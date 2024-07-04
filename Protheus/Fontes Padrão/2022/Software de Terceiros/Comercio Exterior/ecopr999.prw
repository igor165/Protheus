#INCLUDE "Ecopr999.ch"
#include "AVERAGE.CH"
#include "AvPrint.ch"  
#INCLUDE "AP5MAIL.CH"

//Atenção: Neste fonte o comand psay executa a rotina AvSay!!!
#Command @ <lin>,<coluna> psay <conteudo>  => AvSay(<lin>,<coluna>, <conteudo>)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ECOPR999 ³ Autor ³ VICTOR IOTTI          ³ Data ³ 21.12.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Previa da Integracao contabil.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

*-----------------*
Function ECOPR991(aParametros)
*-----------------*
// ** AAF 17/12/07 - Tratamento para execução da prévia por agendamento
Local lScheduled := aParametros <> NIL

If lScheduled
   AvPreAmb(aParametros)
   ConOut("["+DToC(Date()) + " " + Time()+"] "+"Gerando Previa Contabil de Importacao - Easy Accounting")
EndIf
// **

ECOPR999("1",lScheduled)
Return .T.

*----------------*
Function ECOPR992(aParametros)
*----------------*
// ** AAF 17/12/07 - Tratamento para execução da efetivação por agendamento
Local lScheduled := aParametros <> NIL

If lScheduled
   AvPreAmb(aParametros)
   ConOut("["+DToC(Date()) + " " + Time()+"] "+"Gerando Efetivação Contabil de Importacao - Easy Accounting")
EndIf
// **

ECOPR999("2",lScheduled)
Return .T.

*--------------------------*
Function ECOPR999(cQualProg,pAgendado)
*--------------------------*
#DEFINE  COM_FINANCEIRA  "1"
#DEFINE  SEM_FINANCEIRA  "2"
#DEFINE  TIPO_DO_MODULO  "IMPORT"

LOCAL   aDBF_Stru := {{"WKEMPRESA","C",4 ,0} ,{"WKFIRMA"  ,"C",3 ,0},;
                      {"WKREGIST" ,"C",2 ,0} ,{"WKSEQ"    ,"C",2 ,0},;
                      {"WKDATA"   ,"C",6 ,0} ,{"WKARQ"    ,"C",7 ,0},;
                      {"WKLANC"   ,"C",4 ,0} ,{"WKCON_DEV","C",16,0},;
                      {"WKSUB_DEV","C",11,0} ,{"WKCC_DEV" ,"C",11,0},;
                      {"WKCON_CRE","C",16,0} ,{"WKSUB_CRE","C",11,0},;
                      {"WKCC_CRE" ,"C",11,0} ,{"WKVALOR"  ,"C",15,0},;
                      {"WKDTCONT" ,"C",6 ,0} ,{"WKHIST"   ,"C",3 ,0},;
                      {"WKCOMPL"  ,"C",20,0} ,{"WKFILL01" ,"C",2 ,0}}

LOCAL cMesSAY,cDataSAY,cMes,cAno

// ** AAF 17/12/07 - Tratamento para execução da prévia por agendamento
Default pAgendado  := .F.
Private lScheduled := pAgendado
Private aMessages  := {}
// **

Private nGeralDB := nGeralCR := 0
Private aTotContas:={}

Private dData_Con,dDta_Inic,dDta_Fim,cCod_Lote,lContinua:=.T.,lGeraTxt:=.F.,cHora,nTaxa

Private cFilEC2:=xFilial("EC2"),cFilEC4:=xFilial("EC4"),cFilEC5:=xFilial("EC5"),cFilEC6:=xFilial("EC6")
Private cFilEC8:=xFilial("EC8"),cFilEC9:=xFilial("EC9"),cFilECA:=xFilial("ECA"),cFilSA2:=xFilial("SA2")
Private cFilEC3:=xFilial("EC3"),cFilEC7:=xFilial("EC7"),cFilECE:=xFilial("ECE"),cFilEC1:=xFilial("EC1")
Private cFilSW6:=xFilial("SW6"),cFilECC:=xFilial("ECC"),lTipoCont:=1
Private nSubSetor, nTam:=90, lVCReal := GetNewPar("MV_VCREAL",.F.)
Private nVlr_Cal:= 0, aTaxas := {}

PRIVATE aTabMsg:={}, B_aTabMsg:={|conteudo| ER_f_say(conteudo)}, lFirst, cTit, lPR300:=.F., nContReg:=0, nContReg1:=0

PRIVATE lMuda_Dt := .F. // VI

PRIVATE l3M := GetNewPar("MV_3M_CT",.F.), lGeraRel := .T.

Private cPrv_Efe:=cQualProg, nTamHawb:=LEN(EC2->EC2_HAWB),nTamIdentc:=LEN(EC2->EC2_IDENTC),nTamInvoic:=LEN(EC5->EC5_INVOIC),nTamForn:=LEN(EC2->EC2_FORN),;
        nTamMoeda := LEN(EC2->EC2_MOEDA)

Private nTot1:=0, nTot2:=0, nTot3:=0, nTot4:=0, nTot5:=0, nTot6 := 0, nTot7 := 0, nTot8 := 0

Private lExisteECE := .F., lExisteECF := .F., lExisteECG := .F.

// Verifica a existencia da rotina de Estorno
lExisteECE := EasyGParam("MV_ESTORNO", .F., .F.)

// Verifica se existe o arquivo de pagamento antecipado ECF/ECG
lExisteECF := EasyGParam("MV_PAGANT", .F., .F.)
If lExisteECF 
   cFilECF    := xFilial('ECF')
   lExisteECG := .T.
   cFilECG    := xFilial('ECG')
Endif

If ! EasyEntryPoint("ECO_CTB")
   AvE_Msg(STR0001,1) //"N„o foi encontrado o RDMAKE para gerar o TXT."
   Return .F.
EndIf


cNomArq := E_CriaTrab(, aDBF_Stru, "Work")
IF ! USED()
   AvE_Msg(STR0002,20) //"N„o ha area disponivel para abertura do arquivo temporario."
   RETURN .F.
ENDIF

IndRegua("Work",cNomArq+TEOrdBagExt(),"WKDATA+WKLANC")
PRIVATE aTab_Inv[999],aTab_HAWB[999],aTabVlr_I[999],aTabVlr_H[999],aVlr_Ind[999]
Private cMesProc := AllTrim(EasyGParam("MV_MESPROC"))
Private nNR_Cont := EasyGParam("MV_NR_CONT")
Private lTop     := .F.

#IFDEF TOP                                      
  IF (TcSrvType() != "AS/400")   // Considerar qdo for AS/400 para que tenha o tratamento de Codbase
     lTop := .T.
  Endif
#ENDIF 

cHora := TIME()

cMesSAY  :=SUBSTR(cMesProc,1,2)+"/"+SUBSTR(cMesProc,3,4)
cDataSAY :=DTOC(dDataBase)

cMes = STRZERO(VAL(SUBSTR(cMesProc,1,2))+1,2,0)
cAno = SUBSTR(cMesProc,3,4)
IF cMes = "13"
   cMes = "01"
   cAno = STRZERO(VAL(cAno)+1,4,0)
ENDIF

dData_Con = AVCTOD("01/"+cMes+"/"+cAno) - 1
dDta_Inic = AVCTOD("01/"+SUBSTR(cMesProc,1,2)+"/"+SUBSTR(cMesProc,3,4))
dDta_Fim  = dData_Con

&& LAB 03.03.00

nVlr_reais:=nPag_Ctb_M:=nVC_aposDI:=nPag_Abe_M:=nPag_Abe_R:=n201_Abe_R:=nVC_prov:=0   && LAB 24.07.00
nSdo_Ant_M := 0
lProcessa  := .F.
dData_Ctb  := dData_Con
dDt_UltOc  := dData_Con
lGera_503  := .F.
l201_Cont  := .T.
lTem_DI    := .F.     
IF cPrv_Efe = "1"
   cTit:=STR0004 //"Pr‚via da integra‡„o contabil"
   cPerg:=STR0005 //"Confirma pr‚via da integra‡„o ?"
   nLinDialog:=23 //20 - FSM - 11/10/2012
Else
   cTit:=STR0006 //"Efetiva‡„o da contabiliza‡„o"
   cPerg:=STR0007 //"Confirma efetiva‡„o da contabiliza‡„o ?"
   nLinDialog:=25
EndIF

If !lScheduled
   // GFP - 10/11/2011 - Ajuste de tamanho de tela para que botão não seja exibido cortado.
   DEFINE MSDIALOG oDlg TITLE cTit From 9,0 To nLinDialog,50/*45*/ OF GetWndDefault()
      nColS  :=2.0
      nColG  :=10.5
   
      If cPrv_Efe = "1"
         nLin   :=3.5//2.0
         @ nLin++,nColS SAY STR0008 //"Mˆs em Processamento"
         @ nLin++,nColS SAY STR0009 //"Data da Integra‡„o"
         @ nLin++,nColS SAY STR0010 //"Contabilizar com Data"
         @ nLin++,nColS SAY STR0011 //"Contabilizar com Hora"
      Else
         nLin   :=3.0//1.5
         @ nLin++,nColS SAY STR0008 //"Mˆs em Processamento"
         @ nLin++,nColS SAY STR0012 //"No. da Contabiliza‡„o"
         @ nLin++,nColS SAY STR0013 //"Data da Contabiliza‡„o"
         @ nLin++,nColS SAY STR0014 //"Hora da Contabiliza‡„o"
         @ nLin++,nColS SAY STR0010 //"Contabilizar com Data"
         @ nLin++,nColS SAY STR0015 //"C¢digo do Lote"
      EndIf
   
      If cPrv_Efe = "1"
         nLin:=3.5//2.0
         cCod_Lote := SPACE(006)
         @ nLin++,nColG MSGET cMesSAY   When .F. SIZE 35,08 OF oDlg
         @ nLin++,nColG MSGET cDataSAY  When .F. SIZE 35,08 OF oDlg
         @ nLin++,nColG MSGET dData_Con          SIZE /*35*/42,08 OF oDlg  // GFP - 21/11/2011
         @ nLin++,nColG MSGET cHora     When .F. SIZE 35,08 OF oDlg
      Else
         nLin:=3.0//1.5
         cCod_Lote := "IMP" + STRZERO(nNR_Cont+1,3,0)
         cNR_Say   := STR(nNR_Cont+1,4,0)
         @ nLin++,nColG MSGET cMesSAY   When .F. SIZE 35,08 OF oDlg
         @ nLin++,nColG MSGET cNR_Say   When .F. SIZE 35,08 OF oDlg
         @ nLin++,nColG MSGET cDataSAY  When .F. SIZE 35,08 OF oDlg
         @ nLin++,nColG MSGET cHora     When .F. SIZE 35,08 OF oDlg
         @ nLin++,nColG MSGET dData_Con          SIZE /*35 */42,08 OF oDlg  // GFP - 21/11/2011
         @ nLin++,nColG MSGET cCod_Lote PICTURE "@!" SIZE 35,08 OF oDlg
      EndIf

      nOpca:=0
   ACTIVATE MSDIALOG oDlg ON INIT ;
            EnchoiceBar(oDlg,{||IF(PR999Val(1),(nOpca:=1,oDlg:End()),)},;
                             {||nOpca:=0,oDlg:End()}) CENTERED
Else //Schedulado
   IF PR999Val(1)
      nOpca:=1
   EndIf
EndIf

If nOpca # 0    

   lContinua:=.T.
   lGeraTxt:=.F.

   // Verifica se ultima efetivação teve algum problema
   EC1->(DbSetOrder(2))
   If EC1->(DbSeek(cFilEC1+"IMPORT"+STRZERO(nNR_Cont,4,0)))
      If EC1->EC1_OK = '2' .And. EC1->EC1_STATUS # 'E'
         Help("", 1, "AVG0005364",,StrZero(nNR_Cont,4,0) + STR0062,2,30)// LRL 08/01/04 MsgInfo(STR0113 + StrZero(nNR_Cont,4,0) + STR0062) //"Houve problema(s) com a ultima contabilizacao (No. "###").
                                                                         //Por favor, estorne esta contabilizacao para prosseguir."
         lContinua := .F.
      Endif
   Endif
   EC1->(DbSetOrder(1))   
   
   If lContinua   
      AvProcessa({||PR999ProcInv()},STR0016) //"Atualizando Arq. de Invoices."
   Endif    
   
   If lContinua .AND. (lScheduled .OR. SimNao(cPerg,STR0017,,,,STR0017)=='S') //"Questao ?" ### "Questao ?"    
                      
      AvProcessa({||PR999Proc()},STR0018) //"Pesquisando Processos."      
      
      If EasyEntryPoint("ECOPR999")                       
         ExecBlock("ECOPR999",.F.,.F.,"FIMCALCULOS")   
      EndIf
                                                  
      if lGeraRel                                            
         AvProcessa({||ER_PR999IMP()},STR0019) //"Gerando Arq. de Impressao."
      Else
         If EasyEntryPoint("ECOPR999")                       
            ExecBlock("ECOPR999",.F.,.F.,"RELATORIO")   
         EndIf   
      EndIf
      
      IF cPrv_Efe == "2" .AND. lGeraTxt
         AvProcessa({||PR999TXT()},STR0020) //"Gerando Arq. de Integra‡„o Contabil."
      EndIf         
   Endif   
EndIf

Work->(E_EraseArq(cNomArq))
EC1->(DBSETORDER(1))
EC2->(DBSETORDER(1))
EC3->(DBSETORDER(1))
EC4->(DBSETORDER(1))
EC5->(DBSETORDER(1))
EC6->(DBSETORDER(1))
EC7->(DBSETORDER(1))
EC8->(DBSETORDER(1))
EC9->(DBSETORDER(1))
ECA->(DBSETORDER(1))
ECB->(DBSETORDER(1))
ECC->(DBSETORDER(1))

Return .T.

*----------------------*
Function PR999ProcInv()
*----------------------*
LOCAL nCont:=1,lProc_Inv:=.T., nRecnoECE := 0
EC5->(DBSETORDER(3))
EC4->(DBSETORDER(2))
EC7->(DBSETORDER(3))
EC9->(DBSETORDER(3))

// Rotina p/ contagem de registros
AvPAguarde({||PRContaReg(1)},STR0067)   //"Aguarde... Apurando Dados"
ProcRegua(nTot1)
Pr999Men(STR0068)    //"Lendo Historico da DI"

EC3->(DBSETORDER(1))
EC3->(DBSEEK(cFilEC3+'    '))
DO WHILE ! EC3->(EOF()) .AND. EMPTY(ALLTRIM(EC3->EC3_NR_CON)) .AND. EC3->EC3_FILIAL=cFilEC3
   
   IncProc(STR0072+EC3->EC3_DI_NUM) //"DI: "

   EC3->(DBSKIP())
   MRecno:= EC3->(RECNO())
   EC3->(DBSKIP(-1))
   Reclock('EC3',.F.)
   EC3->EC3_NR_CON := '0000'
   EC3->(MSUNLOCK())
   EC3->(DBGOTO(MRecno))
ENDDO

ProcRegua(nTot2)
Pr999Men(STR0073)  //"Lendo Detalhes da DI"

EC4->(DBSETORDER(2))
EC4->(DBSEEK(cFilEC4+'    '))
DO WHILE ! EC4->(EOF()) .AND. EMPTY(ALLTRIM(EC4->EC4_NR_CON)) .AND. EC4->EC4_FILIAL=cFilEC4
   
   IncProc(STR0075+EC4->EC4_HAWB) //"Processo: "
   
   EC4->(DBSKIP())
   MRecno:= EC4->(RECNO())
   EC4->(DBSKIP(-1))
   Reclock('EC4',.F.)
   EC4->EC4_NR_CON := '0000'
   EC4->(MSUNLOCK())
   EC4->(DBGOTO(MRecno))
ENDDO

EC4->(DBSEEK(cFilEC4+STRZERO(nNR_Cont+1,4,0)))  
DO WHILE ! EC4->(EOF()) .AND. EC4->EC4_NR_CON = STRZERO(nNR_Cont+1,4,0) .AND. EC4->EC4_FILIAL=cFilEC4
   
   IncProc(STR0075+EC4->EC4_HAWB) //"Processo: "
   
   EC4->(DBSKIP())
   MRecno:= EC4->(RECNO())
   EC4->(DBSKIP(-1))
   Reclock('EC4',.F.)
   EC4->EC4_NR_CON := '0000'
   EC4->(MSUNLOCK())
   EC4->(DBGOTO(MRecno))
ENDDO
EC4->(DBSETORDER(1))

ProcRegua(nTot3)
Pr999Men(STR0076)  //"Lendo Invoices (Contabilidade)"

EC5->(DBSEEK(cFilEC5+'    '))
DO WHILE ! EC5->(EOF()) .AND. EMPTY(ALLTRIM(EC5->EC5_NR_CON)) .AND. EC5->EC5_FILIAL=cFilEC5
   
   IncProc(STR0079+EC5->EC5_INVOIC) //"Invoice: "
      
   EC5->(DBSKIP())
   MRecno:= EC5->(RECNO())
   EC5->(DBSKIP(-1))
   Reclock('EC5',.F.)
   EC5->EC5_NR_CON := '0000'
   EC5->(MSUNLOCK())
   EC5->(DBGOTO(MRecno))
ENDDO

ProcRegua(nTot4)
Pr999Men(STR0080) //"Lendo Movimentacao da Conta"

EC7->(DBSETORDER(3))
EC7->(DBSEEK(cFilEC7+'    '))
DO WHILE ! EC7->(EOF()) .AND. EMPTY(ALLTRIM(EC7->EC7_NR_CON)) .AND. EC7->EC7_FILIAL=cFilEC7
			
   IncProc(STR0075+EC7->EC7_HAWB) //"Processo: "
	
   EC7->(DBSKIP())
   MRecno:= EC7->(RECNO())
   EC7->(DBSKIP(-1))
   Reclock('EC7',.F.)
   EC7->EC7_NR_CON := '0000'
   EC7->(MSUNLOCK())
   EC7->(DBGOTO(MRecno))
ENDDO
EC7->(DBSETORDER(1))

ProcRegua(nTot5)
Pr999Men(STR0083) //"Lendo Eventos da Invoice"

EC9->(DBSETORDER(3))
EC9->(DBSEEK(cFilEC9+'    '))
DO WHILE ! EC9->(EOF()) .AND. EMPTY(ALLTRIM(EC9->EC9_NR_CON)) .AND. EC9->EC9_FILIAL=cFilEC9
   
   IncProc(STR0079+EC9->EC9_INVOIC) //"Invoice: "
   
   EC9->(DBSKIP())
   MRecno:= EC9->(RECNO())
   EC9->(DBSKIP(-1))
   Reclock('EC9',.F.)
   EC9->EC9_NR_CON := '0000'
   EC9->(MSUNLOCK())
   EC9->(DBGOTO(MRecno))
ENDDO

ProcRegua(nTot6)    
Pr999Men(STR0076) //"Lendo Invoices (Contabilidade)"

EC9->(DBSETORDER(1))
EC5->(DBSEEK(cFilEC5))
DO WHILE ! EC5->(EOF()) .AND. VAL(EC5->EC5_NR_CON) = 0 .AND. EC5->EC5_FILIAL==cFilEC5
          
	 IncProc(STR0079+EC5->EC5_INVOIC) //"Invoice: "
			

   IF EC5->EC5_CD_PGT = "1" .AND. EC5->EC5_AMOS $ cNao
      IF ! EC9->(DBSEEK(cFilEC9+EC5->EC5_FORN+EC5->EC5_INVOIC+EC5_IDENTC+"602"))
         Reclock('EC5',.F.)
         EC5->EC5_CD_PGT := "2"  && Liberar a contabilizacao
         EC5->(MSUNLOCK())
      ENDIF
   ENDIF
   EC5->(DBSKIP())
ENDDO

ProcRegua(nTot7)
Pr999Men(STR0076)   //"Lendo Invoices (Contabilidade)"

EC9->(DBSETORDER(2))
EC5->(DBSEEK(cFilEC5+'9999'))
DO WHILE ! EC5->(EOF()) .AND. VAL(EC5->EC5_NR_CON)=9999 .AND. EC5->EC5_FILIAL==cFilEC5
          
   IncProc(STR0079+EC5->EC5_INVOIC) //"Invoice: "
      
   IF EC5->EC5_CD_PGT="1" .AND. EC5->EC5_AMOS $ cNao
      IF ! EC9->(DBSEEK(cFilEC9+EC5->EC5_FORN+EC5->EC5_INVOIC+EC5_IDENTC+"602"))
         IF EMPTY(ALLTRIM(EC5->EC5_VCFANO+EC5->EC5_VCFMES))   // EDS 19/12/2001
            AvE_Msg(STR0022+ALLTRIM(EC5->EC5_INVOIC)+STR0023,1) //"Invoice a vista "###" n„o possue pagamento - VERIFICAR"
            AADD(aTabMsg,STR0022+ALLTRIM(EC5->EC5_INVOIC)+STR0023) //"Invoice a vista "###" n„o possue pagamento - VERIFICAR"
         ENDIF   
         lProc_Inv = .F.
      ENDIF
   ENDIF
   EC5->(DBSKIP())
ENDDO

IF ! lProc_Inv
   AvE_Msg(STR0024,1) //"Aten‡„o existem invoices a vista sem pagamento - Processamento n„o efetuado."
   IF cPrv_Efe = "2"
      lContinua:=.F.
   ENDIF
ENDIF
EC5->(DBSETORDER(1))
EC9->(DBSETORDER(1))

Return .T.

*-------------------*
Function PR999Proc()
*-------------------*
LOCAL cInvoice,cIdentct,cFornec,lPrimeiro,nRecnoEC5,nContRegua:=1, nIndexAnt, cForn, cMoeda, I
PRIVATE nDi_NumAtu := Space(10)

// Grava no arquivo EC1 os dados da efetivaçao
If cPrv_Efe = "2"
   Grv999EC1()
   Reclock('EC1',.F.)
   EC1->EC1_OK := "2"
   EC1->(Msunlock())                     
Endif   

PR300Can_VCF(9999)

IF lTop                                      
  IF (TcSrvType() != "AS/400")
     ApagaECA()
  Else      
     AvPAguarde({||PRContaReg(3)},STR0067)   //"Aguarde... Apurando Dados"
     AvProcessa({||ApagaECA()},STR0087) //"Limpando Arquivo da Previa..."
  Endif  
Endif 

IF !lTop                                              
  AvPAguarde({||PRContaReg(3)},STR0067)            //"Aguarde... Apurando Dados"
  AvProcessa({||ApagaECA()},STR0087) //"Limpando Arquivo da Previa..."


ENDIF

************* rotina de apuracao de invoices nao contabilizadas - lanc. 1.01
// Rotina p/ contagem de registros
AvPAguarde({||PRContaReg(2)},STR0067)   //"Aguarde... Apurando Dados"

// Gera Variacoes referente ao adiantemento
If lExisteECF .And. lExisteECG
   GeraAdiant()                           
Endif

ProcRegua(nTot1)    
Pr999Men(STR0076) //"Lendo Invoices (Contabilidade)"

EC5->(DBSETORDER(3))
EC5->(DBSEEK(cFilEC5))
cInvoice := EC5->EC5_INVOIC
cIdentct := EC5->EC5_IDENTC
cFornec := EC5->EC5_FORN

lPrimeiro = .T.
nVlr_reais:=nPag_Ctb_M:=nVC_aposDI:=nPag_Abe_M:=nPag_Abe_R:=n201_Abe_R:=nVC_prov:=0   && LAB 24.07.00
nSdo_Ant_M := 0
lProcessa  := .F.
dData_Ctb  := dData_Con
dDt_UltOc  := dData_Con
dDt_PG := dDt_DI := CTOD('')
nVl_PG := nVl_DI := 0
nTx_PG := 0
lGera_503  := .F.
l201_Cont  := .T.
lTem_DI    := .F.               && nova rotina abaixo
lTem_PG    := .F.
lTem_DI2   := .F.
nInd       := 0
nVCReal    := 0       
nData603   := 0
nEC7DTCONT := 0
nEC9DTCONT := 0
Ind        := 0

DO WHILE .T.
   lRefresh:=.t.

   EC5->(DBSEEK(cFilEC5+'0000'+cFornec+cInvoice+cIdentct,.T.))
			   
   IF VAL(EC5->EC5_NR_CON) # 0 .OR. EC5->(EOF()) .OR. cFilEC5 # EC5->EC5_FILIAL
      EXIT
   ENDIF
   
   nRecnoEC5 = EC5->(RECNO())
   EC5->(DBSKIP())
   IF  VAL(EC5->EC5_NR_CON) # 0 .OR. EC5->(EOF()) .OR. cFilEC5 # EC5->EC5_FILIAL
       IF ! lPrimeiro
          EXIT
       ELSE
          lPrimeiro := .F.
       ENDIF
   ENDIF
                          
   cInvoice := EC5->EC5_INVOIC
   cIdentct := EC5->EC5_IDENTC
   cFornec  := EC5->EC5_FORN


   EC5->(DBSKIP(-1))

   IncProc(STR0079+EC5->EC5_INVOIC) //"Invoice: "

   EC8->(DBSETORDER(2))

   If ! EMPTY(ALLTRIM(EC5->EC5_VCFANO+EC5->EC5_VCFMES))  // VI 06/11/01
      EC5->(DBSETORDER(3))
      EC5->(DBGOTO(nRecnoEC5))
      EC5->(DBSKIP())
      LOOP   
   EndIf

   IF ! EC8->(DBSEEK(cFilEC8+EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC))
      IF EC5->EC5_AMOS $ cSim
         AADD(aTabMsg,STR0025+ ALLTRIM(EC5->EC5_INVOIC)+STR0026) //"Invoice sem Processo - Inv. "###" - AMOSTRA"
      ELSE
         AADD(aTabMsg,STR0025+ EC5->EC5_INVOIC) //"Invoice sem Processo - Inv. "
      ENDIF
      EC5->(DBSETORDER(3))
      EC5->(DBGOTO(nRecnoEC5))
      EC5->(DBSKIP())
      LOOP
   ENDIF

   AFILL(aTab_HAWB,SPACE(37))
   Ind := 0

   lSai := .F.
   nVlr_FOB_H := 0
   DO WHILE ! EC8->(EOF()) .AND. EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC = EC8->EC8_FORN+EC8->EC8_INVOIC+EC8->EC8_IDENTC .AND. EC8->EC8_FILIAL = cFilEC8
      lRefresh:=.t.

      IF ASCAN(aTab_HAWB,EC8->EC8_HAWB+EC8->EC8_FORN+EC8->EC8_MOEDA+EC8->EC8_IDENTC) = 0
         Ind = Ind + 1
         aTab_HAWB[Ind] = EC8->EC8_HAWB+EC8->EC8_FORN+EC8->EC8_MOEDA+EC8->EC8_IDENTC
         EC2->(DBSEEK(cFilEC2+EC8->EC8_HAWB+EC8->EC8_FORN+EC8->EC8_MOEDA+EC8->EC8_IDENTC))
         nVlr_FOB_H += EC2->EC2_FOB_DI
         EC4->(DBSETORDER(1))
         EC4->(DBSEEK(cFilEC4+EC8->EC8_HAWB+EC8->EC8_FORN+EC8->EC8_MOEDA+EC8->EC8_IDENTC+"201"))
         IF VAL(EC4->EC4_NR_CON) # 0 .AND. ! EC4->(EOF())
            lSai = .T.
         ENDIF
      ENDIF
      EC8->(DBSKIP())
   ENDDO

   IF lSai
      EC5->(DBSETORDER(3))
      EC5->(DBGOTO(nRecnoEC5))
      EC5->(DBSKIP())
      LOOP
   ENDIF

   nInd = 0
   FOR I=1 TO Ind
       EC8->(DBSETORDER(3))
       EC8->(DBSEEK(cFilEC8+aTab_HAWB[I]))

       AFILL(aTab_Inv,SPACE(25))
       nInd = 0
							
       DO WHILE ! EC8->(EOF()) .AND. EC8->EC8_HAWB+EC8->EC8_FORN+EC8->EC8_MOEDA+EC8->EC8_IDENTC=aTab_HAWB[I] .AND. EC8->EC8_FILIAL=cFilEC8
          IF ASCAN(aTab_Inv,EC8->EC8_FORN+EC8->EC8_INVOIC+EC8->EC8_IDENTC) = 0
             nInd = nInd + 1
             aTab_Inv[nInd] = EC8->EC8_FORN+EC8->EC8_INVOIC+EC8->EC8_IDENTC
          ENDIF
          EC8->(DBSKIP())
       ENDDO
   NEXT

   lSai := .F.
   nVlr_Fob_I := 0
   FOR I=1 TO nInd
       EC5->(DBSETORDER(1))
       EC5->(DBSEEK(cFilEC5+aTab_Inv[I]))
       nVlr_Fob_I += EC5->EC5_FOB_TO
       IF VAL(EC5->EC5_NR_CON) # 0
          lSai = .T.
       ENDIF
   NEXT

   IF lSai
      EC5->(DBSETORDER(3))
      EC5->(DBGOTO(nRecnoEC5))
      EC5->(DBSKIP())
      LOOP
   ENDIF

   IF VAL(STR(nVlr_Fob_I,15,2)) # VAL(STR(nVlr_FOB_H,15,2))
      EC5->(DBSETORDER(1))				     	// EDS 18/12/01
      EC5->(DBSEEK(cFilEC5+ALLTRIM(aTab_Inv[1])))										
	  IF EMPTY(ALLTRIM(EC5->EC5_VCFANO+EC5->EC5_VCFMES))  
         AADD(aTabMsg,STR0027+ALLTRIM(aTab_Inv[1])+STR0028+aTab_HAWB[1]) //"FOB na invoice diferente do FOB do processo - Inv. "###" Processo "
      ENDIF          
      EC5->(DBSETORDER(3))
      EC5->(DBGOTO(nRecnoEC5))
      EC5->(DBSKIP())
      LOOP
   ENDIF

   IF Ind = 1
      FOR I=1 TO nInd
          EC2->(DBSEEK(cFilEC2+aTab_HAWB[1]))
          nDi_NumAtu := EC2->EC2_DI_NUM
          EC5->(DBSETORDER(1))
          EC5->(DBSEEK(cFilEC5+aTab_Inv[I]))
          lMuda_Dt := .F.
          //nTaxa = BuscaTxECO(EC5->EC5_MOE_FO,IF("ITAUTEC" $ UPPER(SM0->M0_NOMECOM),PRDataAnt(),PR200VerDT(EC5->EC5_DT_EMI)))  //EC5->EC5_DT_EMI - GFC 04/08/04
          IniVarEmbarque(dData_Con, EC5->EC5_HAWB,EC5->EC5_INVOIC,EC5->EC5_FORN) //FSM - 30/11/2012
          nTaxa := nTxComp
          
          If EasyEntryPoint("ECOPR999")                       
             ExecBlock("ECOPR999",.F.,.F.,"EVENTO_101_1")   
          EndIf

          PR200_GrvPRV(VAL(STR(EC5->EC5_FOB_TO * nTaxa,15,2)),"101",aTab_Inv[I],aTab_HAWB[1],"101",IF("ITAUTEC" $ UPPER(SM0->M0_NOMECOM),EC5->EC5_DT_EMI,PR200VerDT(EC5->EC5_DT_EMI))," ",EC5->EC5_DT_EMI,EC2->EC2_MOEDA,nTaxa)   // - GFC 04/08/04
          
          If l3M .AND. AllTrim(EC5->EC5_IDENTC) $ "7/8"
             PR200_GrvPRV(VAL(STR(EC5->EC5_FOB_TO * nTaxa,15,2)),"351",aTab_Inv[I],aTab_HAWB[1],"351",PR200VerDT(EC5->EC5_DT_EMI)," ",EC5->EC5_DT_EMI,EC2->EC2_MOEDA,nTaxa) && LAB 01.08.01  
          EndIf
          
          PR200_VcfGrv(VAL(STR(EC5->EC5_FOB_TO * nTaxa,15,2)),"101",aTab_Inv[I],aTab_HAWB[1],"101",EC5->EC5_DT_EMI," ")
          
      NEXT
   ELSE
      FOR I=1 TO Ind
          EC2->(DBSEEK(cFilEC2+aTab_HAWB[I]))
          nDi_NumAtu = EC2->EC2_DI_NUM
          EC5->(DBSETORDER(1))
          EC5->(DBSEEK(cFilEC5+aTab_Inv[1]))
          lMuda_Dt = .F.
          //nTaxa = BuscaTxECO(EC5->EC5_MOE_FO,IF("ITAUTEC" $ UPPER(SM0->M0_NOMECOM),PRDataAnt(),PR200VerDT(EC5->EC5_DT_EMI)))  //EC5->EC5_DT_EMI - GFC 04/08/04
          IniVarEmbarque(dData_Con, EC5->EC5_HAWB,EC5->EC5_INVOIC,EC5->EC5_FORN) //FSM - 30/11/2012
          nTaxa := nTxComp
          
          If EasyEntryPoint("ECOPR999")                       
             ExecBlock("ECOPR999",.F.,.F.,"EVENTO_101_2")   
          EndIf

          PR200_GrvPRV(VAL(STR(EC2->EC2_FOB_DI * nTaxa,15,2)),"101",aTab_Inv[1],aTab_HAWB[I],"101",IF("ITAUTEC" $ UPPER(SM0->M0_NOMECOM),EC5->EC5_DT_EMI,PR200VerDT(EC5->EC5_DT_EMI))," ",EC5->EC5_DT_EMI,EC2->EC2_MOEDA,nTaxa) // - GFC 04/08/04
          
          If l3M .AND. AllTrim(EC5->EC5_IDENTC) $ "7/8"
             PR200_GrvPRV(VAL(STR(EC2->EC2_FOB_DI * nTaxa,15,2)),"351",aTab_Inv[1],aTab_HAWB[I],"351",PR200VerDT(EC5->EC5_DT_EMI)," ",EC5->EC5_DT_EMI,EC2->EC2_MOEDA,nTaxa) && LAB 01.08.01  
          EndIf                                                   
                    
          PR200_VcfGrv(VAL(STR(EC2->EC2_FOB_DI * nTaxa,15,2)),"101",aTab_Inv[1],aTab_HAWB[I],"101",EC5->EC5_DT_EMI," ")                    

      NEXT
   ENDIF

   EC5->(DBSETORDER(3))
   EC5->(DBGOTO(nRecnoEC5))

   FOR I=1 TO nInd
       EC5->(DBSETORDER(1))
       EC5->(DBSEEK(cFilEC5+aTab_Inv[I]))
       Reclock('EC5',.F.)
       EC5->EC5_NR_CON := STRZERO(nNR_Cont+1,4,0)
       EC5->(MSUNLOCK())
   NEXT
   EC5->(DBSETORDER(3))
   EC5->(DBGOTO(nRecnoEC5))
   EC5->(DBSKIP())

