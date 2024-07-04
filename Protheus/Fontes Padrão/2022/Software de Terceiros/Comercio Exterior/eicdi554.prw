#INCLUDE "EICDI554.CH"
#Include "TOPCONN.ch"
//Funcao    :EICDI554  - Autor - AVERAGE-MJBARROS      - Data : 07/11/96
//Co-Autor  :ALEX WALLAUER  01/08/2000  - (Protheus V508)
//Descricao :Recebimento de Importacao ( Solicitacao de NFE)
//Uso       :SIGAEIC
//Revisão   : dez/2015 - implementação do rateio por adição.
//            Através do parâmetro MV_EIC0060, passa a ser possível informar as despesas base de ICMS que serão rateadas pela
//            quantidade de adições do processo. Os valores das despesas serão isoladas na variável nSomaDespRatAdicao.

//#INCLUDE "FiveWin.ch"
#include "Average.ch"
#DEFINE  NFE_PRIMEIRA  1
#DEFINE  NFE_COMPLEMEN 2
#DEFINE  NFE_UNICA     3
#DEFINE  CUSTO_REAL    4
#DEFINE  NFE_MAE       5
#DEFINE  NFE_FILHA     6
#DEFINE  COMPLEMENTO_VL 7
#DEFINE  NF_TRANSFERENCIA 9// AWR - 02/02/09 - NFT
#DEFINE  ENTER CHR(13)+CHR(10)

//JVR - 25/03/10 - movido para o inicio da função, para quando for chamado algumas funções de RdMake não de erro.
Static lSegInc  := SW9->(FIELDPOS("W9_SEGINC")) # 0 .AND. SW9->(FIELDPOS("W9_SEGURO")) # 0 .AND. ;
                   SW8->(FIELDPOS("W8_SEGURO")) # 0 .AND. SW6->(FIELDPOS("W6_SEGINV")) # 0 // EOB - 14/07/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)

*---------------------------*
Function EICDI554()
*---------------------------*
LOCAL aFixos:={ { AVSX3("W6_HAWB"   ,5) ,"W6_HAWB"   },; //"Processo"
                { AVSX3("W6_DI_NUM" ,5) ,"W6_DI_NUM" },; //"No. da D.I."
                { AVSX3("W6_ADICAOK",5) ,{|| IF(!SW6->W6_ADICAOK $ cSim,STR0262,STR0261)}},; //"1a. NFE"
                { AVSX3("W6_NF_ENT" ,5) ,"W6_NF_ENT" },; //"1a. NFE"
                { AVSX3("W6_DT_NF"  ,5) ,"W6_DT_NF"  },; //AWR 14/7/98 //"Dt 1a. NFE"
                { AVSX3("W6_NF_COMP",5) ,"W6_NF_COMP"},; //"1a. NFC"
                { AVSX3("W6_DT_NFC" ,5) ,"W6_DT_NFC" },; //AWR 14/7/98 //"Dt 1a. NFC"
                { AVSX3("W6_FOB_TOT",5) ,"W6_FOB_TOT"},; //"Total F.O.B."
                { AVSX3("W6_INLAND" ,5) ,"W6_INLAND" },; //"Inland"
                { AVSX3("W6_PACKING",5) ,"W6_PACKING"},; //"Packing"
                { AVSX3("W6_FRETEIN",5) ,"W6_FRETEIN"},; //"Frete Intl"
                { AVSX3("W6_DESCONT",5) ,"W6_DESCONT"} } //"Desconto"

Private _PictPrUn := ALLTRIM(X3Picture("WN_PRUNI")), _PictQtde := ALLTRIM(X3Picture("W3_QTDE"))
Private PICT_CPO03 :=  ALLTRIM(X3PICTURE("B1_POSIPI")) //_PictTec
Private PICT_CPO07 := _PictQtde//"@E 999,999,999.9999"
PRIVATE cCond:="If(Empty(SW6->W6_DI_NUM) .OR. .NOT.(SW6->W6_ADICAOK $ 'SY1'),.F.,.T.)"
PRIVATE cCadastro := STR0013 //"Recebimento de Importa‡Æo - NF"
Private lMV_NF_MAE  := EasyGParam("MV_NF_MAE",,.F.) //SVG - 30/10/2009 - Tratamento NF Mae e Filha
PRIVATE Work1File,Work1FileA,Work1FileB,Work1FileC,Work1FileD,Work1FileF,Work1FileG,Work1FileH,Work2File,Work3File,Work3FileA,Work4File,cFileWk,cFileWkA

PRIVATE aRotina := { }

aAdd(aRotina,{STR0014 ,"AxPesqui", 0 , 1}) //"Pesquisar"
aAdd(aRotina,{STR0015 ,"DI554NFE", 0 , 1}) //"P&rimeira"
aAdd(aRotina,{STR0016 ,"DI554NFE", 0 , 2}) //"Complementar"
aAdd(aRotina,{STR0017 ,"DI554NFE", 0 , 2}) //"Unica"
If lMV_NF_MAE
   aAdd(aRotina,{STR0311 ,"DI554NFE", 0 , 2}) //"Nota Mãe"   //SVG - 30/10/2009 - Tratamento NF Mae e Filha -
   aAdd(aRotina,{STR0312 ,"DI554NFE", 0 , 2}) //"Nota Filha" //SVG - 30/10/2009 - Tratamento NF Mae e Filha -
EndIf
aAdd(aRotina,{STR0018 ,"DI554NFE", 0 , 4}) //"Cus&to Realiz"

AADD(aRotina,{"Gera I.N. 68/86","EICDI155",0,4})

PRIVATE aDespesa:= {}
PRIVATE PICTICMS:=ALLTRIM(X3Picture("YD_ICMS_RE"))
PRIVATE aPos:= { 15,  1, 70, 540 }

SX6->(DBSETORDER(1))
cAntImp        := EasyGParam("MV_ANT_IMP",,"1")
lIntDraw       := EasyGParam("MV_EIC_EDC",,.F.) //Verifica se existe a integração com o Módulo SIGAEDC
lICMS_NFC      := EasyGParam("MV_ICMSNFC",,.F.)
lLote          := EasyGParam("MV_LOTEEIC",,"N") $ cSim
lExiste_Midia  := EasyGParam("MV_SOFTWAR",,"N") $ cSim
lRateioCIF     := EasyGParam("MV_RATCIF" ,,"N") $ cSim .Or. Upper(Alltrim(EasyGParam("MV_RATCIF" ,,"N"))) $ "VA"
lTemDespBaseICM:= SX3->(DBSEEK("WN_DESPICM"))//AWF - 11/06/2014//.AND. IF(lMV_EASYSIM,.T.,SX3->(DBSEEK("F1_DESPICM")) )
lTemF1_DESPICM := SX3->(DBSEEK("F1_DESPICM"))//AWF - 11/06/2014
aEnv_NFS       := {} //AWF - 16/06/2014 - PARA O LOGIX
lTemPendentes  := .F.//AWF - 16/06/2014 - PARA O LOGIX
lTemCposOri    := SWN->(FIELDPOS("WN_DOCORI")) # 0 .AND. SWN->(FIELDPOS("WN_SERORI")) # 0//AWF - 31/07/2014
lExiste_IPIPA  := IPIPauta() //ATENCAO: SX3->(DBSETORDER(1)) DENTRO DESTA FUNCAO

SA5->(DBSETORDER(3))
SW2->(DBSETORDER(1))

IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"MBROWSE"),)

//AvStAction("204",.F.)
//OAP - Substituição da chamda feita no antigo EICPOCO.
//IF EasyGParam("MV_EIC_PCO",,.F.)
   //IF !EasyGParam("MV_PCOIMPO",,.T.)//Se for importador é .T., e Adquirente é .F.
      //AADD(aRotina,{"Visualiza NFT","EICCO100(.F.,EasyGParam('MV_PCOIMPO',,.T.))",0,4})
   //ENDIF
//ENDIF

mBrowse(,,,,"SW6",aFixos,,,cCond)

SA5->(DBSETORDER(1))
SWZ->(DBSETORDER(1))
SWN->(DBSETORDER(1))
SF1->(DBSETORDER(1))
SD1->(DBSETORDER(1))
SX3->(DBSETORDER(1))
SW7->(DBSETORDER(1))
SW8->(DBSETORDER(1))
SW9->(DBSETORDER(1))
If lIntDraw
   ED4->(dbSetOrder(1))
   ED0->(dbSetOrder(1))
EndIf
DBSELECTAREA("SX3")

Return .T.
*----------------------------------------------------------*
Function DI554NFE(cAlias,nReg,nOpc,aLocExecAuto)
*----------------------------------------------------------*
LOCAL bDDIFor:={||AT(SWD->(LEFT(SWD->WD_DESPESA,1)),"129") = 0 .AND.;
                  IF(!lGravaWorks,Empty(SWD->WD_NF_COMP),;
                     SWD->WD_NF_COMP+SWD->WD_SE_NFC=cNota) }

LOCAL bDDIWhi:={||xFILIAL("SWD")==SWD->WD_FILIAL .AND. SWD->WD_HAWB == SW6->W6_HAWB}

LOCAL oDlg, nCoL1, nCoL2, nCoL3, nCoL4, I


Local aOrdSF1
Local aSldItSInv

SX3->(DbSetOrder(2))

Private lTemDespBaseICM:= SX3->(DBSEEK("WN_DESPICM"))//AWF - 11/06/2014//.AND. IF(lMV_EASYSIM,.T.,SX3->(DBSEEK("F1_DESPICM")) )
Private lTemF1_DESPICM := SX3->(DBSEEK("F1_DESPICM"))//AWF - 11/06/2014

Private lMV_NF_MAE  := EasyGParam("MV_NF_MAE",,.F.) //SVG - 30/10/2009 - Tratamento NF Mae e Filha

Private lExisteSEQ_ADI:= SW8->(FIELDPOS("W8_SEQ_ADI")) # 0 .AND.;
                         SWN->(FIELDPOS("WN_SEQ_ADI")) # 0 //AWR - 06/11/08 NFE
Private lMV_GRCPNFE:= EasyGParam("MV_GRCPNFE",,.F.) .AND.; //AWR - 06/11/08 - Indica se integracao vai gravar (T) ou não (F) os campos novos da NFE
        SWN->(FIELDPOS("WN_PREDICM")) # 0 .AND. SWN->(FIELDPOS("WN_DESCONI")) # 0 .AND.;
        SWN->(FIELDPOS("WN_VLRIOF"))  # 0 .AND. SWN->(FIELDPOS("WN_DESPADU")) # 0 .AND.;
        SWN->(FIELDPOS("WN_ALUIPI"))  # 0 .AND. SWN->(FIELDPOS("WN_QTUIPI"))  # 0 .AND.;
        SWN->(FIELDPOS("WN_QTUPIS"))  # 0 .AND. SWN->(FIELDPOS("WN_QTUCOF"))  # 0

PRIVATE lDespAuto:=.f., aDespExecAuto:={}, lCalcImpAuto := .F. // EOS

PRIVATE lSoGravaNF  :=.F.// AWR - 02/02/09 - So Grava a NF sem Tela
PRIVATE lSoEstornaNF:=.F.// AWR - 12/02/09 - So Estorna a NF sem Tela

Private cMV_NFFILHA := EasyGParam("MV_NFFILHA",,"0")

PRIVATE lSair:=.F.

//NCF-27/05/2010
//lICMS_Dif      := SWZ->( FieldPos("WZ_ICMSUSP") > 0  .And.  FieldPos("WZ_ICMSDIF") > 0  .And.  FieldPos("WZ_ICMS_CP") > 0  .And.  FieldPos("WZ_ICMS_PD") > 0  )  ;
                  //.And.  SWN->( FieldPos("WN_VICM_PD") > 0  .And.  FieldPos("WN_VICMDIF") > 0  .And.  FieldPos("WN_VICM_CP") > 0 )

PRIVATE lICMS_Dif  := SWZ->( FieldPos("WZ_ICMSUSP") > 0  .And.  FieldPos("WZ_ICMSDIF") > 0  .And.  FieldPos("WZ_ICMS_CP") > 0  .And.  FieldPos("WZ_ICMS_PD") > 0  )  ;
                  .And.  SWN->( FieldPos("WN_VICM_PD") > 0  .And.  FieldPos("WN_VICMDIF") > 0  .And.  FieldPos("WN_VICM_CP") > 0 );
                  .And. SW8->( FieldPos("W8_VICMDIF")) > 0 .And. SW8->( FieldPos("W8_VICM_CP")) > 0 .And. SW8->( FieldPos("W8_VLICMDV")) > 0

// EOB - 16/02/09
//lICMS_Dif2     := SWZ->( FieldPos("WZ_PCREPRE") ) > 0 .AND. SWN->( FieldPos("WN_PICM_PD") > 0  .And.  FieldPos("WN_PICMDIF") > 0  .And.  FieldPos("WN_PICM_CP") > 0 .And. FieldPos("WN_PLIM_CP") > 0 )

PRIVATE lICMS_Dif2     := SWZ->( FieldPos("WZ_PCREPRE") ) > 0 .AND. SWN->( FieldPos("WN_PICM_PD") > 0  .And.  FieldPos("WN_PICMDIF") > 0  .And.  FieldPos("WN_PICM_CP") > 0 .And. FieldPos("WN_PLIM_CP") > 0 );
                          .And.  SW8->( FieldPos("W8_PICMDIF")) > 0  .And. SW8->( FieldPos("W8_PICM_CP")) > 0 .AND. SW8->( FieldPos("W8_PCREPRE")) > 0 .And. SW8->( FieldPos("W8_ICMS_PD")) > 0

PRIVATE nNewVlIcm:= 0   //TRP - 13/03/2010
PRIVATE lRecalcIcms    := EasyGParam("MV_RECICMS",,.F.)  //TRP - 10/03/2010 - Parâmetro que define se a base e o valor do ICMS serão recalculados na nota.
Private lCposICMSPt :=  ( SB1->(FIELDPOS("B1_VLR_ICM")) # 0 .And.  SWZ->(FIELDPOS("WZ_TPPICMS")) # 0 .And. SW8->(FIELDPOS("W8_VLICMDV")) # 0  .And. EIJ->(FIELDPOS("EIJ_VLICMD")) # 0 )        //NCF - 11/05/2011- Campos do ICMS de Pauta

SF1->(DBSETORDER(5))
Private lTemPrimeira := SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+"1")) .Or. SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+"5"))
Private aDeletados:= {}, aEAIDeletados:= {} //EAI
Private cMv_ESPEIC := IF(cPaisLoc='BRA' ,EasyGParam("MV_ESPEIC",,'NFE'),'NF') // SVG - 06/07/2010 -
Private lCpoDtFbLt := AvFlags("DATA_FABRIC_LOTE_IMPORTACAO")
Private lEstornaBtn

IF aLocExecAuto == NIL
   lExecAuto:=.F.
   lDespAuto:=.F.
ELSE
   IF VALTYPE(aLocExecAuto) == "L"
      lExecAuto:=aLocExecAuto
   ELSE
      lExecAuto:= aLocExecAuto[1]
      If (lDespAuto:=aLocExecAuto[2])==.T.  // indica que os calculos de despesa devem ser baseados na tabela passada como parâmetro
         aDespExecAuto:=aLocExecAuto[3]
      Endif
      IF Len(aLocExecAuto) > 3
         lCalcImpAuto := aLocExecAuto[4]  // EOS
      ENDIF
      IF Len(aLocExecAuto) > 4
         lSoGravaNF := aLocExecAuto[5]  // AWR - 02/02/09 - So Grava a NF
      ENDIF
   ENDIF
ENDIF

//FSM 02/09/2011
If Type("lPesoBruto") == "U"
   lPesoBruto := .F.
EndIf

IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"VALIDA_PROCESSO"),)
IF lSair
   RETURN .T.
ENDIF

DBSELECTAREA("SW6")
IF EOF() .and. BOF()
   Return (.T.)
EndIf

Private lGeraNota := .F.  //JWJ - 26/10/2006

IF(EasyEntryPoint("EICDI554"), Execblock("EICDI554",.F.,.F.,"NFE_INICIO"),)

IF SW6->W6_TIPOFEC = "DA"  .And. !lGeraNota  //JWJ - 26/10/2006: Acrescentei o lGeraNota
   Help("",1,"AVG0000812")
// MSGSTOP(STR0286,STR0022)//"Nota Fiscal não pode gerada, Processo refere-se a uma D.A."
   RETURN .F.
ENDIF
If Type("lICMSCompl") == "U"
   lICMSCompl := .F.
EndIf
PRIVATE nDecPais:=MSDECIMAIS(1)
PRIVATE aDBF_Stru:={{"WKCOD_I"   ,"C",AVSX3("W7_COD_I",3),0},;
                    {"WKFLAG"    ,"C",02,0},;
                    {"WKTEC"     ,"C",10,0},;
                    {"WKEX_NCM"  ,"C",LEN(SB1->B1_EX_NCM),0},;
                    {"WKEX_NBM"  ,"C",LEN(SB1->B1_EX_NBM),0},;
                    {"WKACMODAL" ,"C",IF(lIntDraw,LEN(SW8->W8_AC),13),0},;
                    {"WKICMS_A"  ,"N",06,2},;
                    {"WKQTDE"    ,"N",18,7},;
                    {"WKPRECO"   ,"N",18,7},;
                    {"WKDESCR"   ,"C",60,0},;
                    {"WKUNI"     ,"C",03,0},;
                    {"WKREGTRII" ,"C",01,0},;
                    {"WKREGTRIPI","C",01,0},;
                    {"WKVLDEVII" ,"N",15,2},;
                    {"WKVLDEIPI" ,"N",15,2},;
                    {"WKIPIVAL"  ,"N",18,7},;
                    {"WKIIVAL"   ,"N",18,2},;
                    {"WKPRUNI"   ,"N",AVSX3("WN_PRUNI",3),AVSX3("WN_PRUNI",4)},;
                    {"WKVALMERC" ,"N",18,7},;
                    {"WKIPITX"   ,"N",06,2},;
                    {"WKIITX"    ,"N",06,2},;
                    {"WKRATEIO"  ,"N",AVSX3("WN_RATEIO",3),AVSX3("WN_RATEIO",4)},;
                    {"WKRATPESO" ,"N",18,16},;
                    {"WKRATQTDE" ,"N",18,16},;
                    {"WKVL_ICM"  ,"N",18,7},;
                    {"WKPESOL"   ,"N",AVSX3("WN_PESOL",3),AVSX3("WN_PESOL",4)},;
                    {"WKBASEII"  ,"N",18,7},;
                    {"WKIPIBASE" ,"N",18,7},;
                    {"WKFOB"     ,"N",18,7},;
                    {"WKFOB_R"   ,"N",18,7},;
                    {"WKFOB_ORI" ,"N",18,7},;
                    {"WKFOBR_ORI","N",18,7},;
                    {"WKSEGURO"  ,"N",18,7},;
                    {"WKCIF"     ,"N",18,7},;
                    {"WKCIF_MOE" ,"N",18,7},;
                    {"WKOUT_DESP","N",18,7},;
                    {"WKOUT_D_US","N",18,7},;
                    {"WKFRETE"   ,"N",18,7},;
                    {"WKSI_NUM"  ,"C",AVSX3("W7_SI_NUM",AV_TAMANHO),0},;// SO.:0026 OS.: 0222/02 FCD
                    {"WKPO_NUM"  ,"C",AvSx3("W7_PO_NUM",AV_TAMANHO),0},;
                    {"WKADICAO"  ,"C",03,0},;
                    {"WKPO_SIGA" ,"C",AVSX3("C7_NUM",AV_TAMANHO),0},;
                    {"WKFORN"    ,"C",LEN(SW7->W7_FORN),0},;//AWR 21/03/2001
                    {"WKFABR"    ,"C",LEN(SW7->W7_FABR),0},;
                    {"WKLOJA"    ,"C",LEN(SA2->A2_LOJA),0},;//AWR 21/03/2001
                    {"WKREC_ID"  ,"N",10,0},;
                    {"WK_CC"     ,"C",AVSX3("W7_CC",3),0},;//SO.:0026 OS.: 0222/02 FCD
                    {"WK_CFO"    ,"C",AVSX3("WZ_CFO",3),0},;
                    {"WK_NFE"    ,"C",AVSX3("D1_DOC",3),0},;
                    {"WK_NOTA"   ,"C",AVSX3("D1_DOC",3),0},;
                    {"WK_SE_NFE" ,"C",AVSX3("D1_SERIE",3),0},;
                    {"WK_DT_NFE" ,"D",08,0},;
                    {"WK_OPERACA","C",05,0},;
                    {"WKLI"      ,"C",10,0},;
                    {"WKPOSICAO" ,"C",LEN(SW3->W3_POSICAO),0},;
                    {"WKPOSSIGA" ,"C",LEN(SW3->W3_POSICAO),0},; // RA - 24/10/03 - O.S. 1076/03
                    {"WKPGI_NUM" ,"C",AvSx3("W7_PGI_NUM",AV_TAMANHO),0},;
                    {"WK_REG"    ,"N",AVSX3("W1_REG",3),0},;
                    {"WKDTVALID" ,"D",08,0},;
                    {"WK_LOTE"   ,"C",AvSx3("WV_LOTE",AV_TAMANHO),0},;
                    {"WK_VLMID_M","N",18,7},;
                    {"WK_VLMID_R","N",18,7},;
                    {"WK_QTMID"  ,"N",18,7},;
                    {"WKINVOICE" ,"C",AvSx3("W7_INVOICE",AV_TAMANHO),0},;
                    {"WKOUTDESP" ,"N",AVSX3("W8_OUTDESP",3),AVSX3("W8_OUTDESP",4)},;
                    {"WKINLAND"  ,"N",AVSX3("W8_INLAND" ,3),AVSX3("W8_INLAND" ,4)},;
                    {"WKPACKING" ,"N",AVSX3("W8_PACKING",3),AVSX3("W8_PACKING",4)},;
                    {"WKDESCONT" ,"N",AVSX3("W8_DESCONT",3),AVSX3("W8_DESCONT",4)},;
                    {"WKVLACRES" ,"N",AVSX3("W8_VLACRES",3),AVSX3("W8_VLACRES",4)},;
                    {"WKVLDEDU"  ,"N",AVSX3("W8_VLDEDU" ,3),AVSX3("W8_VLDEDU" ,4)},;
                    {"WKRDIFMID" ,"N",18,7},;
                    {"WKICMS_RED","N",09,6},;
                    {"WKICMSPC"  ,"N",09,6},;
                    {"WKUDIFMID" ,"N",18,7},;
                    {"WKDESPESA" ,"C",33,0},;
                    {"WKBASEICMS","N",18,7},;
                    {"WKVLUPIS"  ,"N",AVSX3("W8_VLUPIS",3),AVSX3("W8_VLUPIS",4)},;
                    {"WKBASPIS"  ,"N",18,7},;
                    {"WKPERPIS"  ,"N",06,2},;
                    {"WKVLRPIS"  ,"N",18,7},;
                    {"WKVLUCOF"  ,"N",AVSX3("W8_VLUCOF",3),AVSX3("W8_VLUCOF",4)},;
                    {"WKBASCOF"  ,"N",18,7},;
                    {"WKPERCOF"  ,"N",06,2},;
                    {"WKVLRCOF"  ,"N",18,7},;
                    {"WKRECMAE"  ,"N",10,0},;
                    {"WKQTDEUTIL","N",18,7},;
                    {"WKSLDDISP" ,"N",18,7},;
                    {"WKQTDEFILH","N",18,7}}



AADD(aDBF_Stru,{"WKDESPICM"  ,"N",If(lTemDespBaseICM,AVSX3("WN_DESPICM",3),AVSX3("W8_OUTDESP",3)),;
                                 If(lTemDespBaseICM,AVSX3("WN_DESPICM",4),AVSX3("W8_OUTDESP",4))})

AADD(aDBF_Stru,{"WKNVE",AVSX3("W8_NVE",AV_TIPO),AVSX3("W8_NVE",AV_TAMANHO),AVSX3("W8_NVE",AV_DECIMAL)})  // GFP - 20/09/2013 - Novo Layout NFE - (Nota técnica da NFe - 2013-005)
IF lExisteSEQ_ADI// AWR - 06/11/08 - NFE
   Aadd(aDBF_Stru,{"WKSEQ_ADI","C",LEN(SW8->W8_SEQ_ADI),0})
EndIf

IF lMV_GRCPNFE//Campos novos NFE - AWR 06/11/2008
   Aadd(aDBF_Stru,{"WKDESPADU","N",AVSX3("WN_DESPADU",AV_TAMANHO),AVSX3("WN_DESPADU",AV_DECIMAL)})
   Aadd(aDBF_Stru,{"WKALUIPI" ,"N",AVSX3("WN_ALUIPI" ,AV_TAMANHO),AVSX3("WN_ALUIPI" ,AV_DECIMAL)})
   Aadd(aDBF_Stru,{"WKQTUIPI" ,"N",AVSX3("WN_QTUIPI" ,AV_TAMANHO),AVSX3("WN_QTUIPI" ,AV_DECIMAL)})
   Aadd(aDBF_Stru,{"WKQTUPIS" ,"N",AVSX3("WN_QTUPIS" ,AV_TAMANHO),AVSX3("WN_QTUPIS" ,AV_DECIMAL)})
   Aadd(aDBF_Stru,{"WKQTUCOF" ,"N",AVSX3("WN_QTUCOF" ,AV_TAMANHO),AVSX3("WN_QTUCOF" ,AV_DECIMAL)})
   Aadd(aDBF_Stru,{"WKPREDICM","N",AVSX3("WN_PREDICM",AV_TAMANHO),AVSX3("WN_PREDICM",AV_DECIMAL)})
   Aadd(aDBF_Stru,{"WKDESCONI","N",AVSX3("WN_DESCONI",AV_TAMANHO),AVSX3("WN_DESCONI",AV_DECIMAL)})
   Aadd(aDBF_Stru,{"WKVLRIOF" ,"N",AVSX3("WN_VLRIOF" ,AV_TAMANHO),AVSX3("WN_VLRIOF" ,AV_DECIMAL)})
ENDIF

//NCF-27/05/2010
If lICMS_Dif  // PLB 14/05/07 - ICMS diferido
   AAdd( aDBF_Stru, {"WKVLICMDEV", "N", 18, 07 } )
   AAdd( aDBF_Stru, {"WKBASE_DIF", "N", 18, 07 } )
   AAdd( aDBF_Stru, {"WKVL_ICM_D", "N", 18, 07 } )
   AAdd( aDBF_Stru, {"WKVLCREPRE", "N", 18, 07 } ) // EOB - 16/02/09
EndIf
If lICMS_Dif2 // EOB - 16/02/09
   AAdd( aDBF_Stru, {"WK_PERCDIF", "N", AVSX3("WZ_ICMSDIF",AV_TAMANHO), AVSX3("WZ_ICMSDIF",AV_DECIMAL) } )
   AAdd( aDBF_Stru, {"WK_CRE_PRE", "N", AVSX3("WZ_ICMS_CP",AV_TAMANHO), AVSX3("WZ_ICMS_CP",AV_DECIMAL) } )
   AAdd( aDBF_Stru, {"WK_PCREPRE", "N", AVSX3("WZ_PCREPRE",AV_TAMANHO), AVSX3("WZ_PCREPRE",AV_DECIMAL) } )
   AAdd( aDBF_Stru, {"WK_PAG_DES", "N", AVSX3("WZ_ICMS_PD",AV_TAMANHO), AVSX3("WZ_ICMS_PD",AV_DECIMAL) } )
EndIf

Aadd(aDBF_Stru,{"WKNOTAOR"  ,"C",AVSX3("WN_DOC"   ,AV_TAMANHO),AVSX3("WN_DOC",AV_DECIMAL)})
Aadd(aDBF_Stru,{"WKSERIEOR" ,"C",AVSX3("WN_SERIE" ,AV_TAMANHO),AVSX3("WN_SERIE" ,AV_DECIMAL)})

//Numeração provisória
If AvFlags("EIC_EAI")
   AAdd(aDBF_Stru,{"WKNOTAPR" , AvSx3("WN_DOC"  , AV_TIPO), AvSx3("WN_DOC"  , AV_TAMANHO), AvSx3("WN_DOC"  , AV_DECIMAL)})
   AAdd(aDBF_Stru,{"WKSERIEPR", AvSx3("WN_SERIE", AV_TIPO), AvSx3("WN_SERIE", AV_TAMANHO), AvSx3("WN_SERIE", AV_DECIMAL)})
EndIf

//AWF - 17/06/14 - Logix
Aadd(aDBF_Stru,{"WK_OK"   ,"C",AVSX3("F1_OK"    ,AV_TAMANHO),AVSX3("F1_OK"    ,AV_DECIMAL)})
Aadd(aDBF_Stru,{"WKSTATUS","C",01,0})
//FSM - 02/09/2011 - Peso Bruto Unitario
If lPesoBruto
   aAdd( aDBF_Stru, {"WKPESOBR", AVSX3("W8_PESO_BR",AV_TIPO), AVSX3("W8_PESO_BR",AV_TAMANHO), AVSX3("W8_PESO_BR",AV_DECIMAL) } )
EndIf

IF lCposICMSPt                                                           //NCF - 11\05\2011 - Inclui o campo de ICMS devido para tratamento de ICMS de Pauta
   IF ( nPos := aScan(aDBF_Stru, {|x| x[1] == "WKVLICMDEV"}) ) == 0
      AAdd( aDBF_Stru, {"WKVLICMDEV", "N", 18, 07 } )
   ENDIF
ENDIF

If lCposCofMj                                                            //NCF - 20/07/2012 - Majoração COFINS
   AADD(aDBF_Stru,{"WKALCOFM"  ,"N",06,2})
   AADD(aDBF_Stru,{"WKVLCOFM"  ,"N",18,7})
EndIf
If lCposPisMj                                                            //GFP - 11/06/2013 - Majoração PIS
   AADD(aDBF_Stru,{"WKALPISM"  ,"N",06,2})
   AADD(aDBF_Stru,{"WKVLPISM"  ,"N",18,7})
EndIf

If SWN->(FieldPos("WN_AC")) # 0    // GFP - 20/09/2013 - Novo Layout NFE - (Nota técnica da NFe - 2013-005)
   AADD(aDBF_Stru,{"WKAC",AVSX3("W8_AC",AV_TIPO),AVSX3("W8_AC",AV_TAMANHO),AVSX3("W8_AC",AV_DECIMAL)})
EndIf

If SWN->(FieldPos("WN_AFRMM")) # 0    // GFP - 23/09/2013 - Novo Layout NFE - (Nota técnica da NFe - 2013-005)
   AADD(aDBF_Stru,{"WKAFRMM",AVSX3("WN_AFRMM",AV_TIPO),AVSX3("WN_AFRMM",AV_TAMANHO),AVSX3("WN_AFRMM",AV_DECIMAL)})
EndIf

//AAF 20/12/2016 - Criacao dos campos de valor devido de pis e cofins para calcular a base de icms nos casos de suspensão do imposto
AADD(aDBF_Stru,{"WKVLDEPIS","N",AVSX3("W8_VLDEPIS",3),AVSX3("W8_VLDEPIS",4)})
AADD(aDBF_Stru,{"WKVLDECOF","N",AVSX3("W8_VLDECOF",3),AVSX3("W8_VLDECOF",4)})

IF lCpoDtFbLt
   AADD(aDBF_Stru,{"WKDTFBLT","D",08,0} )
ENDIF

If AvFlags("ICMSFECP_DI_ELETRONICA")
   AADD(aDBF_Stru,{"WKALFECP",AVSX3("W8_ALFECP",AV_TIPO),AVSX3("W8_ALFECP",AV_TAMANHO),AVSX3("W8_ALFECP",AV_DECIMAL)})
   AADD(aDBF_Stru,{"WKVLFECP",AVSX3("W8_VLFECP",AV_TIPO),AVSX3("W8_VLFECP",AV_TAMANHO),AVSX3("W8_VLFECP",AV_DECIMAL)})
EndIf

If AVFLAGS("FECP_DIFERIMENTO")
   AADD(aDBF_Stru,{"WKFECPALD",AVSX3("W8_FECPALD",AV_TIPO),AVSX3("W8_FECPALD",AV_TAMANHO),AVSX3("W8_FECPALD",AV_DECIMAL)})
   AADD(aDBF_Stru,{"WKFECPVLD",AVSX3("W8_FECPVLD",AV_TIPO),AVSX3("W8_FECPVLD",AV_TAMANHO),AVSX3("W8_FECPVLD",AV_DECIMAL)})
   AADD(aDBF_Stru,{"WKFECPREC",AVSX3("W8_FECPREC",AV_TIPO),AVSX3("W8_FECPREC",AV_TAMANHO),AVSX3("W8_FECPREC",AV_DECIMAL)})
EndIf

AADD(aDBF_Stru,{"WKLINHA",AVSX3("WN_LINHA",AV_TIPO),AVSX3("WN_LINHA",AV_TAMANHO),AVSX3("WN_LINHA",AV_DECIMAL)})

PRIVATE aDBF_Stru2:={{"WKICMS_A"  ,"N",06,2},;
                     {"WKTEC"     ,"C",10,0},;
                     {"WKEX_NCM"  ,"C",LEN(SB1->B1_EX_NCM),0},;
                     {"WKEX_NBM"  ,"C",LEN(SB1->B1_EX_NBM),0},;
                     {"WKADICAO"  ,"C",03,0},;
                     {"WKPESOL"   ,"N",AVSX3("WN_PESOL",3),AVSX3("WN_PESOL",4)},;
                     {"WKFOB"     ,"N",18,7},;
                     {"WKFOB_R"   ,"N",18,7},;
                     {"WKFRETE"   ,"N",18,7},;
                     {"WKFOB_ORI" ,"N",18,7},;
                     {"WKFOBR_ORI","N",18,7},;
                     {"WKCIF_MOE" ,"N",18,7},;
                     {"WKSEGURO"  ,"N",18,7},;
                     {"WKCIF"     ,"N",18,7},;
                     {"WKII"      ,"N",18,7},;
                     {"WKIPI"     ,"N",18,7},;
                     {"WKICMS"    ,"N",18,7},;
                     {"WKOUTRDESP","N",18,7},;
                     {"WKOUTRD_US","N",18,7},;
                     {"WKII_A"    ,"N",06,2},;
                     {"WKIIREDU_A","N",06,2},;
                     {"WK_CFO"    ,"C",AVSX3("WZ_CFO",3),0},;
                     {"WK_OPERACA","C",05,0},;
                     {"WK_NF_COMP","C",AVSX3("D1_DOC",3),0},;
                     {"WK_SE_NFC" ,"C",AVSX3("D1_SERIE",3),0},;
                     {"WKVLACRES" ,"N",AVSX3("W8_VLACRES",3),AVSX3("W8_VLACRES",4)},;
                     {"WKVLDEDU"  ,"N",AVSX3("W8_VLDEDU" ,3),AVSX3("W8_VLDEDU" ,4)},;
                     {"WKBASEII"  ,"N",18,7},;
                     {"WK_DT_NFC" ,"D",08,0},;
                     {"WKIPI_A"   ,"N",06,2},;
                     {"WKRED_CTE" ,"N",09,6},;
                     {"WKICMS_RED","N",09,6},;
                     {"WKICMSPC"  ,"N",09,6},;
                     {"WKRDIFMID" ,"N",18,7},;
                     {"WKQTDE"    ,"N",18,7},;
                     {"WKREC_ID"  ,"N",10,0},;
                     {"WKUDIFMID" ,"N",18,7},;
                     {"WKBASPIS"  ,"N",18,7},;
                     {"WKVLRPIS"  ,"N",18,7},;
                     {"WKBASCOF"  ,"N",18,7},;
                     {"WKVLRCOF"  ,"N",18,7}}

PRIVATE aDBF_Stru3:={{"WKRECNO"   ,"N",10,0},;//PRIVATE POR CAUSA DA MERCK
                     {"WKDESPESA" ,"C",33,0},;
                     {"WKVALOR"   ,"N",18,7},;
                     {"WKVALOR_US","N",18,7},;
                     {"WK_NF_COMP","C",AVSX3("D1_DOC",3),0},;
                     {"WK_SE_NFC" ,"C",AVSX3("D1_SERIE",3),0},;
                     {"WK_DT_NFC" ,"D",08,0},;
                     {"WKPO_NUM"  ,"C",AvSx3("W2_PO_NUM", AV_TAMANHO),0},;
                     {"WKPOSICAO" ,"C",LEN(SW3->W3_POSICAO),0},;
                     {"WK_LOTE"   ,"C",AvSx3("WN_LOTECTL",AV_TAMANHO),0},;
                     {"WKPGI_NUM" ,"C",10,0}}//PRIVATE POR CAUSA DA MERCK

TB_Campos1:={}

nOldArea:=SELECT()

PRIVATE cTit:=""            // JONATO 24/11 - Trevo

PRIVATE PICT15_8:= '@E 999,999.99999999'
PRIVATE PICT15_2:= '@E 999,999,999,999.99'
PRIVATE PICT06_2:= '@E 999.99'
PRIVATE PICT1816:= '@E 9.9999999999999999'
PRIVATE PICT21_8:= _PictPrUn//'@E 999,999,999,999.9999'
PRIVATE PICTICMS:= AVSX3("YD_ICMS_RE",6)
//PRIVATE PICTPesoT:= AVSX3("B1_PESO",6)
//PRIVATE PICTPesoI:= AVSX3("B1_PESO",6)
PRIVATE PICTPesoT:= AVSX3("EIJ_PESOL",6)//ACB - 22/03/2011
PRIVATE PICTPesoI:= AVSX3("EIJ_PESOL",6)//ACB - 22/03/2011

PRIVATE lDisable:=.F., lGerouNFE:=.F.,TB_Campos2:={},nOpca := 0

PRIVATE cMarca := GetMark(), lInverte := .F., nContProc:= 0
PRIVATE MDI_FOB, MDI_FOB_R, MDI_FRETE, MDI_SEGURO, MDI_CIF, MDI_II, MDI_IPI,;
        MDI_ICMS, MDespesas,MDI_PESO:=0,MLin:=0,MDI_OUTR:=0,MDI_OU_US:=0,MDI_CIFPURO:=0 //LGS-19/07/2016
PRIVATE nTipoNF := nOpc

If lMV_NF_MAE // TDF - 25/03/10
   If(nOpc = 7, nTipoNF:=nOpc-3,If(nOpc!=5 .And. nOpc!=6,nTipoNF:=nOpc-1,nTipoNF:=nOpc))
Else
   nTipoNF:=nOpc-1
EndIf

Private lFilha := (nTipoNF = 6)

PRIVATE nNBM_CIF:=nNBM_II:=nNBM_IPI:=nNBM_ICMS:=0

PRIVATE tDI_II:=0, tDI_IPI:=0, tDI_ICMS:=0, n_II:=0, n_ValM:=0, n_TotNFE:=0,;
        n_IPI :=0, n_ICMS :=0, n_CIF:=0 , n_PIS :=0, n_COFINS:=0

PRIVATE DESPESA_FRETE:=EasyGParam("MV_D_FRETE"),DESPESA_SEGURO:=EasyGParam("MV_D_SEGUR"),;
        DESPESA_II   :=EasyGParam("MV_D_II"),   DESPESA_IPI   :=EasyGParam("MV_D_IPI"),;
        DESPESA_ICMS :=EasyGParam("MV_D_ICMS") ,DESPESA_PIS:="204",DESPESA_COF:="205"

PRIVATE nFob:=0,nFobTot:=0,nPesoL:=0,nPesoB:=0,nSomaNoCIF:=nSomaBaseICMS:=nPSomaBaseICMS:=0,; //FSM - 02/09/2011 - Peso Bruto Unitario
        aNBMm:={}, nSomaDespRatAdicao:= 0

PRIVATE nPSomaNoCIF:= 0

PRIVATE bDifere:={ |vDI,vNBM,tit| DI554MsgDif(.F.,vDI,vNBM,tit) },lComDiferenca:=.F.

PRIVATE oSayTotGe,aLista:={}

PRIVATE cDI_FOB, nFob_R:=0, n_Frete:=0, n_Seguro:=0

PRIVATE cNumNFE, cSerieNFE, dDtNFE

PRIVATE lDespBaseIcms := SW8->(FIELDPOS("W8_D_BAICM")#0)

PRIVATE nTotNFC      := 0   // ACL 10/06/05

Private lTemFilha    := SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+"6"))

PRIVATE lTipoCompl   := (nTipoNF == NFE_COMPLEMEN)  // trata particularidade da NF complementar Bete 24/11 - Trevo

PRIVATE aICMS_Dif    := {}  // EOB 16/02/09

Private lTemNFT             // By JPP - 24/07/2009  - 16:00
Private lNFFilha3:= .F. //LGS-05/05/2014-Variavel para NF Filha tipo 3

SYT->(DBSETORDER(1))
SYT->(dBSeek(xFilial("SYT")+SW6->W6_IMPORT))
cCpoBasICMS:="YB_ICMS_"+Alltrim(SYT->YT_ESTADO)
lTemYB_ICM_UF:=SYB->(FIELDPOS(cCpoBasICMS)) # 0
lMV_EASY_SIM  := EasyGParam("MV_EASY",,"N")=="S"
lMV_PIS_EIC   := EasyGParam("MV_PIS_EIC",,.F.) .AND. SW8->(FIELDPOS("W8_BASPIS")) # 0 .AND. SWN->(FIELDPOS("WN_BASPIS")) # 0
lMV_PIS_EIC    := lMV_PIS_EIC .AND. ((SW6->W6_DTREG_D >= CTOD("01/05/2004")) .or. EMPTY(SW6->W6_DTREG_D)) // DFS - Permitir que apareça a soma dos totais (PIS e COFINS) no Recebimento de Importação, se a data de D.I estiver em branco no Desembaraço
lIntDraw      := EasyGParam("MV_EIC_EDC",,.F.) //Verifica se existe a integração com o Módulo SIGAEDC
lSomaDifMidia := EasyGParam("MV_DIFMIDI",,.T.)
PRIVATE lNFAutomatica  :=ALLTRIM(EasyGParam("MV_NF_AUTO")) $ cSim
PRIVATE lQuebraOperacao:=ALLTRIM(EasyGParam("MV_QB_OPER")) $ cSim
PRIVATE cQbrACModal    :=EasyGParam("MV_QBACMOD",,"1")
Private lIn327 := EasyGParam("MV_IN327" ,,.F.) // Bete - 24/02/05
PRIVATE cCpoBsPis:=cCpoVlPis:=cCpoBsCof:=cCpoVlCof:=cCpoAlPis:=cCpoAlCof:=""
Private aCposWork4 := {}      // GFP - 28/06/2013 - Variavel para ponto de entrada.
PRIVATE lDataDesmb := .T. //LRS -09/02/2015 - Validação para o campo DT Desembaraço vazio, para ponto de entrada.

IF(EasyEntryPoint("EICDI154"),Execblock("EICDI154",.F.,.F.,"DT_DESEMBARACO"),) // LRS - 09/02/2015 - Ponto de entrada para Mudar o valor da Variavel lDataDesemb
IF lDataDesmb
	If nTipoNF <> CUSTO_REAL .AND. Empty(SW6->W6_DT_DESE) // GFP - 05/03/2014
	   MsgStop(STR0361,STR0022) // "É necessário que o campo 'Dt. Desembaraço' esteja preenchido para a geração da NF."  ### "Atenção"
	   Return .F.
	EndIf
EndIF

IF nTipoNF == CUSTO_REAL .AND. SW6->W6_IMPCO == "1" .AND. (Empty(SW6->W6_NF_ENT) .OR. Empty(SW6->W6_SE_NF))  // GFP - 03/11/2014
   EasyHelp(STR0362)  //"Não é possível efetuar o Custo Realizado pois este processo de Conta e Ordem não possui Nota Fiscal gerada."
   RETURN .F.
ENDIF
//RRV - 25/02/2013
IF nTipoNF == NFE_COMPLEMEN
   lDifCamb     := SUBSTR(EasyGParam("MV_EIC0025",,"SSSS"),1,1) $ cSim
ELSEIF nTipoNF == NFE_UNICA .OR. nTipoNF == CUSTO_REAL
   If nTipoNF == NFE_UNICA
      If DI154CompValor(SW6->W6_HAWB) .And. DI154TemDspProc(SW6->W6_HAWB, "B") //LGS-02/06/2016
         nTipoNF   := NFE_PRIMEIRA
         MsgInfo(StrTran(STR0373,"XX",Alltrim(SYT->YT_ESTADO)),STR0022)
      Else
         lDifCamb  := SUBSTR(EasyGParam("MV_EIC0025",,"SSSS"),2,1) $ cSim
      EndIf
   Else
      lDifCamb  := SUBSTR(EasyGParam("MV_EIC0025",,"SSSS"),3,1) $ cSim
   Endif
ELSEIF nTipoNF = NF_TRANSFERENCIA// AWR - 02/02/09 - NFT
   lDifCamb  := SUBSTR(EasyGParam("MV_EIC0025",,"SSSS"),4,1) $ cSim
ENDIF

IF lMV_PIS_EIC .AND. lMV_EASY_SIM
   aRelImp  := MaFisRelImp("MT100",{ "SD1" })
   If !Empty( S:= aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_BASEPS2"} ) )
      cCpoBsPis:= aRelImp[S,2]
   EndIf
   If !Empty( S:= aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_VALPS2"} ) )
      cCpoVlPis:= aRelImp[S,2]
   EndIf
   If !Empty( S:= aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_BASECF2"} ) )
      cCpoBsCof:= aRelImp[S,2]
   EndIf
   If !Empty( S:= aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_VALCF2"} ) )
      cCpoVlCof:= aRelImp[S,2]
   EndIf
   If !Empty( S:= aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_ALIQPS2"} ) )
      cCpoAlPis:= aRelImp[S,2]
   EndIf
   If !Empty( S:= aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_ALIQCF2"} ) )
      cCpoAlCof:= aRelImp[S,2]
   EndIf
   IF EMPTY(cCpoBsPis) .OR. EMPTY(cCpoVlPis) .OR. EMPTY(cCpoBsCof) .OR. EMPTY(cCpoVlCof)
      MSGINFO(STR0346+; //STR0346 "Os campos de PIS/COFINS nao estao todos definidos: "
              CHR(13)+CHR(10)+"IT_BASEPS2 ==> "+cCpoBsPis+;
              CHR(13)+CHR(10)+"IT_VALPS2  ==> "+cCpoVlPis+;
              CHR(13)+CHR(10)+"IT_BASECF2 ==> "+cCpoBsCof+;
              CHR(13)+CHR(10)+"IT_VALCF2  ==> "+cCpoVlCof+;
              CHR(13)+CHR(10)+"IT_ALIQPS2 ==> "+cCpoAlPis+;
              CHR(13)+CHR(10)+"IT_ALIQCF2 ==> "+cCpoAlCof)
      RETURN .F.
   ENDIF
EndIf

SW7->(DbSeek(xFilial("SW7")+SW6->W6_HAWB))
lCurrier   := SW6->W6_CURRIER $ cSim
lGravaWorks:=.F.
lTemComplem:=.F.
lNaoTemComp:=.T.
lTemPauta  :=.F.
cNota      :=''
cMoeDolar  :=BuscaDolar()//EasyGParam("MV_SIMB2")
cMoeDolar  :=IF(EMPTY(cMoeDolar),"US$",cMoeDolar)
lRatFretePorFOB:=lRatFreQtde:=.F.//Variavel usada no rdmake para o Mercosul
SWZ->(DBSETORDER(2))
SWN->(DBSETORDER(2))
SF1->(DBSETORDER(5))
EI1->(DBSETORDER(1))
Private lTemCusto    := EI1->(DBSEEK(xFilial("EI1")+SW6->W6_HAWB))
Private nVlrCustoSWN := 0

lLoop := .F.   // Bete 05/12 - Trevo

aOrdSF1 := SaveOrd({"SF1"})

IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"INICIA_VARIAVEIS"),)

lTemNFT:=.F. // By JPP - 24/07/2009 - 16:00 - Inclusão dos tratamentos para gerar nota fiscal complementar de transferência de posse.
             // Se existir nota fiscal de transferência de posse, a variável lTemNFT passará a ser .T.
             // As alterações serão realizadas pela função AvStAction("205",.F.) que rodará a função U_EICPOCO passando como parâmetro a ação "205".

//AvStAction("205",.F.)
//OAP - Substituição da chamda feita no antigo EICPOCO + Adaptação(Ver chamada no EICDI154)
IF EasyGParam("MV_EIC_PCO",,.F.)
   IF !lExecAuto .AND. !lSoGravaNF .AND. !EasyGParam("MV_PCOIMPO",,.T.) .AND. !EMPTY(SW6->W6_IMPCO)//Se for importador é .T., e Adquirente é .F.
      IF nTipoNF == NFE_PRIMEIRA .OR. nTipoNF == NFE_UNICA .OR. (lMV_NF_MAE .And. nTipoNF == NFE_MAE)
         IF SW6->W6_IMPCO == '1'
            MSGINFO(STR0351) //STR0351 "Processo Por Conta e Ordem nao pode gerar NFE."
            lLoop:=.T.
         ENDIF
      ELSE
      // By JPP - 24/07/2009 - 16:00 - Inclusão dos tratamentos para gerar nota fiscal complementar de transferência de posse.
         SF1->(DbSetOrder(5))
         lTemNFT:=SF1->(DbSeek(xFilial("SF1")+SW6->W6_HAWB+"9"))
         RestOrd(aOrdSF1)
      ENDIF
   ENDIF
ENDIF

IF lLoop       // Bete 05/12 - Trevo
   RETURN .F.
ENDIF

IF SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+STR(nTipoNF,1,0))) .OR.;
   (nTipoNF == CUSTO_REAL .AND. ;
   EI1->(DBSEEK(xFilial("EI1")+SW6->W6_HAWB)))
   IF (nTipoNF==NFE_PRIMEIRA .OR. nTipoNF==NFE_UNICA .OR. (lMV_NF_MAE .And. nTipoNF == NFE_MAE) ) .AND.;
      SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+"2"))
      lTemComplem:=.T.
   ENDIF
   SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+STR(nTipoNF,1,0)))
   lGravaWorks:=.T.
   cNota :=SF1->F1_CTR_NFC//Nota + Serie
ELSEIF !lSoGravaNF// AWR - 02/02/09 - So Grava a NF
/* IF nTipoNF==NFE_PRIMEIRA .OR. nTipoNF==NFE_UNICA .Or. (lMV_NF_MAE .And. nTipoNF == NFE_MAE)
      IF !Empty(SW6->W6_NF_ENT)
         IF nTipoNF==NFE_PRIMEIRA .AND. SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB + "3"))
            Help("",1,"AVG0000800")//"Processo possui Nota Fiscal Unica"###"Atenção"
            RETURN .F.
         ELSEIF (nTipoNF==NFE_PRIMEIRA .OR. nTipoNF==NFE_UNICA) .AND. SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB + "5"))
            Alert(STR0352) //STR0352 "Processo possui Nota Fiscal Mãe."
            RETURN .F.
         ELSEIF (nTipoNF==NFE_UNICA .OR. (lMV_NF_MAE .And. nTipoNF==NFE_MAE) .OR. (lMV_NF_MAE .And. nTipoNF==NFE_FILHA)) .AND. SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB + "1"))
            Help("",1,"AVG0000801")//"Processo possui Primeira Nota Fiscal"###"Atenção"
            RETURN .F.
         ELSEIF ((lMV_NF_MAE .And. nTipoNF==NFE_MAE) .OR. (lMV_NF_MAE .And. nTipoNF==NFE_FILHA)) .And. SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB + "3"))
            Help("",1,"AVG0000800")
            RETURN .F.
         ENDIF
      ENDIF
   ENDIF
ELSE*/

   IF nTipoNF==NFE_PRIMEIRA .OR. nTipoNF==NFE_UNICA .Or. nTipoNF == NFE_MAE
      IF !Empty(SW6->W6_NF_ENT)
         IF nTipoNF==NFE_PRIMEIRA  .AND. SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+"3"))
            Help("",1,"AVG0000800")
            Return .F.
         ELSEIF (nTipoNF==NFE_PRIMEIRA .OR. nTipoNF==NFE_UNICA) .AND. SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+"5"))
            Alert(STR0316)
            RETURN .F.
         ELSEIF (nTipoNF==NFE_UNICA .OR. (lMV_NF_MAE .And. nTipoNF == NFE_MAE) .OR. (lMV_NF_MAE .And. nTipoNF == NFE_FILHA) ) .AND. SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+"1"))
            Help("",1,"AVG0000801")//"Processo possui Primeira Nota Fiscal"###"Atenção"
            Return .F.
         ELSEIF ((lMV_NF_MAE .And. nTipoNF == NFE_MAE) .OR. (lMV_NF_MAE .And. nTipoNF == NFE_FILHA)) .And. SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+"3"))
            Help("",1,"AVG0000800")
            Return .F.
         ENDIF
      ENDIF

      If EasyGParam("MV_EIC0057",,.F.)
         aSldItSInv := DI154SdInv(SW6->W6_HAWB)    //NCF - 20/12/2018 - Valida se existem itens com saldo sem invoice quando usuário está com parâmetro MV_EIC0057 habilitado.
         IF aSldItSInv[1]
            EasyHelp( aSldItSInv[2] , STR0022  )
            RETURN .F.
         EndIf
      EndIf

   ELSEIF nTipoNF==NFE_COMPLEMEN
      IF !SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+"1")) .AND.;// Bete 30/11 - Trevo
         !SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+"3")) .AND.;
         !SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+"5"))
            Help(" ",1,"DI154NOTA1")
            Return .F.
      ENDIF

   ELSEIF lMV_NF_MAE .And. nTipoNF == NFE_FILHA
      IF !SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+"5")) .And. !SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+"3")) .And. !SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+"1")) //SVG - 07/04/2011 - Nota fiscal filha a partir da nota primeira , unica ou mãe.
         MSGINFO(STR0314) //"Conhecimento não Possui Nota Mãe."
         Return .F.
      ENDIF
   ENDIF

   IF nTipoNF = NFE_COMPLEMEN .OR. (lMV_NF_MAE .And. nTipoNF = NFE_FILHA)
      IF !DI154Logix(.T.)
         Return .F.
      ENDIF
   ENDIF
   //Jacomo Lisa - 08/08/2014 -- Incluida a validação qndo for integrado com o Logix, não permitir gerar notas fiscais quando tiverem embarques pendentes
   IF AvFlags("EIC_EAI") .AND. STR(nTipoNF,1,0) $ "1/3/5" .And.;//Primeira/Unica/Mãe
      !AvFlags("EAI_PGANT_INV_NF")

      IF SW6->W6_TITOK == "2"
         MSGALERT(STR0363, STR0022) //"Processo possui integração de invoices pendente com o ERP. Processe a integração primeiro para que seja possivel gerar a nota fiscal.", "Atenção"
         Return .F.
      ENDIF
   ENDIF
ENDIF

If nTipoNF == NFE_FILHA //LGS-05/05/14 - So quando for NF Filha que pode setar a variavel de verificação da nova regra.
   lNFFilha3 := IF (EasyGParam("MV_NFFILHA",,"0")=="3",.T.,.F.)
EndIf

IF !lGravaWorks
   SW8->(DBSETORDER(1))
   SW9->(DBSETORDER(3))
   IF !SW8->(DBSEEK(xFilial("SW8")+SW6->W6_HAWB)) .OR.;
      !SW9->(DBSEEK(xFilial("SW9")+SW6->W6_HAWB))
      Help("",1,"AVG0000813")
//    MSGSTOP("Nota Fiscal nao pode ser gerada, Processo nao possui Invoices.",STR0022)
      RETURN .F.
   ENDIF

   // GCC - 27/12/2013 - Permitir que o custo realizado possa ser impresso sem o número da DI
   If nTipoNF <> CUSTO_REAL
      IF EMPTY(SW6->W6_DI_NUM) .AND. !lCurrier                      //NCF - 03/11/2009 - adicionada a verificação de Currier para validação
         Help(" ",1,"DI154SEMDI")//Processo nao possui D.I.         //                   da mensagem.
         Return .F.
      EndIf
   EndIf

   // SVG - 13/05/2010 -
   If lCurrier .And. Empty(SW6->W6_DIRE) .And. (Empty(SW6->W6_DT_DESE) .Or. Empty(SW6->W6_LOCAL))//FDR - 08/08/12 - Incluso na validação campo do DIRE
      MsgInfo(STR0317)
      Return .F.
   EndIf

   If nTipoNF <> CUSTO_REAL  // GFP - 13/01/2014 - Permitir que o custo realizado possa ser impresso sem adições cadastradas
      IF !EIJ->(DBSEEK(xFilial()+SW6->W6_HAWB)) .OR. EIJ->EIJ_ADICAO == "MOD"
         Help("",1,"AVG0000817")
//      MSGINFO(0288,0022) //"Processo nao possui Adicoes."
         Return .F.
      ENDIF
   EndIf

   If nTipoNF <> CUSTO_REAL  // GFP - 13/01/2014 - Permitir que o custo realizado possa ser impresso sem adições cadastradas
      IF !SW6->W6_ADICAOK $ cSim
         Help("",1,"AVG0000818")
//      MSGINFO(0289,0022) //"As Adicoes do Processo nao estao Corretas."
         Return .F.
      ENDIF
   EndIf
ENDIF

aNFsCompCtr:={}

IF (nTipoNF == NFE_COMPLEMEN .Or. (lMV_NF_MAE .And. nTipoNF == NFE_FILHA)) .AND. SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+STR(nTipoNF,1,0)))//!Empty(SW6->W6_NF_COMP)

   lGravaWorks:=.F.

   aNFsComp   :={}
   TB_Campos  :={}

   AADD(TB_CAMPOS,{{||WorkNF->F1_DOC+" "+Transform(WorkNF->F1_SERIE,AvSX3("F1_SERIE",AV_PICTURE))},,(STR0027)}) //"N§ Nota Fiscal"
   AADD(TB_CAMPOS,{"F1_FORNECE" ,,STR0084}) //"Fornecedor"
   AADD(TB_CAMPOS,{"F1_EMISSAO" ,,STR0029}) //"Data NF"
//   AADD(TB_CAMPOS,{"F1_DESPESA" ,,STR0030,AVSX3("F1_DESPESA")[6]}) //"Valor NF"

   aCampos:={"F1_DOC","F1_SERIE","F1_EMISSAO","F1_DESPESA","F1_CTR_NFC","F1_FORNECE","F1_LOJA"}

   WorkNFile:=E_CriaTrab(,,"WorkNF")

   bWhi:={||SF1->F1_TIPO_NF == STR(nTipoNF,1,0) .AND. SF1->F1_HAWB == SW6->W6_HAWB}

   bFor:={||IncProc(STR0273+' '+SF1->F1_DOC),ASCAN(aNFsComp,{|N|N[1]==SF1->F1_DOC.AND.N[2]==SF1->F1_SERIE.AND.N[6]==SF1->F1_FORNECE})=0} //"Lendo Despesa: "

   bGrv:={||ProcRegua(SF1->(LASTREC())),;
   SF1->(DBEVAL({||AADD(aNFsComp,{SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_EMISSAO,SF1->F1_DESPESA,SF1->F1_CTR_NFC,SF1->F1_FORNECE,SF1->F1_LOJA,SF1->(Recno())})},;
                bFor,bWhi))}

   SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+STR(nTipoNF,1,0)))
   SA2->(DbSeek(xFilial("SA2")+SF1->F1_FORNECE)) // RHP

   Processa(bGrv,STR0031) //"Processando..."

   cNota:= "" //AWF - 16/06/2014
   nRecWork:=0//AWF - Controle para ver se vai te tela - 16/06/2014

   FOR I:= 1 TO LEN(aNFsComp)
       WorkNF->(DBAPPEND())
       WorkNF->F1_DOC     :=aNFsComp[I][1]
       WorkNF->F1_SERIE   :=aNFsComp[I][2]
       WorkNF->F1_EMISSAO :=aNFsComp[I][3]
       WorkNF->F1_DESPESA :=aNFsComp[I][4]
       WorkNF->F1_CTR_NFC :=aNFsComp[I][5]
       IF ASCAN(aNFsCompCtr,aNFsComp[I][5])=0
          AADD (aNFsCompCtr,aNFsComp[I][5])
       ENDIF
       WorkNF->F1_FORNECE :=aNFsComp[I][6]
       WorkNF->F1_LOJA    :=aNFsComp[I][7]

       IF AvFlags("EIC_EAI")//AWF -  REQ 6 16/06/2014
          SF1->(DBGOTO( aNFsComp[I][8] ))
          IF SF1->F1_OK = "0"
             lTemPendentes:=.T.
             nRecWork:= WorkNF->(RECNO())
             EXIT
          ENDIF
       ENDIF

   NEXT

   nOpca:=0
   WorkNF->(DBGOTOP())

   IF nRecWork = 0 //AWF - 16/06/2014

      DEFINE MSDIALOG oDlg TITLE STR0032 FROM 5,5 TO 22,98 Of oMainWnd //"Nota Fiscal"
      @ 00,00 MsPanel oPanel Prompt "" Size 60,20 of oDlg
      @4.2,24 BUTTON STR0033  SIZE 38,12 ACTION (nOpca:=2,oDlg:End()) OF oPanel Pixel //"&Inclui"

      @4.2,140 BUTTON STR0034 SIZE 38,12 ACTION (nOpca:=1,oDlg:End()) OF oPanel Pixel//"&Estorna"

/* SVG - 24/05/2011 - Não se trata de work especifica da tabela, o que ocasiona erros devido a campos de usuario não inseridos na work.
      //by GFP - 29/09/2010 :: 14:23 - Inclusão da função para carregar campos criados pelo usuario.
      TB_Campos := AddCpoUser(TB_Campos,"SF1","2")
*/
      oMarkNF:=MsSelect():New("WorkNF",,,TB_Campos,@lInverte,@cMarca,{33,5,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2})
      oMarkNF:bAval:={||nOpca:=1,oDlg:End()}

	  oPanel:Align:=CONTROL_ALIGN_TOP
	  oMarkNF:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT

      ACTIVATE MSDIALOG oDlg ON INIT ;
            (EnchoiceBar(oDlg,{||nOpca:=2,oDlg:End()},;
                             {||nOpca:=0,oDlg:End()}),;
            oMarkNF:oBrowse:Refresh()) CENTERED //LRL 08/04/04 -Alinhamento MDI. //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   ELSE

      WorkNF->(DBGOTO(nRecWork))//AWF - 16/06/2014
      nOpca := 1//AWF - 16/06/2014

   ENDIF

   IF nOpca==1

      cNota :=WorkNF->F1_CTR_NFC//Nota + Serie
      cChave:=WorkNF->F1_DOC+WorkNF->F1_SERIE+WorkNF->F1_FORNECE+WorkNF->F1_LOJA+" (SWN) "
      If SWN->(DbSeek(xFilial()+WorkNF->F1_DOC+WorkNF->F1_SERIE+WorkNF->F1_FORNECE+WorkNF->F1_LOJA))//AWR 21/03/2001
         lGravaWorks:=.T.
      ELSE
         MSGINFO(STR0035+cChave+STR0036,STR0022) //"Nota Fiscal Complementar: "###" nÆo encontrada"###"Atenção"
         WorkNF->(E_EraseArq(WorkNFile))
         DBSELECTAREA("SW6")
         Return .F.
      ENDIF

   ELSEIF nOpca == 0

      WorkNF->(E_EraseArq(WorkNFile))
      DBSELECTAREA("SW6")
      Return .F.

   ELSEIF nOpca == 2

      lNaoTemComp:=.F.

   ENDIF

   WorkNF->(E_EraseArq(WorkNFile))
   DBSELECTAREA("SW6")
   aCampos:={}

ENDIF

ICMS_NFC:= EasyGParam("MV_ICMSNFC",,.F.)
lICMSCompl:= nTipoNF==NFE_COMPLEMEN

//	IF nTipoNF == NFE_COMPLEMEN .AND. lICMS_NFC .AND. !lGravaWorks
IF lICMSCompl .AND. lICMS_NFC .AND. !lGravaWorks   // Bete 24/11 - Trevo
   lICMS_NFC:=MSGYESNO(STR0364) //"Deseja calcular I.C.M.S. para Nota Fiscal Complementar?"
ENDIF


If ! SW6->(RecLock("SW6",.F.))
   Help(" ",1,"REGNLOCK")
   SW6->(MsUnlock())
   Return .F.
Endif

SW7->(DbSeek(xFilial("SW7")+SW6->W6_HAWB))
SW2->(dBSeek(xFilial("SW2")+SW7->W7_PO_NUM))

AADD(TB_Campos1,{"WKADICAO"  ,"" ,STR0290 }) //"Adicao"
AADD(TB_Campos1,{"WK_CFO"    ,"" , STR0039 }) //"C.F.O."
AADD(TB_Campos1,{{||Work2->WK_OPERACA+"/"+TRANSFORM(Work2->WKTEC,PICT_CPO03)+"/"+Work2->WKEX_NCM+"/"+Work2->WKEX_NBM},"",STR0040}) //"Operacao/TEC/Ex-NCM/Ex-NBM"  // GFP - 13/03/2015
AADD(TB_Campos1,{"WKPESOL"   ,"" , STR0144 ,PICTPesoT}) //"Peso Adiçào"
IF nTipoNF # NFE_COMPLEMEN
   AADD(TB_Campos1,{"WKFOB_R"   ,"" , STR0042 ,PICT15_2}) //"FOB (R$)"
   AADD(TB_Campos1,{"WKFRETE"   ,"" , STR0043 ,PICT15_2}) //"FRETE (R$)"
   AADD(TB_Campos1,{"WKSEGURO"  ,"" , STR0044 ,PICT15_2}) //"SEGURO (R$)"
   //AADD(TB_Campos1,{"WKCIF"   ,"" , STR0045 ,PICT15_2}) //"C.I.F. (R$)"
   IF !lGravaWorks
      AADD(TB_Campos1,{"WKVLACRES",,AVSX3("W8_VLACRES",5),PICT15_2})
      AADD(TB_Campos1,{"WKVLDEDU" ,,AVSX3("W8_VLDEDU" ,5),PICT15_2})
   ENDIF
   AADD(TB_Campos1,{"WKBASEII"  ,, STR0045 ,PICT15_2}) //"C.I.F. (R$)"
   AADD(TB_Campos1,{"WKII_A"    ,, STR0047 ,PICT06_2}) //"% I.I."
   AADD(TB_Campos1,{"WKIIREDU_A",, STR0291 ,PICT06_2}) //"% Reduz. II"
   AADD(TB_Campos1,{"WKII"      ,, STR0048 ,PICT15_2}) //"I.I. (R$)"
   AADD(TB_Campos1,{"WKIPI_A"   ,, STR0049 ,PICT06_2}) //"% I.P.I."
   AADD(TB_Campos1,{"WKIPI"     ,, STR0050 ,PICT15_2}) //"I.P.I. (R$)"
ENDIF
IF lMV_PIS_EIC
   AADD(TB_Campos1,{"WKBASPIS",,AVSX3("W8_BASPIS",5),AVSX3("W8_BASPIS",6)})
   AADD(TB_Campos1,{"WKVLRPIS",,AVSX3("W8_VLRPIS",5),AVSX3("W8_VLRPIS",6)})
   AADD(TB_Campos1,{"WKBASCOF",,AVSX3("W8_BASCOF",5),AVSX3("W8_BASCOF",6)})
   AADD(TB_Campos1,{"WKVLRCOF",,AVSX3("W8_VLRCOF",5),AVSX3("W8_VLRCOF",6)})
ENDIF

AADD(TB_Campos1,{"WKICMS_A"  ,, STR0051 ,PICT06_2}) //"% I.C.M.S."
//AADD(TB_Campos1,{"WKICMS_RED",, AVSX3("WZ_RED_ICM",5),PICT06_2})
AADD(TB_Campos1,{"WKICMS"    ,, STR0052 ,PICT15_2}) //"I.C.M.S. (R$)"
AADD(TB_Campos1,{{||Work2->WKOUTRDESP+Work2->WKRDIFMID},"",STR0053,PICT15_2}) //"Outras Despesas"

IF !lGravaWorks .AND. !lNFAutomatica .AND. nTipoNF # CUSTO_REAL
   AADD(TB_Campos2,{"WKFLAG","" ,"",})
ENDIF
IF nTipoNF == CUSTO_REAL
   AADD(TB_Campos2,{"WK_NFE   " ,"" ,STR0037,}) //"N§ Custo"
ELSE
   AADD(TB_Campos2,{"WK_NFE   " ,"" ,STR0038,}) //"N§ NF"
   AADD(TB_Campos2,{{|| Transform(Work1->WK_SE_NFE,AvSX3("F1_SERIE",AV_PICTURE)) },"" ,(STR0028),})//"S‚rie NF"
ENDIF
AADD(TB_Campos2,{"WKADICAO"  ,"" ,STR0347     ,}) //STR0347 "Adição"
IF lExisteSEQ_ADI// AWR - 18/09/08 - NFE
   AADD(TB_Campos2,{"WKSEQ_ADI",,AVSX3("WN_SEQ_ADI)" ,AV_TITULO)})// AWR - 11/09/08 - NF-Eletronica //STR0348 "Seq. Reg."
ENDIF
AADD(TB_Campos2,{"WKFORN"    ,"" ,STR0084      ,}) //"Forncedor"

IF EICLOJA()
   AADD(TB_Campos2,{"WKLOJA"    ,"" ,STR0349      ,}) //STR0349 "Loja"
ENDIF

AADD(TB_Campos2,{"WK_CFO"    ,"" ,STR0039      ,}) //"C.F.O."
If lIntDraw
   AADD(TB_Campos2,{"WKACMODAL",,IF(cQbrACModal="1",AVSX3("W8_AC",5),AVSX3("ED0_MODAL",5)) })
Endif
AADD(TB_Campos2,{{||Work1->WK_OPERACA+"/"+TRANSFORM(Work1->WKTEC,PICT_CPO03)+"/"+Work1->WKEX_NCM+"/"+Work1->WKEX_NBM},"",STR0040,}) //"Operacao/TEC/Ex-NCM/Ex-NBM"  // GFP - 13/03/2015
AADD(TB_Campos2,{"WKCOD_I"   ,"" ,STR0054           ,}) //"C¢d. Item"
AADD(TB_Campos2,{{||Left(Work1->WKDESCR,35)},,STR0055}) //"Descri‡Æo do Item"
AADD(TB_Campos2,{"WKPESOL"   ,"" ,STR0041,PICTPesoI}) //"Peso L¡quido"
AADD(TB_Campos2,{"WKPRUNI"   ,"" ,STR0056,PICT21_8 }) //"Pre‡o Unit rio(R$)"
AADD(TB_Campos2,{"WKQTDE"    ,"" ,STR0057          ,PICT_CPO07}) //"Quantidade"
AADD(TB_Campos2,{"WKVALMERC" ,"" ,STR0058,_PictPrUn}) //"Pre‡o Total(R$)"
IF nTipoNF # NFE_COMPLEMEN
   AADD(TB_Campos2,{"WKFOB_R"   ,"" , STR0042          ,PICT15_2}) //"FOB R$"
   AADD(TB_Campos2,{"WKFRETE"   ,"" , STR0043          ,PICT15_2}) //"Frete R$"
   AADD(TB_Campos2,{"WKSEGURO"  ,"" , STR0044          ,PICT15_2}) //"Seguro R$"
   //AADD(TB_Campos2,{"WKCIF"     ,"" , STR0045          ,PICT15_2}) //"C.I.F. (R$)"
   IF !lGravaWorks
      AADD(TB_Campos2,{"WKVLACRES",,AVSX3("W8_VLACRES",5),PICT15_2})
      AADD(TB_Campos2,{"WKVLDEDU" ,,AVSX3("W8_VLDEDU" ,5),PICT15_2})
   ENDIF
   AADD(TB_Campos2,{"WKBASEII"  ,, STR0045          ,PICT15_2})//"C.I.F. (R$)"
   AADD(TB_Campos2,{"WKIITX"    ,, STR0047          ,PICT06_2}) //"% II"
   AADD(TB_Campos2,{"WKVLDEVII" ,, STR0048+" Devido",PICT15_2}) //"I.I. (R$)"
   AADD(TB_Campos2,{"WKIIVAL"   ,, STR0048          ,PICT15_2}) //"I.I. (R$)"
   AADD(TB_Campos2,{"WKIPIBASE" ,, STR0060          ,PICT15_2}) //"Base I.P.I. (R$)"
   AADD(TB_Campos2,{"WKIPITX"   ,, STR0049          ,PICT06_2}) //"% I.P.I."
   AADD(TB_Campos2,{"WKVLDEIPI" ,, STR0050+" Devido",PICT15_2}) //"I.P.I. (R$)"
   AADD(TB_Campos2,{"WKIPIVAL"  ,, STR0050          ,PICT15_2}) //"I.P.I. (R$)"
ENDIF
IF lMV_PIS_EIC
   AADD(TB_Campos2,{"WKBASPIS",,AVSX3("W8_BASPIS",5),AVSX3("W8_BASPIS",6)})
   AADD(TB_Campos2,{"WKPERPIS",,AVSX3("W8_PERPIS",5),AVSX3("W8_PERPIS",6)})
   AADD(TB_Campos2,{"WKVLRPIS",,AVSX3("W8_VLRPIS",5),AVSX3("W8_VLRPIS",6)})
   AADD(TB_Campos2,{"WKBASCOF",,AVSX3("W8_BASCOF",5),AVSX3("W8_BASCOF",6)})
   AADD(TB_Campos2,{"WKPERCOF",,AVSX3("W8_PERCOF",5),AVSX3("W8_PERCOF",6)})
   AADD(TB_Campos2,{"WKVLRCOF",,AVSX3("W8_VLRCOF",5),AVSX3("W8_VLRCOF",6)})
   If lCposCofMj                                                                        //NCF - 20/07/2012 - Majoração COFINS
      AADD(TB_Campos2,{"WKALCOFM",,"Alq.Maj.COF",PICT06_2            })
      AADD(TB_Campos2,{"WKVLCOFM",,"Vlr.Maj.COF",AVSX3("W8_VLCOFM",6)})
   EndIf
   If lCposPisMj                                                                        //GFP - 11/06/2013 - Majoração PIS
      AADD(TB_Campos2,{"WKALPISM",,"Alq.Maj.PIS",PICT06_2            })
      AADD(TB_Campos2,{"WKVLPISM",,"Vlr.Maj.PIS",AVSX3("W8_VLPISM",6)})
   EndIf
ENDIF

// GFP - 05/08/2013 - Tratamento para exibição do campo WN_DESPICM no grid
IF !(nTipoNF == CUSTO_REAL .AND. lGravaWorks)//Para nao aparecer na consulta do custo
   IF lTemDespBaseICM  .OR. !lGravaWorks//Quando na existir o campo no SWN: só mostrar na geracao
      AADD(TB_Campos2,{"WKDESPICM" ,,STR0336, PICT15_2})//"Desp. Base ICMS (R$)"
   ENDIF
ENDIF

AADD(TB_Campos2,{"WKBASEICMS",, STR0062          ,PICT15_2}) //"Base I.C.M.S. (R$)"
AADD(TB_Campos2,{"WKICMS_A"  ,, STR0051          ,PICT06_2}) //"% ICMS"
AADD(TB_Campos2,{"WKVL_ICM"  ,, STR0052          ,PICT15_2}) //"I.C.M.S. (R$)"

	// EOB - 16/02/09   NCF-27/05/2010
	IF !lTipoCompl .AND. nTipoNF # CUSTO_REAL

       IF lICMS_Dif
	      AADD(TB_Campos2,{"WKVLICMDEV","" , STR0350   ,PICT15_2}) //STR0350 "ICMS devido"
	   ENDIF

	   IF lICMS_Dif2
      	  AADD(TB_Campos2,{"WK_PERCDIF","",AVSX3("WZ_ICMSDIF",5),AVSX3("WZ_ICMSDIF",6)})
       ENDIF

	   IF lICMS_Dif
  		  AADD(TB_Campos2,{"WKVL_ICM_D","",AVSX3("WN_VICMDIF",5),AVSX3("WN_VICMDIF",6)})
       ENDIF

	   IF lICMS_Dif2
    	  AADD(TB_Campos2,{"WK_PCREPRE","" ,AVSX3("WZ_PCREPRE",5),AVSX3("WZ_PCREPRE",6)})
   		  AADD(TB_Campos2,{"WK_CRE_PRE","" ,AVSX3("WZ_ICMS_CP",5),AVSX3("WZ_ICMS_CP",6)})
  	   ENDIF

  	   IF lICMS_Dif
		  AADD(TB_Campos2,{"WKVLCREPRE",,AVSX3("WN_VICM_CP",5),AVSX3("WN_VICM_CP",6)})
	   ENDIF

	   IF lICMS_Dif2
   		  AADD(TB_Campos2,{"WK_PAG_DES","", AVSX3("WZ_ICMS_PD",5),AVSX3("WZ_ICMS_PD",6)})
   	   ENDIF

   	   IF lCposICMSPt                                                                                     //NCF - 11\05\2011 - Exibe o campo de ICMS devido para tratamento de ICMS de Pauta
          IF ( nPos1 := aScan(aDBF_Stru, {|x| x[1] == "WKVLICMDEV"}) ) # 0
             IF ( nPos2 := aScan(TB_Campos2, {|x| If(ValType(x[1])=="C",x[1] == "WKVLICMDEV",0) }) ) == 0
                AADD(TB_Campos2,{"WKVLICMDEV","" , "ICMS devido"   ,PICT15_2})
             ENDIF
          ENDIF
       ENDIF

       If AvFlags("ICMSFECP_DI_ELETRONICA")
          AADD(TB_Campos2,{"WKALFECP","" ,AVSX3("W8_ALFECP",5),AVSX3("W8_ALFECP",6)})
          AADD(TB_Campos2,{"WKVLFECP","" ,AVSX3("W8_VLFECP",5),AVSX3("W8_VLFECP",6)})          
       EndIf
       If AVFLAGS("FECP_DIFERIMENTO")
          AADD(TB_Campos2,{"WKFECPALD","",AVSX3("W8_FECPALD",5),AVSX3("W8_FECPALD",6)})
          AADD(TB_Campos2,{"WKFECPVLD","",AVSX3("W8_FECPVLD",5),AVSX3("W8_FECPVLD",6)})
          AADD(TB_Campos2,{"WKFECPREC","",AVSX3("W8_FECPREC",5),AVSX3("W8_FECPREC",6)})
       EndIf
    ENDIF

IF nTipoNF # NFE_PRIMEIRA .AND. nTipoNF # NFE_MAE
   AADD(TB_Campos2,{"WKOUT_DESP",, STR0053          ,PICT15_2}) //"Outras Despesas"
ENDIF
AADD(TB_Campos2,{"WKPO_NUM"  ,, STR0063          ,}) //"N§ P.O."

IF lLote //.AND. (nTipoNF # CUSTO_REAL .OR. !lGravaWorks)
   AADD(TB_Campos2,{"WK_LOTE"  ,"" ,STR0064                             }) //"No. Lote"
   IF lCpoDtFbLt
       AADD(TB_Campos2,{"WKDTFBLT" ,"",AvSX3("WV_DFABRI",5) } )
   ENDIF
   AADD(TB_Campos2,{"WKDTVALID","" ,STR0065                         }) //"Dt. Validade"
   AADD(TB_Campos2,{{||IF(SUBSTR(Work1->WKPGI_NUM,1,1)=="*","",Work1->WKPGI_NUM)},,STR0066}) //"No. PLI"
ENDIF
IF lMV_GRCPNFE .AND. nTipoNF # CUSTO_REAL //Campos novos NFE - AWR 06/11/2008
   AADD(TB_Campos2,{ "WKALUIPI" ,"",AVSX3("WN_ALUIPI" ,5),AVSX3("WN_ALUIPI" ,6) })
   AADD(TB_Campos2,{ "WKQTUIPI" ,"",AVSX3("WN_QTUIPI" ,5),AVSX3("WN_QTUIPI" ,6) })
   AADD(TB_Campos2,{ "WKQTUPIS" ,"",AVSX3("WN_QTUPIS" ,5),AVSX3("WN_QTUPIS" ,6) })
   AADD(TB_Campos2,{ "WKQTUCOF" ,"",AVSX3("WN_QTUCOF" ,5),AVSX3("WN_QTUCOF" ,6) })
   AADD(TB_Campos2,{ "WKPREDICM","",AVSX3("WN_PREDICM",5),AVSX3("WN_PREDICM",6) })
   AADD(TB_Campos2,{ "WKDESCONI","",AVSX3("WN_DESCONI",5),AVSX3("WN_DESCONI",6) })
   AADD(TB_Campos2,{ "WKVLRIOF" ,"",AVSX3("WN_VLRIOF" ,5),AVSX3("WN_VLRIOF" ,6) })
ENDIF

//FSM - 02/09/2011 - Peso Bruto Unitario
If lPesoBruto
   AADD(TB_Campos2,{ "WKPESOBR" ,"",AVSX3("W8_PESO_BR" ,5),AVSX3("W8_PESO_BR" ,6) })
EndIf

IF lGravaWorks .AND. AvFlags("EIC_EAI")//AWF - 17/06/14 - Logix
	  Private aSTs:={"0=NF não integrada","1=NF Integrada.","2=NF integrada c/ sol.cancelamento","3=NF cancelada."}
	  AADD(TB_Campos2,{ {|| if((nPosST:=aScan(aSTs,Work1->WKSTATUS))>0,aSTs[nPosST],"") } ,,AVSX3("F1_STATUS",5)})// "Nao Classif."###"Classificada"

      aAdd(TB_Campos2,{ {|| if(AllTrim(Work1->WK_OK) == "1", STR0366, STR0366) } ,"",AVSX3("F1_OK",5) ,AVSX3("F1_OK"     ,6)}) //"Grupo de NF Integrado", "Grupo de NF não Integrado"
	  Aadd(TB_Campos2,{ "WKMENNOTA","",AVSX3("F1_MENNOTA",5),AVSX3("F1_MENNOTA",6)})
	  //Nota fiscal provisória
	  aAdd(TB_Campos2,{ "WKNOTAPR" , "", "No.Prov.NF", AvSx3("WN_DOC"  , AV_PICTURE)})
      aAdd(TB_Campos2,{ "WKSERIEPR", "", "Série Prov", AvSx3("WN_SERIE", AV_PICTURE)})
ENDIF
IF lTemCposOri .OR. !lGravaWorks//AWF - 31/07/2014
   aAdd(TB_Campos2,{ "WKNOTAOR" ,"",AVSX3("WN_DOC  ",5),AVSX3("WN_DOC"  ,6)})
   aAdd(TB_Campos2,{{|| Transform(Work1->WKSERIEOR,AvSX3("F1_SERIE",AV_PICTURE)) },"",AVSX3("WN_SERIE",5),AVSX3("WN_SERIE",6)})
ENDIF

IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,'WORK_BROWSES'),)

aCampos :={"W9_INVOICE","W9_FORN","W9_MOE_FOB","W9_FRETEIN","W9_INLAND","W9_PACKING",;
           "W9_OUTDESP","W9_DESCONT","W9_FOB_TOT","W6_FOB_TOT"}
// EOB - 14/07/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP
IF lSegInc
   AADD( aCampos, "W9_SEGURO")
ENDIF

cFileWk:=E_CriaTrab(,{{"WKCODIGO","C",1,0}},"Work_Tot")
IF !USED()
   SW6->(MSUnlock())
   Help("",1,"AVG0000802")
   Return .F.
ENDIF

IndRegua("Work_Tot",cFileWk+TEOrdBagExt(),"WKCODIGO+W9_INVOICE+W9_FORN")

cFileWkA:=E_Create(,.F.)
IndRegua("Work_Tot",cFileWkA+TEOrdBagExt(),"WKCODIGO+W9_MOE_FOB")

SET INDEX TO (cFileWk+TEOrdBagExt()),(cFileWkA+TEOrdBagExt())

aDBF_Stru:= AddWkCpoUser(aDBF_Stru,"SWN")
Work1File := E_CriaTrab(,aDBF_Stru,"Work1") //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados

IF !USED()
   SW6->(MSUnlock())
   Work_Tot->(E_EraseArq(cFileWk,cFileWkA))
   Help("",1,"AVG0000802")
   Return .F.
ENDIF

IndRegua("Work1",Work1File+TEOrdBagExt() ,"WKADICAO+WK_CFO+WK_OPERACA+WKTEC+WKEX_NCM+WKEX_NBM+WKCOD_I+WKPOSICAO")

Work1FileA:=E_Create(,.F.)
IndRegua("Work1",Work1FileA+TEOrdBagExt(),"WK_NFE+WK_SE_NFE")

Work1FileB:=E_Create(,.F.)
IndRegua("Work1",Work1FileB+TEOrdBagExt(),"WKPO_NUM+WKPOSICAO+WKPGI_NUM")

Work1FileC:=E_Create(,.F.)
IndRegua("Work1",Work1FileC+TEOrdBagExt(),"WK_NFE+WK_SE_NFE+WK_OPERACA+WKTEC+WKEX_NCM+WKEX_NBM+WKPO_NUM")

Work1FileD:=E_Create(,.F.)

IF EICLOJA()
   IndRegua("Work1",Work1FileD+TEOrdBagExt(),"WKFORN+WKLOJA+WK_CFO+WKACMODAL+WK_OPERACA+WKTEC+WKEX_NCM+WKEX_NBM+WKCOD_I+WKPOSICAO")
ELSE
   IndRegua("Work1",Work1FileD+TEOrdBagExt(),"WKFORN+WK_CFO+WKACMODAL+WK_OPERACA+WKTEC+WKEX_NCM+WKEX_NBM+WKCOD_I+WKPOSICAO")
ENDIF

Work1FileF:=E_Create(,.F.)
IndRegua("Work1",Work1FileF+TEOrdBagExt(),"WKCOD_I")
Work1FileG:=E_Create(,.F.)
IndRegua("Work1",Work1FileG+TEOrdBagExt(),"WKPO_NUM")
Work1FileH:=E_Create(,.F.)
IndRegua("Work1",Work1FileH+TEOrdBagExt(),"WKINVOICE")
Work1FileI:=E_Create(,.F.)
IndRegua("Work1",Work1FileI+TEOrdBagExt(),"WKNOTAOR+WKSERIEOR")

   WORK1->(OrdListClear())
   Work1->(dbSetIndex(Work1File +TEOrdBagExt()))
   Work1->(dbSetIndex(Work1FileA+TEOrdBagExt()))
   Work1->(dbSetIndex(Work1FileB+TEOrdBagExt()))
   Work1->(dbSetIndex(Work1FileC+TEOrdBagExt()))
   Work1->(dbSetIndex(Work1FileD+TEOrdBagExt()))
   Work1->(dbSetIndex(Work1FileF+TEOrdBagExt()))
   Work1->(dbSetIndex(Work1FileG+TEOrdBagExt()))
   Work1->(dbSetIndex(Work1FileH+TEOrdBagExt()))
   Work1->(dbSetIndex(Work1FileI+TEOrdBagExt()))


//Work2
Work2File := E_CriaTrab(,aDBF_Stru2,"Work2") //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados

IF ! USED()
   SW6->(MSUnlock())
   Help("",1,"AVG0000802")
   Work1->(E_EraseArq(Work1File,Work1FileA,Work1FileB))
   FErase(Work1FileC+TEOrdBagExt())
   FErase(Work1FileD+TEOrdBagExt()) 
   Return .F.
ENDIF

IndRegua("Work2",Work2File+TEOrdBagExt(),"WKADICAO+WK_CFO+WK_OPERACA+WKTEC+WKEX_NCM+WKEX_NBM")

//Work3
Work3File := E_CriaTrab(,aDBF_Stru3,"Work3") //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados

IF ! USED()
   SW6->(MSUnlock())
   Help("",1,"AVG0000802")
   Work1->(E_EraseArq(Work1File,Work1FileA,Work1FileB))
   FErase(Work1FileC+TEOrdBagExt())
   FErase(Work1FileD+TEOrdBagExt())
   Work2->(E_EraseArq(Work2File))
   Return .F.
ENDIF

IndRegua("Work3",Work3File+TEOrdBagExt(),"WKRECNO")

Work3FileA:=E_Create(aDBF_Stru3,.F.)

IndRegua("Work3",Work3FileA+TEOrdBagExt(),"WKPO_NUM+WKDESPESA")

SET INDEX TO (Work3File+TEOrdBagExt()),(Work3FileA+TEOrdBagExt())
aCampos:={}
//aHeader:={}
aCposWork4 := {{"WKDESP"   ,"C",40,0},;
              {"WKVALOR"  ,"N",18,2},;
              {"WKNOTA"   ,"C",LEN(SWD->WD_NF_COMP),0},;
              {"WKSERIE"  ,"C",03,0},;
              {"WKBASEICM","C",01,0},;
              {"WKICMS_UF","C",01,0},;
              {"WKBASEIMP","C",01,0},;
              {"WKICMSNFC","C",01,0},;
              {"WKBASECUS","C",01,0},;
              {"WKRATPESO","C",01,0},;
              {"TRB_ALI_WT","C",03,0},; //TRP - 25/01/07 - Campos do WalkThru
              {"TRB_REC_WT","N",10,0}}  // GFP - 28/06/2013

IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"WORK4"),)  // GFP - 28/06/2013

Work4File:=E_CriaTrab(,aCposWork4,"Work4")   // GFP - 28/06/2013

IF ! USED()
   SW6->(MSUnlock())
   Help("",1,"AVG0000802")
   Work1->(E_EraseArq(Work1File,Work1FileA,Work1FileB))
   FErase(Work1FileC+TEOrdBagExt())
   FErase(Work1FileD+TEOrdBagExt())
   Work2->(E_EraseArq(Work2File))
   Work3->(E_EraseArq(Work3File,Work3FileA))
   Return .F.
ENDIF

IndRegua("Work4",Work4File+TEOrdBagExt(),"WKDESP")

IF (EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,'OUTROS_INDICES'),)

lComIcms:=lGravaWorks//Para aparecer o valor do ICMS no Estorno
MDI_FOB :=MDI_FOB_R:=MDI_FRETE:=MDI_SEGURO:=MDI_CIF:=MDI_CIF_M:=MDI_CIFMOE:=0
MDI_II  :=MDI_IPI:=MDI_ICMS:=MDI_OUTR:=MDI_PESO:=MDI_QTDE:=TICMS:=nTiraCusto:=0
nNBM_CIF:=nNBM_II:=nNBM_IPI:=nNBM_ICMS:=0
nNBM_PIS:=nNBM_COF:=MDI_PIS:=MDI_COF  :=0
nPesoL  :=MDespesas:=nPesoB:=0 //FSM - 02/08/2011 - Peso Bruto Unitario
Private nPSemCusto := 0
Private nSemCusto := 0

PRIVATE M_FOB_MIDRS:=0 , nFobItemMidiaRS:=0
PRIVATE lAlterouAliquotas:=.F.//Variavel usada para verificar se houve alteracao nas aliquotas e peso
PRIVATE lEIB_Processa    :=EasyGParam("MV_UTILEIB",,.F.)
PRIVATE cFormPro := EasyGParam("MV_NF_AUTO",, "N") // TDF - 17/11/2010
PRIVATE lTemDespCusto := DI154TemDspProc(SW6->W6_HAWB, "B") //LGS - 03/06/2016
Private lIntegrarEstorno:= .T.
Private nNivelForcaEstorno:= 7

SA2->(DbSeek(xFilial("SA2")+SW7->W7_FORN+EICRetLoja("SW7", "W7_FORLOJ")))
lLerNota:=.F.
IF (EasyGParam("MV_LERNOTA",,.F.) .OR. SW6->W6_IMPCO == "1") .AND. nTipoNF = CUSTO_REAL .AND. !lGravaWorks  // GFP - 03/11/2014

   SF1->(DBSETORDER(5))
   IF SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+'1'))
      nTipoNF:=1
      lLerNota:=.T.
      lGravaWorks:=.T.
      cNota :=SF1->F1_CTR_NFC//Nota + Serie
   ENDIF

   IF SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+'3'))
      nTipoNF:=3
      lLerNota:=.T.
      lGravaWorks:=.T.
      cNota :=SF1->F1_CTR_NFC//Nota + Serie
   ENDIF
   IF SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+'5'))
      nTipoNF  :=5
      lLerNota :=.T.
      lGravaWorks:=.T.
      cNota :=SF1->F1_CTR_NFC//Nota + Serie
   ENDIF
   IF SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+'9'))  // GFP - 03/11/2014 - Conta e Ordem
      nTipoNF  :=9
      lLerNota :=.T.
      lGravaWorks:=.T.
      cNota :=SF1->F1_CTR_NFC//Nota + Serie
   ENDIF

ENDIF

IF lGravaWorks
   Processa({|| DI554GrWorks({|msg| MsProcTxt(msg)},bDDIFor,BDDIWhi)},;
            STR0068) //"Pesquisando Informa‡äes..."

   IF lLerNota
      nTipoNF:=4
      Processa({|| DI554GeraCusto()},STR0068) //"Pesquisando Informa‡äes..."
      lGravaWorks:=.F.
      DI554MsgDif(.T.)
   ENDIF
ELSE
   lRet_Ok:=.T.
   Processa({|| lRet_Ok:=DI554Grava({|msg| MsProcTxt(msg)},bDDIFor,BDDIWhi)},;
            STR0068) //"Pesquisando Informa‡äes..."

  IF nTipoNF==NFE_COMPLEMEN
     If Empty(MDI_OUTR) .And. !lTemDespCusto
        Help(" ",1,"DI154DESP")//Nao ha  despesas p/ geracao de Nota Fiscal Complementar
        E_RESET_AREA()//Work1File,Work1FileA,Work1FileB,Work1FileC,Work2File,Work3File,Work3FileA,cFileWk,cFileWkA)
        Return .F.
     Endif

     //LGS-02/06/2016 - Complemento de Valor
     If (DI154CompValor(SW6->W6_HAWB) .And. lICMS_NFC  .And. lTemDespCusto .And. MDI_OUTR == 0) .Or.;
        (DI154CompValor(SW6->W6_HAWB) .And. !lICMS_NFC .And. lTemDespCusto)
        E_RESET_AREA()
        MsgInfo(STR0374,STR0022)
        Return .F.
     EndIf
     If DI154CompValor(SW6->W6_HAWB) .And. lTemDespCusto .And. MDI_OUTR > 0
        MsgInfo(STR0375,STR0022)
     EndIf

  ELSEIF nTipoNF<>NFE_FILHA
      DI554MsgDif(.T.)
  Endif

  IF !lRet_Ok  // Bete 28/11 - Trevo
     E_RESET_AREA()
     Return .F.
  ENDIF
ENDIF

IF lExecAuto
   E_RESET_AREA()
   Return .T.
ENDIF

IF Work2->(BOF()) .AND. Work2->(EOF())
   IF ! lGravaWorks
      Help(" ",1,"EICSEMREG")
      E_RESET_AREA()//Work1File,Work1FileA,Work1FileB,Work1FileC,Work2File,Work3File,Work3FileA,cFileWk,cFileWkA)
      Return .F.
   ENDIF
ENDIF

IF nTipoNF==NFE_COMPLEMEN

/*   If Empty(MDI_OUTR) - ASR 27/12/2005 - NÃO É NECESSÁRIO
      Help(" ",1,"DI154DESP")//"Nao h  despesas p/ gera‡ao de Nota Fiscal Complementar
       E_RESET_AREA()//Work1File,Work1FileA,Work1FileB,Work1FileC,Work2File,Work3File,Work3FileA,cFileWk,cFileWkA)
       Return .F.
   Endif*/

   nFob_R  :=0
   n_Frete :=0
   n_Seguro:=0
   n_CIF   :=0
   n_II    :=0
   n_IPI   :=0
   n_ICMS  := IF(lICMS_NFC, IF(lExiste_Midia,0, nNBM_ICMS ) ,0)
   n_PIS   :=0
   n_COFINS:=0
   n_Desp  :=0
   n_Tx_Fob:=0
   n_Vl_Fre:=0
   n_Tx_Fre:=0
   n_Vl_USS:=0
   n_Tx_FOB:=0

ELSE
   nFob_R  :=MDI_FOB_R
   n_Frete :=MDI_FRETE
   n_Seguro:=MDI_SEGURO
   n_CIF   :=MDI_CIF
   n_II    :=nNBM_II
   n_IPI   :=nNBM_IPI
   n_ICMS  :=nNBM_ICMS
   n_PIS   :=nNBM_PIS
   n_COFINS:=nNBM_COF
   n_Desp  :=MDespesas
   n_Vl_Fre:=ValorFrete(SW6->W6_HAWB,,,2)
   n_Tx_Fre:=SW6->W6_TX_FRET
   n_Vl_USS:=SW6->W6_VL_USSE
ENDIF

cTotal  :=STR0280
n_ValM  :=DITRANS(n_CIF,2)+DITRANS(n_II,2)
n_TotNFE:=DITRANS(n_ValM,2)+DITRANS(n_IPI,2)+DITRANS(n_PIS,2)+DITRANS(n_COFINS,2)
n_VlTota:=DITRANS((n_TotNFE+n_ICMS+MDI_OUTR),2)
//Remove dos totais as despesas que não são base de custo
If EasyGParam("MV_EIC0070",,.F.)
   n_VlTota -= (nSemCusto + nPSemCusto)
EndIf

If !(lTemCusto .And. nTipoNF == CUSTO_REAL) .And. !lNFFilha3
   n_Desp += If(EasyGParam("MV_EIC0037",,.F.),nSomaBaseICMS,0)
Endif

IF !lNFFilha3 //LGS-05/05/14
   IF nTipoNF <> CUSTO_REAL
      n_VlTota += DITRANS(nSomaBaseICMS + nPSomaBaseICMS + nTxSisc + nSomaDespRatAdicao, 2)
   ELSE
      IF !lTemCusto
         if ! EasyGParam("MV_LERNOTA",,.F.)
            n_VlTota += DITRANS( nSomaBaseICMS + nPSomaBaseICMS + nTxSisc + nSomaDespRatAdicao ,2)
         else
            n_VlTota += ditrans( nVlrCustoSNW ,2)
         endif
      ENDIF
   ENDIF
ENDIF

nL1:=1.4; nL2:=2.2; nL3:=3.0; nL4:=3.8; nL5:=4.6; nL6:=5.4; nL7:=6.2; nL8:=7.0
nC1:=0.7; nC2:=5.2; nC3:=13.0; nC4:=18.2; nC5:=25.7; nC6:=31.2

Work2->(DBGOTOP())
Work1->(DBGOTOP())

SA2->(DBSETORDER(1))
SW7->(DBSETORDER(1))
SW2->(DBSETORDER(1))
SYT->(DBSETORDER(1))
SW7->(DbSeek(xFilial("SW7")+SW6->W6_HAWB))
SW2->(dBSeek(xFilial("SW2")+SW7->W7_PO_NUM))
SYT->(dBSeek(xFilial("SYT")+SW2->W2_IMPORT))
SA2->(DbSeek(xFilial("SA2")+SW7->W7_FORN+EICRetLoja("SW7", "W7_FORLOJ")))

If nTipoNF == NFE_COMPLEMEN .AND. SW6->W6_IMPCO == "1"  // GFP - 21/01/2015 - Geração de NF Complementar para processos Conta e Ordem deve ser apresentado Fornecedor do Importador.
   IF !Empty(SYT->YT_FORN) .And. !Empty(SYT->YT_LOJA)   //LRS - 8/10/2015 - Verifica se o Fornecedor do processo Complementar do conta e ordem está preenchido, se não pega do P.O.
	  SA2->(DbSeek(xFilial("SA2")+SYT->YT_FORN+EICRetLoja("SYT", "YT_LOJA")))
   Else
	  SA2->(DbSeek(xFilial("SA2")+SW2->W2_FORN+EICRetLoja("SW2", "W2_FORLOJ")))
   EndIF
EndIf

DO CASE
   CASE nTipoNF = NFE_PRIMEIRA
        cTit:=cCadastro+" ("+STR0181+")"
   CASE nTipoNF = NFE_COMPLEMEN
        cTit:=cCadastro+" ("+STR0016+")"
   CASE nTipoNF = NFE_UNICA
        cTit:=cCadastro+" ("+STR0017+")"
   CASE (lMV_NF_MAE .And. nTipoNF == NFE_MAE)
        cTit:=cCadastro+" ("+STR0311+")"
   CASE (lMV_NF_MAE .And. nTipoNF == NFE_FILHA)
        cTit:=cCadastro+" ("+STR0312+")"
   CASE nTipoNF = CUSTO_REAL
        cTit:=cCadastro+" ("+STR0182+")"
ENDCASE

cTit+=STR0333 //STR0333 " com Adições"

DO WHILE .T.

   lGeraNF:=.T.
   nOpca:=000
   nLin :=0.1
   nCoL1:=005
   nCoL2:=050
   nCoL3:=122
   nCoL4:=172
   nCoL5:=255

   oMainWnd:ReadClientCoords()
   DEFINE MSDIALOG oDlg TITLE cTit ;
      FROM oMainWnd:nTop+060,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
      OF oMainWnd PIXEL

   nSize:= 56

   @ nLin,nLin TO nLin+102,249       PIXEL
   @ nLin,250  TO nLin+102,260+nSize PIXEL

   nLin+=04
   @ nLin,nCoL1 SAY AVSX3("W6_HAWB",5) SIZE 58,7 PIXEL
   @ nLin,nCoL2 MSGET SW6->W6_HAWB     WHEN .F. SIZE 58,8 PIXEL

   @ nLin,nCoL3 SAY AVSX3("W6_DT_DESE",5) SIZE 58,7 PIXEL//"Dt.Desembaraço"
   @ nLin,nCoL4 MSGET SW6->W6_DT_DESE     WHEN .F. SIZE 58,8 PIXEL

   nLin+=12
   @ nLin,nCoL1 SAY STR0084        SIZE 58,7 PIXEL//"Fornecedor"
   IF LEN(aLista) < 2
      @ nLin,nCoL2 MSGET SA2->A2_NOME WHEN .F. SIZE 180,8 PIXEL
   ELSE
      cForn:=aLista[1]
      @ nLin,nCoL2 LISTBOX cForn ITEMS aLista SIZE 180,10 PIXEL
   ENDIF
   nLin+=12
   @ nLin,nCoL1 SAY STR0083        SIZE 58,7 PIXEL//"Importador"
   @ nLin,nCoL2 MSGET SYT->YT_NOME WHEN .F. SIZE 180,8 PIXEL

   nLin+=12
   @ nLin,nCoL1 SAY AVSX3("W6_DI_NUM",5) SIZE 58,7 PIXEL//"Nº D.I."
   @ nLin,nCoL2 MSGET SW6->W6_DI_NUM     WHEN .F. SIZE 58,8 PIXEL

   @ nLin,nCoL3 SAY AVSX3("W6_DTREG_D",5) SIZE 58,7 PIXEL
   @ nLin,nCoL4 MSGET SW6->W6_DTREG_D     WHEN .F. SIZE 58,8 PIXEL

   nLin+=12
   @ nLin,nCoL1 SAY STR0073+IF(!lCurrier,"("+SW6->W6_FREMOED+")","") SIZE 58,7 PIXEL//"Frete
   @ nLin,nCoL2 MSGET n_Vl_Fre  PICTURE PICT15_2 SIZE 58, 7 OF oDlg WHEN .F. RIGHT PIXEL

   @ nLin,nCoL3 SAY AVSX3("W6_TX_FRET",5) SIZE 58,7 PIXEL
   @ nLin,nCoL4 MSGET n_Tx_Fre PICTURE PICT15_8 SIZE 58, 7 OF oDlg WHEN .F. RIGHT PIXEL

   nLin+=12
   @ nLin,nCoL1 SAY STR0075+IF(!lCurrier,"("+SW6->W6_SEGMOEDA+")","") SIZE 58,7 PIXEL//"Seguro
   @ nLin,nCoL2 MSGET n_Vl_USS  PICTURE PICT15_2 SIZE 58, 7 OF oDlg WHEN .F. RIGHT PIXEL

   @ nLin,nCoL3 SAY STR0076 SIZE 58,7 PIXEL//"Tx Seg "
   @ nLin,nCoL4 MSGET SW6->W6_TX_SEG PICTURE PICT15_8 SIZE 58, 7 OF oDlg WHEN .F. RIGHT PIXEL

   nLin+=12
   @ nLin,nCoL1 SAY STR0053 SIZE 58,7 PIXEL//"Outras Desp.(R$)"
   @ nLin,nCoL2 MSGET n_Desp  PICTURE PICT15_2 SIZE 58, 7 OF oDlg WHEN .F. RIGHT PIXEL

   @ nLin,nCoL3 SAY STR0274 SIZE 58,7 PIXEL //"Total Geral (R$)"
   @ nLin,nCoL4 MSGET oSayTotGe VAR n_VlTota PICTURE PICT15_2 SIZE 58, 7 OF oDlg WHEN .F. RIGHT PIXEL

   nLin:=05
   @ nLin,nCoL5 BUTTON STR0103 SIZE nSize,12 ACTION (nOpca:=0,oDlg:End()) OF oDlg PIXEL //"&Sair"

   nLin+=12
   @ nLin,nCoL5 BUTTON IF(lTemPendentes,STR0378,STR0085) SIZE nSize,12 ACTION ; //"Integracao"//"&Estorno"
                               (IF(lTemFilha .And. (lMV_NF_MAE .And. nTipoNF == NFE_MAE) ,Alert(STR0313),; //"Conhecimento possui Nota Fiscal de Remessa!"
                               IF(lTemComplem,Help("",1,"AVG0000816"),;//MsgStop(STR0086,STR0022),; //"Conhecimento possui Nota Fiscal Complementar"###"Atenção"
                               IF(ValEstorno() .And. DI154Logix(.F.) .AND. MsgYesNo(STR0087,STR0088)==.T.,(nOpca:=1,oDlg:End()),)))); //"Confirma Estorno ?"###"Estorno"
                               WHEN ((lGravaWorks.OR.lGerouNFE) .And. lEstornaBtn) OF oDlg PIXEL

   /* WFS - opção para forçar o estorno quando a nota fiscal não existir no LOGIX.
      Uso restrito à usuários com nível 7 ou superior. */
   If AvFlags("EIC_EAI") .And. cNivel >= nNivelForcaEstorno .And. !lTemPendentes
      nLin+=12
      @ nLin,nCoL5 BUTTON STR0379 SIZE nSize, 12 ACTION ; //"Forçar o Estorno"
                               IF(lTemFilha .And. lMV_NF_MAE .And. nTipoNF == NFE_MAE , Alert(STR0313),; //"Conhecimento possui Nota Fiscal de Remessa!"
                                  IF(lTemComplem, Help("",1,"AVG0000816"),;//MsgStop(STR0086,STR0022),; //"Conhecimento possui Nota Fiscal Complementar"###"Atenção"
                                     IF(ValEstorno() .And. DI154Logix(.F.) .AND. MsgYesNo(STR0380, STR0088),;//"Esta ação forçará o estorno da nota fiscal no Easy Import Control, não integrando esta operação com o ERP via EAI, podendo causar inconsistência caso a nota fiscal exista no ERP. É uma operação irreversível. Deseja prosseguir?"
                                          (nOpca:= 1, lIntegrarEstorno:= .F., oDlg:End()),);
                                     );
                                  );
                               WHEN ((lGravaWorks.OR.lGerouNFE) .And. lEstornaBtn)  .And. cNivel >= nNivelForcaEstorno OF oDlg PIXEL
   EndIf

   IF !lGravaWorks
      nLin+=12
      @ nLin,nCoL5 BUTTON STR0089 SIZE nSize,12 ACTION ; //"&Itens"
                               ((nOpca:=2,oDlg:End())) OF oDlg PIXEL
   ENDIF

   IF lMV_NF_MAE  // DFS - Alteração do tratamento para trazer os botões quando tiver o parametro ligado/desligado.
      If nTipoNF <> NFE_FILHA
         nLin+=12
         @ nLin,nCoL5 BUTTON STR0275 SIZE nSize,12 ACTION (DI554ValTxTela()) OF oDlg PIXEL WHEN (nTipoNF # NFE_COMPLEMEN)//"&Valores/Taxas"

         nLin+=12
         @ nLin,nCoL5 BUTTON STR0276 SIZE nSize,12 ACTION (DI554DespTela())  OF oDlg PIXEL //"&Despesas"
      Endif
   Else
      nLin+=12
      @ nLin,nCoL5 BUTTON STR0275 SIZE nSize,12 ACTION (DI554ValTxTela()) OF oDlg PIXEL WHEN (nTipoNF # NFE_COMPLEMEN)//"&Valores/Taxas"

      nLin+=12
      @ nLin,nCoL5 BUTTON STR0276 SIZE nSize,12 ACTION (DI554DespTela())  OF oDlg PIXEL //"&Despesas"
   ENDIF

   IF nTipoNF # CUSTO_REAL
      nLin+=12
      @ nLin,nCoL5 BUTTON STR0334 SIZE nSize,12 ACTION (EICDI155(99)) WHEN (lGerouNFE .OR. lGravaWorks) OF oDlg PIXEL //STR0334 "Gera I.N. 68/86"
   ENDIF

   IF lGravaWorks
      nLin+=12
      @ nLin,nCoL5 BUTTON STR0100 SIZE nSize,12 ACTION (DIMostraTotais()) OF oDlg PIXEL //"&Totais"
      nLin+=12
      @ nLin,nCoL5 BUTTON STR0278 SIZE nSize,12 ACTION (nOpca:=3,oDlg:End()) OF oDlg PIXEL //"I&mpressão"
   ENDIF

   //DRL - 09/03/09
   If FindFunction("U_EICDILOG")
      nLin+=12
      @ nLin,nCoL5 BUTTON "LogNf" SIZE nSize,12 ACTION (EasyExRdm("U_EICDILOG","EICDI154")) OF oDlg PIXEL
   EndIF

   If nTipoNF = CUSTO_REAL 
      nLin+=12
      @ nLin,nCoL5 BUTTON STR0382 SIZE nSize,12 ACTION ((Processa({||DI154PRTXT()},STR0031),nOpca:=0)) OF oDlg PIXEL // EXPORTA
   EndIf
   
   IF lGravaWorks
      Work1->(DBSETORDER(5))
      Work1->(DBGOTOP())
      oMark:= MsSelect():New("Work1",,,TB_Campos2,.T.,@cMarca,{103,1,(oDlg:nClientHeight-26)/2,(oDlg:nClientWidth-4)/2})
   ELSE
      oMark:= MsSelect():New("Work2",,,TB_Campos1,.T.,@cMarca,{103,1,(oDlg:nClientHeight-26)/2,(oDlg:nClientWidth-4)/2})
   ENDIF

   IF (EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"TELA1"),)

   ACTIVATE MSDIALOG oDlg ON INIT (oMark:oBrowse:Refresh())

   DO CASE
      CASE nOpca = 0
           EXIT
      CASE nOpca = 1
           lNoErro:=.T.
           Processa({|| lNoErro:=DI554Estorna() },STR0090) //"Processando Estorno..."
           IF !lNoErro
              LOOP
           ENDIF
           EXIT
      CASE nOpca = 2
           IF !DI554Itens(bDDIFor,bDDIWhi) // Itens
              EXIT //AWF 31/07/2014 - LOGIX - Se se gerou as notas e for integrado com o Logix retorna .F. para sair dessa tela principal de geracao de nota
           ENDIF
      CASE nOpca = 3 ; EICDI155(nTipoNF) //Impressão
   ENDCASE

ENDDO

E_RESET_AREA()

IF nOpca == 1
   IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,'DEPOIS_ESTORNO_NOTA'),)
EndIf

Return .T.

*------------------------------*
Static Function ValEstorno()
*------------------------------*

Private lEstNF := .T.

If EasyEntryPoint("EICDI554")
   ExecBlock("EICDI554", .F., .F., "VALIDA_ESTORNO")
EndIf

Return lEstNf

*------------------------------------------------*
Function DI554ValTxTela()
*------------------------------------------------*
LOCAL oDlg, nLin, nCoL1, nCoL2, nCoL3, nCoL4, nCoL5, nCoL6, aTB_CpoTot,oMarkTot ,oPanelTop, oPanelBtn
LOCAL nDespBase := nSomaNoCIF + nPSomaNoCIF
Local nBaseICMS := nSomaBaseICMS + nPSomaBaseICMS + nSomaDespRatAdicao
nLin :=005
nCoL1:=005
nCoL2:=040
nCoL3:=100
nCoL4:=145
nCoL5:=205
nCoL6:=246
aTB_CpoTot:={}
AADD(aTB_CpoTot,{"W9_MOE_FOB" ,,AVSX3("W9_MOE_FOB",5),AVSX3("W9_MOE_FOB",6)})
AADD(aTB_CpoTot,{"W9_FOB_TOT" ,,AVSX3("W9_FOB_TOT",5),AVSX3("W9_FOB_TOT",6)})
AADD(aTB_CpoTot,{"W9_INLAND"  ,,AVSX3("W9_INLAND" ,5),AVSX3("W9_INLAND" ,6)})
AADD(aTB_CpoTot,{"W9_PACKING" ,,AVSX3("W9_PACKING",5),AVSX3("W9_PACKING",6)})
AADD(aTB_CpoTot,{"W9_DESCONT" ,,AVSX3("W9_DESCONT",5),AVSX3("W9_DESCONT",6)})
AADD(aTB_CpoTot,{"W9_FRETEIN" ,,AVSX3("W9_FRETEIN",5),AVSX3("W9_FRETEIN",6)})
AADD(aTB_CpoTot,{"W9_OUTDESP" ,,AVSX3("W9_OUTDESP",5),AVSX3("W9_OUTDESP",6)})
// EOB - 14/07/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP
IF lSegInc
   AADD(aTB_CpoTot,{"W9_SEGURO",,AVSX3("W9_SEGURO",5),AVSX3("W9_SEGURO",6)})
ENDIF
AADD(aTB_CpoTot,{"W6_FOB_TOT" ,,"Total Geral"        ,AVSX3("W6_FOB_TOT",6)})

IF Work_Tot->(BOF()) .AND. Work_Tot->(EOF())
   Processa({|| DI554SomaTotais() },STR0292)  //"Somando totais"
ENDIF

DEFINE MSDIALOG oDlg TITLE STR0279 ; //"Visualiza Valores/Taxas"
       FROM oMainWnd:nTop+099,oMainWnd:nLeft TO oMainWnd:nBottom-50,oMainWnd:nRight-20;
       OF oMainWnd PIXEL
 @ 00,00 MsPanel oPanelTOP Prompt "" Size nCoL6+60,70 of oDlg //LRL 08/04/04 Painel para alinhamento MDI.
// @ nLin,nCoL1 SAY STR0042 SIZE 57,7 PIXEL//"FOB (R$)"
 @ nLin,nCoL1 SAY STR0042 SIZE 57,7 of oPanelTop PIXEL//"FOB (R$)"       //acb - 05/02/2010
 @ nLin,nCoL2 MSGET nFOB_R PICTURE PICT15_2 SIZE 57, 7 OF oDlg WHEN .F. RIGHT  PIXEL

// @ nLin,nCoL3 SAY STR0043 SIZE 57,7 PIXEL//"Frete R$"
 @ nLin,nCoL3 SAY STR0043 SIZE 57,7 of oPanelTop PIXEL//"Frete R$"       //acb - 05/02/2010
 @ nLin,nCoL4 MSGET n_FRETE PICTURE PICT15_2 SIZE 57, 7 OF oDlg WHEN .F. RIGHT  PIXEL

// @ nLin,nCoL5 SAY STR0044    SIZE 57,7 PIXEL //"Seguro R$"
 @ nLin,nCoL5 SAY STR0044    SIZE 57,7 of oPanelTop PIXEL      //acb - 05/02/2010
 @ nLin,nCoL6 MSGET n_SEGURO PICTURE PICT15_2 SIZE 57, 7 OF oDlg WHEN .F. RIGHT  PIXEL

 nLin+=12
// @ nLin,nCoL1 SAY STR0071  SIZE 57,7  PIXEL //"Despesas"
 @ nLin,nCoL1 SAY STR0071  SIZE 57,7 of oPanelTop  PIXEL       //acb - 05/02/2010
 @ nLin,nCoL2 MSGET n_Desp PICTURE PICT15_2 SIZE 57, 7 OF oDlg WHEN .F. RIGHT  PIXEL

// @ nLin,nCoL3 SAY AVSX3("W6_TX_US_D",5) SIZE 57,7 PIXEL
 @ nLin,nCoL3 SAY AVSX3("W6_TX_US_D",5) SIZE 57,7 of oPanelTop PIXEL      //acb - 05/02/2010
 @ nLin,nCoL4 MSGET SW6->W6_TX_US_D PICTURE PICT15_8 SIZE 57, 7 OF oDlg WHEN .F. RIGHT PIXEL

// @ nLin,nCoL5 SAY STR0284 SIZE 57,7  PIXEL//"Desp. Base (R$)"
 @ nLin,nCoL5 SAY STR0284 SIZE 57,7 of oPanelTop PIXEL//"Desp. Base (R$)"       //acb - 05/02/2010
 //MFR 27/10/2020 OSSME-5341
 @ nLin,nCoL6 MSGET nDespBase PICTURE PICT15_2 SIZE 57, 7 OF oDlg WHEN .F. RIGHT PIXEL

 nLin+=12

// @ nLin,nCoL1 SAY STR0048  SIZE 57,7  PIXEL//"I.I. (R$)"
 @ nLin,nCoL1 SAY STR0048  SIZE 57,7 of oPanelTop PIXEL//"I.I. (R$)"       //acb - 05/02/2010
 @ nLin,nCoL2 MSGET n_II   PICTURE PICT15_2 SIZE 57, 7 OF oDlg WHEN .F. RIGHT PIXEL

// @ nLin,nCoL3 SAY STR0050  SIZE 57,7 PIXEL//"I.P.I. (R$)"
 @ nLin,nCoL3 SAY STR0050  SIZE 57,7 of oPanelTop PIXEL//"I.P.I. (R$)"        //acb - 05/02/2010
 @ nLin,nCoL4 MSGET n_IPI  PICTURE PICT15_2 SIZE 57, 7 OF oDlg WHEN .F. RIGHT PIXEL

// @ nLin,nCoL5 SAY STR0045  SIZE 57,7  PIXEL//"C.I.F. (R$)"
 @ nLin,nCoL5 SAY STR0045  SIZE 57,7 of oPanelTop PIXEL//"C.I.F. (R$)"    //acb - 05/02/2010
 @ nLin,nCoL6 MSGET n_CIF  PICTURE PICT15_2 SIZE 57, 7 OF oDlg WHEN .F. RIGHT PIXEL//oSayCIF VAR

// LDR - 05/11/04
 IF lMV_PIS_EIC

    nLin+=12
//    @ nLin,nCoL1 SAY AVSX3("W8_VLRPIS",5)  SIZE 57,7  PIXEL//"PIS "
    @ nLin,nCoL1 SAY AVSX3("W8_VLRPIS",5)  SIZE 57,7 of oPanelTop PIXEL//"PIS "     //acb - 05/02/2010
    @ nLin,nCoL2 MSGET n_PIS   PICTURE PICT15_2 SIZE 57, 7 OF oDlg WHEN .F. RIGHT PIXEL

//    @ nLin,nCoL3 SAY AVSX3("W8_VLRCOF",5)  SIZE 57,7 PIXEL//"COFINS"
    @ nLin,nCoL3 SAY AVSX3("W8_VLRCOF",5)  SIZE 57,7 of oPanelTop PIXEL//"COFINS"    //acb - 05/02/2010
    @ nLin,nCoL4 MSGET n_COFINS  PICTURE PICT15_2 SIZE 57, 7 OF oDlg WHEN .F. RIGHT PIXEL

//    @ nLin,nCoL5 SAY "Desp.Base ICMS"  SIZE 57,7  PIXEL
    @ nLin,nCoL5 SAY STR0335  SIZE 57,7 of oPanelTop PIXEL   //acb - 05/02/2010 //STR0335 "Desp.Base ICMS"
    @ nLin,nCoL6 MSGET nBaseICMS  PICTURE PICT15_2 SIZE 57, 7 OF oDlg WHEN .F. RIGHT PIXEL//oSayCIF VAR

 ENDIF
// LDR - 05/11/04

 nLin+=13
// @ nLin,nCoL1 SAY cTotal SIZE 150,7 PIXEL //"Total Geral CIF + II + IPI + ICMS + Outras Desp. (R$)"
 @ nLin,nCoL1 SAY cTotal SIZE 150,7 of oPanelTop PIXEL //"Total Geral CIF + II + IPI + ICMS + Outras Desp. (R$)"   //acb - 05/02/2010
 @ nLin,nCoL4 MSGET n_VlTota PICTURE PICT15_2 SIZE 57, 7 OF oDlg WHEN .F. RIGHT PIXEL

// @ nLin,nCoL5 SAY STR0052  SIZE 57,7    PIXEL//"I.C.M.S. (R$)"
 @ nLin,nCoL5 SAY STR0052  SIZE 57,7 of oPanelTop PIXEL//"I.C.M.S. (R$)"   //acb - 05/02/2010
 @ nLin,nCoL6 MSGET n_ICMS PICTURE PICT15_2 SIZE 57, 7 OF oDlg WHEN .F. RIGHT PIXEL

 nLin+=14
 @ 1.3,1.5 TO nLin,nCoL6+60  PIXEL

 oMarkTot:=MSSELECT():New("Work_Tot",,,aTB_CpoTot,lInverte,cMarca,{nLin,1,((oDlg:nClientHeight-4)/2)-20,(oDlg:nClientWidth-4)/2})
 oMarkTot:oBrowse:bWhen:={||DBSELECTAREA("Work_Tot"),.T.}

 @00,00 MsPanel oPanelBTN Prompt "" Size nCoL6+60,24 of oDlg

 DEFINE SBUTTON FROM 5,5 TYPE 01 ACTION oDlg:End() ENABLE  of oPanelBtn

 oDlg:lMaximized:=.T.
 oPanelTOP:Align:=CONTROL_ALIGN_TOP
 oPanelBtn:Align:=CONTROL_ALIGN_BOTTOM
 oMarkTot:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

 ACTIVATE DIALOG oDlg ON INIT (oMarkTot:oBrowse:Refresh())  //LRL 07/04/04 -Alinhament MDI. //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

RETURN .T.
*------------------------------------*
Function DI554SomaTotais()
*------------------------------------*
LOCAL cFilSW8:=xFilial("SW8")
LOCAL cFilSW9:=xFilial("SW9")
PRIVATE lTotaisInv:=.F.

//Work_Tot->(avzap())

IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"TOTAIS_1"),)

ProcRegua(SW8->(LASTREC()))
SW8->(DBSETORDER(1))
SW9->(DBSETORDER(1))

SW8->(DBSEEK(cFilSW8+SW6->W6_HAWB))

DO While !SW8->(Eof()) .AND. ;
          SW8->W8_FILIAL == cFilSW8 .AND.;
          SW8->W8_HAWB   == SW6->W6_HAWB

   IncProc(STR0293+SW8->W8_INVOICE) //"Somando Invoice: "

   //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
   SW9->(DBSEEK(cFilSW9+SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8", "W8_FORLOJ")+SW8->W8_HAWB))
   IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"ACERTA_SEEK1"),)

   IF lTotaisInv
      Work_Tot->(DBSETORDER(1))
      IF !Work_Tot->(DBSEEK('1'+SW8->W8_INVOICE+SW8->W8_FORN))
          Work_Tot->(DBAPPEND())
          Work_Tot->WKCODIGO  :='1'
          Work_Tot->W9_INVOICE:=SW8->W8_INVOICE
          Work_Tot->W9_FORN   :=SW8->W8_FORN
          Work_Tot->W9_MOE_FOB:=SW9->W9_MOE_FOB
      ENDIF
      Work_Tot->W9_FOB_TOT+=(SW8->W8_PRECO*SW8->W8_QTDE)
      Work_Tot->W9_INLAND +=SW8->W8_INLAND
      Work_Tot->W9_PACKING+=SW8->W8_PACKING
      Work_Tot->W9_DESCONT+=IF(!lIn327,SW8->W8_DESCONT,0) // Bete - 24/02/05
      Work_Tot->W9_FRETEIN+=SW8->W8_FRETEIN
      Work_Tot->W9_OUTDESP+=SW8->W8_OUTDESP
      // EOB - 14/07/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
      IF lSegInc
         Work_Tot->W9_SEGURO+=SW8->W8_SEGURO
      ENDIF
      Work_Tot->W6_FOB_TOT+=DI500RetVal("ITEM_INV", "TAB", .T.) // EOB - 14/07/08 - chamada da função DI500RetVal
      IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"TOTAIS_2"),)
   ENDIF
   Work_Tot->(DBSETORDER(2))
   IF !Work_Tot->(DBSEEK('2'+SW9->W9_MOE_FOB))
      Work_Tot->(DBAPPEND())
      Work_Tot->WKCODIGO  :='2'
      Work_Tot->W9_INVOICE:=STR0294 //"Total Moeda:"
      Work_Tot->W9_MOE_FOB:=SW9->W9_MOE_FOB
   ENDIF
   Work_Tot->W9_FOB_TOT+=(SW8->W8_PRECO*SW8->W8_QTDE)
   Work_Tot->W9_INLAND +=SW8->W8_INLAND
   Work_Tot->W9_PACKING+=SW8->W8_PACKING
   Work_Tot->W9_DESCONT+=IF(!lIn327,SW8->W8_DESCONT,0) // Bete - 24/02/05
   Work_Tot->W9_FRETEIN+=SW8->W8_FRETEIN
   Work_Tot->W9_OUTDESP+=SW8->W8_OUTDESP
   // EOB - 14/07/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
   IF lSegInc
      Work_Tot->W9_SEGURO+=SW8->W8_SEGURO
   ENDIF
   Work_Tot->W6_FOB_TOT+=DI500RetVal("ITEM_INV", "TAB", .T.) // EOB - 14/07/08 - chamada da função DI500RetVal
   IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"TOTAIS_3"),)
   SW8->(DBSKIP())
ENDDO
Work_TOT->(DBGOTOP())
RETURN .T.

*-----------------------------------------*
Function DI554DespTela()
*-----------------------------------------*
LOCAL oDlg,TB_Campos:={}

aAdd(TB_Campos,{"WKDESP"   ,,STR0071}) //"Despesas"
aAdd(TB_Campos,{"WKVALOR"  ,,STR0281,"@E 99,999,999,999.99"}) //"Valor (R$)"
aAdd(TB_Campos,{{|| DI554SimNao(Work4->WKBASECUS,1)},,AVSX3("YB_BASECUS",5)})
aAdd(TB_Campos,{{|| DI554SimNao(Work4->WKBASEIMP,2)},,AVSX3("YB_BASEIMP",5)})
aAdd(TB_Campos,{{|| DI554SimNao(Work4->WKBASEICM,2)},,AVSX3("YB_BASEICM",5)})
aAdd(TB_Campos,{{|| DI554SimNao(Work4->WKICMS_UF,2)},,AVSX3("YB_BASEICM",5)+" - "+Alltrim(SYT->YT_ESTADO)})
aAdd(TB_Campos,{{|| DI554SimNao(Work4->WKICMSNFC,2)},,AVSX3("YB_ICMSNFC",5)})
aAdd(TB_Campos,{{|| DI554SimNao(Work4->WKRATPESO,2)},,AVSX3("YB_RATPESO",5)})
aAdd(TB_Campos,{"WKNOTA"   ,,AVSX3("WD_NF_COMP",5)})
aAdd(TB_Campos,{"WKSERIE"  ,,AVSX3("WD_SE_NFC" ,5)})

oMainWnd:ReadClientCoords()
DEFINE MSDIALOG oDlg TITLE STR0295; //"Visualiza Despesas"
       FROM 000,oMainWnd:nLeft TO 240,oMainWnd:nRight-25 OF oMainWnd PIXEL

  Work4->(dBGoTop())

  oMark2:=oSend(MsSelect(),"New","Work4",,,TB_Campos,.F.,@cMarca,{005,005,100,(oDlg:nClientWidth-4)/2})

  DEFINE SBUTTON FROM 105,oMainWnd:nLeft+10 TYPE 01 ACTION oDlg:End() ENABLE

ACTIVATE DIALOG oDlg ON INIT (oMark2:oBrowse:Refresh()) CENTERED

RETURN .T.
*-----------------------------------------*
Function DI554SimNao(cCampo,nBranco)
*-----------------------------------------*
IF AT(SWD->(LEFT(Work4->WKDESP,1)),"129") =0 .AND. Work4->WKDESP <> "701"
   DO CASE
      CASE cCampo  $ cSim ; RETURN STR0261//"1-Sim"
      CASE cCampo  $ cNao ; RETURN STR0262//"2-Não"
      CASE nBranco = 1    ; RETURN STR0261//"1-Sim"
      CASE nBranco = 2    ; RETURN STR0262//"2-Não"
   ENDCASE
ENDIF
RETURN "   "

*-----------------------------------*
Function DI554Itens(bDDIFor,bDDIWhi)
*-----------------------------------*
LOCAL lInverte := .F., oDlg, oPanel //ACB - 06/12/2010 - Inclusão da variavel oPanel para deixar a tela no padrão MDI
LOCAL cBotao:=IF(nTipoNF # CUSTO_REAL,STR0282,STR0283) //"&Gera NFE"###"&Grava"
LOCAL nCol:=IF(!lNFAutomatica.AND.nTipoNF#CUSTO_REAL,31,17)
PRIVATE nOpca := 0 // POR CAUSA DO BOTAO DO RDMAKE

DO WHILE .T.

   Work1->(DBSETORDER(5))
   Work1->(DBGOTOP())
   nOpca:=0
   lRet:=.T.//AWF 31/07/2014 - LOGIX - Se se gerou as notas e for integrado com o Logix retorna .F. para sair da tela principal de geracao de nota

   oMainWnd:ReadClientCoords()
   DEFINE MSDIALOG oDlg TITLE STR0097 ; //"Itens da NF's"
      FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
      OF oMainWnd PIXEL

   oMark:= MsSelect():New("Work1","WKFLAG",,TB_Campos2,@lInverte,@cMarca,{nCol,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2})
   IF lNFAutomatica .OR. nTipoNF == CUSTO_REAL
      oMark:bAval:={||DI554It_Alt(), oMark:oBrowse:Refresh()}
   ENDIF

   @ 00,00 MsPanel oPanel Prompt "" Size 60,30 of oDlg //ACB - 06/12/2010 - Painel para alinhamento MDI
   IF EasyEntryPoint("ICPADDI0")
      Execblock("ICPADDI0",.F.,.F.,"BOTAO")
   Else
      If IsMemVar("oDlgPrv") .And. ValType(oDlgPrv) == "O" //Type("oDlgPrv") == "O"
         @ 004,055 BUTTON STR0382 SIZE 35,11 ACTION (IF(DI154Gerou(),Processa({|| DI154PRTXT()},STR0031),)) PIXEL // EXPORTA
      Else
         @ 1.5,040 BUTTON STR0382 SIZE 37,11 ACTION (IF(DI154Gerou(),Processa({|| DI154PRTXT()},STR0031),)) PIXEL // EXPORTA
      EndIf
   EndIf
   IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"BOTAO"),)

   @ 04,095 BUTTON STR0102  SIZE 35,11 ACTION (DI554It_Alt(),oMark:oBrowse:Refresh());
                                       OF oDlg PIXEL WHEN !lGerouNFE //"&Altera Item"

   @ 04,135 BUTTON STR0272  SIZE 35,11 ACTION (nOpca:=1,oDlg:End());
                                       OF oDlg PIXEL WHEN (nTipoNF#CUSTO_REAL.OR.lGerouNFE)//"&Impressão"

   @ 04,175 BUTTON STR0101  SIZE 30,11 ACTION (DI554Pesquisa(),oMark:oBrowse:Refresh());
                                       OF oDlg PIXEL //"&Pesquisa"

   IF SW6->W6_IMPCO == "1" .and. !EasyGParam("MV_EIC_PCO",,.F.)  // GFP - 03/11/2014 - Quando o processo for Conta e Ordem, o sistema chama a tela de totais do EICCO100.
      @ 04,210 BUTTON STR0100  SIZE 30,11 ACTION (PCOTotDesp(xFilial("EIW")+SW6->W6_HAWB));
                                          OF oDlg PIXEL //"&Totais"
   ELSE
      @ 04,210 BUTTON STR0100  SIZE 30,11 ACTION (DIMostraTotais(),oMark:oBrowse:Refresh());
                                          OF oDlg PIXEL //"&Totais"
   ENDIF

   @ 04,245 BUTTON cBotao   SIZE 30,11 ACTION (nOpca:=2,oDlg:End());
                                       OF oDlg PIXEL WHEN (lGeraNF.AND.!lGerouNFE)

   @ 04,280 BUTTON STR0103  SIZE 30,11 ACTION (nOpca:=0,oDlg:End());
                                       OF oDlg PIXEL //"&Sair"

   IF !lNFAutomatica .AND. nTipoNF # CUSTO_REAL
      @ 17,205 BUTTON STR0098 SIZE 50,11 ACTION (DIMarcados(.T.),oMark:oBrowse:Refresh()) OF oDlg PIXEL WHEN !lGerouNFE//"A&ltera Marcados"

      @ 17,255 BUTTON STR0099 SIZE 55,11 ACTION (DIMarcados(.F.),oMark:oBrowse:Refresh()) OF oDlg PIXEL WHEN !lGerouNFE//"&Marca/Desm. Todos"
   ENDIF
   oDlg:lMaximized:=.T.//ACB - 06/12/2010
   oPanel:Align:=CONTROL_ALIGN_TOP
   oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
   oMark:oBrowse:Refresh() //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

//   ACTIVATE MSDIALOG oDlg ON INIT (oMark:oBrowse:Refresh())
 //  ACTIVATE MSDIALOG oDlg ON INIT (oPanel:Align:=CONTROL_ALIGN_TOP,oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT, oMark:oBrowse:Refresh()) //ACB - 06/12/2010 -Alinhamento MDI //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   ACTIVATE MSDIALOG oDlg // BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   IF nOpca=1
      EICDI155(nTipoNF)
      LOOP
   ENDIF

   IF nOpca=2
      Processa({|| DI554GerNF(@lGerouNFE,bDDIFor,bDDIWhi)},STR0104) //"Gera‡Æo de NF's"
      If !lGerouNFE
         LOOP
      //ELSEIF AvFlags("EIC_EAI")//AWF 31/07/2014 - LOGIX - Se se gerou as notas e for integrado com o Logix retorna .F. para sair da tela principal de geracao de nota
      //   lRet:=.F.
      //   EXIT
      ENDIF
   ENDIF

   IF nOpca=0
      EXIT
   ENDIF

ENDDO

Work2->(DBGOTOP())

RETURN lRet//AWF 31/07/2014 - LOGIX - Se se gerou as notas e for integrado com o Logix retorna .F. para sair da tela principal de geracao de nota


*---------------------------------------*
STATIC Function DIMarcados(lAlt)
*---------------------------------------*
LOCAL oDlg, nOpca, nRecno:=Work1->(RECNO())
LOCAL cTit  :=IF(lAlt,STR0105,STR0106) //"Altera‡Æo dos Itens Marcados"###"Marca / Desmarca Itens"
LOCAL bValid:=IF(lAlt,{|| DI554Valid("NFE")      .AND.;
                          DI554Valid("SERIE",.F.).AND.;
                          DI554Valid("DATA")},{||.T.})
LOCAL nCo1:=0.8, nCo2:=6.3,nOrd:=Work1->(INDEXORD())
LOCAL nMarca:=1, cCFO:= IF(EICLOJA(),Work1->WKFORN+Work1->WKLOJA+Work1->WK_CFO ,Work1->WKFORN+Work1->WK_CFO),cMarcaNew,bWhile
IF lAlt
   nOpca:=.T.
   Work1->( DBGOTOP() )
   Work1->( DBEVAL({|| nOpca:=!Work1->WKFLAG==cMarca },,{||nOpca}) )
   Work1->( DBGOTO(nRecno) )
   IF nOpca
      Help("",1,"AVG0000803")
//    MSGinfo(0107,0108) //"Não existe registros marcados"###"Informação"
      RETURN .F.
   Endif
Endif

cNumNFE  :=Work1->WK_NFE
cSerieNFE:=Work1->WK_SE_NFE
dDtNFE   :=dDataBase
IF !EMPTY(Work1->WK_DT_NFE)
   dDtNFE:=Work1->WK_DT_NFE
ENDIF
nOpca    :=0

DEFINE MSDIALOG oDlg TITLE cTit FROM 9,10 TO 18,48 Of oMainWnd

  IF lAlt

     @1.2,nCo1 SAY STR0094 //"N§ da N.F."
     @2.2,nCo1 SAY STR0095 //"S‚rie"
     @3.2,nCo1 SAY STR0096 //"Data da N.F."

     @1.2,nCo2 MSGET cNumNFE   PICTURE "@!"  SIZE 50,8
     @2.2,nCo2 MSGET cSerieNFE PICTURE "@!"  SIZE 15,8
     @3.2,nCo2 MSGET dDtNFE    PICTURE "@D"  SIZE 45,8

  ELSE

     @08,05 TO 45,70 OF oDlg PIXEL

     @18,10 RADIO nMarca ITEMS STR0296,STR0110 3D SIZE 49,12 PIXEL //###"&Todos os Itens" //"&Por Forn. + CFO"

  ENDIF

  @14,105 BUTTON STR0111 SIZE 25,11 ACTION (If(EVAL(bValid),(nOpca:=1,oDlg:End()),)) OF oDlg PIXEL //"&OK"

  @34,105 BUTTON STR0103 SIZE 25,11 ACTION (nOpca:=0,oDlg:End())                     OF oDlg PIXEL //"&Sair"


ACTIVATE MSDIALOG oDlg CENTERED

If nOpca = 0
RETURN .F.
Endif

cMarcaNew:=IF(Work1->WKFLAG==cMarca,"  ",cMarca)

bWhile:={||.T.}

Work1->(DBSETORDER(5))
Work1->(DBGOTOP())

IF !lAlt .AND. nMarca == 1
   IF EICLOJA()
      bWhile:={|| cCFO == Work1->WKFORN+Work1->WKLOJA+Work1->WK_CFO }
   ELSE
      bWhile:={|| cCFO == Work1->WKFORN+Work1->WK_CFO }
   ENDIF
   Work1->(DBSEEK(cCFO))
ENDIF

Processa({|| DIGravaAlt(lAlt,bWhile,cMarcaNew)},STR0112) //"Alterando Itens..."

Work1->(DBSETORDER(nOrd))
Work1->(DBGOTO(nRecno))


RETURN .T.

*----------------------------------------------------------------------------*
STATIC Function DIGravaAlt(lAlt,bWhile,cMarcaNew)
*----------------------------------------------------------------------------*

ProcRegua(Work1->(LASTREC()))

DO WHILE !Work1->(EOF()) .AND. EVAL(bWhile)

   IncProc(STR0113+' '+Work1->WKCOD_I) //"Processando Item: "

   IF Work1->WKFLAG == cMarca .AND. lAlt .AND. DI554ValNF(.T.,cNumNFE,cSerieNFE)  // GFP - 26/06/2015

      Work1->WK_NFE   := cNumNFE
      Work1->WK_SE_NFE:= cSerieNFE
      Work1->WK_DT_NFE:= dDtNFE
      Work1->WKFLAG   := '  '

      Work3->(DBSEEK(Work1->(RECNO())))

      DO WHILE !Work3->(EOF()) .AND. Work1->(RECNO()) == Work3->WKRECNO

         Work3->WK_NF_COMP:=cNumNFE
         Work3->WK_SE_NFC :=cSerieNFE
         Work3->WK_DT_NFC :=dDtNFE
         Work3->(DBSKIP())

      ENDDO

   ELSEIF !lAlt

      Work1->WKFLAG := cMarcaNew

   ENDIF

   Work1->(DBSKIP())

ENDDO

RETURN .T.

*--------------------------------------*
STATIC Function DIMostraTotais()
*--------------------------------------*
LOCAL nCo1:=0.5, nCo2:=5, nCo3:=12.5, nCo4:=19
LOCAL nTotNFE:= nVlTota:= 0
PRIVATE nFobR:=nFrete:=nSeguro:=nCIF:=nII:=nIPI:=nDespBaseICMS:=nDespBasCIF:=0   //nSomaNoCIF:=nPSomaNoCIF:=
PRIVATE nBaseIPI:=nBaseICMS:=nICMS  :=nDesp  :=nDIFOB:=0,lSair:=.F.
PRIVATE nBASPIS :=nVLRPIS  :=nBASCOF:=nVLRCOF:= /*nPSomaBaseICMS :=*/ ntxSisc:= 0
Private oGet_Esc, cGet_Esc := "" //RRV - 19/09/2012 - Tratamento para o "ESC" to teclado funcionar corretamente
IF EasyEntryPoint("EICDI554")
   Execblock("EICDI554",.F.,.F.,'TELA_TOTAIS')
   IF lSair
      RETURN .T.
   ENDIF
ENDIF

Processa({|| DI554Soma()},STR0114) //"Calculando Totais"

//DFS - Validação para o campo Desp. Base ICMS
if EasyGParam("MV_RATACRE",,.F.)
   IF EMPTY(nDespBasCIF)
      nDespBasCIF:=nSomaNoCIF + nPSomaNoCIF
   ENDIF
endif

//DFS - Validação para o campo Desp. Base ICMS
//LGS - 13/11/13 - Incluido para Soma o Valor Devido Anti Dupin quando tiver calculado no processo.
IF EMPTY(nDespBaseICMS)
   If EasyGParam("MV_ANDUBIC",,.F.) .AND. !Empty(EIJ->EIJ_VLD_DU)  // GFP - 11/12/2013
      nDespBaseICMS:=MDI_OUTR + nPSomaBaseICMS + nTxSisc + nSomaDespRatAdicao
   Else
   	  nDespBaseICMS:=nSomaBaseICMS + nPSomaBaseICMS + nTxSisc + nSomaDespRatAdicao
   EndIf
ENDIF

if !(lTemCusto .And. nTipoNF == CUSTO_REAL) .And. !lNFFilha3 //LGS-05/05/14
   nDesp+= If(EasyGParam("MV_EIC0037",,.F.),nDespBaseICMS,0)   // GFP - 21/10/2013
Endif

nVlTota := DITRANS(nCIF + nII + nIPI + nICMS + nVLRPIS + nVLRCOF,2)

IF !lNFFilha3
   IF nTipoNF <> CUSTO_REAL
      nVlTota += DITRANS(nDespBaseICMS,2)
   ELSE
      IF !lTemCusto
         IF ! EasyGParam("MV_LERNOTA",,.F.)
            nVlTota += DITRANS(nDespBaseICMS,2)
         else
            nVlTota += ditrans( nVlrCustoSNW ,2)
         ENDIF
      ENDIF
   ENDIF
   // MFR 28/09/2021 OSSME-6247
//   IF nTipoNF == NFE_UNICA 
   IF nTipoNF == NFE_UNICA .OR. nTipoNF == CUSTO_REAL
      nVlTota += nDesp
   ENDIF
ENDIF

DEFINE MSDIALOG oDlg TITLE STR0115 FROM 0,10 TO 18,66 Of oMainWnd //"TOTAIS"

nLinha := 1.2
@nLinha,nCo1 SAY STR0042 //"FOB (R$)"
@nLinha,nCo2 MSGET nFobR WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
nLinha+=1

@nLinha,nCo1 SAY STR0043 //"Frete (R$)"
@nLinha,nCo2 MSGET nFrete WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
nLinha+=1

@nLinha,nCo1 SAY STR0044 //"Seguro (R$)"
@nLinha,nCo2 MSGET nSeguro WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
nLinha+=1

IF !EMPTY(nDespBasCIF) .AND. !EMPTY(nCIF)
   @nLinha,nCo1 SAY "Desp Base CIF (R$)"
   @nLinha,nCo2 MSGET nDespBasCIF WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
   nLinha+=1
ENDIF

@nLinha,nCo1 SAY STR0045 //"C.I.F. (R$)"
@nLinha,nCo2 MSGET nCIF WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
nLinha+=1

@nLinha,nCo1 SAY STR0048 //"I.I. (R$)"
@nLinha,nCo2 MSGET nII  WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
nLinha+=1

@nLinha,nCo1 SAY STR0060 //"Base I.P.I. (R$)"
@nLinha,nCo2 MSGET nBaseIPI  WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
nLinha+=1

@nLinha,nCo1 SAY STR0050 //"I.P.I. (R$)"
@nLinha,nCo2 MSGET nIPI  WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT

nLinha:=1.2

IF lMV_PIS_EIC
   @nLinha,nCo3 SAY AVSX3("W8_BASPIS",5)
   @nLinha,nCo4 MSGET nBASPIS WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
   nLinha+=1

   @nLinha,nCo3 SAY AVSX3("W8_VLRPIS",5)
   @nLinha,nCo4 MSGET nVLRPIS WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
   nLinha+=1

   @nLinha,nCo3 SAY AVSX3("W8_BASCOF",5)
   @nLinha,nCo4 MSGET nBASCOF WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
   nLinha+=1

   @nLinha,nCo3 SAY AVSX3("W8_VLRCOF",5)
   @nLinha,nCo4 MSGET nVLRCOF WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
   nLinha+=1
ENDIF

IF !EMPTY(nDespBaseICMS)
   lVlrOk := IF (EasyGParam("MV_NFFILHA",,"0") $ "1,3",.T.,.F.)//LGS-05/05/14
   //TRP - 10/06/11 - Caso seja Nota Filha e o parâmetro MV_NFFILHA seja 0 ou 2, não mostrar cálculo das despesas base ICMS na tela de Totais.
   If lMV_NF_MAE .AND. nTipoNF == NFE_FILHA .And. !lVlrOk //EasyGParam("MV_NFFILHA",,"0") <> "1" //LGS-05/05/2014
      nVlTota:= nVlTota - nDespBaseICMS
      nDespBaseICMS:= 0
   Endif

   @nLinha,nCo3 SAY STR0336 //STR0336 "Desp. Base ICMS (R$)"
   @nLinha,nCo4 MSGET nDespBaseICMS WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
   nLinha+=1
ENDIF

IF !EMPTY(nBaseICMS)
   @nLinha,nCo3 SAY STR0062 //"Base I.C.M.S. (R$)"
   @nLinha,nCo4 MSGET nBaseICMS WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
   nLinha+=1
ENDIF

@nLinha,nCo3 SAY STR0052 //"I.C.M.S. (R$)"
@nLinha,nCo4 MSGET nICMS     WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
nLinha+=1
IF !EMPTY(nDesp) .AND. nTipoNF > 1 .AND. nTipoNF <= 4
   @nLinha,nCo3 SAY STR0053 //"Outras Desp.(R$)"
   @nLinha,nCo4 MSGET nDesp  WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
   nLinha+=1
ENDIF
@nLinha,nCo3 SAY STR0082 //"Total Geral"
@nLinha,nCo4 MSGET nVlTota   WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
nLinha+=1

@1200,1200 MsGet oGet_Esc Var cGet_Esc Of oDlg //RRV - 19/09/2012 - Tratamento para o "ESC" to teclado funcionar corretamente
oGet_Esc:SetFocus()

ACTIVATE MSDIALOG oDlg CENTERED

RETURN NIL

*----------------------*
Function DI554Soma()
*----------------------*
LOCAL nRecno:=Work1->(RECNO())

ProcRegua( Work1->(LASTREC()) )
Work1->(DBGOTOP())

DO WHILE !Work1->(EOF())
   IncProc()
   nFobR    +=Work1->WKFOB_R
   nFrete   +=Work1->WKFRETE
   nSeguro  +=Work1->WKSEGURO
   IF nTipoNF <> NFE_COMPLEMEN //LRS - 11/04/2018
      nCIF     +=Work1->WKCIF
   EndIF
   nII      +=Work1->WKIIVAL
   nBaseIPI +=Work1->WKIPIBASE
   nIPI     +=Work1->WKIPIVAL
   nBaseICMS+=Work1->WKBASEICMS
   nICMS    +=Work1->WKVL_ICM
   nDIFOB   +=Work1->WKVALMERC
   nDesp    +=Work1->WKOUT_DESP
   nBASPIS  +=Work1->WKBASPIS
   nVLRPIS  +=Work1->WKVLRPIS
   nBASCOF  +=Work1->WKBASCOF
   nVLRCOF  +=Work1->WKVLRCOF
   nDespBaseICMS += Work1->WKDESPICM
   // MDI_OUTR +=Work1->WKDESPICM
   Work1->(DBSKIP())
ENDDO

Work1->(DBGOTO(nRecno))

RETURN .T.

*----------------------*
Function DI554It_Alt()
*----------------------*
LOCAL nCif, oDlg, nOpca:=0, nRecno:=Work1->(RECNO())
LOCAL cConfirma:=STR0121 //"Recalcula  FOB / CIF / Frete / Seguro ?"
LOCAL cTit2    :=STR0122 //"Valor da Mercadoria Alterado"
LOCAL cTit     :=STR0123 //"Altera‡Æo do Item Atual"

LOCAL nFOBRS  :=Work1->WKFOB_R
LOCAL nSeguro :=Work1->WKSEGURO
LOCAL nFrete  :=Work1->WKFRETE
LOCAL nVLCIF  :=Work1->WKCIF
LOCAL nVLMERC :=Work1->WKVALMERC

LOCAL nVlII   :=Work1->WKIIVAL
LOCAL nBaseIPI:=Work1->WKIPIBASE
LOCAL nVlIPI  :=Work1->WKIPIVAL
LOCAL nVlICMS :=Work1->WKVL_ICM
LOCAL nBasICMS:=Work1->WKBASEICMS
LOCAL n_DespBICMS:=Work1->WKDESPICM // SVG - 06/09/2011 -

LOCAL nCFOBRS  :=Work1->WKFOB_R
LOCAL nCSeguro :=Work1->WKSEGURO
LOCAL nCFrete  :=Work1->WKFRETE
LOCAL nCVLCIF  :=Work1->WKCIF
LOCAL nCVLMERC :=Work1->WKVALMERC
LOCAL nCVlII   :=Work1->WKIIVAL
LOCAL nCBaseIPI:=Work1->WKIPIBASE
LOCAL nCVlIPI  :=Work1->WKIPIVAL
LOCAL nCVlICMS :=Work1->WKVL_ICM
LOCAL nBASPIS  :=Work1->WKBASPIS // JBS - 02/06/2004
LOCAL nVLRPIS  :=Work1->WKVLRPIS // JBS - 02/06/2004
LOCAL nBASCOF  :=Work1->WKBASCOF // JBS - 02/06/2004
LOCAL nVLRCOF  :=Work1->WKVLRCOF // JBS - 02/06/2004
LOCAL nPrecoUnit:=Work1->WKPRUNI

//LRS - 05/04/2017 - Adicionado os campos de Credito presumido na tela de alteração de item
Local nVlCMDIF  := Work1->WKVL_ICM_D
Local nVlICMCP  := Work1->WKVLCREPRE

LOCAL bValid:=IF(nTipoNF # CUSTO_REAL .AND. !lNFAutomatica,;
              {|| DI554Valid("NFE")       .AND. ;
                  DI554Valid("SERIE",.F.) .AND. ;
                  DI554Valid("DATA")      .AND. ;
                  DI554ValNF(.F.,cNumNFE,cSerieNFE)},{||.T.})  // GFP - 26/06/2015
LOCAL nCo1:=0.8, nCo2:=6.3, nCo3:=14.0, nCo4:=19.5

cCod     :=Work1->WK_OPERACA+Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM
cNumNFE  :=Work1->WK_NFE
cSerieNFE:=Work1->WK_SE_NFE
dDtNFE   :=Work1->WK_DT_NFE

DEFINE MSDIALOG oDlg TITLE cTit FROM 6,10 TO 26,70 Of oMainWnd

oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165)
oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

@1.4,nCo1 SAY STR0094  OF oPanel//"N§ da N.F."
@2.4,nCo1 SAY STR0095  OF oPanel//"S‚rie"
@3.4,nCo1 SAY STR0096  OF oPanel//"Data da N.F."
@4.4,nCo1 SAY STR0119  OF oPanel//"Vl. Mercadoria"
@5.4,nCo1 SAY STR0124  OF oPanel//"Valor FOB"
@6.4,nCo1 SAY STR0125  OF oPanel//"Valor Seguro"
@7.4,nCo1 SAY STR0126  OF oPanel//"Valor Frete"
@8.4,nCo1 SAY STR0127  OF oPanel//"Valor CIF"
@9.4,nCo1 SAY AVSX3("WN_PRUNI",5) OF oPanel//"Preco Unit."

@1.4,nCo2 MSGET cNumNFE   PICTURE "@!" SIZE 55,8 WHEN nTipoNF # CUSTO_REAL .AND. !lNFAutomatica  OF oPanel//AWR 12/8/00
@2.4,nCo2 MSGET cSerieNFE PICTURE "@!" SIZE 15,8 WHEN nTipoNF # CUSTO_REAL .AND. !lNFAutomatica  OF oPanel//AWR 12/8/99
@3.4,nCo2 MSGET dDtNFE    PICTURE "@D" SIZE 40,8 WHEN nTipoNF # CUSTO_REAL  OF oPanel//AWR 24/8/99
@4.4,nCo2 MSGET nVLMERC   VALID nVLMERC>=0 PICTURE PICT15_2    SIZE 55,8  OF oPanel
@5.4,nCo2 MSGET nFOBRS    VALID nFOBRS >=0 PICTURE PICT15_2    SIZE 55,8  OF oPanel
@6.4,nCo2 MSGET nSeguro   VALID nSeguro>=0 PICTURE PICT15_2    SIZE 55,8  OF oPanel
@7.4,nCo2 MSGET nFrete    VALID nFrete  >=0 PICTURE PICT15_2    SIZE 55,8  OF oPanel
@8.4,nCo2 MSGET nVLCIF    VALID nVLCIF  >=0 PICTURE PICT15_2    SIZE 55,8  OF oPanel
@9.4,nCo2 MSGET nPrecoUnit VALID nPrecoUnit  >=0 PICTURE PICT21_8    SIZE 55,8  OF oPanel

@1.4,nCo3 SAY STR0128  OF oPanel//"Valor I.I."
@2.4,nCo3 SAY STR0129  OF oPanel//"Valor Base IPI"
@3.4,nCo3 SAY STR0130  OF oPanel//"Valor I.P.I."
nLinha:=4.4
IF lMV_PIS_EIC
   @nLinha,nCo3 SAY AVSX3("W8_BASPIS",5)  OF oPanel
   nLinha+=1

   @nLinha,nCo3 SAY AVSX3("W8_VLRPIS",5)  OF oPanel
   nLinha+=1

   @nLinha,nCo3 SAY AVSX3("W8_BASCOF",5)  OF oPanel
   nLinha+=1

   @nLinha,nCo3 SAY AVSX3("W8_VLRCOF",5)  OF oPanel
   nLinha+=1
   oDlg:nHeight+=50
ENDIF
@nLinha,nCo3 SAY LEFT(STR0062,13)  OF oPanel//"Base I.C.M.S."
nLinha+=1
@nLinha,nCo3 SAY STR0131  OF oPanel//"Valor ICMS"
nLinha+=1
@nLinha,nCo3 SAY STR0284  OF oPanel//"Desp. Base (R$)"

//LRS - 05/04/2017 - Adicionado os campos de Credito presumido na tela de alteração de item
If lICMS_Dif
   nLinha+=1
   @nLinha,nCo3 SAY STR0376  OF oPanel //"Cred. Pres. ICMS"
   nLinha+=1

   @nLinha,nCo3 SAY STR0377  OF oPanel //"Cred. Pres. ICMS"
   nLinha+=1

   oDlg:nHeight+=50
EndIF

@1.4,nCo4 MSGET nVlII     VALID nVlII   >=0 PICTURE PICT15_2    SIZE 55,8  OF oPanel
@2.4,nCo4 MSGET nBaseIPI  VALID nBaseIPI>=0 PICTURE PICT15_2    SIZE 55,8  OF oPanel
@3.4,nCo4 MSGET nVlIPI    VALID nVlIPI  >=0 PICTURE PICT15_2    SIZE 55,8  OF oPanel
nLinha:=4.4
IF lMV_PIS_EIC
   @nLinha,nCo4 MSGET nBASPIS VALID nBASPIS >=0 PICTURE PICT15_2 SIZE 55,8  OF oPanel
   nLinha+=1

   @nLinha,nCo4 MSGET nVLRPIS VALID nVLRPIS >=0 PICTURE PICT15_2 SIZE 55,8  OF oPanel
   nLinha+=1

   @nLinha,nCo4 MSGET nBASCOF VALID nBASCOF >=0 PICTURE PICT15_2 SIZE 55,8  OF oPanel
   nLinha+=1

   @nLinha,nCo4 MSGET nVLRCOF VALID nVLRCOF >=0 PICTURE PICT15_2 SIZE 55,8  OF oPanel
   nLinha+=1
ENDIF
@nLinha,nCo4 MSGET nBasICMS  VALID nBasICMS>=0 PICTURE PICT15_2    SIZE 55,8  OF oPanel
nLinha+=1
@nLinha,nCo4 MSGET nVlICMS   VALID nVlICMS >=0 PICTURE PICT15_2    SIZE 55,8  OF oPanel
nLinha+=1 //SVG - 06/09/2011 -
@nLinha,nCo4 MSGET n_DespBICMS   VALID nVlICMS >=0 PICTURE PICT15_2    SIZE 55,8  OF oPanel

//LRS - 05/04/2017 - Adicionado os campos de Credito presumido na tela de alteração de item
IF lICMS_Dif
   nLinha+=1
   @nLinha,nCo4 MSGET nVlCMDIF  VALID nVlCMDIF>=0 PICTURE PICT15_2    SIZE 55,8 OF oPanel
   nLinha+=1

   @nLinha,nCo4 MSGET nVlICMCP  VALID nVlICMCP>=0 PICTURE PICT15_2    SIZE 55,8 OF oPanel
   nLinha+=1
EndIF

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,;
         {||If(EVAL(bValid),(nOpcA:=1,oDlg:End()),)},;
         {||nOpcA:=0, oDlg:End()}) CENTERED

If nOpca = 0
   Return .F.
Endif

Work1->(DBSETORDER(1))
Work1->(DBGOTO(nRecno))
Work2->(DBSEEK(Work1->WKADICAO+Work1->WK_CFO+Work1->WK_OPERACA+Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM))

nCif   :=nVLCIF
nSeg   :=nSeguro

Work1->WK_NFE    := cNumNFE
Work1->WK_SE_NFE := cSerieNFE
Work1->WK_DT_NFE := dDtNFE
Work1->WKCIF     := nCif
Work1->WKFOB_R   := nFOBRS
Work1->WKFRETE   := nFrete
Work1->WKVALMERC := nVLMERC
Work1->WKSEGURO  := nSeg
Work1->WKIIVAL   := nVlII
Work1->WKIPIBASE := nBaseIPI
Work1->WKIPIVAL  := nVlIPI
Work1->WKBASEICMS:= nBasICMS
Work1->WKVL_ICM  := nVlICMS
Work1->WKDESPICM := n_DespBICMS// SVG - 06/09/2011 -
Work1->WKBASPIS  := nBASPIS // JBS - 02/06/2004
Work1->WKVLRPIS  := nVLRPIS // JBS - 02/06/2004
Work1->WKBASCOF  := nBASCOF // JBS - 02/06/2004
Work1->WKVLRCOF  := nVLRCOF // JBS - 02/06/2004
Work1->WKPRUNI   := nPrecoUnit

IF nTipoNF == NFE_COMPLEMEN
   Work1->WKOUT_DESP:= nVLMERC
ENDIF

//LRS - 05/04/2017 - Adicionado os campos de Credito presumido na tela de alteração de item
IF lICMS_Dif
   Work1->WKVL_ICM_D := nVlCMDIF
   Work1->WKVLCREPRE := nVlICMCP
EndIF

Work1->(DBGOTO(nRecno))
Work3->(DBSEEK(Work1->(RECNO())))

WHILE !Work3->(EOF()) .AND. Work1->(RECNO()) == Work3->WKRECNO
   Work3->WK_NF_COMP:=cNumNFE
   Work3->WK_SE_NFC :=cSerieNFE
   Work3->WK_DT_NFC :=dDtNFE
   Work3->(DBSKIP())
ENDDO
// Subtrai os valores anteriores da tela principal
n_CIF    := DITRANS((n_CIF    - nCVLCIF),2)
nFOB_R   := DITRANS((nFOB_R   - nCFOBRS),2)
n_FRETE  := DITRANS((n_FRETE  - nCFrete),2)
n_II     := DITRANS((n_II     - nCVlII),2)
n_SEGURO := DITRANS((n_SEGURO - nCSeguro ),2)
n_IPI    := DITRANS((n_IPI    - nCVlIPI),2)
n_ICMS   := DITRANS((n_ICMS   - nCVlICMS),2)

// Soma os novos valores na tela principal
n_CIF    := DITRANS((n_CIF    + nCif),2)
nFOB_R   := DITRANS((nFOB_R   + nFOBRS),2)
//MDI_FOB  := nFOB_R   / IF(EMPTY(n_Tx_Fob),1,n_Tx_Fob)
n_FRETE  := DITRANS((n_FRETE  + nFrete),2)
n_Vl_Fre := DITRANS((n_FRETE  / IF(EMPTY(n_Tx_Fre),1,n_Tx_Fre)),2)
n_II     := DITRANS((n_II     + nVlII),2)
n_SEGURO := DITRANS((n_SEGURO + nSeg),2)
n_Vl_USS := DITRANS((n_SEGURO / IF(EMPTY(SW6->W6_TX_SEG),1,SW6->W6_TX_SEG)),2)
n_IPI    := DITRANS((n_IPI    + nVlIPI),2)
n_ICMS   := DITRANS((n_ICMS   + nVlICMS),2)
n_ValM   := DITRANS(n_CIF,2)  + DITRANS(n_II,2)
n_TotNFE := DITRANS(n_ValM,2) + DITRANS(n_IPI,2)
n_VlTota := DITRANS((n_TotNFE + n_ICMS+MDI_OUTR),2)
//cPictDI  := IF(RIGHT(STR(MDI_FOB,15,4),2)="00",;
//              "@E 999,999,999,999.99","@E 999,999,999,999.9999")


RETURN .T.

*----------------------------------------------*
Function DI554GrWorks(bMsg,bDDIFor,bDDIWhi)
*----------------------------------------------*
LOCAL nCont:=0,nValor:=0, lSair:=.F.
LOCAL  nFbMid_M:=0 , M_FOB_MIDRS:=0
Local cFilSA2:=xFilial("SA2")
LOCAL cFilSB1:=xFILIAL("SB1")
LOCAL cFilSW2:=xFILIAL("SW2")
LOCAL cFilSW7:=xFILIAL("SW7")
LOCAL cFilSW8:=xFILIAL("SW8")
LOCAL cFilSW9:=xFILIAL("SW9")
LOCAL cFilSWZ:=xFILIAL("SWZ")
LOCAL cFilSYD:=xFILIAL("SYD")
LOCAL cFilSWN:=xFILIAL("SWN")
LOCAL cFilSF1:=xFILIAL("SF1")
aDespesa:= {};nFob:=nFobTot:=nPesoL:=nContProc:=nSomaNoCIF:=nSomaBaseICMS:=nPesoB:=nSomaDespRatAdicao:= 0 //FSM 02/08/2011 - Peso Bruto Unitario
nPSomaNoCIF:= 0
SD1->(DBSETORDER(8))//9
SYB->(DBSETORDER(1))
SW7->(DBSEEK(cFilSW7+SW6->W6_HAWB))
SA2->(DBSEEK(cFilSA2+SW7->W7_FORN+EICRetLoja("SW7", "W7_FORLOJ")))//CR
lMidia:=.f.
ProcRegua(50)

DI554IncProc(STR0132) //"Verificando Processo, Aguarde..."

DI554GrvDespesa()

DI554IncProc(STR0132) //"Verificando Processo, Aguarde..."
IF nTipoNF # NFE_COMPLEMEN .OR. lRateioCIF
// MDI_FOB_R := SW6->W6_FOB_TOT+DITrans(MDespesas,2)
// MDI_FRETE := ValorFrete(SW6->W6_HAWB,,,1)
// MDI_FRETE += SW6->W6_VLFR_CO
// MDI_SEGURO:= SW6->W6_VLSEGMN
// IF lCurrier
//    MDI_FRETE := MDI_SEGURO := 0
// ENDIF
// MDI_CIF   := DITrans( MDI_FOB_R + MDI_FRETE + MDI_SEGURO + nSomaNoCIF     ,2)

   SWD->(DbSeek(xFilial("SWD")+SW6->W6_HAWB+DESPESA_II))
   tDI_II  :=MDI_II  := DITrans( SWD->WD_VALOR_R,2 )

   SWD->(DbSeek(xFilial("SWD")+SW6->W6_HAWB+DESPESA_IPI))
   tDI_IPI :=MDI_IPI := DITrans( SWD->WD_VALOR_R,2 )
/*   IF lCurrier
      tDI_IPI := MDI_IPI := 0
   ENDIF
*/
   SWD->(DbSeek(xFilial("SWD")+SW6->W6_HAWB+DESPESA_ICMS))
   tDI_ICMS:=MDI_ICMS:= DITrans( SWD->WD_VALOR_R,2 )
ENDIF

aEnv_NFS:={}//AWF - 13/06/2014 - LOGIX

IF nTipoNF # CUSTO_REAL

   SF1->(DBSETORDER(5))
   SWN->(DBSETORDER(2))
   ProcRegua(50)

   SF1->(DBSEEK(cFilSF1+SW6->W6_HAWB+STR(nTipoNF,1,0)))

   DO WHILE SF1->(!EOF())                 .AND.;
         SF1->F1_FILIAL  == cFilSF1       .AND.;
         SF1->F1_HAWB    == SW6->W6_HAWB  .AND.;
         SF1->F1_TIPO_NF == STR(nTipoNF,1,0)

      DI554IncProc(STR0133) //"Lendo Nota Fiscal, Aguarde..."

      IF !EMPTY(cNota) .AND. cNota # SF1->F1_CTR_NFC // Nota + Serie
         SF1->(DBSKIP())
         LOOP
      ENDIF

      IF AvFlags("EIC_EAI")//AWF -  REQ 6 16/06/2014
         AADD( aEnv_NFS , SF1->(RECNO()) )//AWF - 13/06/2014 - LOGIX
         IF SF1->F1_OK = "0"//AWF - 13/06/2014 - LOGIX
            lTemPendentes:=.T.
         ENDIF
      ENDIF

      SWN->(DBSEEK(cFilSWN+SF1->F1_DOC+SF1->F1_SERIE))//+SF1->F1_FORNECE+SF1->F1_LOJA))

      DO WHILE SWN->(!EOF())              .AND.;
            SWN->WN_FILIAL == cFilSWN     .AND.;
            SWN->WN_DOC    == SF1->F1_DOC .AND.;
            SWN->WN_SERIE  == SF1->F1_SERIE  .AND.;
            SWN->WN_FORNECE== SF1->F1_FORNECE.AND.;
            SWN->WN_LOJA   == SF1->F1_LOJA

         IF SWN->WN_TIPO_NF # STR(nTipoNF,1,0).OR.;
            SWN->WN_HAWB    # SW6->W6_HAWB
            SWN->(DBSKIP())
            LOOP
         ENDIF

         DI554IncProc(STR0133) //"Lendo Nota Fiscal, Aguarde..."

         Work1->(DBAPPEND())
         Work1->WK_NFE     := SWN->WN_DOC
         Work1->WK_NOTA    := SWN->WN_DOC
         Work1->WK_SE_NFE  := SWN->WN_SERIE
         Work1->WKTEC      := SWN->WN_TEC
         Work1->WKEX_NCM   := SWN->WN_EX_NCM
         Work1->WKEX_NBM   := SWN->WN_EX_NBM
         Work1->WKQTDE     := SWN->WN_QUANT
         Work1->WKPRECO    := SWN->WN_PRECO
         Work1->WKPO_NUM   := SWN->WN_PO_EIC
         //AWR 14/04/2000
         IF !EMPTY(SWN->WN_QTSEGUM) .AND.;
            EasyGParam("MV_UNIDCOM",,2) == 2 .AND. lMV_EASY_SIM
            Work1->WKQTDE := SWN->WN_QTSEGUM
         ENDIF
         Work1->WKCOD_I    := SWN->WN_PRODUTO
         Work1->WKVALMERC  := SWN->WN_VALOR
         Work1->WK_CFO     := SWN->WN_CFO
         Work1->WK_OPERACA := SWN->WN_OPERACA
         Work1->WKICMS_A   := SWN->WN_ICMS_A
         Work1->WKDESCR    := SWN->WN_DESCR
         Work1->WKUNI      := SWN->WN_UNI
         Work1->WKIPITX    := SWN->WN_IPITX
         Work1->WKVLDEVII  := SWN->WN_VLDEVII
         Work1->WKVLDEIPI  := SWN->WN_VLDEIPI
         Work1->WKIPIVAL   := SWN->WN_IPIVAL
         Work1->WKIITX     := SWN->WN_IITX
         Work1->WKIIVAL    := SWN->WN_IIVAL
         Work1->WKPRUNI    := SWN->WN_PRUNI
         Work1->WKVL_ICM   := SWN->WN_VL_ICM
         If AvFlags("ICMSFECP_DI_ELETRONICA")
            Work1->WKVLFECP := SWN->WN_VLFECP
         EndIf
         If AVFLAGS("FECP_DIFERIMENTO")
            Work1->WKFECPVLD := SWN->WN_FECPVLD
            Work1->WKFECPREC := SWN->WN_FECPREC
         EndIf
         Work1->WKPESOL    := SWN->WN_PESOL
         Work1->WKSEGURO   := SWN->WN_SEGURO
         Work1->WKBASEII   := SWN->WN_CIF
         Work1->WKCIF      := SWN->WN_CIF
         Work1->WKOUT_DESP := SWN->WN_DESPESAS
         Work1->WKFRETE    := SWN->WN_FRETE
         Work1->WK_CFO     := SWN->WN_CFO
         Work1->WK_OPERACA := SWN->WN_OPERACA
         Work1->WKOUT_D_US := SWN->WN_OUTR_US
         Work1->WKIPIBASE  := SWN->WN_IPIBASE
         Work1->WKBASEICMS := SWN->WN_BASEICM // AWR 07/12/2000
         //NCF-27/05/2010
         If lICMS_Dif  // PLB 14/05/07 - Tratamento Diferimento de ICMS
            DI154Diferido(.T.)
         EndIf
         Work1->WKFOB_R    := SWN->WN_FOB_R
         Work1->WKFORN     := SWN->WN_FORNECE
         Work1->WK_CC      := SWN->WN_CC     // FCD
         Work1->WKSI_NUM   := SWN->WN_SI_NUM //FCD
         Work1->WKLOJA     := SWN->WN_LOJA
         Work1->WKPOSICAO  := SWN->WN_ITEM
         Work1->WKADICAO   := SWN->WN_ADICAO
         Work1->WKPGI_NUM  := SWN->WN_PGI_NUM
         Work1->WKINVOICE  := SWN->WN_INVOICE
         Work1->WKOUTDESP  := SWN->WN_OUT_DES
         Work1->WKINLAND   := SWN->WN_INLAND
         Work1->WKPACKING  := SWN->WN_PACKING
         Work1->WKDESCONT  := SWN->WN_DESCONT

         If SWN->(FieldPos("WN_AC")) # 0    // GFP - 20/09/2013 - Novo Layout NFE - (Nota técnica da NFe - 2013-005)
            Work1->WKAC := SWN->WN_AC
         EndIf

         If SWN->(FieldPos("WN_NVE")) # 0    // GFP - 20/09/2013 - Novo Layout NFE - (Nota técnica da NFe - 2013-005)
            Work1->WKNVE := SWN->WN_NVE
         EndIf

         If SWN->(FieldPos("WN_AFRMM")) # 0    // GFP - 23/09/2013 - Novo Layout NFE - (Nota técnica da NFe - 2013-005)
            Work1->WKAFRMM := SWN->WN_AFRMM
         EndIf

         IF lMV_PIS_EIC .AND. nTipoNF # 2
            Work1->WKVLUPIS  := SWN->WN_VLUPIS
            Work1->WKBASPIS  := SWN->WN_BASPIS
            Work1->WKPERPIS  := SWN->WN_PERPIS
            Work1->WKVLRPIS  := SWN->WN_VLRPIS
            Work1->WKVLUCOF  := SWN->WN_VLUCOF
            Work1->WKBASCOF  := SWN->WN_BASCOF
            Work1->WKPERCOF  := SWN->WN_PERCOF
            Work1->WKVLRCOF  := SWN->WN_VLRCOF
            If lCposCofMj                                                            //NCF - 20/07/2012 - Majoração COFINS
               Work1->WKALCOFM  := SWN->WN_ALCOFM
               Work1->WKVLCOFM  := SWN->WN_VLCOFM
            EndIf
            If lCposPisMj                                                            //GFP - 11/06/2013 - Majoração PIS
               Work1->WKALPISM  := SWN->WN_ALPISM
               Work1->WKVLPISM  := SWN->WN_VLPISM
            EndIf
         ENDIF
         SA2->(DBSEEK(xFilial("SA2")+Work1->WKFORN+Work1->WKLOJA))
         IF(ASCAN(aLista,{|F|F=Work1->WKFORN})=0,AADD(aLista,Work1->WKFORN+"-"+SA2->A2_NREDUZ),)

         IF lLote
            Work1->WK_LOTE  := SWN->WN_LOTECTL
            Work1->WKDTVALID:= SWN->WN_DTVALID
            IF lCpoDtFbLt
               Work1->WKDTFBLT := SWN->WN_DFABRI
            ENDIF
         ENDIF
         IF lExisteSEQ_ADI// AWR - 06/11/08 - NFE
            Work1->WKSEQ_ADI := SWN->WN_SEQ_ADI
         ENDIF
         IF lMV_GRCPNFE//Campos novos NFE - AWR 06/11/2008
            Work1->WKPREDICM := SWN->WN_PREDICM
            Work1->WKDESCONI := SWN->WN_DESCONI
            Work1->WKVLRIOF  := SWN->WN_VLRIOF
            Work1->WKDESPADU := SWN->WN_DESPADU
            Work1->WKALUIPI  := SWN->WN_ALUIPI
            Work1->WKQTUIPI  := SWN->WN_QTUIPI
            Work1->WKQTUPIS  := SWN->WN_QTUPIS
            Work1->WKQTUCOF  := SWN->WN_QTUCOF
         ENDIF
         IF SWN->(FIELDPOS("WN_DESPICM")) # 0	//ASR 07/11/2005 - GRAVAÇÃO DA SWN
            Work1->WKDESPICM  := SWN->WN_DESPICM
            nVlrCustoSWN := SWN->WN_DESPICM
         ENDIF

         IF AvFlags("EIC_EAI")//AWF - 17/06/14 - Logix
            //Work1->WKSTATUS:=SF1->F1_STATUS //AWF - Já é gravado acima no padrao
            Work1->WK_OK     :=SF1->F1_OK
			Work1->WKMENNOTA :=SF1->F1_MENNOTA

			//numeração provisória - será exibida após o recebimento da nota fiscal oficial do ERP
            Work1->WKNOTAPR := SF1->F1_NFORIG
            Work1->WKSERIEPR:= SF1->F1_SERORIG
         ENDIF
         IF lTemCposOri//AWF - 31/07/2014
            Work1->WKNOTAOR := SWN->WN_DOCORI
            Work1->WKSERIEOR:= SWN->WN_SERORI
         ENDIF

         nNBM_CIF +=Work1->WKCIF
         nNBM_II  +=Work1->WKIIVAL
         nNBM_IPI +=Work1->WKIPIVAL
         nNBM_ICMS+=Work1->WKVL_ICM
         nNBM_PIS +=Work1->WKVLRPIS
         nNBM_COF +=Work1->WKVLRCOF
         MDI_OUTR +=Work1->WKOUT_DESP
         MDI_FOB_R+=Work1->WKFOB_R
         MDI_CIF  +=Work1->WKBASEII//Work1->WKCIF
//         IF !lCurrier
            MDI_FRETE +=Work1->WKFRETE
            MDI_SEGURO+=Work1->WKSEGURO
//         ENDIF

         IF (EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,'LER_SF1_SWN'),)

         SWN->(DBSKIP())

      ENDDO

      SF1->(DBSKIP())

   ENDDO

ELSE

   EI2->(DBSETORDER(1))



   ProcRegua(50)

   EI2->(DBSEEK(xFilial()+SW6->W6_HAWB))

   DO WHILE ! EI2->(EOF())                     .AND.;
              EI2->EI2_FILIAL == xFilial("EI2").AND.;
              EI2->EI2_HAWB   == SW6->W6_HAWB

      DI554IncProc(STR0134) //"Lendo Custo, Aguarde..."

      IF EI2->EI2_TIPO_NF # STR( nTipoNF,1, 0 )
         EI2->(DBSKIP())
         LOOP
      ENDIF

      Work1->(DBAPPEND())
      Work1->WK_NFE    := EI2->EI2_DOC
      Work1->WK_SE_NFE := EI2->EI2_SERIE
      Work1->WKTEC     := EI2->EI2_TEC
      Work1->WKEX_NCM  := EI2->EI2_EX_NCM
      Work1->WKEX_NBM  := EI2->EI2_EX_NBM
      Work1->WKPO_NUM  := EI2->EI2_PO_NUM
      Work1->WKQTDE    := EI2->EI2_QUANT
      Work1->WKCOD_I   := EI2->EI2_PRODUTO
      Work1->WKVALMERC := EI2->EI2_VALOR
      Work1->WKVL_ICM  := EI2->EI2_VALICM
      Work1->WK_CFO    := EI2->EI2_CFO
      Work1->WK_OPERACA:= EI2->EI2_OPERACA
      Work1->WKICMS_A  := EI2->EI2_ICMS_A
      Work1->WKPRECO   := EI2->EI2_PRECO
      Work1->WKDESCR   := EI2->EI2_DESCR
      Work1->WKUNI     := EI2->EI2_UNI
      Work1->WKVLDEVII := EI2->EI2_VLDEII
      Work1->WKVLDEIPI := EI2->EI2_VLDIPI
      Work1->WKIPITX   := EI2->EI2_IPITX
      Work1->WKIPIVAL  := EI2->EI2_IPIVAL
      Work1->WKIITX    := EI2->EI2_IITX
      Work1->WKIIVAL   := EI2->EI2_IIVAL
      Work1->WKPRUNI   := EI2->EI2_PRUNI
      Work1->WKVL_ICM  := EI2->EI2_VL_ICM
      Work1->WKPESOL   := EI2->EI2_PESOL
      Work1->WKSEGURO  := EI2->EI2_SEGURO
      Work1->WKBASEII  := EI2->EI2_CIF
      Work1->WKCIF     := EI2->EI2_CIF
      Work1->WKOUT_DESP:= EI2->EI2_DESPES
      Work1->WKFRETE   := EI2->EI2_FRETE
      Work1->WK_CFO    := EI2->EI2_CFO
      Work1->WK_OPERACA:= EI2->EI2_OPERAC
      Work1->WKOUT_D_US:= EI2->EI2_OUTR_U
      Work1->WKIPIBASE := EI2->EI2_IPIBAS
      Work1->WKFORN    := EI2->EI2_FORNEC
      Work1->WKPGI_NUM := EI2->EI2_PGI_NU
      Work1->WKINVOICE := EI2->EI2_INVOIC
      Work1->WKOUTDESP := EI2->EI2_OUT_DE
      Work1->WKINLAND  := EI2->EI2_INLAND
      Work1->WKPACKING := EI2->EI2_PACKIN
      Work1->WKDESCONT := EI2->EI2_DESCON
      Work1->WKFOB_R   := EI2->EI2_FOB_R
      IF lMV_PIS_EIC
         Work1->WKVLUPIS  := EI2->EI2_VLUPIS
         Work1->WKBASPIS  := EI2->EI2_BASPIS
         Work1->WKPERPIS  := EI2->EI2_PERPIS
         Work1->WKVLRPIS  := EI2->EI2_VLRPIS
         Work1->WKVLUCOF  := EI2->EI2_VLUCOF
         Work1->WKBASCOF  := EI2->EI2_BASCOF
         Work1->WKPERCOF  := EI2->EI2_PERCOF
         Work1->WKVLRCOF  := EI2->EI2_VLRCOF
         If lCposCofMj                                                            //NCF - 20/07/2012 - Majoração COFINS
            Work1->WKVLCOFM  := EI2->EI2_VLCOFM
         EndIf
         If lCposPisMj                                                            //GFP - 11/06/2013 - Majoração PIS
            Work1->WKVLPISM  := EI2->EI2_VLPISM
         EndIf

      ENDIF
      IF lLote
         Work1->WK_LOTE  :=EI2->EI2_LOTECT
         Work1->WKDTVALID:=EI2->EI2_DTVALI
         IF lCpoDtFbLt
            Work1->WKDTFBLT := EI2->EI2_DFABRI
         ENDIF
      ENDIF

      nNBM_CIF +=Work1->WKCIF
      nNBM_II  +=Work1->WKIIVAL
      nNBM_IPI +=Work1->WKIPIVAL
      nNBM_ICMS+=Work1->WKVL_ICM
      nNBM_PIS +=Work1->WKVLRPIS
      nNBM_COF +=Work1->WKVLRCOF
      MDI_OUTR +=Work1->WKOUT_DESP
      MDI_FOB_R+=Work1->WKFOB_R
      MDI_CIF  +=Work1->WKCIF
//      IF !lCurrier
         MDI_FRETE +=Work1->WKFRETE
         MDI_SEGURO+=Work1->WKSEGURO
//      ENDIF

      IF (EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,'LEREI2'),)

      EI2->(DbSkip())

   ENDDO

ENDIF

DI554IncProc() // 100%

DBSELECTAREA("Work1")

Work1->(DBGOTOP())

RETURN .T.
*---------------------------------------*
Function DI554ForDesp()
*---------------------------------------*
LOCAL nTaxa
LOCAL lBaseICMS //LGS-03/06/2016

IF SYB->(DbSeek(xFilial("SYB")+SWD->WD_DESPESA)).AND.;
   !(SYB->YB_BASECUS $ cNao)
   IF SWD->WD_DESPESA $ "701/702/703"  // RRV - 07/03/2013
      If lDifCamb  // RRV - 25/02/2013
         nDifCamb+=SWD->WD_VALOR_R
         DI554TabDes(aDespesa)
      EndIf
      RETURN .T.
   ENDIF

   /* Complementar apenas desp base de icms, Complemento Valor, apenas desp que nao for base de icms */
   lBaseICMS:=SYB->YB_BASEICM
   IF nTipoNF == NFE_COMPLEMEN  .And. DI154CompValor(SW6->W6_HAWB) .And. !(lBaseICMS $ cSim) //LGS-06/04/2016
      RETURN .F.
   ENDIF

// EOS - 13/05 - permitir gravar no SWW na primeira nota, as despesas que sao base de impostos e icms
// AWR - OBS: nTipoNF # 2 por que pode ocorrer de entrar uma despesa base despois de gerado a primeira ou unica

   IF SYB->YB_BASEIMP $ cSim .OR. IF(lTemYB_ICM_UF,SYB->(FIELDGET(FIELDPOS(cCpoBasICMS))) $ cSim,SYB->YB_BASEICM $ cSim) //SYB->YB_BASEICM $ cSim
      IF nTipoNF # 2
         //NCF - 12/07/2011 - Não considerar Adiantamento de Taxa Siscomex no custo (DI Eletronica gera a despesa automaticamente)
         //IF !(EasyGParam("MV_CODTXSI",,"") $ SWD->WD_DESPESA .And. SWD->WD_BASEADI $ cSim)
            Di554TabDes(aDespesa)// Grava o SWW
         //ENDIF
          RETURN .F.
       ELSEIF !lICMS_NFC  // Bete - se nota complementar, verifica se calcula ICMS, se não, ignora as despesas base
          RETURN .F.
       ENDIF
    ENDIF

// AWR - 18/05 - ignora as despesas que nao sao base de imposto e ICMS na primeira nota quando nao é Ler Nota (Custo)
   IF nTipoNF == 1 .OR. nTipoNF == 5
      RETURN .F.
   ENDIF

   nTaxa:=BuscaTaxa(cMoeDolar,SWD->WD_DES_ADI,.T.,.F.,.T.)
   MDI_OUTR +=SWD->WD_VALOR_R
   MDI_OU_US+=SWD->WD_VALOR_R / IF(nTaxa#0,nTaxa,1)
   DI554TabDes(aDespesa)
ELSE
   RETURN .F.
ENDIF

RETURN .T.
*---------------------------------------*
Function DI554Grava(bMsg,bDDIFor,bDDIWhi)
*---------------------------------------*
LOCAL bDespDiFor:={||AT(LEFT(SWD->WD_DESPESA,1),"129") = 0}
LOCAL bDespDiWhi:={||cFilSWD==SWD->WD_FILIAL .AND. SWD->WD_HAWB==SW6->W6_HAWB}
LOCAL nNBM_FOB:=0, nRatIPD:=0, nFob_RS:=0
LOCAL nFbMid_M:=0, nFbMid_RS:=0, cFilSWD:=xFILIAL("SWD")
LOCAL nCifMaior := 0, nRecno:=1,cTam:=AVSX3("B1_VM_P",3),lTemRED_CTE , Wind , E
LOCAL cFilEIJ:=xFILIAL("EIJ")
LOCAL cFilSB1:=xFILIAL("SB1")
LOCAL cFilSW2:=xFILIAL("SW2")
LOCAL cFilSW7:=xFILIAL("SW7")
LOCAL cFilSW8:=xFILIAL("SW8")
LOCAL cFilSW9:=xFILIAL("SW9")
LOCAL cFilSWZ:=xFILIAL("SWZ")
LOCAL cFilSWX:=xFILIAL("SWX")
LOCAL cFilSYD:=xFILIAL("SYD")
Local aSegUnid:= {}
Local cIndice := ""
Local bSeekWk1 , bSeekWk2 , bWhileWk
Private lMidia:=.f.
PRIVATE bDDIAcu  :={|| DI554ForDesp()}
PRIVATE lPesoNew := 0 // PARA RDMAKE DE PESO NO W5 - RHP

nPSemCusto := 0
nSemCusto := 0
nContProc:=M_FOB_MIDRS:= nFobItemMidiaRS:= nDifCamb:= nSomaNoCIF:= nSomaBaseICMS:=nSomaDespRatAdicao:=nPSomaBaseICMS := ntxSisc:= 0
nPSomaNoCIF:= 0
aDespesa := {}; nFobMoeda:=nFobTot:=nPesoL:=nPesoB:=0 //FSM - 02/09/2011 - Peso Bruto Unitario
aDesAcerto:={}
DI554IncProc()

//Private nPSomaBaseICMS := ntxSisc:= 0 //DFS - Declaração da variável para que o campo Desp.Base ICMS seja mostrado na tela, mesmo quando o parâmetro MV_TEM_DI estiver ligado

SWX->(DBSETORDER(1) )
SWZ->(DBSETORDER(2) )
SYB->(DBSETORDER(1) )
SW7->(DBSETORDER(4) )
SW7->(DbSeek(xFILIAL("SW7")+SW6->W6_HAWB))
SW2->(DbSeek(xFilial()+SW7->W7_PO_NUM))
SA2->(DBSEEK(xFilial("SA2")+SW7->W7_FORN+EICRetLoja("SW7", "W7_FORLOJ")))

If nTipoNF == NFE_COMPLEMEN .AND. SW6->W6_IMPCO == "1"  // GFP - 21/01/2015 - Geração de NF Complementar para processos Conta e Ordem deve ser apresentado Fornecedor do Importador.
   IF !Empty(SYT->YT_FORN) .And. !Empty(SYT->YT_LOJA)   //LRS - 8/10/2015 - Verifica se o Fornecedor do processo Complementar do conta e ordem está preenchido, se não pega do P.O.
	  SA2->(DbSeek(xFilial("SA2")+SYT->YT_FORN+EICRetLoja("SYT", "YT_LOJA")))
   Else
	  SA2->(DbSeek(xFilial("SA2")+SW2->W2_FORN+EICRetLoja("SW2", "W2_FORLOJ")))
   EndIF
EndIf

DI554IncProc()
nFobMoeda:= 0
nTotFob_Proc:= 0

IF lExiste_Midia
   SW9->(DBSETORDER(1))
   SW8->(DBSETORDER(1))
   SW8->(DBSEEK(cFilSW8+SW6->W6_HAWB))
   DO WHILE  ! SW8->(EOF()) .AND. SW8->W8_FILIAL == cFilSW8 .AND. SW8->W8_HAWB == SW6->W6_HAWB
      SW2->(DbSeek(cFilSW2+SW8->W8_PO_NUM))
      SB1->(DbSeek(cFilSB1+SW8->W8_COD_I))
      //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
      SW9->(DbSeek(cFilSW9+SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8", "W8_FORLOJ")+SW8->W8_HAWB))
      IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"ACERTA_SEEK3"),)
      IF SB1->B1_MIDIA $ cSim
         // M_FOBMIDRS = FOB das mídias (vlr da midia + despesa de frete)  // Bete - 24/02/05
         M_FOB_MIDRS    += DITrans(SB1->B1_QTMIDIA * SW8->W8_QTDE * SW2->W2_VLMIDIA * SW9->W9_TX_FOB,2)
         IF !SW9->W9_FREINC $ cSim
            M_FOB_MIDRS+=DITrans(SW8->W8_FRETEIN*SW9->W9_TX_FOB,2)
         ENDIF
         // nFobItemMidiaRS = FOB TOTAL (Vl. Software + despesas) dos itens que tem midia  // Bete - 24/02/05
         nFobItemMidiaRS+= DITrans(SW8->W8_PRECO*SW8->W8_QTDE*SW9->W9_TX_FOB,2)
         nFobItemMidiaRS+= DITrans(DI500RetVal("ITEM_INV,SEM_FOB", "TAB", .T., .T.),2) // EOB - 14/07/08 - chamada da função DI500RetVal
         nTotFob_Proc   += DITrans(SB1->B1_QTMIDIA * SW8->W8_QTDE * SW2->W2_VLMIDIA * SW9->W9_TX_FOB,2) // LDR
      ELSE
         nTotFob_Proc   += DITrans(SW8->W8_PRECO*SW8->W8_QTDE*SW9->W9_TX_FOB,2)
         MDespesas      += DITrans(DI500RetVal("ITEM_INV,SEM_FOB", "TAB", .T., .T.),2) // EOB - 14/07/08 - chamada da função DI500RetVal
      ENDIF
      SW8->(DBSKIP())
   ENDDO
ELSE
   nTotFob_Proc := SW6->W6_FOB_TOT
   SW9->(DBSETORDER(3))
   SW9->(DbSeek(cFilSW9+SW6->W6_HAWB))
   DO WHILE ! SW9->(EOF()) .AND. SW9->W9_FILIAL == cFilSW9 .AND.;
                                 SW9->W9_HAWB == SW6->W6_HAWB
	  MDespesas+=DI500RetVal("TOT_INV,SEM_FOB", "TAB", .T.,.T.)  // EOB - 14/07/08 - chamada da função DI500RetVal
      SW9->(DBSKIP())
   ENDDO
ENDIF

IF (EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"GRVWORK_1"),)

DI554GrvDespesa()

DI554IncProc()

IF (nTipoNF # NFE_COMPLEMEN .AND. nTipoNF # NFE_FILHA) .OR. lRateioCIF //AWR Rateio
/*   IF lCurrier
      MDI_FRETE:=MDI_SEGURO:=0
   ENDIF
*/
   SWD->(DbSeek(xFilial("SWD")+SW6->W6_HAWB+DESPESA_II))
   tDI_II  :=MDI_II  :=SWD->WD_VALOR_R
   DI554VerDespesas("I.I.",SWD->(EOF()))

   SWD->(DbSeek(xFilial("SWD")+SW6->W6_HAWB+DESPESA_IPI))
   tDI_IPI :=MDI_IPI :=SWD->WD_VALOR_R
/*   IF lCurrier
      tDI_IPI := MDI_IPI := 0
   ENDIF */
   DI554VerDespesas("I.P.I.",SWD->(EOF()))

   SWD->(DbSeek(xFilial("SWD")+SW6->W6_HAWB+DESPESA_ICMS))
   tDI_ICMS:=MDI_ICMS:=SWD->WD_VALOR_R
   DI554VerDespesas("I.C.M.S.",SWD->(EOF()))

   IF lMV_PIS_EIC
      SWD->(DbSeek(xFilial("SWD")+SW6->W6_HAWB+DESPESA_PIS))
      MDI_PIS:=SWD->WD_VALOR_R
      DI554VerDespesas("PIS",SWD->(EOF()))

      SWD->(DbSeek(xFilial("SWD")+SW6->W6_HAWB+DESPESA_COF))
      MDI_COF:=SWD->WD_VALOR_R
      DI554VerDespesas("COFINS",SWD->(EOF()))
   ENDIF

ENDIF

DI554IncProc()
IF nTipoNF # NFE_COMPLEMEN .AND. nTipoNF # NFE_FILHA
   SWD->(DbSeek(xFilial("SWD")+SW6->W6_HAWB)) //AWR 13/7/98
   SWD->(DbEval(bDDIAcu,bDespDiFor,bDespDiWhi))//Le todas as despesas
ENDIF

DI554IncProc()
IF nTipoNF = NFE_PRIMEIRA .OR. (lMV_NF_MAE .And. nTipoNF == NFE_MAE)
   MDI_OUTR:=MDI_OU_US:=nDifCamb:=0
ENDIF

DI554IncProc()

IF nTipoNF = CUSTO_REAL
   DI554Tela(tDI_II,tDI_IPI,tDI_ICMS)
ENDIF

IF nTipoNF = NFE_COMPLEMEN//nTipoNF # NFE_PRIMEIRA .AND. nTipoNF # CUSTO_REAL
   MDI_OUTR:=MDI_OU_US:=nDifCamb:=0
   aDespesa:={}
   SWD->(DbSeek(xFilial("SWD")+SW6->W6_HAWB))
   SWD->(DbEval(bDDIAcu,bDDIFor,bDDIWhi))//Ignora despesas com Numero de Nota
   IF Empty(MDI_OUTR)
      Return .F.
   Endif
ENDIF

ProcRegua(50)

SW7->(DbSeek(xFILIAL("SW7")+SW6->W6_HAWB))

aRecWork1:={} // Para os Rdmakes

ProcRegua(SW8->(LASTREC()))

If lIntDraw
   ED4->(dbSetOrder(2))
   ED0->(dbSetOrder(1))
EndIf
Work1->(dbsetorder(3))
EIJ->(DBSETORDER(1))
SW0->(DBSETORDER(1))
SYQ->(DBSETORDER(1))
SY1->(DBSETORDER(1))
SW9->(DBSETORDER(1))
SW8->(DBSETORDER(1))
SW8->(DBSEEK(cFilSW8+SW6->W6_HAWB))

DO WHILE  !SW8->(EOF()) .AND. SW8->W8_FILIAL == cFilSW8 .AND. SW8->W8_HAWB == SW6->W6_HAWB

   DI554IncProc(STR0136+' '+SW8->W8_COD_I) //"Lendo Item: "

   SB1->(DbSeek(cFilSB1+SW8->W8_COD_I))
   SW2->(DbSeek(cFilSW2+SW8->W8_PO_NUM))
   //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
   SW9->(DbSeek(cFilSW9+SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8", "W8_FORLOJ")+SW8->W8_HAWB))

   // O While é mantido, pois nem todos possuem a alteração no índice 1 da SW9 (FILIAL+INVOICE+FORNECEDOR+HAWB)
   // A alteração do índice 1 da SW9 é disponibilizada através do update UIINVOICE
   DO WHILE !SW9->(EOF()) .AND. SW9->W9_FILIAL  == cFILSW9         .AND.;
                                SW8->W8_INVOICE == SW9->W9_INVOICE .AND.;
                                SW8->W8_FORN    == SW9->W9_FORN    .And.;
                                (!EICLoja() .Or. SW8->W8_FORLOJ == SW9->W9_FORLOJ)
      IF SW8->W8_HAWB  == SW9->W9_HAWB
         EXIT
      ENDIF
      SW9->(DBSKIP())
   ENDDO
   IF !SW7->(DbSeek(cFilSW7+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM))
      Help("",1,"AVG0000804")
//    MSGINFO("Existe Desbalanceamento no Banco de Dados, por favor saia do Sistema.","Atencao: Arquivo SW8 => SW7")
      RETURN .F.
   ENDIF

   IF(IPIPauta(),lTemPauta := .T.,)

   lLoop:=.F.
   IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"GRVWORK_1a"),)
   IF lLoop
      SW8->(DBSKIP())
      LOOP
   ENDIF

   EIJ->(DbSeek(cFilEIJ+SW6->W6_HAWB+SW8->W8_ADICAO))
   SWZ->(DbSeek(cFilSWZ+IF(EIJ->(FIELDPOS("EIJ_OPERAC")) # 0 .AND. SW8->(FIELDPOS("W8_OPERACA")) # 0  .AND. !Empty(SW8->W8_OPERACA),SW8->W8_OPERACA,SW7->W7_OPERACA))) //RRV - 21/01/2013
   SWX->(DbSeek(cFilSWX+SWZ->WZ_CFO))// SVG - 04/05/2010 - Seek para a gravação do CFO da Nota Filha
   SYD->(DbSeek(cFilSYD+SW8->W8_TEC+SW8->W8_EX_NCM+SW8->W8_EX_NBM))
   IF !Work2->(DbSeek(SW8->W8_ADICAO+SWZ->WZ_CFO+IF(EIJ->(FIELDPOS("EIJ_OPERAC")) # 0 .AND. SW8->(FIELDPOS("W8_OPERACA")) # 0  .AND. !Empty(SW8->W8_OPERACA),SW8->W8_OPERACA,SW7->W7_OPERACA)+SW8->W8_TEC+SW8->W8_EX_NCM+SW8->W8_EX_NBM))
      Work2->(DBAPPEND())
      Work2->WKADICAO   := SW8->W8_ADICAO
      Work2->WK_CFO     := SWZ->WZ_CFO
      //TRP - 25/11/2011 - Sempre considerar primeiro a operação da Invoice.
      IF EIJ->(FIELDPOS("EIJ_OPERAC")) # 0 .AND. SW8->(FIELDPOS("W8_OPERACA")) # 0  .AND. !Empty(SW8->W8_OPERACA)
         Work2->WK_OPERACA := SW8->W8_OPERACA
      Else
         Work2->WK_OPERACA := SW7->W7_OPERACA
      Endif
      Work2->WKTEC      := SW8->W8_TEC
      Work2->WKEX_NCM   := SW8->W8_EX_NCM
      Work2->WKEX_NBM   := SW8->W8_EX_NBM
      Work2->WKREC_ID   := EIJ->(RECNO())
      Work2->WKII_A     := EIJ->EIJ_ALI_II
      Work2->WKIIREDU_A := EIJ->EIJ_PR_II
      IF !EMPTY(EIJ->EIJ_ALA_II)
         Work2->WKII_A  := EIJ->EIJ_ALA_II
      ENDIF
      IF !EMPTY(EIJ->EIJ_ALR_II)
         Work2->WKII_A  := EIJ->EIJ_ALR_II
      ENDIF
      Work2->WKIPI_A := EIJ->EIJ_ALAIPI
      IF nTipoNF # NFE_COMPLEMEN .OR. lICMS_NFC
         cOperICM := ""
         IF EIJ->(FIELDPOS("EIJ_OPERAC")) # 0 .AND. SW8->(FIELDPOS("W8_OPERACA")) # 0 
            If !Empty(SW8->W8_OPERACA)
               cOperICM := SW8->W8_OPERACA
            else
               cOperICM := SW7->W7_OPERACA
            endif
         endif
         IF !empty(cOperICM) .and. SWZ->(DbSeek( cFilSWZ+cOperICM )) //RRV - 21/01/2013
            Work2->WKICMS_A  := DITRANS(SWZ->WZ_AL_ICMS,2)
            Work2->WKICMS_RED:= IF(SWZ->WZ_RED_ICM#0,(100-SWZ->WZ_RED_ICM)/100,1)
            Work2->WKRED_CTE := SWZ->WZ_RED_CTE
            IF SWZ->(FIELDPOS("WZ_ICMS_PC")) # 0
               Work2->WKICMSPC := SWZ->WZ_ICMS_PC//ASR - 10/10/2005
            ENDIF
         ELSE
            Work2->WKICMS_A  := DITRANS(SYD->YD_ICMS_RE,2)
            Work2->WKICMS_RED:= 1
         ENDIF
      ENDIF
   ENDIF

   IF lExiste_Midia .AND. SB1->B1_MIDIA $ cSim  // LDR - 27/08/04
      lPesoNew:=SW7->W7_PESOMID*SB1->B1_QTMIDIA
   ELSE
   lPesoNew:=SW7->W7_PESO
   ENDIF

   IF lMV_EASY_SIM
      SB1->(DBSEEK(xfilial()+SW8->W8_COD_I))
      aTabSeg:=AV_Seg_Uni(SW8->W8_CC,SW8->W8_SI_NUM,SW8->W8_COD_I,SW8->W8_REG,SW8->W8_QTDE,,.T.)
      IF(LEN(aTabSeg)>2,lPesoNew:=aTabSeg[3],)
   ENDIF

   IF(EasyEntryPoint("EICDI554"),ExecBlock("EICDI554",.F.,.F.,"PESONEW"),)

   lMidia:=.F.
   IF lExiste_Midia .AND. SB1->B1_MIDIA $ cSim
      nFbMid_M  := DITrans( SB1->B1_QTMIDIA * SW8->W8_QTDE * SW2->W2_VLMIDIA, 2 )
      IF !SW9->W9_FREINC $ cSim
         nRatIPD := SW8->W8_FRETEIN
      ENDIF
      nFbMid_MRS:= DITrans( (nFbMid_M + nRatIPD) * SW9->W9_TX_FOB, 2 )
      lMidia:=.T.
   ELSE
      nRatIPD := DI500RetVal("ITEM_INV,SEM_FOB", "TAB", .T.)  // EOB - 14/07/08 - chamada da função DI500RetVal
   ENDIF

   If lPesoBruto //FSM - 02/09/2011 - Peso Bruto Unitario
      nPesoB    := SW8->W8_PESO_BR * SW8->W8_QTDE
   EndIf
   nPesoL    := lPesoNew * SW8->W8_QTDE
   nFobMoeda := DITrans(SW8->W8_PRECO*SW8->W8_QTDE,2)
   nFob_RS   := SW8->W8_FOBTOTR // Ja tem as despesas inclusas
   nRatIPD_RS:= DITRANS(nRatIPD*SW9->W9_TX_FOB,2)

   IF lmidia .OR. ( lmidia .AND. nTipoNF = NFE_COMPLEMEN )
      nFobTot  := DITrans(nFbMid_M,2)
      nFobRSTot:= DITrans(nFbMid_MRS,2)  // Ja tem as despesas inclusas
   ELSE
      nFobTot  := DITrans(nFobMoeda,2)
      nFobRSTot:= DITrans(nFob_RS,2)  // Ja tem as despesas inclusas
   ENDIF

   EIJ->(dbSeek(cFilEIJ+SW6->W6_HAWB+SW8->W8_ADICAO))

   Work1->(DBAPPEND())

   If SWN->(FieldPos("WN_AC")) # 0    // GFP - 20/09/2013 - Novo Layout NFE - (Nota técnica da NFe - 2013-005)
      If lIntDraw
         Work1->WKAC := SW8->W8_AC
      Else
         aOrd := SaveOrd({"SW4"}) //LGS-26/03/2015
         SW4->(DbSetOrder(1)) //W4_FILIAL+W4_PGI_NUM
         If SW4->(DbSeek(xFilial("SW4")+SW8->W8_PGI_NUM))
            Work1->WKAC := SW4->W4_ATO_CON
         EndIf
         RestOrd(aOrd,.T.)
      EndIf
   EndIf

   If lTemPrimeira
      nRegSWN := SWN->(RecNo())
      nOrdSWN := SWN->(IndexOrd())
      nRegSF1 := SF1->(RecNo())
      nOrdSF1 := SF1->(IndexOrd())
      nOrdSWV := SWV->(IndexOrd())
      nRegSWV := SWV->(Recno())
      lAchou  := .F.

      SWN->(dbSetOrder(1))//WN_FILIAL+WN_DOC+WN_SERIE+WN_TEC+WN_EX_NCM+WN_EX_NBM

      SF1->(dbSetOrder(5)) //F1_FILIAL+F1_HAWB+F1_TIPO_NF+F1_DOC+F1_SERIE
      SF1->(dbSeek(xFilial("SF1")+SW6->W6_HAWB))
      Do While SF1->(F1_FILIAL+F1_HAWB) == xFilial("SF1")+SW6->W6_HAWB .AND. !lAchou
         //ISS - 13/12/10 - Verificação se o HAWB corrente possui alguma nota gerada, e não apenas notas de despesas (NFD)
         If lCposNFDesp .AND. !ExistHAWBNFE(SF1->F1_HAWB)
            SF1->(DbSkip())
            Loop
         EndIf
         If SWN->(dbSeek(xFilial("SWN")+SF1->(F1_DOC+F1_SERIE)+SW8->(W8_TEC+W8_EX_NCM+W8_EX_NBM)))
            Do While SWN->(WN_FILIAL+WN_DOC+WN_SERIE+WN_TEC+WN_EX_NCM+WN_EX_NBM) == xFilial("SWN")+SF1->(F1_DOC+F1_SERIE)+SW8->(W8_TEC+W8_EX_NCM+W8_EX_NBM)
               If SWN->WN_HAWB+SWN->WN_INVOICE+SWN->WN_PO_EIC+SWN->WN_ITEM+SWN->WN_PGI_NUM == SW8->(W8_HAWB+W8_INVOICE+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM)
                  If lLote .And. SWV->(dbseek(XFILIAL("SWV")+SWN->WN_HAWB+SWN->WN_INVOICE+SWN->WN_PGI_NUM+SWN->WN_PO_EIC+SWN->WN_ITEM))
                     If Alltrim(SWV->WV_LOTE) == AllTrim(SWN->WN_LOTECTL)
                        Work1->WKADICAO  := SWN->WN_ADICAO
                        Work1->WKNOTAOR  := SWN->WN_DOC //DFS - 14/02/11 - Adição de campos na verificação
                        Work1->WKSERIEOR := SWN->WN_SERIE //DFS - 14/02/11 - Adição de campos na verificação
                        lAchou := .T.
                        EXIT
                     EndIf
                  Else
                     Work1->WKADICAO  := SWN->WN_ADICAO
                     Work1->WKNOTAOR  := SWN->WN_DOC //DFS - 14/02/11 - Adição de campos na verificação
                     Work1->WKSERIEOR := SWN->WN_SERIE //DFS - 14/02/11 - Adição de campos na verificação
                     lAchou := .T.
                     EXIT
                  EndIf
               EndIf
               SWN->(dbSkip())
            EndDo
         EndIf

         SF1->(dbSkip())
      EndDo
      SWV->(dbSetOrder(nOrdSWV),dbGoTo(nRegSWV))
      SF1->(dbSetOrder(nOrdSF1),dbGoTo(nRegSF1))
      SWN->(dbSetOrder(nOrdSWN),dbGoTo(nRegSWN))
   EndIf

   Work1->WKPO_NUM :=SW8->W8_PO_NUM
   Work1->WKPOSICAO:=SW8->W8_POSICAO
   Work1->WKPGI_NUM:=SW8->W8_PGI_NUM
   If Empty(Work1->WKADICAO)
      Work1->WKADICAO :=SW8->W8_ADICAO
   EndIf
   Work1->WKINVOICE:=SW8->W8_INVOICE
   IF !(lExiste_Midia .AND. SB1->B1_MIDIA $ cSim)  // Bete - 24/02/05
      Work1->WKOUTDESP:=SW8->W8_OUTDESP
      Work1->WKINLAND :=SW8->W8_INLAND
      Work1->WKPACKING:=SW8->W8_PACKING
      Work1->WKDESCONT:=IF(!lIn327,SW8->W8_DESCONT,0)  // Bete - 24/02/05
   ENDIF
   Work1->WKVLACRES:=SW8->W8_VLACRES
   Work1->WKVLDEDU :=SW8->W8_VLDEDU

   Work1->WKRATEIO :=(nFobRSTot/(nTotFob_Proc+MDespesas))

   If SWN->(FieldPos("WN_NVE")) # 0  // GFP - 20/09/2013 - Novo Layout NFE - (Nota técnica da NFe - 2013-005)
      Work1->WKNVE := SW8->W8_NVE
   EndIf

   IF lExisteSEQ_ADI// AWR - 06/11/08 - NFE
      Work1->WKSEQ_ADI := SW8->W8_SEQ_ADI
   ENDIF
   IF lMV_GRCPNFE .AND. nTipoNF # NFE_COMPLEMEN .AND. nTipoNF # NFE_FILHA //Campos novos NFE - AWR 06/11/2008
      IF !Empty(SWZ->WZ_RED_CTE)                      //NCF - 12/11/2009 - Grava a aliquota da carga tribut. equivalente
         Work1->WKPREDICM :=SWZ->WZ_RED_CTE           //                   caso a mesma esteja pre-enchida, senão, grava
      ELSE                                            //                   a aliquota de redução da base de ICMS.
         Work1->WKPREDICM :=SWZ->WZ_RED_ICM
      ENDIF
      Work1->WKALUIPI  :=EIJ->EIJ_ALUIPI
      Work1->WKQTUIPI  :=EIJ->EIJ_QTUIPI
      Work1->WKQTUPIS  :=EIJ->EIJ_QTUPIS
      Work1->WKQTUCOF  :=EIJ->EIJ_QTUCOF
   ENDIF

   If lIntDraw
      IF ED4->(DBSEEK(xFilial()+SW8->W8_AC+SW8->W8_SEQSIS))
         IF ED0->(DBSEEK(xFilial()+ED4->ED4_PD))
            IF cQbrACModal = "1"
               Work1->WKACMODAL:=SW8->W8_AC
            ELSEIF cQbrACModal = "2"
               Work1->WKACMODAL:=ED0->ED0_MODAL
            ENDIF
         ENDIF
      ENDIF
   EndIf

   IF lMidia
      Work1->WK_VLMID_M:= DITrans(nFbMid_MRS,2)
      Work1->WK_QTMID  := SB1->B1_QTMIDIA * SW8->W8_QTDE
      IF lSomaDifMidia .AND. lNaoTemComp // AWR - MIDIA - 7/5/4
         nTaxa:=BuscaTaxa(cMoeDolar,SW6->W6_DT_DESE,.T.,.F.,.T.)
         IF(nTaxa=0,nTaxa:=1,)
         nDespDif := SW8->W8_INLAND+SW8->W8_PACKING+SW8->W8_OUTDESP-IF(!lIn327,SW8->W8_DESCONTO,0) // Bete - 24/02/05
         Work1->WKRDIFMID := DITrans( ((nFobMoeda+nDespDif) - (Work1->WK_QTMID * SW2->W2_VLMIDIA))* SW9->W9_TX_FOB,2 ) // Bete - 24/02/05
         Work1->WKUDIFMID := DITrans( ((nFobMoeda+nDespDif) - (Work1->WK_QTMID * SW2->W2_VLMIDIA))* IF(SW9->W9_MOE_FOB=cMoeDolar,1,(SW9->W9_TX_FOB/nTaxa)) ,2 ) // Bete - 24/02/05
         Work2->WKRDIFMID += Work1->WKRDIFMID
         Work2->WKUDIFMID += Work1->WKUDIFMID
      ENDIF
   ENDIF  // AWR - MIDIA - 7/5/4
   IF lNaoTemComp
      Work1->WKRDIFMID += DITrans( nDifCamb * Work1->WKRATEIO ,2)
      Work2->WKRDIFMID += DITrans( nDifCamb * Work1->WKRATEIO ,2)// AWR - MIDIA - 7/5/4
   ENDIF

   SA5->(DbSeek(xFilial("SA5")+SW8->W8_COD_I+SW8->W8_FABR+SW8->W8_FORN))
   SA2->(DBSEEK(xFilial("SA2")+SW8->W8_FORN))
   If nTipoNF == NFE_COMPLEMEN .AND. SW6->W6_IMPCO == "1"  // GFP - 21/01/2015 - Geração de NF Complementar para processos Conta e Ordem deve ser apresentado Fornecedor do Importador.
	   IF !Empty(SYT->YT_FORN) .And. !Empty(SYT->YT_LOJA)   //LRS - 8/10/2015 - Verifica se o Fornecedor do processo Complementar do conta e ordem está preenchido, se não pega do P.O.
		  SA2->(DbSeek(xFilial("SA2")+SYT->YT_FORN+EICRetLoja("SYT", "YT_LOJA")))
	   Else
		  SA2->(DbSeek(xFilial("SA2")+SW2->W2_FORN+EICRetLoja("SW2", "W2_FORLOJ")))
	   EndIF
   EndIf
   IF(ASCAN(aLista,{|F|F=SW8->W8_FORN})=0,AADD(aLista,SW8->W8_FORN+"-"+SA2->A2_NREDUZ),)

   Work1->WKCOD_I   := SW8->W8_COD_I
   Work1->WKTEC     := SW8->W8_TEC
   Work1->WKEX_NCM  := SW8->W8_EX_NCM
   Work1->WKEX_NBM  := SW8->W8_EX_NBM
   Work1->WKREGTRII := EIJ->EIJ_REGTRI
   Work1->WKREGTRIPI:= EIJ->EIJ_REGIPI

   If AvFlags("EIC_EAI")//AHAC - 02/07/14 - Integrado com Logix pega a segunda unidade
      aSegUnid:= AClone(BUSCA_2UM(Work1->WKPO_NUM, Work1->WKPOSICAO))
      Work1->WKUNI:= aSegUnid[2] //segunda unidade de medida
      Work1->WKQTDE:= SW8->W8_QTDE * aSegUnid[3] //quantidade X fator de conversão
      Work1->WKPRECO:= SW8->W8_QTDE * SW8->W8_PRECO / Work1->WKQTDE
   Else
      Work1->WKUNI  := BUSCA_UM(SW7->W7_COD_I+SW7->W7_FABR +SW7->W7_FORN,SW7->W7_CC+SW7->W7_SI_NUM,EICRetLoja("SW7", "W7_FABLOJ"),EICRetLoja("SW7", "W7_FORLOJ"))
      Work1->WKQTDE := SW8->W8_QTDE
      Work1->WKPRECO:= SW8->W8_PRECO
   EndIf

   Work1->WKDESCR   := MEMOLINE(MSMM(SB1->B1_DESC_P,cTam),60)
   Work1->WKREC_ID  := SW7->(RECNO())
   Work1->WKPO_NUM  := SW8->W8_PO_NUM
   Work1->WKFORN    := If(nTipoNF == NFE_COMPLEMEN .AND. SW6->W6_IMPCO == "1",SA2->A2_COD,SW8->W8_FORN)  // GFP - 21/01/2015 - Geração de NF Complementar para processos Conta e Ordem deve ser apresentado Fornecedor do Importador.
   Work1->WKFABR    := SW8->W8_FABR
   IF EICLOJA()
      Work1->WKLOJA    := SW8->W8_FORLOJ
   ELSE
      Work1->WKLOJA    := SA2->A2_LOJA
   ENDIF
   Work1->WKPO_SIGA := DI154_PO_SIGA() // RA - 24/10/03 - O.S. 1076/03 // Antes=>SW2->W2_PO_SIGA
   Work1->WK_CC     := SW8->W8_CC
   Work1->WKSI_NUM  := SW8->W8_SI_NUM
   //TRP - 25/11/2011 - Sempre considerar primeiro a operação da Invoice.
   IF EIJ->(FIELDPOS("EIJ_OPERAC")) # 0 .AND. SW8->(FIELDPOS("W8_OPERACA")) # 0  .AND. !Empty(SW8->W8_OPERACA)
      Work1->WK_OPERACA := SW8->W8_OPERACA
   Else
      Work1->WK_OPERACA := SW7->W7_OPERACA
   Endif

   //RRV - 21/01/2013
   SWZ->(DbSeek(cFilSWZ+Work1->WK_OPERACA))
   Work1->WK_CFO    := If(lMv_NF_MAE .And. nTipoNF == NFE_FILHA .And. SWX->(FieldPos("WX_CFOFILH")) # 0 , SWX->WX_CFOFILH,SWZ->WZ_CFO)// SVG - 04/05/2010 - Gravação do CFO da Nota Filha

   Work1->WKPOSICAO := SW8->W8_POSICAO
   Work1->WKPGI_NUM := SW8->W8_PGI_NUM
   Work1->WK_REG    := SW8->W8_REG
   Work1->WKIITX    := CheckAliRed("II",Work2->WKII_A)  // GFP - 23/06/2014
   Work1->WKIPITX   := CheckAliRed("IPI",Work2->WKIPI_A)  // GFP - 23/06/2014
   Work1->WKICMS_A  := Work2->WKICMS_A

   If (lMV_NF_MAE .And. nTipoNF == NFE_FILHA .And. EasyGParam("MV_NFFILHA",,"0") == "2")
      Work1->WKSEGURO:= 0
      Work1->WKFRETE:= 0
   Else
      Work1->WKSEGURO  := SW8->W8_VLSEGMN
      Work1->WKFRETE   := SW8->W8_VLFREMN
   Endif

   IF !(lMV_NF_MAE .And. nTipoNF == NFE_FILHA)
      Work1->WKVL_ICM  := SW8->W8_VLICMS
      Work1->WKIIVAL   := SW8->W8_VLII
      Work1->WKBASEII  := SW8->W8_BASEII
      Work1->WKVLDEVII := SW8->W8_VLDEVII
      Work1->WKVLDEIPI := SW8->W8_VLDEIPI
      Work1->WKIPIVAL  := SW8->W8_VLIPI
      Work1->WKIPIBASE := SW8->W8_BASEII+SW8->W8_VLII
      Work1->WKBASEICMS:= SW8->W8_BASEICM
   ENDIF
   Work1->WKCIF     := SW8->W8_BASEII//DITrans(nFobRSTot+Work1->WKFRETE+Work1->WKSEGURO,2)

   If lICMS_Dif  // PLB 14/05/07 - ICMS diferido  NCF-28/05/2010
      Work1->WKVLICMDEV := SW8->W8_VLICMDV
      Work1->WKVL_ICM_D := SW8->W8_VICMDIF  //02
      Work1->WKVLCREPRE := SW8->W8_VICM_CP  //05
   EndIf
   If lICMS_Dif2 // EOB - 16/02/09
      Work1->WK_PERCDIF := SW8->W8_PICMDIF  //01
      Work1->WK_CRE_PRE := SW8->W8_PICM_CP  //03
      Work1->WK_PCREPRE := SW8->W8_PCREPRE  //04
      Work1->WK_PAG_DES := SW8->W8_ICMS_PD  //06
   EndIf

   IF lCposICMSPt                                                                    //NCF - 11\05\2011 - Inclui o campo de ICMS devido para tratamento de ICMS de Pauta
      Work1->WKVLICMDEV := SW8->W8_VLICMDV
   ENDIF

   If AvFlags("ICMSFECP_DI_ELETRONICA")
      Work1->WKALFECP := SW8->W8_ALFECP
      Work1->WKVLFECP := SW8->W8_VLFECP
   EndIf
   If AVFLAGS("FECP_DIFERIMENTO")
      Work1->WKFECPALD := SW8->W8_FECPALD
      Work1->WKFECPVLD := SW8->W8_FECPVLD
      Work1->WKFECPREC := SW8->W8_FECPREC
   EndIf
   IF lMV_PIS_EIC  .AND. nTipoNF # 2 .And. nTipoNF # NFE_FILHA
      Work1->WKVLUPIS  := SW8->W8_VLUPIS
      Work1->WKBASPIS  := SW8->W8_BASPIS
      Work1->WKPERPIS  := SW8->W8_PERPIS
      Work1->WKVLRPIS  := SW8->W8_VLRPIS
      Work1->WKVLUCOF  := SW8->W8_VLUCOF
      Work1->WKBASCOF  := SW8->W8_BASCOF
      Work1->WKPERCOF  := SW8->W8_PERCOF
      Work1->WKVLRCOF  := SW8->W8_VLRCOF

	  //AAF 20/12/2016 - Carregar campos de valor devido de pis e cofins para calcular a base de icms nos casos de suspensão do imposto
	  Work1->WKVLDEPIS := If(EIJ->EIJ_REG_PC == "5",SW8->W8_VLDEPIS,SW8->W8_VLRPIS)
	  Work1->WKVLDECOF := If(EIJ->EIJ_REG_PC == "5",SW8->W8_VLDECOF,SW8->W8_VLRCOF)

      Work2->WKBASPIS  += SW8->W8_BASPIS
      Work2->WKVLRPIS  += SW8->W8_VLRPIS
      Work2->WKBASCOF  += SW8->W8_BASCOF
      Work2->WKVLRCOF  += SW8->W8_VLRCOF

      If lCposCofMj                                                            //NCF - 20/07/2012 - Majoração COFINS
         Work1->WKVLCOFM  += SW8->W8_VLCOFM
         Work1->WKALCOFM  := EIJ->EIJ_ALCOFM
      EndIf
      If lCposPisMj                                                            //GFP - 11/06/2013 - Majoração PIS
         Work1->WKVLPISM  += SW8->W8_VLPISM
         Work1->WKALPISM  := EIJ->EIJ_ALPISM
      EndIf

      nNBM_PIS         += Work1->WKVLRPIS
      nNBM_COF         += Work1->WKVLRCOF
   ENDIF
   //LGS-19/05/2014 - Com o parametro ligado devo manter o total com a soma de todas as despesas taxa siscomex que foram informadas no processo
   //				  para integrar com o compras e manter os valores do EIC igual no Compras.
   IF lDespBaseIcms .And. nTipoNF <> NFE_COMPLEMEN
      Work1->WKDESPICM  := SW8->W8_D_BAICM //If ( EasyGParam("MV_EIC0042",,.F.),nSomaBaseICMS,SW8->W8_D_BAICM) //LGS-27/07/2015
      Work1->WKOUT_DESP += SW8->W8_D_BAICM //If ( EasyGParam("MV_EIC0042",,.F.),nSomaBaseICMS,SW8->W8_D_BAICM) //LGS-27/07/2015
      nVlrCustoSNW      := SW8->W8_D_BAICM
   Else
      Work1->WKDESPICM  := DITrans((nPSomaBaseICMS+nSomaBaseICMS)*Work1->WKRATEIO,2) //SVG - 22/12/2010 -
   ENDIF

   AADD(aRecWork1,Work1->(RECNO()))

   //FSM 02/09/2011 - Peso Bruto Unitario
   If lPesoBruto
      Work1->WKPESOBR := nPesoB
   EndIf
   Work1->WKPESOL   := IF((lMV_NF_MAE .And. nTipoNF == NFE_FILHA), lPesoNew, nPesoL)
   Work1->WKFOB     := DITrans(nFobTot+nRatIPD,2)
   Work1->WKFOB_R   := DITrans(nFobRSTot,2)
   Work1->WKFOB_ORI := DITrans(nFobMoeda+nRatIPD,2)
   Work1->WKFOBR_ORI:= DITrans(nFob_RS,2)

   MDI_FOB_R        += Work1->WKFOB_R
   If !(lMV_NF_MAE .And. nTipoNF == NFE_FILHA) // SVG - 27/05/2010 -
      Work2->WKPESOL   += Work1->WKPESOL
      Work2->WKFOB     += Work1->WKFOB
      Work2->WKFOB_R   += Work1->WKFOB_R
      Work2->WKFOB_ORI += Work1->WKFOB_ORI
      Work2->WKFOBR_ORI+= Work1->WKFOBR_ORI
      Work2->WKQTDE    += Work1->WKQTDE
      Work2->WKFRETE   += Work1->WKFRETE
      Work2->WKSEGURO  += Work1->WKSEGURO
      Work2->WKCIF     += Work1->WKCIF
      Work2->WKVLACRES += Work1->WKVLACRES
      Work2->WKVLDEDU  += Work1->WKVLDEDU
      Work2->WKBASEII  += Work1->WKBASEII
      Work2->WKII      += Work1->WKIIVAL//EIJ->EIJ_VLARII
      Work2->WKIPI     += Work1->WKIPIVAL//EIJ->EIJ_VLAIPI
      Work2->WKICMS    += Work1->WKVL_ICM//EIJ->EIJ_VLICMS
   Endif
//   IF !lCurrier
      MDI_FRETE += Work1->WKFRETE
      MDI_SEGURO+= Work1->WKSEGURO
//   ENDIF
   MDI_CIF  += Work1->WKBASEII//Work1->WKCIF
   MDI_PESO += Work1->WKPESOL
   MDI_QTDE += Work1->WKQTDE

   IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"GRVWORK_4"),)

   //IF (nTipoNF # NFE_PRIMEIRA .AND. !lLote) - RMD - 29/05/08 - Não deve considerar o uso de lotes ao alimentar a work
   IF nTipoNF # NFE_PRIMEIRA .AND. nTipoNF # NFE_MAE
      lAcerta:=.T.
      FOR Wind = 1 TO LEN(aDespesa)
          SWD->(DBGOTO(aDespesa[Wind,4]))
          nTaxa:=BuscaTaxa(cMoeDolar,SWD->WD_DES_ADI,.T.,.F.,.T.)
          IF(nTaxa=0,nTaxa:=1,)
          Work3->(DBAPPEND())
          Work3->WKRECNO   := Work1->(RECNO())
          Work3->WKDESPESA := aDespesa[Wind,1] + IF(SYB->(DBSEEK(XFILIAL("SYB")+aDespesa[Wind,1])),;
                                                 "-"+SUBS(SYB->YB_DESCR,1,20)," ")
          nValor:=DITRANS(aDespesa[Wind,2]*Work1->WKRATEIO,2)
          Work3->WKVALOR   := nValor
          Work3->WKVALOR_US:= DITRANS(Work3->WKVALOR/nTaxa,2)
          Work3->WKPO_NUM  := Work1->WKPO_NUM
          Work3->WKPOSICAO := Work1->WKPOSICAO
          Work3->WKPGI_NUM := Work1->WKPGI_NUM
          IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"GRVWORK3"),)//PADRAO
          IF lAcerta
             IF (nPos:=ASCAN(aDesAcerto,{|Desp|Desp[1]==Work3->WKDESPESA})) = 0
                AADD(aDesAcerto,{Work3->WKDESPESA,Work3->WKVALOR,Work3->WKVALOR_US,aDespesa[Wind,2],DITRANS(aDespesa[Wind,2]/nTaxa,2)})
             ELSE
                aDesAcerto[nPos,2] += Work3->WKVALOR
                aDesAcerto[nPos,3] += Work3->WKVALOR_US
             ENDIF
          ENDIF
      NEXT

   ENDIF

   SW8->(DBSKIP())

ENDDO

IF lLote
	//Quebra os itens da NF de acordo com os lotes.
	DI554Lote()
ENDIF

If (lMV_NF_MAE .And. nTipoNF == NFE_FILHA)
	//Busca informações da NF Mãe.
	Di554NfFilha()
EndIf

lTemItens  := .F.
lGrvWk2    := .F.
If (lMV_NF_MAE .And. nTipoNF == NFE_FILHA) .And. (SF1->(DBSeek(xFilial("SF1")+SW6->W6_HAWB+"5")) .Or. SF1->(DBSeek(xFilial("SF1")+SW6->W6_HAWB+"3")) .Or. SF1->(DBSeek(xFilial("SF1")+SW6->W6_HAWB+"1"))) //SVG - 07/04/2011 - Nota fiscal filha a partir da nota primeira , unica ou mãe.
   Work1->(dbGoTop())
   Do While Work1->(!EOF()) .And. !lTemItens
      If Work1->WKSLDDISP > 0
         lTemItens:= .T.
      EndIf
      Work1->(dbSkip())
   EndDo
   Work1->(dbGoTop())
   If lTemItens
      IF DI554FILHA()
         lGrvWk2 := .T.
      ELSE
         RETURN .F.
      ENDIF
   Else
      MsgInfo(STR0315)
      Return .F.
   EndIf
Else
   lGrvWk2 := .F.  //*******
EndIf

If lGrvWk2
      SW8->(dbSetOrder(6))
      Work1->(dbGoTop())
      Do While Work1->(!EOF())
         SW8->(dbSeek(cFilSW8+SW6->W6_HAWB+Work1->WKINVOICE+Work1->WKPO_NUM+Work1->WKPOSICAO+Work1->WKPGI_NUM))

         DI554GrvWK2()

   	     Work1->(dbSkip())
   	  EndDo
   	  Work1->(dbGoTop())
EndIf
IF (EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"GRVWORK_2"),)

IF nTipoNF <> NFE_FILHA
   FOR E=1 TO LEN(aDesAcerto)

      Work3->(DBGOTOP())
      DO WHILE ! Work3->(EOF())
         IF Work3->WKDESPESA == aDesAcerto[E,1]
            EXIT
         ENDIF
         Work3->(DBSKIP())
      ENDDO
      IF aDesAcerto[E,2] # aDesAcerto[E,4]
         Work3->WKVALOR := Work3->WKVALOR + (aDesAcerto[E,4] - aDesAcerto[E,2])
      ENDIF

      IF aDesAcerto[E,3] # aDesAcerto[E,5]
         Work3->WKVALOR_US := Work3->WKVALOR_US + (aDesAcerto[E,5] - aDesAcerto[E,3])
      ENDIF
   NEXT
ENDIF

If nTipoNf == NFE_COMPLEMEN .OR. nTipoNF == NFE_FILHA//AWF - 31/07/2014 - Nao testei o lMV_NF_MAE pq se tiver ligado nunca vai ter o tipo NF Filha
   DI154GrvOri()
EndIf

Work3->(DBGOTOP())

IF nTipoNF = CUSTO_REAL//CR
   Work1->(DBSETORDER(3))
ENDIF

IF nTipoNF <> NFE_FILHA
   Work2->(DBGOTOP())

   nNBM_CIF:=nNBM_II:=nNBM_IPI:=nNBM_ICMS:=0
   nNBM_FRETE:= nNBM_FOB_R:= nNBM_SEGURO:=0
   nRDIFMID := nOUTRDESP := nOUTRD_US := 0
   nNBM_PIS:=nNBM_COF:=0

   ProcRegua( Work2->( LASTREC() ) * 2 )
   nCIFMaior:=Work2->WKCIF
   nRecno   :=Work2->(RECNO())
   nRecnoMidia:=0
   DO WHILE  Work2->(!EOF())

      DI554IncProc(STR0137) //"Gravando impostos das NCMs"

      IF nTipoNF # NFE_PRIMEIRA .AND. nTipoNF # NFE_MAE
        IF lRateioCIF
           Work2->WKOUTRDESP:= DITrans(MDI_OUTR  * Work2->WKCIF/MDI_CIF   ,2)
           Work2->WKOUTRD_US:= DITrans(MDI_OU_US * Work2->WKCIF/MDI_CIF,2)
        ELSE
           Work2->WKOUTRDESP:= DITRANS(MDI_OUTR  * (Work2->WKFOBR_ORI / (nTotFob_Proc+MDespesas)),2)
           Work2->WKOUTRD_US:= DITRANS(MDI_OU_US * (Work2->WKFOBR_ORI / (nTotFob_Proc+MDespesas)),2)
        ENDIF
      ENDIF

      IF lExiste_Midia .AND. nTipoNF # NFE_PRIMEIRA .AND. nTipoNF # NFE_MAE .AND. lNaoTemComp
         IF !EMPTY(Work2->WKRDIFMID)
            nRecnoMidia:=Work2->(RECNO())
         ENDIF
      ENDIF
      IF Work2->WKCIF > nCIFMaior
         nCIFMaior:=Work2->WKCIF
         nRecno   :=Work2->(RECNO())
      ENDIF

      nRDIFMID    += Work2->WKRDIFMID
      nOUTRDESP   += Work2->WKOUTRDESP
      nOUTRD_US   += Work2->WKOUTRD_US

      Work2->(DBSKIP())
   ENDDO

   Work2->(DBGOTO(nRecno))

   IF nTipoNF # NFE_PRIMEIRA .AND. nTipoNF # NFE_MAE
      IF DiTrans( MDI_OUTR,2 ) # DiTrans( nOUTRDESP,2 )
         Work2->WKOUTRDESP += DiTrans( MDI_OUTR ,2 ) - DiTrans( nOUTRDESP,2 )
      ENDIF

      IF DiTrans( MDI_OU_US,2 ) # DiTrans( nOUTRD_US,2 )
         Work2->WKOUTRD_US += DiTrans( MDI_OU_US ,2 ) - DiTrans( nOUTRD_US,2 )
      ENDIF
   ENDIF

   IF lNaoTemComp
      IF lExiste_Midia .AND. lSomaDifMidia
         IF(nRecnoMidia=0,,Work2->(DBGOTO(nRecnoMidia)))
         IF DITrans(nRDIFMID,2) # DITrans(nDifCamb+(nFobItemMidiaRS-M_FOB_MIDRS),2)
            Work2->WKRDIFMID   += DITrans(nDifCamb+(nFobItemMidiaRS-M_FOB_MIDRS),2) - DITrans(nRDIFMID,2)
         ENDIF
      ELSE
         IF DITrans(nRDIFMID,2) # DITrans(nDifCamb,2)
            Work2->WKRDIFMID += DITrans(nDifCamb,2) - DITrans(nRDIFMID,2)
         ENDIF
      ENDIF
   ENDIF

   Work2->(DBGOTOP())

   nNBM_CIF:=nNBM_II:=nNBM_IPI:=nNBM_ICMS:=0
   nNBM_PIS:=nNBM_COF:=0
   If lRecalcIcms
      nNewVlIcm:= 0  //TRP - 13/03/2010
   Endif
   nSumDespI:= 0

   DO WHILE  Work2->(!EOF())

      DI554IncProc(STR0137) //"Gravando impostos das NCMs"

      IF nTipoNF <> NFE_COMPLEMEN
         nNBM_CIF   +=Work2->WKCIF  ; nNBM_II    +=Work2->WKII
         nNBM_IPI   +=Work2->WKIPI;   nNBM_ICMS  +=Work2->WKICMS
         nNBM_PIS   +=Work2->WKVLRPIS ; nNBM_COF +=Work2->WKVLRCOF
      ENDIF

      IF nTipoNF == NFE_COMPLEMEN .AND. !lRateioCIF
         Work2->WKCIF    := 0
         Work2->WKII     := 0
         Work2->WKIPI    := 0
         Work2->WKII_A   := 0
         Work2->WKIPI_A  := 0
         Work2->WKFRETE  := 0
         Work2->WKSEGURO := 0
   //    IF(!lICMS_NFC,Work2->WKICMS:=0,)
         Work2->WKICMS:=0
         Work2->WKBASEII := 0
         Work2->WKVLACRES:= 0
         Work2->WKVLDEDU := 0
      ENDIF

      DI554Rateio(.F.,nTipoNF)

      //   o fob em reais deve ser zerado apos o rateio, para nf complementar

      IF nTipoNF == NFE_COMPLEMEN
         Work2->WKFOB  :=0
         Work2->WKFOB_R:=0
      ENDIF

      IF nTipoNF == NFE_COMPLEMEN //.AND. lRateioCIF // AWR RATEIO
         Work2->WKCIF    := 0
         Work2->WKII     := 0
         Work2->WKIPI    := 0
         Work2->WKII_A   := 0
         Work2->WKIPI_A  := 0
         Work2->WKFRETE  := 0
         Work2->WKSEGURO := 0
   //      IF(!lICMS_NFC,Work2->WKICMS:=0,)
         IF !lICMS_NFC
            Work2->WKICMS:=0
         ENDIF
         Work2->WKBASEII := 0
         Work2->WKVLACRES:= 0
         Work2->WKVLDEDU := 0
      ENDIF

      If lRecalcIcms
         nNewVlIcm+=Work2->WKICMS   //TRP - 13/03/2010
      Endif

      Work2->(DBSKIP())
   ENDDO

   If lRecalcIcms
      nNBM_ICMS:=nNewVlIcm
   Endif

   DBSELECTAREA("Work2")
   DI554IncProc()
   DI554TestDI(bDifere)

   Work2->(DBGOTOP())

   nTaxa:=BuscaTaxa(cMoeDolar,SW6->W6_DT_DESE,.T.,.F.,.T.)//Taxa do Dolar
   nTaxa:=IF(nTaxa=0,1,nTaxa)

   IF nTipoNF # NFE_PRIMEIRA .AND. nTipoNF # NFE_MAE .AND. nTipoNF # CUSTO_REAL
      IF LExiste_Midia .AND. lNaoTemComp .AND. lSomaDifMidia
         MDI_OUTR += (nFobItemMidiaRS-M_FOB_MIDRS)
         MDI_OU_US+=((nFobItemMidiaRS-M_FOB_MIDRS)/nTaxa)
      ENDIF
      IF lNaoTemComp
         MDI_OUTR += nDifCamb
      ENDIF
   ELSEIF nTipoNF == CUSTO_REAL
      IF LExiste_Midia  .AND. lSomaDifMidia
         MDI_OUTR +=(nFobItemMidiaRS-M_FOB_MIDRS)
        MDI_OU_US+=((nFobItemMidiaRS-M_FOB_MIDRS)/nTaxa)
      ENDIF
      MDI_OUTR +=nDifCamb
   ENDIF
ENDIF

If lRecalcIcms
   If Work4->(DbSeek("203"))
      Work4->WKVALOR:= nNewVlIcm     //TRP - 13/03/2010 - Acerta o valor da Despesa 203-ICMS na visualização de Despesas na Nota Fiscal.
   Endif
Endif

//** AAF 17/09/2008 - Despesas base de imposto SIM e base de custos NAO (Ex.: Valoracao Aduaneira)
If EasyGParam("MV_EIC0070",,.F.)
  
   cIndice := "WKADICAO"
   bSeekWk1:=&("{|| Work2->("+cIndice+")}")
   bSeekWk2:=&("{|| Work1->("+cIndice+")}")
   bWhileWk:=&("{|| Work2->("+cIndice+") == Work1->("+cIndice+")}")

   Work2->(DBGOTOP())
   DO WHILE Work2->(!EOF())
      Work1->(DbSeek(EVAL(bSeekWk1)))

      DO WHILE !Work1->(EOF()) .AND. EVAL(bWhileWk)

         nTiraCusto := (nSemCusto*(Work1->WKFOB_R/MDI_FOB_R)+nPSemCusto*(Work1->WKPESOL/MDI_PESO))  // BHF/BETE 06/02/09

         Work1->WKCIF     -= nTiraCusto
         Work1->WKVALMERC -= nTiraCusto

         Work1->(DBSKIP())
      ENDDO

      Work2->WKCIF -= (nSemCusto+nPSemCusto)

      Work2->(dbSkip())
   ENDDO

EndIf

IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"FINALGRAVA"),)

RETURN .T.

*----------------------------------------------------------------------------*
FUNCTION DI554IncProc(cMsg)
*----------------------------------------------------------------------------*
IF nContProc > 50
   ProcRegua(50)
   nContProc:=0
ENDIF
nContProc++
IncProc(cMsg)
RETURN .T.
*----------------------------------------------------------------------------*
FUNCTION DI554GrvDespesa()// AWR 03/08/2000
*----------------------------------------------------------------------------*
LOCAL lBaseICM:=.F.
PRIVATE bValid:={|| .T. }, lJaSomou:=.F.
PRIVATE xFilSYB:=xFilial("SYB")

PRIVATE lDespAuto:=.f.

SYB->(DBSETORDER(1))
SWD->(DbSeek((xFilSWD:=xFilial("SWD"))+SW6->W6_HAWB))
IF lGravaWorks
   bValid:={|| SWD->WD_NF_COMP+SWD->WD_SE_NFC=cNota .OR. nTipoNF = CUSTO_REAL }
ELSE
   bValid:={|| EMPTY(SWD->WD_NF_COMP) .OR. nTipoNF = CUSTO_REAL }
ENDIF
nSomaNoCIF:=nSomaBaseICMS:=nPSomaNoCIF:=nPSomaBaseICMS:= nSomaDespRatAdicao:= 0//AWR
nTxSisc := 0

DO WHILE  xFilSWD == SWD->WD_FILIAL .AND. SWD->WD_HAWB==SW6->W6_HAWB .AND. !SWD->(EOF())

   DI154IncProc()
   lLoop:=.F.
   IF(EasyEntryPoint("EICDI154"),Execblock("EICDI154",.F.,.F.,"ANTES_GRAVA_WOKR4"),)
   IF lLoop
      SWD->(DBSKIP())
      LOOP
   ENDIF
   //NCF - 12/07/2011 - Não considerar Adiantamento de Taxa Siscomex
   //IF EasyGParam("MV_CODTXSI",,"") $ SWD->WD_DESPESA .And. SWD->WD_BASEADI $ cSim
   //   SWD->(DBSKIP())
   //   LOOP
   //ENDIF

   Work4->(DBAPPEND())

   IF SYB->(DBSEEK(xFilSYB+SWD->WD_DESPESA)) .AND.  !(LEFT(SWD->WD_DESPESA,1) $ "129")
      lJaSomou:=.F.
      Work4->WKBASEICM:=SYB->YB_BASEICM
      lBaseICM:=SYB->YB_BASEICM $ cSim
      IF lTemYB_ICM_UF
         Work4->WKICMS_UF:=SYB->(FIELDGET(FIELDPOS(cCpoBasICMS)))
         lBaseICM:=lBaseICM .AND. Work4->WKICMS_UF $ cSim
      ENDIF


      IF lBaseICM .AND. (nTipoNF==NFE_PRIMEIRA .OR. nTipoNF==NFE_UNICA .OR. nTipoNF==CUSTO_REAL .OR. (lMV_NF_MAE .And. nTipoNF == NFE_MAE)) //.AND. !lLerNota
         If SWD->WD_DESPESA $ cDespRatAdicao
            /* despesas que devem ser rateadas pela quantidade de adições */
            nSomaDespRatAdicao += DI154_SWDVal(.T.)
         ElseIf SYB->YB_RATPESO $ cSim
            nPSomaBaseICMS += DI154_SWDVal(.T.)
         ELSE
            nSomaBaseICMS += DI154_SWDVal(.T.)
         ENDIF
         lJaSomou:=.T.
	  ENDIF
      IF lICMS_NFC
         Work4->WKICMSNFC:=SYB->YB_ICMSNFC
         //FDR - 04/06/13 - Verifica UF para calcular base do ICMS da despesa
         IF SYB->YB_ICMSNFC $ cSim .AND. /*SYB->(FIELDGET(FIELDPOS(cCpoBasICMS))) $ cSim*/ IF(lTemYB_ICM_UF,SYB->(FIELDGET(FIELDPOS(cCpoBasICMS))) $ cSim,SYB->YB_BASEICM $ cSim) .AND. ((lICMSCompl .AND. EVAL(bValid)) .OR. lLerNota) // GFP - 30/10/2013
            IF !lJaSomou
               If SWD->WD_DESPESA $ cDespRatAdicao
                  /* despesas que devem ser rateadas pela quantidade de adições */
                  nSomaDespRatAdicao += DI154_SWDVal(.T.)
               ElseIf SYB->YB_RATPESO $ cSim
                  nPSomaBaseICMS += DI154_SWDVal(.T.)
               ELSE
                  nSomaBaseICMS  += DI154_SWDVal(.T.)
               ENDIF
            ENDIF
         ENDIF
      ENDIF
      Work4->WKBASECUS:=SYB->YB_BASECUS
      Work4->WKBASEIMP:=SYB->YB_BASEIMP


      IF SYB->YB_BASEIMP $ cSim
         IF SYB->YB_RATPESO $ cSim
            nPSomaNoCIF += DI154_SWDVal(.T.)
         ELSE
            nSomaNoCIF  += DI154_SWDVal(.T.)
         ENDIF

         //** AAF 17/09/2008 - Despesas base de imposto SIM e base de custos NAO (Ex.: Valoracao Aduaneira)
         IF !(SYB->YB_BASECUS $ cSim) .AND. (EVAL(bValid) .OR. lLerNota)
            IF SYB->YB_RATPESO $ cSim
               nPSemCusto += DI154_SWDVal(.T.)
            ELSE
               nSemCusto  += DI154_SWDVal(.T.)
            ENDIF
         ENDIF
         //**
      ENDIF
   ENDIF

   // EOS - 25/04/03
   Work4->WKRATPESO:=SYB->YB_RATPESO
   Work4->WKDESP   :=SWD->WD_DESPESA+"-"+SYB->YB_DESCR
   Work4->WKVALOR  :=DI154_SWDVal()
   Work4->WKNOTA   :=SWD->WD_NF_COMP
   Work4->WKSERIE  :=SWD->WD_SE_NFC
   IF(EasyEntryPoint("EICDI154"),Execblock("EICDI154",.F.,.F.,"GRAVA_WOKR4"),)
   SWD->(DBSKIP())

ENDDO 
                   
nSomaBaseICMS += DI554VlAnDubICM("EIJ",SW6->W6_HAWB,nTipoNF)  //NCF - 14/09/2017 - Soma Desp.Ant.Dumping das adições caso houver

Return NIL

*----------------------------------------------------------------------------*
FUNCTION DI554VerDespesas(cDespesa,lFimArq)
*----------------------------------------------------------------------------*
LOCAL cMsg:=""

IF lFimArq
   cMsg:=STR0138+cDespesa+STR0139 //" Despesa "###" não cadastrada para este Processo"
ELSEIF EMPTY(SWD->WD_VALOR_R)
   cMsg:=STR0138+cDespesa+STR0140 //" Despesa "###" com valor não preenchido para este Processo"
ENDIF

IF !EMPTY(cMsg)
   DI554MsgDif(.F.,1,1,cDespesa,cMsg)
ENDIF

RETURN NIL

*----------------------------------------------------------------------------*
FUNCTION DI554Rateio(Alteracao,nTipoNF)
*----------------------------------------------------------------------------*
LOCAL nRec, nValMerc:= nDesp:= nDesp_US:= nFob:= nII:= nIPI:= nIPIBase:= nFrete:= nSeguro:= nCIF:= nICMS:=0
LOCAL nCifMaior := 0
LOCAL nVlICMS:=IF(lExiste_Midia,EasyGParam("MV_ICMSMID"),0), lPassouIPI:=.f., lPassouICMS:=.f.
LOCAL nValorIPIPauta:=0
//TRP - 10/03/2010
LOCAL nRedICMS, nWZ_ICMSPC:= 0
LOCAL nSomaICMS_NCM :=DITRANS((nSomaBaseICMS *(Work2->WKFOB_R/MDI_FOB_R)),2)
Local nASomaICMS_NCM:=DiTrans(nSomaDespRatAdicao/ Work2->(EasyRecCount()), 2)
LOCAL nPSomaICMS_NCM:=DITRANS(nPSomaBaseICMS*(Work2->WKPESOL/MDI_PESO ),2)
PRIVATE nVal_Dif := nVal_CP := nVal_ICM := 0//AWF - Usadas nas funcões DI154CalcICMS() e DI154Diferido()

Work1->(DBSETORDER(1))
IF !Work1->(DbSeek(Work2->WKADICAO+Work2->WK_CFO+Work2->WK_OPERACA+Work2->WKTEC+Work2->WKEX_NCM+Work2->WKEX_NBM))
   Help("",1,"AVG0000804")
// MSGINFO("Existe Desbalanceamento no Banco de Dados, por favor saia do Sistema.","Atenção")
   RETURN .F.
ENDIF
nRec:=Work1->(RECNO())
nCifMaior := Work1->WKCIF

IF SB1->(DbSeek(xFilial()+Work1->WKCOD_I)) .AND. nTipoNF # NFE_COMPLEMEN
   IF lExiste_Midia .AND. SB1->B1_MIDIA $ cSim .AND. !EMPTY(nVlICMS)
      nNBM_ICMS    -=Work2->WKICMS
      Work2->WKICMS:=0
   ENDIF
ENDIF

DO WHILE !Work1->(EOF()) .AND. (Work1->WKADICAO+Work1->WK_CFO+Work1->WK_OPERACA+Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM) ==;
                               (Work2->WKADICAO+Work2->WK_CFO+Work2->WK_OPERACA+Work2->WKTEC+Work2->WKEX_NCM+Work2->WKEX_NBM)

  Work1->WKRATEIO:=Work1->WKFOBR_ORI/Work2->WKFOBR_ORI
  IF(!lRatFretePorFOB,Work1->WKRATPESO:=Work1->WKPESOL/Work2->WKPESOL,)
  IF(lRatFreQTDE,Work1->WKRATQTDE:=Work1->WKQTDE/Work2->WKQTDE,)

  IF nTipoNF # NFE_COMPLEMEN
     IF SB1->(DbSeek(xFilial()+Work1->WKCOD_I)) .AND. IPIPauta()
        lPassouIPI:=.T.
        SW7->(DBGOTO(Work1->WKREC_ID))
        nValorIPIPauta  := IPIPauta(.T.)
        Work1->WKIPIVAL := DITrans(Work1->WKQTDE * nValorIPIPauta,2)
     ENDIF

     IF lExiste_Midia .AND. SB1->B1_MIDIA $ cSim .AND. !EMPTY(nVlICMS)
        lPassouICMS:=.T.
        Work1->WKICMS_A  := Work2->WKICMS_A
        Work1->WKBASEICMS+= DITrans(Work1->WK_QTMID * nVlICMS ,2)
        Work1->WKVL_ICM  := DITrans(Work1->WKBASEICMS*Work1->WKICMS_A/100,2)
        Work2->WKICMS    += Work1->WKVL_ICM
        nNBM_ICMS        += Work1->WKVL_ICM
     ENDIF

     IF Work1->WKCIF > nCifMaior
       nCifMaior := Work1->WKCIF
       nRec := Work1->(RECNO())
     ENDIF

//   IF nTipoNF == NFE_PRIMEIRA
     IF nTipoNF # CUSTO_REAL    //ASR 07/11/2005
        Work1->WKVALMERC := Work1->WKIPIBASE
     ELSE
        IF lRateioCIF
           Work1->WKVALMERC := Work1->WKIPIBASE +;
                               DITrans(MDI_OUTR  *  (Work1->WKCIF/MDI_CIF) + Work1->WKRDIFMID,2)
        ELSE
           Work1->WKVALMERC := Work1->WKIPIBASE +;
                               DITrans(Work2->WKOUTRDESP * Work1->WKRATEIO + Work1->WKRDIFMID,2)
        ENDIF
     ENDIF
/*     IF lCurrier
        Work1->WKIPIBASE := 0
     ENDIF
*/

     // TRP - 10/03/2010 - Recalcular a base e o valor do ICMS na nota fiscal, considerando despesas posteriores a DI (Manaus).
     If lRecalcIcms
        SW8->(DbSetOrder(4))
        If SW8->(DbSeek(xFilial("SW8") + SW6->W6_HAWB + Work1->WKADICAO))
           Work1->WK_OPERACA:= SW8->W8_OPERACA
           SWZ->(DbSetOrder(2))
           IF SWZ->(DbSeek(xFilial("SWZ")+Work1->WK_OPERACA))
              nRedICMS := IF(SWZ->WZ_RED_ICM#0,(100-SWZ->WZ_RED_ICM)/100,1)
              IF SWZ->(FIELDPOS("WZ_ICMS_PC")) # 0
                 nWZ_ICMSPC:=(SWZ->WZ_ICMS_PC/100)

                 Work1->WKDESPICM := DITrans(((nSomaICMS_NCM+nASomaICMS_NCM)*Work1->WKRATEIO)+(nPSomaICMS_NCM*Work1->WKRATPESO),2)
	             IF lRateioCIF
   	                nRateioCIF:=(Work1->WKFOB_R+Work1->WKFRETE+Work1->WKSEGURO)/(Work2->WKFOB_R+Work2->WKFRETE+Work2->WKSEGURO)
      	            Work1->WKDESPICM := DITrans(((nSomaICMS_NCM+nASomaICMS_NCM)*nRateioCIF)+(nPSomaICMS_NCM*Work1->WKRATPESO),2)
	             ENDIF

                 //Work1->WKBASEICMS := DI154CalcICMS(,nRedICMS,If(SWZ->WZ_AL_ICMS<>0,SWZ->WZ_AL_ICMS,nWZ_ICMSPC),SWZ->WZ_RED_CTE,Work1->WKBASEII,Work1->WKDESPICM,Work1->WKBASPIS,Work1->WKIIVAL,Work1->WKIPIVAL,.T.,Work1->WKVLRPIS,Work1->WKVLRCOF,Work1->WK_OPERACA)

				 //AAF 20/12/2016 - Utilizar PIS e COFINS devido para a base de icms nos casos de suspensão do imposto
				 //RMD - 04/10/17 - Confirma a utilização do PIS e COFINS devido para os casos de suspensão utilizando o campo WZ_PC_ICMS
                 lPisCofDev := .F.
                 If SWZ->(FieldPos("WZ_PC_ICMS")) > 0
                    lPisCofDev := SWZ->WZ_PC_ICMS == "1"
                 EndIf
				 Work1->WKBASEICMS := DI154CalcICMS(,nRedICMS,If(SWZ->WZ_AL_ICMS<>0,SWZ->WZ_AL_ICMS,nWZ_ICMSPC),SWZ->WZ_RED_CTE,Work1->WKBASEII,Work1->WKDESPICM,Work1->WKBASPIS,Work1->WKIIVAL,Work1->WKIPIVAL,.T.,If(lPisCofDev,Work1->WKVLDEPIS,Work1->WKVLRPIS),If(lPisCofDev,Work1->WKVLDECOF,Work1->WKVLRCOF),Work1->WK_OPERACA)

                 Work1->WKVL_ICM := DITrans(Work1->WKBASEICMS*Work1->WKICMS_A/100,2)
                 Work2->WKICMS:= Work1->WKVL_ICM
              Endif
           Endif
        Endif
     Endif

  ELSE
     IF lRateioCIF
        Work1->WKVALMERC := DITrans(MDI_OUTR * (Work1->WKCIF / MDI_CIF) + Work1->WKRDIFMID,2)
     ELSE
        Work1->WKVALMERC := DITrans(Work2->WKOUTRDESP * Work1->WKRATEIO + Work1->WKRDIFMID,2)
     ENDIF

     IF lICMSCompl .AND. lICMS_NFC
        Work1->WKICMS_RED:= Work2->WKICMS_RED
        Work1->WKICMSPC  := Work2->WKICMSPC
     ENDIF

  ENDIF

  IF nTipoNF # NFE_PRIMEIRA .AND. nTipoNF # NFE_MAE
     IF lRateioCIF
        Work1->WKOUT_DESP:= DITrans(MDI_OUTR  * Work1->WKCIF/MDI_CIF + Work1->WKRDIFMID ,2)
        Work1->WKOUT_D_US:= DITrans(MDI_OU_US * Work1->WKCIF/MDI_CIF + Work1->WKUDIFMID ,2)
        nSumDespI+= Work1->WKOUT_DESP
     ELSE
        Work1->WKOUT_DESP:= DITrans(Work2->WKOUTRDESP * Work1->WKRATEIO + Work1->WKRDIFMID ,2)
        Work1->WKOUT_D_US:= DITrans(Work2->WKOUTRD_US * Work1->WKRATEIO + Work1->WKUDIFMID ,2)
     ENDIF
  ENDIF


  IF lICMSCompl .AND. lICMS_NFC     // Bete 24/11 - Trevo

     If SWZ->(DbSeek(xFilial("SWZ")+Work1->WK_OPERACA))
        // EOB 16/02/09
		IF lICMS_Dif .AND. ASCAN( aICMS_Dif, {|x| x[1] == Work1->WK_OPERACA} ) == 0
        //                Operação           Suspensao        % diferimento    % Credito presumido                % Limite Cred.   % pg desembaraco   Aliq. do ICMS    Aliq. do ICMS S/ PIS
           AADD( aICMS_Dif, {Work1->WK_OPERACA, SWZ->WZ_ICMSUSP, SWZ->WZ_ICMSDIF, IF( lICMS_Dif2, SWZ->WZ_PCREPRE, 0), SWZ->WZ_ICMS_CP, SWZ->WZ_ICMS_PD, SWZ->WZ_AL_ICMS, SWZ->WZ_ICMS_PC     } )
        ENDIF
     Endif

     Work1->WKICMS_A  := Work2->WKICMS_A
     nBaseICMS        := DITRANS( ((nSomaICMS_NCM+nASomaICMS_NCM) * Work1->WKRATEIO) +;
                                  (nPSomaICMS_NCM* Work1->WKRATPESO),2)//AWR
	 Work1->WKDESPICM := nBaseICMS
     Work1->WKBASEICMS:= DI154CalcICMS(nBaseICMS , Work1->WKICMS_RED ,Work1->(IF(WKICMS_A!=0,WKICMS_A,WKICMSPC)) , Work2->WKRED_CTE,,,,,,,,,Work1->WK_OPERACA)//ASR - 10/10/2005 - SE WKICMS_A == 0 USAR WKICMSPC
     Work1->WKVL_ICM := DITrans(Work1->WKBASEICMS*(Work1->WKICMS_A/100),2)
     If AvFlags("ICMSFECP_DI_ELETRONICA")
        Work1->WKALFECP := SWZ->WZ_ALFECP
        Work1->WKVLFECP := DITrans(Work1->WKBASEICMS*(SWZ->WZ_ALFECP/100),2)
     EndIf
     If AVFLAGS("FECP_DIFERIMENTO")
        Work1->WKFECPALD := SWZ->WZ_ICMSDIF
        Work1->WKFECPVLD := DITrans(Work1->WKVLFECP * (Work1->WKFECPALD/100),2)
        Work1->WKFECPREC := DITrans(Work1->WKVLFECP - Work1->WKFECPVLD      ,2)
     EndIf

     If lICMS_Dif
        DI154Diferido(.F.)
     EndIf

     Work2->WKICMS+= Work1->WKVL_ICM

     nNBM_ICMS+= Work2->WKICMS

  ENDIF

  Work1->WKPRUNI:= Work1->WKVALMERC / Work1->WKQTDE
  IF nTipoNF # NFE_PRIMEIRA .AND. nTipoNF # NFE_MAE
     nDesp   += Work1->WKOUT_DESP
     nDesp_US+= Work1->WKOUT_D_US
  ENDIF

//  IF lRateioCIF .AND.(nTipoNF = NFE_UNICA .OR. nTipoNF = CUSTO_REAL)
//     nValMerc+=Work1->WKIPIBASE
//  ELSE
     nValMerc+=Work1->WKVALMERC
//  ENDIF

  IF nTipoNF = NFE_COMPLEMEN //.AND. lRateioCIF
     Work1->WKFOB     := 0
     Work1->WKFOB_R   := 0
     Work1->WKFRETE   := 0
     Work1->WKSEGURO  := 0
     Work1->WKCIF     := 0
     Work1->WKIITX    := 0
     Work1->WKIIVAL   := 0
     Work1->WKIPIBASE := 0
     Work1->WKBASEII  := 0
     Work1->WKVLACRES := 0
     Work1->WKVLDEDU  := 0
     Work1->WKIPITX   := 0
     Work1->WKIPIVAL  := 0
     IF !lICMS_NFC
        Work1->WKBASEICMS:=0
        Work1->WKICMS_A  :=0
        Work1->WKVL_ICM  :=0
     ENDIF
  ENDIF
  If SWN->(FieldPos("WN_AFRMM")) # 0
      MDI_CIFPURO    := DITrans( MDI_FOB_R + MDI_FRETE + MDI_SEGURO,2) //LGS-19/07/2016
      Work1->WKAFRMM := DI154CaAFRMM()
   EndIf  
  Work1->(DBSKIP())

ENDDO

// acerta diferenca dos totais da TEC

Work1->(DBGOTO(nRec)) // posiciona no primeiro item da nbm

IF nTipoNF # NFE_COMPLEMEN
   IF nTipoNF # CUSTO_REAL    // Bete 06/12
      IF nValMerc # (Work2->WKCIF + Work2->WKII)
         Work1->WKVALMERC+=(Work2->WKCIF + Work2->WKII) - nValMerc
      ENDIF
   ELSE
      IF nValMerc # (Work2->WKCIF+Work2->WKII+Work2->WKOUTRDESP+Work2->WKRDIFMID)
         Work1->WKVALMERC+=(Work2->WKCIF+Work2->WKII+Work2->WKOUTRDESP+Work2->WKRDIFMID) - DITrans(nValMerc,2)
      ENDIF
      IF lRateioCIF
         nRecNow:=Work2->(RECNO())
         Work2->(DBSKIP())
         IF WorK2->(EOF())
            IF nSumDespI # MDI_OUTR + (nFobItemMidiaRS-M_FOB_MIDRS)
               Work1->WKVALMERC+=  (MDI_OUTR + (nFobItemMidiaRS-M_FOB_MIDRS)) - nSumDespI
            ENDIF
         ENDIF
         Work2->(DBGOTO(nRecNow))
      ENDIF
   ENDIF
ELSEIF nValMerc # (Work2->WKOUTRDESP+Work2->WKRDIFMID)
   Work1->WKVALMERC+=(Work2->WKOUTRDESP+Work2->WKRDIFMID) - DITrans(nValMerc,2)
ENDIF
IF !EMPTY(Work1->WKVALMERC)
   Work1->WKPRUNI:=Work1->WKVALMERC/Work1->WKQTDE
ENDIF

IF nTipoNF # NFE_PRIMEIRA .AND. nTipoNF # NFE_MAE
   IF nDesp # (Work2->WKOUTRDESP+Work2->WKRDIFMID)
      Work1->WKOUT_DESP += (Work2->WKOUTRDESP+Work2->WKRDIFMID)-DITrans(nDesp,2)
   ENDIF
   IF nDesp_US # Work2->WKOUTRD_US+Work2->WKUDIFMID
      Work1->WKOUT_D_US += (Work2->WKOUTRD_US+Work2->WKUDIFMID)-DITrans(nDesp_US,2)
   ENDIF
ENDIF

//IF nTipoNF = NFE_COMPLEMEN .AND. lICMS_NFC .AND. nICMS # Work2->WKICMS //.AND. !lPassouICMS .AND. !lTemPauta
//   Work1->WKVL_ICM+=Work2->WKICMS - DITrans(nICMS,2)
//ENDIF

Work1->(DBSETORDER(1))

RETURN
*----------------------------------------------------------------------------
FUNCTION DI554TestDI(bDifere)
*----------------------------------------------------------------------------
LOCAL cNew_II:=cNew_IPI:=cNew_ICMS:=0; lDifere:=.F.

IF !EMPTY(MDI_II)
   lComDiferenca:=EVAL(bDifere,MDI_II,nNBM_II,"I.I.")
ENDIF

IF !EMPTY(MDI_IPI)
   lDifere:=EVAL(bDifere,MDI_IPI,nNBM_IPI,"I.P.I.")
   If(EMPTY(lComDiferenca),lComDiferenca:=.F.,)
   If(!lComDiferenca,lComDiferenca:=lDifere,)
ENDIF

IF !EMPTY(MDI_ICMS)
   EVAL(bDifere,MDI_ICMS,nNBM_ICMS,"I.C.M.S.")
   If(EMPTY(lComDiferenca),lComDiferenca:=.F.,)
   If(!lComDiferenca,lComDiferenca:=lDifere,)
ENDIF

IF lMV_PIS_EIC
   IF !EMPTY(MDI_PIS)
      EVAL(bDifere,MDI_PIS,nNBM_PIS,"PIS")
      If(EMPTY(lComDiferenca),lComDiferenca:=.F.,)
      If(!lComDiferenca,lComDiferenca:=lDifere,)
   ENDIF
   IF !EMPTY(MDI_COF)
      EVAL(bDifere,MDI_COF,nNBM_COF,"COFINS")
      If(EMPTY(lComDiferenca),lComDiferenca:=.F.,)
      If(!lComDiferenca,lComDiferenca:=lDifere,)
   ENDIF
ENDIF


cNew_II  := nNBM_II
cNew_IPI := nNBM_IPI
cNew_ICMS:= nNBM_ICMS

//IF (cNew_II+cNew_IPI+cNew_ICMS) # 0
   DI554Tela(cNew_II,cNew_IPI,cNew_ICMS)
//ENDIF

RETURN
*----------------------------------------------------------------------------
FUNCTION DI554Tela(TDI_II,TDI_IPI,TDI_ICMS)
*----------------------------------------------------------------------------

nFob_R   := IF(nTipoNF==NFE_COMPLEMEN,0,MDI_FOB_R)
n_Frete  := IF(nTipoNF==NFE_COMPLEMEN,0,MDI_FRETE)
n_Seguro := IF(nTipoNF==NFE_COMPLEMEN,0,MDI_SEGURO)
n_CIF    := IF(nTipoNF==NFE_COMPLEMEN,0,MDI_CIF)
n_IPI    := IF(nTipoNF==NFE_COMPLEMEN,0,TDI_IPI)
n_ICMS   := IF(nTipoNF==NFE_COMPLEMEN .OR. lICMS_NFC,TDI_ICMS,0)   //IF(nTipoNF# NFE_COMPLEMEN .OR. lComIcms,TDI_ICMS,0)
n_II     := IF(nTipoNF==NFE_COMPLEMEN,0,TDI_II)
n_TotNFE := n_CIF+n_II+n_IPI
n_ValM   := n_CIF+n_II
n_VlTota := DITRANS((n_TotNFE+n_ICMS+MDI_OUTR),2)

If oSayTotGe # NIL
   oSayTotGe:Refresh()
Endif

Return

*---------------------------------------------*
Function DI554GerNF(lGerouNFE,bDDIFor,bDDIWhi)
*---------------------------------------------*
LOCAL nRec1:=Work1->(RecNo())
LOCAL nRec2:=Work2->(RecNo())
LOCAL nRec3:=Work3->(RecNo())
LOCAL nOldArea:=Select(), nQtdeNFs:=0, nVlTotNFs:=0, nDespTotNFCs:=0
LOCAL cTec,cExNCM,cExNBM,nFob,nDespUS,nFob_R,nCIF_Moe, aAntLido:={}
LOCAL cTpNrNfs := EasyGParam("MV_TPNRNFS",,"1")
LOCAL i  //NCF - 06/10/2011
LOCAL aOrdForm:= {} //TRP - 28/12/11 - Inclusão de array para guardar a ordem do formulário antes do while.
PRIVATE cOperacao,cACModal,cCFO, lSair:=.F.
PRIVATE cForn := SPACE(AVSX3("W7_FORN",3)) //SO.:0026 OS.:0222/02 FCD
PRIVATE cNumero, cSerie, nItem:= ntx_Ufesp := 0
PRIVATE nQtde    := nPesoB   := 0 ,  nEspecie := nMarca  := nNumero := SPACE(12) ,nTrans := SPACE(6)
PRIVATE cChvQuebra:= "" // Jonato, 31-01-2001
PRIVATE nWK1Ordem :=5 //Variavel usada para trocar a ordem da Work no Rdmake
PRIVATE nWK2Ordem :=1 //Variavel usada para trocar a ordem da Work no Rdmake
PRIVATE lMV_UNIDCOM_2:=EasyGParam("MV_UNIDCOM",,2) = 2
Private cLoja

PRIVATE nNFLin := 0  //NCF - 19/10/2010 - Variáveis para apurar a linha do item na DI Eletronica
PRIVATE aNFLin := {}
PRIVATE lDespNFC_W := .F.
PRIVATE lDespNFC_X := .F.
Private cNumComp, cSerieComp
Private nRecItNFC //NCF - 06/10/2011
Private aRecItNFCz := {}

If EICLoja()
   cLoja := Space(AvSx3("W7_FORLOJ", 3))
EndIf

dDtNFE:=IF(EMPTY(dDtNFE),dDataBase,dDtNFE)

If lComDiferenca .AND. nTipoNF <> NFE_COMPLEMEN   //TRP - 12/01/2012 - O sistema não deve apresentar mensagem de divergência de impostos na Nota Complementar.
   Help("",1,"AVG0000805")
Endif

SW7->(DBSEEK(xFilial("SW7")+SW6->W6_HAWB))
SA2->(DBSEEK(xFilial("SA2")+SW7->W7_FORN+EICRetLoja("SW7", "W7_FORLOJ")))
If nTipoNF == NFE_COMPLEMEN .AND. SW6->W6_IMPCO == "1"  // GFP - 21/01/2015 - Geração de NF Complementar para processos Conta e Ordem deve ser apresentado Fornecedor do Importador.
   IF !Empty(SYT->YT_FORN) .And. !Empty(SYT->YT_LOJA)   //LRS - 8/10/2015 - Verifica se o Fornecedor do processo Complementar do conta e ordem está preenchido, se não pega do P.O.
	  SA2->(DbSeek(xFilial("SA2")+SYT->YT_FORN+EICRetLoja("SYT", "YT_LOJA")))
   Else
	  SA2->(DbSeek(xFilial("SA2")+SW2->W2_FORN+EICRetLoja("SW2", "W2_FORLOJ")))
   EndIF
EndIf
IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,'IniciaVariavel'),)

IF lSair
   DbSelectArea(nOldArea)
   Return .T.
ENDIF
//NCF - 11/11/2010 - Validação para não permitir geração da NFC com itens que possuam valor zerado
IF nTipoNF == NFE_COMPLEMEN
   Work1->(DBGOTOP())
   nRecMaior  := nVlrMaior := 0
   aRecItNFCz := {}
   WHILE Work1->(!EOF())
      IF Work1->WKOUT_DESP == 0
         lDespNFC_W := .T.
         aAdd( aRecItNFCz,Work1->(Recno()) )
      ELSEIF Work1->WKOUT_DESP < 0 .And. ( EasyGParam("MV_EASY",,"N") == "S" .Or. !EasyGParam("MV_EIC0009",,.F.) ) //NCF - 20/05/2011 - Permitir ou não despesas negativas na NF Complementar
         lDespNFC_X := .T.
      ENDIF
      Work1->(DbSkip())
   ENDDO
   IF lDespNFC_W
      If MsgYesNo(STR0328+STR0329)
         //NCF - 06/10/2011 - Posicionar nas despesas menores para adicionar valor mínimo abatido da maior despesa
         For i := 1 To Len(aRecItNFCz)
            Work1->(dbGoto(aRecItNFCz[i]))
            Work1->WKOUT_DESP := 0.01
            Work1->WKVALMERC  := 0.01
            nRecItNFC := MaiorItNFC()     //NCF - 06/10/2011 - Buscar o item que possuir maior rateio
            Work1->(dbGoto(nRecItNFC))
            If Work1->WKOUT_DESP > 0.01
               Work1->WKOUT_DESP -= 0.01
            EndIf
            If Work1->WKVALMERC > 0.01
               Work1->WKVALMERC  -= 0.01
            EndIf
         Next i
      Else
         lGerouNFE := .F.
         Return .F.
      EndIf
   ENDIF
   IF lDespNFC_X
      MSGALERT(STR0330+STR0331+STR0332)
      lGerouNFE := .F.
      Return .F.
   ENDIF

ENDIF

//TDF - 17/11/2010 Revisão dos conceitos de utilização de formulário própio.
If nTipoNF == NF_TRANSFERENCIA
    cFormPro      := "N"
Else    
    If lMV_EASY_SIM .AND. nTipoNF # CUSTO_REAL .AND. !lNFAutomatica //LRS - 26/04/2018 - Se For NFT nao perguntar
        If MSGYESNO(STR0309,STR0032) //"Utiliza Formulario Proprio?"
            cFormPro      := "S"
        Else
            cFormPro      := "N"
        Endif
    Endif
EndIf

IF lNFAutomatica .AND. nTipoNF # CUSTO_REAL

   ProcRegua(Work1->(LASTREC()))

   Work2->(DBSETORDER(nWK2Ordem))//1
   Work1->(DBSETORDER(nWK1Ordem))//5
   Work1->(DBGOTOP())
   nItem:=0
   cForn:=""
   cLoja:=""
   cCFO :=""
   cACModal:=""
   cOperacao:=""

   cNumComp   := ""
   cSerieComp := ""

   cAdicAnt := ""
   nAdicao  := 0

   DO WHILE !Work1->(EOF())
      //ACB - 03/3/2011 - TRatamento de compração de pesos
      If !ComparaPeso (,Work1->WKPESOL,"D1_PESO",.T.,)
         Return .F.
      EndIf

      IncProc(STR0150) //"Gerando Nota Fiscal"

      //FDR - 31/10/11
      If Work1->WKADICAO <> cAdicAnt
         nAdicao ++
         cAdicAnt := Work1->WKADICAO
      EndIf

      IF DI554Quebrou()
         cNumero:=WORK1->WK_NFE
         cSerie :=WORK1->WK_SE_NFE

         IF AvFlags("EIC_EAI")//AWF - 16/06/2014
            cNumero:=GetSXENum("SF1","F1_DOC")
            ConfirmSx8()
            cSerie :="_"
         ENDIF

         IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,'NOVO_NUMERO_NF'),)

         IF EMPTY(cNumero)
            //TDF - 28/02/11 - Alteração para que o botão "Cancelar" funcione corretamente
            DO WHILE .T.
               IF !SX5NumNota(.F.,cTpNrNfs)
                  RETURN .F.
               ELSE
                  EXIT
               ENDIF
            ENDDO

            If cTpNrNfs <> "3"

               cNumero := NxTSx5Nota(Transform(cSerie,AvSX3("F1_SERIE",AV_PICTURE)),.T.,cTpNrNfs)
               cSerie  := SerieNfId(,4,"WN_SERIE",dDtNFE,cMv_ESPEIC,cSerie)//AAF 18/02/2015 - Como as funções SX5NumNota e NxTSx5Nota continuam retornando serie com 3 digitos, altera a variaval para a serie nova para verificação em seeks

               //ASR 17/02/2006 - INICIO - VALIDACAO DO NUMERO DA NOTA FISCAL - NUMERACAO AUTOMATICA
               nOrderSF1 := SF1->(IndexOrd())
               SF1->(DBSetOrder(1))
               If EasyGParam("MV_NFEHAWB",,.T.)//ASR 22/02/2006
                  If SF1->(DBSeek(xFilial("SF1")+cNumero+cSerie))
                     Do While SF1->(!EOF()) .AND. SF1->F1_FILIAL == xFilial("SF1") .AND. SF1->F1_DOC == cNumero .AND. SF1->F1_SERIE == cSerie
                        If !EMPTY(SF1->F1_HAWB)
                           Do While SF1->(DBSeek(xFilial("SF1")+cNumero+cSerie))
                              cNumero := NxTSx5Nota(Transform(cSerie,AvSX3("F1_SERIE",AV_PICTURE)),.T.,cTpNrNfs)
                              cSerie  := SerieNfId(,4,"WN_SERIE",dDtNFE,cMv_ESPEIC,cSerie)
                           EndDo
                           Exit
                        EndIf
                        SF1->(DBSKIP())
                     EndDo
                  EndIf
               Else//ASR 22/02/2006 - Inicio
                  If SF1->(DbSeek(xFilial("SF1")+cNumero+cSerie+Work1->WKFORN+Work1->WKLOJA))
                     Do While SF1->(DBSeek(xFilial("SF1")+cNumero+cSerie+Work1->WKFORN+Work1->WKLOJA))
                        cNumero := NxTSx5Nota(Transform(cSerie,AvSX3("F1_SERIE",AV_PICTURE)),.T.,cTpNrNfs)
                        cSerie  := SerieNfId(,4,"WN_SERIE",dDtNFE,cMv_ESPEIC,cSerie)
                     EndDo
                  Endif
               EndIf//ASR 22/02/2006 - Fim
               SF1->(DBSetOrder(nOrderSF1))
               //ASR 17/02/2006 - FIM

            Else //cTpNrNfs == "3"
               //ER - 10/04/2008
               IF nTipoNF # NF_TRANSFERENCIA //LRS - 26/04/2018 - Nao mudar o numero digitado pelo cliente se for nft
                  //lMudouNum := .T.
                  cNumero := Ma461NumNF(.T.,Transform(cSerie,AvSX3("F1_SERIE",AV_PICTURE)),cNumero)
               Else
                  lMudouNum := .F.
	              cNumero := Work1->WK_NFE
               EndIF
            EndIf
         ENDIF

         nItem:=0
         cForn    := Work1->WKFORN
         If EICLoja()
            cLoja := Work1->WKLOJA
         EndIF
         cCFO     := Work1->WK_CFO
         cOperacao:= Work1->WK_OPERACA
         cACModal := Work1->WKACMODAL
      ENDIF
      nItem++

      //TDF- 22/12/2010 - VERIFICA SE JÁ ESTA PREENCHIDO ANTES DE GRAVAR A NUMERAÇÃO DA NOTA
      IF EMPTY(Work1->WK_NFE)
         Work1->WK_NFE   :=cNumero
      ENDIF

      IF EMPTY(Work1->WK_SE_NFE)
         Work1->WK_SE_NFE:=cSerie
      ENDIF

      IF EMPTY(Work1->WK_DT_NFE)
         Work1->WK_DT_NFE:=dDtNFE
      ENDIF
      //*TDF*//

      IF Work3->(DBSEEK(Work1->(RECNO())))

         DO WHILE !Work3->(EOF()) .AND. Work1->(RECNO()) == Work3->WKRECNO

            //TRP - 14/02/12 - Alteração para que, aceite mais de uma numeração de nota fiscal no Recebimento de Importação.
            //Só alterar o número da nota caso o mesmo não esteja preenchido para gravar corretamente o SWW
            IF EMPTY(Work3->WK_NF_COMP)
               Work3->WK_NF_COMP:=cNumero
            ENDIF
            IF EMPTY(Work3->WK_SE_NFC)
               Work3->WK_SE_NFC :=cSerie
            ENDIF
            IF EMPTY(Work3->WK_DT_NFC)
               Work3->WK_DT_NFC :=dDtNFE
            ENDIF

            Work3->(DBSKIP())

         ENDDO

      ENDIF

     Work1->(DBSKIP())

   ENDDO

   If lRecalcIcms
      SWD->(DbSetOrder(1))
      If SWD->(DBSEEK(xFilial("SWD")+SW6->W6_HAWB))
         DO WHILE SWD->(!EOF())              .AND.;
            SWD->WD_FILIAL==xFilial("SWD").AND.;
            SWD->WD_HAWB  == SW6->W6_HAWB
            If SWD->WD_DESPESA = "203"
               SWD->(RecLock("SWD",.F.))
               SWD->WD_VALOR_R := nNewVlIcm     //TRP - 13/03/2010 - Acerta o valor da Despesa 203-ICMS no Desembaraço
               SWD->(MsUnlock())
            Endif
            SWD->(DbSkip())
         ENDDO
      Endif
   Endif


ELSEIF nTipoNF = CUSTO_REAL

   ProcRegua(Work1->(LASTREC()))

   Work2->(DBSETORDER(nWK2Ordem))//1
   Work1->(DBSETORDER(nWK1Ordem))//5
   Work1->(DBGOTOP())
   nItem:=EasyGParam("MV_NRCUSTO")
   nItem++
   SetMV("MV_NRCUSTO",nItem)
   cNumero:=STRZERO(nItem,6,0)

   DO WHILE !Work1->(EOF())

      IncProc(STR0150) //"Gerando Nota Fiscal"

      IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,'QUEBRA_CUSTO'),)

      Work1->WK_NFE   :=cNumero
      Work1->WK_DT_NFE:=dDtNFE

      IF Work3->(DBSEEK(Work1->(RECNO())))

         DO WHILE !Work3->(EOF()) .AND. Work1->(RECNO()) == Work3->WKRECNO

            Work3->WK_NF_COMP:=cNumero
            Work3->WK_DT_NFC :=dDtNFE

            Work3->(DBSKIP())

         ENDDO

      ENDIF

     Work1->(DBSKIP())

   ENDDO

ELSEIF !lNFAutomatica .AND. nTipoNF # CUSTO_REAL
   aNF1:={}
   aNF2:={}
   Work1->(DBSETORDER(2))
   Work1->(DBGOTOP())
   cForn := Work1->WKFORN
   If EICLoja()
      cLoja := WORK1->WKLOJA
   EndIf
   DO WHILE !Work1->(EOF())
      IF EMPTY(Work1->WK_NFE)
         Help("",1,"AVG0000806")
//       MSGINFO("Existem Notas Fiscais nao informadas",0022)
         RETURN .F.
      ENDIF
      IF ASCAN(aNF1,{|N| N[1]==Work1->WK_NFE+Work1->WK_SE_NFE .AND. N[2]==Work1->WKFORN .And. (!EICLoja() .Or. N[3] == WORK1->WKLOJA)} ) == 0
         AADD (aNF1,{ Work1->WK_NFE+Work1->WK_SE_NFE,Work1->WKFORN, WORK1->WKLOJA })
         IF ASCAN(aNF2,{|F| F[1]==aNF1[LEN(aNF1),1] }) == 0
            AADD (aNF2,{ aNF1[LEN(aNF1),1] })
         ELSE
            Help("",1,"AVG0000807")
//          MSGINFO("Existem Fornecedores com os mesmo numeros de N.F.'s.",0022)
            RETURN .F.
         ENDIF
      ENDIF
      
      If lMV_EASY_SIM .And. cFormPro == "S" //TRP - 28/12/11 - Verifica se está integrado com Compras e se selecionou a utilização de formulário próprio
         aOrdForm:=  SaveOrd({"SF1"}) //TRP - 28/12/11 - Salva a ordem da tabela
         SF1->(DBSetOrder(1))
         If SF1->(DbSEEK(xFilial("SF1")+Work1->WK_NFE+Work1->WK_SE_NFE+Work1->WKFORN+WORK1->WKLOJA))
            MsgInfo(STR0353+; //Já existe Nota Fiscal no Módulo de Compras com as seguintes informações:
                    CHR(13)+CHR(10)+STR0354+Work1->WK_NFE+;
                    CHR(13)+CHR(10)+STR0355+Transform(Work1->WK_SE_NFE,AvSX3("F1_SERIE",AV_PICTURE))+;
                    CHR(13)+CHR(10)+STR0356+Work1->WKFORN+;
                    CHR(13)+CHR(10)+STR0357+WORK1->WKLOJA)
            Work1->(DbGotop())
            Return .F.
         Endif
         RestOrd(aOrdForm,.T.)
      Endif            
      
      Work1->(DBSKIP())
   ENDDO

//** AAF 11/08/08 - Tratamento para validação da Nota Fiscal não automática.

   ProcRegua(Work1->(LASTREC()))

   Work2->(DBSETORDER(nWK2Ordem))//1
   Work1->(DBSETORDER(nWK1Ordem))//5
   Work1->(DBGOTOP())
   cNFE      := ""
   cSerieNFE := ""
   nItem:=0
   cForn:=""
   cLoja := ""  // GFP - 03/07/2013
   cCFO :=""
   cACModal:=""
   cOperacao :=""

   DO WHILE !Work1->(EOF())

      IncProc(STR0150) //"Gerando Nota Fiscal"
      nRecProx := 0

      IF Work1->(WK_NFE+WK_SE_NFE) <> cNFE+cSerieNFE

         cNFE      := Work1->WK_NFE
         cSerieNFE := Work1->WK_SE_NFE

         If cTpNrNfs == "1" .OR. cTpNrNfs == "2"
            //Não há função de validação da nota não automática na Microsiga para numeração SX5 ou SXE.
            cNumero := Work1->WK_NFE
         ElseIf cTpNrNfs == "3"
            //ER - 10/04/2008
            IF nTipoNF # NF_TRANSFERENCIA //LRS - 26/04/2018 - Nao mudar o numero digitado pelo cliente se for nft
               //lMudouNum := .T.
               cNumero := Ma461NumNF(.T.,Transform(Work1->WK_SE_NFE,AvSX3("F1_SERIE",AV_PICTURE)),Work1->WK_NFE)
            Else
               lMudouNum := .F.
	           cNumero := Work1->WK_NFE
            EndIF
         ENDIF

      ENDIF

      If Work1->WK_NFE <> cNumero
         Work1->(dbSkip())
         If Work1->(EoF())
            nRecProx := 0
         Else
    	      nRecProx := Work1->(RecNo())
         EndIf

         Work1->(dbSkip(-1))

         Work1->WK_NFE := cNumero
      EndIf

      If nRecProx > 0
         Work1->(dbGoTo(nRecProx))
      Else
         Work1->(DBSKIP())
      EndIf
   ENDDO

   If lRecalcIcms
      SWD->(DbSetOrder(1))
      If SWD->(DBSEEK(xFilial("SWD")+SW6->W6_HAWB))
         DO WHILE SWD->(!EOF())              .AND.;
            SWD->WD_FILIAL==xFilial("SWD").AND.;
            SWD->WD_HAWB  == SW6->W6_HAWB
            If SWD->WD_DESPESA = "203"
               SWD->(RecLock("SWD",.F.))
               SWD->WD_VALOR_R := nNewVlIcm     //TRP - 13/03/2010 - Acerta o valor da Despesa 203-ICMS no Desembaraço
               SWD->(MsUnlock())
            Endif
            SWD->(DbSkip())
         ENDDO
      Endif
   Endif

//**
ENDIF

ProcRegua(Work1->(LASTREC())+Work1->(LASTREC())+Work3->(LastRec()) )

Work2->(DBSETORDER(1))
Work1->(DBSETORDER(4))
Work1->(DBGOTOP())

cOperacao:=Work1->WK_OPERACA
cExNCM:=Work1->WKEX_NCM
cExNBM:=Work1->WKEX_NBM
cTec  :=Work1->WKTEC
nNFE  :=Work1->WK_NFE
nSerie:=Work1->WK_SE_NFE
dDtNFE:=Work1->WK_DT_NFE
nPesol:=nFob:=nFrete:=nSeguro:=nCIF:=nII:=nIPI:=nICMS:=nDespesa:=nDespUS:=nDespesaICM:=nPesoB:=0//FSM - 02/09/2011 - Peso Bruto Unitario //ASK 16/01/2008
nFob_R:=nCIF_Moe:=nItem:=nBaseIPI:=nBaseICMS:=nValor:=nItem:=nContItem:=0
lGerouNFE :=.F.
cNotaGrupo:=Work1->WK_NFE+Work1->WK_SE_NFE
nNFEAux  :=""
nSerieAux:=""
aCab  :={}//Para gravacao da Microsiga
aItens:={}//Para gravacao da Microsiga
lMSErroAuto := .F.
lMSHelpAuto := .F. // para mostrar os erros na tela


SB1->(DBSETORDER(1))
SB1->(DbSeek(xFilial("SB1")+EasyGParam("MV_PRODIMP")))

aEnv_NFS:={}

Begin Transaction

Begin SEQUENCE

DO WHILE If(nTipoNF # CUSTO_REAL, !Work1->(EOF()) , .T. )

   IncProc(STR0151) //"Gravando Nota Fiscal"

   If nTipoNF # CUSTO_REAL

      IF DI554CapQuebrou()//nNFE # Work1->WK_NFE  .OR. nSerie # Work1->WK_SE_NFE

         IF !DI554CapNF()
            EXIT
         ENDIF
         aItens:={}//Limpa os itens da tabela para nao acumular para a proxima nota
         nQtdeNFs +=1
         nNFE  :=Work1->WK_NFE
         nSerie:=Work1->WK_SE_NFE
         dDtNFE:=Work1->WK_DT_NFE
         nPesol:=nValor:=nFrete:=nSeguro:=nCIF:=nII:=nIPI:=nICMS:=nDespesa:=nPesoB:=0//FSM - 02/09/2011 - Peso Bruto Unitario

      ENDIF

	   //AAF 07/11/2016
      IF (nNFLin := ASCAN(aNFLin, {|x|x[1]==Work1->(WK_NFE+WK_SE_NFE)}) ) == 0
         WORK1->WKLINHA := 1
         AADD(aNFLin, {Work1->(WK_NFE+WK_SE_NFE), 1})
      ELSE
         aNFLin[nNFLin,2] += 1
         WORK1->WKLINHA := aNFLin[nNFLin,2]
      ENDIF

      // O Seek do Work2 e do SA2 esta antes do Skip do Work1 para incluir os dados, na Capa, do Registro certo do Work2 e do SA2
      Work2->(DBSEEK(Work1->WKADICAO+Work1->WK_CFO+Work1->WK_OPERACA+Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM))
      SA2->(DBSEEK(xFilial("SA2")+Work1->WKFORN+Work1->WKLOJA))//AWR 21/03/2001
      If nTipoNF == NFE_COMPLEMEN .AND. SW6->W6_IMPCO == "1"  // GFP - 21/01/2015 - Geração de NF Complementar para processos Conta e Ordem deve ser apresentado Fornecedor do Importador.
         IF !Empty(SYT->YT_FORN) .And. !Empty(SYT->YT_LOJA)   //LRS - 8/10/2015 - Verifica se o Fornecedor do processo Complementar do conta e ordem está preenchido, se não pega do P.O.
	        SA2->(DbSeek(xFilial("SA2")+SYT->YT_FORN+EICRetLoja("SYT", "YT_LOJA")))
         Else
	        SA2->(DbSeek(xFilial("SA2")+SW2->W2_FORN+EICRetLoja("SW2", "W2_FORLOJ")))
         EndIF
      EndIf
	  SC1->( DbSetOrder(1) ) // GCC - 23/07/2013 - Restauração do Indice, pois no MATA140 (Funçào DI154CapNF()) onde o mesmo é desposicionado.

      IF lMV_EASY_SIM

         SB1->(DBSEEK(xFilial("SB1")+Work1->WKCOD_I))
         cLOCAL:=SB1->B1_LOCPAD
         IF PosO1_It_Solic(Work1->WK_CC,Work1->WKSI_NUM,Work1->WKCOD_I,Work1->WK_REG,0) //MCF - 18/05/2016 - Alteração da do W1_SEQ.
            SW0->(DBSEEK(xFilial("SW0")+SW1->W1_CC+SW1->W1_SI_NUM))
            SC1->(DBSETORDER(1))
            IF SC1->(DBSEEK(xFilial("SC1")+SW0->W0_C1_NUM+SW1->W1_POSICAO)) .AND.;
               !EMPTY(SC1->C1_LOCAL)
               cLOCAL := SC1->C1_LOCAL
            ENDIF
         ENDIF

         nQTSEGUM:=0
         nQUANT  :=Work1->WKQTDE
         cSEGUM  :=SPACE(LEN(Work1->WKUNI))
         cUNI    :=Work1->WKUNI
         aSegUM:=AV_Seg_Uni(Work1->WK_CC,Work1->WKSI_NUM,Work1->WKCOD_I,Work1->WK_REG,Work1->WKQTDE)
         IF !EMPTY(aSegUM[2])
            If lMV_UNIDCOM_2
               nQTSEGUM:=Work1->WKQTDE
               nQUANT  :=aSegUM[2]
            Else
               nQTSEGUM:=aSegUM[2]
            Endif
            If SW0->(DBSeek(xFilial("SW0")+Work1->WK_CC+Work1->WKSI_NUM))
               IF SC1->(DBSEEK(xFilial("SC1")+SW0->W0_C1_NUM+SW1->W1_POSICAO))//SW1 ja esta posicionado
                  cUNI  :=SC1->C1_UM
                  cSEGUM:=SC1->C1_SEGUM
                  // RA - 31/10/03 - O.S. 1107/03 - Inicio
                  If Empty(SC1->C1_SEGUM) .And. ( SC1->C1_QTSEGUM == 0 .Or. SC1->C1_QUANT == SC1->C1_QTSEGUM )
                     cSEGUM := SC1->C1_UM
                  EndIf
                  // RA - 31/10/03 - O.S. 1107/03 - Final
               Endif
            Endif
         Else
			// GCC - 10/12/2013 - Tratamento para carregar de forma correta os campo de quantidade e unidade quando não existir a SC
			If EasyGParam("MV_UNIDCOM",,2) == 2 .And. !Empty(SB1->B1_CONV) .And. !Empty(SB1->B1_SEGUM) //FSY - 26/02/2014 - Adicionado condição que verifica se os campos B1_CONV e B1_SEGUM estão preenchidos
				cUNI    := SB1->B1_UM
				cSEGUM  := SB1->B1_SEGUM
				nQTSEGUM:= Work1->WKQTDE
				cTpConv := SB1->B1_TIPCONV
				nConv	:= SB1->B1_CONV
				If !Empty(cTpConv)
				   If cTpConv == "M"
				      nQUANT := Work1->WKQTDE * nConv//FSY - 06/03/2014 - Realizada correção do calculo
				   Else
				      nQUANT := Work1->WKQTDE / nConv//FSY - 06/03/2014 - Realizada correção do calculo
				   EndIf
				EndIf
			EndIf
         EndIf

         If nTipoNF==NFE_COMPLEMEN
            nQTSEGUM:=0
            cSEGUM  :=SPACE(LEN(Work1->WKUNI))
            cUNI    :=SPACE(LEN(Work1->WKUNI))
         ENDIF

         DI554GrvSD1(cLOCAL,nQTSEGUM,nQUANT,cUNI,cSEGUM,Work1->WKBASEII,nTipoNF)//AWR 27/08/2002
                                        // SVG - 08/10/2010 - Despesa base de imposto inserida também na nota mãe
         IF nTipoNF==NFE_PRIMEIRA .Or. (lMV_NF_MAE .And. (nTipoNF == NFE_MAE .Or.  (nTipoNF == NFE_FILHA .And. EasyGParam("MV_NFFILHA",,"0") $ "1,3"))) //LGS-05/05/14 //ASR 07/11/2005 - GRAVAÇÃO DA SWN
            nDespesa += Work1->WKDESPICM
         ELSEIF nTipoNF==NFE_UNICA
            nDespesa += ( Work1->WKDESPICM + Work1->WKOUT_DESP )
         ENDIF

         //EicAtuSB2(1) - //NCF - 02/12/2019 - Nopado

      ELSE
         nDespesa    += Work1->WKOUT_DESP
         nDespesaICM += Work1->WKDESPICM
      ENDIF

      //FSM - 02/09/2011 - Peso Bruto Unitario
      If lPesoBruto
         nPesoB += Work1->WKPESOBR
      EndIf

      nPesol  +=Work1->WKPESOL
      nValor  +=Work1->WKFOB_R
      nFrete  +=Work1->WKFRETE
      nSeguro +=Work1->WKSEGURO
      nCIF    +=Work1->WKBASEII//Work1->WKCIF
      nII     +=Work1->WKIIVAL
      nIPI    +=Work1->WKIPIVAL
      nICMS   +=Work1->WKVL_ICM
      /*                                             //NCF - 18/10/2010 - (Nopado) - Duplica Valor das despesas base de ICMS quando utiliza DI Eletronica
      IF nTipoNF==NFE_PRIMEIRA .OR. nTipoNF==NFE_MAE
	      nDespesa+=Work1->WKDESPICM
	  ELSEIF nTipoNF==NFE_UNICA
	      nDespesa+=Work1->WKOUT_DESP+Work1->WKDESPICM
	  ENDIF
	  */
      nVlTotNFs   +=(Work1->WKIPIBASE+Work1->WKIPIVAL)

      //** AAF 10/07/08 - Adicionado valor do PIS, COFINS e ICMS.
      IF lMV_PIS_EIC
         nVlTotNFs   += Work1->WKVLRPIS+Work1->WKVLRCOF+Work1->WKVL_ICM+nDespesa
      EndIf
      //**

      nDespTotNFCs+=Work1->WKOUT_DESP

   ELSE

   IF nNFE   # Work1->WK_NFE  .OR. nSerie    # Work1->WK_SE_NFE .OR.;
      cTec   # Work1->WKTEC   .OR. cOperacao # Work1->WK_OPERACA.OR.;
      cExNCM # Work1->WKEX_NCM.OR. cExNBM    # Work1->WKEX_NBM

      Work1->(DbSkip(-1))//Para gravar os dados do registro anterior
      Work2->(DBSEEK(Work1->WKADICAO+Work1->WK_CFO+Work1->WK_OPERACA+Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM))

         EI3->(RecLock("EI3",.T.))
         EI3->EI3_FILIAL := xFilial("EI3")
         EI3->EI3_TIPO_N := STR(nTipoNF,1,0)
         EI3->EI3_HAWB   := SW6->W6_HAWB
         EI3->EI3_ICMS_A := Work2->WKICMS_A
         EI3->EI3_TEC    := Work2->WKTEC
         EI3->EI3_EX_NCM := Work2->WKEX_NCM
         EI3->EI3_EX_NBM := Work2->WKEX_NBM
         EI3->EI3_PESOL  := nPesol //Work2->WKPESOL
         EI3->EI3_FOB    := nFob   //Work1->WKFOB
         EI3->EI3_FOB_R  := nFob_R //Work2->WKFOB_R
         EI3->EI3_FRETE  := nFrete //Work2->WKFRETE
         EI3->EI3_CIF_MO := nCIF_Moe//Work2->WKCIF_MOE
         EI3->EI3_SEGURO := nSeguro//Work2->WKSEGURO
         EI3->EI3_CIF    := nCIF   //Work2->WKCIF
         EI3->EI3_II     := nII    //Work2->WKII
         EI3->EI3_IPI    := nIPI   //Work2->WKIPI
         EI3->EI3_ICMS   := nICMS  //Work2->WKICMS
         EI3->EI3_OUTRDE := nDespesa//Work2->WKOUTRDESP
         EI3->EI3_OUTR_U := nDespUS//Work2->WKOUTRD_US
         EI3->EI3_II_A   := Work2->WKII_A
         EI3->EI3_CFO    := Work2->WK_CFO
         EI3->EI3_OPERAC := Work2->WK_OPERACA
         EI3->EI3_NF_COM := Work1->WK_NFE
         //EI3->EI3_SE_NFC := Work1->WK_SE_NFE
		 SerieNfId("EI3",1,"EI3_SE_NFC",,,,Work1->WK_SE_NFE)

         EI3->EI3_DT_NFC := Work1->WK_DT_NFE
         EI3->EI3_IPI_A  := Work2->WKIPI_A
         EI3->(MsUnlock())


      IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"GRAVA_SD1_EI3"),)

      Work1->(DbSkip())

      IF Work1->(Eof())
         EXIT
      ENDIF

      cOperacao:=Work1->WK_OPERACA
      cExNCM:=Work1->WKEX_NCM
      cExNBM:=Work1->WKEX_NBM
      cTec  :=Work1->WKTEC
      nNFE  :=Work1->WK_NFE
      nSerie:=Work1->WK_SE_NFE
      dDtNFE:=Work1->WK_DT_NFE
      nPesol:=nFob:=nFrete:=nSeguro:=nCIF:=nII:=nIPI:=nICMS:=nDespesa:=nDespUS:=nFob_R:=nCIF_Moe:=nBaseIPI:=nBaseICMS:=nPesoB:=0 //FSM - 02/09/2011 - Peso Bruto Unitario

   ENDIF

   IF lExiste_Midia .AND. nTipoNF = CUSTO_REAL .AND. !EMPTY(Work1->WKFOBR_ORI)
      nFob  +=Work1->WKFOB_ORI
      nFob_R+=Work1->WKFOBR_ORI
   ELSE
      nFob  +=Work1->WKFOB
      nFob_R+=Work1->WKFOB_R
   ENDIF

   //FSM - 02/09/2011 - Peso Bruto Unitario
   If lPesoBruto
      nPesoB += Work1->WKPESOBR
   EndIf

   nPesol  +=Work1->WKPESOL
   nFrete  +=Work1->WKFRETE
   nSeguro +=Work1->WKSEGURO
   nCIF    +=Work1->WKBASEII//Work1->WKCIF
   nII     +=Work1->WKIIVAL
   nIPI    +=Work1->WKIPIVAL
   nICMS   +=Work1->WKVL_ICM
   nDespesa+=Work1->WKOUT_DESP
   nDespUS +=Work1->WKOUT_D_US
   nBaseIPI+=Work1->WKIPIBASE
   nBaseICMS+=Work1->WKBASEICMS

   IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"ACUMULA_SD1_EI3"),)

   ENDIF

   Work1->(DbSkip())

ENDDO

IF !lMSErroAuto .AND. nTipoNF # 4
   DI554CapNF()
ENDIF

IF lMSErroAuto
// MostraErro()
   BREAK
ENDIF

nWK1Ordem :=2 //Variavel usada para trocar a ordem da Work no Rdmake

IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,'IniciaVar2'),)

SW0->(DBSETORDER(1))

DBSELECTAREA("Work1")

Work1->(DBSETORDER(nWK1Ordem))
Work1->(DBGOTOP())
nNFE  :=Work1->WK_NFE
nSerie:=Work1->WK_SE_NFE
dDtNFE:=Work1->WK_DT_NFE
nPesol:=nValor:=nFrete:=nSeguro:=nCIF:=nII:=nIPI:=nICMS:=nDespesa:=nItem:=nContItem:=nPesoB:=0 //FSM - 02/09/2011 - Peso Bruto Unitario
nNFEAux  :=""
nSerieAux:=""

If lIntDraw .and. cAntImp == "1"
   SW8->(dbSetOrder(6))
   ED4->(dbSetOrder(2))
EndIf

SB1->(DBSETORDER(1))
SB1->(DbSeek(xFilial("SB1")+EasyGParam("MV_PRODIMP")))

DO WHILE ! Work1->(EOF())

   IncProc(STR0151) //"Gravando Nota Fiscal"

   If nTipoNF # CUSTO_REAL

      lLoop := .F.
      IF(EasyEntryPoint("EICDI554"),EXECBLOCK("EICDI554",.F.,.F.,"ANTES_GRAVA_SWN"),) //JWJ - 07/11/2005
      IF lLoop
      	Work1->(DBSKIP())
      	Loop
      ENDIF

      SWN->(RecLock("SWN",.T.))
      SWN->WN_FILIAL   := xFilial("SWN")
      SWN->WN_TIPO_NF  := STR(nTipoNF,1,0)
      SWN->WN_HAWB     := SW6->W6_HAWB
      SWN->WN_DOC      := Work1->WK_NFE
      //SWN->WN_SERIE    := Work1->WK_SE_NFE
	  SerieNfId("SWN",1,"WN_SERIE",,,,Work1->WK_SE_NFE)

      SWN->WN_TEC      := Work1->WKTEC
      SWN->WN_EX_NCM   := Work1->WKEX_NCM
      SWN->WN_EX_NBM   := Work1->WKEX_NBM
      SWN->WN_PO_EIC   := Work1->WKPO_NUM
      SWN->WN_PO_NUM   := Work1->WKPO_SIGA
      SWN->WN_BASEICM  := Work1->WKBASEICMS
      SWN->WN_ITEM     := Work1->WKPOSICAO

     //TDF - 30/01/2012
      IF Work1->(fieldpos("WKPOSSIGA")) > 0 .AND. SWN->(FIELDPOS("WN_ITEM_DA")) > 0
         SWN->WN_ITEM_DA  := If(!Empty(Work1->WKPOSSIGA),Work1->WKPOSSIGA,Work1->WKPOSICAO)
      EndIf

      SWN->WN_QUANT    := If(nTipoNF==NFE_COMPLEMEN,0,Work1->WKQTDE)
      SWN->WN_PRECO    := Work1->WKPRECO
      SWN->WN_UNI      := Work1->WKUNI
      SB1->(DBSEEK(xFilial("SB1")+ Work1->WKCOD_I))
      SWN->WN_LOCAL := SB1->B1_LOCPAD

      /*
      IF nTipoNF # COMPLEMENTO_VL //LGS-18/04/2016
         //JWJ 18/05/2006: Controle para a numeração dos itens (WN_LINHA) POR NOTA
	      IF (nNFLin := ASCAN(aNFLin, {|x|x[1]==Work1->(WK_NFE+WK_SE_NFE)}) ) == 0
	         SWN->WN_LINHA := 1
	         AADD(aNFLin, {Work1->(WK_NFE+WK_SE_NFE), 1})
	      ELSE
	         aNFLin[nNFLin,2] += 1
	         SWN->WN_LINHA := aNFLin[nNFLin,2]
	      ENDIF
	  ELSE
	         If SWN->(FieldPos("WN_LINHA")) # 0
	            SWN->WN_LINHA := Work1->WKLINHA
	         EndIf
	         If SWN->(FieldPos("WN_NUMSEQ")) # 0
	            SWN->WN_NUMSEQ:= Work1->WKNUMSEQ
	         EndIf
	  ENDIF
      */
      If SWN->(FieldPos("WN_LINHA")) # 0 .AND. WORK1->(FieldPos("WKLINHA")) # 0
         SWN->WN_LINHA := Work1->WKLINHA
      EndIf


      SC1->( DbSetOrder(1) ) // GCC - 04/07/2013 - Restauração do Indice, pois no MATA140 (funçào DI554CapNF()) onde o mesmo é desposicionado.

      IF PosO1_It_Solic(work1->wk_cc,work1->wksi_num,work1->wkcod_i,work1->wk_reg,0)
        SW0->(DBSEEK(xFilial("SW0")+SW1->W1_CC+SW1->W1_SI_NUM))
        IF SC1->(DBSEEK(xFilial("SC1")+SW0->W0_C1_NUM+SW1->W1_POSICAO)) .AND.;
           !EMPTY(SC1->C1_LOCAL)
           SWN->WN_LOCAL := SC1->C1_LOCAL
        ENDIF
      ENDIF

      //AWR 27/03/2002
      IF lMV_EASY_SIM
         aSegUM:=AV_Seg_Uni(Work1->WK_CC,Work1->WKSI_NUM,Work1->WKCOD_I,Work1->WK_REG,Work1->WKQTDE)
         IF !EMPTY(aSegUM[2])
            If lMV_UNIDCOM_2
               SWN->WN_PRECO  :=(Work1->WKQTDE * Work1->WKPRECO) / aSegUM[2]
               SWN->WN_QTSEGUM:= If(nTipoNF==NFE_COMPLEMEN,0,Work1->WKQTDE)
               SWN->WN_QUANT  := If(nTipoNF==NFE_COMPLEMEN,0,aSegUM[2])
            ELSE
               SWN->WN_QTSEGUM:=aSegUM[2]
            ENDIF
            If SW0->(DBSeek(xFilial("SW0")+Work1->WK_CC+Work1->WKSI_NUM))
               SC1->(DBSETORDER(2))
               If SC1->(DBSEEK(xFilial('SC1')+Work1->WKCOD_I+SW0->W0_C1_NUM))
                  SWN->WN_UNI  :=SC1->C1_UM
                  SWN->WN_SEGUM:=SC1->C1_SEGUM
               Endif
               SC1->(DBSETORDER(1))
            Endif
         ENDIF
      ENDIF

      IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,'GRAVA_WN'),)

      SWN->WN_PRODUTO  := Work1->WKCOD_I
      SWN->WN_VALOR    := Work1->WKVALMERC
      SWN->WN_VALIPI   := Work1->WKIPIVAL
      SWN->WN_VALICM   := Work1->WKVL_ICM
      SWN->WN_OPERACA  := Work1->WK_OPERACA
      SWN->WN_FORNECE  := Work1->WKFORN
      SWN->WN_LOJA     := Work1->WKLOJA
      SWN->WN_ICMS_A   := Work1->WKICMS_A
      SWN->WN_DESCR    := Work1->WKDESCR
      SWN->WN_IPITX    := Work1->WKIPITX
      SWN->WN_VLDEVII  := Work1->WKVLDEVII
      SWN->WN_VLDEIPI  := Work1->WKVLDEIPI
      SWN->WN_IPIVAL   := Work1->WKIPIVAL
      SWN->WN_IITX     := Work1->WKIITX
      SWN->WN_IIVAL    := Work1->WKIIVAL
      SWN->WN_PRUNI    := Work1->WKPRUNI
      SWN->WN_RATEIO   := DITRANS(Work1->WKRATEIO,9)
      SWN->WN_VL_ICM   := Work1->WKVL_ICM
      SWN->WN_PESOL    := Work1->WKPESOL
      SWN->WN_SEGURO   := Work1->WKSEGURO
      SWN->WN_CIF      := Work1->WKBASEII//Work1->WKCIF
      If nTipoNF # 2	//ASR 07/11/2005
	     SWN->WN_DESPESAS := Work1->WKOUT_DESP
      EndIf
      SWN->WN_FRETE    := Work1->WKFRETE
      SWN->WN_SI_NUM   := Work1->WKSI_NUM
      SWN->WN_CC       := Work1->WK_CC
      SWN->WN_CFO      := Work1->WK_CFO
      SWN->WN_OUTR_US  := Work1->WKOUT_D_US
      SWN->WN_IPIBASE  := Work1->WKIPIBASE
      SWN->WN_PGI_NUM  := Work1->WKPGI_NUM
      SWN->WN_ADICAO   := Work1->WKADICAO
      SWN->WN_INVOICE  := Work1->WKINVOICE
      SWN->WN_OUT_DES  := Work1->WKOUTDESP
      SWN->WN_INLAND   := Work1->WKINLAND
      SWN->WN_PACKING  := Work1->WKPACKING
      SWN->WN_DESCONT  := Work1->WKDESCONT
      SWN->WN_FOB_R    := Work1->WKFOB_R
      If lTemDespBaseICM .AND. nTipoNF # 2	//ASR 07/11/2005 - GRAVAÇÃO DA SWN
         SWN->WN_DESPICM := Work1->WKDESPICM
      ENDIF
      IF lMV_PIS_EIC .AND. nTipoNF # 2
         SWN->WN_VLUPIS := Work1->WKVLUPIS
         SWN->WN_BASPIS := Work1->WKBASPIS
         SWN->WN_PERPIS := Work1->WKPERPIS
         SWN->WN_VLRPIS := Work1->WKVLRPIS
         SWN->WN_VLUCOF := Work1->WKVLUCOF
         SWN->WN_BASCOF := Work1->WKBASCOF
         SWN->WN_PERCOF := Work1->WKPERCOF
         SWN->WN_VLRCOF := Work1->WKVLRCOF
         If lCposCofMj                                                            //NCF - 20/07/2012 - Majoração COFINS
            SWN->WN_ALCOFM := Work1->WKALCOFM
            SWN->WN_VLCOFM := Work1->WKVLCOFM
         EndIf
         If lCposPisMj                                                            //GFP - 11/06/2013 - Majoração PIS
            SWN->WN_ALPISM := Work1->WKALPISM
            SWN->WN_VLPISM := Work1->WKVLPISM
         EndIf
      ENDIF
      IF lLote
         SWN->WN_LOTECTL:= Work1->WK_LOTE
         SWN->WN_DTVALID:= Work1->WKDTVALID
         IF lCpoDtFbLt
            SWN->WN_DFABRI := Work1->WKDTFBLT
         ENDIF
      ENDIF
      IF SWN->(FIELDPOS("WN_VLACRES")) # 0 .AND. SWN->(FIELDPOS("WN_VLDEDUC")) # 0
         SWN->WN_VLACRES := Work1->WKVLACRES
         SWN->WN_VLDEDUC := Work1->WKVLDEDU
      ENDIF
      IF lExisteSEQ_ADI// AWR - 06/11/08 - NFE
         SWN->WN_SEQ_ADI := Work1->WKSEQ_ADI
      ENDIF
      IF lMV_GRCPNFE .AND. nTipoNF # 2//Campos novos NFE - AWR 06/11/2008
         SWN->WN_DESPADU := Work1->WKDESPADU
         SWN->WN_ALUIPI  := Work1->WKALUIPI
         SWN->WN_QTUIPI  := Work1->WKQTUIPI
         SWN->WN_QTUPIS  := Work1->WKQTUPIS
         SWN->WN_QTUCOF  := Work1->WKQTUCOF
         SWN->WN_PREDICM := Work1->WKPREDICM
      ENDIF
      //NCF-27/05/2010
      If lICMS_Dif  // PLB 14/05/07 - Tratamento para Diferimento de ICMS
         SWN->WN_VICMDIF := Work1->WKVL_ICM_D
         SWN->WN_VICM_CP := Work1->WKVLCREPRE
      EndIf

      If lICMS_Dif2  // EOB - 16/02/09
         SWN->WN_PICM_PD := WORK1->WK_PAG_DES
         SWN->WN_PICMDIF := WORK1->WK_PERCDIF
         SWN->WN_PICM_CP := WORK1->WK_PCREPRE
         SWN->WN_PLIM_CP := WORK1->WK_CRE_PRE
      EndIf

      If SWN->(FieldPos("WN_AC")) # 0    // GFP - 20/09/2013 - Novo Layout NFE - (Nota técnica da NFe - 2013-005)
         SWN->WN_AC := Work1->WKAC
      EndIf
      If SWN->(FieldPos("WN_NVE")) # 0    // GFP - 20/09/2013 - Novo Layout NFE - (Nota técnica da NFe - 2013-005)
         SWN->WN_NVE := Work1->WKNVE
      EndIf
      If SWN->(FieldPos("WN_AFRMM")) # 0    // GFP - 23/09/2013 - Novo Layout NFE - (Nota técnica da NFe - 2013-005)
         SWN->WN_AFRMM := Work1->WKAFRMM
      EndIf
      IF lTemCposOri//AWF - 31/07/2014
         SWN->WN_DOCORI:= Work1->WKNOTAOR
         SWN->WN_SERORI:= Work1->WKSERIEOR
      ENDIF
      If AvFlags("ICMSFECP_DI_ELETRONICA")
         SWN->WN_ALFECP := Work1->WKALFECP
         SWN->WN_VLFECP := Work1->WKVLFECP
      EndIf
      If AVFLAGS("FECP_DIFERIMENTO")
         SWN->WN_FECPALD := Work1->WKFECPALD
         SWN->WN_FECPVLD := Work1->WKFECPVLD
         SWN->WN_FECPREC := Work1->WKFECPREC
      EndIf
      SWN->(MsUnlock())

      If lIntDraw .and. cAntImp == "1" .and. nTipoNF = 1
         SW8->(dbSeek(xFilial("SW8")+SWN->WN_HAWB+SWN->WN_INVOICE+SWN->WN_PO_EIC+SWN->WN_ITEM+SWN->WN_PGI_NUM))
         If !Empty(SW8->W8_AC) .and. aScan(aAntLido,{|x| x[1]==SWN->WN_HAWB .and. x[2]==SWN->WN_INVOICE .and.;
         x[3]==SWN->WN_PO_EIC .and. x[4]==SWN->WN_ITEM .and. x[5]==SWN->WN_PGI_NUM}) = 0
            aAdd(aAntLido,{SWN->WN_HAWB,SWN->WN_INVOICE,SWN->WN_PO_EIC,SWN->WN_ITEM,SWN->WN_PGI_NUM})
            ED4->(dbSeek(xFilial("ED4")+SW8->W8_AC+SW8->W8_SEQSIS))
            DIGrvAnt(1,SWN->WN_HAWB,SWN->WN_PO_EIC,SWN->WN_INVOICE,SWN->WN_PRODUTO,SWN->WN_ITEM,SWN->WN_PGI_NUM,SW8->W8_QT_AC,dDtNFE,ED4->ED4_AC,ED4->ED4_SEQSIS,ED4->ED4_PD)
         EndIf
      EndIf

   ELSE
      IF DI554CapQuebrou()//nNFE # Work1->WK_NFE  .OR. nSerie # Work1->WK_SE_NFE

         IF !DI554CapNF()
            EXIT
         ENDIF
         nQtdeNFs +=1
         nNFE  :=Work1->WK_NFE
         nSerie:=Work1->WK_SE_NFE
         dDtNFE:=Work1->WK_DT_NFE
         nPesol:=nValor:=nFrete:=nSeguro:=nCIF:=nII:=nIPI:=nICMS:=nDespesa:=nPesoB:=0 //FSM - 02/09/2011 - Peso Bruto Unitario

      ENDIF

      EI2->(RecLock("EI2",.T.))
      EI2->EI2_FILIAL   := xFilial("EI2")
      EI2->EI2_TIPO_N   := STR(nTipoNF,1,0)
      EI2->EI2_HAWB     := SW6->W6_HAWB
      EI2->EI2_DOC      := Work1->WK_NFE
      EI2->EI2_NOTA     := Work1->WK_NOTA
      //EI2->EI2_SERIE    := Work1->WK_SE_NFE
	  SerieNfId("EI2",1,"EI2_SERIE",,,,Work1->WK_SE_NFE)

      EI2->EI2_TEC      := Work1->WKTEC
      EI2->EI2_EX_NCM   := Work1->WKEX_NCM
      EI2->EI2_EX_NBM   := Work1->WKEX_NBM
      EI2->EI2_PO_NUM   := Work1->WKPO_NUM
      EI2->EI2_POSICA   := Work1->WKPOSICAO
      EI2->EI2_QUANT    := If(nTipoNF==NFE_COMPLEMEN,0,Work1->WKQTDE) //MJB100399
      EI2->EI2_PRODUT   := Work1->WKCOD_I
      EI2->EI2_VALOR    := Work1->WKVALMERC
      EI2->EI2_VALIPI   := Work1->WKIPIVAL
      EI2->EI2_VALICM   := Work1->WKVL_ICM
      EI2->EI2_OPERAC   := Work1->WK_OPERACA
      EI2->EI2_FORNEC   := Work1->WKFORN//AWR 21/03/2001
      EI2->EI2_LOJA     := Work1->WKLOJA//AWR 21/03/2001
      EI2->EI2_ICMS_A   := Work1->WKICMS_A
      EI2->EI2_PRECO    := Work1->WKPRECO
      EI2->EI2_DESCR    := Work1->WKDESCR
      EI2->EI2_UNI      := Work1->WKUNI
      EI2->EI2_VLDEII   := Work1->WKVLDEVII
      EI2->EI2_VLDIPI   := Work1->WKVLDEIPI
      EI2->EI2_IPITX    := Work1->WKIPITX
      EI2->EI2_IPIVAL   := Work1->WKIPIVAL
      EI2->EI2_IITX     := Work1->WKIITX
      EI2->EI2_IIVAL    := Work1->WKIIVAL
      EI2->EI2_PRUNI    := Work1->WKPRUNI
      EI2->EI2_RATEIO   := DITRANS(Work1->WKRATEIO,9)
      EI2->EI2_VL_ICM   := Work1->WKVL_ICM
      EI2->EI2_PESOL    := Work1->WKPESOL
      EI2->EI2_SEGURO   := Work1->WKSEGURO
      EI2->EI2_CIF      := Work1->WKBASEII//Work1->WKCIF
      EI2->EI2_DESPES   := Work1->WKOUT_DESP
      EI2->EI2_FRETE    := Work1->WKFRETE
      EI2->EI2_SI_NUM   := Work1->WKSI_NUM
      EI2->EI2_CC       := Work1->WK_CC
      EI2->EI2_CFO      := Work1->WK_CFO
      EI2->EI2_REC_ID   := Work1->WKREC_ID
      EI2->EI2_OUTR_U   := Work1->WKOUT_D_US
      EI2->EI2_IPIBAS   := Work1->WKIPIBASE
      EI2->EI2_PGI_NU   := Work1->WKPGI_NUM
      EI2->EI2_INVOIC   := Work1->WKINVOICE
      EI2->EI2_OUT_DE   := Work1->WKOUTDESP
      EI2->EI2_INLAND   := Work1->WKINLAND
      EI2->EI2_PACKIN   := Work1->WKPACKING
      EI2->EI2_DESCON   := Work1->WKDESCONT
      EI2->EI2_FOB_R    := Work1->WKFOB_R
      IF lMV_PIS_EIC
         EI2->EI2_VLUPIS := Work1->WKVLUPIS
         EI2->EI2_BASPIS := Work1->WKBASPIS
         EI2->EI2_PERPIS := Work1->WKPERPIS
         EI2->EI2_VLRPIS := Work1->WKVLRPIS
         EI2->EI2_VLUCOF := Work1->WKVLUCOF
         EI2->EI2_BASCOF := Work1->WKBASCOF
         EI2->EI2_PERCOF := Work1->WKPERCOF
         EI2->EI2_VLRCOF := Work1->WKVLRCOF
         If lCposCofMj                                                            //NCF - 20/07/2012 - Majoração COFINS
            EI2->EI2_VLCOFM := Work1->WKVLCOFM
         EndIf
         If lCposPisMj                                                            //GFP - 11/06/2013 - Majoração PIS
            EI2->EI2_VLPISM := Work1->WKVLPISM
         EndIf

      ENDIF
      IF lLote
         EI2->EI2_LOTECT:= Work1->WK_LOTE
         EI2->EI2_DTVALI:= Work1->WKDTVALID
         IF lCpoDtFbLt
            EI2->EI2_DFABRI := Work1->WKDTFBLT
         ENDIF
      ENDIF

      IF EI2->(FIELDPOS("EI2_VACRES")) # 0 .AND. EI2->(FIELDPOS("EI2_VDEDUC")) # 0 //ER - 15/07/2008
         EI2->EI2_VACRES := Work1->WKVLACRES
         EI2->EI2_VDEDUC := Work1->WKVLDEDU
      ENDIF

      EI2->(MsUnlock())

      nPesol  +=EI2->EI2_PESOL
      IF lExiste_Midia .AND. !EMPTY(Work1->WKFOBR_ORI)
         nValor +=Work1->WKFOBR_ORI
      ELSE
         nValor +=Work1->WKFOB_R
      ENDIF
      nFrete  +=EI2->EI2_FRETE
      nSeguro +=EI2->EI2_SEGURO
      nCIF    +=EI2->EI2_CIF
      nII     +=EI2->EI2_IIVAL
      nIPI    +=EI2->EI2_IPIVAL
      nICMS   +=EI2->EI2_VL_ICM
      nDespesa+=EI2->EI2_DESPESAS

   ENDIF

   IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"GRAVA_SWN_EI2"),)

   // O Seek do Work2 e do SA2 esta antes do Skip do Work1 para incluir os dados, na Capa, do Registro certo do Work2 e do SA2
   Work2->(DBSEEK(Work1->WKADICAO+Work1->WK_CFO+Work1->WK_OPERACA+Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM))
   SA2->(DBSEEK(xFilial("SA2")+Work1->WKFORN+Work1->WKLOJA))//AWR 21/03/2001

   Work1->(DbSkip())

ENDDO

If lIntDraw .and. cAntImp == "1"
   SW8->(dbSetOrder(1))
   ED4->(dbSetOrder(1))
EndIf

If nTipoNF = CUSTO_REAL
   DI554CapNF()
ENDIF

nQtdeNFs +=1

Work1->(DbGoTop())

SW6->(RecLock("SW6",.F.))

If (nTipoNF==NFE_PRIMEIRA .OR. nTipoNF==NFE_UNICA .Or. (lMV_NF_MAE .And. nTipoNF == NFE_MAE))
   SW6->W6_NF_ENT  :=ALLTRIM(Work1->WK_NFE)+IF(nQtdeNFs>1," ...","")
   //SW6->W6_SE_NF   :=Work1->WK_SE_NFE
   SerieNfId("SW6",1,"W6_SE_NF",,,,Work1->WK_SE_NFE)

   SW6->W6_DT_NF   :=Work1->WK_DT_NFE
   SW6->W6_VL_NF   :=nVlTotNFs
   DI554ProcEIB(.T.)
ENDIF

//If (nTipoNF==NFE_COMPLEMEN .OR. nTipoNF==NFE_UNICA)
IF nTipoNF # CUSTO_REAL
   If nTipoNF==NFE_COMPLEMEN // .And. Empty(SW6->W6_NF_COMP)
      SW6->W6_NF_COMP:=ALLTRIM(Work1->WK_NFE)+IF(nQtdeNFs>1," ...","")
      //SW6->W6_SE_NFC :=Work1->WK_SE_NFE
	  SerieNfId("SW6",1,"W6_SE_NFC",,,,Work1->WK_SE_NFE)

      SW6->W6_DT_NFC :=Work1->WK_DT_NFE
      SW6->W6_VL_NFC +=nDespTotNFCs
   Endif
   SWD->(DBSEEK(xFilial("SWD")+SW6->W6_HAWB))
   If nTipoNF # NFE_FILHA //LGS-25/04/2015 - Validação para não gravar o nro da NF Filha e perder a referencia do nro gerado pela NF Mãe.
	  DO WHILE SWD->(!EOF()) .AND. EVAL(bDDIWhi)
	     //NCF - 13/09/2010 - Para gravar número na nota quando é imposto integrado pelo despachante
	     //TDF - 06/01/2010 - Revisão do tratamento para gravar o número da nota                   // SVG - 19/01/2011 - Gravar numero da nota nas despesas 1 2 9 , quando nao for complementar
	     IF SYB->(DbSeek(xFilial("SYB")+SWD->WD_DESPESA )) .AND. (LEFT(SWD->WD_DESPESA,1) $ "12") .AND. !lTipoCompl //SWD->WD_INTEGRA
	        SWD->(RecLock("SWD",.F.))
	        SWD->WD_NF_COMP:=Work1->WK_NFE
	        //SWD->WD_SE_NFC :=Work1->WK_SE_NFE
			SerieNfId("SWD",1,"WD_SE_NFC",,,,Work1->WK_SE_NFE)

	        SWD->(MsUnlock())
	     ENDIF
	     IF !SYB->(DbSeek(xFilial("SYB")+SWD->WD_DESPESA )) .OR.;
	        SYB->YB_BASECUS $ cNao .OR. !EVAL(bDDIFor)
	        SWD->(DBSKIP())
	        LOOP
	     ENDIF
	     lBaseICMS:=SYB->YB_BASEICM
	     IF SYB->YB_BASEICM $ cSim
	        IF lTemYB_ICM_UF
	           lBaseICMS:= SYB->(FIELDGET(FIELDPOS(cCpoBasICMS)))
	        ENDIF
	     ENDIF
	     IF (nTipoNF==NFE_PRIMEIRA .OR. (lMV_NF_MAE .And. nTipoNF==NFE_MAE) .Or. (lMV_NF_MAE .And. nTipoNF == NFE_FILHA)) .AND. !(SYB->YB_BASEIMP $ cSim) .AND. !(lBaseICMS $ cSim)
	        SWD->(DBSKIP())
	        LOOP
	     ENDIF
	     SWD->(RecLock("SWD",.F.))
	     SWD->WD_NF_COMP:=Work1->WK_NFE
	     //SWD->WD_SE_NFC :=Work1->WK_SE_NFE
	     SerieNfId("SWD",1,"WD_SE_NFC",,,,Work1->WK_SE_NFE)

         SWD->WD_DT_NFC :=Work1->WK_DT_NFE
         SWD->WD_VL_NFC :=nVlTotNFs
	     IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"GRAVA_SWD"),)
	     SWD->(MsUnlock())
	     SWD->(DBSKIP())
	  ENDDO
   ENDIF
ENDIF

IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,'GRAVAR'),)

SW6->(MsUnlock())

If nTipoNF # NFE_PRIMEIRA .AND. nTipoNF # NFE_MAE
   Work3->(DBGOTOP())
   DO WHILE Work3->(!EOF())
      IncProc(STR0152+' '+Work3->WKDESPESA)//"Gravando Despesas: "
      Work1->(DBGOTO(Work3->WKRECNO))
      SWW->(RecLock("SWW",.T.))
      SWW->WW_FILIAL  := xFilial("SWW")
      SWW->WW_DESPESA := Work3->WKDESPESA
      SWW->WW_VALOR   := Work3->WKVALOR
      SWW->WW_PO_NUM  := Work3->WKPO_NUM
      SWW->WW_NF_COMP := Work3->WK_NF_COMP
      //SWW->WW_SE_NFC  := Work3->WK_SE_NFC
      SerieNfId("SWW",1,"WW_SE_NFC",,,,Work3->WK_SE_NFC)

	  SWW->WW_DT_NFC  := Work3->WK_DT_NFC
      SWW->WW_TIPO_NF := STR(nTipoNF,1,0)
      SWW->WW_FORNECE := Work1->WKFORN
      SWW->WW_LOJA    := Work1->WKLOJA
      SWW->WW_NR_CONT := Work3->WKPOSICAO
      SWW->WW_HAWB    := SW6->W6_HAWB
      SWW->WW_PGI_NUM := Work3->WKPGI_NUM
      SWW->WW_LOTECTL := Work1->WK_LOTE //Work3->WK_LOTE   //NCF - 21/06/2011 -

      IF SWW->(FIELDPOS("WW_INVOICE")) # 0
         SWW->WW_INVOICE := WORK1->WKINVOICE
      ENDIF

      IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"GRAVA_SWW"),)
      SWW->(MsUnlock())
      Work3->(DBSKIP())
   ENDDO
ENDIF

End SEQUENCE

End Transaction

Work1->(DBSETORDER(1))
Work1->(DbGoto(nRec1))
Work2->(DbGoto(nRec2))
Work3->(DbGoto(nRec3))

IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,'FINAL_GRAVA_NOTA'),)

IF !lMSErroAuto
   cNota:=cNotaGrupo
   lGerouNFE:=.T.
   IF nTipoNF # CUSTO_REAL
      IF AvFlags("EIC_EAI")//AWF -  REQ 6 11/06/2014

         lOK:=.T.
         For i = 1 To Len(aEnv_NFS)
             SF1->(DBGOTO(aEnv_NFS[I]))
             If !EICNF100(.T.,3)//Na respota coloca F1_STATUS := "1"
                lOK:=.F.
                EXIT
             EndIf
         Next

         If lOK

            For i = 1 To Len(aEnv_NFS)
                SF1->(DBGOTO(aEnv_NFS[I]))
                SF1->(RECLOCK("SF1",.F.))
                SF1->F1_OK:="1"
                SF1->(MSUNLOCK())
            Next

            //igor chiba 02/07/14 contabilizacao
            IF EasyGParam('MV_EIC_ECO',,.F.) == 'N' .AND. EasyGParam('MV_EIC0047',,.F.) .AND. (nTipoNF==NFE_PRIMEIRA .OR. nTipoNF==NFE_UNICA .Or.  nTipoNF == NFE_MAE)
               GERVAR_TRA('TN')
            ENDIF

            MsgInfo(STR0367, STR0368) //"NF(s) Integrada(s) com Sucesso", "Aviso"

            /* O envio dos efetivos e a compensação com o evento 608 ocorrerá apenas quando a integração da
               nota fiscal ocorrer */
            IF AvFlags("EAI_PGANT_INV_NF") .AND. (nTipoNF==NFE_PRIMEIRA .OR. nTipoNF==NFE_UNICA .Or.  nTipoNF == NFE_MAE)
               IF EICAP110(.T., 3, SF1->F1_HAWB, "D", "1", .T., "1",,, .T.)
                  EICAP111(.T.,3,SF1->F1_HAWB,         ,         ,"1",.T.)
               ENDIF
            ENDIF
         Else
            lOK:=.T.
            Processa({|| lOK:=DI554Estorna() },STR0090) //"Processando Estorno..."
            IF !lOK
               MsgInfo(STR0369, STR0368) //"Não foi possível estornar a nota fiscal. Tente novamente após a realização dos ajustes necessários."
            ENDIF

         ENDIF

      ELSE
         //igor chiba se nao estiver integrado tambem disparar contabilizacao
         IF EasyGParam('MV_EIC_ECO',,.F.) == 'N' .AND. EasyGParam('MV_EIC0047',,.F.) .AND. (nTipoNF==NFE_PRIMEIRA .OR. nTipoNF==NFE_UNICA .Or.  nTipoNF == NFE_MAE)
            GERVAR_TRA('TN')
         ENDIF

         MSGINFO((STR0153),STR0108) //"Geracao de Nota Fiscal Concluida"###"Informação"

      EndIf
   ELSE
      MsgInfo((STR0154),STR0108) //"Gravacao de Custo Concluida"###"Informação"
   ENDIF

ENDIF

DbSelectArea(nOldArea)

Return .T.
*--------------------------------------------------------------------------------------*
Function DI554GrvSD1(cLOCAL,nQTSEGUM,nQUANT,cUNI,cSEGUM,nCIF,xTipoNF)
*--------------------------------------------------------------------------------------*
Local cPosicao := Work1->WKPOSICAO // RA - 24/10/03 - O.S. 1075/03
LOCAL lCpoCtCust := (EasyGParam("MV_EASY") $ cSim) .And. SW3->(FIELDPOS("W3_CTCUSTO")) > 0 // NCF - 12/07/2010 - Flag do campo de Centro de Custo
Local nWKVALMERC :=  0  // LGS - 19/07/2016
Local cConta  := ""
Local cItemCta := ""
Local cClvl   := ""
Local aOrdSCI 
LOCAL lAchouSC1
PRIVATE lSair := .F.

IF(EasyEntryPoint("EICDI554"),EXECBLOCK("EICDI554",.F.,.F.,"ANTES_GRAVA_SD1"),)	//JWJ - 07/11/2005

IF lSair
	Return
Endif

xTipoNF:=STR(xTipoNF,1)
If !Empty(Work1->WKPOSSIGA) // DI veio de uma DA
   cPosicao := Work1->WKPOSSIGA
ENDIF
SC7->(DBSETORDER(1))
IF !SC7->(DBSEEK(xFilial()+Work1->WKPO_SIGA+cPosicao))
    SC7->(DBSEEK(xFilial()+Work1->WKPO_SIGA+'01  '+cPosicao))
ENDIF
// RA - 24/10/03 - O.S. 1075/03 - Final
SB1->(DbSeek(xFilial()+Work1->WKCOD_I))
aItem:={}

//LGS-19/07/2016 - Alteracao para desconsiderar o valor do II do Vl Total do Item, antes era feito no NFESefaz, agora nós que temos que validar
If EasyGParam("MV_EIC0064",,.F.) .And. SD1->(FIELDPOS("D1_II")) # 0
   nWKVALMERC := Work1->WKVALMERC - Work1->WKIIVAL
Else
   nWKVALMERC := Work1->WKVALMERC
EndIf

//FSY - 06/03/2014 - Ajustada a 3º posição do vetor aItem com o conteudo "T", pois a integração com SIGACOM não era realizada
// AADD(aItem,{"D1_ITEM"        ,Work1->WKPOSICAO ,NIL}) OS 1163/03   -  08/11/2003
If SWN->(FieldPos("WN_LINHA")) # 0 .AND. WORK1->(FieldPos("WKLINHA")) # 0
   AADD(aItem,{"D1_ITEM"        ,STRZERO(Work1->WKLINHA, 4),NIL})
EndIf

AADD(aItem,{"D1_COD"         ,Work1->WKCOD_I                ,  NIL})// codigo do produto
//SVG - 16/05/2011 - Nopado a verificação da variável lGrvItem devido a esses campos serem usados para o envio ao SEFAZ
//If nTipoNF # NFE_COMPLEMEN .And. nTipoNF # NFE_MAE
   //LRS - 07/10/2015 - Não Gravar os campos D1_PEDIDO e D1_ITEMPC se o tiver integrado com compras e for Nota Complementar e Nota Mãe
//   If (EasyGParam("MV_EASY") == "S" .And. (nTipoNF <> NFE_COMPLEMEN .AND. nTipoNF <> NFE_FILHA))
If nTipoNF <> NFE_FILHA
	   AADD(aItem,{"D1_PEDIDO"   ,Work1->WKPO_SIGA              ,".T."})// Pedido de compra
	   AADD(aItem,{"D1_ITEMPC"   ,SC7->C7_ITEM                  ,".T."})// Item do Pedido de compra
EndIF
//Endif
If !Empty(cUNI)
   AADD(aItem,{"D1_UM"       ,cUNI                   ,/*NIL*/".T."}) // unidade do produto
Endif
If !Empty(cSEGUM)
   AADD(aItem,{"D1_SEGUM"    ,cSEGUM                 ,/*NIL*/".T."})
Endif
If nTipoNF = NFE_COMPLEMEN //LGS-19/07/2016
   AADD(aItem,{"D1_VUNIT"    ,/*Work1->WKVALMERC*/ nWKVALMERC       ,/*NIL*/".T."}) // valor unitario do item
ELSE
   AADD(aItem,{"D1_QUANT"    ,nQUANT                 ,/*NIL*/".T."})  // quantidade do produto
   AADD(aItem,{"D1_VUNIT"    ,/*Work1->WKVALMERC*/ nWKVALMERC/nQuant,/*NIL*/".T."}) // valor unitario do item
Endif
AADD(aItem,{"D1_TOTAL"       ,/*Work1->WKVALMERC*/ nWKVALMERC       ,/*NIL*/".T."})  // valor total do item (quantidade * preco)
AADD(aItem,{"D1_VALIPI"      ,Work1->WKIPIVAL        ,/*NIL*/".T."})  // Vlr do IPI
AADD(aItem,{"D1_VALICM"      ,Work1->WKVL_ICM        ,/*NIL*/".T."})  // Vlr do ICMS
If !Empty(Work1->WK_CFO)
   AADD(aItem,{"D1_CF"       ,Work1->WK_CFO          ,/*NIL*/".T."})  // Classificacao Fiscal
ENDIF

//FDR - 01/10/2015 - Envio do valor II destacado, atendimento a Decisão Normativa CAT 06, de 11-09-2015 - SP
IF SD1->(FIELDPOS("D1_II")) # 0
   AADD(aItem,{"D1_II"       ,Work1->WKIIVAL   ,".T."})
   AADD(aItem,{"D1_ALIQII"   ,Work1->WKIITX    ,".T."})
ENDIF

AADD(aItem,{"D1_IPI"         ,Work1->WKIPITX         ,/*NIL*/".T."})
AADD(aItem,{"D1_PICM"        ,Work1->WKICMS_A        ,/*NIL*/".T."})
AADD(aItem,{"D1_PESO"        ,Work1->WKPESOL         ,/*NIL*/".T."})  // Peso Total do Item
AADD(aItem,{"D1_FORNECE"     ,Work1->WKFORN          ,/*NIL*/".T."})
AADD(aItem,{"D1_LOJA"        ,Work1->WKLOJA          ,/*NIL*/".T."})
AADD(aItem,{"D1_LOCAL"       ,cLOCAL                 ,/*NIL*/".T."})
AADD(aItem,{"D1_DOC"         ,Work1->WK_NFE          ,         NIL})
AADD(aItem,{"D1_SERIE"       ,Work1->WK_SE_NFE       ,         NIL})
AADD(aItem,{"D1_EMISSAO"     ,Work1->WK_DT_NFE       ,         NIL})
AADD(aItem,{"D1_DTDIGIT"     ,dDataBase              ,/*NIL*/".T."})
AADD(aItem,{"D1_TIPO"        ,IF(nTipoNF=NFE_COMPLEMEN,"C" ,"N" ),NIL})
AADD(aItem,{"D1_TIPODOC"     ,IF(nTipoNF=NFE_COMPLEMEN,"13","10"),NIL})
AADD(aItem,{"D1_TP"          ,SB1->B1_TIPO           ,/*NIL*/".T."})
If !Empty(cSEGUM)
   AADD(aItem,{"D1_QTSEGUM"  ,nQTSEGUM               ,/*NIL*/".T."})
Endif
AADD(aItem,{"D1_BASEICM"     ,Work1->WKBASEICMS      ,/*NIL*/".T."})
AADD(aItem,{"D1_BASEIPI"     ,Work1->WKIPIBASE       ,/*NIL*/".T."})
AADD(aItem,{"D1_FORMUL"      ,cFormPro               ,/*NIL*/".T."})
AADD(aItem,{"D1_TEC"         ,Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM+Work1->WK_OPERACA,/*NIL*/".T."})
AADD(aItem,{"D1_CONHEC"      ,SW6->W6_HAWB           ,/*NIL*/".T."})
AADD(aItem,{"D1_TIPO_NF"     ,xTipoNF                ,/*NIL*/".T."})
//FSY - 06/03/2014 - Ajustada a 3º posição do vetor aItem com o conteudo "T", pois a integração com SIGACOM não era realizada

IF nTipoNF == NFE_COMPLEMEN .Or. (lMV_NF_MAE .And. nTipoNF == NFE_FILHA)  // Alfredo Magalhaes - Microsiga
   nOrdSWN := SWN->(INDEXORD())
   SWN->(DBSETORDER(3))
   SWV->(DBSETORDER(2))
   lAchouSWN := .F.
   lTemLote  := .F.

   //LGS-10/04/2014 - Verifica se o desembaraço possui lote
   If SWV->(dbseek(XFILIAL("SWV")+SWN->WN_HAWB+SWN->WN_INVOICE+SWN->WN_PGI_NUM+SWN->WN_PO_EIC+SWN->WN_ITEM))
   	  lTemLote := .T.
   EndIf

   IF SWN->(DBSEEK(xFilial("SWN")+SW6->W6_HAWB))

      DO WHILE SWN->(!EOF())                    .AND.;
               SWN->WN_FILIAL  == xFilial("SWN").AND.;
               SWN->WN_HAWB    == SW6->W6_HAWB

         If SWN->WN_ITEM <> WORK1->WKPOSICAO  // GFP - 16/01/2014 - Posiciona no item correto da NF.
            SWN->(DbSkip())
            Loop
         EndIf

         If (SWN->WN_INVOICE == WORK1->WKINVOICE) .AND.;
            (SWN->WN_PO_EIC  == WORK1->WKPO_NUM)  .AND.;
            (SWN->WN_PGI_NUM == WORK1->WKPGI_NUM) .AND.;
            (SWN->WN_ITEM    == WORK1->WKPOSICAO) .AND.;
            (Alltrim(SWN->WN_LOTECTL) == Alltrim(Work1->WK_LOTE)) .AND.; //ASK 09/09/2007 - Verifica quebra de lote.
            (SWN->WN_TIPO_NF $ "1,3,5")

            AADD(aItem,{"D1_NFORI"    ,SWN->WN_DOC    ,NIL})
            AADD(aItem,{"D1_SERIORI"  ,SWN->WN_SERIE  ,NIL})
            AADD(aItem,{"D1_ITEMORI"  ,STRZERO(SWN->WN_LINHA, 4)  ,.F.})
            SF1->(dbSetOrder(5))
            If !SF1->(dbSeek(xFilial("SF1") + SWN->WN_HAWB + "1"))
               If SF1->(dbSeek(xFilial("SF1") + SWN->WN_HAWB + "3"))
                  AADD(aItem,{"D1_DATORI"  ,SF1->F1_EMISSAO  ,Nil})
               EndIf
            Else
               AADD(aItem,{"D1_DATORI"  ,SF1->F1_EMISSAO  ,Nil})
            EndIf

            lAchouSWN := .T.

            EXIT

         ENDIF
         SWN->(DbSkip())
      ENDDO
   ENDIF
   SWN->(DBSETORDER(nOrdSWN))
Endif

IF lLote .AND. SD1->(FIELDPOS("D1_LOTECTL")) # 0 .AND. SD1->(FIELDPOS("D1_DTVALID")) # 0
   SB1->(DBSEEK(xFilial("SB1")+Work1->WKCOD_I))
   IF SB1->B1_RASTRO $ "SL" .AND. !EMPTY(Work1->WK_LOTE)
      AADD(aItem,{"D1_LOTECTL",Work1->WK_LOTE  , ".T." })
       IF !EMPTY(Work1->WKDTVALID)
          AADD(aItem,{"D1_DTVALID",Work1->WKDTVALID, ".T." })
       ENDIF
       IF SD1->(FIELDPOS("D1_DFABRIC")) # 0 .And. lCpoDtFbLt .And. !EMPTY(Work1->WKDTFBLT)
          AADD(aItem,{"D1_DFABRIC",Work1->WKDTFBLT, ".T." })
       ENDIF
   ENDIF
ENDIF

IF Work1->(FIELDPOS("WKDESPICM")) # 0
                                  // SVG - 08/10/2010 - Despesa base de imposto inserida também na nota mãe
   IF nTipoNF==NFE_PRIMEIRA .Or. (lMV_NF_MAE .And. (nTipoNF == NFE_MAE .Or.  (nTipoNF == NFE_FILHA .And. EasyGParam("MV_NFFILHA",,"0") $ "1,3"))) //LGS-05/05/14
      AADD(aItem,{"D1_DESPESA",Work1->WKDESPICM,})
   ELSEIF nTipoNF == 3
      AADD(aItem,{"D1_DESPESA",Work1->WKDESPICM+Work1->WKOUT_DESP,})
   ELSEIF nTipoNF == 2
      AADD(aItem,{"D1_DESPESA",0,})
   ENDIF
ENDIF

IF lMV_PIS_EIC .AND. nTipoNF # 2
   AADD(aItem,{cCpoBsPis,Work1->WKBASPIS,})
   AADD(aItem,{cCpoVlPis,Work1->WKVLRPIS,})
   AADD(aItem,{cCpoAlPis,Work1->WKPERPIS,})
   AADD(aItem,{cCpoAlCof,Work1->WKPERCOF,})
   AADD(aItem,{cCpoBsCof,Work1->WKBASCOF,})
   AADD(aItem,{cCpoVlCof,Work1->WKVLRCOF,})
ENDIF

/*EasyGParam("MV_EIC0008",,.F.) FIXO .T. OSSME-6437 MFR 06/12/2021 */
//If EasyGParam("MV_EIC0008",,.F.)
   AADD(aItem,{"D1_CLVL"     ,SC7->C7_CLVL     ,".T."})    //ISS - 06/05/2011 - Classe Valor Contabil
//EndIF

/*WHRS 14/11/2017 TE-7527 539560/ MTRADE-1690 /MTRADE-1790 - envio de conta contábil na geração do documento de entrada*/
aOrdSCI:= SaveOrd({"SC1"})
SC1->( DbSetOrder(1) )

If SW0->(DBSeek(xFilial("SW0")+Work1->WK_CC+Work1->WKSI_NUM))
    //IF SC1->(DBSEEK(xFilial("SC1")+SW0->W0_C1_NUM+Work1->WKPOSICAO))
    IF SC1->(DBSEEK(xFilial("SC1")+SC7->C7_NUMSC +SC7->C7_ITEMSC)) //LRS - 11/04/2018
        lAchouSC1 := .T.
    ENDIF
ENDIF

IF lAchouSC1
    cConta := SC1->C1_CONTA 
    cItemCta := SC1->C1_ITEMCTA 
    cClvl := SC1->C1_CLVL
ENDIF

if EMPTY(cConta) 
    cConta := SB1->B1_CONTA 
endIf
if EMPTY(cItemCta)
    cItemCta := SB1->B1_ITEMCC 
endIf
if EMPTY(cClvl)
    cClvl := SB1->B1_CLVL
endIf

// 09/03/06 - Bete - Chamado 025671 
AADD(aItem,{"D1_CONTA"    ,cConta    ,".T."})    //NCF - 18/10/2010 - Gravação a partir da Solicitação de Compras e não do
AADD(aItem,{"D1_ITEMCTA"  ,cItemCta  ,".T."})    //                   Pedido de Compras (SC7)
AADD(aItem,{"D1_CLVL"     ,cClvl     ,".T."})    //ISS - 06/05/2011 - Classe Valor Contabil

RestOrd(aOrdSCI,.T.)

If lCpoCtCust  //NCF - 23/06/2010 - Gravação do campo do Centro de Custo no SD1
   aOrdTabl := SaveOrd({"SW3"})
      SW3->(DbSetOrder(8))
      SW3->(DbSeek(xFilial() + Work1->WKPO_NUM + Work1->WKPOSICAO))
      //DFS - 29/08/12 - Para só utilizar o SW3 se o mesmo tiver preenchido, visto que, não é um campo obrigatório
      If !Empty(SW3->W3_CTCUSTO)
         AADD(aItem,{"D1_CC",SW3->W3_CTCUSTO,".T."})
      Else
         AADD(aItem,{"D1_CC"       ,SC7->C7_CC       ,".T."})
      EndIf
   RestOrd(aOrdTabl)
Else
   AADD(aItem,{"D1_CC"   ,SC7->C7_CC     ,".T."})
EndIf

If lICMS_Dif  // LRS-13/02/2017 - Tratamento Diferimento ICMS
   Aadd( aItem, { "D1_ICMSDIF", Work1->WKVL_ICM_D, ".T." } )
EndIf

If lICMS_Dif .AND. Work1->WKVL_ICM_D > 0 .AND. SD1->(FieldPos("D1_VOPDIF")) > 0  // Envio do valor devido no novo campo D1_VOPDIF
   Aadd( aItem, {"D1_VOPDIF", Work1->WKVLICMDEV, ".T." })
EndIf

If lCposCofMj //NCF - 25/07/2012 - Majoração COFINS
   Aadd( aItem, { "D1_VALCMAJ", Work1->WKVLCOFM , ".T." } )
EndIf
If lCposPisMj //GFP - 11/06/2013 - Majoração PIS
   Aadd( aItem, { "D1_VALPMAJ", Work1->WKVLPISM , ".T." } )
EndIf

If AvFlags("ICMSFECP_DI_ELETRONICA") .And. SD1->( Fieldpos("D1_ALQFECP") > 0 .And. Fieldpos("D1_VALFECP") > 0 )
   AADD(aItem,{"D1_ALQFECP"   ,Work1->WKALFECP  ,".T."})
   AADD(aItem,{"D1_VALFECP"   ,Work1->WKVLFECP  ,".T."}) 
   If SD1->( Fieldpos("D1_BASFECP") ) > 0                     
      AADD(aItem,{"D1_BASFECP"   ,Work1->WKBASEICMS  ,".T."})  //
   EndIf     
EndIf

IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,'GRAVACAO_SD1'),)

AADD(aItens,ACLONE(aItem))

RETURN .T.


*---------------------*
Function DI554Quebrou()  // Jonato 30-01-2001  , Para que outras quebras possam ser feitas, via rdmake
*---------------------*
PRIVATE lQuebra_Espe:=.f., lQuebrou_NF:=.f.
Private lQuebraCFO := EasyGParam("MV_QBCFO",,.F.) //RRV - 18/01/2013 - Define se a nota será quebrada por CFOP ou não.(.T. = Quebra, .F. = Não quebra)  // GFP - 17/06/2013

IF (EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,'Tem_Outra_Quebra'),)

IF ! lQuebra_Espe

   //DFS - 14/02/11 - Caso tenha nota fiscal complementar, quebrar por numero de nota.
   If nTipoNF == NFE_COMPLEMEN
      If Work1->WKNOTAOR <> cNumComp .OR. Work1->WKSERIEOR <> cSerieComp .Or. nItem >= EasyGParam("MV_NUMITEN")
         cNumComp   := WORK1->WKNOTAOR
         cSerieComp := WORK1->WKSERIEOR
         Return .T.
      Else
         Return .F.
      EndIf
   Else
      IF nItem >= EasyGParam("MV_NUMITEN") .OR.;
         cForn # Work1->WKFORN .OR. (EICLoja() .And. cLoja # Work1->WKLOJA) .OR.;   // GFP - 03/07/2013 - Quebra de NF por Loja de Fornecedor.
         nItem == 0 .OR. If(lQuebraCFO, cCFO # Work1->WK_CFO,.F.) .OR.; //RRV - 18/01/2013 - Incluida flag de quebra de nota por CFOP. (.T. = Quebra, .F. = Não quebra)
         (lIntDraw .AND. Work1->WKACMODAL # cACModal) .OR.;
         (lQuebraOperacao .AND. cOperacao # Work1->WK_OPERACA) .OR.;
         nAdicao > 99
         nAdicao := 0
         RETURN .t.
      ELSE
         RETURN .f.
      ENDIF
   EndIf
ELSE
   RETURN lQuebrou_NF
ENDIF

*-------------------------*
Function DI554CapQuebrou()  // Alex 11-05-2001  , Para que outras quebras possam ser feitas, via rdmake
*-------------------------*
PRIVATE lQuebra_Espe:=.F., lQuebrou_NF:=.F.

IF (EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,'Outra_Quebra'),)

IF ! lQuebra_Espe
   IF nNFE # Work1->WK_NFE  .OR. nSerie # Work1->WK_SE_NFE
     RETURN .T.
   ELSE
     RETURN .F.
   ENDIF
ENDIF

RETURN lQuebrou_NF
*-----------------------*
Function DI554CapNF()
*-----------------------*
LOCAL GRV,cChaveSF1
//Private cMv_ESPEIC := IF(cPaisLoc='BRA' ,EasyGParam("MV_ESPEIC",,'NFE'),'NF') // SVG - 06/07/2010 -
If nTipoNF # CUSTO_REAL
   IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"ANTES_GRV_SF1"),) // SVG - 06/07/2010 -
   cChaveSF1:=nNFE+nSerie+SA2->A2_COD+SA2->A2_LOJA+IF(nTipoNF=NFE_COMPLEMEN,"C","N")
   aCab := {}
   AADD(aCab,{"F1_TIPO"        ,IF(nTipoNF=NFE_COMPLEMEN,"C","N"),NIL})// TIPO DA NOTA - "N"ORMAL OU "C"OMPLEMENTAR
   AADD(aCab,{"F1_FORMUL"      ,cFormPro          ,NIL})   // FORMULARIO PROPRIO SIM OU NAO, CONF.OPCAO DO USUARIO
   AADD(aCab,{"F1_DOC"         ,nNFE              ,NIL})   // NUMERO DA NOTA
   AADD(aCab,{"F1_SERIE"       ,nSerie            ,NIL})   // SERIE DA NOTA
   AADD(aCab,{"F1_EMISSAO"     ,dDtNFE            ,NIL})   // DATA DA EMISSAO DA NOTA
   AADD(aCab,{"F1_FORNECE"     ,SA2->A2_COD       ,NIL})   // FORNECEDOR
   AADD(aCab,{"F1_LOJA"        ,SA2->A2_LOJA      ,NIL})   // LOJA DO FORNECEDOR
   //BHF-08/05/2009 - Inclusão do Parâmetro.
   AADD(aCab,{"F1_ESPECIE"     ,cMv_ESPEIC        ,NIL})   // NOTA FISCAL DE ENTRADA // SVG - 06/07/2010 -
   AADD(aCab,{"F1_DTDIGIT"     ,dDataBase         ,NIL})
//   AADD(aCab,{"F1_EST"         ,"EX"              ,NIL})
   AADD(aCab,{"F1_EST"         ,SA2->A2_EST       ,NIL}) // ISS - 09/05/11
   AADD(aCab,{"F1_TIPODOC"     ,IF(nTipoNF=NFE_COMPLEMEN,"13","10"),NIL})
   AADD(aCab,{"F1_TIPO_NF"     ,STR(nTipoNF,1,0)  ,NIL})
   AADD(aCab,{"F1_HAWB"        ,SW6->W6_HAWB      ,NIL})

   If !ComparaPeso (,nPesol,"F1_PESOL",.T.,)
      Return .F.
   EndIf

   AADD(aCab,{"F1_PESOL"       ,nPesol            ,NIL})

   AADD(aCab,{"F1_PLIQUI"     ,nPesol            ,Nil})//Peso Liquido

   //FSM - 02/09/2011 - Peso Bruto Unitario
   If lPesoBruto
      AADD(aCab,{"F1_PBRUTO"   ,nPesoB            ,NIL})
   EndIf

   AADD(aCab,{"F1_TRANSP"     ,SW6->W6_TRANS     ,Nil})//TRP - 09/08/12 - Envio da Transportadora

   AADD(aCab,{"F1_FOB_R"       ,nValor            ,NIL})
   AADD(aCab,{"F1_FRETE"       ,nFrete            ,NIL})
   AADD(aCab,{"F1_SEGURO"      ,nSeguro           ,NIL})
   AADD(aCab,{"F1_CIF"         ,nCIF              ,NIL})
   AADD(aCab,{"F1_II"          ,nII               ,NIL})
   AADD(aCab,{"F1_IPI"         ,nIPI              ,NIL})
   AADD(aCab,{"F1_ICMS"        ,nICMS             ,NIL})
   AADD(aCab,{"F1_DESPESA"     ,nDespesa          ,NIL})
   AADD(aCab,{"F1_CTR_NFC"     ,cNotaGrupo        ,Nil})

   //NCF - 22/10/2010 - Solicitado pela Microsiga
   If SA2->(FieldPos("A2_IMPIP")) <> 0 .And. EasyGParam("MV_INTACD",.F.,"0") == "1"
       AADD(aCab,{"AUTIMPIP"     ,1     ,Nil})  // ACD
   EndIf
   IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"GRAVACAO_SF1"),)

   IF EasyGParam("MV_EASY",,"N")=="S"
      MSExecAuto({|x,y| MATA140(x,y)},aCab,aItens)
      IF lMSErroAuto
         MostraErro()
         RETURN .F.
      ENDIF
      //FDR - 18/07/13
      IF EasyGParam("MV_TPNRNFS",,"1") == "2"
         ConfirmSX8()
      ENDIF
      IF (nPos:=ASCAN(aCab,{ |A| A[1]="F1_EST" } )) # 0
         SF1->(DBSETORDER(1))
         IF SF1->(DBSEEK(xFilial()+cChaveSF1))
            SF1->(RecLock("SF1",.F.))
            FOR GRV := nPos TO LEN(aCab)
                IF ( nPos:=SF1->( FIELDPOS(aCab[GRV,1]) ) ) # 0
                   SF1->( FIELDPUT(nPos,aCab[GRV,2]) )
                ENDIF
             NEXT
             IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"GRV_SF1"),)
             SF1->(MsUnlock())
         ELSE
             MSGSTOP(STR0038+": ["+cChaveSF1+"] "+STR0036,STR0022)
             lMSErroAuto:=.T.
         ENDIF
      ENDIF

   ELSE

      SF1->(RecLock("SF1",.T.))
      SF1->F1_FILIAL := xFilial("SF1")
      FOR GRV := 1 TO LEN(aCab)
          IF ( nPos:=SF1->( FIELDPOS(aCab[GRV,1]) ) ) # 0
             SF1->( FIELDPUT(nPos,aCab[GRV,2]) )
          ENDIF
      NEXT
      If lTemF1_DESPICM  .AND. !lMV_EASYSIM//So grava F1_DESPICM se nao eh integrado com a Microsiga
         //SF1->F1_DESPESA:= 0
         //SF1->F1_DESPICM:= nDespesa
         SF1->F1_DESPICM := nDespesaICM //ASK 16/01/2008
      Endif
      AADD( aEnv_NFS , SF1->(RECNO()) )
      IF AvFlags("EIC_EAI")//AWF -  REQ 6 11/06/2014
         SF1->F1_OK     := "0"
         SF1->F1_STATUS := "0"
      ENDIF
      IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"GRV_SF1"),)
      SF1->(MsUnlock())

   ENDIF

Else
   EI1->(RecLock("EI1",.T.))
   EI1->EI1_FILIAL   := xFilial("EI1")
   EI1->EI1_CIF      := nCIF
   EI1->EI1_DOC      := nNFE
   //EI1->EI1_SERIE    := nSerie
   SerieNfId("EI1",1,"EI1_SERIE",,,,nSerie)

   EI1->EI1_DTDIGI   := dDataBase
   EI1->EI1_DESPES   := nDespesa
   EI1->EI1_EMISSA   := dDtNFE
   EI1->EI1_FOB_R    := nValor
   EI1->EI1_FORNEC   := SA2->A2_COD
   EI1->EI1_FRETE    := nFrete
   EI1->EI1_HAWB     := SW6->W6_HAWB
   EI1->EI1_ICMS     := nICMS
   EI1->EI1_II       := nII
   EI1->EI1_IPI      := nIPI
   EI1->EI1_LOJA     := SA2->A2_LOJA
   EI1->EI1_PESOL    := nPesol
   EI1->EI1_SEGURO   := nSeguro
   EI1->EI1_SERIE    := nSerie
   EI1->EI1_TIPO_NF  := STR(nTipoNF,1,0)
   IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"GRV_EI1"),)
   EI1->(MsUnlock())
Endif

IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"GRAVA_SF1_EI1"),)

RETURN .T.
*-----------------------------------------------*
Function DI554Estorna()
*-----------------------------------------------*
LOCAL nCont:=0, lNFClassificada:=.F.,nOrdSF1:=SF1->(INDEXORD())
LOCAL aItem,aItens,aCab,aNotasCompDel,i,K
//NCF - 18/04/2012 - Tratamento do estorno das notas que já foram transmitidas ao Sefaz.
Local nHoras    := 0
Local nSpedExc  := GetNewPar("MV_SPEDEXC",72)
Local lTpOcor   := EDD->(FIELDPOS("EDD_CODOCO")) > 0 .And. EDD->(FIELDPOS("EDD_DESTIN")) > 0 //AOM - 22/06/2012 - Campos para gravação de Itens comprados na Anterioridade

Local dDtDigit 		:= dDataBase //TDF - 16/08/2012 - Ajuste com os novos campos de NFE

PRIVATE cFilSF1:=xFILIAL("SF1")
PRIVATE cFilSD1:=xFILIAL("SD1")
PRIVATE lOk:=.T.

If Type("lIntegrarEstorno") == "U"
   lIntegrarEstorno:= .T.
EndIf

bForSWD:={|| AT(SWD->(LEFT(SWD->WD_DESPESA,1)),"129") = 0 .AND.;
             EMPTY(cNota) .OR. cNota = SWD->WD_NF_COMP+SWD->WD_SE_NFC }

bForNota:={ || SF1->(DBSEEK(cFilSF1+SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA))) .AND.;
              (EMPTY(cNota) .OR. cNota == SF1->F1_CTR_NFC) }

IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,'ANTES_ESTORNO_NOTA'),)

If !lOk
   Return .F.
EndIf

IF AvFlags("EIC_EAI")//AWF -  REQ 6 11/06/2014

   /*
   For i = 1 To Len(aEnv_NFS)
       SF1->(DBGOTO(aEnv_NFS[I]))
       IF SF1->F1_STATUS = "1"
          SF1->(RECLOCK("SF1",.F.))
          SF1->F1_STATUS:="2"
          SF1->(MSUNLOCK())
       ENDIF
   Next
   */

   lOK:=.T.
   lPodeEstornar:= .T.
   lPrimeiraVez:=.T.
   lSolicitado := .F.
   For i = 1 To Len(aEnv_NFS)

      SF1->(DBGOTO(aEnv_NFS[I]))
      //wfs abr/2017 - opção de forçar o estorno do recebimento de importação, sem execução da integração via EAI
      If lIntegrarEstorno

         IF SF1->F1_STATUS == "1"
            lSolicitado := .T.
            If !EICNF100(.T.,5)//Na resposta coloca F1_STATUS := "3"

               lOK:=.F.
               EXIT

            ELSEIF lPrimeiraVez//Se 1 estorno der OK, tudo deve ser passado para SF1->F1_OK:="0"
               lPrimeiraVez:=.F.
               For K = 1 To Len(aEnv_NFS)
                   SF1->(DBGOTO(aEnv_NFS[K]))
                   SF1->(RECLOCK("SF1",.F.))
                   SF1->F1_OK:="0"
                   SF1->(MSUNLOCK())
               Next

            EndIf

         EndIf

      Else
         SF1->(RecLock("SF1", .F.))
         SF1->F1_STATUS:= "4" //Cancelamento forçado (não integrado ao ERP via EAI)
         SF1->(MsUnlock())
      EndIf

      lPodeEstornar := lPodeEstornar .AND. (SF1->F1_STATUS == "0" .OR. SF1->F1_STATUS == "3" .Or. SF1->F1_STATUS == "4")
   Next

   //Se todos os estornos derem OK, tudo deve ser passado para SF1->F1_OK:="1"
   If lOk
      For I = 1 To Len(aEnv_NFS)
         SF1->(DBGOTO(aEnv_NFS[I]))
         SF1->(RECLOCK("SF1",.F.))
         SF1->F1_OK:="1"
         SF1->(MSUNLOCK())
      Next
   EndIf

   //If lOK
   If !lOk
      MsgInfo(STR0369, STR0368) //"Não foi possível estornar a nota fiscal. Tente novamente após a realização dos ajustes necessários.", "Aviso"
      Return .F.

   ElseIf lPodeEstornar
     //igor chiba 02/04/14 ESTORNAR CONTABILIZACAO
     IF EasyGParam('MV_EIC_ECO',,.F.) == 'N' .AND. EasyGParam('MV_EIC0047',,.F.) .AND. (nTipoNF==NFE_PRIMEIRA .OR. nTipoNF==NFE_UNICA .Or.  nTipoNF == NFE_MAE) .And. FindFunction("L500RETREG")
        //aRegs:=L500RETREG(SW6->W6_FILIAL,SW6->W6_HAWB,"'201','501','504'",'TN') //comentado por wfs
        aRegs:=L500RETREG(SW6->W6_FILIAL,SW6->W6_HAWB,"'201','211','501','512','504','513'",'TN') //processos sem cobertura cambial
        L500CANCTB(aRegs)
     ENDIF

//    ConOut("Integrado com Sucesso","LOGIX")

   ElseIf lSolicitado

	  MsgInfo(STR0370, STR0368) //"Solicitação de estorno enviada ao ERP. Aguarde a autorização da SEFAZ e tente novamente o estorno da nota fiscal.", "Aviso"
      RETURN .F.

   Else
	  MsgInfo(STR0371, STR0368) //"Estorno não é possível enquanto existirem NF integradas no ERP. Aguarde a autorização da SEFAZ e tente novamente o estorno da nota fiscal.", "Aviso"
      RETURN .F.

   ENDIF

   aEnv_NFS:= {}

ENDIF

lMV_EASYSIM:= EasyGParam("MV_EASY",,"N")=="S"
lMSErroAuto := .F.
lMSHelpAuto := .F.

IF nTipoNF # CUSTO_REAL

   ProcRegua(2)

   IncProc(STR0132) //"Verificando Processo, Aguarde..."

   If lIntDraw .and. cAntImp == "1"
      EDD->(dbSetOrder(2))
      If !EasyGParam("MV_EDC0009",,.F.) .And. EDD->(dbSeek(xFilial("EDD")+SW6->W6_HAWB))
         Do While !EDD->(EOF()) .and. EDD->EDD_FILIAL==xFilial("EDD") .and. EDD->EDD_HAWB==SW6->W6_HAWB
            If (!Empty(EDD->EDD_PREEMB).Or. !Empty(EDD->EDD_PEDIDO) .Or. (lTpOcor .And. !Empty(EDD->EDD_CODOCO)) ) //AOM - 23/11/2011 - Tratamento para considerar Vendas para exportadores.
               MsgInfo(STR0339) //STR0339 "Nota Fiscal não pode ser estornada pois tem itens ligados a REs de acordo com a anterioridade (Drawback)."
               EDD->(dbSetOrder(1))
               Return
            EndIf
            EDD->(dbSkip())
         EndDo
      EndIf
   EndIf

   SF1->(DBSETORDER(5))
   SF1->(DBSEEK(cFilSF1+SW6->W6_HAWB+STR(nTipoNF,1,0)))

   //TDF - 16/08/2012 - Ajuste com os novos campos de NFE
   dDtdigit 	:= IIf(SF1->(FieldPos('F1_DTDIGIT'))>0 .And. !Empty(SF1->F1_DTDIGIT),SF1->F1_DTDIGIT,SF1->F1_EMISSAO)

   //NCF - 18/04/2012 -  Tratamento do estorno das notas que já foram transmitidas ao Sefaz.
   IF lMV_EASYSIM
      If SF1->F1_FORMUL == "S" .And. "SPED" $ SF1->F1_ESPECIE .And. SF1->(FieldPos("F1_FIMP"))>0 .And. SF1->F1_FIMP $ "TS" //verificacao apenas da especie como SPED e notas que foram transmitidas ou impresso o DANFE
         //TDF - 08/08/12 - Ajuste com os novos campos de NFE
         nHoras := SubtHoras(IIF(SF1->(FieldPos("F1_DAUTNFE")) <> 0 .And. !Empty(SF1->F1_DAUTNFE),SF1->F1_DAUTNFE,dDtdigit),IIF(SF1->(FieldPos("F1_HAUTNFE")) <> 0 .And. !Empty(SF1->F1_HAUTNFE),SF1->F1_HAUTNFE,SF1->F1_HORA), dDataBase, substr(Time(),1,2)+":"+substr(Time(),4,2) )
         If nHoras > nSpedExc .And. SF1->F1_STATUS<>"C"
            MsgAlert(STR0358 + Alltrim(STR(nSpedExc)) +STR0359) //STR0368 "Não foi possivel excluir a(s) nota(s), pois o prazo para o cancelamento da(s) NF-e é de " //STR0369 " horas"
            Return
         EndIf
      EndIf
   ENDIF
   SF1->(DBEVAL({||++nCont},,{||cFilSF1         == SF1->F1_FILIAL  .AND.;
                                SF1->F1_HAWB    == SW6->W6_HAWB    .AND.;
                                SF1->F1_TIPO_NF == STR(nTipoNF,1,0)}))


   ProcRegua(nCont+3)

   IncProc(STR0157) //"Estornando Nota Fiscal"

   SD1->(DBSETORDER(1))
   SF1->(DBSETORDER(5))


   Begin Transaction

   aItens:={}
   aNotasCompDel:={}
   SF1->(DBSEEK(cFilSF1+SW6->W6_HAWB+STR(nTipoNF,1,0)))

   DO WHILE SF1->(!EOF())                   .AND.;
         SF1->F1_FILIAL  == cFilSF1         .AND.;
         SF1->F1_HAWB    == SW6->W6_HAWB    .AND.;
         SF1->F1_TIPO_NF == STR(nTipoNF,1,0)

      IncProc(STR0157) //"Estornando Nota Fiscal"

      aItens:={}  // GFP - 15/02/2016

      IF !EMPTY(cNota) .AND. cNota # SF1->F1_CTR_NFC
         SF1->(DBSKIP())
         LOOP
      ENDIF

      IF EMPTY(SF1->F1_STATUS)
         lNFClassificada := .F.
      ELSE
         lNFClassificada := .T.
      ENDIF

      IF EasyEntryPoint("EICPDI01")
         IF !ExecBlock("EICPDI01",.F.,.F.,"ESTORNO NA NOTA")
            LOOP
         ENDIF
      ENDIF
      lOk:=.T.
      IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,'ESTORNO NA NOTA'),)

      IF !lOk
         LOOP
      ENDIF
      //RHP
      SD1->(DBSEEK(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))

      DO WHILE SD1->(!EOF())                 .AND.;
            SD1->D1_FILIAL == xFilial("SD1") .AND.;
            SD1->D1_DOC    == SF1->F1_DOC    .AND.;
            SD1->D1_SERIE  == SF1->F1_SERIE  .AND.;
            SD1->D1_FORNECE== SF1->F1_FORNECE.AND.;
            SD1->D1_LOJA   == SF1->F1_LOJA

         IF SD1->D1_TIPO_NF # STR(nTipoNF,1,0) .OR.;
            SD1->D1_CONHEC  # SW6->W6_HAWB
            SD1->(DBSKIP())
            LOOP
         ENDIF

         IF lMV_EASYSIM
            aItem:={}
            AADD(aItem,{"D1_DOC"    ,SD1->D1_DOC    ,NIL})
            AADD(aItem,{"D1_SERIE"  ,SD1->D1_SERIE  ,NIL})
            AADD(aItem,{"D1_FORNECE",SD1->D1_FORNECE,NIL})
            AADD(aItem,{"D1_LOJA"   ,SD1->D1_LOJA   ,NIL})
            AADD(aItens,ACLONE(aItem))
         ELSE
            SD1->(RecLock("SD1",.F.,.T.))
            SD1->(DBDELETE())
            SD1->(MsUnlock())
         ENDIF
         SD1->(DbSkip())

      ENDDO

      If lIntDraw .and. cAntImp == "1"
         EDD->(dbSetOrder(2))
      EndIf

      AADD(aNotasCompDel,SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)

      IF lMV_EASYSIM
         aCab := {}
         AADD(aCab,{"F1_DOC"    ,SF1->F1_DOC    ,NIL})   // NUMERO DA NOTA
         AADD(aCab,{"F1_SERIE"  ,SF1->F1_SERIE  ,NIL})   // SERIE DA NOTA
         AADD(aCab,{"F1_FORNECE",SF1->F1_FORNECE,NIL})   // FORNECEDOR
         AADD(aCab,{"F1_LOJA"   ,SF1->F1_LOJA   ,NIL})   // LOJA DO FORNECEDOR
         AADD(aCab,{"F1_TIPO"   ,SF1->F1_TIPO   ,NIL})   // TIPO DA NF
         nRecno:=SF1->(RECNO())
         IF lNFClassificada
            MSExecAuto({|x,y,z| MATA103(x,y,z)},aCab,aItens,20)
         ELSE
            MSExecAuto({|x,y,z| MATA140(x,y,z)},aCab,aItens,5)
         ENDIF
         SF1->(DBGOTO(nRecno))
         IF lMSErroAuto
            RollBackDelTran("")                               //NCF - 23/04/2012 - Restaurar a integridade dos dicionários do SIGAEIC caso não seja realizado estorno
            EXIT                                              //                   pelo SIGACOM.
         ENDIF
      ELSE
         SF1->(RecLock("SF1",.F.,.T.))
         SF1->(DBDELETE())
         SF1->(MsUnlock())
      ENDIF

      SF1->(DbSkip())

   ENDDO

   IF !lMSErroAuto

      IncProc(STR0157) //"Estornando Nota Fiscal"

      nTotNFC := 0
      SWN->(DBSETORDER(3))
 	  IF SWN->(DBSEEK(xFilial("SWN")+SW6->W6_HAWB+STR(nTipoNF,1,0))) .AND. !lMSErroAuto
    	  DO WHILE SWN->(!EOF())                   .AND.;
        	       SWN->WN_FILIAL == xFilial("SWN").AND.;
            	   SWN->WN_HAWB   == SW6->W6_HAWB  .AND.;
	               SWN->WN_TIPO_NF== STR(nTipoNF,1,0)

    	     IF ASCAN(aNotasCompDel,SWN->WN_DOC+SWN->WN_SERIE+SWN->WN_FORNECE+SWN->WN_LOJA) = 0
		        // Bete 10/08/05 - soma os valores das demais notas complementares
			    If nTipoNF==NFE_COMPLEMEN
		   	       nTotNFC := nTotNFC + SWN->WN_VALOR
		      	EndIf

        	    SWN->(DBSKIP())
            	LOOP
	         ENDIF

	         If lIntDraw .and. cAntImp == "1"
    	        DIGrvAnt(2,SWN->WN_HAWB,SWN->WN_PO_EIC,SWN->WN_INVOICE,SWN->WN_PRODUTO,SWN->WN_ITEM,SWN->WN_PGI_NUM)
        	 EndIf

	         SWN->(RecLock("SWN",.F.,.T.))
    	     If nTipoNF # NFE_COMPLEMEN
	    	     MaAvalPC("SC7",11) // Edu -> Cancela a baixa o Pedido de Compra feito até a versão 6.09
	         EndIf
    	     SWN->(DBDELETE())
        	 SWN->(MsUnlock())
	         SWN->(DbSkip())
    	  ENDDO
	      If lIntDraw .and. cAntImp == "1"
    	     EDD->(dbSetOrder(1))
	      EndIf
	  ENDIF

      SW6->(RecLock("SW6",.F.))

      If nTipoNF==NFE_PRIMEIRA .OR. nTipoNF==NFE_UNICA .OR. (lMV_NF_MAE .And. nTipoNF == NFE_MAE)
         SW6->W6_NF_ENT  :=""
         //SW6->W6_SE_NF   :=""
		 SerieNfId("SW6",1,"W6_SE_NF",CTod("  /  /  "),"","","")

         SW6->W6_DT_NF   :=AVCTOD("")
         SW6->W6_VL_NF   :=0
         SW6->W6_DT_ENTR :=AVCTOD("")
      Endif


//    IF nTipoNF==NFE_COMPLEMEN .OR. nTipoNF==NFE_UNICA
      IF nTipoNF # CUSTO_REAL
         If nTipoNF==NFE_COMPLEMEN
            SF1->(DBSETORDER(5))
            IF SF1->(DBSEEK(cFilSF1+SW6->W6_HAWB+STR(nTipoNF,1,0)))
               SW6->W6_NF_COMP:=SF1->F1_DOC
               //SW6->W6_SE_NFC :=SF1->F1_SERIE
			   SerieNfId("SW6",1,"W6_SE_NFC",,,,SF1->F1_SERIE)

               SW6->W6_DT_NFC :=SF1->F1_EMISSAO
               SW6->W6_VL_NFC :=nTotNFC
            ELSE
               SW6->W6_NF_COMP:=""
               //SW6->W6_SE_NFC :=""
			   SerieNfId("SW6",1,"W6_SE_NFC",CTod("  /  /  "),"","","")

               SW6->W6_DT_NFC :=AVCTOD("")
               SW6->W6_VL_NFC :=0
            ENDIF

         ENDIF

         IF nTipoNF # NFE_FILHA//LGS-25/04/2015 - Qdo for NF Filha não devo apagar a referencia do nro da NF que foi gerado pela NF Mãe.
	        SWD->(DBSEEK(xFilial("SWD")+SW6->W6_HAWB))
	        DO WHILE SWD->(!EOF())              .AND.;
	              SWD->WD_FILIAL==xFilial("SWD").AND.;
	              SWD->WD_HAWB  == SW6->W6_HAWB

	           //NCF - 13/09/2010 - Para limpar número na nota quando é imposto integrado pelo despachante
	           //TDF - 06/01/2010 - Revisão do tratamento para gravar o número da nota
	           IF SYB->(DbSeek(xFilial("SYB")+SWD->WD_DESPESA )) .AND. (LEFT(SWD->WD_DESPESA,1) $ "12") .AND. !lTipoCompl//SWD->WD_INTEGRA
	              SWD->(RecLock("SWD",.F.))
	              SWD->WD_NF_COMP:= ""
	              //SWD->WD_SE_NFC := "" //LGS-05/08/2016
	              SerieNfId("SWD",1,"WD_SE_NFC",CTod("  /  /  "),"","","")
	              SWD->(MsUnlock())
	           ENDIF
	           IF EVAL(bForSWD)//AT(SWD->(LEFT(SWD->WD_DESPESA,1)),"129")=0.AND.cNota = SWD->WD_NF_COMP+SWD->WD_SE_NFC

	              SWD->(RecLock("SWD",.F.))
	              SWD->WD_NF_COMP:=""
	              //SWD->WD_SE_NFC :="" //LGS-05/08/2016
	              SerieNfId("SWD",1,"WD_SE_NFC",CTod("  /  /  "),"","","")
	              SWD->WD_DT_NFC :=AVCTOD("")
	              SWD->WD_VL_NFC :=0
	              SWD->(MsUnlock())

	           ENDIF

	           SWD->(DBSKIP())
	        ENDDO
		 ENDIF
      ENDIF

      SW6->(MsUnlock())

	  SWW->(DBSETORDER(2))
	  IF SWW->(DBSEEK(Xfilial("SWW")+SW6->W6_HAWB+STR(nTipoNF,1,0))) .AND. !lMSErroAuto
    	 DO WHILE !SWW->(EOF())                    .AND.;
         	       SWW->WW_FILIAL == xFilial("SWW").AND.;
      			   SWW->WW_HAWB   == SW6->W6_HAWB  .AND.;
                   SWW->WW_TIPO_NF== STR(nTipoNF,1,0)

	        IF ASCAN(aNotasCompDel,SWW->WW_NF_COMP+SWW->WW_SE_NFC+SWW->WW_FORNECE+SWW->WW_LOJA) = 0
    	       SWW->(DBSKIP())
        	   LOOP
	        ENDIF

    	    SWW->(RecLock("SWW",.F.,.T.))
        	SWW->(DBDELETE())
	        SWW->(MsUnlock())
    	    SWW->(DbSkip())
         ENDDO
      ENDIF
   ENDIF

   End Transaction

      If AvFlags("EIC_EAI") .And. lPodeEstornar
       IF AvFlags("EAI_PGANT_INV_NF") .AND. (nTipoNF==NFE_PRIMEIRA .OR. nTipoNF==NFE_UNICA .Or.  nTipoNF == NFE_MAE)
          IF EICAP112(.T.,3,SW6->W6_HAWB,,,"1",.T.) //Se estornar com sucesso, envia a "deleção" dos titulos
             EICAP110(.T., 5, SW6->W6_HAWB, "D", "1", .T., "1",,, .T.)
          ENDIF
       ENDIF
   EndIf

ELSE

   ProcRegua(2)

   EI1->(DBSETORDER(1))
   EI1->(DBSEEK( xFilial("EI1") + SW6->W6_HAWB ))

   IncProc(STR0158) //"Estornando Custo..."

   EI1->(DBEVAL({||++nCont},,{||xFilial("EI1") == EI1->EI1_FILIAL .AND.;
                                EI1->EI1_HAWB  == SW6->W6_HAWB}))

   IncProc(STR0158) //"Estornando Custo..."

   ProcRegua(nCont+3)

   EI1->(DBSEEK( xFilial("EI1") + SW6->W6_HAWB ))

Begin Transaction

   DO WHILE ! EI1->(EOF())                      .AND.;
              EI1->EI1_FILIAL == xFilial("EI1") .AND.;
              EI1->EI1_HAWB   == SW6->W6_HAWB

      IncProc(STR0158) //"Estornando Custo..."

      IF EI1->EI1_TIPO_NF # STR( nTipoNF,1, 0 )
         EI1->(DBSKIP())
         LOOP
      ENDIF

      EI1->(RecLock("EI1",.F.,.T.))
      EI1->(DBDELETE())
      EI1->(MsUnlock())
      EI1->(DbSkip())

   ENDDO

   EI2->(DBSETORDER(1))
   EI2->(DBSEEK(xFilial("EI2")+SW6->W6_HAWB))
   IncProc(STR0158) //"Estornando Custo..."

   DO WHILE ! EI2->(EOF())                      .AND.;
              EI2->EI2_FILIAL == xFilial("EI2") .AND.;
              EI2->EI2_HAWB   == SW6->W6_HAWB

      IF EI2->EI2_TIPO_NF # STR( nTipoNF,1, 0 )
         EI2->(DBSKIP())
         LOOP
      ENDIF
      EI2->(RecLock("EI2",.F.,.T.))
      EI2->(DBDELETE())
      EI2->(MsUnlock())
      EI2->(DbSkip())
   ENDDO

   EI3->(DBSETORDER(1))
   EI3->(DBSEEK( xFilial("EI3") + SW6->W6_HAWB ))
   IncProc(STR0158) //"Estornando Custo..."

   DO WHILE ! EI3->(EOF())                      .AND.;
              EI3->EI3_FILIAL == xFilial("EI3") .AND.;
              EI3->EI3_HAWB   == SW6->W6_HAWB

      IF EI3->EI3_TIPO_NF # STR( nTipoNF,1, 0 )
         EI3->(DBSKIP())
         LOOP
      ENDIF

      EI3->(RecLock("EI3",.F.,.T.))
      EI3->(DBDELETE())
      EI3->(MsUnlock())
      EI3->(DbSkip())
   ENDDO

   SWW->(DBSETORDER(2))
   IF SWW->(DBSEEK(Xfilial("SWW")+SW6->W6_HAWB+STR(nTipoNF,1,0))) .AND. !lMSErroAuto
      DO WHILE !SWW->(EOF())                    .AND.;
                SWW->WW_FILIAL == xFilial("SWW").AND.;
                SWW->WW_HAWB   == SW6->W6_HAWB  .AND.;
                SWW->WW_TIPO_NF== STR(nTipoNF,1,0)

         SWW->(RecLock("SWW",.F.,.T.))
         SWW->(DBDELETE())
         SWW->(MsUnlock())
         SWW->(DbSkip())
      ENDDO
   ENDIF

End Transaction

ENDIF

SF1->(DBSETORDER(nOrdSF1))
SWN->(DBSETORDER(1))
SWW->(DBSETORDER(1))

IncProc() //100%

IF lMSErroAuto
   MostraErro()
   RETURN .F.
ELSE
   //igor chiba 02/07/14 estornar contabilizacao
   IF !AvFlags("EIC_EAI") .AND. EasyGParam('MV_EIC_ECO',,.F.) == 'N' .AND. EasyGParam('MV_EIC0047',,.F.) .AND. (nTipoNF==NFE_PRIMEIRA .OR. nTipoNF==NFE_UNICA .Or.  nTipoNF == NFE_MAE) .And. FindFunction("L500RETREG")
      //aRegs:=L500RETREG(SW6->W6_FILIAL,SW6->W6_HAWB,"'201','501','504'",'TN') //comentado por wfs
      aRegs:=L500RETREG(SW6->W6_FILIAL,SW6->W6_HAWB,"'201','211','501','512','504','513'",'TN') //processos sem cobertura cambial
      L500CANCTB(aRegs)
   ENDIF
ENDIF

RETURN .T.
*-------------------------*
STATIC Function DITrans(nVal,nDec)
*-------------------------*
return VAL(STR(nVal,30,nDec))

*---------------------------------------------------------------------*
Function DI554ProcEIB(lGrava,nSNAliq,nSNPeso,nSNAcreDedu)
*---------------------------------------------------------------------*
LOCAL nCont:=0, nFatorFrete:=1,lExistiaReg:=.F.,cFil:=xFilial("EIB")

IF !lEIB_Processa .OR. (lGrava .AND. !lAlterouAliquotas)
   RETURN .F.
ENDIF

DBSELECTAREA("EIB")
DBSETORDER(1)
Work1->(DBSETORDER(1))
lExistiaReg:=EIB->(DBSEEK(xFilial("EIB")+SW6->W6_HAWB))
ProcRegua(Work2->(LASTREC()))
Work2->(DBGOTOP())

DO WHILE Work2->(!EOF())

   IncProc(STR0268+' '+Work2->WKTEC) //"Processando NCM: "

   IF lGrava
      nCont++
      IF EIB->(DBSEEK(xFilial("EIB")+SW6->W6_HAWB+Work2->WK_CFO+Work2->WK_OPERACA+Work2->WKTEC+Work2->WKEX_NCM+Work2->WKEX_NBM))
         EIB->(RECLOCK("EIB",.F.))
         EIB->EIB_PESO  :=Work2->WKPESOL
         EIB->EIB_PERII :=Work2->WKII_A
         EIB->EIB_PERIPI:=Work2->WKIPI_A
         EIB->EIB_PERICM:=Work2->WKICMS_A
         IF EIB->(FIELDPOS("EIB_VLACRE")) # 0 .AND. EIB->(FIELDPOS("EIB_VLACRE")) # 0  //NCF - Gravação dos valores de Acrescimos e Deduções
            EIB->EIB_VLACRE := Work2->WKVLACRES
            EIB->EIB_VLDEDU := Work2->WKVLDEDUC
         ENDIF
         EIB->EIB_FILLER:="ALTERADO"
         EIB->(MSUNLOCK())
      ELSE
         EIB->(RECLOCK("EIB",.T.))
         EIB->EIB_FILIAL:=xFilial("EIB")
         EIB->EIB_HAWB  :=SW6->W6_HAWB
         EIB->EIB_POSIPI:=Work2->WKTEC
         EIB->EIB_EX_NCM:=Work2->WKEX_NCM
         EIB->EIB_EX_NBM:=Work2->WKEX_NBM
         EIB->EIB_PESO  :=Work2->WKPESOL
         EIB->EIB_PERII  :=Work2->WKII_A
         EIB->EIB_PERIPI :=Work2->WKIPI_A
         EIB->EIB_PERICM:=Work2->WKICMS_A
         EIB->EIB_CFO   :=Work2->WK_CFO
         EIB->EIB_OPERA :=Work2->WK_OPERACA
         IF EIB->(FIELDPOS("EIB_VLACRE")) # 0 .AND. EIB->(FIELDPOS("EIB_VLACRE")) # 0  //NCF - Gravação dos valores de Acrescimos e Deduções
            EIB->EIB_VLACRE := Work2->WKVLACRES
            EIB->EIB_VLDEDU := Work2->WKVLDEDUC
         ENDIF
         IF(lExistiaReg,EIB->EIB_FILLER:="INCLUIDO",)
         EIB->(MSUNLOCK())
      ENDIF
   ELSE
      IF EIB->(DBSEEK(xFilial("EIB")+SW6->W6_HAWB+Work2->WK_CFO+Work2->WK_OPERACA+Work2->WKTEC+Work2->WKEX_NCM+Work2->WKEX_NBM))
         IF nSNAliq == 1
            Work2->WKII_A  := EIB->EIB_PERII
            Work2->WKIPI_A := EIB->EIB_PERIPI
            Work2->WKICMS_A:= EIB->EIB_PERICM
         ENDIF
         If nSNAcreDedu == 1
            If EIB->(FIELDPOS("EIB_VLACRE")) # 0 .AND. EIB->(FIELDPOS("EIB_VLACRE")) # 0  //NCF - Gravação dos valores de Acrescimos e Deduções
               Work2->WKVLACRES := EIB->EIB_VLACRE
               Work2->WKVLDEDUC := EIB->EIB_VLDEDU
            EndIf
         EndIf
         IF nSNPeso == 1
            MDI_PESO       -= Work2->WKPESOL
            MDI_PESO       += EIB->EIB_PESO
            nFatorFrete    := EIB->EIB_PESO / Work2->WKPESOL
            Work2->WKPESOL := EIB->EIB_PESO
            Work1->(DBSEEK(Work2->WKADICAO+Work2->WK_CFO+Work2->WK_OPERACA+Work2->WKTEC+Work2->WKEX_NCM+Work2->WKEX_NBM))
            DO WHILE Work1->WK_CFO     ==  Work2->WK_CFO     .AND. ;
                     Work1->WKADICAO   ==  Work2->WKADICAO   .AND. ;
                     Work1->WK_OPERACA ==  Work2->WK_OPERACA .AND. ;
                     Work1->WKTEC      ==  Work2->WKTEC      .AND. ;
                     Work1->WKEX_NCM   ==  Work2->WKEX_NCM   .AND. ;
                     Work1->WKEX_NBM   ==  Work2->WKEX_NBM   .AND. Work1->(!EOF())
               Work1->WKPESOL := Work1->WKPESOL * nFatorFrete
               Work1->(DBSKIP())
            ENDDO
         ENDIF
      ENDIF
   ENDIF
   Work2->(DBSKIP())
ENDDO

IF lGrava .AND. lExistiaReg
   ProcRegua(nCont)
   EIB->(DBSEEK(cFil+SW6->W6_HAWB))
   DO WHILE EIB->EIB_HAWB  ==SW6->W6_HAWB .AND. EIB->(!EOF()).AND.;
            EIB->EIB_FILIAL==cFil

      EIB->(RECLOCK("EIB",.F.))
      IF !EMPTY(EIB->EIB_FILLER)
         IncProc(STR0268+' '+EIB->EIB_POSIPI) //"Processando NCM: "
         EIB->EIB_FILLER:=""
         EIB->(MSUNLOCK())
      ELSE
         EIB->(DBDELETE())
             ENDIF
      EIB->(DBSKIP())
   ENDDO
ENDIF

RETURN .T.

*---------------------------------------------------------------------*
Function DI554MsgDif(lBox,nDI,nNBM,cTit,cMsg)
*---------------------------------------------------------------------*
LOCAL  lRet:=.F.,cObs:="",nLin:=0,oDlg
STATIC cObsII,cObsIPI,cObsICMS,cObsPIS,cObsCOF
DEFAULT cMsg := ""
DEFAULT cTit := ""
DEFAULT nDI  := 0
DEFAULT nNBM := 0

IF !lBox

   IF VAL(STR(nDI,18,2)) # VAL(STR(nNBM,18,2))
          cObs:=cTit+STR0269+AllTrim(TRANS(nDI ,"@E 99,999,999,999,999.99"))+; //" informado (R$ "
                 STR0270+AllTrim(TRANS(nNBM,"@E 99,999,999,999,999.99"))+")" //") difere do calculado (R$ "
          lRet:=.T.
   ENDIF

   IF(!EMPTY(cMsg),cObs:=cMsg,)

   DO CASE
      CASE cTit == "I.I."     ;  cObsII   := cObs
      CASE cTit == "I.P.I."   ;  cObsIPI  := cObs
      CASE cTit == "I.C.M.S." ;  cObsICMS := cObs
      CASE cTit == "PIS"      ;  cObsPIS  := cObs
      CASE cTit == "COFINS"   ;  cObsCOF  := cObs
   ENDCASE

ELSEIF (cObsII   # NIL .AND. !EMPTY(cObsII  )) .OR.;
       (cObsIPI  # NIL .AND. !EMPTY(cObsIPI )) .OR.;
       (cObsPIS  # NIL .AND. !EMPTY(cObsPIS )) .OR.;
       (cObsCOF  # NIL .AND. !EMPTY(cObsCOF )) .OR.;
       (cObsICMS # NIL .AND. !EMPTY(cObsICMS))

   DEFINE MSDIALOG oDlg FROM  0,0 TO 11,60 TITLE STR0271 OF oMainWnd //"Visualização das Diferenças"

   nLin:=0
   nLin2:=40

   If !Empty(cObsII)
      nLin:=nLin+08
          @ nLin,010 SAY cObsII   SIZE 200,8 OF oDlg PIXEL
   EndIf
   If !Empty(cObsIPI)
      nLin:=nLin+10
          @ nLin,010 SAY cObsIPI  SIZE 200,8 OF oDlg PIXEL
   EndIf

   If !Empty(cObsICMS)
      nLin:=nLin+10
          @ nLin,010 SAY cObsICMS SIZE 200,8 OF oDlg PIXEL
   EndIf

   IF lMV_PIS_EIC
      If !Empty(cObsPIS)
         nLin:=nLin+10
         @ nLin,010 SAY cObsPIS  SIZE 200,8 OF oDlg PIXEL
      EndIf
      If !Empty(cObsCOF)
         nLin:=nLin+10
         @ nLin,010 SAY cObsCOF  SIZE 200,8 OF oDlg PIXEL
      EndIf
      nLin2:=60
   EndIf

   @ 002,005 TO nLin2,220 LABEL "" OF oDlg PIXEL

   DEFINE SBUTTON FROM 065,180 TYPE 1 ACTION (oDlg:End()) ENABLE OF oDlg PIXEL

   ACTIVATE MSDIALOG oDlg CENTERED

 ENDIF

RETURN lRet

*------------------------------*
FUNCTION DI554TabDes(aDespesa)
*------------------------------*
LOCAL nPos:= ASCAN(aDespesa,{|Desp|Desp[1]==SWD->WD_DESPESA})

lSair:=.F.
IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"TAB_DESPESAS"),)
IF lSair
   RETURN NIL
ENDIF

IF nPos==0
   AADD(aDespesa,{SWD->WD_DESPESA,SWD->WD_VALOR_R,0,SWD->(RECNO()),0,0})
ELSE
   aDespesa[nPos,2]+=SWD->WD_VALOR_R
   aDespesa[nPos,6]+=SWD->WD_VALOR_R / IF(BuscaTaxa(cMoeDolar,SWD->WD_DES_ADI,.T.,.F.,.T.)#0,BuscaTaxa(cMoeDolar,SWD->WD_DES_ADI,.T.,.F.,.T.),1)
ENDIF

RETURN NIL

*------------------------------*
FUNCTION DI554Valid(cQual)
*------------------------------*
IF !lGeraNF
   Return .T.
ENDIF

DO CASE
   CASE cQual = "NFE"
        If Empty(cNumNFE)
           Help("",1,"AVG0000809")
//         MSGINFO((0252),0022) //"Numero da N.F. nao informado"###"Atenção"
           Return .F.
        Endif

   CASE cQual = "SERIE"
        SF1->(DBSETORDER(1))
        If SF1->(DbSeek(xFilial("SF1")+cNumNFE+cSerieNFE))//+Work1->WKFORN+Work1->WKLOJA)) - AWR 05/02/2004
           lMensagem:=.F.
           DO WHILE SF1->(!EOF()) .AND. SF1->F1_FILIAL = xFilial("SF1") .AND. SF1->F1_DOC = cNumNFE .AND. SF1->F1_SERIE = cSerieNFE
              IF !EMPTY(SF1->F1_HAWB)
                 lMensagem:=.T.
                 EXIT
              ENDIF
              SF1->(DBSKIP())
           ENDDO
           IF lMensagem
              Help("",1,"AVG0000810")//"Numero da N.F. e da Serie ja cadastrados no sistema."###"Atenção"
              Return .F.
           ENDIF
        Endif

   CASE cQual = "DATA"
        If Empty(dDtNFE)
           Help("",1,"AVG0000811")
//         MsgInfo(257,0022) //"Data da N.F. não Preenchida"###"Atenção"
           Return .F.
        Endif
EndCase

Return .T.

*-------------------------*
Function DI554Pesquisa()
*-------------------------*
LOCAL nOpca  :=0, oDlgPeq
LOCAL nRecno :=Work1->(RECNO())
LOCAL nOrder :=Work1->(INDEXORD())
LOCAL cCFO   :=Work1->WK_CFO
LOCAL cAdicao:=Work1->WKADICAO
LOCAL cOpera :=Work1->WK_OPERACA
LOCAL cTec   :=Work1->WKTEC
LOCAL cNcm   :=Work1->WKEX_NCM
LOCAL cNbm   :=Work1->WKEX_NBM
LOCAL cItem  :=Work1->WKCOD_I
LOCAL cChave :=cAdicao+cCFO+cOpera+cTec+cNcm+cNbm+cItem
LOCAL nCo1   :=04
LOCAL nCo2   :=40
LOCAL nLin   :=05

DEFINE MSDIALOG oDlgPeq TITLE STR0258 From 0,0 To 15,35 OF oMainWnd //"Pesquisa Chave"

@nLin,nCo1 SAY STR0290 SIZE 25,8 PIXEL //"Adicao"
@nLin,nCo2 MSGET cAdicao  SIZE 50,8 PIXEL

nLin+=12
@nLin,nCo1 SAY STR0039  SIZE 25,8 PIXEL
@nLin,nCo2 MSGET cCFO   SIZE 50,8 PIXEL

nLin+=12
@nLin,nCo1 SAY STR0305 SIZE 25,8 PIXEL //"Operacao"
@nLin,nCo2 MSGET cOpera SIZE 50,8 PIXEL F3 "SWZ"

nLin+=12
@nLin,nCo1 SAY STR0306    SIZE 25,8 PIXEL //"TEC"
@nLin,nCo2 MSGET cTec   SIZE 52,8 PIXEL F3 "SYD"  PICTURE "@R 9999.99.99"

nLin+=12
@nLin,nCo1 SAY STR0307 SIZE 25,8 PIXEL //"EX-NCM"
@nLin,nCo2 MSGET cNcm   SIZE 50,8 PIXEL F3 "WD2"

nLin+=12
@nLin,nCo1 SAY STR0308 SIZE 25,8 PIXEL //"EX-NBM"
@nLin,nCo2 MSGET cNbm   SIZE 50,8 PIXEL F3 "WD3"

nLin+=12
@nLin,nCo1 SAY STR0054 SIZE 25,8 PIXEL //"Cod. Item"
@nLin,nCo2 MSGET cItem  SIZE 50,8 PIXEL F3 "SB1"

@ 10,100 BUTTON STR0111 SIZE 30,11 ACTION (nOpca:=1,If(DI554ValPesq(cAdicao,cTec,cItem),oDlgPeq:End(),)) OF oDlgPeq PIXEL //"&OK"   // GFP - 09/10/2012
@ 30,100 BUTTON STR0103 SIZE 30,11 ACTION (nOpca:=0,oDlgPeq:End()) OF oDlgPeq PIXEL //"&Sair"

ACTIVATE MSDIALOG oDlgPeq CENTERED

If nOpcA = 0
   RETURN .F.
Endif
cChave:=cAdicao+cCFO+cOpera+cTec/*+"  "*/+cNcm+cNbm+cItem      // GFP - 15/10/2012
Work1->(DBSETORDER(1))
Work1->(DBSEEK(cChave))  //Work1->(DBSEEK(RTRIM(cChave),.T.))  // GFP - 15/10/2012
IF Work1->(EOF())
   Work1->(DBGOTO(nRecno))
ENDIF
Work1->(DBSETORDER(nOrder))

RETURN .T.

*-----------------------------------------------------------------------------------------------------------------------------------*
STATIC FUNCTION E_RESET_AREA()
*-----------------------------------------------------------------------------------------------------------------------------------*
DBSELECTAREA("SW6")
IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,'DELETAWORK'),)
SW6->(MSUnlock())
IF TYPE('lNaoDelWork')=="L" .AND. lNaoDelWork
   RETURN .T.
ENDIF

If Select("Work1") > 0
    Work1->(dbCloseArea())
    E_EraseArq(Work1File,Work1FileA,Work1FileB)
    FErase(Work1FileC+TEOrdBagExt())
    FErase(Work1FileD+TEOrdBagExt())
EndIf

If Select("Work2") > 0
    Work2->(dbCloseArea())
    E_EraseArq(Work2File)
EndIf

If Select("Work3") > 0
    Work3->(E_EraseArq(Work3File,Work3FileA))
EndIf

If Select("Work4") > 0
    Work4->(E_EraseArq(Work4File))
EndIf

If Select("Work_Tot") > 0
    Work_Tot->(E_EraseArq(cFileWk,cFileWkA))
EndIf

DBSELECTAREA("SW6")
RETURN .T.
*-------------------------------------------------------------------------------------------------------*
FUNCTION DI554CalcICMS(nBase,nAlqReducao,nAliquota,nAliqRedCte)
*-------------------------------------------------------------------------------------------------------*
IF !EMPTY(nAliqRedCte) .AND. nAlqReducao == 1
   If EasyGParam("MV_EIC0029",,"N") == "R"                                                         //NCF - 22/05/2013 - O valor do ICMS a integrar a própria base de cálculo para cálculo por Carga Tributária
      nBaseNew:= ( nBase / ( (100 - nAliqRedCte) /100 ) )                                  //                   Equivalente deve ser obtido conforme o parâmetro: N=Alíquota Normal; R=Alíquota Reduzida
      Return DITrans( nBaseNew * (nAliqRedCte/nAliquota) ,2)
   Else
      nBaseNew:= ( nBase/(1-(nAliquota/100)) )                                             //NCF - 06/02/2013 - Correção do cálculo de Carga Tributária equivalente
      Return DITRANS( nBaseNew * ((nAliqRedCte/100) / (nAliquota/100)),2)
   EndIf
ELSE
   IF GetNewPar("MV_ICMS_IN",.F.)
      Return DITrans( ( (nBase*nAlqReducao) / ( (100 - nAliquota) /100 ) ) ,2)
   ELSE
      Return DITrans( (nBase*nAlqReducao) ,2)
   ENDIF
ENDIF

*---------------------------------------------------------------------------------------------------*
FUNCTION DI554GeraCusto()
*--------------------------------------------------------------------------------------*
LOCAL nNBM_FOB:=0, nRatIPD:=0,nTam:=AVSX3("B1_VM_P",3)
LOCAL cFilSWD:=xFILIAL("SWD")
LOCAL nCifMaior := 0, nRecno:=1, Wind, E
LOCAL n1CIFMaior,n1Recno,nSumDespI,nRecnoMidia,nTotProc
LOCAL cFilSB1:=xFilial('SB1')
LOCAL cFilSW2:=xFilial('SW2')
LOCAL cFilSW7:=xFilial('SW7')
LOCAL cFilSWP:=xFilial('SWP')
LOCAL cFilSW9:=xFilial('SW9')
Local aMaiorDesp:= {} //ACB - 17/01/2011

ProcRegua(Work1->(LASTREC())+3)

nContProc:=M_FOB_MID:= nFobItemMidia:= nDifCamb:=0
aDespesa := {}; nFob:=nFobTot:=nPesoL:=nPesoB:=0 //FSM - 02/09/2011 - Peso Bruto Unitario
aDesAcerto:={}

IncProc()

SYB->(DBSETORDER(1))
SB1->(DBSETORDER(1))
SW2->(DBSETORDER(1))
SW7->(DBSETORDER(4))
SW9->(DBSETORDER(1))

nFob:=0

IncProc()

MDI_OUTR:=MDI_OU_US:=nDifCamb:=0
SWD->(DbSeek(xFilial("SWD")+SW6->W6_HAWB)) //AWR 13/7/98
SWD->(DbEval( {|| DI554ForDesp(.T.)} ,;
              {|| AT(LEFT(SWD->WD_DESPESA,1),"129") = 0} ,;
              {|| cFilSWD==SWD->WD_FILIAL .AND. SWD->WD_HAWB==SW6->W6_HAWB} ))//Le todas as despesas
IncProc()

Work1->(dbsetorder(3))
Work1->(DBGOTOP())

nTotProc:=MDI_FOB_R

DO WHILE  !Work1->(EOF())

   IncProc(STR0136+' '+Work1->WKCOD_I) //"Lendo Item: "

   SB1->(DbSeek(cFilSB1+Work1->WKCOD_I))
   SW2->(DbSeek(cFilSW2+Work1->WKPO_NUM))
   SW7->(DBSEEK(cFilSW7+SW6->W6_HAWB+SW2->W2_PO_NUM+Work1->WKPOSICAO+Work1->WKPGI_NUM))
   SWP->(DBSEEK(cFilSWP+SW7->W7_PGI_NUM+SW7->W7_SEQ_LI))
   //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
   SW9->(DBSEEK(cFilSW9+Work1->WKINVOICE+Work1->WKFORN+EICRetLoja("WORK1", "WKLOJA")+SW6->W6_HAWB))

   // O While é mantido, pois nem todos possuem a alteração no índice 1 da SW9 (FILIAL+INVOICE+FORNECEDOR+HAWB)
   // A alteração do índice 1 da SW9 é disponibilizada através do update UIINVOICE
   DO WHILE !SW9->(EOF()) .AND. SW9->W9_FILIAL   == cFilSW9         .AND.;
                                Work1->WKINVOICE == SW9->W9_INVOICE .AND.;
                                Work1->WKFORN    == SW9->W9_FORN    .And.;
                                (!EICLoja() .Or. Work1->WKLOJA == SW9->W9_FORLOJ)
      IF SW6->W6_HAWB  == SW9->W9_HAWB
         EXIT
      ENDIF
      SW9->(DBSKIP())
   ENDDO

   IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"GRVWORK_1a"),)

   Work1->WK_NFE    := ''
   Work1->WKFABR    := SW7->W7_FABR
   Work1->WKDESCR   := MEMOLINE(MSMM(SB1->B1_DESC_P,nTam),60)
   Work1->WKPO_SIGA := DI154_PO_SIGA() // RA - 24/10/03 - O.S. 1076/03 // Antes=>SW2->W2_PO_SIGA

   IF !Work2->(DBSEEK(Work1->WKADICAO+Work1->WK_CFO+Work1->WK_OPERACA+Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM))
      Work2->(DBAPPEND())
      Work2->WKADICAO  := Work1->WKADICAO
      Work2->WK_OPERACA:= Work1->WK_OPERACA
      Work2->WK_CFO    := Work1->WK_CFO
      Work2->WKTEC     := Work1->WKTEC
      Work2->WKEX_NCM  := Work1->WKEX_NCM
      Work2->WKEX_NBM  := Work1->WKEX_NBM
      Work2->WKII_A    := Work1->WKIITX
      Work2->WKIPI_A   := Work1->WKIPITX
      Work2->WKICMS_A  := Work1->WKICMS_A
   ENDIF
   Work2->WKFOB_R  += Work1->WKFOB_R
   Work2->WKFRETE  += Work1->WKFRETE
   Work2->WKSEGURO += Work1->WKSEGURO
   Work2->WKCIF    += Work1->WKCIF
   Work2->WKII     += Work1->WKIIVAL
   Work2->WKIPI    += Work1->WKIPIVAL
   Work2->WKICMS   += Work1->WKVL_ICM
   Work2->WKPESOL  += Work1->WKPESOL
   Work2->WKCIF_MOE+= DITrans(MDI_CIFMOE * (Work1->WKFOB_R/nTotProc),2)

   IF lNaoTemComp
      Work1->WKRDIFMID += DITrans(nDifCamb*( Work1->WKFOB_R/nTotProc ),2)
      Work2->WKRDIFMID += Work1->WKRDIFMID
   ENDIF

   IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"GRVWORK_4"),)

   lAcerta:=.T.
   FOR Wind = 1 TO LEN(aDespesa)
       SWD->(DBGOTO(aDespesa[Wind,4]))
       nTaxa:=BuscaTaxa(cMoeDolar,SWD->WD_DES_ADI,.T.,.F.,.T.)
       IF(nTaxa=0,nTaxa:=1,)
       Work3->(DBAPPEND())
       Work3->WKRECNO   := Work1->(RECNO())
       Work3->WKDESPESA := aDespesa[Wind,1] + IF(SYB->(DBSEEK(XFILIAL("SYB")+aDespesa[Wind,1])),;
                                              "-"+SUBS(SYB->YB_DESCR,1,20)," ")
       nValor:=DITRANS(aDespesa[Wind,2]*( Work1->WKFOB_R/nTotProc ),2)
       Work3->WKVALOR   := nValor
       Work3->WKVALOR_US:= DITRANS(Work3->WKVALOR/nTaxa,2)
       Work3->WKPO_NUM  := Work1->WKPO_NUM
       Work3->WKPOSICAO := Work1->WKPOSICAO
       Work3->WKPGI_NUM := Work1->WKPGI_NUM
       IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"GRVWORK3"),)//PADRAO
       IF lAcerta
          IF (nPos:=ASCAN(aDesAcerto,{|Desp|Desp[1]==Work3->WKDESPESA})) = 0
              AADD(aDesAcerto,{Work3->WKDESPESA ,;
                               Work3->WKVALOR   ,;
                               Work3->WKVALOR_US,;
                               aDespesa[Wind,2] ,;
                               DITRANS(aDespesa[Wind,2]/nTaxa,2),;
                               Work3->(Recno()) })
              AAdd(aMaiorDesp, DITRANS(Work3->WKVALOR,2)) //wfs 14/01/11
          ELSE
             aDesAcerto[nPos,2] += Work3->WKVALOR
             aDesAcerto[nPos,3] += Work3->WKVALOR_US
             If DITRANS(Work3->WKVALOR,2) > aMaiorDesp[nPos]//wfs 14/01/11
                aDesAcerto[nPos][6]:= Work3->(Recno())
                aMaiorDesp[nPos]:= DITRANS(Work3->WKVALOR,2)
             EndIf
          ENDIF
       ENDIF
       IF(EasyEntryPoint("IC023PO1"),Execblock("IC023PO1",.F.,.F.,"GRVWORK3"),)//MERCK - ALEX
   NEXT

   Work1->(DBSKIP())

ENDDO

IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"GRVWORK_2"),)

FOR E=1 TO LEN(aDesAcerto)

   Work3->(DBGOTO( aDesAcerto[E,6] ))

   IF aDesAcerto[E,2] # aDesAcerto[E,4]
      Work3->WKVALOR := Work3->WKVALOR + (aDesAcerto[E,4] - aDesAcerto[E,2])
   ENDIF

   IF aDesAcerto[E,3] # aDesAcerto[E,5]
      Work3->WKVALOR_US := Work3->WKVALOR_US + (aDesAcerto[E,5] - aDesAcerto[E,3])
   ENDIF

NEXT

nRDIFMID := nOUTRDESP := nOUTRD_US := 0

Work1->(dbsetorder(1))
Work2->(dbsetorder(1))

Work1->(DBGOTOP())
Work2->(DBGOTOP())
ProcRegua( Work2->( LASTREC() ) )
n1CIFMaior:=Work1->WKCIF
nCIFMaior :=Work2->WKCIF
n1Recno   :=Work1->(RECNO())
nRecno    :=Work2->(RECNO())
nSumDespI :=nRecnoMidia:=0

DO WHILE  Work2->(!EOF())

   IncProc(STR0137) //"Gravando impostos das NCMs"

   IF lRateioCIF
      Work2->WKOUTRDESP:= DITrans(MDI_OUTR  * Work2->WKCIF/MDI_CIF   ,2)
      Work2->WKOUTRD_US:= DITrans(MDI_OU_US * Work2->WKCIF/MDI_CIF,2)
   ELSE
      Work2->WKOUTRDESP:= DITRANS(MDI_OUTR  * (Work2->WKFOB_R / nTotProc ),2)
      Work2->WKOUTRD_US:= DITRANS(MDI_OU_US * (Work2->WKFOB_R / nTotProc ),2)
   ENDIF

   Work1->(DBSEEK(Work2->WKADICAO+Work2->WK_CFO+Work2->WK_OPERACA+Work2->WKTEC+Work2->WKEX_NCM+Work2->WKEX_NBM))
   nDesp:=nDesp_US:=0

   DO WHILE !Work1->(EOF()) .AND. (Work1->WKADICAO+Work1->WK_CFO+Work1->WK_OPERACA+Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM) ==;
                                  (Work2->WKADICAO+Work2->WK_CFO+Work2->WK_OPERACA+Work2->WKTEC+Work2->WKEX_NCM+Work2->WKEX_NBM)
      IF lRateioCIF
         Work1->WKOUT_DESP:= DITrans(MDI_OUTR  * Work1->WKCIF/MDI_CIF + Work1->WKRDIFMID ,2)
         Work1->WKOUT_D_US:= DITrans(MDI_OU_US * Work1->WKCIF/MDI_CIF + Work1->WKUDIFMID ,2)
//       nSumDespI+= Work1->WKOUT_DESP
      ELSE
         Work1->WKOUT_DESP:= DITrans(Work2->WKOUTRDESP * (Work1->WKFOB_R/Work2->WKFOB_R) + Work1->WKRDIFMID ,2)
         Work1->WKOUT_D_US:= DITrans(Work2->WKOUTRD_US * (Work1->WKFOB_R/Work2->WKFOB_R) + Work1->WKUDIFMID ,2)
      ENDIF
      nDesp    += Work1->WKOUT_DESP
      nDesp_US += Work1->WKOUT_D_US
      IF Work1->WKCIF > nCIFMaior
         n1CIFMaior:=Work1->WKCIF
         n1Recno   :=Work1->(RECNO())
      ENDIF
      Work1->(DBSKIP())

   ENDDO
   Work1->(DBGOTO(n1Recno))
   IF nDesp # (Work2->WKOUTRDESP+Work2->WKRDIFMID)
      Work1->WKOUT_DESP += (Work2->WKOUTRDESP+Work2->WKRDIFMID)-DITrans(nDesp,2)
   ENDIF
   IF nDesp_US # Work2->WKOUTRD_US+Work2->WKUDIFMID
      Work1->WKOUT_D_US += (Work2->WKOUTRD_US+Work2->WKUDIFMID)-DITrans(nDesp_US,2)
   ENDIF

   IF Work2->WKCIF > nCIFMaior
      nCIFMaior:=Work2->WKCIF
      nRecno   :=Work2->(RECNO())
   ENDIF

   nOUTRDESP   += Work2->WKOUTRDESP
   nOUTRD_US   += Work2->WKOUTRD_US
   nRDIFMID    += Work2->WKRDIFMID

   Work2->(DBSKIP())
ENDDO

Work2->(DBGOTO(nRecno))
Work1->(DBGOTO(n1Recno))

IF DiTrans( MDI_OUTR,2 ) # DiTrans( nOUTRDESP,2 )
   Work2->WKOUTRDESP += DiTrans( MDI_OUTR ,2 ) - DiTrans( nOUTRDESP,2 )
ENDIF

IF DiTrans( MDI_OU_US,2 ) # DiTrans( nOUTRD_US,2 )
   Work2->WKOUTRD_US += DiTrans( MDI_OU_US ,2 ) - DiTrans( nOUTRD_US,2 )
ENDIF

IF lNaoTemComp
   IF DITrans(nRDIFMID,2) # DITrans(nDifCamb,2)
      Work2->WKRDIFMID += DITrans(nDifCamb,2) - DITrans(nRDIFMID,2)
   ENDIF
ENDIF

DBSELECTAREA("Work2")
DI554IncProc()
IF SW6->W6_IMPCO <> "1"  // GFP - 03/11/2014 - Tela de Divergencia de Valores somente aparecerá em casos  que o processo NÂO seja Conta e Ordem.
   DI554TestDI(bDifere)
ENDIF
Work2->(DBGOTOP())

MDI_OUTR +=nDifCamb

IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,"FINALGRAVA"),)

RETURN NIL

*------------------------------*
FUNCTION DI554Lote()
*------------------------------*
LOCAL D,J,C,N,nPosicao,lInvoice:=.F.,nTamReg:=AVSX3("WV_REG",3)
Local nQtdeLinha, nQtdeNF

	Work1->(DBGOTOP())

	ProcRegua(LEN(aRecWork1))

	// *** Define critérios para busca do lote
	SIX->(DBSETORDER(1))
	IF SIX->(DBSEEK("SWV2")) .AND. SWV->(FIELDPOS("WV_INVOICE")) # 0
	   lInvoice:=.T.
	   SWV->(DBSETORDER(2))
	   bSeek :={|| Work1->(WKINVOICE+WKPGI_NUM+WKPO_NUM+WKPOSICAO) }
	   bWhile:={|| SWV->WV_INVOICE == Work1->WKINVOICE.And.;
	               SWV->WV_PGI_NUM == Work1->WKPGI_NUM.And.;
	               SWV->WV_PO_NUM  == Work1->WKPO_NUM .And.;
	               SWV->WV_POSICAO == Work1->WKPOSICAO}
	ELSE
	   SWV->(DBSETORDER(1))
	   bSeek :={|| Work1->(WKPGI_NUM+WKPO_NUM+WK_CC+WKSI_NUM+WKCOD_I+STR(WK_REG,nTamReg))}
	   bWhile:={|| SWV->WV_PGI_NUM == Work1->WKPGI_NUM.And.;
	               SWV->WV_PO_NUM  == Work1->WKPO_NUM .And.;
	               SWV->WV_CC      == Work1->WK_CC    .And.;
	               SWV->WV_SI_NUM  == Work1->WKSI_NUM .And.;
	               SWV->WV_COD_I   == Work1->WKCOD_I  .And.;
	               SWV->WV_REG     == Work1->WK_REG}
	ENDIF
	// ***

	// *** Campos que não serão rateados, pois não sofrem alteração mesmo com a alteração da quantidade (valores iguais para todos os lotes)
	AADD(aCampos,"WKICMS_A"  )
	AADD(aCampos,"WKQTDE"    )
	AADD(aCampos,"WKPRECO"   )
	AADD(aCampos,"WKPRUNI"   )
	AADD(aCampos,"WKIPITX"   )
	AADD(aCampos,"WKIITX"    )
	AADD(aCampos,"WKREC_ID"  )
	AADD(aCampos,"WK_REG"    )
	AADD(aCampos,"WK_QTMID"  )
	AADD(aCampos,"WKICMS_RED")
	AADD(aCampos,"WKVLUPIS"  )
	AADD(aCampos,"WKPERPIS"  )
	AADD(aCampos,"WKVLUCOF"  )
	AADD(aCampos,"WKPERCOF"  )
	AADD(aCampos,"WKALCOFM"  )//FDR - 28/02/13

	If (lMV_NF_MAE .And. nTipoNF == NFE_FILHA)
		AADD(aCampos,"WKPESOL")
	EndIf
	// ***

	// *** Adiciona em 'aValor' todos os campos que serão rateados de acordo com a quantidade de cada lote
	aValor:={}
	DBSELECTAREA("Work1")
	FOR nPosicao := 1 TO FCOUNT()
	   IF VALTYPE(FIELDGET(nPosicao)) $ "CDL" .AND. ASCAN(aCampos,FIELD(nPosicao)) = 0
	      AADD(aCampos,FIELD(nPosicao))
	   ELSEIF VALTYPE(FIELDGET(nPosicao)) $ "N" .AND. ASCAN(aCampos,FIELD(nPosicao)) = 0
	      /*
	      	aValor:
	      	[1] - Valor original do campo ANTES da quebra
	      	[2] -
	      	[3] -
	      	[4] - Posicao do campo na Work1
	      */
	      AADD(aValor,{0,0,0,nPosicao})
	   ENDIF
	NEXT

	//Variável para backup do registro no momento da cópia de linha da Work1
	aDados:=ARRAY(LEN(aCampos))
	// ***

	// *** Inicia a verificação para cada item do SWN (Work1), já com os Recnos armazenados em aRecWork1
	SW7->(DBSETORDER(1))
	FOR N := 1 TO LEN(aRecWork1)

	    Work1->(dbGoTo(aRecWork1[N]))

	    IncProc(STR0341 +Work1->WKCOD_I) //STR0341 "Verificando Lotes, Item: "

	    // *** Controle de quantidades da linha
	    // Quantidade do item na linha original (que será quebrada)
	    nQtdeLinha := Work1->WKQTDE
		nQtdeNF := GetQtdeNF()
		// ***

	    // *** Verifica se existe lote para o item
	    lAchouSWV:= .F.
	    IF LEFT(Work1->WKPGI_NUM,1) == "*" .OR. lInvoice
	       lAchouSWV:=SWV->(dbSeek(xFilial()+SW6->W6_HAWB+EVAL(bSeek) ))
	    ELSE
	       lAchouSWV:=SWV->(dbSeek(xFilial()+SPACE(17)+EVAL(bSeek) ))
	    ENDIF
	    // ***

		// *** Caso tenha lote, trata a quebra da linha
	    IF lAchouSWV

		   // *** Faz backup de todos os valores que serão rateados
	       FOR D := 1 TO LEN(aValor)
			   // -> aValor[x][1] - Valor do campo ANTES da quebra (total da linha)
			   // -> aValor[x][4] - Posição do campo na Work1 (ID do campo)
	           aValor[D,1] := Work1->(FieldGet( aValor[D,4] ))
	       NEXT
           // ***

           // *** ZERA o acumulador de valor já utilizado nas quebras dos itens
	           AEVAL(aValor,{|t,I|aValor[I,2]:=0})
	       // ***

		   /*
		   	A linha atual da Work1 será a linha referente ao primeiro lote do item, com isso, sua quantidade será alterada para a
		   	quantidade deste lote e todos os seus valores serão rateados de acordo com a nova quantidade.
		   */
		   // *** Executa o rateio pelo lote
	       DI554RatLote(nQtdeLinha, nQtdeNF)
	       // ***

	       SWV->(dbSkip())

	       // *** Continua o tratamento para os demais lotes do mesmo item
	       DO While !SWV->(Eof())                     .And.;
	                SWV->WV_FILIAL  == xFilial("SWV") .And.;
	                SWV->WV_HAWB    == SW6->W6_HAWB .AND. EVAL(bWhile)


	            // *** Faz backup dos campos que serão apenas copiados para a nova linha
	            For j := 1 To LEN(aCampos)
	                aDados[J]:=Work1->(FieldGet(FieldPos(aCampos[j])))
	            Next
	            // ***

				//Cria a nova linha para receber o lote atual
	            Work1->(DBAPPEND())

				// *** Volta o backup dos campos (que não serão alterados ou rateados - comuns para todos as quebras)
	            For j := 1 To LEN(aCampos)
	                IF !EMPTY(aDados[J])
	                   Work1->(FieldPut(FieldPos(aCampos[j]),aDados[J]))
	                ENDIF
	            Next
	            // ***

			   /*
			   	A linha atual da Work1 será a nova linha referente ao lote atual do item. Com isso, sua quantidade será alterada para a
			   	quantidade deste lote e todos os seus valores serão rateados de acordo com a nova quantidade. Lembrando que a quantidade da linha referente ao lote
			   	anterior não se refere obrigatoriamente à quantidade do item ou da nota filha, e sim do valor do item no lote.
			   */
			   // *** Executa o rateio pelo lote
		       DI554RatLote(nQtdeLinha, nQtdeNF)
		       // ***

	           SWV->(dbSkip())
	       EndDo
	       // *** Final da quebra por lotes

	       //Diferenca  :=Total Original - Somatoria
	       FOR D := 1 TO LEN(aValor)
	           aValor[D,3]:= aValor[D,1] - aValor[D,2]
	           nValor := Work1->(FieldGet( aValor[D,4] )) + aValor[D,3]
	           Work1->(FieldPut( aValor[D,4] , nValor ))
	       NEXT

	    Endif
	    // *** Final da quebra de linha

	NEXT

Return(NIL)

*------------------------------------------*
Function DI554RatLote(nQtdeLinha, nQtdeNF)
*------------------------------------------*
Local P,nValor

	// *** Define a quantidade do item no lote e o percentual que este se refere com relação à LINHA ANTERIOR
	Work1->WKQTDE    := SWV->WV_QTDE * (nQtdeLinha / nQtdeNF) //Quantidade do item no lote
	nPerc := Work1->WKQTDE / nQtdeLinha						  //Quantidade do lote sobre a quantidade total do item na nota
	// ***

	// *** Campos específicos do lote
	Work1->WK_LOTE   :=SWV->WV_LOTE
	Work1->WKDTVALID :=SWV->WV_DT_VALI
    IF lCpoDtFbLt
       Work1->WKDTFBLT := SWV->WV_DFABRI
    ENDIF
	// ***

	// Rateio
	FOR P := 1 TO LEN(aValor)
	   nValor := aValor[P,1] * nPerc
	   Work1->(FieldPut( aValor[P,4] , nValor ))
	NEXT

	//Somatoria
	FOR P := 1 TO LEN(aValor)
	   aValor[P,2] += Work1->(FieldGet( aValor[P,4] ))
	NEXT

Return Nil

/*
	Busca a quantidade total da linha da Work1 a ser considerada para ser considerada na quebra dos lotes.
*/
Static Function GetQtdeNF()
Local aOrd
Local nQtdeNF := 0

	If Empty(Work1->WKNOTAOR+WKSERIEOR)
		//Quando não é nota filha, a quantidade é a própria quantidade da linha na Work1
		nQtdeNF := Work1->WKQTDE
	Else
		//Quando é nota filha, busca a quantidade do item na nota mãe, considerando lotes
		aOrd := SaveOrd("SWN")
		SWN->(DbSetOrder(3))
		If SWN->(DBSEEK(xFilial("SWN")+SW6->W6_HAWB+'5'))
			While SWN->(!EOF()) .And. xFilial("SW8")+SW6->W6_HAWB+'5' == xFilial("SWN")+SWN->WN_HAWB+SWN->WN_TIPO_NF
				If SWN->(WN_FILIAL+WN_HAWB+WN_INVOICE+WN_PO_EIC+WN_ITEM+WN_PGI_NUM+WN_PRODUTO) == xFilial("SWN")+SW6->W6_HAWB+Work1->(WKINVOICE+WKPO_NUM+WKPOSICAO+WKPGI_NUM+WKCOD_I)
					nQtdeNF += SWN->WN_QUANT
				EndIf
				SWN->(DBSkip())
			EndDo

		Else //LGS-30/10/13
			nQtdeNF := Work1->WKQTDE
		EndIf
		RestOrd(aOrd, .T.)
	EndIf

Return nQtdeNF

Static Function Di554NfFilha()
Local nQtdeMae := 0

	Work1->(DbGoTop())
	While Work1->(!Eof())

		SWN->(DBSetOrder(3))
		// *** Verifica se existe nota mãe e guarda o Recno
		If SWN->(DBSEEK(xFilial("SWN")+SW6->W6_HAWB+"5")) .Or. SWN->(DBSEEK(xFilial("SWN")+SW6->W6_HAWB+"3")) .Or. SWN->(DBSEEK(xFilial("SWN")+SW6->W6_HAWB+"1")) //SVG - 07/04/2011 - Nota fiscal filha a partir da nota primeira , unica ou mãe.
			lAchouMae:=.F.
			While !lAchouMae .And. SWN->(!EOF()) .And. xFilial("SW8")+SW6->W6_HAWB == xFilial("SWN")+SWN->WN_HAWB
				If SWN->WN_TIPO_NF <> "2" .And. SWN->WN_TIPO_NF <> "6"
					If SWN->(WN_FILIAL+WN_HAWB+WN_INVOICE+WN_PO_EIC+WN_ITEM+WN_PGI_NUM+WN_PRODUTO) == xFilial("SWN")+SW6->W6_HAWB+Work1->(WKINVOICE+WKPO_NUM+WKPOSICAO+WKPGI_NUM+WKCOD_I) .And. (AllTrim(SWN->WN_LOTECTL) == AllTrim(Work1->WK_LOTE))
						Work1->WKRECMAE := SWN->(RECNO())
						nQtdeMae := SWN->WN_QUANT
						lAchouMae:=.T.
					EndIf
				EndIf
				SWN->(DBSkip())
			EndDo
		EndIf
		// ***

		// *** Busca a quantidade já utilizada em outras notas filhas
		If SWN->(DBSEEK(xFilial("SWN")+SW6->W6_HAWB+STR(nTipoNF,1,0)))
			While SWN->(!EOF() .And. xFilial()+SW6->W6_HAWB+STR(nTipoNF,1,0) == WN_FILIAL+WN_HAWB+WN_TIPO_NF)
				If SWN->(WN_FILIAL+WN_HAWB+WN_INVOICE+WN_PO_EIC+WN_ITEM+WN_PGI_NUM+WN_PRODUTO) == xFilial("SWN")+SW6->W6_HAWB+Work1->(WKINVOICE+WKPO_NUM+WKPOSICAO+WKPGI_NUM+WKCOD_I) .And. (AllTrim(SWN->WN_LOTECTL) == AllTrim(Work1->WK_LOTE))
					Work1->WKQTDEUTIL += SWN->WN_QUANT
				EndIf
				SWN->(DBSkip())
			EndDo
		EndIf

		If (Work1->WKSLDDISP := nQtdeMae - Work1->WKQTDEUTIL) <= 0
			// *** VER - Remover linha da Work1
		EndIf

		Work1->(DbSkip())
	EndDo
	Work1->(DbGoTop())

Return Nil

/*------------------------------------------------------------------------------------
Funcao      : DI554FILHA
Parametros  :
Retorno     :
Objetivos   : Nota Fiscal de Remessa
Autor       : Saimon Vinicius Gava
Data/Hora   : 04/11/2009
Revisao     :
Obs.        : MV_NFFILHA - indica quais valores deverão ser apresentados na nota filha, sendo:
              0 - valor da mercadoria (FOB, FRETE, SEGURO, CIF e II)- default
              1 - TUDO
*------------------------------------------------------------------------------------*/
Function DI554FILHA()

Local oGetDB
Local cTitulo:= STR0327 //"Nota Fiscal de Remessa"
Local cSay := STR0342 //STR0342 "Percentual %"
Local nOpc:=0,lOk:=lTemItens:=lRet:=.F.
Local aButtons :={}
Private nPercentual := 100
Private lRefresh := .T.
Private aHeader := {}
Private aCols := {}
Private oDlgFilha
Private aRotina := {{STR0343, "Alteração", 0, 4}} // Necessário para a GETDB   //STR0343 "Alteração"

Aadd(aButtons,{"S4WB011N",{||DI554Busca(),oGetDB:oBrowse:Refresh()},STR0344})   // GFC  -  "Conf D.I." //STR0344 "Pesquisar"


AADD(aHeader,{ AVSX3("WN_INVOICE" ,AV_TITULO),"WKINVOICE" ,AVSX3("WN_INVOICE" ,AV_PICTURE),AVSX3("WN_INVOICE" ,AV_TAMANHO),AVSX3("WN_INVOICE",AV_DECIMAL),,"",AVSX3("WN_INVOICE" ,AV_TIPO) ,"",""})
AADD(aHeader,{ AVSX3("WN_PO_EIC",AV_TITULO),"WKPO_NUM" ,AVSX3("WN_PO_EIC" ,AV_PICTURE),AVSX3("WN_PO_EIC" ,AV_TAMANHO),AVSX3("WN_PO_EIC",AV_DECIMAL),,"",AVSX3("WN_INVOICE" ,AV_TIPO),"","" })
AADD(aHeader,{ AVSX3("WN_PRODUTO",AV_TITULO),"WKCOD_I" ,AVSX3("WN_PRODUTO" ,AV_PICTURE),AVSX3("WN_PRODUTO" ,AV_TAMANHO),AVSX3("WN_PRODUTO",AV_DECIMAL),,"",AVSX3("WN_PRODUTO" ,AV_TIPO),"",""})
AADD(aHeader,{ STR0323,"WKDESCR" ,AVSX3("B1_DESC" ,AV_PICTURE),AVSX3("B1_DESC" ,AV_TAMANHO),AVSX3("B1_DESC",AV_DECIMAL),,"",AVSX3("B1_DESC" ,AV_TIPO),"",""}) //SVG - 28/04/2011 - Inserido descrição do produto. STR0323 ->"Desc. Prod."
AADD(aHeader,{ AVSX3("WN_QUANT",AV_TITULO),"WKQTDE" ,AVSX3("WN_QUANT",AV_PICTURE),AVSX3("WN_QUANT" ,AV_TAMANHO),AVSX3("WN_QUANT",AV_DECIMAL),,"",AVSX3("WN_QUANT" ,AV_TIPO),"","" })
AADD(aHeader,{ STR0324,"WKQTDEUTIL" ,AVSX3("WN_QUANT",AV_PICTURE),AVSX3("WN_QUANT" ,AV_TAMANHO),AVSX3("WN_QUANT",AV_DECIMAL),,"",AVSX3("WN_QUANT" ,AV_TIPO),"","" }) //"Qtde. Utilizada"
AADD(aHeader,{ STR0325,"WKSLDDISP" ,AVSX3("WN_QUANT",AV_PICTURE),AVSX3("WN_QUANT" ,AV_TAMANHO),AVSX3("WN_QUANT",AV_DECIMAL),,"",AVSX3("WN_QUANT" ,AV_TIPO),"","" })//"Qtde. Disponivel"
AADD(aHeader,{ STR0326,"WKQTDEFILH" ,AVSX3("WN_QUANT",AV_PICTURE),AVSX3("WN_QUANT" ,AV_TAMANHO),AVSX3("WN_QUANT",AV_DECIMAL),,"",AVSX3("WN_QUANT" ,AV_TIPO),"","" })//"Qtde. a Utilizar"

//FDR - 05/04/12 - Inclusão do campo número do lote
If lLote
   AADD(aHeader,{ STR0064 ,"WK_LOTE" ,AVSX3("WN_LOTECTL",AV_PICTURE),AVSX3("WN_LOTECTL" ,AV_TAMANHO),AVSX3("WN_LOTECTL",AV_DECIMAL),,"",AVSX3("WN_LOTECTL" ,AV_TIPO),"","" })
Endif

DEFINE MSDIALOG oDlgFilha TITLE cTitulo FROM 5,5 TO 38,110 Of oMainWnd

   @ 20,10 SAY cSay      SIZE 58,7  PIXEL
   @ 30,10 MSGET oGet1 VAR nPercentual PICTURE "999.99"     SIZE 58,8 PIXEL
   @ 30,60 BUTTON "&"+STR0345  SIZE 38,12 ACTION (DI554CalcPerc(nPercentual),oGetDB:oBrowse:Refresh())  Pixel //STR0345 "Calcula"
   oGetDB := MsGetDB():New(0,0,165,413,1,/*"U_LINHAOK"*/,/* "U_TUDOOK"*/,,;
   .F.,{"WKQTDEFILH"},,.F.,,"Work1","U_GET554",,.F.,oDlgFilha, .T., ,/*"U_DELOK"*/,/*"U_SUPERDEL"*/)

   oGetDB:oBrowse:Align := CONTROL_ALIGN_BOTTOM
   oGetDB:oBrowse:bADD := {|| .F.}

   oDlgFilha:lCentered := .T.


ACTIVATE MSDIALOG oDlgFilha ON INIT (EnchoiceBar(oDlgFilha,{|| if(Validaitens(),(lOk:=.T.,oDlgFilha:End()),)},{||oDlgFilha:End(),lOk:=.F.},,aButtons))


If lOk
   WORK1->(DBGoTop())
   Do While WORK1->(!EOF())
      If WORK1->WKQTDEFILH  <= 0
         WORK1->(DBDelete())
      Else
         nRecSWN := SWN->(RECNO())
         SWN->(dbGoto(WORK1->WKRECMAE))
         nPerc := Work1->WKQTDEFILH / Work1->WKQTDE
         Work1->WKPRUNI   := SWN->WN_PRUNI
         Work1->WKQTDE    := Work1->WKQTDEFILH
         Work1->WKVALMERC := DITrans(Work1->WKQTDEFILH*SWN->WN_PRUNI,2)
         Work1->WKPESOL   := Work1->WKPESOL * Work1->WKQTDE
         nPesoL           := lPesoNew * Work1->WKQTDE // SVG - 11/05/2011 - Ajuste do peso.

         //FSM - 02/09/2011 - Peso Bruto Unitario
         If lPesoBruto
            nPesoB := Work1->WKPESOBR * Work1->WKQTDE
         EndIf

         Work1->WKFOB     := Work1->WKFOB * nPerc
         Work1->WKFOB_R   := DITRANS(Work1->WKFOB_R * nPerc,2)
         Work1->WKFOB_ORI := Work1->WKFOB
         Work1->WKFOBR_ORI:= Work1->WKFOB_R
         Work1->WKCIF     := Work1->WKFOB_R
         IF cMV_NFFILHA <> "2"
            Work1->WKFRETE   := DITrans(SWN->WN_FRETE * nPerc,2)
            Work1->WKSEGURO  := DITrans(SWN->WN_SEGURO * nPerc,2)
         ENDIF
         Work1->WKCIF     := DITRANS(SWN->WN_CIF * nPerc,2)

         If cMV_NFFILHA == "2"
            Work1->WKCIF:= Work1->WKCIF - (DITrans(SWN->WN_FRETE * nPerc,2) + DITrans(SWN->WN_SEGURO * nPerc,2) )
         Endif

        IF SWN->(FIELDPOS("WN_VLACRES")) # 0 .AND. SWN->(FIELDPOS("WN_VLDEDUC")) # 0
            Work1->WKVLACRES := DITRANS(SWN->WN_VLACRES * nPerc,2)
            Work1->WKVLDEDU  := DITRANS(SWN->WN_VLDEDUC * nPerc,2)
         ENDIF
         IF cMV_NFFILHA $ '0,1,3' //LGS-05/05/14 //cMV_NFFILHA == "0" .OR. cMV_NFFILHA == "1"
            Work1->WKBASEII  := Work1->WKCIF
            Work1->WKIITX    := SWN->WN_IITX
            Work1->WKIIVAL   := DITRANS(SWN->WN_IIVAL * nPerc,2)
         ENDIF

         IF cMV_NFFILHA == "1"
            Work1->WKIPIBASE := DITRANS(SWN->WN_IPIBASE * nPerc,2)
            Work1->WKIPITX   := SWN->WN_IPITX
            Work1->WKIPIVAL  := DITRANS(SWN->WN_IPIVAL * nPerc,2)

            IF lMV_PIS_EIC
               Work1->WKVLUPIS := SWN->WN_VLUPIS
               Work1->WKBASPIS := DITRANS(SWN->WN_BASPIS * nPerc,2)
               Work1->WKPERPIS := SWN->WN_PERPIS
               Work1->WKVLRPIS := DITRANS(SWN->WN_VLRPIS * nPerc,2)
               Work1->WKVLUCOF := SWN->WN_VLUCOF
               Work1->WKBASCOF := DITRANS(SWN->WN_BASCOF * nPerc,2)
               Work1->WKPERCOF := SWN->WN_PERCOF
               Work1->WKVLRCOF := DITRANS(SWN->WN_VLRCOF * nPerc,2)
               If lCposCofMj                                                            //NCF - 20/07/2012 - Majoração COFINS
                  Work1->WKALCOFM  := SWN->WN_ALCOFM
                  Work1->WKVLCOFM  := DITRANS(SWN->WN_VLCOFM * nPerc,2)
               EndIf
               If lCposPisMj                                                            //GFP - 11/06/2013 - Majoração PIS
                  Work1->WKALPISM  := SWN->WN_ALPISM
                  Work1->WKVLPISM  := DITRANS(SWN->WN_VLPISM * nPerc,2)
               EndIf
            ENDIF
            Work1->WKBASEICMS := DITRANS(SWN->WN_BASEICM * nPerc,2)
            Work1->WKICMS_A   := SWN->WN_ICMS_A
            Work1->WKVL_ICM   := DITRANS(SWN->WN_VL_ICM * nPerc,2)
            Work1->WKOUT_DESP := DITRANS(SWN->WN_DESPESA * nPerc,2)

            If AvFlags("ICMSFECP_DI_ELETRONICA")
               Work1->WKALFECP := SWN->WN_ALFECP
               Work1->WKVLFECP := DITRANS(SWN->WN_VLFECP * nPerc,2)
            EndIf
            If AVFLAGS("FECP_DIFERIMENTO")
               Work1->WKFECPALD := SWN->WN_FECPALD
               Work1->WKFECPVLD := DITrans(SWN->WN_FECPVLD * nPerc,2)
               Work1->WKFECPREC := DITrans(SWN->WN_FECPREC * nPerc,2)
            EndIf            
         ENDIF
		 //LGS-05/05/14
         IF cMV_NFFILHA $ '1,3' .And. SWN->(FIELDPOS("WN_DESPICM")) # 0
         	Work1->WKDESPICM := DITRANS(SWN->WN_DESPICM * nPerc,2)
         EndIf
         SWN->(dbGoto(nRecSWN))
      EndIf
      WORK1->(DBSkip())
   EndDo
   Work1->(dbGoTop())
   lRet:=.T.
EndIf
Return lRet

*---------------------
User Function GET554()
*---------------------
Local lRet := .T.
Local lPerm5porc := EasyGParam("MV_EIC0032",,.F.)  // GFP - 15/08/2013

//DFS - Tratamento para não permitir valores maiores que os disponíveis - Chamado: 081104
If (lPerm5porc .AND. M->WKQTDEFILH > ((WORK1->WKQTDE * 0.05) + WORK1->WKSLDDISP)) .OR. (!lPerm5porc .AND. M->WKQTDEFILH > (WORK1->WKSLDDISP))  // GFP - 28/10/2013
   lRet := .F.
   MsgInfo(STR0318 + If(lPerm5porc,CHR(13)+CHR(10) + STR0360,""),STR0022) //"Valor superior a quantidade disponível!"  ### "Sistema permite o recebimento de até 5% para mais além da quantidade manifestada (BL e Fatura)." ### "Atenção"
//WFS - 19/01/12 - Alterado de M->WKQTDEFILH <= 0 para
Elseif M->WKQTDEFILH < 0
   lRet := .F.
   MsgInfo(STR0319) // "Valor Inválido."
Endif

Return lRet

/*------------------------------------------------------------------------------------
Funcao      : DI554CalcPerc
Parametros  :
Retorno     :
Objetivos   : Calcular percentual de nota filha
Autor       : Saimon Vinicius Gava
Data/Hora   : 04/11/2009
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Function DI554CalcPerc(nPercentual)

Work1->(DBGoTop())
While Work1->(!EOF())
   //DFS - Tratamento para não permitir valores negativos no Percentual da Nota Filha. Chamado: 081104
   If nPercentual >= 0
      If Work1->WKSLDDISP >= ((Work1->WKSLDDISP * nPercentual)/100)
         Work1->WKQTDEFILH := ((Work1->WKSLDDISP * nPercentual)/100)
      EndIf
   Else
     MsgInfo (STR0320) //"Não é permitido digitar valores negativos."
   Endif
   Work1->(DBSkip())
EndDo
Work1->(DBGoTop())
Return

/*------------------------------------------------------------------------------------
Funcao      : DI554Busca
Parametros  :
Retorno     :
Objetivos   : Busca de itens da nota filha
Autor       : Saimon Vinicius Gava
Data/Hora   : 04/11/2009
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Function DI554Busca()
Local oDlg
Local cTitulo:=STR0321 //"Busca de Itens da Nota Filha"
Local cPesq:=Space(15)
Local aOpcao := {"1- Item","2- PO","3- Invoice"}
Local cCombo := aOpcao[1]

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 30,50 TO 39,88 Of oDlgFilha

   @ 020,020 SAY "Opção"   SIZE 100,8 OF oDlg PIXEL
   @ 30,10   COMBOBOX cCombo     ITEMS aOpcao SIZE 35,90 OF oDlg PIXEL
   @ 30,65 MSGET oGet1 VAR cPesq  PICTURE Avsx3("WN_INVOICE",AV_PICTURE) SIZE 58,8 PIXEL

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||lOk:=.T.,oDlg:End()},{||oDlg:End()},,))

DO CASE
   CASE cCombo == "1- Item"
      Work1->(dbSetOrder(6))
      If !Empty(cPesq)
         Work1->(dbSeek(cPesq))
      EndIf
   CASE cCombo == "2- PO"
      Work1->(dbSetOrder(7))
      If !Empty(cPesq)
         Work1->(dbSeek(cPesq))
      EndIf
   CASE cCombo == "3- Invoice"
      Work1->(dbSetOrder(8))
      If !Empty(cPesq)
         Work1->(dbSeek(cPesq))
      EndIf
ENDCASE

Return


/*------------------------------------------------------------------------------------
Funcao      : DI554GrvWk2
Parametros  :
Retorno     :
Objetivos   : Gravação da Work2
Autor       : Saimon Vinicius Gava
Data/Hora   : 04/11/2009
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Function DI554GrvWk2()

   EIJ->(DbSeek(xFilial("EIJ")+SW6->W6_HAWB+SW8->W8_ADICAO))
   SWZ->(DbSeek(xFilial("SWZ")+EIJ->EIJ_OPERAC))
   SYD->(DbSeek(xFilial("SYD")+SW8->W8_TEC+SW8->W8_EX_NCM+SW8->W8_EX_NBM))
   IF !Work2->(DbSeek(SW8->W8_ADICAO+SWZ->WZ_CFO+SW7->W7_OPERACA+SW8->W8_TEC+SW8->W8_EX_NCM+SW8->W8_EX_NBM))
      Work2->(DBAPPEND())
      Work2->WKADICAO   := SW8->W8_ADICAO
      Work2->WK_CFO     := SWZ->WZ_CFO
      Work2->WK_OPERACA := SW7->W7_OPERACA
      Work2->WKTEC      := SW8->W8_TEC
      Work2->WKEX_NCM   := SW8->W8_EX_NCM
      Work2->WKEX_NBM   := SW8->W8_EX_NBM
      Work2->WKREC_ID   := EIJ->(RECNO())
      Work2->WKII_A     := EIJ->EIJ_ALI_II
      Work2->WKIIREDU_A := EIJ->EIJ_PR_II
      IF !EMPTY(EIJ->EIJ_ALA_II)
         Work2->WKII_A  := EIJ->EIJ_ALA_II
      ENDIF
      IF !EMPTY(EIJ->EIJ_ALR_II)
         Work2->WKII_A  := EIJ->EIJ_ALR_II
      ENDIF
      IF nTipoNF <> NFE_FILHA .OR. cMV_NFFILHA == "1"
         Work2->WKIPI_A := EIJ->EIJ_ALAIPI
         IF nTipoNF # NFE_COMPLEMEN //  .OR. lICMS_NFC
            IF SWZ->(DbSeek(xFilial("SWZ")+EIJ->EIJ_OPERAC))
               Work2->WKICMS_A  := DITRANS(SWZ->WZ_AL_ICMS,2)
               Work2->WKICMS_RED:= IF(SWZ->WZ_RED_ICM#0,(100-SWZ->WZ_RED_ICM)/100,1)
               Work2->WKRED_CTE := SWZ->WZ_RED_CTE
            ELSE
               Work2->WKICMS_A  := DITRANS(SYD->YD_ICMS_RE,2)
               Work2->WKICMS_RED:= 1
            ENDIF
         ENDIF
      ENDIF
   ENDIF

   IF nTipoNF <> NFE_FILHA

      Work1->WKIITX   := Work2->WKII_A
      Work1->WKIPITX  := Work2->WKIPI_A
      Work1->WKICMS_A := Work2->WKICMS_A
      IF lMidia
         Work1->WK_VLMID_M:= DITrans(nFbMid_MRS,2)
         Work1->WK_QTMID  := SB1->B1_QTMIDIA * SW8->W8_QTDE
         IF lSomaDifMidia .AND. lNaoTemComp // AWR - MIDIA - 7/5/4
            nTaxa:=BuscaTaxa(cMoeDolar,SW6->W6_DT_DESE,.T.,.F.,.T.)
            IF(nTaxa=0,nTaxa:=1,)
            nDespDif := SW8->W8_INLAND+SW8->W8_PACKING+SW8->W8_OUTDESP-IF(!lIn327,SW8->W8_DESCONTO,0) // Bete - 24/02/05
            Work2->WKRDIFMID += Work1->WKRDIFMID
            Work2->WKUDIFMID += Work1->WKUDIFMID
         ENDIF
      ENDIF  // AWR - MIDIA - 7/5/4
      IF lNaoTemComp
         Work2->WKRDIFMID += DITrans( nDifCamb * Work1->WKRATEIO ,2)// AWR - MIDIA - 7/5/4
      ENDIF
   ELSE
      Work2->WKII_A   := Work1->WKIITX
      Work2->WKIPI_A  := Work1->WKIPITX
      Work2->WKICMS_A := Work1->WKICMS_A
   ENDIF

   IF lMV_PIS_EIC  .AND. nTipoNF # 2
      Work2->WKBASPIS  += Work1->WKBASPIS
      Work2->WKVLRPIS  += Work1->WKVLRPIS
      Work2->WKBASCOF  += Work1->WKBASCOF
      Work2->WKVLRCOF  += Work1->WKVLRCOF
   ENDIF

   Work2->WKPESOL   += Work1->WKPESOL
   Work2->WKFOB     += Work1->WKFOB
   Work2->WKFOB_R   += Work1->WKFOB_R
   Work2->WKFOB_ORI += Work1->WKFOB_ORI
   Work2->WKFOBR_ORI+= Work1->WKFOBR_ORI
   Work2->WKQTDE    += Work1->WKQTDE
   Work2->WKFRETE   += Work1->WKFRETE
   Work2->WKSEGURO  += Work1->WKSEGURO
   Work2->WKCIF     += Work1->WKCIF
   Work2->WKVLACRES += Work1->WKVLACRES
   Work2->WKVLDEDU  += Work1->WKVLDEDU
   Work2->WKBASEII  += Work1->WKBASEII
   Work2->WKII      += Work1->WKIIVAL//EIJ->EIJ_VLARII
   Work2->WKIPI     += Work1->WKIPIVAL//EIJ->EIJ_VLAIPI
   Work2->WKICMS    += Work1->WKVL_ICM//EIJ->EIJ_VLICMS

   IF (lMV_NF_MAE .And. nTipoNF == NFE_FILHA)
      MDI_FOB_R  += Work1->WKFOB_R
      MDI_FRETE  += Work1->WKFRETE
      MDI_SEGURO += Work1->WKSEGURO
      MDI_CIF    += Work1->WKCIF
      nNBM_II    += Work1->WKIIVAL
      nNBM_IPI   += Work1->WKIPIVAL
      nNBM_ICMS  += Work1->WKVL_ICM
      nNBM_PIS   += Work1->WKVLRPIS
      nNBM_COF   += Work1->WKVLRCOF
      MDI_OUTR   += Work1->WKOUT_DESP
   ENDIF

Return .F.

Static Function Validaitens()
Local lTemItens := .F.

WORK1->(DBGoTop())
Do While WORK1->(!EOF()) .And. !lTemItens
   If WORK1->WKQTDEFILH  > 0
      lTemItens := .T.
   EndIf
   Work1->(dbSkip())
EndDo

WORK1->(DBGoTop())
If !lTemItens
   Alert(STR0322)      //"Não existem itens selecionados para a Nota Filha."
EndIf

return lTemItens

/*
Funcao      : DI554ValPesq()
Parâmetros  : cAdicao: Código Adição
              cTec  : NCM do produto
              cItem : Código do item
Retorno     : lRet  : .T./.F.
Objetivos   : Validar informações de pesquisa
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 09/10/2012 : 17:12
*/
*-------------------------------------------------*
Static Function DI554ValPesq(cAdicao,cTec,cItem)
*-------------------------------------------------*
Local lRet := .T.

Do Case
   Case Empty(cAdicao)
      MsgInfo("Preencha a Adição")
      lRet := .F.
   Case Empty(cTec)
      MsgInfo("Preencha a NCM")
      lRet := .F.
   Case Empty(cItem)
      MsgInfo("Preencha o item")
      lRet := .F.
End Case

Return lRet

/*
Funcao      : CheckAliRed()
Parâmetros  : cImpsoto : Imposto a ser checado
Retorno     : nAliq : Aliquota localizada
Objetivos   : Checar se existe Aliquota Reduzida
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 23/06/2014 :: 11:54
*/
*-----------------------------------------*
Static Function CheckAliRed(cImposto,nVal)
*-----------------------------------------*
Local aOrd := SaveOrd("EIJ")
Local nAliq := nVal

Begin Sequence
   EIJ->(DbSetOrder(1))
   If !EIJ->(DbSeek(xFilial("EIJ")+SW6->W6_HAWB+Work2->WKADICAO))
      Break
   EndIf

   Do Case
      Case cImposto == "II"
         If EIJ->EIJ_ALR_II > 0
            nAliq := EIJ->EIJ_ALR_II
         EndIf
      Case cImposto == "IPI"
         If EIJ->EIJ_ALRIPI > 0
            nAliq := EIJ->EIJ_ALRIPI
         EndIf
   End Case
End Sequence

RestOrd(aOrd,.T.)
Return nAliq

/*
Funcao      : DI554ValNF()
Parâmetros  : lTodos, cNumero, cSerie
Retorno     : lRet
Objetivos   : Validação de Numero de NF, mediante itens de quebra de NF.
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 26/06/2015 - 13:23
*/
*----------------------------------------------*
Function DI554ValNF(lTodos,cNumero,cSerie)
*----------------------------------------------*
Local lRet := .T.
Local cFornLoj := Work1->WKFORN + If(EICLoja(),Work1->WKLOJA,"")
Local cCFO := Work1->WK_CFO
Local cACModal := Work1->WKACMODAL
Local cOperacao := Work1->WK_OPERACA
Local lQuebraCFO := EasyGParam("MV_QBCFO",,.T.)
Local nRecWK := Work1->(Recno())

Work1->(DbGoTop())
Do While Work1->(!Eof())
   If (!Empty(Work1->WK_NFE) .AND. !Empty(Work1->WK_SE_NFE)) .AND.;
      (Work1->WK_NFE == cNumero .AND. Work1->WK_SE_NFE == cSerie) .AND.;
      cFornLoj # Work1->WKFORN + If(EICLoja(),Work1->WKLOJA,"") /*.OR.;    //NCF - 16/12/2015 - Nopado - o trecho não permite que se informe Nro.NF distitino por item
      (lQuebraCFO .AND. cCFO # Work1->WK_CFO) .OR.;
      (lIntDraw .AND. cACModal # Work1->WKACMODAL) .OR.;
      (lQuebraOperacao .AND. cOperacao # Work1->WK_OPERACA)*/

      If !lTodos
         MsgInfo(STR0372,STR0022)  // "Não é possível utilizar este número, série e data para este item." ### "Atenção"
      EndIf
      lRet := .F.
      Exit
   EndIf
   Work1->(DbSkip())
EndDo

Work1->(DbGoTo(nRecWK))
Return lRet

/*
Funcao      : VlAnDubICM()
Parâmetros  : cAliasTab,cHawb,nTipoNFE
Retorno     : nVlrAntDumpDI 
Objetivos   : Retornar o total das despesas Anti dumping base de ICMS da DI
Autor       : Nilson César
Data/Hora   : 14/09/2017
*/
Static Function VlAnDubICM(cAliasTab,cHawb,nTipoNFE)
Local aOrdEIJ      
Local nVlrAntDumpDI := 0
Local lCondWhile
Local lcondExec := EasyGParam("MV_TEM_DI",,.F.) .And. ;
                   ValType(nTipoNFE) == "N" .And. ;
                   (nTipoNFE == NFE_PRIMEIRA .Or. nTipoNFE == NFE_UNICA ) .And. ;
                   EasyGParam("MV_ANDUBIC",,.F.) .And.;
                   CHKFILE("EIJ") .And. EIJ->(FIELDPOS("EIJ_VLR_DU")) > 0 
                   
Default cAliasTab := "EIJ"
Default cHawb := SW6->W6_HAWB

If lcondExec  
  
   aOrdEIJ := SaveOrd(cAliasTab)
   (cAliasTab)->(DbGoTop())

   If cAliasTab == "EIJ"
      EIJ->(DbSetOrder(1))
      lCondWhile := EIJ->(DbSeek(xfilial("EIJ")+cHawb))
      bWhile := {|| EIJ->(!Eof()) .And. EIJ->EIJ_HAWB == cHawb }
   EndIf

   If lCondWhile
      Do While Eval(bWhile)
         If (cAliasTab)->EIJ_ADICAO == "MOD"
            (cAliasTab)->(DbSkip())
            Loop
         EndIf
         nVlrAntDumpDI += (cAliasTab)->EIJ_VLR_DU
         (cAliasTab)->(DbSkip())
      EndDo
   EndIf
   RestOrd(aOrdEIJ,.T.)
   
EndIf

Return nVlrAntDumpDI

/*
Funcao      : DI554VlAnDubICM()
Parâmetros  : cAliasTab,cHawb,nTipoNFE
Retorno     : Chamada da função estática VlAnDubICM() 
Objetivos   : Retornar o total das despesas Anti dumping base de ICMS da DI
Autor       : Nilson César
Data/Hora   : 14/09/2017
*/
Function DI554VlAnDubICM(cAliasTab, cHawb ,nTipoNFE)
Return VlAnDubICM(caliasTab, cHawb, nTipoNFE) 
*--------------------------------------------------------------------------------------*
*                                  FIM DO PROGRAMA EICDI554.PRW
*--------------------------------------------------------------------------------------*

