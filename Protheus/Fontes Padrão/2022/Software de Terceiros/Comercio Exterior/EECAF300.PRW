#INCLUDE "PROTHEUS.ch"
#INCLUDE "EECAF300.ch"
/*
Programa : EECAF300.PRW
Objetivo : MANUTENCAO DE FFC
Autor    : LUCIANO CAMPOS DE SANTANA
Data/Hora: 21/04/2001 19:27
Revisao  : Gustavo F.C. - 20/06/2002 - Alterações para Financiamento
Revisao  : Lucas R. R. Lopes  - 09/12/2004 - Conceito multi filial,substituição das variaveis cFilEF3,
          cFilEF2, cFilEF1 ,cFilEc6 pela Função xFilial
Obs.     :
*/
#include "EEC.CH"

#define EV_PRINC2       "101"
#define EV_EMBARQUE     "600"
#define EV_LIQ_PRC      "630"
#define EV_LIQ_JUR      "640"
#define EV_LIQ_PRC_FC   "660"
//** GFC - Pré-Pagamento/Securitização
#define EV_PRINC_PREPAG "700"  //Principal das parcelas de pré-pagamento/securitização
#define EV_JUROS_PREPAG "710"  //Parcelas de juros de pré-pagamento/securitização
//**

*--------------------------------------------------------------------
FUNCTION EECAF300(cTipoCon,cTipoReg,cNrFFC)
LOCAL oDLG,nOrderSX3:=SX3->(IndexOrd()),oBTNOK,oBTNCANCEL,aPOS,cFLAG,nSX3,;
      /*aBUTTONS := {},*/;
      cPICTFFC := AVSX3("EEQ_FFC",AV_PICTURE),;
      bOK, bOK2,;
      bCANCEL  := {||nOpc:=0,oDlg:End(),lRet := .F.},;
      aORDANT  := SAVEORD({"SA2","SA6","SY0","EEC"}),;
      lRET     := .F.,;
      nOPC     := 0, aSemSx3:={}, cArq, cx

// by CAF 09/04/2004
//Local lEstorno := .f.  // LDB 18/11/2006 - Mudanca para private
Local nLin //LRL 17/12/04
// ** By JBJ - 15/09/2003 - Flag para indicação de liquidação de FFC.
Local i
Local aOrd := SaveOrd({"SX7"}),cRegra, cRegra_Errada  // JPP - 01/06/2005 11:20

Local lSairTela := .F.

Local aTipos    := {}
Local aTipCon   := {}
Local aButManut := {}  // GFP - 28/10/2013

// BAK - Variaveis integração mensagem unica
Local lEaiBuffer := .F.
Local bOnError := { |cFuncName, nOpc| AF200RetLiq(aParcLiq,cFuncName,nOpc,"FFC")}
Private aParcLiq   := {}

Private lCallRS403 := Valtype(cTipoCon) == "C" .And. Valtype(cTipoReg) == "C" .And. !Empty(cTipoCon) .And. !Empty(cTipoReg) .And. IsInCallStack("ESSRS403")

Private aButtons := {}
//** HVR - 08/03/2006 - Nova estrutura das tabelas de financiamento - EF1_TPMODU e EF1_SEQCNT.
Private lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                     EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                     EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                     EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                     EF6->( FieldPos("EF6_SEQCNT") ) > 0 .AND. EEQ->( FieldPos("EEQ_TP_CON") ) > 0
//** HVR - 08/03/2006

Private lLiq := .f.
Private lEstorno := .f. /* LDB - 18/11/2006 */
Private lNrInvo := (EEQ->(FieldPos("EEQ_NRINVO")) > 0)

// PLB 30/06/06 - Tabela de cadastro de Financiamentos
Private lCadFin := ChkFile("EF7") .AND. ChkFile("EF8") .AND. ChkFile("EF9")
Private lFFCIMP := (EEQ->(FieldPos("EEQ_FFCIMP")) > 0) //HVR 04/04/06 VALIDA SE O CAMPO EXISTE

PRIVATE cNOME,cNomeForn,cWORKEEQ,cFFC,cInvoice,cIMPORT,dVENCTI,dVENCTF,dEMBARI,dEMBARF,dDTNEG,;
        cREFBANC,lFFC,oMSELECT,cCONDPAG,nDIASPAG,cFornec,cLojaFor,cLojaImp,cNrOp,cNrOpSq,FileWork,FileWork1,; //HVR 09/03/2006 - Adicionado campo cNrOpSq para Identificar a sequencia do contrato
        aHEADER  := {},aCAMPOTMP := {},;
        aCAMPOS  := ARRAY(EEQ->(FCOUNT())),;
        cMARCA   := GetMark(),;
        lINVERTE := .F.,;
        cFilEF3,;
        cFilEF2,;
        cFilEF1,;
        cFilEC6,;
        lFinanciamento := EasyGParam("MV_EFF",,.F.),;
        lIntFina   := EasyGParam("MV_EEC_EFF",,.F.),;
        lACCACE    := .T. /*EasyGParam("MV_ACC_ACE",,.T.)*/ ,;
        aESTRU   := {{"EEQ_FLAG"  ,"C",02,0},;
                     {"EEQ_PREEMB","C",20,0}},;
        lParFin := EEQ->(FieldPos("EEQ_PARFIN")) > 0,;
        cProc := CriaVar("EEC_PREEMB"),;
        nSaldo := 0, nTotal := 0,;
        oSaldo, oTotal, cMoeda := Space(AvSx3("EEC_MOEDA",AV_TAMANHO)),   ;
        cBanco := SPACE(AvSx3("EEQ_BANC",AV_TAMANHO)), ; //ASK 04/09/2007 - Inclusão do filtro para o Banco no FFC
        cNCON := SPACE(AvSx3("EEQ_NCON",AV_TAMANHO)), ;
        cAGEN := SPACE(AvSx3("EEQ_AGEN",AV_TAMANHO)), ;
        cNomeBC := SPACE(AvSx3("EEQ_NOMEBC",AV_TAMANHO)) , oBanco

Private lTelaVincula := .F. //FSM - 01/03/2012

//** GFC - Pré-Pagamento/Securitização
Private lPrePag     := EF1->(FieldPos("EF1_CAREPR")) > 0 .and. EF1->(FieldPos("EF1_TPCAPR")) > 0 .and.;
                       EF1->(FieldPos("EF1_PARCPR")) > 0 .and. EF1->(FieldPos("EF1_PERIPR")) > 0 .and.;
                       EF1->(FieldPos("EF1_TPPEPR")) > 0 .and. EF1->(FieldPos("EF1_CAREJR")) > 0 .and.;
                       EF1->(FieldPos("EF1_TPCAJR")) > 0 .and. EF1->(FieldPos("EF1_PARCJR")) > 0 .and.;
                       EF1->(FieldPos("EF1_PERIJR")) > 0 .and. EF1->(FieldPos("EF1_TPPEJR")) > 0 .and.;
                       EF1->(FieldPos("EF1_PREPAG")) > 0 .and.;
                       EF1->(FieldPos("EF1_CLIENT")) > 0 .and. EF1->(FieldPos("EF1_CLLOJA")) > 0 .and.;
                       EF1->(FieldPos("EF1_ROF")) > 0    .and. EF1->(FieldPos("EF1_INI_IR")) > 0 .and.;
                       EF1->(FieldPos("EF1_FIM_IR")) > 0 .and. EF1->(FieldPos("EF1_PERCIR")) > 0 .and.;
                       EF1->(FieldPos("EF1_REAJIR")) > 0 .and. EF3->(FieldPos("EF3_SLDLIQ")) > 0 .and.;
                       EF3->(FieldPos("EF3_LIQ_RS")) > 0 .and. EF3->(FieldPos("EF3_NROP")) > 0 .and.;
                       EF3->(FieldPos("EF3_EV_VIN")) > 0 .and. EF3->(FieldPos("EF3_PARVIN")) > 0 .and.;
                       EF3->(FieldPos("EF3_SLDVIN")) > 0
//**

Private cEvent := Space(3), oImport, oForn

// ** By JBJ - 17/01/2002 - Flag Manutencao de cotaçao fechamento de câmbio.
Private lCotaCambio := .f.
Private aDelCotCam := {}

// Verifica o valor máximo permitido para alteraçào do valor em Reais.
Private nVlMaximo := EasyGParam("MV_AVGVLMX",,0) // MJA 29/12/04

// ** By JBJ - 20/05/2003 - Flag Estorno de Parcela com variação cambial.
Private lEstParVC := EasyGParam("MV_AVG0046",,.f.)
Private lTemEC6New := .F., cTX_100, cTX_520
Private lTemLiqPrm := EF1->(FieldPos("EF1_LIQPRM")) > 0 .And. EF1->(FieldPos("EF1_LIQPRR")) > 0 .And.;
                      EF1->(FieldPos("EF1_LIQJRM")) > 0 .And. EF1->(FieldPos("EF1_LIQJRR")) > 0
Private lBancoDif  := .F.

// ** JPM - 08/01/2010 - indica se a baixa gerencial é gravada logo após o OK, da mesma forma que a liquidação
Private lGrvBxgAuto := .T.
Private lIsEmb:= .T.
Private cParcSE1 := ""  // GFP - 29/05/2013
aHeader:={}
aCols := {}

If Type("lRollBack") <> "L"
   lRollBack := .F.
EndIf

//LRL 16/12/04----Usuario pode Ver outras  Filiais-------------------------------
Private lMultiFil
Private cxFil := cFilAnt

Private cTipCon  := ""
Private cTipo    := ""

Private nLinTela := 550 //465 //438 *** GFP 27/07/2011 - Alteração de tamanho de tela - M11.5  // GFP - 28/10/2013 - Inclusão de novos filtros
Private nColTela := 510

// ** JPM - 08/01/2010 - Declaração da variável.
Private aFiliais

/* ACSJ 11/MAR/2005 - Antes era usado para montar um combo box com as filiais

Private aFiliais  := AvgSelectFil(.F.)   // Pega Todas as filias que o usuario tem acesso
Private aFilNames  := AvgFilName(aFiliais)
Private aFilNome := {}
Private oCmbFil
Private lTodasFil := .F.
For i:= 1 To len(aFiliais)
   aADD(aFilNome,aFiliais[i] + " - " +aFilNames[i] )
Next
Aadd(aFilNome,"  ")*/

// BAK - Variaveis utilizada na integração mensagem unica
Private aDadosEAI := {}
Private cNumFFC := ""
Private lEaiExecAut := .F.
Private aDataContr := If(Type('aDataContr') <> 'A',{},aDataContr)

SX3->(DbSetOrder(2))              //MFR 09/06/2020 OSSME-4872
lMultiFil  := VerSenha(115) .and. FWModeAccess("EF1") == "C" .and.;
              FWModeAccess("EEQ") == "E" .AND. SX3->(DbSeek("EF3_FILORI"))




SX3->(DbSetOrder(1))

//--------------------------------LRL 16/12/04----Usuario pode Ver outras  Filiais

// ** By JBJ - 28/01/2003 - Flag Manutencao de cotaçao fechamento de câmbio.
EXG->(DBSETORDER(1))
If Select("EXG") > 0
   lCotaCambio := EXG->(FieldPos("EXG_PREEMB")) > 0 .And. EXG->(FieldPos("EXG_TX")) > 0
EndIf

SX3->(DBSETORDER(2))
Private lOkEVENT  := SX3->(dbSeek("EEQ_EVENT"))
lTemEC6New := SX3->(DbSeek("EC6_TPMODU")) .And. SX3->(DbSeek("EC6_DIAMES"))

Private lTemChave := SX3->(DBSeek("EF1_BAN_FI")) .and. SX3->(DBSeek("EF1_PRACA")) .and.;
                     SX3->(DBSeek("EF2_BAN_FI")) .and. SX3->(DBSeek("EF2_PRACA")) .and.;
                     SX3->(DBSeek("EF3_BAN_FI")) .and. SX3->(DBSeek("EF3_PRACA")) .and.;
                     SX3->(DBSeek("EF4_BAN_FI")) .and. SX3->(DBSeek("EF4_PRACA")) .and.;
                     SX3->(DBSeek("EF1_AGENFI")) .and. SX3->(DBSeek("EF1_NCONFI")) .and.;
                     SX3->(DBSeek("EF3_AGENFI")) .and. SX3->(DBSeek("EF3_NCONFI"))
                     
//NCF - 04/06/2021 - Variáveis instanciadas para utilização na subrotina de reversão de dados em caso de falha na integração FFC x EAI Msg. Única                      
Private lAdtForVin := .F.
Private lAdtForEst := .F.
Private lAdtForBkp := .F.
Private lCompenFor := .F.
Private nRecAdtFor := 0

SX3->(DBSETORDER(nOrderSX3))
If lIntFina .and. lFinanciamento
   cFilEF3 := xFilial("EF3")
   cFilEF2 := xFilial("EF2")
   cFilEF1 := xFilial("EF1")
   Private lIsContab := .F.  // PLB 18/06/07 - Identifica se o Contrato de Financiamento foi Contabilizado
EndIf
nSX3 := SX3->(INDEXORD())
SX3->(DBSETORDER(2))
IF SX3->(DBSEEK(AvKey("EEQ_FFC","X3_CAMPO"))) .And. ! X3Uso(SX3->X3_USADO)
   AADD(aESTRU,{"EEQ_FFC",AVSX3("EEQ_FFC",AV_TIPO),AVSX3("EEQ_FFC",AV_TAMANHO),AVSX3("EEQ_FFC",AV_DECIMAL)})
ENDIF

//HVR 04/04/06 VALIDA SE O CAMPO EXISTE E ADICIONA NA WORK
IF SX3->(DBSEEK(AvKey("EEQ_FFCIMP","X3_CAMPO"))) .And. ! X3Uso(SX3->X3_USADO)
   AADD(aESTRU,{"EEQ_FFCIMP",AVSX3("EEQ_FFCIMP",AV_TIPO),AVSX3("EEQ_FFCIMP",AV_TAMANHO),AVSX3("EEQ_FFCIMP",AV_DECIMAL)})
ENDIF
//HVR***

IF SX3->(DBSEEK(AvKey("EEQ_DTVC","X3_CAMPO"))) .And. ! X3Uso(SX3->X3_USADO)
   AADD(aESTRU,{"EEQ_DTVC",AVSX3("EEQ_DTVC",AV_TIPO),AVSX3("EEQ_DTVC",AV_TAMANHO),AVSX3("EEQ_DTVC",AV_DECIMAL)})
ENDIF

Aadd(aEstru,{"WK_Import","C",28,0})

//LRS - 28/09/2018
Aadd(aEstru,{"A1_COD",AVSX3("A1_COD",AV_TIPO),AVSX3("A1_COD",AV_TAMANHO),AVSX3("A1_COD",AV_DECIMAL)})

/* by jbj - 22/06/04 09:43 - Caso o campo EEQ_NRINVO não exista na base de dados,
                             o campo é incluído manualmente na estrutura da tabela
                             temporária. */
If !lNrInvo
   Aadd(aEstru,{"EEQ_NRINVO","C",20})
EndIf

If EECFlags("FRESEGCOM")
   //aAdd(aEstru,{"EEQ_IMPORT","C",AVSX3("EEQ_IMPORT",AV_TAMANHO)})
   //aAdd(aEstru,{"EEQ_IMLOJA","C",AVSX3("EEQ_IMLOJA",AV_TAMANHO)})

   //AST - 28/06/08 - verifica se os campos existem na tabela antes de incluílos no vetor
   addNaoUsado(aEstru,"EEQ_IMPORT")
   addNaoUsado(aEstru,"EEQ_IMLOJA")
EndIf

aAdd(aEstru,{"EEQ_FILORI","C",AVSX3("EEQ_FILIAL",AV_TAMANHO)+18,AVSX3("EEQ_FILIAL",AV_DECIMAL)})

aAdd(aEstru,{"EEQ_FINNUM","C",AVSX3("EEQ_FINNUM",AV_TAMANHO),AVSX3("EEQ_FILIAL",AV_DECIMAL)})

//Campo de flag utilizado pela rotina de desvinculação de parcelas da FFC
aAdd(aEstru,{"WK_DEFLAG"  ,"C",02,0})

//TRP - 29/01/07 - Campos do WalkThru
AADD(aESTRU,{"TRB_ALI_WT","C",03,0})
AADD(aESTRU,{"TRB_REC_WT","N",10,0})

If EEQ->(FieldPos("EEQ_MODAL")) > 0
   aAdd(aESTRU,{"EEQ_MODAL",AVSX3("EEQ_MODAL",AV_TIPO),AVSX3("EEQ_MODAL",AV_TAMANHO),AVSX3("EEQ_MODAL",AV_DECIMAL)})
EndIf

If EEQ->(FieldPos('EEQ_BCOEXT')) > 0 .And. EEQ->(FieldPos('EEQ_AGCEXT')) > 0 .And. EEQ->(FieldPos('EEQ_CNTEXT')) > 0
   aAdd(aESTRU,{'EEQ_BCOEXT',AVSX3('EEQ_BCOEXT',AV_TIPO),AVSX3('EEQ_BCOEXT',AV_TAMANHO),AVSX3('EEQ_BCOEXT',AV_DECIMAL)})
   aAdd(aESTRU,{'EEQ_AGCEXT',AVSX3('EEQ_AGCEXT',AV_TIPO),AVSX3('EEQ_AGCEXT',AV_TAMANHO),AVSX3('EEQ_AGCEXT',AV_DECIMAL)})
   aAdd(aESTRU,{'EEQ_CNTEXT',AVSX3('EEQ_CNTEXT',AV_TIPO),AVSX3('EEQ_CNTEXT',AV_TAMANHO),AVSX3('EEQ_CNTEXT',AV_DECIMAL)})
EndIf

If EEQ->(FieldPos('EEQ_TPPROC')) > 0 .And. EEQ->(FieldPos('EEQ_REGIST')) > 0
   aAdd(aESTRU,{'EEQ_TPPROC',AVSX3('EEQ_TPPROC',AV_TIPO),AVSX3('EEQ_TPPROC',AV_TAMANHO),AVSX3('EEQ_TPPROC',AV_DECIMAL)})
   aAdd(aESTRU,{'EEQ_REGIST',AVSX3('EEQ_REGIST',AV_TIPO),AVSX3('EEQ_REGIST',AV_TAMANHO),AVSX3('EEQ_REGIST',AV_DECIMAL)})
EndIf

//RRC - 01/02/2013 - Verifica se o Alias já está em uso
If Select("TMP") > 0
   TMP->(DbCloseArea())
EndIf

SX3->(DBSETORDER(nSX3))
cWORKEEQ  := E_CRIATRAB("EEQ",aESTRU,"TMP")
//INDREGUA("TMP",cWORKEEQ+TEOrdBagExt(),"EEQ_PREEMB + Substr(WK_IMPORT,1,6) + EEQ_NRINVO + EEQ_PARC","AllwayTrue()","AllwaysTrue()",STR0001) //"Processando Arquivo Temporario"
INDREGUA("TMP",cWORKEEQ+TEOrdBagExt(),"EEQ_PREEMB + EEQ_IMPORT + EEQ_NRINVO + EEQ_PARC","AllwayTrue()","AllwaysTrue()",STR0001) //"Processando Arquivo Temporario" #### THTS - 13/10/2017 - Projeto temporario no banco de dados

FileWork:=E_Create(,.F.)
IndRegua("TMP",FileWork+TEOrdBagExt(),"EEQ_PREEMB + EEQ_NRINVO + EEQ_PARC")

FileWork1:=E_Create(,.F.)
IndRegua("TMP",FileWork1+TEOrdBagExt(),"EEQ_PREEMB + EEQ_PARC")

SET INDEX TO (cWORKEEQ+TEOrdBagExt()),(FileWork+TEOrdBagExt()),(FileWork1+TEOrdBagExt())

/*
If lOkEVENT
   FileWork:=E_Create(,.F.)
   IndRegua("TMP",FileWork+OrdBagExt(),"EEQ_NRINVO+EEQ_PARC")
   SET INDEX TO (cWORKEEQ+OrdBagExt()),(FileWork+OrdBagExt())
Else
   SET INDEX TO (cWORKEEQ+OrdBagExt())
EndIf
*/

// ** By JBJ - 17/01/03 - Work para cotação de fechamento de FFC.
If lCotaCambio
   aCampos:= Array(EXG->(FCount()))
   Aadd(aSemSx3,{"RECNO","N",10,0})

   //TRP - 29/01/07 - Campos do WalkThru
   AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
   AADD(aSemSX3,{"TRB_REC_WT","N",10,0})

   cArq   := E_CriaTrab("EXG",aSemSx3,"Work_Cot")
   IndRegua("Work_Cot",cArq+TEOrdBagExt(),"EXG_PREEMB+EXG_PARC+EXG_BANC+EXG_CORR",,,STR0032) //"Processando Arquivo Temporário..."
   Set Index To (cArq+TEOrdBagExt())
   aCampos:=Array(EEQ->(FCount()))
EndIf

If lIntFina
   If !ChkFile("EC6")
      MsgInfo(STR0062) //"Arquivo de eventos contábeis não pôde ser aberto."
      Return .T.
   EndIf
   cFilEC6 := xFilial("EC6")
   EC6->(DbSetOrder(6))
   EC6->(DbSeek(xFilial("EC6")+If(lTemEC6New,"FIEX01","")+'100'))
   cTX_100 := EC6->EC6_TXCV
   EC6->(DbSeek(xFilial("EC6")+If(lTemEC6New,"FIEX01","")+'520'))
   cTX_520 := EC6->EC6_TXCV
   EC6->(DbSetOrder(1))
EndIf

DO WHILE .T.
   If lCotaCambio
      DbSelectArea("Work_Cot")
      Work_Cot->(DbSetOrder(1))
      AvZap()
   EndIf

   If Select("TMP") == 0
      AF300AbTMP('2')
      AvZap()
   Else
      DBSELECTAREA("TMP")
      TMP->(dbSetOrder(3))
      AvZap()
   EndIf

   dVENCTI  := dVENCTF := dEMBARI := dEMBARF := dDTNEG := dIniCrd := dFimCrd := AVCTOD("  /  /  ")  // GFP - 28/10/2013
   bOK      := {||nOpc:=1,oDlg:End()}
   nDIASPAG := nOPC := 0
   cNOME    := SPACE(40)
   cNomeForn:= SPACE(40)
   cREFBANC := SPACE(20)
   cFFC     := Space(AvSx3("EEQ_FFC",AV_TAMANHO))

   //AAF 01/12/05 - Tipo de Contrato (EEQ_TP_CON).
   cTipCon  := ""
   aTipCon  := ComboX3Box("EEQ_TP_CON", X3Cbox())
   cTipo    := ""
   aTipos   := ComboX3Box("EEQ_TIPO", X3Cbox())
   aAdd(aTipCon, "")
   aAdd(aTipos , "")

   If lOkEVENT
      cInvoice := Space(Len(EEQ->EEQ_NRINVO))
      cEvent   := Space(3)
   EndIf

   cImport  := Space(AvSx3("EEC_IMPORT",AV_TAMANHO))
   cFornec	:= Space(AvSx3("EEC_FORN"  ,AV_TAMANHO))
   cLojaFor := Space(AvSx3("EEC_FOLOJA"  ,AV_TAMANHO)) //MCF - 13/06/2016
   cLojaImp := Space(AvSx3("EEC_IMLOJA"  ,AV_TAMANHO)) //MCF - 13/06/2016
   cNrOp    := Space(AvSX3("EEQ_NROP"  ,AV_TAMANHO))
// HVR 09/03/2006 - Adicionado o campo cNrOpSq para identificar a sequencia do contrato (Validando se o campo existe)
   If lEFFTpMod
      cNrOpSq  := Space(AvSX3("EF1_SEQCNT"  ,AV_TAMANHO))
   EndIf //HVR***
   cCondPag := Space(AvSx3("EEC_CONDPA",AV_TAMANHO))
   cNomeCon := Space(AvSx3("Y6_VM_DESP",AV_TAMANHO))
   cProc    := Space(Avsx3("EEC_PREEMB",AV_TAMANHO))

   If !lEaiExecAut
      lEstorno := .f.
   EndIf

   //  ACSJ - 11/MAR/2005 - Inicio
   Private cFil   := ""
   
   If ValType(aFiliais) == "U"
      If lMultiFil
        aFiliais := AvgSelectFil(.T.,"EEQ")
      Else
        aFiliais := {}
        AAdd (aFiliais, xFilial("EEQ"))
      EndIf
   EndIf
   
   If aFiliais[1] <> "WND_CLOSE"

      For i:= 1 to Len(aFiliais)
         cFil+="'"+aFiliais[i]+"'"
         If i<Len(aFiliais)
            cFil+=","
         EndIF
      Next
      // ------------------- - Fim

      // Criação de Ponto de Entrada para permitir alterar o tamanho da tela - DFS - 02/02/2009
      If EasyEntryPoint("EECAF300")
         ExecBlock("EECAF300",.F.,.F.,"AF300_ANTES_TELAFFC")
      EndIf

      If lCallRS403
         If cTipoCon == "A"
            cTipCon := "4"
         Else
            cTipCon := "3"
         EndIf
         cTipo := cTipoReg
      EndIf

      aButManut := {} // GFP - 28/10/2013
      If FindFunction("H_RELFFC")
         aAdd(aButManut,{"PRECO"  ,{||AF300Rel()},STR0130,STR0130}) //GFP - 28/10/2013  //"Rel. FFC"
      EndIf

      If !lEaiExecAut
         Define MsDialog oDlg Title STR0002 From 0,0 To nLinTela,nColTela Of oMainWnd Pixel //"Manutenção De FFC"
            @ 16,02 To /*219*/231,254 LABEL STR0102 Pixel //STR0102	" Parâmetros Iniciais "  // GFP - 28/10/2013
            nLin:=25

            oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165)
            oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

            // Nro FFC.
            @ nLin,009 Say STR0003 OF oPanel Pixel //"Nro. FFC"
            @ nlin,042 MsGet cFFC   Picture cPICTFFC Size 040,08 When(Empty(cProc));
                                  Valid(Af300Val(1)) F3(IF(lMultiFil,"FFCFIL","EEQ"))OF oPanel Pixel// OF oDlg

            If !lCallRS403
               If EEQ->( FieldPos("EEQ_TIPO") ) > 0
                  @ nLin+12,009 Say AvSX3("EEQ_TIPO", AV_TITULO)OF oPanel Pixel
                  @ nLin+12,042 ComboBox cTipo Items aTipos Valid( AF300VAL(20,cTipo)) Size 80, 08  OF oPanel Pixel// Of oDlg
               EndIf
               // Código do Evento.
               @ nLin+12,165 Say STR0103 OF oPanel Pixel //FONT oDlg:oFont COLOR CLR_HBLUE -Não será mais obrigatório //STR0103	"Evento"
               @ nLin+12,185 MsGet cEvent Picture "@!" SIZE 040,08 F3("E21");
                                     When(Empty(cFFC) .And. lOkEVENT .And. EECFlags("FRESEGCOM")) Valid(Af300Val(17))OF oPanel Pixel// Of oDlg
            Else
               // Código do Evento.
               @ nLin+12,009 Say STR0103 OF oPanel Pixel //FONT oDlg:oFont COLOR CLR_HBLUE -Não será mais obrigatório //STR0103	"Evento"
               @ nLin+12,042 MsGet cEvent Picture "@!" SIZE 040,08 F3("E21");
                                     When(Empty(cFFC) .And. lOkEVENT .And. EECFlags("FRESEGCOM")) Valid(Af300Val(17))OF oPanel Pixel// Of oDlg
            EndIf
            // Nro do Processo de Embarque.
            @ nLin,090 Say STR0060 OF oPanel Pixel //"Processo"
            @ nLin,120 MsGet cProc Picture Avsx3("EEC_PREEMB",AV_PICTURE) F3(If(lMultiFil,"EMBFIL","EEC")) Size 070,08 When(Empty(cFFC));
                                  Valid (If(!Empty(cProc) .AND. !lMulTiFil ,ExistCpo("EEC",cProc),.t.) .And. AF300VAL(16))OF oPanel Pixel// Of oDlg

            // Moeda.
            @ nLin+24,009 Say STR0076  OF oPanel  Pixel FONT oDlg:oFont COLOR CLR_HBLUE //"Moeda"
            @ nLin+24,042 MsGet cMoeda   Picture "@!" Size 040,08 OF oPanel Pixel;// Of oDLG;
                                  When(EMPTY(cFFC) .AND. Empty(cProc)) F3("SYF") Valid(AF300Val(14,cMoeda))

            // Importador.
            @ nLin+36,009 Say STR0004 OF oPanel  Pixel
            @ nLin+36,042 MsGet oImport Var cImport  Picture "@!" Size 040,08  When(Af300W("IMPORT") .And. Empty(cFFC) .And. Empty(cProc)) F3("SA1");
                                   Valid(AF300VAL(2,cIMPORT))OF oPanel Pixel// Of oDlg

            // "Loja"
            @ nLin+36,085 Say STR0138 OF oPanel Pixel  //MCF - 13/06/2016
            @ nLin+36,098 MsGet cLojaImp Picture "@!" Size 032,08 When(Af300W("IMPLOJA") .And. Empty(cFFC) .And. Empty(cProc));
                                   Valid(AF300VAL(21,cLojaImp))OF oPanel Pixel
            // Descrição do importador.
            @ nLin+48,009 Say STR0005  OF oPanel  Pixel //"Nome"
            @ nLin+48,042 MsGet cNOME    Picture "@!" Size 205,08 When(.f.) OF oPanel Pixel// Of oDlg

            // Codigo da Invoice.
            @ nLin+60,009 Say STR0033 OF oPanel   Pixel //"Invoice"
            @ nLin+60,042 MsGet cInvoice Picture "@!" Size 070,08 When( Empty(cFFC) .And. lOkEVENT);
                                  F3(If(lMultiFil,"INVFIL","E18")) VALID(AF300VAL(10,cInvoice))OF oPanel Pixel// Of oDlg

         If !lCallRS403
            // Condição de Pagamento.
            @ nLin+72,009 Say STR0006  OF oPanel  Pixel //"Cond. Pagto."
            @ nLin+72,042 MsGet cCONDPAG Picture "@!" Size 040,08 When(Empty(cFFC) .And. Empty(cProc)) F3("SY6");
                                  Valid(AF300VAL(4,cCONDPAG))OF oPanel Pixel// Of oDlg

            // Dias da condição de pagamento.
            @ nLin+72,085 Say STR0007  OF oPanel  Pixel //"Dias Pagto."
            @ nLin+72,115 MsGet nDIASPAG Picture "999" Size 040,08 When(Empty(cFFC) .And. !Empty(cCONDPAG) .And. Empty(cProc));
                                  Valid(AF300VAL(4,cCONDPAG,nDIASPAG))OF oPanel Pixel// Of oDlg

            // Descrição da condição de pagamento.
            @ nLin+84,009 Say STR0008  OF oPanel  Pixel //"Descrição"
            @ nLin+84,042 MsGet cNOMECON Picture "@!"  SIZE 205,08 When(.f.)OF oPanel Pixel// OF oDLG

            // Cód. do Fornecedor.
            @ nLin+96 ,009 Say STR0063 OF oPanel   Pixel FONT oDlg:oFont COLOR CLR_HBLUE // "Fornecedor"
         Else
            @ nLin+96 ,009 Say STR0063 OF oPanel  Pixel
         EndIf
         @ nLin+96,042 MsGet cFornec  Picture "@!" Size 040,08 When(If(lCallRS403,cTipo=="P",Af300W("FORN") .And. Empty(cFFC) .And. Empty(cProc)));
                                               F3("FOR") Valid( AF300VAL(12,cFornec)) OF oPanel Pixel// Of oDLG
         // "Loja"
         @ nLin+96,085 Say STR0138 OF oPanel Pixel //MCF - 13/06/2016
         @ nLin+96,098 MsGet cLojaFor Picture "@!" Size 032,08 When(If(lCallRS403,cTipo=="P",Af300W("FORNLOJA") .And. Empty(cFFC) .And. Empty(cProc)));
                                                         Valid( AF300VAL(20)) OF oPanel Pixel

         // Descrição do Fornecedor.
         @ nLin+108,009 Say STR0005 OF oPanel  Pixel  //  "Nome"
         @ nLin+108,042 MsGet oForn Var cNomeForn Picture "@!" Size 205,08 When(.f.)OF oPanel Pixel// Of oDlg

         // Número da Operação // HVR 09/03/2006 - Adicionado o campo cNrOpSq para identificar a sequencia do contrato
         @ nLin+120,009 Say AVSX3("EEQ_NROP",AV_TITULO)OF oPanel Pixel
         @ nLin+120,042 MsGet cNrOp  Picture AVSX3("EEQ_NROP",AV_PICTURE) Valid(Vazio() .Or. AF300Val(15,cMoeda)) Size 040,08 OF oPanel Pixel// Of oDLG

         If lEFFTpMod      // HVR 09/03/2006 - Adicionado o campo cNrOpSq para identificar a sequencia do contrato - verifica se este campo já existe
            @ nLin+120,084 Say AVSX3("EF1_SEQCNT",AV_TITULO)OF oPanel Pixel
            @ nLin+120,117 MsGet cNrOpSq  Picture AVSX3("EF1_SEQCNT",AV_PICTURE) Size 040,08 OF oPanel Pixel// Of oDLG
         EndIf
         // ** Período para filtro a partir do vencimento das parcelas.
         @ nLin+132,009 Say STR0009 OF oPanel  Pixel //"Vencimento"
         @ nLin+132,042 MsGet dVENCTI Picture "@D"  Size 040,08 When(Empty(cFFC))OF oPanel Pixel// Of oDlg

         @ nLin+132,085 Say STR0010 OF oPanel  Pixel //"Até"
         @ nLin+132,100 MsGet dVENCTF Picture "@D" Size 040,08 When(Empty(cFFC));
                                Valid(AF300VAL(3,dVENCTF,dVENCTI,STR0011))OF oPanel Pixel// Of oDlg //"Intervalo de Vencimentos Inválido"

         If !lCallRS403
            // ** Período para filtro a partir da data de embarque.
            @ nLin+144,009 Say STR0012 OF oPanel  Pixel //"Embarque"
            @ nLin+144,042 MsGet dEmbarI Picture "@D" Size 040,08  When (Empty(cFFC) .And. Empty(cProc))OF oPanel Pixel// Of oDlg

            @ nLin+144,085 Say STR0010  OF oPanel Pixel //"Até"
            @ nLin+144,100 MsGet dEmbarF Picture "@D"  Size 040,08 When(Empty(cFFC) .And. Empty(cProc));
                                 Valid(AF300VAL(3,dEmbarF,dEmbarI,STR0013))OF oPanel Pixel// Of oDLG //"Intervalo de Embarques Inválido"
         EndIf

         // ASK 04/09/2007 Filtro por Banco
         @ nLin+156,009 Say STR0042 OF oPanel  Pixel //"Banco"
         @ nLin+156,042 MsGet cBanco Picture "!@" Size 040,08  /*When (Empty(cFFC) .And. Empty(cProc)) */;
                                                  F3("SA6") Valid(AF300VAL(7,cBanco))OF oPanel Pixel// Of oDLG

         @ nLin+156,085 Say STR0043 OF oPanel  Pixel //"Agencia"
         @ nLin+156,115 MsGet cAGEN Picture "!@"  Size 040,08 When(Empty(cFFC) .And. Empty(cProc) .And. ;
                                                     Empty(cBanco)) Valid(AF300VAL(7,cBanco))OF oPanel Pixel// Of oDLG
         @ nLin+156,160 Say STR0044 OF oPanel  Pixel //"Conta"
         @ nLin+156,190 MsGet cNCON Picture "!@" Size 040,08  When (Empty(cFFC) .And. Empty(cProc) .And.;
                                                       Empty(cBanco)) Valid(AF300VAL(7,cBanco))OF oPanel Pixel// Of oDlg

         @ nLin+168,009 Say STR0005+STR0042 OF oPanel  Pixel //"Nome do Banco"
         @ nLin+168,042 MsGet oBanco Var cNOMEBC Picture "!@"  Size 205,08 When(.F.) OF oPanel Pixel// Of oDLG //"Intervalo de Embarques Inválido"


         //** AAF 01/12/05 - Filtro por Tipo de Contrato (EEQ_TP_CON) e Tipo de câmbio(Receber/Pagar).
         If EEQ->( FieldPos("EEQ_TP_CON") ) > 0
            @ nLin+180,009 Say AvSX3("EEQ_TP_CON", AV_TITULO)OF oPanel Pixel
            @ nLin+180,042 ComboBox cTipCon Items aTipCon Size 80, 08 OF oPanel Pixel// Of oDlg
         EndIf
         //**

         // GFP - 28/10/2013
         @ nLin+192,009 Say STR0131 OF oPanel Pixel //"Cdto.Exterior"
         @ nLin+192,042 MsGet dIniCrd Picture "@D"  Size 040,08 When(Empty(cFFC))OF oPanel Pixel// Of oDlg

         @ nLin+192,085 Say STR0010 OF oPanel Pixel //"Até"
         @ nLin+192,100 MsGet dFimCrd Picture "@D" Size 040,08 When(Empty(cFFC));
                                Valid(AF300VAL(3,dFimCrd,dIniCrd,STR0011)) OF oPanel Pixel// Of oDlg //"Intervalo de Vencimentos Inválido"

         @ nLin+275,042 MsGet cx OF oPanel Pixel// Of oDlg

         // Criação de Ponto de Entrada para permitir a criação de um nova opção de filtro - DFS - 02/02/2009
         If EasyEntryPoint("EECAF300")
            ExecBlock("EECAF300",.F.,.F.,{"AF300_TELAFILTROS", oDlg})
         EndIf

         Activate MsDialog oDlg Centered On Init EnchoiceBar(oDlg,{|| If(Af300ValTela(),Eval(bOK),)},bCANCEL,,aButManut)  // GFP - 28/10/2013
      Else
         cFFC := cNumFFC
         nOpc := 1
      EndIf
   EndIf

   IF nOPC = 0
      EXIT
   ENDIF

   nTotal := 0

   lFFC := IF(EMPTY(cFFC),.T.,.F.) // .T.->INCLUI FFC E .F.->ALTERA FFC

   //Definições de VALID dos campos
   INCLUI := lFFC
   ALTERA := !lFFC

   MSAGUARDE({|| If(lCallRS403,AF300Registro(),AF300A())},STR0014) //"Aguarde"
   dbSelectArea("TMP")
   IF TMP->(BOF() .AND. EOF())
      HELP(" ",1,"AVG0005097") //MSGINFO("Não Existe Dados Nestas Condições","Atenção")
      LOOP
   ENDIF

   IF ! lFFC
      cFLAG := ""
      bOK2  := {||nOpc:=1,oDlg:End()}

      aButtons:={}
      If lCotaCambio
         aAdd(aButtons,{"PRECO"  ,{||AF300CotaCam()},STR0034,STR0034/*STR0091*/}) //"Cotação de Câmbio" # "Cot.Camb" //FSM - 14/11/2012
      EndIf

      IF EMPTY(TMP->EEQ_PGT)
         // ** By JBJ - 22/07/03 - 18:03 (Botão visualizar para FFC já liquidado).
         aAdd(aButtons,{"BMPVISUAL" /*"ANALITICO"*/, {|| AF300SAL(.F.,Nil,.t.)} ,STR0037}) //"Visualizar"
         aAdd(aButtons,{"TABPRICE" /*"SALARIOS"*/,{|| IF(AF300SAL(.T.),(EVAL(bOK2),lLiq:=.t.),"")},STR0058, STR0058/*STR0092*/}) //"Liquidar FFC" # "Liq.FFC" //FSM - 14/11/2012
         aAdd(aButtons,{"EXCLUIR" ,{|| IF(AF300ESTF()  ,EVAL(bOK2),"")}, "Estornar FFC" , "Estornar FFC" }) // STR0016,STR0016 /*STR0093*/ - "Estorna FFC" # "Est.FFC" //FSM - 14/11/2012
         If lOkEVENT
            aAdd(aBUTTONS,{"PESQUISA",{|| AF300PesqInv() }, STR0029, STR0029/*STR0094*/ }) //"Pesquisar Invoice" # "Pesq.Inv"//FSM - 14/11/2012
         EndIf
      ELSE
         // ** By JBJ - 22/07/03 - 18:03 (Botão visualizar para FFC já liquidado).
         aAdd(aButtons,{"BMPVISUAL" /*"ANALITICO"*/, {|| AF300SAL(.F.,Nil,.t.)} ,STR0037}) //"Visualizar"
         // by CAF 09/04/2004 aAdd(aButtons,{"EXCLUIR"  , {|| IF(AF300ESTB() ,EVAL(bOK2),"")},STR0016  }) //"Estorna FFC"
         aAdd(aButtons,{"EXCLUIR"  , {|| IF(lEstorno := AF300MsgEst(),EVAL(bOK2),"")}, "Estornar Liquidação FFC","Estornar Liquidação FFC" }) // STR0016, STR0016/*STR0093*- "Estorna FFC" # "Est.FFC" //FSM - 14/11/2012

         If lOkEVENT
            aAdd(aBUTTONS,{"PESQUISA",{|| AF300PesqInv() }, STR0029, STR0029/*STR0094*/}) //"Pesquisar Invoice" # "Pesq.Inv"//FSM - 14/11/2012
         EndIf
      ENDIF

      //GFP - 28/10/2013
      aAdd(aButtons,{"MENURUN" ,{|| If(lSairTela := AF300VincParc(), oDlg:End(),) }, STR0132 , STR0132 })  //"Vincular Parcela"

      //RMD - 02/01/07 - Incluída nova funcionalidade para desvincular parcelas da FFC
      aAdd(aButtons,{"MENURUN" /*"NOVACELULA"*/,{|| If(lSairTela := AF300DesvParc(), oDlg:End(),) }, STR0084, STR0084/*STR0095*/})//"Desvincular Parcelas" # "Desv.Parc" //FSM - 14/11/2012

      If EECFlags("CAMBIO_EXT")
         aAdd(aButtons,{"BUDGET",{|| AF300BXG(), oMSELECT:oBrowse:Refresh() },"Baixa Gerencial", "Baixa Gerencial"/*"Bx. Geren."*/}) //FSM - 14/11/2012
      EndIf

   ELSE
      cFLAG    := "EEQ_FLAG"
      lBancoDif := .F.
      bOK2     := {||nOpc:=1,IF(AF300VAL(9).AND.AF300GFFC(),oDlg:End(),nOPC:=0)}
      aBUTTONS := {{"LBTIK"    ,{|| AF300TODOS()},STR0018, STR0018/*STR0096*/ },; //"Marca/Desmarca Todos" # "Todos" //FSM - 14/11/2012
                   {"BMPVISUAL" /*"ANALITICO"*/,{|| AF300SAL(.F.,Nil,.t.)},STR0019, STR0019/*STR0097*/} } //"Visualizar Parcela" # "Vis.Parc" //FSM - 14/11/2012
      If lOkEVENT
         aAdd(aBUTTONS,{"PESQUISA",{|| AF300PesqInv() }, STR0029, STR0029/*STR0094*/}) //"Pesquisar Invoice" # "Pesq.Inv" //FSM - 14/11/2012
      EndIf

      cFilAnt := aFiliais[1]  //LRL-22/12/04-Garantir que o numero não se repita entre as filiais

      cFFC    := SeqCodFFC()//Carrega código do FFC com base em parâmetro, substituindo a GetSXENum("EEQ","EEQ_FFC")

      cFilAnt :=cxFil   //LRL-22/12/04-Garantir que o numero não se repita entre as filiais
   ENDIF
   cNrFFC := cFFC

   nOPC := 0
   nSaldo := 0

   aPos	:= {}

   oMainWnd:ReadClientCoords()

   Aadd(aPos,oMainWnd:nTop)
   Aadd(aPos,oMainWnd:nLeft)
   Aadd(aPos,oMainWnd:nBottom)
   Aadd(aPos,oMainWnd:nRight)

    // Criação de Ponto de Entrada para para permitir a criação de um novo botão - DFS - 02/02/2009
    If EasyEntryPoint("EECAF300")
       ExecBlock("EECAF300",.F.,.F.,"AF300_TELAFFC")
    EndIf

    If !lEaiExecAut
       DEFINE MSDIALOG oDlg TITLE IF(EMPTY(cFFC),STR0020,STR0002) FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL //"Inclusão de FFC"###"Manutenção de FFC"

       oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165)
       oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

       @ 15,005 SAY STR0003   Of oPanel PIXEL //"Nro. FFC"
       @ 13,040 MSGET cFFC     PICTURE cPICTFFC SIZE 040,08 PIXEL OF oPanel WHEN .F. VALID(AF300VAL(5))//RMD - 19/10/2006 - Número da FFC passou a ser controlado por numeração automática.

       @ 15,170 Say STR0076   Of oPanel PIXEL //"Moeda"
       @ 13,205 MsGet cMoeda   PICTURE "@!"     Size 040,08 PIXEL of oPanel When(.f.)
       *
       @ 25,005 SAY STR0004   Of oPanel PIXEL //"Importador"
       @ 23,040 MSGET cIMPORT  PICTURE "@!"     SIZE 040,08 PIXEL OF oPanel WHEN(.F.)
       @ 35,005 SAY STR0005   Of oPanel PIXEL //"Nome"
       @ 33,040 MSGET cNOME    PICTURE "@!"     SIZE 205,08 PIXEL OF oPanel WHEN(.F.)
       *
       @ 45,005 SAY STR0006   Of oPanel PIXEL //"Cond. Pagto."
       @ 43,040 MSGET cCONDPAG PICTURE "@!"     SIZE 040,08 PIXEL OF oPanel WHEN(.F.)
       @ 55,005 SAY STR0007   Of oPanel PIXEL //"Dias Pagto."
       @ 53,040 MSGET nDIASPAG PICTURE "999"    SIZE 040,08 PIXEL OF oPanel WHEN(.F.)
       @ 65,005 SAY STR0008   Of oPanel PIXEL //"Descrição"
       @ 63,040 MSGET cNOMECON PICTURE "@!"     SIZE 205,08 PIXEL OF oPanel WHEN(.F.)

       @ aPos[1]+20, (aPos[2]+250) TO (aPos[1]+78), (aPos[1]+400)  PIXEL

       @ 28,250 Say STR0064 oF oPanel PIXEL   // "Valor Total das Invoices    "
       @ 26,325 MSGET oTotal Var nTotal PICTURE "@E 9,999,999,999.99" SIZE 65,08 PIXEL OF oPanel WHEN(.F.)

       @ 57,250 Say STR0065 Of oPanel PIXEL   // "Valor das Invoices Marcadas "
       @ 55,325 MSGET oSaldo Var nSaldo PICTURE "@E 9,999,999,999.99" SIZE 65,08 PIXEL OF oPanel WHEN(.F.)
       *
       aPOS     := POSDLGDOWN(oDLG)
       aPOS[1]  := 120

       //by CRF 18/10/2010 - 09:44
       aCampoTMP := AddCpoUser(aCampoTMP,"EEQ","2")

       oMSELECT := MsSelect():New("TMP",cFLAG,,aCampoTMP,@lInverte,@cMarca,aPOS)

       IF EMPTY(cFLAG)
          AF300Marca(cMarca,.t.)
          oMSELECT:bAval := {|| AF300SAL(.F.)}
       Else
          // Gera Saldo - By A. Caetano Jr. - 02/12/2003
          oMSELECT:bAval := {|| AF300Marca(cMarca) }
       ENDIF

      ACTIVATE MSDIALOG oDlg ON INIT ENCHOICEBAR(oDLG,bOK2,bCANCEL,,aBUTTONS)
   Else
      If !lEstorno
         AF300SAL(.T.,,,lEaiExecAut)
      EndIf
      lSairTela := .F.
      nOpc := 1
   EndIf

   lRet := .T.
   If !lSairTela

      IF nOPC = 1

         If FindFunction("EasyEAIBuffer")
            lEaiBuffer := .T.
            EasyEAIBuffer("INICIO")
         EndIf

         //Begin Transaction
            IF lFFC
               CONFIRMSX8()
               MSAGUARDE({|| lRet := AF300B()},STR0014) //"Aguarde"
               // ** By JBJ - 20/01/03 - Mostra nro FFC gerado.
               If lRet
                  MsgInfo(STR0059+Transf(cFFC,AVSX3("EEQ_FFC",AV_PICTURE)),STR0036)          //"Aviso" //" FFC Nro: "
               EndIf
            ELSE
               // Chamar rotina de estorno / ponto de entrada.
               IF lEstorno
                  lRet := AF300ESTB(.F.,.T.)
               Endif

               If lRet
                  MSAGUARDE({|| lRet := AF300C(lLiq)},STR0014) //"Aguarde"
               EndIf

               //NCF - 01/09/2014 - Ordenar integrações de estorno de baixa por ordem decrescente de sequencias de baixa
               If lEstorno .and. lEaiBuffer
                  EasyEAIOrd("EECAF221",5,"EEQ","EEQ_SEQBX",.T.)
               EndIf
            ENDIF

         //End Transaction
         //ELinkClearID()
 		 //If lEaiBuffer .And. !EasyEAIBuffer("FIM",,.F.)
 		 If !EasyEAIBuffer("FIM",bOnError)
            AF200RevFin(.T.)
            If lEstorno
               lLiq := .T.
               lEstorno := .F.
            Else
               lEstorno := .T.
               lLiq := .F.
            EndIf
            //lEaiExecAut := .T.     //NCF - 21/10/2014
            //Loop                   //NCF - 21/10/2014
         Else
            lEaiExecAut := .F.
            aDadosEAI  := {}
            aDataContr := {}
         EndIf

         aParcLiq := {}

      Else
         //RollBackSxE() - Numeração passou a ser parametrizada.
         If lFFC
            SeqCodFFC(.T., cFFC)//Cancela o uso da sequência
         EndIf
         lRet:= .F.
      ENDIF

      If IsInCallStack("ESSRS403")
         Exit
      EndIf

   EndIf

ENDDO
TMP->(E_EraseArq("TMP"))

// ** By JBJ - 17/01/03 - Work de cotacao de fechamento de FFC.
If lCotaCambio
   Work_Cot->(E_EraseArq("Work_Cot"))
EndIf

If lOkEVENT
   FERASE(FileWork)
EndIf
RESTORD(aORDANT)
cFilAnt:=cxFil
RETURN(NIL)

/*
Função     : Af300ValTela()
Objetivos  : Validar Botão Ok na tela inicial de parâmetros de FFC.
Parâmetros : Nenhum.
Retorno    : .T./.F.
Autor      : João Pedro Macimiano Trabbold
Data       : 21/03/06 às 11:58
*/
*---------------------*
Function Af300ValTela()
*---------------------*
Local lRet := .T.

Begin Sequence

   If !AF300Val(13) .Or. !AF300VAL(15)
      lRet := .F.
      Break
   EndIf

   If EasyEntryPoint("EECAF300")
      If ValType((lRet := ExecBlock("EECAF300",.F.,.F.,{"VALIDA_TELA"}))) <> "L"
         lRet := .T.
      EndIf
      If !lRet
         Break
      EndIf
   Endif

End Sequence

Return lRet

*--------------------------------------------------------------------
STATIC FUNCTION AF300VAL(nP_ACAO,nP_CMP1,nP_CMP2,nP_CMP3)
LOCAL cAUX, nNumAux
Local lOk ,i //LRL 20/12/04
Local nReg, lRet   // By JPP - 21/02/2006 - 14:00
Local lDtNego:= .F.
Local lMovExt := .F.
Local lBcoExt := .F.
Local lTemBcoExt := .F.
Local cBanExt := ""
Local cAgeExt := ""
Local cNConExt := ""

//** ASK Tela de divergência para informações bancarias das parcelas selecionadas. ver NP_ACAO 9
Private cFile     :=""
Private cMask     := "Arquivos Texto (*.TXT) |*.txt|"
Private cTexto := ''
IF nP_ACAO = 1
   IF ! EMPTY(cFFC)
      cFFC := IF(TYPE(cFFC)="N",STRZERO(VAL(cFFC),LEN(cFFC),0),cFFC)
      EEQ->(DBSETORDER(2))
      //LRL-20/12/04-------Considera todas as Filiais--------------------------------------------------------
      If lMultiFil
         lOk := .F.
         For i:= 1 To Len(aFiliais)
             If EEQ->(DBSEEK(aFiliais[i]+cFFC))
                lOk := .T.
//                cFil:="  "
//                lTodasFil:=.T.
                cFilAnt:=cxFil
                Exit
             EndIf
         Next
         If !lOk
            HELP(" ",1,"AVG0005098") //MSGINFO("Número de FFC Inválido","Atenção")
            RETURN(.F.)
         EnDIf
      ELSEIF ! (EEQ->(DBSEEK(XFILIAL("EEQ")+cFFC)))
      //--------------------------------------------------------LRL-20/12/04-------Considera todas as Filiais
         HELP(" ",1,"AVG0005098") //MSGINFO("Número de FFC Inválido","Atenção")
         RETURN(.F.)
      ENDIF

      If lOkEvent
         cEvent    := Space(AvSx3("EEQ_EVENT" ,AV_TAMANHO))
      EndIf
      cProc     := Space(AvSx3("EEC_PREEMB",AV_TAMANHO))
      cMoeda    := Space(AvSx3("EEC_MOEDA" ,AV_TAMANHO))
      cImport   := Space(AvSx3("EEC_IMPORT",AV_TAMANHO))
      cNome     := Space(40)
      cFornec   := Space(AvSx3("EEC_FORN",AV_TAMANHO))
      cNrOp     := Space(AvSX3("EEQ_NROP",AV_TAMANHO))
      If lEFFTpMod      // HVR 09/03/2006 - Adicionado o campo cNrOpSq para identificar a sequencia do contrato
         cNrOpSq   := Space(AvSX3("EF1_SEQCNT",AV_TAMANHO))
      EndIf  //HVR***
      cNomeForn := Space(40)
      cCondPag  := Space(AvSx3("EEC_CONDPA",AV_TAMANHO))
      nDiasPag  := 0
      cNomeCon  := Space(AvSx3("Y6_VM_DESP",AV_TAMANHO))
      dVenctI   := AvCtoD("")
      dVenctF   := AvCtoD("")
      dEmbarI   := AvCtoD("")
      dEmbarF   := AvCtoD("")
      cNomeBC:= Space(AvSx3("EEQ_NOMEBC",AV_TAMANHO)) //ASK

      If lOkEVENT
         cInvoice  := Space(AvSx3("EEQ_NRINVO",AV_TAMANHO))
      EndIf
   ENDIF
ELSEIF nP_ACAO = 2
       cNome := Space(40)

       If !Empty(cImport)
          SA1->(DBSETORDER(1))
          If ! AF300VAL(6,cIMPORT)
             RETURN(.F.)
          ELSE/*IF ! (SA1->(DBSEEK(XFILIAL("SA1")+cIMPORT+cLojaImp))) //MCF - 13/06/2016 - Adicionado loja no seek
              HELP(" ",1,"AVG0005099") //MSGINFO("Importador Inválido","Atenção")
              RETURN(.F.)*/
             If !TEVlCliFor(cImport,cLojaImp,"SA1",,.T.)
                RETURN(.F.)
             EndIf
          ENDIF
          cNOME := SA1->A1_NOME
       EndIf

ELSEIF nP_ACAO = 3
       IF ! EMPTY(nP_CMP1) .AND. DTOS(nP_CMP1) < DTOS(nP_CMP2)
          HELP(" ",1,"AVG0005100",,nP_CMP3,1,2) //MSGINFO(nP_CMP3,"Atenção")
          RETURN(.F.)
       ENDIF
ELSEIF nP_ACAO = 4
       IF ! EMPTY(nP_CMP1)
          nP_CMP2 := IF(nP_CMP2=NIL,"",STR(nP_CMP2,3,0))
          SY6->(DBSETORDER(1))
          IF ! (SY6->(DBSEEK(XFILIAL("SY6")+nP_CMP1+nP_CMP2)))
             HELP(" ",1,"AVG0005101") //MSGINFO("Condição de Pagamento Inválida","Atenção")
             RETURN(.F.)
          ENDIF
          cAUX     := AVSX3("Y6_VM_DESP",AV_TAMANHO)
          cNOMECON := MEMOLINE(MSMM(SY6->Y6_DESC_P,cAUX),cAUX,1)
          nDIASPAG := SY6->Y6_DIAS_PA
       ELSE
          cNOMECON := SPACE(LEN(cNOMECON))
          nDIASPAG := 0
       ENDIF
ELSEIF nP_ACAO = 5
       IF ! AF300VAL(6,cFFC)
          RETURN(.F.)
       ENDIF
       cFFC := IF(TYPE(cFFC)="N",STRZERO(VAL(cFFC),LEN(cFFC),0),cFFC)
       EEQ->(DBSETORDER(2))
       IF (EEQ->(DBSEEK(XFILIAL("EEQ")+cFFC)))
          HELP(" ",1,"AVG0005102") //MSGINFO("Número de FFC Já Utilizado","Atenção")
          RETURN(.F.)
       ENDIF
ELSEIF nP_ACAO = 6              //NCF - 01/04/2019
       IF EMPTY(nP_CMP1) .And. (IsMemVar("cTipo") .And. cTipo <> "A")
          HELP(" ",1,"AVG0005103") //MSGINFO("Preenchimento Obrigatório Deste Campo","Atenção")
          RETURN(.F.)
       ENDIF
ELSEIF nP_ACAO = 7
       IF ! EMPTY(cBanco)
          cAGEN := BCOAGE(cBanco)
          IF Empty(cAGEN)
             HELP(" ",1,"AVG0005104") //MSGINFO("Banco Inválido","Atenção")
             RETURN(.F.)
          ENDIF
          cBanco  := SA6->A6_COD
          cNCON   := SA6->A6_NUMCON
          cNOMEBC := SA6->A6_NOME
       ENDIF
ELSEIF nP_ACAO = 8
       //DFS - 16/07/13 - Nopado, visto que, o Câmbio Normal (Sem FFC) não é obrigatório o preenchimento deste campo.
       /*IF EMPTY(M->EEQ_NROP)     // GFP - 13/12/2012
          MSGINFO(STR0129,STR0026)    //"Numero de Operação deve ser informado." ###  "Atenção"
          RETURN(.F.)
       ENDIF*/
       nP_CMP1 := ""
       IF ! EMPTY(M->EEQ_PGT) .AND. EMPTY(M->EEQ_TX)
          nP_CMP1 := nP_CMP1+STR0021 //"Taxa Não Preenchida"
       ENDIF
       IF ! EMPTY(nP_CMP1)
          HELP(" ",1,"AVG0005105",,nP_CMP1,2,1) //MSGINFO("Baixa Não Realizada:"+ENTER+nP_CMP1,"Atenção")
          RETURN(.F.)
       ENDIF

       If Empty(M->EEQ_PGT)
          MsgInfo(STR0056+AllTrim(AvSx3("EEQ_PGT",AV_TITULO))+STR0057,STR0026) //"O campo '"###"' deve ser informado."###"Atenção"
          Return .f.
       EndIf

       If M->EEQ_TX = 0
          MsgInfo(STR0056+AllTrim(AvSx3("EEQ_TX",AV_TITULO))+STR0057,STR0026) //"O campo '"###"' deve ser informado."###"Atenção"
          Return .f.
       EndIf

       If Empty(M->EEQ_BANC)
          MsgInfo(STR0056+AllTrim(AvSx3("EEQ_BANC",AV_TITULO))+STR0057,STR0026) //"O campo '"###"' deve ser informado."###"Atenção"
          Return .f.
       EndIf

       If Empty(M->EEQ_DTCE) .And. (M->EEQ_EVENT <> "102" .Or. (Type("lCallRS403") == "L" .And. lCallRS403) )
          If EECFlags("CAMBIO_EXT")
             MsgInfo(STR0056+AllTrim(AvSx3("EEQ_DTCE",AV_TITULO))+STR0104,STR0026)//	STR0104	" não foi preenchido. Acesse a rotina de Baixa Gerencial."
          Else
             MsgInfo(STR0056+AllTrim(AvSx3("EEQ_DTCE",AV_TITULO))+STR0057,STR0026) //"O campo '"###"' deve ser informado."###"Atenção"
          EndIf
          Return .f.
       EndIf

      /*If !lIntFina .and. !lFinanciamento .and. Empty(M->EEQ_DTCC)
          MsgInfo(STR0056+AllTrim(AvSx3("EEQ_DTCC",AV_TITULO))+STR0057,STR0026) //"O campo '"###"' deve ser informado."###"Atenção"
          Return .f.
       EndIf*/

      //*** RMD - 19/12/07 - Validação do banco
      If !Empty(M->EEQ_BANC) .Or. !Empty(M->EEQ_AGEN) .Or. !Empty(M->EEQ_NCON)
         SA6->(DbSetOrder(1))
         If !SA6->(DbSeek(xFilial()+M->(EEQ_BANC+EEQ_AGEN+EEQ_NCON)))
            MsgInfo(STR0105 + ENTER + STR0106, STR0016)//"Aviso" //STR0105	"A conta informada não existe no cadastro de bancos." //STR0106	"Escolha uma conta válida."
            Return .F.
         EndIf
      EndIf
      //***

      If !Empty(M->EEQ_BANC) .Or. !Empty(M->EEQ_AGEN) .Or. !Empty(M->EEQ_NCON)
         SA6->(DbSetOrder(1))
         If !SA6->(DbSeek(xFilial()+M->(EEQ_BANC+EEQ_AGEN+EEQ_NCON)))
            MsgInfo(STR0105 + ENTER + STR0106, STR0016)//"Aviso" //STR0105	"A conta informada não existe no cadastro de bancos." //STR0106	"Escolha uma conta válida."
            Return .F.
         EndIf
      EndIf

       //JAP - Verifica se o valor da parcela é maior que o permitido no parâmetro MV_AVGVLMX.
       nRecNo := TMP->(Recno())
       TMP->(DbGoTop())
       Do While TMP->(!Eof())
          //If (TMP->EEQ_VL * M->EEQ_TX) > nVlMaximo
          //RMD - 20/10/06 - Valida igual na validação do campo EEQ_EQVL
          If ABS((TMP->EEQ_VL * TMP->EEQ_TX) - TMP->EEQ_EQVL) > nVlMaximo
             MsgStop(STR0082+TMP->EEQ_PARC+" ("+;//"O valor em Reais da parcela "
             AllTrim(Transf((TMP->EEQ_VL * M->EEQ_TX),AvSx3("EEQ_VL",AV_PICTURE)))+") "+;
             STR0083+"("+;//"está acima do valor máximo permitido "
             AllTrim(Transf(nVlMaximo,AvSx3("EEQ_VL",AV_PICTURE)))+")",STR0026)
             TMP->(DbGoTo(nRecNo))
             Return (.f.)
          EndIf

          If EasyVerModal("TMP") // TMP->(FieldPos("EEQ_MODAL")) > 0 .And. TMP->EEQ_MODAL == "2"
             lMovExt := .T.
          EndIf

          TMP->(DbSkip())
       EndDo

       If lMovExt .And. (!Empty(M->EEQ_BCOEXT) .Or. !Empty(M->EEQ_AGCEXT) .Or. !Empty(M->EEQ_CNTEXT))
          SA6->(DbSetOrder(1))
          If !SA6->(DbSeek(xFilial()+M->(EEQ_BCOEXT+EEQ_AGCEXT+EEQ_CNTEXT)))
             MsgInfo(STR0105 + ENTER + STR0106, STR0016)//"Aviso" //STR0105	"A conta informada não existe no cadastro de bancos." //STR0106	"Escolha uma conta válida."
             Return .F.
          EndIf
       EndIf

       If EasyEntryPoint("EECAF300")
         xRet := ExecBlock("EECAF300",.F.,.F.,{"PE_VALIDA"})
         If ValType(xRet) = "L"
            Return(xRet)
         EndIf
       EndIf

ELSEIF nP_ACAO = 9
       TMP->(DBGOTOP())
       DO WHILE ! TMP->(EOF()) .AND.;
          EMPTY(TMP->EEQ_FLAG)
          TMP->(DBSKIP())
       ENDDO
       IF TMP->(EOF())
          HELP(" ",1,"AVG0005106") //MSGINFO("Não há Parcelas Selecionadas","Atenção")
          TMP->(DBGOTOP())
          RETURN(.F.)
       ENDIF
       //TMP->(DBGOTOP())

       //*** ASK 10/09/2007 - Verifica se há bancos diferentes nas parcelas selecionadas
       TMP->(DbGoTop())
       lTemBanco  := .F.
       lFirstParc := .T.
       cBanco     := Space(Avsx3("EEQ_BANC",AV_TAMANHO))
       cAgencia   := Space(Avsx3("EEQ_AGEN",AV_TAMANHO))
       cNConta    := Space(Avsx3("EEQ_NCON",AV_TAMANHO))
       lBcoExt := TMP->(FieldPos('EEQ_MODAL')) > 0  .And. TMP->(FieldPos('EEQ_BCOEXT')) > 0 .And. TMP->(FieldPos('EEQ_AGCEXT')) > 0 .And. TMP->(FieldPos('EEQ_CNTEXT')) > 0
       If lBcoExt
          lTemBcoExt := .F.
          cBanExt := Space(Avsx3("EEQ_BCOEXT",AV_TAMANHO))
          cAgeExt := Space(Avsx3("EEQ_AGCEXT",AV_TAMANHO))
          cNConExt := Space(Avsx3("EEQ_CNTEXT",AV_TAMANHO))
       EndIf
       Do While !TMP->(Eof())
          If Empty(TMP->EEQ_FLAG)
             TMP->(DbSkip())
             LOOP
          EndIf
          EEQ->(DbSetOrder(4))
          If EEQ->(DbSeek(xFilial("EEQ") + TMP->EEQ_NRINVO)) .And. lFirstParc

             If lBcoExt .And. TMP->EEQ_MODAL == "2" .And. !Empty(TMP->EEQ_BCOEXT)
                cBanExt := TMP->EEQ_BCOEXT
                cAgeExt := TMP->EEQ_AGCEXT
                cNConExt := TMP->EEQ_CNTEXT
                lTemBcoExt  := .T.
                lFirstParc := .F.
             Else
                If !Empty(EEQ->EEQ_BANC)
                   cBanco := TMP->EEQ_BANC
                   cAgencia := TMP->EEQ_AGEN
                   cNConta := TMP->EEQ_NCON
                   lTemBanco  := .T.
                   lFirstParc := .F.
                EndIf
             EndIf

          EndIf
          If !lFirstParc .And. (lTemBanco .Or. lTemBcoExt) .And. (( cBanco <> TMP->EEQ_BANC .And. ;
             cAgencia <> TMP->EEQ_AGEN .And. cNConta <> TMP->EEQ_NCON ) .Or. (lBcoExt .And. TMP->EEQ_MODAL == "2" .And. cBanExt <> TMP->EEQ_BCOEXT .And. ;
             cAgeExt <> TMP->EEQ_AGCEXT .And. cNConExt <> TMP->EEQ_CNTEXT))
             lBancoDif := .T.
          EndIf
          TMP->(DbSkip())
       EndDo

       If lBancoDif
          TMP->(DbGoTop())
          cTexto += STR0107+CHR(13)+CHR(10) //	STR0107	"Informações Bancárias Divergentes!"
          cTexto += STR0108+CHR(13)+CHR(10) //STR0108	"Ver Detalhes:"
          cTexto += Replicate("-",128)+CHR(13)+CHR(10)
          cTexto += STR0042 +Space(5)+STR0043+Space(5)+STR0044+Space(10) +"Invoice"+CHR(13) + CHR(10)//STR0042 "Banco" //STR0043	"Agencia" //STR0044	"Nº.conta"
          Do While !TMP->(Eof())
             If Empty(TMP->EEQ_FLAG)
                TMP->(DbSkip())
                LOOP
             Else
                If Empty(TMP->EEQ_BANC)
                   cTexto += Space(2) + IncSpace(TMP->EEQ_BANC,Avsx3("EEQ_BANC",AV_TAMANHO),.T.) + Space(8) +IncSpace(TMP->EEQ_AGEN,Avsx3("EEQ_AGEN",AV_TAMANHO),.T.)+;
                   Space(16)+IncSpace(TMP->EEQ_NCON,Avsx3("EEQ_NCON",AV_TAMANHO),.T.) +Space(4)+ TMP->EEQ_NRINVO + chr(10) + Chr(13)
                Else
                   cTexto += Space(2) + TMP->EEQ_BANC + Space(8) + TMP->EEQ_AGEN + Space(7) + TMP->EEQ_NCON + Space(4) +;
                   TMP->EEQ_NRINVO + chr(10) + Chr(13)
                EndIf
                If lBcoExt .And. TMP->EEQ_MODAL == "2"
                   If Empty(TMP->EEQ_BCOEXT)
                       cTexto += Space(2) + IncSpace(TMP->EEQ_BANC,Avsx3("EEQ_BANC",AV_TAMANHO),.T.) + Space(8) +IncSpace(TMP->EEQ_AGEN,Avsx3("EEQ_AGEN",AV_TAMANHO),.T.)+;
                       Space(16)+IncSpace(TMP->EEQ_NCON,Avsx3("EEQ_NCON",AV_TAMANHO),.T.) +Space(4)+ TMP->EEQ_NRINVO + chr(10) + Chr(13)
                   Else
                      cTexto += Space(2) + TMP->EEQ_BCOEXT + Space(8) + TMP->EEQ_AGCEXT + Space(7) + TMP->EEQ_CNTEXT + Space(4) +;
                      TMP->EEQ_NRINVO + chr(10) + Chr(13)
                   EndIf
                EndIf
             EndIf
             TMP->(DbSkip())
          EndDo
          cTexto += Replicate("-",128)+CHR(13)+CHR(10)
          //cTexto += "Log da atualizacao "+CHR(13)+CHR(10)+cTexto
          __cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cTexto)

          Define FONT oFont NAME "Mono AS" Size 5,12   //6,15
          Define MsDialog oDlg Title STR0026 From 3,0 to 340,417 Pixel //STR0026  "Atenção"

          @ 5,5 Get oMemo  Var cTexto MEMO Size 200,145 Of oDlg Pixel
          oMemo:bRClicked := {||AllwaysTrue()}
          oMemo:oFont:=oFont

          Define SButton  From 153,175 Type 1 Action oDlg:End() Enable Of oDlg Pixel //Apaga
          Define SButton  From 153,145 Type 13 Action (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
          Activate MsDialog oDlg Center
       EndIf

//***
ElseIf nP_ACAO = 10
   nNumAux := EEQ->(IndexOrd())
   EEQ->(dbSetOrder(5))
      //LRL-20/12/04-------Considera todas as Filiais--------------------------------------------------------
      If !Empty(cInvoice) .And. lMultiFil
         lOk := .F.
         For i:= 1 To Len(aFiliais)
             If EEQ->(DBSEEK(aFiliais[i]+cInvoice+EV_PRINC2))
                lOk := .T.
//                cFil:="  "
//                lTodasFil:=.T.
                cFilAnt:=cxFil
                Exit
             EndIf
         Next
         If !lOk
            Help("",1,"REGNOIS")
            RETURN(.F.)
         EnDIf
   //--------------------------------------------------------LRL-20/12/04-------Considera todas as Filiais
   ElseIf !Empty(cInvoice) .and. !EEQ->(dbSeek(xFilial("EEQ")+cInvoice+EV_PRINC2))
      Help("",1,"REGNOIS")
      RETURN(.F.)
   EndIf
   EEQ->(dbSetOrder(nNumAux))
ElseIf nP_ACAO = 11
   If Empty(cImport) .And. Empty(cProc)
      Help("",1,"AVG0005251") //Campo Importador não preenchido.
      Return .F.
   EndIf
Elseif nP_ACAO = 12
   cNomeForn := Space(40)
   //LRS - 31/08/2016 - Correção do Seek do fornecedor inserido na mão o codigo
   If !Empty(cFornec) .And. If(Type("lCallRS403") == "L" .And. lCallRS403,cTipo=="P",.T.) // Valida somente quando o cTipo for 'P' (A Pagar) e chamada da funcao do fonte ESSRS403
      SA2->(DBSETORDER(1))
      If !TEVlCliFor(cFornec,cLojaFor,"SA2",,.T.)
         RETURN(.F.)
      EndIf
/*      If ! AF300VAL(6,cFornec) // Mensagem de preenchimento obrigatorio - By A. Caetano Jr.
         RETURN(.F.)
      ELSEIF !Empty(cLojaFor)
         IF ! (SA2->(DBSEEK(XFILIAL("SA2")+cFornec+cLojaFor))) //MCF - 13/06/2016 - Adicionado loja no seek
	         HELP(" ",1,"AVG0000491") //MSGINFO("Entre com o Fornecedor Valido","Atenção")
	         RETURN(.F.)
         EndIF
      ELSEIF Empty(cLojaFor)
         IF !(SA2->(DBSEEK(XFILIAL("SA2")+cFornec)))
            HELP(" ",1,"AVG0000491") //MSGINFO("Entre com o Fornecedor Valido","Atenção")
            RETURN(.F.)
         Else
            cLojaFor := SA2->A2_LOJA
         EndIF
      ENDIF
*/
      cNOMEForn := SA2->A2_NOME
   EndIf

Elseif nP_ACAO = 13
   If EECFlags("FRESEGCOM") .And. lOkEvent
/*HVR 09/03/2006 Não validar caso o campo Evento não estiver preenchido, apenas ignorar o campo
      If Empty(cFFC) // .And. Empty(cEvent)
         MsgStop("Código do Evento Contábil não informado !","Atenção")
         Return (.f.)
      EndIf
*/
   EndIf

   if If(Type("lCallRS403") == "L" .And. lCallRS403,cTipo=="P",.T.) .And. (Empty(cFornec) .And. cTipo <> "A" ) .And. Empty(cFFC) .And. Empty(cEvent)
      Help("",1,"AVG0000490") //Campo Forncededor não preenchido.
      Return .F.
   EndIf

Elseif nP_ACAO = 14
   If .not. Empty(cMoeda)
      SYF->(DBSetOrder(1))
      If .not. AF300Val(6,cMoeda) // Mensagem de preenchimento obrigatorio - By A. Caetano Jr.
         Return .f.
      Elseif .not. SYF->(DBSeek( xFilial("SYF") + cMoeda ) )
         HELP(" ",1,"AVG0003021") // Codigo da Moeda nao cadastrado
         RETURN(.F.)
      Endif
   ENDIF
Elseif nP_Acao = 15
   If Empty(cMoeda) .and. Empty(cFFC) //.And. Empty(cEvent) VI 16/06/06
//    HELP(" ",1,"AVG0005285") // Moeda nao informada
      EasyHelp(STR0077,STR0026)
      Return(.f.)
   Endif
Elseif nP_Acao = 16  // Nro.Processo

   If !Empty(cProc)
      dEmbarI := AvCToD("")
      dEmbarF := AvCToD("")

      // ** Carrega as informações da capa do processo.
      EEC->(DbSetOrder(1))
      //LRL 20/12/04-Considera outras Filiais-----------------------------------------------------
      lOk := .F.
      If lMultiFil
         For i:= 1 To Len(aFiliais)
             If EEC->(DBSEEK(aFiliais[i]+AvKey(cProc,"EEC_PREEMB")))
                lOk := .T.
//                cFil:="  "
//                lTodasFil:=.T.
                cFilAnt:=cxFil
                Exit
             EndIf
         Next
         If !lOk
            Help("",1,"REGNOIS")
            Return .F.
         EnDIf
      ElseIf EEC->(DbSeek(xFilial("EEC")+AvKey(cProc,"EEC_PREEMB")))
         lOk:= .T.
      EndIF
      If lOk
      //-----------------------------------------------------LRL 20/12/04-Considera outras Filiais
         // Moeda
         cMoeda  := EEC->EEC_MOEDA

         // Código e Descrição do Importador.
         cImport := EEC->EEC_IMPORT
         cNome   := EEC->EEC_IMPODE

         // Código e nome do fornecedor.
         cFornec   := EEC->EEC_FORN
         cNomeForn := Posicione("SA2",1,xFilial("SA2")+EEC->EEC_FORN+EEC->EEC_FOLOJA,"A2_NOME")

         // Cod, dias e descrição da condição de pagamento.
         cCondPag := EEC->EEC_CONDPA
         nDiasPag := EEC->EEC_DIASPA
         cNomeCon := SY6Descricao(EEC->EEC_CONDPA+Str(EEC->EEC_DIASPA,AVSX3("EEC_DIASPA",AV_TAMANHO) ,;
                                                                      AVSX3("EEC_DIASPA",AV_DECIMAL)),;
                                                                      EEC->EEC_IDIOMA,1)
      EndIf
   Endif

ElseIf nP_Acao = 17  // Evento


   If !Empty(cEvent)
      EC6->(DbSetOrder(1))
      If !EC6->(DbSeek(xFilial("EC6")+"EXPORT"+AvKey(cEvent,"EC6_ID_CAM")))
         MsgInfo(STR0109+AllTrim(cEvent)+STR0110,STR0026)//STR0109	 "O evento '" //	STR0110	"' não existe no cadastro de eventos contábeis." //STR0026  	"Atenção"
         Return (.f.)
      EndIf
   EndIf


   //** JVR ** 17/02/2009
   If !Empty(cEvent)

      //** AAF 01/12/05
      If EC6->EC6_RECDES == '1'
         cTipo   := "R" //Recebimento
      ElseIf EC6->EC6_RECDES == '2'
         cTipo   := "P" //Pagamento   -  Alterado dia 09/03/2006
      EndIf

   EndIf

ElseIf nP_Acao = 18    // By JPP - 21/02/2006 - 14:10
   //WFS 24/08/09
   //Ponto de entrada para tratamentos customizados na validação da data de negociação (EEQ_DTNEGO)
   If EasyEntryPoint("EECAF300")
      lDtNego:= ExecBlock("EECAF300",.F.,.F., "DTNEGO_VALID")
   EndIf
   If !lDtNego
       lRet := .T.
       nReg := WORK1->(Recno())
       WORK1->(DbGoTop())
       Do While ! WORK1->(Eof())

          If EasyVerModal("WORK1") //WORK1->(FieldPos("EEQ_MODAL")) > 0 .And. WORK1->EEQ_MODAL == "2"
             lMovExt := .T.
             WORK1->(DbSkip())
             Loop
          EndIf

          If Empty(WORK1->EEQ_DTCE) .and. !Empty(M->EEQ_DTNEGO)
             // ** JPM - 08/01/2010 - na nova rotina de cambio, a baixa gerencial (preench. data de credito) é feita num botão separado.
             If Work1->EEQ_TIPO <> "P" .And. !EECFlags("CAMBIO_EXT")
                MsgInfo(STR0069,STR0026)   // "A Data de Credito no Exterior deve ser informada"###"Atenção"
                lRet := .F.
                Exit
             EndIf
          ElseIf M->EEQ_DTNEGO < WORK1->EEQ_DTCE
             MsgInfo(STR0070,STR0026)   // "Data de Negociação inferior a Data de Credito no Exterior"###"Atenção"
             lRet := .f.
             Exit
          ElseIF !Empty(WORK1->EEQ_SOL) .and. M->EEQ_DTNEGO < WORK1->EEQ_SOL
             MsgInfo(STR0081,STR0026) //"Data de negociação não pode ser anterior a Data de Solicitação."###"Atenção"
             lRet := .f.
             Exit
          Endif
          WORK1->(DbSkip())
       EndDo
       WORK1->(DbGoTo(nReg))

       // ** JPM - 08/01/2010 - a instrução abaixo não considerava se não passou pela validação acima.
       If !lRet
          Return(lRet)
       EndIf

       //ASK 11/09/2007 - Caso as parcelas tiverem com informações bancarias divergentes, ver nP_ACAO 9
       If lBancoDif
          If MsgYesNo(STR0099+CHR(13)+CHR(10)+STR0100,STR0026)
          //"Há parcelas com informações bancárias divergentes!"/"Deseja sobrepor estas informações?"
             lRet := .T.
          Else
             lRet := .F.
          EndIf
       EndIf

       If lMovExt .And. (Empty(M->EEQ_BCOEXT) .Or. Empty(M->EEQ_AGCEXT) .Or. Empty(M->EEQ_CNTEXT))
          EasyHelp("Existem parcelas com movimentaçao no exterior. Informe o banco no exterior.")
          lRet := .F.
       EndIf

       Return(lRet)
   EndIf
ElseIf nP_Acao = 19 // Registro

   If !Empty(cProc) .And. Type('cTpReg') == "C" .And. !Empty(cTpReg)
      dEmbarI := AvCToD("")
      dEmbarF := AvCToD("")

      EJY->(DbSetOrder(1)) //EJY_FILIAL+EJY_TPPROC+EJY_REGIST
      lOk := .F.
      If lMultiFil
         For i:= 1 To Len(aFiliais)
             If EJY->(DBSEEK(aFiliais[i]+AvKey(cTpReg,"EJY_TPPROC")+AvKey(cProc,"EJY_REGIST")))
                lOk := .T.
                cFilAnt:=cxFil
                Exit
             EndIf
         Next
         If !lOk
            Help("",1,"REGNOIS")
            Return .F.
         EnDIf
      ElseIf EJY->(DbSeek(xFilial("EJY")+AvKey(cTpReg,"EJY_TPPROC")+AvKey(cProc,"EJY_REGIST")))
         lOk:= .T.
      EndIF
      If lOk
         cMoeda    := EJY->EJY_MOEDA
         cImport   := EJY->EJY_IMPORT
         cNome     := Posicione("SA1",1,xFilial("SA1")+EJY->EJY_IMPORT+EJY->EJY_LOJIMP,"A1_NOME")
         cFornec   := EJY->EJY_EXPORT
         cNomeForn := Posicione("SA2",1,xFilial("SA2")+EJY->EJY_EXPORT+EJY->EJY_LOJEXP,"A2_NOME")
      EndIf
   Endif
   
ElseIf nP_Acao == 20 .Or. nP_Acao == 21
   If !Empty(If( nP_Acao == 20 , cFornec , cImport))
      If !TEVlCliFor( If( nP_Acao == 20 , cFornec , cImport) , If( nP_Acao == 20 , cLojaFor , cLojaImp) , If( nP_Acao == 20 , "SA2" , "SA1") ,,.T.)
         Return .F.
      EndIf
   Else
      If !Empty( If( nP_Acao == 20 , cLojaFor , cLojaImp) )
         MSgInfo( StrTran( STR0139 , "####", If( nP_Acao == 20 , "Fornecedor" , "Importador") ) , STR0026)  //" #### não informado para localizar a loja!"        
      EndIf
   EndIf

EndIf

RETURN(.t.)
*----------------------*
STATIC FUNCTION AF300A()
*----------------------*
Local cQry:="", cFrom:="", cCmd:=""
Local i
Local aFil:=AClone(aFiliais)
Local xcFil :=cFilAnt

#IFNDEF TOP
  Local bCond
  Local cChave:=""
  Local nOrdem := 0
  Local nTipCon
#ENDIF

Private cWhere:=""  //TRP - 20/07/2011 - Para utilização em rdmake.
// CARREGA DA BASE P/ O TMP
If lIntFina .and. lFinanciamento
   EF3->(dbSetOrder(3))
EndIf

IF lFFC
   // QUANDO FOR INCLUSAO DE FFC
   #IFDEF TOP
      // ** By JBJ - 30/07/03 Montagem do Select p/ filtro das informações.
      cQry   := "Select EEQ.R_E_C_N_O_ AS RECNO,  EEC.EEC_IMPORT AS EEC_IMPORT "
      cFrom  := "From "+RetSqlName("EEC")+" EEC, "+RetSqlName("EEQ")+" EEQ "+If(!Empty(cNrOpSq),", "+RetSqlName("EF3")+" EF3 ","")//AAF 06/05/2006 - Verifica se o filtro está sendo utilizado antes de filtrar pelo EF3 //HVR 09/03/2006 - Filtro por Sequencia

      // ACSJ - 14/MAR/2005 - INICIO
      /*LRL 18/12/04 ------------------Considerar-todas as filiais-----------------------------------
      If !lMultiFil
         cWhere := "Where EEC.D_E_L_E_T_ <> '*' And EEC_FILIAL ='"+xFilial("EEQ")+"' And "+;
                         "EEC_PREEMB = EEQ_PREEMB "
      Else
      EndIf                   */
      //--------------------------------------------------------------------------------- LRL 18/12/04

      cWhere := "Where EEC.D_E_L_E_T_ <> '*' And EEC.EEC_FILIAL IN ("+cFil+") And "+;
                "EEC.EEC_PREEMB = EEQ.EEQ_PREEMB "
      // - ACSJ - 14/MAR/2005 - FIM

      // ** Processo.
      If !Empty(cProc)
         cWhere += " And EEC.EEC_PREEMB = '"+AllTrim(cProc)+"' "
      EndIf

      If !EECFlags("FRESEGCOM")

         // ** Importador.
         If !Empty(cImport)
            cWhere += " And EEC.EEC_IMPORT = '"+AllTrim(cImport)+"' "
         EndIf

         // ** Fornecedor - By A. Caetano Jr - 01/12/2003
         cWhere += " And EEC.EEC_FORN = '"+AllTrim(cFornec)+"' "

         // ** Moeda - By A. Caetano Jr - 06/12/2003
         cWhere += " And EEC.EEC_MOEDA = '"+AllTrim(cMoeda)+"' "
      EndIf
      //ASK 04/09/2007 - Filtro para o Banco
      If !Empty(cBanco)
         cWhere += " And EEQ.EEQ_BANC = '"+AllTrim(cBanco)+"' "
         cWhere += " And EEQ.EEQ_AGEN = '"+AllTrim(cAGEN)+"' "
         cWhere += " And EEQ.EEQ_NCON = '"+AllTrim(cNCON)+"' "
      EndIf

      // ** Condição de Pagamento.
      If !Empty(cCondPag)
         cWhere += " And EEC.EEC_CONDPA = '"+AllTrim(cCondPag)+"' And "+;
                   " EEC.EEC_DIASPA = "+Str(nDiasPag,3,0)+" "
      EndIf

      // ** Período de Dt.Embarque.
      If !Empty(dEmbarI)
         cWhere += " And EEC.EEC_DTEMBA >= '" + DtoS(dEmbarI)+"' "
      EndIf
      If !Empty(dEmbarF)
         cWhere += " And EEC.EEC_DTEMBA <= '" + DtoS(dEmbarF)+"' "
      EndIf
      /*ACSJ 14/MAR/2005 - INICIO
      //LRL 18/12/04 ------------------Considerar-todas as filiais-----------------------------------
      If !lMultiFil
         cWhere += " And EEQ.D_E_L_E_T_ <> '*' And EEQ_FILIAL ='"+xFilial("EEQ")+"' "
      Else
      EndIf
      //--------------------------------------------------------------------------------- LRL 18/12/04*/
      cWhere += " And EEQ.D_E_L_E_T_ <> '*' And EEQ_FILIAL IN ("+cFil+") "
      //ACSJ 14/MAR/2005 - FIM

      // ** Condições para as parcelas no EEQ.
      cWhere += " And EEQ.EEQ_FFC = '"+Space(Avsx3("EEQ_FFC",AV_TAMANHO))+"'"+;
                      " And EEQ.EEQ_PGT = '        ' "
      //HVR 04/04/06
      IF lFFCIMP
         cWhere += " And EEQ.EEQ_FFCIMP = '"+Space(Avsx3("EEQ_FFCIMP",AV_TAMANHO))+"' "
      ENDIF
      //HVR***

      // ** Número da Operação - GFC 12/02/05
      If !Empty(cNrOp)
         cWhere += "AND EEQ.EEQ_NROP = '"+cNrOp+"' "
      EndIf

      // ** Sequencia - HVR 09/03/06 - Adicionado campo Sequencia do COntrato
      //AAF 06/05/2006 - Filtro deve ser feito pelo EF3.
      If !Empty(cNrOpSq)
         cWhere += "AND EF3.EF3_FILIAL = '"+xFilial("EF3")+"' "
         cWhere += "AND EF3.EF3_SEQCNT = '"+cNrOpSq+"' "
         cWhere += "AND EF3.EF3_CONTRA = '"+cNrOp+"' AND EF3.EF3_CODEVE = '600' "
         cWhere += "AND EEQ.EEQ_NRINVO = EF3.EF3_INVOIC AND EEQ.EEQ_PARC = EF3.EF3_PARC "
      EndIf
      //HVR***

      // ** Período de Vencimento.
      If !Empty(dVenctI)
         cWhere += " And EEQ.EEQ_VCT >= '" + DtoS(dVenctI)+"' "
      EndIf
      If !Empty(dVenctF)
         cWhere += " And EEQ.EEQ_VCT <= '" + DtoS(dVenctF)+"' "
      EndIf

      // ** Período de Crédito no Exterior.  // GFP - 28/10/2013
      If !Empty(dIniCrd)
         cWhere += " And EEQ.EEQ_DTCE >= '" + DtoS(dIniCrd)+"' "
      EndIf
      If !Empty(dFimCrd)
         cWhere += " And EEQ.EEQ_DTCE <= '" + DtoS(dFimCrd)+"' "
      EndIf

      If lOkEvent
         If !Empty(cInvoice)
            cWhere += " And EEQ.EEQ_NRINVO = '"+AllTrim(cInvoice)+"' "
         EndIf

         If EECFlags("FRESEGCOM")
            If !Empty(cEvent)
               cWhere += " And EEQ.EEQ_EVENT = '"+cEvent+"' "
            EndIf
//         Else
//            cWhere += " And EEQ.EEQ_EVENT = '"+EV_PRINC2+"' " //HVR???
         EndIf
      EndIf

      /* by jbj - Se os novos campos para tratamento do importador, fornecedor e moeda existirem no
                  ambiente, o filtro para seleção dos dados é executado diretamente no EEQ. */

      If EECFlags("FRESEGCOM")
         If !Empty(cImport)
            cWhere += " And EEQ.EEQ_IMPORT = '"+AllTrim(cImport)+"' "
         EndIf

         If !Empty(cFornec)
            cWhere += " And EEQ.EEQ_FORN = '"+AllTrim(cFornec)+"' "
         EndIf

         If !Empty(cMoeda)
            cWhere += " And EEQ.EEQ_MOEDA = '"+AllTrim(cMoeda)+"' "
         EndIf
      EndIf

      //** AAF 01/12/05 - Validação para o Tipo de Contrato(EEQ_TP_CON)
      If EEQ->( FieldPos("EEQ_TP_CON") ) > 0
         If !Empty(cTipCon)
            cWhere += " And EEQ.EEQ_TP_CON = '"+Left(cTipCon,1)+"' "
         EndIf
      EndIf

      If EEQ->( FieldPOs("EEQ_TIPO") ) > 0 .AND. !Empty(cTipo)
         cWhere += " And EEQ.EEQ_TIPO = '"+Left(cTipo,1)+"' "
      EndIf
      //**
      
      cWhere += " And EEQ.EEQ_FASE <> 'F' " //THTS - 29/08/2017 - Adiantamento de Fornecedores nao podem ser utilizados pra FFC
      
      // Criação de Ponto de Entrada - TRP - 20/07/2011
      If EasyEntryPoint("EECAF300")
         ExecBlock("EECAF300",.F.,.F.,{"AF300_QRY"})
      EndIf

      cCmd := (cQry+cFrom+cWhere)

      //** GFC - 19/01/06 - O Right outter join que estava sendo utilizado não funcionava em todos os bancos
         If EEQ->( FieldPos("EEQ_TP_CON") ) > 0 .And. ( Empty(cTipCon)  .Or.  cTipCon $ "3/4" )
            cQry   := ""
            cFrom  := ""
            cWhere := ""

            cQry   := " UNION Select EEQ.R_E_C_N_O_ AS RECNO, EEQ.EEQ_IMPORT AS EEC_IMPORT "
            cFrom  := "From "+RetSqlName("EEQ")+" EEQ "+If(!Empty(cNrOpSq),", "+RetSqlName("EF3")+" EF3 ","")

            cWhere := "Where EEQ.D_E_L_E_T_ <> '*' And EEQ.EEQ_FILIAL IN ("+cFil+") "

            // ** Processo.
            If !Empty(cProc)
               cWhere += " And EEQ.EEQ_PREEMB = '"+AllTrim(cProc)+"' "
            EndIf

            // ** Condições para as parcelas no EEQ.
            cWhere += " And EEQ.EEQ_FFC = '"+Space(Avsx3("EEQ_FFC",AV_TAMANHO))+"'"+;
                      " And EEQ.EEQ_PGT = '        ' "

            //HVR 04/04/06
            IF lFFCIMP
               cWhere += " And EEQ.EEQ_FFCIMP = '"+Space(Avsx3("EEQ_FFCIMP",AV_TAMANHO))+"' "
            ENDIF
            //HVR***

            // ** Número da Operação - GFC 12/02/05
            If !Empty(cNrOp)
               cWhere += "AND EEQ.EEQ_NROP = '"+cNrOp+"' "
            EndIf

            // ** Sequencia - HVR 09/03/06 - Adicionado campo Sequencia do Contrato
            //AAF 06/05/2006 - Filtro deve ser feito pelo EF3.
            If !Empty(cNrOpSq)
               //cWhere += "AND EF3.EF3_SEQCNT = '"+cNrOpSq+"' "
               cWhere += "AND EF3.EF3_FILIAL = '"+xFilial("EF3")+"' "
               cWhere += "AND EF3.EF3_SEQCNT = '"+cNrOpSq+"' "
               cWhere += "AND EF3.EF3_CONTRA = '"+cNrOp+"' AND EF3.EF3_CODEVE = '600' "
               cWhere += "AND EEQ.EEQ_NRINVO = EF3.EF3_INVOIC AND EEQ.EEQ_PARC = EF3.EF3_PARC "
            EndIf
            //HVR***

            // ** Período de Vencimento.
            If !Empty(dVenctI)
               cWhere += " And EEQ.EEQ_VCT >= '" + DtoS(dVenctI)+"' "
            EndIf
            If !Empty(dVenctF)
               cWhere += " And EEQ.EEQ_VCT <= '" + DtoS(dVenctF)+"' "
            EndIf

            If lOkEvent
               If !Empty(cInvoice)
                  cWhere += " And EEQ.EEQ_NRINVO = '"+AllTrim(cInvoice)+"' "
               EndIf

               If EECFlags("FRESEGCOM")
                  If !Empty(cEvent)
                     cWhere += " And EEQ.EEQ_EVENT = '"+cEvent+"' "
                  EndIf
               Else
//                  cWhere += " And EEQ.EEQ_EVENT = '"+EV_PRINC2+"' "
               EndIf
            EndIf

            /* by jbj - Se os novos campos para tratamento do importador, fornecedor e moeda existirem no
                        ambiente, o filtro para seleção dos dados é executado diretamente no EEQ. */

            If EECFlags("FRESEGCOM")
               If !Empty(cImport)
                  cWhere += " And EEQ.EEQ_IMPORT = '"+AllTrim(cImport)+"' "
               EndIf

            //JAP - 29/06/06 - Verifica se é despesa ou receita.
            If !Empty(cFornec)
               cWhere += " And EEQ.EEQ_FORN = '"+AllTrim(cFornec)+"'"

               /*
               If IsReceita(cEvent)
                  cWhere += " And EEQ.EEQ_FORN = '"+AllTrim(cFornec)+"' "
               Else
                  cWhere += " And EEC.EEC_FORN = '"+AllTrim(cFornec)+"' "
               EndIf
               */
            EndIf

               If !Empty(cMoeda)
                  cWhere += " And EEQ.EEQ_MOEDA = '"+AllTrim(cMoeda)+"' "
               EndIf
            EndIf

            //ASK 04/09/2007 - Filtro para o Banco
            If !Empty(cBanco)
               cWhere += " And EEQ.EEQ_BANC = '"+AllTrim(cBanco)+"' "
               cWhere += " And EEQ.EEQ_AGEN = '"+AllTrim(cAGEN)+"' "
               cWhere += " And EEQ.EEQ_NCON = '"+AllTrim(cNCON)+"' "
            EndIf

            //** AAF 01/12/05 - Validação para o Tipo de Contrato(EEQ_TP_CON)
            If EEQ->( FieldPos("EEQ_TP_CON") ) > 0
               If !Empty(cTipCon) // PLB 23/05/06
                  cWhere += " And (EEQ.EEQ_TP_CON = '"+Left(cTipCon,1)+"' OR EEQ.EEQ_EVENT = '605' OR EEQ.EEQ_EVENT = '602' ) "//AAF 14/02/2014 - Não é necessário validar o tipo para adiantamento
               Else
                  cWhere += " And (EEQ.EEQ_TP_CON IN ('3','4') OR EEQ.EEQ_EVENT = '605' OR EEQ.EEQ_EVENT = '602' ) " //AAF 14/02/2014 - Não é necessário validar o tipo para adiantamento
               EndIf
            EndIf

            If EEQ->( FieldPOs("EEQ_TIPO") ) > 0 .AND. !Empty(cTipo)
               cWhere += " And EEQ.EEQ_TIPO = '"+Left(cTipo,1)+"' "
            EndIf
            //**

            cWhere += " And EEQ.EEQ_FASE <> 'F' " //THTS - 29/08/2017 - Adiantamento de Fornecedores nao podem ser utilizados pra FFC

            // Criação de Ponto de Entrada - TRP - 20/07/2011
            If EasyEntryPoint("EECAF300")
               ExecBlock("EECAF300",.F.,.F.,{"AF300_QRY3/4"})
            EndIf

            cCmd += (cQry+cFrom+cWhere)
         EndIf
         //**

      cCmd := ChangeQuery(cCmd)
      DbUseArea(.t., "TOPCONN", TCGENQRY(,,cCmd),"Qry",.f.,.t.)

      // ** Atualiza as informações no Tmp.
      Do While Qry->(!Eof())
         EEQ->(DbGoTo(Qry->RECNO))
         If lIntFina .and. lFinanciamento .and. (EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,If(EEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+EEQ->EEQ_NRINVO+EEQ->EEQ_PARC+EV_LIQ_PRC));   //HVR 08/03/2006 - Incluido no indice o campo EF3_TPMODU
         .or. EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,If(EEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+EEQ->EEQ_NRINVO+EEQ->EEQ_PARC+EV_LIQ_PRC_FC)))// .and. !Empty(EF3->EF3_NR_CON)    //HVR 08/03/2006 - Incluido no indice o campo EF3_TPMODU
            Qry->(dbSkip()) //AAF 03/05/2006 - Correção de Loop infinito devido a Skip no Alias EEQ.
            Loop
         EndIf
         Tmp->(DbAppend())
         RegToMemory("EEQ", .F.)
         AvReplace("EEQ","Tmp")
         TMP->EEQ_VLFCAM:= AF200VLFCam("EEQ", "ALT")                              //NCF - 11/04/2011
         TMP->TRB_ALI_WT:= "EEQ"
         TMP->TRB_REC_WT:= EEQ->(Recno())
         SA1->(DBSetOrder(1))
         //SA1->(DBSeek(xFilial()+Qry->EEC_IMPORT))
         SA1->(DBSeek(xFilial()+EEQ->EEQ_IMPORT))
         TMP->WK_Import := EEQ->EEQ_IMPORT + "-" + SA1->A1_NREDUZ//Qry->EEC_IMPORT + "-" + SA1->A1_NREDUZ
         TMP->A1_COD := EEQ->EEQ_IMPORT //LRS - 28/09/2018
         TMP->EEQ_FILORI := EEQ->EEQ_FILIAL + " - " + AvgFilName({EEQ->EEQ_FILIAL})[1]
         nTotal += TMP->EEQ_VL
         Qry->(DbSkip())
      EndDo
      //Qry->(DbCloseArea())

   #ELSE
      If !Empty(cProc)
         nOrdem := 1
         cChave := AvKey(AllTrim(cProc),"EEC_PREEMB")
         bCond := {|| EEC->(EEC_FILIAL+EEC_PREEMB) == (xFilial("EEC")+cChave)}
      Else
         nOrdem := 8
         cChave := AvKey(AllTrim(cFornec),"EEC_FORN")
         bCond := {|| EEC->(EEC_FILIAL+EEC_FORN) == (xFilial("EEC")+cChave)}
      EndIf

      EEC->(DBSETORDER(nOrdem))
      //LRL 20/12/04 ------------------Considerar-todas as filiais-----------------------------------
      If !lMultiFil
         aFil := {cFilAnt}
      EndIf
      For i:= 1 To Len(aFil)
         cFilAnt:=aFil[i] //LRL 20/12/04 - Seta o Resultado do xFilial caso Exclusivo
      //-----------------------------------LRL 18/12/04 ------------------Considerar-todas as filiais
         EEC->(DBSEEK(XFILIAL("EEC")+cChave))
         DO WHILE ! EEC->(EOF()) .AND. Eval(bCond)
            IF (EMPTY(cCONDPAG) .OR. cCONDPAG+STR(nDIASPAG,3,0) = EEC->(EEC_CONDPA+STR(EEC_DIASPA,3,0))) .AND.;
               (EMPTY(dEMBARI) .OR. EEC->(DTOS(EEC_DTEMBA) >= DTOS(dEMBARI) .AND. DTOS(EEC_DTEMBA) <= DTOS(dEMBARF))) .and.;
               ( Empty(cImport) .or. EEC->EEC_IMPORT == cImport ) .and. ( EEC->EEC_MOEDA == cMoeda )

               EEQ->(DBSETORDER(1))
               EEQ->(DBSEEK(XFILIAL("EEQ")+EEC->EEC_PREEMB))
               DO WHILE ! EEQ->(EOF()) .AND.;
                  EEQ->(EEQ_FILIAL+EEQ->EEQ_PREEMB) = (XFILIAL("EEQ")+EEC->EEC_PREEMB)

                  If EECFlags("FRESEGCOM") .And. lOkEvent
                     If !Empty(cEvent)
                        If (EEQ->EEQ_EVENT <> cEvent)
                           EEQ->(dbSkip())
                           Loop
                        EndIf
                     EndIf
                  EndIf

                  If !Empty(cNrOp)
                     If EEQ->EEQ_NROP <> cNrOp
                        EEQ->(dbSkip())
                        Loop
                     EndIf
                  EndIf

                  If !Empty(cTipo) //wfs
                     If AllTrim(cTipo) <> AllTrim(EEQ->EEQ_TIPO)
                        EEQ->(DBSkip())
                        Loop
                     EndIf
                  EndIf

                  IF EEQ->(EMPTY(EEQ_FFC) .And. IF(lFFCIMP, EMPTY(EEQ_FFCIMP),.T.) .AND. EMPTY(EEQ_PGT)) .AND.; // EMPTY(EEQ_SOL)) .AND.; // ** By JBJ - 19/05/03 - Nao filtrar pela Dt.Sol.Cambio. //HVR 04/04/06 ADICIONADO  .And. IF(lFFCIMP, EMPTY(EEQ_FFCIMP),.T.)
                     (EMPTY(dVENCTI) .OR. (EEQ->(DTOS(EEQ_VCT) >= DTOS(dVENCTI) .AND. DTOS(EEQ_VCT) <= DTOS(dVENCTF)))) .and.;
                     (!lOkEVENT .or. (Empty(cInvoice) .or. (EEQ->EEQ_INVOICE==cInvoice /*.and. If(!lOkEvent,.t.,EEQ->EEQ_EVENT==EV_PRINC2)*/)))
                     If lIntFina .and. lFinanciamento .and.;
                     (EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,If(EEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+EEQ->EEQ_NRINVO+EEQ->EEQ_PARC+EV_LIQ_PRC)) .or.;  //HVR 08/03/2006 - Incluido no indice o campo EF3_TPMODU
                     EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,If(EEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+EEQ->EEQ_NRINVO+EEQ->EEQ_PARC+EV_LIQ_PRC_FC)))// .and. !Empty(EF3->EF3_NR_CON)   //HVR 08/03/2006 - Incluido no indice o campo EF3_TPMODU
                        EEQ->(dbSkip())
                        Loop
                     EndIf
                     TMP->(DBAPPEND())
                     RegToMemory("EEQ", .F.)
                     AVREPLACE("EEQ","TMP")
                     TMP->EEQ_VLFCAM:= AF200VLFCam("EEQ", "ALT")                              //NCF - 11/04/2011
                     TMP->TRB_ALI_WT:= "EEQ"
                     TMP->TRB_REC_WT:= EEQ->(Recno())
                     SA1->(DBSetOrder(1))
                     SA1->(DBSeek(xFilial("EEC")+EEC->EEC_IMPORT))
                     TMP->WK_Import := EEC->EEC_IMPORT + "-" + SA1->A1_NREDUZ
                     TMP->A1_COD := EEC->EEC_IMPORT //LRS -28/09/2018
                     TMP->EEQ_FILORI := EEQ->EEQ_FILIAL + " - " + AvgFilName({EEQ->EEQ_FILIAL})[1]
                     nTotal += TMP->EEQ_VL
                  ENDIF
                  EEQ->(DBSKIP())
               ENDDO
            Endif
            EEC->(DBSKIP())
         ENDDO

         //** AAF 02/12/05 - Câmbio Tipo 3 e Tipo 4.
         For nTipCon := 3 To 4
            cTip := AllTrim(Str(nTipCon,1))

            If Empty(cTipCon) .OR. cTipCon == cTip
               EEQ->( dbSetOrder(6) )//EEQ_FILIAL+EEQ_FASE+EEQ_PREEMB+EEQ_PARC

               EEQ->( dbSeek(xFilial("EEQ")+cTip) )
               Do While !EEQ->( EoF() ) .AND. EEQ->EEQ_FILIAL == xFilial("EEQ") .AND. EEQ->EEQ_FASE == cTip

                  If EECFlags("FRESEGCOM") .And. lOkEvent
                     If !Empty(cEvent)
                        If (EEQ->EEQ_EVENT <> cEvent)
                           EEQ->( dbSkip() )
                           Loop
                        EndIf
                     EndIf
                  EndIf

                  If !Empty(cNrOp)
                     If EEQ->EEQ_NROP <> cNrOp
                        EEQ->( dbSkip() )
                        Loop
                     EndIf
                  EndIf

                  If EEQ->( Empty(EEQ_FFC) .And. IF(lFFCIMP, EMPTY(EEQ_FFCIMP),.T.) .AND. Empty(EEQ_PGT) ) .AND.; // EMPTY(EEQ_SOL)) .AND.; // ** By JBJ - 19/05/03 - Nao filtrar pela Dt.Sol.Cambio. //HVR 04/04/06 ADICIONADO  .And. IF(lFFCIMP, EMPTY(EEQ_FFCIMP),.T.)
                     ( Empty(dVenctI) .OR. ( EEQ->( DtoS(EEQ_VCT) >= DtoS(dVenctI) .AND. DtoS(EEQ_VCT) <= DtoS(dVenctF) ) ) ) .AND.;
                     ( !lOkEVENT .OR. ( Empty(cInvoice) .OR. ( EEQ->EEQ_INVOICE == cInvoice /* .AND. If(!lOkEvent,.T.,EEQ->EEQ_EVENT == EV_PRINC2)*/ ) ) )

                     TMP->( dbAppend() )
                     RegToMemory("EEQ", .F.)
                     AvReplace("EEQ","TMP")
                     TMP->EEQ_VLFCAM:= AF200VLFCam("EEQ", "ALT")                              //NCF - 11/04/2011
                     TMP->TRB_ALI_WT:= "EEQ"
                     TMP->TRB_REC_WT:= EEQ->(Recno())
                     SA1->( dbSetOrder(1) )
                     SA1->( dbSeek(xFilial("EEQ")+EEQ->EEQ_IMPORT) )
                     TMP->WK_Import := EEC->EEC_IMPORT + "-" + SA1->A1_NREDUZ
                     TMP->A1_COD := EEC->EEC_IMPORT //LRS - 28/09/2018
                     TMP->EEQ_FILORI := EEQ->EEQ_FILIAL + " - " + AvgFilName({EEQ->EEQ_FILIAL})[1]
                     nTotal += TMP->EEQ_VL
                  EndIf

                  EEQ->( dbSkip() )
               EndDo
            EndIf
         Next nTipCon
         //**
     Next    //LRL 20/12/04
   #ENDIF

   If lOkEVENT
      //LRL 18/12/04--------------------------------------------------------------------------------------------
      aCAMPOTMP := {{"EEQ_FLAG","","  "}}
      If lMultiFil
          aAdd(aCampoTmp,{"EEQ_FILORI","","Filial"})
      EndIF
      aAdd(aCampoTmp,COLBRW("EEQ_EVENT","TMP"))
      aAdd(aCampoTmp,{"WK_IMPORT","","Importador"})
      aAdd(aCampoTmp,COLBRW("EEQ_PREEMB","TMP"))
      aAdd(aCampoTmp,COLBRW("EEQ_NRINVO","TMP"))
      aAdd(aCampoTmp,COLBRW("EEQ_PARC"  ,"TMP"))
      aAdd(aCampoTmp,COLBRW("EEQ_VCT"   ,"TMP"))
      aAdd(aCampoTmp,COLBRW("EEQ_VL"    ,"TMP"))
      aAdd(aCampoTmp,{{||TRANSF(TMP->EEQ_VLFCAM, '@E 999,999,999,999.99')},"",AVSX3("EEQ_VLFCAM",5) }) //NCF - 11/04/2011
      aAdd(aCampoTmp,COLBRW("EEQ_NROP"  ,"TMP"))
      //--------------------------------------------------------------------------------------------LRL 18/12/04
      If EECFlags("FRESEGCOM")
         aAdd(aCampoTmp,COLBRW("EEQ_MOEDA" ,"TMP"))
         aAdd(aCampoTmp,COLBRW("EEQ_PARI"  ,"TMP"))
         aAdd(aCampoTmp,COLBRW("EEQ_CODEMP","TMP"))
         aAdd(aCampoTmp,COLBRW("EEQ_FORN"  ,"TMP"))
         aAdd(aCampoTmp,COLBRW("EEQ_FOLOJA","TMP"))
         aAdd(aCampoTmp,COLBRW("EEQ_TIPO"  ,"TMP"))

         If EEQ->( FieldPos("EEQ_TP_CON") ) > 0
            aAdd(aCampoTmp,COLBRW("EEQ_TP_CON","TMP"))
         EndIf
      EndIf
   Else
      //LRL 18/12/04--------------------------------------------------------------------------------------------
      aCAMPOTMP := {{"EEQ_FLAG","","  "}}
  	  If lMultiFil
          aAdd(aCampoTmp,{"EEQ_FILORI","","Filial"})
      EndIF
  	  aAdd(aCampoTmp,{"WK_IMPORT","","Importador"})
      aAdd(aCampoTmp,COLBRW("EEQ_PREEMB","TMP"))
      aAdd(aCampoTmp,COLBRW("EEQ_PARC"  ,"TMP"))
      aAdd(aCampoTmp,COLBRW("EEQ_VCT"   ,"TMP"))
      aAdd(aCampoTmp,COLBRW("EEQ_VL"    ,"TMP"))
      aAdd(aCampoTmp,{{||TRANSF(TMP->EEQ_VLFCAM, '@E 999,999,999,999.99')},"",AVSX3("EEQ_VLFCAM",5) }) //NCF - 11/04/2011
      aAdd(aCampoTmp,COLBRW("EEQ_NROP"  ,"TMP"))
      //--------------------------------------------------------------------------------------------LRL 18/12/04
   EndIf

   If AVFLAGS("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP")
      aAdd(aCampoTMP, {{||Transform(TMP->EEQ_ACRESC, AVSX3("EEQ_ACRESC",AV_PICTURE))}, "", AVSX3("EEQ_ACRESC",AV_TITULO)})
      aAdd(aCampoTMP, {{||Transform(TMP->EEQ_DECRES, AVSX3("EEQ_DECRES",AV_PICTURE))}, "", AVSX3("EEQ_DECRES",AV_TITULO)}) 
   EndIf

ELSE
   // QUANDO NAO FOR INCLUSAO DE FFC
   //LRL 18/12/04 ------------------Considerar-todas as filiais-----------------------------------
   If !lMultiFil
     aFil := {cFilAnt}
   EndIf
   For i:= 1 To Len(aFil)
      cFilAnt:=aFil[i] //LRL 18/12/04 - Seta o Resultado do xFilial caso Exclusivo
      EEC->(DBSETORDER(1))
      EEC->(DBSEEK(XFILIAL("EEC")+if(!lMultiFil ,EEQ->EEQ_PREEMB,"")))
      cCONDPAG := EEC->EEC_CONDPA
      nDIASPAG := EEC->EEC_DIASPA
      EEQ->(DBSETORDER(2))
      EEQ->(DBSEEK(XFILIAL("EEQ")+cFFC))
      DO WHILE ! EEQ->(EOF()) .AND.;
         EEQ->(if(!lMultiFil ,EEQ_FILIAL,"")+EEQ_FFC) = (if(!lMultiFil ,XFILIAL("EEQ"),"")+cFFC)
         *
         If lMultiFil  .And. EEQ->EEQ_FILIAL <> xFIlial("EEQ")
            EEQ->(dbSkip())
            Loop
         EnDIf
         If lIntFina .and. lFinanciamento .and.;
         (EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,If(EEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+EEQ->EEQ_NRINVO+EEQ->EEQ_PARC+EV_LIQ_PRC)) .or.;   //HVR 08/03/2006 - Incluido no indice o campo EF3_TPMODU
         EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,If(EEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+EEQ->EEQ_NRINVO+EEQ->EEQ_PARC+EV_LIQ_PRC_FC))) .and. !Empty(EF3->EF3_NR_CON)   //HVR 08/03/2006 - Incluido no indice o campo EF3_TPMODU
            EEQ->(dbSkip())
            Loop
         EndIf
         EEC->(DBSETORDER(1))
         EEC->(DBSEEK(XFILIAL("EEC")+EEQ->EEQ_PREEMB))
         IF ! EMPTY(cCONDPAG) .AND. cCONDPAG # EEC->EEC_CONDPA
           cCONDPAG := SPACE(LEN(cCONDPAG))
           nDIASPAG := 0
         ENDIF
         TMP->(DBAPPEND())
         RegToMemory("EEQ", .F.)
         AVREPLACE("EEQ","TMP")
         TMP->TRB_ALI_WT:= "EEQ"
         TMP->TRB_REC_WT:= EEQ->(Recno())
         If EEQ->( FieldPos("EEQ_BCOEXT") ) > 0 .And. TMP->( FieldPos("EEQ_NBCEXT") ) > 0 //AOM - 21/09/10 //NCF - 08/09/2014 - verificar campo EEQ_NBCEXT
            TMP->EEQ_NBCEXT:= Posicione("SA6", 1, xFilial("SA6") + EEQ->(EEQ_BCOEXT + EEQ_AGCEXT + EEQ_CNTEXT), "A6_NOME")
         Endif
         TMP->EEQ_VLFCAM:= AF200VLFCam("EEQ", "ALT")                              //NCF - 11/04/2011
         SA1->(DBSetOrder(1))
         SA1->(DBSeek(xFilial("SA1")+EEC->EEC_IMPORT))
         TMP->WK_Import := EEC->EEC_IMPORT + "-" + SA1->A1_NREDUZ
         TMP->A1_COD := EEC->EEC_IMPORT //LRS - 28/09/2018
         TMP->EEQ_FILORI:= xFilial("EEQ")+ " - " + AvgFilName({xFilial("EEQ")})[1]
         nTotal += TMP->EEQ_VL

         If !lEaiExecAut .And. Empty(aDadosEAI) //privates na função principal, de onde esta função estática é chamada.
            cNumFFC := TMP->EEQ_FFC
            aAdd(aDadosEAI,{"EEQ_DTNEGO",TMP->EEQ_DTNEGO})
            aAdd(aDadosEAI,{"EEQ_PGT",TMP->EEQ_PGT})
            aAdd(aDadosEAI,{"EEQ_TX",TMP->EEQ_TX})
            aAdd(aDadosEAI,{"EEQ_NROP",TMP->EEQ_NROP})
            aAdd(aDadosEAI,{"EEQ_BANC",TMP->EEQ_BANC})
            aAdd(aDadosEAI,{"EEQ_AGEN",TMP->EEQ_AGEN})
            aAdd(aDadosEAI,{"EEQ_NCON",TMP->EEQ_NCON})
            aAdd(aDadosEAI,{"EEQ_NOMEBC",TMP->EEQ_NOMEBC})
            aAdd(aDadosEAI,{"EEQ_DECAM",TMP->EEQ_DECAM})
            aAdd(aDadosEAI,{"EEQ_RFBC",TMP->EEQ_RFBC})
            aAdd(aDadosEAI,{"EEQ_CORR",TMP->EEQ_CORR})
         EndIf
         EEQ->(DBSKIP())
       ENDDO
   Next
   If lOkEVENT
      //LRL 18/12/04--------------------------------------------------------------------------------------------
      aCAMPOTMP := {}
      If lMultiFil
          aAdd(aCampoTmp,{"EEQ_FILORI","","Filial"})
      EndIF
      aAdd(aCampoTmp,{"WK_IMPORT","","Importador"})
      aAdd(aCampoTmp,COLBRW("EEQ_PREEMB","TMP"))
      aAdd(aCampoTmp,COLBRW("EEQ_NRINVO","TMP"))
      aAdd(aCampoTmp,COLBRW("EEQ_PARC"  ,"TMP"))
      aAdd(aCampoTmp,COLBRW("EEQ_VCT"   ,"TMP"))
      aAdd(aCampoTmp,COLBRW("EEQ_VL"    ,"TMP"))
      aAdd(aCampoTmp,{{||TRANSF(TMP->EEQ_VLFCAM, '@E 999,999,999,999.99')},"",AVSX3("EEQ_VLFCAM",5) }) //NCF - 11/04/2011
      aAdd(aCampoTmp,COLBRW("EEQ_NROP"  ,"TMP"))
      //--------------------------------------------------------------------------------------------LRL 18/12/04
      If EECFlags("FRESEGCOM")
         aAdd(aCampoTmp,COLBRW("EEQ_MOEDA" ,"TMP"))
         aAdd(aCampoTmp,COLBRW("EEQ_PARI"  ,"TMP"))
         aAdd(aCampoTmp,COLBRW("EEQ_CODEMP","TMP"))
         aAdd(aCampoTmp,COLBRW("EEQ_FORN"  ,"TMP"))
         aAdd(aCampoTmp,COLBRW("EEQ_FOLOJA","TMP"))
         aAdd(aCampoTmp,COLBRW("EEQ_TIPO"  ,"TMP"))

         If EEQ->( FieldPos("EEQ_TP_CON") ) > 0
            aAdd(aCampoTmp,COLBRW("EEQ_TP_CON","TMP"))
         EndIf
      EndIf

      If AvFlags("EEC_LOGIX")                                                                          //NCF - 15/05/2015
         If EEQ->(FieldPos("EEQ_FINNUM")) > 0
            aAdd(aCampoTmp,COLBRW("EEQ_FINNUM","TMP"))
         EndIf
         If EEQ->(FieldPos("EEQ_SEQBX")) > 0
            aAdd(aCampoTmp,COLBRW("EEQ_SEQBX","TMP"))
         EndIf
      EndIf

   Else
      //LRL 18/12/04--------------------------------------------------------------------------------------------
      aCAMPOTMP := {}
      If lMultiFil
          aAdd(aCampoTmp,{"EEQ_FILORI","","Filial"})
      EndIF
      aAdd(aCampoTmp,{"WK_IMPORT","","Importador"})
      aAdd(aCampoTmp,COLBRW("EEQ_PREEMB","TMP"))
      aAdd(aCampoTmp,COLBRW("EEQ_PARC"  ,"TMP"))
      aAdd(aCampoTmp,COLBRW("EEQ_VCT"   ,"TMP"))
      aAdd(aCampoTmp,COLBRW("EEQ_VL"    ,"TMP"))
      aAdd(aCampoTmp,{{||TRANSF(TMP->EEQ_VLFCAM, '@E 999,999,999,999.99')},"",AVSX3("EEQ_VLFCAM",5) })  //NCF - 11/04/2011
      aAdd(aCampoTmp,COLBRW("EEQ_NROP"  ,"TMP"))
     //--------------------------------------------------------------------------------------------LRL 18/12/04
   EndIf

   If AVFLAGS("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP")
      aAdd(aCampoTMP, {{||Transform(TMP->EEQ_ACRESC, AVSX3("EEQ_ACRESC",AV_PICTURE))}, "", AVSX3("EEQ_ACRESC",AV_TITULO)})
      aAdd(aCampoTMP, {{||Transform(TMP->EEQ_DECRES, AVSX3("EEQ_DECRES",AV_PICTURE))}, "", AVSX3("EEQ_DECRES",AV_TITULO)}) 
   EndIf

ENDIF
cFilAnt := xcFil //LRL 18/12/04
If lIntFina .and. lFinanciamento
   EF3->(dbSetOrder(1))
EndIf

//ER - 03/04/2007
If EasyEntryPoint("EECAF300")
   ExecBlock("EECAF300",.F.,.F.,{"FIM_GRV_TMP"})
EndIf

#IFDEF TOP
   If Select("Qry") > 0
      Qry->(DbCloseArea())
   EndIf
#ENDIF

TMP->(DBGOTOP())

// ** By JBJ - 17/01/03 - Carrega as Cotações para o FFC.
If lCotaCambio
   EXG->(DbSetOrder(1))
   EXG->(DbSeek(xFilial("EXG")+AvKey("_FFC"+TMP->EEQ_FFC,"EXG_PREEMB")))

   Do While EXG->(!Eof()) .And. EXG->EXG_FILIAL == xFilial("EXG") .And.;
                                EXG->EXG_PREEMB == AvKey("_FFC"+TMP->EEQ_FFC,"EXG_PREEMB")
      Work_Cot->(DbAppend())
      AvReplace("EXG","Work_Cot")
      Work_Cot->RECNO := EXG->(RecNo())
      Work_Cot->TRB_ALI_WT:= "EXG"
      Work_Cot->TRB_REC_WT:= EXG->(Recno())
      EXG->(DbSkip())
   EndDo

   Work_Cot->(DbGoTop())
EndIf

RETURN(NIL)
*--------------------------------------------------------------------
STATIC FUNCTION AF300B()
LOCAL cPREEMB
Local lBcoExt := EEQ->(FieldPos("EEQ_MODAL")) > 0 .And. EEQ->(FieldPos('EEQ_BCOEXT')) > 0 .And. EEQ->(FieldPos('EEQ_AGCEXT')) > 0 .And. EEQ->(FieldPos('EEQ_CNTEXT')) > 0
Local cAction := ""
Local lRet := .T.
Local aCposInt := {"EEQ_FORN", "EEQ_FOLOJA", "EEQ_IMPORT", "EEQ_IMLOJA", "EEQ_BANC", "EEQ_VCT", "EEQ_VL"}
Local lAltTit := .F.
Local cSeqPag := ""
Local cProcess := ""
Local lCpoProc := TMP->(FieldPos('EEQ_TPPROC')) > 0 .And. TMP->(FieldPos('EEQ_REGIST')) > 0
Local nRecNoTmp := 0
Local lExibMsg  := .T.
Local cFilAtuEEQ := ""
Local aOrdTMP
// INCLUI FFC NA BASE
M->EEC_STATUS := ""
M->EEC_STTDES := ""
EEQ->(DBSETORDER(1))
TMP->(DBGOTOP())

Begin Transaction

ProcRegua(TMP->(LastRec()))

If EEQ->(FieldPos("EEQ_BCOEXT")) > 0
   aAdd(aCposInt,"EEQ_BCOEXT")
EndIf

DO WHILE ! TMP->(EOF())
   EEC->(DBSEEK(Left(TMP->EEQ_FILORI,FWSizeFilial())+TMP->EEQ_PREEMB))   //TRP - 12/09/2012 - Utilizar a função FWSizeFilial() para retornar o tamanho da filial.
   //EEC->(RECLOCK("EEC",.F.))
   cPREEMB := TMP->EEQ_PREEMB

   If lCpoProc .And. cProcess <>  EEQ->EEQ_TPPROC+EEQ->EEQ_REGIST
      cProcess := TMP->EEQ_TPPROC+TMP->EEQ_REGIST
      cSeqPag := RS401PrxNum(cProcess)
   EndIf

   DO WHILE ! TMP->(EOF()) .AND. TMP->EEQ_PREEMB = cPREEMB
      //nRecNoTmp:= TMP->(RecNo())
      aOrdTMP := SaveOrd('TMP')    
      IF ! EMPTY(TMP->EEQ_FLAG) .AND.; //LRS - 06/07/2015 - Correção do DBSEEK.
         (EEQ->(DBSEEK(Left(TMP->EEQ_FILORI,FWSizeFilial())+TMP->(EEQ_PREEMB+EEQ_PARC)+TMP->EEQ_FASE))) //TRP - 12/09/2012 - Utilizar a função FWSizeFilial() para retornar o tamanho da filial.

         EEQ->(RECLOCK("EEQ",.F.))

         If lBcoExt .And. EEQ->EEQ_MODAL == "2" .And. lCpoProc
            lAltTit := AvGeraTit("TMP","EEQ",aCposInt)
            cAction := ""
            If Empty(EEQ->EEQ_DTCE) .And. !Empty(TMP->EEQ_DTCE)
               cAction := "6" // Baixa
            ElseIf !Empty(EEQ->EEQ_DTCE) .And. Empty(TMP->EEQ_DTCE)
               cAction := "7" // Estorno
            ElseIf !Empty(EEQ->EEQ_DTCE) .And. !Empty(TMP->EEQ_DTCE) .And. (EEQ->EEQ_DTCE <> TMP->EEQ_DTCE .Or. lAltTit)
               cAction := "4" // Alteração
            EndIf
            If cProcess <>  EEQ->EEQ_TPPROC+EEQ->EEQ_REGIST
               cSeqPag := RS401PrxNum(EEQ->EEQ_TPPROC+EEQ->EEQ_REGIST)
            EndIf
         EndIf

         EEQ->EEQ_FFC    := cFFC
         EEQ->EEQ_SOL    := TMP->EEQ_SOL
         EEQ->EEQ_DTNEGO := TMP->EEQ_DTNEGO
         EEQ->EEQ_DECAM  := TMP->EEQ_DECAM
         EEQ->EEQ_BANC   := TMP->EEQ_BANC
         EEQ->EEQ_AGEN   := TMP->EEQ_AGEN
         EEQ->EEQ_NCON   := TMP->EEQ_NCON
         EEQ->EEQ_NOMEBC := TMP->EEQ_NOMEBC
         EEQ->EEQ_RFBC   := TMP->EEQ_RFBC
         EEQ->EEQ_CORR   := TMP->EEQ_CORR
         EEQ->EEQ_DTCE   := TMP->EEQ_DTCE
         If !lIntFina .and. !lFinanciamento
            EEQ->EEQ_VLCOR  := TMP->EEQ_VLCOR
            EEQ->EEQ_JRAA   := TMP->EEQ_JRAA
            EEQ->EEQ_ADIA   := TMP->EEQ_ADIA
            EEQ->EEQ_RESP   := TMP->EEQ_RESP
            EEQ->EEQ_CTDC   := TMP->EEQ_CTDC
         EndIf

         //TRP - 05/06/2012 - Gravaçao do campo Observação.
         EEQ->EEQ_OBS:= TMP->EEQ_OBS

         cFilAtuEEQ := EEQ->EEQ_FILIAL            //NCF - 27/02/2013 - Recupera a filial quando ativado o modo Multifilial
		//*** GFP - 29/07/2011 :: 14h16 - Forçar gravação da numeração FFC na Work
         TMP->EEQ_FFC := cFFC
         AVREPLACE("TMP","EEQ")

         If lMultiFil                             //NCF - 27/02/2013 - Acerta a gravação quando ativado o modo Multifilial
            EEQ->EEQ_FILIAL := cFilAtuEEQ
         EndIf
         // ** JPM 11/12/2009
         If EECFlags("CAMBIO_EXT") .Or. AvFlags("CAMBIO_EXP_MOV_EXT")
            EEQ->EEQ_NROPAG := TMP->EEQ_NROPAG
         EndIf

         //Alcir - 26-08-04
         If EasyEntryPoint("EECAF300")
             ExecBlock("EECAF300",.F.,.F.,{"INC_FFC"})
         Endif

         /*If lBcoExt // Limpando os campos do banco de acordo com a modalidade
            If EEQ->EEQ_MODAL == "2"
               EEQ->EEQ_BANC   := Space(AvSx3("EEQ_BANC",AV_TAMANHO))
               EEQ->EEQ_AGEN   := Space(AvSx3("EEQ_AGEN",AV_TAMANHO))
               EEQ->EEQ_NCON   := Space(AvSx3("EEQ_NCON",AV_TAMANHO))
               EEQ->EEQ_NOMEBC := Space(AvSx3("EEQ_NOMEBC",AV_TAMANHO))
            Else
               EEQ->EEQ_BCOEXT := Space(AvSx3('EEQ_BCOEXT',AV_TAMANHO))
               EEQ->EEQ_AGCEXT := Space(AvSx3('EEQ_AGCEXT',AV_TAMANHO))
               EEQ->EEQ_CNTEXT := Space(AvSx3('EEQ_CNTEXT',AV_TAMANHO))
            EndIf
         EndIf*/

         EEQ->(MSUNLOCK())

         // Tratamento para integraçao da movimentacao no exterior
         If lBcoExt .And. lCpoProc .And. !Empty(cAction)

            If Select('TMP') > 0
               TMP->(DbCloseArea())    //NCF - Fecha a área da TMP para ser aberta posteriorente, já que pode ser utilizada pelo SIGACTB na integração com SIGAFIN
            EndIf
            /*RRC - 08/03/2013 - Para o Easy Siscoserv, lMsg verifica se deve exibir a mensagem de confirmação da exclusão dos pagamentos para estorno de liquidação
            Caso tenha excluída uma vez, não pergunta novamente*/
            If (lRet := AF300Integ(cAction,cSeqPag,lExibMsg))
               lExibMsg := .F.
            EndIf
            cProcess := EEQ->EEQ_TPPROC+EEQ->EEQ_REGIST
         EndIf

         If !lRet
            //EasyHelp("A gravação não ocorreu devido à impossibilidade de integração com o módulo Financeiro. Verifique o Log Viewer.") // "A gravação não ocorreu devido à impossibilidade de integração com o módulo Financeiro. Verifique o Log Viewer."
            ELinkRollBackTran()
            Exit
         EndIf

      ENDIF

      If Select("TMP") == 0
         AF300AbTMP('1')
         RestOrd(aOrdTMP,.T.)
      EndIF

      If !Empty(cAction) .And. cAction == "7" .And. TMP->(FieldPos("EEQ_SEQPAG")) > 0
 	     TMP->EEQ_SEQPAG := ""
      EndIf

      TMP->(DBSKIP())
   ENDDO

   AF200STATUS("EEQ",.T.)
   If EasyEntryPoint("EECAF300") // By JPP - 15/08/2005 - 09:00 - Inclusão do ponto de entrada.
      ExecBlock("EECAF300",.F.,.F.,{"PE_STATUS_B"})
   Endif
ENDDO

End Transaction
If !lRet
    EasyElinkError("FIN", !(IsMemVar("lEaiExecAut") .And. lEaiExecAut))
EndIf
ELinkClearID()

RETURN lRet


/*
Funcao      : AF300C()
Parametros  :
Retorno     :
Objetivos   :
Autor       :
Data/Hora   :
Revisão     :
Obs.        :
*/
FUNCTION AF300C()
Local lRet := .T.

If !InTransaction()

   Begin Transaction

      If !(lRet := AF300Baixa())
         //MsgInfo(STR0101,STR0036)  // "Impossibilidade de integração com o módulo Financeiro. Verifique o Log Viewer."
         ELinkRollBackTran()
      EndIf

   End Transaction
   ELinkClearID()

Else

   If !(lRet := AF300Baixa())
      //MsgInfo(STR0101,STR0036)  // "Impossibilidade de integração com o módulo Financeiro. Verifique o Log Viewer."
      ELinkRollBackTran()
   EndIf

EndIf
If !lRet
    EasyElinkError("FIN", !(IsMemVar("lEaiExecAut") .And. lEaiExecAut))
EndIf
Return lRet

Static Function AF300Baixa()
LOCAL cPREEMB, nEF3Rec, i:=0, nx:=0, ni:=0, nTxAux:=1, nRecAux, cCpoDt:=EasyGParam("MV_CPODTJR",,"EEQ_DTCE")
Local nRecNoTmp
Local aProcessos := {} /* array que irá definir quais processos passaram a ter todas as suas parcelas liquidadas
                          ou nenhuma delas, para o controle de acerto na renovação de saldo da L/C */
Local aEmbarques:= {} //embarques que devem ter seus títulos recriados no sigafun após vinculação e liquidação do adiantamento pós embarque
Local cSeek:= ""
Local lRet:= .T.
Local cProcess := ""
Local lCpoProc := TMP->(FieldPos('EEQ_TPPROC')) > 0 .And. TMP->(FieldPos('EEQ_REGIST')) > 0 .And. EEQ->(FieldPos('EEQ_TPPROC')) > 0 .And. EEQ->(FieldPos('EEQ_REGIST')) > 0
Local cSeqPag := ""
Local cAction := ""
Local lAltTit := .F.
Local aCposInt := {"EEQ_FORN", "EEQ_FOLOJA", "EEQ_IMPORT", "EEQ_IMLOJA", "EEQ_BANC", "EEQ_VCT", "EEQ_VL"}
Local cIntAction := ""
Local lExibMsg   := .T.
Local aReg     := {}
Local aOrdTMP
Private aGetProv := {}, aArrayEEQ:={}, nSeqAux:=1  // GFC - 22/01/05 - Para dar os gets das provisões de juros (financiamento)
Private aROTINA   := {{"","",0,1},{"","",0,2},{"","",0,4},{"","",0,4}}  // GFC - 22/01/05 - MsGetDados
Private aRestItens := {}, aTotInvoice := {} //JPM
Private nValorBaixa //DFS - Criação de variável para puxar corretamente do XML
Private nParcEst // Utilizada no estorno
Private dDtBaixa //DFS -  Criação de variável para puxar corretamente do XML
//** GFC - 16/08/05 - Flag para controlar se é para baixar os contratos de financiamento automaticamente ou não,
//                    que será atualizado na função ex400liquida
If Type("lRollBack") <> "L"
   lRollBack := .F.
EndIf

If Type('lEstorno') <> 'L'
   lEstorno:= .F.
EndIf

If Type("lCallRS403") <> "L"
   lCallRS403:= .F.
EndIf

//RRC - 07/03/2013
If IsInCallStack("ESSRS400")
   cModulo := "ESS"
EndIf

If EEQ->(FieldPos("EEQ_BCOEXT")) > 0
   aAdd(aCposInt,"EEQ_BCOEXT")
EndIf

cBaixaCont := "2" //1-SIM, 2-NAO (ainda não perguntou), 3-NAO (já perguntou)
//**

Af200CtrRen(1,,,.t.) // JPM - 08/08/05 - Apura totais de invoice e de restauração de saldo

// GRAVA A BAIXA NA BASE
If lLiq .and. lIntFina .and. lFinanciamento
   EF3->(dbSetOrder(3))
EndIf

EEC->(DBSETORDER(1))
EEQ->(DBSETORDER(1))
TMP->(DBGOTOP())
DO WHILE ! TMP->(EOF())

	   If lMultiFil
		  cFilAnt:=Left(TMP->EEQ_FILORI,FWSizeFilial())  //TRP - 12/09/2012 - Utilizar a função FWSizeFilial() para retornar o tamanho da filial.
	   EndIf

	   EEC->(DBSEEK(XFILIAL("EEC")+TMP->EEQ_PREEMB))
	   M->EEC_STATUS := ""
	   M->EEC_STTDES := ""
	   cPREEMB := TMP->EEQ_PREEMB

	   If lLiq .and. lIntFina .and. lFinanciamento
		  aArrayEEQ := {}
		  nSeqAux:=1
		  nRecAux := TMP->(RecNo())
		  DO WHILE ! TMP->(EOF()) .AND. TMP->EEQ_PREEMB = cPREEMB
			 EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,If(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),"")+TMP->EEQ_NRINVO+If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN)+EV_EMBARQUE))//HVR 08/03/2006 - Incluido no indice o campo EF3_TPMODU
			 GrvArrayEEQ()
			 TMP->(dbSkip())
		  EndDo
		  TMP->(dbGoTo(nRecAux))
	   EndIf

	   EF3->( dbSetOrder(3) )

       If lCpoProc .And. cProcess <> TMP->EEQ_TPPROC+TMP->EEQ_REGIST
          cProcess := TMP->EEQ_TPPROC+TMP->EEQ_REGIST
          cSeqPag := RS401PrxNum(cProcess)
       EndIf

	   DO WHILE ! TMP->(EOF()) .AND. TMP->EEQ_PREEMB = cPREEMB
		  IF (EEQ->(DBSEEK(  If(lMultifil, Left(TMP->EEQ_FILORI,FWSizeFilial()), XFILIAL("EEQ") ) +TMP->(EEQ_PREEMB+EEQ_PARC)+TMP->EEQ_FASE)))     //NCF - 06/03/2014 - Tratamento Multifilial

			 Af200CtrRen(2,,,.t.) // JPM - 08/08/05 - Faz as restaurações/abatimentos de saldo das cartas de crédito renováveis.

			 If EECFlags("ITENS_LC") .And. Tmp->EEQ_EVENT == "101"

				If (nPos := AScan(aProcessos,{|x| x[1]+x[2] == EEQ->(EEQ_FILIAL+EEQ_PREEMB) })) = 0
				   AAdd(aProcessos,{EEQ->EEQ_FILIAL,EEQ->EEQ_PREEMB,.f.,.f.}) // 3ª pos. = tem parcela liquidada? / 4ª pos. = tem parcela não liquidada?
				   nPos := Len(aProcessos)
				EndIf

				RegToMemory("TMP", .F., .F., .F.) //LRS - 05/02/2015
				If !Empty( AF200DtBaixa("M")) .And. !aProcessos[nPos][3] // !Empty(Tmp->EEQ_PGT) .And. !aProcessos[nPos][3]
				   aProcessos[nPos][3] := .t.
				ElseIf Empty(AF200DtBaixa("M")) .And. !aProcessos[nPos][4]// Empty(Tmp->EEQ_PGT) .And. !aProcessos[nPos][4]
				   aProcessos[nPos][4] := .t.
				EndIf

			 EndIf

			 //*** RMD - 10/11/07 - Nova legislação de câmbio
			 If EECFlags("CAMBIO_EXT")
				//Grava as movimentações
				AD101GrvInv("EEQ", "TMP", "EXPBXG",, .T.)

				//** AAF 04/03/08 - Liquidação do FFC

	// JPM - 14/01/2010 - Tirada a verificação, pois tem que passar aqui no estorno da liquidação também.
	//            If lLiq
				AD101GrvInv("EEQ", "TMP", "EXPLIQ",, .T.)
	//            EndIf
				//**
			 EndIf
			 //***

			 EEQ->(RECLOCK("EEQ",.F.))
			 cAction := ""
			 If EasyVerModal()  //EEQ->(FieldPos("EEQ_MODAL")) > 0 .And. EEQ->EEQ_MODAL == "2"
                lAltTit := AvGeraTit("TMP","EEQ",aCposInt)
                If Empty(EEQ->EEQ_DTCE) .And. !Empty(TMP->EEQ_DTCE)
                  cAction := "6" // Baixa
                ElseIf !Empty(EEQ->EEQ_DTCE) .And. Empty(TMP->EEQ_DTCE)
                  cAction := "7" // Estorno
                ElseIf !Empty(EEQ->EEQ_DTCE) .And. !Empty(TMP->EEQ_DTCE) .And. (EEQ->EEQ_DTCE <> TMP->EEQ_DTCE .Or. lAltTit)
                  cAction := "4" // Alteração
                ElseIf AF200ParcLiq()
                  cAction := "0" // Baixado no movimento exterior
                EndIf
			 EndIf

			 If lCpoProc .And. cProcess <>  EEQ->EEQ_TPPROC+EEQ->EEQ_REGIST
                cSeqPag := RS401PrxNum(EEQ->EEQ_TPPROC+EEQ->EEQ_REGIST)
             EndIf

             //NCF - 08/09/2014
             If TMP->EEQ_PGT <> EEQ->EEQ_PGT
                aReg := {}
                For i:=1 To EEQ->(Fcount())
                   aAdd(aReg, &("EEQ->"+EEQ->(FIELDNAME(i)) ) )
                Next i
                aAdd(aParcLiq, aReg)
                AF200BKPInt('EEQ', If(lEstorno, 'EEC_ESBX_ALT', 'EEC_INBX_ALT') , aParcLiq[Len(aParcLiq)], , , )
             EndIf

			 AVREPLACE("TMP","EEQ")

			 nTxAux := EEQ->EEQ_TX
			 EEQ->EEQ_EQVL := (EEQ->EEQ_VL - EEQ->EEQ_CGRAFI) * nTxAux //LRS - 21/03/2018
			 If lLiq .and. lIntFina .and. lFinanciamento .and. !Empty(EEQ->EEQ_PGT) .and.;
			 EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,If(EEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+EEQ->EEQ_NRINVO+If(!lParFin .Or. Empty(EEQ->EEQ_PARFIN), EEQ->EEQ_PARC, EEQ->EEQ_PARFIN)+EV_EMBARQUE))   //HVR 08/03/2006 - Incluido no indice o campo EF3_TPMODU
				//GrvArrayEEQ()
				FAF2ArrayEEQ()
				For ni:=1 to Len(aArrayEEQ)
				   If aArrayEEQ[ni,1] > 0 .and. !aArrayEEQ[ni,21]
					  EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,If(EEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+aArrayEEQ[ni,5]+If(lTemChave,aArrayEEQ[ni,14]+aArrayEEQ[ni,15]+If(lEFFTpMod,aArrayEEQ[ni,22],""),""))) //HVR 08/03/2006 - Incluido no indice o campo EF3_TPMODU e EF3_SEQCNT

					  cMod := IIF(lEFFTpMod,EF1->EF1_TPMODU,"E")
					  EX400Liquida(EF1->EF1_CONTRA,EEQ->EEQ_NRINVO,;
								   If(lParFin .and. !Empty(aArrayEEQ[ni,13]), aArrayEEQ[ni,13], aArrayEEQ[ni,3]),EEQ->EEQ_PREEMB,;
								   aArrayEEQ[ni,1],EEC->EEC_MOEDA,EF1->EF1_MOEDA,"EF1","EF3","FFC",EEQ->EEQ_TX,EEQ->&(cCpoDt),If(!Empty(EEQ->EEQ_DTNEGO),EEQ->EEQ_DTNEGO,EEQ->EEQ_PGT),EEQ->EEQ_PGT,If(lMultiFil,xFilial("EEQ"),Nil),;
								   Nil,Nil,Nil,Nil,If(lTemChave,aArrayEEQ[ni,14],""),If(lTemChave,EEQ->EEQ_AGEN,""),If(lTemChave,EEQ->EEQ_NCON,""),If(lTemChave,aArrayEEQ[ni,15],),Nil,;
								   aArrayEEQ[ni,1] * nTxAux, , TMP->EEQ_NROP, aArrayEEQ[ni,16], If(lEFFTpMod,If(EEQ->EEQ_TP_CON $ ("1/3"),"E","I"),""), If(lEFFTpMod,aArrayEEQ[ni,22],"") )  //If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN) - retirado do segundo parametro dessa linha
					  aArrayEEQ[ni,21] := .T.
				   ElseIf aArrayEEQ[ni,1] = 0 .and. !aArrayEEQ[ni,21]
					  aArrayEEQ[ni,1] := aArrayEEQ[ni,17]
				   EndIf
				Next ni
			 EndIf

			 // ** By JBJ - 15/09/03 - 18:45. - Chamada só na liquidação da parcela.
			 If lLiq

				//WFS 12/05/11
				//Quando há customização que aciona o contábil a área de trabalho TMP é encerrada
				//nRecNoTmp:= TMP->(RecNo())
            aOrdTMP := SaveOrd('TMP')    //NCF - Fecha a área da TMP para ser aberta posteriorente, já que pode ser utilizada pelo SIGACTB na integração com SIGAFIN

				If !Empty(EEQ->EEQ_PGT)
				   If EasyEntryPoint("EECAF300")
					  ExecBlock("EECAF300",.F.,.F.,{"PE_LIQ"})
				   Endif
				EndIf
				//lLiq:=.f.

				If Select("TMP") == 0
               AF300AbTMP('1')
               RestOrd(aOrdTMP,.T.)
				EndIf

			 Else


				//WFS 12/05/11
				//Quando há customização que aciona o contábil a área de trabalho TMP é encerrada
				//nRecNoTmp:= TMP->(RecNo())
            aOrdTMP := SaveOrd('TMP')    //NCF - Fecha a área da TMP para ser aberta posteriorente, já que pode ser utilizada pelo SIGACTB na integração com SIGAFIN

				// ** JPM - 06/01/2010 - ponto de entrada na gravação quando não é liquidação
				If EasyEntryPoint("EECAF300")
				   ExecBlock("EECAF300",.F.,.F.,{"PE_GRV_PARC_SEM_LIQ"})
				Endif

				If Select("TMP") == 0
               AF300AbTMP('1')
               RestOrd(aOrdTMP,.T.)
				EndIf

			 EndIf

		  ENDIF

        //nRecNoTmp:= TMP->(RecNo())
        aOrdTMP := SaveOrd('TMP')    //NCF - Fecha a área da TMP para ser aberta posteriorente, já que pode ser utilizada pelo SIGACTB na integração com SIGAFIN
        If Select('TMP') > 0
           TMP->(DbCloseArea())
        EndIf

		  //DFS - 19/10/10 - Inclusão de tratamento para quando houver integração com financeiro e liquidação de FFC, o sistema baixe os títulos no financeiro também.
		  If lLiq //.AND. IsIntEnable("001")

             ChkFile("SE1")
             SE1->(DbSetOrder(1))
			 //WFS 17/08/11
			 //Revisão do tratamento de integração e implementação da liquidação de adiantamento pós-embarque
			 If Empty(EEQ->EEQ_FINNUM) .And. !lCallRS403
				If IsReceita(EEQ->EEQ_EVENT)
				   If EEQ->EEQ_TIPO == "A" .And. !Empty(EEQ->EEQ_PGT) .And. ( EasyGParam("MV_AVG0180",,.F.) .Or. AVFLAGS("EEC_LOGIX") )

				      If !(lRet := AvStAction("001")) //Inclusão do título de adiantamento no SigaFin
					     lRollBack:= .T.
						 Exit
				      EndIf

                  //Armazena quais são os processos para posterior alteração do título no financeiro
                  If EEQ->EEQ_EVENT == "603"
                     AAdd(aEmbarques, EEQ->EEQ_PREEMB)
                  EndIf


                  If SE1->(DbSeek(xFilial()+"EEC"+AvKey(EEQ->EEQ_FINNUM, "E1_NUM")+AvKey(" ", "E1_PARCELA")+AvKey(TETpTitEEQ("EEQ"),"E1_TIPO")))
                     If !Empty(EEQ->EEQ_PGT) .And. EEQ->EEQ_TIPO == "A" .And. EasyGParam("MV_AVG0180",,.F.) .And. !Empty(EEC->EEC_DTEMBA)
                        nValorBaixa:= EEQ->EEQ_EQVL
                        dDtBaixa   := EEQ->EEQ_PGT
                        If !(lRet := AF300BAIXA("008"))//Baixa do titulo de adiantamento
                           lRollBack := .T.
                           Exit
                        EndIf
                     EndIf
                  EndIf
               EndIf
            EndIf
         Else
            cParcSE1 := If(EECFlags("TIT_PARCELAS"),EECGetFinParc(EEQ->EEQ_PARC),AvKey(" ", "E1_PARCELA")) // GFP - 29/05/2013
            ChkFile("SE1")
            SE1->(DbSetOrder(1))
            If IsReceita(EEQ->EEQ_EVENT)
               If EEQ->EEQ_TIPO == "A"
                  cSeek:= 'SE1->(DbSeek(xFilial()+"EEC"+AvKey(EEQ->EEQ_FINNUM, "E1_NUM")+AvKey(cParcSE1, "E1_PARCELA")+AvKey(TETpTitEEQ("EEQ"),"E1_TIPO")))'  // GFP - 29/05/2013   //NCF - 04/07/2019
               Else
                  cSeek:= 'SE1->(DbSeek(xFilial()+"EEC"+AvKey(EEQ->EEQ_FINNUM, "E1_NUM")+AvKey(cParcSE1, "E1_PARCELA")+AvKey("NF","E1_TIPO")))'  // GFP - 29/05/2013
               EndIf

               If !IsIntEnable("001") .OR. &(cSeek)
                  If EEQ->EEQ_TIPO == "A"
                     nValorBaixa:= EEQ->EEQ_EQVL
                     dDtBaixa   := EEQ->EEQ_PGT

						 If IsIntEnable("001") .AND. !(lRet := AF300Action("008",aOrdTMP)) //Baixa de títulos de adiantamento
                            lRollBack:= .T.
                            Exit
                         EndIf
				      Else
                         nValorBaixa := EEQ->EEQ_EQVL
  					     If !Empty(cAction) .And. ( cAction == "4" .Or. cAction == "7") // Alteraçao ou estorno
  					        If lCallRS403 // Chamada na funcao ESSRS403 - integração de serviço
			                   cIntAction := "024"
			                ElseIf AF201PosicSE5("SE1")
			                   cIntAction := "009"
	     		            EndIf

  					        If !Empty(cIntAction) .And. !AF300Action(cIntAction,aOrdTMP) //Estorno de títulos a receber
  					           lRollBack:= .T.
  					        EndIf

  					     EndIf

			             If lCallRS403 // Chamada na funcao ESSRS403 - integração de serviço
			                cIntAction := "023"
			             Else
			                cIntAction := "004"
			             EndIf

			             If !(lRet := AF300Action("004",aOrdTMP)) //Baixa de títulos a receber   //NCF - 11/04/2011
                            lRollBack:= .T.
                            Exit
                         EndIf

                      EndIf

                   EndIf

                Else

				   ChkFile("SE2")
				   SE2->(DbSetOrder(1))
				   If !IsIntEnable("001") .OR. (SE2->(DbSeek(xFilial()+cModulo+EEQ->EEQ_FINNUM)) ) .Or. lCallRS403      // SE2->(DbSeek(xFilial()+"EEC"+EEQ->EEQ_FINNUM))

                  If !Empty(cAction) .And. ( cAction == "4" .Or. cAction == "7")

                     If lCallRS403 // Chamada na funcao ESSRS403 - integração de serviço
                        cIntAction := "029"
                     ElseIf AF201PosicSE5("SE2")
                        cIntAction := "014"
                     EndIf

                     If !Empty(cIntAction) .AND. !AvStAction(cIntAction) // Estorno de titulos a pagar
                        lRollBack := .T.
                     EndIf

                  EndIf

                  If lCallRS403 // Chamada na funcao ESSRS403 - integração de serviço
                     cIntAction := "028"
                  Else
                     cIntAction := "013"
                  EndIf

                  If !(lRet :=AvStAction("013")) //Baixa de títulos a pagar
                     lRollBack:= .T.
                     Exit
                  Endif

				   EndIf

				EndIf
			 EndIf
		  EndIf

         //WFS 17/08/11
         //Recria os títulos no SigaFin, quando houver vinculação/ liquidação de parcelas de adiantamento pós-embarque
         If Len(aEmbarques) > 0
            If !(lRet:= AF300AtualTit(aEmbarques))
               lRollBack := .T.
               Exit
            EndIf
         EndIf

         If lCpoProc
         cProcess := EEQ->EEQ_TPPROC+EEQ->EEQ_REGIST
         EndIf

         If Select("TMP") == 0
            AF300AbTMP('1')
            RestOrd(aOrdTMP,.T.)
         EndIf

		  If !Empty(cAction) .And. ( cAction == "4" .Or. cAction == "7") .And. TMP->(FieldPos("EEQ_SEQPAG")) > 0
		     TMP->EEQ_SEQPAG := ""
		  EndIf

		  TMP->(DBSKIP())
	   ENDDO

	   If lRollBack
          Exit
       EndIf

	   AF200STATUS("EEQ",.T.)

	   If EasyEntryPoint("EECAF300") // By JPP - 15/08/2005 - 09:00 - Inclusão do ponto de entrada.
		  ExecBlock("EECAF300",.F.,.F.,{"PE_STATUS_C"})
	   Endif

EndDo

If lRet
   If EECFlags("ITENS_LC")
      For i := 1 To Len(aProcessos)
         If aProcessos[i][3] .And. !aProcessos[i][4] // Se apenas houverem parcelas liquidadas
            Af200CtrRen(3,aProcessos[i][1],aProcessos[i][2],.t.)  //restaura saldo restante
         ElseIf !aProcessos[i][3] .And. aProcessos[i][4] // se apenas houverem parcelas não liquidadas
            Af200CtrRen(4,aProcessos[i][1],aProcessos[i][2],.t.)  //abate saldo restante, que foi restaurado anteriormente.
         EndIf
      Next
   EndIf

   //cFilAnt:= xcFil
   //Alcir - 26-08-04
   If EasyEntryPoint("EECAF300")
      ExecBlock("EECAF300",.F.,.F.,{"INC_ADIANTAMENTO"})
   Endif

   // GFC - INICIO - 22/01/2005
   If lLiq .and. lIntFina .and. lFinanciamento .and. FAF2GetProv()
      TMP->(DBGOTOP())
      DO WHILE ! TMP->(EOF())
         If lMultiFil
            cFilAnt:=Left(TMP->EEQ_FILORI,FWSizeFilial())  //TRP - 12/09/2012 - Utilizar a função FWSizeFilial() para retornar o tamanho da filial.
         EndIf
         EEC->(DBSEEK(XFILIAL("EEC")+TMP->EEQ_PREEMB))
         cPREEMB := TMP->EEQ_PREEMB
         DO WHILE ! TMP->(EOF()) .AND. TMP->EEQ_PREEMB = cPREEMB
            IF (EEQ->(DBSEEK(XFILIAL("EEQ")+TMP->(EEQ_PREEMB+EEQ_PARC))))
               EEQ->(RECLOCK("EEQ",.F.))
               AVREPLACE("TMP","EEQ")
               If !Empty(EEQ->EEQ_PGT) .and. EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,If(EEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+EEQ->EEQ_NRINVO+If(!lParFin .Or. Empty(EEQ->EEQ_PARFIN), EEQ->EEQ_PARC, EEQ->EEQ_PARFIN)+EV_EMBARQUE)) //HVR 08/03/2006 - Incluido no indice o campo EF3_TPMODU
                  Do While !EF3->(EOF()) .and. EF3->EF3_FILIAL+If(lEFFTpMod,EF3->EF3_TPMODU,"")==xFilial("EF3")+If(lEFFTpMod,If(EEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"") .and. EF3->EF3_INVOIC == EEQ->EEQ_NRINVO .and.;  //HVR 08/03/2006 - Incluido no indice o campo EF3_TPMODU
                           EF3->EF3_PARC == If(!lParFin .Or. Empty(EEQ->EEQ_PARFIN), EEQ->EEQ_PARC, EEQ->EEQ_PARFIN) .and. EF3->EF3_CODEVE == EV_EMBARQUE
                     nx += 1
                     EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3->EF3_CONTRA+If(lTemChave,EF3->EF3_BAN_FI+EF3->EF3_PRACA+If(lEFFTpMod,EF3->EF3_SEQCNT,""),"")))  //HVR 08/03/2006 - Incluido no indice o campo EF3_TPMODU e EF3_SEQCNT
                     nEF3Rec := EF3->(RecNo())
                     If EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,If(EEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+EEQ->EEQ_NRINVO+EEQ->EEQ_PARC+EV_LIQ_PRC)) .or.;        //GFC - 22/01/05 //HVR 08/03/2006 - Incluido no indice o campo EF3_TPMODU
                        EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,If(EEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+EEQ->EEQ_NRINVO+EEQ->EEQ_PARC+EV_LIQ_PRC_FC))  //HVR 08/03/2006 - Incluido no indice o campo EF3_TPMODU
                        FAF2EstLiq(EF3->EF3_CONTRA,EF3->EF3_SEQ,If(lTemChave,EF3->EF3_BAN_FI,),If(lTemChave,EF3->EF3_PRACA,),.F.,If(lEFFTpMod,EF3->EF3_SEQCNT,"")) //GFC - 22/01/05   //HVR 08/03/2006 - Incluido no indice o campo EF3_SEQCNT
                     EndIf
                     EF3->(dbGoTo(nEF3Rec))
                     nTxAux := EEQ->EEQ_EQVL / EEQ->EEQ_VL

                     cMod := IIF(lEFFTpMod,EF1->EF1_TPMODU,"E")

                     EX400Liquida(EF1->EF1_CONTRA,EEQ->EEQ_NRINVO,;
                                  If(lParFin .and. !Empty(EEQ->EEQ_PARFIN), EEQ->EEQ_PARFIN, EEQ->EEQ_PARC),EEQ->EEQ_PREEMB,;
                                  EF3->EF3_VL_MOE,EEC->EEC_MOEDA,EF1->EF1_MOEDA,"EF1","EF3","FFC",EEQ->EEQ_TX,EEQ->&(cCpoDt),If(!Empty(EEQ->EEQ_DTNEGO),EEQ->EEQ_DTNEGO,EEQ->EEQ_PGT),EEQ->EEQ_PGT,If(lMultiFil,xFilial("EEQ"),Nil),;
                                  aGetProv[nx,4],aGetProv[nx,6],aGetProv[nx,5],aGetProv[nx,7],If(lTemChave,EF1->EF1_BAN_FI,),If(lTemChave,EEQ->EEQ_AGEN,),If(lTemChave,EEQ->EEQ_NCON,),If(lTemChave,EF1->EF1_PRACA,),,;
                                  EF3->EF3_VL_MOE * nTxAux, , EEQ->EEQ_NROP)    //GFC - 22/01/05
                     EF3->(dbGoTo(nEF3Rec))
                     EF3->(dbSkip())
                  EndDo
               EndIf
            EndIf

            If EasyEntryPoint("EECAF300")
               ExecBlock("EECAF300",.F.,.F.,{"PE_AF300C_FIN"})
            Endif

            TMP->(DBSKIP())
         EndDo
      EndDo
      cFilAnt:= xcFil
   EndIf

   // GFC - FIM
   lLiq    := .F.

   // ** By JBJ - 17/01/03 - Grava as cotações de cambio
   If lCotaCambio
      Work_Cot->(DbGoTop())
      Do While Work_Cot->(!Eof())
         If Work_Cot->RECNO == 0
            EXG->(RecLock("EXG",.t.))
            EXG->EXG_FILIAL := xFilial("EXG")
            AvReplace("Work_Cot","EXG")
         Else
            EXG->(dbGoTo(Work_Cot->RECNO))
            EXG->(RecLock("EXG",.f.))
            AvReplace("Work_Cot","EXG")
         EndIf
         If EXG->(IsLocked())
            EXG->(MSUnlock())
         EndIf
         Work_Cot->(DbSkip())
      EndDo

      For i:=1 To Len(aDelCotCam)
         EXG->(DbGoTo(aDelCotCam[i]))
         If EXG->(RecLock("EXG",.f.))
            EXG->(DbDelete())
            EXG->(MSUnlock())
         EndIf
      Next
   EndIf

   If lIntFina .and. lFinanciamento
      EF3->(dbSetOrder(1))
   EndIf

   //TRP- 15/01/2007 - 17:00
   If EasyEntryPoint("EECAF300")
      ExecBlock("EECAF300",.F.,.F.,{"PE_FIM_AF300C"})
   Endif
EndIf

Return lRet

*--------------------------------------------------------------------
STATIC FUNCTION AF300TODOS()
// MARCA TODOS NA INCLUSAO DE FFC
LOCAL lTODOS := .T. //IF(EMPTY(TMP->EEQ_FLAG),.T.,.F.)
Local nRecno := TMP->(Recno())

TMP->(DBGOTOP())
TMP->(DBEVAL( { ||  If(lTodos .and. !EMPTY(TMP->EEQ_FLAG) , lTodos := .F. , )  }  ))
TMP->(DBGOTOP())

nSaldo := 0
DO WHILE ! TMP->(EOF())
    if !EasyVerModal("TMP")
        If lTodos
            nSaldo += EEQ_VL
        Endif
        TMP->EEQ_FLAG := IF(lTODOS,cMARCA," ")
    Endif
    TMP->(DBSKIP())
ENDDO

TMP->(DBGOTO(nRecno))

oMSELECT:oBrowse:REFRESH()
SYSREFRESH()
RETURN(NIL)
*--------------------------------------------------------------------
STATIC FUNCTION AF300SAL(lP_MODO,lCotacao,lVisParc,lExecAuto)
// TELA DA BAIXA
LOCAL oDLG,Z,aPOS,Y,;
      bVALE     := {|| nBTOP := 1,iif(AF300VDT("TMP"),oDLG:End(),{|| oGet:oBrowse:Refesh(),nBTOP := 0 } ) },;
      bNAOVALE  := {|| nBTOP := 0},;
      bCANCEL   := {|| nBTOP := 0,oDLG:End()},;
      bOK       := IF(lP_MODO,{|| IF(AF300VAL(8),EVAL(bVALE),EVAL(bNAOVALE))},;
                              {|| nBTOP := 0,oDLG:End()}),;
      cALIAS    := SELECT(),;
      aBUTTONS  := {},;
      nBTOP     := 0,;
      lRET      := .F.
Local nRecWork := Tmp->(RecNo())
Local cPREEMB, nRecAux, lExitLoop:=.F. //** GFC
Local lMovExt := .F.

//** GFC - 30/06/05 - Se o parâmetro MV_MV_LIQPARC estiver ativado, não irá permitir liquidar a parcela caso a
//                    mesma não seja totalmente câmbio pronto ou totalmente vinculada a contrato de financiamento
Private aArrayEEQ:={}
Private lAF300 := .T.  // By JPP - 21/02/2006 - 14:37

If lIntFina .and. lFinanciamento .and. lP_MODO .and. EasyGParam("MV_LIQPARC",,.F.)
   EF3->(dbSetOrder(3))
   nRecAux := TMP->(RecNo())
   TMP->(DBGOTOP())
   DO WHILE ! TMP->(EOF())
      cPREEMB := TMP->EEQ_PREEMB
      aArrayEEQ := {}
      nSeqAux:=1
      EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,If(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),"")+TMP->EEQ_NRINVO+If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN)+EV_EMBARQUE)) //HVR 08/03/2006 - Incluido no indice o campo EF3_TPMODU
      GrvArrayEEQ()
      If !VerLiqPar(.T.)
         lExitLoop := .T.
         Exit
      EndIf
      TMP->(dbSkip())
   EndDo
   TMP->(dbGoTo(nRecAux))
   EF3->(dbSetOrder(1))
   If lExitLoop
      Return .F.
   EndIf
EndIf
//**

Private aENCHOICE := {"EEQ_DTNEGO",/*"EEQ_DECAM",*/"EEQ_NROP","EEQ_PGT"   ,"EEQ_TX",;
                      "EEQ_EQVL","EEQ_BANC"  ,"EEQ_AGEN" ,"EEQ_NCON","EEQ_NOMEBC","EEQ_RFBC",;
                      "EEQ_CORR"},;
        aALTERA   := IF(lP_MODO,{"EEQ_EQVL","EEQ_DTNEGO",/*"EEQ_DECAM",*/"EEQ_NROP","EEQ_PGT" ,"EEQ_TX",;
                                 "EEQ_BANC"  ,"EEQ_AGEN" ,"EEQ_NCON","EEQ_NOMEBC","EEQ_RFBC",;
                                 "EEQ_CORR",},{})

If !lIntFina .and. !lFinanciamento
   aAdd(aEnchoice,"EEQ_VLCOR")
   aAdd(aEnchoice,"EEQ_JRAA")
   aAdd(aEnchoice,"EEQ_ADIA")
   aAdd(aEnchoice,"EEQ_RESP")
   aAdd(aEnchoice,"EEQ_CTDC")
   aAdd(aEnchoice,"EEQ_DTCC")
   If lP_MODO
      aAdd(aAltera,"EEQ_VLCOR")
      aAdd(aAltera,"EEQ_JRAA")
      aAdd(aAltera,"EEQ_ADIA")
      aAdd(aAltera,"EEQ_RESP")
      aAdd(aAltera,"EEQ_CTDC")
      aAdd(aAltera,"EEQ_DTCC")
   EndIf
EndIf

/* JPM - 11/12/2009 - a ordem de pagamento será preenchida por parcela.
//** AAF 04/03/08 - Numero da Ordem de Pagamento
If EECFlags("CAMBIO_EXT")
   aAdd(aENCHOICE,"EEQ_NROPAG")
   If lP_MODO
      aAdd(aAltera,"EEQ_NROPAG")
   EndIf
EndIf
//**
*/

PRIVATE aTELA[0,0],aGETS[0],nTOTFFC := 0,;
      aHEADER   := {},;
      aAlter	:= {},;
      aROTINA   := {{"","",0,3},{"","",0,4}},;
      lSOLICITA := lCONTRATA := lALTERA := lP_MODO,;
      aCAMPOS   := ARRAY(EEQ->(FCOUNT())),;
      nUSADO    := 0,;
      lINVERTE := .F.,;
      lREFRESH := .T.

Default lCotacao := .f.
Default lVisParc := .f.

/* AAF 04/03/08 - Retirada validação pois a liquidação pode ser realizada manualmente por lotes.

//*** RMD - 23/11/07 - Nova legislação de câmbio
If EECFlags("CAMBIO_EXT") .And. lP_MODO
   If TMP->EEQ_CONTMV $ cSim
      MsgInfo("Não é possível efetuar a liquidação porque a FFC controla movimentações no exterior.", "Atenção")
      Return .F.
   EndIf
EndIf
//***

*/

Aadd(aHeader,{ "Importador",            "WK_IMPORT",    "",                     28,                     0,                    "","",    "C"                   } )
Aadd(aHeader,{ AVSX3("EEQ_PREEMB",5),	"EEQ_PREEMB",	AVSX3("EEQ_PREEMB",6),	AVSX3("EEQ_PREEMB",3),	AVSX3("EEQ_PREEMB",4),"","",	AVSX3("EEQ_PREEMB",2) } )

/* by jbj - 22/06/04 10:55 - Verifica se o campo EEQ_NRINVO
                             existe na base de dados.*/
If lNrInvo
   Aadd(aHeader,{AvSx3("EEQ_NRINVO",5),"EEQ_NRINVO",AvSx3("EEQ_NRINVO",6),AvSx3("EEQ_NRINVO",3),AvSx3("EEQ_NRINVO",4),"","",AvSx3("EEQ_NRINVO",2)})
EndIf
Aadd(aHeader,{ AVSX3("EEQ_PARC",  5),	"EEQ_PARC",		AVSX3("EEQ_PARC",  6),	AVSX3("EEQ_PARC",  3),	AVSX3("EEQ_PARC",  4),"","",	AVSX3("EEQ_PARC",  2) } )
Aadd(aHeader,{ AVSX3("EEQ_DTCE",  5),	"EEQ_DTCE",		AVSX3("EEQ_DTCE",  6),  AVSX3("EEQ_DTCE",  3),	AVSX3("EEQ_DTCE",  4),"","",	AVSX3("EEQ_DTCE",  2) } )
Aadd(aHeader,{ AVSX3("EEQ_SOL",   5),   "EEQ_SOL",      AVSX3("EEQ_SOL",   6),  AVSX3("EEQ_SOL",   3),  AVSX3("EEQ_SOL",   4),"","",	AVSX3("EEQ_SOL",   2) } )

// ** JPM 11/12/2009 - nova leg cambial
If EECFlags("CAMBIO_EXT")
   Aadd(aHeader,{ AVSX3("EEQ_NROPAG",   5),   "EEQ_NROPAG",      AVSX3("EEQ_NROPAG",   6),  AVSX3("EEQ_NROPAG",   3),  AVSX3("EEQ_NROPAG",   4),"","",	AVSX3("EEQ_NROPAG",   2) } )
EndIf

Aadd(aHeader,{ AVSX3("EEQ_VCT",   5),   "EEQ_VCT",		AVSX3("EEQ_VCT",   6),	AVSX3("EEQ_VCT",   3),	AVSX3("EEQ_VCT",   4),"","",	AVSX3("EEQ_VCT",   2) } )
Aadd(aHeader,{ AVSX3("EEQ_VL",    5),	"EEQ_VL",		AVSX3("EEQ_VL",    6),  AVSX3("EEQ_VL",    3),  AVSX3("EEQ_VL",    4),"","",	AVSX3("EEQ_VL",    2) } )
Aadd(aHeader,{ AVSX3("EEQ_VLFCAM",5),	"EEQ_VLFCAM",	AVSX3("EEQ_VLFCAM",6),  AVSX3("EEQ_VLFCAM",3),  AVSX3("EEQ_VLFCAM",4),"","",	AVSX3("EEQ_VLFCAM",2) } )  //NCF - 11/02/2011

If EECFlags("FRESEGCOM")
   If lOkEvent
      Aadd(aHeader,{AvSx3("EEQ_EVENT" ,5),"EEQ_EVENT" ,AvSx3("EEQ_EVENT" ,6),AvSx3("EEQ_EVENT" ,3),AvSx3("EEQ_EVENT" ,4),"","",AvSx3("EEQ_EVENT" ,2)})
   EndIf
   Aadd(aHeader,{AvSx3("EEQ_MOEDA" ,5),"EEQ_MOEDA" ,AvSx3("EEQ_MOEDA" ,6),AvSx3("EEQ_MOEDA" ,3),AvSx3("EEQ_MOEDA" ,4),"","",AvSx3("EEQ_MOEDA" ,2)})
   Aadd(aHeader,{AvSx3("EEQ_PARI " ,5),"EEQ_PARI"  ,AvSx3("EEQ_PARI " ,6),AvSx3("EEQ_PARI " ,3),AvSx3("EEQ_PARI " ,4),"","",AvSx3("EEQ_PARI " ,2)})
   Aadd(aHeader,{AvSx3("EEQ_CODEMP",5),"EEQ_CODEMP",AvSx3("EEQ_CODEMP",6),AvSx3("EEQ_CODEMP",3),AvSx3("EEQ_CODEMP",4),"","",AvSx3("EEQ_CODEMP",2)})
   Aadd(aHeader,{AvSx3("EEQ_FORN"  ,5),"EEQ_FORN"  ,AvSx3("EEQ_FORN"  ,6),AvSx3("EEQ_FORN"  ,3),AvSx3("EEQ_FORN"  ,4),"","",AvSx3("EEQ_FORN"  ,2)})
   Aadd(aHeader,{AvSx3("EEQ_FOLOJA",5),"EEQ_FOLOJA",AvSx3("EEQ_FOLOJA",6),AvSx3("EEQ_FOLOJA",3),AvSx3("EEQ_FOLOJA",4),"","",AvSx3("EEQ_FOLOJA",2)})
   Aadd(aHeader,{AvSx3("EEQ_TIPO " ,5),"EEQ_TIPO"  ,AvSx3("EEQ_TIPO " ,6),AvSx3("EEQ_TIPO " ,3),AvSx3("EEQ_TIPO " ,4),"","",AvSx3("EEQ_TIPO " ,2)})

   If EEQ->( FieldPos("EEQ_TP_CON") ) > 0
      aAdd(aHeader,{AvSx3("EEQ_TP_CON",5),"EEQ_TP_CON"  ,AvSx3("EEQ_TP_CON" ,6),AvSx3("EEQ_TP_CON" ,3),AvSx3("EEQ_TP_CON" ,4),"","",AvSx3("EEQ_TP_CON" ,2)})
   EndIf

EndIf

//** AAF 04/03/08 - Crédito no exterior somente por baixa gerencial.
If EECFlags("CAMBIO_EXT") .And. !AVFLAGS("CAMBIO_EXP_MOV_EXT")
   Aadd(aAlter,"EEQ_NROPAG") // JPM - 11/12/2009 - alteração da ordem de pagamento por parcela
Else
   Aadd(aAlter,"EEQ_DTCE")
EndIf
//**

Aadd(aAlter,"EEQ_SOL")

If lVisParc
   If aScan(aEnchoice,{|x| Upper(x) == "EEQ_VL"}) = 0
      aAdd(aEnchoice,"EEQ_VL")
   EndIf
   If aScan(aEnchoice,{|x| Upper(x) == "EEQ_VLFCAM"}) = 0    //NCF - 11/04/2011
      aAdd(aEnchoice,"EEQ_VLFCAM")
   EndIf
   If aScan(aEnchoice,{|x| Upper(x) == "EEQ_DTCE"}) = 0
      Aadd(aEnchoice,"EEQ_DTCE")
   Endif
   If aScan(aEnchoice,{|x| Upper(x) == "EEQ_SOL"}) = 0
      Aadd(aEnchoice,"EEQ_SOL")
   Endif
   If aScan(aEnchoice,{|x| Upper(x) == "EEQ_NROPAG"}) = 0
      Aadd(aEnchoice,"EEQ_NROPAG")
   Endif
EndIf

DBSELECTAREA("TMP")
FOR Z := 1 TO TMP->(FCOUNT())
    M->&(TMP->(FIELDNAME(Z))) := TMP->(FIELDGET(Z))
NEXT

//M->EEQ_RFBC := SPACE(20) //ASK   // TLM 20/02/2008
If lIntFina .and. lFinanciamento
   EF3->(dbSetOrder(3))
   EF1->(dbSetOrder(1))
   If EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,If(M->EEQ_TP_CON $ ("2/4"),"I","E"),"")+M->EEQ_NRINVO+If(!lParFin .Or. Empty(M->EEQ_PARFIN),M->EEQ_PARC,M->EEQ_PARFIN))) //HVR 08/03/2006 - Incluido no indice o campo EF3_TPMODU
      If EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3->EF3_CONTRA+If(lTemChave,EF3->EF3_BAN_FI+EF3->EF3_PRACA+If(lEFFTpMod,EF3->EF3_SEQCNT,""),""))) //HVR 08/03/2006 - Incluido no indice o campo EF3_TPMODU e EF3_SEQCNT
         M->EEQ_NROP  := EF1->EF1_CONTRA
         If lTemChave .and. Empty(M->EEQ_BANC)
            M->EEQ_BANC  := EF1->EF1_BAN_FI
            SA6->(dbSeek(xFilial("SA6")+EF1->EF1_BAN_FI))
            M->EEQ_AGEN  := SA6->A6_AGENCIA
            M->EEQ_NCON  := SA6->A6_NUMCON
            M->EEQ_NOMEBC:= SA6->A6_NOME
         EndIF
      Endif
   EndIf
Endif

// ** By  JBJ - 17/01/03 - Cotacao de taxas para fechamento de FFC.
If lCotacao
   M->EEQ_TX    := Work_Cot->EXG_TX
   M->EEQ_BANC  := Work_Cot->EXG_BANC
   M->EEQ_AGEN  := Work_Cot->EXG_AGEN
   M->EEQ_NCON  := Work_Cot->EXG_NCON
   M->EEQ_NOMEBC:= Work_Cot->EXG_NOMEBC
   M->EEQ_CORR  := Work_Cot->EXG_CORR
   M->EEQ_RFBC  := Work_Cot->EXG_RFBC
   M->EEQ_VLCOR := Work_Cot->EXG_VLCOR
EndIf

// SERVE P/ FUNCIONAR A TECLA F3 DO CAMPO "EMITIDO POR"
// POSICIONA NO PRIMEIRO PROCESSO
EEC->(DBSETORDER(1))
EEC->(DBSEEK(Left(TMP->EEQ_FILORI,FWSizeFilial())+TMP->EEQ_PREEMB)) //TRP - 12/09/2012 - Utilizar a função FWSizeFilial() para retornar o tamanho da filial.
DBSELECTAREA("EEC")
FOR Z := 1 TO EEC->(FCOUNT())
    M->&(EEC->(FIELDNAME(Z))) := EEC->(FIELDGET(Z))
NEXT

// CALCULA O TOTAL DO FFC
TMP->(DBGOTOP())
DO WHILE ! TMP->(EOF())
   nTOTFFC := nTOTFFC+TMP->EEQ_VLFCAM //TMP->EEQ_VL comentado por wfs

   If EasyVerModal("TMP") //TMP->(FieldPos("EEQ_MODAL")) > 0 .And. TMP->EEQ_MODAL == "2"
      lMovExt := .T.
      M->EEQ_BCOEXT  := TMP->EEQ_BCOEXT
      M->EEQ_AGCEXT  := TMP->EEQ_AGCEXT
      M->EEQ_CNTEXT  := TMP->EEQ_CNTEXT
   Else
      M->EEQ_BANC  := TMP->EEQ_BANC
      M->EEQ_AGEN  := TMP->EEQ_AGEN
      M->EEQ_NCON  := TMP->EEQ_NCON
      M->EEQ_NOMEBC:= TMP->EEQ_NOMEBC
   EndIf

   TMP->(DBSKIP())
ENDDO

If EasyEntryPoint("EECAF300")
   ExecBlock("EECAF300",.F.,.F.,{"BAIXA_FFC_CARREGA"})
Endif

If lMovExt .And. EEQ->(FieldPos("EEQ_MODAL")) > 0  .And. EEQ->(FieldPos('EEQ_BCOEXT')) > 0 .And. EEQ->(FieldPos('EEQ_AGCEXT')) > 0 ;
   .And. EEQ->(FieldPos('EEQ_CNTEXT')) > 0
   //aAdd(aENCHOICE,"EEQ_MODAL")
   //aAdd(aALTERA,"EEQ_MODAL")
   aAdd(aENCHOICE,'EEQ_BCOEXT')
   aAdd(aENCHOICE,'EEQ_AGCEXT')
   aAdd(aENCHOICE,'EEQ_CNTEXT')
   aAdd(aALTERA,'EEQ_BCOEXT')
   aAdd(aALTERA,'EEQ_AGCEXT')
   aAdd(aALTERA,'EEQ_CNTEXT')
EndIf

If AVFLAGS("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP")
   aAdd(aENCHOICE,'EEQ_ACRESC')
   aAdd(aENCHOICE,'EEQ_DECRES')
EndIf

//OAP - Inclusão dos campos criados pelo usuário, assim os mesmos poderão ser alteraveis quando chamados.
aHeader:= AddCpoUser(aHeader,"EEQ","4")
aALTER := AddCpoUser(aAlter,"EEQ","1")
aAdd(aENCHOICE,"NOUSER")

If Type("aDadosEAI") <> "A"
   aDadosEAI:= {}
EndIf

Do While .T.

   DBSELECTAREA("TMP")
   If Valtype(lExecAuto) == "U"
      DEFINE MSDIALOG oDlg TITLE STR0022 FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL //"Manutenção de FFC - Baixa"

         If .not. lVisParc
            aPOS := POSDLGUp(oDLG)
            If AScan(aButtons,{|x| x[1]=="S4WB014A" .And. x[3]==STR0066}) == 0 // PLB 11/05/06 - Verifica se ja incluiu botao
               Aadd(aButtons,{"S4WB014A",{|| AF300GrvDt("TMP"), oGet:oBrowse:Refresh() }, STR0066, STR0098 })   // "Preenche todas as data automaticamente" # "Datas"
            EndIf
         Else
            aPos := POSDLG(oDLG)
         Endif

         ENCHOICE("EEQ",RECNO(),1,4,,,aENCHOICE,aPOS,aALTERA,3)

         if .not. lVisParc
	        aPos := POSDLGDOWN(oDLG)
            TMP->(oGet:=MsGetDb():New( aPos[1], aPos[2], aPos[3]-8, aPos[4], 2, , , ,.f., aAlter, , .t.,,"TMP") )  // By JPP - 13/10/2006 - 17:20 - A posição final da MsGetDb deve ser diminuida 8 posições para ser exibida a barra de rolagem em ambiente MDI.
            oGET:oBROWSE:BADD := {||.F.}
	     Endif

      ACTIVATE MSDIALOG oDlg ON INIT ENCHOICEBAR(oDLG,bOK,bCANCEL,,aBUTTONS)
   Else
      If Len(aDadosEAI) > 0
         M->EEQ_DTNEGO := aDadosEAI[aScan(aDadosEAI,{|X| AllTrim(Upper(X[1])) == "EEQ_DTNEGO" })][2]
         M->EEQ_PGT := aDadosEAI[aScan(aDadosEAI,{|X| AllTrim(Upper(X[1])) == "EEQ_PGT" })][2]
         M->EEQ_TX := aDadosEAI[aScan(aDadosEAI,{|X| AllTrim(Upper(X[1])) == "EEQ_TX" })][2]
         M->EEQ_NROP := aDadosEAI[aScan(aDadosEAI,{|X| AllTrim(Upper(X[1])) == "EEQ_NROP" })][2]
         M->EEQ_BANC := aDadosEAI[aScan(aDadosEAI,{|X| AllTrim(Upper(X[1])) == "EEQ_BANC" })][2]
         M->EEQ_AGEN := aDadosEAI[aScan(aDadosEAI,{|X| AllTrim(Upper(X[1])) == "EEQ_AGEN" })][2]
         M->EEQ_NCON := aDadosEAI[aScan(aDadosEAI,{|X| AllTrim(Upper(X[1])) == "EEQ_NCON" })][2]
         M->EEQ_NOMEBC := aDadosEAI[aScan(aDadosEAI,{|X| AllTrim(Upper(X[1])) == "EEQ_NOMEBC" })][2]
         M->EEQ_DECAM := aDadosEAI[aScan(aDadosEAI,{|X| AllTrim(Upper(X[1])) == "EEQ_DECAM" })][2]
         M->EEQ_RFBC := aDadosEAI[aScan(aDadosEAI,{|X| AllTrim(Upper(X[1])) == "EEQ_RFBC" })][2]
         M->EEQ_CORR := aDadosEAI[aScan(aDadosEAI,{|X| AllTrim(Upper(X[1])) == "EEQ_CORR" })][2]
      EndIf
      nBTOP := 1
   EndIf

   IF nBTOP = 1 .And. !lVisParc
      lLoop := .F.
      If EasyEntryPoint("EECAF300")
         ExecBlock("EECAF300",.F.,.F.,{"LOOP_BAIXA_FFC"})
      Endif
      If lLoop
         Loop
      EndIf
      TMP->(DBGOTOP())
      DO WHILE ! TMP->(EOF())
         //** GFC - 27/01/06
         If lIntFina .and. lFinanciamento
            lLoop := .F.
            EF3->(dbSetOrder(3))
            If EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,If(M->EEQ_TP_CON $ ("2/4"),"I","E"),"")+M->EEQ_NRINVO+If(!lParFin .Or. Empty(M->EEQ_PARFIN),M->EEQ_PARC,M->EEQ_PARFIN)+EV_EMBARQUE)) //HVR 08/03/2006 - Incluido no indice o campo EF3_TPMODU
               Do While !EF3->(EOF()) .and. xFilial("EF3")+If(lEFFTpMod,If(M->EEQ_TP_CON $ ("2/4"),"I","E"),"") ==EF3->EF3_FILIAL+If(lEFFTpMod,EF3->EF3_TPMODU,"") .and. EF3->EF3_INVOIC==M->EEQ_NRINVO .and.;  //HVR 08/03/2006 - Incluido no indice o campo EF3_TPMODU
               EF3->EF3_PARC==If(!lParFin .Or. Empty(M->EEQ_PARFIN), M->EEQ_PARC, M->EEQ_PARFIN) .and.;
               EF3->EF3_CODEVE == EV_EMBARQUE
                  If M->EEQ_PGT < EF3->EF3_DT_EVE
                     MsgInfo(STR0079+" ("+DtoC(EF3->EF3_DT_EVE)+"). "+STR0080+Alltrim(EF3->EF3_INVOIC)+"/"+EF3->EF3_PARC) //"A Data de Liquidação não pode ser menor que a Data de Vinculação" # "Invoice/Parc: "
                     lLoop := .T.
                     Exit
                  EndIf
                  EF3->(dbSkip())
               EndDo
            EndIf
            If lLoop
               Exit
            EndIf
         EndIf
         //**

        //OAP - Gravando alterações realizadas nos campos criados peli usuário
        /*SX3->(dbSeek("EEQ"))
			While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "EEQ"
			   If Alltrim(SX3->X3_PROPRI) == "U" .AND. X3Uso(SX3->X3_USADO)
                  TMP->&(SX3->X3_CAMPO) := M->&(SX3->X3_CAMPO)
   			   EndIf
               SX3->(dbSkip())
            EndDo*/

         TMP->EEQ_DTNEGO := M->EEQ_DTNEGO ; TMP->EEQ_DECAM  := M->EEQ_DECAM
         TMP->EEQ_NROP   := M->EEQ_NROP   ; TMP->EEQ_PGT    := M->EEQ_PGT
         TMP->EEQ_TX     := M->EEQ_TX     ; TMP->EEQ_EQVL   := TMP->EEQ_VL*M->EEQ_TX
         //TMP->EEQ_BANC   := M->EEQ_BANC   ; TMP->EEQ_AGEN   := M->EEQ_AGEN
         //TMP->EEQ_NCON   := M->EEQ_NCON   ; TMP->EEQ_NOMEBC := M->EEQ_NOMEBC
         //TMP->EEQ_RFBC   := iif(empty(TMP->EEQ_RFBC),M->EEQ_RFBC,)//ASK 07/02/2008 - Se a parcela possuir referencia preenchida, não sobrepõe
         TMP->EEQ_RFBC   := iif(empty(M->EEQ_RFBC),TMP->EEQ_RFBC,M->EEQ_RFBC) // TLM 04/02/2008 - Se a parcela foi alterada grava com alteração, caso contrario, mantém o conteúdo original.
         TMP->EEQ_CORR   := M->EEQ_CORR
         //TMP->EEQ_DTCE   := M->EEQ_DTCE   //; TMP->EEQ_EQVL   := M->EEQ_EQVL   // By JPP - 31/05/2005 - 17:35 - Esta instrução grava incorretamente o valor em reais de cada parcela do FFC.
         If !lIntFina .and. !lFinanciamento
            TMP->EEQ_VLCOR  := M->EEQ_VLCOR
            TMP->EEQ_JRAA   := M->EEQ_JRAA
            TMP->EEQ_ADIA   := M->EEQ_ADIA
            TMP->EEQ_RESP   := M->EEQ_RESP
            TMP->EEQ_CTDC   := M->EEQ_CTDC
            TMP->EEQ_DTCC   := M->EEQ_DTCC
         EndIf


         If EasyVerModal("TMP") .And. TMP->(FieldPos('EEQ_BCOEXT')) > 0 .And. TMP->(FieldPos('EEQ_AGCEXT')) > 0 .And. TMP->(FieldPos('EEQ_CNTEXT')) > 0
            //TMP->(FieldPos("EEQ_MODAL")) > 0 .And. TMP->(FieldPos('EEQ_BCOEXT')) > 0 .And. TMP->(FieldPos('EEQ_AGCEXT')) > 0;
            //.And. TMP->(FieldPos('EEQ_CNTEXT')) > 0 .And. TMP->EEQ_MODAL == "2"
            TMP->EEQ_BCOEXT := M->EEQ_BCOEXT
            TMP->EEQ_AGCEXT := M->EEQ_AGCEXT
            TMP->EEQ_CNTEXT := M->EEQ_CNTEXT
         Else
            TMP->EEQ_BANC   := M->EEQ_BANC
            TMP->EEQ_AGEN   := M->EEQ_AGEN
            TMP->EEQ_NCON   := M->EEQ_NCON
            TMP->EEQ_NOMEBC := M->EEQ_NOMEBC
         EndIf

         /* JPM - 11/12/2009 - a ordem de pagamento é preenchida por parcela
         //** AAF 04/03/08 - Gravação do numero da Ordem de Pagamento
         If EECFlags("CAMBIO_EXT")
            TMP->EEQ_NROPAG := M->EEQ_NROPAG
         EndIf
         //**
         */

         If EasyEntryPoint("EECAF300")
            ExecBlock("EECAF300",.F.,.F.,{"BAIXA_FFC_GRAVA"})
         Endif
         TMP->(DBSKIP())
      ENDDO

      //** GFC - 27/01/05
      If lLoop
         aGets := {}
         aTela := {}
         Loop
      EndIf
      //**

      lRET := .T.
   ENDIF
   Exit
EndDo

Tmp->(DbGoTo(nRecWork))
DBSELECTAREA(cALIAS)

If Valtype(lExecAuto) == "U"
   oMSELECT:oBROWSE:REFRESH()
EndIf

RETURN(lRET)


/*
Funcao      : AF300ESTB()
Parametros  :
Retorno     :
Objetivos   :
Autor       :
Data/Hora   :
Revisão     :
Obs.        :
*/

FUNCTION AF300ESTB(lP_FFC,lSemMsg)
Local lRet := .T.

If !InTransaction()
   Begin Transaction
      If !(lRet := AF300Estorno(lP_FFC,lSemMsg))
         //MsgInfo(STR0101,STR0036)  // "Impossibilidade de integração com o módulo Financeiro. Verifique o Log Viewer."
         ELinkRollBackTran()
      EndIf
   End Transaction
   ELinkClearID()

Else
   If !(lRet := AF300Estorno(lP_FFC,lSemMsg))
      //MsgInfo(STR0101,STR0036)  // "Impossibilidade de integração com o módulo Financeiro. Verifique o Log Viewer."
      ELinkRollBackTran()
   EndIf
EndIf
If !lRet
    EasyElinkError("FIN", !(IsMemVar("lEaiExecAut") .And. lEaiExecAut))
EndIf
Return lRet

Static Function AF300Estorno(lP_FFC,lSemMsg)
// ESTORNO DA BAIXA
Local aOrdEEQ := SaveOrd("EEQ")
LOCAL lRet := .T., aEstLiq:={}, i, nx
Local nRecNoTmp
Local aEmbarques:= {}
Local cSeek:= ""
Local lMovExt := .F.
Local lCpoProc := TMP->(FieldPos('EEQ_TPPROC')) > 0 .And. TMP->(FieldPos('EEQ_REGIST')) > 0 .And. EEQ->(FieldPos('EEQ_TPPROC')) > 0 .And. EEQ->(FieldPos('EEQ_REGIST')) > 0
Local cIntAction := ""
Local lExibMsg   := .T.
Local aOrdTMP
Private nSeqAux:=1 //GFC
Private lLoop := .F.
Private lEstBXG
Private nParcEst

Default lSemMsg := .f.

//RRC - 07/03/2013
If IsInCallStack("ESSRS400")
   cModulo := "ESS"
EndIf

If Type("lRollBack") <> "L"
   lRollBack := .F.
EndIf

If Type("lCallRS403") <> "L"
   lCallRS403:= .F.
EndIf

Begin Sequence
   lP_FFC := If(lP_FFC=Nil,.F.,lP_FFC)
   If lSemMsg .Or. MSGNOYES(STR0023+If(lP_FFC,STR0024,STR0025),STR0026) //"Confirma o Estorno "###"do FFC ?"###"da Baixa ?"###"Atenção"
      If !lSemMsg
         If ! lP_FFC .AND. ! Empty(TMP->EEQ_DTVC) .And. !lEstParVC
            MSGINFO(STR0028,STR0026) //"FFC Com Variação Cambial. Estorno Cancelado "###"Atenção"
            lRet:= .F.
            Break
         EndIf
      EndIf

      If lIntFina .and. lFinanciamento
         EF3->(dbSetOrder(3))
      EndIf

      If EasyEntryPoint("EECAF300")
         ExecBlock("EECAF300",.F.,.F.,{"PE_ESTB_INI"})
      Endif

      If EasyEntryPoint("EECAF300")
         ExecBlock("EECAF300",.F.,.F.,{"PE_ESTB_INI"})
      Endif

      TMP->(DBGOTOP())
      DO WHILE ! TMP->(EOF())
         lLoop := .F.

         // MPG - 12/11/2018 - para quando for multifilial considerar a filial do registro selecionado para ação
         if lMultiFil .and. !empty(TMP->EEQ_FILORI)
            cFilAnt := Left(TMP->EEQ_FILORI,FWSIZEFILIAL())
         endif
         
         //nRecNoTmp:= TMP->(RecNo())
         aOrdTMP := SaveOrd('TMP')      //NCF - Fecha a área da TMP para ser aberta posteriorente, já que pode ser utilizada pelo SIGACTB na integração com SIGAFIN

         If EasyEntryPoint("EECAF300")
            ExecBlock("EECAF300",.F.,.F.,{"PE_ESTB_LOOP"})
         Endif

         If Select('TMP') == 0
            AF300AbTMP('1')
            RestOrd(aOrdTMP,.T.)
         EndIf

         If lLoop
            TMP->(DbSkip())
            Loop
         EndIf

         If !lP_FFC .and. lIntFina .and. lFinanciamento
            EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,If(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),"")+TMP->EEQ_NRINVO+If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN)+EV_EMBARQUE))   //HVR 08/03/2006 - Incluido no indice o campo EF3_TPMODU
            aArrayEEQ := {}
            aEstLiq := {}
            GrvArrayEEQ()
            nOrdEF3 := EF3->(IndexOrd())
            For nx:=1 to Len(aArrayEEQ)
               If !Empty(aArrayEEQ[nx,5])
                  EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,If(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),"")+aArrayEEQ[nx,5]+iif(lTemChave,aArrayEEQ[nx,14]+aArrayEEQ[nx,15]+If(lEFFTpMod,aArrayEEQ[nx,22],""),""))) //HVR 08/03/2006 - Incluido no indice o campo EF3_TPMODU e EF3_SEQCNT
                  EF3->(dbSetOrder(1))
                  If EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,EF1->EF1_TPMODU,"")+aArrayEEQ[nx,5]+iif(lTemChave,aArrayEEQ[nx,14]+aArrayEEQ[nx,15]+If(lEFFTpMod,aArrayEEQ[nx,22],""),"")+EV_LIQ_PRC)) .or.; //HVR 08/03/2006 - Incluido no indice o campo EF3_TPMODU
                     (lPrePag .and. If(lEFFTpMod,EF1->EF1_CAMTRA == "1",EF1->EF1_TP_FIN $ ("02/03")) .and. EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,EF1->EF1_TPMODU,"")+aArrayEEQ[nx,5]+iif(lTemChave,aArrayEEQ[nx,14]+aArrayEEQ[nx,15],"")+iif(lEFFTpMod, aArrayEEQ[nx,22],"")+Left(EV_LIQ_JUR,2)))) //HVR 08/03/2006 - Incluido no indice o campo EF3_TPMODU
                     cSeq := ""
                     Do While EF3->(!Eof()) .And. EF3->EF3_FILIAL+If(lEFFTpMod,EF3->EF3_TPMODU,"") = xFilial("EF3")+If(lEFFTpMod,EF1->EF1_TPMODU,"") .And. aArrayEEQ[nx,5] = EF3->EF3_CONTRA ;  //HVR 08/03/2006 - Incluido no indice o campo EF3_TPMODU
                              .And. (EF3->EF3_CODEVE=EV_LIQ_PRC .or. (lPrePag .and. If(lEFFTpMod,EF1->EF1_CAMTRA == "1",EF1->EF1_TP_FIN $("02/03")) .and.;
                              Left(EF3->EF3_CODEVE,2)=Left(EV_LIQ_JUR,2))) .and.;
                        If(lTemChave,EF3->EF3_BAN_FI+EF3->EF3_PRACA+If(lEFFTpMod,EF3->EF3_SEQCNT,"")==aArrayEEQ[nx,14]+aArrayEEQ[nx,15]+If(lEFFTpMod,aArrayEEQ[nx,22],""),.T.)  //HVR 08/03/2006 - Incluido no indice o campo EF3_SEQCNT
                        If EF3->EF3_INVOIC == TMP->EEQ_NRINVO .and. EF3->EF3_PARC==IIF(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN)  //.and. EF3->EF3_VL_MOE = aArrayEEQ[nx,1]  // PLB 11/05/06
                           aAdd(aEstLiq,{EF3->EF3_CONTRA,EF3->EF3_SEQ,If(lTemChave,EF3->EF3_BAN_FI,),If(lTemChave,EF3->EF3_PRACA,),If(lEFFTpMod,EF3->EF3_SEQCNT,"")})  //HVR 08/03/2006 - Incluido no indice o campo EF3_SEQCNT
                        Endif
                        EF3->(DbSkip())
                     Enddo
                  EndIf
               EndIf
            Next nx
            EF3->(dbSetOrder(nOrdEF3))
            For i:=1 to Len(aEstLiq)
               FAF2EstLiq(aEstLiq[i,1],aEstLiq[i,2],aEstLiq[i,3],aEstLiq[i,4],.T.,aEstLiq[i,5])  //HVR 08/03/2006 - Incluido no indice o campo EF3_SEQCNT
            Next i
         EndIf

         // ** By JBJ - 19/05/03 - 15:40.
         If EasyEntryPoint("EECAF300")
            ExecBlock("EECAF300",.F.,.F.,{"PE_EST"})
         Endif

         dDataPgt := TMP->EEQ_PGT

         TMP->EEQ_PGT    := AVCTOD("")
         TMP->EEQ_EQVL   := 0          ; TMP->EEQ_TX     := 0

         IF lP_FFC
            TMP->EEQ_DTNEGO := AVCTOD("  /  /  ") // MPG - só deve apagar a data de negociação quando a FFC for estornada e não a liquidação da mesma.
            TMP->EEQ_FFC := ""
         ENDIF

         // ** RMD - 15/08/05
         If lIntFina .And. lFinanciamento
            nOrdEF3 := EF3->(IndexOrd())
            EF3->(dbSetOrder(3))
            If !EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,If(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),"")+TMP->EEQ_NRINVO+If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN)+"600"))   //HVR 08/03/2006 - Incluido no indice o campo EF3_TPMODU
               TMP->EEQ_NROP   := Space(20)
            EndIf
            EF3->(dbSetOrder(nOrdEF3))
         Else
            TMP->EEQ_NROP   := Space(20)
         EndIf

         If !lIntFina .and. !lFinanciamento
            TMP->EEQ_VLCOR  := 0
            TMP->EEQ_JRAA   := 0
            TMP->EEQ_ADIA   := 0
            TMP->EEQ_RESP   := SPACE(35)
            TMP->EEQ_CTDC   := SPACE(01)
            TMP->EEQ_DTCC   := AVCTOD("  /  /  ")
         EndIf

         //DFS - 19/10/10 - Inclusão de tratamento para estorno no financeiro
         If IsIntEnable("001")
            SE1->(DbSetOrder(1))
            SE2->(DbSetOrder(1))
            SE5->(DbSetOrder(7))
            EEQ->(DbSetOrder(2))
            If EEQ->(DbSeek(xFilial()+TMP->(EEQ_FFC+EEQ_PREEMB+EEQ_PARC)))
               EEC->(dbsetorder(1),DBSeek(xFilial() + EEQ->EEQ_PREEMB))
               lMovExt := .F.
               If EasyVerModal("EEQ") //EEQ->(FieldPos("EEQ_MODAL")) > 0 .And. EEQ->EEQ_MODAL == "2"
                  lMovExt := .T.
               EndIf

               cParcSE1 := If(EECFlags("TIT_PARCELAS"),EECGetFinParc(EEQ->EEQ_PARC),AvKey(" ", "E1_PARCELA"))  // GFP - 29/05/2013
               If IsReceita(TMP->EEQ_EVENT)

                  //WFS - 18/08/11
                  //Tratamento para considerar vinculação de adiantamento pós-embarque
                  //Obs.: não há tratamento de rollback na rotina
                  If EEQ->EEQ_TIPO == "A"
                     cSeek:= 'SE1->(DbSetOrder(1),DBSeek(xFilial()+"EEC"+AvKey(EEQ->EEQ_FINNUM, "E1_NUM")+AvKey(cParcSE1, "E1_PARCELA")+AvKey(TETpTitEEQ("EEQ"),"E1_TIPO")))'  // GFP - 29/05/2013    //NCF - 04/07/2019
                  ElseIf lCallRS403
                     cSeek:= 'SE1->(DbSetOrder(1),DbSeek(xFilial()+cModulo+AvKey(EEQ->EEQ_FINNUM, "E1_NUM")+AvKey(EECGetFinParc(EEQ->EEQ_PARC), "E1_PARCELA")+AvKey("NF","E1_TIPO")))'
                  Else
                     cSeek:= 'SE1->(DbSetOrder(1),DBSeek(xFilial()+"EEC"+AvKey(EEQ->EEQ_FINNUM, "E1_NUM")+AvKey(cParcSE1, "E1_PARCELA")+AvKey("NF","E1_TIPO")))'  // GFP - 29/05/2013
                  EndIf

                  If ((&cSeek) .And. AF201PosicSE5("SE1",SE1->E1_BAIXA)) .Or. !IsIntEnable("001") .Or. lCallRS403

                     If EEQ->EEQ_TIPO == "A"
                        If EasyGParam("MV_AVG0180",,.F.)
                           EEC->(DBSetOrder(1))
                           EEC->(DBSeek(xFilial() + EEQ->EEQ_PREEMB))
                           If !Empty(EEC->EEC_DTEMBA)
                              If !(lRet := AvStAction("009")) //Estorno do título de adiantamento no SigaFin
                                 lRollBack:= .T.
                                 Exit
                              EndIf
                           EndIf
                           If !(lRet := AvStAction("002")) //Exclusão do título de adiantamento no SigaFin
                              lRollBack:= .T.
                              Exit
                           EndIf

                           //Armazena quais são os processos para posterior alteração do título no financeiro
                           If !lRollBack .And. EEQ->EEQ_EVENT == "603"
                              AAdd(aEmbarques, EEQ->EEQ_PREEMB)
                           EndIf
                        EndIf

                     Else

                        If lCallRS403 // Chamada na funcao ESSRS403 - integração de serviço
                           cIntAction := "024"
                        Else
                           cIntAction := "009"
                        EndIf

                        If !lMovExt .And. !(lRet := AF300Action("009",aOrdTMP)) //Estorno de títulos a receber
                           lRollBack:= .T.
                           Exit
                        EndIf

                     Endif
                  EndIf
               Else
                  If !IsIntEnable("001") .Or. (SE2->(DbSeek(xFilial()+cModulo+TMP->EEQ_FINNUM)) .And. AF201PosicSE5("SE2")) .Or. lCallRS403//SE2->(DbSeek(xFilial()+"EEC"+TMP->EEQ_FINNUM)) .And. AF201PosicSE5("SE2")

                     If lCallRS403 // Chamada na funcao ESSRS403 - integração de serviço
                        cIntAction := "029"
                     Else
                        cIntAction := "014"
                     EndIf

                     If !lMovExt .And. !(lRet := AvStAction(cIntAction)) //Estorno de títulos a pagar
                        lRollBack:= .T.
                        Exit
                     EndIf
                  EndIf
               EndIf
            EndIf

         Else
            If IsReceita(TMP->EEQ_EVENT)
               If !Empty(TMP->EEQ_FINNUM) .And. !Empty(dDataPgt)
                  EEQ->(DbSetOrder(1)) //EEQ_FILIAL+EEQ_PREEMB+EEQ_PARC+EEQ_FASE
                  //NCF - 28/02/2014 - Considerar tratamento multifilial quando Acionada a manutenção de FFC de filial diferente da filial das cambiais inclusas na FFC
                  If EEQ->(DbSeek( If(  lMultifil, Left(TMP->EEQ_FILORI,FWSIZEFILIAL()), xFilial("EEQ")  ) +TMP->(EEQ_PREEMB+EEQ_PARC+EEQ_FASE)))
                     If !Empty(EEQ->EEQ_FINNUM)
                        If EEQ->EEQ_TIPO == "A"
                           If !Empty(EEQ->EEQ_SEQBX)
                              If !(lRet := AvStAction("009")) //Estorno de baixa do título de adiantamento
                                 lRollBack := .T.
                                 EXIT
                              EndIf
                              lAF212EsBxAuto := .T.
                           EndIf

                           If !(lRet := AvStAction("002")) //Estorno do título de  adiantamento
                              lRollBack := .T.
                              EXIT
                           EndIf
                              
                           //NCF - 15/05/2015
                           lAF212EsBxAuto := .F.

                        ElseIf !(lRet := AvStAction("009")) //Estorno de títulos a receber
                           lRollBack:= .T.
                           Exit
                        EndIf
                     Endif
                  EndIf
               Endif
            Else
               If !Empty(TMP->EEQ_FINNUM) .And. !Empty(dDataPgt)
                  EEQ->(DbSetOrder(1)) //EEQ_FILIAL+EEQ_PREEMB+EEQ_PARC+EEQ_FASE
                  //NCF - 28/02/2014 - Considerar tratamento multifilial quando Acionada a manutenção de FFC de filial diferente da filial das cambiais inclusas na FFC
                  If EEQ->(DbSeek( If(  lMultifil, Left(TMP->EEQ_FILORI,FWSIZEFILIAL()), xFilial("EEQ")  ) +TMP->(EEQ_PREEMB+EEQ_PARC+EEQ_FASE)))
                     If !Empty(EEQ->EEQ_FINNUM) .And. !(lRet := AvStAction("014")) //Estorno de títulos a pagar
                        lRollBack:= .T.
                        Exit
                     Endif
                  EndIf
               Endif
            Endif
         EndIf

         //WFS 17/08/11
         //Recria os títulos no SigaFin, quando houver vinculação/ liquidação de parcelas de adiantamento pós-embarque
         If Len(aEmbarques) > 0
            If !(lRet := AF300AtualTit(aEmbarques))
               lRollBack := .T.
               Exit
            EndIf
         EndIf

         If Select("TMP") == 0
            AF300AbTMP("1")
            RestOrd(aOrdTMP,.T.)
         EndIf

         If !lP_FFC .And. !lMovExt .And. lCpoProc .And. TMP->(FieldPos("EEQ_SEQPAG")) > 0
            TMP->EEQ_SEQPAG := ""
         EndIf

         // MPG - 12/11/2018 - para quando for multifilial considerar a filial do registro selecionado para ação
         if lMultiFil
            cFilAnt := cxFil
         endif

         TMP->(DBSKIP())
      ENDDO
      
      If lIntFina .and. lFinanciamento
         EF3->(dbSetOrder(1))
      EndIf
     
      TMP->(DBGOTOP())

      If EasyEntryPoint("EECAF300")
         ExecBlock("EECAF300",.F.,.F.,{"PE_ESTB_FIM"})
      Endif

   EndIf

End Sequence

// MPG - 12/11/2018 - para quando for multifilial considerar a filial do registro selecionado para ação
if lMultiFil
   cFilAnt := cxFil
endif

RestOrd(aOrdEEQ,.T.)

Return lRet

*--------------------------------------------------------------------
STATIC FUNCTION AF300ESTF()
// ESTORNO DE FFC
LOCAL lRET := .F.
BEGIN SEQUENCE
   TMP->(DBGOTOP())
   IF ! EMPTY(TMP->EEQ_PGT)
      HELP(" ",1,"AVG0005108") //MSGINFO("Estorno de FFC Não Realizado."+ENTER+"Estorne a Baixa Primeiro.","Atenção")
      BREAK

   // ** JPM 11/12/2009 - Nova Legislação Cambial
   ELSEIF EECFlags("CAMBIO_EXT") .And. TMP->EEQ_CONTMV $ "1SY" .And. ! EMPTY(TMP->EEQ_DTCE)
      MsgInfo(STR0111,STR0026) //	STR0111	"Estorno de FFC não realizado. Estorne a baixa gerencial primeiro."  //	#define	STR0026  	"Atenção"
      BREAK

   ELSEIF AF300ESTB(.T.)
          lRET := .T.
   ENDIF
END SEQUENCE
RETURN(lRET)
*-------------------------*
STATIC FUNCTION AF300GFFC()
*-------------------------*
// TELA DE GETS DE INCLUSAO DE FFC
LOCAL oDLGC,Z,aPOS,Y, oGet,cTrb,;
      bOK	    := {|| If(AF300VAL(18),(nBTop := 1, oDlgC:End()),) },;
      bCancel   := {|| nBTop := 0, oDlgC:End() },;
      cALIAS    := SELECT(),;
      aBUTTONS  := {},;
      nBTOP     := 0,;
      lRET      := .F.
Local lBcoExt := TMP->(FieldPos("EEQ_MODAL")) > 0  .And. TMP->(FieldPos('EEQ_BCOEXT')) > 0 .And. TMP->(FieldPos('EEQ_AGCEXT')) > 0 .And. TMP->(FieldPos('EEQ_CNTEXT')) > 0
Local lTemMovExt := .F.

PRIVATE aENCHOICE := {"EEQ_DTNEGO",/*"EEQ_DECAM",*/"EEQ_BANC","EEQ_AGEN","EEQ_NCON",;
                      "EEQ_NOMEBC","EEQ_RFBC","EEQ_CORR","EEQ_CRNO","EEQ_OBS"},;
        aALTERA   := {"EEQ_DTNEGO",/*"EEQ_DECAM",*/"EEQ_BANC","EEQ_AGEN","EEQ_NCON",;
                      "EEQ_NOMEBC","EEQ_RFBC","EEQ_CORR","EEQ_OBS"}

Private lAF300 := .T.  // By JPP - 20/02/2006 - 17:00

If !lIntFina .and. !lFinanciamento
   aAdd(aEnchoice,"EEQ_VLCOR")
   aAdd(aAltera,"EEQ_VLCOR")
   aAdd(aEnchoice,"EEQ_JRAA")
   aAdd(aAltera,"EEQ_JRAA")
   aAdd(aEnchoice,"EEQ_ADIA")
   aAdd(aAltera,"EEQ_ADIA")
   aAdd(aEnchoice,"EEQ_RESP")
   aAdd(aAltera,"EEQ_RESP")
   aAdd(aEnchoice,"EEQ_CTDC")
   aAdd(aAltera,"EEQ_CTDC")
EndIf
*

/* JPM - 11/12/2009 - A ordem de pagamento deve ser preenchida por parcela.
//** AAF 04/03/08 - Numero da Ordem de Pagamento
If EECFlags("CAMBIO_EXT")
   aAdd(aAltera,"EEQ_NROPAG")
EndIf
//**
*/

PRIVATE aTELA[0,0],aGETS[0],;
        aHEADER   := {},;
        aAlter    := {},;
        lSOLICITA := lCONTRATA := .T.,;
		aCampos[7],;
        nUSADO    := 0,;
        lALTERA   := .T.,;
        lINVERTE  := .F.,;
        lREFRESH  := .T.,;
        aROTINA   := {{"","",0,3},{"","",0,4}},;
        aStru     := {}

*

Aadd(aHeader,{ "Importador",            "WK_IMPORT",    "",                     28,                     0,                    "","",    "C"                   } )
Aadd(aHeader,{ AVSX3("EEQ_PREEMB",5),	"EEQ_PREEMB",	AVSX3("EEQ_PREEMB",6),	AVSX3("EEQ_PREEMB",3),	AVSX3("EEQ_PREEMB",4),"","",	AVSX3("EEQ_PREEMB",2) } )

/* by jbj - 22/06/04 10:55 - Verifica se o campo EEQ_NRINVO
                             existe na base de dados.*/
If lNrInvo
   Aadd(aHeader,{AvSx3("EEQ_NRINVO",5),"EEQ_NRINVO",AvSx3("EEQ_NRINVO",6),AvSx3("EEQ_NRINVO",3),AvSx3("EEQ_NRINVO",4),"","",	AVSX3("EEQ_NRINVO",2)})
EndIf
Aadd(aHeader,{ AVSX3("EEQ_PARC",  5),	"EEQ_PARC",		AVSX3("EEQ_PARC",  6),	AVSX3("EEQ_PARC",  3),	AVSX3("EEQ_PARC",  4),"","",	AVSX3("EEQ_PARC",  2) } )
Aadd(aHeader,{ AVSX3("EEQ_DTCE",  5),	"EEQ_DTCE",		AVSX3("EEQ_DTCE",  6),  AVSX3("EEQ_DTCE",  3),	AVSX3("EEQ_DTCE",  4),"","",	AVSX3("EEQ_DTCE",  2) } )
Aadd(aHeader,{ AVSX3("EEQ_SOL",   5),   "EEQ_SOL",      AVSX3("EEQ_SOL",   6),  AVSX3("EEQ_SOL",   3),  AVSX3("EEQ_SOL",   4),"","",	AVSX3("EEQ_SOL",   2) } )

// ** JPM 11/12/2009 - nova leg cambial
If EECFlags("CAMBIO_EXT")
   Aadd(aHeader,{ AVSX3("EEQ_NROPAG",   5),   "EEQ_NROPAG",      AVSX3("EEQ_NROPAG",   6),  AVSX3("EEQ_NROPAG",   3),  AVSX3("EEQ_NROPAG",   4),"","",	AVSX3("EEQ_NROPAG",   2) } )
EndIf

Aadd(aHeader,{ AVSX3("EEQ_VCT",   5),   "EEQ_VCT",		AVSX3("EEQ_VCT",   6),	AVSX3("EEQ_VCT",   3),	AVSX3("EEQ_VCT",   4),"","",	AVSX3("EEQ_VCT",   2) } )
Aadd(aHeader,{ AVSX3("EEQ_VL",    5),	"EEQ_VL",		AVSX3("EEQ_VL",    6),  AVSX3("EEQ_VL",    3),  AVSX3("EEQ_VL",    4),"","",	AVSX3("EEQ_VL",    2) } )
Aadd(aHeader,{ AVSX3("EEQ_VLFCAM",5),	"EEQ_VLFCAM",	AVSX3("EEQ_VLFCAM",6),  AVSX3("EEQ_VLFCAM",3),  AVSX3("EEQ_VLFCAM",4),"","",	AVSX3("EEQ_VLFCAM",2) } )  //NCF - 11/02/2011

//** AAF 04/03/08 - Crédito no exterior somente por baixa gerencial.
If EECFlags("CAMBIO_EXT") .And. !AVFLAGS("CAMBIO_EXP_MOV_EXT")
   Aadd(aAlter,"EEQ_NROPAG") // JPM - 11/12/2009 - alteração da ordem de pagamento por parcela
Else
   Aadd(aAlter,"EEQ_DTCE")
EndIf
//**

Aadd(aAlter,"EEQ_SOL")

DBSELECTAREA("TMP")
Y := 1
Z := TMP->(FCOUNT())
DO WHILE Y <= Z
   M->&(TMP->(FIELDNAME(Y))) := TMP->(FIELDGET(Y))
   Y++
ENDDO
// SERVE P/ FUNCIONAR A TECLA F3 DO CAMPO "EMITIDO POR"
// POSICIONA NO PRIMEIRO PROCESSO
EEC->(DBSETORDER(1))
EEC->(DBSEEK(Left(TMP->EEQ_FILORI,FWSizeFilial())+TMP->EEQ_PREEMB)) //TRP - 12/09/2012 - Utilizar a função FWSizeFilial() para retornar o tamanho da filial.
DBSELECTAREA("EEC")
FOR Z := 1 TO EEC->(FCOUNT())
    M->&(EEC->(FIELDNAME(Z))) := EEC->(FIELDGET(Z))
NEXT

If EasyEntryPoint("EECAF300")
   ExecBlock("EECAF300",.F.,.F.,{"SOLICITA_FFC_CARREGA"})
Endif

Aadd(aStru,{ "WK_IMPORT", "C",                   28,0})
Aadd(aStru,{ "EEQ_PREEMB",AVSX3("EEQ_PREEMB",2), AVSX3("EEQ_PREEMB",3), AVSX3("EEQ_PREEMB",4)})

/* by jbj - 22/06/04 10:55 - Verifica se o campo EEQ_NRINVO
                             existe na base de dados.*/
If !lNrInvo
   Aadd(aStru,{"EEQ_NRINVO","C",20,0})
Else
   Aadd(aStru,{"EEQ_NRINVO",AVSX3("EEQ_NRINVO",2),AVSX3("EEQ_NRINVO",3),AVSX3("EEQ_NRINVO",4)})
EndIf
Aadd(aStru,{ "EEQ_PARC",  AVSX3("EEQ_PARC",  2), AVSX3("EEQ_PARC",  3), AVSX3("EEQ_PARC",  4) } )
Aadd(aStru,{ "EEQ_DTCE",  AVSX3("EEQ_DTCE",  2), AVSX3("EEQ_DTCE",  3), AVSX3("EEQ_DTCE",  4) } )
Aadd(aStru,{ "EEQ_SOL",   AVSX3("EEQ_SOL",   2), AVSX3("EEQ_SOL",   3), AVSX3("EEQ_SOL",   4) } )

// ** JPM 11/12/2009 - nova leg cambial
If EECFlags("CAMBIO_EXT") .Or. AvFlags("CAMBIO_EXP_MOV_EXT")
   Aadd(aStru,{ "EEQ_NROPAG",   AVSX3("EEQ_NROPAG",   2), AVSX3("EEQ_NROPAG",   3), AVSX3("EEQ_NROPAG",   4) } )
EndIf

Aadd(aStru,{ "EEQ_VCT",   AVSX3("EEQ_VCT",   2), AVSX3("EEQ_VCT",   3), AVSX3("EEQ_VCT",   4) } )
Aadd(aStru,{ "EEQ_VL",    AVSX3("EEQ_VL",    2), AVSX3("EEQ_VL",    3), AVSX3("EEQ_VL",    4) } )
Aadd(aStru,{ "EEQ_VLFCAM",AVSX3("EEQ_VLFCAM",2), AVSX3("EEQ_VLFCAM",3), AVSX3("EEQ_VLFCAM",4) } )   //NCF - 11/02/2011


If EECFlags("FRESEGCOM")
   aAdd(aHeader,{AvSx3("EEQ_MOEDA" ,5), "EEQ_MOEDA" , AvSx3("EEQ_MOEDA" ,6), AvSx3("EEQ_MOEDA" ,3), AvSx3("EEQ_MOEDA" ,4),"","", AvSx3("EEQ_MOEDA" ,2)})
   aAdd(aHeader,{AvSx3("EEQ_PARI"  ,5), "EEQ_PARI"  , AvSx3("EEQ_PARI"  ,6), AvSx3("EEQ_PARI"  ,3), AvSx3("EEQ_PARI"  ,4),"","", AvSx3("EEQ_PARI"  ,2)})
   aAdd(aHeader,{AvSx3("EEQ_CODEMP",5), "EEQ_CODEMP", AvSx3("EEQ_CODEMP",6), AvSx3("EEQ_CODEMP",3), AvSx3("EEQ_CODEMP",4),"","", AvSx3("EEQ_CODEMP",2)})
   aAdd(aHeader,{AvSx3("EEQ_FORN"  ,5), "EEQ_FORN"  , AvSx3("EEQ_FORN"  ,6), AvSx3("EEQ_FORN"  ,3), AvSx3("EEQ_FORN"  ,4),"","", AvSx3("EEQ_FORN"  ,2)})
   aAdd(aHeader,{AvSx3("EEQ_FOLOJA",5), "EEQ_FOLOJA", AvSx3("EEQ_FOLOJA",6), AvSx3("EEQ_FOLOJA",3), AvSx3("EEQ_FOLOJA",4),"","", AvSx3("EEQ_FOLOJA",2)})
   aAdd(aHeader,{AvSx3("EEQ_TIPO"  ,5), "EEQ_TIPO"  , AvSx3("EEQ_TIPO"  ,6), AvSx3("EEQ_TIPO"  ,3), AvSx3("EEQ_TIPO"  ,4),"","", AvSx3("EEQ_TIPO"  ,2)})

   Aadd(aStru,{"EEQ_MOEDA" , AvSx3("EEQ_MOEDA" ,2), AvSx3("EEQ_MOEDA" ,3), AvSx3("EEQ_MOEDA" ,4)})
   Aadd(aStru,{"EEQ_PARI"  , AvSx3("EEQ_PARI"  ,2), AvSx3("EEQ_PARI"  ,3), AvSx3("EEQ_PARI"  ,4)})
   Aadd(aStru,{"EEQ_CODEMP", AvSx3("EEQ_CODEMP",2), AvSx3("EEQ_CODEMP",3), AvSx3("EEQ_CODEMP",4)})
   Aadd(aStru,{"EEQ_FORN"  , AvSx3("EEQ_FORN"  ,2), AvSx3("EEQ_FORN"  ,3), AvSx3("EEQ_FORN"  ,4)})
   Aadd(aStru,{"EEQ_FOLOJA", AvSx3("EEQ_FOLOJA",2), AvSx3("EEQ_FOLOJA",3), AvSx3("EEQ_FOLOJA",4)})
   Aadd(aStru,{"EEQ_TIPO"  , AvSx3("EEQ_TIPO"  ,2), AvSx3("EEQ_TIPO"  ,3), AvSx3("EEQ_TIPO"  ,4)})

   If EEQ->( FieldPos("EEQ_TP_CON") ) > 0
      aAdd(aHeader,{AvSx3("EEQ_TP_CON"  ,5), "EEQ_TP_CON"  , AvSx3("EEQ_TP_CON"  ,6), AvSx3("EEQ_TP_CON"  ,3), AvSx3("EEQ_TP_CON"  ,4),"","", AvSx3("EEQ_TP_CON"  ,2)})
      aAdd(aStru,{"EEQ_TP_CON"  , AvSx3("EEQ_TP_CON"  ,2), AvSx3("EEQ_TP_CON"  ,3), AvSx3("EEQ_TP_CON"  ,4)})
   EndIf
EndIf

//*** RMD - 23/11/07 - Nova legislação de câmbio
If EECFlags("CAMBIO_EXT")
   aAdd(aEnchoice, "EEQ_CONTMV")
   /* JPM - 11/12/2009 - a ordem de pagamento deve ser preenchida por parcela (no browse)
   aAdd(aEnchoice, "EEQ_NROPAG") //AAF 04/03/08 - Numero da Ordem de Pagamento
   */
EndIf
//***

If lBcoExt
   aAdd(aStru,{"EEQ_MODAL",AVSX3("EEQ_MODAL",AV_TIPO),AVSX3("EEQ_MODAL",AV_TAMANHO),AVSX3("EEQ_MODAL",AV_DECIMAL)})
   aAdd(aStru,{'EEQ_BCOEXT',AVSX3('EEQ_BCOEXT',AV_TIPO),AVSX3('EEQ_BCOEXT',AV_TAMANHO),AVSX3('EEQ_BCOEXT',AV_DECIMAL)})
   aAdd(aStru,{'EEQ_AGCEXT',AVSX3('EEQ_AGCEXT',AV_TIPO),AVSX3('EEQ_AGCEXT',AV_TAMANHO),AVSX3('EEQ_AGCEXT',AV_DECIMAL)})
   aAdd(aStru,{'EEQ_CNTEXT',AVSX3('EEQ_CNTEXT',AV_TIPO),AVSX3('EEQ_CNTEXT',AV_TAMANHO),AVSX3('EEQ_CNTEXT',AV_DECIMAL)})
EndIf


// FDR - 20/10/10
aStru   := AddWkCpoUser(aStru,"EEQ")
cTrb	:= E_CriaTrab("",aStru,"WORK1")

TMP->( DBSetFilter( {|| TMP->EEQ_FLAG <> Space(2) }, "TMP->EEQ_FLAG <>'" + Space(2) + "'" ) )
TMP->(DBGoTop())
lBcoExt := lBcoExt .And. TMP->(FieldPos("EEQ_MODAL")) > 0  .And. WORK1->(FieldPos("EEQ_MODAL")) > 0  .And. WORK1->(FieldPos('EEQ_BCOEXT')) > 0 .And. WORK1->(FieldPos('EEQ_AGCEXT')) > 0 .And. WORK1->(FieldPos('EEQ_CNTEXT')) > 0

Do While .not. TMP->(Eof())
   If TMP->EEQ_Flag <> Space(2)

      WORK1->( RecLock("WORK1", .t.) )

      WORK1->EEQ_PREEMB	:= TMP->EEQ_PREEMB
      WORK1->EEQ_NRINVO	:= TMP->EEQ_NRINVO
      WORK1->EEQ_PARC	:= TMP->EEQ_PARC
      WORK1->EEQ_DTCE	:= TMP->EEQ_DTCE
      WORK1->EEQ_SOL	:= TMP->EEQ_SOL

      // ** JPM 11/12/2009
      If EECFlags("CAMBIO_EXT") .Or. AvFlags("CAMBIO_EXP_MOV_EXT")
         WORK1->EEQ_NROPAG := TMP->EEQ_NROPAG
      EndIf

      WORK1->EEQ_VCT	:= TMP->EEQ_VCT
      WORK1->EEQ_VL		:= TMP->EEQ_VL
      WORK1->EEQ_VLFCAM := TMP->EEQ_VLFCAM          //NCF - 11/04/2011
      WORK1->WK_IMPORT	:= TMP->WK_IMPORT

      If EECFlags("FRESEGCOM")
         Work1->EEQ_MOEDA  := Tmp->EEQ_MOEDA
         Work1->EEQ_PARI   := Tmp->EEQ_PARI
         Work1->EEQ_CODEMP := Tmp->EEQ_CODEMP
         Work1->EEQ_FORN   := Tmp->EEQ_FORN
         Work1->EEQ_FOLOJA := Tmp->EEQ_FOLOJA
         Work1->EEQ_TIPO   := Tmp->EEQ_TIPO

         If Work1->( FieldPos("EEQ_TP_CON") ) > 0
            Work1->EEQ_TP_CON := Tmp->EEQ_TP_CON
         EndIf
      EndIf

      If lBcoExt
         Work1->EEQ_MODAL  := TMP->EEQ_MODAL
         If TMP->EEQ_MODAL == "2"
            lTemMovExt := .T.
         EndIf
      EndIf

      aOrd := SaveOrd("SX3",1)
      SX3->(dbSeek("EEQ"))
      While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "EEQ"
         If SX3->X3_PROPRI=="U" .AND. X3Uso(SX3->X3_USADO) .and. (SX3->X3_ARQUIVO)->(FieldPos(SX3->X3_CAMPO)) > 0
            Eval(FieldWBlock(SX3->X3_CAMPO, Select("Work1")),  Eval(FieldWBlock(SX3->X3_CAMPO, Select("TMP"))))
         EndIF
         SX3->(dbSkip())
       Enddo
       RestOrd(aOrd)


       WORK1->( MSUnlock() )
   Endif
   TMP->(DBSkip())
Enddo

If lBcoExt .And. lTemMovExt
   aAdd(aENCHOICE,'EEQ_BCOEXT')
   aAdd(aENCHOICE,'EEQ_AGCEXT')
   aAdd(aENCHOICE,'EEQ_CNTEXT')
   aAdd(aALTERA,'EEQ_BCOEXT')
   aAdd(aALTERA,'EEQ_AGCEXT')
   aAdd(aALTERA,'EEQ_CNTEXT')
   M->EEQ_BCOEXT := Space(AvSx3("EEQ_BCOEXT",AV_TAMANHO))
   M->EEQ_AGCEXT := Space(AvSx3("EEQ_AGCEXT",AV_TAMANHO))
   M->EEQ_CNTEXT := Space(AvSx3("EEQ_CNTEXT",AV_TAMANHO))
EndIf

//ASK 10/09/2007 - Limpa da memória para não carregar na enchoice.
M->EEQ_PGT    := AVCTOD("")
M->EEQ_EQVL   := 0          ; M->EEQ_TX     := 0 ; M->EEQ_VLFCAM := 0
M->EEQ_DECAM  := SPACE(01)
M->EEQ_BANC   := SPACE(03)  ; M->EEQ_CORR   := Space(AvSx3("EEQ_CORR",AV_TAMANHO)) //SPACE(15) *** GFP 27/07/2011
M->EEQ_AGEN   := SPACE(05)  ; M->EEQ_NCON   := SPACE(10)
M->EEQ_NOMEBC := SPACE(40)  ; M->EEQ_RFBC   := SPACE(20)
M->EEQ_DTNEGO := AVCTOD("  /  /  ")

DBSelectArea("TMP")
Set Filter to

//*** RMD - 23/11/07 - Nova legislação de câmbio
If !EECFlags("CAMBIO_EXT")
   Aadd(aButtons,{"S4WB014A",{|| AF300GrvDt("WORK1"), oGet:oBrowse:Refresh() }, STR0066, STR0098 })   // "Preenche todas as data automaticamente" # "Datas"
EndIf
//***

// FDR - 20/10/10
aHeader := AddCpoUser(aHeader,"EEQ","4")
aALTER   := AddCpoUser(aAlter,"EEQ","1")
aAdd(aENCHOICE,"NOUSER")

DBSELECTAREA("WORK1")
WORK1->(dbGoTop())

DEFINE MSDIALOG oDlgC TITLE STR0027 FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL //"Manutenção de FFC - Solicitação"

   lWhile   := .f.
   aPOS     := POSDLGUp(oDLGC)

   ENCHOICE("EEQ",RECNO(),1,4,,,aENCHOICE,aPos,aALTERA,3)

   aPOS     := POSDLGDOWN(oDLGC)
   WORK1->(oGet:=MsGetDb():New( aPos[1], aPos[2], aPos[3], aPos[4], 2, , , ,.f., aAlter, , .t.,,"WORK1") )
   oGET:oBROWSE:BADD := {||.F.}

ACTIVATE MSDIALOG oDlgC ON INIT ENCHOICEBAR(oDLGC,bOK,bCancel,,aBUTTONS)

WORK1->(DBGoTop())
TMP->( DBSetOrder(2) )
Do While .not. WORK1->(Eof())
   if TMP->(DBSeek(WORK1->EEQ_PREEMB + WORK1->EEQ_NRINVO + WORK1->EEQ_PARC))
      TMP->( RecLock("TMP",.f.) )
      TMP->EEQ_DTCE   := WORK1->EEQ_DTCE
      TMP->EEQ_SOL    := WORK1->EEQ_SOL

      // ** JPM 11/12/2009 - Nova leg. cambial
      If EECFlags("CAMBIO_EXT") .Or. AvFlags("CAMBIO_EXP_MOV_EXT")
         TMP->EEQ_NROPAG := WORK1->EEQ_NROPAG
      EndIf

      SX3->(dbSeek("EEQ"))
	  While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "EEQ"
	     If Alltrim(SX3->X3_PROPRI) == "U" .AND. X3Uso(SX3->X3_USADO)
            TMP->&(SX3->X3_CAMPO) := WORK1->&(SX3->X3_CAMPO)
         EndIf

         SX3->(dbSkip())
      EndDo

   Endif
   WORK1->( DBSkip() )
Enddo

IF nBTOP = 1

   // Grava os dados apenas nos registros contidos na WORK1 para o TMP
   // By - A. Caetano Jr - 06/12/2003

   WORK1->(DBGoTop())
   TMP->( DBSetOrder(2) )
   Do While .not. WORK1->(Eof())
      if TMP->(DBSeek(WORK1->EEQ_PREEMB + WORK1->EEQ_NRINVO + WORK1->EEQ_PARC))

         TMP->( RecLock("TMP",.f.) )
         TMP->EEQ_DTNEGO := M->EEQ_DTNEGO
         TMP->EEQ_DECAM  := M->EEQ_DECAM

          /* TLM 20/02/2008 - Se não for informado nenhum dado na manuteção FCC (memória) será utilizado os dados da parcela que estão gravados na tabela
                             Para o Banco, agência, conta, nome do banco e referência do banco */
         If lBcoExt .And. TMP->EEQ_MODAL == "2"
            TMP->EEQ_BCOEXT := iif(empty(M->EEQ_BCOEXT),TMP->EEQ_BCOEXT,M->EEQ_BCOEXT)
            TMP->EEQ_AGCEXT := iif(empty(M->EEQ_AGCEXT),TMP->EEQ_AGCEXT,M->EEQ_AGCEXT)
            TMP->EEQ_CNTEXT := iif(empty(M->EEQ_CNTEXT),TMP->EEQ_CNTEXT,M->EEQ_CNTEXT)
         Else
            TMP->EEQ_BANC   := iif(empty(M->EEQ_BANC),TMP->EEQ_BANC,M->EEQ_BANC)
            TMP->EEQ_AGEN   := iif(empty(M->EEQ_AGEN),TMP->EEQ_AGEN,M->EEQ_AGEN)
            TMP->EEQ_NCON   := iif(empty(M->EEQ_NCON),TMP->EEQ_NCON,M->EEQ_NCON)
            TMP->EEQ_NOMEBC := iif(empty(M->EEQ_NOMEBC),TMP->EEQ_NOMEBC,M->EEQ_NOMEBC)
            TMP->EEQ_RFBC   := iif(empty(M->EEQ_RFBC),TMP->EEQ_RFBC,M->EEQ_RFBC) /*  TLM 20/02/2008   */
         EndIf

         //TMP->EEQ_RFBC   := iif(empty(TMP->EEQ_RFBC),M->EEQ_RFBC,)//ASK 07/02/2008 - Se a parcela possuir referencia preenchida, não sobrepõe

         TMP->EEQ_CORR   := M->EEQ_CORR

         //*** RMD - 23/11/07 - Nova legislação de câmbio
         If EECFlags("CAMBIO_EXT")
            TMP->EEQ_CONTMV := M->EEQ_CONTMV
         EndIf
         //***

         If !lIntFina .and. !lFinanciamento
            TMP->EEQ_VLCOR  := M->EEQ_VLCOR
            TMP->EEQ_JRAA   := M->EEQ_JRAA
            TMP->EEQ_ADIA   := M->EEQ_ADIA
            TMP->EEQ_RESP   := M->EEQ_RESP
            TMP->EEQ_CTDC   := M->EEQ_CTDC
         Endif

		 //TRP - 05/06/2012 - Gravaçao do campo Observação.
         TMP->EEQ_OBS:= M->EEQ_OBS

         /* JPM - 11/12/2009 - a ordem de pagamento deve ser preenchida por parcela.
         //** AAF 04/03/08 - Gravação do Numero da Ordem de Pagamento
         If EECFlags("CAMBIO_EXT")
            TMP->EEQ_NROPAG := M->EEQ_NROPAG
         EndIf
         //**
         */

         If EasyEntryPoint("EECAF300")
            ExecBlock("EECAF300",.F.,.F.,{"SOLICITA_FFC_GRAVA"})
         Endif
         TMP->( MSUnlock() )
      Endif
      WORK1->(DBSkip())
   Enddo
   //TMP->( DBSetOrder(1) )
   TMP->(dbSetOrder(3))
   lRET := .T.
Endif
//TMP->(DBSetOrder(1))
TMP->(dbSetOrder(3))
TMP->(DBGOTOP())
DBSELECTAREA(cALIAS)
oMSELECT:oBROWSE:REFRESH()
WORK1->(E_EraseArq("WORK1"))
RETURN(lRET)

*----------------------------*
Static Function AF300PesqInv()
*----------------------------*
Local cInv:=Space(Len(EEQ->EEQ_NRINVO))
LOCAL cImp:=Space(Len(EEC->EEC_IMPORT))
Local cPreemb := Space(Len(EEQ->EEQ_PREEMB))
Local nOp:=0, nRec:=TMP->(RecNo())

DEFINE MSDIALOG oDlg TITLE STR0031 ; //"Invoice a Pesquisar"
       FROM 12,05 TO 25/*20*/,55 OF GetWndDefault()        //BHF - 18/07/08 //FSM - 14/11/2012

   @03,02 Say AVSX3("EEC_IMPORT",5) of oDlg
   @03,08 MSGET cImp PICT AVSX3("EEC_IMPORT",6) F3("CLI") VALID iif(Empty(cImp),.t.,AvgExistCpo("SA1",cImp,1)) SIZE 60,8 //AAF - 06/01/2005 - Utilizada a Função AvgExistCpo para validar em Multifiliais.

   @04,02 SAY  AVSX3("EEQ_NRINVO",5) of oDlg
   @04,08 MSGET cInv PICT AVSX3("EEQ_NRINVO",6) VALID iif(Empty(cInv),.t.,AvgExistCpo("EEQ",cInv,4)) SIZE 60,8 //AAF - 06/01/2005 - Utilizada a Função AvgExistCpo para validar em Multifiliais.

   @05,02 SAY  AVSX3("EEQ_PREEMB",5) of oDlg
   @05,08 MSGET cPreemb PICT AVSX3("EEQ_PREEMB",6) F3(If(Type("lCallRS403") == "L" .And. lCallRS403,'EJY',"EEC")) VALID iif(Empty(cPreemb),(MsgInfo("Informe o Processo.","Atenção"),.F.),AvgExistCpo("EEQ",cPreemb,1)) SIZE 60,8

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOp:=1,oDlg:End()},{||nOp:=0,oDlg:End()}) CENTERED

If nOp=1
   If !Empty(cPreemb)
      If Empty(cImp)
         TMP->(dbSetOrder(2))
         If !TMP->(dbSeek(cPreemb+cInv))
            MsgInfo(STR0030) //"Invoice não Encontrada."
            TMP->(dbGoTo(nRec))
         Else
            oMSELECT:oBrowse:Refresh()
         EndIf
      Elseif Empty(cInv)
         TMP->(DBSetOrder(1))
         If .not. TMP->(DBSeek(cPreemb+cImp))
            MsgInfo(STR0067)  // "Importador não Encontrado."
            TMP->(DBGoTo(nRec))
         Else
            oMSELECT:oBrowse:Refresh()
         Endif
      Else
         TMP->(DBSetOrder(1))
         if .not. TMP->(DBSeek(cPreemb+cImp+cInv))
            MsgInfo(STR0068)   // "Registro não Encontrado."
            TMP->(DBGoTo(nRec))
         Else
            oMSELECT:oBrowse:Refresh()
         Endif
      Endif
   EndIf
   //TMP->(dbSetOrder(1))
   TMP->(dbSetOrder(3))
EndIf

Return .T.

/*
Funcao      : AF300CotaCam()
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Manutencao de Cotaçao e Fechamento de Cambio. ( Versao FFC)
Autor       : Jeferson Barros Jr.
Data/Hora   : 17/01/2003 14:10.
Revisao     :
Obs.        :
*/
*---------------------*
Function AF300CotaCam()
*----------------------*
Local cTit, oDlg, oMsSelect, cFFC, nVlTot:=0, nTaxa :=0
Local aButtons := {}, aCpos := {}, aOrd:=SaveOrd({"EEC","EXG"})
Local bOk := {|| oDlg:End()} , bCancel := {|| oDlg:End()}
Local lRet:= .t.

Begin Sequence

  // ** Definição dos botoes da Enchoice Bar.
  aAdd(aButtons,{"BMPVISUAL" /*"ANALITICO"*/, {|| AF300CotMan(VIS_DET)},STR0037}) //"Visualizar"

  If Empty(TMP->EEQ_PGT)   // ** Verifica se a FFC está liquidada.
     aAdd(aButtons,{"BMPINCLUIR" /*"EDIT"*/ , {|| AF300CotMan(INC_DET,oMsSelect)},STR0038}) //"Incluir"
     aAdd(aButtons,{"EDIT" /*"ALT_CAD"*/    , {|| AF300CotMan(ALT_DET,oMsSelect)},STR0039}) //"Alterar"
     aAdd(aButtons,{"EXCLUIR"  , {|| AF300CotMan(EXC_DET,oMsSelect)},STR0040}) //"Excluir"
     aAdd(aButtons,{"LIQCHECK" , {|| If(AF300LiqParc(),Eval(bOk),Nil)},STR0041}) //"Liquidar"
  EndIf

  // ** Colunas para o Browse ...
  aCpos := {{{|| AllTrim(Work_Cot->EXG_BANC)+"-"+AllTrim(Work_Cot->EXG_NOMEBC)},"",STR0042+Space(50)},; //"Banco"
            {{|| Work_Cot->EXG_AGEN} ,"",STR0043},; //"Agencia"
            {{|| Work_Cot->EXG_NCON} ,"",STR0044},; //"Nro.Conta"
            {{|| AllTrim(Transf(Work_Cot->EXG_TX,AVSX3("EXG_TX",AV_PICTURE)))} ,"",STR0045},; //"Taxa"
            {{|| AllTrim(Transf(Work_Cot->EXG_DSPBCO,AVSX3("EXG_DSPBCO",AV_PICTURE)))} ,"",STR0046},; //"Desp.Bco."
            {{|| AllTrim(Work_Cot->EXG_CORR)+"-"+AllTrim(Posicione("SY5",1,xFilial("SY5")+Work_Cot->EXG_CORR,"Y5_NOME"))} ,"",STR0047+Space(50)},; //"Corretor"
            {{|| AllTrim(Transf(Work_Cot->EXG_VLCOR,AVSX3("EXG_VLCOR",AV_PICTURE)))} ,"",STR0048+Space(200)}} //"Vl.Corretagem"

  Work_Cot->(DbGoTop())

  // ** Set das variáveis...
  cTit  := STR0049 //"Cotação de Taxas Para Fechamento de FFC. "
  aTela := {} ;  aGets := {}
  cFFC   := TMP->EEQ_FFC
  nTaxa  := TMP->EEQ_TX

  // ** Calcula o total do FFC.
  TMP->(DbGoTop())
  Do While TMP->(!Eof())
     nVlTot += TMP->EEQ_VL
     TMP->(DbSkip())
  EndDo
  TMP->(DbGoTop())

  DEFINE MSDIALOG oDlg TITLE cTit FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

     @ 15,007 Say STR0050 Size 80,07 PIXEL Of oDlg //"FFC  "
     @ 15,140 Say STR0051 Size 80,07 PIXEL Of oDlg //"Total"
     @ 15,280 Say STR0052 Size 80,07 PIXEL Of oDlg //"Taxa "

     @ 15,050 MSGET cFFC   PICTURE AVSX3("EEQ_FFC",AV_PICTURE) Size 050,07  Pixel Of oDlg When .f.
     @ 15,190 MSGET nVlTot PICTURE AVSX3("EEQ_VL ",AV_PICTURE) Size 050,07  Pixel Of oDlg When .f.
     @ 15,330 MSGET nTaxa  PICTURE AVSX3("EEQ_TX",AV_PICTURE)  Size 050,07  Pixel Of oDlg When .f.

     aPos := PosDlgDown(oDlg)
     aPos[1] := 30

    // by CRF 18/10/2010


    aCpos := AddCpoUser(aCpos,"EXG","5","Work_Cot")
    //aCpos := AddCpoUser(aCpos,"EXG",2)

     oMsSelect := MsSelect():New("Work_Cot",,,aCpos,,,aPos)
     oMsSelect:bAval := {|| AF300CotMan(VIS_DET)}

  ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : AF300CotMan(nTipo,oMsSelect)
Parametros  : nTipo  := VIS_DET/INC_DET/ALT_DET/EXC_DET
              oMsSelect := Objeto para refresh.
Retorno     : .T.
Objetivos   : Manutencao de Cotação de fechamento de câmbio. (Versao FFC).
Autor       : Jeferson Barros Jr.
Data/Hora   : 17/01/03 15:00.
Obs.        :
*/
*------------------------------------------*
Static Function AF300CotMan(nTipo,oMsSelect)
*------------------------------------------*
Local bOk:={|| If(AF300ValCot(nTipo,nReg),(nOpcao := 1,oDlg:End()),Nil)}, bCancel:={|| oDlg:End()}
Local aEnchoice := {}, aPos := {}, aButtons:={}
Local cTit := STR0053 //"Taxas de Câmbio."
Local nOpcao := 0, nReg, i:=0
Local lRet := .t.

Private aTela[0,0],aGets[0], aHeader:={},nUsado:=0
Private lRefresh:=.t.

Begin Sequence

   IF nTipo != INC_DET .And. Work_Cot->(Eof()) .AND. Work_Cot->(Bof())
      HELP(" ",1,"AVG0000632") // "Não existem registros para a manutenção !"
      Break
   EndIf

   // ** Campos da enchoice.
   aEnchoice:={"EXG_TX","EXG_CORR","EXG_CRNO" ,"EXG_VLCOR",;
               "EXG_BANC","EXG_NOMEBC","EXG_AGEN","EXG_NCON","EXG_DSPBCO", "EXG_DSPCON","EXG_RFBC"}

   If nTipo == INC_DET
      For i := 1 TO EXG->(FCount())
         M->&(EXG->(FieldName(i))) := CriaVar(EXG->(FieldName(i)))
      Next
   Else
      For i := 1 TO Work_Cot->(FCount())
         M->&(Work_Cot->(FieldName(i))) := Work_Cot->(FieldGet(i))
      Next
   EndIf

   nReg := Work_Cot->(RecNo())

   DEFINE MSDIALOG oDlg TITLE cTit FROM 9,0 TO 35,80 OF oMainWnd
      aPos := PosDlg(oDlg)
      EnChoice("EXG",,IF(nTipo=INC_DET,3,4),,,,aEnchoice,aPos,IF(Str(nTipo,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1),{},),3)
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons) CENTERED

   If nOpcao = 1
      If nTipo == INC_DET
         Work_Cot->(DbAppend())
         nReg := Work_Cot->(RecNo())
         AvReplace("M","Work_Cot")
         Work_Cot->EXG_PREEMB := "_FFC"+AllTrim(TMP->EEQ_FFC)
         Work_Cot->EXG_PARC   := "FF"
      ElseIf nTipo == ALT_DET
         AvReplace("M","Work_Cot")
      EndIf

      If nTipo <> VIS_DET
         oMsSelect:oBrowse:Refresh()
         Work_Cot->(DbGoTop())
      EndIf
   EndIf

End Sequence

Return lRet

/*
Funcao      : AF300ValCot(nTipo,nReg).
Parametros  : nTipo => Opcao
              nReg  => Nro. Registro.
Retorno     : .t./.f.
Objetivos   : Efetuar validação do registro para exclusão.
Autor       : Jeferson Barros Jr.
Data/Hora   : 17/01/03 15:40.
Obs.        :
*/
*-------------------------------------*
Static Function AF300ValCot(nTipo,nReg)
*-------------------------------------*
Local lRet:=.t., nRecNo:=0

Begin Sequence

   If Str(nTipo,1) $ Str(INC_DET,1)+"/"+Str(ALT_DET,1)
      If !Obrigatorio(aGets,aTela)
         lRet := .f.
         Break
      Endif

      nRecNo:= Work_Cot->(Recno())

      If Work_Cot->(DbSeek(AvKey("_FFC"+TMP->EEQ_FFC,"EXG_PREEMB")+AvKey("FF","EXG_PARC")+M->EXG_BANC+M->EXG_CORR))
         If nTipo == INC_DET
            MsgInfo(STR0054,STR0026) //"Já existe cotação de câmbio para este banco e corretora."###"Atenção"
            lRet:=.f.
            Break
         Else
            If Work_Cot->(RecNO()) <> nRecNo
               MsgInfo(STR0054,STR0026) //"Já existe cotação de câmbio para este banco e corretora."###"Atenção"
               lRet:=.f.
               Break
            EndIf
         EndIf
      EndIf

      Work_Cot->(DbGoTo(nRecNo))

   ElseIf nTipo == EXC_DET

      If MsgNoYes(STR0055,STR0036) //"Confirma exclusão do Registro Atual ?"###"Aviso"
         Work_Cot->(DbGoTo(nReg))

         If Work_Cot->RECNO != 0
            aAdd(aDelCotCam,Work_Cot->RECNO)
         EndIf

         Work_Cot->(DbDelete())
         Work_Cot->(DbGoTop())
      Else
         lRet := .F.
      EndIf
   EndIf

End Sequence

Return lRet

/*
Funcao      : AF300LiqParc().
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Efetuar liquidacao da parcela com base na cotação selecionada.
Autor       : Jeferson Barros Jr.
Data/Hora   : 17/01/03 15:41.
Obs.        :
*/
*-----------------------------*
Static Function AF300LiqParc()
*-----------------------------*
Local lRet:=.f.

Begin Sequence

   If Work_Cot->(Eof()) .AND. Work_Cot->(Bof())
      Help(" ",1,"AVG0000632") // "Não existem registros para a manutenção !"
      Break
   EndIf

   AF300Sal(.t.,.t.)

   If !Empty(TMP->EEQ_PGT)
      lRet:=.t.
   EndIf

End Sequence

Return lRet

/*
by CAF 09/04/2004 - A função abaixo AF3ValLiq não estava sendo utilizada, com isso
                    gerava erro de compilação no MP8

*----------------------------------------------------------------------------------------------*
Static Function AF3ValLiq()
*----------------------------------------------------------------------------------------------*
Local lRet:=.T.

If lIntFina .and. lFinanciamento
   EF3->(dbSetOrder(3))
   EF1->(dbSetOrder(1))
   If EF3->(dbSeek(cFilEF3+If(lEFFTpMod,"E","")+TMP->EEQ_NRINVO+If(!lParFin .Or. Empty(TMP->EEQ_PARFIN),TMP->EEQ_PARC,TMP->EEQ_PARFIN)))
      If EF1->(dbSeek(cFilEF1+EF3->EF3_CONTRA)) .and. !Empty(EF1->EF1_DT_ENC)
         MsgInfo(STR0061) //"FFC não pode ser liquidado pois está vinculado a um contrato encerrado."
         lRet:=.F.
      Endif
   EndIf
Endif

Return lRet
*/

// *******************************
Function AF300Marca(PcMarca,PlTodos)
// By A. Caetano Jr. - 02/12/2203
// Gera Saldo dos itens marcados.
// *******************************
LOCAL nReg

If Valtype(PlTodos) == "U"
   PlTodos := .f.
Endif

nReg := TMP->(Recno())

If PlTodos
    TMP->(DBGoTop())
    Do While .not. TMP->(Eof())
        if !EasyVerModal("TMP")
            nSaldo += TMP->EEQ_VL
        Endif
        TMP->(DBSkip())
    Enddo
    TMP->(DBGoTo(nReg))
Else
    if !EasyVerModal("TMP")
        RecLock("TMP",.f.)
        If Empty(TMP->EEQ_FLAG)
            // ** JPM - 08/01/2009 - na nova rotina de câmbio, se a parcela já possuir baixa gerencial, não pode ser vinculada.
            /*If EECFlags("CAMBIO_EXT") .And. !Empty(TMP->EEQ_DTCE)
                MsgInfo("Essa parcela já está com Baixa Gerencial e não poderá ser vinculada à FFC.","Atenção")
                Return
            EndIf*/
            nSaldo += TMP->EEQ_VL
            TMP->EEQ_FLAG := PcMarca
        Else
            nSaldo -= TMP->EEQ_VL
            TMP->EEQ_FLAG := Space(2)
        Endif
        TMP->( MsUnlock() )
    Else
        MsgInfo( "As operações em lote com parcelas de movimento no exterior devem ser gerenciadas pela rotina 'Painel de Câmbio'!", "Aviso" )
    Endif
Endif

oSaldo:Refresh()

//Acb - 05/08/2010 - Ponto de entrada 3M **082841
If EasyEntryPoint("EECAF300")
   ExecBlock("EECAF300",.F.,.F.,"AF300_MARCA_TODOS")
EndIf

Return Nil

// *********************************
Function AF300VDT(PAlias)
// Verifica se as Datas foram preenchidas corretamente
// By - A. Caetano Jr - 03/12/2003
// *********************************
LOCAL lRet
lRet := .t.

&(PAlias)->(DBGoTop())
Do While .not. &(PAlias)->(Eof())

   If (PAlias)->EEQ_TIPO <> "P" .and. Empty((PAlias)->EEQ_DTCE)
      MsgInfo(STR0069)   // "A Data de Credito no Exterior deve ser informada"
      lRet := .f.
      Exit
   Endif

   If ( M->EEQ_DTNEGO < &(PAlias)->(EEQ_DTCE) ) .and. (.not. Empty(M->EEQ_DTNEGO) )
      MsgInfo(STR0070)   // "Data de Negociação inferior a Data de Credito no Exterior"
	  lRet := .f.
      Exit
   Endif

   IF !Empty((PAlias)->EEQ_SOL) .and. !Empty(M->EEQ_DTNEGO) .And. M->EEQ_DTNEGO < (PAlias)->EEQ_SOL  // By JPP - 21/02/2006 - 14:00
      MsgInfo(STR0081,STR0026) //"A data de negociação não pode ser anterior a Data de Solicitação."###"Atenção"
      lRet := .f.
      Exit
   Endif

   &(PAlias)->(DBSkip())
Enddo

If PAlias == "TMP"   // Liquidacao
   If Empty(AF200DtBaixa("M"))//Empty(M->EEQ_PGT)
      MsgInfo(STR0071)   // "A Data de Liquidação deve ser informada"
      lRet := .F.
   Endif
   If Empty(M->EEQ_DTNEGO)
      MsgInfo(STR0072)   // "A Data de Negociação deve ser informada"
      lRet := .F.
   Endif
Endif

Return lRet

// ********************************
FUNCTION AF300GrvDt(PAlias)
// By A. Caetano Jr. - 05/12/2003
// Preenche as datas de solicitacao e credito no exterior automaticamente.
// ********************************
LOCAL nReg, nDtOk
LOCAL dDtCe, dDtSol
LOCAL oDLGDT

Local oRadio
Local nRadio := 1
Local aRadio := {STR0112,; //STR0112	"Todas as parcelas."
                 STR0113}//STR0113	"Somente as parcelas com a data em branco."

nDtOk   := 0
nReg    := &(PAlias)->(Recno())
dDtCe   := CtoD(Space(8))
dDtSol  := CtoD(Space(8))

Begin Sequence

   //DEFINE MSDIALOG oDLGDT TITLE STR0073 FROM 0,0 TO 145,295 OF oMainWnd PIXEL   // "Preenchimento automatico de datas"
   DEFINE MSDIALOG oDLGDT TITLE STR0073 FROM 0,0 TO /*200*/230,385 OF oMainWnd PIXEL   // "Preenchimento automatico de datas"   350  //FSM - 14/11/2012

    @33,05 To 67, 170 Label STR0114 Pixel//STR0114	"Preencher"
    @40,17 Say STR0074                             PIXEL   // "Data de Credito no Exterior "
    @38,89 MsGet dDtCE  PICTURE "@D" SIZE 060,08;
        When !EECFlags("CAMBIO_EXT")  PIXEL // ** JPM - 08/01/2009 - só pode alterar a data de crédito quando está na rotina antiga.

    // ** JPM - 08/01/2010 - botão que explica porque a data de crédito não está ativa.
    If EECFlags("CAMBIO_EXT")
       @ 38,150 Button oBtAjuda Prompt "?" Size 09,09 Pixel ;
         Action MsgInfo(STR0117+; //STR0117	"O campo 'Data de Crédito no Exterior' está desabilitado pois "
                        STR0115,STR0026) //Of oDLGDT// //	STR0115	" deve ser preenchido através da rotina de baixa gerencial." //STR0026  	"Atenção"
    EndIf

    @55,17 Say STR0075                             PIXEL   // "Data de Solicitacao         "
    @53,89 MsGet dDtSol PICTURE "@D" SIZE 060,08   PIXEL

    @72,05 To 105, 170 Label STR0116 Pixel//STR0116	"Atualizar"
    @79,17 Radio oRadio Var nRadio Size 120,11 Items aRadio[1], aRadio[2] Of oDLGDT

   ACTIVATE MSDIALOG oDLGDT CENTERED ON INIT ENCHOICEBAR(oDLGDT, {|| nDtOk := 1, oDLGDT:End() } ,{|| oDLGDT:End() } )
   If nDtOk == 1
      &(PAlias)->(DBGoTop())
      Do While .not. &(PAlias)->(EoF())
         &(PAlias)->(RecLock(PAlias,.f.))

      	  If !Empty(dDtCE)
   	        If nRadio = 1 .or. (nRadio = 2 .and. Empty(&(PAlias)->(EEQ_DTCE)))
      	       &(PAlias)->(EEQ_DTCE) := dDtCE
    	       M->EEQ_DTCE           := dDtCE
            EndIf
          Endif

         If !Empty(dDtSol)
            If nRadio = 1 .or. (nRadio = 2 .and. Empty(&(PAlias)->(EEQ_SOL)))
               &(PAlias)->(EEQ_SOL)  := dDtSol
               M->EEQ_SOL            := dDtSol
            EndIf
         Endif

         &(PAlias)->(MsUnlock())
         &(PAlias)->(DBSkip())
      Enddo
   Endif

End Sequence
&(PAlias)->(DBGoTo(nReg))
Return nil

//----------------------------------------------
STATIC FUNCTION AF300MsgEst()
// MSG P/ CONFIRMAÇÃO DO ESTORNO DA BAIXA

// ** JPM - colocado como private para ser acessado pelo ponto de entrada.
//LOCAL lRET := .F.

Private lRetEstBaixa := .F.

BEGIN SEQUENCE

   // ** JPM - 08/01/2010 - validações customizadas.
   If EasyEntryPoint("EECAF300")
      ExecBlock("EECAF300",.F.,.F.,"VALIDA_ESTORNO_BAIXA")
   EndIf

   IF MSGNOYES(STR0023+STR0025,STR0026) //"Confirma o Estorno "###"da Baixa ?"###"Atenção"
      IF ! EMPTY(TMP->EEQ_DTVC) .And. !lEstParVC
         MSGINFO(STR0028,STR0026) //"FFC Com Variação Cambial. Estorno Cancelado "###"Atenção"
         BREAK
      ENDIF
      lRetEstBaixa := .T.
   ENDIF
END SEQUENCE

RETURN lRetEstBaixa

/*
Funcao      : AF300W().
Parametros  : cTratamento - Indica qual tratamento deverá ser realizado.
Retorno     : .t./.f.
Objetivos   : Controle para habilitar/desabilitar campo na tela de gets.
Autor       : Jeferson Barros Jr.
Data/Hora   : 25/08/04 14:31.
Obs.        :
*/
*---------------------------------*
Static Function Af300W(cTratamento)
*---------------------------------*
Local lRet := .t.

Begin Sequence

   If !EECFlags("FRESEGCOM") .Or. ( Empty(cEvent) .And. Empty(cTipo) )
      Break
   EndIf

   Do Case
      Case (cTratamento $ "IMPORT|IMPLOJA")

         If !IsReceita(cEvent) .And. (IsMemVar("cTipo") .And. cTipo <> "A")
            lRet := .f.
            cImport := Space(AvSx3("EEC_IMPORT",AV_TAMANHO))
            cLojaImp:= Space(AvSx3("EEC_IMLOJA",AV_TAMANHO))
            cNome   := Space(40)
         EndIf

      Case (cTratamento $ "FORN|FORNLOJA")

         If IsReceita(cEvent) .Or. (IsMemVar("cTipo") .And. cTipo == "A")
            lRet      := .f.
            cFornec   := Space(AvSx3("EEC_FORN",AV_TAMANHO))
            cLojaFor  := Space(AvSx3("EEC_FOLOJA",AV_TAMANHO))
            cNomeForn := Space(40)
         EndIf

   EndCase

End Sequence

Return lRet

/*
Função   :Ex300F3
Autor    :Lucas Rolim Rosa Lopes
Data     :20/12/04
Objetivo :F3 caso o Usuario possa visualisar outras filiais
*/
*--------------------------------------------------*
Function AF300F3(nTipo,Nopc)
*--------------------------------------------------*
Local lRet := .F.
Local oDlg,oGetDD,i
Local nRecEEQ  := EEQ->(Recno())
Local nRecEEC  := EEC->(Recno())
Private cCadastro := If (nTipo == 1 ,"FFC",If (nTipo==2,STR0117,"Invoice"))//STR0117	"Processo"
Default nOpc := 1
Private aROTINA   := {{"","",0,1}}
Private aHeader
Private aCols
aHeader:={}
aCols := {}
Do Case
   Case nTipo == 1 //FFC
      Aadd(aHeader,{AVSX3("EEQ_FFC"   ,5), "FFC" ,AVSX3("EEQ_FFC"   ,6), AVSX3("EEQ_FFC",3),AVSX3("EEQ_FFC",4),"",nil, AVSX3("EEQ_FFC",2),nil,nil })
      Aadd(aHeader,{AVSX3("EEQ_PREEMB",5), "EMB" ,AVSX3("EEQ_PREEMB",6), AVSX3("EEQ_PREEMB",3),AVSX3("EEQ_PREEMB",4),"",nil, AVSX3("EEQ_PREEMB",2),nil,nil })
      Aadd(aHeader,{AVSX3("EEQ_PARC"  ,5), "PAR" ,AVSX3("EEQ_PARC"  ,6), AVSX3("EEQ_PARC"  ,3),AVSX3("EEQ_PARC"  ,4),"",nil, AVSX3("EEQ_PARC"  ,2),nil,nil })
      Aadd(aHeader,{AVSX3("EEQ_VCT"   ,5), "VCT" ,AVSX3("EEQ_VCT"   ,6), AVSX3("EEQ_VCT"   ,3),AVSX3("EEQ_VCT"   ,4),"",nil, AVSX3("EEQ_VCT"   ,2),nil,nil })
      EEQ->(DbGoTop())
      For i:=1 To Len(aFiliais)
         If EEQ->(DbSeek(aFiliais[i]))
            Do While !EEQ->(EOF())  .And. EEQ->EEQ_FILIAL == aFiliais[i]
               If aScan(aCols,{|x| x[1] == EEQ->EEQ_FFC }) == 0
                  Aadd(aCols,Array(Len(aHeader)+1))
                  GDFieldPut("FFC",EEQ->EEQ_FFC,Len(aCols))
                  GDFieldPut("EMB",EEQ->EEQ_PREEMB,Len(aCols))
                  GDFieldPut("PAR",EEQ->EEQ_PARC,Len(aCols))
                  GDFieldPut("VCT",EEQ->EEQ_VCT,Len(aCols))
               EndIf
               EEQ->(DbSkip())
            EndDo
         EndIf
      Next
   Case nTipo == 2 //Processo
      Aadd(aHeader,{AVSX3("EEC_PREEMB",5), "EMB" ,AVSX3("EEC_PREEMB",6), AVSX3("EEC_PREEMB",3),AVSX3("EEC_PREEMB",4),"",nil, AVSX3("EEC_PREEMB",2),nil,nil })
      Aadd(aHeader,{AVSX3("EEC_DTPROC",5), "DTP" ,AVSX3("EEC_DTPROC",6), AVSX3("EEC_DTPROC",3),AVSX3("EEC_DTPROC",4),"",nil, AVSX3("EEC_DTPROC",2),nil,nil })
      Aadd(aHeader,{AVSX3("EEC_STTDES",5), "STT" ,AVSX3("EEC_STTDES",6), AVSX3("EEC_STTDES",3),AVSX3("EEC_STTDES",4),"",nil, AVSX3("EEC_STTDES",2),nil,nil })

      For i:=1 To Len(aFiliais)
         If EEC->(DbSeek(aFiliais[i]))
            Do While !EEC->(EOF())  .And. EEC->EEC_FILIAL == aFiliais[i]
               If aScan(aCols,{|x| x[1] == EEC->EEC_PREEMB }) == 0
                  Aadd(aCols,Array(Len(aHeader)+1))
                  GDFieldPut("EMB",EEC->EEC_PREEMB   ,Len(aCols))
                  GDFieldPut("DTP",EEC->EEC_DTPROC   ,Len(aCols))
                  GDFieldPut("STT",EEC->EEC_STTDES   ,Len(aCols))
               EndIf
            EEC->(DbSkip())
            EndDo
         EndIf
      Next
   Case nTipo == 3 //Invoice
      Aadd(aHeader,{AVSX3("EEQ_PREEMB",5), "EMB" ,AVSX3("EEQ_PREEMB",6), AVSX3("EEQ_PREEMB",3),AVSX3("EEQ_PREEMB",4),"",nil, AVSX3("EEQ_PREEMB",2),nil,nil })
      Aadd(aHeader,{AVSX3("EEQ_NRINVO",5), "INV" ,AVSX3("EEQ_NRINVO",6), AVSX3("EEQ_NRINVO",3),AVSX3("EEQ_NRINVO",4),"",nil, AVSX3("EEQ_NRINVO",2),nil,nil })
      Aadd(aHeader,{AVSX3("EEQ_PARC"  ,5), "PAR" ,AVSX3("EEQ_PARC"  ,6), AVSX3("EEQ_PARC"  ,3),AVSX3("EEQ_PARC"  ,4),"",nil, AVSX3("EEQ_PARC"  ,2),nil,nil })
      Aadd(aHeader,{AVSX3("EEQ_VCT"   ,5), "VCT" ,AVSX3("EEQ_VCT"   ,6), AVSX3("EEQ_VCT"   ,3),AVSX3("EEQ_VCT"   ,4),"",nil, AVSX3("EEQ_VCT"   ,2),nil,nil })
      EEQ->(DbGoTop())
      For i:=1 To Len(aFiliais)
         If EEQ->(DbSeek(aFiliais[i]))
            Do While !EEQ->(EOF())  .And. EEQ->EEQ_FILIAL == aFiliais[i]
               If aScan(aCols,{|x| x[1] == EEQ->EEQ_NRINVO }) == 0 .AND. EEQ->EEQ_EVENT == "101"
                  Aadd(aCols,Array(Len(aHeader)+2))
                  GDFieldPut("INV",EEQ->EEQ_NRINVO ,Len(aCols))
                  GDFieldPut("EMB",EEQ->EEQ_PREEMB ,Len(aCols))
                  GDFieldPut("PAR",EEQ->EEQ_PARC   ,Len(aCols))
                  GDFieldPut("VCT",EEQ->EEQ_VCT    ,Len(aCols))
                  aCols[Len(aCols),5] := EEQ->EEQ_FILIAL
               EndIf
            EEQ->(DbSkip())
            EndDo
         EndIF
      Next
EndCase
DEFINE MSDIALOG oDlg TITLE cCadastro FROM 10,10 TO 285,450 OF oMainWnd  PIXEL
    
    oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //LRS - 27/09/2018
    oPanel:Align:= CONTROL_ALIGN_TOP 

    oGetDD := MsGetDados():New(13,000,120,230,nOpc,"",   ,  ,.f.,      ,nil,.t.,1500,"",nil,nil,,oPanel)
    oGetDD:oBrowse:BLDBLCLICK:={|| lRet:=.T.,oDlg:End()}
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lRet:= .T. , oDlg:End()},{||oDlg:End()},,) CENTERED
If lRet
   Do Case
      Case nTipo == 1
         cFFC := GDFieldGet("FFC", n )
      Case nTipo == 2
         cProc    := GDFieldGet("EMB", n)
      Case nTipo == 3
         cInvoice := GDFieldGet("INV",n)
   EndCase
EndIf

Return lRet

*--------------------------------------------------------------------------------------------------------*
Static Function GrvArrayEEQ()
*--------------------------------------------------------------------------------------------------------*
Local nValTot:=0, nPos, nVlControle:=0, ni

nVlControle:=0
Do While !EF3->(EoF()) .and. EF3->EF3_FILIAL+If(lEFFTpMod,EF3->EF3_TPMODU,"") == xFilial("EF3")+If(lEFFTpMod,If(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),"") .and. EF3->EF3_INVOIC == TMP->EEQ_NRINVO .and.;  //HVR 08/03/2006 - Incluido no indice o campo EF3_TPMODU
   EF3->EF3_PARC == If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN) .and.;
   EF3->EF3_CODEVE == EV_EMBARQUE// .and. nValTot < TMP->EEQ_VL

   If (nPos:=aScan(aArrayEEQ,{|x| x[16]==EF3->(RecNo())})) > 0
      For ni:=nPos to Len(aArrayEEQ)
         nVlControle += aArrayEEQ[ni,1]
      Next ni
   EndIf

   If nVlControle < EF3->EF3_VL_INV
      //aAdd(aArrayEEQ,{EF3->EF3_VL_MOE,EF3->EF3_BAN_FI,TMP->EEQ_PARC,EF3->EF3_PRACA,EF3->EF3_CONTRA,,,nSeqAux})
      aAdd(aArrayEEQ,{(EF3->EF3_VL_INV-nVlControle),TMP->EEQ_VCT,EF3->EF3_PARC,EF3->EF3_DT_FIX,EF3->EF3_CONTRA,;
                      EF3->EF3_SEQ,If(!Empty(EF3->EF3_NR_CON) , "1" , "2" ),nSeqAux,TMP->EEQ_PREEMB, EF3->EF3_DT_EVE, EF3->EF3_TX_MOE, "", TMP->EEQ_PARFIN,;
                      If(lTemChave, EF3->EF3_BAN_FI, ""), Iif(lTemChave, EF3->EF3_PRACA, ""),EF3->(RecNo()),(EF3->EF3_VL_INV-nVlControle),;  //HVR 08/03/2006 - Incluido no indice o campo EF3_SEQCNT
                      .F.,If(!lPrepag .or. Left(EF3->EF3_EV_VIN,2)==Left(EV_PRINC_PREPAG,2), "1", "2"),TMP->(RecNo()),.F., IF(lEFFTpMod,EF3->EF3_SEQCNT,"")}) //HVR 08/03/2006 - Adicionado Sequencia do COntrato
      nSeqAux += 1
      nValTot += (EF3->EF3_VL_INV-nVlControle)
   EndIf
   nVlControle := 0
   EF3->(dbSkip())
EndDo

Return .T.

/*
Função     : SeqCodFFC
Objetivos  : Controlar numeração de FFC
Parâmetros : lCancel - Cancela uso da sequência, cFFCSeq - Sequência a ser cancelada
Retorno    : xRet - Nil se lCancel = .T., Caractere se lCancel = .F.
Autor      : Rodrigo Mendes Diaz
Data       : 18/10/2006
*/
Static Function SeqCodFFC(lCancel, cFFCSeq)
Local xRet := Nil
Local nFFCSeq := 0
Local aOrd, cFilter
Default lCancel := .F.
Default cFFCSeq := "0"

Begin Sequence

   If Val(EasyGParam("MV_AVG0126",,"0")) <= 1
      If lCancel
         RollBackSxE()
      Else
         xRet := EasyGetMVSeq("MV_AVG0126")
      EndIf
   Else
      If lCancel//Caso a sequência não tenha sido utilizada, verifica se a sequencia não foi incrementada por outra rotina,
               //caso negativo, retorna à sequência anterior.
         If Val(cFFCSeq) = 0
            Break
         EndIf
         If cFFCSeq == EasyGParam("MV_AVG0126",,"0")
            SetMV("MV_AVG0126", StrZero(Val(cFFCSeq) - 1, AvSx3("EEQ_FFC", AV_TAMANHO)))
         EndIf
      Else
         //Caso o parâmetro não possua a sequência correta, busca na tabela EEQ
         If Val(EasyGParam("MV_AVG0126",,"0")) == 0
            aOrd := SaveOrd("EEQ")
            cFilter := EEQ->(DbFilter())
            EEQ->(DbClearFilter())
            EEQ->(DbGoTop())
            If EEQ->(!Eof())
               nFFCSeq := Val(EEQ->EEQ_FFC)
               While EEQ->(!Eof())
                  If Val(EEQ->EEQ_FFC) > nFFCSeq
                     nFFCSeq := Val(EEQ->EEQ_FFC)
                  EndIf
                  EEQ->(DbSkip())
               EndDo
               If nFFCSeq > 0
                  SetMV("MV_AVG0126", StrZero(nFFCSeq, AvSx3("EEQ_FFC", AV_TAMANHO)))
               EndIf
            EndIf
            If Len(AllTrim(cFilter)) > 0
               EEQ->(DbSetFilter(cFilter))
            EndIf
            RestOrd(aOrd, .T.)
         EndIf

         nFFCSeq := Val(EasyGParam("MV_AVG0126",,"0")) + 1
         SetMV("MV_AVG0126", StrZero(nFFCSeq, AvSx3("EEQ_FFC", AV_TAMANHO)))
         xRet := StrZero(nFFCSeq, AvSx3("EEQ_FFC", AV_TAMANHO))
      EndIf
   EndIf

End Sequence

Return xRet

/*
Função     : AF300DesvParc
Objetivos  : Desvincular parcelas da FFC
Parâmetros : Nenhum
Retorno    : lSairTela - .T. - Sai da manutenção de FFC
                         .F. - Não sai da manutenção
Autor      : Rodrigo Mendes Diaz
Data       : 02/01/2006
*/
*----------------------*
Function AF300DesvParc()
*----------------------*
Local nRecnoTMP := TMP->(Recno())

Local aButtons    := {},;
      aCposBrowse := aClone(aCampoTMP),;
      aFilter

Local bOk        := {|| If(AF300ValDesv("BOK"), (lOk := .T., oDlg:End()),) },;
      bCancel    := {|| oDlg:End() },;
      bMark      := {|| TMP->(If(Empty(WK_DEFLAG), If(AF300ValDesv("MARK"), WK_DEFLAG := cMarca, ), WK_DEFLAG := Space(2))) }

Local oDlg

Local lInverte  := .F.,;
      lOk       := .F.,;
      lSairTela := .F.,;
      lOkMark   := .F.

Private cMarca := GetMark()

Begin Sequence

   TMP->(DbGoTop())
   aAdd(aCposBrowse, Nil)
   aIns(aCposBrowse, 1)
   aCposBrowse[1] := {"WK_DEFLAG","","  "}

   DEFINE MSDIALOG oDlg TITLE STR0085 FROM DLG_LIN_INI+(DLG_LIN_FIM/4),DLG_COL_INI+(DLG_COL_FIM/4);//"Selecione as parcelas que serão desvinculadas"
                                        TO DLG_LIN_FIM-(DLG_LIN_FIM/4),DLG_COL_FIM-(DLG_COL_FIM/5);
                                        OF oMainWnd PIXEL
      aPos := PosDlg(oDlg)

      oMsSelect := MsSelect():New("TMP", "WK_DEFLAG",, aCposBrowse, @lInverte, @cMarca, PosDlg(oDlg))
      oMsSelect:bAval := bMark

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

   If lOk
      //Filtra a work para tratar somente as parcelas marcadas
      aFilter := EECSaveFilter("TMP")
      TMP->(DbClearFilter())
      TMP->(DbSetFilter({|| TMP->WK_DEFLAG == cMarca }, "TMP->WK_DEFLAG == cMarca"))

      //Efetua desvinculação utilizando as mesmas rotinas do estorno de FFC
      If !Empty(TMP->EEQ_PGT)
         //Efetua estorno da baixa das parcelas marcadas
         AF300ESTB(.F.,.T.)
         MsAguarde({|| AF300C(lLiq)}, STR0014) //"Aguarde"
         TMP->(DbGoTop())
         //Desvincula as parcelas marcadas
         AF300ESTB(.T., .T.)
         MsAguarde({|| AF300C(lLiq)}, STR0014) //"Aguarde"
      Else
         //Desvincula as parcelas marcadas
         AF300ESTB(.T., .T.)
         MsAguarde({|| AF300C(lLiq)}, STR0014) //"Aguarde"
      EndIf

      //Retira as parcelas marcadas da Work, restaura o filtro se existir e atualiza o valor total da FFC
      TMP->(DbGoTop())
      TMP->(dbEval({|| If(!Empty(WK_DEFLAG), (nTotal -= EEQ_VL, nSaldo -= EEQ_VL, DbDelete()),) },, {|| !Eof() }))
      TMP->(DbClearFilter())
      EECRestFilter(aFilter)
      TMP->(DbGoTop())
      //Se o usuário desvincular todas as parcelas da FFC, a função retorna .T., para que o sistema feche a tela de manutenção da FFC
      //caso contrário, função retorna .F. e o sistema continua na manutenção da FFC.
      If IsVazio("TMP")
         MsgInfo(STR0087, STR0036)//"Todas as parcelas foram desvinculadas. A FFC foi excluída do sistema." ### "Aviso"
         lSairTela := .T.
      EndIf
   Else
      //Retira a marca dos itens
      TMP->(DbGoTop())
      TMP->(dbEval({|| If(!Empty(WK_DEFLAG), WK_DEFLAG := Space(2),) },, {|| !Eof() }))
      TMP->(DbGoTo(nRecnoTMP))
   EndIf
   oMSelect:oBrowse:Refresh()

End Sequence

Return lSairTela

/*
Função     : AF300ValDesv
Objetivos  : Validações da desvinculação de parcelas
Parâmetros : cVal - Identificação da validação
Retorno    : lRet
Autor      : Rodrigo Mendes Diaz
Data       : 02/01/2006
*/
*---------------------------------*
Static Function AF300ValDesv(cVal)
*---------------------------------*
Local lRet := .T., lOkParc := .F.
Local nRecno := TMP->(Recno())

Begin Sequence

   Do Case
      Case cVal == "MARK"
         If !Empty(TMP->EEQ_DTVC) .And. !lEstParVC
            MsgInfo(STR0088 ,STR0026)//"Parcela com variação cambial. Não será possível desvincular." ### "Atenção"
            lRet := .F.
            Break
         EndIf

      Case cVal == "BOK"
         TMP->(DbGoTop())
         While TMP->(!Eof())
            If !Empty(TMP->WK_DEFLAG)
               lOkParc := .T.
               //Verifica se possui parcela com baixa
               If !Empty(TMP->EEQ_PGT)
                  If !MsgYesNo(STR0086, STR0036)//"A FFC possui baixa. Para desvincular, a baixa das parcelas marcadas será estornada. Deseja prosseguir?" ### "Aviso"
                     lRet := .F.
                     Break
                  Else
                     Exit
                  EndIf
               EndIf
            EndIf
            TMP->(DbSkip())
         EndDo
         If !lOkParc
            MsgInfo(STR0090 ,STR0026)//"Selecione ao menos uma parcela para desvincular." ### "Atenção"
            lRet := .F.
            Break
         EndIf

         If !MsgYesNo(STR0089, STR0036)//"Confirma o estorno das parcelas? Esta operação não poderá ser desfeita." ### "Aviso"
            lRet := .F.
            Break
         EndIf

      End Case

End Sequence

TMP->(DbGoTo(nRecno))

Return lRet

/*
Função     : AF300BXG()
Objetivos  : Efetuar a baixa gerencial nas parcelas da FFC
Parâmetros : Nenhum
Retorno    : Nenhum
Autor      : Rodrigo Mendes Diaz
Data       : 26/11/07
*/
Static Function AF300BXG()
Local aOrd := SaveOrd("TMP")
Local lOk := .F.
Local bOk := {|| If(ValidBxg(lEstorno), (lOk := .T., oDlg:End()),) },;
      bCancel := {|| oDlg:End() }
Local oDlg
//Local aCampos /*, aAltera*/ //FSM - 14/11/2012

Local lEstorno := .T. // ** JPM - 06/01/2010 - Estorno da baixa gerencial

Private aGets, aTela, lLoop, aAltera , aCamposBx
      
Begin Sequence

   If !Empty(AF200DtBaixa("TMP"))//!Empty(TMP->EEQ_PGT)
      MsgInfo(STR0118, STR0026) //STR0118	"Não é possível efetuar/alterar a baixa gerencial porque a FFC está liquidada." //STR0026  	"Atenção"
      Break
   EndIf

   // ** JPM - 07/01/2010 - Verifica se existe alguma parcela que ainda não tenha baixa gerencial.
   TMP->(DbGoTop())
   While TMP->(!EoF())
      If Empty(TMP->EEQ_DTCE)
         lEstorno := .F.
         Exit
      EndIf
      TMP->(DbSkip())
   EndDo

   If lEstorno
      TMP->(DbGoTop())
   EndIf
   
   aCamposBx := {"EEQ_DTCE", "EEQ_CONTMV", "EEQ_BCOEXT", "EEQ_CNTEXT", "EEQ_AGCEXT", "EEQ_NBCEXT"}
   
   // ** JPM - 06/01/2009 - Estorno da baixa gerencial
   If lEstorno
      aAltera := {}
   Else
      aAltera := {"EEQ_DTCE", "EEQ_CONTMV", "EEQ_BCOEXT", "EEQ_CNTEXT", "EEQ_AGCEXT", "EEQ_NBCEXT"}
   EndIf

   /* JPM - 11/12/2009 - A ordem de pagamento deve ser preenchida por parcela.
   //** AAF 04/03/08 - Numero da Ordem de Pagamento
   aAdd(aCampos,"EEQ_NROPAG")
   aAdd(aAltera,"EEQ_NROPAG")
   //**
   */

   //OAP - Inclusão dos campos criados pelo usuário, assim os mesmos poderam ser alteraveis quando chamados.
   //aAltera := AddCpoUser(aAltera,"EEQ","1")                          
   //aAdd(aCampos,"NOUSER")
   
   RegToMemory("TMP", .F., .F., .F.)

   If EasyEntryPoint("EECAF300")
      ExecBlock("EECAF300",.F.,.F., "AF300BXG_ANTES_TELA")
   Endif

   DEFINE MSDIALOG oDlg TITLE STR0119 FROM 0,0 TO 400,600 OF oMainWnd PIXEL //STR0119	"Baixa Gerencial"

      EnChoice("EEQ", 0, ALTERAR,,,,aCamposBx, PosDlg(oDlg), aAltera)

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bOk, bCancel) CENTERED

   If lOk
      If lEstorno
         // ** JPM - 06/01/2009 - Estorno da baixa gerencial
         If EasyEntryPoint("EECAF300")
            ExecBlock("EECAF300",.F.,.F.,{"PE_EST_BAIXA_GERENCIAL_INI"})
         Endif

         TMP->(DbGoTop())
         While TMP->(!Eof())
            lLoop := .F.

            If EasyEntryPoint("EECAF300")
               ExecBlock("EECAF300",.F.,.F.,{"PE_EST_BAIXA_GERENCIAL_LOOP"})
            Endif

            If lLoop
               TMP->(DbSkip())
               Loop
            EndIf

            TMP->EEQ_DTCE := AvCToD("")
            TMP->(DbSkip())
         EndDo

         If EasyEntryPoint("EECAF300")
            ExecBlock("EECAF300",.F.,.F.,{"PE_EST_BAIXA_GERENCIAL_FIM"})
         Endif

      Else
         TMP->(DbGoTop())
         While TMP->(!Eof())
            // ** JPM - Só faz a baixa gerencial das que não tinham ainda.
            If Empty(TMP->EEQ_DTCE)
               aEval(aAltera, {|x| Eval(FieldWBlock(x, Select("TMP")), Eval(MemVarBlock(x))) })
            EndIf
            TMP->(DbSkip())
         EndDo
      EndIf
   EndIf

End Sequence

RestOrd(aOrd, .T.)
Return lOk

/*
Função     : ValidBxg()
Objetivos  : Validar a baixa gerencial
Parâmetros : Nenhum
Retorno    : lRet
Autor      : Rodrigo Mendes Diaz
Data       : 26/11/07
*/
Static Function ValidBxg(lEstorno)

Local aOrd := SaveOrd("TMP")
//Local lRet := .T.
// ** JPM - private para ser acessado pelo ponto de entrada
Private lRetBxg := .T.

Begin Sequence
   // ** JPM - 06/01/2010 - Estorno da baixa gerencial
   If lEstorno
      If !MsgYesNo(STR0120,STR0026)//STR0120	"Deseja realmente estornar a baixa gerencial desta FFC?" //STR0026  "Atenção"
         lRetBxg := .F.
         Break
      EndIf

      If EasyEntryPoint("EECAF300")
         ExecBlock("EECAF300",.F.,.F.,{"PE_EST_BAIXA_GERENCIAL_FIM_VALIDACAO"})
      Endif

   Else
      // ** JPM - 13/01/2010
      If Empty(M->EEQ_DTCE)
         MsgInfo(STR0121,STR0026)//STR0121	"Para efetuar a baixa gerencial, a data de crédito no exterior deve ser preenchida." //#define	STR0026  	"Atenção"
         lRetBxg := .F.
         Break
      EndIf

      If (EEQ->( FieldPos("EEQ_BCOEXT") ) > 0 .And. !Empty(M->EEQ_BCOEXT)) .Or. !Empty(M->EEQ_CNTEXT) .Or. !Empty(M->EEQ_AGCEXT)
         If EEQ->( FieldPos("EEQ_BCOEXT") ) > 0 .And. !(lRetBxg := SA6->(DbSeek(xFilial()+M->(EEQ_BCOEXT+EEQ_AGCEXT+EEQ_CNTEXT))))
            MsgInfo(STR0122 + ENTER + STR0123, STR0016)//"Aviso" //STR0122	"A conta informada não existe no cadastro de bancos." //STR0123	"Escolha uma conta válida."
            Break
         EndIf
      EndIf
      If M->EEQ_CONTMV $ cSim
         If (EEQ->( FieldPos("EEQ_BCOEXT") ) > 0 .And. Empty(M->EEQ_BCOEXT)) .Or. Empty(M->EEQ_CNTEXT) .Or. Empty(M->EEQ_AGCEXT)
            MsgInfo(STR0124, STR0026) //STR0124	"Favor informar todos os dados do banco no exterior." //STR0026 "Atenção"
            lRetBxg := .F.
            Break
         EndIf
         If !(lRetBxg := SA6->A6_MOEEASY == M->EEQ_MOEDA)
            MsgInfo(STR0125 + ENTER + STR0126, STR0026)//STR0125	"A moeda da conta escolhida é diferente da moeda da FFC." //STR0126	"Escolha uma conta na mesma moeda da FFC." ////STR0026 "Atenção"
            Break
         EndIf
      EndIf
      // ** JPM 07/01/2010 - se alguma parcela tiver baixa gerencial, avisa o usuário
      TMP->(DbGoTop())
      While TMP->(!EoF())
         If !Empty(TMP->EEQ_DTCE)
            If !MsgYesNo(STR0127+; //	STR0127	"Existem parcelas que já possuem baixa gerencial. Se continuar, o sistema apenas fará a baixa gerencial "
                         STR0128,STR0026) //STR0128	"das parcelas que ainda não a possuem. Deseja continuar?" //STR0026  	"Atenção"
               lRetBxg := .F.
               Break
            EndIf
            Exit
         EndIf
         TMP->(DbSkip())
      EndDo

      If EasyEntryPoint("EECAF300")
         ExecBlock("EECAF300",.F.,.F.,{"PE_BAIXA_GERENCIAL_FIM_VALIDACAO"})
      Endif

   EndIf

End Sequence

RestOrd(aOrd,.T.)

Return lRetBxg

/*
Função      : AF300AtualTit()
Objetivo    : Atualizar os títulos no módulo SigaFin quando houver liquidação de adiantamentos
              pós embarque
Parametro   : Array com os processos que devem ser alterados
Retorno     : .T. se a integração foi realizada com sucesso
              .F. se a integração não foi realizada
Autor       : Wilsimar Fabrício
Data e Hora : 17/08/11
*/
Static Function AF300AtualTit(aEmbarques)
Local aOrd:= SaveOrd("EEQ")
Local lRet:= .T.
Local nCont
Local aRecNo:= {}

Begin Sequence

   EEQ->(DBSetOrder(1))
   For nCont:= 1 To Len(aEmbarques)

      EEQ->(DBSeek(xFilial() + aEmbarques[nCont]))

      While EEQ->(!Eof()) .And. EEQ->EEQ_FILIAL == EEQ->(xFilial()) .And.;
            EEQ->EEQ_PREEMB == aEmbarques[nCont]

         If EEQ->EEQ_EVENT == "101" .And. EEQ->EEQ_TIPO == "R"
            AAdd(aRecNo, EEQ->(RecNo()))
         EndIf

         EEQ->(DBSkip())
      EndDo

   Next

   If Len(aRecNo) > 0
      If !AF200AtualTit(aRecNo)
         lRet:= .F.
      EndIf
   EndIf

End Sequence

RestOrd(aOrd, .T.)
Return lRet

Static Function AF300Registro()
Local cQry:="", cFrom:="", cCmd:=""
Local i
Local aFil  := AClone(aFiliais)
Local xcFil := cFilAnt
Local bCond
Local cChave:=""
Local nOrdem := 0
Local nTipCon
Private cWhere := ""
If lIntFina .and. lFinanciamento
   EF3->(dbSetOrder(3))
EndIf

IF lFFC

   #IFDEF TOP

      cQry   := "Select EEQ.R_E_C_N_O_ AS RECNO,  EEQ.EEQ_IMPORT AS EEQ_IMPORT  "
      cFrom  := "From "+RetSqlName("EJY")+" EJY, "+RetSqlName("EEQ")+" EEQ "+If(!Empty(cNrOpSq),", "+RetSqlName("EF3")+" EF3 ","")
      cWhere := "Where EJY.D_E_L_E_T_ <> '*' And EJY.EJY_FILIAL IN ("+cFil+") "

      If !Empty(cProc)
         cWhere += " And EEQ.EEQ_PREEMB Like '%" +If(cTipCon=="3","V","A")+AllTrim(cProc) + "%' "
      EndIf

      If !Empty(cBanco)
         cWhere += " And EEQ.EEQ_BANC = '"+AllTrim(cBanco)+"' "
         cWhere += " And EEQ.EEQ_AGEN = '"+AllTrim(cAGEN)+"' "
         cWhere += " And EEQ.EEQ_NCON = '"+AllTrim(cNCON)+"' "
      EndIf

      cWhere += " And EEQ.D_E_L_E_T_ <> '*' And EEQ_FILIAL IN ("+cFil+") "
      cWhere += " And EEQ.EEQ_FFC = '"+Space(Avsx3("EEQ_FFC",AV_TAMANHO))+"'"+;
                " And EEQ.EEQ_PGT = '        ' "

      IF lFFCIMP
         cWhere += " And EEQ.EEQ_FFCIMP = '"+Space(Avsx3("EEQ_FFCIMP",AV_TAMANHO))+"' "
      ENDIF

      If !Empty(cNrOp)
         cWhere += "AND EEQ.EEQ_NROP = '"+cNrOp+"' "
      EndIf

      If !Empty(cNrOpSq)
         cWhere += "AND EF3.EF3_FILIAL = '"+xFilial("EF3")+"' "
         cWhere += "AND EF3.EF3_SEQCNT = '"+cNrOpSq+"' "
         cWhere += "AND EF3.EF3_CONTRA = '"+cNrOp+"' AND EF3.EF3_CODEVE = '600' "
         cWhere += "AND EEQ.EEQ_NRINVO = EF3.EF3_INVOIC AND EEQ.EEQ_PARC = EF3.EF3_PARC "
      EndIf

      If !Empty(dVenctI)
         cWhere += " And EEQ.EEQ_VCT >= '" + DtoS(dVenctI)+"' "
      EndIf

      If !Empty(dVenctF)
         cWhere += " And EEQ.EEQ_VCT <= '" + DtoS(dVenctF)+"' "
      EndIf

      If lOkEvent
         If !Empty(cInvoice)
            cWhere += " And EEQ.EEQ_NRINVO = '"+AllTrim(cInvoice)+"' "
         EndIf

         If EECFlags("FRESEGCOM")
            If !Empty(cEvent)
               cWhere += " And EEQ.EEQ_EVENT = '"+cEvent+"' "
            EndIf
         EndIf
      EndIf

      If EECFlags("FRESEGCOM")
         If !Empty(cImport)
            cWhere += " And EEQ.EEQ_IMPORT = '"+AllTrim(cImport)+"' "
         EndIf

         If !Empty(cFornec)
            cWhere += " And EEQ.EEQ_FORN = '"+AllTrim(cFornec)+"' "
         EndIf

         If !Empty(cMoeda)
            cWhere += " And EEQ.EEQ_MOEDA = '"+AllTrim(cMoeda)+"' "
         EndIf
      EndIf

      If EEQ->( FieldPos("EEQ_TP_CON") ) > 0
         If !Empty(cTipCon)
            cWhere += " And EEQ.EEQ_TP_CON = '"+Left(cTipCon,1)+"' "
         Else
            cWhere += " And EEQ.EEQ_TP_CON = '1' "
         EndIf
      EndIf

      If EEQ->( FieldPOs("EEQ_TIPO") ) > 0 .AND. !Empty(cTipo)
         cWhere += " And EEQ.EEQ_TIPO = '"+Left(cTipo,1)+"' "
      EndIf

      cWhere += " And EEQ.EEQ_FASE <> 'F' " //THTS - 29/08/2017 - Adiantamento de Fornecedores nao podem ser utilizados pra FFC

      If EasyEntryPoint("EECAF300")
         ExecBlock("EECAF300",.F.,.F.,{"AF300_QRY"})
      EndIf

      cCmd := (cQry+cFrom+cWhere)

      If EEQ->( FieldPos("EEQ_TP_CON") ) > 0 .And. ( Empty(cTipCon)  .Or.  cTipCon $ "3/4" )
         cQry   := ""
         cFrom  := ""
         cWhere := ""

         cQry   := " UNION Select EEQ.R_E_C_N_O_ AS RECNO, EEQ.EEQ_IMPORT AS EEQ_IMPORT "
         cFrom  := "From "+RetSqlName("EEQ")+" EEQ "+If(!Empty(cNrOpSq),", "+RetSqlName("EF3")+" EF3 ","")
         cWhere := "Where EEQ.D_E_L_E_T_ <> '*' And EEQ.EEQ_FILIAL IN ("+cFil+") "

         If !Empty(cProc)
            cWhere += " And EEQ.EEQ_PREEMB Like '%" +If(cTipCon=="3","V","A")+AllTrim(cProc) + "%'"
         EndIf

         cWhere += " And EEQ.EEQ_FFC = '"+Space(Avsx3("EEQ_FFC",AV_TAMANHO))+"'"+;
                   " And EEQ.EEQ_PGT = '        ' "

         IF lFFCIMP
            cWhere += " And EEQ.EEQ_FFCIMP = '"+Space(Avsx3("EEQ_FFCIMP",AV_TAMANHO))+"' "
         ENDIF

         If !Empty(cNrOp)
            cWhere += "AND EEQ.EEQ_NROP = '"+cNrOp+"' "
         EndIf

         If !Empty(cNrOpSq)
            cWhere += "AND EF3.EF3_FILIAL = '"+xFilial("EF3")+"' "
            cWhere += "AND EF3.EF3_SEQCNT = '"+cNrOpSq+"' "
            cWhere += "AND EF3.EF3_CONTRA = '"+cNrOp+"' AND EF3.EF3_CODEVE = '600' "
            cWhere += "AND EEQ.EEQ_NRINVO = EF3.EF3_INVOIC AND EEQ.EEQ_PARC = EF3.EF3_PARC "
         EndIf

         If !Empty(dVenctI)
            cWhere += " And EEQ.EEQ_VCT >= '" + DtoS(dVenctI)+"' "
         EndIf
         If !Empty(dVenctF)
            cWhere += " And EEQ.EEQ_VCT <= '" + DtoS(dVenctF)+"' "
         EndIf

         If lOkEvent
            If !Empty(cInvoice)
               cWhere += " And EEQ.EEQ_NRINVO = '"+AllTrim(cInvoice)+"' "
            EndIf

            If EECFlags("FRESEGCOM")
               If !Empty(cEvent)
                  cWhere += " And EEQ.EEQ_EVENT = '"+cEvent+"' "
               EndIf
            EndIf
         EndIf

         If EECFlags("FRESEGCOM")
            If !Empty(cImport)
               cWhere += " And EEQ.EEQ_IMPORT = '"+AllTrim(cImport)+"' "
            EndIf

            If !Empty(cFornec)
               cWhere += " And EEQ.EEQ_FORN = '"+AllTrim(cFornec)+"' "
            EndIf

            If !Empty(cMoeda)
               cWhere += " And EEQ.EEQ_MOEDA = '"+AllTrim(cMoeda)+"' "
            EndIf
         EndIf

         If !Empty(cBanco)
            cWhere += " And EEQ.EEQ_BANC = '"+AllTrim(cBanco)+"' "
            cWhere += " And EEQ.EEQ_AGEN = '"+AllTrim(cAGEN)+"' "
            cWhere += " And EEQ.EEQ_NCON = '"+AllTrim(cNCON)+"' "
         EndIf

         If EEQ->( FieldPos("EEQ_TP_CON") ) > 0
            If !Empty(cTipCon)
               cWhere += " And EEQ.EEQ_TP_CON = '"+Left(cTipCon,1)+"' "
            Else
               cWhere += " And EEQ.EEQ_TP_CON IN ('3','4') "
            EndIf
         EndIf

         If EEQ->( FieldPOs("EEQ_TIPO") ) > 0 .AND. !Empty(cTipo)
            cWhere += " And EEQ.EEQ_TIPO = '"+Left(cTipo,1)+"' "
         EndIf

         cWhere += " And EEQ.EEQ_FASE <> 'F' " //THTS - 29/08/2017 - Adiantamento de Fornecedores nao podem ser utilizados pra FFC

         If EasyEntryPoint("EECAF300")
            ExecBlock("EECAF300",.F.,.F.,{"AF300_QRY3/4"})
         EndIf

         cCmd += (cQry+cFrom+cWhere)
      EndIf

      cCmd := ChangeQuery(cCmd)
      DbUseArea(.t., "TOPCONN", TCGENQRY(,,cCmd),"Qry",.f.,.t.)

      // ** Atualiza as informações no Tmp.
      Do While Qry->(!Eof())
         EEQ->(DbGoTo(Qry->RECNO))
         If lIntFina .and. lFinanciamento .and. (EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,If(EEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+EEQ->EEQ_NRINVO+EEQ->EEQ_PARC+EV_LIQ_PRC));   //HVR 08/03/2006 - Incluido no indice o campo EF3_TPMODU
         .or. EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,If(EEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+EEQ->EEQ_NRINVO+EEQ->EEQ_PARC+EV_LIQ_PRC_FC)))// .and. !Empty(EF3->EF3_NR_CON)    //HVR 08/03/2006 - Incluido no indice o campo EF3_TPMODU
            Qry->(dbSkip()) //AAF 03/05/2006 - Correção de Loop infinito devido a Skip no Alias EEQ.
            Loop
         EndIf
         Tmp->(DbAppend())
         RegToMemory("EEQ", .F.)
         AvReplace("EEQ","Tmp")
         TMP->EEQ_VLFCAM:= AF200VLFCam("EEQ", "ALT")                              //NCF - 11/04/2011
         TMP->TRB_ALI_WT:= "EEQ"
         TMP->TRB_REC_WT:= EEQ->(Recno())
         SA1->(DBSetOrder(1))
         //SA1->(DBSeek(xFilial()+Qry->EEC_IMPORT))
         SA1->(DBSeek(xFilial()+EEQ->EEQ_IMPORT))
         TMP->WK_Import := EEQ->EEQ_IMPORT + "-" + SA1->A1_NREDUZ//Qry->EEC_IMPORT + "-" + SA1->A1_NREDUZ
         TMP->A1_COD := EEQ->EEQ_IMPORT
         TMP->EEQ_FILORI := EEQ->EEQ_FILIAL + " - " + AvgFilName({EEQ->EEQ_FILIAL})[1]
         nTotal += TMP->EEQ_VL
         Qry->(DbSkip())
      EndDo
      //Qry->(DbCloseArea())
   #ENDIF

   If lOkEVENT
      aCAMPOTMP := {{"EEQ_FLAG","","  "}}
      If lMultiFil
          aAdd(aCampoTmp,{"EEQ_FILORI","","Filial"})
      EndIF
      aAdd(aCampoTmp,COLBRW("EEQ_EVENT","TMP"))
      aAdd(aCampoTmp,{"WK_IMPORT","","Importador"})
      aAdd(aCampoTmp,COLBRW("EEQ_PREEMB","TMP"))
      aAdd(aCampoTmp,COLBRW("EEQ_NRINVO","TMP"))
      aAdd(aCampoTmp,COLBRW("EEQ_PARC"  ,"TMP"))
      aAdd(aCampoTmp,COLBRW("EEQ_VCT"   ,"TMP"))
      aAdd(aCampoTmp,COLBRW("EEQ_VL"    ,"TMP"))
      aAdd(aCampoTmp,{{||TRANSF(TMP->EEQ_VLFCAM, '@E 999,999,999,999.99')},"",AVSX3("EEQ_VLFCAM",5) })
      aAdd(aCampoTmp,COLBRW("EEQ_NROP"  ,"TMP"))
      If EECFlags("FRESEGCOM")
         aAdd(aCampoTmp,COLBRW("EEQ_MOEDA" ,"TMP"))
         aAdd(aCampoTmp,COLBRW("EEQ_PARI"  ,"TMP"))
         aAdd(aCampoTmp,COLBRW("EEQ_CODEMP","TMP"))
         aAdd(aCampoTmp,COLBRW("EEQ_FORN"  ,"TMP"))
         aAdd(aCampoTmp,COLBRW("EEQ_FOLOJA","TMP"))
         aAdd(aCampoTmp,COLBRW("EEQ_TIPO"  ,"TMP"))

         If EEQ->( FieldPos("EEQ_TP_CON") ) > 0
            aAdd(aCampoTmp,COLBRW("EEQ_TP_CON","TMP"))
         EndIf
      EndIf
   Else
      aCAMPOTMP := {{"EEQ_FLAG","","  "}}
  	  If lMultiFil
          aAdd(aCampoTmp,{"EEQ_FILORI","","Filial"})
      EndIF
  	  aAdd(aCampoTmp,{"WK_IMPORT","","Importador"})
      aAdd(aCampoTmp,COLBRW("EEQ_PREEMB","TMP"))
      aAdd(aCampoTmp,COLBRW("EEQ_PARC"  ,"TMP"))
      aAdd(aCampoTmp,COLBRW("EEQ_VCT"   ,"TMP"))
      aAdd(aCampoTmp,COLBRW("EEQ_VL"    ,"TMP"))
      aAdd(aCampoTmp,{{||TRANSF(TMP->EEQ_VLFCAM, '@E 999,999,999,999.99')},"",AVSX3("EEQ_VLFCAM",5) }) //NCF - 11/04/2011
      aAdd(aCampoTmp,COLBRW("EEQ_NROP"  ,"TMP"))
   EndIf
ELSE
   If !lMultiFil
     aFil := {cFilAnt}
   EndIf
   For i:= 1 To Len(aFil)
      cFilAnt:=aFil[i] //LRL 18/12/04 - Seta o Resultado do xFilial caso Exclusivo
      EEQ->(DBSETORDER(2))
      EEQ->(DBSEEK(XFILIAL("EEQ")+cFFC))
      DO WHILE ! EEQ->(EOF()) .AND. EEQ->(if(!lMultiFil ,EEQ_FILIAL,"")+EEQ_FFC) = (if(!lMultiFil ,XFILIAL("EEQ"),"")+cFFC)
         If lMultiFil  .And. EEQ->EEQ_FILIAL <> xFIlial("EEQ")
            EEQ->(dbSkip())
            Loop
         EnDIf
         If lIntFina .and. lFinanciamento .and.;
            (EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,If(EEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+EEQ->EEQ_NRINVO+EEQ->EEQ_PARC+EV_LIQ_PRC)) .or.;
            EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,If(EEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+EEQ->EEQ_NRINVO+EEQ->EEQ_PARC+EV_LIQ_PRC_FC))) .and. !Empty(EF3->EF3_NR_CON)
            EEQ->(dbSkip())
            Loop
         EndIf
         TMP->(DBAPPEND())
         RegToMemory("EEQ", .F.)
         AVREPLACE("EEQ","TMP")
         TMP->TRB_ALI_WT:= "EEQ"
         TMP->TRB_REC_WT:= EEQ->(Recno())
         If EEQ->( FieldPos("EEQ_BCOEXT") ) > 0 .And. TMP->( FieldPos("EEQ_NBCEXT") ) > 0 //NCF - 08/09/2014 - Verificação do campo EEQ_NBCEXT
            TMP->EEQ_NBCEXT:= Posicione("SA6", 1, xFilial("SA6") + EEQ->(EEQ_BCOEXT + EEQ_AGCEXT + EEQ_CNTEXT), "A6_NOME")
         Endif
         TMP->EEQ_VLFCAM:= AF200VLFCam("EEQ", "ALT")
         SA1->(DBSetOrder(1))
         SA1->(DBSeek(xFilial("SA1")+EEQ->EEQ_IMPORT))
         TMP->WK_Import := EEQ->EEQ_IMPORT + "-" + SA1->A1_NREDUZ
         TMP->A1_COD := EEQ->EEQ_IMPORT
         TMP->EEQ_FILORI:= xFilial("EEQ")+ " - " + AvgFilName({xFilial("EEQ")})[1]
         nTotal += TMP->EEQ_VL
         EEQ->(DBSKIP())
       ENDDO
   Next
   If lOkEVENT
      aCAMPOTMP := {}
      If lMultiFil
          aAdd(aCampoTmp,{"EEQ_FILORI","","Filial"})
      EndIF
      aAdd(aCampoTmp,{"WK_IMPORT","","Importador"})
      aAdd(aCampoTmp,COLBRW("EEQ_PREEMB","TMP"))
      aAdd(aCampoTmp,COLBRW("EEQ_NRINVO","TMP"))
      aAdd(aCampoTmp,COLBRW("EEQ_PARC"  ,"TMP"))
      aAdd(aCampoTmp,COLBRW("EEQ_VCT"   ,"TMP"))
      aAdd(aCampoTmp,COLBRW("EEQ_VL"    ,"TMP"))
      aAdd(aCampoTmp,{{||TRANSF(TMP->EEQ_VLFCAM, '@E 999,999,999,999.99')},"",AVSX3("EEQ_VLFCAM",5) }) //NCF - 11/04/2011
      aAdd(aCampoTmp,COLBRW("EEQ_NROP"  ,"TMP"))
      If EECFlags("FRESEGCOM")
         aAdd(aCampoTmp,COLBRW("EEQ_MOEDA" ,"TMP"))
         aAdd(aCampoTmp,COLBRW("EEQ_PARI"  ,"TMP"))
         aAdd(aCampoTmp,COLBRW("EEQ_CODEMP","TMP"))
         aAdd(aCampoTmp,COLBRW("EEQ_FORN"  ,"TMP"))
         aAdd(aCampoTmp,COLBRW("EEQ_FOLOJA","TMP"))
         aAdd(aCampoTmp,COLBRW("EEQ_TIPO"  ,"TMP"))

         If EEQ->( FieldPos("EEQ_TP_CON") ) > 0
            aAdd(aCampoTmp,COLBRW("EEQ_TP_CON","TMP"))
         EndIf
      EndIf
   Else
      aCAMPOTMP := {}
      If lMultiFil
          aAdd(aCampoTmp,{"EEQ_FILORI","","Filial"})
      EndIF
      aAdd(aCampoTmp,{"WK_IMPORT","","Importador"})
      aAdd(aCampoTmp,COLBRW("EEQ_PREEMB","TMP"))
      aAdd(aCampoTmp,COLBRW("EEQ_PARC"  ,"TMP"))
      aAdd(aCampoTmp,COLBRW("EEQ_VCT"   ,"TMP"))
      aAdd(aCampoTmp,COLBRW("EEQ_VL"    ,"TMP"))
      aAdd(aCampoTmp,{{||TRANSF(TMP->EEQ_VLFCAM, '@E 999,999,999,999.99')},"",AVSX3("EEQ_VLFCAM",5) })  //NCF - 11/04/2011
      aAdd(aCampoTmp,COLBRW("EEQ_NROP"  ,"TMP"))
   EndIf
ENDIF

cFilAnt := xcFil
If lIntFina .and. lFinanciamento
   EF3->(dbSetOrder(1))
EndIf

If EasyEntryPoint("EECAF300")
   ExecBlock("EECAF300",.F.,.F.,{"FIM_GRV_TMP"})
EndIf

#IFDEF TOP
   If Select("Qry") > 0
      Qry->(DbCloseArea())
   EndIf
#ENDIF

TMP->(DBGOTOP())

If lCotaCambio
   EXG->(DbSetOrder(1))
   EXG->(DbSeek(xFilial("EXG")+AvKey("_FFC"+TMP->EEQ_FFC,"EXG_PREEMB")))

   Do While EXG->(!Eof()) .And. EXG->EXG_FILIAL == xFilial("EXG") .And.;
                                EXG->EXG_PREEMB == AvKey("_FFC"+TMP->EEQ_FFC,"EXG_PREEMB")
      Work_Cot->(DbAppend())
      AvReplace("EXG","Work_Cot")
      Work_Cot->RECNO := EXG->(RecNo())
      Work_Cot->TRB_ALI_WT:= "EXG"
      Work_Cot->TRB_REC_WT:= EXG->(Recno())
      EXG->(DbSkip())
   EndDo

   Work_Cot->(DbGoTop())
EndIf

RETURN(NIL)

Static Function AF300Integ(cAction,cSeqPag,lExibMsg) //RRC - 15/03/2013 - Acrescentado lExibMsg// BAK - 24/09/12
Local lRet := .T.
Local cBaixa := ""
Local cEstorno := ""
Local lAchouTit := .T.
Local lEstorno := .T.
Local lFinanceiro := ChkFile("SE1") .And. ChkFile("SE2") .And. ChkFile("SE5")
Local aOrd := SaveOrd({"EEQ","SE1","SE2","SE5"})
Default lExibMsg  := .T.
Private nParcEst // Utilizada no estorno
Private nValorBaixa := 0

//RRC - 07/03/2013
If IsInCallStack("ESSRS400")
   cModulo := "ESS"
EndIf

Begin Sequence

   If "R" $ EEQ->EEQ_TIPO // IsReceita(EEQ->EEQ_EVENT)
      cBaixa := "023" // Baixa de parcela de cambio a receber
      cEstorno := "024" // Estorno de parcela de cambio a receber
      If lFinanceiro .And. !Empty(EEQ->EEQ_FINNUM)
         SE1->(DbSetOrder(1))//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
         SE5->(DbSetOrder(7))//E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
         lAchouTit := SE1->(DbSeek(xFilial()+cModulo+AvKey(EEQ->EEQ_FINNUM, "E1_NUM")+AvKey(EECGetFinParc(EEQ->EEQ_PARC), "E1_PARCELA")+AvKey("NF","E1_TIPO")))
         lEstorno := AF201PosicSE5("SE1")
      EndIf
      lEstorno := !IsIntEnable("001") .Or. lEstorno
   Else
      cBaixa := "028" // Baixa de parcela de cambio a pagar
      cEstorno := "029" // Estorno de parcela de cambio a pagar
      If lFinanceiro .And. !Empty(EEQ->EEQ_FINNUM)
         SE2->(DbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
         SE5->(DbSetOrder(7))//E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
         lAchouTit:= SE2->(DbSeek(xFilial()+cModulo+AvKey(EEQ->EEQ_FINNUM, "E2_NUM")+AvKey("1", "E2_PARCELA")+AvKey("NF","E2_TIPO")))
         lEstorno := AF201PosicSE5("SE2")
      EndIf
      lEstorno := !IsIntEnable("001") .OR. lEstorno
   EndIf

   //If !Empty(EEQ->EEQ_FINNUM)

      nValorBaixa := AF200VlTx()*EEQ->EEQ_VL

      If (cAction == "7" .Or. cAction == "4") .And. (lAchouTit .Or. !IsIntEnable("001")) .And. lEstorno // Estorno de parcela
         /*If !RS401Pagto(2,,lExibMsg) //RRC - 08/03/2013 - Caso não exclua os pagamentos (EL1)
            lRet := .F.
            Break
         EndIf*/
         lRet := AvStAction(cEstorno)
      EndIf

      If (cAction == "6" .Or. cAction == "4") .And. AF200ParcLiq() .And. (lAchouTit .Or. !IsIntEnable("001")) // Baixa de parcela
         lRet := AvStAction(cBaixa)
      EndIf

   //EndIf

End Sequence

RestOrd(aOrd,.T.)

Return lRet

/*
Função    : AF300Rel()
Objetivos : Relatório de FFC
Autor     : Guilherme Fernandes Pilan - GFP
Data      : 28/10/2013
*/
*-----------------------------------------------*
Static Function AF300Rel()
*-----------------------------------------------*
Local lRet := .T.
Local cDir := "\Comex\"
Local cFile:= "RELFFC.xrp"
Local cNrFFC, cBanco, cAgenc, cConta, dCrExtDe, dCrExtAte, lStop
Private cFiltro := cSeek := ""

Begin Sequence

   Do While .T.
      If !Pergunte("EECFFC01",.T.)
         Break
      EndIf

      cNrFFC    := AvKey(MV_PAR01,"EEQ_FFC")
      cBanco    := AvKey(MV_PAR02,"EEQ_BANC")
      cAgenc    := AvKey(MV_PAR03,"EEQ_AGEN")
      cConta    := AvKey(MV_PAR04,"EEQ_NCON")
      dCrExtDe  := MV_PAR05
      dCrExtAte := MV_PAR06

      DBSELECTAREA("EEQ")

      cFiltro := "EEQ_FILIAL == '"+xFilial("EEQ")+"'"

      If !Empty(cNrFFC)
         cFiltro += " .And. EEQ_FFC == '"+cNrFFC+"'"
      EndIf

      If !Empty(cBanco)
         cFiltro += " .And. EEQ_BANC == '"+cBanco+"'"+" .And. EEQ_AGEN == '"+cAgenc+"'"+" .And. EEQ_NCON == '"+cConta+"'"
      EndIf

      If !Empty(dCrExtDe)
         cFiltro += " .And. EEQ_DTCE >= CToD('"+DToC(MV_PAR05)+"')"
      EndIf

      If !Empty(dCrExtAte)
         cFiltro += " .And. EEQ_DTCE <= CToD('"+DToC(MV_PAR06)+"')"
      EndIf

      lStop := .F.
      aOrdEEQ := SaveOrd("EEQ")
      DbGoTop()
      DbEval(  {|| lStop := .T.},  &( "{||"+cfiltro+"}" ) ,  {|| !lStop}  )

      If lStop
         RestOrd(aOrdEEQ,.T.)
         EXIT
      EndIf

      MsgInfo(STR0133,STR0036)  // "Registro não encontrado." ### "Aviso"
      EEQ->(DBClearFilter())
   EndDo

   SET FILTER TO &(cFiltro)

   If !lIsDir(cDir) .And. !(MakeDir(cDir) == 0)
      MsgInfo(StrTran(STR0134, "###", cDir),STR0026)   // "Erro ao criar o diretório temporário '###'. Não será possível executar o relatório."  ### "Atenção"
      lRet := .F.
      Break
   EndIf

   If File(cDir+cFile)
      FErase(cDir+cFile)
   EndIf

   If !MemoWrite(cDir+cFile, EasyExecAHU("RELFFC") )
      MsgInfo(STR0135,STR0026)  // "Erro de Abertura do arquivo." ### "Atenção"
      lRet := .F.
      Break
   EndIf

   LoadReport(cDir+cFile)
   FErase(cDir+cFile)

   EEQ->(DBClearFilter())

End Sequence

Return lRet

/*
Função     : AF300VincParc
Objetivos  : Vincular parcelas no FFC
Parâmetros : Nenhum
Retorno    : lSairTela - .T. - Sai da manutenção de FFC
                         .F. - Não sai da manutenção
Autor      : Guilherme Fernandes Pilan - GFP
Data       : 28/10/2013
*/
*----------------------*
Function AF300VincParc()
*----------------------*
Local aCposBrowse := {} , aFilter, aStruWk := {}, aOrd := SaveOrd({"TMP","EEQ","SA1"})

Local bOk        := {|| lOk := .T., oDlg:End() },;
      bCancel    := {|| oDlg:End() },;
      bMark      := {|| TRB->(If(Empty(WK_DEFLAG), WK_DEFLAG := cMarca, WK_DEFLAG := Space(2))) }

Local oDlg

Local cQuery := ""

Local lInverte  := .F.,;
      lOk       := .F.,;
      lSairTela := .F.,;
      lOkMark   := .F.

Local nTopErr := NIL
Local cBanco := ""
Local cCont  := ""
Local cAgen  := ""

Private cMarca := GetMark()

Begin Sequence

   aAdd(aStruWk,{"EEQ_PREEMB",AvSX3("EEQ_PREEMB",AV_TIPO),AvSX3("EEQ_PREEMB",AV_TAMANHO),AvSX3("EEQ_PREEMB",AV_DECIMAL)})
   aAdd(aStruWk,{"EEQ_EVENT" ,AvSX3("EEQ_EVENT",AV_TIPO),AvSX3("EEQ_EVENT",AV_TAMANHO),AvSX3("EEQ_EVENT",AV_DECIMAL)})
   aAdd(aStruWk,{"EEQ_NRINVO",AvSX3("EEQ_NRINVO",AV_TIPO),AvSX3("EEQ_NRINVO",AV_TAMANHO),AvSX3("EEQ_NRINVO",AV_DECIMAL)})
   aAdd(aStruWk,{"EEQ_PARC"  ,AvSX3("EEQ_PARC",AV_TIPO),AvSX3("EEQ_PARC",AV_TAMANHO),AvSX3("EEQ_PARC",AV_DECIMAL)})
   aAdd(aStruWk,{"EEQ_VCT"   ,AvSX3("EEQ_VCT",AV_TIPO),AvSX3("EEQ_VCT",AV_TAMANHO),AvSX3("EEQ_VCT",AV_DECIMAL)})
   aAdd(aStruWk,{"EEQ_MOEDA" ,AvSX3("EEQ_MOEDA",AV_TIPO),AvSX3("EEQ_MOEDA",AV_TAMANHO),AvSX3("EEQ_MOEDA",AV_DECIMAL)})
   aAdd(aStruWk,{"EEQ_VL"    ,AvSX3("EEQ_VL",AV_TIPO),AvSX3("EEQ_VL",AV_TAMANHO),AvSX3("EEQ_VL",AV_DECIMAL)})
   aAdd(aStruWk,{"WK_DEFLAG" ,"C",2,0})

   TMP->(DbGoTop())

   cBanco := TMP->EEQ_BANC
   cCont  := TMP->EEQ_NCON
   cAgen  := TMP->EEQ_AGEN

   BeginSql Alias "WorkQry"
	   	Select EEQ_PREEMB, EEQ_EVENT, EEQ_NRINVO, EEQ_PARC, EEQ_VCT, EEQ_MOEDA, EEQ_VL
	   	From %table:EEQ% EEQ
	   	Where
	   		EEQ_FILIAL = %xfilial:EEQ%
	   		And EEQ_FFC = ' '
	   		And EEQ_PGT = ' '
	   		And EEQ_FORN = %exp:TMP->EEQ_FORN% And EEQ_FOLOJA = %exp:TMP->EEQ_FOLOJA%
	   		And EEQ_MOEDA = %exp:TMP->EEQ_MOEDA%
	   		And EEQ_BANC = %exp:cBanco%
	   		And EEQ_NCON = %exp:cCont%
	   		And EEQ_AGEN = %exp:cAgen%
	   		And EEQ.%NotDel%
   EndSql

   TCSetField("WorkQry", "EEQ_VCT", "D")

   If IsVazio("WorkQry")   // Caso vazio
      MsgInfo(STR0136,STR0026)   //"Não há parcelas disponíveis para vinculação."  ### "Atenção"
      lSairTela := .T.
      Break
   EndIf

   aAdd(aCposBrowse,COLBRW("EEQ_PREEMB" ,"TRB"))
   aAdd(aCposBrowse,COLBRW("EEQ_EVENT"  ,"TRB"))
   aAdd(aCposBrowse,COLBRW("EEQ_NRINVO" ,"TRB"))
   aAdd(aCposBrowse,COLBRW("EEQ_PARC"   ,"TRB"))
   aAdd(aCposBrowse,COLBRW("EEQ_VCT"    ,"TRB"))
   aAdd(aCposBrowse,COLBRW("EEQ_MOEDA"  ,"TRB"))
   aAdd(aCposBrowse,COLBRW("EEQ_VL"     ,"TRB"))

   cNameWk := E_CriaTrab(, aStruWk, "TRB")

   WorkQry->(DbGoTop())
   TMP->(DbSetOrder(2))
   Do While WorkQry->(!Eof())
      If !TMP->(DbSeek(WorkQry->(EEQ_PREEMB+EEQ_NRINVO+EEQ_PARC)))
         TRB->(DbAppend())
         TRB->EEQ_PREEMB := WorkQry->EEQ_PREEMB
         TRB->EEQ_EVENT  := WorkQry->EEQ_EVENT
         TRB->EEQ_NRINVO := WorkQry->EEQ_NRINVO
         TRB->EEQ_PARC   := WorkQry->EEQ_PARC
         TRB->EEQ_VCT    := WorkQry->EEQ_VCT
         TRB->EEQ_MOEDA  := WorkQry->EEQ_MOEDA
         TRB->EEQ_VL     := WorkQry->EEQ_VL
         TRB->WK_DEFLAG := ""
         nTotal += EEQ_VL
         nSaldo += EEQ_VL
      EndIf
      WorkQry->(DbSkip())
   EndDo

   aAdd(aCposBrowse, Nil)
   aIns(aCposBrowse, 1)
   aCposBrowse[1] := {"WK_DEFLAG","","  "}

   TRB->(DbGoTop())
   TMP->(DbGoTop())

   DEFINE MSDIALOG oDlg TITLE STR0137 FROM DLG_LIN_INI+(DLG_LIN_FIM/4),DLG_COL_INI+(DLG_COL_FIM/4);//"Selecione as parcelas que serão vinculadas"
                                        TO DLG_LIN_FIM-(DLG_LIN_FIM/4),DLG_COL_FIM-(DLG_COL_FIM/5);
                                        OF oMainWnd PIXEL
      aPos := PosDlg(oDlg)

      oMsSelect := MsSelect():New("TRB", "WK_DEFLAG",, aCposBrowse, @lInverte, @cMarca, PosDlg(oDlg))
      oMsSelect:bAval := bMark

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel)

   If lOk
      //Filtra a work para tratar somente as parcelas marcadas
      TRB->(DbClearFilter())
      TRB->(DbSetFilter({|| TRB->WK_DEFLAG == cMarca }, "TRB->WK_DEFLAG == cMarca"))

	  TMP->(DbSetOrder(2))
	  TRB->(dbGoTop())

      Do While TRB->(!Eof())
         If ! TMP->(DbSeek(TRB->(EEQ_PREEMB+EEQ_NRINVO+EEQ_PARC)))
            EEQ->(DbSetOrder(4))
            If EEQ->(DbSeek(xFilial("EEQ")+TRB->(EEQ_NRINVO+EEQ_PREEMB+EEQ_PARC)))
               TMP->(DbAppend())
               AvReplace("EEQ","TMP")
               SA1->(DBSetOrder(1))
               SA1->(DBSeek(xFilial()+EEQ->EEQ_IMPORT))
               TMP->EEQ_FFC := cFFC
               TMP->EEQ_VLFCAM:= AF200VLFCam("EEQ", "ALT")
               SA1->(DBSetOrder(1))
               SA1->(DBSeek(xFilial("SA1")+EEQ->EEQ_IMPORT))
               TMP->WK_IMPORT := EEQ->EEQ_IMPORT + "-" + SA1->A1_NREDUZ
               TMP->A1_COD := EEQ->EEQ_IMPORT
               TMP->EEQ_FILORI:= xFilial("EEQ")+ " - " + AvgFilName({xFilial("EEQ")})[1]     //NCF - 06/03/2014 - Tratamento Multifilial
               TMP->TRB_ALI_WT:= "EEQ"
               TMP->TRB_REC_WT:= EEQ->(Recno())
            EndIf
         EndIf
         TRB->(DbSkip())
      EndDo
   EndIf
   TMP->(dbGoTop())
   oMSelect:oBrowse:Refresh()
End Sequence

If Select("WorkQry") # 0
   WorkQry->(DbCloseArea())
EndIf
If Select("TRB") # 0
   TRB->(DbCloseArea())
EndIf

RestOrd(aOrd,.T.)
Return lSairTela

/*
Funcao      : AF300AbTMP()
Parametros  : cMod - Apenas para determinar o modo como o índice da tabela deve ser montado.
Retorno     : Nenhum.
Objetivos   : Reabrir o arquivo temporário TMP caso o ele tenha sido fechado por ponto de entrada / rotina do SIGACTB
Autor       : Nilson César
Data/Hora   : 05/02/2020
Obs.        :
*/
Function AF300AbTMP(cMod)

   TETempReopen(cWorkEEQ, "TMP")

   If cMod == "1"
      IndRegua("TMP",cWORKEEQ+TEOrdBagExt(),"EEQ_PREEMB + A1_COD + EEQ_NRINVO + EEQ_PARC","AllwayTrue()","AllwaysTrue()",STR0001) //"Processando Arquivo Temporario"
      IndRegua("TMP",FileWork+TEOrdBagExt(),"EEQ_PREEMB + EEQ_NRINVO+EEQ_PARC")
      IndRegua("TMP",FileWork1+TEOrdBagExt(),"EEQ_PREEMB + EEQ_PARC")
      SET INDEX TO (cWORKEEQ+TEOrdBagExt()),(FileWork+TEOrdBagExt()),(FileWork1+TEOrdBagExt())
   ElseIf cMod == "2"
      IndRegua("TMP",cWORKEEQ+TEOrdBagExt(),"A1_COD + EEQ_NRINVO + EEQ_PARC","AllwayTrue()","AllwaysTrue()",STR0001) //"Processando Arquivo Temporario"
      IndRegua("TMP",FileWork+TEOrdBagExt(),"EEQ_NRINVO+EEQ_PARC")
      SET INDEX TO (cWORKEEQ+TEOrdBagExt()),(FileWork+TEOrdBagExt())      
   EndIf

Return

/*
Funcao      : Af300Action()
Parametros  : cActCall - Integração a invocar no AvStAction()
              aOrdTMP  - Array de estado da tabela para uso na rotina RestOrd()
Retorno     : lRet - Resultado da chamada do AvStAction()
Objetivos   : Executar a integração com a tabela TMP fechada e restaurá-la em um mesmpo ponto após
              a integração com SIGAFIN, para evitar conflito de uso do mesmo alias "TMP" na tabela 
              utilizada pelo módulo SIGACTB quando há contabilização online na baixa do título. 
Autor       : Nilson César
Data/Hora   : 05/02/2020
Obs.        :
*/
Function Af300Action(cActCall,aOrdTMP)

Local lReturn
Default aOrdTMP := {}

   If Select("TMP") > 0              //Fecha a TMP antes de chamar a integração
      If Empty(aOrdTMP) 
         aOrdTMP := SaveOrd("TMP")
      EndIf
      TMP->(DbCloseArea())
   EndIf
   
   lReturn := AvStAction(cActCall)   //Executa a integração

   If Select("TMP") > 0              //Fecha a TMP novamente caso tenha sido aberta por outro módulo.
      TMP->(DbCloseArea())
   EndIf

   AF300AbTMP("1")                   //Restaura a TMP para o módulo atual

   If !Empty(aOrdTMP)                //Restaura a ordem e posicionamento da tabela caso tenha salvo.
      RestOrd(aOrdTMP,.T.)
   EndIf

Return lReturn

*------------------------------------------------------------------------------------------------------------------*
*                                              FIM DO PROGRAMA EECAF300                                            *
*------------------------------------------------------------------------------------------------------------------*