ENDDO

************* rotina de apuracao de # Fobs Hawb e Invoices - lanc. 2.01 de acerto

ProcRegua(nTot2)
Pr999Men(STR0073) //"Lendo Detalhes da DI"

EC4->(DBSETORDER(2))
EC4->(DBSEEK(cFilEC4+'0000'+"201"))

cHawb    := EC4->EC4_HAWB
cIdentct := EC4->EC4_IDENTC                          
cForn    := EC4->EC4_FORN
cMoeda   := EC4->EC4_MOEDA

lPrimeiro = .T.

DO WHILE .T.
   lRefresh:=.t.
   
   EC4->(DBSEEK(cFilEC4+'0000'+"201"+cHawb+cForn+cMoeda+cIdentct))
      
   IF  VAL(EC4->EC4_NR_CON) # 0 .OR. EC4->EC4_ID_CAM # "201" .OR. EC4->(EOF()) .OR. EC4->EC4_FILIAL#cFilEC4
       EXIT
   ENDIF
   
   nRecnoEC4 = EC4->(RECNO())
   EC4->(DBSKIP())
   IF  VAL(EC4->EC4_NR_CON) # 0 .OR. EC4->EC4_ID_CAM # "201" .OR. EC4->(EOF()) .OR. EC4->EC4_FILIAL#cFilEC4
       IF ! lPrimeiro
          EXIT
       ELSE
          lPrimeiro = .F.
       ENDIF
   ENDIF              

   cHawb = EC4->EC4_HAWB
   cIdentct = EC4->EC4_IDENTC
   cForn = EC4->EC4_FORN
   cMoeda = EC4->EC4_MOEDA

   EC4->(DBSKIP(-1))
   
   IncProc(STR0075+EC4->EC4_HAWB) //"Processo: "

   EC2->(DBSEEK(cFilEC2+EC4->EC4_HAWB+EC4->EC4_FORN+EC4->EC4_MOEDA+EC4->EC4_IDENTC))
   nDi_NumAtu := EC2->EC2_DI_NUM
   cHouse_Atu := EC2->EC2_HAWB
   cIdent_Atu := EC2->EC2_IDENTC

   AFILL(aTab_Inv,SPACE(25))
   AFILL(aVlr_Ind,0)
   nInd := 0
   lProb_I = .F.
   EC8->(DBSETORDER(3))
   EC8->(DBSEEK(cFilEC8+EC4->EC4_HAWB+EC4->EC4_FORN+EC4->EC4_MOEDA+EC4->EC4_IDENTC))

   DO WHILE ! EC8->(EOF()) .AND. EC4->EC4_HAWB+EC4->EC4_FORN+EC4->EC4_MOEDA+EC4->EC4_IDENTC = EC8->EC8_HAWB+EC8->EC8_FORN+EC8->EC8_MOEDA+EC8->EC8_IDENTC .AND. EC8->EC8_FILIAL=cFilEC8
      lRefresh:=.t.
      
      IF ASCAN(aTab_Inv,EC8->EC8_FORN+EC8->EC8_INVOIC+EC4->EC4_IDENTC) = 0
         nInd = nInd + 1
         aTab_Inv[nInd] = EC8->EC8_FORN+EC8->EC8_INVOIC+EC8->EC8_IDENTC
         aVlr_Ind[nInd] = EC8->EC8_FOB_PO
         EC5->(DBSETORDER(1))
         EC5->(DBSEEK(cFilEC5+EC8->EC8_FORN+EC8->EC8_INVOIC+EC8->EC8_IDENTC))
         lProb_I = .F.
         IF nInd = 1
            IF VAL(EC5->EC5_NR_CON) # 0
               lTeste_I = .T.
            ELSE
               lTeste_I = .F.
            ENDIF
         ELSE
            IF lTeste_I
               IF VAL(EC5->EC5_NR_CON) = 0
	   			  IF EMPTY(ALLTRIM(EC5->EC5_VCFANO+EC5->EC5_VCFMES))  // EDS 19/12/2001
                     AADD(aTabMsg,STR0031+EC2->EC2_DI_NUM+STR0028+ALLTRIM(EC2->EC2_HAWB)+STR0029+ALLTRIM(EC8->EC8_INVOIC)+STR0030) //" PROCESSO "###" INVOICE "###" INT. DIFERE DOS DEMAIS" //"DI "
                  ENDIF   
                  lProb_I = .T.
               ENDIF
            ELSE
               IF VAL(EC5->EC5_NR_CON) # 0
                  IF EMPTY(ALLTRIM(EC5->EC5_VCFANO+EC5->EC5_VCFMES))  // EDS 19/12/2001 
                     AADD(aTabMsg,STR0031+EC2->EC2_DI_NUM+STR0028+ALLTRIM(EC2->EC2_HAWB)+STR0029+ALLTRIM(EC8->EC8_INVOIC)+STR0030) //"DI "###" PROCESSO "###" INVOICE "###" INT. DIFERE DOS DEMAIS"
                  ENDIF   
                  lProb_I = .T.
               ENDIF
            ENDIF
         ENDIF
      ELSE
         MConta = ASCAN(aTab_Inv,EC8->EC8_FORN+EC8->EC8_INVOIC+EC8->EC8_IDENTC)
         aVlr_Ind[MConta] = aVlr_Ind[MConta] + EC8->EC8_FOB_PO
      ENDIF
      EC8->(DBSKIP())
   ENDDO

   IF lProb_I
      EC4->(DBSETORDER(2))
      EC4->(DBGOTO(nRecnoEC4))
      EC4->(DBSKIP())
      LOOP
   ENDIF

   AFILL(aTab_HAWB,SPACE(28))
   Ind := 0
   AFILL(aTabVlr_I,0)
   lSai = .F.
   FOR I=1 TO nInd

       EC5->(DBSETORDER(1))
       EC5->(DBSEEK(cFilEC5+aTab_Inv[I]))

       IF VAL(EC5->EC5_NR_CON) # 0
          EC7->(DBSETORDER(1))
          
          EC7->(DBSEEK(cFilEC7+EC5->EC5_FORN+EC5->EC5_INVOIC+cIdent_Atu+cHouse_Atu+"101",.T.))
                    
          dData_Comp = AVCTOD(SPACE(08))
          DO WHILE ! EC7->(EOF()) .AND. EC5->EC5_FORN+EC5->EC5_INVOIC+cIdent_Atu = EC7->EC7_FORN+EC7->EC7_INVOIC+EC7->EC7_IDENTC .AND. cFilEC7=EC7->EC7_FILIAL

             IF EC7->EC7_ID_CAMP $ "101/501/504"
                aTabVlr_I[I] = aTabVlr_I[I] + EC7->EC7_VALOR
                IF EC7->EC7_ID_CAMP = "101"
                   dData_Comp = EC7->EC7_DT_CON
                ENDIF
             ENDIF
             EC7->(DBSKIP())
          ENDDO
       ENDIF

       AFILL(aTab_HAWB,SPACE(37))
       Ind = 0

       EC8->(DBSETORDER(2))
       EC8->(DBSEEK(cFilEC8+EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC))

       DO WHILE ! EC8->(EOF()) .AND. EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC=EC8->EC8_FORN+EC8->EC8_INVOIC+EC8->EC8_IDENTC .AND. cFilEC8=EC8->EC8_FILIAL


          IF ASCAN(aTab_HAWB,EC8->EC8_HAWB+EC8->EC8_FORN+EC8->EC8_MOEDA+EC8->EC8_IDENTC) = 0
             Ind = Ind + 1
             aTab_HAWB[Ind] = EC8->EC8_HAWB+EC8->EC8_FORN+EC8->EC8_MOEDA+EC8->EC8_IDENTC
             EC2->(DBSEEK(cFilEC2+EC8->EC8_HAWB+EC8->EC8_FORN+EC8->EC8_MOEDA+EC8->EC8_IDENTC))
             EC4->(DBSETORDER(1))
             EC4->(DBSEEK(cFilEC4+EC8->EC8_HAWB+EC8->EC8_FORN+EC8->EC8_MOEDA+EC8->EC8_IDENTC+"201"))
             IF VAL(EC4->EC4_NR_CON) # 0 .AND. ! EC4->(EOF())
                lSai = .T.
             ENDIF
             EC4->(DBSETORDER(2))
          ENDIF
          EC8->(DBSKIP())
       ENDDO
   NEXT

   IF lSai
      EC4->(DBSETORDER(2))
      EC4->(DBGOTO(nRecnoEC4))
      EC4->(DBSKIP())
      LOOP
   ENDIF
   AFILL(aTabVlr_H,0)
   FOR I=1 TO Ind
       EC2->(DBSEEK(cFilEC2+aTab_HAWB[I]))
       aTabVlr_H[I] = aTabVlr_H[I] + (VAL(STR(EC2->EC2_FOB_DI * EC2->EC2_TX_DI,15,2)))
   NEXT

   nValor_I = 0
   FOR I=1 TO nInd
       nValor_I += aTabVlr_I[I]
   NEXT

   nValor_H = 0
   FOR I=1 TO Ind
       nValor_H += aTabVlr_H[I]
   NEXT

   IF nInd # 1
      FOR I=1 TO nInd
          lTem_PG := .F.                       
          EC9->(DBSETORDER(1))
          EC9->(DBSEEK(cFilEC9+aTab_Inv[I]))
          nVCReal:=0
          IF ! EC9->(EOF()) .and. cFilEC9 = EC9->EC9_FILIAL
              lFinan  := .F.
              lPg_602 := .F.
              dDt_Finan = AVCTOD("  /  /  ")
              nVCReal:=0
              dData603:=cTod('')
              nData603:=0
              nSoma603:=0
              nOrdAux:=EC5->(INDEXORD())
              EC5->(DBSETORDER(1))   
              nValEC5 := 0
              If aTab_Inv[I] # EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC
                 If EC5->(DBSEEK(cFilEC5+aTab_Inv[I]))
                    nValEC5 := EC5->EC5_FOB_TO
                 EndIf
              Else 
                 nValEC5 := EC5->EC5_FOB_TO
              EndIf    
              EC5->(DBSETORDER(nOrdAux))

              DO WHILE ! EC9->(EOF()) .AND. aTab_Inv[I] = EC9->EC9_FORN+EC9->EC9_INVOIC+EC9->EC9_IDENTC .AND. cFilEC9=EC9->EC9_FILIAL


                 IF EC9->EC9_ID_CAM $ "603/613/620/622"
                    IF EC9->EC9_ID_CAM = "603"
                       nSoma603+=EC9->EC9_VL_MOE
                       If Empty(dData603)
                          dData603:=EC9->EC9_DTCONT
                       EndIf
                       nData603 := Val(StrZero(Year(dData603),4,0)+StrZero(Month(dData603),2,0))
                       If VAL(EC9->EC9_NR_CON) # 0 .AND. VAL(EC9->EC9_NR_CON) # 9999 .AND. nSoma603 = nValEC5// VI
                          lTem_PG := .T.
                       Else 
                          lTem_PG := .F.                       
                       EndIf
                    EndIf
                    dDt_Finan = EC9->EC9_DTCONT
                    lFinan = .T.
                    IF  VAL(EC9->EC9_NR_CON) = 0 .OR. VAL(EC9->EC9_NR_CON) = 9999
                        dDt_Finan = dData_Con
                    ENDIF
                 ENDIF
                 IF EC9->EC9_ID_CAM $ "602/612"
                    lPg_602 = .T.
                 ENDIF
                 EC9->(DBSKIP())
              ENDDO
              
              If lTem_PG
                 nOrdAux:=EC7->(INDEXORD())
                 EC7->(DBSETORDER(1))
                 EC7->(DBSEEK(cFilEC7+aTab_Inv[I]))
                 DO WHILE ! EC7->(EOF()) .AND. aTab_Inv[I] = EC7->EC7_FORN+EC7->EC7_INVOIC+EC7->EC7_IDENTC .AND. cFilEC7=EC7->EC7_FILIAL
                    nEC7DTCONT := Val(StrZero(Year(EC7->EC7_DT_CON),4,0)+StrZero(Month(EC7->EC7_DT_CON),2,0))  
                    IF EC7->EC7_ID_CAMP $ "501/504" .AND. nEC7DTCONT >= nData603
                       If !EC7->EC7_BLOQ
                          nVCReal += EC7->EC7_VALOR
                       ENDIF   
                    ENDIF
                    IF EC7->EC7_ID_CAMP $ "502/503/505" .AND. nEC7DTCONT = nData603                    
                       If !EC7->EC7_BLOQ                       
                          nVCReal -= EC7->EC7_VALOR
                       ENDIF   
                    EndIf
                    EC7->(DBSKIP())
                 ENDDO       
                 EC7->(DBSETORDER(nOrdAux))
              ENDIF

              IF VAL(STR(aVlr_Ind[I]*EC2->EC2_TX_DI,15,2)) - aTabVlr_I[I] >= 0
                 IF lFinan
                    IF dDt_Finan >= PR200VerDT(EC2->EC2_DTENCE)  && se pagto antes da D.I.
                       lMuda_Dt = .F.
                       PR200_GrvPRV((VAL(STR(aVlr_Ind[I]*EC2->EC2_TX_DI,15,2))) - aTabVlr_I[I],"201",aTab_Inv[I],aTab_HAWB[1],"911",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)
                       If l3M .AND. AllTrim(EC2->EC2_IDENTC) $ "7/8"                       
                          PR200_GrvPRV((VAL(STR(aVlr_Ind[I]*EC2->EC2_TX_DI,15,2))) - aTabVlr_I[I],"352",aTab_Inv[I],aTab_HAWB[1],"352",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)
                       EndIf
                       PR200_VcfGrv((VAL(STR(aVlr_Ind[I]*EC2->EC2_TX_DI,15,2))) - aTabVlr_I[I],"201",aTab_Inv[I],aTab_HAWB[1],"201",PR200VerDT(EC2->EC2_DTENCE)," ")
                    ELSE
                       lMuda_Dt = .F.
                       PR200_GrvPRV((VAL(STR(aVlr_Ind[I]*EC2->EC2_TX_DI,15,2))) - aTabVlr_I[I],"201",aTab_Inv[I],aTab_HAWB[1],"901",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)
                       If l3M .AND. AllTrim(EC2->EC2_IDENTC) $ "7/8"                       
                          PR200_GrvPRV((VAL(STR(aVlr_Ind[I]*EC2->EC2_TX_DI,15,2))) - aTabVlr_I[I],"352",aTab_Inv[I],aTab_HAWB[1],"352",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)
                       EndIf
                    ENDIF
                    lTem_DI2 := .T.
                    nVCReal += (VAL(STR(aVlr_Ind[I]*EC2->EC2_TX_DI,15,2))) - aTabVlr_I[I] 
                 ELSE
                    EC5->(DBSETORDER(1))
                    EC5->(DBSEEK(cFilEC5+aTab_Inv[I]))
                    lMuda_Dt = .F.
                    IF EC5->EC5_CD_PGT = "1"
                       IF lPg_602
                          PR200_GrvPRV((VAL(STR(aVlr_Ind[I]*EC2->EC2_TX_DI,15,2))) - aTabVlr_I[I],"201",aTab_Inv[I],aTab_HAWB[1],"901",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)
                          If l3M .AND. AllTrim(EC2->EC2_IDENTC) $ "7/8"                       
                             PR200_GrvPRV((VAL(STR(aVlr_Ind[I]*EC2->EC2_TX_DI,15,2))) - aTabVlr_I[I],"352",aTab_Inv[I],aTab_HAWB[1],"352",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)
                          EndIf
                          PR200_VcfGrv((VAL(STR(aVlr_Ind[I]*EC2->EC2_TX_DI,15,2))) - aTabVlr_I[I],"201",aTab_Inv[I],aTab_HAWB[1],"201",PR200VerDT(EC2->EC2_DTENCE)," ")
                       ELSE
                          IF EMPTY(ALLTRIM(EC5->EC5_VCFANO+EC5->EC5_VCFMES))  // EDS 19/12/2001                       
                             AADD(aTabMsg,STR0032+ALLTRIM(EC5->EC5_INVOIC)) //"*** ATENCAO *** - Invoice a vista sem pagamento - Inv."
                          ENDIF   
                       ENDIF
                    ELSE
                       PR200_GrvPRV((VAL(STR(aVlr_Ind[I]*EC2->EC2_TX_DI,15,2))) - aTabVlr_I[I],"201",aTab_Inv[I],aTab_HAWB[1],"911",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)
                       If l3M .AND. AllTrim(EC2->EC2_IDENTC) $ "7/8"                       
                          PR200_GrvPRV((VAL(STR(aVlr_Ind[I]*EC2->EC2_TX_DI,15,2))) - aTabVlr_I[I],"352",aTab_Inv[I],aTab_HAWB[1],"352",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)
                       EndIf
                       PR200_VcfGrv((VAL(STR(aVlr_Ind[I]*EC2->EC2_TX_DI,15,2))) - aTabVlr_I[I],"201",aTab_Inv[I],aTab_HAWB[1],"201",PR200VerDT(EC2->EC2_DTENCE)," ")
                    ENDIF
                    lTem_DI2 := .T.
                    nVCReal +=(VAL(STR(aVlr_Ind[I]*EC2->EC2_TX_DI,15,2))) - aTabVlr_I[I] 
                 ENDIF
              ELSE
                 IF lFinan
                    IF dDt_Finan >= PR200VerDT(EC2->EC2_DTENCE)
                       lMuda_Dt = .F.
                       PR200_GrvPRV(((VAL(STR(aVlr_Ind[I]*EC2->EC2_TX_DI,15,2))) - aTabVlr_I[I])*(1),"201",aTab_Inv[I],aTab_HAWB[1],"912",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)
                       If l3M .AND. AllTrim(EC2->EC2_IDENTC) $ "7/8"                       
                          PR200_GrvPRV(((VAL(STR(aVlr_Ind[I]*EC2->EC2_TX_DI,15,2))) - aTabVlr_I[I])*(1),"353",aTab_Inv[I],aTab_HAWB[1],"353",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)
                       EndIf
                       PR200_VcfGrv((VAL(STR(aVlr_Ind[I]*EC2->EC2_TX_DI,15,2))) - aTabVlr_I[I],"201",aTab_Inv[I],aTab_HAWB[1],"201",PR200VerDT(EC2->EC2_DTENCE)," ")
                    ELSE
                       lMuda_Dt = .F.
                       PR200_GrvPRV(((VAL(STR(aVlr_Ind[I]*EC2->EC2_TX_DI,15,2))) - aTabVlr_I[I])*(1),"201",aTab_Inv[I],aTab_HAWB[1],"902",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)
                       If l3M .AND. AllTrim(EC2->EC2_IDENTC) $ "7/8"                       
                          PR200_GrvPRV(((VAL(STR(aVlr_Ind[I]*EC2->EC2_TX_DI,15,2))) - aTabVlr_I[I])*(1),"353",aTab_Inv[I],aTab_HAWB[1],"353",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)
                       EndIf
                    ENDIF
                    lTem_DI2 := .T.
                    nVCReal +=(VAL(STR(aVlr_Ind[I]*EC2->EC2_TX_DI,15,2))) - aTabVlr_I[I]
                 ELSE
                    EC5->(DBSETORDER(1))
                    EC5->(DBSEEK(cFilEC5+aTab_Inv[I]))
                    lMuda_Dt = .F.
                    IF EC5->EC5_CD_PGT = "1"
                       IF lPg_602
                          PR200_GrvPRV(((VAL(STR(aVlr_Ind[I]*EC2->EC2_TX_DI,15,2))) - aTabVlr_I[I])*(1),"201",aTab_Inv[I],aTab_HAWB[1],"902",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)
                          If l3M .AND. AllTrim(EC2->EC2_IDENTC) $ "7/8"                       
                             PR200_GrvPRV(((VAL(STR(aVlr_Ind[I]*EC2->EC2_TX_DI,15,2))) - aTabVlr_I[I])*(1),"353",aTab_Inv[I],aTab_HAWB[1],"353",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)
                          EndIf
                          PR200_VcfGrv((VAL(STR(aVlr_Ind[I]*EC2->EC2_TX_DI,15,2))) - aTabVlr_I[I],"201",aTab_Inv[I],aTab_HAWB[1],"201",PR200VerDT(EC2->EC2_DTENCE)," ")
                       ELSE
                          IF EMPTY(ALLTRIM(EC5->EC5_VCFANO+EC5->EC5_VCFMES))  // EDS 19/12/2001
                             AADD(aTabMsg,STR0032+ALLTRIM(EC5->EC5_INVOIC)) //"*** ATENCAO *** - Invoice a vista sem pagamento - Inv."
                          ENDIF   
                       ENDIF
                    ELSE
                       PR200_GrvPRV(((VAL(STR(aVlr_Ind[I]*EC2->EC2_TX_DI,15,2))) - aTabVlr_I[I])*(1),"201",aTab_Inv[I],aTab_HAWB[1],"912",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)
                       If l3M .AND. AllTrim(EC2->EC2_IDENTC) $ "7/8"                       
                          PR200_GrvPRV(((VAL(STR(aVlr_Ind[I]*EC2->EC2_TX_DI,15,2))) - aTabVlr_I[I])*(1),"353",aTab_Inv[I],aTab_HAWB[1],"353",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)
                       EndIf
                       PR200_VcfGrv((VAL(STR(aVlr_Ind[I]*EC2->EC2_TX_DI,15,2))) - aTabVlr_I[I],"201",aTab_Inv[I],aTab_HAWB[1],"201",PR200VerDT(EC2->EC2_DTENCE)," ")
                    ENDIF
                    lTem_DI2 := .T.
                    nVCReal +=(VAL(STR(aVlr_Ind[I]*EC2->EC2_TX_DI,15,2))) - aTabVlr_I[I]
                 ENDIF
              ENDIF

              IF cPrv_Efe = "2"
                 EC5->(DBSETORDER(1))
                 IF EC5->(DBSEEK(cFilEC5+aTab_Inv[I]))
                    EC5->(Reclock('EC5',.F.))
                    EC5->EC5_T_D    := "E"           && indica estoque,
                    EC5->EC5_T_D_NR := STRZERO(nNR_Cont+1,4,0)
                    EC5->(MSUNLOCK())
                 ENDIF
              ENDIF

          ENDIF
          APUVCREAL(nVCReal,aTab_Inv[I],aTab_HAWB[1],EC2->EC2_DTENCE,EC2->EC2_MOEDA)          
      NEXT
   ELSE
      IF nValor_H - nValor_I >= 0
         FOR I=1 TO Ind
             lTem_PG := .F.                       
             EC2->(DBSEEK(cFilEC2+aTab_HAWB[I]))
             nDi_NumAtu = EC2->EC2_DI_NUM

             EC9->(DBSETORDER(1))
             EC9->(DBSEEK(cFilEC9+aTab_Inv[1]))
             IF ! EC9->(EOF()) .AND. cFilEC9=EC9->EC9_FILIAL
                lFinan = .F.
                lPg_602 = .F.
                dDt_Finan = AVCTOD(SPACE(08))
                nVCReal:=0
                dData603:=cTod('')
                nData603:=0
                nSoma603:=0
                nOrdAux:=EC5->(INDEXORD())
                EC5->(DBSETORDER(1))   
                nValEC5 := 0
                If aTab_Inv[I] # EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC
                   If EC5->(DBSEEK(cFilEC5+aTab_Inv[I]))
                      nValEC5 := EC5->EC5_FOB_TO
                   EndIf
                Else 
                   nValEC5 := EC5->EC5_FOB_TO
                EndIf
                EC5->(DBSETORDER(nOrdAux))
                DO WHILE ! EC9->(EOF()) .AND. aTab_Inv[1] = EC9->EC9_FORN+EC9->EC9_INVOIC+EC9->EC9_IDENTC .AND. cFilEC9=EC9->EC9_FILIAL


                   IF EC9->EC9_ID_CAM $ "603/613/620/622"
                      IF EC9->EC9_ID_CAM = "603"
                         If Empty(dData603)
                            dData603:=EC9->EC9_DTCONT
                         EndIf
                         nData603 := Val(StrZero(Year(dData603),4,0)+StrZero(Month(dData603),2,0))
                         nSoma603+=EC9->EC9_VL_MOE
                         If VAL(EC9->EC9_NR_CON) # 0 .AND. VAL(EC9->EC9_NR_CON) # 9999  .AND. nSoma603 = nValEC5// VI
                            lTem_PG := .T.
                         Else 
                            lTem_PG := .F.                       
                         EndIf
                      EndIf

                      dDt_Finan = EC9->EC9_DTCONT
                      lFinan = .T.
                      IF  VAL(EC9->EC9_NR_CON) = 0 .OR. VAL(EC9->EC9_NR_CON) = 9999
                          dDt_Finan = dData_Con
                      ENDIF
                   ENDIF
                   IF EC9->EC9_ID_CAM $ "602/612"
                      lPg_602 = .T.
                   ENDIF
                   EC9->(DBSKIP())
                ENDDO
                
                If lTem_PG
                   nOrdAux:=EC7->(INDEXORD())
                   EC7->(DBSETORDER(1))
                   EC7->(DBSEEK(cFilEC7+aTab_Inv[1]))
                   DO WHILE ! EC7->(EOF()) .AND. aTab_Inv[1] = EC7->EC7_FORN+EC7->EC7_INVOIC+EC7->EC7_IDENTC .AND. cFilEC7=EC7->EC7_FILIAL
                      nEC7DTCONT := Val(StrZero(Year(EC7->EC7_DT_CON),4,0)+StrZero(Month(EC7->EC7_DT_CON),2,0))  
                      IF EC7->EC7_ID_CAMP $ "501/504" .AND. nEC7DTCONT >= nData603
                         If !EC7->EC7_BLOQ                        
                            nVCReal += EC7->EC7_VALOR
                         ENDIF   
                      ENDIF                      
                      IF EC7->EC7_ID_CAMP $ "502/503/505" .AND. nEC7DTCONT = nData603                    
                         If !EC7->EC7_BLOQ                       
                            nVCReal -= EC7->EC7_VALOR
                         ENDIF   
                      EndIf
                      EC7->(DBSKIP())
                   ENDDO       
                   EC7->(DBSETORDER(nOrdAux))
// VI 20/01/02     nVCReal += nValor_H
                ENDIF

                IF lFinan
                   IF dDt_Finan >= PR200VerDT(EC2->EC2_DTENCE)
                      lMuda_Dt = .F.
                      PR200_GrvPRV(((nValor_H - nValor_I)/Ind),"201",aTab_Inv[1],aTab_HAWB[I],"911",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)
                      If l3M .AND. AllTrim(EC2->EC2_IDENTC) $ "7/8"                                             
                         PR200_GrvPRV(((nValor_H - nValor_I)/Ind),"352",aTab_Inv[1],aTab_HAWB[I],"352",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)
                      EndIf
                      PR200_VcfGrv(((nValor_H - nValor_I)/Ind),"201",aTab_Inv[1],aTab_HAWB[I],"201",PR200VerDT(EC2->EC2_DTENCE)," ")
                      nVCReal +=((nValor_H - nValor_I)/Ind)
                   ELSE
                      lMuda_Dt = .F.
                      PR200_GrvPRV(((nValor_H - nValor_I)/Ind),"201",aTab_Inv[1],aTab_HAWB[I],"901",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)
                      If l3M .AND. AllTrim(EC2->EC2_IDENTC) $ "7/8"                                             
                         PR200_GrvPRV(((nValor_H - nValor_I)/Ind),"352",aTab_Inv[1],aTab_HAWB[I],"352",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)
                      EndIf
                      nVCReal +=((nValor_H - nValor_I)/Ind)
                      nVCReal *=-1
                   ENDIF
                   lTem_DI2 := .T.
