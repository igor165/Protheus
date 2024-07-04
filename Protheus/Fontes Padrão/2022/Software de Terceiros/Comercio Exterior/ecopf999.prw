#include "EEC.ch"
#INCLUDE "ecopf999.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ ECOEXP999 ³ Autor ³ EMERSON DIB SALVADOR  ³ Data ³ 08.08.02 ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Previa/Efetivação do Financiamento (Exportação)            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Uso       ³ SIGAEco   											       ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±Revisao    : Marcelo Azevedo     : Data 30/09/04                         ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

                                                         
/*    Victor           
Adiantamento de clientes
605	Pagamento do Cliente
      Este evento ocorrerá assim que for digitado um adiantamento no cadastro de clientes, e este contenha a 
      data de pagamento.

602   Quando é associado um adiantamento de cliente no pedido, o sistema não gera o evento 602, mas sim o evento 115      

590	V.C. Adiantamento (Taxa Subiu) / 591	V.C. Adiantamento (Taxa Desceu)
      Estes eventos ocorrerão sempre que existir o evento 605 e tenha v.c. até o fim do mês ou se for encontrado os 
      eventos 115 ou 116.
      
115   Transferência p/ Antecipado
      Este evento ocorre quando for vinculado o adiantamento ao pedido, e após a vinculação toda a v.c. passará 
      para o pedido.

116	Transferência p/ Embarque
      Este evento ocorre quando for vinculado o adiantamento ao embarque, e somente aparecerá caso a data de embarque
      seja no pedido. Esta vinculação deve ocorrer no mesmo mês da data de embarque.
      
592	V.C. Realizada - Perda / 593	V.C. Realizada - Tx Subiu
      Estes eventos ocorreram quando a data de embarque estiver preenchida e será a v.c. do evento 
      116 - Valor * Tx Embarque

Obs:
0 - Testar melhor os adiantamentos.
1 - Não considerar o saldo do eeq, e sim apurar por período.




*/
                                                         
*-----------------*
Function ECOEXP991
*-----------------*
ECOEXP999("1")
Return .T.

*-----------------*
Function ECOEXP992
*-----------------*
//Alcir Alves - 21-03-05 - variaveis de pre tratamento
Private lEcoEft:=.T. //retorno do rdmake que define se vai efetivar ou não

 If EasyEntryPoint("ECOPF999")
    ExecBlock("ECOPF999",.F.,.F.,"VALIDA_EFETIVACAO")
 Endif
//
 IF lEcoEft==.T.
    ECOEXP999("2")
 ENDIF
Return .T.

*---------------------------*
Function ECOEXP999(cQualProg)
*---------------------------*
Local cPerg := "", cPergDiaMes := "", oCbx
Local aFil := {cFilAnt}//AvgSelectFil(.F.), i    // NICK - 13/03/2006

If(Select("EF1") == 0,ChkFile("EF1",.F.),)
If(Select("EF2") == 0,ChkFile("EF2",.F.),)
If(Select("EF3") == 0,ChkFile("EF3",.F.),)
If(Select("SA2") == 0,ChkFile("SA2",.F.),)
If(Select("SYE") == 0,ChkFile("SYE",.F.),)
If(Select("EEC") == 0,ChkFile("EEC",.F.),)
If(Select("SA6") == 0,ChkFile("SA6",.F.),)
If(Select("EEQ") == 0,ChkFile("EEQ",.F.),)
If(Select("EET") == 0,ChkFile("EET",.F.),)
If(Select("EEM") == 0,ChkFile("EEM",.F.),)
If(Select("EES") == 0,ChkFile("EES",.F.),)
If(Select("SA1") == 0,ChkFile("SA1",.F.),)
If(Select("EE7") == 0,ChkFile("EE7",.F.),)
If(Select("EE9") == 0,ChkFile("EE9",.F.),)
If(Select("SYS") == 0,ChkFile("SYS",.F.),)

Private cFilEF1  := xFilial("EF1"),cFilEF2:=xFilial("EF2"),cFilEF3:=xFilial("EF3"),cFilSYS:=xFilial("SYS")
Private cFilEC1  := xFilial("EC1"),cFilECA:=xFilial("ECA"),cFilSA2:=xFilial("SA2"),cFilEC6:=xFilial("EC6")
Private cFilSYE  := xFilial("SYE"),cFilEEC:=xFilial("EEC"),cFilECC:=xFilial("ECC"),cFilEE9:=xFilial("EE9")
Private cFilSA6  := xFilial("SA6"),cFilEEQ:=xFilial("EEQ"),cFilECF:=xFilial("ECF"),cFilECE:=xFilial("ECE")
Private cFilEET  := xFilial("EET"),cFilECG:=xFilial("ECG"),cFilEEM:=xFilial("EEM"),cFilEES:=xFilial("EES")
Private cFilSA1  := xFilial("SA1"),cFilEE7:=xFilial("EE7"),cFilECI:=xFilial("ECI"),cFilEXL:=xFilial("EXL")
Private cFilSY5  := xFilial("SY5"),cFilACY:=xFilial("ACY")

Private cMesProc := AllTrim(EasyGParam("MV_MESPEXP",,StrZero(Month(dDataBase),2)+StrZero(Year(dDataBase),4)))
Private lExisteECE := EasyGParam("MV_ESTORNO", .F., .F.) // Verifica a existencia da rotina de Estorno
Private nNR_Cont := EasyGParam("MV_NRCONT",,1)
Private lPagAnt   := EasyGParam("MV_AVG0039",,.F.)
Private cCustoPad := AllTrim(EasyGParam("MV_CCPAD",,''))
Private lVcAv   := EasyGParam("MV_AVGVCAV",,.F.) // Variação Cambial após vinculação   MJA 18/08/04
Private lBackTo := EasyGParam("MV_BACKTO",,.F.) // MJA
Private lFESEOD := EasyGParam("MV_AVGFSOD",,.T.) // Verifica se contabiliza Frete, Seguro e Outras Despesas.
Private lComiss := EasyGParam("MV_AVGCOMI",,.T.) // Verifica se contabiliza as comissões.
Private lRegBox := EasyGParam("MV_AVGRECA",,.F.) // Verifica se terá Regime de Caixa
Private cRelato := EasyGParam("MV_ARQECO",,"c:\") // Verifica o caminho que será gravado os DBF´s na Prévia e na Efetivação. MJA 05/04/05
Private nMesEmb := EasyGParam("MV_MESEMB",,1) // Verifica se utilizará a taxa do embarque ou do primeiro dia do mês caso seja embarque fora mês. 1 - Data Embarque / 2 - Início do Mês
Private lZeraCon := EasyGParam("MV_ZERACON",,.F.)
//Private cDtFinan := EasyGParam("MV_ECO0001",,'EF1->EF1_DT_JUR') // VI 19/09/05 - FSM - 10/10/2012
Private cMV_EVEEXCL := EasyGParam("MV_EVEEXCL",,"")  // VI 13/12/05
Private nDiasJur := 1 // EasyGParam("MV_EFF0003",,0) // VI 19/09/05 // Nick 27/04/06 - Solicitado por Victor

Private dData_Con,dDta_Ini,dDta_Fim,cDataSay:=DTOC(dDataBase),lContinua:=.T.,lGeraTxt:=.F.,cHora:=Time()
Private cMes, cAno, nOpca, oProcess
Private cPrv_Efe := cQualProg, aVCProcTotal:={}
Private lTop     := .F., nGeralDB:=0, nGeralCR := 0
Private cTit, nPerg, nLinDialog := 20, aTotContas:={}
Private nColS, nColG, nLin, nTotal600EF3
Private aTabMsg  := {}, B_aTabMsg:={|conteudo| ER_f_say(conteudo)}, aTaxas := {}, aEvePadrao := {}, aProcSYS := {}, aEvePad := {}, aEvePad2 := {}
Private lDiaria  := .F.
Private lTemECANew := .F., lTemEC6New := .F., lTemSYSNew := .F., lTemECFNew := .F., lTemECENew := .F.
Private lTemEEQNew := .F., lTemEETNew := .F., lTemECGNew := .F., lTemEESNew := .F., lTemEEMNew := .F.
Private lGrava := .T. // MJA 24/09/04 USADO APENAS PARA RDMAKE NA GRAVACAO DAS TABELAS ECG E ECF
Private lTemEC6Rat := .F., lTemEF3Cta := .F., lTemEF1PRA := .F.
Private nTotECAFin := 0, nTotECAExp := 0, nTotEF1 := 0, nTotECE := 0, nTotEEC:= 0, nTotEEQ1:=0, nTotEEQ2:=0, nTotECG := 0  // Usada na funcao ECOEXPContaReg
Private aModo := {STR0001}//{STR0001, STR0002}  //"1- Mensal"###"2- Diária"
Private cModo := aModo[1]
Private aTab_TConta := {}, aTab_DebTot := {}, aTab_CreTot := {}
Private nPag  := 0, lTemTPMODU, cTPMODU:=''

Private lEF2_TIPJUR := EF2->(FieldPos("EF2_TIPJUR")) > 0
// Nick - 05/07/2006 - Nova estrutura das tabelas de financiamento - EF1_TPMODU e EF1_SEQCNT.
Private cTipoModu := 'E' // Para o Financiamento utiliza apenas o "E"
Private lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                     EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                     EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                     EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                     EF6->( FieldPos("EF6_SEQCNT") ) > 0 .AND. EF3->( FieldPos("EF3_ORIGEM") ) > 0 .and.;
                     EF3->( FieldPos("EF3_ROF"   ) ) > 0 .AND. ECA->( FieldPos("ECA_SEQCNT") ) > 0 .AND.;
                     ECF->( FieldPos("ECF_SEQCNT") ) > 0 .AND. ECE->( FieldPos("ECE_SEQCNT") ) > 0

// Nick - 05/07/2006 - Tabela de cadastro de Financiamentos.
Private lCadFin := ChkFile("EF7") .AND. ChkFile("EF8") .AND. ChkFile("EF9")
// Verifica a existencia de novos campos no SX3
SX3->(DbSetOrder(2))
lTemECANew := SX3->(DbSeek("ECA_CONTRA")) .And. SX3->(DbSeek("ECA_PREEMB")) .And. SX3->(DbSeek("ECA_FASE"))  .And. ;
              SX3->(DbSeek("ECA_TIPO")) .And. SX3->(DbSeek("ECA_FAOR")) .And. SX3->(DbSeek("ECA_PROR")) .And. ;
              SX3->(DbSeek("ECA_PAOR")) .And. SX3->(DbSeek("ECA_NRNF")) .And. SX3->(DbSeek("ECA_CONTAB"))
lTemEC6New := SX3->(DbSeek("EC6_TPMODU")) .And. SX3->(DbSeek("EC6_DIAMES"))
lTemSYSNew := SX3->(DbSeek("YS_TPMODU"))
lTemECFNew := SX3->(DbSeek("ECF_CONTRA")) .And. SX3->(DbSeek("ECF_TP_EVE")) .And. SX3->(DbSeek("ECF_PREEMB")) .And. ;
    		  SX3->(DbSeek("ECF_FASE"))   .And. SX3->(DbSeek("ECF_TIPO")) .And. SX3->(DbSeek("ECF_FAOR")) .And. ;
    		  SX3->(DbSeek("ECF_PROR"))   .And. SX3->(DbSeek("ECF_PAOR")) .And. SX3->(DbSeek("ECF_NRNF")) .And. ;
    		  SX3->(DbSeek("ECF_CONTAB"))
lTemECENew := SX3->(DbSeek("ECE_SEQ"))    .And. SX3->(DbSeek("ECE_ORIGEM")) .And. SX3->(DbSeek("ECE_VL_MOE")) .And. ;
	    	  SX3->(DbSeek("ECE_TX_ATU")) .And. SX3->(DbSeek("ECE_TX_ANT")) .And. SX3->(DbSeek("ECE_CONTRA")) .And. ;
			  SX3->(DbSeek("ECE_TP_EVE"))
lTemEETNew := SX3->(DbSeek("EET_NR_CON")) .And. SX3->(DbSeek("EET_DTDEMB"))
lTemEEQNew := SX3->(DbSeek("EEQ_NR_CON"))
lTemECGNew := SX3->(DbSeek("ECG_PREEMB"))
lTemEESNew := SX3->(DbSeek("EES_NR_CON"))
lTemEEMNew := SX3->(DbSeek("EEM_TXTB"))
lTemTPMODU := SX3->(DbSeek("ECG_TPMODU")) .AND. SX3->(DbSeek("ECF_TPMODU")) .AND. SX3->(DbSeek("ECE_TPMODU"))
lTemEC6Rat := SX3->(DbSeek("EC6_RATEIO"))
lTemEF3Cta := SX3->(DbSeek("EF3_CTA_DB")) .And. SX3->(DbSeek("EF3_CTA_CR"))
lTemEF1PRA := SX3->(DBSEEK("EF3_PRACA")) .and. SX3->(DBSEEK("EF1_PRACA"))
lTemFilOri := SX3->(DbSeek("EF3_FILORI")) .and. SX3->(DbSeek("ECA_FILORI")) .and. SX3->(DbSeek("ECF_FILORI"))  // VI 20/12/05
lTemEC6Pro := SX3->(DbSeek("EC6_PROCES"))

SX3->(DbSetOrder(1))              
nNrUltCont := 'XXXX'
EC1->(DBSETORDER(2))
EC1->(DBSEEK(cFilEC1+'EXPORT'))
DO WHILE EC1->(!EOF()) .AND. cFilEC1 = EC1->EC1_FILIAL .AND. EC1->EC1_TPMODU = 'EXPORT'   
   IF EC1->EC1_STATUS = ' '
      nNrUltCont := EC1->EC1_NR_CON
   ENDIF   
   EC1->(DBSKIP())
ENDDO

If lTemTPMODU
   cTPMODU:='EXPORT'
   bTPMODUECF := {|| ECF->ECF_TPMODU = 'EXPORT' }
   bTPMODUECG := {|| ECG->ECG_TPMODU = 'EXPORT' }
   bTPMODUECE := {|| ECE->ECE_TPMODU = 'EXPORT' }
Else
   bTPMODUECF := {|| .T. }
   bTPMODUECG := {|| .T. }
   bTPMODUECE := {|| .T. }
EndIf

#IFDEF TOP
  IF (TcSrvType() != "AS/400")   // Considerar qdo for AS/400 para que tenha o tratamento de Codbase
     lTop := .T.
  Endif
#Endif

cMesSAY  := SUBSTR(cMesProc,1,2)+"/"+SUBSTR(cMesProc,3,4)
cMes     := STRZERO(VAL(SUBSTR(cMesProc,1,2))+1,2,0)
cAno     := SUBSTR(cMesProc,3,4)
IF cMes = "13"
   cMes := "01"
   cAno := STRZERO(VAL(cAno)+1,4,0)
Endif
dData_Con := AVCTOD("01/"+cMes+"/"+cAno) - 1
dDta_Ini := AVCTOD("01/"+SUBSTR(cMesProc,1,2)+"/"+SUBSTR(cMesProc,3,4))
dDta_Fim  := dData_Con

IF cPrv_Efe = "1"
   cTit        :=STR0003 //"Prévia Financiamento/Exportação"
   cPerg       :=STR0004 //"Confirma Prévia Financiamento/Exportação ?"
   cPergDiaMes :=STR0005 //"Tipo Prévia"
Else
   cTit        := STR0006 //"Efetivação Financiamento/Exportaçao"
   cPerg       := STR0007 //"Confirma Efetivação Financiamento/Exportação ?"
   cPergDiaMes := STR0008 //"Tipo Efetivação"
Endif

DEFINE MSDIALOG oDlg TITLE cTit From 9,0 To nLinDialog+2,46 OF GetWndDefault()

   nOpca    := 0
   nColS    := 2.0
   nColG    := 10.5
   nLin     := 1.5
   cNR_Say  := STRZERO(nNR_Cont+1,4,0)

   @ nLin++,nColS SAY STR0009 //"Mês em Processamento"
   @ nLin++,nColS SAY STR0010 //"No. da Contabilização"
   @ nLin++,nColS SAY STR0011 //"Data da Contabilização"
   @ nLin++,nColS SAY STR0012 //"Hora da Contabilização"
   @ nLin++,nColS SAY STR0013 //"Contabilizar com Data"
   @ nLin++,nColS SAY cPergDiaMes

   nLin := 1.5
   @ nLin++,nColG MSGET cMesSAY   When .F. SIZE 35,08 OF oDlg
   @ nLin++,nColG MSGET cNR_Say   When .F. SIZE 35,08 OF oDlg
   @ nLin++,nColG MSGET cDataSAY  When .F. SIZE 35,08 OF oDlg
   @ nLin++,nColG MSGET cHora     When .F. SIZE 35,08 OF oDlg
   @ nLin++,nColG MSGET dData_Con          SIZE /*35*/42,08 OF oDlg  // GFP - 21/11/2011
   @ nLin++,nColG ComboBox oCbx Var cModo Items aModo When .F. SIZE 50,08 of oDlg

ACTIVATE MSDIALOG oDlg ON INIT ;
         EnchoiceBar(oDlg,{||IF(PREXP999Val(1),(nOpca:=1,oDlg:End()),)},;
                          {||nOpca:=0,oDlg:End()}) CENTERED

If nOpca # 0

   // Verifica se ultima efetivação teve algum problema
   EC1->(DbSetOrder(2))
   If EC1->(DbSeek(cFilEC1+"EXPORT"+STRZERO(nNR_Cont,4,0)))
      If EC1->EC1_OK = '2' .And. EC1->EC1_STATUS # 'E'
         MsgInfo(STR0014 + StrZero(nNR_Cont,4,0) + STR0015) //"Houve problema(s) com a ultima contabilizacao "###" .Estorne para prosseguir."
         lContinua := .F.
      Endif
      If lContinua .AND. (EC1->EC1_MES+EC1->EC1_ANO) = cMesProc .And. EC1->EC1_STATUS # 'E'
         MsgInfo(STR0016) //"Período a ser processado é igual ao último período efetivado. Favor trocar o período de processamento."
         lContinua := .F.
      Endif
   Endif
   EC1->(DbSetOrder(1))

   /* AAF 20/02/09 - Contabilizar apenas filial corrente
   IF LEN(aFil) > 1  // NICK 13/03/2006
      E_Msg(STR0101,1)  //"Esta operação não pode ser executada por usuarios com acesso a mais de uma Filial."
      lContinua := .f.
   Endif 
   */

   If lContinua .AND. SimNao(cPerg,STR0098,,,,STR0017)=='S' //"Atenção"    //"Financiamento Exportação"   // GFP - 21/11/2011

      // Verifica se a prévia / efetivação é Diaria / Mensal
      lDiaria := If(Left(cModo,1)="2", .T., .F.)

      // Grava no arquivo EC1 os dados da efetivaçao
      If cPrv_Efe = "2"
         GrvPF999EC1()
         Reclock('EC1',.F.)
         EC1->EC1_OK := "2"
         EC1->(Msunlock())
      Endif

      MsAguarde({||ECOEXPContaReg()},  STR0018)                    // Contagem de Registros //"Aguarde... Apurando Dados..."
      MsAguarde({||ECOECAContaReg('TODOS')},  STR0019)             // Contagem de Registros do ECA //"Aguarde... Apurando Dados Arq.Prévia..."

      IF cPrv_Efe == "2"
         cTotProc:= "8"
      Else
         cTotProc:= "5"
      EndIf

      oProcess := MsNewProcess():New({|lEnd| PRFIN999Func(@lEnd) },cTit,STR0029+"1 / "+cTotProc,.T.)
      oProcess:Activate()

   Endif
Endif

EF1->(DBSETORDER(1))
EF2->(DBSETORDER(1))
EF3->(DBSETORDER(1))
ECA->(DBSETORDER(1))
SYE->(DBSETORDER(1))
EC6->(DBSETORDER(1))
SYS->(DbSetOrder(1))
EEC->(DBSETORDER(1))
EEQ->(DBSETORDER(1))
EET->(DbSetOrder(1))
ECF->(DbSetOrder(1))
ECG->(DbSetOrder(1))

Return .T.

*--------------------------*
Function PRFIN999Func(lEnd)
*--------------------------*
Local cxFilAnt := cFilAnt , nFil    // MJA 10/01/05 
Local aFil := {cFilAnt}//AAF 20/02/09 - Contabilizar apenas filial corrente. //AvgSelectFil(.F.)    // MJA 10/01/05 
Private lPrimeira := .T.        
Private lGeraRel := .T.
oProcess:SetRegua1(Val(cTotProc))

oProcess:IncRegua1(STR0096+"1 / "+cTotProc+" "+STR0020)
ECOEXP999_LIMPA(@lEnd) // Limpa Arquivo de Prévia 
If lEnd
   Return .F.
EndIf

oProcess:IncRegua1(STR0096+"2 / "+cTotProc+" "+STR0021)
PRFIN999Proc(@lEnd)    // Contabilização ACC/ACE 

If lEnd
   Return .F.
EndIf

// **
For nFil := 1 to Len(aFil)  // MJA 10/01/05
   cFilAnt := aFil[nFil]    // MJA 10/01/05
   ChangeFilial()           // MJA 10/01/05 
   
   // ** AAF 27/04/2007 - Processa os estornos dos eventos contabilizados anteriormente.
   ProcEst()
   oProcess:IncRegua1(STR0096+"3 / "+cTotProc+" "+STR0022)
   // **
   
   PREXP999Proc(@lEnd)    // Contabilização Exportação //"Lendo Processos..."
   lPrimeira := .F.
Next    // MJA 10/01/05 
// **
If lEnd
   Return .F.
EndIf

// Impressão do Relatório                              
oProcess:IncRegua1(STR0096+"5 / "+cTotProc+" "+STR0023)
MsAguarde({||ECOECAContaReg('TODOS')},  STR0019)   // Contagem de Registros do ECA //"Aguarde... Apurando Dados Arq.Prévia..."
If (nTotECAExp+nTotECAFin) > 0
   If(EasyEntryPoint("ECOPF999"),ExecBlock("ECOPF999",.F.,.F.,"FIM_DOS_CALCULOS"),) // MJA 20/04/05
   If lGeraRel
      ER_PF999IMP(@lEnd) //"Gerando Arq. p/ Impressão..."
    else
      ExecBlock("ECOPF999",.F.,.F.,"IMPRIME")
   Endif   
   If lEnd
      Return .F.
   EndIf
   IF cPrv_Efe == "2" .AND. lGeraTxt
      oProcess:IncRegua1(STR0096+"6 / "+cTotProc+" "+STR0024)
      PREXP999TXT(@lEnd) //"Gerando Arq. de Texto."
      If lEnd
         Return .F.
      EndIf
      oProcess:IncRegua1(STR0096+"7 / "+cTotProc+" "+STR0025)
      ECOEXP999_LIMPA(@lEnd) // Limpando Arquivo da Efetivação...      
   Endif
Else
   E_Msg(STR0026,1) //"Não há registros para impressão."
Endif

// Grava nos parametros a Hora / Dt.da Previa
DbSelectArea("ECA")
If cPrv_Efe = "1"
   SETMV('MV_HOPREV',cHora)
   SETMV('MV_DTPREV',dDataBase)
   If(EasyEntryPoint("ECOPF999"),ExecBlock("ECOPF999",.F.,.F.,"PLANPRE"),) // MJA 28/06/05 
Else
   oProcess:IncRegua1(STR0096+"8 / "+cTotProc+" "+STR0099)
   nGeralDB := nGeralCR := 0
   PRFIN999TotC(@lEnd) // "Gravando Totais das Contas..." 
   If lEnd
      Return .F.
   EndIf
 
// Grava no arquivo EC1 os dados da efetivaçao quando a efetivação chegou até o fim sem problemas.
   Reclock('EC1',.F.)
   EC1->EC1_OK := "1"
   EC1->EC1_VAL_DB := nGeralDB 
   EC1->EC1_VAL_CR := nGeralCR    
   EC1->(Msunlock())
Endif
cFilAnt := cxFilAnt    // MJA 10/01/05 
Return .T.                             

*--------------------------*
Function PRFIN999TotC(lEnd)
*--------------------------*
Local i:=1, cFilECH := xFilial('ECH')
oProcess:SetRegua2(Len(aTotContas))
For i:=1 to Len(aTotContas)
    oProcess:IncRegua2("1 / 1 "+STR0090+': '+Alltrim(aTotContas[i,1])) //Conta
    Reclock('ECH',.T.)
    ECH->ECH_FILIAL := cFilECH
    ECH->ECH_TPMODU := 'EXPORT'
    ECH->ECH_NR_CON := STRZERO(nNR_Cont+1,4,0)
    ECH->ECH_CONTA  := aTotContas[i,1]
    ECH->ECH_VAL_DB := aTotContas[i,2]
    ECH->ECH_VAL_CR := aTotContas[i,3]
    ECH->(Msunlock())
    
    nGeralDB += aTotContas[i,2]
    nGeralCR += aTotContas[i,3]
Next 
Return .T.                             

*--------------------------*
Function PRFIN999Proc(lEnd)
*--------------------------*
Local cSeqAtual  := Space(Len(EF3->EF3_SEQ)), cParcAtual := Space(Len(EF3->EF3_PARC)), nTxFimMes := 0, nTotalInv := 0, nCont := 1, nTxUltima := 0
Local nVar550Acc := 0, nVar500Acc := 0, nVar520Acc := 0
Local nVar500Ace := 0, nVar520Ace := 0, nVar550Ace := 0
Local nT550AccM  := 0, nT500AccM  := 0, nT520AccM := 0
Local nT550AccR  := 0, nT500AccR  := 0, nT520AccR := 0
Local nT500AceM  := 0, nT520AceM  := 0, nT550AceM  := 0, nT600AceM  := 0, nT630AceM := 0
Local nT650AceM  := 0, nTotSldJM   := 0
Local nT520AceR  := 0, nT550AceR  := 0, nT600AceR := 0
Local nT630AceR  := 0, nT650AceR  := 0
Local lGeraVar   := .T., lAccAce  := .F., nTotVarACC := 0, l600Contab := .F., l100Contab := .F.
Local aTx_Dia    := {}, aInvoices := {}, aTx_Cont := {}, aTx_Ctb := {}
Local nPos       := 0 , nPos1 := 0, nDesagio := 0
Local aInv600    := {}, aInv650 := {}
Local aDadosPRV  := {}, aDadosEF3 := {}, aDados101 := {}
Local nIndexAnt, nRecnoECE
Local cEvento, cParc, dDtEve100 := AVCTOD(' / / ')
Local nTxEmb := 0, nVarEmbVin := 0, x
Local lGrava520 := .T.
Local nRecOld, nIndOld, cInv, cParcela
Local nSlPri, nSlJur
Local cFilCompartilhada:=EasyGParam("MV_ECOFILC",,"") // MV_ que define qual filial irá contabilizar os arquivos compartilhados.
Local i
Local nInd
Private lIsContab := .F.  // PLB 13/06/07 - Identifica se o Contrato de Financiamento foi Contabilizado

SYS->(DbSetOrder(2))
EF3->(DbSetOrder(6))
EF1->(DbSetOrder(1))
SYE->(DbSetOrder(2))
EC6->(DbSetOrder(6))
SA1->(DbSetOrder(1))
SA2->(DbSetOrder(1))
SA6->(DbSetOrder(1))
EEQ->(DbSetOrder(1))
EEC->(DbSetOrder(1))
EET->(DbSetOrder(1))
If lTemECFNew .And. lTemECGNew .And. lTemECANew
   ECG->(DbSetOrder(4))
Endif

EF1->(DbSeek(cFilEF1+IF(lEFFTPMOD,cTipoModu,""))) // Nick 02/08/06
oProcess:SetRegua2(nTotEF1)                 

Do While EF1->(!EOF()) .And. EF1->EF1_FILIAL == cFilEF1 .And. IF(lEFFTPMOD,EF1->EF1_TPMODU = cTipoModu,.T.) .And. ;
   If(Empty(cFilCompartilhada),.T.,If(cFilCompartilhada=cFilEC1,.T.,.F.))

   If lEnd
      If lEnd:=MsgYesNo(STR0097,STR0098)
         Return .F.
      EndIf
   EndIf
   
   lGeraVar   := .T.
   lAccAce    := l100Contab := l600Contab := .F.
   lEvento    := 100
   nT500AccR  := nT520AccR := nT550AccR := 0
   nT500AccM  := nT520AccM := nT550AccM := nT650AceM := nTotSldJM := 0
   nT500AceM  := nT520AceM := nT550AceM := nT600AceM := nT630AceM := 0
   nT500AceR  := nT520AceR := nT550AceR := nT600AceR := nT630AceR := 0
   nT650AceR  := 0
   dDtEve100  := AVCTOD(' /  / ')
   
   oProcess:IncRegua2("1 / 1 "+STR0027+Alltrim(EF1->EF1_CONTRA)) //"Contrato: "

   If !Empty(EF1->EF1_DT_ENCE) .and. EF1->EF1_DT_ENCE < dDta_Ini
      EF1->(DBSKIP())
      LOOP
   Endif

   If Empty(EF1->EF1_DT_JUR) .or. EF1->EF1_DT_JUR > dDta_Fim
      Sem_Juros(EF1->EF1_CONTRA)   
      EF1->(DBSKIP())
      LOOP
   Endif
   
   // PLB 13/06/07 - Verifica se o Contrato de Financiamento já havia sido contabilizado
   lIsContab := EX401IsCtb(EF1->EF1_CONTRA,IIF(lTemEF1PRA,EF1->EF1_BAN_FI,""),IIF(lTemEF1PRA,EF1->EF1_PRACA,""),IIF(lEFFTpMod,EF1->EF1_SEQCNT,""))


************************************************** // MJA 14/09/05   Aqui apura-se os saldos na moeda que serão utilizados nos cálculos
   EF3->(DbSetOrder(6))   
   if lTemEF1PRA
      EF3->(DbSeek(cFilEF3+IIF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+IIF(lEFFTpMod,EF1->EF1_SEQCNT,""))) // Nick 05/07/06
    else
      EF3->(DbSeek(cFilEF3+IIF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA)) // Nick 05/07/06
   endif   
   nSlPri := EF1->EF1_VL_MOE  // EF1_SLD_PM
   nSlJur := 0                // EF1_SLD_JM
   nSlACE := 0                // EF1_SL2_PM
   Do While EF3->(!Eof()) .And. EF3->EF3_FILIAL = cFilEF3 .And. EF3->EF3_CONTRA = EF1->EF1_CONTRA      
      IF EF3->EF3_DT_EVE <= dDta_Fim
         DO CASE
            CASE !(EF1->EF1_CAMTRA == "1") .AND. EF3->EF3_CODEVE = '600'
                 nSlPri -= EF3->EF3_VL_MOE
                 nSlACE += EF3->EF3_VL_MOE
            CASE Left(EF3->EF3_CODEVE,2) = '52' .And. EF3->EF3_TP_EVE # '02' //VI 21/12/05
                 nSlJur += EF3->EF3_VL_MOE
            CASE Left(EF3->EF3_CODEVE,2) = '51' .And. EF3->EF3_TP_EVE # '02' //VI 21/12/05
                 nSlJur -= EF3->EF3_VL_MOE
            CASE EF3->EF3_CODEVE = '650'
                 nSlJur -= EF3->EF3_VL_MOE                 
            CASE EF3->EF3_CODEVE = '700' .AND. EF3->EF3_TX_MOE <> 0 .AND. EF3->EF3_VL_REA <> 0 .AND. EF1->EF1_CAMTRA == "1"
                 nSlPri -= EF3->EF3_VL_MOE
         ENDCASE
      ENDIF
      EF3->(DBSKIP())                                               
   Enddo
**************************************************

//   If lEF2_TIPJUR
//      aJuros := EX400BusJur("EF2","EF1")
//    Else
      aJuros := {"0"} // Caso não tenha a configuração para mais de um tipo de juros, carrega como '0'
//   EndIf

   // Taxa dos dias p/ calculo da provisão de juros
   //If Empty(EF1->EF1_DT_CTB) .Or. EF1->EF1_DT_CTB = EF1->EF1_DT_JUR
   // PLB 13/06/07
   If Empty(EF1->EF1_DT_CTB)  .Or.  !lIsContab
         aTx_Dia  := EX400BusTx(EF1->EF1_TP_FIN, dDta_Fim, EF1->EF1_DT_JUR-nDiasJur, "EF1", "EF2",aJuros[1]) // Nick 27/04/06
//         aTx_Dia  := EX400BusTx(EF1->EF1_TP_FIN, dDta_Fim, EF1->EF1_DT_JUR, "EF1", "EF2",aJuros[1])
      aTx_Ctb  := {}
/*      For x:=1 to Len(aTx_Dia) // MJA 04/08/05 Foi retirado apos conversa com a Rita
//        aTx_Dia[x,1] := EF1->EF1_TX_CTB   VI 27/07/05
          IF x = Len(aTx_Dia)
             aTx_Dia[x,2] := aTx_Dia[x,2] + 1 // Sempre soma-se mais um no ultimo parametro do aTaxa para trazer o numero de dias correto para o contabil MJA 23/07/05
          endif   
      Next*/
   Else
//      aTx_Dia  := EX400BusTx(EF1->EF1_TP_FIN, dDta_Fim, EF1->EF1_DT_CTB+1, "EF1", "EF2",aJuros[1])
        aTx_Dia  := EX400BusTx(EF1->EF1_TP_FIN, dDta_Fim, EF1->EF1_DT_CTB, "EF1", "EF2",aJuros[1])
        aTx_Ctb  := EX400BusTx(EF1->EF1_TP_FIN, EF1->EF1_DT_CTB, EF1->EF1_DT_JUR-nDiasJur , "EF1", "EF2",aJuros[1])
      
/*       For x:=1 to Len(aTx_Dia)             // MJA 23/07/05
             if x = Len(aTx_Dia)
                aTx_Dia[x,2] := aTx_Dia[x,2] + nDiasJur // Sempre soma-se mais um no ultimo parametro do aTaxa para trazer o numero de dias correto para o contabil MJA 19/09/05
             endif   
         Next*/
/*      If Len(aTx_Dia) # 0 // VI 28/07/05 MJA 04/08/05 Foi retirada apos conversa com a Rita
         aTx_Dia[Len(aTx_Dia),2] := aTx_Dia[Len(aTx_Dia),2] + 1 // Sempre soma-se mais um no ultimo parametro do aTaxa para trazer o numero de dias correto para o contabil MJA 23/07/05
      EndIf

      If Len(aTx_Ctb) # 0 // VI 28/07/05
         aTx_Ctb[Len(aTx_Ctb),2] := aTx_Ctb[Len(aTx_Ctb),2] + 1 // Sempre soma-se mais um no ultimo parametro do aTaxa para trazer o numero de dias correto para o contabil MJA 23/07/05
      EndIf
      */
   EndIf

   // Apura o total das invoices no Período  
   if lTemEF1PRA
         nTotalInv := ECOEXP999INV(IF(lEFFTpMod,EF1->EF1_TPMODU,''),EF1->EF1_CONTRA,EF1->EF1_BAN_FI,EF1->EF1_PRACA,IF(lEFFTpMod,EF1->EF1_SEQCNT,''),If(EF1->EF1_CAMTRA = '1', '700', '600'))
    else
         nTotalInv := ECOEXP999INV(IF(lEFFTpMod,EF1->EF1_TPMODU,''),EF1->EF1_CONTRA)
   endif   
   
   // Taxa do último dia do mês na moeda do contrato
   EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT","")+'101')) 
   cTX_101 := EC6->EC6_TXCV
   if EF1->EF1_TP_FIN = '03' .or. EF1->EF1_TP_FIN = '04' // MJA 26/05/05 Para buscar os eventos no EC6 correspondente ao Pré-Pagamento ou Securitização
      EC6->(DbSeek(cFilEC6+If(lTemEC6New,"FIEX"+EF1->EF1_TP_FIN,"")+'100'))
      cTX_100 := EC6->EC6_TXCV
      nTxFimMes      := ECOEXP999Tx(EF1->EF1_MOEDA, dDta_Fim, cTX_100 )
      EC6->(DbSeek(cFilEC6+If(lTemEC6New,"FIEX"+EF1->EF1_TP_FIN,"")+'520'))
      cTX_520 := EC6->EC6_TXCV
      nTxFimMesJuros := ECOEXP999Tx(EF1->EF1_MOEDA, dDta_Fim, cTX_520 )
    else
      EC6->(DbSeek(cFilEC6+If(lTemEC6New,"FIEX01","")+'100'))
      cTX_100 := EC6->EC6_TXCV
      nTxFimMes      := ECOEXP999Tx(EF1->EF1_MOEDA, dDta_Fim, cTX_100 )
      EC6->(DbSeek(cFilEC6+If(lTemEC6New,"FIEX01","")+'520'))
      cTX_520 := EC6->EC6_TXCV
      nTxFimMesJuros := ECOEXP999Tx(EF1->EF1_MOEDA, dDta_Fim, cTX_520 )
   endif

   // Última taxa de contabilização do contrato
   //nTxUltima      := EF1->EF1_TX_CTB
   //nTxUltimaJuros := ECOEXP999Tx(EF1->EF1_MOEDA, EF1->EF1_DT_CTB, cTX_520)
   //** PLB 13/06/07
   If Empty(EF1->EF1_DT_CTB)  .Or.  !lIsContab
      nTxUltima      := BuscaTaxa(EF1->EF1_MOEDA,EF1->EF1_DT_JUR,,.F.,.T.,,cTX_100)
      nTxUltimaJuros := ECOEXP999Tx(EF1->EF1_MOEDA,EF1->EF1_DT_JUR, cTX_520)
   Else
      nTxUltima      := EF1->EF1_TX_CTB
      nTxUltimaJuros := ECOEXP999Tx(EF1->EF1_MOEDA, EF1->EF1_DT_CTB, cTX_520)
   EndIf
   //**

   // Verifica se há eventos no periodo ou ja contabilizados
   if lTemEF1PRA // MJA 27/01/05
      lAccAce   := ECOEXP999BUS(IF(lEFFTpmod,'E',''),EF1->EF1_CONTRA, '600', .F.,EF1->EF1_BAN_FI,EF1->EF1_PRACA,IF(lEFFTpmod,EF1->EF1_SEQCNT,''))     // Verifica se há o evento no periodo e nao esta contabilizado
      If !lAccAce
         l600Contab:= ECOEXP999BUS(IF(lEFFTpmod,'E',''),EF1->EF1_CONTRA, '600', .T.,EF1->EF1_BAN_FI,EF1->EF1_PRACA,IF(lEFFTpmod,EF1->EF1_SEQCNT,''))  // Verifica se há o evento e esta contabilizado
      Endif
    else
      lAccAce   := ECOEXP999BUS(EF1->EF1_CONTRA, '600', .F.)     // Verifica se há o evento no periodo e nao esta contabilizado
      If !lAccAce
         l600Contab:= ECOEXP999BUS(EF1->EF1_CONTRA, '600', .T.)  // Verifica se há o evento e esta contabilizado
      Endif
   endif
   // Até aqui, está OK 26/05/05 Pré-pagamento
   aDadosPRV  := {}
   aDadosEF3  := {}
   EF3->(DbSetOrder(6))   
   // Busca no EF3 os eventos do Contrato
//VI 26/07/05   EF3->(DBSETORDER(1))  // MJA 30/03/05
   if lTemEF1PRA
         EF3->(DbSeek(cFilEF3+IIF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+IIF(lEFFTpMod,EF1->EF1_SEQCNT,""))) // Nick 05/07/06
    else
         EF3->(DbSeek(cFilEF3+IIF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA)) // Nick 05/07/06
   endif   

   Do While EF3->(!Eof()) .And. EF3->EF3_FILIAL = cFilEF3 .And. EF3->EF3_CONTRA = EF1->EF1_CONTRA
   
      aInv600    := {}
      aInv650    := {}

      nVar500Acc := 0; nVar520Acc := 0; nVar550Acc := 0; nVar500Acc := 0; nVar520Acc := 0
      nVar500Ace := 0; nVar520Ace := 0; nVar550Ace := 0; nT650AceM  := 0; nTotSldJM   := 0
      nTotVarACC := 0
      cSeqAtual  := EF3->EF3_SEQ
      cInvoice   := EF3->EF3_INVOIC
      cParc      := EF3->EF3_PARC
      lEvento100 := .F.
      nTot700Liq := 0
      
      Do While EF3->(!Eof()) .And. EF3->EF3_FILIAL = cFilEF3 .And. EF3->EF3_CONTRA = EF1->EF1_CONTRA ;
               .And. EF3->EF3_INVOIC = cInvoice .And. EF3->EF3_PARC = cParc        
         
         IF EF3->EF3_DT_EVE > dDta_Fim // MJA 14/09/05
            EF3->(DBSKIP())
            LOOP
         ENDIF
         
         IF EF3->EF3_CODEVE = "140"  // Para Calcular a Comissao Financeira
            cInv  := EF3->EF3_INVOIC
            cParcela := EF3->EF3_PARC
            cCodEve  := SUBSTR(EF3->EF3_CODEVE,3,1) // MJA 12/02/05 Pega o indicador do tipo de Juros para pesquisar depois no 64 ou 67
            nRecOld := EF3->(Recno())
            nIndOld := EF3->(INDEXORD())
            EF3->(DBSETORDER(2))
               if EF3->(DBSEEK(cFilEF3+IIF(lEFFTpMod,cTipoModu,"")+'615'+cInv+cParcela)) // Nick 05/07/06
               nTaxa := EF3->EF3_TX_MOE
               dData_OK := EF3->EF3_DT_EVE
             else
               nTaxa := nTxFimMes
               dData_OK := dDta_Fim
            endif
            EF3->(DBSETORDER(nIndOld))
            EF3->(DBGOTO(nRecOld))
                          //         1               2               3             4                5             6       7           8          9           10            11              12        13     14                                         15                                         16             17            18             19          20                    21
            AADD(aDadosEF3, {EF3->EF3_VL_REA,EF1->EF1_MOEDA,EF3->EF3_CODEVE,EF3->EF3_INVOIC,EF3->EF3_PARC,EF3->EF3_CONTRA,"",EF3->EF3_CODEVE,dData_OK,EF3->EF3_SEQ,EF3->EF3_TP_EVE,EF3->EF3_VL_MOE,nTaxa,nTxUltima,If(EF3->EF3_TP_EVE='01','ACC',If(EF3->EF3_TP_EVE='02', 'ACE', 'PRE') ),EF3->EF3_PREEMB,EF1->EF1_BAN_FI,EF1->EF1_PRACA,EF1->EF1_AGENFI,EF1->EF1_NCONFI,IF(lEFFTpMod,EF1->EF1_SEQCNT,"")})
         						  //        1               2                 3               4                5            6            7           8        9    10  11                                    12                                          13         14  15  16  17  18  19  20 21         22           23                24      25       26             27         28     29
            AAdd(aDadosPRV, {EF3->EF3_VL_REA, EF3->EF3_CODEVE, EF3->EF3_CONTRA, EF3->EF3_INVOIC, EF3->EF3_CODEVE, dData_OK, EF1->EF1_MOEDA, nTaxa, nTxUltima, "", "", If(EF3->EF3_TP_EVE='01','ACC',If(EF3->EF3_TP_EVE='02', 'ACE', 'PRE') ), EF3->EF3_PREEMB, "", "", "", "", "", "", "", 0, EF3->(RECNO()),EF3->EF3_VL_REA,CLI_TIP('EF3',cInvoice,'1'),'',EF3->EF3_BANC,EF3->EF3_PRACA,cFilEF3,IF(lEFFTpMod,EF3->EF3_SEQCNT,"")}) // Nick 20/10/06
            nVariacao := (EF3->EF3_VL_MOE*nTaxa - EF3->EF3_VL_REA)
//            If nVariacao <> 0 //    1                     2                        3                 4                        5                    6              7         8        9      10  11                   12                         13        14  15  16  17  18  19  20 21 22    23     24 25       26           27          28
               AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, '596', '597'), EF3->EF3_CONTRA, EF3->EF3_INVOIC, If(nVariacao > 0, '596', '597'), dData_OK,  EF1->EF1_MOEDA, nTaxa, nTxUltima, "", "", If(EF3->EF3_TP_EVE='01','ACC',If(EF3->EF3_TP_EVE='02', 'ACE', 'PRE') ), EF3->EF3_PREEMB, "", "", "", "", "", "", "", 0, EF3->(RECNO()),nVariacao,'','',EF3->EF3_BANC,EF3->EF3_PRACA,cFilEF3,IF(lEFFTpMod,EF3->EF3_SEQCNT,"")})
                             //     1            2                       3                      4                5             6       7                  8                   9           10            11              12        13     14       15          16
               AADD(aDadosEF3, {nVariacao,EF1->EF1_MOEDA,If(nVariacao > 0, '596', '597'),EF3->EF3_INVOIC,EF3->EF3_PARC,EF3->EF3_CONTRA,"",If(nVariacao > 0, '596', '597'),dData_OK,EF3->EF3_SEQ,EF3->EF3_TP_EVE,EF3->EF3_VL_MOE,nTaxa,nTxUltima,If(EF3->EF3_TP_EVE='01','ACC',If(EF3->EF3_TP_EVE='02', 'ACE', 'PRE') ),EF3->EF3_PREEMB,EF1->EF1_BAN_FI,EF1->EF1_PRACA,EF1->EF1_AGENFI,EF1->EF1_NCONFI,IF(lEFFTpMod,EF1->EF1_SEQCNT,"")})
               
//            Endif
         ENDIF

         // Somatória Saldo de Juros ACE na Moeda
         lGrava520 := .T.
         If EF3->EF3_CODEVE = '650' .Or. (EF3->EF3_CODEVE = '520' .And. EF3->EF3_GERECO = '1')
            nTotSldJM += EF3->EF3_VL_MOE
         Elseif EF3->EF3_CODEVE = '640' 
            nTotSldJM -= EF3->EF3_VL_MOE
         Endif

         // Verifica se o evento 100 esta nesta sequencia
         lEvento100 := If(!lEvento100, If(EF3->EF3_CODEVE = '100' .And. !Empty(Val(EF3->EF3_NR_CON)), .T., .F.), .T.)
         // Verifica a data do evento 100 (Embarque)
         If(Empty(dDtEve100) .And. EF3->EF3_CODEVE = '100', dDtEve100 := EF3->EF3_DT_EVE, )

         // Emb.Transf. Principal ACC/ACE - 600
         If EF3->EF3_CODEVE = '600'
		    AAdd(aInv600, {EF3->EF3_INVOIC, EF3->EF3_PARC, EF3->EF3_DT_EVE,; 
		                   EF3->EF3_VL_MOE, EF3->EF3_VL_REA, EF3->EF3_SEQ,;
		                   EF3->EF3_TX_MOE, EF3->EF3_PREEMB, EF3->EF3_NR_CON,;
		                   EF3->EF3_MOE_IN, EF3->EF3_VL_MOE} ) // VI 16/10/03
         Endif
        
         // Liquidação Principal ACE - 630
         If EF3->EF3_CODEVE = '630' .And. ((EF3->EF3_DT_EVE >= (dDta_Ini) .And. EF3->EF3_DT_EVE <= (dDta_Fim) .Or. EF3->EF3_DT_EVE < (dDta_Ini)) .Or. !Empty(Val(EF3->EF3_NR_CON)))
            nPos := Ascan(aInv600,{|x| x[1]=EF3->EF3_INVOIC .And. x[2]=EF3->EF3_PARC})
            If nPos > 0
               aInv600[nPos,4] -= EF3->EF3_VL_MOE
               aInv600[nPos,5] -= EF3->EF3_VL_REA
            Endif
         Endif

         // Liquidação Principal ACE - 660  VI 26/07/05
         If EF3->EF3_CODEVE = '660' .And. ((EF3->EF3_DT_EVE >= (dDta_Ini) .And. EF3->EF3_DT_EVE <= (dDta_Fim) .Or. EF3->EF3_DT_EVE < (dDta_Ini)) .Or. !Empty(Val(EF3->EF3_NR_CON)))
            nPos := Ascan(aInv600,{|x| x[1]=EF3->EF3_INVOIC .And. x[2]=EF3->EF3_PARC})
            If nPos > 0
               aInv600[nPos,4] -= EF3->EF3_VL_MOE
               aInv600[nPos,5] -= EF3->EF3_VL_REA
            Endif
         Endif

         IF EF3->EF3_CODEVE = '520'
            cInv  := EF3->EF3_INVOIC
            cParcela := EF3->EF3_PARC
            nRecOld := EF3->(Recno())
            nIndOld := EF3->(INDEXORD())
            EF3->(DBSETORDER(2))
               if EF3->(DBSEEK(cFilEF3+IIF(lEFFTpMod,EF3->EF3_TPMODU,"")+'640'+cInv+cParcela)) // Nick 05/07/06
               if EF3->EF3_VL_REA = 0 .OR. EMPTY(EF3->EF3_DT_EVE)
                  lGrava520 := .F.
               endif
            endif
            EF3->(DBSETORDER(nIndOld))
            EF3->(DBGOTO(nRecOld))
         ENDIF
         
         
         If ((EF3->EF3_DT_EVE >= (dDta_Ini) .And. EF3->EF3_DT_EVE <= dDta_Fim .Or. EF3->EF3_DT_EVE < dDta_Ini) .And. Empty(Val(EF3->EF3_NR_CON))) .OR.;
            (EF3->EF3_CODEVE = '999' .AND. EF3->EF3_DT_EST >= dDta_Ini .And. EF3->EF3_DT_EST <= dDta_Fim .And. Empty(Val(EF3->EF3_NR_CON)))
        
            // Grava no Arquivo de prévia ECA os Eventos gerados no EF3                                                                                                                                                                                                                                                                                                                                  // 24 25
            if !(EF3->EF3_CODEVE = '640' .AND. EF3->EF3_VL_REA = 0) .and. !(EF3->EF3_CODEVE = '520' .AND. !lGrava520) // MJA 24/01/05 para não calcular o evento 640 caso o seu valor em reais seja 0
                         //              1                2               3                4                                       5                                      6                7                8            9             10            11                                    12                                              13        14  15  16  17  18 19 20 21      22               23       24 25         26              27        28         29
               AAdd(aDadosPRV, {EF3->EF3_VL_REA, EF3->EF3_CODEVE, EF3->EF3_CONTRA, EF3->EF3_INVOIC, If(EF3->EF3_CODEVE = '999', EF3->EF3_EV_EST, EF3->EF3_CODEVE), EF3->EF3_DT_EVE, EF1->EF1_MOEDA, EF3->EF3_TX_MOE, nTxUltima, EF3->EF3_PARC, EF1->EF1_CC, If(EF3->EF3_TP_EVE='01','ACC',If(EF3->EF3_TP_EVE='02', 'ACE', 'PRE') ), EF3->EF3_PREEMB, "", "", "", "", "","","", 0,EF3->(Recno()),EF3->EF3_VL_MOE,"","",EF3->EF3_BAN_FI,EF3->EF3_PRACA,cFilEF3,IF(lEFFTpMod,EF3->EF3_SEQCNT,"")})
            ENDIF
            
            If cPrv_Efe = "2"      // Efetivacao
               Reclock("EF3", .F.)
               EF3->EF3_NR_CON := STRZERO(nNR_Cont+1,4,0)
               EF3->(MsUnlock())
            Endif

            If EF3->EF3_CODEVE = '100'  // Contratação de Câmbio

               // Tem Evento 100
               l100Contab := .T.

               // Gera Variaçao do ACC apenas uma vez por sequencia
               lGeraVar := .F.

               //** AAF 02/04/08 - Busca ultima provisão de juros gerada para o pré-pagamento
               If EF1->EF1_CAMTRA == "1"
            
                  nRecAntEF3:=EF3->(RecNo())
                  nOrdAntEF3:=EF3->(IndexOrd())

                  If EF1->EF1_DT_CTB > EF1->EF1_DT_JUR
                     dDtIniProv := EF1->EF1_DT_CTB
                  Else
                     dDtIniProv := EF1->EF1_DT_JUR
                  EndIf      
            
                  EF3->(dbSetOrder(1))
                  EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,"E","")+EF1->(EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+If(lEFFTpMod,EF1_SEQCNT,""))))
            
                  dDtUltPr := CToD("  /  /  ")
                  nUltTxPr := 0
            
                  Do While EF3->(!EOF() .and. EF3_FILIAL+If(lEFFTpMod,EF3_TPMODU,"")+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+If(lEFFTpMod,EF3_SEQCNT,"")==;
                                              xFilial("EF3")+If(lEFFTpMod,"E","")+EF1->(EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+If(lEFFTpMod,EF1_SEQCNT,"")))
                                              
                     If EF3->EF3_DT_EVE<=dDta_Fim .AND. EF3->EF3_CODEVE==Left("520",2)+Alltrim(Str(Val(aJuros[1]))).AND. EF3->EF3_DT_EVE > dDtUltPr
                        dDtUltPr := EF3->EF3_DT_EVE
                        nUltTxPr := EF3->EF3_TX_MOE
                     EndIf
                     EF3->(dbSkip())
                  EndDo

                  EF3->(dbGoTo(nRecAntEF3))
                  EF3->(dbSetOrder(nOrdAntEF3))
            
                  If dDtUltPr >= dDtIniProv
                     nTxUltimaJuros := nUltTxPr
                  Else
                     nTxUltimaJuros := ECOEXP999Tx(EF1->EF1_MOEDA, dDtIniProv, cTX_520)
                  EndIf

                  nVar520Acc := EX401ProvTot("EF1","EF3",dDta_Fim,dDtIniProv,aJuros[1])
               Else
                  For nCont := 1 to Len(aTx_Dia)
                      nVar520Acc += ROUND(((aTx_Dia[nCont,2] * aTx_Dia[nCont,1] * (nSlPri)) / 100),2)
                  Next
               EndIf
               
               // V.C. do Principal - ACC
               nVar500Acc := ((EF3->EF3_VL_MOE-nTotal600EF3) * nTxFimMes) - ((EF3->EF3_VL_MOE-nTotal600EF3) * EF3->EF3_TX_MOE)
               
               // Grava no Arquivo de Prévia - ECA                         
               
	           AAdd(aDadosPRV, {nVar500Acc, If(nVar500Acc > 0, '500', '501'), EF3->EF3_CONTRA, SPACE(LEN(EF3->EF3_INVOIC)), If(nVar500Acc > 0, '500', '501'), dDta_Fim, EF3->EF3_MOE_IN, nTxFimMes, nTxUltima, EF3->EF3_PARC, EF1->EF1_CC, If(EF3->EF3_TP_EVE='01','ACC',If(EF3->EF3_TP_EVE='02', 'ACE', 'PRE') ), SPACE(LEN(EF3->EF3_PREEMB)), "", "", "", "", "","","",0,EF3->(Recno()),EF3->EF3_VL_MOE-nTotal600EF3,"","",EF3->EF3_BAN_FI,EF3->EF3_PRACA,cFilEF3,IF(lEFFTpMod,EF3->EF3_SEQCNT,"")} )
               if lGrava520 // MJA 24/01/05 para não calcular o evento 640 caso o seu valor em reais seja 0
                  AAdd(aDadosPRV, {ROUND((nVar520Acc * nTxFimMesJuros),2), '520', EF3->EF3_CONTRA, SPACE(LEN(EF3->EF3_INVOIC)), '520', dDta_Fim, EF3->EF3_MOE_IN, nTxFimMesJuros, nTxUltimaJuros, EF3->EF3_PARC, EF1->EF1_CC, If(EF3->EF3_TP_EVE='01','ACC',If(EF3->EF3_TP_EVE='02', 'ACE', 'PRE') ), SPACE(LEN(EF3->EF3_PREEMB)), "", "", "", "", "","","",0,EF3->(Recno()),nVar520Acc,"","",EF3->EF3_BAN_FI,EF3->EF3_PRACA,cFilEF3,IF(lEFFTpMod,EF3->EF3_SEQCNT,"")} )
               endif
               
               // Totais
               nT500AccR += nVar500Acc
//             nT520AccR += nVar520Acc * nTxFimMes
               nT520AccR += ROUND((nVar520Acc * nTxFimMesJuros),2)
               nT520AccM += nVar520Acc
               
               // Transfere variações e eventos p/ ECF
               If cPrv_Efe = "2"      // Efetivacao
                  AAdd(aDadosEF3, {nVar500Acc,             EF1->EF1_MOEDA, If(nVar500Acc > 0, '500', '501'), EF3->EF3_INVOIC, EF3->EF3_PARC, EF1->EF1_CONTRA, EF1->EF1_CC, If(nVar500Acc > 0, '500', '501'), dDta_Fim, cSeqAtual, 'CO', EF3->EF3_VL_MOE-nTotal600EF3, nTxFimMes, nTxUltima, If(EF3->EF3_TP_EVE='01','ACC',If(EF3->EF3_TP_EVE='02', 'ACE', 'PRE') ), SPACE(LEN(EF3->EF3_PREEMB)),EF1->EF1_BAN_FI,EF1->EF1_PRACA,EF1->EF1_AGENFI,EF1->EF1_NCONFI,IF(lEFFTpMod,EF1->EF1_SEQCNT,"")} )
//                AAdd(aDadosEF3, {nVar520Acc * nTxFimMes, EF1->EF1_MOEDA, '520', EF3->EF3_INVOIC, EF3->EF3_PARC, EF1->EF1_CONTRA, EF1->EF1_CC, '520', dDta_Fim, cSeqAtual, 'CO', nVar520Acc, nTxFimMes, nTxUltima, 'ACC', SPACE(LEN(EF3->EF3_PREEMB))} )
                  if lGrava520
                     AAdd(aDadosEF3, {ROUND((nVar520Acc * nTxFimMesJuros),2), EF1->EF1_MOEDA, '520', EF3->EF3_INVOIC, EF3->EF3_PARC, EF1->EF1_CONTRA, EF1->EF1_CC, '520', dDta_Fim, cSeqAtual, 'CO', nVar520Acc, nTxFimMesJuros, nTxUltimaJuros, If(EF3->EF3_TP_EVE='01','ACC',If(EF3->EF3_TP_EVE='02', 'ACE', 'PRE') ), SPACE(LEN(EF3->EF3_PREEMB)),EF1->EF1_BAN_FI,EF1->EF1_PRACA,EF1->EF1_AGENFI,EF1->EF1_NCONFI,IF(lEFFTpMod,EF1->EF1_SEQCNT,"")} )
                  endif   
               Endif
            Endif

            // V.C. ACC Principal Acumulada Até o embarque - 500
            If EF3->EF3_CODEVE = '500'     // VICTOR ? NÃO DEVERIA TER 501 TAMBEM ?
			      nTotVarACC += EF3->EF3_VL_REA
            Endif

            // Emb.Transf. Principal ACC/ACE - 600 (Acumula apenas os totais do periodo)
            If EF3->EF3_CODEVE = '600'
			      nT600AceM += EF3->EF3_VL_MOE
			      nT600AceR += EF3->EF3_VL_REA
            Endif

            // Transf. de Juros ACC/ACE - 650
            If EF3->EF3_CODEVE = '650'
			      AAdd(aInv650, {EF3->EF3_INVOIC, EF3->EF3_DT_EVE, EF3->EF3_VL_MOE, EF3->EF3_VL_REA, EF3->EF3_PARC, EF3->EF3_TX_MOE, EF3->EF3_PREEMB} )
            Endif
         Endif

         EF3->(DbSkip())
      Enddo 

      // Gera Variação Cambial do ACC e Grava na PREVIA / ECF
      If (!(EF1->EF1_CAMTRA == "1") .AND. lEvento100 ) .OR. (EF1->EF1_CAMTRA == "1" .AND. Empty(cInvoice+cParc) .AND. !l100Contab);
      .And. nSlPri <> 0 .And. (EF3->EF3_PARC <> cParc .Or. EF3->(Eof()) .OR. EF1->EF1_CONTRA <> EF3->EF3_CONTRA) .And. ((!l100Contab .And. (lGeraVar .Or. lAccAce)) .Or. (!lGeraVar .And. !lAccAce))

         // Geração de V.C.
         lGeraVar := .F.

         // V.C. do Principal
		 nVar500Acc := (((nSlPri)*nTxFimMes) - ((nSlPri)*nTxUltima)) + nTotVarACC

         If EF1->EF1_CAMTRA == "1"                
            nRecAntEF3:=EF3->(RecNo())
            nOrdAntEF3:=EF3->(IndexOrd())

            If EF1->EF1_DT_CTB > EF1->EF1_DT_JUR
               dDtIniProv := EF1->EF1_DT_CTB
            Else
               dDtIniProv := EF1->EF1_DT_JUR
            EndIf      
            
            EF3->(dbSetOrder(1))
            EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,"E","")+EF1->(EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+If(lEFFTpMod,EF1_SEQCNT,""))))
            
            dDtUltPr := CToD("  /  /  ")
            nUltTxPr := 0
            //LRS - 07/04/2017
            Do While EF3->(!EOF()) .and.  EF3->(EF3_FILIAL+If(lEFFTpMod,EF3_TPMODU,"")+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+If(lEFFTpMod,EF3_SEQCNT,""))==;
                                        xFilial("EF3")+If(lEFFTpMod,"E","")+EF1->(EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+If(lEFFTpMod,EF1_SEQCNT,""))
                                              
               If EF3->EF3_DT_EVE<=dDta_Fim .AND. EF3->EF3_CODEVE==Left("520",2)+Alltrim(Str(Val(aJuros[1]))).AND. EF3->EF3_DT_EVE > dDtUltPr
                  dDtUltPr := EF3->EF3_DT_EVE
                  nUltTxPr := EF3->EF3_TX_MOE
               EndIf
               EF3->(dbSkip())
            EndDo

            EF3->(dbGoTo(nRecAntEF3))
            EF3->(dbSetOrder(nOrdAntEF3))               
               
            If dDtUltPr >= dDtIniProv
               nTxUltimaJuros := nUltTxPr
               dDtIniProv     := dDtUltPr
            Else
               nTxUltimaJuros := ECOEXP999Tx(EF1->EF1_MOEDA, dDtIniProv, cTX_520)
            EndIf
               
            nVar520Acc := EX401ProvTot("EF1","EF3",dDta_Fim,dDtIniProv,aJuros[1])
         Else
            // Provisão de Juros - ACC
            For nCont := 1 to Len(aTx_Dia)
               nVar520Acc += ROUND((((aTx_Dia[nCont,2]) * aTx_Dia[nCont,1] * (nSlPri)) / 100),2)
            Next         
         EndIf

         // V.C. Provisão de Juros - ACC
         If !lAccAce              // Antes ou depois da transferência ACC/ACE
            nVar550Acc := ROUND((nSlJur * nTxFimMesJuros),2) - ROUND((If(!lGeraVar .And. !lAccAce .And. l600Contab, (nSlJur * nTxUltimaJuros), EF1->EF1_SLD_JR)),2)
            nVal550Moe := nSlJur

         Else                     // No momento da transferência ACC/ACE
            If EF1->EF1_CAMTRA == "1"                
               nVal550Moe := 0
               
               nVal550Moe := EX401ProvTot("EF1","EF3",dDta_Fim,,Alltrim(Str(Val(aJuros[1]))))
               nVal550Moe -= nVar520Acc
               
               nVar550Acc := Round(nVal550Moe * (nTxFimMesJuros - nTxUltimaJuros),2)
            Else
               nVal550Moe := 0
               For nCont := 1 to Len(aTx_Ctb)
                   nVal550Moe += ROUND((((aTx_Ctb[nCont,2]) * aTx_Ctb[nCont,1] * (nSlPri)) / 100),2)
/*                nVar550Acc += ((nSlPri) * (aTx_Dia[nCont,1]/100) * nTxFimMesJuros * ;
                               (EF1->EF1_DT_CTB - EF1->EF1_DT_JUR)) - ((nSlPri) * ;
                               (aTx_Dia[nCont,1]/100) * nTxUltimaJuros * (EF1->EF1_DT_CTB - EF1->EF1_DT_JUR))*/

               Next
               nVar550Acc := ROUND((nVal550Moe * nTxFimMesJuros),2) - ROUND((nVal550Moe * nTxUltimaJuros),2)
            Endif
         EndIf
         
         // Grava no Arquivo de Prévia - ECA
//       AAdd(aDadosPRV, {nVar500Acc            , If(nVar500Acc > 0, '500', '501'), EF1->EF1_CONTRA, SPACE(LEN(EF3->EF3_INVOIC)), If(nVar500Acc > 0, '500', '501'), dDta_Fim, EF1->EF1_MOEDA, nTxFimMes, nTxUltima, cParc, EF1->EF1_CC, If(EF1->EF1_TP_FIN='01','ACC',If(EF1->EF1_TP_FIN='02', 'ACE', 'PRE') ), SPACE(LEN(EF3->EF3_PREEMB)), "", "", "", "", "", "","",0,EF3->(Recno()),EF3->EF3_VL_MOE,"","",EF1->EF1_BAN_FI,EF1->EF1_PRACA,cFilEF1} ) vi/22/12/05
         AAdd(aDadosPRV, {nVar500Acc            , If(nVar500Acc > 0, '500', '501'), EF1->EF1_CONTRA, SPACE(LEN(EF3->EF3_INVOIC)), If(nVar500Acc > 0, '500', '501'), dDta_Fim, EF1->EF1_MOEDA, nTxFimMes, nTxUltima, cParc, EF1->EF1_CC, If(EF1->EF1_TP_FIN='01','ACC',If(EF1->EF1_TP_FIN='02', 'ACE', 'PRE') ), SPACE(LEN(EF3->EF3_PREEMB)), "", "", "", "", "", "","",0,0,nSlPri,"","",EF1->EF1_BAN_FI,EF1->EF1_PRACA,cFilEF1,IF(lEFFTpMod,EF1->EF1_SEQCNT,"")} )
         if lGrava520
//          AAdd(aDadosPRV, {nVar520Acc * nTxFimMesJuros, '520', EF1->EF1_CONTRA, SPACE(LEN(EF3->EF3_INVOIC)), '520', dDta_Fim, EF1->EF1_MOEDA, nTxFimMesJuros, nTxUltimaJuros, cParc, EF1->EF1_CC, If(EF1->EF1_TP_FIN='01','ACC',If(EF1->EF1_TP_FIN='02', 'ACE', 'PRE') ), SPACE(LEN(EF3->EF3_PREEMB)), "", "", "", "", "", "","",0,EF3->(Recno()),EF3->EF3_VL_MOE,"","",EF1->EF1_BAN_FI,EF1->EF1_PRACA,cFilEF1} ) vi/22/12/05
            AAdd(aDadosPRV, {ROUND((nVar520Acc * nTxFimMesJuros),2), '520', EF1->EF1_CONTRA, SPACE(LEN(EF3->EF3_INVOIC)), '520', dDta_Fim, EF1->EF1_MOEDA, nTxFimMesJuros, nTxUltimaJuros, cParc, EF1->EF1_CC, If(EF1->EF1_TP_FIN='01','ACC',If(EF1->EF1_TP_FIN='02', 'ACE', 'PRE') ), SPACE(LEN(EF3->EF3_PREEMB)), "", "", "", "", "", "","",0,0,nVar520Acc,"","",EF1->EF1_BAN_FI,EF1->EF1_PRACA,cFilEF1,IF(lEFFTpMod,EF1->EF1_SEQCNT,"")} )
         endif   
//       AAdd(aDadosPRV, {nVar550Acc            , If(nVar550Acc > 0, '550', '551'), EF1->EF1_CONTRA, SPACE(LEN(EF3->EF3_INVOIC)), If(nVar550Acc > 0, '550', '551'), dDta_Fim, EF1->EF1_MOEDA, nTxFimMesJuros, nTxUltimaJuros, cParc, EF1->EF1_CC, If(EF1->EF1_TP_FIN='01','ACC',If(EF1->EF1_TP_FIN='02', 'ACE', 'PRE') ), SPACE(LEN(EF3->EF3_PREEMB)), "", "", "", "", "", "","",0,EF3->(Recno()),EF3->EF3_VL_MOE,"","",EF1->EF1_BAN_FI,EF1->EF1_PRACA,cFilEF1} ) vi/22/12/05
         AAdd(aDadosPRV, {ROUND(nVar550Acc,2)   , If(nVar550Acc > 0, '550', '551'), EF1->EF1_CONTRA, SPACE(LEN(EF3->EF3_INVOIC)), If(nVar550Acc > 0, '550', '551'), dDta_Fim, EF1->EF1_MOEDA, nTxFimMesJuros, nTxUltimaJuros, cParc, EF1->EF1_CC, If(EF1->EF1_TP_FIN='01','ACC',If(EF1->EF1_TP_FIN='02', 'ACE', 'PRE') ), SPACE(LEN(EF3->EF3_PREEMB)), "", "", "", "", "", "","",0,0,nVal550Moe,"","",EF1->EF1_BAN_FI,EF1->EF1_PRACA,cFilEF1,IF(lEFFTpMod,EF1->EF1_SEQCNT,"")} ) 

         If cPrv_Efe = "2"
            // Transfere as variacoes - ACC geradas para o ECF
            AAdd(aDadosEF3, {nVar500Acc,             EF1->EF1_MOEDA, If(nVar500Acc > 0, '500', '501'), SPACE(LEN(EF3->EF3_INVOIC)), cParc, EF1->EF1_CONTRA, EF1->EF1_CC, If(nVar500Acc > 0, '500', '501'), dDta_Fim, cSeqAtual, 'CO', nVar500Acc, nTxFimMes, nTxUltima, If(EF1->EF1_TP_FIN='01','ACC',If(EF1->EF1_TP_FIN='02', 'ACE', 'PRE') ), SPACE(LEN(EF3->EF3_PREEMB)),EF1->EF1_BAN_FI,EF1->EF1_PRACA,EF1->EF1_AGENFI,EF1->EF1_NCONFI,IF(lEFFTpMod,EF1->EF1_SEQCNT,"")} )
            AAdd(aDadosEF3, {ROUND((nVar520Acc * nTxFimMesJuros),2), EF1->EF1_MOEDA, '520', SPACE(LEN(EF3->EF3_INVOIC)), cParc, EF1->EF1_CONTRA, EF1->EF1_CC, '520', dDta_Fim, cSeqAtual, 'CO', nVar520Acc, nTxFimMesJuros, nTxUltimaJuros, If(EF1->EF1_TP_FIN='01','ACC',If(EF1->EF1_TP_FIN='02', 'ACE', 'PRE') ), SPACE(LEN(EF3->EF3_PREEMB)),EF1->EF1_BAN_FI,EF1->EF1_PRACA,EF1->EF1_AGENFI,EF1->EF1_NCONFI,IF(lEFFTpMod,EF1->EF1_SEQCNT,"")} )
            AAdd(aDadosEF3, {nVar550Acc            , EF1->EF1_MOEDA, If(nVar550Acc > 0, '550', '551'), SPACE(LEN(EF3->EF3_INVOIC)), cParc, EF1->EF1_CONTRA, EF1->EF1_CC, If(nVar550Acc > 0, '550', '551'), dDta_Fim, cSeqAtual, 'CO', nVar550Acc, nTxFimMesJuros, nTxUltimaJuros, If(EF1->EF1_TP_FIN='01','ACC',If(EF1->EF1_TP_FIN='02', 'ACE', 'PRE') ), SPACE(LEN(EF3->EF3_PREEMB)),EF1->EF1_BAN_FI,EF1->EF1_PRACA,EF1->EF1_AGENFI,EF1->EF1_NCONFI,IF(lEFFTpMod,EF1->EF1_SEQCNT,"")} )
         Endif

         // Acumula Totais das Variações
         nT500AccR += nVar500Acc
         nT520AccR += ROUND((nVar520Acc * nTxFimMesJuros),2)
         nT550AccR += ROUND(nVar550Acc,2)
         nT520AccM += nVar520Acc
      Endif    
      

      // Geração da Variação Cambial ACE para Invoices que possuem evento 600 (Emb.Transf. Principal ACC/ACE) no período
      For nInd := 1 to Len(aInv600)

        nVar500Ace := 0
        nVar520Ace := 0
        nVar550Ace := 0
        nVarEmbVin := 0
        
        cInvoice:= aInv600[nInd,1]
        cParc   := aInv600[nInd,2]
        dDtEve  := aInv600[nInd,3]
        nVlMoe  := aInv600[nInd,4]
        nVlRea  := aInv600[nInd,5]
        cSeq    := aInv600[nInd,6]
        nTxMoe  := aInv600[nInd,7]
        cProc   := aInv600[nInd,8]
        nNrCont := aInv600[nInd,9]
        nTxMoeJuros := ECOEXP999Tx(aInv600[nInd,10], dDtEve, cTX_520)
        nVl600  := aInv600[nInd,11]  // VI 16/10/03
                                  
        If nVl600 <> 0 .and. Val(nNrCont) = 0 // Todo o IF, VI 16/10/03
           // V.C. Dt.Embarque ate Dt.Vinculacao da Invoice
           EEC->(DbSeek(cFilEEC+cProc))          
                     
           IF (EEC->EEC_DTEMBA >= dDta_Ini .And. EEC->EEC_DTEMBA <= dDta_Fim) .or. ! (ECG->(DbSeek(cFilECG+cTPMODU+'EX'+cProc))) // VI 19/11/03
              nTxEmb := ECOEXP999Tx(EEC->EEC_MOEDA, EEC->EEC_DTEMBA, cTX_101)
           ElseIf ECG->(DbSeek(cFilECG+cTPMODU+'EX'+cProc)) // EEQ->EEQ_PREEMB  VI 25/07/03
              nTxEmb := ECG->ECG_ULT_TX   
           Else
              nTxEmb := ECOEXP999Tx(EEC->EEC_MOEDA, dDta_Ini-1, cTX_101)
           EndIf
           nVarEmbVin := (nVl600 * nTxMoe) - (nVl600 * nTxEmb)
/*           If nVarEmbVin <> 0 .AND. !lVcAv   // MJA 19/08/04  -> Foi colocado o lVcAv para naum calcular a VC do periodo da Invoice até a Vinculação
              AAdd(aDadosPRV, {nVarEmbVin, If(nVarEmbVin > 0, '582', '583'), "", cInvoice, If(nVarEmbVin > 0, '582', '583'), dDtEve, EF1->EF1_MOEDA, nTxMoe, nTxEmb, cParc, "", 'VC', cProc, "", "", "", "", "", "","",0,0,nVl600,EEC->EEC_IMPORT,'1',"","",cFilEEC})
           EndIf
*/          // Retirou-se a validação para não contabilizar VC zerada MJA 24/08/05
           If !lVcAv   // MJA 19/08/04  -> Foi colocado o lVcAv para naum calcular a VC do periodo da Invoice até a Vinculação
              AAdd(aDadosPRV, {nVarEmbVin, If(nVarEmbVin > 0, '582', '583'), "", cInvoice, If(nVarEmbVin > 0, '582', '583'), dDtEve, EF1->EF1_MOEDA, nTxMoe, nTxEmb, cParc, "", 'VC', cProc, "", "", "", "", "", "","",0,0,nVl600,EEC->EEC_IMPORT,'1',"","",cFilEEC,IF(lEFFTpMod,EF1->EF1_SEQCNT,"")})
           EndIf
           
        EndIf
        
        If nVlMoe <> 0 .AND. EF1->EF1_TP_FIN # '03' .AND. EF1->EF1_TP_FIN # '04' 
           
           If Empty(Val(nNrCont))    // Gera V.C para o Embarque (600) no Periodo
              If EF1->EF1_TP_FIN == "02"  .And.  dDtEve < EF1->EF1_DT_JUR  // PLB 02/07/07 - Trata Vinculacao ACE
                 aTx_DiaAux := EX400BusTx(EF1->EF1_TP_FIN, dDta_Fim, EF1->EF1_DT_JUR-nDiasJur, "EF1", "EF2",aJuros[1])
              Else
                 aTx_DiaAux := EX400BusTx(EF1->EF1_TP_FIN, dDta_Fim, dDtEve, "EF1", "EF2",aJuros[1])  // VI
              EndIf
              aTx_CtbAux := EX400BusTx(EF1->EF1_TP_FIN, dDtEve, EF1->EF1_DT_JUR-nDiasJur, "EF1", "EF2",aJuros[1])  // VI              
/*              For x:=1 to Len(aTx_DiaAux)             // MJA 04/08/05 Foi retirado apos conversa com a Rita
                  if x = Len(aTx_DiaAux)
                     aTx_DiaAux[x,2] := aTx_DiaAux[x,2] + 1 // Sempre soma-se mais um no ultimo parametro do aTaxa para trazer o numero de dias correto para o contabil MJA 23/07/05
                  endif
              Next     */
              
              If dDtEve >= dDta_Ini .And. dDtEve <= dDta_Fim
                 // V.C. do Principal ACE
                 If EF1->EF1_TP_FIN == "02"  .And.  dDtEve < EF1->EF1_DT_JUR  // PLB 02/07/07 - Trata Vinculacao ACE
                    nVar500Ace := ((nVlMoe * nTxFimMes) - (nVlMoe * nTxUltima))
                    nT500AceR  += (ROUND(nVlMoe * nTxFimMes,2) - ROUND(nVlMoe * nTxUltima,2))
                 Else
                    nVar500Ace := ((nVlMoe * nTxFimMes) - (nVlMoe * nTxMoe))
                    nT500AceR  += (ROUND(nVlMoe * nTxFimMes,2) - ROUND(nVlMoe * nTxMoe,2))
                 EndIf

                 // Provisão de Juros ACE
                 For nCont := 1 to Len(aTx_DiaAux)
                     nVar520Ace += ROUND((((nVlMoe * aTx_DiaAux[nCont,1]) * aTx_DiaAux[nCont,2]) / 100),2)
	     	   	      nT520AceM  += ROUND((((nVlMoe * aTx_DiaAux[nCont,1]) * aTx_DiaAux[nCont,2]) / 100),2)
   			         nT520AceR  += ROUND((ROUND(((nVlMoe * aTx_DiaAux[nCont,1] * aTx_DiaAux[nCont,2]) / 100),2) * nTxFimMesJuros),2)
                 Next
             
                 // V.C. Provisão de Juros ACE
                 If Len(aInv650) > 0
                    nPos := Ascan(aInv650,{|x| x[1]=cInvoice .And. x[5]=cParc})
                    If nPos > 0
//                     VI 28/07/05
//                     nVar550Ace := (aInv650[nPos,3] * nTxFimMesJuros) - (aInv650[nPos,3] * aInv650[nPos,6])
// 	                 nT550AceR  += (aInv650[nPos,3] * nTxFimMesJuros) - (aInv650[nPos,3] * aInv650[nPos,6])
                       nVal550Moe := 0
                       For nCont := 1 to Len(aTx_CtbAux)
                           //nVal550Moe += ROUND((((nVlMoe * aTx_CtbAux[nCont,1]) * aTx_CtbAux[nCont,2]) / 100),2)
                           //** PLB 02/07/07
                           nValAux := ROUND((((nVlMoe * aTx_CtbAux[nCont,1]) * aTx_CtbAux[nCont,2]) / 100),2)
                           If nValAux > 0
                              nVal550Moe += nValAux
                           EndIf
                           //**
                       Next
                       nVar550Ace := ROUND((nVal550Moe * nTxFimMesJuros),2) - ROUND((nVal550Moe * aInv650[nPos,6]),2)
   	                 nT550AceR  += ROUND((nVal550Moe * nTxFimMesJuros),2) - ROUND((nVal550Moe * aInv650[nPos,6]),2)
   	                 nDesagio := nVal550Moe // vi 08/12/05
                    Endif

                 Elseif !lEvento100  // Caso nao tenha havido liquidação no período ou o embarque tenha ocorrido no mesmo periodo do contrato

                    // Taxa dos dias p/ calculo da provisão de juros
                    aTx_Cont  := EX400BusTx(EF1->EF1_TP_FIN, dDtEve, dDtEve100, "EF1", "EF2",aJuros[1])
/*                    For x:=1 to Len(aTx_Cont)             // MJA 04/08/05 Foi retirado apos conversa com a Rita
                        if x = Len(aTx_Cont) .AND. !(StrZero(Month(dDtEve),2)+StrZero(Year(dDtEve),4) = cMesProc)
                           aTx_Cont[x,2] := aTx_Cont[x,2] + 1 // Sempre soma-se mais um no ultimo parametro do aTaxa para trazer o numero de dias correto para o contabil MJA 23/07/05
                        endif
                    Next     */
                    
            
                    For nCont := 1 to Len(aTx_Cont)
                        nDesagio   := ROUND(((nVlMoe * (aTx_Cont[nCont,1] * aTx_Cont[nCont,2])) / 100),2)
                        nVar550Ace += ROUND((nDesagio * nTxFimMesJuros),2) - ROUND((nDesagio * nTxMoeJuros),2)
   	                  nT550AceR  += ROUND((nDesagio * nTxFimMesJuros),2) - ROUND((nDesagio * nTxMoeJuros),2)
   	              Next
                 Endif
              Endif   

           Elseif !Empty(Val(nNrCont)) .And. nSlACE <> 0  // Gera V.C p/ Embarque (600) que não seja do periodo e ja tenha sido contabilizado

              // V.C. do Principal ACE
              nVar500Ace := (nVlMoe * nTxFimMes) - (nVlMoe * nTxUltima)
              nT500AceR  += (nVlMoe * nTxFimMes) - (nVlMoe * nTxUltima)

              // Provisão de Juros ACE
              For nCont := 1 to Len(aTx_Dia)
                  nVar520Ace += ROUND((nVlMoe * (aTx_Dia[nCont,1]/100) * aTx_Dia[nCont,2]),2)
                  nT520AceM  += ROUND((nVlMoe * (aTx_Dia[nCont,1]/100) * aTx_Dia[nCont,2]),2)
                  nT520AceR  += ROUND((ROUND((nVlMoe * aTx_Dia[nCont,1] * aTx_Dia[nCont,2] / 100),2) * nTxFimMesJuros),2)
              Next

              // V.C. Provisão de Juros ACE
//              nVar550Ace := (nTotSldJM * nTxFimMesJuros) - (nTotSldJM * nTxUltimaJuros)
//              nT550AceR  += (nTotSldJM * nTxFimMesJuros) - (nTotSldJM * nTxUltimaJuros)              
//VI 08/12/05 nVar550Ace := (nVar520Ace * nTxFimMesJuros) - (nVar520Ace * nTxUltimaJuros) // MJA 19/08/05
//VI 08/12/05 nT550AceR  += (nVar520Ace * nTxFimMesJuros) - (nVar520Ace * nTxUltimaJuros) // MJA 19/08/05              

              aTx_Cont  := EX400BusTx(EF1->EF1_TP_FIN, EF1->EF1_DT_CTB, EF1->EF1_DT_JUR-nDiasJur, "EF1", "EF2",aJuros[1])  // VI 08/12/05
              For nCont := 1 to Len(aTx_Cont)
                  nDesagio   := ROUND(((nVlMoe * (aTx_Cont[nCont,1] * aTx_Cont[nCont,2])) / 100),2)
                  nVar550Ace += ROUND(((nDesagio * nTxFimMesJuros) - (nDesagio * nTxUltimaJuros)),2)
                  nT550AceR  += ROUND(((nDesagio * nTxFimMesJuros) - (nDesagio * nTxUltimaJuros)),2)
              Next

           Endif

           // Grava no Arquivo de Prévia - ECA
           AAdd(aDadosPRV, {nVar500Ace            , If(nVar500Ace > 0, '500', '501'), EF1->EF1_CONTRA, cInvoice, If(nVar500Ace > 0, '500', '501'), dDta_Fim, EF1->EF1_MOEDA, nTxFimMes, nTxUltima, cParc, EF1->EF1_CC, 'ACE', cProc, "", "", "", "", "", "","",0,0,nVlMoe,"","",EF1->EF1_BAN_FI,EF1->EF1_PRACA,cFilEF1,IF(lEFFTpMod,EF1->EF1_SEQCNT,"")})
           if lGrava520
              AAdd(aDadosPRV, {ROUND((nVar520Ace * nTxFimMesJuros),2), '520', EF1->EF1_CONTRA, cInvoice, '520', dDta_Fim, EF1->EF1_MOEDA, nTxFimMesJuros, nTxUltimaJuros, cParc, EF1->EF1_CC, 'ACE', cProc, "", "", "", "", "", "","",0,0,nVar520Ace,"","",EF1->EF1_BAN_FI,EF1->EF1_PRACA,cFilEF1,IF(lEFFTpMod,EF1->EF1_SEQCNT,"")})
           endif   
//           AAdd(aDadosPRV, {nVar550Ace            , If(nVar550Ace > 0, '550', '551'), EF1->EF1_CONTRA, cInvoice, If(nVar550Ace > 0, '550', '551'), dDta_Fim, EF1->EF1_MOEDA, nTxFimMesJuros, nTxUltimaJuros, cParc, EF1->EF1_CC, 'ACE', cProc, "", "", "", "", "", "","",0,0,nTotSldJM,"","",EF1->EF1_BAN_FI,EF1->EF1_PRACA,cFilEF1})
           AAdd(aDadosPRV, {nVar550Ace            , If(nVar550Ace > 0, '550', '551'), EF1->EF1_CONTRA, cInvoice, If(nVar550Ace > 0, '550', '551'), dDta_Fim, EF1->EF1_MOEDA, nTxFimMesJuros, nTxUltimaJuros, cParc, EF1->EF1_CC, 'ACE', cProc, "", "", "", "", "", "","",0,0,nDesagio,"","",EF1->EF1_BAN_FI,EF1->EF1_PRACA,cFilEF1,IF(lEFFTpMod,EF1->EF1_SEQCNT,"")}) // vi 08/12/05
           If cPrv_Efe = "2"   // Transfere as variacoes geradas para o ECF
              AAdd(aDadosEF3, {nVar500Ace            , EF1->EF1_MOEDA, If(nVar500Ace > 0, '500', '501'), cInvoice, cParc, EF1->EF1_CONTRA, EF1->EF1_CC, If(nVar500Ace > 0, '500', '501'), dDta_Fim, cSeqAtual, 'CO', nVar500Ace, nTxFimMes, nTxUltima, 'ACE', cProc,EF1->EF1_BAN_FI,EF1->EF1_PRACA,EF1->EF1_AGENFI,EF1->EF1_NCONFI,IF(lEFFTpMod,EF1->EF1_SEQCNT,"")} )
              if lGrava520
                 AAdd(aDadosEF3, {ROUND((nVar520Ace * nTxFimMesJuros),2), EF1->EF1_MOEDA, '520', cInvoice, cParc, EF1->EF1_CONTRA, EF1->EF1_CC, '520', dDta_Fim, cSeqAtual, 'CO', nVar520Ace, nTxFimMesJuros, nTxUltimaJuros, 'ACE', cProc,EF1->EF1_BAN_FI,EF1->EF1_PRACA,EF1->EF1_AGENFI,EF1->EF1_NCONFI,IF(lEFFTpMod,EF1->EF1_SEQCNT,"")} )
              endif   
              AAdd(aDadosEF3, {nVar550Ace            , EF1->EF1_MOEDA, If(nVar550Ace > 0, '550', '551'), cInvoice, cParc, EF1->EF1_CONTRA, EF1->EF1_CC, If(nVar550Ace > 0, '550', '551'), dDta_Fim, cSeqAtual, 'CO', nVar550Ace, nTxFimMesJuros, nTxUltimaJuros, 'ACE', cProc,EF1->EF1_BAN_FI,EF1->EF1_PRACA,EF1->EF1_AGENFI,EF1->EF1_NCONFI,IF(lEFFTpMod,EF1->EF1_SEQCNT,"")} )
           Endif
        Endif  
      Next
   Enddo

   // Grava as Variacoes e eventos na prévia, ja rateando se necessario
   If Len(aDadosPRV) > 0
	  PExp999_PrvRat(aDadosPRV)
   Endif

   If cPrv_Efe = "2"
      If Len(aDadosEF3) > 0
    	 PF999_EF3Rat(aDadosEF3)    // Grava as Variacoes geradas no ECF, ja rateando se necessario
      Endif
      // Gravar os saldos no EF1 referentes ao ACC qdo for efetivação
      Reclock("EF1", .F.)

      // ACC
      EF1->EF1_SLD_PR += nT500AccR          		    // Sld. Principal em Reais = Sld.Principal + V.C.
      EF1->EF1_SLD_JM += nT520AccM                      // Sld. Juros ACC na Moeda = Sld.Anterior + Juros
      EF1->EF1_SLD_JR += ROUND((nT520AccR+nT550AccR),2)            // Sld. Juros ACC em Reais = Sld.Anterior + Juros

      // ACE
      EF1->EF1_SL2_PR += nT500AceR		                // Sld. Principal em Reais = Sld.Principal + V.C.
      EF1->EF1_SL2_JM += nT520AceM                      // Sld. Juros ACE na Moeda = Sld.Anterior + Prov.Juros
      EF1->EF1_SL2_JR += ROUND(nT520AceR,2)+ROUND(nT550AceR,2)            // Sld. Juros ACE em Reais = Sld.Anterior + Juros

      // Última taxa de contabilização do contrato
      //nTxUltima := EF1->EF1_TX_CTB
      // ** PLB 13/06/07
      If Empty(EF1->EF1_DT_CTB)  .Or.  !lIsContab
         nTxUltima := BuscaTaxa(EF1->EF1_MOEDA,EF1->EF1_DT_JUR,,.F.,.T.,,cTX_100)
      Else
         nTxUltima := EF1->EF1_TX_CTB
      EndIf
      // **

      // Grava taxa e data da contabilização anterior para que seja usado na hora do estorno
      // PLB 13/06/07 - Incluida verificacao para que seja mantido o legado. Antes o campo EF1_DT_CTB já vinha preenchido com EF1_DT_JUR
      //                Porém eles poderiam ser iguais mas sem identificar que o Contrato houvesse sido contabilizado
      If !Empty(EF1->EF1_DT_CTB)  .And.  EF1->EF1_DT_CTB <> dDta_Fim  
         EF1->EF1_TX_ANT := EF1->EF1_TX_CTB                // Ultima taxa de contabilizacao anterior (ultimo dia do mes)
         EF1->EF1_DT_ANT := EF1->EF1_DT_CTB                // Ultima data da contabilizacao anterior
      EndIf

      // Grava taxa e data da contabilização atual
      EF1->EF1_TX_CTB := nTxFimMes  // Ultima taxa de contabilizacao (ultimo dia do mes)
      EF1->EF1_DT_CTB := dDta_Fim   // Ultima data da contabilizacao

	  EF1->(MsUnlock())
   Endif

   EF1->(DbSkip())
Enddo   

Return .T.
*---------------------*
Function PREXP999Proc(lEnd)
*---------------------*
Local nIndexAtu, nRecnoEEQ
Local nTxFimMes := 0, nTxIniMes := 0, nTxDiaLiq := 0, nTxNF := 0, nTxMesAnt := 0, nTxEmb := 0
Local lVencMes  := .F., lTemEmbPer := .F., lCalcNF := .T.
Local aRecebe := {}, aNF := {}, aBaixa := {}, aCC := {}, lMes := .F., aProcessos := {}, aProcDesp := {} , aInvComis := {}, aRecProc := {}
Local dDta_FimAux, dDta_IniAux, dDta_Emb
Local cProcesso, cParcela, cInvoice, cMoeda, cFase, cProcAnt := "", dDataLiq
Local nVlTransf := 0, nVariacao := 0, nVCTransf := 0
Local nPos := 0, nTotNF := 0, nDifer := 0
Local cProcOr, cFaseOr, cParcOr, cInvOr
Local nValorBx := 0, nVc101 := 0, nPagCli := 0, nDesconto := 0, nTotEEQ := 0, nTotECF := 0
Local cParc101, cProc101, cFase101, cIdentc101, i, nTpNrCont, x 
Local n101ECF := 0
Local nTotAdiant := 0 // Nick 24/04/2006
Local lGerar101 := .t. // Nick 30/09/06
Local lRetPE  := .F.
Private cSYSLoja := ""  // GFP - 09/11/2011
Private nResFinal := 0

Private aDadosPRV := {}
Private lGravou101 := .f.
Private cTipSYS := "H"
Private iVC
SYS->(DbSetOrder(2))
EF3->(DbSetOrder(3))
EC6->(DbSetOrder(6))
EEQ->(DbSetOrder(1))
EEC->(DbSetOrder(1))
SA1->(DbSetOrder(1))
SA2->(DbSetOrder(1))
SA6->(DbSetOrder(1))
EE7->(DbSetOrder(1))
If lTemECFNew .And. lTemECGNew .And. lTemECANew
   ECF->(DbSetOrder(9))
   ECG->(DbSetOrder(4))
   ECA->(DbSetOrder(11))
Endif
aVCProcTotal:={} // VI 27/07/05
EEQ->(DbSetOrder(8))
oProcess:SetRegua2(nTotEEQ1)
            
For nTpNrCont := 1 to 2                                                              // MJA 17/02/05 Para tratar quando tiver cambio alterado.
   if nTpNrCont = 1                                                                   // Foi feita essa alteração para que se contabilizasse todos os registros ainda não contabilizados
      EEQ->(DbSeek(cFilEEQ+Space(Len(EEQ->EEQ_NR_CON)),.T.))                         // e para recalcular os registros que sofreram alteração no câmbio da exportação.
      bCondicao := {|| Empty(EEQ->EEQ_NR_CON)}                                      // Por isso que no segundo loop do FOR busca apenas por EEQ_NR_CON vazio
    else                                                                             // 
      EEQ->(DbSeek(cFilEEQ+Replicate("X",AVSX3("EEQ_NR_CON",3,"EEQ")),.T.))          //
      bCondicao := {|| EEQ->EEQ_NR_CON = Replicate("X",AVSX3("EEQ_NR_CON",3,"EEQ"))} //
   endif                                                                             //
	Do While EEQ->(!EOF()) .And. EEQ->EEQ_FILIAL == cFilEEQ .And. Eval(bCondicao)
       
       //ER - 23/01/2007
       If EasyEntryPoint("ECOPF999")
          lRetPE := ExecBlock("ECOPF999",.F.,.F.,"READEEQ")
          If ValType(lRetPE) == "L" .and. lRetPE
             EEQ->(DbSkip())
             Loop   
          EndIf
       EndIf
  
	   if EEQ->EEQ_EVENT $ cMV_EVEEXCL // VI 13/12/05
	      EEQ->(DBSKIP())
	      LOOP
	   ENDIF             
 
	   IF lEFFTPMOD  // Testa se tem os campos do Financiamento Nick 04/09/06
	      IF EEQ->EEQ_TP_CON # '1' .AND. EEQ->EEQ_TP_CON # ' ' .AND. EEQ->EEQ_TP_CON # '' // Nick 04/09/06
	         EEQ->(DBSKIP())
	         LOOP
	      ENDIF
	   ENDIF             
 
    // MJA 28/09/05
       IF EEQ->EEQ_EVENT $ '101/102/103/120/121/122/127'       
          n101ECF := 0
          cNrEEQ := ""
          ECF->(DBSETORDER(9))
          ECF->(DBSEEK(cFilECF+'EXPORT'+'EX'+EEQ->EEQ_PREEMB))
          DO WHILE ECF->(!EOF()) .And. cFilECF = ECF->ECF_FILIAL .AND. ECF->ECF_PREEMB = EEQ->EEQ_PREEMB // VI 13/12/05
             IF ECF->ECF_ID_CAM = EEQ->EEQ_EVENT
                n101ECF += ECF->ECF_VL_MOE
                cNrEEQ := ECF->ECF_NR_CON
             ENDIF
             ECF->(DBSKIP())
          ENDDO
    	  EEC->(DbSeek(cFilEEC+EEQ->EEQ_PREEMB))       
//          IF n101ECF = IF(EEQ->EEQ_EVENT = '101',EEC->EEC_TOTPED,EEQ->EEQ_VL) // Nick 28/04/06
          IF n101ECF = IF(EEQ->EEQ_EVENT = '101',EEC->EEC_TOTPED,EEQ->EEQ_VL) .and. STRZERO(nNR_Cont+1,4,0) <> cNrEEQ
//           If cPrv_Efe = "2"   vi 13/12/05
                nEEQRecAux:=EEQ->(RECNO())
                EEQ->(DBSKIP())
                nEEQRecProx:=EEQ->(RECNO())
                EEQ->(DBGOTO(nEEQRecAux))
                Reclock('EEQ',.F.)
                EEQ->EEQ_NR_CON := cNrEEQ
                EEQ->(MSUNLOCK())
                if nTpNrCont = 1
//                 EEQ->(DbSeek(cFilEEQ+Space(Len(EEQ->EEQ_NR_CON)),.T.))
                   bCondicao := {|| Empty(EEQ->EEQ_NR_CON) }
                else
//                 EEQ->(DbSeek(cFilEEQ+Replicate("X",AVSX3("EEQ_NR_CON",3,"EEQ")),.T.)) 
                   bCondicao := {|| EEQ->EEQ_NR_CON = Replicate("X",AVSX3("EEQ_NR_CON",3,"EEQ"))} 
                endif
                EEQ->(DBGOTO(nEEQRecProx))
                LOOP
//  	      else
//              EEQ->(DBSKIP())
//              LOOP
//           endif
          ENDIF
       ENDIF
                  
	//------------------------------------------ MJA 30/09/04   Para Calcular se for Back to Back
	   IF lBackTo
	      if AP106isBackto(EEQ->EEQ_PREEMB,OC_EM) //.and. EEQ->EEQ_VCT >= dDta_Ini .And. EEQ->EEQ_VCT <= dDta_Fim
	         CALC_BACK()
 	         If cPrv_Efe = "2"
                Reclock('EEQ',.F.)
                EEQ->EEQ_NR_CON := STRZERO(nNR_Cont+1,4,0)
                EEQ->(MSUNLOCK())
                if nTpNrCont = 1                                                    
                   EEQ->(DbSeek(cFilEEQ+Space(Len(EEQ->EEQ_NR_CON)),.T.))           
                   bCondicao := {|| Empty(EEQ->EEQ_NR_CON) }                        
                 else                                                                 
                   EEQ->(DbSeek(cFilEEQ+Replicate("X",AVSX3("EEQ_NR_CON",3,"EEQ")),.T.)) 
                   bCondicao := {|| EEQ->EEQ_NR_CON = Replicate("X",AVSX3("EEQ_NR_CON",3,"EEQ"))} 
                endif
                LOOP
	         ENDIF
	         
	         EEQ->(DBSKIP())
	         LOOP
	      endif
	   ENDIF
	//------------------------------------------
	     
	   aDadosPrv := {}
	   aDados101 := {}
	   
	   oProcess:IncRegua2("1 / 4 "+STR0029+Alltrim(EEQ->EEQ_PREEMB)+' Inv: '+Alltrim(EEQ->EEQ_NRINVO)) //"Contrato: "
	
	   If lEnd
	      If lEnd:=MsgYesNo(STR0097,STR0098) 
	         Return .F.
	      EndIf
	   EndIf
	
	   // Contabiliza Despesas
	   nPos := Ascan(aProcDesp, EEQ->EEQ_PREEMB)
	   If nPos = 0
	      If lTemEETNew
	         PRDESP999(EEQ->EEQ_PREEMB, EEQ->EEQ_NRINVO)
	      Endif
	      AAdd(aProcDesp, EEQ->EEQ_PREEMB)
	   Endif
	
    // Nick - 14/03/2006  - Mudei pois estava no local errado e não estava carregando corretamente

	   If lPagAnt
	      cTipo := If(EEQ->EEQ_FASE = 'C', 'CLI', If(EEQ->EEQ_FASE = 'P', 'PED', 'EMB') )
	      cFase := EEQ->EEQ_FASE
	   Else
	      cTipo := 'EXP'
	      cFase := " "
	   Endif
	
	
	//----------------------------------------------------------------------- MJA 26/08/04
	   Do Case
	      // Gera Evento de Desconto   
	      Case EEQ->EEQ_EVENT = "801"
	         nTxDiaLiq := EEQ->EEQ_TX
	     		nVlrReais := EEQ->EEQ_VL * nTxDiaLiq
	         cMoeda := EEQ->EEQ_MOEDA 
	         //                  1         2     3         4           5         6          7        8           9            10                  11                  12         13          14  15  16  17  18  19  20 21 22     23                               24                                           25            26 27
	         AAdd(aDadosPRV, {nVlrReais, '801', "", EEQ->EEQ_NRINVO, '801', EEQ->EEQ_PGT, cMoeda, nTxDiaLiq, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, "", "", "", "", "", "", "",0, 0,(EEQ->EEQ_VL),IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
	         // V.C. Desconto
	         nVariacao := (EEQ->EEQ_VL * EEQ->EEQ_TX)-(EEQ->EEQ_VL * nTxEmb)
	         cEvento   := If(nVariacao > 0, "584","585")
//	         If nVariacao <> 0
	            AAdd(aDadosPRV, {nVariacao, cEvento, "", EEQ->EEQ_NRINVO, cEvento, EEQ->EEQ_PGT, cMoeda, nTxDiaLiq, nTxEmb, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, "", "", "", "", "", "", "",0, 0,(EEQ->EEQ_VL),IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
//	         Endif
	      // Gera Evento de Devolução
	      Case EEQ->EEQ_EVENT = "802"
	         nTxDiaLiq := EEQ->EEQ_TX
	     		nVlrReais := EEQ->EEQ_VL * nTxDiaLiq
	         cMoeda := EEQ->EEQ_MOEDA
	         //                  1         2     3         4           5         6          7        8           9            10                  11                  12         13          14  15  16  17  18  19  20 21 22     23
	         AAdd(aDadosPRV, {nVlrReais, '802', "", EEQ->EEQ_NRINVO, '802', EEQ->EEQ_PGT, cMoeda, nTxDiaLiq, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, "", "", "", "", "", "", "",0, 0,(EEQ->EEQ_VL),IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
	         // V.C. Desconto
	         nVariacao := (EEQ->EEQ_VL * EEQ->EEQ_TX)-(EEQ->EEQ_VL * nTxEmb)
	         cEvento   := If(nVariacao > 0, "586","587")
//	         If nVariacao <> 0
	            AAdd(aDadosPRV, {nVariacao, cEvento, "", EEQ->EEQ_NRINVO, cEvento, EEQ->EEQ_PGT, cMoeda, nTxDiaLiq, nTxEmb, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, "", "", "", "", "", "", "",0, 0,(EEQ->EEQ_VL),IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
//	         Endif
	      Case EEQ->EEQ_EVENT = "803"
	         nTxDiaLiq := EEQ->EEQ_TX
	     		nVlrReais := EEQ->EEQ_VL * nTxDiaLiq
	         cMoeda := EEQ->EEQ_MOEDA
	         //                  1         2     3         4           5         6          7        8           9            10                  11                  12         13          14  15  16  17  18  19  20 21 22     23
	         AAdd(aDadosPRV, {nVlrReais, '803', "", EEQ->EEQ_NRINVO, '803', EEQ->EEQ_PGT, cMoeda, nTxDiaLiq, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, "", "", "", "", "", "", "",0, 0,(EEQ->EEQ_VL),IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
	         // V.C. Desconto
	         nVariacao := (EEQ->EEQ_VL * EEQ->EEQ_TX)-(EEQ->EEQ_VL * nTxEmb)
	         cEvento   := If(nVariacao > 0, "570","571")
//	         If nVariacao <> 0
	            AAdd(aDadosPRV, {nVariacao, cEvento, "", EEQ->EEQ_NRINVO, cEvento, EEQ->EEQ_PGT, cMoeda, nTxDiaLiq, nTxEmb, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, "", "", "", "", "", "", "",0, 0,(EEQ->EEQ_VL),IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
//	         Endif
	      Case EEQ->EEQ_EVENT = "804"
	         nTxDiaLiq := EEQ->EEQ_TX
	     	 nVlrReais := EEQ->EEQ_VL * nTxDiaLiq
	         cMoeda := EEQ->EEQ_MOEDA
	         //                  1         2     3         4           5         6          7        8           9            10                  11                  12         13          14  15  16  17  18  19  20 21 22     23
	         AAdd(aDadosPRV, {nVlrReais, '804', "", EEQ->EEQ_NRINVO, '804', EEQ->EEQ_PGT, cMoeda, nTxDiaLiq, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, "", "", "", "", "", "", "",0, 0,(EEQ->EEQ_VL),IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
	         // V.C. Desconto
	         nVariacao := (EEQ->EEQ_VL * EEQ->EEQ_TX)-(EEQ->EEQ_VL * nTxEmb)
	         cEvento   := If(nVariacao > 0, "572","573")
//	         If nVariacao <> 0
	            AAdd(aDadosPRV, {nVariacao, cEvento, "", EEQ->EEQ_NRINVO, cEvento, EEQ->EEQ_PGT, cMoeda, nTxDiaLiq, nTxEmb, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, "", "", "", "", "", "", "",0, 0,(EEQ->EEQ_VL),IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
//	         Endif
	      Case EEQ->EEQ_EVENT = "805"
	         nTxDiaLiq := EEQ->EEQ_TX
	     		nVlrReais := EEQ->EEQ_VL * nTxDiaLiq
	         cMoeda := EEQ->EEQ_MOEDA
	         //                  1         2     3         4           5         6          7        8           9            10                  11                  12         13          14  15  16  17  18  19  20 21 22     23
	         AAdd(aDadosPRV, {nVlrReais, '805', "", EEQ->EEQ_NRINVO, '805', EEQ->EEQ_PGT, cMoeda, nTxDiaLiq, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, "", "", "", "", "", "", "",0, 0,(EEQ->EEQ_VL),IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
	         // V.C. Desconto
	         nVariacao := (EEQ->EEQ_VL * EEQ->EEQ_TX)-(EEQ->EEQ_VL * nTxEmb)
	         cEvento   := If(nVariacao > 0, "574","575")
//	         If nVariacao <> 0
	            AAdd(aDadosPRV, {nVariacao, cEvento, "", EEQ->EEQ_NRINVO, cEvento, EEQ->EEQ_PGT, cMoeda, nTxDiaLiq, nTxEmb, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, "", "", "", "", "", "", "",0, 0,(EEQ->EEQ_VL),IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
//	         Endif
	      Case EEQ->EEQ_EVENT = "806"
	         nTxDiaLiq := EEQ->EEQ_TX
	     		nVlrReais := EEQ->EEQ_VL * nTxDiaLiq
	         cMoeda := EEQ->EEQ_MOEDA
	         //                  1         2     3         4           5         6          7        8           9            10                  11                  12         13          14  15  16  17  18  19  20 21 22     23
	         AAdd(aDadosPRV, {nVlrReais, '806', "", EEQ->EEQ_NRINVO, '806', EEQ->EEQ_PGT, cMoeda, nTxDiaLiq, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, "", "", "", "", "", "", "",0, 0,(EEQ->EEQ_VL),IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
	         // V.C. Desconto
	         nVariacao := (EEQ->EEQ_VL * EEQ->EEQ_TX)-(EEQ->EEQ_VL * nTxEmb)
	         cEvento   := If(nVariacao > 0, "576","577")
//	         If nVariacao <> 0
	            AAdd(aDadosPRV, {nVariacao, cEvento, "", EEQ->EEQ_NRINVO, cEvento, EEQ->EEQ_PGT, cMoeda, nTxDiaLiq, nTxEmb, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, "", "", "", "", "", "", "",0, 0,(EEQ->EEQ_VL),IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
//	         Endif
	      Case EEQ->EEQ_EVENT = "807"
	         nTxDiaLiq := EEQ->EEQ_TX
	     		nVlrReais := EEQ->EEQ_VL * nTxDiaLiq
	         cMoeda := EEQ->EEQ_MOEDA
	         //                  1         2     3         4           5         6          7        8           9            10                  11                  12         13          14  15  16  17  18  19  20 21 22     23
	         AAdd(aDadosPRV, {nVlrReais, '807', "", EEQ->EEQ_NRINVO, '807', EEQ->EEQ_PGT, cMoeda, nTxDiaLiq, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, "", "", "", "", "", "", "",0, 0,(EEQ->EEQ_VL),IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
	         // V.C. Desconto
	         nVariacao := (EEQ->EEQ_VL * EEQ->EEQ_TX)-(EEQ->EEQ_VL * nTxEmb)
	         cEvento   := If(nVariacao > 0, "578","579")
//	         If nVariacao <> 0
	            AAdd(aDadosPRV, {nVariacao, cEvento, "", EEQ->EEQ_NRINVO, cEvento, EEQ->EEQ_PGT, cMoeda, nTxDiaLiq, nTxEmb, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, "", "", "", "", "", "", "",0, 0,(EEQ->EEQ_VL),IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
//	         Endif
	        
	   EndCase
	
	//----------------------------------------------------------------------- FIM
	
	// Aqui ficava os calculos - comissoes, frete, seguro e outras despesas.
	
	
    // Aqui ficava o back to back	
	
	
	   // Contabiliza Adiantamento caso mesmo esteja liquidado
//	   IF EEQ->EEQ_FASE $ 'E/C/P' .And. EEQ->EEQ_TIPO $ 'A' .And. EEQ->EEQ_EVENT $ '605/602/101' ;
	   IF EEQ->EEQ_FASE $ 'E/C/P' .And. EEQ->EEQ_TIPO $ 'A' .And. EEQ->EEQ_EVENT $ '605/602' ; // MJA 07/08/05
	      .And. (Empty(EEQ->EEQ_PGT) .OR. ((EEQ->EEQ_PGT < (dDta_Ini) .Or. EEQ->EEQ_PGT > (dDta_Fim)) .AND. !EMPTY(EEQ->EEQ_PGT)))
	      EEQ->(DbSkip())
	      Loop
	   Endif
	
	   IF (EEQ->EEQ_EVENT >= '300' .and. EEQ->EEQ_EVENT <= '499') .and. ;
	      (Empty(EEQ->EEQ_PGT) .Or. (EEQ->EEQ_PGT < (dDta_Ini) .Or. EEQ->EEQ_PGT > (dDta_Fim)))
	      EEQ->(DbSkip())
	      Loop
	   Endif
	
	   // Data de Embarque
	   dDta_Emb    := dDta_Fim
	                             
	   EEC->(DbSeek(cFilEEC+EEQ->EEQ_PREEMB))
	   dEmbA := EEC->EEC_DTEMBA // MJA 07/08/05
	   
//	   If EEC->EEC_COBCAM $ cNao .or. EEC->EEC_MPGEXP = '006' .OR. (EEC->EEC_STATUS = '*' .and. !Empty(EEC->EEC_FIM_PE) .and. EEC->EEC_FIM_PE < dDta_Ini) .or. ;
	   If EEC->EEC_MPGEXP = '006' .OR. (EEC->EEC_STATUS = '*' .and. !Empty(EEC->EEC_FIM_PE) .and. EEC->EEC_FIM_PE < dDta_Ini) .or. ;  // MJA 24/05/05 Para calcular mesmo sem cobertura cambial.
	      ((EEC->EEC_STATUS = '*' .and. !Empty(EEC->EEC_FIM_PE) .and. EEC->EEC_FIM_PE >= dDta_Ini .AND. EEC->EEC_FIM_PE <= dDta_Fim) .and. !ECF->(DbSeek(cFilECF+cTPMODU+'EX'+EEQ->EEQ_PREEMB)))
	      EEQ->(DbSkip())
	      Loop
	   EndIf
	   
	   ECG->(DbSeek(cFilECG+cTPMODU+'EX'+EEQ->EEQ_PREEMB))
	                                         
	   
	//------------------ FRETE/SEGURO/OUTRAS DESPESAS ----------------------------------------------------- MJA 09/09/04
	   
	   IF !(EEQ->EEQ_EVENT >= '300' .and. EEQ->EEQ_EVENT <= '499')
	      If !Empty(EEC->EEC_DTEMBA)
	         If !Empty(ECG->ECG_DTENCE) //AAF 24/11/09 - Despreza processos com contabilização encerrada.
	            EEQ->(DbSkip())
	            Loop
	         ElseIf EEC->EEC_DTEMBA >= dDta_Ini .And. EEC->EEC_DTEMBA <= dDta_Fim .OR. EEQ->EEQ_NR_CON = Replicate("X",AVSX3("EEQ_NR_CON",3,"EEQ"))
	            dDta_Emb := EEC->EEC_DTEMBA
	         ElseIf EEQ->EEQ_EVENT <> "603" .OR. EEC->EEC_DTEMBA >= dDta_Fim
	            EEQ->(DbSkip())
	            Loop
	         Endif
	      EndIf
	   Endif
	  
	  If EEQ->EEQ_EVENT == "603"
    	 dDta_Emb := EEC->EEC_DTEMBA
      EndIf
	  
	//------------------ FIM ------------------------------------------------------------------------------ MJA 09/09/04
	  
	   cProcesso := EEQ->EEQ_PREEMB
	   cParcela  := EEQ->EEQ_PARC
	   cInvoice  := EEQ->EEQ_NRINVO
	
	   // Armazena os processos originais
	   cFaseOr   := If(lPagAnt,EEQ->EEQ_FAOR, "")
	   cProcOr   := If(lPagAnt,EEQ->EEQ_PROR, "")
	   cParcOr   := If(lPagAnt,EEQ->EEQ_PAOR, "")
	
	   // Nick - 14/03/2006 - Está no local errado pois está utilizando antes de carregar a
	   // variavel cTIPO
	   /*If lPagAnt
	      cTipo := If(EEQ->EEQ_FASE = 'C', 'CLI', If(EEQ->EEQ_FASE = 'P', 'PED', 'EMB') )
	      cFase := EEQ->EEQ_FASE
	   Else
	      cTipo := 'EXP'
	      cFase := " "
	   Endif */
	
	   // Definição da moeda
	   If cFase = 'C'      // Cliente
	      SA1->(DbSeek(cFilSA1+Alltrim(EEQ->EEQ_PREEMB)))	      
	      // EXJ->(DbSetOrder(1))
          // EXJ->(DbSeek(xFilial("EXJ")+SA1->A1_COD+SA1->A1_LOJA))
	      cMoeda := IF(!EMPTY(EEQ->EEQ_MOEDA),EEQ->EEQ_MOEDA,SA1->A1_MOEDA)
	      EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT","")+'605'))
	   Elseif cFase = 'P'  // Pedido
	      EE7->(DbSeek(cFilEE7+AVKEY(EEQ->EEQ_PREEMB, "EE7_PEDIDO")))
	      cMoeda := EE7->EE7_MOEDA
	      EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT","")+'602'))
	   Else                // Embarque
         cMoeda := EEQ->EEQ_MOEDA //EEC->EEC_MOEDA VI 09/08/05
	      EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT","")+'101'))
	   Endif
	   cTX_101 := EC6->EC6_TXCV
	   //Taxas
	
	   nTxDiaLiq := EEQ->EEQ_TX
	   nTxFimMes := ECOEXP999Tx(cMoeda, dDta_Fim, cTX_101 )
	   nTxIniMes := ECOEXP999Tx(cMoeda, dDta_Ini, cTX_101 )
	   nTxEmb    := ECOEXP999Tx(cMoeda, dDta_Emb, cTX_101 )
	
	   // nTxMesAnt := If(!Empty(ECG->ECG_ULT_TX), ECG->ECG_ULT_TX, nTxIniMes)
       // Nick 20/04/06

	   If !Empty(ECG->ECG_ULT_TX) // Já tinha contabilização
	      nTxMesAnt := ECG->ECG_ULT_TX
	   ElseIf dDta_Emb <= dDta_Fim .AND. dDta_Emb >= dDta_Ini .and. !(EEQ->EEQ_TIPO = 'A')   // Data de embarque no período
	      nTxMesAnt := nTxEmb
	   ElseIf lPagAnt
	      If EEQ->EEQ_PGT >= dDta_Ini .and. EEQ->EEQ_PGT <= dDta_Fim
	         nTxMesAnt := nTxDiaLiq
	      Else
	         nTxMesAnt := ECOEXP999Tx(cMoeda,(dDta_Ini - 1), cTX_101 )
	      Endif
	   Else 
	      nTxMesAnt := nTxIniMes
	   EndIf
       

	   IF EEQ->EEQ_EVENT $ '120/121/122' .and. lComiss // MJA 03/08/05
	      CALC_COMISS("IN",nResFinal)

	      If cPrv_Efe = "2"
            Reclock('EEQ',.F.)
            EEQ->EEQ_NR_CON := STRZERO(nNR_Cont+1,4,0)
            EEQ->(MSUNLOCK())
            if nTpNrCont = 1                                                    
               EEQ->(DbSeek(cFilEEQ+Space(Len(EEQ->EEQ_NR_CON)),.T.))           
               bCondicao := {|| Empty(EEQ->EEQ_NR_CON) }                        
             else                                                                 
               EEQ->(DbSeek(cFilEEQ+Replicate("X",AVSX3("EEQ_NR_CON",3,"EEQ")),.T.)) 
               bCondicao := {|| EEQ->EEQ_NR_CON = Replicate("X",AVSX3("EEQ_NR_CON",3,"EEQ"))} 
            endif
            LOOP
	      ENDIF

         EEQ->(DBSKIP())
         Loop

	   ENDIF
	   
	   if EEQ->EEQ_EVENT $ '102/103/127' .and. lFESEOD 
         CALC_FSOD("IN",nResFinal)

	      If cPrv_Efe = "2"
            Reclock('EEQ',.F.)
            EEQ->EEQ_NR_CON := STRZERO(nNR_Cont+1,4,0)
            EEQ->(MSUNLOCK())
            if nTpNrCont = 1
               EEQ->(DbSeek(cFilEEQ+Space(Len(EEQ->EEQ_NR_CON)),.T.))           
               bCondicao := {|| Empty(EEQ->EEQ_NR_CON) }                        
             else
               EEQ->(DbSeek(cFilEEQ+Replicate("X",AVSX3("EEQ_NR_CON",3,"EEQ")),.T.)) 
               bCondicao := {|| EEQ->EEQ_NR_CON = Replicate("X",AVSX3("EEQ_NR_CON",3,"EEQ"))} 
            endif
            LOOP                                                                             
	      ENDIF

         EEQ->(DBSKIP())
         Loop

	   endif
	
	   nVariacao := -9999999999                                 
	   // Contabiliza Despesas e Gera evento 101 quando o processo tiver Embarque
	   nPos := Ascan(aProcessos, cProcesso+cInvoice+cParcela+EEQ->EEQ_EVENT)
	   lGravou101 := .F.
	   If nPos = 0
	      // *-*
	      // Gera Evento 101 de embarque  foi removido dia 26/10 pois mostrava o total do processo sem respeitar condicoes de pagamento
	      If !Empty(EEC->EEC_DTEMBA)

             If EasyEntryPoint("ECOPF999")
                ExecBlock("ECOPF999",.F.,.F.,"ANTES_EVENTO_101")
             Endif

//	         If EEC->EEC_DTEMBA >= (dDta_Ini) .And. EEC->EEC_DTEMBA <= (dDta_Fim) .And. !ECF->(DbSeek(cFilECF+cTPMODU+'EX'+EEQ->EEQ_PREEMB+Space(Len(ECF->ECF_FASE))+AvKey(EEQ->EEQ_NRINVO,"ECF_INVEXP")+Space(Len(ECF->ECF_SEQ))+"101")) .and. EEQ->EEQ_TIPO # 'A' .and. EEQ->EEQ_TIPO # 'P' // VI 29/07/03 MJA 28/09/04 ACRESCENTADO O EEQ->EEQ_TIPO # 'P'
	         //If EEC->EEC_DTEMBA >= (dDta_Ini) .And. EEC->EEC_DTEMBA <= (dDta_Fim) .And. !ECF->(DbSeek(cFilECF+cTPMODU+'EX'+EEQ->EEQ_PREEMB+Space(Len(ECF->ECF_FASE))+AvKey(EEQ->EEQ_NRINVO,"ECF_INVEXP")+Space(Len(ECF->ECF_SEQ))+"101")) .and. EEQ->EEQ_TIPO # 'P' // Nick 05/05/06
	         If EEC->EEC_DTEMBA >= (dDta_Ini) .And. EEC->EEC_DTEMBA <= (dDta_Fim) .And. !ECF->(DbSeek(cFilECF+cTPMODU+'EX'+EEQ->EEQ_PREEMB+Space(Len(ECF->ECF_FASE))+AvKey(EEQ->EEQ_NRINVO,"ECF_INVEXP")+AvKey(EEQ->EEQ_PARC,"ECF_SEQ")+"101")) .and. EEQ->EEQ_TIPO # 'P' // Nick 05/05/06
// VI 29/07/05
               nRecOld := EEQ->(RECNO())
               nOldInd := EEQ->(INDEXORD())
               cOldPro := EEQ->EEQ_PREEMB
               EEQ->(DBSETORDER(1))
               EEQ->(DbSeek(cFilEEQ+cOldPro))                        
               nTotAdiant := 0
               Do While EEQ->(!EOF()) .And. EEQ->EEQ_FILIAL == cFilEEQ .And. EEQ->EEQ_PREEMB = cOldPro
                  If (EEQ->EEQ_EVENT = '101' .OR. EEQ->EEQ_EVENT = '603') .And. EEQ->EEQ_TIPO = "A" 
                     nTotAdiant += EEQ->EEQ_VL
                  ENDIF
  	               EEQ->(DBSKIP())
               Enddo
               EEQ->(DBSETORDER(nOldInd)) // Vai gerar o evento de estorno (999) logo depois, na linha 1279
               EEQ->(DBGOTO(nRecOld))
               lGerar101 := .t.
// VI 29/07/05 	         
	         
	            // Gera Evento 101 - Embarque
//             IF !EMPTY(EEQ->EEQ_CGRAFI)
// VI 25/07/05    nValorOK := EEC->EEC_TOTPED-EEQ->EEQ_CGRAFI
	                 //                      1          2     3         4           5           6               7           8          9     10  11    12           13       14   15  16  17  18  19  20 21 22      23                       24                                              25             26 27
//                AAdd(aDados101, {nValorOK * nTxEmb, '101', "", EEQ->EEQ_NRINVO, '101', EEC->EEC_DTEMBA, EEC->EEC_MOEDA, nTxEmb, nTxMesAnt, "", "", 'EMB', EEQ->EEQ_PREEMB, "",  "", "", "", "", "", "", 0, 0, nValorOK,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ}) // VI 19/11/03             
//             ELSE 
//Nick 24/04/06   AAdd(aDados101, {(EEC->EEC_TOTPED-nTotAdiant) * nTxEmb, '101', "", EEQ->EEQ_NRINVO, '101', EEC->EEC_DTEMBA, EEC->EEC_MOEDA, nTxEmb, nTxMesAnt, "", "", 'EMB', EEQ->EEQ_PREEMB, "",  "", "", "", "", "", "", 0, 0, EEC->EEC_TOTPED-nTotAdiant,IF(EEQ->EEQ_TIPO='R',EEQ->EEQ_IMPORT,EEQ->EEQ_FORN),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ}) // VI 19/11/03               
               // Nick 08/05/06 
               Do case 
                  Case (EEC->EEC_TOTPED = nTotAdiant .and. EEQ->EEQ_TIPO = 'A' .and. EEC->EEC_TOTPED = EEQ->EEQ_SALDO) // .OR. (EEC->EEC_TOTPED <> nTotAdiant .AND. EEQ->EEQ_TIPO # 'A') //Nick 26/09/06
 	                AAdd(aDados101, {(EEC->EEC_TOTPED) * nTxEmb, '101', "", EEQ->EEQ_NRINVO, '101', EEC->EEC_DTEMBA, EEC->EEC_MOEDA, nTxEmb, nTxMesAnt, "", "", 'EMB', EEQ->EEQ_PREEMB, "",  "", "", "", "", "", "", 0, 0, EEC->EEC_TOTPED,IF(EEQ->EEQ_TIPO='R',EEQ->EEQ_IMPORT,EEQ->EEQ_FORN),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""}) // VI 19/11/03             
                  Case (EEC->EEC_TOTPED = nTotAdiant .and. EEQ->EEQ_TIPO = 'A' .and. EEC->EEC_TOTPED <> EEQ->EEQ_SALDO .AND. EEQ->EEQ_PARC = '01') // .AND. EEQ->EEQ_PARC = '01' Nick 03/10/06
                    
 	                //AAdd(aDados101, {(EEC->EEC_TOTPED) * nTxEmb, '101', "", EEQ->EEQ_NRINVO, '101', EEC->EEC_DTEMBA, EEC->EEC_MOEDA, nTxEmb, nTxMesAnt, "", "", 'EMB', EEQ->EEQ_PREEMB, "",  "", "", "", "", "", "", 0, 0, EEQ->EEQ_VL,IF(EEQ->EEQ_TIPO='R',EEQ->EEQ_IMPORT,EEQ->EEQ_FORN),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""}) // VI 19/11/03
 	                AAdd(aDados101, {(EEC->EEC_TOTPED) * nTxEmb, '101', "", EEQ->EEQ_NRINVO, '101', EEC->EEC_DTEMBA, EEC->EEC_MOEDA, nTxEmb, nTxMesAnt, "", "", 'EMB', EEQ->EEQ_PREEMB, "",  "", "", "", "", "", "", 0, 0, EEC->EEC_TOTPED,IF(EEQ->EEQ_TIPO='R',EEQ->EEQ_IMPORT,EEQ->EEQ_FORN),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""}) // VI 19/11/03

                  Case EEQ->EEQ_TIPO # 'A' .AND. EEC->EEC_TOTPED <> nTotAdiant .AND. !(ECA->(DBSEEK(cFilECA+'EXPORT'+EEQ->EEQ_PREEMB+Space(Len(ECA->ECA_IDENTC))+EEQ->EEQ_NRINVO))) //Nick 28/09/06 
                      AAdd(aDados101, {(EEC->EEC_TOTPED) * nTxEmb, '101', "", EEQ->EEQ_NRINVO, '101', EEC->EEC_DTEMBA, EEC->EEC_MOEDA, nTxEmb, nTxMesAnt, "", "", 'EMB', EEQ->EEQ_PREEMB, "",  "", "", "", "", "", "", 0, 0, EEC->EEC_TOTPED,IF(EEQ->EEQ_TIPO='R',EEQ->EEQ_IMPORT,EEQ->EEQ_FORN),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""}) // VI 19/11/03             
                  Case EEQ->EEQ_TIPO # 'A' .AND. EEC->EEC_TOTPED <> nTotAdiant .AND. (ECA->(DBSEEK(cFilECA+'EXPORT'+EEQ->EEQ_PREEMB+Space(Len(ECA->ECA_IDENTC))+EEQ->EEQ_NRINVO))) //Nick 28/09/06
                    Do while ECA->(!EOF()) .and. ECA->ECA_FILIAL = cFilECA .AND. ECA->ECA_PREEMB = EEQ->EEQ_PREEMB .AND. ECA->ECA_INVEXP = EEQ->EEQ_NRINVO
                       IF ECA->ECA_ID_CAM = '101'
                          lGerar101 := .f.
                          Exit
                       Endif
                       ECA->(DBSKIP())
                    Enddo
                    If lGerar101
                       AAdd(aDados101, {(EEC->EEC_TOTPED) * nTxEmb, '101', "", EEQ->EEQ_NRINVO, '101', EEC->EEC_DTEMBA, EEC->EEC_MOEDA, nTxEmb, nTxMesAnt, "", "", 'EMB', EEQ->EEQ_PREEMB, "",  "", "", "", "", "", "", 0, 0, EEC->EEC_TOTPED,IF(EEQ->EEQ_TIPO='R',EEQ->EEQ_IMPORT,EEQ->EEQ_FORN),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""}) // VI 19/11/03             
                    Endif
               EndCase
               PExp999_PrvRat(aDados101)
               lGravou101 := .T.
               aDados101 := {}               
               AAdd(aProcessos, cProcesso+cInvoice+cParcela+EEQ->EEQ_EVENT) //FRR 20/02/06 - Para adicionar somente em eventos 101
	         Endif
	      Endif
	   Endif                   
	      
	   // VI 16/10/03 Para baixar a diferença do que não está financiado.
	   // Testa se tem os campos do Financiamento - Nick - 02/08/06
	   If !Empty(EEQ->EEQ_NRINVO) .And. EF3->(DbSeek(cFilEF3+IF(lEFFTPMOD,cTipoModu,"")+EEQ->EEQ_NRINVO+EEQ->EEQ_PARFIN)) .And.;
	      EEQ->EEQ_EVENT = '101' .And. EEQ->EEQ_FASE $ 'E' .And. (Empty(Alltrim(EEQ->EEQ_TIPO)) .OR. EEQ->EEQ_TIPO = 'R') // MJA 28/09/04
	      If !Empty(EEQ->EEQ_PGT) .Or. (Empty(EEQ->EEQ_PGT) .and. lVcAv)   // vazio e lmv
	         nValInv := 0                 
	                  
	         If !Empty(EEQ->EEQ_PGT) //.Or. !lVcAv // VI 26/07/05
	            EF3->(DbSeek(cFilEF3+IF(lEFFTPMOD,cTipoModu,"")+EEQ->EEQ_NRINVO+EEQ->EEQ_PARFIN+'600')) // Nick 02/08/06
	            Do While EF3->(!Eof()) .And. EF3->EF3_FILIAL = cFilEF3 .And.  ;
	               EF3->EF3_INVOIC = EEQ->EEQ_NRINVO .And. EF3->EF3_PARC = EEQ->EEQ_PARFIN .And. EF3->EF3_CODEVE = '600'
	               if EF3->EF3_EV_FO = ' ' .or. EF3->EF3_EV_FO $ cNao // VI 17/12/05
//                   nValInv += EF3->EF3_VL_MOE VI 26/07/05
                     nValInv += EF3->EF3_VL_INV
	               endif
	               EF3->(DbSkip())
	            EndDo
	         EndIf
//	         If (EEQ->EEQ_VL - nValInv) > 0 .AND. (((EEQ->EEQ_VL - nValInv) # EEQ->EEQ_VL) .OR. !lVcAv)
               nTaxaAux := nTxDiaLiq
	            If !Empty(EEQ->EEQ_PGT) //.Or. (Empty(EEQ->EEQ_PGT) .and. lVcAv) // VI 03/11/03
	               nVlrReais := (EEQ->EEQ_VL - nValInv - EEQ->EEQ_CGRAFI) * nTxDiaLiq
	               IF nVlrReais < 0
	                  nVlrReais := 0
	               ENDIF   
	               nVariacao := ((EEQ->EEQ_VL - If(lVcAv,0,nValInv)) * nTxDiaLiq) - ((EEQ->EEQ_VL - If(lVcAv,0,nValInv)) * nTxEmb)
//                AAdd(aDadosPRV,    {nVlrReais, '607', "", EEQ->EEQ_NRINVO, '607', EEQ->EEQ_PGT, cMoeda, nTxDiaLiq, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), cProcOr      , cFaseOr      , cParcOr      , "", "",0,0,(EEQ->EEQ_VL - nValInv),IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ })
                  If nVlrReais <> 0  // VI 23/04/05
                     AAdd(aDadosPRV,    {nVlrReais, '607', "", EEQ->EEQ_NRINVO, '607', EEQ->EEQ_PGT, cMoeda, nTxDiaLiq, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), cProcOr      , cFaseOr      , cParcOr      , "", "",0,0,ABS(EEQ->EEQ_VL - nValInv),IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
                     //If nVlrReais <> 0  // VI 23/04/05 -> Nick 26/10/06 - Nopei pois estava duplicando o lancamento com um valor zerado
                     //   AAdd(aDadosPRV, { 0       , '607', "", EEQ->EEQ_NRINVO, '607', EEQ->EEQ_PGT, cMoeda, nTxDiaLiq, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), cProcOr      , cFaseOr      , cParcOr      , "", "",0,0,               nValInv ,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
                     //EndIf
                  Else      
                     AAdd(aDadosPRV,    { 0       , '607', "", EEQ->EEQ_NRINVO, '607', EEQ->EEQ_PGT, cMoeda, nTxDiaLiq, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), cProcOr      , cFaseOr      , cParcOr      , "", "",0,0, EEQ->EEQ_VL           ,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
                  EndIf
                  if lRegBox
//------------------------------------------------------------ MJA 24/08/05
                     nRecECF := ECF->(Recno())
                     nIndECF := ECF->(INDEXORD())
                     nTxRC := nTxEmb
                     ECF->(DBSETORDER(9))
                     ECF->(DBSEEK(cFilECF+'EXPORT'+'EX'+EEQ->EEQ_PREEMB+' '+EEQ->EEQ_NRINVO+EEQ->EEQ_PARC+'  '+'101'))
                     IF ECF->(!EOF())
                        nTxRC := ECF->ECF_PARIDA
                     ENDIF
                     ECF->(DBSETORDER(nIndECF))
                     ECF->(DBGOTO(nRecECF))
//------------------------------------------------------------
                     nVarRC := ((EEQ->EEQ_VL-If(lVcAv,0,nValInv)) * nTxDiaLiq) - ((EEQ->EEQ_VL-If(lVcAv,0,nValInv)) * nTxRC)
                     //cEveRC := If(nVariacao > 0, "589","588")
                     cEveRC := If(nVarRC > 0, "589","588") //ER - 18/10/2007
		               // V.C do Pagamento
// 				      If nVarRC <> 0    //  1        2     3           4          5       6            7         8         9             10                     11               12           13             14                      15               16  17  18  19     20                 21                 22       23                       24                                         25                   26 27    28
 	                     AAdd(aDadosPRV, {nVarRC, cEveRC, "", EEQ->EEQ_NRINVO, cEveRC, EEQ->EEQ_PGT, cMoeda, nTxDiaLiq, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), "", "", "", "", dDta_Fim, nVarRC,0,0,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""}) //ER - 18/10/2007
	                     //AAdd(aDadosPRV, {nVarRC, cEveRC, "", EEQ->EEQ_NRINVO, cEveRC, dDta_Fim, cMoeda, nTxDiaLiq, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), "", "", "", "", dDta_Fim, nVarRC,0,0,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
// 				      Endif
	                  ZERACON(EEQ->EEQ_PREEMB,EEQ->EEQ_PARC,EEQ->EEQ_TX,EEQ->EEQ_VL,dDta_Fim,nTxRC,nTxMesAnt,nVarRC,EEQ->EEQ_FASE)                   
                  Endif
	              nTaxaAux := nTxDiaLiq
               ElseIf lVcAv .AND. EEQ->EEQ_VL == nValInv // MJA 04/08/05 Acrescentei .AND. EEQ->EEQ_VL == nValInv para calcular qdo for todo vinculado
	               nVariacao := ((EEQ->EEQ_VL - nValInv) * nTxFimMes ) - ((EEQ->EEQ_VL - nValInv) * nTxEmb)
	               nTaxaAux := nTxFimMes
	               
                  // VI 27/07/05 para que não gere v.c. duplicada.
                  nPos := Ascan(aVCProcTotal,{|x| x[1] = EEQ->EEQ_PREEMB})
                  If nPos = 0
                     AAdd(aVCProcTotal, {EEQ->EEQ_PREEMB, EEQ->EEQ_VL})
                  Endif
	               
	            EndIf
                // Retirou-se a validação para não contabilizar VC zerada  MJA 24/08/05
/*	            If nVariacao <> 0 .AND. nVariacao <> -9999999999  // MJA 04/08/05
  	               cEvento := If(nVariacao > 0, "582","583")
	               AAdd(aDadosPRV, {nVariacao, cEvento, "", EEQ->EEQ_NRINVO, cEvento, IF(lVcAv,IF(!EMPTY(EEQ->EEQ_PGT),EEQ->EEQ_PGT,dDta_Fim),dDta_Emb) , cMoeda, nTaxaAux, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), cProcOr, cFaseOr, cParcOr, "", dDta_Fim, 0, 0,(EEQ->EEQ_VL - If(lVcAv,0,nValInv)),IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ }) // MJA 18/08/04 //Alcir Alves - 19-07-05 !lVcAv
	            Endif*/                
	            If nVariacao <> -9999999999  // MJA 04/08/05
  	               cEvento := If(nVariacao > 0, "582","583")
	               AAdd(aDadosPRV, {nVariacao, cEvento, "", EEQ->EEQ_NRINVO, cEvento, IF(lVcAv,IF(!EMPTY(EEQ->EEQ_PGT),EEQ->EEQ_PGT,dDta_Fim),dDta_Emb) , cMoeda, nTaxaAux, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), cProcOr, cFaseOr, cParcOr, "", dDta_Fim, 0, 0,(EEQ->EEQ_VL - If(lVcAv,0,nValInv)),IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""}) // MJA 18/08/04 //Alcir Alves - 19-07-05 !lVcAv
	            Endif
	            // Grava as Variacoes e eventos na prévia, ja rateando se necessario
	            If Len(aDadosPRV) > 0
	               PExp999_PrvRat(aDadosPRV)
	            Endif
//	         EndIf
	      EndIf
	      // MJA 02/08/05 Para gravar o Numero COntabil no evento 101
	      IF EEQ->EEQ_EVENT = '101' .AND. EEQ->EEQ_TIPO = 'A' .AND.  (dEmbA < dDta_Ini .OR. dEmbA > dDta_Fim .OR. EMPTY(dEmbA)) // MJA 07/08/05
	         EEQ->(DBSKIP())
	         LOOP
	      ENDIF
	      If cPrv_Efe = "2"
            Reclock('EEQ',.F.)
            EEQ->EEQ_NR_CON := STRZERO(nNR_Cont+1,4,0)
            EEQ->(MSUNLOCK())
            if nTpNrCont = 1
               EEQ->(DbSeek(cFilEEQ+Space(Len(EEQ->EEQ_NR_CON)),.T.))
               bCondicao := {|| Empty(EEQ->EEQ_NR_CON) }
             else
               EEQ->(DbSeek(cFilEEQ+Replicate("X",AVSX3("EEQ_NR_CON",3,"EEQ")),.T.))
               bCondicao := {|| EEQ->EEQ_NR_CON = Replicate("X",AVSX3("EEQ_NR_CON",3,"EEQ"))}
            endif
            LOOP
	      ENDIF
	      
	      EEQ->(DbSkip())
	      Loop
	   Endif
	   // fim VI 16/10/03
	   
	   l607:=.F.
      nResFinal := 0
	   If nTpNrCont = 1      
         If EEQ->EEQ_EVENT = '101' .And. EEQ->EEQ_TIPO # "A"
            nVlrReais := (EEQ->EEQ_VL - EEQ->EEQ_CGRAFI) * If(!Empty(EEQ->EEQ_PGT), nTxDiaLiq, nTxEmb)
//          nVlrReais := (EEQ->EEQ_VL) * If(!Empty(EEQ->EEQ_PGT), nTxDiaLiq, nTxEmb) MJA 10/08/05
         Elseif EEQ->EEQ_EVENT $ '101/603' .And. EEQ->EEQ_TIPO = "A"
//VI 25/07/05 nVlrReais := (EEQ->EEQ_VL - EEQ->EEQ_CGRAFI) * If(EEQ->EEQ_EVENT $ '101', nTxEmb, nTxDiaLiq )
//          nVlrReais := (EEQ->EEQ_VL) * If(EEQ->EEQ_EVENT $ '101', nTxEmb, nTxDiaLiq )
//            nVlrReais := (EEQ->EEQ_VL) * If(EEQ->EEQ_EVENT $ '101/116/115/112', nTxEmb, nTxDiaLiq )
            nVlrReais := (EEQ->EEQ_VL) * nTxEmb
         Else
            nVlrReais := (EEQ->EEQ_VL * EEQ->EEQ_TX ) // MJA 03/08/05
         EndIf
      Else
   	   nPos := ASCAN(aRecProc,{|x| x[1]=EEQ->EEQ_PREEMB})
         IF nPos = 0
            nRecOld := EEQ->(RECNO())
            nOldInd := EEQ->(INDEXORD())
            cOldPro := EEQ->EEQ_PREEMB
            EEQ->(DBSETORDER(1))
            EEQ->(DbSeek(cFilEEQ+cOldPro))
    	      Do While EEQ->(!EOF()) .And. EEQ->EEQ_FILIAL == cFilEEQ .And. EEQ->EEQ_PREEMB = cOldPro
                If EEQ->EEQ_EVENT = '101'
                   nTotEEQ += EEQ->EEQ_VL
                   AADD(aRecProc,{EEQ->EEQ_PREEMB,EEQ->(RECNO())})
                ENDIF
  	            EEQ->(DBSKIP())
            Enddo
            ECF->(DBSETORDER(9))
            ECF->(DbSeek(cFilECF+'EXPORT'+'EX'+cOldPro))
            Do While ECF->(!EOF()) .And. ECF->ECF_FILIAL == cFilECF .And. ECF->ECF_PREEMB = cOldPro
                IF ECF->ECF_ID_CAM = '101'
                   nTotECF += ECF->ECF_VL_MOE
                ENDIF
                ECF->(DBSKIP())
            Enddo
            nResFinal := nTotEEQ - nTotECF
            DO CASE
                CASE nResFinal > 0
                     nVlrReais := nResFinal
                CASE nResFinal < 0
                     EEQ->(DBSETORDER(nOldInd)) // Vai gerar o evento de estorno (999) logo depois, na linha 1279
                     EEQ->(DBGOTO(nRecOld))
                OTHERWISE
                     EEQ->(DBSETORDER(nOldInd))
                     EEQ->(DBGOTO(nRecOld))
                     EEQ->(DBSKIP())
                     LOOP
            ENDCASE
   	    Else
            EEQ->(DBSKIP())
            LOOP
   	   Endif
   	Endif

   	
	   // Parcela de câmbio
	   lContab := .T.
	
	   // Efetivacao
      IF EEQ->EEQ_EVENT = '101' .AND. EEQ->EEQ_TIPO = 'A' .AND.  (dEmbA < dDta_Ini .OR. dEmbA > dDta_Fim .OR. EMPTY(dEmbA)) // MJA 07/08/05
         EEQ->(DBSKIP())
         LOOP
      ENDIF

	   nRecAuxEEQ := 0
	   If cPrv_Efe = "2"
    	   IF nTpNrCont = 2 .AND. nResFinal # 0

    	     FOR I := 1 TO LEN(aRecProc)
	             EEQ->(DBGOTO(aRecProc[i,2]))
                 RECLOCK('EEQ',.F.)
	             EEQ->EEQ_NR_CON := STRZERO(nNR_Cont+1,4,0)
	             EEQ->(MSUNLOCK())
	         NEXT I
            
	      ELSE
 	         nRecEEQAutal := EEQ->(RECNO())
	         EEQ->(DBSKIP())
	         nRecAuxEEQ := EEQ->(RECNO())
	         EEQ->(DBGOTO(nRecEEQAutal))
	         Reclock('EEQ',.F.)
	         EEQ->EEQ_NR_CON := STRZERO(nNR_Cont+1,4,0)
	         EEQ->(MSUNLOCK())
	      ENDIF
	   Endif
	   
	   IF EEQ->EEQ_EVENT $ '120/121/122/102/103/127'
	   	  If cPrv_Efe = "2"
             If nRecAuxEEQ <> 0
                EEQ->(DBSETORDER(8))                     // MJA 27/04/05
	            EEQ->(DBGOTO(nRecAuxEEQ))
	          Else
	            EEQ->(DbSeek(cFilEEQ+Space(Len(EEQ->EEQ_NR_CON)),.T.))
	         EndIf
      	     Loop
           ENDIF
 	      //EEQ->(DbSkip())
      endif
	
	   if EEQ->EEQ_EVENT = '101' .And. !Empty(EEQ->EEQ_PGT) .And. EEQ->EEQ_TIPO # 'A' .And. EEQ->EEQ_TIPO # 'P' // MJA 28/09/04
	      If EEQ->EEQ_PGT < (dDta_Ini) .Or. EEQ->EEQ_PGT > (dDta_Fim)
	         lContab := .F.
	      Endif
	   Endif
	
	   If !lContab
	      If cPrv_Efe = "2"
	         If nRecAuxEEQ <> 0
	            EEQ->(DBGOTO(nRecAuxEEQ))
	         Else
	            EEQ->(DbSeek(cFilEEQ+Space(Len(EEQ->EEQ_NR_CON)),.T.))
	         EndIf
	      Else
	         EEQ->(DbSkip())
	      Endif   
	      Loop
	   Else                             
	      If ( EEQ->EEQ_EVENT = '101' .OR. EEQ->EEQ_EVENT = '603' ) .And. !Empty(EEQ->EEQ_PGT)               // Gera Evento de Pagamento / VC Pagamento Cliente
	         If ! Empty(dDta_Emb) .and. (dDta_Emb >= dDta_Ini .And. dDta_Emb <= dDta_Fim .OR. EEQ->EEQ_EVENT = '603')
	            nTaxAux := nTxEmb
	         Else 
	            nTaxAux := nTxMesAnt
	         EndIf
	         If EEQ->EEQ_TIPO = 'A'
	            If EEQ->EEQ_EVENT = '603'
	               cEvento = '117'
	            Else
                   cEvento := If(cTipo='EMB' .and. cFaseOr $ 'C', '116', If(cTipo='EMB' .and. cFaseOr $ 'P', '112', '115'))
                EndIf
//              nVariacao := (EEQ->EEQ_VL * nTxDiaLiq) - (EEQ->EEQ_VL * nTaxAux)
                nVariacao := (EEQ->EEQ_VL * nTaxAux) - (EEQ->EEQ_VL * nTxMesAnt)
	         Else
	            cEvento := '607'
//VI 25/07/05   nVariacao := ((EEQ->EEQ_VL - EEQ->EEQ_CGRAFI) * nTxDiaLiq) - ((EEQ->EEQ_VL - EEQ->EEQ_CGRAFI) * nTaxAux)
                nVariacao := ((EEQ->EEQ_VL ) * nTxDiaLiq) - ((EEQ->EEQ_VL ) * nTaxAux)
	         EndIf                                                                     
	         
	         //----------------------------- Para calcular Regime de Caixa MJA 25/03/05
             if lRegBox .and. cEvento = '607'             
//VI 25/07/05   nVarRC := ((EEQ->EEQ_VL - EEQ->EEQ_CGRAFI) * nTxDiaLiq) - ((EEQ->EEQ_VL - EEQ->EEQ_CGRAFI) * nTxEmb)
//------------------------------------------------------------ MJA 24/08/05
                nRecECF := ECF->(Recno())
                nIndECF := ECF->(INDEXORD())
                nTxRC := nTxEmb
                ECF->(DBSETORDER(9))
                //ECF->(DBSEEK(cFilECF+'EXPORT'+'EX'+EEQ->EEQ_PREEMB+' '+EEQ->EEQ_NRINVO+EEQ->EEQ_PARC+'  '+'101'))
                ECF->(DBSEEK(cFilECF+'EXPORT'+'EX'+EEQ->EEQ_PREEMB+' '+EEQ->EEQ_NRINVO+AvKey(EEQ->EEQ_PARC,"ECF_SEQ")+'101')) // Nick 11/09/2006
                IF ECF->(!EOF())
                   nTxRC := ECF->ECF_PARIDA
                ENDIF
                ECF->(DBSETORDER(nIndECF))
                ECF->(DBGOTO(nRecECF))
//------------------------------------------------------------

                nVarRC := ((EEQ->EEQ_VL ) * nTxDiaLiq) - ((EEQ->EEQ_VL ) * nTxRC)
 		        //cEveRC := If(nVariacao > 0, "589","588")
                cEveRC := If(nVarRC > 0, "589","588")	//ER - 18/10/2007

				// V.C do Pagamento
			    If nVarRC <> 0
//VI 25/07/05      AAdd(aDadosPRV, {nVarRC, cEveRC, "", EEQ->EEQ_NRINVO, cEveRC, dDta_Fim, cMoeda, nTxDiaLiq, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), "", "", "", "", dDta_Fim, nVarRC,0,(EEQ->EEQ_VL - EEQ->EEQ_CGRAFI),IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ })
//ER 18/10/07      AAdd(aDadosPRV, {nVarRC, cEveRC, "", EEQ->EEQ_NRINVO, cEveRC, dDta_Fim, cMoeda, nTxDiaLiq, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), "", "", "", "", dDta_Fim, nVarRC,0,(EEQ->EEQ_VL ),IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
                   AAdd(aDadosPRV, {nVarRC, cEveRC, "", EEQ->EEQ_NRINVO, cEveRC, EEQ->EEQ_PGT, cMoeda, nTxDiaLiq, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), "", "", "", "", dDta_Fim, nVarRC,0,(EEQ->EEQ_VL ),IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
				Endif
	            ZERACON(EEQ->EEQ_PREEMB,EEQ->EEQ_PARC,EEQ->EEQ_TX,EEQ->EEQ_VL,dDta_Fim,nTxRC,nTxMesAnt,nVarRC,EEQ->EEQ_FASE)	         
			 
			 ElseIf lRegBox
                //ER - 24/10/2007
                If cEvento == "112"
                   nVarRC := (EEQ->EEQ_VL * EEQ->EEQ_TX) - (EEQ->EEQ_VL * nTxEmb)
                   cEveRC := If(nVarRC > 0, "593","592")
                   aAdd(aDadosPRV, {nVarRC, cEveRC, "", EEQ->EEQ_NRINVO, cEveRC, EEC->EEC_DTEMBA, cMoeda, nTxEmb, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), "", "", "", "", dDta_Fim, nVarRC,0,0,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""}) //ER - 18/10/2007
                
                ElseIf cEvento $ "115/116/117"
                   nVarRC := (EEQ->EEQ_VL * EEQ->EEQ_TX) - (EEQ->EEQ_VL * nTxEmb)
                   cEveRC := If(nVarRC > 0, "599","598")
                   aAdd(aDadosPRV, {nVarRC, cEveRC, "", EEQ->EEQ_NRINVO, cEveRC, EEC->EEC_DTEMBA, cMoeda, nTxEmb, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), "", "", "", "", dDta_Fim, nVarRC,0,0,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""}) //ER - 18/07/2007
                   ZERACON(EEQ->EEQ_PREEMB,EEQ->EEQ_PARC,EEQ->EEQ_TX,EEQ->EEQ_VL,dDta_Fim,nTxEmb,nTxMesAnt,nVarRC,EEQ->EEQ_FASE)
			    
			    Endif
			 Endif
			 //-----------------------------FIM
			 
// Nick 20/04/06   AAdd(aDadosPRV, {nVlrReais, cEvento, ""       , EEQ->EEQ_NRINVO, cEvento, EEQ->EEQ_PGT, cMoeda, nTxDiaLiq, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo   , EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), cProcOr, cFaseOr, cParcOr, "" , ""       , 0     , 0    ,(EEQ->EEQ_VL - EEQ->EEQ_CGRAFI),IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ})
	         
	         //ER - 24/10/2007
	         If EEQ->EEQ_TIPO == 'A'
                AAdd(aDadosPRV, {nVlrReais, cEvento, ""       , EEQ->EEQ_NRINVO, cEvento, EEC->EEC_DTEMBA, cMoeda, nTaxAux,nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo   , EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), cProcOr, cFaseOr, cParcOr, "" , ""       , 0     , 0    ,(EEQ->EEQ_VL - EEQ->EEQ_CGRAFI),IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})	            
	         Else   
	            AAdd(aDadosPRV, {nVlrReais, cEvento, ""       , EEQ->EEQ_NRINVO, cEvento, EEQ->EEQ_PGT, cMoeda, nTxDiaLiq,nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo   , EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), cProcOr, cFaseOr, cParcOr, "" , ""       , 0     , 0    ,(EEQ->EEQ_VL - EEQ->EEQ_CGRAFI),IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
             EndIf
             
	         l607:=.T.
	         
//       Elseif (EEQ->EEQ_EVENT # '801' .AND. EEQ->EEQ_EVENT # '802' .AND. ((EEQ->EEQ_VCT >= dDta_Ini .And. EEQ->EEQ_VCT <= dDta_Fim) .OR. (EEQ->EEQ_NR_CON = Replicate("X",AVSX3("EEQ_NR_CON",3,"EEQ"))))) .OR. EEQ->EEQ_EVENT $ '602/605'
	      Elseif (EEQ->EEQ_EVENT # '801' .AND. EEQ->EEQ_EVENT # '802' .AND. ((EEQ->EEQ_PGT >= dDta_Ini .And. EEQ->EEQ_PGT <= dDta_Fim) .OR. (EEQ->EEQ_NR_CON = Replicate("X",AVSX3("EEQ_NR_CON",3,"EEQ"))))) .OR. EEQ->EEQ_EVENT $ '602/605' // VI 30/07/05	      
	         //----------------------------- Para calcular Regime de Caixa MJA 25/03/05
             /*
             if lRegBox .and. EEQ->EEQ_EVENT $ '602/605'
                if EEQ->EEQ_EVENT = '602'
                   nVarRC := (EEQ->EEQ_VL * EEQ->EEQ_TX) - (EEQ->EEQ_VL * nTxEmb)
     		       //cEveRC := If(nVariacao > 0, "593","592")
                   cEveRC := If(nVarRC > 0, "593","592") //ER - 18/10/2007
				   
				   // V.C do Pagamento
//				   If nVarRC <> 0
				      //AAdd(aDadosPRV, {nVarRC, cEveRC, "", EEQ->EEQ_NRINVO, cEveRC, dDta_Fim, cMoeda, nTxEmb, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), "", "", "", "", dDta_Fim, nVarRC,0,0,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
                      AAdd(aDadosPRV, {nVarRC, cEveRC, "", EEQ->EEQ_NRINVO, cEveRC, EEC->EEC_DTEMBA, cMoeda, nTxEmb, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), "", "", "", "", dDta_Fim, nVarRC,0,0,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""}) //ER - 18/10/2007
//				   Endif   
				 else
                   nVarRC := (EEQ->EEQ_VL * EEQ->EEQ_TX) - (EEQ->EEQ_VL * nTxEmb)
     		       //cEveRC := If(nVariacao > 0, "599","598")
                   cEveRC := If(nVarRC > 0, "599","598") //ER - 18/10/2007

				   // V.C do Pagamento
//				   If nVarRC <> 0
				      //AAdd(aDadosPRV, {nVarRC, cEveRC, "", EEQ->EEQ_NRINVO, cEveRC, dDta_Fim, cMoeda, nTxEmb, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), "", "", "", "", dDta_Fim, nVarRC,0,0,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
                      AAdd(aDadosPRV, {nVarRC, cEveRC, "", EEQ->EEQ_NRINVO, cEveRC, EEC->EEC_DTEMBA, cMoeda, nTxEmb, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), "", "", "", "", dDta_Fim, nVarRC,0,0,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""}) //ER - 18/07/2007
				      ZERACON(EEQ->EEQ_PREEMB,EEQ->EEQ_PARC,EEQ->EEQ_TX,EEQ->EEQ_VL,dDta_Fim,nTxEmb,nTxMesAnt,nVarRC,EEQ->EEQ_FASE)
//				   Endif   				   
			    Endif
			 Endif
			 */   
             //-----------------------------FIM
	         if !lGravou101
  	            IF nResFinal < 0
	               //AAdd(aDadosPRV, {nResFinal, '999', "", EEQ->EEQ_NRINVO, '101', EEQ->EEQ_PGT, cMoeda, nTxDiaLiq, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, "", "", "", "", "", "", "",0, 0, nResFinal,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""}) 
	               //ASK 14/12/2007 - Alterado o 6° parâmetro para a data final de contabilização
                   AAdd(aDadosPRV, {nResFinal, '999', "", EEQ->EEQ_NRINVO, '101', dDta_Fim, cMoeda, nTxDiaLiq, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, "", "", "", "", "", "", "",0, 0, nResFinal,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
	             ELSE
	               AAdd(aDadosPRV, {nVlrReais, if(EEQ->EEQ_FAOR ='C','115',EEQ->EEQ_EVENT), "", EEQ->EEQ_NRINVO, EEQ->EEQ_EVENT, If(EEQ->EEQ_EVENT $ '101', EEC->EEC_DTEMBA, EEQ->EEQ_PGT), cMoeda, If(EEQ->EEQ_EVENT $ '101', nTxEmb, nTxDiaLiq), If(EEQ->EEQ_EVENT $ '101', nTxIniMes, nTxFimMes), cParcela, If(cTipo='EMB',"",cCustoPad), cTipo, cProcesso, cFase, If(lPagAnt, EEQ->EEQ_TIPO, ""), cProcOr, cFaseOr, cParcOr, "", "", 0, 0,EEQ->EEQ_VL,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,IF(EEQ->EEQ_TIPO='A',EEC->EEC_IMPORT,EEQ->EEQ_IMPORT)),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""}) // MJA 31/08/04
	            ENDIF
	         endif   
	      Endif
	   Endif
	
	   // V.C. Recebimento / Adiantamento / Embarque
	   If EEQ->EEQ_TIPO $ 'A' //.Or. (EEQ->EEQ_EVENT $ '101' .And. Empty(EEQ->EEQ_PGT))
	      If EEQ->EEQ_EVENT $ '602/605'
	         nSaldoA := EEQ->EEQ_VL
	         cFaseA := EEQ->EEQ_FASE
	         cPreembA := EEQ->EEQ_PREEMB
	         cParcA := EEQ->EEQ_PARC
	         cEvent := EEQ->EEQ_EVENT
	         cInvo  := EEQ->EEQ_NRINVO // Nick 27/10/06
            nRecOld := EEQ->(Recno())
            nIndOld := EEQ->(INDEXORD())
            EEQ->(DBSETORDER(7))
            EEC->(DBSETORDER(1))
            EEQ->(DBSEEK(cFilEEQ+cFaseA+cPreembA+cParcA))
            //DO WHILE EEQ->(!EOF()) .AND. (EEQ->EEQ_PGT >= dDta_Ini .and. EEQ->EEQ_PGT <= dDta_Fim)
            DO WHILE EEQ->(!EOF()) .AND. (EEQ->EEQ_PGT >= dDta_Ini .and. EEQ->EEQ_PGT <= dDta_Fim) .AND. EEQ->EEQ_NRINVO = cInvo // EEQ->EEQ_PREEMB = cPreembA // Nick 01/09/2006
	   		   EEC->(DBSEEK(cFilEEC+EEQ->EEQ_PREEMB))
               IF (EEQ->EEQ_EVENT $ '101' .AND. !Empty(EEC->EEC_DTEMBA) .AND. EEC->EEC_DTEMBA <= dDta_Fim) .OR. EEQ->EEQ_EVENT $ '602'
                  IF EEQ->EEQ_FAOR = 'C'
                     nSaldoA -= EEQ->EEQ_VL
                  ENDIF
                  IF EEQ->EEQ_FAOR = 'P' .AND. cEvent = '602'
                     nSaldoA -= EEQ->EEQ_VL               
                  ENDIF   
               ENDIF
               EEQ->(DBSKIP())
            ENDDO
            EEQ->(DBSETORDER(nIndOld))
            EEQ->(DBGOTO(nRecOld))
	         IF nSaldoA > 0
	            nVariacao := (nSaldoA * nTxFimMes) - (nSaldoA * If(!Empty(EEQ->EEQ_PGT), nTxDiaLiq, nTxEmb))
	         EndIf
	      Endif
	   Endif
	
	   // Define evento de VC e grava n'a prévia
       // Retirou-se a validação para não contabilizar VC zerada 	   MJA 24/08/05 
  	   If nVariacao <> -9999999999 // .AND. nVariacao <> 0 
	      If EEQ->EEQ_EVENT $ '602/605'				// V.C Adiantamento/Pagto. Antecipado
	         cEvento := If(EEQ->EEQ_FASE $ 'C', If(nVariacao > 0, "590","591"), If(nVariacao > 0, "594","595"))
	      Elseif EEQ->EEQ_EVENT $ '101/603'             // V.C Invoice
	         IF EEQ->EEQ_TIPO # 'A' .AND. EEQ->EEQ_TIPO # 'P'
	            IF nVariacao > 0
   	            cEvento := "582"
   	          ELSE
   	            cEvento := "583"   	            
	            ENDIF
	          ELSE
	            IF EEQ->EEQ_FAOR = 'C'
	               IF nVariacao > 0
   	               cEvento := "590"
   	             ELSE
   	               cEvento := "591"   	            
	               ENDIF	            
	             ELSE
	               IF nVariacao > 0
   	               cEvento := "594"
   	             ELSE
   	               cEvento := "595"   	            
	               ENDIF	            	             
	            ENDIF 
            ENDIF    
// 	         cEvento := IF(EEQ->EEQ_TIPO # 'A' .AND. EEQ->EEQ_TIPO # 'P',If(nVariacao > 0, "582","583"),IF(nVariacao > 0, "594","595")) // MJA 01/09/04            
	      Endif
	      // V.C
//Nick 20/04/06	      AAdd(aDadosPRV, {nVariacao, cEvento, "", EEQ->EEQ_NRINVO, cEvento, dDta_Emb, cMoeda, If(l607,nTxDiaLiq,nTxFimMes), nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), cProcOr, cFaseOr, cParcOr, "", dDta_Fim, 0, 0,EEQ->EEQ_VL,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ})
	      AAdd(aDadosPRV, {nVariacao, cEvento, "", EEQ->EEQ_NRINVO, cEvento,If(EEQ->EEQ_TIPO = "A",dDta_Emb,EEQ->EEQ_PGT), cMoeda, If(l607,IF(EEQ->EEQ_TIPO = 'A',nTaxAux,nTxDiaLiq),nTxFimMes), nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), cProcOr, cFaseOr, cParcOr, "", dDta_Fim, 0, 0,EEQ->EEQ_VL,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
	      
          // ** AAF 16/10/09 - Gerar o 582/583 para acertar a variacao do processo
          If EEQ->EEQ_EVENT == '603' .AND. dDta_Emb < dDta_Ini
             AAdd(aDadosPRV,{nVariacao, If(nVariacao > 0, "582","583"), "", EEQ->EEQ_NRINVO,If(nVlrReais > 0, "582","583"),dDta_Emb, cMoeda, If(l607,IF(EEQ->EEQ_TIPO = 'A',nTaxAux,nTxDiaLiq),nTxFimMes), nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), cProcOr, cFaseOr, cParcOr, "", dDta_Fim, 0, 0,EEQ->EEQ_VL,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
          EndIf	      
       Endif
	
	   // Grava as Variacoes e eventos na prévia, ja rateando se necessario
	   If Len(aDadosPRV) > 0
	      PExp999_PrvRat(aDadosPRV)
	   Endif
	
	          
	   If cPrv_Efe = "2"
	      If nRecAuxEEQ <> 0
	         EEQ->(DBGOTO(nRecAuxEEQ))
	      Else
	         EEQ->(DbSeek(cFilEEQ+Space(Len(EEQ->EEQ_NR_CON)),.T.))
	      EndIf
	   Else
	      EEQ->(DbSkip())
	   Endif
	Enddo

Next nTpNrCont

// Le Pagamentos
EEQ->(DbSetOrder(9))
oProcess:SetRegua2(nTotEEQ2)

EEQ->(DbSeek(cFilEEQ+Dtos(dDta_Ini),.T.))
Do While EEQ->(!EOF()) .And. EEQ->EEQ_FILIAL == cFilEEQ .And. EEQ->EEQ_PGT <= dDta_Fim
   
   //ER - 23/01/2007
   If EasyEntryPoint("ECOPF999")
      lRetPE := ExecBlock("ECOPF999",.F.,.F.,"READPAG")
      If ValType(lRetPE) == "L" .and. lRetPE
         EEQ->(DbSkip())
         Loop   
      EndIf
   EndIf
      
   if EEQ->EEQ_EVENT $ cMV_EVEEXCL // VI 13/12/05
      EEQ->(DBSKIP())
      LOOP
   ENDIF

	   IF lBackTo // VI 01/07/05
	      if AP106isBackto(EEQ->EEQ_PREEMB,OC_EM) 
	         EEQ->(DBSKIP())
	         LOOP
	      endif
	   ENDIF

   IF EEQ->EEQ_EVENT = "101" .AND. (EEQ->EEQ_PGT < dDta_Ini .OR. EEQ->EEQ_PGT > dDta_Fim) // MJA 28/07/05
      EEQ->(DbSkip())                                                                     // MJA 28/07/05
      LOOP
   ENDIF                                                                                  // MJA 28/07/05
   aDadosPrv := {}
   oProcess:IncRegua2("2 / 4 "+STR0029+Alltrim(EEQ->EEQ_PREEMB)+' Inv: '+Alltrim(EEQ->EEQ_NRINVO)) //"Contrato: "

   If lEnd
      If lEnd:=MsgYesNo(STR0097,STR0098)
         Return .F.
      EndIf
   EndIf

   // Despesas
   nPos := Ascan(aProcDesp, EEQ->EEQ_PREEMB)
   If nPos = 0
      If lTemEETNew
         PRDESP999(EEQ->EEQ_PREEMB, EEQ->EEQ_NRINVO)
      Endif
      AAdd(aProcDesp, EEQ->EEQ_PREEMB)
   Endif

   // Contabiliza Adiantamento caso mesmo esteja liquidado
   IF EEQ->EEQ_FASE $ 'E/C/P' .And. EEQ->EEQ_TIPO $ 'A' .And. EEQ->EEQ_EVENT $ '605/602/101' ;
      .And. (Empty(EEQ->EEQ_PGT) .OR. (EEQ->EEQ_FASE $ 'E' .And. EEQ->EEQ_TIPO $ 'A' .And. EEQ->EEQ_EVENT $ '101' .AND. !Empty(EEQ->EEQ_PGT))) // MJA 01/09/04
      EEQ->(DbSkip())
      Loop
   Endif

   // Data de Embarque
   EEC->(DbSeek(cFilEEC+EEQ->EEQ_PREEMB))
//   If EEC->EEC_COBCAM $ cNao .or. EEC->EEC_MPGEXP = '006' .OR. (EEC->EEC_STATUS = '*' .and. !Empty(EEC->EEC_FIM_PE) .and. EEC->EEC_FIM_PE < dDta_Ini)
   If EEC->EEC_MPGEXP = '006' .OR. (EEC->EEC_STATUS = '*' .and. !Empty(EEC->EEC_FIM_PE) .and. EEC->EEC_FIM_PE < dDta_Ini)   // MJA 24/05/05 Para calcular mesmo sem cobertura cambial
      EEQ->(DbSkip())
      Loop                                                                  
   EndIf

   ECG->(DbSeek(cFilECG+cTPMODU+'EX'+EEQ->EEQ_PREEMB))

   dDta_Emb := EEC->EEC_DTEMBA
   
// Erro, verificar qual a real necessidade deste IF e modificá-lo    MJA 09/08/05
   If (!EEQ->EEQ_EVENT $ '101/121/102/103/120/122' .and. LEFT(EEQ->EEQ_EVENT,1) $ '3/4') .Or. !EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT","")+EEQ->EEQ_EVENT)) .Or. ;
      EEQ->EEQ_NR_CON = STRZERO(nNR_Cont+1,4,0) .Or. (Empty(EEQ->EEQ_NR_CON) .And. If(!Empty(dDta_Emb), (dDta_Emb >= dDta_Ini .And. dDta_Emb <= dDta_Fim), .T.))
      EEQ->(DbSkip())
      Loop
   EndIf
// --------------------------------------------------------------   
   
   IF EEQ->EEQ_EVENT $ '120/121/122' .and. lComiss .AND. (EEQ->EEQ_PGT >= dDta_Ini .and. EEQ->EEQ_PGT <= dDta_Fim)// MJA 03/08/05
      CALC_COMISS("IN",nResFinal)
      EEQ->(DBSKIP())
      LOOP
   ENDIF
	   
   if EEQ->EEQ_EVENT $ '102/103/127' .and. lFESEOD .AND. (EEQ->EEQ_PGT >= dDta_Ini .and. EEQ->EEQ_PGT <= dDta_Fim) // MJA 03/08/05
      CALC_FSOD("IN",nResFinal)
      EEQ->(DBSKIP())
      LOOP
   endif
   
/*
   If EEQ->EEQ_EVENT # '101' .Or. !EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT","")+EEQ->EEQ_EVENT)) .Or. ;
      (Empty(EEQ->EEQ_NR_CON) .And. If(!Empty(dDta_Emb), (dDta_Emb >= dDta_Ini .And. dDta_Emb <= dDta_Fim), .T.))
      EEQ->(DbSkip())
      Loop
   EndIf
*/


   nValInv := 0

   // Definição da moeda
   cMoeda := EEC->EEC_MOEDA

// VI 17/12/05

   If !lVcAv // AAF 10/03/08 - Verificar se o parâmetro está desativado.
      If !Empty(EEQ->EEQ_NRINVO) .And. EF3->(DbSeek(cFilEF3+IF(lEFFTpMod,cTipoModu,"")+EEQ->EEQ_NRINVO+EEQ->EEQ_PARFIN+'630')) .And.;
         EEQ->EEQ_EVENT = '101' .And. EEQ->EEQ_FASE $ 'E' .And. (Empty(Alltrim(EEQ->EEQ_TIPO)) .Or. (!Empty(Alltrim(EEQ->EEQ_TIPO)) .AND. EEQ->EEQ_TIPO = 'R')) // MJA 28/09/04
         Do While EF3->(!Eof()) .And. EF3->EF3_FILIAL = cFilEF3 .And.  ;
                  EF3->EF3_INVOIC = EEQ->EEQ_NRINVO .And. EF3->EF3_PARC = EEQ->EEQ_PARFIN .And. EF3->EF3_CODEVE = '630'
            IF EF3->EF3_DT_EVE = EEQ->EEQ_PGT  // MJA 19/08/05 Para buscar apenas a parcela realmente para para o mes.    
               nValInv += EF3->EF3_VL_MOE
            ENDIF   
            EF3->(DbSkip())
         EndDo
      EndIF
   EndIf
   
   If (EEQ->EEQ_VL - nValInv) <= 0 // VI 23/04/05
      AAdd(aDadosPRV, { 0, '607', "", EEQ->EEQ_NRINVO, '607', EEQ->EEQ_PGT, cMoeda, EEQ->EEQ_TX, 0, EEQ->EEQ_PARC, " ", 'EMB', EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), EEQ->EEQ_PROR, EEQ->EEQ_FAOR, EEQ->EEQ_PAOR, "", "",0,0, EEQ->EEQ_VL,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
      PExp999_PrvRat(aDadosPRV)
      EEQ->(DbSkip())
      Loop
   EndIf

   // Efetivacao
   If cPrv_Efe = "2" .And. Empty(EEQ->EEQ_NR_CON) // .and. (EEC->EEC_DTEMBA >= dDta_Ini .AND. EEC->EEC_DTEMBA <= dDta_Fim) // MJA 29/07/05 Coloquei esta consistencia para não barrar o calculo da VC nos embarques fora do periodo.
      Reclock('EEQ',.F.)
      EEQ->EEQ_NR_CON := STRZERO(nNR_Cont+1,4,0)
      EEQ->(MSUNLOCK())
   Endif

   cTipo := 'EXP'

   EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT","")+'101')) 
   cTX_101 := EC6->EC6_TXCV      

   //Taxas
   nTxDiaLiq := EEQ->EEQ_TX
   nTxFimMes := ECOEXP999Tx(cMoeda, dDta_Fim, cTX_101 )
   nTxIniMes := ECOEXP999Tx(cMoeda, dDta_Ini, cTX_101 )
   nTxEmb    := ECOEXP999Tx(cMoeda, dDta_Emb, cTX_101 )
   
   
   If dDta_Emb <= dDta_Fim .And. dDta_Emb >= dDta_Ini 
      nTxMesAnt := nTxEmb
   ElseIf !Empty(ECG->ECG_ULT_TX)
      nTxMesAnt := ECG->ECG_ULT_TX
   Else
      nTxMesAnt := nTxIniMes
   EndIf

   nVlrReais := (EEQ->EEQ_VL - nValInv - EEQ->EEQ_CGRAFI) * nTxDiaLiq
   if nVlrReais < 0
      nVlrReais := 0
   endif   

   // Gera Evento de Pagamento

   
   If nVlrReais <> 0  // VI 23/04/05
      AAdd(aDadosPRV,    {nVlrReais, '607', "", EEQ->EEQ_NRINVO, '607', EEQ->EEQ_PGT, cMoeda, nTxDiaLiq, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), EEQ->EEQ_PROR, EEQ->EEQ_FAOR, EEQ->EEQ_PAOR, "", "",0,0,(EEQ->EEQ_VL - nValInv - EEQ->EEQ_CGRAFI),IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
      //If nVlrReais <> 0  // VI 23/04/05 -> Nick 26/10/06 - Nopei pois estava duplicando o lancamento com um valor zerado
      //   AAdd(aDadosPRV, { 0       , '607', "", EEQ->EEQ_NRINVO, '607', EEQ->EEQ_PGT, cMoeda, nTxDiaLiq, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), EEQ->EEQ_PROR, EEQ->EEQ_FAOR, EEQ->EEQ_PAOR, "", "",0,0,               nValInv ,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
      //EndIf
   Else      
      AAdd(aDadosPRV,    { 0       , '607', "", EEQ->EEQ_NRINVO, '607', EEQ->EEQ_PGT, cMoeda, nTxDiaLiq, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), EEQ->EEQ_PROR, EEQ->EEQ_FAOR, EEQ->EEQ_PAOR, "", "",0,0, EEQ->EEQ_VL-EEQ->EEQ_CGRAFI,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
   EndIf

   if lRegBox
//VI 25/07/05      nVariacao := ((EEQ->EEQ_VL-If(lVcAv,0,nValInv)-EEQ->EEQ_CGRAFI) * nTxDiaLiq) - ((EEQ->EEQ_VL-If(lVcAv,0,nValInv)-EEQ->EEQ_CGRAFI) * nTxEmb)
//------------------------------------------------------------ MJA 24/08/05
       nRecECF := ECF->(Recno())
       nIndECF := ECF->(INDEXORD())
       nTxRC := nTxEmb
       ECF->(DBSETORDER(9))
       ECF->(DBSEEK(cFilECF+'EXPORT'+'EX'+EEQ->EEQ_PREEMB+' '+EEQ->EEQ_NRINVO+AvKey(EEQ->EEQ_PARC,"ECF_SEQ")+'101'))
       IF ECF->(!EOF())
          nTxRC := ECF->ECF_PARIDA
       ENDIF
       ECF->(DBSETORDER(nIndECF))
       ECF->(DBGOTO(nRecECF))
//------------------------------------------------------------

      nVariacao := ((EEQ->EEQ_VL-If(lVcAv,0,nValInv)) * nTxDiaLiq) - ((EEQ->EEQ_VL-If(lVcAv,0,nValInv)) * nTxRC)
      cEvento   := If(nVariacao > 0, "589","588")
      // V.C do Pagamento
//      If nVariacao <> 0
         //AAdd(aDadosPRV, {nVariacao, cEvento, "", EEQ->EEQ_NRINVO, cEvento, dDta_Fim, cMoeda, nTxDiaLiq, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), "", "", "", "", dDta_Fim, EEQ->EEQ_VL-If(lVcAv,0,nValInv),0,EEQ->EEQ_VL,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
         AAdd(aDadosPRV, {nVariacao, cEvento, "", EEQ->EEQ_NRINVO, cEvento, EEQ->EEQ_PGT, cMoeda, nTxDiaLiq, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), "", "", "", "", dDta_Fim, EEQ->EEQ_VL-If(lVcAv,0,nValInv),0,EEQ->EEQ_VL,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""}) //ER - 18/10/2007
//      Endif
        ZERACON(EEQ->EEQ_PREEMB,EEQ->EEQ_PARC,EEQ->EEQ_TX,EEQ->EEQ_VL,dDta_Fim,nTxRC,nTxMesAnt,nVariacao,EEQ->EEQ_FASE)
   Endif
   // V.C. Recebimento / Adiantamento / Pagamento Cliente
//VI 25/07/05   nVariacao := ((EEQ->EEQ_VL - If(lVcAv,0,nValInv)-EEQ->EEQ_CGRAFI) * nTxDiaLiq) - ((EEQ->EEQ_VL - If(lVcAv,0,nValInv)-EEQ->EEQ_CGRAFI) * nTxMesAnt) // VI 23/04/05
   IF EEC->EEC_DTEMBA < dDta_Ini .And. (Empty(EEQ->EEQ_NR_CON) .OR. EEQ->EEQ_NR_CON = STRZERO(nNR_Cont+1,4,0)) // para verificar dt embarque dentro do mes com data anterior.// MJA 02/09/05
      nTxOk := nTxEmb
     ELSE
      nTxOk := nTxMesAnt      
   ENDIF
//   nVariacao := ((EEQ->EEQ_VL - If(lVcAv,0,nValInv)) * nTxDiaLiq) - ((EEQ->EEQ_VL - If(lVcAv,0,nValInv)) * nTxMesAnt) // VI 23/04/05
   nVariacao := ((EEQ->EEQ_VL - If(lVcAv,0,nValInv)) * nTxDiaLiq) - ((EEQ->EEQ_VL - If(lVcAv,0,nValInv)) * nTxOk) // VI 23/04/05 MJA 02/09/05
   cEvento   := If(nVariacao > 0, "582","583")
   // V.C do Pagamento
   // Retirou-se a validação para não contabilizar VC zerada     MJA 24/08/05
//   If nVariacao <> 0 .and. !EMPTY(EEQ->EEQ_PGT) //  (!(EEC->EEC_DTEMBA >= dDta_Ini .AND. EEC->EEC_DTEMBA <= dDta_Fim) .AND. !(EMPTY(EEQ->EEQ_NR_CON) .Or. val(EEQ->EEQ_NR_CON) = (nNR_Cont+1)))  // nVariacao <> 0 .and. (!(EEC->EEC_DTEMBA >= dDta_Ini .AND. EEC->EEC_DTEMBA <= dDta_Fim) .AND. !(EMPTY(EEQ->EEQ_NR_CON) .Or. val(EEQ->EEQ_NR_CON) = (nNR_Cont+1)))// .OR. !EMPTY(EEQ->EEQ_PGT)) // MJA 28/07/05 Alterei para mostrar a data da liquidação
   If !EMPTY(EEQ->EEQ_PGT) //  (!(EEC->EEC_DTEMBA >= dDta_Ini .AND. EEC->EEC_DTEMBA <= dDta_Fim) .AND. !(EMPTY(EEQ->EEQ_NR_CON) .Or. val(EEQ->EEQ_NR_CON) = (nNR_Cont+1)))  // nVariacao <> 0 .and. (!(EEC->EEC_DTEMBA >= dDta_Ini .AND. EEC->EEC_DTEMBA <= dDta_Fim) .AND. !(EMPTY(EEQ->EEQ_NR_CON) .Or. val(EEQ->EEQ_NR_CON) = (nNR_Cont+1)))// .OR. !EMPTY(EEQ->EEQ_PGT)) // MJA 28/07/05 Alterei para mostrar a data da liquidação   
      AAdd(aDadosPRV, {nVariacao, cEvento, "", EEQ->EEQ_NRINVO, cEvento, IF(!EMPTY(EEQ->EEQ_PGT),EEQ->EEQ_PGT,dDta_Fim), cMoeda, nTxDiaLiq, nTxOk, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), cTipo, EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), "", "", "", "", dDta_Fim, (EEQ->EEQ_VL - If(lVcAv,0,nValInv)),0,EEQ->EEQ_VL,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""}) // MJA 28/07/05
   Endif
   
   // Grava as Variacoes e eventos na prévia, ja rateando se necessario
   If Len(aDadosPRV) > 0
      PExp999_PrvRat(aDadosPRV)
   Endif

   EEQ->(DbSkip())
Enddo

// Le o ECG / ECF para gerar variações cambiais do pag. antecipado / adiantamento / Contabilidade Exportação
oProcess:SetRegua2(nTotECG)
EF3->(DbSetOrder(2))
//EEQ->(DbSetOrder(5))
          
ECG->(DbSeek(cFilECG+cTPMODU+'EX', .T.))

Do While ECG->(!EOF()) .And. ECG->ECG_FILIAL == cFilECG .And. ECG->ECG_ORIGEM = 'EX' .And. Eval(bTPMODUECG)

   oProcess:IncRegua2("3 / 4 "+STR0029+Alltrim(ECG->ECG_PREEMB)) //"Contrato: "
   aProcessos := {} 
   nAdiantEmb:= 0 // Nick 26/04/06
   cProcesso := ECG->ECG_PREEMB

   If lEnd
      If lEnd:=MsgYesNo(STR0097,STR0098) 
         Return .F.
      EndIf
   EndIf
   
   // ** AAF - 09/04/08 - Ignora os processos encerrados manualmente.
   If !Empty(ECG->ECG_DTENCE)
	  ECG->(DBSKIP())
	  LOOP      
   EndIf
   // **
   
   IF lBackTo // VI 01/07/05
	  if AP106isBackto(ECG->ECG_PREEMB,OC_EM) 
	     ECG->(DBSKIP())
	     LOOP
	  endif
   ENDIF

   // Datas Auxiliares
   dDta_FimAux := dDta_Fim
   dDta_IniAux := dDta_Ini
      
   // Inicializa Array
   aRecebe   := {}
   aBaixa    := {}
   aDadosPrv := {}
   nVc101    := 0
   nPagCli   := 0
   nDesconto := 0
   nContaGra := 0 // MJA 05/08/05
      
   // Localiza o Processo
   EEC->(DbSeek(cFilEEC+cProcesso))
//   If EEC->EEC_COBCAM $ cNao .or. EEC->EEC_MPGEXP = '006' .OR. (EEC->EEC_STATUS = '*' .and. !Empty(EEC->EEC_FIM_PE) .and. EEC->EEC_FIM_PE < dDta_Ini)
   If (EEC->EEC_STATUS = '*' .and. !Empty(EEC->EEC_FIM_PE) .and. EEC->EEC_FIM_PE < dDta_Ini)   // MJA 24/05/05 Para calcular mesmo sem cobertura cambial
      ECG->(DbSkip())
      Loop   
   EndIf

   cMoeda := EEC->EEC_MOEDA   

// If EEC->EEC_STATUS = '*' .and. !Empty(EEC->EEC_FIM_PE) .and. EEC->EEC_FIM_PE >= dDta_Ini .and. EEC->EEC_FIM_PE <= dDta_Fim   // VI 19/08/03
   If ! EEC->EEC_COBCAM $ cNao .AND. EEC->EEC_MPGEXP # '006' .And. EEC->EEC_STATUS = '*' .and. !Empty(EEC->EEC_FIM_PE) .and. EEC->EEC_FIM_PE >= dDta_Ini .and. EEC->EEC_FIM_PE <= dDta_Fim   // VI 01/08/05 MJA 19/08/05
      If ECF->(DbSeek(cFilECF+cTPMODU+'EX'+cProcesso+Space(Len(ECF->ECF_FASE))+AvKey(EEC->EEC_NRINVO,"ECF_INVEXP")+Space(Len(ECF->ECF_SEQ))+"107"))   
         Do While ! ECF->(Eof()) .and. cProcesso = ECF->ECF_PREEMB .and. ECF->ECF_ID_CAM = '107' .And. Eval(bTPMODUECF)
            nVariacao := ECF->ECF_VALOR - (ECF->ECF_VL_MOE * ECG->ECG_ULT_TX)
//            If nVariacao <> 0 //    1                       2                3          4                       5                        6            7            8               9              10               11        12       13           14       15  16  17  18       19               20              21      22         23      24 25 26 27    28
               AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, "580", "581"), "", ECF->ECF_INVEXP, If(nVariacao > 0, "580", "581"), EEC->EEC_FIM_PE, cMoeda, ECF->ECF_PARIDA, ECG->ECG_ULT_TX, ECF->ECF_SEQ, ECF->ECF_IDENTC, 'VC', cProcesso, ECF->ECF_FASE, "", "", "", "", ECF->ECF_NRNF, EEC->EEC_FIM_PE, ECF->ECF_VL_MOE, 0,0,ECF->ECF_FORN,ECF->ECF_TP_FOR,"","",cFilECF,""})
//            Endif
            ECF->(DBSKIP())
         EndDo
      EndIf
      If Len(aDadosPRV) > 0
         PExp999_PrvRat(aDadosPRV)
      Endif
      ECG->(DbSkip())
      Loop   
   EndIf
      
   // Taxas
   
   EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT","")+'101')) 
   cTX_101 := EC6->EC6_TXCV      

   nTxMesAnt := If(!Empty(ECG->ECG_ULT_TX), ECG->ECG_ULT_TX, ECOEXP999Tx(EEC->EEC_MOEDA, dDta_Ini, cTX_101))  // Mes Anterior
   nTxEmb    := ECOEXP999Tx(EEC->EEC_MOEDA, EEC->EEC_DTEMBA, cTX_101 )                                        // Taxa Embarque
      
   // Gera V.C. até a data de embarque
   lTemEmbPer := .F.
   If !Empty(EEC->EEC_DTEMBA)
      If EEC->EEC_DTEMBA >= dDta_Ini .And. EEC->EEC_DTEMBA <= dDta_Fim
         ECF->(DbSeek(cFilECF+cTPMODU+'EX'+cProcesso+Space(Len(ECF->ECF_FASE))+AvKey(EEC->EEC_NRINVO,"ECF_INVEXP")+Space(Len(ECF->ECF_SEQ))+"101"))
         If ECF->(EOF()) .OR. ECF->ECF_NR_CON = STRZERO(nNR_Cont+1,4,0)
            dDta_FimAux := EEC->EEC_DTEMBA
            lTemEmbPer  := .T.
         EndIf
      else // MJA 13/07/05 Aqui verifica se há embarque fora do período para calcular corretamente a VC da invoice        
         DbSelectArea("ECF")
         ECF->(DbSetOrder(9))
         ECF->(DbSeek(cFilECF+cTPMODU+"EX"+EEC->EEC_PREEMB))
         Do While ! ECF->(EOF()) .AND. (xFilial("EEC") = cFilECF) .AND. (ECF_ORIGEM == "EX") .AND. (ECF->ECF_PREEMB == EEC->EEC_PREEMB)// .AND. !lAchou
            IF ECF->ECF_ID_CAM = '101' .And. ECF->ECF_TIPO <> "A"  // VI 31/07/05    VERIFICAR O NR_CONT
               lTemEmbPer  := .F.
            ENDIF
            ECF->(DbSkip())
         EndDo
      Endif
   Endif
   // Verifica no ECA os recebimentos / baixas geradas neste período quando for prévia
   If lTemECANew //.And. lLeEca //cPrv_Efe = "1" 

      // Acumula Recebimentos (Adiantamentos) do processos
      ECA->(DbSeek(cFilECA+'EXPORT'+cProcesso))
	  Do While ECA->(!EOF()) .And. ECA->ECA_FILIAL == cFilECA .And. ECA->ECA_TPMODU = 'EXPORT' .And. ;
		 ECA->ECA_PREEMB = cProcesso

         cPremeb   := ECA->ECA_PREEMB
         cInvoice  := ECA->ECA_INVEXP
         cParcela  := ECA->ECA_SEQ
         cFase     := ECA->ECA_FASE
         cMoeda    := ECA->ECA_MOEDA
         cParc101  := ECA->ECA_SEQ
         cProc101  := ECA->ECA_PREEMB
         cFase101  := ECA->ECA_FASE
         cIdentc   := ECA->ECA_IDENTC
         cIdentc101:= ECA->ECA_IDENTC
         cClie     := ECA->ECA_FORN // MJA 09/05/05
         cTpCl     := ECA->ECA_TP_FOR // MJA 09/05/05
         nAdiantAnt:= 0 // Nick 25/04/06
         cEv101    := ECA->ECA_ID_CAM  //LRS 

         // Taxas
         nTxFimMes    := ECOEXP999Tx(cMoeda, dDta_Fim, cTX_101)
         nTxIniMes    := ECOEXP999Tx(cMoeda, dDta_Ini, cTX_101)
            
         Do While ECA->(!EOF()) .And. ECA->ECA_FILIAL == cFilECA .And. ECA->ECA_TPMODU = 'EXPORT' .And. ;
            ECA->ECA_PREEMB = cProcesso .And. ECA->ECA_INVEXP = cInvoice  .And. ;
            ECA->ECA_FASE = cFase // .And. ECA->ECA_SEQ = cParcela

            If ECA->ECA_TIPO <> 'A'
               If ECA->ECA_ID_CAM $ "602/605"
                  nPos := Ascan(aRecebe,{|x| x[1]=ECA->ECA_PREEMB .And. x[2]=ECA->ECA_INVEXP .And. x[3]=ECA->ECA_SEQ .And. x[4]=ECA->ECA_FASE})
                  If nPos > 0
                     aRecebe[nPos,5] += ECA->ECA_VALOR / ECA->ECA_TX_USD
                  Else
                     AAdd(aRecebe, {ECA->ECA_PREEMB, ECA->ECA_INVEXP, AVKEY(ECA->ECA_SEQ, "ECF_SEQ"), ECA->ECA_FASE, ECA->ECA_VALOR  / ECA->ECA_TX_USD, ECA->ECA_MOEDA, ECA->ECA_DT_CON,ECA->ECA_FORN, ECA->ECA_TP_FOR })
                  Endif

               Elseif ECA->ECA_ID_CAM $ "101"          // Cambio
                  nVc101    += ECA->ECA_VALOR / ECA->ECA_TX_USD
                  cParc101  := ECA->ECA_SEQ
               	  cProc101  := ECA->ECA_PREEMB
               	  cFase101  := ECA->ECA_FASE
               	  cIdentc101:= ECA->ECA_IDENTC
               Elseif ECA->ECA_ID_CAM $ "607"          // Pagamento Cliente
                  If ECA->ECA_VL_MOE <> 0 .And. ECA->ECA_VALOR = 0
                     nVc101 -= ECA->ECA_VL_MOE            
                  Else
                     nVc101 -= ECA->ECA_VALOR / ECA->ECA_TX_USD                                 
                  EndIf
                  nPagCli   += ECA->ECA_VALOR / ECA->ECA_TX_USD
               Elseif ECA->ECA_ID_CAM $ "801"          // Descontos
                  nVc101    -= ECA->ECA_VALOR / ECA->ECA_TX_USD
                  nDesconto += ECA->ECA_VALOR / ECA->ECA_TX_USD
               Elseif ECA->ECA_ID_CAM $ "802"          // Devolução  MJA 25/08/04
                  nVc101    -= ECA->ECA_VALOR / ECA->ECA_TX_USD
                  nDesconto += ECA->ECA_VALOR / ECA->ECA_TX_USD
               Elseif ECA->ECA_ID_CAM $ "121/124"          //   MJA 04/08/05 Deduzir a Conta Grafica da Invoice
                  // nVc101    -= ECA->ECA_VALOR / ECA->ECA_TX_USD // MJA 05/08/05 
                  IF ECA->ECA_ID_CAM = '121'
                     nContaGra := ECA->ECA_VALOR / ECA->ECA_TX_USD // MJA 05/08/05
                   ELSE
                     nContaGra += ECA->ECA_VALOR / ECA->ECA_TX_USD // MJA 05/08/05             
                  ENDIF   
               Endif
            Endif

            IF ECA->ECA_ID_CAM $ "112/116/117"  // Adiantamento // Nick 25/04/06
               nAdiantAnt += ECA->ECA_VL_MOE
            Endif
            cClie := ECA->ECA_FORN // MJA 09/05/05
            cTpCl := ECA->ECA_TP_FOR // MJA 09/05/05

            ECA->(DbSkip())
         Enddo      
         
         // Agrupas as invoices para Gerar V.C
         IF cEv101 $ "101" //LRS 
            nPos := Ascan(aProcessos,{|x| x[1]=cInvoice})
            If nPos = 0
               AAdd(aProcessos, {cInvoice, nVc101, cClie, cTpCl, cMoeda}) // VI 24/07/05
            Else
               aProcessos[nPos,2] += nVc101
            Endif
         EndIF

         // Somar o valor dos adiantamentos do embarque   Nick 26/04/2006
         nAdiantEmb += nAdiantAnt

         nVC101 := 0  // Zera Variavel

      Enddo   
         
      // Acumula Baixas / Liquidações processos 
      nRecnoECA := ECA->(Recno())
      nIndexECA := ECA->(IndexOrd())
      ECA->(DbSetOrder(12))
         
      ECA->(DbSeek(cFilECA+'EXPORT'+cProcesso))
      Do While ECA->(!EOF()) .And. ECA->ECA_FILIAL == cFilECA .And. ECA->ECA_TPMODU = 'EXPORT' .And. ;
		 ECA->ECA_PROR = cProcesso
	    
		 cInvoice := ECA->ECA_INVEXP
         cParcela := ECA->ECA_PAOR
         cFase    := ECA->ECA_FAOR

         Do While ECA->(!EOF()) .And. ECA->ECA_FILIAL == cFilECA .And. ECA->ECA_TPMODU = 'EXPORT' .And. ;
            ECA->ECA_PROR = cProcesso .And. ECA->ECA_INVEXP = cInvoice .And. ECA->ECA_PAOR = cParcela .And. ;
            ECA->ECA_FAOR = cFase
               
               
            If ECA->ECA_TIPO $ 'A' .And. ECA->ECA_ID_CAM $ "602/605/607"                                                            
               nPos := Ascan(aBaixa,{|x| x[1] = ECA->ECA_PROR .And. x[2] = ECA->ECA_INVEXP .And. x[3] = ECA->ECA_FAOR  .And. x[4] = ECA->ECA_PAOR })
               If nPos > 0
                  aBaixa[nPos,5] += ECA->ECA_VALOR  / ECA->ECA_TX_USD        // Baixa
                  aBaixa[nPos,6] += ECA->ECA_VALOR  / ECA->ECA_TX_USD        // Transferência no mês
               Else
                  AAdd(aBaixa, {ECA->ECA_PROR, ECA->ECA_INVEXP, ECA->ECA_FAOR, ECA->ECA_PAOR, ECA->ECA_VALOR / ECA->ECA_TX_USD, ECA->ECA_VALOR , ECA->ECA_MOEDA, ECA->ECA_DT_CON })
               Endif
            Endif
            ECA->(DbSkip())
         Enddo
      Enddo

      // Retorna ao registro e Indice anterior
      ECA->(DbSetOrder(nIndexECA))
      ECA->(DbGoto(nRecnoECA))

   Endif
   aNFsProc := {} // VI 17/12/05
   // Localiza as variações ja geradas no ECF
   ECF->(DbSeek(cFilECF+cTPMODU+'EX'+cProcesso))
   Do While ECF->(!EOF()) .And. ECF->ECF_FILIAL == cFilECF .And. ECF->ECF_ORIGEM = 'EX' .And. ;
      ECF->ECF_PREEMB = cProcesso .And. Eval(bTPMODUECF)

      // Se for registro deste mes ignora pois ja foi contabilizado pelo ECA
      If ECF->ECF_NR_CON = STRZERO(nNR_Cont+1,4,0)
         ECF->(DbSkip())
         Loop
      Endif      
      cPreemb  := ECF->ECF_PREEMB
      cInvoice := ECF->ECF_INVEXP
      cParcela := AvKey(ECF->ECF_SEQ, "ECF_PAOR")
      cMoeda   := ECF->ECF_MOEDA
      cIdentc  := ECF->ECF_IDENTC
      cFase    := If(lTemECFNew, ECF->ECF_FASE, "")
      cTipo    := If(lTemECFNew, If(ECF->ECF_FASE = 'C', 'CLI', 'PED'), "")
      cProcOr  := ""
	   cParcOr  := ""
	   cFaseOr  := ""
	   cParc101  := ECF->ECF_SEQ
      cProc101  := ECF->ECF_PREEMB
      cFase101  := ECF->ECF_FASE
      cIdentc101:= ECF->ECF_IDENTC
      nAdiantAnt:= 0 // Nick 25/04/06
      cEv101    := ECF->ECF_ID_CAM  //LRS 
      
      nVlTransf := 0

      // Acumula Recebimentos (Adiantamentos) dos processos
      Do While ECF->(!EOF()) .And. ECF->ECF_FILIAL == cFilECF .And. ECF->ECF_ORIGEM = 'EX' .And. ;
         ECF->ECF_PREEMB = cProcesso .And. ECF->ECF_INVEXP = cInvoice .And. ECF->ECF_SEQ = cParcela .And. ;
         ECF->ECF_FASE = cFase .And. Eval(bTPMODUECF)
         
         // Se for registro deste mes ignora pois ja foi contabilizado pelo ECA
         If ECF->ECF_NR_CON = STRZERO(nNR_Cont+1,4,0)  // VI 01/12/05
            ECF->(DbSkip())
            Loop
         Endif                  

         // VI 17/12/05   Para não gerar duplicidade.
         If Empty(Alltrim(ECF->ECF_NRNF))
            lNFsDif := .F.
         Else
            lNFsDif := If(Ascan(aNFsProc,{|x| x == ECF->ECF_ID_CAM+"-"+ECF->ECF_NRNF})>0,.F.,.T.)
         EndIf
         If lNFsDif 
            AAdd(aNFsProc,ECF->ECF_ID_CAM+"-"+ECF->ECF_NRNF)
         Endif

         // Taxas
         cMoeda   := ECF->ECF_MOEDA
         nTxFimMes    := ECOEXP999Tx(cMoeda, dDta_Fim, cTX_101)
         nTxIniMes    := ECOEXP999Tx(cMoeda, dDta_Ini, cTX_101)
         If ! Empty(EEC->EEC_DTEMBA) .And. EEC->EEC_DTEMBA >= dDta_Ini .And. EEC->EEC_DTEMBA <= dDta_Fim // VI 31/07/05
            nTxEmb    := ECOEXP999Tx(cMoeda, EEC->EEC_DTEMBA, cTX_101 )                                        // Taxa Embarque
         EndIf         
         aVcAnt := {}
         
         // Contabiliza evento de estorno
         If Empty(ECF->ECF_NR_CON) .And. ECF->ECF_DTCONT >= dDta_Ini .And. ECF->ECF_DTCONT <= dDta_Fim
            AAdd(aDadosPRV, {ECF->ECF_VALOR, ECF->ECF_ID_CAM, "", ECF->ECF_INVEXP, ECF->ECF_LINK, ECF->ECF_DTCONT, ECF->ECF_MOEDA, ECF->ECF_PARIDA, ECF->ECF_FLUTUA, ECF->ECF_SEQ, ECF->ECF_IDENTC, 'VC', ECF->ECF_PREEMB, ECF->ECF_FASE, "", "", "", "", ECF->ECF_NRNF, ECF->ECF_DTCONT, 0, 0,0,"","","","",cFilECF,""})
            If cPrv_Efe = "2"      // Efetivacao
               Reclock("ECF", .F.)
               ECF->ECF_NR_CON := STRZERO(nNR_Cont+1,4,0)
               ECF->(MsUnlock())
            Endif
         Endif


//  Estava a rotina If ECF->ECF_NR_CON = STRZERO(nNR_Cont+1,4,0) ...

         // V.C do Frete dos meses anteriores apos Embarque
         
        If ECF->ECF_ID_CAM $ '102' .And. (ECF->ECF_DTCONT < dDta_IniAux .Or. ECF->ECF_DTCONT > dDta_FimAux)
            nVlECF := ECF->ECF_VL_MOE
            EEQ->(DBSETORDER(1)) // No Lê pagamentos deve-se tratar pagamentos parciais.
            EEQ->(DBSEEK(cFilEEQ+ECF->ECF_PREEMB))
            DO While EEQ->(!EOF()) .AND. EEQ->EEQ_FILIAL = cFilEEQ .AND. EEQ->EEQ_PREEMB = ECF->ECF_PREEMB
               IF EEQ->EEQ_EVENT = '102'
                  nRec := EEQ->(Recno())
                  nInd := EEQ->(INDEXORD())
                  IF (ECF->ECF_VL_MOE # EEQ->EEQ_VL .AND. (EEQ->EEQ_PGT < dDta_IniAux .OR. EEQ->EEQ_PGT > dDta_FimAux)) .OR. EMPTY(EEQ->EEQ_PGT)
                     DO WHILE EEQ->(!EOF()) .AND. EEQ->EEQ_FILIAL = cFilEEQ .AND. ECF->ECF_PREEMB = EEQ->EEQ_PREEMB
                        IF !EMPTY(EEQ->EEQ_PGT) .AND. ECF->ECF_ID_CAM = EEQ->EEQ_EVENT
                           nVlECF -= EEQ->EEQ_VL
                           EEQ->(DBSKIP())
                        ENDIF
                        EEQ->(DBSKIP())
                     ENDDO
                     c102Pree := ECF->ECF_PREEMB
                     c102Fase := ECF->ECF_FASE 
                     c102Inve := ECF->ECF_INVEXP
                     c102Seq  := ECF->ECF_SEQ
                     c102NrCo := ECF->ECF_NR_CON
                     c102NrNf := ECF->ECF_NRNF
                     c102Forn := ECF->ECF_FORN
                     c102TpFo := ECF->ECF_TP_FOR
                     c102IDENT:= ECF->ECF_IDENTC
                     cTipSYS  := "H" // Foi criada esta variavel como padrão no SYS é "H" porém quando for
                                     // customizado no cliente ele utilizara o ponto de entrada no ECOPF999_RDM (PRE_SYS)
                                     // para modificar esta variavel para "Z" (Customizado)
                     nRecOld  := ECF->(RECNO())
                  
                     ECF->(DBSEEK(cFilECF+'EXPORT'+'EX'+c102Pree+c102Fase+c102Inve+c102Seq+'570'))
                     DO WHILE ECF->(!EOF()) .AND. ECF->ECF_ID_CAM = '570' .AND. cFilECF = ECF->ECF_FILIAL
                        IF ECF->ECF_NRNF = c102NrNf .And. nNrUltCont = ECF->ECF_NR_CON //.AND. ECF->ECF_IDENTC = c102IDENT  // Analisar qdo tiver pagamento parcial, tem de buscar realmente a ultima VC que ocorreu no mes passado.
                           AAdd(aVcAnt, {ECF->ECF_INVEXP,ECF->ECF_NRNF,nVlECF,AVKEY(ECF->ECF_IDENTC,"YS_CC"),ECF->ECF_ID_CAM,ECF->ECF_FORN,ECF->ECF_MOEDA,AVKEY(ECF->ECF_INVOIC,"YS_INVOICE")})
                           cMesAntAux := ECF->ECF_PARIDA
                        ENDIF
                        ECF->(DBSKIP())
                     ENDDO                
                     ECF->(DBSEEK(cFilECF+'EXPORT'+'EX'+c102Pree+c102Fase+c102Inve+c102Seq+'571'))
                     DO WHILE ECF->(!EOF()) .AND. ECF->ECF_ID_CAM = '571' .AND. cFilECF = ECF->ECF_FILIAL
                        IF ECF->ECF_NRNF = c102NrNf .And. nNrUltCont = ECF->ECF_NR_CON //.AND. ECF->ECF_IDENTC = c102IDENT 
                           //                    1             2          3               4                          5             6              7                       8
                           AAdd(aVcAnt, {ECF->ECF_INVEXP,ECF->ECF_NRNF,nVlECF,AVKEY(ECF->ECF_IDENTC,"YS_CC"),ECF->ECF_ID_CAM,ECF->ECF_FORN,ECF->ECF_MOEDA,AVKEY(ECF->ECF_INVEXP,"YS_INVEXP")})
                           cMesAntAux := ECF->ECF_PARIDA
                        ENDIF
                        ECF->(DBSKIP())
                     ENDDO                
                     FOR i:=1 TO Len(aVcAnt)
                         IF aVcAnt[i,3] >= 0
                            EC6->(Dbsetorder(1))
                            EC6->(DbSeek(xFilial("EC6")+"EXPORT"+aVcAnt[i,5]))
                            IF EC6->EC6_RATEIO = '1'
                              iVC := i
                              // Rotina para Rateio da VC
                              If(EasyEntryPoint("ECOPF999"),ExecBlock("ECOPF999",.F.,.F.,"VC_FRETE"),) // Nick 26/07/06
                              SYS->(DbSetOrder(2))
                              
                              // GFP - 09/11/2011 - Tratamento Loja
                              IF EICLOJA()
                                 //Posiciona no primeiro registro.
                                 IF SYS->(DbSeek(xFilial("SYS")+"E"+cTipSYS+aVcAnt[i,1]+aVcAnt[i,6]))
                                    cSYSLoja := SYS->YS_FORLOJ
                                    // CHAVE - YS_FILIAL+YS_TPMODU+YS_TIPO+YS_PREEMB+YS_FORN+YS_FORLOJ+YS_MOEDA+YS_INVEXP+YS_CC
                                    IF SYS->(DbSeek(xFilial("SYS")+"E"+cTipSYS+aVcAnt[i,1]+aVcAnt[i,6]+cSYSLoja+aVcAnt[i,7]+aVcAnt[i,8]+aVcAnt[i,4]))
                                       aVcAnt[i,3] := SYS->YS_PERC * aVcAnt[i,3]
                                    ENDIF
                                 ENDIF                                 
                              ELSE
                                 // CHAVE - YS_FILIAL+YS_TPMODU+YS_TIPO+YS_PREEMB+YS_FORN+YS_MOEDA+YS_INVEXP+YS_CC
                                 IF SYS->(DbSeek(xFilial("SYS")+"E"+cTipSYS+aVcAnt[i,1]+aVcAnt[i,6]+aVcAnt[i,7]+aVcAnt[i,8]+aVcAnt[i,4]))
                                    aVcAnt[i,3] := SYS->YS_PERC * aVcAnt[i,3]
                                 ENDIF
                              ENDIF
                              
                            Endif
                            nVariacao := (aVcAnt[i,3] * If(!lTemEmbPer,nTxFimMes,nTxEmb)) - (aVcAnt[i,3] * cMesAntAux)
                            If nVariacao <> 0
                               AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, "570", "571"), "", aVcAnt[i,1], If(nVariacao > 0, "570", "571"), dDta_FimAux, cMoeda, If(!lTemEmbPer,nTxFimMes,nTxEmb), cMesAntAux, cParcela, aVcAnt[i,4], 'VC', cProcesso, cFase, "", "", "", "", aVcAnt[i,2], dDta_FimAux, aVcAnt[i,3], 0,nVlECF,c102Forn,c102TpFo,"","",cFilECF,""})
                            EndIf
		                   Endif
			            Next i
  			            ECF->(DBGOTO(nRecOld))
			      ENDIF
                  EEQ->(DBSETORDER(nInd))
                  EEQ->(DBGOTO(nRec))			   
               Endif
               EEQ->(DBSKIP())
            Enddo
            EEQ->(DBSKIP())
        Endif
         
      
         // V.C do Seguro dos meses anteriores apos Embarque
         aVcAnt := {}
         If ECF->ECF_ID_CAM $ '103' .And. (ECF->ECF_DTCONT < dDta_IniAux .Or. ECF->ECF_DTCONT > dDta_FimAux)
            nVlECF := ECF->ECF_VL_MOE
            EEQ->(DBSETORDER(1)) // No Lê pagamentos deve-se tratar pagamentos parciais.
            EEQ->(DBSEEK(cFilEEQ+ECF->ECF_PREEMB))
            DO While EEQ->(!EOF()) .AND. EEQ->EEQ_FILIAL = cFilEEQ .AND. EEQ->EEQ_PREEMB = ECF->ECF_PREEMB
               IF EEQ->EEQ_EVENT = '103'
                  nRec := EEQ->(Recno())
                  nInd := EEQ->(INDEXORD())
                  IF (ECF->ECF_VL_MOE # EEQ->EEQ_VL .AND. (EEQ->EEQ_PGT < dDta_IniAux .OR. EEQ->EEQ_PGT > dDta_FimAux)) .OR. EMPTY(EEQ->EEQ_PGT)
                     DO WHILE EEQ->(!EOF()) .AND. EEQ->EEQ_FILIAL = cFilEEQ .AND. ECF->ECF_PREEMB = EEQ->EEQ_PREEMB
                        IF !EMPTY(EEQ->EEQ_PGT) .AND. ECF->ECF_ID_CAM = EEQ->EEQ_EVENT
                           nVlECF -= EEQ->EEQ_VL
                           EEQ->(DBSKIP())
                        ENDIF
                        EEQ->(DBSKIP())
                     ENDDO
                     c103Pree := ECF->ECF_PREEMB
                     c103Fase := ECF->ECF_FASE
                     c103Inve := ECF->ECF_INVEXP
                     c103Seq  := ECF->ECF_SEQ
                     c103NrCo := ECF->ECF_NR_CON
                     c103NrNf := ECF->ECF_NRNF
                     c103Forn := ECF->ECF_FORN
                     c103TpFo := ECF->ECF_TP_FOR 
                     nRecOld  := ECF->(RECNO())
               
                     ECF->(DBSEEK(cFilECF+'EXPORT'+'EX'+c103Pree+c103Fase+c103Inve+c103Seq+'572'))
                     DO WHILE ECF->(!EOF()) .AND. ECF->ECF_ID_CAM = '572' .AND. cFilECF = ECF->ECF_FILIAL
                        IF ECF->ECF_NRNF = c103NrNf .And. nNrUltCont = ECF->ECF_NR_CON //.AND. ECF->ECF_IDENTC = c103IDENT  // Analisar qdo tiver pagamento parcial, tem de buscar realmente a ultima VC que ocorreu no mes passado.
                           AAdd(aVcAnt, {ECF->ECF_INVEXP,ECF->ECF_NRNF,nVlECF,AVKEY(ECF->ECF_IDENTC,"YS_CC"),ECF->ECF_ID_CAM,ECF->ECF_FORN,ECF->ECF_MOEDA,AVKEY(ECF->ECF_INVOIC,"YS_INVOICE")})
                           cMesAntAux := ECF->ECF_PARIDA
                        ENDIF
                        ECF->(DBSKIP())
                     ENDDO                
                     ECF->(DBSEEK(cFilECF+'EXPORT'+'EX'+c103Pree+c103Fase+c103Inve+c103Seq+'573'))
                     DO WHILE ECF->(!EOF()) .AND. ECF->ECF_ID_CAM = '573' .AND. cFilECF = ECF->ECF_FILIAL
                        IF ECF->ECF_NRNF = c103NrNf .And. nNrUltCont = ECF->ECF_NR_CON //.AND. ECF->ECF_IDENTC = c103IDENT 
                           //                    1             2          3               4                          5             6              7                       8
                           AAdd(aVcAnt, {ECF->ECF_INVEXP,ECF->ECF_NRNF,nVlECF,AVKEY(ECF->ECF_IDENTC,"YS_CC"),ECF->ECF_ID_CAM,ECF->ECF_FORN,ECF->ECF_MOEDA,AVKEY(ECF->ECF_INVEXP,"YS_INVEXP")})
                           cMesAntAux := ECF->ECF_PARIDA
                        ENDIF
                        ECF->(DBSKIP())
                     ENDDO                
                     FOR i:=1 TO Len(aVcAnt)
                         IF aVcAnt[i,3] >= 0
                            EC6->(Dbsetorder(1))
                            EC6->(DbSeek(xFilial("EC6")+"EXPORT"+aVcAnt[i,5]))
                            IF EC6->EC6_RATEIO = '1'
                              iVC := i
                              // Rotina para Rateio da VC
                              If(EasyEntryPoint("ECOPF999"),ExecBlock("ECOPF999",.F.,.F.,"VC_SEGURO"),) // Nick 26/07/06
                              SYS->(DbSetOrder(2))
                              
                              // GFP - 09/11/2011 - Tratamento Loja
                              IF EICLOJA()
                                 //Posiciona no primeiro registro.
                                 IF SYS->(DbSeek(xFilial("SYS")+"E"+cTipSYS+aVcAnt[i,1]+aVcAnt[i,6]))
                                    cSYSLoja := SYS->YS_FORLOJ
                                    // CHAVE - YS_FILIAL+YS_TPMODU+YS_TIPO+YS_PREEMB+YS_FORN+YS_FORLOJ+YS_MOEDA+YS_INVEXP+YS_CC
                                    IF SYS->(DbSeek(xFilial("SYS")+"E"+cTipSYS+aVcAnt[i,1]+aVcAnt[i,6]+cSYSLoja+aVcAnt[i,7]+aVcAnt[i,8]+aVcAnt[i,4]))
                                       aVcAnt[i,3] := SYS->YS_PERC * aVcAnt[i,3]
                                    ENDIF
                                 ENDIF                                 
                              ELSE
                                 // CHAVE - YS_FILIAL+YS_TPMODU+YS_TIPO+YS_PREEMB+YS_FORN+YS_MOEDA+YS_INVEXP+YS_CC
                                 IF SYS->(DbSeek(xFilial("SYS")+"E"+cTipSYS+aVcAnt[i,1]+aVcAnt[i,6]+aVcAnt[i,7]+aVcAnt[i,8]+aVcAnt[i,4]))
                                    aVcAnt[i,3] := SYS->YS_PERC * aVcAnt[i,3]
                                 ENDIF
                              ENDIF                            
                              
                            Endif
                            nVariacao := (aVcAnt[i,3] * If(!lTemEmbPer,nTxFimMes,nTxEmb)) - (aVcAnt[i,3] * cMesAntAux)
                            If nVariacao <> 0
                               AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, "572", "573"), "", aVcAnt[i,1], If(nVariacao > 0, "572", "573"), dDta_FimAux, cMoeda, If(!lTemEmbPer,nTxFimMes,nTxEmb), cMesAntAux, cParcela, aVcAnt[i,4], 'VC', cProcesso, cFase, "", "", "", "", aVcAnt[i,2], dDta_FimAux, aVcAnt[i,3], 0,nVlECF,c103Forn,c103TpFo,"","",cFilECF,""})
                            EndIf
		                   Endif
			            Next i
  			            ECF->(DBGOTO(nRecOld))
			      ENDIF
                  EEQ->(DBSETORDER(nInd))
                  EEQ->(DBGOTO(nRec))			   
               Endif
               EEQ->(DBSKIP())
            Enddo
            EEQ->(DBSKIP())
        Endif

         
         PF999CalcCom(dDta_IniAux,dDta_FimAux,lTemEmbPer,nTxFimMes,nTxEmb,cMoeda,cParcela,cProcesso,cFase)
//         If (lTemEmbPer .and. lCalcNF) .Or. Empty(EEC->EEC/DTEMBA) .or. EEC->EEC_DTEMBA > dDta_Fim
         If lTemEmbPer .Or. Empty(EEC->EEC_DTEMBA) .or. EEC->EEC_DTEMBA > dDta_Fim // MJA 03/08/05 

            If ECF->ECF_ID_CAM $ "602/605/115" .And. (ECF->ECF_TIPO <> 'A' .Or. (ECF->ECF_TIPO $ 'A' .And. !Empty(ECF->ECF_NR_CON))) 
               nPos := Ascan(aRecebe,{|x| x[1] = ECF->ECF_PREEMB .And. x[2] = ECF->ECF_INVEXP .And. x[3] = ECF->ECF_SEQ .And. x[4] = ECF->ECF_FASE })
               If nPos > 0
                  aRecebe[nPos,5] += ECF->ECF_VL_MOE  // ECF->ECF_VALOR
               Else  
                  AAdd(aRecebe, {ECF->ECF_PREEMB, ECF->ECF_INVEXP, ECF->ECF_FASE, ECF->ECF_SEQ, ECF->ECF_VL_MOE, ECF->ECF_MOEDA, ECF->ECF_DTCONT,ECF->ECF_FORN, ECF->ECF_TP_FOR })
               Endif                
               // ------------------------------------- MJA 07/08/05
               nRecOld := EEQ->(RECNO())
               nOldInd := EEQ->(INDEXORD())                                                
               EEQ->(DBSETORDER(7))
               EEQ->(DBSEEK(cFilEEQ+ECF->ECF_FASE+ECF->ECF_PREEMB+ECF->ECF_SEQ))
               DO WHILE EEQ->(!EOF()) .AND. EEQ->EEQ_FAOR = ECF->ECF_FASE .AND. EEQ->EEQ_PROR = ECF->ECF_PREEMB .AND. EEQ->EEQ_PAOR = SUBSTR(ECF->ECF_SEQ,1,2)
                  IF nPos > 0                  
                     aRecebe[nPos,5] -= EEQ->EEQ_VL
                   ELSE
                     aRecebe[Len(aRecebe),5] -= EEQ->EEQ_VL
                  ENDIF   
                  EEQ->(DBSKIP())
               ENDDO   
                  // Ler o eeq e verificar o evento 101 com tipo adiantamento fase pedido (quando meu ECF for 602), e deduzir no aRecebe. Fazer isso para o evento 605 tb.
               EEQ->(DBSETORDER(nOldInd))
               EEQ->(DBGOTO(nRecOld))
               // -------------------------------------
               
            Endif                     


            // V.C das Despesas Internas dos meses anteriores / Foi alterado esta rotina pois não trazia as contas e C.C. das VC anteriores
            If ECF->ECF_ID_CAM $ '126' .And. (ECF->ECF_DTCONT < dDta_IniAux .Or. ECF->ECF_DTCONT > dDta_FimAux) .And. lNFsDif // vi 17/12/05
               c126Pree := ECF->ECF_PREEMB
               c126Fase := ECF->ECF_FASE 
               c126Inve := ECF->ECF_INVEXP
               c126Seq  := ECF->ECF_SEQ
               c126NrCo := ECF->ECF_NR_CON
               c126NrNf := ECF->ECF_NRNF
               c126Forn := ECF->ECF_FORN
               c126TpFo := ECF->ECF_TP_FOR
               nRecOld  := ECF->(RECNO())
               
               ECF->(DBSEEK(cFilECF+'EXPORT'+'EX'+c126Pree+c126Fase+c126Inve+c126Seq+'540'))
               DO WHILE ECF->(!EOF()) .AND. ECF->ECF_ID_CAM = '540' .AND. cFilECF = ECF->ECF_FILIAL
                  IF ECF->ECF_NRNF = c126NrNf .And. nNrUltCont = ECF->ECF_NR_CON
                     AAdd(aVcAnt, {ECF->ECF_INVEXP,ECF->ECF_NRNF,ECF->ECF_VL_MOE,ECF->ECF_IDENTC})
                     cMesAntAux := ECF->ECF_PARIDA
                  ENDIF
                  ECF->(DBSKIP())
               ENDDO
               ECF->(DBSEEK(cFilECF+'EXPORT'+'EX'+c126Pree+c126Fase+c126Inve+c126Seq+'541'))
               DO WHILE ECF->(!EOF()) .AND.ECF->ECF_ID_CAM = '541' .AND. cFilECF = ECF->ECF_FILIAL
                  IF ECF->ECF_NRNF = c126NrNf .And. nNrUltCont = ECF->ECF_NR_CON
                     AAdd(aVcAnt, {ECF->ECF_INVEXP,ECF->ECF_NRNF,ECF->ECF_VL_MOE,ECF->ECF_IDENTC})
                     cMesAntAux := ECF->ECF_PARIDA
                  ENDIF
                  ECF->(DBSKIP())
               ENDDO
               
               FOR i:=1 TO Len(aVcAnt)
                   IF aVcAnt[i,3] >= 0
                      nVariacao := (aVcAnt[i,3] * If(!lTemEmbPer,nTxFimMes,nTxEmb)) - (aVcAnt[i,3] * cMesAntAux)
                      If nVariacao <> 0
                         AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, "540", "541"), "", aVcAnt[i,1], If(nVariacao > 0, "540", "541"), dDta_FimAux, cMoeda, If(!lTemEmbPer,nTxFimMes,nTxEmb), cMesAntAux, cParcela, aVcAnt[i,4], 'VC', cProcesso, cFase, "", "", "", "", aVcAnt[i,2], dDta_FimAux, aVcAnt[i,3], 0,aVcAnt[i,3],c126Forn,c126TpFo,"","",cFilECF,""})
                      EndIf
			       Endif
			   Next i
			   ECF->(DBGOTO(nRecOld))
            Endif                        

            // V.C do Seguro dos meses anteriores / Foi alterado esta rotina pois não trazia as contas e C.C. das VC anteriores
            If ECF->ECF_ID_CAM $ '105' .And. (ECF->ECF_DTCONT < dDta_IniAux .Or. ECF->ECF_DTCONT > dDta_FimAux) .And. lNFsDif // vi 17/12/05
               c105Pree := ECF->ECF_PREEMB
               c105Fase := ECF->ECF_FASE 
               c105Inve := ECF->ECF_INVEXP
               c105Seq  := ECF->ECF_SEQ
               c105NrCo := ECF->ECF_NR_CON
               c105NrNf := ECF->ECF_NRNF
               c105Forn := ECF->ECF_FORN
               c105TpFo := ECF->ECF_TP_FOR
               nRecOld  := ECF->(RECNO())
               
               ECF->(DBSEEK(cFilECF+'EXPORT'+'EX'+c105Pree+c105Fase+c105Inve+c105Seq+'532'))
               DO WHILE ECF->(!EOF()) .AND. ECF->ECF_ID_CAM = '532' .AND. cFilECF = ECF->ECF_FILIAL
                  IF ECF->ECF_NRNF = c105NrNf .And. nNrUltCont = ECF->ECF_NR_CON
                     AAdd(aVcAnt, {ECF->ECF_INVEXP,ECF->ECF_NRNF,ECF->ECF_VL_MOE,ECF->ECF_IDENTC})
                     cMesAntAux := ECF->ECF_PARIDA
                  ENDIF
                  ECF->(DBSKIP())
               ENDDO
               ECF->(DBSEEK(cFilECF+'EXPORT'+'EX'+c105Pree+c105Fase+c105Inve+c105Seq+'533'))
               DO WHILE ECF->(!EOF()) .AND. ECF->ECF_ID_CAM = '533' .AND. cFilECF = ECF->ECF_FILIAL
                  IF ECF->ECF_NRNF = c105NrNf .And. nNrUltCont = ECF->ECF_NR_CON
                     AAdd(aVcAnt, {ECF->ECF_INVEXP,ECF->ECF_NRNF,ECF->ECF_VL_MOE,ECF->ECF_IDENTC})
                     cMesAntAux := ECF->ECF_PARIDA
                  ENDIF
                  ECF->(DBSKIP())
               ENDDO
               
               FOR i:=1 TO Len(aVcAnt)
                   IF aVcAnt[i,3] >= 0
                      nVariacao := (aVcAnt[i,3] * If(!lTemEmbPer,nTxFimMes,nTxEmb)) - (aVcAnt[i,3] * cMesAntAux)
                      If nVariacao <> 0
                         AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, "532", "533"), "", aVcAnt[i,1], If(nVariacao > 0, "532", "533"), dDta_FimAux, cMoeda, If(!lTemEmbPer,nTxFimMes,nTxEmb), cMesAntAux, cParcela, aVcAnt[i,4], 'VC', cProcesso, cFase, "", "", "", "", aVcAnt[i,2], dDta_FimAux, aVcAnt[i,3], 0,aVcAnt[i,3],c105Forn,c105TpFo,"","",cFilECF,""})
                      EndIf
			       Endif
			   Next i
			   ECF->(DBGOTO(nRecOld))
            Endif                        

            // V.C do Frete dos meses anteriores / Foi alterado esta rotina pois não trazia as contas e C.C. das VC anteriores
            If ECF->ECF_ID_CAM $ '104' .And. (ECF->ECF_DTCONT < dDta_IniAux .Or. ECF->ECF_DTCONT > dDta_FimAux) .And. lNFsDif // vi 17/12/05
               c104Pree := ECF->ECF_PREEMB; c104Fase := ECF->ECF_FASE  ; c104Inve := ECF->ECF_INVEXP
               c104Seq  := ECF->ECF_SEQ   ; c104NrCo := ECF->ECF_NR_CON; c104NrNf := ECF->ECF_NRNF
               c104Forn := ECF->ECF_FORN  ; c104TpFo := ECF->ECF_TP_FOR               
               nRecOld  := ECF->(RECNO())
               
               ECF->(DBSEEK(cFilECF+'EXPORT'+'EX'+c104Pree+c104Fase+c104Inve+c104Seq+'530'))
//             DO WHILE ECF->(!EOF()) .AND. ECF->ECF_NR_CON = c104NrCo .AND. ECF->ECF_ID_CAM = '530' .And. cFilECF = ECF->ECF_FILIAL VI 08/08/05
//                IF ECF->ECF_NRNF = c104NrNf
               DO WHILE ECF->(!EOF()) .AND. ECF->ECF_ID_CAM = '530' .And. cFilECF = ECF->ECF_FILIAL
                  IF ECF->ECF_NRNF = c104NrNf .And. nNrUltCont = ECF->ECF_NR_CON
                     AAdd(aVcAnt, {ECF->ECF_INVEXP,ECF->ECF_NRNF,ECF->ECF_VL_MOE,ECF->ECF_IDENTC})
                     cMesAntAux := ECF->ECF_PARIDA
                  ENDIF
                  ECF->(DBSKIP())
               ENDDO
               ECF->(DBSEEK(cFilECF+'EXPORT'+'EX'+c104Pree+c104Fase+c104Inve+c104Seq+'531'))
               DO WHILE ECF->(!EOF()) .AND. ECF->ECF_ID_CAM = '531' .And. cFilECF = ECF->ECF_FILIAL
                  IF ECF->ECF_NRNF = c104NrNf .And. nNrUltCont = ECF->ECF_NR_CON
                     AAdd(aVcAnt, {ECF->ECF_INVEXP,ECF->ECF_NRNF,ECF->ECF_VL_MOE,ECF->ECF_IDENTC})
                     cMesAntAux := ECF->ECF_PARIDA
                  ENDIF
                  ECF->(DBSKIP())
               ENDDO
               
               FOR i:=1 TO Len(aVcAnt)
                   IF aVcAnt[i,3] >= 0
                      nVariacao := (aVcAnt[i,3] * If(!lTemEmbPer,nTxFimMes,nTxEmb)) - (aVcAnt[i,3] * cMesAntAux)
                      If nVariacao <> 0
                         AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, "530", "531"), "", aVcAnt[i,1], If(nVariacao > 0, "530", "531"), dDta_FimAux, cMoeda, If(!lTemEmbPer,nTxFimMes,nTxEmb), cMesAntAux, cParcela, aVcAnt[i,4], 'VC', cProcesso, cFase, "", "", "", "", aVcAnt[i,2], dDta_FimAux, aVcAnt[i,3], 0,aVcAnt[i,3],c104Forn,c104TpFo,"","",cFilECF,""})
                      EndIf
			       Endif
			   Next i
			   ECF->(DBGOTO(nRecOld))
            Endif                        


//-------- MJA 10/08/05 Tem de verificar se realmente nao calcula a VC antes. VERIFICAR!!!!!
//---------------------------------------------------------

            // V.C da NF dos meses anteriores / Foi alterado esta rotina pois não trazia as contas e C.C. das VC anteriores
//          If ECF->ECF_ID_CAM $ '107' .And. (ECF->ECF_DTCONT < dDta_IniAux .Or. ECF->ECF_DTCONT > dDta_FimAux) VI 01/08/05

            If ! EEC->EEC_COBCAM $ cNao  .AND. EEC->EEC_MPGEXP # '006' .And. ECF->ECF_ID_CAM $ '107' .And. (ECF->ECF_DTCONT < dDta_IniAux .Or. ECF->ECF_DTCONT > dDta_FimAux) .And. lNFsDif // vi 17/12/05
               c107Pree := ECF->ECF_PREEMB
               c107Fase := ECF->ECF_FASE 
               c107Inve := ECF->ECF_INVEXP
               c107Seq  := ECF->ECF_SEQ
               c107NrCo := ECF->ECF_NR_CON
               c107NrNf := ECF->ECF_NRNF
               c107Forn := ECF->ECF_FORN
               c107TpFo := ECF->ECF_TP_FOR                              
               nRecOld  := ECF->(RECNO())
               
               ECF->(DBSEEK(cFilECF+'EXPORT'+'EX'+c107Pree+c107Fase+c107Inve+c107Seq+'580'))
               DO WHILE ECF->(!EOF()) .AND. ECF->ECF_ID_CAM = '580' .And. cFilECF = ECF->ECF_FILIAL
                  IF ECF->ECF_NRNF = c107NrNf .And. nNrUltCont = ECF->ECF_NR_CON
                     AAdd(aVcAnt, {ECF->ECF_INVEXP,ECF->ECF_NRNF,ECF->ECF_VL_MOE,ECF->ECF_IDENTC})
                  ENDIF
                  ECF->(DBSKIP())
               ENDDO
               ECF->(DBSEEK(cFilECF+'EXPORT'+'EX'+c107Pree+c107Fase+c107Inve+c107Seq+'581'))
               DO WHILE ECF->(!EOF()) .AND. ECF->ECF_ID_CAM = '581' .And. cFilECF = ECF->ECF_FILIAL
                  IF ECF->ECF_NRNF = c107NrNf .And. nNrUltCont = ECF->ECF_NR_CON
                     AAdd(aVcAnt, {ECF->ECF_INVEXP,ECF->ECF_NRNF,ECF->ECF_VL_MOE,ECF->ECF_IDENTC})
                  ENDIF
                  ECF->(DBSKIP())
               ENDDO
               
               FOR i:=1 TO Len(aVcAnt)
                   IF aVcAnt[i,3] >= 0
                      nVariacao := (aVcAnt[i,3] * If(!lTemEmbPer,nTxFimMes,nTxEmb)) - (aVcAnt[i,3] * nTxMesAnt)
                      If nVariacao <> 0
                         AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, "580", "581"), "", aVcAnt[i,1], If(nVariacao > 0, "580", "581"), dDta_FimAux, cMoeda, If(!lTemEmbPer,nTxFimMes,nTxEmb), nTxMesAnt, cParcela, aVcAnt[i,4], 'VC', cProcesso, cFase, "", "", "", "", aVcAnt[i,2], dDta_FimAux, aVcAnt[i,3], 0,aVcAnt[i,3],c107Forn,c107TpFo,"","",cFilECF,""})
                      EndIf
			       Endif
			   Next i
			   ECF->(DBGOTO(nRecOld))
            Endif                        
         Endif


         // Acumula valores p/ V.C da Invoice
         If ECF->ECF_ID_CAM $ '101' .And. Empty(ECF->ECF_TIPO) //.And. (ECF->ECF_DTCONT < dDta_IniAux .Or. ECF->ECF_DTCONT > dDta_FimAux)
            nVc101    += ECF->ECF_VL_MOE
            cParc101  := ECF->ECF_SEQ
            cProc101  := ECF->ECF_PREEMB
            cFase101  := ECF->ECF_FASE
            cIdentc101:= ECF->ECF_IDENTC
         Elseif ECF->ECF_ID_CAM $ "607" //.And. ECF->ECF_NR_CON # STRZERO(nNR_Cont+1,4,0)  // Pagamento Invoice VI 01/12/05
            nVc101    -= ECF->ECF_VL_MOE
            nPagCli   += ECF->ECF_VL_MOE
         Elseif ECF->ECF_ID_CAM $ "801"   // Desconto
            nVc101    -= ECF->ECF_VL_MOE
            nDesconto += ECF->ECF_VL_MOE
         Elseif ECF->ECF_ID_CAM $ "802"   // Devolução //MJA 25/08/04 -> Aqui desconta a devolução do valor da Invoice
            nVc101    -= ECF->ECF_VL_MOE
            nDesconto += ECF->ECF_VL_MOE

         Elseif ECF->ECF_ID_CAM $ "121/124"   //   MJA 04/08/05 Deduzir a Conta Grafica da Invoice
            // nVc101    -= ECF->ECF_VL_MOE
            IF ECF->ECF_ID_CAM = '121'
               nContaGra := ECF->ECF_VL_MOE // MJA 05/08/05
             ELSE
               nContaGra += ECF->ECF_VL_MOE // MJA 05/08/05             
            ENDIF   
           
         Elseif ECF->ECF_ID_CAM $ "999" .And. ECF->ECF_LINK $ '607'  // Estorno
            If !Empty(ECF->ECF_NR_CON) .Or. (Empty(ECF->ECF_NR_CON) .And. ECF->ECF_DTCONT >= (dDta_Ini) .And. ECF->ECF_DTCONT <= (dDta_Fim))
               nVc101    += ECF->ECF_VL_MOE
            Endif
         // Nick 25/04/2006
         Elseif ECF->ECF_ID_CAM $ "112/116/117"  // Adiantamento
            nAdiantAnt += ECF->ECF_VL_MOE
         Endif
         cClie := ECF->ECF_FORN // MJA 09/05/05
         cTpCl := ECF->ECF_TP_FOR // MJA 09/05/05
         ECF->(DbSkip())
      Enddo                                     
      
      IF cEv101 $ "101" //LRS 
         // Agrupas as invoices para Gerar V.C   
         nPos := Ascan(aProcessos,{|x| x[1]=cInvoice})
         If nPos = 0
            AAdd(aProcessos, {cInvoice, nVc101, cClie, cTpCl, cMoeda}) // MJA 09/05/05 VI 24/07/05
         Else
            aProcessos[nPos,2] += nVc101
         Endif
      EndIF

      // Somar o valor dos adiantamentos do embarque   Nick 26/04/2006
      nAdiantEmb += nAdiantAnt
      
      nVC101 := 0

      // Acumula Baixas / Vinculações dos processos (Processo de Origem, Fase Origem)
      nRecnoECF := ECF->(Recno())
      nIndexECF := ECF->(IndexOrd())

    If Empty(EEC->EEC_DTEMBA) .Or. lTemEmbPer

         ECF->(DbSetOrder(10))
    	 ECF->(DbSeek(cFilECF+cTPMODU+'EX'+cProcesso+cFase+cInvoice+cParcela))

         Do While ECF->(!EOF()) .And. ECF->ECF_FILIAL == cFilECF .And. ECF->ECF_ORIGEM = 'EX' .And. ;
            ECF->ECF_PROR = cProcesso .And. ECF->ECF_FAOR = cFase .And. ECF->ECF_PAOR = cParcela .And. ;
   		    ECF->ECF_INVEXP = cInvoice .And. Eval(bTPMODUECF)
   		    
   		    // Se for registro deste mes ignora pois ja foi contabilizado pelo ECA
            If ECF->ECF_NR_CON = STRZERO(nNR_Cont+1,4,0)
               ECF->(DbSkip())
               Loop
            Endif

		    If ECF->ECF_TIPO = 'A' .And. ECF->ECF_ID_CAM $ "116/115/117/112" .OR. (ECF->ECF_ID_CAM = '101/602' .AND. ECF->ECF_TIPO = 'A' .AND. ECF->ECF_FAOR = 'C' ) // VI 11/08/03 ECF->ECF_ID_CAM $ "602/605/607"
               If lTemECFNew
                  lMes := If(ECF->ECF_DTCONT >= (dDta_Ini) .And. ECF->ECF_DTCONT <= (dDta_Fim), .T., .F.)
                  nPos := Ascan(aBaixa,{|x| x[1] = ECF->ECF_PROR .And. x[2] = ECF->ECF_INVEXP .And. x[3] = ECF->ECF_FAOR .And. x[4] = ECF->ECF_PAOR })
                  If nPos > 0
                     // Liquidacoes
                     aBaixa[nPos,5] += ECF->ECF_VL_MOE
                     // Liquidacoes no período
                     If lMes
                        aBaixa[nPos,6] +=  ECF->ECF_VL_MOE
                     Endif
                  Else
                     AAdd(aBaixa, {ECF->ECF_PROR, ECF->ECF_INVEXP, ECF->ECF_FAOR, ECF->ECF_PAOR, ECF->ECF_VL_MOE, If(lMes, ECF->ECF_VL_MOE, 0), ECF->ECF_MOEDA, ECF->ECF_DTCONT })
                  Endif
               Endif
            Endif   
               
            ECF->(DbSkip())
         Enddo
         // Retorna ao registro e Indice anterior
         ECF->(DbSetOrder(nIndexECF))
         ECF->(DbGoto(nRecnoECF))
    Endif
   Enddo 

   // Gera VC das Invoices   
   For x:=1 to Len(aProcessos)                                                                          
      cInvoice := aProcessos[x,1]
      nVC101   := aProcessos[x,2]
      cClie    := aProcessos[x,3]
      cTpCl    := aProcessos[x,4]
      cMoeda   := aProcessos[x,5] // VI 24/07/05

      nTxFimMes    := ECOEXP999Tx(cMoeda, dDta_Fim, cTX_101) // VI 24/07/05
      nTxIniMes    := ECOEXP999Tx(cMoeda, dDta_Ini, cTX_101) // VI 24/07/05
      If ! Empty(EEC->EEC_DTEMBA)
         nTxEmb    := ECOEXP999Tx(cMoeda, EEC->EEC_DTEMBA, cTX_101 )                                        // Taxa Embarque
      EndIf         

//      nVcVinc := 0
//      nTxVinc  := 0 
      If !lVcAv  // VI 26/07/05 Para gerar v.c. somente do que não está vinculado
         EF3->(DbSeek(cFilEF3+IF(lEFFTPMOD,cTipoModu,"")+'600'+cInvoice)) // Nick - 02/08/06
         Do While ! EF3->(Eof()) .AND. Alltrim(cInvoice) == Alltrim(EF3->EF3_INVOIC) .AND. EF3->EF3_CODEVE == '600' .and. cFilEF3 = EF3->EF3_FILIAL // MJA 18/08/04
            If Alltrim(cProc101) == Alltrim(EF3->EF3_PREEMB) 
//             nVC101 -= EF3->EF3_VL_MOE  // VI 19/07/05
               nVC101 -= EF3->EF3_VL_INV // VI 26/07/05
               cParc101 := EF3->EF3_PARC
            EndIF
            EF3->(Dbskip())
         EndDo
//    ElseIf lVcAv .And. EF3->(DbSeek(cFilEF3+'600'+cInvoice)) // Para que não gere v.c. pois já foi gerado.
//       nVC101 := 0  VI 27/07/05
      EndIf

      IF ROUND(nContaGra,0) == ROUND(nVc101,0) // MJA 05/08/05
         nVc101 := 0
      ENDIF                  
      
      // VI 27/07/05 para que não gere v.c. duplicada.
      nPos := Ascan(aVCProcTotal,{|x| x[1] = EEC->EEC_PREEMB})
      lGeraVC:=.T.
      If nPos > 0
         If Abs(aVCProcTotal[nPos,2] - nVC101) < 0.01
            lGeraVC:=.F.
         EndIf
      Endif
      If (nVC101 - nAdiantEmb) >= 0.01 .And. lGeraVC
         // Nick 24/04/06 - Incluida funcao para buscar o valor de adiantamentos realizados.
         nVariacao := ((nVC101 - nAdiantEmb) * nTxFimMes) - ((nVC101 - nAdiantEmb) * If(lTemEmbPer, nTxEmb, nTxMesAnt)) //VI 26/07/05
         // Retirou-se a validação para não contabilizar VC zerada 	 MJA 24/08/05
//       If nVariacao <> 0 // .And. Abs(nVariacao) >= 0.01                                                                                                                                                                                                                                                // 24-> IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT) 25-> IF(EEQ->EEQ_TIPO=='P','2','1')
                           //    1                      2                 3      4                     5                   6         7        8                      9                    10         11        12      13        14     15  16  17  18  19      20                      21               22 23                  24                      25             26 27   28  cInvoice cParc101                           
            AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, "582", "583"), "", cInvoice, If(nVariacao > 0, "582", "583"), dDta_Fim, cMoeda, nTxFimMes, If(lTemEmbPer, nTxEmb, nTxMesAnt), cParc101, cIdentc101, 'EXP', cProc101, cFase101, "", "", "", "", "", dDta_FimAux, nVC101, 0, nVC101,CLI_TIP('EF3',cInvoice,'1'),CLI_TIP('EF3',cInvoice,'2'),"","",cFilEEQ,""})            
//	     Endif
	  Endif
   Next

   // Gera V.C´s do Evento 101 do processo
   // Gera V.C´s dos processos e Saldos
   For x:=1 to Len(aRecebe)

       cProc    := aRecebe[x,1]                     // Processo
       cInv     := aRecebe[x,2]                     // Invoice
       cFase    := aRecebe[x,3]                     // Fase
       cParc    := AVKEY(aRecebe[x,4], "ECF_PAOR")  // Parcela
       nVlRec   := aRecebe[x,5]                     // Valor Recebido
       cMoeda   := aRecebe[x,6]                     // Moeda
       dData    := aRecebe[x,7]                     // Data do Evento
       cForn    := aRecebe[x,8]                     // Fornecedor/Importador
       cTpFo    := aRecebe[x,9]                     // Tipo Fornecedor/Importador       
       cTipo    := If(cFase = 'C', 'CLI', If(cFase = 'P', 'PED', 'EMB') )
       nVlBx    := 0              				    // Valor Baixado
       nVlTransf:= 0              				    // Valor Transferência no Mês 

       // Taxas
       nTxFimMes := ECOEXP999Tx(cMoeda, dDta_Fim, cTX_101)
       nTxIniMes := ECOEXP999Tx(cMoeda, dDta_Ini, cTX_101)
       nTxDiaLiq := 0
       dDataLiq  := AVCTOD(" / /  ")

       // Gera VC do recebimento (saldo) de meses anteriores, mesmo que não haja liquidações
       If dData < (dDta_Ini) .Or. dData > (dDta_Fim)
          lGeraVC   := .T.
       Else
          lGeraVC   := .F.
       Endif

       nPos := Ascan(aBaixa,{|x| x[1] = cProc .And. x[2] = cInv .And. x[3] = cFase .And. x[4] = cParc })
       If nPos > 0
          nVlBx     := aBaixa[nPos,5]     			        // Liquidação
          dDataLiq  := aBaixa[nPos,8]					    // Data da Liquidacao
          nTxDiaLiq := ECOEXP999Tx(cMoeda, dDataLiq, cTX_101) // Taxa do Dia da Liquidação
          nVlTransf := aBaixa[nPos,6]                       // Transferencia
       Endif

       If lGeraVC

          // Saldo da parcela do Pagamento Antecipado do processo
          nSaldo := nVlRec// - nVlBx MJA 07/08/05

          // V.C do Saldo do Adiantamento
          nVariacao := (nSaldo * If(!lTemEmbPer,nTxFimMes,nTxEmb)) - (nSaldo * nTxMesAnt)
//          If nVariacao <> 0
          If nSaldo <> 0 // Nick 26/04/06
             cEvento := If(cFase $ 'C', If(nVariacao > 0, '590', '591'), If(nVariacao > 0, '594', '595') )
//             AAdd(aDadosPRV, {nVariacao, cEvento, "", cInv, cEvento, dDta_FimAux, cMoeda, nTxFimMes, nTxMesAnt, cParc, If(cTipo='E',"",cCustoPad), cTipo, cProc, cFase, "", "", "", "", "", dDta_Fim, nSaldo, 0,0,cForn,cTpFo,"","",cFilEEQ})
             AAdd(aDadosPRV, {nVariacao, cEvento, "", cInv, cEvento, dDta_FimAux, cMoeda, If(!lTemEmbPer,nTxFimMes,nTxEmb), nTxMesAnt, cParc, If(cTipo='E',"",cCustoPad), cTipo, cProc, cFase, "", "", "", "", "", dDta_Fim, nSaldo, 0,0,cForn,cTpFo,"","",cFilEEQ,""})
          Endif
//          Endif

          // Transferencia
          If nVlTransf <> 0
             cEvento := If(cFase $ 'C', '115', If(cFase $ 'P', '116', '112'))
             AAdd(aDadosPRV, {nVlTransf, cEvento, "", cInv, cEvento, dDataLiq, cMoeda, nTxDiaLiq, nTxIniMes, cParc, If(cTipo='E',"",cCustoPad), cTipo, cProc, cFase, "", "", "", "", "", "", "", 0, 0,0,cForn,cTpFo,"","",cFilEEQ,""})
          Endif
       Endif
   Next
      
   // Grava as Variacoes e eventos na prévia, ja rateando se necessario
   If Len(aDadosPRV) > 0
      PExp999_PrvRat(aDadosPRV)
   Endif

   // Grava a Taxa do Mês anterior
   If cPrv_Efe = "2"
      Reclock("ECG", .F.)
      ECG->ECG_ULT_TX := ECOEXP999Tx(cMoeda, dDta_Fim, cTX_101)
      ECG->(Msunlock())
   Endif
      
   ECG->(DbSkip())
Enddo
READ_NF(@lEnd) 

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ READ_NF   ³ Autor ³ MARCELO AZEVEDO       ³ Data ³ 18.02.05 ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Previa/Efetivação Das Notas Fiscais (Exportação)           ³±±
±±³Foi necessário quebrar a rotina co contabil pois surgiu o erro memory  ³±± 
±±³ overbooked                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Uso       ³ SIGAEco   												               ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

**********************
FUNCTION READ_NF(lEnd)
**********************
Local i
Local lNFAgain   := .F.
Local n101ECF    := 0
Local lRetPE     := .F.
Local nInc       := 0
Local nVlTotalNF := 0
Local nValorNF   := 0
Local nComRatNf  := 0

Private cCustoNF := "", cCustoFRE  := "", cCustroSEG := "", cCustoOUT  := "", cCustoCOM  := "" // VI 27/04/05 Utilizadas no RDM
Private lGrvOutDesp := .T. // Utilizada no RDM VI 27/04/05
Private aOutras   := {}, aOUSemRat := {} // VI 27/04/05
Private lTemRat126, lTemRatVCO

// Contabilização da NF
EEM->(DbSetOrder(1))
EES->(DbSetOrder(1))
EE9->(DbSetOrder(2))
EEC->(DbSetOrder(12))

oProcess:SetRegua2(nTotEEC)

EEC->(DbSeek(cFilEEC, .T.))
lTemRat107 := If(EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT"+"107",""))) .and. EC6->EC6_RATEIO $ cSim,.T.,.F.)
lTemRatVC 	 := If(EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT"+"580",""))) .and. EC6->EC6_RATEIO $ cSim,.T.,.F.)
          
// Frete          
lTemRat104 := If(EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT"+"104",""))) .and. EC6->EC6_RATEIO $ cSim,.T.,.F.)
lTemRatVCF  := If(EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT"+"530",""))) .and. EC6->EC6_RATEIO $ cSim,.T.,.F.)
        
// Seguro
lTemRat105 := If(EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT"+"105",""))) .and. EC6->EC6_RATEIO $ cSim,.T.,.F.)
lTemRatVCS  := If(EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT"+"532",""))) .and. EC6->EC6_RATEIO $ cSim,.T.,.F.)
        
// Outras Despesas
lTemRat126 := If(EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT"+"126",""))) .and. EC6->EC6_RATEIO $ cSim,.T.,.F.)
lTemRatVCO  := If(EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT"+"540",""))) .and. EC6->EC6_RATEIO $ cSim,.T.,.F.)

// Comissao a Remeter
lTemRat123 := If(EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT"+"123",""))) .and. EC6->EC6_RATEIO $ cSim,.T.,.F.)
lTemRatVCR := If(EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT"+"534",""))) .and. EC6->EC6_RATEIO $ cSim,.T.,.F.)
                     
// Comissao Conta Grafica
lTemRat124 := If(EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT"+"124",""))) .and. EC6->EC6_RATEIO $ cSim,.T.,.F.)
lTemRatVCG := If(EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT"+"536",""))) .and. EC6->EC6_RATEIO $ cSim,.T.,.F.)
                         
// Comissao a Deduzir da Fatura
lTemRat125 := If(EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT"+"125",""))) .and. EC6->EC6_RATEIO $ cSim,.T.,.F.)
lTemRatVCD := If(EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT"+"538",""))) .and. EC6->EC6_RATEIO $ cSim,.T.,.F.)

DBSELECTAREA("EEC")
If !(Posicione("SX2",1,"EEC","X2_MODO") == "C" .and. !lPrimeira)
	Do While EEC->(!EOF()) .And. EEC->EEC_FILIAL == cFilEEC 
       
       //ER - 23/01/2007
       If EasyEntryPoint("ECOPF999")
          lRetPE := ExecBlock("ECOPF999",.F.,.F.,"READNF")
          If ValType(lRetPE) == "L" .and. lRetPE
             EEC->(DbSkip())
             Loop   
          EndIf
       EndIf
       
	   oProcess:IncRegua2("4 / 4 "+STR0032+Alltrim(EEC->EEC_PREEMB)) //Processo : 
	
	   If lEnd
	      If lEnd:=MsgYesNo(STR0097,STR0098) 
	         Return .F.
	      EndIf
	   EndIf

	   dDta_FimAux := dDta_Fim
	   dDta_IniAux := dDta_Ini
	   dDataEmbAux := If(!EMPTY(EEC->EEC_DTEMBA) .And. EEC->EEC_DTEMBA <= dDta_Fim ,EEC->EEC_DTEMBA,dDta_FimAux) // VI 31/07/05
	
//	   If EEC->EEC_COBCAM $ cNao .or. EEC->EEC_MPGEXP = '006' .OR. (EEC->EEC_STATUS = '*' .and. !Empty(EEC->EEC_FIM_PE) .and. EEC->EEC_FIM_PE < dDta_Ini)
	   If (EEC->EEC_STATUS = '*' .and. !Empty(EEC->EEC_FIM_PE) .and. EEC->EEC_FIM_PE < dDta_Ini) // MJA 24/05/05 Para calcular mesmo sem cobertura cambial
	      EEC->(DbSkip())
	      Loop
	   EndIf

	   IF lBackTo // VI 01/07/05
	      if AP106isBackto(EEC->EEC_PREEMB,OC_EM) 
	         EEC->(DBSKIP())
	         LOOP
	      endif
	   ENDIF
       
	   If !Empty(dDataEmbAux) .and. dDataEmbAux >= dDta_Ini .And. dDataEmbAux <= dDta_Fim //.and. dDataEmbAux >= (dDta_Ini) .And. dDataEmbAux <= (dDta_Fim)
	      dDta_FimAux := dDataEmbAux                       
	   Endif
	   
	   lCancelada := .F.
	   If (EEC->EEC_STATUS = '*' .and. !Empty(EEC->EEC_FIM_PE) .and. EEC->EEC_FIM_PE >= dDta_Ini .and. EEC->EEC_FIM_PE <= dDta_Fim) //.and. EEC->EEC_FIM_PE < dDataEmbAux
	      lCancelada := .T.      
	   EndIf
	   
	   // Taxa do Inicio do Mês                             
	
	   EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT","")+'101')) 
	   cTX_101 := EC6->EC6_TXCV      
	
	   nTxFimMes := ECOEXP999Tx(EEC->EEC_MOEDA, dDta_FimAux, cTX_101)
	   nTxIniMes := ECOEXP999Tx(EEC->EEC_MOEDA, dDta_IniAux, cTX_101)
	   nTxEmbarq := ECOEXP999Tx(EEC->EEC_MOEDA, dDataEmbAux, cTX_101)
	
	   // Inicializa Variaveis
	   nTotNF    := 0
	   aNF    	 := {}
	   aNFSemRat := {}   
	   aDadosPrv := {}
	   aFrete    := {}
	   aFrSemRat := {}
	   aSeguro   := {}
	   aSESemRat := {}
	   aOutras   := {}
	   aOUSemRat := {}
	   aCom123   := {}
	   a123SemRat := {}
	   aCom124    := {}
	   a124SemRat := {}
	   aCom125    := {}
	   a125SemRat := {}
       aEve101 := {}
	   lNFAgain := .F.
	   nTotPgt := 0           
//---------------------------------------- MJA 04/05/05 Para verificar se houve embarque com data anterior e que não foi contabilizado	   
       // MJA 28/09/05
       
       n101ECF := 0
       lCalcula := .T.
       ECF->(DBSETORDER(9))
       ECF->(DBSEEK(cFilECF+'EXPORT'+'EX'+EEC->EEC_PREEMB))
       DO WHILE ECF->(!EOF()) .AND. ECF->ECF_PREEMB = EEC->EEC_PREEMB
          IF ECF->ECF_ID_CAM = '101'
             n101ECF += ECF->ECF_VL_MOE
          ENDIF
          ECF->(DBSKIP())
       ENDDO                                     
       IF n101ECF = EEC->EEC_TOTPED
          lCalcula := .F.
       ENDIF  
        
 	   IF EEC->EEC_DTEMBA < dDta_Ini .AND. !EMPTY(EEC->EEC_DTEMBA) .AND. lCalcula
	      DBSELECTAREA("EEQ")
	      EEQ->(DBSETORDER(5))
	      IF EEQ->(DBSEEK(cFilEEQ+EEC->EEC_NRINVO+'101'))
	         DO WHILE EEQ->EEQ_NRINVO = EEC->EEC_NRINVO .AND. EEQ->EEQ_EVENT = "101" .AND. EEQ->(!EOF()) // MJA 28/07/05
	            IF EMPTY(EEQ->EEQ_NR_CON) .Or. val(EEQ->EEQ_NR_CON) = (nNR_Cont+1)
	               EEM->(DBSETORDER(1))
	               EEM->(DBSEEK(cFilEEM+EEQ->EEQ_PREEMB+'N'))
	               DO WHILE EEM->(!EOF()) .AND. EEM->EEM_PREEMB = EEQ->EEQ_PREEMB   // MV -> DATA BASE PARA A TAXA 
	                  lNFAgain := .T.
	                  EES->(DBSETORDER(1))
	                  EES->(DBSEEK(cFilEES+EEM->EEM_PREEMB+EEM->EEM_NRNF))
   	                  DO WHILE EES->(!EOF()) .AND. EES->EES_NRNF = EEM->EEM_NRNF
	                     IF !EMPTY(EES->EES_NR_CON)
                            Reclock("EES", .F.)
				            EES->EES_NR_CON := SPACE(04)
				            EES->(MsUnlock())
				         ENDIF
				         EES->(DBSKIP())
				      ENDDO
	                  EEM->(DBSKIP())
	               ENDDO
	               IF !EMPTY(EEQ->EEQ_PGT)
	                  nTotPgt += EEQ->EEQ_VL
	               ENDIF	              
                   AADD(aEve101,EEQ->(RECNO()))
	            ENDIF  
    	        EEQ->(DBSKIP())	               
	         ENDDO
	         IF LEN(aEve101) > 0
  	            EEQ->(DBGOTO(aEve101[1]))      	                	        	        	               
	            dDta_Fim5 := dDta_FimAux
    	        dDta_FimAux := dDta_IniAux
                nTxFimMes5 := nTxFimMes
 	            nTxFimMes := ECOEXP999Tx(EEC->EEC_MOEDA, IF(nMesEmb = 1,dDataEmbAux,dDta_IniAux), cTX_101)
	              //                                 1                      2     3         4           5          6             7            8          9       10   11   12           13        14   15  16  17  18  19  20 21 22        23                       24                                              25              26 27   28
//  vi 04/01/06 AAdd(aDadosPRV, {EEC->EEC_TOTPED * nTxEmbarq, '101', "", EEC->EEC_NRINVO, '101', dDta_IniAux, EEC->EEC_MOEDA, nTxEmbarq, nTxFimMes, '01', "", 'EMB', EEC->EEC_PREEMB, "",  "", "", "", "", "", "", 0, 0, (EEC->EEC_TOTPED - nTotPgt),IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ}) // MJA 05/05/05
                AAdd(aDadosPRV, {EEC->EEC_TOTPED * nTxEmbarq, '101', "", EEC->EEC_NRINVO, '101', dDta_IniAux, EEC->EEC_MOEDA, nTxEmbarq, nTxFimMes, '01', "", 'EMB', EEC->EEC_PREEMB, "",  "", "", "", "", "", "", 0, 0, EEC->EEC_TOTPED,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""}) // vi 04/01/06
	            nVariacao := ((EEC->EEC_TOTPED - nTotPgt) * nTxFimMes5 ) - ((EEC->EEC_TOTPED - nTotPgt) * nTxEmbarq)
	            nTaxaAux := nTxFimMes5
            
                cEvento := If(nVariacao > 0, "582","583")
                IF nVariacao # 0
   	                               //   1         2     3        4              5        6              7            8          9      10    11   12             13           14        15  16  17  18  19      20      21 22               23                            24                                         25               26 27    28
                   AAdd(aDadosPRV, {nVariacao, cEvento, "", EEC->EEC_NRINVO, cEvento, dDta_Fim5 , EEC->EEC_MOEDA, nTaxaAux, nTxEmbarq, '01', "", 'EMB', EEC->EEC_PREEMB, EEQ->EEQ_FASE, "", "", "", "", "", dDta_FimAux, 0, 0, (EEC->EEC_TOTPED - nTotPgt),IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""}) // MJA 05/05/05
                ENDIF   

                // Efetivacao                             
                FOR I := 1 TO LEN(aEve101)
                    EEQ->(DBGOTO(aEve101[I]))
                    If cPrv_Efe = "2" .And. Empty(EEQ->EEQ_NR_CON) // MJA 29/07/05 Para gravar a contabilização para os embarques antes do periodo contabil
                       Reclock('EEQ',.F.)
                       EEQ->EEQ_NR_CON := STRZERO(nNR_Cont+1,4,0)
                       EEQ->(MSUNLOCK())
                    Endif
                NEXT I    
             ENDIF   
	      ENDIF
       ENDIF

 
 
/* 
	   IF EEC->EEC_DTEMBA < dDta_Ini .AND. !EMPTY(EEC->EEC_DTEMBA) .AND. lCalcula
	      DBSELECTAREA("EEQ")
	      EEQ->(DBSETORDER(5))
	      IF EEQ->(DBSEEK(cFilEEQ+EEC->EEC_NRINVO+'101'))
	         DO WHILE EEQ->EEQ_NRINVO = EEC->EEC_NRINVO .AND. EEQ->EEQ_EVENT = "101" .AND. EEQ->(!EOF()) // MJA 28/07/05
	            IF EMPTY(EEQ->EEQ_NR_CON) .Or. val(EEQ->EEQ_NR_CON) = (nNR_Cont+1)
	               EEM->(DBSETORDER(1))
	               EEM->(DBSEEK(cFilEEM+EEQ->EEQ_PREEMB+'N'))
	               DO WHILE EEM->(!EOF()) .AND. EEM->EEM_PREEMB = EEQ->EEQ_PREEMB   // MV -> DATA BASE PARA A TAXA 
	                  lNFAgain := .T.
	                  EES->(DBSETORDER(1))
	                  EES->(DBSEEK(cFilEES+EEM->EEM_PREEMB+EEM->EEM_NRNF))
   	                  DO WHILE EES->(!EOF()) .AND. EES->EES_NRNF = EEM->EEM_NRNF
	                     IF !EMPTY(EES->EES_NR_CON)
                            Reclock("EES", .F.)
				            EES->EES_NR_CON := SPACE(04)
				            EES->(MsUnlock())
				         ENDIF   
				         EES->(DBSKIP())
				      ENDDO   
	                  EEM->(DBSKIP())
	               ENDDO
	               dDta_Fim5 := dDta_FimAux                                      
 	               dDta_FimAux := dDta_IniAux
 	               nTxFimMes5 := nTxFimMes
 	               nTxFimMes := ECOEXP999Tx(EEC->EEC_MOEDA, IF(!EMPTY(EEQ->EEQ_PGT),EEQ->EEQ_PGT,IF(nMesEmb = 1,dDataEmbAux,dDta_IniAux)), cTX_101)
	                 //                         1              2     3         4           5           6               7          8          9          10        11   12           13        14   15  16  17  18  19  20 21 22        23                       24                                              25              26 27   28
	               AAdd(aDadosPRV, {EEQ->EEQ_VL * nTxEmbarq, '101', "", EEQ->EEQ_NRINVO, '101', dDta_IniAux, EEC->EEC_MOEDA, nTxEmbarq, nTxFimMes, EEQ->EEQ_PARC, "", 'EMB', EEQ->EEQ_PREEMB, "",  "", "", "", "", "", "", 0, 0, EEQ->EEQ_VL,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""}) // MJA 05/05/05
	               
	               nVariacao := (EEQ->EEQ_VL * nTxFimMes5 ) - (EEQ->EEQ_VL * nTxEmbarq)            
	               nTaxaAux := nTxFimMes5	            
//	               If nVariacao <> 0
                   If EMPTY(EEQ->EEQ_PGT) // VI 02/09/05
	                  cEvento := If(nVariacao > 0, "582","583")
	                               //      1         2      3        4              5                          6                                 7            8          9           10        11   12             13                14       15  16  17  18  19      20      21 22       23                            24                                         25               26 27    28
	                  AAdd(aDadosPRV, {nVariacao, cEvento, "", EEQ->EEQ_NRINVO, cEvento, IF(!EMPTY(EEQ->EEQ_PGT),EEQ->EEQ_PGT,dDta_Fim5) , EEQ->EEQ_MOEDA, nTaxaAux, nTxEmbarq, EEQ->EEQ_PARC, "", 'EMB', EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, "", "", "", "", "", dDta_FimAux, 0, 0, EEQ->EEQ_VL,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""}) // MJA 05/05/05
	               EndIf   
//	               Endif                

                   // Efetivacao
                   If cPrv_Efe = "2" .And. Empty(EEQ->EEQ_NR_CON) // MJA 29/07/05 Para gravar a contabilização para os embarques antes do periodo contabil
                      Reclock('EEQ',.F.)
                      EEQ->EEQ_NR_CON := STRZERO(nNR_Cont+1,4,0)
                      EEQ->(MSUNLOCK())
                      EEQ->(DBSEEK(cFilEEQ+EEC->EEC_NRINVO+'101'))
                   Endif
	            ENDIF
	            EEQ->(DBSKIP())
	         ENDDO   
	      ENDIF	       
       ENDIF
       DBSELECTAREA("EEC")
*/       
//----------------------------------------
	

	   EEM->(DbSeek(cFilEEM+EEC->EEC_PREEMB))   // Busca NF
	
	   If EEM->EEM_DTNF > dDta_Fim 
	      EEC->(DbSkip())
	      Loop  
	   Endif
       If lComiss
           DBSELECTAREA("EEC")
	  	   If !(Posicione("SX2",1,"EEC","X2_MODO") == "C" .and. !lPrimeira)
			   Do While EEM->(!Eof()) .And. cFilEEM = EEM->EEM_FILIAL .And. EEM->EEM_PREEMB = EEC->EEC_PREEMB

                  IF ((EEM->EEM_DTNF < dDta_Ini .and. !lNFAgain) .OR. (EEM->EEM_DTNF > dDta_Fim .and. !lNFAgain)) // MJA 21/07/05 Para trazer apenas as notas do mês contábil em questão		
//			      If EEM->EEM_DTNF > dDta_Fim 
			         EEM->(DbSkip())
			         Loop  
			      Endif
			
			      // Totalização dos Itens da NF
			      nVlItem := 0
			
			      // Taxa da NF
			      nTxNF   := If(lTemEEMNew, EEM->EEM_TXTB, ECOEXP999Tx(EEC->EEC_MOEDA, EEM->EEM_DTNF, cTX_101))
			      If EEM->EEM_DTNF >= dDta_Ini .and. EEM->EEM_DTNF <= dDta_Fim
			         nTxNFIni := If(lTemEEMNew, EEM->EEM_TXTB, ECOEXP999Tx(EEC->EEC_MOEDA, EEM->EEM_DTNF,cTX_101))
			      Else
			         nTxNFIni := ECOEXP999Tx(EEC->EEC_MOEDA, (dDta_Ini-1),cTX_101)
			      Endif
			     
//			      cCusto  := ""
                  cCustoNF   := ""
                  cCustoFRE  := ""
                  cCustoSEG  := "" 
                  cCustoOUT  := ""
                  cCustoCOM  := "" // VI 27/04/05
			                  
			      // Busca Itens da NF
			      EES->(DbSeek(cFilEES+EEM->EEM_PREEMB+EEM->EEM_NRNF))
			      DBSELECTAREA("EEC")
			      If !(Posicione("SX2",1,"EEC","X2_MODO") == "C" .and. !lPrimeira)
				      Do While EES->(!Eof()) .And. cFilEES = EES->EES_FILIAL .And. EES->EES_PREEMB = EEM->EEM_PREEMB .And. ;
				         EES->EES_NRNF = EEM->EEM_NRNF
				
				         If ! Empty(Val(EES->EES_NR_CON))
				            EES->(DBSKIP())
				            Loop
				         EndIf
	   
     
				         If lTemEESNew
				            // Localiza o EE9 o Item e seus respectivo C.Custos
				            If EE9->(DbSeek(cFilEE9+EES->EES_PREEMB+EES->EES_PEDIDO+EES->EES_SEQUEN))
//      		               cCusto := EE9->EE9_CC
                               cCustoNF   := EE9->EE9_CC
                               cCustoFRE  := EE9->EE9_CC
                               cCustoSEG  := EE9->EE9_CC
                               cCustoOUT  := EE9->EE9_CC
                               cCustoCOM  := EE9->EE9_CC // VI 27/04/05
				            Else
//				               cCusto := cCustoPad
                               cCustoNF   := cCustoPad
                               cCustoFRE  := cCustoPad
                               cCustoSEG  := cCustoPad
                               cCustoOUT  := cCustoPad
                               cCustoCOM  := cCustoPad // VI 27/04/05
				            Endif
				          
                            If(EasyEntryPoint("ECOPF999"),ExecBlock("ECOPF999",.F.,.F.,"LEITURA_EEM_CC"),) // VI 27/04/05
				
				// FOB
				            nPos := Ascan( aNF, { |x| x[1]=EEC->EEC_NRINVO .And. x[2]=EEM->EEM_NRNF .And. x[4]=cCustoNF })
				            If nPos > 0
				               aNF[nPos,3] += EES->EES_VLNF
				               aNF[nPos,8] += EES->EES_VLNFM
				            Else         //       1                2              3        4       5          6             7          8              9
				               AAdd(aNF, {EEC->EEC_NRINVO, EEM->EEM_NRNF, EES->EES_VLNF, cCustoNF, nTxNF, EEM->EEM_DTNF, nTxNFIni,EES->EES_VLNFM, EEM->EEM_PREEMB})
				            Endif
				
				            If !lTemRat107 .or. !lTemRatVC  
				               nPosAux := Ascan( aNFSemRat, { |x| x[1]=EEC->EEC_NRINVO .And. x[2]=EEM->EEM_NRNF })
				               If nPosAux > 0
				                  aNFSemRat[nPosAux,3] += EES->EES_VLNF
				                  aNFSemRat[nPosAux,8] += EES->EES_VLNFM                  
				               Else                //      1               2           3          4     5          6          7           8                9
				                  AAdd(aNFSemRat, {EEC->EEC_NRINVO, EEM->EEM_NRNF, EES->EES_VLNF, "", nTxNF, EEM->EEM_DTNF, nTxNFIni,EES->EES_VLNFM, EEM->EEM_PREEMB})
				               Endif            
				            EndIf
				
				            // Total da NF      
				            
				            nTotNF += If(!empty(EES->EES_VLNFM),EES->EES_VLNFM,EES->EES_VLNF/EEM->EEM_TXTB)
				
				// Frete **************************************************************************************************
				
				            if EES->EES_VLFREM > 0 .or. EES->EES_VLFRET > 0
					           nPosF := Ascan( aFrete, { |x| x[1]=EEC->EEC_NRINVO .And. x[2]=EEM->EEM_NRNF .And. x[5]=cCustoFRE })
					           If nPosF > 0
					              aFrete[nPosF,3] += if(!empty(EES->EES_VLFREM),EES->EES_VLFREM,IF(!EMPTY(EEM->EEM_TXFRET),EES->EES_VLFRET/EEM->EEM_TXFRET,EES->EES_VLFRET/EEM->EEM_TXTB))                             
					              aFrete[nPosF,4] += EES->EES_VLFRET               
					           Else            //        1             2                                                                3                                                                                4              5      6          7            8           9              10
					              AAdd(aFrete, {EEC->EEC_NRINVO, EEM->EEM_NRNF,if(!empty(EES->EES_VLFREM),EES->EES_VLFREM,IF(!EMPTY(EEM->EEM_TXFRET),EES->EES_VLFRET/EEM->EEM_TXFRET,EES->EES_VLFRET/EEM->EEM_TXTB)),EES->EES_VLFRET,cCustoFRE, nTxNF, EEM->EEM_DTNF, nTxNFIni,EEM->EEM_PREEMB,EEM->EEM_TXFRET})
					           Endif
					
					           If !lTemRat104 .or. !lTemRatVCF 
					              nPosFAux := Ascan( aFRSemRat, { |x| x[1]=EEC->EEC_NRINVO .And. x[2]=EEM->EEM_NRNF })
					              If nPosFAux > 0
					                 aFRSemRat[nPosFAux,3] += if(!empty(EES->EES_VLFREM),EES->EES_VLFREM,IF(!EMPTY(EEM->EEM_TXFRET),EES->EES_VLFRET/EEM->EEM_TXFRET,EES->EES_VLFRET/EEM->EEM_TXTB))
					                 aFRSemRat[nPosFAux,4] += EES->EES_VLFRET               
					              Else                //        1             2                                                                3                                                                                4          5     6          7            8           9             10
					                 AAdd(aFRSemRat, {EEC->EEC_NRINVO, EEM->EEM_NRNF,if(!empty(EES->EES_VLFREM),EES->EES_VLFREM,IF(!EMPTY(EEM->EEM_TXFRET),EES->EES_VLFRET/EEM->EEM_TXFRET,EES->EES_VLFRET/EEM->EEM_TXTB)),EES->EES_VLFRET,"", nTxNF, EEM->EEM_DTNF, nTxNFIni,EEM->EEM_PREEMB,EEM->EEM_TXFRET})
					              Endif            
					           EndIf
				            Endif
				            
				// Seguro **************************************************************************************************
				            If EES->EES_VLSEGM > 0 .or. EES->EES_VLSEGU > 0
					           nPosS := Ascan( aSeguro, { |x| x[1]=EEC->EEC_NRINVO .And. x[2]=EEM->EEM_NRNF .And. x[5]=cCustoSEG })
					           If nPosS > 0
					              aSeguro[nPosS,3] += if(!empty(EES->EES_VLSEGM),EES->EES_VLSEGM,IF(!EMPTY(EEM->EEM_TXSEGU),EES->EES_VLSEGU/EEM->EEM_TXSEGU,EES->EES_VLSEGU/EEM->EEM_TXTB))
					              aSeguro[nPosS,4] += EES->EES_VLSEGU
					           Else            //        1             2                                                                3                                                                                  4              5      6          7            8           9             10
					              AAdd(aSeguro, {EEC->EEC_NRINVO, EEM->EEM_NRNF,if(!empty(EES->EES_VLSEGM),EES->EES_VLSEGM,IF(!EMPTY(EEM->EEM_TXSEGU),EES->EES_VLSEGU/EEM->EEM_TXSEGU,EES->EES_VLSEGU/EEM->EEM_TXTB)),EES->EES_VLSEGU,cCustoSEG, nTxNF, EEM->EEM_DTNF, nTxNFIni,EEM->EEM_PREEMB,EEM->EEM_TXSEGU})
					           Endif
					              
					           If !lTemRat105 .or. !lTemRatVCS 
					              nPosSAux := Ascan( aSESemRat, { |x| x[1]=EEC->EEC_NRINVO .And. x[2]=EEM->EEM_NRNF })
					              If nPosSAux > 0
					                 aSESemRat[nPosSAux,3] += if(!empty(EES->EES_VLSEGM),EES->EES_VLSEGM,IF(!EMPTY(EEM->EEM_TXSEGU),EES->EES_VLSEGU/EEM->EEM_TXSEGU,EES->EES_VLSEGU/EEM->EEM_TXTB))
					                 aSESemRat[nPosSAux,4] += EES->EES_VLSEGU               
					              Else                //        1             2                                                                3                                                                                4          5     6          7            8           9
					                 AAdd(aSESemRat, {EEC->EEC_NRINVO, EEM->EEM_NRNF,if(!empty(EES->EES_VLSEGM),EES->EES_VLSEGM,IF(!EMPTY(EEM->EEM_TXSEGU),EES->EES_VLSEGU/EEM->EEM_TXSEGU,EES->EES_VLSEGU/EEM->EEM_TXTB)),EES->EES_VLSEGU,"", nTxNF, EEM->EEM_DTNF, nTxNFIni,EEM->EEM_PREEMB,EEM->EEM_TXSEGU})
					              Endif            
					           EndIf
					        Endif
 				// Outras Despesas ******************************************************************************************

				            If EES->EES_VLOUTM > 0 .or. EES->EES_VLOUTR > 0
					           nPosO := Ascan( aOutras, { |x| x[1]=EEC->EEC_NRINVO .And. x[2]=EEM->EEM_NRNF .And. x[5]=cCustoOUT })
					           If nPosO > 0
					              aOutras[nPosO,3] += if(!empty(EES->EES_VLOUTM),EES->EES_VLOUTM,IF(!EMPTY(EEM->EEM_TXOUDE),EES->EES_VLOUTR/EEM->EEM_TXOUDE,EES->EES_VLOUTR/EEM->EEM_TXTB))
					              aOutras[nPosO,4] += EES->EES_VLOUTR
					           Else            //        1             2                                                                3                                                                                  4              5      6          7            8           9             10
					              AAdd(aOutras, {EEC->EEC_NRINVO, EEM->EEM_NRNF,if(!empty(EES->EES_VLOUTM),EES->EES_VLOUTM,IF(!EMPTY(EEM->EEM_TXOUDE),EES->EES_VLOUTR/EEM->EEM_TXOUDE,EES->EES_VLOUTR/EEM->EEM_TXTB)),EES->EES_VLOUTR,cCustoOUT, nTxNF, EEM->EEM_DTNF, nTxNFIni,EEM->EEM_PREEMB,EEM->EEM_TXOUDE})
					           Endif
					              
					           If !lTemRat126 .or. !lTemRatVCO
					              nPosOAux := Ascan( aOUSemRat, { |x| x[1]=EEC->EEC_NRINVO .And. x[2]=EEM->EEM_NRNF })
					              If nPosOAux > 0
					                 aOUSemRat[nPosOAux,3] += if(!empty(EES->EES_VLOUTM),EES->EES_VLOUTM,IF(!EMPTY(EEM->EEM_TXOUDE),EES->EES_VLOUTR/EEM->EEM_TXOUDE,EES->EES_VLOUTR/EEM->EEM_TXTB))
					                 aOUSemRat[nPosOAux,4] += EES->EES_VLOUTR
					              Else                //        1             2                                                                3                                                                                4          5     6          7            8           9                10
					                 AAdd(aOUSemRat, {EEC->EEC_NRINVO, EEM->EEM_NRNF,if(!empty(EES->EES_VLOUTM),EES->EES_VLOUTM,IF(!EMPTY(EEM->EEM_TXOUDE),EES->EES_VLOUTR/EEM->EEM_TXOUDE,EES->EES_VLOUTR/EEM->EEM_TXTB)),EES->EES_VLOUTR,"", nTxNF, EEM->EEM_DTNF, nTxNFIni,EEM->EEM_PREEMB, EEM->EEM_TXOUDE})
					              Endif            
					           EndIf
					        Endif
				
				
				// Comissoes ******************************************************************************************
				
				            EEB->(DBSETORDER(1))
				            IF EEB->(DBSEEK(xFilial("EEB")+EES->EES_PREEMB+"Q"+EE9->EE9_CODAGE))
					           IF SUBSTR(EEB->EEB_TIPOAG,1,1) = '3' // Para somente obter Agentes com Comissao a Receber
					              
					              Do Case
					               	 Case EEB->EEB_TIPCOM = '1' // 123 Comissao a Remeter
				                          nPos1 := Ascan( aCom123, { |x| x[1]=EEC->EEC_NRINVO .And. x[2]=EEM->EEM_NRNF .And. x[5]=cCustoCOM .And. x[10]=EE9->EE9_CODAGE })
									      If nPos1 > 0
									         aCom123[nPos1,3] += IF(!EMPTY(EES->EES_VLMERM),(EES->EES_VLMERM/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM,((EES->EES_VLMERC/EEM->EEM_TXTB)/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM) // valor na Moeda
									         aCom123[nPos1,4] += IF(!EMPTY(EES->EES_VLMERM),((EES->EES_VLMERM/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM)*EEM->EEM_TXTB,(((EES->EES_VLMERC/EEM->EEM_TXTB)/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM)*EEM->EEM_TXTB) // Valor em Reais
									      Else            //        1             2                                                   3                                                                                                                                                         4                                                                                                                              5       6             7         8             9             10            
									         AAdd(aCom123, {EEC->EEC_NRINVO, EEM->EEM_NRNF,IF(!EMPTY(EES->EES_VLMERM),(EES->EES_VLMERM/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM,((EES->EES_VLMERC/EEM->EEM_TXTB)/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM),IF(!EMPTY(EES->EES_VLMERM),((EES->EES_VLMERM/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM)*EEM->EEM_TXTB,(((EES->EES_VLMERC/EEM->EEM_TXTB)/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM)*EEM->EEM_TXTB),cCustoCOM, nTxNF, EEM->EEM_DTNF, nTxNFIni,EEM->EEM_PREEMB,EE9->EE9_CODAGE})
									      Endif               
									  
									      If !lTemRat123 .or. !lTemRatVCR
									         nPos1Aux := Ascan( a123SemRat, { |x| x[1]=EEC->EEC_NRINVO .And. x[2]=EEM->EEM_NRNF .AND. x[10]=EE9->EE9_CODAGE})
									         If nPos1Aux > 0
									            a123SemRat[nPos1Aux,3] += IF(!EMPTY(EES->EES_VLMERM),(EES->EES_VLMERM/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM,((EES->EES_VLMERC/EEM->EEM_TXTB)/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM) // Valor na Moeda
									            a123SemRat[nPos1Aux,4] += IF(!EMPTY(EES->EES_VLMERM),((EES->EES_VLMERM/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM)*EEM->EEM_TXTB,(((EES->EES_VLMERC/EEM->EEM_TXTB)/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM)*EEM->EEM_TXTB) // Valor em Reais						                 
									         Else                //        1             2                                                          3                                                                                                                                                            4                                                                                                                5    6           7            8               9          10
									            AAdd(a123SemRat, {EEC->EEC_NRINVO, EEM->EEM_NRNF,IF(!EMPTY(EES->EES_VLMERM),(EES->EES_VLMERM/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM,((EES->EES_VLMERC/EEM->EEM_TXTB)/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM),IF(!EMPTY(EES->EES_VLMERM),((EES->EES_VLMERM/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM)*EEM->EEM_TXTB,(((EES->EES_VLMERC/EEM->EEM_TXTB)/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM)*EEM->EEM_TXTB),"", nTxNF, EEM->EEM_DTNF, nTxNFIni,EEM->EEM_PREEMB,EE9->EE9_CODAGE})
									         Endif
									      EndIf
					               	
					               	Case EEB->EEB_TIPCOM = '2' // 124 Comissao Conta Grafica
				                         nPos2 := Ascan( aCom124, { |x| x[1]=EEC->EEC_NRINVO .And. x[2]=EEM->EEM_NRNF .And. x[5]=cCustoCOM .And. x[10]=EE9->EE9_CODAGE })
									     If nPos2 > 0
									        aCom124[nPos2,3] += IF(!EMPTY(EES->EES_VLMERM),(EES->EES_VLMERM/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM,((EES->EES_VLMERC/EEM->EEM_TXTB)/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM) // valor na Moeda
									        aCom124[nPos2,4] += IF(!EMPTY(EES->EES_VLMERM),((EES->EES_VLMERM/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM)*EEM->EEM_TXTB,(((EES->EES_VLMERC/EEM->EEM_TXTB)/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM)*EEM->EEM_TXTB) // Valor em Reais
									     Else            //        1             2                                                   3                                                                                                                                                         4                                                                                                                              5        6           7           8            9             10           
									        AAdd(aCom124, {EEC->EEC_NRINVO, EEM->EEM_NRNF,IF(!EMPTY(EES->EES_VLMERM),(EES->EES_VLMERM/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM,((EES->EES_VLMERC/EEM->EEM_TXTB)/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM),IF(!EMPTY(EES->EES_VLMERM),((EES->EES_VLMERM/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM)*EEM->EEM_TXTB,(((EES->EES_VLMERC/EEM->EEM_TXTB)/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM)*EEM->EEM_TXTB),cCustoCOM, nTxNF, EEM->EEM_DTNF, nTxNFIni,EEM->EEM_PREEMB,EE9->EE9_CODAGE})
									     Endif               
                                         
                                         If !lTemRat124 .or. !lTemRatVCG
									        nPos2Aux := Ascan( a124SemRat, { |x| x[1]=EEC->EEC_NRINVO .And. x[2]=EEM->EEM_NRNF .AND. x[10]=EE9->EE9_CODAGE})
									        If nPos2Aux > 0
									           a124SemRat[nPos2Aux,3] += IF(!EMPTY(EES->EES_VLMERM),(EES->EES_VLMERM/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM,((EES->EES_VLMERC/EEM->EEM_TXTB)/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM) // Valor na Moeda
									           a124SemRat[nPos2Aux,4] += IF(!EMPTY(EES->EES_VLMERM),((EES->EES_VLMERM/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM)*EEM->EEM_TXTB,(((EES->EES_VLMERC/EEM->EEM_TXTB)/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM)*EEM->EEM_TXTB) // Valor em Reais						                 
									        Else                //        1             2                                                          3                                                                                                                                                            4                                                                                                                5    6           7            8               9          10
									           AAdd(a124SemRat, {EEC->EEC_NRINVO, EEM->EEM_NRNF,IF(!EMPTY(EES->EES_VLMERM),(EES->EES_VLMERM/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM,((EES->EES_VLMERC/EEM->EEM_TXTB)/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM),IF(!EMPTY(EES->EES_VLMERM),((EES->EES_VLMERM/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM)*EEM->EEM_TXTB,(((EES->EES_VLMERC/EEM->EEM_TXTB)/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM)*EEM->EEM_TXTB),"", nTxNF, EEM->EEM_DTNF, nTxNFIni,EEM->EEM_PREEMB,EE9->EE9_CODAGE})
									        Endif
									     EndIf	               			               			               			               	
					               	
					               	Otherwise // 125 Comissao a Deduzir da Fatura
				                         nPos3 := Ascan( aCom125, { |x| x[1]=EEC->EEC_NRINVO .And. x[2]=EEM->EEM_NRNF .And. x[5]=cCustoCOM .And. x[10]=EE9->EE9_CODAGE })
									     If nPos3 > 0
									        aCom125[nPos3,3] += IF(!EMPTY(EES->EES_VLMERM),(EES->EES_VLMERM/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM,((EES->EES_VLMERC/EEM->EEM_TXTB)/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM) // valor na Moeda
									        aCom125[nPos3,4] += IF(!EMPTY(EES->EES_VLMERM),((EES->EES_VLMERM/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM)*EEM->EEM_TXTB,(((EES->EES_VLMERC/EEM->EEM_TXTB)/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM)*EEM->EEM_TXTB) // Valor em Reais
									     Else            //        1             2                                                   3                                                                                                                                                         4                                                                                                                    5       6           7           8              9         10
									        AAdd(aCom125, {EEC->EEC_NRINVO, EEM->EEM_NRNF,IF(!EMPTY(EES->EES_VLMERM),(EES->EES_VLMERM/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM,((EES->EES_VLMERC/EEM->EEM_TXTB)/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM),IF(!EMPTY(EES->EES_VLMERM),((EES->EES_VLMERM/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM)*EEM->EEM_TXTB,(((EES->EES_VLMERC/EEM->EEM_TXTB)/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM)*EEM->EEM_TXTB),cCustoCOM, nTxNF, EEM->EEM_DTNF, nTxNFIni,EEM->EEM_PREEMB,EE9->EE9_CODAGE})
									     Endif               
									    
									     If !lTemRat125 .or. !lTemRatVCD
									        nPos3Aux := Ascan( a125SemRat, { |x| x[1]=EEC->EEC_NRINVO .And. x[2]=EEM->EEM_NRNF .AND. x[10]=EE9->EE9_CODAGE})
									        If nPos3Aux > 0
									           a125SemRat[nPos3Aux,3] += IF(!EMPTY(EES->EES_VLMERM),(EES->EES_VLMERM/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM,((EES->EES_VLMERC/EEM->EEM_TXTB)/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM) // Valor na Moeda
									           a125SemRat[nPos3Aux,4] += IF(!EMPTY(EES->EES_VLMERM),((EES->EES_VLMERM/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM)*EEM->EEM_TXTB,(((EES->EES_VLMERC/EEM->EEM_TXTB)/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM)*EEM->EEM_TXTB) // Valor em Reais						                 
									        Else                //        1             2                                                          3                                                                                                                                                            4                                                                                                                5    6           7            8               9          10
									           AAdd(a125SemRat, {EEC->EEC_NRINVO, EEM->EEM_NRNF,IF(!EMPTY(EES->EES_VLMERM),(EES->EES_VLMERM/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM,((EES->EES_VLMERC/EEM->EEM_TXTB)/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM),IF(!EMPTY(EES->EES_VLMERM),((EES->EES_VLMERM/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM)*EEM->EEM_TXTB,(((EES->EES_VLMERC/EEM->EEM_TXTB)/EEB->EEB_FOBAGE)*EEB->EEB_TOTCOM)*EEM->EEM_TXTB),"", nTxNF, EEM->EEM_DTNF, nTxNFIni,EEM->EEM_PREEMB,EE9->EE9_CODAGE})
									        Endif
                                         EndIf
					              EndCase
					           ENDIF
				            ENDIF

                            If(EasyEntryPoint("ECOPF999"),ExecBlock("ECOPF999",.F.,.F.,"FIM_APURACAO_ITENS_NF"),) // VI 27/04/05
						         		
				            // Efetivacao
				            If lTemEESNew .And. cPrv_Efe = "2"
				               Reclock("EES", .F.)
				               EES->EES_NR_CON := STRZERO(nNR_Cont+1,4,0)
				               EES->(MsUnlock())
				            Endif				         			
				         Endif
				         EES->(DbSkip())
				      Enddo
				   ENDIF   
				   EEM->(DbSkip())
			   Enddo
		   ENDIF
	   Endif
	 
	   // Chamada de Funcao para calcular as comissoes na NF
       If lComiss
          
          ////////////////////////////////////////////////////////////////
          //ER - 23/10/2007                                             //
          //Verificação de Comissões não vinculadas a Itens do Embarque,//
          //mas que devem ser contabilizadas.                           //
          //                                                            //
          //O valor dessas comissões será rateado pelo valor total de   //
          //todas as NFs do Embarque.                                   //
          ////////////////////////////////////////////////////////////////
          
          //Verifica o valor total das NFs
          nVlTotalNF := 0
          For nInc := 1 to Len(aNf)
             nVlTotalNF += aNf[nInc][8]
          Next
          
          //Verifica as Comissões não vinculadas
          EEB->(DBSETORDER(1))
          If EEB->(DBSEEK(xFilial("EEB")+EEC->EEC_PREEMB+"Q"))
             While EEB->(!EOF()) .and. EEB->(EEB_FILIAL+EEB_PEDIDO+EEB_OCORRE) == xFilial("EEB")+EEC->EEC_PREEMB+"Q"
                
                //Verifica se o tipo do Agente é de Comissão
                If Left(EEB->EEB_TIPOAG,1) <> '3'      
                   EEB->(DbSkip())
                   Loop
                EndIf
                
                //Verifica se há comissão para o Agente
                If EEB->EEB_TOTCOM == 0
                   EEB->(DbSkip())
                   Loop                
                EndIf
                
                Do Case
                   
                   // 123 Comissao a Remeter
                   Case EEB->EEB_TIPCOM = "1"
                        
                        //Verifica se o Agente foi vinculado a algum item.
                        nPos1 := aScan( aCom123, { |x|  x[10] == EEB->EEB_CODAGE})

                        If nPos1 == 0
                           
                           For nInc := 1 to Len(aNf)
                              
                              //Valor da Comissão Rateado por NF
                              nComRatNf := (aNf[nInc][8] / nVlTotalNF) * EEB->EEB_TOTCOM 
                              //                    1              2             3                4                    5         6               7            8           9              10
                              aAdd(aCom123, {EEC->EEC_NRINVO, aNF[nInc][2] , nComRatNf ,nComRatNf * aNf[nInc][5] ,cCustoCOM, aNf[nInc][5], aNf[nInc][6], aNf[nInc][7], EEC->EEC_PREEMB,EEB->EEB_CODAGE})
                        
                              If !lTemRat123 .or. !lTemRatVCR
                                 //                      1              2              3                4                5     6                 7            8             9                10
                                 aAdd(a123SemRat, {EEC->EEC_NRINVO, aNF[nInc][2] , nComRatNf ,nComRatNf * aNf[nInc][5] ,"", aNf[nInc][5], aNf[nInc][6], aNf[nInc][7], EEC->EEC_PREEMB,EEB->EEB_CODAGE})                                 
                              EndIf
                        
                           Next
                        
                        Endif               

                   // 124 Comissao Conta Grafica
                   Case EEB->EEB_TIPCOM = "2"
                        
                        //Verifica se o Agente foi vinculado a algum item.
                        nPos2 := aScan( aCom124, { |x|  x[10] == EEB->EEB_CODAGE})

                        If nPos2 == 0
                           
                           For nInc := 1 to Len(aNf)
                              
                              //Valor da Comissão Rateado por NF
                              nComRatNf := (aNf[nInc][8] / nVlTotalNF) * EEB->EEB_TOTCOM 
                              //                    1              2             3                 4                  5           6             7            8               9              10
                              aAdd(aCom124, {EEC->EEC_NRINVO, aNF[nInc][2] , nComRatNf ,nComRatNf * aNf[nInc][5] ,cCustoCOM, aNf[nInc][5], aNf[nInc][6], aNf[nInc][7] ,EEC->EEC_PREEMB,EEB->EEB_CODAGE})
                        
                              If !lTemRat124 .or. !lTemRatVCR
                                 //                      1              2              3                4                5        6           7              8             9              10
                                 aAdd(a124SemRat, {EEC->EEC_NRINVO, aNF[nInc][2] , nComRatNf ,nComRatNf * aNf[nInc][5] ,"", aNf[nInc][5], aNf[nInc][6], aNf[nInc][7] ,EEC->EEC_PREEMB,EEB->EEB_CODAGE})                                 
                              EndIf
                        
                           Next
                        
                        Endif               

                   // 125 Comissao a Deduzir da Fatura
                   Case EEB->EEB_TIPCOM = "3"
                        
                        //Verifica se o Agente foi vinculado a algum item.
                        nPos3 := aScan( aCom125, { |x|  x[10] == EEB->EEB_CODAGE})

                        If nPos3 == 0
                           
                           For nInc := 1 to Len(aNf)
                              
                              //Valor da Comissão Rateado por NF
                              nComRatNf := (aNf[nInc][8] / nVlTotalNF) * EEB->EEB_TOTCOM                        
                              //                    1              2             3                4                    5         6               7             8            9                 10
                              aAdd(aCom125, {EEC->EEC_NRINVO, aNF[nInc][2] , nComRatNf ,nComRatNf * aNf[nInc][5] ,cCustoCOM, aNf[nInc][5], aNf[nInc][6], aNf[nInc][7] ,EEC->EEC_PREEMB,EEB->EEB_CODAGE})
                        
                              If !lTemRat125 .or. !lTemRatVCR
                                 //                      1              2              3               4                5         6             7            8                9              10
                                 aAdd(a125SemRat, {EEC->EEC_NRINVO, aNF[nInc][2] , nComRatNf ,nComRatNf * aNf[nInc][5] ,"", aNf[nInc][5], aNf[nInc][6], aNf[nInc][7] ,EEC->EEC_PREEMB,EEB->EEB_CODAGE})                                 
                              EndIf
                        
                           Next
                        
                        Endif                                  

                End Case
          
                EEB->(DbSkip())
             EndDo
          EndIf
          
          Comiss_NF(aCom123,a123SemRat,aCom124,a124SemRat,aCom125,a125SemRat,nTxFimMes,nTxEmbarq,dDta_Fim,dDta_Ini,dDta_FimAux,dDataEmbAux)
       Endif    
	
	// Taxas para as Despesas de Frete, Seguro e Outras Despesas
   if len(aNF) > 0 .and. lComiss
      EXL->(DbSeek(cFilEXL+aNF[1,9]))
      
      IniMesFR := ECOEXP999Tx(IF(EMPTY(EXL->EXL_MDFR),EEC->EEC_MOEDA,EXL->EXL_MDFR), dDta_Ini, cTX_101)
	   IniMesSE := ECOEXP999Tx(IF(EMPTY(EXL->EXL_MDSE),EEC->EEC_MOEDA,EXL->EXL_MDSE), dDta_Ini, cTX_101)
	   IniMesOU := ECOEXP999Tx(IF(EMPTY(EXL->EXL_MDDI),EEC->EEC_MOEDA,EXL->EXL_MDDI), dDta_Ini, cTX_101)
      
	   FimMesFR := ECOEXP999Tx(IF(EMPTY(EXL->EXL_MDFR),EEC->EEC_MOEDA,EXL->EXL_MDFR), dDta_Fim, cTX_101)
	   FimMesSE := ECOEXP999Tx(IF(EMPTY(EXL->EXL_MDSE),EEC->EEC_MOEDA,EXL->EXL_MDSE), dDta_Fim, cTX_101)
	   FimMesOU := ECOEXP999Tx(IF(EMPTY(EXL->EXL_MDDI),EEC->EEC_MOEDA,EXL->EXL_MDDI), dDta_Fim, cTX_101)
	   
	   EmbarqFR := ECOEXP999Tx(IF(EMPTY(EXL->EXL_MDFR),EEC->EEC_MOEDA,EXL->EXL_MDFR), dDataEmbAux, cTX_101) 
	   EmbarqSE := ECOEXP999Tx(IF(EMPTY(EXL->EXL_MDSE),EEC->EEC_MOEDA,EXL->EXL_MDSE), dDataEmbAux, cTX_101) 
	   EmbarqOU := ECOEXP999Tx(IF(EMPTY(EXL->EXL_MDDI),EEC->EEC_MOEDA,EXL->EXL_MDDI), dDataEmbAux, cTX_101) 
	   
     	/*
     	IniMesFR := ECOEXP999Tx(EEC->EEC_MOEDA, dDta_Ini, cTX_101)
	   IniMesSE := ECOEXP999Tx(EEC->EEC_MOEDA, dDta_Ini, cTX_101)
	   IniMesOU := ECOEXP999Tx(EEC->EEC_MOEDA, dDta_Ini, cTX_101)
      
	   FimMesFR := ECOEXP999Tx(EEC->EEC_MOEDA, dDta_Fim, cTX_101)
	   FimMesSE := ECOEXP999Tx(EEC->EEC_MOEDA, dDta_Fim, cTX_101)
	   FimMesOU := ECOEXP999Tx(EEC->EEC_MOEDA, dDta_Fim, cTX_101)
	   
	   EmbarqFR := ECOEXP999Tx(EEC->EEC_MOEDA, dDataEmbAux, cTX_101) 
	   EmbarqSE := ECOEXP999Tx(EEC->EEC_MOEDA, dDataEmbAux, cTX_101) 
	   EmbarqOU := ECOEXP999Tx(EEC->EEC_MOEDA, dDataEmbAux, cTX_101) 
      */
   endif
   
// Frete
*************************************************************************************************************
*********************************************/* Frete */*****************************************************
*************************************************************************************************************
   if lFESEOD
      if Len(aFrete) > 0
	     If lTemRat104 .or. lTemRatVCF
	        For i:=1 to Len(aFrete)
	             // Tx da NF
	             nTxNF := aFrete[i,10]
	             // Evento de Frete
	             If lTemRat104 .and. aFrete[i,7] >= dDta_Ini .and. aFrete[i,7] <= dDta_Fim
	                //                     1        2     3       4         5         6                                   7                            8        9      10      11        12           13        14  15  16  17  18      19          20       21 22 |            23            |                        24                          |25  26 27    28
	                AAdd(aDadosPRV, {aFrete[i,4], '104', "", aFrete[i,1], '104', aFrete[i,7], IF(EMPTY(EXL->EXL_MDFR),EEC->EEC_MOEDA,EXL->EXL_MDFR), nTxNF, nTxFimMes, "", aFrete[i,5], 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aFrete[i,2], aFrete[i,7], 0, 0,(aFrete[i,3]*IF(EXL->EXL_PAFR = 0,1,EXL->EXL_PAFR)),IF(EMPTY(EXL->EXL_FOFR),EEC->EEC_FORN,EXL->EXL_FOFR),"2","","",cFilEEM,""})
	                //AAdd(aDadosPRV, {aFrete[i,4], '104', "", aFrete[i,1], '104', aFrete[i,7], EEC->EEC_MOEDA, nTxNF, nTxFimMes, "", aFrete[i,5], 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aFrete[i,2], aFrete[i,7], 0, 0,(aFrete[i,4] / nTxNF),EEC->EEC_FORN,"2","","",cFilEEM})	                
	             EndIf
	
	             // V.Cambial do Frete
	             If lTemRatVCF
	                If Empty(dDataEmbAux)// .OR. aFrete[i,7] <= dDataEmbAux)
	                   nTaxaAux:= FimMesFR
	                Else
	                   nTaxaAux:= EmbarqFR
	                EndIf      //          Vl Moe
                    nTxReal := ECOEXP999Tx(IF(EMPTY(EXL->EXL_MDFR),EEC->EEC_MOEDA,EXL->EXL_MDFR), (dDta_Ini-1), cTX_101)	                
                    If aFrete[i,7] >= (dDta_Ini) .And. aFrete[i,7] <= dDta_Fim 
	                   nVariacao := IF(!EMPTY(aFrete[i,3]), (aFrete[i,3] * if(EXL->EXL_PAFR <> 0,EXL->EXL_PAFR,1)) * nTaxaAux - aFrete[i,4],((aFrete[i,4] / nTxNF)* if(EXL->EXL_PAFR <> 0,EXL->EXL_PAFR,1)) * nTaxaAux - ((aFrete[i,4] / nTxNF) * if(EXL->EXL_PAFR <> 0,EXL->EXL_PAFR,1)) * aFrete[i,4])  //nTxNFIni
                     Else
                       nVariacao := IF(!EMPTY(aFrete[i,3]), (aFrete[i,3] * if(EXL->EXL_PAFR <> 0,EXL->EXL_PAFR,1)) * nTaxaAux - aFrete[i,3] * nTxReal,((aFrete[i,4] / nTxNF)* if(EXL->EXL_PAFR <> 0,EXL->EXL_PAFR,1)) * nTaxaAux - ((aFrete[i,4] / nTxNF) * if(EXL->EXL_PAFR <> 0,EXL->EXL_PAFR,1)) * nTxReal)  //nTxNFIni
                    EndIf
	                
//	                If nVariacao <> 0  //     1                     2               3       4                       5                      6                              7                                  8                9           10    11         12         13          14  15  16  17  18       19            20         21                22          23
	                   AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, '530', '531'), "", aFrete[i,1], If(nVariacao > 0, '530', '531'), dDta_FimAux, IF(EMPTY(EXL->EXL_MDFR),EEC->EEC_MOEDA,EXL->EXL_MDFR), nTaxaAux , nTxNF*EXL->EXL_PAFR, "",aFrete[i,5], 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aFrete[i,2], aFrete[i,7], (aFrete[i,3] / nTxNF)*EXL->EXL_PAFR, 0,(aFrete[i,3]*IF(EXL->EXL_PAFR = 0,1,EXL->EXL_PAFR)),IF(EMPTY(EXL->EXL_FOFR),EEC->EEC_FORN,EXL->EXL_FOFR),"2","","",cFilEEM,""} ) //Alcir Alves - 19-07-05 - a posição 8 foi mudada para nTaxaAux
	                  //AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, '530', '531'), "", aFrete[i,1], If(nVariacao > 0, '530', '531'), dDta_FimAux, EEC->EEC_MOEDA, nTxFimMes, nTxNF, "",aFrete[i,5], 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aFrete[i,2], aFrete[i,7], (aFrete[i,4] / nTxNF), 0,(aFrete[i,4] / nTxNF),EEC->EEC_FORN,"2","","",cFilEEM,""} )
//	                Endif
	             EndIf
	         Next              
	      endif                      
	      If !lTemRat104 .or. !lTemRatVCF
	         For i:=1 to Len(aFRSemRat)
	             // Tx da NF
	             nTxNF := aFRSemRat[i,10]
	             // Evento de Frete
	             If !lTemRat104 .and. aFRSemRat[i,7] >= dDta_Ini .and. aFRSemRat[i,7] <= dDta_Fim
	                AAdd(aDadosPRV, {aFRSemRat[i,4], '104', "", aFRSemRat[i,1], '104', aFRSemRat[i,7], IF(EMPTY(EXL->EXL_MDFR),EEC->EEC_MOEDA,EXL->EXL_MDFR), nTxNF, nTxFimMes, "", "", 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aFRSemRat[i,2], aFRSemRat[i,7], 0, 0,(aFrete[i,3]*IF(EXL->EXL_PAFR = 0,1,EXL->EXL_PAFR)),IF(EMPTY(EXL->EXL_FOFR),EEC->EEC_FORN,EXL->EXL_FOFR),"2","","",cFilEEM,""})
	                //AAdd(aDadosPRV, {aFRSemRat[i,4], '104', "", aFRSemRat[i,1], '104', aFRSemRat[i,7], EEC->EEC_MOEDA, nTxNF, nTxFimMes, "", "", 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aFRSemRat[i,2], aFRSemRat[i,7], 0, 0,(aFRSemRat[i,4] / nTxNF),EEC->EEC_FORN,"2","","",cFilEEM})
	             EndIf
	
	             // V.Cambial do Frete
	             If !lTemRatVCF
	                If Empty(dDataEmbAux) //.OR. aFRSemRat[i,7] <= dDataEmbAux)
	                   nTaxaAux:= FimMesFR
	                Else
	                   nTaxaAux:= EmbarqFR
	                EndIf
                    nTxReal := ECOEXP999Tx(IF(EMPTY(EXL->EXL_MDFR),EEC->EEC_MOEDA,EXL->EXL_MDFR), (dDta_Ini-1), cTX_101)	                	                
                    If aFRSemRat[i,7] >= (dDta_Ini) .And. aFRSemRat[i,7] <= dDta_Fim 
	                   nVariacao := IF(!EMPTY(aFRSemRat[i,3]), (aFRSemRat[i,3] * if(EXL->EXL_PAFR <> 0,EXL->EXL_PAFR,1)) * nTaxaAux - aFRSemRat[i,4],((aFRSemRat[i,4] / nTxNF)* if(EXL->EXL_PAFR <> 0,EXL->EXL_PAFR,1)) * nTaxaAux - ((aFRSemRat[i,4] / nTxNF) * if(EXL->EXL_PAFR <> 0,EXL->EXL_PAFR,1)) * aFRSemRat[i,4])  //nTxNFIni
                     Else
                       nVariacao := IF(!EMPTY(aFRSemRat[i,3]), (aFRSemRat[i,3] * if(EXL->EXL_PAFR <> 0,EXL->EXL_PAFR,1)) * nTaxaAux - aFRSemRat[i,3] * nTxReal,((aFRSemRat[i,4] / nTxNF)* if(EXL->EXL_PAFR <> 0,EXL->EXL_PAFR,1)) * nTaxaAux - ((aFRSemRat[i,4] / nTxNF) * if(EXL->EXL_PAFR <> 0,EXL->EXL_PAFR,1)) * nTxReal)  //nTxNFIni
                    EndIf
	                

//	                If nVariacao <> 0
	                   AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, '530', '531'), "", aFRSemRat[i,1], If(nVariacao > 0, '530', '531'), dDta_FimAux, IF(EMPTY(EXL->EXL_MDFR),EEC->EEC_MOEDA,EXL->EXL_MDFR), nTaxaAux, nTxNF*EXL->EXL_PAFR, "", aFRSemRat[i,5], 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aFRSemRat[i,2], aFRSemRat[i,7], (aFRSemRat[i,4] / nTxNF)*EXL->EXL_PAFR, 0,(aFrete[i,3]*IF(EXL->EXL_PAFR = 0,1,EXL->EXL_PAFR)),IF(EMPTY(EXL->EXL_FOFR),EEC->EEC_FORN,EXL->EXL_FOFR),"2","","",cFilEEM,""} ) //Alcir Alves - 19-07-05 - a posição 8 foi mudada para nTaxaAux
	                   //AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, '530', '531'), "", aFRSemRat[i,1], If(nVariacao > 0, '530', '531'), dDta_FimAux, EEC->EEC_MOEDA, nTxFimMes, nTxNF, "", aFRSemRat[i,5], 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aFRSemRat[i,2], aFRSemRat[i,7], (aFRSemRat[i,4] / nTxNF), 0,(aFRSemRat[i,4] / nTxNF),EEC->EEC_FORN,"2","","",cFilEEM } )	                   
//	                Endif
	             EndIf
	         Next              
	      endif                 
	   endif   
	// Seguro 
	*************************************************************************************************************
	*********************************************/* Seguro */****************************************************
	*************************************************************************************************************
	   if Len(aSeguro) > 0
	      If lTemRat105 .or. lTemRatVCS
	         For i:=1 to Len(aSeguro)
	             // Tx do Seguro
	             nTxNF := aSeguro[i,10]
	             // Evento de Seguro
	             If lTemRat105 .and. aSeguro[i,7] >= dDta_Ini .and. aSeguro[i,7] <= dDta_Fim
	                AAdd(aDadosPRV, {aSeguro[i,4], '105', "", aSeguro[i,1], '105', aSeguro[i,7], IF(EMPTY(EXL->EXL_MDSE),EEC->EEC_MOEDA,EXL->EXL_MDSE), nTxNF, nTxFimMes, "", aSeguro[i,5], 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aSeguro[i,2], aSeguro[i,7], 0, 0,(aSeguro[i,3]*IF(EXL->EXL_PASE=0,1,EXL->EXL_PASE)),IF(EMPTY(EXL->EXL_FOSE),EEC->EEC_FORN,EXL->EXL_FOSE),"2","","",cFilEEM,""})
	                //AAdd(aDadosPRV, {aSeguro[i,4], '105', "", aSeguro[i,1], '105', aSeguro[i,7], EEC->EEC_MOEDA, nTxNF, nTxFimMes, "", aSeguro[i,5], 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aSeguro[i,2], aSeguro[i,7], 0, 0,(aSeguro[i,4] / nTxNF),EEC->EEC_FORN,"2","","",cFilEEM})
	             EndIf
	
	             // V.Cambial do Seguro
	             If lTemRatVCS
	                If Empty(dDataEmbAux) //.OR. aSeguro[i,7] <= dDataEmbAux)
	                   nTaxaAux:= FimMesSE
	                Else
	                   nTaxaAux:= EmbarqSE  // * ECG->ECG_ULT_TX
	                EndIf
                    nTxReal := ECOEXP999Tx(IF(EMPTY(EXL->EXL_MDSE),EEC->EEC_MOEDA,EXL->EXL_MDSE), (dDta_Ini-1), cTX_101)	                
                    If aSeguro[i,7] >= (dDta_Ini) .And. aSeguro[i,7] <= dDta_Fim 
    	               nVariacao := IF(!EMPTY(aSeguro[i,3]), (aSeguro[i,3] * if(EXL->EXL_PASE <> 0,EXL->EXL_PASE,1)) * nTaxaAux - aSeguro[i,4],((aSeguro[i,4] / nTxNF)* if(EXL->EXL_PASE <> 0,EXL->EXL_PASE,1)) * nTaxaAux - ((aSeguro[i,4] / nTxNF) * if(EXL->EXL_PASE <> 0,EXL->EXL_PASE,1)) * aSeguro[i,4])  //nTxNFIni
                     Else
    	               nVariacao := IF(!EMPTY(aSeguro[i,3]), (aSeguro[i,3] * if(EXL->EXL_PASE <> 0,EXL->EXL_PASE,1)) * nTaxaAux - aSeguro[i,3] * nTxReal,((aSeguro[i,4] / nTxNF)* if(EXL->EXL_PASE <> 0,EXL->EXL_PASE,1)) * nTaxaAux - ((aSeguro[i,4] / nTxNF) * if(EXL->EXL_PASE <> 0,EXL->EXL_PASE,1)) * nTxReal)  //nTxNFIni
                    EndIf
	                
//	                If nVariacao <> 0
	                   AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, '532', '533'), "", aSeguro[i,1], If(nVariacao > 0, '532', '533'), dDta_FimAux, IF(EMPTY(EXL->EXL_MDSE),EEC->EEC_MOEDA,EXL->EXL_MDSE), nTaxaAux, nTxNF*EXL->EXL_PASE, "", aSeguro[i,5], 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aSeguro[i,2], aSeguro[i,7], (aSeguro[i,4] / nTxNF)*EXL->EXL_PASE, 0,(aSeguro[i,4] / nTxNF)*EXL->EXL_PASE,IF(EMPTY(EXL->EXL_FOSE),EEC->EEC_FORN,EXL->EXL_FOSE),"2","","",cFilEEM,""} ) //Alcir Alves - 19-07-05 - a posição 8 foi mudada para nTaxaAux
                     //AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, '532', '533'), "", aSeguro[i,1], If(nVariacao > 0, '532', '533'), dDta_FimAux, EEC->EEC_MOEDA, nTxFimMes, nTxNF, "", aSeguro[i,5], 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aSeguro[i,2], aSeguro[i,7], (aSeguro[i,4] / nTxNF), 0,(aSeguro[i,4] / nTxNF),EEC->EEC_FORN,"2","","",cFilEEM } )	                   
//	                Endif
	             EndIf
	         Next              
	      endif                      
	      If !lTemRat105 .or. !lTemRatVCS
	         For i:=1 to Len(aSESemRat)
	             // Tx do Seguro
	             nTxNF := aSESemRat[i,10]
	             // Evento de Seguro
	             If !lTemRat105 .and. aSESemRat[i,7] >= dDta_Ini .and. aSESemRat[i,7] <= dDta_Fim
	                AAdd(aDadosPRV, {aSESemRat[i,4], '105', "", aSESemRat[i,1], '105', aSESemRat[i,7], IF(EMPTY(EXL->EXL_MDSE),EEC->EEC_MOEDA,EXL->EXL_MDSE), nTxNF, nTxFimMes, "", "", 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aSESemRat[i,2], aSESemRat[i,7], 0, 0,(aSeguro[i,3]*IF(EXL->EXL_PASE=0,1,EXL->EXL_PASE)),IF(EMPTY(EXL->EXL_FOSE),EEC->EEC_FORN,EXL->EXL_FOSE),"2","","",cFilEEM,""})
	               // AAdd(aDadosPRV, {aSESemRat[i,4], '105', "", aSESemRat[i,1], '105', aSESemRat[i,7], EEC->EEC_MOEDA, nTxNF, nTxFimMes, "", "", 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aSESemRat[i,2], aSESemRat[i,7], 0, 0,(aSESemRat[i,4] / nTxNF),EEC->EEC_FORN,"2","","",cFilEEM})	                
	             EndIf
	
	             // V.Cambial do Seguro
	             If !lTemRatVCS
	                If Empty(dDataEmbAux) // .OR. aSESemRat[i,7] <= dDataEmbAux)
	                   nTaxaAux:= FimMesSE
	                Else
	                   nTaxaAux:= EmbarqSE
	                EndIf
                    nTxReal := ECOEXP999Tx(IF(EMPTY(EXL->EXL_MDSE),EEC->EEC_MOEDA,EXL->EXL_MDSE), (dDta_Ini-1), cTX_101)	                
                    If aSESemRat[i,7] >= (dDta_Ini) .And. aSESemRat[i,7] <= dDta_Fim 
	                   nVariacao := IF(!EMPTY(aSESemRat[i,3]), (aSESemRat[i,3] * if(EXL->EXL_PASE <> 0,EXL->EXL_PASE,1)) * nTaxaAux - aSESemRat[i,4],((aSESemRat[i,4] / nTxNF)* if(EXL->EXL_PASE <> 0,EXL->EXL_PASE,1)) * nTaxaAux - ((aSESemRat[i,4] / nTxNF) * if(EXL->EXL_PASE <> 0,EXL->EXL_PASE,1)) * aSESemRat[i,4])  //nTxNFIni
                     Else
   	                   nVariacao := IF(!EMPTY(aSESemRat[i,3]), (aSESemRat[i,3] * if(EXL->EXL_PASE <> 0,EXL->EXL_PASE,1)) * nTaxaAux - aSESemRat[i,3] * nTxReal,((aSESemRat[i,4] / nTxNF)* if(EXL->EXL_PASE <> 0,EXL->EXL_PASE,1)) * nTaxaAux - ((aSESemRat[i,4] / nTxNF) * if(EXL->EXL_PASE <> 0,EXL->EXL_PASE,1)) * nTxReal)  //nTxNFIni
                    EndIf
	                
//	                If nVariacao <> 0
	                   AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, '532', '533'), "", aSESemRat[i,1], If(nVariacao > 0, '532', '533'), dDta_FimAux, IF(EMPTY(EXL->EXL_MDSE),EEC->EEC_MOEDA,EXL->EXL_MDSE), nTaxaAux, nTxNF*EXL->EXL_PASE, "", aSESemRat[i,5], 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aSESemRat[i,2], aSESemRat[i,7], (aSESemRat[i,4] / nTxNF)*EXL->EXL_PASE, 0,(aSeguro[i,3]*IF(EXL->EXL_PASE=0,1,EXL->EXL_PASE)),IF(EMPTY(EXL->EXL_FOSE),EEC->EEC_FORN,EXL->EXL_FOSE),"2","","",cFilEEM,""} ) //Alcir Alves - 19-07-05 - a posição 8 foi mudada para nTaxaAux
	                   //AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, '532', '533'), "", aSESemRat[i,1], If(nVariacao > 0, '532', '533'), dDta_FimAux, EEC->EEC_MOEDA, nTxFimMes, nTxNF, "", aSESemRat[i,5], 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aSESemRat[i,2], aSESemRat[i,7], (aSESemRat[i,4] / nTxNF), 0,(aSESemRat[i,4] / nTxNF),EEC->EEC_FORN,"2","","",cFilEEM } )	                   
//	                Endif
	             EndIf
	         Next              
	      endif                 
	   endif
	
	*************************************************************************************************************
	*****************************************/* Outras Despesas */***********************************************
	*************************************************************************************************************

    lGrvOutDesp := .T.

    If(EasyEntryPoint("ECOPF999"),ExecBlock("ECOPF999",.F.,.F.,"INICIO_GRV_OUTRAS_DESP"),) // VI 27/04/05

    If lGrvOutDesp 
		   if Len(aOutras) > 0
		      If lTemRat126 .or. lTemRatVCO
		         For i:=1 to Len(aOutras)
		             // Tx de Outras Despesas
		             nTxNF := aOutras[i,10]
		             // Evento de Outras Despesas
		             If lTemRat126 .and. aOutras[i,7] >= dDta_Ini .and. aOutras[i,7] <= dDta_Fim             
		                AAdd(aDadosPRV, {aOutras[i,4], '126', "", aOutras[i,1], '126', aOutras[i,7], IF(EMPTY(EXL->EXL_MDDI),EEC->EEC_MOEDA,EXL->EXL_MDDI), nTxNF, nTxFimMes, "", aOutras[i,5], 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aOutras[i,2], aOutras[i,7], 0, 0,(aOutras[i,3]*IF(EXL->EXL_PADI=0,1,EXL->EXL_PADI)),IF(EMPTY(EXL->EXL_FODI),EEC->EEC_FORN,EXL->EXL_FODI),"2","","",cFilEEM,""}) // VI 08/12/05
		                //AAdd(aDadosPRV, {aOutras[i,4], '126', "", aOutras[i,1], '126', aOutras[i,7], EEC->EEC_MOEDA, nTxNF, nTxFimMes, "", aOutras[i,5], 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aOutras[i,2], aOutras[i,7], 0, 0,(aOutras[i,4] / nTxNF),EEC->EEC_FORN,"2","","",cFilEEM})
		                If(EasyEntryPoint("ECOPF999"),ExecBlock("ECOPF999",.F.,.F.,"OUT_DESP"),)
		             EndIf
		
		             // V.Cambial de Outras Despesas
		             If lTemRatVCO
		                If Empty(dDataEmbAux) //.OR. aOutras[i,7] <= dDataEmbAux)
		                   nTaxaAux:= FimMesOU
		                Else
		                   nTaxaAux:= EmbarqOU
		                EndIf
                        nTxReal := ECOEXP999Tx(IF(EMPTY(EXL->EXL_MDDI),EEC->EEC_MOEDA,EXL->EXL_MDDI), (dDta_Ini-1), cTX_101)		                
                        If aOutras[i,7] >= (dDta_Ini) .And. aOutras[i,7] <= dDta_Fim 
		                   nVariacao := IF(!EMPTY(aOutras[i,3]), (aOutras[i,3] * if(EXL->EXL_PADI <> 0,EXL->EXL_PADI,1)) * nTaxaAux - aOutras[i,4],((aOutras[i,4] / nTxNF)* if(EXL->EXL_PADI <> 0,EXL->EXL_PADI,1)) * nTaxaAux - ((aOutras[i,4] / nTxNF) * if(EXL->EXL_PADI <> 0,EXL->EXL_PADI,1)) * aOutras[i,4])  //nTxNFIni
                         Else
  	                       nVariacao := IF(!EMPTY(aOutras[i,3]), (aOutras[i,3] * if(EXL->EXL_PADI <> 0,EXL->EXL_PADI,1)) * nTaxaAux - aOutras[i,3] * nTxReal,((aOutras[i,4] / nTxNF)* if(EXL->EXL_PADI <> 0,EXL->EXL_PADI,1)) * nTaxaAux - ((aOutras[i,4] / nTxNF) * if(EXL->EXL_PADI <> 0,EXL->EXL_PADI,1)) * nTxReal)  //nTxNFIni
                        EndIf
		                

//		                If nVariacao <> 0
		                   AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, '540', '541'), "", aOutras[i,1], If(nVariacao > 0, '540', '541'), dDta_FimAux, IF(EMPTY(EXL->EXL_MDDI),EEC->EEC_MOEDA,EXL->EXL_MDDI), nTaxaAux, nTxNF*EXL->EXL_PADI, "", aOutras[i,5], 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aOutras[i,2], aOutras[i,7], (aOutras[i,4] / nTxNF)*EXL->EXL_PADI, 0,(aOutras[i,3]*IF(EXL->EXL_PADI=0,1,EXL->EXL_PADI)),IF(EMPTY(EXL->EXL_FODI),EEC->EEC_FORN,EXL->EXL_FODI),"2","","",cFilEEM,""} ) //Alcir Alves - 19-07-05 - a posição 8 foi mudada para nTaxaAux
		                   //AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, '540', '541'), "", aOutras[i,1], If(nVariacao > 0, '540', '541'), dDta_FimAux, EEC->EEC_MOEDA, nTxFimMes, nTxNF, "", aOutras[i,5], 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aOutras[i,2], aOutras[i,7], (aOutras[i,4] / nTxNF), 0,(aOutras[i,4] / nTxNF),EEC->EEC_FORN,"2","","",cFilEEM } )
//		                Endif
		             EndIf
		         Next              
		      endif                      
		      If !lTemRat126 .or. !lTemRatVCO
		         For i:=1 to Len(aOUSemRat)
		             // Tx do Outras Despesas
		             nTxNF := aOUSemRat[i,10]
		             // Evento de Outras Despesas
		             If !lTemRat126 .and. aOUSemRat[i,7] >= dDta_Ini .and. aOUSemRat[i,7] <= dDta_Fim
		                AAdd(aDadosPRV, {aOUSemRat[i,4], '126', "", aOUSemRat[i,1], '126', aOUSemRat[i,7], IF(EMPTY(EXL->EXL_MDDI),EEC->EEC_MOEDA,EXL->EXL_MDDI), nTxNF, nTxFimMes, "", "", 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aOUSemRat[i,2], aOUSemRat[i,7], 0, 0,(aOUSemRat[i,3]*IF(EXL->EXL_PADI=0,1,EXL->EXL_PADI)),IF(EMPTY(EXL->EXL_FODI),EEC->EEC_FORN,EXL->EXL_FODI),"2","","",cFilEEM,""})
		                //AAdd(aDadosPRV, {aOUSemRat[i,4], '126', "", aOUSemRat[i,1], '126', aOUSemRat[i,7], EEC->EEC_MOEDA, nTxNF, nTxFimMes, "", "", 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aOUSemRat[i,2], aOUSemRat[i,7], 0, 0,(aOUSemRat[i,4] / nTxNF),EEC->EEC_FORN,"2","","",cFilEEM})
		             EndIf
		
		             // V.Cambial de Outras Despesas
		             If !lTemRatVCO
		                If Empty(dDataEmbAux) // .OR. aOUSemRat[i,7] <= dDataEmbAux)
		                   nTaxaAux:= FimMesOU
		                Else
		                   nTaxaAux:= EmbarqOU
		                EndIf
                        nTxReal := ECOEXP999Tx(IF(EMPTY(EXL->EXL_MDDI),EEC->EEC_MOEDA,EXL->EXL_MDDI), (dDta_Ini-1), cTX_101)
                        If aOUSemRat[i,7] >= (dDta_Ini) .And. aOUSemRat[i,7] <= dDta_Fim 
		                   nVariacao := IF(!EMPTY(aOUSemRat[i,3]), (aOUSemRat[i,3] * if(EXL->EXL_PADI <> 0,EXL->EXL_PADI,1)) * nTaxaAux - aOUSemRat[i,4],((aOUSemRat[i,4] / nTxNF)* if(EXL->EXL_PADI <> 0,EXL->EXL_PADI,1)) * nTaxaAux - ((aOUSemRat[i,4] / nTxNF) * if(EXL->EXL_PADI <> 0,EXL->EXL_PADI,1)) * aOUSemRat[i,4])  //nTxNFIni
                         Else
   	                       nVariacao := IF(!EMPTY(aOUSemRat[i,3]), (aOUSemRat[i,3] * if(EXL->EXL_PADI <> 0,EXL->EXL_PADI,1)) * nTaxaAux - aOUSemRat[i,3] * nTxReal,((aOUSemRat[i,4] / nTxNF)* if(EXL->EXL_PADI <> 0,EXL->EXL_PADI,1)) * nTaxaAux - ((aOUSemRat[i,4] / nTxNF) * if(EXL->EXL_PADI <> 0,EXL->EXL_PADI,1)) * nTxReal)  //nTxNFIni
                        EndIf
		                
//		                If nVariacao <> 0
		                   AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, '540', '541'), "", aOUSemRat[i,1], If(nVariacao > 0, '540', '541'), dDta_FimAux, IF(EMPTY(EXL->EXL_MDDI),EEC->EEC_MOEDA,EXL->EXL_MDDI), nTaxaAux, nTxNF*EXL->EXL_PADI, "", aOUSemRat[i,5], 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aOUSemRat[i,2], aOUSemRat[i,7], (aOUSemRat[i,4] / nTxNF)*EXL->EXL_PADI, 0,(aOUSemRat[i,3]*IF(EXL->EXL_PADI=0,1,EXL->EXL_PADI)),IF(EMPTY(EXL->EXL_FODI),EEC->EEC_FORN,EXL->EXL_FODI),"2","","",cFilEEM,""} ) //Alcir Alves - 19-07-05 - a posição 8 foi mudada para nTaxaAux 
		                  // AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, '540', '541'), "", aOUSemRat[i,1], If(nVariacao > 0, '540', '541'), dDta_FimAux, EEC->EEC_MOEDA, nTxFimMes, nTxNF, "", aOUSemRat[i,5], 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aOUSemRat[i,2], aOUSemRat[i,7], (aOUSemRat[i,4] / nTxNF), 0,(aOUSemRat[i,4] / nTxNF),EEC->EEC_FORN,"2","","",cFilEEM } )
//		                Endif
		             EndIf
		         Next              
		      endif                 
		   endif
    Else
           If(EasyEntryPoint("ECOPF999"),ExecBlock("ECOPF999",.F.,.F.,"GRV_OUTRAS_DESP"),) // VI 27/04/05
    EndIf
   ENDIF // vi 22/12/05

	*************************************************************************************************************
	******************************/* Verifica diferenças na NF */************************************************
	*************************************************************************************************************
	   If Len(aNF) > 0
	   
	      // Verifica a diferença e joga a diferença no último item da NF
	      nFobEECAux := EEC->EEC_TOTPED
	      nDifer     := (Int(nFobEECAux - nTotNF)) * nTxNF
	      If nDifer <> 0
	         If Abs(nDifer) > 10
	            AADD(aTabMsg, STR0033 + Alltrim(aNF[Len(aNF),2]) + STR0034 + EEC->EEC_PREEMB) //"Advertência: Somatoria dos itens da NF "###" difere do valor do Processo "
	         EndIf
	         If Abs(nDifer) <= 10
	            aNF[Len(aNF),3] += nDifer
	            If Len(aNFSemRat) > 0
                   aNF[Len(aNFSemRat),3] += nDifer
                EndIf
	         Endif
	      Endif
	*************************************************************************************************************
	******************************************/* Calculo FOB - NFs*/*********************************************
	*************************************************************************************************************
	      If lTemRat107 .or. lTemRatVC                                                   
            If EEC->EEC_MPGEXP # '006' .AND. ! EEC->EEC_COBCAM $ cNao // vi 01/08/05
	         For i:=1 to Len(aNF)
	             // Tx da NF
	             nTxNF := aNF[i,5]
	             // Evento de FOB
	             If lTemRat107 .and. aNF[i,6] >= dDta_Ini .and. aNF[i,6] <= dDta_Fim
	                AAdd(aDadosPRV, {aNF[i,3], '107', "", aNF[i,1], '107', aNF[i,6], EEC->EEC_MOEDA, nTxNF, nTxFimMes, "", aNF[i,4], 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aNF[i,2], aNF[i,6], 0, 0,(aNF[i,3] / nTxNF),EEC->EEC_IMPORT,"1","","",cFilEEM,""} )
	             EndIf
	
	             // V.Cambial da NF
	             If lTemRatVC .AND. ! lCancelada  // VI 19/08/03
//                  If (Empty(dDataEmbAux) .OR. aNF[i,6] <= dDataEmbAux) // VI 02/09/05
                    If Empty(dDataEmbAux) //.OR. aNF[i,6] <= dDataEmbAux) 
	                   nTaxaAux:= nTxFimMes
	                Else
	                   nTaxaAux:= nTxEmbarq
	                EndIf
                    nTxReal := ECOEXP999Tx(EEC->EEC_MOEDA, (dDta_Ini-1), cTX_101) // MJA 02/09/05
                    If aNF[i,6] >= (dDta_Ini) .And. aNF[i,6] <= dDta_Fim 
                       nVariacao := IF(!EMPTY(aNF[i,8]), (aNF[i,8] * nTaxaAux) - aNF[i,3],((aNF[i,3] / nTxNF) * nTaxaAux) - ((aNF[i,3] / nTxNF) * aNF[i,7]))  //nTxNFIni
                    Else
                       nVariacao := IF(!EMPTY(aNF[i,8]), (aNF[i,8] * nTaxaAux) - (aNF[i,8] * nTxReal),((aNF[i,3] / nTxNF) * nTaxaAux) - ((aNF[i,3] / nTxNF) * nTxReal))  //nTxNFIni
                    EndIf
                       
//	                If nVariacao <> 0
	                   AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, '580', '581'), "", aNF[i,1], If(nVariacao > 0, '580', '581'), dDta_FimAux, EEC->EEC_MOEDA, nTxFimMes, nTxNF, "", aNF[i,4], 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aNF[i,2], aNF[i,6], (aNF[i,3] / nTxNF), 0,(aNF[i,3] / nTxNF),EEC->EEC_IMPORT,"1","","",cFilEEM,""} )
//	                Endif
	             EndIf
	         Next
	        EndIf 
	      EndIf
	      If ! lTemRat107 .or. ! lTemRatVC
            If EEC->EEC_MPGEXP # '006' .AND. ! EEC->EEC_COBCAM $ cNao // vi 01/08/05
	         For i:=1 to Len(aNFSemRat)
	             // Tx da NF
	             nTxNF := aNFSemRat[i,5] 
	             // Evento de FOB
	             If ! lTemRat107 .and. aNFSemRat[i,6] >= dDta_Ini .and. aNFSemRat[i,6] <= dDta_Fim
	                                 //      1         2     3         4          5         6                7           8        9      10       11           12         13         14  15  16  17  18       19               20       21  22             23                 24       25  26 27    28   29
	                AAdd(aDadosPRV, {aNFSemRat[i,3], '107', "", aNFSemRat[i,1], '107', aNFSemRat[i,6], EEC->EEC_MOEDA, nTxNF, nTxFimMes, "", aNFSemRat[i,4], 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aNFSemRat[i,2], aNFSemRat[i,6], 0, 0,(aNFSemRat[i,3] / nTxNF),EEC->EEC_IMPORT,"1","","",cFilEEM,""} )
	             EndIf
	
	             // V.Cambial da NF
	             If ! lTemRatVC .AND. ! lCancelada  // VI 19/08/03
//                  If (Empty(dDataEmbAux) .OR. aNFSemRat[i,6] <= dDataEmbAux) 
                    If Empty(dDataEmbAux) //.OR. aNFSemRat[i,6] <= dDataEmbAux)  // vi 02/09/05
	                   nTaxaAux:= nTxFimMes
	                Else
	                   nTaxaAux:= nTxEmbarq
	                EndIf
                    nTxReal := ECOEXP999Tx(EEC->EEC_MOEDA, (dDta_Ini-1), cTX_101)
                    If aNFSemRat[i,6] >= (dDta_Ini) .And. aNFSemRat[i,6] <= dDta_Fim 
                       nVariacao := IF(!EMPTY(aNFSemRat[i,8]), (aNFSemRat[i,8] * nTaxaAux) - aNFSemRat[i,3],((aNFSemRat[i,3] / nTxNF) * nTaxaAux) - ((aNFSemRat[i,3] / nTxNF) * aNFSemRat[i,7])) // nTxNFIni
                    Else
                       nVariacao := IF(!EMPTY(aNFSemRat[i,8]), (aNFSemRat[i,8] * nTaxaAux) - (aNFSemRat[i,8] * nTxReal),((aNFSemRat[i,3] / nTxNF) * nTaxaAux) - ((aNFSemRat[i,3] / nTxNF) * nTxReal)) // nTxNFIni
                    EndIf

//	                If nVariacao <> 0  //   1                   2                    3       4                        5                       6              7            8        9    10        11          12          13        14  15  16  17  18        19             20                      21          22              23                24        25  26 27    28   29
	                   AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, '580', '581'), "", aNFSemRat[i,1], If(nVariacao > 0, '580', '581'), dDta_FimAux, EEC->EEC_MOEDA, nTxFimMes, nTxNF, "", aNFSemRat[i,4], 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aNFSemRat[i,2], aNFSemRat[i,6], (aNFSemRat[i,3] / nTxNF), 0,(aNFSemRat[i,3] / nTxNF),EEC->EEC_IMPORT,"1","","",cFilEEM,""} )
//	                Endif
	             EndIf
	         Next
	        EndIf 
	      EndIf
	   Endif
	   // Grava as Variacoes e eventos na prévia, ja rateando se necessario
	   If Len(aDadosPRV) > 0
	      PExp999_PrvRat(aDadosPRV)
	   Endif
	   EEC->(DbSkip())
	Enddo
ENDIF		
EEC->(DbSetOrder(1))
EE9->(DbSetOrder(1))
//---------------------------------------- MJA 20/09/04 PONTO DE ENTRADA PARA FAZER O PRE-CALCULO DA TABELA EXM
aDadosPRV := {}
If(EasyEntryPoint("ECOPF999"),ExecBlock("ECOPF999",.F.,.F.,"PRE_CALC"),) // MJA 21/09/04 03/05/05
If Len(aDadosPRV) > 0
      PExp999_PrvRat(aDadosPRV)
Endif

//-------------------------------------FIM
Return Nil



*--------------------------------------*
FUNCTION PRDESP999(cProcesso, cInvoice)
*--------------------------------------*
Local aDadosDesp := {}

// Le o arquivo de despesas EET
EET->(DbSeek(cFilEET+cProcesso))
DBSELECTAREA("EET")
If !(Posicione("SX2",1,"EET","X2_MODO") == "C" .and. !lPrimeira)
	Do While EET->(!Eof()) .And. EET->EET_FILIAL = cFilEET .And. EET->EET_PEDIDO = cProcesso
	
//   If EET->EET_DTDEMB >= (dDta_Ini) .And. EET->EET_DTDEMB <= (dDta_Fim)  .And. Empty(Val(EET->EET_NR_CON)) .And. EET->EET_OCORRE = "Q"
   If EET->EET_DTDEMB >= (dDta_Ini) .And. EET->EET_DTDEMB <= (dDta_Fim)  .And. Empty(Val(EET->EET_NR_CON)) .And. EET->EET_OCORRE = "Q" .AND. !EMPTY(EET->EET_EVENT)
      // Grava no Arquivo de Prévia - ECA
      AAdd(aDadosDesp, {EET->EET_VALORR, EET->EET_EVENT, "", cInvoice, EET->EET_EVENT,;
	                        EET->EET_DTDEMB, EEC->EEC_MOEDA, 0, 0, "", "", 'EXP', EET->EET_PEDIDO,;
                        "", "", "", "", "", "","",0,0,0,"","","","",cFilEET,""} )
	  	  // Efetivacao
		  If cPrv_Efe = "2" 
	         Reclock('EET',.F.)
	         EET->EET_NR_CON := STRZERO(nNR_Cont+1,4,0)
	         EET->(MSUNLOCK())
	      Endif
	   Endif
	   EET->(DbSkip())
	Enddo
	ENDIF
                     
PExp999_PrvRat(aDadosDesp)
          
Return Nil
*--------------------------------------------------------------*
FUNCTION ECOEXP999INV(cTipoModu,cContrato,cBanco,cPraca,cSeqcnt,cEvento)
*--------------------------------------------------------------*
Local nTotal := 0, nIndexEF3 := EF3->(IndexOrd())
Default cEvento := '600'

EF3->(DbSetOrder(1))
nTotal600EF3 := 0
if cBanco # NIL //MJA 27/01/05
   // Nick 06/07/2006 - Ajustar o Indice para os novos definidos peloa Alessandro
   If EF3->(DbSeek(cFilEF3+IF(lEFFTPMOD,cTipoModu,"")+cContrato+cBanco+cPraca+IF(lEFFTpMod,cSeqcnt,"")+cEvento)) //MJA 27/01/05 //Nick 02/08/06
	   Do While EF3->(!Eof()) .And. cFilEF3 = EF3->EF3_FILIAL .And. EF3->EF3_CONTRA = cContrato .and. EF3->EF3_CODEVE = cEvento .and. EF3->EF3_BAN_FI = cBanco .and. EF3->EF3_PRACA = cPraca
//	      nTotal600EF3 += EF3->EF3_VL_MOE          MJA 26/04/05
	      If EF3->EF3_DT_EVE >= (dDta_Ini) .And. EF3->EF3_DT_EVE <= (dDta_Fim) .AND. EF3->EF3_TX_MOE <> 0 .AND. EF3->EF3_VL_REA <> 0 //.And. EF3->EF3_CODEVE = '600'  VI 25/07/03
	         nTotal += EF3->EF3_VL_MOE
	         nTotal600EF3 += EF3->EF3_VL_MOE
	      Endif
	      EF3->(DbSkip())
	   Enddo
	Endif
 else //MJA 27/01/05
   // Nick 06/07/2006 ajustar o Indice para os novos definidos pelo Alessandro
   If EF3->(DbSeek(cFilEF3+IF(lEFFTPMOD,cTipoModu,"")+cContrato+cEvento)) // Nick - 02/08/06
	   Do While EF3->(!Eof()) .And. cFilEF3 = EF3->EF3_FILIAL .And. EF3->EF3_CONTRA = cContrato .and. EF3->EF3_CODEVE = cEvento
//	      nTotal600EF3 += EF3->EF3_VL_MOE          MJA 26/04/05
	      If EF3->EF3_DT_EVE >= (dDta_Ini) .And. EF3->EF3_DT_EVE <= (dDta_Fim) .AND. EF3->EF3_TX_MOE <> 0 .AND. EF3->EF3_VL_REA <> 0 //.And. EF3->EF3_CODEVE = '600'  VI 25/07/03
	         nTotal += EF3->EF3_VL_MOE
	         nTotal600EF3 += EF3->EF3_VL_MOE
	      Endif
	      EF3->(DbSkip())
	   Enddo
	Endif  
endif

EF3->(DbSetOrder(nIndexEF3))

Return nTotal


*---------------------------------------------------*
FUNCTION PExp999_PrvRat(aDadosPRV)
*---------------------------------------------------*
Local x
//private x := 0 
Private cConSN, cTipoRat:="H", cEventoAux:="" // VI 27/04/05

/* Posições do vetor aDadosPRV
[1] - Valor
[2] - Evento
[3] - Contrato
[4] - Invoice
[5] - Link
[6] - Data
[7] - Moeda
[8] - Taxa da Moeda
[9] - Taxa Mes Anterior
[10] - Sequencia
[11] - C.Custo
[12] - Tipo PROCESSO 01=ACC,02=ACE,03=PRE,PED,CLI,EMB
[13] - Numero do Processo
[14] - Fase (C - Cliente, P - Pedido, E - Embarque)  			  ****** Se houver Pag.Antecipado
[15] - Tipo do Evento (A-Adiantamento / E-Embarque /NF-N.Fiscal)  ****** Se houver Pag.Antecipado 
[16] - Processo de Origem						     			  ****** Se houver Pag.Antecipado 
[17] - Fase de Origem						     	 		      ****** Se houver Pag.Antecipado 
[18] - Parcela de Origem						     		      ****** Se houver Pag.Antecipado 
[19] - Nota Fiscal									 			  ****** Qdo. for contabilizacao da NF
[20] - Data de Entrada da 1a. Variação							  ****** Se houver
[21] - Valor em que houve a Variação                              ****** Qdo. for Variação
[22] - Nº. do RECNO do Registro para que se grave as 
       contas contábeis no EF3. (Usado na Tabela EF3, nos eventos ja 
       gerados pelo financiamento).
[23] - Valor na moeda
[24] - Cliente ou Fornecedor (Códigos)    //MJA 18/12/04
[25] - Tipo ( 1- Cliente, 2- Fornecedor)  //MJA 18/12/04
[26] - Banco (Financiamento)
[27] - Praca (Financiamento)
[28] - Filial de Origem (Acrescentado para versão 811)
[29] - Sequencia do Contrato de Financiamento
*/

For x := 1 to Len(aDadosPRV)

    cIdentCT   := aDadosPRV[x,11] // C.Custo
    cEventoAux := aDadosPRV[x,2] // Evento

    // Verifica se o evento deve ser rateado
    If aDadosPrv[x,12] $ 'ACC/ACE/PRE'
       EC6->(DbSeek(cFilEC6+If(lTemEC6New,"FIEX"+If(aDadosPrv[x,12] = 'ACC', '01', If(aDadosPrv[x,12]='ACE', '02', '03')), "")+aDadosPrv[x,2] ))
    Else
       EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT"+aDadosPRV[x,2],"")))
    Endif 
                 
    cContSN := aDadosPrv[x,2]
    If(EasyEntryPoint("ECOPF999"),ExecBlock("ECOPF999",.F.,.F.,"APOS_EC6"),) // MJA 27/09/04
    If Round(aDadosPRV[x,1],2) = 0 // MJA 27/05/05 Para aparecer mesmo com valores zerados.
       aDadosPRV[x,1] := 0
    ENDIF   

    If !Empty(aDadosPRV[x,13])  .AND. !aDadosPRV[x,12] $ ('CLI/PED/VC') .And. Empty(aDadosPrv[x,19]) .And. If(lTemEC6Rat, EC6->EC6_RATEIO $ '1', .T.) .and. Len(aDadosPRV) > 0 // Ratear por C.Custo - SYS

       If SYS->(DbSeek(cFilSYS+If(lTemSYSNew,"E","")+cTipoRat+aDadosPRV[x,13]))
          DBSELECTAREA("SYS")
          If !(Posicione("SX2",1,"SYS","X2_MODO") == "C" .and. !lPrimeira)
	          DO WHILE SYS->(!EOF()) .AND. SYS->YS_FILIAL==cFilSYS .AND. If(lTemSYSNew, SYS->YS_TPMODU == "E", .T.) .AND. SYS->YS_TIPO+SYS->YS_PREEMB == cTipoRat+aDadosPRV[x,13]
	
	             cIdentCT := SYS->YS_CC
	
	             // Grava no arquivo de Prévia - ECA
//	             If Round(aDadosPRV[x,1],2) # 0 .Or. aDadosPRV[x,2] = "607"
	                PF999_GrvPRV(aDadosPRV[x,1] * SYS->YS_PERC, aDadosPRV[x,2], aDadosPRV[x,3], aDadosPRV[x,4], aDadosPRV[x,5], aDadosPRV[x,6], aDadosPRV[x,7], aDadosPRV[x,8],;
                             aDadosPRV[x,9], aDadosPrv[x,10], cIdentCT, aDadosPRV[x,12], aDadosPRV[x,13], aDadosPRV[x,14], aDadosPRV[x,15], aDadosPRV[x,16], aDadosPRV[x,17], aDadosPRV[x,18], aDadosPrv[x,19], aDadosPrv[x,20], aDadosPrv[x,21] * SYS->YS_PERC, aDadosPrv[x,22], aDadosPrv[x,23] * SYS->YS_PERC,aDadosPrv[x,24],aDadosPrv[x,25],aDadosPrv[x,26],aDadosPrv[x,27],aDadosPrv[x,28],aDadosPrv[x,29])
//	             Endif
	
	             SYS->(DbSkip())
	          Enddo
          ENDIF
       Else
          PF999_SYS(aDadosPRV[x,13])  // Emite mensagem de aviso no final do relatório
       Endif   
    Else
       // Grava no arquivo de Prévia - ECA
//       If Round(aDadosPRV[x,1],2) # 0 .Or. aDadosPRV[x,2] = "607"
          PF999_GrvPRV(aDadosPRV[x,1], aDadosPRV[x,2], aDadosPRV[x,3], aDadosPRV[x,4], aDadosPRV[x,5], aDadosPRV[x,6], aDadosPRV[x,7], aDadosPRV[x,8],;
                       aDadosPRV[x,9], aDadosPrv[x,10], If(EC6->EC6_RATEIO='2',SPACE(LEN(EC6->EC6_IDENTC)),cIdentCT), aDadosPRV[x,12], aDadosPRV[x,13], aDadosPRV[x,14], aDadosPRV[x,15], aDadosPRV[x,16], aDadosPRV[x,17], aDadosPRV[x,18], aDadosPrv[x,19], aDadosPrv[x,20], aDadosPrv[x,21], aDadosPrv[x,22], aDadosPrv[x,23],aDadosPrv[x,24],aDadosPrv[x,25],aDadosPrv[x,26],aDadosPrv[x,27],aDadosPrv[x,28],aDadosPrv[x,29])
//       Endif
    Endif
Next

Return Nil
*-------------------------------*
FUNCTION PF999_EF3Rat(aDadosEF3)
*-------------------------------*
Local x := 0

/* Posições do vetor aDadosEF3
[1] - Valor
[2] - Moeda
[3] - Evento
[4] - Invoice
[5] - Parcela
[6] - Contrato
[7] - C.Custo
[8] - Link
[9] - Data
[10]- Sequencia
[11]- Origem - Tipo de registro 'CO' (Contrato) 
[12]- Valor na Moeda
[13]- Tx. Fim do Mês
[14]- Tx. do mes anterior
[15]- Tipo do financiamento 01=ACC;02=ACE;03=PRE (Pre Pagamento)
[16]- Processo
[17]- Banco
[18]- Praça
[19]- Agencia
[20]- Conta
*/

For x := 1 to Len(aDadosEF3)    

    cIdentCT := aDadosEF3[x,7] // C.Custo
    
    // Verifica se o evento devera ser rateado
    EC6->(DbSeek(cFilEC6+If(lTemEC6New,"FIEX"+If(aDadosEF3[x,15] = 'ACC', '01', If(aDadosEF3[x,15]='ACE', '02', '03')), "")+aDadosEF3[x,3] ))
    
    If Round(aDadosEF3[x,1],2) = 0
       aDadosEF3[x,1] := 0
    endif
    If !Empty(aDadosEF3[x,16]) .And. If(lTemEC6Rat, EC6->EC6_RATEIO $ '1', .T.)  // Ratear por C.Custo - SYS

       SYS->(DbSeek(cFilSYS+If(lTemSYSNew,"E","")+"H"+aDadosEF3[x,16]))
       DBSELECTAREA("SYS")
       If !(Posicione("SX2",1,"SYS","X2_MODO") == "C" .and. !lPrimeira)
	       DO WHILE SYS->(!EOF()) .AND. SYS->YS_FILIAL==cFilSYS .AND. If(lTemSYSNew, SYS->YS_TPMODU == "E", .T.) .AND. SYS->YS_TIPO+SYS->YS_PREEMB == "H"+aDadosEF3[x,16]
	
	          cIdentCT := SYS->YS_CC
	
	          // Grava no arquivo ECF
//	          If Round(aDadosEF3[x,1],2) # 0
	             PF999_GrvEF3(aDadosEF3[x,1] * SYS->YS_PERC, aDadosEF3[x,2], aDadosEF3[x,3], aDadosEF3[x,4], aDadosEF3[x,5], aDadosEF3[x,6], cIdentCT, aDadosEF3[x,8], aDadosEF3[x,9], aDadosEF3[x,10], aDadosEF3[x,11], If(Left(aDadosEF3[x,3],1) $ "520", aDadosEF3[x,12], 0), aDadosEF3[x,13], aDadosEF3[x,14], aDadosEF3[x,15], aDadosEF3[x,16], EC6->EC6_CTA_DB, EC6->EC6_CTA_CR,aDadosEF3[x,17],aDadosEF3[x,18],aDadosEF3[x,19],aDadosEF3[x,20],aDadosEF3[x,21])
//	          Endif
	
	          SYS->(DbSkip())
	       Enddo
       Endif
    Else
       // Grava no arquivo ECF
//       If Round(aDadosEF3[x,1],2) # 0
          PF999_GrvEF3(aDadosEF3[x,1], aDadosEF3[x,2], aDadosEF3[x,3], aDadosEF3[x,4], aDadosEF3[x,5], aDadosEF3[x,6], cIdentCT, aDadosEF3[x,8], aDadosEF3[x,9], aDadosEF3[x,10], aDadosEF3[x,11], If(Left(aDadosEF3[x,3],1) $ "520", aDadosEF3[x,12], 0), aDadosEF3[x,13], aDadosEF3[x,14], aDadosEF3[x,15], aDadosEF3[x,16], EC6->EC6_CTA_DB, EC6->EC6_CTA_CR,aDadosEF3[x,17],aDadosEF3[x,18],aDadosEF3[x,19],aDadosEF3[x,20],aDadosEF3[x,21])
//       Endif
    Endif                                          
Next

Return Nil     

*-------------------------------------------------------------------------------------*
FUNCTION ECOEXP999BUS(cTipoModu,cContrato, cEvento, lVerContab, cBanco, cPraca,cSeqcnt)
*-------------------------------------------------------------------------------------*
Local nIndexEF3 := EF3->(IndexOrd()), lRet := .F.

EF3->(DbSetOrder(1)) 
if cBanco # NIL
    If EF3->(DbSeek(cFilEF3+IF(lEFFTPMOD,cTipoModu,"")+cContrato+cBanco+cPraca+IF(lEFFTpMod,cSeqcnt,"")+cEvento)) //  // Nick 02/08/06
       If !lVerContab
	      If Empty(Val(EF3->EF3_NR_CON)) .And. (EF3->EF3_DT_EVE >= (dDta_Ini) .And. EF3->EF3_DT_EVE <= (dDta_Fim) .Or. EF3->EF3_DT_EVE < (dDta_Ini))
	         lRet := .T.
	      Endif
	   Else
	      If !Empty(Val(EF3->EF3_NR_CON))
	         lRet := .T.
	      Endif
	   Endif
	Endif
 else
    If EF3->(DbSeek(cFilEF3+IF(lEFFTPMOD,cTipoModu,"")+cContrato+cEvento)) // Nick 02/08/06
       If !lVerContab
	      If Empty(Val(EF3->EF3_NR_CON)) .And. (EF3->EF3_DT_EVE >= (dDta_Ini) .And. EF3->EF3_DT_EVE <= (dDta_Fim) .Or. EF3->EF3_DT_EVE < (dDta_Ini))
	         lRet := .T.
	      Endif
	   Else
	      If !Empty(Val(EF3->EF3_NR_CON))
	         lRet := .T.
	      Endif
	   Endif
	Endif
endif

EF3->(DbSetOrder(nIndexEF3))
Return lRet
                     // 1       2        3        4      5      6      7       8      9     10    11       12     13    14    15    16       17      18    19     20         21     22      23     24      25      26      27      28      29
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
FUNCTION PF999_GrvPRV(PValor,PEvento,PContrato,PInvoice,PLink,PData,PMoeda,PTxMoeda,PTxAnt,PSeq,PIdentc,PTipoFin,PHawb,PFase,PTipo,PProcOr,PFaseOr,PParcOr,PNF,PDtEntrada,PVlOrVC,PRecno, PVLMOE,PCliFor,PTipoCli,PBanco,PPraca,PFilOri,PSeqcnt)
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*

//colocar novo parâmetro para receber o cliente ou fornecedor conforme o caso e o tipo.
//buscar quando a conta for xxxxxxxx no cadastro do cliente ou fornecedor ou banco

Local cCliente := "", cTipoCli := ""
Local cEvePesq := If(PEvento = '999' .OR. Plink = '999', PLink, PEvento)
Local nOrdemEEC := EEC->(IndexOrd()), nRecnoEEC := EEC->(Recno())
Local nOrdemEEQ := EEQ->(IndexOrd()), nRecnoEEQ := EEQ->(Recno())
Local nOrdemEF1 := EF1->(IndexOrd()), nRecnoEF1 := EF1->(Recno())
Private MCTA_DEB, MCTA_CRE, MPEvento := PEvento, MPidentc := PIdentc, MContrato := PContrato, MPCliFor := PCliFor, MPTipoCli := PTipoCli
Private lSemALL := .F.
PVLMOE := If(PVLMOE=Nil,0,PVLMOE)

// Caso nao encontre o evento diario procura pelo evento mensal
If PTipoFin = 'ACC' .Or. PTipoFin = 'ACE' .Or. PTipoFin = 'PRE'
   If !EC6->(DbSeek(cFilEC6+If(lTemEC6New,"FIEX"+If(PTipoFin = 'ACC', '01', If(PTipoFin = 'ACE', '02', '03') ),"")+cEvePesq+AVKEY(PIdentc,"ECA_IDENTC")+If(lDiaria,'1','2')))
      If lDiaria
         EC6->(DbSeek(cFilEC6+If(lTemEC6New,"FIEX"+If(PTipoFin = 'ACC', '01', If(PTipoFin = 'ACE', '02', '03')),"")+cEvePesq+AVKEY(PIdentc,"ECA_IDENTC")+'2'))
      Else
         EC6->(DbSeek(cFilEC6+If(lTemEC6New,"FIEX"+If(PTipoFin = 'ACC', '01', If(PTipoFin = 'ACE', '02', '03')),"")+cEvePesq+AVKEY(PIdentc,"ECA_IDENTC")+Space(01)))
      Endif
   Endif
Else
   If !EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT","")+cEvePesq+AVKEY(PIdentc,"ECA_IDENTC")+If(lDiaria,'1','2')))
      If lDiaria
         EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT","")+cEvePesq+AVKEY(PIdentc,"ECA_IDENTC")+'2'))
      Else
         EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT","")+cEvePesq+AVKEY(PIdentc,"ECA_IDENTC")+Space(01)))
      Endif
   Endif
Endif

If(EasyEntryPoint("ECOPF999"),ExecBlock("ECOPF999",.F.,.F.,"SEM_ALLTRIM"),)
// Verifica se o evento é contabilizado

If !EC6->(Eof())

   If ! Empty(EC6->EC6_EVE_AS) // VI 21/02/06
      PF999_GrvPRV(PValor,EC6->EC6_EVE_AS,PContrato,PInvoice,PLink,PData,PMoeda,PTxMoeda,PTxAnt,PSeq,PIdentc,PTipoFin,PHawb,PFase,PTipo,PProcOr,PFaseOr,PParcOr,PNF,PDtEntrada,PVlOrVC,0, PVLMOE,PCliFor,PTipoCli,PBanco,PPraca,PFilOri,PSeqcnt)

      // Caso nao encontre o evento diario procura pelo evento mensal
      If PTipoFin = 'ACC' .Or. PTipoFin = 'ACE' .Or. PTipoFin = 'PRE'
         If !EC6->(DbSeek(cFilEC6+If(lTemEC6New,"FIEX"+If(PTipoFin = 'ACC', '01', If(PTipoFin = 'ACE', '02', '03') ),"")+cEvePesq+AVKEY(PIdentc,"ECA_IDENTC")+If(lDiaria,'1','2')))
            If lDiaria
               EC6->(DbSeek(cFilEC6+If(lTemEC6New,"FIEX"+If(PTipoFin = 'ACC', '01', If(PTipoFin = 'ACE', '02', '03')),"")+cEvePesq+AVKEY(PIdentc,"ECA_IDENTC")+'2'))
            Else
               EC6->(DbSeek(cFilEC6+If(lTemEC6New,"FIEX"+If(PTipoFin = 'ACC', '01', If(PTipoFin = 'ACE', '02', '03')),"")+cEvePesq+AVKEY(PIdentc,"ECA_IDENTC")+Space(01)))
            Endif
         Endif
      Else
         If !EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT","")+cEvePesq+AVKEY(PIdentc,"ECA_IDENTC")+If(lDiaria,'1','2')))
            If lDiaria
               EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT","")+cEvePesq+AVKEY(PIdentc,"ECA_IDENTC")+'2'))
            Else
               EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT","")+cEvePesq+AVKEY(PIdentc,"ECA_IDENTC")+Space(01)))
            Endif
         Endif
      Endif
   EndIf

//------------------------------------- MJA 16/11/05
   IF lTemEC6Pro
      IF EC6->EC6_PROCES = "2"
         RETURN .F.
      ENDIF
   ENDIF   
//-------------------------------------
   If lSemALL
      MCTA_DEB  := if(empty(EC6->EC6_CTA_DB),Sem_Conta(PEvento,PIdentc,PHawb),EC6->EC6_CTA_DB)
      MCTA_CRE  := if(empty(EC6->EC6_CTA_CR),Sem_Conta(PEvento,PIdentc,PHawb),EC6->EC6_CTA_CR)
    else
      MCTA_DEB  := if(empty(AllTrim(EC6->EC6_CTA_DB)),Sem_Conta(PEvento,PIdentc,PHawb),AllTrim(EC6->EC6_CTA_DB))
      MCTA_CRE  := if(empty(AllTrim(EC6->EC6_CTA_CR)),Sem_Conta(PEvento,PIdentc,PHawb),AllTrim(EC6->EC6_CTA_CR))
   Endif   

   If(EasyEntryPoint("ECOPF999"),ExecBlock("ECOPF999",.F.,.F.,"DESFORMATA_CONTA"),)
   
   If PEvento = '999'
   
      if lSemALL
	     If !Empty(EC6->EC6_CDBEST) .And. !Empty(EC6->EC6_CCREST)
	        MCTA_DEB:= EC6->EC6_CDBEST
	        MCTA_CRE:= EC6->EC6_CCREST
	     Else
	        MCTA_DEB  := if(empty(EC6->EC6_CTA_CR),Sem_Conta(PEvento,PIdentc,PHawb),EC6->EC6_CTA_CR)
	        MCTA_CRE  := if(empty(EC6->EC6_CTA_DB),Sem_Conta(PEvento,PIdentc,PHawb),EC6->EC6_CTA_DB)
	     Endif
	   else
	     If !Empty(EC6->EC6_CDBEST) .And. !Empty(EC6->EC6_CCREST)
	        MCTA_DEB:= AllTrim(EC6->EC6_CDBEST)
	        MCTA_CRE:= AllTrim(EC6->EC6_CCREST)
	     Else
	        MCTA_DEB  := if(empty(AllTrim(EC6->EC6_CTA_CR)),Sem_Conta(PEvento,PIdentc,PHawb),AllTrim(EC6->EC6_CTA_CR))
	        MCTA_CRE  := if(empty(AllTrim(EC6->EC6_CTA_DB)),Sem_Conta(PEvento,PIdentc,PHawb),AllTrim(EC6->EC6_CTA_DB))
	     Endif	      
      endif
   Endif

   // Verifica se ja esta vinculado ao um processo p/ obter fornecedor, conta bancaria e cliente
   If !Empty(PHawb) .Or. !Empty(PContrato)

      If !Empty(PContrato) //.And. Empty(PInvoice) VI 20/08/05
         EF1->(DbSetOrder(1))
         EF1->(DbSeek(cFilEF1+IF(lEFFTPMOD,cTipoModu,"")+PContrato+PBanco+PPraca+IF(lEFFTpMod,PSeqcnt,""))) // Nick 02/08/06
         If Empty(PInvoice)
            EF3->(DBSETORDER(1))
            EF3->(DBSEEK(cFilEF3+IF(lEFFTPMOD,cTipoModu,"")+PContrato+PBanco+PPraca+IF(lEFFTpMod,PSeqcnt,"")+PEvento)) // Nick 02/08/06
         Else
            EF3->(DBSETORDER(2))
            EF3->(DBSEEK(cFilEF3+IF(lEFFTPMOD,cTipoModu,"")+PEvento+PInvoice+PSeq)) // Nick 02/08/06
         EndIf
      Endif

      EEC->(DbSetOrder(1))
      EEC->(DbSeek(If(lTemFilOri.And.!Empty(EF3->EF3_FILORI).And.!Empty(PContrato),EF3->EF3_FILORI,cFilEEC)+AvKey(PHawb, "EEC_PREEMB")))

      EEQ->(DbSetOrder(1))
      EEQ->(DbSeek(If(lTemFilOri.And.!Empty(EF3->EF3_FILORI).And.!Empty(PContrato),EF3->EF3_FILORI,cFilEEQ)+PHawb+Pseq))

      If(EasyEntryPoint("ECOPF999"),ExecBlock("ECOPF999",.F.,.F.,"POS_EEQ"),) // VI 20/01/04

//    cCliente := EEC->EEC_IMPORT                                                MJA 28/09/04 Foi feita esta alteraçào 
      cCliente := PCliFor //if(!empty(EEQ->EEQ_FORN) .AND. EEQ->EEQ_TIPO = 'P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT)// para pegar o código correto 
      cTipoCli := PTipoCli //if(!empty(EEQ->EEQ_FORN) .AND. EEQ->EEQ_TIPO = 'P','2','1') // que será gravado no ECA e no ECF (1-Fornecedor/2-Cliente)
       
      
      // Verifica se os tipos de contas são de Fornecedor
      If MCTA_DEB = Replicate("9",Len(EC6->EC6_CTA_DB))
         If PEvento $ "120/123/121/124/122/125"
            SY5->(dbsetorder(1))
            If SY5->(DbSeek(cFilSY5+PCliFor)) // Aqui ele pesquisa pelo agente que está no EE9
               SA2->(DBSETORDER(1))
               If SA2->(DbSeek(cFilSA2+SY5->Y5_FORNECE+SY5->Y5_LOJAF))
                  if lSemALL
                     MCTA_DEB = SA2->A2_CONTAB
                   else
                     MCTA_DEB = AllTrim(SA2->A2_CONTAB)                   
                  endif   
               Endif
            ENDIF
          else
            If SA2->(DbSeek(cFilSA2+PCliFor)) .AND. !Empty(AllTrim(PCliFor))
               if lSemALL
                  MCTA_DEB = SA2->A2_CONTAB
                else
                  MCTA_DEB = AllTrim(SA2->A2_CONTAB)
               endif   
            Endif
         endif
      Endif
      

      If MCTA_CRE = Replicate("9",Len(EC6->EC6_CTA_CR))
         If PEvento $ "120/123/121/124/122/125"
            SY5->(dbsetorder(1))
            If SY5->(DbSeek(cFilSY5+PCliFor)) //  ele pesquisa pelo agente que está no EE9
               SA2->(DBSETORDER(1))
               If SA2->(DbSeek(cFilSA2+SY5->Y5_FORNECE+SY5->Y5_LOJAF))
                  if lSemALL
                     MCTA_CRE = SA2->A2_CONTAB
                   else
                     MCTA_CRE = AllTrim(SA2->A2_CONTAB)                   
                  endif   
               Endif
            ENDIF
          else            
            If SA2->(DbSeek(cFilSA2+PCliFor)) .AND. !Empty(AllTrim(PCliFor))
               if lSemALL
                  MCTA_CRE = SA2->A2_CONTAB
                else
                  MCTA_CRE = AllTrim(SA2->A2_CONTAB)                   
               endif   
            Endif
         Endif
      Endif


      // Verifica se os tipos de contas são de Cliente
      If MCTA_DEB = Replicate("8",Len(EC6->EC6_CTA_DB))
         If SA1->(DbSeek(cFilSA1+EEC->EEC_IMPORT)) .AND. !Empty(AllTrim(EEC->EEC_IMPORT))
            if lSemALL
               MCTA_DEB = SA1->A1_CONTAB
             else
               MCTA_DEB = AllTrim(SA1->A1_CONTAB)             
            endif   
         Endif
      Endif
      If MCTA_CRE = Replicate("8",Len(EC6->EC6_CTA_CR))
         If SA1->(DbSeek(cFilSA1+EEC->EEC_IMPORT)) .AND. !Empty(AllTrim(EEC->EEC_IMPORT))
            if lSemALL
               MCTA_CRE = SA1->A1_CONTAB
             else
               MCTA_CRE = AllTrim(SA1->A1_CONTAB)             
            endif   
         Endif
      Endif
      If SIX->(DbSeek("ECI"+"2"))
         ECI->(DBSETORDER(2))
      EndIf
      // Verifica se os tipos de contas são de Banco         
      If PTipoFin = 'ACC' .Or. PTipoFin = 'ACE' .Or. PTipoFin = 'PRE' // VI 09/12/05
//       If PEvento $ "128/129" // VI 01/08/05
//          cChave := "EEQ->EEQ_BANC+EEQ->EEQ_AGEN+EEQ->EEQ_NCON"
         IF !EMPTY(EF3->EF3_BANC)
            cChave := "EF3->EF3_BANC+EF3->EF3_AGEN+EF3->EF3_NCON"
         ELSEIF !EMPTY(EF1->EF1_BAN_MO)
            cChave := "EF1->EF1_BAN_MO+EF1->EF1_AGENMO+EF1->EF1_NCONMO"
         ELSE
            cChave := "EF1->EF1_BAN_FI+EF1->EF1_AGENFI+EF1->EF1_NCONFI"
         ENDIF
      Else 
         cChave := "EEQ->EEQ_BANC+EEQ->EEQ_AGEN+EEQ->EEQ_NCON"      
      EndIf
     
      If SUBSTR(MCTA_DEB,1,Len(EC6->EC6_CTA_DB)-1) = Replicate("7",Len(EC6->EC6_CTA_DB)-1)
         DO CASE
            CASE RIGHT(MCTA_DEB,1) = '0'
//vi 09/12/05    if SA6->(DbSeek(cFilSA6+EEQ->EEQ_BANC))  // If (SA6->(DbSeek(cFilSA6+&(cChave)))) //(SA6->(DbSeek(cFilSA6+EEQ->EEQ_BANC)) .AND. !Empty(AllTrim(EEQ->EEQ_BANC))) .Or. (SA6->(DbSeek(cFilSA6+EF1->EF1_BAN_FI)) .AND. !Empty(AllTrim(EF1->EF1_BAN_FI)))
                 if SA6->(DbSeek(cFilSA6+&(cChave)))
                    if lSemALL
                       MCTA_DEB = SA6->A6_CONTABI
                     else
                       MCTA_DEB = Alltrim(SA6->A6_CONTABI)
                    endif   
                 ENDIF
            OTHERWISE
                 If SIX->(DbSeek("ECI"+"2"))
                    If ECI->(DbSeek(cFilECI+&(cChave)+'FIEX'+If(PTipoFin == "ACC","01","02")+RIGHT(MCTA_DEB,1)))
                       if lSemALL
                          MCTA_DEB = ECI->ECI_CONTAB
                       else
                          MCTA_DEB = AllTrim(ECI->ECI_CONTAB)                     
                       endif   
                    ENDIF         
                    IF PEvento $ '600/650'
                       // ECI->(DbSeek(cFilECI+&(cChave)+'FIEX01'+'1')) // Nick 04/10/06
                       ECI->(DbSeek(cFilECI+&(cChave)+'FIEX'+If(PTipoFin == "ACC","01","02")+RIGHT(MCTA_DEB,1))) // Nick 04/10/06 
                       MCTA_DEB = ECI->ECI_CONTAB
                       //ECI->(DbSeek(cFilECI+&(cChave)+'FIEX02'+'1')) // Nick 04/10/06
                       ECI->(DbSeek(cFilECI+&(cChave)+'FIEX'+If(PTipoFin == "ACC","01","02")+RIGHT(MCTA_CRE,1))) // Nick 04/10/06
                       MCTA_CRE = ECI->ECI_CONTAB
                    ENDIF
                 EndIf
         ENDCASE   
      ENDIF
      If SUBSTR(MCTA_CRE,1,Len(EC6->EC6_CTA_CR)-1) = Replicate("7",Len(EC6->EC6_CTA_CR)-1) .AND. PEvento # '600' .AND. PEvento # '650'
         DO CASE
            CASE RIGHT(MCTA_CRE,1) = '0'
                 If (SA6->(DbSeek(cFilSA6+&(cChave)))) // .AND. !Empty(AllTrim(EEQ->EEQ_BANC))) .Or. (SA6->(DbSeek(cFilSA6+EF1->EF1_BAN_FI)) .AND. !Empty(AllTrim(EF1->EF1_BAN_FI)))
                    if lSemALL
                       MCTA_CRE = SA6->A6_CONTABI
                    else
                       MCTA_CRE = AllTrim(SA6->A6_CONTABI)                     
                    endif   
                 ENDIF                
            OTHERWISE
                 If ECI->(DbSeek(cFilECI+&(cChave)+EC6->EC6_TPMODU+RIGHT(MCTA_CRE,1)))
                    if lSemALL
                       MCTA_CRE = ECI->ECI_CONTAB
                     else
                       MCTA_CRE = AllTrim(ECI->ECI_CONTAB)                     
                    endif   
                 ENDIF
         ENDCASE   
      ENDIF
   Endif
   
   If(EasyEntryPoint("ECOPF999"),ExecBlock("ECOPF999",.F.,.F.,"GRAVA_ECA"),) // VI 20/08/05

// VI 20/08/05
      EEC->(DbSetOrder(nOrdemEEC))
      EEC->(DbGoto(nRecnoEEC))
      EEQ->(DbSetOrder(nOrdemEEQ))
      EEQ->(DbGoto(nRecnoEEQ))
      EF1->(DbSetOrder(nOrdemEF1))
      EF1->(DbGoto(nRecnoEF1))

   // Grava ECA
   //IF EC6->EC6_CONTAB $ '1'  // Permite contabilização
      Reclock('ECA',.T.)
      ECA->ECA_FILIAL := cFilECA
      ECA->ECA_INVEXP := PInvoice
  	  ECA->ECA_ID_CAM := PEvento
 	  ECA->ECA_DESCAM := If((PEvento = '999' .Or. PLink = '999'), "EST."+EC6->EC6_DESC, EC6->EC6_DESC)
      //ECA->ECA_DT_CON := If((PEvento = '999' .Or. PLink = '999'), dDta_Fim, PData)// PData
      // PLB 17/05/07 - Quando for o evento 100, utiliza a data de Inicio do Contrato de Financiamento
      If PEvento == "999"  .Or.  PLink == "999"
          ///ECA->ECA_DT_CON := dDta_Fim   
          //ASK 14/12/2007 - Alterado para gravar a data do Evento e não a data final de contabilização
          ECA->ECA_DT_CON := PData
      ElseIf PEvento == "100"
         ECA->ECA_DT_CON := EF1->EF1_DT_CON
      Else
         ECA->ECA_DT_CON := PData
      EndIf

      ECA->ECA_COD_HI := EC6->EC6_COD_HI
      ECA->ECA_VALOR  := PValor
      ECA->ECA_LINK   := PLink
      ECA->ECA_IDENTC := PIdentc
      ECA->ECA_FINANC := EC6->EC6_FINANC
      ECA->ECA_OBS    := EC6->EC6_DESC
      if lSemALL
         ECA->ECA_CTA_DB := MCTA_DEB
         ECA->ECA_CTA_CR := MCTA_CRE
      else
         ECA->ECA_CTA_DB := AllTrim(MCTA_DEB)
         ECA->ECA_CTA_CR := AllTrim(MCTA_CRE)       
      endif   
      ECA->ECA_FORN   := cCliente
      ECA->ECA_TP_FOR := cTipoCli
      ECA->ECA_TX_USD := PTxMoeda
      ECA->ECA_MOEDA  := PMoeda
      ECA->ECA_SEQ    := PSeq
      ECA->ECA_TPMODU := If((PTipoFin = 'ACC' .Or. PTipoFin = 'ACE' .or. PTipoFin = 'PRE'), "FIEX"+If(PTipoFin = 'ACC', '01', If(PTipoFin = 'ACE', '02', '03')), 'EXPORT')
      ECA->ECA_VL_MOE := PVLMOE
      If lTemFilOri
         ECA->ECA_FILORI := PFilOri
      EndIf
      // Verificar a existencia dos campos novos
      If lTemECANew
         ECA->ECA_CONTRA := PContrato
         ECA->ECA_PREEMB := PHawb
         ECA->ECA_FASE   := PFase
         ECA->ECA_TIPO   := PTipo
         ECA->ECA_PROR   := PProcOr
         ECA->ECA_FAOR   := PFaseOr
         ECA->ECA_PAOR   := PParcOr
         ECA->ECA_NRNF   := PNF
         ECA->ECA_CONTAB := EC6->EC6_CONTAB
      Endif
      IF lTemEF1PRA
         ECA->ECA_BANCO := PBanco
         ECA->ECA_PRACA := PPraca
      ENDIF
      IF lEFFTPMOD
         ECA->ECA_SEQCNT := PSEQCNT
      ENDIF

      If(EasyEntryPoint("ECOPF999"),ExecBlock("ECOPF999",.F.,.F.,"GRAVA_ECA_APOS_REPLACE"),)  // VI 20/01/04

      ECA->(MSUNLOCK())

      // Gravação no Arquivo de Diario Auxiliar (EZC)
      If cPrv_Efe = "2"
         If(EasyEntryPoint("ECOPF999"),ExecBlock("ECOPF999",.F.,.F.,"GRAVA_APOS_ECA"),)
      Endif
      
//    conta, db, cr     
      If ECA->ECA_CONTAB = '1' .and. cPrv_Efe = "2" 
         nPosConta := Ascan(aTotContas,{|x| x[1]=ECA->ECA_CTA_DB })
         If nPosConta > 0
            aTotContas[nPosConta,2] += Abs(ECA->ECA_VALOR)
         Else
            AAdd(aTotContas, {ECA->ECA_CTA_DB,Abs(ECA->ECA_VALOR),0})
         Endif

         nPosConta := Ascan(aTotContas,{|x| x[1]=ECA->ECA_CTA_CR })
         If nPosConta > 0
            aTotContas[nPosConta,3] += Abs(ECA->ECA_VALOR)
         Else
            AAdd(aTotContas, {ECA->ECA_CTA_CR,0,Abs(ECA->ECA_VALOR)})
         Endif                                                       
      EndIf
            
   //Endif                   
   
// PONTO NOVO
   If(EasyEntryPoint("ECOPF999"),ExecBlock("ECOPF999",.F.,.F.,"GRAVAR"),) // MJA 24/09/04
                       
   IF lGrava
     // Grava no ECG - Cabeçalho dos Processos
      If lTemECGNew
         nRecnoECG := ECG->(Recno())
         If !PTipoFin $ ('ACC/ACE/PRE')
            If !ECG->(DbSeek(cFilECG+'EXPORT'+"EX"+PHawb))
               Reclock("ECG",.T.)
               ECG->ECG_FILIAL  := cFilECG
               ECG->ECG_PREEMB  := PHawb
               ECG->ECG_IDENTC  := PIdentc
               ECG->ECG_SIS_OR  := "1"
               ECG->ECG_ORIGEM  := "EX"
               ECG->ECG_FORN 	 := cCliente
               ECG->ECG_DTENCE  := AVCTOD(' /  / ')
               If lTemFilOri
                  ECG->ECG_FILORI  := PFilOri
               EndIf
               If lTemTPMODU
                  ECG->ECG_TPMODU  := 'EXPORT'
               EndIf
            Else
               Reclock("ECG",.F.)
            Endif
            ECG->ECG_NR_CON  := If(cPrv_Efe = "2", STRZERO(nNR_Cont+1,4,0),Space(LEN(ECG->ECG_NR_CON)))
            ECG->ECG_DT      := dDataBase
    	   Endif
         ECG->(MSUNLOCK())
         ECG->(DbGoto(nRecnoECG))
      Endif

      If cPrv_Efe = "2"

         // Grava ECF
         If PEvento # '999' .And. PLink # '999'
            Reclock('ECF',.T.)
            ECF->ECF_FILIAL := cFilECF
            ECF->ECF_INVEXP := PInvoice
            ECF->ECF_ID_CAM := PEvento
            ECF->ECF_IDENTC := PIdentc
            ECF->ECF_DTCONT := PData
            ECF->ECF_NR_CON := If(cPrv_Efe = "2", STRZERO(nNR_Cont+1,4,0),SPACE(LEN(ECF->ECF_NR_CON)))
            ECF->ECF_VALOR  := PValor
            ECF->ECF_MOEDA  := PMoeda
            ECF->ECF_DESCR  := EC6->EC6_DESC
            ECF->ECF_SEQ    := PSeq
            ECF->ECF_ORIGEM := If((PTipoFin $ 'ACC/ACE/PRE'), 'CO', 'EX')
            ECF->ECF_VL_MOE := PVLMOE  // If(!Empty(PVlOrVC) .AND. PEvento # '607', PVlOrVC, if(PEvento = '607',PVLMOE,PValor / PTxMoeda))
            ECF->ECF_PARIDA := PTxMoeda      // Tx do Mes
            ECF->ECF_FLUTUA := PTxAnt        // Tx do Mes Anterior
            ECF->ECF_LINK   := PLink
            ECF->ECF_CTA_DB := MCTA_DEB
            ECF->ECF_CTA_CR := MCTA_CRE
            ECF->ECF_FORN   := cCliente
            ECF->ECF_TP_FOR := cTipoCli
            If lTemFilOri
               ECF->ECF_FILORI := PFilOri
            EndIf   
            If lTemECFNew
               ECF->ECF_CONTRA := PContrato
               ECF->ECF_TP_EVE := If((PTipoFin $ 'ACC/ACE/PRE'), If(PTipoFin = 'ACC', '01', If(PTipoFin = 'ACE', '02', '03')),)
               ECF->ECF_PREEMB := PHawb
               ECF->ECF_FASE   := PFase
               ECF->ECF_TIPO   := PTipo
               ECF->ECF_PROR   := PProcOr
               ECF->ECF_FAOR   := PFaseOr
               ECF->ECF_PAOR   := PParcOr
               ECF->ECF_NRNF   := PNF
               ECF->ECF_CONTAB := EC6->EC6_CONTAB
            Endif

            IF lTemEF1PRA
               ECF->ECF_BANCO := PBanco
               ECF->ECF_PRACA := PPraca
            ENDIF
 
            IF lEFFTPMOD
               ECF->ECF_SEQCNT := PSEQCNT
            ENDIF
            If lTemTPMODU
               ECF->ECF_TPMODU := 'EXPORT'         
            EndIf
          
            If !Empty(PDtEntrada)
               ECF->ECF_DTCONV := PDtEntrada
            Endif
         Else
            Reclock('ECF',.T.)            // Grava apenas a inversão das contas do estorno
            ECF->ECF_CTA_DB := MCTA_DEB
            ECF->ECF_CTA_CR := MCTA_CRE
            ECF->ECF_DTCONT := dDta_Fim            
         Endif
         ECF->(MSUNLOCK())
                                    
         // Grava as contas contabeis nos eventos que foram gerados pela Manut.do Financiamento.
         If !Empty(PRecno) .And. lTemEF3Cta
            EF3->(DbGoto(PRecno))
	        Reclock('EF3',.F.)
   	        EF3->EF3_CTA_DB := MCTA_DEB
            EF3->EF3_CTA_CR := MCTA_CRE
            EF3->(msUnlock())
         Endif
      Endif
   ENDIF
   lGrava := .T.
Else
   If EC6->(Eof())
      PF999_EvePad(PEvento, PIdentc, lDiaria, PHawb)  // Verifica os eventos Padrões
   Endif
Endif

RETURN NIL
                    //  1       2        3        4        5        6         7       8      9     10     11        12         13       14         15        16        17         18       19      20      21       22        23
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
FUNCTION PF999_GrvEF3(nValor, cMoeda, cEvento, cInvoice, cParc, cContrato, cCCusto, cLink, dData, cSeq, cOrigem, nValorMoe, nTaxaFim, nTaxaAnt, cTipoFin, cProcesso, cContaDB, cContaCR, cBanco, cPraca, cAgencia, cConta, cSeqCnt)
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*

// Grava no EF3
Reclock('EF3',.T.)
EF3->EF3_FILIAL := cFilEF3
EF3->EF3_CODEVE := cEvento
EF3->EF3_CONTRA := cContrato
EF3->EF3_PREEMB := cProcesso
EF3->EF3_INVOIC := cInvoice
EF3->EF3_PARC   := cParc
EF3->EF3_VL_REA := nValor
EF3->EF3_VL_MOE := IF(cEvento # '520',0,nValorMoe) // MJA 20/05/05 Para gravar o valor zerado caso for VC
EF3->EF3_TX_MOE := nTaxaFim
EF3->EF3_DT_EVE := dData
EF3->EF3_SEQ    := cSeq
EF3->EF3_NR_CON := If(cPrv_Efe = "2", STRZERO(nNR_Cont+1,4,0),SPACE(LEN(EF3->EF3_NR_CON)))
EF3->EF3_TP_EVE := If(cTipoFin = 'ACC', '01', If(cTipoFin = 'ACE', '02', '03'))
EF3->EF3_GERECO := '1'   // Indica que o evento foi gerado na contabilização.
EF3->EF3_MOE_IN := cMoeda
IF lEFFTPMOD
   EF3->EF3_TPMODU := 'E'
   EF3->EF3_SEQCNT := cSEQCNT 
Endif
If lTemEF3Cta
   EF3->EF3_CTA_DB := cContaDB
   EF3->EF3_CTA_CR := cContaCR
Endif
IF lTemEF1PRA // MJA 23/04/05
   EF3->EF3_BAN_FI := cBanco
   EF3->EF3_PRACA  := cPraca
   EF3->EF3_AGENFI := cAgencia
   EF3->EF3_NCONFI := cConta
ENDIF 

EF3->(msUnlock())

RETURN NIL

*------------------------------------------*
Function PF999_EvePad(cEve, cCusto, lDiario, cProc)
*------------------------------------------*
Local nPosicao 

// Emite Mensagem de Divergências no final do relatório
nPosicao := Ascan(aEvePadrao,{|x| x[1]=cEve .And. x[2]=cCusto .And. x[3]=lDiario .and. x[4]=cProc})
If nPosicao = 0
   AAdd(aEvePadrao, {cEve, cCusto, lDiario, cProc} )
   AADD(aTabMsg, STR0035 + cEve + STR0036 + If(lDiario, STR0037, STR0038) +  STR0039 + Alltrim(cCusto) + " do Processo "+ alltrim(cProc) +STR0040) //"Evento "###" Tipo "###"Diario"###"Mensal"###" da Unid. Requisitante "###" nao esta cadastrado."
Endif

Return NIL

*----------------------------------*
Function Sem_Conta(cEve,cCC,cProcesso)
*----------------------------------*
Local nPosicao

// Emite Mensagem de Divergências no final do relatório
nPosicao := Ascan(aEvePad,{|x| x[1]=cEve .And. x[2]=cCC .and. x[3]=cProcesso})
If nPosicao = 0 .and. EC6->EC6_CONTAB = '1'
   AAdd(aEvePad, {cEve,cCC,cProcesso} )
   AADD(aTabMsg, "O evento " + cEve + " do Centro de Custo " + alltrim(cCC) + " do processo " + alltrim(cProcesso) + " está sem cadastro de conta") //"Evento "###" Tipo "###"Diario"###"Mensal"###" da Unid. Requisitante "###" nao esta cadastrado."
Endif

Return SPACE(LEN(EC6->EC6_CTA_CR))


*----------------------------*
Function Sem_Juros(cContrato)
*----------------------------*
Local nPosicao

// Emite Mensagem de Divergências no final do relatório
nPosicao := Ascan(aEvePad2,cContrato)
If nPosicao = 0
   AAdd(aEvePad2, cContrato )
   AADD(aTabMsg, "O Contrato " + alltrim(cContrato) + " esta com data de inicio de juros superior ao mês contábil ou em branco.")
Endif

Return .T.



*------------------------*
Function PF999_SYS(cProc)
*------------------------*
Local nPosicao 

// Emite Mensagem de Divergências no final do relatório
nPosicao := Ascan(aProcSYS, {|x| x=cProc})
If nPosicao = 0
   AAdd(aProcSYS, cProc )
   AADD(aTabMsg, STR0041 + Alltrim(cProc) + STR0042) //"Processo "###" Nao foi encontrado no arquivo de Rateio."
Endif

Return NIL

*---------------------*
Function GrvPF999EC1()
*---------------------*

Reclock('EC1',.T.)
EC1->EC1_FILIAL := xFilial('EC1')
EC1->EC1_NR_CON := STRZERO(nNR_Cont+1,4,0)
EC1->EC1_DT_CON := dData_Con
EC1->EC1_DT_EFE := dDataBase
EC1->EC1_HO_CON := cHora
EC1->EC1_MES    := LEFT(cMesProc,2)
EC1->EC1_ANO    := RIGHT(cMesProc,4)		
EC1->EC1_TPMODU := "EXPORT"
EC1->(MSUNLOCK())

SETMV('MV_NRCONT',AllTrim(STR(nNR_Cont+1,4,0)))

Return NIL
*--------------------*
FUNCTION PREXP999TXT(lEnd)
*--------------------*

If EasyEntryPoint("ECO_CTBFE")
   ExecBlock("ECO_CTBFE")
Else
   E_MSG(STR0043,1) //"Não foi encontrado o RDMAKE para gerar o TXT."
   Return .F.
Endif

RETURN .T.
*--------------------------------*
STATIC FUNCTION PREXP999Val(nTipo)
*--------------------------------*

If nTipo == 1
   IF EMPTY(dData_Con)
      E_Msg(STR0044,1) //"Data da contabilização não preenchida."
      Return .F.
   ELSE
      IF dData_Con > (dDta_Fim) .OR. dData_Con < (dDta_Ini)
         E_Msg(STR0045,1) //"Data de contabilização deve estar no mês de processamento."
         Return .F.
      Endif
   Endif
Endif

Return .T.

*---------------------*
Function ER_PF999IMP(lEnd)
*---------------------*
Local cDesc1     := ""
Local cDesc2     := ""
Local cDesc3     := ""
Local cString    := "ECA"


Private nLin     := 80
Private wnrel    := "ECOEXP999"
Private Tamanho  := "P"
Private Limite   := 132
Private Titulo   := If(cPrv_Efe = "1", STR0046, STR0047) + " - " + ; //"Prévia Financiamento Exportação"###"Efetivação Financiamento Exportação"
				    SubStr(cMesProc,1,2)+"/"+SubStr(cMesProc,3,4)
Private nomeprog := "ECOEXP999"
Private aReturn  := { STR0048, 1,STR0017, 1, 1, 1, "", 1} //"Zebrado"###"Financiamento Exportação"
Private nLastKey := 0
Private aDriver  := {}

IF cPrv_Efe = "2"
   lGeraTxt:=.T.
Endif

wnrel:=SetPrint(cString,NomeProg,,@Titulo,cDesc1,cDesc2,cDesc3,.F.,.F.,.T.,Tamanho)

If nLastKey == 27
//   Set Filter To
   Return
Endif

SetDefault(aReturn,cString)
               
If nLastKey = 27
//   Set Filter To
   Return
Endif


PF_SENDPRN(@lEnd)    // Relatório Prévia/Efetivação - Financiamento
PE_SENDPRN(@lEnd)    // Relatório Prévia/Efetivação - Exportação
                                             
Return .T.

*-----------------------------------------------*
FUNCTION PREXP200_Resumo(cCtDeb, cCtCre, nValor)
*-----------------------------------------------*
LOCAL nPosicao := 0

IF nValor < 0
   nValor := nValor * (-1)
Endif

IF ! EMPTY(AllTrim(cCtDeb))
   nPosicao = ASCAN(aTab_Conta,cCtDeb)
   IF nPosicao > 0
      aTab_Deb[nPosicao]    += nValor
   ELSE
      AAdd(aTab_Conta, cCtDeb)
      AAdd(aTab_Deb, nValor)
      AAdd(aTab_Cre, 0)
   Endif
      
   // Totais
   nPosicao = ASCAN(aTab_TConta,cCtDeb)
   IF nPosicao > 0
      aTab_DebTot[nPosicao] += nValor
   Else
      AAdd(aTab_TConta, cCtDeb)
      AAdd(aTab_DebTot, nValor)
      AAdd(aTab_CreTot, 0)
   Endif
Endif

IF ! EMPTY(AllTrim(cCtCre))
   nPosicao = ASCAN(aTab_Conta,cCtCre)
   IF nPosicao > 0
      aTab_Cre[nPosicao]   += nValor
   ELSE
      AAdd(aTab_Conta, cCtCre)
      AAdd(aTab_Cre, nValor)
      AAdd(aTab_Deb, 0)
   Endif
      
   // Totais
   nPosicao = ASCAN(aTab_TConta,cCtCre)
   IF nPosicao > 0
      aTab_CreTot[nPosicao]+= nValor
   Else
      AAdd(aTab_TConta, cCtCre)
      AAdd(aTab_CreTot, nValor)
      AAdd(aTab_DebTot, 0)
   Endif
Endif

RETURN

*--------------------*
Function PF_SENDPRN(lEnd)
*--------------------*                                              
LOCAL cContra_Ant, cHawb_Ant, cIdentc_Ant, cBanco_Ant, cSeqcnt_Ant
PRIVATE aTab_Conta := {}, aTab_Deb := {}, aTab_Cre := {}
Private lTMCONTA:=.f. // Alcir Alves - 18-07-05 - variavel que define se existe ou não o ponto 
oProcess:SetRegua2(nTotECAFin)

If (nTotECAFin) = 0
   Return .T.
Endif

DBSELECTAREA('ECA')
If lTemECANew
   ECA->(DBSETORDER(10))
Endif   
ECA->(DbSeek(cFilECA+"FIEX", .T.))

nLimPage  := 69    ; nColIni := 1
nCol1     := 001   ; nCol2   := 022   ; nCol3     := 027   ; nCol4   := 032
nCol5     := 041   ; nCol6   := 068   ; nCol7     := 084   ; nCol8   := 100
nCol9     := 115   ; nCol10  := 130   
nColFim   := 132   ; nLin    := 80
nColRes1  := 10    ; nColRes2:= 40    ; nColRes3  := 80

DO WHILE ! ECA->(EOF()) .AND. ECA->ECA_FILIAL = cFilECA .AND. Left(ECA->ECA_TPMODU,4) = "FIEX"

   oProcess:IncRegua2("1 / 2 "+STR0054+Alltrim(ECA->ECA_CONTRA)) //"Contrato: "

   If lEnd
      If lEnd:=MsgYesNo(STR0097,STR0098) 
         Return .F.
      EndIf
   EndIf
                   
   IF lTemECANew .And. ECA->ECA_CONTAB <> '1'  // Nao Permite Contabilização
      ECA->(DbSkip())
      Loop
   Endif           

   If nLin > nLimPage
      PExp999CabRel(1,'FIN')
   Endif
   //Alcir Alves - 18-07-05
   EEC->(DBSETORDER(1)) // MJA 11/08/05
   EEC->(DBSEEK(cFilEEC+ECA->ECA_PREEMB)) // MJA 11/08/05
   @ nLin,nCol1 PSay STR0050 + ECA->ECA_CONTRA + STR0100 + IF(SA6->(DBSEEK(cFilSA6+ECA->ECA_BANCO)),SA6->A6_NREDUZ,SPACE(15)) + STR0051 + ECA->ECA_PREEMB + STR0052+; //"Contrato : "###" / Processo : "###" / Unid.Req.: "
			    AllTrim(ECA->ECA_IDENTC) + " - " + If(ECC->(DbSeek(cFilECC+ECA->ECA_IDENTC)), Left(ECC->ECC_DESCR,10), Space(10))+;
			    STR0053 + EEC->EEC_IMPORT //+ " - " + If(SA1->(Dbseek(cFilSA1+ECA->ECA_FORN)), Left(SA1->A1_NREDUZ,10), "") //" / Cliente : "
	    
   nLin++
   cContra_Ant := ECA->ECA_CONTRA
   IF lEFFTPMOD
      cSeqcnt_Ant := ECA->ECA_SEQCNT
   ENDIF
   cHawb_Ant   := ECA->ECA_PREEMB
   cIdentc_Ant := ECA->ECA_IDENTC
   cBanco_Ant  := ECA->ECA_BANCO

   lSaida:= .F.
   lprim:=.t.
   
   DO WHILE ! ECA->(EOF()) .AND. cContra_Ant = ECA->ECA_CONTRA .AND. cHawb_Ant = ECA->ECA_PREEMB ;
            .AND. cIdentc_Ant = ECA->ECA_IDENTC .AND. ECA->ECA_FILIAL = cFilECA ;
            .AND. Left(ECA->ECA_TPMODU,04) = "FIEX" .AND. ECA->ECA_BANCO = cBanco_Ant

/*    IF ECA->ECA_VALOR = 0  // Nao Imprime Valor Zerado
         ECA->(DbSkip())
         Loop
      Endif
*/
      If lprim                                                                               
         lprim:=.f.
      Else
         oProcess:IncRegua2("1 / 2 "+STR0054+Alltrim(ECA->ECA_CONTRA)) //"Contrato: "
      EndIf
      If lEnd
         If lEnd:=MsgYesNo(STR0097,STR0098) 
            Return .F.
         EndIf
      EndIf
         
      IF lTemECANew .And. ECA->ECA_CONTAB <> '1'  // Nao Permite Contabilização
         ECA->(DbSkip())
         Loop
      Endif

      If nLin > nLimPage
         PExp999CabRel(1,'FIN')
         EEC->(DBSETORDER(1)) // MJA 11/08/05
         EEC->(DBSEEK(cFilEEC+ECA->ECA_PREEMB)) // MJA 11/08/05
         @ nLin,nCol1 PSay STR0050 + ECA->ECA_CONTRA + STR0051 + ECA->ECA_PREEMB + STR0052+; //"Contrato : "###" / Processo : "###" / Unid.Req.: "
			               AllTrim(ECA->ECA_IDENTC) + " - " + If(ECC->(DbSeek(cFilECC+ECA->ECA_IDENTC)), Left(ECC->ECC_DESCR,10), "")+;
			               STR0053 + EEC->EEC_IMPORT //+ " - " + If(SA1->(Dbseek(cFilSA1+ECA->ECA_FORN)), Left(SA1->A1_NREDUZ,10), "") //" / Cliente : "
			               
         nLin++
      Endif

      @ nLin,nCol1 PSay ECA->ECA_INVEXP
      @ nLin,nCol2 PSay ECA->ECA_SEQ
      @ nLin,nCol3 PSay If(ECA->ECA_TPMODU = "FIEX01", 'ACC', If(ECA->ECA_TPMODU = "FIEX02", 'ACE', 'PRE'))
      @ nLin,nCol4  PSay DTOC(ECA->ECA_DT_CON)
      @ nLin,nCol5  PSay TRANS(ECA->ECA_ID_CAM,'@R 9.99')+" - "+ECA->ECA_DESCAM
      If EasyEntryPoint("ECOPF999")
         ExecBlock("ECOPF999",.F.,.F.,"TAMANHO_CONTA")
      Endif
	   if !lTMCONTA  //Alcir Alves - 18-07-05 - caso não exista o ponto tamanho conta
	     @ nLin,nCol6  PSay ECA->ECA_CTA_DB
	     @ nLin,nCol7  PSay ECA->ECA_CTA_CR
	     @ nLin,nCol8  PSay TRANS(ECA->ECA_VALOR,'@E 999,999,999.99')
	     If lTemECANew
	        @ nLin,nCol9 PSay TRANS(ECA->ECA_TX_USD,'@E 999,999.999999')
	     Endif
	  Endif
      PREXP200_Resumo(ECA->ECA_CTA_DB,ECA->ECA_CTA_CR,ECA->ECA_VALOR)

      nLin++
      ECA->(DBSKIP())

   Enddo
   nLin++
   IF lSaida
      EXIT
   Endif
ENDDO

IF nPag > 0

   IF cPrv_Efe = "2"
      nLin++
      @ nLin,nCol2 PSay STR0055+"PAEX"+SUBSTR(cMesProc,1,2)+SUBSTR(cMesProc,3,4)+STR0056 //"ARQUIVO DE INTEGRACAO CONTABIL "###".TXT GERADO"
   Endif

   If nTotECAFin > 0
      ER_PEXP200FIMREL('FIN')
   Endif   
   
Endif

RETURN .T.

*---------------------*
Function PE_SENDPRN(lEnd)
*---------------------*
LOCAL cHawb_Ant, cIdentc_Ant, cTipoProc, lPassouExe := .F.
PRIVATE aTab_Conta := {}, aTab_Deb := {}, aTab_Cre := {}, cNomeArq

oProcess:SetRegua2(nTotECAExp)

If (nTotECAExp+nTotECAFin) = 0
   Return .T.
Endif

DBSELECTAREA('ECA')
If lTemECANew
   ECA->(DBSETORDER(11))
Else
   ECA->(DBSETORDER(2))
Endif   
ECA->(DbSeek(cFilECA+"EXPORT", .T.))

//cAlias := CriaWork(if(cPrv_Efe='1',"PR","EF")) // MJA 08/04/05 Chamada para criar WORK e gerar a Prévia em DBF
nLimPage  := 69    ; nColIni := 1
nCol1     := 001   ; nCol2   := 029   ; nCol3     := 040   ; nCol4   := 056
nCol5     := 072   ; nCol6   := 087   ; nCol7     := 102   ; nCol8   := 124
nCol9     := 130   
nColFim   := 132   ; nLin    := 80
nColRes1  := 10    ; nColRes2:= 40    ; nColRes3  := 80

DO WHILE ! ECA->(EOF()) .AND. ECA->ECA_FILIAL = cFilECA .AND. ECA->ECA_TPMODU = "EXPORT"

   oProcess:IncRegua2("2 / 2 "+STR0060+Alltrim(ECA->ECA_PREEMB)) //"Processo: "

   If lEnd
      If lEnd:=MsgYesNo(STR0097,STR0098) 
         Return .F.
      EndIf
   EndIf

   IF lTemECANew .And. ECA->ECA_CONTAB <> '1'  // Nao Permite Contabilização
      ECA->(DbSkip())
      Loop
   Endif         

   If nLin > nLimPage
      PExp999CabRel(1,'EXP')
   Endif
   
   cTipoProc := If(ECA->ECA_FASE $ 'C', STR0057, If(ECA->ECA_FASE $ 'P', STR0058, STR0032)) //"Cliente  : "###"Pedido   : "###"Processo : "

   EEC->(DBSETORDER(1)) // MJA 11/08/05
   EEC->(DBSEEK(cFilEEC+ECA->ECA_PREEMB)) // MJA 11/08/05
   @ nLin,nCol1 PSay cTipoProc + ECA->ECA_PREEMB + If(ECA->ECA_FASE $ 'C', " - ", "") + If(ECA->ECA_FASE $ 'C', If(SA1->(Dbseek(cFilSA1+Alltrim(ECA->ECA_PREEMB))), Left(SA1->A1_NREDUZ,10), Space(10)), Space(13)) + ;
                STR0059 + ECA->ECA_INVEXP +; //" / Invoice : "
                STR0052 + ECA->ECA_IDENTC + " - " + If(ECC->(DbSeek(cFilECC+ECA->ECA_IDENTC)), Left(ECC->ECC_DESCR,10), "") +; //" / Unid.Req.: "
                If(!ECA->ECA_FASE $ 'C', STR0053 + EEC->EEC_IMPORT, "") //" / Cliente : "  //+ " - " + If(SA1->(Dbseek(cFilSA1+ECA->ECA_FORN)), Left(SA1->A1_NREDUZ,10), ""), "") //" / Cliente : "

   nLin++
   cHawb_Ant   := ECA->ECA_PREEMB
   cInv_Ant    := ECA->ECA_INVEXP
   cIdentc_Ant := ECA->ECA_IDENTC

   lSaida:= .F.
   lprim:=.t.
            
   DO WHILE ! ECA->(EOF()) .AND. cHawb_Ant = ECA->ECA_PREEMB ;
            .AND. cInv_Ant = ECA->ECA_INVEXP ;
            .AND. cIdentc_Ant = ECA->ECA_IDENTC .AND. ECA->ECA_FILIAL = cFilECA ;
            .AND. ECA->ECA_TPMODU = "EXPORT"

/*    IF ECA->ECA_VALOR = 0  // Nao Imprime Valor Zerado
         ECA->(DbSkip())
         Loop
      Endif
*/
      If lprim                                                                               
         lprim:=.f.
      Else
         oProcess:IncRegua2("2 / 2 "+STR0060+Alltrim(ECA->ECA_PREEMB)) //"Processo: "
      EndIf              

      If lEnd
         If lEnd:=MsgYesNo(STR0097,STR0098) 
            Return .F.
         EndIf
      EndIf      
      
      IF lTemECANew .And. ECA->ECA_CONTAB <> '1'  // Nao Permite Contabilização
         ECA->(DbSkip())
         Loop
      Endif
/*      
      Reclock(cAlias,.T.)
      (cAlias)->PROCESSO := ECA->ECA_PREEMB
      (cAlias)->INVOICE  := ECA->ECA_INVEXP
      (cAlias)->UNID_REQ := ECA->ECA_IDENTC
      (cAlias)->EVENTO   := ECA->ECA_ID_CAM
      (cAlias)->DESCRICAO := ECA->ECA_DESCAM
      (cAlias)->DT_CONT   := ECA->ECA_DT_CON
      (cAlias)->DEBITO    := ECA->ECA_CTA_DB
      (cAlias)->CREDITO   := ECA->ECA_CTA_CR
      (cAlias)->VALOR     := ECA->ECA_VALOR
      (cAlias)->TAXA      := ECA->ECA_TX_USD
      (cAlias)->NF        := ECA->ECA_NRNF
      (cAlias)->PARCELA   := ECA->ECA_SEQ
      (cAlias)->(Msunlock())
*/      
      If nLin > nLimPage
         PExp999CabRel(1,'EXP')
         
         cTipoProc := If(ECA->ECA_FASE $ 'C', STR0057, If(ECA->ECA_FASE $ 'P', STR0058, STR0032)) //"Cliente  : "###"Pedido   : "###"Processo : "
         EEC->(DBSETORDER(1)) // MJA 11/08/05
         EEC->(DBSEEK(cFilEEC+ECA->ECA_PREEMB)) // MJA 11/08/05
         @ nLin,nCol1 PSay cTipoProc + ECA->ECA_PREEMB + STR0059 + ECA->ECA_INVEXP +; //" / Invoice : "
                           STR0052 + ECA->ECA_IDENTC + " - " + If(ECC->(DbSeek(cFilECC+ECA->ECA_IDENTC)), Left(ECC->ECC_DESCR,10), "") +; //" / Unid.Req.: "
                           STR0053 + EEC->EEC_IMPORT //+ " - " + If(SA1->(Dbseek(cFilSA1+ECA->ECA_FORN)), Left(SA1->A1_NREDUZ,10), "") //" / Cliente : "
         nLin++
      Endif
       
      @ nLin,nCol1  PSay TRANS(ECA->ECA_ID_CAM,'@R 9.99')+" - "+ECA->ECA_DESCAM
      @ nLin,nCol2  PSay DTOC(ECA->ECA_DT_CON)
      @ nLin,nCol3  PSay ECA->ECA_CTA_DB
      @ nLin,nCol4  PSay ECA->ECA_CTA_CR
      @ nLin,nCol5  PSay TRANS(ECA->ECA_VALOR,'@E 999,999,999.99')
      If ECA->ECA_TX_USD # 0
         @ nLin,nCol6 PSay TRANS(ECA->ECA_TX_USD,'@E 999,999.999999')
      Endif
      @ nLin,nCol7 PSay ECA->ECA_NRNF
      If !Empty(ECA->ECA_SEQ)
         @ nLin,nCol8+2 PSay StrZero(Val(ECA->ECA_SEQ),2)
      Endif

      PREXP200_Resumo(ECA->ECA_CTA_DB,ECA->ECA_CTA_CR,ECA->ECA_VALOR)

      nLin++
      ECA->(DBSKIP())

   Enddo
   nLin++
   IF lSaida
      EXIT
   Endif
ENDDO

IF nPag > 0

   IF cPrv_Efe = "2"
      nLin++
      lPassouExe := .F.
      If EasyEntryPoint("ECOPF999")
         If ExecBlock("ECOPF999",.F.,.F.,"IMP_NOME")
           lPassouExe := .T.
         Endif
      Endif
      If !lPassouExe
         @ nLin,nCol2 PSay STR0055+"PAEX"+SUBSTR(cMesProc,1,2)+SUBSTR(cMesProc,3,4)+STR0056 //"ARQUIVO DE INTEGRACAO CONTABIL "###".TXT GERADO."
      Endif
   Endif

   If nTotECAExp > 0
      ER_PEXP200FIMREL('EXP')
   Endif
   
   // Total Geral das contas
   ER_PEXP200FIMREL('TOT')
                 
Endif

// Imprime Mensagens de Divergências                                      
If LEN(aTabMsg)>0
   PExp999CabRel(3,'EXP')
   Aeval(aTabMsg,b_aTabMsg)
Endif

SET DEVICE TO SCREEN
     
/*     
(cAlias)->(DBCLOSEAREA())
if FILE(cRelato+cNomeArq+".DBF")
   FERASE(cRelato+cNomeArq+".DBF")
ENDIF   
CpyS2T(".\"+curdir()+cNomeArq+".DBF",cRelato, .T. )
FRENAME(cRelato+cNomeArq+".DBF",cRelato+cAlias+".dbf")
//Copy to &(cRelato+cAlias)
*/


If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

RETURN .T.
*---------------------------------*
Function PExp999CabRel(nRel,cTipo)
*---------------------------------*

aDriver  := ReadDriver()
@ 0,0 PSay &(aDriver[3])

nLin:= 1
nPag++

If nRel=1
   IF cPrv_Efe = "1"
      cTexto1:= STR0061 + If(lDiaria, STR0062, STR0038 ) + STR0063 + If(cTipo = 'FIN', STR0064, STR0065) + STR0066+SUBSTR(cMesProc,1,2)+"/"+SUBSTR(cMesProc,3,4) //"PREVIA "###"DIARIA"###"MENSAL"###" DA INTEGRACAO "###"FINANCIAMENTO "###"DA "###"EXPORTACAO - "
      cTexto2:= STR0067+DTOC(dDataBase)+STR0068+cHora //"Data da Previa.: "###" Hora.: "
   ELSE
      cTexto1:= STR0069 + If(lDiaria, STR0062, STR0038 ) + STR0063 + If(cTipo = 'FIN', STR0064, STR0065) + STR0066+SUBSTR(cMesProc,1,2)+"/"+SUBSTR(cMesProc,3,4) //"EFETIVACAO "###"DIARIA"###"MENSAL"###" DA INTEGRACAO "###"FINANCIAMENTO "###"DA "###"EXPORTACAO - "
      cTexto2:= STR0070+DTOC(dDataBase)+STR0068+cHora //"Data da Efetivacao.: "###" Hora.: "
   Endif
Elseif nRel=2
   If cTipo <> 'TOT'
      cTexto1:= STR0071 + If(cTipo = "FIN", 'FINANCIAMENTO', 'EXPORTACAO') + " - " + SUBSTR(cMesProc,1,2)+"/"+SUBSTR(cMesProc,3,4) //"RESUMO "
   Else
      cTexto1:= STR0072+SUBSTR(cMesProc,1,2)+"/"+SUBSTR(cMesProc,3,4) //"RESUMO GERAL - "
   Endif
   IF cPrv_Efe = "1"
      cTexto2:= STR0067+DTOC(dDataBase)+STR0068+cHora //"Data da Previa.: "###" Hora.: "
   Else
      cTexto2:= STR0070+DTOC(dDataBase)+STR0068+cHora //"Data da Efetivacao.: "###" Hora.: "
   Endif
Else
   cTexto1:= STR0073 //"RELACAO DE MENSAGENS"
   cTexto2:= ""
Endif

@ nLin,nColIni PSay Replicate("-",nColFim)
nLin++

@ nLin,nColIni PSay AllTrim(SM0->M0_NOME)+" - "+AllTrim(SM0->M0_FILIAL)
@ nLin,( (nColFim/2) - Round((Len(cTexto1)/2),0) ) PSay cTexto1
@ nLin,nColFim-19 PSay STR0074+STR(nPag,8) //"Pagina..: "
nLin++

@ nLin,nColIni PSay STR0075 //'SIGAECO'
@ nLin,( (nColFim/2) - Round((Len(cTexto2)/2),0) ) PSay cTexto2
@ nLin,nColFim-19 PSay STR0076+DTOC(dDatabase) //"Emissao.: "
nLin++

@ nLin,nColIni PSay Replicate("-",nColFim)

If nRel#3
   nLin++
   @ nLin,10 PSay STR0077+STRZERO(nNR_Cont+1,4,0) //"Numero da Contabilizacao..: "
   @ nLin,76 PSay STR0078+DTOC(dData_Con) //"Data da Contabilizacao..: "
Endif
nLin++

If nRel=1
   nLin++    
   If cTipo = 'FIN'
      @ nLin,nCol1  PSay STR0079 //'Invoice'
      @ nLin,nCol2  PSay STR0080 //'Parc.'
      @ nLin,nCol3  PSay STR0081 //'Tipo'
      @ nLin,nCol4  PSay STR0082 //'Dt.Cont.'
      @ nLin,nCol5  PSay STR0083 //'Descricao Contabil'
      @ nLin,nCol6  PSay STR0084 //'Debito'
      @ nLin,nCol7  PSay STR0085 //'Credito'
      @ nLin,nCol8  PSay STR0086 //'Valor'
      @ nLin,nCol9  PSay STR0087 //'Taxa Usada'
      nLin++
      @ nLin,nCol1  PSay Repli('-',20)
      @ nLin,nCol2  PSay Repli('-',04)
      @ nLin,nCol3  PSay Repli('-',04)
      @ nLin,nCol4  PSay Repli('-',08)
      @ nLin,nCol5  PSay Repli('-',26)
      @ nLin,nCol6  PSay Repli('-',15)
      @ nLin,nCol7  PSay Repli('-',15)
      @ nLin,nCol8  PSay Repli('-',14)
      @ nLin,nCol9  PSay Repli('-',14)
   Else
      @ nLin,nCol1  PSay STR0083 //'Descricao Contabil'
      @ nLin,nCol2  PSay STR0082 //'Dt.Cont.'
      @ nLin,nCol3  PSay STR0084 //'Debito'
      @ nLin,nCol4  PSay STR0085 //'Credito'
      @ nLin,nCol5  PSay STR0086 //'Valor'
      @ nLin,nCol6  PSay STR0087 //'Taxa Usada'
      @ nLin,nCol7  PSay STR0088 //'Nota Fiscal'
      @ nLin,nCol8  PSay STR0089 //'Parcela'
      nLin++
      @ nLin,nCol1  PSay Repli('-',27)
      @ nLin,nCol2  PSay Repli('-',08)
      @ nLin,nCol3  PSay Repli('-',15)
      @ nLin,nCol4  PSay Repli('-',15)
      @ nLin,nCol5  PSay Repli('-',14)
      @ nLin,nCol6  PSay Repli('-',14)
      @ nLin,nCol7  PSay Repli('-',20)
      @ nLin,nCol8  PSay Repli('-',07)     
   Endif   
   nLin++
Elseif nRel=2
   nLin++
   @ nLin,nColRes1 PSay STR0090 //'Conta'
   @ nLin,nColRes2 PSay STR0084 //'Debito'
   @ nLin,nColRes3 PSay STR0085 //'Credito'
   nLin++
   @ nLin,nColRes1 PSay REPLI('-',15)
   @ nLin,nColRes2 PSay REPLI('-',25)
   @ nLin,nColRes3 PSay REPLI('-',25)
   nLin++
Endif

RETURN

// Financiamento
// Contrato :     - Processo :        - Unid.Req.:
//  1                     2                      3    4      5        6                         7                8              9           10             11
//INVOICE                SEQ.  TIPO DT.CONTAB. DESCRICAO CONTABIL         DEBITO          CREDITO         VALOR          TAXA USADA     CLIENTE
//---------------------- ----- ---- ---------- -------------------------- --------------- --------------- -------------- -------------- ---------

// Exportação
// Processo :       - Invoice :          - Unid.Req.: 
//  1                              2              3            4             5               6               7                     8
//DESCRICAO CONTABIL          DT.CONTAB.     DEBITO          CREDITO         VALOR          TAXA USADA     NOTA FISCAL            PARCELA
// -------------------------- ----------     --------------- --------------- -------------- -------------- ---------------------- ------- 

*-------------------------------*
Function ER_PEXP200FIMREL(cTipo)
*-------------------------------*
Local aOrdemConta := {}, i

PExp999CabRel(2, cTipo)

nVlr_Deb := 0
nVlr_Cre := 0             

For I := 1 TO Len(If(cTipo # 'TOT', aTab_Conta, aTab_TConta)) 
    If cTipo # 'TOT'
       AAdd( aOrdemConta, { aTab_Conta[I], aTab_Deb[I], aTab_Cre[I]} )
    Else
       AAdd( aOrdemConta, { aTab_TConta[I], aTab_DebTot[I], aTab_CreTot[I]} )
    Endif   
Next                                                              
   
// Ordena Array por Ordem de Conta
aSort(aOrdemConta,,,{|x,y| x[1] < y[1]})
   
For I := 1 TO Len(aOrdemConta)
   @ nLin,nColRes1 PSay aOrdemConta[I,1]
   @ nLin,nColRes2 PSay TRANS(aOrdemConta[I,2],'@E 999,999,999,999.99')
   @ nLin,nColRes3 PSay TRANS(aOrdemConta[I,3],'@E 999,999,999,999.99')
   nVlr_Deb = nVlr_Deb + aOrdemConta[I,2]
   nVlr_Cre = nVlr_Cre + aOrdemConta[I,3]
   nLin++
   If nLin > nLimPage
      PExp999CabRel(2, cTipo)
   Endif
Next

@ nLin,nColRes2 PSay STR0091 //"------------------"
@ nLin,nColRes3 PSay STR0091 //"------------------"
nLin++
@ nLin,nColRes2 PSay TRANS(nVlr_Deb,'@E 999,999,999,999.99')
@ nLin,nColRes3 PSay TRANS(nVlr_Cre,'@E 999,999,999,999.99')
nLin++
@ nLin,nColRes2 PSay ''

Return
*--------------------------*
Function ER_f_say(qualquer)
*--------------------------*
LOCAL cSay:="", nTam := 90
If nLin > nLimPage-1
   PExp999CabRel(3,'EXP')
Endif

cSay:=MEMOLINE(qualquer,nTam,1)
@ nLin,nCol1 PSay Trans(cSay,"@!")

IF LEN(AllTrim(qualquer)) > nTam
   nLin++
   cSay:=MEMOLINE(qualquer,nTam,2)
   @ nLin,nCol1 PSay Trans(cSay,"@!")
Endif
nLin++

Return Nil

*------------------------*
FUNCTION ECOEXP999_LIMPA(lEnd)
*------------------------*
Local nCount := 0, nCont := 0, cQuery

// ECA
IF lTop
   IF ECA->(EasyRecCount())/1024 < 1
      nCount := 1
   Else
      nCount := Round(ECA->(EasyRecCount())/1024,0)
   Endif
   
   oProcess:SetRegua2(nCount)   
   
   nCount:=ECA->(EasyRecCount())
   nCont := 0                   

   // APAGA A CADA 1024 PARA NÃO ENCHER O LOG DO BANCO
   While nCont <= nCount
        oProcess:IncRegua2("1 / 1 "+STR0092) //"Limpando Arquivo da Prévia..."
        If lEnd
           If lEnd:=MsgYesNo(STR0097,STR0098) 
              Return .F.
           EndIf
        EndIf

        cQuery := "DELETE FROM "+RetSqlName("ECA")
       	cQuery := cQuery + " WHERE R_E_C_N_O_ between "+Str(nCont)+" AND "+Str(nCont+1024)
       	cQuery := cQuery + " AND ECA_FILIAL = '" + cFilECA + "'"
        Query := cQuery + " AND (ECA_TPMODU = 'FIEX01' OR ECA_TPMODU = 'FIEX02' OR ECA_TPMODU = 'FIEX03' OR ECA_TPMODU = 'EXPORT')"
        nCont := nCont + 1024
    	TCSQLEXEC(cQuery)
   Enddo

Else
   oProcess:SetRegua2(nTotECAFin)
   DBSELECTAREA('ECA')
   ECA->(DbSeek(cFilECA+"FIEX",.T.))     
   ECA->(DBEVAL({||(oProcess:IncRegua2("1 / 2"+STR0050+Alltrim(ECA->ECA_CONTRA)),ECA->(Reclock('ECA',.F.)),ECA->(DBDELETE()),ECA->(MSUNLOCK()))},,{||ECA->ECA_FILIAL==cFilECA .AND. Left(ECA->ECA_TPMODU,04) = "FIEX" },,,.T.)) //"Limpando Arquivo da Prévia..."###"Contrato : "
   oProcess:SetRegua2(nTotECAExp)
   ECA->(DbSeek(cFilECA+"EXPORT",.T.))
   ECA->(DBEVAL({||(oProcess:IncRegua2("2 / 2"+STR0032+Alltrim(ECA->ECA_PREEMB)),ECA->(Reclock('ECA',.F.)),ECA->(DBDELETE()),ECA->(MSUNLOCK()))},,{||ECA->ECA_FILIAL==cFilECA .AND. ECA->ECA_TPMODU = "EXPORT" },,,.T.)) //"Limpando Arquivo da Prévia..."###"Processo : "
Endif
                    
Return .T.

*------------------------------------------*
FUNCTION ECOEXP999Tx(PInd, PData, cTipoTx)
*------------------------------------------*
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
      AADD(aTabMsg, STR0093+ Pind +") "+ Dtoc(PData)) //"Taxa Zerada - ("
   Endif
Endif

Return nTaxaECO         

*-------------------------*
FUNCTION ECOEXPContaReg()
*-------------------------*
Local cQueryEF1, cQueryECE, cQueryEEC, cQueryEEQ, cQueryECG
Local cAliasEF1, cAliasECE, cAliasEEC, cAliasEEQ, cAliasECG

nTotEF1 := nTotECE := nTotEEC := nTotEEQ1 := nTotEEQ2 := nTotECG := 0
  
IF lTop

  cAliasEF1    := "EF1TMP"
  cAliasECE    := "ECETMP"
  cAliasEEC    := "EECTMP"
  cAliasEEQ1   := "EEQ1TMP"
  cAliasEEQ2   := "EEQ2TMP"  
  cAliasECG    := "ECGTMP"
  
  // Querys
  cQueryEF1    := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EF1")+ " WHERE EF1_FILIAL='"+ cFilEF1 +"' AND D_E_L_E_T_ <> '*' "
  cQueryECE    := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("ECE")+ " WHERE ECE_FILIAL='"+ cFilECE +"' AND D_E_L_E_T_ <> '*' AND ECE_NR_CON = '0000' " //AAF 27/04/07 - AND ECE_ORIGEM = 'CO'
  cQueryEEC    := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EEC")+ " WHERE EEC_FILIAL='"+ cFilEEC +"' AND D_E_L_E_T_ <> '*' "
  cQueryEEQ1   := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EEQ")+ " WHERE EEQ_FILIAL='"+ cFilEEQ +"' AND D_E_L_E_T_ <> '*' AND (EEQ_NR_CON = '' OR EEQ_NR_CON = ' ')"
  cQueryEEQ2   := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EEQ")+ " WHERE EEQ_FILIAL='"+ cFilEEQ +"' AND D_E_L_E_T_ <> '*' AND EEQ_PGT >= '" + DTOS(dDta_Ini) + "' AND EEQ_PGT <= '" + DTOS(dDta_Fim) + "' "
  cQueryECG    := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("ECG")+ " WHERE ECG_FILIAL='"+ cFilECG +"' AND D_E_L_E_T_ <> '*' AND ECG_ORIGEM = 'EX' "

  If lTemTPMODU
     cQueryECE += "AND ECE_TPMODU = 'EXPORT'"
     cQueryECG += "AND ECG_TPMODU = 'EXPORT'"     
  EndIf
  
  // EF1
  PExpExecQry(cQueryEF1, cAliasEF1)
  If Select(cAliasEF1) > 0
     nTotEF1 := (cAliasEF1)->TOTALREG
     (cAliasEF1)->(DbCloseArea())
  Else
     nTotEF1 := 0
  Endif

  // ECE
  PExpExecQry(cQueryECE, cAliasECE)
  If Select(cAliasECE) > 0
     nTotECE := (cAliasECE)->TOTALREG
     (cAliasECE)->(DbCloseArea())
  Else
     nTotECE := 0
  Endif
  
  // EEC
  PExpExecQry(cQueryEEC, cAliasEEC)
  If Select(cAliasEEC) > 0
     nTotEEC := (cAliasEEC)->TOTALREG
     (cAliasEEC)->(DbCloseArea())
  Else
     nTotEEC := 0
  Endif

  // EEQ1
  PExpExecQry(cQueryEEQ1, cAliasEEQ1)
  If Select(cAliasEEQ1) > 0
     nTotEEQ1 := (cAliasEEQ1)->TOTALREG
     (cAliasEEQ1)->(DbCloseArea())
  Else
     nTotEEQ1 := 0
  Endif

  // EEQ2
  PExpExecQry(cQueryEEQ2, cAliasEEQ2)
  If Select(cAliasEEQ2) > 0
     nTotEEQ2 := (cAliasEEQ2)->TOTALREG
     (cAliasEEQ2)->(DbCloseArea())
  Else
     nTotEEQ2 := 0
  Endif

  // ECG
  PExpExecQry(cQueryECG, cAliasECG)
  If Select(cAliasECG) > 0
     nTotECG := (cAliasECG)->TOTALREG
     (cAliasECG)->(DbCloseArea())
  Else
     nTotECG := 0
  Endif

Else    

  // EF1
  EF1->(DbSeek(cFilEF1,.T.))
  EF1->(DBEVAL({||nTotEF1++, MsProcTxt(STR0094+EF1->EF1_CONTRA)},,{||EF1->(!EOF()) .And. EF1->EF1_FILIAL = cFilEF1 })) //"Lendo Contrato: "
  
  // ECE
  ECE->(DbSeek(cFilECE+cTPMODU+'0000',.T.))
  ECE->(DBEVAL({||nTotECE++, MsProcTxt(STR0094+ECE->ECE_CONTRA)},,{||ECE->(!EOF()) .And. ECE->ECE_FILIAL = cFilECE .And. ECE->ECE_ORIGEM = 'CO' .And. ECE->ECE_NR_CON = '0000' .And. Eval(bTPMODUECE)})) //"Lendo Contrato: "
  
  // ECE
  EEC->(DbSeek(cFilEEC,.T.))
  EEC->(DBEVAL({||nTotEEC++, MsProcTxt(STR0095+EEC->EEC_PREEMB)},,{||EEC->(!EOF()) .And. EEC->EEC_FILIAL = cFilEEC })) //"Lendo Processo: "

  // EEQ1  
  EEQ->(DbSetOrder(8))
  EEQ->(DbSeek(cFilEEQ+Space(Len(EEQ->EEQ_NR_CON)),.T.))
  EEQ->(DBEVAL({||nTotEEQ1++, MsProcTxt(STR0095+EEQ->EEQ_PREEMB)},,{||EEQ->(!EOF()) .And. EEQ->EEQ_FILIAL = cFilEEQ .And. Empty(EEQ->EEQ_NR_CON) })) //"Lendo Processo: "
  EEQ->(DbSetOrder(1))

  // EEQ2
  EEQ->(DbSetOrder(9))
  EEQ->(DbSeek(cFilEEQ+Dtos(dDta_Ini),.T.))
  EEQ->(DBEVAL({||nTotEEQ2++, MsProcTxt(STR0095+EEQ->EEQ_PREEMB)},,{||EEQ->(!EOF()) .And. EEQ->EEQ_FILIAL = cFilEEQ .And. EEQ->EEQ_PGT <= dDta_Fim })) //"Lendo Processo: "
  EEQ->(DbSetOrder(1))
  
  // EEC
  EEC->(DbSetOrder(12)) 
  EEC->(DbSeek(cFilEEC,.T.))
  EEC->(DBEVAL({||nTotEEC++, MsProcTxt(STR0095+EEC->EEC_PREEMB)},,{||EEC->(!EOF()) .And. EEC->EEC_FILIAL = cFilEEC .And. EEC->EEC_DTEMBA <= (dDta_Fim) })) //"Lendo Processo: "
  EEC->(DbSetOrder(1))

  // ECG
  ECG->(DbSeek(cFilECG+cTPMODU,.T.))
  ECG->(DBEVAL({||nTotECG++, MsProcTxt(STR0095+ECG->ECG_PREEMB)},,{||ECG->(!EOF()) .And. ECG->ECG_FILIAL = cFilECG .And. (ECG->ECG_ORIGEM = 'EX') .And. Eval(bTPMODUECG) })) //"Lendo Processo: "

Endif

RETURN .T.     

*------------------------------*
FUNCTION ECOECAContaReg(cOpcao)
*------------------------------*
Local cQueryECAFin, cQueryECAExp
Local cAliasECAFin, cAliasECAExp

nTotECAFin := 0
nTotECAExp := 0
  
IF lTop
  
  cAliasECAFin := "ECATMPFIN"
  cAliasECAExp := "ECATMPEXP"

  // Querys
  cQueryECAFin := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("ECA")+ " WHERE ECA_FILIAL='"+ cFilECA +"' AND D_E_L_E_T_ <> '*' AND ECA_TPMODU = 'FIEX01' OR ECA_TPMODU = 'FIEX02' OR ECA_TPMODU = 'FIEX03' "
  cQueryECAExp := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("ECA")+ " WHERE ECA_FILIAL='"+ cFilECA +"' AND D_E_L_E_T_ <> '*' AND ECA_TPMODU = 'EXPORT' "

  // ECA - Financiamento
  If cOpcao = 'TODOS' .Or. cOpcao = 'FIN'
     PExpExecQry(cQueryECAFin, cAliasECAFin)
     If Select(cAliasECAFin) > 0
        nTotECAFin := (cAliasECAFin)->TOTALREG
        (cAliasECAFin)->(DbCloseArea())
     Else
        nTotECAFin := 0
     Endif
  Endif
  
  // ECA - Exportação
  If cOpcao = 'TODOS' .Or. cOpcao = 'EXP'
     PExpExecQry(cQueryECAExp, cAliasECAExp)
     If Select(cAliasECAExp) > 0
        nTotECAExp := (cAliasECAExp)->TOTALREG
        (cAliasECAExp)->(DbCloseArea())
     Else
        nTotECAExp := 0
     Endif
  Endif
  
Else    

  // ECA - Financiamento
  ECA->(DbSeek(cFilECA+"FIEX",.T.))
  ECA->(DBEVAL({||nTotECAFin++, MsProcTxt(STR0094+ECA->ECA_CONTRA)},,{||ECA->(!EOF()) .And. ECA->ECA_FILIAL = cFilECA .AND. Left(ECA->ECA_TPMODU,04) = "FIEX" })) //"Lendo Contrato: "
  
  // ECA - Exportação
  ECA->(DbSeek(cFilECA+"EXPORT",.T.))
  ECA->(DBEVAL({||nTotECAExp++, MsProcTxt(STR0095+ECA->ECA_PREEMB)},,{||ECA->(!EOF()) .And. ECA->ECA_FILIAL = cFilECA .AND. ECA->ECA_TPMODU = "EXPORT" })) //"Lendo Processo: "

Endif

RETURN .T.  
   
*------------------------------------------*
STATIC FUNCTION PExpExecQry(cQuery, cAlias)
*------------------------------------------*

cQuery := ChangeQuery(cQuery)
DbUsearea(.T.,"TOPCONN", TCGenQry(,,cQuery), cAlias,.F.,.T.)

RETURN .T.




*------------------------------------*
STATIC FUNCTION CALC_FSOD(Tipo,nValor)
*------------------------------------*

Local nTxUtil, nTxIniMes, nTxEmbarq, nTxMesAnt, cTX_101, cMoeda

IF nValor = 0
   nValor := EEQ->EEQ_VL
ENDIF   

ECG->(DbSeek(cFilECG+cTPMODU+'EX'+EEQ->EEQ_PREEMB))
cMoeda := EEQ->EEQ_MOEDA
EC6->(DbSeek(cFilEC6+"EXPORT"))
cTX_101 := EC6->EC6_TXCV // Para saber se deve usar a taxa de compra ou venda (1 - 2)
	
//Taxas
nTxFimMes := ECOEXP999Tx(cMoeda, dDta_Fim, cTX_101 ) // (Moeda, data, Compra(1) ou venda(2))
nTxIniMes := ECOEXP999Tx(cMoeda, dDta_Ini, cTX_101 )
nTxEmbarq := ECOEXP999Tx(cMoeda, EEC->EEC_DTEMBA, cTX_101)
If EEC->EEC_MOEDA = EEQ->EEQ_MOEDA
   If !Empty(ECG->ECG_ULT_TX)
      nTxMesAnt := ECG->ECG_ULT_TX
    Else
      nTxMesAnt := nTxIniMes
   EndIf                        
Else
   nTxMesAnt := ECOEXP999Tx(cMoeda, dDta_Ini-1, cTX_101 )
EndIf
IF EEC->EEC_DTEMBA >= dDta_Ini .and. EEC->EEC_DTEMBA <= dDta_Fim
   nTxMesAnt := nTxEmbarq
ENDIF                      

If Tipo == "IN"
  // IF /*(EEQ->EEQ_VCT >= dDta_Ini .And. EEQ->EEQ_VCT <= dDta_Fim ) .OR. */ (EEQ->EEQ_PGT >= dDta_Ini .And. EEQ->EEQ_PGT <= dDta_Fim )
      //--------------------------- CALCULO DE FRETE/SEGURO/OUTRAS DESPESAS APOS EMBARQUE -----------------// MJA 16/09/04
	  IF EMPTY(EEQ->EEQ_NR_CON)
         //                     1                 2         3          4                 5         6               7           8          9            10       11   12         13          14  15  16  17  18  19        20      21 22     23                            24                                         25           26 27    28  29
        AAdd(aDadosPRV, {nValor*nTxEmbarq, EEQ->EEQ_EVENT, "", EEQ->EEQ_NRINVO, EEQ->EEQ_EVENT, dDta_Fim, EEQ->EEQ_MOEDA, nTxEmbarq, nTxFimMes, EEQ->EEQ_PARC, "", 'EXP', EEQ->EEQ_PREEMB, "", "", "", "", "", "", EEQ->EEQ_DTVC, 0, 0,nValor,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
     ENDIF   
     IF !EMPTY(EEQ->EEQ_PGT)
        //                           1                                               2                             3          4                                          5                                       6               7              8          9            10       11   12         13          14  15  16  17  18  19        20      21 22   23                              24                                       25             26 27   28    29
        AAdd(aDadosPRV, {nValor*EEQ->EEQ_TX, IF(EEQ->EEQ_EVENT='102','610',IF(EEQ->EEQ_EVENT='103','611','615')), "", EEQ->EEQ_NRINVO, IF(EEQ->EEQ_EVENT='102','610',IF(EEQ->EEQ_EVENT='103','611','615')), EEQ->EEQ_PGT, EEQ->EEQ_MOEDA, EEQ->EEQ_TX, nTxFimMes, EEQ->EEQ_PARC, "", 'EXP', EEQ->EEQ_PREEMB, "", "", "", "", "", "", EEQ->EEQ_DTVC, 0, 0,nValor,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})    	   
     ENDIF
     if !Empty(EEQ->EEQ_PGT) .AND. EEQ->EEQ_PGT <= dDta_Fim // Encerre o mes e possua pagamaneto
        nVariacao := (nValor * EEQ->EEQ_TX) - (nValor * nTxMesAnt)
        nTxUtil := EEQ->EEQ_TX
        dDtaUtil := EEQ->EEQ_PGT
      elseif Empty(EEQ->EEQ_PGT) // Encerre o mes e nao possua pagamento
        nVariacao := (nValor * nTxFimMes) - (nValor * nTxMesAnt)
        nTxUtil := nTxFimMes
        dDtaUtil := dDta_Fim        
      elseif EEQ->EEQ_PGT > dDta_Fim .and. (EEQ->EEQ_PGT < (dDta_Fim+30)) // encerre o mes e tenha embarque para o mes seguinte
        nVariacao := (nValor * EEQ->EEQ_TX) - (nValor * nTxMesAnt)
        nTxUtil := EEQ->EEQ_TX
        dDtaUtil := EEQ->EEQ_PGT
      elseif EEQ->EEQ_PGT > (dDta_Fim+30) // encerre o mes e nao tenha embarque para o mes seguinte
        nVariacao := (nValor * nTxFimMes) - (nValor * nTxMesAnt)
        nTxUtil := nTxFimMes
        dDtaUtil := dDta_Fim
     endif
     If nVariacao <> 0 
        DO CASE
           CASE EEQ->EEQ_EVENT = '102' // Frete
                AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, '570', '571'), "", EEQ->EEQ_PREEMB, If(nVariacao > 0, '570', '571'), dDtaUtil, EEQ->EEQ_MOEDA, nTxUtil, nTxMesAnt, EEQ->EEQ_PARC, "", 'EXP', EEQ->EEQ_PREEMB, "", "", "", "", "", "", EEQ->EEQ_DTVC, 0, 0,EEQ->EEQ_VL,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
           CASE EEQ->EEQ_EVENT = '103' //  Seguro
                AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, '572', '573'), "", EEQ->EEQ_PREEMB, If(nVariacao > 0, '572', '573'), dDtaUtil, EEQ->EEQ_MOEDA, nTxUtil, nTxMesAnt, EEQ->EEQ_PARC, "", 'EXP', EEQ->EEQ_PREEMB, "", "", "", "", "", "", EEQ->EEQ_DTVC, 0, 0,EEQ->EEQ_VL,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
           OTHERWISE                   //  Outras Despesas

                AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, '542', '543'), "", EEQ->EEQ_PREEMB, If(nVariacao > 0, '542', '543'), dDtaUtil, EEQ->EEQ_MOEDA, nTxUtil, nTxMesAnt, EEQ->EEQ_PARC, "", 'EXP', EEQ->EEQ_PREEMB, "", "", "", "", "", "", EEQ->EEQ_DTVC, 0, 0,EEQ->EEQ_VL,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
        ENDCASE        
     endif   
  // Endif
ENDIF   
PExp999_PrvRat(aDadosPRV)
aDadosPRV := {}
RETURN .T.

               
*-------------------------*
STATIC FUNCTION CALC_BACK()
*-------------------------*
Local nRecOld := EEQ->(Recno()), nIndOld := EEQ->(INDEXORD())
Local nRecECA := ECA->(Recno()), nIndECA := ECA->(INDEXORD())
Local cPreemb:=EEQ->EEQ_PREEMB, cCliImp  := ""
Local dDtRec:=ctod(""),nVlRRec:=0,nVlMRec:=0,lTemRecTot:=.T.,lTemPgtTot:=.T.,cNRInvo:=''
Local aDadosPRV := {} // Nick 21/09/06 - Pois estava duplicando os lançamentos anteriores

   ECA->(DBSETORDER(6))          
   lTemECA:=ECA->(DBSEEK(xFilial("ECA")+"EXPORT"+"130"))
   ECA->(DBSETORDER(nIndECA))
   ECA->(DBGOTO(nRecECA))
   
   If EEQ->EEQ_PGT >= dDta_Ini .And. EEQ->EEQ_PGT <= dDta_Fim
      EEQ->(DBSETORDER(1))          
      EEQ->(DBSEEK(xFilial("EEQ")+cPreemb))
      Do While ! EEQ->(EOF()) .And. xFilial("EEQ") = EEQ->EEQ_FILIAL
         If EEQ->EEQ_EVENT = '101'
            If !Empty(EEQ->EEQ_PGT)
               dDtRec   := EEQ->EEQ_PGT
               nVlRRec  += EEQ->EEQ_EQVL
               nVlMRec  += EEQ->EEQ_VL
               cNRInvo  := EEQ->EEQ_NRINVO
               cCliImp  := EEQ->EEQ_IMPORT
            Else
               lTemRecTot:=.F.
               Exit
            EndIf
         ElseIf EEQ->EEQ_EVENT = '129'
            If Empty(EEQ->EEQ_PGT)
               lTemPgtTot:=.F.                     
               Exit
            EndIf
         EndIf
         EEQ->(DBSKIP())
      EndDo
      EEQ->(DBSETORDER(nIndOld))
      EEQ->(DBGOTO(nRecOld))

      Do Case
	     Case EEQ->EEQ_EVENT = '101' // VI 01/07/05
//            AAdd(aDadosPRV,{EEQ->EEQ_VL*nTxEmbarq,'128', "", EEQ->EEQ_NRINVO, '128', dDta_Fim, EEQ->EEQ_MOEDA,nTxEmbarq,nTxFimMes, EEQ->EEQ_PARC, "", 'EXP', EEQ->EEQ_PREEMB, "", "", "", "", "", "", EEQ->EEQ_DTVC, 0, 0,EEQ->EEQ_VL,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ}) VI 22/08/05
              AAdd(aDadosPRV,{EEQ->EEQ_EQVL,'128', "", EEQ->EEQ_NRINVO, '128', dDta_Fim, EEQ->EEQ_MOEDA,EEQ->EEQ_TX,EEQ->EEQ_TX, EEQ->EEQ_PARC, "", 'EXP', EEQ->EEQ_PREEMB, "", "", "", "", "", "", EEQ->EEQ_DTVC, 0, 0,EEQ->EEQ_VL,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})

         Case EEQ->EEQ_EVENT = '129'  // VI 01/07/05
//            AAdd(aDadosPRV,{EEQ->EEQ_VL*nTxEmbarq,'129', "", EEQ->EEQ_NRINVO, '129', dDta_Fim, EEQ->EEQ_MOEDA,nTxEmbarq,nTxFimMes,EEQ->EEQ_PARC, "", 'EXP', EEQ->EEQ_PREEMB, "", "", "", "", "", "", EEQ->EEQ_DTVC, 0, 0,EEQ->EEQ_VL,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ})
	          AAdd(aDadosPRV,{EEQ->EEQ_EQVL,'129', "", EEQ->EEQ_NRINVO, '129', dDta_Fim, EEQ->EEQ_MOEDA,EEQ->EEQ_TX,EEQ->EEQ_TX,EEQ->EEQ_PARC, "", 'EXP', EEQ->EEQ_PREEMB, "", "", "", "", "", "", EEQ->EEQ_DTVC, 0, 0,EEQ->EEQ_VL,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
      EndCase                                                                 
      IF lTemRecTot .And. lTemPgtTot .And. ! lTemECA
         AAdd(aDadosPRV,{nVlRRec,'130', "", cNRInvo, '130', dDta_Fim, EEQ->EEQ_MOEDA,0,0,EEQ->EEQ_PARC, "", 'EXP', EEQ->EEQ_PREEMB, "", "", "", "", "", "", EEQ->EEQ_PGT, 0, 0,nVlMRec,cCliImp,'1',"","",cFilEEQ,""})
      ENDIF
   
      PExp999_PrvRat(aDadosPRV)
   EndIf   
//ENDIF	
RETURN .T.                                  


*---------------------------------------*
STATIC FUNCTION CALC_COMISS(TIPO,nValor)
*---------------------------------------*
Local nTxEmbarq2, nTxNF2, nTxFimMes2, nTxIniMes2, nTxMesAnt2, cMoeda2, cTX_1012, dDta_Fim2
IF nValor = 0
   nValor := EEQ->EEQ_VL
ENDIF   

ECG->(DbSeek(cFilECG+cTPMODU+'EX'+EEQ->EEQ_PREEMB))
cMoeda2 := EEQ->EEQ_MOEDA
EC6->(DbSeek(cFilEC6+"EXPORT"))
cTX_1012 := EC6->EC6_TXCV // Para saber se deve usar a taxa de compra ou venda (1 - 2)
	
//Taxas
nTxNF2     := EEM->EEM_TXTB
nTxFimMes2 := ECOEXP999Tx(cMoeda2, dDta_Fim, cTX_1012 ) // (Moeda, data, Compra(1) ou venda(2))
nTxIniMes2 := ECOEXP999Tx(cMoeda2, dDta_Ini, cTX_1012 )
nTxEmbarq2 := ECOEXP999Tx(EEQ->EEQ_MOEDA, EEC->EEC_DTEMBA, cTX_1012)  // Deve-se pegar o EEQ_VCT pois as datas de pagamento para as comissoes podem ser totalmante diferentes da forma de pagamento escolhido no EEC
nVariacao := 0
dDta_Fim2 := dDta_Fim                                              

If EEC->EEC_MOEDA = EEQ->EEQ_MOEDA
   If !Empty(ECG->ECG_ULT_TX)
      nTxMesAnt2 := ECG->ECG_ULT_TX
    Else
      nTxMesAnt2 := nTxIniMes2
   EndIf                        
   IF EEC->EEC_DTEMBA >= dDta_Ini .and. EEC->EEC_DTEMBA <= dDta_Fim
      nTxMesAnt2 := nTxEmbarq2
   ENDIF                      
Else
   nTxMesAnt2 := ECOEXP999Tx(cMoeda2, dDta_Ini-1, cTX_1012 )
EndIf

// VI 27/07/05 lTem608 := If(EC6->(DbSeek(cFilEC6+"EXPORT"+"608"+"")) .and. EC6->EC6_CONTAB = "1",.T.,.F.)
	IF !EMPTY(EEQ->EEQ_PGT) // CASO TENHA LIQUIDADO
// 	IF EEQ->EEQ_EVENT = "121" //.AND. lTem608 VI 27/07/05
//	      AAdd(aDadosPRV, {nValor*EEQ->EEQ_TX, "608","", EEQ->EEQ_NRINVO, "608", EEQ->EEQ_VCT, EEQ->EEQ_MOEDA, EEQ->EEQ_TX, nTxFimMes2, EEQ->EEQ_PARC, "", 'EXP', EEQ->EEQ_PREEMB, "", "", "", "", "", "", EEQ->EEQ_DTVC, 0, 0,nValor,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ})
//	   ELSE
  	      AAdd(aDadosPRV, {nValor*EEQ->EEQ_TX, IF(EEQ->EEQ_EVENT = '120','612',IF(EEQ->EEQ_EVENT = '121','613','614')),"", EEQ->EEQ_NRINVO, IF(EEQ->EEQ_EVENT = '120','612',IF(EEQ->EEQ_EVENT = '121','613','614')), EEQ->EEQ_PGT, EEQ->EEQ_MOEDA, EEQ->EEQ_TX, nTxFimMes2, EEQ->EEQ_PARC, "", 'EXP', EEQ->EEQ_PREEMB, "", "", "", "", "", "", EEQ->EEQ_DTVC, 0, 0,nValor,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_CODEMP,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""}) // MJA 10/10/05 EEQ_CODEMP 
//	   ENDIF     	      
    ELSE // SEM LIQUIDACAO
      AAdd(aDadosPRV, {nValor*nTxEmbarq2, EEQ->EEQ_EVENT, "", EEQ->EEQ_NRINVO, EEQ->EEQ_EVENT,IF(EEC->EEC_DTEMBA >= dDta_Ini .and. EEC->EEC_DTEMBA <= dDta_Fim,EEC->EEC_DTEMBA,dDta_Fim), EEQ->EEQ_MOEDA, nTxEmbarq2, nTxFimMes2, EEQ->EEQ_PARC, "", 'EXP', EEQ->EEQ_PREEMB, "", "", "", "", "", "", EEC->EEC_DTEMBA, 0, 0,nValor,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_CODEMP,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
  	ENDIF
//   IF !(EEQ->EEQ_EVENT = "121" .AND. lTem608)  // VI 26/07/05
      if !Empty(EEQ->EEQ_PGT)
	      nVariacao := (nValor * EEQ->EEQ_TX) - (nValor * nTxMesAnt2)
         nTxUtil := EEQ->EEQ_TX
         dDta_Fim2 := EEQ->EEQ_PGT
      elseif Empty(EEQ->EEQ_PGT) // Encerre o mes e nao possua pagamento
	      nVariacao := (nValor * nTxFimMes2) - (nValor * nTxMesAnt2)
	      nTxUtil := nTxFimMes2
      endif   
//	endif	   
	If nVariacao <> 0 
	   DO CASE
	      CASE EEQ->EEQ_EVENT = '120' // Comissão A Remeter após o Embarque
	           AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, '574', '575'), "", EEQ->EEQ_PREEMB, If(nVariacao > 0, '574', '575'), dDta_Fim2, EEQ->EEQ_MOEDA, nTxUtil, nTxMesAnt2, EEQ->EEQ_PARC, "", 'EXP', EEQ->EEQ_PREEMB, "", "", "", "", "", "", EEQ->EEQ_DTVC, 0, 0,nValor,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_CODEMP,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
	      CASE EEQ->EEQ_EVENT = '121' // Comissão Conta Gráfica após o Embarque
	           AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, '576', '577'), "", EEQ->EEQ_PREEMB, If(nVariacao > 0, '576', '577'), dDta_Fim2, EEQ->EEQ_MOEDA, nTxUtil, nTxMesAnt2, EEQ->EEQ_PARC, "", 'EXP', EEQ->EEQ_PREEMB, "", "", "", "", "", "", EEQ->EEQ_DTVC, 0, 0,nValor,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_CODEMP,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
	      OTHERWISE                   // Comissão A Deduzir da Fatura após o Embarque
	           AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, '578', '579'), "", EEQ->EEQ_PREEMB, If(nVariacao > 0, '578', '579'), dDta_Fim2, EEQ->EEQ_MOEDA, nTxUtil, nTxMesAnt2, EEQ->EEQ_PARC, "", 'EXP', EEQ->EEQ_PREEMB, "", "", "", "", "", "", EEQ->EEQ_DTVC, 0, 0,nValor,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_CODEMP,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})
	   ENDCASE        
	Endif	

PExp999_PrvRat(aDadosPRV)
aDadosPRV := {}
//ENDIF	
RETURN .T.                                  



// Funcao para calcular as comissoes das Notas Fiscais      
*************************************************************************************************************************************************
STATIC FUNCTION COMISS_NF(aCom123,a123SemRat,aCom124,a124SemRat,aCom125,a125SemRat,nTxFimMes,nTxEmbarq,dDta_Fim,dDta_Ini,dDta_FimAux,dDataEmbAux)
*************************************************************************************************************************************************
Local i

// Comissão a Remeter
if Len(aCom123) > 0
   If lTemRat123 .or. lTemRatVCR
      For i:=1 to Len(aCom123)
          // Tx da NF
          nTxNF := aCom123[i,6]
          // Evento de Comissao a Remeter
          If lTemRat123 .and. aCom123[i,7] >= dDta_Ini .and. aCom123[i,7] <= dDta_Fim 
             //                     1         2     3       4          5         6              7           8       9       10      11         12         13          14  15  16  17  18      19             20      21 22       23          24       25
             AAdd(aDadosPRV, {aCom123[i,4], '123', "", aCom123[i,1], '123', aCom123[i,7], EEC->EEC_MOEDA, nTxNF, nTxFimMes, "", aCom123[i,5], 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aCom123[i,2], aCom123[i,7], 0, 0,aCom123[i,3],aCom123[i,10],"2","","",cFilEEM,""})
          EndIf
          // V.Cambial da Comissao a Remeter
          If lTemRatVCR
             If Empty(dDataEmbAux)
                nTaxaAux:= nTxFimMes
             Else
                nTaxaAux:= nTxEmbarq
             EndIf                                                    
             nVariacao := IF(!EMPTY(aCom123[i,3]), aCom123[i,3] * nTaxaAux - aCom123[i,4],(aCom123[i,4] / nTxNF) * nTaxaAux - (aCom123[i,4] / nTxNF) * aCom123[i,4])
//           If nVariacao <> 0  //     1                     2               3       4                       5                      6               7         8         9    10    11         12         13          14  15  16  17  18       19            20         21           22        23
                AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, '534', '535'), "", aCom123[i,1], If(nVariacao > 0, '534', '535'), dDta_FimAux, EEC->EEC_MOEDA, nTxFimMes, nTxNF, "",aCom123[i,5], 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aCom123[i,2], aCom123[i,7], aCom123[i,3], 0,aCom123[i,3],aCom123[i,10],"2","","",cFilEEM,""} )
//           Endif
          EndIf
      Next              
   endif                      
   If !lTemRat123 .or. !lTemRatVCR
      For i:=1 to Len(a123SemRat)
          // Tx da NF
          nTxNF := a123SemRat[i,6] 
          // Evento de Comissao a Remeter
          If !lTemRat123 .and. a123SemRat[i,7] >= dDta_Ini .and. a123SemRat[i,7] <= dDta_Fim
             AAdd(aDadosPRV, {a123SemRat[i,4], '123', "", a123SemRat[i,1], '123', a123SemRat[i,7], EEC->EEC_MOEDA, nTxNF, nTxFimMes, "", "", 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", a123SemRat[i,2], a123SemRat[i,7], 0, 0,a123SemRat[i,3],a123SemRat[i,10],"2","","",cFilEEM,""})
          EndIf

          // V.Cambial da Comissao a Remeter
          If !lTemRatVCR
             If Empty(dDataEmbAux)
                nTaxaAux:= nTxFimMes
             Else
                nTaxaAux:= nTxEmbarq
             EndIf
             nVariacao := IF(!EMPTY(a123SemRat[i,3]), a123SemRat[i,3] * nTaxaAux - a123SemRat[i,4],(a123SemRat[i,4] / nTxNF) * nTaxaAux - (a123SemRat[i,4] / nTxNF) * a123SemRat[i,4])
//             If nVariacao <> 0
                AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, '534', '535'), "", a123SemRat[i,1], If(nVariacao > 0, '534', '535'), dDta_FimAux, EEC->EEC_MOEDA, nTxFimMes, nTxNF, "","", 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", a123SemRat[i,2], a123SemRat[i,7], a123SemRat[i,3], 0,a123SemRat[i,3],a123SemRat[i,10],"2","","",cFilEEM,""})
//             Endif
          EndIf
      Next              
   endif                 
endif
   
// Comissão Conta Grafica
if Len(aCom124) > 0
   If lTemRat124 .or. lTemRatVCG
      For i:=1 to Len(aCom124)
          // Tx da NF
          nTxNF := aCom124[i,6]
          // Evento de Comissao Conta Grafica
          If lTemRat124 .and. aCom124[i,7] >= dDta_Ini .and. aCom124[i,7] <= dDta_Fim 
             //                     1         2     3       4          5         6              7           8       9       10      11         12         13          14  15  16  17  18      19             20      21 22       23
             AAdd(aDadosPRV, {aCom124[i,4], '124', "", aCom124[i,1], '124', aCom124[i,7], EEC->EEC_MOEDA, nTxNF, nTxFimMes, "", aCom124[i,5], 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aCom124[i,2], aCom124[i,7], 0, 0,aCom124[i,3],aCom124[i,10],"2","","",cFilEEM,""})
          EndIf

          // V.Cambial da Comissao Conta Grafica
          If lTemRatVCG
             If Empty(dDataEmbAux)
                nTaxaAux:= nTxFimMes
             Else
                nTaxaAux:= nTxEmbarq
             EndIf                                                    
             nVariacao := IF(!EMPTY(aCom124[i,3]), aCom124[i,3] * nTaxaAux - aCom124[i,4],(aCom124[i,4] / nTxNF) * nTaxaAux - (aCom124[i,4] / nTxNF) * aCom124[i,4])
//             If nVariacao <> 0  //     1                     2               3       4                       5                      6               7         8         9    10    11         12         13          14  15  16  17  18       19            20         21           22        23
                AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, '536', '537'), "", aCom124[i,1], If(nVariacao > 0, '536', '537'), dDta_FimAux, EEC->EEC_MOEDA, nTxFimMes, nTxNF, "",aCom124[i,5], 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aCom124[i,2], aCom124[i,7], aCom124[i,3], 0,aCom124[i,3],aCom124[i,10],"2","","",cFilEEM,""})
//             Endif
          EndIf
      Next              
   endif                      
   If !lTemRat124 .or. !lTemRatVCG
      For i:=1 to Len(a124SemRat)
          // Tx da NF
          nTxNF := a124SemRat[i,6] 
          // Evento de Comissao Conta Grafica
          If !lTemRat124 .and. a124SemRat[i,7] >= dDta_Ini .and. a124SemRat[i,7] <= dDta_Fim
             AAdd(aDadosPRV, {a124SemRat[i,4], '124', "", a124SemRat[i,1], '124', a124SemRat[i,7], EEC->EEC_MOEDA, nTxNF, nTxFimMes, "", "", 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", a124SemRat[i,2], a124SemRat[i,7], 0, 0,a124SemRat[i,3],a124SemRat[i,10],"2","","",cFilEEM,""})
          EndIf
          // V.Cambial da Comissao Conta Grafica
          If !lTemRatVCG
             If Empty(dDataEmbAux)
                nTaxaAux:= nTxFimMes
             Else
                nTaxaAux:= nTxEmbarq
             EndIf
             nVariacao := IF(!EMPTY(a124SemRat[i,3]), a124SemRat[i,3] * nTaxaAux - a124SemRat[i,4],(a124SemRat[i,4] / nTxNF) * nTaxaAux - (a124SemRat[i,4] / nTxNF) * a124SemRat[i,4])
//             If nVariacao <> 0
                AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, '536', '537'), "", a124SemRat[i,1], If(nVariacao > 0, '536', '537'), dDta_FimAux, EEC->EEC_MOEDA, nTxFimMes, nTxNF, "","", 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", a124SemRat[i,2], a124SemRat[i,7], a124SemRat[i,3], 0,a124SemRat[i,3],a124SemRat[i,10],"2","","",cFilEEM,""})
//             Endif
          EndIf
      Next              
   endif                 
endif
   
// Comissão Deduzir da Fatura
if Len(aCom125) > 0
   If lTemRat125 .or. lTemRatVCD
      For i:=1 to Len(aCom125)
          // Tx da NF
          nTxNF := aCom125[i,6]
          // Evento de Comissao Deduzir da Fatura
          If lTemRat125 .and. aCom125[i,7] >= dDta_Ini .and. aCom125[i,7] <= dDta_Fim 
             //                     1         2     3       4          5         6              7           8       9       10      11         12         13          14  15  16  17  18      19             20      21 22       23
             AAdd(aDadosPRV, {aCom125[i,4], '125', "", aCom125[i,1], '125', aCom125[i,7], EEC->EEC_MOEDA, nTxNF, nTxFimMes, "", aCom125[i,5], 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aCom125[i,2], aCom125[i,7], 0, 0,aCom125[i,3],aCom125[i,10],"2","","",cFilEEM,""})
          EndIf

          // V.Cambial da Comissao Deduzir da Fatura
          If lTemRatVCD
             If Empty(dDataEmbAux)
                nTaxaAux:= nTxFimMes
             Else
                nTaxaAux:= nTxEmbarq
             EndIf                                                    
             nVariacao := IF(!EMPTY(aCom125[i,3]), aCom125[i,3] * nTaxaAux - aCom125[i,4],(aCom125[i,4] / nTxNF) * nTaxaAux - (aCom125[i,4] / nTxNF) * aCom125[i,4])
//             If nVariacao <> 0  //     1                     2               3       4                       5                      6               7         8         9    10    11         12         13          14  15  16  17  18       19            20         21           22        23
                AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, '538', '539'), "", aCom125[i,1], If(nVariacao > 0, '538', '539'), dDta_FimAux, EEC->EEC_MOEDA, nTxFimMes, nTxNF, "",aCom125[i,5], 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", aCom125[i,2], aCom125[i,7], aCom125[i,3], 0,aCom125[i,3],aCom125[i,10],"2","","",cFilEEM,""} )
//             Endif
          EndIf
      Next              
   endif                      
   If !lTemRat125 .or. !lTemRatVCD
      For i:=1 to Len(a125SemRat)
          // Tx da NF
          nTxNF := a125SemRat[i,6] 
          // Evento de Comissao Deduzir da Fatura
          If !lTemRat125 .and. a125SemRat[i,7] >= dDta_Ini .and. a125SemRat[i,7] <= dDta_Fim
             AAdd(aDadosPRV, {a125SemRat[i,4], '125', "", a125SemRat[i,1], '125', a125SemRat[i,7], EEC->EEC_MOEDA, nTxNF, nTxFimMes, "", "", 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", a125SemRat[i,2], a125SemRat[i,7], 0, 0,a125SemRat[i,3],a125SemRat[i,10],"2","","",cFilEEM,""})
          EndIf

          // V.Cambial da Comissao Deduzir da Fatura
          If !lTemRatVCD
             If Empty(dDataEmbAux)
                nTaxaAux:= nTxFimMes
             Else
                nTaxaAux:= nTxEmbarq
             EndIf
             nVariacao := IF(!EMPTY(a125SemRat[i,3]), a125SemRat[i,3] * nTaxaAux - a125SemRat[i,4],(a125SemRat[i,4] / nTxNF) * nTaxaAux - (a125SemRat[i,4] / nTxNF) * a125SemRat[i,4])
//             If nVariacao <> 0
                AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, '538', '539'), "", a125SemRat[i,1], If(nVariacao > 0, '538', '539'), dDta_FimAux, EEC->EEC_MOEDA, nTxFimMes, nTxNF, "","", 'EXP', EEC->EEC_PREEMB, "", "", "", "", "", a125SemRat[i,2], a125SemRat[i,7], a125SemRat[i,3], 0,a125SemRat[i,3],a125SemRat[i,10],"2","","",cFilEEM,""})
//             Endif
          EndIf
      Next              
   endif                 
endif    
RETURN .T.       
         
******************************
STatic Function ChangeFilial()
******************************         

cFilEF1  := xFilial("EF1")
cFilEF2  := xFilial("EF2")
cFilEF3  := xFilial("EF3")
cFilSYS  := xFilial("SYS")
cFilEC1  := xFilial("EC1")
cFilECA  := xFilial("ECA")
cFilSA2  := xFilial("SA2")
cFilEC6  := xFilial("EC6")
cFilSYE  := xFilial("SYE")
cFilEEC  := xFilial("EEC")
cFilECC  := xFilial("ECC")
cFilEE9  := xFilial("EE9")
cFilSA6  := xFilial("SA6")
cFilEEQ  := xFilial("EEQ")
cFilECF  := xFilial("ECF")
cFilECE  := xFilial("ECE")
cFilEET  := xFilial("EET")
cFilECG  := xFilial("ECG")
cFilEEM  := xFilial("EEM")
cFilEES  := xFilial("EES")
cFilSA1  := xFilial("SA1")
cFilEE7  := xFilial("EE7")
cFilECI  := xFilial("ECI")
cFilEXL  := xFilial("EXL")
cFilSY5  := xFilial("SY5")

Return .T.
 

***************************************
FUNCTION CLI_TIP(cAlias,cInvoice,cQual)
***************************************
Local nRecOld, nIndOld
Local cFor

nRecOld := EEQ->(Recno())
nIndOld := EEQ->(INDEXORD())
DO CASE
   CASE cAlias = "EF3"
        EEQ->(DBSETORDER(5))
        EEQ->(DBSEEK(cFilEEQ+cInvoice+'101'))
        cFor := IF(EEQ->EEQ_TIPO = 'R',EEQ->EEQ_IMPORT,EEQ->EEQ_FORN)
        cTip := IF(EEQ->EEQ_TIPO=='P','2','1')
ENDCASE
EEQ->(DBSETORDER(nIndOld))
EEQ->(DBGOTO(nRecOld))

RETURN(if(cQual='1',cFor,cTip))


****************************************************************************
FUNCTION ZERACON(cProcesso,cParcela,cTaxa,nValor,dDta_Fim,nTxEmb,nTxMesAnt,nVarReal,cFase) // 01/08/05
****************************************************************************
Local nTot582,nTot583,nVl502, cTXFimMes, lSoma, cMesF, cAnoF, dDtaFIM
Local nVCAtualAux:=(cTaxa * nValor) - (nValor * If(EEC->EEC_DTEMBA >= dDta_Ini .And. EEC->EEC_DTEMBA <= dDta_Fim,nTxEmb,nTxMesAnt))

IF Empty(EEQ->EEQ_NR_CON) .OR. EEQ->EEQ_NR_CON = STRZERO(nNR_Cont+1,4,0) // para verificar dt embarque dentro do mes com data anterior.
   nVCAtualAux:=(cTaxa * nValor) - (nValor * nTxEmb)
EndIf

nTot582 := 0
nTot583 := 0
nVl502  := 0

EC6->(DbSeek(cFilEC6+If(lTemEC6New,"EXPORT","")+'101')) 
cTX_101 := EC6->EC6_TXCV

nRecOld := ECF->(Recno())
nIndOld := ECF->(INDEXORD())
ECF->(DBSETORDER(9))                              

If nVCAtualAux > 0
   nTot582 := nVCAtualAux
Else
   nTot583 := nVCAtualAux
EndIf

ECF->(DBSEEK(cFilECF+"EXPORT"+"EX"+cProcesso))
DO WHILE ECF->(!EOF()) .And. ECF->ECF_FILIAL = cFilECF .And. cProcesso = ECF->ECF_PREEMB
   lSoma:=.F.

   If ECF->ECF_ID_CAM $ '582/583' // Para verificar se o evento de v.c. é do fim do mês para casos de liquidações
                                  // parciais.

      cMesF    := Str(Month(ECF->ECF_DTCONT)+1,2,0)
      cAnoF    := Str(Year(ECF->ECF_DTCONT),4,0)
      IF cMesF = "13"
         cMesF := "01"
         cAnoF := STRZERO(VAL(cAnoF)+1,4,0)
      Endif
      dDtaFIM := AVCTOD("01/"+cMesF+"/"+Right(cAnoF,2)) - 1

      cTXFimMes := ECOEXP999Tx(ECF->ECF_MOEDA, dDtaFIM, cTX_101 )                                  
      If cTXFimMes = ECF->ECF_PARIDA .And. dDtaFIM = ECF->ECF_DTCONT
         lSoma:=.T.
      EndIf
   EndIf
   IF ECF->ECF_NR_CON # STRZERO(nNR_Cont+1,4,0) .And. lSoma
      DO CASE 
         CASE ECF->ECF_ID_CAM = '582' //.and. ECF->ECF_SEQ = cParcela .And. ECF->ECF_FASE = cFase
              nTot582 += (nValor * ECF->ECF_PARIDA) - (nValor * ECF->ECF_FLUTUA)
         CASE ECF->ECF_ID_CAM = '583' //.and. ECF->ECF_SEQ = cParcela .And. ECF->ECF_FASE = cFase
              nTot583 += (nValor * ECF->ECF_PARIDA) - (nValor * ECF->ECF_FLUTUA)
      ENDCASE
   EndIf
   ECF->(DBSKIP())
ENDDO  

If nTot582 > Abs(nTot583) 
   nVl502 := nTot582
Else
   nVl502 := nTot583   
EndIf

/* VI 20/08/05
nVl502 := nTot582+nTot583   

If (nTot582 = 0 .And. nVarReal < 0) .And. (nVarReal - nVl502) < 0
   nVl502 += nVarReal - nVl502     
ElseIf (nTot582 = 0 .And. nVarReal > 0) .And. (nVl502 - nVarReal) < 0
   nVl502 := nVl502 - nVarReal 
ElseIf (nTot583 = 0 .And. nVarReal > 0 ) .And. (nVarReal - nVl502) > 0
   nVl502 += nVarReal - nVl502     
ElseIf (nTot583 = 0 .And. nVarReal < 0 ) .And. (nVl502 - nVarReal) > 0
   nVl502 := nVl502 - nVarReal 
EndIf*/

AAdd(aDadosPRV, {Abs(nVl502), '502', "", EEQ->EEQ_NRINVO, '502', dDta_Fim, EEQ->EEQ_MOEDA, nTxEmb, nTxMesAnt, EEQ->EEQ_PARC, If(cTipo='EMB',"",cCustoPad), 'EMB', EEQ->EEQ_PREEMB, EEQ->EEQ_FASE, If(lPagAnt, EEQ->EEQ_TIPO,""), "", "", "", "", dDta_Fim, Abs(nVl502),0,0,IF(EEQ->EEQ_TIPO='P',EEQ->EEQ_FORN,EEQ->EEQ_IMPORT),IF(EEQ->EEQ_TIPO=='P','2','1'),"","",cFilEEQ,""})

ECF->(DBSETORDER(nIndOld))
ECF->(DBGOTO(nRecOld))

RETURN .T.

Static function PF999CalcCom(dDta_IniAux,dDta_FimAux,lTemEmbPer,nTxFimMes,nTxEmb,cMoeda,cParcela,cProcesso,cFase)

Local i         
            
         // V.C do Comissao CG dos meses anteriores apos Embarque
         If ECF->ECF_ID_CAM $ '121' .And. (ECF->ECF_DTCONT < dDta_IniAux .Or. ECF->ECF_DTCONT > dDta_FimAux)
            nVlECF := ECF->ECF_VL_MOE
            cMesAntAux := ECF->ECF_PARIDA
            cInvAux    := ECF->ECF_INVEXP
            cIdentAux  := ECF->ECF_IDENTC
            cNrNfAux   := ECF->ECF_NRNF
            
            nRec := EEQ->(Recno())
            nInd := EEQ->(INDEXORD())            
            EEQ->(DBSETORDER(1)) // No Lê pagamentos deve-se tratar pagamentos parciais.
            EEQ->(DBSEEK(cFilEEQ+ECF->ECF_PREEMB+AvKey(ECF->ECF_SEQ, "EEQ_PARC")))//RMD - 05/07/13
            IF (ECF->ECF_VL_MOE # EEQ->EEQ_VL .AND. (EEQ->EEQ_PGT < dDta_IniAux .OR. EEQ->EEQ_PGT > dDta_FimAux)) .OR. EMPTY(EEQ->EEQ_PGT)
               DO WHILE EEQ->(!EOF()) .AND. EEQ->EEQ_FILIAL = cFilEEQ .AND. ECF->ECF_PREEMB = EEQ->EEQ_PREEMB
                  IF !EMPTY(EEQ->EEQ_PGT) .AND. ECF->ECF_ID_CAM = EEQ->EEQ_EVENT
                     nVlECF -= EEQ->EEQ_VL
                     EEQ->(DBSKIP())
                  ENDIF
                  EEQ->(DBSKIP())
               ENDDO
               c121Pree := ECF->ECF_PREEMB; c121Fase := ECF->ECF_FASE  ; c121Inve := ECF->ECF_INVEXP
               c121Seq  := ECF->ECF_SEQ   ; c121NrCo := ECF->ECF_NR_CON; c121NrNf := ECF->ECF_NRNF
               c121Forn := ECF->ECF_FORN  ; c121TpFo := ECF->ECF_TP_FOR               
               nRecOld  := ECF->(RECNO())
               
               ECF->(DBSEEK(cFilECF+'EXPORT'+'EX'+c121Pree+c121Fase+c121Inve+c121Seq+'576'))
               DO WHILE ECF->(!EOF()) .AND. ECF->ECF_ID_CAM = '576' .AND. cFilECF = ECF->ECF_FILIAL
                  IF ECF->ECF_NRNF = c121NrNf .And. nNrUltCont = ECF->ECF_NR_CON               
                     AAdd(aVcAnt, {ECF->ECF_INVEXP,ECF->ECF_NRNF,nVlECF,ECF->ECF_IDENTC})
                     cMesAntAux := ECF->ECF_PARIDA
                  ENDIF
                  ECF->(DBSKIP())
               ENDDO                
               ECF->(DBSEEK(cFilECF+'EXPORT'+'EX'+c121Pree+c121Fase+c121Inve+c121Seq+'577'))
               DO WHILE ECF->(!EOF()) .AND. ECF->ECF_ID_CAM = '577' .AND. cFilECF = ECF->ECF_FILIAL
                  IF ECF->ECF_NRNF = c121NrNf .And. nNrUltCont = ECF->ECF_NR_CON               
                     AAdd(aVcAnt, {ECF->ECF_INVEXP,ECF->ECF_NRNF,nVlECF,ECF->ECF_IDENTC})
                     cMesAntAux := ECF->ECF_PARIDA
                  ENDIF
                  ECF->(DBSKIP())
               ENDDO                
               
               If Len(aVcAnt) > 0
                  FOR i:=1 TO Len(aVcAnt)
                      IF aVcAnt[i,3] >= 0
                         nVariacao := (aVcAnt[i,3] * If(!lTemEmbPer,nTxFimMes,nTxEmb)) - (aVcAnt[i,3] * cMesAntAux)
                         If nVariacao <> 0
                            AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, "576", "577"), "", aVcAnt[i,1], If(nVariacao > 0, "576", "577"), dDta_FimAux, cMoeda, If(!lTemEmbPer,nTxFimMes,nTxEmb), cMesAntAux, cParcela, aVcAnt[i,4], 'VC', cProcesso, cFase, "", "", "", "", aVcAnt[i,2], dDta_FimAux, aVcAnt[i,3], 0,nVlECF,c121Forn,c121TpFo,"","",cFilECF,""})
                         EndIf
      		             Endif
      			   Next i
               Else
                  //** AAF 27/03/2009 - Tem comissao contabilizada mas não tem variação cambial pos embarque contabilizada. (vaziacao zerada não é gerada)
                  nVariacao := (nVlECF * If(!lTemEmbPer,nTxFimMes,nTxEmb)) - (nVlECF * cMesAntAux)
                  If nVariacao <> 0
                     AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, "576", "577"), "", cInvAux, If(nVariacao > 0, "576", "577"), dDta_FimAux, cMoeda, If(!lTemEmbPer,nTxFimMes,nTxEmb), cMesAntAux, cParcela, cIdentAux, 'VC', cProcesso, cFase, "", "", "", "", cNrNfAux, dDta_FimAux, nVlECF, 0,nVlECF,c121Forn,c121TpFo,"","",cFilECF,""})
                  EndIf
                  //**
			   EndIf
   			   
			      ECF->(DBGOTO(nRecOld))
			   ENDIF
            EEQ->(DBSETORDER(nInd))
            EEQ->(DBGOTO(nRec))			   
         Endif                        
                  
         // V.C do Comissao Remeter dos meses anteriores apos Embarque
         If ECF->ECF_ID_CAM $ '120' .And. (ECF->ECF_DTCONT < dDta_IniAux .Or. ECF->ECF_DTCONT > dDta_FimAux)
            nVlECF := ECF->ECF_VL_MOE
            cMesAntAux := ECF->ECF_PARIDA
            cInvAux    := ECF->ECF_INVEXP
            cIdentAux  := ECF->ECF_IDENTC
            cNrNfAux   := ECF->ECF_NRNF
            
            nRec := EEQ->(Recno())
            nInd := EEQ->(INDEXORD())            
            EEQ->(DBSETORDER(1)) // No Lê pagamentos deve-se tratar pagamentos parciais.
            EEQ->(DBSEEK(cFilEEQ+ECF->ECF_PREEMB+AvKey(ECF->ECF_SEQ, "EEQ_PARC")))//RMD - 05/07/13
            IF (ECF->ECF_VL_MOE # EEQ->EEQ_VL .AND. (EEQ->EEQ_PGT < dDta_IniAux .OR. EEQ->EEQ_PGT > dDta_FimAux)) .OR. EMPTY(EEQ->EEQ_PGT)
               DO WHILE EEQ->(!EOF()) .AND. EEQ->EEQ_FILIAL = cFilEEQ .AND. ECF->ECF_PREEMB = EEQ->EEQ_PREEMB
                  IF !EMPTY(EEQ->EEQ_PGT) .AND. ECF->ECF_ID_CAM = EEQ->EEQ_EVENT
                     nVlECF -= EEQ->EEQ_VL
                     EEQ->(DBSKIP())
                  ENDIF
                  EEQ->(DBSKIP())
               ENDDO
               c120Pree := ECF->ECF_PREEMB; c120Fase := ECF->ECF_FASE  ; c120Inve := ECF->ECF_INVEXP
               c120Seq  := ECF->ECF_SEQ   ; c120NrCo := ECF->ECF_NR_CON; c120NrNf := ECF->ECF_NRNF
               c120Forn := ECF->ECF_FORN  ; c120TpFo := ECF->ECF_TP_FOR               
               nRecOld  := ECF->(RECNO())
               
               ECF->(DBSEEK(cFilECF+'EXPORT'+'EX'+c120Pree+c120Fase+c120Inve+c120Seq+'574'))
               DO WHILE ECF->(!EOF()) .AND. ECF->ECF_ID_CAM = '574' .AND. cFilECF = ECF->ECF_FILIAL
                  IF ECF->ECF_NRNF = c120NrNf .And. nNrUltCont = ECF->ECF_NR_CON               
                     AAdd(aVcAnt, {ECF->ECF_INVEXP,ECF->ECF_NRNF,nVlECF,ECF->ECF_IDENTC})
                     cMesAntAux := ECF->ECF_PARIDA
                  ENDIF
                  ECF->(DBSKIP())
               ENDDO                
               ECF->(DBSEEK(cFilECF+'EXPORT'+'EX'+c120Pree+c120Fase+c120Inve+c120Seq+'575'))
               DO WHILE ECF->(!EOF()) .AND. ECF->ECF_ID_CAM = '575' .AND. cFilECF = ECF->ECF_FILIAL
                  IF ECF->ECF_NRNF = c120NrNf .And. nNrUltCont = ECF->ECF_NR_CON               
                     AAdd(aVcAnt, {ECF->ECF_INVEXP,ECF->ECF_NRNF,nVlECF,ECF->ECF_IDENTC})
                     cMesAntAux := ECF->ECF_PARIDA
                  ENDIF
                  ECF->(DBSKIP())
               ENDDO                
               If Len(aVcAnt) > 0
                  FOR i:=1 TO Len(aVcAnt)
                      IF aVcAnt[i,3] >= 0
                         nVariacao := (aVcAnt[i,3] * If(!lTemEmbPer,nTxFimMes,nTxEmb)) - (aVcAnt[i,3] * cMesAntAux)
                         If nVariacao <> 0
                            AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, "574", "575"), "", aVcAnt[i,1], If(nVariacao > 0, "574", "575"), dDta_FimAux, cMoeda, If(!lTemEmbPer,nTxFimMes,nTxEmb), cMesAntAux, cParcela, aVcAnt[i,4], 'VC', cProcesso, cFase, "", "", "", "", aVcAnt[i,2], dDta_FimAux, aVcAnt[i,3], 0,nVlECF,c120Forn,c120TpFo,"","",cFilECF,""})
                         EndIf
		              Endif
      			  Next i
               Else
                  //** AAF 27/03/2009 - Tem comissao contabilizada mas não tem variação cambial pos embarque contabilizada. (vaziacao zerada não é gerada)
                  nVariacao := (nVlECF * If(!lTemEmbPer,nTxFimMes,nTxEmb)) - (nVlECF * cMesAntAux)
                  If nVariacao <> 0
                     AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, "574", "575"), "", cInvAux, If(nVariacao > 0, "574", "575"), dDta_FimAux, cMoeda, If(!lTemEmbPer,nTxFimMes,nTxEmb), cMesAntAux, cParcela, cIdentAux, 'VC', cProcesso, cFase, "", "", "", "", cNrNfAux, dDta_FimAux, nVlECF, 0,nVlECF,c120Forn,c120TpFo,"","",cFilECF,""})
                  EndIf
                  //**
			   EndIf
			   
			      ECF->(DBGOTO(nRecOld))
			   ENDIF
            EEQ->(DBSETORDER(nInd))
            EEQ->(DBGOTO(nRec))			   
         Endif     
         
         // V.C da Comissao a Deduzir da Fatura dos meses anteriores / Foi alterado esta rotina pois não trazia as contas e C.C. das VC anteriores
            If ECF->ECF_ID_CAM $ '125' .And. (ECF->ECF_DTCONT < dDta_IniAux .Or. ECF->ECF_DTCONT > dDta_FimAux) .AND. (EMPTY(EEC->EEC_DTEMBA) .OR. lTemEmbPer)
               cMesAntAux := ECF->ECF_PARIDA
               nVlECF     := ECF->ECF_VL_MOE
               cInvAux    := ECF->ECF_INVEXP
               cIdentAux  := ECF->ECF_IDENTC
               cNrNfAux   := ECF->ECF_NRNF            
               
               c125Pree := ECF->ECF_PREEMB
               c125Fase := ECF->ECF_FASE
               c125Inve := ECF->ECF_INVEXP
               c125Seq  := ECF->ECF_SEQ
               c125NrCo := ECF->ECF_NR_CON
               c125NrNf := ECF->ECF_NRNF
               c125Forn := ECF->ECF_FORN
               c125TpFo := ECF->ECF_TP_FOR
               nRecOld  := ECF->(RECNO())

               ECF->(DBSEEK(cFilECF+'EXPORT'+'EX'+c125Pree+c125Fase+c125Inve+c125Seq+'538'))
               DO WHILE ECF->(!EOF()) .AND. ECF->ECF_ID_CAM = '538' .And. cFilECF = ECF->ECF_FILIAL
                  IF ECF->ECF_NRNF = c125NrNf .And. nNrUltCont = ECF->ECF_NR_CON
                     AAdd(aVcAnt, {ECF->ECF_INVEXP,ECF->ECF_NRNF,ECF->ECF_VL_MOE,ECF->ECF_IDENTC})
                     cMesAntAux := ECF->ECF_PARIDA
                  ENDIF
                  ECF->(DBSKIP())
               ENDDO
               ECF->(DBSEEK(cFilECF+'EXPORT'+'EX'+c125Pree+c125Fase+c125Inve+c125Seq+'539'))
               DO WHILE ECF->(!EOF()) .AND. ECF->ECF_ID_CAM = '539' .And. cFilECF = ECF->ECF_FILIAL
                  IF ECF->ECF_NRNF = c125NrNf .And. nNrUltCont = ECF->ECF_NR_CON
                     AAdd(aVcAnt, {ECF->ECF_INVEXP,ECF->ECF_NRNF,ECF->ECF_VL_MOE,ECF->ECF_IDENTC})
                     cMesAntAux := ECF->ECF_PARIDA
                  ENDIF
                  ECF->(DBSKIP())
               ENDDO
               
               If Len(aVcAnt) > 0
                   FOR i:=1 TO Len(aVcAnt)
                      IF aVcAnt[i,3] >= 0
                         nVariacao := (aVcAnt[i,3] * If(!lTemEmbPer,nTxFimMes,nTxEmb)) - (aVcAnt[i,3] * cMesAntAux)
                         If nVariacao <> 0
                            AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, "538", "539"), "", aVcAnt[i,1], If(nVariacao > 0, "538", "539"), dDta_FimAux, cMoeda, If(!lTemEmbPer,nTxFimMes,nTxEmb), cMesAntAux, cParcela, aVcAnt[i,4], 'VC', cProcesso, cFase, "", "", "", "", aVcAnt[i,2], dDta_FimAux, aVcAnt[i,3], 0,aVcAnt[i,3],c125Forn,c125TpFo,"","",cFilECF,""})
                         EndIf
      			       Endif
   	    		   Next i
               Else
                  //** AAF 27/03/2009 - Tem comissao contabilizada mas não tem variação cambial pos embarque contabilizada. (vaziacao zerada não é gerada)
                  nVariacao := (nVlECF * If(!lTemEmbPer,nTxFimMes,nTxEmb)) - (nVlECF * cMesAntAux)
                  If nVariacao <> 0
                     AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, "538", "539"), "", cInvAux, If(nVariacao > 0, "538", "539"), dDta_FimAux, cMoeda, If(!lTemEmbPer,nTxFimMes,nTxEmb), cMesAntAux, cParcela, cIdentAux, 'VC', cProcesso, cFase, "", "", "", "", cNrNfAux, dDta_FimAux, nVlECF, 0,nVlECF,c125Forn,c125TpFo,"","",cFilECF,""})
                  EndIf                  
                  //**
			   EndIf			   
			   
			   ECF->(DBGOTO(nRecOld))
            Endif  

            // V.C da Comissao a Remeter dos meses anteriores / Foi alterado esta rotina pois não trazia as contas e C.C. das VC anteriores
            If ECF->ECF_ID_CAM $ '123' .And. (ECF->ECF_DTCONT < dDta_IniAux .Or. ECF->ECF_DTCONT > dDta_FimAux) .AND. (EMPTY(EEC->EEC_DTEMBA) .OR. lTemEmbPer)
               cMesAntAux := ECF->ECF_PARIDA
               nVlECF     := ECF->ECF_VL_MOE
               cInvAux    := ECF->ECF_INVEXP
               cIdentAux  := ECF->ECF_IDENTC
               cNrNfAux   := ECF->ECF_NRNF

               c123Pree := ECF->ECF_PREEMB; c123Fase := ECF->ECF_FASE   ; c123Inve := ECF->ECF_INVEXP
               c123Seq  := ECF->ECF_SEQ   ; c123NrCo := ECF->ECF_NR_CON ; c123NrNf := ECF->ECF_NRNF
               c123Forn := ECF->ECF_FORN  ; c123TpFo := ECF->ECF_TP_FOR
               nRecOld  := ECF->(RECNO())

               ECF->(DBSEEK(cFilECF+'EXPORT'+'EX'+c123Pree+c123Fase+c123Inve+c123Seq+'534'))
               DO WHILE ECF->(!EOF()) .AND. ECF->ECF_ID_CAM = '534' .And. cFilECF = ECF->ECF_FILIAL
                  IF ECF->ECF_NRNF = c123NrNf .And. nNrUltCont = ECF->ECF_NR_CON
                     AAdd(aVcAnt, {ECF->ECF_INVEXP,ECF->ECF_NRNF,ECF->ECF_VL_MOE,ECF->ECF_IDENTC})
                     cMesAntAux := ECF->ECF_PARIDA
                  ENDIF
                  ECF->(DBSKIP())
               ENDDO
               ECF->(DBSEEK(cFilECF+'EXPORT'+'EX'+c123Pree+c123Fase+c123Inve+c123Seq+'535'))
               DO WHILE ECF->(!EOF()) .AND. ECF->ECF_ID_CAM = '535' .And. cFilECF = ECF->ECF_FILIAL
                  IF ECF->ECF_NRNF = c123NrNf .And. nNrUltCont = ECF->ECF_NR_CON
                     AAdd(aVcAnt, {ECF->ECF_INVEXP,ECF->ECF_NRNF,ECF->ECF_VL_MOE,ECF->ECF_IDENTC})
                     cMesAntAux := ECF->ECF_PARIDA
                  ENDIF
                  ECF->(DBSKIP())
               ENDDO
               
               If Len(aVcAnt) > 0
                  FOR i:=1 TO Len(aVcAnt)
                      IF aVcAnt[i,3] >= 0
                         nVariacao := (aVcAnt[i,3] * If(!lTemEmbPer,nTxFimMes,nTxEmb)) - (aVcAnt[i,3] * cMesAntAux)
                         If nVariacao <> 0
                            AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, "534", "535"), "", aVcAnt[i,1], If(nVariacao > 0, "534", "535"), dDta_FimAux, cMoeda, If(!lTemEmbPer,nTxFimMes,nTxEmb), cMesAntAux, cParcela, aVcAnt[i,4], 'VC', cProcesso, cFase, "", "", "", "", aVcAnt[i,2], dDta_FimAux, aVcAnt[i,3], 0,aVcAnt[i,3],c123Forn,c123TpFo,"","",cFilECF,""})
                         EndIf
                      Endif
                  Next i
               Else
                  //** AAF 27/03/2009 - Tem comissao contabilizada mas não tem variação cambial pos embarque contabilizada. (vaziacao zerada não é gerada)
                  nVariacao := (nVlECF * If(!lTemEmbPer,nTxFimMes,nTxEmb)) - (nVlECF * cMesAntAux)
                  If nVariacao <> 0
                     AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, "534", "535"), "", cInvAux, If(nVariacao > 0, "534", "535"), dDta_FimAux, cMoeda, If(!lTemEmbPer,nTxFimMes,nTxEmb), cMesAntAux, cParcela, cIdentAux, 'VC', cProcesso, cFase, "", "", "", "", cNrNfAux, dDta_FimAux, nVlECF, 0,nVlECF,c123Forn,c123TpFo,"","",cFilECF,""})
                  EndIf
                  //**
			   EndIf			   
			   
			   
			      ECF->(DBGOTO(nRecOld))
            Endif  
                                  
            // V.C da Conta Grafica dos meses anteriores / Foi alterado esta rotina pois não trazia as contas e C.C. das VC anteriores
            If ECF->ECF_ID_CAM $ '124' .And. (ECF->ECF_DTCONT < dDta_IniAux .Or. ECF->ECF_DTCONT > dDta_FimAux) .AND. (EMPTY(EEC->EEC_DTEMBA) .OR. lTemEmbPer)  // MJA 22/09/05 Foi acrescentado o bloqueio da data do embarque
               cMesAntAux := ECF->ECF_PARIDA
               nVlECF     := ECF->ECF_VL_MOE
               cInvAux    := ECF->ECF_INVEXP
               cIdentAux  := ECF->ECF_IDENTC
               cNrNfAux   := ECF->ECF_NRNF

               c124Pree := ECF->ECF_PREEMB ; c124Fase := ECF->ECF_FASE  ; c124Inve := ECF->ECF_INVEXP
               c124Seq  := ECF->ECF_SEQ    ; c124NrCo := ECF->ECF_NR_CON; c124NrNf := ECF->ECF_NRNF
               c124Forn := ECF->ECF_FORN   ; c124TpFo := ECF->ECF_TP_FOR
               nRecOld  := ECF->(RECNO())

               ECF->(DBSEEK(cFilECF+'EXPORT'+'EX'+c124Pree+c124Fase+c124Inve+c124Seq+'536'))
               DO WHILE ECF->(!EOF()) .AND. ECF->ECF_ID_CAM = '536' .And. cFilECF = ECF->ECF_FILIAL
                  IF ECF->ECF_NRNF = c124NrNf .And. nNrUltCont = ECF->ECF_NR_CON
                     AAdd(aVcAnt, {ECF->ECF_INVEXP,ECF->ECF_NRNF,ECF->ECF_VL_MOE,ECF->ECF_IDENTC})
                     cMesAntAux := ECF->ECF_PARIDA
                  ENDIF
                  ECF->(DBSKIP())
               ENDDO
               ECF->(DBSEEK(cFilECF+'EXPORT'+'EX'+c124Pree+c124Fase+c124Inve+c124Seq+'537'))
               DO WHILE ECF->(!EOF()) .AND. ECF->ECF_ID_CAM = '537' .And. cFilECF = ECF->ECF_FILIAL
                  IF ECF->ECF_NRNF = c124NrNf .And. nNrUltCont = ECF->ECF_NR_CON
                     AAdd(aVcAnt, {ECF->ECF_INVEXP,ECF->ECF_NRNF,ECF->ECF_VL_MOE,ECF->ECF_IDENTC})
                     cMesAntAux := ECF->ECF_PARIDA
                  ENDIF
                  ECF->(DBSKIP())
               ENDDO
               
               If Len(aVcAnt) > 0
                   FOR i:=1 TO Len(aVcAnt)
                      IF aVcAnt[i,3] >= 0
                         nVariacao := (aVcAnt[i,3] * If(!lTemEmbPer,nTxFimMes,nTxEmb)) - (aVcAnt[i,3] * cMesAntAux)
                         If nVariacao <> 0
                            AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, "536", "537"), "", aVcAnt[i,1], If(nVariacao > 0, "536", "537"), dDta_FimAux, cMoeda, If(!lTemEmbPer,nTxFimMes,nTxEmb), cMesAntAux, cParcela, aVcAnt[i,4], 'VC', cProcesso, cFase, "", "", "", "", aVcAnt[i,2], dDta_FimAux, aVcAnt[i,3], 0,aVcAnt[i,3],c124Forn,c124TpFo,"","",cFilECF,""})
                         EndIf
	    		       Endif
    			   Next i
               Else
                  //** AAF 27/03/2009 - Tem comissao contabilizada mas não tem variação cambial pos embarque contabilizada. (vaziacao zerada não é gerada)
                  nVariacao := (nVlECF * If(!lTemEmbPer,nTxFimMes,nTxEmb)) - (nVlECF * cMesAntAux)
                  If nVariacao <> 0
                     AAdd(aDadosPRV, {nVariacao, If(nVariacao > 0, "536", "537"), "", cInvAux, If(nVariacao > 0, "536", "537"), dDta_FimAux, cMoeda, If(!lTemEmbPer,nTxFimMes,nTxEmb), cMesAntAux, cParcela, cIdentAux, 'VC', cProcesso, cFase, "", "", "", "", cNrNfAux, dDta_FimAux, nVlECF, 0,nVlECF,c124Forn,c124TpFo,"","",cFilECF,""})
                  EndIf
                  //**
			   EndIf

			   ECF->(DBGOTO(nRecOld))
            Endif                        
                                                                                      
Return .t.         

//** AAF 27/04/07
//Processar os estornos das contabilizações anteriores.
//Grava arquivo ECE no arquivo ECA
*************************
Static Function ProcEst()
*************************
Local nContador := 1

If lExisteECE

   oProcess:IncRegua1(STR0096+"4 / "+cTotProc+" "+"Lendo Processos Estornados") //"Lendo Processos Estornados"
   oProcess:SetRegua2(nTotECE)

   cArea := Alias()      
   nIndexAnt := ECE->(IndexOrd())
   
   ECE->(dbSetOrder(3))
   ECE->(dbSeek(cFilECE+'EXPORT'))
   do while ECE->(!eof()) .And. ECE->ECE_FILIAL == cFilECE .And. ECE->ECE_TPMODU == 'EXPORT' .And. Val(ECE->ECE_NR_CON) == 0
   
      oProcess:IncRegua2(AllTrim(Str(nContador))+" / "+AllTrim(Str(nTotECE))+" "+STR0032+Alltrim(ECE->ECE_PREEMB))
   		    
      //           Valor          Evento           Contrato     Invoice         Link          Data            Moeda           Tx.Moeda        Tx.Moeda Ant.   Seq.         Identc          Tipo Fiancia.                Fase   Tipo  ProcOr PFaseOr PParcOr PNF PDtEntrada PVlOrVC PRecno PVLMOE         PCliFor       PTipoCli
      PF999_GrvPRV(ECE->ECE_VALOR,ECE->ECE_ID_CAM,             ,ECE->ECE_INVOIC,ECE->ECE_LINK,ECE->ECE_DT_EST,ECE->ECE_MOE_FO,ECE->ECE_TX_ANT,ECE->ECE_TX_ATU,ECE->ECE_SEQ,ECE->ECE_IDENTC,'EX'        ,ECE->ECE_PREEMB,OC_EM,      ,      ,       ,       ,   ,          ,       ,      ,ECE->ECE_VALOR,ECE->ECE_FORN,        )	   
               
      if cPrv_Efe = "2"      // Efetivacao      
         Reclock('ECE',.F.)
         ECE->ECE_NR_CON := STRZERO(nNR_Cont+1,4,0)
         ECE->(MSUNLOCK()) 
         /*
         ECF->(Reclock('ECF',.F.))
         ECF->ECF_CTA_DB := ALLTRIM(ECE->ECE_CDBEST)   // Conta de estorno correspondente ao evento
         ECF->ECF_CTA_CR := ALLTRIM(ECE->ECE_CCREST)   
         ECF->(MsUnlock())
         */    
      endif
      
      nContador++
      
      ECE->(DbSkip())
   enddo
   // Ordem anterior
   ECE->(dbSetOrder(nIndexAnt))
   if !Empty(cArea)
      dbSelectArea(cArea)
   endif
EndIf

Return .T.