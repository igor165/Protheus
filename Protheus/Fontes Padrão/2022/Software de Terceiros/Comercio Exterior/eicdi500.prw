//------------------------------------------------------------------------------------//
//Empresa...: AVERAGE TECNOLOGIA
//Funcao....: EICDI500()
//Autor.....: Alex Wallauer (AWR)
//Data......: 08 de Setembro de 2001, 11:00
//Sintaxe...: #EICDI500 - Desembaraco
//            #EICDI501 - Embarque
//            #EICDI502 - Desembaraco de Nacionalizacao
//Uso.......: SIGAEIC
//Versao....: Protheus - 6.09
//Descricao.: Mega Tratamento de D.I. Eletronica...
//Revisão   : dez/2015 - implementação do rateio por adição.
//            Através do parâmetro MV_EIC0060, passa a ser possível informar as despesas base de ICMS que serão rateadas pela
//            quantidade de adições do processo. Os valores das despesas serão isoladas na variável nSomaDespRatAdicao.
//------------------------------------------------------------------------------------//
#INCLUDE "Eicdi500.ch"
//#include "FiveWin.ch"
#include "Average.ch"
#Include "TOPCONN.ch"
#define MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)
#define COLUNA_FINAL   (oDlg:nClientWidth-4)/2
#define COLUNA_FINAL_I (oDlgItens:nClientWidth-4)/2
#define FECHTO_EMBARQUE       "1"
#define FECHTO_DESEMBARACO    "2"
#define FECHTO_NACIONALIZACAO "3"
#define FINALIZAR (nOpca:=1,If(ValType(oDlg) == "O",oDlg:End(),oDLGBACK:End()))
#define VISUAL    2
#define INCLUSAO  3
#define ALTERACAO 4
#define ESTORNO   5
#define ENCERRAR  6 // Acb - 22/10/2010 - Melhoria para cancelamento do desembaraço em casa de estravio de mercadoria.
#define ENTER CHR(10)+CHR(13)
#define SIM     "1"
#define NAO     "2"
#define GENERICO     "06"
#define NCM_GENERICA "99999999"

#define DUIMP_INTEGRADA "1"
#define DUIMP_MANUAL    "2"
#define DUIMP           "2"

Function EICDI501(lSchedule,lTemDI_Ele) //Antiga EIDI401   //TRP-10/12/07- Inclusão dos parâmetros lSchedule e lTemDI_Ele /Cópia da v609A

PRIVATE cCadastro  := STR0021 //"Embarques"
PRIVATE cTitulo    := STR0022 //"Fechamento do Embarque"
PRIVATE MOpcao     := FECHTO_EMBARQUE
PRIVATE _Declaracao:=.F.
Private aEmbarques :=NIL
DEFAULT lSchedule := .F.   //TRP-10/12/07

DI500Main(lSchedule,lTemDI_Ele)//,aAutoCapa,aParamAutDesp,nOpcAuto) //TRP-10/12/07 -  CRF-23/05/2011
RETURN .T. 

Function EICDI502(lSchedule,lTemDI_Ele) //Antiga EIDI402   //TRP-10/12/07- Inclusão dos parâmetros lSchedule e lTemDI_Ele /Cópia da v609A

PRIVATE cCadastro  := STR0023 //"Desembaraco"
PRIVATE cTitulo    := STR0024 //"Fechamento de Desembaraco"
PRIVATE MOpcao     := FECHTO_DESEMBARACO
PRIVATE _Declaracao:=.F.
Private aEmbarques :=NIL
DEFAULT lSchedule := .F.   //TRP-10/12/07


DI500Main(lSchedule,lTemDI_Ele)//,aAutoCapa,aParamAutDesp,nOpcAuto)  //TRP-10/12/07 //CRF-23/05/2011
RETURN .T.

Function EICDI503(lSchedule,lTemDI_Ele) //Antiga EIDI403     //TRP-10/12/07- Inclusão dos parâmetros lSchedule e lTemDI_Ele /Cópia da v609A

PRIVATE cCadastro  := STR0027 //"Desembaraço de Nacionalizacao"
PRIVATE cTitulo    := STR0028 //"Fechamento de Desembaraco de Nacionalizacao"
PRIVATE MOpcao     := FECHTO_NACIONALIZACAO
PRIVATE _Declaracao:=.F.
Private aEmbarques :=NIL
DEFAULT lSchedule := .F. //TRP-10/12/07

DI500Main(lSchedule,lTemDI_Ele)//,aAutoCapa,aParamAutDesp,nOpcAuto) //TRP-10/12/07 //CRF-23/05/2011
RETURN .T.

Function DI500Main(lShedL,lTemDI_Ele,aDesembaraco,aDespesas,nOpcAu)//Antiga DI400Main(aFixos)    //TRP-10/12/07- Inclusão dos parâmetros lShedL e lTemDI_Ele /Cópia da v609A  CRF-23/05/2011

LOCAL lOK:=.T., nOrderSX3:=SX3->(IndexOrd())
LOCAL lRet := .T.
LOCAL lPergunte := .T. //MCF - 28/12/2015
local nPosFunDsp := 0
Local oFwBrw
Local aLegends := {}

DEFAULT lShedL := .F.  //TRP-10/12/07

AvlSX3Buffer(.T.) //AAF 24/07/2015 - Melhorar performance da gravacao da DI
PRIVATE lSchedule := lShedL  //TRP-10/12/07
Private aCabAuto:= aDesembaraco//ExecAuto na Despesas  CRF - 23/05/2011
Private aCabItem:= aDespesas
Private lDespAuto := ( aCabAuto <> NIL ) .And. ( aCabItem <> NIL )  //ExecAuto na Despesas  CRF - 23/05/2011
Private nOpcAuto:= nOpcAu //ExecAuto na Despesas  CRF - 23/05/2011
PRIVATE cMoeDolar:= BuscaDolar()//GETNEWPAR("MV_SIMB2","US$")
PRIVATE lFinanceiro:=EasyGParam("MV_EASYFIN",,"N")=="S" //.AND. GetNewPar("MV_EASY","N")=="S" //NCF - 25/03/2013 - Funcionamento da integração com SIGAFIN independente do SIGACOM
PRIVATE aDelFile:={},aTabelas:={},aTabHouse:={}
PRIVATE lAntDumpBaseICMS:=GETNEWPAR("MV_ANDUBIC",.F.)//AWR - 25/11/2004 - Define se o valor do AntiDumping sera Base de ICMS - WKANTIDUM
PRIVATE lTemAdicao:= temAdicao(lTemDI_Ele) //IF(lTemDI_Ele==NIL,GETNEWPAR("MV_TEM_DI",.F.),lTemDI_Ele) //TRP-10/12/07
PRIVATE lTemDSI   := GETNEWPAR("MV_TEM_DSI",.F.)
PRIVATE cMarca := GetMark(), lInverte := .F.
PRIVATE lFilDa :=EasyGParam("MV_FIL_DA")
PRIVATE nTamReg:=AVSX3("W1_REG",3)
PRIVATE nDecimais :=AVSX3("W9_FOB_TOT",4)
Private lIntDraw := EasyGParam("MV_EIC_EDC",,.F.) //Verifica se existe a integração com o Módulo SIGAEDC
Private lMensDrawback := EasyGParam("MV_MENSDRA",,.T.) //Indica se será apresentada mensagem referente a drawback na seleção dos itens. - GFC 18/08/04
Private cAntImp  := EasyGParam("MV_ANT_IMP",,"1")
Private lTem_ECO := EasyGParam("MV_EIC_ECO",,"N") $ cSim
Private cEasy    := EasyGParam("MV_EASY") // RA
Private lEnvDesp := EasyGParam("MV_ENVDESP",,.F.)
Private lExiste_Midia := IF(EasyGParam("MV_SOFTWAR",,"N")=="N",.F.,.T.) // LDR - 24/08/04
Private lGravaFin_EIC := EasyGParam("MV_FIN_EIC",,.F.) .AND. !lFinanceiro
Private cFilED3, cFilED4, cFilED2, cFilSB1:=xFilial("SB1"), cFilSA5:=xFilial("SA5")
Private cFilSW5:=xFilial("SW5"), cFilED0
Private cFilSW8:=xFilial("SW8"), cFilSW9:=xFilial("SW9")
Private cFilSWB:=xFilial("SWB")//igor chiba 29/09/09
Private lIn327 := EasyGParam("MV_IN327" ,,.F.) // Bete - 21/02/05
PRIVATE lZeraDesPis:= EasyGParam("MV_ZDESPIS",,.T.)
PRIVATE lICMSMidiaDupl:= EasyGParam("MV_ICMSDUP",,.F.)//AWR - 28/06/2006
SX3->(DBSETORDER(2))
Private lPesoMid := SX3->(dbSeek("A5_PESOMID")) .AND. SX3->(dbSeek("W7_PESOMID")) // LDR - 24/08/04
Private lTemRECOF  := EasyGParam("MV_RECOF",,.F.)
Private lCposAdto  := EasyGParam("MV_PG_ANT",,.F.)
PRIVATE lDespBaseIcms := SW8->(FIELDPOS("W8_D_BAICM"))#0
Private lQbgOperaca:= EIJ->(FIELDPOS("EIJ_OPERAC")) # 0 .AND. SW8->(FIELDPOS("W8_OPERACA")) # 0 //AWR - 20/12/2004
PRIVATE lTemDI     := SX3->(dbSeek("W6_TEM_DI")) .AND. lTemAdicao
Private lW2ConaPro := SX3->(DbSeek("W2_CONAPRO")) .AND. EasyGParam("MV_AVG0170",,.F.)  //TRP-28/08/08- Teste do parâmetro MV_AVG0170 para definir se habilita Controle de Alçadas no EIC.
Private lVlUnid    := SX3->(DBSEEK("YD_UM"))  .AND. SX3->(DBSEEK("W8_QTDE_UM")) // LDR - OC - 0048/04 - OS - 0989/04
Private lREGIPIW8  := SW8->(FIELDPOS("W8_REGIPI")) # 0 .AND. EIJ->(FieldPos("EIJ_REGIPI")) # 0 // NCF - 26/06/09  - Inclusão de verificação de uso do campo EIJ->EIJ_REG_IP
Private lAUTPCDI := DI500AUTPCDI()	//JWJ 12/05/2006
Private lSegInc    := SW9->(FIELDPOS("W9_SEGINC")) # 0 .AND. SW9->(FIELDPOS("W9_SEGURO")) # 0 .AND. ;
                      SW8->(FIELDPOS("W8_SEGURO")) # 0 .AND. SW6->(FIELDPOS("W6_SEGINV")) # 0 // EOB - 20/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
Private lExisteSEQ_ADI:= SW8->(FIELDPOS("W8_SEQ_ADI")) # 0 .AND. SW8->(FIELDPOS("W8_GRUPORT")) # 0//AWR - 18/09/08 NFE
Private aCores := {} // AST - 12/12/08 - Inclusão do parametro aCores
Private lAltInv:= EasyGParam("MV_EIC0002",,.F.) // TDF - 09/08/10
PRIVATE lCambInicial:= .F. // TDF - 09/08/10
Private lInvAnt := SX3->(dbSeek("EW4_INVOIC")) .AND. SX3->(dbSeek("EW5_INVOIC")) .AND.; //DRL - 15/09/09 - Invoices Antecipadas
                   SX2->(dbSeek("EW4")) .AND. SX2->(dbSeek("EW5")) .AND. SIX->(dbSeek("EW4")) .AND. SIX->(dbSeek("EW5"))
PRIVATE lAvIntFinEIC:= AvFlags("AVINT_FINANCEIRO_EIC")
PRIVATE lAvIntDesp  := AvFlags("AVINT_PR_EIC") .OR. AvFlags("AVINT_PRE_EIC")
Private lEncerraDes := EasyGParam("MV_EIC0007",,.F.) //Acb - 22/10/2010
Private lPesoBruto := SW3->(FieldPos("W3_PESO_BR")) > 0 .And. SW5->(FieldPos("W5_PESO_BR")) > 0 .And. SW7->(FieldPos("W7_PESO_BR")) > 0 .And.;
                      SW8->(FieldPos("W8_PESO_BR")) > 0 .And. EasyGParam("MV_EIC0014",,.F.) //FSM - 02/09/2011

PRIVATE lDECapa:= .F.//TDF - 01/12/11
Private lEIJIPIPauta:= EIJ->(FieldPos("EIJ_VLRIPI")) > 0
//FSM - 15/05/2012
Private cWorkName := ""
Private lContAdm := .F.
Private aPOAdm := {}
Private nContPo := 0
Private aEnv_PO := {}
Private lChangeEmb:=.F. //IGOR CHIBA 02/07/14 SE EXISTE ALTERACAO NO EMBARQUE
Private lValNegativo := .F. //LGS-10/06/2014
Private cMoedaFrt := "" //MCF - 27/01/2015
Private cMoedaSeg := "" //MCF - 27/01/2015
Private lValida := .T.  // GFP - 19/08/2015
PRIVATE aRotina:= MenuDef(ProcName(1), .T.)
PRIVATE lMV_TXSIRAT:=EasyGParam("MV_TXSIRAT",,.F.)//AWR -11/01/2005
Private _PictPrUn := ALLTRIM(X3Picture("W3_PRECO")), _PictQtde := ALLTRIM(X3Picture("W3_QTDE"))
Private _PictPO := ALLTRIM(X3Picture("W2_PO_NUM"))
PRIVATE lMostMsgNVE := .T. // GFP - 31/10/2016
//** TDF - 25/05/11 - Novo tratamento de DE Mercosul
Private lEJ9 := ChkFile("EJ9",.F.)

//** GFC - 21/11/05 - Câmbio de frete, seguro, comissão e embarque
Private lWB_TP_CON := SWB->(FieldPos("WB_TP_CON")) > 0  .and. SW9->(FieldPos("W9_FORNECC")) > 0 .and.;
                      SW9->(FieldPos("W9_LOJAC")) > 0   .and. SW9->(FieldPos("W9_COMPV")) > 0   .and.;
                      SW9->(FieldPos("W9_PERCOM")) > 0  .and. SW9->(FieldPos("W9_VALCOM")) > 0 .and.;
                      SWB->(FieldPos("WB_TIPOCOM")) > 0 .and. SW6->(FieldPos("W6_CONDP_F")) > 0 .and.;
                      SW6->(FieldPos("W6_DIASP_F")) > 0 .and. SW6->(FieldPos("W6_CONDP_S")) > 0 .and.;
                      SW6->(FieldPos("W6_DIASP_S")) > 0 .and. SWB->(FieldPos("WB_TIPOCOM")) > 0 .and.;
                      SWB->(FieldPos("WB_EVENT")) > 0   .and. SWB->(FieldPos("WB_TIPOC")) > 0
Private lGeraFrete := EasyGParam("MV_CAMBFRE",,.F.)
Private lGeraSeg   := EasyGParam("MV_CAMBSEG",,.F.)
Private lGeraCom   := EasyGParam("MV_CAMBCOM",,.F.)
Private aFilters := {}
Private aVisions := {}

If lDespAuto
   aADD(aRotina,{ STR0033,"DI500Despes",0,7})//"Despesas" - WFS 06/12/10
   PRIVATE MOpcao     := FECHTO_EMBARQUE
Endif

Private lMUserEDC := FindFunction("EDCMultiUser")
If lIntDraw  .And.  MOpcao == FECHTO_DESEMBARACO  .And.  lMUserEDC
   Private oMUserEDC := EDCMultiUser():Novo()  // Inicializa objeto para controle multi-usuário do Drawback
EndIf

PRIVATE lICMS_Dif      := SWZ->( FieldPos("WZ_ICMSUSP") > 0  .And.  FieldPos("WZ_ICMSDIF") > 0  .And.  FieldPos("WZ_ICMS_CP") > 0  .And.  FieldPos("WZ_ICMS_PD") > 0  )  ;
                  .And.  SWN->( FieldPos("WN_VICM_PD") > 0  .And.  FieldPos("WN_VICMDIF") > 0  .And.  FieldPos("WN_VICM_CP") > 0 );
                  .And. SW8->( FieldPos("W8_VICMDIF")) > 0 .And. SW8->( FieldPos("W8_VICM_CP")) > 0 .And. SW8->( FieldPos("W8_VLICMDV")) > 0


PRIVATE lICMS_Dif2     := SWZ->( FieldPos("WZ_PCREPRE") ) > 0 .AND. SWN->( FieldPos("WN_PICM_PD") > 0  .And.  FieldPos("WN_PICMDIF") > 0  .And.  FieldPos("WN_PICM_CP") > 0 .And. FieldPos("WN_PLIM_CP") > 0 );
                          .And.  SW8->( FieldPos("W8_PICMDIF")) > 0  .And. SW8->( FieldPos("W8_PICM_CP")) > 0 .AND. SW8->( FieldPos("W8_PCREPRE")) > 0 .And. SW8->( FieldPos("W8_ICMS_PD")) > 0


PRIVATE nVal_Dif := nVal_CP := nVal_ICM := 0

PRIVATE lCposNFDesp :=    (SWD->(FIELDPOS("WD_B1_COD")) # 0 .And. SWD->(FIELDPOS("WD_DOC")) # 0 .And. SWD->(FIELDPOS("WD_SERIE")) # 0;                   //NCF - Campos da Nota Fiscal de Despesas
                     .And. SWD->(FIELDPOS("WD_ESPECIE")) # 0 .And. SWD->(FIELDPOS("WD_EMISSAO")) # 0 .AND. SWD->(FIELDPOS("WD_B1_QTDE")) # 0;
                     .And. SWD->(FIELDPOS("WD_TIPONFD")) # 0)

Private cCodRatPeso := "10/13"   // NCF - 27/07/2010 - Variável private para adicionar via ponto de entrada os códigos dos acrescimos a serem rateados por peso.


Private lCpsICMSPt :=  ( SB1->(FIELDPOS("B1_VLR_ICM")) # 0 .And.  SWZ->(FIELDPOS("WZ_TPPICMS")) # 0 .And. SW8->(FIELDPOS("W8_VLICMDV")) # 0  .And. EIJ->(FIELDPOS("EIJ_VLICMD")) # 0 )        //NCF - 11/05/2011- Campos do ICMS de Pauta
Private cMV_CALCICM := EasyGParam("MV_CALCICM",,"0") //NCF - 11/05/2011 - Parametro do ICMS de Pauta
Private lAtuTabSisc := .F.                      //NCF - 24/05/2011 - Variavel que controla atualização da Tabela Siscomex
Private lCposNVEPLI := (EIM->(FIELDPOS("EIM_FASE")) # 0 .And. SW5->(FIELDPOS("W5_NVE")) # 0 /*.And. EasyGParam("MV_EIC0011",,.F.)*/ ) //NCF - Classificação N.V.A.E na PLI
Private lCposCofMj := SYD->(FieldPos("YD_MAJ_COF")) > 0 .And. SYT->(FieldPos("YT_MJCOF")) > 0 .And. SWN->(FieldPos("WN_VLCOFM")) > 0 .And.;                                                   //NCF - 20/07/2012 - Majoração PIS/COFINS
                      SWN->(FieldPos("WN_ALCOFM")) > 0  .And. SWZ->(FieldPos("WZ_TPCMCOF")) > 0 .And. SWZ->(FieldPos("WZ_ALCOFM")) > 0 .And.;
                      EIJ->(FieldPos("EIJ_ALCOFM")) > 0 .And. SW8->(FieldPos("W8_VLCOFM")) > 0 .And. EI2->(FieldPos("EI2_VLCOFM")) > 0
Private lCposPisMj := SYD->(FieldPos("YD_MAJ_PIS")) > 0 .And. SYT->(FieldPos("YT_MJPIS")) > 0 .And. SWN->(FieldPos("WN_VLPISM")) > 0 .And.;                                                    //NCF - 20/07/2012 - Majoração PIS/COFINS
                      SWN->(FieldPos("WN_ALPISM")) > 0  .And. SWZ->(FieldPos("WZ_TPCMPIS")) > 0 .And. SWZ->(FieldPos("WZ_ALPISM")) > 0 .And.;
                      EIJ->(FieldPos("EIJ_ALPISM")) > 0 .And. SW8->(FieldPos("W8_VLPISM")) > 0 .And. EI2->(FieldPos("EI2_VLPISM")) > 0    //GFP - 11/06/2013 - Majoração PIS
Private oBufferUM:= tHashMap():New() //bufferização da busca pela unidade de medida
#IFDEF TOP
   lTop := .T.
#ELSE
   lTop := .F.
#ENDIF

if !lTem_ECO
   OLD_ALIAS:=ALIAS()
   ChkFile("EC1",.F.)
   DBSELECTAREA("EC1")
   EC1->(DBSETORDER(1))
   IF EC1->(DBSEEK(XFILIAL("EC1")+IIF(EC1->(FieldPos("EC1_TPMODU"))>0,"IMPORT","")))  //CASO EXISTA REGISTRO NO EC1 COM A FILIAL ATUAL
      PUTMV("MV_EIC_ECO","S")
   ENDIF
   DBSELECTAREA(OLD_ALIAS)
endif

If lIntDraw
   cFilED4:=xFilial("ED4")
   cFilED3:=xFilial("ED3")
   cFilED2:=xFilial("ED2")
   cFilED0:=xFilial("ED0")
   cFilEDD:=xFilial("EDD")
   EDD->(dbSetOrder(2))
EndIf
DI500aEMB()

lCriouOK:=.F.

E_Init()

bSetKey1:=SetKey(VK_F11)//AWR - 3/6/4
bSetKey2:=SetKey(VK_F12)

IF lFinanceiro
   SetKey(VK_F11,{|| lPergunte := Pergunte("EICFI5",.T.) }) //MCF - 28/12/2015
ENDIF
IF lFinanceiro //.AND. SX1->(DBSEEK("EICFI4"))
   SetKey(VK_F12,{|| Pergunte("EICFI4",.T.) })
ENDIF
lNoBaixa:=.T.

DI500Fil(.T.)
bExecute:={|| .T. }   //TRP-10/12/07
SW6->(DBSETORDER(1))
EIJ->(DBSETORDER(1))

DI500TstCpoPeso()

If	lAvIntFinEIC
   Private cEICFI09 := EasyGParam('MV_EICFI09',,'') //define codigo da integração de Despesas Provisórias
   Private cEICFI10 := EasyGParam('MV_EICFI10',,'') //define codigo da integração de NUMERARIO.DESPACHANTE
   Private cEICFI11 := EasyGParam('MV_EICFI11',,'') //define codigo da integração de DESPESAS.REALIZADAS
   Private cEICFI12 := EasyGParam('MV_EICFI12',,'') //define codigo da integração de COMPENSAÇÃO NUMERÁRIO x DESPESAS REALIZADAS
   Private lEICFI09  := .F.
   Private lEICFI10  := .F.
   Private lEICFI11  := .F.
   Private lEICFI12  := .F.

   E00->(DBSETORDER(1))
   lEICFI09:=( E00->(DBSEEK(XFILIAL('E00')+AVKEY(cEICFI09,'E00_COD') )) .AND. E00->E00_SITUAC$cSim ) //esta ativo  Despesas Provisórias
   lEICFI10:=( E00->(DBSEEK(XFILIAL('E00')+AVKEY(cEICFI10,'E00_COD') )) .AND. E00->E00_SITUAC$cSim ) //esta ativo  NUMERARIO.DESPACHANTE
   lEICFI11:=( E00->(DBSEEK(XFILIAL('E00')+AVKEY(cEICFI11,'E00_COD') )) .AND. E00->E00_SITUAC$cSim ) //esta ativo  DESPESAS.REALIZADAS
   lEICFI12:=( E00->(DBSEEK(XFILIAL('E00')+AVKEY(cEICFI12,'E00_COD') )) .AND. E00->E00_SITUAC$cSim ) //esta ativo  COMPENSAÇÃO NUMERÁRIO x DESPESAS REALIZADAS
EndIf

//**igor chiba indica se irá gravar integração no ERP financeiro
Private LCAMBIO_EIC:= AVFLAGS('AVINT_CAMBIO_EIC')

IF LCAMBIO_EIC
   Private cEICFI05 := EasyGParam('MV_EICFI05',,'') //define codigo da integração de CBO
   Private cEICFI06 := EasyGParam('MV_EICFI06',,'') //define codigo da integração de INVOICE
   Private cEICFI07 := EasyGParam('MV_EICFI07',,'') //define codigo da integração de INVOICE ANTECIPADA
   Private lEICFI05  := .F.
   Private lEICFI06  := .F.
   Private lEICFI07  := .F.

   E00->(DBSETORDER(1))
   lEICFI05:=( E00->(DBSEEK(XFILIAL('E00')+AVKEY(cEICFI05,'E00_COD') ))  .AND. E00->E00_SITUAC$cSim ) //esta ativo  CAMBIO
   lEICFI06:=( E00->(DBSEEK(XFILIAL('E00')+AVKEY(cEICFI06,'E00_COD') ))  .AND. E00->E00_SITUAC$cSim ) //esta ativo  INVOICE
   lEICFI07:=( E00->(DBSEEK(XFILIAL('E00')+AVKEY(cEICFI07,'E00_COD') ))  .AND. E00->E00_SITUAC$cSim ) //esta ativo  INV ANTECIPADA
   Private lIntegStat  := EasyGParam("MV_EICFI21",,.F.)  // PLB 15/04/10 - Status de Retorno do ERP
ENDIF
Private __KeepUsrFiles //Tratamento específico para manter arquivos de trabalho - Vide EECAE109.

If(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"FILTRA_BROWSE"),) // MCF - 29/09/2014

__KeepUsrFiles:= SaveTempFiles() //Tratamento específico para manter arquivos de trabalho - Vide EECAE109.

IF lSchedule  //TRP-10/12/07
   EVAL(bExecute)
ELSE
   If ( Type("lDespAuto") == "U" .OR. !lDespAuto )
      oFwBrw := FWmBrowse():New()
      oFwBrw:SetDescription(cCadastro) // Título da FWMBrowse
      oFwBrw:SetAlias("SW6")
      oFwBrw:SetMenuDef(ProcName(1)) // Define o MenuDef baseado no fonte
      oFwBrw:DisableDetails()
      // Configura os filtros
      IIF(Empty(aFilters), aFilters := GetFilters(),) // Caso a variável esteja preenchida pelo ponto de entrada
      aEval(aFilters, {|x| oFwBrw:AddFilter(x[1], x[2]) }) // Título e expressão do filtro
      // Configura as legendas
      If !Empty(aCores) .and. Len(aCores[1]) == 2 // Atualiza o legado para utilizar o novo método
         aCores := UpdtLegado(aCores)
      EndIf
      aLegends := GetLegends(.T.)
      aEval(aLegends, {|x| oFwBrw:AddLegend(x[1], x[2], x[3],,.F.) }) // Filtro, cor, título e exibição do filtro da legenda desabilitado
      // Habilita a exibição de visões e gráficos
      oFwBrw:SetAttach( .T. )
      // Configura as visões padrões
      IIF(Empty(aVisions), aVisions := GetVisions(),) // Caso a variável esteja preenchido pelo ponto de entrada
      oFwBrw:SetViewsDefault(aVisions)
      oFwBrw:ForceQuitButton()
      oFwBrw:Activate()
   Else
      Default nOpcAuto := 3
      If nOpcAuto == 7 .and. ( nPosFunDsp := aScan( aRotina, { |X| upper(alltrim(X[2])) == "DI500DESPES"}) ) > 0
         nOpcAuto := nPosFunDsp
         SW6->(DbSetOrder(1))
         If SW6->(DbSeek(xFilial("SW6")+AvKey(aCabAuto[2],"W6_HAWB")))
            MBrowseAuto(nOpcAuto,aCabAuto,"SW6",,.T.)
         Endif
      Endif
   Endif
ENDIF

DI500Fil(.F.)
DI500Final()

SetKey(VK_F11,bSetKey1)//AWR - 3/6/4
SetKey(VK_F12,bSetKey2)
If FindFunction("AvlSX3Buffer")
   AvlSX3Buffer(.F.) //AAF 24/07/2015 - Melhorar performance da gravacao da DI
Endif

Return .T.

/*
Funcao      : temAdicao()
Parâmetros  : lTemDI_Ele
Retorno     : lógico - define se o ambiente está configurado para DI eletrônica
Objetivos   : Redefinir se o ambiente está configurado para DI eletrônica, para processos do tipo DI
Autor       : wfs
Data/Hora   : dez/ 2021
*/
Static Function temAdicao(lTemDI_Ele)
Return IIF(lTemDI_Ele==NIL, EasyGParam("MV_TEM_DI",.F.), lTemDI_Ele) 

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 17/01/07 - 13:31
*/
Static Function MenuDef(cLocOrigem, lLocMBrowse)
Local aRotAdic := {}
Local lExisteSEQ_ADI := .F.

Default cLocOrigem  := AvMnuFnc()
//Default lLocMBrowse := .F. - Nopado pois é necessário retornar todas as opções da rotina. Apenas o menufuncional não pode exibi-las (funcao GETMENUDEF é do menu funcional).
Default lLocMBrowse := OrigChamada()
PRIVATE cOrigem := cLocOrigem //AWR - 12/08/2010 - Para usar no rdmake
PRIVATE lMBrowse:= lLocMBrowse//AWR - 12/08/2010 - Para usar no rdmake
PRIVATE aRotina :=  {}        //AWR - 12/08/2010 - Para usar no rdmake

   If lMBrowse
      lExisteSEQ_ADI := SW8->(FIELDPOS("W8_SEQ_ADI")) # 0 .AND. SW8->(FIELDPOS("W8_GRUPORT")) # 0
   EndIf
   cOrigem := Upper(AllTrim(cOrigem))

   If EasyGParam("MV_AVG0182",,.F.) .Or. !lMbrowse                  // NCF - 03/09/2009 - Criado o parametro "MV_AVG0182" para habilitar a pesquisa
      AADD(aRotina,{ STR0029,"AxPesqui",0,1})//"Pesquisar"     // padrão para os cliente que não utilizam os pontos de entrada criados na função
   Else                                                        // "DI500Busca".
      AADD(aRotina,{ STR0029,"DI500Busca",0,1})//"Pesquisar"
   EndIf
   aADD(aRotina,{ STR0030,"DI500Manut",0,2})//"Visualizar"
   aADD(aRotina,{ STR0031,"DI500Manut",0,3})//"Incluir"
   aADD(aRotina,{ STR0032,"DI500Manut",0,4})//"Alterar"
   aADD(aRotina,{ STR0034,"DI500Manut",0,5})//"Estornar"

   If Valtype("lEncerraDes") # "L"
      lEncerraDes := EasyGParam("MV_EIC0007",,.F.) //Acb - 22/10/2010
   EndIf

   If lEncerraDes
      aADD(aRotina,{STR0566,"DI500Encerra",0,6})//"Encerrar"//Acb - 22/10/2010 - melhoria cancelamento de desembaraço por motivos de estravio de mercadoria
   EndIf
   aADD(aRotina,{ STR0516, "MsDocument", 0, 4 } ) //"Conhecimento" - DRL 08/09/09 //  STR0516  "Conhecimento "

   If cOrigem $ "EICDI502/EICDI503"
      //aADD(aRotina,{ STR0033,"DI500Despes",0,4})//"Despesas" - WFS - Alterada a ordem para não afetar o DSI
      If GETNEWPAR("MV_TEM_DSI",.F.)
         aADD(aRotina,{ STR0576,"DI500Manut",0,3})//Atencao: NAO MUDAR A POSICAO DA DSI NO AROTINA, TEM QUER SER 7 //STR0576  "Incluir DSI"
      EndIf
      aADD(aRotina,{ STR0033,"DI500Despes",0,4})//"Despesas" - WFS 06/12/10
      If EasyGParam("MV_TEM_DI",.F.) .OR. EasyGParam("MV_TEM_DSI",.F.)
         aADD(aRotina,{ STR0258,"DI500EnvSis",0,2}) //"Siscomex"
      EndIf

      //Opção "Diagnostico" removida, devido à mudança na integração siscomex importação

      If EasyGParam("MV_RECOF",,.F.)
         aADD(aRotina,{STR0577,"U_EICRECOF",0,2}) //STR0577 "Envio RECOF"
      EndIf

      If AvFlags("SUFRAMA") .And. EasyGParam("MV_TEM_DI",.F.) // BAK - ApresentaçAo da rotina da Declaração Amazonense de Importação
         aADD(aRotina,{"DAI","EICDAI100",0,2})
      EndIf
   EndIf

   If FindFunction("U_EICINTWEB")//Integracao Documentos WEB
      aADD(aRotina,{STR0578,"U_EICINTWEB",0,2}) // STR0578 "Document. WEB"
   Endif

   //AST - 30/10/08 - NFE - Exportação/Importação de Processos para Excel
   If cOrigem == "EICDI502" 
      aAdd(aRotina,{STR0579 ,"Proc2XLS",0,2}) //STR0579 "Exportar dados da planilha"
      aAdd(aRotina,{STR0580 ,"ImpProcXLS",0,2}) //STR0580 "Importar dados da planilha"
   EndIf
   //NCF - 22/06/2020 - Ativação de pergunte sem teclado.
   IF EasyGParam("MV_EASYFIN",,"N")=="S"
      AADD(aRotina, { "Config.Int.FIN","SetF11FIN",0,7} )//"Config.Int.FIN"
   ENDIF
   
   Aadd(aRotina, {STR0912, "LP500VINC", 0, 2}) //"Itens DUIMP"   

   If AvFlags("AVINT_PRE_EIC")
      Aadd(aRotina, {"Despesas Provisórias", "DI500Prov", 0, 2})
   EndIf

   aADD(aRotina,{ STR0893,"DI500Legenda",0,4})  // Legendas
   If(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"AROTINA"),)

   // P.E. utilizado para adicionar itens no Menu da mBrowse
   If EasyEntryPoint("IDI500MNU")
      aRotAdic := ExecBlock("IDI500MNU",.f.,.f.,)
      If ValType(aRotAdic) == "A"
         aEval(aRotAdic,{|x| AAdd(aRotina,x)})
      EndIf
   EndIf
Return aRotina

/*
Funcao     : DI500Legenda()
Parametros : Nenhum
Retorno    : Tela de legenda
Objetivos  : Exibir as legendas dos status
Autor      : Nícolas Castellani Brisque
Data       : Agosto/2022
*/
Function DI500Legenda()
Return BrwLegenda(STR0941, STR0893, GetLegends()) // Status / Legendas

/*
Funcao     : GetLegends()
Parametros : lFiltro
Retorno    : Array com as legendas
Objetivos  : Dependendo de como é chamada, pode retornar apenas as legendas ou o filtro delas.
Autor      : Nícolas Castellani Brisque
Data       : Agosto/2022
*/
Static Function GetLegends(lFiltro)
Local aLegenda := {}
Local i
Default lFiltro := .F.

   If !Empty(aCores)
      For i := 1 to Len(aCores)
         aAdd(aLegenda, MontaLegenda(IIF(lFiltro, aCores[i][1],), aCores[i][2], aCores[i][3]))
      Next
   Else
      aAdd(aLegenda, MontaLegenda(IIF(lFiltro, RetFilter("ENCERRADO"),   ), "BR_PRETO",    STR0933)) // Encerrado
      aAdd(aLegenda, MontaLegenda(IIF(lFiltro, RetFilter("ENCERRAMENTO"),), "BR_VERDE",    STR0934)) // Aguardando encerramento
      aAdd(aLegenda, MontaLegenda(IIF(lFiltro, RetFilter("ENTREGA"),     ), "BR_AZUL",     STR0935)) // Aguardando entrega
      aAdd(aLegenda, MontaLegenda(IIF(lFiltro, RetFilter("NOTA_FISCAL"), ), "BR_VERMELHO", STR0936)) // Aguardando nota fiscal
      aAdd(aLegenda, MontaLegenda(IIF(lFiltro, RetFilter("DESEMBARAÇO"), ), "BR_MARROM",   STR0937)) // Aguardando desembaraço
      aAdd(aLegenda, MontaLegenda(IIF(lFiltro, RetFilter("REGISTRO"),    ), "BR_LARANJA",  STR0938)) // Aguardando registro
      aAdd(aLegenda, MontaLegenda(IIF(lFiltro, RetFilter("CHEGADA"),     ), "BR_AMARELO",  STR0939)) // Aguardando chegada
      aAdd(aLegenda, MontaLegenda(IIF(lFiltro, RetFilter("EMBARQUE"),    ), "BR_BRANCO",   STR0940)) // Aguardando embarque
   EndIf
Return aLegenda

/*
Funcao     : MontaLegenda()
Parametros : cFiltro - Filtro da legenda (caso utilize), 
             cCor    - Cor a ser utilizada para a legenda
             cTitulo - Título da legenda
Retorno    : Retorna um array organizado
Objetivos  : Função para auxiliar a montagem de legenda e deixar mais limpo o código
Autor      : Nícolas Castellani Brisque
Data       : Agosto/2022
*/
Static Function MontaLegenda(cFiltro, cCor, cTitulo)
Local aArray := {}
Default cFiltro := ""
   If !Empty(cFiltro)
      aAdd(aArray, cFiltro)
   EndIf
   aAdd(aArray, cCor)
   aAdd(aArray, cTitulo)
Return aArray

/*
Funcao     : RetFilter()
Parametros : cTipo - Define qual é o tipo de nome/filtro a ser utilizado, 
             lNome - Se verdadeiro, retornará o nome ao invés do filtro
Retorno    : Retorna uma string com o nome ou o filtro
Objetivos  : Dependendo de como é chamada, retornar o filtro ou o nome dele.
Autor      : Nícolas Castellani Brisque
Data       : Agosto/2022
*/
Static Function RetFilter(cTipo, lNome)
Local cRet := ""
Default lNome := .F.
   Do Case
      Case cTipo == "ENCERRADO"
            cRet := IIF(lNome, STR0933, "!Empty(SW6->W6_DT_ENCE)") // Encerrado
      Case cTipo == "ENCERRAMENTO"
            cRet := IIF(lNome, STR0934, "!Empty(SW6->W6_DT_ENTR) .and. Empty(SW6->W6_DT_ENCE)") // Aguardando encerramento
      Case cTipo == "ENTREGA"
            cRet := IIF(lNome, STR0935, "!Empty(SW6->W6_DT_NF) .and. Empty(SW6->W6_DT_ENTR)") // Aguardando entrega
      Case cTipo == "NOTA_FISCAL"
            cRet := IIF(lNome, STR0936, "!Empty(SW6->W6_DT_DESE) .and. Empty(SW6->W6_DT_NF)") // Aguardando nota fiscal
      Case cTipo == "DESEMBARAÇO"
            cRet := IIF(lNome, STR0937, "!Empty(SW6->W6_CHEG) .and. !Empty(SW6->W6_DTREG_D) .and. Empty(SW6->W6_DT_DESE) .and. Empty(SW6->W6_DT_NF)") // Aguardando desembaraço
      Case cTipo == "REGISTRO"
            cRet := IIF(lNome, STR0938, "!Empty(SW6->W6_CHEG) .and. Empty(SW6->W6_DTREG_D)") // Aguardando registro
      Case cTipo == "CHEGADA"
            cRet := IIF(lNome, STR0939, "!Empty(SW6->W6_DT_EMB) .and. Empty(SW6->W6_CHEG) .and. Empty(SW6->W6_DT_DESE) .and. Empty(SW6->W6_DT_NF)") // Aguardando chegada
      Case cTipo == "EMBARQUE"
            cRet := IIF(lNome, STR0940, "!Empty(SW6->W6_DT_ETD) .and. Empty(SW6->W6_DT_EMB) .and. Empty(SW6->W6_CHEG) .and. Empty(SW6->W6_DT_DESE) .and. Empty(SW6->W6_DT_NF) .and. Empty(SW6->W6_DT_ENTR) .and. Empty(SW6->W6_DT_ENCE)") // Aguardando embarque
   EndCase
Return cRet

/*
Funcao     : GetVisions()
Parametros : Nenhum
Retorno    : Retorna array com as visões
Objetivos  : Retornar um array com as visões para o Browse
Autor      : Nícolas Castellani Brisque
Data       : Agosto/2022
*/
Static Function GetVisions()
Local oDSView
Local aVisions := {}
Local aColunas := AvGetCpBrw("SW6")
Local aContextos := {"ENCERRADO", "ENCERRAMENTO", "ENTREGA", "NOTA_FISCAL", "DESEMBARAÇO", "REGISTRO", "CHEGADA", "EMBARQUE"}
Local cFiltro
Local i
   If aScan(aColunas, "W6_FILIAL") == 0
      aAdd(aColunas, "W6_FILIAL")
   EndIf
   For i := 1 To Len(aContextos)
      cFiltro := RetFilter(aContextos[i])
      oDSView := FWDSView():New()
      oDSView:SetName(AllTrim(Str(i)) + " - " + RetFilter(aContextos[i], .T.))
      oDSView:SetPublic(.T.)
      oDSView:SetCollumns(aColunas)
      oDSView:SetOrder(1)
      oDSView:AddFilter(AllTrim(Str(i)) + "-" + RetFilter(aContextos[i], .T.), cFiltro)
      oDSView:SetID(AllTrim(Str(i)))
      oDsView:SetLegend(.T.)
      aAdd(aVisions, oDSView)
   Next
Return aVisions

/*
Funcao     : GetFilters()
Parametros : Nenhum
Retorno    : Retorna array com os filtros padrões
Objetivos  : Retornar um array com os filtros para o Browse
Autor      : Nícolas Castellani Brisque
Data       : Agosto/2022
*/
Static Function GetFilters()
Local aContextos := {"ENCERRADO", "ENCERRAMENTO", "ENTREGA", "NOTA_FISCAL", "DESEMBARAÇO", "REGISTRO", "CHEGADA", "EMBARQUE"}
Local aFilters := {}
Local i
   For i := 1 To Len(aContextos)
      aAdd(aFilters, {RetFilter(aContextos[i], .T.), RetFilter(aContextos[i])}) // Nome e a expressão do filtro
   Next
Return aFilters

/*
Funcao     : UpdtLegado()
Parametros : Nenhum
Retorno    : Retorna array com as legendas
Objetivos  : Modificar o legado para ficar no padrão novo de legendas. Essa função só
             será utilizada caso o usuário não remova a opção de legendas padrão do MenuDef
             através do Ponto de Entrada aRotina
Autor      : Nícolas Castellani Brisque
Data       : Agosto/2022
*/
Static Function UpdtLegado(aCores)
Local aCoresNovo := {}
Local i
   For i := 1 to Len(aCores)
      AAdd(aCoresNovo, {aCores[i][1], aCores[i][2], ""})
   Next
Return aCoresNovo

FUNCTION DI500CriaWork()//Antiga DI_InitWork(bCloseAll,bMsg)

Local i
// BAK - Inclusao do campo EIJ_CODMAT na quebra da adição para a Declaração Amazonense de Importação, como tambem para criação na Work
Local lDAI := SW8->(FieldPos("W8_CODMAT")) > 0 .And. EIJ->(FieldPos("EIJ_CODMAT")) > 0 .And. AvFlags("SUFRAMA") .And. EasyGParam("MV_TEM_DI", ,.F.)

IF !lSchedule //TRP-10/12/07
   Procregua(3)
   IncProc(STR0261) //"Iniciando Ambiente..."
ENDIF
aSemSX3SW7:={;
{"WKCOD_I"   ,"C",LEN(SW7->W7_COD_I),0},;
{"WKFABR"    ,"C",LEN(SW7->W7_FABR) ,0} ,;
{"WKNOME_FAB","C",15,0} ,;
{"WKFORN"    ,"C",LEN(SW7->W7_FORN) ,0} ,;
{"WKNOME_FOR","C",15,0} ,;
{"WKFLUXO"   ,"C",1 ,0} ,;
{"WKQTDE"    ,"N",AVSX3("W7_QTDE"  ,3),AVSX3("W7_QTDE" ,4)} ,;
{"WKCC"      ,"C",AvSx3("W7_CC"    , AV_TAMANHO)   ,0} ,;
{"WKDESCR"   ,"C",AvSx3("B1_VM_GI" ,3),0} ,;
{"WKSI_NUM"  ,"C",AvSx3("W7_SI_NUM", AV_TAMANHO),0} ,;
{"WKPO_NUM"  ,"C",AvSx3("W7_PO_NUM", AV_TAMANHO),0} ,;
{"WKPGI_NUM" ,"C",AvSx3("W7_PGI_NUM", AV_TAMANHO),0} ,;
{"WKGI_NUM"  ,"C",13,0} ,;
{"WKFLAG"    ,"L",1,0}  ,{"WKFLAG2"   ,"L",1 ,0} ,;
{"WKPRECO"   ,"N",AVSX3("W7_PRECO",3),AVSX3("W7_PRECO",4)} ,;
{"WKSALDO_Q" ,"N",AVSX3("W7_QTDE" ,3),AVSX3("W7_QTDE" ,4)} ,;
{"WKSALDO_O" ,"N",AVSX3("W7_QTDE" ,3),AVSX3("W7_QTDE" ,4)} ,;
{"WKQTDE_D"  ,"N",AVSX3("W7_QTDE" ,3),AVSX3("W7_QTDE" ,4)} ,;
{"WKQTDEDORI","N",AVSX3("W7_QTDE" ,3),AVSX3("W7_QTDE" ,4)} ,;
{"WKDISPINV" ,"N",AVSX3("W7_QTDE" ,3),AVSX3("W7_QTDE" ,4)} ,;
{"WKDT_EMB"  ,"D",08,0} ,{"WKDT_ENTR" ,"D",8 ,0} ,;
{"WKNBM"     ,"C",10,0} ,{"WKDTENTR_S","D",8 ,0} ,;
{"WKPART_N"  ,"C",LEN(IF(SW3->(FieldPos("W3_PART_N")) # 0,SW3->W3_PART_N,SA5->A5_CODPRF)),0} ,{"WKDOCTO_F" ,"C",15,0} ,;
{"WKSEQ"     ,"N",02,0} ,;
{"WKREG"     ,"N",nTamReg,0},{"WKRECNO_ID","N",10,0} ,;
{"WKPESO_L"  ,"N",AVSX3("W7_PESO",3),AVSX3("W7_PESO",4)},;    //TRP-28/02/08
{"WKMOEDA"   ,"C",3,0}  ,{"WKFLAGWIN" ,"C",2 ,0} ,;
{"WKFLAGWIN2","C",02,0} ,{"WKOPERACA" ,"C",LEN(SW7->W7_OPERACA),0},;
{"WKSEQ_LI"  ,"C",03,0} ,{"WKREGIST"  ,"C",10,0},;
{"WKREG_VEN" ,"D",08,0} ,;
{"WKINVOICE" ,"C",AvSx3("W7_INVOICE", AV_TAMANHO),0},;
{"WKPOSICAO" ,"C",LEN(SW3->W3_POSICAO),0} ,{"WK_ALTEROU","L",01,0},;
{"WKEX_NCM"  ,"C",LEN(SW7->W7_EX_NCM),0},;
{"WKEX_NBM"  ,"C",LEN(SW7->W7_EX_NBM),0},;
{"WKTEC"     ,"C",LEN(SW7->W7_NCM),0},;
{"WKIPIPAUTA","N",15,5},{"WK_ADICAO"  ,"C",03,0}}


EICAddWkLoja(aSemSX3SW7, "W7_FABLOJ", "WKFABR")
EICAddWkLoja(aSemSX3SW7, "W7_FORLOJ", "WKFORN")

If lPesoBruto  //FSM - 31/08/2011 - "Peso Bruto Unitário"
   aAdd(aSemSX3SW7,{"WKW7PESOBR" ,AVSX3("W7_PESO_BR",AV_TIPO),AVSX3("W7_PESO_BR",AV_TAMANHO),AVSX3("W7_PESO_BR",AV_DECIMAL)})
EndIf

If lOperacaoEsp
  AADD(aSemSX3SW7,{"W7_CODOPE",AVSX3("W8_CODOPE" ,2),AVSX3("W8_CODOPE" ,3),AVSX3("W8_CODOPE" ,4)})
  AADD(aSemSX3SW7,{"W7_DESOPE",AVSX3("W8_DESOPE" ,2),AVSX3("W8_DESOPE" ,3),AVSX3("W8_DESOPE" ,4)})
EndIf

If lIntDraw
   aAdd(aSemSX3SW7,{"WKAC"     ,"C",Len(SW5->W5_AC),0})
   aAdd(aSemSX3SW7,{"WKSEQSIS" ,"C",Len(SW5->W5_SEQSIS),0})
EndIf

IF lExiste_Midia .AND. lPesoMid   // LDR - 25/08/04
   aAdd(aSemSX3SW7,{"WKPESOMID","N",AVSX3("W7_PESOMID",3),AVSX3("W7_PESOMID",4)})
ENDIF
//NCF - 08/08/2011 - Classificação N.V.A.E na PLI
If lTemNVE
   aAdd(aSemSX3SW7,{"WK_NVE" ,"C",AVSX3("W5_NVE",3),AVSX3("W5_NVE",4)})
EndIf

IF !lSchedule  //TRP-10/12/07
   IncProc(STR0261) //"Iniciando Ambiente..."
ENDIF

aSemSX3SW8:={}
AADD(aSemSX3SW8,{"WKINVOICE" ,"C",AvSx3("W8_INVOICE", AV_TAMANHO),0})
AADD(aSemSX3SW8,{"WKQTDE"    ,"N",AVSX3("W8_QTDE" ,3),AVSX3("W8_QTDE" ,4)})
AADD(aSemSX3SW8,{"WKPRECO"   ,"N",AVSX3("W8_PRECO",3),AVSX3("W8_PRECO",4)})
AADD(aSemSX3SW8,{"WKCOD_I"   ,"C",AvSx3("W8_COD_I", AV_TAMANHO),0})
AADD(aSemSX3SW8,{"WKPART_N"  ,"C",LEN(IF(SW3->(FieldPos("W3_PART_N")) # 0,SW3->W3_PART_N,SA5->A5_CODPRF)),0}) //NCF - 30/10/2009
AADD(aSemSX3SW8,{"WKFABR"    ,"C",AVSX3("W8_FABR",3) ,0})
If EICLoja()
   AADD(aSemSX3SW8,{"W8_FABLOJ"    ,"C",AVSX3("W8_FABLOJ",3) ,0})  
EndIf
AADD(aSemSX3SW8,{"WKREG"     ,"N",nTamReg,0})
AADD(aSemSX3SW8,{"WKDT_EMIS" ,"D",8 ,0})
AADD(aSemSX3SW8,{"WKPO_NUM"  ,"C",AvSx3("W2_PO_NUM", AV_TAMANHO),0})
AADD(aSemSX3SW8,{"WKCC"      ,"C",AVSX3("W8_CC",3) ,0})
AADD(aSemSX3SW8,{"WKSI_NUM"  ,"C",AVSX3("W8_SI_NUM",3) ,0})
AADD(aSemSX3SW8,{"WKPGI_NUM" ,"C",AvSx3("W8_PGI_NUM", AV_TAMANHO),0})// ; AADD(aSemSX3SW8,{"WKDESC_DI","M",10,0})
AADD(aSemSX3SW8,{"WKSEQ_LI"  ,"C",03,0})
AADD(aSemSX3SW8,{"WKFLUXO"   ,"C",01,0})
AADD(aSemSX3SW8,{"WKFLAGIV"  ,"C",2 ,0})
AADD(aSemSX3SW8,{"WKFLAG_LSI","L",01,0})
AADD(aSemSX3SW8,{"WKFLAGDSI" ,"C",2 ,0})
AADD(aSemSX3SW8,{"WKDISPLOT" ,"N",AVSX3("WV_QTDE"   ,3),AVSX3("WV_QTDE"   ,4)})// AWR - Lote - 07/06/2004
AADD(aSemSX3SW8,{"WKBASEII"  ,"N",AVSX3("W8_BASEII" ,3),AVSX3("W8_BASEII" ,4)})
AADD(aSemSX3SW8,{"WKBASEICM" ,"N",AVSX3("W8_BASEICM",3),AVSX3("W8_BASEICM",4)})
AADD(aSemSX3SW8,{"WKTAXASIS" ,"N",AVSX3("W8_BASEICM",3),AVSX3("W8_BASEICM",4)})
AADD(aSemSX3SW8,{"WKANTIDUM" ,"N",AVSX3("W8_BASEICM",3),AVSX3("W8_BASEICM",4)})//AWR - 25/11/2004
AADD(aSemSX3SW8,{"WKFOBTOTR" ,"N",AVSX3("W8_FOBTOTR",3),AVSX3("W8_FOBTOTR",4)})
AADD(aSemSX3SW8,{"WKVLMLE"   ,"N",AVSX3("W8_VLMLE"  ,3),AVSX3("W8_VLMLE"  ,4)})
AADD(aSemSX3SW8,{"WKFORN"    ,"C",LEN(SW2->W2_FORN),0})
If EICLoja()
   aAdd(aSemSX3SW8,{"W8_FORLOJ" ,"C", AvSX3("W8_FORLOJ", AV_TAMANHO), 0})
EndIf
AADD(aSemSX3SW8,{"WKPRTOTMOE","N",AVSX3("W9_FOB_TOT",3),AVSX3("W9_FOB_TOT",4)})
AADD(aSemSX3SW8,{"WKOUTDESP" ,"N",AVSX3("W8_OUTDESP",3),AVSX3("W8_OUTDESP",4)})
AADD(aSemSX3SW8,{"WKINLAND"  ,"N",AVSX3("W8_INLAND" ,3),AVSX3("W8_INLAND" ,4)})
AADD(aSemSX3SW8,{"WKFRETEIN" ,"N",AVSX3("W8_FRETEIN",3),AVSX3("W8_FRETEIN",4)})
AADD(aSemSX3SW8,{"WKPACKING" ,"N",AVSX3("W8_PACKING",3),AVSX3("W8_PACKING",4)})
AADD(aSemSX3SW8,{"WKDESCONT" ,"N",AVSX3("W8_DESCONT",3),AVSX3("W8_DESCONT",4)})
AADD(aSemSX3SW8,{"WKPESO_L"  ,"N",AVSX3("W7_PESO",3)   ,AVSX3("W7_PESO",4)})    //TRP-28/02/08

If lPesoBruto
   AADD(aSemSX3SW8,{"WKW8PESOBR", AVSX3("W8_PESO_BR",AV_TIPO), AVSX3("W8_PESO_BR",AV_TAMANHO), AVSX3("W8_PESO_BR",4)})
EndIf

AADD(aSemSX3SW8,{"WKSALDO_AT","N",AVSX3("W7_QTDE"   ,3),AVSX3("W7_QTDE"   ,4)})
AADD(aSemSX3SW8,{"WKSALDO"   ,"N",AVSX3("W7_QTDE"   ,3),AVSX3("W7_QTDE"   ,4)})
AADD(aSemSX3SW8,{"WKDISPINV" ,"N",AVSX3("W7_QTDE"   ,3),AVSX3("W7_QTDE"   ,4)})
AADD(aSemSX3SW8,{"WKVLACRES" ,"N",AVSX3("W8_VLACRES",3),AVSX3("W8_VLACRES",4)})
AADD(aSemSX3SW8,{"WKVLDEDU"  ,"N",AVSX3("W8_VLDEDU" ,3),AVSX3("W8_VLDEDU" ,4)})
AADD(aSemSX3SW8,{"WKPESOTOT" ,"N",18,5/*AVSX3("B1_PESO",4)*/}) //AAF 11/09/2008 - Necessário tamanho 5 pois é o tamanho no Siscomex.
AADD(aSemSX3SW8,{"WKTEC"     ,"C",LEN(SW7->W7_NCM),0})
AADD(aSemSX3SW8,{"WKEX_NCM"  ,"C",LEN(SW7->W7_EX_NCM),0})
AADD(aSemSX3SW8,{"WKEX_NBM"  ,"C",LEN(SW7->W7_EX_NBM),0})
AADD(aSemSX3SW8,{"WKREGIST"  ,"C",10,0}) ; AADD(aSemSX3SW8,{"WKPOSICAO" ,"C",LEN(SW3->W3_POSICAO),0})
AADD(aSemSX3SW8,{"WKRECNO"   ,"N",10,0}) ; AADD(aSemSX3SW8,{"WKOPERACA" ,"C",LEN(SW7->W7_OPERACA),0})
AADD(aSemSX3SW8,{"WKCOND_PA" ,"C",05,0}) ; AADD(aSemSX3SW8,{"WKDIAS_PA" ,"N",03,0}) ; AADD(aSemSX3SW8,{"WKTCOB_PA" ,"C",01,0})
AADD(aSemSX3SW8,{"WKADICAO"  ,"C",03,0}) ; AADD(aSemSX3SW8,{"WKMOEDA"   ,"C",03,0})
AADD(aSemSX3SW8,{"WKINCOTER" ,"C",03,0}) ; AADD(aSemSX3SW8,{"WKVLSEGMN" ,"N",15,2})
AADD(aSemSX3SW8,{"WKVLFREMN" ,"N",15,2}) ; AADD(aSemSX3SW8,{"WKVLICMS"  ,"N",15,2})
AADD(aSemSX3SW8,{"WKVLII"    ,"N",15,2}) ; AADD(aSemSX3SW8,{"WKVLDEVII" ,"N",15,2})
AADD(aSemSX3SW8,{"WKVLIPI"   ,"N",15,2}) ; AADD(aSemSX3SW8,{"WKVLDEIPI" ,"N",15,2})
AADD(aSemSX3SW8,{"WKSEQ_ADI" ,"C",03,0}) ; AADD(aSemSX3SW8,{"WKREGTRI"  ,"C",01,0})
AADD(aSemSX3SW8,{"WKTACOII"  ,"C",01,0}) ; AADD(aSemSX3SW8,{"WKACO_II"  ,"C",03,0})
AADD(aSemSX3SW8,{"WKFUNREG"  ,"C",02,0}) ; AADD(aSemSX3SW8,{"WKMOTADI"  ,"C",02,0})
AADD(aSemSX3SW8,{"WKFLAGNVE" ,"C",03,0}) ; AADD(aSemSX3SW8,{"WKNVE"     ,"C",03,0})
AADD(aSemSX3SW8,{"WKNVETIPO" ,"C",02,0})//Utilizado para controlar a nve nos itens da ivoice desmarcados
AADD(aSemSX3SW8,{"WKUNID"    ,"C",AVSX3("W8_UNID" ,3),AVSX3("W8_UNID" ,4)})
//TRP - 30/01/07 - Campos do WalkThru
AADD(aSemSX3SW8,{"TRB_ALI_WT","C",03,0})
AADD(aSemSX3SW8,{"TRB_REC_WT","N",10,0})
AADD(aSemSX3SW8,{"WKGRUPORT" ,"C",03,0})//AWR - 18/09/08 - NFE
AADD(aSemSX3SW8,{"WKDESCITEM" ,"C",AVSX3("B1_DESC"   ,3),0})//SVG - 07/08/2009 -
IF lExiste_Midia .AND. lPesoMid   // LDR - 25/08/04
   AADD(aSemSX3SW8,{"WKQTMIDIA"    ,"N",14,2})
   AADD(aSemSX3SW8,{"WKVL_TOTM"    ,"N",15,2})
   AADD(aSemSX3SW8,{"WKPES_MID"    ,"N",15,2})
ENDIF

IF lVlUnid // LDR - OC - 0048/04 - OS - 0989/04
   AADD(aSemSX3SW8,{"WKQTDE_UM"  ,"N",13,3})
ENDIF

IF lDespBaseIcms
   AADD(aSemSX3SW8,{"WKD_BAICM" ,"N",AVSX3("W8_D_BAICM",3),AVSX3("W8_D_BAICM",4)})
ENDIF

IF lSeginc
   AADD(aSemSX3SW8,{"WKSEGURO" ,"N",AVSX3("W8_SEGURO",3),AVSX3("W8_SEGURO",4)})
ENDIF

aSemSX3SW8 := AddWkCpoUser(aSemSX3SW8,"SW8")

// AWR - Campos PIS/COFINS
nInt:=15
nDec:=2
IF lMV_PIS_EIC
   nInt:=AVSX3("W8_VLRPIS",3)
   nDec:=AVSX3("W8_VLRPIS",4)
ENDIF
aAdd(aSemSX3SW7,{"WKPERPIS"  ,"N",06,2}) ; AADD(aSemSX3SW7,{"WKVLUPIS"  ,"N",AVSX3("W8_VLUPIS",3),AVSX3("W8_VLUPIS",4)})
aAdd(aSemSX3SW7,{"WKPERCOF"  ,"N",06,2}) ; AADD(aSemSX3SW7,{"WKVLUCOF"  ,"N",AVSX3("W8_VLUCOF",3),AVSX3("W8_VLUCOF",4)})

AADD(aSemSX3SW8,{"WKPERPIS"  ,"N",06,2}) ; AADD(aSemSX3SW8,{"WKBASPIS"  ,"N",nInt,nDec})
AADD(aSemSX3SW8,{"WKPERCOF"  ,"N",06,2}) ; AADD(aSemSX3SW8,{"WKBASCOF"  ,"N",nInt,nDec})
AADD(aSemSX3SW8,{"WKVLUPIS"  ,"N",AVSX3("W8_VLUPIS",3),AVSX3("W8_VLUPIS",4)}) ; AADD(aSemSX3SW8,{"WKVLRPIS"  ,"N",nInt,nDec})
AADD(aSemSX3SW8,{"WKVLUCOF"  ,"N",AVSX3("W8_VLUCOF",3),AVSX3("W8_VLUCOF",4)}) ; AADD(aSemSX3SW8,{"WKVLRCOF"  ,"N",nInt,nDec})
IF lZeraDespis
   AADD(aSemSX3SW8,{"WKICMBPIS"  ,"N",nInt,nDec})
ENDIF
If lCposCofMj                                                            //NCF - 20/07/2012 - Majoração COFINS
   AADD(aSemSX3SW8,{"WKALCOFM"  ,"N",06  ,   2})
   AADD(aSemSX3SW8,{"WKVLCOFM"  ,"N",nInt,nDec})
EndIf
If lCposPisMj                                                            //GFP - 11/06/2013 - Majoração PIS
   AADD(aSemSX3SW8,{"WKALPISM"  ,"N",06  ,   2})
   AADD(aSemSX3SW8,{"WKVLPISM"  ,"N",nInt,nDec})
EndIf
// AWR - Campos PIS/COFINS
If lIntDraw
   AADD(aSemSX3SW8,{"WKAC"      ,"C",LEN(SW8->W8_AC),0})
   AADD(aSemSX3SW8,{"WKSEQSIS"  ,"C",LEN(SW8->W8_SEQSIS),0})
   AADD(aSemSX3SW8,{"WKQT_AC"   ,"N",AVSX3("W8_QT_AC",3),AVSX3("W8_QT_AC",4)})
   AADD(aSemSX3SW8,{"WKQT_AC2"  ,"N",AVSX3("W8_QT_AC2",3),AVSX3("W8_QT_AC2",4)})
   AADD(aSemSX3SW8,{"WKVL_AC"   ,"N",AVSX3("W8_VL_AC",3),AVSX3("W8_VL_AC",4)})
EndIf

IF lOperacaoEsp
   AADD(aSemSX3SW8,{"W8_CODOPE"  ,AVSX3("W8_CODOPE",2),AVSX3("W8_CODOPE",3),AVSX3("W8_CODOPE",4)})
   AADD(aSemSX3SW8,{"W8_DESOPE"  ,AVSX3("W8_CODOPE",2),AVSX3("W8_DESOPE",3),AVSX3("W8_DESOPE",4)})
ENDIF


IF lREGIPIW8
   AADD(aSemSX3SW8,{"WKREGIPI" ,"C",AVSX3("W8_REGIPI",3),0})
ENDIF
IF lAUTPCDI
   //SW7
   AADD(aSemSX3SW7,{"WKREG_PC" ,"C",LEN(SW8->W8_REG_PC),0})
   AADD(aSemSX3SW7,{"WKFUN_PC" ,"C",LEN(SW8->W8_FUN_PC),0})
   AADD(aSemSX3SW7,{"WKFRB_PC" ,"C",LEN(SW8->W8_FRB_PC),0})
   //SW8
   AADD(aSemSX3SW8,{"WKREG_PC" ,"C",LEN(SW8->W8_REG_PC),0})
   AADD(aSemSX3SW8,{"WKFUN_PC" ,"C",LEN(SW8->W8_FUN_PC),0})
   AADD(aSemSX3SW8,{"WKFRB_PC" ,"C",LEN(SW8->W8_FRB_PC),0})
   AADD(aSemSX3SW8,{"WKVLDEPIS","N",AVSX3("W8_VLDEPIS",3),AVSX3("W8_VLDEPIS",4)})
   AADD(aSemSX3SW8,{"WKVLDECOF","N",AVSX3("W8_VLDECOF",3),AVSX3("W8_VLDECOF",4)})
ENDIF

If lICMS_Dif
  AADD(aSemSX3SW8,{"WKICMSUSP",AVSX3("WZ_ICMSUSP",AV_TIPO),AVSX3("WZ_ICMSUSP",3),AVSX3("WZ_ICMSUSP",4)})
  AADD(aSemSX3SW8,{"WKVICMDIF",AVSX3("WN_VICMDIF",AV_TIPO),AVSX3("WN_VICMDIF",3),AVSX3("WN_VICMDIF",4)})
  AADD(aSemSX3SW8,{"WKVICM_CP",AVSX3("WN_VICM_CP",AV_TIPO),AVSX3("WN_VICM_CP",3),AVSX3("WN_VICM_CP",4)})
  AADD(aSemSX3SW8,{"WKVLICMDV",AVSX3("W8_VLICMDV",AV_TIPO),AVSX3("W8_VLICMDV",3),AVSX3("W8_VLICMDV",4)})
EndIf
If lICMS_Dif2
  AADD(aSemSX3SW8,{"WKPCREPRE",AVSX3("WZ_PCREPRE",AV_TIPO),AVSX3("WZ_PCREPRE",3),AVSX3("WZ_PCREPRE",4)})
  AADD(aSemSX3SW8,{"WKPICMDIF",AVSX3("WN_PICMDIF",AV_TIPO),AVSX3("WN_PICMDIF",3),AVSX3("WN_PICMDIF",4)})
  AADD(aSemSX3SW8,{"WKPICM_CP",AVSX3("WN_PICM_CP",AV_TIPO),AVSX3("WN_PICM_CP",3),AVSX3("WN_PICM_CP",4)})
  AADD(aSemSX3SW8,{"WKICMS_PD",AVSX3("WZ_ICMS_PD",AV_TIPO),AVSX3("WZ_ICMS_PD",3),AVSX3("WZ_ICMS_PD",4)})
Endif
IF AvFlags("EIC_EAI")  //SSS - REQ. 6.2 - 27/06/2014 - Unidade de Medida do Fornecedor no processo de importação
   AADD(aSemSX3SW7,{"WKUNI"    ,"C",AVSX3("W3_UM"     ,3),0})
   AADD(aSemSX3SW7,{"WKSEGUM"  ,"C",AVSX3("W3_SEGUM"  ,3),0})
   AADD(aSemSX3SW7,{"WKQTSEGUM","N",AVSX3("W3_QTSEGUM",3),AVSX3("W3_QTSEGUM" ,4)})
   AADD(aSemSX3SW7,{"WKFATOR"  ,"N",AVSX3("J5_COEF"   ,3),AVSX3("J5_COEF",4)})
   AADD(aSemSX3SW8,{"WKUNI"    ,"C",AVSX3("W3_UM"     ,3),0})
   //AADD(aSemSX3SW8,{"WKQTSEGUM","N",AVSX3("W8_QTSEGUM",3),AVSX3("W8_QTSEGUM" ,4)})
   //AADD(aSemSX3SW8,{"WKSEGUM"  ,"C",AVSX3("W8_SEGUM"  ,3),0})
   AADD(aSemSX3SW8,{"WKQTSEGUM","N",AVSX3("W3_QTSEGUM",3),AVSX3("W3_QTSEGUM" ,4)})
   AADD(aSemSX3SW8,{"WKSEGUM"  ,"C",AVSX3("W3_SEGUM"  ,3),0})
   AADD(aSemSX3SW8,{"WKFATOR"  ,"N",AVSX3("J5_COEF"   ,3),AVSX3("J5_COEF",4)})
ENDIF
//SSS - REQ. 6.2 - 27/06/2014 - Unidade de Medida do Fornecedor no processo de importação
aSemSX3SW7 := AddWkCpoUser(aSemSX3SW7,"SW7")
//TRP - 30/01/07 - Campos do WalkThru
AADD(aSemSX3SW7,{"TRB_ALI_WT","C",03,0})
AADD(aSemSX3SW7,{"TRB_REC_WT","N",10,0})
// SVG - 13/07/09 -
//If ("CTREE" $ RealRDD()) - Nopado por FDR - 28/07/11
AADD(aSemSX3SW8,{"WKFILTRO","C",01,0})
//EndIf

IF cPaisLoc == "CHI"
  AADD(aSemSX3SW8,{"WKJUROS","N",15,2})
ENDIF
AADD(aSemSX3SW8,{"WKIPIPAUTA","N",AVSX3("W7_VLR_IPI",3),AVSX3("W7_VLR_IPI",4)}) //NCF - 23/02/2011 - Adicionado o campo para guardar a Aliq. de IPI de Pauta dos Itens da Invoice

If lCpsICMSPt                                                                                                 //NCF - 11/05/2011 - Campos do ICMS de Pauta
   IF ( nPos := aScan(aSemSX3SW8, {|x| x[1] == "W8_VLICMDV"}) ) == 0
      AADD(aSemSX3SW8,{"WKVLICMDV",AVSX3("W8_VLICMDV",AV_TIPO),AVSX3("W8_VLICMDV",3),AVSX3("W8_VLICMDV",4)})
   ENDIF
EndIf

AADD(aSemSX3SW8,{"WKDESC_DI","M",10,0}) // campos memos tem q estar no fim do arquivo senao ctree nao funcioan

// BAK - Inclusao do campo WKCODMATRI na work para informar a Matriz de tributaçao na Declaração Amazonense de Importação
If SW8->(FieldPos("W8_CODMAT")) > 0 .And. AvFlags("SUFRAMA") .And. EasyGParam("MV_TEM_DI", ,.F.)
   AADD(aSemSX3SW8,{"WKCODMATRI",AVSX3("W8_CODMAT",AV_TIPO),AVSX3("W8_CODMAT",AV_TAMANHO),0})
EndIf

aSemSX3SW9:={{"WK_RECNO"  ,"N",10,00},;
             {"W9_QTDE"   ,"N",15,04},;
             {"W9_PESO"   ,"N",18,AVSX3("W6_PESOL",4)},;
             {"W9_HAWB"   ,"C",AVSX3("W9_HAWB",AV_TAMANHO),0},; //TDF 06/12/2010 - INCLUSÃO DO W9_HAWB PARA GRAVAR NA WORK
             {"W9_ALTCAMB","C",01,00}}

//TRP - 30/01/07 - Campos do WalkThru
AADD(aSemSX3SW9,{"TRB_ALI_WT","C",03,0})
AADD(aSemSX3SW9,{"TRB_REC_WT","N",10,0})

If AVFLAGS("ICMSFECP_DI_ELETRONICA")
   AADD(aSemSX3SW8,{"WKALFECP",AVSX3("W8_ALFECP",AV_TIPO),AVSX3("W8_ALFECP",AV_TAMANHO),AVSX3("W8_ALFECP",AV_DECIMAL)})
   AADD(aSemSX3SW8,{"WKVLFECP",AVSX3("W8_VLFECP",AV_TIPO),AVSX3("W8_VLFECP",AV_TAMANHO),AVSX3("W8_VLFECP",AV_DECIMAL)})
EndIf

If AVFLAGS("FECP_DIFERIMENTO")
   AADD(aSemSX3SW8,{"WKFECPALD",AVSX3("W8_FECPALD",AV_TIPO),AVSX3("W8_FECPALD",AV_TAMANHO),AVSX3("W8_FECPALD",AV_DECIMAL)})
   AADD(aSemSX3SW8,{"WKFECPVLD",AVSX3("W8_FECPVLD",AV_TIPO),AVSX3("W8_FECPVLD",AV_TAMANHO),AVSX3("W8_FECPVLD",AV_DECIMAL)})
   AADD(aSemSX3SW8,{"WKFECPREC",AVSX3("W8_FECPREC",AV_TIPO),AVSX3("W8_FECPREC",AV_TAMANHO),AVSX3("W8_FECPREC",AV_DECIMAL)})
EndIf

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"STRU_WORKS"),)

IF !lSchedule    //TRP-10/12/07
   IncProc(STR0262+"1") //"Criando Arquivo Temporario "
ENDIF
//*********************************************************  WORK
/* wfs mai/2017 - adequação para uso do EECCRIATRAB(), com a passagem do 7º parâmetro */
FileWork:=E_CriaTrab(,aSemSX3SW7,"Work",,,, SaveTempFiles())
cWorkName := FileWork //FSM - 21/05/2012
IF ! USED()
   Help(" ",1,"E_NAOHAREA")
   RETURN .F.
ENDIF
AADD(aDelFile,{"Work",FileWork})

/* wfs mai/2017 - adequação para uso do EECGetIndexFile e EECIndRequa */
E_IndRegua("Work",FileWork+TEOrdBagExt(),"WKPGI_NUM+WKCC+WKSI_NUM+WKCOD_I+WKPO_NUM+WKPOSICAO")

FileWork2:= E_Create(,.F.,"Work", FileWork, 1, SaveTempFiles())//E_Create(,.F.)
E_IndRegua("Work",FileWork2+TEOrdBagExt(),"WKPO_NUM+WKCC+WKSI_NUM+WKCOD_I")
AADD(aDelFile,{,FileWork2})

/* wfs mai/2017 - adequação para uso do EECGetIndexFile e EECIndRequa */
FileWork3:=E_Create(,.F.,"Work", FileWork, 2, SaveTempFiles())//E_Create(,.F.)
E_IndRegua("Work",FileWork3+TEOrdBagExt(),"WKPO_NUM+WKPGI_NUM+WKPOSICAO")
AADD(aDelFile,{,FileWork3})

/* wfs mai/2017 - adequação para uso do EECGetIndexFile e EECIndRequa */
FileWork4:= E_Create(,.F.,"Work", FileWork, 3, SaveTempFiles())//E_Create(,.F.)
E_IndRegua("Work",FileWork4+TEOrdBagExt(),"WKCOD_I+DTOS(WKDT_EMB)")
AADD(aDelFile,{,FileWork4})

SET INDEX TO (FileWork +TEOrdBagExt()), (FileWork2+TEOrdBagExt()),;
             (FileWork3+TEOrdBagExt()), (FileWork4+TEOrdBagExt())

aSemSX3   :={{"WK_RECNO"  ,"N",10,0}}
aSemSX3EIJ:={{"WK_RECNO"  ,"N",10,0}}

//TRP - 30/01/07 - Campos do WalkThru
AADD(aSemSX3EIJ,{"TRB_ALI_WT","C",03,0})
AADD(aSemSX3EIJ,{"TRB_REC_WT","N",10,0})

//ISS - 06/05/2010
IF EIJ->(FIELDPOS("EIJ_BASPIS")) != 0
   SX3->(DbSetOrder(2))
   SX3->(DbSeek("EIJ_BASPIS"))
   If !X3USO(SX3->X3_USADO)
      aAdd(aSemSX3EIJ, {"EIJ_BASPIS", AvSx3("EIJ_BASPIS", AV_TIPO), AvSx3("EIJ_BASPIS", AV_TAMANHO), AvSx3("EIJ_BASPIS", AV_DECIMAL)})
   EndIf
Endif

//TRP - 22/02/2010
IF EIJ->(FIELDPOS("EIJ_ARDPIS")) != 0
   SX3->(DbSetOrder(2))
   SX3->(DbSeek("EIJ_ARDPIS"))
   If !X3USO(SX3->X3_USADO)
      aAdd(aSemSX3EIJ, {"EIJ_ARDPIS", AvSx3("EIJ_ARDPIS", AV_TIPO), AvSx3("EIJ_ARDPIS", AV_TAMANHO), AvSx3("EIJ_ARDPIS", AV_DECIMAL)})
   EndIf
Endif

//TRP - 22/02/2010
IF EIJ->(FIELDPOS("EIJ_ARDCOF")) != 0
   SX3->(DbSetOrder(2))
   SX3->(DbSeek("EIJ_ARDCOF"))
   If !X3USO(SX3->X3_USADO)
      aAdd(aSemSX3EIJ, {"EIJ_ARDCOF", AvSx3("EIJ_ARDCOF", AV_TIPO), AvSx3("EIJ_ARDCOF", AV_TAMANHO), AvSx3("EIJ_ARDCOF", AV_DECIMAL)})
   EndIf
Endif

//TRP - 22/07/2010 - Campo para Admissão Temporária
IF EIJ->(FIELDPOS("EIJ_ALPROP")) != 0
   SX3->(DbSetOrder(2))
   SX3->(DbSeek("EIJ_ALPROP"))
   If !X3USO(SX3->X3_USADO)
      aAdd(aSemSX3EIJ, {"EIJ_ALPROP", AvSx3("EIJ_ALPROP", AV_TIPO), AvSx3("EIJ_ALPROP", AV_TAMANHO), AvSx3("EIJ_ALPROP", AV_DECIMAL)})
   EndIf
Endif

IF EIJ->(FIELDPOS("EIJ_TAXSIS")) = 0
   AADD(aSemSX3EIJ,{"EIJ_TAXSIS","N",15,2})
ENDIF
IF lDespBaseIcms                            //NCF - 20/12/2010 - Acerto de rateio das despesas base de ICMS por item das adições
   AADD(aSemSX3EIJ,{"EIJ_DPBICM","N",15,2})
ENDIF
AADD(aSemSX3EIJ,{"EIJ_TCOBPG","C",1,0})

aSemSX3EIM:={{"WKTEC"     ,"C",10,0}}// AWR - NVE - 19/10/2004
aSemSX3EIO:={{"WK_RECNO"  ,"N",10,0}}
//** TDF - 25/05/11 - Novo tratamento DE Mercosul
IF lEJ9
   aSemSX3EJ9:={{"WK_RECNO"  ,"N",10,0}}
ENDIF
aSemSX3SWV:={{"WKDISPLOT" ,"N",AVSX3("WV_QTDE",3),AVSX3("WV_QTDE",4)},;// AWR - Lote - 07/06/2004
             {"WKFLAGLOT" ,"C",2 ,0},;// AWR - Lote - 07/06/2004
             {"WK_DESCR"  ,"C",AVSX3("B1_DESC",3) ,0}}
IF EIO->(FIELDPOS("EIO_PARCEL")) = 0
   AADD(aSemSX3EIO,{"EIO_PARCEL","C",02,0})
ENDIF
aSemTOT   :={{"WKCODIGO"  ,"C",1,0}}

//TRP - 30/01/07 - Campos do WalkThru
AADD(aSemTOT,{"TRB_ALI_WT","C",03,0})
AADD(aSemTOT,{"TRB_REC_WT","N",10,0})

aIndiceEIF:={"EIF_CODIGO+EIF_DOCTO"}

//FDR - 31/01/12 - Alterado ordem do indice na Work
IF EIF->(FieldPos("EIF_SEQUEN")) > 0
   aIndiceEIF:={"EIF_SEQUEN+EIF_CODIGO+EIF_DOCTO"}
ENDIF

aIndiceEIG:={"EIG_CODIGO+EIG_NUMERO"}

aIndiceEIJ:={ "EIJ_ADICAO+EIJ_FORN","EIJ_ADICAO" }
             /*"EIJ_NROLI+EIJ_FORN+" + If(EicLoja(), "EIJ_FORLOJ+", "") + "EIJ_FABR+" + If(EicLoja(), "EIJ_FABLOJ+", "") + "EIJ_TEC+EIJ_EX_NCM+EIJ_EX_NBM+"+;
             "EIJ_CONDPG+STR(EIJ_DIASPG,3,0)+EIJ_MOEDA+EIJ_INCOTE"+;
             "+EIJ_REGTRI+EIJ_FUNREG+EIJ_MOTADI+EIJ_TACOII+EIJ_ACO_II"+IF(lREGIPIW8,"+EIJ_REGIPI","")+IF(lQbgOperaca,"+EIJ_OPERAC","")+IF(lTemNVE,"+EIJ_NVE","")+;
             IF(lAUTPCDI,"+EIJ_REG_PC+EIJ_FUN_PC+EIJ_FRB_PC","")+If(lEIJIPIPauta,"+STR(EIJ_VLRIPI,15,5)","")+If(lDAI,"+EIJ_CODMAT","") }//FDR - 24/11/11 - Adicionada a Aliq. do IPI de Pauta na quebra da adição
             */
//** TDF - 25/05/11 - Novo tratamento DE Mercosul
IF lEJ9
   aIndiceEJ9:={"EJ9_HAWB+EJ9_ADICAO"}
ENDIF

aIndiceEIK:={"EIK_ADICAO+EIK_TIPVIN+EIK_DOCVIN"}
aIndiceEIL:={"EIL_ADICAO+EIL_DESTAQ"}
aIndiceCIM:={"EIM_CODIGO"}// AWR - NVE
aIndiceEIM:={"EIM_ADICAO+EIM_NIVEL+EIM_ATRIB+EIM_ESPECI"+If(lEIM_NCM,"+EIM_NCM","")} 
IF lTemNVE// AWR - NVE
   AADD(aIndiceEIM,"EIM_CODIGO")// AWR - NVE
   AADD(aIndiceCIM,"WKTEC+EIM_NIVEL+EIM_ATRIB+EIM_ESPECI"+If(lEIM_NCM,"+EIM_NCM",""))
   AADD(aIndiceEIM,"EIM_FASE+EIM_HAWB+EIM_CODIGO+EIM_NIVEL+EIM_ATRIB+EIM_ESPECI"+If(lEIM_NCM,"+EIM_NCM",""))
   AADD(aIndiceEIM,"EIM_HAWB+EIM_NIVEL+EIM_CODIGO+EIM_ATRIB+EIM_ESPECI"+If(lEIM_NCM,"+EIM_NCM",""))
ENDIF        
aIndiceEIN:={"EIN_ADICAO+EIN_TIPO+EIN_CODIGO+EIN_FOBMOE"}
aIndiceEIO:={"EIO_ADICAO+EIO_TIPCOB+EIO_BANCO+EIO_PRACA+EIO_CAMBIO+EIO_CGCCOM+EIO_MESANO",;
             "EIO_ADICAO+EIO_TIPCOB+EIO_PARCEL"}
aIndiceSW9:={"W9_INVOICE+W9_FORN"+IF(EICLoja(), "+W9_FORLOJ+W9_HAWB", "+W9_HAWB")} // TDF 06/12/2010
aIndiceCWV:={"WV_LOTE+WV_FORN" + If(EICLoja(), "+WV_FORLOJ", "") + "+DTOS(WV_DT_VALI)"} // AWR - Lote
aIndiceSWV:={"WV_LOTE+WV_FORN" + If(EICLoja(), "+WV_FORLOJ", "") + "+DTOS(WV_DT_VALI)",;// AWR - Lote
             "WV_FORN" + If(EICLoja(), "+WV_FORLOJ", "") + "+WV_PGI_NUM+WV_PO_NUM+WV_POSICAO+WV_INVOICE",;// AWR - Lote
             "WV_PGI_NUM+WV_PO_NUM+WV_CC+WV_SI_NUM+WV_COD_I+STR(WV_REG,nTamReg)+WV_LOTE"}// AWR - Lote
aIndiceTWV:={"WV_LOTE+WV_FORN" + If(EICLoja(), "+WV_FORLOJ", "")+"+WV_INVOICE+WV_PGI_NUM+WV_PO_NUM+WV_POSICAO",;// AWR - Lote
             "WV_INVOICE+WV_FORN" + If(EICLoja(), "+WV_FORLOJ", "") + "+WV_PGI_NUM+WV_PO_NUM+WV_POSICAO"}// AWR - Lote
aIndiceSW8:= GetIndWKW8() //{"WKINVOICE+WKFORN" + If(EICLoja(), "+W8_FORLOJ", "") + "+WKPO_NUM+WKPOSICAO+WKPGI_NUM",;//1
                        //"WKFORN" + If(EICLoja(), "+W8_FORLOJ", "") + "+WKPO_NUM+WKPOSICAO+WKPGI_NUM",;//2
                        //"WKADICAO+WKSEQ_ADI",;//3
                        //"WKADICAO",;//4
                        //"WKNVE",;   //5 // AWR - NVE
                        //"WKTEC",;   //6 // AWR - NVE
                        //"WKGRUPORT"}//7 // AWR - 19/09/08 - NFE
//NCF - Índice 3 para histórico
            /*"WKREGIST+WKFORN" + If(EICLoja(), "+W8_FORLOJ", "") + "+WKFABR" + If(EICLoja(), "+W8_FABLOJ", "") + "+WKTEC+WKEX_NCM+WKEX_NBM+WKCOND_PA+STR(WKDIAS_PA,3,0)+WKMOEDA+WKINCOTER"+;
             "+WKREGTRI+WKFUNREG+WKMOTADI+WKTACOII+WKACO_II"+IF(lREGIPIW8,"+WKREGIPI","")+IF(lQbgOperaca,"+WKOPERACA","")+IF(lTemNVE,"+WKNVE","")+;
             IF(lAUTPCDI,"+WKREG_PC+WKFUN_PC+WKFRB_PC","")+If(!lTemAdicao .OR. lEIJIPIPauta ,"+STR(WKIPIPAUTA,15,5)","")+If(lDAI,"+WKCODMATRI",""),;*/ //+ "+STR(WKIPIPAUTA,15,5)",;//3// AWR - NVE   //NCF - 23/02/2011 - Adicionada a Aliq. do IPI de Pauta na quebra da adição

aIndiceTOT:={"WKCODIGO+W9_INVOICE+W9_FORN"+If(EICLoja(), "+W9_FORLOJ", ""),"WKCODIGO+W9_MOE_FOB"}
If !EICLoja()
   aCpoTot :={"W9_INVOICE","W9_FORN","W9_MOE_FOB","W9_FRETEIN","W9_INLAND","W9_PACKING",;
              "W9_OUTDESP","W9_DESCONT","W9_FOB_TOT","W6_FOB_TOT"}
Else
   aCpoTot :={"W9_INVOICE","W9_FORN","W9_FORLOJ","W9_MOE_FOB","W9_FRETEIN","W9_INLAND","W9_PACKING",;
              "W9_OUTDESP","W9_DESCONT","W9_FOB_TOT","W6_FOB_TOT"}
EndIf
If lInvAnt //DRL - 16/09/09 - Invoices Antecipadas
   aStruInv:={ {"WKFLAGWIN","C",02,0},;
               {"WKPLI"      ,AvSx3("W5_PGI_NUM",2),AvSx3("W5_PGI_NUM",3),AvSx3("W5_PGI_NUM",4)},;
               {"WKQTD_PLI"  ,AvSx3("W3_QTDE",2)   ,AvSx3("W3_QTDE",3)   ,AvSx3("W3_QTDE",4)},;
               {"WKQTD_SLA"  ,AvSx3("W3_QTDE",2)   ,AvSx3("W3_QTDE",3)   ,AvSx3("W3_QTDE",4)},;
               {"WKQTD_SEL"  ,AvSx3("W3_QTDE",2)   ,AvSx3("W3_QTDE",3)   ,AvSx3("W3_QTDE",4)},;
               {"WKQTD_ORI"  ,AvSx3("W3_QTDE",2)   ,AvSx3("W3_QTDE",3)   ,AvSx3("W3_QTDE",4)},;
               {"WKINVOIC"   ,AvSx3("EW5_INVOIC",2),AvSx3("EW5_INVOIC",3),AvSx3("EW5_INVOIC",4)},;
               {"WKPO_NUM"   ,AvSx3("W3_PO_NUM",2) ,AvSx3("W3_PO_NUM",3) ,AvSx3("W3_PO_NUM",4)},;
               {"WKPOSICAO"  ,AvSx3("W3_POSICAO",2),AvSx3("W3_POSICAO",3),AvSx3("W3_POSICAO",4)},;
               {"WKITEM"     ,AvSx3("W3_COD_I",2)  ,AvSx3("W3_COD_I",3)  ,AvSx3("W3_COD_I",4)},;
               {"WKUSADO"   ,"C",01,0} }
   aIndInv :=  {"WKPLI+WKPO_NUM+WKPOSICAO+WKINVOIC"}
EndIf

IF lSeginc
   AADD(aCpoTot,"W9_SEGURO")
ENDIF

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ALT_INDICE"),)
aTabelas:={}//cAlias,aIndice    ,aSemSX3   ,aCampos,aHeader,cComAlias
AADD(aTabelas,{"SW8",aIndiceSW8 ,aSemSX3SW8,{}     ,       ,'Nao',.F.})// Por causa do ambiente CTREE nao pode criar o campo DELETE por ultimo nesse arquivo, tem que ser o memo
AADD(aTabelas,{"SW9",aIndiceSW9 ,aSemSX3SW9,       ,       ,     ,NIL})
AADD(aTabelas,{"EIF",aIndiceEIF    ,aSemSX3,       ,{}     ,     ,NIL})
AADD(aTabelas,{"EIG",aIndiceEIG    ,aSemSX3,       ,{}     ,     ,NIL})
AADD(aTabelas,{"EIH",{"EIH_CODIGO"},aSemSX3,       ,{}     ,     ,NIL})
AADD(aTabelas,{"EII",{"EII_CODIGO"},aSemSX3,       ,{}     ,     ,NIL})
AADD(aTabelas,{"EIJ",aIndiceEIJ ,aSemSX3EIJ,       ,       ,     ,NIL})
IF lEJ9
   AADD(aTabelas,{"EJ9",aIndiceEJ9,aSemSX3EJ9,     ,{}     ,     ,NIL})
ENDIF
IF lTemAdicao .OR. lTemDSI
   AADD(aTabelas,{"EIK",aIndiceEIK ,aSemSX3,       ,{}     ,     ,NIL})
   AADD(aTabelas,{"EIL",aIndiceEIL ,aSemSX3,       ,{}     ,     ,NIL})
   AADD(aTabelas,{"EIN",aIndiceEIN ,aSemSX3,       ,{}     ,     ,NIL})
   AADD(aTabelas,{"EIO",aIndiceEIO ,aSemSX3EIO,    ,{}     ,     ,NIL})
ENDIF
//NCF - 08/08/2011 - Classificação N.V.A.E na PLI
If lCposNVEPLI
   aSemSX3_EIM := aClone(aSemSX3)
   aAdd(aSemSX3_EIM,{"EIM_HAWB",AVSX3("EIM_HAWB",2),AVSX3("EIM_HAWB",3),AVSX3("EIM_HAWB",4)})
   AADD(aTabelas,{"EIM",aIndiceEIM ,aSemSX3_EIM,   ,{}     ,     ,NIL})
Else
   AADD(aTabelas,{"EIM",aIndiceEIM ,aSemSX3,       ,{}     ,     ,NIL})
EndIf

IF lTemNVE// AWR - NVE
   AADD(aTabelas,{"CEIM",aIndiceCIM ,aSemSX3EIM,,      ,'EIM',NIL})// AWR - NVE
   If lCposNVEPLI
      aSemSX3GEIM := AClone(aSemSX3_EIM)
   Else
      aSemSX3GEIM := AClone(aSemSX3)
   EndIf

   AAdd( aSemSX3GEIM, { "EIM_ALI_WT", "C", 3,   0 } )
   AAdd( aSemSX3GEIM, { "EIM_REC_WT", "N", 10,  0 } )
   AADD(aTabelas,{"GEIM",aIndiceEIM ,aSemSX3GEIM,,{},'EIM',NIL})             //NCF - 09/11/2012
ENDIF
AADD(aTabelas,{"Tot",aIndiceTOT    ,aSemTOT,aCpoTot,       ,'Nao',NIL})
IF EasyGParam("MV_LOTEEIC",,"N") $ cSim // AWR - Lote
   AADD(aTabelas,{"SWV",aIndiceSWV ,{}        ,    ,       ,     ,.F.})// AWR - Lote - Principal  //NCF - 29/11/2017 - aSemSX3 {}
   AADD(aTabelas,{"CWV",aIndiceCWV ,{}        ,    ,       ,'SWV',.F.})// AWR - Lote - Capa       //NCF - 29/11/2017 - aSemSX3 {}
   AADD(aTabelas,{"TWV",aIndiceTWV ,aSemSX3SWV,    ,       ,'SWV',.F.})// AWR - Lote - Temporario
ENDIF

IF lAUTPCDI
   aIndiceSJZ:={"JZ_CODIGO"}
   AADD(aTabelas,{"SJZ",aIndiceSJZ ,{},       ,{}     ,     ,NIL})
ENDIF

If lInvAnt //DRL - 16/09/09 - Invoices Antecipadas
   AADD(aTabelas,{"Sel",aIndInv ,aStruInv,{},       ,'Nao',NIL})
EndIf

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"IND_ESTRU_EXTRA"),)

IF !lSchedule   //TRP-10/12/07
   Procregua(LEN(aTabelas))
ENDIF
SX3->(DBSETORDER(1))
FOR I := 1 TO LEN(aTabelas)
    IF !lSchedule   //TRP-10/12/07
       IncProc(STR0262+STR(I+1,2))//"Criando Arquivo Temporario "
    ENDIF
    If Select("Work_"+aTabelas[I][1]) <> 0 //LRS - 07/11/2018 - Verificar se a work existe para fechar
       ("Work_"+aTabelas[I][1])->(avzap())
    EndIF
    IF !DI500CriaTrab(aTabelas[I],aDelFile)
       RETURN .F.
    ENDIF    
NEXT
RETURN .T.

Function DI500CriaTrab(aTabelas,aDelFile)

LOCAL cAlias   :=aTabelas[1]
LOCAL aIndice  :=aTabelas[2]
LOCAL aSemSX3  :=aTabelas[3]
LOCAL aCpos    :=aTabelas[4]
LOCAL aHeader  :=aTabelas[5]
LOCAL xComAlias:=aTabelas[6]
LOCAL lDelete  :=IF(LEN(aTabelas)>6,aTabelas[7],NIL)
LOCAL cAliasWK :="Work_"+cAlias,cFileWk,F
LOCAL aWrkTmpBco := {"Work_SW8","Work_EIJ"}
LOCAL lFrcTmpBco := ( aScan(aWrkTmpBco,cAliasWK) > 0 .And. !TETempBanco() ) .Or. TETempBanco()
IF SX3->(DBSEEK(cAlias))
   DBSELECTAREA(cAlias)
ENDIF
IF(xComAlias#NIL,IF(xComAlias#'Nao',cAlias:=xComAlias,cAlias:=NIL),)// AWR - Lote
aCampos:=IF(aCpos=NIL,ARRAY((cAlias)->(Fcount())),aCpos)// AWR - Lote

/* wfs mai/2017 - adequação para uso do EECCRIATRAB(), com a passagem do 7º parâmetro */
aAdd(aSemSX3,{"DBDELETE","L",1,0}) //THTS - 01/11/2017 - Este campo deve sempre ser o ultimo campo da Work
cFileWk:=E_CriaTrab(cAlias,aSemSX3,cAliasWK,aHeader,lDelete,, SaveTempFiles(), lFrcTmpBco  )

IF !USED()
   Help(" ",1,"E_NAOHAREA")
   RETURN .F.
ENDIF
AADD(aDelFile,{cAliasWK,cFileWk})
nQtdeIndice:=LEN(aDelFile)
FOR F := 1 TO LEN(aIndice)
   IF F > 1
      cFileWk:= E_Create(,.F., cAliasWK, cAliasWK, F-1, SaveTempFiles())//E_Create(,.F.)
      AADD(aDelFile,{,cFileWk})
   ENDIF
   E_IndRegua(cAliasWK,cFileWk+ TEOrdBagExt(),aIndice[F])
   /* wfs mai/2017 - reaproveitamento de arquivos temporários */
   If SaveTempFiles() .And. F == 1
      Set Index To (cFileWk+TEOrdBagExt())
   EndIf
NEXT
IF LEN(aIndice) > 1
   DBSELECTAREA(cAliasWk)
   SET INDEX TO
   FOR F := nQtdeIndice TO LEN(aDelFile)
      DBSETINDEX(aDelFile[F,2]+ TEOrdBagExt())
   NEXT
ENDIF
RETURN .T.

Function DI500Manut(cAlias,nReg,nOpc)//Antiga DI400Visual(),DI400Inclui(),DI400Altera(),DI400Estorn()

LOCAL aOk:={||FINALIZAR}//,STR0421} //"Sair"
LOCAL bValid :={||.T.}, D, i, I6,N
LOCAL x3ord  := SX3->(INDEXORD())
LOCAL cCpoBasICMS,lTemYB_ICM_UF
Local lTopo //LRL 25/03/04 - Define se Existe um MsSelect abaixo da Enchoice para alinhamento na MDI
LOCAL X := 0, aLockSW4 := {} //ASR 10/02/2006
Local oDLGBACK
Local lDespDA , l
Local lTpOcor   := EDD->(FIELDPOS("EDD_CODOCO")) > 0 .And. EDD->(FIELDPOS("EDD_DESTIN")) > 0 //AOM - 22/06/2012 - Campos para gravação de Itens comprados na Anterioridade
Local nOrdSW5
Local lDuimp := AvFlags("DUIMP") .AND. If(nOpc == INCLUSAO, .F., SW6->W6_TIPOREG == DUIMP)
local nRecEV1 := 0
Local aValidacao := {}

PRIVATE aCorrespW7 := {} , aCorrespW8 := {} , aCorrespMeSW8 := {}
PRIVATE lMV_SLD_EMB:=EasyGParam("MV_SLD_EMB",,.F.) // LDR
PRIVATE lMV_PIS_EIC:=EasyGParam("MV_PIS_EIC",,.F.) .AND. SW8->(FIELDPOS("W8_BASPIS")) # 0 .AND. SYD->(FIELDPOS("YD_PER_PIS")) # 0
PRIVATE lMV_ICMSPIS:= lMV_PIS_EIC .AND. EasyGParam("MV_ICMSPIS",,.F.)
PRIVATE cMV_CODTXSI:= EasyGParam("MV_CODTXSI",,"415")
PRIVATE lDISimples := .F., lGetRegTri := .F.  //GFC 26/11/2003
PRIVATE nAcertaFOB := 0
PRIVATE nFOB_TOT   := 0 // EOS 17/11
PRIVATE nOPC_mBrw  := nOPC   // JBS - 28/11/2003
PRIVATE aLotes  :={},lGravaSWV:=.F.// AWR - Lote
PRIVATE lRetifica :=.F.
Private lMsgEnv   := IF(nOPC=ALTERACAO,.T.,.F.)
PRIVATE lWhenAutPis:=.F.,lWhenAutCof:= .F.
PRIVATE lValidaEic := .T. //JAP - 18/08/2006
PRIVATE aICMS_Dif    := {}
PRIVATE nVlrOpc := nOpc // DFS - 14/01/2010 - Inclusão de variável para validação do campo W6_CURRIER
PRIVATE aTabsNVEDI := {} //NCF - 10/10/2011
Private nOpcAdiVis:= nOpc
Private lTaxa := .F.    // GFP - 25/02/2013
Private lTitEAI_OK //:= .T. // JL- 17/07/2014 VARIAVEL DE CONTROLE PARA GERAÇÃO DE CAMBIO QUANDO INTEGRADO COM O LOGIX
//FSM - 17/05/2012 - Admissão em Entreposto
Private lContAdm := .F.
Private aPOAdm := {}
Private nContPo := 0
Private nVezesEnvia := 0
Private lOperacaoEsp := AvFlags("OPERACAO_ESPECIAL")
Private lRegerCamb := .T.  // GFP - 04/09/2015
Private lEIM_NCM := EIM->(FieldPos("EIM_NCM")) > 0 //AvFlags("NVE_POR_PRODUTO")
Private oCheckWork:= tHashMap():New()
//RRV - 22/02/2013 - Tratamento de títulos provisórios de numerário.
If EasyGParam("MV_EIC0023",,.F.) //AAF 02/02/2017 - Declarado para existir mesmo que gravar somente a capa.
   Private cControle := "Desemb"
EndIf

If lOperacaoEsp
  PRIVATE oOperacao := EASYOPESP():New()
EndIf

PRIVATE aCorrespWork := {} //AOM - 04/04/2011

Private nTaxaDolar//RMD - 23/12/14 - Variável para registrar a taxa do dolar informada no botão "Taxas"
//WFS 03/12/2013 - função estática para redefinir as variáveis de filial
DI500AtuFilial()
// MFR 06/10/2021 OSSME-6278 
If nopc == 4
   nOrdSW5 := SW5->(INDEXORD())
   SW5->(DBSETORDER(2))
   SW5->(DbSeek(xFilial("SW5")+SW6->W6_HAWB))
   SW5->(dbEval({|| CheckWork() },,{|| SW5->(!EOF()) .AND. xFilial("SW5") == SW5->W5_FILIAL .AND. SW5->W5_HAWB == SW6->W6_HAWB  }))   
   SW5->(DBSETORDER(nOrdSW5))
EndIf

//Tabela SW7 - Itens Declaração de Importação  - AOM - 04/04/2011
AADD(aCorrespW7,{"W7_COD_I"   ,"WKCOD_I"    })//Código do Item
AADD(aCorrespW7,{"W7_FABR"    ,"WKFABR"     })//Fabricante
AADD(aCorrespW7,{"W7_FORN"    ,"WKFORN"     })//Fornecedor
AADD(aCorrespW7,{"W7_FLUXO"   ,"WKFLUXO"    })//Fluxo
AADD(aCorrespW7,{"W7_QTDE"    ,"WKQTDE"     })//Quantidade
AADD(aCorrespW7,{"W7_CC"      ,"WKCC"       })//Unidade Requisitante
AADD(aCorrespW7,{"W7_SI_NUM"  ,"WKSI_NUM"   })//Num. da SI
AADD(aCorrespW7,{"W7_PO_NUM"  ,"WKPO_NUM"   })//Num. do PO
AADD(aCorrespW7,{"W7_PGI_NUM" ,"WKPGI_NUM"  })//Num. PLI
AADD(aCorrespW7,{"W7_PRECO"   ,"WKPRECO"    })//Preço
AADD(aCorrespW7,{"W7_SALDO_Q" ,"WKQTDE"     })//Saldo Qtde
AADD(aCorrespW7,{"W7_SEQ"     ,"WKSEQ"      })//Sequencia
AADD(aCorrespW7,{"W7_REG"     ,"WKREG"      })//Parcela No.
AADD(aCorrespW7,{"W7_PESO"    ,"WKPESO_L"   })//Peso Liquido
AADD(aCorrespW7,{"W7_OPERACA" ,"WKOPERACA"  })//Operação
AADD(aCorrespW7,{"W7_SEQ_LI"  ,"WKSEQ_LI"   })//Sequencia LI
AADD(aCorrespW7,{"W7_INVOICE" ,"WKINVOICE"  })//Invoice
AADD(aCorrespW7,{"W7_POSICAO" ,"WKPOSICAO"  })//Posição
AADD(aCorrespW7,{"W7_EX_NCM"  ,"WKEX_NCM"   })//Ex-NCM
AADD(aCorrespW7,{"W7_EX_NBM"  ,"WKEX_NBM"   })//EX-NBM
AADD(aCorrespW7,{"W7_NCM"     ,"WKTEC"      })//N.C.M
AADD(aCorrespW7,{"W7_VLR_IPI" ,"WKIPIPAUTA" })//Valor do IPI Unitario
AADD(aCorrespW7,{"W7_PESOMID" ,"WKPESOMID"  })//Peso MID

//Adicionando na Work de correspondencia
aAdd(aCorrespWork,{"SW7","Work",aCorrespW7})

//Tabela SW8 - Itens da Invoice - AOM - 04/04/2011
AADD(aCorrespW8,{"W8_INVOICE"   ,"WKINVOICE"    })//Invoice
AADD(aCorrespW8,{"W8_SI_NUM"    ,"WKSI_NUM"     })//Nr SI
AADD(aCorrespW8,{"W8_QTDE"      ,"WKQTDE"       })//Quantidade
AADD(aCorrespW8,{"W8_PRECO"     ,"WKPRECO"      })//Preço
AADD(aCorrespW8,{"W9_FOB_TOT"   ,"WKPRTOTMOE"      })//Preço Itens
AADD(aCorrespW8,{"W8_COD_I"     ,"WKCOD_I"      })//Código do Item
// MFR 02/09/2021 OSSME-6152
AADD(aCorrespW8,{"W3_PART_N"    ,"WKPART_N",AVSX3('W3_PART_N',5)})  //NCF - 30/10/2009 - Adição do campo de Part-Number na Invoice
AADD(aCorrespW8,{"B1_DESC"      ,"WKDESCITEM",LEFT(AVSX3('B1_DESC',5),9)})     
AADD(aCorrespW8,{"W8_FABR"      ,"WKFABR"       })//Fabrica
AADD(aCorrespW8,{"W8_FABLOJ"    ,"W8_FABLOJ"    })//Fabricante Loja

AADD(aCorrespW8,{"W7_PESO"      ,"WKPESO_L"     }) //Peso Líq. Unit.
If lPesoBruto
   AADD(aCorrespW8,{"W8_PESO_BR","WKW8PESOBR"   }) //Peso Bruto Unit.
EndIf
AADD(aCorrespW8,{"WKPESOTOT"    ,"WKPESOTOT"    }) //"Peso Total" aqui neste caso é WKPESOTOT nos dois parâmetros mesmo

AADD(aCorrespW8,{"W8_REG"       ,"WKREG"        })//Parcela
AADD(aCorrespW8,{"W8_PO_NUM"    ,"WKPO_NUM"     })//Num. do PO
AADD(aCorrespW8,{"W8_CC"        ,"WKCC"         })//Cliente Int.
AADD(aCorrespW8,{"W8_PGI_NUM"   ,"WKPGI_NUM"    })//No PLI
AADD(aCorrespW8,{"W8_SEQ_LI"    ,"WKSEQ_LI"     })//Seq LI
AADD(aCorrespW8,{"W8_FLUXO"     ,"WKFLUXO"      })//Fluxo
AADD(aCorrespW8,{"W8_BASEII"    ,"WKBASEII"     })//Base .I .I R$
AADD(aCorrespW8,{"W8_BASEICM"   ,"WKBASEICM"    })//Base ICMS R$
AADD(aCorrespW8,{"W8_TAXASIS"   ,"WKTAXASIS"    })//Taxa Siscomex
AADD(aCorrespW8,{"W8_FOBTOTR"   ,"WKFOBTOTR"    })//FOB Total R$
AADD(aCorrespW8,{"W8_VLMLE"     ,"WKVLMLE"      })//VLMV Moeda
AADD(aCorrespW8,{"W8_FORN"      ,"WKFORN"       })//Fornecedor
AADD(aCorrespW8,{"W8_FORLOJ"    ,"W8_FORLOJ"    })//Loja do Fornecedor
AADD(aCorrespW8,{"W8_OUTDESP"   ,"WKOUTDESP"    })//Outr. Desp.
AADD(aCorrespW8,{"W8_INLAND"    ,"WKINLAND"     })//Inland Charg.
AADD(aCorrespW8,{"W8_FRETEIN"   ,"WKFRETEIN"    })//Int'l Freigh
AADD(aCorrespW8,{"W8_PACKING"   ,"WKPACKING"    })//Packing Charg
AADD(aCorrespW8,{"W8_DESCONT"   ,"WKDESCONT"    })//Desconto
AADD(aCorrespW8,{"W8_VLACRES"   ,"WKVLACRES"    })//Acrescimo R$
AADD(aCorrespW8,{"W8_VLDEDU"    ,"WKVLDEDU"     })//Deducao R$
AADD(aCorrespW8,{"W8_TEC"       ,"WKTEC"        })//N.c.m
AADD(aCorrespW8,{"W8_EX_NCM"    ,"WKEX_NCM"     })//Ex-NCM
AADD(aCorrespW8,{"W8_EX_NBM"    ,"WKEX_NBM"     })//Ex-NBM
AADD(aCorrespW8,{"W8_POSICAO"   ,"WKPOSICAO"    })//Posicao
AADD(aCorrespW8,{"W8_OPERACA"   ,"WKOPERACA"    })//Operacao
AADD(aCorrespW8,{"W8_ADICAO"    ,"WKADICAO"     })//Adicao
AADD(aCorrespW8,{"W8_VLSEGMN"   ,"WKVLSEGMN"    })//Seguro R$
AADD(aCorrespW8,{"W8_VLFREMN"   ,"WKVLFREMN"    })//Frete R$
AADD(aCorrespW8,{"W8_VLICMS"    ,"WKVLICMS"     })//I.C.M.S R$
AADD(aCorrespW8,{"W8_VLII"      ,"WKVLII"       })//I.I. R$
AADD(aCorrespW8,{"W8_VLIPI"     ,"WKVLIPI"      })//I.P.I. R$
AADD(aCorrespW8,{"W8_VLDEVII"   ,"WKVLDEVII"    })//Vl. Dev II R$
AADD(aCorrespW8,{"W8_SEQ_ADI"   ,"WKSEQ_ADI"    })//Seq. Adicao
AADD(aCorrespW8,{"W8_ACO_II"    ,"WKACO_II"     })//Acor Tarif II
AADD(aCorrespW8,{"W8_NVE"       ,"WKNVE"        })//Tab N.V.E.
AADD(aCorrespW8,{"W8_UNID"      ,"WKUNID"       })//Unidade de Medida
AADD(aCorrespW8,{"W8_GRUPORT"   ,"WKGRUPORT"    })//Grp Regtri
AADD(aCorrespW8,{"W8_QTDE_UM"   ,"WKQTDE_UM"    })//Quant. Unid
AADD(aCorrespW8,{"W8_D_BAICM"   ,"WKD_BAICM"    })//Desp.B.ICMS
//AADD(aCorrespW8,{"W8_QTDVOL"    ,"WKQTDVOL"     })//Qtde Vol //Nopado por RRV - 14/01/2013
AADD(aCorrespW8,{"W8_SEGURO"    ,"WKSEGURO"     })//Seguro
//AADD(aCorrespW8,{"W8_VLUPIS"    ,"WKPERPIS"     })//Vlr Unit PIS                 NCF - 22/02/2016 - Condicionada a inclusão no teste de parametro abaixo.
//AADD(aCorrespW8,{"W8_VLUCOF"    ,"WKVLUCOF"     })//Vlr Unit COFIN
//AADD(aCorrespW8,{"W8_PERPIS"    ,"WKPERPIS"     })//% PIS
//AADD(aCorrespW8,{"W8_PERCOF"    ,"WKPERCOF"     })//% COFIN

//FDR - 10/07/12
If lIntDraw
   AADD(aCorrespW8,{"W8_AC"        ,"WKAC"         })//Ato Concessório
   AADD(aCorrespW8,{"W8_SEQSIS"    ,"WKSEQSIS"     })//Seq. Ato
   AADD(aCorrespW8,{"W8_QT_AC"     ,"WKQT_AC"      })//Qtd. no A.C.
   AADD(aCorrespW8,{"W8_QT_AC2"    ,"WKQT_AC2"     })//Qtd. Comp. no A.C.
   AADD(aCorrespW8,{"W8_VL_AC"     ,"WKVL_AC"      })//Valor no A.C.
EndIf

AADD(aCorrespW8,{"W8_REGIPI"    ,"WKREGIPI"     })//Reg Trib IPI

IF lAUTPCDI                                                             //NCF - 23/02/2016 - Condicionado ao parâmetro
   AADD(aCorrespW8,{"W8_REG_PC"    ,"WKREG_PC"     })//Reg Trib P/C
   AADD(aCorrespW8,{"W8_FUN_PC"    ,"WKFUN_PC"     })//Fund Leg P/C
   AADD(aCorrespW8,{"W8_FRB_PC"    ,"WKFRB_PC"     })//Reg Red P/C
   IF lMV_PIS_EIC
      AADD(aCorrespW8,{"W8_VLDEPIS"   ,"WKVLDEPIS"    })//V. Devido PIS
      AADD(aCorrespW8,{"W8_VLDECOF"   ,"WKVLDECOF"    })//V. Devido COF
      AADD(aCorrespW8,{"W8_VLUPIS"    ,"WKPERPIS"     })//Vlr Unit PIS
      AADD(aCorrespW8,{"W8_VLUCOF"    ,"WKVLUCOF"     })//Vlr Unit COFIN
      AADD(aCorrespW8,{"W8_PERPIS"    ,"WKPERPIS"     })//% PIS
      AADD(aCorrespW8,{"W8_PERCOF"    ,"WKPERCOF"     })//% COFIN
   ENDIF
ENDIF

AADD(aCorrespW8,{"W8_VLICMDV"   ,"WKVLICMDV"    })//ICMS Devido

AADD(aCorrespMeSW8,{"W8_QTDE"    ,"nSaldo"    })//Quantidade
AADD(aCorrespMeSW8,{"W8_PRECO"   ,"nPreco"    })//Preço
AADD(aCorrespMeSW8,{"W8_INLAND"  ,"nInland"   })//Inland Charg.
AADD(aCorrespMeSW8,{"W8_PACKING" ,"nPacking"  })//Packing Charg
AADD(aCorrespMeSW8,{"W8_DESCONT" ,"nDesconto" })//Desconto
AADD(aCorrespMeSW8,{"W8_FRETEIN" ,"nFrete"    })//Int'l Freigh
AADD(aCorrespMeSW8,{"W8_OUTDESP" ,"nOutDesp"  })//Outr. Desp.
AADD(aCorrespMeSW8,{"W8_ADICAO"  ,"cAdicao"   })//Adicao
AADD(aCorrespMeSW8,{"W8_QTDE_UM" ,"nQtde_Um"  })//Quant. Unid
AADD(aCorrespMeSW8,{"W8_AC"      ,"cAto"      })//Ato Concessório
AADD(aCorrespMeSW8,{"W8_SEGURO"  ,"nSeguro"   })//Seguro


//Adicionando na Work de correspondencia
aAdd(aCorrespWork,{"SW8","Work_SW8",aCorrespW8   })
aAdd(aCorrespWork,{"SW8","M"       ,aCorrespMeSW8})


SIX->(DBSETORDER(1))// AWR - Lote
lTemLote:= SWV->(FIELDPOS("WV_INVOICE")) # 0 .AND.;// AWR - Lote
           SWV->(FIELDPOS("WV_POSICAO")) # 0 .AND.;
           SWV->(FIELDPOS("WV_FORN"))    # 0 .AND.;
           SIX->(dbSeek("SWV2")) .and. EasyGParam("MV_LOTEEIC",,"N") $ cSim;
//MFR 27/07/2021 OSSME-6090
If AvFlags("DUIMP") .And. lTemLote
           lTemLote := ( Empty(Alltrim(Posicione("SW9",3,xFilial("SW9")+SW6->W6_HAWB,"W9_INVOICE"))) .Or. SW6->W6_TIPOREG <> '2') //Se for DUIMP e tiver invoice então não tem lote
EndIf
lTemNVE := EIM->(FIELDPOS("EIM_CODIGO")) # 0 .AND.;// AWR - NVE
           SW8->(FIELDPOS("W8_NVE"))     # 0 .AND.;// AWR - NVE
           EIJ->(FIELDPOS("EIJ_NVE"))    # 0 .AND.;// AWR - NVE
           SIX->(dbSeek("EIM2"))

lSair:=.F.
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"INICIO_DI500MANUT"),)
IF lSair
   RETURN 0
ENDIF

// DUIMP 
if nOpc == ALTERACAO .and. ( MOpcao == FECHTO_EMBARQUE .or. MOpcao == FECHTO_DESEMBARACO ) .and. lDuimp .and. SW6->W6_FORMREG == DUIMP_INTEGRADA .and. existFunc("DU100VdSW6") .and. !DU100VdSW6( @nRecEV1, SW6->W6_HAWB )
   return nOpc
endif

//**
IF LCAMBIO_EIC
   SW9->(DBSETORDER(3))
   SWB->(DBSETORDER(1))
   IF nOpc = 5 //nao deixar excluir se no processo tiver alguma invoice sem titerp
      SW9->(DBSEEK(cFilSW9+SW6->W6_HAWB))
      cProcesso:=SW6->W6_HAWB
      DO WHILE SW9->(!EOF()) .AND. SW9->W9_FILIAL == cfilSW9  .AND. cProcesso == SW9->W9_HAWB
         IF EMPTY(SW9->W9_TITERP) .AND. lEICFI06
            MSGINFO(STR0581 + SW9->W9_INVOICE+STR0582) //STR0581 'Processo nao pode ser excluido pois a invoice: ' //STR0582 'está sem o titulo.'
            RETURN 0
         ENDIF
         SW9->(DBSKIP())
      ENDDO
      cProcesso:=SW6->W6_HAWB
      SWB->(DBSEEK(cFilSWB+cProcesso+AVKEY('D','WB_PO_DI') ))
      DO WHILE SWB->(!EOF()) .AND. SWB->WB_FILIAL == cfilSWB;
                             .AND. cProcesso      == SWB->WB_HAWB;
                             .AND. SWB->WB_PO_DI  == AVKEY('D','WB_PO_DI')

         //IF EMPTY(SWB->WB_TITERP) .AND. lEICFI05
         //IF IIF(lIntegStat, SWB->WB_TITRET$cNao, EMPTY(SWB->WB_TITERP) ) .AND. lEICFI05  // PLB 15/04/10 - Status de Retorno do ERP
         IF IIF(lIntegStat, SWB->WB_TITRET$cNao, .F. ) .AND. lEICFI05  // PLB 15/04/10 - Status de Retorno do ERP
            //MSGINFO('Processo nao pode ser excluido pois cambio: está sem o titulo.')
	            MSGINFO(STR0583)  // PLB 15/04/10 - Status de Retorno do ERP //  //STR0583 'Processo nao pode ser excluido pois cambio está sem retorno do ERP.'
            RETURN 0
         ENDIF
         SWB->(DBSKIP())
      ENDDO
   ENDIF
ENDIF
//**

nOPC:=nOPC_mBrw// AWR - 04/11/2004

IF lTemDSI .AND. MOpcao # FECHTO_EMBARQUE
   IF nOpc = 7//Atencao: NAO MUDAR A POSICAO DA DSI NO AROTINA, TEM QUER SER 7
      nOpc := INCLUSAO
      lDISimples:=.T.
      lTemAdicao:=.T.
   ELSEIF !Inclui .AND. SW6->W6_DSI=="1"
      lDISimples:=.T.
      lTemAdicao:=.T.
   ENDIF
ENDIF

IF nOpc # INCLUSAO .AND. nOpc # VISUAL
   If !DI500PROG()
      Return nOpc
   EndIf
EndIf

//JVR - 18/01/2010 - Tratamento para não permitir estorno caso tenha titulo baixado.
If nOpc = ESTORNO
   SWD->(DBSetOrder(1))
   If SWD->(DBSeek(xFilial("SWD") + SW6->W6_HAWB ))
      While SWD->(!Eof()) .and. SWD->WD_HAWB == SW6->W6_HAWB

         //ISS - 23/08/10 - Tratamento para validar apenas as parcelas da DI de nacionalização.
         If SWD->WD_DA == "1" .AND. SW6->W6_TIPOFEC == "DIN"
            lDespDA := .F.
         Else
            lDespDA := .T.
         EndIf

         If !Empty(SWD->WD_PREFIXO) .and. !Empty(SWD->WD_CTRFIN1) .and. !Empty(SWD->WD_TIPO) .and. ;
            !Empty(SWD->WD_FORN)    .and. !Empty(SWD->WD_LOJA).and. lDespDA
            If IsBxE2Eic(SWD->WD_PREFIXO,SWD->WD_CTRFIN1,SWD->WD_TIPO,SWD->WD_FORN,SWD->WD_LOJA,,SWD->WD_PARCELA)
               MsgInfo(STR0584) // STR0584 "Processo não pode ser estornado, visto que ha título(s) de despesa(s) baixado(s)!"
               RETURN .F.
            EndIf
         EndIf
         SWD->(DBSKIP())
      EndDo
   EndIf

    // TDF - 15/08/11 - Não permitir estorno caso tenha Invoice e MV_DATAFIN > DDATABASE
    SW9->(DBSetOrder(3))
    If lFinanceiro .AND. SW9->(DBSeek(xFilial("SW9") + SW6->W6_HAWB ))
       If EasyGParam("MV_DATAFIN") > DDATABASE
          MsgInfo(STR0574 + ENTER + STR0575, STR0057)
          Return .F.
       EndIf
    EndIf
EndIf

IF nOpc = ALTERACAO .OR. nOpc = ESTORNO
	IF ALLTRIM(SW6->W6_TIPOFEC) == "DA" .AND. SW2->(DBSEEK(xFilial("SW2")+LEFT("DA"+SW6->W6_DI_NUM,LEN(SW2->W2_PO_NUM))))
		MsgInfo(STR0585 + IF(nOpc=ALTERACAO, STR0586, STR0587)+STR0588) //STR0585 "Processo nao pode ser " //STR0586 "alterado" //STR0587 "estornado" //STR0588 ", visto que ha nacionalizacao em andamento!"
		RETURN .F.
	ENDIF
   If !SW6->(RecLock("SW6",.F.,.F.,.T.))
      Return .F.
   Endif
ENDIF

//** PLB 04/12/06 - Verifica se é possível estornar um Embarque ou Desembaraço que tenham itens apropriados à Ato Concessório de Drawback
If nOpc == ESTORNO  .And.  ( MOpcao == FECHTO_EMBARQUE  .Or.  MOpcao == FECHTO_DESEMBARACO ) .And. Type("oMUserEDC") == "O"
   If lIntDraw  .And.  !Empty(SW6->W6_DI_NUM)  .And.  lMUserEDC  .And.  !oMUserEDC:Reserva("DI","ESTORNA")
      Return .F.
   EndIf
EndIf
//**

IF !lCriouOK
   IF lSchedule  //TRP-10/12/07
      lCriouOK:=DI500CriaWork()
   ELSE
      Processa({|| lCriouOK:=DI500CriaWork(lSchedule)},STR0260) //"Criando Temporarios"
   ENDIF
   IF !lCriouOK
      SW6->(MsUnlock())
      RETURN .F.
   ENDIF
ENDIF

PRIVATE aBotoes1T:={}
PRIVATE aSemSX3:=NIL
PRIVATE aCamposMostra:=aEmbarques
PRIVATE aDarGets:=NIL
PRIVATE cNomArq :=''
PRIVATE lExiste :=.T.,aDeletados:={}, aEAIDeletados:= {}
PRIVATE aWkDeletados := {}    //NCF - 09/11/2012
PRIVATE lGravaEIF:=lGravaEIG:=lGravaEIH:=lGravaEII:=.F.
PRIVATE lGravaEIJ:=lGravaEIK:=lGravaEIL:=lGravaEIM:=lGravaEIN:=lGravaEIO:=lGravaEJ9:=.F.
PRIVATE nPos_aRotina  := nOpc
PRIVATE lAltDescricao := GETNEWPAR("MV_DESCDI",.T.)
PRIVATE lPrimeiraVez  :=.T.
PRIVATE cPedido:=SPACE(LEN(SW7->W7_PO_NUM))
PRIVATE cPLI:=SPACE(LEN(SW7->W7_PGI_NUM))
PRIVATE aPedido:={},aPLI:={}, aInv := {} //DRL - 16/09/09 - Invoices Antecipadas
PRIVATE cPONAC:=cPedido,lGetPo:=.T.
PRIVATE dDataBranca:=AVCTOD("")
PRIVATE aAliasCapa:={'EIF','EIG','EIH','EII','EIJ','EIM'}
PRIVATE aAliasAdic:=IF(lTemAdicao,{'EIK','EIL','EIN','EIO'},{})
PRIVATE lBuscaTaxaAuto:=.T.
PRIVATE lGravaSoCapa:=.T.
PRIVATE lTemCambio  :=.F.
PRIVATE lAltSoTaxa  :=.F.// So serve p/ quando nao tem Adicao e nao tem DSI
PRIVATE lTemNfE   := .F.
PRIVATE cVM_OBS   :=' '
PRIVATE cVM_OBS_PE:=' '  // JBS - 28/11/2003
PRIVATE cVM_COMP  :=' '
PRIVATE nSomaBaseICMS:=0
PRIVATE nBaseICMSPeso:=0 //TDF - 05/10/2012
PRIVATE nSomaTaxaSisc:=0// AWR - 18/02/2004
Private nSomaDespRatAdicao:= 0, cDespRatAdicao:= EasyGParam("MV_EIC0060",,"")
Private oEnch1 //LRL 25/03/04
Private cProcDI := ""   // TLM 21/02/2008
If lInvAnt //DRL - 16/09/09 - Invoices Antecipadas
   cInv := Space(AVSX3("W8_INVOICE",3))
Endif
//PRIVATE nSomaNoCIF:=0 //Em Analise AWR
Private lSelectPO := .T. // DFS - Habilitar ou desabilitar a seleção de POs para o desembaraço da nacionalização.

If lEJ9 .And. lTemAdicao
   AAdd(aAliasAdic, "EJ9")
EndIf

IF !Inclui
   SF1->(DBSETORDER(5))
   //ISS - 13/12/10 - Verificação se o HAWB corrente possui alguma nota gerada, e não apenas notas de despesas (NFD)
   If lCposNFDesp
      lTemNfE := SF1->(DBSEEK(xFilial()+SW6->W6_HAWB)) .AND. ExistHAWBNFE(SW6->W6_HAWB)
   Else
      lTemNfE:= SF1->(DBSEEK(xFilial()+SW6->W6_HAWB))
   EndIf
ENDIF
IF !Inclui .AND. lTemAdicao

   SYT->(DBSETORDER(1))
   SYT->(dBSeek(xFilial("SYT")+SW6->W6_IMPORT))
   cCpoBasICMS:="YB_ICMS_"+Alltrim(SYT->YT_ESTADO)
   lTemYB_ICM_UF:=SYB->(FIELDPOS(cCpoBasICMS)) # 0

   SYB->(DBSETORDER(1))
   SWD->(DBSETORDER(1))
   SWD->(DbSeek(xFilial()+SW6->W6_HAWB))
   DO WHILE xFilial('SWD') == SWD->WD_FILIAL .AND.;
            SWD->WD_HAWB   == SW6->W6_HAWB .AND.;
           !SWD->(EOF()) .AND. lTemAdicao
      IF SYB->(DBSEEK(xFilial()+SWD->WD_DESPESA)) .AND. !SWD->( LEFT(SWD->WD_DESPESA,1) ) $ "1,2,9" ;
         .AND. SWD->WD_DESPESA <> cMV_CODTXSI  // Bete 23/05/05 - para não duplicar a tx do siscomex
         lBaseICM:=SYB->YB_BASEICM $ cSim
         IF lTemYB_ICM_UF
            lBaseICM:=lBaseICM .AND. SYB->(FIELDGET(FIELDPOS(cCpoBasICMS))) $ cSim
         ENDIF
         IF lBaseICM
            If SWD->WD_DESPESA $ cDespRatAdicao //.And. RJ //wfs
               /* despesas que devem ser rateadas pela quantidade de adições */
               nSomaDespRatAdicao += SWD->WD_VALOR_R
            //TDF - 05/10/12 - Rateia . de ICMS por peso
            ElseIf SYB->YB_RATPESO $ cSim //SYB->YB_RATPESO == "1"
               nBaseICMSPeso+=SWD->WD_VALOR_R
            Else
               nSomaBaseICMS+=SWD->WD_VALOR_R
            EndIf
         ENDIF
      ENDIF
      SWD->(DBSKIP())
   ENDDO
ENDIF

SF1->(DBSETORDER(1))
M->W6_IMPORT  :=SPACE(LEN(SW6->W6_IMPORT))
M->W6_ADICAOK :=SPACE(LEN(SW6->W6_ADICAOK))
cMOEDAProc    :=SPACE(LEN(SW2->W2_MOEDA))

If Select("Work") > 0 //LRS - 26/01/2018
   Work->(avzap())
EndIF 
FOR D := 1 TO LEN(aTabelas)
   cAliasZ:="Work_"+aTabelas[D,1]
  (cAliasZ)->(avzap())
NEXT

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"INICIO_OPCAO"),)

DO CASE

CASE nOpc == VISUAL//******* V I S U A L ***********************************************
     DBSELECTAREA("SW6")
     IF Bof() .AND. Eof()
        Return nOpc
     EndIf

     FOR i := 1 TO FCount()
        M->&(FIELDNAME(i)) := FieldGet(i)
     NEXT i

     IF lTemDSI
        lDISimples := (M->W6_DSI=="1")
     ENDIF

     IF !lDISimples
        IF MOpcao = FECHTO_DESEMBARACO
           IF ( lTemDI .and. SW6->W6_TEM_DI = "2" ) .Or. (AVFLAGS("DUIMP") .And. M->W6_TIPOREG == DUIMP) //DUIMP
              lTemAdicao := .F.
            ELSE
              lTemAdicao := temAdicao()//.T.
            ENDIF
        ENDIF
     ENDIF

     aCampos:={"W7_SEQ_LI" , "W7_PGI_NUM", "WP_VENCTO" ,"W7_PO_NUM" , "W7_CC"     , "W7_SI_NUM" ,;
               "W7_COD_I"  , "W5_DESC_P" , "W7_POSICAO","W7_FABR"   , "W5_FABR_N" , "W7_FORN"   ,;
               "W5_FORN_N" , "W7_QTDE"   , "W7_PRECO"  ,"W6_FOB_TOT", "W9_INVOICE", "W9_DT_EMIS",;
               "W7_PESO"   , "W7_NCM"    , "W7_EX_NCM" ,"W7_EX_NBM" , "WP_REGIST"}

     EICAddLoja(aCampos, "W7_FORLOJ", Nil, "W7_FORN")
     EICAddLoja(aCampos, "W7_FABLOJ", Nil, "W7_FABR")

     //TRP - 30/01/07 - Campos do WalkThru
     aSemSx3 := {}
     AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
     AADD(aSemSX3,{"TRB_REC_WT","N",10,0})
     AADD(aSemSX3,{"WK_OK"     ,"C",02,0})
     IF AvFlags("EIC_EAI")  //SSS - REQ. 6.2 - 27/06/2014 - Unidade de Medida do Fornecedor no processo de importação
        AADD(aSemSX3,{"WKUNI"    ,"C",AVSX3("W3_UM"     ,3),0})
        AADD(aSemSX3,{"WKQTSEGUM","N",AVSX3("W3_QTSEGUM",3),AVSX3("W3_QTSEGUM" ,4)})
        AADD(aSemSX3,{"WKSEGUM"  ,"C",AVSX3("W3_SEGUM"  ,3),0})
        AADD(aSemSX3,{"WKFATOR"  ,"N",AVSX3("J5_COEF"   ,3),AVSX3("J5_COEF"    ,4)})
     EndIf
     //FSM - 01/08/2011 - "Peso Bruto Unitário"
     If lPesoBruto
        aAdd(aSemSX3,{"WKW7PESOBR" ,AVSX3("W7_PESO_BR",AV_TIPO), AVSX3("W7_PESO_BR",AV_TAMANHO),AVSX3("W7_PESO_BR",AV_DECIMAL)})
     EndIf

     If lIntDraw
        aAdd(aCampos,"W5_AC")
     EndIf

     //AOM - 14/04/2011
     If lOperacaoEsp
       AADD(aSemSX3,{"W8_CODOPE"    ,AVSX3("W8_CODOPE",2),AVSX3("W8_CODOPE",3),AVSX3("W8_CODOPE",4)})
     EndIf

     IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"VISUAL_CAMPOS"),)

     cNomArq:=E_CriaTrab(,aSemSX3,,,,, SaveTempFiles())
     E_IndRegua("TRB",cNomArq+TEOrdBagExt(),"W7_PGI_NUM+W7_CC+W7_SI_NUM+W7_COD_I")

     aTB_Campos := {}
     IF MOpcao==FECHTO_NACIONALIZACAO
        AADD(aTB_Campos,{{||TRANS(TRB->W7_PO_NUM,AVSX3("W2_PO_NUM",6))+"  "},,STR0079})//"Nacionalizacao"
     ELSE
        AADD(aTB_Campos,{"W7_PO_NUM" ,,AVSX3("W7_PO_NUM" ,5)})
     ENDIF
     IF cPaisLoc=="BRA"
        AADD(aTB_Campos,{"W7_PGI_NUM",,AVSX3("W7_PGI_NUM",5)})
        AADD(aTB_Campos,{"W7_SEQ_LI" ,,AVSX3("W7_SEQ_LI" ,5)})
        AADD(aTB_Campos,{"WP_REGIST" ,,AVSX3("WP_REGIST" ,5),AVSX3("WP_REGIST" ,6)})
        AADD(aTB_Campos,{"WP_VENCTO" ,,AVSX3("WP_VENCTO" ,5)})
     ENDIF
     AADD(aTB_Campos,{"W7_CC"     ,,AVSX3("W7_CC"     ,5)})
     AADD(aTB_Campos,{"W7_SI_NUM" ,,AVSX3("W7_SI_NUM" ,5)})
     AADD(aTB_Campos,{"W7_POSICAO",,AVSX3("W7_POSICAO",5)})
     AADD(aTB_Campos,{"W7_COD_I"  ,,AVSX3("W7_COD_I"  ,5)})

     IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ADD_TB_CAMPOS"),)  // rs 11/11/05

     If lIntDraw .and. lMensDrawback .and. Empty(M->W6_DTREG_D)  //GFC 18/08/04
        AADD(aTB_Campos,{{|| MensDrawback(.T.,TRB->W7_COD_I,TRB->W7_FORN,TRB->W9_INVOICE,TRB->W7_PO_NUM,TRB->W7_POSICAO,TRB->W7_PGI_NUM,TRB->W5_AC,TRB->W7_NCM)},,"Drawback"})//LRS - 28/09/2016 alterado o primeiro parametro para imprimir a coluna drawback na visualização
     Endif
     AADD(aTB_Campos,{"W5_DESC_P" ,,STR0043              })
     AADD(aTB_Campos,{"W7_FABR"   ,,AVSX3("W7_FABR"   ,5)})
     If EICLoja()
        AADD(aTB_Campos,{"W7_FABLOJ"   ,,AVSX3("W7_FABLOJ"   ,5)})
     EndIf
     AADD(aTB_Campos,{"W5_FABR_N" ,,AVSX3("W5_FABR_N" ,5)})
     AADD(aTB_Campos,{"W7_FORN"   ,,AVSX3("W7_FORN"   ,5)})
     If EICLoja()
        AADD(aTB_Campos,{"W7_FORLOJ"   ,,AVSX3("W7_FABLOJ"   ,5)})
     EndIf
     AADD(aTB_Campos,{"W5_FORN_N" ,,AVSX3("W5_FORN_N" ,5)})
     AADD(aTB_Campos,{"W7_QTDE"   ,,AVSX3("W7_QTDE"   ,5),AVSX3("W7_QTDE",6)})
     IF AvFlags("EIC_EAI")  //SSS - REQ. 6.2 - 27/06/2014 - Unidade de Medida do Fornecedor no processo de importação
        AADD(aTB_Campos,{"WKUNI"    ,,AVSX3("W3_UM"     ,5)})
        AADD(aTB_Campos,{"WKQTSEGUM",,AVSX3("W3_QTSEGUM",5),AVSX3("W3_QTSEGUM" ,6)})
        AADD(aTB_Campos,{"WKSEGUM"  ,,AVSX3("W3_SEGUM"  ,5)})
        AADD(aTB_Campos,{"WKFATOR"  ,,"Fator Conv 2UM"  ,AVSX3("J5_COEF",6)    })
     ENDIF
     AADD(aTB_Campos,{"W7_PRECO"  ,,AVSX3("W7_PRECO"  ,5),AVSX3("W7_PRECO",6)})
     AADD(aTB_Campos,{"W6_FOB_TOT",,AVSX3("W9_FOB_TOT",5),AVSX3("W6_FOB_TOT",6)})
     AADD(aTB_Campos,{"W7_PESO"   ,,AVSX3("W7_PESO",5)   ,AVSX3("W7_PESO",6)})

     //FSM - 01/08/2011 - "Peso Bruto Unitário"
     If lPesoBruto
        aAdd(aTB_Campos,{"WKW7PESOBR"   ,,AVSX3("W7_PESO_BR",5)   ,AVSX3("W7_PESO_BR",6)})
     EndIf

     AADD(aTB_Campos,{"W7_NCM"    ,,AVSX3("W3_TEC",5)    ,AVSX3("W3_TEC",6)})
     AADD(aTB_Campos,{"W7_EX_NCM" ,,AVSX3("W3_EX_NCM",5) ,AVSX3("W3_EX_NCM",6)})
     AADD(aTB_Campos,{"W7_EX_NBM" ,,AVSX3("W3_EX_NBM",5) ,AVSX3("W3_EX_NBM",6)})
     AADD(aTB_Campos,{"W9_INVOICE",,AVSX3("W9_INVOICE",5)})
     AADD(aTB_Campos,{"W9_DT_EMIS",,STR0051}) //"Data da Invoice"

     If lIntDraw
        AADD(aTB_Campos,{"W5_AC",,AVSX3("W5_AC",5)}) //"Ato Concess."
     EndIf

     //AOM - 14/04/2011
     If lOperacaoEsp
       AADD(aTB_Campos,{"W8_CODOPE",,AVSX3("W8_CODOPE",5),AVSX3("W8_CODOPE",6)})
     EndIf

     IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"VISUAL_INDICE_COLUNAS"),)

     Processa({|| DI500GrvTRB(.F.) },STR0054) //"Pesquisa de Itens"

     IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"VISUAL_DEPOIS_GRVTRB"),)
     TRB->(DBGOTOP())

     AADD(aBotoes1T,{"BAIXATIT" /*"VERNOTA"*/   ,{|| DI500Invoices()},STR0425}) //"Invoices"
     IF MOpcao # FECHTO_EMBARQUE
        IF lDISimples
           AADD(aBotoes1T,{"BUDGET"    ,{|| DI500Simples() },STR0156}) //STR0156  "Impostos"
        ELSEIF lTemAdicao .And. !lDuimp
           AADD(aBotoes1T,{"BMPINCLUIR",{|| DI500Adicoes() },STR0426 }) //"Adicoes"
        ENDIF
     ENDIF
     IF cPaisLoc=="BRA" .AND. !lTemAdicao .AND. !lDISimples .And. !lDuimp// Nao pode aparecer quando for visual e Adicao
        AADD(aBotoes1T,{"PRECO" ,{|| DI500RegPesq() },STR0589/*,STR0529*/}) //LRL 25/03/04 -"Reg.Trib" //STR0589 "Regime de Tributacao"
     ENDIF

     IF FindFunction("EICAdicao").AND. lExisteSEQ_ADI .AND. !lTemAdicao .AND. !lDISimples .And. !lDuimp//AWR - 18/09/2008 - NFE
        AADD(aBotoes1T,{"BMPINCLUIR",{|| EICAdicao(.F.,4,.T.)},STR0426}) //STR0426 := "Adicoes"
     ENDIF

     IF(lTemLote, AADD(aBotoes1T,{"CONTAINR",{|| DI500Lotes() },"Lotes"}) ,)// AWR - Lote
     AADD(aBotoes1T,{"SIMULACAO",{|| DI500Totais(oMark)  },STR0382 }) //"Totais"

     AADD(aBotoes1T,{"TOP"   ,{|| nOpca:=10,oDlg:End()},STR0511 })//"Primeiro"
     AADD(aBotoes1T,{"PREV"  ,{|| nOpca:=20,oDlg:End()},STR0512 })//"Anterior"
     AADD(aBotoes1T,{"NEXT"  ,{|| nOpca:=30,oDlg:End()},STR0513 })//"Proximo"
     AADD(aBotoes1T,{"BOTTOM",{|| nOpca:=40,oDlg:End()},STR0514 })//"Ultimo"
     //******* V I S U A L ***********************************************
CASE nOpc == INCLUSAO//****** I N C L U S A O ******************************************
     lTemAdicao :=  temAdicao()//EasyGParam("MV_TEM_DI",,.F.)
     lExiste:=.F.
     DI500Fil(.F.)

     dbSelectArea("SW6")
     FOR I6 := 1 TO FCount()
         M->&(FIELDNAME(I6)) := CRIAVAR(FIELDNAME(I6))
     NEXT
     IF lDISimples
        M->W6_DSI:="1"
        IF lTemDI
           M->W6_TEM_DI:="1"
        ENDIF
     ENDIF

     IF lTemDI .AND. !lDISimples
        IF MOpcao = FECHTO_DESEMBARACO
            IF !MSgYesNo(STR0590,STR0141) //STR0590 "Utilizar DI Eletronica para esse processo ?"
               lTemAdicao := .F.
            ELSE
               lTemAdicao := .T.
               M->W6_TEM_DI:="1"
            ENDIF
        ENDIF
     ENDIF

     DI500Controle(0,{M->W6_VLFRECC,M->W6_VLFREPP,M->W6_VLFRETN,M->W6_VLSEGMN,M->W6_VL_USSE,M->W6_SEGBASE,M->W6_SEGPERC,M->W6_TX_FRET})

     lSelectPO := .T. // DFS - Habilitar ou desabilitar a seleção de POs para o desembaraço da nacionalização.

     IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"E_INITVAR"),)

     IF MOpcao == FECHTO_NACIONALIZACAO .AND. lSelectPO // DFS - Habilitar ou desabilitar a seleção de POs para o desembaraço da nacionalização.
        If !DI500SELPO()
           DI500Fil(.T.)
           Return 3
        EndIf
     EndIf

     bValid:={|| Obrigatorio(aGets,aTela).AND.;
                 E_Valid(aGets,{|campo| DI_Valid(campo,,.T.)}).AND.;
                 DI_Valid("TUDO",.F.,.T.).AND. DI500CUSTO()}
     aOk:=NIL

     If MOpcao <> FECHTO_EMBARQUE  //CCM - 15/05/09 - Alteração para o botão não aparecer no embarque.
        AADD(aBotoes1T,{"TABPRICE" /*"LJPRECO"*/,{|| Processa({|| DI500Taxa(.T.,.T.,nOPC)})    },STR0591})//RMD - Alteração na imagem utilizada, para evitar redundância com o regime de tributação. //STR0591 "Taxas  // GFP - 11/03/2013
     Endif

     AADD(aBotoes1T,{"BAIXATIT" /*"VERNOTA"*/,{|| IF(Eval(bValid),DI500Invoices(),)},STR0425})  //STR0425 "Invoices"
     IF MOpcao # FECHTO_EMBARQUE
        IF lDISimples
           AADD(aBotoes1T,{"BUDGET"    ,{|| IF(Eval(bValid),DI500Simples() ,)},STR0156}) //STR0156  "Impostos"
        ELSEIF lTemAdicao .And. !lDuimp
           AADD(aBotoes1T,{"BMPINCLUIR",{|| IF(Eval(bValid),DI500Adicoes() ,)},STR0426}) //STR0426 := "Adicoes"
           AADD(aBotoes1T,{"BMPGROUP"  ,{|| DI500EIJManut(5)},STR0471/*,STR0530*/}) //LRL 25/03/04 -  "Model.Adi" //STR0471 := "Modelo de Adicoes"
        ENDIF
     ENDIF
     IF cPaisLoc=="BRA" .AND. !lDISimples .And. !lDuimp
        AADD(aBotoes1T,{"PRECO",{|| IF(Eval(bValid),DI500RegPesq() ,)},STR0589/*,STR0529*/}) //LRL 25/03/04 -   "Reg.Trib" //STR0589 "Regime de Tributacao"
     ENDIF
     IF(lTemLote, AADD(aBotoes1T,{"CONTAINR",{|| DI500Lotes() },STR0592}) ,)// AWR - Lote //STR0592 "Lotes"
     //IF(lTemNVE , AADD(aBotoes1T,{"PRODUTO" ,{|| (DI500NVE(nOPC_mBrw),Work->(DBGOTOP()),oMark:oBrowse:Refresh())   },"N.V.E."}),)// AWR - NVE
     AADD(aBotoes1T,{"SIMULACAO" ,{|| DI500Totais() },STR0382 }) //LGS 22/07/13  - Habilitado "Totais"
     AADD(aBotoes1T,{"CLIPS"/*"NOVACELULA"*/,{|| DI500Comple() },STR0593/*,STR0531*/ }) //LRL 25/03/04 -  "Edit.Comp" //STR0593 "Edicao Complemento"
     AADD(aBotoes1T,{"NEXT"      ,{|| IF(Eval(bValid),IF(DI500Itens(),FINALIZAR,),)},STR0594}) //STR0594 "Itens"
     // SVG - 08/04/09 -
     IF FindFunction("EICAdicao").AND. lExisteSEQ_ADI .AND. !lTemAdicao .AND. !lDISimples .And. !lDuimp//AWR - 18/09/2008 - NFE
        AADD(aBotoes1T,{"BMPINCLUIR",{|| EICAdicao(.F.,4,.T.)},STR0426}) //STR0426 := "Adicoes"
     ENDIF

     //****** I N C L U S A O ******************************************
CASE nOpc == ALTERACAO//**** A L T E R A C A O *****************************************

     DBSELECTAREA("SW6")
     IF Bof() .AND. Eof()
        SW6->(MsUnlock())
        Return nOpc
     EndIf
     FOR i := 1 TO FCount()
        M->&(FIELDNAME(i)) := FieldGet(i)
     NEXT i

     aValidacao := DU100MtArr(M->W6_HAWB)

     IF !EasyGParam("MV_TEM_DI",,.F.) .And. !Empty(M->W6_DI_NUM) .And. SW6->(FieldPos("W6_VERSAO")) > 0 .And. Empty(M->W6_VERSAO) //MCF - 18/04/2016
        M->W6_VERSAO := "00"
     ENDIF

     IF lTemDSI
        lDISimples := (M->W6_DSI=="1")
     ENDIF

     IF !lDISimples
        IF MOpcao = FECHTO_DESEMBARACO
           IF ( lTemDI .and. SW6->W6_TEM_DI = "2" ) .Or. (AVFLAGS("DUIMP") .And. M->W6_TIPOREG == DUIMP) //DUIMP
              lTemAdicao := .F.
           ELSE
              lTemAdicao := temAdicao()//.T.
           ENDIF
        ENDIF
     ENDIF

     DI500Controle(0,{M->W6_VLFRECC,M->W6_VLFREPP,M->W6_VLFRETN,M->W6_VLSEGMN,M->W6_VL_USSE,M->W6_SEGBASE,M->W6_SEGPERC,M->W6_TX_FRET})

     lNoBaixa:=.T.
     lNoBaixa:=EICFI400("VAL_CPO_DI")

     lSair:=.F.
     IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ALTERA"),)

     If lSair
        SW6->(MsUnlock())
        RETURN nOpc
     EndIf

     bValid:={|| E_Valid(aGets,{|C| DI_Valid(C,,.T.)}).AND.DI_Valid("TUDO",.F.,.T.).AND.DI500CUSTO()}
     aOk   :={|| If(DI500GrvCapa(bValid),FINALIZAR,) }
     AADD(aBotoes1T,{"TABPRICE" /*"LJPRECO"*/,{|| IF(DI500AlterValid(bValid,.F.,.F.,.T.),Processa({|| DI500Taxa(.T.,.T.,nOPC)}),) },STR0591})//RMD - Alteração na imagem utilizada, para evitar redundância com o regime de tributação. //STR0591 "Taxas"  // GFP - 11/03/2013
     AADD(aBotoes1T,{"BAIXATIT" /*"VERNOTA"*/,{|| IF(DI500AlterValid(bValid,.T.,.F.,.T.),DI500Invoices(),)},"Invoices"})
     IF MOpcao # FECHTO_EMBARQUE
        IF lDISimples
           AADD(aBotoes1T,{"BUDGET"    ,{|| IF(DI500AlterValid(bValid,.T.,.F.),DI500Simples()  ,)},STR0156}) //STR0156  "Impostos"
        ELSEIF lTemAdicao .And. !lDuimp
           AADD(aBotoes1T,{"BMPINCLUIR",{|| IF(DI500AlterValid(bValid,.T.,.F.),DI500Adicoes()  ,)},STR0426}) //STR0426 := "Adicoes"
           AADD(aBotoes1T,{"BMPGROUP"  ,{|| IF(DI500AlterValid(bValid,.F.,.F.),DI500EIJManut(5),)},STR0471/*,STR0530*/}) //LRL 25/03/04 -   "Model.Adi" //STR0471 := "Modelo de Adicoes"
        ENDIF
     ENDIF
     IF cPaisLoc=="BRA" .AND. !lDISimples .And. !lDuimp
        AADD(aBotoes1T,{"PRECO"        ,{|| IF(DI500AlterValid(bValid,.T.,.F.),DI500RegPesq() ,)},STR0589/*,STR0529*/}) //LRL 25/03/04 - "Reg.Trib" //STR0589 "Regime de Tributacao"
     ENDIF
     IF(lTemLote, AADD(aBotoes1T,{"CONTAINR",{|| IF(DI500AlterValid(bValid,.T.,.F.),DI500Lotes(),) },STR0592}) ,)// AWR - Lote  //STR0592 "Lotes"
     //IF(lTemNVE , AADD(aBotoes1T,{"PRODUTO" ,{|| IF(DI500AlterValid(bValid,.T.,.F.),DI500NVE(nOPC_mBrw)  ,) },"N.V.E."}),)// AWR - NVE
     AADD(aBotoes1T,{"SIMULACAO" ,{|| DI500Totais() },STR0382 }) //LGS 22/07/13  - Habilitado "Totais"
     AADD(aBotoes1T,{"CLIPS"/*"NOVACELULA"*/,{|| DI500Comple() },STR0593/*,STR0531*/ }) //LRL 25/03/04 -   "Edit.Comp" //STR0593 "Edicao Complemento"
     AADD(aBotoes1T,{"NEXT"      ,{|| IF(DI500AlterValid(bValid,.T.,.F.),IF(DI500Itens(),FINALIZAR,),)},STR0594}) //STR0594 "Itens"
     // SVG - 08/04/09 -
     IF FindFunction("EICAdicao").AND. lExisteSEQ_ADI .AND. !lTemAdicao .AND. !lDISimples  .And. !lDuimp//AWR - 18/09/2008 - NFE
        AADD(aBotoes1T,{"BMPINCLUIR",{|| EICAdicao(.F.,4,.T.)},STR0426}) //STR0426 := "Adicoes"
     ENDIF


     Processa({|| DI500EIGrava('LEITURA',SW6->W6_HAWB,aAliasCapa)},STR0595)//STR0595 "Gravando Arquivos Temporarios..."

     // **** A L T E R A C A O *****************************************
CASE nOpc == ESTORNO// *******  E S T O R N O  ******************************************

     // GCC - 17/12/2013 - Não permitir a exclusão do processo com o relatório de custo realizado impresso
	 EI1->(DbSetOrder(1))
	 If EI1->(DbSeek(xFilial()+SW6->W6_HAWB))
	 	MsgStop(STR0851) // "Processo não pode ser estornado, pois o mesmo contém o relatório de custo realizado impresso."
		Return nOpc
	 EndIf

     IF !EICFI400("VAL_CPO_DI")
        EICFI400('MENSAGEM')
        SW6->(MsUnlock())
        RETURN nOpc
     ENDIF

     lSair:=.F.
     IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ESTORNO"),)
     If lSair
        SW6->(MsUnlock())
        RETURN nOpc
     EndIf

     SW7->( DBSetOrder(1) )
     IF !SW7->(DBSEEK(xFilial()+SW6->W6_HAWB))
        Help(" ",1,"E_NAOHAITE")//NAO HA ITENS PARA O PROCESSAMENTO.
     ELSE
        IF lValidaEIC //JAP 19/08/06
           EIC->(DBSETORDER(1))
           IF EIC->(DBSEEK(xFilial()+SW6->W6_HAWB))
              Help("",1,"AVG0000722")//Processo nao pode ser estornado, pois possui Despesas na Solicitacao de Numerario
              SW6->(MsUnlock())
              Return nOpc
           ENDIF
        ENDIF
        SF1->(DBSETORDER(5))
        IF SF1->(DBSEEK(xFilial()+SW6->W6_HAWB))
           Help("", 1, "AVG0000250")//'Processo não pode ser estornado, pois possui NF(s) de entrada
           SF1->(DBSETORDER(1))
           SW6->(MsUnlock())
           Return nOpc
        ENDIF
        SX3->(DBSETORDER(2))
        IF lTem_ECO .AND. SX3->(DBSEEK("W6_CONTAB"))
           IF !EMPTY(SW6->W6_CONTAB)
              Help("", 1, "AVG0000251")//'Itens do processo não podem ser ESTORNADOS -processo Contabilizado
              SX3->(DBSETORDER(x3ord))
              SW6->(MsUnlock())
              Return nOpc
           ENDIF
        ENDIF
        If lIntDraw  .And. !EasyGParam("MV_EDC0009",,.F.) //AOM 19/12/2011
           ED2->(dbSetOrder(4))
           If ED2->(dbSeek(cFilED2+SW6->W6_HAWB))
              Help("", 1, "AVG0000723",,ED2->ED2_AC,3,0)//Msg Info(STR0508+ED2->ED2_AC+").") //"Processo nao pode ser estornado pois esta apropriado para Drawback (A.C. "
              SW6->(MsUnlock())
              Return nOpc
           ElseIf cAntImp=="2" //GFC - 17/07/2003 - Anterioridade Drawback
              If  EDD->(dbSeek(cFilEDD+SW6->W6_HAWB))
                 Do While !EDD->(EOF()) .and. EDD->EDD_FILIAL==cFilEDD .and. EDD->EDD_HAWB==SW6->W6_HAWB
                    If (!Empty(EDD->EDD_PREEMB)  .Or. !Empty(EDD->EDD_PEDIDO) .Or. (lTpOcor .And. !Empty(EDD->EDD_CODOCO)) ) //AOM - 23/11/2011 - Tratamento para considerar Vendas para exportadores.
                       MsgInfo(STR0596) //STR0596 "Processo não pode ser estornado pois tem itens ligados a REs de acordo com a anterioridade."
                       SW6->(MsUnlock())
                       Return nOpc
                    EndIf
                    EDD->(dbSkip())
                 EndDo
              EndIf
           EndIf
        EndIf
        SX3->(DBSETORDER(1))
        SF1->(DBSETORDER(1))

        // Bete 13/09/05 - verificacao se no cambio ha adiantamentos vinculados
		IF lCposAdto
		   lTemAdto := .F.
		   cFilSWB := xFilial("SWB")
		   SWB->(dbSetorder(1))
		   SWB->(DBSEEK(cFilSWB + SW6->W6_HAWB + "D"))
		   DO WHILE !SWB->(eof()) .AND. SWB->WB_FILIAL==cFilSWB .AND. SWB->WB_HAWB==SW6->W6_HAWB .AND. SWB->WB_PO_DI=="D"
		      IF Left(SWB->WB_TIPOREG,1) == "P"
		         lTemAdto := .T.
		         EXIT
		      ENDIF
		      SWB->(dbSkip())
		   ENDDO
		   IF lTemAdto
		      MSGINFO(STR0597) //STR0597 "Atencao! Existem adiantamentos vinculados p/ este processo no cambio"
		      RETURN nOpc
		   ENDIF
		ENDIF

        IF !lFinanceiro
           SWA->(DBSETORDER(1))
           // EOS - Se existir os cpos referente a pagamento antecipado, trata Seek
           // com um campo a mais o WB_PO_DI que, nas parcelas de cambio de DI tera como
           // conteudo a letra "D".
           cFilSWA  := xFilial("SWA")
           cChavSWA := cFilSWA + SW6->W6_HAWB
           IF lCposAdto
              cChavSWA += "D"
           ENDIF
           IF desCambLiq(.T.)
              Return nOpc
           ENDIF
        ENDIF
        IF MOpcao = FECHTO_DESEMBARACO .OR. MOpcao == FECHTO_NACIONALIZACAO
           IF _Declaracao
              IF SW7->W7_FLUXO # "4"
                 Help(" ",1,"E_ENTRPNAO")//HOUSE NAO EH ENTREPOSTADO
                 SW6->(MsUnlock())
                 Return nOpc
              ENDIF
           ELSE
              IF SW7->W7_FLUXO = "4"
                 Help(" ",1,"E_ENTRPSIM")//HOUSE EH ENTREPOSTADO
                 SW6->(MsUnlock())
                 Return nOpc
              ENDIF
          ENDIF
        ENDIF
        If lAvIntFinEIC
           SWD->(DBSETORDER(1))
           SWD->(DbSeek(xFilial()+SW6->W6_HAWB))
           DO WHILE xFilial('SWD') == SWD->WD_FILIAL .AND.;
                    SWD->WD_HAWB   == SW6->W6_HAWB .AND.;
                    !SWD->(EOF())

              If !Empty(SWD->WD_TITERP) .OR. Upper(Left(AllTrim(SWD->WD_CTRLERP),7)) == "ENVIADO"
                 MsgStop(STR0598) //STR0598 "Existem despesas neste processo que já foram enviadas ao ERP. Faça o estorno do Envio ao Financeiro ERP."
                 Return nOpc
              EndIf

              SWD->(DBSKIP())
           ENDDO

           If EW6->(dbSeek(xFilial("EW6")+'DRL'+SW6->W6_HAWB))
              MsgStop(STR0599) //STR0599 "Processo já possui compensação de despesas. Faça o estorno da compensação na rotina de Envio de Despesas."
              Return nOpc
           EndIf
        EndIf
     ENDIF

     IF !SW6->(RecLock("SW6",.F.,.T.))
        Return nOpc
     ENDIF

     if !EasyVldSX9( "SW6" , { { "EV1", { xFilial("EV1") } }} )
        return nOpc
     endif

     DbSelectArea("SW6")
     FOR i := 1 TO FCount()
         M->&(FIELDNAME(i)) := FieldGet(i)
     NEXT
     IF lTemDSI
        lDISimples := (M->W6_DSI=="1")
     ENDIF

     SW7->(DBSETORDER(1))
     SW7->(DBSEEK(xFilial()+SW6->W6_HAWB))

     aCampos:={"W7_SEQ_LI" ,"W7_PGI_NUM","W7_POSICAO","WP_VENCTO","W7_PO_NUM" ,"W7_CC",;
               "W7_SI_NUM" ,"W7_COD_I"  ,"W5_DESC_P" ,"W7_FABR"  ,"W5_FABR_N",;
               "W7_FORN"   ,"W5_FORN_N" ,"W7_QTDE"   ,"W7_PRECO" ,"W6_FOB_TOT","W7_HAWB" ,;
               "W9_INVOICE","W9_DT_EMIS","WP_REGIST" ,"W7_PESO"  ,"W7_NCM"    ,"W7_EX_NCM",;
               "W7_EX_NBM"}
     If lIntDraw
        aAdd(aCampos,"W5_AC")
     EndIf

     If EICLoja()
        EICAddLoja(aCampos, "W7_FABLOJ", Nil, "W7_FABR")
        EICAddLoja(aCampos, "W7_FORLOJ", Nil ,"W7_FORN")
     EndIf

     aSemSX3:={}
     AADD(aSemSX3,{"WKFLAG"    ,"L",01,0})
     AADD(aSemSX3,{"W7_REG"    ,"N",nTamReg,0})
     AADD(aSemSX3,{"W5_PGI_NUM","C",AvSx3("W5_PGI_NUM", AV_TAMANHO),0})
     AADD(aSemSX3,{"WKRECNO"   ,"N",10,0})
     AADD(aSemSX3,{"WK_OK"     ,"C",02,0})
     //TRP - 30/01/07 - Campos do WalkThru
     AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
     AADD(aSemSX3,{"TRB_REC_WT","N",10,0})

     IF AvFlags("EIC_EAI")  //AWF - REQ. 6.2 - 04/08/2014 - Unidade de Medida do Fornecedor no processo de importação
        AADD(aSemSX3,{"WKUNI"    ,"C",AVSX3("W3_UM"     ,3),0})
        AADD(aSemSX3,{"WKQTSEGUM","N",AVSX3("W3_QTSEGUM",3),AVSX3("W3_QTSEGUM" ,4)})
        AADD(aSemSX3,{"WKSEGUM"  ,"C",AVSX3("W3_SEGUM"  ,3),0})
        AADD(aSemSX3,{"WKFATOR"  ,"N",AVSX3("J5_COEF"   ,3),AVSX3("J5_COEF"    ,4)})
     EndIf

     IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ESTORNO_CAMPOS"),)

     //FSM - 01/08/2011 - "Peso Bruto Unitário"
     If lPesoBruto
        aAdd(aSemSX3,{"WKW7PESOBR" ,AVSX3("W7_PESO_BR",AV_TIPO), AVSX3("W7_PESO_BR",AV_TAMANHO),AVSX3("W7_PESO_BR",AV_DECIMAL)})
     EndIf

     //AOM - 14/04/2011
     If lOperacaoEsp
       AADD(aSemSX3,{"W8_CODOPE"    ,AVSX3("W8_CODOPE",2),AVSX3("W8_CODOPE",3),AVSX3("W8_CODOPE",4)})
     EndIf

     cNomArq:=E_CriaTrab(,aSemSX3,,,,, SaveTempFiles())

     E_IndRegua("TRB",cNomArq+TEOrdBagExt(),"W7_PGI_NUM+W7_CC+W7_SI_NUM+W7_COD_I")

     aTB_Campos:={}
     AADD(aTB_Campos,{"WK_OK"     ,," " })
     IF MOpcao==FECHTO_NACIONALIZACAO
        AADD(aTB_Campos,{{||TRANS(TRB->W7_PO_NUM,AVSX3("W2_PO_NUM",6))+"  "},,STR0079})//"Nacionalizacao"
     ELSE
        AADD(aTB_Campos,{"W7_PO_NUM" ,,AVSX3("W7_PO_NUM" ,5)})
     ENDIF
     IF cPaisLoc=="BRA"
        AADD(aTB_Campos,{"W7_PGI_NUM",,AVSX3("W7_PGI_NUM",5)})
        AADD(aTB_Campos,{"W7_SEQ_LI" ,,AVSX3("W7_SEQ_LI" ,5)})
        AADD(aTB_Campos,{"WP_REGIST" ,,AVSX3("WP_REGIST" ,5),AVSX3("WP_REGIST" ,6)})
        AADD(aTB_Campos,{"WP_VENCTO" ,,AVSX3("WP_VENCTO" ,5)})
     ENDIF
     AADD(aTB_Campos,{"W7_CC"     ,,AVSX3("W7_CC"     ,5)})
     AADD(aTB_Campos,{"W7_SI_NUM" ,,AVSX3("W7_SI_NUM" ,5)})
     AADD(aTB_Campos,{"W7_POSICAO",,AVSX3("W7_POSICAO",5)})
     AADD(aTB_Campos,{"W7_COD_I"  ,,AVSX3("W7_COD_I"  ,5)})

     IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ADD_TB_CAMPOS"),)     // RS 11/11/05

     If lIntDraw .and. lMensDrawback .and. Empty(M->W6_DTREG_D)  // GFC 18/08/04
        AADD(aTB_Campos,{{|| MensDrawback(.F.,TRB->W7_COD_I,TRB->W7_FORN,TRB->W9_INVOICE,TRB->W7_PO_NUM,TRB->W7_POSICAO,TRB->W7_PGI_NUM,TRB->W5_AC,TRB->W7_NCM)},,"Drawback"})
     Endif
     AADD(aTB_Campos,{"W5_DESC_P" ,,STR0043              })
     AADD(aTB_Campos,{"W7_FABR"   ,,AVSX3("W7_FABR"   ,5)})
     If EICLoja()
        AADD(aTB_Campos,{"W7_FABLOJ"   ,,AVSX3("W7_FABLOJ"   ,5)})
     EndIf
     AADD(aTB_Campos,{"W5_FABR_N" ,,AVSX3("W5_FABR_N" ,5)})
     AADD(aTB_Campos,{"W7_FORN"   ,,AVSX3("W7_FORN"   ,5)})
     If EICLoja()
        AADD(aTB_Campos,{"W7_FORLOJ"   ,,AVSX3("W7_FABLOJ"   ,5)})
     EndIf
     AADD(aTB_Campos,{"W5_FORN_N" ,,AVSX3("W5_FORN_N" ,5)})
     AADD(aTB_Campos,{"W7_QTDE"   ,,AVSX3("W7_QTDE"   ,5),_PictQtde})
     IF AvFlags("EIC_EAI")  //SSS - REQ. 6.2 - 27/06/2014 - Unidade de Medida do Fornecedor no processo de importação
        AADD(aTB_Campos,{"WKUNI"    ,,AVSX3("W3_UM"     ,5)})
        AADD(aTB_Campos,{"WKQTSEGUM",,AVSX3("W3_QTSEGUM",5),AVSX3("W3_QTSEGUM" ,6)})
        AADD(aTB_Campos,{"WKSEGUM"  ,,AVSX3("W3_SEGUM"  ,5)})
        AADD(aTB_Campos,{"WKFATOR"  ,,"Fator Conv 2UM",AVSX3("J5_COEF",6) })
     EndIf
     AADD(aTB_Campos,{"W7_PRECO"  ,,AVSX3("W7_PRECO"  ,5),AVSX3("W7_PRECO",6)})
     AADD(aTB_Campos,{"W6_FOB_TOT",,AVSX3("W9_FOB_TOT",5),AVSX3("W6_FOB_TOT",6)})
     AADD(aTB_Campos,{"W7_PESO"   ,,AVSX3("W7_PESO"   ,5),AVSX3("W7_PESO",6)})

     //FSM - 31/08/2011 - "Peso Bruto Unitário"
     If lPesoBruto
        aAdd(aTB_Campos,{"WKW7PESOBR"   ,,AVSX3("W7_PESO_BR"   ,5),AVSX3("W7_PESO_BR",6)})
     EndIf

     AADD(aTB_Campos,{"W7_NCM"    ,,AVSX3("W3_TEC"    ,5),AVSX3("W3_TEC",6)})
     AADD(aTB_Campos,{"W7_EX_NCM" ,,AVSX3("W3_EX_NCM" ,5),AVSX3("W3_EX_NCM",6)})
     AADD(aTB_Campos,{"W7_EX_NBM" ,,AVSX3("W3_EX_NBM" ,5),AVSX3("W3_EX_NBM",6)})
     AADD(aTB_Campos,{"W9_INVOICE",,AVSX3("W9_INVOICE",5)})

     If lIntDraw
        AADD(aTB_Campos,{"W5_AC",,AVSX3("W5_AC",5)}) //"Ato Concess."
     EndIf

     //AOM - 14/04/2011
     If lOperacaoEsp
       AADD(aTB_Campos,{"W8_CODOPE",,AVSX3("W8_CODOPE",5),AVSX3("W8_CODOPE",6)})
     EndIf

     IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ESTORNO_INDICE_COLUNAS"),)

     IF SW7->(DBSEEK(xFilial()+SW6->W6_HAWB))
        Processa({|| DI500GrvTRB(.T.) },STR0054)//"Pesquisa de Itens"
     ENDIF

     nORDER:=TRB->(INDEXORD())

     IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ESTORNO_DEPOIS_GRVTRB"),)

     TRB->(DBSETORDER(nORDER))

     MConta:=0
     aOk:={|| If(DI500Estorno(),FINALIZAR,)} //"Estornar"

     AADD(aBotoes1T,{"RESPONSA" ,{|| Processa({|| DI500MarcaAll('TRB',oMark:oBrowse)}) },STR0427/*,STR0532*/}) //"Marca/Desmarca Todos"  -  "Marc/Des"
     //*******  E S T O R N O  ******************************************
ENDCASE

IF Inclui .And. GetNewPar("MV_NRDI",.F.) // RA - 06/11/2003 - O.S. 1146/03
   M->W6_HAWB := "Automatico" // So inicializei para passar pela validacao da primeira tela , AWR  08/04/2003
ENDIF

nTaxaDolar := M->W6_TX_US_D//RMD - 23/12/14 - Guarda a taxa registrada antes da exibição da tela.

lSair:=.F.//AWR - 09/08/2010
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ANTES_TELA"),)
If lSair//AWR - 09/08/2010
   SW6->(MsUnlock())
   RETURN nOpc
EndIf

DO WHILE .T.
   nOpca:=0
   aGets:={}
   aTela:={}
   lTopo:=.F.
   oMainWnd:ReadClientCoords()//So precisa declarar uma fez para o Programa todo
    //TLM 21/02/2008 Criação da variavel cProc para personalização do Título da MSDIALOG
   DEFINE MSDIALOG oDlg TITLE cTitulo +" "+ cProcDI ;
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 ;
          TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd PIXEL

    nLinha :=(oDlg:nClientHeight-4)/2
    IF nOpc = VISUAL .OR. nOpc = ESTORNO
       nLinha :=MEIO_DIALOG-1
    ENDIF

    oEnCh1:=MsMget():New( cAlias,nReg,nOpc,,,,aCamposMostra,{15,1,nLinha,COLUNA_FINAL},aDarGets,3)

    IF AvFlags("EIC_EAI")  //Jacomo lisa - 15/07/2014 - Adicionada a validação quando for integrada do Logix, não permitir alterar certos campos quando possuir uma parcela de frete/seguro liquidada
       Private lCambFrete := CambioVal("A",M->W6_HAWB) //Adicionada a Validação se existe cambios liquidados de Frete
       Private lCambSegur := CambioVal("B",M->W6_HAWB)//Adicionada a Validação se existe cambios liquidados de Seguro

       aCposFrete := {"W6_FREMOED","W6_VLFRECC","W6_TX_FRET","W6_CONDP_F","W6_DIASP_F","W6_VENCFRE","W6_FORNECF","W6_LOJAF"}
       aCposSegur := {"W6_SEGMOED","W6_VL_USSE","W6_TX_SEG","W6_DIASP_S","W6_DIASP_S","W6_VENCSEG","W6_FORNECS","W6_LOJAS"}
       IF lCambFrete
          FOR n := 1 to LEN(aCposFrete)
             IF (nPosSW6 := ascan(oEnch1:AENTRYCTRLS, {|x| aCposFrete[n] $ x:CREADVAR}) ) > 0
                oEnCh1:AENTRYCTRLS[nPosSW6]:BWHEN := {|| .F.}
             ENDIF
          NEXT
       ENDIF
       IF lCambSegur
          FOR n := 1 to LEN(aCposSegur)
             IF (nPosSW6 := ascan(oEnch1:AENTRYCTRLS, {|x| aCposSegur[n] $ x:CREADVAR}) ) > 0
                oEnCh1:AENTRYCTRLS[nPosSW6]:BWHEN := {|| .F.}
             ENDIF
          NEXT
       ENDIF

    ENDIF


    aGetsW6 := aClone(aGets)
    IF MOpcao == FECHTO_NACIONALIZACAO .AND. nOpc = INCLUSAO
       M->W6_VM_OBS := cVM_OBS
       M->W6_VM_COMP:= cVM_COMP
    ENDIF

    IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"CRIA_VAR_MEM"),) // JBS - 28/11/2003

    IF nOpc = VISUAL .OR. nOpc = ESTORNO
       lTopo := .t.
       oMark:=MSSELECT():New("TRB",IF(nOpc=ESTORNO,"WK_OK",NIL),,aTB_Campos,lInverte,cMarca,{MEIO_DIALOG,1,(oDlg:nClientHeight-6)/2,COLUNA_FINAL})
//       oMark:bAval:= {|| TRB->WK_OK := If(Empty(TRB->WK_OK) .And. VldOpeDesemb("MARC_IT_EST"),cMarca,"") , oMark:oBrowse:Refresh() }
       oMark:bAval:={|| DI500MKEST() .And. VldOpeDesemb("MARC_IT_EST") }//AOM - 14/04/2011 - Operacoes Especiais
       oMark:oBrowse:bWhen:={||DBSELECTAREA("TRB"),.T.}
       oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
       //DFS - 31/01/13 - Inclusão de refresh na tela dos itens do embarque
       oMark:oBrowse:Refresh()
    ENDIF

	oEnch1:oBox:Align := if(lTopo,CONTROL_ALIGN_TOP,CONTROL_ALIGN_ALLCLIENT) //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oDlg:lMaximized:=.T.
   ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,if(nOpc == 3,{|| IF(Eval(bValid),IF(DI500Itens(),FINALIZAR,),)},aOk),;
                                                                                                               {|| IF(DI500Sair(nOpc), (nOpca:=0,oDlg:End()),)},,aBotoes1T),oDLGBACK := oDlg,oEnch1:oBox:Align := if(lTopo,CONTROL_ALIGN_TOP,CONTROL_ALIGN_ALLCLIENT),if(nOpc = VISUAL .OR. nOpc = ESTORNO,oMark:oBrowse:Refresh(),))
                      //LRL 25/03/04 - Alinhamento MDI //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   IF DI500Mov(nOpca)
      LOOP
   ENDIF
   IF nOpca = 1 .OR. nOpca = 0 /*.AND. DI500Sair(nOpc))*/
      //ASR 10/02/2006 - INICIO - O REGISTRO PERMANECIA TRAVADO SE A DI NAO FOR GRAVADA
      SW4->(DBSETORDER(1))
      aLockSW4 := SW4->(DBRLOCKLIST())
      FOR X := 1 TO LEN(aLockSW4)
         SW4->(DBGOTO(aLockSW4[X]))
         SW4->(MSUNLOCK())
      NEXT
      //FSM - 17/05/2012
      If nOpca == 0 .And. EasyGParam("MV_AVG0211",,.F.) .And. lContAdm
         DI500EstAdmEntre()
      EndIf
      //ASR 10/02/2006 - FIM
      EXIT
   ENDIF
ENDDO

IF SELECT('TRB') # 0
   TRB->(E_EraseArq(cNomArq))
ENDIF

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"FINAL_OPCAO"),)

DI500Fil(.T.)
If lIntDraw  .And.  MOpcao == FECHTO_DESEMBARACO  .And.  lMUserEDC
   oMUserEDC:Fim()  // PLB 01/12/06 - Solta registros presos e reinicializa objeto
EndIf
//AOM - 06/04/11
If lOperacaoEsp
   oOperacao:DeleteWork()
EndIf
dbSelectArea("SW6")
//RRC - 20/11/2013 - Integração SIGAEIC x SIGAESS relativo a despesas
If nOpca == 1 .And. nOpc != 2 /* RMD - 31/08/17 - Envia o estorno .And. nOpc != 5*/ .And. AvFlags("CONTROLE_SERVICOS_AQUISICAO") .And. EasyGParam("MV_ESS0022",,.T.) .And. SWD->(FieldPos("WD_MOEDA")) > 0 .And. SWD->(FieldPos("WD_VL_MOE")) > 0 .And. SWD->(FieldPos("WD_TX_MOE")) > 0
   DI500ESS(SW6->W6_HAWB,nOpc)
EndIf

if (nOpc == ALTERACAO .and. nOpca == 1) .and. (DU100VdAlt(aValidacao) .or. nRecEV1 > 0)
   DU100AtuEV(nRecEV1)
endif

SW6->(MSUNLOCK())
Return nOpc

/**
Function DI500Mov(nOp)
 */
Function DI500Mov(nOp)

LOCAL nRecno:=SW6->(RECNO()), i, d
Local lDuimp := .F.

IF LEN(aTabHouse) # 0
   DO CASE
   CASE nOp == 10
        SW6->(DBSEEK(xFilial("SW6")+aTabHouse[1]))

   CASE nOp == 20
        nPos := ASCAN(aTabHouse,SW6->W6_HAWB)
        IF nPos == 1
           Help("",1,"AVG0000263",,ALLTRIM(cChave),2,6)//(STR0210 + ALLTRIM(cChave) ,STR0057  ) //"Não há processos anteriores a este para o PO : "###"Informação"
        ELSE
           SW6->(DBSEEK(xFilial("SW6")+aTabHouse[nPos-1]))
        ENDIF

   CASE nOp == 30
        nPos := ASCAN(aTabHouse,SW6->W6_HAWB)
        IF nPos == LEN(aTabHouse)
           Help("", 1, "AVG0000262",,ALLTRIM(cChave),2,6)//"Não há processos posteriores a este para o PO : "
        ELSE
           SW6->(DBSEEK(xFilial("SW6")+aTabHouse[nPos+1]))
        ENDIF

   CASE nOp == 40
        SW6->(DBSEEK(xFilial("SW6")+aTabHouse[LEN(aTabHouse)]))

   OTHERWISE
        RETURN .F.
   ENDCASE

ELSE
   DO CASE
   CASE nOp == 10
        SW6->(DBSEEK(xFilial("SW6")))

   CASE nOp == 20
        SW6->(DBSKIP(-1))
        IF SW6->W6_FILIAL != xFilial("SW6") .Or. SW6->(Bof())
           SW6->(DBSEEK(xFilial("SW6")))
        ENDIF

   CASE nOp == 30
        SW6->(DBSKIP())
        IF SW6->W6_FILIAL != xFilial("SW6") .Or. SW6->(Eof())
           SW6->(AVSeekLast(xFilial("SW6"))) // POSICIONA A ULTIMA OCORRENCIA
        ENDIF

   CASE nOp == 40
        SW6->(AVSeekLast(xFilial("SW6"))) // POSICIONA A ULTIMA OCORRENCIA

   OTHERWISE
        RETURN .F.
   ENDCASE

ENDIF

IF nRecno == SW6->(RECNO())
   RETURN .T.
ENDIF

FOR i := 1 TO SW6->(FCount())
    M->&(SW6->(FIELDNAME(i))) := SW6->(FieldGet(i))
NEXT
IF lTemDSI
   lDISimples := (M->W6_DSI=="1")
ENDIF

If AVFLAGS("DUIMP") .And. M->W6_TIPOREG == '2' //DUIMP
   lDuimp := .T.
EndIf

IF lTemDI .AND. !lDISimples
   IF MOpcao = FECHTO_DESEMBARACO
      IF SW6->W6_TEM_DI = "2" .Or. lDuimp
         lTemAdicao := .F.
       ELSE
         lTemAdicao := temAdicao()//.T.
       ENDIF
   ENDIF
ENDIF

aBotoes1T:={}
AADD(aBotoes1T,{"BAIXATIT" /*"VERNOTA"*/   ,{|| DI500Invoices()},STR0425,Nil}) //"Invoices"
IF MOpcao # FECHTO_EMBARQUE
   IF lDISimples
      AADD(aBotoes1T,{"BUDGET"    ,{|| DI500Simples() },STR0156,Nil}) //STR0156  "Impostos"
   ELSEIF lTemAdicao  .And. !lDuimp
      AADD(aBotoes1T,{"BMPINCLUIR",{|| DI500Adicoes() },STR0426,Nil }) //"Adicoes"
   ENDIF
ENDIF
IF cPaisLoc=="BRA" .AND. !lTemAdicao .AND. !lDISimples .And. !lDuimp
   AADD(aBotoes1T,{"PRECO",{|| DI500RegPesq() },STR0589/*,STR0529*/}) //LRL 26/03/04 -   "Reg.Trib" //STR0589 "Regime de Tributacao"
ENDIF
IF(lTemLote, AADD(aBotoes1T,{"CONTAINR",{|| DI500Lotes() },STR0592}) ,)// AWR - Lote //STR0592 "Lotes"
AADD(aBotoes1T,{"SIMULACAO",{|| DI500Totais(oMark)  },STR0382}) //LGS 22/07/13  - Habilitado "Totais"
AADD(aBotoes1T,{"TOP"   ,{|| nOpca:=10,oDlg:End()},STR0511,Nil })//"Primeiro"
AADD(aBotoes1T,{"PREV"  ,{|| nOpca:=20,oDlg:End()},STR0512,Nil })//"Anterior"
AADD(aBotoes1T,{"NEXT"  ,{|| nOpca:=30,oDlg:End()},STR0513,Nil })//"Proximo"
AADD(aBotoes1T,{"BOTTOM",{|| nOpca:=40,oDlg:End()},STR0514,Nil })//"Ultimo"

FOR D := 1 TO LEN(aTabelas)
   cAliasZ:="Work_"+aTabelas[D,1]
  (cAliasZ)->(avzap())
NEXT

Processa({|| DI500GrvTRB(.F.) },STR0054) //"Pesquisa de Itens"

RETURN .T.

Function DI500Sair(nOpc)

Private lSair := .T. // SVG - 09/12/2010 - Compatibilização de versão de v811 para P10

IF nOpc = VISUAL .OR. nOpc = ESTORNO
   Return .T.
ENDIF

// SVG - 09/12/2010 - Compatibilização de versão de v811 para P10
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"DI500SAIR"),)
// SVG - 09/12/2010 - Compatibilização de versão de v811 para P10
If !lSair
   Return .F.
EndIf

Return MSGYesNo(STR0506,STR0141)//"Confirma Saida ?"

FUNCTION DI500Busca()

LOCAL cCombo, i
LOCAL aTabItens := {}
aTabIndex:={}
SIX->(DBSEEK("SW6"))
DO WHILE ! SIX->(EOF()) .AND. SIX->INDICE == "SW6"
   IF SIX->SHOWPESQ = 'N'
      SIX->(DBSKIP())
      LOOP
   ENDIF
   AADD(aTabIndex,{Capital(SIX->DESCRICAO),IF("DTOS" $ UPPER(SIX->CHAVE) .OR. "DTOC" $ UPPER(SIX->CHAVE),SIX->CHAVE,SPACE(100))})
   SIX->(DBSKIP())
ENDDO

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"BUSCA_1"),)

SIX->(DBSEEK("SW7"+"2"))
AADD(aTabIndex,{Capital(SIX->DESCRICAO),SPACE(100)})
FOR I := 1 TO LEN(aTabIndex)
    AADD(aTAbItens,aTabIndex[I,1])
NEXT
cCombo := aTabItens[1]
cChave := SPACE(90)
lPorPO := .F.

DO WHILE .T.
   nOpcao   := 0

   DEFINE MSDIALOG oDlg FROM 00,00 TO 100,490 PIXEL TITLE STR0029  OF oMainWnd//"Pesquisa"

    @05,05 COMBOBOX oCBX VAR cCombo ITEMS aTabItens SIZE 206,36 PIXEL OF oDlg

    @22,05 MSGET oBigGet VAR cChave SIZE 206,10 PIXEL

    DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlg ENABLE ACTION (nOpcao:=1, oDlg:End())
    DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlg ENABLE ACTION oDlg:End()

   ACTIVATE DIALOG oDlg CENTERED

   IF nOpcao == 1
      IF cCombo == aTabIndex[Len(aTabIndex),1]
         lPorPO := .T.
      ENDIF
      IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"BUSCA_2"),)
      IF !EMPTY(cChave)
         IF !DI500Pesq(cCombo,lPorPO,cChave)
            LOOP
         ENDIF
      ENDIF
   ENDIF

   EXIT

ENDDO

lPorPO:=.F.
aTabHouse:={}

RETURN .T.

FUNCTION DI500Pesq(cCombo,lPorPO,cChave)

LOCAL nOrd := SW6->(INDEXORD()),cFilSW7:=xFilial("SW7"),lRet:=.T.
LOCAL nOrdSW7 := SW7->(INDEXORD()), nRecSW7:= SW7->(RECNO())

IF lPorPO
   aTabHouse := {}
   SW7->(DBSETORDER(2))
   IF SW7->(DBSEEK(cFilSW7+RTrim(cChave)))
      cChave:=SW7->W7_PO_NUM
      DO WHILE !SW7->(EOF()) .AND. SW7->W7_FILIAL == cFilSW7 .AND.;
                                   SW7->W7_PO_NUM == cChave
         IF ASCAN(aTabHOUSE,SW7->W7_HAWB) == 0
            AADD(aTabHouse,SW7->W7_HAWB)
         ENDIF
         SW7->(DBSKIP())
      ENDDO
      IF LEN(aTabHouse) # 0
         aTabHouse := ASORT(aTabHouse)
         SW6->(DBSETORDER(1))
         SW6->(DBSEEK(xFilial("SW6")+aTabHouse[1]))
         SW7->(DBSETORDER(nOrdSW7))
         SW7->(DBGOTO(nRecSW7))
         DI500Manut("SW6",SW6->(RECNO()),2)
      ENDIF
   ELSE
      IF !EMPTY(cChave)
         HELP(" ",1,"PESQ01")
         lRet:=.F.
      ENDIF
      SW7->(DBSETORDER(nOrdSW7))
      SW7->(DBGOTO(nRecSW7))
   ENDIF
ELSE
   nPos := ASCAN(aTabIndex,{|var| var[1] ==  cCombo})
   IF nPos # 0
      IF !EMPTY(aTabIndex[nPos,2] )
         cChave:= ALLTRIM(ConvData(aTabIndex[nPos,2],cChave))
      Else
         cChave:= RTrim(cChave)
      ENDIF
      SW6->(DBSETORDER(nPos))
      IF !SW6->(DBSEEK(xFilial("SW6")+cChave)) .AND. !EMPTY(cChave)
         HELP(" ",1,"PESQ01")
         lRet:=.F.
      ENDIF
   ENDIF
ENDIF
//SW6->(DBSETORDER(nOrd))

RETURN lRet

Function DI500Comple()

Local lPVez := .T.//,cInvoiceNew,cProcEndNew,cNewImportEnd
Local P//do FOR

PRIVATE nAux
IF EMPTY(Alltrim(M->W6_VM_COMP))
   RETURN .F.
ENDIF

IF !Inclui .AND. lPrimeiraVez
   Processa({|| DI500Existe() },STR0054) //"Pesquisa de Itens"
ENDIF

PRIVATE cTexto, cInvoice, cHouse, cTermo, cImportador, nTam:=AVSX3("W6_VM_COMP",03)
PRIVATE cImportEnd, cProcurador, cProcEnd, cRefDes,cData , cMaster
//AWR - 23/08/04 - Troca do controle p/ quebrar por adicao ou regime
PRIVATE lExiW6_QBRPICO:=SW6->(FIELDPOS("W6_QBRPICO")) # 0
PRIVATE cQuebraPICO:=IF(lExiW6_QBRPICO,M->W6_QBRPICO,"1")//Quebra por Regime
// - BHF - 28/10/08 - Complemento Edição - Conatainer
Private cContainer := ""

SYT->(dbSetOrder(1))

cTexto   := Alltrim(M->W6_VM_COMP)
cInvoice := ""
Work_SW9->(DBGOTOP())
Do While !Work_SW9->(EOF())
   cInvoice += ALLTRIM(Work_SW9->W9_INVOICE) + ", "
   Work_SW9->(dbSkip())
EndDo

cInvoice:= Left(cInvoice , Len(cInvoice)-2)

cHouse := STR0516+ALLTRIM(M->W6_HOUSE)//"Conhecimento "

cMaster := AVSX3("W6_MAWB",5)+" "+ALLTRIM(M->W6_MAWB)

cTermo := If(M->W6_TIPODOC=="2" .And. !EMPTY(M->W6_IDEMANI),STR0517+M->W6_IDEMANI,"")//"Termo de Entrada "

SYT->(dbSeek(xFilial("SYT")+M->W6_IMPORT))

cImportador:= Alltrim(SYT->YT_NOME)
If SYT->(FieldPos("YT_COMPEND")) > 0   // TLM 09/06/2008 - Incluído o complemento do endereço, tabela SYT
   cImportEnd := Alltrim(SYT->YT_ENDE)+ If(!Empty(SYT->YT_COMPEND)," Compl. " + Alltrim(SYT->YT_COMPEND),"") +" nro. "+Alltrim(Str(SYT->YT_NR_END))+", "+Alltrim(SYT->YT_BAIRRO)+" - "+Alltrim(SYT->YT_CIDADE)+" - "+Alltrim(SYT->YT_PAIS)
Else
   cImportEnd := Alltrim(SYT->YT_ENDE)+ " nro. "+Alltrim(Str(SYT->YT_NR_END))+", "+Alltrim(SYT->YT_BAIRRO)+" - "+Alltrim(SYT->YT_CIDADE)+" - "+Alltrim(SYT->YT_PAIS)
EndIf

cProcurador:= Alltrim(SYT->YT_PROC1)
cProcEnd:= Alltrim(SYT->YT_END_PR1)
cRefDes := Alltrim(M->W6_REF_DES)
cData   := DtoC(dDataBase)

cPISCOFINS:=""
aTabPISCOF:={}
aTabAdCompl:={}
nVLRPIS:=nVLRCOF:= 0

IF lMV_PIS_EIC
   cBas:=AVSX3("W8_BASPIS",6)
   cPer:=AVSX3("W8_PERPIS",6)
   cVlr:=AVSX3("W8_VLRPIS",6)
   Work_EIJ->(DBSETORDER(1))
   Work_SW8->(DBGOTOP())
   DO WHILE !Work_SW8->(EOF())
      //AWR - 23/08/04 - Troca do controle p/ quebrar por adicao ou regime
      IF cQuebraPICO == "2" //Quebra por Regime
         IF (nPos:=ASCAN(aTabPISCOF, {|T| T[1]==Work_SW8->WKREGTRI .AND. T[2]==Work_SW8->WKPERPIS .AND. T[3]==Work_SW8->WKPERCOF .AND. T[4]==Work_SW8->WKVLUPIS .AND. T[5]==Work_SW8->WKVLUCOF} )) = 0
            AADD(aTabPISCOF, {Work_SW8->WKREGTRI,Work_SW8->WKPERPIS,Work_SW8->WKPERCOF,Work_SW8->WKVLUPIS,Work_SW8->WKVLUCOF,0,0,0,0,0,"","","","","",""} )
            nPos:=LEN(aTabPISCOF)
         ENDIF
      ELSE //Quebra por Adicao
         IF (nPos:=ASCAN(aTabPISCOF, {|T| T[11]==Work_SW8->WKADICAO .AND. T[2]==Work_SW8->WKPERPIS .AND. T[3]==Work_SW8->WKPERCOF .AND. T[4]==Work_SW8->WKVLUPIS .AND. T[5]==Work_SW8->WKVLUCOF} )) = 0
            AADD(aTabPISCOF, {Work_SW8->WKREGTRI,Work_SW8->WKPERPIS,Work_SW8->WKPERCOF,Work_SW8->WKVLUPIS,Work_SW8->WKVLUCOF,0,0,0,0,0,Work_SW8->WKADICAO} )
            nPos:=LEN(aTabPISCOF)
         ENDIF
      ENDIF

      IF(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"COMPLEMENTO_1"),)

      IF nPos # 0
         aTabPISCOF[nPos,06]+=Work_SW8->WKBASPIS
         aTabPISCOF[nPos,07]+=Work_SW8->WKBASCOF
         aTabPISCOF[nPos,08]+=Work_SW8->WKVLRPIS
         aTabPISCOF[nPos,09]+=Work_SW8->WKVLRCOF
         aTabPISCOF[nPos,10]+=Work_SW8->WKVLICMS

         IF cQuebraPICO == "2" //Quebra por Regime
            IF ASCAN(aTabAdCompl,Work_SW8->WKADICAO) == 0
               aTabPISCOF[nPos,11]+=Work_SW8->WKADICAO+","
               IF Work_EIJ->(DBSEEK(Work_SW8->WKADICAO))
                  aTabPISCOF[nPos,12]+=STR(Work_EIJ->EIJ_ALI_II,6,2)+","
                  aTabPISCOF[nPos,13]+=STR(Work_EIJ->EIJ_ALAIPI,6,2)+","
                  IF !EMPTY(Work_EIJ->EIJ_ALRIPI)
                     aTabPISCOF[nPos,14]+=STR(Work_EIJ->EIJ_ALRIPI,6,2)+","
                  ENDIF
//                  IF !EMPTY(Work_EIJ->EIJ_PRIPI)
//                     aTabPISCOF[nPos,15]+=STR(Work_EIJ->EIJ_PRIPI ,6,2)+","
//                  ENDIF
                  IF !EMPTY(Work_EIJ->EIJ_ALUIPI)
                     aTabPISCOF[nPos,16]+=STR(Work_EIJ->EIJ_ALUIPI,6,2)+","
                  ENDIF
               ENDIF
               AADD(aTabAdCompl,Work_SW8->WKADICAO)
            ENDIF
         ENDIF

         If(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"SOMATORIA_TROCA_TEXTO"),)

      ENDIF
      Work_SW8->(DBSKIP())
   ENDDO
   IF cQuebraPICO == "2" //Quebra por Regime
      ASORT( aTabPISCOF,,,{|x,y| x[1] < y[1]} )
   ELSE
      ASORT( aTabPISCOF,,,{|x,y| x[11] < y[11]} )
   ENDIF
   cRegTri:=""//Quebra por Regime
   cAdicao:=""//Quebra por Adicao
   FOR P := 1 TO LEN(aTabPISCOF)
       //EOS - 03/05/04 - Troca do controle de adicao para regime
       //AWR - 23/08/04 - Troca do controle p/ quebrar por adicao ou regime
       nAux:=P
       IF cQuebraPICO == "2" //Quebra por Regime
          lLoop:=.F.
          If(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"FOR_TROCA_TEXTO"),)
          IF lLoop
             LOOP
          ENDIF
          IF cRegTri # aTabPISCOF[P,1]
             SJP->(dbSetOrder(1))
             SJP->(DBSEEK(XFILIAL("SJP")+aTabPISCOF[P,1]))
             cPISCOFINS+="Regime: "+aTabPISCOF[P,1]+IF(!SJP->(EOF()),"-"+ALLTRIM(SJP->JP_DESC),"")+CHR(13)+CHR(10)
             cRegTri:=aTabPISCOF[P,1]
          ENDIF
       ELSE //Quebra por Adicao
          IF cAdicao # aTabPISCOF[P,11]
             SJP->(dbSetOrder(1))
             SJP->(DBSEEK(XFILIAL("SJP")+aTabPISCOF[P,1]))
             cPISCOFINS+="Adicao: "+aTabPISCOF[P,11]+", Regime: "+aTabPISCOF[P,1]+IF(!SJP->(EOF()),"-"+ALLTRIM(SJP->JP_DESC),"")+CHR(13)+CHR(10)
             cAdicao:=aTabPISCOF[P,11]
          ENDIF
       ENDIF

       IF(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"COMPLEMENTO_2"),)

       IF EMPTY(aTabPISCOF[P,04])
          cPISCOFINS+= STR0600+TRANS(aTabPISCOF[P,02],cPer)+" %"+CHR(13)+CHR(10)//STR0600 "Aliquota PIS......: "
          cPISCOFINS+= STR0601+TRANS(aTabPISCOF[P,03],cPer)+" %"+CHR(13)+CHR(10) //STR0601 "Aliquota COFINS...: "
          cPISCOFINS+= STR0602+TRANS(aTabPISCOF[P,06],cBas)+CHR(13)+CHR(10) //STR0602 "Base PIS..........: "
          cPISCOFINS+= STR0603+TRANS(aTabPISCOF[P,07],cBas)+CHR(13)+CHR(10) //STR0603 "Base COFINS.......: "
       ELSE
          cPISCOFINS+=STR0604+TRANS(aTabPISCOF[P,04],cBas)+CHR(13)+CHR(10) //STR0604 "Vlu p/ Quantidade.: "
          cPISCOFINS+=STR0604+TRANS(aTabPISCOF[P,05],cBas)+CHR(13)+CHR(10)//STR0604 "Vlu p/ Quantidade.: "
       ENDIF

       cPISCOFINS+=STR0605+TRANS(aTabPISCOF[P,08],cVlr)+CHR(13)+CHR(10) //STR0605 "Valor PIS.........: "
       cPISCOFINS+=STR0606+TRANS(aTabPISCOF[P,09],cVlr)+CHR(13)+CHR(10) //STR0606 "Valor COFINS......: "
       cPISCOFINS+=STR0607+TRANS(aTabPISCOF[P,10],cVlr)+CHR(13)+CHR(10) //STR0607 "Valor ICMS........: "
       IF cQuebraPICO == "2" //Quebra por Regime
          cPISCOFINS+=STR0608+LEFT(aTabPISCOF[P,11],LEN(aTabPISCOF[P,11])-1)+CHR(13)+CHR(10) //STR0608 "Adicoes...........: "
          cPISCOFINS+=STR0609+LEFT(aTabPISCOF[P,12],LEN(aTabPISCOF[P,12])-1)+CHR(13)+CHR(10)//STR0609 "Aliquota I.I. ....: "
          cPISCOFINS+=STR0610+LEFT(aTabPISCOF[P,13],LEN(aTabPISCOF[P,13])-1)+CHR(13)+CHR(10) //STR0610 "Aliquota I.P.I. ..: "
          IF !EMPTY(aTabPISCOF[P,14])
             cPISCOFINS+=STR0611+LEFT(aTabPISCOF[P,14],LEN(aTabPISCOF[P,14])-1)+CHR(13)+CHR(10) //STR0611 "Aliquota Red. IPI.: "
          ENDIF
          IF !EMPTY(aTabPISCOF[P,15])
             cPISCOFINS+=STR0612+LEFT(aTabPISCOF[P,15],LEN(aTabPISCOF[P,15])-1)+CHR(13)+CHR(10)//STR0612 "Per. Red. do IPI..: "
          ENDIF
          IF !EMPTY(aTabPISCOF[P,16])
             cPISCOFINS+=STR0613+LEFT(aTabPISCOF[P,16],LEN(aTabPISCOF[P,16])-1)+CHR(13)+CHR(10) //STR0613 "Vlr. Uni. Esp. IPI: "
          ENDIF
       ELSE //Quebra por Adicao
          IF Work_EIJ->(DBSEEK(aTabPISCOF[P,11]))
             cPISCOFINS+=STR0609+STR(Work_EIJ->EIJ_ALI_II,6,2)+CHR(13)+CHR(10) //STR0609 "Aliquota I.I. ....: "
             cPISCOFINS+=STR0610+STR(Work_EIJ->EIJ_ALAIPI,6,2)+CHR(13)+CHR(10) //STR0610 "Aliquota I.P.I. ..: "
             IF !EMPTY(Work_EIJ->EIJ_ALRIPI)
                cPISCOFINS+=STR0611+STR(Work_EIJ->EIJ_ALRIPI,6,2)+CHR(13)+CHR(10) //STR0611 "Aliquota Red. IPI.: "
             ENDIF
//             IF !EMPTY(Work_EIJ->EIJ_PRIPI)
//                cPISCOFINS+="Per. Red. do IPI..: "+STR(Work_EIJ->EIJ_PRIPI ,6,2)+CHR(13)+CHR(10)
//             ENDIF
             IF !EMPTY(Work_EIJ->EIJ_ALUIPI)
                cPISCOFINS+=STR0613+STR(Work_EIJ->EIJ_ALUIPI,6,2)+CHR(13)+CHR(10) //STR0613 "Vlr. Uni. Esp. IPI: "
             ENDIF
          ENDIF
       ENDIF
       IF(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"COMPLEMENTO_3"),)
       cPISCOFINS+=CHR(13)+CHR(10)
   NEXT

ENDIF

// BHF - 28/10/08 - Verificação e preenchimento dos containers
SJD->(DbSetOrder(1))
If SJD->(DbSeek(xFilial()+M->W6_HAWB))
   While SJD->(!Eof()) .And. M->W6_HAWB == SJD->JD_HAWB
      SX5->(DbSeek(xFilial()+"C3"+SJD->JD_TIPO_CT))
      cContainer += AllTrim(SX5->X5_DESCRI)+": "+AllTrim(SJD->JD_CONTAIN) + ", "
      SJD->(DbSkip())
   End Do
   cContainer:= Left(cContainer , Len(cContainer)-2)
EndIf

If(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"ANTES_TROCA_TEXTO"),)

IF(!EMPTY(cInvoice)   ,cTexto:=StrTran(cTexto , "#INVOICE"               ,STR0518+cInvoice),)// "Fatura: "
IF(!EMPTY(cImportador),cTexto:=StrTran(cTexto , "#IMPORTADOR"            ,cImportador),)
IF(!EMPTY(cImportEnd) ,cTexto:=StrTran(cTexto , "#IMPORTENDE"            ,cImportEnd),)
IF(!EMPTY(M->W6_HOUSE),cTexto:=StrTran(cTexto , "#HOUSE"                 ,cHouse),)
IF(!EMPTY(M->W6_MAWB) ,cTexto:=StrTran(cTexto , "#MASTER"                ,cMaster),)
IF(!EMPTY(cProcurador),cTexto:=StrTran(cTexto , "#PROCURADOR"            ,cProcurador),)
IF(!EMPTY(cProcEnd)   ,cTexto:=StrTran(cTexto , "#ENDERECO_DO_PROCURADOR",cProcEnd),)
IF(!EMPTY(cRefDes)    ,cTexto:=StrTran(cTexto , "#REFERENCIA_DESPACHANTE",cRefDes),)
//BHF - 28/10/08 - Container
If(!Empty(cContainer) ,cTexto:=StrTran(cTexto , "#CONTAINER"             ,cContainer),)
cTexto := StrTran(cTexto,"#TERMOENTRADA",cTermo)
cTexto := StrTran(cTexto,"#DATA"        ,cData)
cTexto := StrTran(cTexto,"#PIS_COFINS"  ,cPISCOFINS)

If(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"DEPOIS_TROCA_TEXTO"),)

M->W6_VM_COMP := cTexto
lGravaSoCapa:=.F.

Return .T.

Function DI500Edit_Comple() // FUNCAO CHAMADA DO DICIONARIO SX7 CAMPO W6_MSG_COM. // LDR 09/10/04

LOCAL cVM_COMP:=""

cVM_COMP:=MSMM(SY7->Y7_TEXTO)
//cVM_COMP:=STRTRAN(cVM_COMP,CHR(13)+CHR(10),"")

IF !EMPTY(M->W6_VM_COMP)
   cVM_COMP:=M->W6_VM_COMP+CHR(13)+CHR(10)+cVM_COMP
ENDIF

RETURN cVM_COMP

Function DI500Itens(lAuto)//Antiga DI_SelItem() - Parte do Browse

LOCAL aBotoes:={},oDlgItens//,nOpcaoItem
Local oPanItem //LRL 26/03/04
Local lDuimp 
Default lAuto := .F.
Private aDesmarc:={} //AAF 13/05/05 - Usada para Itens apropriados em Drawback.
PRIVATE cTitItens := STR0431	//JWJ 24/06/05 - P/ poder modificar o titulo da janela em RDMAKES
Private nOpcaoItem // DFS - Tratamento em RdMake (variável oMark deve ser feito tratamento específico) ***

IF !Inclui .AND. lPrimeiraVez
   Processa({|| DI500Existe() },STR0054) //"Pesquisa de Itens"
ENDIF

IF Inclui .AND. lPrimeiraVez
   IF !DI500Selecao()
      RETURN .F.
   ENDIF
ENDIF

aCamposItem:={}
AADD(aCamposItem,{"WKFLAGWIN"  ,,""})
IF MOpcao==FECHTO_NACIONALIZACAO
   AADD(aCamposItem,{{||TRANS(Work->WKPO_NUM,AVSX3("W2_PO_NUM",6))+"  "},,STR0079})//"Nacionalizacao"
ELSE
   AADD(aCamposItem,{"WKPO_NUM",,AVSX3("W2_PO_NUM",5),AVSX3("W2_PO_NUM",6)})
ENDIF
IF cPaisLoc=="BRA"
   AADD(aCamposItem,{"WKPGI_NUM"  ,,AVSX3("W5_PGI_NUM",5),AVSX3("W5_PGI_NUM",6)})
   AADD(aCamposItem,{"WKSEQ_LI"   ,,AVSX3("W7_SEQ_LI" ,5)})
   AADD(aCamposItem,{"WKREGIST"   ,,AVSX3("WP_REGIST" ,5),AVSX3("WP_REGIST" ,6)})
   AADD(aCamposItem,{"WKREG_VEN"  ,,AVSX3("WP_VENCTO" ,5)})
ENDIF
AADD(aCamposItem,{"WKPOSICAO"  ,,AVSX3("W7_POSICAO",5)})
AADD(aCamposItem,{"WKCOD_I"    ,,AVSX3("W7_COD_I"  ,5),AVSX3("W7_COD_I",6)})

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"AADD_BROWSE_ITEM"),)  // RS - 10/11/05

If lIntDraw .and. lMensDrawback .and. Empty(M->W6_DTREG_D)  //GFC 18/08/04
   AADD(aCamposItem,{{|| MensDrawback(.T.,Work->WKCOD_I,Work->WKFORN,Work->WKINVOICE,Work->WKPO_NUM,Work->WKPOSICAO,Work->WKPGI_NUM,Work->WKAC,Work->WKTEC)},,"Drawback"})
EndIf
AADD(aCamposItem,{"WKPART_N"   ,,AVSX3("A5_CODPRF" ,5)})
AADD(aCamposItem,{"WKDESCR"    ,,AVSX3("B1_DESC_GI",5)})
AADD(aCamposItem,{{||Work->WKFABR+' '+Work->WKNOME_FAB},,AVSX3("W7_FABR",5)})
If EICLoja()
   AADD(aCamposItem,{{|| Work->W7_FABLOJ},,AVSX3("W7_FABLOJ",5)})
EndIf
AADD(aCamposItem,{{||Work->WKFORN+' '+Work->WKNOME_FOR},,AVSX3("W7_FORN",5)})
If EICLoja()
   AADD(aCamposItem,{{|| Work->W7_FORLOJ},,AVSX3("W7_FORLOJ",5)})
EndIf
AADD(aCamposItem,{'WKMOEDA'    ,,AVSX3("W2_MOEDA",5)})
AADD(aCamposItem,{'WKPRECO'    ,,AVSX3("W7_PRECO",5),_PictPrUn})
AADD(aCamposItem,{"WKDISPINV"  ,,STR0428,_PictQtde}) //"Disp p/ Inv."
AADD(aCamposItem,{"WKQTDE_D"   ,,AVSX3("W7_QTDE",5)+" "+IF(MOpcao=FECHTO_EMBARQUE,STR0085,STR0086),_PictQtde}) //###"Embarque"###"Desemb"
IF AvFlags("EIC_EAI")   //SSS - REQ. 6.2 - 27/06/2014 - Unidade de Medida do Fornecedor no processo de importação
   AADD(aCamposItem,{"WKUNI"    ,,AVSX3("W3_UM"     ,5)})
   AADD(aCamposItem,{"WKQTSEGUM",,AVSX3("W3_QTSEGUM",5),AVSX3("W3_QTSEGUM" ,6)})
   AADD(aCamposItem,{"WKSEGUM"  ,,AVSX3("W3_SEGUM"  ,5)})
   AADD(aCamposItem,{"WKFATOR"  ,,"Fator Conv 2UM",AVSX3("J5_COEF",6) })
ENDIF
AADD(aCamposItem,{"WKSALDO_Q"  ,,AVSX3("W7_SALDO_Q",5),_PictQtde})
AADD(aCamposItem,{"WKPESO_L"   ,,AVSX3("W7_PESO",5)  ,AVSX3("W7_PESO",6)})
//FSM - 31/08/2011 - "Peso Bruto Unitário"
If lPesoBruto
   AADD(aCamposItem,{"WKW7PESOBR" ,,AVSX3("W7_PESO_BR",5),AVSX3("W7_PESO_BR",6)})
EndIf
AADD(aCamposItem,{"WKTEC"      ,,AVSX3("W3_TEC",5)   ,AVSX3("W3_TEC",6)})
AADD(aCamposItem,{"WKEX_NCM"   ,,AVSX3("W3_EX_NCM",5),AVSX3("W3_EX_NCM",6)})
AADD(aCamposItem,{"WKEX_NBM"   ,,AVSX3("W3_EX_NBM",5),AVSX3("W3_EX_NBM",6)})
AADD(aCamposItem,{"WKOPERACA"  ,,"Operacao"})
IF lMV_PIS_EIC .AND. !lAUTPCDI
   AADD(aCamposItem,{"WKPERPIS",,AVSX3("W8_PERPIS",5),AVSX3("W8_PERPIS",6)})
   AADD(aCamposItem,{"WKPERCOF",,AVSX3("W8_PERCOF",5),AVSX3("W8_PERCOF",6)})
   AADD(aCamposItem,{"WKVLUPIS",,AVSX3("W8_VLUPIS",5),AVSX3("W8_VLUPIS",6)})
   AADD(aCamposItem,{"WKVLUCOF",,AVSX3("W8_VLUCOF",5),AVSX3("W8_VLUCOF",6)})
ENDIF

//AOM - 11/04/2011
If lOperacaoEsp
  AADD(aCamposItem,{"W7_CODOPE",,AVSX3("W8_CODOPE",5),AVSX3("W8_CODOPE",6)})
  AADD(aCamposItem,{"W7_DESOPE",,AVSX3("W8_DESOPE",5),AVSX3("W8_DESOPE",6)})
EndIf

AADD(aBotoes,{"BAIXATIT" /*"VERNOTA"*/   ,{|| DI500Invoices(oMark:oBrowse)  },STR0425}) //"Invoices"
lDuimp := AvFlags("DUIMP") .AND. M->W6_TIPOREG == "2"
IF MOpcao # FECHTO_EMBARQUE
   IF lDISimples
      AADD(aBotoes,{"BUDGET"    ,{|| DI500Simples(oMark:oBrowse)},STR0156}) //STR0156  "Impostos"
   ELSEIF lTemAdicao  .And. !lDuimp
      AADD(aBotoes,{"BMPINCLUIR",{|| DI500Adicoes(oMark:oBrowse)},STR0426}) //"Adicoes"
   ENDIF
ENDIF
IF cPaisLoc=="BRA" .AND. !lDISimples .And. !lDuimp
   AADD(aBotoes,{"PRECO",{|| DI500RegPesq() },STR0589,STR0529}) //LRL 25/03/04 -  "Reg.Trib" //STR0589 "Regime de Tributacao"
ENDIF

IF FindFunction("EICAdicao").AND. lExisteSEQ_ADI .AND. !lTemAdicao .AND. !lDISimples .And. !lDuimp//AWR - 18/09/2008 - NFE
   AADD(aBotoes,{"BMPINCLUIR",{|| EICAdicao(.F.,4,.T.)},STR0426}) //STR0426 := "Adicoes"
ENDIF

IF(lTemLote, AADD(aBotoes,{"CONTAINR",{|| DI500Lotes() },STR0592}) ,)// AWR - Lote //STR0592 "Lotes"
IF(lTemNVE , AADD(aBotoes,{"PRODUTO" ,{|| (DI500NVE(nOPC_mBrw),Work->(DBGOTOP()),oMark:oBrowse:Refresh())   },"N.V.E."}),)// AWR - NVE - 18/10/2004
AADD(aBotoes,{"SIMULACAO" ,{|| DI500Totais(oMark)      },STR0382}) //"Totais"

IF !ValidCambio(.F.)//!lTemCambio
   AADD(aBotoes,{"RESPONSA"  ,{|| Processa({|| DI500MarcaAll('Work',oMark:oBrowse)})},STR0427/*,STR0532*/}) //"Marca/Desmarca Todos" -  "Marc/Des"
ENDIF
//AAF 13/05/05 - Adicinada Validação para Itens apropriados a Drawback.
AADD(aBotoes,{"PREV"      ,{|| nOpcaoItem:=0,If( VerItemAto(),oDlgItens:End(),)},STR0429/*,STR0512*/}) //"Tela Anterior" -   "Proximo"
AADD(aBotoes,{"NEXT"      ,{|| nOpcaoItem:=1,If( VerItemAto(),oDlgItens:End(),)},STR0430/*,STR0513*/}) //"Proxima Tela"  -   "Anterior"
aBotaoItem:=aBotoes//Para colocar novos botoes via rdmake
nOrder:=3
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"BROWSE_SELECIONA"),)
aBotoes:=aBotaoItem
Private cDigCod_I := CriaVar("W7_COD_I")
Private nDigQtde  := CriaVar("W7_QTDE")

DO WHILE .T.
   DBSELECTAREA("Work")
   SET FILTER TO
   Work->(dbsetorder(norder))
   Work->(DBGOTOP())
   nOpcaoItem:=0
   lMostMsgNVE := .T.
    If lAuto // EJA - 25/09/2018 - Se for rotina automática, não abrir msdialog, executar direto a rotina de itens
        Return DI500Conferencia(.T.)
    Else
        DEFINE MSDIALOG oDlgItens TITLE cTitItens ; //"Selecao de Itens"
          FROM oMainWnd:nTop+125,oMainWnd:nLeft +05 ;
          TO oMainWnd:nBottom-60,oMainWnd:nRight-10 OF oMainWnd PIXEL
      @00,00  MSPANEL oPanItem Prompt "" Size 60,37 of oDlgItens
      @8,005 SAY AVSX3("W6_HAWB",5)  of oPanItem PIXEL //'Nr. Processo:'
      @8,136 SAY AVSX3("W6_DT_HAWB",5) of oPanItem PIXEL //'Data:'
      @5.5,040 MSGET M->W6_HAWB     PICT "@!" SIZE 60,8 WHEN .F. of oPanItem PIXEL
      @5.5,170 MSGET M->W6_DT_HAWB  PICT "@D" SIZE 40,8 WHEN .F. of oPanItem PIXEL
      @22,005 SAY AVSX3("W6_HOUSE",5)  of oPanItem  PIXEL //'House / B.L.:'
      @20.5,40  MSGET M->W6_HOUSE              SIZE 60,8 WHEN .F. of oPanItem PIXEL

      @5.5,COLUNA_FINAL_I-85 BUTTON oBtnPOPLI PROMPT STR0432 SIZE 55,13 ; //"Selecao PO's / PLI's"
                          ACTION (DI500Selecao(oMark:oBrowse)) OF oPanItem PIXEL //WHEN !lTemCambio SVG - 01/09/2011 -
      oBtnPOPLI:cToolTip:=STR0433 //"Selecao de Pedidos e P.L.I.'s"

      @19.5,COLUNA_FINAL_I-85 BUTTON oBtnSel   PROMPT STR0434 SIZE 55,13 ; //"Selecao Itens Digit."
                          ACTION (DI500DigItem(oMark:oBrowse)) OF oPanItem PIXEL //WHEN !lTemCambio SVG - 01/09/2011 -
      oBtnSel:cToolTip := STR0096 //"Seleção de Itens por Digitação"

      oMark:=MsSelect():New("Work","WKFLAGWIN",,aCamposItem,lInverte,cMarca,{50,1,(oDlgItens:nClientHeight-6)/2,COLUNA_FINAL_I})
      oMark:bAval:={|x| x:= GetFocus(), DI500MarkItem() , SetFocus(x) }
      oMark:oBrowse:bWhen:={||DBSELECTAREA("Work"),.T.}
      oDlgItens:lMaximized:=.T. //LRL 26/03/04 - Maximilização da janela

      IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ENCHOICE_ITENS"),)//ASR 03/11/2005 - INCLUIR GET'S NA ENCHOICE DA SELEÇÃO DE ITENS

	  oPanItem:Align:=CONTROL_ALIGN_TOP //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
      oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT  //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

        ACTIVATE MSDIALOG oDlgItens ON INIT (EnchoiceBar(oDlgItens,{|| nOpcaoItem:=1,If( VerItemAto(),oDlgItens:End(),)},{|| nOpcaoItem:=0,If( VerItemAto(),oDlgItens:End(),)},.F.,aBotoes),oMark:oBrowse:Refresh())//Alinhamento MDI //LRL 26/03/04 //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

        IF nOpcaoItem = 1
            IF !DI500Conferencia()
                LOOP
            ENDIF
            RETURN .T.
        ENDIF
    EndIf
   EXIT
ENDDO
RETURN .F.

FUNCTION DI500Conferencia(lAuto)//Antiga D_Tela4()

LOCAL cTitulo:=STR0111+IF(!_Declaracao,IF(MOpcao=FECHTO_EMBARQUE,STR0085,STR0113),STR0114) //'Grava '###'Embarque'###'D.I.'###'D.A.'
LOCAL oDlg, oMark, nGravou:=0,aOk
LOCAL lPergunte := .T. //MCF - 28/12/2015
Local lDuimp
Default lAuto := .F.
PRIVATE aBotoesConf:={}

PRIVATE oGetInland, oGetPacking, oGetFrete, oGetDesconto, oTotalFob, nTotalFob:=0
PRIVATE MDesconto := MInland := MFrt_Int := MPacking := 0
PRIVATE cTitFinal	:= STR0119 	//JWJ 24/06/05 - P/ poder modificar o titulo da janela em RDMAKES
Private lBtRatFrete := .F. //Indica se já foi clicado no botão de Rateio de Frete

DI500Fil(.F.)

aCamposConf:={}
IF MOpcao==FECHTO_NACIONALIZACAO
   AADD(aCamposConf,{{||TRANS(Work->WKPO_NUM,AVSX3("W2_PO_NUM",6))+"  "},,STR0079})//"Nacionalizacao"
ELSE
   AADD(aCamposConf,{"WKPO_NUM",,AVSX3("W2_PO_NUM",5),AVSX3("W2_PO_NUM",6)})
ENDIF
IF cPaisLoc=="BRA"
   AADD(aCamposConf,{"WKPGI_NUM" ,, AVSX3("W7_PGI_NUM",5),AVSX3("W7_PGI_NUM",6)})
   AADD(aCamposConf,{"WKSEQ_LI"  ,, AVSX3("W7_SEQ_LI" ,5) })
   AADD(aCamposConf,{"WKREGIST"  ,, AVSX3("WP_REGIST" ,5),AVSX3("WP_REGIST" ,6)})
   AADD(aCamposConf,{'WKREG_VEN' ,, AVSX3("WP_VENCTO" ,5)})
ENDIF
AADD(aCamposConf,{"WKPOSICAO" ,, AVSX3("W7_POSICAO",5)})
AADD(aCamposConf,{"WKCOD_I"   ,, AVSX3("W7_COD_I",5),AVSX3("B1_COD",6)})

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ADD_BROWSE_CONF"),) // Inclusao no Browse Campo ADM. TEMP - RS 10/11/05

AADD(aCamposConf,{"WKPART_N"  ,, AVSX3("A5_CODPRF",5)})
AADD(aCamposConf,{{||Work->WKFABR+' '+Work->WKNOME_FAB},, AVSX3("W7_FABR",5)})
If EICLoja()
   AADD(aCamposConf,{{|| Work->W7_FABLOJ},,AVSX3("W7_FABLOJ",5)})
EndIf
AADD(aCamposConf,{{||Work->WKFORN+' '+Work->WKNOME_FOR},,AVSX3("W7_FORN",5)})
If EICLoja()
   AADD(aCamposConf,{{|| Work->W7_FORLOJ},,AVSX3("W7_FORLOJ",5)})
EndIf
AADD(aCamposConf,{"WKDISPINV" ,,STR0428,_PictQtde}) //"Disp p/ Inv."
AADD(aCamposConf,{"WKQTDE"    ,,AVSX3("W7_QTDE",5),_PictQtde})
IF AvFlags("EIC_EAI")  //SSS - REQ. 6.2 - 27/06/2014 - Unidade de Medida do Fornecedor no processo de importação
   AADD(aCamposConf,{"WKUNI"    ,,AVSX3("W3_UM"     ,5)})
   AADD(aCamposConf,{"WKQTSEGUM",,AVSX3("W3_QTSEGUM",5),AVSX3("W3_QTSEGUM" ,6)})
   AADD(aCamposConf,{"WKSEGUM"  ,,AVSX3("W3_SEGUM"  ,5)})
ENDIF
AADD(aCamposConf,{'WKMOEDA'   ,,AVSX3("W2_MOEDA",5)})
AADD(aCamposConf,{'WKPRECO'   ,,AVSX3("W7_PRECO",5),_PictPrUn})
IF MOpcao = FECHTO_EMBARQUE
   AADD(aCamposConf,{"WKDT_ENTR",,AVSX3("W3_DT_ENTR",5)})
   AADD(aCamposConf,{"WKDT_EMB" ,,AVSX3("W3_DT_EMB" ,5)})
ENDIF
AADD(aCamposConf,{"WKPESO_L"  ,,AVSX3("W7_PESO",5)  ,AVSX3("W7_PESO",6)})

//FSM - 31/08/2011 - "Peso Bruto Unitário"
If lPesoBruto
   AADD(aCamposConf,{"WKW7PESOBR",,AVSX3("W7_PESO_BR",5),AVSX3("W7_PESO_BR",6)})
EndIf

AADD(aCamposConf,{"WKTEC"     ,,AVSX3("W3_TEC",5)   ,AVSX3("W3_TEC",6)})
AADD(aCamposConf,{"WKEX_NCM"  ,,AVSX3("W3_EX_NCM",5),AVSX3("W3_EX_NCM",6)})
AADD(aCamposConf,{"WKEX_NBM"  ,,AVSX3("W3_EX_NBM",5),AVSX3("W3_EX_NBM",6)})
AADD(aCamposConf,{"WKCC"      ,,AVSX3("W0__CC"   ,5),AVSX3("W0__CC",6)})
AADD(aCamposConf,{"WKSI_NUM"  ,,AVSX3("W0__NUM"  ,5),AVSX3("W0__NUM",6)})
IF lAUTPCDI
   AADD(aCamposConf,{"WKREG_PC",,AVSX3("W8_REG_PC",5),AVSX3("W8_REG_PC",6)})
   AADD(aCamposConf,{"WKFUN_PC",,AVSX3("W8_FUN_PC",5),AVSX3("W8_FUN_PC",6)})
   AADD(aCamposConf,{"WKFRB_PC",,AVSX3("W8_FRB_PC",5),AVSX3("W8_FRB_PC",6)})
ELSEIF lMV_PIS_EIC
   AADD(aCamposConf,{"WKPERPIS",,AVSX3("W8_PERPIS",5),AVSX3("W8_PERPIS",6)})
   AADD(aCamposConf,{"WKPERCOF",,AVSX3("W8_PERCOF",5),AVSX3("W8_PERCOF",6)})
   AADD(aCamposConf,{"WKVLUPIS",,AVSX3("W8_VLUPIS",5),AVSX3("W8_VLUPIS",6)})
   AADD(aCamposConf,{"WKVLUCOF",,AVSX3("W8_VLUCOF",5),AVSX3("W8_VLUCOF",6)})
ENDIF

AADD(aCamposConf,{"WKOPERACA" ,,"Operacao"})

AADD(aBotoesConf,{"BAIXATIT" /*"VERNOTA"*/      ,{|| DI500Invoices(oMark:oBrowse)},STR0425}) //"Invoices"
lDuimp := AvFlags("DUIMP") .AND. M->W6_TIPOREG == "2"
IF MOpcao # FECHTO_EMBARQUE
   IF lDISimples
      AADD(aBotoesConf,{"BUDGET"    ,{|| DI500Simples(oMark:oBrowse)},STR0156,Nil}) //STR0156  "Impostos"
   ELSEIF lTemAdicao  .And. !lDuimp
      AADD(aBotoesConf,{"BMPINCLUIR",{|| DI500Adicoes(oMark:oBrowse)},STR0426   }) //"Adicoes"
   ENDIF
ENDIF
IF cPaisLoc=="BRA" .AND. !lDISimples .And. !lDuimp
   AADD(aBotoesConf,{"PRECO"  ,{|| DI500RegPesq() },STR0589,STR0529}) //LRL 25/03/04 -  "Reg.Trib" //STR0589 "Regime de Tributacao"
ENDIF
IF(lTemLote, AADD(aBotoesConf,{"CONTAINR",{|| DI500Lotes() },STR0592}) ,)// AWR - Lote //STR0592 "Lotes"
IF(lTemNVE , AADD(aBotoesConf,{"PRODUTO" ,{|| (DI500NVE(nOPC_mBrw),Work->(DBGOTOP()),oMark:oBrowse:Refresh())   },"N.V.E."}),)// AWR - NVE - 18/10/2004
AADD(aBotoesConf,{"SIMULACAO" ,{|| DI500Totais(oMark)   },STR0382}) //"Totais"
AADD(aBotoesConf,{"PREV"      ,{|| nGravou:=0,oDlg:End()},STR0429/*,STR0512*/}) //"Tela Anterior" -  "Anterior"

IF EasyGParam("MV_FRE_DIN",,.T.) .AND. MOpcao = FECHTO_NACIONALIZACAO
   AADD(aBotoesConf,{"FORM" ,{|| DI500RatFrete(),lBtRatFrete := .T. },STR0614}) //STR0614 "Rateia Frete/Seguro"
ENDIF
// SVG - 08/04/09 -
IF FindFunction("EICAdicao").AND. lExisteSEQ_ADI .AND. !lTemAdicao .AND. !lDISimples .And. !lDuimp//AWR - 18/09/2008 - NFE
   AADD(aBotoes1T,{"BMPINCLUIR",{|| EICAdicao(.F.,4,.T.)},STR0426}) //STR0426 "Adicoes"
ENDIF

aOk:={|| IF(DI_Valid("W6_DI_NUM",,.T.) .AND. DI500_Grava() ,(nGravou:=1,If(!lAuto, oDlg:End(),)),)}

nOrderConf:=3

IF lFinanceiro //.AND. SX1->(DBSEEK("EICFI5"))
   SetKey(VK_F11,{|| lPergunte := Pergunte("EICFI5",.T.) }) //MCF - 28/12/2015
ENDIF
IF lFinanceiro //.AND. SX1->(DBSEEK("EICFI4"))
   SetKey(VK_F12,{|| Pergunte("EICFI4",.T.) })
ENDIF

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"BROWSE_CONFERENCIA"),)

DBSELECTAREA("Work")
SET FILTER TO WKFLAG == .T.

DO WHILE .T.
   nGravou:=0
   Work->(dbsetorder(nOrderConf))
   Work->(DBGOTOP())
    If lAuto
        Eval(aOk)
    Else
   DEFINE MSDIALOG oDlg TITLE cTitFinal; //"Conferencia Final"
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5;
          TO   oMainWnd:nBottom-60,oMainWnd:nRight-10 OF oMainWnd PIXEL

     oMark:=MsSelect():New("Work",,,aCamposConf,lInverte,cMarca,{18,1,(oDlg:nClientHeight-6)/2,COLUNA_FINAL})
     oMark:oBrowse:bWhen:={||DBSELECTAREA("Work"),.T.}
     oDlg:lMaximized:=.T. //LRL 26/03/04 - Maximiliza Janela
     oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	 oMark:oBrowse:Refresh()


        //DFS - 31/01/13 - Inclusão de refresh na tela.
        ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,aOk,{|| nGravou:=0,oDlg:End()},,aBotoesConf), oMark:oBrowse:Refresh()) //LRL 26/03/04 - Alinhamento MDI //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
    EndIf

   DBSELECTAREA("Work")
   SET FILTER TO

   IF nGravou = 1
      If lInvAnt   //GFP 28/10/2010 ** Inserção automatica do Processo de Inv. Antecipada caso Embarque tenha sido realizado.
         EW4->(DbSetOrder(1))
         Work_SW9->(dbGoTop())
         While !Work_SW9->(Eof())  
            If EW4->(DbSeek(xFilial("EW4")+Work_SW9->(W9_INVOICE + W9_FORN + W9_FORLOJ))) .AND. Empty(EW4->EW4_HAWB) //AAF 27/12/2019 - Associar apenas se nao tiver embarque na invoice antecipada.
                RecLock("EW4", .F.)
                EW4->EW4_HAWB := M->W6_HAWB
                EW4->(MsUnLock())
            Endif
            Work_SW9->(dbSkip())
         EndDo
      Endif
      RETURN .T.
   ENDIF
   EXIT
ENDDO

RETURN .F.

FUNCTION DI500_Grava()//Antiga DbuDi400B()

LOCAL lOK:=.T.,lItemOK:=.F.,nOrdSW9:=SW9->(INDEXORD())
LOCAL nWk   // ACSJ - 15/07/2004 - é obrigatório declarar a variavei de contagem do comando For/Next como local.
Local lTemFrete   := .F. //Indica se a DA tem frete preenchido
Local nRecNo := 0
Local nxInd //DRL - 16/09/09 - Invoices Antecipadas
Local cInvOK,i,CPOS:=""
Local cTipParc := ""
Local lGvInvParcial := EasyGParam("MV_EIC0057",,.F.) //LGS-14/05/2015
//MFR TE-7011 WCC-534964 MTRADE-1554 28/09/2017
Local lCancela := .F.
Local nQtde := 0
Local nCtrItem := 0
Local nRecCount := 0
Local lTemInvoice := .F.
Local lSemInvoice := .F. //TE-9580

PRIVATE aSWBUserCps := {}  // GFP - 07/11/2013
PRIVATE lRateiaIntFreigh := .F. //LGS-12/11/2013

//RRV - 22/02/2013 - Tratamento de títulos provisórios de numerário.
//If EasyGParam("MV_EIC0023",,.F.)
//   Private cControle := "Desemb"
//EndIf

DBSELECTAREA("Work")
SET FILTER TO WKFLAG == .T.

Work->(DBGOTOP())
Work->(DBEVAL({||lItemOK:=.T.},{|| WKFLAG },{|| !lItemOK  } ))
Work->(DBGOTOP())

IF !lItemOK // .AND. !Inclui
   Help("",1,"AVG0000701")//"Nao existem itens Selecionados."
   RETURN .F.
ENDIF

//** AAF 17/06/2010 - Verifica se existem invoices sem itens
cInvOK:=""
Work_SW8->(dbSetOrder(1))
Work_SW9->(DBGOTOP())
Work_SW9->(DBEVAL({||cInvOK:=Work_SW9->W9_INVOICE},{|| !Work_SW8->(dbSeek(Work_SW9->(W9_INVOICE+W9_FORN))) },{|| Empty(cInvOK) } ))
Work_SW9->(DBGOTOP())

If !Empty(cInvOK)
   MsgStop(STR0615+cInvOK+STR0616)//STR0615 "A invoice " //STR0616 " está sem itens selecionados"
   Return .F.
EndIf
/*
IF MOpcao = FECHTO_EMBARQUE
   //Verifica se foi feita alguma invoice no Embarque
   Work->(DBEVAL({||lOK:=.F.},{|| Work->WKDISPINV # Work->WKQTDE .AND. Work->WKFLAG },{|| lOK } ))
   Work->(DBGOTOP())
ENDIF
*/
//lTemInvoice:= .T.
//IF MOpcao <> FECHTO_EMBARQUE
   //Verifica se algum item TEM invoice
   lTemInvoice:= .F.
   Work->(DBEVAL({||lTemInvoice:= .T.},{|| Work->WKDISPINV # Work->WKQTDE .AND. Work->WKFLAG },{|| !lTemInvoice } ))
   Work->(DBGOTOP())
//ENDIF
   //Verifica se algum item NAO tem Invoice
   lSemInvoice:= .F.                                                             //NCF - 19/12/2018
   Work->(DBEVAL({||lSemInvoice:= .T.},{|| (Work->WKDISPINV == Work->WKQTDE .or. Work->WKDISPINV > 0 ) .AND. Work->WKFLAG },{|| !lSemInvoice } ))
   Work->(DBGOTOP())

IF VldSldInv(lGvInvParcial,lTemInvoice,lSemInvoice) //TE-9580 - Valida se prossegue com a gravação ou se bloqueia devido a itens fora da invoice
     Help("",1,"AVG0000702")//"Existem itens ou saldo de itens sem Invoice."
     Return .F.                           
EndIf
/*
IF MOpcao # FECHTO_EMBARQUE .OR. !lOK
   //Verifica se foi feito invoices e usado todo o saldo no Embarque ou no Desembaraco
   lOK:=.T.
   //LGS-14/05/2015 - Verifica se pode gravar o embarque com invoice com qtds parciais.
   IF EasyGParam("MV_EIC0057",,.F.) .And. MOpcao == FECHTO_EMBARQUE
      lGvInvParcial := .T.
   ENDIF
   IF !lGvInvParcial
      Work->(DBEVAL({||lOK:=.F.},{|| !EMPTY(Work->WKDISPINV) .AND. Work->WKFLAG },{|| lOK  } ))
      Work->(DBGOTOP())
   ENDIF
ENDIF
*/ 
If lGvInvParcial .And. lTemInvoice .And. lSemInvoice // Se permite invoice parcial e existe itens com e sem invoice, faz o ajuste
    lOk := .F.
EndIf

IF !lOK 
   //MFR TE-7011 WCC-534964 MTRADE-1554 28/09/2017
   //Help("",1,"AVG0000702")//"Existem itens ou saldo de itens sem Invoice."
    If !lGvInvParcial .AND. !MsgYesNo(STR0897,STR0141) // Não vai perguntar quando o parâmetro for true e for pela tela do embarque      
         Return .F.
    Else    
       nRecNo := Work->(RecNo())
       WORK->(DBGOTOP())
       nRecCount := 0
       nCtrItem  := 0
       DO WHILE WORK->(!EOF())
          nRecCount := nRecCount + 1
          lCancela := .f.
          nQtde := Work->WKQtde   
          //Se a invoice não for antecipada e não é parcial faz o controle da quantidade 
          if aScan(aInv,WORK->WKINVOICE) = 0 .and. !lGvInvParcial                                    
             Work->WKQtde := Work->WKQtde -  Work->WKDISPINV
             if Work->WKQtde = 0
                lCancela := .t.
             Endif
           EndIf     
                
          // Se não tem invoice e é desembaraco não gera o item           
           if EMPTY(WORK->WKINVOICE) .and. nQtde == Work->WKDISPINV .and. !MOpcao == FECHTO_EMBARQUE
              lCancela := .t.
           EndIf    
                                     
           if lCancela
              WORK->WKFLAGWIN   := ""
              WORK->WKFLAG      := .F.
              WORK->WK_ALTEROU  := .T.
              nCtrItem          := nCtrItem + 1
           EndIf
                
           WORK->(DBSKIP())
        ENDDO
        Work->(DbGoTo(nRecNo))
        
        if nCtrItem == nRecCount
           Help("",1,"AVG0000702")//"Existem itens ou saldo de itens sem Invoice."
           Return .F.                                   
        EndIf                                                             
    EndIf
ENDIF

If MOpcao == FECHTO_NACIONALIZACAO .and. nOPC_mBrw == INCLUIR .and. lOk

   //ER - Verifica se as DA´s possuem Frete preenchido.
   nRecSW6:= SW6->(RecNo())//AWR - 17/04/2007 - Para nao desposicionar o SW6
   nRecNo := Work->(RecNo())
   WORK->(DBGOTOP())
   SW6->(DbSetOrder(1))
   DO WHILE WORK->(!EOF())

      IF EMPTY(WORK->WKFLAGWIN)
         WORK->(DBSKIP())
         LOOP
      ENDIF

      IF SW2->(DBSEEK(xFilial("SW2")+WORK->WKPO_NUM))
         IF !EMPTY(SW2->W2_HAWB_DA) .AND. SW6->(DBSEEK(xFilial("SW6")+SW2->W2_HAWB_DA))
            If !Empty(SW6->W6_VLFRECC) .or. !Empty(SW6->W6_VLFREPP) .or. !Empty(SW6->W6_VLFRETN)
               lTemFrete := .T.
               EXIT
            EndIf
         EndIf
      EndIf

      WORK->(DBSKIP())
   ENDDO
   Work->(DbGoTo(nRecNo))
   SW6->(DbGoTo(nRecSW6))

   If !lBtRatFrete .and. lTemFrete
      MsgInfo(STR0617,STR0141) //STR0617 "O frete não foi rateado." //STR0141 := "Atenção"
      //Return .F.// AWR-EOB - 17/04/2007 - É só para avisar, nao pode obrigar
   EndIf
EndIf

lRetorno:=.F.
lSair:=.F.

If lInvAnt //DRL - 16/09/09 - Invoices Antecipadas
        //---    Confere se toda a quantidade dos produtos constantes nas Invoices Antecipadas do Processo de Embarque
        //      que deve ser gravado, foram lançadas na tela de Invoice do Processo, ou se o usuário desmarcou alguma
        //		quantidade nos produtos... Esta consistência serve para garantir que, quando for selecionada uma
        //		INVOICE ANTECIPADA para compor o processo de embarque, a mesma possua TODOS os itens com suas respec-
        //		tivas quantidades no processo, evitando que apenas parte da Invoice seja lançada no Processo de Embarque.
        lSair:=.F.	//---	Variável PRIVATE do EICDI500.PRW.
        axQtEW5SW8	:={}
        aOrd     := SaveOrd({"EW5","WORK_SW8"})
        WORK_SW8->(dBSetOrder(1))
        WORK_SW8->(dBGoTop())
        While	WORK_SW8->(!Eof())
            If  (nxInd:=aScan(axQtEW5SW8,{|X|    X[01]==WORK_SW8->WKINVOICE	.AND.;
                                                 X[02]==WORK_SW8->WKFORN    .AND.;
                                                 X[03]==WORK_SW8->WKPO_NUM	.AND.;
                                                 X[04]==WORK_SW8->WKPOSICAO .And.;
                                                 X[07]==Work_SW8->W8_FORLOJ }))==0
                WORK_SW8->(aAdd(axQtEW5SW8,{WKINVOICE,WKFORN,WKPO_NUM,WKPOSICAO,0,0,Work_SW8->W8_FORLOJ}))
                nxInd	:=	Len(axQtEW5SW8)
            EndIf
            axQtEW5SW8[nxInd,5]+=WORK_SW8->WKQTDE
            WORK_SW8->(dBSkip())
        EndDo
        //
        cxMsg:=""
        EW5->(dBSetOrder(2))
        For	nxInd:=1	to	Len(axQtEW5SW8)
            cxKey:=axQtEW5SW8[nxInd,3]+axQtEW5SW8[nxInd,4]+axQtEW5SW8[nxInd,1]
            If EW5->(dBSeek(xFilial("EW5")+cxKey))
               While EW5->(!Eof()).AND.EW5->EW5_FILIAL==xFilial("EW5").AND.EW5->(EW5_PO_NUM+EW5_POSICA+EW5_INVOIC)==cxKey
                   If  EW5->(EW5_INVOIC+EW5_FORN)==axQtEW5SW8[nxInd,01]+axQtEW5SW8[nxInd,02]
                       axQtEW5SW8[nxInd,6]+=EW5->EW5_QTDE
                   EndIf
                   EW5->(dBSkip())
                EndDo

                If  axQtEW5SW8[nxInd,5]<>axQtEW5SW8[nxInd,6] .And. ( !AVFLAGS("INV_ANT_GERA_CAMB_FIN") .Or. M->W6_TITINAN <> '1' )
                   If	!(AllTrim(axQtEW5SW8[nxInd,1])+Chr(13)+Chr(10)$cxMsg)
                      cxMsg+="-> "+AllTrim(axQtEW5SW8[nxInd,1])+Chr(13)+Chr(10)
                   EndIf
                EndIf
            EndIf
        Next nxInd
        //
		If	!Empty(cxMsg)
            MsgStop(    STR0618+Chr(13)+Chr(10)+; //STR0618 "Verifique as seguintes Invoices, pois as mesmas não estão"
                        STR0619+Chr(13)+Chr(10)+Chr(13)+Chr(10)+; //STR0619 "completamente lançadas neste Processo de Embarque:"
                        cxMsg)
            lSair:=.T.
        EndIf

        If	!DI500ChkEW4()
		//---	Se houve inconsistências no teste contra a tabela de capa da Invoice Antecipada, SAI sem permitir a gravação
		   lSair:=.T.
	    EndIf
        RestOrd(aOrd)
EndIf

//Se for processo DUIMP verifica que há alterações de saldo de itens da invoice para menor e se é possível 
//fazer esta alteração nos itens de lote já gravados pela rotina de vinculação de Lotes\LPCO
If AvFlags("DUIMP") .And. M->W6_TIPOREG == '2'
   cQryAltQW8:= GetQryW8WV("1")
   If VLotesLPCO(cQryAltQW8)
      If !VLnDispChg(cQryAltQW8)
         cHlpErro := STR0915 + ENTER //"Não há saldo disponível de itens sem Lotes ou sem LPCO informado para absorver o saldo alterado no item da invoice." + ENTER
         cHlpErro += STR0916         //"A gravação do Desembaraço será cancelada!" + ENTER
         cHlpSol  := STR0917         //"Revise as alterações de saldo realizadas nos itens da invoice nesta mesma manutenção ou cancele a manutenção do desembaraço e verifique os Lotes e LPCOS indicados para este item na rotina de Itens DUIMP afim de liberar saldo que absorva a diferença de quantidade informada no item da invoice."   
         EasyHelp(cHlpErro,"Atenção",cHlpSol)
         lSair := .T.
         Return lRetorno
      EndIf
   EndIf
   GetQryW8WV("","CLOSE")
EndIf

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ANTES_CONF_GRAVA"),)
IF lSair
   RETURN lRetorno
EndIf

Work_SW9->(DBSETORDER(1))
Work_SW8->(DBSETORDER(1))
Work_SW9->(DBGOTOP())

DO WHILE !Work_SW9->(EOF())
   IF WORK_SW9->W9_TUDO_OK == NAO .AND.;
      Work_SW8->(DBSEEK(Work_SW9->W9_INVOICE+Work_SW9->W9_FORN+WORK_SW9->W9_FORLOJ))
      IF DI500InvConf(.F.,Work_SW9->W9_INVOICE,Work_SW9->W9_FORN,.T.,WORK_SW9->W9_FORLOJ)
		 If (WORK_SW9->(FIELDPOS("W9_RATFRT")) # 0) //LGS-12/11/2013
         	lRateiaIntFreigh := .T.
         EndIf
         Processa( {|| DI500InvTotais(.F.,.F.) } )
      ELSE
         RETURN .F.
      ENDIF
   ENDIF
   Work_SW9->(DBSKIP())
ENDDO

If lCambInicial .and. lAltInv // TDF - 09/08/10
   cPergunte:= STR0620 // STR0620 "Os ajustes na(s) parcela(s) de câmbio devem ser feitos manualmente.Confirma a gravação?"
Else
   cPergunte:=STR0059
EndIf
lSair:=.F.
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GRAVA_TUDO"),)
IF lSair
   RETURN .F.
EndIf

IF MSgYesNo(cPergunte,STR0141)//'Confirma a Gravação ? '###'Fechamento'
      If AvFlags("EIC_EAI") //.AND.( !EasyGParam("MV_EIC0049",,.F.) .OR. (!EMPTY(M->W6_DT_NF)))// Só enviar a gravação se os titulos foram excluidos com sucesso
         lTitEAI_OK := .T.
         IF !EICAP110(.T.,5,M->W6_HAWB,"D")//EICAP110(lEnvio,nOpc,cHawb,cFaseAP,cTipParc,lJumpVal,cTipo,aAltParc,cTabAlias)
            lTitEAI_OK := .F.
            //nVezesEnvia++
            //IF nVezesEnvia < 2
               Return .F.
            //ENDIF
         ENDIF
         //IF nVezesEnvia == 2
         //   M->W6_TITOK := "2"
         //ENDIF
      ENDIF

    //AOM - 18/04/2011 -  Operaçoes Especiais
    If !VldOpeDesemb("BTN_PRINC_EMB")
       Return .F.
    EndIf

   // RA - 06/11/2003 - O.S. 1145/03 - Inicio
   If Inclui .And. GetNewPar("MV_NRDI",.F.)
      /*
      xControle := EasyGParam("MV_CTRL_DI",,"999999999999998")
      xControle := Val(xControle)+1
      Do While xControle == 999999999999999
         MsgStop("MV_CTRL_DI => SX6")
         xControle := EasyGParam("MV_CTRL_DI",,"999999999999998")
         xControle := Val(xControle)+1
      EndDo
//      xControle  := PadL(xControle,Len(SW6->W6_HAWB),"0")  - RS 28/04/06
      xControle  := PadL(xControle,15,"0")
      SetMV("MV_CTRL_DI",xControle)
      */    
      
      xControle := EasyGetMVSeq("MV_CTRL_DI")
      M->W6_HAWB := AvKey(xControle, "W6_HAWB")



      If(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"CTRL_DI"),)
      //*** Atualiza o HAWB na work das invoices visto que este campo faz parte da chave de busca
      Work_SW9->(DbGoTop())
      Work_SW9->(DbEval({|| W9_HAWB := M->W6_HAWB }))
      Work_SW9->(DbGoTop())
   EndIf
   
   SW6->(DbSetOrder(1))
   SW9->(DbSetOrder(3))

   IF Inclui .AND. ( SW7->(DbSeek(xFilial()+M->W6_HAWB)) .Or.;
                     SW8->(DbSeek(xFilial()+M->W6_HAWB)) .Or.;
                     SW9->(DbSeek(xFilial()+M->W6_HAWB)) .Or. ;
                     SW6->(DbSeek(xFilial()+M->W6_HAWB))   )
      Help("",1,"AVG0000724",,Alltrim(M->W6_HAWB),1,10)//MSG INFO(Avsx3("W6_HAWB",5)+" "+Alltrim(M->W6_HAWB)+STR0515,STR0141)//ja Cadastrado,Atencao
      SW9->(DbSetOrder(nOrdSW9))
      // RA - 06/11/2003 - O.S. 1145/03 - Inicio
      If Inclui .And. GetNewPar("MV_NRDI",.F.)
         M->W6_HAWB := "Automatico"
         //*** Atualiza o HAWB na work das invoices visto que este campo faz parte da chave de busca
         Work_SW9->(DbGoTop())
         Work_SW9->(DbEval({|| W9_HAWB := M->W6_HAWB }))
         Work_SW9->(DbGoTop())
      EndIf
      Return .F.
   ENDIF

   SW9->(DbSetOrder(nOrdSW9))
   lSair:=.F.
   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ANT_GRAVA_TUDO"),)
   IF lSair
      RETURN .F.
   EndIf

   IF lFinanceiro .Or. lAvIntDesp
      axFlDelWork:={}
      TP251CriaWork()
      axFl2DelWork:={}
      TP252CriaWork()
   ENDIF


   If lAvIntDesp//AWR - 2011/06/01 - O AVINTEG deve ser executado fora do Begin Transaction
      oDI500IntProv := AvIntProv():New()
   EndIf

    // TDF - 15/08/11 - Não permitir alterações que gerem movimentações financeiras de acordo com o MV_DATAFIN
    If lFinanceiro .And. FI400DIAlterou(M->W6_HAWB,"A")
       If EasyGParam("MV_DATAFIN") > DDATABASE
          MsgInfo(STR0574 + ENTER + STR0575, STR0057)
          Return .F.
       EndIf
    EndIf

   IF (!lGravaFin_EIC .AND. !lCambInicial) .OR. lAvIntDesp
       EICFI400("ANT_GRV_DI","I")
    ENDIF
    //** BHF - 08/12/08
    IF lGravaFin_EIC .And. FI400DIAlterou(M->W6_HAWB,"I")
       FI400ANT_DI(M->W6_HAWB,.F.,lGravaFin_EIC)
    ENDIF

    //**
    lChangeEmb := (nOPC_mBrw == 3 .AND. !EMPTY(M->W6_DT_EMB)) .OR.  (nOPC_mBrw <> 3 .AND. M->W6_DT_EMB <> SW6->W6_DT_EMB) 	//IGOR CHIBA se for inclusao e data preenchida ou se for alteracao e data diferente
    IF AvFlags("EIC_EAI") .AND. lTitEAI_OK//.AND.( !EasyGParam("MV_EIC0049",,.F.) .OR. (!EMPTY(M->W6_DT_NF))) -- Jacomo Lisa - 08/08/2014 - Verifica se teve alteração antes de Gravar o Processo
       //lIntEnvia := ValEnvCBO("D",.F.,.T.)//ValEnvCBO(cFase,lJumpVal,lJustVal)
       cTipParc := ValEnvCBO("D",.F.,.T.)//ValEnvCBO(cFase,lJumpVal,lJustVal)
    ENDIF

    //NCF - 25/10/2018
    IF (Work_EIJ->(BOF()) .AND. Work_EIJ->(EOF())) .And. ( M->W6_CURRIER $ cSim .And. !Empty(M->W6_DIRE) ) .And. (nOPC_mBrw == 3 .Or. nOPC_mBrw == 4)
       If EasyGParam("MV_TEM_DI",,.F.) 
          Processa({|| DI500GeraAdicoes()},STR0342) //"Gerando Adicoes..."
       Else
          Processa({|| EICAdicao(.F.,4,.T.,.T.) } , STR0342 )
       EndIf
    ENDIF

    Processa({|| DI500GravaTudo() },STR0024) //"Fechamento de Desembaraço"

   IF (!lGravaFin_EIC .AND. !lCambInicial) .OR. lAvIntDesp
       EICFI400("POS_GRV_DI","I")
    ENDIF

   If lAvIntDesp//AWR - 2011/06/01 - O AVINTEG deve ser executado fora do Begin Transaction
      oDI500IntProv:Grava()
      oDI500IntProv := NIL
   EndIf

//***** DELETAR ARQUIVO DA FUNCAO AV POS_DI() E AVPOS_PO(), QDO TEM CONTROLE DE TRANSACAO
   IF lFinanceiro
      If Select("WorkTP") # 0
         IF TYPE("axFl2DelWork") = "A" .AND. LEN(axFl2DelWork) > 0
            WorkTP->(E_EraseArq(axFl2DelWork[1]))
            FOR nWk:=2 TO LEN(axFl2DelWork)
                FERASE(axFl2DelWork[nWk]+TEOrdBagExt())
            NEXT
         ENDIF
      ENDIF
      //JMS - 23/06/04 - PARA APAGAR OS ARQUIVOS DO EICTP251.
      If Select("Work_1") # 0 .AND. Select("Work_2") # 0
         IF TYPE("axFlDelWork") = "A" .AND. LEN(axFlDelWork) > 0
            Work_1->(E_EraseArq(axFlDelWork[1]))
            Work_2->(E_EraseArq(axFlDelWork[3]))
            FOR nWk:=2 TO LEN(axFlDelWork)
                FERASE(axFlDelWork[nWk]+TEOrdBagExt())       //NCF - 19/12/2017 - Necessário usar FERASE para excluir os índices pois o arquivo WORK não mais existia na tela de Conf. Final
            NEXT
         ENDIF
      ENDIF
   ENDIF
//*******************

   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"POS_GRAVA_TUDO"),)

   IF AvFlags("EIC_EAI") //Jacomo Lisa - 17/07/2014 - Incluida a Integração do Logix
      aEnv_PO:= PO420PedOri(aEnv_PO) //NCF - 17/10/2016
      IF Len(aEnv_PO) > 0  //Envio dos Pedidos
         /* Verifica se existem pedidos originados por processo de entreposto e
            retorna os pedidos válidos para a geração da programação de entregas*/
         //aEnv_PO:= PO420PedOri(aEnv_PO)
         For i = 1 To Len(aEnv_PO) //SSS -  REG 4.5 03/06/14
            If !EICPO420(.T.,4,,"SW2",.F.,aEnv_PO[I])// EICPO420(lEnvio,nOpc,aCab,cAlias,lWk,cPo_num)
               cPos+=ALLTRIM(aEnv_PO[I])+", "
            EndIf
         Next
         If !Empty(cPos)
            MsgInfo(STR0871, STR0558) //"Acesse os Purchase orders #### para realização dos ajustes necessários.", "Aviso"
         EndIf
         aEnv_PO:= {}
      ENDIF
      //Jacomo Lisa - 08/08/2014 -- Incluida a Integração do Logix
      If AvFlags("EIC_EAI") .AND. lTitEAI_OK .AND. !EMPTY(cTipParc)//.AND. (!EasyGParam("MV_EIC0049",,.F.) .OR. (!EMPTY(M->W6_DT_NF)) ).AND. lIntEnvia// Só enviar a gravação se os titulos foram excluidos com sucesso
         IF !EICAP110(.T.,3,M->W6_HAWB,"D",cTipParc,.T.) //EICAP110(lEnvio,nOpc,cHawb,cFaseAP,cTipParc,lJumpVal,cTipo,aAltParc,cTabAlias)
            lTitEAI_OK := .F.
         ENDIF
      ENDIF

      /* Atualização do status do processo */
      AP110AtuStatus(M->W6_HAWB, .T.)
   ENDIF

   IF Inclui .And. GetNewPar("MV_NRDI",.F.) // RA - 06/11/2003 - O.S. 1145/03
      MSGINFO( STR0520+M->W6_HAWB,STR0141)//"Numero do Processo: "###"Atencao"
   ENDIF

   if isMemVar("lGravaSoCapa") .and. !lGravaSoCapa .and. nOPC_mBrw == ALTERACAO .and. ( MOpcao == FECHTO_EMBARQUE .or. MOpcao == FECHTO_DESEMBARACO ) .and. AvFlags("DUIMP") .and. M->W6_TIPOREG == DUIMP .and. existFunc("EICLP501")
      Processa({|| EICLP501( M->W6_HAWB ) }, STR0930 + "...") // "Atualizando Itens DUIMP"
   endif

   RETURN .T.

ENDIF

RETURN .F.

Function DI500Selecao(oBrw)//Antiga DI_SelPO()

Local bOk := {||IF(DI500POPLIValid(.T.,cPedido,.T.),(nOpcaoSele:=1,oDlgSelec:End()),)} //FDR - 22/07/11
LOCAL bCancel:={|| nOpcaoSele:=0,oDlgSelec:End() },cPO,cGI,lOk:=.T.,cTitulo
Private aBtnSelecao:={}
PRIVATE oLbx1,oLbx2,oDlgSelec,cWhenSel := .T.
IF oBrw = NIL
   cPedido:=M->W6_PO_NUM
ELSE
   cPedido:=SPACE(LEN(SW7->W7_PO_NUM))
ENDIF
cPLI:=SPACE(LEN(SW7->W7_PGI_NUM))
IF Work->(EasyRecCount("Work")) == 0 .AND. Inclui
   IF(EMPTY(cPedido),aPedido:={},)
   aPLI:={}
ENDIF

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"CARGA_PO_PLI"),)

DO WHILE .T.
   nOpcaoSele:=0
   cColD:=627
   cTitulo:=STR0433//"Selecao de Pedidos e P.L.I.'s"
   IF cPaisLoc # "BRA"
      cTitulo:=LEFT(STR0433,21)//"Seleccion de Pedidos"
      cColD:=350
   ENDIF

   DEFINE MSDIALOG oDlgSelec TITLE cTitulo FROM 116,171 TO 416,cColD OF oMainWnd PIXEL

     oPanel:= TPanel():New(0, 0, "", oDlgSelec,, .F., .F.,,, 116, 171)
     oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

     @ 1.5,.2 SAY AVSX3("W2_PO_NUM",5) OF oPanel //"Pedido"
     @ 1.5,04 MSGET cPedido F3 "SW2" SIZE 55,8 PICT _PictPO VALID DI500POPLIValid(.T.,cPedido,.F.) WHEN cWhenSel OF oPanel

     IF cPaisLoc = "BRA"
        @ 1.5,11 SAY AVSX3("W7_PGI_NUM",5) OF oPanel//"P.L.I."
        @ 1.5,14 MSGET cPLI    F3 "SW4" SIZE 50,8 PICTURE "@!" VALID DI500POPLIValid(.F.,cPedido,.F.) WHEN cWhenSel OF oPanel
     ENDIF

     If lInvAnt //DRL - 16/09/09 - Invoices Antecipadas
        oDlgSelec:nRight += 150
        @ 1.5,21 SAY STR0621 OF oPanel//STR0621 "Invoice Ant."
        @ 1.5,25 MSGET cInv F3 "EW4_0" SIZE 55,8 Picture "@!" VALID ValidInv(cInv) OF oPanel
        @ 2.5,25 LISTBOX oLbxInv VAR cInv ITEMS aInv SIZE 50,80 OF oPanel UPDATE
	 EndIf

     IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"TELA_SELECAO"),)

     @ 2.5,04 LISTBOX oLbx1 VAR cPO ITEMS aPedido SIZE 50,80 OF oPanel UPDATE
     IF cPaisLoc = "BRA"
        @ 2.5,14 LISTBOX oLbx2 VAR cGI ITEMS aPLI SIZE 50,80 OF oPanel UPDATE
     ENDIF
   ACTIVATE MSDIALOG oDlgSelec ON INIT EnchoiceBar(oDlgSelec,bOk,bCancel,,aBtnSelecao) CENTERED /*FDR - 22/07/11*/ //DI500EnchoiceBar(oDlgSelec,aOk,bCancel,.F.,aBtnSelecao) CENTERED
   IF nOpcaoSele = 0
      DI500POFIL()
      RETURN .F.
   ENDIF

   IF Len(cPedido) < LEN(SW7->W7_PO_NUM)
      cPedido:= cPedido+SPACE(LEN(SW7->W7_PO_NUM)-LEN(cPedido))
   ENDIF

   lOk:=.T.
   Processa({|| lOk:=DI500WorkGrava() },STR0054) //"Pesquisa de Itens"
   IF lOk
      EXIT
   ENDIF
ENDDO
lPrimeiraVez:=.F.
Work->(dbsetorder(3))
Work->(DBGOTOP())
IF oBrw # NIL
   oBrw:Refresh()
   oBrw:Reset()
ENDIF
RETURN .T.


FUNCTION DI500POPLIValid(lPedido,cPedido,lOK,lDiValid)//Antiga DI_ValidPO(lValidPO)

Local nI:=0 //igor chiba 29/09/09
Local	cCdImport:= ""
Local	cCdImpPO	:=	""
Default lDiValid := .F.
Private aOrdPO := {} //NCF 12/05/09
//FSM - 24/05/2012
If EasyGParam("MV_AVG0211",,.F.) .And. DI500AdmEntre()
   Return .T.
EndIf

IF lInvAnt .AND. LCAMBIO_EIC
   cFilEW4:=XFILIAL('EW4')
   cFilEW5:=XFILIAL('EW5')
   cFilSW2:=XFILIAL('SW2')
   cFilSW5:=XFILIAL('SW5')
   EW4->(DBSETORDER(1))
   EW5->(DBSETORDER(1))
   SW5->(DBSETORDER(8))

   FOR nI:=1 to len(aInv)
      IF EW4->(DBSEEK(cFilEW4+aInv[nI])) .AND. EMPTY(EW4->EW4_TITERP) .AND. lEICFI07
         lValidPOPLI:=.F.
         MsgStop(STR0622) //STR0622 'Invoice Antecipada não pode ser usada pois não possui Título ERP.'
         RETURN .F.
      ENDIF
   NEXT

   FOR nI:=1 to len(aPLI)
      SW5->(DBSEEK(cFilSW5+aPLI[nI]))
      IF EW4->(DBSEEK(cFilEW4+SW5->W5_INVANT )) .AND. EMPTY(EW4->EW4_TITERP) .AND. lEICFI07
         MsgStop(STR0622)//STR0622 'Invoice Antecipada não pode ser usada pois não possui Título ERP.'
         RETURN .F.
      ENDIF
   NEXT

	cCdImport	:=	""
   FOR nI:=1 to len(aInv)
      EW5->(DBSEEK(cFilEW5+aInv[nI]))
      While	EW5->(!Eof()).AND.EW5->EW5_FILIAL==cFilEW5.AND.EW5->EW5_INVOIC==aInv[nI]
      	If	aScan(aPedido,EW5->EW5_PO_NUM) == 0
      		aAdd(aPedido,EW5->EW5_PO_NUM)
      		cCdImpPO		:=	Posicione("SW2",1,cFilSW2+EW5->EW5_PO_NUM,"W2_IMPORT")
      		cCdImport	:=	If(Empty(cCdImport),cCdImpPO,cCdImport)
      		If	cCdImpPO	<>	cCdImport	.OR.	(!Empty(M->W6_IMPORT)	.AND.	cCdImpPO	<>	M->W6_IMPORT)
		         MsgStop(STR0623)//STR0623 'Não é permitido embarcar Invoices de importadores diferentes num mesmo Processo de Embarque'
      		   RETURN .F.
      		EndIf
      	EndIf
      	EW5->(dBSkip())
      EndDo
   NEXT

	If	Empty(M->W6_IMPORT)	.AND. If(cPaisLoc # "BRA",.T.,nOPC_mBrw == 3)	.AND.	!Empty(cCdImport)
	   M->W6_IMPORT	:=	cCdImport
	   M->W6_IMPORVM	:=	Posicione("SYT",1,xFilial("SYT")+M->W6_IMPORT,"YT_NOME")
	EndIf
	If	Empty(M->W6_PO_NUM)	.AND.	Len(aPedido)>0
		M->W6_PO_NUM:=AvKey(aPedido[01],"W6_PO_NUM")
	EndIf
ENDIF
//**
IF lOK
   IF LEN(aPedido) = 0  .AND. LEN(aPLI) = 0
      Help("", 1,"AVG0000703")//Nao ha Pedidos ou P.L.I.s selecionados.
      RETURN .F.
   ENDIF
   lValidPOPLI:=.T.
   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"VALID_OK_PEDIDO_PLI"),)
   RETURN lValidPOPLI
ENDIF

IF Len(cPedido) < LEN(SW2->W2_PO_NUM)
   cPedido:= cPedido+SPACE(LEN(SW2->W2_PO_NUM)-LEN(cPedido))
ENDIF

IF Len(cPLI) < LEN(SW5->W5_PGI_NUM)
   cPLI:= cPLI+SPACE(LEN(SW5->W5_PGI_NUM)-LEN(cPLI))
ENDIF

IF lPedido .AND. (EMPTY(cPedido) .OR. ASCAN(aPedido,cPedido) # 0)
   RETURN .T.
ELSEIF !lPedido .AND. (EMPTY(cPLI) .OR. ASCAN(aPLI,cPLI) # 0)
   RETURN .T.
ENDIF

IF lPedido
   SW5->(DBSETORDER(3))
   IF !SW5->(DBSEEK(xFilial()+cPedido)) .And. !DI500PNPLI(cPedido)
      IF MOpcao == FECHTO_NACIONALIZACAO
         Help(" ",1,"E_SEMGINAC")//'NAO EXISTE P.L.I. PARA A NACIONALIZACAO INFORMADA
      ELSE
         Help(" ",1,"E_SEMGIPO")//NAO EXISTE P.L.I. PARA O P.O. INFORMADO
      ENDIF
      RETURN .F.
   ENDIF
ELSE
   SW5->(DBSETORDER(1))
   SW4->(DBSETORDER(1))
   IF SW4->(DBSEEK(xFilial()+cPLI)) .AND.;
      SW5->(DBSEEK(xFilial()+cPLI))
      cPedido:=SW5->W5_PO_NUM
   ELSE
      Help(" ",1,"E_GINAOCAD")
      RETURN .F.
   ENDIF
ENDIF

SW3->(DBSETORDER(1))
SW2->(DBSETORDER(1))
IF !SW2->(DBSEEK(xFilial()+cPedido)) .OR.;
   !SW3->(DBSEEK(xFilial()+cPedido))
   IF MOpcao == FECHTO_NACIONALIZACAO
      Help(" ",1,"E_NANAOCAD")//NACIONALIZACAO NAO CADASTRADA
   ELSE
      Help(" ",1,"E_PONAOCAD")//P.O. NAO CADASTRADO
   ENDIF
   RETURN .F.
ELSEIF !AvFlags("EIC_EAI") .And. lW2ConaPro .And. !Empty(SW2->W2_CONAPRO) .And. SW2->W2_CONAPRO<>"L"
   MsgStop(STR0547,STR0141)//"O Pedido não está liberado pelo Controle de Alcada",Atencao
   Return .F.
ENDIF
SW3->(DBSEEK(xFilial()+cPedido))//Posiciona no SW3 quando acha o SW2

If MOpcao#FECHTO_NACIONALIZACAO .AND. ! Empty(Alltrim(SW2->W2_HAWB_DA))
   Help(" ",1,"AVG0000089")
   Return .F.
Endif

If MOpcao=FECHTO_NACIONALIZACAO .AND. Empty(Alltrim(SW2->W2_HAWB_DA))
   Help(" ",1,"AVG0000088")
   Return .F.
Endif
//IGOR CHIBA -AVERAGE 23/05/2014 tratamento
//para que, quando a integração via mensagem única estiver habilitada (MV_EIC_EAI), apenas seja possível utilizar Purchase Order cujo status seja aprovado
If AvFlags("EIC_EAI") .AND. SW2->W2_CONAPRO <> '1'
   EasyHelp(STR0887, STR0558) //"O Purchase Order está aguardando aprovação no ERP". "Aviso"
   Return .F.
Endif
If /*MOpcao=FECHTO_NACIONALIZACAO .AND.*/ Empty(M->W6_PO_NUM) .AND. !Empty(cPedido)   //NCF-01/08/09 - Na validação do PO selecionado(Desembaraço e Nacionalização),
   M->W6_PO_NUM := cPedido                                                        //               preenche o No. do P.O que estava vindo vazio.
EndIf

// FDR - 19/07/11 - Verifica se opção é "Incluir DSI"
lDSIInclui := EasyGParam("MV_TEM_DSI",,.F.) .And. Upper(aRotina[nOPC_mBrw][1]) == Upper("Incluir DSI")

aOrdPO := SaveOrd({"SW2","SYT"})
IF !EMPTY(M->W6_PO_NUM) .And. IF(cPaisLoc # "BRA",.T.,nOPC_mBrw == 3 .Or. lDSIInclui)                 //NCF-12/05/09 - Preenchimeto do Cod. Importador
   SW2->(DbSetOrder(1))                                                                                  //               referente ao P.O. Selecionado
   SW2->(DbSeek(xFilial("SW2")+M->W6_PO_NUM))
   M->W6_IMPORT := SW2->W2_IMPORT
   SYT->(DbSetOrder(1))
   SYT->(DbSeek(xFilial("SYT")+M->W6_IMPORT))
   M->W6_IMPORVM := SYT->YT_NOME
ENDIF
//IF(EMPTY(M->W6_IMPORT),M->W6_IMPORT:=SW2->W2_IMPORT,)
RestOrd(aOrdPo, .T.)

IF M->W6_IMPORT # SW2->W2_IMPORT
   Help(" ",1,"E_IMPDIFER")//O IMPORTADOR DESTE P.O. NAO E M->W6_IMPORT
   Return .F.
ENDIF

IF cPaisLoc # "BRA"
   IF(EMPTY(cMoedaProc),cMoedaProc:=SW2->W2_MOEDA,)
   IF cMoedaProc # SW2->W2_MOEDA
      Help(" ",1,"E_MOEDIFER")//'A MOEDA DESTE P.O. NAO E cMoedaProc
      Return .F.
   ENDIF
ELSEIF !lPedido
   SWP->(DBSETORDER(1))
   IF SWP->(DBSEEK(xFilial()+SW5->W5_PGI_NUM))
      IF LDISimples
         IF EMPTY(M->W6_TIPODES)
            M->W6_TIPODES:=SWP->WP_NAT_LSI
         ENDIF
         IF !EMPTY(SWP->WP_NAT_LSI) .AND. M->W6_TIPODES # SWP->WP_NAT_LSI
            MSGSTOP(STR0624,"LSI: "+SW5->W5_PGI_NUM+" "+SW5->W5_SEQ_LI)//STR0624 "Natureza da Operacao difere das LSI's ja informadas." // STR0625 "LSI: "
            Return .F.
         ENDIF
      ENDIF
   ENDIF
ENDIF

lValidPOPLI:=.T.

lValidPOPLI := VALID_PEDIDO(lDiValid,.T.,.T.,.T.) // Valid_Pedido_PLI //veio da tela de seleção dos po´s

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"VALID_PEDIDO_PLI"),)

IF !lValidPOPLI
   RETURN .F.
ENDIF

IF !lGetPo
   AADD(aPedido,cPedido)
   Return .T.
EndIf

IF lPedido
   IF TYPE("oLbx1") = "O"
      oLbx1:ADD(cPedido)
   ENDIF
ELSE
   oLbx2:ADD(cPLI)
ENDIF

Return .T.


FUNCTION DI500WorkGrava()//Antiga DI_SelItem() - Parte da Validacao

Local nPLI, nPO, nCont:=0
PRIVATE lTemItens:= .F.
PRIVATE oDlgProc := GetWndDefault()

//ProcRegua(LEN(aPLI))
ProcRegua(IF(lTop .AND. Len(aPLI) > 0,DI500TotReg("PLI"),10))
SW4->(DBSETORDER(1))

SW5->(DBSETORDER(1))
FOR nPLI:= 1 TO LEN(aPLI)

    cPli:=aPLI[nPLI]
    //IncProc(STR0440+cPli) //"Lendo Itens da PLI: "
    //TRP-01/10/07
   IF !lTop
      IF nCont > 10
         nCont:=0
         ProcRegua(10)
      EndIf
      nCont++
   EndIf
   IncProc(STR0440+cPli) //"Lendo Itens da PLI: "

    IF SW4->(DBSEEK(xFilial()+cPli))
       SW4->(RecLock("SW4",.F.))
    ELSE
       RETURN .F.
    ENDIF
    SW5->(DBSEEK(xFilial()+cPli))
    cPedido:=SW5->W5_PO_NUM

    DI500POFIL()

    DBSELECTAREA("Work")
    Work->(DBSETORDER(1))
    Work->(DBSEEK(cPli))
    SET FILTER TO Work->WKPGI_NUM == cPli

    DI500ProcGI("W5_PGI_NUM",cPli)
    DBSELECTAREA("Work")
    SET FILTER TO

NEXT

//ProcRegua(LEN(aPedido))
ProcRegua(IF(lTop .AND. Len(aPedido) > 0,DI500TotReg("Pedido"),10))

SW5->(DBSETORDER(3))
FOR nPO:= 1 TO LEN(aPedido)

   cPedido:=aPedido[nPO]
   IF Len(cPedido) < LEN(SW5->W5_PO_NUM)
   cPedido:= cPedido+SPACE(LEN(SW5->W5_PO_NUM)-LEN(cPedido))
   ENDIF
   //IncProc(STR0441+cPedido) //"Lendo Itens do Pedido: "
   //TRP-01/10/07
   IF !lTop
      IF nCont > 10
         nCont:=0
         ProcRegua(10)
      EndIf
      nCont++
   EndIf
   IncProc(STR0441+cPedido) //"Lendo Itens do Pedido: "

    SW5->(DBSEEK(xFilial()+cPedido))
    cPLI:=SW5->W5_PGI_NUM

    IF SW4->(DBSEEK(xFilial()+cPLI))
       SW4->(RecLock("SW4",.F.))
    ELSE
       RETURN .F.
    ENDIF

    DI500POFIL()

    DBSELECTAREA("Work")
    Work->(DBSETORDER(2))
    Work->(DBSEEK(cPedido))
    SET FILTER TO Work->WKPO_NUM == cPedido

    DI500ProcGI("W5_PO_NUM",cPedido)

    DBSELECTAREA("Work")
    SET FILTER TO

NEXT


DBSELECTAREA("Work")
IF !lTemItens .AND. Inclui
   Help("", 1,"AVG0000704")//Nao ha Itens a serem selecionados.
   SET FILTER TO
   RETURN .F.
ENDIF
lGravaSoCapa:=.F.

RETURN .T.

FUNCTION DI500ProcGI(cCpo,cChave)//Antiga DI_ProcGI(bMsg)

LOCAL lAchou, MChave, MChave_WK, aOrd //DRL - 16/09/09
LOCAL cFilSW5:=xFilial("SW5")
LOCAL cFilSW2:=xFILIAL("SW2")
LOCAL cTmpTabSW5,cTmpWrkSW5,cSelect, cFrom, cWhere, cQuery, nOldArea
Local lPrimeiro   := .T.
Local lMostMsgNVE := .T.
Local lTemNVEPLI  := .F.
Local lTemNVECad  := .F.
Local oJsonInvAnt := JsonObject():new() //THTS - 11/10/2021 - Controlar as Invoices para calcular os totais dos itens de cada Invoice adicionada ao processo
Local aJsonInv
Local nTotInv

SW3->(dbSetOrder(1))
SW9->(DBSETORDER(3))
SA5->(DBSETORDER(3))
SWP->(DBSETORDER(1))
SW2->(dbSetOrder(1))
cIndice:=Work->(INDEXKEY())

cLSIsNaoLidas:=""

cTmpTabSW5 := GetNextAlias()
cWhere := "% SW5."+cCpo+" = '"+cChave+"' %"

BeginSQL Alias cTmpTabSW5
   SELECT SW5.R_E_C_N_O_
   FROM %table:SW5% SW5
   WHERE SW5.%NotDel%
   AND SW5.W5_FILIAL  = %exp:cFilSW5%
   AND %Exp:cWhere%
   AND SW5.W5_SEQ = 0
   AND SW5.W5_SALDO_Q > 0
EndSql

DO WHILE (cTmpTabSW5)->(!Eof())

   SW5->(DbGoTo( (cTmpTabSW5)->R_E_C_N_O_ ))
   oDlgProc:SetText(STR0282+ALLTRIM(SW5->W5_COD_I)) //"Lendo Item: "

   If lTop
      If cChave == cPli
         IncProc(STR0440+cPli)
      Else
         IncProc(STR0441+cPedido)
      Endif
   Endif

   SW2->(DBSEEK(cFilSW2+SW5->W5_PO_NUM))

   IF MOpcao = FECHTO_DESEMBARACO
      IF !EMPTY(SW2->W2_HAWB_DA)
         (cTmpTabSW5)->(DbSkip())
         LOOP
      ENDIF
   ELSEIF MOpcao = FECHTO_NACIONALIZACAO
      IF EMPTY(SW2->W2_HAWB_DA)
         (cTmpTabSW5)->(DbSkip())
         LOOP
      ENDIF
   ENDIF

   IF MOpcao = FECHTO_DESEMBARACO .OR. MOpcao == FECHTO_NACIONALIZACAO
      IF _Declaracao
         IF SW5->W5_FLUXO # "4"
            (cTmpTabSW5)->(DbSkip())
            LOOP
         ENDIF
      ELSE
         IF SW5->W5_FLUXO = "4"
            (cTmpTabSW5)->(DbSkip())
            LOOP
         ENDIF
      ENDIF
   ENDIF

   IF SWP->(DBSEEK(xFilial()+SW5->W5_PGI_NUM))
      IF LDISimples .AND. SWP->(FieldPos("WP_NAT_LSI")) > 0
         IF EMPTY(M->W6_TIPODES)
            M->W6_TIPODES:=SWP->WP_NAT_LSI
         ENDIF
         IF !EMPTY(SWP->WP_NAT_LSI) .AND. M->W6_TIPODES # SWP->WP_NAT_LSI
            cLSIsNaoLidas+=SW5->W5_PGI_NUM+" "+SW5->W5_SEQ_LI+", "
            (cTmpTabSW5)->(DbSkip())
            LOOP
         ENDIF
      ENDIF
   ENDIF

   //MChave   := cChave+SW5->W5_CC+SW5->W5_SI_NUM+SW5->W5_COD_I
   lLoop:=.F.
   If lInvAnt //DRL - 16/09/09 - Invoices Antecipadas
      aOrd     := SaveOrd({"EW4","EW5","WORK_SW9","SW3"})
      EW5->(DbSetOrder(2))
      If Len(aInv) > 0
         WORK_SEL->(DbSeek(SW5->(W5_PGI_NUM+W5_PO_NUM+W5_POSICAO)))
         While WORK_SEL->(!Eof()) .And. WORK_SEL->(WKPLI+WKPO_NUM+WKPOSICAO)==SW5->(W5_PGI_NUM+W5_PO_NUM+W5_POSICAO)
              If Empty(WORK_SEL->WKFLAGWIN)
                 WORK_SEL->(DbSkip())
                 LOOP
              EndIf
              lLoop := .T.
              lTemItens:=.T.
              If Empty(WORK_SEL->WKUSADO)
                 DI500GrvW7W8W9(@lPrimeiro,@lMostMsgNVE,@lTemNVEPLI,@lTemNVECad,@oJsonInvAnt)
                 WORK_SEL->WKUSADO:="X"
              EndIf
              WORK_SEL->(DbSkip())
         EndDo
      EndIf
      RestOrd(aOrd)
   EndIf
   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"SKIP_ITEM_SW5"),)
   IF lLoop
      (cTmpTabSW5)->(DbSkip())
      LOOP
   ENDIF

   //MChave_WK:= MChave
   //Work->(dbsetorder(2),DBSEEK(MChave))
   lAchou:= CheckWork()//.F.

   IF lAchou
      lTemItens:=.T.
      (cTmpTabSW5)->(DbSkip())
      Loop
   ENDIF

   DI500CarregaWork("W5_")//Grava SW5 no Work
   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"CARREGA_WORK"),)
   (cTmpTabSW5)->(DbSkip())
   lTemItens:= .T.

ENDDO
aJsonInv := oJsonInvAnt:getNames()
For nTotInv := 1 To Len(aJsonInv)
   Work_SW9->(dbGoTo(oJsonInvAnt[aJsonInv[nTotInv]]))
   DI500InvTotais(.F.,.F.,,.T.,.T.)
Next

(cTmpTabSW5)->(DbCloseArea())

//** AAF 22/08/2008 - Ponto de entrada para o final do processamento para carregar os itens.
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"CARREGA_WORK_FINAL"),)

IF !EMPTY(cLSIsNaoLidas)
   cLSIsNaoLidas:=LEFT(cLSIsNaoLidas,LEN(cLSIsNaoLidas)-2)
   MSGINFO(STR0624,STR0625+cLSIsNaoLidas) //STR0624 "Natureza da Operacao difere das LSI's ja informadas." //STR0625 "LSI's nao Lidas: "
ENDIF

RETURN .T.

/*
Funcao      : CheckWork()
Parâmetros  : 
Retorno     :
Objetivos   : bufferizar a verifiação da existência de registro na work
Autor       : WFS
Data 	      : 04/10/2019
Obs         : 
Revisão     :
*/
Static function CheckWork()
Local lAchou
Local cHashChave:= ""
Local cContent:= ""

Begin Sequence

   lAchou:= .F.
   cHashChave:= SW5->(W5_FILIAL + W5_CC + W5_SI_NUM + W5_COD_I + W5_PO_NUM + W5_PGI_NUM + W5_FORN + W5_FORLOJ + W5_FABR + W5_FABLOJ + Str(W5_REG))

   If !(lAchou:= oCheckWork:Get(cHashChave, @cContent))
      oCheckWork:Set(cHashChave, cHashChave)
   EndIf


End Sequence

Return lAchou


Function DI500Invoices(oBrw)

LOCAL nInd/*,oDlgSW9*/,nTipo:=2
LOCAL aTelaInv, aGetsInv
Local nOpcOk := 0
PRIVATE cTitInvoice := STR0446	//JWJ 24/06/05 - P/ poder modificar o titulo da janela em RDMAKES
Private aBotoes:={} // DFS - 10/08/2010 - Troca de variável para Private devido a customizações em RdMakes.
Private oDlgSW9 // DFS - Tratamento na declaração para devida customização em RdMake
Private cCadastro := STR0446//Manutenção de Invoices
IF !Inclui .AND. lPrimeiraVez
   IF nPos_aRotina = VISUAL .OR. nPos_aRotina = ESTORNO
      IF Work_SW8->(EasyRecCount("Work_SW8")) == 0
         Processa({|| DI500InvCarrega()},STR0054) //"Pesquisa de Itens"
      ENDIF
   ELSE
      Processa({|| DI500Existe()    },STR0054) //"Pesquisa de Itens"
   ENDIF
ENDIF

IF nPos_aRotina # VISUAL .AND. nPos_aRotina # ESTORNO
   IF WORK->(BOF()) .AND. WORK->(EOF())
      Help("", 1,"AVG0000705")//"Nao ha itens de Pedidos/P.L.I.s para inclusao de Invoices"
      RETURN .T.
   ENDIF
ENDIF

aTB_CposSW9:=ArrayBrowse("SW9","WORK_SW9")

//RMD - 25/09/14 - Incluído campo para visualizar o total de cada Invoice no Browse.
AADD(aTB_CposSW9,{{|| DI500Trans(DI500RetVal("TOT_INV", "WORK", .T.)) },,STR0874, AVSX3("W6_FOB_TOT",6)})  // "Valor Total"

AADD(aTB_CposSW9,{"W9_PESO",,STR0444,AVSX3("W6_PESOL",6)}) //"Peso Total"
//**igor chiba  incluindo campo de titulo erp
IF LCAMBIO_EIC
   AADD(aTB_CposSW9,{"W9_TITERP",,STR0626}) //STR0626 'Título ERP'
ENDIF
aTelaInv:=ACLONE(aTela)
aGetsInv:=ACLONE(aGets)

IF nPos_aRotina # VISUAL
   //IF !lTemCambio .AND. !lAltSoTaxa
      AADD(aBotoes,{'EDIT'   ,{|| DI500W9Manut(1)},STR0031}) //"Incluir"
   //ENDIF
   AADD(aBotoes,{'IC_17'     ,{|| DI500W9Manut(2)},STR0032}) //"Alterar"
   IF !ValidCambio(.F.)// .AND. !lAltSoTaxa                                      //NCF - 29/10/2009 - Chamada da Função ValidCambio()
      AADD(aBotoes,{'EXCLUIR',{|| DI500W9Manut(3)},STR0153}) //"Excluir"
   ENDIF
   IF cPaisLoc=="BRA" .AND. !lDISimples .And. !(AVFLAGS("DUIMP") .And. M->W6_TIPOREG == "2") //não é duimp
      AADD(aBotoes,{"PRECO"  ,{|| DI500RegPesq(),oMarkSW9:oBrowse:Refresh() },STR0589,STR0529}) //LRL 25/03/04 -  "Reg.Trib" //LDB 20/06/2006 Chamado 031135 //STR0589 "Regime de Tributacao"
   ENDIF
   AADD(aBotoes,{"SIMULACAO" ,{|| DI500Totais(oMarkSW9)  },STR0382}) //"Totais"
ELSE
   AADD(aBotoes,{"BMPVISUAL" /*'PESQUISA'*/  ,{|| DI500W9Manut(4)},STR0450,STR0533}) //"Visualizacao" -  "Visuali."
   nTipo:=4
ENDIF
AADD(aBotoes,{"PREV" ,{|| oDlgSW9:End()},STR0429/*,STR0512*/}) //"Tela Anterior" -   "Anterior"

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"BROWSE_WORK_SW9"),)

DO WHILE .T.

   aGets:={}
   aTela:={}
   Work_SW9->(DBGOTOP())

   DEFINE MSDIALOG oDlgSW9 TITLE cTitInvoice; //"Manutencao de Invoices"
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 ;
          TO oMainWnd:nBottom-60,oMainWnd:nRight - 10  STYLE nOR(DS_MODALFRAME, WS_POPUP) OF oMainWnd PIXEL

   //by GFP - 30/09/2010 :: 10:53 - Inclusão da função para carregar campos criados pelo usuario.
   aTB_CposSW9 := AddCpoUser(aTB_CposSW9,"SW9","2")

   oMarkSW9:=MSSELECT():New("WORK_SW9",,,aTB_CposSW9,lInverte,cMarca,{15,1,(oDlgSW9:nClientHeight-6)/2,(oDlgSW9:nClientWidth-4)/2})
   oMarkSW9:bAval:={|| DI500W9Manut(nTipo)}
   oMarkSW9:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oMarkSW9:oBrowse:Refresh() //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oDlgSW9:lMaximized := .T.
   //DFS - 31/01/13 - Inclusão de refresh na tela.
   ACTIVATE MSDIALOG oDlgSW9 ON INIT (EnchoiceBar(oDlgSW9,{|| nOpcOk:=1, oDlgSW9:End()},{|| nOpcOk:=0,oDlgSW9:End()},.F.,aBotoes), oMarkSW9:oBrowse:Refresh()) //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   lLoop:=.F.

   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"VALIDA_MANUT_INV"),) // LDR

   IF lLoop
      LOOP
   ENDIF

   EXIT
ENDDO
DBSELECTAREA("Work_SW8")
SET FILTER TO

If !nPos_aRotina = VISUAL .AND. !nPos_aRotina = ESTORNO .AND. nOpcOk == 1
   DI501ATUDI(M->W6_HAWB,,.T.,.T./*lWork*/)  //Atualiza Aba Valores DI conforme dados carregados na Work
EndIf

aTela:=ACLONE(aTelaInv)
aGets:=ACLONE(aGetsInv)
Work->(DBGOTOP())
IF oBrw # NIL
   oBrw:Refresh()
   oBrw:Reset()
ENDIF
RETURN .T.


FUNCTION DI500W9Manut(nTipo)

LOCAL /*oDlgW9Manut,*/cTituto:='',nInd,lErro:=.F.,nOpcao:=0, b, W, n
LOCAL cNomeQtde:=AVSX3("W7_QTDE",5) ,cPictQtde:=AVSX3("W7_QTDE",6)
LOCAL cPictPrec:=AVSX3("W7_PRECO",6),cPictFob :=AVSX3("W6_FOB_TOT",6)
LOCAL nRec:=WORK_SW9->WK_RECNO
LOCAL aValida:={"W9_INVOICE","W9_DT_EMIS","W9_FORN","W9_MOE_FOB","W9_COND_PA","W9_INCOTER"}
LOCAL bValid:={|| DI500InvValid(,,aValida) .And. VerCobInv() .And. DI500MatVld() }
LOCAL aOk:={||IF(EVAL(bValid),(nOpcao:=1,oDlgW9Manut:End()),),"OK"}
LOCAL bCancel:={||nOpcao:=0,oDlgW9Manut:End()}
LOCAL lTopo //25/03/04
LOCAL lInclusao := .F. //ASK - 23/07/07
Local i,j,nI,nPosY, aFieldsSrc, aEstrWKSW8, aFieldsFWB, aColWKSW8, aSeekWKSW8, aFiltWKSW8, cFilFbrwW8 := ""
Local oLayer
Local cBkpWKSW8 := CriaTrab(,.f.)
Local cBkpWork  := CriaTrab(,.f.)

PRIVATE nTipoW9Manut := nTipo
PRIVATE aDarGetsSW9,aCamposSW8:={},nPos_SW8aRotina,aBotaoSW9:=NIL
PRIVATE aPictures:={AVSX3("W9_INLAND" ,6),AVSX3("W9_PACKING",6),AVSX3("W9_DESCONT",6),;
                    AVSX3("W9_FRETEIN",6),AVSX3("W9_OUTDESP",6),AVSX3("W7_PESO",6) }
PRIVATE oEnch2
Private lCarregaSW9 := EasyGParam("MV_INIINV", ,.F.) //LGS-27/11/2013 //DRL - 13/05/09 parametro para manter o carregamento padrao dos campos da Invoice
                                                //no momento da inclusao da segunda invoice para o mesmo processo.

Private oDlgW9Manut // DFS - Troca de declaração para devida customização em RdMakes
Private lDelInvoice := .T. //LGS-31/01/2014 - Valida exclusão da invoice por Ponte de Entrada.
//Nopado por FDR - 13/09/13 - O sistema sempre deve acertar o rateio das despesas
//Private lMarcado := .F. //RRV - 16/11/2012 - Variável para indicar que um item novo foi marcado.

Begin Sequence
nTipo := nTipoW9Manut

If EICLoja()
   aAdd(aValida, "W9_FORLOJ")
EndIf

//Cria backup para o caso de cancelar as alterações feitas na Invoice e nos itens da Invoice
Work_SW8->(TeTempBackup(cBkpWKSW8))
Work->(TeTempBackup(cBkpWork))

DO CASE
CASE nTipo = 1
     cTituto:=STR0447 //"Inclusao"
     nPos_SW8aRotina:=INCLUSAO
     DBSELECTAREA("WORK_SW9")
     IF Bof() .AND. Eof()
        DBSELECTAREA("SW9")
        lCarregaSW9 := .F. //LGS-27/11/2013
        FOR nInd := 1 TO FCount()
            M->&(FIELDNAME(nInd)) := CRIAVAR(FIELDNAME(nInd))
        NEXT
     ELSE
        If(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"SW9_NAOCARREGA"),)        //CCH
           If lCarregaSW9 //CCH
              FOR nInd := 1 TO FCount()
                 M->&(FIELDNAME(nInd)) := FieldGet(nInd)
              NEXT
           Else
              FOR nInd := 1 TO FCount()
                 If Type(M->(FIELDNAME(nInd))) == "C"
                    M->&(FIELDNAME(nInd)) := Space(Len(M->(FieldName(nInd))))
                 ElseIf Type(M->(FIELDNAME(nInd))) == "N"
                    M->&(FIELDNAME(nInd)) := 0
                 ElseIf Type(M->(FIELDNAME(nInd))) == "D"
                    M->&(FIELDNAME(nInd)) := AvCtoD("  /  /  ")
                 EndIf
              NEXT
           EndIf
        M->W9_FOB_TOT := 0
        M->W9_INVOICE := SPACE(LEN(Work_SW9->W9_INVOICE))
        M->W9_TUDO_OK := "2"
        //LRS - 01/03/2018
        M->W9_DESCONT := 0 
        M->W9_SEGURO  := 0 
        M->W9_FRETEIN := 0
        M->W9_INLAND  := 0
        M->W9_PACKING := 0
        M->W9_OUTDESP := 0
        // EOS - 17/11
        M->WK_RECNO   := 0
     EndIf
     IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"MANUT_W9_INC"),)

     IF !lCarregaSW9 //LGS-27/11/2013
       DI500IniciaCapa(M->W6_PO_NUM,.F.,.F.)
     EndIf

CASE nTipo = 2
     cTituto:=STR0448 //"Alteracao"
     nPos_SW8aRotina:=ALTERACAO
     DBSELECTAREA("WORK_SW9")
     IF Bof() .AND. Eof()
        Return .F.
     EndIf

     ValidCambio(.T.)                          //NCF - 29/10/2009 - Chamada da função que verifica a existência de adiantamentos
                                               //                   vinculados ou câmbio liquidado no controle de câmbio

     // TDF - 09/08/10
     If lAltInv == .T.
        lCambInicial  := lTemCambio
        lTemCambio    := .F.
        lAltSoTaxa    := .F.
     EndIF

     FOR nInd := 1 TO FCount()
        M->&(FIELDNAME(nInd)) := FieldGet(nInd)
     NEXT i
     DI500WorkSW8()

     IF (/*lTemCambio*/ValidCambio(.F.) .OR. lAltSoTaxa) .and. !lGravaFin_EIC // ** GFC - 08/12/05 - Caso a geração do cambio seja automatica, os campos poderão ser alterados
        aDarGetsSW9:={"W9_TX_FOB"}
     ElseIf lGravaFin_EIC  .AND.  lAltSoTaxa  .AND. LCAMBIO_EIC  // PLB 11/08/10 - Caso esteja ativada a Integração com o AvInteg alterar somente a Taxa
        aDarGetsSW9:={"W9_TX_FOB"}
     ENDIF

CASE nTipo = 3

	 If EasyEntryPoint("IDI500INV") //LGS-31/01/2014 - Valida exclusão da invoice
      	lDelInvoice := ExecBlock("IDI500INV",.F.,.F.,"PE_EXCLUSAO_INVOICE")
      	If !lDelInvoice
        	Break
      	EndIf
     EndIf

     aOk:={||IF(MSGYESNO(STR0165,STR0141),(nOpcao:=1,oDlgW9Manut:End()),),"OK"}
     cTituto:=STR0449 //"Exclusao"
     aDarGetsSW9:={}
     nPos_SW8aRotina:=ALTERACAO
     DBSELECTAREA("WORK_SW9")
     IF Bof() .AND. Eof()
        Return .F.
     EndIf
     FOR nInd := 1 TO FCount()
        M->&(FIELDNAME(nInd)) := FieldGet(nInd)
     NEXT i

     IF FINDFUNCTION("DI500LoteVal") //AWR
        IF !DI500LoteVal("EXCLUI_LOTE") // AWR - LOTE
           RETURN .F.
        ENDIF
     ENDIF

     DI500WorkSW8()

CASE nTipo = 4
     cTituto:=STR0450 //"Visualizacao"
     aOk:={||nOpcao:=0,oDlgW9Manut:End(),STR0421} //"Sair"
     bCancel:={||nOpcao:=0,oDlgW9Manut:End(),STR0421}
     nPos_SW8aRotina:=VISUAL
     SW9->(DBGOTO(nRec))
     DBSELECTAREA("WORK_SW9")
     IF Bof() .AND. Eof()
        Return .F.
     EndIf
     FOR nInd := 1 TO FCount()
        M->&(FIELDNAME(nInd)) := FieldGet(nInd)
     NEXT i
     DI500WorkSW8()
ENDCASE

lSair := .F.
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"MANUT_SW9"),)
IF lSair
   Return .T.
ENDIF
// **igor chiba
IF LCAMBIO_EIC
   IF nTipoW9Manut <> 1  .AND.  nTipoW9Manut <> 4
      SWB->(DBSETORDER(1))
      cFilSWB:=XFILIAL('SWB')
      IF Work_SW9->WK_RECNO <> 0 // ou seja estamos na alteraçao
         IF EMPTY(WORK_SW9->W9_TITERP) .AND. lEICFI06
            MSGINFO(STR0615+WORK_SW9->W9_INVOICE+STR0627) //STR0615 "A invoice " //STR0627 "nao pode ser manipulada por nao possuir título."
            RETURN .F.
         ENDIF

         IF SWB->(DBSEEK(cFilSWB+M->W6_HAWB+AVKEY('D','WB_PO_DI')+WORK_SW9->W9_INVOICE))
            DO WHILE SWB->(!EOF()) .AND. SWB->WB_FILIAL  == cFilSWB;
                                   .AND. SWB->WB_HAWB    == M->W6_HAWB ;
                                   .AND. SWB->WB_PO_DI   == AVKEY('D','WB_PO_DI');
                                   .AND. SWB->WB_INVOICE == WORK_SW9->W9_INVOICE

               //IF EMPTY(SWB->WB_TITERP) .AND. lEICFI05
               //IF IIF(lIntegStat, SWB->WB_TITRET$cNao, EMPTY(SWB->WB_TITERP) ) .AND. lEICFI05  // PLB 15/04/10 - Status de Retorno do ERP
               IF IIF(lIntegStat, SWB->WB_TITRET$cNao, .F. ) .AND. lEICFI05  // PLB 15/04/10 - Status de Retorno do ERP
                 //MSGINFO('Invoice: '+WORK_SW9->W9_INVOICE+'nao pode ser manipulada pois seu cambio nao possui título.')
                  MSGINFO(STR0615+WORK_SW9->W9_INVOICE+STR0628)  // PLB 15/04/10 - Status de Retorno do ERP ///STR0615 "A invoice " //str0628 'nao pode ser manipulada pois seu cambio está sem retorno do ERP'
                  RETURN .F.
               ENDIF
               SWB->(DBSKIP())
            ENDDO
         ENDIF
      ENDIF
   ENDIF
ENDIF
// **

IF nTipo # 3 .AND. nTipo # 4
   AADD(aCamposSW8,{"WKFLAGIV"  ,,""})
ENDIF
AADD(aCamposSW8,{"WKPO_NUM"  ,,AVSX3('W8_PO_NUM' ,5)})
AADD(aCamposSW8,{"WKPOSICAO" ,,AVSX3("W8_POSICAO",5)})
AADD(aCamposSW8,{"WKCOD_I"   ,,AVSX3('W8_COD_I'  ,5)})
AADD(aCamposSW8,{"WKPART_N"  ,,IF(SW3->(FieldPos('W3_PART_N')) # 0,AVSX3('W3_PART_N',5),AVSX3('A5_CODPRF',5))})  //NCF - 30/10/2009 - Adição do campo de Part-Number na Invoice
AADD(aCamposSW8,{"WKDESCITEM",,LEFT(AVSX3('B1_DESC',5),9)})                                                      //NCF - 30/10/2009 - Adição do campo de descrição do item na invoice
AADD(aCamposSW8,{"WKFABR"    ,,AVSX3('W8_FABR'   ,5)})
If EICLoja()
   AADD(aCamposSW8,{"W8_FABLOJ",, AVSX3('W8_FABLOJ'   ,5)})
EndIf
AADD(aCamposSW8,{"WKQTDE"    ,,AVSX3("W8_QTDE"   ,5),cPictQtde})
IF AvFlags("EIC_EAI")   //SSS - REQ. 6.2 - 27/06/2014 - Unidade de Medida do Fornecedor no processo de importação
   AADD(aCamposSW8,{"WKUNI"    ,,AVSX3("W3_UM"     ,5)})
   AADD(aCamposSW8,{"WKQTSEGUM",,AVSX3("W3_QTSEGUM",5),AVSX3("W3_QTSEGUM",6)})
   AADD(aCamposSW8,{"WKSEGUM"  ,,AVSX3("W3_SEGUM"  ,5)})
   AADD(aCamposSW8,{"WKFATOR"  ,,"Fator Conv 2UM",AVSX3("J5_COEF",6) })
ENDIF
AADD(aCamposSW8,{"WKUNID"    ,,AVSX3("W8_UNID"   ,5),AVSX3("W8_UNID",6)})
AADD(aCamposSW8,{"WKPRECO"   ,,AVSX3("W8_PRECO"  ,5),cPictPrec})
AADD(aCamposSW8,{"WKPRTOTMOE",,AVSX3("W9_FOB_TOT",5),cPictFob })
If lIntDraw
   AADD(aCamposSW8,{"WKAC"  ,,AVSX3("W8_AC" ,5)})
ENDIF
AADD(aCamposSW8,{"WKINLAND"  ,,AVSX3("W8_INLAND" ,5),aPictures[1]})
AADD(aCamposSW8,{"WKPACKING" ,,AVSX3("W8_PACKING",5),aPictures[2]})
AADD(aCamposSW8,{"WKDESCONT" ,,AVSX3("W8_DESCONT",5),aPictures[3]})
AADD(aCamposSW8,{"WKFRETEIN" ,,AVSX3('W8_FRETEIN',5),aPictures[4]})
AADD(aCamposSW8,{"WKOUTDESP" ,,AVSX3("W8_OUTDESP",5),aPictures[5]})
// EOB - 20/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
IF lSegInc
   AADD(aCamposSW8,{"WKSEGURO" ,,AVSX3("W8_SEGURO",5),AVSX3("W8_SEGURO",6)})
ENDIF
AADD(aCamposSW8,{"WKPESO_L"  ,"WKPESO_L",AVSX3("W7_PESO"   ,5),aPictures[6]})
//FSM - 01/09/2011 - "Peso Bruto Unitário"
If lPesoBruto
   AADD(aCamposSW8,{"WKW8PESOBR" ,"WKW8PESOBR",AVSX3("W8_PESO_BR" ,5),AVSX3("W8_PESO_BR" ,AV_PICTURE)})
EndIf

AADD(aCamposSW8,{"WKPESOTOT" ,"WKPESOTOT",STR0444           ,AVSX3("W7_PESO",6)}) //"Peso Total"
AADD(aCamposSW8,{"WKTEC"     ,,AVSX3("W8_TEC"    ,5)})
IF !(AvFlags("DUIMP") .AND. M->W6_TIPOREG=="2")
    AADD(aCamposSW8,{"WKADICAO" ,,AVSX3("W8_ADICAO" ,5)})
    AADD(aCamposSW8,{"WKSEQ_ADI",,AVSX3("W8_SEQ_ADI",5)})
EndIf    
IF lTemAdicao .AND. !lDISimples
   aBox:=ComboX3Box("EIJ_TACOII")
   cBox:="{||"
   For B:=1 To Len(aBox)
       cBox += "IF(Work_SW8->WKTACOII == '"+Substr(aBox[B],1,At("=",aBox[B])-1)+"','"+Substr(aBox[B],At("=",aBox[B])+1)+"',"
   Next
   cBox+="''"+Replic(")",Len(aBox))+"}"
   bBox:=&(cBox)
   AADD(aCamposSW8,{{|| DI500DescRegTri(Work_SW8->WKREGTRI)},,AVSX3('EIJ_REGTRI',5)})
   AADD(aCamposSW8,{"WKFUNREG",,AVSX3("EIJ_FUNREG",5)})
   AADD(aCamposSW8,{bBox,,AVSX3("EIJ_TACOII",5)})
   AADD(aCamposSW8,{"WKACO_II",,AVSX3("EIJ_ACO_II",5)})
ENDIF
AADD(aCamposSW8,{"WKOPERACA",,"Operacao"})
IF lAUTPCDI
   AADD(aCamposSW8,{"WKREG_PC",,AVSX3("W8_REG_PC",5),AVSX3("W8_REG_PC",6)})
   AADD(aCamposSW8,{"WKFUN_PC",,AVSX3("W8_FUN_PC",5),AVSX3("W8_FUN_PC",6)})
   AADD(aCamposSW8,{"WKFRB_PC",,AVSX3("W8_FRB_PC",5),AVSX3("W8_FRB_PC",6)})
ELSEIF lMV_PIS_EIC
   AADD(aCamposSW8,{"WKPERPIS",,AVSX3("W8_PERPIS",5),AVSX3("W8_PERPIS",6)})
   AADD(aCamposSW8,{"WKPERCOF",,AVSX3("W8_PERCOF",5),AVSX3("W8_PERCOF",6)})
   AADD(aCamposSW8,{"WKVLUPIS",,AVSX3("W8_VLUPIS",5),AVSX3("W8_VLUPIS",6)})
   AADD(aCamposSW8,{"WKVLUCOF",,AVSX3("W8_VLUCOF",5),AVSX3("W8_VLUCOF",6)})
ENDIF


IF lExiste_Midia .AND. lPesoMid   // LDR - 25/08/04
   AADD(aCamposSW8,{"WKQTMIDIA",,"Qtde. Midia",AVSX3("B1_QTMIDIA",6)})
   AADD(aCamposSW8,{"WKVL_TOTM",,"Valor Tot Midia",AVSX3("W8_QTDE",6)})
   AADD(aCamposSW8,{"WKPES_MID",,"Peso Tot Midia",AVSX3("W8_QTDE",6)})
ENDIF
IF lTemNVE
   AADD(aCamposSW8,{"WKNVE",,AVSX3("W8_NVE",5)})
ENDIF                  
IF lExisteSEQ_ADI //AWR - 18/09/08 NFE
   AADD(aCamposSW8,{"WKGRUPORT",,AVSX3("W8_GRUPORT",5)})
ENDIF

//AOM - 11/04/2011
If lOperacaoEsp
   AADD(aCamposSW8,{"W8_CODOPE",,AVSX3("W8_CODOPE",5),AVSX3("W8_CODOPE",6)})
   AADD(aCamposSW8,{"W8_DESOPE",,AVSX3("W8_DESOPE",5),AVSX3("W8_DESOPE",6)})
EndIF

lAlteraDesp := .T.//Alteracao de INLAND, PACKING, DESCONTO, FRETE, OUTRAS DESPESAS
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"BROWSE_WORK_SW8"),)

aCpoSW9 := {"W9_INCOTER","W9_FREINC","W9_SEGINC","W9_INLAND","W9_PACKING","W9_OUTDESP","W9_DESCONT"}

DO WHILE .T.
   aTela:={}
   aGets:={}

   nOpcao:=0
   aBotaoSW9:=NIL
   IF nTipo == 2 //Alteracao
      nPos_SW8aRotina:=ALTERACAO
      nOpcao :=1
      bCancel:={||nOpcao:=0,oDlgW9Manut:End(),STR0421}
      aBotaoSW9 :={}
      IF lAltDescricao
         AADD(aBotaoSW9,{'EDIT',{|| DI500GetDesc()},STR0451/*,STR0534*/}) //"Alterar Descricao do Item" -   "Alt.Desc"
      ENDIF
      IF !ValidCambio(.F.)/*!lTemCambio*/ .AND. !lAltSoTaxa
         AADD(aBotaoSW9,{"RESPONSA",{|| Processa({||  MarkItW8(oBrwInv,"ALL") /*DI500MarcaAll('Work_SW8',oMarkItens:oBrowse)*/})},STR0427,STR0427}) //"Marca/Desmarca Todos" -  "Marc/Des" //RRV 22/08/2012 - Ajuste para exibir corretamente o botão Marca/Desmarca todos
      ENDIF
      AADD(aBotaoSW9,{"FORM"    ,{|| Processa({|| DI500InvTotais(.T.,.F.,oBrwInv/*oMarkItens:oBrowse*/) })},STR0452/*,STR0535*/}) //"Rateia Despesas" -  "Rateia"
      If lTemLote .And. FindFunction("DI505WizLote")//RMD - 22/09/12 - Nova opção de associação de lotes da fase de LI via Wizard
         AADD(aBotaoSW9,{"MPWIZARD",{|| Processa({|| DI505WizLote() })}, STR0834, STR0833})//"Assistente de inclusão de lotes" - "Lotes"
      EndIf
   ENDIF

   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"TELA_INVOICES"),)
   lTopo:= .F. //LRL 25/03/04
   DEFINE MSDIALOG oDlgW9Manut TITLE cTituto+STR0453  ;  //" de Invoice"
             FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM STYLE nOR(DS_MODALFRAME, WS_POPUP) OF oMainWnd PIXEL

   //RMD - 06/12/21 - Reorganiza as dimensões dos objetos na tela
     oLayer := FWLayer():new()
     oLayer:Init(oDlgW9Manut,.F.)
   /*
     oPanelSW9:= TPanel():New(0, 0, "", oDlgW9Manut,, .F., .F.,,, oMainWnd:nRight-10 , oMainWnd:nBottom-60 )
     oPanelSW9:Align:= CONTROL_ALIGN_ALLCLIENT
   */
   IF nTipo = 1 //Inclui
      //nMeio:=(oPanelSW9:nClientHeight-6)/2
      oLayer:AddLine("PANEL_SW9", 100)
   ELSE
      oLayer:AddLine("PANEL_SW9", 50)
      //nMeio:=INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 )-10
      DBSELECTAREA("Work_SW8")
      Work_SW8->(DBSETORDER(2))
      IF nTipo = 3 .OR. nTipo = 4 // Exclusao ou Alteracao
         If !EICLoja()
            //SET FILTER TO Work_SW8->WKINVOICE+Work_SW8->WKFORN==Work_SW9->W9_INVOICE+Work_SW9->W9_FORN  - NOPADO POR AOM - 27/07/2011
            Work_SW8->(DBEVAL({||  If(Work_SW8->WKINVOICE+Work_SW8->WKFORN==;
                                      Work_SW9->W9_INVOICE+Work_SW9->W9_FORN , ;
                                      Work_SW8->WKFILTRO:="S",Work_SW8->WKFILTRO:="")}))
            //SET FILTER TO Work_SW8->WKFILTRO == "S"  - FSM - 02/08/2011

         Else
            //SET FILTER TO Work_SW8->WKINVOICE+Work_SW8->WKFORN+Work_SW8->W8_FORLOJ==Work_SW9->W9_INVOICE+Work_SW9->W9_FORN+Work_SW9->W9_FORLOJ  - NOPADO POR AOM - 27/07/2011
            Work_SW8->(DBEVAL({||  If(Work_SW8->WKINVOICE+Work_SW8->WKFORN+Work_SW8->W8_FORLOJ==;
                                      Work_SW9->W9_INVOICE+Work_SW9->W9_FORN+Work_SW9->W9_FORLOJ, ;
                                      Work_SW8->WKFILTRO:="S",Work_SW8->WKFILTRO:="")}))
            //SET FILTER TO Work_SW8->WKFILTRO == "S"  - FSM - 02/08/2011
         EndIf

         //Work_SW8->( DbSetFilter({|| Work_SW8->WKFILTRO == 'S'},"Work_SW8->WKFILTRO == 'S'") )  // FSM - 02/08/2011
         cFilFbrwW8 := "Work_SW8->WKFILTRO == 'S'"
      ELSE
         // SVG - 13/07/09 -
         If ("CTREE" $ RealRDD())
            If !EICLoja()
               Work_SW8->(DBEVAL({||;
               If((Work_SW8->WKINVOICE == SPACE(LEN(Work_SW8->WKINVOICE)).AND.;
                   Work_SW8->WKFORN+Work_SW8->WKMOEDA == Work_SW9->W9_FORN+Work_SW9->W9_MOE_FOB) .OR.;
                   Work_SW8->WKINVOICE+Work_SW8->WKFORN == Work_SW9->W9_INVOICE+Work_SW9->W9_FORN , ;
                   Work_SW8->WKFILTRO:="S",Work_SW8->WKFILTRO:="")}))
               //SET FILTER TO Work_SW8->WKFILTRO == "S" - FSM - 02/08/2011
            Else
               Work_SW8->(DBEVAL({||;
               If((Work_SW8->WKINVOICE == SPACE(LEN(Work_SW8->WKINVOICE)).AND.;
                   Work_SW8->WKFORN+Work_SW8->W8_FORLOJ+Work_SW8->WKMOEDA == Work_SW9->W9_FORN+Work_SW9->W9_FORLOJ+Work_SW9->W9_MOE_FOB) .OR.;
                   Work_SW8->WKINVOICE+Work_SW8->WKFORN+Work_SW8->W8_FORLOJ == Work_SW9->W9_INVOICE+Work_SW9->W9_FORN+Work_SW9->W9_FORLOJ , ;
                   Work_SW8->WKFILTRO:="S",Work_SW8->WKFILTRO:="")}))
               //SET FILTER TO Work_SW8->WKFILTRO == "S" - FSM - 02/08/2011
            EndIf

            //Work_SW8->( DbSetFilter({|| Work_SW8->WKFILTRO == 'S'},"Work_SW8->WKFILTRO == 'S'") )  // FSM - 02/08/2011
            cFilFbrwW8 := "Work_SW8->WKFILTRO == 'S'"

         Else
            If !EICLoja()
               // SET FILTER TO (Work_SW8->WKINVOICE == SPACE(LEN(Work_SW8->WKINVOICE)) .AND. Work_SW8->WKFORN+Work_SW8->WKMOEDA == Work_SW9->W9_FORN+Work_SW9->W9_MOE_FOB) .OR.  Work_SW8->WKINVOICE+Work_SW8->WKFORN == Work_SW9->W9_INVOICE+Work_SW9->W9_FORN
               //FDR - 16/07/11
               //FSM - 02/08/2011 - cFiltro := "(Work_SW8->WKINVOICE == '"+Space(Len(Work_SW8->WKINVOICE))+"' .AND. Work_SW8->WKFORN+Work_SW8->WKMOEDA == Work_SW9->W9_FORN+Work_SW9->W9_MOE_FOB) .OR.  Work_SW8->WKINVOICE+Work_SW8->WKFORN == Work_SW9->W9_INVOICE+Work_SW9->W9_FORN"
               Work_SW8->(DBEVAL({|| If((Work_SW8->WKINVOICE == SPACE(LEN(Work_SW8->WKINVOICE)) .AND. Work_SW8->WKFORN+Work_SW8->WKMOEDA == Work_SW9->W9_FORN+Work_SW9->W9_MOE_FOB) .OR.  Work_SW8->WKINVOICE+Work_SW8->WKFORN == Work_SW9->W9_INVOICE+Work_SW9->W9_FORN,;
                                         Work_SW8->WKFILTRO:="S",Work_SW8->WKFILTRO:="")}))
            Else
               //SET FILTER TO (Work_SW8->WKINVOICE == SPACE(LEN(Work_SW8->WKINVOICE)) .AND. Work_SW8->WKFORN+Work_SW8->W8_FORLOJ+Work_SW8->WKMOEDA == Work_SW9->W9_FORN+Work_SW9->W9_FORLOJ+Work_SW9->W9_MOE_FOB) .OR.  Work_SW8->WKINVOICE+Work_SW8->WKFORN+Work_SW8->W8_FORLOJ == Work_SW9->W9_INVOICE+Work_SW9->W9_FORN+Work_SW9->W9_FORLOJ
               //FDR - 16/07/11
               //FSM - 02/08/2011 - cFiltro := "(Work_SW8->WKINVOICE == '"+Space(Len(Work_SW8->WKINVOICE))+"' .AND. Work_SW8->WKFORN+Work_SW8->W8_FORLOJ+Work_SW8->WKMOEDA == Work_SW9->W9_FORN+Work_SW9->W9_FORLOJ+Work_SW9->W9_MOE_FOB) .OR.  Work_SW8->WKINVOICE+Work_SW8->WKFORN+Work_SW8->W8_FORLOJ == Work_SW9->W9_INVOICE+Work_SW9->W9_FORN+Work_SW9->W9_FORLOJ"

               Work_SW8->(DBEVAL({|| If((Work_SW8->WKINVOICE == SPACE(LEN(Work_SW8->WKINVOICE)) .AND. Work_SW8->WKFORN+Work_SW8->W8_FORLOJ+Work_SW8->WKMOEDA == Work_SW9->W9_FORN+Work_SW9->W9_FORLOJ+Work_SW9->W9_MOE_FOB) .OR.  Work_SW8->WKINVOICE+Work_SW8->WKFORN+Work_SW8->W8_FORLOJ == Work_SW9->W9_INVOICE+Work_SW9->W9_FORN+Work_SW9->W9_FORLOJ,;
                                         Work_SW8->WKFILTRO:="S",Work_SW8->WKFILTRO:="")}))

            EndIf

            //Work_SW8->(DbSetFilter( {|| Work_SW8->WKFILTRO == 'S'},"Work_SW8->WKFILTRO == 'S'")) //FSM - 10/08/2011
            cFilFbrwW8 := "Work_SW8->WKFILTRO == 'S'"

         EndIf
      ENDIF
      Work_SW8->(DBGOTOP())

      //MODO ANTIGO - Uso de MsSelect (nao permite implementação de filtro e pesuqisa dinâmica)
      /*==========================================================================================================
      oMarkItens:=MSSELECT():New('Work_SW8',IF(nTipo#3,'WKFLAGIV',),,aCamposSW8,lInverte,cMarca,{nMeio,1,(oDlgW9Manut:nClientHeight-6)/2,(oDlgW9Manut:nClientWidth-4)/2})
      oMarkItens:oBrowse:bWhen:={|| DBSELECTAREA('Work_SW8'),.T.}
      IF nTipo # 3 .AND. nTipo # 4 .AND. If(lTemAdicao, !ValidCambio(.F.), .T.) //.AND. !lAltSoTaxa
         oMarkItens:bAval:={|| DI500SW8Get()}
      ELSE
         oMarkItens:bAval:={|| .T. }
      ENDIF
      lTopo:=.T.
      oMarkItens:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT //Alinhamento MDI
      */

      //MODO NOVO - Uso do objeto FWBrowse para aproveitamento de interface com pesquisa e filtro dinâmicos.
      //==========================================================================================================
      //Inicializa variaveis e obtem o array da estrutura principal dos campos da tabela de itens da invoice (SW8)
      aFieldsSrc := {"WKPO_NUM","WKCOD_I","WKFABR"}
      aEstTmpSW8 := ("Work_SW8")->(dbStruct())
      aEstrWKSW8 := {}
      aIndcWKSW8 := GetIndWKW8()
      aFieldsFWB := {}
      aColWKSW8  := {}
      aSeekWKSW8 := {}
      aFiltWKSW8 := {}
      
      //Percorre o array dos campos a serem mostrados na tela para carregar a estrutura destes campos e montar o array de filtros da tela
      For i:=1 To Len(aCamposSW8)                                                                                              //Campos que devem aparecer na tela
         If Valtype(aCamposSW8[i][1])=="C" .And. ( nPosW := aScan( aEstTmpSW8 , {|x| x[1] ==  aCamposSW8[i][1] } ) ) > 0       //Loc. do campo no array de estrutura dos campos (somente campos declarados no aCampos como Caracter)
            If ( nPosX := aScan(aCorrespW8,{|y| y[2]==aEstTmpSW8[nPosW][1] }) ) > 0                                            //Loc. do campo no array de correspondencia campos Work x Tabela (SW8)
               aAdd(aEstrWKSW8,aEstTmpSW8[nPosW])
               nPosY := Len(aEstrWKSW8)
               aSize(aEstrWKSW8[nPosY],Len(aEstrWKSW8[nPosY])+2)

               aEstrWKSW8[nPosY][Len(aEstrWKSW8[nPosY])-1] := IF(aCorrespW8[nPosX][1]=="WKPESOTOT",STR0444,AVSX3(aCorrespW8[nPosX][1],AV_TITULO))
               aEstrWKSW8[nPosY][Len(aEstrWKSW8[nPosY])  ] := IF(aCorrespW8[nPosX][1]=="WKPESOTOT",AVSX3("W7_PESO",AV_PICTURE)       ,AVSX3(aCorrespW8[nPosX][1],AV_PICTURE))

               aAdd(aFieldsFWB,aEstrWKSW8[nPosY][1])
               aAdd(aFiltWKSW8,{aEstrWKSW8[nPosY][1] , aEstrWKSW8[nPosY][5] , aEstrWKSW8[nPosY][2] , aEstrWKSW8[nPosY][3] , aEstrWKSW8[nPosY][4],""})     /* Campos usados no filtro */  
            EndIf
         EndIf     
      Next i

      //Monta o array estruturado conforme os índices da tabela para montar a pesquisa.
      For i:=1 To Len(aIndcWKSW8)
         aTmpKey := EasyQuebraChave(aIndcWKSW8[i],.F.)
         cNameIndex := ""
         aIdCampos  := {}
         For j:=1 To Len(aTmpKey)
            If ( nPosW := aScan(aEstrWKSW8,{|x|x[1]==aTmpKey[j]}) ) > 0
               cNameIndex += aEstrWKSW8[ nPosW ][5] + If(j<Len(aTmpKey), "+", "")
               aMontCpos  := { aTmpKey[j] , aEstrWKSW8[ nPosW ][2] , aEstrWKSW8[ nPosW ][3] , aEstrWKSW8[ nPosW ][4] , aEstrWKSW8[ nPosW ][5] , aEstrWKSW8[ nPosW ][6] }
            Else
               If( nPosX := aScan( aCorrespW8 , {|x| x[2] == aTmpKey[j] } ) ) > 0
                  cNameIndex += AvSX3( aCorrespW8[nPosX][1] , AV_TITULO ) + If(j<Len(aTmpKey), "+", "")
                  aMontCpos  := { aTmpKey[j] , AvSX3( aCorrespW8[nPosX][1] , AV_TIPO ) , AvSX3( aCorrespW8[nPosX][1] , AV_TAMANHO ) , AvSX3( aCorrespW8[nPosX][1] , AV_DECIMAL ) , AvSX3( aCorrespW8[nPosX][1] , AV_TITULO ) , AvSX3( aCorrespW8[nPosX][1] , AV_PICTURE ) }
               EndIf
            EndIf
            aAdd(aIdCampos,aMontCpos )
         Next j
         aAdd(aSeekWKSW8, {cNameIndex, aIdCampos, i})                                                                             /* Campos usados na pesquisa */ 
      Next i
      
      oLayer:AddLine("PANEL_SW8", 50)
      cTitFBrwSW8 := STR0911   //Space(177) + cSTR00XX  //"Itens da Invoice"
      //Cria a instancia do objeto FWBrowse
      oBrwInv:=FWBrowse():New(oLayer:GetLinePanel("PANEL_SW8")/*oPanelSW9*/)
      oBrwInv:SetDescription(cTitFBrwSW8)    
      oBrwInv:SetDataTable( "WORK_SW8" )
      oBrwInv:SetAlias( "WORK_SW8" )
      oBrwInv:SetProfileID("BRWORKSW8")

      If nTipo # 3
         // Cria uma coluna de marca/desmarca
         bMarkOneW8		:= {|oBrwInv| MarkItW8(oBrwInv,"ONE") }
         bMarkAllW8  	:= {|oBrwInv| MarkItW8(oBrwInv,"ALL") }
         oColumn := oBrwInv:AddMarkColumns({|| If(Empty(Work_SW8->WKFLAGIV), 'LBNO', 'LBOK') },bMarkOneW8,bMarkAllW8)            
      EndIf

      For nI := 1 To Len(aEstrWKSW8)                   
         If aScan(aFieldsFWB,{|x| x == aEstrWKSW8[nI][1]}) > 0                  
            oColumn := FWBrwColumn():New()                
            oColumn:SetType(   aEstrWKSW8[nI][2] )
            oColumn:SetTitle(  aEstrWKSW8[nI][5] )
            oColumn:SetSize(   aEstrWKSW8[nI][3] )
            oColumn:SetDecimal(aEstrWKSW8[nI][4] )
            oColumn:SetPicture(aEstrWKSW8[nI][6] )
            oColumn:SetData(&('{ || ' + ("Work_SW8")->(aEstrWKSW8[nI,1]) + ' }'))
            aAdd(aColWKSW8,oColumn)                       
         EndIf           
      Next nI
    
      //aSort(aFiltWKSW8, , , { | x,y | x[2] < y[2] } ) // Ordenação dos campos de filtro por ordem crescente dos títulos
      
      oBrwInv:SetSeek(,aSeekWKSW8)        /* Monta Pesquisa */
      oBrwInv:SetUseFilter()              /* Habilita o Filtro */
      oBrwInv:SetFieldFilter(aFiltWKSW8)  /* Monta o Filtro */       
      oBrwInv:SetColumns(aColWKSW8)       /* Monta as colunas */

      If !Empty(cFilFbrwW8)
         oBrwInv:AddFilter( 'Default' , cFilFbrwW8 , .T. , .T. )  /* Adiciona o filtro default do legado */
      EndIf

      oBrwInv:Activate()
      oBrwInv:Refresh()
      //===================================================================================================================================================

      IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"SELECT_INVOICES"),)
   ENDIF

   //oEnCh2:=MsMGet():New("SW9",nRec,nPos_SW8aRotina,,,,,{15,1,nMeio,(oDlgW9Manut:nClientWidth-4)/2 },aDarGetsSW9,3,,,,,,,,,,.T.) //FSM 12/08/2011 - Tratamento para habilitar o campo W9_INVOICE quando inclusão
   //nAltMsget := (oPanelSW9:nClientHeight/4)+15
   oEnCh2:=MsMGet():New("SW9",nRec,nPos_SW8aRotina,,,,,PosDlg(oLayer:GetLinePanel("PANEL_SW9"))/*{15,1,nAltMsget,0}*/,aDarGetsSW9,3,,,,oLayer:GetLinePanel("PANEL_SW9"),,,,,,.T.)

   M->W9_NOM_FOR:=BuscaFabr_Forn(M->W9_FORN, M->W9_FORLOJ)
   //lTopo:= nTipo <> 1
   //oEnch2:oBox:Align := if(lTopo,CONTROL_ALIGN_TOP,CONTROL_ALIGN_ALLCLIENT)//BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oEnch2:oBox:Align := CONTROL_ALIGN_ALLCLIENT

   //Jacomo lisa - 15/07/2014 - Adicionada a validação quando for integrada do Logix, não permitir alterar certos campos quando possuir uma parcela liquidada
   IF AvFlags("EIC_EAI") .and. nTipo == 2 .AND. ValidCambio(.F.)
      FOR n := 1 to LEN(aCpoSW9)
         IF (nPosSW9 := ascan(oEnch2:AENTRYCTRLS, {|x| aCpoSW9[n] $ x:CREADVAR}) ) > 0
            oEnCh2:AENTRYCTRLS[nPosSW9]:BWHEN := {|| .F.}
         ENDIF
      NEXT
      IF AvRetInco(M->W9_INCOTER,"CONTEM_FRETE")
         IF (nPosSW9 := ascan(oEnch2:AENTRYCTRLS, {|x| "W9_FRETEIN" $ x:CREADVAR}) ) > 0
            oEnCh2:AENTRYCTRLS[nPosSW9]:BWHEN := {|| .F.}
         ENDIF
      ENDIF
      IF AvRetInco(M->W9_INCOTER,"CONTEM_SEG")
         IF (nPosSW9 := ascan(oEnch2:AENTRYCTRLS, {|x| "W9_SEGURO" $ x:CREADVAR}) ) > 0
            oEnCh2:AENTRYCTRLS[nPosSW9]:BWHEN := {|| .F.}
         ENDIF
      ENDIF
   ENDIF

   //oPanelSW9:Align:= CONTROL_ALIGN_ALLCLIENT
   oDlgW9Manut:lMaximized:=.T. //LRL 25/03/04 - Maximiliza Janela MDI
   ACTIVATE MSDIALOG oDlgW9Manut ON INIT (If(nTipo <> 1,/*oMarkItens:oBrowse:Refresh()*/,), EnchoiceBar(oDlgW9Manut,aOk,bCancel,.F.,aBotaoSW9)) //LRL 25/03/04 - Alinhamento MDI //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   IF nOpcao == 1
      lGravaSoCapa:=.F.
      IF nTipo = 1  //Inclui
         IF !DI500WorkSW8()
            Help("", 1,"AVG0000706")//"Nao ha Itens de Pedidos e P.L.I.s para esse Fornecedor e Moeda"
            LOOP
         ENDIF

         WORK_SW9->(DBAPPEND())
         AVReplace("M","WORK_SW9")
         WORK_SW9->W9_HAWB:= M->W6_HAWB//TDF 06/12/2010 - FORÇA A GRAVAÇÃO DO HAWB
         If Empty(WORK_SW9->W9_TX_FOB) .And. lBuscaTaxaAuto .And. MsgYesNo(STR0629 +ENTER+ STR0630) //SVG - 01/06/2011 - //STR0629 "Taxa da Invoice não informada. " //STR0630 "Deseja que o sistema preencha automaticamente?"
            WORK_SW9->W9_TX_FOB:=BuscaTaxa(WORK_SW9->W9_MOE_FOB,DI500DtTxInv(),.T.,.F.,.T.)
            M->W9_TX_FOB:=BuscaTaxa(M->W9_MOE_FOB,DI500DtTxInv(),.T.,.F.,.T.) //Para visualização na tela de marcação do item.
         EndIf

         IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"APPEND_INVOICES"),)
         nTipo:=2
         lInclusao:= .T. //ASK - 23/07/07
         LOOP

      ELSEIF nTipo = 2//Altera
         aDados:={}
         lZera :=.F.
         FOR W := 1 TO WORK_SW9->(FCOUNT())
            AADD(aDados,{WORK_SW9->(FIELDGET(W)),})
            IF !lZera .AND. WORK_SW9->(FIELD(W)) $ "W9_INCOTER,W9_COND_PA,W9_DIAS_PA" .AND.;
               WORK_SW9->(FIELDGET(W)) # EVAL(FieldBlock(WORK_SW9->(FIELD(W))))
               lZera:= .T.
            ENDIF
         NEXT
         AVReplace("M","WORK_SW9")
         WORK_SW9->W9_HAWB:= M->W6_HAWB//TDF 06/12/2010 - FORÇA A GRAVAÇÃO DO HAWB

         Processa( {|| DI500InvTotais(.F.,.F.,,.F.,.F.)} )
         IF DI500InvConf(.T.,Work_SW9->W9_INVOICE,Work_SW9->W9_FORN,.F., WORK_SW9->W9_FORLOJ)
            Processa( {|| DI500InvTotais(.F.,lZera)} )
         ENDIF
         FOR W := 1 TO WORK_SW9->(FCOUNT())
            aDados[W,2]:=WORK_SW9->(FIELDGET(W))
         NEXT
         DI500Controle(2,aDados)
         //** GFC - 05/12/05
         If lWB_TP_CON .and. Empty(Work_SW9->W9_VALCOM) .and. Work_SW9->W9_COMPV == "2"
            Work_SW9->W9_VALCOM := If(Work_SW9->W9_PERCOM<>0, (DI500RetVal("TOT_INV", "WORK", .T.)* Work_SW9->W9_PERCOM)/100, 0) // EOB - 21/05/08 - chamada da função DI500RetVal
         EndIf

      ELSEIF nTipo = 3 //Exclui

         //TRP - 09/11/2011 - Validar a exclusão da Invoice
         IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ANTES_DELETA_INV"),)

         DBSELECTAREA("Work_SW8")
         If !VldOpeDesemb("MARC_EST_IV") //AOM - Operacao especial
           Break
         EndIf
         SET FILTER TO
         Work_SW8->(DBSETORDER(1))
         DO WHILE Work_SW8->(DBSEEK(WORK_SW9->W9_INVOICE+WORK_SW9->W9_FORN+WORK_SW9->W9_FORLOJ))
            DI500InvMarca('D',.F.)
            WORK_SW8->(DBDELETE())
            Work_SW8->(DBSKIP())
         ENDDO
         IF !EMPTY(Work_SW9->WK_RECNO)
            AADD(aDeletados,{"SW9",Work_SW9->WK_RECNO})
         ENDIF
         IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"DELETA_INVOICES"),)
         WORK_SW9->(DBDELETE())
         WORK_SW9->(DBGOTOP())
      ENDIF

   Else //nOpcao == 0 - Clicou no Cancelar
      If nTipo == 2 //Alteração
         Work_SW8->(AvZap())
         Work_SW8->(TERestBackup(cBkpWKSW8))

         Work->(AvZap())
         Work->(TERestBackup(cBkpWork))
      EndIf
   ENDIF
   EXIT
ENDDO

End Sequence
DBSELECTAREA("Work_SW8")
Work_SW8->(DBSETORDER(1))
SET FILTER TO
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"FIM_W9MANUT"),)
DBSELECTAREA("Work_SW9")
oMarkSW9:oBrowse:Refresh()

RETURN .T.

FUNCTION DI500GetDesc()

LOCAL oDLGDescr,lGrava:=.F.,aBotoes:={},lCarrega:=.F.
PRIVATE mDescGet:=Work_SW8->WKDESC_DI
DEFINE FONT oFont NAME "Courier New" SIZE 0,15

AADD(aBotoes,{"BMPINCLUIR" /*"NOVACELULA"*/,{|| lCarrega:=.T.,oDLGDescr:End()},STR0631,STR0536}) //LRL 25/03/04 -  "Descrição" //STR0631 "Carrega Descricao"

DO WHILE .T.

   DEFINE MSDIALOG oDLGDescr TITLE STR0455 From 15,00 To 34,52 OF oMainWnd  //"Alteracao de Descricao"

   oPanel:= TPanel():New(0, 0, "", oDLGDescr,, .F., .F.,,, 90, 165) //MCF - 22/07/2015
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

// @14,2 GET mDescGet SIZE 203,100 PIXEL OF oDLGDescr HSCROLL
   oDLGDescr:SetFont(oFont)
   @08,2 GET mDescGet MEMO HSCROLL SIZE 203,100 OF oPanel PIXEL

   ACTIVATE MSDIALOG oDLGDescr ON INIT EnchoiceBar(oDLGDescr,;
                                       {||lGrava:=.T.,oDLGDescr:End()},;
                                        {||lGrava:=.F.,oDLGDescr:End()},.F.,aBotoes) CENTERED
   IF lCarrega
      IF Empty(mDescGet) .OR. MSGYESNO(STR0632,STR0633)//STR0632 "Deseja sobrepor descricao atual?" //STR0633 "Descricao GI"
         SB1->(dbSetorder(1))
         SB1->(dbSeek(xFilial("SB1")+Work_SW8->WKCOD_I))
         mDescGet:=MSMM(SB1->B1_DESC_GI,AvSx3("B1_VM_GI",3))
         mDescGet:=STRTRAN(mDescGet,CHR(13)+CHR(10),' ')
         IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ALTERA_DESCR_ITEM"),)
      ENDIF
      lCarrega:=.F.
      LOOP
   ENDIF

   IF lGrava
      Work_SW8->WKDESC_DI:=STRTRAN(mDescGet,CHR(13)+CHR(10),' ')
   ENDIF

   EXIT

ENDDO

RETURN lGrava

FUNCTION DI500WorkSW8()

LOCAL nRet:= .F., nRecEIM
LOCAL lTemNVEPLI := .F. //NCF - 07/12/11 - Classificação N.V.A.E na PLI
Local lTemNVECad := .F. //AAF
LOCAL lPrimeiro  := .T. //NCF - 07/12/11 - Classificação N.V.A.E na PLI
Local lMostMsgNVE:= .T.
Local nOrdSW1 := 0
Local nRecSW1 := 0
Local mDescGet := ""  // GFP - 08/07/2013
Local cTmpWrkSW7, cQuery, cSelect, cFrom , cWhere, nOldArea
Local cDescAux
Private nDescItem := 30 //FDR - 15/04/13

DBSELECTAREA("Work_SW8")
SET FILTER TO
Work_SW8->(DBSETORDER(1))

SB1->(dbSetorder(1))
SW2->(DBSETORDER(1))
SW3->(DBSetOrder(8))

WORK->(DBGOTOP())

//ATENCAO: QUALQUER ALTERACAO NA LOGICA DESTA FUNCAO DEVERA SER ANALIZADO SE NAO AFETARA
//O RDMAKE  DA EMBRAER NO PONTO DE ENTRADA "CARREGA_WORK"

cSelect := " SELECT WKSW7.R_E_C_N_O_, SB1.B1_COD, SB1.R_E_C_N_O_ SB1RECNO, SW2.W2_PO_NUM, SW2.R_E_C_N_O_ SW2RECNO, SW3.W3_PO_NUM, SW3.W3_POSICAO, SW3.R_E_C_N_O_ SW3RECNO "
cFrom   := " FROM " + TETempName("WORK") + " WKSW7"
cJoins  := " LEFT JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_COD    = WKSW7.WKCOD_I  AND SB1.B1_FILIAL = '" + SB1->(xFilial()) + "' AND SB1.D_E_L_E_T_ <> '*'"
cJoins  += " LEFT JOIN " + RetSQLName("SW2") + " SW2 ON SW2.W2_PO_NUM = WKSW7.WKPO_NUM AND SW2.W2_FILIAL = '" + SW2->(xFilial()) + "' AND SW2.D_E_L_E_T_ <> '*'"
cJoins  += " LEFT JOIN " + RetSQLName("SW3") + " SW3 ON SW3.W3_PO_NUM = WKSW7.WKPO_NUM AND SW3.W3_POSICAO = WKSW7.WKPOSICAO  AND SW3.W3_SEQ = 0 AND SW3.W3_FILIAL = '" + SW3->(xFilial()) + "' AND SW3.D_E_L_E_T_ <> '*'"
cWhere  := " WHERE" + iIF( TcSrvType()=="AS/400"," WKSW7.@DELETED@ <> '*' "," WKSW7.D_E_L_E_T_ <> '*'" )
cWhere  += " AND WKSW7.WKFLAG    = 'T' "
cWhere  += " AND WKSW7.WKMOEDA   = '"   + M->W9_MOE_FOB +"' "
cWhere  += " AND WKSW7.WKFORN    = '"   + M->W9_FORN    +"' "
cWhere  += " AND WKSW7.W7_FORLOJ = '"   + M->W9_FORLOJ  +"' "

cTmpWrkSW7 := GetNextAlias()
cQuery     := ChangeQuery(cSelect + cFrom  + cJoins + cWhere)
nOldArea   := Select()
MPSysOpenQuery(cQuery, cTmpWrkSW7)
DbSelectArea(cTmpWrkSW7)
lMostMsgNVE := .T.
ProcRegua(10)
DO While (cTmpWrkSW7)->(!Eof())
   WORK->(DbgoTo( (cTmpWrkSW7)->R_E_C_N_O_ ))

   IncProc()
   
   lLoop:=.F.
   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"SKIP_ITEM_SW8"),)
   IF lLoop
      (cTmpWrkSW7)->(DBSKIP())//WORK->(DBSKIP())
      LOOP
   ENDIF

   SB1->(Dbgoto( (cTmpWrkSW7)->SB1RECNO ))//SB1->(dbSeek(xFilial("SB1")+Work->WKCOD_I))
   SW2->(Dbgoto( (cTmpWrkSW7)->SW2RECNO ))//SW2->(DBSEEK(xFILIAL("SW2")+Work->WKPO_NUM))
   SW3->(Dbgoto( (cTmpWrkSW7)->SW3RECNO ))//SW3->(DbSeek(xFilial("SW3")+WORK->WKPO_NUM+WORK->WKPOSICAO))

   IF Work_SW8->(DBSEEK(M->W9_INVOICE+WORK->WKFORN+Work->W7_FORLOJ+WORK->WKPO_NUM+WORK->WKPOSICAO+WORK->WKPGI_NUM))
      Work_SW8->WKSALDO_AT:= Work_SW8->WKQTDE + WORK->WKDISPINV
      Work_SW8->WKSALDO:= 0

      If SW3->(FieldPos("W3_PART_N")) # 0                                 //NCF - 30/10/2009 - Exibição do Part-Number do item da Invoice
         //SW3->(DBSetOrder(8))
         //SW3->(DbSeek(xFilial("SW3") + WORK->WKPO_NUM + WORK->WKPOSICAO))
         If !Empty(SW3->W3_PART_N)
            Work_SW8->WKPART_N:= SW3->W3_PART_N
         Else
            Work_SW8->WKPART_N := SA5->(BuscaPart_N())
         EndIf
      Else
         Work_SW8->WKPART_N := SA5->(BuscaPart_N())
      EndIf

      If Work_SW8->(FIELDPOS("WKDESCITEM")) # 0                            //NCF - 30/10/2009 - Exibição da descrição do item da Invoice
         Work_SW8->WKDESCITEM:= If( Empty( cDescAux := MSMM(SB1->B1_DESC_P,nDescItem,1)) , SB1->B1_DESC , cDescAux   )
      EndIf

      If Empty(Work_SW8->WKNVE)
         ClassifNVE(lCposNVEPLI,nTipoW9Manut,@lPrimeiro,@lMostMsgNVE,@lTemNVEPLI,@lTemNVECad)
      EndIf

   ELSE
      IF EMPTY(WORK->WKDISPINV)
         (cTmpWrkSW7)->(DBSKIP()) //WORK->(DBSKIP())
         LOOP
      ENDIF
      IF !Work_SW8->(DBSEEK(SPACE(LEN(SW9->W9_INVOICE))+WORK->WKFORN+Work->W7_FORLOJ+WORK->WKPO_NUM+WORK->WKPOSICAO+WORK->WKPGI_NUM))
         Work_SW8->(DBAPPEND())
         //Grava os campos WKPO_NUM,WKPOSICAO,WKPGI_NUM,WKCOD_I,WKFORN,WKFABR,WKPESO_L,
         //WKCC,WKSI_NUM,WKREG,WKSEQ_LI,WKFLUXO,WKREGIST,WKTEC,Work->WKEX_NCM,WKEX_NBM
      ENDIF
      AVREPLACE('Work','Work_SW8')
      Work_SW8->WKINVOICE := Space(Len(Work_SW8->WKINVOICE))  //TRP - 08/07/2010
      //Work_SW8->WKINVOICE :=M->W9_INVOICE //TDF - 21/05/10
      //Work_SW8->WKFORN    :=M->W9_FORN //TDF - 21/05/10
      Work_SW8->WKCOND_PA :=M->W9_COND_PA
      Work_SW8->WKDIAS_PA :=M->W9_DIAS_PA
      Work_SW8->WKTCOB_PA :=Posicione("SY6",1,xFilial("SY6")+M->W9_COND_PA+STR(M->W9_DIAS_PA,3),"Y6_TIPOCOB")
      Work_SW8->WKMOEDA   :=M->W9_MOE_FOB
      Work_SW8->WKINCOTER :=M->W9_INCOTER
      Work_SW8->WKQTDE    :=WORK->WKDISPINV
      Work_SW8->WKPRECO   :=WORK->WKPRECO
      Work_SW8->WKPRTOTMOE:=DI500Trans(WORK->WKPRECO*Work_SW8->WKQTDE)
      Work_SW8->WKSALDO_AT:=WORK->WKDISPINV
      Work_SW8->WKRECNO   :=WORK->(RECNO())
      Work_SW8->WKSALDO   :=0
      Work_SW8->WKUNID    :=TransQtde(0,.T.,,Work_SW8->WKCOD_I,Work_SW8->WKFABR,Work_SW8->WKFORN,Work_SW8->WKCC,Work_SW8->WKSI_NUM, Work_SW8->W8_FABLOJ, Work_SW8->W8_FORLOJ)
      Work_SW8->TRB_ALI_WT:="SW8"
//      Work_SW8->TRB_REC_WT:=SW8->(Recno())

      WORK_SW8->W8_FORLOJ := Work->W7_FORLOJ
      WORK_SW8->W8_FABLOJ := Work->W7_FABLOJ

      //FSM - 01/09/2011 - "Peso Bruto Unitário"
      If lPesoBruto
         Work_SW8->WKW8PESOBR := Work->WKW7PESOBR
      EndIf

      //AOM - Carregando itens da invoice com OPE ESP.
      IF lOperacaoEsp
         WORK_SW8->W8_CODOPE := WORK->W7_CODOPE
         WORK_SW8->W8_DESOPE := Posicione("EJ0",1,xFilial("EJ0") + Work_SW8->W8_CODOPE ,"EJ0_DESC")
      ENDIF

      IF SW8->(FIELDPOS("W8_DT_EMIS"))#0
         Work_SW8->WKDT_EMIS   :=M->W9_DT_EMIS
      ENDIF
      IF lExiste_Midia .AND. lPesoMid   // LDR - 25/08/04
         IF SB1->B1_MIDIA $ cSIM
            Work_SW8->WKQTMIDIA := SB1->B1_QTMIDIA
            Work_SW8->WKVL_TOTM := (WORK_SW8->WKQTDE*SB1->B1_QTMIDIA*SW2->W2_VLMIDIA)
            Work_SW8->WKPES_MID := (Work_SW8->WKQTDE * WORK->WKPESOMID * SB1->B1_QTMIDIA)
         ENDIF
      ENDIF
      If lIntDraw .and. cPaisLoc=="BRA" .and. !Empty(Work_SW8->WKAC)  //GFC 26/11/2003
         ED0->(dbSetOrder(2))
         ED0->(dbSeek(cFilED0+Work_SW8->WKAC))
         Work_SW8->WKREGTRI := If(ED0->ED0_MODAL=="1","5","3")
         Work_SW8->WKFUNREG := "16"
      EndIf
      IF lDiSimples // JBS - 19/11/2003
         Work_SW8->WKADICAO := Work->WK_ADICAO
      ENDIF

      If SW3->(FieldPos("W3_PART_N")) # 0
         If !Empty(SW3->W3_PART_N)
            Work_SW8->WKPART_N:= SW3->W3_PART_N
         Else
            Work_SW8->WKPART_N := SA5->(BuscaPart_N())
         EndIf
      Else
         Work_SW8->WKPART_N := SA5->(BuscaPart_N())
      EndIf

      If Work_SW8->(FIELDPOS("WKDESCITEM")) # 0
         Work_SW8->WKDESCITEM:= If( Empty( cDescAux := MSMM(SB1->B1_DESC_P,nDescItem,1)) , SB1->B1_DESC , cDescAux   )
      EndIf

      // GFP - 08/07/2013 - Carregar descrição do item no momento da inclusão.
      //mDescGet:=MSMM(SB1->B1_DESC_GI,AvSx3("B1_VM_GI",3))
      mDescGet := If( Empty( cDescAux := MSMM(SB1->B1_DESC_GI,AvSx3("B1_VM_GI",3)) ) , SB1->B1_DESC , cDescAux   )
      mDescGet:=STRTRAN(mDescGet,CHR(13)+CHR(10),' ')
      Work_SW8->WKDESC_DI:=STRTRAN(mDescGet,CHR(13)+CHR(10),' ')

      //NCF - 23/02/2011 - Grava a Aliq. do IPI de Pauta para Item da Invoice
      IF Work->WKIPIPAUTA # 0
         Work_SW8->WKIPIPAUTA := Work->WKIPIPAUTA
      ENDIF
	  
      //NCF - 08/08/2011 - Classificação N.V.A.E na PLI      
      ClassifNVE(lCposNVEPLI,nTipoW9Manut,@lPrimeiro,@lMostMsgNVE,@lTemNVEPLI,@lTemNVECad)

	  /*EIM->(DbSetOrder(3))
      If lCposNVEPLI .And. EasyGParam("MV_EIC0011",,.F.) .And. lPrimeiro .And. !Empty(Work->WK_NVE) .And. (nTipoW9Manut == 1 .Or. nTipoW9Manut == 2)
         If MsgYesNo(STR0815 + CHR(13)+CHR(10)+; //"Existem itens marcados no processo que já possuem classificação"
                     STR0816 + CHR(13)+CHR(10)+; //"N.V.A.E. vinda da fase de Pedido de Licença de Importação (LI)!"
                     STR0817 , STR0558) //STR0817" Deseja importar as informações de N.V.A.E. para estes itens ?" STR0558 "Aviso"
            lTemNVEPLI := .T.
            lPrimeiro  := .F.
         Else
            lPrimeiro  := .F.
         EndIf
      
      //MFR 26/11/2018 OSSME-1483   
	  //ElseIf lCposNVEPLI .And. lMostMsgNVE .And. Empty(Work->WK_NVE) .And. (nTipoW9Manut == 1 .Or. nTipoW9Manut == 2) .AND. EIM->(DbSeek(xFilial("EIM")+AvKey("CD","EIM_FASE")+AvKey(Work->WKCOD_I,"EIM_HAWB") )) .And. If(lEIM_NCM,AvKey(Work->WKTEC,"EIM_NCM")==EIM->EIM_NCM,.T.) 
      ElseIf lCposNVEPLI .And. EasyGParam("MV_EIC0011",,.F.) .And. lMostMsgNVE .And. Empty(Work->WK_NVE) .And. (nTipoW9Manut == 1 .Or. nTipoW9Manut == 2) .AND. EIM->(DbSeek(GetFilEIM("CD")+AvKey("CD","EIM_FASE")+AvKey(Work->WKCOD_I,"EIM_HAWB") )) .And. If(lEIM_NCM,AvKey(Work->WKTEC,"EIM_NCM")==EIM->EIM_NCM,.T.) 
	     If MsgYesNo(STR0892 + ENTER + STR0817,STR0804)
            lTemNVECad  := .T.
            lMostMsgNVE := .F.
         Else
            lMostMsgNVE := .F.
         EndIf
      EndIf
      
      If lTemNVEPLI .AND. !Empty(Work->WK_NVE)
      
         TransfNVE("LI")
         Work_SW8->WKNVE := Work->WK_NVE
	  //MFR 26/11/2018 OSSME-1483   	 
	  //ElseIf lTemNVECad .AND. EIM->(DbSeek(xFilial("EIM")+AvKey("CD","EIM_FASE")+AvKey(Work->WKCOD_I,"EIM_HAWB")))
      ElseIf lTemNVECad .AND. EIM->(DbSeek(GetFilEIM("CD")+AvKey("CD","EIM_FASE")+AvKey(Work->WKCOD_I,"EIM_HAWB")))

         TransfNVE("CD")
         Work_SW8->WKNVE := Work->WK_NVE

         WORK_CEIM->(DbAppend())
         Work_CEIM->EIM_CODIGO := Work->WK_NVE
         Work_CEIM->WKTEC      := Work->WKTEC
         lMostMsgNVE := .F.
         lGravaEIM   := .T.
	  
      EndIf
*/
      // BAK - Buscando o codigo da Matriz de Tributação na SI
      If Work_SW8->(FieldPos("WKCODMATRI")) > 0 .And. SW1->(FieldPos("W1_CODMAT")) > 0 .And. AvFlags("SUFRAMA") .And. EasyGParam("MV_TEM_DI", ,.F.)
         nOrdSW1 := SW1->(IndexOrd())
         nRecSW1 := SW1->(Recno())
         SW1->(DbSetOrder(1))
         If Empty(Work_SW8->WKCODMATRI) .And. SW1->(DBSeek(xFILIAL("SW1") + AvKey(Work_SW8->WKCC,"W1_CC") + AvKey(Work_SW8->WKSI_NUM,"W1_SI_NUM") + AvKey(Work_SW8->WKCOD_I,"W1_COD_I") ))
            Work_SW8->WKCODMATRI := SW1->W1_CODMAT
         EndIf
         SW1->(DbSetOrder(nOrdSW1))
         SW1->(DbGoTo(nRecSW1))
      EndIf

   ENDIF
   nRet:= .T.

   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GRAVA_WORK_SW8"),)

   (cTmpWrkSW7)->(DbSkip())
   
ENDDO

(cTmpWrkSW7)->(DbCloseArea())
DbSelectArea(nOldArea)

RETURN nRet

FUNCTION DI500SW8Get()

LOCAL oDlgTela,oFobTotal,cFornecedor,cFabricante,nopca,nRecno:=Work_SW8->(RECNO())
Local i, nPos //AOM - 25/05/2011
Local cAto:=""
Private cCodMatriz := ""
PRIVATE lWkAC:= .F.  //TRP-18/01/08
PRIVATE nFOB_TOT:=0
PRIVATE nL1:=10 ; nC1:=8  ; nC2:=56

Private nTamDlg := 25

IF !DI500Alcada(Work_SW8->WKPO_NUM) //LRS - 07/03/2017
   Return .F.
EndIF

DBSELECTAREA("Work_SW8")
SET FILTER TO

IF lEnvDesp .AND. lMsgEnv
   SWP->(DBSETORDER(1))
   IF SWP->(DBSEEK(xFilial("SWP")+Work_sw8->WKPGI_NUM+Work_sw8->WKSEQ_LI))
      IF !EMPTY(SWP->WP_ENV_ORI)
         MSGINFO(STR0634,STR0141) //STR0634 "Como o arquivo ja foi enviado para o despachante e sera feita uma alteração no item, o arquivo devera ser enviado novamente. " //STR0141 := "Atencao"
         lMsgEnv:=.F.
       ENDIF
    ENDIF
ENDIF

IF !EMPTY(Work_SW8->WKFLAGIV) .and. !lTemCambio
   //AOM - 06/04/2011 - Estorno da Admissao temporaria - Operação Especial
   If !VldOpeDesemb("DESMARCA_IT_INV")
      Return .F.
   EndIf

   IF !DI500LoteVal("TEM_LOTE_AVISO",,,WORK_SW8->(WKFORN+WKPGI_NUM+WKPO_NUM+WKPOSICAO+WKINVOICE))// AWR - Lote
      RETURN .F.// AWR - Lote
   ENDIF
   DI500InvMarca('D')
   DBSELECTAREA("Work_SW8")
   // SVG - 13/07/09 -
   If ("CTREE" $ RealRDD())
      If !EICLoja()
         Work_SW8->(DBEVAL({||;
         If(Work_SW8->WKINVOICE+Work_SW8->WKFORN == M->W9_INVOICE+M->W9_FORN .OR. ;
         (Work_SW8->WKINVOICE == Space(Len(Work_SW8->WKINVOICE)) .AND. Work_SW8->WKFORN+Work_SW8->WKMOEDA == M->W9_FORN+M->W9_MOE_FOB);
         ,Work_SW8->WKFILTRO:="S",Work_SW8->WKFILTRO:="")}))
         SET FILTER TO Work_SW8->WKFILTRO == "S"
      Else
         Work_SW8->(DBEVAL({||;
         If(Work_SW8->WKINVOICE+Work_SW8->WKFORN+Work_SW8->W8_FORLOJ == M->W9_INVOICE+M->W9_FORN+M->W9_FORLOJ .OR. ;
         (Work_SW8->WKINVOICE == Space(Len(Work_SW8->WKINVOICE)) .AND. Work_SW8->WKFORN+Work_SW8->W8_FORLOJ+Work_SW8->WKMOEDA == M->W9_FORN+M->W9_FORLOJ+M->W9_MOE_FOB);
         ,Work_SW8->WKFILTRO:="S",Work_SW8->WKFILTRO:="")}))
         SET FILTER TO Work_SW8->WKFILTRO == "S"
      EndIf
   Else
      If EICLoja()
         SET FILTER TO Work_SW8->WKINVOICE+Work_SW8->WKFORN+Work_SW8->W8_FORLOJ == M->W9_INVOICE+M->W9_FORN+M->W9_FORLOJ .OR. (EMPTY(Work_SW8->WKINVOICE) .AND. Work_SW8->WKFORN+Work_SW8->W8_FORLOJ+Work_SW8->WKMOEDA == M->W9_FORN+M->W9_FORLOJ+M->W9_MOE_FOB)
      Else
         SET FILTER TO Work_SW8->WKINVOICE+Work_SW8->WKFORN == M->W9_INVOICE+M->W9_FORN .OR. (EMPTY(Work_SW8->WKINVOICE) .AND. Work_SW8->WKFORN+Work_SW8->WKMOEDA == M->W9_FORN+M->W9_MOE_FOB)
      EndIf
   EndIf

   Work_SW8->(DBGOTO(nRecno))
   oBrwInv:Refresh()//oMarkItens:oBrowse:Refresh()
   RETURN .T.
ENDIF

SA2->(DBSETORDER(1))
SA2->(DBSEEK(xFilial("SA2")+Work_SW8->WKFORN+Work_SW8->W8_FORLOJ))
cFornecedor:=SA2->A2_NREDUZ

SA2->(DBSEEK(xFilial("SA2")+Work_SW8->WKFABR+Work_SW8->W8_FABLOJ))
cFabricante:=SA2->A2_NREDUZ

nSaldo   :=Work_SW8->WKQTDE
nPreco   :=Work_SW8->WKPRECO
nInland  :=Work_SW8->WKINLAND
nPacking :=Work_SW8->WKPACKING
nDesconto:=Work_SW8->WKDESCONT
nFrete   :=Work_SW8->WKFRETEIN
nOutDesp :=Work_SW8->WKOUTDESP
// EOB - 20/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
IF lSegInc
	nSeguro := Work_SW8->WKSEGURO
ENDIF
cAdicao  :=Work_SW8->WKADICAO

//AOM - 11/04/2011
If lOperacaoEsp
   cCodOpe  := Work_SW8->W8_CODOPE
EndIF

IF lVlUnid // LDR - OC - 0048/04 - OS - 0989/04
   IF EMPTY(Work_SW8->WKQTDE_UM)
      nQtde_Um:=DI500UNID(Work_SW8->WKCOD_I,Work_SW8->WKFABR,Work_SW8->WKFORN, Work_SW8->W8_FABLOJ, Work_SW8->W8_FORLOJ)
   ELSE
      nQtde_Um:=Work_SW8->WKQTDE_UM
   ENDIF
ENDIF

nFobTotal:=DI500Trans(nSaldo * nPreco)

// BAK - Armazenando o codigo da Matriz de Tributação informado na Invoice
If Work_SW8->(FieldPos("WKCODMATRI")) > 0 .And. AvFlags("SUFRAMA") .And. EasyGParam("MV_TEM_DI", ,.F.)
   If !Empty(Work_SW8->WKCODMATRI)
      cCodMatriz := Work_SW8->WKCODMATRI
   Else
      cCodMatriz := Space(AvSX3("W8_CODMAT",AV_TAMANHO))
   EndIf
EndIf

//TLM 03/01/2008 Criação da variavel lWKAC para personalização da MSDIALOG oDlgTela.
If lIntDraw
   lWkAC:=!Empty(Work_SW8->WKAC)
Endif

//AOM - 25/05/2011 - Carregar a Memória com os campos nomeados igual ao dicionário de acordo com o Arraya "CorrespW8"
For i := 1 To Work_SW8->(FCount())
   If (nPos := Ascan(aCorrespW8, {|x| AllTrim(x[2]) == AllTrim(Work_SW8->(FIELDNAME(i)))})) > 0 .And. aCorrespW8[nPos][1] <> "W9_FOB_TOT"
      M->&(aCorrespW8[nPos][1]) := Work_SW8->(FieldGet(i))
   EndIf
Next i


IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"INICIA_GET_ITEM_INVOICE"),)

DEFINE MSDIALOG oDlgTela TITLE STR0456 From 00,00 To nTamDlg,50 OF oMainWnd  //"Seleciona Item da Invoice"

  @nL1,nC1 SAY AVSX3("W7_COD_I",5)   SIZE 40,8 PIXEL
  @nL1,nC2 MSGET Work_SW8->WKCOD_I   PICTURE AVSX3("W7_COD_I",6) SIZE 107,08 PIXEL WHEN .F.
   nL1+=13
  @nL1,nC1 SAY AVSX3("W7_FABR",5)    SIZE 40,8 PIXEL//'Fabricante'
  @nL1,nC2 MSGET cFabricante PICTURE '@!'  SIZE 107,08 PIXEL WHEN .F.
   nL1+=13
  @nL1,nC1 SAY AVSX3("W7_FORN",5)    SIZE 40,8 PIXEL//'Fornecedor'
  @nL1,nC2 MSGET cFornecedor PICTURE '@!' SIZE 107,08 PIXEL WHEN .F.
   nL1+=13
  @nL1,nC1 SAY AVSX3("W7_SALDO_Q",5) SIZE 40,08 PIXEL//Saldo Qtde
  @nL1,nC2 MSGET nSaldo   PICTURE _PictQtde VALID DI500InvValid('SALDO',oFobTotal) SIZE 107,08 PIXEL WHEN !ValidCambio(.f.,"Itens")//!lTemCambio
   nL1+=13
  IF AvFlags("EIC_EAI")
     @nL1,nC1 SAY "Unidade" SIZE 40,08 PIXEL//Unidade //AWF - 01/07/2014
     @nL1,nC2 MSGET Work_SW8->WKUNI SIZE 107,08 PIXEL WHEN .F.
     nL1+=13
  EndIf
  @nL1,nC1 SAY AVSX3("W8_PRECO",5)   SIZE 40,8 PIXEL//Preco
  @nL1,nC2 MSGET nPreco   PICTURE _PictPrUn VALID DI500InvValid('PRECO',oFobTotal) SIZE 107,08 PIXEL WHEN .F.
   nL1+=13
  @nL1,nC1 SAY AVSX3("W9_FOB_TOT",5) SIZE 50,8 PIXEL//Preco Total
//RMD - 09/06/08 - Utiliza a picture do campo W9_FOB_TOT, base da variável nDecimais, parâmetro no arredondamento do valor FOB
//  @nL1,nC2 MSGET oFobTotal VAR nFobTotal PICTURE _PictPrUn                      SIZE 95,08 WHEN .F. PIXEL
  @nL1,nC2 MSGET oFobTotal VAR nFobTotal PICTURE AvSx3("W9_FOB_TOT", AV_PICTURE)      SIZE 107,08 WHEN .F. PIXEL
   nL1+=13
  @nL1,nC1 SAY AVSX3("W8_INLAND",5)  SIZE 50,8 PIXEL //Inland
  @nL1,nC2 MSGET nInland   PICTURE aPictures[1] VALID DI500InvValid('INLAND')   SIZE 107,08 PIXEL WHEN (lAlteraDesp .and. !ValidCambio(.f.,"Itens")/*!lTemCambio*/)
   nL1+=13
  @nL1 ,nC1 SAY AVSX3("W8_PACKING",5) SIZE 50,8 PIXEL //Packing
  @nL1 ,nC2 MSGET nPacking PICTURE aPictures[2] VALID DI500InvValid('PACKING')  SIZE 107,08 PIXEL WHEN (lAlteraDesp .and. !ValidCambio(.f.,"Itens")/*!lTemCambio*/)
   nL1+=13
  @nL1,nC1 SAY  AVSX3("W8_DESCONT",5) SIZE 50,8 PIXEL //Desconto
  @nL1,nC2 MSGET nDesconto PICTURE aPictures[3] VALID DI500InvValid('DESCONTO') SIZE 107,08 PIXEL WHEN (lAlteraDesp .and. !ValidCambio(.f.,"Itens")/*!lTemCambio*/)
   nL1+=13
  @nL1,nC1 SAY AVSX3("W8_FRETEIN",5) SIZE 50,8 PIXEL//Int'l Freigh
  @nL1,nC2 MSGET nFrete   PICTURE aPictures[4] VALID DI500InvValid('FRETE')     SIZE 107,08 PIXEL WHEN (lAlteraDesp .and. !ValidCambio(.f.,"Itens")/*!lTemCambio*/)
   nL1+=13
  @nL1,nC1 SAY AVSX3("W8_OUTDESP",5) SIZE 50,8 PIXEL
  @nL1,nC2 MSGET nOutDesp PICTURE aPictures[5] VALID DI500InvValid('OUTDESP')   SIZE 107,08 PIXEL WHEN (lAlteraDesp .and. !ValidCambio(.f.,"Itens")/*!lTemCambio*/)
   nL1+=13

   // EOB - 20/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
  IF lSegInc
     @nL1,nC1 SAY AVSX3("W8_SEGURO",5) SIZE 50,8 PIXEL
     @nL1,nC2 MSGET nSeguro PICTURE AVSX3("W8_SEGURO",6) Valid DI500InvValid('SEGURO') SIZE 107,08 PIXEL WHEN (lAlteraDesp .and. !ValidCambio(.f.,"Itens")/*!lTemCambio*/)
      nL1+=13
  EndIf

  IF cPaisLoc == "BRA" .AND. !lExisteSEQ_ADI
     @nL1,nC1 SAY AVSX3("W8_ADICAO",5) SIZE 50,8 PIXEL
   //ASK 08/08/2007 - Correção do Valid do campo W8_ADICAO
   //@nL1,nC2 MSGET cAdicao PICTURE AVSX3("W8_ADICAO",6) Valid (If(!Empty(M->W6_DI_NUM) .and. lIntDraw,NaoVazio(cAdicao),)) SIZE 30,08 PIXEL WHEN !lTemAdicao .AND. lIntDraw .AND. !Empty(Posicione("SW5",9,xFilial("SW5")+SW5->(W5_AC+W5_COD_I),"W5_AC"))
     @nL1,nC2 MSGET cAdicao PICTURE AVSX3("W8_ADICAO",6) Valid (If(!Empty(M->W6_DI_NUM) .and. lIntDraw,NaoVazio(cAdicao),)) SIZE 30,08 PIXEL WHEN !lTemAdicao .AND. lIntDraw .AND. lWkAC  // !Empty(Work_SW8->WKAC) TLM 03/01/2008
     nL1+=13
  EndIf

  If lIntDraw
     cAto:=Work_SW8->WKAC
     @nL1,nC1 SAY AVSX3("W8_AC",5) SIZE 50,8 PIXEL
     @nL1,nC2 MSGET cAto PICTURE AVSX3("W8_AC",6) SIZE 95,08 PIXEL WHEN .F.
     nL1+=14
  EndIf

  IF lVlUnid // LDR  - OC - 0048/04 - OS - 0989/04
     @nL1,nC1 SAY AVSX3("W8_QTDE_UM",5) SIZE 50,8 PIXEL
     @nL1,nC2 MSGET nQtde_Um PICTURE AVSX3("W8_QTDE_UM" ,6) VALID DI500InvValid('QTDE_UM')   SIZE 1,08 PIXEL WHEN (lAlteraDesp .and. !ValidCambio(.f.,"Itens")/*!lTemCambio*/)
     nL1+=13
  ENDIF

  IF lOperacaoEsp   //AOM - 11/04/2011 - Campo Operacao Especial
     @nL1,nC1 SAY AVSX3("W8_CODOPE",5) SIZE 50,8 PIXEL
     @nL1,nC2 MSGET cCodOpe F3 "EJ0" PICTURE AVSX3("W8_CODOPE" ,6) VALID ValidOpe("cCodOpe_W8") SIZE 95,08 PIXEL WHEN (lAlteraDesp .and. !lTemCambio)
     nL1+=13
  ENDIF

  // BAK - Apresentação do campo do codigo da Matriz de Tributação na invoice
  If SW8->(FieldPos("W8_CODMAT")) > 0 .And. AvFlags("SUFRAMA") .And. EasyGParam("MV_TEM_DI", ,.F.)
     @nL1,nC1 SAY AVSX3("W8_CODMAT",5) SIZE 50,8 PIXEL
     @nL1,nC2 MSGET cCodMatriz PICTURE AVSX3("W8_CODMAT" ,6) VALID DI500InvValid('MATRIZ') SIZE 95,08 PIXEL F3 "EJB"
     nL1+=13
  EndIf
  IF AvFlags("EIC_EAI")//AWF - 25/06/2014
     M->W8_QTSEGUM := nSaldo * Work_SW8->WKFATOR
     //cSegUN:= TRANS(M->W8_QTSEGUM,AVSX3("W8_QTSEGUM",6))+" "+WORK_SW8->WKSEGUM//AWF - 01/07/2014
     cSegUN:= TRANS(M->W8_QTSEGUM,AVSX3("W3_QTSEGUM",6))+" "+WORK_SW8->WKSEGUM//AWF - 01/07/2014
     //@nL1,nC1 SAY AVSX3("W8_QTSEGUM",AV_TITULO) SIZE 107,08 PIXEL
     @nL1,nC1 SAY AVSX3("W3_QTSEGUM",AV_TITULO) SIZE 107,08 PIXEL
     @nL1,nC2 MSGET cSegUN SIZE 60,8 PIXEL WHEN .F.//AWF - 01/07/2014
     nL1+=13
  ENDIF
  IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ITEM_GET_INVOICE"),)
  DEFINE SBUTTON FROM 010,167 TYPE 1 ACTION(nopca:=1,If(DI500InvValid("OK_ITEM") .And. VldOpeDesemb("BTN_MK_IT_INV")/*AOM - 06/04/2011 -  Operação Especial*/,odlgTela:End(),nopca:=0)) ENABLE OF odlgTela PIXEL
  DEFINE SBUTTON FROM 036,167 TYPE 2 ACTION(nopca:=0,odlgTela:End()) ENABLE OF odlgTela PIXEL

  IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GET_ITEM_INVOICE"),)

  nL1+=250
  oDlgTela:nHeight:=nL1

ACTIVATE MSDIALOG odlgTela CENTERED

IF nOpca==1

   //Nopado por FDR - 13/09/13 - O sistema sempre deve acertar o rateio das despesas
   //lMarcado := .T. //RRV - 16/11/2012 - Indica que um item foi marcado (Para acertar o rateio das despesas nos itens da Invoice)

   Work_SW8->WKOUTDESP :=nOutDesp
   Work_SW8->WKQTDE    :=nSaldo
   Work_SW8->WKPRECO   :=nPreco
   Work_SW8->WKINLAND  :=nInland
   Work_SW8->WKPACKING :=nPacking
   Work_SW8->WKDESCONT :=nDesconto
   Work_SW8->WKFRETEIN :=nFrete
   IF lSegInc
      Work_SW8->WKSEGURO  :=nSeguro
   EndIf   
   Work_SW8->WKOUTDESP :=nOutDesp
   Work_SW8->WKADICAO  :=cAdicao
   IF lVlUnid // LDR - OC - 0048/04 - OS - 0989/04
      Work_SW8->WKQTDE_UM :=nQtde_Um
   ENDIF
   IF AvFlags("EIC_EAI")//AWF - 25/06/2014
      Work_SW8->WKQTSEGUM:= M->W8_QTSEGUM//WorK_SW8->WKQTDE*Work_SW8->WKFATOR
   ENDIF
   //AOM - 11/04/2011 - Campo Operacao Especial
   IF lOperacaoEsp
      Work_SW8->W8_CODOPE := cCodOpe
      Work_SW8->W8_DESOPE := Posicione("EJ0",1,xFilial("EJ0") + Work_SW8->W8_CODOPE ,"EJ0_DESC")
   EndIF

   // BAK - Gravando o codigo da Matriz de Tributação na Work
   If Work_SW8->(FieldPos("WKCODMATRI")) > 0 .And. AvFlags("SUFRAMA") .And. EasyGParam("MV_TEM_DI", ,.F.)
      Work_SW8->WKCODMATRI := cCodMatriz
   EndIf

   //If !lTemCambio  //GFC 23/10/03
   If !Empty(M->W6_DI_NUM) .and. Empty(Work_SW8->WKADICAO) .and. !lTemAdicao .and. lIntDraw .and. !lExisteSEQ_ADI //CCH - 04/05/09 - Inserida a mesma validação do Marca/Desmarca Todos
      Help("",1,"AVG0000717")//Existe itens com campo Adicao nao preenchido.")                                    //NCF - 30/09/09 - Verificação de NFE
   Else
      DI500InvMarca('M')
   EndIf
   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GRAVA_GET_ITEM_INVOICE"),)
ENDIF
DBSELECTAREA("Work_SW8")
   // SVG - 13/07/09 -
   If ("CTREE" $ RealRDD())
      If !EICLoja()
         Work_SW8->(DBEVAL({||;
         If(Work_SW8->WKINVOICE+Work_SW8->WKFORN == M->W9_INVOICE+M->W9_FORN .OR.;
         (EMPTY(Work_SW8->WKINVOICE) .AND. Work_SW8->WKFORN+Work_SW8->WKMOEDA == M->W9_FORN+M->W9_MOE_FOB);
         ,Work_SW8->WKFILTRO:="S",Work_SW8->WKFILTRO:="")}))
         SET FILTER TO Work_SW8->WKFILTRO == "S"
      Else
         Work_SW8->(DBEVAL({||;
         If(Work_SW8->WKINVOICE+Work_SW8->WKFORN+Work_SW8->W8_FORLOJ == M->W9_INVOICE+M->W9_FORN+M->W9_FORLOJ .OR.;
         (EMPTY(Work_SW8->WKINVOICE) .AND. Work_SW8->WKFORN+Work_SW8->W8_FORLOJ+Work_SW8->WKMOEDA == M->W9_FORN+M->W9_FORLOJ+M->W9_MOE_FOB);
         ,Work_SW8->WKFILTRO:="S",Work_SW8->WKFILTRO:="")}))
         SET FILTER TO Work_SW8->WKFILTRO == "S"
      EndIf
   Else
      If !EICLoja()
         SET FILTER TO Work_SW8->WKINVOICE+Work_SW8->WKFORN == M->W9_INVOICE+M->W9_FORN .OR. (EMPTY(Work_SW8->WKINVOICE) .AND. Work_SW8->WKFORN+Work_SW8->WKMOEDA == M->W9_FORN+M->W9_MOE_FOB)
      Else
         SET FILTER TO Work_SW8->WKINVOICE+Work_SW8->WKFORN+Work_SW8->W8_FORLOJ == M->W9_INVOICE+M->W9_FORN+M->W9_FORLOJ .OR. (EMPTY(Work_SW8->WKINVOICE) .AND. Work_SW8->WKFORN+Work_SW8->W8_FORLOJ+Work_SW8->WKMOEDA == M->W9_FORN+M->W9_FORLOJ+M->W9_MOE_FOB)
      EndIf
   EndIf
Work_SW8->(DBGOTO(nRecno))
oBrwInv:Refresh()//oMarkItens:oBrowse:Refresh()
RETURN .T.


FUNCTION DI500InvValid(cLocCampo,oObjeto,aValida)// Chamada do X3_VALID DO SW9

LOCAL C,cHelp
IF cPaisLoc # "BRA"// Chamada do X3_VALID DO SW9 do EICDI600.PRW tb
   RETURN DI600InvValid(cLocCampo,oObjeto,aValida)
ENDIF
PRIVATE lDesp_Invo,cCampo:=cLocCampo
PRIVATE c_DuplDoc := GetNewPar("MV_DUPLDOC"," ")

IF aValida # NIL
   If !Obrigatorio(aGets,aTela)
      RETURN .F.
   Endif

   //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
   SW9->(DBSETORDER(1))
   SW9->(DBSEEK(xFilial("SW9")+M->W9_INVOICE+M->W9_FORN+M->W9_FORLOJ+M->W6_HAWB))
   DO WHILE !SW9->(EOF()) .AND. ;
             SW9->W9_FILIAL  == xFilial("SW9") .AND. ;
             SW9->W9_INVOICE == M->W9_INVOICE  .AND. ;
             SW9->W9_FORN    == M->W9_FORN .AND. nPos_SW8aRotina = INCLUSAO .AND.;
             (!EICLoja() .Or. SW9->W9_FORLOJ == M->W9_FORLOJ) .AND. ;
             SW9->W9_HAWB    == M->W6_HAWB

      lDesp_Invo := .F.
      IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"DESPREZA_INVOICE_EMISSAO"),)

      IF lDesp_Invo
         SW9->(DBSKIP())
         LOOP
      ENDIF

      IF SW9->W9_HAWB <> M->W6_HAWB
         Help("",1,"AVG0000725",,ALLTRIM(SW9->W9_HAWB),2,0)//Invoice ja cadastrada para o Processo: "+SW9->W9_HAWB,)
         RETURN .F.
      ENDIF
      SW9->(DBSKIP())
   ENDDO

   IF !POSITIVO(M->W9_FRETEIN)
      RETURN .F.
   ELSEIF EMPTY(M->W9_FRETEIN) .AND. M->W9_FREINC $ cNao .AND.;
      AvRetInco(M->W9_INCOTER,"CONTEM_FRETE")/*FDR - 27/12/10*/ /*M->W9_INCOTER $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP"*/ .AND. nPos_SW8aRotina = ALTERACAO//AWR - ,DDU
      Help(" ",1,"E_FREVALOR")//VALOR DO FRETE NAO INFORMADO
      RETURN .F.
   ENDIF

   // EOB - 20/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
   IF lSegInc
      // EOB - 29/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
      IF AvRetInco(M->W9_INCOTER,"CONTEM_SEG")/*FDR - 27/12/10*/  //M->W9_INCOTER $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP"
         lIncot_Seg := .T.
      ELSE
         lIncot_Seg := .F.
      ENDIF
      nRegWSW9 := WORK_SW9->(recno())
      WORK_SW9->(dbGotop())
      DO WHILE !WORK_SW9->(EOF())
         IF (WORK_SW9->W9_INVOICE+WORK_SW9->W9_FORN+WORK_SW9->W9_FORLOJ) # (M->W9_INVOICE+M->W9_FORN+M->W9_FORLOJ)
            IF ( !(AvRetInco(WORK_SW9->W9_INCOTER,"CONTEM_SEG")/*FDR - 27/12/10*/ /*WORK_SW9->W9_INCOTER $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP"*/) .AND. lIncot_Seg ) .OR. ( AvRetInco(WORK_SW9->W9_INCOTER,"CONTEM_SEG")/*FDR - 27/12/10*/  /*WORK_SW9->W9_INCOTER $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP"*/ .AND. !lIncot_Seg )
               MSGINFO(STR0555) //Atenção! Neste processo há invoice com incoterm que contém seguro e invoice com incoterm que não contém seguro. Esta operação não é permitida no Siscomex.
               WORK_SW9->(dbGoto(nRegWSW9))
               RETURN .F.
            ENDIF
         ENDIF
         WORK_SW9->(dbSkip())
      ENDDO
      WORK_SW9->(dbGoto(nRegWSW9))

      IF !POSITIVO(M->W9_SEGURO)
         RETURN .F.
      ELSEIF EMPTY(M->W9_SEGURO) .AND. AvRetInco(M->W9_INCOTER,"CONTEM_SEG")/*FDR - 27/12/10*/  /*M->W9_INCOTER $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP"*/ .AND. nPos_SW8aRotina = ALTERACAO
         Help(" ",1,"E_SEGVALOR")//VALOR DO SEGURO NAO INFORMADO
         //RETURN .F. SVG - 23/07/09 -
      ELSEIF !EMPTY(M->W9_SEGURO) .AND. !AvRetInco(M->W9_INCOTER,"CONTEM_SEG")/*FDR - 27/12/10*/  //!(M->W9_INCOTER $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP")         
         MSGINFO(STR0556)//Valor do seguro deve ser informado somente quando o incoterm contém seguro
         M->W9_SEGURO := 0         
      ENDIF
   ENDIF

   //** GFC - 21/11/05 - Câmbio de frete, seguro, comissão e embarque
   If lWB_TP_CON .and. !(Empty(M->W9_FORNECC) .and. Empty(M->W9_LOJAC) .and. Empty(M->W9_COMPV) .and. Empty(M->W9_PERCOM) .and.;
   Empty(M->W9_VALCOM) .and. Empty(M->W9_TIPOCOM)) .and. !(!Empty(M->W9_FORNECC) .and. !Empty(M->W9_LOJAC) .and.;
   !Empty(M->W9_COMPV) .and. (!Empty(M->W9_PERCOM) .or. !Empty(M->W9_VALCOM)) .and. !Empty(M->W9_TIPOCOM))
      If !MsgYesNo(STR0635) //STR0635 "As informações de comissão estão incompletas. Deseja continuar?"
         Return .F.
      EndIf
   EndIf

   FOR C:=1 TO LEN(aValida)
      cCampo:='M->'+ALLTRIM(aValida[C])
      cCampo:=&(cCampo)
      IF EMPTY(cCampo)
         Help("", 1, "AVG0000721",,AVSX3(aValida[C],5),1,8)//nao preenchido
         RETURN .F.
      ENDIF
   NEXT

   lValid:=.T.
   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"INVOICE_VALID_OK"),)
   RETURN lValid

ENDIF

IF cCampo == NIL
   cCampo:=UPPER(READVAR())
ENDIF
IF Left(cCampo,3) == "M->"
   cCampo:=Subs(cCampo,4)
ENDIF

DO CASE
   CASE cCampo=="W9_INVOICE"
      IF !NaoVazio(M->W9_INVOICE)
         RETURN .F.
      //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
      ELSEIF !EMPTY(M->W9_FORN) .And. (!EICLoja() .Or. !Empty(M->W9_FORLOJ)) .AND. WORK_SW9->(DBSEEK(M->W9_INVOICE+M->W9_FORN+M->W9_FORLOJ+M->W6_HAWB))
         Help(" ",1,"JAGRAVADO")
         RETURN .F.
      ENDIF
      //ASK 13/09/07 - Se o MV_DUPLDOC estiver ligado e a 3ªletra for I, indica que o numero da invoice será o n°
      //do título INV no financeiro, abaixo validamos se existe o título para não duplicar a chave do SE2.
      IF lFinanceiro .And. SUBSTR(c_DuplDoc,1,1) == "S" .and. SUBSTR(c_DuplDoc,3,1) == "I"
         SE2->(DbSetOrder(6)) //LGS-27/01/2015
         IF SUBSTR(c_DuplDoc,2,1) == "R"
            cNroDupl := RIGHT(ALLTRIM(M->W9_INVOICE),LEN(SE2->E2_NUM)) //LRS - 25/05/2015 - Colocado AvKey no dbseek para localizar corretamente o numero do processo na EE2
            If SE2->(DbSeek(xFilial("SE2")+M->(W9_FORN+W9_FORLOJ)+"EIC"+AvKey(cNroDupl,"E2_NUM"))) //LGS-27/01/2015
               MsgStop(STR0549 + cNroDupl, STR0141)//"Já existe Título de Invoice no SIGAFIN com esta numeração: "
               RETURN .F.
            EndIf
         ELSEIF SUBSTR(c_DuplDoc,2,1) == "L"
            cNroDupl := LEFT(ALLTRIM(M->W9_INVOICE),LEN(SE2->E2_NUM))
            If SE2->(DbSeek(xFilial("SE2")+M->(W9_FORN+W9_FORLOJ)+"EIC"+AvKey(cNroDupl,"E2_NUM"))) //LGS-27/01/2015
               MsgStop(STR0549 + cNroDupl, STR0141)//"Já existe Título de Invoice no SIGAFIN com esta numeração: "
               RETURN .F.
            EndIf
         ENDIF
      EndIf

   CASE cCampo=="W9_MOE_FOB"
      //IF !ExistCpo("SYE",M->W9_MOE_FOB,2)
      If !ExistCpo("SYF",M->W9_MOE_FOB)  // PLB 28/03/07 - Cadastro de Moedas
         RETURN .F.
      ENDIF
      IF /*EMPTY(M->W9_TX_FOB) .AND.*/ lBuscaTaxaAuto //MCF - 28/07/2015
         M->W9_TX_FOB := BuscaTaxa(M->W9_MOE_FOB,DI500DtTxInv(),.T.,.F.,.T.)
      Endif

   CASE cCampo=="W9_FORN"
      lRet := .T. //Para ponto de entrada
      IF !NaoVazio(M->W9_FORN) .OR. !ExistCpo("SA2",M->W9_FORN)
         RETURN .F.
      //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
      ELSEIF WORK_SW9->(DBSEEK(M->W9_INVOICE+M->W9_FORN+EICRetLoja("M","W9_FORLOJ")+M->W6_HAWB))
         Help(" ",1,"JAGRAVADO")
         RETURN .F.
      ENDIF
      IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"VALIDA_SW9_FORN"),)
      If !lRet
         Return .F.
      EndIf

   CASE cCampo=="W9_FORLOJ"
      If EICLoja() .AND. !Empty(M->W9_FORLOJ)
         SA2->(DBSETORDER(1))
         If SA2->(DbSeek(xFilial("SA2")+M->W9_FORN+M->W9_FORLOJ))
            M->W9_NOM_FOR := SA2->A2_NREDUZ
         Else
            Return .F.
         EndIf
      EndIf
   CASE cCampo=="W9_FRETEIN"
      IF !POSITIVO(M->W9_FRETEIN)
         RETURN .F.
      ELSEIF EMPTY(M->W9_FRETEIN) .AND. M->W9_FREINC $ cNao .AND. AvRetInco(M->W9_INCOTER,"CONTEM_FRETE")/*FDR - 27/12/10*/  //M->W9_INCOTER $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP"
         Help(" ",1,"E_FREVALOR")//VALOR DO FRETE NAO INFORMADO
         RETURN .F.
      ENDIF

//LAM - 17/10/06 - Atualizar campo de valor de câmbio
      If M->W9_COMPV == "1"  //Valor
         M->W9_PERCOM := 0
      ElseIf M->W9_COMPV == "2"  //Percentual
         M->W9_VALCOM := If(M->W9_PERCOM<>0,(DI500RetVal("TOT_INV", "MEMO", .T.)*M->W9_PERCOM)/100, 0) // EOB - 21/05/08 - chamada da função DI500RetVal
      EndIf
   // EOB - 20/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
   CASE cCampo=="W9_SEGURO"
      IF !POSITIVO(M->W9_SEGURO)
         RETURN .F.
      ELSEIF EMPTY(M->W9_SEGURO) .AND. AvRetInco(M->W9_INCOTER,"CONTEM_SEG")/*FDR - 27/12/10*/  //M->W9_INCOTER $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP"
         Help(" ",1,"E_SEGVALOR")//VALOR DO SEGURO NAO INFORMADO
         //RETURN .F.
      ELSEIF !EMPTY(M->W9_SEGURO) .AND. !AvRetInco(M->W9_INCOTER,"CONTEM_SEG")/*FDR - 27/12/10*/  //!(M->W9_INCOTER $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP")
		 MSGINFO(STR0556)//Valor do seguro deve ser informado somente quando o incoterm contém seguro
		 M->W9_SEGURO := 0
      ENDIF

      If M->W9_COMPV == "1"  //Valor
         M->W9_PERCOM := 0
      ElseIf M->W9_COMPV == "2"  //Percentual
         M->W9_VALCOM := If(M->W9_PERCOM<>0,(DI500RetVal("TOT_INV", "MEMO", .T.)*M->W9_PERCOM)/100, 0) // EOB - 21/05/08 - chamada da função DI500RetVal
      EndIf

   // EOB - 29/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
   CASE cCampo=="W9_INCOTER"
      IF AvRetInco(M->W9_INCOTER,"CONTEM_SEG")/*FDR - 27/12/10*/  //M->W9_INCOTER $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP"
         lIncot_Seg := .T.
      ELSE
         lIncot_Seg := .F.
      ENDIF
      nRegWSW9 := WORK_SW9->(recno())
      WORK_SW9->(dbGotop())
      DO WHILE !WORK_SW9->(EOF())
         IF (WORK_SW9->W9_INVOICE+WORK_SW9->W9_FORN+WORK_SW9->W9_FORLOJ) # (M->W9_INVOICE+M->W9_FORN+M->W9_FORLOJ)
            IF (!AvRetInco(WORK_SW9->W9_INCOTER,"CONTEM_SEG")/*WORK_SW9->W9_INCOTER $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP"*/ .AND.;
               lIncot_Seg) .OR. (AvRetInco(WORK_SW9->W9_INCOTER,"CONTEM_SEG")/*WORK_SW9->W9_INCOTER $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP"*/ .AND. !lIncot_Seg)//FDR - 27/12/10
               MSGINFO(STR0555)//Atenção! Neste processo há invoice com incoterm que contém seguro e invoice com incoterm que não contém seguro. Esta operação não é permitida no Siscomex.
               WORK_SW9->(dbGoto(nRegWSW9))
               RETURN .F.
            ENDIF
         ENDIF
         WORK_SW9->(dbSkip())
      ENDDO
      WORK_SW9->(dbGoto(nRegWSW9))

   CASE cCampo=="SALDO"
      IF nSaldo>Work_SW8->WKSALDO_AT
         Help("", 1,"AVG0000707")//"Quantidade maior que saldo disponivel"
         RETURN .F.
      ELSEIF !POSITIVO(nSaldo)
         RETURN .F.
      ELSEIF !NaoVazio(nSaldo)//EMPTY(nSaldo)
//       Help(" ",1,"E_SALDOQTD")//SALDO DE QUANTIDADE NAO PREENCHIDO
         RETURN .F.
      ENDIF
      nFobTotal:=DI500Trans(nSaldo * nPreco)
      oObjeto:Refresh()
      IF AvFlags("EIC_EAI")//AWF - 25/06/2014
         M->W8_QTSEGUM:=nSaldo*Work_SW8->WKFATOR
         //cSegUN:= TRANS(M->W8_QTSEGUM,AVSX3("W8_QTSEGUM",6))+" "+WORK_SW8->WKSEGUM//AWF - 01/07/2014
         cSegUN:= TRANS(M->W8_QTSEGUM,AVSX3("W3_QTSEGUM",6))+" "+WORK_SW8->WKSEGUM//AWF - 01/07/2014
      ENDIF
   CASE cCampo=="PRECO"
      IF !POSITIVO(nPreco)
         RETURN .F.
      ELSEIF !NaoVazio(nPreco)
         RETURN .F.
      ENDIF
      nFobTotal:=DI500Trans(nSaldo * nPreco)
      oObjeto:Refresh()

   CASE cCampo=="INLAND"
      IF !POSITIVO(nInland)
         RETURN .F.
      ENDIF

   CASE cCampo=="PACKING"
      IF !POSITIVO(nPacking)
         RETURN .F.
      ENDIF

   CASE cCampo=="FRETE"
      IF !POSITIVO(nFrete)
         RETURN .F.
      ENDIF

   // EOB - 29/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
   CASE cCampo=="SEGURO"
      IF !POSITIVO(nSeguro)
         RETURN .F.
      ENDIF

   CASE cCampo=='OUTDESP'
      IF !POSITIVO(nOutDesp)
         RETURN .F.
      ENDIF

   CASE cCampo=='QTDE_UM'
      IF !POSITIVO(nQtde_Um)
         RETURN .F.
      ENDIF

   CASE cCampo=="DESCONTO"
      IF !POSITIVO(nDesconto)
         RETURN .F.
      ELSEIF nDesconto>nFobTotal+nInland+nPacking+nOutDesp
         Help("",1,"AVG0000708")//"Desconto maior que a soma FOB TOTAL + Inland + Packing + Outras Despesas"
         RETURN .F.
      ENDIF

   Case cCampo=="OK_ITEM" .AND. cPaisLoc = "BRA"
         // by CAF 17/01/08 If !Empty(M->W6_DI_NUM) .and. Empty(cAdicao) .and. !lTemAdicao .and. lIntDraw .And. !Empty(Work_SW8->WKAC)
         If !Empty(M->W6_DI_NUM) .and. Empty(cAdicao) .and. !lTemAdicao .and. lIntDraw .And. lWkAC .And. !Empty(Work_SW8->WKAC)
            Help("",1,"AVG0000709")//"Campo Adicao deve ser preenchido.")//0507
            Return .F.
         EndIf

         // BAK - Validação do campo do Codigo da Matriz de Tributação
         If Work_SW8->(FieldPos("WKCODMATRI")) > 0 .And. AvFlags("SUFRAMA") .And. EasyGParam("MV_TEM_DI", ,.F.) .And. Empty(cCodMatriz)
            MsgInfo(STR0821,STR0141) // "Preencha o campo 'Cod Matriz'."
            Return .F.
         Else
            //RRC - 17/07/2012 - Chama a validação do campo do Codigo da Matriz de Tributação
            If Work_SW8->(FieldPos("WKCODMATRI")) > 0 .And. AvFlags("SUFRAMA") .And. EasyGParam("MV_TEM_DI", ,.F.) .And. !Empty(cCodMatriz)
               If !DI500InvValid("MATRIZ")
                  Return .F.
               EndIf
            EndIf
         EndIf

   //** GFC - 21/11/05 - Câmbio de frete, seguro, comissão e embarque
   CASE cCampo$"W9_COMPV,W9_INLAND,W9_PACKING,W9_OUTDESP,W9_DESCONT,W9_FREINC,W9_SEGURO"
      If M->W9_COMPV == "1"  //Valor
         M->W9_PERCOM := 0
      ElseIf M->W9_COMPV == "2"  //Percentual
         M->W9_VALCOM := If(M->W9_PERCOM<>0,(DI500RetVal("TOT_INV","MEMO",.T.)*M->W9_PERCOM)/100, 0) // EOB - 21/05/08 - chamada da função DI500RetVal
      EndIf
   CASE cCampo=="W9_PERCOM"
      M->W9_VALCOM := If(M->W9_PERCOM<>0,(DI500RetVal("TOT_INV","MEMO",.T.)*M->W9_PERCOM)/100, 0) // EOB - 21/05/08 - chamada da função DI500RetVal

   Case AllTrim(Upper(cCampo)) == "MATRIZ"
      nOrdEJB := EJB->(IndexOrd())
      nRecEJB := EJB->(Recno())
      EJB->(DbSetOrder(1))

      //RRC - 17/07/2012 - Verifica se o código da matriz existe para o importador do processo
      If Type("cCodMatriz") == "C" .And. Type("M->W6_IMPORT") <> "U" .And. !Empty(cCodMatriz) .And. !EJB->(DbSeek(xFilial("EJB") + AvKey(M->W6_IMPORT,"EJB_IMPORT")  + AvKey(cCodMatriz,"W8_CODMAT")))
         MsgInfo(STR0822 +AllTrim(cCodMatriz)+ STR0824,STR0141) // "A Matriz " + " não está relecionada ao importador do processo."
         EJB->(DbSetOrder(nOrdEJB))
         EJB->(DbGoTo(nRecEJB))
         Return .F.
      EndIf

      //RRC - 17/07/2012 - Verifica se o código da matriz selecionado está ativo
      If Type("cCodMatriz") == "C" .And. Type("M->W6_IMPORT") <> "U" .And. !Empty(cCodMatriz) .And. EJB->(DbSeek(xFilial("EJB") + AvKey(M->W6_IMPORT,"EJB_IMPORT")  + AvKey(cCodMatriz,"W8_CODMAT"))) .And. EJB->EJB_ATIVO == "2"
         MsgInfo(STR0822 +AllTrim(cCodMatriz)+ STR0825,STR0141) // "A Matriz " + " não está ativa."
         EJB->(DbSetOrder(nOrdEJB))
         EJB->(DbGoTo(nRecEJB))
         Return .F.
      EndIf

ENDCASE

lValid:=.T.
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"INVVALID_CPOS_SW8_SW9"),)

RETURN lValid

FUNCTION DI500InvConf(lSoma,cInvoice,cForn,lPerg, cForLoj)

LOCAL nConf // do FOR
LOCAL nRecno:=Work_SW8->(RECNO())
LOCAL nOrder:=Work_SW8->(INDEXORD())
//LOCAL nPesoZero := 0 //Rossetti
Local lPesoZero := .F.
PRIVATE aInvConf :={}
PRIVATE lSomaDespInv := lSoma
PRIVATE cMsg := ""

Work_SW8->(DBSETORDER(1))
IF !Work_SW8->(DBSEEK(cInvoice+cForn+If(EICLoja(), cForLoj, ""))) .AND. lSoma
    Work_SW8->(DBGOTO(nRecno))
    Work_SW8->(DBSETORDER(nOrder))
   RETURN .F.
ENDIF

AADD(aInvConf,{0,WORK_SW9->W9_INLAND,"INLAND" })
AADD(aInvConf,{0,WORK_SW9->W9_PACKING,"PACKING"})
AADD(aInvConf,{0,WORK_SW9->W9_DESCONT,"DESCONTO"})
AADD(aInvConf,{0,WORK_SW9->W9_OUTDESP,"OUTRA DESPESA"})
IF Work_SW9->W9_FREINC $ cSim
   AADD(aInvConf,{0,0,"FRETE INTL"})
ELSE
   AADD(aInvConf,{0,WORK_SW9->W9_FRETEIN,"FRETE INTL"})
ENDIF
AADD(aInvConf,{0,WORK_SW9->W9_FOB_TOT,"TOTAL FOB"})
// EOB - 20/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
IF lSegInc
   IF Work_SW9->W9_SEGINC $ cSim
      AADD(aInvConf,{0,0,"SEGURO INTL"})
   ELSE
      AADD(aInvConf,{0,WORK_SW9->W9_SEGURO,"SEGURO INTL"})
   ENDIF
ENDIF

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"CONFERE_DESP_INV"),)

lSoma := lSomaDespInv
DO WHILE Work_SW8->(!EOF())           .AND.;
         Work_SW8->WKINVOICE==cInvoice.AND.;
         Work_SW8->WKFORN   ==cForn   .AND. lSoma .And.;
         Work_SW8->W8_FORLOJ == cForLoj


   IF EMPTY(Work_SW8->WKFLAGIV)
      Work_SW8->(DBSKIP())
      LOOP
   ENDIF

   aInvConf[1,1]+=Work_SW8->WKINLAND
   aInvConf[2,1]+=Work_SW8->WKPACKING
   aInvConf[3,1]+=Work_SW8->WKDESCONT
   aInvConf[4,1]+=Work_SW8->WKOUTDESP
   aInvConf[5,1]+=Work_SW8->WKFRETEIN
   aInvConf[6,1]+=Work_SW8->WKPRTOTMOE

   // EOB - 20/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
   IF lSegInc
      aInvConf[7,1]+=Work_SW8->WKSEGURO
   ENDIF
   if Work_SW8->WKPESOTOT == 0 .and. M->W9_FREINC $ cNao .AND. AvRetInco(M->W9_INCOTER,"CONTEM_FRETE")/*FDR - 27/12/10*/  //M->W9_INCOTER $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP"
   		lPesoZero := .T.
   endif
   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"WHILE_CONFERE_DESP_INV"),)

   Work_SW8->(DBSKIP())

ENDDO

IF lSoma
   Work_SW8->(DBGOTO(nRecno))
   Work_SW8->(DBSETORDER(nOrder))
   FOR nConf := 1 TO LEN(aInvConf)
      IF STR(aInvConf[nConf,2],18,2) # STR(aInvConf[nConf,1],18,2)
         cMsg := cMsg + chr(13) + chr(10) + aInvConf[nConf,3] + chr(13) + chr(10) + "Capa: " + STR(aInvConf[nConf,2],18,2) + " Itens: " + STR(aInvConf[nConf,1],18,2) 
         lPerg := .T.
         Work_SW9->W9_TUDO_OK:=NAO
      ENDIF
   NEXT
ENDIF

IF lPesoZero
	MSGinfo(STR0563,STR0558)// "Existe item(s) com peso liquido zerado. O frete não será rateado para este(s) item(s)." "Aviso"
endif
IF lPerg
   //MFR OSSME-2708 27/08/2019
   cMsg2 := STRTran(STR0898, "####", cMsg + chr(13) + chr(10)) // As somatórias dos valores informados para os itens diferem dos totais informados na capa da Invoice: ####
                                                               // Ao confirmar, o sistema efetuará o rateio dos valores da capa, ainda que informado 0 (zero), pelos itens da Invoice.
                                                               // Deseja realizar automaticamente o acerto dos rateios dos valores?
   RETURN MSGYESNO(cMsg2,STR0283+ALLTRIM(cInvoice)+"/"+cForn)//"Lendo Invoice: "
ENDIF

//Nopado por FDR - 13/09/13 - O sistema sempre deve acertar o rateio das despesas
//RRV - 16/11/2012 - Pergunta se deseja acertar o rateio das despesas da Invoice nos itens(SW8) x capa(SW9) quando novos itens forem marcados.
//If lMarcado
//	Return MsgYesNo(STR0837,STR0558) //RRV - 16/11/2012 - "Foram marcados novos itens para esta Invoice. Deseja acertar?" / "Aviso"
//EndIf
//MFR OSSME-2708 27/08/2019
RETURN .F.

//Função para restaurar o filtro da work sw8 de acordo com o parÂmetro lMemoria
FUNCTION DI500RstFil(lMemoria,cOldFilter)
if lMemoria
   WORK_SW8->(DbClearFilter())
   if !empty(cOldFilter)
       WORK_SW8->(DbSetFilter(&("{||" + cOldFilter + "}"),cOldFilter))
   endif
   WORK_SW8->(dbgotop() )
EndIf
Return nil

FUNCTION DI500InvTotais(lMemoria,lZeraAdicao,oBrw,lRatFrete,lRatPorFOB)

LOCAL aAcertos:={},nCont:=0,nRecno:=Work_SW8->(RECNO())
LOCAL nRecFRE:=nRecVlr:=1,nOrder:=Work_SW8->(INDEXORD())
LOCAL nMaiorFre:=nMaiorVlr:=0,lCalcula:=.F.,cTipoRat:='',A
LOCAL cInvoice,cForn,nINLAND:=nPACKING:=nDESCONT:=nOUTDESP:=nFRETEIN:=0
LOCAL nSEGURO:=0, lCalSeg := .F. // EOB - 20/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
LOCAL nTotalRatFrtIn := 0 //LGS-12/11/13
//THTS - 16/11/2017 - Objeto EasyRateio para as despesas
Local oRatSeguro
Local oRatFrete
Local oRatInland
Local oRatPacking
Local oRatOutDes
Local oRatDescon
Local nContSW8 := 0
Local cOldFilter
Local bFilTemp
Local nTipCobCPg
PRIVATE aValRat:={} //LGS-26/11/14
Private lAlteraRateio := .T. //MCF - 28/01/2015 - Variável criada para o ponto de entrada RATEIA_DESC_INV
DEFAULT lZeraAdicao:= .F.
DEFAULT lRatFrete  := .T.
DEFAULT lRatPorFOB := .T.

If (WORK_SW9->(FIELDPOS("W9_RATFRT")) # 0) //LGS-12/11/13 - Verifica se o valor do frete internacional vai ser rateado ou informado manual item a item.
  lRateiaIntFreigh  := IF(TYPE("lRateiaIntFreigh")<>"L",.F.,lRateiaIntFreigh)
  If lRateiaIntFreigh == .T.
  	 lRatFrete  := .T.
  ElseIf M->W9_RATFRT == '2'
     lRatFrete  := .F.
  Else
     lRatFrete  := .T.
  EndIf
EndIf

lGravaSoCapa:= .F.
lRDMemoria  := lMemoria
lRDRatFrete := lRatFrete
lRDRatPorFOB:= lRatPorFOB

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"RATEIA_DESP_INV"),)

lRatFrete := lRDRatFrete
lRatPorFOB:= lRDRatPorFOB
lSair:= !lRatFrete .AND. !lRatPorFOB

ProcRegua(20)
IF lMemoria
   cInvoice :=M->W9_INVOICE
   cForn    :=M->W9_FORN
   If EICLoja()
      cLoja := M->W9_FORLOJ
   EndIf
   IF lRatPorFOB
      nINLAND :=M->W9_INLAND
      nPACKING:=M->W9_PACKING
      nDESCONT:=M->W9_DESCONT
      nOUTDESP:=M->W9_OUTDESP
      // EOB - 20/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
      IF lSegInc
         nSEGURO := M->W9_SEGURO
         lCalSeg := M->W9_SEGINC $ cNao
      ENDIF
   ENDIF
   IF lRatFrete
      nFRETEIN:=M->W9_FRETEIN
      lCalcula:=M->W9_FREINC $ cNao
      cTipoRat:=M->W9_RAT_POR
   ENDIF
ELSE
   cInvoice :=Work_SW9->W9_INVOICE
   cForn    :=Work_SW9->W9_FORN
   If EICLoja()
      cLoja := Work_SW9->W9_FORLOJ
   EndIf
   IF lRatPorFOB
      nINLAND :=WORK_SW9->W9_INLAND
      nPACKING:=WORK_SW9->W9_PACKING
      nDESCONT:=WORK_SW9->W9_DESCONT
      nOUTDESP:=WORK_SW9->W9_OUTDESP
      // EOB - 20/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
      IF lSegInc
         nSEGURO := WORK_SW9->W9_SEGURO
         lCalSeg := WORK_SW9->W9_SEGINC $ cNao
      ENDIF
   ENDIF
   IF lRatFrete
      nFRETEIN:=WORK_SW9->W9_FRETEIN
      lCalcula:=WORK_SW9->W9_FREINC $ cNao
      cTipoRat:=WORK_SW9->W9_RAT_POR
   ENDIF
ENDIF

Work_SW8->(DBSETORDER(1))

//** AAF 17/06/2010
/*Work_SW8->(DBSEEK(Space(Len(Work_SW8->WKINVOICE))))
DO WHILE Work_SW8->(!EOF()) .AND. Work_SW8->WKINVOICE==Space(Len(Work_SW8->WKINVOICE))

   If EMPTY(Work_SW8->WKFLAGIV)
      Work_SW8->(dbDelete()) //Desprezar registro desmarcado para evitar duplicidade na chave única do SW8.
                             //Ao alterar a invoice, será criado novo registro se necessário.
   EndIf

   Work_SW8->(DBSKIP())
EndDo*/
//wfs - out/2019: ajustes de performance
//MFR 06/11/2020 OSSME-5299
If !lMemoria
    TcSqlExec("UPDATE " + TETempName("Work_SW8") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ where WKINVOICE = '" + Space(Len(Work_SW8->WKINVOICE)) + "' and WKFLAGIV = ' ' ") 
else
    cOldFilter := WORK_SW8->(DbFilter())
    WORK_SW8->(DbClearFilter())
    cFilTemp := cOldFilter + If(!Empty(cOldFilter)," .And. " ,"" )  + "WORK_SW8->WKFLAGIV != ' '"        //NCF - 29/04/2021
    bFilTemp := &("{||" + cFilTemp + "}")         
    Work_SW8->(DbSetFilter(bFilTemp,cFilTemp))
    Work_SW8->(Dbgotop())
EndIf
IF !Work_SW8->(DBSEEK(cInvoice+cForn+IF(EICLoja(), cLoja, "")))
   Work_SW8->(DBSETORDER(nOrder))
   Work_SW8->(DBGOTO(nRecno))
   //MFR 06/11/2020 OSSME-5299
   DI500RstFil(lMemoria,cOldFilter)
   RETURN .F.
ENDIF

IF !lSair
   AADD(aAcertos,{0,nINLAND })
   AADD(aAcertos,{0,nPACKING})
   AADD(aAcertos,{0,nDESCONT})
   AADD(aAcertos,{0,nOUTDESP})
   AADD(aAcertos,{0,nFRETEIN})
   // EOB - 20/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
   IF lSegInc
	   AADD(aAcertos,{0,nSEGURO})
   ENDIF
ENDIF

IF lRatFrete
   WORK_SW9->W9_QTDE:=0
ENDIF

nCont:= EasyRecCount("Work_SW8")
ProcRegua(nCont)

M->W9_FOB_TOT:=0
WORK_SW9->W9_PESO   :=0
WORK_SW9->W9_FOB_TOT:=0
nTotQtde_Inv := 0   // LDR -27/08/04
nTotFob_Inv  := 0   // LDR -27/08/04
nTotPeso_Inv := 0   // LDR -27/08/04
nTipCobCPg   := Posicione("SY6",1,xFilial("SY6")+WORK_SW9->W9_COND_PA+STR(WORK_SW9->W9_DIAS_PA,3),"Y6_TIPOCOB")

SW2->(DBSETORDER(1))
WORK->(DBSETORDER(3))
DO WHILE Work_SW8->(!EOF()) .AND. Work_SW8->WKINVOICE==cInvoice .AND.;
                                  Work_SW8->WKFORN   ==cForn    .And.;
                                  WORK_SW8->W8_FORLOJ == cLoja

   IncProc(STR0460+Work_SW8->WKCOD_I) //"Calculando Item: "

   IF !EMPTY(Work_SW8->WKFLAGIV)
      SB1->(dbSetorder(1))
      SB1->(dbSeek(xFilial("SB1")+Work_SW8->WKCOD_I))
      IF lExiste_Midia .AND. lPesoMid .AND. SB1->B1_MIDIA $ cSIM   // LDR - 25/08/04
         SW2->(DBSEEK(xFILIAL("SW2")+Work_SW8->WKPO_NUM))
         WORK->(DBSEEK(Work_SW8->WKPO_NUM+Work_SW8->WKPGI_NUM+Work_SW8->WKPOSICAO))
         nTotQtde_Inv += Work_SW8->WKQTDE * SB1->B1_QTMIDIA
         nTotFob_Inv  += Work_SW8->WKQTDE * SB1->B1_QTMIDIA * SW2->W2_VLMIDIA
         nTotPeso_Inv += Work_SW8->WKQTDE * SB1->B1_QTMIDIA * WORK->WKPESOMID
      ELSE
         nTotQtde_Inv += Work_SW8->WKQTDE
         nTotFob_Inv  += Work_SW8->WKPRTOTMOE
         nTotPeso_Inv += Work_SW8->WKPESOTOT
      ENDIF

      IF !lMemoria
         IF lTemAdicao .AND. ( If( EasyGParam("MV_EIC0075",,1) == 1 , Work_SW8->WKCOND_PA # WORK_SW9->W9_COND_PA .OR. Work_SW8->WKDIAS_PA # WORK_SW9->W9_DIAS_PA , ;
                                                                      Work_SW8->WKTCOB_PA # nTipCobCPg ) .OR. ;
                              Work_SW8->WKMOEDA   # WORK_SW9->W9_MOE_FOB .OR.;
                              Work_SW8->WKINCOTER # WORK_SW9->W9_INCOTER )
            Work_SW8->WKADICAO:=""
         ENDIF
         Work_SW8->WKCOND_PA:= WORK_SW9->W9_COND_PA
         Work_SW8->WKDIAS_PA:= WORK_SW9->W9_DIAS_PA
         Work_SW8->WKTCOB_PA:= nTipCobCPg
         Work_SW8->WKMOEDA  := WORK_SW9->W9_MOE_FOB
         Work_SW8->WKINCOTER:= WORK_SW9->W9_INCOTER

         IF !EMPTY(nFRETEIN) .AND. lRatFrete
            Work_SW9->W9_QTDE  += Work_SW8->WKQTDE
         ENDIF
         Work_SW9->W9_PESO   += Work_SW8->WKPESOTOT
         Work_SW9->W9_FOB_TOT+= Work_SW8->WKPRTOTMOE

      ELSE
         M->W9_FOB_TOT += Work_SW8->WKPRTOTMOE
      ENDIF

      IF lZeraAdicao
         Work_SW8->WKADICAO:='   '
      ENDIF
      IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"SOMA_DESP_INV"),)
   ENDIF

   If (WORK_SW9->(FIELDPOS("W9_RATFRT")) # 0) .And. lRatFrete == .F. //LGS-12/11/13
   	  nTotalRatFrtIn += Work_SW8->WKFRETEIN
   EndIf

   Work_SW8->(DBSKIP())

ENDDO

If (WORK_SW9->(FIELDPOS("W9_RATFRT")) # 0) .And. lRatFrete == .F. .And. !Empty(Work_SW9->W9_FRETEIN) //LGS-12/11/13 - Compara o valor informado na capa e o total somado por item
   If nTotalRatFrtIn # Work_SW9->W9_FRETEIN
      MsgInfo(STR0850)
      DI500W9Manut(2)
   EndIf
EndIf

M->W9_TUDO_OK:=Work_SW9->W9_TUDO_OK:=SIM

IF lSair
   //MFR 05/11/2020 OSSME-5299
   DI500RstFil(lMemoria,cOldFilter)
   RETURN .F.
ENDIF

SB1->(dbSetorder(1))
SW2->(DBSETORDER(1))
WORK->(DBSETORDER(3))

Work_SW8->(DBSEEK(cInvoice+cForn+If(EICLoja(), cLoja, "")))
nRecVlr := Work_SW8->(RECNO())

//THTS - 16/11/2017 - Utiliza a EasyRateio para as despesas
Work_SW8->(dbEval({|| If( !Empty(Work_SW8->WKFLAGIV) , nContSW8++ , )}))
Work_SW8->(dbGoTo(nRecVlr))
oRatSeguro  := EasyRateio():New(nSEGURO , nTotFob_Inv, nContSW8, AvSx3("W8_SEGURO" , AV_DECIMAL))
Do Case
	Case cTipoRat == "1" //Peso
		oRatFrete   := EasyRateio():New(nFRETEIN, nTotPeso_Inv, nContSW8, AvSx3("W8_FRETEIN", AV_DECIMAL))
	Case cTipoRat == "2" //Preco
		oRatFrete   := EasyRateio():New(nFRETEIN, nTotFob_Inv , nContSW8, AvSx3("W8_FRETEIN", AV_DECIMAL))
	Case cTipoRat == "3" //Quantidade
		oRatFrete   := EasyRateio():New(nFRETEIN, nTotQtde_Inv, nContSW8, AvSx3("W8_FRETEIN", AV_DECIMAL))
EndCase
If EasyGParam("MV_RAT_INL",, 1) == 2 //1-Por FOB;2-Por Peso
    oRatInland  := EasyRateio():New(nINLAND , nTotPeso_Inv, nContSW8, AvSx3("W8_INLAND" , AV_DECIMAL))
Else
    oRatInland  := EasyRateio():New(nINLAND , nTotFob_Inv, nContSW8, AvSx3("W8_INLAND" , AV_DECIMAL))
EndIf
oRatPacking := EasyRateio():New(nPACKING, nTotFob_Inv, nContSW8, AvSx3("W8_PACKING", AV_DECIMAL))
oRatOutDes  := EasyRateio():New(nOUTDESP, nTotFob_Inv, nContSW8, AvSx3("W8_OUTDESP", AV_DECIMAL))
oRatDescon  := EasyRateio():New(nDESCONT, nTotFob_Inv, nContSW8, AvSx3("W8_DESCONT", AV_DECIMAL))

nCont:= EasyRecCount("Work_SW8")
ProcRegua(nCont)

DO WHILE Work_SW8->(!EOF()) .AND. Work_SW8->WKINVOICE==cInvoice .AND.;
                                  Work_SW8->WKFORN   ==cForn    .And.;
                                  (!EICLoja() .Or. Work_SW8->W8_FORLOJ == cLoja)

   IncProc(STR0460+Work_SW8->WKCOD_I) //"Calculando Item: "

   IF EMPTY(Work_SW8->WKFLAGIV)
      Work_SW8->(DBSKIP())
      LOOP
   ENDIF

   SB1->(dbSeek(xFilial("SB1")+Work_SW8->WKCOD_I))
   IF lRatPorFOB
      IF SB1->B1_MIDIA $ cSIM  .AND. lExiste_Midia .AND. lPesoMid   // LDR - 25/08/04
         SW2->(DBSEEK(xFILIAL("SW2")+Work_SW8->WKPO_NUM))
         WORK->(DBSEEK(Work_SW8->WKPO_NUM+Work_SW8->WKPGI_NUM+Work_SW8->WKPOSICAO))
         If EasyGParam("MV_RAT_INL",, 1) == 1 //JVR - 05/11/2009 - Rateio INLAND
            //Work_SW8->WKINLAND  :=DI500Trans(((Work_SW8->WKQTDE*SB1->B1_QTMIDIA*SW2->W2_VLMIDIA)/nTotFob_Inv)*nINLAND )
            Work_SW8->WKINLAND := oRatInland:GetItemRateio(Work_SW8->WKQTDE*SB1->B1_QTMIDIA*SW2->W2_VLMIDIA) //THTS - 21/11/2017
         EndIf
         //Work_SW8->WKPACKING :=DI500Trans(((Work_SW8->WKQTDE*SB1->B1_QTMIDIA*SW2->W2_VLMIDIA)/nTotFob_Inv)*nPACKING)
         //Work_SW8->WKDESCONT :=DI500Trans(((Work_SW8->WKQTDE*SB1->B1_QTMIDIA*SW2->W2_VLMIDIA)/nTotFob_Inv)*nDESCONT)
         //Work_SW8->WKOUTDESP :=DI500Trans(((Work_SW8->WKQTDE*SB1->B1_QTMIDIA*SW2->W2_VLMIDIA)/nTotFob_Inv)*nOUTDESP)
         Work_SW8->WKPACKING := oRatPacking:GetItemRateio(Work_SW8->WKQTDE*SB1->B1_QTMIDIA*SW2->W2_VLMIDIA) //THTS - 16/11/2017
         Work_SW8->WKDESCONT := oRatDescon:GetItemRateio(Work_SW8->WKQTDE*SB1->B1_QTMIDIA*SW2->W2_VLMIDIA) //THTS - 16/11/2017
         Work_SW8->WKOUTDESP := oRatOutDes:GetItemRateio(Work_SW8->WKQTDE*SB1->B1_QTMIDIA*SW2->W2_VLMIDIA) //THTS - 16/11/2017
      ELSE
         If EasyGParam("MV_RAT_INL",, 1) == 1 //JVR - 05/11/2009 - Rateio INLAND
            //Work_SW8->WKINLAND  :=DI500Trans((Work_SW8->WKPRTOTMOE/nTotFob_Inv)*nINLAND )
            Work_SW8->WKINLAND := oRatInland:GetItemRateio(Work_SW8->WKPRTOTMOE) //THTS - 21/11/2017
         EndIf
         //Work_SW8->WKPACKING :=DI500Trans((Work_SW8->WKPRTOTMOE/nTotFob_Inv)*nPACKING)
         Work_SW8->WKPACKING := oRatPacking:GetItemRateio(Work_SW8->WKPRTOTMOE) //THTS - 16/11/2017

         IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"RATEIA_DESC_INV"),)

         //MCF - 28/01/2015 Variável que permite manipular a forma do rateio entre os itens da invoice no ponto de entrada RATEIA_DESC_INV.
         If lAlteraRateio
         	//Work_SW8->WKDESCONT :=DI500Trans((Work_SW8->WKPRTOTMOE/nTotFob_Inv)*nDESCONT)
            Work_SW8->WKDESCONT := oRatDescon:GetItemRateio(Work_SW8->WKPRTOTMOE) //THTS - 16/11/2017
         Endif
         //Work_SW8->WKOUTDESP :=DI500Trans((Work_SW8->WKPRTOTMOE/nTotFob_Inv)*nOUTDESP)
         Work_SW8->WKOUTDESP := oRatOutDes:GetItemRateio(Work_SW8->WKPRTOTMOE) //THTS - 16/11/2017
      ENDIF
   ENDIF

   IF !EMPTY(nFRETEIN) .AND. lRatFrete
      IF lCalcula
         DO CASE
            CASE cTipoRat == "1" //Peso
                 IF SB1->B1_MIDIA $ cSIM .AND. lExiste_Midia .AND. lPesoMid   // LDR - 25/08/04
                    //Work_SW8->WKFRETEIN:=DI500Trans(((Work_SW8->WKQTDE*SB1->B1_QTMIDIA*Work->WKPESOMID)/nTotPeso_Inv)*nFRETEIN)
                    Work_SW8->WKFRETEIN := oRatFrete:GetItemRateio(Work_SW8->WKQTDE*SB1->B1_QTMIDIA*Work->WKPESOMID) //THTS - 21/11/2017
                    If EasyGParam("MV_RAT_INL",, 1) == 2 //JVR - 05/11/2009 - Rateio INLAND
                       //Work_SW8->WKINLAND := DI500Trans(((Work_SW8->WKQTDE*SB1->B1_QTMIDIA*Work->WKPESOMID)/nTotPeso_Inv)*nINLAND)
                       Work_SW8->WKINLAND := oRatInland:GetItemRateio(Work_SW8->WKQTDE*SB1->B1_QTMIDIA*Work->WKPESOMID) //THTS - 21/11/2017
                    EndIf
                 ELSE
                    //Work_SW8->WKFRETEIN:=DI500Trans((Work_SW8->WKPESOTOT/nTotPeso_Inv)*nFRETEIN)
                    Work_SW8->WKFRETEIN := oRatFrete:GetItemRateio(Work_SW8->WKPESOTOT) //THTS - 21/11/2017
                    If EasyGParam("MV_RAT_INL",, 1) == 2 //JVR - 05/11/2009 - Rateio INLAND
                       //Work_SW8->WKINLAND := DI500Trans((Work_SW8->WKPESOTOT/nTotPeso_Inv)*nINLAND)
                       Work_SW8->WKINLAND := oRatInland:GetItemRateio(Work_SW8->WKPESOTOT) //THTS - 21/11/2017
                    EndIf
                 ENDIF
            CASE cTipoRat == "2" //Preco
                 IF SB1->B1_MIDIA $ cSIM  .AND. lExiste_Midia .AND. lPesoMid   // LDR - 25/08/04
                    //Work_SW8->WKFRETEIN:=DI500Trans(((Work_SW8->WKQTDE * SB1->B1_QTMIDIA * SW2->W2_VLMIDIA)/nTotFob_Inv)*nFRETEIN)
                    Work_SW8->WKFRETEIN := oRatFrete:GetItemRateio(Work_SW8->WKQTDE * SB1->B1_QTMIDIA * SW2->W2_VLMIDIA) //THTS - 21/11/2017
                 ELSE
                    //Work_SW8->WKFRETEIN:=DI500Trans((Work_SW8->WKPRTOTMOE/nTotFob_Inv)*nFRETEIN)
                    Work_SW8->WKFRETEIN := oRatFrete:GetItemRateio(Work_SW8->WKPRTOTMOE) //THTS - 21/11/2017
                 ENDIF
            CASE cTipoRat == "3" //Quantidade
                 IF SB1->B1_MIDIA $ cSIM  .AND. lExiste_Midia .AND. lPesoMid   // LDR - 25/08/04
                    //Work_SW8->WKFRETEIN:=DI500Trans(((Work_SW8->WKQTDE * SB1->B1_QTMIDIA) /nTotQtde_Inv)*nFRETEIN)
                    Work_SW8->WKFRETEIN := oRatFrete:GetItemRateio(Work_SW8->WKQTDE * SB1->B1_QTMIDIA) //THTS - 21/11/2017
                 ELSE
                    //Work_SW8->WKFRETEIN:=DI500Trans((Work_SW8->WKQTDE /nTotQtde_Inv)*nFRETEIN)
                    Work_SW8->WKFRETEIN := oRatFrete:GetItemRateio(Work_SW8->WKQTDE) //THTS - 21/11/2017
                 ENDIF
         ENDCASE
      ELSE
         Work_SW8->WKFRETEIN:=0
      ENDIF
   ELSEIF lRatFrete
      Work_SW8->WKFRETEIN:=0
      If EasyGParam("MV_RAT_INL",, 1) == 2 //JVR - 05/11/2009 - Rateio INLAND
         //Work_SW8->WKINLAND := DI500Trans((Work_SW8->WKPESOTOT/nTotPeso_Inv)*nINLAND)
         Work_SW8->WKINLAND := oRatInland:GetItemRateio(Work_SW8->WKPESOTOT) //THTS - 21/11/2017
      EndIf
   ENDIF

   // EOB - 20/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
   IF lSegInc
      IF !EMPTY(nSEGURO) .AND. lRatPorFOB
         IF lCalSeg
            //Work_SW8->WKSEGURO:=DI500Trans((Work_SW8->WKPRTOTMOE/nTotFob_Inv)*nSEGURO)
            Work_SW8->WKSEGURO := oRatSeguro::GetItemRateio(Work_SW8->WKPRTOTMOE) //THTS - 16/11/2017
         ELSE
            Work_SW8->WKSEGURO:=0
         ENDIF
      ELSE
         Work_SW8->WKSEGURO:=0
      ENDIF
   ENDIF

   IF lRatPorFOB
      aAcertos[1,1]+=Work_SW8->WKINLAND
      aAcertos[2,1]+=Work_SW8->WKPACKING
      aAcertos[3,1]+=Work_SW8->WKDESCONT
      aAcertos[4,1]+=Work_SW8->WKOUTDESP
      // EOB - 20/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
      IF lSegInc
         aAcertos[6,1]+=Work_SW8->WKSEGURO
      ENDIF
   ENDIF
   IF lRatFrete
      aAcertos[5,1]+=Work_SW8->WKFRETEIN
   ENDIF

   IF lRatPorFOB .AND. Work_SW8->WKPRTOTMOE > nMaiorVlr
      nMaiorVlr:=Work_SW8->WKPRTOTMOE
      nRecVlr  :=Work_SW8->(RECNO())
   ENDIF

   IF lRatFrete .AND. Work_SW8->WKFRETEIN > nMaiorFre
      nMaiorFre:=Work_SW8->WKFRETEIN
      nRecFre  :=Work_SW8->(RECNO())
   ENDIF

   Work_SW8->(DBSKIP())

ENDDO

IF lRatPorFOB
   Work_SW8->(DBGOTO(nRecVlr))
   FOR A := 1 TO 4
      IF !EMPTY(aAcertos[A,1]) .AND.  aAcertos[A,2] # aAcertos[A,1]
         IF(A=1,Work_SW8->WKINLAND += DI500Trans(aAcertos[A,2] - aAcertos[A,1]),)
         IF(A=2,Work_SW8->WKPACKING+= DI500Trans(aAcertos[A,2] - aAcertos[A,1]),)
         IF(A=3,Work_SW8->WKDESCONT+= DI500Trans(aAcertos[A,2] - aAcertos[A,1]),)
         IF(A=4,Work_SW8->WKOUTDESP+= DI500Trans(aAcertos[A,2] - aAcertos[A,1]),)
      ENDIF
   NEXT
ENDIF

IF lRatFrete
   IF !EMPTY(nFRETEIN) .AND. lCalcula
      Work_SW8->(DBGOTO(nRecFre))
      IF !EMPTY(aAcertos[5,1]) .AND. aAcertos[5,2] # aAcertos[5,1]
         Work_SW8->WKFRETEIN+=DI500Trans(aAcertos[5,2] - aAcertos[5,1])
      ENDIF
   ENDIF
ENDIF

// EOB - 20/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
IF lSegInc .AND. lRatPorFOB
   IF !EMPTY(nSEGURO) .AND. lCalSeg
      Work_SW8->(DBGOTO(nRecVlr))
      IF !EMPTY(aAcertos[6,1]) .AND. aAcertos[6,2] # aAcertos[6,1]
         Work_SW8->WKSEGURO+=DI500Trans(aAcertos[6,2] - aAcertos[6,1])
      ENDIF
   ENDIF
ENDIF

aValRat := Aclone(aAcertos) //LGS-26/11/2014
DI500ValRat()

Work_SW8->(DbGoTop())    // GFP - 02/03/2013
Do While Work_SW8->(!Eof())
   If Work_SW8->WKINLAND  < 0 .OR. Work_SW8->WKFRETEIN < 0 .OR.;
      Work_SW8->WKPACKING < 0 .OR. Work_SW8->WKFRETEIN < 0 .OR.;
      Work_SW8->WKOUTDESP < 0 .OR. Work_SW8->WKDESCONT < 0          //Valor negativo
      MsgInfo(STR0838,STR0558)    //  "Após o rateio, existem valores negativos no processo." #### "Aviso"
      Exit
   EndIf
   Work_SW8->(DBSkip())
EndDo

Work_SW8->(DBSETORDER(nOrder))
Work_SW8->(DBGOTO(nRecno))
//MFR 05/11/2020 OSSME-5299
DI500RstFil(lMemoria,cOldFilter)
//DFS - 31/01/13 - Inclusão de foco na tela.
IF oBrw # NIL
   oBrw:Refresh()
   oBrw:Reset()
   oBrw:SetFocus()
ENDIF

RETURN .T.

Function DI500Totais(oBrow)
Local oMark
LOCAL oDlgTotal, aOk:={|| oDlgTotal:End() }
PRIVATE lTotaisInv:=.F.
Private cTitTotal := STR0636 //STR0636 "TOTAIS DO PROCESSO"

IF !Inclui .AND. lPrimeiraVez
   IF nPos_aRotina = VISUAL .OR. nPos_aRotina = ESTORNO
      IF Work_SW8->(EasyRecCount("Work_SW8")) == 0
         Processa({|| DI500InvCarrega()},STR0054) //"Pesquisa de Itens"
      ENDIF
   ELSE
      Processa({|| DI500Existe()    },STR0054) //"Pesquisa de Itens"
   ENDIF
ENDIF

Processa({|| DI500SomaTotais() },STR0461)  //"Somando totais"
IF Work_Tot->(BOF()) .AND. Work_Tot->(EOF())
   Help("",1,"AVG0000710")//"Nao existe itens selecionados para Totalizar."
   Return .f.
ENDIF

aTB_CpoTot:={}
IF lTotaisInv
   AADD(aTB_CpoTot,{"W9_INVOICE" ,,AVSX3("W9_INVOICE",5)})
ENDIF
AADD(aTB_CpoTot,{"W9_MOE_FOB" ,,AVSX3("W9_MOE_FOB",5),AVSX3("W9_MOE_FOB",6)})
AADD(aTB_CpoTot,{"W9_FOB_TOT" ,,AVSX3("W9_FOB_TOT",5),AVSX3("W9_FOB_TOT",6)})
AADD(aTB_CpoTot,{"W9_INLAND"  ,,AVSX3("W9_INLAND" ,5),AVSX3("W9_INLAND" ,6)})
AADD(aTB_CpoTot,{"W9_PACKING" ,,AVSX3("W9_PACKING",5),AVSX3("W9_PACKING",6)})
AADD(aTB_CpoTot,{"W9_DESCONT" ,,AVSX3("W9_DESCONT",5),AVSX3("W9_DESCONT",6)})
AADD(aTB_CpoTot,{"W9_FRETEIN" ,,AVSX3("W9_FRETEIN",5),AVSX3("W9_FRETEIN",6)})
AADD(aTB_CpoTot,{"W9_OUTDESP" ,,AVSX3("W9_OUTDESP",5),AVSX3("W9_OUTDESP",6)})
// EOB - 20/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
IF lSegInc
   AADD(aTB_CpoTot,{"W9_SEGURO" ,,AVSX3("W9_SEGURO",5),AVSX3("W9_SEGURO",6)})
ENDIF
AADD(aTB_CpoTot,{"W6_FOB_TOT" ,,STR0158        ,AVSX3("W6_FOB_TOT",6)}) //"Total Geral"

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"TELA_TOTAIS"),)  // GFP - 10/06/2014

Work_Tot->(DBGOTOP())
DEFINE MSDIALOG oDlgTotal TITLE cTitTotal FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 ;
                                           TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
                                           OF oMainWnd PIXEL

   oMark:=MSSELECT():New("Work_Tot",,,aTB_CpoTot,lInverte,cMarca,{17,1,(oDlgTotal:nClientHeight-4)/2,(oDlgTotal:nClientWidth-4)/2})
   oMark:oBrowse:bWhen:={||DBSELECTAREA("Work_Tot"),.T.}
   oDlgTotal:lMaximized:=.T.  //LRL 26/03/04 - Maximiliza Janela
   oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
ACTIVATE MSDIALOG oDlgTotal ON INIT (EnchoiceBar(oDlgTotal,aOk,{|| oDlgTotal:End() },,),;
                                     oMark:oBrowse:Refresh()) // LRL 26/03/04 -Alinhamento MDI

IF Type("oBrow") = "O"
   oBrow:oBrowse:Refresh()
ENDIF

RETURN .T.

Function DI500SomaTotais()

LOCAL cAlias:='Work_SW8',T

Work_SW8->(DBSETORDER(1))
Work_SW9->(DBSETORDER(1))
Work_SW9->(DBGOTOP())
DO WHILE !Work_SW9->(EOF())
   IF WORK_SW9->W9_TUDO_OK == NAO .AND.;
      Work_SW8->(DBSEEK(Work_SW9->W9_INVOICE+Work_SW9->W9_FORN+WORK_SW9->W9_FORLOJ))
      IF DI500InvConf(.F.,Work_SW9->W9_INVOICE,Work_SW9->W9_FORN,.T., WORK_SW9->W9_FORLOJ)
         DI500InvTotais(.F.,.F.)
      ENDIF
   ENDIF
   Work_SW9->(DBSKIP())
ENDDO

Work_SW9->(DBSETORDER(1))
Work_Tot->(avzap())
// WNM 05/05/09 FOR T := 1 TO 2
FOR T := 1 TO 3// WNM 05/05/09

  IF T = 2
     IF Work_Tot->(EasyRecCount("Work_Tot")) # 0// Se tiver itens de invoice nao precisa do while Work
        EXIT
     ENDIF
     cAlias := 'Work'
  ENDIF

  IF T = 3 // WNM 05/05/09
     IF Work_Tot->(EasyRecCount("Work_Tot")) # 0// Se tiver itens de invoice nao precisa do while Work
        EXIT
     ENDIF
     cAlias := 'TRB'
  ENDIF    // WNM 05/05/09

  IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"TOTAIS_1"),)
  If Select(cAlias) = 0
     Return .T.
  EndIf
  ProcRegua((cAlias)->(EasyRecCount(cAlias)))
  (cAlias)->(DBSETORDER(1))
  (cAlias)->(DBGOTOP())
  DO While !(cAlias)->(Eof())
     IF cAlias == 'Work_SW8'
        IncProc(STR0463+Work_SW8->WKINVOICE) //"Somando Invoice: "        
        IF !nPos_aRotina = VISUAL .AND. !nPos_aRotina = ESTORNO
           IF EMPTY(Work_SW8->WKFLAGIV) .OR. EMPTY(Work_SW8->WKINVOICE)
              Work_SW8->(DBSKIP())
              LOOP
           ENDIF
        ENDIF
        
        lLoop:=.F.

        IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"SOMA_TOTAIS_SW8"),)

        IF lLoop
            WORK_SW8->(DBSKIP())
            LOOP
        ENDIF
        IF lTotaisInv
           Work_Tot->(DBSETORDER(1))
           IF !Work_Tot->(DBSEEK('1'+Work_SW8->WKINVOICE+Work_SW8->WKFORN+Work_SW8->W8_FORLOJ))
              Work_Tot->(DBAPPEND())
              Work_Tot->WKCODIGO  :='1'
              Work_Tot->W9_INVOICE:=Work_SW8->WKINVOICE
              Work_Tot->W9_FORN   :=Work_SW8->WKFORN
              If EICLoja()
                 Work_Tot->W9_FORLOJ := Work_SW8->W8_FORLOJ
              EndIf
              Work_Tot->W9_MOE_FOB:=Work_SW8->WKMOEDA
              Work_Tot->TRB_ALI_WT:="SW9"
              Work_Tot->TRB_REC_WT:=SW9->(Recno())
              //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
              Work_SW9->(DBSEEK(Work_SW8->WKINVOICE+Work_SW8->WKFORN+Work_SW8->W8_FORLOJ+M->W6_HAWB))
           ENDIF
           Work_Tot->W9_FOB_TOT+=Work_SW8->WKPRTOTMOE
           Work_Tot->W9_INLAND +=Work_SW8->WKINLAND
           Work_Tot->W9_PACKING+=Work_SW8->WKPACKING
           Work_Tot->W9_DESCONT+=Work_SW8->WKDESCONT
           Work_Tot->W9_FRETEIN+=Work_SW8->WKFRETEIN
           Work_Tot->W9_OUTDESP+=Work_SW8->WKOUTDESP
           // EOB - 20/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
           IF lSegInc
              Work_Tot->W9_SEGURO+=Work_SW8->WKSEGURO
           ENDIF
           Work_Tot->W6_FOB_TOT += DI500Trans(DI500RetVal("ITEM_INV", "WORK", .T.)) // EOB - 20/06/08 - chamada da função DI500RetVal

           IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"TOTAIS_2"),)
        ENDIF
        Work_Tot->(DBSETORDER(2))
        IF !Work_Tot->(DBSEEK('2'+Work_SW8->WKMOEDA))
           Work_Tot->(DBAPPEND())
           Work_Tot->WKCODIGO  :='2'
           Work_Tot->W9_INVOICE:=STR0464 //"Total Moeda:"
           Work_Tot->W9_MOE_FOB:=Work_SW8->WKMOEDA
           Work_Tot->TRB_ALI_WT:="SW9"
           Work_Tot->TRB_REC_WT:=SW9->(Recno())
           //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
           Work_SW9->(DBSEEK(Work_SW8->WKINVOICE+Work_SW8->WKFORN+Work_SW8->W8_FORLOJ+M->W6_HAWB)) //AAF 26/03/2009 - Posicionar W9 tambem para total tipo '2'
        ENDIF

        Work_Tot->W9_FOB_TOT+=Work_SW8->WKPRTOTMOE
        Work_Tot->W9_INLAND +=Work_SW8->WKINLAND
        Work_Tot->W9_PACKING+=Work_SW8->WKPACKING
        Work_Tot->W9_DESCONT+=Work_SW8->WKDESCONT
        Work_Tot->W9_FRETEIN+=Work_SW8->WKFRETEIN
        Work_Tot->W9_OUTDESP+=Work_SW8->WKOUTDESP
        // EOB - 20/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
        IF lSegInc
           Work_Tot->W9_SEGURO+=Work_SW8->WKSEGURO
        ENDIF
        Work_Tot->W6_FOB_TOT+=DI500Trans(DI500RetVal("ITEM_INV", "WORK", .T.)) // EOB - 20/06/08 - chamada da função DI500RetVal
        IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"TOTAIS_3"),)

    ELSEIF cAlias == 'Work'
        IncProc(STR0465+Work->WKMOEDA) //"Somando Moeda: "
        IF !nPos_aRotina = VISUAL .AND. !nPos_aRotina = ESTORNO
           IF !WORK->WKFLAG
              WORK->(DBSKIP())
              LOOP
           ENDIF
        ENDIF
        Work_Tot->(DBSETORDER(2))
        IF !Work_Tot->(DBSEEK('3'+Work->WKMOEDA))
           Work_Tot->(DBAPPEND())
           Work_Tot->WKCODIGO  :='3'
           Work_Tot->W9_INVOICE:=STR0464 //"Total Moeda:"
           Work_Tot->W9_MOE_FOB:=Work->WKMOEDA
           Work_Tot->TRB_ALI_WT:="SW9"
           Work_Tot->TRB_REC_WT:=SW9->(Recno())
        ENDIF

        Work_Tot->W9_FOB_TOT+=DI500Trans(Work->WKQTDE*Work->WKPRECO)
        Work_Tot->W6_FOB_TOT+=DI500Trans(Work->WKQTDE*Work->WKPRECO)
        IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"TOTAIS_4"),)
// WNM 05/05/09
    ELSEIF cAlias == 'TRB'
        SW2->(DBSETORDER(1))
        SW2->(DBSEEK(xFilial()+TRB->W7_PO_NUM))
        IncProc(STR0465+SW2->W2_MOEDA) //"Somando Moeda: "
        Work_Tot->(DBSETORDER(2))
        IF !Work_Tot->(DBSEEK('3'+SW2->W2_MOEDA))
           Work_Tot->(DBAPPEND())
           Work_Tot->WKCODIGO  :='3'
           Work_Tot->W9_INVOICE:=STR0464 //"Total Moeda:"
           Work_Tot->W9_MOE_FOB:=SW2->W2_MOEDA
           Work_Tot->TRB_ALI_WT:="SW7"
           Work_Tot->TRB_REC_WT:=TRB->TRB_REC_WT
        ENDIF

        Work_Tot->W9_FOB_TOT+=DI500Trans(TRB->W7_QTDE*TRB->W7_PRECO)
        Work_Tot->W6_FOB_TOT+=DI500Trans(TRB->W7_QTDE*TRB->W7_PRECO)
        IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"TOTAIS_5"),)

// WNM 05/05/09
    ENDIF
    (cAlias)->(DBSKIP())
  ENDDO
  (cAlias)->(DBGOTOP())

NEXT
Work_SW9->(DBGOTOP())
RETURN .T.

Function DI500Adicoes(oBrw)

LOCAL nTipo:=2,aOK:=NIL
PRIVATE aBotoesEIJ:={}
PRIVATE cPictCGC:=AVSX3('W6_CGC_OUT',6)
PRIVATE aCposNaoMostra:={'EIJ_VSEGLE','EIJ_VLFRET','EIJ_MOEFRE','EIJ_MOESEG','EIJ_TX_SEG','EIJ_TX_FRE','EIJ_RATACR','EIJ_TEC_CL','EIJ_MERCOS'}
PRIVATE aCposAtoLegal :={'EIJ_ASSVIC','EIJ_EX_VIC','EIJ_ATOVIC','EIJ_ORGVIC','EIJ_NROVIC','EIJ_ANOVIC',;
                         'EIJ_ASSVIB','EIJ_EX_VIB','EIJ_ATOVIB','EIJ_ORGVIB','EIJ_NROVIB','EIJ_ANOVIB'}
PRIVATE aCposIIAcoTar :={'EIJ_ASSII ','EIJ_EX_II ','EIJ_ATO_II','EIJ_ORG_II','EIJ_NRATII','EIJ_ANO_II'}
PRIVATE aCposIPIAcoTar:={'EIJ_ASSIPI','EIJ_EX_IPI','EIJ_ATOIPI','EIJ_ORGIPI','EIJ_NROIPI','EIJ_ANOIPI'}
PRIVATE aCposEIJ:={},lIncluiEIJ:=LExcluiEIJ:=.F.
PRIVATE nAcertaFOB:=0//Usada na Aplicacao do Modelo
PRIVATE lGravouEIN:=.F.//AWR - 11/01/2005 - Por causa do botao Aplica Modelo
PRIVATE cTitManutAdicao := STR0473	//Johann - 06/07/2005

If AvFlags("DUIMP") .AND. M->W6_TIPOREG == "2" 
   EasyHelp(STR0927, STR0929 ,STR0928) //"Processo do tipo DUIMP não permite adições", "Aviso","Se o seu processo for do tipo DUIMP, acesse a ação Itens DUIMP no browse. Caso seu processo seja do tipo D.I., alterar o campo Tp.Registro para 1-DI, na aba Di./Duimp do desembaraço"
   RETURN .T.
EndIf

SX3->(DBSETORDER(1))
IF SX3->(DBSEEK("EIJ"))
   DO WHILE SX3->(!EOF()) .AND. SX3->X3_ARQUIVO == "EIJ"
      IF ASCAN(aCposNaoMostra,SX3->X3_CAMPO) # 0 .OR.;
         ASCAN(aCposAtoLegal ,SX3->X3_CAMPO) # 0 .OR.;
         ASCAN(aCposIIAcoTar ,SX3->X3_CAMPO) # 0 .OR.;
         ASCAN(aCposIPIAcoTar,SX3->X3_CAMPO) # 0 .OR.;
         !X3Uso(SX3->X3_USADO) .OR. SX3->X3_NIVEL > cNivel
         SX3->(dbSkip())
         Loop
      ENDIF
      AADD(aCposEIJ,SX3->X3_CAMPO)
      SX3->(DBSKIP())
   ENDDO
   SX3->(DBSEEK("EIJ"))
ELSE
   RETURN .F.
ENDIF

IF !Inclui .AND. lPrimeiraVez
   IF nPos_aRotina = VISUAL .OR. nPos_aRotina = ESTORNO
         // AWR - 13/09/2004 - Nao pode testar o EIJ pq sempre esta preenchido
         Processa({|| DI500EIGrava('LEITURA',SW6->W6_HAWB,aAliasAdic)},STR0466) //"Lendo Adicoes..."
   ELSE
      Processa({|| DI500Existe() },STR0054) //"Pesquisa de Itens"
   ENDIF
ENDIF

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ANT_GERA_ADICAO"),)

Work_EIJ->(DBGOTOP())
IF nPos_aRotina # VISUAL .AND. nPos_aRotina # ESTORNO

   IF !EMPTY(M->W6_DTREG_D) .AND. !lRetifica .AND. lTemAdicao // LDR - 04/01/05 - DEICMAR
      MsgInfo(STR0637) //STR0637 "Adicao nao pode ser alterada pois a data de registro da Di ja foi preenchida."
      Return .T.
   ENDIF

   Work_SW8->(DBGOTOP())
   IF WORK_SW8->(BOF()) .AND. WORK_SW8->(EOF())
      Help("",1,"AVG0000700")//Nao ha Invoices para gerar Adicoes.",0057) //0467
      RETURN .T.
   ENDIF

   Work_SW8->(DBSETORDER(1))
   Work_SW9->(DBGOTOP())

   DO WHILE !Work_SW9->(EOF())
      IF WORK_SW9->W9_TUDO_OK == NAO .AND.;
         Work_SW8->(DBSEEK(Work_SW9->W9_INVOICE+Work_SW9->W9_FORN+Work_SW8->W8_FORLOJ))
         IF DI500InvConf(.F.,Work_SW9->W9_INVOICE,Work_SW9->W9_FORN,.T.,Work_SW8->W8_FORLOJ)
            Processa( {|| DI500InvTotais(.F.,.F.) } )
         ELSE
            RETURN .T.
         ENDIF
      ENDIF
      Work_SW9->(DBSKIP())
   ENDDO

   DI500Controle(3,{M->W6_VLFRECC,M->W6_VLFREPP,M->W6_VLFRETN,M->W6_VLSEGMN,M->W6_VL_USSE,M->W6_SEGBASE,M->W6_SEGPERC,M->W6_TX_FRET})

      lTemRegBranco:=.F.
      Processa({|| lTemRegBranco:=DI500MarkReg(,.T.) })
      IF lTemRegBranco
         Help("",1,"AVG0005350")//LRL - 08/01/04  - MSGINFO("Existem Itens de Invoice sem Regime de Tributacao.")
         RETURN .T.
      ENDIF

   Work_EIJ->(DBSETORDER(1))
   Work_EIJ->(DBGOTOP())
   IF (Work_EIJ->(BOF()) .AND. Work_EIJ->(EOF())) .OR.;
      !(M->W6_ADICAOK $ cSim) .OR. Work_EIJ->EIJ_ADICAO = "MOD"
	  If MsgYesNo("Este processo ainda não possui adições. Deseja gera-las?")
         Processa({|| DI500GeraAdicoes()},STR0342) //"Gerando Adicoes..."
	  EndIf
   ENDIF

ELSE
   IF Work_EIJ->(BOF()) .AND. Work_EIJ->(EOF())
      Help("",1,"AVG0000711")//Nao ha Adicoes para Consulta.",0057) //0468
      RETURN .T.
   ENDIF
ENDIF

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"POS_GERA_ADICAO"),)

aTB_CposEIJ:=ArrayBrowse("EIJ","WORK_EIJ")
IF lZeraDespis .AND. EIJ->(FIELDPOS("EIJ_ICMSPI")) !=0
   AADD(aTB_CposEIJ,{"EIJ_ICMSPI",,AVSX3("EIJ_ICMSPI",5),AVSX3("EIJ_ICMSPI",6)})
ENDIF
IF EIJ->(FIELDPOS("EIJ_TAXSIS")) = 0
   AADD(aTB_CposEIJ,{"EIJ_TAXSIS",,"Taxa SISCOMEX",AVSX3("W8_BASEICM",6)})
ENDIF
// SVG - 30/07/2009 -
IF EIJ->(FIELDPOS("EIJ_CALIPI")) != 0
   AADD(aTB_CposEIJ,{"EIJ_CALIPI",,AVSX3("EIJ_CALIPI",5),AVSX3("EIJ_CALIPI",6)})
ENDIF

//TRP - 22/02/2010
IF EIJ->(FIELDPOS("EIJ_ARDPIS")) != 0
   AADD(aTB_CposEIJ,{"EIJ_ARDPIS",,AVSX3("EIJ_ARDPIS",5),AVSX3("EIJ_ARDPIS",6)})
ENDIF

//TRP - 22/02/2010
IF EIJ->(FIELDPOS("EIJ_ARDCOF")) != 0
   AADD(aTB_CposEIJ,{"EIJ_ARDCOF",,AVSX3("EIJ_ARDCOF",5),AVSX3("EIJ_ARDCOF",6)})
ENDIF

//TRP - 22/07/2010 - Campo para Admissão Temporária
IF EIJ->(FIELDPOS("EIJ_ALPROP")) != 0
   AADD(aTB_CposEIJ,{"EIJ_ALPROP",,AVSX3("EIJ_ALPROP",5),AVSX3("EIJ_ALPROP",6)})
ENDIF

aTelaSW6:=ACLONE(aTela)//Devem ser salvos antes da chamada da DI500Invoices() se nao ocorre erro
aGetsSW6:=ACLONE(aGets)

IF nPos_aRotina # VISUAL
   AADD(aBotoesEIJ,{"BAIXATIT" /*"VERNOTA"*/  ,{|| DI500Invoices() },STR0425,Nil}) //"Invoices"
   AADD(aBotoesEIJ,{"COLGERA"  ,{|| Processa({|| DI500GeraAdicoes()},STR0342) },STR0469,STR0638}) //"Gerando Adicoes..."###"Gera Adicoes" //STR0638 "Gera Adi"
   AADD(aBotoesEIJ,{"PESQUISA" /*"LOCALIZA"*/ ,{|| DI500EIJItens() },STR0470,STR0537}) //"Itens Adicoes" -   "Itens.Adi"
   IF lIncluiEIJ
      AADD(aBotoesEIJ,{"BMPINCLUIR",{|| DI500EIJManut(1,oMarkEIJ)},STR0031}) //"Incluir"
   ENDIF
   AADD(aBotoesEIJ,{"EDIT"     ,{|| DI500EIJManut(2,oMarkEIJ)},STR0032}) //"Alterar" IC_17
   AADD(aBotoesEIJ,{"BMPGROUP" ,{|| DI500EIJManut(5,oMarkEIJ)},STR0471,STR0530}) //"Modelo de Adicoes" -  "Model.Adi"
   AADD(aBotoesEIJ,{"SOLICITA" ,{|| Processa({|| DI500AplicaMod(3,oMarkEIJ)})} ,STR0472,STR0538}) //"Aplica Modelo" -  "Apli.Mode"
   IF LExcluiEIJ
      AADD(aBotoesEIJ,{"EXCLUIR"  ,{|| DI500EIJManut(3,oMarkEIJ)},STR0153}) //STR0153  "Excluir"
   ENDIF
   AADD(aBotoesEIJ,{"SIMULACAO" ,{|| DI500AdiTotais(.T.)  },STR0639,STR0539 })//LRL 25/03/04  "Total.Imp" //STR0639 "Totais Impostos"

ELSE
   AADD(aBotoesEIJ,{"PESQUISA" /*"LOCALIZA"*/,{|| DI500EIJItens() },STR0470,STR0537}) //"Itens Adicoes" -  "Itens.Adi"
   AADD(aBotoesEIJ,{"BMPVISUAL" /*'PESQUISA'*/,{|| DI500EIJManut(4,oMarkEIJ)},STR0450,STR0533}) //"Visualizacao" -  "Visuali."
   nTipo:=4
ENDIF
AADD(aBotoesEIJ,{"PREV",{|| oDlgAdicao:End()},STR0429/*,STR0512*/}) //"Tela Anterior" -   "Anterior"

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"BROWSE_WORK_EIJ"),)

DO WHILE .T.

   aGets:={}
   aTela:={}
   Work_EIJ->(DBGOTOP())

   DEFINE MSDIALOG oDlgAdicao TITLE cTitManutAdicao ; //"Manutencao de Adicoes"
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 ;
          TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd PIXEL

   //by GFP - 30/09/2010 :: 11:01 - Inclusão da função para carregar campos criados pelo usuario.
   aTB_CposEIJ := AddCpoUser(aTB_CposEIJ,"EIJ","2")

   oMarkEIJ:=MSSELECT():New("WORK_EIJ",,,aTB_CposEIJ,lInverte,cMarca,{15,1,(oDlgAdicao:nClientHeight-6)/2,(oDlgAdicao:nClientWidth-4)/2})
   oMarkEIJ:bAval:={|| DI500EIJManut(nTipo,oMarkEIJ)}
   oMarkEIJ:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT //Alinhamento MDI
   oDlgAdicao:lMaximized:=.T.

   ACTIVATE MSDIALOG oDlgAdicao ON INIT (oMarkEIJ:oBrowse:Refresh(), EnchoiceBar(oDlgAdicao,{|| oDlgAdicao:End()},{|| oDlgAdicao:End()},,aBotoesEIJ))
   EXIT
ENDDO

aTela:=ACLONE(aTelaSW6)
aGets:=ACLONE(aGetsSW6)
Work->(DBGOTOP())
IF oBrw # NIL
   oBrw:Refresh()
   oBrw:Reset()
ENDIF

RETURN .T.


FUNCTION DI500EIJItens()

LOCAL oDlgItensEIJ,nMeio,aCamposSW8:={},nRec:=WORK_EIJ->WK_RECNO, nInd
// BAK - Tratamento para EnchoiceBar e declaração do bCancel - 18-08-2011
//LOCAL aOk:={{|| oDlgItensEIJ:End() },"OK"},aCposItEIJ,aBotoes:={}
Local aCposItEIJ,aBotoes:={}
Local bOk     := {|| oDlgItensEIJ:End() }
Local bCancel := {|| oDlgItensEIJ:End() }
LOCAL aPictures:={AVSX3("W9_INLAND" ,6),AVSX3("W9_PACKING",6),AVSX3("W9_DESCONT",6),;
                  AVSX3("W9_FRETEIN",6),AVSX3("W9_OUTDESP",6),AVSX3("W8_VLFREMN",6),;
                  AVSX3("W8_VLSEGMN",6),AVSX3("W8_VLII"   ,6),AVSX3("W8_VLIPI"  ,6),;
                  AVSX3("W8_VLACRES",6),AVSX3("W8_VLDEDU" ,6),AVSX3("W8_VLICMS" ,6),;
                  AVSX3("W7_QTDE"   ,6),AVSX3("W7_PESO"   ,6),AVSX3("W7_PRECO"  ,6),;
                  AVSX3("W6_FOB_TOT",6)}

DBSELECTAREA("WORK_EIJ")
IF Bof() .AND. Eof()
   Return .F.
EndIf

IF Work_EIJ->EIJ_ADICAO = "MOD"
   Help("",1,"AVG0000712")//O Modelo da Adicao nao possui itens.",0057) //0474
   RETURN .T.
ENDIF

IF !Inclui .AND. lPrimeiraVez
   IF nPos_aRotina = VISUAL .OR. nPos_aRotina = ESTORNO
      IF Work_SW8->(EasyRecCount("Work_SW8")) == 0
         Processa({|| DI500InvCarrega()},STR0054) //"Pesquisa de Itens"
      ENDIF
   ENDIF
ENDIF

AADD(aCamposSW8,{"WKINVOICE" ,,AVSX3('W9_INVOICE',5)})
AADD(aCamposSW8,{"WKPO_NUM"  ,,AVSX3('W8_PO_NUM' ,5)})
AADD(aCamposSW8,{"WKCOD_I"   ,,AVSX3('W8_COD_I'  ,5)})
AADD(aCamposSW8,{"WKFABR"    ,,AVSX3('W8_FABR'   ,5)})
If EICLoja()
   AADD(aCamposSW8,{"W8_FABLOJ",, AVSX3('W8_FABLOJ'   ,5)})
EndIf
AADD(aCamposSW8,{"WKQTDE"    ,,AVSX3("W8_QTDE"   ,5),aPictures[13]})
AADD(aCamposSW8,{"WKPRECO"   ,,AVSX3("W8_PRECO"  ,5),aPictures[15]})
AADD(aCamposSW8,{"WKPRTOTMOE",,AVSX3("W9_FOB_TOT",5),aPictures[16]})
AADD(aCamposSW8,{"WKINLAND"  ,,AVSX3("W8_INLAND" ,5),aPictures[01]})
AADD(aCamposSW8,{"WKPACKING" ,,AVSX3("W8_PACKING",5),aPictures[02]})
AADD(aCamposSW8,{"WKOUTDESP" ,,AVSX3("W8_OUTDESP",5),aPictures[02]})
AADD(aCamposSW8,{"WKDESCONT" ,,AVSX3("W8_DESCONT",5),aPictures[03]})
AADD(aCamposSW8,{"WKFRETEIN" ,,AVSX3('W8_FRETEIN',5),aPictures[04]})
AADD(aCamposSW8,{"WKOUTDESP" ,,AVSX3("W8_OUTDESP",5),aPictures[05]})
// EOB - 21/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
IF lSegInc .AND. AvRetInco(Work_EIJ->EIJ_INCOTE,"CONTEM_SEG")/*FDR - 27/12/10*/  //Work_EIJ->EIJ_INCOTE $ "CIF,CIP,DAF,DES,DEQ,DDP,DDU"
   AADD(aCamposSW8,{"WKSEGURO",,AVSX3("W8_SEGURO",5),AVSX3("W8_SEGURO",6)})
ENDIF
AADD(aCamposSW8,{"WKVLMLE"   ,,AVSX3("W8_VLMLE"  ,5),aPictures[16]})
AADD(aCamposSW8,{"WKFOBTOTR" ,,AVSX3("W8_FOBTOTR",5),aPictures[16]})
AADD(aCamposSW8,{"WKPESO_L"  ,,AVSX3("W7_PESO"   ,5),aPictures[14]})
AADD(aCamposSW8,{"WKPESOTOT" ,,STR0444              ,aPictures[14]}) //"Peso Total"
AADD(aCamposSW8,{"WKVLFREMN" ,,AVSX3("W8_VLFREMN",5),aPictures[06]})
IF !AvRetInco(Work_EIJ->EIJ_INCOTE,"CONTEM_SEG")/*FDR - 27/12/10*/  //Work_EIJ->EIJ_INCOTE $ "CIF,CIP,DAF,DES,DEQ,DDP,DDU")
   AADD(aCamposSW8,{"WKVLSEGMN" ,,AVSX3("W8_VLSEGMN",5),aPictures[07]})
ENDIF
AADD(aCamposSW8,{"WKBASEII"  ,,AVSX3("W8_BASEII" ,5),aPictures[08]})
AADD(aCamposSW8,{"WKVLDEVII" ,,AVSX3("EIJ_DEVII" ,5)+" II",aPictures[08]})
AADD(aCamposSW8,{"WKVLII"    ,,AVSX3("W8_VLII"   ,5),aPictures[08]})
AADD(aCamposSW8,{"WKVLDEIPI" ,,AVSX3("EIJ_VLDIPI",5)+" IPI",aPictures[08]})
AADD(aCamposSW8,{"WKVLIPI"   ,,AVSX3("W8_VLIPI"  ,5),aPictures[09]})
AADD(aCamposSW8,{"WKVLACRES" ,,AVSX3("W8_VLACRES",5),aPictures[10]})
AADD(aCamposSW8,{"WKVLDEDU"  ,,AVSX3("W8_VLDEDU" ,5),aPictures[11]})
IF lMV_PIS_EIC
   AADD(aCamposSW8,{"WKBASPIS",,AVSX3("W8_BASPIS",5),AVSX3("W8_BASPIS",6)})
   AADD(aCamposSW8,{"WKPERPIS",,AVSX3("W8_PERPIS",5),AVSX3("W8_PERPIS",6)})
   AADD(aCamposSW8,{"WKVLUPIS",,AVSX3("W8_VLUPIS",5),AVSX3("W8_VLUPIS",6)})
   AADD(aCamposSW8,{"WKVLRPIS",,AVSX3("W8_VLRPIS",5),AVSX3("W8_VLRPIS",6)})
   AADD(aCamposSW8,{"WKBASCOF",,AVSX3("W8_BASCOF",5),AVSX3("W8_BASCOF",6)})
   AADD(aCamposSW8,{"WKPERCOF",,AVSX3("W8_PERCOF",5),AVSX3("W8_PERCOF",6)})
   AADD(aCamposSW8,{"WKVLUCOF",,AVSX3("W8_VLUCOF",5),AVSX3("W8_VLUCOF",6)})
   AADD(aCamposSW8,{"WKVLRCOF",,AVSX3("W8_VLRCOF",5),AVSX3("W8_VLRCOF",6)})
If lCposCofMj                                                                             //NCF - 20/07/2012 - Majoração COFINS
   AADD(aCamposSW8,{"WKVLCOFM",,AVSX3("W8_VLCOFM",5),AVSX3("W8_VLCOFM",6)})
EndIf
If lCposPisMj                                                                             //GFP - 11/06/2013 - Majoração PIS
   AADD(aCamposSW8,{"WKVLPISM",,AVSX3("W8_VLPISM",5),AVSX3("W8_VLPISM",6)})
EndIf
ENDIF
AADD(aCamposSW8,{"WKTAXASIS" ,,STR0640              ,AVSX3("W8_BASEICM",6)              }) //STR0640 "Taxa SISCOMEX"
AADD(aCamposSW8,{"WKANTIDUM" ,,STR0641              ,AVSX3("W8_BASEICM",6)              })//AWR - 25/11/2004 //STR0641 "AntiDumping"
AADD(aCamposSW8,{"WKBASEICM" ,,AVSX3("W8_BASEICM",5),AVSX3("W8_BASEICM",6)              })
AADD(aCamposSW8,{"WKVLICMS"  ,                      ,AVSX3("W8_VLICMS" ,5),aPictures[12]})
If AvFlags("ICMSFECP_DI_ELETRONICA")
   AADD(aCamposSW8,{"WKVLFECP" ,,AVSX3("W8_VLFECP",5),AVSX3("W8_VLFECP",6)              })
   AADD(aCamposSW8,{"WKALFECP" ,,AVSX3("W8_ALFECP",5),AVSX3("W8_ALFECP",6)              })
EndIf
If AVFLAGS("FECP_DIFERIMENTO")
   AADD(aCamposSW8,{"WKFECPALD",,AVSX3("W8_FECPALD",5),AVSX3("W8_FECPALD",6)            })
   AADD(aCamposSW8,{"WKFECPVLD",,AVSX3("W8_FECPVLD",5),AVSX3("W8_FECPVLD",6)            })
   AADD(aCamposSW8,{"WKFECPREC",,AVSX3("W8_FECPREC",5),AVSX3("W8_FECPREC",6)            })
EndIf
AADD(aCamposSW8,{"WKINCOTER" ,                      ,AVSX3("W9_INCOTER",5)              })
AADD(aCamposSW8,{"WKADICAO"  ,                      ,AVSX3("W8_ADICAO" ,5)              })
AADD(aCamposSW8,{"WKSEQ_ADI" ,                      ,STR0642                            }) //STR0642 "Seq. Adicao"
AADD(aCamposSW8,{"WKOPERACA" ,                      ,STR0643                            }) //STR0643 "Operacao"

aCposItEIJ:=NIL /*{,;
"EIJ_ADICAO","EIJ_NROLI" ,"EIJ_FABFOR","EIJ_FORN","EIJ_FABR","EIJ_TEC","EIJ_EX_NCM",;
"EIJ_EX_NBM","EIJ_CONDPG","EIJ_DIASPG","EIJ_INCOTE","EIJ_MOEDA" ,"EIJ_MOESEG",;
"EIJ_TX_SEG","EIJ_MOEFRE","EIJ_TX_FRE","EIJ_TX_FOB","EIJ_QT_EST","EIJ_PESOL" ,;
"EIJ_VLMLE" ,"EIJ_VLMMN" ,"EIJ_VSEGMN","EIJ_VSEGLE","EIJ_VLFRET","EIJ_VFREMN",;
"EIJ_QTITEM","EIJ_VLARII","EIJ_VLAIPI","EIJ_EINAVM","EIJ_EINDVM","EIJ_VLICMS",;
"EIJ_BAS_II","EIJ_BASIPI"}*/

//DBSELECTAREA("WORK_EIJ")
IF nRec # 0
   EIJ->(DBGOTO(nRec))
ENDIF
DBSELECTAREA("EIJ")
FOR nInd := 1 TO FCount()
    IF (nPos:=WORK_EIJ->( FieldPos(EIJ->(FieldName(nInd))) )) # 0
       M->&(FIELDNAME(nInd)) := WORK_EIJ->(FieldGet(nPos))
    ENDIF
NEXT

aTela:={}
aGets:={}

DBSELECTAREA("Work_SW8")
Work_SW8->(DBSETORDER(4))
SET FILTER TO Work_SW8->WKADICAO == Work_EIJ->EIJ_ADICAO
DBGOTOP()

AADD(aBotoes,{"SIMULACAO" ,{|| DI500AdiTotais()  },STR0382 }) //LGS 22/07/13  - Habilitado "Totais"

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ANTES_MSDIALOG_ITENS_ADICAO"),)//BHF-22/05/09


DEFINE MSDIALOG oDlgItensEIJ TITLE STR0475+Work_EIJ->EIJ_ADICAO ;  //"Itens da Adicao: "
           FROM oMainWnd:nTop+125,oMainWnd:nLeft+5;
           TO   oMainWnd:nBottom-60,oMainWnd:nRight-10 OF oMainWnd PIXEL

//    nMeio:=INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 )-10
    nMeio:=INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 )+50

    oEnchItens:=MsMget():New("EIJ",nRec,ALTERACAO,,,,aCposItEIJ,{15,1,nMeio,(oDlgItensEIJ:nClientWidth-4)/2 },{},3,,,,,,,,,.F.,.F.) //THTS - 11/09/2017

    //GFP 20/10/2010
    aCamposSW8 := AddCpoUser(aCamposSW8,"SW8","2")

    oMarkItens:=MSSELECT():New("Work_SW8",,,aCamposSW8,lInverte,cMarca,{nMeio+1,1,(oDlgItensEIJ:nClientHeight-6)/2,(oDlgItensEIJ:nClientWidth-4)/2})
    oMarkItens:oBrowse:bWhen:={|| DBSELECTAREA("Work_SW8"),.T.}
    oMarkItens:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //Alinhamento MDI
    oDlgItensEIJ:lMaximized:=.T.

	oEnchItens:oBox:Align:=CONTROL_ALIGN_TOP //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

// BAK - Tratamento para EnchoiceBar - 18/06/2011
//ACTIVATE MSDIALOG oDlgItensEIJ ON INIT (oMarkItens:oBrowse:Refresh(), DI500EnchoiceBar(oDlgItensEIJ,aOk,,.F.,aBotoes),;
//                                        oEnchItens:oBox:Align:=CONTROL_ALIGN_TOP)
ACTIVATE MSDIALOG oDlgItensEIJ ON INIT (oMarkItens:oBrowse:Refresh(), EnchoiceBar(oDlgItensEIJ,bOk,bCancel,.F.,aBotoes)) //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

DBSELECTAREA("Work_SW8")
SET FILTER TO

RETURN .T.

Function DI500AdiTotais(lAdicao)

LOCAL nCo1:=.5, nCo2:=5, nCo3:=13, nCo4:=20, nCo5:=30// 18 - AWR - 06/2009 - Chamado P10
LOCAL nTotNFE:= nVlTota:= 0,oDlg,PICT15_2:=AVSX3("W6_FOB_TOT",6)
LOCAL nCOL:=65,cTitulo:=STR0794//STR0476 //STR0794 "Totais Nota fiscal"
PRIVATE nBaseII:= nFobR:= nFrete:= nSeguro:= nDed:= nAcres:= 0 , nLIN:=21
PRIVATE nVLAIPI:= nVLARII:= nICMS  :=nVLDEII :=nVLDIPI := nVLRDMP :=0
PRIVATE nVL_II := nVLR_II:= nDEVII :=nVLDIPI :=0
PRIVATE nBASPIS:= nVLRPIS:= nBASCOF:=nVLRCOF :=0
PRIVATE nVLDEPIS:=nVLDECOF:=0

IF(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"INICIA_VAL_ADITOTAIS"),)

Processa({|| DI500AdiSoma(lAdicao)})

IF lAdicao # NIL
   nLIN:=30
      nCOL:=57
   IF lAUTPCDI
      nCOL:=76
      nLIN:=25
   ENDIF
   cTitulo:=STR0639 //STR0639 "Totais Impostos"
ENDIF

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 9,10 TO nLIN,nCOL Of oMainWnd

 IF lAdicao = NIL

    @1.2,nCo1 SAY AVSX3("W8_FOBTOTR",5)//"FOB R$"
    @2.2,nCo1 SAY AVSX3("W8_VLFREMN",5)//"Frete CC R$"
    @3.2,nCo1 SAY AVSX3("W8_VLSEGMN",5)//"Seguro R$"
    @4.2,nCo1 SAY AVSX3("W8_VLII"   ,5)+STR0644 // STR0644 " Devido"
    @5.2,nCo1 SAY AVSX3("W8_VLII"   ,5)//"I.I. R$"

    @1.2,nCo2 MSGET nFobR     WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
    @2.2,nCo2 MSGET nFrete    WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
    @3.2,nCo2 MSGET nSeguro   WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
    @4.2,nCo2 MSGET nVLDEII   WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
    @5.2,nCo2 MSGET nVLARII   WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT

    @1.2,nCo3 SAY AVSX3("W8_VLIPI"  ,5)+ STR0644 // STR0644 " Devido"
    @2.2,nCo3 SAY AVSX3("W8_VLIPI"  ,5)//"I.P.I. R$"
    @3.2,nCo3 SAY AVSX3("W8_VLICMS" ,5)//"I.C.M.S. R$"
    @4.2,nCo3 SAY AVSX3("W8_VLACRES",5)//"Acrescimos R$"
    @5.2,nCo3 SAY AVSX3("W8_VLDEDU" ,5)//"Deducoes R$"

    @1.2,nCo4 MSGET nVLDIPI WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
    @2.2,nCo4 MSGET nVLAIPI WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
    @3.2,nCo4 MSGET nICMS   WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
    @4.2,nCo4 MSGET nAcres  WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
    @5.2,nCo4 MSGET nDed    WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT

    IF lMV_PIS_EIC

       IF !lAUTPCDI
          @6.2,nCo1 SAY AVSX3("W8_BASPIS",5)//AWR - 06/2009 - Chamado P10
          @6.2,nCo2 MSGET nBASPIS WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
       ELSE
          @6.2,nCo1 SAY "PIS R$ Devido" //AWR - 06/2009 - Chamado P10
          @6.2,nCo2 MSGET nVLDEPIS WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
       ENDIF
       @7.2,nCo1 SAY AVSX3("W8_VLRPIS",5)+" R$"//AWR - 06/2009 - Chamado P10
       @7.2,nCo2 MSGET nVLRPIS WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT

       IF !lAUTPCDI
          @6.2,nCo3 SAY AVSX3("W8_BASCOF",5)//AWR - 06/2009 - Chamado P10
          @6.2,nCo4 MSGET nBASCOF WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
       ELSE
          @6.2,nCo3 SAY "COFINS R$ Devido" //AWR - 06/2009 - Chamado P10
          @6.2,nCo4 MSGET nVLDECOF WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
       ENDIF
       @7.2,nCo3 SAY AVSX3("W8_VLRCOF",5)+" R$"//AWR - 06/2009 - Chamado P10
       @7.2,nCo4 MSGET nVLRCOF WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT

       oDlg:nHeight+=50

    ENDIF

  ELSE

    nLIN:=1
    nCo1:=2
    nCo3:=13
    nCo4:=21
    @ nLIN++  ,nCo1+1 SAY STR0645// STR0645 "Valor Calculado
    @ nLIN++  ,nCo1 MSGET nVL_II  WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT

    nLIN+=.5
    @ nLIN    ,nCo1+1 SAY STR0645 // STR0645 "Valor Calculado
    nLIN+=.5
    @ nLIN++  ,nCo1+1 SAY STR0646 //STR0646 "    Reduzido"
    @ nLIN++  ,nCo1 MSGET nVLR_II WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT

    nLIN+=.5
    @ nLIN++  ,nCo1+1 SAY STR0647 //STR0647 "  Valor Devido"
    @ nLIN++  ,nCo1 MSGET nDEVII  WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT

    nLIN+=.5
    @ nLIN++  ,nCo1+1 SAY STR0648 // STR0648 "Valor a Recolher"
    @ nLIN++  ,nCo1 MSGET nVLARII WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
    @ 0.5     ,nCo1-1  TO nLIN,nCo3-3 LABEL " I.I. " OF oDlg

    IF(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"DI500ADITOTAIS"),)

    nLIN:=1
    @ nLIN++   ,nCo3+1 SAY STR0647 //STR0647 "  Valor Devido"
    @ nLIN++   ,nCo3 MSGET nVLDIPI WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT

    nLIN+=.5
    @ nLIN++  ,nCo3+1 SAY STR0795 //STR0795 "Valor a Recolher"
    @ nLIN++  ,nCo3 MSGET nVLAIPI WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
    @ 0.5     ,nCo3-1  TO nLIN,nCo4 LABEL " I.P.I. " OF oDlg

    IF lMV_PIS_EIC
       IF !lAUTPCDI
          nLinAux:=nLIN+=.5
          nLIN+=1.5
          @ nLIN++ ,nCo3 MSGET nVLRPIS WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
          @ nLinAux,nCo3-1  TO nLIN,nCo4 LABEL " PIS " OF oDlg

          nLinAux:=nLIN+=.5
          nLIN+=1.6
          @ nLIN   ,nCo3 MSGET nVLRCOF WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
          nLIN+=1
          @ nLinAux,nCo3-1  TO nLIN,nCo4 LABEL " COFINS " OF oDlg

          nLinAux:=nLIN+=.5
          nLIN+=2
          @ nLIN ,nCo3 MSGET nICMS   WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
          nLIN+=.5
          @ nLinAux,nCo3-1  TO nLIN,nCo4 LABEL " I.C.M.S. " OF oDlg

          oDlg:nHeight+=100
       ELSE
          nLinAux:=nLIN+=.5
          nLIN+=2
          @ nLIN ,nCo3 MSGET nICMS   WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
          nLIN+=.5
          @ nLinAux,nCo3-1  TO nLIN,nCo4 LABEL " I.C.M.S. " OF oDlg

          nLIN:=1
          @ nLIN++   ,nCo4+4 SAY STR0647 //STR0647 "  Valor Devido"
          @ nLIN++   ,nCo4+3 MSGET nVLDEPIS WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT

          nLIN+=.5
          @ nLIN++  ,nCo4+4 SAY STR0648 //STR0648 "Valor a Recolher"
          @ nLIN++  ,nCo4+3 MSGET nVLRPIS WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
          @ 0.5     ,nCo4+2  TO nLIN,nCo5+2 LABEL "PIS" OF oDlg

          nLIN+=2
          @ nLIN++   ,nCo4+4 SAY STR0647 //STR0647 "  Valor Devido"
          @ nLIN++   ,nCo4+3 MSGET nVLDECOF WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT

          nLIN+=.5
          @ nLIN++  ,nCo4+4 SAY STR0648 //STR0648 "Valor a Recolher"
          @ nLIN++  ,nCo4+3 MSGET nVLRCOF WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
          @ nLinAux ,nCo4+2  TO nLIN,nCo5+2 LABEL "Cofins" OF oDlg

          oDlg:nHeight+=100

       ENDIF
    ELSE

       nLinAux:=nLIN+=.5
       nLIN+=1.5
       @ nLIN++ ,nCo3 MSGET nICMS   WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
       @ nLinAux,nCo3-1  TO nLIN,nCo4 LABEL " I.C.M.S. " OF oDlg

    ENDIF

  ENDIF

ACTIVATE MSDIALOG oDlg CENTERED

RETURN NIL


Function DI500AdiSoma(lAdicao)

LOCAL cAlias:=IF(lAdicao=NIL,'Work_SW8','Work_EIJ')
LOCAL nRecno:=(cAlias)->(RECNO())

ProcRegua( (cAlias)->(EasyReccount(cAlias)) )
(cAlias)->(DBGOTOP())

DO WHILE !(cAlias)->(EOF())
   IncProc()

   IF lAdicao = NIL
      IF EMPTY(Work_SW8->WKFLAGIV) .OR.  EMPTY(Work_SW8->WKINVOICE)
         Work_SW8->(DBSKIP())
         LOOP
      ENDIF
      nFobR  +=Work_SW8->WKFOBTOTR
      nFrete +=Work_SW8->WKVLFREMN
      nSeguro+=Work_SW8->WKVLSEGMN
      nVLDEII+=Work_SW8->WKVLDEVII
      nVLARII+=Work_SW8->WKVLII
      nVLDIPI+=Work_SW8->WKVLDEIPI
      nVLAIPI+=Work_SW8->WKVLIPI
      nICMS  +=Work_SW8->WKVLICMS
      nAcres +=Work_SW8->WKVLACRES
      nDed   +=Work_SW8->WKVLDEDU
      nBASPIS+=Work_SW8->WKBASPIS
      nVLRPIS+=Work_SW8->WKVLRPIS
      nBASCOF+=Work_SW8->WKBASCOF
      nVLRCOF+=Work_SW8->WKVLRCOF
      IF lAUTPCDI .AND. !lDISIMPLES
         nVLDEPIS += Work_SW8->WKVLDEPIS
         nVLDECOF += Work_SW8->WKVLDECOF
      ENDIF
   ELSE
      nVLARII+=Work_EIJ->EIJ_VLARII
      nVLAIPI+=Work_EIJ->EIJ_VLAIPI
      nVLRDMP+=Work_EIJ->EIJ_VLR_DU
      IF lAdicao
         nVL_II +=Work_EIJ->EIJ_VL_II
         nVLR_II+=Work_EIJ->EIJ_VLR_II
         nDEVII +=Work_EIJ->EIJ_DEVII
         nVLDIPI+=Work_EIJ->EIJ_VLDIPI
         nICMS  +=Work_EIJ->EIJ_VLICMS
         IF lAUTPCDI .AND. !lDISIMPLES
            nVLDEPIS += Work_EIJ->EIJ_VLDPIS
            nVLDECOF += Work_EIJ->EIJ_VLDCOF
            nVLRPIS += Work_EIJ->EIJ_VLRPIS
            nVLRCOF += Work_EIJ->EIJ_VLRCOF
         ENDIF
      ENDIF
   ENDIF

   IF(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"SOMA_ADITOTAIS"),)

   (cAlias)->(DBSKIP())

ENDDO

IF lAdicao # NIL .AND. lAdicao .AND. !lAUTPCDI
   nVLRPIS:=nVLRCOF:= 0
   IF lMV_PIS_EIC
      ProcRegua( Work_SW8->(EasyReccount("Work_SW8")) )
      Work_SW8->(DBGOTOP())
      DO WHILE !Work_SW8->(EOF())
         IncProc()
         IF EMPTY(Work_SW8->WKFLAGIV) .OR.  EMPTY(Work_SW8->WKINVOICE)
            Work_SW8->(DBSKIP())
            LOOP
         ENDIF
         nVLRPIS+=Work_SW8->WKVLRPIS
         nVLRCOF+=Work_SW8->WKVLRCOF
         Work_SW8->(DBSKIP())
      ENDDO
   ENDIF
ENDIF

(cAlias)->(DBGOTO(nRecno))

RETURN .T.

FUNCTION DI500EIJManut(nTipo,oMarkEIJ,aPegaCpos)

LOCAL oDlgEIJManut,cTituto:=" ",nInd,lErro:=.F.,nOpcao:=1, TB
LOCAL nRec:=WORK_EIJ->WK_RECNO,bCancel:=NIL,nRecnoVolta:=WORK_EIJ->(RECNO())
LOCAL bValid:={|| Obrigatorio(aGets,aTela).AND.;
                  DI500ValTudo( aValidEIJ,{|C| DI_Val_EIJ(C,.T.)} ) }
//LOCAL aOk:={{||IF(EVAL(bValid),(nOpcao:=1,oDlgEIJManut:End()),)},"OK"} FSM - 20/07/2011
Local bOk := {||IF(EVAL(bValid),(nOpcao:=1,oDlgEIJManut:End()),)}
LOCAL aTelaSalve,aGetsSalve
PRIVATE aCposMostra:={}
PRIVATE cTitAdHawb := ""	//Johann - 06/07/2005

// BAK - Tratamento para EnchoiceBar - 18/06/2011
bCancel := {||nOpcao:=0,oDlgEIJManut:End()}

IF nTipo # 5 .AND.  Work_EIJ->EIJ_ADICAO = "MOD"
   Help("",1,"AVG0000720")//"O Modelo da Adicao nao pode ser alterado nesta opcao.",0057) //0485
   RETURN .T.
ENDIF

IF (nTipo == 1 .Or. nTipo == 2 .Or. nTipo == 5) .And. (AvFlags("DUIMP") .And. M->W6_TIPOREG == '2') //Inclusao ou Alteracao para tipo DUIMP ainda nao esta disponivel
   EasyHelp(STR0924,STR0558) //Opção não disponível para processos do tipo DUIMP ## Atenção
   RETURN .T.
ENDIF

aCposModEIJ:={"EIJ_BENSEM","EIJ_EIL","EIJ_EIL_VM","EIJ_APLICM","EIJ_EINA","EIJ_AGENID",;
              "EIJ_EINAVM","EIJ_MATUSA","EIJ_EIND","EIJ_EINDVM","EIJ_LOCVEN","EIJ_EIK",;
              "EIJ_EIK_VM","EIJ_VINCCO","EIJ_METVAL","EIJ_METVVM","EIJ_TPAGE",;
              "EIJ_AGENOM","EIJ_AGEEND","EIJ_AGEBCO","EIJ_AGEAGE",'EIJ_RATACR',;
              'EIJ_REGICM','EIJ_EXOICM','EIJ_ACTIPI'} //BHF - 02/04/2009
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"MOD_ADICAO"),)

IF aPegaCpos # NIL .AND. nTipo = 5
   aPegaCpos := aCposModEIJ
   RETURN .T.
ENDIF

PRIVATE aDarGetsEIJ,aBotaoEIJ:=NIL,nPos_EIJaRotina
PRIVATE aValidEIJ:={'EIJ_NROVIB','EIJ_NROVIC'}

// EOB - 13/03/08 - Tratamento referente aos campos do Mercosul
IF EIJ->(FIELDPOS("EIJ_DEMERC")) # 0
	AADD(aValidEIJ, "EIJ_DEMERC")
ENDIF
IF EIJ->(FIELDPOS("EIJ_IDCERT")) # 0
	AADD(aValidEIJ, "EIJ_IDCERT")
ENDIF

IF !Inclui .AND. lPrimeiraVez  // GFP - 17/10/2013
   IF nPos_aRotina = VISUAL .OR. nPos_aRotina = ESTORNO
      IF Work_SW8->(EasyRecCount("Work_SW8")) == 0
         Processa({|| DI500InvCarrega()},STR0054) //"Pesquisa de Itens"
      ENDIF
   ELSE
      Processa({|| DI500Existe()    },STR0054) //"Pesquisa de Itens"
   ENDIF
ENDIF

IF nTipo = 5

   IF !Inclui .AND. lPrimeiraVez
      Processa({|| DI500Existe() },STR0054) //"Pesquisa de Itens"
   ENDIF

ELSE

   aCposMostra:=ACLONE(aCposEIJ)

ENDIF

DO CASE
CASE nTipo = 1
     cTituto:=STR0447 //"Inclusao"
     nPos_EIJaRotina:=INCLUSAO
     DBSELECTAREA("EIJ")
     FOR nInd := 1 TO FCount()
         M->&(FIELDNAME(nInd)) := CRIAVAR(FIELDNAME(nInd))
     NEXT
     bCancel:={||nOpcao:=0,oDlgEIJManut:End()}
     aBotaoEIJ :={{"FORM",{|| Processa({|| DI500CalcEIJ("M")})},STR0486,STR0486}} //"Calcula Impostos"-  STR0540 - "Calc.Imp"

CASE nTipo = 2
     cTituto:=STR0448 //"Alteracao"
     nPos_EIJaRotina:=ALTERACAO
     DBSELECTAREA("WORK_EIJ")
     IF Bof() .AND. Eof()
        Return .F.
     EndIf
     DBSELECTAREA("EIJ")
     FOR nInd := 1 TO FCount()
         IF (nPos:=WORK_EIJ->( FieldPos(EIJ->(FieldName(nInd))) )) # 0
            M->&(FIELDNAME(nInd)) := WORK_EIJ->(FieldGet(nPos))
         ENDIF
     NEXT
     aBotaoEIJ:={{"FORM",{|| Processa({|| DI500CalcEIJ('M')})},STR0486,STR0486}} //"Calcula Impostos" -  STR0540"Calc.Imp"

        aDarGetsEIJ:={}
        FOR TB := 1 TO LEN(aCposMostra)
            IF !(aCposMostra[TB] $ "EIJ_REGTRI,EIJ_FUNREG,EIJ_MOTADI,EIJ_TACOII,EIJ_ACO_II,EIJ_OPERAC"+IF(lREGIPIW8,",EIJ_REGIPI","")+IF(lAUTPCDI,",EIJ_REG_PC,EIJ_FUN_PC,EIJ_FRB_PC","")  )//AWR - 20/12/2004 - campo EIJ_OPERAC nao pode dar GET/nao precisa existir
               AADD(aDarGetsEIJ,aCposMostra[TB])
            ENDIF
        NEXT
CASE nTipo = 3
     cTituto:=STR0449 //"Exclusao"
     aDarGetsEIJ:={}
     //aOk:={{|| nOpcao:=1,oDlgEIJManut:End()},'OK'} FSM - 20/07/2011
     bOk := {|| nOpcao:=1,oDlgEIJManut:End()}
     nPos_EIJaRotina:=ALTERACAO
     DBSELECTAREA('WORK_EIJ')
     IF Bof() .AND. Eof()
        Return .F.
     EndIf
     DBSELECTAREA("EIJ")
     FOR nInd := 1 TO FCount()
         IF (nPos:=WORK_EIJ->( FieldPos(EIJ->(FieldName(nInd))) )) # 0
            M->&(FIELDNAME(nInd)) := WORK_EIJ->(FieldGet(nPos))
         ENDIF
     NEXT
     bCancel:={||nOpcao:=0,oDlgEIJManut:End()}

CASE nTipo = 4
     cTituto:=STR0450 //"Visualizacao"
     // aOk:={{||nOpcao:=0,oDlgEIJManut:End()},STR0421} //"Sair" FSM - 20/072011
     bOk := {||nOpcao:=0,oDlgEIJManut:End()}
     nPos_EIJaRotina:=VISUAL
     DBSELECTAREA("WORK_EIJ")
     IF Bof() .AND. Eof()
        Return .F.
     EndIf
     DBSELECTAREA("EIJ")
     FOR nInd := 1 TO FCount()
         IF (nPos:=WORK_EIJ->( FieldPos(EIJ->(FieldName(nInd))) )) # 0
            M->&(FIELDNAME(nInd)) := WORK_EIJ->(FieldGet(nPos))
         ENDIF
     NEXT

CASE nTipo = 5//"Modelo"
     Work_EIJ->(DBSETORDER(1))
     IF !Work_EIJ->(DBSEEK("MOD"))
        nPos_EIJaRotina:=INCLUSAO
        DBSELECTAREA("EIJ")
        FOR nInd := 1 TO FCount()
            M->&(FIELDNAME(nInd)) := CRIAVAR(FIELDNAME(nInd))
        NEXT
        M->EIJ_ADICAO:="MOD"
     ELSE
        nPos_EIJaRotina:=ALTERACAO
        DBSELECTAREA("EIJ")
        FOR nInd := 1 TO FCount()
            IF (nPos:=WORK_EIJ->( FieldPos(EIJ->(FieldName(nInd))) )) # 0
               M->&(FIELDNAME(nInd)) := WORK_EIJ->(FieldGet(nPos))
            ENDIF
        NEXT
     ENDIF
     DBSELECTAREA("EIJ")
     aCposMostra:=ACLONE(aCposModEIJ)
     aBotaoEIJ:={ {"SDUAPPEND" /*"BMPPARAM"*/,{|| DI500HelpMod(aCposModEIJ) } , STR0487,STR0541 }} //"Busca Modelos" -  "Busc.Mode"
     aValidEIJ:={}
     cTituto:=STR0488 //"Modelo"
     bCancel:={||nOpcao:=0,oDlgEIJManut:End()}
ENDCASE

/* Remoção de campos criados exclusivamente para a DUIMP */
RemoveFields(aCposMostra, SetRemoveFields("EIJ"), .F.)

aTelaSalve:=ACLONE(aTela)
aGetsSalve:=ACLONE(aGets)
aTela:={}
aGets:={}
IF !EMPTY(Work_EIJ->WK_RECNO)
   EIJ->(DBGOTO(Work_EIJ->WK_RECNO))
ENDIF

IF lAUTPCDI
   IF WORK_EIJ->EIJ_TPAPIS = "1"
      lWhenAutPis := .F.
   ELSE
      lWhenAutPis := .T.
   ENDIF

   IF WORK_EIJ->EIJ_TPACOF = "1"
      lWhenAutCof := .F.
   ELSE
      lWhenAutCof := .T.
   ENDIF
ENDIF


DI500GrvEI("EII",M->W6_QTD_ADI)//Para dar Carga na Vairavel "nSomaTaxaSisc"

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ANTES_TELA_EIJ"),)

//TDF - 24/02/11 - Preencher automaticamento o campo destaque quando houver destaque no cadastro da N.c.m.
SYD->(DBSetOrder(1))
SYD->(DBSeek(xFilial() + Work_EIJ->EIJ_TEC))
If !Empty(SYD->YD_DESTAQU)
   If !(Work_EIL->(DBSeek(Work_EIJ->EIJ_ADICAO)))
      Work_EIL->(DBAPPEND())
      Work_EIL->EIL_ADICAO:=Work_EIJ->EIJ_ADICAO
      Work_EIL->EIL_DESTAQ:=SYD->YD_DESTAQU
   EndIf
EndIf

If Empty(M->EIJ_LOCVEN)  // GFP - 01/04/2013
   M->EIJ_LOCVEN := If(Empty(M->EIJ_LOCVEN),GetLocVen("INVOICE"),M->EIJ_LOCVEN) //SW9->W9_INCOTER   //GFP - 19/03/2013
EndIf

M->EIJ_RATACR := "1"  // GFP - 02/03/2013 - Manter sempre habilitado

lGravouEIN:=.F.//AWR - 11/01/2005
DO WHILE .T.

   nOpcao:=0//Para nao Gravar no Botao 'X'
// IF nTipo = 2
//    nOpcao:=1//Para Gravar no Botao 'X' na Alteracao
// ENDIF
   DEFINE MSDIALOG oDlgEIJManut TITLE cTituto+STR0489+cTitAdHawb ;  //" de Adicoes"
          FROM oMainWnd:nTop+125,oMainWnd:nLeft +5 ;
          TO oMainWnd:nBottom-60,oMainWnd:nRight-10 OF oMainWnd PIXEL

     oEnChEIJ:=MsMget():New("EIJ",nRec,nPos_EIJaRotina,,,,aCposMostra,{15,1,(oDlgEIJManut:nClientHeight-6)/2,;
                                                              (oDlgEIJManut:nClientWidth-4)/2 },;
                                                               aDarGetsEIJ,3,,,,,,.T.,,,nTipo=5)//Decimo nono parametro com .T.: Desabilita as Pastas 
     oDlgEIJManut:lMaximized:=.T.
     oEnChEIJ:oBox:Align:=CONTROL_ALIGN_ALLCLIENT  //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   ACTIVATE MSDIALOG oDlgEIJManut ON INIT ( EnchoiceBar(oDlgEIJManut, bOk, bCancel,, aBotaoEIJ)) //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   IF nOpcao == 1
      lGravaEIJ:=.T.
      lGravaSoCapa:=.F.
      IF nTipo = 1  //Inclui
         WORK_EIJ->(DBAPPEND())
         M->WK_RECNO:=0
         M->W6_QTD_ADI++
         DI500GrvEI("EII",M->W6_QTD_ADI)
         DI500GrvEI("EII_SW6")
      ENDIF

      IF nTipo = 5 .AND. nPos_EIJaRotina = INCLUSAO
         WORK_EIJ->(DBAPPEND())
         M->WK_RECNO:=0
      ENDIF

      IF nTipo = 2 .OR. nTipo = 1 .OR. nTipo = 5

         //SVG - 30/07/2009 - IPI de Pauta Por Peso
         If M->EIJ_TPAIPI == "2" .AND. EIJ->(FieldPos("EIJ_CALIPI")) > 0 .AND. M->EIJ_CALIPI == "2"
            M->EIJ_QTUIPI := M->EIJ_PESOL
         EndIf
         AVReplace("M","WORK_EIJ")
         IF nTipo # 5
            IF ((!EMPTY(M->W6_SEGPERC) .AND. M->W6_SEGBASE $ "3,4") .OR. lMV_TXSIRAT) .AND. lGravouEIN//AWR - 11/01/2005
               Processa({|| DI500GeraAdicoes()},STR0342) //"Gerando Adicoes..."
            ELSE
               Processa({|| DI500CalcEIJ('Work_EIJ') } )
            ENDIF
         ENDIF
      ELSEIF nTipo = 3 //Exclui
         IF !EMPTY(Work_EIJ->WK_RECNO)
            AADD(aDeletados,{"EIJ",Work_EIJ->WK_RECNO})
         ENDIF
         WORK_EIJ->(DBDELETE())
         lGravaEIF:=lGravaEIG:=lGravaEIH:=lGravaEII:=lGravaEIK:=.T.
         lGravaEIL:=lGravaEIM:=lGravaEIN:=lGravaEIO:=lGravaEIJ:=lGravaEJ9:=.T.
         M->W6_QTD_ADI--
         DI500GrvEI("EII",M->W6_QTD_ADI)
         DI500GrvEI("EII_SW6")
         WORK_EIJ->(DBSKIP(-1))
      ENDIF
   ENDIF
   Work_EIJ->(DBGOTO(nRecnoVolta))
   EXIT
ENDDO

IF Type("oMarkEIJ") = "O"
   oMarkEIJ:oBrowse:Refresh()
ENDIF
aTela:=ACLONE(aTelaSalve)
aGets:=ACLONE(aGetsSalve)

RETURN .T.

Function DI500HelpMod(aCposModEIJ)

LOCAL oDlg, cFil:=xFilial("EIJ"),cChave
LOCAL cFilEIL:=xFilial("EIL")
LOCAL cFilEIK:=xFilial("EIK")
LOCAL cFilEIN:=xFilial("EIN")
LOCAL lRet:=.F., A
LOCAL bAction:={|| cChave:=EIJ->EIJ_HAWB+EIJ->EIJ_ADICAO,lRet:=.T.,oDlg:End() }
LOCAL Tb_Campos:={}
Local nAlt, nLarg

AADD(Tb_Campos,{"EIJ_HAWB" ,,AVSX3('EIJ_HAWB',5)})

dbSelectArea("EIJ")
Work_EIJ->(DBSETORDER(1))
DBSEEK(cFil)
SET FILTER TO cFil == EIJ->EIJ_FILIAL .AND. EIJ->EIJ_ADICAO == "MOD"

nAlt := 25
nLarg := 38

DEFINE MSDIALOG oDlg TITLE STR0487 FROM 1,1 TO nAlt, nLarg OF oMainWnd //"Busca Modelos"

   oMark:=MsSelect():New("EIJ",,,TB_Campos,lInverte,cMarca,{18,1,(oDlg:nClientHeight-4)/2,(oDlg:nClientWidth-4)/2},,,,,,)//{20,6,140,200}) .T. //AWR - 06/2009 - Chamado P10 - Tirei o parametro a mais
   oMark:baval:=bAction
   oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT (oMark:oBrowse:Refresh(), DI500EnchoiceBar(oDlg, {bAction,STR0490}, {||lRet:=.F.,oDlg:End()} )); 
                  CENTERED //STR0490 "Seleciona"
dbSelectArea("EIJ")
SET FILTER TO

IF lRet
   EIJ->(DBSEEK(cFil+cChave))
   FOR A := 1 TO LEN(aCposModEIJ)
      IF (nPos:=EIJ->(FIELDPOS(aCposModEIJ[A]))) # 0 .AND.;
           Work_EIJ->(FIELDPOS(aCposModEIJ[A]))  # 0
         M->&(EIJ->(FIELDNAME(nPos))):= EIJ->(FieldGet(nPos))
      ENDIF
   NEXT
   EIJ_METVVM:=E_Field("EIJ_METVAL","JM_DESC",,,1)

   Work_EIL->(DBSETORDER(1))
   EIL->(DBSETORDER(1))
   EIL->(DBSEEK(cFilEIL+cChave))
   DO WHILE EIL->(!EOF()) .AND. cFilEIL+cChave == EIL->EIL_FILIAL+EIL->EIL_HAWB+EIL->EIL_ADICAO
       IF !Work_EIL->(DBSEEK("MOD"+EIL->EIL_DESTAQ))
           Work_EIL->(DBAPPEND())
           Work_EIL->EIL_ADICAO:="MOD"
           Work_EIL->EIL_DESTAQ:=EIL->EIL_DESTAQ
       ENDIF
       EIL->(DBSKIP())
   ENDDO
   DI500GrvCpoVisual("EIJ_EIL")

   Work_EIK->(DBSETORDER(1))
   EIK->(DBSETORDER(1))
   EIK->(DBSEEK(cFilEIK+cChave))
   DO WHILE EIK->(!EOF()) .AND. cFilEIK+cChave == EIK->EIK_FILIAL+EIK->EIK_HAWB+EIK->EIK_ADICAO
      IF !Work_EIK->(DBSEEK("MOD"+EIK->EIK_TIPVIN+EIK->EIK_DOCVIN))
          Work_EIK->(DBAPPEND())
          Work_EIK->EIK_ADICAO:="MOD"
          Work_EIK->EIK_TIPVIN:=EIK->EIK_TIPVIN
          Work_EIK->EIK_DOCVIN:=EIK->EIK_DOCVIN
      ENDIF
      EIK->(DBSKIP())
   ENDDO
   DI500GrvCpoVisual("EIJ_EIK")

   Work_EIN->(DBSETORDER(1))
   EIN->(DBSETORDER(1))
   EIN->(DBSEEK(cFilEIN+cChave))
   DO WHILE EIN->(!EOF()) .AND. cFilEIN+cChave == EIN->EIN_FILIAL+EIN->EIN_HAWB+EIN->EIN_ADICAO
      IF !Work_EIN->(DBSEEK("MOD"+EIN->EIN_TIPO+EIN->EIN_CODIGO+EIN->EIN_FOBMOE))
          Work_EIN->(DBAPPEND())
          Work_EIN->EIN_ADICAO:="MOD"
          IF !Check_adic(Work_EIN->EIN_ADICAO) // 03/08/12 - BCO - Validação para o Campo EIN_ADICAO não ser gravado vazio
             Return .F.
          ENDIF
          Work_EIN->EIN_TIPO  :=EIN->EIN_TIPO
          Work_EIN->EIN_CODIGO:=EIN->EIN_CODIGO
          Work_EIN->EIN_DESC  :=EIN->EIN_DESC
          Work_EIN->EIN_FOBMOE:=EIN->EIN_FOBMOE
          Work_EIN->EIN_VLMLE :=EIN->EIN_VLMLE
          Work_EIN->EIN_VLMMN :=Work_EIN->EIN_VLMLE*BuscaTaxa(EIN->EIN_FOBMOE,dDataBase,.T.,.F.,.T.)
      ENDIF
      EIN->(DBSKIP())
   ENDDO
   DI500GrvCpoVisual("EIJ_EINA")
   DI500GrvCpoVisual("EIJ_EIND")
ENDIF

RETURN lRet

Function DI500GeraAdicoes(lBotaoTaxas)

LOCAL cIndice, cChaveAtual, cChaveOld, nAdicao:=1,N,nNroAdicao:=0,T
LOCAL nTotFrete:=nTotFreReal:=nFreteMaior:=nRecnoFRE:=MDespesas:=0,nSegMoeda:=0
LOCAL nTotSegRS:=nTotSeg:=nSegMaior:=nRecnoSeg:=0,aCposModelo:={}
LOCAL nItensAdi:=EICParISUF()  // Bete - número máximo de itens de uma adição
LOCAL lAuto := .F. // AST - 02/02/09 - Armazenar o retorno da função DeduFretN
//TRP - 07/04/10
LOCAL lCheckDesp := .F.
LOCAL nAcuDesp := 0
LOCAL aOrdWD
LOCAL aOrdYB
LOCAL aOrdW9
Local aDetMercAdi
Local oRateioRS
Local oRateioNegoc
//MFR OSSME-1425 04/12/2018
Local nVL_USSE
Local nVLSEGMN
DEFAULT lBotaoTaxas := .F.
PRIVATE aContrAdicao:={},lTaxaPreenchida:=.T.,lAcertou:=.F.,lTemNegativo:=.F.
PRIVATE nFOBMaior:=nRecnoFOB:=0
PRIVATE aGrvEIJ:={},aGrvEIN:={}
PRIVATE aGrvEIK:={},aGrvEIL:={}
PRIVATE cFilSAH:=xFilial('SAH')
PRIVATE cFilSA2:=xFilial('SA2')
PRIVATE cFilSA5:=xFilial('SA5')
PRIVATE cFilSB1:=xFilial('SB1')
PRIVATE cFilSJ5:=xFilial('SJ5')
PRIVATE cFilSY6:=xFilial('SY6')
PRIVATE cFilSYD:=xFilial('SYD')
PRIVATE xFilSYB:=xFilial("SYB")
PRIVATE xFilSWD:=xFilial("SWD")
PRIVATE xFilSJL:=xFilial("SJL")
PRIVATE lEINSobrepoe:=.F.//Usada na Aplicacao do Modelo
PRIVATE lEIJSobrepoe:=.F.//Usada na Aplicacao do Modelo
PRIVATE aZeraCampos :={.T.,.T.,.T., .T.,.T.,.T.}
PRIVATE nFobTotProc:=0, nPesoProc:=0            // LDR - 25/08/04
lGravaEIJ:=.T.
lGravaSoCapa:=.F.

// Bete - número máximo de itens de uma adição
IF nItensAdi = 0
   nItensAdi := 78
ENDIF

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ZERA_CAMPOS_ADICAO"),)

Work_SW8->(DBGOTOP())
IF WORK_SW8->(BOF()) .AND. WORK_SW8->(EOF())
   RETURN .T.
ENDIF

IF M->W6_ADICAOK $ cNao .AND. lBotaoTaxas
   MSGINFO(STR0649,STR0141) //STR0649 "As Adicoes serao recalculadas."
ENDIF

//***** WHILE DO TESTE DAS N.V.E.S *************
cNCM:=""
aNCM:={}
Work_SW8->(DBGOTOP())
DO WHILE Work_SW8->(!EOf()) .AND. lTemNVE //AWR - NVE

   IncProc(STR0502+Work_SW8->WKADICAO)
   IF EMPTY(Work_SW8->WKFLAGIV)  .OR.;
      EMPTY(Work_SW8->WKINVOICE) .OR.;
      !EMPTY(Work_SW8->WKNVE)    .OR.;
      ASCAN(aNCM,Work_SW8->WKTEC) # 0
      Work_SW8->(DBSKIP())
      LOOP
   ENDIF

   AADD(aNCM,Work_SW8->WKTEC)
   cTECSeek:=Work_SW8->WKTEC
   nTamTEC :=LEN(Work_SW8->WKTEC)
   FOR T := 1 TO nTamTEC
       IF !SJL->(DBSEEK(xFilSJL+cTECSeek))
          cTECSeek:=LEFT(Work_SW8->WKTEC,nTamTEC-T)+SPACE(T)
       ELSE
          cNCM+=Work_SW8->WKTEC+", "
          EXIT
       ENDIF
   NEXT

   Work_SW8->(DBSKIP())
ENDDO

IF lTemNVE .AND. !EMPTY(cNCM)//AWR - NVE
   IF !MSGYESNO(STR0650+cNCM+STR0651) //STR0650 "Itens das seguintes NCM's nao possuem NVE: " //STR0651 "Deseja gerar as Adicoes mesmo assim?"
      RETURN .F.
   ENDIF
ENDIF

Work_EIJ->(DBSETORDER(1))
Work_EIJ->(DBGOTOP())
Work_EIJ->(DBEVAL( {|| ;
IF(aZeraCampos[1],Work_EIJ->EIJ_QTITEM:= 0,),;
IF(aZeraCampos[2],Work_EIJ->EIJ_QT_EST:= 0,),;
IF(aZeraCampos[3],Work_EIJ->EIJ_PESOL := 0,),;
IF(aZeraCampos[4],Work_EIJ->EIJ_VLMLE := 0,),;
IF(aZeraCampos[4],Work_EIJ->EIJ_VLMMN := 0,),;
IF(aZeraCampos[5],Work_EIJ->EIJ_VLFRET:= 0,),;
IF(aZeraCampos[6],Work_EIJ->EIJ_VFREMN:= 0,),;
Work_EIJ->EIJ_QTUIPI:= 0},{|| Work_EIJ->EIJ_ADICAO # "MOD" } )) //MCF - 12/11/2015

DI500EIJManut(5,,aCposModelo)

SY6->(DBSETORDER(1))
SA2->(DBSETORDER(1))
SA5->(DBSETORDER(3))
SAH->(DBSETORDER(1))
SB1->(DBSETORDER(1))
SJ5->(DBSETORDER(1))
SYD->(DBSETORDER(1))
SJ5->(DBSETORDER(1))
Work_EIJ->(DBSETORDER(2))
Work_SW9->(DBSETORDER(1))
Work_SW8->(DBSETORDER(4))
//EIJ_NROLI+EIJ_FORN+EIJ_FABR+EIJ_TEC+EIJ_EX_NCM+EIJ_EX_NBM+EIJ_CONDPG+STR(EIJ_DIASPG,3,0)+EIJ_MOEDA+EIJ_INCOTE+EIJ_REGTRI+EIJ_TACOII+EIJ_ACO_II
cIndiceEIJ:=Work_EIJ->(INDEXKEY())
//WKREGIST+WKFORN+WKFABR+WKTEC+WKEX_NCM+WKEX_NBM+WKCOND_PA+STR(WKDIAS_PA,3,0)+WKMOEDA+WKINCOTER+WKREGTRI+WKTACOII+WKACO_II
cIndiceSW8:=Work_SW8->(INDEXKEY())

ProcRegua( Work_EIJ->(EasyReccount("Work_EIJ")) )
Work_EIJ->(DBGOTOP())

//***** WHILE DE EXCLUSAO DE ADICOES **********
DO WHILE Work_EIJ->(!EOf())
   IncProc(STR0502+Work_EIJ->EIJ_ADICAO)
   IF Work_EIJ->EIJ_ADICAO == "MOD"
      DI500AplicaMod(1,aCposModelo)
      AADD(aDeletados,{"EIJ",Work_EIJ->WK_RECNO})
      Work_EIJ->(DBSKIP())
      LOOP
   ENDIF
   cChaveEIJ:=Work_EIJ->(&(cIndiceEIJ))
   IF !WORK_SW8->(DBSEEK(cChaveEIJ))
      IF !EMPTY(Work_EIJ->WK_RECNO)
         AADD(aDeletados,{"EIJ",Work_EIJ->WK_RECNO})
      ENDIF
      Work_EIJ->(DBDELETE())
   ELSE
      IF EMPTY(Work_SW8->WKFLAGIV) .OR.;
         EMPTY(Work_SW8->WKINVOICE) .OR.;
         EMPTY(Work_SW8->WKADICAO)
         IF !EMPTY(Work_EIJ->WK_RECNO)
            AADD(aDeletados,{"EIJ",Work_EIJ->WK_RECNO})
         ENDIF
         Work_EIJ->(DBDELETE())
      ENDIF
   ENDIF
   Work_EIJ->(DBSKIP())
ENDDO
//***** WHILE DE EXCLUSAO DE ADICOES **********

ProcRegua( Work_SW8->(EasyReccount("Work_SW8")) )
Work_EIJ->(DBSETORDER(1))
Work_SW8->(DBGOTOP())
//***** WHILE DOS NUMEROS DE ITENS DAS ADICOES *************
DO WHILE Work_SW8->(!EOf())

   IncProc(STR0502+Work_SW8->WKADICAO)
   IF EMPTY(Work_SW8->WKFLAGIV) .OR.;
      EMPTY(Work_SW8->WKINVOICE).OR.;
      EMPTY(Work_SW8->WKADICAO) .OR.;
      !WORK_EIJ->(DBSEEK(Work_SW8->WKADICAO))
      Work_SW8->WKADICAO:=""
      Work_SW8->(DBSKIP())
      LOOP
   ENDIF

   IF (N:=ASCAN(aContrAdicao,{|A| A[1]==VAL(Work_SW8->WKADICAO) })) = 0
      AADD(aContrAdicao,{VAL(Work_SW8->WKADICAO),1})
   ELSE
      aContrAdicao[N,2]++
   ENDIF

   Work_SW8->(DBSKIP())

ENDDO
//***** WHILE DOS NUMEROS DE ITENS DAS ADICOES *************

ProcRegua( Work_SW8->(EasyReccount("Work_SW8")) )
Work_SW8->(DBGOTOP())
M->W6_FOB_TOT:=0
M->W6_PESOL  :=0

nFOBMaior:=nAcertaFOB:=nFOB_TOT:=nBaseTotalII:=0   // EOS 17/11
nRecnoFOB:=1
MDespesas:=0
nTotalDespe:=0

//***** WHILE DA GERACAO DE ADICOES E SOMATORIAS **********
aRegAdiCapa := {}
Work_EIJ->(DBEval({|| aAdd(aRegAdiCapa , {EIJ_ADICAO , WK_RECNO}) } ))
//NCF - Nova função para gerar as adições utilizando querys sobre arq.temp. no banco 
//GerAdicQry(.T.,.F.,"Work_EIJ","Work_SW8") // Somente foi alterado o nome da funcao
DI500GerAdicQry(.T.,.F.,"Work_EIJ","Work_SW8")

Work_SW8->(DbGoTop())                    
DO WHILE Work_SW8->(!EOf())

   SW2->(DBSETORDER(1))      // LDR - 25/08/04
   SW2->(DBSEEK(xFILIAL("SW2")+Work_SW8->WKPO_NUM))
   WORK->(DBSETORDER(3))     // LDR - 25/08/04
   WORK->(DBSEEK(Work_SW8->WKPO_NUM+Work_SW8->WKPGI_NUM+Work_SW8->WKPOSICAO))

   IncProc(STR0502+Work_SW8->WKADICAO)
   DI500WorkEIJ(Work_SW8->WKADICAO, aRegAdiCapa)

   IF lExiste_Midia .AND. lPesoMid .AND. SB1->B1_MIDIA $ cSim// LDR - 25/08/04
      nFobTotProc+= Work_SW8->WKQTDE * SB1->B1_QTMIDIA * SW2->W2_VLMIDIA * Work_SW9->W9_TX_FOB
      nPesoProc  += Work_SW8->WKQTDE * SB1->B1_QTMIDIA * WORK->WKPESOMID
      MDespesas  += Work_SW8->WKFRETEIN * Work_SW9->W9_TX_FOB   // Bete 24/02/05
   ELSE
      nFobTotProc+= DI500Trans(Work_SW8->WKPRECO*Work_SW8->WKQTDE, 2) * Work_SW9->W9_TX_FOB
      nPesoProc  += Work_SW8->WKPESOTOT
      MDespesas  += DI500Trans(DI500RetVal("ITEM_INV,SEM_FOB", "WORK", .T., .T., .T.)) // EOB - 20/06/08 - chamada da função DI500RetVal)
   ENDIF

   M->W6_PESOL  += Work_SW8->WKPESOTOT
   M->W6_FOB_TOT+= DI500Trans(Work_SW8->WKPRECO*Work_SW8->WKQTDE, 2) * Work_SW9->W9_TX_FOB

   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GERA_EIJ_QUEBRA"),)

   Work_SW8->(DBSKIP())

ENDDO

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"APOS_GERAR_ADICAO"),)
//***** WHILE DA GERACAO DE ADICOES E SOMATORIAS **********

IF !EMPTY(nAcertaFOB) 
   IF nAcertaFOB # nFobTotProc+MDespesas
      Work_EIJ->(DBGOTO(nRecnoFOB))
      Work_EIJ->EIJ_VLMMN+=(nFobTotProc+MDespesas)-nAcertaFOB
      nAcertaFOB+=((nFobTotProc+MDespesas)-nAcertaFOB)
      M->W6_VLMLEMN := nFobTotProc //NCF - 22/02/2018 - Ajustar totalizador do Processo no local de embarque em moeda nacional
      M->W6_TOT_PRO +=(nFobTotProc+MDespesas)-nAcertaFOB  //NCF - 22/02/2018 - Ajustar totalizador do Processo + Desp. Internacionais
   Endif
   If M->W6_FOB_GER # nAcertaFOB  //NCF - 23/02/2018 - Ajustar variável separadamente já que só ela pode estar divergente
      M->W6_FOB_GER += (nAcertaFOB - M->W6_FOB_GER)  
   EndIf
ENDIF

// NCF - 23/05/2012 - O valor Unitário das Mercadorias na Condição de Venda somados devem ser idênticos ao valor total da Adição
//                    na Condição de Venda. O valor no Processo vem com duas casas decimais, porém o rateio das despesas da invoice
//                    dependendo do Incoterm faz com que o valor unitário em decimais sofra alterações que impactam no valor final
//                    ficando diferente do valor arredondado. O valor deve ser acertado de acordo com a somatória dos valores unitários
//                    dos itens da adição.

Work_EIJ->(DbGoTop())
Do While Work_EIJ->(!Eof())
   If AvRetInco(Work_EIJ->EIJ_INCOTE,"CONTEM_FRETE") .Or. AvRetInco(Work_EIJ->EIJ_INCOTE,"CONTEM_SEG")
      aDetMercAdi := ApDetMerc("Work")
      If DITRANS(aDetMercAdi[2],2) # Work_EIJ->EIJ_VLMLE
         Work_EIJ->EIJ_VLMLE := DITRANS(aDetMercAdi[2],2)
         Work_EIJ->EIJ_VLMMN := DITRANS(Work_EIJ->EIJ_VLMLE * Work_SW9->W9_TX_FOB,2)
         DI500CondPagto()
      EndIf
   EndIf
   Work_EIJ->(DbSkip())
EndDo

Work_EIK->(DBSETORDER(1))
Work_EIL->(DBSETORDER(1))
Work_EIM->(DBSETORDER(1))
Work_EIN->(DBSETORDER(1))
Work_EIO->(DBSETORDER(1))
Work_SW8->(DBSETORDER(4))
ProcRegua( Work_EIJ->(EasyReccount("Work_EIJ")) )
Work_EIJ->(DBGOTOP())
nTotSegRS:=nTotFreReal:=nTotSeg:=nTotFrete:=0
nSegMaior:=nFreteMaior:=0
nRecnoSeg:=nRecnoFRE  :=Work_EIJ->(RECNO())

//************ WHILE DO RATEIO DO FRETE ****************
nDifFrete := 0  // RMD - 03/10/2014
DO WHILE Work_EIJ->(!EOf())
   IncProc(STR0501+Work_EIJ->EIJ_ADICAO)

   IF Work_EIJ->EIJ_ADICAO == "MOD"
      Work_EIJ->(DBSKIP())
      LOOP
   ENDIF

   IF EMPTY(WORK_EIJ->EIJ_QTITEM)
      IF !EMPTY(Work_EIJ->WK_RECNO)
         AADD(aDeletados,{"EIJ",Work_EIJ->WK_RECNO})
      ENDIF
      Work_EIJ->(DBDELETE())
      Work_EIJ->(DBSKIP())
      LOOP
   ENDIF

   //Rateio do Frete em Real e na Moeda
   aFrete := DI500ApFreAdi(Work_EIJ->EIJ_PESOL,,Work_EIJ->EIJ_TX_FOB, Work_EIJ->EIJ_VLMLE)  // RMD - 03/10/2014
   Work_EIJ->EIJ_VLFRET := aFrete[1]  // Moeda Negociada
   Work_EIJ->EIJ_VFREMN := aFrete[2]  // Moeda Nacional - Real
   IF Work_EIJ->EIJ_MOEDA # M->W6_FREMOED
      Work_EIJ->EIJ_VLFRET := aFrete[3]  // Moeda Negociada
   ENDIF
   IF Work_EIJ->EIJ_VFREMN > nFreteMaior
      nFreteMaior:=Work_EIJ->EIJ_VFREMN
      nRecnoFRE  :=Work_EIJ->(RECNO())
   ENDIF
   nTotFrete  +=Work_EIJ->EIJ_VLFRET // Moeda Negociada
   nTotFreReal+=Work_EIJ->EIJ_VFREMN // Moeda Nacional - Real

   IF AvRetInco(Work_EIJ->EIJ_INCOTE,"CONTEM_FRETE")/*FDR - 27/12/10*/  //Work_EIJ->EIJ_INCOTE $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDP,DDU"//AWR - DDU
      nAcertaFOB-=Work_EIJ->EIJ_VFREMN
   ENDIF
   Work_EIJ->(DBSKIP())

ENDDO

IF !EMPTY(M->W6_PESOL)
   lAcertou:=.F.
   //NCF - 23/05/2012 - Arredondamento para igualar ao frete já calculado para a adiçao
   IF nTotFreReal # Round( ((M->W6_VLFREPP+M->W6_VLFRECC-M->W6_VLFRETN)*M->W6_TX_FRET) ,2)// Real
      Work_EIJ->(DBGOTO(nRecnoFRE))
      Work_EIJ->EIJ_VFREMN += DI500Trans(((M->W6_VLFREPP+M->W6_VLFRECC-M->W6_VLFRETN)*M->W6_TX_FRET)-nTotFreReal)
      lAcertou:=.T.
   ELSE
      lAcertou:=.T. //NCF - 23/05/2012 - Caso o frete já esteja correto e não necessite de acerto
   ENDIF
ENDIF

//MFR OSSME-1425 04/12/2018
/*IF !EMPTY(M->W6_SEGPERC)
   M->W6_VL_USSE:=0
   M->W6_VLSEGMN:=0
ENDIF
*/
nVL_USSE:=0
nVLSEGMN:=0

ProcRegua( Work_EIJ->(EasyReccount("Work_EIJ")) )
nTotAcres:=nTotDeduc:=nAcrecimo:=nDeducao:=0                         //NCF - 27/09/2011 - Variáveis para apurar o acrescimo total do processo

Work_EIJ->(dbGoTop())
Do While Work_EIJ->(!EOF())
   If Work_EIJ->EIJ_ADICAO <> "MOD"                                  //NCF - 27/09/2011 - Não pode somar o valor do modelo nos acréscimos
      DI500GrvCpoVisual("EIJ_EINA",@nAcrecimo,,Work_EIJ->EIJ_ADICAO)
      DI500GrvCpoVisual("EIJ_EIND",,@nDeducao ,Work_EIJ->EIJ_ADICAO)
      nTotAcres += nAcrecimo
      nTotDeduc += nDeducao
   EndIf
   Work_EIJ->(DbSkip())
EndDo

Work_EIJ->(DBGOTOP())
//********* WHILE DO CALCULO POR PORCENTAGEM DO SEGURO ****************
DO WHILE Work_EIJ->(!EOf())
   IF EMPTY(M->W6_SEGPERC) .And. EMPTY(M->W6_SEGBASE)//EMPTY(M->W6_VL_USSE)

      nVL_USSE:= M->W6_VL_USSE // Moeda Negociada
      nVLSEGMN:= M->W6_VLSEGMN // Moeda Nacional - Real

      EXIT
   ENDIF
   IncProc(STR0501+Work_EIJ->EIJ_ADICAO)

   IF Work_EIJ->EIJ_ADICAO == "MOD"
      Work_EIJ->(DBSKIP())
      LOOP
   ENDIF

   nAcrecimo:=nDeducao:=0
      DI500GrvCpoVisual("EIJ_EINA",@nAcrecimo,,Work_EIJ->EIJ_ADICAO)
      DI500GrvCpoVisual("EIJ_EIND",,@nDeducao ,Work_EIJ->EIJ_ADICAO)

   //Rateio do Seguro em Real e na Moeda
   //NCF - 29/09/2011 - O frete proporcional da adição deve ser retirado conforme incoterm
/*Work_EIJ->EIJ_VLMMN,;*/

//MFR OSSME-1425 04/12/2018
/*                       aSeguro:=DI500ApSegAdi(Work_EIJ->EIJ_INCOTE,;
                         IF(AvRetInco(Work_EIJ->EIJ_INCOTE,"CONTEM_FRETE"),Work_EIJ->EIJ_VLMMN-Work_EIJ->EIJ_VFREMN,Work_EIJ->EIJ_VLMMN),;
                          nAcertaFOB,;
                          Work_EIJ->EIJ_VFREMN,;//Real
                          M->W6_VL_USSE,;//Na Moeda
                          M->W6_VLSEGMN,.F.,; //Real
                          nAcrecimo-nDeducao,nTotAcres-nTotDeduc)
                          */
                          
                          aSeguro:=DI500ApSegAdi(Work_EIJ->EIJ_INCOTE,;
                          IF(AvRetInco(Work_EIJ->EIJ_INCOTE,"CONTEM_FRETE"),Work_EIJ->EIJ_VLMMN-Work_EIJ->EIJ_VFREMN,Work_EIJ->EIJ_VLMMN),;
                          nAcertaFOB,;
                          Work_EIJ->EIJ_VFREMN,;//Real
                          M->W6_VL_USSE,;//Na Moeda
                          IIF(M->W6_VLSEGMN = 0, M->W6_VL_USSE * M->W6_TX_SEG , M->W6_VLSEGMN ),.F.,; 
                          nAcrecimo-nDeducao,nTotAcres-nTotDeduc)

   Work_EIJ->EIJ_VSEGLE := aSeguro[1]// Moeda Negociada
   Work_EIJ->EIJ_VSEGMN := aSeguro[2]// Moeda Nacional - Real

   IF Work_EIJ->EIJ_VSEGMN > nSegMaior
      nSegMaior:=Work_EIJ->EIJ_VSEGMN
      nRecnoSEG:=Work_EIJ->(RECNO())
   ENDIF
   //MFR OSSME-1425 04/12/2018
   //M->W6_VL_USSE+=Work_EIJ->EIJ_VSEGLE// Moeda Negociada
   //M->W6_VLSEGMN+=Work_EIJ->EIJ_VSEGMN// Moeda Nacional - Real
   nVL_USSE+=Work_EIJ->EIJ_VSEGLE// Moeda Negociada
   nVLSEGMN+=Work_EIJ->EIJ_VSEGMN// Moeda Nacional - Real
   Work_EIJ->(DBSKIP())

ENDDO
//MFR OSSME-1425 04/12/2018
 M->W6_VL_USSE:=nVL_USSE // Moeda Negociada
 M->W6_VLSEGMN:=nVLSEGMN// Moeda Nacional - Real

ProcRegua( Work_EIJ->(EasyReccount("Work_EIJ")) )
Work_EIJ->(DBGOTOP())
nSeqAdicao:=1
nNroAdicao:=0

oRateioNegoc := EasyRateio():New(;
    M->W6_VL_USSE,;
    nAcertaFOB + (nTotAcres-nTotDeduc),;
    Work_EIJ->(EasyRecCount("Work_EIJ")),;
    AvSX3("EIJ_VSEGLE", AV_DECIMAL);
)
oRateioRS := EasyRateio():New(;
    M->W6_VLSEGMN,;
    nAcertaFOB + (nTotAcres-nTotDeduc),;
    Work_EIJ->(EasyRecCount("Work_EIJ")),;
    AvSX3("EIJ_VSEGMN", AV_DECIMAL);
)
//********* WHILE DO RATEIO DO SEGURO E DOS IMPOSTOS ****************
DO WHILE Work_EIJ->(!EOf())
   IncProc(STR0501+Work_EIJ->EIJ_ADICAO)

   IF Work_EIJ->EIJ_ADICAO == "MOD"
      Work_EIJ->(DBSKIP())
      LOOP
   ENDIF

   DI500GrvEI("EIN",,aGrvEIN,,,lBotaoTaxas)

   IF nSeqAdicao # VAL(Work_EIJ->EIJ_ADICAO)
      cSeqAdi:=STRZERO(nSeqAdicao,3,0)
      Work_SW8->(DBSETORDER(4))//As funcoes executadas neste while PODEM trocar a ordem do SW8
      DO WHILE Work_SW8->(DBSEEK(Work_EIJ->EIJ_ADICAO))
         Work_SW8->WKADICAO:=cSeqAdi
         IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GRAVA_ADICAO_SW8"),)
      ENDDO
      DI500AtuEI(cSeqAdi)
      Work_EIJ->EIJ_ADICAO:=cSeqAdi
   ENDIF

   nAcrecimo:=nDeducao:=0
   DI500GrvCpoVisual("EIJ_EINA",@nAcrecimo,,Work_EIJ->EIJ_ADICAO)
   DI500GrvCpoVisual("EIJ_EIND",,@nDeducao ,Work_EIJ->EIJ_ADICAO)

   //Rateio do Seguro em Real e na Moeda 
   Work_EIJ->EIJ_VSEGLE := oRateioNegoc:GetItemRateio(fobEIJ(nAcrecimo, nDeducao))// Moeda Negociada
   Work_EIJ->EIJ_VSEGMN := oRateioRS:GetItemRateio(fobEIJ(nAcrecimo, nDeducao))// Moeda Nacional - Real

   IF Work_EIJ->EIJ_VSEGMN > nSegMaior
      nSegMaior:=Work_EIJ->EIJ_VSEGMN
      nRecnoSEG:=Work_EIJ->(RECNO())
   ENDIF

   nTotSeg  +=Work_EIJ->EIJ_VSEGLE// Moeda Negociada
   nTotSegRS+=Work_EIJ->EIJ_VSEGMN// Moeda Nacional - Real

   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ANT_CALCEIJ"),)    // Bete 04/06/05 - Antes do calculo dos impostos

   // AST - 02/02/09 - Inclusão da chamada da função DeduFretN
   If EasyGParam("MV_DEFRENA",,.F.)
      lAuto := DeduFretN(lAuto) // Armazena o retorno da função DeduFretN, para o usuário confirmar apenas uma vez
                                // e não necessitar ficar confirmando a cada adição
   EndIf

   //TRP - 07/04/10 - Chamada da funcão CalcAcres - Rateio por valor dos acréscimos
   If EasyGParam("MV_RATACRE",,.F.)  .AND. SWD->(FIELDPOS("WD_CODACR ")) # 0 .AND. SWD->(FIELDPOS("WD_DESCACR")) # 0
      aOrdWD := SaveOrd("SWD")
      aOrdYB := SaveOrd("SWD")
      aOrdW9 := SaveOrd("SW9")
      SWD->(DbSetOrder(1))
      SYB->(DbSetOrder(1))
      SW9->(DbSetOrder(3))
      SW9->(DbSeek(xFilial("SW9") + M->W6_HAWB))
      If SWD->(DbSeek(xFilial("SWD")+M->W6_HAWB))
         While SWD->(!Eof()) .And. (xFilial("SWD") == SWD->WD_FILIAL) .And. (SWD->WD_HAWB == M->W6_HAWB)
            If SYB->(DbSeek(xFilial("SYB") + SWD->WD_DESPESA))
               If SYB->YB_BASEIMP $ cSim
                  nAcuDesp:= SWD->WD_VALOR_R
                  cCodAcr:= SWD->WD_CODACR
                  cDescAcr:= SWD->WD_DESCACR
                  lRatPeso := SYB->YB_RATPESO == '1'  
                  lCheckDesp := CalcAcres(lCheckDesp,nAcuDesp,cCodAcr,cDescAcr,lRatPeso)  
               Endif
            EndIf
            SWD->(DbSkip())
         EndDo
      EndIf

      RestOrd(aOrdWD, .T.)
      RestOrd(aOrdYB, .T.)
      RestOrd(aOrdW9, .F.)
   Endif
   DI500CalcEIJ('Work_EIJ')

   nBaseTotalII +=Work_EIJ->EIJ_BAS_II

   IF M->W6_ADICAOK $ cNao
      DI500CondPagto()
   ENDIF
   DI500ValRat(1)  //LGS-26/11/2014
   DI500VerCposNeg()

   nSeqAdicao++
   nNroAdicao++

   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GERA_EIJ_RATEIO"),)

   Work_EIJ->(DBSKIP())

ENDDO
//********* WHILE DO RATEIO DO SEGURO E CALCULO DOS IMPOSTOS ****************

IF !EMPTY(M->W6_PESOL)
   IF lAcertou
      Work_EIJ->(DBGOTO(nRecnoFRE))
      DI500CalcEIJ('Work_EIJ')
   ENDIF
ENDIF

IF !EMPTY(M->W6_FOB_TOT)
   lAcertou:=.F.
   IF nTotSegRS # M->W6_VLSEGMN // Moeda Nacional - Real
      Work_EIJ->(DBGOTO(nRecnoSeg))
      Work_EIJ->EIJ_VSEGMN += DI500Trans(M->W6_VLSEGMN - nTotSegRS)
      lAcertou:=.T.
   ENDIF
   IF EMPTY(M->W6_SEGPERC)
      IF nTotSeg # M->W6_VL_USSE   // Moeda Negociada
         Work_EIJ->(DBGOTO(nRecnoSeg))
         Work_EIJ->EIJ_VSEGLE += DI500Trans(M->W6_VL_USSE - nTotSeg)
         lAcertou:=.T.
      ENDIF
   ELSE
      M->W6_VL_USSE := M->W6_VLSEGMN / M->W6_TX_SEG
   ENDIF
   IF lAcertou
      Work_EIJ->(DBGOTO(nRecnoSeg))
      DI500CalcEIJ('Work_EIJ')
   ENDIF
ENDIF

M->W6_ADICAOK:=IF( lTaxaPreenchida .AND. !lTemNegativo , SIM , NAO )
M->W6_QTD_ADI:=nNroAdicao
DI500Controle(0,{M->W6_VLFRECC,M->W6_VLFREPP,M->W6_VLFRETN,M->W6_VLSEGMN,M->W6_VL_USSE,M->W6_SEGBASE,M->W6_SEGPERC,M->W6_TX_FRET})
DI500GrvEI("EII",M->W6_QTD_ADI)//Para dar Carga na Vairavel "nSomaTaxaSisc"
DI500BaseICMSCalc()// AWR - 18/02/2004
DI500GrvEI("EII_SW6")
Work_EIJ->(DBGOTOP())

IF lTemNegativo
   Help("",1,"AVG0000713")//Existem Adicoes com valores negativos.")
ENDIF

IF Type("oMarkEIJ") = "O"
   oMarkEIJ:oBrowse:Refresh()
ENDIF

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"FIM_GERA_ADICOES"),)

//** AAF 27/04/05
If lIntDraw .AND. EasyGParam("MV_DRAWCOM",,.F.)
   AtoComplemDi() //Adiciona ao campo complemento da DI os dados das adicoes com Drawback.
Endif

RETURN .T.

Function DI500GerNrAdicao()

LOCAL nNrNewAdicao:=1
Work_EIJ->(DBSETORDER(1))
DO WHILE Work_EIJ->(DBSEEK(STRZERO(nNrNewAdicao,3,0)))
   nNrNewAdicao++
ENDDO
RETURN nNrNewAdicao

Function DI500VerCposNeg()

IF Work_EIJ->EIJ_VLMLE  < 0 .OR. ;
   Work_EIJ->EIJ_VLMMN  < 0 .OR. ;
   Work_EIJ->EIJ_VFREMN < 0 .OR. ;
   Work_EIJ->EIJ_VSEGMN < 0
   lTemNegativo:=.T.
ENDIF
RETURN

Function DI500CondPagto()

LOCAL nCont:=0,P
SY6->(DBSEEK(cFilSY6+Work_EIJ->EIJ_CONDPG+STR(Work_EIJ->EIJ_DIASPG,3,0)))

Work_EIO->(DBSEEK(Work_EIJ->EIJ_ADICAO))
DO WHILE Work_EIO->(!EOF()) .AND. Work_EIO->EIO_ADICAO == Work_EIJ->EIJ_ADICAO
//Caso o usuario altere a modalidade p/ Work_EIJ->EIJ_TIPCOB = "3" e existir parcela a vista no EIO tem que apagar AWR - EOS
   IF Work_EIJ->EIJ_TIPCOB = "4" .OR. (Work_EIJ->EIJ_TIPCOB = "3" .AND. Work_EIO->EIO_TIPCOB = '1')
      IF !EMPTY(Work_EIO->WK_RECNO)
         AADD(aDeletados,{"EIO",Work_EIO->WK_RECNO})
      ENDIF
      Work_EIO->(DBDELETE())
   ELSEIF Work_EIO->EIO_TIPCOB = '2' .AND. EMPTY(Work_EIO->EIO_PARCEL)
      nCont++
      Work_EIO->EIO_PARCEL := STRZERO(nCont,2)
   ENDIF
   Work_EIO->(DBSKIP())
ENDDO
Work_EIJ->EIJ_VLM360 := 0
Work_EIJ->EIJ_VL_FIN := 0
Work_EIJ->EIJ_QTPARC := 0
Work_EIJ->EIJ_PERPAR := ' '
DO CASE
CASE SY6->Y6_TIPO == '1'// Normal
     IF Work_EIJ->EIJ_TIPCOB = '3'// AWR - EOS
        Work_EIJ->EIJ_VLM360 := Work_EIJ->EIJ_VLMLE
     ELSE
        Work_EIJ->EIJ_VL_FIN := Work_EIJ->EIJ_VLMLE
     ENDIF
     Work_EIJ->EIJ_QTPARC := 1
     Work_EIJ->EIJ_PERPAR := '1'

CASE SY6->Y6_TIPO == '2'// A Vista
     IF Work_EIJ->EIJ_TIPCOB = '3'// AWR - EOS
        Work_EIJ->EIJ_VLM360 := Work_EIJ->EIJ_VLMLE
     ELSE
        IF !Work_EIO->(DBSEEK(Work_EIJ->EIJ_ADICAO+'1'))
           Work_EIO->(DBAPPEND())
           Work_EIO->EIO_ADICAO := Work_EIJ->EIJ_ADICAO
           Work_EIO->EIO_TIPCOB := '1'
           Work_EIO->EIO_PARCEL := '01'
           Work_EIO->EIO_PGREAL := '2'
        ENDIF
        Work_EIO->EIO_VLMLE  := Work_EIJ->EIJ_VLMLE
     ENDIF

CASE SY6->Y6_TIPO == '3'// Parcelado OU Antecipado
     Work_EIO->(DBSETORDER(2))
     nTotMontante:=0
     FOR P := 1 TO 10
        nDiaParc:=DI500Block("SY6","Y6_DIAS_"+STRZERO(P,2))
        IF !EMPTY(nDiaParc)
           nPercParc:=DI500Block("SY6","Y6_PERC_"+STRZERO(P,2))

           IF nDiaParc > 360 .AND. Work_EIJ->EIJ_TIPCOB = '3'// AWR - EOS
              nTotMontante+=DI500Trans(Work_EIJ->EIJ_VLMLE * (nPercParc/100))
              IF Work_EIO->(DBSEEK(Work_EIJ->EIJ_ADICAO+'2'+STRZERO(P,2)))
                 IF !EMPTY(Work_EIO->WK_RECNO)
                    AADD(aDeletados,{"EIO",Work_EIO->WK_RECNO})
                 ENDIF
                 Work_EIO->(DBDELETE())// Apaga por que o usuario pode ter mudado o EIJ_TIPCOB de 1 ou 2 p/ 3
              ENDIF
           ELSEIF nDiaParc > 0
              Work_EIJ->EIJ_QTPARC++
              Work_EIJ->EIJ_VL_FIN += DI500Trans(Work_EIJ->EIJ_VLMLE * (nPercParc/100))
              Work_EIJ->EIJ_PERPAR := '1'
              IF Work_EIO->(DBSEEK(Work_EIJ->EIJ_ADICAO+'2'+STRZERO(P,2)))
                 IF !EMPTY(Work_EIO->WK_RECNO)
                    AADD(aDeletados,{"EIO",Work_EIO->WK_RECNO})
                 ENDIF
                 Work_EIO->(DBDELETE())// Apaga por que o usuario pode ter mudado o EIJ_TIPCOB de 1 ou 2 p/ 3
              ENDIF
           ELSE
              IF !Work_EIO->(DBSEEK(Work_EIJ->EIJ_ADICAO+'2'+STRZERO(P,2)))
                 Work_EIO->(DBAPPEND())
                 Work_EIO->EIO_ADICAO := Work_EIJ->EIJ_ADICAO
                 Work_EIO->EIO_TIPCOB := '2'
                 Work_EIO->EIO_PARCEL := STRZERO(P,2)
                 Work_EIO->EIO_PGREAL := '2'
              ENDIF
              Work_EIO->EIO_VLMLE  := DI500Trans(Work_EIJ->EIJ_VLMLE * (nPercParc/100))
           ENDIF

        ENDIF
     NEXT
     Work_EIJ->EIJ_VLM360 := nTotMontante
     Work_EIO->(DBSETORDER(1))
ENDCASE

IF Work_EIJ->EIJ_TIPCOB = "4"
   Work_EIJ->EIJ_QTPARC := 0
   Work_EIJ->EIJ_VL_FIN := 0
   Work_EIJ->EIJ_PERPAR := ' '
ENDIF

RETURN .T.


Function DI500AtuEI(cSeqAdi)

DO WHILE Work_EIK->(DBSEEK(cSeqAdi))
   IF !EMPTY(Work_EIK->WK_RECNO)
      AADD(aDeletados,{"EIK",Work_EIK->WK_RECNO})
   ENDIF
   Work_EIK->(DBDELETE())
ENDDO
DO WHILE Work_EIK->(DBSEEK(Work_EIJ->EIJ_ADICAO))
   Work_EIK->EIK_ADICAO:=cSeqAdi
ENDDO

DO WHILE Work_EIL->(DBSEEK(cSeqAdi))
   IF !EMPTY(Work_EIL->WK_RECNO)
      AADD(aDeletados,{"EIL",Work_EIL->WK_RECNO})
   ENDIF
   Work_EIL->(DBDELETE())
ENDDO
DO WHILE Work_EIL->(DBSEEK(Work_EIJ->EIJ_ADICAO))
   Work_EIL->EIL_ADICAO:=cSeqAdi
ENDDO
//AWR - NVE - 19/10/2004 - Nao mexer: vai funicionar com ou sem NVE, com processo novo ou antigo
Work_EIM->(DBSETORDER(1))
DO WHILE Work_EIM->(DBSEEK(cSeqAdi))
   IF !EMPTY(Work_EIM->WK_RECNO)
      AADD(aDeletados,{"EIM",Work_EIM->WK_RECNO})
   ENDIF
   Work_EIM->(DBDELETE())
ENDDO
DO WHILE Work_EIM->(DBSEEK(Work_EIJ->EIJ_ADICAO))
   Work_EIM->EIM_ADICAO:=cSeqAdi
ENDDO

DO WHILE Work_EIN->(DBSEEK(cSeqAdi))
   IF !EMPTY(Work_EIN->WK_RECNO)
      AADD(aDeletados,{"EIN",Work_EIN->WK_RECNO})
   ENDIF
   Work_EIN->(DBDELETE())
ENDDO
DO WHILE Work_EIN->(DBSEEK(Work_EIJ->EIJ_ADICAO))
   Work_EIN->EIN_ADICAO:=cSeqAdi
   IF !Check_adic(Work_EIN->EIN_ADICAO) // 03/08/12 - BCO - Validação para o Campo EIN_ADICAO não ser gravado vazio
      Return .F.
   ENDIF
ENDDO

DO WHILE Work_EIO->(DBSEEK(cSeqAdi))
   IF !EMPTY(Work_EIO->WK_RECNO)
      AADD(aDeletados,{"EIO",Work_EIO->WK_RECNO})
   ENDIF
   Work_EIO->(DBDELETE())
ENDDO
DO WHILE Work_EIO->(DBSEEK(Work_EIJ->EIJ_ADICAO))
   Work_EIO->EIO_ADICAO:=cSeqAdi
ENDDO

Return .T.

Function DI500WorkEIJ(cAdicao, aRegAdiCapa)

LOCAL nFOBTotal
Local lItemIpiPauta := .F. //RRV - 15/01/2013
Local nPos
//RRV - 15/01/2013 - Verifica se o item possui Ipi de Pauta.
SB1->(DbSeek(xFilial()+Work_Sw8->WkCod_I))
If !Empty(SB1->B1_TAB_IPI)
   EI6->(DbSeek(xFilial()+SB1->B1_TAB_IPI))
   lItemIpiPauta := .T.
EndIf

Work_EIJ->(DBSETORDER(1))
//TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
WORK_SW9->(DBSEEK(Work_SW8->WKINVOICE+Work_SW8->WKFORN+Work_SW8->W8_FORLOJ+M->W6_HAWB))
SYD->(DBSEEK(cFilSYD+Work_SW8->WKTEC+Work_SW8->WKEX_NCM+Work_SW8->WKEX_NBM))
IF !WORK_EIJ->(DBSEEK(cAdicao))
   SY6->(DBSEEK(cFilSY6+Work_SW8->WKCOND_PA+STR(Work_SW8->WKDIAS_PA,3,0)))
   SA2->(DBSEEK(cFilSA2+Work_SW8->WKFORN+Work_SW8->W8_FORLOJ))
   Work_EIJ->(DBAPPEND())
   Work_EIJ->EIJ_ADICAO :=cAdicao
   Work_EIJ->EIJ_NROLI  :=Work_SW8->WKREGIST
   Work_EIJ->EIJ_FORN   :=Work_SW8->WKFORN
   Work_EIJ->EIJ_FABR   :=Work_SW8->WKFABR
   Work_EIJ->EIJ_FABFOR :=IF(Work_SW8->WKFABR==Work_SW8->WKFORN .And. (!EICLoja() .Or. Work_SW8->W8_FORLOJ == Work_SW8->W8_FABLOJ),'1','2')
   Work_EIJ->EIJ_TEC    :=Work_SW8->WKTEC
   Work_EIJ->EIJ_EX_NCM :=Work_SW8->WKEX_NCM
   Work_EIJ->EIJ_EX_NBM :=Work_SW8->WKEX_NBM
   Work_EIJ->EIJ_CONDPG :=Work_SW8->WKCOND_PA
   Work_EIJ->EIJ_DIASPG :=Work_SW8->WKDIAS_PA
   Work_EIJ->EIJ_TCOBPG :=Work_SW8->WKTCOB_PA
   Work_EIJ->EIJ_INCOTE :=Work_SW8->WKINCOTER
   Work_EIJ->EIJ_MOEDA  :=Work_SW8->WKMOEDA
   Work_EIJ->TRB_ALI_WT :="SW8"
   Work_EIJ->TRB_REC_WT :=SW8->(Recno())
   //FDR - 24/11/11 - Tratamento para gravação do valor da aliquota do IPI de Pauta
   IF lEIJIPIPauta
      Work_EIJ->EIJ_VLRIPI:=Work_SW8->WKIPIPAUTA
   ENDIF
   If EICLoja()
      Work_EIJ->EIJ_FABLOJ := Work_SW8->W8_FABLOJ
      Work_EIJ->EIJ_FORLOJ := Work_SW8->W8_FORLOJ
   EndIf

   IF lQbgOperaca//AWR - 20/12/2004
      Work_EIJ->EIJ_OPERAC:=Work_SW8->WKOPERACA
   ENDIF
   IF !(Work_SW8->WKREGTRI $ '2,6,9')
      Work_EIJ->EIJ_ALI_II:=SYD->YD_PER_II
   ENDIF
   IF Work_SW8->WKREGTRI # '6'
      //RRV - 14/01/2013 - Ajusta o IPI da adição com a tabela de IPI de Pauta, zerando a alíquota de IPI.
      If(lItemIpiPauta,Work_EIJ->EIJ_ALAIPI:=0,Work_EIJ->EIJ_ALAIPI:=SYD->YD_PER_IPI)
      If lItemIpiPauta
         Work_EIJ->EIJ_TPAIPI := '2'
         Work_EIJ->EIJ_ALUIPI := EI6->EI6_IPIUNI
         Work_EIJ->EIJ_CALIPI := EI6->EI6_CALIPI //MCF - 10/11/2015
         //Work_EIJ->EIJ_QTUIPI := EI6->EI6_QTD_EM - Nopado por MCF - 10/11/2015
      Else
         Work_EIJ->EIJ_TPAIPI:='1'
      EndIf
      IF lREGIPIW8
         Work_EIJ->EIJ_REGIPI:=Work_SW8->WKREGIPI
      ENDIF
   ENDIF
   IF lAUTPCDI
      WORK_EIJ->EIJ_REG_PC := Work_SW8->WKREG_PC
      WORK_EIJ->EIJ_FUN_PC := Work_SW8->WKFUN_PC
      WORK_EIJ->EIJ_FRB_PC := Work_SW8->WKFRB_PC
      //JAP - 31/07/06 - Redução inserida na SYD atribuida para o EIJ.
      IF Work_SW8->WKREG_PC == "4"
         WORK_EIJ->EIJ_REDCOF := SYD->YD_RED_COF
         WORK_EIJ->EIJ_REDPIS := SYD->YD_RED_PIS
      ENDIF
      IF !EMPTY(SYD->YD_VLU_PIS)
         Work_EIJ->EIJ_TPAPIS:='2'
         Work_EIJ->EIJ_ALUPIS:=SYD->YD_VLU_PIS
      ELSE
         Work_EIJ->EIJ_TPAPIS:='1'
         If WORK_EIJ->EIJ_REG_PC $ '6' //TDF - 11/11/11 - Regime tipo '6' não incidencia
            Work_EIJ->EIJ_ALAPIS:=0
         Else
            Work_EIJ->EIJ_ALAPIS:=SYD->YD_PER_PIS
         EndIf
      ENDIF
      IF !EMPTY(SYD->YD_VLU_COF)
         Work_EIJ->EIJ_TPACOF:='2'
         Work_EIJ->EIJ_ALUCOF:=SYD->YD_VLU_COF
      ELSE
         Work_EIJ->EIJ_TPACOF:='1'
         If WORK_EIJ->EIJ_REG_PC $ '6' //TDF - 11/11/11 - Regime tipo '6' não incidencia
            Work_EIJ->EIJ_ALACOF:=0
         Else
            Work_EIJ->EIJ_ALACOF:=SYD->YD_PER_COF

            If lCposCofMj                                                                             //NCF - 20/07/2012 - Majoração COFINS
               Work_EIJ->EIJ_ALCOFM:= EicGetPerMaj( Work_EIJ->EIJ_TEC+Work_EIJ->EIJ_EX_NCM+Work_EIJ->EIJ_EX_NBM , Work_EIJ->EIJ_OPERAC ,SYT->YT_COD_IMP, "COFINS")
               Work_EIJ->EIJ_ALACOF += Work_EIJ->EIJ_ALCOFM
            EndIf
            If lCposPisMj                                                                             //GFP - 11/06/2013 - Majoração PIS
               Work_EIJ->EIJ_ALPISM:= EicGetPerMaj( Work_EIJ->EIJ_TEC+Work_EIJ->EIJ_EX_NCM+Work_EIJ->EIJ_EX_NBM , Work_EIJ->EIJ_OPERAC ,SYT->YT_COD_IMP, "PIS")
               Work_EIJ->EIJ_ALAPIS += Work_EIJ->EIJ_ALPISM
            EndIf
         EndIF
      ENDIF
   ENDIF
   Work_EIJ->EIJ_TIPCOB:=SY6->Y6_TIPOCOB
   Work_EIJ->EIJ_MODALI:=SY6->Y6_TABELA
   Work_EIJ->EIJ_INSTFI:=SY6->Y6_INST_FI
   Work_EIJ->EIJ_MOTIVO:=SY6->Y6_MOTIVO
   Work_EIJ->EIJ_PERIOD:=IF(SY6->Y6_DIAS_PA>0 .AND. SY6->Y6_DIAS_PA<900,SY6->Y6_DIAS_PA,)
   Work_EIJ->EIJ_VINCCO:='1'
   IF lTemNVE //AWR - NVE
      Work_EIJ->EIJ_NVE:=Work_SW8->WKNVE
   ENDIF
   Work_EIJ->EIJ_REGTRI:=Work_SW8->WKREGTRI
   /*If Work_SW8->WKREGTRI="3"    TDF - 07/11/12 - De acordo com o SISCOMEX, quando o regime de trib. de II é isento, o regime de trib do IPI pode ser qualquer opção.
      Work_EIJ->EIJ_REGIPI := "1"*/
   If Work_SW8->WKREGTRI = "5"
    //Work_EIJ->EIJ_REGIPI := "5"     // GFP - 26/06/2013 - De acordo com o SISCOMEX, quando o regime de trib. de II é suspenso, o regime de trib do IPI pode ser qualquer opção.
      Work_EIJ->EIJ_REGICM:=Work_SW8->WKREGTRI
      Work_EIJ->EIJ_EXOICM:=Work_SW8->WKFUNREG
   EndIf
   Work_EIJ->EIJ_FUNREG:=Work_SW8->WKFUNREG
   Work_EIJ->EIJ_MOTADI:=Work_SW8->WKMOTADI
   Work_EIJ->EIJ_TACOII:=Work_SW8->WKTACOII
   Work_EIJ->EIJ_ACO_II:=Work_SW8->WKACO_II
   If lIntDraw
      If !Empty(Work_SW8->WKAC)
         ED0->(dbSetOrder(2))
         ED0->(dbSeek(cFilED0+Work_SW8->WKAC))
         If ED0->ED0_MODAL=="1"
            Work_EIJ->EIJ_REGTRI:="5"
         Else
            Work_EIJ->EIJ_REGTRI:="3"
         EndIf
         If Work_EIJ->EIJ_REGTRI = "3"
            Work_EIJ->EIJ_REGIPI := "1"
         ElseIf Work_EIJ->EIJ_REGTRI = "5"
            Work_EIJ->EIJ_REGIPI := "5"
            Work_EIJ->EIJ_REGICM:=Work_EIJ->EIJ_REGTRI
            Work_EIJ->EIJ_EXOICM:="16"
         EndIf
         Work_EIJ->EIJ_FUNREG:="16"
      EndIf
      Work_SW8->WKREGTRI := Work_EIJ->EIJ_REGTRI // BHF - 05/12/08
   ENDIF

   //** AAF 26/03/08 - Inicializar o tipo de certificado mercosul para sem certificado.
   If WORK_EIJ->(FieldPos("EIJ_IDCERT")) > 0
      WORK_EIJ->EIJ_IDCERT := CriaVar("EIJ_IDCERT")
   EndIf

   // BAK - Gravando da work da Invoice para a work da adicao
   If WORK_EIJ->(FieldPos("EIJ_CODMAT")) > 0 .And. Work_SW8->(FieldPos("WKCODMATRI")) > 0 .And. AvFlags("SUFRAMA") .And. EasyGParam("MV_TEM_DI", ,.F.)
      WORK_EIJ->EIJ_CODMAT := Work_SW8->WKCODMATRI
   EndIf

   IF(M->W6_TIPODES # '19',Work_EIJ->EIJ_TPAII:='1',)
   DI500AplicaMod(2)
   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GERA_EIJ_CAPA"),)
ELSE
   If lIntDraw
      If !Empty(Work_SW8->WKAC)
         ED0->(dbSetOrder(2))
         ED0->(dbSeek(cFilED0+Work_SW8->WKAC))
         If ED0->ED0_MODAL=="1"
            Work_EIJ->EIJ_REGTRI:="5"
         Else
            Work_EIJ->EIJ_REGTRI:="3"
         EndIf
         If Work_EIJ->EIJ_REGTRI = "3"
            Work_EIJ->EIJ_REGIPI := "1"
         ElseIf Work_EIJ->EIJ_REGTRI = "5"
            Work_EIJ->EIJ_REGIPI := "5"
            Work_EIJ->EIJ_REGICM:=Work_EIJ->EIJ_REGTRI
            Work_EIJ->EIJ_EXOICM:="16"
         EndIf
         Work_EIJ->EIJ_FUNREG:="16"
      EndIf
      Work_SW8->WKREGTRI := Work_EIJ->EIJ_REGTRI
   EndIf
ENDIF

//Campos Visuais do EIJ \/ \/
Work_EIJ->EIJ_MOEFRE:=M->W6_FREMOED
Work_EIJ->EIJ_TX_FRE:=M->W6_TX_FRET
Work_EIJ->EIJ_UM_EST:=SYD->YD_UNID
Work_EIJ->EIJ_TX_FOB:=Work_SW9->W9_TX_FOB
IF EMPTY(M->W6_SEGPERC)
   Work_EIJ->EIJ_MOESEG:=M->W6_SEGMOED
   Work_EIJ->EIJ_TX_SEG:=M->W6_TX_SEG
ELSE
   Work_EIJ->EIJ_MOESEG:=Work_EIJ->EIJ_MOEDA
   Work_EIJ->EIJ_TX_SEG:=Work_EIJ->EIJ_TX_FOB
ENDIF
//Campos Visuais do EIJ/\ /\
nQtdeEsta:=0
DI500QtdeEsta()

Work_EIJ->EIJ_QTITEM+= 1
Work_EIJ->EIJ_QT_EST+= nQtdeEsta

IF lItemIpiPauta //MCF - 10/11/2015
   IF EI6->EI6_CALIPI == "1" .AND. Work_SW8->WKREGTRI # '6'
      If !Empty(EI6->EI6_QTD_EM)
         Work_EIJ->EIJ_QTUIPI+= EI6->EI6_QTD_EM * Work_SW8->WKQTDE
      Else
         Work_EIJ->EIJ_QTUIPI+= Work_SW8->WKQTDE
      Endif
   Endif
Endif

IF SB1->B1_MIDIA $ cSim .AND. lExiste_Midia .AND. lPesoMid   // LDR - 25/08/04
   Work_EIJ->EIJ_PESOL += WORK->WKPESOMID * Work_SW8->WKQTDE * SB1->B1_QTMIDIA
   nFOBTotal:=DI500Trans((Work_SW8->WKQTDE * SB1->B1_QTMIDIA * SW2->W2_VLMIDIA)+Work_SW8->WKFRETEIN)   // Bete 24/02/05
ELSE
   Work_EIJ->EIJ_PESOL += Work_SW8->WKPESOTOT
   nFOBTotal:=DI500Trans(DI500RetVal("ITEM_INV", "WORK", .T.,, .T.))  // EOB - 21/05/08 - chamada da função DI500RetVal
ENDIF

Work_EIJ->EIJ_VLMLE += nFOBTotal
Work_EIJ->EIJ_VLMMN += DI500Trans(nFOBTotal*Work_SW9->W9_TX_FOB)
nAcertaFOB          += DI500Trans(nFOBTotal*Work_SW9->W9_TX_FOB)
nFOB_TOT            += DI500Trans(nFOBTotal*Work_SW9->W9_TX_FOB)  // EOS 17/11
IF Work_EIJ->EIJ_VLMMN > nFOBMaior
   nRecnoFOB:=Work_EIJ->(RECNO())
   nFOBMaior:=Work_EIJ->EIJ_VLMMN
ENDIF
IF EMPTY(Work_SW9->W9_TX_FOB)
   lTaxaPreenchida:=.F.
ENDIF

If Empty(Work_EIJ->EIJ_LOCVEN)  // GFP - 01/04/2013
   Work_EIJ->EIJ_LOCVEN := If(Empty(Work_EIJ->EIJ_LOCVEN),GetLocVen("ADICAO"),Work_EIJ->EIJ_LOCVEN) //NCF-13/05/2010  //GFP - 19/03/2013
EndIf
//NCF - 05/09/2018
If Len(aRegAdiCapa) > 0 .And. ( nPos := aScan(aRegAdiCapa, {|x| x[1] == cAdicao })  ) > 0
   Work_EIJ->WK_RECNO := aRegAdiCapa[nPos][2]   
EndIf

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GERA_EIJ_ITEM"),)

RETURN .T.

Function DI500QtdeEsta()

LOCAL cFilSAH:=xFilial("SAH"), cFilSJ5:=xFilial("SJ5")
PRIVATE cUMde:='  '

cUMde:=BUSCA_UM(Work_SW8->WKCOD_I+Work_SW8->WKFABR+Work_SW8->WKFORN,Work_SW8->WKCC+WORK_SW8->WKSI_NUM, Work_SW8->W8_FABLOJ, Work_SW8->W8_FORLOJ)

SAH->(DBSEEK(cFilSAH+cUMde))
IF !EMPTY(SAH->AH_COD_SIS) .AND. !EMPTY(SYD->YD_UNID)
   IF AvVldUn(SYD->YD_UNID) // MPG - 06/02/2018 

      IF SB1->B1_MIDIA $ cSim .AND. lExiste_Midia .AND. lPesoMid   // LDR - 25/08/04
         nQtdeEsta := SW7->W7_PESOMID * Work_SW8->WKQTDE * SB1->B1_QTMIDIA
      ELSE
         nQtdeEsta := Work_SW8->WKPESOTOT//SB1->B1_PESO
      ENDIF
                            // MPG - 06/02/2018 - adcionado o left para comparação do campo yd_unid
   ELSEIF Left(Alltrim(SAH->AH_COD_SIS),2) # Left(Alltrim(SYD->YD_UNID),2) .AND. Left(Alltrim(cUMde),2) # Left(Alltrim(SYD->YD_UNID),2)   //TRP - 16/04/10 - Tratar os casos em que a unidade de medida do item e da NCM são iguais.

	  IF LEN(SJ5->J5_DE) > LEN(cUMde)
	     cUMde:=cUMde+SPACE(LEN(SJ5->J5_DE)-LEN(cUMde))
	  ENDIF

      IF SJ5->(DBSEEK(cFilSJ5+cUMde+AvKey(SYD->YD_UNID,"J5_PARA")+SB1->B1_COD))  // GFP - 27/02/2013
         IF SB1->B1_MIDIA $ cSim .AND. lExiste_Midia .AND. lPesoMid   // LDR - 25/08/04
            nQtdeEsta := Work_SW8->WKQTDE * SB1->B1_QTMIDIA * SJ5->J5_COEF
         ELSE
   	        nQtdeEsta := Work_SW8->WKQTDE*SJ5->J5_COEF
         ENDIF
      ELSEIF SJ5->(DBSEEK(cFilSJ5+AVKEY(cUMde,"J5_DE")+AVKEY(SYD->YD_UNID,"J5_PARA")))
         DO WHILE !SJ5->(EOF()) .AND. SJ5->J5_FILIAL  == cFilSJ5 .AND.;
                                      SJ5->J5_DE      == AVKEY(cUMde,"J5_DE") .AND.;
                                      SJ5->J5_PARA    == AVKEY(SYD->YD_UNID,"J5_PARA")
            IF EMPTY(SJ5->J5_COD_I)
               IF SB1->B1_MIDIA $ cSim .AND. lExiste_Midia .AND. lPesoMid   // LDR - 25/08/04
                  nQtdeEsta := Work_SW8->WKQTDE * SB1->B1_QTMIDIA * SJ5->J5_COEF
               ELSE
   	              nQtdeEsta := Work_SW8->WKQTDE*SJ5->J5_COEF
               ENDIF
               EXIT
            ENDIF
            SJ5->(dbSkip())
         ENDDO
      ENDIF
   ELSE
      IF SB1->B1_MIDIA $ cSim .AND. lExiste_Midia .AND. lPesoMid   // LDR - 25/08/04
         nQtdeEsta := Work_SW8->WKQTDE * SB1->B1_QTMIDIA
      ELSE
         nQtdeEsta := Work_SW8->WKQTDE
      ENDIF
   ENDIF
ENDIF

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"QUANTIDADE_ESTATISTICA"),)

RETURN nQtdeEsta

Function DI500AplicaMod(nOpcao,aCposModelo)
Local aTxSisc := {}, i

DO CASE
CASE nOpcao = 1
     DI500GrvEI("EIJ",,aGrvEIJ,aCposModelo)
     DI500GrvEI("EIL",,aGrvEIL,.F.)
     DI500GrvEI("EIK",,aGrvEIK,.F.)
     DI500GrvEI("EIN",,aGrvEIN,.F.)

CASE nOpcao = 2
     lEIJSobrepoe:=.T.
     DI500GrvEI("EIJ",,aGrvEIJ)
     If( Select("Work_EIL") > 0 , DI500GrvEI("EIL",,aGrvEIL), )
     If( Select("Work_EIK") > 0 , DI500GrvEI("EIK",,aGrvEIK), )
//   DI500GrvEI("EIN",,aGrvEIN) Esta sendo chamada no While do EIJ do Rateio do seguro e do frete

CASE nOpcao = 3//Botao Aplica Modelo
     lEINSobrepoe:=.T.
     lEIJSobrepoe:=.F.
     Work_EIJ->(DBSETORDER(1))
     IF !WORK_EIJ->(DBSEEK("MOD"))
         Help("",1,"AVG0000714")//Nao existe Modelo Cadastrado.",0057) //0413
         RETURN .F.
     ENDIF
     lEIJSobrepoe:=MSGYESNO(STR0652,STR0141)//AWR - 06/2009 - Chamado P10 //STR0652 "Sobrepoe campos preenchidos das Adicoes ?"
     IF !(Work_EIJ->EIJ_RATACR $ cSim)
        lEINSobrepoe:=MSGYESNO(STR0505 ,STR0141)//"Sobrepoe valores de Acrescimos/Deducoes ?"
     ENDIF
     aCposModelo:={}
     aGrvEIJ:={}
     aGrvEIN:={}
     aGrvEIK:={}
     aGrvEIL:={}
     ProcRegua( Work_EIJ->(EasyReccount("Work_EIJ"))+5)
     DI500EIJManut(5,,aCposModelo)
     IncProc(STR0264+Work_EIJ->EIJ_ADICAO) //"Aplicando Adicao: "
     DI500GrvEI("EIJ",,aGrvEIJ,aCposModelo)
     IncProc(STR0264+Work_EIJ->EIJ_ADICAO) //"Aplicando Adicao: "
     DI500GrvEI("EIL",,aGrvEIL,.F.)
     IncProc(STR0264+Work_EIJ->EIJ_ADICAO) //"Aplicando Adicao: "
     DI500GrvEI("EIK",,aGrvEIK,.F.)
     IncProc(STR0264+Work_EIJ->EIJ_ADICAO) //"Aplicando Adicao: "
     DI500GrvEI("EIN",,aGrvEIN,.F.)
     IncProc(STR0264+Work_EIJ->EIJ_ADICAO) //"Aplicando Adicao: "
     DI500GrvEI("EII_SW6")
     Work_EIJ->(DBGOTOP())
     nAcertaFOB:=0
     DO WHILE Work_EIJ->(!EOf())
        IF Work_EIJ->EIJ_ADICAO == "MOD"
           Work_EIJ->(DBSKIP())
           LOOP
        ENDIF
        nAcertaFOB+=Work_EIJ->EIJ_VLMMN
        Work_EIJ->(DBSKIP())
     ENDDO
     Work_EIJ->(DBGOTOP())
     DO WHILE Work_EIJ->(!EOf())
        IncProc(STR0264+Work_EIJ->EIJ_ADICAO) //"Aplicando Adicao: "
        IF Work_EIJ->EIJ_ADICAO == "MOD"
           Work_EIJ->(DBSKIP())
           LOOP
        ENDIF
        DI500GrvEI("EIJ",,aGrvEIJ)
        DI500GrvEI("EIL",,aGrvEIL)
        DI500GrvEI("EIK",,aGrvEIK)
        DI500GrvEI("EIN",,aGrvEIN,,,,.T.)
        AADD(aTxSisc,{WORK_EIJ->EIJ_ADICAO,WORK_EIJ->EIJ_TAXSIS})
        DI500CalcEIJ('Work_EIJ')
        Work_EIJ->(DBSKIP())
     ENDDO
     IF ((!EMPTY(M->W6_SEGPERC) .AND. M->W6_SEGBASE $ "3,4") /*.OR. lMV_TXSIRAT*/) .AND. lGravouEIN//AWR - 11/01/2005
        Processa({|| DI500GeraAdicoes()},STR0342) //"Gerando Adicoes..."
        Work_EIJ->(DBGOTOP()) //MCF-10/04/2015 //LGS-16/09/2014 - Validação para rateio da taxa siscomex qdo aplica modelo de adicao.
        //NCF - 02/04/2020 - Ativado o parametro MV_TXSISRAT e o seguro sendo percentual, caso exista acréscimos e deduções nas adições e no modelo,
        //                   a taxa siscomex já é rateada por CIF (Base II) corretamente dentro da DI500GeraAdicoes considerando o recálculo de
        //                   acréscimos, deduções e seguro percentual.
        /*IF Len(aTxSisc) # 0           
           For i := 1 To Len(aTxSisc)   
               IF WORK_EIJ->(DbSeek(aTxSisc[i][1])) .And. aTxSisc[i][2] <> WORK_EIJ->EIJ_TAXSIS
                  WORK_EIJ->EIJ_TAXSIS := aTxSisc[i][2]
               ENDIF
           Next
        ENDIF*/
     ENDIF
     Work_EIJ->(DBGOTOP())
     IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"APLICAMOD"),)
ENDCASE
RETURN .T.

Function DI500GrvEI(cAlias,nAdicao,aGrava,aCpos,lDSI,lBotaoTaxas,lCalc)

LOCAL nVlrTab:=0,M,cTabela:="C5",nRecno:=0,nTx
LOCAL nEII // do FOR
LOCAL nVlrDumpA:=nVlrDumpE:=VlAntDumpTot:=0
Local nCurrier := M->W6_CURRIER
Local lDesConCarg := (SW6->(FieldPos("W6_CO_CARG")) # 0 .And. M->W6_CO_CARG == '1') //LRS 4/9/2013 - 9:00 - Chamado 743788: Foi Adicionado a variavel para a validação de N.F sem D.I
DEFAULT lDSI := .F.
DEFAULT lBotaoTaxas := .F.
DEFAULT lCalc       := .F.
Private nVLRDMP:=0

IF cAlias == "EII"

   SX5->(DBSETORDER(1))
   nVlrTab:=0// AWR - 24/05/2004
   IF SX5->(DBSEEK(xFilial("SX5")+cTabela+"00"))
      nVlrTab:=VAL(SX5->X5_DESCRI)
   ENDIF

   FOR nTx := 1 TO nAdicao
       IF nTx < 100
          cSeek:=STRZERO(nTx,2,0)
       ELSE
          cSeek:="99"
       ENDIF
       SX5->(DBSEEK(xFilial("SX5")+cTabela+cSeek,.T.))
       nVlrTab+=VAL(SX5->X5_DESCRI)
   NEXT

//SX5 - Tabela de Taxa do SISCOMEX
//Tabela  Adicao  Valor
//C5      00      30 (Valor minimo)
//C5      02      10
//C5      05      08
//C5      10      06
//C5      20      04
//C5      50      02
//C5      99      01

   IF !Work_EII->(DBSEEK("7811"))
      Work_EII->(DBAPPEND())
      Work_EII->EII_CODIGO:="7811"
   ENDIF

   IF nCurrier <> "1" //RNLP 26/02/2020 - Issue DTRADE-3281 - remoção dos pontos que consideram este campo(W6_CO_CARG) como condição para a geração da taxa SISCOMEX
      Work_EII->EII_VLTRIB:= nVlrTab// AWR - 24/05/2004
   Else
      Work_EII->EII_VLTRIB:= 0
   Endif
   nSomaTaxaSisc:=0// AWR - 18/02/2004
   //DFS - Criação de Tratamento para que só calcule a taxa siscomex quando Currier for diferente de 1

   IF nCurrier <> "1" //RNLP 26/02/2020 - Issue DTRADE-3281 - remoção dos pontos que consideram este campo(W6_CO_CARG) como condição para a geração da taxa SISCOMEX
      nSomaTaxaSisc:=Work_EII->EII_VLTRIB
   Endif
   nMemAdicao:=nAdicao//Para o Rdmake
   lGravaEII :=.T.

ELSEIF cAlias == "EII_SW6"
   lSair := .F.
   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GRAVA_EII_SW6"),)
   IF lSair
      RETURN .T.
   ENDIF

   IF !lDSI
      nVLAIPI:=nVLARII:=nVLRDMP:=0
      Processa({|| DI500AdiSoma(.F.)})
   ENDIF

   nVLRPIS:=nVLRCOF:= 0
   IF lMV_PIS_EIC
      nRecno:=Work_SW8->(RECNO())
      Work_SW8->(DBGOTOP())
      DO WHILE !Work_SW8->(EOF())
         IF EMPTY(Work_SW8->WKFLAGIV) .OR.  EMPTY(Work_SW8->WKINVOICE)
            Work_SW8->(DBSKIP())
            LOOP
         ENDIF
         IF lAUTPCDI .AND. Work_SW8->WKREG_PC $ "3,5" //Work_SW8->WKREGTRI $ "3,5" // GFP - 22/10/2014
            Work_SW8->(DBSKIP())
            LOOP
         ENDIF
         nVLRPIS+=Work_SW8->WKVLRPIS
         nVLRCOF+=Work_SW8->WKVLRCOF
         Work_SW8->(DBSKIP())
      ENDDO
      Work_SW8->(DBGOTO(nRecno))
   ENDIF

   cCod_EII:=ALLTRIM(GETNEWPAR("MV_COD_EII","2892,3345,5602,5629,5529,"))

   aCodValEII:={}
   DO WHILE !EMPTY(cCod_EII)

      nPos:=AT(',',cCod_EII)
      IF nPos # 0
         AADD(aCodValEII,{SUBSTR(cCod_EII,1,nPos-1),0})
         cCod_EII:=SUBSTR(cCod_EII,nPos+1)
      ELSE
         AADD(aCodValEII,{cCod_EII,0})
         cCod_EII:=""
      ENDIF

      IF LEN(aCodValEII) = 1
         aCodValEII[1,2]:=nVLARII
      ELSEIF LEN(aCodValEII) = 2
         aCodValEII[2,2]:=nVLAIPI
      ELSEIF LEN(aCodValEII) = 3
         aCodValEII[3,2]:=nVLRPIS
      ELSEIF LEN(aCodValEII) = 4
         aCodValEII[4,2]:=nVLRCOF
      ELSEIF LEN(aCodValEII) = 5  // BHF - 26/01/09 - AntiDumping
         aCodValEII[5,2]:=nVLRDMP
      ENDIF

   ENDDO

   FOR nEII := 1 TO LEN(aCodValEII)

       IF !Work_EII->(DBSEEK(aCodValEII[nEII,1])) .AND. !EMPTY(aCodValEII[nEII,2])
          Work_EII->(DBAPPEND())
          Work_EII->EII_CODIGO:= aCodValEII[nEII,1]
          Work_EII->EII_VLTRIB:= aCodValEII[nEII,2]
          lGravaEII :=.T.
       ELSEIF !Work_EII->(EOF())
          IF EMPTY(aCodValEII[nEII,2])
             IF !EMPTY(Work_EII->WK_RECNO) .AND. ASCAN(aDeletados,{|D| D[1]='EII' .AND. D[2]=Work_EII->WK_RECNO} ) = 0
                AADD(aDeletados,{'EII',Work_EII->WK_RECNO})
             ENDIF
             Work_EII->(DBDELETE())
          ELSE
             Work_EII->EII_VLTRIB:= aCodValEII[nEII,2]
          ENDIF
          lGravaEII :=.T.
       ENDIF

   NEXT


ELSEIF cAlias == "EIJ"
   IF aGrava # NIL .AND. aCpos # NIL
      FOR M := 1 TO LEN(aCpos)
         IF EIJ->(FIELDPOS(aCpos[M])) # 0 .AND.;//Para nao gravar os campos visuais
            (nPos:= Work_EIJ->(FIELDPOS(aCpos[M]))) # 0
            AADD(aGrava, { aCpos[M], Work_EIJ->(FIELDGET(nPos)) } )
         ENDIF
      NEXT
   ELSEIF aGrava # NIL
      lGravaEIJ:=.T.
      Work_EIJ->EIJ_RATACR:=' '//Para sobrepor o campo sempre
      FOR M := 1 TO LEN(aGrava)
         IF EIJ->(FIELDPOS(aGrava[M,1])) # 0 .AND.;//Para nao gravar os campos visuais
            (nPos:= Work_EIJ->(FIELDPOS(aGrava[M,1]))) # 0
            IF (EMPTY(Work_EIJ->(FIELDGET( nPos ))) .OR. lEIJSobrepoe) .and.;        // GFC - 21/01/2004
            If(lIntDraw .and. Work_EIJ->(FieldName(nPos)) $ ("EIJ_REGTRI/EIJ_REGIPI/EIJ_REGICM/EIJ_EXOICM/EIJ_FUNREG"), !(Work_EIJ->EIJ_REGTRI $ ("03/05") .and. Alltrim(Work_EIJ->EIJ_FUNREG) == "16"), .T.)
               Work_EIJ->(FIELDPUT( nPos,aGrava[M,2] ))
            ENDIF
         ENDIF
      NEXT
      IF lEIJSobrepoe
         IF Work_EIJ->EIJ_REGTRI $ '2,6,9'
            Work_EIJ->EIJ_ALI_II:=0
         ENDIF
         IF Work_EIJ->EIJ_REGIPI $ '3' .OR. Work_EIJ->EIJ_REGTRI = '6'
            Work_EIJ->EIJ_ALAIPI:=0
         ENDIF
      ENDIF
   ENDIF

ELSEIF cAlias == "EIL"
    Work_EIL->(DBSETORDER(1))
    IF aGrava # NIL .AND. aCpos # NIL
       Work_EIL->(DBSEEK("MOD"))
       DO WHILE Work_EIL->(!EOF()) .AND. Work_EIL->EIL_ADICAO == "MOD"
          AADD(aGrava, Work_EIL->EIL_DESTAQ )
          Work_EIL->(DBSKIP())
       ENDDO
    ELSEIF aGrava # NIL
       lGravaEIL:=.T.
       FOR M := 1 TO LEN(aGrava)
          IF !Work_EIL->(DBSEEK(Work_EIJ->EIJ_ADICAO+aGrava[M]))
             Work_EIL->(DBAPPEND())
             Work_EIL->EIL_ADICAO:=Work_EIJ->EIJ_ADICAO
             Work_EIL->EIL_DESTAQ:=aGrava[M]
          ENDIF
       NEXT
    ENDIF

ELSEIF cAlias == "EIK"
    Work_EIK->(DBSETORDER(1))
    IF aGrava # NIL .AND. aCpos # NIL
       Work_EIK->(DBSEEK("MOD"))
       DO WHILE Work_EIK->(!EOF()) .AND. Work_EIK->EIK_ADICAO == "MOD"
          AADD(aGrava, {Work_EIK->EIK_TIPVIN,Work_EIK->EIK_DOCVIN} )
          Work_EIK->(DBSKIP())
       ENDDO
    ELSEIF aGrava # NIL
       lGravaEIK:=.T.
       FOR M := 1 TO LEN(aGrava)
          IF !Work_EIK->(DBSEEK(Work_EIJ->EIJ_ADICAO+aGrava[M,1]+aGrava[M,2]))
             Work_EIK->(DBAPPEND())
             Work_EIK->EIK_ADICAO:=Work_EIJ->EIJ_ADICAO
             Work_EIK->EIK_TIPVIN:=aGrava[M,1]
             Work_EIK->EIK_DOCVIN:=aGrava[M,2]
          ENDIF
       NEXT
    ENDIF

ELSEIF cAlias == "EIN"
    Work_EIN->(DBSETORDER(1))
    IF aGrava # NIL .AND. aCpos # NIL
       Work_EIN->(DBSEEK("MOD"))
       DO WHILE Work_EIN->(!EOF()) .AND. Work_EIN->EIN_ADICAO == "MOD"
          AADD(aGrava, {Work_EIN->EIN_TIPO,Work_EIN->EIN_CODIGO,Work_EIN->EIN_DESC,;
                        Work_EIN->EIN_FOBMOE,Work_EIN->EIN_VLMLE,Work_EIN->EIN_VLMMN} )
          Work_EIN->(DBSKIP())
       ENDDO
    ELSEIF aGrava # NIL
       lGravouEIN:=lGravaEIN:=.T.
       FOR M := 1 TO LEN(aGrava)
           IF !Work_EIN->(DBSEEK(Work_EIJ->EIJ_ADICAO+aGrava[M,1]+aGrava[M,2]+aGrava[M,4]))
              Work_EIN->(DBAPPEND())
              Work_EIN->EIN_ADICAO:=Work_EIJ->EIJ_ADICAO
              IF !Check_adic(Work_EIN->EIN_ADICAO) // 03/08/12 - BCO - Validação para o Campo EIN_ADICAO não ser gravado vazio
                 Return .F.
              ENDIF
              Work_EIN->EIN_TIPO  :=aGrava[M,1]
              Work_EIN->EIN_CODIGO:=aGrava[M,2]
              Work_EIN->EIN_DESC  :=aGrava[M,3]
              Work_EIN->EIN_FOBMOE:=aGrava[M,4]
          ENDIF
          IF lEINSobrepoe
             IF Work_EIJ->EIJ_RATACR $ cSim
                IF Work_EIN->EIN_CODIGO $ cCodRatPeso
                   Work_EIN->EIN_VLMLE:=(Work_EIJ->EIJ_PESOL/SW6->W6_PESOL)*aGrava[M,5]         //NCF - 24/09/2010 - Rateio das despesas de acrescimos por peso
                ELSE
                   Work_EIN->EIN_VLMLE:=(Work_EIJ->EIJ_VLMMN/nFOB_TOT)*aGrava[M,5]//NACERTAFOB
                ENDIF
             ELSE
                Work_EIN->EIN_VLMLE:=aGrava[M,5]
             ENDIF
          ENDIF
       NEXT
       lTemAcrescimo:=Work_EIN->(DBSEEK("MOD1"))
       lTemDeducao  :=Work_EIN->(DBSEEK("MOD2"))
       Work_EIN->(DBSEEK(Work_EIJ->EIJ_ADICAO))
       DO WHILE Work_EIN->(!EOF()) .AND. Work_EIN->EIN_ADICAO == Work_EIJ->EIJ_ADICAO
          lDeleta:=.F.
          IF !lTemAcrescimo .AND. lEINSobrepoe .AND. Work_EIN->EIN_TIPO == '1'
             lDeleta:=.T.
          ENDIF
          IF !lTemDeducao .AND. lEINSobrepoe .AND. Work_EIN->EIN_TIPO == '2'
             lDeleta:=.T.
          ENDIF
          IF EMPTY(Work_EIN->EIN_VLMLE)
             lDeleta:=.T.
          ENDIF
          IF lDeleta
             IF !EMPTY(Work_EIN->WK_RECNO)
                IF ASCAN(aDeletados,{|D| D[1]='EIN' .AND. D[2]=Work_EIN->WK_RECNO} ) = 0
                   AADD(aDeletados,{'EIN',Work_EIN->WK_RECNO})
                ENDIF
             ENDIF
             Work_EIN->(DBDELETE())
             Work_EIN->(DBSKIP())
             LOOP
          ENDIF
          IF lBotaoTaxas
             IF AllTrim(Work_EIN->EIN_FOBMOE) == "R$" //AOM - 22/03/2010
                Work_EIN->EIN_VLMMN:= Work_EIN->EIN_VLMLE
             ELSE
                Work_EIN->EIN_VLMMN:=Work_EIN->EIN_VLMLE*BuscaTaxa(Work_EIN->EIN_FOBMOE,dDataBusca,.T.,.F.,.T.)
             ENDIF
          ELSE
             IF lCalc
                IF AllTrim(Work_EIN->EIN_FOBMOE) == "R$" //AOM - 22/03/2010
                   Work_EIN->EIN_VLMMN:= Work_EIN->EIN_VLMLE
                ELSE
                   Work_EIN->EIN_VLMMN:=Work_EIN->EIN_VLMLE*BuscaTaxa(Work_EIN->EIN_FOBMOE,dDataBase,.T.,.F.,.T.)
                ENDIF
             ENDIF
          ENDIF
       Work_EIN->(DBSKIP())
       ENDDO
    ENDIF
ENDIF

cAliasMod:=cAlias
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GRAVA_EI_MODELO"),)

RETURN .T.


Function DI500ApFreAdi(nPeso,nFrete,nTaxa, nFOB)

Local nFreteAux,aFrete:={,,}

nFreteAux := DI500Trans(M->W6_VLFREPP + M->W6_VLFRECC - M->W6_VLFRETN) //FRETE TOTAL
nFreteAux := DI500Trans((nPeso / nPesoProc) * nFreteAux) //Frete correspondente ao peso

aFrete[1] := nFreteAux //Frete na Moeda
nFreteAux := DI500Trans(nFreteAux * M->W6_TX_FRET) //Transforma em Reais
aFrete[2] := nFreteAux //Frete em Real
IF nTaxa # NIL
   aFrete[3] := aFrete[2] / nTaxa//Work_EIJ->EIJ_TX_FOB
ENDIF
IF nFrete = NIL
   Return aFrete
ENDIF

Return aFrete[nFrete]

Function DI500CalcEIJ(cAlias)

LOCAL nAcrecimo:=nDeducao:=0,cFilSWZ:=xFilial("SWZ"),cFilSYD:=xFilial("SYD")
LOCAL nRecVlr:=nRecFre:=0,aAcertos:={}
LOCAL nMaiorFre:=nMaiorVlr:=0
LOCAL cAdicao := DI500Block(cAlias,"EIJ_ADICAO"),nCont:=0
LOCAL lAcerto:=lAcertoSeg:=.T.,aSeguro, nContaItem:=0
LOCAL nOrdSW8:=Work_SW8->(INDEXORD())
LOCAL A // do FOR
LOCAL nVlICMS  :=EasyGParam("MV_ICMSMID",,0)//AWR  - 28/06/2006
Local nQtdeTot  := 0
Local nQtdRateio:= 0
Local aConvVal
Local nPos1     := 0
Local nVal_CP1 := 0
Local nVal_CP2 := 0
Local aOrd_EIN := {}
Local nAcresFrete := 0
Local nRatPeso:= 0
Local nCurrier   := M->W6_CURRIER  //DFS - Variável para verificação de taxa siscomex
Local lDesConCarg := (SW6->(FieldPos("W6_CO_CARG")) # 0 .And. M->W6_CO_CARG == '1') //LRS 4/9/2013 - 9:00 - Chamado 743788: Foi Adicionado a variavel para a validação de N.F sem D.I
Local i
Local oRateioRS
Local lTxSisICMS := DI500TxICM(M->W6_IMPORT)

PRIVATE nEIJ_BASPIS:=nEIJ_BR_PIS:=nEIJ_VLDPIS:=nEIJ_VLRPIS:=nEIJ_BASCOF:=nEIJ_BR_COF:=nEIJ_VLDCOF:=nEIJ_VLRCOF:=0
PRIVATE nEIJ_QTUPIS:=nEIJ_QTUCOF:=0
Private nQtdAdi := 0             // AAF 12/02/2007 - Rateio de quatidade específica da adição por quantidade do item.

ProcRegua( 24 )

nTotAcres:=nTotDeduc:=nRecWKEIJ:=nBaseTotalII:=0 //THTS - 13/06/2017 - TE5755  Campo taxa siscomex na adição
nRecWKEIJ:=Work_EIJ->(recno())
Work_EIJ->(dbGoTop())
Do While Work_EIJ->(!EOF())
   If Work_EIJ->EIJ_ADICAO <> "MOD"                                  //NCF - 27/09/2011 - Não pode somar o valor do modelo nos acréscimos
      DI500GrvCpoVisual("EIJ_EINA",@nAcrecimo,,Work_EIJ->EIJ_ADICAO)
      DI500GrvCpoVisual("EIJ_EIND",,@nDeducao ,Work_EIJ->EIJ_ADICAO)
      nTotAcres += nAcrecimo
      nTotDeduc += nDeducao
   EndIf
   nBaseTotalII +=Work_EIJ->EIJ_BAS_II //THTS - 13/06/2017 - TE5755  Campo taxa siscomex na adição
   Work_EIJ->(dbSkip())
EndDo
Work_EIJ->(dbGoTo(nRecWKEIJ))
nVal_Dif := nVal_CP := nVal_ICM := 0   //TRP - 18/02/2010

IncProc(STR0266) //"Calculando Impostos "
DI500GrvCpoVisual("EIJ_EINA",@nAcrecimo,,cAdicao)
DI500GrvCpoVisual("EIJ_EIND",,@nDeducao ,cAdicao)


//1-Imposto de Importacao
//=======================
nBaseII:=nPr_II:=0// Variaveis usada em Rdmake
DI500IICalc(cAlias,DI500Block(cAlias,"EIJ_VLMMN" ),;
                   DI500Block(cAlias,"EIJ_VFREMN"),;
                   DI500Block(cAlias,"EIJ_VSEGMN"),;
                   DI500Block(cAlias,"EIJ_INCOTE"),nAcrecimo,nDeducao,@nBaseII,.T.)

IncProc(STR0266) //"Calculando Impostos "
//2-Imposto Sobre Produto Industrializado
//=======================================
DI500IPICalc(cAlias,nBaseII,DI500Block(cAlias,"EIJ_VLARII"),.T.,DI500Block(cAlias,"EIJ_DEVII"),/*6*/,/*7*/,/*8*/,/*9*/,DI500Block(cAlias,"EIJ_QTUIPI"),DI500Block(cAlias,"EIJ_ALUIPI"))

IncProc(STR0266) //"Calculando Impostos "
//3-Imposto Antidumping
//=====================
//Valor Devido := Calculo por Aliquota-AD-Valorem
//DI500Block(cAlias,"EIJ_VLD_DU", DI500Trans((DI500Block(cAlias,"EIJ_ALADDU")*(DI500Block(cAlias,"EIJ_BAD_AD")/100))) )
//Calculo por Aliquota-AD-Valorem
nVlrDumpA:=DI500Trans((DI500Block(cAlias,"EIJ_ALADDU")*(DI500Block(cAlias,"EIJ_BAD_AD")/100)))

//Valor a Recolher := Calculo por Valor Especifico
//DI500Block(cAlias,"EIJ_VLR_DU", DI500Trans((DI500Block(cAlias,"EIJ_ALADDU")*DI500Block(cAlias,"EIJ_BAE_AD"))) )
//Calculo por Valor Especifico
nVlrDumpE:=DI500Trans((DI500Block(cAlias,"EIJ_ALEADU")*DI500Block(cAlias,"EIJ_BAE_AD")))

//IF !EMPTY(DI500Block(cAlias,"EIJ_VLR_DU"))
//ENDIF
//Valor Devido
DI500Block(cAlias,"EIJ_VLD_DU", nVlrDumpA+nVlrDumpE )
//Valor a Recolher
DI500Block(cAlias,"EIJ_VLR_DU", nVlrDumpA+nVlrDumpE )

IncProc(STR0266) //"Calculando Impostos "
//4-Imposto sobre Circulacao de Mercadorias e Servicos
//====================================================
nMaiorFre:=nMaiorVlr:=0
aAcertos:={}
AADD(aAcertos,{0,DI500Block(cAlias,"EIJ_VFREMN")})
AADD(aAcertos,{0,DI500Block(cAlias,"EIJ_VSEGMN")})
AADD(aAcertos,{0,nAcrecimo})
AADD(aAcertos,{0,nDeducao})
AADD(aAcertos,{0,DI500Block(cAlias,"EIJ_VLMMN")})
IF AvRetInco(Work_EIJ->EIJ_INCOTE,"CONTEM_FRETE")/*FDR - 27/12/10*/  //Work_EIJ->EIJ_INCOTE $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP"
   nVLMLE := DI500Block(cAlias,"EIJ_VLMLE")-DI500Block(cAlias,"EIJ_VLFRET")
   // EOB - 27/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
   IF AvRetInco(Work_EIJ->EIJ_INCOTE,"CONTEM_SEG")/*FDR - 27/12/10*/  //Work_EIJ->EIJ_INCOTE $ "CIF,CIP,DAF,DES,DEQ,DDP,DDU"
      nVLMLE -= DI500Block(cAlias,"EIJ_VSEGLE")
   ENDIF
   AADD(aAcertos,{0,nVLMLE})
ELSE
   AADD(aAcertos,{0,DI500Block(cAlias,"EIJ_VLMLE")})
ENDIF

//Em Analise AWR
//nSomaItemNoCIF :=nSomaNoCIF*(DI500Block(cAlias,"EIJ_VLMMN")/nAcertaFOB)
//TDF - 05/10/12 - Soma despesa base de ICMS rateada por peso
nSomaItemBaseICMS:=DI500Trans( nSomaBaseICMS * (DI500Block(cAlias,"EIJ_VLMMN")/nFOB_TOT)) + DI500Trans(nBaseICMSPeso*(DI500Block(cAlias,"EIJ_PESOL")/SW6->W6_PESOL))// Aqui nao pode somar Taxa Siscomex
/* despesas que devem ser rateadas pela quantidade de adições */
nSomaItemBaseICMS += DI500Trans(nSomaDespRatAdicao/M->W6_QTD_ADI)
If lDespBaseIcms //NCF - 20/12/2010 - Acerto de rateio das despesas base de ICMS por item das adições
   Work_EIJ->EIJ_DPBICM := DI500Trans( nSomaBaseICMS * (DI500Block(cAlias,"EIJ_VLMMN")/nFOB_TOT)) + DI500Trans(nBaseICMSPeso*(DI500Block(cAlias,"EIJ_PESOL")/SW6->W6_PESOL))//NCF - 20/12/2010 - Despesas Base de ICMS da Adição sem Taxa Siscomex
   /* despesas que devem ser rateadas pela quantidade de adições */
   Work_EIJ->EIJ_DPBICM += DI500Trans(nSomaDespRatAdicao/M->W6_QTD_ADI)
   
   If lAntDumpBaseICMS//AAF 05/07/2017 - adicionado antidumping
      Work_EIJ->EIJ_DPBICM += DI500Block(cAlias,"EIJ_VLR_DU")
   EndIf
EndIf
//IF EMPTY(Work_EIJ->EIJ_TAXSIS)// Para nao perder o acerto na Altercao da Adicao

IF nCurrier <> "1" //RNLP 26/02/2020 - Issue DTRADE-3281 - remoção dos pontos que consideram este campo(W6_CO_CARG) como condição para a geração da taxa SISCOMEX
   Work_EIJ->EIJ_TAXSIS:=DI500Trans( DI500TxSiscomex(VAL(Work_EIJ->EIJ_ADICAO),M->W6_QTD_ADI,(Work_EIJ->EIJ_BAS_II/nBaseTotalII)) ) //THTS - 13/06/2017 - TE5755  Campo taxa siscomex na adição
Else
   Work_EIJ->EIJ_TAXSIS:= 0
Endif

// EOS 14/11/03 - p/ acerto das despesas que sao base de ICMS - por adicao
IF lAntDumpBaseICMS//AWR - 25/11/2004
   AADD(aAcertos,{0,nSomaItemBaseICMS+IF(lTxSisICMS ,Work_EIJ->EIJ_TAXSIS,0) +DI500Block(cAlias,"EIJ_VLR_DU")})// Somar Taxa Siscomex p/ o acerto
ELSE
   AADD(aAcertos,{0,nSomaItemBaseICMS+IF(lTxSisICMS ,Work_EIJ->EIJ_TAXSIS,0) })// Somar Taxa Siscomex p/ o acerto
ENDIF
AADD(aAcertos,{0,Work_EIJ->EIJ_TAXSIS})
AADD(aAcertos,{0,DI500Block(cAlias,"EIJ_VLR_DU")})//AWR - 25/11/2004

lAcerto:=.T.
lAcertoSeg:=.T.
//Rotina de Rateio
SYD->(DBSETORDER(1))
SWZ->(DBSETORDER(2))
SB1->(DBSETORDER(1))
Work_SW8->(DBSETORDER(4))
Work_SW8->(DBSEEK(cAdicao))
nRecVlr := Work_SW8->(RECNO())

oRateioRS := EasyRateio():New(;
    Work_EIJ->EIJ_VSEGMN,;
    IF(AvRetInco(Work_EIJ->EIJ_INCOTE,"CONTEM_FRETE"),Work_EIJ->EIJ_VLMMN-Work_EIJ->EIJ_VFREMN,Work_EIJ->EIJ_VLMMN),;
    Work_SW8->(EasyRecCount("Work_SW8")),;
    AvSX3("EIJ_VSEGMN", AV_DECIMAL);
)

nCont:= EasyRecCount("Work_SW8")
ProcRegua(nCont)

DO WHILE Work_SW8->(!EOF()) .AND.;
         Work_SW8->WKADICAO == cAdicao

   IncProc(STR0266+Work_SW8->WKCOD_I) //"Calculando Impostos "

   IF EMPTY(Work_SW8->WKFLAGIV) .AND. EMPTY(Work_SW8->WKINVOICE)
      Work_SW8->(DBSKIP())
      LOOP
   ENDIF
   //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
   WORK_SW9->(DBSEEK(Work_SW8->WKINVOICE+Work_SW8->WKFORN+Work_SW8->W8_FORLOJ+M->W6_HAWB))
   SB1->(dbSeek(xFilial("SB1")+Work_SW8->WKCOD_I))
   IF lExiste_Midia .AND. lPesoMid .AND. SB1->B1_MIDIA $ cSIM
      SW2->(DBSEEK(xFILIAL("SW2")+Work_SW8->WKPO_NUM))
      nTotSW8:=DI500Trans((Work_SW8->WKQTDE*SB1->B1_QTMIDIA*SW2->W2_VLMIDIA)+Work_SW8->WKFRETEIN)  // Bete 24/02/05
      WORK->(DBSETORDER(2))
      WORK->(DBSEEK(Work_SW8->(WKPO_NUM+WKCC+WKSI_NUM+WKCOD_I)))
      nPesoItem := Work_SW8->WKQTDE*SB1->B1_QTMIDIA*Work->WKPESOMID
   ELSE
      nTotSW8:=DI500Trans(DI500RetVal("ITEM_INV", "WORK", .T.,, .T.)) // EOB - 21/05/08 - chamada da função DI500RetVal
      nPesoItem := Work_SW8->WKPESOTOT
   ENDIF

   Work_SW8->WKFOBTOTR:=DI500Trans((nTotSW8*Work_SW9->W9_TX_FOB))
   Work_SW8->WKVLFREMN:=DI500Trans((nPesoItem/DI500Block(cAlias,"EIJ_PESOL"))*DI500Block(cAlias,"EIJ_VFREMN"))
   IF AvRetInco(Work_EIJ->EIJ_INCOTE,"CONTEM_FRETE")/*FDR - 27/12/10*/  //Work_EIJ->EIJ_INCOTE $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDP,DDU"//AWR - DDU
      nVLFRET:=DI500Trans((nPesoItem/DI500Block(cAlias,"EIJ_PESOL"))*DI500Block(cAlias,"EIJ_VLFRET"))
      Work_SW8->WKVLMLE:=nTotSW8-nVLFRET
      nFOBRS:=DI500Block(cAlias,"EIJ_VLMMN")-DI500Block(cAlias,"EIJ_VFREMN")
   ELSE
      Work_SW8->WKVLMLE:=nTotSW8
      nFOBRS:=DI500Block(cAlias,"EIJ_VLMMN")
   ENDIF
   nRateio:=(Work_SW8->WKFOBTOTR/DI500Block(cAlias,"EIJ_VLMMN"))

   // NCF - 30/09/2011 - Ponto de entrada para manipular os códigos de acrescimos a serem rateados por peso
   If EasyEntryPoint("EICDI500")
      Execblock("EICDI500",.F.,.F.,"RATEIO_ACRESCIMOS")
   EndIf

   // NCF - 27/07/2010 - Calcula os acrescimos de frete da adição separadamente para ratear por peso
   IF SELECT("Work_EIN") > 0 .And. Work_EIN->(EasyRecCount("Work_EIN")) > 0
      aOrd_EIN := SaveOrd({"Work_EIN"})
      Work_EIN->(DbGoTop())
      Work_EIN->(DbSeek(Work_SW8->WKADICAO))
      Do While !Work_EIN->(EOF()) .And. Work_EIN->EIN_ADICAO == Work_SW8->WKADICAO .And. Work_EIN->EIN_TIPO == "1"
         If Work_EIN->EIN_CODIGO $ cCodRatPeso
            nAcrecimo   -= Work_EIN->EIN_VLMMN
            nAcresFrete += Work_EIN->EIN_VLMMN
         EndIf
         Work_EIN->(DbSkip())
      EndDo
      RestOrd(aOrd_EIN)
   ENDIF

   Work_SW8->WKVLACRES:=DI500Trans(nAcrecimo*nRateio) + DI500Trans(nAcresFrete*(Work_SW8->WKPESOTOT/Work_EIJ->EIJ_PESOL))
   Work_SW8->WKVLDEDU :=DI500Trans(nDeducao *nRateio)

   nAcrecimo   += nAcresFrete
   nAcresFrete := 0

   Work_SW8->WKVLSEGMN:= oRateioRS:GetItemRateio(IF(AvRetInco(Work_EIJ->EIJ_INCOTE,"CONTEM_FRETE"),Work_SW8->WKFOBTOTR-Work_SW8->WKVLFREMN,Work_SW8->WKFOBTOTR))

   // EOB - 26/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
   IF AvRetInco(Work_EIJ->EIJ_INCOTE,"CONTEM_SEG")/*FDR - 27/12/10*/  //Work_EIJ->EIJ_INCOTE $ "CIF,CIP,DAF,DES,DEQ,DDP,DDU"//AWR - DDU
      nVLSEG:=DI500Trans(((Work_SW8->WKFOBTOTR-Work_SW8->WKVLFREMN)/nFOBRS)*DI500Block(cAlias,"EIJ_VSEGLE"))
      Work_SW8->WKVLMLE-=nVLSEG
   ENDIF

   IF !lMV_TXSIRAT//AWR -11/01/2005
      Work_SW8->WKTAXASIS:=DI500Trans(Work_EIJ->EIJ_TAXSIS*nRateio)
   ENDIF
   IF lAntDumpBaseICMS//AWR - 25/11/2004
      Work_SW8->WKANTIDUM:=DI500Trans(DI500Block(cAlias,"EIJ_VLR_DU")*nRateio)
   ENDIF

   //TDF - 05/10/12 - Cálculo da base com despesa base de ICMS rateada por peso
   If nBaseICMSPeso > 0
      nRatPeso:= nPesoItem/DI500Block(cAlias,"EIJ_PESOL")
      Work_SW8->WKBASEICM:=DI500Trans(nSomaItemBaseICMS*nRatPeso)+IF(lTxSisICMS ,Work_SW8->WKTAXASIS,0)+Work_SW8->WKANTIDUM
   Else
      Work_SW8->WKBASEICM:=DI500Trans(nSomaItemBaseICMS*nRateio)+IF(lTxSisICMS ,Work_SW8->WKTAXASIS,0)+Work_SW8->WKANTIDUM
   EndIf

   IF lDespBaseIcms
      WORK_SW8->WKD_BAICM := Work_SW8->WKBASEICM
   ENDIF

   aAcertos[1,1]+=Work_SW8->WKVLFREMN
   aAcertos[2,1]+=Work_SW8->WKVLSEGMN
   aAcertos[3,1]+=Work_SW8->WKVLACRES
   aAcertos[4,1]+=Work_SW8->WKVLDEDU
   aAcertos[5,1]+=Work_SW8->WKFOBTOTR
   aAcertos[6,1]+=Work_SW8->WKVLMLE
   aAcertos[7,1]+=Work_SW8->WKBASEICM
   aAcertos[8,1]+=Work_SW8->WKTAXASIS
   aAcertos[9,1]+=Work_SW8->WKANTIDUM//AWR - 25/11/2004

   IF AvRetInco(Work_SW8->WKINCOTER,"CONTEM_FRETE")/*FDR - 27/12/10*/  //Work_SW8->WKINCOTER $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDP,DDU"
      Work_SW8->WKVLFREMN:=0
      lAcerto:=.F.
   ENDIF
   // EOB - 26/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
   IF AvRetInco(Work_SW8->WKINCOTER,"CONTEM_SEG")/*FDR - 27/12/10*/  //Work_SW8->WKINCOTER $ "CIF,CIP,DAF,DES,DEQ,DDP,DDU"
      Work_SW8->WKVLSEGMN:=0
      lAcertoSeg:=.F.
   ENDIF

   IF Work_SW8->WKPRTOTMOE > nMaiorVlr
      nMaiorVlr:=Work_SW8->WKPRTOTMOE
      nRecVlr  :=Work_SW8->(RECNO())
   ENDIF
   IF Work_SW8->WKPESOTOT > nMaiorFre
      nMaiorFre:=Work_SW8->WKPESOTOT
      nRecFre  :=Work_SW8->(RECNO())
   ENDIF
   nContaItem++
   Work_SW8->WKSEQ_ADI:=STRZERO(nContaItem,3)

   //AAF 12/02/2007 - Rateio de quatidade específica da adição por quantidade do item.
   nQtdAdi += Work_SW8->WKQTDE

   Work_SW8->(DBSKIP())
ENDDO
IF nRecFre # 0
   Work_SW8->(DBGOTO(nRecFre))
   IF !EMPTY(aAcertos[1,1])   .AND.   DI500Block(cAlias,"EIJ_VFREMN") # aAcertos[1,1] .AND. lAcerto
      Work_SW8->WKVLFREMN+=DI500Trans(DI500Block(cAlias,"EIJ_VFREMN") - aAcertos[1,1])
   ENDIF
   IF !EMPTY(aAcertos[2,1])   .AND.   DI500Block(cAlias,"EIJ_VSEGMN") # aAcertos[2,1] .AND. lAcertoSeg
      Work_SW8->WKVLSEGMN+=DI500Trans(DI500Block(cAlias,"EIJ_VSEGMN") - aAcertos[2,1])
   ENDIF
ENDIF
IF nRecVlr # 0
   Work_SW8->(DBGOTO(nRecVlr))
   FOR A := 3 TO  LEN(aAcertos)
     IF !EMPTY(aAcertos[A,1]) .AND. aAcertos[A,2] # aAcertos[A,1]
        IF(A=3,Work_SW8->WKVLACRES += DI500Trans(aAcertos[A,2] - aAcertos[A,1]),)
        IF(A=4,Work_SW8->WKVLDEDU  += DI500Trans(aAcertos[A,2] - aAcertos[A,1]),)
        IF(A=5,Work_SW8->WKFOBTOTR += DI500Trans(aAcertos[A,2] - aAcertos[A,1]),)
        IF(A=6,Work_SW8->WKVLMLE   += DI500Trans(aAcertos[A,2] - aAcertos[A,1]),)
        IF(A=7,Work_SW8->WKBASEICM += DI500Trans(aAcertos[A,2] - aAcertos[A,1]),)
        IF lDespBaseIcms
           IF(A=7,Work_SW8->WKD_BAICM += DI500Trans(aAcertos[A,2] - aAcertos[A,1]),)
        ENDIF
        IF(A=8,Work_SW8->WKTAXASIS += DI500Trans(aAcertos[A,2] - aAcertos[A,1]),)
        IF lAntDumpBaseICMS//AWR - 25/11/2004
           IF(A=9,Work_SW8->WKANTIDUM += DI500Trans(aAcertos[A,2] - aAcertos[A,1]),)
        ENDIF
     ENDIF
   NEXT
ENDIF


nMaiorVlr:=0
aAcertos:={}
AADD(aAcertos,{0,DI500Block(cAlias,"EIJ_VLARII")})
AADD(aAcertos,{0,DI500Block(cAlias,"EIJ_VLAIPI")})
AADD(aAcertos,{0,0})

If lCpsICMSPt                                     //NCF - 11/05/2011
   AADD(aAcertos,{0,0})
EndIf

IF lAUTPCDI
   DI500Block(cAlias,"EIJ_BASPIS",0)
   DI500Block(cAlias,"EIJ_BR_PIS",0)
   DI500Block(cAlias,"EIJ_VLDPIS",0)
   DI500Block(cAlias,"EIJ_VLRPIS",0)
   DI500Block(cAlias,"EIJ_BASCOF",0)
   DI500Block(cAlias,"EIJ_BR_COF",0)
   DI500Block(cAlias,"EIJ_VLDCOF",0)
   DI500Block(cAlias,"EIJ_VLRCOF",0)
ENDIF

//If WORK_SW8->( FieldPos("WKQTDVOL") == 0 )   // Nopado por GFP - 27/02/2013
   nQtdeTot := 0
   aConvVal := DI500ConvQtdeRat(cAlias,@nQtdeTot)
//EndIf

WORK->(DBSETORDER(3))  // Bete - 08/09/04 - Tratamento IPI c/ aliq. especif.
SYD->(DBSETORDER(1))
SWZ->(DBSETORDER(2))
Work_SW9->(DBSETORDER(1))
Work_SW8->(DBSETORDER(4))
Work_SW8->(DBSEEK(cAdicao))

nCont:= EasyRecCount("Work_SW8")
ProcRegua(nCont)

DO WHILE Work_SW8->(!EOF()) .AND.;
         Work_SW8->WKADICAO == cAdicao

   IncProc(STR0266+Work_SW8->WKCOD_I) //"Calculando Impostos "

   IF EMPTY(Work_SW8->WKFLAGIV) .AND. EMPTY(Work_SW8->WKINVOICE)
      Work_SW8->(DBSKIP())
      LOOP
   ENDIF

   WORK->(DBSEEK(Work_SW8->WKPO_NUM+Work_SW8->WKPGI_NUM+Work_SW8->WKPOSICAO))  // Bete - 08/09/04 - Tratamento IPI c/ aliq. especif.

//   If WORK_SW8->( FieldPos("WKQTDVOL") > 0 )   // Nopado por GFP - 27/02/2013
//      nQtdRateio := WORK_SW8->WKQTDVOL*Work_SW8->WKQTDE
//   Else
      nPos1 := aScan(aConvVal, {|x| x[2] == Work_SW8->(RECNO()) })
      If nPos1 > 0
         nQtdRateio:= aConvVal[nPos1][1] * DI500Block(cAlias,"EIJ_QTUIPI") / nQtdeTot
      Endif
//   EndIf

   nAliqIPIUsada:=nAliqIIUsada:=nBaseII:=nVlDII:=nVlDIPI:=nPr_II:=0// Variaveis usada em Rdmake
   nBASE_PC:=0
   nVlrIPIEsp:=0  // Bete - 02/09/04 - Tratamento IPI c/ aliq. especifica
   Work_SW8->WKVLII :=DI500IICalc(cAlias,Work_SW8->WKFOBTOTR,Work_SW8->WKVLFREMN,;
                                         Work_SW8->WKVLSEGMN,Work_SW8->WKINCOTER,;
                                         Work_SW8->WKVLACRES,Work_SW8->WKVLDEDU ,;
                                         @nBaseII,.F.,@nVlDII)
   Work_SW8->WKVLDEVII:=nVlDII
   Work_SW8->WKBASEII :=nBaseII//+(nSomaItemNoCIF*nRateio)//Em Analise AWR
   Work_SW8->WKVLIPI  :=DI500IPICalc(cAlias,Work_SW8->WKBASEII,Work_SW8->WKVLII,.F.,nVlDII,@nVlDIPI,,, Work_SW8->WKCOD_I, nQtdRateio, Work->WKIPIPAUTA )
   Work_SW8->WKVLDEIPI:=nVlDIPI

   nAliqICMS :=0 // Variavel usada em Rdmake
   nRedICMS  :=1 // Variavel usada em Rdmake
   nWZ_ICMSPC:=0 // Variavel usada em Rdmake
   nAlICMFECP:=0
   nAlDifFECP:=0
   SWZ->(DBSETORDER(2))
   IF SWZ->(DbSeek(cFilSWZ+Work_SW8->WKOPERACA))
/* Quando existir aliquota de carga tributaria equivalente esta sera usada para o calculo da base de pis e cofins*/
      IF EMPTY(SWZ->WZ_RED_CTE)
         nAliqICMS:= SWZ->WZ_AL_ICMS
      ELSE
         nAliqICMS:= SWZ->WZ_RED_CTE
      ENDIF
      IF SWZ->(FIELDPOS("WZ_ICMS_PC")) # 0
         nWZ_ICMSPC:=(SWZ->WZ_ICMS_PC/100)
      ENDIF
      nRedICMS := IF(SWZ->WZ_RED_ICM#0,(100-SWZ->WZ_RED_ICM)/100,1)

      // TRP - 18/02/2010
      IF lICMS_Dif .AND. ASCAN( aICMS_Dif, {|x| x[1] == Work_SW8->WKOPERACA} ) == 0
      //                   Operação            Suspensao        % diferimento    % Credito presumido                 % Limite Cred.   % pg desembaraco   Aliq. do ICMS    Aliq. ICMS S/ PIS
         AADD( aICMS_Dif, {Work_SW8->WKOPERACA, SWZ->WZ_ICMSUSP, SWZ->WZ_ICMSDIF, IF( lICMS_Dif2, SWZ->WZ_PCREPRE, 0), SWZ->WZ_ICMS_CP, SWZ->WZ_ICMS_PD, SWZ->WZ_AL_ICMS, SWZ->WZ_ICMS_PC } )
      ENDIF

      If AvFlags("ICMSFECP_DI_ELETRONICA")
         nAlICMFECP := SWZ->WZ_ALFECP
      EndIf
      If AvFlags("FECP_DIFERIMENTO")
         nAlDifFECP := SWZ->WZ_ICMSDIF
      EndIf

   ELSEIF SYD->(DbSeek(cFilSYD+Work_SW8->WKTEC+Work_SW8->WKEX_NCM+Work_SW8->WKEX_NBM))
      nAliqICMS:= SYD->YD_ICMS_RE
      IF SYD->(FIELDPOS("YD_ICMS_PC")) # 0                                            //NCF - 10/06/2011 - Aliq. De ICMS para PIS/COFINS na N.c.m
         nWZ_ICMSPC := (SYD->YD_ICMS_PC/100)
      ENDIF
   ENDIF

   nBaseICMS:=0
   IF lMV_PIS_EIC
      nQtde:=Work_SW8->WKQTDE // ldr - OC - 0048/04 - OS - 0989/04
      IF lVlUnid .AND. !EMPTY(Work_SW8->WKQTDE_UM) // LDR - OC - 0048/04 - OS - 0989/04
         nQtde:=Work_SW8->WKQTDE_UM
      ENDIF

      /* JONATO 04/FEV/2005. A utilização da variável nAUX_II é necessária para os casos
      em que houver redução de base de calculo, porque nesses casos as planilhas de calculo
      da Receita, reduzem a aliquota, e não a base. Também criei a variável apenas aqui para
      não ter que mexer com o tratamento dentro da função de calculo do impostos */
      nAUX_II:= nAliqIIUsada
      If DI500Block(cAlias,"EIJ_REGTRI") == '4' .and. ;
         DI500Block(cAlias,"EIJ_PR_II") <> 0    .and. ;
         EMPTY(DI500Block(cAlias,"EIJ_ALR_II"))
         nAUX_II:= nAliqIIUsada - ( nAliqIIUsada * (DI500Block(cAlias,"EIJ_PR_II")/100) )
      ElseIf DI500Block(cAlias,"EIJ_REGTRI") $ '2,3,6'  // Bete - 06/05/06 - P/ IMUNIDADE, ISENCAO ou NAO-INCIDENCIA
         nAUX_II:=0                                     // de II, a aliquota é zero p/ o cálculo do PIS/COFINS
      Endif
      nAux_IPI:=nAliqIPIUsada                         // Jonato em 28/09/2005. Segundo a MP252, para ISENÇÃO
      IF DI500Block(cAlias,"EIJ_REGIPI") $ '1,3'      // E IMUNIDADE de IPI, a aliquota é zero para calculo
         nAUX_IPI:=0                                  // de PIS
      ELSEIF DI500Block(cAlias,"EIJ_REGIPI") $ '4,5' .AND. DI500Block(cAlias,"EIJ_TPAIPI") = '2'
         IF nVlrIPIEsp == 0
            nVlrIPIEsp := DI500Trans(DI500Block(cAlias,"EIJ_QTUIPI")*DI500Block(cAlias,"EIJ_ALUIPI"))
         ENDIF
      ELSEIF DI500Block(cAlias,"EIJ_REGIPI") $ '5' //JAP - Zera o cálculo do IPI em caso de suspensão e o ato do IPI for = LEI
         cNroipi := EasyGParam("MV_ZIPIPIS",,"")
         cEijipi := DI500Block(cAlias,"EIJ_NROIPI")
         cNroipi := Alltrim(STRTRAN(cNroipi, ".",""))
         cEijipi := Alltrim(STRTRAN(cEijipi, ".",""))
         IF !Empty(cNroipi) .AND. cEijipi $ cNroipi .AND. ALLTRIM(DI500Block(cAlias,"EIJ_ATOIPI")) == 'LEI'
            nAUX_IPI := 0
         ENDIF
      ELSEIF DI500Block(cAlias,"EIJ_REGIPI") $ '2'
         nAUX_IPI:=DI500Block(cAlias,"EIJ_ALRIPI")  // Bete - 06/05/06 - P/ REDUCAO, considerar a aliq. reduzida
      ENDIF                                         // p/ o calculo do PIS/COFINS

      SYD->(DbSeek(cFilSYD+Work_SW8->WKTEC+Work_SW8->WKEX_NCM+Work_SW8->WKEX_NBM))


      IF !lAUTPCDI
         nRedPis:=SYD->YD_RED_PIS
         nRedCof:=SYD->YD_RED_COF
         nAliPis:=Work_SW8->WKPERPIS
         nAliCof:=Work_SW8->WKPERCOF
         nAluPis:=Work_SW8->WKVLUPIS
         nAluCof:=Work_SW8->WKVLUCOF

         If lCposCofMj                                                                             //NCF - 20/07/2012 - Majoração COFINS
            nAliCofMaj:=EicGetPerMaj( Work_SW8->WKTEC+Work_SW8->WKEX_NCM+Work_SW8->WKEX_NBM , Work_SW8->WKOPERACA ,SYT->YT_COD_IMP, "COFINS")
         EndIf
         If lCposPisMj                                                                             //GFP - 11/06/2013 - Majoração PIS
            nAliPisMaj:=EicGetPerMaj( Work_SW8->WKTEC+Work_SW8->WKEX_NCM+Work_SW8->WKEX_NBM , Work_SW8->WKOPERACA ,SYT->YT_COD_IMP, "PIS")
         EndIf

      ELSE
         nRedPis := DI500Block(cAlias,"EIJ_PRB_PC")
         nRedCof := DI500Block(cAlias,"EIJ_PRB_PC")
         nAliPis := DI500Block(cAlias,"EIJ_ALAPIS")
         nAliCof := DI500Block(cAlias,"EIJ_ALACOF")
         nAluPis := DI500Block(cAlias,"EIJ_ALUPIS")
         nAluCof := DI500Block(cAlias,"EIJ_ALUCOF")

         If lCposCofMj                                                             //NCF - 20/07/2012 - Majoração COFINS
            If Empty(DI500Block(cAlias,"EIJ_ALCOFM"))
               nAliCofMaj := EicGetPerMaj( Work_SW8->WKTEC+Work_SW8->WKEX_NCM+Work_SW8->WKEX_NBM , Work_SW8->WKOPERACA ,SYT->YT_COD_IMP, "COFINS")
            Else
               nAliCofMaj := (DI500Block(cAlias,"EIJ_ALCOFM"))
            EndIf
         EndIf
         If lCposPisMj                                                             //GFP - 11/06/2013 - Majoração PIS
            If Empty(DI500Block(cAlias,"EIJ_ALPISM"))
               nAliPisMaj := EicGetPerMaj( Work_SW8->WKTEC+Work_SW8->WKEX_NCM+Work_SW8->WKEX_NBM , Work_SW8->WKOPERACA ,SYT->YT_COD_IMP, "PIS")
            Else
               nAliPisMaj := (DI500Block(cAlias,"EIJ_ALPISM"))
            EndIf
         EndIf

         IF DI500Block(cAlias,"EIJ_REG_PC") = "4" //AWR - 17/06/2009 - Correcao: o SISCOMEX considera o Aliq. Reduzida para calcular a Base PIS/COFINS
            IF EIJ->(FieldPos("EIJ_ARDPIS")) # 0
               IF DI500Block(cAlias,"EIJ_ARDPIS") $ cSim  //TRP - 22/02/2010
                  nAliPis := DI500Block(cAlias,"EIJ_REDPIS")
               ENDIF
            ELSE
               IF !EMPTY(DI500Block(cAlias,"EIJ_REDPIS"))
                  nAliPis := DI500Block(cAlias,"EIJ_REDPIS")
               ENDIF
            ENDIF

            IF EIJ->(FieldPos("EIJ_ARDCOF")) # 0
               IF DI500Block(cAlias,"EIJ_ARDCOF") $ cSim  //TRP - 22/02/2010
                  nAliCof := DI500Block(cAlias,"EIJ_REDCOF")
               ENDIF
            ELSE
               IF !EMPTY(DI500Block(cAlias,"EIJ_REDCOF"))
                  nAliCof := DI500Block(cAlias,"EIJ_REDCOF")
               ENDIF
            ENDIF
         ENDIF
      ENDIF
      IF !EMPTY(nAluPis) .OR. (lAUTPCDI .AND. DI500Block(cAlias,"EIJ_TPAPIS") == "2")
         Work_SW8->WKBASPIS:= 0

         //** AAF 12/02/2007 - Rateio de quatidade específica da adição por quantidade do item.
         Work_SW8->WKVLRPIS:= nAluPis * IIF(lAUTPCDI,DI500Block(cAlias,"EIJ_QTUPIS"),nQtde) * Work_SW8->WKQTDE / nQtdAdi

         IF lAUTPCDI
         	Work_SW8->WKVLUPIS  := nAluPis
            Work_SW8->WKPERPIS  := 0  // Zera aliquota ad. valorem por estar tratando como especifica
            Work_SW8->WKVLDEPIS := Work_SW8->WKVLRPIS
            IF DI500Block(cAlias,"EIJ_REG_PC") <> "1"
               Work_SW8->WKVLRPIS := 0
            ENDIF
            nEIJ_VLDPIS+= Work_SW8->WKVLDEPIS
            nEIJ_VLRPIS+= Work_SW8->WKVLRPIS
         ENDIF
      ELSE
         //** AAF 14/09/07 - Considerar rateio do IPI Específico para calculo da base de PIS/COFINS
         If nVlrIPIEsp > 0
            Work_SW8->WKBASPIS:= DI500PISCalc(nBaseII,Work_SW8->WKBASEICM,(nAUX_II/100),(nAUX_IPI/100),(nAliqICMS/100),(nAliPis/100),(nAliCof/100),(nRedPis/100),nWZ_ICMSPC, Work_SW8->WKVLIPI,"PISCALC_DI",@nBASE_PC,.T.)//JVR - 20/05/10 - Acerto de acordo com SISCOMEX
            //Work_SW8->WKBASPIS:= DI500PISCalc(nBaseII,Work_SW8->WKBASEICM,(nAUX_II/100),(nAUX_IPI/100),(nAliqICMS/100),(nAliPis/100),(nAliIntCof/100),(nRedPis/100),nWZ_ICMSPC, Work_SW8->WKVLIPI,"PISCALC_DI",@nBASE_PC,.T.) //RJB //TRP - 23/02/2010
         Else
            Work_SW8->WKBASPIS:= DI500PISCalc(nBaseII,Work_SW8->WKBASEICM,(nAUX_II/100),(nAUX_IPI/100),(nAliqICMS/100),(nAliPis/100),(nAliCof/100),(nRedPis/100),nWZ_ICMSPC, 0,"PISCALC_DI",@nBASE_PC)//JVR - 20/05/10 - Acerto de acordo com SISCOMEX
            //Work_SW8->WKBASPIS:= DI500PISCalc(nBaseII,Work_SW8->WKBASEICM,(nAUX_II/100),(nAUX_IPI/100),(nAliqICMS/100),(nAliPis/100),(nAliIntCof/100),(nRedPis/100),nWZ_ICMSPC, 0,"PISCALC_DI",@nBASE_PC) //RJB //TRP - 23/02/2010
         EndIf            
         Work_SW8->WKVLRPIS:= Work_SW8->WKBASPIS * (nAliPis/100)
         
         //FDR - 26/01/17
         If lCposPisMj                                                                             //GFP - 11/06/2013 - Majoração PIS
            Work_SW8->WKVLRPIS:= Work_SW8->WKBASPIS * ((nAliPis)/100)
            Work_SW8->WKVLPISM:= Work_SW8->WKBASPIS * ( nAliPisMaj/100)
         EndIf
                  
         IF lAUTPCDI 
            Work_SW8->WKPERPIS  := IF(DI500Block(cAlias,"EIJ_REG_PC") $ "2,6", 0, nAliPis)
         	Work_SW8->WKVLUPIS  := 0  // Zera aliquota especifica por estar tratando como ad. valorem
            Work_SW8->WKVLDEPIS := IF(DI500Block(cAlias,"EIJ_REG_PC") $ "6", 0, Work_SW8->WKVLRPIS) //TDF - 11/11/11 - Regime tipo '6' não incidencia
            IF DI500Block(cAlias,"EIJ_REG_PC") = "4"
               IF EIJ->(FieldPos("EIJ_ARDPIS")) # 0
                  IF DI500Block(cAlias,"EIJ_ARDPIS") $ cSim //TRP - 22/02/2010 //!EMPTY(DI500Block(cAlias,"EIJ_REDPIS")) //AAF 11/09/2008 - Conforme Siscomex
                     Work_SW8->WKPERPIS:=DI500Block(cAlias,"EIJ_REDPIS")
                     Work_SW8->WKVLRPIS:= Work_SW8->WKBASPIS * (Work_SW8->WKPERPIS/100)
                  ENDIF
               ELSE
                  IF !EMPTY(DI500Block(cAlias,"EIJ_REDPIS"))
                     Work_SW8->WKPERPIS:=DI500Block(cAlias,"EIJ_REDPIS")
                     Work_SW8->WKVLRPIS:= Work_SW8->WKBASPIS * (Work_SW8->WKPERPIS/100)
                  ENDIF
               ENDIF
            ENDIF

            IF DI500Block(cAlias,"EIJ_REG_PC") $ "2,3,5,6"
               Work_SW8-> WKVLRPIS := 0
            ENDIF
            nEIJ_BASPIS+=nBASE_PC
            IF DI500Trans(Work_SW8->WKBASPIS) < DI500Trans(nBASE_PC)
               nEIJ_BR_PIS+=Work_SW8->WKBASPIS
            ENDIF
            nEIJ_VLDPIS+= Work_SW8->WKVLDEPIS
            nEIJ_VLRPIS+=Work_SW8->WKVLRPIS
         ENDIF
      ENDIF
      IF !EMPTY(nAluCof) .OR. (lAUTPCDI .AND. DI500Block(cAlias,"EIJ_TPACOF") == "2")
         Work_SW8->WKBASCOF:= 0
         Work_SW8->WKVLRCOF:= nAluCof * IIF(lAUTPCDI,DI500Block(cAlias,"EIJ_QTUCOF"),nQtde) // ldr - OC - 0048/04 - OS - 0989/04

         //** AAF 12/02/2007 - Rateio de quatidade específica da adição por quantidade do item.
         Work_SW8->WKVLRCOF:= nAluCof * IIF(lAUTPCDI,DI500Block(cAlias,"EIJ_QTUCOF"),nQtde) * Work_SW8->WKQTDE / nQtdAdi

         IF lAUTPCDI
            Work_SW8->WKVLUCOF  := nAluCof
            Work_SW8->WKPERCOF  := 0  // Zera aliquota ad. valorem por estar tratando como especifica
            Work_SW8->WKVLDECOF := Work_SW8->WKVLRCOF
            IF DI500Block(cAlias,"EIJ_REG_PC") <> "1"
               Work_SW8->WKVLRCOF := 0
            ENDIF
            nEIJ_VLDCOF += Work_SW8->WKVLDECOF
            nEIJ_VLRCOF += Work_SW8->WKVLRCOF
         ENDIF
      ELSE
         // Alterado para DEICMAR -> nAux_IPI é zero para calculo de COFINS MP 252 para REGIME SUSPENSAO, ISENÇAO E IMUNIDADE DE IPI - RS 05/10
         //** AAF 14/09/07 - Considerar rateio do IPI Específico para calculo da base de PIS/COFINS
         If nVlrIPIEsp > 0
            Work_SW8->WKBASCOF:= DI500PISCalc(nBaseII,Work_SW8->WKBASEICM,(nAUX_II/100),(nAux_IPI/100),(nAliqICMS/100),(nAliPis/100),(nAliCof/100),(nRedCof/100),nWZ_ICMSPC, Work_SW8->WKVLIPI,"PISCALC_DI",@nBASE_PC,.T.)//JVR - 20/05/10 - Acerto de acordo com SISCOMEX
            //Work_SW8->WKBASCOF:= DI500PISCalc(nBaseII,Work_SW8->WKBASEICM,(nAUX_II/100),(nAux_IPI/100),(nAliqICMS/100),(nAliIntPis/100),(nAliCof/100),(nRedCof/100),nWZ_ICMSPC, Work_SW8->WKVLIPI,"PISCALC_DI",@nBASE_PC,.T.)  //TRP - 23/02/2010
         Else
            Work_SW8->WKBASCOF:=  DI500PISCalc(nBaseII,Work_SW8->WKBASEICM,(nAUX_II/100),(nAux_IPI/100),(nAliqICMS/100),(nAliPis/100),(nAliCof/100),(nRedCof/100),nWZ_ICMSPC, 0,"PISCALC_DI",@nBASE_PC)//JVR - 20/05/10 - Acerto de acordo com SISCOMEX
            //Work_SW8->WKBASCOF:= DI500PISCalc(nBaseII,Work_SW8->WKBASEICM,(nAUX_II/100),(nAux_IPI/100),(nAliqICMS/100),(nAliIntPis/100),(nAliCof/100),(nRedCof/100),nWZ_ICMSPC, 0,"PISCALC_DI",@nBASE_PC) //RJB //TRP - 23/02/2010
         Endif
         Work_SW8->WKVLRCOF:= Work_SW8->WKBASCOF * (nAliCof/100)

         If lCposCofMj                                                                             //NCF - 20/07/2012 - Majoração COFINS
            Work_SW8->WKVLRCOF:= Work_SW8->WKBASCOF * ((nAliCof)/100)
            Work_SW8->WKVLCOFM:= Work_SW8->WKBASCOF * ( nAliCofMaj/100)
         EndIf
         
         IF lAUTPCDI 
            Work_SW8->WKPERCOF  := IF(DI500Block(cAlias,"EIJ_REG_PC") $ "2,6", 0, nAliCof)
         	Work_SW8->WKVLUCOF  := 0  // Zera aliquota especifica por estar tratando como ad. valorem
            Work_SW8->WKVLDECOF := IF(DI500Block(cAlias,"EIJ_REG_PC") $ "6", 0, Work_SW8->WKVLRCOF)//TDF - 11/11/11 - Regime tipo '6' não incidencia
            IF DI500Block(cAlias,"EIJ_REG_PC") = "4"
               IF EIJ->(FieldPos("EIJ_ARDCOF")) # 0
                  IF DI500Block(cAlias,"EIJ_ARDCOF") $ cSim //TRP - 22/02/2010 //!EMPTY(DI500Block(cAlias,"EIJ_REDCOF")) //AAF 11/09/2008 - Conforme Siscomex
                     Work_SW8->WKPERCOF:=DI500Block(cAlias,"EIJ_REDCOF")
                     Work_SW8->WKVLRCOF:= Work_SW8->WKBASCOF * (Work_SW8->WKPERCOF/100)
                  ENDIF
               ELSE
                  IF !EMPTY(DI500Block(cAlias,"EIJ_REDCOF"))
                     Work_SW8->WKPERCOF:=DI500Block(cAlias,"EIJ_REDCOF")
                     Work_SW8->WKVLRCOF:= Work_SW8->WKBASCOF * (Work_SW8->WKPERCOF/100)
                  ENDIF
               ENDIF
            ENDIF

            IF DI500Block(cAlias,"EIJ_REG_PC") $ "2,3,5,6"
               Work_SW8-> WKVLRCOF := 0
            ENDIF
            nEIJ_BASCOF += nBASE_PC
            IF DI500Trans(Work_SW8->WKBASCOF) < DI500Trans(nBASE_PC)
               nEIJ_BR_COF += Work_SW8->WKBASCOF
            ENDIF
            nEIJ_VLDCOF += Work_SW8->WKVLDECOF
            nEIJ_VLRCOF += Work_SW8->WKVLRCOF
         ENDIF
      ENDIF
   ENDIF
   /*Para o calculo do ICMS e sempre utilizada a aliquota normal    // LDR */
   IF SWZ->(!EOF())
      nAliqICMS:= SWZ->WZ_AL_ICMS
      If AvFlags("ICMSFECP_DI_ELETRONICA")
         nAlICMFECP := SWZ->WZ_ALFECP
      EndIf
      If AvFlags("FECP_DIFERIMENTO")
         nAlDifFECP := SWZ->WZ_ICMSDIF
      EndIf
   ENDIF

   SB1->(dbSeek(cFilSB1+Work_SW8->WKCOD_I))
   IF lExiste_Midia .AND. lPesoMid .AND. SB1->B1_MIDIA $ cSIM .AND. lICMSMidiaDupl//AWR  - 28/06/2006

      //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
      Work_SW9->(DBSEEK(Work_SW8->WKINVOICE+WORK_SW8->WKFORN+Work_SW8->W8_FORLOJ+M->W6_HAWB))
      Work_SW8->WKBASEICM:=DI500Trans((Work_SW8->WKVL_TOTM * Work_SW9->W9_TX_FOB * 2) ,2)

   ELSEIF lExiste_Midia .AND. lPesoMid .AND. SB1->B1_MIDIA $ cSIM .AND. !EMPTY(nVlICMS)//AWR  - 28/06/2006

      Work_SW8->WKBASEICM+=DI500Trans((Work_SW8->WKQTMIDIA * WORK_SW8->WKQTDE * nVlICMS),2)

   ELSEIF lMV_PIS_EIC .AND. lMV_ICMSPIS
      //Work_SW8->WKBASEICM:=DI500ICMSCalc(,nRedICMS,nAliqICMS,nBaseII,Work_SW8->WKBASEICM,nBaseICMS,Work_SW8->WKVLII,Work_SW8->WKVLIPI,Work_SW8->WKVLRPIS,Work_SW8->WKVLRCOF,(nWZ_ICMSPC*100),"ICMSCALC_DI") //RJB 07/06/2004
      //TRP - 18/02/2010
      //RMD - 04/10/17 - Confirma a utilização do PIS e COFINS devido para os casos de suspensão utilizando o campo WZ_PC_ICMS
      lPisCofDev := .F.
      If SWZ->(FieldPos("WZ_PC_ICMS")) > 0
         lPisCofDev := SWZ->WZ_PC_ICMS == "1"
      EndIf
      Work_SW8->WKBASEICM:=DI154CalcICMS(,nRedICMS,If(nAliqICMS<>0,nAliqICMS,nWZ_ICMSPC),SWZ->WZ_RED_CTE,nBaseII,Work_SW8->WKBASEICM,nBaseICMS,Work_SW8->WKVLII,Work_SW8->WKVLIPI,.T., if(DI500Block(cAlias,"EIJ_REG_PC")=="5" .And. lPisCofDev,Work_SW8->WKVLDEPIS,Work_SW8->WKVLRPIS),if(DI500Block(cAlias,"EIJ_REG_PC")=="5" .And. lPisCofDev,Work_SW8->WKVLDECOF,Work_SW8->WKVLRCOF),Work_SW8->WKOPERACA)
   ELSE
      Work_SW8->WKBASEICM+=DI500Trans((nBaseII+Work_SW8->WKVLII+Work_SW8->WKVLIPI))
      //Work_SW8->WKBASEICM:=DI500ICMSCalc( Work_SW8->WKBASEICM, nRedICMS, nAliqICMS )
      //TRP - 18/02/2010
      Work_SW8->WKBASEICM:=DI154CalcICMS(Work_SW8->WKBASEICM, nRedICMS, nAliqICMS)
   ENDIF
   //SVG - 05/04/2010 - Não grava o valor do ICMS caso seja Drawback Suspensão e não seja Intermediário.
   IF TYPE("aICMS_DIF")=="A" .AND. VALTYPE(Work_SW8->WKOPERACA)=="C" .AND. LEN(aICMS_DIF) > 0 .AND. (nP:=ASCAN( aICMS_Dif, {|x| x[1] == Work_SW8->WKOPERACA} )) > 0;
                             .AND. !( SWZ->(FieldPos("WZ_TPPICMS")) > 0 .And. (SWZ->WZ_TPPICMS $ "1/2" ) )
      cSuspensao := aICMS_Dif[nP,2]
      If cSuspensao $ cSim
         Work_SW8->WKVLICMS:= 0
         If AvFlags("ICMSFECP_DI_ELETRONICA")
            Work_SW8->WKVLFECP := 0
         EndIf
         If AvFlags("FECP_DIFERIMENTO")
            Work_SW8->WKFECPVLD := 0
            Work_SW8->WKFECPREC := 0
         EndIf
      Else
         //Work_SW8->WKVLICMS:= DI500Trans(Work_SW8->WKBASEICM * (nAliqICMS/100) )  //TRP - 19/04/10
         Work_SW8->WKVLICMS:= nVal_ICM
         If AvFlags("ICMSFECP_DI_ELETRONICA")
            Work_SW8->WKVLFECP := DITrans(Work_SW8->WKBASEICM*(nAlICMFECP/100),2)
            Work_SW8->WKALFECP := nAlICMFECP
         EndIf
         If AvFlags("FECP_DIFERIMENTO")
            Work_SW8->WKFECPALD := nAlDifFECP
            Work_SW8->WKFECPVLD := DITrans(Work_SW8->WKVLFECP * (nAlDifFECP/100),2)
            Work_SW8->WKFECPREC := DITrans(Work_SW8->WKVLFECP - Work_SW8->WKFECPVLD,2)
         EndIf
      EndIf

   ElseIf lCpsICMSPt
      //NCF - 11/05/2011 - Tratamentos de ICMS de Pauta
      aOrdSWZ := SaveOrd({"SWZ"})
      SWZ->(DbSetOrder(2))
      SWZ->(DbSeek(xFilial("SWZ")+Work_SW8->WKOPERACA))
      If cMV_CALCICM == "1"
         If !Empty(SB1->B1_VLR_ICM) .And. (!lIntDraw .OR. DI500DrawICMS())
            If !EMPTY(SWZ->WZ_TPPICMS) .And. SWZ->WZ_TPPICMS # "3"
               Work_SW8->WKVLICMDV := DI500Trans(Work_SW8->WKBASEICM * (nAliqICMS/100) )  //NCF - 11/05/2011 - Recupera o valor do ICMS Devido
               If SWZ->WZ_TPPICMS == "1"
                  Work_SW8->WKVLICMS := DITrans(Work_SW8->WKPESOTOT*SB1->B1_VLR_ICM,2)    //NCF - 11/05/2011 - Pauta por Peso
               ElseIf SWZ->WZ_TPPICMS == "2"
                  Work_SW8->WKVLICMS := DITrans(Work_SW8->WKQTDE*SB1->B1_VLR_ICM,2)       //NCF - 11/05/2011 - Pauta por Quantidade
               EndIf
            Else                                                                          //NCF - 15/06/2011 - Ajustes em caso de não utilização do ICMS de Pauta
               Work_SW8->WKVLICMS:= DI500Trans(Work_SW8->WKBASEICM * (nAliqICMS/100) )
            EndIf
         Else
            If !lIntDraw .OR. DI500DrawICMS()
              Work_SW8->WKVLICMS:= DI500Trans(Work_SW8->WKBASEICM * (nAliqICMS/100) )
            EndIf
         EndIf
      ElseIf cMV_CALCICM == "3"
         If !Empty(SB1->B1_VLR_ICM) .And. (!lIntDraw .OR. DI500DrawICMS())
            If !EMPTY(SWZ->WZ_TPPICMS) .And. SWZ->WZ_TPPICMS # "3"
               Work_SW8->WKVLICMDV := DI500Trans(Work_SW8->WKBASEICM * (nAliqICMS/100) )                                                    //NCF - 11/05/2011 - Recupera o valor do ICMS Devido
               If SWZ->WZ_TPPICMS == "1"
                  Work_SW8->WKVLICMS := DITrans(Work_SW8->WKPESOTOT * SB1->B1_VLR_ICM,2) + DITrans( ( nBase * (SWZ->WZ_AL_ICMS/100) ), 2 )  //NCF - 11/05/2011 - Pauta por Peso
               ElseIf SWZ->WZ_TPPICMS == "2"
                  Work_SW8->WKVLICMS := DITrans(Work_SW8->WKQTDE * SB1->B1_VLR_ICM,2) + DITrans( ( nBase * (SWZ->WZ_AL_ICMS/100) ), 2 )     //NCF - 11/05/2011 - Pauta por Quantidade
               EndIf
            Else
               Work_SW8->WKVLICMS:= DI500Trans(Work_SW8->WKBASEICM * (nAliqICMS/100) )
            EndIf
         Else                                                                                                                               //NCF - 15/06/2011 - Ajustes em caso de não utilização do ICMS de Pauta
            If !lIntDraw .OR. DI500DrawICMS()
              Work_SW8->WKVLICMS:= DI500Trans(Work_SW8->WKBASEICM * (nAliqICMS/100) )
            EndIf
         EndIf
      EndIf
      RestOrd(aOrdSWZ)
   ElseIf !lIntDraw .OR. DI500DrawICMS()
      Work_SW8->WKVLICMS:= DI500Trans(Work_SW8->WKBASEICM * (nAliqICMS/100) )
      If AvFlags("ICMSFECP_DI_ELETRONICA")
         Work_SW8->WKVLFECP := DITrans(Work_SW8->WKBASEICM*(nAlICMFECP/100),2)
         Work_SW8->WKALFECP := nAlICMFECP
      EndIf
      If AvFlags("FECP_DIFERiMENTO")
         Work_SW8->WKFECPALD := nAlDifFECP
         Work_SW8->WKFECPVLD := DITrans(Work_SW8->WKVLFECP * (nAlDifFECP/100),2)
         Work_SW8->WKFECPREC := DITrans(Work_SW8->WKVLFECP - Work_SW8->WKFECPVLD,2)
      EndIf
   EndIf

   aAcertos[1,1]+=Work_SW8->WKVLII
   aAcertos[2,1]+=Work_SW8->WKVLIPI
   aAcertos[3,1]+=Work_SW8->WKVLICMS
   IF lCpsICMSPt
      aAcertos[4,1]+=Work_SW8->WKVLICMDV
   ENDIF

   IF Work_SW8->WKPRTOTMOE > nMaiorVlr
      nMaiorVlr:=Work_SW8->WKPRTOTMOE
      nRecVlr  :=Work_SW8->(RECNO())
   ENDIF


   SWZ->(DBSETORDER(2))
   IF SWZ->(DbSeek(cFilSWZ+Work_SW8->WKOPERACA))
   //TRP/NCF - Cálculo Diferimento

      nRedICMS := IF(SWZ->WZ_RED_ICM#0,(100-SWZ->WZ_RED_ICM)/100,1)

      SYB->(DBSETORDER(1))
      SWD->(DBSETORDER(1))
      SWD->(DbSeek(xFilial()+SW6->W6_HAWB))

      SYT->(DBSETORDER(1))
      SYT->(dBSeek(xFilial("SYT")+SW6->W6_IMPORT))
      cCpoBasICMS:="YB_ICM_"+Alltrim(SYT->YT_ESTADO)
      lTemYB_ICM_UF:=SYB->(FIELDPOS(cCpoBasICMS)) # 0
      
      /* /* //NCF-13/09/2017 - Valor já está no campo WORK_SW8->WKD_BAICM  
      nDBICMS:= 0

      DO WHILE xFilial('SWD') == SWD->WD_FILIAL .AND.;
         SWD->WD_HAWB   == SW6->W6_HAWB .AND.;
         !SWD->(EOF()) .AND. lTemAdicao
         IF SYB->(DBSEEK(xFilial()+SWD->WD_DESPESA)) .AND. !SWD->( LEFT(SWD->WD_DESPESA,1) ) $ "1,2,9" ;
              .AND. SWD->WD_DESPESA <> cMV_CODTXSI
            lBaseICM:=SYB->YB_BASEICM $ cSim
            IF lTemYB_ICM_UF
               lBaseICM:=lBaseICM .AND. SYB->(FIELDGET(FIELDPOS(cCpoBasICMS))) $ cSim
            ENDIF
            IF lBaseICM
               nDBICMS+=SWD->WD_VALOR_R
            ENDIF
         ENDIF
         SWD->(DBSKIP())
      ENDDO          
      */
         
      nBase:= (Work_SW8->WKFOBTOTR + Work_SW8->WKVLFREMN + Work_SW8->WKVLSEGMN + Work_SW8->WKVLACRES - Work_SW8->WKVLDEDU) + Work_SW8->WKVLII + Work_SW8->WKVLIPI + /*nDBICMS*/ WORK_SW8->WKD_BAICM /*+ Work_SW8->WKTAXASIS*/ + If(lAUTPCDI,Work_SW8->WKVLDEPIS,Work_SW8->WKVLRPIS) +  If(lAUTPCDI,Work_SW8->WKVLDECOF,Work_SW8->WKVLRCOF) //TRP - 24/10/2012
      
      IF !EMPTY(SWZ->WZ_RED_CTE) .AND. nRedICMS == 1
         nBaseNew:= ( nBase / ( (100 -  SWZ->WZ_RED_CTE) /100 ) )
         nBase := DITrans( nBaseNew * ( SWZ->WZ_RED_CTE/SWZ->WZ_AL_ICMS ) ,2)
      ELSE
         nBase := DITrans( ( (nBase*nRedICMS) / ( (100 - SWZ->WZ_AL_ICMS ) /100 ) ) ,2)
      ENDIF

      nVal_ICM := DITrans( ( nBase * (SWZ->WZ_AL_ICMS/100) ), 2 )
      nVal_ICMDV := DITrans( ( nBase * (SWZ->WZ_AL_ICMS/100) ), 2 )
      If AvFlags("ICMSFECP_DI_ELETRONICA")
         nAlICMFECP := SWZ->WZ_ALFECP
      EndIf
      If AvFlags("FECP_DIFERIMENTO")
         nAlDifFECP := SWZ->WZ_ICMSDIF
      EndIf

      //Tratamentos de Suspensão, Diferimento e Credito Presumido de ICMS com DI Eletronica
	  IF TYPE("aICMS_DIF")=="A" .AND. VALTYPE(Work_SW8->WKOPERACA)=="C" .AND. LEN(aICMS_DIF) > 0 .AND. (nP:=ASCAN( aICMS_Dif, {|x| x[1] == Work_SW8->WKOPERACA} )) > 0;
                                .AND. !( SWZ->(FieldPos("WZ_TPPICMS")) > 0 .And. (SWZ->WZ_TPPICMS $ "1/2" ) )
         IF aICMS_Dif[nP,3] > 0 //.AND. IF(EasyGParam("MV_AICMDIF",,0) > 0, SWZ->WZ_AL_ICMS == EasyGParam("MV_AICMDIF",,0), .T.)  // GFP - 19/03/2013 - Nopado para que o sistema calcule CFO com mais de uma aliquota de diferimento diferente.
            nVal_Dif := DITrans( ( nVal_ICM * ( aICMS_Dif[nP,3] / 100 ) ), 2 )
         ENDIF


         IF aICMS_Dif[nP,4] > 0
            nVal_CP1 := DITrans( ( (nVal_ICM - nVal_Dif) * ( aICMS_Dif[nP,4] / 100 ) ), 2 )
            nVal_CP  := nVal_CP1
         ENDIF

         IF aICMS_Dif[nP,5] > 0
            nVal_CP2 := DITrans(( nBase * ( aICMS_Dif[nP,5] / 100 ) ), 2 )
            nVal_CP  := nVal_CP2
         ENDIF

         IF nVal_CP1 > 0 .AND. nVal_CP2 > 0
            nVal_CP  := IF(nVal_CP1 > nVal_CP2, nVal_CP2, nVal_CP1)
         ENDIF

         nVal_ICM1 := nVal_ICM - nVal_Dif - nVal_CP
         nVal_ICM2 := DITrans( ( nBase * ( aICMS_Dif[nP,6] / 100 ) ), 2)
         nVal_ICM  := IF(nVal_ICM1 > nVal_ICM2, nVal_ICM1, nVal_ICM2 )

         If lICMS_Dif
 	        Work_SW8->WKICMSUSP:=aIcms_Dif[nP,2]               // ICMS Suspenso
  	        Work_SW8->WKVICMDIF:= nVal_Dif                    // Valor ICMS Diferido
  	        Work_SW8->WKVICM_CP:= nVal_Cp                     // Valor Cred. Presumido
            Work_SW8->WKVLICMDV:= nVal_ICMDV                  // Valor ICMS Devido
         EndIf

         If lICMS_Dif2
            Work_SW8->WKPCREPRE:=aIcms_Dif[nP,4]               //% Perc. Max. Cred. PResumido
  	        Work_SW8->WKPICMDIF:=aIcms_Dif[nP,3]               //% Difer. do ICMS
  	        Work_SW8->WKPICM_CP:=aIcms_Dif[nP,5]               //% Cred. Presumido
  	        Work_SW8->WKICMS_PD:=aIcms_Dif[nP,6]               //% Min. ICMS
         Endif
	   EndIf

   ENDIF


   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"WHILE_CALC_IMPOSTOS"),)   // Bete 02/06/05
   Work_SW8->(DBSKIP())
ENDDO
IF lAUTPCDI
   DI500Block(cAlias,"EIJ_BASPIS", nEIJ_BASPIS)
   DI500Block(cAlias,"EIJ_BR_PIS", nEIJ_BR_PIS)
   DI500Block(cAlias,"EIJ_VLDPIS", nEIJ_VLDPIS)
   DI500Block(cAlias,"EIJ_VLRPIS", nEIJ_VLRPIS)

   DI500Block(cAlias,"EIJ_BASCOF", nEIJ_BASCOF)
   DI500Block(cAlias,"EIJ_BR_COF", nEIJ_BR_COF)
   DI500Block(cAlias,"EIJ_VLDCOF", nEIJ_VLDCOF)
   DI500Block(cAlias,"EIJ_VLRCOF", nEIJ_VLRCOF)
ENDIF

IF nRecVlr # 0
   Work_SW8->(DBGOTO(nRecVlr))
   FOR A := 1 TO  LEN(aAcertos)
     IF !EMPTY(aAcertos[A,1]) .AND. aAcertos[A,2] # aAcertos[A,1]
        IF(A=1,Work_SW8->WKVLII   += DI500Trans(aAcertos[A,2] - aAcertos[A,1]),)
        IF(A=2,Work_SW8->WKVLIPI  += DI500Trans(aAcertos[A,2] - aAcertos[A,1]),)
     ENDIF
   NEXT
ENDIF

//Calculo do ICMS
DI500Block(cAlias,"EIJ_VLICMS", aAcertos[3,1] )
IF lCpsICMSPt                                                                   //NCF - 11/05/2011
   DI500Block(cAlias,"EIJ_VLICMD", aAcertos[4,1] )
ENDIF

DI500GrvEI("EII_SW6")

Work_SW8->(DBSETORDER(nOrdSW8))
Return .T.

Function DI500ApSegAdi(cIncoter,nFOBRS,nFOBTotRS,nFreteRS,nSegMoeda,nSegRS,lRateio,nAcresDedu,nTotAcresDedu)// Atencao: Funcao usada no EICDI154.PRW

LOCAL aSeguro:=ARRAY(2),nRateio
DEFAULT nTotAcresDedu:=0

//MFR OSSME-1425
//IF EMPTY(M->W6_SEGPERC) .OR. lRateio
IF EMPTY(M->W6_SEGPERC) .OR. EMPTY(M->W6_SEGBASE) .OR. lRateio
   //NCF - 21/09/2011 - Nopado - Nas chamadas da Função DI500ApSegAdi, o frete já deve estar retirado quando o incoterm prevê frete incluso.
   //                            A variável nFreTotRS não é passada e por isso não se obtem o frete proporcional da adição para rateio.

   //IF AvRetInco(cIncoter,"CONTEM_FRETE")/*FDR - 27/12/10*/  //cIncoter $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDP,DDU"//AWR - DDU
      //nRateio:= (nFOBRS-nFreteRS+nAcresDedu)/(nFOBTotRS+nTotAcresDedu)//-nFreTotRS)
   //ELSE
      nRateio:= (nFOBRS+nAcresDedu)/(nFOBTotRS+nTotAcresDedu)
   //ENDIF
   aSeguro[1]:= DI500Trans(nRateio*nSegMoeda)// Moeda Negociada
   aSeguro[2]:= DI500Trans(nRateio*nSegRS)// Moeda Nacional - Real
ELSE
   IF M->W6_SEGBASE = '1'//Seguro Sobre o Valor da Mercadoria
      IF AvRetInco(cIncoter,"CONTEM_FRETE")/*FDR - 27/12/10*/  //cIncoter $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDP,DDU"//AWR - DDU
         aSeguro[2]:=DI500Trans((nFOBRS-nFreteRS)*M->W6_SEGPERC/100)//Real
      ELSE
         aSeguro[2]:=DI500Trans(nFOBRS*M->W6_SEGPERC/100)//Real
      ENDIF
      aSeguro[1]:=DI500Trans(aSeguro[2]/Work_EIJ->EIJ_TX_FOB)//Moeda Negociada

   ELSEIF M->W6_SEGBASE = '2'//Seguro Sobre o Valor da Mercadoria + Frete
      IF AvRetInco(cIncoter,"CONTEM_FRETE")/*FDR - 27/12/10*/  //cIncoter $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDP,DDU"//AWR - DDU
         aSeguro[2]:=DI500Trans(nFOBRS*M->W6_SEGPERC/100)//Real
      ELSE
         aSeguro[2]:=DI500Trans((nFOBRS+nFreteRS)*M->W6_SEGPERC/100)//Real
      ENDIF
      aSeguro[1]:=DI500Trans(aSeguro[2]/Work_EIJ->EIJ_TX_FOB)//Moeda Negociada

   ELSEIF M->W6_SEGBASE = '3'//Seguro Sobre o Valor da Mercadoria + Frete + Acrescimo - Deducao
      nFOBRS+=nAcresDedu
      IF AvRetInco(cIncoter,"CONTEM_FRETE")/*FDR - 27/12/10*/  //cIncoter $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDP,DDU"//AWR - DDU
         aSeguro[2]:=DI500Trans(nFOBRS*M->W6_SEGPERC/100)//Real
      ELSE
         aSeguro[2]:=DI500Trans((nFOBRS+nFreteRS)*M->W6_SEGPERC/100)//Real
      ENDIF
      aSeguro[1]:=DI500Trans(aSeguro[2]/Work_EIJ->EIJ_TX_FOB)//Moeda Negociada

   ELSEIF M->W6_SEGBASE = '4'//Seguro Sobre o Valor da Mercadoria + Acrescimo - Deducao
      nFOBRS+=nAcresDedu
      IF AvRetInco(cIncoter,"CONTEM_FRETE")/*FDR - 27/12/10*/  //cIncoter $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDP,DDU"//AWR - DDU
         aSeguro[2]:=DI500Trans((nFOBRS-nFreteRS)*M->W6_SEGPERC/100)//Real
      ELSE
         aSeguro[2]:=DI500Trans(nFOBRS*M->W6_SEGPERC/100)//Real
      ENDIF
      aSeguro[1]:=DI500Trans(aSeguro[2]/Work_EIJ->EIJ_TX_FOB)//Moeda Negociada

   ENDIF
ENDIF

RETURN aSeguro


FUNCTION DI500IICalc(cAlias,nVlrRS,nFreteRS,nSeguroRS,cIncot,nAcrecimo,nDeducao,nBaseII,lAdicao,nVlrII,nAliqNew)

LOCAL nII:=0,nVl_II:=0
LOCAL nVlr_II // deixar assim,para poder comparar com NIL

nBaseII:=DI500Trans(nVlrRS+nAcrecimo-nDeducao)

IF !AvRetInco(cIncot,"CONTEM_FRETE")
   nBaseII+= nFreteRS
ENDIF

IF !AvRetInco(cIncot,"CONTEM_SEG")
   nBaseII+= nSeguroRS
ENDIF

IF lAdicao
   DI500Block(cAlias,"EIJ_BAS_II", nBaseII )
ENDIF
//Valor Calculado I.I.
IF nAliqNew = NIL
   nAliqIIUsada:=DI500Block(cAlias,"EIJ_ALI_II")
ELSE
   nAliqIIUsada:=nAliqNew
ENDIF
nVl_II:=DI500Trans((nBaseII*(nAliqIIUsada/100)))

IF lAdicao
   DI500Block(cAlias,"EIJ_VL_II" , nVl_II )
   DI500Block(cAlias,"EIJ_VLR_II", 0 )
   DI500Block(cAlias,"EIJ_DEVII" , 0 )
ENDIF

//Valor Calculado Reduzido I.I.
IF !EMPTY(DI500Block(cAlias,"EIJ_TACOII"))
   IF nAliqNew = NIL
      nAliqIIUsada:=DI500Block(cAlias,"EIJ_ALA_II")
   ENDIF
   nVlr_II:=DI500Trans((nBaseII*(nAliqIIUsada/100)))
   IF lAdicao
      DI500Block(cAlias,"EIJ_VLR_II", nVlr_II )
   ENDIF
ENDIF
//IF !EMPTY(DI500Block(cAlias,"EIJ_ALR_II"))
IF DI500Block(cAlias,"EIJ_REGTRI") == '4'
   IF nAliqNew = NIL
      nAliqIIUsada:=DI500Block(cAlias,"EIJ_ALR_II")
   ENDIF
   nVlr_II:=DI500Trans((nBaseII*(nAliqIIUsada/100)))
   IF lAdicao
      DI500Block(cAlias,"EIJ_VLR_II", nVlr_II )
   ENDIF
ENDIF

//Valor Devido I.I.
IF nVlr_II # NIL
   nII:=nVlr_II//Essa variavel eh diferente da debaixo
   IF lAdicao
      DI500Block(cAlias,"EIJ_DEVII", nVlr_II )
   ENDIF
ELSE
   nII:=nVl_II
   IF lAdicao
      DI500Block(cAlias,"EIJ_DEVII", nVl_II )
   ENDIF
ENDIF
nVlrII:=nII//Valor do I.I. Devido sem  Isencao ou Suspensao usado para base do I.P.I.
//Valor a Recolher I.I.
IF DI500Block(cAlias,"EIJ_REGTRI") $ '3,5'
   nII:=0
ELSEIF DI500Block(cAlias,"EIJ_REGTRI") == '4' .AND. !EMPTY(DI500Block(cAlias,"EIJ_PR_II"))
   IF DI500Block(cAlias,"EIJ_PR_II") == 100
      nII:=0
   ELSE
      nII:=DI500Trans((nBaseII*(DI500Block(cAlias,"EIJ_ALI_II")/100)))
      nII:=DI500Trans((nII*((100-DI500Block(cAlias,"EIJ_PR_II"))/100)))
   ENDIF
   nPr_II := DI500Block(cAlias,"EIJ_PR_II")

   IF lAdicao
      DI500Block(cAlias,"EIJ_DEVII", nVl_II )
   ENDIF

ENDIF
IF lAdicao
   DI500Block(cAlias,"EIJ_VLARII", nII )
ENDIF

RETURN nII

FUNCTION DI500IPICalc(cAlias,nBaseII,nII,lAdicao,nVlrII,nVlDIPI,nIPIBase,nAliqNew, cCod_I, nQtde, nVUIPI)// Atencao: Funcao usada no EICDI154.PRW
// Bete - 13/09/04 - Inclusao dos parametros cCod_I, nQtde e nVUIPI

LOCAL nIPI:=0
DEFAULT cCod_I:=" ", nQtde:=0, nVUIPI:=0       // Bete - 14/09/04

//Valor Base Ad. Valorem I.P.I.
nIPIBase:=DI500Trans(nBaseII+nII)

IF DI500Block(cAlias,"EIJ_REGTRI") $ '5'//'3,5'//AWR 0 06/2009 - No SICOMEX o I.I. 3-Isento nao entra na base do IPI
   nIPIBase:=DI500Trans(nBaseII+nVlrII) //O I.I. devido serve de base de calculo mesmo sendo 5-Suspenso
ENDIF

IF lAdicao
   DI500Block(cAlias,"EIJ_BASIPI",nIPIBase)
ENDIF

IF lAdicao
   DI500Block(cAlias,"EIJ_VLAIPI",0)
   DI500Block(cAlias,"EIJ_VLDIPI",0)
ENDIF

//Valor Devido := Valor a Recolher I.P.I.
IF nAliqNew = NIL
   IF DI500Block(cAlias,"EIJ_TPAIPI")== "2"  // Jonato em 25/08/2004 para tratar IPI com aliq. especifica
      nAliqIPIUsada:=DI500Block(cAlias,"EIJ_ALUIPI")
   ELSE
      If !Empty(DI500Block(cAlias,"EIJ_ALRIPI")) //ER - 14/05/2007
         nAliqIPIUsada:=DI500Block(cAlias,"EIJ_ALRIPI")
      Else
         //****TRP - 15/04/10 - Tratamento da reducao total de IPI
         IF DI500Block(cAlias,"EIJ_REGIPI") $ '2'
            nAliqIPIUsada:=DI500Block(cAlias,"EIJ_ALRIPI")
         ELSE
            nAliqIPIUsada:=DI500Block(cAlias,"EIJ_ALAIPI")
         ENDIF
      EndIf
   ENDIF
ELSE
   nAliqIPIUsada:=nAliqNew
ENDIF
IF DI500Block(cAlias,"EIJ_TPAIPI")== "2"  // Jonato em 25/08/2004 para tratar IPI com aliq. especifica
   // nVlDIPI:=nIPI:=DI500Trans(nIPIBase*nAliqIPIUsada)
   //Bete - 02/09/04 - Tratamento IPI c/ aliq. Espec.
   //IF lAdicao  //AAF 13/09/07 - Utilizar quantidade específica da adição
   //nVlDIPI:=nIPI:=nVlrIPIEsp:=DI500Trans(DI500Block(cAlias,"EIJ_QTUIPI")*nAliqIPIUsada)
   //SVG - 30/07/2009 - IPI de pauta por peso
   If EIJ->(FieldPos("EIJ_CALIPI")) > 0 .AND. DI500Block(cAlias,"EIJ_CALIPI")== "2" .AND. lAdicao
      nVlDIPI:=nIPI:=nVlrIPIEsp:=DI500Trans(DI500Block(cAlias,"EIJ_PESOL")*nAliqIPIUsada)
   Else
      nVlDIPI:=nIPI:=nVlrIPIEsp:=DI500Trans(nQtde*nAliqIPIUsada)
   EndIf
   IF Empty(nVlDIPI) .AND. !EMPTY(cCod_I) .AND. SB1->(DbSeek(xFilial()+cCod_I)) .AND. IPIPauta()
      nIPIPauta := IPIPauta(.T., nVUIPI)
      nVlDIPI:=nIPI:=nVlrIPIEsp:=DI500Trans(nQtde * nIPIPauta,2)
   ENDIF
ELSE
   nVlDIPI:=nIPI:=DI500Trans((nIPIBase*(nAliqIPIUsada/100)))
ENDIF

IF lAdicao
   DI500Block(cAlias,"EIJ_VLDIPI",nIPI)
ENDIF

IF DI500Block(cAlias,"EIJ_REGIPI") $ '2,4'
   IF lAdicao
      DI500Block(cAlias,"EIJ_VLAIPI",nIPI)
   ENDIF
ELSE
   nIPI:=0
ENDIF

RETURN nIPI
// AWR - 22/04/2004 - Os tres primeiros paramentros é do calculo Velho, os outros sao do calculo novo

FUNCTION DI500ICMSCalc(nBase,nRedICMS,nAliquota,nVA,nOT,nBase_PIS,nII,nIPI,nPis,nCofins,nICMSPC,cOrigem_2)

DEFAULT cOrigem_2:="DI500ICMSCALC"
PRIVATE nVlr_Imp_Dev := 0

IF nPis == NIL
   nPis := 0
ENDIF

IF nCofins == NIL
   nCofins := 0
ENDIF
IF SWZ->(!EOF()) .AND. !EMPTY(SWZ->WZ_RED_CTE)  // LDR
   nAliqCTE:=SWZ->WZ_RED_CTE
ELSE
   nAliqCTE := 0
ENDIF
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,cOrigem_2),)// RJB 14/06/2004
IF lMV_ICMSPIS

   nBase := nVA + nII + nIPI + nOT + nPis + nCofins + nVlr_Imp_Dev // SOMATORIA NO RDMAKE DESTA VARIAVEL nVlr_Imp_Dev

ENDIF
IF !EMPTY(nAliqCTE) .AND. nRedICMS == 1
   nBaseNew:= ( nBase / ( (100 - nAliqCTE) /100 ) )
   nBase := DITrans( nBaseNew * (nAliqCTE/nAliquota) ,2)
ELSE
   IF EasyGParam("MV_ICMS_IN",,.F.)
      nBase := DITrans( ( (nBase*nRedICMS) / ( (100 - nAliquota) /100 ) ) ,2)
      If nAliquota == 0 .and. nICMSPC # 0
         nBase := DITrans( ( (nBase*nRedICMS) / ( (100 - nICMSPC) /100 ) ) ,2)    // Jonato em 27/Ago/2005 para ter uma base mesmo quando ICMS exonerado
      Endif
   ELSE
      nBase := DITrans( (nBase*nRedICMS) ,2)
   ENDIF
ENDIF
Return nBase


FUNCTION DI500PISCalc(nVA,nOT,nII,nIPI,nICMS,nPIS,nCOFINS,nPercRed,nWZ_ICMSPC,nVlIPIEsp,cOrigem,nBASE_PC,lIPIPauta)// Atencao: Funcao usada no EICDI154.PRW e EICTP252.PRW
DEFAULT nVlIPIEsp:= 0   // Bete - 02/09/04 - Tratamento de IPI Especifico
DEFAULT lIPIPauta:= .F.
PRIVATE nBase_PIS:=0, nCIF:=nVA, cChamada:=cOrigem//AWR - 25/10/2004 - Variaveis usadas no Rdmake
If Type("lAUTPCDI") <> "L"
   lAUTPCDI := DI500AUTPCDI()
EndIf

If EasyGParam("MV_EIC0028",,.F.)
   If nWZ_ICMSPC <> 0
      nICMS := nWZ_ICMSPC
   EndIf
Else
   nICMS := 0
EndIf

If !EasyGParam("MV_EIC0030",,.F.)   // GFP - 11/10/2013
   nPIS    := 0
   nCOFINS := 0
EndIf

IF nVlIPIEsp > 0 // Bete - 02/09/04 - Tratamento de IPI Especifico
   nBase_PIS:= (nVA*(1+(nII * nICMS)) + (nICMS * nVlIPIEsp)+(nOT * nICMS) ) / (1 - ( nICMS + nPIS + nCOFINS ))
ELSE
   nBase_PIS:= (nVA * ( 1 + (nII * nICMS) + (nIPI * nICMS) + (nII * nIPI * nICMS)) + (nOT * nICMS) ) / (1 - ( nICMS + nPIS + nCOFINS ))
ENDIF

IF EasyGParam("MV_ZDESPIS",,.T.)
   nValorII := nVA*nII
   IF lIPIPauta
       nValorIPI := nVlIPIEsp
   ELSE
       nValorIPI := (nVa + nValorII)*nIPI
   ENDIF
   nICMSTEMP:= ( (nVA + nValorII + nValorIPI)/(1-nICMS) ) * nICMS
   nBase_PIS:= (nVA+nICMSTEMP)/(1-(nPIS+nCOFINS))

   IF cOrigem == "PISCALC_DI"  .OR. cOrigem == "PISCALC_DSI"
      Work_SW8->WKICMBPIS  :=nICMSTEMP
   ENDIF
ENDIF

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"DI500PISCALC"),)//AWR - 25/10/2004
IF lAUTPCDI
   nBASE_PC := nBase_PIS
ENDIF

IF nPercRed # 0
   nVlrTira :=(nBase_PIS*nPercRed)
   nBase_PIS:=(nBase_PIS-nVlrTira)
ENDIF

RETURN nBase_PIS


FUNCTION DI500BaseICMSCalc()// AWR - 18/02/2004

LOCAL cFilSWZ:=xFilial("SWZ"),cFilSYD:=xFilial("SYD")
LOCAL nBaseICMS:=0
LOCAL nMaiorAdi:=0
LOCAL nMaiorVlr:=0
LOCAL nRecVlr  :=0
//LOCAL nRecAdi  :=0
LOCAL nAntiDump:=0//AWR - 25/11/2004
LOCAL nVlICMS  :=EasyGParam("MV_ICMSMID",,0)//AWR  - 28/06/2006
Local nQtdeTot  := 0
Local nQtdRateio:= 0
Local aConvVal
Local nPos1     := 0
Local cAdicao1
Local lDesConCarg := (SW6->(FieldPos("W6_CO_CARG")) # 0 .And. M->W6_CO_CARG == '1') //LRS 4/9/2013 - 9:00 - Chamado 743788: Foi Adicionado a variavel para a validação de N.F sem D.I
Local nCurrier := M->W6_CURRIER // DFS - Variável para verificação de taxa siscomex
Local cAlias := "Work_EIJ" //FDR - 23/12/16
Local lTxSisICMS := DI500TxICM(M->W6_IMPORT)

nEIJ_BASPIS:=nEIJ_BR_PIS:=nEIJ_VLDPIS:=nEIJ_VLRPIS:=nEIJ_BASCOF:=nEIJ_BR_COF:=nEIJ_VLDCOF:=nEIJ_VLRCOF:=0

Private aQtdAdi:= {}//AAF 12/02/2007 - Rateio de quatidade específica da adição por quantidade do item.
Work_SW8->(DBSETORDER(4))
Work_EIJ->(DBSETORDER(1))
Work_EIJ->(DBGOTOP())
ProcRegua( Work_EIJ->(EasyReccount("Work_EIJ")) )

nVal_Dif := nVal_CP := nVal_ICM := 0   //TRP - 18/02/2010

Private nRecAdi     := WORK_EIJ->(RECNO())
Private nRecIte     := WORK_SW8->(RECNO())
Private nRecIteMAdi := WORK_SW8->(RECNO())
Private nMaiorAdi   := nMaiorIte   := 0
Private nDspBICM_Ad := nDspICMS_It := 0
Private nTaxSISC_Ad := nTaxSISC_It := 0
Private aOrdSWZ     := {}              //NCF - 11/05/2011

//NCF - 21/12/2010 - Primeiro Loop nas adicões(apurar o rateio de despesa base icms e taxa siscomex para cada adição)
DO WHILE WORK_EIJ->(!EOF())

   IncProc(STR0266+Work_EIJ->EIJ_ADICAO) //"Calculando Impostos "

   IF Work_EIJ->EIJ_ADICAO == "MOD"
      Work_EIJ->(DBSKIP())
      LOOP
   ENDIF

   IF nCurrier <> "1" //RNLP 26/02/2020 - Issue DTRADE-3281 - remoção dos pontos que consideram este campo(W6_CO_CARG) como condição para a geração da taxa SISCOMEX
      Work_EIJ->EIJ_TAXSIS:=DI500Trans( DI500TxSiscomex(VAL(Work_EIJ->EIJ_ADICAO),M->W6_QTD_ADI,(Work_EIJ->EIJ_BAS_II/nBaseTotalII)) )
   Else
      Work_EIJ->EIJ_TAXSIS := 0
   Endif
   IF lAntDumpBaseICMS//AWR - 15/01/2004
      nAntiDump+=Work_EIJ->EIJ_VLR_DU//AWR - 25/11/2004
   ENDIF
   If lDespBaseIcms
      nDspBICM_Ad +=  WORK_EIJ->EIJ_DPBICM
   EndIf
   nTaxSISC_Ad +=  WORK_EIJ->EIJ_TAXSIS

   IF WORK_EIJ->EIJ_TAXSIS > nMaiorAdi
      nRecAdi   := WORK_EIJ->(RECNO())
      nMaiorAdi :=  WORK_EIJ->EIJ_TAXSIS
   ENDIF

   Work_EIJ->EIJ_VLICMS:=0

   If AvFlags("GRV_BASEICMS_DI_ELETRONICA")
      Work_EIJ->EIJ_BASICM := 0
   EndIf

   IF lCpsICMSPt                                            //NCF - 11/05/2011
      Work_EIJ->EIJ_VLICMD:=0
   ENDIF

   IF lZeraDespis .AND. EIJ->(FIELDPOS("EIJ_ICMSPI")) !=0
      Work_EIJ->EIJ_ICMSPI := 0
   ENDIF

   WORK_EIJ->(DbSkip())

ENDDO

WORK_EIJ->(DbGoTo(nRecAdi))  
If WORK_EIJ->(!Eof())      //NCF - 11/10/2019 
   IF nCurrier <> "1" //RNLP 26/02/2020 - Issue DTRADE-3281 - remoção dos pontos que consideram este campo(W6_CO_CARG) como condição para a geração da taxa SISCOMEX
      IF nSomaTaxaSisc #  nTaxSISC_Ad
         WORK_EIJ->EIJ_TAXSIS += ( nSomaTaxaSisc -  nTaxSISC_Ad )
      ENDIF
   EndIf

   IF nDspBICM_Ad # (nSomaBaseICMS + nSomaDespRatAdicao)
      If lDespBaseIcms
         //TDF - 05/10/12 - Soma despesa base de ICMS rateada por peso
         WORK_EIJ->EIJ_DPBICM += (nSomaBaseICMS + nBaseICMSPeso + nSomaDespRatAdicao + nAntiDump - nDspBICM_Ad) //AAF 05/07/2017 - adicionado antidumping
      EndIf
   ENDIF
EndIf

Work_EIJ->(DBGOTOP())

// NCF - 21/12/2010 - Segundo loop para os itens de cada adição (apurar o rateio de despesa base icms e taxa siscomex para cada item da adição)
DO WHILE WORK_EIJ->(!EOF())

   nRecIte     := 0
   nMaiorIte   := 0
   nTaxSISC_It := 0
   nDspICMS_It := 0

   //** AAF 12/02/2007 - Rateio de quatidade específica da adição por quantidade do item.
   If ( nPos := aScan(aQtdAdi,Work_EIJ->EIJ_ADICAO) ) == 0
      aAdd(aQtdAdi,{Work_EIJ->EIJ_ADICAO,0})
      nPos := Len(aQtdAdi)
   EndIf

   IF Work_SW8->(DBSEEK(Work_EIJ->EIJ_ADICAO))
      DO WHILE Work_SW8->(!EOF()) .And. Work_SW8->WKADICAO == Work_EIJ->EIJ_ADICAO

         IF EMPTY(Work_SW8->WKFLAGIV) .AND. EMPTY(Work_SW8->WKINVOICE)
            Work_SW8->(DBSKIP())
            LOOP
         ENDIF

         nRateio:=(Work_SW8->WKFOBTOTR/Work_EIJ->EIJ_VLMMN )
         IF lAntDumpBaseICMS//AWR - 25/11/2004
            Work_SW8->WKANTIDUM:=DI500Trans(Work_EIJ->EIJ_VLR_DU*nRateio)
         ENDIF
         IF lMV_TXSIRAT//AWR -11/01/2005
            nRateio:=(Work_SW8->WKBASEII/Work_EIJ->EIJ_BAS_II)
         ENDIF
         Work_SW8->WKTAXASIS:=DI500Trans(Work_EIJ->EIJ_TAXSIS*nRateio)

         nTaxSISC_It +=  Work_SW8->WKTAXASIS
         If lDespBaseIcms
            IF WORK_EIJ->EIJ_DPBICM == 0 .Or. WORK_EIJ->EIJ_TAXSIS == 0    //NCF - 04/07/2011 - Para considerar o acerto das desp. base ICMS
               nDspICMS_It += Work_SW8->WKD_BAICM
            ELSE
               nDspICMS_It += (Work_SW8->WKD_BAICM - Work_SW8->WKTAXASIS)  //NCF - 04/07/2011 - Para considerar o acerto das desp. base ICMS sem a taxa siscomex
            ENDIF
         EndIf

         IF WORK_SW8->WKTAXASIS > nMaiorIte
            nRecIte   := WORK_SW8->(RECNO())
            nMaiorIte := WORK_SW8->WKTAXASIS
         ENDIF

         IF WORK_EIJ->(RECNO()) == nRecAdi .And. WORK_SW8->WKTAXASIS >= nMaiorIte
            nRecIteMAdi := WORK_SW8->(RECNO())
         ENDIF

         //AAF 12/02/2007 - Rateio de quatidade específica da adição por quantidade do item.
         aQtdAdi[nPos][2] += Work_SW8->WKQTDE

         Work_SW8->(DBSKIP())
      ENDDO
   ENDIF

   If nRecIte > 0
      WORK_SW8->(DbGoTo(nRecIte))
      IF nCurrier <> "1" //RNLP 26/02/2020 - Issue DTRADE-3281 - remoção dos pontos que consideram este campo(W6_CO_CARG) como condição para a geração da taxa SISCOMEX
         IF nTaxSISC_It # WORK_EIJ->EIJ_TAXSIS
            WORK_SW8->WKTAXASIS += (WORK_EIJ->EIJ_TAXSIS - nTaxSISC_It)
         ENDIF
         IF lDespBaseIcms            
            IF (WORK_EIJ->EIJ_DPBICM == 0 .Or. WORK_EIJ->EIJ_TAXSIS == 0) .And. lTxSisICMS   //NCF - 04/07/2011 - Para considerar o acerto das desp. base ICMS quando Tx. Sicomex ou Dsp.Base estiver zerada
               IF nDspICMS_It # If(WORK_EIJ->EIJ_DPBICM < WORK_EIJ->EIJ_TAXSIS, (WORK_EIJ->EIJ_DPBICM-WORK_EIJ->EIJ_TAXSIS)*(-1) ,WORK_EIJ->EIJ_DPBICM-WORK_EIJ->EIJ_TAXSIS)
                  WORK_SW8->WKD_BAICM += ( If(WORK_EIJ->EIJ_DPBICM < WORK_EIJ->EIJ_TAXSIS, (WORK_EIJ->EIJ_DPBICM-WORK_EIJ->EIJ_TAXSIS)*(-1) ,WORK_EIJ->EIJ_DPBICM-WORK_EIJ->EIJ_TAXSIS) - nDspICMS_It)  //NCF - 25/04/2011
               ENDIF
            ELSE
               IF nDspICMS_It # WORK_EIJ->EIJ_DPBICM                     //NCF - 04/07/2011 - Para considerar o acerto das desp. base ICMS
                  WORK_SW8->WKD_BAICM += (WORK_EIJ->EIJ_DPBICM - nDspICMS_It)
               ENDIF
            ENDIF
         ENDIF
      ENDIF
   EndIf

   nTaxSISC_It := 0                                                                                //NCF - 20/04/2011
   nDspICMS_It := 0                                                                                //NCF - 20/04/2011

   WORK_EIJ->(DbSkip())

ENDDO

Work_SW8->(DBGOTOP())
Work_SW8->(DBSETORDER(4))
Work_EIJ->(DBSETORDER(1))
ProcRegua( Work_SW8->(EasyReccount("Work_SW8")) )
nRecVlr := Work_SW8->(RECNO())
DO WHILE Work_SW8->(!EOF())

   IncProc(STR0266+Work_SW8->WKCOD_I) //"Calculando Impostos "

   IF EMPTY(Work_SW8->WKFLAGIV) .AND. EMPTY(Work_SW8->WKINVOICE)
      Work_SW8->(DBSKIP())
      LOOP
   ENDIF

   Work_EIJ->(DBSEEK(Work_SW8->WKADICAO))

   //TDF - 05/10/12 - Soma despesa base de ICMS rateada por peso
   nSomaItemBaseICMS:=DI500Trans( (nSomaBaseICMS) * (Work_EIJ->EIJ_VLMMN/nFOB_TOT)) + DI500Trans(nBaseICMSPeso* (Work_EIJ->EIJ_PESOL/SW6->W6_PESOL))
   /* despesas que devem ser rateadas pela quantidade de adições */
   nSomaItemBaseICMS += DI500Trans(nSomaDespRatAdicao/M->W6_QTD_ADI)

   nRateio:=(Work_SW8->WKFOBTOTR/Work_EIJ->EIJ_VLMMN)

   Work_SW8->WKBASEICM:=DI500Trans(nSomaItemBaseICMS*nRateio)+IF(lTxSisICMS ,Work_SW8->WKTAXASIS,0)+Work_SW8->WKANTIDUM

   nBaseICMS+=Work_SW8->WKBASEICM

   IF Work_SW8->WKBASEICM > nMaiorVlr
      nMaiorVlr:=Work_SW8->WKBASEICM
      nRecVlr  :=Work_SW8->(RECNO())
   ENDIF

   Work_SW8->(DBSKIP())
ENDDO

IF nRecVlr # 0
   Work_SW8->(DBGOTO(nRecVlr))
   //TDF - 05/10/12 - Soma despesa base de ICMS rateada por peso
   IF (nSomaBaseICMS+nBaseICMSPeso+IF(lTxSisICMS ,nSomaTaxaSisc,0)+nAntiDump+nSomaDespRatAdicao) # nBaseICMS
      Work_SW8->WKBASEICM+= (nSomaBaseICMS+nBaseICMSPeso+IF(lTxSisICMS ,nSomaTaxaSisc,0)+nAntiDump+nSomaDespRatAdicao)-nBaseICMS
   ENDIF
ENDIF

cAdicao1:= ""
WORK->(DBSETORDER(3))  // Bete - 08/09/04 - Tratamento IPI c/ aliq. especif.
Work_SW8->(DBGOTOP())
Work_SW8->(DBSETORDER(4))
Work_EIJ->(DBSETORDER(1))
ProcRegua( Work_SW8->(EasyReccount("Work_SW8")) )
DO WHILE Work_SW8->(!EOF())

   IncProc(STR0266+Work_SW8->WKCOD_I) //"Calculando Impostos "

   nVal_Dif := nVal_CP := nVal_ICM := 0 //THTS - 15/09/2017 - TE-6792 - Zera as variaveis a cada item

   IF EMPTY(Work_SW8->WKFLAGIV) .AND. EMPTY(Work_SW8->WKINVOICE)
      Work_SW8->(DBSKIP())
      LOOP
   ENDIF

   Work_EIJ->(DBSEEK(Work_SW8->WKADICAO))
   nAliqIPIUsada:=nAliqIIUsada:=0
   nBASE_PC:=0
   nVlrIPIEsp:=0   // Bete - 02/09/04 - Tratamento IPI c/ aliq. especif.
   WORK->(DBSEEK(Work_SW8->WKPO_NUM+Work_SW8->WKPGI_NUM+Work_SW8->WKPOSICAO))  // Bete - 08/09/04 - Tratamento IPI c/ aliq. especif.

   If cAdicao1 <> Work_SW8->WKADICAO
      nQtdeTot := 0
      aConvVal := DI500ConvQtdeRat("Work_EIJ",@nQtdeTot)
   Endif

//   If WORK_SW8->( FieldPos("WKQTDVOL") > 0 )     // Nopado por GFP - 27/02/2013
//      nQtdRateio := WORK_SW8->WKQTDVOL*Work_SW8->WKQTDE
//   Else
      nPos1 := aScan(aConvVal, {|x| x[2] == Work_SW8->(RECNO()) })
      If nPos1 > 0
         nQtdRateio:= aConvVal[nPos1][1] * DI500Block("Work_EIJ","EIJ_QTUIPI") / nQtdeTot
      Endif
//   EndIf

   DI500IICalc( "Work_EIJ",0,0,0,'',0,0,0,.F.,0)
   DI500IPICalc("Work_EIJ",0,0,.F.,0,0,,, Work_SW8->WKCOD_I, nQtdRateio, Work->WKIPIPAUTA)

   nAliqICMS :=0
   nRedICMS  :=1
   nWZ_ICMSPC:=0
   IF SWZ->(DbSeek(cFilSWZ+Work_SW8->WKOPERACA))
/* Quando existir aliquota de carga tributaria equivalente esta sera usada para o calculo da base de pis e cofins // LDR*/
      IF EMPTY(SWZ->WZ_RED_CTE)
         nAliqICMS:= SWZ->WZ_AL_ICMS
      ELSE
         nAliqICMS:= SWZ->WZ_RED_CTE
      ENDIF
      IF SWZ->(FIELDPOS("WZ_ICMS_PC")) # 0
         nWZ_ICMSPC:=(SWZ->WZ_ICMS_PC/100)
      ENDIF
      nRedICMS := IF(SWZ->WZ_RED_ICM#0,(100-SWZ->WZ_RED_ICM)/100,1)

      // TRP - 18/02/2010
      IF lICMS_Dif .AND. ASCAN( aICMS_Dif, {|x| x[1] == Work_SW8->WKOPERACA} ) == 0
      //                Operação           Suspensao        % diferimento    % Credito presumido                % Limite Cred.   % pg desembaraco
         AADD( aICMS_Dif, {Work_SW8->WKOPERACA, SWZ->WZ_ICMSUSP, SWZ->WZ_ICMSDIF, IF( lICMS_Dif2, SWZ->WZ_PCREPRE, 0), SWZ->WZ_ICMS_CP, SWZ->WZ_ICMS_PD, SWZ->WZ_AL_ICMS, SWZ->WZ_ICMS_PC} )
      ENDIF

      If AvFlags("ICMSFECP_DI_ELETRONICA")
         nAlICMFECP := SWZ->WZ_ALFECP
      EndIf
      If AvFlags("FECP_DIFERIMENTO")
         nAlDifFECP := SWZ->WZ_ICMSDIF
      EndIf

   ELSEIF SYD->(DbSeek(cFilSYD+Work_SW8->WKTEC+Work_SW8->WKEX_NCM+Work_SW8->WKEX_NBM))
      nAliqICMS:= SYD->YD_ICMS_RE
      IF SYD->(FIELDPOS("YD_ICMS_PC")) # 0                                            //NCF - 10/06/2011 - Aliq. De ICMS para PIS/COFINS na N.c.m
         nWZ_ICMSPC := (SYD->YD_ICMS_PC/100)
      ENDIF
   ENDIF

   nBaseICMS:=0
   // Bete - 09/05/06 - somente é necessário recalcular o PIS-COFINS novamente após a apuração da taxa do SISCOMEX,
   // se a fórmula de cálculo for a antiga, ou seja o MV_ZDESPIS = .F., onde as outras despesas entram no cálculo
   IF lMV_PIS_EIC .AND. !lZeraDesPis
      nQtde:=Work_SW8->WKQTDE // ldr - OC - 0048/04 - OS - 0989/04
      IF lVlUnid  .AND. !EMPTY(Work_SW8->WKQTDE_UM)// LDR - OC - 0048/04 - OS - 0989/04
         nQtde:=Work_SW8->WKQTDE_UM
      ENDIF

      //O campo Work_SW8->WKBASEICM contem SOMENTE as despesas base de ICMS
      /* JONATO 04/FEV/2005. A utilização da variável nAUX_II é necessária para os casos
      em que houver redução de base de calculo, porque nesses casos as planilhas de calculo
      da Receita, reduzem a aliquota, e não a base. Também criei a variável apenas aqui para
      não ter que mexer com o tratamento dentro da função de calculo do impostos */
      nAUX_II:= nAliqIIUsada
      If Work_EIJ->EIJ_REGTRI = '4' .and. Work_EIJ->EIJ_PR_II <> 0 .and. EMPTY(Work_EIJ->EIJ_ALR_II)
         nAUX_II:= nAliqIIUsada - ( nAliqIIUsada * (Work_EIJ->EIJ_PR_II/100) )
      ElseIf Work_EIJ->EIJ_REGTRI $ '2,3,6'  // Bete - 06/05/06 - P/ IMUNIDADE, ISENCAO ou NAO-INCIDENCIA
         nAUX_II:=0                          // de II, a aliquota é zero p/ o cálculo do PIS/COFINS
      Endif
      nAux_IPI:=nAliqIPIUsada              // Jonato em 28/09/2005. Segundo a MP252, para ISENÇÃO
      IF Work_EIJ->EIJ_REGIPI $ '1,3'      // E IMUNIDADE de IPI, a aliquota é zero para calculo de PIS
         nAUX_IPI:=0
      ELSEIF Work_EIJ->EIJ_REGIPI $ '4,5' .AND. Work_EIJ->EIJ_TPAIPI = '2'
         IF nVlrIPIEsp == 0
            nVlrIPIEsp := DI500Trans(Work_EIJ->EIJ_QTUIPI*Work_EIJ->EIJ_ALUIPI)
         ENDIF
      ELSEIF Work_EIJ->EIJ_REGIPI $ '5'    //JAP - Zera o cálculo do IPI em caso de suspensão e o ato do IPI for = LEI
         cNroipi := EasyGParam("MV_ZIPIPIS",,"")
         cEijipi := Work_EIJ->EIJ_NROIPI
         cNroipi := Alltrim(STRTRAN(cNroipi, ".",""))
         cEijipi := Alltrim(STRTRAN(cEijipi, ".",""))
         IF !Empty(cNroipi) .AND. cEijipi $ cNroipi .AND. ALLTRIM(Work_EIJ->EIJ_ATOIPI) == 'LEI'
            nAUX_IPI := 0
         ENDIF
      ELSEIF Work_EIJ->EIJ_REGIPI $ '2'
         nAUX_IPI:=Work_EIJ->EIJ_ALRIPI       // Bete - 06/05/06 - P/ REDUCAO, considerar a aliq. reduzida
      ENDIF                                   // p/ o calculo do PIS/COFINS

      SYD->(DbSeek(cFilSYD+Work_SW8->WKTEC+Work_SW8->WKEX_NCM+Work_SW8->WKEX_NBM))

      IF !lAUTPCDI
         nRedPis:=SYD->YD_RED_PIS
         nRedCof:=SYD->YD_RED_COF
         nAliPis:=Work_SW8->WKPERPIS
         nAliCof:=Work_SW8->WKPERCOF
         nAluPis:=Work_SW8->WKVLUPIS
         nAluCof:=Work_SW8->WKVLUCOF
         If lCposCofMj                                                             //NCF - 20/07/2012 - Majoração COFINS
            nAliCofMaj := EicGetPerMaj( SYD->(YD_TEC+YD_EX_NCM+YD_EX_NBM) , Work_SW8->WKOPERACA ,SYT->YT_COD_IMP, "COFINS")
         EndIf
         If lCposPisMj                                                             //GFP - 11/06/2013 - Majoração PIS
            nAliPisMaj := EicGetPerMaj( SYD->(YD_TEC+YD_EX_NCM+YD_EX_NBM) , Work_SW8->WKOPERACA ,SYT->YT_COD_IMP, "PIS")
         EndIf
      ELSE
         nRedPis := Work_EIJ->EIJ_PRB_PC
         nRedCof := Work_EIJ->EIJ_PRB_PC
         nAliPis := Work_EIJ->EIJ_ALAPIS
         nAliCof := Work_EIJ->EIJ_ALACOF
         nAluPis := Work_EIJ->EIJ_ALUPIS
         nAluCof := Work_EIJ->EIJ_ALUCOF
         
               
         If lCposCofMj                                                             //NCF - 20/07/2012 - Majoração COFINS
            If Empty(DI500Block(cAlias,"EIJ_ALCOFM"))
               nAliCofMaj := EicGetPerMaj( Work_SW8->WKTEC+Work_SW8->WKEX_NCM+Work_SW8->WKEX_NBM , Work_SW8->WKOPERACA ,SYT->YT_COD_IMP, "COFINS")
            Else
               nAliCofMaj := (DI500Block(cAlias,"EIJ_ALCOFM"))
            EndIf
         EndIf
         If lCposPisMj                                                             //GFP - 11/06/2013 - Majoração PIS
            If Empty(DI500Block(cAlias,"EIJ_ALPISM"))
               nAliPisMaj := EicGetPerMaj( Work_SW8->WKTEC+Work_SW8->WKEX_NCM+Work_SW8->WKEX_NBM , Work_SW8->WKOPERACA ,SYT->YT_COD_IMP, "PIS")
            Else
               nAliPisMaj := (DI500Block(cAlias,"EIJ_ALPISM"))
            EndIf
         EndIf

         IF DI500Block(cAlias,"EIJ_REG_PC") = "4" //AWR - 17/06/2009 - Correcao: o SISCOMEX considera o Aliq. Reduzida para calcular a Base PIS/COFINS
            IF EIJ->(FieldPos("EIJ_ARDPIS")) # 0
               IF DI500Block(cAlias,"EIJ_ARDPIS") $ cSim  //TRP - 22/02/2010
                  nAliPis := DI500Block(cAlias,"EIJ_REDPIS")
               ENDIF
            ELSE
               IF !EMPTY(DI500Block(cAlias,"EIJ_REDPIS"))
                  nAliPis := DI500Block(cAlias,"EIJ_REDPIS")
               ENDIF
            ENDIF

            IF EIJ->(FieldPos("EIJ_ARDCOF")) # 0
               IF DI500Block(cAlias,"EIJ_ARDCOF") $ cSim  //TRP - 22/02/2010
                  nAliCof := DI500Block(cAlias,"EIJ_REDCOF")
               ENDIF
            ELSE
               IF !EMPTY(DI500Block(cAlias,"EIJ_REDCOF"))
                  nAliCof := DI500Block(cAlias,"EIJ_REDCOF")
               ENDIF
            ENDIF
         ENDIF
      ENDIF
      IF !EMPTY(nAluPis) .OR. (lAUTPCDI .AND. Work_EIJ->EIJ_TPAPIS == "2")
         Work_SW8->WKBASPIS:= 0
         //Work_SW8->WKVLRPIS:= nAluPis * IIF(lAUTPCDI,Work_EIJ->EIJ_QTUPIS,nQtde) // LDR - OC - 0048/04 - OS - 0989/04

         //** AAF 12/02/2007 - Rateio de quatidade específica da adição por quantidade do item.
         Work_SW8->WKVLRPIS:= nAluPis * IIF(lAUTPCDI,Work_EIJ->EIJ_QTUPIS,nQtde) * Work_SW8->WKQTDE / If(nPos:=aScan(aQtdAdi,{|x| x[1] == Work_SW8->WKADICAO}) > 0,aQtdAdi[nPos][2],Work_SW8->WKQTDE)

         IF lAUTPCDI
         	Work_SW8->WKVLUPIS  := nAluPis
            Work_SW8->WKPERPIS  := 0  // Zera aliquota ad. valorem por estar tratando como especifica
            Work_SW8->WKVLDEPIS := Work_SW8->WKVLRPIS
            IF Work_EIJ->EIJ_REG_PC <> "1"
               Work_SW8->WKVLRPIS := 0
            ENDIF
            nEIJ_VLDPIS+= Work_SW8->WKVLDEPIS
            nEIJ_VLRPIS+= Work_SW8->WKVLRPIS
         ENDIF
      ELSE
         Work_SW8->WKBASPIS:= DI500PISCalc(Work_SW8->WKBASEII,Work_SW8->WKBASEICM,(nAUX_II/100),(nAUX_IPI/100),(nAliqICMS/100),(nAliPis/100),(nAliCof/100),(nRedPis/100),nWZ_ICMSPC, nVlrIPIEsp,"PISCALC_DI",@nBASE_PC) //RJB //TRP - 23/02/2010//JVR - 20/05/10 - Acerto de acordo com SISCOMEX
         //Work_SW8->WKBASPIS:= DI500PISCalc(Work_SW8->WKBASEII,Work_SW8->WKBASEICM,(nAUX_II/100),(nAUX_IPI/100),(nAliqICMS/100),(nAliPis/100),(nAliIntCof/100),(nRedPis/100),nWZ_ICMSPC, nVlrIPIEsp,"PISCALC_DI",@nBASE_PC) //RJB //TRP - 23/02/2010
         Work_SW8->WKVLRPIS:= Work_SW8->WKBASPIS * (nAliPis/100)
         
         //FDR - 26/01/17
         If lCposPisMj                                                                             //GFP - 11/06/2013 - Majoração PIS
            Work_SW8->WKVLRPIS:= Work_SW8->WKBASPIS * ((nAliPis)/100)
            Work_SW8->WKVLPISM:= Work_SW8->WKBASPIS * ( nAliPisMaj/100)
         EndIf
         
         IF lAUTPCDI 
            Work_SW8->WKPERPIS  := IF(Work_EIJ->EIJ_REG_PC $ "2,6", 0, nAliPis)
         	Work_SW8->WKVLUPIS  := 0  // Zera aliquota especifica por estar tratando como ad. valorem
            Work_SW8->WKVLDEPIS := Work_SW8->WKVLRPIS

            IF Work_EIJ->EIJ_REG_PC = "4"
               IF EIJ->(FieldPos("EIJ_ARDPIS")) # 0
                  IF DI500Block("Work_EIJ","EIJ_ARDPIS") $ cSim //TRP - 22/02/2010 //!EMPTY(Work_EIJ->EIJ_REDPIS)//AWR - Seguindo a logica do Block de cima  - EMPTY(Work_EIJ->EIJ_PRB_PC)
                     Work_SW8->WKPERPIS:= Work_EIJ->EIJ_REDPIS
                     Work_SW8->WKVLRPIS:= Work_SW8->WKBASPIS * (Work_SW8->WKPERPIS/100)
                  ENDIF
               ELSE
                  IF !EMPTY(Work_EIJ->EIJ_REDPIS)
                     Work_SW8->WKPERPIS:= Work_EIJ->EIJ_REDPIS
                     Work_SW8->WKVLRPIS:= Work_SW8->WKBASPIS * (Work_SW8->WKPERPIS/100)
                  ENDIF
               ENDIF
            ENDIF

            IF Work_EIJ->EIJ_REG_PC $ "2,3,5,6"
               Work_SW8-> WKVLRPIS := 0
            ENDIF
            nEIJ_BASPIS+=nBASE_PC
            IF DI500Trans(Work_SW8->WKBASPIS) < DI500Trans(nBASE_PC)
               nEIJ_BR_PIS+=Work_SW8->WKBASPIS
            ENDIF
            nEIJ_VLDPIS+= Work_SW8->WKVLDEPIS
            nEIJ_VLRPIS+=Work_SW8->WKVLRPIS
         ENDIF
      ENDIF
      IF !EMPTY(nAluCof) .OR. (lAUTPCDI .AND. Work_EIJ->EIJ_TPACOF == "2")
         Work_SW8->WKBASCOF:= 0
         //Work_SW8->WKVLRCOF:= nAluCof * IIF(lAUTPCDI,Work_EIJ->EIJ_QTUCOF,nQtde) // ldr - OC - 0048/04 - OS - 0989/04

         //** AAF 12/02/2007 - Rateio de quatidade específica da adição por quantidade do item.
         Work_SW8->WKVLRCOF:= nAluCof * IIF(lAUTPCDI,Work_EIJ->EIJ_QTUCOF,nQtde) * Work_SW8->WKQTDE / If(nPos:=aScan(aQtdAdi,{|x| x[1] == Work_SW8->WKADICAO}) > 0,aQtdAdi[nPos][2],Work_SW8->WKQTDE)

         IF lAUTPCDI
            Work_SW8->WKVLUCOF  := nAluCof
            Work_SW8->WKPERCOF  := 0  // Zera aliquota ad. valorem por estar tratando como especifica
            Work_SW8->WKVLDECOF := Work_SW8->WKVLRCOF
            IF Work_EIJ->EIJ_REG_PC = "1"
               Work_SW8->WKVLRCOF := 0
            ENDIF
            nEIJ_VLDCOF += Work_SW8->WKVLDECOF
            nEIJ_VLRCOF += Work_SW8->WKVLRCOF
         ENDIF
      ELSE
         // Alterado para DEICMAR -> nAux_IPI é zero para calculo de COFINS MP 252 para REGIME SUSPENSAO, ISENÇAO E IMUNIDADE DE IPI - RS 05/10
         Work_SW8->WKBASCOF:= DI500PISCalc(Work_SW8->WKBASEII,Work_SW8->WKBASEICM,(nAUX_II/100),(nAux_IPI/100),(nAliqICMS/100),(nAliPis/100),(nAliCof/100),(nRedCof/100),nWZ_ICMSPC, nVlrIPIEsp,"PISCALC_DI",@nBASE_PC)//JVR - 20/05/10 - Acerto de acordo com SISCOMEX
         //Work_SW8->WKBASCOF:= DI500PISCalc(Work_SW8->WKBASEII,Work_SW8->WKBASEICM,(nAUX_II/100),(nAux_IPI/100),(nAliqICMS/100),(nAliIntPis/100),(nAliCof/100),(nRedCof/100),nWZ_ICMSPC, nVlrIPIEsp,"PISCALC_DI",@nBASE_PC) //RJB //TRP - 23/02/2010
         Work_SW8->WKVLRCOF:= Work_SW8->WKBASCOF * (nAliCof/100)

         If lCposCofMj                                                                             //NCF - 20/07/2012 - Majoração COFINS
            Work_SW8->WKVLRCOF:= Work_SW8->WKBASCOF * ((nAliCof)/100)
            Work_SW8->WKVLCOFM:= Work_SW8->WKBASCOF * ( nAliCofMaj/100)
         EndIf
         
         IF lAUTPCDI 
            Work_SW8->WKPERCOF  := IF(Work_EIJ->EIJ_REG_PC $ "2,6", 0, nAliCof)
         	Work_SW8->WKVLUCOF  := 0  // Zera aliquota especifica por estar tratando como ad. valorem
            Work_SW8->WKVLDECOF := Work_SW8->WKVLRCOF

            IF Work_EIJ->EIJ_REG_PC = "4"
               IF EIJ->(FieldPos("EIJ_ARDCOF")) # 0
                  IF DI500Block("Work_EIJ","EIJ_ARDCOF") $ cSim //TRP - 22/02/2010 //!EMPTY(Work_EIJ->EIJ_REDCOF)//AWR - Seguindo a logica do Block de cima  - EMPTY(Work_EIJ->EIJ_PRB_PC)
                     Work_SW8->WKPERCOF:= Work_EIJ->EIJ_REDCOF
                     Work_SW8->WKVLRCOF:= Work_SW8->WKBASCOF * (Work_SW8->WKPERCOF/100)
                  ENDIF
               ELSE
                  IF !EMPTY(Work_EIJ->EIJ_REDCOF)
                     Work_SW8->WKPERCOF:= Work_EIJ->EIJ_REDCOF
                     Work_SW8->WKVLRCOF:= Work_SW8->WKBASCOF * (Work_SW8->WKPERCOF/100)
                  ENDIF
               ENDIF
            ENDIF
            IF Work_EIJ->EIJ_REG_PC $ "2,3,5,6"
               Work_SW8-> WKVLRCOF := 0
            ENDIF

            nEIJ_BASCOF += nBASE_PC
            IF DI500Trans(Work_SW8->WKBASCOF) < DI500Trans(nBASE_PC)
               nEIJ_BR_COF += Work_SW8->WKBASCOF
            ENDIF
            nEIJ_VLDCOF += Work_SW8->WKVLDECOF
            nEIJ_VLRCOF += Work_SW8->WKVLRCOF
         ENDIF
      ENDIF
   ENDIF

   /*Para o calculo do ICMS e sempre utilizada a aliquota normal    // LDR */
   IF SWZ->(!EOF())
      nAliqICMS:= SWZ->WZ_AL_ICMS
      If AvFlags("ICMSFECP_DI_ELETRONICA")
         nAlICMFECP := SWZ->WZ_ALFECP
      EndIf
      If AvFlags("FECP_DIFERIMENTO")
         nAlDifFECP := SWZ->WZ_ICMSDIF
      EndIf
   ENDIF

   SB1->(dbSeek(cFilSB1+Work_SW8->WKCOD_I))
   IF lExiste_Midia .AND. lPesoMid .AND. SB1->B1_MIDIA $ cSIM .AND. lICMSMidiaDupl//AWR  - 28/06/2006

      //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
      Work_SW9->(DBSEEK(Work_SW8->WKINVOICE+WORK_SW8->WKFORN+Work_SW8->W8_FORLOJ+M->W6_HAWB))
      Work_SW8->WKBASEICM:=DI500Trans((Work_SW8->WKVL_TOTM * Work_SW9->W9_TX_FOB * 2) ,2)

   ELSEIF lExiste_Midia .AND. lPesoMid .AND. SB1->B1_MIDIA $ cSIM .AND. !EMPTY(nVlICMS)//AWR  - 28/06/2006

      Work_SW8->WKBASEICM+=DI500Trans((Work_SW8->WKQTMIDIA * WORK_SW8->WKQTDE * nVlICMS),2)

   ELSEIF lMV_PIS_EIC .AND. lMV_ICMSPIS

      //Work_SW8->WKBASEICM:=DI500ICMSCalc(,nRedICMS,nAliqICMS,Work_SW8->WKBASEII,Work_SW8->WKBASEICM,nBaseICMS,Work_SW8->WKVLII,Work_SW8->WKVLIPI,Work_SW8->WKVLRPIS,Work_SW8->WKVLRCOF,(nWZ_ICMSPC*100),"ICMSCALC_DI") //AWR 13/09/2004
      //TRP - 18/02/2010

	  //AAF 20/12/2016 - Utilizar PIS e COFINS devido para a base de icms nos casos de suspensão do imposto
      //RMD - 04/10/17 - Confirma a utilização do PIS e COFINS devido para os casos de suspensão utilizando o campo WZ_PC_ICMS
      lPisCofDev := .F.
      If SWZ->(FieldPos("WZ_PC_ICMS")) > 0
         lPisCofDev := SWZ->WZ_PC_ICMS == "1"
      EndIf
      Work_SW8->WKBASEICM:=DI154CalcICMS(,nRedICMS,If(nAliqICMS<>0,nAliqICMS,nWZ_ICMSPC),SWZ->WZ_RED_CTE,Work_SW8->WKBASEII,Work_SW8->WKBASEICM,nBaseICMS,Work_SW8->WKVLII,Work_SW8->WKVLIPI,.T.,if(DI500Block(cAlias,"EIJ_REG_PC")=="5" .And. lPisCofDev,Work_SW8->WKVLDEPIS,Work_SW8->WKVLRPIS),if(DI500Block(cAlias,"EIJ_REG_PC")=="5" .And. lPisCofDev,Work_SW8->WKVLDECOF,Work_SW8->WKVLRCOF),Work_SW8->WKOPERACA)

	  ELSE
      Work_SW8->WKBASEICM+=DI500Trans((Work_SW8->WKBASEII+Work_SW8->WKVLII+Work_SW8->WKVLIPI))
      //Work_SW8->WKBASEICM:=DI500ICMSCalc( Work_SW8->WKBASEICM, nRedICMS, nAliqICMS )
      //TRP - 18/02/2010
      Work_SW8->WKBASEICM:=DI154CalcICMS( Work_SW8->WKBASEICM, nRedICMS, nAliqICMS )
   ENDIF
    //THTS - 15/09/2017
   Work_SW8->WKVLICMDV := DI500Trans(Work_SW8->WKBASEICM * (nAliqICMS/100) )  //NCF - 11/05/2011 - Recupera o valor do ICMS Devido

   //SVG - 05/04/2010 - Não grava o valor do ICMS caso seja Drawback Suspensão e não seja Intermediário.
   If lCpsICMSPt
      //NCF - 11/05/2011 - Tratamentos de ICMS de Pauta
      aOrdSWZ := SaveOrd({"SWZ"})
      SWZ->(DbSetOrder(2))
      SWZ->(DbSeek(xFilial("SWZ")+Work_SW8->WKOPERACA))
      If cMV_CALCICM == "1"
         If !Empty(SB1->B1_VLR_ICM) .And. (!lIntDraw .OR. DI500DrawICMS())
            If !EMPTY(SWZ->WZ_TPPICMS) .And. SWZ->WZ_TPPICMS # "3"
               If SWZ->WZ_TPPICMS == "1"
                  Work_SW8->WKVLICMS := DITrans(Work_SW8->WKPESOTOT*SB1->B1_VLR_ICM,2)    //NCF - 11/05/2011 - Pauta por Peso
               ElseIf SWZ->WZ_TPPICMS == "2"
                  Work_SW8->WKVLICMS := DITrans(Work_SW8->WKQTDE*SB1->B1_VLR_ICM,2)       //NCF - 11/05/2011 - Pauta por Quantidade
               EndIf
            Else
               Work_SW8->WKVLICMS:= DI500Trans(Work_SW8->WKBASEICM * (nAliqICMS/100) )    //NCF - 15/06/2011 - Ajustes em caso de não utilização do ICMS de Pauta
            EndIf
         Else
            If !lIntDraw .OR. DI500DrawICMS()
              Work_SW8->WKVLICMS:= DI500Trans(Work_SW8->WKBASEICM * (nAliqICMS/100) )
            EndIf
         EndIf
      ElseIf cMV_CALCICM == "3"
         If !Empty(SB1->B1_VLR_ICM) .And. (!lIntDraw .OR. DI500DrawICMS())
            If !EMPTY(SWZ->WZ_TPPICMS) .And. SWZ->WZ_TPPICMS # "3"
               Work_SW8->WKVLICMDV := DI500Trans(Work_SW8->WKBASEICM * (nAliqICMS/100) )                                                    //NCF - 11/05/2011 - Recupera o valor do ICMS Devido
               If SWZ->WZ_TPPICMS == "1"
                  Work_SW8->WKVLICMS := DITrans(Work_SW8->WKPESOTOT * SB1->B1_VLR_ICM,2) + DITrans( ( nBase * (SWZ->WZ_AL_ICMS/100) ), 2 )  //NCF - 11/05/2011 - Pauta por Peso
               ElseIf SWZ->WZ_TPPICMS == "2"
                  Work_SW8->WKVLICMS := DITrans(Work_SW8->WKQTDE * SB1->B1_VLR_ICM,2) + DITrans( ( nBase * (SWZ->WZ_AL_ICMS/100) ), 2 )     //NCF - 11/05/2011 - Pauta por Quantidade
               EndIf
            Else
               Work_SW8->WKVLICMS:= DI500Trans(Work_SW8->WKBASEICM * (nAliqICMS/100) )                                                      //NCF - 15/06/2011 - Ajustes em caso de não utilização do ICMS de Pauta
            EndIf
         Else
            If !lIntDraw .OR. DI500DrawICMS()
              Work_SW8->WKVLICMS:= DI500Trans(Work_SW8->WKBASEICM * (nAliqICMS/100) )
            EndIf
         EndIf
      EndIf
      RestOrd(aOrdSWZ)
   ElseIf !lIntDraw .OR. DI500DrawICMS()
      Work_SW8->WKVLICMS:= DI500Trans(Work_SW8->WKBASEICM * (nAliqICMS/100) )
      If AvFlags("ICMSFECP_DI_ELETRONICA")
         Work_SW8->WKVLFECP := DITrans(Work_SW8->WKBASEICM*(nAlICMFECP/100),2)
         Work_SW8->WKALFECP := nAlICMFECP
      EndIf
      If AvFlags("FECP_DIFERIMENTO")
         Work_SW8->WKFECPALD := nAlDifFECP
         Work_SW8->WKFECPVLD := DITrans(Work_SW8->WKVLFECP * (nAlDifFECP/100),2)
         Work_SW8->WKFECPREC := DITrans(Work_SW8->WKVLFECP - Work_SW8->WKFECPVLD,2)
      EndIf      
   EndIf
	//THTS - 15/09/2017 - Movido
    IF TYPE("aICMS_DIF")=="A" .AND. VALTYPE(Work_SW8->WKOPERACA)=="C" .AND. LEN(aICMS_DIF) > 0 .AND. (nP:=ASCAN( aICMS_Dif, {|x| x[1] == Work_SW8->WKOPERACA} )) > 0;
                             .AND. !( SWZ->(FieldPos("WZ_TPPICMS")) > 0 .And. (SWZ->WZ_TPPICMS $ "1/2" ) )
      cSuspensao := aICMS_Dif[nP,2]
      If cSuspensao $ cSim
         Work_SW8->WKVLICMS:= 0
         If AvFlags("ICMSFECP_DI_ELETRONICA")
            Work_SW8->WKVLFECP := 0
         EndIf
         If AvFlags("FECP_DIFERIMENTO")
            Work_SW8->WKFECPVLD := 0
            Work_SW8->WKFECPREC := 0
         EndIf
      Else
         //Work_SW8->WKVLICMS:= DI500Trans(Work_SW8->WKBASEICM * (nAliqICMS/100) )  //TRP - 19/04/10
         Work_SW8->WKVLICMS:= nVal_ICM
         If AvFlags("ICMSFECP_DI_ELETRONICA")
            Work_SW8->WKVLFECP := DITrans(Work_SW8->WKBASEICM*(nAlICMFECP/100),2)
            Work_SW8->WKALFECP := nAlICMFECP
         EndIf
         If AvFlags("FECP_DIFERIMENTO")
            Work_SW8->WKFECPALD := nAlDifFECP
            Work_SW8->WKFECPVLD := DITrans(Work_SW8->WKVLFECP * (nAlDifFECP/100),2)
            Work_SW8->WKFECPREC := DITrans(Work_SW8->WKVLFECP - Work_SW8->WKFECPVLD,2)
         EndIf
      EndIf
   //NCF - 11/05/2011 - Grava o ICMS de Pauta
    EndIf

   Work_EIJ->EIJ_VLICMS+=Work_SW8->WKVLICMS

   If AvFlags("GRV_BASEICMS_DI_ELETRONICA")
      Work_EIJ->EIJ_BASICM += Work_SW8->WKBASEICM
   EndIf

   If lCpsICMSPt                                                             //NCF - 11/05/2011 - Grava o ICMS Devido da Adição
      Work_EIJ->EIJ_VLICMD+=Work_SW8->WKVLICMDV
   EndIf

   IF lZeraDespis .AND. EIJ->(FIELDPOS("EIJ_ICMSPI")) !=0
      Work_EIJ->EIJ_ICMSPI+=Work_SW8->WKICMBPIS
   ENDIF
   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"WHILE_CALC_IMPOSTOS_2"),)
   cAdicao1:= Work_SW8->WKADICAO
   Work_SW8->(DBSKIP())
ENDDO
IF lAUTPCDI .and. !lZeraDesPis
   Work_EIJ->EIJ_BASPIS := nEIJ_BASPIS
   Work_EIJ->EIJ_BR_PIS := nEIJ_BR_PIS
   Work_EIJ->EIJ_VLDPIS := nEIJ_VLDPIS
   Work_EIJ->EIJ_VLRPIS := nEIJ_VLRPIS

   Work_EIJ->EIJ_BASCOF := nEIJ_BASCOF
   Work_EIJ->EIJ_BR_COF := nEIJ_BR_COF
   Work_EIJ->EIJ_VLDCOF := nEIJ_VLDCOF
   Work_EIJ->EIJ_VLRCOF := nEIJ_VLRCOF
ENDIF

RETURN .T.

Function DI500TxSiscomex(nAdiAtual,nAdiTotal,nRateio)

LOCAL nVlrAdi:=0

If Type("lAtuTabSisc") == "L" .And. !lAtuTabSisc                          //NCF - 24/05/2011 - Para corrigir os valores da taxa de utilização do sistema siscomex no SIGAEIC
   DI500AtuTab("A")                                                       //       conforme a legislação alterada pela Portaria No. 257 do Ministério da Fazenda publicada
EndIf                                                                     //       em 23/05/2011 no Diário Oficial da União.

SYB->(DBSEEK(xFilial()+cMV_CODTXSI))// EasyGParam("MV_CODTXSI",,"415") //THTS - 13/06/2017

   IF lMV_TXSIRAT
      nVlrAdi:=(nSomaTaxaSisc*nRateio)
      RETURN nVlrAdi
   ENDIF

   IF SX5->(DBSEEK(xFilial("SX5")+"C500"))
      nVlrAdi:=VAL(SX5->X5_DESCRI)
   ENDIF

   IF(nAdiAtual>99,nAdiAtual:=99,)
   SX5->(DBSEEK(xFilial("SX5")+"C5"+STRZERO(nAdiAtual,2,0),.T.))
   nVlrAdi:=VAL(SX5->X5_DESCRI) +(nVlrAdi/nAdiTotal)

RETURN nVlrAdi

FUNCTION DI500Block(cAlias,cCampo,xValor)

IF cAlias = "M"
   RETURN EVAL(MemVarBlock(cCampo),xValor)
ENDIF

RETURN EVAL(FIELDWBLOCK(cCampo,SELECT(cAlias)),xValor)


FUNCTION DI500ValTudo(aCampos,bValid,lTeste)

LOCAL nAcrecimo:=nDeducao:=0
LOCAL nInd
DEFAULT lTeste:=.T.

FOR nInd:=1 TO LEN(aCampos)
    IF !EVAL(bValid,aCampos[nInd])
       RETURN .F.
    ENDIF
NEXT
IF lTeste
   DI500GrvCpoVisual("EIJ_EINA",@nAcrecimo,,M->EIJ_ADICAO)
   DI500GrvCpoVisual("EIJ_EIND",,@nDeducao ,M->EIJ_ADICAO)
   IF nDeducao > nAcrecimo
      Help("",1,"AVG0000715")//"Somatoria dos valores das deducoes maior que a somatoria dos valores dos acrescimos."
   ENDIF
ENDIF
RETURN .T.


FUNCTION DI_Val_EIJ(cLocalCampo,lTudo,lWhen,oCampo)//Funcao chamada do X3_VALID de varios campos

Local T, cMsgNve ,cDetNVE

DEFAULT lTudo :=.F.
DEFAULT lWhen :=.F.

IF Type("lDISimples") == "L" .AND. lDISimples
   RETURN DI500DSIValid(cLocalCampo,lTudo,lWhen,oCampo)
ENDIF

lRet:=.T.
cNomeCampo:=cLocalCampo
IF oCampo # NIL
   cNomeCampo:=oCampo:cReadvar
ENDIF
IF cNomeCampo == NIL
   cNomeCampo:=UPPER(READVAR()) // variavel private da Enchoice
ENDIF
IF Left(cNomeCampo,3) == "M->"
   cNomeCampo:=Subs(cNomeCampo,4)
ENDIF

IF lWhen
  DO CASE
  CASE "W6_" $ cNomeCampo//W6_TIPODES chama essa funcao DI_Val_EIJ(,,.T.)
     RETURN .T.

  CASE cNomeCampo == 'EIJ_EXOICM'
     IF M->EIJ_REGICM # '8'
        lRet:= .F.
     ENDIF
//****************  II ******************
  CASE cNomeCampo == 'EIJ_FUNREG'
     IF M->EIJ_REGTRI $ '1'
        lRet:= .F.
     ENDIF

  CASE cNomeCampo == 'EIJ_TACOII'
     IF M->EIJ_REGTRI $ '2,3,6,9'
        lRet:= .F.
     ENDIF

  CASE cNomeCampo == 'EIJ_ACO_II'
     IF M->EIJ_REGTRI $ '2,3,6,9' .OR. M->EIJ_TACOII # "2"//AWR - 06/2009 - Chamado P10
        M->EIJ_ACO_II:=SPACE(LEN(EIJ->EIJ_ACO_II))//AWR - 06/2009 - Chamado P10
        lRet:= .F.
     ENDIF

  CASE cNomeCampo == 'EIJ_ALA_II'
     IF M->EIJ_REGTRI $ '2,3,6.9'
        lRet:= .F.
     ENDIF

  CASE cNomeCampo == 'EIJ_PR_II'
     IF M->EIJ_REGTRI $ '1,2,3,6,9' .OR. !EMPTY(M->EIJ_ALR_II)//AWR - 06/2009 - Chamado P10
        lRet:= .F.
     ENDIF

  CASE cNomeCampo == 'EIJ_ALI_II'
     IF M->EIJ_REGTRI $ '2,6,9'
        lRet:= .F.
     ENDIF

  CASE cNomeCampo == 'EIJ_ALR_II'
     IF M->EIJ_REGTRI $ '1,2,3,6,9' .OR. !EMPTY(M->EIJ_PR_II)//AWR - 06/2009 - Chamado P10
        lRet:= .F.
     ENDIF

  CASE cNomeCampo == 'EIJ_TPAII'//AWR - 06/2009 - Chamado P10
     IF M->EIJ_REGTRI $ '2,6'
        lRet:= .F.
     ENDIF

  CASE cNomeCampo == 'EIJ_ACTAII'//AWR - 06/2009 - Chamado P10
     IF M->EIJ_REGTRI $ '2,6'
        lRet:= .F.
     ENDIF

//****************  IPI ******************

  CASE cNomeCampo == 'EIJ_CALIPI' // SVG - 29/07/09 -
     IF EIJ->(FIELDPOS("EIJ_CALIPI")) != 0 .And. !(M->EIJ_TPAIPI $ '2')
        M->EIJ_CALIPI:=""
        RETURN .F.
     ENDIF

  CASE cNomeCampo == 'EIJ_ALRIPI'
     IF M->EIJ_REGIPI $ '1,3,4,5' .OR. M->EIJ_REGTRI $ '2,6'//AWR - 06/2009 - Chamado P10
        lRet:= .F.
     ENDIF

  CASE cNomeCampo == 'EIJ_ALAIPI'
     IF M->EIJ_REGIPI $ '3' .OR. M->EIJ_REGTRI $ '2,6'//AWR - 06/2009 - Chamado P10
        lRet:= .F.
     ENDIF

  CASE cNomeCampo == 'EIJ_PRIPI'
     IF M->EIJ_REGIPI $ '1,3,4,5' .OR. M->EIJ_REGTRI $ '2,6'//AWR - 06/2009 - Chamado P10
        lRet:= .F.
     ENDIF

  CASE cNomeCampo == 'EIJ_ALUIPI'
     IF M->EIJ_REGIPI $ '2,3' .OR. M->EIJ_REGTRI $ '2,6'//AWR - 06/2009 - Chamado P10
        lRet:= .F.
     ENDIF

  CASE cNomeCampo == 'EIJ_QTUIPI'

     IF M->EIJ_REGIPI $ '2,3' .OR. M->EIJ_REGTRI $ '2,6' //AWR - 06/2009 - Chamado P10
        lRet:= .F.
     ENDIF
     IF EIJ->(FIELDPOS("EIJ_CALIPI")) != 0 .And. M->EIJ_CALIPI $ '2'
        M->EIJ_QTUIPI := 0
        RETURN .F.
     ENDIF

  CASE cNomeCampo == 'EIJ_QTRIPI'
     IF M->EIJ_REGIPI $ '2,3' .OR. M->EIJ_REGTRI $ '2,6'//AWR - 06/2009 - Chamado P10
        lRet:= .F.
     ENDIF

  CASE cNomeCampo == 'EIJ_TPRECE'
     IF M->EIJ_REGIPI $ '2,3' .OR. M->EIJ_REGTRI $ '2,6'//AWR - 06/2009 - Chamado P10
        lRet:= .F.
     ENDIF

  CASE cNomeCampo == 'EIJ_NCTIPI'
     IF M->EIJ_REGIPI $ '3' .OR. M->EIJ_REGTRI $ '2,6'//AWR - 06/2009 - Chamado P10
        lRet:= .F.
     ENDIF

  CASE cNomeCampo == 'EIJ_UNUIPI'
     IF M->EIJ_REGIPI $ '3' .OR. M->EIJ_REGTRI $ '2,6'//AWR - 06/2009 - Chamado P10
        lRet:= .F.
     ENDIF

  CASE cNomeCampo == 'EIJ_REGIPI'
     IF M->EIJ_REGTRI $ '2,6'//AWR - 06/2009 - Chamado P10
        lRet:= .F.
     ENDIF

  CASE cNomeCampo == 'EIJ_TPAIPI'
     IF M->EIJ_REGTRI $ '2,6'//AWR - 06/2009 - Chamado P10
        lRet:= .F.
     ENDIF

  CASE cNomeCampo == 'EIJ_ACTIPI'//AWR - 06/2009 - Chamado P10
     IF M->EIJ_REGTRI $ '1,2,6'
        lRet:= .F.
     ENDIF

  CASE cNomeCampo == "EIJ_FUN_PC"
     IF M->EIJ_REG_PC = "1"
        lRet:= .F.
     ENDIF

  CASE cNomeCampo == "EIJ_REDPIS"
       IF !(M->EIJ_REG_PC $ "4")
          lRet:=.F.
       ENDIF
  CASE cNomeCampo == "EIJ_REDCOF"
       IF !(M->EIJ_REG_PC $ "4")
          lRet:=.F.
       ENDIF
  CASE cNomeCampo == "EIJ_ALAPIS"
       IF M->EIJ_TPAPIS # "1" .or. M->EIJ_REG_PC $ '6'//TDF - 11/11/11 - Regime tipo '6' não incidencia
          lRet:=.F.
       ENDIF
  CASE cNomeCampo == "EIJ_ALACOF"
       IF M->EIJ_TPACOF # "1" .or. M->EIJ_REG_PC $ '6'//TDF - 11/11/11 - Regime tipo '6' não incidencia
          lRet:=.F.
       ENDIF
  CASE cNomeCampo == "EIJ_UNUPIS"
       IF M->EIJ_TPAPIS # "2" .or. M->EIJ_REG_PC $ '6'//TDF - 11/11/11 - Regime tipo '6' não incidencia
          lWhenAutPis:=.F.
       ELSE
          lWhenAutPis:=.T.
       ENDIF
       lRet := lWhenAutPis
  CASE cNomeCampo == "EIJ_ALUPIS"
       IF M->EIJ_TPAPIS # "2" .or. M->EIJ_REG_PC $ '6'//TDF - 11/11/11 - Regime tipo '6' não incidencia
          lWhenAutPis:=.F.
       ELSE
          lWhenAutPis:=.T.
       ENDIF
       lRet := lWhenAutPis
  CASE cNomeCampo == "EIJ_UNUCOF"
       IF M->EIJ_TPACOF # "2"
          lWhenAutCof:=.F.
       ELSE
          lWhenAutCof:=.T.
       ENDIF
       lRet := lWhenAutCof
  CASE cNomeCampo == "EIJ_ALUCOF"
       IF M->EIJ_TPACOF # "2"
          lWhenAutCof:=.F.
       ELSE
          lWhenAutCof:=.T.
       ENDIF
       lRet := lWhenAutCof

  CASE cNomeCampo == "EIJ_PAISEM" .OR. cNomeCampo == "EIJ_DICERT" .OR. cNomeCampo == "EIJ_ITDICE" .OR. cNomeCampo == "EIJ_QTDCER"
  	   IF VAL(M->EIJ_IDCERT) < 2
	      M->EIJ_PAISEM := SPACE(LEN(EIJ->EIJ_PAISEM))
     	  M->EIJ_DICERT := SPACE(LEN(EIJ->EIJ_DICERT))
          M->EIJ_ITDICE := SPACE(LEN(EIJ->EIJ_ITDICE))
	      M->EIJ_QTDCER := 0
  	      lRet := .F.
  	   ENDIF

  //TRP - 21/07/2010
  CASE cNomeCampo == "EIJ_ALPROP"
      IF Empty(M->EIJ_MOTADI)
         lRet:= .F.
      Endif

  CASE cNomeCampo == "EIJ_PAISOR"                           //NCF - 24/04/2012 - Validações do Campo de Pais de Origem da Adição
     If Empty(M->EIJ_PAISOR)
        MsgInfo(STR0818,STR0141)
        lRet:= .F.
     Else
        If !EXISTCPO('SYA',M->EIJ_PAISOR)
           lRet := .F.
        EndIf                                               //NCF - 24/04/2012 - Permitir que o país de origem do fornecedor seja igaul ao pais do exportador quando o fabricante é desconhecido na adição.
     EndIf

//****************  ANTIDUMPING **********  //LGS-09/10/2015
  CASE cNomeCampo == "EIJ_BAE_AD" .Or. cNomeCampo == "EIJ_ALEADU"
     If M->EIJ_TPADUM == "1"
        lRet := .F.
     EndIf

  CASE cNomeCampo == "EIJ_ALADDU"
     If M->EIJ_TPADUM == "2"
        lRet := .F.
     EndIf

  ENDCASE

  RETURN lRet
ENDIF

cNome :=AVSX3(cNomeCampo,05)
cPasta:=AVSX3(cNomeCampo,15)

lSair:=.F.
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ANT_VALID_EIJ"),)
IF lSair
   RETURN lRet
ENDIF

IF !lTudo
  DO CASE
  CASE cNomeCampo == 'EIN_CODIGO'
     lRet := .T.
     IF cTipo == '1'
        lRet := Vazio() .OR. ExistCpo("SJN",M->EIN_CODIGO)
        SJN->(DBSEEK(xFilial()+M->EIN_CODIGO))
        M->EIN_DESC:=Work_TEMP->EIN_DESC:=SJN->JN_DESC
     ELSE
        lRet := Vazio() .OR. ExistCpo("SJO",M->EIN_CODIGO)
        SJO->(DBSEEK(xFilial()+M->EIN_CODIGO))
        M->EIN_DESC:=Work_TEMP->EIN_DESC:=SJO->JO_DESC
     ENDIF
     oMarkEI:ForceRefresh()
     RETURN lRet

  CASE cNomeCampo == 'EIN_FOBMOE'
     lRet := Vazio() .OR. ExistCpo("SYF",M->EIN_FOBMOE)
     IF lRet
        //AOM - 18/03/2010
        If AllTrim(M->EIN_FOBMOE) == "R$"
           M->EIN_VLMMN:=Work_TEMP->EIN_VLMMN:= Work_TEMP->EIN_VLMLE
        Else
           M->EIN_VLMMN:=Work_TEMP->EIN_VLMMN:= Work_TEMP->EIN_VLMLE*BuscaTaxa(M->EIN_FOBMOE,dDataBase,.T.,.F.,.T.)
        EndIf
        oMarkEI:ForceRefresh()
     ENDIF
     RETURN lRet

  CASE cNomeCampo == 'EIN_VLMLE'
     lRet := Positivo(M->EIN_VLMLE)
     IF lRet
        //AOM - 18/03/2010
        If AllTrim(Work_TEMP->EIN_FOBMOE) == "R$"
           M->EIN_VLMMN:=Work_TEMP->EIN_VLMMN:= M->EIN_VLMLE
        Else
           M->EIN_VLMMN:=Work_TEMP->EIN_VLMMN:= M->EIN_VLMLE*BuscaTaxa(Work_TEMP->EIN_FOBMOE,dDataBase,.T.,.F.,.T.)
        EndIf
        oMarkEI:ForceRefresh()
     ENDIF
     RETURN lRet

  CASE cNomeCampo == 'EIM_NIVEL'// AWR - NVE - 17/10/2004

     IF Type("lTemNVE") # "L"
        RETURN lRet
     ENDIF
     IF lTemNVE // AWR - NVE - 17/10/2004
        IF EMPTY(M->EIJ_TEC)
           MSGSTOP(STR0653) //STR0653 "NCM nao preenchida."
           Return .F.
        ENDIF
        SJL->(DBSETORDER(1))
        cTECSeek:=M->EIJ_TEC
        nTamTEC:=LEN(M->EIJ_TEC)
        FOR T := 1 TO nTamTEC
           IF !SJL->(DBSEEK(xFilial()+cTECSeek))
              cTECSeek:=LEFT(M->EIJ_TEC,nTamTEC-T)+SPACE(T)
           ELSE
              EXIT
           ENDIF
        NEXT
        IF EMPTY(M->EIM_NIVEL)
           MSGSTOP(STR0654) //STR0654 "Nivel nao preenchido."
           lRet:= .F.
        ELSEIF !SJL->(DBSEEK(xFilial()+cTECSeek+TRIM(Work_GEIM->EIM_ATRIB)+TRIM(Work_GEIM->EIM_ESPECI)))
           MSGSTOP(STR0655) //STR0655 "NCM atual, Atributo e Especificacao nao tem esse Nivel."
           lRet:= .F.
        ELSEIF SJL->JL_NIVEL # M->EIM_NIVEL
           MSGSTOP(STR0655,STR0656+SJL->JL_NIVEL) //STR0655 "NCM atual, Atributo e Especificacao nao tem esse Nivel." //STR0656 "Nivel da NCM atual: "
           lRet:= .F.
        ENDIF
     ENDIF
     RETURN lRet

  CASE cNomeCampo == 'EIM_ATRIB'

     IF Type("lTemNVE") # "L"
        RETURN lRet
     ENDIF
     IF lTemNVE // AWR - NVE - 17/10/2004
        IF EMPTY(M->EIM_ATRIB)
           M->EIM_DES_AT:=Work_GEIM->EIM_DES_AT:=""
           Return .T.
        ENDIF
        IF EMPTY(M->EIJ_TEC)
           MSGSTOP(STR0653) //STR0653 "NCM nao preenchida."
           Return .F.
        ENDIF
        SJK->(DBSETORDER(1))
        cTECSeek:=M->EIJ_TEC
        nTamTEC:=LEN(M->EIJ_TEC)
        FOR T := 1 TO nTamTEC
           IF !SJK->(DBSEEK(xFilial()+cTECSeek))
              cTECSeek:=LEFT(M->EIJ_TEC,nTamTEC-T)+SPACE(T)
           ELSE
              EXIT
           ENDIF
        NEXT
        IF !SJK->(DBSEEK(xFilial()+cTECSeek+ALLTRIM(M->EIM_ATRIB)))
           MSGSTOP(STR0656) //STR0656 "NCM atual nao tem esse Atributo."
           lRet:= .F.
        ELSE
           Work_GEIM->EIM_NIVEL := SJK->JK_NIVEL //If(Empty(Work_GEIM->EIM_NIVEL),SJK->JK_NIVEL,Work_GEIM->EIM_NIVEL)
           If lEIM_NCM
              Work_GEIM->EIM_NCM := If(Empty(Work_GEIM->EIM_NCM),SJK->JK_NCM,Work_GEIM->EIM_NCM)
           EndIf
           IF SJK->JK_NIVEL # Work_GEIM->EIM_NIVEL
              MSGSTOP(STR0657,STR0656+SJK->JK_NIVEL) //STR0657 "NCM atual e Atributo nao tem esse Nivel." //STR0656 "Nivel da NCM atual: "
              lRet:= .F.
           ENDIF
        ENDIF
        M->EIM_DES_AT:=Work_GEIM->EIM_DES_AT:=SJK->JK_DES_ATR
     ELSE
        cTECSeek:=M->EIJ_TEC
        nTamTEC:=LEN(M->EIJ_TEC)
        FOR T := 1 TO nTamTEC
           IF !SJK->(DBSEEK(xFilial()+cTECSeek+M->EIM_ATRIB))
              cTECSeek:=LEFT(M->EIJ_TEC,nTamTEC-T)+SPACE(T)
           ELSE
              EXIT
           ENDIF
        NEXT
        lRet := Vazio() .OR. ExistCpo("SJK",cTECSeek+M->EIM_ATRIB)
        SJK->(DBSEEK(xFilial()+cTECSeek+M->EIM_ATRIB))
        M->EIM_DES_AT:=Work_TEMP->EIM_DES_AT:=SJK->JK_DES_ATR
        oMarkEI:ForceRefresh()
     ENDIF
     nRecWk := Work_GEIM->(Recno())
     cChave := Work_GEIM->EIM_NIVEL+M->EIM_ATRIB
     Work_GEIM->(DbGoTop())
     Do While Work_GEIM->(!Eof())
           If Work_GEIM->(Recno()) <> nRecWk .AND. Work_GEIM->EIM_NIVEL+Work_GEIM->EIM_ATRIB == cChave .And. Posicione('SJK',1,xFilial("SJK")+AvKey(M->EIJ_TEC,"JK_NCM")+AvKey(M->EIM_ATRIB,"JK_ATRIB"),'JK_MULTIPL') == 'N'
           Alert(STR0903) //"Este Atributo não pode ser duplicado pois não permite repetição." 
           Work_GEIM->(DbGoTo(nRecWk))
           Work_GEIM->EIM_DES_AT := If(Empty(Work_GEIM->EIM_ATRIB),"",Posicione("SJK",1,xFilial()+cTECSeek+Work_GEIM->EIM_ATRIB,"JK_DES_ATR"))
           Return .F.
        EndIf
        Work_GEIM->(DbSkip())
     EndDo
     SJL->(DbSetOrder(1))
     If !SJL->(DBSEEK(xFilial("SJL")+AvKey(M->EIJ_TEC,"JL_NCM")+AvKey(M->EIM_ATRIB,"JL_ATRIB")))
        Alert(STR0905) //"Não existem especificações cadastradas para este atributo!"
        Work_GEIM->(DbGoTo(nRecWk))
        Return .F.      
     EndIF
     Work_GEIM->(DbGoTo(nRecWk))
     RETURN lRet

  CASE cNomeCampo == 'EIM_ESPECI'

     IF Type("lTemNVE") # "L"
        RETURN lRet
     ENDIF
     IF lTemNVE // AWR - NVE - 17/10/2004
        IF EMPTY(M->EIM_ESPECI)
           M->EIM_DES_ES:=Work_GEIM->EIM_DES_ES:=""
           Return .T.
        ENDIF
        IF EMPTY(M->EIJ_TEC)
           MSGSTOP(STR0653)//STR0653 "NCM nao preenchida."
           Return .F.
        ENDIF
        SJL->(DBSETORDER(1))
        cTECSeek:=M->EIJ_TEC
        nTamTEC:=LEN(M->EIJ_TEC)
        FOR T := 1 TO nTamTEC
           IF !SJL->(DBSEEK(xFilial()+cTECSeek))
              cTECSeek:=LEFT(M->EIJ_TEC,nTamTEC-T)+SPACE(T)
           ELSE
              EXIT
           ENDIF
        NEXT
        IF !SJL->(DBSEEK(xFilial()+cTECSeek+Work_GEIM->EIM_ATRIB+ALLTRIM(M->EIM_ESPECI)))
           cMsgNve := STR0658 //"NCM atual e Atributo nao tem essa Especificacao."
           cDetNVE := STR0904 //"Ncm: '####',Nível: '****',Atributo: '@@@@',Especificação: '&&&&'"
           cDetNVE := StrTran(cDetNVE, "####", M->EIJ_TEC)
           cDetNVE := StrTran(cDetNVE, "****", StrTokArr(AllTrim(Posicione("SX3",2,"EIM_NIVEL","X3_CBOX")),";")[aScan(StrTokArr(AllTrim(Posicione("SX3",2,"EIM_NIVEL","X3_CBOX")),";"),{|x|Left(x,1)==Work_GEIM->EIM_NIVEL})])
           cDetNVE := StrTran(cDetNVE, "@@@@", Work_GEIM->EIM_ATRIB)
           cDetNVE := StrTran(cDetNVE, "&&&&", M->EIM_ESPECI)
           cDetNVE := StrTran(cDetNVE, ",", CHR(13)+CHR(10))
           MsgStop(cMsgNve + CHR(13)+CHR(10) + cDetNVE , STR0141)      
           RETURN .F.
        ELSE
           Work_GEIM->EIM_NIVEL := SJL->JL_NIVEL //If(Empty(Work_GEIM->EIM_NIVEL),SJL->JL_NIVEL,Work_GEIM->EIM_NIVEL)
           If lEIM_NCM
              Work_GEIM->EIM_NCM := If(Empty(Work_GEIM->EIM_NCM),SJL->JL_NCM,Work_GEIM->EIM_NCM)
           EndIf
           IF SJL->JL_NIVEL # Work_GEIM->EIM_NIVEL
              MSGSTOP(STR0655,STR0656+SJL->JL_NIVEL) //STR0655 "NCM atual, Atributo e Especificacao nao tem esse Nivel." //STR0656 "Nivel da NCM atual: "
              lRet:= .F.
           ENDIF
        ENDIF

        nRecWk := Work_GEIM->(Recno())
        cChave := Work_GEIM->EIM_NIVEL+Work_GEIM->EIM_ATRIB+M->EIM_ESPECI
        Work_GEIM->(DbGoTop())
        Do While Work_GEIM->(!Eof())
           If Work_GEIM->(Recno()) <> nRecWk .AND. Work_GEIM->EIM_NIVEL+Work_GEIM->EIM_ATRIB+Work_GEIM->EIM_ESPECI == cChave
              Alert(STR0902) //"Especificação não pode ser duplicada para um mesmo atributo que não permita repetição" 
              Work_GEIM->(DbGoTo(nRecWk))
              Work_GEIM->EIM_DES_ES := If(Empty(Work_GEIM->EIM_ESPECI),"",Posicione("SJL",1,xFilial()+cTECSeek+Work_GEIM->EIM_ATRIB+Work_GEIM->EIM_ESPECI,"JL_DES_ESP"))
              Return .F.
           EndIf
           Work_GEIM->(DbSkip())
        EndDo
        Work_GEIM->(DbGoTo(nRecWk))

        M->EIM_DES_ES:=Work_GEIM->EIM_DES_ES:=SJL->JL_DES_ESP
     ELSE
        cTECSeek:=M->EIJ_TEC
        nTamTEC:=LEN(M->EIJ_TEC)
        FOR T := 1 TO nTamTEC
           IF !SJL->(DBSEEK(xFilial()+cTECSeek+Work_TEMP->EIM_ATRIB+M->EIM_ESPECI))
              cTECSeek:=LEFT(M->EIJ_TEC,nTamTEC-T)+SPACE(T)
           ELSE
              EXIT
           ENDIF
        NEXT
        lRet := Vazio() .OR. ExistCpo("SJL",cTECSeek+Work_TEMP->EIM_ATRIB+M->EIM_ESPECI)
        SJL->(DBSEEK(xFilial()+cTECSeek+Work_TEMP->EIM_ATRIB+M->EIM_ESPECI))
        M->EIM_DES_ES:=Work_TEMP->EIM_DES_ES:=SJL->JL_DES_ESP
        oMarkEI:ForceRefresh()
     ENDIF
     RETURN lRet

  CASE cNomeCampo == 'EIN_DESC'
      If AvFlags("DUIMP") .And. SW6->W6_TIPOREG == "2"
         RETURN ''
      Else
         IF cTipo == '1'
            SJN->(DBSEEK(xFilial()+Work_TEMP->EIN_CODIGO))
            RETURN SJN->JN_DESC
         ELSE
            SJO->(DBSEEK(xFilial()+Work_TEMP->EIN_CODIGO))
            RETURN SJO->JO_DESC
         ENDIF
      EndIf

  CASE cNomeCampo == 'EIJ_REGICM'
     IF M->EIJ_REGICM # '8'
        M->EIJ_EXOICM:=SPACE(LEN(EIJ->EIJ_EXOICM))
     ENDIF

  CASE cNomeCampo == 'EIJ_REGTRI'
     DO CASE
     CASE M->EIJ_REGTRI = '1'
          M->EIJ_ALI_II:=0
          //SYD->(DBSETORDER(1))
          //SYD->(DBSEEK(xFilial()+M->EIJ_TEC+M->EIJ_EX_NCM+M->EIJ_EX_NBM))
          //IF EMPTY(M->EIJ_ALI_II)
          //   M->EIJ_ALI_II:=SYD->YD_PER_II
          //ENDIF
          M->EIJ_FUNREG:=SPACE(LEN(EIJ->EIJ_FUNREG))
          M->EIJ_ALR_II:=0
          M->EIJ_PR_II :=0
          M->EIJ_FUNREG:=SPACE(LEN(EIJ->EIJ_FUNREG))
          M->EIJ_MOTADI:=SPACE(LEN(EIJ->EIJ_MOTADI))
          M->EIJ_MOTAVM:=SPACE(LEN(SJR->JR_DESC))

     CASE M->EIJ_REGTRI $ '2,6'//AWR - 06/2009 - Chamado P10
          M->EIJ_TACOII:=SPACE(LEN(EIJ->EIJ_TACOII))
          M->EIJ_ACO_II:=SPACE(LEN(EIJ->EIJ_ACO_II))
          M->EIJ_ALA_II:=0
          M->EIJ_ALI_II:=0
          M->EIJ_ALR_II:=0
          M->EIJ_PR_II :=0
          M->EIJ_DEVII :=0
          M->EIJ_VLARII:=0
          M->EIJ_VLR_II:=0
          M->EIJ_VL_II :=0

          M->EIJ_REGIPI:= '3'//AWR - 06/2009 - Chamado P10
          DI_Val_EIJ('EIJ_REGIPI')//AWR - 06/2009 - Chamado P10
          M->EIJ_TPAIPI:= ' '//AWR - 06/2009 - Chamado P10

     CASE M->EIJ_REGTRI $ '9'//6//AWR - 06/2009 - Chamado P10
          M->EIJ_TACOII:=SPACE(LEN(EIJ->EIJ_TACOII))
          M->EIJ_ACO_II:=SPACE(LEN(EIJ->EIJ_ACO_II))
          M->EIJ_ALA_II:=0
          M->EIJ_ALI_II:=0
          M->EIJ_ALR_II:=0
          M->EIJ_PR_II :=0

        //Executar quando Nao tem Reg. Trib. ou Quando nao Tem Adicao
        //IF M->EIJ_REGTRI = '6' .AND. !lTemAdicao//AWR - 06/2009 - Chamado P10
        //   M->EIJ_REGIPI:= '3'//AWR - 06/2009 - Chamado P10
        //   DI_Val_EIJ('EIJ_REGIPI')//AWR - 06/2009 - Chamado P10
        //   M->EIJ_REGIPI:= ' '//AWR - 06/2009 - Chamado P10
        //   M->EIJ_TPAIPI:= ' '//AWR - 06/2009 - Chamado P10
        //ENDIF//AWR - 06/2009 - Chamado P10

     CASE M->EIJ_REGTRI = '3'
          M->EIJ_TACOII:=SPACE(LEN(EIJ->EIJ_TACOII))
          M->EIJ_ACO_II:=SPACE(LEN(EIJ->EIJ_ACO_II))
          M->EIJ_ALA_II:=0
          M->EIJ_ALR_II:=0
          M->EIJ_PR_II :=0
     ENDCASE
     RETURN .T.

  CASE cNomeCampo == 'EIJ_REGIPI'
     DO CASE
     CASE M->EIJ_REGIPI $ '1,4,5'
          M->EIJ_ALRIPI:=0
          M->EIJ_PRIPI :=0
          //Executar quando Tem Adicao
          IF M->EIJ_REGIPI = '4' .AND. lTemAdicao
             SYD->(DBSETORDER(1))
             SYD->(DBSEEK(xFilial()+M->EIJ_TEC+M->EIJ_EX_NCM+M->EIJ_EX_NBM))
             IF EMPTY(M->EIJ_ALAIPI)
                M->EIJ_ALAIPI:=SYD->YD_PER_IPI
             ENDIF
          ENDIF

     CASE M->EIJ_REGIPI = '2'
          M->ALUIPI    :=0
          M->EIJ_QTUIPI:=0
          M->EIJ_QTRIPI:=0
          M->EIJ_TPRECE:=SPACE(LEN(EIJ->EIJ_TPRECE))
          M->EIJ_TPREVM:=/*SPACE(LEN(EIJ->EIJ_TPREVM))*/CriaVar("EIJ_TPREVM")// TDF - 09/03/10

     CASE M->EIJ_REGIPI = '3'
          M->EIJ_ALRIPI:=0
          M->EIJ_ALAIPI:=0
          M->EIJ_QTUIPI:=0
          M->EIJ_QTRIPI:=0
          M->EIJ_TPRECE:=SPACE(LEN(EIJ->EIJ_TPRECE))
          M->EIJ_TPREVM:=/*SPACE(LEN(EIJ->EIJ_TPREVM))*/CriaVar("EIJ_TPREVM")// TDF - 09/03/10
          M->EIJ_NCTIPI:=SPACE(LEN(EIJ->EIJ_NCTIPI))
          M->EIJ_UNUIPI:=SPACE(LEN(EIJ->EIJ_UNUIPI))
          M->EIJ_PRIPI :=0
          M->ALUIPI    :=0

     ENDCASE
     RETURN .T.
  CASE cNomeCampo == "EIJ_REG_PC"
          M->EIJ_FUN_PC:=SPACE(LEN(EIJ->EIJ_FUN_PC))   //JWJ
          M->EIJ_FRB_PC:=SPACE(LEN(EIJ->EIJ_FRB_PC))

          IF M->EIJ_REG_PC $ '6'//TDF - 11/11/11 - Regime tipo '6' não incidencia
             M->EIJ_ALAPIS:=0
             M->EIJ_ALACOF:=0
          EndIf

  CASE cNomeCampo == "EIJ_TPAPIS"

      IF M->EIJ_TPAPIS = "1" .OR. M->EIJ_REG_PC $ '6' //TDF - 11/11/11 - Regime tipo '6' não incidencia
          lWhenAutPis:=.F.
          M->EIJ_QTUPIS := 0
          M->EIJ_UNUPIS := ""
          M->EIJ_ALUPIS := 0
      ELSE
          lWhenAutPis:=.T.
          M->EIJ_ALAPIS := 0
          M->EIJ_BASPIS := 0
          M->EIJ_BR_PIS := 0
          M->EIJ_VLDPIS := 0
          M->EIJ_VLRPIS := 0
      ENDIF

  CASE cNomeCampo == "EIJ_TPACOF"

      IF M->EIJ_TPACOF = "1" .OR. M->EIJ_REG_PC $ '6' //TDF - 11/11/11 - Regime tipo '6' não incidencia
          lWhenAutCof:=.F.
          M->EIJ_QTUCOF := 0
          M->EIJ_UNUCOF := ""
          M->EIJ_ALUCOF := 0
      ELSE
          lWhenAutCof:=.T.
          M->EIJ_ALACOF := 0
          M->EIJ_BASCOF := 0
          M->EIJ_BR_COF := 0
          M->EIJ_VLDCOF := 0
          M->EIJ_VLRCOF := 0
      ENDIF

  ENDCASE
ENDIF

DO CASE
CASE cNomeCampo == 'EIJ_NROVIB'
     If !Empty(M->EIJ_ASSVIB) .and. Empty(M->EIJ_NROVIB)
        Help("", 1, "AVG0000721",,cNome+STR0414+cPasta,1,8)//cNome+0414+cPasta+0415,0057) //" na pasta "###" deve ser preenchido."
        RETURN .F.
     EndIf

CASE cNomeCampo == 'EIJ_NROVIC'
     If !Empty(M->EIJ_ASSVIC) .and. Empty(M->EIJ_NROVIC)
        Help("",1,"AVG0000721",,cNome+STR0414+cPasta,1,8)//cNome+STR0414+cPasta+STR0415,STR0057) //" na pasta "###" deve ser preenchido."
        RETURN .F.
      EndIf

CASE cNomeCampo == "EIJ_DEMERC"  // EOB - 13/03/08 - campos ref. ao Mercosul
     SYA->(dbSetOrder(1))
     IF !EMPTY(M->EIJ_DEMERC) .AND. (EMPTY(M->EIJ_PAISPR) .OR. !SYA->(dbSeek(xFilial("SYA")+M->EIJ_PAISPR)) .OR. !(SYA->YA_MERCOSU $ cSim))
        MSGINFO(STR0551)
      	lRet := .F.
     ELSEIF EMPTY(M->EIJ_DEMERC)
     	M->EIJ_REINIC := SPACE(LEN(EIJ->EIJ_REINIC))
     	M->EIJ_REFINA := SPACE(LEN(EIJ->EIJ_REFINA))
     ENDIF

CASE cNomeCampo == "EIJ_REINIC"   // EOB - 13/03/08 - campos ref. ao Mercosul
     /*IF EMPTY(M->EIJ_REINIC) .AND. !EMPTY(M->EIJ_DEMERC)
        MSGINFO("A faixa dos itens que compoem a DE deve ser informada visto que existe a informação da DE. Pasta = " + cPasta)
        lRet := .F.
     */
     IF !EMPTY(M->EIJ_REINIC) .AND. EMPTY(M->EIJ_DEMERC)
        MSGINFO(STR0552)
        lRet := .F.
     ENDIF

CASE cNomeCampo == "EIJ_REFINA"  // EOB - 13/03/08 - campos ref. ao Mercosul
     IF !EMPTY(M->EIJ_REFINA) .AND. EMPTY(M->EIJ_DEMERC)
        MSGINFO(STR0552)
        lRet := .F.
     ENDIF

CASE cNomeCampo == "EIJ_IDCERT"  // EOB - 13/03/08 - campos ref. ao Mercosul - No envio do TXT para o SISCOMEX se o campo EIJ_IDCERT tiver branco, envia "1"
     IF EMPTY(M->EIJ_IDCERT) .AND. !EMPTY(M->EIJ_DEMERC)
        MSGINFO(STR0553)
        lRet := .F.
     ELSEIF !EMPTY(M->EIJ_IDCERT) .AND. M->EIJ_IDCERT <> "1" .AND. EMPTY(M->EIJ_DEMERC)//AWR - 06/2009 - Chamado P10
        MSGINFO(STR0554)
        lRet := .F.
     ENDIF

CASE cNomeCampo == "EJ9_DEMERC"
     SYA->(dbSetOrder(1))
     //TDF - 01/12/11
     IF !EMPTY(M->EJ9_DEMERC) .AND. (If(!lDECapa,EMPTY(M->EIJ_PAISPR),EMPTY(M->W6_PAISPRO)) .OR. If(!lDECapa,!SYA->(dbSeek(xFilial("SYA")+M->EIJ_PAISPR)),!SYA->(dbSeek(xFilial("SYA")+M->W6_PAISPRO))) .OR. !(SYA->YA_MERCOSU $ cSim))
        MSGINFO(STR0551)
      	lRet := .F.
     ELSEIF EMPTY(M->EJ9_DEMERC)
     	Work_TEMP->EJ9_REINIC := SPACE(LEN(EJ9->EJ9_REINIC))
     	Work_TEMP->EJ9_REFINA := SPACE(LEN(EJ9->EJ9_REFINA))
     ENDIF

CASE cNomeCampo == "EJ9_REINIC"
     IF !EMPTY(M->EJ9_REINIC) .AND. EMPTY(Work_TEMP->EJ9_DEMERC)
        MSGINFO(STR0552)
        lRet := .F.
     ENDIF

CASE cNomeCampo == "EJ9_REFINA"
     IF !EMPTY(M->EJ9_REFINA) .AND. EMPTY(Work_TEMP->EJ9_DEMERC)
        MSGINFO(STR0552)
        lRet := .F.
     ENDIF

CASE cNomeCampo == "EJ9_QTDCER"
    If lDECapa
        lRet:=.F.
    EndIF

CASE cNomeCampo == "EJ9_ITDICE"
    If lDECapa
        lRet:=.F.
    EndIF
CASE cNomeCampo == "EJ9_DICERT"
    If lDECapa
        lRet:=.F.
    EndIF
CASE cNomeCampo == "EJ9_PAISEM"
    If lDECapa
        lRet:=.F.
    EndIF

ENDCASE
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"DEPOIS_VALID_EIJ"),)

RETURN lRet

Function DI500Fil(lFil)

LOCAL cFiltro, cAlias
If lFilDa
   cAlias:=Alias()
   DbSelectArea("SW6")
   If lFil
      If MOpcao ==  FECHTO_NACIONALIZACAO
         cFiltro:="W6_FILIAL='"+xFilial("SW6")+"' .AND. W6_TIPOFEC='DIN'"
      Else
         cFiltro:="W6_FILIAL='"+xFilial("SW6")+"' .AND. W6_TIPOFEC<>'DIN'"
      EndIf
      SET FILTER TO &cFiltro
   Else
      SET FILTER TO
   EndIF

   IF EMPTY(cAlias)
      cAlias:="SW6"
   ENDIF

   DbSelectArea(cAlias)
EndIf

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"FILTRO"),)

Return .T.


Function DI500BrowseEI()//Chamado do SXB, XB_ALIAS = 'EIF'

STATIC lAcrescimo
LOCAL aTB_Campos,cTituto:=STR0267,nPos,nTam //"Manutencao de "
// BAK - Tratamento para EnchoiceBar - 18/08/2011
//LOCAL aOk:={{||IF(DI500EIValid(.T.),oDlgEI:End(),)},"OK"},
Local T
LOCAL bCancel:={|| oDlgEI:End() },nAlias:=SELECT(), cFileTemp
Local bOk := {||IF(DI500EIValid(.T.),oDlgEI:End(),)}
Private lIndAtivo := .t.   // Variavel criada para controlar indice das areas do MSGETDB (não pode ter indice ativo)
						   // ACSJ - 09/04/2004

IF SELECT("Work_EIF") = 0 .OR. SELECT("Work_EIG") = 0 .OR.;
   SELECT("Work_EIH") = 0 .OR. SELECT("Work_EII") = 0
   SELECT(nAlias)
   Help("",1,"AVG0000732")//MSGSTOP(TR0416,STR0141) //"Opcao nao Disponivel, Consulte o Processo pelo Menu."
   RETURN .T.
ENDIF

PRIVATE lValidRepetidos:= .T.,aCpos:={},nLargura:=300
PRIVATE cArq,cAliasWK,bValidEI,bWhile:={||.T.}
PRIVATE cCampo:=UPPER(READVAR())
PRIVATE bAtributo:={|| Work_TEMP->EIM_ATRIB == SJL->JL_ATRIB }//AWR - Usado no filtro do SXB do F3 do SJL no EIM_ESPECI


DO CASE
CASE "EIN_CODIGO" $ cCampo  //Capa EIJ
     IF lAcrescimo
        lREt:=ConPad1(,,,'SJN',,)
        IF lREt
           Work_Temp->EIN_CODIGO:=M->EIN_CODIGO:=SJN->JN_CODIGO
        ENDIF
     ELSE
        lREt:=ConPad1(,,,'SJO',,)
        IF lREt
           Work_Temp->EIN_CODIGO:=M->EIN_CODIGO:=SJO->JO_CODIGO
        ENDIF
     ENDIF
     RETURN .T.

CASE "W6_TIPODES" $ cCampo//Capa SW6
     IF lDISimples
        lREt:=ConPad1(,,,'SJV',,)
        IF lREt
           M->W6_TIPODES:=SJV->JV_CODIGO
        ENDIF
     ELSE
        lREt:=ConPad1(,,,'SJB',,)
        IF lREt
           M->W6_TIPODES:=SJB->JB_COD
        ENDIF
     ENDIF

     oEnCh1:Refresh()

     RETURN lREt

CASE "W6_INSTRDE" $ cCampo//Capa SW6
     cArq    :="EIF"
     cAliasWK:="Work_EIF"
     bValidEI:={|| EMPTY(EIF_CODIGO).OR.EMPTY(EIF_DOCTO)}
     nLargura:=400
     (cAliasWK)->(DBGOTOP())
     lIndAtivo := .f.  // Quando a variavel .f. é setado a ordem natural do arquivo. MSGETDB (não pode ter indice ativo)
                       // ACSJ - 09/04/2004

CASE "W6_PROCVIN" $ cCampo //Capa SW6
     cArq:="EIG"
     cAliasWK:="Work_EIG"
     bValidEI:={|| EMPTY(EIG_CODIGO).OR.EMPTY(EIG_NUMERO)}
     nLargura:=400
     (cAliasWK)->(DBGOTOP())
     lIndAtivo := .f.   // Quando a variavel .f. é setado a ordem natural do arquivo. MSGETDB (não pode ter indice ativo)
                       // ACSJ - 09/04/2004

CASE "W6_VOLUMES" $ cCampo //Capa SW6
     cArq:="EIH"
     cAliasWK:="Work_EIH"                //SVG -10-11-08
     bValidEI:={|| EMPTY(EIH_CODIGO) .OR. If(EIH_CODIGO == "37",.F.,EMPTY(EIH_QTDADE))}
     nLargura:=550
     (cAliasWK)->(DBGOTOP())
     lIndAtivo := .f.   // Quando a variavel .f. é setado a ordem natural do arquivo. MSGETDB (não pode ter indice ativo)
                       // ACSJ - 09/04/2004

CASE "W6_DEBITOS" $ cCampo //Capa SW6
     cArq:="EII"
     cAliasWK:="Work_EII"
     bValidEI:={|| EMPTY(EII_CODIGO).AND.EMPTY(EII_VLTRIB) }
     nLargura:=500
     (cAliasWK)->(DBGOTOP())
     lIndAtivo:=.F.// AWR - 18/01/2005

CASE "EIJ_EIK" $ cCampo  //Capa EIJ
     cArq:="EIK"
     cAliasWK:="Work_EIK"
     bValidEI:={|| EMPTY(EIK_TIPVIN).AND.EMPTY(EIK_DOCVIN)}
     nLargura:=400
     Work_EIK->(DBSEEK(M->EIJ_ADICAO))
     bWhile:={|| Work_EIK->EIK_ADICAO == M->EIJ_ADICAO }
     aCpos:={'EIK_ADICAO'}
     lIndAtivo:=.F.// AWR - 18/01/2005

CASE "EIJ_EIL" $ cCampo  //Capa EIJ
     cArq:="EIL"
     cAliasWK:="Work_EIL"
     bValidEI:={|| EMPTY(EIL_DESTAQ)}
     nLargura:=550
     Work_EIL->(DBSEEK(M->EIJ_ADICAO))
     bWhile:={|| Work_EIL->EIL_ADICAO == M->EIJ_ADICAO }
     aCpos:={'EIL_ADICAO'}
     lIndAtivo:=.F.// AWR - 18/01/2005

CASE "EIJ_EIM" $ cCampo  //Capa EIJ
     cArq:="EIM"
     cAliasWK:="Work_EIM"
     bValidEI:={|| EMPTY(EIM_NIVEL).AND.EMPTY(EIM_ATRIB).AND.EMPTY(EIM_ESPECI)}
     nLargura:=50
     Work_EIM->(DBSETORDER(1))
     lAchou:=Work_EIM->(DBSEEK(M->EIJ_ADICAO))
     bWhile:={|| Work_EIM->EIM_ADICAO == M->EIJ_ADICAO}
     IF lTemNVE .AND. !lAchou//AWR - NVE - 19/10/2004
        Work_EIM->(DBSETORDER(2))
        Work_EIM->(DBSEEK(M->EIJ_NVE))
        bWhile:={|| Work_EIM->EIM_CODIGO == M->EIJ_NVE}
     ENDIF
     aCpos:={'EIM_ADICAO'}
     lIndAtivo:=.F.// AWR - 18/01/2005

CASE "EIJ_EIN" $ cCampo  //Capa EIJ
     cArq:="EIN"
     cAliasWK:="Work_EIN"
     bValidEI:={|| EMPTY(EIN_CODIGO).AND.EMPTY(EIN_FOBMOE).AND.EMPTY(EIN_VLMLE)}
     nLargura:=50
     IF "EIJ_EINA" $ cCampo
        lAcrescimo := .T.
        cTipo:='1'
     ELSEIF "EIJ_EIND" $ cCampo
        lAcrescimo := .F.
        cTipo:='2'
     ENDIF
     bWhile:={|| Work_EIN->EIN_ADICAO==M->EIJ_ADICAO.AND.Work_EIN->EIN_TIPO==cTipo}
     Work_EIN->(DBSEEK(M->EIJ_ADICAO+cTipo))
     aCpos:={'EIN_ADICAO','EIN_TIPO'}//Tabelas de Campos que nao deve aparecer no MSGETDB
     lIndAtivo:=.F.// AWR - 18/01/2005

CASE "EIJ_EIO" $ cCampo  //Capa EIJ
     cArq:="EIO"
     cAliasWK:="Work_EIO"
     nLargura:=50
     bValidEI:={|| EMPTY(EIO_PGREAL).AND.EMPTY(EIO_BANCO).AND.EMPTY(EIO_PRACA ).AND.;
                   EMPTY(EIO_CAMBIO).AND.EMPTY(EIO_VLMLE).AND.EMPTY(EIO_CGCCOM).AND.;
                   EMPTY(EIO_MESANO)}
     cTipo:=RIGHT(cCampo,1)
     bWhile:={|| Work_EIO->EIO_ADICAO==M->EIJ_ADICAO.AND.Work_EIO->EIO_TIPCOB==cTipo}
     Work_EIO->(DBSEEK(M->EIJ_ADICAO+cTipo))
     //Tabelas de Campos que nao deve aparecer no MSGETDB
     aCpos:=IF(cTipo$'12',{'EIO_MESANO','EIO_TIPCOB','EIO_ADICAO'},;
                          {'EIO_PGREAL','EIO_BANCO' ,'EIO_PRACA','EIO_TIPCOB',;
                           'EIO_CAMBIO','EIO_CGCCOM','EIO_TPCOM','EIO_ADICAO'})
     IF cTipo$'13'
        AADD(aCpos,'EIO_PARCEL')
     ENDIF
     IF cTipo = '3'
        lValidRepetidos:= .F.
        nLargura:=500
     ENDIF
     lIndAtivo:=.F.// AWR - 18/01/2005

CASE "EIJ_DEMERC" $ cCampo  //TDF - 01/12/11
     If lEJ9
        cArq:="EJ9"
        cAliasWK:="Work_EJ9"
        nLargura:=550
        Work_EJ9->(DBGOTOP())
        Work_EJ9->(DBSEEK(AVKEY(M->W6_HAWB,"EJ9_HAWB")+AVKEY(M->EIJ_ADICAO,"EJ9_ADICAO")))
        bWhile:={|| ALLTRIM(Work_EJ9->EJ9_HAWB) == ALLTRIM(M->W6_HAWB) .AND. ALLTRIM(Work_EJ9->EJ9_ADICAO) == ALLTRIM(M->EIJ_ADICAO) }
        bValidEI:= {|| EMPTY(EJ9_DEMERC)}
        lValidRepetidos:= .F.
        lGravaEJ9:= .T.
        lDECapa:= .F.
     EndIf

CASE "W6_DEMERCO" $ cCampo  //TDF - 01/12/11
     If lEJ9
        cArq:="EJ9"
        cAliasWK:="Work_EJ9"
        nLargura:=550
        Work_EJ9->(DBGOTOP())
        Work_EJ9->(DBSEEK(AVKEY(M->W6_HAWB,"EJ9_HAWB")))
        bWhile:={|| ALLTRIM(Work_EJ9->EJ9_HAWB) == ALLTRIM(M->W6_HAWB)}
        bValidEI:= {|| EMPTY(EJ9_DEMERC)}
        lValidRepetidos:= .F.
        lGravaEJ9:= .T.
        lDECapa:= .T.
     EndIf
OTHERWISE

   IF DI500TelaEI()
      RETURN .T.
   ENDIF

   lSair:=.T.
   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"BROWSE_EI"),)
   IF lSair
      RETURN .T.
   ENDIF
ENDCASE

SX2->(DBSETORDER(1))
IF SX2->(DBSEEK(cArq))
   cTituto+=LOWER(FWX2Nome(cArq))
ENDIF

IF "EIJ_EIL" $ cCampo
   cTituto:=LOWER(FWX2Nome(cArq))
   cTituto:=UPPER(LEFT(cTituto,1))+SUBSTR(cTituto,2)
ENDIF
//Inicia o aHeader guardado na Array aTabelas no inicio do programa
nPos   :=ASCAN(aTabelas,{|A|A[1]==cArq})
aHeader:=ACLONE(aTabelas[nPos,5])

/* Remoção de campos criados exclusivamente para a DUIMP */
RemoveFields(aHeader, SetRemoveFields(cArq), .T.)

//** PLB 26/02/07 - Walk-Thru
SX3->( DBSetOrder(2) )
SX3->( DBSeek(cAliasWK+"_FILIAL") )
cUsado := SX3->X3_USADO
AAdd( aHeader, { "Alias WT", cArq+"_ALI_WT", "", 3,  0, NIL, cUsado, "C", cAliasWK, "" } )
AAdd( aHeader, { "Recno WT", cArq+"_REC_WT", "", 10, 0, NIL, cUsado, "N", cAliasWK, "" } )

dbSelectArea(cAliasWK)
cIndice  := (cAliasWK)->(INDEXKEY())
IF !(cAliasWK $ "Work_EJ9")
   IF AT('ADICAO',cIndice) # 0
      cIndice:= SUBSTR(cIndice,12)//Tira adicao do Indice
   ENDIF
ENDIF
IF AT('EIN_TIPO',cIndice) # 0 .OR. AT('EIO_TIPCOB',cIndice) # 0
   nPos:=AT('+',cIndice)
   cIndice:=SUBSTR(cIndice,nPos+1)//Tira Tipo do Indice
ENDIF
aStru    := DBSTRUCT()
//** PLB 26/02/07 - Walk-Thru
AAdd( aStru, { cArq+"_ALI_WT", "C", 3,   0 } )
AAdd( aStru, { cArq+"_REC_WT", "N", 10,  0 } )

aAdd(aStru,{"DBDELETE","L",1,0}) //THTS - 01/11/2017 - Este campo deve sempre ser o ultimo campo da Work
cFileTemp := E_CriaTrab(,aStru,"Work_TEMP",,,, SaveTempFiles()) //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados

IF !USED()
   Help(" ",1,"E_NAOHAREA")
   RETURN .F.
ENDIF
E_IndRegua("Work_Temp",cFileTemp+TEOrdBagExt(),cIndice)
cAliasEI:=cAliasWK
cAliasWK:="Work_TEMP"
(cAliasEI)->(DBEVAL( {|| DI500GrvTemp(.T.) }, ,bWhile))

nPos:=0
nTam:=LEN(aHeader)-LEN(aCpos)
FOR T := 1 TO LEN(aCpos)//Tira os Campos que nao deve aparecer no MSGETDB
    IF (nPos:=ASCAN(aHeader,{|H|H[2]==aCpos[T]})) # 0
       ADEL(aHeader,nPos)
       ASIZE(aHeader,LEN(aHeader)-1)
    ENDIF
NEXT
IF(nPos#0,ASIZE(aHeader,nTam),)

nPosi:=nPos_aRotina//Verefica se a MSGETDB deve aparecer com um registro em branco ou nao e serao editavel
IF Work_TEMP->(EasyRecCount("Work_TEMP")) > 0 .AND. nPos_aRotina = INCLUSAO
   nPosi:= ALTERACAO
ELSEIF Work_TEMP->(EasyRecCount("Work_TEMP")) == 0 .AND. nPos_aRotina = ALTERACAO
   nPosi:= INCLUSAO
ENDIF

If "W6_PROCVIN" $ cCampo .and. !VerifDUIMP()
   nPosi := VISUAL
EndIf

IF lTemNVE .AND. cArq == "EIM" //AWR - NVE - 17/10/2004
   nPosi:= VISUAL

   (cAliasWK)->(DBGOTOP())
   nRegistro:=0
   DO WHILE (cAliasWK)->(!EOF())
      IF (cAliasWK)->DBDELETE
         (cAliasWK)->(DBSKIP()); LOOP
      ENDIF
      nRegistro++
      (cAliasWK)->(DBSKIP())
   ENDDO

   IF EMPTY(nRegistro)
      MSGINFO(STR0799,STR0141)  //	STR0141 := "Atenção" //STR0799 "Adição não possui NVE"
      Work_TEMP->(E_EraseArq(cArq))
      SELECT(nAlias)
      DI500GrvCpoVisual(cCampo)
      RETURN .T.
   ENDIF

ENDIF
IF nPosi = VISUAL .OR. nPosi = ESTORNO
   // aOk:={{||oDlgEI:End()},STR0421} //"Sair" FDR - 16/08/2011
   bCancel:={||oDlgEI:End()}
   bOk := {||oDlgEI:End()}
ENDIF

dbSelectArea(cAliasWK)
if lIndAtivo   // ACSJ - 09/04/2004
   (cAliasWK)->(DBSETORDER(1))
Else
   (cAliasWK)->(DBSETORDER(0))
Endif
(cAliasWK)->(DBGOTOP())

//FDR - 30/01/12 - Alterando a posição do campo EIF_SEQUEN no vetor aHeader
If AllTrim(Upper(cArq)) == "EIF" .And. EIF->(FieldPos("EIF_SEQUEN")) > 0

   nPos := aScan(aHeader,{|X| AllTrim(Upper(X[2])) == "EIF_SEQUEN"})
   If nPos > 0
      aDel(aHeader,nPos)
      aIns(aHeader, 1)
      aHeader[1]:={AvSX3("EIF_SEQUEN",AV_TITULO), "EIF_SEQUEN",AvSX3("EIF_SEQUEN",AV_PICTURE), AvSX3("EIF_SEQUEN",AV_TAMANHO),AvSX3("EIF_SEQUEN",AV_DECIMAL), /*AvSX3("EIF_SEQUEN",AV_VALID)*/, NIL, AvSX3("EIF_SEQUEN",AV_TIPO), NIL, NIL }
   EndIf
EndIf

DEFINE MSDIALOG oDlgEI TITLE cTituto ;
       FROM oMainWnd:nTop   +200,oMainWnd:nLeft +1 ;
       TO   oMainWnd:nBottom-100,oMainWnd:nRight-nLargura OF oMainWnd PIXEL

  aRotina := MenuDef()  // GFP - 06/05/2013
  oMarkEI:=MsGetDB():New(15,1,(oDlgEI:nClientHeight-6)/2,(oDlgEI:nClientWidth-4)/2,nPosi,;
                     "DI500EIValid(.F.)","","",.T.,,,.F.,,cAliasWK,,.F.,,,,,"DI500DelEI(nPosi)")
  oMarkEI:oBrowse:bwhen:={||(dbSelectArea(cAliasWK),.t.)}
  oMarkEI:ForceRefresh()

  oMarkEI:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

//ACTIVATE MSDIALOG oDlgEI ON INIT (DI500EnchoiceBar(oDlgEI,aOk,bCancel,.F.),; FDR - 16/08/2011
ACTIVATE MSDIALOG oDlgEI ON INIT (EnchoiceBar(oDlgEI,bOk,bCancel,.F.),;
                                  oMarkEI:oBrowse:Refresh())  CENTERED //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

Work_TEMP->(E_EraseArq(cArq))
SELECT(nAlias)

DI500GrvCpoVisual(cCampo)

Return .T.

FUNCTION DI500DelEI(nPos)

IF nPos = VISUAL
   RETURN .F.
ENDIF
IF (cAliasWK)->DBDELETE
   RETURN .F.
ENDIF
RETURN .T.


Function DI500TelaEI()


LOCAL oDlgEI,aCposMostra,nLargura:=300,nPos,cTituto
//LOCAL aOk:={{||oDlgEI:End()},"OK"} FDR - 16/08/2011
Local bOk := {||oDlgEI:End()}
Local bCancel := {||oDlgEI:End()}
LOCAL aTelaSalve,aGetsSalve,bValid

//FDR - 16/08/2011
PRIVATE aCposAtoLegal :={'EIJ_ASSVIC','EIJ_EX_VIC','EIJ_ATOVIC','EIJ_ORGVIC','EIJ_NROVIC','EIJ_ANOVIC',;
                         'EIJ_ASSVIB','EIJ_EX_VIB','EIJ_ATOVIB','EIJ_ORGVIB','EIJ_NROVIB','EIJ_ANOVIB'}
PRIVATE aCposIIAcoTar :={'EIJ_ASSII ','EIJ_EX_II ','EIJ_ATO_II','EIJ_ORG_II','EIJ_NRATII','EIJ_ANO_II'}
PRIVATE aCposIPIAcoTar:={'EIJ_ASSIPI','EIJ_EX_IPI','EIJ_ATOIPI','EIJ_ORGIPI','EIJ_NROIPI','EIJ_ANOIPI'}

DO CASE
CASE "EIJ_ATOLEG" $ cCampo//Capa EIJ
     aCposMostra:=ACLONE(aCposAtoLegal)
     cAlias  :="EIJ"
     cTituto :=STR0268 //"Ato Legal"
     nPos    :=nPos_EIJaRotina
     lOkF3   :=.T.
     aValidF3:={'EIJ_NROVIB','EIJ_NROVIC'}
     bValid  :={|| DI500ValTudo( aValidF3,{|C| DI_Val_EIJ(C,.T.)},.F. )}
     IF nPos_EIJaRotina == ALTERACAO
        // aOk  :={{||IF(EVAL(bValid),oDlgEI:End(),)},"OK"} FDR - 16/08/2011
        bOk :={||IF(EVAL(bValid),oDlgEI:End(),)}
     ENDIF

CASE "EIJ_ACTAII" $ cCampo //Capa EIJ
     cAlias  :="EIJ"
     aCposMostra:=ACLONE(aCposIIAcoTar)
     cTituto:=STR0269 //"Acordo Tarifario de I.I."
     nPos:=nPos_EIJaRotina

CASE "EIJ_ACTIPI" $ cCampo//Capa EIJ
     cAlias  :="EIJ"
     aCposMostra:=ACLONE(aCposIPIAcoTar)
     cTituto:=STR0270 //"Beneficio Fiscal" Antigo "Acordo Tarifatório de I.P.I."  --BHF - 02/04/2009
     nPos:=nPos_EIJaRotina

OTHERWISE
   lSair:=.T.
   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"TELA_EI"),)
   IF lSair
      RETURN .F.
   ENDIF

ENDCASE

aTelaSalve:=ACLONE(aTela)
aGetsSalve:=ACLONE(aGets)
aTela:={}
aGets:={}

DEFINE MSDIALOG oDlgEI TITLE cTituto ;
       FROM oMainWnd:nTop   +200,oMainWnd:nLeft +1 ;
       TO   oMainWnd:nBottom-175,oMainWnd:nRight-nLargura OF oMainWnd PIXEL

    EnChoice( cAlias,WORK_EIJ->WK_RECNO,nPos,,,,aCposMostra,{15,1,(oDlgEI:nClientHeight-4)/2 ,(oDlgEI:nClientWidth-4)/2},,3)

//ACTIVATE MSDIALOG oDlgEI ON INIT DI500EnchoiceBar(oDlgEI,aOk,bCancel,.F.) CENTERED // FDR - 16/08/2011
ACTIVATE MSDIALOG oDlgEI ON INIT EnchoiceBar(oDlgEI,bOk,bCancel,.F.) CENTERED

aTela:=ACLONE(aTelaSalve)
aGets:=ACLONE(aGetsSalve)

Return .T.

Function DI500GrvTemp(lGravaTemp)

LOCAL nRecOld:=0
Local cAliasWT := ""
IF lGravaTemp
   Work_TEMP->(DBAPPEND())
   AVREPLACE(cAliasEI,"Work_TEMP")
   Work_TEMP->WK_RECNO:=(cAliasEI)->(RECNO())
   //** PLB 26/02/07 - Walk-Thru
   Work_TEMP->&(cArq+"_ALI_WT") := cArq
   Work_TEMP->&(cArq+"_REC_WT") := (cAliasEI)->WK_RECNO
ELSE
   nRecOld:=0
   IF EMPTY(Work_TEMP->WK_RECNO)
      (cAliasEI)->(DBAPPEND())
   ELSE
      (cAliasEI)->(DBGOTO(Work_TEMP->WK_RECNO))
      nRecOld:=(cAliasEI)->WK_RECNO
   ENDIF
   AVREPLACE("Work_TEMP",cAliasEI)
   (cAliasEI)->WK_RECNO:=nRecOld
ENDIF
RETURN .T.

Function DI500EIValid(lTudo)//Esta funcao eh chamada do X3_RELACAO

LOCAL nRec:=Work_TEMP->(RECNO())
IF(cArq=='EIF',lGravaEIF:=.T.,)
IF(cArq=='EIG',lGravaEIG:=.T.,)
IF(cArq=='EIH',lGravaEIH:=.T.,)
IF(cArq=='EII',lGravaEII:=.T.,)
IF(cArq=='EIK',lGravaEIK:=.T.,)
IF(cArq=='EIL',lGravaEIL:=.T.,)
IF(cArq=='EIM',lGravaEIM:=.T.,)
IF(cArq=='EIN',lGravaEIN:=lGravouEIN:=.T.,)
IF(cArq=='EIO',lGravaEIO:=.T.,)
PRIVATE lValidF3:=.T. //Para o Rdmake Alterar o valor

IF !lTudo
   IF Work_TEMP->DBDELETE
      RETURN .T.
   ENDIF
   IF Work_TEMP->(EVAL(bValidEI))
      HELP(" ",1,"OBRIGAT")
      RETURN .F.
   ENDIF

   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"VALID_LINHA_F3"),)

ELSEIF lTudo
   Work_TEMP->(DBGOTOP())
   aDados :={}
   (cAliasWK)->(DBSETORDER(1))
   cCampos:=Work_TEMP->(INDEXKEY())
   cCampos:="Work_TEMP->("+cCampos+")"
   if .not. lIndAtivo    // ACSJ - 09/04/2004
      (cAliasWK)->(DBSETORDER(0))
   Endif
   DO WHILE Work_TEMP->(!EOF())
      IF !Work_TEMP->DBDELETE
         IF Work_TEMP->(EVAL(bValidEI))
            HELP(" ",1,"OBRIGAT")
            Work_TEMP->(DBGOTO(nRec))
            RETURN .F.
         ENDIF
         //ACB - retirada validação para não duplicara linha com dois codigos iguais na quantidade dentro de volumes
         // na pasta DI do desembaraço, validação estava sendo feita sendo que o siscomex permite duplicar a linha
         //para inclusão da quatidade com a mesma embalagem.      ---- 22/06/2010
         SX2->(DBSETORDER(1))    //Incluido tratamento para caso o cliente não aplique o UPDATE não ira gerar erro de chave unica.
         IF SX2->(DBSEEK("EIH")) .and. !empty(FWX2Unico("EIH"))
            cConteudo:=&(cCampos)
            IF ASCAN(aDados,cConteudo) = 0
               AADD(aDados,cConteudo)
            ELSEIF lValidRepetidos
               Help("",1,"AVG0000726",,cConteudo,2,0)//MSG INFO(STR0417+cConteudo,STR0057) //"Existem registros Repetidos: "
               Work_TEMP->(DBGOTO(nRec))
               RETURN .F.
            ENDIF
         EndIf
         IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"VALID_TUDO_F3"),)
         IF !lValidF3
            RETURN .F.
         ENDIF
      ENDIF
      Work_TEMP->(DBSKIP())
   ENDDO
   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"VALID_ARQ_F3"),)
   IF !lValidF3
      RETURN .F.
   ENDIF
   DBSELECTAREA('Work_TEMP')
   Work_TEMP->(DBGOTOP())
   DO WHILE Work_TEMP->(!EOF())

      IF Work_TEMP->DBDELETE
         IF !EMPTY(Work_TEMP->WK_RECNO)
            (cAliasEI)->(DBGOTO(Work_TEMP->WK_RECNO))
            IF !EMPTY((cAliasEI)->WK_RECNO)
               IF ASCAN(aDeletados,{|D| D[1]=cArq .AND. D[2]=(cAliasEI)->WK_RECNO} ) = 0
                  AADD(aDeletados,{cArq,(cAliasEI)->WK_RECNO})
               ENDIF
            ENDIF
            (cAliasEI)->(DBDELETE())
         ENDIF
         Work_TEMP->(DBDELETE())
         Work_TEMP->(DBSKIP())
         LOOP
      ENDIF

      DI500GrvTemp(.F.)

      cFieldWk :=cArq+'_ADICAO'
      IF (cAliasEI)->((nPos:=FieldPos(cFieldWk))) # 0  //NCF - 09/11/2012 - So não deve gravar adição no caso de Tabela de DE Mercosul na capa do processo
         IF EMPTY((cAliasEI)->(FIELDGET(nPos))) .AND. !(cAliasEI == "Work_EJ9" .AND. lDECapa) //TDF - 01/12/11
            (cAliasEI)->(FIELDPUT(nPos,M->EIJ_ADICAO))
         ENDIF
         IF(cArq=='EIN'.AND.EMPTY(Work_EIN->EIN_TIPO  ),Work_EIN->EIN_TIPO  :=cTipo,)
         IF(cArq=='EIO'.AND.EMPTY(Work_EIO->EIO_TIPCOB),Work_EIO->EIO_TIPCOB:=cTipo,)
      ENDIF
      Work_TEMP->(DBSKIP())

   ENDDO
   DBSELECTAREA(cAliasEI)
   DBSETORDER(1)
   PACK
ENDIF

RETURN lValidF3


Function DI500GrvCpoVisual(cCampo,nValRealA,nValRealD,cAdicao)//Esta funcao eh chamada do X3_RELACAO

LOCAL nAlias:=SELECT(),cPict
LOCAL nRecSX3:=SX3->(RECNO())//A Funcao AVSX3() desposiciona o SX3
Local lTemNVE := EIM->(FIELDPOS("EIM_CODIGO")) # 0 .AND.;// AWR - NVE
                 SW8->(FIELDPOS("W8_NVE"))     # 0 .AND.;// AWR - NVE
                 EIJ->(FIELDPOS("EIJ_NVE"))    # 0 .AND.;// AWR - NVE
                 SIX->(dbSeek("EIM2"))

PRIVATE cInitCampo:=''


IF SELECT("Work_EIF") = 0 .OR. SELECT("Work_EIG") = 0 .OR.;
   SELECT("Work_EIH") = 0 .OR. SELECT("Work_EII") = 0
   SELECT(nAlias)
   RETURN cInitCampo
ENDIF

DO CASE
CASE "W6_INSTRDE" $ cCampo
     Work_EIF->(DBGOTOP())
     M->W6_INSTRVM:=' '
     DO WHILE Work_EIF->(!EOF())
        IF !EMPTY(Work_EIF->EIF_CODIGO) .AND. !Work_EIF->DBDELETE
           SJE->(DBSEEK(xFilial()+Work_EIF->EIF_CODIGO))
           M->W6_INSTRVM:=cInitCampo:=STR0271+ALLTRIM(SJE->JE_DESC)+"-"+ALLTRIM(Work_EIF->EIF_DOCTO) //"Tipo: "
           EXIT
        ENDIF
        Work_EIF->(DBSKIP())
     ENDDO

CASE "W6_PROCVIN" $ cCampo
     Work_EIG->(DBGOTOP())
     M->W6_PROCVVM:=' '
     DO WHILE Work_EIG->(!EOF())
        IF !EMPTY(Work_EIG->EIG_CODIGO) .AND. !Work_EIG->DBDELETE
           bCampo:=&("{||"+AVSX3('EIG_CODIGO',14,'Work_EIG')+"}")
           M->W6_PROCVVM:=cInitCampo:=STR0271+EVAL(bCampo)+"-"+ALLTRIM(Work_EIG->EIG_NUMERO) //"Tipo: "
           EXIT
        ENDIF
        Work_EIG->(DBSKIP())
     ENDDO

CASE "W6_VOLUMES" $ cCampo
     Work_EIH->(DBGOTOP())
     M->W6_VOLUMVM:=' '
     DO WHILE Work_EIH->(!EOF())
        IF !EMPTY(Work_EIH->EIH_CODIGO) .AND. !Work_EIH->DBDELETE
           SJF->(DBSEEK(xFilial()+Work_EIH->EIH_CODIGO))
           cPict:=AVSX3("EIH_QTDADE",6)
           M->W6_VOLUMVM:=cInitCampo:=ALLTRIM(TRANS(Work_EIH->EIH_QTDADE,cPict))+" "+ALLTRIM(SJF->JF_DESC)
           EXIT
        ENDIF
        Work_EIH->(DBSKIP())
     ENDDO

CASE "W6_DEBITOS" $ cCampo
     Work_EII->(DBGOTOP())
     M->W6_DEBITVM:=' '
     DO WHILE Work_EII->(!EOF())
        IF !EMPTY(Work_EII->EII_CODIGO) .AND. !Work_EII->DBDELETE
           SJH->(DBSEEK(xFilial()+Work_EII->EII_CODIGO))
           cPict:=AVSX3("EII_VLTRIB",6)
           M->W6_DEBITVM:=cInitCampo:=ALLTRIM(SJH->JH_DESC)+": R$ "+ALLTRIM(TRANS(Work_EII->EII_VLTRIB,cPict))
           EXIT
       ENDIF
       Work_EII->(DBSKIP())
     ENDDO

CASE "EIJ_EIL" $ cCampo .AND. (lTemAdicao .OR. lTemDSI)//AWR-12/10/2006-Tem que testar = ao teste da criacao das works//lTemDI//JWJ 03.10.2006: Só gravar os destaques se tem DI
     M->EIJ_EIL_VM:=' '
     Work_EIL->(DBSEEK(M->EIJ_ADICAO))
     DO WHILE Work_EIL->(!EOF()) .AND. Work_EIL->EIL_ADICAO==M->EIJ_ADICAO
        IF !EMPTY(Work_EIL->EIL_DESTAQ) .AND. !Work_EIL->DBDELETE
           M->EIJ_EIL_VM:=cInitCampo:=Work_EIL->EIL_DESTAQ
           EXIT
        ENDIF
        Work_EIL->(DBSKIP())
     ENDDO

CASE "EIJ_EIK" $ cCampo .AND. (lTemAdicao .OR. lTemDSI)//AWR-12/10/2006-Tem que testar = ao teste da criacao das works//lTemDI	//JWJ 04.10.2006
     Work_EIK->(DBSEEK(M->EIJ_ADICAO))
     M->EIJ_EIK_VM:=' '
     DO WHILE Work_EIK->(!EOF()) .AND. Work_EIK->EIK_ADICAO==M->EIJ_ADICAO
        IF !Work_EIK->DBDELETE
           bCampo:=&("{||"+AVSX3('EIK_TIPVIN',14,'Work_EIK')+"}")
           M->EIJ_EIK_VM:=cInitCampo:=STR0271+EVAL(bCampo)+"-"+ALLTRIM(Work_EIK->EIK_DOCVIN) //"Tipo: "
           EXIT
        ENDIF
        Work_EIK->(DBSKIP())
     ENDDO

CASE "EIJ_EIM" $ cCampo
     Work_EIM->(DBSETORDER(1))
     lAchou:=Work_EIM->(DBSEEK(M->EIJ_ADICAO))
     bWhile:={|| Work_EIM->EIM_ADICAO == M->EIJ_ADICAO}
     IF lTemNVE .AND. !lAchou//AWR - NVE - 19/10/2004
        Work_EIM->(DBSETORDER(2))
        Work_EIM->(DBSEEK(M->EIJ_NVE))
        bWhile:={|| Work_EIM->EIM_CODIGO == M->EIJ_NVE}
     ENDIF
     M->EIJ_EIM_VM:=' '
     DO WHILE Work_EIM->(!EOF()) .AND. EVAL(bWhile)
        IF !Work_EIM->DBDELETE
           bCampo:=&("{||"+AVSX3('EIM_NIVEL',14,'Work_EIM')+"}")
           M->EIJ_EIM_VM:=cInitCampo:=STR0272+EVAL(bCampo)+", "+ALLTRIM(Work_EIM->EIM_DES_AT)+", "+ALLTRIM(Work_EIM->EIM_DES_ES) //"Nivel: "
           EXIT
        ENDIF
        Work_EIM->(DBSKIP())
     ENDDO

CASE "EIJ_EIN" $ cCampo .AND. (lTemAdicao .OR. lTemDSI)//AWR-12/10/2006-Tem que testar = ao teste da criacao das works//lTemDI//JWJ 04.10.2006
     IF cAdicao = NIL
        cAdicao:= M->EIJ_ADICAO
     ENDIF
     nValRealA:=0
     nValRealD:=0
     cTipo:=IF("EIJ_EINA" $ cCampo,'1','2')
     Work_EIN->(DBSEEK(cAdicao+cTipo))
     DO WHILE Work_EIN->(!EOF()) .AND. Work_EIN->EIN_ADICAO==cAdicao .AND.;
                                       Work_EIN->EIN_TIPO==cTipo
        IF !Work_EIN->DBDELETE
           IF "EIJ_EINA" $ cCampo
              nValRealA+= Work_EIN->EIN_VLMMN
              //nValRealA+=Work_EIN->EIN_VLMLE*BuscaTaxa(Work_EIN->EIN_FOBMOE,dDataBase,.T.,.F.,.T.)//Work_EIN->EIN_VLMMN
           ELSE
              //nValRealD+=Work_EIN->EIN_VLMLE*BuscaTaxa(Work_EIN->EIN_FOBMOE,dDataBase,.T.,.F.,.T.)//Work_EIN->EIN_VLMMN
              nValRealD+= Work_EIN->EIN_VLMMN
           ENDIF
        ENDIF
        Work_EIN->(DBSKIP())
     ENDDO
     IF "EIJ_EINA" $ cCampo
        M->EIJ_EINAVM:=cInitCampo:="R$ "+ALLTRIM(TRANS(nValRealA,AVSX3("EIN_VLMMN",6)))
     ELSE
        M->EIJ_EINDVM:=cInitCampo:="R$ "+ALLTRIM(TRANS(nValRealD,AVSX3("EIN_VLMMN",6)))
     ENDIF

CASE "EIJ_EIO" $ cCampo .AND. (lTemAdicao .OR. lTemDSI)//AWR-12/10/2006-Tem que testar = ao teste da criacao das works//lTemDI//JWJ 04.10.2006
     cTipo:=RIGHT(cCampo,1)
     Work_EIO->(DBSEEK(M->EIJ_ADICAO+cTipo))
     IF "EIJ_EIO_1" $ cCampo
        M->EIJ_EIO1VM:=' '
     ELSEIF "EIJ_EIO_2" $ cCampo
        M->EIJ_EIO2VM:=' '
     ELSE
        M->EIJ_EIO3VM:=' '
     ENDIF
     DO WHILE Work_EIO->(!EOF()) .AND. Work_EIO->EIO_ADICAO==M->EIJ_ADICAO .AND.;
                                       Work_EIO->EIO_TIPCOB==cTipo
        IF !Work_EIO->DBDELETE
           cInitCampo:=IF(Work_EIO->EIO_PGREAL='1',STR0273,"")+; //"Pago em R$-"
                          STR0274+ALLTRIM(Work_EIO->EIO_BANCO)+; //"Bco: "
                          STR0275+ALLTRIM(Work_EIO->EIO_PRACA)+; //"-Pca: "
                          STR0276+ALLTRIM(Work_EIO->EIO_CAMBIO)+; //"-Cambio: "
                          STR0277+ALLTRIM(TRANS(Work_EIO->EIO_VLMLE,AVSX3('EIO_VLMLE',6))) //"-Vlr: "
           IF "EIJ_EIO_1" $ cCampo
              M->EIJ_EIO1VM:=cInitCampo
           ELSEIF "EIJ_EIO_2" $ cCampo
              M->EIJ_EIO2VM:=cInitCampo
           ELSE
              M->EIJ_EIO3VM:=cInitCampo:=STR0278+ALLTRIM(TRANS(Work_EIO->EIO_VLMLE,AVSX3("EIO_VLMLE",6)))+STR0279+TRANS(Work_EIO->EIO_MESANO,AVSX3('EIO_MESANO',6)) //"Valor: "###"- Data: "
           ENDIF
           EXIT
        ENDIF
        Work_EIO->(DBSKIP())
     ENDDO

// TDF - 08/06/11
CASE "EJ9_HAWB" $ cCampo

   If AvFlags("DUIMP") .And. SW6->W6_TIPOREG == "2"
      cInitCampo := SW6->W6_HAWB
   Else
      cInitCampo:= M->W6_HAWB
      M->EJ9_HAWB:= cInitCampo
   EndIf
// TDF - 08/06/11
CASE "EJ9_ADICAO" $ cCampo

   If !lDECapa
      cInitCampo:= Work_EIJ->EIJ_ADICAO
      M->EJ9_ADICAO:= cInitCampo
   Endif

//FDR - 30/01/12 - Gerando número sequencial
CASE "EIF_SEQUEN" $ cCampo

   cInitCampo:= DI500SeqInstrDe()
   M->EIF_SEQUEN := cInitCampo

CASE "EIJ_PAISDS" $ cCampo
   cInitCampo:= POSICIONE("SYA",1,XFILIAL()+Work_EIJ->EIJ_PAISOR,"YA_DESCR")
   M->EIJ_PAISDS:= cInitCampo

ENDCASE


SX3->(DBGOTO(nRecSX3))

IF EasyEntryPoint("EICDI500")
   cRDCampo:=cCampo
   Execblock("EICDI500",.F.,.F.,"GRAVA_MEMOS")
ENDIF

SX3->(DBGOTO(nRecSX3))

RETURN cInitCampo


Function DI500PROG(cPar)//Antiga EICDI400PROG(cPar)

PRIVATE lCerto:=.T. // para rdmake
//If(cPar=Nil,"M",cPar)
SW2->(DBSETORDER(1))
lGetPo:=.T.
IF MOpcao == FECHTO_NACIONALIZACAO .AND. ! (Val(SW6->W6_TIPODES) >= 14 .And. Val(SW6->W6_TIPODES) <= 16)
   Help(" ",1,"AVG0000090")
   lCerto:=.F.
ElseIf MOpcao # FECHTO_NACIONALIZACAO .AND. SW2->(DBSEEK(xFilial("SW2")+LEFT("DA"+SW6->W6_DI_NUM,LEN(SW2->W2_PO_NUM))))
   If (Val(SW6->W6_TIPODES) >= 2 .And. Val(SW6->W6_TIPODES) <= 4)
//    If cPar # "V" // Visual//ASR - 14/10/2005
         //Help(" ",1,"AVG0000098")
         //lCerto:=.F.
//    EndIf
   Else
      Help(" ",1,"AVG0000091")
      lCerto:=.F.
   EndIf
ElseIf MOpcao # FECHTO_NACIONALIZACAO .AND. SW6->W6_TIPOFEC = "DIN"
   Help(" ",1,"AVG0000091")
   lCerto:=.F.
EndIf
IF EasyEntryPoint("EICDI500")
   Execblock("EICDI500",.F.,.F.,"VALIDA_ALT_EST")
ENDIF

Return lCerto


Function DI500SelPO()//Antiga EICDISELPO()

LOCAL nOpca, cFiltro, i
Local cAliasFil:=Alias()
LOCAL bValid:={|| DI500POPLIValid(.T.,cPedido,.F.) .AND. DI500PONAC() .AND. ExistChav("SW6",M->W6_HAWB)}

lGetPo:=.F.
cPedido:=SPACE(Len(SW2->W2_PO_NUM))
M->W6_HAWB:=SPACE(Len(SW6->W6_HAWB))

cFiltro := "W2_FILIAL='"+xFilial("SW2")+"' .And. W2_HAWB_DA <> '"+Space(Len(SW2->W2_HAWB_DA))+"'"
DBSELECTAREA("SW2")
If lFilDa
   SET FILTER TO &cFiltro
   DBSELECTAREA(cAliasFil)
EndIf
nOpca:=0
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"SELPO_TELA"),) //BHF-22/05/09
DO WHILE .T.

   DEFINE MSDIALOG oDlgPONAC TITLE STR0001 From 9,0 To 24,49 OF oMainWnd //"Selecao de P.O."

   oPanel:= TPanel():New(0, 0, "", oDlgPONAC,, .F., .F.,,, 90, 165) //MCF - 22/07/2015
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   If !EasyGParam("MV_NRDI",,.F.) // SVG - 27/03/09 -
      @ 1.8,0.8 SAY AVSX3("W6_HAWB",5) OF oPanel //Processo
      @ 1.8,5  MSGET M->W6_HAWB PICTURE ALLTRIM(X3Picture("W6_HAWB")) VALID (ExistChav("SW6",M->W6_HAWB)) SIZE 60,8 OF oPanel // LRL 06/01/04
   EndIf
   @ 3.6,0.8 SAY AVSX3("W2_PO_NUM",5) OF oPanel //Pedido
   @ 3.6,5  MSGET cPedido F3 "SW2" PICTURE _PictPO SIZE 60,8 OF oPanel //LRL 06/01/04

  ACTIVATE MSDIALOG oDlgPONAC ON INIT ;
           EnchoiceBar(oDlgPONAC,{||If(Eval(bValid),(nOpca:=1,oDlgPONAC:End()),)},;
                                 {||nOpca:=0,oDlgPONAC:End()},.F.) CENTERED //FDR - 15/08/11
  If nOpca # 0
     SW2->(DBSETORDER(1))
     SW2->(DBSEEK(xFilial()+cPedido))
     SW6->(DBSETORDER(1))
     SW6->(DBSEEK(xFilial()+SW2->W2_HAWB_DA))
     cProcSave:=M->W6_HAWB
     DBSELECTAREA("SW6")
     FOR i := 1 TO FCount()
         M->&(FIELDNAME(i)) := FieldGet(i)
     NEXT i
     M->W6_HAWB   :=cProcSave
     M->W6_DI_NUM :=SPACE(LEN(SW6->W6_DI_NUM))
     M->W6_DT     :=AVCTOD("")
     M->W6_DTREG_D:=AVCTOD("")
     M->W6_DT_DESE:=AVCTOD("")
     M->W6_DT_NF  :=AVCTOD("")
     M->W6_NF_ENT :=SPACE(LEN(SW6->W6_NF_ENT))
     M->W6_VL_NF  :=0
     M->W6_PO_NUM := cPedido  // GFP - 18/03/2014
     IF !EMPTY(SW6->W6_OBS)
        cVM_OBS := MSMM(SW6->W6_OBS,AVSX3("W6_VM_OBS",03))
     ENDIF
     IF !EMPTY(SW6->W6_COMPLEM)
        cVM_COMP:= MSMM(SW6->W6_COMPLEM,AVSX3("W6_VM_COMP",03))
     ENDIF

     IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GRAVA_MEMO_EM_VAR"),) // JBS - 28/11/2003

     DI500POFIL()
     lGetPo:=.T.
     Return .T.

  ENDIF

  EXIT

ENDDO

Return .F.


Function DI500PONAC() //Antiga DI_PONAC()

Local lRet:=.T.
SW6->(DBSETORDER(1))
If ! SW6->(DBSEEK(xFilial()+SW2->W2_HAWB_DA))
   Help(" ",1,"AVG0000099")
   lRet := .F.
EndIf
Return lRet


Function DI500POFIL()

If lFilDa
   cAliasFil:=Alias()
   DBSELECTAREA("SW2")
   SET FILTER TO
   IF !EMPTY(cAliasFil)  //TRP-05/11/2007
      DBSELECTAREA(cAliasFil)
   ELSE
      DBSELECTAREA("SW6")
   ENDIF
EndIf
Return .T.


FUNCTION DI500GrvTRB(lEstorno)

LOCAL lSuframa:=AvFlags("SUFRAMA"),nCont:=0
LOCAL cFilSW7:=xFilial("SW7"), cFilSW8:=xFilial("SW8")
LOCAL cFilSA2:=xFilial("SA2")
LOCAL cFilSB1:=xFilial("SB1")
LOCAL cFilSWP:=xFilial("SWP")
LOCAL cFilSW9:=xFilial("SW9")
LOCAL cFilSW4:=xFilial("SW4")
LOCAL cFilSYX:=xFilial("SW4")
Local nCountReg:= 0

TRB->(avzap())

nCont:= EasyQryCount("select W7.W7_FILIAL from " + RetSQLName("SW7") + " W7 where W7.W7_FILIAL = '" + cFilSW7 + "' and W7.W7_HAWB = '" + SW6->W6_HAWB + "' and " + If(TcSrvType() <> "AS/400", " W7.D_E_L_E_T_ <> '*' ", " W7.@DELETED@ <> '*' "))
ProcRegua(nCont)

SWP->(DBSETORDER(1))
SYX->(DBSETORDER(3))
SW2->(DBSETORDER(1))
SW4->(DBSETORDER(1))
SW7->(DBSETORDER(1))
SW7->(DBSEEK(cFilSW7+SW6->W6_HAWB))
SW2->(DBSEEK(xFilial()+SW7->W7_PO_NUM))

DO WHILE !SW7->(EOF())             .AND.;
         SW7->W7_FILIAL == cFilSW7 .AND.;
         SW7->W7_HAWB   == SW6->W6_HAWB

  IncProc(STR0077+ALLTRIM(SW7->W7_COD_I))//"LENDO ITENS DA D.I.: "

  SWP->(DBSEEK(cFilSWP+SW7->W7_PGI_NUM+SW7->W7_SEQ_LI))
  SB1->(DBSEEK(cFilSB1+ SW7->W7_COD_I))

  TRB->(DBAPPEND())
  TRB->W7_SEQ_LI := SW7->W7_SEQ_LI
  TRB->W7_PGI_NUM:= SW7->W7_PGI_NUM
  TRB->WP_REGIST := SWP->WP_REGIST
  TRB->WP_VENCTO := SWP->WP_VENCTO
  TRB->W7_COD_I  := SW7->W7_COD_I
  TRB->W5_DESC_P := MSMM( SB1->B1_DESC_GI,AvSx3("B1_VM_GI",3),1 )

  //FSM - 01/08/2011 - "Peso Bruto Unitário"
  If lPesoBruto
     TRB->WKW7PESOBR := SW7->W7_PESO_BR
  EndIf
  TRB->W7_PO_NUM := SW7->W7_PO_NUM
  TRB->W7_CC     := SW7->W7_CC
  TRB->W7_SI_NUM := SW7->W7_SI_NUM
  TRB->W7_FABR   := SW7->W7_FABR
  If EICLoja()
     TRB->W7_FABLOJ := SW7->W7_FABLOJ
  EndIf
  TRB->W7_POSICAO:= SW7->W7_POSICAO
  TRB->W7_PESO   := SW7->W7_PESO
  TRB->W7_NCM    := SW7->W7_NCM
  TRB->W7_EX_NCM := SW7->W7_EX_NCM
  TRB->W7_EX_NBM := SW7->W7_EX_NBM
  TRB->TRB_ALI_WT:= "SW7"
  TRB->TRB_REC_WT:= SW7->(Recno())
  IF lEstorno
     TRB->WKRECNO   :=SW7->(RECNO())
     TRB->W5_PGI_NUM:=SW7->W7_PGI_NUM
     TRB->W7_REG    :=SW7->W7_REG
  ENDIF

  IF lSuframa
     SW4->(DBSEEK(cFilSW4+SW7->W7_PGI_NUM))
     IF !EMPTY(SW4->W4_PROD_SU)
        IF SYX->(DBSEEK(cFilSYX+SW4->W4_PROD_SU+SW7->W7_COD_I))
           TRB->W5_DESC_P := MEMOLINE( SYX->YX_DES_ZFM,36,1 )
        ENDIF
     ENDIF
   ENDIF

  SA2->(DBSEEK(cFilSA2+SW7->W7_FABR+EICRetLoja("SW7", "W7_FABLOJ")))

  TRB->W5_FABR_N := SA2->A2_NREDUZ
  TRB->W7_FORN   := SW7->W7_FORN
  If EICLoja()
     TRB->W7_FORLOJ := SW7->W7_FORLOJ
  EndIf

  SA2->(DBSEEK(cFilSA2+SW7->W7_FORN+EICRetLoja("SW7", "W7_FORLOJ")))

  TRB->W5_FORN_N := SA2->A2_NREDUZ
  TRB->W7_QTDE   := SW7->W7_QTDE
  TRB->W7_PRECO  := SW7->W7_PRECO
  TRB->W6_FOB_TOT:= SW7->W7_QTDE*SW7->W7_PRECO
  TRB->W9_INVOICE:= SW8->(PesqIVH(SW7->W7_HAWB,SW7->W7_COD_I,SW7->W7_FABR,;
                                  SW7->W7_FORN,SW7->W7_PGI_NUM,SW7->W7_SI_NUM,;
                                  SW7->W7_PO_NUM,SW7->W7_CC,SW7->W7_REG,EICRetLoja("SW7", "W7_FABLOJ"),EICRetLoja("SW7", "W7_FORLOJ")))
  IF AvFlags("EIC_EAI")//AWF - 25/06/2014 - Carrega Segunda unidade para Visualização
     aSegUM:=Busca_2UM(SW7->W7_PO_NUM,SW7->W7_POSICAO)
     IF LEN(aSegUM) > 0
        TRB->WKUNI    :=aSegUM[1]
        TRB->WKSEGUM  :=aSegUM[2]
        TRB->WKFATOR  :=aSegUM[3]
        TRB->WKQTSEGUM:=TRB->W7_QTDE*TRB->WKFATOR
     ENDIF
  ENDIF
  IF !EMPTY(TRB->W9_INVOICE)
     nPos := AT("+",TRB->W9_INVOICE)
     IF nPos # 0
        SW9->(DBSEEK(cFilSW9+SUBST(TRB->W9_INVOICE,1,nPos-1)+TRB->W7_FORN+EICRetLoja("TRB", "W7_FORLOJ")+SW7->W7_HAWB))
     ELSE
        SW9->(DBSEEK(cFilSW9+TRB->W9_INVOICE+TRB->W7_FORN+EICRetLoja("TRB", "W7_FORLOJ")+SW7->W7_HAWB))
     ENDIF
     TRB->W9_DT_EMIS:=SW9->W9_DT_EMIS

     SW8->(dbSetOrder(6))

     //AAF 27/09/05 - Campo TRB->W9_INVOICE pode possuir mais um Nro. de Invoice.
     //If SW8->(dbSeek(cFilSW8+SW7->W7_HAWB+TRB->W9_INVOICE+SW7->W7_PO_NUM+SW7->W7_POSICAO+SW7->W7_PGI_NUM))
     If SW8->(dbSeek(cFilSW8+SW7->W7_HAWB+SW9->W9_INVOICE+SW7->W7_PO_NUM+SW7->W7_POSICAO+SW7->W7_PGI_NUM))
        If lIntDraw
           TRB->W5_AC := SW8->W8_AC
        EndIf
        If lOperacaoEsp //AOM - 15/04/2011 - Operacao Especiais
           TRB->W8_CODOPE := SW8->W8_CODOPE
        EndIf
     EndIf

  ENDIF

  IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GRAVA_TRB"),)

  SW7->(DBSKIP())
ENDDO
SYX->(dBSETORDER(1))
TRB->(DBGOTOP())

DI500EIGrava('LEITURA',SW6->W6_HAWB,aAliasCapa)

RETURN .T.

FUNCTION PesqIVH(PHawb,PItem,PFabr,PForn,PPGi,PSi,PPo,PCc,PReg,PFABLoj, PForLoj)//Usada por EICNA400 - Entreposto

LOCAL MCont := 0 , PInvoice := SPACE(LEN(SW8->W8_INVOICE))
LOCAL cChave:=PHawb+PPgi+PPo+PSi+PCc+PItem+STR(PReg,AVSX3("W1_REG",3),0)
LOCAL cFilSW8:=xFilial("SW8")
Default PFABLoj := "", PForLoj := ""

SW8->(DBSETORDER(3)) //W8_FILIAL+W8_HAWB+W8_PGI_NUM+W8_PO_NUM+W8_SI_NUM+W8_CC+W8_COD_I+STR(W8_REG,4,0)
SW9->(DBSetOrder(1)) //W9_FILIAL+W9_INVOICE+W9_FORN+W9_FORLOJ+W9_HAWB

If cFilSW8 + cChave == SW8->(W8_FILIAL+W8_HAWB+W8_PGI_NUM+W8_PO_NUM+W8_SI_NUM+W8_CC+W8_COD_I+STR(W8_REG,4,0)) .Or. SW8->(DBSEEK(cFilSW8+cChave))

   If SW8->(W8_FILIAL + W8_INVOICE) + PForn + PForLoj + PHawb == SW9->(W9_FILIAL+W9_INVOICE+W9_FORN+W9_FORLOJ+W9_HAWB) .Or. SW9->(DBSeek(xFilial() + SW8->W8_INVOICE + PForn + PForLoj + PHawb))
      PInvoice:= SW8->W8_INVOICE
      //MFR OSSME-5299 05/11/2020
      SW8->(DbSkip())
      if SW8->(!Eof()) .And. cFilSW8 + cChave == SW8->(W8_FILIAL+W8_HAWB+W8_PGI_NUM+W8_PO_NUM+W8_SI_NUM+W8_CC+W8_COD_I+STR(W8_REG,4,0)) 
         PInvoice:='Diversas'
      EndIf
      SW8->(DbSkip(-1))
   EndIf

EndIf

RETURN PInvoice


FUNCTION DI500Final()//Antiga DI_Final(bCloseAll)

Local W
SW4->(DBSETORDER(1))
SW7->(DBSETORDER(1))
SW8->(DBSETORDER(1))
SW9->(DBSETORDER(1))
SY9->(DBSETORDER(1))
SA5->(DBSETORDER(1))
SWZ->(DBSETORDER(1))
SX3->(DBSETORDER(1))

FOR W := 1 TO LEN(aDelFile)
   cAlias:=aDelFile[W,1]
   cArq  :=aDelFile[W,2]
   IF cAlias # NIL .AND. Select(cAlias) > 0
      (cAlias)->(E_EraseArq(cArq,,,SaveTempFiles())) //wfs mai/2017 - adequação para uso do EECEraseArq(), com a passagem do 4º parâmetro 
   ELSE
      /* wfs mai/2017 - adequação para uso do EECEraseArq(), com a passagem do 4º parâmetro */
      If SaveTempFiles()
         E_EraseArq(cArq,,,SaveTempFiles())
      Else
         FERASE(cArq+TEOrdBagExt())
      EndIf
   ENDIF
NEXT

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"DI500FINAL"),)

DBSELECTAREA("SW6")

RETURN .T.


Function DI500GrvCapa(bValid)//Antiga DI400Atu(bValid)

LOCAL nWk,i   // ACSJ - 15/07/2004 - é obrigatório declarar a variavei de contagem do comando For/Next como local.
Local aChaves := {},cPos := "", cTipParc := ""
Local aOrdSW7Tmp := {} //NCF - 14/10/2016
Private cRegDI:= "" //AAF 12/09/05 - Indica se há registro de DI. Utilizado para controle do Drawback.
Private lAltDtReg := .F.  // PLB 19/12/06 - Indica se a Data de Reg. da DI foi alterada -> Drawback
lTitEAI_OK := .T. //JL - Incluida a validação

If !Obrigatorio(aGetsW6,aTela) .or. !Eval(bValid)
   RETURN .F.
Endif
//
If	lInvAnt	//---	Rotina de Invoice Antecipada LIGADA
	If	!DI500ChkEW4()
		//---	Se houve inconsistências no teste contra a tabela de capa da Invoice Antecipada, SAI sem permitir a gravação
		RETURN	.F.
	EndIf
EndIf
//
cPergunte:=STR0280
lRetorno:=.F.
lSair:=.F.
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ANTES_CONF_CAPA"),)
IF lSair
   RETURN lRetorno
EndIf

If AvFlags("WORKFLOW")
   aChaves := EasyGroupWF("EMBARQUE_EIC")
EndIf

If Mopcao != FECHTO_EMBARQUE
    RETURN DI500Itens(.T.)
Else
    IF !lGravaSoCapa
        RETURN DI500_Grava()
    ENDIF
EndIf

If MsgYesNo(cPergunte,STR0141)//'Capa da D.I.' //"Confirma a gravacao somente da capa do processo?"

   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ANT_GRAVA_CAPA"),)

   If !VldOpeDesemb("BTN_PRINC_EMB")
      Return .F.
   EndIf

   IF lFinanceiro .Or. lAvIntDesp
      axFlDelWork:={}
      TP251CriaWork()
      axFl2DelWork:={}
      TP252CriaWork()
   ENDIF

   If lAvIntDesp//AWR - 2011/06/01 - O AVINTEG deve ser executado fora do Begin Transaction
      oDI500IntProv := AvIntProv():New()
   EndIf

   //AAF 25/09/2014 - Integração de exclusão dos titulos deve ocorrer antes da transaction, para evitar que um erro de integração faça roolback nos titulos ja excluídos.
   If AvFlags("EIC_EAI") //.AND.( !EasyGParam("MV_EIC0049",,.F.) .OR. (!EMPTY(M->W6_DT_NF)))// Só enviar a gravação se os titulos foram excluidos com sucesso
      lTitEAI_OK := .T.
      IF !EICAP110(.T.,5,M->W6_HAWB,"D")
         lTitEAI_OK := .F.
         Return .F.
      ENDIF
   ENDIF

    // TDF - 15/08/11 - Não permitir alterações que gerem movimentações financeiras de acordo com o MV_DATAFIN
	If lFinanceiro .And. FI400DIAlterou(M->W6_HAWB,"A")
        If EasyGParam("MV_DATAFIN") > DDATABASE
            MsgInfo(STR0574 + ENTER + STR0575, STR0057)
            Return .F.
        EndIf
    EndIf

   Begin Transaction

	 If EasyGParam("MV_EASYFIN",,"N") == "S" .OR. lAvIntDesp
        EICFI400("ANT_GRV_DI","A")
     EndIf
     //** BHF - 08/12/08
     If lGravaFin_EIC .And. FI400DIAlterou(M->W6_HAWB,"A")
       FI400ANT_DI(M->W6_HAWB,.F.,lGravaFin_EIC)
	 EndIf

    //Jacomo Lisa - Incluida a Validação para integração dos Pedidos no Logix
    IF ( ( !EMPTY(M->W6_DT_ENTR) .OR. !EMPTY(SW6->W6_DT_ENTR) ).AND. (M->W6_DT_ENTR <> SW6->W6_DT_ENTR) ) .OR.; // Caso W6_DT_ENTR estiver preenchido e esteja diferente da fisica
       ( ( !EMPTY(M->W6_PRVENTR) .OR. !EMPTY(SW6->W6_PRVENTR) ).AND. (M->W6_PRVENTR <> SW6->W6_PRVENTR) ) //Pegar a data prevista
       aOrdSW7Tmp := SaveOrd("SW7")
       SW7->(DbSetOrder(4))
       SW7->(DBSEEK(xFilial("SW7")+M->W6_HAWB))
       DO WHILE SW7->(!EOF()) .AND. SW7->W7_HAWB   == M->W6_HAWB .AND. SW7->W7_FILIAL == xFilial("SW7")
          IF ascan(aEnv_PO,SW7->W7_PO_NUM + SW7->W7_POSICAO) == 0
             aadd(aEnv_PO,SW7->W7_PO_NUM + SW7->W7_POSICAO)
          ENDIF
          SW7->(DBSKIP())
       ENDDO
       RestOrd(aOrdSW7Tmp,.T.)
    ENDIF


    //wfs 10/12/13
    //A função DI500GrvSW6() foi alterada para dentro do ELSE, evitando dupla baixa do ato concessório quando realizada a gravação da capa do processo
    lChangeEmb := (nOPC_mBrw == 3 .AND. !EMPTY(M->W6_DT_EMB)) .OR.  (nOPC_mBrw <> 3 .AND. M->W6_DT_EMB <> SW6->W6_DT_EMB) 	//IGOR CHIBA se for inclusao e data preenchida ou se for alteracao e data diferente
    IF AvFlags("EIC_EAI") .AND. lTitEAI_OK//.AND.( !EasyGParam("MV_EIC0049",,.F.) .OR. (!EMPTY(M->W6_DT_NF)))-- Jacomo Lisa - 08/08/2014 - Verifica se teve alteração antes de Gravar o Processo
       //lIntEnvia := ValEnvCBO("D",.F.,.T.)//ValEnvCBO(cFase,lJumpVal,lJustVal)
       cTipParc    := ValEnvCBO("D",.F.,.T.)
    ENDIF
     //wfs 10/12/13
     //A função DI500GrvSW6() foi alterada para dentro do ELSE, evitando dupla baixa do ato concessório quando realizada a gravação da capa do processo
    If Work->(EasyRecCount("Work")) > 0  // SVG - 09/04/09 -
        DI500GravaTudo()
    Else
     	// ** BHF
     	Processa({|| DI500GrvSW6("2") },STR0281) //"Gravacao da Capa..."
     	lDI500GrvSW6:= .T.
        If lOperacaoEsp
           oOPeracao:SaveOperacao()//AOM - Operacao especial - Caso for gravação da capa executa a operação especial
        EndIf

        //igor chiba  02/04/14 contabilizacao
        IF EasyGParam("MV_EIC_ECO",,'N') == 'N'  .AND. EasyGParam('MV_EIC0047',,.F.) .And. FindFunction("L500GERCTB") //se o modulo sigaeco estiver desligado
          //IGOR CHIBA ESTORNO CONTABIL NO CASO DE ALTERA SOMENTE CAPA
          IF nOPC_mBrw <> 3  .and. lChangeEmb .And. FindFunction("L500RETREG")//!EMPTY(SW6->W6_DT_EMB)//IF !EMPTY(SW6->W6_DT_EMB)
             //aRegs:=L500RETREG(xFilial("SW6"),SW6->W6_HAWB,"'101','501','504'",'')//comentado por wfs
             aRegs:=L500RETREG(xFilial("SW6"),SW6->W6_HAWB,"'101','111','501','512','504','513'",'')//processos sem cobertura cambial
             L500CANCTB(aRegs)
          ENDIF
          IF !EMPTY(SW6->W6_DT_EMB)
             L500GERCTB('TE')
          ENDIF
       ENDIF

    EndIf

    End Transaction //LRS - 12/07/2017

    EICFI400("POS_GRV_DI","I")  // SVG - 05/02/2011 - Alteração dos titulos, pode ter havido alteração na data de embarque.

     If AvFlags("WORKFLOW")     //*** GFP 28/03/2011 - 14:45 - Inclusão de verificação de WorkFlow
        EasyGroupWF("EMBARQUE_EIC",aChaves)
     EndIf

   //AAF 25/09/2014 - Integração de inclusão de titulo via EAI deve ocorrer após a transaction, pois não é impeditiva para gravação.
   If AvFlags("EIC_EAI") .AND. lTitEAI_OK .AND. !EMPTY(cTipParc)//.AND. (!EasyGParam("MV_EIC0049",,.F.) .OR. (!EMPTY(M->W6_DT_NF)) ) .AND. lIntEnvia// Só enviar a gravação se os titulos foram excluidos com sucesso
      IF !EICAP110(.T.,3,M->W6_HAWB,"D",cTipParc,.T.) //EICAP110(lEnvio,nOpc,cHawb,cFaseAP,cTipParc,lJumpVal,cTipo,aAltParc,cTabAlias)
         lTitEAI_OK := .F.
      ENDIF
   ENDIF

   If lAvIntDesp//AWR - 2011/06/01 - O AVINTEG deve ser executado fora do Begin Transaction
      oDI500IntProv:Grava()
      oDI500IntProv := NIL
   EndIf

//***** DELETAR ARQUIVO DA FUNCAO AV POS_DI() E AVPOS_PO(), QDO TEM CONTROLE DE TRANSACAO
   IF lFinanceiro
      If Select("WorkTP") # 0
         IF TYPE("axFl2DelWork") = "A" .AND. LEN(axFl2DelWork) > 0
            WorkTP->(E_EraseArq(axFl2DelWork[1]))
            FOR nWk:=2 TO LEN(axFl2DelWork)
                FERASE(axFl2DelWork[nWk]+TEOrdBagExt())
            NEXT
         ENDIF
      ENDIF
      //JMS - 23/06/04 - PARA APAGAR OS ARQUIVOS DO EICTP251.
      If Select("Work_1") # 0 .AND. Select("Work_2") # 0
         IF TYPE("axFlDelWork") = "A" .AND. LEN(axFlDelWork) > 0
            Work_1->(E_EraseArq(axFlDelWork[1]))
            Work_2->(E_EraseArq(axFlDelWork[3]))
            FOR nWk:=2 TO LEN(axFlDelWork)
                FERASE(axFlDelWork[nWk]+TEOrdBagExt())
            NEXT
         ENDIF
      ENDIF
   ENDIF
//*******************

   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"POS_GRAVA_CAPA"),)
   aEnv_PO:= PO420PedOri(aEnv_PO) //NCF - 17/10/2016
   //Como o objetivo é reenviar a programação de entregas, não faz sentido reenviar atualização do pedido se houver nota fiscal gerada ou se o processo tiver sido encerrado.
   IF AvFlags("EIC_EAI")
      
      If Empty(M->W6_NF_ENT) .and. Len(aEnv_PO) > 0
      
         For i = 1 To Len(aEnv_PO) //SSS -  REG 4.5 03/06/14
            /* Verifica se existem pedidos originados por processo de entreposto e
               retorna os pedidos válidos para a geração da programação de entregas*/
            If !EICPO420(.T.,4,,"SW2",.F.,aEnv_PO[I])// EICPO420(lEnvio,nOpc,aCab,cAlias,lWk,cPo_num)
               cPos+=ALLTRIM(aEnv_PO[I])+", "
            EndIf
         Next
         If !Empty(cPos)
            MsgInfo("Acesse os Purchase orders "+cpos+" para realização dos ajustes necessários.")
         EndIf
         aEnv_PO:= {}
      
      EndIf

      /* Atualização do status do processo */
      AP110AtuStatus(M->W6_HAWB, .T.)
   ENDIF
   Return .T.
Endif

Return .F.

Function ValCoEnc()
 //MFR 08/10/2020 OSSME-5138
 Local cCampo:=UPPER(READVAR())
 IF Left(cCampo,3) == 'M->'
   cCampo:=Subs(cCampo,4)
 ENDIF
 Do Case  
   CASE cCampo == 'W6_IMPCO' .or. cCampo == 'W6_IMPENC'
      IF M->W6_IMPCO == '1'.AND. M->W6_IMPENC == '1'
         MSGINFO(STR0906) // "Pedido nao pode ser Conta e Ordem e Encomenda ao mesmo tempo."
         Return .F.
      ENDIF
      IF cCampo == 'W6_IMPENC'
         if DI500ValCE("IMPENC") //se retornar true é pq tem itens em PO com o cmpo IMPENC diferente //p2
            IF M->W6_IMPENC == '2'
               Alert(STR0813) //STR0813 'Pedido tem que ser de encomenda'
            ELSE
               Alert(STR0814)//STR0814 'Pedido nao pode ser de encomenda'
            EndIf
            Return .F.
         EndIf
      EndIf
EndCase
Return .t.

FUNCTION DI_Valid(cLocalCampo,lPasta,lOK)//Funcao chamada do X3_VALID de varios campos

Local cPasta:=''
Local lLibQt  := GETNEWPAR("MV_LIBQTEM", .F.)
//** GFC - 28/11/05 - Câmbio de frete, seguro, comissão e embarque
Local aJaCom:={}, nJaCom:=0, nJaFrete:=0, nJaSeg:=0  //valores já gravados no SWB para comissão, frete e seguro
Local cAliasSW9, nPos
Local nPesoLiq // FSY - Variavel utilizado para validar o calculo do Peso Liquido Unitario no Case: 'PESLIQTOT'
//FDR - 21/10/13 - Parâmetro que define se irá verificar a ref. Despachante em outro processo
Local lRefDesp := EasyGParam("MV_EIC0036",,.F.)
Local nValTaxa := 0 //LGS-16/03/2015
Local aAreaSW6 := SW6->(getArea())
Local lVldNumDI:= .T.
PRIVATE lRet:=.T.
PRIVATE cNomeCampo:=cLocalCampo
DEFAULT lPasta := .T.
DEFAULT lOK := .F.
PRIVATE lBotaoOK:=lOK//Para usar no RDMAKE
PRIVATE nCpoFocus := 0 //NCF - 13/08/09

IF cNomeCampo == NIL
   cNomeCampo:=UPPER(READVAR()) // variavel private da Enchoice
ENDIF

IF Left(cNomeCampo,3) == 'M->'
   cNomeCampo:=Subs(cNomeCampo,4)
ENDIF

IF lPasta
   cPasta:=AVSX3(cNomeCampo,05)+STR0403+AVSX3(cNomeCampo,15) //" -> Pasta: "
ENDIF

lSair:=.F.
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ANT_VALID_SW6"),)
IF lSair
   RETURN lRet
ENDIF

DO CASE
   CASE cNomeCampo == 'W6_PO_NUM' .AND. !lBotaoOK
         IF !EMPTY(M->W6_PO_NUM)
         IF Work->(EasyRecCount("Work")) == 0
            IF !DI500POPLIValid(.T.,M->W6_PO_NUM,.F.,.T.)
               RETURN .T.
            ENDIF
            aPedido:={}
            AADD(aPedido,M->W6_PO_NUM)
            DI500IniciaCapa(M->W6_PO_NUM,.F.,.T.)
         ELSE//IF ASCAN(aPedido,M->W6_PO_NUM) = 0 - Perguntar sempre
            Posicione("SW2",1,xFILIAL("SW2")+M->W6_PO_NUM,"W2_IMPORT")
            IF MSGYESNO(STR0521,STR0522)//"Confirma a troca de Pedido ?","Os campos da Capa serao reinicializados.")
               if !VALID_PEDIDO(.F.,.T.,.F.,.F.) //p1
                  return .F.
               EndIf
               VALID_PEDIDO(.T.,.T.,.F.,.F.)
               IF !DI500POPLIValid(.T.,M->W6_PO_NUM,.F.,.T.)
                  RETURN .T.
               ENDIF
               IF ASCAN(aPedido,M->W6_PO_NUM) = 0
                  AADD( aPedido,M->W6_PO_NUM)
                  DI500IniciaCapa(M->W6_PO_NUM,.T.,.T.)
               ELSE
                  DI500IniciaCapa(M->W6_PO_NUM,.F.,.T.)
               ENDIF
            ELSE
               RETURN .F.
            ENDIF
         ENDIF
      ENDIF

   //RMD - 04/10/13
   CASE cNomeCampo == 'W6_REF_DES'
      If lRefDesp .AND. !Empty(M->W6_REF_DES)
         BeginSql Alias "QRYREFDES"
         	SELECT
         		W6_REF_DES
         	FROM
         		%table:SW6% SW6
         	WHERE
         		(W6_HAWB <> %exp:M->W6_HAWB% OR W6_FILIAL <>  %XFilial:SW6%)
         		AND W6_REF_DES = %exp:M->W6_REF_DES%
         		AND %NotDel%
         EndSql

         If !QRYREFDES->(Eof())
	         MsgInfo(STR0848, STR0558)//"A referência do despachante já foi informada em outro processo. Verifique o conteúdo do campo para continuar.", "Aviso"
	         QRYREFDES->(DbCloseArea())
	         Return .F.
         EndIf
         QRYREFDES->(DbCloseArea())
      EndIf


   CASE cNomeCampo == 'W6_TX_US_D'

      IF !Inclui .and. SW6->W6_DTREG_D < SW6->W6_CONTAB .and. Empty(M->W6_TX_US_D) .AND. !Empty(M->W6_DI_NUM)
         Help("",1,"AVG0000727",,cPasta,4,0)//Msg Info(AVSX3("W6_TX_US_D",5)+STR0509,cPasta) //"Taxa US$ D.I" # " não pode ser vazio(a) pois processo já foi contabilizado."
         RETURN .F.
      ENDIF

      IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"VALIDACAO_TAXA"),)  // GFP - 19/08/2015

      IF lValida .AND. nTaxaDolar <> M->W6_TX_US_D //RMD - 23/12/14 - Caso o valor da taxa seja diferente do conteúdo da variável nTaxaDolar, não foi utilizado o botão "Taxas".
         MsgAlert(STR0852,STR0558)  // "A alteração da taxa somente é possível através da opção 'Taxas' em 'Ações Relacionadas'." ### "Aviso"
         M->W6_TX_US_D := nTaxaDolar //MCF - 23/12/2014
         Return .F.
      ENDIF

      //IF(!Inclui .AND. !Empty(M->W6_TX_US_D), AtuVlDI(!lTaxa),)  // Nopado por GFP - 06/03/2013

   CASE cNomeCampo == 'W6_DT_EMB'
        IF EMPTY( M->W6_DT_EMB) .and. !Empty(M->W6_DTREG_D)
           Help("",1,"AVG0000716",,cPasta,3,0)//Necessario preencher Data de Embarque."
           Return .F.
        ENDIF

        //** GFC - 28/11/05 - Câmbio de frete, seguro, comissão e embarque
        If lWB_TP_CON .and. !Empty(M->W6_DT_EMB) .and. Empty(SW6->W6_DT_EMB)
           If SWB->(dbSeek(xFilial("SWB")+M->W6_HAWB+If(lCposAdto,"D","")))
              Do While !SWB->(EOF()) .and. SWB->WB_FILIAL == xFilial("SWB") .and. SWB->WB_HAWB==M->W6_HAWB .and.;
              If(lCposAdto,SWB->WB_PO_DI=="D",.T.)
                 If Left(SWB->WB_TIPOREG,1) == "A"
                 nJaFrete += SWB->WB_FOBMOE
              ElseIf Left(SWB->WB_TIPOREG,1) == "B"
                 nJaSeg   += SWB->WB_FOBMOE
              ElseIf Left(SWB->WB_TIPOREG,1) == "C"
                 If (nPos:=aScan(aJaCom,{|x| x[1]==SWB->WB_INVOICE})) > 0
                    aJaCom[nPos,2] += SWB->WB_FOBMOE
                 Else
                    aAdd(aJaCom,{SWB->WB_INVOICE,SWB->WB_FOBMOE})
                 EndIf
              EndIf
              SWB->(dbSkip())
              EndDo
           EndIf

           If nJaFrete > M->W6_VLFRECC
              MsgInfo(STR0800) //STR0800 "A data de embarque não pode ser preenchida pois as parcelas de cambio para frete estão maiores que o valor do frete informado na capa do processo."
              Return .F.
           ElseIf nJaSeg > M->W6_VL_USSE
              MsgInfo(STR0659) //STR0659 "A data de embarque não pode ser preenchida pois as parcelas de cambio para seguro estão maiores que o valor do frete informado na capa do processo."
              Return .F.
           EndIf

           If(Work_SW9->(EasyRecCount("Work_SW9"))>0,cAliasSW9:="Work_SW9",cAliasSW9:="SW9")

           If cAliasSW9=="SW9"
              SW9->(dbSetOrder(3))
              SW9->(dbSeek(xFilial("SW9")+M->W6_HAWB))
           Else
              Work_SW9->(dbGoTop())
           EndIf
           Do While !(cAliasSW9)->(EOF()) .and. If(cAliasSW9=="SW9",SW9->W9_FILIAL==xFilial("SW9") .and. SW9->W9_HAWB==M->W6_HAWB,.T.)
              If (nPos:=aScan(aJaCom,{|x| x[1]==(cAliasSW9)->W9_INVOICE })) > 0
                 If aJaCom[nPos,2] > (cAliasSW9)->W9_VALCOM
                    MsgInfo(STR0660+Alltrim(aJaCom[nPos,1])+".") //STR0660 "A data de embarque não pode ser preenchida pois as parcelas de cambio para comissão estão com valores maiores que o valor da comissão informado na invoice "
                    Return .F.
                 EndIf
              EndIf
              (cAliasSW9)->(dbSkip())
           EndDo
        EndIf

        IF !lOk
           DI500AtuDtEta("ETA")
        ENDIF
        Return .T.

   CASE cNomeCampo == 'W6_PAISVEI'
        SYA->(DBSETORDER(1))
        IF !EMPTY( M->W6_PAISVEI )
           IF !SYA->(DBSEEK(xFilial()+M->W6_PAISVEI) )
              Help(" ",1,"E_VEICNAC",,cPasta,2,0)//NACIONALIDADE DO VEICULO NAO ENCONTRADA
              RETURN .F.
           ENDIF
        ENDIF

   CASE cNomeCampo == 'W6_LOCAL'
        IF ! EMPTY(M->W6_LOCAL)
           SY9->(DbSetOrder(2))
           IF !SY9->(DBSEEK(xFilial()+M->W6_LOCAL) )
              Help(" ",1,"REGNOIS",,cPasta,5,0)
              SY9->(DbSetOrder(1))
              RETURN .F.
           Else // GFP - 20/03/2012 - Validação de Registro Bloqueado
              If SY9->(FieldPos("Y9_MSBLQL")) > 0 .AND. SY9->Y9_MSBLQL == "1" // 1 - Registro Bloqueado  ## 2 - Registro Liberado
                 Help(" ",1,"REGBLOQ",,cPasta,2,0)  // Este registro está bloqueado para uso.
                 RETURN .F.
              EndIf
           ENDIF
           SY9->(DbSetOrder(1))
        ENDIF

   CASE cNomeCampo == 'W6_DESP'
        IF EMPTY( M->W6_DESP )
//         Msg('DESPACHANTE NAO PREENCHIDO - TECLE ENTER',100,.T.)
           Help(" ",1,"E_DENAOINF",,cPasta,2,0)
           RETURN .F.
        ENDIF
        SY5->(DBSETORDER(1))

        IF !SY5->(DBSEEK(xFilial()+M->W6_DESP))
           Help(" ",1,"E_DENAOCAD",,cPasta,2,0)//DESPACHANTE NAO CADASTRADO
           RETURN .F.
        ELSE
           // SVG - 20/07/2009 -
           If !(LEFT(SY5->Y5_TIPOAGE,1) = "6" .OR. LEFT(SY5->Y5_TIPOAGE,1) = " ")
               MsgInfo(STR0565)
               Return .F.
           Else
              RETURN .T.
           EndIf
        ENDIF
   CASE cNomeCampo == 'W6_AGENTE'
        // GFP - 03/10/2011
        IF !EMPTY(M->W6_AGENTE)
            SY4->(DBSETORDER(1))
            IF !SY4->(DBSEEK(xFilial()+M->W6_AGENTE))
   ///         Msg('AGENTE NAO CADASTRADO - TECLE ENTER',100,.T.)
               Help(" ",1,"E_AGNAOCAD",,cPasta,2,0)      // Agente não cadastrado.
               RETURN .F.
            ELSE
               IF Empty(SY4->Y4_FORN)
                  IF EasyGParam("MV_EASYFIN") $ cSim
                     MsgStop(STR0803,STR0804) // STR0803 "O Agente selecionado não possui Fornecedor/Loja cadastrado." //STR0804 "Atenção"
                     RETURN .F.
                  ELSE
                     RETURN .T.
                  ENDIF
               ENDIF
            ENDIF
         ELSE
   ///        Msg(STR0805,100,.T.) STR0805 "Agente não preenchido - tecle enter."
            Help(" ",1,"E_AGNAOINF",,cPasta,2,0)       // Agente não encontrado.
            RETURN .F.
         ENDIF

   CASE cNomeCampo == 'W6_DI_NUM'

        IF !EMPTY(M->W6_DI_NUM)

            IF AVSX3("W6_DI_NUM",2)=="N"
               cChaveW6:=Str(M->W6_DI_NUM, AVSX3("W6_DI_NUM",AV_TAMANHO) , 0)
            Else
               cChaveW6:=M->W6_DI_NUM
            ENDIF
            DI500Fil(.F.)
            IF SW6->(DBSETORDER(11) , DBSEEK(xFilial("SW6")+cChaveW6)) //MCF - 13/04/2016    
               if (Inclui .OR. M->W6_HAWB # SW6->W6_HAWB) .Or. SW6->(FieldPos("W6_VERSAO")) == 0
                  If SW6->W6_TIPOFEC != AvKey("DI","W6_TIPOFEC") .And. M->W6_TIPODES # SW6->W6_TIPODES
                     easyHelp(STR0925,STR0558) //"N° da DI/DA já existente! Só é possível usar a mesma numeração quando for um processo de retificação!"
                     lVldNumDI := .F.
                  Else
                     If "W6_DI_NUM" $ Readvar()
                        MsgInfo(STR0926)//"N° da DI/DA localizada em outro processo, não será possível a integração da retificação com Siscomex"
                     elseif AVFLAGS("DUIMP") .and. M->W6_TIPOREG == DUIMP .and. M->W6_FORMREG == DUIMP_MANUAL
                        lVldNumDI := .F.
                        EasyHelp(STR0944 , STR0804, StrTran( STR0945, "####", alltrim(SW6->W6_HAWB) ) ) // "O número da DUIMP informado está em outro processo." ## "Verifique o processo '####' ou o número da DUIMP informada."
                     EndIf
                  EndIf
               EndIf
            EndIf
            DI500Fil(.T.)
            restArea(aAreaSW6)
            If !lVldNumDI
               RETURN .F.
            EndIf

        ELSEIF !Inclui .and. !EMPTY(SW6->W6_DTREG_D) .AND. SW6->W6_DTREG_D < SW6->W6_CONTAB .and. Empty(M->W6_TX_US_D)
           Help("",1,"AVG0000728",,cPasta,4,0)//Msg Info(AVSX3("W6_DI_NUM",5)+STR0509,cPasta) //"No. da DI/DA" # " não pode ser vazio(a) pois processo já foi contabilizado."
           RETURN .F.
        ElseIf !EMPTY(M->W6_DTREG_D) .and. Empty(M->W6_DI_NUM) .AND. lOK .AND. !M->W6_CURRIER $ cSim
           Help(" ",1,"AVG0005351") //LRL 08/01/04 - MsgInfo("No. da DI/DA não pode ser vazio(a) pois a Data Registo da DI foi informada.")
           Return .F.
        ENDIF

        //** PLB (TAV095) - 01/12/06
        If lIntDraw  .And.  MOpcao == FECHTO_DESEMBARACO
           //** PLB - 11/12/06 - Validacao de Numero de Adicao na Invoice dos itens utilizados para Drawback
           If !Empty(M->W6_DI_NUM) .and. ( !AVFLAGS("DUIMP") .or. !(M->W6_TIPOREG == DUIMP) ) .And.  ( nOPC_mBrw == INCLUSAO  .Or. ;
                                             ( nOPC_mBrw == ALTERACAO  .And.  Empty(SW6->W6_DI_NUM) ) )
              If Select("Work_SW8") > 0  .And.  Work_SW8->( EasyRecCount("Work_SW8") ) > 0
                 nRecWK_SW8 := Work_SW8->( RecNo() )
                 Work_SW8->( DBGoTop() )
                 Do While Work_SW8->( !EoF() )
                    If Work_SW8->( !Empty(WKAC)  .And.  Empty(WKADICAO) )
                       MsgInfo(STR0661) //STR0661 "Não é possível registrar o Número da DI pois existem itens utilizados para Drawback que não possuem Número de Adição na Invoice."
                       Return .F.
                    EndIf
                    Work_SW8->( DBSkip() )
                 EndDo
                 Work_SW8->( DBGoTo(nRecWK_SW8) )
              ElseIf nOPC_mBrw == ALTERACAO
                 nRecSW8 := SW8->( RecNo() )
                 nOrdSW8 := SW8->( IndexOrd() )
                 SW8->( DBSetOrder(1) )
                 SW8->( DBSeek(cFilSW8+SW6->W6_HAWB) )
                 Do While SW8->( !EoF()  .And.  W8_FILIAL+W8_HAWB == cFilSW8+SW6->W6_HAWB )
                    If SW8->( !Empty(W8_AC)  .And.  Empty(W8_ADICAO) )
                       MsgInfo(STR0661) //STR0661 "Não é possível registrar o Número da DI pois existem itens utilizados para Drawback que não possuem Número de Adição na Invoice."
                       Return .F.
                    EndIf
                    SW8->( DBSkip() )
                 EndDo
                 SW8->( DBSetOrder(nOrdSW8) )
                 SW8->( DBGoTo(nRecSW8) )
              EndIf
           EndIf
           // Controle Multi-Usuário
           If lMUserEDC
              If ( nOPC_mBrw == ALTERACAO  .And.  SW6->W6_DI_NUM != M->W6_DI_NUM )  ;
                 .Or.  ( nOPC_mBrw == INCLUSAO  .And.  !Empty(M->W6_DI_NUM) )
                 If !oMUserEDC:Reserva("DI","ALTERA")
                    MsgInfo(STR0662) //STR0662 "Não é possível alterar o Número da DI pois alguma rotina está utilizando o Registro de saldo do Ato Concessorio cujos itens estão apropriados."
                    Return .F.
                 EndIf
              ElseIf nOPC_mBrw == INCLUSAO  .And.  Empty(M->W6_DI_NUM)
                 oMUserEDC:Solta("DI","ALTERA")
              EndIf
           EndIf
        EndIf
        //SVG 09/10/08
           nCpoFocus := GetFocus()                                                  //NCF - 13/08/09

   CASE cNomeCampo == 'W6_DT' .AND. MOpcao # FECHTO_NACIONALIZACAO
        //TDF 08-11-10 verificação da Modalidade, onde 6,4 e 2 são modalidades de despacho antecipado.
        IF !EMPTY( M->W6_DT ) .AND. M->W6_DT < M->W6_CHEG .AND. M->W6_MODAL_D <> "6" .And. M->W6_MODAL_D <> "4".And. M->W6_MODAL_D <> "2"
        //Msg('DT DE PAGAMENTO DOS IMPOSTOS DEVE SER MAIOR QUE A DT DE ATRACACAO',3000,.T.)
           Help(" ",1,"E_DTPGIMP",,cPasta,3,0)
           RETURN .F.
        ENDIF
        RETURN .T.

   CASE cNomeCampo == 'W7_PESO'
        IF !POSITIVO(M->W7_PESO)
           RETURN .F.
        ENDIF
        IF !NaoVazio(M->W7_PESO)
           RETURN .F.
        ENDIF
        If Positivo(M->W7_PESO)  // GFP - 15/04/2013

           //nPesLiqTot := M->W7_PESO * TSALDO_Q //** Dopado FSY - 07/06/2013
           //** FSY - 07/06/2013 - Condição inserida para validar o tamanho do campo Peso Liquido Total.
           nPesoLiq := Alltrim (Transform( M->W7_PESO * TSALDO_Q , AvSx3("W6_PESOTOT", 6)))
           If "*" $ nPesoLiq//A função Transform() retorna * quando ultrapassa o limite do campo.
              MsgInfo("O tamanho do campo Peso Liquido Total ultrapasso o limite suportado pelo sistema 'Peso Liq. Total = Peso Liq. Uni * quantidade'.")
              RETURN .F.
           Else
              nPesLiqTot := M->W7_PESO * TSALDO_Q
           EndIf
        Else
           M->W7_PESO := 0
           nPesLiqTot := 0
           RETURN .F.
        EndIf

   CASE cNomeCampo == 'TFOBUNIT'
        IF !POSITIVO(TFOBUNIT)
           RETURN .F.
        ENDIF
        IF !NaoVazio(TFOBUNIT)
           RETURN .F.
        ENDIF
        nFobTotal:=DI500Trans(TSaldo_Q * TFobUnit)
        oFobTotal:Refresh()

   CASE cNomeCampo == 'PESLIQTOT'  // GFP - 15/04/2013
        IF !POSITIVO(TFOBUNIT)
           RETURN .F.
        ENDIF

        If POSITIVO(nPesoLiq)
           //M->W7_PESO := nPesLiqTot / TSALDO_Q //Dopado FSY - 07/06/2013 - Condição inserida para validar o tamanho do campo Peso Liquido Unitario.
           //**FSY - 07/06/2013
           nPesoLiq := Alltrim (Transform( nPesLiqTot / TSALDO_Q , AvSx3("W7_PESO", 6)))
           If "*" $ nPesoLiq//A função Transform() retorna * quando ultrapassa o limite do campo.
              MsgInfo("O tamanho do campo Peso Liquido Unitário ultrapasso o limite suportado pelo sistema 'Peso Liq Uni = Peso Liq. Total/quantidade' ")
              RETURN .F.
           Else
              M->W7_PESO := nPesLiqTot / TSALDO_Q
           EndIf
        Else
           M->W7_PESO := 0
           nPesLiqTot := 0
           RETURN .F.
        EndIf

   CASE cNomeCampo == 'TSALDO_Q'
        IF !POSITIVO(TSALDO_Q)
           DBSELECTAREA("Work")
           RETURN .F.
        ENDIF
        IF EMPTY(TSALDO_Q)
           Help(" ",1,"E_SALDOQTD")//SALDO DE QUANTIDADE NAO PREENCHIDO
           RETURN .F.
        ENDIF
        IF !lMV_SLD_EMB
           IF lExiste
              IF PosOrd2_IT_Guias(M->W6_HAWB,Work->WKCC,Work->WKSI_NUM,Work->WKCOD_I ,;
                                   Work->WKFABR,Work->WKFORN,Work->WKREG,Work->WKPGI_NUM,Work->WKPO_NUM,Work->WKPOSICAO, Work_SW8->W8_FABLOJ, Work_SW8->W8_FORLOJ)

                 IF TSALDO_Q > Work->WKSALDO_O
                    IF (TSALDO_Q - Work->WKSALDO_O) > SW5->W5_SALDO_Q .And. !lLibQt
//                     Msg('QUANTIDADE MAIOR QUE O SALDO DA GUIA - TECLE ENTER',100,.T.)
                       Help(" ",1,"E_QTDSLD")
                       SELECT Work
                       RETURN .F.
                    ENDIF
                 ENDIF
              ELSE
                 IF TSaldo_Q > Work->WKSALDO_O  .AND. !lLibQt
                    Help(" ",1,"E_QTDSLD")
                    SELECT Work
                    RETURN .F.
                 ENDIF
              ENDIF
           ELSE
              IF TSALDO_Q > Work->WKSALDO_O .AND. !lLibQt
//               Msg('QUANTIDADE MAIOR QUE O SALDO DA GUIA
                 Help(" ",1,"E_QTDSLD")
                 SELECT Work
                 RETURN .F.
              ENDIF
           ENDIF
        ENDIF
        SELECT Work
        nFobTotal:=DI500Trans(TSaldo_Q * TFobUnit)
        oFobTotal:Refresh()

        If POSITIVO(M->W7_PESO) // GFP - 15/04/2013
           nPesLiqTot := M->W7_PESO * TSALDO_Q
        Else
           nPesLiqTot := 0
           M->W7_PESO := 0
           RETURN .F.
        EndIf
        IF AvFlags("EIC_EAI")//AWF - 25/06/2014
           M->W7_QTSEGUM:=TSALDO_Q*Work->WKFATOR
          cSegUN:= TRANS(M->W7_QTSEGUM,AVSX3("W3_QTSEGUM",6))+" "+WORK->WKSEGUM//AWF - 01/07/2014
        ENDIF
        RETURN .T.

   CASE cNomeCampo == 'W6_CHEG' .AND. MOpcao # FECHTO_NACIONALIZACAO
        IF EMPTY( M->W6_CHEG ) .AND. ! EMPTY( M->W6_DI_NUM )
//         Help(" ",1,"E_DCHEGNAO",,cPasta,2,0)
//         RETURN .F.
        ELSE
           IF !EMPTY(M->W6_CHEG) .AND. M->W6_CHEG < M->W6_DT_EMB
              Help(" ",1,"E_DCHEGEMB",,cPasta,3,0)
              RETURN .F.
           ELSE
              IF !lOk
                 dI500AtuDtEta("PRD")
              ENDIF
              RETURN .T.
           ENDIF
        ENDIF

   CASE cNomeCampo == 'W6_DT_AVE'
         IF !EMPTY( M->W6_DT_AVE ) .And. !EMPTY( M->W6_CHEG )            
            IF M->W6_MODAL_D =  '1' //Modalidade Normal               
               IF M->W6_DT_AVE < M->W6_CHEG                     
                  easyHelp(STR0899) //Para a modalidade Normal a data de averbação do embarque deverá ser maior ou igual que a data de atracação
                  RETURN .F.
               ELSE
                  RETURN .T.
               ENDIF               
            ELSEIF M->W6_MODAL_D =  '2' //Modalidade Antecipada                  
               IF M->W6_DT_AVE >= M->W6_CHEG
                  easyHelp(STR0900) //Para a modalidade Antecipada a data de averbação do embarque deverá ser menor que a data de atracação
                  RETURN .F.
               ELSE
                  RETURN .T.
               ENDIF               
            ENDIF   
         ENDIF   

/* CASE cNomeCampo == 'W6_DTRECDO'
        IF EMPTY( M->W6_DTRECDO )
           RETURN .T.
        ELSE
           IF M->W6_DTRECDO < M->W6_DT_EMB
              Help(" ",1,"E_DRECDEMB",,cPasta,3,0)//DATA DE RECBTO. DOCTO. DEVE SER MAIOR QUE DATA DE EMBARQUE
              RETURN .F.
           ELSE
              RETURN .T.
           ENDIF
        ENDIF*/

   CASE cNomeCampo == 'W6_DT_DESE'
        IF EMPTY( M->W6_DT_DESE )
           RETURN .T.
        ELSE
           IF M->W6_DT_DESE < M->W6_DT
              Help(" ",1,"E_DDESDPAG",,cPasta,3,0)//DATA DE DESEMBARACO DEVE SER MAIOR QUE DATA DE PAGTO. IMPOSTOS
              RETURN .F.
           ELSE
              RETURN .T.
           ENDIF
        ENDIF
        
        If !Empty(M->W6_DT_DESE) .And. AvFlags("DUIMP")
           If M->W6_TIPOREG == '2' .And. (Empty(M->W6_DI_NUM) .Or. Empty(M->W6_VERSAO) .Or. Empty(M->W6_DTREG_D))
              EasyHelp(STR0922, STR0558, STR0923) //"Para preencher a Data de Desembaraço será necessário preencher Número DI/DA/DUIMP, Versão e Data de Registro de Importação" ## Atenção ##"Verifique o preenchimento dos campos: Número DI/DA/DUIMP, Versão e Data de Registro de Importação"
              RETURN .F.
           EndIf
        EndIf

        IF !lOk
           DI500AtuDtEta("PRE")
        ENDIF

   CASE cNomeCampo == 'W6_DT_NF'
        IF EMPTY( M->W6_NF_ENT) .AND. .NOT. EMPTY( M->W6_DT_NF )
           Help(" ",1,"E_NNFENAO",,cPasta,3,0)//NUMERO DA N.F. DE ENTRADA NAO FOI PREENCHIDO
           RETURN .F.
        ENDIF
        IF .NOT. EMPTY( M->W6_NF_ENT) .AND. EMPTY( M->W6_DT_NF )
           Help(" ",1,"E_DNFENAO",,cPasta,3,0)//DATA DA N.F. DE ENTRADA DEVE SER PREENCHIDA
           RETURN .F.
        ENDIF

   CASE cNomeCampo == 'W6_VL_NF'
        IF EMPTY(M->W6_NF_ENT) .AND. .NOT. EMPTY(M->W6_VL_NF)
           Help(" ",1,"E_NNFENAO",,cPasta,3,0)//NUMERO DA N.F. DE ENTRADA NAO FOI PREENCHIDO
           RETURN .F.
        ENDIF
        IF .NOT. EMPTY(M->W6_NF_ENT) .AND. EMPTY( M->W6_VL_NF )
           Help(" ",1,"E_VNFENAO",,cPasta,3,0)//VALOR DA N.F. DE ENTRADA DEVE SER PREENCHIDO
           RETURN .F.
        ENDIF

   CASE cNomeCampo == 'W6_DT_NFC'
        IF EMPTY( M->W6_NF_COMP ) .AND. .NOT. EMPTY( M->W6_DT_NFC )
           Help(" ",1,"E_NNFENAO",,cPasta,3,0)//NUMERO DA N.F. COMPLEMENTAR NAO FOI PREENCHIDO
           RETURN .F.
        ENDIF
        IF .NOT. EMPTY( M->W6_NF_COMP) .AND. EMPTY( M->W6_DT_NFC )
           Help(" ",1,"E_DNFENAO",,cPasta,3,0)//DATA DA N.F. COMPLEMENTAR DEVE SER PREENCHIDA
           RETURN .F.
        ENDIF

   CASE cNomeCampo == 'W6_VL_NFC'
        IF EMPTY( M->W6_NF_COMP ) .AND. .NOT. EMPTY( M->W6_VL_NFC )
           Help(" ",1,"E_NNFENAO",,cPasta,3,0)//NUMERO DA N.F. COMPLEMENTAR NAO FOI PREENCHIDO
           RETURN .F.
        ENDIF
        IF .NOT. EMPTY( M->W6_NF_COMP ) .AND. EMPTY( M->W6_VL_NFC )
           Help(" ",1,"E_VNFENAO",,cPasta,3,0)//VALOR DA N.F. COMPLEMENTAR DEVE SER PREENCHIDO
           RETURN .F.
        ENDIF

   CASE cNomeCampo == 'W6_DT_ENTR' .AND. cPAISLOC=="BRA"   // 26/03 R.A.D. para nao considerar a NFE no desembaraco
        If !Empty(M->W6_DT_ENTR)// SVG  - 29/06/09 -
           If Empty(M->W6_DT_DESE)
              MsgAlert(STR0564)
              Return .F.
           EndIf
        EndIf
        IF EMPTY(M->W6_DT_ENTR)
           RETURN .T.
        ELSE
           IF EMPTY(M->W6_NF_ENT)
              Help(" ",1,"E_DENTNNF",,cPasta,3,0)//DT. DE ENTREGA NAO PODE SER PREENCHIDA QUANDO N.F. NAO RECEBIDA
              RETURN .F.
           ENDIF
           IF EMPTY(M->W6_DT_EMB)
              MSGINFO(STR0561) //DATA DE ENTREGA NÃO PODE SER PREENCHIDA QUANDO A DATA DE EMBARQUE ESTIVER VAZIA
              RETURN .F.
           ELSEIF M->W6_DT_ENTR < M->W6_DT_EMB
              Help(" ",1,"E_DENTDEMB",,cPasta,3,0)//DATA DE ENTREGA DEVE SER MAIOR QUE DATA DE EMBARQUE
              RETURN .F.
           ELSE
              IF EMPTY(M->W6_DT_DESE)
                 MSGINFO(STR0562) //DATA DE ENTREGA NÃO PODE SER PREENCHIDA QUANDO A DATA DE DESEMBARAÇO ESTIVER VAZIA
                 RETURN .F.
              ELSEIF M->W6_DT_ENTR < M->W6_DT_DESE
                 Help(" ",1,"E_DENTDDES",,cPasta,3,0)//DATA DE ENTREGA DEVE SER MAIOR OU IGUAL A DATA DE DESEMBARACO
                 RETURN .F.
              ELSE
                 RETURN .T.
              ENDIF
           ENDIF
        ENDIF

   CASE cNomeCampo == 'W6_DT_ENCE'
        IF EMPTY( M->W6_DT_ENTR )
           IF EMPTY( M->W6_DT_ENCE )
              RETURN .T.
           ELSE
              IF lOk
                 IF MsgYesNo(STR0663) //STR0663 "Data de entrega não informada. Confirma o encerramento?"
                    RETURN .T.
                 ENDIF
                 //Help(" ",1,"E_DENCNAO",,cPasta,3,0)//DATA DE ENCERRAMENTO NAO PODE SER PREENCHIDA
                 RETURN .F.
              ENDIF
              RETURN .T.
           ENDIF
        ELSE
           IF EMPTY( M->W6_DT_ENCE )
              RETURN .T.
           ELSE
              IF M->W6_DT_ENCE < M->W6_DT_ENTR
                 Help(" ",1,"E_DENCDENT",,cPasta,3,0)//DATA DE ENCERRAMENTO DEVE SER MAIOR QUE DATA DE ENTREGA
                 RETURN .F.
              ELSE
                 RETURN .T.
              ENDIF
           ENDIF
        ENDIF

   CASE cNomeCampo == 'W6_VLFREPP'.OR. ;
		cNomeCampo == 'W6_VLFRECC'.OR. ;
		cNomeCampo == 'W6_VLFRETN'

        IF EMPTY(ValorFrete(M->W6_HAWB,,,2,.T.))
           IF EMPTY(M->W6_FREMOED)
              RETURN .T.
           ELSE
              Help(" ",1,"E_FREVALOR",,cPasta,2,0)//VALOR DO FRETE NAO INFORMADO
              RETURN .F.
           ENDIF
        ELSE
           IF EMPTY(M->W6_FREMOED)
              Help(" ",1,"E_FREMOEDA",,cPasta,2,0)//MOEDA DO FRETE NAO INFORMADA
              RETURN .F.
           ENDIF
        ENDIF

        DI500Controle(3,{M->W6_VLFRECC,M->W6_VLFREPP,M->W6_VLFRETN,M->W6_VLSEGMN,M->W6_VL_USSE,M->W6_SEGBASE,M->W6_SEGPERC,M->W6_TX_FRET})

   CASE cNomeCampo == 'W6_SETORRA'
        SJG->(DBSETORDER(1))
        IF !EMPTY(M->W6_SETORRA) .AND. !SJG->(DBSEEK(xFilial()+M->W6_REC_ALF+M->W6_SETORRA))
           Help(" ",1,"REGNOIS",,cPasta,5,0)
           Return .F.
        ENDIF

   CASE cNomeCampo == 'W6_FREMOED'

        If !Empty(SW6->W6_FREMOED) .AND. Empty(cMoedaFrt) //MCF - 27/01/2015
           cMoedaFrt := SW6->W6_FREMOED
        EndIf
        cMoedaFrt := If(Empty(cMoedaFrt), M->W6_FREMOED, cMoedaFrt)

        SYF->(DBSETORDER(1))
        If !Empty(M->W6_FREMOED) .And. !SYF->(DbSeek(xFilial()+M->W6_FREMOED))
           Help(" ",1,"REGNOIS",,cPasta,5,0)
           Return .F.
        Endif
        IF !EMPTY(M->W6_FREMOED)
           IF EMPTY(M->W6_TX_FRET) .AND. lBuscaTaxaAuto
              M->W6_TX_FRET:=BuscaTaxa(M->W6_FREMOED,dDataBase,.T.,.F.,.T.)
           ELSE
              IF !Empty(cMoedaFrt) .AND. cMoedaFrt != M->W6_FREMOED
                 cMoedaFrt := M->W6_FREMOED
                 nValTaxa  := BuscaTaxa(M->W6_FREMOED,dDataBase,.T.,.F.,.T.)
                 IF Empty(M->W6_DTREG_D) .AND. nValTaxa <> 0 //LGS-16/03/2015 - Qdo a Taxa for "ZERO" não tem cadastro na "SYE" e não devo trocar a taxa
                    M->W6_TX_FRET := nValTaxa                //cadastrada no processo já.
                 ENDIF
              ENDIF
           ENDIF
        ELSE
           M->W6_TX_FRET := 0
        ENDIF

        DI500Controle(3,{M->W6_VLFRECC,M->W6_VLFREPP,M->W6_VLFRETN,M->W6_VLSEGMN,M->W6_VL_USSE,M->W6_SEGBASE,M->W6_SEGPERC,M->W6_TX_FRET})


   CASE cNomeCampo == 'W6_TX_FRET'
        IF EMPTY(ValorFrete(M->W6_HAWB,,,2,.T.))
           IF EMPTY(M->W6_TX_FRET)
              RETURN .T.
           ELSE
              Help(" ",1,"E_FREVALOR",,cPasta,2,0)//VALOR DO FRETE NAO INFORMADO
              RETURN .F.
           ENDIF
        ELSE
           IF M->W6_FREMOED # cMoeDolar .AND. EMPTY(M->W6_TX_FRET)
              Help(" ",1,"E_FRETAXA",,cPasta,2,0)//TAXA DE CONVERSAO DO FRETE NAO INFORMADA
///           RETURN .F.
           ENDIF
        ENDIF

        DI500Controle(3,{M->W6_VLFRECC,M->W6_VLFREPP,M->W6_VLFRETN,M->W6_VLSEGMN,M->W6_VL_USSE,M->W6_SEGBASE,M->W6_SEGPERC,M->W6_TX_FRET})

   CASE cNomeCampo == 'W6_SEGPERC'
        IF !Positivo(M->W6_SEGPERC)
           RETURN .F.
        ENDIF
        IF EMPTY(M->W6_SEGPERC)
           M->W6_SEGBASE:=' '
        ENDIF
        DI500Controle(3,{M->W6_VLFRECC,M->W6_VLFREPP,M->W6_VLFRETN,M->W6_VLSEGMN,M->W6_VL_USSE,M->W6_SEGBASE,M->W6_SEGPERC,M->W6_TX_FRET})
        RETURN .T.

   CASE cNomeCampo == 'W6_VL_USSE'
        IF !EMPTY(M->W6_SEGPERC)
           RETURN .T.
        ENDIF

        IF EMPTY(M->W6_VL_USSE)
           IF EMPTY(M->W6_SEGMOED)
              RETURN .T.
           ELSE
              Help(" ",1,"E_SEGVALOR",,cPasta,2,0)//VALOR DO SEGURO NAO INFORMADO
              RETURN .F.
           ENDIF
        ELSE
           IF EMPTY(M->W6_SEGMOED)
              Help(" ",1,"E_SEGMOEDA",,cPasta,2,0)//MOEDA DO SEGURO NAO INFORMADA
              RETURN .F.
           ENDIF
        ENDIF
        M->W6_VLSEGMN:=DI500TRANS(M->W6_VL_USSE*M->W6_TX_SEG)

        DI500Controle(3,{M->W6_VLFRECC,M->W6_VLFREPP,M->W6_VLFRETN,M->W6_VLSEGMN,M->W6_VL_USSE,M->W6_SEGBASE,M->W6_SEGPERC,M->W6_TX_FRET})

   CASE cNomeCampo == 'W6_TX_SEG'
//      IF !EMPTY(M->W6_SEGPERC)
//         RETURN .T.
//      ENDIF
        IF EMPTY(M->W6_VL_USSE) .AND. EMPTY(M->W6_SEGPERC)
           IF !EMPTY(M->W6_TX_SEG)
              Help(" ",1,"E_SEGVALOR",,cPasta,2,0)//VALOR DO SEGURO NAO INFORMADO
              RETURN .F.
           ENDIF
        ENDIF
        IF EMPTY(M->W6_SEGPERC)
           M->W6_VLSEGMN:=DI500TRANS(M->W6_VL_USSE*M->W6_TX_SEG)
        ENDIF
        DI500Controle(3,{M->W6_VLFRECC,M->W6_VLFREPP,M->W6_VLFRETN,M->W6_VLSEGMN,M->W6_VL_USSE,M->W6_SEGBASE,M->W6_SEGPERC,M->W6_TX_FRET})

   CASE cNomeCampo == 'W6_SEGMOED'

   		 If !Empty(SW6->W6_SEGMOED) .AND. Empty(cMoedaSeg) //MCF - 27/01/2015
           cMoedaSeg := SW6->W6_SEGMOED
        EndIf
        cMoedaSeg := If(Empty(cMoedaSeg), M->W6_FREMOED, cMoedaSeg)

        SYF->(DBSETORDER(1))
        If !Empty(M->W6_SEGMOED)
           IF !SYF->(DbSeek(xFilial()+M->W6_SEGMOED))
              Help(" ",1,"REGNOIS",,cPasta,5,0)
              Return .F.
           ENDIF
        ELSEIF !EMPTY(M->W6_SEGPERC)
           Help(" ",1,"E_SEGMOEDA",,cPasta,2,0)//MOEDA DO SEGURO NAO INFORMADA
           RETURN .F.
        ENDIF

        If !Empty(M->W6_SEGMOED)//SVG 21/10/08
           //IF /*EMPTY(M->W6_TX_SEG) .AND.*/ lBuscaTaxaAuto // NCF - 27/07/09
           //CCH - 08/09/2009 - Só utiliza o lBuscaTaxaAuto se o país for Argentina. Caso contrário, mantém o padrão.
           If (cPaisLoc <> "BRA" .or. EMPTY(M->W6_TX_SEG)) .and. lBuscaTaxaAuto
              M->W6_TX_SEG:=BuscaTaxa(M->W6_SEGMOED,dDataBase,.T.,.F.,.T.)
              M->W6_VLSEGMN:=DI500TRANS(M->W6_VL_USSE*M->W6_TX_SEG)
           ELSE
              IF !Empty(cMoedaSeg) .AND. cMoedaSeg != M->W6_SEGMOED
                 cMoedaSeg := M->W6_SEGMOED
				 nValTaxa  := BuscaTaxa(M->W6_SEGMOED,dDataBase,.T.,.F.,.T.)
                 IF Empty(M->W6_DTREG_D) .AND. nValTaxa <> 0 //LGS-09/04/2015 - Qdo a Taxa for "ZERO" não tem cadastro na "SYE" e não devo trocar a taxa
                    M->W6_TX_SEG := nValTaxa                 //cadastrada no processo já.
                 ENDIF
              ENDIF
           ENDIF
        Else
           M->W6_TX_SEG := 0
        Endif

        DI500Controle(3,{M->W6_VLFRECC,M->W6_VLFREPP,M->W6_VLFRETN,M->W6_VLSEGMN,M->W6_VL_USSE,M->W6_SEGBASE,M->W6_SEGPERC,M->W6_TX_FRET})

   CASE cNomeCampo == 'TUDO'
        SYR->(DBSETORDER(1))
        IF !EMPTY(M->W6_VIA_TRA) .AND. !EMPTY(M->W6_ORIGEM) .AND. !EMPTY(M->W6_DEST)
           IF ! SYR->(DBSEEK(xFilial()+M->W6_VIA_TRA+M->W6_ORIGEM+M->W6_DEST))
              Help("", 1, "AVG0000264")//E_Msg(STR0211,1) //"NÆo Existe esta Via de Transporte / Origem / Destino No Cadastro De Fretes"
              RETURN .F.
           ENDIF
        ELSEIF !EMPTY(M->W6_VIA_TRA) .AND. !EMPTY(M->W6_ORIGEM)
           IF ! SYR->(DBSEEK(xFilial()+M->W6_VIA_TRA+M->W6_ORIGEM))
              Help("", 1, "AVG0000265")//E_Msg(STR0212,1) //"NÆo Existe esta Via de Transporte / Origem no Cadastro de Fretes"
              RETURN .F.
           ENDIF
        ENDIF

        If MOpcao == FECHTO_NACIONALIZACAO .AND. ! (Val(M->W6_TIPODES) >= 14 .And. Val(M->W6_TIPODES) <= 16)
           Help(" ",1,"AVG0000100")
           Return .F.
        Endif

        IF !EMPTY(M->W6_VL_USSE)
           IF !EICFI400("VAL_SW6_2")//Valida M->W6_VENCSEG e M->W6_CORRETO
              Return .F.
           ENDIF
        ENDIF

        DI500Controle(3,{M->W6_VLFRECC,M->W6_VLFREPP,M->W6_VLFRETN,M->W6_VLSEGMN,M->W6_VL_USSE,M->W6_SEGBASE,M->W6_SEGPERC,M->W6_TX_FRET})

//      IF !EMPTY(M->W6_VL_FRET)
//         IF !EICFI400("VAL_SW6_1")//Valida M->W6_HOUSE e M->W6_VENCFRE
//            Return .F.
//         ENDIF
//      ENDIF

        //** GFC - 09/03/06 - Mostrar mensagem caso tenha geração de cambio automatico e os campos não estajam
        //                    completamente preenchidos
        If lWB_TP_CON .and. lGravaFin_EIC
           If lGeraFrete .and. !Empty(M->W6_VLFRECC) //AWR - 19/10/06 - Só dar essa mensagem se o frete CC tiver preenchido
              IF Empty(M->W6_FORNECF) .or. Empty(M->W6_FREMOED) .or. Empty(M->W6_VENCFRE) .or. Empty(M->W6_CONDP_F)
                 MsgInfo(STR0664) //STR0664 "Os dados do frete não estão completamente preenchidos e não serão gerados no câmbio."
              EndIf
           EndIf
           If lGeraSeg .and. !Empty(M->W6_VL_USSE)
              IF Empty(M->W6_FORNECS) .or. Empty(M->W6_SEGMOED) .or. Empty(M->W6_VENCSEG) .or. Empty(M->W6_CONDP_S)
                 MsgInfo(STR0665) //STR0665 "Os dados do seguro não estão completamente preenchidos e não serão gerados no câmbio
              EndIf
           EndIf
        EndIf

        //FDR - 03/09/12 - Validação para processo Courrier
        If M->W6_CURRIER == "1" .And. ValidCourrier()
            Return .F.
        EndIf

        RETURN .T.

   CASE cNomeCampo == 'W6_TRANS'
        IF !Empty(M->W6_TRANS)
           SA4->(DBSETORDER(1))
           IF !SA4->(DbSeek( xFilial()+M->W6_TRANS ))
              Help("", 1, "AVG0000267",,cPasta,2,0)//Transportadora não cadastrada
              RETURN .F.
           ENDIF
        ENDIF

   CASE cNomeCampo == 'W6_MT3'
        IF M->W6_MT3 < 0
           Help("", 1, "AVG0000268",,cPasta,2,0)//Volume cubado não pode ser negativo
           RETURN .F.
        ENDIF

        DI_CalcPesoCub() //DFS - 08/02/12 - Chamada da função para cálculo do peso dependendo da via de transporte

   Case cNomeCampo == "W6_PESO_BR"
        DI_CalcPesoCub() //DFS - 08/02/12 - Chamada da função para cálculo do peso dependendo da via de transporte

   CASE cNomeCampo == 'W6_CONTA20'
        IF M->W6_CONTA20 < 0
           Help("", 1, "AVG0000269",,cPasta,2,0)//Container de 20' não pode ser negativo
           RETURN .F.
        ENDIF

   CASE cNomeCampo == 'W6_CONTA40'
        IF M->W6_CONTA40 < 0
           Help("", 1, "AVG0000270",,cPasta,2,0)//Container de 40' não pode ser negativo
           RETURN .F.
        ENDIF

   CASE cNomeCampo == 'W6_CON40HC'
        IF M->W6_CON40HC < 0
           Help("", 1, "AVG0000271",,cPasta,3,0)//Container de 40' HC não pode ser negativo
           RETURN .F.
        ENDIF

   CASE cNomeCampo == 'W6_OUTROS'
        IF M->W6_OUTROS < 0
           Help("", 1, "AVG0000272",,cPasta,2,0)//Outros não pode ser negativo
           RETURN .F.
        ENDIF

   CASE cNomeCampo == "W6_PRVDESE"
        If MOpcao = FECHTO_DESEMBARACO
           IF !Empty(M->W6_PRVDESE) .And. M->W6_PRVDESE < M->W6_CHEG
              Help("", 1, "AVG0000273",,cPasta,3,0)//Previsão de Desembaraço deve ser maior ou igual a Data de Atracação !
              Return .F.
           Endif
        Endif

        IF !lOk
           Di500AtuDtEta("PRE")
        ENDIF

   CASE cNomeCampo == "W6_DTREG_D"

        If !Empty(M->W6_DTREG_D) .And. M->W6_DTREG_D < M->W6_DT
           Help("", 1, "AVG0000274",,cPasta,3,0)//Registro da D.I. deve ser maior ou igual a Data de Pagamento de Impostos !
           Return .F.
        Endif

        If !Inclui .and. SW6->W6_DTREG_D < SW6->W6_CONTAB .and. Empty(M->W6_DTREG_D) .AND. !EMPTY(SW6->W6_DI_NUM)
            Help("", 1, "AVG0000729",,cPasta,4,0)//Data Registro da D.I. nao pode ser vazia pois processo ja foi contabilizado."
            Return .F.
        ElseIf !Empty(M->W6_DI_NUM) .and. Empty(M->W6_DTREG_D) .AND. lOK
           Help("", 1, "AVG0005352")//LRL 08/01/04 - MsgInfo("Data Registo da D.I. não pode ser vazia pois o No. da DI/DA foi informado(a).")
           Return .F.
        EndIf


   CASE cNomeCampo == "W6_ARMADOR"
        If !Empty(M->W6_ARMADOR)
	        SY5->(dbSetOrder(1))
	        If SY5->(dbSeek(xFilial("SY5")+M->W6_ARMADOR))
               If LEFT(SY5->Y5_TIPOAGE,1) <> "4"
	              Help("", 1,"AVG0000660",,cPasta,3,0)
	              Return .f.
	           Endif
	        Else
	           Help("", 1,"AVG0003033",,cPasta,2,0) // Codigo do Armador nao Encontrado.
    	       Return .F.
	        Endif
        Endif

   CASE cNomeCampo == "TEC1"
         SYD->(DBSETORDER(1))
         IF !EMPTY(M->W7_NCM )
         
            IF !ExistCpo("SYD", M->W7_NCM)
               //Help("", 1, "AVG0000336")//Codigo N.C.M. nao cadastrado
               RETURN .F.
            ENDIF

            If ExistTrigger('W7_NCM') .AND. Empty(M->W7_EX_NCM) .AND. Empty(M->W7_EX_NBM)
               RunTrigger(1,nil,nil,,'W7_NCM')
            Endif
         ENDIF

         //TRP-26/05/08- Preenchimento do campo N.C.M é obrigatório no item na fase de Desembaraço.
         If Empty(M->W7_NCM)
            MsgInfo(STR0666,STR0558)  //STR0666 "O preenchimento do campo N.C.M é obrigatório!" //STR0558  "Aviso"
            Return .F.
         EndIf

   CASE cNomeCampo == "TEC2"
        SYD->(DBSETORDER(1))
           IF !VAZIO(M->W7_EX_NCM) .AND. !ExistCpo("SYD", M->W7_NCM+M->W7_EX_NCM)
           //Help("", 1, "AVG0000337")//Codigos N.C.M.s nao cadastrado
           RETURN .F.
        ENDIF

   CASE cNomeCampo == "TEC3"
        SYD->(DBSETORDER(1))
        IF !VAZIO(M->W7_EX_NBM) .AND. !ExistCpo("SYD", M->W7_NCM+M->W7_EX_NCM+M->W7_EX_NBM)
           //Help("", 1, "AVG0000338")//Codigos N.C.M.s e N.B.M. nao cadastrados
           RETURN .F.
        ENDIF

   CASE cNomeCampo == 'W6_VIA_TRA' .OR. cNomeCampo == 'W6_DT_ETD'
        IF cNomeCampo == 'W6_VIA_TRA'
           SYQ->(DBSETORDER(1))
           IF !EMPTY(M->W6_VIA_TRA) .AND. !SYQ->(DBSEEK(xFilial()+M->W6_VIA_TRA))
              Help(" ",1,"REGNOIS",,cPasta,5,0)
              Return .F.
           ENDIF
           DI_CalcPesoCub() //DFS - 08/02/12 - Chamada da função para cálculo do peso dependendo da via de transporte
        ENDIF

        IF !lOk
           DI500AtuDtEta("ETA")
        ENDIF

   CASE cNomeCampo == 'W6_ORIGEM' .OR. cNomeCampo == 'W6_DEST'
        SYR->(DBSETORDER(1))
        IF !EMPTY(M->W6_VIA_TRA) .AND. !EMPTY(M->W6_ORIGEM) .AND. !EMPTY(M->W6_DEST)
           IF ! SYR->(DBSEEK(xFilial()+M->W6_VIA_TRA+M->W6_ORIGEM+M->W6_DEST))
              Help("", 1, "AVG0000264")//E_Msg(STR0211,1) //"NÆo Existe esta Via de Transporte / Origem / Destino No Cadastro De Fretes"
              RETURN .F.
           ENDIF
        ELSEIF !EMPTY(M->W6_VIA_TRA) .AND. !EMPTY(M->W6_ORIGEM)
           IF ! SYR->(DBSEEK(xFilial()+M->W6_VIA_TRA+M->W6_ORIGEM))
              Help("", 1, "AVG0000265")//E_Msg(STR0212,1) //"NÆo Existe esta Via de Transporte / Origem no Cadastro de Fretes"
              RETURN .F.
           ENDIF
        ENDIF

        IF !lOk
           DI500AtuDtEta("ETA")
        ENDIF

   CASE cNomeCampo == 'W6_DT_ETA'

        IF !lOk
           DI500AtuDtEta("PRD")
        ENDIF

   CASE cNomeCampo == 'W6_MSG_COM'
        SY7->(DBSETORDER(3))
        IF !EMPTY(M->W6_MSG_COM) .AND. !SY7->(DBSEEK(xFilial()+AVKEY('4','Y7_POGI')+M->W6_MSG_COM))
           Help(" ",1,"REGNOIS",,cPasta,5,0)
           SY7->(DBSETORDER(1))
           Return .F.
        ENDIF
        SY7->(DBSETORDER(1))
//CCH - 21/11/2008 - Removida a validação pois não é necessária a amarração do nro da viagem com a embarcação

  /* CASE cNomeCampo == 'W6_IDENTVE'		//JWJ 06/09/2006 - Release 4
        //SX3->(DBSETORDER(2))
        IF SW6->(FIELDPOS("W6_VIAGEM")) # 0 .AND. (ALLTRIM(SX3->X3_F3) == "EE6")
           IF !Empty(M->W6_IDENTVE)
              EE6->(DBSETORDER(1))
              IF !EE6->(DBSEEK(xFilial()+M->W6_IDENTVE))
                 MSGINFO("Codigo do Navio nao cadastrado no sistema.")
                 lRet := .F.
              ELSE
                 M->W6_VIAGEM := EE6->EE6_VIAGEM
                 lRet := .T.
              ENDIF
           Else
              M->W6_VIAGEM := ""
              lRet := .T.
           ENDIF
        ENDIF

   CASE cNomeCampo == 'W6_VIAGEM'		//JWJ 06/09/2006 - Release 4
        //SX3->(DBSETORDER(2))
        IF SW6->(FIELDPOS("W6_VIAGEM")) # 0
           IF !Empty(M->W6_IDENTVE) .AND. EMPTY(M->W6_VIAGEM)
              MSGINFO("Codigo de Viagem nao preenchido.")
              lRet := .F.
           ELSEIF !Empty(M->W6_IDENTVE) .AND. !EMPTY(M->W6_VIAGEM)
	          EE6->(DBSETORDER(1))
	          IF !EE6->(DBSEEK(xFilial()+M->W6_IDENTVE+M->W6_VIAGEM))
	             MSGINFO("Navio e Codigo de Viagem nao cadastrados.")
	             lRet := .F.
	          ENDIF
	       ELSEIF Empty(M->W6_IDENTVE) .AND. !EMPTY(M->W6_VIAGEM)
	          MSGINFO("Codigo de Viagem nao pode ser preenchido sem preencher o Navio.")
	          M->W6_VIAGEM := ""
	          lRet := .F.
	       ENDIF
        Else
           lRet := .T.
        ENDIF */

   CASE cNomeCampo == "W6_DEMERCO"  // EOB - 10/03/08 - campos ref. ao Mercosul
     If !lEJ9
        SYA->(dbSetOrder(1))
        IF !EMPTY(M->W6_DEMERCO)
           IF !EMPTY(M->W6_PAISPRO) .AND. SYA->(dbSeek(xFilial("SYA")+M->W6_PAISPRO)) .AND. SYA->YA_MERCOSU $ cSim
              IF M->W6_TIPODES $ "16,17,20,21,22"
                 MSGINFO(STR0550)
                 lRet := .F.
     	      ELSE
      	         lRet := .T.
      	      ENDIF
      	   ELSE
	  	      MSGINFO(STR0551)
      	      lRet := .F.
           ENDIF
        ELSE
        	M->W6_REINIC  := SPACE(LEN(SW6->W6_REINIC))
        	M->W6_REFINAL := SPACE(LEN(SW6->W6_REFINAL))
   		ENDIF
   	 EndIF

   CASE cNomeCampo == 'W6_FORNECF' //AOM - 17/06/2011

      IF !EMPTY(M->W6_FORNECF)
         SA2->(DBSETORDER(1))
         If !(SA2->(DbSeek(xFilial("SA2") + AvKey(M->W6_FORNECF,"A2_COD"))))
            MSGINFO(STR0807,STR0804) //STR0807 "O Fornecedor informado não está cadastrado." //STR0804 "Atenção"
            lRet := .F.
         EndIf
      ENDIF


   CASE cNomeCampo == 'W6_FORNECS' //AOM - 17/06/2011

      IF !EMPTY(M->W6_FORNECS)
         SA2->(DBSETORDER(1))
         If !(SA2->(DbSeek(xFilial("SA2") + AvKey(M->W6_FORNECS,"A2_COD"))))
            MSGINFO(STR0807,STR0804) //STR0807 "O Fornecedor informado não está cadastrado." //STR0804 "Atenção"
            lRet := .F.
         EndIf
      ENDIF

// GFP - 03/10/2011
   CASE cNomeCampo == "W6_CORRETO"
         IF EasyGParam("MV_EASYFIN") $ cSim
            IF !EMPTY(M->W6_CORRETO)
               SYW->(DBSETORDER(1))
               IF !SYW->(DBSEEK(xFilial()+M->W6_CORRETO))
                  MsgStop(STR0808,STR0804) //STR0808 "Corretor não cadastrado." //STR0804 "Atenção"
                  RETURN .F.
               ELSE
                  IF Empty(SYW->YW_FORN)
                     MsgStop(STR0809,STR0804) //STR0804 "Atenção" //STR0809 "O Corretor selecionado não possui Fornecedor/Loja cadastrado."
                     Return .F.
                  ENDIF
               ENDIF
            ELSE
               RETURN .t.
            ENDIF
         ELSE
            RETURN .T.
         ENDIF
   CASE cNomeCampo == "OK"
      if SYD->(dbsetorder(1),dbSeek(xFilial()+M->W7_NCM))
         if (!empty(SYD->YD_EX_NCM) .and. empty(M->W7_EX_NCM)) .or. (!empty(SYD->YD_EX_NBM) .and. empty(M->W7_EX_NBM))
            MsgStop(STR0901,STR0804) // "A NCM informada contém códigos N.C.M.s e N.B.M. cadastrados e deve ser informado."
            lRet := .F.
         endif
      endif
   CASE cNomeCampo == "W6_FORMREG"      
      If M->W6_FORMREG == "1" .And. EV1->(FieldPos("EV1_VERSAO")) == 0         
         EasyHelp(STR0913, STR0558, STR0914) //A opção de integração com a DUIMP ainda não está disponível. Neste momento somente é possível informar dados registrados pelo usuário diretamente no Portal Único" ## ATENCAO ## "Será necessário aguardar a implementação da rotina de integração com a DUIMP"
         lRet := .F. //tem que ser lret true para seguir pros gatilhos que limpam os campos di manual, dt manual, etc e bloqueio de edição dos campos         
      EndIf
   CASE cNomeCampo == "W6_VSMANU"
      If Empty(M->W6_REGMANU) .And. !Empty(M->W6_VSMANU) 
         EasyHelp(STR0918, STR0558,STR0919) //"Campo de DUIMP Manual não foi Preenchido" ## AViso ## "Preencha primeiro o campo DUIMP Manual para depois preencher a versão Manual"
         lRet := .F.
      EndIf
   CASE cNomeCampo == "W6_DTMANU" 
      If Empty(M->W6_REGMANU) .And. !Empty(M->W6_DTMANU) 
         EasyHelp(STR0920, STR0558,STR0921) //"Campo de DUIMP Manual não foi Preenchido" ##Aviso ## "Preencha primeiro o campo DUIMP Manual para depois preencher a Data de Registro Manual"
         lRet := .F.
      EndIf
   CASE cNomeCampo == "W6_REGMANU" 
      If AvFlags("DUIMP") .AND.  M->W6_TIPOREG == DUIMP 
         M->W6_DI_NUM := M->W6_REGMANU
         lRet := DI_VALID("W6_DI_NUM")
      EndIf   
ENDCASE

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"DEPOIS_VALID_SW6"),)
lRefresh := .T.

restArea(aAreaSW6)

RETURN lRet


Function DI500IniciaCapa(cPO,lCarregaItens,lLocSW6)

LOCAL lOk:=.T.,cCpoSW,lGrvnaCapa:=.F.,oDlgSelec, P
LOCAL cMAlias:=IF(lLocSW6,"M->W6_","M->W9_"),nRecno
LOCAL aPedUsado:={},nOrder:=Work->(INDEXORD()), nCpos
PRIVATE lSW6:=lLocSW6,cCpoNaoInicia:=""
PRIVATE cCpoNaoPreenche:=if(cPaisLoc # "BRA","M->W6_FORN","")     //NCF - 28/07/09
IF lCarregaItens .AND. lSW6
   Processa({|| lOk:=DI500WorkGrava() },STR0054) //"Pesquisa de Itens"
ENDIF

IF EMPTY(cPO)

   WORK->(DBGOTOP())
   DO WHILE Work->(!EOF())
      IF !WORK->WKFLAG
         WORK->(DBSKIP())
         LOOP
      ENDIF
      IF ASCAN(aPedUsado,Work->WKPO_NUM) == 0
         AADD(aPedUsado,Work->WKPO_NUM)
      ENDIF
      Work->(DBSKIP())
   ENDDO

   IF LEN(aPedUsado) = 1
      cPO:=aPedUsado[1]
   ENDIF
   lOk:=.F.

ENDIF

IF !lSW6 .AND. EMPTY(cPO) .AND. !EMPTY(aPedUsado)

   cPO:=aPedUsado[1]
   lOk:=.F.

   DEFINE MSDIALOG oDlgSelec TITLE STR0523 FROM 0,0 TO 200,290 OF oMainWnd PIXEL//"Selecionar Pedido Base"

     @ 2.5,.5 SAY AVSX3("W2_PO_NUM",5)//"Pedido"
     @ 2.5,04 LISTBOX oLbx1 VAR cPO ITEMS aPedUsado SIZE 50,60 OF oDlgSelec

     @ 17,02 CHECKBOX lGrvnaCapa PROMPT STR0524 SIZE 200,10 OF oDlgSelec PIXEL //"Considerar o Pedido como Base p/ as Invoices"

   ACTIVATE MSDIALOG oDlgSelec ON INIT DI500EnchoiceBar(oDlgSelec,{{|| lOk:=.T.,oDlgSelec:End() },"OK"},;
                                                                   {|| lOk:=.F.,oDlgSelec:End() },.F.) CENTERED

   IF !lOk
      RETURN .F.
   ENDIF
   IF lGrvnaCapa
      M->W6_PO_NUM:=cPO
   ENDIF

ENDIF

IF lOk
   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ANTES_INICIA_SW6_SW9"),)

   //AvStAction("201",.F.)//AWR 17/03/2009
   //OAP - Substituição feita no antigo EICPOCO
   IF EasyGParam("MV_EIC_PCO",,.F.)
      cCpoNaoInicia += ",M->W6_IMPCO,M->W6_IMPENC"
   ENDIF


   SW2->(DBSETORDER(1))
   SX3->(DBSETORDER(2))
   IF SW2->(DBSEEK(xFilial()+cPO))
      FOR nCpos := 1 TO SW2->(FCOUNT())
          cCpoSW:=cMAlias+SUBSTR(SW2->(FIELDNAME(nCpos)),4)
          IF TYPE(cCpoSW) $ "CD"
             IF SX3->(DBSEEK(SUBSTR(cCpoSW,4))) .AND. X3USO(SX3->X3_USADO) .AND. !(cCpoSW$cCpoNaoInicia)
                IF !(cCpoSW $ cCpoNaoPreenche)   // NCF - 28/07/09
                   &(cCpoSW):=SW2->(FIELDGET(nCpos))//W6_PO_NUM,W6_AGENTE,W6_ORIGEM,W6_DEST,W6_IMPORT,W6_TAB_PC,W6_DESP,W6_ARMAZEM
                ENDIF
                /* LDB 20/06/2006 Chamado 031083 (Processar Gatilhos) */
                If SX3->X3_TRIGGER == "S"
                   RunTrigger(1)
                EndIf
             ENDIF
          ENDIF
      NEXT

      IF lSW6
         IF !("W6_VIA_TRA" $ cCpoNaoInicia)
            M->W6_VIA_TRA:=SW2->W2_TIPO_EM
            SYQ->(DBSETORDER(1))
            SYQ->(DBSEEK(xFilial()+M->W6_VIA_TRA))
            M->W6_DESCVIA:=SYQ->YQ_DESCR
         ENDIF
         M->W6_REC_ALF := SW2->W2_ARMAZEM
         M->W6_VM_RECA := Posicione("SJA",1,xFilial("SJA") + SW2->W2_ARMAZEM ,"JA_DESCR")
      ELSE
         M->W9_MOE_FOB	:=SW2->W2_MOEDA
         M->W9_DIAS_PA	:=SW2->W2_DIAS_PA
         M->W9_FORN		:= SW2->W2_FORN // SVG - 11/05/09 -
         If EICLoja()
            M->W9_FORLOJ	:= SW2->W2_FORLOJ
         EndIf
      ENDIF

      IF !lSW6
         nRecno:=Work_SW9->(Recno())
         Work_SW9->(DBGOTOP())
         DO WHILE !Work_SW9->(EOF())
            IF !EMPTY(Work_SW9->W9_TX_FOB) .AND. Work_SW9->W9_MOE_FOB == M->W9_MOE_FOB
               M->W9_TX_FOB:=Work_SW9->W9_TX_FOB
               EXIT
            ENDIF
            Work_SW9->(DBSKIP())
         ENDDO
         Work_SW9->(DBGOTO(nRecno))
         IF EMPTY(M->W9_TX_FOB) .AND. lBuscaTaxaAuto
            M->W9_TX_FOB:=BuscaTaxa(M->W9_MOE_FOB,DI500DtTxInv(),.T.,.F.,.T.)
         ENDIF
      ENDIF
      SY5->(DBSETORDER(1))
      SY5->(DBSEEK(xFilial()+M->W6_DESP))
      M->W6_DESPNOM:=SY5->Y5_NOME
      SYT->(DBSETORDER(1))
      SYT->(DBSEEK(xFilial()+M->W6_IMPORT))
      M->W6_IMPORVM:=SYT->YT_NOME_RE
      IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"INICIA_SW6_SW9"),)
      //SVG - 20/12/10 - Preenchimento dos campos, apos o preenchimento do po base.
      SW5->(DBSETORDER(3))
      SW5->(DBSEEK(XFILIAL("SW5")+CPO))
      SW4->(DBSETORDER(1))
      SW4->(DBSEEK(XFILIAL("SW4")+SW5->W5_PGI_NUM))
      SJ0->(DBSETORDER(1))
      If Empty(M->W6_URF_DES)
         M->W6_URF_DES := SW4->W4_URF_DES
      EndIf
      If Empty(M->W6_URF_ENT)
         M->W6_URF_ENT := SW4->W4_URF_CHE
      EndIf
      SJ0->(DBSEEK(xFilial("SJ0")+M->W6_URF_ENT))
      If Empty(M->W6_VM_UENT)
         M->W6_VM_UENT :=SJ0->J0_DESC
      EndIf
      SJ0->(DBSEEK(xFilial("SJ0")+M->W6_URF_DES))
      If Empty(M->W6_VM_UENT)
         M->W6_VM_UENT :=SJ0->J0_DESC
      EndIf
      If Empty(M->W6_VM_UDES)
         M->W6_VM_UDES:=SJ0->J0_DESC
      EndIf
   ENDIF
   SX3->(DBSETORDER(1))
ENDIF

RETURN .T.

Function DI500Controle(nControle,aDadosComp)

LOCAL W
STATIC aDadosSW6
STATIC lAlterou
STATIC lAlterouSW6
IF cPaisLoc  # "BRA"// AWR - 6/8/2004 - Essa funcao é chamda da funcao DI_VALID() que é chamada do dicionario (SX3)
   RETURN .T.       // que por sua vez é usado o SW6 em conjunto com o EICDI600.PRW
ENDIF
IF nControle = 0
   aDadosSW6  := ACLONE(aDadosComp)
   lAlterou   := !M->W6_ADICAOK $ cSim
   lAlterouSW6:= .F.
ENDIF

IF nControle = 1
   M->W6_ADICAOK:= NAO
   lAlterou     := .T.
   RETURN .F.
ENDIF

IF nControle = 2
   FOR W := 1 TO LEN(aDadosComp)
      IF aDadosComp[W,1] # aDadosComp[W,2]
         M->W6_ADICAOK := NAO
         lAlterou := .T.
         RETURN .F.
      ENDIF
   NEXT
ENDIF

IF nControle = 3
   lAlterouSW6 := .F.
   FOR W := 1 TO LEN(aDadosComp)
       IF aDadosComp[W] # aDadosSW6[W]
          M->W6_ADICAOK:= NAO
          lAlterouSW6  := .T.
          RETURN .F.
       ENDIF
   NEXT
   IF !lAlterouSW6 .AND. !lAlterou
      M->W6_ADICAOK:= SIM
   ENDIF
ENDIF

RETURN .T.


FUNCTION DI500CUSTO()

lValida:=.T.

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"VALIDA_OK"),)

RETURN lValida

Function DI400ENC(nTipo, cCampo)//Funcao chamada do X3_WHEN de varios campos
//Funcao que valida se a data de encerramento esta preenchida e nao permitir a edicao
//de certos campos

Default cCampo := ""

DO CASE
   CASE nTipo = 1  // Somente data de encerramento
        IF !EMPTY(M->W6_DT_ENCE)
           RETURN .F.
        EndIf

        Return VerifDUIMP()

   CASE nTipo = 2 //data de encerramento ou Data contabil ou Nota Fiscal ou Nao Tem DI
        IF !EMPTY(M->W6_DT_ENCE) .OR. !DI500CTB() .OR. DITEMNFE(.T.)
           RETURN .F.
        EndIf

   CASE nTipo = 3 // data de encerramento ou Nota fiscal ou Integrado com SIGAECO
        IF !EMPTY(M->W6_DT_ENCE) .OR. DITEMNFE() .OR. !DI500CTB() 
           RETURN .F.
        EndIf

         If cCampo  == "M->W6_DI_NUM" 
            If M->W6_CURRIER $ cSim
               RETURN .F.
            EndIf
         EndIf
      
        If AvFlags("DUIMP") .And. (cCampo == "W6_DI_NUM" .Or. cCampo == "W6_DTREG_D")
           If M->W6_TIPOREG == DUIMP 
              RETURN .F.
           EndIf
        EndIf

        Return VerifDUIMP()
   CASE nTipo = 4 // data de encerramento e possui parcela Baixada
        IF !EMPTY(M->W6_DT_ENCE) .OR. !lNoBaixa
           RETURN .F.
        EndIf


  // LBL - 01/07/2013

   CASE nTipo = 5 //Verifica se a NFE foi enviada ao SEFAZ e bloqueia o campo Data de Desembaraço
		aOrd := SaveOrd({"SF1"})
        SF1->(DbSetOrder(5))
        SF1->(DbSeek(XFILIAL()+AvKey(M->W6_HAWB,"W6_HAWB")))
           DO WHILE SF1->(!EOF()) .AND. XFILIAL("SW6")+AvKey(M->W6_HAWB,"W6_HAWB") == XFILIAL("SF1")+AvKey(SF1->F1_HAWB,"F1_HAWB")
              IF !Empty(SF1->F1_CHVNFE)
                 RestOrd(aOrd,.T.)
                 RETURN .F.
              EndIf
              SF1->(dbSkip())
  		   EndDo

   Case nTipo == 6 /* campos taxa, frete e seguro da invoice (SW9) */
      If AvFlags("EAI_PGANT_INV_NF") .And. IntegPendente() //Pendências de integração com o Financeiro do ERP
         Return .F.
      EndIf


   Case nTipo == 7 /* número da D.I. e versão, para cenários sem D.I. eletrônica (MV_TEM_DI = .F.)*/

      If !EasyGParam("MV_TEM_DI",, .F.)
         If !Empty(M->W6_DI_NUM) .And. !Empty(M->W6_VERSAO) .And. M->W6_VERSAO <> "00"
            Return .F.
         EndIf
      EndIf

   // nTipo == 8 - Utilizado para o campo W6_CURRIER - Fica editável se não tem invoice ou quando o W6_TIPOREG é diferente de DUIMP
   // nTipo == 9 - Utilizado para o campo W6_TIPOREG - só pode ser editável enquanto não houver Invoice no processo
   Case nTipo == 8 .or. nTipo == 9//MFR 27/07/2021 OSSME-6090 Tipo Registro 1=DI 2=DUIMP deixar não editável quando tiver invoice

      if (nTipo == 8 .and. AvFlags("DUIMP") .and. M->W6_TIPOREG == DUIMP) .or. nTipo == 9
         if lPrimeiraVez
            Return Empty(Alltrim(Posicione("SW9",3,xFilial("SW9")+M->W6_HAWB,"W9_INVOICE"))) 
         Else
            Return Work_SW9->(EasyRecCount("Work_SW9")) == 0 
         EndIf
      endif

   Case nTipo == 10 // Verifica se o processo é do tipo DUIMP, Integrado e se já está registrado.
      Return VerifDUIMP()

   OtherWise

      Return .T.

ENDCASE

Return .T.

Static Function VerifDUIMP()
Local lRet := .T.

   If AvFlags("DUIMP") .and. M->W6_TIPOREG == DUIMP .and. M->W6_FORMREG == DUIMP_INTEGRADA .and. !Empty(M->W6_DTREG_D)
      lRet := .F.
   EndIF

Return lRet

FUNCTION DITEMNFE(lCampo)//Funcao chamada do X3_WHEN de varios campos

LOCAL lRetorno:=.T.
DEFAULT lCampo := .F.
IF lTemNFE
   lRetorno:=.T.//Nao Edita o Campo
ELSE
   lRetorno:=.F.//Edita o Campo
ENDIF
IF lRetorno == .F. .AND. DI500CTB()==.F.
   lRetorno := .T.//Nao Edita o Campo
ENDIF
IF lRetorno == .F. //Edita o Campo
   IF lCampo .AND. !lTemAdicao
      lRetorno:=.T.//Nao Edita o Campo
   ENDIF
ENDIF

If AvFlags("EAI_PGANT_INV_NF") .And. IntegPendente() //Pendências de integração com o Financeiro do ERP
   lRetorno:= .T. //não edita o campo
EndIf

RETURN lRetorno

//Funcao que valida se a data contabil esta preenchida e nao permitir a edicao
//de certos campos

Function DI500CTB()//Antiga DI400CTB()

IF GetNewPar("MV_EIC_ECO","N") $ cSim
   IF !Inclui .AND. !EMPTY(SW6->W6_CONTAB) .and. !Empty(SW6->W6_DI_NUM)
      RETURN .F.
   ENDIF
EndIf
Return .T.

//Funcao destinada a inicializar a data ETA na inclusao de processos.
//Utilizada atraves do valid do dicionario SX3.

Function DI500AtuDtEta(cCalcDt)//Antiga Di_AtuDtEta()  // by CAF 24/09/1998 14:19

LOCAL nSYR_Ordem := SYR->(IndexOrd())
LOCAL nSYR_Recno := SYR->(Recno())
SX3->(DBSETORDER(2))

IF M->W6_CALCAUT == "1"   // EOS - se o campo estiver com SIM, calcular as datas segundo os lead times
 //M->W6_CALCAUT := "1"   // GFP - 02/03/2013 - Manter sempre habilitada quando efetuar o calculo.  // GFP - 29/05/2013 - Sistema não deve forçar atualização da data ETA.
   SY9->(DBSETORDER(2))
   IF cCalcDt == "ETA"
      SYR->(dbSetOrder(1))  // Filial+Yr_Via+Yr_Origem...
      IF !SYR->(dbSeek(xFilial()+M->W6_VIA_TRA+M->W6_ORIGEM+M->W6_DEST))
         SYR->(dbSetOrder(nSYR_Ordem))
         SYR->(dbGoTo(nSYR_Recno))
         Return .T.
      ENDIF

      IF !Empty(M->W6_DT_EMB)
         M->W6_DT_ETA := M->W6_DT_EMB + SYR->YR_TRANS_T
      ELSEIF ! Empty(M->W6_DT_ETD)
         M->W6_DT_ETA := M->W6_DT_ETD + SYR->YR_TRANS_T
      ENDIF
      cCalcDt := "PRD"
   ENDIF
   IF cCalcDt == "PRD"
      IF !Empty(M->W6_CHEG)
         M->W6_PRVDESE := M->W6_CHEG + IF(SY9->(DBSEEK(xFilial()+M->W6_DEST)),SY9->Y9_LT_DES,EasyGParam("MV_LT_DESE"))
      ELSEIF ! Empty(M->W6_DT_ETA)
         M->W6_PRVDESE := M->W6_DT_ETA + IF(SY9->(DBSEEK(xFilial()+M->W6_DEST)),SY9->Y9_LT_DES,EasyGParam("MV_LT_DESE"))
      ENDIF
      cCalcDt := "PRE"
   ENDIF
   IF cCalcDt == "PRE"
      IF !Empty(M->W6_DT_DESE)
         M->W6_PRVENTR := M->W6_DT_DESE + IF(SY9->(DBSEEK(xFilial()+M->W6_DEST)),SY9->Y9_LT_TRA, 0)
      ELSEIF !EMPTY(M->W6_PRVDESE)
         M->W6_PRVENTR := M->W6_PRVDESE + IF(SY9->(DBSEEK(xFilial()+M->W6_DEST)),SY9->Y9_LT_TRA, 0)
      ENDIF
   ENDIF
   SY9->(DBSETORDER(1))
ENDIF

SYR->(dbSetOrder(nSYR_Ordem))
SYR->(dbGoTo(nSYR_Recno))
lRefresh := .T.

Return .T.


Function DI500AlterValid(bValid,lValCampos,lLValidCambio,lAltTaxa)//Antiga DI400NFCamVal()

LOCAL x3ord:= SX3->(INDEXORD())
DEFAULT lLValidCambio:= .F.
DEFAULT lAltTaxa     := .F.

PRIVATE lValidCambio:= lLValidCambio
PRIVATE lAlteraTaxa:= lAltTaxa
PRIVATE lValNota   := .T.

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"INICIO_ALTERVALID"),)

IF lValCampos
   IF !Obrigatorio(aGets,aTela) .or. !Eval(bValid)
      RETURN .F.
   ENDIF
ENDIF

IF !lNoBaixa .AND. lLValidCambio // Bete 14/10/05 - Testar baixa somente se o parametro de validacao de cambio estiver .T.
   EICFI400('MENSAGEM')
   RETURN .F.
ENDIF

SF1->(DBSETORDER(5))
SWD->(DbSetOrder(1))

IF SF1->(DBSEEK(xFilial()+SW6->W6_HAWB)) .OR. lTemNFE
   IF lValNota
      //ISS - 13/12/10 - Verificação se o HAWB corrente possui alguma nota gerada, e não apenas notas de despesas (NFD)
      If(lCposNFDesp)
         If ExistHAWBNFE(SW6->W6_HAWB)
            Help("", 1, "AVG0000247")//Itens do processo nao podem ser alterados, pois o processo possui NF(s)
            SF1->(DBSETORDER(1))
            RETURN .F.
         EndIf
      Else
         Help("", 1, "AVG0000247")//Itens do processo nao podem ser alterados, pois o processo possui NF(s)
         SF1->(DBSETORDER(1))
         RETURN .F.
      Endif
   EndIf
ENDIF
SF1->(DBSETORDER(1))

SX3->(DBSETORDER(2))
IF lTem_ECO .AND. SX3->(DBSEEK("W6_CONTAB"))
   IF !EMPTY(SW6->W6_CONTAB) .and. !Empty(SW6->W6_DI_NUM)
     Help("", 1, "AVG0000248")//Itens do processo nao podem ser alterados, -processo Contabilizado
     SX3->(DBSETORDER(x3ord))
     RETURN .F.
   Endif
ENDIF
SX3->(DBSETORDER(x3ord))

If MOpcao = FECHTO_DESEMBARACO .OR. MOpcao == FECHTO_NACIONALIZACAO
   IF SW7->(DBSEEK(xFilial()+M->W6_HAWB))
      IF _Declaracao
         IF SW7->W7_FLUXO # "4"
            Help(" ",1,"E_ENTRPNAO")//"HOUSE NAO eh ENTREPOSTADO
            Return .F.
         ENDIF
      ELSE
         IF SW7->W7_FLUXO = "4"
            Help(" ",1,"E_ENTRPSIM")//"HOUSE eh ENTREPOSTADO
            Return .F.
          ENDIF
      ENDIF
   ENDIF
ENDIF

If !Empty(SW6->W6_DT_ENCE)
   If MsgYesNo(STR0075,STR0141) # .T. //"Processo j  encerrado - Deseja alter -lo ?"###"Alteração de Processo"
      Return .F.
   Endif
Endif

IF nPos_aRotina # INCLUSAO .AND. !EMPTY(M->W6_DTREG_D) .AND. !lRetifica .AND. lTemAdicao // AWR - 18/01/05
   MsgInfo(STR0667) //STR0667 "Não pode haver alterações a partir desta ação pois o processo encontra-se com a declaração registrada."
   Return .F.
ENDIF

lValida:=.T.
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ALTERVALID"),)

RETURN lValida

/*--------------------------------------------------------------------------------------------------
Funcao      : ValidCambio
Parametros  : lMsg - Exibe ou não a Mensagem de aviso.
Retorno     : Retorna .T. caso haja câmbio de adiantamento ou cambio liquidado ou .F. caso contrário
Objetivos   : Validar a exibição do botão de exclusão das invoices na tela de Manutenção de Invoices
Autor       : Nilson César
Data/Hora   : 28/10/2009
Revisao     : 29/10/2009
Obs.        : Trecho de código tranformado em função, anteriormente era parte integrante das funções
              DI500W9Manut e D500AlterValid
*----------------------------------------------------------------------------------------------------*/

FUNCTION ValidCambio(lMsg,cOrigem)

LOCAL lTemAdto := .F.
LOCAL lCambLiq := .F.
LOCAL lRetorno := .F.
LOCAL aOrdWB   := {}
LOCAL aOrdE2   := {}    //TRP- 02/02/2010
Local lTemInvoice:=.F. //SVG - 01/09/2011 - Verificação se tem invoice para checar o cambio correto
Local nRecnoWKSW8 := 0
Local aOrdWK9 := {}
DEFAULT lMsg   := .F.
Default cOrigem := "GERAL"

Private lRetValCamb:= .F.

// Bete 06/09/05 - verificacao se no cambio ha adiantamentos vinculados
aOrdWB := SaveOrd("SWB")
aOrdWK9 := SaveOrd("Work_SW9")
IF lCposAdto .AND. AvKey(M->W6_HAWB,"W6_HAWB") == AvKey(WORK->WKPO_NUM,"W6_HAWB") //LRS - Validar o adiantamento do Câmbio somente se o item selecionado for do processo
   lTemAdto := .F.
   cFilSWB := xFilial("SWB")
   SWB->(dbSetorder(1))
   SWB->(DBSEEK(cFilSWB + M->W6_HAWB + "D"))
   DO WHILE !SWB->(eof()) .AND. SWB->WB_FILIAL==cFilSWB .AND. SWB->WB_HAWB==M->W6_HAWB .AND. SWB->WB_PO_DI=="D"
      IF Left(SWB->WB_TIPOREG,1) == "P"
         lTemAdto := .T.
         EXIT
      ENDIF
      SWB->(dbSkip())
   ENDDO
   IF lTemAdto
      IF lMsg
         MSGINFO(STR0668) //STR0668 "Atencao! Existem adiantamentos vinculados p/ este processo no cambio"
      ENDIF
      lAltSoTaxa := .T.	//ASR 03/11/2005 - PERMITE ALTERAR APENAS A TAXA DA INVOICE QUANDO O PROCESSO TIVE TITULO - RETURN .F.
   ENDIF
ENDIF

RestOrd(aOrdWB, .T.)

// SVG - 01/09/2011
If cOrigem == "Itens"
   nRecnoWKSW8 := WORK_SW8->(Recno())
   WORK_SW8->(dbSetOrder(2)) // WKFORN+WKPO_NUM+WKPOSICAO+WKPGI_NUM
   If WORK_SW8->(dbSeek(WORK->WKFORN+WORK->WKPO_NUM+WORK->WKPOSICAO+WORK->WKPGI_NUM)) //Verifica se o item esta contido em alguma invoice
      WORK_SW9->(dbSetOrder(1))
      If WORK_SW9->(dbSeek(WORK_SW8->WKINVOICE))
         lTemInvoice:=.T.
      EndIf
   EndIf
   WORK_SW8->(dbGoTo(nRecnoWKSW8))
EndIf
If lTemInvoice .Or. cOrigem <> "Itens"
   //RMD - 11/07/08 - Valida se existe cambio liquidado, caso positivo não permite alteração da invoice.
   aOrdWB := SaveOrd("SWB")
   aOrdE2 := SaveOrd("SE2")   //TRP- 02/02/2010
   SWB->(DbSetOrder(1))
   SWB->(DbSeek(xFilial("SWB")+M->W6_HAWB+"D"+Work_SW9->(W9_INVOICE+W9_FORN)+WORK_SW9->W9_FORLOJ))
   While SWB->(!Eof() .And. WB_FILIAL+WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN == xFilial("SWB")+M->W6_HAWB+"D"+Work_SW9->(W9_INVOICE+W9_FORN) .And. (!EICLoja() .Or. SWB->WB_LOJA == WORK_SW9->W9_FORLOJ) )
      If !Empty(SWB->WB_CA_DT)
         lCambLiq := .T.
         Exit
      EndIf

      //TRP - 02/02/2010 - Valida a compensação de parcelas no financeiro.
      If lFinanceiro
         SE2->(DbSetOrder(6))
         If SE2->(dbSeek(xFilial("SE2")+SWB->(WB_FORN+WB_LOJA+WB_PREFIXO+WB_NUMDUP+WB_PARCELA)))
            If SE2->E2_VALOR <> SE2->E2_SALDO
     	       lCambLiq := .T.
               Exit
     	    Endif
         Endif
      Endif

      SWB->(DbSkip())
   EndDo
EndIf

RestOrd(aOrdWK9, .T.)
RestOrd(aOrdWB, .T.)
RestOrd(aOrdE2, .F.)   //TRP- 02/02/2010
If lCambLiq
   IF lMsg
      //MsgInfo(STR0557, STR0558)//"Existe uma ou mais parcelas de câmbio com liquidação para esta invoice. Para efetuar alterações, estorne a liquidação das parcelas."###"Aviso"
      MSGINFO(STR0796)//STR0796 "Atencao! Existe uma ou mais parcelas de câmbio com liquidação/compensação para esta invoice"
   ENDIF
   lAltSoTaxa := .T.
EndIf

lRetorno := lCambLiq .OR. lTemAdto
IF lRetorno
   lTemCambio := .T.
ENDIF

lRetValCamb:= lRetorno

//TRP - 20/10/2011 - PE para tratar o chamado 089807 - Merck
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"RET_VALID_CAMB"),)

Return lRetValCamb

/**
 * EJA - 24/10/2018 - Verifica se o desembaraço tem câmbio algum câmbio liquidado.
 * Retorna .T. se tem algum câmbio liquidado, retorna .F. se não existir câmbio liquidado.
 */
Static Function desCambLiq(lMsg)
Local aOrdSW9 := SaveOrd("SW9")
Local lCambLiq := .F.
SW9->(dbSeek(xFilial("SW9")+SW6->W6_HAWB))
While SW9->(!Eof() .And. SW9->W9_HAWB == SW6->W6_HAWB)
    lCambLiq := invCambLiq(lMsg)
    If lCambLiq
        Exit 
    EndIf
    SW9->(DbSkip())
EndDo
RestOrd(aOrdSW9, .T.)
Return lCambLiq

/**
 * EJA - 24/10/2018 - Valida se uma invoice tem câmbio liquidado.
 */
Static Function invCambLiq(lMsg)
Local lCambLiq := .F.
Local aOrdWB := SaveOrd("SWB")

SWB->(DbSeek(xFilial("SWB")+SW6->W6_HAWB+"D"+SW9->(W9_INVOICE+W9_FORN)+EICRetLoja("SW9", "W9_FORLOJ")))
While SWB->(!Eof() .And. WB_FILIAL+WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN == xFilial("SWB")+SW6->W6_HAWB+"D"+SW9->(W9_INVOICE+W9_FORN) .And. (!EICLoja() .Or. SWB->WB_LOJA == EICRetLoja("SW9", "W9_FORLOJ")) )
    If !Empty(SWB->WB_CA_DT)
        lCambLiq := .T.
        Exit
    EndIf
    SWB->(DbSkip())
EndDo
RestOrd(aOrdWB, .T.)

If lCambLiq
    If lMsg
      //MsgInfo(STR0557, STR0558)//"Existe uma ou mais parcelas de câmbio com liquidação para esta invoice. Para efetuar alterações, estorne a liquidação das parcelas."###"Aviso"
      MSGINFO(STR0796)//STR0796 "Atencao! Existe uma ou mais parcelas de câmbio com liquidação/compensação para esta invoice"
   EndIf
EndIf

Return lCambLiq

FUNCTION DI500Existe()//Antiga DI_Existe(bMsg)

LOCAL cFilSW7:=xFilial("SW7")
LOCAL nCont:=0
Local cTmpTabSW7, cQuery, cSelect, cFrom , cWhere, nOldArea, lRetLoop

aPedido:={}
aPLI:={}
lPrimeiraVez:=.F.

SA5->(DBSETORDER(3))
SB1->(DBSETORDER(1))
SW2->(DBSETORDER(1))
SW4->(DBSETORDER(1))
SW7->(DBSETORDER(1))
SW9->(DBSETORDER(3))
SWP->(DBSETORDER(1))
Work->(DBSETORDER(3))
lMostMsgNVE := .T.
DBSELECTAREA("SW7")

   cSelect := " SELECT TABSW7.*"
   cFrom   := " FROM " + RetSQLNAME("SW7") + " TABSW7"
   cWhere  := " WHERE" + iIF( TcSrvType()=="AS/400"," TABSW7.@DELETED@ <> '*' "," TABSW7.D_E_L_E_T_ <> '*'" )
   cWhere  += " AND TABSW7.W7_HAWB    = '"+ M->W6_HAWB +"' "
   cWhere  += " AND TABSW7.W7_FILIAL  = '"+ cfilSW7 +"' "
   cWhere  += " AND TABSW7.W7_SEQ     = 0"
   cWhere  += " AND TABSW7.W7_SALDO_Q > 0"

   cTmpTabSW7 := GetNextAlias()
   cQuery     := ChangeQuery(cSelect + cFrom + cWhere)
   nOldArea   := Select()
   MPSysOpenQuery(cQuery, cTmpTabSW7)
   DbSelectArea(cTmpTabSW7)

   nCont:= EasyQryCount(cSelect + cFrom + cWhere)
   ProcRegua(nCont)

   DO While (cTmpTabSW7)->(!Eof())
      SW7->(DbgoTo( (cTmpTabSW7)->R_E_C_N_O_ ))
      
      IncProc(STR0077+ALLTRIM(SW7->W7_COD_I)) //"LENDO ITENS DA D.I.: "

      IF MOpcao = FECHTO_DESEMBARACO .OR. MOpcao == FECHTO_NACIONALIZACAO
         IF _Declaracao
            IF SW7->W7_FLUXO # "4"
               (cTmpTabSW7)->(DbSkip())
               LOOP
            ENDIF
         ELSE
            IF SW7->W7_FLUXO = "4"
               (cTmpTabSW7)->(DbSkip())
               LOOP
            ENDIF
         ENDIF
      ENDIF

      IF ASCAN(aPedido,SW7->W7_PO_NUM) = 0
         AADD(aPedido,SW7->W7_PO_NUM)
      ENDIF
      IF SUBSTR(SW7->W7_PGI_NUM,1,1) # '*' .AND. ASCAN(aPLI,SW7->W7_PGI_NUM) = 0
         AADD(aPLI,SW7->W7_PGI_NUM)
      ENDIF

      DI500CarregaWork("W7_")//Grava SW7 na Work

      (cTmpTabSW7)->(DbSkip())
   ENDDO

   (cTmpTabSW7)->(DbCloseArea())
   DbSelectArea(nOldArea)

DI500InvCarrega()
DI500EIGrava('LEITURA',SW6->W6_HAWB,aAliasAdic)

RETURN .T.


FUNCTION DI500InvCarrega()

LOCAL cFilSW7:=xFilial("SW7")
LOCAL cFilSW8:=xFilial("SW8")
LOCAL cFilSW9:=xFilial("SW9")
LOCAL cFilSWP:=xFilial("SWP")
LOCAL cTamMemo:=AVSX3('W8_DESC_VM',3)
Local nVal_CP1 := 0
Local nVal_CP2 := 0
Local nRecSW1, nOrdSW1
Local nCont:= 0
Local cTexto:= ""

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"INV_CARREGA_INI_VAL"),)

nCont:=0
nOrdSW1 := SW1->(IndexOrd())
nRecSW1 := SW1->(Recno())

WORK->(DBSETORDER(3))
SW7->(DBSETORDER(4))
SWP->(DBSETORDER(1))
SB1->(dbSetorder(1))
SW2->(DBSETORDER(1))
SW8->(DBSETORDER(1))
SW8->(DBSEEK(xFilial()+SW6->W6_HAWB))

nCont:= EasyQryCount("select W8.W8_FILIAL from " + RetSQLName("SW8") + " W8 where W8.W8_FILIAL = '" + cFILSW8 + "' and W8.W8_HAWB = '" + SW6->W6_HAWB + "' and " + If(TcSrvType() <> "AS/400", " W8.D_E_L_E_T_ <> '*' ", " W8.@DELETED@ <> '*' "))
ProcRegua(nCont)
cTexto:= StrTran(STR0282, ":", rtrim(STR0788) + ":")
DO WHILE SW8->(!EOF()) .AND.;
         SW8->W8_HAWB   == SW6->W6_HAWB .AND.;
         SW8->W8_FILIAL == cFILSW8
   
   IncProc(cTexto + ALLTRIM(SW8->W8_COD_I)) //"Lendo Item da Invoice: "

   Work_SW8->(DBAPPEND())
   DI500GrvWkSW8(.F.)
   CarregaNVE()
   Work_SW8->WKFLAGIV    := cMarca
   Work_SW8->WKSALDO_AT  := WORK_SW8->WKQTDE
   Work_SW8->WKSALDO     := WORK_SW8->WKQTDE
   Work_SW8->WKPRTOTMOE  := DI500TRANS(WORK_SW8->WKQTDE*WORK_SW8->WKPRECO)//AWR - 19/09/2005
   Work_SW8->TRB_ALI_WT  := "SW8"
   Work_SW8->TRB_REC_WT  := SW8->(Recno())

   IF AvFlags("EIC_EAI")//AWF - 25/06/2014 - Carrega Segunda unidade para Visualização
     aSegUM:=Busca_2UM(Work_SW8->WKPO_NUM,Work_SW8->WKPOSICAO)
     IF LEN(aSegUM) > 0
        Work_SW8->WKUNI    :=aSegUM[1]
        Work_SW8->WKSEGUM  :=aSegUM[2]
        Work_SW8->WKFATOR  :=aSegUM[3]
        Work_SW8->WKQTSEGUM:=Work_SW8->WKQTDE * Work_SW8->WKFATOR
     ENDIF
  ENDIF

   If EICLoja()
     Work_SW8->W8_FORLOJ := SW8->W8_FORLOJ
     Work_SW8->W8_FABLOJ := SW8->W8_FABLOJ
   EndIf

   //AOM - 11/04/2011 - Inicializando a work SW8
   If lOperacaoEsp
      Work_SW8->W8_CODOPE := If(Empty(WORK->W7_CODOPE),SW8->W8_CODOPE,WORK->W7_CODOPE)
      Work_SW8->W8_DESOPE := Posicione("EJ0",1,xFilial("EJ0") + Work_SW8->W8_CODOPE ,"EJ0_DESC")
   EndIf
   //FSM - 01/09/2011 - "Peso Bruto Unitário"
   If lPesoBruto
      Work_SW8->WKW8PESOBR := SW8->W8_PESO_BR
   EndIf

   // BAK - Gravando da work da Invoice a partir da SI ou Invoice
   If Work_SW8->(FieldPos("WKCODMATRI")) > 0 .And. SW1->(FieldPos("W1_CODMAT")) > 0 .And. AvFlags("SUFRAMA") .And. EasyGParam("MV_TEM_DI", ,.F.)
      SW1->(DbSetOrder(1))
      If Empty(SW8->W8_CODMAT) .And. SW1->(DBSeek(xFILIAL("SW1") + AvKey(Work_SW8->WKCC,"W1_CC") + AvKey(Work_SW8->WKSI_NUM,"W1_SI_NUM") + AvKey(Work_SW8->WKCOD_I,"W1_COD_I") ))
         Work_SW8->WKCODMATRI := SW1->W1_CODMAT
      Else
         Work_SW8->WKCODMATRI := SW8->W8_CODMAT
      EndIf
   EndIf

   IF lAltDescricao .AND. !EMPTY(SW8->W8_DESC_DI)
      Work_SW8->WKDESC_DI:= MSMM(SW8->W8_DESC_DI,cTamMemo)
   ENDIF
   IF SW7->(DBSEEK(cFilSW7+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM))
      IF !lQbgOperaca//AWR - 22/12/2004 - ja foi preenchido com o W8_OPERACA
         Work_SW8->WKOPERACA:= SW7->W7_OPERACA
      ENDIF
      Work_SW8->WKPESO_L := SW7->W7_PESO
      Work_SW8->WKPESOTOT:= WORK_SW8->WKQTDE*SW7->W7_PESO
      IF lMV_PIS_EIC .AND. WORK->(DBSEEK(Work_SW8->WKPO_NUM+Work_SW8->WKPGI_NUM+Work_SW8->WKPOSICAO)) .AND. !lAUTPCDI
         Work->WKVLUPIS  := Work_SW8->WKVLUPIS
         Work->WKVLUCOF  := Work_SW8->WKVLUCOF
         Work->WKPERPIS  := Work_SW8->WKPERPIS
         Work->WKPERCOF  := Work_SW8->WKPERCOF
      ENDIF
   ENDIF
   IF SWP->(DBSEEK(cFilSWP+SW8->W8_PGI_NUM+SW8->W8_SEQ_LI))
      Work_SW8->WKREGIST := SWP->WP_REGIST
   ENDIF
// IF (lDISimples .OR. !lTemAdicao) .AND. !EMPTY(Work_SW8->WKADICAO)//AWR - 18/09/08 NFE
   IF ( lDISimples .AND. !EMPTY(Work_SW8->WKADICAO) ) .OR. (!lTemAdicao .AND. !EMPTY(IF(lExisteSEQ_ADI,Work_SW8->WKGRUPORT,Work_SW8->WKADICAO)))//AWR - 18/09/08 NFE
      Work_SW8->WKFLAGDSI :=cMarca
      Work_SW8->WKFLAG_LSI:=.T.
   ENDIF
   Work_SW8->WKDISPLOT := WORK_SW8->WKQTDE// AWR - Lote - 07/06/2004

   SB1->(dbSeek(xFilial("SB1")+Work_SW8->WKCOD_I))
   SW2->(DBSEEK(xFILIAL("SW2")+Work_SW8->WKPO_NUM))

   WORK_SW8->WKDESCITEM  := SB1->B1_DESC //SVG - 07/08/2009 -
   IF lExiste_Midia .AND. lPesoMid   // LDR - 25/08/04
      IF SB1->B1_MIDIA $ cSIM
         WORK->(DBSETORDER(3))
         WORK->(DBSEEK(Work_SW8->WKPO_NUM+Work_SW8->WKPGI_NUM+Work_SW8->WKPOSICAO))
         Work_SW8->WKQTMIDIA := SB1->B1_QTMIDIA
         Work_SW8->WKVL_TOTM := (WORK_SW8->WKQTDE*SB1->B1_QTMIDIA*SW2->W2_VLMIDIA)
         Work_SW8->WKPES_MID := (Work_SW8->WKQTDE * WORK->WKPESOMID * SB1->B1_QTMIDIA)
      ENDIF
   ENDIF

   //TRP/NCF - 28/05/10 - Diferimento
   aOrdSWZ := SaveOrd("SWZ")
   SWZ->(DBSETORDER(2))
   IF SWZ->(DbSeek(xFilial("SWZ")+Work_SW8->WKOPERACA))

      IF lICMS_Dif .AND. (nP:=ASCAN( aICMS_Dif, {|x| x[1] == Work_SW8->WKOPERACA} )) == 0
         //                Operação           Suspensao        % diferimento    % Credito presumido                % Limite Cred.   % pg desembaraco
         AADD( aICMS_Dif, {Work_SW8->WKOPERACA, SWZ->WZ_ICMSUSP, SWZ->WZ_ICMSDIF, IF( lICMS_Dif2, SWZ->WZ_PCREPRE, 0), SWZ->WZ_ICMS_CP, SWZ->WZ_ICMS_PD, SWZ->WZ_AL_ICMS, SWZ->WZ_ICMS_PC} )
		 nP := Len(aICMS_Dif)
      ENDIF

      //Cálculo Diferimento
      nRedICMS := IF(SWZ->WZ_RED_ICM#0,(100-SWZ->WZ_RED_ICM)/100,1)

      SYB->(DBSETORDER(1))
      SWD->(DBSETORDER(1))
      SWD->(DbSeek(xFilial()+SW6->W6_HAWB))

      SYT->(DBSETORDER(1))
      SYT->(dBSeek(xFilial("SYT")+SW6->W6_IMPORT))
      cCpoBasICMS:="YB_ICM_"+Alltrim(SYT->YT_ESTADO)
      lTemYB_ICM_UF:=SYB->(FIELDPOS(cCpoBasICMS)) # 0
      
      /* //NCF-13/09/2017 - Valor já está no campo WORK_SW8->WKD_BAICM
      nDBICMS:= 0

      DO WHILE xFilial('SWD') == SWD->WD_FILIAL .AND.;
         SWD->WD_HAWB   == SW6->W6_HAWB .AND.;
          !SWD->(EOF()) .AND. lTemAdicao
          IF SYB->(DBSEEK(xFilial()+SWD->WD_DESPESA)) .AND. !SWD->( LEFT(SWD->WD_DESPESA,1) ) $ "1,2,9" ;
              .AND. SWD->WD_DESPESA <> cMV_CODTXSI
              lBaseICM:=SYB->YB_BASEICM $ cSim
              IF lTemYB_ICM_UF
                 lBaseICM:=lBaseICM .AND. SYB->(FIELDGET(FIELDPOS(cCpoBasICMS))) $ cSim
              ENDIF
              IF lBaseICM
                 nDBICMS+=SWD->WD_VALOR_R
              ENDIF
          ENDIF
          SWD->(DBSKIP())
      ENDDO          
      */
      nBase:= (Work_SW8->WKFOBTOTR + Work_SW8->WKVLFREMN + Work_SW8->WKVLSEGMN + Work_SW8->WKVLACRES - Work_SW8->WKVLDEDU) + Work_SW8->WKVLII + Work_SW8->WKVLIPI + /*nDBICMS*/ WORK_SW8->WKD_BAICM /*+ Work_SW8->WKTAXASIS*/ + If(lAUTPCDI,Work_SW8->WKVLDEPIS,Work_SW8->WKVLRPIS) +  If(lAUTPCDI,Work_SW8->WKVLDECOF,Work_SW8->WKVLRCOF)  // TRP - 24/10/2012
      
      IF !EMPTY(SWZ->WZ_RED_CTE) .AND. nRedICMS == 1
         nBaseNew:= ( nBase / ( (100 -  SWZ->WZ_RED_CTE) /100 ) )
         nBase := DITrans( nBaseNew * ( SWZ->WZ_RED_CTE/SWZ->WZ_AL_ICMS ) ,2)
      ELSE
         nBase := DITrans( ( (nBase*nRedICMS) / ( (100 - SWZ->WZ_AL_ICMS ) /100 ) ) ,2)
      ENDIF

      nVal_ICM := DITrans( ( nBase * (SWZ->WZ_AL_ICMS/100) ), 2 )
      nVal_ICMDV := DITrans( ( nBase * (SWZ->WZ_AL_ICMS/100) ), 2 )
      If AvFlags("ICMSFECP_DI_ELETRONICA")
         nAlICMFECP := SWZ->WZ_ALFECP
      EndIf
      If AvFlags("FECP_DIFERIMENTO")
         nAlDifFECP := SWZ->WZ_ICMSDIF
      EndIf

	  If lICMS_Dif .AND. nP > 0

         IF aICMS_Dif[nP,3] > 0 //.AND. IF(EasyGParam("MV_AICMDIF",,0) > 0, SWZ->WZ_AL_ICMS == EasyGParam("MV_AICMDIF",,0), .T.)  // GFP - 19/03/2013 - Nopado para que o sistema calcule CFO com mais de uma aliquota de diferimento diferente.
            nVal_Dif := DITrans( ( nVal_ICM * ( aICMS_Dif[nP,3] / 100 ) ), 2 )
         ENDIF


         IF aICMS_Dif[nP,4] > 0
            nVal_CP1 := DITrans( ( (nVal_ICM - nVal_Dif) * ( aICMS_Dif[nP,4] / 100 ) ), 2 )
            nVal_CP  := nVal_CP1
         ENDIF

         IF aICMS_Dif[nP,5] > 0
            nVal_CP2 := DITrans(( nBase * ( aICMS_Dif[nP,5] / 100 ) ), 2 )
            nVal_CP  := nVal_CP2
         ENDIF

         IF nVal_CP1 > 0 .AND. nVal_CP2 > 0
            nVal_CP  := IF(nVal_CP1 > nVal_CP2, nVal_CP2, nVal_CP1)
         ENDIF

         nVal_ICM1 := nVal_ICM - nVal_Dif - nVal_CP
         nVal_ICM2 := DITrans( ( nBase * ( aICMS_Dif[nP,6] / 100 ) ), 2)
         nVal_ICM  := IF(nVal_ICM1 > nVal_ICM2, nVal_ICM1, nVal_ICM2 )

         //Fim do Cálculo Diferimento

         Work_SW8->WKICMSUSP:=aICMS_Dif[nP,2]                // ICMS Suspenso
     	 Work_SW8->WKVICMDIF:= nVal_Dif                     // Valor ICMS Diferido
  	     Work_SW8->WKVICM_CP:= nVal_Cp                      // Valor Cred. Presumido
  	     Work_SW8->WKVLICMDV:= nVal_ICMDV                  // Valor ICMS Devido

         If lICMS_Dif2
 	        Work_SW8->WKPCREPRE:=aICMS_Dif[nP,4]               //% Perc. Max. Cred. PResumido
  	        Work_SW8->WKPICMDIF:=aICMS_Dif[nP,3]               //% Difer. do ICMS
  	        Work_SW8->WKPICM_CP:=aICMS_Dif[nP,5]               //% Cred. Presumido
  	        Work_SW8->WKICMS_PD:=aICMS_Dif[nP,6]               //% Min. ICMS
         Endif
	   EndIf
   Endif

   Work_SW8->WKIPIPAUTA :=  Work->WKIPIPAUTA               //NCF - 22/02/2011 - Grava Aliq. do IPI de Pauta no Item de Invoice

   Restord(aOrdSWZ,.T.)

   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"INV_CARREGA_SW8"),)

   SW8->(DBSKIP())

ENDDO

nCont:= EasyQryCount("select W9.W9_FILIAL from " + RetSQLName("SW9") + " W9 where W9.W9_FILIAL = '" + cFILSW9 + "' and W9.W9_HAWB = '" + SW6->W6_HAWB + "' and " + If(TcSrvType() <> "AS/400", " W9.D_E_L_E_T_ <> '*' ", " W9.@DELETED@ <> '*' "))
ProcRegua(nCont)

Work_SW8->(DBSETORDER(1))
SW9->(DBSETORDER(3))
SW9->(DBSEEK(xFilial()+SW6->W6_HAWB))
DO WHILE SW9->(!EOF()) .AND.;
         SW9->W9_HAWB   == SW6->W6_HAWB .AND.;
         SW9->W9_FILIAL == cFILSW9

   IncProc(STR0283+ALLTRIM(SW9->W9_INVOICE)) //"Lendo Invoice: "

   Work_SW9->(DBAPPEND())
   AVREPLACE("SW9","Work_SW9")
   WORK_SW9->W9_TUDO_OK:=SIM
   WORK_SW9->WK_RECNO:=SW9->(RECNO())
   WORK_SW9->TRB_ALI_WT:="SW9"
   WORK_SW9->TRB_REC_WT:=SW9->(Recno())
   Work_SW8->(DBSEEK(Work_SW9->W9_INVOICE+Work_SW9->W9_FORN+WORK_SW9->W9_FORLOJ))
   DO WHILE Work_SW8->(!EOF()) .AND. Work_SW8->WKINVOICE==Work_SW9->W9_INVOICE .AND.;
                                     Work_SW8->WKFORN   ==Work_SW9->W9_FORN    .And.;
                                     (!EICLoja() .Or. Work_SW8->W8_FORLOJ == Work_SW9->W9_FORLOJ)

      Work_SW8->WKCOND_PA :=SW9->W9_COND_PA
      Work_SW8->WKDIAS_PA :=SW9->W9_DIAS_PA
      Work_SW8->WKTCOB_PA :=Posicione("SY6",1,xFilial("SY6")+SW9->W9_COND_PA+STR(SW9->W9_DIAS_PA,3),"Y6_TIPOCOB")
      Work_SW8->WKMOEDA   :=SW9->W9_MOE_FOB
      Work_SW8->WKINCOTER :=SW9->W9_INCOTER
      WORK_SW9->W9_QTDE   +=Work_SW8->WKQTDE
      WORK_SW9->W9_PESO   +=Work_SW8->WKPESOTOT

      IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"INV_SOMA_SW8_GRV_SW9"),)

      Work_SW8->(DBSKIP())
   ENDDO

   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"INV_CARREGA_SW9"),)

   SW9->(DBSKIP())

ENDDO

SW1->(DbSetOrder(nOrdSW1))
SW1->(DbGoTo(nRecSW1))

DI500SWVGrv(.T.)// AWR - Lote

RETURN .T.

FUNCTION DI500CarregaWork(cLocAlias)//Antiga DI400GrvWKIGId ( PId_Ig )
Local aOrdSW8 := SaveOrd({"SW8"})
Local cProdSuf:='', cFilSYD:=xFilial('SYD')
Local nRecAli, nCont := 1
Local aWKSW7Ncm
PRIVATE cAlias:=cLocAlias
                                    //NCF - Carregar item anuente do SW3 que já possui LI antes do PN no Desembaraço de Nacionalização
IF(cAlias="W5_",DBSELECTAREA('SW5'),IF(cAlias="W3_",DBSELECTAREA('SW3'),DBSELECTAREA('SW7')))

nRecAli := Recno()  // GFP - 24/04/2013

Work->(DBAPPEND())
Work->WKCOD_I    :=  FIELDGET(FIELDPOS(cAlias+"COD_I"))
Work->WKFLUXO    :=  FIELDGET(FIELDPOS(cAlias+"FLUXO"))
Work->WKQTDE     :=  FIELDGET(FIELDPOS(cAlias+"QTDE"))
Work->WKPRECO    :=  FIELDGET(FIELDPOS(cAlias+"PRECO"))
Work->WKSALDO_Q  :=  FIELDGET(FIELDPOS(cAlias+"SALDO_Q"))
Work->WKSALDO_O  :=  FIELDGET(FIELDPOS(cAlias+"SALDO_Q"))
Work->WKSI_NUM   :=  FIELDGET(FIELDPOS(cAlias+"SI_NUM"))
Work->WKPO_NUM   :=  FIELDGET(FIELDPOS(cAlias+"PO_NUM"))
IF cAlias == "W3_"                                               //NCF - 22/03/2011 - Item anuente com LI do Embarque no PN
   Work->WKPGI_NUM  :=  FIELDGET(FIELDPOS(cAlias+"PGI_DA"))
ELSE
   Work->WKPGI_NUM  :=  FIELDGET(FIELDPOS(cAlias+"PGI_NUM"))
ENDIF
Work->WKSEQ      :=  FIELDGET(FIELDPOS(cAlias+"SEQ"))
Work->WKCC       :=  FIELDGET(FIELDPOS(cAlias+"CC"))
Work->WKFABR     :=  FIELDGET(FIELDPOS(cAlias+"FABR"))
Work->WKFORN     :=  FIELDGET(FIELDPOS(cAlias+"FORN"))
Work->WKREG      :=  FIELDGET(FIELDPOS(cAlias+"REG"))
Work->WKPOSICAO  :=  FIELDGET(FIELDPOS(cAlias+"POSICAO"))
Work->WKPO_NUM   :=  FIELDGET(FIELDPOS(cAlias+"PO_NUM"))
IF cAlias == "W3_"                                               //NCF - 22/03/2011 - Item anuente com LI do Embarque no PN
   Work->WKSEQ_LI   :=  SW5->(FIELDGET(FIELDPOS("W5_SEQ_LI")))
ELSE
   Work->WKSEQ_LI   :=  FIELDGET(FIELDPOS(cAlias+"SEQ_LI"))
ENDIF
Work->TRB_ALI_WT :=  "SW7"
Work->TRB_REC_WT :=  SW7->(Recno())
SB1->(DBSEEK(xFilial()+Work->WKCOD_I))
SW2->(DBSEEK(xFilial()+Work->WKPO_NUM))
Work->WKMOEDA    :=  SW2->W2_MOEDA
Work->WKDISPINV  :=  0
Work->W7_FORLOJ :=  FIELDGET(FIELDPOS(cAlias+"FORLOJ"))
Work->W7_FABLOJ :=  FIELDGET(FIELDPOS(cAlias+"FABLOJ"))

//FSM - 31/08/2011 - "Peso Bruto Unitário"
If lPesoBruto
   Work->WKW7PESOBR := FIELDGET(FIELDPOS(cAlias+"PESO_BR"))
EndIf

If lIntDraw
   If cAlias=="W5_"
      Work->WKAC     := FIELDGET(FIELDPOS(cAlias+"AC"))
      Work->WKSEQSIS := FIELDGET(FIELDPOS(cAlias+"SEQSIS"))
   ElseIf cAlias=="W3_"                                        //NCF - 22/03/2011 - Item anuente com LI do Embarque no PN
      nRegW5 := SW5->(RECNO())
      Do While !SW5->(EOF()) .and. SW5->W5_SEQ <> 0
         SW5->(dbSkip())
      EndDo
      If SW5->W5_SEQ=0
         Work->WKAC     := SW5->W5_AC
         Work->WKSEQSIS := SW5->W5_SEQSIS
      EndIf
      SW5->(DbGoTo(nRegW5))
   Else
      SW5->(dbSetOrder(8))
      SW5->(dbSeek(cFilSW5+Work->WKPGI_NUM+Work->WKPO_NUM+Work->WKPOSICAO))
      Do While !SW5->(EOF()) .and. SW5->W5_SEQ <> 0
         SW5->(dbSkip())
      EndDo
      If SW5->W5_SEQ=0
         Work->WKAC     := SW5->W5_AC
         Work->WKSEQSIS := SW5->W5_SEQSIS
      EndIf
      SW5->(dbSetOrder(1))
   EndIf
EndIf

IF EasyGParam("MV_EIC0057",,.F.) //LGS-14/05/2015
   DI500SldSW8()
ELSE
   IF !SW9->(DBSEEK(xFilial()+SW7->W7_HAWB)) .AND. cAlias="W7_"
      Work->WKDISPINV:= Work->WKQTDE
   ENDIF
ENDIF

IF SWP->(DBSEEK(xFilial()+Work->WKPGI_NUM+Work->WKSEQ_LI))
   Work->WKREGIST := SWP->WP_REGIST
   Work->WKREG_VEN:= SWP->WP_VENCTO
ENDIF

IF SW4->(DBSEEK(xFilial()+ Work->WKPGI_NUM ))
   Work->WKGI_NUM:= SW4->W4_GI_NUM
   cProdSuf      := SW4->W4_PROD_SU
ENDIF

E_ItFabFor(,cPRodSuf,"DI")   // grava descricao do item, nome do fabricante e fornecedor

SW3->(DbSetOrder(8))
SW3->(DbSeek(xFilial("SW3") + Work->WKPO_NUM + Work->WKPOSICAO ))
If SW3->(FieldPos("W3_PART_N")) # 0 //ASK 05/10/2007
   If !Empty(SW3->W3_PART_N)
      Work->WKPART_N:= SW3->W3_PART_N
   Else
      If EICSFabFor(xFilial("SA5")+Work->WKCOD_I+Work->WKFABR+Work->WKFORN, EICRetLoja("Work", "W7_FABLOJ"), Work->W7_FORLOJ)
         Work->WKPART_N:= SA5->A5_CODPRF
      EndIf
   EndIf
Else
   IF EICSFabFor(xFilial("SA5")+Work->WKCOD_I+Work->WKFABR+Work->WKFORN, EICRetLoja("Work", "W7_FABLOJ"), Work->W7_FORLOJ)
      Work->WKPART_N:= SA5->A5_CODPRF
   EndIf
EndIf

//AOM - 11/04/2011 - adiciona a ope esp na work SW7
If lOperacaoEsp
   If !Empty(SW7->W7_CODOPE)
      Work->W7_CODOPE := SW7->W7_CODOPE
      Work->W7_DESOPE := Posicione("EJ0",1,xFilial("EJ0") + Work->W7_CODOPE ,"EJ0_DESC")
   ElseIf !Empty(SW5->W5_CODOPE)
      Work->W7_CODOPE := SW5->W5_CODOPE
      Work->W7_DESOPE := Posicione("EJ0",1,xFilial("EJ0") + Work->W7_CODOPE ,"EJ0_DESC")
   Else
      Work->W7_CODOPE := SW3->W3_CODOPE
      Work->W7_DESOPE := Posicione("EJ0",1,xFilial("EJ0") + Work->W7_CODOPE ,"EJ0_DESC")
   EndIf
EndIf


IF cAlias = "W7_"
   Work->WKPESO_L   := SW7->W7_PESO
   Work->WKTEC      := SW7->W7_NCM
   Work->WKEX_NCM   := SW7->W7_EX_NCM
   Work->WKEX_NBM   := SW7->W7_EX_NBM
   Work->WKRECNO_ID := SW7->(Recno())
   Work->WKQTDE_D   := SW7->W7_SALDO_Q
   Work->WKQTDEDORI := SW7->W7_SALDO_Q
   Work->WKOPERACA  := SW7->W7_OPERACA
   SW5->(dbSetOrder(8))
   SW5->(dbSeek(cFilSW5+Work->WKPGI_NUM+Work->WKPO_NUM+Work->WKPOSICAO))
   // EOB - 26/06/08 - Ao carregar a Work de um item anuente, não teremos mais saldo na LI, portanto, deve-se carregar o saldo original do item
   // com a qtde original da LI (novo campo W5_QTDELI) e o saldo do item com a diferenca entre o que foi registrado na Li contra o que foi embarcado.
   IF SW5->W5_FLUXO == "1" .AND. SW5->(FIELDPOS("W5_QTDELI")) > 0 .AND. SW5->W5_QTDELI > 0
      nSaldoW3 := DI400POSld("S")
      IF Work->WKQTDE_D + nSaldoW3 > SW5->W5_QTDELI
         nSaldo_O := SW5->W5_QTDELI
         nSaldo_Q := SW5->W5_QTDELI - Work->WKQTDE_D
      ELSE
         nSaldo_O := Work->WKQTDE_D + nSaldoW3
         nSaldo_Q := nSaldoW3
      ENDIF
      Work->WKSALDO_O  := nSaldo_O
      Work->WKSALDO_Q  := nSaldo_Q
   ELSE
	  SW7->(DbSetOrder(4)) // GCC - 16/07/2013
      If SW7->(DbSeek(xFilial("SW7")+M->W6_HAWB+Work->WKPO_NUM+Work->WKPOSICAO+Work->WKPGI_NUM))
         Work->WKSALDO_O := SW7->W7_SALDO_Q + SW5->W5_SALDO_Q
         Work->WKSALDO_Q := SW7->W7_SALDO_Q + SW5->W5_SALDO_Q
      Else
         Work->WKSALDO_O := Work->WKQTDE_D + SW5->W5_SALDO_Q
         Work->WKSALDO_Q := SW5->W5_SALDO_Q                  
      EndIf 
      SW7->(DbSetOrder(1)) // GCC - 16/07/2013
   ENDIF
   //MFR TE-7011 WCC-534964 MTRADE-1554 28/09/2017
   //Work->WKDISPINV := Work->WKSALDO_O - Work->WKQTDE_D  //NCF - 30/11/2017 - Não permitia saldo disponivel para invoice no desembaraço  
   Work->WKFLAG     :=  .T.
   Work->WKFLAG2    :=  .T.
   Work->WKFLAGWIN  :=  cMarca
   Work->WKFLAGWIN2 :=  cMarca
   Work->WK_ALTEROU := .F.
   IF lExiste_Midia .AND. lPesoMid   // LDR - 25/08/04
      Work->WKPESOMID := SW7->W7_PESOMID      // LDR - 24/08/04
   ENDIF
   M->W6_IMPORT:=SW2->W2_IMPORT
   cMoedaProc  :=SW2->W2_MOEDA
   Work->WKIPIPAUTA := IPIPauta(.T., SW7->W7_VLR_IPI)

   IF lMV_PIS_EIC .AND. SYD->(DBSEEK(cFilSYD+Work->WKTEC+Work->WKEX_NCM+Work->WKEX_NBM)) .AND. !(lIntDraw .AND. !Empty(Work->WKAC)) .AND. !lAUTPCDI
      SW9->(DBSETORDER(3))
      IF !SW9->(DBSEEK(cFilSW9+M->W6_HAWB))
         Work->WKVLUPIS := SYD->YD_VLU_PIS
         Work->WKVLUCOF := SYD->YD_VLU_COF
         Work->WKPERPIS := SYD->YD_PER_PIS
         Work->WKPERCOF := SYD->YD_PER_COF
      ENDIF
   ENDIF
   //NCF - 08/08/2011 - Classificação N.V.A.E na PLI
   IF lCposNVEPLI     
      Work->WK_NVE := SW5->W5_NVE      
   EndIf
   IF AvFlags("EIC_EAI")//AWF - 25/06/2014
      aSegUM:=Busca_2UM(SW7->W7_PO_NUM,SW7->W7_POSICAO)
      IF LEN(aSegUM) > 0
         Work->WKUNI    :=aSegUM[1]
         Work->WKSEGUM  :=aSegUM[2]
         Work->WKFATOR  :=aSegUM[3]
         Work->WKQTSEGUM:=Work->WKQTDE*Work->WKFATOR
      ENDIF
   ENDIF
ELSE
   IF !FINDFUNCTION("B1PESO") //AWR
      Work->WKPESO_L := IF(!EMPTY(SW5->W5_PESO),SW5->W5_PESO,If(SW3->(FIELDPOS("W3_PESOL"))<>0 .AND. !Empty(SW3->W3_PESOL),SW3->W3_PESOL,SB1->B1_PESO))
   ELSE
      Work->WKPESO_L := IF(!EMPTY(SW5->W5_PESO),SW5->W5_PESO,If(SW3->(FIELDPOS("W3_PESOL"))<>0 .AND. !Empty(SW3->W3_PESOL),SW3->W3_PESOL,B1Peso(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN, EICRetLoja("SW5", "W5_FABLOJ")+EICRetLoja("SW5", "W5_FORLOJ")))) // RA - 31/10/03 - O.S. 1110/03
   ENDIF
   aWKSW7Ncm        := Busca_NCM('SW5',"NCM",,.T.)
   Work->WKTEC      := aWKSW7Ncm[1]//Busca_NCM('SW5',"NCM"   )
   Work->WKEX_NCM   := aWKSW7Ncm[2]//Busca_NCM('SW5',"EX_NCM")
   Work->WKEX_NBM   := aWKSW7Ncm[3]//Busca_NCM('SW5',"EX_NBM")
   Work->WKRECNO_ID := SW5->(Recno())
   Work->WKDT_EMB   := SW5->W5_DT_EMB
   Work->WKDT_ENTR  := SW5->W5_DT_ENTR
   Work->WKNBM      := SW5->W5_NBM
   Work->WKDOCTO_F  := SW5->W5_DOCTO_F
   Work->WKOPERACA  := SW5->W5_OPERACA
   Work->WK_ALTEROU := .T.
   IF lExiste_Midia .AND. lPesoMid   // LDR - 25/08/04
      Work->WKPESOMID := SA5->A5_PESOMID   // LDR - 24/08/04
   ENDIF
   Work->WKIPIPAUTA := IPIPauta (.F.)
   IF Inclui//Inicializar os itens desmarcados.
      Work->WKQTDE  := 0
      Work->WKQTDE_D:= 0
   ENDIF
   IF lMV_PIS_EIC .AND. SYD->(DBSEEK(cFilSYD+Work->WKTEC+Work->WKEX_NCM+Work->WKEX_NBM)) .AND. !(lIntDraw .AND. !Empty(Work->WKAC)) .AND. !lAUTPCDI
      Work->WKVLUPIS := SYD->YD_VLU_PIS
      Work->WKVLUCOF := SYD->YD_VLU_COF
      Work->WKPERPIS := SYD->YD_PER_PIS
      Work->WKPERCOF := SYD->YD_PER_COF
   ENDIF
   //NCF - 08/08/2011 - Classificação N.V.A.E na PLI
   IF cAlias == "W5_" .And. lCposNVEPLI 
      Work->WK_NVE := SW5->W5_NVE
   EndIf
   IF AvFlags("EIC_EAI")//AWF - 25/06/2014
      aSegUM:=Busca_2UM(SW5->W5_PO_NUM,SW5->W5_POSICAO)
      IF LEN(aSegUM) > 0
         Work->WKUNI    :=aSegUM[1]
         Work->WKSEGUM  :=aSegUM[2]
         Work->WKFATOR  :=aSegUM[3]
         Work->WKQTSEGUM:=Work->WKQTDE_D*Work->WKFATOR
      ENDIF
   ENDIF
ENDIF

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GRV_WORK_ITEM"),)

DbGoTo(nRecAli)  // GFP - 24/05/2013
RETURN .T.

Function DI500MarcaAll(cAlias,oBrw)// Antigas DI400AllMark e DI_MarcaAll(oBrw)

Local cNewMarca, nRec_Work := (cAlias)->(Recno()),lOK:=.T.
Local lMensagem:=.F.
Local cFilSW7:=xFilial("SW7")
Local nOrdSW7 := SW7->( IndexOrd() )
Local nRecSW7 := SW7->( RecNo() )
Local lSemPeso := EasyGParam("MV_EIC0004",,.F.)//Acb - 16/09/2010
Local cProcesso, cPoNum, cPosicao, cPgiNum
Local aCampos


Private lMens_Qtde:=.F.  // LDR

ProcRegua((cAlias)->(EasyReccount(cAlias)))

SX3->(DbSetOrder(2))
SX3->(DBSeek("W6_PESOL"))

IF cAlias == 'Work'
   lGravaSoCapa:=.F.
   
   IF !DI500Alcada(Work->WKPO_NUM) //LRS - 07/03/2017
      Return .F.
   EndIF

   IF !EMPTY(M->W6_DTREG_D)  .AND. !lRetifica .AND. lTemAdicao // LDR - 04/01/05 - DEICMAR
      MsgInfo(STR0670,STR0141) //STR0670 "A data de registro da Di ja foi preenchida ."  //	STR0141 := "Atenção"
      Return .T.
   ENDIF

   IF lEnvDesp .AND. lMsgEnv
      SWP->(DBSETORDER(1))
      IF SWP->(DBSEEK(xFilial("SWP")+Work->WKPGI_NUM+Work->WKSEQ_LI))
         IF !EMPTY(SWP->WP_ENV_ORI)
             MSGINFO(STR0671,STR0141) //STR0671 "Como o arquivo ja foi enviado para o despachante e sera feita uma alteração no item, o arquivo devera ser enviado novamente. " //STR0141 := "Atenção"
             lMsgEnv:=.F.
         ENDIF
      ENDIF
   ENDIF

   IF Work->WKFLAG
      cNewMarca := Space(2)
      Work->(DBGOTOP())
      Work->(DBEVAL({||lOK:=.F.},{|| Work->WKDISPINV # Work->WKQTDE .AND. WKFLAG },{|| lOK  } ))
      IF !lOK
         IF !MSGYESNO(STR0284,STR0141) //"Existem Itens com Invoice, Continua Desmarca Todos?"
            (cAlias)->(dbGoTo(nRec_Work))
            RETURN .F.
         ENDIF
      ENDIF
   ELSE
      cNewMarca := cMarca
   ENDIF

   //igor chiba 04/05/09
   WORK->(dbGoTo(nRec_Work))
   IF Work->WKFLAG
      cNewMarca := Space(2)
   ELSE
      If lSemPeso//Acb - 17/09/2010
         Work->(DBGOTOP())
//           MsgInfo("Existe(m) iten(s) sem peso","ATENÇÃO")
         Work->(DBEVAL({||lOK:=.F.},{|| EMPTY(WORK->WKPESO_L)  },{|| lOK  } ))//ACB - 03/01/2011 - Tratamento para selecionar item sem peso
         If !lOk
            IF !MSGYESNO(STR0672) //STR0672 "Existe(m) item(ns) sem peso. Deseja continuar?"
               WORK->(dbGoTo(nRec_Work))
               RETURN .F.
            ELSE
               cNewMarca := cMarca
            ENDIF
         Else
            cNewMarca := cMarca
         EndIf
      ELSE
         Work->(DBGOTOP())
         Work->(DBEVAL({||lOK:=.F.},{|| EMPTY(WORK->WKPESO_L)  },{|| lOK  } ))
         IF !lOK
            MsgInfo(STR0673,STR0141) //STR0673 "Existe(m) item(ns) sem peso. Estes itens não poderão ser marcados "  //STR0141 := "Atenção"
            WORK->(dbGoTo(nRec_Work))
            RETURN .F.
            //ENDIF
         ENDIF
         cNewMarca := cMarca
      ENDIF

      //Valida se existem itens sem NCM
      If ItemSemNCM()
         MsgInfo(STR0946,STR0141) //"Existe(m) item(ns) sem NCM. Estes itens não poderão ser marcados."  //STR0141 := "Atenção"
         WORK->(dbGoTo(nRec_Work))
      EndIf
   ENDIF
  //Fim igor chiba 04/05/09


   SW7->( DBSetOrder(4) )  // PLB - 01/12/06
   Work_SW9->(DBSETORDER(1))
   Work_SW8->(DBSETORDER(2))
   Work->(dbGoTop())
   lMostMsgNVE := Work->WKFLAG
   DO While !Work->(Eof())
      IncProc(STR0285+Work->WKCOD_I) //"Des/Marcando Item: "
      IF Empty(cNewMarca) .And. Work->WKFLAG
         If lIntDraw  .And.  MOpcao == FECHTO_DESEMBARACO  .And.  !Empty(Work->( WKAC+WKSEQSIS ))  .And.  !Empty(M->W6_DI_NUM)  .And.  lMUserEDC
            If SW7->( DBSeek(cFilSW7+M->W6_HAWB+Work->WKPO_NUM+Work->WKPOSICAO+Work->WKPGI_NUM) )
               If !oMUserEDC:Reserva("DI","SEL_ITEM")  // PLB 01/12/06 - Trava os registros refentes ao Item no objeto
                  Work->( DBSkip() )
                  Loop
               EndIf
            Else
               oMUserEDC:Solta("DI","SEL_ITEM")  // PLB 01/12/06 - Destrava os registros refentes ao Item no objeto
            EndIf
         EndIf
         M->W6_PESOL     -= Work->WKPESO_L * Work->WKQTDE
         IF M->W6_PESOL < 0
            M->W6_PESOL := 0
         ENDIF
         Work->WKSALDO_Q := Work->WKSALDO_O
         Work->WKQTDE_D  := 0
         Work->WKQTDE    := 0
         Work->WKFLAG    := .F.
         Work->WKFLAGWIN := Space(2)
         Work->WK_ALTEROU:= .T.
         WORK->WKDISPINV := 0

         cOldFilter := WORK_SW8->(DbFilter())
         WORK_SW8->(DbClearFilter())
         cFilTemp := "WORK_SW8->WKFORN    == '"+WORK->WKFORN   +"' .And. "
         cFilTemp += "WORK_SW8->W8_FORLOJ  == '"+WORK->W7_FORLOJ+"' .And. "
         cFilTemp += "WORK_SW8->WKPO_NUM  == '"+WORK->WKPO_NUM +"' .And. "
         cFilTemp += "WORK_SW8->WKPOSICAO == '"+WORK->WKPOSICAO+"' .And. "  
         cFilTemp += "WORK_SW8->WKPGI_NUM == '"+WORK->WKPGI_NUM+"'"        
         bFilTemp := &("{||" + cFilTemp + "}")         
         Work_SW8->(DbSetFilter(bFilTemp,cFilTemp))
         Work_SW8->(Dbgotop())

         //IF Work_SW8->(DBSEEK(WORK->WKFORN+Work->W7_FORLOJ+WORK->WKPO_NUM+WORK->WKPOSICAO+WORK->WKPGI_NUM))
            DO WHILE Work_SW8->(!EOF()) //.AND.;
                     //WORK_SW8->(WKFORN+Work_SW8->W8_FORLOJ+WKPO_NUM+WKPOSICAO+WKPGI_NUM) ==;
                     //WORK->(WKFORN+Work->W7_FORLOJ+WKPO_NUM+WKPOSICAO+WKPGI_NUM)
               //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
               IF Work_SW9->(DBSEEK(Work_SW8->WKINVOICE+WORK_SW8->WKFORN+Work_SW8->W8_FORLOJ+M->W6_HAWB))
                  WORK_SW9->W9_FOB_TOT-=Work_SW8->WKPRTOTMOE
                  WORK_SW9->W9_TUDO_OK:=NAO
               ENDIF
               DI500Controle(1)
               DI500LoteVal("DEL_LOTE",,,WORK_SW8->(WKFORN+W8_FORLOJ+WKPGI_NUM+WKPO_NUM+WKPOSICAO+WKINVOICE))//LGS-27/02/2015 //AWR - Lote
               lDeleta:=.T.
               IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"DESMARCA_ALL_ITEM_SW7"),)
               IF lDeleta
                  Work_SW8->(DBDELETE())
               ELSE
                  Work_SW8->WKFLAGIV :=""
                  Work_SW8->WKADICAO :=""
                  Work_SW8->WKGRUPORT:=""//AWR - 18/09/08 NFE
                  Work_SW8->WKFLAGDSI:=""
                  Work_SW8->WKINVOICE:=SPACE(LEN(SW9->W9_INVOICE))
               ENDIF
               IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"2_DESMARCA_ALL_ITEM_SW7"),)//AWR - 09/08/2010
               Work_SW8->(DBSKIP())
            ENDDO
         //ENDIF
         WORK_SW8->(DbClearFilter())
         if !empty(cOldFilter)
            WORK_SW8->(DbSetFilter(&("{||" + cOldFilter + "}"),cOldFilter))
         endif
         WORK_SW8->( dbgotop() )
                                                    //NCF - 05/07/2010 - Itens com peso zerado não poderão ser marcados
      ElseIF !Empty(cNewMarca) .And. !Work->WKFLAG .And. (Work->WKPESO_L <> 0 .or. lSemPeso) .And. !Empty(Work->WKTEC);
             .And.  IIF(lIntDraw .And. lMUserEDC .And. MOpcao == FECHTO_DESEMBARACO .And. !Empty(Work->WKAC) .And. !Empty(M->W6_DI_NUM);
                        ,IIF(SW7->( DBSeek(cFilSW7+M->W6_HAWB+Work->WKPO_NUM+Work->WKPOSICAO+Work->WKPGI_NUM) );
                             ,oMUserEDC:Solta("DI","SEL_ITEM")    ;
                             ,oMUserEDC:Reserva("DI","SEL_ITEM") );
                        ,.T.)
         //NCF - 09/11/2009
         cValor := STR(M->W6_PESOL+(Work->WKPESO_L * Work->WKQTDE),,AvSx3("W6_PESOL", AV_DECIMAL))
         cInteiro := AllTrim(SubStr(cValor, 1, At(".", cValor)))
   	     cDecimal := AllTrim(SubStr(cValor, At(".", cValor) + 1))

         //If (Len(cInteiro) > (AvSx3("W6_PESOL", AV_TAMANHO)) - AvSx3("W6_PESOL", AV_DECIMAL) - 1) .Or. (Len(cDecimal) > AvSx3("W6_PESOL", AV_DECIMAL))
         If (Len(cInteiro)+Len(cDecimal)) > AvSx3("W6_PESOL", AV_TAMANHO)
         //
            MsgStop(STR0674+CHR(13)+CHR(10); //STR0674 "O Peso x Quantidade dos itens do processo "
                   +STR0675+CHR(13)+CHR(10); //STR0675 "ultrapassou o limite suportado pelo sistema!"
                   +STR0676) //STR0676 "Efetue a correção no(s) peso(s) do(s) iten(s)"
            EXIT
         ENDIF

         Work->WKQTDE    := Work->WKSALDO_Q
         Work->WKQTDE_D  := Work->WKSALDO_Q
         Work->WKSALDO_Q := 0
         Work->WKFLAG    := .T.
         Work->WKFLAGWIN := cMarca
         Work->WK_ALTEROU:= .T.
         WORK->WKDISPINV := Work->WKQTDE
         M->W6_PESOL     += Work->WKPESO_L * Work->WKQTDE

         IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"MARCA_ALL_ITEM_SW7"),)
         DI500Controle(1)
      Endif
      If AvFlags("EIC_EAI")
         Work->WKQTSEGUM := If(EMPTY(cNewMarca),0,Work->WKQTDE*Work->WKFATOR) //AWF - Zerar Segunda quantidade no (Des)Marca Todos
      EndIf
      Work->(dbSkip())
   ENDDO

ELSEIF cAlias == 'TRB'
   IF TRB->WK_OK == cMarca
      cNewMarca:=SPACE(02)
   ELSE
      cNewMarca:=cMarca
   ENDIF
   TRB->(DBGOTOP())
   DO WHILE !TRB->(EOF())
      IncProc(STR0285+TRB->W7_COD_I) //"Des/Marcando Item: "

      //Tratamento para Operaçoes especiais - AOM  - 15/04/2011
      If VldOpeDesemb("MARC_TDS_EST")
         TRB->WK_OK :=cNewMarca
      EndIf

      TRB->(DBSKIP())
   ENDDO

ELSEIF cAlias == 'Work_SW8'

   IF !DI500Alcada(Work_SW8->WKPO_NUM) //LRS - 07/03/2017
      Return .F.
   EndIF
   
   IF lEnvDesp .AND. lMsgEnv
      SWP->(DBSETORDER(1))
      IF SWP->(DBSEEK(xFilial("SWP")+Work_SW8->WKPGI_NUM+Work_SW8->WKSEQ_LI))
         IF !EMPTY(SWP->WP_ENV_ORI)
             MSGINFO(STR0634,STR0141) //STR0634 "Como o arquivo ja foi enviado para o despachante e sera feita uma alteração no item, o arquivo devera ser enviado novamente. " //STR0141 := "Atenção"
             lMsgEnv:=.F.
         ENDIF
      ENDIF
   ENDIF

   IF Work_SW8->WKFLAGIV == cMarca
      cNewMarca := Space(2)
   ELSE
      cNewMarca := cMarca
   ENDIF
   IF Empty(cNewMarca)
      IF !DI500LoteVal("EXCLUI_LOTE") // AWR - LOTE
         RETURN .F.
      ENDIF
   ENDIF
   DBSELECTAREA("Work_SW8")

   cFilWkW8Atu := RescFilAtv(oBrw)  //Recuperar os filtros acumulados no objeto FWBrowse da Work_SW8 para marcação
   If Empty(cFilWkW8Atu)
      SET FILTER TO 
   Else
      SET FILTER TO &(cFilWkW8Atu)
   EndIf

   Work_SW8->(DBSETORDER(2))
   Work_SW8->(dbGoTop())
   DO While !Work_SW8->(Eof())
      IncProc(STR0285+Work_SW8->WKCOD_I) //"Des/Marcando Item: "
      IF WORK_SW8->WKMOEDA <> M->W9_MOE_FOB
         WORK_SW8->(DBSKIP())
         LOOP
      ENDIF
      IF WORK_SW8->WKFORN <> M->W9_FORN .Or. WORK_SW8->W8_FORLOJ <> M->W9_FORLOJ
         WORK_SW8->(DBSKIP())
         LOOP
      ENDIF
      IF Empty(cNewMarca) .And. !EMPTY(Work_SW8->WKFLAGIV) .AND.;
         Work_SW8->WKINVOICE == M->W9_INVOICE .AND. Work_SW8->WKFORN == M->W9_FORN .And. Work_SW8->W8_FORLOJ == M->W9_FORLOJ

         DI500InvMarca('D')

      /*ISS - 27/05/10 - Implementação do Elseif, para que o mesmo cheque se o "work_SW8->INVOICE" possui o mesmo código da invoice contida
                         na memória, por alterações anteriores a work_SW8 já está carregada, com isso, "inutilizando" a condição de EMPTY */
      Elseif !Empty(cNewMarca).AND.EMPTY(Work_SW8->WKFLAGIV).AND.(EMPTY(Work_SW8->WKINVOICE) .OR. (Work_SW8->WKINVOICE == M->W9_INVOICE))
                                                                                                   //NCF - 30/09/09 - Verificação de integ. Drawback e NFE
         If !Empty(M->W6_DI_NUM) .and. Empty(Work_SW8->WKADICAO) .and. !lTemAdicao .and. lIntDraw .and. IF(lIntDraw,!Empty(Work_SW8->WKAC),.F.) .and. lExisteSEQ_ADI
            lMensagem:=.T.
         ELSE
            DI500InvMarca('M')
         ENDIF

      Endif
      Work_SW8->(dbSkip())
   ENDDO
   IF lMensagem
      Help("",1,"AVG0000717")//Existe itens com campo Adicao nao preenchido.")
   ENDIF
   IF lMens_Qtde // LDR
      MsgInfo(STR0529,STR0141)
   ENDIF
   DBSELECTAREA("Work_SW8")
   Work_SW8->(DBSETORDER(2))
   // SVG - 13/07/09 -
   If ("CTREE" $ RealRDD())
      If !EICLoja()
         Work_SW8->(DBEVAL({||;
         If(Work_SW8->WKINVOICE+Work_SW8->WKFORN == M->W9_INVOICE+M->W9_FORN .OR.;
         (EMPTY(Work_SW8->WKINVOICE) .AND. Work_SW8->WKFORN+Work_SW8->WKMOEDA == M->W9_FORN+M->W9_MOE_FOB);
         ,Work_SW8->WKFILTRO:="S",Work_SW8->WKFILTRO:="")}))
         SET FILTER TO Work_SW8->WKFILTRO == "S"
      Else
         Work_SW8->(DBEVAL({||;
         If(Work_SW8->WKINVOICE+Work_SW8->WKFORN+Work_SW8->W8_FORLOJ == M->W9_INVOICE+M->W9_FORN+M->W9_FORLOJ .OR.;
         (EMPTY(Work_SW8->WKINVOICE) .AND. Work_SW8->WKFORN+Work_SW8->W8_FORLOJ+Work_SW8->WKMOEDA == M->W9_FORN+M->W9_FORLOJ+M->W9_MOE_FOB);
         ,Work_SW8->WKFILTRO:="S",Work_SW8->WKFILTRO:="")}))
         SET FILTER TO Work_SW8->WKFILTRO == "S"
      EndIf
   Else
      If !EICLoja()
         SET FILTER TO Work_SW8->WKINVOICE+Work_SW8->WKFORN == M->W9_INVOICE+M->W9_FORN .OR. (EMPTY(Work_SW8->WKINVOICE) .AND. Work_SW8->WKFORN+Work_SW8->WKMOEDA == M->W9_FORN+M->W9_MOE_FOB)
      Else
         SET FILTER TO Work_SW8->WKINVOICE+Work_SW8->WKFORN+Work_SW8->W8_FORLOJ == M->W9_INVOICE+M->W9_FORN+M->W9_FORLOJ .OR. (EMPTY(Work_SW8->WKINVOICE) .AND. Work_SW8->WKFORN+Work_SW8->W8_FORLOJ+Work_SW8->WKMOEDA == M->W9_FORN+M->W9_FORLOJ+M->W9_MOE_FOB)
      EndIf
   EndIf
ENDIF
(cAlias)->(dbGoTop())

SW7->( DBSetOrder(nOrdSW7) )
SW7->( DBGoTo(nRecSW7) )


IF oBrw # NIL
   oBrw:Reset()
   oBrw:Refresh()
ENDIF

RETURN .T.

/*
Funcao      : DI500InvMarca()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         :
Revisão     :
*/
FUNCTION DI500InvMarca(cTipo,lOpe)

Local i, nPos
PRIVATE cRDTipo:=cTipo
Default lOpe := .T.
WORK->(DBSETORDER(3))

//AOM - 25/05/2011 - Carregar a Memória com os campos nomeados igual ao dicionário de acordo com o Arraya "CorrespW8"
For i := 1 To Work_SW8->(FCount())

   If (nPos := Ascan(aCorrespW8, {|x| AllTrim(x[2]) == AllTrim(Work_SW8->(FIELDNAME(i)))})) > 0 .And. aCorrespW8[nPos][1] <> "W9_FOB_TOT"
      M->&(aCorrespW8[nPos][1]) := Work_SW8->(FieldGet(i))
   EndIf

Next i

IF cRDTipo == 'D'

   //AOM - 12/04/2011 - Operacao Especial
   If lOpe .And. !VldOpeDesemb("MK_IT_INV")
      Return .F.
   EndIf

   DI500LoteVal("DEL_LOTE",,,WORK_SW8->(WKFORN+W8_FORLOJ+WKPGI_NUM+WKPO_NUM+WKPOSICAO+WKINVOICE))//LGS-27/02/2015 // AWR - Lote
   Work_SW8->WKFLAGIV:=""
   If lTemAdicao .or. !lIntDraw
      Work_SW8->WKADICAO :=""
      Work_SW8->WKFLAGDSI:=""
   EndIf
   Work_SW8->WKINVOICE:=SPACE(LEN(SW9->W9_INVOICE))
   DI500Controle(1)
   IF WORK->(DBSEEK(Work_SW8->WKPO_NUM+Work_SW8->WKPGI_NUM+Work_SW8->WKPOSICAO))
      WORK->WKDISPINV:=Work_SW8->WKSALDO_AT
   ENDIF
   Work_SW8->WKDISPLOT :=WORK_SW8->WKQTDE// AWR - Lote - 07/06/2004
   If Work_SW8->WKNVETIPO == "CD" //NVE no Produto
      Work->WK_NVE := " "
   EndIf

   M->W9_FOB_TOT -= Work_SW8->WKPRTOTMOE //Subtrati o total do item na capa da invoice ao desmarcá-lo

ELSEIF cRDTipo == 'M'
   If VerCobertDB() //AOM - 30/07/10 - Verifica se a Cobertura Cambial de cond pagto está de acordo com o Ato Concessório
      //AOM - 12/04/2011 - Operacao Especial
      If !VldOpeDesemb("MK_IT_INV")
         Return .F.
      EndIf
      Work_SW8->WKFLAGIV  :=cMarca
      Work_SW8->WKINVOICE :=M->W9_INVOICE
      Work_SW8->WKPRTOTMOE:=DI500Trans(Work_SW8->WKQTDE * Work_SW8->WKPRECO)
      Work_SW8->WKPESOTOT :=Work_SW8->WKPESO_L*Work_SW8->WKQTDE
      Work_SW8->WKUNID    :=TransQtde(0,.T.,,Work_SW8->WKCOD_I,Work_SW8->WKFABR,Work_SW8->WKFORN,Work_SW8->WKCC,Work_SW8->WKSI_NUM, Work_SW8->W8_FABLOJ, Work_SW8->W8_FORLOJ)
      IF lVlUnid // LDR - OC - 0048/04 - OS - 0989/04
         IF EMPTY(Work_SW8->WKQTDE_UM)
            Work_SW8->WKQTDE_UM:=DI500UNID(Work_SW8->WKCOD_I,Work_SW8->WKFABR,Work_SW8->WKFORN)
            IF !EMPTY(Work_SW8->WKQTDE_UM) // E PQ NAO EXISTE NA TABELA DE PARA SJ5
               lMens_Qtde:=.T.
            ENDIF
         ENDIF
      ENDIF

      DI500Controle(1)
      IF WORK->(DBSEEK(Work_SW8->WKPO_NUM+Work_SW8->WKPGI_NUM+Work_SW8->WKPOSICAO))
         IF Work_SW8->WKSALDO_AT - Work_SW8->WKQTDE > 0
            WORK->WKDISPINV:=Work_SW8->WKSALDO_AT-Work_SW8->WKQTDE
         ELSE
            WORK->WKDISPINV:=0
         ENDIF
         If Work_SW8->WKNVETIPO == "CD" //NVE no Produto
            Work->WK_NVE := Work_SW8->WKNVE
         EndIf
      ENDIF
      Work_SW8->WKDISPLOT :=WORK_SW8->WKQTDE// AWR - Lote - 07/06/2004

      M->W9_FOB_TOT += Work_SW8->WKPRTOTMOE //Soma o total do item na capa da invoice ao marcá-lo
   EndIf
ENDIF
If AvFlags("EIC_EAI")
   Work_SW8->WKQTSEGUM := If(EMPTY(Work_SW8->WKFLAGIV),0,Work_SW8->WKQTDE*Work_SW8->WKFATOR) //AWF - Zerar Segunda quantidade no (Des)Marca Todos
Endif
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"MARCA_DESMARCA_ITEM_INVOICE"),)

RETURN .T.

/*
Funcao DI500AtPs(cOperacao)
Parâmetro cOperacao ='A' de adição indica que vai somar, igual a 'S' de subtração indica qeu vai subtrair
*/
Function DI500AtPs(cOperacao)
If cOperacao=='S'
   M->W6_PESOL    -= Work->WKPESO_L * Work->WKQTDE
Else
   M->W6_PESOL     += Work->WKPESO_L * Work->WKQTDE
EndIf


/*
Funcao      : DI500MarkItem()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         :
Revisão     :
*/
Function DI500MarkItem()//Antiga DI400ItemMarca()

LOCAL cTitulo:=STR0286, nOpcA //"Selecao do Item do Processo"
LOCAL lGet_Mid:=.F.  // LDR - 25/08/04
Local cFilSW7:=xFilial("SW7")
Local nOrdSW7 := SW7->( IndexOrd() )
Local nRecSW7 := SW7->( RecNo() )
Local bValid := {||IIF(lMUserEDC .And. MOpcao == FECHTO_DESEMBARACO .And. lIntDraw .And. !Empty(Work->WKAC) .And. !Empty(M->W6_DI_NUM);
                       ,IIF(SW7->( DBSeek(cFilSW7+M->W6_HAWB+Work->WKPO_NUM+Work->WKPOSICAO+Work->WKPGI_NUM) );
                            ,oMUserEDC:Solta("DI","SEL_ITEM")     ;
                            ,oMUserEDC:Reserva("DI","SEL_ITEM") ) ;
                       ,.T.)}  // PLB(TAV095) - 01/12/06
Local cTmpWrkSW8, cQuery, cSelect, cFrom , cWhere, nOldArea, lRetLoop, nRecno

PRIVATE  nFobTotal:=0, oFobTotal,ncTrBox:=ncTrLin:=127,lVolta:=.F., lFobUnit:=.T. //Variavel usada no Rdmake
PRIVATE oDlg,aBox, cAdmTemp
//RRV - 17/12/2012 - Criada variavéis que podem ser tratadas via ponto de entrada (Unidade de Medida).
Private cPicture := "AA"
Private nCompri := 05
Private nAltura := 08
Private nPesLiqTot := 0  // GFP - 15/04/2013
Private lAlteraNcm := .T. // MCF - 24/09/2014

lGravaSoCapa:=.F.

nL1:=10 ; nL2:=23 ; nL3:=036 ; nL4:= 049 ; nL5:= 062
nL6:=75 ; nL7:=88 ; nL8:=101 ; nL9:= 114 ; nLa:= 127
nC1:=08 ; nC2:=49 ; nC3:=098 ; nC4:= 127
nTamDlg:= 25
//MFR 14/10/2020 OSSME-5138
nRecno:=SW2->(RECNO())
Posicione("SW2",1,xFILIAL("SW2")+Work->WKPO_NUM,"W2_IMPORT")
If sw2->w2_impco !=  M->W6_IMPCO
   if M->W6_IMPCO == "1"
      msginfo(STR0907) //"Processo de importaçao por conta e ordem não pode ter item de pedido de que não é de importação por conta e ordem"
   Else
      msginfo(STR0908) //"Processo de importação que não é por conta e ordem não pode ter item de pedido de que é de importação por conta e ordem"
   Endif
   SW2->(DBGOTO(nRecno))
   Return .T.
EndIf
If sw2->w2_impenc !=  M->W6_IMPENC
   if M->W6_IMPENC == "1"
      msginfo(STR0909) //"Processo de importaçao por encomenda não pode ter item de pedido de que não é por encomenda"
   Else
      msginfo(STR0910) //"Processo de importação que não é por encomenda não pode ter item de pedido de que é por encomenda"
   Endif
   SW2->(DBGOTO(nRecno))
   Return .T.
EndIf
SW2->(DBGOTO(nRecno))  

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"TELA_MARCA_ITEM"),)

IF lVolta
   RETURN .T.
ENDIF

IF !EMPTY(M->W6_DTREG_D) .AND. !lRetifica .AND. lTemAdicao // LDR - 04/01/05 - DEICMAR
   MsgInfo(STR0677,STR0141) //STR0677 "O item nao pode ser alterado pois a data de registro da Di ja foi preenchida." //STR0141 := "Atenção"
   Return .T.
ENDIF

Work->WK_ALTEROU := .T.

SW7->( DBSetOrder(4) )  // PLB 01/12/06

IF Work->WKFLAG .AND. !ValidCambio(.F.,"Itens")//!lTemCambio
   If lIntDraw  .And.  lMUserEDC  .And.  MOpcao == FECHTO_DESEMBARACO  .And.  !Empty(Work->( WKAC+WKSEQSIS ))  .And.  !Empty(M->W6_DI_NUM)
      If SW7->( DBSeek(cFilSW7+M->W6_HAWB+Work->WKPO_NUM+Work->WKPOSICAO+Work->WKPGI_NUM) )
         If !oMUserEDC:Reserva("DI","SEL_ITEM")  // PLB 01/12/06 - Trava os registros refentes ao Item no objeto
            Return .F.
         EndIf
      Else
         oMUserEDC:Solta("DI","SEL_ITEM")  // PLB 01/12/06 - Destrava os registros refentes ao Item no objeto
      EndIf
   EndIf
   IF Work->WKDISPINV # Work->WKQTDE
      IF !MSGYESNO(STR0287,STR0141) //"Item possui Invoice, Deseja Desmarcar?"
         RETURN AlteraItem()
      ENDIF
      IF lEnvDesp .AND. lMsgEnv
         SWP->(DBSETORDER(1))
         IF SWP->(DBSEEK(xFilial("SWP")+Work->WKPGI_NUM+Work->WKSEQ_LI))
            IF !EMPTY(SWP->WP_ENV_ORI)
               MSGINFO(STR0634,STR0141) //STR0634 "Como o arquivo ja foi enviado para o despachante e sera feita uma alteração no item, o arquivo devera ser enviado novamente. " //STR0141 := "Atenção"
               lMsgEnv:=.F.
            ENDIF
         ENDIF
      ENDIF
      DBSELECTAREA("Work_SW8")
      SET FILTER TO
      Work_SW8->(DBSETORDER(2))

      /* Verifica se possui ato concessório vinculado ao processo de exportação
         Caso possua, não pode ser desmarcado */
      If ExisteACExport()
         Return .F.
      EndIf

      cSelect := " SELECT WKSW8.*"
      cFrom   := " FROM " + TETempName("Work_SW8") + " WKSW8"
      cWhere  := " WHERE" + iIF( TcSrvType()=="AS/400"," WKSW8.@DELETED@ <> '*' "," WKSW8.D_E_L_E_T_ <> '*'" )
      cWhere  += " AND WKSW8.WKFORN    = '"   + WORK->WKFORN   +"' "
      cWhere  += " AND WKSW8.W8_FORLOJ = '"   + WORK->W7_FORLOJ+"' "
      cWhere  += " AND WKSW8.WKPO_NUM  = '"   + WORK->WKPO_NUM +"' "
      cWhere  += " AND WKSW8.WKPOSICAO = '"   + WORK->WKPOSICAO+"' "
      cWhere  += " AND WKSW8.WKPGI_NUM = '"   + WORK->WKPGI_NUM+"' "

      cTmpWrkSW8 := GetNextAlias()
      cQuery     := ChangeQuery(cSelect + cFrom + cWhere)
      nOldArea   := Select()
      MPSysOpenQuery(cQuery, cTmpWrkSW8)
      DbSelectArea(cTmpWrkSW8)
      lRetLoop   := .T.
      DO While (cTmpWrkSW8)->(!Eof())
         Work_SW8->(DbgoTo( (cTmpWrkSW8)->R_E_C_N_O_ ))

         If lIntDraw .and. cAntImp == "2" .and. !Empty(Work->WKAC) //GFC - 17/07/2003 - Anterioridade Drawback

            //AAF 13/05/05 - Verifica se o Item está apropriado em Drawback.
            If aScan(aDesmarc,Work->( RecNo() )) == 0 .AND. ED2->( dbSeek(cFilED2+M->W6_HAWB+Work_SW8->( WKINVOICE+WKPO_NUM+WKPOSICAO+WKPGI_NUM )) )
               aAdd(aDesmarc,Work->( RecNo() ))
            Endif

         EndIf

         IF Work_SW9->(DBSEEK(Work_SW8->WKINVOICE+WORK_SW8->WKFORN+Work_SW8->W8_FORLOJ+M->W6_HAWB))
            WORK_SW9->W9_FOB_TOT-=Work_SW8->WKPRTOTMOE
            WORK_SW9->W9_TUDO_OK:=NAO
         ENDIF
         DI500Controle(1)
         DI500LoteVal("DEL_LOTE",,,WORK_SW8->(WKFORN+Work_SW8->W8_FORLOJ+WKPGI_NUM+WKPO_NUM+WKPOSICAO+WKINVOICE))//LGS-27/02/2015 //GFP - 25/06/2015
         lDeleta:=.T.

         IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"DESMARCA_ITEM_SW7"),)
      
         IF lDeleta
            Work_SW8->(DBDELETE())
         ELSE
            Work_SW8->WKFLAGIV :=""
            Work_SW8->WKADICAO :=""
            Work_SW8->WKFLAGDSI:=""
            Work_SW8->WKNVE    :=""//AWR - NVE - 17/10/2004
            Work_SW8->WKINVOICE:=SPACE(LEN(SW9->W9_INVOICE))
         ENDIF

         IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"2_DESMARCA_ITEM_SW7"),)//AWR - 09/08/2010
         (cTmpWrkSW8)->(DbSkip())
      ENDDO
   
      (cTmpWrkSW8)->(DbCloseArea())
      DbSelectArea(nOldArea)
      If !lRetLoop
         Return lRetLoop
      EndIf
   ENDIF
   //MFR 04/11/2020 OSSME-5183 conta efetuada na funcao DI500AtPs
   //M->W6_PESOL    -= Work->WKPESO_L * Work->WKQTDE 
   DI500AtPs("S")
   IF M->W6_PESOL < 0
      M->W6_PESOL := 0
   ENDIF
   Work->WKSALDO_Q:= Work->WKSALDO_O
   Work->WKDISPINV:= 0
   Work->WKQTDE_D := 0
   Work->WKQTDE   := 0
   If AvFlags("EIC_EAI")
      Work->WKQTSEGUM:= 0
   EndIf
   Work->WKFLAG   := !Work->WKFLAG
   Work->WKFLAGWIN:= Space(2)
   RETURN .T.
ENDIF

SW7->( DBSetOrder(nOrdSW7) )
SW7->( DBGoTo(nRecSW7) )

IF Work->WKFLUXO # "7" .AND. cPaisLoc = "BRA"
   IF EMPTY(Work->WKREGIST)
      Help("", 1, "AVG0000254")//Este item nao possui registro no SISCOMEX
   ELSEIF EMPTY(Work->WKREG_VEN)
      Help("", 1, "AVG0000255")//Este item nao possui anuencia
   ENDIF
ENDIF

IF lExiste_Midia .AND. lPesoMid // LDR - 24/08/04
   SB1->(DBSETORDER(1))
   SB1->(DBSEEK(xFILIAL("SB1")+WORK->WKCOD_I))
   IF SB1->B1_MIDIA $ cSIM
      lGet_Mid:=.T.
   ENDIF
ENDIF

M->W7_PESO   := Work->WKPESO_L
M->W7_NCM    := Work->WKTEC
M->W7_EX_NCM := Work->WKEX_NCM
M->W7_EX_NBM := Work->WKEX_NBM

//FSM - 31/08/2011 - "Peso Bruto Unitário"
If lPesoBruto
   M->W7_PESO_BR := Work->WKW7PESOBR
EndIf

IF !lAUTPCDI
   M->W8_VLUPIS := Work->WKVLUPIS
   M->W8_VLUCOF := Work->WKVLUCOF
   M->W8_PERPIS := Work->WKPERPIS
   M->W8_PERCOF := Work->WKPERCOF
ENDIF
IF lGet_Mid   // LDR - 25/08/04
   M->W7_PESOMID:= Work->WKPESOMID // LDR - 24/08/04
ENDIF
TSaldo_Q     := Work->WKSALDO_Q
TFobUnit     := Work->WKPRECO
nFobTotal    := DI500Trans(TSaldo_Q * TFobUnit)
TUnidade     := Eval({||BUSCA_UM(Work->WKCOD_I+Work->WKFABR+Work->WKFORN,WORK->WKCC+WORK->WKSI_NUM, EICRetLoja("Work", "W7_FABLOJ"), Work->W7_FORLOJ)})  //NCF - 15/10/2009
nPesLiqTot   := TSaldo_Q * M->W7_PESO  // GFP - 15/04/2013

DEFINE MSDIALOG oDlg TITLE cTitulo From 00,00 To nTamDlg,50 OF oMainWnd

@nL1,nC1 SAY AVSX3("W7_COD_I",5)  SIZE 40,8 PIXEL//'Codigo Item'
@nL1,nC2 MSGET Work->WKCOD_I    PICT AVSX3("W7_COD_I",6) SIZE 107,08 PIXEL WHEN .F.
nL1+=13
@nL1,nC1 SAY AVSX3("A5_CODPRF",5)  SIZE 40,8 PIXEL//Part Number
@nL1,nC2 MSGET Work->WKPART_N   PICT '@!' SIZE 107,08 PIXEL WHEN .F.
nL1+=13
@nL1,nC1 SAY AVSX3("W7_FABR",5)    SIZE 40,8 PIXEL//Fabricante
@nL1,nC2 MSGET Work->WKNOME_FAB PICT '@!'   SIZE 107,08 PIXEL WHEN .F.
nL1+=13
@nL1,nC1 SAY AVSX3("W7_FORN",5)    SIZE 40,8 PIXEL//Fornecedor
@nL1,nC2 MSGET Work->WKNOME_FOR PICT '@!'   SIZE 107,08 PIXEL WHEN .F.
nL1+=13
@nL1,nC1 SAY AVSX3("W7_SALDO_Q",5) SIZE 40,08 PIXEL//Saldo Qtde
@nL1,nC2 MSGET TSaldo_Q PICTURE _PictQtde VALID DI_Valid('TSALDO_Q',.F.) SIZE 80,08 PIXEL WHEN !ValidCambio(.F.,"Itens")//!lTemCambio SVG - 01/09/2011 -!lTemCambio
nL1+=13
@nL1,nC1 SAY STR0048               SIZE 40,8 PIXEL//Preco Unitario
@nL1,nC2 MSGET TFobUnit PICTURE _PictPrUn VALID DI_Valid('TFOBUNIT',.F.) SIZE 80,08 PIXEL WHEN !ValidCambio(.F.,"Itens")/*!lTemCambio*/ .AND. lFobUnit
nL1+=13
@nL1,nC1 SAY STR0108               SIZE 50,8 PIXEL//FOB Total
//RMD - 09/06/08 - Utiliza a picture do campo W9_FOB_TOT, base da variável nDecimais, parâmetro no arredondamento do valor FOB
//@nL1,nC2 MSGET oFobTotal VAR nFobTotal PICTURE _PictPrUn SIZE 80,08 WHEN .F. PIXEL
@nL1,nC2 MSGET oFobTotal VAR nFobTotal PICTURE AvSx3("W9_FOB_TOT", AV_PICTURE) SIZE 80,08 WHEN .F. PIXEL
nL1+=13
@nL1,nC1 SAY AVSX3("W7_PESO",5)    SIZE 50,8 PIXEL
@nL1,nC2 MSGET M->W7_PESO    PICTURE AVSX3("W7_PESO",6) VALID DI_Valid('M->W7_PESO',.F.) SIZE 80,08 PIXEL
nL1+=13
// GFP - 15/04/2013 - Inclusão de campo Peso Liquido Total para calculo de Peso Liquido Unitario.
@nL1,nC1 SAY STR0839               SIZE 40,8 PIXEL//"Peso Liq Total"
@nL1,nC2 MSGET nPesLiqTot PICTURE AVSX3(/*"W7_PESO"*/"W6_PESOTOT",6) VALID DI_Valid('PESLIQTOT',.F.) SIZE 80,08 PIXEL //FSY - 03/06/2013 - AVSX3("W6_PESOTOT",6) Alterado o tamanho para 13,3 do campo. ex: 999.999.999,999
nL1+=13

//FSM - 30/08/2011 - Inclusao do campo "Peso Bruto Unitário"
If lPesoBruto
   @nL1,nC1 SAY AVSX3("W7_PESO_BR",5)    SIZE 50,8 PIXEL
   @nL1,nC2 MSGET M->W7_PESO_BR   PICTURE AVSX3("W7_PESO_BR",AV_PICTURE) VALID Positivo() SIZE 80,08 PIXEL
   nL1+=13
EndIf


If (EasyEntryPoint("EICDI500"),Execblock("EICDI500",.f.,.f.,"ALTERA_PESO"),)//acb 27/05/2010

@nL1,nC1 SAY AVSX3("B1_UM",5) SIZE 40,08 PIXEL //Unidade
@nL1,nC2 MSGET TUnidade PICTURE cPicture SIZE nCompri,nAltura PIXEL WHEN .F. //NCF - 15/10/2009 //RRV - 17/12/2012 - Criada variavéis que podem ser tratadas via ponto de entrada (Unidade de Medida).
nL1+=13
@nL1,nC1 SAY AVSX3("W7_NCM",5)  SIZE 40,8 PIXEL
@nL1,nC2 MSGET M->W7_NCM    SIZE 45,8 VALID DI_Valid('TEC1',.F.) PICTURE AVSX3("W3_TEC"   ,6)  F3 AVSX3("W3_TEC",8)   WHEN lAlteraNcm PIXEL HASBUTTON//MCF - 24/09/2014
@nL1,nC3 MSGET M->W7_EX_NCM SIZE 05,8 VALID DI_Valid('TEC2',.F.) PICTURE AVSX3("W3_EX_NCM",6) F3 AVSX3("W3_EX_NCM",8) WHEN !Empty(M->W7_NCM) PIXEL HASBUTTON
@nL1,nC4 MSGET M->W7_EX_NBM SIZE 05,8 VALID DI_Valid('TEC3',.F.) PICTURE AVSX3("W3_EX_NBM",6) F3 AVSX3("W3_EX_NBM",8) WHEN !Empty(M->W7_NCM) PIXEL HASBUTTON
nL1+=13
IF Work->WKIPIPAUTA # 0
  @nL1,nC1 SAY STR0288 PIXEL //"IPI de Pauta"
  @nL1,nC2 MSGET Work->WKIPIPAUTA Picture "@E 9999,999,999.99999" SIZE 80,08 PIXEL // Bete - 09/09/04
  nL1+=13
ENDIF

IF lMV_PIS_EIC .AND. MOpcao # FECHTO_EMBARQUE .AND. (lTemAdicao .OR. lDISimples) .AND. !(lIntDraw .AND. !Empty(Work->WKAC)) .AND. !lAUTPCDI
   @nL1,nC1 SAY AVSX3("W8_PERPIS",5)    SIZE 50,8 PIXEL
   @nL1,nC2 MSGET M->W8_PERPIS PICTURE AVSX3("W8_PERPIS",6) VALID EVAL(AVSX3("W8_PERPIS",7)) SIZE 80,08 PIXEL WHEN EVAL(AVSX3("W8_PERPIS",13))
   nL1+=13
   @nL1,nC1 SAY AVSX3("W8_PERCOF",5)    SIZE 50,8 PIXEL
   @nL1,nC2 MSGET M->W8_PERCOF PICTURE AVSX3("W8_PERCOF",6) VALID EVAL(AVSX3("W8_PERCOF",7)) SIZE 80,08 PIXEL WHEN EVAL(AVSX3("W8_PERCOF",13))
   nL1+=13
   @nL1,nC1 SAY AVSX3("W8_VLUPIS",5)    SIZE 50,8 PIXEL
   @nL1,nC2 MSGET M->W8_VLUPIS PICTURE AVSX3("W8_VLUPIS",6) VALID EVAL(AVSX3("W8_VLUPIS",7)) SIZE 80,08 PIXEL WHEN EVAL(AVSX3("W8_VLUPIS",13))
   nL1+=13
   @nL1,nC1 SAY AVSX3("W8_VLUCOF",5)    SIZE 50,8 PIXEL
   @nL1,nC2 MSGET M->W8_VLUCOF PICTURE AVSX3("W8_VLUCOF",6) VALID EVAL(AVSX3("W8_VLUCOF",7)) SIZE 80,08 PIXEL WHEN EVAL(AVSX3("W8_VLUCOF",13))
   oDlg:nHeight:=(nL1+250)
   nL1+=13
ENDIF

If lGet_Mid      // LDR - 24/08/04
   @nL1,nC1 SAY AVSX3("W7_PESOMID",5)    SIZE 50,8 PIXEL
   @nL1,nC2 MSGET M->W7_PESOMID PICTURE AVSX3("W7_PESOMID",6) VALID EVAL(AVSX3("W7_PESOMID",7)) SIZE 80,08 PIXEL WHEN EVAL(AVSX3("W7_PESOMID",13))
   oDlg:nHeight:=(nL1+250)
   nL1+=13
EndIf

If lIntDraw .and. lMensDrawback .and. Empty(M->W6_DTREG_D) // GFC 18/08/04
   nL1+=4
   @nL1,nC2 SAY MensDrawback(.T.,Work->WKCOD_I,Work->WKFORN,Work->WKINVOICE,Work->WKPO_NUM,Work->WKPOSICAO,Work->WKPGI_NUM,Work->WKAC,Work->WKTEC)  SIZE 150,8 PIXEL FONT oDlg:oFont COLOR CLR_HRED
   nL1+=13
EndIf
IF AvFlags("EIC_EAI")//AWF - 25/06/2014
   M->W7_QTSEGUM := TSaldo_Q * Work->WKFATOR
   cSegUN:= TRANS(M->W7_QTSEGUM,AVSX3("W3_QTSEGUM",6))+" "+WORK->WKSEGUM//AWF - 01/07/2014
   @nL1,nC1 SAY AVSX3("W3_QTSEGUM",AV_TITULO) SIZE 40,8 PIXEL
   @nL1,nC2 MSGET cSegUN SIZE 60,8 PIXEL WHEN .F.//AWF - 01/07/2014
   nL1+=13
ENDIF
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"SEL_ITEM"),)
//IGOR CHIBA 04/05/09 DEFINE SBUTTON FROM 010,160 TYPE 1 ACTION IIF(!  lIntDraw .Or. Eval(bValid)                                   ,(nopca:=1,oDlg:End()),) ENABLE OF oDlg PIXEL
DEFINE SBUTTON FROM 010,160 TYPE 1 ACTION  IF( (!lIntDraw .Or. Eval(bValid)) .AND. DI_Valid('TEC1' ,.F.) .And. DI_Valid('M->W7_PESO' ,.F.) .and. DI_Valid("OK",.F.) ,(nopca:=1,oDlg:End()) ,) ENABLE OF oDlg PIXEL
DEFINE SBUTTON FROM nL3,160 TYPE 2 ACTION(nopca:=0,oDlg:End()) ENABLE OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTERED

DBSELECTAREA("Work")

IF nOpcA = 1

   //** AAF 13/05/05 - Para Itens apropriados em Drawback.
   If lIntDraw
      nPos := aScan(aDesmarc,Work->( RecNo() ))
      If nPos > 0
         aDel(aDesmarc,nPos)
      Endif
   Endif
   //NCF - 09/11/2009 - Impede a marcação do item quando o valor de peso líquido do pedido excede
   //                   o suportado pelo tamanho do campo W6_PESOL
   SX3->(DbSetOrder(2))
   SX3->(DBSeek("W6_PESOL"))
   cValor := STR(M->W6_PESOL+(M->W7_PESO * IF(lTemCambio,Work->WKQTDE,M->TSaldo_Q)),,AvSx3("W6_PESOL", AV_DECIMAL))
   cInteiro := AllTrim(SubStr(cValor, 1, At(".", cValor)))
   cDecimal := AllTrim(SubStr(cValor, At(".", cValor) + 1))

   //If (Len(cInteiro) > (AvSx3("W6_PESOL", AV_TAMANHO)) - AvSx3("W6_PESOL", AV_DECIMAL) - 1) .Or. (Len(cDecimal) > AvSx3("W6_PESOL", AV_DECIMAL))
   If (Len(cInteiro)+Len(cDecimal)) > AvSx3("W6_PESOL", AV_TAMANHO)
      //
      MsgStop(STR0674+CHR(13)+CHR(10); //STR0674 "O Peso x Quantidade dos itens do processo "
             +STR0675+CHR(13)+CHR(10); //STR0675 "ultrapassou o limite suportado pelo sistema!"
             +STR0676) //STR0676 "Efetue a correção no(s) peso(s) do(s) iten(s)"
      RETURN .F.
   ENDIF

   IF ValidCambio(.F.,"Itens")//lTemCambio
      DBSELECTAREA("Work_SW8")
      SET FILTER TO
      Work_SW8->(DBSETORDER(2))
      IF Work_SW8->(DBSEEK(WORK->WKFORN+Work->W7_FORLOJ+WORK->WKPO_NUM+WORK->WKPOSICAO+WORK->WKPGI_NUM))
         DO WHILE Work_SW8->(!EOF()) .AND.;
                  WORK_SW8->(WKFORN+Work_SW8->W8_FORLOJ+WKPO_NUM+WKPOSICAO+WKPGI_NUM) ==;
                  WORK->(WKFORN+Work->W7_FORLOJ+WKPO_NUM+WKPOSICAO+WKPGI_NUM)
            Work_SW8->WKTEC     := M->W7_NCM
            Work_SW8->WKEX_NCM  := M->W7_EX_NCM
            Work_SW8->WKEX_NBM  := M->W7_Ex_NBM
            Work_SW8->WKPESO_L  := M->W7_PESO
            Work_SW8->WKPESOTOT := M->W7_PESO*Work_SW8->WKQTDE
            IF !lAUTPCDI
               Work_SW8->WKVLUPIS  := M->W8_VLUPIS
               Work_SW8->WKVLUCOF  := M->W8_VLUCOF
               Work_SW8->WKPERPIS  := M->W8_PERPIS
               Work_SW8->WKPERCOF  := M->W8_PERCOF
            ENDIF
            IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GRV_ALT_SW8"),)
            Work_SW8->(DBSKIP())
         ENDDO
      ENDIF
      M->W6_PESOL     -= Work->WKPESO_L * Work->WKQTDE
      IF M->W6_PESOL < 0
         M->W6_PESOL := 0
      ENDIF
      Work->WKPESO_L  := M->W7_PESO
      Work->WKTEC     := M->W7_NCM
      Work->WKEX_NCM  := M->W7_EX_NCM
      Work->WKEX_NBM  := M->W7_Ex_NBM
      IF !lAUTPCDI
         Work->WKVLUPIS  := M->W8_VLUPIS
         Work->WKVLUCOF  := M->W8_VLUCOF
         Work->WKPERPIS  := M->W8_PERPIS
         Work->WKPERCOF  := M->W8_PERCOF
      ENDIF
      M->W6_PESOL     += Work->WKPESO_L * Work->WKQTDE
      IF lGet_Mid   // LDR - 25/08/04
         Work->WKPESOMID := M->W7_PESOMID  // LDR  - 24/08/04
      ENDIF
      DI500Controle(1)
      IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"MARCA_ITEM_COM_CAMBIO"),)
      RETURN .T.
   ENDIF
   Work->WKQTDE    := TSaldo_Q
   Work->WKQTDE_D  := TSaldo_Q
   Work->WKSALDO_Q := Work->WKSALDO_Q - TSaldo_Q
   Work->WKPRECO   := TFobUnit
   Work->WKFLAG    := .T.
   Work->WKFLAGWIN := cMarca
   Work->WKPESO_L  := M->W7_PESO
   Work->WKTEC     := M->W7_NCM
   Work->WKEX_NCM  := M->W7_EX_NCM
   Work->WKEX_NBM  := M->W7_Ex_NBM
   IF AvFlags("EIC_EAI")//AWF - 25/06/2014
      Work->WKQTSEGUM := M->W7_QTSEGUM//WorK->WKQTDE*Work->WKFATOR
   ENDIF
   //FSM - 31/08/2011 - "Peso Bruto Unitário"
   If lPesoBruto
      Work->WKW7PESOBR := M->W7_PESO_BR
   EndIf

   IF !lAUTPCDI
      Work->WKVLUPIS  := M->W8_VLUPIS
      Work->WKVLUCOF  := M->W8_VLUCOF
      Work->WKPERPIS  := M->W8_PERPIS
      Work->WKPERCOF  := M->W8_PERCOF
   ENDIF
   WORK->WKDISPINV := Work->WKQTDE
   //MFR 04/11/2020 OSSME-5183 conta efetuada na funcao DI500AtPs
   //M->W6_PESOL     += Work->WKPESO_L * Work->WKQTDE 
   DI500AtPs("A")
   IF lGet_Mid    // LDR - 25/08/04
      Work->WKPESOMID := M->W7_PESOMID   // LDR - 24/08/04
   ENDIF
   DI500Controle(1)
   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"MARCA_ITEM_SW7"),)
ENDIF

RETURN .T.


/*
Funcao      : ExisteACExport()
Parâmetros  :
Retorno     :
Objetivos   : Verificar se possui ato concessório vinculado ao processo de exportação
Autor       : wfs
Data 	      : out/2019
Obs         :
Revisão     :
*/
Static Function ExisteACExport()
Local lRet:= .F.
Local cNextAlias:= "", cSelect:= "", cFrom:= "", cWhere:= ""

Begin Sequence

   If lIntDraw .and. cAntImp == "2" .and. !Empty(Work->WKAC)

      cSelect := " SELECT WKSW8.WKFORN, WKSW8.W8_FORLOJ, WKSW8.WKPO_NUM, WKSW8.WKPOSICAO, WKSW8.WKPGI_NUM, WKSW8.WKINVOICE"
      cFrom   := " FROM " + TETempName("Work_SW8") + " WKSW8"
      cFrom   += " Join " + RetSqlName("EDD") + " EDD"
      cFrom   += " on EDD.EDD_FILIAL = '" + EDD->(xFilial()) + "' and EDD.EDD_HAWB = '" + M->W6_HAWB + "' and EDD.EDD_INVOIC = WKSW8.WKINVOICE and EDD.EDD_PO_NUM = WKSW8.WKPO_NUM "
      cFrom   += " and EDD.EDD_POSICA = WKSW8.WKPOSICAO and EDD.EDD_PGI_NU = WKSW8.WKPGI_NUM "
      cWhere  := " WHERE WKSW8.D_E_L_E_T_ <> '*'"
      cWhere  += " AND WKSW8.WKFORN    = '"   + WORK->WKFORN   +"' "
      cWhere  += " AND WKSW8.W8_FORLOJ = '"   + WORK->W7_FORLOJ+"' "
      cWhere  += " AND WKSW8.WKPO_NUM  = '"   + WORK->WKPO_NUM +"' "
      cWhere  += " AND WKSW8.WKPOSICAO = '"   + WORK->WKPOSICAO+"' "
      cWhere  += " AND WKSW8.WKPGI_NUM = '"   + WORK->WKPGI_NUM+"' "
      cWhere  += " and (EDD.EDD_PREEMB <> ' ' or EDD.EDD_PEDIDO <> ' ' or EDD.EDD_CODOCO <> ' ' )"


      cNextAlias := GetNextAlias()
      cQuery     := ChangeQuery(cSelect + cFrom + cWhere)
      MPSysOpenQuery(cQuery, cNextAlias)
      
      If (cNextAlias)->(!Bof()) .And. (cNextAlias)->(!Eof())
         MsgInfo(STR0678) //STR0678 "Item não pode ser desmarcado pois está vinculado a um RE de acordo com a anterioridade."
         lRet:= .T.
      EndIf

      (cNextAlias)->(DBCloseArea())

   EndIf

End Sequence

Return lRet


/*--------------------------------------------------------------------------------------------------
Funcao      : AlteraItem
Objetivos   : Permitir alterar o peso e a NCM do item do Desembaraço sem desmarcar a Invoice.
Autor       : Diogo Felipe dos Santos
Data/Hora   : 15/01/2013
Revisao     : Rodrigo Mendes
*----------------------------------------------------------------------------------------------------*/
Static Function AlteraItem()

Local lGet_Mid := .F.
LOCAL cFilSW7:=xFilial("SW7")
Local bValid := {||IIF(lMUserEDC .And. MOpcao == FECHTO_DESEMBARACO .And. lIntDraw .And. !Empty(Work->WKAC) .And. !Empty(M->W6_DI_NUM);
                       ,IIF(SW7->( DBSeek(cFilSW7+M->W6_HAWB+Work->WKPO_NUM+Work->WKPOSICAO+Work->WKPGI_NUM) );
                            ,oMUserEDC:Solta("DI","SEL_ITEM")     ;
                            ,oMUserEDC:Reserva("DI","SEL_ITEM") ) ;
                       ,.T.)}    // GFP - 12/06/2013
Private TSaldo_Q, TFOBUNIT, nFobTotal

//Carregar variáveis de memória da work "WORK"
M->W7_PESO   := Work->WKPESO_L
M->W7_NCM    := Work->WKTEC
M->W7_EX_NCM := Work->WKEX_NCM
M->W7_EX_NBM := Work->WKEX_NBM
//MFR 04/11/2020 OSSME-5183
DI500AtPs("S")

TSaldo_Q  := WORK->WKSALDO_Q //WORK->WKSALDO_O  // GFP - 22/05/2013
TFOBUNIT  := WORK->WKPRECO
nFobTotal := DI500Trans(TSaldo_Q * TFobUnit)  //WORK_SW9->W9_FOB_TOT   // GFP - 03/06/2014

If lPesoBruto
   M->W7_PESO_BR := Work->WKW7PESOBR
EndIf

IF lExiste_Midia .AND. lPesoMid
   SB1->(DBSETORDER(1))
   SB1->(DBSEEK(xFILIAL("SB1")+WORK->WKCOD_I))
   IF SB1->B1_MIDIA $ cSIM
      lGet_Mid:=.T.
   ENDIF
ENDIF

IF lGet_Mid
   M->W7_PESOMID:= Work->WKPESOMID
ENDIF

//Exibir Tela
DEFINE MSDIALOG oDlg TITLE cTitulo From 00,00 To nTamDlg,50 OF oMainWnd

@nL1,nC1 SAY AVSX3("W7_COD_I",5)  SIZE 40,8 PIXEL//'Codigo Item'
@nL1,nC2 MSGET Work->WKCOD_I    PICT AVSX3("W7_COD_I",6) SIZE 107,08 PIXEL WHEN .F.
nL1+=13
@nL1,nC1 SAY AVSX3("A5_CODPRF",5)  SIZE 40,8 PIXEL//Part Number
@nL1,nC2 MSGET Work->WKPART_N   PICT '@!' SIZE 107,08 PIXEL WHEN .F.
nL1+=13
@nL1,nC1 SAY AVSX3("W7_FABR",5)    SIZE 40,8 PIXEL//Fabricante
@nL1,nC2 MSGET Work->WKNOME_FAB PICT '@!'   SIZE 107,08 PIXEL WHEN .F.
nL1+=13
@nL1,nC1 SAY AVSX3("W7_FORN",5)    SIZE 40,8 PIXEL//Fornecedor
@nL1,nC2 MSGET Work->WKNOME_FOR PICT '@!'   SIZE 107,08 PIXEL WHEN .F.
nL1+=13
@nL1,nC1 SAY AVSX3("W7_SALDO_Q",5) SIZE 40,08 PIXEL//Saldo Qtde
@nL1,nC2 MSGET TSaldo_Q PICTURE _PictQtde VALID DI_Valid('TSALDO_Q',.F.) SIZE 80,08 PIXEL WHEN .F.
nL1+=13
@nL1,nC1 SAY STR0048               SIZE 40,8 PIXEL//Preco Unitario
@nL1,nC2 MSGET TFobUnit PICTURE _PictPrUn VALID DI_Valid('TFOBUNIT',.F.) SIZE 80,08 PIXEL WHEN .F.
nL1+=13
@nL1,nC1 SAY STR0108               SIZE 50,8 PIXEL//FOB Total
@nL1,nC2 MSGET oFobTotal VAR nFobTotal PICTURE AvSx3("W9_FOB_TOT", AV_PICTURE) SIZE 80,08 WHEN .F. PIXEL
nL1+=13
@nL1,nC1 SAY AVSX3("W7_PESO",5)    SIZE 50,8 PIXEL
@nL1,nC2 MSGET M->W7_PESO    PICTURE AVSX3("W7_PESO",6) VALID DI_Valid('Peso_Tot',.F.) SIZE 80,08 PIXEL
nL1+=13

If lPesoBruto
   @nL1,nC1 SAY AVSX3("W7_PESO_BR",5)    SIZE 50,8 PIXEL
   @nL1,nC2 MSGET M->W7_PESO_BR   PICTURE AVSX3("W7_PESO_BR",AV_PICTURE) VALID Positivo() SIZE 80,08 PIXEL
   nL1+=13
EndIf

@nL1,nC1 SAY AVSX3("W7_NCM",5)  SIZE 40,8 PIXEL
@nL1,nC2 MSGET M->W7_NCM    SIZE 45,8 VALID DI_Valid('TEC1',.F.) PICTURE AVSX3("W3_TEC"   ,6) F3 AVSX3("W3_TEC",8) PIXEL
@nL1,nC3 MSGET M->W7_EX_NCM SIZE 05,8 VALID DI_Valid('TEC2',.F.) PICTURE AVSX3("W3_EX_NCM",6) F3 AVSX3("W3_EX_NCM",8) WHEN !Empty(M->W7_NCM) PIXEL
@nL1,nC4 MSGET M->W7_EX_NBM SIZE 05,8 VALID DI_Valid('TEC3',.F.) PICTURE AVSX3("W3_EX_NBM",6) F3 AVSX3("W3_EX_NBM",8) WHEN !Empty(M->W7_NCM) PIXEL
nL1+=13

DEFINE SBUTTON FROM 010,160 TYPE 1 ACTION  IF( (!lIntDraw .Or. Eval(bValid)) .AND. DI_Valid('M->W7_PESO' ,.F.) ,(nopca:=1,oDlg:End()) ,) ENABLE OF oDlg PIXEL
DEFINE SBUTTON FROM nL3,160 TYPE 2 ACTION(nopca:=0,oDlg:End()) ENABLE OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTERED

//Validar peso digitado

//Gravar resultado na "WORK"
if nopca == 1
   Work->WKPESO_L := M->W7_PESO
   Work->WKTEC    := M->W7_NCM
   Work->WKEX_NCM := M->W7_EX_NCM
   Work->WKEX_NBM := M->W7_EX_NBM
Else
   M->W7_PESO   := Work->WKPESO_L
   M->W7_NCM    := Work->WKTEC
   M->W7_EX_NCM := Work->WKEX_NCM
   M->W7_EX_NBM := Work->WKEX_NBM
EndIf
//MFR 04/11/2020 OSSME-5183
DI500AtPs("A")

//Caso o item tenha invoice (WORK_SW8), atualizar
IF Work_SW8->(DBSEEK(WORK->WKFORN+Work->W7_FORLOJ+WORK->WKPO_NUM+WORK->WKPOSICAO+WORK->WKPGI_NUM))
   DO WHILE Work_SW8->(!EOF()) .AND. WORK_SW8->(WKFORN+Work_SW8->W8_FORLOJ+WKPO_NUM+WKPOSICAO+WKPGI_NUM) == WORK->(WKFORN+Work->W7_FORLOJ+WKPO_NUM+WKPOSICAO+WKPGI_NUM)
      Work_SW8->WKPESO_L  := Work->WKPESO_L
      Work_SW8->WKPESOTOT := Work_SW8->(WKPESO_L*WKQTDE)
      Work_SW8->WKTEC     := Work->WKTEC
      Work_SW8->WKEX_NCM  := Work->WKEX_NCM
      Work_SW8->WKEX_NBM  := Work->WKEX_NBM
      Work_SW8->(DBSKIP())
   EndDo
EndIf

Return Nil

//Função..: VerItemAto()
//Autor...: AAF - Alessandro Alves Ferreira
//Data....: 13/05/05
//Objetivo: Verifica se algum item apropriado para drawback foi desmarcado.
****************************
Static Function VerItemAto()
****************************
Local lRet := .T.

If lIntDraw .AND. aScan(aDesmarc,{|X| X <> NIL}) > 0
   MsgStop(STR0763)// STR0763 "Itens apropriados para Drawback devem estar selecionados"
   lRet := .F.
Endif

Return lRet

/*------------------------------------------------------------------------------------
Funcao      : DeduFretN
Parametros  : lAuto - variável lógica que indica se realiza a dedução automática ou solicita confirmação do usuário
                      .T. - realiza dedução sem solicitar a confirmação do usuário
                      .F. - solicita a confirmção do usuário
Retorno     : valor lógico se o usuário optou pela dedução automática
Objetivos   : Dedução automática do frete nacional para incoterms CPT, CIP e DDU
Autor       : Anderson Soares Toledo
Data/Hora   : 02/02/09
Revisao     : Caio César Henrique - 03/06/09 - O Rateio deve ser feito por PESO, e não por Adição
Obs.        :
*------------------------------------------------------------------------------------*/
Static Function DeduFretN(lAuto)
   //Local nFreteRat := 0 // Valor do frete rateado para as adições
   Local nGrupoInc := 0 // nº de adições com incoterm do grupo: CPT, CIP e DDU, utilizada para verificar
                        // por quantas adições será realizado o rateio
   Local aOrd           // armazenar o indice e o registro das tabelas "Work_EIJ" e "Work_EIN"
   Local nPesoTot  := 0 // Armazenar o Peso Total para utilização no rateio por peso CCH - 03/06/2009

   Default lAuto := .F.

   If M->W6_VLFRETN > 0  //Verifica se existe frete nacional
      aOrd := SaveOrd({"Work_EIJ","Work_EIN"})
      WORK_EIJ->(dbGoTop())
      While !Work_EIJ->(EOF())
         If AvRetInco(Work_EIJ->EIJ_INCOTE,"CONTEM_FRETEN")/*FDR - 27/12/10*/  //Work_EIJ->EIJ_INCOTE $ "CPT,CIP,DDU"
            nGrupoInc++
            nPesoTot += EIJ->EIJ_PESOL
         EndIf
         Work_EIJ->(dbSkip())
      EndDo
      If nGrupoInc > 0
         If lAuto .Or. MsgYesNo(STR0766) //STR0766 "Deseja realizar a dedução automática do frete nacional para os incoterms CPT,CIP e DDU?"
            lAuto := .T.
            //nFreteRat := M->W6_VLFRETN/nGrupoInc
            Work_EIJ->(dbGoTop())
            While !Work_EIJ->(EOF())
               If AvRetInco(Work_EIJ->EIJ_INCOTE,"CONTEM_FRETEN") /* FSM - 27/12/10 */ //Work_EIJ->EIJ_INCOTE $ "CPT,CIP,DDU"
                  If !Work_EIN->(dbSeek(Work_EIJ->EIJ_ADICAO+"2"+"01"))
                     Work_EIN->(dbAppend())
                     Work_EIN->EIN_TIPO   := "2"
                     Work_EIN->EIN_CODIGO := "01"
                     Work_EIN->EIN_DESC   := "FRETE INTERNO - PAIS DE IMPORTACAO"
                     Work_EIN->EIN_FOBMOE := M->W6_FREMOED
                     Work_EIN->EIN_VLMLE  := Round(((M->W6_VLFRETN * EIJ->EIJ_PESOL)/nPesoTot),AVSX3("EIN_VLMLE",4))
                     Work_EIN->EIN_VLMMN  := Round((Work_EIN->EIN_VLMLE * M->W6_TX_FRET),AVSX3("EIN_VLMMN",4))
                     //Work_EIN->EIN_VLMLE  := nFreteRat
                     //Work_EIN->EIN_VLMMN  := nFreteRat * M->W6_TX_FRET
                     Work_EIN->EIN_ADICAO := Work_EIJ->EIJ_ADICAO
                     IF !Check_adic(Work_EIN->EIN_ADICAO) // 03/08/12 - BCO - Validação para o Campo EIN_ADICAO não ser gravado vazio
                        Return .F.
                     ENDIF
                  EndIf
               EndIf
               Work_EIJ->(dbSkip())
            EndDo
         EndIf
      EndIf
      RestOrd(aOrd,.T.)
   EndIf

Return lAuto

*******************************
Static Function DI500DrawICMS()
*******************************
Local lRet := .T.

ED4->( dbSetOrder(2) )
ED0->( dbSetOrder(1) )

If ED4->( dbSeek(xFilial("ED4")+Work_SW8->WKAC+Work_SW8->WKSEQSIS) ) .AND.;
   ED0->( dbSeek(xFilial("ED0")+ED4->ED4_PD) ) .AND.;
   ED0->ED0_TIPOAC # "02" .AND.;
   ED0->ED0_MODAL == "1"

   lRet := .F.
EndIf

Return lRet

*==============================*
Static Function DI500GrvW7W8W9(lPrimeiro,lMostMsgNVE,lTemNVEPLI,lTemNVECad,oJsonInvAnt)
*==============================*
Local aSegUM:= {}, aOrd := SaveOrd("EIM")
Local aWKSW5Ncm   := {}

Begin Sequence

	lTemItens := .T.

	EW5->(DbSetOrder(2))
	EW5->(DbSeek(xFilial("EW5")+SW5->(W5_PO_NUM+W5_POSICAO)+WORK_SEL->WKINVOIC+SW5->W5_FORN+EICRetLoja("SW5", "W5_FORLOJ")))
	EW4->(DbSeek(xFilial("EW4")+EW5->EW5_INVOIC+SW5->W5_FORN+EICRetLoja("SW5", "W5_FORLOJ")))
	SW3->(DbSeek(xFilial("SW3")+EW5->(EW5_PO_NUM+EW5_POSICA)))

	If AvFlags("EIC_EAI")
	   aSegUM:= Busca_2UM(EW5->EW5_PO_NUM, EW5->EW5_POSICA)
	EndIf

	//Grava Work do SW7
	nOrdWork:=WORK->(INDEXORD())
	WORK->(DbSetOrder(3))	//"WKPO_NUM+WKPGI_NUM+WKPOSICAO"
	If WORK->(dbSeek(WORK_SEL->(WKPO_NUM+WKPLI+WKPOSICAO)))
      If WORK->WKSALDO_Q >= WORK_SEL->WKQTD_SLA //empty(WORK->WKFLAGWIN)
         WORK->WKQTDE    := WORK->WKQTDE+WORK_SEL->WKQTD_SLA
         WORK->WKQTDE_D  := WORK->WKQTDE_D+WORK_SEL->WKQTD_SLA
         WORK->WKSALDO_Q := WORK->WKSALDO_O-WORK->WKQTDE_D
         WORK->WKSALDO_O := SW5->W5_SALDO_Q
         WORK->WKDISPINV := WORK->WKDISPINV - WORK_SEL->WKQTD_SLA   //TRP - 08/07/2010
         If WORK->WKDISPINV < 0
            WORK->WKDISPINV:= 0
         EndIf
         WORK->WK_ALTEROU:= .T.
         WORK->WKFLAG		:=	.T.
         WORK->WKFLAGWIN	:=	cMarca
         WORK->WKFLAG2		:=	.F.
         WORK->WKFLAGWIN2	:=	cMarca

         If AvFlags("EIC_EAI") .And. Len(aSegUM) > 0
            Work->WKUNI    :=aSegUM[1]
            Work->WKSEGUM  :=aSegUM[2]
            Work->WKFATOR  :=aSegUM[3]
            Work->WKQTSEGUM:=Work->WKQTDE * Work->WKFATOR
         EndIf
      endif
	Else
		WORK->(dbAppend())
		WORK->WKCOD_I		:=	EW5->EW5_COD_I
		WORK->WKFABR		:=	SW5->W5_FABR
		WORK->WKFORN		:=	EW5->EW5_FORN
	   Work->W7_FABLOJ := SW5->W5_FABLOJ
	   Work->W7_FORLOJ := EW5->EW5_FORLOJ
		WORK->WKFLUXO		:=	SW5->W5_FLUXO
		WORK->WKMOEDA		:=	EW4->EW4_MOEDA
		WORK->WKPRECO		:=	EW5->EW5_PRECO
		WORK->WKPGI_NUM	    :=	WORK_SEL->WKPLI
		WORK->WKGI_NUM		:=	WORK_SEL->WKPLI
		WORK->WKSI_NUM		:=	SW5->W5_SI_NUM
		WORK->WKPO_NUM		:=	WORK_SEL->WKPO_NUM
		WORK->WKCC			:=	SW5->W5_CC
		WORK->WKSEQ			:=	SW5->W5_SEQ
		WORK->WKREG			:=	SW5->W5_REG
		WORK->WKPOSICAO	:=	WORK_SEL->WKPOSICAO
		IF !EMPTY(EW5->EW5_PESOL)
			WORK->WKPESO_L	:=	EW5->EW5_PESOL
		ELSE
			WORK->WKPESO_L	:=	IF(!EMPTY(SW5->W5_PESO),SW5->W5_PESO,B1Peso(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN, EICRetLoja("SW5", "W5_FABLOJ"), EICRetLoja("SW5", "W5_FORLOJ")))
		ENDIF

      Work->WKW7PESOBR := IF(EMPTY(EW5->EW5_PESOB),SW5->W5_PESO_BR,EW5->EW5_PESOB)

		WORK->WKSEQ_LI		:=	SW5->W5_SEQ_LI
		WORK->WKRECNO_ID	:=	SW5->(Recno())
		WORK->WKDT_EMB		:=	SW5->W5_DT_EMB
		WORK->WKDT_ENTR	:=	SW5->W5_DT_ENTR
        aWKSW5Ncm           :=  Busca_NCM('SW5',"NCM",,.T.)
		WORK->WKTEC			:=	aWKSW5Ncm[1]//Busca_NCM('SW5',"NCM"   )   // RJB 05/12/2005
		WORK->WKEX_NCM		:=	aWKSW5Ncm[2]//Busca_NCM('SW5',"EX_NCM")   // RJB 05/12/2005
		WORK->WKEX_NBM		:=	aWKSW5Ncm[3]//Busca_NCM('SW5',"EX_NBM")   // RJB 05/12/2005
		WORK->WKNBM			:=	SW5->W5_NBM
		WORK->WKDOCTO_F	:=	SW5->W5_DOCTO_F
		WORK->WK_ALTEROU	:=	.T.
		WORK->WKQTDE		:=	WORK_SEL->WKQTD_SLA
		WORK->WKQTDE_D		:=	WORK_SEL->WKQTD_SLA
		WORK->WKINVOICE	:=	EW5->EW5_INVOIC
		WORK->WKSALDO_Q	:=	SW5->W5_SALDO_Q-WORK->WKQTDE//WORK_SEL->WKQTD_SEL
		WORK->WKSALDO_O	:=	SW5->W5_SALDO_Q
		WORK->WKFLAG		:=	.T.
		WORK->WKFLAGWIN	:=	cMarca
		WORK->WKFLAG2		:=	.F.
		WORK->WKFLAGWIN2	:=	cMarca
	    WORK->WKDISPINV	    := 0//WORK->WKSALDO_O - WORK_SEL->WKQTD_SLA   //TRP - 08/07/2010
		IF SWP->(DBSEEK(xFilial()+WORK->WKPGI_NUM+WORK->WKSEQ_LI))
			WORK->WKREGIST := SWP->WP_REGIST
			WORK->WKREG_VEN:= SWP->WP_VENCTO
		ENDIF
		E_ItFabFor(,,"DI")
		If lOperacaoEsp
           If !Empty(SW5->W5_CODOPE)
              Work->W7_CODOPE := SW5->W5_CODOPE
              Work->W7_DESOPE := Posicione("EJ0",1,xFilial("EJ0") + Work->W7_CODOPE ,"EJ0_DESC")
           Else
              Work->W7_CODOPE := SW3->W3_CODOPE
              Work->W7_DESOPE := Posicione("EJ0",1,xFilial("EJ0") + Work->W7_CODOPE ,"EJ0_DESC")
           EndIf  
        EndIf
		IF lCposNVEPLI  
           Work->WK_NVE := SW5->W5_NVE
        EndIf
        
       If AvFlags("EIC_EAI") .And. Len(aSegUM) > 0
           Work->WKUNI    :=aSegUM[1]
           Work->WKSEGUM  :=aSegUM[2]
           Work->WKFATOR  :=aSegUM[3]
           Work->WKQTSEGUM:=Work->WKQTDE * Work->WKFATOR
       EndIf
	ENDIF

	Work_SW8->(DbAppend())
	AVReplace("WORK","WORK_SW8")
	Work_SW8->WKINVOICE   := EW5->EW5_INVOIC
	Work_SW8->WKFLAGIV    := cMarca
	Work_Sw8->WKQTDE      := WORK_SEL->WKQTD_SLA
	Work_SW8->WKSALDO_AT  := WORK_SW8->WKQTDE
	Work_SW8->WKDISPLOT   := WORK_SW8->WKQTDE
	Work_SW8->WKSALDO     := WORK_SW8->WKQTDE
	Work_SW8->WKPESO_L    := WORK->WKPESO_L

    If lPesoBruto
       Work_SW8->WKW8PESOBR := Work->WKW7PESOBR
    EndIf

	Work_SW8->WKPESOTOT   := Work_SW8->(WKPESO_L*WKQTDE)
	Work_SW8->WKPRTOTMOE  := DI500TRANS(WORK_SW8->WKQTDE*WORK_SW8->WKPRECO)
	Work_SW8->WKUNID      := TransQtde(0,.T.,,WORK->WKCOD_I,WORK->WKFABR,WORK->WKFORN,WORK->WKCC,WORK->WKSI_NUM, Work_SW8->W8_FABLOJ, Work_SW8->W8_FORLOJ)
    If EICLoja()
       WORK_SW8->W8_FORLOJ := Work->W7_FORLOJ
       WORK_SW8->W8_FABLOJ := Work->W7_FABLOJ
    EndIf

    If lOperacaoEsp
       Work_SW8->W8_CODOPE := Work->W7_CODOPE
       Work_SW8->W8_DESOPE := Posicione("EJ0",1,xFilial("EJ0") + Work_SW8->W8_CODOPE ,"EJ0_DESC")
    EndIf
	IF lCposNVEPLI
       Work_SW8->WKNVE := Work->WK_NVE
    EndIf

    If AvFlags("EIC_EAI") .And. Len(aSegUM) > 0
       Work_SW8->WKUNI    :=aSegUM[1]
       Work_SW8->WKSEGUM  :=aSegUM[2]
       Work_SW8->WKQTSEGUM:=Work_SW8->WKQTDE * aSegUM[3]
    EndIf

	IF !Work_SW9->(DbSeek(EW5->EW5_INVOIC))
		Work_SW9->(DBAPPEND())
		Work_SW9->W9_INVOICE := EW4->EW4_INVOIC
		Work_SW9->W9_DT_EMIS := EW4->EW4_DT_EMI
		Work_SW9->W9_FORN    := EW4->EW4_FORN
		If EICLoja()
		   Work_SW9->W9_FORLOJ := EW4->EW4_FORLOJ
		EndIf
		Work_SW9->W9_NOM_FOR := BuscaFabr_Forn(EW4->EW4_FORN)
		Work_SW9->W9_MOE_FOB := EW4->EW4_MOEDA
		Work_SW9->W9_INCOTER := EW4->EW4_INCOTE
		Work_SW9->W9_TX_FOB  := BuscaTaxa(EW4->EW4_MOEDA,dDataBase,.T.,.F.,.T.) // RJB 05/12/2005
		Work_SW9->W9_COND_PA := EW4->EW4_COND_P
		Work_SW9->W9_DIAS_PA := EW4->EW4_DIAS_P
		Work_SW9->W9_RAT_POR := EW4->EW4_RATPOR
		Work_SW9->W9_FREINC  := EW4->EW4_FREINC
		Work_SW9->W9_FRETEIN := EW4->EW4_FRETEI
		Work_SW9->W9_INLAND  := EW4->EW4_INLAND
		Work_SW9->W9_PACKING := EW4->EW4_PACKIN
		Work_SW9->W9_DESCONT := EW4->EW4_DESCON
        //RMD - 19/06/17 - Carrega o seguro da Invoice Antecipada
        If lSegInc
            Work_SW9->W9_SEGURO := EW4->EW4_SEGURO
            Work_SW9->W9_SEGINC := EW4->EW4_SEGINC
        EndIf
		Work_SW9->W9_TUDO_OK := "1"
		IF LCAMBIO_EIC
   		If	!lEICFI06	.AND.	lEICFI07
			   Work_SW9->W9_TITERP:= EW4->EW4_TITERP
		   EndIf
		ENDIF
	EndIf
	Work_SW8->WKCOND_PA :=Work_SW9->W9_COND_PA
	Work_SW8->WKDIAS_PA :=Work_SW9->W9_DIAS_PA
   Work_SW8->WKTCOB_PA :=Posicione("SY6",1,xFilial("SY6")+Work_SW9->W9_COND_PA+STR(Work_SW9->W9_DIAS_PA,3),"Y6_TIPOCOB")
	Work_SW8->WKMOEDA   :=Work_SW9->W9_MOE_FOB
	Work_SW8->WKINCOTER :=Work_SW9->W9_INCOTER
   
   oJsonInvAnt[Work_SW9->W9_INVOICE] := Work_SW9->(Recno())

   //NCF - 08/08/2011 - Classificação N.V.A.E na PLI      
   ClassifNVE(lCposNVEPLI,2,@lPrimeiro,@lMostMsgNVE,@lTemNVEPLI,@lTemNVECad)

	If(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GRV_WORK_INVOICE"),)  // GFP - 28/03/2014

	WORK->(DBSETORDER(NORDWORK))

End Sequence
RestOrd(aOrd,.T.)
Return(.T.)

/*------------------------------------------------------------------------------------
Funcao      : CalcAcres
Parametros  : lCheckDesp  - variável lógica que indica se realiza o cálculo automático para os acréscimos ou solicita confirmação do usuário
                      .T. - realiza dedução sem solicitar a confirmação do usuário
                      .F. - solicita a confirmção do usuário
              nValTotDesp - Valor das despesas base de imposto para rateio entre as adicoes
              cCod - Codigo do acrescimo informado na despesa
              cDescr - Descricao do acrescimo informada na despesa
              lRatPeso - Define se o Rateio vai ser por Peso
Retorno     : Valor lógico se o usuário optou pela cálculo automático dos acréscimos
Objetivos   : Cálculo/Rateio dos acréscimos para despesas base de imposto quando DI Eletronica
Autor       : Thiago Rinaldi Pinto
Data/Hora   : 07/04/10
*------------------------------------------------------------------------------------*/
*---------------------------------------------------------------------*
Static Function CalcAcres(lCheckDesp,nValTotDesp,cCod,cDescr,lRatPeso)
*---------------------------------------------------------------------*   
   Local aOrd           // armazenar o indice e o registro das tabelas "Work_EIJ" e "Work_EIN"
   Local nValTotAdic := 0    //armazenar valor total de todas adicoes
   Local nPesTotAdic := 0
   Default lCheckDesp := .F.
   Default lRatPeso   := .F.                 
   If nValTotDesp > 0  //Verifica se existe despesas base de imposto
      aOrd := SaveOrd({"Work_EIJ","Work_EIN"})
      WORK_EIJ->(dbGoTop())
      While !Work_EIJ->(EOF())                           
         nValTotAdic += Work_EIJ->EIJ_VLMLE 
         nPesTotAdic += Work_EIJ->EIJ_PESOL 
         Work_EIJ->(dbSkip())
      EndDo
      If nValTotAdic > 0
         If lCheckDesp .Or. MsgYesNo(STR0776) //STR0776 "Deseja realizar o cálculo automático dos acréscimos para despesas base de imposto?"
            lCheckDesp := .T.
            Work_EIJ->(dbGoTop())
            While !Work_EIJ->(EOF())
               If !Work_EIN->(dbSeek(Work_EIJ->EIJ_ADICAO+"1"+Avkey(cCod,"EIN_CODIGO")))
                  Work_EIN->(dbAppend())
                  Work_EIN->EIN_TIPO   := "1"
                  Work_EIN->EIN_CODIGO := cCod
                  Work_EIN->EIN_DESC   := cDescr
                  Work_EIN->EIN_FOBMOE := EasyGParam("MV_SIMB1",,"R$")
                  Work_EIN->EIN_VLMLE  := nValTotDesp * If(lRatPeso, (Work_EIJ->EIJ_PESOL/nPesTotAdic) , (Work_EIJ->EIJ_VLMLE/nValTotAdic) )  //Rateio = (valor da adicao / valor total das adicoes) * valor da despesa  //NCF - 22/12/2016 - Adicionado rateio por peso (config. da despesa)
                  Work_EIN->EIN_VLMMN  := Work_EIN->EIN_VLMLE //* SW9->W9_TX_FOB
                  Work_EIN->EIN_ADICAO := Work_EIJ->EIJ_ADICAO
                  IF !Check_adic(Work_EIN->EIN_ADICAO) // 03/08/12 - BCO - Validação para o Campo EIN_ADICAO não ser gravado vazio
                     Return .F.
                  ENDIF
               Else
                  Work_EIN->EIN_VLMLE  := nValTotDesp * If(lRatPeso, (Work_EIJ->EIJ_PESOL/nPesTotAdic) , (Work_EIJ->EIJ_VLMLE/nValTotAdic) )  //Rateio = (valor da adicao / valor total das adicoes) * valor da despesa  //NCF - 22/12/2016 - Adicionado rateio por peso (config. da despesa)
                  Work_EIN->EIN_VLMMN  := Work_EIN->EIN_VLMLE //* SW9->W9_TX_FOB
               Endif
               Work_EIJ->(dbSkip())
            EndDo
         EndIf
      EndIf
      RestOrd(aOrd,.T.)
   EndIf

Return lCheckDesp

//TRP - 07/04/2010 - Valida Campo Codigo/Descricao de Acrescimo nas Despesas.
*-----------------------------------*
Function Valid_Desp(cCampo)
*-----------------------------------*
DO CASE

   CASE cCampo == 'WD_CODACR'
      lRet := .T.
      lRet := Vazio() .OR. ExistCpo("SJN",M->WD_CODACR)
      SJN->(DBSEEK(xFilial()+M->WD_CODACR))
      M->WD_DESCACR:=SJN->JN_DESC

   CASE cCampo == 'WD_DESCACR'
      SJN->(DBSEEK(xFilial()+M->WD_CODACR))
      RETURN SJN->JN_DESC

ENDCASE

RETURN lRet

/*
Funcao     : VerCobertDB()
Parametros : Nenhum
Retorno    : lRet
Objetivos  : Verificar se a Cobertura Cambial da cond pagto esta em comum com o Ato Concessório
Autor      : Allan Oliveira Monteiro
Data/Hora  : 30/07/2010
*/
Function VerCobertDB()
Local lRet := .T.
Local cCobCamb, cMsg := ""

Begin Sequence
  If lIntDraw .And. !Empty(WORK_SW8->WKAC)
     /*** Verificando a Cobertura Cambial da cond pagto ***/
     SY6->(dbSeek(xFilial("SY6")+M->W9_COND_PA+str(M->W9_DIAS_PA,3,0)))
     cCobCamb := If(SY6->Y6_TIPOCOB<>"4","1","2")

     /*** Verifica se a Cobertura da Cond pagto é igual a do itens do Ato Concessório ***/
     ED4->(DbSetOrder(2))
     ED4->(DbSeek(xFilial("ED4")+Work_SW8->WKAC+Work_SW8->WKSEQSIS))
     If AllTrim(ED4->ED4_CAMB) <> AllTrim(cCobCamb)
        If ED4->ED4_CAMB == "1"
           cMsg := STR0781+Alltrim(ED4->ED4_ITEM)+STR0782 //STR0781 "O item" //STR0782 " não pode ser apropriado, pois no Ato Concessório o mesmo possui Cobertura Cambial e a condição de pagamento"
           cMsg += STR0783 //STR0783 " ultilizada está Sem cobertura Cambial. Para que o item possa ser apropriado as condições devem estar em comum."
        ElseIf ED4->ED4_CAMB == "2"
           cMsg += STR0781 + Alltrim(ED4->ED4_ITEM)+STR0784 //STR0781 "O item" //STR0784 " não pode ser apropriado, pois no ato concessório o mesmo está Sem Cobertura Cambial e a condição de pagamento"
           cMsg += STR0785 //STR0785 " ultilizada está Com Cobertura Cambial. Para que o item possa ser apropriado as condições devem estar em comum."
        EndIf

        If !Empty(cMsg)
           MsgInfo(cMsg, STR0558)//STR0558 "Aviso"
        EndIf
        lRet := .F.
     EndIf
  EndIf
End Sequence

Return lRet

/*
Funcao     : VerCobInv()
Parametros : Nenhum
Retorno    : lRet
Objetivos  : Valida se os itens da Invoice estão com a cobertura Cambial em comum ao Ato concessório
Autor      : Allan Oliveira Monteiro
Data/Hora  : 30/07/2010
*/
Function VerCobInv()
Local lRet := .T., lValid := .T., lMsg

Work_SW8->(DbGoTop())

/*** Verifica se a condição de pagto esta de acordo com as dos itens marcados" ***/
While Work_SW8->(!EOF())
  If !Empty(Work_SW8->WKFLAGIV)
     If !VerCobertDB()
        lValid:= .F.
     EndIf
  EndIf
  Work_SW8->(DbSkip())
EndDo

If !lValid
   lMsg := MsgYesNo(STR0786,STR0558) //STR0786 "Deseja desmarcar o(s) item(ns) que possue(m) divergencia(s) de cobertura cambial entre o Ato Concessório e Condição de Pagamento selecionada ?" //STR0558 "Aviso"
   If lMsg
      Work_SW8->(DbGoTop())
      While Work_SW8->(!EOF())
         If !Empty(Work_SW8->WKFLAGIV)
            DI500InvMarca('D') //Desmarca
         EndIf
      Work_SW8->(DbSkip())
      EndDo
   EndIf
   Work_SW8->(DbGoTop())
   lRet := .F.
EndIf

Return lRet

/*
Funcao     : DI500BlqCur()
Parametros : Nenhum
Retorno    : lHabCurrier
Objetivos  : Bloqueia o campo W6_CURRIER na Alteração
Autor      : Diogo Felipe dos Santos
Data/Hora  : 14/01/11 - 09:33
*/
*-------------------------------*
User Function DI500BlqCur()
*-------------------------------*

Private lHabCurrier := .T.

If nVlrOpc == 4
   lHabCurrier := .F.
Endif

Return lHabCurrier

Static Function DI500Qry(cCampo,cImpco)
Local cQuery
   Work->(DbGotop()) //Feito isso para dar tipo de um refresh na tabela temporária e atualizar o campo wkflag para .T.
   cQuery := "SELECT SW2.W2_IMPCO FROM " + RetSQLName("SW2") +" SW2 INNER JOIN " + TeTempName("WORK") + " WORK ON SW2.W2_PO_NUM = WORK.WKPO_NUM "
   cQuery+= "WHERE SW2.W2_FILIAL = '" + xFilial("SW2") + "' AND SW2.W2_PO_NUM = WORK.WKPO_NUM "
   cQuery+= "AND SW2.W2_" + cCampo + " <> '" +  cImpCo + "' AND WORK.WKFlag = 'T'  AND SW2.D_E_L_E_T_ <> '*' "
return (EasyQryCount(cQuery) > 0)

//MFR 14/10/2020 OSSME-5138
*------------------------------*
//Função para validar se tem agum item marcado de um pedido que tenha o campo conta e ordem ou encomeda diferente do processo base ou do valor da tela
//Esta função é somente disparada pelo valid quando o campo é alterado via tela
Static Function DI500ValCE(cCampo)
*------------------------------*
Local cImpCo:='0', lRetorno:=.T.
cImpCo := &("M->W6_"+cCampo)
if cImpCo <> '0'
   lRetorno := DI500Qry(cCampo,cImpco)
Else
   lRetorno := .F.
EndIf
Return lRetorno

//MFR 14/10/2020 OSSME-5138
*------------------------------*
//Função para validar se tem agum item marcado de um pedido que tenha o campo conta e ordem ou encomeda diferente do processo base ou do valor da tela
//cCampo = indica o campo a ser pesquisado na query
//lSolPo = indica se deve comprara o campo conta e ordem e encomenda da sw2 com o campo da capa 
//lRetorno = se .t. indica que tem informacoes diferentes entre o que já existe o que está quererndo alterar
//lAltCmp = indica se o campo encomenda ou conta e ordem foi alterado
//l2SelPo   = se .t. idnica que veio da tela interna de seleção do PO depois do botão Itens
Static Function DI500ValCO(cCampo,lSelPO,lAltCmp,l2SelPo)
*------------------------------*
Local cImpCo:='0', lRetorno, nRecno
Default lAltCmp := .F.
Default l2SelPo :=.F.

if lSelPO //.or. (cCampo == "IMPENC" .And. M->W6_IMPENC != SW2->W2_IMPENC) //p3
   nRecno:=SW2->(RECNO())
   cImpCo := Posicione("SW2",1,xFILIAL("SW2")+M->W6_PO_NUM,"W2_"+cCampo)
   if cCampo != "IMPENC" .or. (if(l2SelPO,M->W6_IMPENC == SW2->W2_IMPENC,M->W6_IMPENC != SW2->W2_IMPENC)) // Aqui verifica se foi o campo encoemnda foi alterado pelo gatilho do processo base ou alerado manualmen 
      SW2->(DBGOTO(nRecno))
   EndIf
Else
   cImpCo := &("M->W6_"+cCampo)
EndIf
if cImpCo <> '0'
   lRetorno := DI500Qry(cCampo,cImpco)
Else
   lRetorno := .F.
EndIf
If lAltCmp .and. !lRetorno
   lRetorno := &("SW2->W2_"+cCampo) != &("M->W6_"+cCampo)
EndIf
Return lRetorno

*------------------------------*
//lAtualiza = se .t. atualiza e valida 
//            se .f. só valida
//lSelPo    = se .t. indica que veio da seleção do P.O. -Deve comparar com o campo conta e ordem ou encomenda da capa com o processo, além dos itens
//l2SelPo   = se .t. idnica que veio da tela interna de seleção do PO depois do botão Itens
Static Function VALID_PEDIDO(lAtualiza,lSelPo,lAltCmp,l2SelPo)
*------------------------------*
//MFR 14/10/2020 OSSME-5138
//M->W6_IMPCO := IF(SW6->W6_HAWB == M->W6_HAWB, M->W6_IMPCO, "")  // GFP - 14/11/2013 - Caso seja inclusão, o W6_IMPCO sempre deverá ser apagado na alteração do Pedido de Referencia.
if lAtualiza
   M->W6_IMPCO := ""
   M->W6_IMPENC := ""
EndIf
IF SW2->(FIELDPOS("W2_IMPCO")) # 0 .And. SW6->(FIELDPOS("W6_IMPCO")) # 0
   IF EMPTY(M->W6_IMPCO)
      IF SW2->W2_IMPCO='1'
         M->W6_IMPCO := '1'
      ELSE
         M->W6_IMPCO := '2'
      ENDIF
   ELSEIF EasyGParam("MV_EIC_PCO",,.F.) //W6 preenchido 1 ou 2
      IF M->W6_IMPCO == '1' //trata conta e ordem
         IF SW2->W2_IMPCO <> '1' .and. DI500ValCO("IMPCO",lSelPo,lAltCmp,l2SelPo)
            Alert(STR0811) //STR0811 'Pedido tem que ser de importacão por conta e ordem' alterado para
            RETURN .F.     //        'Existem itens marcados que não são da modalidade [conta e ordem] que precisam ser desmarcados antes de prosseguir com esta alteração'
         ENDIF
      ELSE //W6=2
         IF SW2->W2_IMPCO == '1' .and.  DI500ValCO("IMPCO",lSelPO,lAltCmp,l2SelPo)
            Alert(STR0812) //STR0812 'Pedido nao pode ser de importacao por conta e ordem' alterado para
            RETURN .F.     //        'Existem itens marcados que são da modalidade [conta e ordem] que precisam ser desmarcados antes de prosseguir com esta alteração'
         ENDIF
      ENDIF
   ENDIF
ENDIF

IF SW2->(FIELDPOS("W2_IMPENC")) # 0 .And. SW6->(FIELDPOS("W6_IMPENC")) # 0
   IF EMPTY(M->W6_IMPENC)
      IF SW2->W2_IMPENC='1'
         M->W6_IMPENC := '1'
      ELSE
         M->W6_IMPENC := '2'
      ENDIF

   ELSEIF EasyGParam("MV_EIC_PCO",,.F.) //W6 preenchido 1 ou 2
      IF M->W6_IMPENC == '1'
         IF SW2->W2_IMPENC <> '1' .and. DI500ValCo("IMPENC",lSelPo,lAltCmp,l2SelPo)
            Alert(STR0813) //STR0813 'Pedido tem que ser de encomenda' alterado para
                           //        'Existem itens marcados na modalidade [encomenda] que precisam ser desmarcados antes de prosseguir com esta alteração'
            RETURN .F.
         ENDIF
      ELSE //W6=2
         IF SW2->W2_IMPENC == '1' .And. DI500ValCo("IMPENC",lSelPo,lAltCmp,l2SelPo)
            Alert(STR0814)//STR0814 'Pedido nao pode ser de encomenda' alteado para
            RETURN .F.    //        'Existem itens marcados que não são da modalidade [encomenda] que precisam ser desmarcados antes de prosseguir com esta alteração'
         ENDIF
      ENDIF
   ENDIF
ENDIF

RETURN .T.


/*
Função    : VldOpeDesemb()
Objetivos : Executa regra de Operação Especial de acordo com o parametro passado
Parametros: cParam - Indica o trecho onde é feito o tratamento de Operação especial
Retorno   : .T. - Caso tenha ocorrido a operação com sucesso
            .F. - Caso não tenha a operação com sucesso
Autor     : Allan Oliveira Monteiro
Revisão   :
Data      : 10/04/2011
*/
*-----------------------------------*
Static Function VldOpeDesemb(cParam)
*-----------------------------------*
Local lRet := .T. , lSeekSW8 := .F. , lSeekSW9 := .F.
Local  aOrd := SaveOrd({"SW7","SW8","SW9","Work_SW8"})
Local  aCampos
Local  cProcesso,cPoNum, cPosicao, cPgiNum

Begin Sequence

   //Verifica se o campo da operação existe
   If !lOperacaoEsp
       Break
   EndIf

   DO CASE

      CASE cParam == "BTN_PRINC_EMB" //Operação acionada na gravação do Desembaraço

         Begin Sequence

            //Inicializa controle de transição no caso de algum estorno incorreto retornar o valor das works
            oOperacao:InitTrans()

            //Verifica se a gravação do Desembaraço é feita pela capa ou pelos itens(INC)
            If Work->(EasyRecCount("Work")) == 0 .And. Work_SW8->(EasyRecCount("Work_SW8")) == 0 .And. Work_SW9->(EasyRecCount("Work_SW9")) == 0

               cProcesso := M->W6_HAWB

               //Verifica se a Capa do Desembaraço houve alteração
               If !OPVERALTDI500(.T.)
                  Break
               EndIf

               //Verifica se a area esta ativa
               If Select("QUERY") > 0
                  QUERY->(DbCloseArea())
               EndIf

               //Query para trazer todas invoices do processo com operacao preenchida
               BeginSql Alias "QUERY"

                  SELECT SW8.R_E_C_N_O_ AS RECSW8, SW9.R_E_C_N_O_ AS RECSW9, SW7.R_E_C_N_O_ AS RECSW7
                  FROM %table:SW8% SW8 INNER JOIN %table:SW9% SW9 ON SW8.W8_HAWB = SW9.W9_HAWB AND SW8.W8_INVOICE = SW9.W9_INVOICE AND SW8.W8_FORN = SW9.W9_FORN AND SW8.W8_FORLOJ = SW9.W9_FORLOJ
                  INNER JOIN %table:SW7% SW7 ON SW8.W8_HAWB = SW7.W7_HAWB AND SW8.W8_PO_NUM = SW7.W7_PO_NUM AND SW8.W8_POSICAO = SW7.W7_POSICAO AND SW8.W8_PGI_NUM = SW7.W7_PGI_NUM
                  WHERE SW8.%NotDel% AND SW9.%NotDel% AND SW7.%NotDel% AND SW8.W8_FILIAL = %xFilial:SW8% AND SW9.W9_FILIAL = %xFilial:SW9% AND SW7.W7_FILIAL = %xFilial:SW7%  AND
                  SW8.W8_CODOPE <> ' ' AND SW8.W8_HAWB = %Exp:cProcesso%

               EndSql

               //Estorna todas as operações achadas anteriormente
               Do While QUERY->(!EOF())

                  SW7->(DbGoTo(QUERY->RECSW7))
                  SW8->(DbGoTo(QUERY->RECSW8))
                  SW9->(DbGoTo(QUERY->RECSW9))

                  aCampos := {{"SW8","SW8"},{"SW7","SW7"},{"SW6","SW6"}, {"SW9","SW9"}}
                  If !(oOperacao:InitOperacao(SW8->W8_CODOPE, "SW8", aCampos, .F.,.T.,"BTN_PRINC_EMB"))//Estorno
                     lRet := .F.
                     Break
                  EndIf

                  aCampos := {{"SW8","SW8"},{"SW7","SW7"},{"SW6","M"}, {"SW9","SW9"}}
                  If !(oOperacao:InitOperacao(SW8->W8_CODOPE, "SW8", aCampos, .T.,.T.,"BTN_PRINC_EMB"))//Inclusão
                     lRet := .F.
                     Break
                  EndIf


               QUERY->(DBSkip())
               EndDo

            Else

               Work_SW8->(DbGoTop())
               Work_SW9->(DbGoTop())
               Work->(DbGoTop())
               Work->(DbSetOrder(3))    //WKPO_NUM+WKPGI_NUM+WKPOSICAO
               Work_SW8->(DbSetOrder(1))//WKINVOICE+WKFORN+W8_FORLOJ+WKPO_NUM+WKPOSICAO+WKPGI_NUM
               Work_SW9->(DbSetOrder(1))//W9_INVOICE+W9_FORN+W9_FORLOJ+W9_HAWB
               SW8->(DbSetOrder(6))     //W8_FILIAL+W8_HAWB+W8_INVOICE+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM
               SW7->(DbSetOrder(4))     //W7_FILIAL+W7_HAWB+W7_PO_NUM+W7_POSICAO+W7_PGI_NUM
               SW9->(DbSetOrder(1))     //W9_INVOICE+W9_FORN+W9_FORLOJ+W9_HAWB
               SW6->(DbSetOrder(1))     //W6_FILIAL+W6_HAWB

               //Executa todas as invoices a serem gravadas no processo
               Do While Work_SW9->(!EOF())

                  Work_SW8->(DbSeek(Work_SW9->W9_INVOICE + Work_SW8->WKFORN + Work_SW8->W8_FORLOJ))
                  Do While Work_SW8->(!EOF()) .And. Work_SW8->WKINVOICE == Work_SW9->W9_INVOICE .And. Work_SW8->WKFORN == Work_SW9->W9_FORN ;
                                              .And. Work_SW8->W8_FORLOJ == Work_SW9->W9_FORLOJ


                     If Work->(DbSeek(Work_SW8->WKPO_NUM + Work_SW8->WKPGI_NUM + Work_SW8->WKPOSICAO))

                        //Verifica se os dados da base foram realmente alterados
                        If nOPC_mBrw == 4 .And. !OPVERALTDI500(.F.)
                           Work_SW8->(DbSkip())
                           Loop
                        EndIf


                        aCampos := {{"SW8","SW8"},{"SW7","SW7"},{"SW6","SW6"}, {"SW9","SW9"}}
                        lSeekSW8 := SW8->(DbSeek(xFilial("SW8") + M->W6_HAWB + Work_SW8->WKINVOICE + Work_SW8->WKPO_NUM + Work_SW8->WKPOSICAO + Work_SW8->WKPGI_NUM))
                        lSeekSW9 := SW9->(DbSeek(xFilial("SW9") + Work_SW9->W9_INVOICE + Work_SW9->W9_FORN + Work_SW9->W9_FORLOJ + M->W6_HAWB))
                        If nOPC_mBrw == 4  .And. lSeekSW8 .And. lSeekSW9 .And. !Empty(SW8->W8_CODOPE)
                           If !oOperacao:InitOperacao(SW8->W8_CODOPE, "SW8", aCampos, .F.,.T.,"BTN_PRINC_EMB")//Estorno
                              lRet := .F.
                              Break
                           EndIf
                        EndIf


                        aCampos := {{"SW8","Work_SW8"},{"SW7","Work"},{"SW6","M"}, {"SW9","Work_SW9"}}
                        If !Empty(Work_SW8->WKFLAGIV) .And. !Empty(Work_SW8->W8_CODOPE)
                           If !oOperacao:InitOperacao(Work_SW8->W8_CODOPE, "SW8", aCampos, .T.,.T.,"BTN_PRINC_EMB")//Inclusão
                              lRet := .F.
                              Break
                           EndIf
                        EndIf

                     EndIf

                  Work_SW8->(DbSkip())
                  EndDo
               Work_SW9->(DbSkip())
               EndDo
            EndIf

         End Sequence

         oOperacao:EndTrans(lRet)

      CASE cParam == "BTN_MK_IT_INV" //Operação acionada no botao OK do item da invoice

         aCampos := {{"SW8","M"},{"SW7","Work"},{"SW6","M"}, {"SW9","M"}}
         If !EMPTY(cCodOpe)
            lRet := oOperacao:InitOperacao(cCodOpe, "SW8", aCampos, .T.,.T.,cParam)//Inclusão
         EndIf

      CASE cParam == "MARC_IT_EST" //Operação acionada na marcação dos itens no estorno do desembaraço

         IF TRB->WK_OK == cMarca
            cNewMarca:=SPACE(02)
         ELSE
            cNewMarca:=cMarca
         ENDIF


         If Select("QRY") > 0
            QRY->(DbCloseArea())
         EndIf

         cProcesso := M->W6_HAWB
         cPoNum    := TRB->W7_PO_NUM
         cPosicao  := TRB->W7_POSICAO
         cPgiNum   := TRB->W7_PGI_NUM

         BeginSql Alias "QRY"

            SELECT SW8.R_E_C_N_O_ AS RECSW8, SW9.R_E_C_N_O_ AS RECSW9, SW7.R_E_C_N_O_ AS RECSW7
            FROM %table:SW8% SW8 INNER JOIN %table:SW9% SW9 ON SW8.W8_HAWB = SW9.W9_HAWB AND SW8.W8_INVOICE = SW9.W9_INVOICE AND SW8.W8_FORN = SW9.W9_FORN AND SW8.W8_FORLOJ = SW9.W9_FORLOJ
            INNER JOIN %table:SW7% SW7 ON SW8.W8_HAWB = SW7.W7_HAWB AND SW8.W8_PO_NUM = SW7.W7_PO_NUM AND SW8.W8_POSICAO = SW7.W7_POSICAO AND SW8.W8_PGI_NUM = SW7.W7_PGI_NUM
            WHERE SW8.%NotDel% AND SW9.%NotDel% AND SW7.%NotDel% AND SW8.W8_FILIAL = %xFilial:SW8% AND SW9.W9_FILIAL = %xFilial:SW9% AND SW7.W7_FILIAL = %xFilial:SW7%  AND
            SW8.W8_CODOPE <> ' ' AND SW8.W8_HAWB = %Exp:cProcesso% AND SW8.W8_PO_NUM = %Exp:cPoNum%  AND SW8.W8_POSICAO = %Exp:cPosicao%  AND  SW8.W8_PGI_NUM = %Exp:cPgiNum%

         EndSql

         Do While QRY->(!EOF())

            SW7->(DbGoTo(QRY->RECSW7))
            SW8->(DbGoTo(QRY->RECSW8))
            SW9->(DbGoTo(QRY->RECSW9))

            aCampos := {{"SW8","SW8"},{"SW7","SW7"},{"SW6","SW6"}, {"SW9","SW9"}}
            If !Empty(cNewMarca)
               If !oOperacao:InitOperacao(SW8->W8_CODOPE, "SW8", aCampos, .F.,.T.,cParam)//Estorno
                  lRet := .F.
               EndIf
            Else
               If !oOperacao:InitOperacao(SW8->W8_CODOPE, "SW8", aCampos, .T.,.T.,cParam)//Inclusao
                  lRet := .F.
               EndIf
            EndIf

         QRY->(DbSkip())
         EndDo

         TRB->WK_OK :=cNewMarca

      CASE cParam == "MK_IT_INV" //Operação acionada na marcação do item da invoice

         aCampos := {{"SW8","M"},{"SW7","Work"},{"SW6","M"}, {"SW9","M"}}

         //Marca
         If EMPTY(Work_SW8->WKFLAGIV).And. !EMPTY(Work_SW8->W8_CODOPE)
            oOperacao:InitOperacao(Work_SW8->W8_CODOPE   , "SW8", aCampos, .T.,.T.,cParam)//Inclusão
         EndIf

         //Desmarca
         If !EMPTY(Work_SW8->WKFLAGIV) .And. !EMPTY(Work_SW8->W8_CODOPE)
            If oOperacao:InitOperacao(Work_SW8->W8_CODOPE   , "SW8", aCampos, .F.,.T.,cParam)//Estorno
               Work_SW8->W8_CODOPE := Work->W7_CODOPE
               Work_SW8->W8_DESOPE := Posicione("EJ0",1,xFilial("EJ0") + Work_SW8->W8_CODOPE ,"EJ0_DESC")
            EndIf
         EndIf

      CASE cParam  == "MARC_TDS_EST"

         If Select("QRY") > 0
            QRY->(DbCloseArea())
         EndIf

         cProcesso := M->W6_HAWB
         cPoNum    := TRB->W7_PO_NUM
         cPosicao  := TRB->W7_POSICAO
         cPgiNum   := TRB->W7_PGI_NUM

         BeginSql Alias "QRY"

            SELECT SW8.R_E_C_N_O_ AS RECSW8, SW9.R_E_C_N_O_ AS RECSW9, SW7.R_E_C_N_O_ AS RECSW7
            FROM %table:SW8% SW8 INNER JOIN %table:SW9% SW9 ON SW8.W8_HAWB = SW9.W9_HAWB AND SW8.W8_INVOICE = SW9.W9_INVOICE AND SW8.W8_FORN = SW9.W9_FORN AND SW8.W8_FORLOJ = SW9.W9_FORLOJ
            INNER JOIN %table:SW7% SW7 ON SW8.W8_HAWB = SW7.W7_HAWB AND SW8.W8_PO_NUM = SW7.W7_PO_NUM AND SW8.W8_POSICAO = SW7.W7_POSICAO AND SW8.W8_PGI_NUM = SW7.W7_PGI_NUM
            WHERE SW8.%NotDel% AND SW9.%NotDel% AND SW7.%NotDel% AND SW8.W8_FILIAL = %xFilial:SW8% AND SW9.W9_FILIAL = %xFilial:SW9% AND SW7.W7_FILIAL = %xFilial:SW7%  AND
            SW8.W8_CODOPE <> ' ' AND SW8.W8_HAWB = %Exp:cProcesso% AND SW8.W8_PO_NUM = %Exp:cPoNum%  AND SW8.W8_POSICAO = %Exp:cPosicao%  AND  SW8.W8_PGI_NUM = %Exp:cPgiNum%

         EndSql

         Do While QRY->(!EOF())

            SW7->(DbGoTo(QRY->RECSW7))
            SW8->(DbGoTo(QRY->RECSW8))
            SW9->(DbGoTo(QRY->RECSW9))

            aCampos := {{"SW8","SW8"},{"SW7","SW7"},{"SW6","SW6"}, {"SW9","SW9"}}
            If !Empty(cNewMarca)
               If !oOperacao:InitOperacao(SW8->W8_CODOPE, "SW8", aCampos, .F.,.T.,cParam)//Estorno
                  lRet := .F.
                  Break
               EndIf
            Else
               If !oOperacao:InitOperacao(SW8->W8_CODOPE, "SW8", aCampos, .T.,.T.,cParam)//Inclusao
                  lRet := .F.
                  Break
               EndIf
            EndIf

         QRY->(DbSkip())
         EndDo

      CASE cParam == "DESMARCA_IT_INV"

         aCampos := {{"SW8","Work_SW8"},{"SW7","Work"},{"SW6","M"}, {"SW9","M"}} //AOM - 06/04/2011

         If !EMPTY(Work_SW8->W8_CODOPE)
             If oOperacao:InitOperacao(Work_SW8->W8_CODOPE, "SW8", aCampos, .F.,.T.,cParam)//Estorno
                cCodOpe             := Work->W7_CODOPE
                Work_SW8->W8_CODOPE := Work->W7_CODOPE
                Work_SW8->W8_DESOPE := Posicione("EJ0",1,xFilial("EJ0") + Work_SW8->W8_CODOPE ,"EJ0_DESC")
             Else
                lRet := .T.
                Break
             EndIf
         EndIf

      CASE cParam == "MARC_EST_IV"

         //Inicializa controle de transição no caso de algum estorno incorreto retornar o valor das works
         oOperacao:InitTrans()
         //LRS - 10/08/2015 - Correção do loop
         Work_SW8->(DBSETORDER(1))
         IF Work_SW8->(DBSEEK(WORK_SW9->W9_INVOICE+WORK_SW9->W9_FORN+WORK_SW9->W9_FORLOJ))//FDR - 23/02/12
             DO WHILE Work_SW8->(!EOF()) .AND. Work_SW8->WKINVOICE==Work_SW9->W9_INVOICE .AND.;
                     Work_SW8->WKFORN   ==Work_SW9->W9_FORN    .And.;
                     (!EICLoja() .Or. Work_SW8->W8_FORLOJ == Work_SW9->W9_FORLOJ)

	            aCampos := {{"SW8","Work_SW8"},{"SW7","Work"},{"SW6","SW6"}, {"SW9","Work_SW9"}}
	            If !Empty(WORK_SW8->W8_CODOPE) .AND. !oOperacao:InitOperacao(WORK_SW8->W8_CODOPE, "SW8", aCampos, .F.,.T.,cParam)//Estorno //FDR - 23/02/12 - Verifica se tem Operação Especial
	               lRet:= .F.
	               oOperacao:EndTrans(lRet)
	               Break
	            EndIf

	            Work_SW8->(DbSkip())
	         EndDo
         EndIF

   ENDCASE

End Sequence

RestOrd(aOrd)

Return lRet

/*
Função    : OPVERALTDI500()
Objetivos : Verica se a capa ou os itens do processo foram alterados
Parametros: lCapa - Verifica se é apenas a capa do processo a ser verificada
Retorno   : lRet := .F. - Não houve alteração
            lRet := .T. - Houve alteração
Autor     : Allan Oliveira Monteiro
Revisão   :
Data      : 19/04/2011
*/
/************************************/
Static Function OPVERALTDI500(lCapa)
/************************************/
Local lRet := .F.
Local i, nLin, nCol

Default lCapa := .T.


Begin Sequence

   SW6->(DbSetOrder(1)) //LRS - 23/09/2016 - Nesse momento o Set Order da SW6 esta posicionado na ordem errada
   If SW6->(DbSeek(xFilial("SW6") + M->W6_HAWB))
      For i:= 1 to SW6->(FCount())
         If SW6->&(FieldName(i)) <> M->&(SW6->(FieldName(i)))
            lRet := .T.
            Break
         EndIf
      Next i
   Else
     lRet := .T.
   EndIf

   If lCapa
      Break
   EndIf

   If SW7->(DbSeek(xFilial("SW7") + M->W6_HAWB +  Work->WKPO_NUM + Work->WKPOSICAO+ Work->WKPGI_NUM))
      For i:= 1 to SW7->(FCount())
         If (nCol:= aScan(aCorrespWork,{|x| AllTrim(x[1]) == "SW7" })) > 0
            If (nPos:= aScan(aCorrespWork[nCol][3],{|x| AllTrim(x[1])== AllTrim(SW7->(FieldName(i)))})) > 0
               If SW7->&(FieldName(i)) <> Work->&(aCorrespWork[nCol][3][nPos][2])
                  lRet := .T.
                  Break
               EndIf
            Else
               If Work->(FieldPos(SW7->(FieldName(i)))) # 0 .And. SW7->&(FieldName(i)) <> Work->&(SW7->(FieldName(i)))
                  lRet := .T.
                  Break
               EndIf
            EndIf
         EndIf
      Next i
   Else
      lRet := .T.
   EndIf

   If SW8->(DbSeek(xFilial("SW8") + M->W6_HAWB + Work_SW8->WKINVOICE + Work_SW8->WKPO_NUM + Work_SW8->WKPOSICAO + Work_SW8->WKPGI_NUM))
      For i:= 1 to SW8->(FCount())
         If (nCol:= aScan(aCorrespWork,{|x| AllTrim(x[1]) == "SW8" })) > 0
            If (nPos:= aScan(aCorrespWork[nCol][3],{|x| AllTrim(x[1])== AllTrim(SW8->(FieldName(i)))})) > 0
               If SW8->&(FieldName(i)) <> Work_SW8->&(aCorrespWork[nCol][3][nPos][2])
                  lRet := .T.
                  Break
               EndIf
            Else
               If Work_SW8->(FieldPos(SW8->(FieldName(i)))) # 0 .And. SW8->&(FieldName(i)) <> Work_SW8->&(SW8->(FieldName(i)))
                  lRet := .T.
                  Break
               EndIf
            EndIf
         EndIf
      Next i
   Else
      lRet := .T.
   EndIf

   If SW9->(DbSeek(xFilial("SW9") + Work_SW9->W9_INVOICE + Work_SW9->W9_FORN + Work_SW9->W9_FORLOJ + Work_SW9->W9_HAWB ))
      For i:= 1 to SW9->(FCount())
         If Work_SW9->(FieldPos(SW9->(FieldName(i)))) # 0 .And. SW9->&(FieldName(i)) <> Work_SW9->&(SW9->(FieldName(i)))
            lRet := .T.
            Break
         EndIf
      Next i
   Else
      lRet := .T.
   EndIf

End Sequence


Return lRet

/*
Funcao      : DI500MKEST()
Parametros  :
Retorno     : .T.
Objetivos   : Marca/Desmarca manualmente um iTem no desembaraço de nacionalização
Autor       : Felipe S. Martinez
Data/Hora   : 15/07/2011 - 15:45 hs
Revisao     :
Obs.        :
*/
Static Function DI500MKEST()

If !lOperacaoEsp .And. Select("TRB") > 0
   If TRB->WK_OK == cMarca //FSM - 14/07/2011
      cNewMarca:=SPACE(02)
   Else
      cNewMarca:=cMarca
   EndIf
   TRB->WK_OK := cNewMarca
EndIf

Return .T.

/*
Função:    DI_CalcPesoCub()
Autor:     Diogo Felipe dos Santos
Data:      08/02/2012
Descrição: Função para cálculo de peso cubado
Revisão:   Thiago Rinaldi Pinto
*/

*-------------------------------*
Static Function DI_CalcPesoCub()
*-------------------------------*

LOCAL nPesoCubado:=0

SYQ->(DBSETORDER(1))
If SYQ->(dbSeek(xFilial("SYQ")+M->W6_VIA_TRA))
   If !Empty(M->W6_VIA_TRA)
      IF M->W6_MT3 # 0
         If Alltrim(SYQ->YQ_COD_DI) == "4-Aerea"
            nPesoCubado   := ( M->W6_MT3 / 0.006 )
         ElseIf Alltrim(SYQ->YQ_COD_DI) == "1-Maritimo"
            nPesoCubado   := ( M->W6_MT3 * 1000 )
         Endif
         M->W6_PESO_TX := IF( M->W6_PESO_BR > nPesoCubado, M->W6_PESO_BR, nPesoCubado )
      EndIf
   EndIf
EndIf

Return Nil

/*-----------------------------------------------------------------------------------------------------------------------
Funcao     : DI500MatVld()
Parametros : Nenhum
Retorno    : Logico
Objetivos  : Valida o codigo da matriz de tributação
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Static Function DI500MatVld()
Local lRet := .T.
Local cMsg := ""
Local cMsg1 := ""
Local cMsg2 := ""
Local nOrdSB1 := SB1->(IndexOrd())
Local nRecSB1 := SB1->(Recno())
Local nOrdEJB := 0
Local nRecEJB := 0
Begin Sequence

   If !(AvFlags("SUFRAMA") .And. EasyGParam("MV_TEM_DI", ,.F.) .And. Work_SW8->(FieldPos("WKCODMATRI")) > 0 )
      lRet := .T.
      Break
   EndIf
   nOrdEJB := EJB->(IndexOrd())
   nRecEJB := EJB->(Recno())
   SB1->(DBSetOrder(1))
   EJB->(DBSetOrder(1))
   Work_SW8->(DbGoTop())
   cMsg1 := "Os itens abaixo não possui 'Cod Matriz' preenchido." + ENTER
   cMsg2 := "Os itens abaixo possui 'Cod Matriz' não relacionado ao importador: '" + SYT->YT_COD_IMP + "'" + ENTER
   While Work_SW8->(!EOF())
      SB1->(DBSEEK(xFilial("SB1")+ Work_SW8->WKCOD_I))
      If !Empty(Work_SW8->WKFLAGIV) .And. Empty(Work_SW8->WKCODMATRI)
         DI500InvMarca('D') //Desmarca
         cMsg1 += " - Produto: "+AllTrim(Work_SW8->WKCOD_I) + " - " +AllTrim(MSMM( SB1->B1_DESC_GI,AvSx3("B1_VM_GI",3),1 ) ) + " do PO: " + AllTrim(Work_SW8->WKPO_NUM) + ENTER
         lRet := .F.
      ElseIf !Empty(Work_SW8->WKFLAGIV) .And. EJB->(DbSeek(xFilial("EJB") + AvKey(M->W6_IMPORT,"EJB_IMPORT") + AvKey(Work_SW8->WKCODMATRI,"EJB_CODMAT"))) .And. !(AllTrim(EJB->EJB_IMPORT) == AllTrim(SYT->YT_COD_IMP))
         DI500InvMarca('D') //Desmarca
         cMsg2 += " - Produto: "+AllTrim(Work_SW8->WKCOD_I) + " - " +AllTrim(MSMM( SB1->B1_DESC_GI,AvSx3("B1_VM_GI",3),1 ) ) + ENTER
         lRet := .F.
      EndIf
      Work_SW8->(DbSkip())
   EndDo

   cMsg := If( At("Produto:",cMsg1) > 0 , cMsg1 , "" ) + If( At("Produto:",cMsg2) > 0 , cMsg2 , "" )
   If !lRet
      EecView(cMsg)
   EndIf

   SB1->(DbSetOrder(nOrdSB1))
   EJB->(DbSetOrder(nOrdEJB))
   SB1->(DbGoTo(nRecSB1))
   EJB->(DbGoTo(nRecEJB))
   Work_SW8->(DbGoTop())

End Sequence
Return lRet

/*
Função    : ValidCourrier()
Objetivo  : Validar o processo de importação por Courrier
Retorno   : Logico
Parametro : Nenhum
Autor     : Flavio Danilo Ricardo
Data      : 03/09/2012
*/
Static Function ValidCourrier()
Private lRetC := .F.      // GFP - 25/10/2012
//LRS 23/10/2013 - Foi modificado a validação do campo W6_DIRE, separando da validação de existencia do campo, da validação de informação
If Empty(M->W6_DTREG_D) .And. Empty(M->W6_DT) .And. Empty(M->W6_DT_DESE) .And. (SW6->(FieldPos("W6_DIRE")) # 0 .And. !Empty(M->W6_DIRE))
   MsgInfo(STR0826,STR0558)//STR0826 - "Preencher os campos Registro DI e Data Pgto. Imposto." - STR0558"Aviso"
   lRetC := .T.
ElseIf Empty(M->W6_DTREG_D) .And. Empty(M->W6_DT) .And. !Empty(M->W6_DT_DESE) .And. (SW6->(FieldPos("W6_DIRE")) # 0 .And. Empty(M->W6_DIRE))
   MsgInfo(STR0827,STR0558)//STR0827 - "Preencher os campos Registro DI, Data Pgto. Imposto e No. DIRE." - STR0558"Aviso"
   lRetC := .T.
ElseIf Empty(M->W6_DTREG_D) .And. Empty(M->W6_DT) .And. !Empty(M->W6_DT_DESE) .And. (SW6->(FieldPos("W6_DIRE")) # 0 .And. !Empty(M->W6_DIRE))
   MsgInfo(STR0826,STR0558)//STR0826 - "Preencher os campos Registro DI e Data Pgto. Imposto." - STR0558"Aviso"
   lRetC := .T.
ElseIf Empty(M->W6_DTREG_D) .And. !Empty(M->W6_DT) .And. Empty(M->W6_DT_DESE) .And. (SW6->(FieldPos("W6_DIRE")) # 0 .And. Empty(M->W6_DIRE))
   MsgInfo(STR0828,STR0558)//STR0828 - "Preencher os campos Registro DI e No. DIRE." - STR0558"Aviso"
   lRetC := .F. //MCF-18/08/2015 - Exibe a mensagem, porém permite realizar a gravação do processo.
   //lRetC := .T.
ElseIf Empty(M->W6_DTREG_D) .And. !Empty(M->W6_DT) .And. Empty(M->W6_DT_DESE) .And. (SW6->(FieldPos("W6_DIRE")) # 0 .And. !Empty(M->W6_DIRE))
   MsgInfo(STR0829,STR0558)//STR0829 - "Preencher o campo Registro DI." - STR0558"Aviso"
   lRetC := .T.
ElseIf Empty(M->W6_DTREG_D) .And. !Empty(M->W6_DT) .And. !Empty(M->W6_DT_DESE) .And. (SW6->(FieldPos("W6_DIRE")) # 0 .And. Empty(M->W6_DIRE))
   MsgInfo(STR0828,STR0558)//STR0828 - "Preencher os campos Registro DI e No. DIRE." - STR0558"Aviso"
   lRetC := .F. //MCF-18/08/2015 - Exibe a mensagem, porém permite realizar a gravação do processo.
   //lRetC := .T.
ElseIf Empty(M->W6_DTREG_D) .And. !Empty(M->W6_DT) .And. !Empty(M->W6_DT_DESE) .And. (SW6->(FieldPos("W6_DIRE")) # 0 .And. !Empty(M->W6_DIRE))
   MsgInfo(STR0829,STR0558)//STR0829 - "Preencher o campo Registro DI." - STR0558"Aviso"
   lRetC := .T.
ElseIf !Empty(M->W6_DTREG_D) .And. Empty(M->W6_DT) .And. Empty(M->W6_DT_DESE) .And. (SW6->(FieldPos("W6_DIRE")) # 0 .And. Empty(M->W6_DIRE))
   MsgInfo(STR0830,STR0558)//STR0830 - "Preencher o campo No. DIRE." - STR0558"Aviso"
   lRetC := .T.
ElseIf !Empty(M->W6_DTREG_D) .And. Empty(M->W6_DT) .And. !Empty(M->W6_DT_DESE) .And. (SW6->(FieldPos("W6_DIRE")) # 0 .And. Empty(M->W6_DIRE))
   MsgInfo(STR0831,STR0558)//STR0831 - "Preencher os campos Data Pgto. Imposto e No. DIRE." - STR0558"Aviso"
   lRetC := .T.
ElseIf !Empty(M->W6_DTREG_D) .And. Empty(M->W6_DT) .And. !Empty(M->W6_DT_DESE) .And. (SW6->(FieldPos("W6_DIRE")) # 0 .And. !Empty(M->W6_DIRE))
   MsgInfo(STR0832,STR0558)//STR0832 - "Preencher o campo Data Pgto. Imposto." - STR0558"Aviso"
   lRetC := .T.
ElseIf !Empty(M->W6_DTREG_D) .And. !Empty(M->W6_DT) .And. Empty(M->W6_DT_DESE) .And. (SW6->(FieldPos("W6_DIRE")) # 0 .And. Empty(M->W6_DIRE))
   MsgInfo(STR0830,STR0558)//STR0830 - "Preencher o campo No. DIRE." - STR0558"Aviso"
   lRetC := .T.
ElseIf !Empty(M->W6_DTREG_D) .And. !Empty(M->W6_DT) .And. !Empty(M->W6_DT_DESE) .And. (SW6->(FieldPos("W6_DIRE")) # 0 .And. Empty(M->W6_DIRE))
   MsgInfo(STR0830,STR0558)//STR0830 - "Preencher o campo No. DIRE." - STR0558"Aviso"
   lRetC := .T.
EndIf
//LRS 23/10/2013 - Fim
If(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"VALID_COURIER"),)  // GFP - 25/10/2012
Return lRetC

/*
Função    : DI500AtuFilial()
Objetivo  : Atualização das variáveis de filiais.
Autor     : Wilsimar Fabricio da Silva - WFS
Data      : 26/11/13
*/
Static Function DI500AtuFilial()

If lIntDraw .And.  Posicione("SX2",1,"ED1","X2_MODO") == "C"
	cFilSW5:=xFilial("SW5")
	cFilSW8:=xFilial("SW8")
	cFilSW9:=xFilial("SW9")
	cFilSWB:=xFilial("SWB")
EndIf
Return

/*
Programa   : DI500ESS()
Objetivo   : Integrar o embarque ao módulo SIGAESS (Easy Siscoserv) para geração do Processo, Invoices e Parcelas referente as despesas
Parâmetros : cHawb - Processo de Embarque, nOpc - Operação a ser realizada
Autor      : Rafael Ramos Capuano
Data       : 20/11/2013 - 14:38
Revisão    : WFS 03/07/2014 - alterada a chamada da função para o programa EICDI505
*/
Function DI500ESS(cHawb,nOpc)
Return Processa({|| DI505ESS(cHawb,nOpc) }, STR0885)//"Integração SISCOSERV" //RMD - 20/10/14

/*
Função     : IntegPendente()
Objetivo   : Verificar se existem integrações pendentes com relação ao financeiro do ERP (EAI)
Parametro  :
Retorno    : Logico - .T. se possui pendências de integração com o financeiro
Observações:
Autor      : WFS
Data       : Fev/2015
*/
Static Function IntegPendente()
Local lRet:= .F.
Local aOrd:= SaveOrd({"SWA"})

Begin Sequence

   /* Se possuir câmbio, verifica o status gravado no processo; se não possui câmbio,
      será validado por programa */
   SWA->(DBSetORder(1)) //WA_FILIAL+WA_HAWB+WA_PO_DI
   If SWA->(DBSeek(xFilial() + M->W6_HAWB + "D"))
      If M->W6_TITOK == "2"
         lRet:= .T.
      EndIf
   Else
      If AP110AtuStatus(M->W6_HAWB, .F.) == "2"
         lRet:= .T.
      EndIf
   EndIf

End Sequence

RestOrd(aOrd, .T.)
Return lRet


/*********************************************/
/* Funções migradas para o programa EICDI501 */
/*********************************************/

Function DI500DigItem(oBrw)
Return DI501DigItem(oBrw)

Function DI500DigVal(cCpo)
Return DI501DigVal(cCpo)

Function DI500GravaTudo()
Return DI501GravaTudo()

Function DI500GrvSW6(cAtz_Ocor)
Return DI501GrvSW6(cAtz_Ocor)

Function DI500Estorno()
Return DI501Estorno()

Function DI500GrvInvoice()
Return DI501GrvInvoice()

Function DI500Despes(Alias,nReg,nOpc)
Return DI501Despes(Alias,nReg,nOpc)

Function DI500DespManut(nOpcao,aAutoCab)
Return DI501DespManut(nOpcao,aAutoCab)

Function DI500RelDesp(lGera)
Return DI501RelDesp(lGera)

Function DI500CondRel()
Return DI501CondRel()

Function DI500D_Grava(cAlias)
Return DI501D_Grava(cAlias)

Function DI500D_Tela(lInit)
Return DI501D_Tela(lInit)

Function DI500D_Edi(lInclui,aAutoCab,lPrestacao)
Return DI501D_Edi(lInclui,aAutoCab,lPrestacao)

Function DI500PVLD(cTipo)//AWF - 11/08/2014
Return DI501PVLD(cTipo)

Function DI500D_Del(lPrestacao)
Return DI501D_Del(lPrestacao)

Function DI500EnchoiceBar(oDlg,aOk,bCancel,lUnused,aButtons)
Return DI501EnchoiceBar(oDlg,aOk,bCancel,aButtons)

Function DI500GrvWkSW8(lGrava)
Return DI501GrvWkSW8(lGrava)

Function DI500SW7Del()// Antiga DI_Estorno //MJB-SAP-1000
Return DI501SW7Del()

Function DI500SW8Del(PHawb,PItem,PFabr,PForn,PPGi,PSi,PPo,PCc,PReg,aInvAcerta, cFabLoj, cForLoj)// Antiga DI410_IVH() //MJB-SAP-1000
Return DI501SW8Del(PHawb,PItem,PFabr,PForn,PPGi,PSi,PPo,PCc,PReg,aInvAcerta, cFabLoj, cForLoj)

Function DI500AcertaSW9(cProcesso,aInvAcerta)
Return DI501AcertaSW9(cProcesso,aInvAcerta)

Function DI500EIGrava(cExecuta,cHawb,aAlias)
Return DI501EIGrava(cExecuta,cHawb,aAlias)

Function DI500aEMB()//Antiga EICDI400aEMB
Return DI501aEMB()

Function DI500EnvSis()
Return DI501EnvSis()

Function DI500ValGerTXT(lNovaInt,lBlind)
Return DI501ValGerTXT(lNovaInt,lBlind)

Function DI500Taxa(lMemoria, lAtu,nOPC)
Return DI501Taxa(lMemoria, lAtu,nOPC) // LRS - 04/05/2017

Function DI500DIConf()
Return DI501DIConf()

Function DI500NVE(nOpc)
Return DI501NVE(nOpc)

Function DI500GetNCM()
Return DI501GetNCM()

Function DI500DelNV()
Return DI501DelNV()

Function DI500TemNVEOK(lVerItens,lMSG)
Return DI501TemNVEOK(lVerItens,lMSG)

Function DI500GerNVE()
Return DI501GerNVE()

Function DI500MarNVE()
Return DI501MarNVE()

Function DI500NVEVal(cCampo,cChave)
Return DI501NVEVal(cCampo,cChave)

Function DI500SelNVE()
Return DI501SelNVE()

Function DI500BoxNVE()
Return DI501BoxNVE()

Function DI500GrvNVE(nSelOp,cChave)
Return DI501GrvNVE(nSelOp,cChave)

Function DI500CrgNVE(cNVE,bBlocSel,lZap)
Return DI501CrgNVE(cNVE,bBlocSel,lZap)

Function DI500GEIMGrv(cChave)
Return DI501GEIMGrv(cChave)

Function DI500EIMGrava()
Return DI501EIMGrava()

Function DI500TstCpoPeso()
Return DI501TstCpoPeso()

Function DI500RatFrete()
Return DI501RatFrete()

Function DI500AUTPCDI()
Return DI501AUTPCDI()

Function DI500TotReg(cOpcao)
Return DI501TotReg(cOpcao)

Function DI500DtTxInv()
Return DI501DtTxInv()

Function DI500ConvQtdeRat(cAlias,nQtdeTot)
Return DI501ConvQtdeRat(cAlias,@nQtdeTot)

Function DI500RetVal(cTot,cArea,lDesp,lConv,lConsidIn327)
Return DI501RetVal(cTot,cArea,lDesp,lConv,lConsidIn327)

Function Proc2XLS(cAlias,nReg)
Return DI501Proc2XLS(cAlias,nReg)

Function ValidInv()
Return DI501ValidInv()

Function GetLocVen(cOrigem)
Return DI501GetLocVen(cOrigem)

Function DI500SWDLin(cHawb,cDespesa)
Return DI501SWDLin(cHawb,cDespesa)

Function DI500ChkEW4()
Return DI501ChkEW4()

Function DI500Crit(MFlag,cCampo)
Return DI501Crit(MFlag,cCampo)

Function DI500Encerra()
Return DI501Encerra()

Function DI500AtuTab(cOpcao)
Return DI501AtuTab(cOpcao)

Function DI500PNPLI(cPo)
Return DI501PNPLI(cPo)

Function DI500GERNF(cOperacao)
Return DI501GERNF(cOperacao)

Function TransfNVE(cFaseOri)
Return DI501TransfNVE(cFaseOri)

Function DI500SeqInstrDe()
Return DI501SeqInstrDe()

Function DI500AdmEntre()
Return DI501AdmEntre()

Function DI500EstAdmEntre()
Return DI501EstAdmEntre()

Function DI500ValTipDes()
Return DI501ValTipDes()

Function DI500LIAutomatica(cCampo)
Return DI501LIAutomatica(cCampo)

Function Check_adic(cAdic) /// 03/08/12 - BCO - Validação para o Campo EIN_ADICAO não ser gravado vazio
Return DI501Check_adic(cAdic)

Function DI500STATUS(cHawb)
Return DI501STATUS(cHawb)

/*
Funcao     : DI500Prov
Parametros : Nenhum
Objetivos  : Visualizar as despesas provisórias quando EAI
Autor      : WFS
Data/Hora  :
*/
Function DI500Prov()
Return FI410Prov("PRE")
/*
Funcao     : SaveTempFiles
Parametros :
Retorno    : Lógico
Objetivos  : Verificar se está ativo o controle de reaproveitamento de arquivos temporários - EECCRIATRAB
             Possibilitar centralizar em um único ponto as verificações destas condições.
             Inicialmente o único cenário para o embarque/ desembaraço é a integração EAI ou ponto de entrada, que altera a variável __KeepUsrFiles.
Autor      : wfs
Data/Hora  : mar/2017
*/
Static Function SaveTempFiles()
Static lSaveTempFiles

Begin Sequence

   If ValType(lSaveTempFiles) == "U"

      If Type("__KeepUsrFiles") <> "L"
         __KeepUsrFiles:= AvFlags("EIC_EAI")
      EndIf

      lSaveTempFiles:= __KeepUsrFiles
   EndIf


End Sequence

Return lSaveTempFiles


/*
Funcao     : VldSldInv
Parametros :lInvParcial - Indica se o Parametro MV_EIC0057 (permite invoice parcial) esta .T. ou .F.;
            lTemInvoice - Indica se tem item com invoice no processo;
            lSemInvoice - Indica se tem item sem invoice no processo;
Retorno    : Lógico
Objetivos  : 
Autor      : 
Data/Hora  : 05/06/2018
*/
Static Function VldSldInv(lInvParcial,lTemInvoice,lSemInvoice)
Local lRet := .F.

Begin Sequence
//Parametro MV_EIC0057 (permite invoice parcial) Habilitado
If lInvParcial .And. MOpcao != FECHTO_EMBARQUE .And. !lTemInvoice //Nao permite gravar desembaraco sem nenhuma invoice
    lRet := .T.
    Break
EndIf

//Parametro MV_EIC0057 (permite invoice parcial) Desabilitado
If !lInvParcial
    If MOpcao == FECHTO_EMBARQUE .And. lTemInvoice .And. lSemInvoice //Gravacao esta sendo feita do Embarque e tem itens com e itens sem invoice
        lRet := .T.
        Break
    ElseIf MOpcao != FECHTO_EMBARQUE
        If lSemInvoice //Esta sendo gravado no desembaraco e tem item sem invoice
            lRet := .T.
            Break
        EndIf
    EndIf
EndIf

End Sequence

Return lRet
/*
Funcao     : DI500ChQry
Parametros : cQryAgpAd - String da Query formada para agrupar as adições
Retorno    : cQryAgruAd - String da Query formada para agrupar as adições modificada via ponto de entrada
Objetivos  : Permitir manipuação da query de agrupamento das adições pelo ponto de entrada que antes permitia 
             o agrupamento pelo Loop nos itens do processo
Autor      : Nilson César
Data/Hora  : 05/09/2018
*/
Function DI500ChQry(cQryAgpAd)
Private cQryAgruAd := cQryAgpAd
   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"LOOP_WORK_SW8_ADICAO"),)
   cQryAgpAd := cQryAgruAd
Return cQryAgruAd

/*------------------------------------------------------------------------------------
Funcao      : GerAdicQry
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : 
Data/Hora   : 
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
//O nome da funcao foi alterada, pois ela havia sido criada no Rdmake. Ao mudar para o eicdi500, definimos um novo nome
//Function GerAdicQry(lGerAdiAut,lLimpa,cAliasCapa,cAliasItem,lAllEmtpy)
Function DI500GerAdicQry(lGerAdiAut,lLimpa,cAliasCapa,cAliasItem,lAllEmtpy)

Local nMaxItAdic  := EICParISUF()
Local cWorkCapa   := TETempName(cAliasCapa) //Substr( TETempName(cAliasCapa) , At("#",TETempName(cAliasCapa))  )  //##TMPSC00_00
Local cWorkItens  := TETempName(cAliasItem) //Substr( TETempName(cAliasItem) , At("#",TETempName(cAliasItem))  )
Local cQryCampos  := cQryClearAd := cSeqAdi := cQryUpdt := cSelecIt := cFromIt := cWhereIt := cQrySelReg := ""
Local aSeqAdic, nPos,i,j,cSeqItAdic,cCpoAdic
Local lGerar      := lGerAdiAut .And. !lLimpa
Local cOldArea    := Select()
Local aRegAdiCapa := {}
Private cQryAgpAdi := "" 
If !lGerar

   If lLimpa
      TEClearWkAd( "C",cWorkCapa ,cAliasCapa,"EICADICAO" )   // Limpa o número das adições da capa 
      TEClearWkAd( "D",cWorkItens,cAliasItem,"EICADICAO" )   // Limpa o número das adições dos itens
   EndIf

  //Forma a query para agrupar as adições (itens com mesmas características no que diz respeito aos critérios de quebra de adição) já com número
   cQryCampos := EicAdicInd("EICADICAO_SW8","3")
   cCpoAdic   := " WKADICAO, "
   cQryAgpAdi := " SELECT "   + cCpoAdic + cQryCampos 
   cQryAgpAdi += " FROM "     + cWorkItens
   cQryAgpAdi += " WHERE D_E_L_E_T_ <> '*'
   cQryAgpAdi += " GROUP BY " + cCpoAdic + cQryCampos 
   cQryAgpAdi += " ORDER BY " + cCpoAdic + cQryCampos

   If Select("WKTMPADIC1") > 0
      WKTMPADIC1->(DBCloseArea())
   EndIf

   cQryAgpAdi := ChangeQuery(cQryAgpAdi)
   TcQuery cQryAgpAdi Alias "WKTMPADIC1" New
   WKTMPADIC1->(Dbgotop())
   //-----------------------------------------------------
   If lLimpa .Or. lAllEmtpy 
      cSeqAdi := Soma1("000")
      aCposChvAd := EicAdicInd("EICADICAO_SW8","1")
      //FUNÇÃO PARA AGRUPAR AS ADIÇÕES CONFORME CARACTERÍSTICAS SEMELHANTES DOS ITENS BASEADAS NA CHAVE DE QUEBRA
      cSeqAdi := TEGerNumAd( aCposChvAd , cWorkItens , cAliasItem , "WKTMPADIC1" , cSeqAdi )
      //FUNÇÃO PARA ORGANIZAR AS ADIÇÕES CONFORME MV_NR_ISUF E AS SEQUÊNCIAS DAS ADIÇÕES DOS ITENS
      TEOrgSeqAd(cAliasItem, cSeqAdi, lLimpa)
      If lLimpa
         // Limpa o número das adições da capa 
         TEClearWkAd( "C",cWorkCapa,cAliasCapa,"EICADICAO" )
      Else
         // Fazer query para agrupar adições com numeraçõa já informada e gravar work da capa
         cQryCampos := "WKADICAO," + cQryCampos 
         cQryAgpAdi := " SELECT " + cQryCampos 
         cQryAgpAdi += " FROM " + cWorkItens
         cQryAgpAdi += " WHERE D_E_L_E_T_ <> '*'
         cQryAgpAdi += " GROUP BY " + cQryCampos 
         cQryAgpAdi += " ORDER BY " + cQryCampos

         If Select("WKLINEADIC1") > 0
            WKLINEADIC1->(DBCloseArea())
         EndIf

         cQryAgpAdi := ChangeQuery(cQryAgpAdi)
         TcQuery cQryAgpAdi Alias "WKLINEADIC1" New

         WKLINEADIC1->(Dbgotop())
         Do While WKLINEADIC1->(!Eof())
            (cAliasCapa)->(DbAppend())
            If cAliasCapa == "WorkCap_SW8"
               AvReplace("WKLINEADIC1",cAliasCapa)
            /*ElseIf cAliasCapa == "Work_EIJ"
               TEGrvWkAdi( {"WKLINEADIC1",EicAdicInd("EICDI500_SW8","1")} , {cAliasCapa,EicAdicInd("EICDI500_EIJ","1")} , cSeqAdi , {}  )*/
            EndIf
            WKLINEADIC1->(DbSkip())
         EndDo
         
         WKLINEADIC1->(DBCloseArea())

      EndIf
      // Limpa o número das adições dos itens    
      TEClearWkAd( "D",cWorkItens,cAliasItem,"EICADICAO" )   
   //-----------------------------------------------------
   Else
      WKTMPADIC1->(Dbgotop())
      (cAliasCapa)->(avzap())
   
      cSeqAdi := Soma1("000")
      Do While WKTMPADIC1->(!Eof())
         (cAliasCapa)->(DbAppend())
         If cAliasCapa == "WorkCap_SW8"
            AvReplace("WKTMPADIC1",cAliasCapa)

            If lAllEmtpy .And. Empty( (cAliasCapa)->WKADICAO ) .And. !lLimpa
               (cAliasCapa)->WKADICAO := cSeqAdi   
            EndIf
         /*ElseIf cAliasCapa == "Work_EIJ"
            TEGrvWkAdi( {"WKTMPADIC1",EicAdicInd("EICDI500_SW8","1")} , {cAliasCapa,EicAdicInd("EICDI500_EIJ","1")} , cSeqAdi , {} )*/
         EndIf
         //***OBS: numerar as adições aqui considerando o IsAllEmpty
         cSeqAdi := Soma1(cSeqAdi)
         WKTMPADIC1->(DbSkip())
      EndDo
   EndIf

   WKTMPADIC1->(DBCloseArea())   

Else 
   // Limpar o número das adições dos itens para efetuar a reorganização
   cQryCampos := EicAdicInd("EICADICAO_SW8","3")
   TEClearWkAd( "D",cWorkItens,cAliasItem,"EICADICAO" )   // Limpa o número das adições dos itens
   
   //Forma a query para agrupar as adições (itens com mesmas características no que diz respeito aos critérios de quebra de adição)
   cQryAgpAdi := " SELECT " + cQryCampos 
   cQryAgpAdi += " FROM " + cWorkItens
   cQryAgpAdi += " WHERE D_E_L_E_T_ <> '*'
   //cQryAgpAdi += " WHERE WKADICAO = '' " 
   cQryAgpAdi += " GROUP BY " + cQryCampos 
   cQryAgpAdi += " ORDER BY " + cQryCampos

   If Select("WKLINEADIC2") > 0
      WKLINEADIC2->(DBCloseArea())
   EndIf

   cQryAgpAdi := DI500ChQry( cQryAgpAdi )

   cQryAgpAdi := ChangeQuery(cQryAgpAdi)
   TcQuery cQryAgpAdi Alias "WKLINEADIC2" New

   WKLINEADIC2->(Dbgotop())
   cSeqAdi := If( lGerAdiAut , Soma1("000") , "")
   aCposChvAd := EicAdicInd("EICADICAO_SW8","1")
   //FUNÇÃO PARA AGRUPAR AS ADIÇÕES CONFORME CARACTERÍSTICAS SEMELHANTES DOS ITENS BASEADAS NA CHAVE DE QUEBRA
   cSeqAdi := TEGerNumAd( aCposChvAd , cWorkItens , cAliasItem , "WKLINEADIC2" , cSeqAdi )

   WKLINEADIC2->(DBCloseArea())

   //FUNÇÃO PARA ORGANIZAR AS ADIÇÕES CONFORME MV_NR_ISUF E AS SEQUÊNCIAS DAS ADIÇÕES DOS ITENS
   TEOrgSeqAd(cAliasItem, cSeqAdi, lLimpa) 

  //Forma a query para agrupar as adições (itens com mesmas características no que diz respeito aos critérios de quebra de adição) já com número
   cQryAgpAdi := " SELECT WKADICAO, " + cQryCampos 
   cQryAgpAdi += " FROM " + cWorkItens
   cQryAgpAdi += " WHERE D_E_L_E_T_ <> '*'
   //cQryAgpAdi +=  If(lGerAdiAut , " WHERE WKADICAO <> '' " , " WHERE WKADICAO = '' " ) 
   cQryAgpAdi += " GROUP BY WKADICAO, " + cQryCampos 
   cQryAgpAdi += " ORDER BY WKADICAO, " + cQryCampos

   If Select("WKTMPADIC2") > 0
      WKTMPADIC2->(DBCloseArea())
   EndIf

   cQryAgpAdi := ChangeQuery(cQryAgpAdi)
   TcQuery cQryAgpAdi Alias "WKTMPADIC2" New

   WKTMPADIC2->(Dbgotop())
   aRegAdiCapa := {}
   If cAliasCapa == "Work_EIJ"
      (cAliasCapa)->(DBEval({|| aAdd(aRegAdiCapa , {EIJ_ADICAO , WK_RECNO}) } ))   
   EndIf

   (cAliasCapa)->(avzap())  //Limpa a tabela quando WorkCap_SW8 / Work_EIJ, porém para Work_EIJ a tratativa de append é feita no EICDI500

   If cAliasCapa == "WorkCap_SW8" 
      Do While WKTMPADIC2->(!Eof())
         (cAliasCapa)->(DbAppend())
         AvReplace("WKTMPADIC2",cAliasCapa)
         WKTMPADIC2->(DbSkip())
      EndDo
   EndIf

   WKTMPADIC2->(DBCloseArea())

EndIf

DbSelectArea(cOldArea)

Return

/*------------------------------------------------------------------------------------
Funcao      : TEGrvWkAdi
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : 
Data/Hora   : 
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
*----------------------------------------------------------------* 
Static Function TEGrvWkAdi(aWorkOrig,aWorkDest,cAdicao,aRegsCapa)
*----------------------------------------------------------------* 
Local cAliasDE    := aWorkOrig[1]
Local cAliasPARA  := aWorkDest[1]
Local i, nPos, lRet := .F.
Local lTamChvAdic := Len( aWorkOrig[2] ) == Len( aWorkDest[2] ) 

If lTamChvAdic
   For i:=1 To Len(aWorkOrig[2])
      If (cAliasDE)->(FieldPos(aWorkOrig[2][i])) > 0
         (cAliasPARA)->&(aWorkDest[2][i]) := (cAliasDE)->&(aWorkOrig[2][i])
      EndIf
   Next i
   If !Empty(cAdicao)
      If cAliasPARA == "WorkCap_SW8" .And. Empty( (cAliasPARA)->WKADICAO  )
         (cAliasPARA)->WKADICAO :=  cAdicao
      ElseIf cAliasPARA == "Work_EIJ" .And. Empty( (cAliasPARA)->EIJ_ADICAO )
         (cAliasPARA)->EIJ_ADICAO := cAdicao
         If Len(aRegsCapa) > 0 .And. ( nPos := aScan(aRegsCapa, {|x| x[1] == cAdicao })  ) > 0
            (cAliasPARA)->WK_RECNO := aRegsCapa[nPos][2]   
         EndIf 
      EndIf
   EndIf
   lRet := .T.
Else
   MsgAlert("A chave de adição do Item da invoice difere da chave de adição do desembaraço! Favor verificar","AVISO")
EndIf

Return lRet

*----------------------------------------------*
FUNCTION TEOrgSeqAd(cAliasItem,cSeqAdi,lLimpa)
*----------------------------------------------*
Local aSeqAdic := {{"001","000",{},""}}
Local nPos, i , j
Local nMaxItAdic := EICParISUF()
Local aOrdWrk := SaveOrd(cAliasItem)
Default cSeqAdi := "000"
Default lLimpa  := .F.

   If cAliasItem == "Work_SW8"
      (cAliasItem)->(DbSetOrder(6)) //"WKTEC"
   EndIf
   (cAliasItem)->(DbGoTop())
   Do While (cAliasItem)->(!eof())

      If (  nPos := aScan( aSeqAdic, {|x| (cAliasItem)->WKADICAO == x[1]   } )  ) > 0 

         If Len(aSeqAdic[nPos][3]) < nMaxItAdic .Or. ( IsInCallStack('EICADICAO') .And. Empty(aSeqAdic[nPos][1]) .And. Empty((cAliasItem)->WKADICAO) )
      
            //Atualiza Array
            aSeqAdic[nPos][2] := Soma1( aSeqAdic[nPos][2] )
            aAdd( aSeqAdic[nPos][3] , (cAliasItem)->(Recno()) ) 
         Else

            //Verificar se existe espaço em uma adição convertida de item originado na mesma adição
            IF (  nPos := aScan( aSeqAdic, {|x| (cAliasItem)->WKADICAO == x[4]  .And. Len(x[3]) < nMaxItAdic   } )  ) > 0

               //Caso exista, reaproveita a mesma adição convertida adicionando nova sequencia   
               aSeqAdic[nPos][2] := Soma1( aSeqAdic[nPos][2] )
               aAdd( aSeqAdic[nPos][3] , (cAliasItem)->(Recno()) )
            Else 
               // Somente sequenciar itens de adições preenchidas e no limite do MV_NR_ISUF            
               If !( Empty((cAliasItem)->WKADICAO) .And. Empty(aSeqAdic[Len(aSeqAdic)][1]) .And. Len(aSeqAdic[Len(aSeqAdic)][3]) >= nMaxItAdic )

                  //Caso contrário, é necessário Incrementar uma nova adição convertida no array (cSeqAdi já vem com a próx. seq. disponível)  
                  aAdd( aSeqAdic, { cSeqAdi , "001" , { (cAliasItem)->(Recno()) } , (cAliasItem)->WKADICAO } )

                  //Se foi digitado o Nro da adição em uma linha que tenha itens na qtde. limite do MV_NR_ISUF, procura a outra linha de adição
                  //gerada com a mesma chave para atribuir à ela a próxima sequência que foi atribuída aos itens excedentes.
                  If !lLimpa .And. ( nPosAtuCap := If( IsMemVar('oMark1') , oMark1:nAt , NIL ) ) <> NIL
                     AtuAdicCAP( "WorkCap_SW8","WKADICAO",cSeqAdi,nPosAtuCap,cAliasItem,(cAliasItem)->(Recno()) )
                  EndIf

                  cSeqAdi := Soma1(cSeqAdi) 
               EndIf

            EndIf

         EndIf
      Else
         //Adiciona a Adição já existente com a primeira sequência
         aAdd( aSeqAdic, { (cAliasItem)->WKADICAO , "001" , { (cAliasItem)->(Recno()) } , "" } )
      EndIF

      (cAliasItem)->(DbSkip())

   EndDo

   For i := 1 to Len(aSeqAdic)
      cSeqItAdic := "000"
      For j := 1 To Len(aSeqAdic[i][3])
        If !Empty(aSeqAdic[i][1])
            (cAliasItem)->(DbGoTo(  aSeqAdic[i][3][j]   ))
            (cAliasItem)->WKADICAO  := aSeqAdic[i][1]
            cSeqItAdic := Soma1(cSeqItAdic)
            (cAliasItem)->WKSEQ_ADI := cSeqItAdic
        EndIf
      Next j
   Next i
   
   RestOrd(aOrdWrk,.t.)

   Return


*------------------------------------------------------------*
FUNCTION TEClearWkAd( cTipo,cWork,cAliasWork,cOrigem,cCodAdicao )
*-------------------------------------------------------------*   
   Local cQryClearAd := ""
   Local aOrd := SaveOrd(cAliasWork)
   Default cCodAdicao := ""
   Do Case
      Case cTipo == "C" 
         If cOrigem == "EICADICAO"
            cQryClearAd := " UPDATE " + cWork
            cQryClearAd += " SET WKADICAO = ' ' "
            If !Empty(cCodAdicao)
                cQryClearAd += " WHERE WKADICAO = '" + cCodAdicao + "' "
            EndIf
         ElseIf cOrigem == "EICDI500"
            cQryClearAd := " UPDATE " + cWork
            cQryClearAd += " SET EIJ_ADICAO = ' ' "
            If !Empty(cCodAdicao)
                cQryClearAd += " WHERE EIJ_ADICAO = '" + cCodAdicao + "' "
            EndIf            
         EndIf
      Case cTipo == "D"
         cQryClearAd := " UPDATE " + cWork
         cQryClearAd += " SET WKADICAO = ' ', WKSEQ_ADI = ' ' "
         If !Empty(cCodAdicao)
            cQryClearAd += " WHERE WKADICAO = '" + cCodAdicao + "' "
         EndIf         
   EndCase    
   (cAliasWork)->(DbSetOrder(0))
   TcSqlExec( cQryClearAd )
   (cAliasWork)->(DbGoTop())

   RestOrd(aOrd, .T.)
   Return


*---------------------------------------------------------------------------------------*
FUNCTION TEGerNumAd( aCposChvAd , cWorkItens , cAliasItem, cWorkRsSet , cSeqAdi ,nRecWork)
*---------------------------------------------------------------------------------------*
Local cQrySelReg := ""
Local cCpoAdic   := "WKADICAO"
Local i, cRetSeqAdi
Local aOrd := SaveOrd(cAliasItem)
Default nRecWork := 0
   Do While (cWorkRsSet)->(!Eof())
      If !Empty(nRecWork)
            (cWorkRsSet)->(dBGoTo(nRecWork))
      EndIf
      cQryUpdt := " UPDATE " + cWorkItens
      cQryUpdt += " SET " + cCpoAdic + " = '"+cSeqAdi+"'"
      cWhereIt := " WHERE "+aCposChvAd[1]+" = '"+(cWorkRsSet)->&( aCposChvAd[1] )+"'"
      For i:=2 To Len(aCposChvAd)
         cWhereIt += " AND "+aCposChvAd[i]+" = '"+ If( ValType( (cWorkRsSet)->&( aCposChvAd[i] )) <> "C", cValTochar( (cWorkRsSet)->&( aCposChvAd[i] ) ) , (cWorkRsSet)->&( aCposChvAd[i] ) )+"'" 
      Next i
      cWhereIt += "   AND " + cCpoAdic + "  = ' '"

      cQryUpdt += cWhereIt

      (cAliasItem)->(DbSetOrder(0))
      TcSqlExec( cQryUpdt )
      (cAliasItem)->(DbGoTop())
      RestOrd(aOrd, .T.)

      cSeqAdi := Soma1(cSeqAdi)

      (cWorkRsSet)->(DbSkip())
      If !Empty(nRecWork)
            Exit
      EndIf
   EndDo

   cRetSeqAdi := cSeqAdi

Return cRetSeqAdi

*------------------------------------------*
STATIC FUNCTION  TEGetEmpty(cAlias,cField)
*------------------------------------------*
Local xRet := NIL
Local xTypeField := Valtype( (cAlias)->(cField) )

Do Case
   Case xTypeField == "C"
      xRet := ""
   Case xTypeField == "D"
      xRet := CtoD("  /  /  ")
   Case xTypeField == "N"
      xRet := 0 
EndCase

Return xRet

Static Function fobEIJ(nAcrecimo, nDeducao)
Return (nAcrecimo-nDeducao) + IF(AvRetInco(Work_EIJ->EIJ_INCOTE,"CONTEM_FRETE"),Work_EIJ->EIJ_VLMMN-Work_EIJ->EIJ_VFREMN,Work_EIJ->EIJ_VLMMN)

*------------------------------------------------------------------------------------------*
Static Function AtuAdicCAP(cAliasCapa,cCpoCapa,xDadoCapa,nRecnoCapa,cAliasItem,nRecnoItem)
*------------------------------------------------------------------------------------------*
Local cAliasSel := TETempName(cAliasCapa)
Local aOrd := SaveOrd(cAliasItem)
Local aCposChvAd := EicAdicInd("EICADICAO_SW8","1")
Local cSelect,cFrom,cWhere,cQueryExec,i,W
Local nOldArea := Select()
Default nRecnoCapa := 0

      cSelect :=  " SELECT * "
      cFrom   :=  " FROM " + cAliasSel 
      cWhere  :=  " WHERE "+aCposChvAd[1]+" = '"+(cAliasItem)->&( aCposChvAd[1] )+"'"
      For i:=2 To Len(aCposChvAd)
         cWhere += " AND "+aCposChvAd[i]+" = '"+ If( ValType( (cAliasItem)->&( aCposChvAd[i] )) <> "C", cValTochar( (cAliasItem)->&( aCposChvAd[i] ) ) , (cAliasItem)->&( aCposChvAd[i] ) )+"'" 
      Next i
      cWhere += "  AND " + "WKADICAO" + "  = ' '"
      If nRecnoCapa > 0
         cWhere += " AND R_E_C_N_O_ <> "+Alltrim(Str(nRecnoCapa))
      EndIf
      cQueryExec :=  cSelect+cFrom+cWhere

      If Select("AGRUPADIC") > 0
         AGRUPADIC->(DbCloseArea())
      EndIf
      cQueryExec := ChangeQuery(cQueryExec)
      dbUseArea( .t., "TopConn", TCGenQry(,,cQueryExec), "AGRUPADIC", .F., .F. )

      IF AGRUPADIC->(!Eof()) .And. AGRUPADIC->(!Bof())
         (cAliasCapa)->(DbGoTo( AGRUPADIC->R_E_C_N_O_  ))
         (cAliasCapa)->&(cCpoCapa) := xDadoCapa
         //aColsSW8[AGRUPADIC->R_E_C_N_O_][1] := xDadoCapa
      ENDIF

      //Atualização da tela de adições
      WorkCap_SW8->(DbGotop())
      aColsSW8 := {}
      Do While WorkCap_SW8->(!eof())
         aCpos:={}
         FOR W := 1 TO len(aCamposSW8)-1
            IF aCamposSW8[W,4] = "C"
               If !aCamposSW8[W,1] == "WKSEQ_ADI"
                  AADD(aCpos,WorkCap_SW8->(FIELDGET( FIELDPOS(aCamposSW8[W,1]) )))
               EndIf   
            ENDIF
         NEXT   
         AADD(aCpos, WorkCap_SW8->(RECNO()) )
         AADD(aCpos,.F.)
         AADD(aColsSW8,aClone(aCpos))
         WorkCap_SW8->(DbSkip())
      EndDo

      aCols        := aClone(aColsSW8)
      oMark1:aCols := aClone(aColsSW8)

      (cAliasItem)->(DBSETORDER(0))
      (cAliasItem)->(DBGOTOP())
      WorkCap_SW8->(DBSETORDER(0))
      WorkCap_SW8->(DBGOTOP())

      AGRUPADIC->(DbCloseArea())
      dbSelectArea(nOldArea)
      RestOrd(aOrd, .T.)

Return

/*
Função   : MarkItW8
Autor    : Nilson César
Data     : 29/09/2020
Objetivo : Habilita/Desabilita registro para marcação conforme condição
           Executa a ação do "DoubleClic"
*/
*--------------------------------------------------
static function MarkItW8(oFBrw,cSel)
*--------------------------------------------------
Local lRet := .F., cFiltAtWkW8


If cSel == "ONE"
   lRet := DI500SW8Get()
ElseIf cSel == "ALL"
   lRet := DI500MarcaAll('Work_SW8',oFBrw) 
EndIf

cFiltAtWkW8 := RescFilAtv(oFBrw)  //Recuperar os filtros acumulados no objeto FWBrowse da Work_SW8

If !Empty(cFiltAtWkW8)
   DBSELECTAREA("Work_SW8")
   SET FILTER TO &(cFiltAtWkW8)
   oFBrw:Refresh()
   oEnch2:Refresh()
EndIf

return lRet//cRet

/*
Função   : RescFilAtv(oFWBrw)
Autor    : Nilson César
Data     : 29/09/2020
Objetivo : Resgatar a expressão de filtro acumulado aplicado ao objeto FwBrowse da tabela Work_SW8
*/
*---------------------------------
Static Function RescFilAtv(oFWBrw)
*---------------------------------
Local cFilAcum := ""
Local i
Local aFilChecked := {}

If ValType(oFWBrw:oFWFilter:aFilter) == 'A'
   aEval(oFWBrw:oFWFilter:aFilter,{|x| If( x[6] , aAdd(aFilChecked,x) ,    )  })  //Recupera apenas filtros marcados para aplicação
   for i:=1 To Len(aFilChecked)           
      cFilAcum += aFilChecked[i][2]
      If i<Len(aFilChecked)
         cFilAcum += " .And. "
      EndIf  
   Next i
EndIf

Return cFilAcum 

/*
Função   : GetIndW8(oFWBrw)
Autor    : Nilson César
Data     : 29/09/2020
Objetivo : Retornar array com as chaves de índice da tabela temporária Work_SW8
*/
Static Function GetIndWKW8()

Local aRet := {"WKINVOICE+WKFORN" + If(EICLoja(), "+W8_FORLOJ", "") + "+WKPO_NUM+WKPOSICAO+WKPGI_NUM",;//1
               "WKFORN" + If(EICLoja(), "+W8_FORLOJ", "") + "+WKPO_NUM+WKPOSICAO+WKPGI_NUM",;          //2
               "WKADICAO+WKSEQ_ADI",;                                                                  //3
               "WKADICAO",;                                                                            //4
               "WKNVE",;                                                                               //5 // AWR - NVE
               "WKTEC",;                                                                               //6 // AWR - NVE
               "WKGRUPORT",;                                                                           //7 // AWR - 19/09/08 - NFE
               "WKPO_NUM",;                                                                            //8 // NCF - Melhoria na Seleção de itens da invoice (FWBrowse -  Work_SW8) - Nro. PO
               "WKCOD_I",;                                                                             //9 // NCF - Melhoria na Seleção de itens da invoice (FWBrowse -  Work_SW8) - Cód. Item
               "WKFABR"}                                                                               //10// NCF - Melhoria na Seleção de itens da invoice (FWBrowse -  Work_SW8) - Fabricante

Return aClone(aRet)

/*
Funcao     : Função que consulta se a Taxa Siscomex está habilitada pra despesa ICMS considerando também o estado
do importador
Parametros : 
Retorno    : .T./.F.
Autor      : Ramon Prado
Data       : Agosto/2021
*/
Static Function DI500TxICM(cImport)
Local cCpoBasICMS := ""
Local lTemYB_ICM_UF := .F.
Local lRet    := .F.
Local aArea   := GetArea()

SYT->(DBSETORDER(1))
SYT->(dBSeek(xFilial("SYT")+cImport))
cCpoBasICMS:="YB_ICMS_"+Alltrim(SYT->YT_ESTADO)
lTemYB_ICM_UF := SYB->(FIELDPOS(cCpoBasICMS)) # 0

IF SYB->(DBSEEK(XFILIAL("SYB")+cMV_CODTXSI)) .AND. lTemYB_ICM_UF .And. SYB->(FIELDGET(FIELDPOS(cCpoBasICMS))) $ cSim 
   lRet := SYB->YB_BASEICM $ cSim 
ELSE
   lRet := .F.
ENDIF

RestArea(aArea)
Return lRet

/*
Funcao     : ClassifNVE() - Utilizada para a classificacao da NVE ao selecionar invoice antecipada ou incluir invoice no processo
Parametros : lExibeMsg - Exibe ou não a msg de NVE para o item / lTemNVEPLI - Enviar .T. quando optar por não apresentar a mensagem (lExibeMsg=.F.) / lTemNVECad - lTemNVEPLI - Enviar .T. quando optar por não apresentar a mensagem (lExibeMsg=.F.)
Retorno    : .T. - Tem NVE na fase de PLI ou Cadastro de Produtos e foi efetuada a transferencia / .F. Nao tem NVE ou não foi efetuada a transferencia
Autor      : Tiago Henrique Tudisco dos Santos - THTS
Data       : 23/09/2021
*/
Static Function ClassifNVE(lCposNVEPLI,nTipoW9Manut,lPrimeiro,lMostMsgNVE,lTemNVEPLI,lTemNVECad)
Local lRet        := .F.
Local aAreaEIM    := SW6->(getArea())

Default lCposNVEPLI  :=  (EIM->(FIELDPOS("EIM_FASE")) # 0 .And. SW5->(FIELDPOS("W5_NVE")) # 0 )
Default nTipoW9Manut := 0

EIM->(DbSetOrder(3))
If lCposNVEPLI .And. EasyGParam("MV_EIC0011",,.F.) .And. lPrimeiro .And. !Empty(Work->WK_NVE) .And. (nTipoW9Manut == 1 .Or. nTipoW9Manut == 2)
   If MsgYesNo(STR0815 + CHR(13)+CHR(10)+; //"Existem itens marcados no processo que já possuem classificação"
               STR0816 + CHR(13)+CHR(10)+; //"N.V.A.E. vinda da fase de Pedido de Licença de Importação (LI)!"
               STR0817 , STR0558) //STR0817" Deseja importar as informações de N.V.A.E. para estes itens ?" STR0558 "Aviso"
      lTemNVEPLI := .T.
      lPrimeiro := .F.
   Else
      lPrimeiro := .F.
   EndIf
ElseIf lCposNVEPLI .And. EasyGParam("MV_EIC0011",,.F.) .And. lMostMsgNVE .And. Empty(Work->WK_NVE) .And. (nTipoW9Manut == 1 .Or. nTipoW9Manut == 2) .AND. EIM->(DbSeek(GetFilEIM("CD")+AvKey("CD","EIM_FASE")+AvKey(Work->WKCOD_I,"EIM_HAWB") )) .And. If(lEIM_NCM,AvKey(Work->WKTEC,"EIM_NCM")==EIM->EIM_NCM,.T.) 
   If MsgYesNo(STR0892 + ENTER + STR0817,STR0804)
      lTemNVECad  := .T.
      lMostMsgNVE := .F.
   Else
      lMostMsgNVE := .F.
   EndIf
EndIf

If lTemNVEPLI .AND. !Empty(Work->WK_NVE)
   Work_SW8->WKNVE := TransfNVE("LI")
   Work->WK_NVE := Work_SW8->WKNVE
   lRet := .T.
ElseIf lTemNVECad .AND. EIM->(DbSeek(GetFilEIM("CD")+AvKey("CD","EIM_FASE")+AvKey(Work->WKCOD_I,"EIM_HAWB")))

   Work_SW8->WKNVE := TransfNVE("CD")
   If !Empty(Work_SW8->WKFLAGIV)
      Work->WK_NVE := Work_SW8->WKNVE
   EndIf
   
   WORK_CEIM->(DbAppend())
   Work_CEIM->EIM_CODIGO := Work->WK_NVE
   Work_CEIM->WKTEC      := Work->WKTEC

   lGravaEIM := .T.
   lRet := .T.
EndIf

RestArea(aAreaEIM)

Return lRet


Static Function CarregaNVE()
//Tem NVE para o item
If !Empty(Work_SW8->WKNVE) .And. lCposNVEPLI  .And. EasyGParam("MV_EIC0011",,.F.)
   EIM->(DbSetOrder(3))//EIM_FILIAL, EIM_FASE, EIM_HAWB, EIM_CODIGO, EIM_NCM
   If EIM->(DbSeek(GetFilEIM("LI") + "LI" + AvKey(Work_SW8->WKPGI_NUM,"W6_HAWB") + Work_SW8->WKNVE))  //Verifica se tem NVE para a PLI
      If aScan(aTabsNVEDI,{|x| x[1] == Work_SW8->WKPGI_NUM .And. x[2] == Work_SW8->WKNVE  }) == 0
         aAdd(aTabsNVEDI,{Work_SW8->WKPGI_NUM, Work_SW8->WKNVE, Work_SW8->WKNVE})
      EndIf
   ElseIf EIM->(DbSeek(GetFilEIM("CD") + "CD" + AvKey(Work_SW8->WKCOD_I,"W6_HAWB") + Work_SW8->WKNVE))//Verifica se tem NVE para o Produto
      If aScan(aTabsNVEDI,{|x| x[1] == Work_SW8->WKCOD_I .And. x[2] == Work_SW8->WKNVE  }) == 0
         aAdd(aTabsNVEDI,{Work_SW8->WKCOD_I, Work_SW8->WKNVE, Work_SW8->WKNVE})
      EndIf
   EndIf
EndIf
Return

/*
Funcao     : VLotesLPCO
Objetivo   : Validar se há alterações de saldo a menor ou desmarcação ocorridos em itens de invoice de processo DUIMP
             que já possuam informação de Lotes\LPCO gravados para o processo.
Parametros : Nenhum
Retorno    : .T./.F.
Autor      : Nilson César
Data       : Setembro/2021
*/
Static Function VLotesLPCO(cQuery)
Local lRet := .F.

If Select("RSAltQtdW8") > 0
   RSAltQtdW8->(dbcloseArea())
EndIf

cQuery:= ChangeQuery(cQuery)
EasyQry(cQuery, "RSAltQtdW8")

If RSAltQtdW8->(!Eof()) .And. RSAltQtdW8->(!Bof())
   lRet := .T.
EndIf

Return lRet

/*
Funcao     : VLnDispChg
Objetivo   : Validar se existem linhas de SWV sem lote e LPCO informados que possam absorver a alteração de quantidade a menor
             realizada no item da invoice.
Parametros : Nenhum
Retorno    : Lógico
Autor      : Nilson César
Data       : Setembro/2021
*/
Static Function VLnDispChg(cQuery)

Local lRet   := .T.

If Select("RSAltQtdW8") == 0
   cQuery:= ChangeQuery(cQuery)
   EasyQry(cQuery, "RSAltQtdW8")
EndIf 

RSAltQtdW8->(DbGoTop())
Do While RSAltQtdW8->(!Eof()) .And. lRet

   cQuery := ""
   cQuery += "SELECT SUM(SWV.WV_QTDE) SUMQTDSWV "
   cQuery += "FROM "+RetSQLName("SWV")+" SWV "
   cQuery += "WHERE SWV.D_E_L_E_T_ = ' ' " 
   cQuery += "  AND SWV.WV_FILIAL  = '"+xFilial("SWV")+"' "
   cQuery += "	 AND SWV.WV_HAWB    = '"+M->W6_HAWB+"' "
   cQuery += "	 AND SWV.WV_INVOICE = '"+RSAltQtdW8->WKINVOICE+"' "
   cQuery += "	 AND SWV.WV_PO_NUM  = '"+RSAltQtdW8->WKPO_NUM +"' "
   cQuery += "	 AND SWV.WV_POSICAO = '"+RSAltQtdW8->WKPOSICAO+"' "
   cQuery += "  AND SWV.WV_LOTE    = ' ' "
   cQuery += "  AND( SELECT COUNT(*) " 
   cQuery += "       FROM "+RetSQLName("EKQ")+" EKQ2 "
   cQuery += "       WHERE EKQ2.D_E_L_E_T_ = ' ' " 
   cQuery += "       AND SWV.WV_FILIAL  = EKQ2.EKQ_FILIAL "
   cQuery += "       AND SWV.WV_HAWB    = EKQ2.EKQ_HAWB "
   cQuery += "       AND SWV.WV_INVOICE = EKQ2.EKQ_INVOIC "
   cQuery += "       AND SWV.WV_PO_NUM  = EKQ2.EKQ_PO_NUM "
   cQuery += "       AND SWV.WV_POSICAO = EKQ2.EKQ_POSICA "
   cQuery += "       AND SWV.WV_SEQUENC = EKQ2.EKQ_SEQUEN "
   cQuery += "       AND EKQ2.EKQ_LPCO <> '' ) = 0 "

   cQuery:= ChangeQuery(cQuery)
   EasyQry(cQuery, "LnWVDispAlt")

   If LnWVDispAlt->(Eof()) .Or. LnWVDispAlt->(Bof()) .Or. ( LnWVDispAlt->SUMQTDSWV == 0 .Or. LnWVDispAlt->SUMQTDSWV < RSAltQtdW8->DIFERENCA )
      lRet := .F.
      LnWVDispAlt->(DBCloseArea())
      EXIT
   EndIf

   LnWVDispAlt->(DBCloseArea())

   RSAltQtdW8->(DbSkip())
EndDo

Return lRet

/*
Funcao     : GetQryW8WV
Objetivo   : Retornar a string da query que verifica se há registros que tiveram quantidade do item na invoice alterado PARA MENOR 
             na manutenção atual e que possuam lotes gravados na manutenção de Lotes\LPCO.
Parametros : cOption - Se enviado com valor "CLOSE" fecha a área de trabalho da query caso esteja aberta.
Retorno    : Caracter
Autor      : Nilson César
Data       : Setembro/2021
*/
Static Function GetQryW8WV(cTypeQry,cOption)

Local cQuery := ''
Default cOption := ''

If cTypeQry == "1"   //Retorna registros de itens da invoice que tiveram quantidade alterada para menor

   cQuery += " SELECT DISTINCT WKSW8.WKINVOICE, WKSW8.WKPO_NUM, WKSW8.WKPOSICAO, WKSW8.WKPGI_NUM,WKSW8.WKFORN,WKSW8.W8_FORLOJ,WKSW8.WKQTDE,(SW8.W8_QTDE - WKSW8.WKQTDE) DIFERENCA"
   cQuery += " FROM "+TETempName("Work_SW8")+" WKSW8"
   cQuery += " INNER JOIN "+RetSQLName("SW8")+" SW8"
   //cQuery += "	ON  WKSW8.TRB_REC_WT = SW8.R_E_C_N_O_"
   cQuery += "		 ON  SW8.W8_FILIAL    = '"+xFilial("SW8")+"'" 
   cQuery += "		 AND SW8.W8_HAWB      = '"+M->W6_HAWB+"'"
   cQuery += "		 AND SW8.W8_INVOICE = WKSW8.WKINVOICE" 
   cQuery += "		 AND SW8.W8_PO_NUM  = WKSW8.WKPO_NUM" 
   cQuery += "		 AND SW8.W8_POSICAO = WKSW8.WKPOSICAO" 
   cQuery += "		 AND SW8.W8_PGI_NUM = WKSW8.WKPGI_NUM" 
   cQuery += "		 AND SW8.W8_FORN    = WKSW8.WKFORN" 
   cQuery += "		 AND SW8.W8_FORLOJ  = WKSW8.W8_FORLOJ" 
   cQuery += "	INNER JOIN " + RetSQLName("SWV") + " SWV"
   cQuery += "		 ON  SWV.WV_FILIAL    = '"+xFilial("SWV")+"'"             
   cQuery += "		 AND SWV.WV_HAWB      = '"+M->W6_HAWB+"'"
   cQuery += "		 AND WKSW8.WKINVOICE  = SWV.WV_INVOICE" 
   cQuery += "		 AND WKSW8.WKPO_NUM   = SWV.WV_PO_NUM"
   cQuery += "		 AND WKSW8.WKPOSICAO  = SWV.WV_POSICAO"
   cQuery += "		 AND WKSW8.WKPGI_NUM  = SWV.WV_PGI_NUM"
   cQuery += "		 AND WKSW8.WKFORN     = SWV.WV_FORN" 
   cQuery += "		 AND WKSW8.W8_FORLOJ  = SWV.WV_FORLOJ"
   cQuery += " WHERE WKSW8.D_E_L_E_T_ = ' '"
   cQuery += " AND WKSW8.WKFLAGIV <> ' '"
   cQuery += " AND SW8.D_E_L_E_T_ = ' '" 
   cQuery += " AND SWV.D_E_L_E_T_ = ' '"
   cQuery += " AND SW8.W8_QTDE > WKSW8.WKQTDE"

ElseIf cTypeQry == "2" //Retorna registros de itens da invoice que foram desmarcados na invoice e que possuem lote ou LPCO informado na rotina de vinculação.

   cQuery += " SELECT DISTINCT SW8.W8_INVOICE,WKSW8.WKINVOICE, WKSW8.WKPO_NUM, WKSW8.WKPOSICAO, WKSW8.WKPGI_NUM,WKSW8.WKFORN,WKSW8.W8_FORLOJ,WKSW8.WKQTDE,(SW8.W8_QTDE - WKSW8.WKQTDE) DIFERENCA" 
   cQuery += " FROM "+TETempName("Work_SW8")+" WKSW8" 
   cQuery += " INNER JOIN "+RetSQLName("SW8")+" SW8 "
   cQuery += "       ON  WKSW8.TRB_REC_WT = SW8.R_E_C_N_O_"
   cQuery += " INNER JOIN "+RetSQLName("SWV")+" SWV "
   cQuery += "       ON  SWV.WV_FILIAL    = '"+xFilial("SWV")+"'"		 
   cQuery += "       AND SWV.WV_HAWB      = '"+M->W6_HAWB+"'"		 
   cQuery += " 		AND SW8.W8_INVOICE   = SWV.WV_INVOICE"		 
   cQuery += "    	AND WKSW8.WKPO_NUM   = SWV.WV_PO_NUM"		 
   cQuery += " 		AND WKSW8.WKPOSICAO  = SWV.WV_POSICAO"		 
   cQuery += " 		AND WKSW8.WKPGI_NUM  = SWV.WV_PGI_NUM"		 
   cQuery += " 		AND WKSW8.WKFORN     = SWV.WV_FORN"		 
   cQuery += " 		AND WKSW8.W8_FORLOJ  = SWV.WV_FORLOJ" 	
   cQuery += " WHERE WKSW8.D_E_L_E_T_ <> ' '"
   cQuery += " AND SW8.D_E_L_E_T_ = ' '"
   cQuery += " AND SWV.D_E_L_E_T_ = ' '"
   cQuery += " AND ( SWV.WV_LOTE <> ' ' OR (SELECT COUNT(*)" 
   cQuery += "                             FROM "+RetSQLName("EKQ")+" EKQ2" 
   cQuery += " 							       WHERE EKQ2.EKQ_FILIAL = '"+xFilial("EKQ")+"'" 
   cQuery += " 							       AND   EKQ2.EKQ_HAWB   = SWV.WV_HAWB" 
   cQuery += " 							       AND   EKQ2.EKQ_INVOIC = SWV.WV_INVOICE" 
   cQuery += " 							       AND   EKQ2.EKQ_PO_NUM = SWV.WV_PO_NUM" 
   cQuery += " 							       AND   EKQ2.EKQ_POSICA = SWV.WV_POSICAO" 
   cQuery += " 							       AND   EKQ2.EKQ_SEQUEN = SWV.WV_SEQUENC" 
   cQuery += " 							       AND   EKQ2.EKQ_LPCO <> ' ' )  > 0 )"

EndIf

If cOption == 'CLOSE'
   If Select('RSAltQtdW8') > 0
      RSAltQtdW8->(dbcloseArea())
   EndIf
EndIf

Return cQuery

/*
Funcao     : RemoveFields
Objetivo   : Remover da tela de adições (e relacionadas) os campos criados especificamente para a DUIMP
Parametros : aFields - relação de campos que serão exibidos
             aRemove - campos da DUIMP que não devem ser exibidos
             lHeader - indica que a estrutura do array é de um aHeader
Retorno    : 
Autor      : wfs
Data       : Dez/2021
*/
Static Function RemoveFields(aFields, aRemove, lHeader)
Local i:= 0, nPos:= 0

      For i:= 1 to Len(aRemove)
         
         If lHeader
            nPos:= AScan(aFields, {|x| x[2] == aRemove[i]})
         Else
            nPos:= AScan(aFields, aRemove[i])
         EndIf

         If nPos > 0
            ADel(aFields, nPos)
            ASize(aFields, Len(aFields) - 1)
         EndIf

      Next i

Return

/*
Funcao     : SetRemoveFields()
Objetivo   : Retornar quais campos da tela de adições (e relacionadas) não devem ser exibidos, em virtude da DUIMP
Parametros : cAlias - indicar a tabela como parâmetro para definição dos campos
Retorno    : aRemove - campos da DUIMP que não devem ser exibidos
Autor      : wfs
Data       : Dez/2021
*/
Static Function SetRemoveFields(cAlias)
Local aRemove:= {}

   Do Case

      Case cAlias == "EIJ"
         aRemove:= {"EIJ_TINFO", "EIJ_TINFA", "EIJ_UNDEST", "EIJ_QTDECO", "EIJ_UNIDCO", "EIJ_DSCCIT", "EIJ_CNPJRZ", "EIJ_NOMIMP", "EIJ_IMPORT", "EIJ_VRSACP", "EIJ_IDPTCP", "EIJ_IDWV", "EIJ_VRSFOR", "EIJ_VRSFAB"}

      Case cAlias == "EIK"
         aRemove:= {"EIK_IDWV"}

      Case cAlias == "EIN"
         aRemove:= {"EIN_CODDED", "EIN_CODACR", "EIN_IDWV"}

      Case cAlias == "EJ9"
         aRemove:= {"EJ9_IDCERT", "EJ9_IDWV"}

   End Case

Return AClone(aRemove)

/*
Funcao     : DI500Filter()
Parametros : Nenhum
Retorno    : .T.
Objetivos  : Criar um filtro padrão do sistema
Autor      : Maurício Frison
Data/Hora  : Julho/2022
*/
Function DI500FILTER()
Local cTrbSW6 := getNextAlias()
Local cFilTemp := ''
Local cPar01   := ''
Local cPOs := "(W6_HAWB='' "
Local lRet := .F.
Local lRestored := FwIsInCallStack("RestoreFIlter")
Local lPergunte := .T. 


Pergunte('DI500FLTR', .F.)    
cPar01:= mv_par01

lPergunte := Pergunte('DI500FLTR', !lRestored)   

If !lPergunte 
   mv_par01:= cPar01
EndIf


//retorna todos os processos onde tenha algum item com o P.O. selecionado
//SELECT DISTINCT(SW6990.W6_HAWB) FROM SW6990 LEFT JOIN SW7990 ON (SW6990.W6_FILIAL=SW7990.W7_FILIAL AND SW6990.W6_HAWB = SW7990.W7_HAWB) WHERE SW7990.W7_PO_NUM = 'PO-6236-B'
If !Empty(mv_par01)
   lRet:=.T.
   BeginSql alias cTrbSW6
      SELECT
         DISTINCT(SW6.W6_HAWB) W6_HAWB 
      FROM
         %table:SW6% SW6 LEFT JOIN %table:SW7% SW7 ON (SW6.W6_FILIAL=SW7.W7_FILIAL AND SW6.W6_HAWB = SW7.W7_HAWB)
      WHERE
         SW6.W6_FILIAL= %xfilial:SW6% AND
         SW6.%notDel%  AND          
         SW7.W7_PO_NUM = %exp:mv_par01% AND
         SW7.%notDel%  
   EndSql

   DO WHILE (cTrbSW6)->(!Eof())
      cpos += " .OR. W6_HAWB== '" + (cTrbSW6)->W6_HAWB+"'"
      (cTrbSW6)->(DbSkip())
   EndDo   
   cPos += ')'
   (cTrbSW6)->(DbCloseArea())

   cOldFilter := SW6->(DbFilter())
   cFilTemp := cOldFilter + If(!Empty(cOldFilter) ," .And. " ,"" )  + cPOs 
EndIf
Return cFilTemp

/*
Funcao     : DI500VldPO()
Parametros : Nenhum
Retorno    : .T. se o P.O. informado existe e .F. se o P.O. informado não existe
Objetivos  : Valida se o PO existe
Autor      : Maurício Frison
Data/Hora  : Julho/2022
*/
Function DI500VldPO()
Local cPo
Local lRet := .T.
cPo := POSICIONE('SW2', 1, xFilial('SW2')+mv_par01, 'W2_PO_NUM')
if Empty(cPo)
   easyhelp(STR0931,STR0929,STR0932) //'Purchase Order não encontado', 'Aviso','Informe um Purchase Order válido'
   lRet := .F.
EndIf   
Return lRet

/*
Funcao     : ItemSemNCM()
Retorno    : .T. se tiver itens na work sem NCM preenchida / .F. se todos os itens da Work possuem NCM
Objetivos  : Validar se a Work de Itens do Processo possui algum item sem NCM preenchida
Autor      : Tiago Tudisco
Data/Hora  : Setembro/2022
*/
Static Function ItemSemNCM()
Local lRet  := .F.
Local cQuery:= GetNextAlias()
Local cTable:= '%' + TETempName('Work') + '%'

BeginSql Alias cQuery
   SELECT WKTEC
   FROM %Exp:cTable%
   WHERE	WKTEC = ' '
     AND %notDel%
EndSql

If (cQuery)->(!Eof())
   lRet := .T.
EndIf
(cQuery)->(DbCloseArea())

Return lRet

//------------------------------------------------------------------------------------//
//                     FIM DO PROGRAMA EICDI500.PRW
//------------------------------------------------------------------------------------//