// VI 20/01/02     nVCReal +=((nValor_H - nValor_I)/Ind)
                ELSE
                   EC5->(DBSETORDER(1))
                   EC5->(DBSEEK(cFilEC5+aTab_Inv[1]))
                   lMuda_Dt = .F.
                   IF EC5->EC5_CD_PGT = "1"
                      IF lPg_602
                         PR200_GrvPRV(((nValor_H - nValor_I)/Ind),"201",aTab_Inv[1],aTab_HAWB[I],"901",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)
                         lTem_DI2 := .T.
                         nVCReal +=((nValor_H - nValor_I)/Ind)
                         If l3M .AND. AllTrim(EC2->EC2_IDENTC) $ "7/8"                                             
                            PR200_GrvPRV(((nValor_H - nValor_I)/Ind),"352",aTab_Inv[1],aTab_HAWB[I],"352",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)
                         EndIf
                         PR200_VcfGrv(((nValor_H - nValor_I)/Ind),"201",aTab_Inv[1],aTab_HAWB[I],"201",PR200VerDT(EC2->EC2_DTENCE)," ")
                      ELSE           
                         IF EMPTY(ALLTRIM(EC5->EC5_VCFANO+EC5->EC5_VCFMES))  // EDS 19/12/2001
                            AADD(aTabMsg,STR0032+ALLTRIM(EC5->EC5_INVOIC)) //"*** ATENCAO *** - Invoice a vista sem pagamento - Inv."
                         ENDIF   
                      ENDIF
                   ELSE
                      PR200_GrvPRV(((nValor_H - nValor_I)/Ind),"201",aTab_Inv[1],aTab_HAWB[I],"911",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)
                      lTem_DI2 := .T.
                      nVCReal +=((nValor_H - nValor_I)/Ind)
                      If l3M .AND. AllTrim(EC2->EC2_IDENTC) $ "7/8"                                             
                         PR200_GrvPRV(((nValor_H - nValor_I)/Ind),"352",aTab_Inv[1],aTab_HAWB[I],"352",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)                      
                      EndIf
                      PR200_VcfGrv(((nValor_H - nValor_I)/Ind),"201",aTab_Inv[1],aTab_HAWB[I],"201",PR200VerDT(EC2->EC2_DTENCE)," ")
                   ENDIF
                ENDIF

                IF cPrv_Efe = "2"
                   EC5->(DBSETORDER(1))
                   IF EC5->(DBSEEK(cFilEC5+aTab_Inv[1]))
                      EC5->(Reclock('EC5',.F.))
                      EC5->EC5_T_D    := "E"   && indica estoque,
                      EC5->EC5_T_D_NR := STRZERO(nNR_Cont+1,4,0)
                      EC5->(MSUNLOCK())
                   ENDIF
                ENDIF

             ENDIF
             APUVCREAL(nVCReal,aTab_Inv[I],aTab_HAWB[1],EC2->EC2_DTENCE)          
         NEXT
      ELSE
         FOR I=1 TO Ind
             EC2->(DBSEEK(cFilEC2+aTab_HAWB[I]))
             nDi_NumAtu = EC2->EC2_DI_NUM
             lTem_PG := .F.                       
             EC9->(DBSETORDER(1))
             EC9->(DBSEEK(cFilEC9+aTab_Inv[1]))
             nVCReal:=0
             IF ! EC9->(EOF()) .AND. EC9->EC9_FILIAL=cFilEC9
                lFinan = .F.
                lPg_602 = .F.
                dDt_Finan = AVCTOD(SPACE(08))
                dData603:=cTod('')
                nData603:=0
                nSoma603:=0
                nOrdAux:=EC5->(INDEXORD())
                EC5->(DBSETORDER(1))   
                nValEC5 := 0
                If aTab_Inv[I] # EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC
                   If EC5->(DBSEEK(cFilEC5+aTab_Inv[I]))
                      nValEC5 := EC5->EC5_FOB_TO
                   EndIf
                Else 
                   nValEC5 := EC5->EC5_FOB_TO
                EndIf
                EC5->(DBSETORDER(nOrdAux))
                DO WHILE ! EC9->(EOF()) .AND. aTab_Inv[1] = EC9->EC9_FORN+EC9->EC9_INVOIC+EC9->EC9_IDENTC .AND. EC9->EC9_FILIAL=cFilEC9


                   IF EC9->EC9_ID_CAM $ "603/613/620/622"
                      IF EC9->EC9_ID_CAM = "603"
                         nSoma603+=EC9->EC9_VL_MOE
                         If Empty(dData603)
                            dData603:=EC9->EC9_DTCONT
                         EndIf
                         nData603 := Val(StrZero(Year(dData603),4,0)+StrZero(Month(dData603),2,0))
                         If VAL(EC9->EC9_NR_CON) # 0 .AND. VAL(EC9->EC9_NR_CON) # 9999  .AND. nSoma603 = nValEC5// VI
                            lTem_PG := .T.
                         Else 
                            lTem_PG := .F.                       
                         EndIf
                      EndIf

                      dDt_Finan = EC9->EC9_DTCONT
                      lFinan = .T.
                      IF  VAL(EC9->EC9_NR_CON) = 0 .OR. VAL(EC9->EC9_NR_CON) = 9999
                          dDt_Finan = dData_Con
                      ENDIF
                   ENDIF
                   IF EC9->EC9_ID_CAM $ "602/612"
                      lPg_602 = .T.
                   ENDIF
                   EC9->(DBSKIP())
                ENDDO

                If lTem_PG  
                   nOrdAux:=EC7->(INDEXORD())
                   EC7->(DBSETORDER(1))
                   EC7->(DBSEEK(cFilEC7+aTab_Inv[1]))
                   DO WHILE ! EC7->(EOF()) .AND. aTab_Inv[1] = EC7->EC7_FORN+EC7->EC7_INVOIC+EC7->EC7_IDENTC .AND. cFilEC7=EC7->EC7_FILIAL
                      nEC7DTCONT := Val(StrZero(Year(EC7->EC7_DT_CON),4,0)+StrZero(Month(EC7->EC7_DT_CON),2,0))  
                      IF EC7->EC7_ID_CAMP $ "501/504" .AND. nEC7DTCONT >= nData603
                         If !EC7->EC7_BLOQ                       
                            nVCReal += EC7->EC7_VALOR  
                         ENDIF   
                      ENDIF
                      IF EC7->EC7_ID_CAMP $ "502/503/505" .AND. nEC7DTCONT = nData603                    
                         If !EC7->EC7_BLOQ                       
                            nVCReal -= EC7->EC7_VALOR  
                         ENDIF   
                      EndIf
                      EC7->(DBSKIP())
                   ENDDO
                   EC7->(DBSETORDER(nOrdAux))
                ENDIF

                IF lFinan
                   IF dDt_Finan >= PR200VerDT(EC2->EC2_DTENCE)
                      lMuda_Dt = .F.
                      PR200_GrvPRV(((nValor_H - nValor_I)*(1)/Ind),"201",aTab_Inv[1],aTab_HAWB[I],"912",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)
                      If l3M .AND. AllTrim(EC2->EC2_IDENTC) $ "7/8"                                             
                         PR200_GrvPRV(((nValor_H - nValor_I)*(1)/Ind),"353",aTab_Inv[1],aTab_HAWB[I],"353",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)
                      EndIf
                      PR200_VcfGrv(((nValor_H - nValor_I)*(1)/Ind),"201",aTab_Inv[1],aTab_HAWB[I],"201",PR200VerDT(EC2->EC2_DTENCE)," ")
                      nVCReal +=((nValor_H - nValor_I)/Ind) 
                   ELSE
                      lMuda_Dt = .F.
                      PR200_GrvPRV(((nValor_H - nValor_I)*(1)/Ind),"201",aTab_Inv[1],aTab_HAWB[I],"902",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)
                      If l3M .AND. AllTrim(EC2->EC2_IDENTC) $ "7/8"                                             
                         PR200_GrvPRV(((nValor_H - nValor_I)*(1)/Ind),"353",aTab_Inv[1],aTab_HAWB[I],"353",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)
                      EndIf
                      nVCReal +=((nValor_H - nValor_I)*(1)/Ind)  
                      nVCReal *= -1 // VI 20/01/02
                   ENDIF
                   lTem_DI2 := .T.
// VI 20/01/02     nVCReal +=((nValor_H - nValor_I)/Ind)
                ELSE
                   EC5->(DBSETORDER(1))
                   EC5->(DBSEEK(cFilEC5+aTab_Inv[1]))
                   lMuda_Dt = .F.
                   IF EC5->EC5_CD_PGT = "1"
                      IF lPg_602
                         PR200_GrvPRV(((nValor_H - nValor_I)*(1)/Ind),"201",aTab_Inv[1],aTab_HAWB[I],"902",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)
                         lTem_DI2 := .T.
                         nVCReal +=((nValor_H - nValor_I)/Ind)
                         If l3M .AND. AllTrim(EC2->EC2_IDENTC) $ "7/8"                                             
                            PR200_GrvPRV(((nValor_H - nValor_I)*(1)/Ind),"353",aTab_Inv[1],aTab_HAWB[I],"353",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)
                         EndIf
                         PR200_VcfGrv(((nValor_H - nValor_I)*(1)/Ind),"201",aTab_Inv[1],aTab_HAWB[I],"201",PR200VerDT(EC2->EC2_DTENCE)," ")
                      ELSE
                         IF EMPTY(ALLTRIM(EC5->EC5_VCFANO+EC5->EC5_VCFMES))  // EDS 19/12/2001
                            AADD(aTabMsg,STR0032+ALLTRIM(EC5->EC5_INVOIC)) //"*** ATENCAO *** - INVOICE A VISTA SEM PAGAMENTO - INV."
                         ENDIF   
                      ENDIF
                   ELSE
                      PR200_GrvPRV(((nValor_H - nValor_I)*(1)/Ind),"201",aTab_Inv[1],aTab_HAWB[I],"912",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)
                      lTem_DI2 := .T.
                      nVCReal +=((nValor_H - nValor_I)/Ind)
                      If l3M .AND. AllTrim(EC2->EC2_IDENTC) $ "7/8"                                                                   
                         PR200_GrvPRV(((nValor_H - nValor_I)*(1)/Ind),"353",aTab_Inv[1],aTab_HAWB[I],"353",PR200VerDT(EC2->EC2_DTENCE)," ",EC2->EC2_DTENCE,EC2->EC2_MOEDA,EC2->EC2_TX_DI)                      
                      EndIf
                      PR200_VcfGrv(((nValor_H - nValor_I)*(1)/Ind),"201",aTab_Inv[1],aTab_HAWB[I],"201",PR200VerDT(EC2->EC2_DTENCE)," ")
                   ENDIF
                ENDIF

                IF cPrv_Efe = "2"
                   EC5->(DBSETORDER(1))
                   IF EC5->(DBSEEK(cFilEC5+aTab_Inv[1]))
                      EC5->(Reclock('EC5',.F.))
                      EC5->EC5_T_D    := "E"   && indica estoque,
                      EC5->EC5_T_D_NR := STRZERO(nNR_Cont+1,4,0)
                      EC5->(MSUNLOCK())
                   ENDIF
                ENDIF

             ENDIF
             APUVCREAL(nVCReal,aTab_Inv[I],aTab_HAWB[1],EC2->EC2_DTENCE,EC2->EC2_MOEDA)          
         NEXT
      ENDIF
   ENDIF

   EC4->(DBSETORDER(2))
   EC4->(DBGOTO(nRecnoEC4))

************* grava 2.01 no DDI evitando v.c. antes da D.I.

   FOR I=1 TO Ind
       EC4->(DBSETORDER(1))
       EC4->(DBSEEK(cFilEC4+aTab_HAWB[I]))
       IF ! EC4->(EOF()) //.AND. ((lVCReal .and. cPrv_Efe = "2") .OR. (!lVCReal)) // VI Para Gravar somente na efetivação
          Reclock('EC4',.F.)
          EC4->EC4_NR_CON := STRZERO(nNR_Cont+1,4,0)
          EC4->(MSUNLOCK())
       ENDIF
   NEXT

   EC4->(DBSETORDER(2))
   EC4->(DBSKIP())
   
ENDDO

************* rotina de apuracao de pagamentos 2.03 em diante

ProcRegua(nTot3)
Pr999Men(STR0073)                //"Lendo Detalhes da DI"

EC4->(DBSETORDER(2))
EC4->(DBSEEK(cFilEC4+'0000'+"203",.T.))

DO WHILE ! EC4->(EOF()) .AND. VAL(EC4->EC4_NR_CON) = 0 .AND. EC4->EC4_FILIAL==cFilEC4

   lRefresh:=.t.
   IncProc(STR0075+EC4->EC4_HAWB) //"Processo: "
			   
   EC4->(DBSKIP())
   nRecEC4_A = EC4->(RECNO())
   EC4->(DBSKIP(-1))

   EC2->(DBSETORDER(1))
   EC2->(DBSEEK(cFilEC2+EC4->EC4_HAWB+EC4->EC4_FORN+EC4->EC4_MOEDA+EC4->EC4_IDENTC))
   EC8->(DBSETORDER(1))
   EC8->(DBSEEK(cFilEC8+EC4->EC4_HAWB+EC4->EC4_FORN+EC4->EC4_MOEDA+EC4->EC4_IDENTC))
   nDi_NumAtu = EC2->EC2_DI_NUM

   DO CASE
      CASE SUBSTR(EC4->EC4_ID_CAM,1,1) = "2" .OR. SUBSTR(EC4->EC4_ID_CAM,1,1) = "4"
           IF EC4->EC4_VL_CAM # 0
              lMuda_Dt = .F.
              PR200_GrvPRV(EC4->EC4_VL_CAM,EC4->EC4_ID_CAM,EC8->EC8_FORN+SPACE(LEN(EC8->EC8_INVOIC)),EC4->EC4_HAWB+Space(nTamForn+nTamMoeda)+EC4->EC4_IDENTC,EC4->EC4_ID_CAM,PR200VerDT(EC4->EC4_DT_PGT)," ",EC4->EC4_DT_PGT,EC4->EC4_MOEDA,0)
           ENDIF
      CASE SUBSTR(EC4->EC4_ID_CAM,1,1) $ "3/6"  && despesas e i.r./desp.bancaria vindas do APD
           IF EC4->EC4_VL_CAMP # 0
              lMuda_Dt = .F.
              PR200_GrvPRV(EC4->EC4_VL_CAMP,EC4->EC4_ID_CAMP,EC8->EC8_FORN+SPACE(LEN(EC8->EC8_INVOIC)),EC4->EC4_HAWB+Space(nTamForn+nTamMoeda)+EC4->EC4_IDENTC,EC4->EC4_ID_CAM,PR200VerDT(EC4->EC4_DT_PGT)," ",EC4->EC4_DT_PGT,EC4->EC4_MOEDA,0)
           ENDIF
   ENDCASE

   IF cPrv_Efe = "2"
      Reclock('EC4',.F.)
      EC4->EC4_NR_CON := STRZERO(nNR_Cont+1,4,0)
      EC4->(MSUNLOCK())
      EC4->(DBGOTO(nRecEC4_A))
   ELSE
      EC4->(DBSKIP())
   ENDIF
ENDDO

ProcRegua(nTot4)
Pr999Men(STR0076)                //"Lendo Invoices (Contabilidade)"

EC5->(DBSETORDER(3))
EC5->(DBSEEK(cFilEC5+'0001',.T.))

DO WHILE ! EC5->(EOF()) .AND. VAL(EC5->EC5_NR_CON) # 0 .AND. EC5->EC5_FILIAL==cFilEC5

   lRefresh:=.t.
   IncProc(STR0079+EC5->EC5_INVOIC) //"Invoice: "
               
   If ! EMPTY(ALLTRIM(EC5->EC5_VCFANO+EC5->EC5_VCFMES))  // VI 06/11/01
      EC5->(DBSKIP())
      LOOP   
   EndIf
   
   If lVCReal  // VI 09/04/02 
      nRegEC7Aux:=EC7->(RECNO())
      nOrdAuxEC7:=EC7->(INDEXORD())
      EC7->(DBSETORDER(1))
      lTem_DI2 := .F.
      If EC7->(DBSEEK(cFilEC7+EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC+EC5->EC5_HAWB+"201"))
         lTem_DI2 := .T.
      EndIF
      EC7->(DBSETORDER(nOrdAuxEC7))
      EC7->(DBGOTO(nRegEC7Aux))
   EndIf
   
   IF "MERCK" $ UPPER(SM0->M0_NOME) .OR. "M.B." $ UPPER(SM0->M0_NOME)
      IF EC5->EC5_AMOS $ cSim 
         EC5->(DBSKIP())
         LOOP
      EndIf
   ELSE   
      //IF EC5->EC5_AMOS $ cSim .OR. (! lVCReal .AND. EC5->EC5_T_D $ "D/E") .or. (lVCReal .and. lTem_DI2) // VI 08/08/01  && divisas e estoque ja' tem pagto ou di, nao gera 501/504
      //AAF 08/10/2012 - Gerar variação cambial de transito mesmo que já pago!
      IF EC5->EC5_AMOS $ cSim .OR. (! lVCReal .AND. EC5->EC5_T_D $ "E") .or. (lVCReal .and. lTem_DI2) // VI 08/08/01  && divisas e estoque ja' tem pagto ou di, nao gera 501/504
         EC5->(DBSKIP())
         LOOP
      ENDIF
   ENDIF
   EC8->(DBSETORDER(2))
   EC8->(DBSEEK(cFilEC8+EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC))
   lSaida = .F.
   AFILL(aTab_HAWB,SPACE(37))
   Ind = 0
   DO WHILE ! EC8->(EOF()) .AND. (EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC)=(EC8->EC8_FORN+EC8->EC8_INVOIC+EC8->EC8_IDENTC) .AND. EC8->EC8_FILIAL=cFilEC8
      lRefresh:=.t.

      EC4->(DBSETORDER(1))
      EC4->(DBSEEK(cFilEC4+EC8->EC8_HAWB+EC8->EC8_FORN+EC8->EC8_MOEDA+EC8->EC8_IDENTC+"201"))
      IF ! EC4->(EOF()) .AND. (VAL(EC4->EC4_NR_CON) # 0 .and. VAL(EC4->EC4_NR_CON) # 9999)
         lSaida = .T.
         EXIT
      ELSE
         EC2->(DBSETORDER(1))
         EC2->(DBSEEK(cFilEC2+EC8->EC8_HAWB+EC8->EC8_FORN+EC8->EC8_MOEDA+EC8->EC8_IDENTC))
         EC7->(DBSETORDER(1))
         EC7->(DBSEEK(cFilEC7+EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC+EC8->EC8_HAWB+"101"))
         IF EC7->(EOF())
            lSaida = .T.
            IF EC5->EC5_AMOS $ cSim
               AADD(aTabMsg,STR0033+ALLTRIM(EC5->EC5_INVOIC) +STR0028+ ALLTRIM(EC8->EC8_HAWB) + STR0026) //"Invoice j  contabilizada. N„o encontrado no arq.CONTABILIZACAO - Inv."###" Processo "###" - Amostra"
            ELSE
               AADD(aTabMsg,STR0033+ALLTRIM(EC5->EC5_INVOIC) +STR0028+ ALLTRIM(EC8->EC8_HAWB) +STR0034+ ALLTRIM(EC5->EC5_IDENTC)) //"Invoice j  contabilizada. N„o encontrado no arq.CONTABILIZACAO - Inv."###" Processo "###" BU/CC "
            ENDIF
            EXIT
         ENDIF
      ENDIF

      IF ! lSaida
          IF ASCAN(aTab_HAWB,EC8->EC8_HAWB+EC8->EC8_FORN+EC8->EC8_MOEDA+EC8->EC8_IDENTC) = 0
             Ind = Ind + 1
             aTab_HAWB[Ind] = EC8->EC8_HAWB+EC8->EC8_FORN+EC8->EC8_MOEDA+EC8->EC8_IDENTC
          ENDIF
      ENDIF

      EC8->(DBSKIP())
   ENDDO

   IF lSaida
      EC5->(DBSKIP())
      LOOP
   ENDIF

   FOR I=1 TO Ind

       EC2->(DBSETORDER(1))
       EC2->(DBSEEK(cFilEC2+aTab_HAWB[I]))

****** nao deveria ler MV000 e sim VCF000, poderiamos limpar o mv000 quando necessario

       nDi_NumAtu = EC2->EC2_DI_NUM
       EC7->(DBSETORDER(1))
       EC7->(DBSEEK(cFilEC7+EC5->EC5_FORN+EC5->EC5_INVOIC+SUBS(aTab_HAWB[I],(nTamHawb+nTamForn+nTamMoeda+1),nTamIdentc)+SUBS(aTab_HAWB[I],1,nTamHawb)+"101"))

       nValor := 0
       DO WHILE ! EC7->(EOF()) .AND. EC5->EC5_FORN+EC5->EC5_INVOIC=EC7->EC7_FORN+EC7->EC7_INVOIC .AND. SUBS(aTab_HAWB[I],1,nTamHawb)+SUBS(aTab_HAWB[I],(nTamHawb+nTamForn+nTamMoeda+1),nTamIdentc) = EC7->EC7_HAWB+EC7->EC7_IDENTC .AND. cFilEC7=EC7->EC7_FILIAL
          lRefresh:=.t.

          IF EC7->EC7_ID_CAM $ "101/501/504"
             nValor += EC7->EC7_VALOR
             IF VAL(EC7->EC7_NR_CONT) = (nNR_Cont+1)
                dData = EC5->EC5_DT_EMI
                EXIT
             ELSE
                dData = EC7->EC7_DT_CON
             ENDIF
          ENDIF
          EC7->(DBSKIP())
       ENDDO

       IF nValor # 0
          nTaxa_A = BuscaTxECO(EC5->EC5_MOE_FO,dData)
          nTaxa_B = BuscaTxECO(EC5->EC5_MOE_FO,dData_Con) // Nick 29/05/06
          nVlr_Cal = VAL(STR(EC5->EC5_FOB_TO * nTaxa_B,15,2))
   
          If EasyEntryPoint("ECOPR999") 
             ExecBlock("ECOPR999",.F.,.F.,"Valor_P_CALCULO_VC")             
          EndIf
                 
          nVlr_Tot = nVlr_Cal - nValor
          IF  "AGFA" $ UPPER(SM0->M0_NOME) .AND. VAL(STR(nVlr_Tot,15,2)) # 0    && para verificar os pagtos
              EC9->(DBSETORDER(2))
              EC9->(DBSEEK(cFilEC9+EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC+"603"))
              IF  ! EC9->(EOF())
                  nVlr_Tot = 0
                  DO  WHILE ! EC9->(EOF()) .AND. EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC+"603" = ;
                                                 EC9->EC9_FORN+EC9->EC9_INVOIC+EC9->EC9_IDENTC+"603"  .AND. EC9->EC9_FILIAL=cFilEC9
                      IF  VAL(EC9->EC9_NR_CON)=9999 .OR. VAL(EC9->EC9_NR_CON) = (nNR_Cont+1) .OR. VAL(EC9->EC9_NR_CON) = 0
                          nVlr_Tot += EC9->EC9_VALOR
                      ENDIF
                      EC9->(DBSKIP())
                  ENDDO
                  IF  nVlr_Tot # 0
                      nVlr_Tot := nVlr_Tot - nValor
                  ELSE
                      nVlr_Tot := nVlr_Cal - nValor
                  ENDIF
              ENDIF
          ENDIF

          IF VAL(STR(nVlr_Tot,15,2)) # 0
             lMuda_Dt = .F.
             IF  "SANTISTA" $ UPPER(SM0->M0_NOME)     && LAB 24.07.00

             ELSE                                       && LAB 24.07.00
             IF nVlr_Tot > 0
                // PR200_GrvPRV(nVlr_Tot,"501",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"501",dData_Con," ",dData_Con,EC2->EC2_MOEDA,nTaxa_A) && LAB 02.03.99
                PR200_GrvPRV(nVlr_Tot,"501",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"501",dData_Con," ",dData_Con,EC2->EC2_MOEDA,nTaxa_B) && LAB 02.03.99
                If l3M .AND. AllTrim(EC5->EC5_IDENTC) $ "7/8"                
                   // PR200_GrvPRV(nVlr_Tot,"354",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"354",dData_Con," ",dData_Con,EC2->EC2_MOEDA,nTaxa_A) && VI 18/12/00
                   PR200_GrvPRV(nVlr_Tot,"354",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"354",dData_Con," ",dData_Con,EC2->EC2_MOEDA,nTaxa_B) && VI 18/12/00
                EndIf
             ELSE
                // PR200_GrvPRV(nVlr_Tot,"504",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"504",dData_Con," ",dData_Con,EC2->EC2_MOEDA,nTaxa_A) && LAB 02.03.99
                PR200_GrvPRV(nVlr_Tot,"504",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"504",dData_Con," ",dData_Con,EC2->EC2_MOEDA,nTaxa_B) && LAB 02.03.99
                If l3M .AND. AllTrim(EC5->EC5_IDENTC) $ "7/8"                                
                   // PR200_GrvPRV(nVlr_Tot,"355",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"355",dData_Con," ",dData_Con,EC2->EC2_MOEDA,nTaxa_A) && LAB 02.03.99
                   PR200_GrvPRV(nVlr_Tot,"355",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"355",dData_Con," ",dData_Con,EC2->EC2_MOEDA,nTaxa_B) && LAB 02.03.99
                EndIf
             ENDIF
          ENDIF
       ENDIF
       ENDIF

   NEXT

   EC5->(DBSKIP())
ENDDO

Procregua(nTot5)
Pr999Men(STR0076) //"Lendo Invoices (Contabilidade)"

EC5->(DBSETORDER(4))
EC5->(DBSEEK(cFilEC5))

DO WHILE ! EC5->(EOF()) .AND. EMPTY(ALLTRIM(EC5->EC5_VCFANO+EC5->EC5_VCFMES)) .AND. cFilEC5=EC5->EC5_FILIAL     

   lRefresh:=.t.   
   IncProc(STR0079+EC5->EC5_INVOIC) //"Invoice: "
   IF EC5->EC5_AMOS $ cSim
      EC5->(DBSKIP())
      LOOP
   ENDIF
   EC9->(DBSETORDER(1))
   IF ! EC9->(DBSEEK(cFilEC9+EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC))
      EC5->(DBSKIP())
      LOOP
   ENDIF

   nVlr_reais:=nPag_Ctb_M:=nVC_aposDI:=nPag_Abe_M:=nPag_Abe_R:=n201_Abe_R:=nVC_prov:=0   && LAB 24.07.00
   nSdo_Ant_M := EC5->EC5_FOB_TO
   lProcessa  := .F.
   dData_Ctb  := dData_Con
   dDt_UltOc  := dData_Con
   lGera_503  := .F.
   l201_Cont  := .T.
   lTem_DI    := .F.               && nova rotina abaixo
   lTem_DI2   := .F.
   lTem_PG    := .F.
   nSoma603   := 0
   IF EasyEntryPoint("ECOPR999") // Nick 02/06/06
   	EXECBLOCK("ECOPR999",.F.,.F.,"LTEM_DI")
   ENDIF   

   DO WHILE ! EC9->(EOF()) .AND. EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC = EC9->EC9_FORN+EC9->EC9_INVOIC+EC9->EC9_IDENTC .AND. cFilEC9=EC9->EC9_FILIAL
      lRefresh:=.t.


      IF EC9->EC9_ID_CAM = "101"
         lProcessa := .T.
         dData_Ctb := EC9->EC9_DTCONT
         dDt_UltOc := EC9->EC9_DTCONT
      ENDIF

      IF EC9->EC9_ID_CAM $ "501/504"
         dData_Ctb := EC9->EC9_DTCONT
      ENDIF

      IF EC9->EC9_ID_CAM = "201"     && testa para poder gerar 4.01/5.06/5.07 AGFA
         lTem_DI   := .T.
         lTem_DI2:= .T.
         dDt_DI  := EC9->EC9_DTCONT // VI 08/08/01 P/ a passagem da VC N.R. para VC R.
         nVL_DI  := EC9->EC9_VALOR  // VI 08/08/01 P/ a passagem da VC N.R. para VC R.
      ENDIF

      IF EC9->EC9_ID_CAM = "201" .AND. (VAL(EC9->EC9_NR_CON) = 9999 .OR. VAL(EC9->EC9_NR_CON) = (nNR_Cont+1) .OR. VAL(EC9->EC9_NR_CON) = 0)
         l201_Cont := .F.
         n201_Abe_R:= n201_Abe_R + EC9->EC9_VALOR
         dDt_UltOc := EC9->EC9_DTCONT
      ENDIF

      IF EC9->EC9_ID_CAM = "603" // VI 08/08/01 P/ a passagem da VC N.R. para VC R.
         nSoma603+=EC9->EC9_VL_MOE
         If nSoma603 = EC5->EC5_FOB_TO
            lTem_PG := .T.
         EndIf
         dDt_PG  := EC9->EC9_DTCONT
         nVL_PG  := EC9->EC9_VALOR
         nTx_PG  := EC9->EC9_PARIDA
      ENDIF

      EC9->(DBSKIP())
   ENDDO

   /*
      RMD - 23/03/09 - Passa a utilizar o índice 2 (EC9_FILIAL+EC9_FORN+EC9_INVOIC+EC9_IDENTC+EC9_ID_CAM+DTOS(EC9_DTCONT)) 
      pois ele não contém o campo 'EC9_DT_LAN', que é atualizado no loop abaixo. Quando utilizado o índice 1, ao atualizar 
      o campo, o registro era desposicionado, o que poderia acarretar em duplicidade na contabilização.
   */
   //EC9->(DBSETORDER(1))
   EC9->(DBSETORDER(2))

   IF ! EC9->(DBSEEK(cFilEC9+EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC))
      EC5->(DBSKIP())
      LOOP
   ENDIF

** nao deveria ser do while pois so' ha' um lancamento a ser feito ??
   nVCReal := 0
   dData201:=cTod('')
   DO WHILE ! EC9->(EOF()) .AND. EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC = EC9->EC9_FORN+EC9->EC9_INVOIC+EC9->EC9_IDENTC .AND. EC9->EC9_FILIAL=cFilEC9
      lRefresh:=.t.

      nEC9DTCONT := Val(StrZero(Year(EC9->EC9_DTCONT),4,0)+StrZero(Month(EC9->EC9_DTCONT),2,0))

      IF EC9->EC9_ID_CAMP $ "201" .And. Val(EC9->EC9_NR_CON) # 0 .and. Val(EC9->EC9_NR_CON) # 9999
         dData201:= EC9->EC9_DTCONT
      ENDIF

      nData201 := Val(StrZero(Year(dData201),4,0)+StrZero(Month(dData201),2,0))

      /* AAF 28/04/09 - Retirado devido a problema com realizacao de variacao cambial na Pfizer.
      IF EC9->EC9_ID_CAMP $ "502/503/505" .And. ! Empty(dData201) .And. nEC9DTCONT >= nData201
         If !EC9->EC9_BLOQ                       
            nVCReal += EC9->EC9_VALOR
         ENDIF   
      ENDIF                   

      IF EC9->EC9_ID_CAMP $ "501/504" .And. ! Empty(dData201) .And. nEC9DTCONT = nData201 
         If !EC9->EC9_BLOQ                       
            nVCReal -= EC9->EC9_VALOR
         ENDIF   
      ENDIF
      */

      IF EC5->EC5_CD_PGT = "1"
         IF EC9->EC9_ID_CAM = "602" .AND. (VAL(EC9->EC9_NR_CON) = 0 .OR. VAL(EC9->EC9_NR_CON) = 9999)
            EC9->(DBSKIP())
            TRecno = EC9->(RECNO())
            EC9->(DBSKIP(-1))
            EC8->(DBSETORDER(2))
            IF EC8->(DBSEEK(cFilEC8+EC9->EC9_FORN+EC9->EC9_INVOIC+EC9->EC9_IDENTC))
               Reclock('EC9',.F.)
               EC9->EC9_NR_CON := STRZERO(IF(cPrv_Efe="2",(nNR_Cont+1),9999),4,0)
               EC9->EC9_DT_LAN := dData_Con
               EC9->(MSUNLOCK())

               lMuda_Dt = .F.
               PR200_GrvPRV(EC9->EC9_VALOR,EC9->EC9_ID_CAM,EC9->EC9_FORN+EC9->EC9_INVOIC+EC9->EC9_IDENTC,EC5->EC5_HAWB,EC9->EC9_ID_CAM,PR200VerDT(EC9->EC9_DTCONT)," ",EC9->EC9_DTCONT,EC5->EC5_MOE_FO,EC9->EC9_PARIDA) && LAB 02.03.99
               nPag_Abe_R = nPag_Abe_R + EC9->EC9_VALOR
               dData_Ctb  = EC9->EC9_DTCONT
               dDt_UltOc := EC9->EC9_DTCONT
               EC9->(DBGOTO(TRecno))
               LOOP
            ENDIF
         ENDIF
      ELSE
         IF EC9->EC9_ID_CAM $ "502/503/505/506/507"
            lProcessa := .T.
            dData_Ctb := EC9->EC9_DTCONT
            dDt_UltOc := EC9->EC9_DTCONT
         ENDIF

         IF EC9->EC9_ID_CAM $ "603/613/620/622/610"
            IF VAL(EC9->EC9_NR_CON) = 0 .OR. VAL(EC9->EC9_NR_CON) = 9999
               EC9->(DBSKIP())
               TRecno := EC9->(RECNO())
               EC9->(DBSKIP(-1))
               EC8->(DBSETORDER(2))
               EC8->(DBSEEK(cFilEC8+EC9->EC9_FORN+EC9->EC9_INVOIC+EC9->EC9_IDENTC))
               IF ! EC8->(EOF())
                  Reclock('EC9',.F.)
                  EC9->EC9_NR_CON := STRZERO(IF(cPrv_Efe="2",(nNR_Cont+1),9999),4,0)
                  EC9->EC9_DT_LAN := dData_Con
                  EC9->(MSUNLOCK())

                  lMuda_Dt   := .F.
                  nDi_NumAtu := SPACE(10)
                  IF "AGFA" $ UPPER(SM0->M0_NOME) .AND. EC9->EC9_ID_CAM $ "603/613/610" .AND. lTem_DI     && sera' gerado junto com variacao 5.06 ou 5.07
                  ELSE
                     cLoja := If(SWB->(FieldPos("WB_LOJA"))>0,Posicione("SA2",1,xFilial("SA2")+EC9->EC9_FORN,"A2_LOJA"),"") //FSM - 24/10/2012
                     SWB->(dbSeek(xFilial("SWB")+EC5->EC5_HAWB+"D"+EC9->EC9_INVOIC+EC9->EC9_FORN+cLoja+EC9->EC9_SEQ))
                     
                     PR200_GrvPRV(EC9->EC9_VALOR,EC9->EC9_ID_CAM,EC9->EC9_FORN+EC9->EC9_INVOIC+EC9->EC9_IDENTC,EC5->EC5_HAWB,EC9->EC9_ID_CAM,PR200VerDT(EC9->EC9_DTCONT)," ",EC9->EC9_DTCONT,EC5->EC5_MOE_FO,EC9->EC9_PARIDA,,,SWB->WB_BANCO,SWB->WB_AGENCIA,SWB->WB_CONTA) && LAB 02.03.99
                  ENDIF
                  nPag_Abe_R = nPag_Abe_R + EC9->EC9_VALOR
                  nPag_Abe_M = nPag_Abe_M + EC9->EC9_VL_MOE
                  dData_Pag  = EC9->EC9_DTCONT
                  IF EC9->EC9_ID_CAM $ "603/613"
                     lGera_503 = .T.
                  ENDIF
                  EC9->(DBGOTO(TRecno))
                  LOOP
               ENDIF
            ELSE
               nPag_Ctb_M = nPag_Ctb_M + EC9->EC9_VL_MOE
            ENDIF
         ENDIF
      ENDIF

      nVlr_reais = nVlr_reais + (EC9->EC9_VALOR * IF(LEFT(EC9->EC9_ID_CAM,1) = "6",-1,1))

      IF  EC9->EC9_ID_CAMP $ "506/507"   && Variacao cambial apos a D.I. para AGFA
          nVC_aposDI =  nVC_aposDI + EC9->EC9_VALOR
      ENDIF

      IF  LEFT(EC9->EC9_ID_CAMP,1) == "5" .OR. EC9->EC9_ID_CAMP == "201"   && LAB 24.07.00 Variacao cambial nao realizada (provisao) 
          nVC_prov =  nVC_prov + EC9->EC9_VALOR
      ENDIF

      EC9->(DBSKIP())
   ENDDO
   
   IF lVCReal
      if (!lTem_DI2 .AND. lTem_PG) 
         nRegAuxEC4:=EC4->(RECNO())
         if EC5->EC5_HAWB+EC5->EC5_IDENTC # EC4->EC4_HAWB+EC4->EC4_IDENTC
            nOrdAux:=EC4->(INDEXORD())
            If nOrdAux # 2
               EC4->(DBSETORDER(2))
            EndIf
            EC4->(DBSEEK(cFilEC4+'0000'+"201"+EC5->EC5_HAWB+EC5->EC5_FORN+EC5->EC5_MOE_FO+EC5->EC5_IDENTC))
            If nOrdAux # EC4->(INDEXORD())
               EC4->(DBSETORDER(nOrdAux))
            EndIf
         EndIF
         If EC4->(EOF())
            lTem_DI2 := .F.
         Else
            lTem_DI2 := .T.
         EndIf
         EC4->(DBGOTO(nRegAuxEC4))
      EndIf
   EndIf

   IF EC5->EC5_CD_PGT = "1"
      IF lProcessa
         MReal_Ant := VAL(STR(nSdo_Ant_M * BuscaTxECO(EC5->EC5_MOE_FO,EC5->EC5_DT_EMI),15,2))
         nVlr_Tot  := nPag_Abe_R - MReal_Ant - n201_Abe_R  && VARIACAO
         nVlr_Tot  := VAL(STR(nVlr_Tot,15,2))
         IF nVlr_Tot # 0
            lMuda_Dt = .F.
            IF nVlr_Tot > 0
               PR200_GrvPRV(nVlr_Tot,"701",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"701",PR200VerDT(dData_Ctb)," ",PR200VerDT(dData_Ctb),EC5->EC5_MOE_FO,BuscaTxECO(EC5->EC5_MOE_FO,EC5->EC5_DT_EMI))   && LAB 02.03.99
               PR200_VCFGRV(nVlr_Tot,"701",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,SPACE(37),"701",PR200VerDT(dData_Ctb)," ")
            ELSE
               PR200_GrvPRV(nVlr_Tot,"702",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"702",PR200VerDT(dData_Ctb)," ",PR200VerDT(dData_Ctb),EC5->EC5_MOE_FO,BuscaTxECO(EC5->EC5_MOE_FO,EC5->EC5_DT_EMI))   && LAB 02.03.99
               PR200_VCFGRV(nVlr_Tot,"702",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,SPACE(37),"702",PR200VerDT(dData_Ctb)," ")
            ENDIF
         ENDIF
      ENDIF
   ELSE
      IF lProcessa
         IF nPag_Abe_R = 0
********    apura v.c. correta no mes sem pagto no mes
            MReal_Ant := VAL(STR((nSdo_Ant_M - nPag_Ctb_M) * BuscaTxECO(EC5->EC5_MOE_FO,PR200VerDT(dData_Ctb)),15,2))
            MReal_Atu := VAL(STR((nSdo_Ant_M - nPag_Ctb_M) * BuscaTxECO(EC5->EC5_MOE_FO,dData_Con),15,2))
            nVlr_Tot  := VAL(STR(MReal_Atu - nVlr_reais,15,2))
            
            nVC_prov = nVC_prov + nVlr_Tot      && VI 08/08/01

            IF  "CIBIE" $ UPPER(SM0->M0_NOME) .AND. EC5->EC5_MOE_FO # "US$"    && LAB 18.06.99
                MUSD_Ant := VAL(STR((nSdo_Ant_M - nPag_Ctb_M) * BuscaTxECO(EC5->EC5_MOE_FO,PR200VerDT(dData_Ctb)) / BuscaTxECO("US$",PR200VerDT(dData_Ctb)),15,2))
                MUSD_Atu := VAL(STR((nSdo_Ant_M - nPag_Ctb_M) * BuscaTxECO(EC5->EC5_MOE_FO,dData_Con) / BuscaTxECO("US$",dData_Con),15,2))
                nUSD_Dif := VAL(STR(MUSD_Atu - MUSD_Ant,15,2))
                IF nUSD_Dif <> 0      && LAB 26.05.00
                   IF nUSD_Dif > 0
                      PR200_GrvPRV(nUSD_Dif,"803",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"803",dData_Con," ",dData_Con,EC5->EC5_MOE_FO,BuscaTxECO(EC5->EC5_MOE_FO,dData_Con))
                   ELSE
                      PR200_GrvPRV(nUSD_Dif,"805",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"805",dData_Con," ",dData_Con,EC5->EC5_MOE_FO,BuscaTxECO(EC5->EC5_MOE_FO,dData_Con))
                   ENDIF
                ENDIF
            ENDIF

            nDi_NumAtu = SPACE(10)
            IF VAL(STR(nVlr_Tot,15,2)) # 0
               lMuda_Dt = .F.
               IF nVlr_Tot > 0
                  IF  "AGFA" $ UPPER(SM0->M0_NOME) .AND. lTem_DI
                      PR200_GrvPRV(nVlr_Tot,"506",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"506",dData_Con," ",dData_Con,EC5->EC5_MOE_FO,BuscaTxECO(EC5->EC5_MOE_FO,dData_Con))
                      PR200_VCFGRV(nVlr_Tot,"506",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,SPACE(37),"506",dData_Con," ")
                  ELSE
                      PR200_GrvPRV(nVlr_Tot,IF(lGera_503,"503","502"),EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,IF(lGera_503,"503","502"),dData_Con," ",dData_Con,EC5->EC5_MOE_FO,BuscaTxECO(EC5->EC5_MOE_FO,dData_Con))
                      PR200_VCFGRV(nVlr_Tot,IF(lGera_503,"503","502"),EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,SPACE(37),IF(lGera_503,"503","502"),dData_Con," ")
                      nVCReal += nVlr_Tot
                  ENDIF
               ELSE
                  IF  "AGFA" $ UPPER(SM0->M0_NOME) .AND. lTem_DI
                      PR200_GrvPRV(nVlr_Tot,"507",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"507",dData_Con," ",dData_Con,EC5->EC5_MOE_FO,BuscaTxECO(EC5->EC5_MOE_FO,dData_Con))
                      PR200_VCFGRV(nVlr_Tot,"507",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,SPACE(37),"507",dData_Con," ")
                  ELSE
                      PR200_GrvPRV(nVlr_Tot,"505",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"505",dData_Con," ",dData_Con,EC5->EC5_MOE_FO,BuscaTxECO(EC5->EC5_MOE_FO,dData_Con))
                      PR200_VCFGRV(nVlr_Tot,"505",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,SPACE(37),"505",dData_Con," ")
                      nVCReal += nVlr_Tot
                  ENDIF
               ENDIF
            ENDIF
         ELSE
********    apura v.c. correta no mes com pagto no mes
            MSaldo_Atual = VAL(STR(nSdo_Ant_M - nPag_Ctb_M,15,2))
            IF MSaldo_Atual - VAL(STR(nPag_Abe_M,15,2)) < 10 .AND. ;    && processar pagtos totais "errados"
               MSaldo_Atual - VAL(STR(nPag_Abe_M,15,2)) > -10
               MVariacao = VAL(STR(nPag_Abe_R - nVlr_reais,15,2))
               IF VAL(STR(MVariacao,15,2)) # 0
                  lMuda_Dt = .F.
                  IF MVariacao > 0
                     IF  "AGFA" $ UPPER(SM0->M0_NOME) .AND. lTem_DI
                         PR200_GrvPRV(MVariacao,"506",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"506",PR200VerDT(dData_Pag)," ",dData_Pag,EC5->EC5_MOE_FO,BuscaTxECO(EC5->EC5_MOE_FO,dData_Pag))
                         PR200_VCFGRV(MVariacao,"506",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,SPACE(37),"506",PR200VerDT(dData_Pag)," ")
                         nVC_aposDI = nVC_aposDI + MVariacao
                     ELSE
                         PR200_GrvPRV(MVariacao,IF(lGera_503,"503","502"),EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,IF(lGera_503,"503","502"),PR200VerDT(dData_Pag)," ",dData_Pag,EC5->EC5_MOE_FO,nTx_Pg) // Nick 19/09/06 BuscaTxECO(EC5->EC5_MOE_FO,dData_Pag)
                         PR200_VCFGRV(MVariacao,IF(lGera_503,"503","502"),EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,SPACE(37),IF(lGera_503,"503","502"),PR200VerDT(dData_Pag)," ")
                         nVlr_reais = nVlr_reais + MVariacao
                         nVCReal += MVariacao
                     ENDIF
                  ELSE
                     IF  "AGFA" $ UPPER(SM0->M0_NOME) .AND. lTem_DI
                         PR200_GrvPRV(MVariacao,"507",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"507",PR200VerDT(dData_Pag)," ",dData_Pag,EC5->EC5_MOE_FO,BuscaTxECO(EC5->EC5_MOE_FO,dData_Pag))
                         PR200_VCFGRV(MVariacao,"507",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,SPACE(37),"507",PR200VerDT(dData_Pag)," ")
                         nVC_aposDI = nVC_aposDI + MVariacao
                     ELSE
                         PR200_GrvPRV(MVariacao,"505",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"505",PR200VerDT(dData_Pag)," ",dData_Pag,EC5->EC5_MOE_FO,nTx_PG) // Nick 19/09/06  BuscaTxECO(EC5->EC5_MOE_FO,dData_Pag)
                         PR200_VCFGRV(MVariacao,"505",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,SPACE(37),"505",PR200VerDT(dData_Pag)," ")
                         nVCReal += MVariacao
                         nVlr_reais = nVlr_reais + MVariacao
                     ENDIF
                  ENDIF
               ENDIF

               IF  ! lTem_DI .AND. cPrv_Efe = "2" .AND. EC5->EC5_T_D # "E"   && LAB 24.07.00  
                      Reclock('EC5',.F.)
                      EC5->EC5_T_D    := "D"   && indica divisas, idem a transito mas j  pago
                      EC5->EC5_T_D_NR := STRZERO(nNR_Cont+1,4,0)
                      EC5->(MSUNLOCK())
               ENDIF

               IF  "AGFA" $ UPPER(SM0->M0_NOME) .AND. ! lTem_DI              && LAB 24.07.00 
                   PR200_GrvPRV(nVlr_reais,"401",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"401",PR200VerDT(dData_Pag)," ",dData_Pag,EC5->EC5_MOE_FO,BuscaTxECO(EC5->EC5_MOE_FO,dData_Pag))
               ENDIF
               IF  "AGFA" $ UPPER(SM0->M0_NOME) .AND. lTem_DI
                   IF nVC_aposDI > 0
                      MVariacao = nPag_Abe_R - nVC_aposDI
                      PR200_GrvPRV(MVariacao ,"603",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"603",PR200VerDT(dData_Pag)," ",dData_Pag,EC5->EC5_MOE_FO,BuscaTxECO(EC5->EC5_MOE_FO,dData_Pag))
                      PR200_GrvPRV(nVC_aposDI,"653",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"653",PR200VerDT(dData_Pag)," ",dData_Pag,EC5->EC5_MOE_FO,BuscaTxECO(EC5->EC5_MOE_FO,dData_Pag))
                   ELSE
                      MVariacao = nPag_Abe_R - nVC_aposDI && LAB 31.05.99
                      PR200_GrvPRV(MVariacao ,"603",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"603",PR200VerDT(dData_Pag)," ",dData_Pag,EC5->EC5_MOE_FO,BuscaTxECO(EC5->EC5_MOE_FO,dData_Pag))
                      PR200_GrvPRV(nVC_aposDI,"654",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"654",PR200VerDT(dData_Pag)," ",dData_Pag,EC5->EC5_MOE_FO,BuscaTxECO(EC5->EC5_MOE_FO,dData_Pag))   && LAB 31.05.99
                   ENDIF
               ENDIF

               nVC_prov = nVC_prov + MVariacao      && LAB 24.07.00

//             IF  lVCReal .AND. lTem_DI .AND. lTem_PG && LAB 24.07.00 // VI 08/08/01
//                 IF nVC_prov > 0
//                    PR200_GrvPRV(nVC_prov ,"657",EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"657",PR200VerDT(dData_Pag)," ",dData_Pag)
//                 ELSE
//                    PR200_GrvPRV(nVC_prov ,"658",EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"657",PR200VerDT(dData_Pag)," ",dData_Pag)
//                 ENDIF
//             ENDIF                             
               APUVCREAL(nVCReal,EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,dData_Pag,EC5->EC5_MOE_FO)
            ELSE

********       trata pagtos parciais com v.c. no pagto e sobre o saldo

               MSdo_Ctb_R = nPag_Abe_R
               MSdo_Ant_R = VAL(STR(nPag_Abe_M * TaxaDi_Normal(),15,2))   && usa tx do dDt_UltOc ou tx D.I. se 201 no mes
               MVariacao  = VAL(STR(MSdo_Ctb_R - MSdo_Ant_R,15,2))

               IF VAL(STR(MVariacao,15,2)) # 0
                  lMuda_Dt = .F.
                  IF MVariacao > 0
                     IF  "AGFA" $ UPPER(SM0->M0_NOME) .AND. lTem_DI
                         PR200_GrvPRV(MVariacao,"506",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"506",PR200VerDT(dData_Pag)," ",dData_Pag,EC5->EC5_MOE_FO,BuscaTxECO(EC5->EC5_MOE_FO,dData_Pag))
                         PR200_VCFGRV(MVariacao,"506",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,SPACE(37),"506",PR200VerDT(dData_Pag)," ")
                         nVC_aposDI = nVC_aposDI + MVariacao
                     ELSE
                         PR200_GrvPRV(MVariacao,IF(lGera_503,"503","502"),EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,IF(lGera_503,"503","502"),PR200VerDT(dData_Pag)," ",dData_Pag,EC5->EC5_MOE_FO,BuscaTxECO(EC5->EC5_MOE_FO,dData_Pag))
                         PR200_VCFGRV(MVariacao,IF(lGera_503,"503","502"),EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,SPACE(37),IF(lGera_503,"503","502"),PR200VerDT(dData_Pag)," ")
                         nVlr_reais = nVlr_reais + MVariacao
                         nVCReal += MVariacao
                     ENDIF
                  ELSE
                     IF  "AGFA" $ UPPER(SM0->M0_NOME) .AND. lTem_DI
                         PR200_GrvPRV(MVariacao,"507",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"507",PR200VerDT(dData_Pag)," ",dData_Pag,EC5->EC5_MOE_FO,BuscaTxECO(EC5->EC5_MOE_FO,dData_Pag))
                         PR200_VCFGRV(MVariacao,"507",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,SPACE(37),"507",PR200VerDT(dData_Pag)," ")
                         nVC_aposDI = nVC_aposDI + MVariacao
                     ELSE
                         PR200_GrvPRV(MVariacao,"505",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"505",PR200VerDT(dData_Pag)," ",dData_Pag,EC5->EC5_MOE_FO,BuscaTxECO(EC5->EC5_MOE_FO,dData_Pag))
                         PR200_VCFGRV(MVariacao,"505",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,SPACE(37),"505",PR200VerDT(dData_Pag)," ")
                         nVlr_reais = nVlr_reais + MVariacao
                         nVCReal += MVariacao
                     ENDIF
                  ENDIF
               ENDIF

               IF  ! lTem_DI .AND. cPrv_Efe = "2" .AND. EC5->EC5_T_D # "E"   && LAB 24.07.00
                      Reclock('EC5',.F.)
                      EC5->EC5_T_D    := "D"   && indica divisas, idem a transito mas j  pago
                      EC5->EC5_T_D_NR := STRZERO(nNR_Cont+1,4,0)
                      EC5->(MSUNLOCK())
               ENDIF

               IF  "AGFA" $ UPPER(SM0->M0_NOME) .AND. ! lTem_DI              && LAB 24.07.00
                   PR200_GrvPRV(nVlr_reais,"401",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"401",PR200VerDT(dData_Pag)," ",dData_Pag,EC5->EC5_MOE_FO,BuscaTxECO(EC5->EC5_MOE_FO,dData_Con))
               ENDIF
               IF  "AGFA" $ UPPER(SM0->M0_NOME) .AND. lTem_DI
                   IF nVC_aposDI > 0
                      MVariacao = nPag_Abe_R - nVC_aposDI
                      PR200_GrvPRV(MVariacao ,"603",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"603",PR200VerDT(dData_Pag)," ",dData_Pag,EC5->EC5_MOE_FO,BuscaTxECO(EC5->EC5_MOE_FO,dData_Pag))
                      PR200_GrvPRV(nVC_aposDI,"653",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"653",PR200VerDT(dData_Pag)," ",dData_Pag,EC5->EC5_MOE_FO,BuscaTxECO(EC5->EC5_MOE_FO,dData_Pag))
                   ELSE
                      MVariacao = nPag_Abe_R - nVC_aposDI       && LAB 31.05.99
                      PR200_GrvPRV(MVariacao ,"603",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"603",PR200VerDT(dData_Pag)," ",dData_Pag,EC5->EC5_MOE_FO,BuscaTxECO(EC5->EC5_MOE_FO,dData_Pag))
                      PR200_GrvPRV(nVC_aposDI,"654",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"654",PR200VerDT(dData_Pag)," ",dData_Pag,EC5->EC5_MOE_FO,BuscaTxECO(EC5->EC5_MOE_FO,dData_Pag))   && LAB 31.05.99
                   ENDIF
               ENDIF

               nVC_prov = nVC_prov + MVariacao      && LAB 24.07.00

//             IF  lVCReal .AND. lTem_DI .AND. lTem_PG && LAB 24.07.00 // VI 08/08/01
//                 IF nVC_prov > 0
//                    PR200_GrvPRV(nVC_prov ,"657",EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"657",PR200VerDT(dData_Pag)," ",dData_Pag)
//                 ELSE
//                    PR200_GrvPRV(nVC_prov ,"658",EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"657",PR200VerDT(dData_Pag)," ",dData_Pag)
//                 ENDIF
//             ENDIF
               APUVCREAL(nVCReal,EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,dData_Pag,EC5->EC5_MOE_FO)
********       aqui comeca o controle do saldo ainda nao pago e respectiva v.cambial LAB 28.06.00

               MSdo_Ctb_R = VAL(STR(((MSaldo_Atual - nPag_Abe_M) * BuscaTxECO(EC5->EC5_MOE_FO,dData_Con)),15,2))
               MSdo_Ant_R = VAL(STR((MSaldo_Atual - nPag_Abe_M) * TaxaDi_Normal(),15,2))
               MVariacao  = VAL(STR(MSdo_Ctb_R - MSdo_Ant_R,15,2))
               IF VAL(STR(MVariacao,15,2)) # 0
                  lMuda_Dt = .F.
                  IF MVariacao > 0
                     IF  "AGFA" $ UPPER(SM0->M0_NOME) .AND. lTem_DI
                         PR200_GrvPRV(MVariacao,"506",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"506",PR200VerDT(dData_Con)," ",dData_Con,EC5->EC5_MOE_FO,BuscaTxECO(EC5->EC5_MOE_FO,dData_Con))
                         PR200_VCFGRV(MVariacao,"506",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,SPACE(37),"506",PR200VerDT(dData_Con)," ")
                         nVC_aposDI = nVC_aposDI + MVariacao
                     ELSE
                         PR200_GrvPRV(MVariacao,IF(lGera_503,"503","502"),EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,IF(lGera_503,"503","502"),PR200VerDT(dData_Con)," ",dData_Con,EC5->EC5_MOE_FO,BuscaTxECO(EC5->EC5_MOE_FO,dData_Con))
                         PR200_VCFGRV(MVariacao,IF(lGera_503,"503","502"),EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,SPACE(37),IF(lGera_503,"503","502"),PR200VerDT(dData_Con)," ")
                         nVlr_reais = nVlr_reais + MVariacao
                         nVCReal += MVariacao
                     ENDIF
                  ELSE
                     IF  "AGFA" $ UPPER(SM0->M0_NOME) .AND. lTem_DI
                         PR200_GrvPRV(MVariacao,"507",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"507",PR200VerDT(dData_Con)," ",dData_Con,EC5->EC5_MOE_FO,BuscaTxECO(EC5->EC5_MOE_FO,dData_Con))
                         PR200_VCFGRV(MVariacao,"507",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,SPACE(37),"507",PR200VerDT(dData_Con)," ")
                         nVC_aposDI = nVC_aposDI + MVariacao
                     ELSE
                         PR200_GrvPRV(MVariacao,"505",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,EC5->EC5_HAWB,"505",PR200VerDT(dData_Con)," ",dData_Con,EC5->EC5_MOE_FO,BuscaTxECO(EC5->EC5_MOE_FO,dData_Con))
                         PR200_VCFGRV(MVariacao,"505",EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC,SPACE(37),"505",PR200VerDT(dData_Con)," ")
                         nVlr_reais = nVlr_reais + MVariacao
                         nVCReal += MVariacao
                     ENDIF
                  ENDIF
               ENDIF
            ENDIF
         ENDIF
      ENDIF
   ENDIF
   EC5->(DBSKIP())
ENDDO

// Grava arquivo ECE no arquivo ECA e EC7
If lExisteECE
   ProcRegua(nTot6)
   Pr999Men(STR0091)    //"Lendo Processos Estornados"

   nIndexAnt := ECE->(IndexOrd())
   ECE->(DbSetOrder(2))

   If !ECE->(dbSeek(cFilECE+TIPO_DO_MODULO+'0000')) //AAF 08/01/08
      ECE->(dbSeek(cFilECE+Space(Len(ECE->ECE_TPMODU))+'0000')) // Nick 18/10/06
   EndIf
   
   Do While ECE->(!EOF()) .And. ECE->ECE_FILIAL == cFilECE .And. Val(ECE->ECE_NR_CON) == 0
      
		IncProc(STR0075+ECE->ECE_HAWB) //"Processo: "
						
		nDi_NumAtu := ECE->ECE_DI_NUM        
		PR200_GrvPRV(ECE->ECE_VALOR,ECE->ECE_ID_CAM,ECE->ECE_FORN+ECE->ECE_INVOIC,ECE->ECE_HAWB+Space(nTamForn+nTamMoeda)+ECE->ECE_IDENTC,ECE->ECE_LINK,PR200VerDT(ECE->ECE_DT_EST)," ",ECE->ECE_DT_EST,ECE->ECE_MOE_FO,0)
		 
   		ECA->(Reclock('ECA',.F.))
   		ECA->ECA_DESCAM := "EST. "+ECA->ECA_DESCAM
   		ECA->ECA_CTA_DB := ALLTRIM(ECE->ECE_CDBEST)   // Conta de estorno correspondente ao evento
        ECA->ECA_CTA_CR := ALLTRIM(ECE->ECE_CCREST)   
   		ECA->(MsUnlock())
   			
   		EC7->(Reclock('EC7',.F.))
   		EC7->EC7_COM_HI := "EST. "+EC7->EC7_COM_HI
   		EC7->EC7_CTA_DB := ALLTRIM(ECE->ECE_CDBEST)   // Conta de estorno correspondente ao evento
        EC7->EC7_CTA_CR := ALLTRIM(ECE->ECE_CCREST)   
   		EC7->(MsUnlock())
   			   			 	 			   
        ECE->(DbSkip())                         
						
 	    If cPrv_Efe = "2"      // Efetivacao      
           nRecnoECE := ECE->(RECNO())
           ECE->(DBSKIP(-1))
           Reclock('ECE',.F.)
           ECE->ECE_NR_CON := STRZERO(nNR_Cont+1,4,0)
           ECE->(MSUNLOCK())
           ECE->(DBGOTO(nRecnoECE))
        Endif      
   Enddo

   // Ordem anterior
   ECE->(DBSetOrder(nIndexAnt))
Endif   
DbSelectArea("ECA")
IF cPrv_Efe = "1"
   SETMV('MV_HO_PREV',cHora)
   SETMV('MV_DT_PREV',dDataBase)
   PR300Can_IVC(nNR_Cont+1,.T.)
ELSE

   ProcRegua(If(lExisteECE,nTot7,nTot6))
   Pr999Men(If(lExisteECE,STR0093,STR0093)) //"Lendo DI´s"###"Lendo DI´s"

   
   EC2->(DBSEEK(cFilEC2))      
   DO WHILE ! EC2->(EOF()) .AND. EC2->EC2_FILIAL=cFilEC2
   
      lRefresh:=.t.      
      IncProc(STR0072+EC2->EC2_DI_NUM) //"DI: "
      
      Reclock('EC3',.T.)
      EC3->EC3_FILIAL := xFilial('EC3')
      EC3->EC3_NR_CON := STRZERO(nNR_Cont+1,4,0)
      EC3->EC3_HAWB   := EC2->EC2_HAWB
      EC3->EC3_IDENTC := EC2->EC2_IDENTC
      EC3->EC3_DI_NUM := EC2->EC2_DI_NUM
      EC3->EC3_FIM_CT := EC2->EC2_FIM_CT
      EC3->EC3_MOEDA  := EC2->EC2_MOEDA
      EC3->EC3_FORN   := EC2->EC2_FORN      

      EC3->(MSUNLOCK())
      EC2->(DBSKIP())
   ENDDO

   //AAF 08/10/2012 - Grava o resumo de debito e credito das contas contabeis
   PREIC999TotC()

   // Grava no arquivo EC1 os dados da efetivaçao
   Reclock('EC1',.F.)
   EC1->EC1_OK := "1"
   EC1->EC1_VAL_DB := nGeralDB  //FSM - 24/10/2012
   EC1->EC1_VAL_CR := nGeralCR    //FSM - 24/10/2012
   EC1->(Msunlock())                        

ENDIF
/*
If l3M 
   nOrdAuxECA:=ECA->(INDEXORD())
   ECA->(DBSETORDER(5))
// ECA_FILIAL+ECA_FORN+ECA_INVOIC+ECA_IDENTC+ECA_HAWB+ECA_ID_CAM
   If ECA->(DBSEEK(cFilECA+If(lTemECATPM, "IMPORT", "")+'4884  '+'XX529510       '+'6'+SPACE(9)+'02/CLI381'+SPACE(8)+'201'))
      Reclock('ECA',.F.)
      ECA->(DBDELETE())
      ECA->(MSUNLOCK())
   EndIf
   If ECA->(DBSEEK(cFilECA+If(lTemECATPM, "IMPORT", "")+'4884  '+'XX529510       '+'6'+SPACE(9)+'02/CLI381'+SPACE(8)+'657'))
      Reclock('ECA',.F.)
      ECA->(DBDELETE())
      ECA->(MSUNLOCK())
   EndIf
   If ECA->(DBSEEK(cFilECA+If(lTemECATPM, "IMPORT", "")+'4884  '+'XX529510       '+'6'+SPACE(9)+'02/CLI381'+SPACE(8)+'503'))
      Reclock('ECA',.F.)
      ECA->ECA_VALOR := 3968.95
      ECA->(MSUNLOCK())
   EndIf
   If ECA->(DBSEEK(cFilECA+If(lTemECATPM, "IMPORT", "")+'715   '+'AS39563        '+'7'+SPACE(9)+'02/AEI358'+SPACE(8)+'657'))
      Reclock('ECA',.F.)
      ECA->(DBDELETE())
      ECA->(MSUNLOCK())
   EndIf
   If ECA->(DBSEEK(cFilECA+If(lTemECATPM, "IMPORT", "")+'715   '+'PF71201        '+'8'+SPACE(9)+'02/CLI412'+SPACE(8)+'657'))
      Reclock('ECA',.F.)
      ECA->(DBDELETE())
      ECA->(MSUNLOCK())
   EndIf
   If ECA->(DBSEEK(cFilECA+If(lTemECATPM, "IMPORT", "")+'715   '+'PF83757        '+'8'+SPACE(9)+'02/AEI316'+SPACE(8)+'657'))
      Reclock('ECA',.F.)
      ECA->(DBDELETE())
      ECA->(MSUNLOCK())
   EndIf
   If ECA->(DBSEEK(cFilECA+If(lTemECATPM, "IMPORT", "")+'715   '+'VB46019        '+'8'+SPACE(9)+'02/AEI327'+SPACE(8)+'657'))
      Reclock('ECA',.F.)
      ECA->(DBDELETE())
      ECA->(MSUNLOCK())
   EndIf
   If ECA->(DBSEEK(cFilECA+If(lTemECATPM, "IMPORT", "")+'715   '+'PF22118        '+'6'+SPACE(9)+'02/CLI393'+SPACE(8)+'657'))
      Reclock('ECA',.F.)
      ECA->(DBDELETE())
      ECA->(MSUNLOCK())
   EndIf
   If ECA->(DBSEEK(cFilECA+If(lTemECATPM, "IMPORT", "")+'715   '+'PF71076        '+'8'+SPACE(9)+'02/CLI532'+SPACE(8)+'657'))
      Reclock('ECA',.F.)
      ECA->(DBDELETE())
      ECA->(MSUNLOCK())
   EndIf
   If ECA->(DBSEEK(cFilECA+If(lTemECATPM, "IMPORT", "")+'715   '+'AS33697        '+'6'+SPACE(9)+'02/CLI598'+SPACE(8)+'657'))
      Reclock('ECA',.F.)
      ECA->(DBDELETE())
      ECA->(MSUNLOCK())
   EndIf
   If ECA->(DBSEEK(cFilECA+If(lTemECATPM, "IMPORT", "")+'4361  '+'DDI002948      '+'7'+SPACE(9)+'02/CLI545'+SPACE(8)+'657'))
      Reclock('ECA',.F.)
      ECA->(DBDELETE())
      ECA->(MSUNLOCK())
   EndIf
   ECA->(DBSETORDER(nOrdAuxECA))
   ECA->(DBGOTOP())
EndIf               
*/

Return .T.
*------------------*
Function Grv999EC1()
*------------------*

Reclock('EC1',.T.)
EC1->EC1_FILIAL := xFilial('EC1')
EC1->EC1_NR_CON := STRZERO(nNR_Cont+1,4,0)
EC1->EC1_DT_CON := dData_Con
EC1->EC1_DT_EFE := dDataBase
EC1->EC1_HO_CON := cHora
// EC1->EC1_MESANO := cMesProc
EC1->EC1_MES    := LEFT(cMesProc,2)
EC1->EC1_ANO    := RIGHT(cMesProc,4)		
EC1->EC1_TPMODU := "IMPORT"

EC1->(MSUNLOCK())
             
SETMV('MV_NR_CONT',ALLTRIM(STR(nNR_Cont+1,4,0)))

Return .T.
*------------------*
FUNCTION PR999TXT()
*------------------*

*Controle->CTN_F == "DEGUSSA" - PR999DegussaGera()
*
*"AGFA" $ UPPER(SM0->M0_NOME) - PR999AgfaGera()

If EasyEntryPoint("ECO_CTB")
   ExecBlock("ECO_CTB")
Else
   AvE_Msg(STR0001,1) //"N„o foi encontrado o RDMAKE para gerar o TXT."
   Return .F.
EndIf

If EasyEntryPoint("ECORDPR1")                       
   if ! ExecBlock("ECORDPR1",.F.,.F.,"1")
      Return .F.
   endif
EndIf

IF lTop                                      
  IF (TcSrvType() != "AS/400")
     ApagaECA()
  Else
     AvPAguarde({||PRContaReg(3)},STR0067)   //"Aguarde... Apurando Dados"
     AvProcessa({||ApagaECA()},STR0087) //"Limpando Arquivo da Previa..."
  Endif  
ENDIF 

IF !lTop
  AvPAguarde({||PRContaReg(3)},STR0067)   //"Aguarde... Apurando Dados"
  AvProcessa({||ApagaECA()},STR0087) //"Limpando Arquivo da Previa..."
ENDIF


// ECA->(DBEVAL({||(PR999Inc("Apagando Previa, Proc.: "+ECA->ECA_HAWB),ECA->(Reclock('ECA',.F.)),ECA->(DBDELETE()),ECA->(MSUNLOCK()))},,{||ECA->ECA_FILIAL==cFilECA},,,.T.))
//PACK

RETURN .T.

*-----------------------------*
FUNCTION PR200VerDT(dDataFunc)    && LAB 01.08.01 DESCONTINUADA E SUBSTITUIDA PELA PR200VerDT
*-----------------------------*

IF dDataFunc < dDta_Inic
   lMuda_Dt = .T.
   RETURN dDta_Inic
ENDIF

IF dDataFunc > dDta_Fim
   lMuda_Dt = .T.
   RETURN dData_Con
ELSE
   RETURN dDataFunc
ENDIF

*------------------------*
FUNCTION PR200DtDI(dData)
*------------------------*

IF STRZERO(MONTH(dData),2,0)+ STRZERO(YEAR(dData),4,0) # cMesProc
   IF cPrv_Efe = "2"
      Reclock('EC5',.F.)
      EC5->EC5_DT_CAM := dData_Con
      EC5->(MSUNLOCK())
   ENDIF
   lMuda_Dt = .T.
   RETURN dData_Con
ELSE
   IF cPrv_Efe = "2"
      Reclock('EC5',.F.)
      EC5->EC5_DT_CAM := dData
      EC5->(MSUNLOCK())
   ENDIF
   RETURN dData
ENDIF

*-------------------------------------------------------------------------------------------------------------*
FUNCTION PR200_GrvPRV(PValor,PIdent,/*PForn,*/PInvoice,PHAWB,PLink,PData,PInfo,PData_A,PMoeda,PTaxaUsd,pSeq,PPrPo,cBanco,cAgencia,cConta)  // GFP - 17/04/2011
*-------------------------------------------------------------------------------------------------------------*
Local PForn := ""        // GFP - 17/04/2012

Default cBanco   := ""
Default cAgencia := ""
Default cConta   := ""

lRefresh:=.t.

cForn     := ''
nSubSetor := SPACE(10)
nHawb     := SPACE(nTamHawb)
nIdentct  := SPACE(nTamIdentc)
nMoeda    := SPACE(nTamMoeda)

MNaoUsado = PR200IdentCt(SUBS(PInvoice,(nTamForn+1),nTamInvoic),SUBS(PHawb,1,nTamHawb),,SUBS(PInvoice,1,nTamForn))  && necessaria para achar cForn e nSubSetor

nHawb    := SUBS(PHawb,1,nTamHawb)   && sera' pesquisado mesmo vindo em branco como PHawb
If lExisteECF .And. lExisteECG .And. Len(PHawb) = (nTamHawb+nTamIdentc) 
   nIdentct := SUBS(PHawb,(nTamHawb+1),nTamIdentc)
Else
   nIdentct := SUBS(PHawb,(nTamHawb+nTamForn+nTamMoeda+1),nTamIdentc)
EndIf

nMoeda   := SUBS(PHawb,(nTamHawb+nTamForn+1),nTamMoeda)

IF EMPTY(nIdentct)
   nIdentct := SUBS(PInvoice,(nTamForn+nTamInvoic+1),nTamIdentc)
ENDIF

IF EMPTY(nMoeda)
   nMoeda := PMoeda
ENDIF

PForn := SUBS(PInvoice,1,nTamForn)
PHawb    := SUBS(PHawb,1,nTamHawb)
PInvoice := SUBS(PInvoice,(nTamForn+1),nTamInvoic)

//AAF - 29/09/2012 - Usar a configuração do centro de custo padrão caso não haja cadastro no EC6 para o centro de custo especifico.
If !EC6->(DBSEEK(cFilEC6+"IMPORT"+PLink+nIdentct))
   EC6->(DbSeek(cFilEC6+"IMPORT"+PLink))
EndIf

If EC2->EC2_HAWB # nHawb .Or. EC2->EC2_IDENTC # nIdentct .Or. EC2->EC2_FORN	# PForn  
   EC2->(Dbseek(cFilEC2+nHawb+PForn+PMoeda+nIdentct))
Endif
nDi_NumAtu := EC2->EC2_DI_NUM
cForn      := PForn

// LAB 24.03.00
// MCTA_DEB  = IF(!EMPTY(ALLTRIM(EC6->EC6_CTA_DB)), ALLTRIM(EC6->EC6_CTA_DB),"00")
// MCTA_CRE  = IF(!EMPTY(ALLTRIM(EC6->EC6_CTA_CR)), ALLTRIM(EC6->EC6_CTA_CR),"00")

//AAF - 29/09/2012 - Traduzir as mascaras de conta contabil.
MCTA_DEB := EasyMascCon(EC6->EC6_CTA_DB,PForn,"",/* cImport */,/* cLojaImp */,cBanco,cAgencia,cConta,'IMPORT',PLink) //MCTA_DEB  := ALLTRIM(EC6->EC6_CTA_DB)      && LAB 24.03.00
MCTA_CRE := EasyMascCon(EC6->EC6_CTA_CR,PForn,"",/* cImport */,/* cLojaImp */,cBanco,cAgencia,cConta,'IMPORT',PLink) //MCTA_CRE  := ALLTRIM(EC6->EC6_CTA_CR)      && LAB 24.03.00

MDT_CCAMB := SPACE(08)

DO CASE
   CASE MCTA_DEB = "999999999999999"
        IF SA2->(DBSEEK(cFilSA2+cForn)) .AND. ! EMPTY(ALLTRIM(cForn))
           MCTA_DEB := IF(!EMPTY(ALLTRIM(SA2->A2_CONTAB)), ALLTRIM(SA2->A2_CONTAB),"999999999999999")
        ENDIF

        IF  "SANTISTA" $ UPPER(SM0->M0_NOME) .AND.  LEFT(MCTA_DEB,6) == "236309"     && LAB 11.11.99
            DO  CASE
                CASE VAL(SUBS(EC2->EC2_SUB_SE,4,3)) < 181
                     MCTA_DEB := "204004"
                CASE VAL(SUBS(EC2->EC2_SUB_SE,4,3)) < 361
                     MCTA_DEB := "204301"
            ENDCASE
        ENDIF
   CASE RIGHT(MCTA_DEB,2) = "99" .AND. ! "CIBIE" $ UPPER(SM0->M0_NOME)      && LAB 18.06.99
        MCTA_DEB = SUBS(MCTA_DEB,1,LEN(MCTA_DEB)-2)+STRZERO(VAL(EC2->EC2_DESP)+IF("MERCK"$UPPER(SM0->M0_NOME).OR."M.B."$UPPER(SM0->M0_NOME),2,0),2)
   CASE LEFT(MCTA_DEB,4) = "0361" .AND. "WARNER" $ UPPER(SM0->M0_NOME)      && LAB 11.10.99
        DO  CASE
            CASE EC2->EC2_DESP = "001"
                 MCTA_DEB = MCTA_DEB + "322816"   && 1o DESPACHANTE 
            CASE EC2->EC2_DESP = "003"
                 MCTA_DEB = MCTA_DEB + "321535"   && 3o DESPACHANTE
            CASE EC2->EC2_DESP = "005"
                 MCTA_DEB = MCTA_DEB + "505497"   && 4o DESPACHANTE 
            OTHERWISE
                 MCTA_DEB = MCTA_DEB + "322619"   && 2o DESPACHANTE O + USADO
        ENDCASE
   CASE LEFT(MCTA_DEB,8) = "11201090" .AND. "ABRIL" $ UPPER(SM0->M0_NOME)         && LAB 03.03.00
        MCTA_DEB = SUBS(MCTA_DEB,1,8) + LEFT(EC2->EC2_SUB_SE,1)
        IF  LEFT(EC2->EC2_SUB_SE,1) == "4"       && LAB 09.03.00
            MCTA_DEB = "131010119"
        ENDIF

// CASE "WARNER" $ UPPER(SM0->M0_NOME) .AND. LEFT(MCTA_DEB,4) = "0437" .AND. ! EMPTY(EC2->EC2_SUB_SE)    && LAB 24.07.00
//      MCTA_DEB = ALLTRIM(EC2->EC2_SUB_SE)

   CASE "WARNER" $ UPPER(SM0->M0_NOME)
        IF  LEFT(MCTA_DEB,4) = "0437" .AND. ! EMPTY(EC2->EC2_SUB_SE)    && LAB 24.07.00
            MCTA_DEB = ALLTRIM(EC2->EC2_SUB_SE)
            IF  ! EMPTY(EC2->EC2_CC_EST) .AND. .NOT. PLink $ "101/201/901/902/911/912"    && LAB 24.10.00  
                MCTA_DEB = ALLTRIM(EC2->EC2_CC_EST)
            ENDIF
            IF  MCTA_DEB == "0944.502" .AND. PLink $ "321/322"                  && LAB 11.10.00  
                MCTA_DEB := "509230.3204.01"
            ENDIF
            IF  MCTA_DEB == "0944.501" .AND. PLink $ "321/322"                  && LAB 11.10.00  
                MCTA_DEB := "509220.3204.01"
            ENDIF
        ENDIF    
ENDCASE

DO CASE
   CASE MCTA_CRE = "999999999999999"
        IF !EMPTY(ALLTRIM(cForn)) .AND. SA2->(DBSEEK(cFilSA2+cForn))
           MCTA_CRE = IF(!EMPTY(ALLTRIM(SA2->A2_CONTAB)), ALLTRIM(SA2->A2_CONTAB),"999999999999999")
        ENDIF

        IF  "SANTISTA" $ UPPER(SM0->M0_NOME) .AND.  LEFT(MCTA_CRE,6) == "236309"     && LAB 11.11.99
            DO  CASE
                CASE VAL(SUBS(EC2->EC2_SUB_SE,4,3)) < 181
                     MCTA_CRE = "204004"
                CASE VAL(SUBS(EC2->EC2_SUB_SE,4,3)) < 361
                     MCTA_CRE = "204301"
            ENDCASE
        ENDIF
   CASE RIGHT(MCTA_CRE,2) = "99"
        MCTA_CRE = SUBS(MCTA_CRE,1,LEN(MCTA_CRE)-2)+STRZERO(VAL(EC2->EC2_DESP)+IF("MERCK"$UPPER(SM0->M0_NOME).OR."M.B."$UPPER(SM0->M0_NOME),2,0),2)
   CASE LEFT(MCTA_CRE,4) = "0361" .AND. "WARNER" $ UPPER(SM0->M0_NOME)      && LAB 11.10.99
        DO  CASE
            CASE EC2->EC2_DESP = "001"
                 MCTA_CRE = MCTA_CRE + "322816"   && 1o DESPACHANTE 
            CASE EC2->EC2_DESP = "003"
                 MCTA_CRE = MCTA_CRE + "321535"   && 3o DESPACHANTE 
            CASE EC2->EC2_DESP = "005"
                 MCTA_CRE = MCTA_CRE + "505497"   && 4o DESPACHANTE 
            OTHERWISE
                 MCTA_CRE = MCTA_CRE + "322619"   && 2o DESPACHANTE O + USADO
        ENDCASE
   CASE LEFT(MCTA_CRE,8) = "11201090" .AND. "ABRIL" $ UPPER(SM0->M0_NOME)         && LAB 03.03.00
        MCTA_CRE = SUBS(MCTA_CRE,1,8) + LEFT(EC2->EC2_SUB_SE,1)
        IF  LEFT(EC2->EC2_SUB_SE,1) == "4"       && LAB 09.03.00
            MCTA_CRE = "131010119"
        ENDIF
// CASE "WARNER" $ UPPER(SM0->M0_NOME) .AND. LEFT(MCTA_CRE,4) = "0437" .AND. ! EMPTY(EC2->EC2_SUB_SE)    && LAB 24.07.00
//      MCTA_CRE = ALLTRIM(EC2->EC2_SUB_SE)

   CASE "WARNER" $ UPPER(SM0->M0_NOME)
        IF  LEFT(MCTA_CRE,4) = "0437" .AND. ! EMPTY(EC2->EC2_SUB_SE)    && LAB 24.07.00
            MCTA_CRE = ALLTRIM(EC2->EC2_SUB_SE)
            IF  ! EMPTY(EC2->EC2_CC_EST) .AND. .NOT. PLink $ "101/201/901/902/911/912"    && LAB 24.10.00  
                MCTA_CRE = ALLTRIM(EC2->EC2_CC_EST)
            ENDIF
            IF  MCTA_CRE == "0944.502" .AND. PLink $ "321/322"          && LAB 11.10.00  
                MCTA_CRE := "509230.3204.01"
            ENDIF
            IF  MCTA_CRE == "0944.501" .AND. PLink $ "321/322"          && LAB 11.10.00  
                MCTA_CRE := "509220.3204.01"
            ENDIF
        ENDIF    
ENDCASE

IF  ! "DEGUSSA" $ SM0->M0_NOME
    IF  PLink $ "602/603/620/622/653/654" .AND. (IF("MERCK" $ UPPER(SM0->M0_NOME),.T.,EMPTY(MCTA_CRE)))  && LAB 28.02.00
        MCTA_CRE  = ALLTRIM(LEFT(EC9->EC9_DESCR,10))
        MDT_CCAMB = SUBS(EC9->EC9_DESCR,12,8)
    ENDIF
ENDIF


IF  PLink $ "207/209/211/213" .AND. ("MERCK" $ UPPER(SM0->M0_NOME) .OR. "M.B." $ UPPER(SM0->M0_NOME)) .AND. MCTA_CRE = "00"    && LAB 20.01.99 ccontabil ii/ipi/icms
    MCTA_CRE  = ALLTRIM(LEFT(EC4->EC4_COM_HI,10))
ENDIF   

IF  PLink $ "622" .AND. ("MERCK" $ UPPER(SM0->M0_NOME) .OR. "M.B." $ UPPER(SM0->M0_NOME)) && desconto/abatimento - contra desconto
    MCTA_CRE = "30101003"
ENDIF
  
IF  ! "DEGUSSA" $ UPPER(SM0->M0_NOME)
    IF  PLink $ "621/623" .AND. (IF("MERCK" $ UPPER(SM0->M0_NOME),.T.,EMPTY(MCTA_CRE)))  && LAB 28.02.00
        MCTA_CRE  = ALLTRIM(LEFT(EC4->EC4_COM_HI,10))
        MDT_CCAMB = PData_A
    ENDIF
ENDIF

IF  PLink = "699"    && controla o pagto, valor credito no banco
    MCTA_CRE  = ALLTRIM(LEFT(EC4->EC4_COM_HI,10))
    MDT_CCAMB = PData_A
ENDIF

IF  PLink $ "612/613" .AND. (IF("MERCK" $ UPPER(SM0->M0_NOME),.T.,EMPTY(MCTA_CRE)))  && LAB 28.02.00
    MDT_CCAMB = SUBS(EC9->EC9_DESCR,12,8)
    IF  ! EMPTY(ALLTRIM(cForn)) .AND. SA2->(DBSEEK(cFilSA2+cForn))
       MCTA_CRE = IF(!EMPTY(ALLTRIM(SA2->A2_CLIQF)), ALLTRIM(SA2->A2_CLIQF),"999999999999999")
    ENDIF
ENDIF

IF  "DEGUSSA" $ UPPER(SM0->M0_NOME)
    IF  PLink = "620"
        MDT_CCAMB = SUBS(EC9->EC9_DESCR,12,8)
        IF SA2->(DBSEEK(cFilSA2+cForn)) .AND. ! EMPTY(ALLTRIM(cForn))
           MCTA_DEB = IF(!EMPTY(ALLTRIM(SA2->A2_CLIQF)), ALLTRIM(SA2->A2_CLIQF),"999999999999999")
        ENDIF
    ENDIF
ENDIF
Reclock('ECA',.T.)
IF "1102001" $ MCTA_CRE 
   ECA->ECA_FILIAL := xFilial('ECA')
ENDIF
IF "MERCK" $ UPPER(SM0->M0_NOME) .OR. "M.B." $ UPPER(SM0->M0_NOME)
   MCTA_DEB := STR(VAL(MCTA_DEB),15)
   MCTA_CRE := STR(VAL(MCTA_CRE),15)
ENDIF   

If lExisteECF .And. (PIdent = "609" .Or. PIdent = "608")
   MCTA_DEB := ECF->ECF_CTA_DB 
   MCTA_CRE := ECF->ECF_CTA_CR 
Endif
  
ECA->ECA_FILIAL := xFilial('ECA')
ECA->ECA_DI_NUM := nDi_NumAtu
ECA->ECA_INVOIC := PInvoice
ECA->ECA_ID_CAM := PIdent
ECA->ECA_DESCAM := EC6->EC6_DESC
ECA->ECA_CTA_DB := ALLTRIM(MCTA_DEB)   && LAB 11.10.99
ECA->ECA_CTA_CR := ALLTRIM(MCTA_CRE)   && LAB 11.10.99
ECA->ECA_DT_CON := PData
ECA->ECA_INFO   := PInfo
ECA->ECA_COD_HI := EC6->EC6_COD_HI
ECA->ECA_VALOR  := PValor
ECA->ECA_LINK   := PLink
ECA->ECA_HAWB   := nHawb
ECA->ECA_IDENTC := nIdentct
ECA->ECA_FINANC := EC6->EC6_FINANC
ECA->ECA_OBS    := EC6->EC6_DESC
ECA->ECA_TX_USD := PTaxaUsd
ECA->ECA_MOEDA  := nMoeda

ECA->ECA_FORN := PForn

If pSeq # NIL
   ECA->ECA_SEQ   := pSeq
Endif            

If PPrPo # NIL .And. PPrPo = 'PR'  
   ECA->ECA_PAGANT:= '1'    // 1-Processo 
Elseif PPrPo # NIL .And. PPrPo = 'PO'  
   ECA->ECA_PAGANT:= '2'    // 1-Pedido
Else   
   ECA->ECA_PAGANT:= '0'    // 0-Normal (nao é adiantamento nem antecipado)
Endif   

ECA->ECA_CONTAB := EC6->EC6_CONTAB
ECA->ECA_TPMODU := "IMPORT"

DO  CASE
    CASE  ("MERCK" $ UPPER(SM0->M0_NOME) .OR. "M.B." $ UPPER(SM0->M0_NOME) .OR. "AGFA" $ UPPER(SM0->M0_NOME)) .AND. PLink $ "602/603/620/621/623/653" && LAB 03.11.99
          ECA->ECA_OBS := MDT_CCAMB
    CASE  "AGFA" $ UPPER(SM0->M0_NOME) .AND. PLink $ "231/241"  && LAB 01.12.98
          ECA->ECA_OBS := "Nf." + EC2->EC2_NF_ENT        && LAB 01.12.98
    CASE  "SANTISTA" $ UPPER(SM0->M0_NOME) .AND. PLink $ "602/603/620/621/623/653"      && LAB 28.02.00
          ECA->ECA_OBS := ALLTRIM(LEFT(EC9->EC9_DESCR,10))
    CASE  PLink $ "602/603/620/621/623/653"              && LAB 03.11.99
          IF  EC5->EC5_MOE_FO $ "US$/USD"
              ECA->ECA_OBS := EC5->EC5_MOE_FO+" "+STRZERO(EC9->EC9_VL_MOE,13,2)+" "+EC5->EC5_FORN+" "+IF(lTem_DI,"S","N")+ " " + MDT_CCAMB   && LAB 02.06.00
          ELSE
              nVlConvPag   := VAL(STR(EC9->EC9_VALOR  / BuscaTxECO("US$",EC9->EC9_DTCONT),15,2))  && LAB 02.06.00
              ECA->ECA_OBS := "US$"+" "+STRZERO(nVlConvPag,13,2)+" "+EC5->EC5_FORN+" "+IF(lTem_DI,"S","N")+ " " + MDT_CCAMB
          ENDIF

*   CASE  "AGFA" $ UPPER(SM0->M0_NOME) .AND. PLink = "603"      && LAB 03.11.99
*         ECA->ECA_OBS := EC5->EC5_MOE_FO+" "+STRZERO(nPag_Abe_M,13,2)+" "+EC5->EC5_FORN+" "+IF(lTem_DI,"S","N")
*   CASE  ("DEGUSSA" $ SM0->M0_NOME .OR. "MERCK" $ SM0->M0_NOME .OR. "M.B." $ SM0->M0_NOME .OR. "AGFA" $ UPPER(SM0->M0_NOME)) .AND. PLink $ "602/603/620/621/623/653" && LAB 03.11.99
*         ECA->ECA_OBS := MDT_CCAMB

*   CASE  "CIBIE" $ SM0->M0_NOME .AND. PLink $ "327/329/441"   && LAB 25.05.99
*         ECA->ECA_OBS := "N.F. " + EC2->EC2_NF_ENT
*   CASE  "CIBIE" $ SM0->M0_NOME .AND. PLink = "447"           && LAB 25.05.99
*         ECA->ECA_OBS := "N.F.C. " + EC2->EC2_NF_COM
    OTHERWISE
          IF lMuda_Dt
             ECA->ECA_OBS += " " + DTOC(PData_A)
          ENDIF
ENDCASE

//PHawb    = SUBS(PHawb,1,nTamHawb)
//PInvoice = SUBS(PInvoice,1,nTamInvoic)

IF  "CIBIE" $ UPPER(SM0->M0_NOME)            && LAB 01.06.00
    DO  CASE
        CASE  PLink $ "101/201"
              ECA->ECA_TX_USD  := EC2->EC2_TX_USD   && LAB 04.08.99
        CASE  PLink $ "441/447/327/329"             && LAB 18.06.99 NFE,NFC,IPI,ICMS
              ECA->ECA_TX_USD  := BuscaTxECO("US$",EC2->EC2_DTENCE)
        OTHERWISE
              ECA->ECA_TX_USD  := EC2->EC2_TX_USD   && LAB 04.08.99
    ENDCASE
ENDIF

ECA->(MSUNLOCK())

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

If lTipoCont = 1
Reclock('EC7',.T.)
EC7->EC7_FILIAL := xFilial('EC7')
EC7->EC7_INVOIC := PInvoice
EC7->EC7_HAWB   := nHawb
EC7->EC7_IDENTC := nIdentct
EC7->EC7_DI_NUM := nDi_NumAtu
EC7->EC7_ID_CAM := PIdent
EC7->EC7_DT_LAN := PData
EC7->EC7_CTA_DB := ALLTRIM(MCTA_DEB)     && LAB 11.10.99
EC7->EC7_CTA_CR := ALLTRIM(MCTA_CRE)     && LAB 11.10.99
EC7->EC7_DT_CON := PData
EC7->EC7_COD_HI := EC6->EC6_COD_HI
EC7->EC7_COM_HI := EC6->EC6_DESC
EC7->EC7_LINK   := PLink
EC7->EC7_VALOR  := PValor
EC7->EC7_NR_CON := STRZERO(nNR_Cont+1,4,0)
EC7->EC7_FORN := PForn
EC7->EC7_MOEDA := nMoeda

IF lMuda_Dt
   EC7->EC7_OBS := DTOC(PData_A)
ENDIF

EC7->(MSUNLOCK())
EndIf

If EasyEntryPoint("ECOPR999")
   ExecBlock("ECOPR999",.F.,.F.,"GRV_CONTA")
EndIf

RETURN Nil

*---------------------------------------------------------------------------------------------*
FUNCTION PR200_VcfGrv(PValor,PIdent,PInvoice,PHAWB,PLink,PData,PInfo)
*---------------------------------------------------------------------------------------------*
lRefresh:=.t.

nHawb    = SUBS(PHawb,1,nTamHawb)
nIdentct = SUBS(PHawb,(nTamHawb+nTamForn+nTamMoeda+1),nTamIdentc)

IF EMPTY(nIdentct)
   nIdentct = SUBS(PInvoice,(nTamForn+nTamInvoic+1),nTamIdentc)
ENDIF

PForn = SUBS(PInvoice,1,nTamForn)

PHawb    = SUBS(PHawb,1,nTamHawb)
PInvoice = SUBS(PInvoice,(nTamForn+1),nTamInvoic)

EC6->(DBSEEK(cFilEC6+"IMPORT"+PLink+nIdentct))

MREC_SAL = EC9->(RECNO())

Reclock('EC9',.T.)
EC9->EC9_FILIAL := xFilial('EC9')
EC9->EC9_INVOIC := PInvoice
EC9->EC9_ID_CAM := PIdent
EC9->EC9_IDENTC := nIdentct
EC9->EC9_DT_LAN := dData_Con
EC9->EC9_DTCONT := PData
EC9->EC9_NR_CON := STRZERO(IF(cPrv_Efe="2",(nNR_Cont+1),9999),4,0)
EC9->EC9_VALOR  := PValor
EC9->EC9_DESCR  := EC6->EC6_DESC
EC9->EC9_FORN := PForn
   
EC9->(MSUNLOCK())

EC9->(DBGOTO(MREC_SAL))

RETURN
*------------------------------
FUNCTION Conv_real(PVl_Cont,PData)  && rotina a ser deletada, testar uso em todos os prgs.
* ------------------------------

IF PData<AVCTOD("01/07/1994")
   RETURN PVl_Cont/2750
ELSE
   RETURN PVl_Cont
ENDIF

*----------------------------------------------------*
FUNCTION PR200IdentCt(nInvoice,PHawb,PRdmake,cFornec)
*----------------------------------------------------*
LOCAL OldRecno:=0,nIdentCt:= SPACE(10),OldOrder:=0

If PRdmake # Nil
   cForn     := SPACE(06)
   nSubSetor := SPACE(10)
EndIf

IF EMPTY(PHawb)
   OldRecno := EC8->(RECNO())
   OldOrder := EC8->(INDEXORD())
   EC8->(DBSETORDER(2))
   IF EC8->(DBSEEK(cFilEC8+cFornec+nInvoice))
      PHawb:=EC8->EC8_HAWB
   ENDIF
   EC8->(DBSETORDER(OldOrder))
   EC8->(DBGOTO(OldRecno))
ENDIF

IF ! EMPTY(PHawb)
     If lTipoCont = 1     
        nIdentCt:=EC2->EC2_IDENTC
        cForn   :=EC2->EC2_FORN  
     Else
        nIdentCt:=ECG->ECG_IDENTC
        cForn   :=ECG->ECG_FORN
     EndIf
     IF "DEGUSSA" $ UPPER(SM0->M0_NOME)
        nSubSetor := EC2->EC2_SUB_SE
     ENDIF
     IF PHawb # EC2->EC2_HAWB
//      OldRecno := EC2->(RECNO())
        OldOrder := EC2->(INDEXORD())
        EC2->(DBSETORDER(1))
        IF EC2->(DBSEEK(cFilEC2+PHawb+cForn))
           nIdentCt:=EC2->EC2_IDENTC
           cForn   :=EC2->EC2_FORN
           IF  "DEGUSSA" $ UPPER(SM0->M0_NOME)
               nSubSetor := EC2->EC2_SUB_SE
           ENDIF
        ENDIF
//      EC2->(DBSETORDER(OldOrder))
//      EC2->(DBGOTO(OldRecno))
     ENDIF
ENDIF

nHawb = PHawb
RETURN nIdentCt

*------------------------------*
STATIC FUNCTION PR999Val(nTipo)
*------------------------------*
Local dDataImp

If nTipo == 1
   IF EMPTY(dData_Con)
      Help(" ",1,"AVG0005335") //E_Msg(STR0039,1) //"Data da contabiliza‡„o n„o preenchida."
      Return .F.
   ELSE
      IF dData_Con > dDta_Fim .OR. dData_Con < dDta_Inic
         Help(" ",1,"AVG0005336") //"Data de contabiliza‡„o deve estar no mˆs de processamento."
         Return .F.
      ENDIF
      If EasyGParam("MV_AVG0179", .T.)
         dDataImp := EasyGParam("MV_AVG0179",, "")
         If !Empty(dDataImp) .And. dData_Con > SToD(dDataImp)
            MsgInfo("Data de contabilização maior que a data final da última importação de dados.", "Atenção")
            Return .F.
         EndIf
      EndIf
      
   ENDIF
EndIf
Return .T.

*---------------------------------------------*
PROCEDURE PR200_Resumo(cCtDeb, cCtCre, nValor)
*---------------------------------------------*
LOCAL nPosicao := 0

IF nValor < 0
   nValor := nValor * (-1)
ENDIF

IF ! EMPTY(ALLTRIM(cCtDeb))
   nPosicao = ASCAN(aTab_Conta,cCtDeb)
   IF nPosicao > 0
      aTab_Deb[nPosicao] = aTab_Deb[nPosicao] + nValor
   ELSE
      AADD(aTab_Conta, cCtDeb)
      AADD(aTab_Deb, nValor)
      AADD(aTab_Cre, 0)
      nCount++                 
   ENDIF
ENDIF

IF ! EMPTY(ALLTRIM(cCtCre))
   nPosicao = ASCAN(aTab_Conta,cCtCre)
   IF nPosicao > 0
      aTab_Cre[nPosicao]+= nValor
   ELSE
      AADD(aTab_Conta, cCtCre)
      AADD(aTab_Cre, nValor)
      AADD(aTab_Deb, 0)
      nCount++
   ENDIF
ENDIF

RETURN
*-------------------------------------*
Function PR999Men(cMsg)
*-------------------------------------*

If !lScheduled
   oDlgProc:=GetWndDefault()
   oDlgProc:SetText(cMsg)
Else
   AvE_MSG(cMsg,1)
EndIf

RETURN .T.

*-------------------------------------*
Function PR999Inc(cMsg,nTot)
*-------------------------------------*
LOCAL cMsgInc:=""
IF nTot # NIL
   cMsgInc:=STR0099+STRZERO(nTot,8) //" de "
ENDIF
oDlgProc:=GetWndDefault()
nContReg++
nContReg1++
IF nContReg1 > 100
   ProcRegua(100)
   nContReg1:=0
ENDIF

oDlgProc:SetText(cMsg)
IncProc(STR0100+STRZERO(nContReg,10)+cMsgInc) //"Reg. Processados: "

RETURN .T.



/*
Alteracao  :  Rotinas Para Impressao por E_REPORT
Autor      :  Osman Medeiros Jr.                 
Data       :  04/05/2001  17:31
*/
*------------------*
Function ER_PR999IMP()
*------------------*
Local cDesc1   := ""
Local cDesc2   := ""
Local cDesc3   := ""
Local cString  := "ECA"
Local aOrd     := {}
Local lAutentica  := EasyGParam("MV_RELAUTH",,.F.)

Private wnrel
Private Tamanho  := "M"
Private titulo   := STR0041+SUBSTR(cMesProc,1,2)+"/"+SUBSTR(cMesProc,3,4) 
Private nomeprog := "ECOPR999"
Private aReturn := { "Zebrado", 1,STR0114, 1, 2, 1, "",1 } //"Contabilidade"
Private nLastKey := 0 
Private nHdl

Private cFrom, cTo, cCC, cAttachment, cBody, cSubject

IF cPrv_Efe = "2"
   lGeraTxt:=.T.
EndIf

If !lScheduled //Impressão normal do relatório
   wnrel:=SetPrint(cString,NomeProg,,@titulo,cDesc1,cDesc2,cDesc3,.F.,.F.,.T.,Tamanho,,.F.)
   
   If nLastKey == 27
      Set Filter To
      Return
   Endif

   SetDefault(aReturn,cString)

   If nLastKey = 27
      Set Filter To
      Return
   Endif

   RptStatus({|| ER_SENDPRN()} ,titulo)
Else
   //Impressão em TXT para envio por e-mail
   
   //Criação do arquivo txt
   cArquivo := CriaTrab(nil, .F.)+".TXT"
   nHdl     := MSFCreate(cArquivo)
      
   If (nHdl == -1)
      AvE_Msg("Nao consegui criar o e-mail. Cancelando.")
      Return .F.
   EndIf
   
   //Configura impressão em arquivo sem exibir telas
   wnrel:=SetPrint(cString,cArquivo,,@Titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,Tamanho,.F.,.T.,nil,nil,.T.,.T.)   
   aReturn[5] := 1
   
   //Executa impressão
   RptStatus({|| ER_SENDPRN()},"Imprimindo contabilizacao de Importacao...")
   Set Device to Screen
   Set Printer to    
   dbCommitAll()
   fClose(nHdl)
   MS_FLUSH()
   
   //Prepara envio de e-mail   
   cServer   := EasyGParam("MV_WFSMTP")
   cAccount  := EasyGParam("MV_WFACC")
   cPassword := EasyGParam("MV_WFPASSW")
   cFrom     := EasyGParam("MV_WFMAIL")
   cTo       := EasyGParam("MV_ECO0002")
   cCC       := "" //:= EasyGParam("MV_WFSMTP")
   cSubject  := "Easy Accounting("+AllTrim(SM0->M0_NOME)+") - "+cTit+" de "+DToC(dDta_Inic)+" à "+DToC(dDta_Fim)
   
   //Corpo do e-mail
   cBody := cTit + " de importação."
   cBody += Chr(13)+Chr(10)
   cBody += Chr(13)+Chr(10)
   
   cBody += "Empresa: "+SM0->M0_NOME
   cBody += Chr(13)+Chr(10)
   cBody += "Filial: "+SM0->M0_FILIAL
   cBody += Chr(13)+Chr(10)
   cBody += "Período: "+DToC(dDta_Inic)+" à "+DToC(dDta_Fim)
   cBody += Chr(13)+Chr(10)
   cBody += Chr(13)+Chr(10)
   
   cBody += "Veja anexo: "+cArquivo
   cBody += Chr(13)+Chr(10)
   cBody += Chr(13)+Chr(10)
   
   cBody += "Obs.: E-mail gerado automaticamente por agendamento do Easy Accounting"
   
   //Anexo
   cAttachment := AllTrim(Upper(GetSrvProfString("STARTPATH","")))
   If Right(cAttachment, 1) <> "\"
      cAttachment += "\"
   EndIf
   cAttachment := cAttachment + cArquivo
   
   If EasyEntryPoint("ECOPR999")
      ExecBlock("ECOPR999",.F.,.F.,"ENVIA_EMAIL")
   EndIf
   
   //Conecta no servido de e-mails
   CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK
   
   If !lOK
      AvE_Msg("Falha na Conexão com Servidor de E-Mail","ERRO")
   EndIf
   
   //Faz autenticação
   If lAutentica
      If !MailAuth(cAccount,cPassword)
         AvE_Msg("Falha na Autenticacao do Usuario","ERRO")
         DISCONNECT SMTP SERVER RESULT lOk
         
         IF !lOk
            GET MAIL ERROR cErrorMsg
            AvE_Msg("Erro na Desconexao: "+cErrorMsg,"ERRO")
            Return .F.
         EndIf
	  EndIf
   EndIf
   
   //Envia
   SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT cSubject BODY cBody ATTACHMENT cAttachment RESULT lOK
   
   If !lOK
      AvE_Msg("Falha no Envio de E-Mail")
   EndIf
      
   DISCONNECT SMTP SERVER
   Delete file &cArquivo
EndIf

Return .T.

*------------------*
Function ER_SENDPRN()
*------------------*

PRIVATE aTab_Conta := {}, aTab_Deb := {}, aTab_Cre := {}, nCount

AvPAguarde({||PRContaReg(3)},STR0067)   //"Aguarde... Apurando Dados"
ProcRegua(nTot1)
Pr999Men(STR0097)	   //"Lendo Previa"

If nTot1 = 0
   AvE_Msg(STR0035,1) //"N„o h  registros para impress„o."
   Return .T.
Endif

DBSELECTAREA('ECA')
If lExisteECF .And. lExisteECG
   ECA->(DBSETORDER(9))
Else
   ECA->(DBSETORDER(1))
Endif   
ECA->(DBSEEK(cFilECA+"IMPORT"))

//AFILL(aTab_Deb,0)
//AFILL(aTab_Cre,0)

nCount = 1

      nLimPage  := 69   ; nColIni := 1    ; nCol1 := 1    ; nCol2 := 17
      nCol3     := 29   ; nCol4   := 56   ; nCol5 := 72   ; nCol6 := 88
      nCol7     := 94   ; nCol8   := 111  ; nCol9 := 114  ; nCol10:= 126
      nColFim   := 134  ; nPag    := 0    ; nLin  := 80
      nColRes1  := 10    ; nColRes2:= 60   ; nColRes3 := 100
      
      DO WHILE ! ECA->(EOF()) .AND. ECA->ECA_FILIAL = cFilECA .AND.;
         ECA->ECA_TPMODU = "IMPORT"
         
         IF ! ECA->ECA_CONTAB $ '1 '  // Nao Permite Contabilização
            ECA->(DbSkip())
            Loop
         Endif

         If nLin > nLimPage
            ER_PR200CabRel(1)
            If lScheduled
               nLimPage := 999999999
            EndIf
         EndIf       
         
         SA2->(DBSEEK(cFilSA2+ECA->ECA_FORN))                

         ECC->(DBSEEK(cFilECC+ECA->ECA_IDENTC))

         //@ nLin,nCol1 PSay STR0051 + "  " + TRANS(ECA->ECA_DI_NUM,'@R 99/9999999-9') + " / " + STR0052 + " " + ECA->ECA_HAWB
         
         @ nLin,nCol1 PSay STR0060 + " " + ECA->ECA_IDENTC + " - " + Left(ECC->ECC_DESCR,08) + " / " + STR0072 + TRANS(ECA->ECA_DI_NUM,'@R 99/9999999-9') + " / " + STR0075 + ECA->ECA_HAWB + ;
                      " / " + STR0115 +  ECA->ECA_FORN + " - " + Left(SA2->A2_NOME,08) +  " / " + STR0117 + ECA->ECA_MOEDA

         nLin++       
	     nIdentc_Ant := ECA->ECA_IDENTC
         nDi_Ant     := ECA->ECA_DI_NUM
         nHawb_Ant   := ECA->ECA_HAWB
         nForn_Ant   := ECA->ECA_FORN
         nMoeda_Ant  := ECA->ECA_MOEDA
         lSaida:= .F.
         DO WHILE ! ECA->(EOF()) .AND. nIdentc_Ant = ECA->ECA_IDENTC .AND. nDi_Ant = ECA->ECA_DI_NUM .AND. nHawb_Ant = ECA->ECA_HAWB .AND. ECA->ECA_FILIAL = cFilECA ;
                  .AND. nForn_Ant = ECA->ECA_FORN .AND. nMoeda_Ant = ECA->ECA_MOEDA ;
                  .AND. ECA->ECA_TPMODU = "IMPORT"
       					
            IncProc(STR0075+ECA->ECA_HAWB) //"Processo: "
       					            
            IF ! ECA->ECA_CONTAB $ '1 '  // Nao Permite Contabilização
               ECA->(DbSkip())
               Loop
            Endif
            If nLin > nLimPage                                 
               ER_PR200CabRel(1)                               
               @ nLin,nCol1 PSay STR0060 + " " + ECA->ECA_IDENTC + " - " + Left(ECC->ECC_DESCR,08) + " / " + STR0072 + TRANS(ECA->ECA_DI_NUM,'@R 99/9999999-9') + " / " + STR0075 + ECA->ECA_HAWB + ;
                             " / " + STR0115 + ECA->ECA_FORN + " - " + Left(SA2->A2_NOME,08)  + " / " + STR0117 + ECA->ECA_MOEDA
               nLin++       
            EndIf                                         
            
            @ nLin,nCol1 PSay If(Empty(ECA->ECA_INVOIC),ECA->ECA_INVOIC,ALLTRIM(ECA->ECA_INVOIC)) + If(!Empty(ECA->ECA_SEQ), "/" + ALLTRIM(STR(VAL(ECA->ECA_SEQ),4)), "")
            @ nLin,nCol2 PSay DTOC(ECA->ECA_DT_CON)
            @ nLin,nCol3 PSay TRANS(ECA->ECA_ID_CAM,'@R 9.99')+" "+ECA->ECA_DESCAM
            @ nLin,nCol4 PSay ECA->ECA_CTA_DB
            @ nLin,nCol5 PSay ECA->ECA_CTA_CR
            @ nLin,nCol6 PSay ECA->ECA_COD_HI
            @ nLin,nCol7 PSay TRANS(ECA->ECA_VALOR,'@E 999,999,999.99')
            @ nLin,nCol8 PSay TRANS(ECA->ECA_TX_USD,'@E 999,999.999999')
            // @ nLin,nCol10 PSay ECA->ECA_IDENTC 

            PR200_Resumo(ECA->ECA_CTA_DB,ECA->ECA_CTA_CR,ECA->ECA_VALOR)

            nLin++
            ECA->(DBSKIP())
         ENDDO
         nLin++

         IF lSaida
            EXIT
         ENDIF
      ENDDO

      IF nPag > 0 .AND. cPrv_Efe = "2"
         nLin++
         @ nLin,nCol2 PSay STR0037+SUBSTR(cMesProc,1,2)+SUBSTR(cMesProc,3,4)+SUBSTR(STRZERO(nNR_Cont+1,4,0),3,2)+STR0038 //"ARQUIVO DE INTEGRACAO CONTABIL "###".TXT GERADO"
      EndIf

      IF nPag > 0
         ER_PR200FimRel()
         If LEN(aTabMsg)>0
            ER_PR200CabRel(3)
            If lScheduled
               Aeval(aMessages,b_aTabMsg)      
            EndIf
            aeval(aTabMsg,b_aTabMsg)
         EndIf
      ENDIF

SET DEVICE TO SCREEN

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

RETURN .T.

*--------------------------*
PROCEDURE ER_PR200CabRel(nRel)
*--------------------------*
Private aDriver := ReadDriver()

@ 0,0 PSay &(aDriver[3])

nLin:= 1
nPag++

If nRel=1
   IF cPrv_Efe = "1"
      cTexto1:= STR0041+SUBSTR(cMesProc,1,2)+"/"+SUBSTR(cMesProc,3,4) //"PREVIA DA INTEGRACAO CONTABIL - "
      cTexto2:= STR0042+DTOC(dDataBase)+STR0043+cHora //"Data da Integracao.: "###" Hora.: "
   ELSE
      cTexto1:= STR0044+SUBSTR(cMesProc,1,2)+"/"+SUBSTR(cMesProc,3,4) //"EFETIVACAO DA INTEGRACAO CONTABIL - "
      cTexto2:= STR0042+DTOC(dDataBase)+STR0043+cHora //"Data da Integracao.: "###" Hora.: "
   ENDIF
Elseif nRel=2
   cTexto1:= STR0045+SUBSTR(cMesProc,1,2)+"/"+SUBSTR(cMesProc,3,4) //"RESUMO - "
   cTexto2:= STR0042+DTOC(dDataBase)+STR0043+cHora //"Data da Integracao.: "###" Hora.: "
Else
   cTexto1:= STR0046 //"RELACAO DE MENSAGENS"
   cTexto2:= ""
EndIf

@ nLin,nColIni PSay Replicate("*",nColFim)
nLin++

@ nLin,nColIni PSay ALLTRIM(SM0->M0_NOME)+" - "+ALLTRIM(SM0->M0_FILIAL)
@ nLin,( (nColFim/2) - Round((Len(cTexto1)/2),0) ) PSay cTexto1
@ nLin,nColFim-19 PSay STR0047+STR(nPag,8) //"Pagina..: "
nLin++

@ nLin,nColIni PSay 'SIGAECO'
@ nLin,( (nColFim/2) - Round((Len(cTexto2)/2),0) ) PSay cTexto2
@ nLin,nColFim-19 PSay STR0048+DTOC(dDatabase) //"Emissao.: "
nLin++

@ nLin,nColIni PSay Replicate("*",nColFim)

If nRel#3
   nLin++
   @ nLin,10 PSay STR0049+STRZERO(nNR_Cont+1,4,0) //"Numero da Contabilizacao..: "
   @ nLin,76 PSay STR0050+DTOC(dData_Con) //"Data da Contabilizacao..: "
EndIf

nLin++

If nRel=1
   nLin++                      
   @ nLin,nCol1 PSay STR0053 //'Invoice'
   @ nLin,nCol2 PSay STR0054 //'Dt. Cont.'
   @ nLin,nCol3 PSay STR0055 //'Descricao Contabil'
   @ nLin,nCol4 PSay STR0056 //'Debito'
   @ nLin,nCol5 PSay STR0057 //'Credito'
   @ nLin,nCol6 PSay STR0058 //'Hist.'
   @ nLin,nCol7 PSay STR0059 //'Valor'
   @ nLin,nCol8 PSay STR0118 //'Taxa Usada'

   nLin++
   // @ nLin,nCol2 PSay '-----------------'
   @ nLin,nCol1 PSay '---------------'
   @ nLin,nCol2 PSay '---------'
   @ nLin,nCol3 PSay '-------------------------'
   @ nLin,nCol4 PSay '---------------'
   @ nLin,nCol5 PSay '---------------'
   @ nLin,nCol6 PSay '-----'
   @ nLin,nCol7 PSay '--------------'
   @ nLin,nCol8 PSay '--------------'
   // @ nLin,nCol10 PSay '----------'
   nLin++
Elseif nRel=2
   nLin++
   @ nLin,nColRes1 PSay STR0061 //'Conta'
   @ nLin,nColRes2 PSay STR0056 //'Debito'
   @ nLin,nColRes3 PSay STR0057 //'Credito'
   nLin++
   @ nLin,nColRes1 PSay REPLI('-',14)
   @ nLin,nColRes2 PSay REPLI('-',24)
   @ nLin,nColRes3 PSay REPLI('-',24)
   nLin++
EndIf

RETURN

*---------------------*
Function ER_PR200FimRel()
*---------------------*
Local I
ER_PR200CabRel(2)

nVlr_Deb = 0
nVlr_Cre = 0
FOR I = 1 TO nCount-1
   @ nLin,nColRes1 PSay aTab_Conta[I]
   @ nLin,nColRes2 PSay TRANS(aTab_Deb[I],'@E 999,999,999,999.99')
   @ nLin,nColRes3 PSay TRANS(aTab_Cre[I],'@E 999,999,999,999.99')
   nVlr_Deb = nVlr_Deb + aTab_Deb[I]
   nVlr_Cre = nVlr_Cre + aTab_Cre[I]
   nLin++
   If nLin > nLimPage
      ER_PR200CabRel(2)
   EndIf
NEXT

@ nLin,nColRes2 PSay "------------------"
@ nLin,nColRes3 PSay "------------------"
nLin++
@ nLin,nColRes2 PSay TRANS(nVlr_Deb,'@E 999,999,999,999.99')
@ nLin,nColRes3 PSay TRANS(nVlr_Cre,'@E 999,999,999,999.99')
nLin++
@ nLin,nColRes2 PSay ''

Return
      

*------------------------------*
static function ER_f_say(qualquer)
*------------------------------*
LOCAL cSay:=""
If nLin > nLimPage-1
   ER_PR200CabRel(3)
ENDIF

cSay:=MEMOLINE(qualquer,nTam,1)
@ nLin,nCol1 PSay Trans(cSay,"@!")

IF LEN(ALLTRIM(qualquer)) > nTam
   nLin++
   cSay:=MEMOLINE(qualquer,nTam,2)
   @ nLin,nCol1 PSay Trans(cSay,"@!")
ENDIF
nLin++

Return Nil
 
Function APUVCREAL(nVC_prov,cInvIdentc,cHAWB,dData_Pag,cMoeda) // VI 08/08/01
   IF lVCReal .AND. lTem_DI2 .AND. lTem_PG 
      IF nVC_prov > 0
         PR200_GrvPRV(nVC_prov ,"657",cInvIdentc,cHAWB,"657",PR200VerDT(dData_Pag)," ",dData_Pag,cMoeda,0)
      ELSE
         PR200_GrvPRV(nVC_prov ,"658",cInvIdentc,cHAWB,"658",PR200VerDT(dData_Pag)," ",dData_Pag,cMoeda,0)
      ENDIF
   ENDIF
Return .T.

*--------------------------------------------------------------------------------------
 STATIC FUNCTION PRContaReg(nOpcao)
*--------------------------------------------------------------------------------------
Local cNrCont := Replicate("0",Len(EC5->EC5_NR_CON))
Local cQueryEC2, cQueryEC3, cQueryEC4, cQueryEC5, cQueryEC7, cQueryEC9, cQueryECA
Local cAliasEC2, cAliasEC3, cAliasEC4, cAliasEC5, cAliasEC7, cAliasEC9, cAliasECA  
Local cQuery                
Local cQueryECE, cAliasECE
Local cQueryECG, cAliasECG

  
IF lTop 
  
 cAliasEC2 := "EC2TMP"
 cAliasEC3 := "EC3TMP"
 cAliasEC4 := "EC4TMP"
 cAliasEC5 := "EC5TMP"
 cAliasEC7 := "EC7TMP"
 cAliasEC9 := "EC9TMP" 
 cAliasECA := "ECATMP"
 
 If lExisteECE
    cAliasECE := "ECETMP"
 Endif   
 If lExisteECG
    cAliasECG := "ECGTMP"
 Endif   

  
 // Querys Padrao
 IF (TcSrvType() != "AS/400")  
    cQrPadrEC2 := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EC2")+ " WHERE EC2_FILIAL='"+ cFilEC2 +"' AND D_E_L_E_T_ <> '*' " 
    cQrPadrEC3 := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EC3")+ " WHERE EC3_FILIAL='"+ cFilEC3 +"' AND D_E_L_E_T_ <> '*' "
    cQrPadrEC4 := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EC4")+ " WHERE EC4_FILIAL='"+ cFilEC4 +"' AND D_E_L_E_T_ <> '*' "
    cQrPadrEC5 := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EC5")+ " WHERE EC5_FILIAL='"+ cFilEC5 +"' AND D_E_L_E_T_ <> '*' "
    cQrPadrEC7 := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EC7")+ " WHERE EC7_FILIAL='"+ cFilEC7 +"' AND D_E_L_E_T_ <> '*' "
    cQrPadrEC9 := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EC9")+ " WHERE EC9_FILIAL='"+ cFilEC9 +"' AND D_E_L_E_T_ <> '*' "
    cQrPadrECA := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("ECA")+ " WHERE ECA_FILIAL='"+ cFilECA +"' AND D_E_L_E_T_ <> '*' " +  "AND ECA_TPMODU = 'IMPORT' "
    If lExisteECE
       cQrPadrECE := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("ECE")+ " WHERE ECE_FILIAL='"+ cFilECE +"' AND D_E_L_E_T_ <> '*' "    
    Endif   
    If lExisteECG
       cQrPadrECG := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("ECG")+ " WHERE ECG_FILIAL='"+ cFilECG +"' AND D_E_L_E_T_ <> '*' "    
    Endif   
 Else
    cQrPadrEC2 := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EC2")+ " WHERE EC2_FILIAL='"+ cFilEC2 +"' "  
    cQrPadrEC3 := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EC3")+ " WHERE EC3_FILIAL='"+ cFilEC3 +"' " 
    cQrPadrEC4 := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EC4")+ " WHERE EC4_FILIAL='"+ cFilEC4 +"' " 
    cQrPadrEC5 := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EC5")+ " WHERE EC5_FILIAL='"+ cFilEC5 +"' " 
    cQrPadrEC7 := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EC7")+ " WHERE EC7_FILIAL='"+ cFilEC7 +"' " 
    cQrPadrEC9 := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EC9")+ " WHERE EC9_FILIAL='"+ cFilEC9 +"' " 
    cQrPadrECA := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("ECA")+ " WHERE ECA_FILIAL='"+ cFilECA +"' " + "AND ECA_TPMODU = 'IMPORT' "
    If lExisteECE
       cQrPadrECE := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("ECE")+ " WHERE ECE_FILIAL='"+ cFilECE +"' "    
    Endif   
    If lExisteECG
       cQrPadrECG := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("ECG")+ " WHERE ECG_FILIAL='"+ cFilECG +"' "    
    Endif   
 Endif     
                                
 If nOpcao == 1         // Parametro vindo da funcao PR999PROCINV        

   *--------> EC3           
   cQueryEC3 := cQrPadrEC3
   cQueryEC3 += "AND EC3_NR_CON = '" + Space(Len(cNrCont)) + "'"  
   PRExecQry(cQueryEC3, cAliasEC3)               
   If Select(cAliasEC3) > 0
      nTot1 := (cAliasEC3)->TOTALREG      
      (cAliasEC3)->(DbCloseArea())
   Else
      nTot1 := 0
   Endif  
   
   *--------> EC4           
   cQueryEC4 := cQrPadrEC4
   cQueryEC4 += "AND EC4_NR_CON = '" + Space(Len(cNrCont)) + "'"  
   PRExecQry(cQueryEC4, cAliasEC4)               
   If Select(cAliasEC4) > 0     
     nTot2 := (cAliasEC4)->TOTALREG
     (cAliasEC4)->(DbCloseArea())
   Else
     nTot2 := (cAliasEC4)->TOTALREG
   Endif  
   
   *--------> EC5         
   cQueryEC5 := cQrPadrEC5
   cQueryEC5 += "AND EC5_NR_CON = '" + Space(Len(cNrCont)) + "'"  
   PRExecQry(cQueryEC5, cAliasEC5)               
   If Select(cAliasEC5) > 0     
      nTot3 := (cAliasEC5)->TOTALREG
     (cAliasEC5)->(DbCloseArea())
   Else
      nTot3 := 0
   Endif  
   
   
   *--------> EC7         
   cQueryEC7 := cQrPadrEC7
   cQueryEC7 += "AND EC7_NR_CON = '" + Space(Len(cNrCont)) + "'"  
   PRExecQry(cQueryEC7, cAliasEC7)               
   If Select(cAliasEC7) > 0     
      nTot4 := (cAliasEC7)->TOTALREG
     (cAliasEC7)->(DbCloseArea())
   Else
      nTot4 := 0
   Endif
                      
   *--------> EC9         
   cQueryEC9 := cQrPadrEC9
   cQueryEC9 += "AND EC9_NR_CON = '" + Space(Len(cNrCont)) + "'"  
   PRExecQry(cQueryEC9, cAliasEC9)               
   If Select(cAliasEC9) > 0       
      nTot5 := (cAliasEC9)->TOTALREG
     (cAliasEC9)->(DbCloseArea())
   Else
      nTot5 := 0
   Endif
                              
   *--------> EC5           
   cQueryEC5 := cQrPadrEC5
   cQueryEC5 += "AND (EC5_NR_CON = '" + cNrCont + "' OR EC5_NR_CON = '" + Space(Len(cNrCont)) + "')"  
   PRExecQry(cQueryEC5, cAliasEC5)               
   If Select(cAliasEC5) > 0       
      nTot6 := (cAliasEC5)->TOTALREG
      (cAliasEC5)->(DbCloseArea())
   Else
      nTot6 := 0
   Endif   
   
   *--------> EC5           
   cQueryEC5 := cQrPadrEC5
   cQueryEC5 += "AND EC5_NR_CON = '9999'"  
   PRExecQry(cQueryEC5, cAliasEC5)               
   If Select(cAliasEC5) > 0       
      nTot7 := (cAliasEC5)->TOTALREG
      (cAliasEC5)->(DbCloseArea())
   Else
      nTot7 := 0
   Endif   
     
 
 Elseif nOpcao == 2     // Parametro vindo da funcao PR999PROC        
  
   *--------> 1) Lendo Invoice (EC5):           
   cQueryEC5 := cQrPadrEC5
   cQueryEC5 += "AND (EC5_NR_CON = '" + cNrCont + "' OR EC5_NR_CON = '" + Space(Len(cNrCont)) + "')" 
   PRExecQry(cQueryEC5, cAliasEC5)               
   If Select(cAliasEC5) > 0       
      nTot1 := (cAliasEC5)->TOTALREG
     (cAliasEC5)->(DbCloseArea())
   Else
     nTot1 := 0
   Endif  
 
   *--------> 2) Lendo Processo (EC4): 
   cQueryEC4 := cQrPadrEC4 
   cQueryEC4 += "AND EC4_ID_CAM = '201' AND (EC4_NR_CON = '" + cNrCont + "' OR EC4_NR_CON = '" + Space(Len(cNrCont)) + "')"  
   PRExecQry(cQueryEC4, cAliasEC4)               
   If Select(cAliasEC4) > 0        
      nTot2 := (cAliasEC4)->TOTALREG
     (cAliasEC4)->(DbCloseArea())
   Else
      nTot2 := 0
   Endif  
 
   *--------> 3) Lendo Processo (EC4): 
   cQueryEC4 := cQrPadrEC4         
   cQueryEC4 += "AND (EC4_NR_CON = '" + cNrCont + "' OR EC4_NR_CON = '" + Space(Len(cNrCont)) + "')" 
   PRExecQry(cQueryEC4, cAliasEC4)               
   If Select(cAliasEC4) > 0        
      nTot3 := (cAliasEC4)->TOTALREG
     (cAliasEC4)->(DbCloseArea())
   Else
      nTot3 := 0
   Endif  
  
   *--------> 4) Lendo Invoice (EC5): 
   cQueryEC5 := cQrPadrEC5
   cQueryEC5 += "AND (EC5_NR_CON <> '" + cNrCont + "' OR EC5_NR_CON = '" + Space(Len(cNrCont)) + "')"  
   PRExecQry(cQueryEC5, cAliasEC5)               
   If Select(cAliasEC5) > 0        
      nTot4 := (cAliasEC5)->TOTALREG
     (cAliasEC5)->(DbCloseArea())
   Else
      nTot4 := 0
   Endif  
 
   *--------> 5) Lendo Invoice (EC5): 
   cQueryEC5 := cQrPadrEC5
   //cQueryEC5 += "AND EC5_VCFANO+EC5_VCFMES = '" + Space(LEN(EC5->EC5_VCFANO+EC5->EC5_VCFMES)) + "'"  
   cQueryEC5 += "AND EC5_VCFANO = '" + Space(LEN(EC5->EC5_VCFANO)) + "' AND EC5_VCFMES = '" + Space(LEN(EC5->EC5_VCFMES)) + "'"  
   PRExecQry(cQueryEC5, cAliasEC5)               
   If Select(cAliasEC5) > 0        
      nTot5 := (cAliasEC5)->TOTALREG
     (cAliasEC5)->(DbCloseArea())
   Else
      nTot5 := 0
   Endif                         
   
   *--------> 6) Lendo Processos Estornados (ECE) :           
   If lExisteECE
      cQueryECE := cQrPadrECE
      cQueryECE += "AND ECE_NR_CON = '0000'"  
      PRExecQry(cQueryECE, cAliasECE)               
      If Select(cAliasECE) > 0        
         nTot6 := (cAliasECE)->TOTALREG
        (cAliasECE)->(DbCloseArea())
      Else
         nTot6 := 0
      Endif  
   Endif   
   
   *--------> 7) Lendo Invoice (EC2):    
   cQueryEC2 := cQrPadrEC2
   PRExecQry(cQueryEC2, cAliasEC2)               
   If lExisteECE
      If Select(cAliasEC2) > 0        
         nTot7 := (cAliasEC2)->TOTALREG
      Else
         nTot7 := 0
      Endif   
   Else
      If Select(cAliasEC2) > 0        
   		 nTot6 := (cAliasEC2)->TOTALREG   
   	  Else
   	     nTot6 := 0
   	  Endif			
   Endif 
   If Select(cAliasEC2) > 0             
      (cAliasEC2)->(DbCloseArea()) 
   Endif   
   
   *--------> ECG           
   If lExisteECG
      cQueryECG := cQrPadrECG
      PRExecQry(cQueryECG, cAliasECG)               
      If Select(cAliasECG) > 0             
         nTot8 := (cAliasECG)->TOTALREG
         (cAliasECG)->(DbCloseArea())            
      Else
         nTot8 := 0
      Endif  
   Endif     
         
  Elseif nOpcao == 3   // Parametro vindo da funcao PR999IMP e ER_SENDPRN       

   *--------> ECA           
   cQueryECA := cQrPadrECA
   PRExecQry(cQueryECA, cAliasECA)               
   If Select(cAliasECA) > 0             
      nTot1 := (cAliasECA)->TOTALREG
     (cAliasECA)->(DbCloseArea())            
   Else
      nTot1 := 0
   Endif     
 Endif 
  
ELSE 
      
  
  If nOpcao == 1         // Parametro vindo da funcao PR999PROCINV        
 
     *--------> EC3               
     nTot1 := 0
     EC3->(DbGotop())    
     EC3->(DbSeek(cFilEC3,.T.))     
     EC3->(DBEVAL({||nTot1++,MsProcTxt(STR0103+EC3->EC3_DI_NUM) },,{||EC3->(!EOF()) .And.  EMPTY(ALLTRIM(EC3->EC3_NR_CON)) .And. EC3->EC3_FILIAL = cFilEC3 })) //"Lendo DI: "
     
     *--------> EC4               
     nTot2 := 0
     EC4->(DbGotop())               
     EC4->(DbSeek(cFilEC4,.T.))     
     EC4->(DBEVAL({||nTot2++,MsProcTxt(STR0104+EC4->EC4_HAWB) },,{||EC4->(!EOF()) .And.  EMPTY(ALLTRIM(EC4->EC4_NR_CON)) .And. EC4->EC4_FILIAL = cFilEC4 })) //"Lendo Processo: "
     
     *--------> EC5               
     nTot3 := 0               
     EC5->(DbGotop())               
     EC5->(DbSeek(cFilEC5,.T.))     
     EC5->(DBEVAL({||nTot3++, MsProcTxt(STR0105+EC5->EC5_INVOIC) },,{||EC5->(!EOF()) .And.  EMPTY(ALLTRIM(EC5->EC5_NR_CON)) .And. EC5->EC5_FILIAL = cFilEC5 })) //"Lendo Invoice: "
     
     *--------> EC7               
     nTot4 := 0 
     EC7->(DbGotop())               
     EC7->(DbSeek(cFilEC7,.T.))     
     EC7->(DBEVAL({||nTot4++, MsProcTxt(STR0105+EC7->EC7_HAWB) },,{||EC7->(!EOF()) .And.  EMPTY(ALLTRIM(EC7->EC7_NR_CON)) .And. EC7->EC7_FILIAL = cFilEC7 })) //"Lendo Invoice: "
     
     *--------> EC9               
     nTot5 := 0
     EC9->(DbGotop())               
     EC9->(DbSeek(cFilEC9,.T.))     
     EC9->(DBEVAL({||nTot5++, MsProcTxt(STR0105+EC9->EC9_INVOIC) },,{||EC9->(!EOF()) .And.  EMPTY(ALLTRIM(EC9->EC9_NR_CON)) .And. EC9->EC9_FILIAL = cFilEC9 })) //"Lendo Invoice: "
     
     *--------> EC5               
     nTot6 := 0
     EC5->(DbGotop())               
     EC5->(DbSeek(cFilEC5,.T.))     
     EC5->(DBEVAL({||nTot6++, MsProcTxt(STR0105+EC5->EC5_INVOIC)},,{||EC5->(!EOF()) .And.  VAL(EC5->EC5_NR_CON) = 0 .And. EC5->EC5_FILIAL = cFilEC5 })) //"Lendo Invoice: "
          
     *--------> EC5               
     nTot7 := 0
     EC5->(DbGotop())
     EC5->(DbSeek(cFilEC5,.T.))     
     EC5->(DBEVAL({||nTot7++, MsProcTxt(STR0105+EC5->EC5_INVOIC)},,{||EC5->(!EOF()) .And.  VAL(EC5->EC5_NR_CON) = 9999 .And. EC5->EC5_FILIAL = cFilEC5 })) //"Lendo Invoice: "
         
  Elseif nOpcao == 2     // Parametro vindo da funcao PR999PROC        
   
     *--------> 1) Lendo Invoice (EC5):               
     nTot1 := 0
     EC5->(DBSETORDER(3))
     EC5->(DbGotop())          
	 EC5->(DbSeek(cFilEC5+'0000',.T.))          
     EC5->(DBEVAL({||nTot1++, MsProcTxt(STR0105+EC5->EC5_INVOIC)},,{||EC5->(!EOF()) .And. VAL(EC5->EC5_NR_CON) = 0 .And. EC5->EC5_FILIAL = cFilEC5 })) //"Lendo Invoice: "
     EC5->(DBSETORDER(1))
                   
     *--------> 2) Lendo Processo (EC4): 
     nTot2 := 0 
     EC4->(DBSETORDER(2))
   	 EC4->(DbGotop())             		
   	 EC4->(DBSEEK(cFilEC4+'0000'+"201",.T.))
     EC4->(DBEVAL({||nTot2++, MsProcTxt(STR0104+EC4->EC4_HAWB)},,{||EC4->(!EOF()) .And. VAL(EC4->EC4_NR_CON) = 0 .And. EC4->EC4_ID_CAM = '201' .And. EC4->EC4_FILIAL = cFilEC4 })) //"Lendo Processo: "
     EC4->(DBSETORDER(1))
					  
     *--------> 3) Lendo Processo (EC4): 
     nTot3 := 0        
     EC4->(DBSETORDER(2))
	 EC4->(DbGotop())          
   	 EC4->(DBSEEK(cFilEC4+'0000',.T.))     
     EC4->(DBEVAL({||nTot3++, MsProcTxt(STR0104+EC4->EC4_HAWB)},,{||EC4->(!EOF()) .And. VAL(EC4->EC4_NR_CON) = 0 .And. EC4->EC4_FILIAL = cFilEC4 })) //"Lendo Processo: "
     EC4->(DBSETORDER(1))

   
     *--------> 4) Lendo Invoice (EC5):  
     nTot4 := 0
     EC5->(DBSETORDER(3))
     EC5->(DbGotop())
     EC5->(DBSEEK(cFilEC5+'0001',.T.))     
     EC5->(DBEVAL({||nTot4++, MsProcTxt(STR0105+EC5->EC5_INVOIC)},,{||EC5->(!EOF()) .And. VAL(EC5->EC5_NR_CON) # 0 .And. EC5->EC5_FILIAL = cFilEC5 })) //"Lendo Invoice: "
     EC5->(DBSETORDER(1))
 
  
     *--------> 5) Lendo Invoice (EC5): 
     nTot5 := 0
     EC5->(DBSETORDER(4))
     EC5->(DbGotop())
     EC5->(DbSeek(cFilEC5,.T.))
     EC5->(DBEVAL({||nTot5++, MsProcTxt(STR0105+EC5->EC5_INVOIC)},,{||EC5->(!EOF()) .And. Empty(Alltrim(EC5->EC5_VCFANO+EC5->EC5_VCFMES)) .And. EC5->EC5_FILIAL = cFilEC5 })) //"Lendo Invoice: "
     EC5->(DBSETORDER(1))
          
     *--------> 6) Lendo Processos Estornados (ECE) :               
     If lExisteECE
        nTot6 := 0
        ECE->(DbGotop())
        ECE->(DbSeek(cFilECE,.T.))     
        ECE->(DBEVAL({||nTot6++, MsProcTxt(STR0104+ECE->ECE_HAWB)},,{||ECE->(!EOF()) .And.  VAL(ECE->ECE_NR_CON) = 0 .And. ECE->ECE_FILIAL = cFilECE }))        //"Lendo Processo: "
     Endif   
     
     *--------> 7) Lendo Processo (EC2): 
     If lExisteECE     
        nTot7 := 0
     Else
        nTot6 := 0
     Endif   
   	 EC2->(DbGotop())          
   	 EC2->(DbSeek(cFilEC2,.T.))     
     EC2->(DBEVAL({||If(lExisteECE, nTot7++,nTot6++),MsProcTxt(STR0104+EC2->EC2_HAWB) },,{||EC2->(!EOF()) .And. EC2->EC2_FILIAL = cFilEC2 })) //"Lendo Processo: "
     
     If lExisteECG
        nTot8 := 0
        ECG->(DbGotop())
        ECG->(DbSeek(cFilECG+TIPO_DO_MODULO,.T.))     
        ECG->(DBEVAL({||nTot8++, MsProcTxt(STR0104+ECG->ECG_HAWB)},,{||ECG->(!EOF()) .And. ECG->ECG_FILIAL = cFilECG .and. ECG->ECG_TPMODU == TIPO_DO_MODULO}))   //"Lendo Processo: "
     Endif   
      
   Elseif nOpcao == 3    // Parametro vindo da funcao PR999IMP e ER_SENDPRN       
 
     nTot1 := 0
     ECA->(DbGotop())
     ECA->(DbSeek(cFilECA+"IMPORT",.T.))
     ECA->(DBEVAL({||nTot1++, MsProcTxt(STR0104+ECA->ECA_HAWB)},,{||ECA->(!EOF()) .And. ECA->ECA_FILIAL = cFilECA .AND. ECA->ECA_TPMODU = "IMPORT"}))      //"Lendo Processo: "
   Endif               
ENDIF                                            

RETURN .T.     

*--------------------------------------------------------------------------------------
 STATIC FUNCTION PRExecQry(cQuery, cAlias)
*--------------------------------------------------------------------------------------

cQuery := ChangeQuery(cQuery)
DbUsearea(.T.,"TOPCONN", TCGenQry(,,cQuery), cAlias,.F.,.T.)

RETURN .T.

*--------------------------------------------------------------------------------------
 STATIC FUNCTION APAGAECA()
*--------------------------------------------------------------------------------------
Local nCount := 0, nCont := 0, cQuery 

IF lTop                                      
  IF (TcSrvType() != "AS/400")

     IF ECA->(EasyRecCount())/1024 < 1
        nCount := 1
     Else
        nCount := Round(ECA->(EasyRecCount())/1024,0)
     EndIf
	 Pr999Men(STR0106)          //"Limpando Arquivo da Previa"

     //** AAF 08/01/08 - Otimização na query de exclusão de registros do ECA
     ChkFile("ECA")
     nOrd := ECA->(IndexOrd())
     ECA->(dbSetOrder(0))
     ECA->(dbGoTop())
     nCont := ECA->(RecNo())
     ECA->(dbGoBottom())
     nCount := ECA->(RecNo())
     ECA->(dbSetOrder(nOrd))
     //**
     
/*
     nCount:=ECA->(EasyRecCount())
     nCont := 0                   
*/

     ProcRegua( Int((nCount-nCont)/1024)+1 )

     // APAGA A CADA 1024 PARA NÃO ENCHER O LOG DO BANCO!
     While nCont <= nCount
		 IncProc(STR0087) //"Limpando Arquivo da Previa..."
									
         cQuery := "DELETE FROM "+RetSqlName("ECA")
       	 cQuery := cQuery + " WHERE R_E_C_N_O_ between "+Str(nCont)+" AND "+Str(nCont+1024)
       	 cQuery := cQuery + " AND ECA_FILIAL = '" + cFilECA + "'"
       	 cQuery := cQuery + " AND ECA_TPMODU = 'IMPORT'"
    	 nCont := nCont + 1024
    	 TCSQLEXEC(cQuery)
     Enddo
  Else
     ProcRegua(nTot1)                                    
     DBSELECTAREA('ECA')
     ECA->(DBSEEK(cFilECA+"IMPORT"))
     ECA->(DBEVAL({||(Pr999Men(STR0106),IncProc(STR0075+ECA->ECA_HAWB),ECA->(Reclock('ECA',.F.)),ECA->(DBDELETE()),ECA->(MSUNLOCK()))},,{||ECA->ECA_FILIAL==cFilECA .AND. ECA->ECA_TPMODU = "IMPORT"},,,.T.))   //"Limpando Arquivo da Previa"###"Processo: "
  Endif
ENDIF

IF !lTop 
   ProcRegua(nTot1)                                    
   DBSELECTAREA('ECA')
   ECA->(DBSEEK(cFilECA+"IMPORT"))
   ECA->(DBEVAL({||(Pr999Men(STR0106),IncProc(STR0075+ECA->ECA_HAWB),ECA->(Reclock('ECA',.F.)),ECA->(DBDELETE()),ECA->(MSUNLOCK()))},,{||ECA->ECA_FILIAL==cFilECA .AND. ECA->ECA_TPMODU = "IMPORT"},,,.T.))   //"Limpando Arquivo da Previa"###"Processo: "
ENDIF

Return .T.
   
*---------------------------------------------------------------------------*
Static Function BuscaTxECO(PInd, PData)
*---------------------------------------------------------------------------*
Local nTaxaECO:=0, nAPos

nAPos := aScan(aTaxas,{|x| x[1]==PInd .and. x[2]==PData })
If nAPos > 0
   nTaxaECO := aTaxas[nAPos,3]
Else
   nTaxaECO := ECOBuscaTaxa(PInd, PData)
   aAdd(aTaxas,{PInd, PData, nTaxaECO})
EndIf

Return nTaxaECO

*------------------------------------------------------------------------------------------------------*
Static Function GeraAdiant()    // Rotina para gerar variacoes para pag.adiantecipados / adiantamentos
*------------------------------------------------------------------------------------------------------*
Local nVariacao := 0 ,nOrdemEC5 := EC5->(IndexOrd()),;
      nEC5Recno := EC5->(Recno()), lExisteDI := .F., nOrdemEC9 := EC9->(IndexOrd()),;
      nEC9Recno := EC9->(Recno()), nRecnoECF := 0, nOrdW9:=SW9->(IndexOrd()), nOrdW8:=SW8->(IndexOrd()), nOrdW2:=SW2->(IndexOrd())
Local cSeq, cOrigem, cInvoice, cHawb, cIdentc, cMoeda, cForn, nValMoe, nTot108, nVariacaoAtual,;
      nPagRel, aInvoice := {}, aSaida   := {}, nTxECG := 0, i := 0, nTaxaFimMes := 0, aInvMercadoria := {}
Local dDataTx, n109, cPo:="", nPos:=0
Private nTx101 := 0, nTaxaVaria := 0, nTxDI := 0
Private lDtEnce := .F.
lTipoCont:=2 // Para na previa não gravar o EC7
SW6->(DbSetOrder(1))
ECG->(DbSetOrder(1))
EC9->(DbSetOrder(4))
ECG->(DbSeek(cFilECG+TIPO_DO_MODULO))
ECF->(DbSetOrder(6))
ProcRegua(nTot8)
Pr999Men(STR0116)    //"Lendo Pagamentos Antecipados"

Do While ECG->(!EOF()) .And. ECG->ECG_FILIAL == cFilECG .and. ECG->ECG_TPMODU == TIPO_DO_MODULO
      
   IncProc(STR0075+ECG->ECG_HAWB) //"Processo: "       
   
   If !Empty(ECG->ECG_DTENCE)
      ECG->(DBSKIP())
      LOOP
   Endif
   nTxECG := ECG->ECG_ULT_TX

   //** AAF 06/03/08
   nSldAdi := 0
   nUltTx  := 0
   dUltTxDt:= CToD("  /  /  ")
   //**
   
   lComp := .F.
   lFim  := .F.
   
   If ECG->ECG_ORIGEM = "PR"    // Processo - Adiantamento
   
      If ! ECF->(DbSeek(cFilECF+TIPO_DO_MODULO+ECG->ECG_HAWB+ECG->ECG_FORN+ECG->ECG_IDENTC+"PR"+"608"))
         AADD(aTabMsg,STR0123)
      EndIf
      SW9->(dbSetOrder(1))
      Do While ECF->(!EOF()) .And. ECF->ECF_FILIAL == cFilECF .And. ECF->ECF_TPMODU == TIPO_DO_MODULO .and.;
         ECF->ECF_HAWB+ECF->ECF_FORN+ECF->ECF_IDENTC+ECF->ECF_ORIGEM+ECF->ECF_ID_CAM = ECG->ECG_HAWB+ECG->ECG_FORN+ECG->ECG_IDENTC+ECG->ECG_ORIGEM+"608"
         cSeq     := ECF->ECF_SEQ
         nVariacao:= 0

         If ECF->ECF_HAWB # SW6->W6_HAWB
            SW6->(DBSEEK(cFilSW6+ECF->ECF_HAWB))
         EndIf
         
         // Verifica se existe registro da DI no SW6
         //dDataEmis := dData_Con
         
         IniVarEmbarque(dData_Con,SW6->W6_HAWB,ECF->ECF_INVOIC,ECF->ECF_FORN)
         
         /*
         If ! SW6->(EOF()) .AND. dDta_Inic <= dDtEnce .AND. dDtEnce <= dDta_Fim  
            dDataEmis := SW6->W6_DTREG_D
            lDtEnce   := .T. //AOM - 19/07/2012 - Flag para colocar data de encerramento na ECG na efetivação.
         EndIf
         */ //FSM - 24/10/2012
         
         If lComp//lDtEnce//lExisteDI
            //nTaxaVaria := SW9->W9_TX_FOB 
            nTaxaVaria := nTxComp
         Else
            nTaxaVaria := BuscaTxECO(ECF->ECF_MOEDA, dData_Con, PR200VerDT(dData_Con))
         Endif
         
         If EasyEntryPoint("ECOPR999")    // Ponto de Entrada p/ controlar a variavel nTaxaVaria conforme necessario                  
            ExecBlock("ECOPR999",.F.,.F.,"TX_ADIANTAMENTO")   
         EndIf               

         If nTaxaVaria = 0 .and. ASCAN(aTabMsg,{|X| X=STR0117+Alltrim(ECF->ECF_HAWB)+" "+STR0117+Alltrim(ECF->ECF_IDENTC)}) = 0
            AADD(aTabMsg,STR0117+Alltrim(ECF->ECF_HAWB)+" "+STR0117+Alltrim(ECF->ECF_IDENTC))
         Endif           

         nRecECF := ECF->(RECNO())
         If ECF->(DbSeek(cFilECF+TIPO_DO_MODULO+ECG->ECG_HAWB+ECG->ECG_FORN+ECG->ECG_IDENTC+"PR"+"101"+ECF->ECF_INVOICE+ECF->ECF_SEQ)) .OR.;
         ECF->(DbSeek(cFilECF+TIPO_DO_MODULO+ECG->ECG_HAWB+ECG->ECG_FORN+ECG->ECG_IDENTC+"PR"+"108"+ECF->ECF_INVOICE+ECF->ECF_SEQ))
            lTrans := .T.
         Else
            lTrans := .F.
         EndIf
         ECF->(DBGOTO(nRecECF))
         
         nRecECF := ECF->(RECNO())
         If ECF->ECF_NR_CON  = "9999"
            nVariacao := (ECF->ECF_VL_MOE * nTaxaVaria) - (ECF->ECF_VL_MOE * ECF->ECF_PARIDA)
            nTxUtilizada := ECF->ECF_PARIDA
            If cPrv_Efe = "2"      // Efetivacao
               RECLOCK("ECF",.F.)
               ECF->ECF_NR_CON := STRZERO(nNR_Cont+1,4,0)
               ECF->(MSUNLOCK())
            EndIf
            PR200_GrvPRV(ECF->ECF_VALOR,"608",ECG->ECG_FORN+ECF->ECF_INVOIC,ECF->ECF_HAWB+Space(nTamForn+nTamMoeda)+ECF->ECF_IDENTC,"608",ECF->ECF_DTCONT," ",ECF->ECF_DTCONT,ECF->ECF_MOEDA,ECF->ECF_PARIDA /*nTaxaVaria*/,ECF->ECF_SEQ,'PR') //FSM - 10/12/2012
         ElseIf lComp .AND. dDtComp < dDta_Inic //AAF 08/10/2012 - Não gerar variação do adiantamento já compensado.
            nVariacao := 0
         Else
            nVariacao := (ECF->ECF_VL_MOE * nTaxaVaria) - (ECF->ECF_VL_MOE * nTxECG)
            nTxUtilizada := nTxECG
         EndIf
         
         If nVariacao # 0
            If cPrv_Efe = "2"      // Efetivacao                                  
               TransfECF(nVariacao, ECF->ECF_MOEDA, If(nVariacao > 0, "508", "509"), ECF->ECF_FORN, ECF->ECF_INVOIC, ECF->ECF_HAWB, ECF->ECF_IDENTC, If(nVariacao>0,"508","509"), If(lComp,dDtComp,dData_Con), ECF->ECF_SEQ, /*lDtEnce*/, 'PR', ECF->ECF_VL_MOE,,"")
               Reclock("ECF",.F.)
               ECF->ECF_PARIDA := nTaxaVaria      // Taxa do Mes
               ECF->ECF_FLUTUA := nTxUtilizada    // Final do Mes anterior
               ECF->(MsUnlock())
               ECF->(DBGOTO(nRecECF))
            Endif   
            // Grava Variacoes 508/509 na previa                                          
            PR200_GrvPRV(nVariacao,If(nVariacao>0,"508","509"),ECF->ECF_FORN+ECF->ECF_INVOIC,ECF->ECF_HAWB+Space(nTamForn+nTamMoeda)+ECF->ECF_IDENTC,If(nVariacao>0,"508","509"),If(lComp,dDtComp,dData_Con)," ",If(lComp,dDtComp,dData_Con),ECF->ECF_MOEDA,nTaxaVaria,ECF->ECF_SEQ,'PR') //FSM - 24/10/2012
         Endif

         If ! lTrans   // Verifica se existe DI               
            // Grava Variacao 508/509/108 no ECF
            //FSM - 24/10/2012
            If lComp //.AND. ! lTrans  // Grava 508/509 com os dados que foram gravados anteriormente no ECF    
               
               nTot108 := (ECF->ECF_VL_MOE * nTaxaVaria)
               If nTot108 # 0
                  

                     If cPrv_Efe = "2"      // Efetivacao
                        nTx608 := ECF->ECF_PARIDA
                        TransfECF(nTot108, ECF->ECF_MOEDA, "101", ECF->ECF_FORN, ECF->ECF_INVOIC, ECF->ECF_HAWB, ECF->ECF_IDENTC, "101", dDtComp, ECF->ECF_SEQ, /*lDtEnce*/, "PR",   ECF->ECF_VL_MOE,,ECF->ECF_PROCOR)
                        Reclock("ECF",.F.)
                        ECF->ECF_PARIDA := nTaxaVaria      // Taxa do Mes
                        ECF->ECF_FLUTUA := nTx608          // Tx do pagamento
                        ECF->(MsUnlock())
                        ECF->(DBGOTO(nRecECF))
                     Endif
                     
                     // Grava 101 na previa
                     PR200_GrvPRV(nTot108,"101",ECF->ECF_FORN+ECF->ECF_INVOIC+ECF->ECF_IDENTC,ECF->ECF_HAWB+Space(nTamForn+nTamMoeda)+ECF->ECF_IDENTC,"101",dDtComp," ",dDtComp,ECF->ECF_MOEDA,nTaxaVaria,ECF->ECF_SEQ,'PR') //FSM - 10/12/2012

                  
                  If EC6->(DbSeek(cFilEC6+"IMPORT"+"108"+ECF->ECF_IDENTC)) .OR. EC6->(DbSeek(cFilEC6+"IMPORT"+"108")) //AAF 29/09/2012 - Utiliza centro de custo padrão.
                     If cPrv_Efe = "2"      // Efetivacao
                        nTx608 := ECF->ECF_PARIDA
                        TransfECF(nTot108, ECF->ECF_MOEDA, "108", ECF->ECF_FORN, ECF->ECF_INVOIC, ECF->ECF_HAWB, ECF->ECF_IDENTC, "108", dDtComp, ECF->ECF_SEQ, /*lDtEnce*/, "PR",   ECF->ECF_VL_MOE,,ECF->ECF_PROCOR)
                        Reclock("ECF",.F.)
                        ECF->ECF_PARIDA := nTaxaVaria      // Taxa do Mes
                        ECF->ECF_FLUTUA := nTx608          // Tx do pagamento
                        ECF->(MsUnlock())
                        ECF->(DBGOTO(nRecECF))
                     Endif   
                     // Grava 108 na previa
                     PR200_GrvPRV(nTot108,"108",ECF->ECF_FORN+ECF->ECF_INVOIC+ECF->ECF_IDENTC,ECF->ECF_HAWB+Space(nTamForn+nTamMoeda)+ECF->ECF_IDENTC,"108",dDtComp," ",dDtComp,ECF->ECF_MOEDA,nTaxaVaria,ECF->ECF_SEQ,'PR') //FSM - 10/12/2012
                  EndIf
                  
                  lTrans := .T.
               Endif
               
               // Para gravar a variacao total no EC9
               nVariacaoTotal:=(ECF->ECF_VL_MOE*nTaxaVaria)-(ECF->ECF_VL_MOE*ECF->ECF_PARIDA)
               nFlutua := ECF->ECF_PARIDA
               If lVCReal .and. nVariacaoTotal # 0
                  IF nVariacaoTotal > 0
                     PR200_GrvPRV(nVariacaoTotal,"667",ECF->ECF_FORN+ECF->ECF_INVOIC+ECF->ECF_IDENTC,ECF->ECF_HAWB+Space(nTamForn+nTamMoeda)+ECF->ECF_IDENTC,"667",dData_Con," ",dData_Con,ECF->ECF_MOEDA,nTaxaVaria,ECF->ECF_SEQ,'PR') //FSM - 10/12/2012
                  ELSE
                     PR200_GrvPRV(nVariacaoTotal,"668",ECF->ECF_FORN+ECF->ECF_INVOIC+ECF->ECF_IDENTC,ECF->ECF_HAWB+Space(nTamForn+nTamMoeda)+ECF->ECF_IDENTC,"668",dData_Con," ",dData_Con,ECF->ECF_MOEDA,nTaxaVaria,ECF->ECF_SEQ,'PR') //FSM - 10/12/2012
                  ENDIF
                  If cPrv_Efe = "2"
                     IF nVariacao > 0
                        TransfECF(nVariacao, ECF->ECF_MOEDA, "667", ECF->ECF_FORN, ECF->ECF_INVOIC, ECF->ECF_HAWB, ECF->ECF_IDENTC, "667", dData_Con, ECF->ECF_SEQ, .F., 'PR', ECF->ECF_VL_MOE,,"")
                     Else
                        TransfECF(nVariacao, ECF->ECF_MOEDA, "668", ECF->ECF_FORN, ECF->ECF_INVOIC, ECF->ECF_HAWB, ECF->ECF_IDENTC, "668", dData_Con, ECF->ECF_SEQ, .F., 'PR', ECF->ECF_VL_MOE,,"")
                     EndIf
                     RecLock("ECF",.F.)
                     ECF->ECF_PARIDA := nTaxaVaria      // Taxa do Mes
                     ECF->ECF_FLUTUA := nFlutua         // Final do Mes anterior
                     ECF->(MSUNLOCK())
                     ECF->(DBGOTO(nRecECF))
                 EndIf              
               EndIf
            EndIf
         EndIf
         
         //AAF 08/10/2012 - Geração de variação cambial para transito da parcela paga antecipada.
         If lTrans
            
            If lFim//lExisteDI
               //nTaxaVaria := SW9->W9_TX_FOB 
               nTaxaVaria := nTxFim
            Else
               nTaxaVaria := BuscaTxECO(ECF->ECF_MOEDA, dData_Con, PR200VerDT(dData_Con))
            Endif
            
            If dDtComp < dDta_Inic
               nVariacao := (ECF->ECF_VL_MOE * nTaxaVaria) - (ECF->ECF_VL_MOE * nTxECG)
               nTxUtilizada := nTxECG
            Else
               nVariacao := (ECF->ECF_VL_MOE * nTaxaVaria) - (ECF->ECF_VL_MOE * nTxComp)
               nTxUtilizada := nTxComp
            EndIf
            
            If nVariacao # 0
               If cPrv_Efe = "2"      // Efetivacao                                  
                  TransfECF(nVariacao, ECF->ECF_MOEDA, If(nVariacao > 0, "514", "515"), ECF->ECF_FORN, ECF->ECF_INVOIC, ECF->ECF_HAWB, ECF->ECF_IDENTC, If(nVariacao>0, "514", "515"), If(lFim,dDtFim,dData_Con), ECF->ECF_SEQ, /*lDtEnce*/, 'PR', ECF->ECF_VL_MOE,,"")
                  Reclock("ECF",.F.)
                  ECF->ECF_PARIDA := nTaxaVaria      // Taxa do Mes
                  ECF->ECF_FLUTUA := nTxUtilizada    // Final do Mes anterior
                  ECF->(MsUnlock())
                  ECF->(DBGOTO(nRecECF))
               Endif   
               // Grava Variacoes 508/509 na previa                                          
               PR200_GrvPRV(nVariacao,If(nVariacao > 0, "514", "515"),ECF->ECF_FORN+ECF->ECF_INVOIC,ECF->ECF_HAWB+Space(nTamForn+nTamMoeda)+ECF->ECF_IDENTC,If(nVariacao > 0, "514", "515"),If(lFim,dDtFim,dData_Con)," ",If(lFim,dDtFim,dData_Con),ECF->ECF_MOEDA,nTaxaVaria,ECF->ECF_SEQ,'PR') //FSM - 10/12/2012
            Endif

         EndIf

         ECF->(DbSkip())
      Enddo
      SW9->(dbGoTo(nOrdW9))
            
   Elseif ECG->ECG_ORIGEM = "PO"    // PO - Pagamento Antecipado
         
      If ! ECF->(DbSeek(cFilECF+TIPO_DO_MODULO+ECG->ECG_HAWB+ECG->ECG_FORN+ECG->ECG_IDENTC+"PO"+"101"))
         If ! ECF->(DbSeek(cFilECF+TIPO_DO_MODULO+ECG->ECG_HAWB+ECG->ECG_FORN+ECG->ECG_IDENTC+"PO"+"60"))
            AADD(aTabMsg,STR0124)         
         EndIf
      EndIf
      
      If ECF->(!Eof())      
      
         cOrigem  := ECF->ECF_ORIGEM
         cInvoice := ECF->ECF_INVOIC
         cHawb    := ECF->ECF_HAWB
         cIdentc  := ECF->ECF_IDENTC         
         cForn    := ECF->ECF_FORN
         cMoeda   := ECF->ECF_MOEDA
         nValMoe  := 0      
         aInvoice := {}
         aSaida   := {}
         aInvMercadoria := {}
         
         //dDataEmis  := dData_Con   
         nTaxaFimMes:= BuscaTxECO(cMoeda, dData_Con, PR200VerDT(dData_Con))
         
         SW9->(dbSetOrder(1))
         SW8->(dbSetOrder(1))
         SW2->(dbSetOrder(1))
                    
         // Apura as Variacoes                                                
         Do While ECF->(!EOF()) .And. ECF->ECF_FILIAL == cFilECF .And. ECF->ECF_TPMODU == TIPO_DO_MODULO .and.;
            ECF->ECF_HAWB+ECF->ECF_IDENTC+ECF->ECF_ORIGEM+ECF->ECF_FORN = cHawb+cIdentc+cOrigem+cForn
            
            If ECF->ECF_ID_CAM $ '609'
               nReg   := ASCAN(aInvoice,{|x| X[1]=ECF->ECF_INVOICE .and. X[5]=ECF->ECF_SEQ})
               IF nReg = 0
                  AAdd(aInvoice, {ECF->ECF_INVOICE, ECF->ECF_HAWB, ECF->ECF_VL_MOE, If(ECF->ECF_NR_CON # '0000' .AND. ECF->ECF_NR_CON # '9999', nTxECG, ECF->ECF_PARIDA), ECF->ECF_SEQ, ECF->ECF_DTCONT, ECF->ECF_MOEDA, ECF->ECF_NR_CON, ECF->ECF_DI_NUM, ECF->ECF_PARIDA } )
               Else
                  aInvoice[nReg,4]  := If(ECF->ECF_NR_CON # '9999', nTxECG, ECF->ECF_PARIDA)
                  aInvoice[nReg,3]  += ECF->ECF_VL_MOE
                  aInvoice[nReg,6]  := ECF->ECF_DTCONT
                  aInvoice[nReg,8]  := ECF->ECF_NR_CON
                  aInvoice[nReg,10] := ECF->ECF_PARIDA
               EndIF

               nReg:=ASCAN(aSaida,{|x| X[1]=ECF->ECF_INVOICE .and. X[6]=ECF->ECF_SEQ})
               IF nReg # 0
                  // Nick 29/05/06 Inclui um teste para verificar se tiver data de embarque vai pegar taxa na
                  // data de embarque.
                  
                  /*
                  IF !EMPTY(SW6->W6_DT_EMB) .AND. SW6->W6_DT_EMB >= dDta_Inic .AND. SW6->W6_DT_EMB <= dDta_Fim
                    aSaida[nReg,5]:= ECF->ECF_PARIDA // BuscaTxECO(ECF->ECF_MOEDA,ECF->ECF_DTCONT) // Nick 07/06/06
                  
                  
                  
                    // aSaida[nReg,5]:=BuscaTxECO(ECF->ECF_MOEDA,ECF->ECF_DTCONT)
                  Else
                    aSaida[nReg,5]:=BuscaTxECO(ECF->ECF_MOEDA,dDta_Fim)   // ECF->ECF_PARIDA
                  Endif
                  */
                  
                  aSaida[nReg,5]:= If(ECF->ECF_NR_CON # '9999', nTxECG, ECF->ECF_PARIDA) //AAF 06/03/08
               EndIf               
               
               If ECF->ECF_NR_CON = '9999'
                  PR200_GrvPRV(ECF->ECF_VALOR,"609",ECF->ECF_FORN+ECF->ECF_INVOIC,ECF->ECF_HAWB+Space(nTamForn+nTamMoeda)+ECF->ECF_IDENTC,"609",ECF->ECF_DTCONT," ",ECF->ECF_DTCONT,ECF->ECF_MOEDA,ECF->ECF_PARIDA,ECF->ECF_SEQ,'PO') //FSM - 10/12/2012
               EndIf

               If cPrv_Efe = "2" .AND. ECF->ECF_NR_CON = '9999'
                  Reclock('ECF',.F.)
                  ECF->ECF_NR_CON := STRZERO(nNR_Cont+1,4,0)
                  ECF->(MsUnlock())
               EndIf
               
               aSort(aInvMercadoria,,,{|a,b| a[1]+a[2]+a[4]+a[5] < b[1]+b[2]+b[4]+b[5]})
               nPos := aScan(aInvMercadoria,{|x| x[1]==ECF->ECF_INVOICE .and. x[2]==ECF->ECF_HAWB .and.;
               x[4]==ECF->ECF_FORN .and. x[5]==ECF->ECF_SEQ })
               Do While nPos>0 .and. nPos<=Len(aInvMercadoria) .and. aInvMercadoria[nPos,1]==ECF->ECF_INVOICE .and. aInvMercadoria[nPos,2]==ECF->ECF_HAWB .and.;
               aInvMercadoria[nPos,4]==ECF->ECF_FORN .and. aInvMercadoria[nPos,5]==ECF->ECF_SEQ
                  aInvMercadoria[nPos,12] := ECF->ECF_PARIDA
                  nPos++
               EndDo

            EndIf
                                                                     
            If ECF->ECF_ID_CAM = '101'                         
               If ECF->ECF_PROCOR # SW6->W6_HAWB
                  SW6->(DBSEEK(cFilSW6+ECF->ECF_PROCOR))
               EndIf                                                      
               
               // Verifica se existe registro da DI no SW6
               dDataEmis := dData_Con
               
               IniVarEmbarque(dData_Con,SW6->W6_HAWB,ECF->ECF_INVOIC,ECF->ECF_FORN)

               If ECF->ECF_NR_CON = '9999'
                  If lComp//SW6->W6_DT_EMB > dDta_Inic .and. SW6->W6_DT_EMB < dData_Con  //GFC 09/08/04
                     //nTx101 := BuscaTxECO(ECF->ECF_MOEDA,SW6->W6_DT_EMB)
                     nTx101 := nTxComp//BuscaTxECO(ECF->ECF_MOEDA,dDtComp)
                  Else
                     nTx101 := BuscaTxECO(ECF->ECF_MOEDA,dDta_Inic)
                  Endif
                  If EasyEntryPoint("ECOPR999")    // Ponto de Entrada p/ controlar a variavel nTx101 conforme necessario
                     ExecBlock("ECOPR999",.F.,.F.,"TX_EMB")   
                  EndIf
                  If nTx101 = 0 .and. ASCAN(aTabMsg,{|X| X=STR0117+Alltrim(ECF->ECF_PROCOR)+" "+STR0117+Alltrim(ECF->ECF_IDENTC)}) = 0
                     AADD(aTabMsg,STR0117+Alltrim(ECF->ECF_PROCOR)+" "+STR0117+Alltrim(ECF->ECF_IDENTC))
                  EndIf
               ElseIF ECF->ECF_DTCONT >= dDta_Inic .AND. ECF->ECF_DTCONT <= dData_Con //Nick 24/05/06                         
                   nTx101 := ECF->ECF_PARIDA
               Else
                   nTx101 := ECG->ECG_ULT_TX
               EndIf
               
               If !lFim .OR. dDtFim >= dDta_Inic //Empty(SW6->W6_DT_ENCE) .OR. SW6->W6_DT_ENCE >= dDta_Inic
                  AADD(aInvMercadoria,{ECF->ECF_INVOICE, ECF->ECF_HAWB, ECF->ECF_VL_MOE, ECF->ECF_FORN, ECF->ECF_SEQ, ECF->ECF_DTCONT, ECF->ECF_MOEDA, ECF->ECF_NR_CON, ECF->ECF_DI_NUM, ECF->ECF_IDENTC, nTx101, 0, ECF->ECF_PROCOR}) //GFC 09/08/04
               EndIf
               
               nReg := ASCAN(aInvoice,{|x| X[1]=ECF->ECF_INVOICE .and. X[5]=ECF->ECF_SEQ})
               IF nReg = 0
                  AAdd(aInvoice, {ECF->ECF_INVOICE, ECF->ECF_HAWB, ECF->ECF_VL_MOE*-1, 0, ECF->ECF_SEQ, ECF->ECF_DTCONT, ECF->ECF_MOEDA, ECF->ECF_NR_CON, ECF->ECF_DI_NUM, 0 } )
               Else
                  aInvoice[nReg,3] -= ECF->ECF_VL_MOE
               EndIF

               If ECF->ECF_NR_CON = '9999'                   
                  AAdd(aSaida, {ECF->ECF_INVOICE, ECF->ECF_HAWB, ECF->ECF_VL_MOE, nTx101, 0, ECF->ECF_SEQ, ECF->ECF_DTCONT, ECF->ECF_MOEDA, ECF->ECF_DI_NUM, ECF->ECF_INVORI, ECF->ECF_DI_NUM, ECF->ECF_PROCOR } )
               EndIF                              
            Endif  
                                                                                                
            ECF->(DbSkip())   

            If ECF->ECF_ID_CAM # '101' .AND. ! ECF->(EOF()) .AND. ECF->ECF_FILIAL==cFilECF .and.;
               ECF->ECF_TPMODU == TIPO_DO_MODULO .and.;
               ECF->ECF_HAWB+ECF->ECF_FORN+ECF->ECF_IDENTC+ECF->ECF_ORIGEM = cHawb+cForn+cIdentc+cOrigem .AND. ;
               Left(ECF->ECF_ID_CAM,2) # '60' .AND. Val(Left(ECF->ECF_ID_CAM,2)) < 65
               ECF->(DbSeek(cFilECF+TIPO_DO_MODULO+ECG->ECG_HAWB+ECG->ECG_FORN+ECG->ECG_IDENTC+"PO"+"60"))
            EndIf

         Enddo
         SW9->(dbGoTo(nOrdW9))
         SW8->(dbGoTo(nOrdW8))
         SW2->(dbGoTo(nOrdW2))
         
         // Grava as variacoes no ECF e na previa as sequencias..         
         nTx       := 0                                                              
         nVariacao := 0
         nValorPag := 0     
         dDta_Ant  := dDta_Fim

         For i=1 to Len(aInvoice)
             If aInvoice[i,3] # 0
                // Calcula a variacao
                nVariacao := (aInvoice[i,3] * nTaxaFimMes) - (aInvoice[i,3] * aInvoice[i,4])                          

                // Gera o Evento 502/505 e Grava no ECF caso seja efetivacao
                If cPrv_Efe = "2" .and. nVariacao # 0
                   //TransfECF(nVariacao, aInvoice[i,7], If(nVariacao > 0,"510","511"), cForn, aInvoice[i,1], cHawb, cIdentc, If(nVariacao > 0,"502","505"), aInvoice[i,6], aInvoice[i,5], .F. , 'PO', If(aInvoice[i,3]<0, aInvoice[i,3]*-1, aInvoice[i,3]),,"" ) Nick 18/05/06
                   TransfECF(nVariacao, aInvoice[i,7], If(nVariacao > 0,"510","511"), cForn, aInvoice[i,1], cHawb, cIdentc, If(nVariacao > 0,"510","511"), dData_Con,aInvoice[i,5], .F. , 'PO', If(aInvoice[i,3]<0, aInvoice[i,3]*-1, aInvoice[i,3]),,"" )
                   Reclock("ECF",.F.)
                   ECF->ECF_PARIDA := nTaxaFimMes     // Taxa do Mes
                   ECF->ECF_FLUTUA := aInvoice[i,4]   // Final do Mes anterior
                   ECF->(MsUnlock())                   
                Endif   
          
                // Grava na previa
                If nVariacao # 0             
                   // PR200_GrvPRV(nVariacao,If(nVariacao > 0,"510","511"),cForn+aInvoice[i,1],cHawb+cIdentc,If(nVariacao > 0,"510","511"),aInvoice[i,6]," ",aInvoice[i,6],aInvoice[i,7],aInvoice[i,4],aInvoice[i,5],'PO')    
                   PR200_GrvPRV(nVariacao,If(nVariacao > 0,"510","511"),cForn+aInvoice[i,1],cHawb+Space(nTamForn+nTamMoeda)+cIdentc,If(nVariacao > 0,"510","511"),dData_Con," ",dData_Con,aInvoice[i,7],nTaxaFimMes,aInvoice[i,5],'PO')//FSM - 10/12/2012    
                EndIF
             Endif   
         Next
         
         For i=1 to Len(aSaida)            
             nReg := ASCAN(aInvoice,{|x| X[1]=aSaida[i,1] .and. X[5]=aSaida[i,6]})             
             If nReg > 0                       
                If ECF->(DbSeek(cFilECF+TIPO_DO_MODULO+ECG->ECG_HAWB+ECG->ECG_FORN+ECG->ECG_IDENTC+"PO"+"101"+aSaida[i,1]+aSaida[i,6]+aSaida[i,12])) .AND. ECF->ECF_NR_CON = '9999' //GFC 02/08/04 - Incluído o aSaida[i,12] (ECF_PROCOR) na chave.
                   nRecECF := ECF->(RECNO())
                   nVariacao := (ECF->ECF_VL_MOE * aSaida[i,4]) - (ECF->ECF_VL_MOE * aSaida[i,5]) // Nick 25/05/06 nTxECG) //aSaida[i,5]

                   // Gera o Evento 502/505 e Grava no ECF caso seja efetivacao
                   If cPrv_Efe = "2" .and. nVariacao # 0
                      TransfECF(nVariacao, ECF->ECF_MOEDA, If(nVariacao > 0,"510","511"), ECF->ECF_FORN, ECF->ECF_INVOICE, ECF->ECF_HAWB, ECF->ECF_IDENTC, If(nVariacao > 0,"510","511"), ECF->ECF_DTCONT, ECF->ECF_SEQ, .F. , 'PO', ECF->ECF_VL_MOE,,aSaida[i,12] )
                      Reclock("ECF",.F.)
                      ECF->ECF_PARIDA := aSaida[i,4] // Nick 26/05/06 nTaxaFimMes        // Taxa do Mes
                      ECF->ECF_FLUTUA := aInvoice[nReg,4]   // Final do Mes anterior
                      ECF->(MsUnlock())                   
                   Endif   
          
                   // Grava na previa
                   If nVariacao # 0             
                      // PR200_GrvPRV(nVariacao,If(nVariacao > 0,"510","511"),If(lExisteFor, ECF->ECF_FORN, "")+ECF->ECF_INVOIC,ECF->ECF_HAWB+ECF->ECF_IDENTC,If(nVariacao > 0,"510","511"),ECF->ECF_DTCONT," ",ECF->ECF_DTCONT,ECF->ECF_MOEDA,ECF->ECF_PARIDA,ECF->ECF_SEQ,'PO') //Nick 07/06/06
                      PR200_GrvPRV(nVariacao,If(nVariacao > 0,"510","511"),ECF->ECF_FORN+ECF->ECF_INVOIC,ECF->ECF_HAWB+Space(nTamForn+nTamMoeda)+ECF->ECF_IDENTC,If(nVariacao > 0,"510","511"),ECF->ECF_DTCONT," ",ECF->ECF_DTCONT,ECF->ECF_MOEDA,aSaida[i,4],ECF->ECF_SEQ,'PO') //FSM - 10/12/2012
                   Endif                     
                   
                   ECF->(DBGOTO(nRecECF))

                   RecLock("ECF",.F.)
                   ECF->ECF_VALOR  := (ECF->ECF_VL_MOE * aSaida[i,4])
                   ECF->ECF_LINK   := If(nVariacao > 0,"510","511")
                   ECF->ECF_NR_CON := If(cPrv_Efe = "2", STRZERO(nNR_Cont+1,4,0),'9999')
                   ECF->ECF_PARIDA := aSaida[i,4]     // Final do Mes atual
                   ECF->ECF_FLUTUA := nTXECG          // Final do Mes anterior
                   ECF->(MSUNLOCK())
                   
                   // Grava na previa
                   PR200_GrvPRV(ECF->ECF_VALOR,"101",ECF->ECF_FORN+ECF->ECF_INVOIC,ECF->ECF_HAWB+Space(nTamForn+nTamMoeda)+ECF->ECF_IDENTC,"101",ECF->ECF_DTCONT," ",ECF->ECF_DTCONT,ECF->ECF_MOEDA,ECF->ECF_PARIDA,ECF->ECF_SEQ,'PO') //FSM - 10/12/2012
                   
                EndIf

                n109 := (ECF->ECF_VL_MOE * aSaida[i,4]) 
                If n109 # 0 .and. (EC6->(DbSeek(cFilEC6+"IMPORT"+"109"+ECF->ECF_IDENTC)) .OR. EC6->(DbSeek(cFilEC6+"IMPORT"+"109"))) // .AND. ECF->ECF_NR_CON = '9999' // Nick 07/06/06 .AND. (aSaida[i,7] >= dDta_Inic .AND. aSaida[i,7] <= dDta_Fim)
                   // Grava na previa o evento 109 caso o mesmo exista no EC6
                   PR200_GrvPRV(n109,"109",ECF->ECF_FORN+ECF->ECF_INVOIC,ECF->ECF_HAWB+Space(nTamForn+nTamMoeda)+ECF->ECF_IDENTC,"109",ECF->ECF_DTCONT," ",ECF->ECF_DTCONT,ECF->ECF_MOEDA,ECF->ECF_PARIDA,ECF->ECF_SEQ,'PO') //FSM - 10/12/2012
                   
                   If cPrv_Efe = "2"
                      TransfECF(n109, aSaida[i,8], "109", cForn, aSaida[i,1], cHawb, cIdentc, "109", aSaida[i,7], aSaida[i,6], .F., 'PO', ECF->ECF_VL_MOE,,aSaida[i,12])
                      RecLock("ECF",.F.)
                      ECF->ECF_PARIDA := aSaida[i,4]     // Taxa do Mes
                      ECF->(MSUNLOCK())
                   EndIf
                EndIf
                                       
             Endif                                                         			              
         Next    

         For i:=1 to Len(aInvMercadoria)   //GFC 09/08/04
            If aInvMercadoria[i,13] <> SW6->W6_HAWB
               SW6->(dbSeek(cFilSW6+aInvMercadoria[i,13]))
            EndIf
            
            SW8->(dbSeek(xFilial("SW8")+SW6->W6_HAWB))
            nRecSW8   := 0
            cPo := ""
            Do While !SW8->(EOF()) .and. SW8->W8_FILIAL==xFilial("SW8") .and. SW8->W8_HAWB==SW6->W6_HAWB
               If !SW8->W8_PO_NUM $ cPO
//                SW2->(dbSeek(xFilial("SW2")+SW8->W8_PO_NUM)) // Nick 06/06/06
                  cPo += "/"+SW8->W8_PO_NUM
//                If SW2->W2_NR_PRO == aInvMercadoria[i,1]  // Nick 06/06/06
                  If ALLTRIM(SW8->W8_PO_NUM) == ALLTRIM(aInvMercadoria[i,2])
                     nRecSW8 := SW8->(RECNO())
                     Exit
                  EndIf
               EndIf
               SW8->(dbSkip())
            EndDo
            SW8->(DBGOTO(nRecSW8))
            SW9->(dbSeek(xFilial("SW9")+SW8->W8_INVOICE+SW8->W8_FORN)) // Nick 06/06/06
            
            IniVarEmbarque(dData_Con,aInvMercadoria[i][13],SW8->W8_INVOICE,SW8->W8_FORN)
            
            IF lFim//lComp//!Empty(SW6->W6_DT_ENCE) .AND. (SW6->W6_DT_ENCE <= dData_Con) // Nick 15/05/06
               //nTxDI := SW9->W9_TX_FOB // Nick 06/06/06
               nTxDI := nTxFim//nTxComp       admin		
               
               //** AAF 06/03/08 - Grava a ultima taxa de DI utilizada.
               IF dDtFim > dUltTxDt //SW6->W6_DT_ENCE > dUltTxDt
                  nUltTx   := nTxDI
                  //dUltTxDt := SW6->W6_DT_ENCE
                  dUltTxDt := dDtComp
               EndIf
               //**
               
               //dDta_Aux := SW6->W6_DT_ENCE
               //dDta_Aux := dDtComp
               dDta_Aux := dDtFim
            Else                       
               nTxDI := BuscaTxECO(aInvMercadoria[i,7],dData_Con)
               dDta_Aux := dData_Con
            EndIf
      
            nVariacao := (aInvMercadoria[i,3] * nTxDI) - (aInvMercadoria[i,3] * aInvMercadoria[i,11])
            If nVariacao # 0
               IF nVariacao > 0
           	      // PR200_GrvPRV(nVariacao,"512",aInvMercadoria[i,4]+aInvMercadoria[i,1],aInvMercadoria[i,2]+aInvMercadoria[i,10],"512",aInvMercadoria[i,6]," ",aInvMercadoria[i,6],aInvMercadoria[i,7],aInvMercadoria[i,11],aInvMercadoria[i,5],'PO')
           	      PR200_GrvPRV(nVariacao,"512",aInvMercadoria[i,4]+aInvMercadoria[i,1],aInvMercadoria[i,2]+Space(nTamForn+nTamMoeda)+aInvMercadoria[i,10],"512",dDta_Aux," ",dDta_Aux,aInvMercadoria[i,7],nTxDI,aInvMercadoria[i,5],'PO') //FSM - 10/12/2012
               ELSE
   			      // PR200_GrvPRV(nVariacao,"513",aInvMercadoria[i,4]+aInvMercadoria[i,1],aInvMercadoria[i,2]+aInvMercadoria[i,10],"513",aInvMercadoria[i,6]," ",aInvMercadoria[i,6],aInvMercadoria[i,7],aInvMercadoria[i,11],aInvMercadoria[i,5],'PO')
   			      PR200_GrvPRV(nVariacao,"513",aInvMercadoria[i,4]+aInvMercadoria[i,1],aInvMercadoria[i,2]+Space(nTamForn+nTamMoeda)+aInvMercadoria[i,10],"513",dDta_Aux," ",dDta_Aux,aInvMercadoria[i,7],nTxDI,aInvMercadoria[i,5],'PO') //FSM - 10/12/2012
               ENDIF
               // Gera o Evento 512/513 e Grava no ECF caso seja efetivacao
               If cPrv_Efe = "2" .and. nVariacao # 0
                  //TransfECF(nVariacao, ECF->ECF_MOEDA, If(nVariacao > 0,"512","513"), ECF->ECF_FORN, ECF->ECF_INVOICE, ECF->ECF_HAWB, ECF->ECF_IDENTC, If(nVariacao > 0,"502","505"), ECF->ECF_DTCONT, ECF->ECF_SEQ, .F. , 'PO', ECF->ECF_VL_MOE,,aSaida[i,12] )
//                TransfECF(PValor,         PMoeda,                   PIdent,                 PForn,            PInvoice,            PHawb,               PCCusto,                       PLink,               PData,            PSeq,             PTransf,POrigem,   PValorMoe,   PNrCont, cProCor)
//                            1               2                          3                      4                  5                    6                   7                             8                      9                  10             11     12          13           14        15
                  TransfECF(nVariacao,aInvMercadoria[i,7], If(nVariacao > 0,"512","513"),aInvMercadoria[i,4],aInvMercadoria[i,1],aInvMercadoria[i,2],aInvMercadoria[i,10], If(nVariacao > 0,"512","513"),aInvMercadoria[i,6],aInvMercadoria[i,5], .F. , 'PO',aInvMercadoria[i,3],   ,aInvMercadoria[i,2] )
                  Reclock("ECF",.F.)
                  ECF->ECF_PARIDA := nTxDI // Nick 26/05/06 nTaxaFimMes        // Taxa do Mes
                  ECF->ECF_FLUTUA := aInvMercadoria[i,11]   // Final do Mes anterior
                  ECF->(MsUnlock())                   
               ENDIF
            Endif

            If lVCReal .And. lFim//lComp//!Empty(SW6->W6_DT_ENCE)
               nVariacao := (aInvMercadoria[i,3] * nTxDI) - (aInvMercadoria[i,3] * aInvMercadoria[i,12])
               If nVariacao # 0
                  IF nVariacao > 0
               	     PR200_GrvPRV(nVariacao,"677",aInvMercadoria[i,4]+aInvMercadoria[i,1],aInvMercadoria[i,2]+Space(nTamForn+nTamMoeda)+aInvMercadoria[i,10],"677",aInvMercadoria[i,6]," ",aInvMercadoria[i,6],aInvMercadoria[i,7],aInvMercadoria[i,12],aInvMercadoria[i,5],'PO') //FSM - 10/12/2012
                  ELSE
			         PR200_GrvPRV(nVariacao,"678",aInvMercadoria[i,4]+aInvMercadoria[i,1],aInvMercadoria[i,2]+Space(nTamForn+nTamMoeda)+aInvMercadoria[i,10],"678",aInvMercadoria[i,6]," ",aInvMercadoria[i,6],aInvMercadoria[i,7],aInvMercadoria[i,12],aInvMercadoria[i,5],'PO') //FSM - 10/12/2012
                  ENDIF
                  If cPrv_Efe = "2"
                     IF nVariacao > 0
                        TransfECF(nVariacao, aInvMercadoria[i,7], "677", cForn, aInvMercadoria[i,1], cHawb, cIdentc, "677", aInvMercadoria[i,6], aInvMercadoria[i,5], .F., 'PO', aInvMercadoria[i,3],,"")
                     Else
                        TransfECF(nVariacao, aInvMercadoria[i,7], "678", cForn, aInvMercadoria[i,1], cHawb, cIdentc, "678", aInvMercadoria[i,6], aInvMercadoria[i,5], .F., 'PO', aInvMercadoria[i,3],,"")
                     EndIf
                     If ECF->(DbSeek(cFilECF+TIPO_DO_MODULO+ECG->ECG_HAWB+ECG->ECG_FORN+ECG->ECG_IDENTC+"PO"+"101")) .or.;
                     ECF->(DbSeek(cFilECF+TIPO_DO_MODULO+ECG->ECG_HAWB+ECG->ECG_FORN+ECG->ECG_IDENTC+"PO"+"60"))
                        ECF->(RecLock("ECF",.F.))
                        ECF->ECF_PARIDA := nTxDI        // Taxa do Mes
                        ECF->ECF_FLUTUA := nTXECG       // Final do Mes anterior
                        ECF->(MSUNLOCK())
                     EndIf
                  EndIf
               EndIf
            EndIf
         Next i
      Endif
   Endif

   // Grava no ECG a ultima taxa usada
   If cPrv_Efe = "2"
      Reclock('ECG',.F.)
      //ECG->ECG_ULT_TX := If(ECG->ECG_ORIGEM="PR",nTaxaVaria,nTaxaFimMes) Nick 09/06/06

      //IF !Empty(SW6->W6_DT_ENCE) .AND. (SW6->W6_DT_ENCE <= dData_Con)
      //   ECG->ECG_ULT_TX := If(ECG->ECG_ORIGEM="PR",nTaxaVaria,)
      
      //AAF 06/03/08 - Grava a ultima taxa utilizada apenas quando encerrar o saldo dos adiantamentos.
      //ECG->ECG_ULT_TX := If(ECG->ECG_ORIGEM="PR",nTaxaVaria,If(nUltTx > 0,nUltTx,nTxDI)) //AAF 06/03/08
      ECG->ECG_ULT_TX := If(ECG->ECG_ORIGEM="PR",nTaxaVaria,If(nTxDI > 0,nTxDI,nTaxaFimMes)) //AAF 06/03/08
      
      If lFim
         ECG->ECG_DTENCE := dData_Con
      Endif
      
      IF (ECG->ECG_NR_CON = '9999') .or. (ECG->ECG_NR_CON = '0000')
         ECG->ECG_NR_CON := STRZERO(nNR_Cont+1,4,0)
      Endif
      ECG->(MsUnlock())
   Endif
   
   ECG->(DbSkip())						 
Enddo   						

EC5->(DbSetOrder(nOrdemEC5))
EC5->(DbGoto(nEC5Recno))
EC9->(DbSetOrder(nOrdemEC9))
EC9->(DbGoto(nEC9Recno))
ECF->(DbSetOrder(1))
lTipoCont:=1 // Para na previa gravar o EC7
Return .T.     

*----------------------------------------------------------------------------------------------------------------------------------------*
Static FUNCTION TransfECF(PValor,PMoeda,PIdent,PForn,PInvoice,PHawb,PCCusto,PLink,PData,PSeq,PTransf,POrigem, PValorMoe, PNrCont, cProCor)
// Grava Variacao gerada nos pagtos. antecipados / Adiantamentos no ECF
*----------------------------------------------------------------------------------------------------------------------------------------*
Local MCTA_DEB := " ", MCTA_CRE := " ", lAchou:=.F.
If(Empty(cProcOr), cProcOr:="", )

lRefresh:=.t.

//AAF - 29/09/2012 - Usar a configuração do centro de custo padrão caso não haja cadastro no EC6 para o centro de custo especifico.
If !EC6->(DbSeek(cFilEC6+"IMPORT"+PLink+PCCusto))
   EC6->(DbSeek(cFilEC6+"IMPORT"+PLink))
EndIf

//AAF - 29/09/2012 - Traduzir as mascaras de conta contabil.
MCTA_DEB := EasyMascCon(EC6->EC6_CTA_DB,PForn,"",/* cImport */,/* cLojaImp */,"","","",'IMPORT',PLink) //MCTA_DEB := EC6->EC6_CTA_DB
MCTA_CRE := EasyMascCon(EC6->EC6_CTA_CR,PForn,"",/* cImport */,/* cLojaImp */,"","","",'IMPORT',PLink) //MCTA_CRE := EC6->EC6_CTA_CR

//GFC - 27/01/2005 - INICIO
lAchou := ECF->(DbSeek(cFilECF+TIPO_DO_MODULO+PHawb+PForn+PCCusto+POrigem+PIdent+PInvoice+PSeq+cProCor)) .and.;
          ECF->ECF_NR_CON = '9999'
If !lAchou
   Do While !ECF->(EOF()) .and. ECf->ECF_FILIAL==cFilECF .and. ECF->ECF_TPMODU == TIPO_DO_MODULO .and.;
   ECF->ECF_HAWB==PHawb .and.;
   ECF->ECF_FORN==PForn.and. ECF->ECF_IDENTC==PCCusto .and. ECF->ECF_ORIGEM==POrigem .and.;
   ECF->ECF_ID_CAM==PIdent .and. ECF->ECF_INVOIC==PInvoice .and. ECF->ECF_SEQ==PSeq .and. ECF->ECF_PROCOR==cProCor .and.;
   ECF->ECF_NR_CON <> '9999'
      ECF->(dbSkip())
   EndDo
   If !ECF->(EOF()) .and. ECf->ECF_FILIAL==cFilECF .and. ECF->ECF_TPMODU == TIPO_DO_MODULO .and.;
   ECF->ECF_HAWB==PHawb .and.;
   ECF->ECF_FORN==PForn.and. ECF->ECF_IDENTC==PCCusto .and. ECF->ECF_ORIGEM==POrigem .and.;
   ECF->ECF_ID_CAM==PIdent .and. ECF->ECF_INVOIC==PInvoice .and. ECF->ECF_SEQ==PSeq .and. ECF->ECF_PROCOR==cProCor .and.;
   ECF->ECF_NR_CON == '9999'
      lAchou := .T.
   EndIf
EndIf
// GFC - FIM

If !lAchou
   Reclock('ECF',.T.)
   ECF->ECF_FILIAL := xFilial('ECF')
   ECF->ECF_TPMODU := TIPO_DO_MODULO //** GFC - 20/02/06 
   ECF->ECF_HAWB   := PHawb
   ECF->ECF_INVOIC := PInvoice
   ECF->ECF_ID_CAM := PIdent
   ECF->ECF_IDENTC := PCCusto
   ECF->ECF_DTCONT := PData
   ECF->ECF_NR_CON := If(PNrCont = NIL, (If(cPrv_Efe = "2", STRZERO(nNR_Cont+1,4,0),'9999')), PNrCont)
   ECF->ECF_VALOR  := PValor 
   ECF->ECF_MOEDA  := PMoeda 
   ECF->ECF_DESCR  := EC6->EC6_DESC
   ECF->ECF_SEQ    := PSeq
   ECF->ECF_ORIGEM := POrigem
   ECF->ECF_FORN   := PForn
   ECF->ECF_VL_MOE := PValorMoe
   ECF->ECF_PROCOR := cProCor
Else   //If ECF->ECF_NR_CON = '9999'
   Reclock('ECF',.F.)
EndIf
If MCTA_DEB = "999999999999999"
   IF SA2->(DBSEEK(cFilSA2+pForn)) .AND. ! EMPTY(ALLTRIM(pForn))
      MCTA_DEB = IF(!EMPTY(ALLTRIM(SA2->A2_CONTAB)), ALLTRIM(SA2->A2_CONTAB),"999999999999999")
   ENDIF
Endif
If MCTA_CRE = "999999999999999"
   IF SA2->(DBSEEK(cFilSA2+pForn)) .AND. ! EMPTY(ALLTRIM(pForn))
      MCTA_CRE = IF(!EMPTY(ALLTRIM(SA2->A2_CONTAB)), ALLTRIM(SA2->A2_CONTAB),"999999999999999")
   ENDIF
Endif
ECF->ECF_CTA_DB := MCTA_DEB
ECF->ECF_CTA_CR := MCTA_CRE   
ECF->ECF_LINK   := PLink
ECF->(MSUNLOCK())

RETURN .T.

Static Function IniVarEmbarque(dData_Con, cHawb,cInvoice,cForn)
Local dDtVazia := CToD("  /  /  ")
Local aVars, i

aVars := {}
aAdd(aVars,{"dDtEmba"  ,dDtVazia})
aAdd(aVars,{"dDtEmba"  ,dDtVazia})
aAdd(aVars,{"dDtDI"    ,dDtVazia})
aAdd(aVars,{"dDtNF"    ,dDtVazia})
aAdd(aVars,{"dDtEntr"  ,dDtVazia})
aAdd(aVars,{"dDtEnce"  ,dDtVazia})
aAdd(aVars,{"dDtComp"  ,dDtVazia})
aAdd(aVars,{"nTxComp"  ,0})
aAdd(aVars,{"dDataEmis",dDtVazia})
aAdd(aVars,{"lComp"    ,.F.})
aAdd(aVars,{"lDtEnce"  ,.F.})
aAdd(aVars,{"dDtFim"   ,dDtVazia})
aAdd(aVars,{"nTxFim"   ,0})
aAdd(aVars,{"lFim"     ,.F.})

For i := 1 To Len(aVars)
   If Type(aVars[i][1])=="U"
      _SetOwnerPrvt(aVars[i][1],aVars[i][2])
   EndIf
Next i

Begin Sequence

Posicione("SW6",1,xFilial("SW6")+cHawb,"")

If SW6->(EoF())
   Break
EndIf

dDtEmba   := SW6->W6_DT_EMB  //&("SW6->("+EasyGParam("",,"W6_DT_EMB") +")")
dDtEmba   := if(dDtEmba <= dDta_Fim,dDtEmba,dDtVazia)

dDtDI     := SW6->W6_DTREG_D //&("SW6->("+EasyGParam("",,"W6_DTREG_D")+")")
dDtDI     := if(dDtDI   <= dDta_Fim,dDtDI  ,dDtVazia)

dDtNF     := SW6->W6_DT_NF   //&("SW6->("+EasyGParam("",,"W6_DT_NF")  +")")
dDtNF     := if(dDtNF   <= dDta_Fim,dDtNF  ,dDtVazia)

dDtEntr   := SW6->W6_DT_ENTR //&("SW6->("+EasyGParam("",,"W6_DT_ENTR")+")")
dDtEntr   := if(dDtEntr <= dDta_Fim,dDtEntr,dDtVazia)

dDtEnce   := SW6->W6_DT_ENCE //&("SW6->("+EasyGParam("",,"W6_DT_ENCE")+")")
dDtEnce   := if(dDtEnce <= dDta_Fim,dDtEnce,dDtVazia)

//SW9->(dbSeek(xFilial("SW9")+cInvoice+cForn/*+ECF->ECF_HAWB*/))//NOPADO POR AOM 19/07/2012
Posicione("SW9",1,xFilial("SW9")+cInvoice+cForn,"")

If SW9->(EoF())
   Break
EndIf

//Inicio de transito / compensação
If EasyGParam("MV_ECO0001",,"2") == "1" //Encerramento
   dDtComp   := dDtEnce
   nTxComp   := SW9->W9_TX_FOB 
   dDataEmis := SW6->W6_DTREG_D
ElseIf EasyGParam("MV_ECO0001",,"2") == "2"//Embarque
   dDtComp   := dDtEmba
   nTxComp   := if(!Empty(dDtComp),BuscaTxECO(SW9->W9_MOE_FOB, dDtEmba, PR200VerDT(dDtEmba)),0)
   dDataEmis := dDtEmba
ElseIf EasyGParam("MV_ECO0001",,"2") == "3" //Registro DI
   dDtComp   := dDtDI
   nTxComp   := SW9->W9_TX_FOB 
   dDataEmis := SW6->W6_DTREG_D
ElseIf EasyGParam("MV_ECO0001",,"2") == "4" //Emissão NF
   dDtComp   := dDtNF
   nTxComp   := SW9->W9_TX_FOB 
   dDataEmis := SW6->W6_DTREG_D
ElseIf EasyGParam("MV_ECO0001",,"2") == "5" //Data de Entrega
   dDtComp   := dDtEntr
   nTxComp   := SW9->W9_TX_FOB 
   dDataEmis := SW6->W6_DTREG_D
EndIf

//Fim de transito
If EasyGParam("MV_ECO0002",,"4") == "1" //Encerramento
   dDtFim   := dDtEnce
   nTxFim   := SW9->W9_TX_FOB 
ElseIf EasyGParam("MV_ECO0002",,"4") == "2" //Embarque
   dDtFim   := dDtEmba
   nTxFim   := if(!Empty(dDtComp),BuscaTxECO(ECF->ECF_MOEDA, dDtEmba, PR200VerDT(dDtEmba)),0)
ElseIf EasyGParam("MV_ECO0002",,"4") == "3" //Registro DI
   dDtFim   := dDtDI
   nTxFim   := SW9->W9_TX_FOB 
ElseIf EasyGParam("MV_ECO0002",,"4") == "4" //Emissão NF
   dDtFim   := dDtNF
   nTxFim   := SW9->W9_TX_FOB 
ElseIf EasyGParam("MV_ECO0002",,"4") == "5" //Data de Entrega
   dDtFim   := dDtEntr
   nTxFim   := SW9->W9_TX_FOB 
EndIf

End Sequence

lComp   := !Empty(dDtComp)
lFim    := !Empty(dDtFim)
lDtEnce := !Empty(dDtEnce)

Return Nil

*--------------------------*
Function PREIC999TotC()
*--------------------------*
Local i:=1, cFilECH := xFilial('ECH')

For i:=1 to Len(aTotContas)
    Reclock('ECH',.T.)
    ECH->ECH_FILIAL := cFilECH
    ECH->ECH_TPMODU := 'IMPORT'
    ECH->ECH_NR_CON := STRZERO(nNR_Cont+1,4,0)
    ECH->ECH_CONTA  := aTotContas[i,1]
    ECH->ECH_VAL_DB := aTotContas[i,2]
    ECH->ECH_VAL_CR := aTotContas[i,3]
    ECH->(Msunlock())
    
    nGeralDB += aTotContas[i,2]
    nGeralCR += aTotContas[i,3]
Next 
Return .T.