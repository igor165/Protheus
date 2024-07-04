#INCLUDE "Eicin100.ch"
// by CAF 19/08/2003 - Versão 8.11 não pode ter o FIVEWIN.ch
//#INCLUDE "FWIN100.ch"
#include "average.ch"
#INCLUDE "avprint.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "EEC.CH"
#Include "TOPCONN.ch"
/*
Funcao    ³ IN100
Autor     ³ AVERAGE/VICTOR IOTTI
Data      ³ 12.11.97
Descricao ³ Importacao de Arquivos
Sintaxe   ³ IN100()
Uso       ³ SIGAEIC
*/

Function EICIN100(nParProg,bGravaDBF,lChamada,lSched_n)

LOCAL oRad1, nOldArea:=SELECT(), nVolta, cArea, i
LOCAL C1:=25, cTit, aItemsRad
LOCAL oFont2, nColBrow:=0
LOCAL x3ord:= SX3->(INDEXORD())
Local cDespAFRMM := EasyGParam("MV_CODAFRM",,"405")

Private lRateioCIF:= EasyGParam("MV_RATCIF" ,,"N") $ cSim .Or. Upper(Alltrim(EasyGParam("MV_RATCIF" ,,"N"))) $ "VA"
Private lRatPeso := .F.
Private MDI_PESO := 0
Private MDI_PESOL:= 0
Private MDI_TOTNF:= 0
lChamada := If(lChamada == Nil, .F., lChamada)
//Private lCompartilhado:=.F. // AWR - 28/04/2006
Private cMemo := ""	//ASR 18/11/05
Private aMemo:= {} //TRP-05/11/12
Private LEN_MSG:=80, INCLUSAO:='I', ALTERACAO:='A', EXCLUSAO:='E' // - BHF 07/10/08 - Alteração tamanho LEN_MSG 80
Private ASTERISCOS:='************************************************************'
Private lSched:=IF(lSched_n=NIL,.F.,lSched_n)
Private nTamUM:=LEN(SB1->B1_UM)
// Nenhum CAD_?? deve começar com Z pois esta só é usada para integrações específicas do CLIENTE. Ou seja não pode ser CAD_Z?.
IF(lSched,LEN_MSG:=70,)
Private CAD_AG := 'AG', CAD_BC := 'BC', CAD_CC := 'CC', CAD_CI := 'CI', CAD_CO := 'CO'
Private CAD_FB := 'FB', CAD_FP := 'FP', CAD_IM := 'IM', CAD_IP := 'IP', CAD_IS := 'IS'
Private CAD_LE := 'LE', CAD_LI := 'LI', CAD_NB := 'NB', CAD_PO := 'PO', CAD_SI := 'SI'
Private CAD_TC := 'TC', CAD_DE := 'DE', CAD_UN := 'UN', CAD_DI := 'DI', CAD_RE := 'RE'
Private CAD_IT := 'IT', CAD_FF := 'FF', CAD_CL := 'CL', CAD_PE := 'PE', CAD_CE := 'CE'
Private CAD_PD := 'PD', CAD_LK := 'LK', CAD_NF := 'NF', CAD_FE := 'FE', CAD_NS := "NS"
Private CAD_NG := 'NG', CAD_NU := 'NU', CAD_DN := 'DN', CAD_EP := 'EP', CAD_UC := 'UC'
PRIVATE CAD_NC := "NC", CAD_ND := "ND", CAD_TP := "TP", CAD_NR := "NR"//AWR - 07/04/09
Private aOpcoes:={}, aEstruDspHe, aEstruDspDe, aEstruDspTx,nPadrao:=0, cRegNPA := "000"
Private lMsmm:= .F. /*EasyGParam("MV_CARGA",,.F.)*/ //ISS - 03/02/11 - Alteração do conteúdo padrão do parâmetro para falso (.F.)
PRIVATE nNumMsmm:=0, nResumoCer:=0, nResumoErr:=0, cTit1Principal:='',cTit2Principal:=''
PRIVATE cArqMemo:='NAO TEM', lIncAltPO:=EasyGParam("MV_INC_PO"), nResumoAlt:=0, nResumoArq:=''
Private nResumoInic:='',nResumoFim:='',nResumoData:=AVCTOD('  /  /  '), aEstruDef:={}, cDirNPA:=''
PRIVATE nSB1_P   := TAMSX3("B1_VM_P")[1]   , nSB1_I := TAMSX3("B1_VM_I")[1]
PRIVATE nSB1_GI  := TAMSX3("B1_VM_GI")[1]  , nSYC_GV  := TAMSX3("YC_DESC_GV")[1]
PRIVATE nSW2_OBS := TAMSX3("W2_VM_OBS")[1] , nSWU_OBS := TAMSX3("WU_VM_OBS")[1]
PRIVATE nTamPosicao:=AVSX3("W3_POSICAO",3)
PRIVATE nTamReg    :=AVSX3("W1_REG",3)
PRIVATE lLeTXT   := .T. // Variavel que define se deve ser lido o txt novamente.
PRIVATE lLidoTXT := .T. // Variavel que define se ja foi lido o txt.
Private lPrevia  := .F., nExtra, NewLine:=CHR(13)+CHR(10)
PRIVATE cNameNDH, cNameNDD, oCbx, cValid:=".T.", cValOk, cValRej, nOrem:=1
PRIVATE cNameTXT 
Private lMostraResumo:=.T., lAppend:=.T., nAno:=2, nTamTela := 385, nTamSelec := 127
Private lParam:=!EMPTY(nParProg), nArq:=LEN(aOpcoes), lBotaoVerItens:=.F., lNPENOTIFY:=.F.
Private _PictItem := ALLTRIM(X3PICTURE("B1_COD")), lNIPTEC:=.F.
Private _PictFob  := ALLTRIM(X3PICTURE("W2_FOB_TOT")), lAlteraPO:=EasyGParam("MV_ALT_PO",,.F.)
Private _PictSI   := ALLTRIM(X3PICTURE("W0__NUM"))
Private lCallSap  := GetNewPar("MV_SAP_INT","N") == "S"                   //MJB-SAP-1100
Private lEIC_EEC  := GetNewPar("MV_EIC_EEC",.F.)                          //MJB-SAP-1100
PRIVATE lIncAltPE := GetNewPar("MV_INC_PE",.F.)                           //MJB-SAP-1100
PRIVATE lINCALTNS := GetNewPar("MV_INC_NS",.F.)                           //LCS-BPCS . PADRAO E FALSO
PRIVATE lNFITENS  := GetNewPar("MV_AVG0038",.F.)    // LCS-BPCS . PADRAO E FALSO
Private lVerifNota:= EasyGParam("MV_VLDNOTA",,.T.) //AAF - 26/11/07 - Indica se faz a integração de despesas mesmo com a 1a Nota.
Private lMV_GRCPNFE:= EasyGParam("MV_GRCPNFE",,.F.) .AND.; //AWR - 04/11/08 - Indica se integracao vai gravar (T) ou não (F) os campos novos da NFE
        SWN->(FIELDPOS("WN_PREDICM")) # 0 .AND. SWN->(FIELDPOS("WN_DESCONI")) # 0 .AND.;
        SWN->(FIELDPOS("WN_VLRIOF"))  # 0 .AND. SWN->(FIELDPOS("WN_DESPADU")) # 0 .AND.;
        SWN->(FIELDPOS("WN_ALUIPI"))  # 0 .AND. SWN->(FIELDPOS("WN_QTUIPI"))  # 0 .AND.;
        SWN->(FIELDPOS("WN_QTUPIS"))  # 0 .AND. SWN->(FIELDPOS("WN_QTUCOF"))  # 0 .AND.;
        SWN->(FIELDPOS("WN_ADICAO"))  # 0 .AND. SWN->(FIELDPOS("WN_SEQ_ADI")) # 0 .AND.;
        SW6->(FIELDPOS("W6_LOCALN"))  # 0 .AND. SW6->(FIELDPOS("W6_UFDESEM")) # 0
Private lTemED9Cpos:=ED9->(FieldPOs("ED9_VAL_SE")) # 0 .AND. ED9->(FieldPOs("ED9_VALCOM")) # 0 .AND.;
                     ED9->(FieldPOs("ED9_VALORI")) # 0 .AND. ED9->(FieldPOs("ED9_UMNCM" )) # 0 .AND.;
                     ED9->(FieldPOs("ED9_QTDNCM")) # 0 .AND. ED9->(FieldPOs("ED9_TX_USS")) # 0 .AND.;
                     ED9->(FieldPOs("ED9_DTAVRB")) # 0 .AND. ED9->(FieldPOs("ED9_ISENTO")) # 0 .AND.;
                     ED9->(FieldPOs("ED9_SALISE")) # 0 .AND. ED9->(FieldPOs("ED9_FASEDR")) # 0 .AND.;
                     ED9->(FieldPOs("ED9_DT_INT")) # 0 .AND. SIX->(dbSeek("ED9"+"4"))//AWR - 07/04/2009
PRIVATE aEE9PROC  := {}                                                   //LCS-BPCS
Private aEECProc  := {}                                                   //AMS-BPCS
PRIVATE aDados :={"",;
                OemtoAnsi(STR0014),; //"Este relatório irá exibir a Integração"
                STR0015,; //"de acordo com a opção escolhida."
                "",;
                "G",;
                220,;
                "",;
                "",;
                "",;
                { STR0016, 1,OemtoAnsi(STR0017), 2, 2, 1, cValid, nOrem },; //"Zebrado"###"Importa‡Æo"
                cModulo+"IN100",;
                { {|| .T. } , {|| .T. }  }  }


PRIVATE cMarca := GetMark(), lInverte := .F., aArqMemo:={}

PRIVATE mMemoResumo:='',lMantem:=EasyGParam("MV_MANTEM") // Integracao

PRIVATE cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999

PRIVATE aHeader[0],nUsado:=0, TCodigo, TB_Cols:={}, TB_Col_D:={}
Private _LIT_R_CC := IF(EMPTY(ALLTRIM(EasyGParam("MV_LITRCC"))),(AVSX3("W0__CC")[5]),ALLTRIM(EasyGParam("MV_LITRCC")))
PRIVATE aTabW0, aTabW4, aTabFabFor, lTravaPO:=.T.

PRIVATE nLenItem:=AVSX3("W3_COD_I",3)//AWR 28/10/99
PRIVATE nLenUM  :=AVSX3("AH_UNIMED",3)//GFC 05/12/03
PRIVATE nLenFabr:=AVSX3("A2_COD",3)//SO.:0026 OS.: 0232/02 FCD
PRIVATE nLenForn:=AVSX3("A2_COD",3)//SO.:0026 OS.: 0232/02 FCD
PRIVATE nLenCli :=AVSX3("A1_COD",3)//SO.:0026 OS.: 0232/02 FCD 
PRIVATE nLenCC  :=AVSX3("W0__CC",3)//SO.:0026 OS.: 0232/02 FCD
PRIVATE nLenSi  :=AVSX3("W0__NUM",3)//SO.:0026 OS.: 0232/02 FCD
PRIVATE nLenEst :=AVSX3("A2_EST",3)//SO.:0032 OS.: 0298/02 FCD
PRIVATE lNPDPSBRTO := .T., lNPDPSBRUN := .T.
Private cDirStart  := Upper(GetSrvProfString("STARTPATH",""))
Private cDirRoot   := Upper(GetSrvProfString("ROOTPATH",""))

// *** CAF OS.0878/98 10/08/1998 16:01 *** (INICIO)
PRIVATE cPath := AllTrim(EasyGParam("MV_PATH_IN"))  // Path de leitura dos arquivos
                                               // texto para integracao.
cPath    :=STRTRAN(cPath    ,"/","\")//Por causa do LINUX
cDirStart:=STRTRAN(cDirStart,"/","\")//Por causa do LINUX
cDirRoot :=STRTRAN(cDirRoot ,"/","\")//Por causa do LINUX

IF(Right(cPath,1)    != "\", cPath += "\",)
IF(Left(cPath,1)     != "\" .and. SubStr(cPath,2,1) <> ":", cPath := "\" + cPath,)
IF(Right(cDirStart,1)!= "\", cDirStart += "\",)
IF(Right(cDirRoot,1)  = "\", cDirRoot := Left(cDirRoot,Len(cDirRoot)-1),)

cRegNPAT:=cRegNPA := "000" //variavel foi movida por causa do Schedule, para o programa saber o nome certo dos arquivos - AWR 25/06/2002
IF TYPE("cMsgR3") = "U"//Caso essa variavel nao for iniciada no Schedule ou o EICIN100  
   cMsgR3:="" // nao for chamado do Schedule: inicia
ENDIF

bCampo  := {|nCPO| Field(nCPO) }

PRIVATE  cFuncao, TBRCols:={}, bMessage, bStatus, bStaIte, bTipo, bDtInteg,nOpcao, nTotRegua, oMark, oTrab
Private  cDate:=IN100DTC(dDataBase)
PRIVATE  cDD:=LEFT(cDate,2), cMM:=SUBS(cDate,3,2), cAA:=RIGHT(cDate,nAno), cTemp

PRIVATE cPictTaxa:='@E 999,999.99999999', cPictPari:="@E 999,999,999.999999" ,;
        cPictcom :="@E 999,999,999.99999"

PRIVATE  cPict13_3:='@E 999,999,999.999',cPictPesoL:='@E 999,999,999.99999999'
PRIVATE  cPict15_2:='@E 999,999,999,999.99', lRdmake:=.F.
PRIVATE  cPict17_2:='@E 99,999,999,999,999.99'
PRIVATE  cPict05_2:='@E 99.99'
PRIVATE  cPict11_4:='@E 999,999.9999'
PRIVATE  cPict15_4:='@E 9,999,999,999.9999'
PRIVATE  cPict15_8:='@E 999,999.99999999'    ,lGeral:=.T., cBrowAux:=STR0019 //"Geral"
PRIVATE  cPict18_8:='@E 999,999,999.99999999',cTipoBrow:=STR0019, cParamInic:=CHR(0), cParamFim :=CHR(255) //"Geral"

Private  cFilEX5:=xFilial("EX5"),cFilEX6:=xFilial("EX6")
Private  cFilSW0:=xFilial("SW0"),cFilSW1:=xFilial("SW1"),cFilSW2:=xFilial("SW2")                      //MJB-SAP-0401
Private  cFilSW3:=xFilial("SW3"),cFilSW4:=xFilial("SW4"),cFilSW5:=xFilial("SW5")                      //MJB-SAP-0401
Private  cFilSW6:=xFilial("SW6"),cFilSW7:=xFilial("SW7"),cFilSWN:=xFilial("SWN")                      //MJB-SAP-0401
Private  cFilSWD:=xFilial("SWD"),cFilSWU:=xFilial("SWU"),cFilSWZ:=xFilial("SWZ")                                             
Private  cFilSA1:=xFilial("SA1"),cFilSA2:=xFilial("SA2"),cFilSA5:=xFilial("SA5"),cFilSA6:=xFilial("SA6") 
Private  cFilSAH:=xFilial("SAH"),cFilEEC:=xFilial("EEC"),cFilEIC:=xFilial("EIC")
Private  cFilSC7:=xFilial("SC7"),cFilEE7:=xFilial("EE7"),cFilEE8:=xFilial("EE8")
Private  cFilSD1:=xFilial("SD1"),cFilEE3:=xFilial("EE3"),cFilSY9:=xFilial("SY9")
Private  cFilSF1:=xFilial("SF1"),cFilSJ2:=xFilial("SJ2"),cFilSJ1:=xFilial("SJ1")
Private  cFilSYA:=xFilial("SYA"),cFilSYB:=xFilial("SYB"),cFilSYC:=xFilial("SYC"),cFilSYD:=xFilial("SYD")
Private  cFilSYE:=xFilial("SYE"),cFilSYF:=xFilial("SYF"),cFilSYG:=xFilial("SYG"),cFilSYJ:=xFilial("SYJ")      					//MJB-SAP-0501
Private  cFilSYR:=xFilial("SYR"),cFilSYP:=xFilial("SYP"),cFilSYQ:=xFilial("SYQ")
Private  cFilSYT:=xFilial("SYT"),cFilSYU:=xFilial("SYU"),cFilEE5:=xFilial("EE5")
Private  cFilSY1:=xFilial("SY1"),cFilSY2:=xFilial("SY2"),cFilSY3:=xFilial("SY3")
Private  cFilSY4:=xFilial("SY4"),cFilSY5:=xFilial("SY5"),cFilSY6:=xFilial("SY6")
Private  cFilECB:=xFilial("ECB"),cFilEE2:=xFilial("EE2"),cFilEEH:=xFilial("EEH")
Private  cFilSB1:=xFilial("SB1"),cFilEEG:=xFilial("EEG"),cFilEEF:=xFilial("EEF")
Private  cFilSJ0:=xFilial("SJ0"),cFilSJA:=xFilial("SJA"),cFilSJB:=xFilial("SJB")
Private  cFilSX5:=xFilial("SX5"),cFilEE9:=xFilial("EE9"),cFilEEL:=xFilial("EEL")
Private  cFilEEN:=xFilial("EEN"),cFilEEM:=xFilial("EEM"),cFilSJ5:=xFilial("SJ5")
Private  cFilSG1:=xFilial("SG1"),cFilSGA:=xFilial("SGA"),cFilSW9:=xFilial("SW9"),cFilEES:=xFilial("EES")
Private  cFilED1:=xFilial("ED1"),cFilED2:=xFilial("ED2"),cFilSW8:=xFilial("SW8"),cFilSC1:=xFilial("SC1")      
Private  cFilSWV:=xFilial("SWV"),cFilED9:=xFilial("ED9"),cFilSWP:=xFilial("SWP")
Private cAliasSB1 := "SB1", cFilSB1Aux:=xFilial("SB1"), lAbriuExp := .F.  // Quando o cliente possui empresas ou filiais # para imp. e exp. Caso DrawBack
Private lAbriuSA2, cFilSA2Aux:=cFilSA2, lSX3TxECB:= .F., lSX3TxSYE:= .F.
PRIVATE lSai_Int:=.F.
Private lMV_PIS_EIC := EasyGParam("MV_PIS_EIC",,.F.) .AND. SWN->(FIELDPOS("WN_VLRPIS")) # 0 .AND. SYD->(FIELDPOS("YD_PER_PIS")) # 0
Private lMV_NF_MAE  := EasyGParam("MV_NF_MAE",,.F.) 
Private cMV_NFFILHA := EasyGParam("MV_NFFILHA",,"0")

Private lSX3EX5_DTINI, lSX3EX5_DTFIM, lSX3EX6_DTINI, lSX3EX6_DTFIM

Private aTabIP := {}
Private aTabSI := {}
// Caso a posicao 1 do parametro 3 do array aOpcoes seja = ´U´ é função do usuário.

SX3->(DBSETORDER(2))
lSX3EIC:=SX3->(DBSEEK("EIC_HAWB"))
lSX3TxECB:=SX3->(DBSEEK("ECB_TX_EXP"))
lSX3TxSYE:=SX3->(DBSEEK("YE_TX_COMP"))
lSX3EX5_DTINI:=SX3->(DBSEEK("EX5_DTINI"))
lSX3EX5_DTFIM:=SX3->(DBSEEK("EX5_DTFIM"))
lSX3EX6_DTINI:=SX3->(DBSEEK("EX6_DTINI"))
lSX3EX6_DTFIM:=SX3->(DBSEEK("EX6_DTFIM"))
SX3->(DBSETORDER(x3ord))

Private _PictPrUn := ALLTRIM(X3Picture("W3_PRECO"))                    //MJB-SAP-0101
Private _PictQtde := ALLTRIM(X3Picture("W3_QTDE"))
Private _PictPO   := ALLTRIM(X3Picture("W2_PO_NUM"))
Private oPanel2 //LRL 05/04/04
Private cIndexSAH //ASK 08/11/07
Private lCposCofMj := SYD->(FieldPos("YD_MAJ_COF")) > 0 .And. SYT->(FieldPos("YT_MJCOF")) > 0 .And. SWN->(FieldPos("WN_VLCOFM")) > 0 .And.;                                                    //NCF - 20/07/2012 - Majoração PIS/COFINS
                      SWN->(FieldPos("WN_ALCOFM")) > 0  .And. SWZ->(FieldPos("WZ_TPCMCOF")) > 0 .And. SWZ->(FieldPos("WZ_ALCOFM")) > 0 .And.;
                      EIJ->(FieldPos("EIJ_ALCOFM")) > 0 .And. SW8->(FieldPos("W8_VLCOFM")) > 0 .And. EI2->(FieldPos("EI2_VLCOFM")) > 0   // GFP - 30/07/2013 - Majoração COFINS

//JPM - 11/07/05 - Alias do arquivo de controle de usuários
Private cAliasControl := "IN_CTR"

Private lOperacaoEsp := AvFlags("OPERACAO_ESPECIAL")  // RMD - 16/12/2013

IF !EasyGParam("MV_PCOIMPO",,.T.)//Se for importador é .T., e Adquirente é .F.
   cTitNFE:="Nota Fiscal NFE / NFT"//Quando esta no Adquirente
ELSE
   cTitNFE:=STR0529
ENDIF

// BAK - Alteração para Nova Integração com despachante
Private lIntDesp := IsInCallStack("EICEI100")

If !AvFlags("INDICEED9")
   Return .F.
EndIf

If SYB->(DbSeek(xFilial("SYB")+AvKey(cDespAFRMM,"YB_DESP")))
   If SYB->YB_RATPESO $ cSim
      lRatPeso := .T.
   EndIf
EndIf

If cModulo = "EIC"              
   AADD(aOpcoes,{STR0001,{||IN100Familia(TB_Cols)}        ,CAD_FP}) // A.C.D.       'Familia de Itens                
   AADD(aOpcoes,{STR0002,{||IN100CC(TB_Cols)}             ,CAD_CC}) // VICTOR IOTTI 'Unidade Requisitante            
   AADD(aOpcoes,{STR0003,{||IN100Item(TB_Cols)}           ,CAD_CI}) // VICTOR IOTTI 'Itens                           
   AADD(aOpcoes,{STR0004,{||IN100FabFor(TB_Cols)}         ,CAD_FB}) // VICTOR IOTTI 'Fabricantes/Fornecedores        
   AADD(aOpcoes,{STR0005,{||IN100ItemFabrFor(TB_Cols)}    ,CAD_LI}) // A.C.D.       'Ligação Item/Fabr./Forn.        
   AADD(aOpcoes,{STR0006,{||IN100NBM(TB_Cols)}            ,CAD_NB}) // VICTOR IOTTI 'NCMs                            
   AADD(aOpcoes,{STR0007,{||IN100Taxas(TB_Cols)}          ,CAD_TC}) // VICTOR IOTTI 'Taxas de Conversão              
   AADD(aOpcoes,{STR0008,{||IN100SI(TB_Cols)}             ,CAD_SI}) // VICTOR IOTTI 'Fase S.I.                       
   AADD(aOpcoes,{STR0009,{||IN100PO(TB_Cols)}             ,CAD_PO}) // VICTOR IOTTI 'Fase P.O.                       
   AADD(aOpcoes,{STR0010,{||IN100DespDespachante(TB_Cols)},CAD_DE}) // A.C.D.       'Despesas do Despachante         
   AADD(aOpcoes,{STR0011,{||IN100DI(TB_Cols)}             ,CAD_DI}) // VICTOR IOTTI 'Atualização da Data Recebimento 
   AADD(aOpcoes,{cTitNFE,{||IN100NFE(TB_Cols)}            ,CAD_FE}) // A.W.R.       
   AADD(aOpcoes,{STR0672,{||IN100NU(TB_Cols)}             ,CAD_NU}) // L.C.B.       "Recebimento de numerário
   nPadrao   := 013 //12
   nTamTela  := 435 // 400 //385
   nTamSelec := 155 // 135 //127

ElseIf cModulo = "EDC"              
   If Select("SB1EXP") = 0
      lAbriuExp := AbreArqExp("SB1",ALLTRIM(EasyGParam("MV_EMPEXP",,"")),ALLTRIM(EasyGParam("MV_FILEXP",,"  ")),cFilSB1Aux,"SB1EXP") // Abre arq. produtos de outra Empresa/Filial de acordo com os parametros.
   Else   
      lAbriuExp := .T.
   Endif    
   If lAbriuExp      
      cAliasSB1    := 'SB1EXP'
      cFilSB1Aux   := If(Empty(ALLTRIM(EasyGParam("MV_FILEXP",,Space(FWSizeFilial())))), Space(FWSizeFilial()), ALLTRIM(EasyGParam("MV_FILEXP",,space(FWSizeFilial()))))
      //AADD(aOpcoes,{STR0724,{||IN100It(TB_Cols)}     ,CAD_IT}) // VI Produtos da Exportação
   Endif

   lAbriuSA2 := AbreArqExp("SA2",ALLTRIM(EasyGParam("MV_EMPEXP",,"")),ALLTRIM(EasyGParam("MV_FILEXP",,Space(FWSizeFilial()))),cFilSA2Aux) // Abre arq. SA2 de outra Empresa/Filial de acordo com os parametros.
   If lAbriuSA2
      cFilSA2Aux   := EasyGParam("MV_FILEXP",,Space(FWSizeFilial()))
      If(Empty(Alltrim(cFilSA2Aux)),cFilSA2Aux:=Space(FWSizeFilial()),) //Devido ao parâmetro vir com um espaço apenas
   Endif
   
   AADD(aOpcoes,{STR0721,{|| IN100Item(TB_Cols)}   ,CAD_CI}) // VI Itens da Importação
   AADD(aOpcoes,{STR0793,{|| IN100It(TB_Cols)}     ,CAD_IT}) // Itens da Exportação // MCF - 08/06/2016 - CADASTRO DE PRODUTOS (Exportação)
   AADD(aOpcoes,{STR0006,{|| IN100NBM(TB_Cols)}    ,CAD_NB}) // VI NCMs                            
   AADD(aOpcoes,{STR0722,{|| IN100ESTPROD(TB_Cols)},CAD_EP}) // VI Estrutura de Produtos
   AADD(aOpcoes,{STR0723,{|| IN100CONVUM(TB_Cols)} ,CAD_UC}) // VI Conversão de Unid. Med.
   AADD(aOpcoes,{STR0734,{|| IN100COMPEXT(TB_Cols)},CAD_CE}) // Dados externos DI/RE - VI Comprovações Externas         
   
   // GFP - 24/08/2011 - Integração Fabr/Forn
   AADD(aOpcoes,{STR0004,{|| IN100FF(TB_Cols)},CAD_FF}) // Fabricantes/Fornecedores
   
   // BAK - 31/08/2011 - Alteração para quantidade de opções na variavel nPadrao
   //nPadrao   := If(lAbriuExp, 6, 5)
   nPadrao   := If(lAbriuExp, Len(aOpcoes)+1, Len(aOpcoes))

   nTamTela  := 287//272    +-15
   nTamSelec := 80//72      +-8
   IF lTemED9Cpos//AWR - 07/04/2009
      AADD(aOpcoes,{"R.E. Externos",{|| IN100RE_Externos(TB_Cols)},CAD_NR})
      nPadrao   ++
      nTamTela  +=35//10
      nTamSelec +=18//8
   ENDIF

Else
   AADD(aOpcoes,{STR0004,{||IN100FF(TB_Cols)}      ,CAD_FF}) // VICTOR IOTTI 'Fabricantes/Fornecedores        
   AADD(aOpcoes,{STR0050,{||IN100Cl(TB_Cols)}      ,CAD_CL}) // VICTOR IOTTI 'Clientes                        
   AADD(aOpcoes,{STR0005,{||IN100LK(TB_Cols)}      ,CAD_LK}) // VICTOR IOTTI 'Ligação Item/Fabr./Forn.        
   AADD(aOpcoes,{STR0007,{||IN100Taxas(TB_Cols)}   ,CAD_TC}) // VICTOR IOTTI 'Taxas de Conversão              
   If ! lEIC_EEC                                                          //MJB-SAP-0101
      AADD(aOpcoes,{STR0003,{||IN100It(TB_Cols)}   ,CAD_IT}) // VICTOR IOTTI 'Itens
   Else                                                                   //MJB-SAP-0101
      AADD(aOpcoes,{STR0003,{||IN100Item(TB_Cols)} ,CAD_CI})               //MJB-SAP-0101
   Endif                                                                  //MJB-SAP-0101
   AADD(aOpcoes,{STR0047,{||IN100PE(TB_Cols)}      ,CAD_PE}) // VICTOR IOTTI 'Processo
   IF lNFITENS
      AADD(aOpcoes,{STR0704,{||IN100NC(TB_Cols)}   ,CAD_NC}) // LUCIANO CS   'NOTAS FISCAIS DE SAIDA COM ITENS
   ELSE
      AADD(aOpcoes,{STR0704,{||IN100NS(TB_Cols)}   ,CAD_NS}) // LUCIANO CS   'NOTAS FISCAIS DE SAIDA SEM ITENS
   ENDIF
   AADD(aOpcoes,{STR0723,{||IN100CONVUM(TB_Cols)}  ,CAD_UC}) // VICTOR IOTTI Conversão de Unid. Med.

   AADD(aOpcoes,{STR0001,{||IN100Familia(TB_Cols)} ,CAD_FP}) // ALCIR          'Familia de Itens  20/07/04              
   
   nPadrao   := 9
   If EX5->( FieldPos("EX5_DTINI") > 0 .AND. FieldPos("EX5_DTFIM") > 0 ) .AND.; //AAF 21/10/04 - Verifica se Existe os Campos Existem
      EX6->( FieldPos("EX6_DTINI") > 0 .AND. FieldPos("EX6_DTFIM") > 0 ) 
      AADD(aOpcoes,{STR0790,{||IN100Preco(TB_Cols)}   ,CAD_TP})    //ALCIR  'TABELAS DE PRECOS  23/07/04 //LRS - 30/10/2013 Trocado STR para o correto.
      nPadrao++
   Endif
   
   //nPadrao   := 10 //9 //8
   nTamTela  := 390 // 380 // 360 //354 //310
   nTamSelec := 125//106 //93 
EndIf   

//CCH - 01/08/2008 - Ajusta tamanho da tela para contemplar a opção Resumo Geral das Integrações
//nTamSelec := 150       // AWR - 08/04/2009 - Nopei pois a variavel nTamSelec tem um valor para cada MODULO, caso seja necessario alterar deve ser feito via ponto de entrada: "MENU" abaixo
//nTamTela  := 430//410  // AWR - 08/04/2009 - Nopei pois a variavel nTamTela  tem um valor para cada MODULO, caso seja necessario alterar deve ser feito via ponto de entrada: "MENU" abaixo

If EasyEntryPoint("IN100CLI")                       
   ExecBlock("IN100CLI",.F.,.F.,"MENU")
EndIf

AADD(aOpcoes,{STR0012,{||IN100DI(TB_Cols)} ,CAD_RE}) // VICTOR IOTTI 'Resumo Geral das Integrações    '

aItemsRad:={}
FOR I:=1 TO LEN(aOpcoes)
    AADD(aItemsRad,aOpcoes[I,1])
NEXT

Do While !lSai_Int // RA - 17/12/03 - O.S. 1401/03 - (.t.=>!lSai_Int)

   ******* JANELA DE OPCOES

   If nVolta#2
      lGeral:=.T.
      lLeTXT := .T.
      lLidoTXT := .F.
      lRdmake:=.F.
      cBrowAux:=cTipoBrow:=STR0019 //"Geral"

      If ! lParam .And. !lChamada
         DEFINE MSDIALOG oDlg FROM 117,180 TO nTamTela,540 TITLE STR0018 of oMainWnd PIXEL

         @  6, 10 TO nTamSelec, 130 LABEL STR0020    OF oDlg  PIXEL //"Seleção"

         nVolta := 0
  
         oRad1 := TRadMenu():New(15,20,aItemsRad,{|x| if(x=nil,nopcao,nopcao:=x)},oDlg,,,,,,,,100,9,,,.T.,.T.)

         DEFINE SBUTTON FROM Int(Max(Len(aOpcoes),5)*3.3),141 TYPE 1 ACTION (nVolta:=1,oDlg:End()) ENABLE OF oDlg PIXEL
         DEFINE SBUTTON FROM Int(Max(Len(aOpcoes),6)*5.8),141 TYPE 2 ACTION (oDlg:End()) ENABLE OF oDlg PIXEL

         ACTIVATE MSDIALOG oDlg CENTERED

         If nVolta#1
            Exit                            
         Endif
      Else       
         If Valtype(nParProg) = "N"
            nOpcao:=nParProg
         ElseIf Valtype(nParProg) = "C"            
            nOpcao:=ASCAN(aOpcoes,{|MENU| ALLTRIM(MENU[3]) = nParProg})
         EndIf
      EndIf    
      
      lParam := If(lChamada, .F., lParam) //Via rot. EICNU400 Integr.de numerário
      
      cFuncao:=UPPER(aOpcoes[nOpcao,3])      
      
      // RA - 17/12/03 - O.S. 1401/03 - Inicio
      If EasyEntryPoint("IN100CLI")                       
         ExecBlock("IN100CLI",.F.,.F.,"APOS_SELECAO_MENU")
      EndIf
      If lSai_Int
         Exit
      EndIf
      // RA - 17/12/03 - O.S. 1401/03 - Final
      
/*      If cFuncao == CAD_NU // .AND. ! lSX3EIC
         IN_MSG(STR0407)
         Exit
      EndIf  */
      
      If cFuncao == CAD_RE 
         cTit:=ALLTRIM(aOpcoes[LEN(aOpcoes),1])
      Else
         lRdmake:=nOpcao>nPadrao
         cTit:=STR0021+ALLTRIM(aOpcoes[nOpcao,1]) //"Integracao de "
      Endif
      cTit:=STRTRAN(cTit, "&", "")
      cTit1Principal:=SPAC(40-LEN(ALLTRIM(MEMOLINE(cTit,25,1))))+ALLTRIM(UPPER(MEMOLINE(cTit,25,1)))
      cTit2Principal:=SPAC(40-LEN(ALLTRIM(MEMOLINE(cTit,25,2))))+ALLTRIM(UPPER(MEMOLINE(cTit,25,2)))

      If ! IN100ESTRU("PA")
         Exit
      EndIf

      DBUSEAREA(.T.,"TOPCONN","IN100_NPA000","Int_Param",.T.)
      IF NETERR()
         IN_MSG(STR0022) //"Arquivo de PARAMETROS nao disponivel ..."
         EXIT
      ENDIF

      While ! Int_Param->(EOF())
            If  (Int_Param->NPAEMP==SM0->M0_CODIGO    .AND. ;
                 Int_Param->NPAFILIAL==left(SM0->M0_CODFIL,len(Int_Param->NPAFILIAL)) .AND. ;
                 ALLTRIM(Int_Param->NPAUSUARIO) == Left(UPPER(ALLTRIM(cUserName)), Len(ALLTRIM(Int_Param->NPAUSUARIO))))
                 Exit
            Endif
            Int_Param->(DbSkip())
      Enddo

      If ! Int_Param->(EOF())         
         cRegNPAT:=cRegNPA := StrZero(Int_Param->(Recno()),3,0)         
         IF ! Reclock("Int_Param",.F.,,.T.)
            IN_MSG(STR0023+NewLine+STR0024) //"O mesmo usuario nao pode executar a "###"integracao de dois micros diferentes."
            Int_Param->(dbcloseAREA())
            EXIT
         ENDIF
      Else
         Int_Param->(DBGOTO(1))
         if Int_Param->(EasyRecCount("Int_Param")) == 1 .AND. EMPTY(ALLTRIM(Int_Param->NPAUSUARIO))
            IF ! Reclock("Int_Param",.F.,,.T.)
               IN_MSG(STR0023+NewLine+STR0024) //"O mesmo usuario nao pode executar a "###"integracao de dois micros diferentes."
               Int_Param->(dbcloseAREA())
               EXIT
            ENDIF
            Int_Param->NPAEMP    :=SM0->M0_CODIGO
            Int_Param->NPAFILIAL :=SM0->M0_CODFIL
            Int_Param->NPAUSUARIO:=UPPER(cUserName)
         Else
            IN100RecLock('Int_Param')
            Int_Param->NPAEMP    :=SM0->M0_CODIGO
            Int_Param->NPAFILIAL :=SM0->M0_CODFIL
            Int_Param->NPAUSUARIO:=UPPER(cUserName)
            If ! lParam
               If cModulo = "EEC"
                  EECIN100Param()
               ElseIF cModulo = "EDC"
                  EDCIN100Param()
               Else
                  // BAK - alteração para a nova integração com despachante
                  If !lIntDesp
                     IN100Param()
                  EndIf
               EndIf
            EndIf
         EndIf
         cRegNPAT:=cRegNPA := StrZero(Int_Param->(Recno()),3,0)
      EndIf
      
      //NCF - 22/08/2018 - Adiciona o módulo para diferenciação de tabelas e índices de integrações semelhantes em módulos diferentes
      cRegNPAT:=cRegNPA := ( cModulo + cRegNPA ) 

      If EasyEntryPoint("IN100CLI")
         ExecBlock("IN100CLI",.F.,.F.,"ANTES_ABRE_ARQ")//AWR - 28/04/2006
      EndIf

      If cFuncao == CAD_RE
         IN100GRVRESUMO()
      Else
    
         IF ! IN100_Abre(cFuncao)
            Int_Param->(dbcloseAREA())
            EXIT
         ENDIF

         bMessage:=FIELDWBLOCK('N'+cFuncao+'Msg'   ,SELECT('Int_'+cFuncao))
         bStatus :={|x| If(x=Nil,('Int_'+cFuncao)->&('N'+cFuncao+'INT_OK')="T",('Int_'+cFuncao)->&('N'+cFuncao+'INT_OK'):=x)}

         If cFuncao $ (CAD_SI+'/'+CAD_PO+'/'+CAD_IT+'/'+CAD_PE+'/'+CAD_FE+'/'+CAD_NU+"/"+CAD_NC)  // SI, PO, Itenss(expo), Processos(expo) E NOTAS FISCAIS COM ITENS
            bStaIte :={|| ('Int_'+cFuncao)->&('N'+cFuncao+'ITEM_OK')="T"}
         Endif
         
         bTipo   :=FIELDWBLOCK('N'+cFuncao+'TIPO'  ,SELECT('Int_'+cFuncao))
         bDtInteg:=FIELDWBLOCK('N'+cFuncao+'INT_DT',SELECT('Int_'+cFuncao))

         ******* JANELA COM OS DADOS

         IF ('Int_'+cFuncao)->(Easyreccount('Int_'+cFuncao)) == 0
            If !lParam                      //MJB-SAP-0800
               IN100RecLock(('Int_'+cFuncao))
               ('Int_'+cFuncao)->(DBGOTOP())
            Endif                           //MJB-SAP-0800
         ENDIF
         ('Int_'+cFuncao)->(DBSETORDER(1))
      Endif
   ENDIF                
   
   If ! lParam                     //MJB-SAP-0800
      oMainWnd:ReadClientCoords()
   Endif                           //MJB-SAP-0800
   
   If EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"PREVIANTES")
   EndIf

   lMostraResumo:=.T.   
   lAppend:=.T.  
   If ! lParam                
   
//MJB-SAP-0101      If cFuncao $ (CAD_SI+'/'+CAD_PO+'/'+CAD_DE+'/'+CAD_PE+'/'+CAD_IT+'/'+CAD_FE+'/'+CAD_NU)  // SI,PO e Envio ao Despachante
      If cFuncao $ (CAD_SI+'/'+CAD_PO+'/'+CAD_DE+'/'+CAD_PE+'/'+CAD_IT+'/'+CAD_FE+'/'+CAD_NU+"/"+CAD_NC) .OR. ;
        (cFuncao = CAD_CI .And. lEIC_EEC)                                 //MJB-SAP-0101
         nExtra:=46-(If(oMainWnd:nBottom=456,11,0))
      ElseIf cFuncao == CAD_RE
         nExtra:=350-(If(oMainWnd:nBottom=456,90,0))
      Else
         nExtra:=49-(If(oMainWnd:nBottom=456,11,0))
      Endif   

      If EasyEntryPoint("IN100CLI")
         ExecBlock("IN100CLI",.F.,.F.,"EXTRA")
      EndIf
   
      DEFINE MSDIALOG oDlg2 TITLE cTit ;
      From oMainWnd:nTop+125,oMainWnd:nLeft+5 To oMainWnd:nBottom-60,oMainWnd:nRight-10 OF oMainWnd PIXEL
      @ 00,00 MsPanel oPanel2 Prompt "" Size 60,21 of Odlg2 //LRL 05/04/04 Painel para alinhamento em Ambiente MDI
      nColBrow:=oMainWnd:nLeft+5
      
      //FDR - 07/05/12
      oDlg2:lMaximized := .T.
   
      If cFuncao # CAD_RE
         // GFP - 26/08/2011 :: 09:52 - Alteração do tamanho da MSSelect e posição de botoes na tela para servir as versões 11 e 11.5
         // GFP - 08/07/2011 :: 17:14 - Alteração de posições de botões na tela de integração
         @ 5,nColBrow         BUTTON STR0026 SIZE 33,11 FONT oDlg2:oFont ACTION (IN100RESUMO(),IN100FOCUS())   OF oPanel2 PIXEL //"&Resumo"
         @ 5,nColBrow+=nExtra BUTTON STR0027 SIZE 33,11 FONT oDlg2:oFont ACTION (IN100Integ(.T.,bGravaDBF),IN100FOCUS()/*,IF(!lGeral,(nVolta:=2,cTipoBrow:=STR0019,IN100ValTipo(),oDlg2:End()),)*/) OF oPanel2 PIXEL //"&Previa"###"Geral"
         @ 5,nColBrow+=nExtra BUTTON STR0028 SIZE 33,11 FONT oDlg2:oFont ACTION (IN100Integ(.F.,bGravaDBF),IN100FOCUS()/*,IF(!lGeral,(nVolta:=2,cTipoBrow:=STR0019,IN100ValTipo(),oDlg2:End()),)*/) OF oPanel2 PIXEL //"&Integra"###"Geral"
         @ 5,nColBrow+=nExtra BUTTON STR0029 SIZE 33,11 FONT oDlg2:oFont ACTION (IN100E_MSG(),IN100FOCUS())    OF oPanel2 PIXEL //"&Mensagem"
         // BAK - alteração para a nova integração com despachante
         If !lIntDesp
            @ 5,nColBrow+=nExtra BUTTON STR0030 SIZE 33,11 FONT oDlg2:oFont ACTION (If(cModulo = "EEC",EECIN100Param(),If(cModulo = "EDC",EDCIN100Param(),IN100Param())),IN100FOCUS())    OF oPanel2 PIXEL //"P&arametros"
            @ 5,nColBrow+=nExtra BUTTON STR0031 SIZE 33,11 FONT oDlg2:oFont ACTION (IN100Txt(),IN100FOCUS())      OF oPanel2 PIXEL //"&Gera Txt"
         EndIf
      EndIf

      If cFuncao # CAD_FE
         DEFINE SBUTTON FROM 5,nColBrow+=nExtra TYPE 6 ACTION (IN100Rel(cTit),IF(cFuncao#CAD_RE,IN100ValTipo(),)) ENABLE OF oPanel2
      ENDIF
      If cFuncao # CAD_RE
         @ 5,nColBrow+=nExtra-6 COMBOBOX oCbx VAR cTipoBrow ITEMS {STR0019,STR0032,STR0033} SIZE 40,50 OF oPanel2 PIXEL ON CHANGE(IF(cBrowAux#cTipoBrow,(IN100ValTipo(),nVolta:=0,MarkBrw(cArea,TB_Cols,@lInverte,@cMarca,oDlg2,lGeral),oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT),)) //"Geral"###"Aceitos"###"Rejeitados"        
         cArea := ('Int_'+cFuncao)
               
         lBotaoVerItens:=.F.

         If EasyEntryPoint("IN100CLI")
            ExecBlock("IN100CLI",.F.,.F.,"BOTAO ITENS")
         EndIf

         If cFuncao = CAD_DE  // Despesas do Despachante.
            @ 5,nColBrow+=nExtra+7 BUTTON "Desp/Taxas"  SIZE 33,11 FONT oDlg2:oFont ACTION (IN100Despesas(),IN100FOCUS()) OF oPanel2 PIXEL // Despesas
            cArea := ( 'Int_DspHe' )
         ElseIf cFuncao $ (CAD_SI+'/'+CAD_PO+'/'+CAD_PE+'/'+CAD_FE+"/"+CAD_NC) .OR. lBotaoVerItens  // SI, PO, PE e NC
            @ 5,nColBrow+=nExtra+7 BUTTON STR0035 SIZE 33,11 FONT oDlg2:oFont ACTION (IN100BrowIt(),IN100FOCUS()) OF oPanel2 PIXEL // Ver Itens
         ElseIf cFuncao = CAD_IT .Or. (cFuncao = CAD_CI .And. lEIC_EEC)   //MJB-SAP-0101
            @ 5,nColBrow+=nExtra+7 BUTTON STR0051 SIZE 33,11 FONT oDlg2:oFont ACTION (IN100BrowIt(),IN100FOCUS()) OF oPanel2 PIXEL // Ver Idiomas
         ElseIf cFuncao = CAD_NU
            @ 5,nColBrow+=nExtra+7 BUTTON STR0034 SIZE 33,11 FONT oDlg2:oFont ACTION (IN100BrowIt(),IN100FOCUS()) OF oPanel2 PIXEL // "Despesas"
         EndIf            
            
         EVAL(aOpcoes[nOpcao,2])
         ('Int_'+cFuncao)->(DBGOTOP())
         If cFuncao = CAD_DE
            Int_DspHe->(DBGOTOP())
         Endif
         
         If EasyEntryPoint("IN100CLI")
            ExecBlock("IN100CLI",.F.,.F.,"ANTES_MARKBRW")
         EndIf
         
         MarkBrw(cArea,TB_Cols,@lInverte,@cMarca,oDlg2,lGeral)
         
        // If cFuncao <> CAD_FF  
        //   oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT//AAF 07/12/04 - Alteração para resolver QNC 003351/2004
        // EndIf
         
         If EasyEntryPoint("IN100CLI")
            ExecBlock("IN100CLI",.F.,.F.,"1BROWSE")
         EndIf
      Else
         DEFINE FONT oFont2 NAME "Courier New" SIZE 0,16
         oDlg2:SetFont(oFont2)
         @ 36,((oDlg2:nClientWidth-312)/(If(oMainWnd:nBottom=456,67,11))) GET mMemoResumo MEMO HSCROLL READONLY SIZE 312,(oDlg2:nClientWidth/(If(oMainWnd:nBottom=456,7,5))) OF oDlg2 PIXEL
      EndIf

      nVolta:=0
        oPanel2:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
        // BAK - Alterção para nova integração com despachante
        // ACTIVATE MSDIALOG oDlg2 ON INIT (EnchoiceBar(oDlg2,{||nVolta:=1,oDlg2:End()},{||oDlg2:End()}),;
        ACTIVATE MSDIALOG oDlg2 ON INIT (EnchoiceBar(oDlg2,{|| If(lIntDesp,nVolta:=0,nVolta:=1),oDlg2:End()},{||oDlg2:End()}))// AAF 07/12/04 - Alteração para resolver QNC 003351/2004 //LRL 05/04/04 - Alinhamento MDI //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

      If nVolta=2
         loop
      Endif
   Else

      IF cFuncao = CAD_DE  // Despesas do Despachante.
         cArea := ( 'Int_DspHe' )
      Else
         cArea := ('Int_'+cFuncao)
      Endif
      lMostraResumo:=.F.
      IN100Integ(.F.,bGravaDBF)  //MJB-SAP-0800
   EndIf

   Int_Param->(MSUNLOCK())
   Int_Param->(dbcloseAREA())
   If cFuncao # CAD_RE
      SYE->(DbSetOrder(1))
      IN100_Fecha(aOpcoes[nOpcao,3])
   EndIf

   If nVolta=0 .OR. lParam
      exit
   Endif

Enddo
/*If lParam .And. !lSai_Int  .And. !TEtempbanco() // RA - 17/12/03 - O.S. 1401/03 - (.And. !lSai_Int)
   save to cArqMemo all like nResumo*
EndIf*/

SYC->(DBSETORDER(1))                                                      //MJB-SAP-1100
SYT->(DBSETORDER(1))
SW9->(DBSETORDER(1))
SYF->(DBSETORDER(1))
If cModulo="EIC"
   SY9->(DBSETORDER(1)) 
   SW6->(DbSetOrder(1))
ElseIf cModulo="EDC"
   ED9->(dbSetOrder(1))
   ED4->(dbSetOrder(1))
   ED3->(dbSetOrder(1))
   SA2->(dbSetOrder(1))
   ED0->(dbSetOrder(1))
EndIf

//JPM - 11/07/05
If Select(cAliasControl) > 0
   (cAliasControl)->(DbCloseArea())
EndIf

DBSELECTAREA(nOldArea) 

Return (Empty(nResumoErr))

*--------------------------------*
STATIC FUNCTION IN100_Abre(cfile)
*--------------------------------*
LOCAL bLer, nRec:=0       

cArqMemo:='NAO TEM'

ASIZE(TB_Cols,0)
ASIZE(TB_Col_D,0)

AADD(TB_Cols,{ {|| IN100Status()}            , "" , STR0036 }) //"Status"
AADD(TB_Cols,{ {|| IN100TIPO() }             , "" , STR0037 }) //"Tipo"

If ! IN100ESTRU(cfile)
   Return .F.
EndIf

do case
   case cfile == CAD_CI // Integracao de Itens
        //MFR 18/12/2018 OSSME-1974
        FErase("NCI"+cRegNPAT+"0"+TeOrdBagExt())
        FErase("NCI"+cRegNPAT+"1"+TeOrdBagExt())
        cValOk:="NCIINT_OK='T'"
        cValRej:="! NCIINT_OK='T'"
        DBUSEAREA(.T.,"TOPCONN", "NCI"+cRegNPA,"Int_CI",.F.)
        IF NETERR()       
           If !lSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else 
              ConOut(STR0038+" NCI000")
           Endif   
           RETURN .F.
        ENDIF   
  
        IN100IndRg( {{"Int_CI" , "NCI"+cRegNPAT , {"NCICOD_I","NCIINT_OK+NCICOD_I"} }}   )        
        cArqMemo:='IN_CI'+cRegNPA
                
        If lEIC_EEC                                                       //MJB-SAP-1100
           If ! IN100IntID()                                              //MJB-SAP-1100
              Int_CI->(dbcloseAREA())                                     //MJB-SAP-1100
              Return .F.                                                  //MJB-SAP-1100
           EndIf                                                          //MJB-SAP-1100
        Endif                                                             //MJB-SAP-1100

        //Alcir Alves - 04-05-05 - integração drawback
        IF EasyGParam("MV_EIC_EDC",,.F.)==.T. .AND. EasyGParam("MV_ENVMAIL",,.F.)==.T.
           //CRIA INDICE TEMPORÁRIO PARA TRATAMENTO DE ITENS NO ATO DE DRAWBACK
           //MFR 18/12/2018 OSSME-1974
           IndRegua("ED2", "ED2"+cRegNPAT+"0"+TeOrdBagExt(),"ED2_FILIAL+ED2_ITEM")         
        ENDIF
        //
   case cfile == CAD_FB // Integracao de Fabricante / Fornecedor
        //MFR 18/12/2018 OSSME-1974
        FErase("NFB"+cRegNPAT+"0"+TeOrdBagExt())
        FErase("NFB"+cRegNPAT+"1"+TeOrdBagExt())
        cValOk:="NFBINT_OK='T'"
        cValRej:="! NFBINT_OK='T'"
        DBUSEAREA(.T.,"TOPCONN", "NFB"+cRegNPA,"Int_FB",.F.)
        IF NETERR()                   
           If !LSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else
              ConOut(STR0038+"NFB"+cRegNPA) // sidney
           Endif
           RETURN .F.
        ENDIF                 
        
        IN100IndRg( {{"Int_FB" , "NFB"+cRegNPAT , {"NFBCOD","NFBINT_OK+NFBCOD"} }}   )
        cArqMemo:='IN_FB'+cRegNPA

   case cfile == CAD_NB // Integracao de NCM
        //MFR 18/12/2018 OSSME-1974
        FErase("NNB"+cRegNPAT+"0"+TeOrdBagExt())
        FErase("NNB"+cRegNPAT+"1"+TeOrdBagExt())
        cValOk:="NNBINT_OK='T'"
        cValRej:="! NNBINT_OK='T'"
        DBUSEAREA(.T.,"TOPCONN", "NNB"+cRegNPA,"Int_NB",.F.)
        IF NETERR()                  
           If !lSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else
              ConOut(STR0038+"NNB"+cRegNPA) // sidney
           Endif   
           RETURN .F.
        ENDIF          
        
        IN100IndRg( {{"Int_NB" , "NNB"+cRegNPAT , {"NNBNCM+NNBQUALNCM","NNBINT_OK+NNBNCM+NNBQUALNCM"} }}   )
        cArqMemo:='IN_NB'+cRegNPA

   case cfile == CAD_TC // Integracao de Taxas
        //MFR 18/12/2018 OSSME-1974
        FErase( "NTC"+cRegNPAT+"0"+TeOrdBagExt())
        FErase( "NTC"+cRegNPAT+"1"+TeOrdBagExt())
        cValOk:="NTCINT_OK='T'"
        cValRej:="! NTCINT_OK='T'"
        DBUSEAREA(.T.,"TOPCONN", "NTC"+cRegNPA,"Int_TC",.F.)
        IF NETERR()                  
           If !lSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else 
              ConOut(STR0038+"NTC"+cRegNPA) // sidney
           Endif   
           RETURN .F.
        ENDIF     
  
        IN100IndRg( {{"Int_TC" , "NTC"+cRegNPAT , {"NTCDATA+NTCMOEDA","NTCINT_OK+NTCDATA+NTCMOEDA"} }}  )
        cArqMemo:='IN_TC'+cRegNPA

   case cfile == CAD_PO // Integracao de P.O.
        AADD(TB_Cols,{ {|| IN100StaIte()} ,"" ,STR0048}) //"Tem Item Rejeitado"
        cValOk:="NPOINT_OK = 'T' .AND. NPOITEM_OK = 'T'"
        cValRej:="! NPOINT_OK = 'T' .OR. ! NPOITEM_OK = 'T'"
        //MFR 18/12/2018 OSSME-1974
        FErase( "NPO"+cRegNPAT+"0"+TeOrdBagExt())
        FErase( "NPO"+cRegNPAT+"1"+TeOrdBagExt())
        DBUSEAREA(.T.,"TOPCONN", "NPO"+cRegNPA,"Int_PO",.F.)
        IF NETERR()                                                             
           If !lSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else 
              Conout(STR0038+"NPO"+cRegNPA)  // sidney
           Endif   
           RETURN .F.
        ENDIF

        IN100IndRg( {{"Int_PO" , "NPO"+cRegNPAT , {"NPOPO_NUM+NPOSEQ_PO","NPOINT_OK+NPOPO_NUM+NPOSEQ_PO"} }}   )
        cArqMemo:='IN_PO'+cRegNPA

        If ! IN100ESTRU("IP")
           Int_PO->(dbcloseAREA())
           Return .F.
        EndIf
        //MFR 18/12/2018 OSSME-1974
        FErase( "NIP"+cRegNPAT+"0"+TeOrdBagExt())
        FErase( "NIP"+cRegNPAT+"1"+TeOrdBagExt())
        DBUSEAREA(.T.,"TOPCONN", "NIP"+cRegNPA,"Int_IP",.F.)
        IF NETERR()
           If !lSched  // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else 
              Conout(STR0038+"NIP"+cRegNPA) // sidney
           Endif   
           Int_PO->(dbcloseAREA())
           RETURN .F.
        ENDIF
        
        IN100IndRg( {{"Int_IP" , "NIP"+cRegNPAT , {"NIPPO_NUM+NIPSEQ_PO+NIPSEQ_IP","NIPCC+NIPSI_NUM"} }}   )
        // Se alterar os indices abertos, favor alterar tambem o RDMAKE
        // EICW0COD.PRW (AGFA)

        If ! ChkFile("SWU",.F.)
           IN_MSG(STR0053,STR0039) //"Arquivo de modelo n„o disponivel ..."###"Informação"
           Int_PO->(dbcloseAREA())
           Int_IP->(dbcloseAREA())
           RETURN .F.
        ENDIF

        DBSELECTAREA('Int_IP')

        aTmpStruct := DbStruct()
        E_CriaTrab(,aTmpStruct,"Temp")

        IF NETERR()              
           If !lSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else 
              Conout(STR0038+"TMPIP"+cRegNPAT) // sidney
           Endif   
           Int_PO->(dbcloseAREA())
           Int_IP->(dbcloseAREA())
           SWU->(dbcloseAREA())
           RETURN .F.
        ENDIF

   case cfile == CAD_SI // Integracao de S.I.
        AADD(TB_Cols,{ {|| IN100StaIte()},"" ,STR0048}) //"Tem Item Rejeitado"
        cValOk:="NSIINT_OK = 'T' .AND. NSIITEM_OK = 'T'"
        cValRej:="! NSIINT_OK = 'T' .OR. ! NSIITEM_OK = 'T'"
        //MFR 18/12/2018 OSSME-1974
        FErase( "NSI"+cRegNPAT+"0"+TeOrdBagExt())
        FErase( "NSI"+cRegNPAT+"1"+TeOrdBagExt())
        DBUSEAREA(.T.,"TOPCONN", "NSI"+cRegNPA,"Int_SI",.F.)
        IF NETERR()
           If !lSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else 
              Conout(STR0038+"NSI"+cRegNPA) // sidney
           Endif   
           RETURN .F.
        ENDIF

        IN100IndRg( {{"Int_SI" , "NSI"+cRegNPAT , {"NSI_CC+NSI_NUM+NSISEQ_SI","NSIINT_OK+NSI_CC+NSI_NUM+NSISEQ_SI"} }}   )

        If ! IN100ESTRU("IS")
           Int_SI->(dbcloseAREA())
           Return .F.
        EndIf
        //MFR 18/12/2018 OSSME-1974
        FErase( "NIS"+cRegNPAT+"0"+TeOrdBagExt())
        DBUSEAREA(.T.,"TOPCONN", "NIS"+cRegNPA,"Int_IS",.F.)
        IF NETERR() 
           If !lSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else 
              Conout(STR0038+"NIS"+cRegNPA) // sidney
           Endif   
 
           Int_SI->(dbcloseAREA())
           RETURN .F.
        ENDIF
  
        IN100IndRg( {{"Int_IS" , "NIS"+cRegNPAT , {"NISCC+NISSI_NUM+NISSEQ_SI+NISSEQ_IS"} }}   )

        If ! ChkFile("SWU",.F.)
           IN_MSG(STR0053,STR0039) //"Arquivo de modelo n„o disponivel ..."###"Informação"
           Int_SI->(dbcloseAREA())
           Int_IS->(dbcloseAREA())
           RETURN .F.
        ENDIF

        cArqMemo:='IN_SI'+cRegNPA

        DBSELECTAREA('Int_IS')
        aTmpStruct := DbStruct()
        E_CriaTrab(,aTmpStruct,"Temp")

        IF NETERR()              
           If !lSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else 
              Conout(STR0038+"TMPIS"+cRegNPAT) // sidney
           Endif   
 
           Int_SI->(dbcloseAREA())
           Int_IS->(dbcloseAREA())
           SWU->(dbcloseAREA())
           RETURN .F.
        ENDIF

   case cfile == CAD_LI  // Itens/Fabr./Forn.
        //MFR 18/12/2018 OSSME-1974
        FErase( "NLI"+cRegNPAT+"0"+TeOrdBagExt())
        FErase( "NLI"+cRegNPAT+"1"+TeOrdBagExt())
        cValOk:="NLIINT_OK='T'"
        cValRej:="! NLIINT_OK='T'"
        DBUSEAREA(.T.,"TOPCONN", "NLI"+cRegNPA,"Int_LI",.F.)
        IF NETERR()                 
           If !lSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else 
              Conout(STR0038+"NLI"+cRegNPA) // sidney
           Endif   

           RETURN .F.
        ENDIF

        IN100IndRg( {{"Int_LI" , "NLI"+cRegNPAT , {"NLICOD_I+NLIFABR+NLIFORN","NLIINT_OK+NLICOD_I+NLIFABR+NLIFORN"} }}   )
        cArqMemo:='IN_LI'+cRegNPA

   case cfile == CAD_FP   //  Familia de Itens.
        //MFR 18/12/2018 OSSME-1974
        FErase( "NFP"+cRegNPAT+"0"+TeOrdBagExt())
        FErase( "NFP"+cRegNPAT+"1"+TeOrdBagExt())
        cValOk:="NFPINT_OK='T'"
        cValRej:="! NFPINT_OK='T'"
        DBUSEAREA(.T.,"TOPCONN", "NFP"+cRegNPA,"Int_FP",.F.)
        IF NETERR()                                                             
           If !lSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else 
              Conout(STR0038+"NFP"+cRegNPA) // sidney
           Endif   

           RETURN .F.
        ENDIF    
        
        If cModulo = "EIC"
           IN100IndRg( {{"Int_FP" , "NFP"+cRegNPAT , {"NFPCOD","NFPINT_OK+NFPCOD"} }}   )
        ElseIf cModulo = "EEC"
           IN100IndRg( {{"Int_FP" , "NFP"+cRegNPAT , {"NFPCOD+NFPIDIOMA","NFPINT_OK+NFPCOD+NFPIDIOMA"} }}   )
        EndIf
        cArqMemo:='IN_FP'+cRegNPA


   case cfile == CAD_TP   //  TABELAS DE PRECO INDICES
        //MFR 18/12/2018 OSSME-1974
        FErase( "NTP"+cRegNPAT+"0"+TeOrdBagExt())
        FErase( "NTP"+cRegNPAT+"1"+TeOrdBagExt())
     //  FErase( "NTP"+cRegNPAT+"1"+TeOrdBagExt())
        cValOk:="NTPINT_OK='T'"
        cValRej:="!NTPINT_OK='T'"
        DBUSEAREA(.T.,"TOPCONN", "NTP"+cRegNPA,"Int_TP",.F.)
        IF NETERR()                                                             
           If !lSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else 
              Conout(STR0038+"NTP"+cRegNPA) // sidney
           Endif   

           RETURN .F.
        ENDIF    
        
        IN100IndRg( {{"Int_TP" , "NTP"+cRegNPAT , {"NTPPRO","NTPINT_OK+NTPPRO"} }}   )
        cArqMemo:='IN_TP'+cRegNPA

   case cfile == CAD_DE   //  Despesas do Despachante.
        //MFR 18/12/2018 OSSME-1974
        FErase( "NDE"+cRegNPAT+"0"+TeOrdBagExt())
        DBUSEAREA(.T.,"TOPCONN", "NDE"+cRegNPA,"Int_DE",.F.)
        IF NETERR()              
           If !lSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else 
              Conout(STR0038+"NDE"+cRegNPA) // sidney
           Endif   

           RETURN .F.
        ENDIF

        IN100IndRg( {{"Int_DE" , "NDE"+cRegNPAT , {"NDEHOUSE+NDETIPOREG"} }}   )  
        cArqMemo:='IN_DE'+cRegNPA
        //MFR 18/12/2018 OSSME-1974
        FErase( "NDH"+cRegNPAT+"0"+TeOrdBagExt())
        FErase( "NDH"+cRegNPAT+"1"+TeOrdBagExt())
        cValOk:="NDEINT_OK='T'"        // FOR CORRIGIDO TROCAR A VALIDACAO. VI
        cValRej:="! NDEINT_OK='T'"

        If ! IN100ESTRU("DH")
           Int_DE->( DbCloseArea() )
           Return .F.
        EndIf

        DBUSEAREA(.T.,"TOPCONN", "NDH"+cRegNPA,"Int_DspHe",.F.)
        IF NETERR()              
           If !lSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else 
              Conout(STR0038+"NDH"+cRegNPA) // sidney
           Endif   
           Int_DE->( DbCloseArea() )
           RETURN .F.
        ENDIF
        
        IN100IndRg( {{"Int_DspHe" , "NDH"+cRegNPAT , { "NDHHOUSE" , "NDHINT_OK+NDHHOUSE" } }}  )   

//************************************ AWR - 22/04/2003
        //MFR 18/12/2018 OSSME-1974
        FErase( "NTX"+cRegNPAT+"0"+TeOrdBagExt())
        If !IN100ESTRU("TX")
           Int_DE->( DbCloseArea() )
           Int_DspHe->( DbCloseArea() )
           Return .F.
        EndIf

        DBUSEAREA(.T.,"TOPCONN", "NTX"+cRegNPA,"Int_DspTx",.F.)
        IF NETERR()
           IN_MSG(STR0038) //"Arquivo nao disponivel ..."
           Int_DE->( DbCloseArea() )
           Int_DspHe->( DbCloseArea() )
           RETURN .F.
        ENDIF
         
        IN100IndRg( {{"Int_DspTx" , "NTX"+cRegNPAT , {"NTXHOUSE+NTXMOEDA"} }}  )

//************************************
        //MFR 18/12/2018 OSSME-1974
        FErase( "NDD"+cRegNPAT+"0"+TeOrdBagExt())
        If ! IN100ESTRU("DD")
           Int_DE->( DbCloseArea() )
           Int_DspHe->( DbCloseArea() )
           Int_DspTx->( DbCloseArea() )
           Return .F.
        EndIf

        DBUSEAREA(.T.,"TOPCONN", "NDD"+cRegNPA,"Int_DspDe",.F.)
        IF NETERR()
           If !lSched           // Sidney
              IN_MSG(STR0038) //"Arquivo n„o disponivel ..."
           Else 
              ConOut(STR0038 + "NDD"+cRegNPA ) // sidney
           Endif   
           Int_DE->( DbCloseArea() )
           Int_DspHe->( DbCloseArea() )
           RETURN .F.
        ENDIF
        
        IN100IndRg( {{"Int_DspDe" , "NDD"+cRegNPAT , {"NDDHOUSE","NDDHOUSE+NDDDESPESA"} }}  ) // NCF - 20/04/2021 - Adicionado campo da chave montado na função DespDelLin para AVINTEG

        If Select("TEMP") > 0
           TEMP->(DbCloseArea())
        EndIf

        aTmpStruct := DbStruct()
        E_CriaTrab(,aTmpStruct,"Temp")

        IF NETERR()
           If !lSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else 
              Conout(STR0038+"TMPNDD"+cRegNPAT) // sidney
           Endif   
           Int_DE->( DbCloseAREA() )
           Int_DspHe->( DbCloseAREA() )
           Int_DspDe->( DbCloseAREA() )
           Int_DspTx->( DbCloseAREA() )
           Processa({||.t.,STR0065}) //"Atualizacao de Cadastros"
           RETURN .F.
        ENDIF          
        aEstruDspHe :=Int_DspHe->(DBSTRUCT())
        aEstruDspDe :=Int_DspDe->(DBSTRUCT())
        aEstruDspTx :=Int_DspTx->(DBSTRUCT())
        DbSelectArea( "Int_DE" )

   case cfile == CAD_DI // Integracao de Data de Recebimento
        //MFR 18/12/2018 OSSME-1974
        FErase( "NDI"+cRegNPAT+"0"+TeOrdBagExt())
        FErase( "NDI"+cRegNPAT+"1"+TeOrdBagExt())
        cValOk :="NDIINT_OK='T'"
        cValRej:="! NDIINT_OK='T'"
        DBUSEAREA(.T.,"TOPCONN", "NDI"+cRegNPA,"Int_DI",.F.)
        IF NETERR()
           If !lSched // sidney
              IN_MSG(STR0038) //"Arquivo n„o disponivel ..."
           Else
              ConOut(STR0038+" Fase"+CAD_DI)   // sidney 
           Endif   
           RETURN .F.
        ENDIF

        IN100IndRg( {{"Int_DI" , "NDI"+cRegNPAT , {"NDIHAWB","NDIINT_OK+NDIHAWB","NDIDI_NUM"} }}   )
        cArqMemo:='IN_DI'+cRegNPA

   case cfile == CAD_CC   //  Unidade Requisitante
        //MFR 18/12/2018 OSSME-1974
        FErase( "NCC"+cRegNPAT+"0"+TeOrdBagExt())
        FErase( "NCC"+cRegNPAT+"1"+TeOrdBagExt())
        cValOk:="NCCINT_OK='T'"
        cValRej:="! NCCINT_OK='T'"
        DBUSEAREA(.T.,"TOPCONN", "NCC"+cRegNPA,"Int_CC",.F.)
        IF NETERR()                      
           If !lSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else
              ConOut(STR0038 + "NCC"+cRegNPA) // sidney
           Endif   
           RETURN .F.
        ENDIF   
    
        IN100IndRg( {{"Int_CC" , "NCC"+cRegNPAT , {"NCCCOD","NCCINT_OK+NCCCOD"} }}   )
        cArqMemo:='IN_CC'+cRegNPA
        
   case cfile == CAD_IT // Integracao de Itens      
        //MFR 18/12/2018 OSSME-1974          
        FErase( "NIT"+cRegNPAT+"0"+TeOrdBagExt())
        FErase( "NIT"+cRegNPAT+"1"+TeOrdBagExt())
        cValOk:="NITINT_OK='T'"
        cValRej:="! NITINT_OK='T'"
        DBUSEAREA(.T.,"TOPCONN", "NIT"+cRegNPA,"Int_IT",.F.)
        IF NETERR()
           If !lSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else
              ConOut(STR0038+"NIT"+cRegNPA ) // sidney
           Endif   
           RETURN .F.
        ENDIF

        IN100IndRg( {{"Int_IT" , "NIT"+cRegNPAT , {"NITCOD_I","NITINT_OK+NITCOD_I"} }}   )
        cArqMemo:='IN_IT'+cRegNPA

        If ! IN100IntID()                                                 //MJB-SAP-1100
           Int_IT->(dbcloseAREA())
           Return .F.
        EndIf

        //Alcir Alves - 04-05-05 - integração drawback
        IF EasyGParam("MV_EEC_EDC",,.F.)==.T. .AND. EasyGParam("MV_ENVMAIL",,.F.)==.T.
           //CRIA INDICE TEMPORÁRIO PARA TRATAMENTO DE ITENS NO ATO DE DRAWBACK
           //MFR 18/12/2018 OSSME-1974
           IndRegua("ED1", "ED1"+cRegNPAT+"0"+TeOrdBagExt(),"ED1_FILIAL+ED1_PROD")         
        ENDIF
        //
   case cfile == CAD_FF // Integracao de Fabricante / Fornecedor
        //MFR 18/12/2018 OSSME-1974
        FErase( "NFF"+cRegNPAT+"0"+TeOrdBagExt())
        FErase( "NFF"+cRegNPAT+"1"+TeOrdBagExt())
        cValOk:="NFFINT_OK='T'"
        cValRej:="! NFFINT_OK='T'"
        DBUSEAREA(.T.,"TOPCONN", "NFF"+cRegNPA,"Int_FF",.F.)
        IF NETERR()
           If !lSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else 
              ConOut(STR0038+"NFF"+cRegNPA ) // sidney
           Endif   
           RETURN .F.
        ENDIF

        IN100IndRg( {{"Int_FF" , "NFF"+cRegNPAT , {"NFFCOD","NFFINT_OK+NFFCOD"} }}   )
        cArqMemo:='IN_FF'+cRegNPA
        
   case cfile == CAD_LK  // Itens/Fabr./Forn.        
        //MFR 18/12/2018 OSSME-1974
        FErase( "NLK"+cRegNPAT+"0"+TeOrdBagExt())
        FErase( "NLK"+cRegNPAT+"1"+TeOrdBagExt())
        cValOk:="NLKINT_OK='T'"
        cValRej:="! NLKINT_OK='T'"
        DBUSEAREA(.T.,"TOPCONN", "NLK"+cRegNPA,"Int_LK",.F.)
        IF NETERR() 
           If !lSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else
              ConOut(STR0038+"NLK"+cRegNPA) // sidney
           Endif   
           RETURN .F.
        ENDIF        
        
        IN100IndRg( {{"Int_LK" , "NLK"+cRegNPAT , {"NLKCOD_I+NLKFABR+NLKFORN","NLKINT_OK+NLKCOD_I+NLKFABR+NLKFORN"} }}   )
        cArqMemo:='IN_LK'+cRegNPA
        
   case cfile == CAD_CL  // Clientes
        //MFR 18/12/2018 OSSME-1974
        FErase( "NCL"+cRegNPAT+"0"+TeOrdBagExt())
        FErase( "NCL"+cRegNPAT+"1"+TeOrdBagExt())
        cValOk:="NCLINT_OK='T'"
        cValRej:="! NCLINT_OK='T'"
        DBUSEAREA(.T.,"TOPCONN", "NCL"+cRegNPA,"Int_CL",.F.)
        IF NETERR()
           If !lSched  // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else
              ConOut(STR0038+"NCL"+cRegNPA) // sidney
           Endif   
           RETURN .F.
        ENDIF                        
        
        IN100IndRg( {{"Int_CL" , "NCL"+cRegNPAT , {"NCLCOD","NCLINT_OK+NCLCOD"} }}   )
        cArqMemo:='IN_CL'+cRegNPA
        
   case cfile == CAD_PE // Processos de Exportacao    
        //MFR 18/12/2018 OSSME-1974        
        FErase( "NPE"+cRegNPAT+"0"+TeOrdBagExt())
        FErase( "NPE"+cRegNPAT+"1"+TeOrdBagExt())
        cValOk:="NPEINT_OK='T'"
        cValRej:="! NPEINT_OK='T'"
        DBUSEAREA(.T.,"TOPCONN", "NPE"+cRegNPA,"Int_PE",.F.)
        IF NETERR()
           If !lSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else 
              ConOut(STR0038+"NPE"+cRegNPA) // sidney
           Endif   
           RETURN .F.
        ENDIF                      
        
        IN100IndRg( {{"Int_PE" , "NPE"+cRegNPAT , {"NPEPEDIDO+NPESEQ","NPEINT_OK+NPEPEDIDO+NPESEQ"} }}   )
        cArqMemo:='IN_PE'+cRegNPA

        If ! IN100ESTRU("PD")
           Int_PE->(dbcloseAREA())
           Return .F.
        EndIf
        //MFR 18/12/2018 OSSME-1974
        FErase( "NPD"+cRegNPAT+"0"+TeOrdBagExt())
        DBUSEAREA(.T.,"TOPCONN", "NPD"+cRegNPA,"Int_PD",.F.)
        IF NETERR()                                                             
           If !lSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           ELse 
              ConOut(STR0038+"NPD"+cRegNPA) // sidney
           Endif   
           Int_PE->(dbcloseAREA())
           RETURN .F.
        ENDIF   

        IN100IndRg( {{"Int_PD" , "NPD"+cRegNPAT , {"NPDPEDIDO+NPDSEQ+NPDSEQITEM","NPDPEDIDO+NPDSEQ+NPDPOSICAO"} }}   )

        DBSELECTAREA('Int_PD')

        aTmpStruct := DbStruct()
        E_CriaTrab(,aTmpStruct,"Temp")

        IF NETERR()
           If !lSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else 
              ConOut(STR0038+"TMPPD"+cRegNPAT) // sidney
           Endif   
           Int_PE->(dbcloseAREA())
           Int_PD->(dbcloseAREA())
           RETURN .F.
        ENDIF

   case cfile == CAD_FE // Integracao de Nota
        AADD(TB_Cols,{ {|| IN100StaIte()} ,"" ,STR0048}) //"Tem Item Rejeitado"
        cValOk:="NFEINT_OK = 'T' .AND. NFEITEM_OK = 'T'"
        cValRej:="! NFEINT_OK = 'T' .OR. ! NFEITEM_OK = 'T'"
        //MFR 18/12/2018 OSSME-1974
        FErase( "NFE"+cRegNPAT+"0"+TeOrdBagExt())
        FErase( "NFE"+cRegNPAT+"1"+TeOrdBagExt())
        DBUSEAREA(.T.,"TOPCONN", "NFE"+cRegNPA,"Int_FE",.F.)
        IF NETERR()                  
           If !lSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else 
              ConOut(STR0038+"NFE"+cRegNPA) // sidney
           Endif   
           RETURN .F.
        ENDIF

        IN100IndRg( {{"Int_FE" , "NFE"+cRegNPAT , {"NFENOTA+NFESERIE","NFEINT_OK+NFENOTA+NFESERIE"} }}   )
        cArqMemo:='IN_FE'+cRegNPA

        If ! IN100ESTRU("FG")
           Int_FE->(dbcloseAREA())
           Return .F.
        EndIf
        DBUSEAREA(.T.,"TOPCONN", "NFG"+cRegNPA,"Int_FG",.F.)
        IF NETERR()
           If !lSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else 
              Conout(STR0038+"NFG"+cRegNPA) // sidney
           Endif   
           RETURN .F.
        ENDIF

        If ! IN100ESTRU("FD")
           Int_FG->(dbcloseAREA())
           Int_FE->(dbcloseAREA())
           Return .F.
        EndIf
        //MFR 18/12/2018 OSSME-1974
        FErase( "NFD"+cRegNPAT+"0"+TeOrdBagExt())
        FErase( "NFD"+cRegNPAT+"1"+TeOrdBagExt())
        DBUSEAREA(.T.,"TOPCONN", "NFD"+cRegNPA,"Int_FD",.F.)
        IF NETERR()                  
           If !lSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else 
              ConOut(STR0038+"NFD"+cRegNPA) // sidney
           Endif   
           Int_FE->(dbcloseAREA())
           RETURN .F.
        ENDIF

        IN100IndRg( {{"Int_FD" , "NFD"+cRegNPAT , {"NFDNOTA+NFDSERIE"} }}   )   

        If Select("TEMP") > 0
           TEMP->(DbCloseArea())
        EndIf
        FErase("TmpFD"+cRegNPAT+GetDBExtension()) 
        DBSELECTAREA('Int_FD')

        aTmpStruct := DbStruct()
        E_CriaTrab(,aTmpStruct,"Temp")          

        IF NETERR()
           If !lSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else 
              ConOut(STR0038+"TMPFD"+cRegNPAT) // sidney
           Endif   
           Int_FG->(dbcloseAREA())
           Int_FE->(dbcloseAREA())
           Int_FD->(dbcloseAREA())
           RETURN .F.
        ENDIF
        
        IN100PesqVal()//LGS-04/03/2015 - Pesquisa se tem os campos "WN_NVE,WN_AC,WN_AFRMM" e busca os valores para integrar na NF.

   case cfile == CAD_NU // Recebimento de numerário
        AADD(TB_Cols,{ {|| IN100StaIte()} ,"" ,STR0048}) //"Tem Item Rejeitado"
        cValOk:="NNUINT_OK = 'T' .AND. NNUITEM_OK = 'T'"
        cValRej:="! NNUINT_OK = 'T' .OR. ! NNUITEM_OK = 'T'"
        //MFR 18/12/2018 OSSME-1974
        FErase( "NNU"+cRegNPAT+"0"+TeOrdBagExt())
        FErase( "NNU"+cRegNPAT+"1"+TeOrdBagExt())
        DBUSEAREA(.T.,"TOPCONN", "NNU"+cRegNPA,"Int_NU",.F.)
        IF NETERR()
           If !lSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else 
              ConOut(STR0038+"NNU"+cRegNPA) // sidney
           Endif   
           RETURN .F.
        ENDIF

        IN100IndRg( {{"Int_NU" , "NNU"+cRegNPAT , {"NNUREFDES","NNUINT_OK+NNUREFDES"} }}   )
        cArqMemo:='IN_NU'+cRegNPA

        If !IN100ESTRU("NG")
           Int_NU->(dbcloseAREA())
           Return .F.
        EndIf
        DBUSEAREA(.T.,"TOPCONN", "NNG"+cRegNPA,"Int_NG",.F.)
        IF NETERR()
           If !lSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else 
              ConOut(STR0038+"NNG"+cRegNPA) // sidney
           Endif   
           RETURN .F.
        ENDIF

        If ! IN100ESTRU("DN")
           Int_NG->(dbcloseAREA())
           Int_NU->(dbcloseAREA())
           Return .F.
        EndIf
        //MFR 18/12/2018 OSSME-1974
        FErase( "NDN"+cRegNPAT+"0"+TeOrdBagExt())
        FErase( "NDN"+cRegNPAT+"1"+TeOrdBagExt())
        DBUSEAREA(.T.,"TOPCONN", "NDN"+cRegNPA,"Int_DN",.F.)
        IF NETERR()  
           If !lSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else 
              ConOut(STR0038+"NDN"+cRegNPA) // sidney
           Endif   
           Int_NU->(dbcloseAREA())
           RETURN .F.
        ENDIF                    

        IN100IndRg( {{"Int_DN" , "NDN"+cRegNPAT , {"NDNREFDES+NDNDESPESA"} }}   )  

        If Select("TEMP") > 0
           TEMP->(DbCloseArea())
        EndIf
        FErase("TmpDN"+cRegNPAT+GetDBExtension())
        DBSELECTAREA('Int_DN')

        aTmpStruct := DbStruct()
        E_CriaTrab(,aTmpStruct,"Temp")

        IF NETERR()                  
           If !Lsched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else 
              ConOut(STR0038+"TMPDN"+cRegNPAT) // sidney
           Endif   
           Int_NG->(dbcloseAREA())
           Int_NU->(dbcloseAREA())
           Int_DN->(dbcloseAREA())
           RETURN .F.
        ENDIF
   CASE cfile == CAD_NS  // NOTAS FISCAIS DE SAIDA
        //MFR 18/12/2018 OSSME-1974
        FErase( "NNS"+cRegNPAT+"0"+TeOrdBagExt())
        FErase( "NNS"+cRegNPAT+"1"+TeOrdBagExt())
        cValOk  := "NNSINT_OK='T'"
        cValRej := "! NNSINT_OK='T'"
        DBUSEAREA(.T.,"TOPCONN", "NNS"+cRegNPA,"Int_NS",.F.)
        IF NETERR()
           If !lSched
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else
              ConOut(STR0038+"NNS"+cRegNPA)
           Endif   
           RETURN(.F.)
        Endif

        IN100IndRg( {{"Int_NS" , "NNS"+cRegNPAT , {"NNSPRO","NNSINT_OK+NNSPRO"} }}   )
        cArqMemo:='IN_NS'+cRegNPA

   CASE cFILE == CAD_NC  // NOTAS FISCAIS COM ITENS
        //MFR 18/12/2018 OSSME-1974
        FErase("NNC"+cRegNPAT+"0"+TeOrdBagExt())
        FErase("NNC"+cRegNPAT+"1"+TeOrdBagExt())
        cValOk  := "NNCINT_OK='T'"
        cValRej := "! NNCINT_OK='T'"
        DBUSEAREA(.T.,"TOPCONN","NNC"+cRegNPA,"Int_NC",.F.)
        IF NETERR()
           If !lSched
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else 
              ConOut(STR0038+"NNC"+cRegNPA)
           Endif   
           RETURN(.F.)
        ENDIF                      

        IN100IndRg( {{"Int_NC" , "NNC"+cRegNPAT , {"NNCPRO+NNCSER+NNCNF+NNCREC","NNCINT_OK+NNCPRO+NNCSER+NNCNF+NNCREC"} }}   )
        cArqMemo := 'IN_NC'+cRegNPA

        If ! IN100ESTRU("ND")
           Int_NC->(dbcloseAREA())
           Return(.F.)
        EndIf
        //MFR 18/12/2018 OSSME-1974 
        FErase("NND"+cRegNPAT+"0"+TeOrdBagExt())
        DBUSEAREA(.T.,"TOPCONN","NND"+cRegNPA,"Int_ND",.F.)
        IF NETERR()                                                             
           If !lSched
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           ELse 
              ConOut(STR0038+"NND"+cRegNPA)
           Endif   
           Int_NC->(dbcloseAREA())
           RETURN(.F.)
        ENDIF   

        IN100IndRg( {{"Int_ND" , "NND"+cRegNPAT , {"NNDPRO+NNDSER+NNDNF+NNDREC"} }}   )

        DBSELECTAREA('Int_ND')

        aTmpStruct := DbStruct()
        E_CriaTrab(,aTmpStruct,"Temp")

        IF NETERR()
           If !lSched
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else 
              ConOut(STR0038+"TEMPND"+cRegNPAT)
           Endif   
           Int_NC->(dbcloseAREA())
           Int_ND->(dbcloseAREA())
           RETURN(.F.)
        ENDIF
****************
*** DrawBack ***
****************
   case cfile == CAD_EP  // Estrutura do Produto
        //MFR 18/12/2018 OSSME-1974
        FErase("NEP"+cRegNPAT+"0"+TeOrdBagExt())
        FErase("NEP"+cRegNPAT+"1"+TeOrdBagExt())
        cValOk:="NEPINT_OK='T'"
        cValRej:="! NEPINT_OK='T'"
        DBUSEAREA(.T.,"TOPCONN","NEP"+cRegNPA,"Int_EP",.F.)
        IF NETERR()                 
           If !lSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else 
              Conout(STR0038+"NEP"+cRegNPA) // sidney
           Endif   

           RETURN .F.
        ENDIF

        IN100IndRg( {{"Int_EP" , "NEP"+cRegNPAT , {"NEPPROD+NEPSEQ+NEPITEM","NEPINT_OK+NEPPROD+NEPSEQ+NEPITEM"} }}   )
        cArqMemo:='IN_EP'+cRegNPA

   Case cfile == CAD_CE  // Intermediário / Solidário
        //MFR 18/12/2018 OSSME-1974
        FErase("NCE"+cRegNPAT+"0"+TeOrdBagExt())
        FErase("NCE"+cRegNPAT+"1"+TeOrdBagExt())
        FErase("NCE"+cRegNPAT+"2"+TeOrdBagExt())
        FErase("NCE"+cRegNPAT+"3"+TeOrdBagExt())
        cValOk:="NCEINT_OK='T'"
        cValRej:="! NCEINT_OK='T'"
        DBUSEAREA(.T.,"TOPCONN","NCE"+cRegNPA,"Int_CE",.F.)
        IF NETERR()                 
           If !lSched 
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else 
              Conout(STR0038+"NCE"+cRegNPA) 
           Endif   

           RETURN .F.
        ENDIF

        aLstIndic := {"NCECNPJ","NCEINT_OK+NCECNPJ","NCELINUM+NCEDINUM+NCEAD+NCEAC+NCESEQS", "NCEDINUM+NCEPOSDI+NCEAD", "NCEPED+NCEPOSDI"}
        If AVFLAGS("SEQMI")
           aAdd(aLstIndic,"NCELINUM+NCEDINUM+NCEAD+NCEAC+NCESEQMI")
        EndIf
        IN100IndRg( {{"Int_CE" , "NCE"+cRegNPAT , aLstIndic }}   ) 
        cArqMemo:='IN_CE'+cRegNPA

   case cFile == CAD_UC  // Unidade de Medida Conversão
        //MFR 18/12/2018 OSSME-1974
        FErase("NUC"+cRegNPAT+"0"+TeOrdBagExt())
        FErase("NUC"+cRegNPAT+"1"+TeOrdBagExt())
        cValOk:="NUCINT_OK='T'"
        cValRej:="! NUCINT_OK='T'"
        DBUSEAREA(.T.,"TOPCONN","NUC"+cRegNPA,"Int_UC",.F.)
        IF NETERR()                 
           If !lSched // sidney
              IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
           Else 
              Conout(STR0038+"NUC"+cRegNPA) // sidney
           Endif   

           RETURN .F.
        ENDIF

        IN100IndRg( {{"Int_UC" , "NUC"+cRegNPAT , {"NUCUMDE+NUCUMPARA+NUCPRODUTO","NUCINT_OK+NUCUMDE+NUCUMPARA+NUCPRODUTO"} }}   )
        cArqMemo:='IN_UC'+cRegNPA

   case cFile == CAD_NR  // RE EXTERNAS -- AWR - 08/04/2009
        //MFR 18/12/2018 OSSME-1974
        FErase("NNR"+cRegNPAT+"0"+TeOrdBagExt())
        FErase("NNR"+cRegNPAT+"1"+TeOrdBagExt())
        cValOk:="NNRINT_OK='T'"
        cValRej:="! NNRINT_OK='T'"
        DBUSEAREA(.T.,"TOPCONN","NNR"+cRegNPA,"Int_NR",.F.)
        IF NETERR()                 
           If !lSched
              IN_MSG("Nao foi possivel abrir o arquivo: NNR"+cRegNPA+".DBF",STR0039) //"Informação"
           Else 
              Conout("Nao foi possivel abrir o arquivo: NNR"+cRegNPA+".DBF")
           Endif   

           RETURN .F.
        ENDIF

        IN100IndRg( {{"Int_NR" , "NNR"+cRegNPAT , {"NNRRE+NNRPOSICA","NNRINT_OK+NNRRE+NNRPOSICA"} }}   )
        cArqMemo:='IN_NR'+cRegNPA

endcase

lSair:=.F.//AWR - 27/01/2006
If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"ABRIR")
// If ! ExecBlock("IN100CLI",.F.,.F.,"ABRIR")
//    Return .f.
// EndIf
EndIf
IF lSair
   Return .f.
EndIf

AADD(TB_Cols,{ {|| IN100CTD(EVAL(bDtInteg))} , "" , STR0071 }) //"Dt Integ"

IF cArqMemo#'NAO TEM'
   cArqMemo+='.MEM'
   /*IF FILE( cArqMemo) .And. !TETempBanco() 
      restore from ( cArqMemo) additive
   ENDIF*/
ENDIF
return .t.
*---------------------------------------------------------------------------------------
Function IN100IntID()
*---------------------------------------------------------------------------------------
If ! IN100ESTRU("ID")
   Return .F.
Endif
//MFR 18/12/2018 OSSME-1974
FErase( "NID"+cRegNPAT+"0"+TeOrdBagExt())
DBUSEAREA(.T.,"TOPCONN", "NID"+cRegNPA,"Int_ID",.F.)
If NETERR()
   IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
   RETURN .F.
Endif

IN100IndRg( {{"Int_ID" , "NID"+cRegNPAT , {"NIDCOD_I"} }}   )

DBSELECTAREA('Int_ID')
aTmpStruct := DbStruct()
E_CriaTrab(,aTmpStruct,"Temp")

IF NETERR()
  IN_MSG(STR0038,STR0039) //"Arquivo n„o disponivel ..."###"Informação"
  Int_ID->(dbcloseAREA())
  RETURN .F.
ENDIF

Return .T.
*---------------------------------*
STATIC FUNCTION IN100_Fecha(cFile)
*---------------------------------*
//JVR - 04/02/10
Local lEraseTemp:= .F.
Local cEraseArq := ""

do case
   case cfile == CAD_CI
        Int_CI->(dbcloseAREA())
        If Select("Int_ID") > 0                                           //MJB-SAP-1200
           Int_ID->(dbcloseAREA())                                        //MJB-SAP-1200
           lEraseTemp:= .T.
           cEraseArq := "TMPID"+cRegNPAT
        Endif                                                             //MJB-SAP-1200
        
   case cfile == CAD_FB
        Int_FB->(dbcloseAREA())

   case cfile == CAD_NB
        Int_NB->(dbcloseAREA())

   case cfile == CAD_TC
        Int_TC->(dbcloseAREA())

   case cfile == CAD_PO
        Int_PO->(dbcloseAREA())
        Int_IP->(dbcloseAREA())
        SWU->(dbcloseAREA())
        lEraseTemp:= .T.
        cEraseArq := "TMPIP"+cRegNPAT

   case cfile == CAD_SI
        Int_SI->(dbcloseAREA())
        Int_IS->(dbcloseAREA())
        SWU->(dbcloseAREA())
        lEraseTemp:= .T.
        cEraseArq := "TMPIS"+cRegNPAT  //ACB - 25/02/2010

   case cfile == CAD_LI
        Int_LI->(dbcloseAREA())

   case cfile == CAD_FP
        Int_FP->(dbcloseAREA())

   case cfile == CAD_DE
        If !lSched
           Processa({||.t.,STR0072}) //"Atualização de Cadastros"
        EndIf
        Int_DE->( DbCloseAREA() )
        Int_DspHe->( DbCloseAREA() )
        Int_DspDe->( DbCloseAREA() )
        Int_DspTx->( DbCloseAREA() )
        lEraseTemp:= .T.
        cEraseArq := "TMPNDD"+cRegNPAT

   case cfile == CAD_DI
        Int_DI->(dbcloseAREA())

   case cfile == CAD_CC
        Int_CC->(dbcloseAREA())

   case cfile == CAD_CL
        Int_CL->(dbcloseAREA())

   case cfile == CAD_FF
        Int_FF->(dbcloseAREA())

   case cfile == CAD_IT
        Int_IT->(dbcloseAREA())
        Int_ID->(dbcloseAREA())
        lEraseTemp:= .T.
        cEraseArq := "TMPID"+cRegNPAT
        
   case cfile == CAD_LK
        Int_LK->(dbcloseAREA())
        
   case cfile == CAD_PE
        Int_PE->(dbcloseAREA())
        Int_PD->(dbcloseAREA())
        lEraseTemp:= .T.
        cEraseArq := "TMPPD"+cRegNPAT
        
   case cfile == CAD_NF
        Int_NF->(dbcloseAREA())
   case cfile == CAD_TP
		  Int_TP->(dbcloseAREA())
   case cfile == CAD_FE
        Int_FE->(dbcloseAREA())
        Int_FD->(dbcloseAREA())
        Int_FG->(dbcloseAREA())
        lEraseTemp:= .T.
        cEraseArq := "TMPFD"+cRegNPAT
                
   case cfile == CAD_NU
        Int_NU->(dbcloseAREA())
        Int_DN->(dbcloseAREA())
        Int_NG->(dbcloseAREA())
        lEraseTemp:= .T.
        cEraseArq := "TMPDN"+cRegNPAT
                
   CASE cFILE == CAD_NS
        INT_NS->(DBCLOSEAREA())

   CASE cFILE == CAD_NC
        INT_NC->(DBCLOSEAREA())
        INT_ND->(DBCLOSEAREA())
        lEraseTemp:= .T.
        cEraseArq := TETempName("Temp")
                
****************
*** DrawBack ***
****************

   case cFile == CAD_EP
        Int_EP->(dbcloseAREA())

   case cFile == CAD_CE
        Int_CE->(dbcloseAREA()) 
        //ASK 08/11/07
        #IFNDEF TOP
           //MFR 18/12/2018 OSSME-1974
           FERASE(cIndexSAH+TeOrdBagExt())
        #ELSE
           dbSelectArea("SAH")
           SAH->(DbCloseArea())
        #ENDIF

   case cFile == CAD_UC
        Int_UC->(dbcloseAREA())

   CASE cFILE == CAD_NR//AWR - 08/04/2009
        INT_NR->(DBCLOSEAREA())

endcase

//JVR - 04/02/10 - verifica se arquivo esta realmente aberto, antes de fecha-lo.
If lEraseTemp
   If Select("Temp") > 0 // ACB - 25/02/2010
      Temp->( E_ERASEARQ(StrTran(TETempName("Temp"),".",""),,,,) )
   EndIf
EndIf

DbSelectArea('SX3')

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"FECHAR")
EndIf
      
Return .T.

*-----------------------------------------------------------------------------------------*
FUNCTION IN100Integ(lPreviaTF,bGravaDBF) //MJB-SAP-0800
*-----------------------------------------------------------------------------------------*
LOCAL cAreaH:='Int_'+cFuncao, cAreaD, cNameH, cNameD, nRec:=0, Cont:=0, nAuxI:=1
LOCAL cAreaI,cNameI
LOCAL bLer, bGravar, cArq:=cFuncao, dInteg, cAlias:=ALIAS(), cAlias2,;
      lEEC
LOCAL bDDMMAA :={|cName| If(cName$"DDMMAA/DDAAMM/AADDMM/AAMMDD/MMAADD/MMDDAA",;
                         (cName:=STRTRAN(RTRIM(cName),'DD',cDD),;
                         cName:=STRTRAN(cName,'MM',cMM),;
                         cName:=STRTRAN(cName,'AA',cAA)),cName), cName }

//LOCAL bFor:=FIELDWBLOCK('N'+cFuncao+'INT_OK',SELECT(cAreaH))
LOCAL bFor:={|x| If(x=nil,(cAreaH)->&('N'+cFuncao+'INT_OK')="T",(cAreaH)->&('N'+cFuncao+'INT_OK'):=x)}
LOCAL cPointE := "EICW0COD", lPointE := EasyEntryPoint(cPointE), nTabCont

Private DtUlt
PRIVATE bmsg:={|msg,lAviso| cmsg:=IF(lAviso=NIL,cErro,cAviso),;
                          IF(cmsg =NIL, cMsg:=PADR(MSG,LEN_MSG)+NewLine,;
                                        cMsg+=PADR(MSG,LEN_MSG)+NewLine),;
                          IF(lAviso=NIL,cErro:=cMSG,cAviso:=cMSG) }

PRIVATE cmsg, cAviso, cErro, lModelo:=.F., cSaveKey, aRelIN100Cli:={}
Private nProcDesp:="", aSaldoAC:={}, aEstProd:={}
Private nCont    := 1, cCodCC:="", lSair:=.F. // p/ uso no rdmake IN100CLI - "EXISTE_ARQ"
Private lStop    := .F. //LRL 25/10/04 
Private aArrayAux:={}, aArrayAux2:={}  //Para uso genérico nos pontos de entrada.
Private lControlUser := EasyGParam("MV_AVG0097",,.f.)//JPM - 11/07/05 - Se .t., não permite que 2 usuários façam uma mesma integração ao mesmo tempo.
Private aNotas:={}
Private aSeqCapa := {}, aSeqItem := {}, aValCapa := {}, aCapaErro := {}  // By JPP - 29/11/2006 - 12:00

lPrevia:=lPreviaTF

// ** JPM - 11/07/05 - Verifica se a opção não está sendo utilizada por outro usuário, e faz tratamentos para espera.
If lControlUser .And. !lPrevia
   If Type("nOpcao") = "N" .And. nOpcao <= Len(aOpcoes)
      If !In100Control(cArq,cRegNPA)
         Return .f.
      EndIf
   Else
      lControlUser := .f.
   EndIf
EndIf
// **

('Int_'+cFuncao)->(DBSETORDER(1))
IF cFuncao = CAD_DE
   Int_DspHe->(DBSETORDER(1))
ELSEIF cFuncao = CAD_NU
   Int_NU->(DBSETORDER(1))
   Int_NU->(DBGOTOP())
Endif

IF lMsmm
   cAlias2:=ALIAS()
   SYP->(DBCLOSEAREA())
   If ! ChkFile("SYP",.T.) 
      IN_MSG(STR0073,STR0039) //"Arquivo de campos memo nÆo dispon¡vel para abertura exclusiva ..."###"Informação"
      ChkFile("SYP",.F.)
      DBSELECTAREA(cAlias2)
      IN100Unlock() // JPM - 11/07/05
      RETURN .F.
   ENDIF
   nNumMsmm:=VerNumMsmm()
   DBSELECTAREA(cAlias2)
ENDIF

aTabFabFor:={}
aMoeProcTx:={}

bGravar:={|| If(!lRdmake,&("IN100Grv"+cFuncao+"()"),IN100GRVRD()),if(type("bUpDate")=="B", If(FindFunction("AvIntExtra"), EasyExRdm("AvIntExtra"), ),) , dInteg:=EVAL(bDtInteg) }

nResumoCer :=0
nResumoErr :=0
nResumoAlt :=0
nResumoInic:=Time()
nResumoFim :=Time()
nResumoData:=dDataBase
nResumoArq :=''

If cFuncao = CAD_SI
   cAreaD :='Int_IS'
   cArq   :='SP'
   cNameH :=ALLTRIM(Int_Param->NPAARQ_H)
   cNameD :=ALLTRIM(Int_Param->NPAARQ_I)
   DtUlt  :=Int_Param->NPAULT_SP

ElseIf  cFuncao = CAD_FE
        cArq   :='FE'
        cAreaD :='Int_FD'
        cNameH :=ALLTRIM(Int_Param->NPAARQ_FE)
        cNameD :="NAOHA"
        DtUlt  :=Int_Param->NPAULT_FE

ElseIf  cFuncao = CAD_NU
        cArq   :='NU'
        cAreaD :='Int_DN'
        cNameH :=ALLTRIM(Int_Param->NPAARQ_NU)
        cNameD :="NAOHA"
        DtUlt  :=Int_Param->NPAULT_NU
        SW6->(DbSetOrder(9))
        SJ0->(DbSetOrder(1))
        SJA->(DbSetOrder(1))        

ElseIf  cFuncao = CAD_PO
        cArq   :='SP'
        cAreaD :='Int_IP'
        cNameH :=ALLTRIM(Int_Param->NPAARQ_H)
        cNameD :=ALLTRIM(Int_Param->NPAARQ_I)
        DtUlt  :=Int_Param->NPAULT_SP
        SYE->(DbSetOrder(2))  //MJB-SAP-0900

        Private aTabReg:={} // AST - 02/04/09 - Declaração movida da função IN100LerPO, na alteração do PO com integração BPCS,
                            // é criada uma capa para cada detalhe, na alteração dos itens identicos, o campo W3_REG estava sendo gravado com 1 para todos os itens.

ElseIf cFuncao = CAD_IT
   cAreaD :='Int_ID'   
   cNameH :=ALLTRIM(Int_Param->NPAARQ_IT)
   cNameD :=If(EMPTY(ALLTRIM(Int_Param->NPAARQ_ID)),"NAOHA",ALLTRIM(Int_Param->NPAARQ_ID))
   DtUlt  :=Int_Param->NPAULT_IT

ElseIf cFuncao = CAD_PE
   cAreaD :='Int_PD'   
   cNameH :=ALLTRIM(Int_Param->NPAARQ_PE)
   cNameD :=ALLTRIM(Int_Param->NPAARQ_PD)
   DtUlt  :=Int_Param->NPAULT_PE   
   SYC->(DbSetOrder(4))                                                   //MJB-SAP-1100
ELSEIF cFUNCAO = CAD_NC
       cAREAD := 'INT_ND'
       cNAMEH := ALLTRIM(INT_PARAM->NPAARQ_NC)
       cNAMED := ALLTRIM(INT_PARAM->NPAARQ_ND)
       dTULT  := INT_PARAM->NPAULT_NC

ElseIf  cFuncao = CAD_DE
        cArq   :='DE'
        cAreaD :='Int_DspDe'
        cAreaI := 'Int_DspTx'
        cNameH := ALLTRIM(Int_Param->NPAARQ_DE)
        cNameI := "NAOHA"
        cNameD := "NAOHA"
        DtUlt  :=Int_Param->NPAULT_DE
ElseIf cFuncao = CAD_FF //*** GFP 26/08/2011 - Integração Fabricantes/Fornecedores
    cArq   :='FF'
    cAreaD :='Int_FF'
    cNameD := "NAOHA" //LRS - 30/10/2013
    cNameH := ALLTRIM(Int_Param->NPAARQ_FF)
    DtUlt  :=Int_Param->NPAULT_FF

ElseIf lRdmake
   If EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"ARQTXT")
   ENDIF
   For nAuxI:=1 TO LEN(aRelIN100Cli)
       Eval(MEMVARBLOCK(aRelIN100Cli[nAuxI,1]),aRelIN100Cli[nAuxI,2])
   Next

ELSE
   DtUlt  :=EVAL(FIELDWBLOCK('NPAULT_'+cFuncao,SELECT('Int_Param')))
   cNameH :=Int_Param->(ALLTRIM(FieldGet(FieldPos('NPAARQ_'+cFuncao))))
   cNameD :=""
   EVAL(FIELDWBLOCK('NPAULT_'+cFuncao,SELECT('Int_Param')))
ENDIF

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"APPEND")
ENDIF

If bGravaDBF <> NIL //MJB-SAP-0800 
   Eval(bGravaDBF)
Endif


// BAK - Alteração para a nova integração com despachante
If lIntDesp .And. ChkFile("EWZ") .And. ChkFile("EWQ")
   cPath     := "\comex\IntDespachante\recebidos\"
   lPrvEI100 := lPrevia
   cNameH    := SubStr(cFileEICEI100,1,At(".TXT",UPPER(cFileEICEI100))-1)
EndIf

If lAppend
   IF EMPTY(cNameH:=EVAL(bDDMMAA,cNameH))
      IN_MSG(STR0075,STR0039) //"Arquivo de entrada n„o informado. Vide parƒmetros."###"Informação"
      /*If !TEtempbanco()
         save to ( cArqMemo) all like nResumo*
      End*/
      IN100Unlock() // JPM - 11/07/05
      RETURN .F.
   ELSEIF !FILE(cPath+(if(".TXT"$Upper(cNameH),cNameH,cNameH+='.TXT'))) // BAK - alteração para exibir a extensao do arquivo correto//!FILE(cPath+(cNameH+='.TXT'))
      IN_MSG(STR0077+cPath+cNameH+STR0078,STR0039) //"Arquivo "###" n„o encontrado."###"Informação"
      /*If !TEtempbanco()
         save to ( cArqMemo) all like nResumo*
      EndIf*/
      IN100Unlock() // JPM - 11/07/05
      RETURN .F.
   ElseIf FILE(cPath+cNameH) .and. !(upper(alltrim(cPath)) == upper(alltrim(cDirStart)))
      If File(cDirStart+cNameH)
         FErase(cDirStart+cNameH)
      EndIf

      If !AvCpyFile(cPath+cNameH, cDirStart+cNameH, lSched)
            IN_MSG(STR0680+cPath+cNameH) //"Ocorreram erros na cópia do arquivo de integração "
            /*If !TEtempbanco()
               save to (cArqMemo) all like nResumo*
            EndIf*/
            IN100Unlock() // JPM - 11/07/05
            Return .F.
      EndIf
   ENDIF
   If(EasyEntryPoint("IN100CLI"),ExecBlock("IN100CLI",.F.,.F.,"EXISTE_ARQ"),)
   IF lSair
      IN100Unlock() // JPM - 11/07/05
      RETURN .F.
   ENDIF
   IF cAreaD # NIL .AND. cNameD # "NAOHA"
      IF cAreaD # NIL
         IF EMPTY(cNameD:=EVAL(bDDMMAA,cNameD))
            IN_MSG(STR0080,STR0039) //"Arquivo detalhe n„o informado. Vide parƒmetros."###"Informação"
            /*If !TEtempbanco()
               save to ( cArqMemo) all like nResumo*
            EndIf*/
            IN100Unlock() // JPM - 11/07/05
            RETURN .F.
         ELSEIF ! FILE(cPath+(cNameD+='.TXT'))
            IN_MSG(STR0082+cNameD+STR0078,STR0039) //"Arquivo detalhe "###" n„o encontrado."###"Informação"
            /*If !TEtempbanco()
               save to ( cArqMemo) all like nResumo*
            EndIf*/
            IN100Unlock() // JPM - 11/07/05
            RETURN .F.
         ElseIf FILE(cPath+cNameD) .and. !(cPath == cDirStart)
            If File(cDirStart+cNameD)
               FErase(cDirStart+cNameD)
            EndIf

            If !AvCpyFile(cPath+cNameD, cDirStart+cNameD, lSched)
               IN_MSG(STR0680+cPath+cNameD) //"Ocorreram erros na cópia do arquivo de integração "
               /*If !TEtempbanco()
                  save to (cArqMemo) all like nResumo*
               EndIf*/
               IN100Unlock() // JPM - 11/07/05
               Return .F.
            EndIf
         ENDIF
      ENDIF
   ENDIF

   If cFuncao = CAD_FE
      Int_FG->(IN100Append(cNameH,"1"))                                                                   
      //bForFE:={|cTp|IF(!lParam,IncProc(STR0087+cTp+STR0088+str(nCont++)),),Int_FG->NFGTIPO=cTp}
      bForFE:={|cTp|IF(!lParam,IncProc(),),Int_FG->NFGTIPO=cTp}
      If !lSched
      	 Processa({|| IN100Copy('Int_FG',@cNameH,@cNameD,bForFE,{'1','2'}) })
      Else
      	 IN100Copy('Int_FG',@cNameH,@cNameD,bForFE,{'1','2'})
      EndIf
   ElseIf cFuncao = CAD_NU
      Int_NG->(IN100Append(cNameH,"1"))
      bForNU:={|cTp|IF(!lParam,IncProc(STR0087+cTp+STR0088+str(nCont++)),),Int_NG->NNGTIPOREG = cTp}
      If !lSched
      	 Processa({||IN100Copy('Int_NG',@cNameH,@cNameD, bForNU,{"NU","DN"})})
      Else                                                                    
      	 IN100Copy('Int_NG',@cNameH,@cNameD, bForNU,{"NU","DN"})
      EndIf   						
   ElseIf cFuncao = CAD_DE //RHP
      Int_DE->(IN100Append(cNameH,"1"))                                                                   
      bForDE:={ |cTp| IF(!lParam,IncProc(STR0087+cTp+STR0088+str(nCont++)),),Int_DE->NDETIPOREG=cTp}

         If !lSched
            Processa({|| IN100Copy('Int_DE',@cNameH,@cNameD,bForDE,{"DI","DE","TX"},@cNameI) })
         Else
           IN100Copy('Int_DE',@cNameH,@cNameD,bForDE,{"DI","DE","TX"},@cNameI)
         EndIf
         cAreaH :='Int_DspHe'
         (cAreaH)->(DBGOTOP())
   ENDIF

   (cAreaH)->(IN100Append(cNameH,"1"))
   DBSELECTAREA((cAreaD))
   IF cAreaD # NIL .AND. cNameD # "NAOHA"
      (cAreaD)->(IN100Append(cNameD,"2"))
      IF cFuncao = CAD_PO .And. lPointE // *** CAF OS.1136/98 28/09/1998 15:24
         ExecBlock(cPointE)
      EndIf
   ENDIF
   DBSELECTAREA((cAreaI))  
   IF cAreaI # NIL .AND. cNameI # "NAOHA"
      (cAreaI)->(IN100Append(cNameI,"2"))
   ENDIF                 
   DBSELECTAREA((cAreaH))

   If cFuncao = CAD_FE
      aNotas:={}
      FERASE(cNameH)
      FERASE(cNameD)
      FERASE(LEFT(cNameH,8)+'.OLD')
      FERASE(LEFT(cNameD,8)+'.OLD')
      //ASR 29/08/2005 - INICIO DO TRATAMENTO DE LIMPEZA DO CAMPO SW6->W6_VL_NF QUANDO A NOTA FOR DO TIPO ENTRADA OU 
      IF lPrevia == .F.
         aOrdSW6 := SaveOrd({"SW6"})
         SW6->(DBSetOrder(1))
         nRecNoInt_FE := Int_FE->(RECNO())
         Int_FE->(DBGoTop())
         DO WHILE !Int_FE->(EOF())
            IF INT_FE->NFEESPECIE = "NFE" .OR. INT_FE->NFEESPECIE = "NFU"
               IF SW6->(DBSeek(cFilSW6+AvKey(Int_FE->NFEHAWB,"W6_HAWB")))
                  SW6->(RECLOCK("SW6",.F.))
                  SW6->W6_VL_NF := 0
                  SW6->(MSUNLOCK())
               ENDIF	                                                    
            ENDIF
            Int_FE->(DBSkip())
         ENDDO
         RestOrd(aOrdSW6)
         Int_FE->(DBGoTo(nRecNoInt_FE))
      ENDIF

      MDI_PESO := 0
      MDI_PESOL:= 0
      MDI_TOTNF:= 0
      INT_FD->(dbgotop())
      while !Int_FD->(EOF())
         //if INT_FD->NFDNOTA + INT_FD->NFDSERIE == INT_FE->NFENOTA + INT_FE->NFESERIE
            MDI_PESO += val(INT_FD->NFDQUANT) * val(INT_FD->NFDPESOL)
            MDI_PESOL+= val(INT_FD->NFDPESOL)
            If lRateioCIF
               MDI_TOTNF +=  val(INT_FD->NFDFOBRS) + val(INT_FD->NFDFRETE) + val(INT_FD->NFDSEGURO)
            Else
               MDI_TOTNF +=  val(INT_FD->NFDFOBRS)
            EndIf
         //endif
         Int_FD->(DBSkip())
      enddo
      
      IN100PesqVal()//LGS-04/03/2015 - Pesquisa se tem os campos "WN_NVE,WN_AC,WN_AFRMM" e busca os valores para integrar na NF.
   
   ENDIF

ENDIF

cSaveKey:=""

lSair:=.F.
If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"FIMAPPEND")
   For nAuxI:=1 TO LEN(aRelIN100Cli)
       Eval(MEMVARBLOCK(aRelIN100Cli[nAuxI,1]),aRelIN100Cli[nAuxI,2])
   Next
EndIf
IF lSair
   IN100Unlock() // JPM - 11/07/05
   RETURN .F.
ENDIF
lProcessa:=.T.
(cAreaH)->(DBGOTOP())
IF cAreaD # NIL .AND. cNameD # "NAOHA"
   (cAreaD)->(DBGOTOP())
ENDIF
IF cAreaI # NIL .AND. cNameI # "NAOHA"
   (cAreaI)->(DBGOTOP())
ENDIF

If !lParam                                 //MJB-SAP-0800
//   Processa({||(cAreaH)->(DBEVAL(bLer))}) //ASR 09/12/2005
    DBSELECTAREA(cAreaH)
	While !(cAreaH)->(Eof())
		IF lProcessa .AND. !lParam
		   nRec := 1
		   ProcRegua(Easyreccount(cAreaH)-1 + IF(cFuncao=CAD_PO,Int_IP->(Easyreccount("Int_IP")),0))
		Endif   
		IF !lParam
		   IncProc(STR0074+PADL(nRec++,5,'0')+" de "+PADL(nTotRegua,5,'0') )
		Endif   
		IN100Geral(DtUlt)
		If !lRdmake 
		   // BAK - Alterção para nova integração com despachante      
		   //&("IN100Ler"+cFuncao+"()") 
           If lIntDesp
              cStatusEI100 := &("IN100Ler"+cFuncao+"()") 
           Else
              &("IN100Ler"+cFuncao+"()") 
           EndIf
		Else 
		   IN100LERRD()
		Endif   
		lProcessa := .F.
		cAviso := NIL
		cErro := NIL
		(cAreaH)->(DBSkip())
	End
Else   
   lProcessa := .F.                          //MJB-SAP-0800
	bWhile:={|| .T. } //ASR 17/01/2006 - bWhile := NIL
   IF lSched
      bWhile := {|| !KillApp() }
   ENDIF
   //(cAreaH)->(DBEVAL(bLer,,bWhile))                //MJB-SAP-0800 //ASR 09/12/2005
    DBSELECTAREA(cAreaH)
	While !(cAreaH)->(Eof()) .AND. EVAL(bWhile)
		IF lProcessa .AND. !lParam
		   nRec := 1
		   ProcRegua(Easyreccount(cAreaH)-1 + IF(cFuncao=CAD_PO,Int_IP->(Easyreccount("Int_IP")),0))
		Endif   
		IF !lParam
		   IncProc(STR0074+PADL(nRec++,5,'0')+" de "+PADL(nTotRegua,5,'0') )
		Endif   
		IN100Geral(DtUlt)
		If !lRdmake 
		   &("IN100Ler"+cFuncao+"()")
		Else 
		   IN100LERRD()
		Endif   
		lProcessa := .F.
		cAviso := NIL
		cErro := NIL
		(cAreaH)->(DBSkip())
	End
Endif

If(EasyEntryPoint("IN100CLI"),ExecBlock("IN100CLI",.F.,.F.,"DEPOIS_IN100LER"),) // AWR - 24/07/08
nResumoFim := Time()
/*If !TEtempbanco()
   save to (cArqMemo) all like nResumo*
EndIf*/

(cAreaH)->(DBGOTOP())
IF cAreaD # NIL .AND. cNameD # "NAOHA"
   (cAreaD)->(DBGOTOP())
ENDIF

IF cAreaI # NIL .AND. cNameI # "NAOHA"
   (cAreaI)->(DBGOTOP())
ENDIF

IF cFuncao = CAD_DE   //ACD
   Int_DspHe->( DbGoTop() )
ENDIF

DBSELECTAREA(cAlias)

If !lParam                                 //MJB-SAP-0800
   oMark:oBrowse:gotop()
Endif

IF lPrevia
   lLidoTXT := .T.
   SYP->(DBCLOSEAREA())
   If ! ChkFile("SYP",.F.)
      IN_MSG(STR0084,STR0039) //"Arquivo de campos memo nao disponivel ..."###"Informação"
   ENDIF
   DBSELECTAREA(cAlias)
   If lMostraResumo
      IN100RESUMO()
   EndIf
   If EasyEntryPoint("EICIN100") //CCH - 03/10/2008 - Inclusão de Ponto de Entrada conforme solicitado por Julio Paz
      ExecBlock("EICIN100",.F.,.F.,"PE_FIM_PREVIA")
   EndIf   
   RETURN .T.
ENDIF

Cont:=0

nTotRegua:=(cAreaH)->(Easyreccount(cAreaH))
IF(cFuncao=CAD_PO,nTotRegua:=nTotRegua+Int_IP->(Easyreccount("Int_IP")),0)
(cAreaH)->(DBGOTOP())

cProcesso:=''
cControle:=''

If ! lParam                                //MJB-SAP-0800
   Processa({|| In100Gra(cNameH,cAreaH,bGravar,bFor)})
Else
   In100Gra(cNameH,cAreaH,bGravar,bFor,bGravaDBF)    //MJB-SAP-0800
Endif

If cFuncao = CAD_FE .AND. lCallSap  
   If FindFunction("AVR3Nota")
      EasyExRdm("AVR3Nota", aNotas)
   ElseIf FindFunction("U_AVR3Nota")
      EasyExRdm("U_AVR3Nota", aNotas)  
   EndIf    
ENDIF
   
(cAreaH)->(DBGOTOP())

IF cFuncao $ "PO/SI" .AND. ! EMPTY(aTabFabFor)
   DBSELECTAREA(cAlias)
   FOR nTabCont:=1 TO LEN(aTabFabFor)
       IN100Cadastra(CAD_FB,aTabFabFor[nTabCont,1],aTabFabFor[nTabCont,2])
   NEXT
ELSEIF cFUNCAO = "NS" .AND. EEC->(FIELDPOS("EEC_DTINNF")) # 0
       FOR nTABCONT := 1 TO LEN(aEE9PROC)
           lEEC := .T.
           EE9->(DBSETORDER(3))
           EE9->(DBSEEK(cFilEE9+AVKEY(aEE9PROC[nTABCONT],"EE9_PREEMB")))
           DO WHILE ! EE9->(EOF()) .AND.;
              EE9->(EE9_FILIAL+EE9_PREEMB) = (cFilEE9+AVKEY(aEE9PROC[nTABCONT],"EE9_PREEMB"))
              *
              IF EMPTY(EE9->(EE9_SERIE+EE9_NF))
                 lEEC := .F.
                 EXIT
              ENDIF
              EE9->(DBSKIP())
           ENDDO
           EEC->(DBSETORDER(1))
           EEC->(DBSEEK(cFilEEC+AVKEY(aEE9PROC[nTABCONT],"EEC_PREEMB")))
           EEC->(RECLOCK("EEC",.F.))
           EEC->EEC_DTINNF := IF(lEEC,dDATABASE,CTOD("  /  /  "))
           EEC->(MSUNLOCK())
       NEXT
ElseIf cFuncao = "NC" .and. EasyGParam("MV_AVG0069", .F., .F.)
   For nTabCont := 1 To Len(aEECProc)
      AE104NFCompara(aEECProc[nTabCont], "EES", .T.)
   Next
   aEECProc := {}
ENDIF

// atualizacao data de integracao (pode nao ter ocorrido atualizacao)

IF !Reclock("Int_Param",.F.,,.T.)
   IN_MSG(STR0023+NewLine+STR0024) //"O mesmo usuario nao pode executar a "###"integracao de dois micros diferentes."
ELSE
   DBSELECTAREA(cAlias)
   Int_Param->(EVAL(FIELDBLOCK('NPAULT_'+cArq),dDataBase))
   Int_Param->(DBCOMMIT())
   Int_Param->(MSUNLOCK())
ENDIF

(cAreaH)->(DBGOTOP())
IF cAreaD # NIL
   (cAreaD)->(DBGOTOP())
ENDIF

IF cFuncao = CAD_DE   //ACD
   Int_DspHe->( DbGoTop() )
ENDIF

DBSELECTAREA(cAlias)
nResumoFim :=Time()
/*If !TEtempbanco()
   save to ( cArqMemo) all like nResumo*
EndIf*/

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"FIM")
EndIf

IN100Unlock() // JPM - 11/07/05

If lMostraResumo
   IN100RESUMO()
EndIf

If EasyEntryPoint("EICIN100")
   ExecBlock("EICIN100",.F.,.F.,"PE_FIM_EFETIVA")
EndIf   

lLeTXT   := .T.
lLidoTXT := .F.
RETURN .T.
*-----------------------------------------------------------------------------------------*
FUNCTION IN100Copy(cAlias,cNameH,cNameD,bCopyFor,aTipo,cNameI)
*-----------------------------------------------------------------------------------------*
LOCAL nAlias:=SELECT()
PRIVATE nCont:=1

DBSELECTAREA(cAlias)

If !lSched
   ProcRegua(Easyreccount(cAlias)*2)
EndIf

cNameH :=CriaTrab(,.f.)+'.TXT'
COPY TO (cNameH) FOR EVAL(bCopyFor,aTipo[1]) SDF

cNameD :=CriaTrab(,.f.)+'.TXT'
COPY TO (cNameD) FOR EVAL(bCopyFor,aTipo[2]) SDF

IF cNameI # NIL
  cNameI :=CriaTrab(,.f.)+'.TXT'
  COPY TO (cNameI) FOR EVAL(bCopyFor,aTipo[3]) SDF
ENDIF
SELECT(nAlias)

RETURN .T.

*-----------------------------------------------------------------------------------------*
FUNCTION IN100Gra(cFileName,cAreaH,bGravar,bFor,bGravaDBF)  //MJB-SAP-0900
*-----------------------------------------------------------------------------------------*
LOCAL nRec:=1, lLogSAP:=(bGravaDBF <> NIL).AND.lCallSap  //MJB-SAP-0900
LOCAL cFuncNew := IF(cFuncao == "DE","DH",cFuncao)
If !lParam               //MJB-SAP-0800
   ProcRegua(nTotRegua)
   oDlgProc := GetWndDefault() //TRP-02/10/07
Endif                    //MJB-SAP-0800

If(EasyEntryPoint("IN100CLI"),ExecBlock("IN100CLI",.F.,.F.,"ANTES_GRAVA_IN100GRA"),)
bWhile:={|| .T. }
IF lSched
   bWhile:={|| !KillApp() }
ENDIF
DO WHILE ! (cAreaH)->(EOF()) .AND. EVAL(bWhile)
   If !lParam               //MJB-SAP-0800
      IncProc(STR0085+PADL(nRec++,5,'0')) //"Gravando Arq. do Sigaeic, Registro No "
   Endif                    //MJB-SAP-0800

   IF (cAreaH)->(FIELDGET(FIELDPOS('N'+cFuncNEW+'INT_OK'))) = "T"
      EVAL(bGravar)
   ElseIf lLogSAP                                  //MJB-SAP-0900
      Eval(bGravaDBF,((cAreaH)->(RecNo())))        //MJB-SAP-0900
   ENDIF
   (cAreaH)->(DBSKIP())
ENDDO
RETURN .T.

*-----------------------------------------------------------------------------
FUNCTION IN100Append(cFileName,cVezApend)
*-----------------------------------------------------------------------------
LOCAL nHandle:=EasyOpenFile(cDirStart+cFileName,FO_READ)

LOCAL Cont:=0

LOCAL nSize:=AT(NewLine,FREADSTR(nHandle,4096)) - 1

If lLeTXT

   IF ! AvIsDir(Left(cPath,Len(cPath)-1))
      // Path nao existe
      If ! lParam .OR. lChamada
         Help(" ",1,"E_PATH_IN")
      Else
         cMsgR3:="MV_PATH_IN incorreto "+cPath
      Endif
      RETURN (.F.)
   ENDIF
   // *** CAF OS.0878/98 10/08/1998 16:01 *** (FIM)
//   IF !lCompartilhado
      avzap()
//   ENDIF

   If cFuncao == CAD_DE  .and. cVezApend == '1'  // acd
//      IF !lCompartilhado
         Int_DspHe->(avzap())
         Int_DspDe->(avzap())
         Int_DspTx->(avzap())
//      ENDIF
   Endif

   ntotregua:=INT(FSEEK(nHandle,0,FS_END) / ( IF(nSize>0,nSize,RECSIZE()-401) ) )
   FCLOSE(nHandle)
   If !lSched
      Processa({|| In100ap2(cFileName,cVezApend)})
   else
      In100ap2(cFileName,cVezApend)
   endif   
   nHandle:=EasyOpenFile(cDirStart+cFileName,FO_READ)
Else
   If !lSched
      Processa({|| IN100Rep()})
   else
      IN100Rep()
   endif   
EndIf

FCLOSE(nHandle)

DBGOTOP()

If cFuncao = CAD_PO .AND. cVezApend="2" .AND. lMantem
   If !lSched
      Processa({|| In100Mantem()})
   Else
      In100Mantem()
   Endif
   DBGOTOP()
EndIf

If cFuncao = CAD_SI .AND. cVezApend="2" .AND. lMantem
   If !lSched
      Processa({|| In100ManSI()})
   Else
      In100ManSI()   
   Endif   
   DBGOTOP()
EndIf

lSair:=.F.
If EasyEntryPoint("IN100CLI")     
   cFile_TXT:=cFileName
   ExecBlock("IN100CLI",.F.,.F.,"DEL_TXT")//AWR 21/08/2001
EndIf

IF lSair
   RETURN .T.
ENDIF

IF ! lPrevia
   cFileOld:=STRTRAN(Upper(cFileName),'TXT','OLD')
   IF FILE(cPath+cFileOld)
      FERASE(cPath+cFileOld)
   ENDIF
   FRENAME(cPath+cFileName,cPath+cFileOld)
   If !(cPath == cDirStart)
      IF FILE(cDirStart+cFileOld)
         FERASE(cDirStart+cFileOld)
      ENDIF
      FRENAME(cDirStart+cFileName,cDirStart+cFileOld)
   EndIf
ENDIF

RETURN .T.

*------------------
FUNCTION IN100Rep()
*------------------
LOCAL nCont:=1

SELECT('Int_'+cFuncao)
If !lSched
   ProcRegua(('Int_'+cFuncao)->(EasyRecCount('Int_'+cFuncao)))
EndIf
('Int_'+cFuncao)->(DBGOTOP())
Replace &('N'+cFuncao+'Msg') With '' For (IF(!lParam,IncProc(STR0086+str(nCont++)),),.T.) //"Atualizando Mensagens, Registro.: "
Return .T.

*-----------------------------------------------------------------------------
FUNCTION IN100Ap2(cFileName,cVezApend)
*-----------------------------------------------------------------------------
LOCAL nCont:=1

If !lsched
   ProcRegua(nTotRegua)
   APPEND FROM (cDirStart+cFileName) SDF WHILE IF(!lParam,(IncProc(),.T.),.T.) //"Atualizando Arq. Temporário "###", Registro.: "
Else 
   APPEND FROM (cDirStart+cFileName) SDF // "Atualizando Arq. Temporário "###", Registro.: "
Endif
RETURN (NIL)

*---------------------*
Function In100Mantem()
*---------------------*
LOCAL nNPO_Rec,nIP_Rec,nIS_Rec,nNIP_Ordem,nIP_Ordem,nW1Ordem
nNPO_Rec   := Int_PO->(RECNO())
nIP_Rec    := SW3->(RECNO())
nIS_Rec    := SW1->(RECNO())
nNIP_Ordem := Int_IP->(INDEXORD())
Int_IP->(DBSETORDER(0)) // Pois o campo NIPCOD_I faz parte da chave
nW1Ordem   := SW1->(INDEXORD())
nIP_Ordem  := SW3->(INDEXORD())
SW1->(DBSETORDER(2))
SW3->(DBSETORDER(8))

If !lsched
   ProcRegua(nTotRegua+1)
Endif
Int_IP->(DBGOTOP())

IF !lParam
   IncProc(STR0089) //"Checando detalhes de pedidos..."
EndIf

DO WHILE ! Int_IP->(EOF())

   IF !lParam
      IncProc()
   EndIf
   
   IF ! Int_IP->( EMPTY(NIPPO_NUM) .OR. VAL(NIPPOSICAO) = 0 ) .AND. UPPER(Int_IP->NIPTIPO)=ALTERACAO
      IF Int_PO->(DBSEEK(Int_IP->NIPPO_NUM+Int_IP->NIPSEQ_PO))
         IF UPPER(Int_PO->NPOTIPO) = ALTERACAO
            If SW3->(DBSEEK(cFilSW3+AVKEY(Int_IP->NIPPO_NUM,"W3_PO_NUM")+Int_IP->NIPPOSICAO))                            //MJB-SAP-0401
               // IF( EMPTY(Int_IP->NIPPO_NUM ) .AND. ! EMPTY(It_Pedidos->IPPO_NUM ) , Int_IP->NIPPO_NUM  := It_Pedidos->IPPO_NUM, NIL )
               IF(EMPTY(ALLTRIM(LEFT(Int_IP->NIPCOD_I,nLenItem))).AND. ! EMPTY(SW3->W3_COD_I  ), Int_IP->NIPCOD_I  := SW3->W3_COD_I,NIL)
               IF(EMPTY(ALLTRIM(Int_IP->NIPCC)     ) .AND. ! EMPTY(SW3->W3_CC     ), Int_IP->NIPCC     := SW3->W3_CC,NIL)
               IF(EMPTY(ALLTRIM(Int_IP->NIPSI_NUM) ) .AND. ! EMPTY(SW3->W3_SI_NUM ), Int_IP->NIPSI_NUM := SW3->W3_SI_NUM,NIL)
               IF(EMPTY(ALLTRIM(Int_IP->NIPFABR)   ) .AND. ! EMPTY(SW3->W3_FABR   ), Int_IP->NIPFABR   := SW3->W3_FABR,NIL )
               IF(EMPTY(ALLTRIM(Int_IP->NIPQTDE)   ) .AND. ! EMPTY(SW3->W3_QTDE   ), Int_IP->NIPQTDE   := STR(SW3->W3_QTDE,AVSX3("W3_QTDE",3),AVSX3("W3_QTDE",4)),NIL) //MJB-SAP-0401
               IF(EMPTY(ALLTRIM(Int_IP->NIPDT_EMB) ) .AND. ! EMPTY(SW3->W3_DT_EMB ), Int_IP->NIPDT_EMB := STRTRAN(DTOC(SW3->W3_DT_EMB ),"/"),NIL)
               IF(EMPTY(ALLTRIM(Int_IP->NIPDT_ENTR)) .AND. ! EMPTY(SW3->W3_DT_ENTR), Int_IP->NIPDT_ENTR:= STRTRAN(DTOC(SW3->W3_DT_ENTR),"/"),NIL)
               IF(EMPTY(ALLTRIM(Int_IP->NIPPRECO)  ) .AND. ! EMPTY(SW3->W3_PRECO  ), Int_IP->NIPPRECO  := STR(SW3->W3_PRECO,15,5),NIL)

               If SW1->(DBSEEK(cFilSW1+Int_IP->NIPPO_NUM+Int_IP->NIPPOSICAO+Int_IP->NIPCC+Int_IP->NIPSI_NUM)) //MJB-SAP-0401
                  IF(EMPTY(ALLTRIM(Int_IP->NIPCLASS)) .AND. ! EMPTY(SW1->W1_CLASS),Int_IP->NIPCLASS    := SW1->W1_CLASS,NIL)
               EndIf

               IF(EMPTY(ALLTRIM(Int_IP->NIPFABR_01)) .AND. ! EMPTY(SW3->W3_FABR_01), Int_IP->NIPFABR_01 := SW3->W3_FABR_01,NIL)
               IF(EMPTY(ALLTRIM(Int_IP->NIPFABR_02)) .AND. ! EMPTY(SW3->W3_FABR_02), Int_IP->NIPFABR_02 := SW3->W3_FABR_02,NIL)
               IF(EMPTY(ALLTRIM(Int_IP->NIPFABR_03)) .AND. ! EMPTY(SW3->W3_FABR_03), Int_IP->NIPFABR_03 := SW3->W3_FABR_03,NIL)
               IF(EMPTY(ALLTRIM(Int_IP->NIPFABR_04)) .AND. ! EMPTY(SW3->W3_FABR_04), Int_IP->NIPFABR_04 := SW3->W3_FABR_04,NIL)
               IF(EMPTY(ALLTRIM(Int_IP->NIPFABR_05)) .AND. ! EMPTY(SW3->W3_FABR_05), Int_IP->NIPFABR_05 := SW3->W3_FABR_05,NIL)
               IF(EMPTY(ALLTRIM(Int_IP->NIPFLUXO)) .AND. ! EMPTY(SW3->W3_FLUXO), Int_IP->NIPFLUXO := SW3->W3_FLUXO,NIL)
            ENDIF

         ENDIF
      ENDIF
   ENDIF

   Int_IP->(DBSKIP())
ENDDO

SW3->(DBSETORDER(nIP_Ordem))
SW1->(DBSETORDER(nW1Ordem))
Int_IP->(DBSETORDER(nNIP_Ordem))
Int_PO->(DBGOTO(nNPO_Rec))
SW3->(DBGOTO(nIP_Rec))
SW1->(DBGOTO(nIS_Rec))

Int_IP->(DBGOTOP())

Return .T.

*--------------------*
Function In100ManSI()
*--------------------*
LOCAL nIS_Rec,lAchou_IS:=.F.,nW1Ordem, nNSI_Rec
nNSI_Rec   := Int_SI->(RECNO())
nIS_Rec    := SW1->(RECNO())
nW1Ordem   := SW1->(INDEXORD())
SW1->(DBSETORDER(1))

If !lsched
   ProcRegua(nTotRegua+1)
EndIf
Int_IS->(DBGOTOP())

IF !lParam
   IncProc(STR0090) //"Checando detalhes da solicitação..."
EndIf   

DO WHILE ! Int_IS->(EOF())

   IF !lParam
      IncProc()
   EndIf

   IF ! Int_IS->( EMPTY(NISCC) .OR. EMPTY(NISSI_NUM) .OR. VAL(NISPOSICAO) = 0 ) .AND. UPPER(Int_IS->NISTIPO)=ALTERACAO
      IF Int_SI->(DBSEEK(Int_IS->(NISCC+NISSI_NUM+NISSEQ_SI)))
         IF UPPER(Int_SI->NSITIPO) = ALTERACAO
            SW1->(DBSEEK(cFilSW1+Int_IS->(NISCC+NISSI_NUM)))                                          //MJB-SAP-0401
            lAchou_IS := .F.
            DO WHILE ! SW1->(EOF()) .AND. cFilSW1 == SW1->W1_FILIAL ;                                 //MJB-SAP-0401
                .AND. (SW1->W1_SI_NUM == Int_IS->NISSI_NUM) ;
                .AND. (SW1->W1_CC == Int_IS->NISCC) .AND. (! lAchou_IS)

                  IF SW1->W1_POSICAO=STRZERO(VAL(Int_IS->NISPOSICAO),nTamPosicao).AND.(SW1->W1_SEQ==0)
                     lAchou_IS := .T.
                  ELSE
                     SW1->(DBSKIP())
                  ENDIF
            ENDDO

            IF lAchou_IS
               IF(EMPTY(ALLTRIM(LEFT(Int_IS->NISCOD_I,nLenItem))).AND.!EMPTY(SW1->W1_COD_I), Int_IS->NISCOD_I    := SW1->W1_COD_I         ,NIL)
               IF(EMPTY(ALLTRIM(Int_IS->NISQTDE)   )             .AND.!EMPTY(SW1->W1_QTDE   ), Int_IS->NISQTDE   := STR(SW1->W1_QTDE,13,3),NIL)
               IF(EMPTY(ALLTRIM(Int_IS->NISFABR)   )             .AND.!EMPTY(SW1->W1_FABR   ), Int_IS->NISFABR   := SW1->W1_FABR          ,NIL)
               IF(EMPTY(ALLTRIM(Int_IS->NISCLASS)  )             .AND.!EMPTY(SW1->W1_CLASS),Int_IS->NISCLASS     := SW1->W1_CLASS         ,NIL)
               IF(EMPTY(ALLTRIM(Int_IS->NISDTENTR_))             .AND.!EMPTY(SW1->W1_DTENTR_), Int_IS->NISDTENTR_:= STRTRAN(DTOC(SW1->W1_DTENTR_),"/"),NIL)
               IF(EMPTY(ALLTRIM(Int_IS->NISFORN)   )             .AND.!EMPTY(SW1->W1_FORN   ), Int_IS->NISFORN   := SW1->W1_FORN          ,NIL)
            ENDIF

         ENDIF
      ENDIF
   ENDIF

   Int_IS->(DBSKIP())
ENDDO

SW1->(DBSETORDER(nW1Ordem))
Int_SI->(DBGOTO(nNSI_Rec))
SW1->(DBGOTO(nIS_Rec))

Int_IS->(DBGOTOP())

Return .T.

*-----------------------------------------------------------------------------
FUNCTION IN100Status(lRel)
*-----------------------------------------------------------------------------
IF lRel = NIL
   RETURN IF(Easyreccount(Alias())<1,SPACE(09),IF(EVAL(bStatus),STR0091,STR0092)) //'ACEITO   '###'REJEITADO'
ELSE
   RETURN IF(Easyreccount(Alias())<1,SPACE(09),IF(EVAL(bStatus),STR0093,STR0094)) //'OK  '###'ERRO'
ENDIF

*-----------------------------------------------------------------------------
FUNCTION IN100StaIte(lRel)
*-----------------------------------------------------------------------------
RETURN IF(Easyreccount(Alias())<1,SPACE(03),IF(EVAL(bStaIte),STR0095,STR0096)) //'NAO'###'SIM'


*---------------------------------------------------------------------------------------------------*
FUNCTION IN100Tipo(lRel)
*---------------------------------------------------------------------------------------------------*
LOCAL tipo:=IF(cFuncao=CAD_DI,"A",UPPER(EVAL(bTipo)))

IF lRel = NIL
   RETURN IF(tipo='I',STR0097,IF(tipo='A',STR0098,IF(tipo='E',STR0099,PADR(tipo,9)))) //'INCLUSAO '###'ALTERACAO'###'EXCLUSAO '
ELSE
   RETURN IF(tipo='I','(I)',IF(tipo='A','(A)',IF(tipo='E','(E)','('+tipo+')')))
ENDIF

*-----------------------------------------------------------------------------
FUNCTION IN100VerErro(cErro,cAviso)
*-----------------------------------------------------------------------------
local cUpDate:=""
IF cErro # NIL .AND. cAviso # NIL
   EVAL(bMessage,STR0100+NewLine+NewLine+cErro+NewLine+NewLine+STR0101+NewLine+NewLine+cAviso) //'*** ERRO(S):'###'*** AVISO(S):'
   EVAL(bStatus,"F")
ELSEIF cErro # NIL
   EVAL(bMessage,STR0100+NewLine+NewLine+cErro) //'*** ERRO(S):'
   EVAL(bStatus,"F")
ELSE
   EVAL(bStatus,"T")
   IF cAviso # NIL
      EVAL(bMessage,STR0101+NewLine+NewLine+cAviso) //'*** AVISO(S):'
   ENDIF
ENDIF

if type("bUpDate")=="B"
   cUpDate:="Eval(bUpDate, Int_"+AllTrim(cFuncao)+"->N"+AllTrim(cFuncao)+"Msg,Int_"+AllTrim(cFuncao)+"->N"+AllTrim(cFuncao)+"INT_OK)"
   &cUpDate
endif

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"VER_ERRO")//AWR 17/08/2001
EndIf

RETURN

*-----------------------------------------------------------------------------
FUNCTION IN100CTD(data,Validar,cFormato,nLenDt)
*-----------------------------------------------------------------------------
LOCAL dRetorno
IF cFormato = NIL
   dRetorno:=AVCTOD ( LEFT(data,2) + "/" + SUBS(data,3,2) + "/" + RIGHT(data,nAno) )
ELSE
   If nLenDt <> Nil .And. nLenDt = 6
      cFormato:=If(cFormato = "AAAAMMDD","AAMMDD","DDMMAA")
   Endif
      
   If cFormato = "AAAAMMDD"
      dRetorno:=AVCTOD ( RIGHT(data,2) + "/" + SUBS(data,5,2) + "/" + LEFT(data,4) )
   ElseIf cFormato = "DDMMAAAA" 
      dRetorno:=AVCTOD ( LEFT(data,2) + "/" + SUBS(data,3,2) + "/" + RIGHT(data,4) )
   ElseIf cFormato = "DDMMAA"
   dRetorno:=AVCTOD ( LEFT(data,2) + "/" + SUBS(data,3,2) + "/" + RIGHT(data,2) )
   Endif
ENDIF
RETURN IF(Validar # NIL,! EMPTY(dRetorno),dRetorno)

*---------------------------------------------------------------------------------------
FUNCTION IN100DTC(dDate,nDigitos)                                         //MJB-SAP-1100
*---------------------------------------------------------------------------------------
Local nDigAno:=If(nDigitos = NIL,nAno,nDigitos), cRet                     //MJB-SAP-1100

If !Empty(dDate)
   cRet:=PADL(DAY(dDate),2,'0')+PADL(MONTH(dDate),2,'0')+RIGHT(STR(YEAR(dDate),4,0),nDigAno) //MJB-SAP-1100
Else
   cRet:=Space(4+nDigAno)
Endif   
RETURN cRet
*-------------------------*
FUNCTION IN100Geral(DtUlt)
*-------------------------*
LOCAL Modelo
Private cNewKey:=&(INDEXKEY(0)) // SVG - 02/07/09 - Para a utilização em RDMAKE -
PRIVATE tipo:=IF(cFuncao=CAD_DI,"A",UPPER(EVAL(bTipo)))
PRIVATE dDtInt:=IN100CTD(EVAL(bDtInteg)) 
tipo:=IF(cFuncao=CAD_FE,"I",tipo)

dDTInt :=IF(EMPTY(dDtInt).AND.cFuncao$CAD_DI+"/"+CAD_FE+"/"+CAD_NU,dDataBase,dDtInt)

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"GERAL")
EndIf

IF !(cFuncao$CAD_DI+"/"+CAD_NU+"/"+CAD_NC+"/"+CAD_ND)
   IF AT(tipo,'IAE') = 0
      EVAL(bmsg,STR0548+STR0549)  // TIPO_INT INVALIDO
   ELSE
      EVAL(bTipo,tipo)            // regrava p/ garantir que estara em letra maiscula
   ENDIF
ENDIF

IF !lSched  // Sidney no Cliente Itautec 16/01/01
    IF EMPTY(dDtInt)
       EVAL(bmsg,STR0102+STR0549) //"DATA DA INTEGRACAO INVALIDO
    ELSEIF !EMPTY(DtUlt) .AND. CTOD(DTOC(dDtInt)) < CTOD(DTOC(DtUlt))//AOM - 08/02/2012
       EVAL(bmsg,STR0103)         //"DATA INTEGRACAO ANTERIOR `A "
       EVAL(bmsg,STR0104)         //"ULTIMA PROCESSADA"
   ENDIF
ENDIF

If cFuncao == CAD_CE
   If(Int_CE->NCETIPOIE="I", cNewKey := &(INDEXKEY(3)), cNewKey := &(INDEXKEY(4)) )
EndIf
IF cFuncao # CAD_DI .AND. cFUNCAO # CAD_NS .AND. cFuncao # CAD_TP
   IF(cSaveKey == cNewKey,EVAL(bmsg,STR0105),cSaveKey:=cNewKey) //'REGISTRO JA INFORMADO'
EndIf

IF AT(cFuncao,CAD_SI+'/'+CAD_PO) = 0
   RETURN
ELSEIF cFuncao = CAD_SI
   Modelo:=Int_SI->NSIMODELO
ELSE
   Modelo:=Int_PO->NPOMODELO
ENDIF

IF (lModelo:=!EMPTY(Modelo)) .AND. ! SWU->(DBSEEK(cFilSWU+Modelo))
   EVAL(bMsg,STR0106+STR0544) // MODELO SEMCADASTRO
   lModelo:=.F.
ENDIF

RETURN

*-----------------------------------------------------------------------------
FUNCTION IN100NaoNum(Valor)
*-----------------------------------------------------------------------------
RETURN (AllTrim(Valor) != "00000000" .And. VAL(Valor) <= 0) //THTS - 14/02/2018 - NCM generica 00000000 deve ser aceita como valida

*-----------------------------------------------------------------------------
FUNCTION IN100E_Msg(Browse)
*-----------------------------------------------------------------------------
LOCAL cmsg:=EVAL(bMessage)

IF Browse = NIL
   IF EMPTY(Alltrim(StrTran(cmsg,CHR(13)+CHR(10),"")))
      IN_MSG(STR0107,STR0039) // Nao ha mensagens para este registro. Informação 
      RETURN NIL
   ENDIF
ELSE
    IF MLCOUNT(ALLTRIM(cMsg),LEN_MSG) > 1
       RETURN LEFT(MEMOLINE(cmsg,LEN_MSG),LEN_MSG-7)+STR0108 //'...(CLICK EM MENSAGEM)'
    ELSE
       RETURN MEMOLINE(cMsg,LEN_MSG)
    ENDIF
ENDIF

DEFINE MSDIALOG oDlg3 TITLE STR0109 From 9,15 To 28,65 OF oMainWnd //"Mensagens"

@ 13,17 GET cMsg MEMO HSCROLL READONLY  SIZE 165,110 OF oDlg3 PIXEL
@ 130,077 BUTTON STR0110 SIZE 34,11 FONT oDlg3:oFont ACTION (oDlg3:End()) OF oDlg3 PIXEL //"&Retorna"

ACTIVATE MSDIALOG oDlg3 CENTERED

RETURN NIL

*-----------------------------------------------------------------------------
FUNCTION IN100Rel(cTit)
*-----------------------------------------------------------------------------
Local nInd
Local lRetBlock //RRV - 30/08/2012 - Trata o retorno do ponto de entrada.
PRIVATE R_Campos:={}, nLenmsg:=LEN_MSG,;
        R_Funcoes:={ {|| IN100RelE_Msg() },{|| .T. } }, lPrimeiro:=.T., lCabDet:=.F.
        
If EasyEntryPoint("IN100CLI") 
	If ValType(lRetBlock := ExecBlock("IN100CLI",.F.,.F.,"IMPRESAO")) == "L" .And. !lRetBlock //RRV - 30/08/2012 - Trata o retorno do ponto de entrada.
	   Return Nil
	EndIf
EndIf

IF cFuncao $ (CAD_SI+'/'+CAD_PO+'/'+CAD_IT+'/'+CAD_PE+'/'+CAD_NU+'/'+CAD_DE+'/'+CAD_NC) .OR. lCabDet
   IN100Inicio_Print(cTit)
   RETURN                       
ELSEIF cFuncao = CAD_RE
   IN100ImpResumo(cTit)
   RETURN
ENDIF

R_Funcoes:={ {|| IN100RelE_Msg() },{|| .T. } }
TBRCols[1,1]:="IN100Status(.T.)"
TBRCols[2,1]:="IN100Tipo(.T.)"

FOR nInd=1  TO  LEN(TBRCols)
    IF UPPER(TBRCols[nInd,2]) # UPPER(STR0112) //'MENSAGEM'
       AADD(R_Campos,{TBRCols[nInd,1],TBRCols[nInd,2],"C"})
    ENDIF
NEXT

AADD(R_Campos,{ {|| MEMOLINE(ALLTRIM(EVAL(bMessage)),LEN_MSG,1)} ,STR0112+SPACE(32),"E"}) //"Mensagem"

aDados[1] :='Int_'+cFuncao
aDados[9] :=cTit
aDados[10]:={ STR0016, 1,STR0017, 2, 2, 1, cValid, nOrem } //"Zebrado"###"Importa‡Æo"
aDados[12]:={ {||IN100RelE_Msg() },{||IN100RelE_Msg() } }

E_Report(aDados,R_Campos)
RETURN .T.

*-----------------------*
FUNCTION IN100RelE_MSG()
*-----------------------*
LOCAL nInd, nLinmsg, nColmsg, cMessage, nTotLin, nLin1

IF lPrimeiro
   lPrimeiro:=.F.
   RETURN .T.
ENDIF

IF cFuncao = CAD_IT .OR. cFuncao = CAD_PE .OR. cFuncao = CAD_NC
   nLin1  :=2
   nColMsg:=20
   nLinMsg:=Li
ELSE                    
   DBSKIP(-1)
   nLin1  :=2 
   nColMsg:=T_Len[LEN(R_Campos),2]
   nLinMsg:=Linha//-1
ENDIF

cMessage:=ALLTRIM(EVAL(bMessage))
nTotLin :=MLCOUNT(cMessage,LEN_MSG)

//If nTotLin=0
//   nLinMsg+=1
//EndIf

FOR nInd:=nLin1 TO nTotLin
    If ! EMPTY(ALLTRIM(MEMOLINE(cMessage,LEN_MSG,nInd)))
       IF cFuncao = CAD_IT .OR. cFuncao = CAD_PE .OR. cFuncao = CAD_NC
          @ nLinMsg++,nColMsg PSAY ALLTRIM(MEMOLINE(cMessage,LEN_MSG,nInd))
       ELSE
          nLinmsg++
          @ nLinmsg,nColmsg PSAY ALLTRIM(MEMOLINE(cMessage,LEN_MSG,nInd))
       ENDIF
    Endif
NEXT

Linha:=nLinMsg
IF cFuncao # CAD_IT .AND. cFuncao # CAD_PE .AND. cFuncao # CAD_NC
   DBSKIP(1)
ENDIF

RETURN .T.

*-----------------------------------------------------------------------------
FUNCTION IN100Txt()
*-----------------------------------------------------------------------------
LOCAL cDDMMAA :=PADL(DAY(dDataBase),2,'0')+PADL(MONTH(dDataBase),2,'0')+;
                RIGHT(STR(YEAR(dDataBase),4,0),2)

LOCAL cFileTxt:=/*cDirNPA+If(RIGHT(cDirNPA,1)="\","","\")+*/"IN"+cDDMMAA+".TXT" + Space(50)
LOCAL nRec:=RECNO(), Cont:=0, nVolta:=0, nHandle:=0

WHILE .T.

   DEFINE MSDIALOG oDlg4 FROM  9,10 TO 15,65 TITLE STR0113 //"Gera‡„o de Arquvio Texto"
   @ 17,16 SAY STR0114                  SIZE 30,10 OF oDlg4 PIXEL //"Arquivo..:"
   @ 17,42 MSGET cFileTxt                    SIZE 110,10 OF oDlg4 PIXEL ;
                 Valid (! EMPTY(cFileTxt))
   DEFINE SBUTTON FROM 07,180 TYPE 1 ACTION (nVolta:=1,oDlg4:End()) ENABLE OF oDlg4 PIXEL
   DEFINE SBUTTON FROM 28,180 TYPE 2 ACTION (oDlg4:End()) ENABLE OF oDlg4  PIXEL
   ACTIVATE MSDIALOG oDlg4 CENTERED

   IF nVolta # 1 .or. EMPTY(cFileTxt)
      RETURN .T.
   ENDIF
   cFileTxt := AllTrim(cFileTxt)
   IF FILE(cFileTxt)
      IF MSGYESNO(STR0115,STR0077) # .T. //"ARQUIVO JA' EXISTE ! - DESEJA SOBREPOR ? "###"Arquivo "
         LOOP
      ENDIF
   ENDIF

   IF (nHandle:=EasyCreateFile(cFileTxt)) == -1
      IN_MSG(STR0116+STR(FERROR(),4,0),STR0039) //"NÇO FOI POSSÖVEL CRIAR ARQUIVO, ERRO = "###"Informação"
      LOOP
   ENDIF
   FCLOSE(nHandle)
   EXIT
ENDDO

DBGOTOP()

//IN_MSG(STR0117+cFileTxt+STR0118,0) //"COPIANDO PARA O ARQUIVO "###" - AGUARDE..."

Processa({|| In100Copia(cFileTxt)} )

DBGOTO(nRec)
RETURN .T.

*---------------------------------------------------------------------------
FUNCTION IN100Copia(cFileTxt)
*---------------------------------------------------------------------------
LOCAL nRec:=0
ProcRegua(Easyreccount(Alias()))
COPY TO (cFileTxt) SDF FOR (IF(!lParam,IncProc(STR0119+str(nRec++)),),&(cValid)) //"Gerando Arq. Texto Registro.: "

RETURN .T.

*---------------------------------------------------------------------------
FUNCTION IN100Item()
*---------------------------------------------------------------------------
LOCAL nInd, nLen

AADD(TB_Cols,{{||TRANSFORM(Int_CI->NCICOD_I,_PictItem)}        ,"", STR0120}) //"Item"
AADD(TB_Cols,{{||LEFT(Int_CI->NCIUNI,2)}                  ,"", STR0121}) //"Unidade"
AADD(TB_Cols,{{||LEFT(Int_CI->NCIDESC_P,36)}              ,"", STR0122}) //"Descrição em Portugues (1a. linha)"
AADD(TB_Cols,{{||LEFT(Int_CI->NCIDESC_I,36)}              ,"", STR0123}) //"Descrição em Ingles (1a. linha)"
AADD(TB_Cols,{{||LEFT(Int_CI->NCIDESC_GI,48)}             ,"", STR0124}) //"Descrição p/ GI (1a. linha)"
AADD(TB_Cols,{{||TRANSFORM(Int_CI->NCITEC,'@R 9999.99.99')}    ,"", STR0125}) //"N.C.M."
AADD(TB_Cols,{{||Int_CI->NCIQUALTEC}                      ,"", STR0126}) //"EX. N.C.M."
AADD(TB_Cols,{{||TRANSFORM(VAL(RIGHT(Trim(Int_CI->NCIPESO_L),11)),cPictPesoL)} ,"", STR0127}) //"Peso Liquido" //MJB-SAP-0201
AADD(TB_Cols,{{||TRANSFORM(VAL(Int_CI->NCIVLREF_US),_PictPrUn)},"", STR0128}) //"Valor Refer. US$"
AADD(TB_Cols,{{||Int_CI->NCIFPCOD+IF(SYC->(DBSEEK(cFilSYC+Int_CI->NCIFPCOD)),'-'+SYC->YC_NOME,SPACE(25))},"","Familia" })
AADD(TB_Cols,{{||IF(Int_CI->NCIANUENTE$cNao,STR0095,STR0096)}  ,"",STR0129 }) //'Nao'###'Sim'###"Anuencia"

If lEIC_EEC .Or. cModulo == "EDC"                                                 //MJB-SAP-0101
   AADD(TB_Cols,{{||Int_CI->NCIEMBAL}                     ,"", "Embalagem"})      //MJB-SAP-0101
   AADD(TB_Cols,{{||Int_CI->NCIQTDEMB}                    ,"", "Qtde Emb."})      //MJB-SAP-0101
   //AOM - 08/02/2012
   If SB1->( FieldPos("B1_IMPORT") ) > 0
      AADD(TB_Cols,{{||Int_CI->NCIIMPORT},"",STR0783}) //"Produto Importado?"
   Endif
   If lEIC_EEC
      IN100ItID()                                                            //MJB-SAP-0101
   EndIf
Endif                                                                     //MJB-SAP-0101

ASIZE(TBRCols,0)
AADD(TBRCols,{ {|| IN100Status()}                 , STR0036 }) //"Status"
AADD(TBRCols,{ {|| IN100TIPO() }                  , STR0037   }) //"Tipo"
AADD(TBRCols,{ {|| IN100CTD(EVAL(bDtInteg))}      , STR0071 }) //"Dt Integ"
AADD(TBRCols,{{||TRANSFORM(Int_CI->NCICOD_I,_PictItem)}        ,STR0120}) //"Item"
AADD(TBRCols,{{||LEFT(Int_CI->NCIUNI,2)}                  ,STR0130}) //"UN"
AADD(TBRCols,{{||LEFT(Int_CI->NCIDESC_P,30)}              ,STR0131}) //"Descr. em Portugues (1a.linha)"
//AADD(TBRCols,{{||LEFT(NCIDESC_I,36)}           ,STR0123}) //"Descrição em Ingles (1a. linha)"
AADD(TBRCols,{{||LEFT(Int_CI->NCIDESC_GI,30)}             ,STR0132}) //"Descr. p/ GI (1a.linha)"
AADD(TBRCols,{{||TRANSFORM(Int_CI->NCITEC,'@R 9999.99.99')}    ,STR0125}) //"N.C.M."
AADD(TBRCols,{{||Int_CI->NCIQUALTEC}                      ,STR0133}) //"EX.NCM"
AADD(TBRCols,{{||TRANSFORM(VAL(RIGHT(Trim(Int_CI->NCIPESO_L),11)),cPictPesoL)} ,STR0127}) //"Peso Liquido"  //MJB-SAP-0201
AADD(TBRCols,{{||TRANSFORM(VAL(Int_CI->NCIVLREF_US),_PictPrUn)},STR0128}) //"Valor Refer. US$"
AADD(TBRCols,{{||Int_CI->NCIFPCOD}                        ,STR0134 }) //"Familia"
AADD(TBRCols,{{||IF(Int_CI->NCIANUENTE$cNao,STR0095,STR0096)}  ,STR0129 }) //'Nao'###'Sim'###"Anuencia"

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"COLCI")
ENDIF
AADD(TBRCols,{{||IN100E_MSG(.T.)}                 ,STR0112}) //"Mensagem"
AADD(TB_Cols,{{||IN100E_Msg(.T.)}                 ,"",STR0112}) //"Mensagem"

RETURN .T.

*--------------------*
FUNCTION IN100LerCI()
*--------------------*
Local cAlias

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"LERCI")
ENDIF

IF EMPTY(LEFT(Int_CI->NCICOD_I,nLenItem))
   EVAL(bmsg,STR0556+STR0546) // CODIGO_ITEM NAOINFORMADO
ENDIF

IF ! EMPTY(ALLTRIM(Int_CI->NCITEC)) .AND. IN100NaoNum(Int_CI->NCITEC)
   EVAL(bmsg,"NCM"+STR0549)  // INVALIDO
ENDIF

IF ! SB1->(DBSEEK(cFilSB1+LEFT(Int_CI->NCICOD_I,nLenItem)))
   IF Int_CI->NCITIPO = EXCLUSAO   //# INCLUSAO
      EVAL(bmsg,STR0556+STR0544) // CODIGO_ITEM SEM CADASTRO
   ENDIF

   IF Int_CI->NCITIPO = ALTERACAO
      cAlias := Alias()
      Reclock( "Int_CI", .F. )
      DbSelectArea( cAlias )

      Int_CI->NCITIPO := INCLUSAO

      Int_CI->( MsUnlock() )
   ENDIF

ELSEIF Int_CI->NCITIPO = INCLUSAO
       EVAL(bmsg,STR0556+STR0545)  // CODIGO_ITEM COMCADASTRO

ELSEIF Int_CI->NCITIPO == EXCLUSAO

       SW1->(DBSETORDER(3))
       IF SW1->(DBSEEK(cFilSW1+LEFT(Int_CI->NCICOD_I,nLenItem)))                                      //MJB-SAP-0401
          EVAL(bmsg,STR0135+SW1->W1_CC+'/'+; //'ITEM PERTENCE A SI '
                     TRANSFORM(SW1->W1_SI_NUM,_PictSI))

       ELSEIF SA5->(DBSEEK(cFilSA5+LEFT(Int_CI->NCICOD_I,nLenItem)))
          EVAL(bmsg,STR0136,.T.) //"LIGACAO FABR/FORN SERA EXCLUIDA"
       ENDIF
       SW1->(DBSETORDER(1))
ENDIF

IF Int_CI->NCITIPO == EXCLUSAO
   IF EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"VALCI")
   ENDIF
   IN100VerErro(cErro,cAviso)
   IF Int_CI->NCIINT_OK = "T"
      nResumoCer+=1
   ELSE
      nResumoErr+=1
   ENDIF
   RETURN
ENDIF

IF EMPTY(ALLTRIM(LEFT(Int_CI->NCIUNI,nTamUM))) .AND. SB1->(EOF())
   EVAL(bmsg,STR0137+STR0546) //"UNIDADE MEDIDA NAO INFORMADO
ENDIF

IF ! EMPTY(ALLTRIM(LEFT(Int_CI->NCIUNI,nTamUM))) .AND. ! SAH->(DBSEEK(cFilSAH+ALLTRIM(LEFT(Int_CI->NCIUNI,nTamUM))))
   EVAL(bmsg,STR0137+STR0544) //"UNIDADE MEDIDA SEM CADASTRO
ENDIF

aVal_CI:={.T.,.T.}
IF(EasyEntryPoint("IN100CLI"),ExecBlock("IN100CLI",.F.,.F.,"VAL_CI"),)

IF EasyEntryPoint("IC050IN1")
   ExecBlock("IC050IN1",.F.,.F.,STR0546) // NAOINFORMADO   // Rdmake para Jundlab
ELSE
   IF aVal_CI[1] .AND. MLCOUNT(ALLTRIM(Int_CI->NCIDESC_P),36) = 0 .AND. SB1->(EOF())
      EVAL(bmsg,STR0138+STR0546) //"DESCRICAO EM PORTUGUES NAOINFORMADO
   ENDIF

   IF aVal_CI[2] .AND. MLCOUNT(ALLTRIM(Int_CI->NCIDESC_GI),48) = 0 .AND. SB1->(EOF())
      EVAL(bmsg,STR0139+STR0546) //"DESCRICAO P/ LI/DI NAOINFORMADO
   ENDIF
ENDIF
//THTS - 14/02/2018 - A NCM generica 00000000 deve ser aceita como valida
IF ! EMPTY(Int_CI->NCITEC) .And. AllTrim(Int_CI->NCITEC) != "00000000" .AND. ! SYD->(DBSEEK(cFilSYD+AvKey(Int_CI->NCITEC,"YD_TEC")+Int_CI->NCIQUALTEC)) .AND. ;
   ! Int_Param->NPAINC_NBM
   EVAL(bmsg,STR0140+STR0544) //"NCM SEMCADASTRO
ENDIF

IF ! EMPTY(Int_CI->NCIFPCOD) .AND. ! SYC->(DBSEEK(cFilSYC+Int_CI->NCIFPCOD)) .AND. ;
   ! Int_Param->NPAINC_FAM
   EVAL(bmsg,STR0134+STR0544) //"FAMILIA SEMCADASTRO
ENDIF

If lEIC_EEC                                                               //MJB-SAP-1100
   If ! ChkFile("EE5")                                                    //MJB-SAP-1100
      EVAL(bmsg,"Impossivel abrir EE5")                                   //MJB-SAP-1100
      Return                                                              //MJB-SAP-1100
   Else                                                                   //MJB-SAP-1100
      IN100PE_EMB(Int_CI->NCIEMBAL,Int_CI->NCIQTDEMB,Int_CI->NCITIPO)     //MJB-SAP-1100
   Endif                                                                  //MJB-SAP-1100
Endif                                                                     //MJB-SAP-1100

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"VALCI")
ENDIF

IN100VerErro(cErro,cAviso)

If lEIC_EEC                                                               //MJB-SAP-1100
   Int_CI->NCIITEM_OK:="T"                                                //MJB-SAP-1100
   If ! IN100PE_ID(Int_CI->NCICOD_I,.F.)                                  //MJB-SAP-1100
      Int_CI->NCIINT_OK := "F"                                            //MJB-SAP-1100
      If Empty(ALLTRIM(Int_CI->NCIMSG))                                   //MJB-SAP-1100
         Int_CI->NCIMSG := "Aviso: .....Vide Idiomas"                     //MJB-SAP-1100
      Endif                                                               //MJB-SAP-1100
   Endif                                                                  //MJB-SAP-1100
Endif                                                                     //MJB-SAP-1100

IF Int_CI->NCIINT_OK = "T"
   nResumoCer+=1
ELSE
   nResumoErr+=1
ENDIF

//AOM - 08/02/2012
If cModulo == "EDC"  .And. Empty(Int_CI->NCIIMPORT)
   Int_CI->NCIIMPORT := "S"
EndIf



RETURN .T.

*---------------------------------------------------------------------------------------------------*
FUNCTION IN100GrvCI()
*---------------------------------------------------------------------------------------------------*
LOCAL cAlias
Private cedcSubjc:="" //Alcir Alves - 05-05-05 - assunto do e-mail
PRIVATE cedcMAIL:="" //Alcir Alves - 04-05-05 - corpo do e-mail somente com os itens modificados
PRIVATE cedcBDM:="" //Alcir Alves - 05-05-05 - corpo do e-mail geral
IF Int_CI->NCITIPO # INCLUSAO

   SB1->(DBSEEK(cFilSB1+LEFT(Int_CI->NCICOD_I,nLenItem)))
   IF SB1->(EOF()) .AND. Int_CI->NCITIPO = ALTERACAO
      EVAL(bmsg,STR0120+STR0544+STR0141) //"ITEM"### SEMCADASTRO " P/ ALTERACAO"
      RETURN
   ELSE
      //Alcir Alves - 04-05-05
      if EasyGParam("MV_ENVMAIL",,.F.)==.T. //Caso parametro para enviar e-mail        
         IF EasyGParam("MV_EIC_EDC",,.F.)==.T. //CASO EXISTA INTEGRAÇÃO DRAWBACK
            IF ED2->(DBSEEK(cFilED2+AVKEY(SB1->B1_COD,"ED2_ITEM")))          
               cedcMAIL:=""
               IF ALLTRIM(MSMM(SB1->B1_DESC_GI,LEN(Int_CI->NCIDESC_GI),1))#ALLTRIM(Int_CI->NCIDESC_GI)  //DESCRICAO DA LI
                   cedcMAIL+=STR0743+"("+ALLTRIM(MSMM(SB1->B1_DESC_GI,LEN(Int_CI->NCIDESC_GI),1))+")"+STR0744+"("+ALLTRIM(Int_CI->NCIDESC_GI)+")"+chr(13)+chr(10)
               ENDIF
               IF SB1->B1_EX_NCM#AVKEY(Int_CI->NCIQUALTEC,"B1_EX_NCM")  //modificaçao de NCM
                   cedcMAIL+=STR0745+"("+ALLTRIM(SB1->B1_EX_NCM)+")"+STR0744+"("+ALLTRIM(Int_CI->NCIQUALTEC)+")"+chr(13)+chr(10)
               ENDIF
               IF SB1->B1_UM#AVKEY(Int_CI->NCIUNI,"B1_UM")  //UNIDADE DE MEDIDA
                   cedcMAIL+=STR0749+"("+ALLTRIM(SB1->B1_UM)+")"+STR0744+"("+ALLTRIM(Int_CI->NCIUNI)+")"+chr(13)+chr(10)
               ENDIF

               cedcSubjc:=""
               If EasyEntryPoint("IN100CLI")                       
                  ExecBlock("IN100CLI",.F.,.F.,"ITEM_MODIFICADO_EMAIL")
               EndIf
               cedcBDM:=""
               IF !empty(cedcMAIL) //caso não esteja vazio quer dizer que houve modificação em no minimo algum item
                  //"Modificação do conteúdo do itens ("                 ") na integração "  
                   cedcSubjc:=STR0746+SB1->B1_COD+STR0747
                   cedcBDM:=STR0748+chr(13)+chr(10)+cedcMAIL
                   lenv:=EICINmail(NIL,NIL,cedcSubjc,cedcBDM,NIL,NIL,NIL)
               ENDIF
             ENDIF
         ENDIF      
      endif
      //     
   ENDIF
   cAlias:=ALIAS()
   Reclock("SB1",.F.)
   DBSELECTAREA(cAlias)
   IF Int_CI->NCITIPO = EXCLUSAO

      IF ! EMPTY(SB1->B1_DESC_P)
         MSMM(SB1->B1_DESC_P,,,,2)
      ENDIF
      IF ! EMPTY(SB1->B1_DESC_I)
         MSMM(SB1->B1_DESC_I,,,,2)
      ENDIF
      IF ! EMPTY(SB1->B1_DESC_GI)
         MSMM(SB1->B1_DESC_GI,,,,2)
      ENDIF

      //** PLB 04/05/07 - Para exclusão de campos Memo customizados do SB1 (chamado 051188)
      If EasyEntryPoint("IN100CLI")                       
         ExecBlock("IN100CLI",.F.,.F.,"ANTES_EXCLUIR_SB1")
      EndIf
      //**

      Reclock("SB1",.F.)
      DBSELECTAREA(cAlias)
      SB1->(DBDELETE())
      SB1->(DBCOMMIT())
      SB1->(MSUNLOCK())
      SA5->(DBSETORDER(2))
      SA5->(DBSEEK(cFilSA5+LEFT(Int_CI->NCICOD_I,nLenItem)))
      SA5->(DBEVAL({|| Reclock("SA5",.F.), SA5->(DBDELETE()),;
                            SA5->(DBCOMMIT()),  SA5->(MSUNLOCK()),;
                            SA5->(DBSKIP())},,;
                   {|| ALLTRIM(SA5->A5_PRODUTO)==LEFT(ALLTRIM(Int_CI->NCICOD_I),nLenItem).AND.SA5->A5_FILIAL==cFilSA5 }))
      SA5->(DBSETORDER(1))
      SYG->(DBSEEK(cFilSYG))
      DO WHILE ! SYG->(EOF()) .AND. cFilSYG==SYG->YG_FILIAL
         IF LEFT(Int_CI->NCICOD_I,nLenItem) = SYG->YG_ITEM
            Reclock("SYG",.F.)
            SYG->(DBDELETE())
         ENDIF
         SYG->(DBSKIP())
      ENDDO
      DBSELECTAREA(cAlias)
      SB1->(MSUNLOCK())
      RETURN
   ENDIF
ENDIF

IF Int_CI->NCITIPO = INCLUSAO
   IN100RecLock('SB1')
   SB1->B1_FILIAL := cFilSB1
   SB1->B1_COD :=LEFT(Int_CI->NCICOD_I,nLenItem)
   SB1->B1_LOCPAD := '.'
ENDIF

IF(!EMPTY(LEFT(Int_CI->NCIUNI,nTamUM)) ,SB1->B1_UM :=LEFT(Int_CI->NCIUNI,nTamUM),)
IF(!EMPTY(Int_CI->NCIDESC_P) ,SB1->B1_DESC   :=MEMOLINE(Int_CI->NCIDESC_P,Len(SB1->B1_DESC)),)  //MJB-SAP-1200
IF(!EMPTY(Int_CI->NCITEC)    ,SB1->B1_POSIPI :=Int_CI->NCITEC,)
IF(!EMPTY(Int_CI->NCIQUALTEC),SB1->B1_EX_NCM :=Int_CI->NCIQUALTEC,)
IF(!EMPTY(Int_CI->NCIFPCOD)  ,SB1->B1_FPCOD  :=Int_CI->NCIFPCOD,)
IF(!EMPTY(Int_CI->NCIANUENTE),SB1->B1_ANUENTE:=If(Int_CI->NCIANUENTE$cSim,"1","2"),)
IF(VAL(Int_CI->NCIVLREF_US)#0,SB1->B1_VLREFUS:=VAL(Int_CI->NCIVLREF_US),)
If lEIC_EEC  .Or. cModulo == "EDC"                                           //MJB-SAP-1100
   IF(!EMPTY(Int_CI->NCIEMBAL)  ,SB1->B1_CODEMB :=Int_CI->NCIEMBAL,)         //MJB-SAP-1100
   IF(!EMPTY(Int_CI->NCIQTDEMB) ,SB1->B1_QE:=Val(Int_CI->NCIQTDEMB),)//AWR 23/08/2002
   
   //AOM - 08/02/2012
   If SB1->(FieldPos("B1_IMPORT")) > 0
      SB1->B1_IMPORT := Int_CI->NCIIMPORT
   EndIf
   
ENDIF
IF Int_CI->NCITIPO = INCLUSAO
   SB1->B1_PESO :=IF(VAL(RIGHT(Int_CI->NCIPESO_L,11))>0,VAL(RIGHT(Int_CI->NCIPESO_L,11)),1)
ELSE
   IF VAL(RIGHT(Int_CI->NCIPESO_L,11)) # 0
      SB1->B1_PESO :=IF(VAL(RIGHT(Int_CI->NCIPESO_L,11))>0,VAL(RIGHT(Int_CI->NCIPESO_L,11)),1)
   ENDIF
ENDIF

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"GRVCI")
ENDIF

IF ! EMPTY(Int_CI->NCIDESC_P)
   IF Int_CI->NCITIPO=INCLUSAO
     nNumMsmm+=1
   ENDIF
   MSMM(IF(Int_CI->NCITIPO=ALTERACAO,SB1->B1_DESC_P,IF(lMsmm,STRZERO(nNumMsmm,6),)),nSB1_P,,ALLTRIM(Int_CI->NCIDESC_P),1,,,"SB1","B1_DESC_P")
ENDIF
IF ! EMPTY(Int_CI->NCIDESC_I)
   IF Int_CI->NCITIPO=INCLUSAO
     nNumMsmm+=1
   ENDIF
   MSMM(IF(Int_CI->NCITIPO=ALTERACAO,SB1->B1_DESC_I,IF(lMsmm,STRZERO(nNumMsmm,6),)),nSB1_I,,ALLTRIM(Int_CI->NCIDESC_I),1,,,"SB1","B1_DESC_I")
ENDIF
IF ! EMPTY(Int_CI->NCIDESC_GI)
   IF Int_CI->NCITIPO=INCLUSAO
     nNumMsmm+=1
   ENDIF
   MSMM(IF(Int_CI->NCITIPO=ALTERACAO,SB1->B1_DESC_GI,IF(lMsmm,STRZERO(nNumMsmm,6),)),nSB1_GI,,ALLTRIM(Int_CI->NCIDESC_GI),1,,,"SB1","B1_DESC_GI")
ENDIF

IF ! EMPTY(Int_CI->NCITEC) .AND. ! SYD->(DBSEEK(cFilSYD+AvKey(Int_CI->NCITEC,"YD_TEC")+Avkey(Int_CI->NCIQUALTEC,"YD_EX_NCM"))) .AND. ;
   Int_Param->NPAINC_NBM
   Int_CI->(IN100Cadastra(CAD_NB,Int_CI->NCITEC,Int_CI->NCIQUALTEC))
ENDIF

IF ! EMPTY(SB1->B1_FPCOD) .AND. ! SYC->(DBSEEK(cFilSYC+AvKey(SB1->B1_FPCOD,"YC_COD"))) .AND. ;
   Int_Param->NPAINC_FAM
   Int_CI->(IN100Cadastra(CAD_FP,SB1->B1_FPCOD,MEMOLINE(Int_CI->NCIDESC_P,25)))
ENDIF

SB1->(MSUNLOCK())

RETURN .T.
*---------------------------------------------------------------------------
FUNCTION IN100FabFor()
*---------------------------------------------------------------------------
AADD(TB_Cols,{{||Int_FB->NFBCOD}                         ,"",STR0142             }) //"Codigo"
AADD(TB_Cols,{{||Int_FB->NFBNOME}                        ,"",STR0143               }) //"Nome"
AADD(TB_Cols,{{||Int_FB->NFBNOME_R}                      ,"",STR0144      }) //"Nome Reduzido"
AADD(TB_Cols,{{||Int_FB->NFBEND}                         ,"",STR0145           }) //"Endereco"
AADD(TB_Cols,{{||Int_FB->NFBBAIRRO}                      ,"",STR0146             }) //"Bairro"
AADD(TB_Cols,{{||LEFT(Int_FB->NFBCIDADE,15)}             ,"",STR0147             }) //"Cidade"
AADD(TB_Cols,{{||Int_FB->NFBESTADO}                      ,"",STR0148             }) //"Estado"
AADD(TB_Cols,{{||Int_FB->NFBCOD_P}                       ,"",STR0149     }) //"Codigo do Pais"
AADD(TB_Cols,{{||If(!EMPTY(Int_FB->NFBCEP),Int_FB->NFBCEP+"  ",Int_FB->NFBCEP2)},"",STR0150              }) //"Cep"
AADD(TB_Cols,{{||Int_FB->NFBCX_POST}                     ,"",STR0151}) //"Caixa Postal"
AADD(TB_Cols,{{||Int_FB->NFBCONTATO}                     ,"",STR0152}) //"Contato"
AADD(TB_Cols,{{||Int_FB->NFBDEPTO}                       ,"",STR0153}) //"Departamento"
AADD(TB_Cols,{{||Int_FB->NFBFONES}                       ,"",STR0154}) //"Fones"
AADD(TB_Cols,{{||LEFT(Int_FB->NFBTELEX,10)}              ,"",STR0155}) //"Telex"
AADD(TB_Cols,{{||LEFT(Int_FB->NFBFAX,15)}                ,"",STR0156}) //"Fax"
AADD(TB_Cols,{{||Int_FB->NFBEMAIL}                       ,"",STR0157}) //"E-Mail"
AADD(TB_Cols,{{||IF(Int_FB->NFB_ID_FBFN='1',STR0158,IF(Int_FB->NFB_ID_FBFN='2',STR0159,IF(Int_FB->NFB_ID_FBFN='3',STR0160,PADL(Int_FB->NFB_ID_FBFN,7))))},"",STR0037}) //'FABRIC.'###'FORNEC.'###'FAB/FOR'###"Tipo"
AADD(TB_Cols,{{||IF(Int_FB->NFBSTATUS='1',STR0096,IF(Int_FB->NFBSTATUS='2',STR0095,PADL(Int_FB->NFBSTATUS,3)))},"",STR0161            }) //'Sim'###'Nao'###"Homologado"
AADD(TB_Cols,{{||Int_FB->NFBREPRES}                      ,"",STR0162}) //"Representante"
AADD(TB_Cols,{{||Int_FB->NFBREPR_EN}                     ,"",STR0163}) //"Endereco do Repres."
AADD(TB_Cols,{{||Int_FB->NFBREPRBAI}                     ,"",STR0164}) //"Bairro do Repres."
AADD(TB_Cols,{{||Int_FB->NFBREPRMUN}                     ,"",STR0165}) //"Cidade do Repres."
AADD(TB_Cols,{{||LEFT(Int_FB->NFBREPREST,nLenEst)}       ,"",STR0166}) //"Estado do Repres."  //SO.:0032 OS.:0298/02 FCD
AADD(TB_Cols,{{||Int_FB->NFBREPPAIS}                     ,"",STR0167}) //"Codigo do Pais do Repres."
AADD(TB_Cols,{{||Int_FB->NFBREPRCEP}                     ,"",STR0168}) //"Cep do Repres."
AADD(TB_Cols,{{||Int_FB->NFBREPCONT}                     ,"",STR0169}) //"Contato do Repres."
AADD(TB_Cols,{{||Int_FB->NFBREPRTEL}                     ,"",STR0170}) //"Fones do Repres."
AADD(TB_Cols,{{||Int_FB->NFBREPRFAX}                     ,"",STR0171}) //"Fax do Repres."
AADD(TB_Cols,{{||Int_FB->NFBREPREMA}                     ,"",STR0172}) //"E-Mail do Repres."
AADD(TB_Cols,{{||IF(Int_FB->NFBID_REPR='S',STR0096,IF(Int_FB->NFBID_REPR='N',STR0095,Int_FB->NFBID_REPR))},"",STR0173}) //'Sim'###'Nao'###"Identifica Repr. na L.I."
AADD(TB_Cols,{{||Int_FB->NFBSWIFT  }                     ,"",STR0174}) //"Swift do Fornecedor"
AADD(TB_Cols,{{||LEFT(Int_FB->NFBREPR_BA,3)}             ,"",STR0175          }) //"No. Banco"
AADD(TB_Cols,{{||LEFT(Int_FB->NFBREPR_AG,5)}             ,"",STR0176        }) //"No. Agencia"
AADD(TB_Cols,{{||LEFT(Int_FB->NFBREPR_CO,10)}            ,"",STR0177          }) //"No. Conta"
AADD(TB_Cols,{{||TRANSFORM(Int_FB->NFBREPR_CGC,'@R 99.999.999/9999-99')},"",STR0178  }) //"C.G.C."
AADD(TB_Cols,{{||IF(Int_FB->NFBCOMI_SO='1',STR0179,IF(Int_FB->NFBCOMI_SO='2',STR0180,IF(Int_FB->NFBCOMI_SO='3',STR0181,IF(Int_FB->NFBCOMI_SO='4',STR0182,PADL(Int_FB->NFBCOMI_SO,6)))))},"",STR0183}) //'F.O.B.'###'C & F'###'Ex.Fab'###'F.A.S.'###"Comissão sobre"
AADD(TB_Cols,{{||IF(Int_FB->NFBRET_PAI='S',STR0096,IF(Int_FB->NFBRET_PAI='N',STR0095,PADL(Int_FB->NFBRET_PAI,3)))},"",STR0184}) //'Sim'###'Nao'###"Comissão Retida no Pais"
AADD(TB_Cols,{{||LEFT(Int_FB->NFBFORN_BA,3)+' / '+LEFT(Int_FB->NFBFORN_AG,5)+' / '+LEFT(Int_FB->NFBFORN_CO,10)},"",STR0185}) //"Banco/Agencia/Conta Fornecedor"
AADD(TB_Cols,{{||Int_FB->NFBPROC_1}                      ,"",STR0186     }) //"1o. Pais  Proc."
AADD(TB_Cols,{{||Int_FB->NFBPROC_2}                      ,"",STR0187     }) //"2o. Pais  Proc."
AADD(TB_Cols,{{||Int_FB->NFBPROC_3}                      ,"",STR0188     }) //"3o. Pais  Proc."

ASIZE(TBRCols,0)
AADD(TBRCols,{"IN100Status()"      ,STR0036}) //"Status"
AADD(TBRCols,{"IN100Tipo()"        ,STR0037}) //"Tipo"
AADD(TBRCols,{"IN100CTD(Int_FB->NFBINT_DT)",STR0071}) //"Dt Integ"
AADD(TBRCols,{"Int_FB->NFBCOD"             ,STR0142}) //"Codigo"
AADD(TBRCols,{"LEFT(Int_FB->NFBNOME,30)"   ,STR0143}) //"Nome"
AADD(TBRCols,{"Int_FB->NFBNOME_R"          ,STR0144}) //"Nome Reduzido"
AADD(TBRCols,{"Int_FB->NFBEND"             ,STR0145}) //"Endereco"
AADD(TBRCols,{"IF(Int_FB->NFB_ID_FBFN='1','"+STR0158+"',IF(NFB_ID_FBFN='2','"+STR0159+"',IF(NFB_ID_FBFN='3','"+STR0160+"',PADL(NFB_ID_FBFN,7))))",STR0037}) //'FABRIC.'###'FORNEC.'###'FAB/FOR'###"Tipo"
//AADD(TBRCols,{"IN100Repres()"      ,STR0189}) //"Representante / Imprime na G.I."
AADD(TBRCols,{"TRANSFORM(Int_FB->NFBREPR_CGC,'@R 99.999.999/9999-99')",STR0178}) //"C.G.C."
AADD(TBRCols,{"IN100Comissao(Int_FB->NFBCOMI_SO,Int_FB->NFBRET_PAI)",STR0190 }) //"Com.Ret.Pais"

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"COLFB")
ENDIF
AADD(TB_Cols,{{||IN100E_Msg(.T.)}                ,"",STR0112}) //"Mensagem"

RETURN .T.

*------------------------------*
FUNCTION IN100Comissao(Sob,Ret)
*------------------------------*
RETURN IF(Sob='1',STR0179,IF(Sob='2',STR0180,IF(Sob='3',STR0181,IF(Sob='4',STR0182,PADL(Sob,6)))))+' -'+IF(Ret='S',STR0096,IF(Ret='N',STR0095,PADL(Ret,3))) //'F.O.B.'###'C & F'###'Ex.Fab'###'F.A.S.'###'Sim'###'Nao'

*---------------------*
FUNCTION IN100Repres()
*---------------------*
IF ! EMPTY(NFBREPRES)
   RETURN  LEFT(NFBREPRES,25)+'/'+IF(NFBID_REPR='S',STR0096,IF(NFBID_REPR='N',STR0095,PADL(NFBID_REPR,3))) //'Sim'###'Nao'
ELSE
   RETURN  SPACE(29)
ENDIF

*------------------------*
FUNCTION IN100ESTRU(cArq)
*------------------------*
LOCAL cDirAux,aEstru:={},lCerto,I, lDiferente, nPosAno:=0, lCopia:=.F.,cExt
Local cFileExt

If cArq = 'PA'
   cDirAux:=''                                                             
   cExt   := "000"
Else
   cDirAux:=cDirNPA
   cExt   := cRegNPA
EndIf

cFileExt := IN100File(cArq, cExt)

lCerto:=.T.

aEstruDef:={}

In100DefEstru(cArq)

If cModulo$"EEC/EDC" 
   nAno:=4
Else   
   nAno:=2
EndIf   

If cFuncao == CAD_TC
   nPosAno := ASCAN(aEstruDef,{|chave| chave[1]=="NTCDATA"})
   IF nPOSANO > 0
      nAno    := If(aEstruDef[nPOSANO,3]=6,2,4)
   ENDIF
EndIf

//AOM -  09/02/2012
If cFuncao == CAD_CI
   nPosAno := ASCAN(aEstruDef,{|chave| chave[1]=="NCIINT_DT"})
   IF nPOSANO > 0
      nAno    := If(aEstruDef[nPOSANO,3]=6,2,4)
   ENDIF
EndIf

If MsFile(cFileExt)
   DBUSEAREA(.T.,"TOPCONN",cFileExt,"Auxiliar",.T.)
   IF NETERR()
      IN_MSG(STR0194+cFileExt+STR0195) //"Arquivo de "###" n„o disponivel ..."
      Return .F.
   ENDIF

   If CMPSTRUCT("Auxiliar") //THTS - 16/08/2019 - Compara a estrutura do arquivo no banco com o do fonte, se tiver diferenca recria a tabela. Se .T. = Estrutura tem diferenca
		Auxiliar->(dbcloseAREA())
		MsErase(cFileExt)
		If !lParam  //MJB-SAP-0800
			MsAguarde({||IN100ALTESTRU({|msg| MsProcTxt(msg)},cArq,cDirAux,aEstruDef,@lCerto,.F.)},STR0196+IN100File(cArq, cExt)+"...") //"Alterando estrutura do arquivo "
		Else
			IN100ALTESTRU({|msg| IN_MSG(msg) },cArq,cDirAux,aEstruDef,@lCerto,lCopia)   //MJB-SAP-0800
		Endif
   Else
		Auxiliar->(dbcloseAREA())
	EndIf
Else
   If !lParam  //MJB-SAP-0800
      MsAguarde({||IN100ALTESTRU({|msg| MsProcTxt(msg)},cArq,cDirAux,aEstruDef,@lCerto,.F.)},STR0196+IN100File(cArq, cExt)+"...") //"Alterando estrutura do arquivo "
   Else
      IN100ALTESTRU({|msg| IN_MSG(msg) },cArq,cDirAux,aEstruDef,@lCerto,lCopia)   //MJB-SAP-0800
   Endif
EndIf

If cArq == "PE" 
   If Ascan(aEstruDef, {|x| x[1] == "NPENOTIFY"}) == 0
      lNPENOTIFY := .F.
   Else
      lNPENOTIFY := .T.      
   EndIf
EndIf                                                                                                 //MJB-SAP-0501

If cArq == "IP" 
   If Ascan(aEstruDef, {|x| x[1] == "NIPTEC"}) == 0
      lNIPTEC := .F.
   Else
      lNIPTEC := .T.      
   EndIf
EndIf                                                                                             

If cArq == "PD"                                                                                       //MJB-SAP-0501
   If Ascan(aEstruDef, {|x| x[1] == "NPDPSBRUN"}) == 0
      lNPDPSBRUN := .F.
   Else
      lNPDPSBRUN := .T.      
   EndIf
   
   If Ascan(aEstruDef, {|x| x[1] == "NPDPSBRTO"}) == 0
      lNPDPSBRTO := .F.
   Else
      lNPDPSBRTO := .T.      
   EndIf
   
EndIf

Return lCerto

*----------------------------------------------------------------*
FUNCTION IN100ALTESTRU(bMsg,cArq,cDirAux,aEstruDef,lCerto,lCopia)
*----------------------------------------------------------------*
Local cExt
Local cFileExt

If !lParam         //MJB-SAP-0900
   Eval(bMsg,STR0197) //"Criando / Alterando Estrutura."
Endif              //MJB-SAP-0900                                 

If cArq = 'PA'
   cExt   := "000"
Else
   cExt   := cRegNPA
EndIf
cFileExt := IN100File(cArq, cExt)
If !MSFILE(cFileExt)
   MSCREATE(cFileExt,aEstruDef,"TOPCONN") 
EndIf

Return .T.

Static Function IN100File(cArq, cExt)
Local cFileExt := "N"+cArq+cExt
If cArq == 'PA'
    cFileExt := "IN100_" + cFileExt
EndIf
Return cFileExt

*--------------------------*
FUNCTION IN_MSG(cMSG,cMSG2)
*--------------------------*
If ! lParam
   MsgInfo(cMsg,If(cMSG2#NIL,cMSG2,"Informação"))
Else
   nResumoArq :=cMsg
   cMsgR3:=IF(cMsgR3#NIL,cMsgR3,' ')+cMsg    //MJB-SAP-0900
   ConOut(cMsg)
EndIf

Return .T.

*---------------------------------------------------------------------------------------------------*
FUNCTION IN100LerFB()
*---------------------------------------------------------------------------------------------------*
IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"LERFB")
ENDIF

IF EMPTY(Int_FB->NFBCOD)
   EVAL(bmsg,STR0557+STR0549)  // CODIGO_FB INVALIDO
ENDIF

IF ! SA2->(DBSEEK(cFilSA2+Int_FB->NFBCOD+'.'))
   IF Int_FB->NFBTIPO = EXCLUSAO  //# INCLUSAO
      EVAL(bmsg,STR0557+STR0544)  // CODIGO_FB SEM CADASTRO
   ENDIF

   IF Int_FB->NFBTIPO = ALTERACAO
      cAlias := Alias()
      Reclock( "Int_FB", .F. )
      DbSelectArea( cAlias )

      Int_FB->NFBTIPO := INCLUSAO

      Int_FB->( MsUnlock() )
   ENDIF

ELSEIF Int_FB->NFBTIPO = INCLUSAO
       EVAL(bmsg,STR0557+STR0545)  // CODIGO_FB COM CADASTRO

ELSEIF Int_FB->NFBTIPO == EXCLUSAO
       IF LEFT(ALLTRIM(UPPER(SA2->A2_ID_FBFN)),1)="1"       //"1-FABR"
          SA5->(DBSETORDER(4))
          IF SA5->(DBSEEK(cFilSA5+SA2->A2_COD))
             EVAL(bmsg,STR0199) //'FABR/FORN POSSUI LIGACAO COM ITEM'
          ENDIF
       ELSEIF LEFT(ALLTRIM(UPPER(SA2->A2_ID_FBFN)),1)="2"   //"2-FORN"
          SA5->(DBSETORDER(1))
          IF SA5->(DBSEEK(cFilSA5+SA2->A2_COD+SA2->A2_LOJA))
             EVAL(bmsg,STR0199) //'FABR/FORN POSSUI LIGACAO COM ITEM'
          ENDIF
       ELSEIF LEFT(ALLTRIM(UPPER(SA2->A2_ID_FBFN)),1)="3"   //"3-AMBOS"
          SA5->(DBSETORDER(1))
          IF SA5->(DBSEEK(cFilSA5+SA2->A2_COD+SA2->A2_LOJA))
             EVAL(bmsg,STR0199) //'FABR/FORN POSSUI LIGACAO COM ITEM'
          ENDIF
          SA5->(DBSETORDER(4))
          IF SA5->(DBSEEK(cFilSA5+SA2->A2_COD))
             EVAL(bmsg,STR0199) //'FABR/FORN POSSUI LIGACAO COM ITEM'
          ENDIF
       ENDIF
       SA5->(DBSETORDER(1))
ENDIF

IF Int_FB->NFBTIPO == EXCLUSAO

   If lEIC_EEC                                                            //MJB-SAP-1100
      IN100PE_FF(Int_FB->NFBCOD,SA2->A2_LOJA)                             //MJB-SAP-1100
   Endif                                                                  //MJB-SAP-1100

   IF EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"VALFB")
   ENDIF
   IN100VerErro(cErro,cAviso)
   IF Int_FB->NFBINT_OK = "T"
      nResumoCer+=1
   ELSE
      nResumoErr+=1
   ENDIF
   RETURN
ENDIF

//IF AT(Int_FB->NFB_ID_FBFN,'123') = 0 .AND. SA2->(EOF())                 //MJB-SAP-1100
If ! SX5->(DBSEEK(cFilSX5+'48'+Int_FB->NFB_ID_FBF))                //MJB-SAP-1100
   EVAL(bmsg,STR0202) //'IDENTIFICACAO FABR/FORN INVALIDO'
ENDIF

IF EMPTY(Int_FB->NFBNOME) .AND. SA2->(EOF())
   EVAL(bmsg,STR0203+STR0546) //"RAZAO SOCIAL NAO INFORMADO
ENDIF

IF EMPTY(Int_FB->NFBEND) .AND. SA2->(EOF())
   EVAL(bmsg,STR0145+STR0546) //"ENDERECO NAO INFORMADO
ENDIF

IF AT(Int_FB->NFBSTATUS,'12') = 0 .AND. SA2->(EOF())
   EVAL(bmsg,STR0204) //"STATUS HOMOLOGADO INVALIDO"
ENDIF

IF EMPTY(Int_FB->NFBREPRES) .AND. ! SA2->(EOF())
   Int_FB->NFBREPRES:=ALLTRIM(SA2->A2_REPRES)
ENDIF

IF EMPTY(ALLTRIM(Int_FB->NFBID_REPR)) .AND. ! SA2->(EOF())
   Int_FB->NFBID_REPR:=UPPER(SA2->A2_ID_REPR)
ENDIF

IF ! EMPTY(ALLTRIM(Int_FB->NFBID_REPR)) .AND. ! Int_FB->NFBID_REPR $ (cSim+cNao)//STR0205 //'SN'
   EVAL(bmsg,STR0206) //"IDENT.DO REPR. NA L.I. INVALIDO"
ELSEIF EMPTY(ALLTRIM(Int_FB->NFBID_REPR)) .AND. SA2->(EOF()) .AND. EMPTY(ALLTRIM(Int_FB->NFBREPRES))
   Int_FB->NFBID_REPR:=STR0207 //'N'
ELSEIF EMPTY(ALLTRIM(Int_FB->NFBID_REPR)) .AND. SA2->(EOF()) .AND. ! EMPTY(ALLTRIM(Int_FB->NFBREPRES))
   EVAL(bmsg,STR0208) //"IDENT.DO REPR. NA L.I. NAO INFORMADO"
ENDIF

IF ! EMPTY(LEFT(Int_FB->NFBREPR_BA,3)) .AND. ! EMPTY(ALLTRIM(Int_FB->NFBREPRES))
   IF ! SA6->(DBSEEK(cFilSA6+LEFT(Int_FB->NFBREPR_BA,3)+LEFT(Int_FB->NFBREPR_AG,5))) .AND. ;
      ! Int_Param->NPAINC_BAN
        EVAL(bmsg,STR0209+STR0544) //"BANCO/AGENCIA REPRESENTANTE SEM CADASTRO
   ENDIF
   IF EMPTY(LEFT(Int_FB->NFBREPR_CO,10))
      EVAL(bmsg,STR0210+STR0546) //"CONTA DO REPRESENTANTE NAOINFORMADO
   ENDIF
ELSEIF ! EMPTY(LEFT(Int_FB->NFBREPR_BA,3)) .AND. EMPTY(ALLTRIM(Int_FB->NFBREPRES))
   EVAL(bmsg,STR0211+STR0546) //"BANCO REPRES.INF. NOME REPRES. NAOINFORMADO
ENDIF

IF ! EMPTY(ALLTRIM(Int_FB->NFBREPR_CGC)) .AND. ! EMPTY(ALLTRIM(Int_FB->NFBREPRES))
   IF ! E_CGC(Int_FB->NFBREPR_CGC,.F.) .AND. Int_FB->NFBREPR_CGC != "99999999999999"
      EVAL(bmsg,STR0212) //"CGC REPRESENTANTE INVALIDO"
   ENDIF
ELSEIF ! EMPTY(ALLTRIM(Int_FB->NFBREPR_CGC)) .AND. EMPTY(ALLTRIM(Int_FB->NFBREPRES))
   EVAL(bmsg,STR0213+STR0546) //"CGC REPRES.INF. NOME REPRES. NAO INFORMADO
ENDIF

IF AT(Int_FB->NFBCOMI_SO,' 1234') = 0 .AND. ! EMPTY(ALLTRIM(Int_FB->NFBREPRES))
   EVAL(bmsg,STR0214) //"TIPO COMISSAO REPRESENT. INVALIDO"
ENDIF

IF AT(Int_FB->NFBRET_PAI,STR0215) = 0 .AND. ! EMPTY(ALLTRIM(Int_FB->NFBREPRES)) //'SN '
   EVAL(bmsg,STR0216) //"COMISSAO RETIDA NO PAIS INVALIDA"
ENDIF

IF EMPTY(ALLTRIM(Int_FB->NFBREPRES))
   IF ! EMPTY(ALLTRIM(Int_FB->NFBREPR_EN)) .OR. ! EMPTY(ALLTRIM(Int_FB->NFBREPR_AG)) .OR.;
      ! EMPTY(ALLTRIM(Int_FB->NFBREPRTEL)) .OR. ! EMPTY(ALLTRIM(Int_FB->NFBREPRFAX)) .OR.;
      ! EMPTY(ALLTRIM(Int_FB->NFBREPRMUN)) .OR. ! EMPTY(ALLTRIM(LEFT(Int_FB->NFBREPREST,nLenEst))) .OR.;   //SO.:0032 OS.:0298/02 FCD
      ! EMPTY(ALLTRIM(Int_FB->NFBREPPAIS)) .OR. ! EMPTY(ALLTRIM(Int_FB->NFBREPRCEP)) .OR.;
      ! EMPTY(ALLTRIM(Int_FB->NFBREPCONT)) .OR. ! EMPTY(ALLTRIM(Int_FB->NFBREPR_CO)) .OR.;
      ! EMPTY(ALLTRIM(Int_FB->NFBREPRBAI)) .OR. ! EMPTY(ALLTRIM(Int_FB->NFBREPREMA))

      EVAL(bmsg,STR0217+STR0546) //"NOME DO REPRESENTANTE NAO INFORMADO
   ENDIF
ENDIF

IF SA2->(EOF())

   IF AT(Int_FB->NFB_ID_FBFN,'23') # 0     // fornecedor
      IF ! EMPTY(LEFT(Int_FB->NFBFORN_BA,3)) .OR. ! EMPTY(LEFT(Int_FB->NFBFORN_AG,5))
         IF ! SA6->(DBSEEK(cFilSA6+LEFT(Int_FB->NFBFORN_BA,3)+LEFT(Int_FB->NFBFORN_AG,5)))
             IF ! Int_Param->NPAINC_BAN
                EVAL(bmsg,STR0218+STR0544) //"BANCO/AGENCIA FORNECEDOR SEMCADASTRO
             ENDIF
         ENDIF
         IF EMPTY(LEFT(Int_FB->NFBFORN_CO,10)) .AND. SA2->(EOF())
            EVAL(bmsg,STR0219+STR0546) //"CONTA DO FORNECEDOR NAOINFORMADO
         ENDIF
      ENDIF

   ELSEIF ! EMPTY(LEFT(Int_FB->NFBFORN_BA,3)) .OR. !EMPTY(LEFT(Int_FB->NFBFORN_AG,5))
          EVAL(bmsg,STR0220) //"REF.BANCARIA SO' P/ FORNEC."
   ENDIF
ENDIF

SYA->(dBSetOrder(1))
IF Empty( Int_FB->NFBCOD_P )  .AND.  SA2->(EOF())
   EVAL(bmsg,STR0149+STR0546) //"CODIGO DO PAIS NAO INFORMADO
ENDIF

IF !Empty( Int_FB->NFBCOD_P ) .AND. ! SYA->(DBSEEK(cFilSYA+Int_FB->NFBCOD_P))
   EVAL(bmsg,STR0149+STR0544) //"CODIGO DO PAIS SEM CADASTRO
ENDIF

IF !Empty( Int_FB->NFBPROC_1 ) .AND. ! SYA->(DBSEEK(cFilSYA+Int_FB->NFBPROC_1))
   EVAL(bmsg,STR0221+STR0544) //"1o. PAIS DE PROCEDENCIA SEM CADASTRO
ENDIF

IF !Empty( Int_FB->NFBPROC_2 ) .AND. ! SYA->(DBSEEK(cFilSYA+Int_FB->NFBPROC_2))
   EVAL(bmsg,STR0222+STR0544) //"2o. PAIS DE PROCEDENCIA SEM CADASTRO
ENDIF

IF !Empty( Int_FB->NFBPROC_3 ) .AND. ! SYA->(DBSEEK(cFilSYA+Int_FB->NFBPROC_3))
   EVAL(bmsg,STR0223+STR0544) //"3o. PAIS DE PROCEDENCIA SEM CADASTRO
ENDIF

IF !Empty( Int_FB->NFBREPPAIS ) .AND. ! SYA->(DBSEEK(cFilSYA+Int_FB->NFBREPPAIS)) .AND.;
   !Empty(ALLTRIM(Int_FB->NFBREPRES))
   EVAL(bmsg,STR0167+STR0544) //"CODIGO DO PAIS DO REPRES. SEM CADASTRO
ENDIF

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"VALFB")
ENDIF

IN100VerErro(cErro,cAviso)

IF Int_FB->NFBINT_OK = "T"
   nResumoCer+=1
ELSE
   nResumoErr+=1
ENDIF
RETURN .T.

*---------------------------------------------------------------------------------------------------*
FUNCTION IN100GrvFB()
*---------------------------------------------------------------------------------------------------*
LOCAL cAlias

IF Int_FB->NFBTIPO # INCLUSAO
   SA2->(DBSEEK(cFilSA2+Int_FB->NFBCOD+'.'))
   IF SA2->(EOF()) .AND. Int_FB->NFBTIPO = ALTERACAO
      EVAL(bmsg,STR0224+STR0544+STR0141) //"FABRICANTE/FORNECEDOR"### SEM CADASTRO  " P/ ALTERACAO"
      RETURN
   ENDIF
   cAlias:=ALIAS()
   Reclock("SA2",.F.)
   DBSELECTAREA(cAlias)

   IF Int_FB->NFBTIPO = EXCLUSAO
      SA2->(DBDELETE())
      SA2->(DBCOMMIT())
      SA2->(MSUNLOCK())
      
      If EasyEntryPoint("IN100CLI")
         ExecBlock("IN100CLI",.F.,.F.,"EXCFB")
      EndIf
      
      RETURN
      

   ENDIF
ENDIF

IF Int_FB->NFBTIPO = INCLUSAO
   IN100RecLock('SA2')
   SA2->A2_FILIAL := cFilSA2
   SA2->A2_COD    :=Int_FB->NFBCOD
   SA2->A2_LOJA   :='.'
ENDIF

IF(!EMPTY(Int_FB->NFBNOME)    ,SA2->A2_NOME    :=Int_FB->NFBNOME,)
IF(!EMPTY(Int_FB->NFBNOME_R)  ,SA2->A2_NREDUZ  :=Int_FB->NFBNOME_R,)
IF(!EMPTY(Int_FB->NFBEND)     ,SA2->A2_END     :=Int_FB->NFBEND,)
IF(!EMPTY(Int_FB->NFBNR_END)  ,SA2->A2_NR_END  :=Int_FB->NFBNR_END,)
IF(!EMPTY(Int_FB->NFBBAIRRO)  ,SA2->A2_BAIRRO  :=Int_FB->NFBBAIRRO,)
//IF(!EMPTY(LEFT(Int_FB->NFBCIDADE,15))  ,SA2->A2_MUN    :=LEFT(Int_FB->NFBCIDADE,15),)  // GFP - 21/08/2013
IF(!EMPTY(Int_FB->NFBCIDADE)  ,SA2->A2_MUN    :=Int_FB->NFBCIDADE,)
IF(!EMPTY(Int_FB->NFBESTADO)  ,SA2->A2_ESTADO  :=Int_FB->NFBESTADO,)
IF(!EMPTY(Int_FB->NFBCOD_P)   ,SA2->A2_PAIS    :=Int_FB->NFBCOD_P,)
IF(!EMPTY(Int_FB->NFBCEP)     ,SA2->A2_CEP     :=Int_FB->NFBCEP,)
IF(EMPTY(Int_FB->NFBCEP).AND.!EMPTY(Int_FB->NFBCEP2),SA2->A2_CEP:=Int_FB->NFBCEP2,)
IF(!EMPTY(Int_FB->NFBCX_POST) ,SA2->A2_CX_POST :=Int_FB->NFBCX_POST,)
IF(!EMPTY(Int_FB->NFBCONTATO) ,SA2->A2_CONTATO :=Int_FB->NFBCONTATO,)
IF(!EMPTY(Int_FB->NFBDEPTO)   ,SA2->A2_DEPTO   :=Int_FB->NFBDEPTO,)
IF(!EMPTY(Int_FB->NFBFONES)   ,SA2->A2_TEL     :=Int_FB->NFBFONES,)
IF(!EMPTY(LEFT(Int_FB->NFBTELEX,10))   ,SA2->A2_TELEX  :=LEFT(Int_FB->NFBTELEX,10),)
IF(!EMPTY(LEFT(Int_FB->NFBFAX,15))     ,SA2->A2_FAX    :=LEFT(Int_FB->NFBFAX,15),)
//IF(!EMPTY(Int_FB->NFB_ID_FBFN),SA2->A2_ID_FBFN :=IF(Int_FB->NFB_ID_FBFN='1',STR0225,IF(Int_FB->NFB_ID_FBFN='2',STR0226,STR0227)),) //'1-Fabr'###'2-Forn'###'3-Ambos'
IF(!EMPTY(Int_FB->NFB_ID_FBFN),SA2->A2_ID_FBFN :=If(!SX5->(DBSEEK(cFilSX5+"48"+Int_FB->NFB_ID_FBFN)),Int_FB->NFB_ID_FBFN,X5DESCRI()),)
IF(!EMPTY(Int_FB->NFBSTATUS)  ,SA2->A2_STATUS  :=Int_FB->NFBSTATUS,)
IF(!EMPTY(Int_FB->NFBREPRES)  ,SA2->A2_REPRES  :=Int_FB->NFBREPRES,)
IF(!EMPTY(Int_FB->NFBREPR_END),SA2->A2_REPR_EN :=Int_FB->NFBREPR_END,)
IF(!EMPTY(Int_FB->NFBID_REPR) ,SA2->A2_ID_REPR :=If(Int_FB->NFBID_REPR$cSim,"1","2"),)
IF(!EMPTY(LEFT(Int_FB->NFBREPR_BA,3)),SA2->A2_REPR_BA  :=LEFT(Int_FB->NFBREPR_BA,3),)
IF(!EMPTY(LEFT(Int_FB->NFBREPR_AG,5)),SA2->A2_REPR_AG :=LEFT(Int_FB->NFBREPR_AG,5),)
IF(!EMPTY(LEFT(Int_FB->NFBREPR_CO,10)),SA2->A2_REPR_CO :=LEFT(Int_FB->NFBREPR_CO,10),)
IF(!EMPTY(Int_FB->NFBREPR_CGC),SA2->A2_REPRCGC :=Int_FB->NFBREPR_CG,)
IF(!EMPTY(Int_FB->NFBCOMI_SO),SA2->A2_COMI_SO :=Int_FB->NFBCOMI_SO,)
IF(!EMPTY(Int_FB->NFBRET_PAI),SA2->A2_RET_PAI :=If(Int_FB->NFBRET_PAI$cSim,"1","2"),)
IF(!EMPTY(LEFT(Int_FB->NFBFORN_BA,3)) ,SA2->A2_BANCO   :=LEFT(Int_FB->NFBFORN_BA,3),)
IF(!EMPTY(LEFT(Int_FB->NFBFORN_AG,5)) ,SA2->A2_AGENCIA :=LEFT(Int_FB->NFBFORN_AG,5),)
IF(!EMPTY(LEFT(Int_FB->NFBFORN_CO,10)),SA2->A2_NUMCON  :=LEFT(Int_FB->NFBFORN_CO,10),)
IF(!EMPTY(Int_FB->NFBPROC_1)  ,SA2->A2_ORIG_1  :=Int_FB->NFBPROC_1,)
IF(!EMPTY(Int_FB->NFBPROC_2)  ,SA2->A2_ORIG_2  :=Int_FB->NFBPROC_2,)
IF(!EMPTY(Int_FB->NFBPROC_3)  ,SA2->A2_ORIG_3  :=Int_FB->NFBPROC_3,)
IF(!EMPTY(Int_FB->NFBREPRMUN) ,SA2->A2_REPRMUN :=Int_FB->NFBREPRMUN,)
IF(!EMPTY(LEFT(Int_FB->NFBREPREST,nLenEst)) ,SA2->A2_REPREST :=LEFT(Int_FB->NFBREPREST,nLenEst),) //SO.:0032 OS.:0298/02 FCD
IF(!EMPTY(Int_FB->NFBREPPAIS) ,SA2->A2_REPPAIS :=Int_FB->NFBREPPAIS,)
IF(!EMPTY(Int_FB->NFBREPRCEP) ,SA2->A2_REPRCEP :=Int_FB->NFBREPRCEP,)
IF(!EMPTY(Int_FB->NFBREPCONT) ,SA2->A2_REPCONT :=Int_FB->NFBREPCONT,)
IF(!EMPTY(Int_FB->NFBREPRTEL) ,SA2->A2_REPRTEL :=Int_FB->NFBREPRTEL,)
IF(!EMPTY(Int_FB->NFBREPRFAX) ,SA2->A2_REPRFAX :=Int_FB->NFBREPRFAX,)
IF(!EMPTY(Int_FB->NFBSWIFT  ) ,SA2->A2_SWIFT   :=Int_FB->NFBSWIFT  ,)
IF(!EMPTY(Int_FB->NFBREPRBAI) ,SA2->A2_REPBAIR :=Int_FB->NFBREPRBAI,)
IF(!EMPTY(Int_FB->NFBREPREMA) ,SA2->A2_REPR_EM :=Int_FB->NFBREPREMA,)
IF(!EMPTY(Int_FB->NFBEMAIL)   ,SA2->A2_EMAIL   :=Int_FB->NFBEMAIL,)

IF ! EMPTY(SA2->A2_REPR_BA) .AND. ;
   ! SA6->(DBSEEK(cFilSA6+AvKey(SA2->A2_REPR_BA,"A6_COD")+AvKey(SA2->A2_REPR_AG,"A6_AGENCIA"))) .AND. ;
   Int_Param->NPAINC_BAN
   Int_FB->(IN100Cadastra(CAD_BC,SA2->A2_REPR_BA,SA2->A2_REPR_AG))
ENDIF

IF ! EMPTY(SA2->A2_BANCO) .AND. ;
   ! SA6->(DBSEEK(cFilSA6+AvKey(SA2->A2_BANCO,"A6_COD")+AvKey(SA2->A2_AGENCIA,"A6_AGENCIA"))) .AND. ;
   Int_Param->NPAINC_BAN
   Int_FB->(IN100Cadastra(CAD_BC,SA2->A2_BANCO,SA2->A2_AGENCIA))
ENDIF

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"GRVFB")
ENDIF

SA2->(MSUNLOCK())
RETURN .T.       

*---------------------------------------------------------------------------
FUNCTION IN100NBM()
*---------------------------------------------------------------------------
AADD(TB_Cols,{{||Int_NB->NNBNCM   }                         ,"",STR0125        }) //"N.C.M."
AADD(TB_Cols,{{||Int_NB->NNBNALADI}                         ,"",STR0228   }) //"NALADI NCCA"
AADD(TB_Cols,{{||Int_NB->NNBNAL_SH}                         ,"",STR0229     }) //"NALADI SH"
AADD(TB_Cols,{{||Int_NB->NNBQUALNCM}                        ,"",STR0126    }) //"EX. N.C.M."
AADD(TB_Cols,{{||Int_NB->NNBDESTAQU}                        ,"",STR0230}) //"No do Destaque"
AADD(TB_Cols,{{||Int_NB->NNBALADI}                          ,"",STR0231         }) //"ALADI"
AADD(TB_Cols,{{||Int_NB->NNBDESC_P}                         ,"",STR0232     }) //"Descrição"
AADD(TB_Cols,{{||TRANSFORM(VAL(Int_NB->NNBPER_II),'@E 999.99')}  ,"",STR0233          }) //"% II"
AADD(TB_Cols,{{||TRANSFORM(VAL(Int_NB->NNBPER_IPI),'@E 999.99')} ,"",STR0234         }) //"% IPI"
AADD(TB_Cols,{{||TRANSFORM(VAL(Int_NB->NNBICMS_RED),'@E 999.99')},"",STR0235        }) //"% ICMS"
AADD(TB_Cols,{{||LEFT(NNBUNID,nLenUM)}              ,"",STR0121       }) //"Unidade"
AADD(TB_Cols,{{||Int_NB->NNBDL_GATT}                        ,"",STR0236      }) //"Lei GATT"
AADD(TB_Cols,{{||Int_NB->NNBDL_NALAD}                       ,"",STR0237    }) //"Lei NALADI"

ASIZE(TBRCols,0)
AADD(TBRCols,{ {|| IN100Status()}                   , STR0036       }) //"Status"
AADD(TBRCols,{ {|| IN100TIPO() }                    , STR0037         }) //"Tipo"
AADD(TBRCols,{ {|| IN100CTD(EVAL(bDtInteg))}        , STR0071     }) //"Dt Integ"
AADD(TBRCols,{ {||Int_NB->NNBNCM}                           ,STR0125        }) //"N.C.M."
AADD(TBRCols,{{||Int_NB->NNBNALADI}                         ,STR0228   }) //"NALADI NCCA"
AADD(TBRCols,{{||Int_NB->NNBNAL_SH}                         ,STR0229     }) //"NALADI SH"
AADD(TBRCols,{{||Int_NB->NNBQUALNCM}                        ,STR0126    }) //"EX. N.C.M."
AADD(TBRCols,{{||Int_NB->NNBDESTAQU}                        ,STR0230}) //"No do Destaque"
AADD(TBRCols,{{||Int_NB->NNBALADI}                          ,STR0231         }) //"ALADI"
AADD(TBRCols,{{||Int_NB->NNBDESC_P}                         ,STR0232     }) //"Descrição"
AADD(TBRCols,{{||TRANSFORM(VAL(Int_NB->NNBPER_II),'@E 999.99')}  ,STR0233          }) //"% II"
AADD(TBRCols,{{||TRANSFORM(VAL(Int_NB->NNBPER_IPI),'@E 999.99')} ,STR0234         }) //"% IPI"
AADD(TBRCols,{{||TRANSFORM(VAL(Int_NB->NNBICMS_RED),'@E 999.99')},STR0235        }) //"% ICMS"
AADD(TBRCols,{{||LEFT(NNBUNID,nLenUM)}              ,STR0121       }) //"Unidade"
AADD(TBRCols,{{||Int_NB->NNBDL_GATT}                        ,STR0236      }) //"Lei GATT"
AADD(TBRCols,{{||Int_NB->NNBDL_NALAD}                       ,STR0237    }) //"Lei NALADI"

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"COLNB")
ENDIF
AADD(TBRCols,{{||IN100E_MSG(.T.)}                   ,STR0112      }) //"Mensagem"
AADD(TB_Cols,{{||IN100E_Msg(.T.)}                   ,"",STR0112      }) // "Mensagem"

RETURN .T.

*---------------------------------------------------------------------------------------------------*
FUNCTION IN100LerNB()
*---------------------------------------------------------------------------------------------------*
IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"LERNB")
ENDIF

IF EMPTY(Int_NB->NNBNCM)
   EVAL(bmsg,STR0559+STR0546)  // CODIGO_NBM NAOINFORMADO
ENDIF

IF IN100NaoNum(Int_NB->NNBNCM)
   EVAL(bmsg,STR0140+STR0549) //"NCM INVALIDO
ENDIF

IF ! SYD->(DBSEEK(cFilSYD+AVKey(Int_NB->NNBNCM,"YD_TEC")+Int_NB->NNBQUALNCM))

   IF Int_NB->NNBTIPO = EXCLUSAO   //# INCLUSAO
      EVAL(bmsg,STR0559+STR0544)  // CODIGO_NBM SEMCADASTRO
   ENDIF

   IF Int_NB->NNBTIPO = ALTERACAO
      cAlias := Alias()
      Reclock( "Int_NB", .F. )
      DbSelectArea( cAlias )

      Int_NB->NNBTIPO := INCLUSAO

      Int_NB->( MsUnlock() )
   ENDIF

ELSEIF Int_NB->NNBTIPO = INCLUSAO
       EVAL(bmsg,STR0559+STR0545)  // CODIGO_NBM COMCADASTRO
ENDIF

IF Int_NB->NNBTIPO == EXCLUSAO
   IF EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"VALNB")
   ENDIF
   IN100VerErro(cErro,cAviso)
   IF Int_NB->NNBINT_OK = "T"
      nResumoCer+=1
   ELSE
      nResumoErr+=1
   ENDIF
   RETURN
ENDIF


IF EMPTY(LEFT(Int_NB->NNBUNID,nLenUM)) .AND. SYD->(EOF())
   EVAL(bmsg,STR0137+STR0546) //"UNIDADE MEDIDA NAOINFORMADO
ENDIF

IF ! EMPTY(LEFT(Int_NB->NNBUNID,nLenUM)) .AND. ! SAH->(DBSEEK(cFilSAH+ALLTRIM(LEFT(Int_NB->NNBUNID,nLenUM)))) .AND. ;
   ! Int_Param->NPAINC_UNI
   EVAL(bmsg,STR0137+STR0544) //"UNIDADE MEDIDA SEMCADASTRO
ENDIF

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"VALNB")
ENDIF

IN100VerErro(cErro,cAviso)

IF Int_NB->NNBINT_OK = "T"
   nResumoCer+=1
ELSE
   nResumoErr+=1
ENDIF
RETURN .T.

*---------------------------------------------------------------------------------------------------*
FUNCTION IN100GrvNB()
*---------------------------------------------------------------------------------------------------*

IF Int_NB->NNBTIPO # INCLUSAO
   SYD->(DBSEEK(cFilSYD+AVKey(Int_NB->NNBNCM,"YD_TEC")+Int_NB->NNBQUALNCM))
   IF SYD->(EOF()) .AND. Int_NB->NNBTIPO = ALTERACAO
      EVAL(bmsg,STR0238+STR0544+STR0141) //"NCMs"### SEMCADASTRO P/ ALTERACAO"
      RETURN
   ENDIF
   cAlias:=ALIAS()
   Reclock("SYD",.F.)
   DBSELECTAREA(cAlias)

   IF Int_NB->NNBTIPO = EXCLUSAO
      SYD->(DBDELETE())
      SYD->(DBCOMMIT())
      SYD->(MSUNLOCK())

      If EasyEntryPoint("IN100CLI")
         ExecBlock("IN100CLI",.F.,.F.,"EXCNB")
      EndIf
      
      RETURN
      
   ENDIF
ENDIF

IF Int_NB->NNBTIPO = INCLUSAO
   IN100RecLock('SYD')
   SYD->YD_FILIAL   :=cFilSYD
   SYD->YD_TEC      :=Int_NB->NNBNCM
   SYD->YD_EX_NCM   :=Int_NB->NNBQUALNCM
ENDIF

IF(!EMPTY(Int_NB->NNBNALADI)  ,SYD->YD_NALADI   :=Int_NB->NNBNALADI,)
IF(!EMPTY(Int_NB->NNBNAL_SH)  ,SYD->YD_NAL_SH   :=Int_NB->NNBNAL_SH,)
IF(VAL(Int_NB->NNBALADI)#0    ,SYD->YD_ALADI    :=Int_NB->NNBALADI,)
IF(!EMPTY(Int_NB->NNBDESC_P)  ,SYD->YD_DESC_P   :=Int_NB->NNBDESC_P,)
IF(VAL(Int_NB->NNBPER_II)#0   ,SYD->YD_PER_II   :=VAL(Int_NB->NNBPER_II),)
IF(VAL(Int_NB->NNBPER_IPI)#0  ,SYD->YD_PER_IPI  :=VAL(Int_NB->NNBPER_IPI),)
IF(VAL(Int_NB->NNBICMS_RED)#0 ,SYD->YD_ICMS_RE  :=VAL(Int_NB->NNBICMS_RE),)
IF(!EMPTY(LEFT(Int_NB->NNBUNID,nTamUM)) ,SYD->YD_UNID :=LEFT(Int_NB->NNBUNID,nTamUM),)
IF(!EMPTY(Int_NB->NNBDL_NALAD),SYD->YD_DL_NALA  :=Int_NB->NNBDL_NALA,)
IF(!EMPTY(Int_NB->NNBDL_GATT) ,SYD->YD_DL_GATT  :=Int_NB->NNBDL_GATT,)
IF(!EMPTY(Int_NB->NNBDESTAQU) ,SYD->YD_DESTAQU  :=Int_NB->NNBDESTAQU,)

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"GRVNB")
EndIf

SYD->(MSUNLOCK())
RETURN .T.

*---------------------------------------------------------------------------
FUNCTION IN100Taxas(TB_Cols)
*---------------------------------------------------------------------------
AADD(TB_Cols,{{||IN100CTD(Int_TC->NTCDATA)}               ,"",STR0239}) //"Data Cotação"
AADD(TB_Cols,{{||Int_TC->NTCMOEDA}                        ,"",STR0240}) //"Moeda"
AADD(TB_Cols,{{||TRANSFORM(VAL(Int_TC->NTCVLCON_C),cPictTaxa)},"",STR0241}) //"Taxa de Conversão"
AADD(TB_Cols,{{||TRANSFORM(VAL(Int_TC->NTCVLFISCA), cPictTaxa)},"",STR0242}) //"Taxa Fiscal (D.I.)"
AADD(TB_Cols,{{||TRANSFORM(VAL(Int_TC->NTCVLCOMPR), cPictTaxa)},"",STR0736}) //"Taxa de Compra" //ASR 13/12/2005

ASIZE(TBRCols,0)
AADD(TBRCols,{{||IN100Status()}                   ,STR0036}) //"Status"
AADD(TBRCols,{{||IN100TIPO() }                    ,STR0037}) //"Tipo"
AADD(TBRCols,{{||IN100CTD(EVAL(bDtInteg))}        ,STR0071}) //"Dt Integ"
AADD(TBRCols,{{||IN100CTD(Int_TC->NTCDATA)}               ,STR0239}) //"Data Cotação"
AADD(TBRCols,{{||Int_TC->NTCMOEDA}                        ,STR0240}) //"Moeda"
AADD(TBRCols,{{||TRANSFORM(VAL(Int_TC->NTCVLCON_C),cPictTaxa)},STR0241}) //"Taxa de Conversão"
AADD(TBRCols,{{||TRANSFORM(VAL(Int_TC->NTCVLFISCA), cPictTaxa)},STR0242}) //"Taxa Fiscal (D.I.)"
AADD(TBRCols,{{||TRANSFORM(VAL(Int_TC->NTCVLCOMPR), cPictTaxa)},STR0736}) //"Taxa de Compra" //ASR 13/12/2005

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"COLTC")
ENDIF
AADD(TBRCols,{{||IN100E_MSG(.T.)}                 ,STR0112}) //"Mensagem"
AADD(TB_Cols,{{||IN100E_Msg(.T.)}                 ,"",STR0112}) // "Mensagem"

RETURN .T.

*---------------------------------------------------------------------------------------------------*
FUNCTION IN100LerTC()
*---------------------------------------------------------------------------------------------------*
IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"LERTC")
ENDIF

IF ! IN100CTD(Int_TC->NTCDATA,.T.)
   EVAL(bmsg,STR0243) //"DATA DA COTACAO INVALIDA"
ENDIF

IF EMPTY(Int_TC->NTCMOEDA)
   EVAL(bmsg,STR0240+STR0546) //"MOEDA NAOINFORMADO

ELSEIF ! SYF->(DBSEEK(cFilSYF+Int_TC->NTCMOEDA))
       EVAL(bmsg,STR0240+STR0544) //"MOEDA SEMCADASTRO
ENDIF

IF ! SYE->(DBSEEK(cFilSYE+DTOS(IN100CTD(Int_TC->NTCDATA))+Int_TC->NTCMOEDA))
   IF Int_TC->NTCTIPO = EXCLUSAO  //# INCLUSAO
      EVAL(bmsg,STR0561+STR0544)  // CODIGO_TC SEMCADASTRO
   ENDIF

   IF Int_TC->NTCTIPO = ALTERACAO
      cAlias := Alias()
      Reclock( "Int_TC", .F. )
      DbSelectArea( cAlias )

      Int_TC->NTCTIPO := INCLUSAO

      Int_TC->( MsUnlock() )
   ENDIF

ELSEIF Int_TC->NTCTIPO = INCLUSAO
       EVAL(bmsg,STR0561+STR0545)  // CODIGO_TC COMCADASTRO
ENDIF

IF Int_TC->NTCTIPO == EXCLUSAO
   IF EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"VALTC")
   ENDIF
   IN100VerErro(cErro,cAviso)
   IF Int_TC->NTCINT_OK = "T"
      nResumoCer+=1
   ELSE
      nResumoErr+=1
   ENDIF
   RETURN
ENDIF
//--- ADC 09/02/2011 Acrescentados os ALIAS para as validações abaixo.
If Empty(Int_TC->NTCVLCON_C) .and. Empty(Int_TC->NTCVLFISCA) .and. Empty(Int_TC->NTCVLCOMPR)
   EVAL(bmsg,STR0245+STR0546) //"TAXAS DE CONVERSAO NAO INFORMADAS"
ElseIF IN100NaoNum(Int_TC->NTCVLCON_C) .and. IN100NaoNum(Int_TC->NTCVLFISCA) .and. IN100NaoNum(Int_TC->NTCVLCOMPR) .AND. SYE->(EOF())
   If !Empty(Int_TC->NTCVLCON_C) .and. IN100NaoNum(Int_TC->NTCVLCON_C)
      EVAL(bmsg,STR0737+STR0549) //"TAXA DE VENDA INVALIDO
   EndIf
   If !Empty(Int_TC->NTCVLFISCA) .and. IN100NaoNum(Int_TC->NTCVLFISCA)
      EVAL(bmsg,STR0242+STR0549) //"TAXA FISCAL INVALIDO
   EndIf
   If !Empty(Int_TC->NTCVLCOMPR) .and. IN100NaoNum(Int_TC->NTCVLCOMPR)
      EVAL(bmsg,STR0736+STR0549) //"TAXA DE COMPRA INVALIDO
   EndIf
ENDIF
//
IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"VALTC")
ENDIF
IN100VerErro(cErro,cAviso)

IF Int_TC->NTCINT_OK = "T"
   nResumoCer+=1
ELSE
   nResumoErr+=1
ENDIF
RETURN .T.

*--------------------*
FUNCTION IN100GrvTC()
*--------------------*
Static lAbre
Private lSairTC := .F. // JBS - 04/03/2004

If(EasyEntryPoint("IN100CLI"),ExecBlock("IN100CLI",.F.,.F.,"ANTES_GRAVA_TC"),) // JBS - 04/03/2004

If lSairTC  // JBS - 04/03/2004
   Return
EndIf   

IF Int_TC->NTCTIPO # INCLUSAO

   SYE->(DBSEEK(cFilSYE+DTOS(IN100CTD(Int_TC->NTCDATA))+Int_TC->NTCMOEDA))
   IF SYE->(EOF()) .AND. Int_TC->NTCTIPO = ALTERACAO
      EVAL(bmsg,STR0245+STR0544+STR0141) //"TAXAS DE CONVERSAO"### SEMCADASTRO  P/ ALTERACAO"
      RETURN
   ENDIF
   cAlias:=ALIAS()
   Reclock("SYE",.F.)
   DBSELECTAREA(cAlias)

   IF Int_TC->NTCTIPO = EXCLUSAO
      SYE->(DBDELETE())
      SYE->(DBCOMMIT())
      SYE->(MSUNLOCK())

      If EasyEntryPoint("IN100CLI")
         ExecBlock("IN100CLI",.F.,.F.,"EXCTC")
      EndIf
      
      RETURN
      
   ENDIF
ENDIF

IF Int_TC->NTCTIPO = INCLUSAO
   IN100RecLock('SYE')
   SYE->YE_FILIAL  :=cFilSYE
   SYE->YE_DATA    :=IN100CTD(Int_TC->NTCDATA)
   SYE->YE_MOEDA   :=Int_TC->NTCMOEDA
ENDIF
IF(VAL(Int_TC->NTCVLCON_C)#0,SYE->YE_VLCON_C :=VAL(Int_TC->NTCVLCON_C),)
IF(VAL(Int_TC->NTCVLFISCA)#0 ,SYE->YE_VLFISCA :=VAL(Int_TC->NTCVLFISCA),)
   IF(VAL(Int_TC->NTCVLCOMPR)#0 ,SYE->YE_TX_COMP :=VAL(Int_TC->NTCVLCOMPR),)

IF EasyGParam("MV_ATUTX")
   cAlias := Alias()
   IF lAbre = NIL
      IF !ChkFile("ECB",.F.)
          IN_MSG(STR0054,STR0055) // Não foi possível abrir o Arquivo ECB"###"Informação"
          lAbre:=.F.
      Else
          lAbre:=.T.    
      ENDIF
   ENDIF
   IF lAbre .AND. !ECB->(DBSEEK(cFilECB+DTOS(SYE->YE_DATA)+SYE->YE_MOEDA))
      ECB->(RECLOCK("ECB",.T.))
      ECB->ECB_FILIAL := cFilECB
      ECB->ECB_DATA   := SYE->YE_DATA
      ECB->ECB_MOEDA  := SYE->YE_MOEDA
      ECB->ECB_TX_CTB := SYE->YE_VLCON_C
      ECB->ECB_TX_EXP := SYE->YE_TX_COMP
      ECB->(MSUNLOCK())
      ECB->(DbCloseArea())
    ENDIF
    SELECT(cAlias)
ENDIF

IF EasyEntryPoint("IC086IN1")
   ExecBlock("IC086IN1",.F.,.F., 1)
ENDIF
If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"GRVTC")
EndIf

SYE->(MSUNLOCK())
RETURN .T.

*-----------------------------------------------------------------------------
FUNCTION IN100Cadastra(Qual,Codigo,Campo1,Campo2,Campo3,aGrvCpos)
*-----------------------------------------------------------------------------
LOCAL cNewmsg:=ALLTRIM(EVAL(bMessage)), cAliasCad:=ALIAS(), i:=0
DEFAULT aGrvCpos := {}
Private cQual := Qual // SVG - 06/05/2011 - Para a utilização em rdmake.
cNewmsg+=IF(MLCOUNT(cNewmsg,LEN_MSG) > 0,NewLine+STR0246,STR0246) //'INCLUSAO DO(A) '###'INCLUSAO DO(A) '

DO CASE
   CASE Qual = CAD_NB
        IN100RecLock('SYD')
        SYD->YD_FILIAL := cFilSYD
        SYD->YD_TEC    :=Codigo
        SYD->YD_EX_NCM :=Campo1
        SYD->YD_EX_NBM :=SPACE(LEN(SYD->YD_EX_NBM))
        SYD->YD_DESC_P :=LEFT(ASTERISCOS,LEN(SYD->YD_DESC_P)-2)+cFuncao
        SYD->(MSUNLOCK())
        cNewmsg+=STR0559  // CODIGO_NBM    
   CASE Qual = CAD_FP
        IN100RecLock('SYC')
        SYC->YC_FILIAL := cFilSYC
        SYC->YC_COD    :=Codigo
        SYC->YC_NOME   :=Campo1
        SYC->(MSUNLOCK())
        cNewMsg+=STR0560  // CODIGO_FAM    
   CASE Qual = CAD_BC
        IN100RecLock('SA6')
        SA6->A6_FILIAL  := cFilSA6
        SA6->A6_COD     :=Codigo
        SA6->A6_AGENCIA :=Campo1
        SA6->A6_NOME    :=LEFT(ASTERISCOS,LEN(SA6->A6_NOME)-2)+cFuncao
        SA6->(MSUNLOCK())
        cNewMsg+=STR0247 //'BANCO/AGENCIA'
   CASE Qual = CAD_LI
        IN100RecLock('SA5')
        SA5->A5_FILIAL   := cFilSA5
        SA5->A5_PRODUTO  := Codigo
        SA5->A5_FABR     := Campo1
        SA5->A5_FORNECE  := Campo2
        if Campo3 # Nil
           SA5->A5_UNID  := Campo3
        EndIf
        SA5->A5_LOJA     := '.'
        SA5->A5_FALOJA   := '.'
        SA5->(MSUNLOCK())
        cNewMsg+=STR0558  // LIGACAO_ITFB  
   CASE Qual = CAD_CC
        IN100RecLock('SY3')
        SY3->Y3_FILIAL := cFilSY3
        SY3->Y3_COD  := Codigo
        SY3->Y3_DESC := LEFT(ASTERISCOS,LEN(SY3->Y3_DESC)-2)+cFuncao
        SY3->Y3_LE   := Campo1
        SY3->(MSUNLOCK())
        cNewMsg+=STR0550 // CENTRO_CUSTO
   CASE Qual = CAD_CI
        IN100RecLock('SB1')
		IF LEN(aGrvCpos) = 0
           SB1->B1_COD    :=Codigo
           SB1->B1_FILIAL :=cFilSB1
           SB1->B1_UM     :=ASTERISCOS
           SB1->B1_PESO   :=1
           IF cFuncao == CAD_PO
              SB1->B1_ANUENTE := IF(Int_IP->NIPFLUXO="1","1","2")
           ELSE
              SB1->B1_ANUENTE := '2'
           ENDIF
           nNumMsmm+=1
           MSMM(IF(lMsmm,STRZERO(nNumMsmm,6),),nSB1_P,,('***'+cFuncao),1,,,"SB1","B1_DESC_P")
           nNumMsmm+=1
           MSMM(IF(lMsmm,STRZERO(nNumMsmm,6),),nSB1_I,,('***'+cFuncao),1,,,"SB1","B1_DESC_I")
           nNumMsmm+=1
           MSMM(IF(lMsmm,STRZERO(nNumMsmm,6),),nSB1_GI,,('***'+cFuncao),1,,,"SB1","B1_DESC_GI")
        ELSE      
           SX3->(dbSetOrder(2))
           FOR i:=1 TO LEN(aGrvCpos)
               IF SX3->(dbSeek(aGrvCpos[i,1])) .AND. SX3->X3_TIPO == "M"
                  MSMM(IF(lMsmm,STRZERO(nNumMsmm,6),),TAMSX3(aGrvCpos[i,1])[1],,aGrvCpos[i,2],1,,,"SB1",aGrvCpos[i,3])
               ELSE
                  SB1->(Fieldput(FieldPos(aGrvCpos[i,1]), aGrvCpos[i,2]))           
               ENDIF
           NEXT                
           SX3->(dbSetOrder(1))
        ENDIF
        SB1->(MSUNLOCK())
        cNewMsg+=STR0556  // CODIGO_ITEM   
   CASE Qual = CAD_LE
        IN100RecLock('SY2')
        SY2->Y2_FILIAL := cFilSY2
        SY2->Y2_SIGLA:=Codigo
        SY2->Y2_DESC :=LEFT(ASTERISCOS,LEN(SY2->Y2_DESC)-2)+cFuncao
        SY2->Y2_END  :=LEFT(ASTERISCOS,LEN(SY2->Y2_END)-2)+cFuncao
        SY2->(MSUNLOCK())
        cNewMsg+=STR0554  // LOCAL_ENTREGA 
   CASE Qual = CAD_CO
        IN100RecLock('SY1')
        SY1->Y1_FILIAL := cFilSY1
        SY1->Y1_COD :=Codigo
        SY1->Y1_NOME:=LEFT(ASTERISCOS,LEN(SY1->Y1_NOME)-2)+cFuncao
        SY1->(MSUNLOCK())
        cNewMsg+=STR0555  // COMPRADOR    
   CASE Qual = CAD_AG
        IN100RecLock('SY4')
        SY4->Y4_COD    :=Codigo
        SY4->Y4_FILIAL := cFilSY4
        SY4->Y4_NOME   :=LEFT(ASTERISCOS,LEN(SY4->Y4_NOME)-2)+cFuncao
        SY4->Y4_END    :=LEFT(ASTERISCOS,LEN(SY4->Y4_END)-2)+cFuncao
        SY4->(MSUNLOCK())
        cNewMsg+=STR0248 //'AGENTE EMBARCADOR'
   CASE Qual = CAD_IM
        IN100RecLock('SYT')
        SYT->YT_COD_IMP := Codigo
        SYT->YT_FILIAL  := cFilSYT
        SYT->YT_NOME    := LEFT(ASTERISCOS,LEN(SYT->YT_NOME)-2)+cFuncao
        SYT->YT_ENDE    := LEFT(ASTERISCOS,LEN(SYT->YT_ENDE)-2)+cFuncao
        SYT->YT_CEP     := LEFT(ASTERISCOS,LEN(SYT->YT_CEP)-2)+cFuncao
        SYT->YT_CGC     := LEFT(ASTERISCOS,LEN(SYT->YT_CGC)-2)+cFuncao
        SYT->YT_REG     := LEFT(ASTERISCOS,LEN(SYT->YT_REG)-2)+cFuncao
        SYT->YT_TEL_IMP := LEFT(ASTERISCOS,LEN(SYT->YT_TEL_IMP)-2)+cFuncao
        SYT->YT_FAX_IMP := LEFT(ASTERISCOS,LEN(SYT->YT_FAX_IMP)-2)+cFuncao
        SYT->YT_CIDADE  := LEFT(ASTERISCOS,LEN(SYT->YT_CIDADE)-2)+cFuncao
        SYT->YT_ESTADO  := LEFT(ASTERISCOS,LEN(Alltrim(SYT->YT_ESTADO))-nLenEst)+cFuncao //SO.:0032 SO.:0298/02 FCD
        SYT->YT_PAIS    := LEFT(ASTERISCOS,LEN(SYT->YT_PAIS)-2)+cFuncao
        SYT->YT_IMP_CON := Campo1
        SYT->(MSUNLOCK())
        cNewMsg+=STR0249 //'IMPORTADOR/CONSIGNATARIO'
   CASE Qual = CAD_FB
        IN100RecLock('SA2')
        IF LEN(aGrvCpos) = 0
           SA2->A2_COD     :=Codigo
           SA2->A2_FILIAL  := cFilSA2
           SA2->A2_LOJA    :='.'
           SA2->A2_NOME    :=LEFT(ASTERISCOS,LEN(SA2->A2_NOME)-2)+cFuncao
           SA2->A2_NREDUZ  :=LEFT(ASTERISCOS,LEN(SA2->A2_NREDUZ)-2)+cFuncao
           SA2->A2_END     :=LEFT(ASTERISCOS,LEN(SA2->A2_END)-2)+cFuncao
           SA2->A2_ID_FBFN :=If(!SX5->(DBSEEK(cFilSX5+"48"+Campo1)),Campo1,X5DESCRI())
           SA2->A2_STATUS  := '1'
        ELSE
           FOR i:=1 TO LEN(aGrvCpos)
               SA2->(Fieldput(FieldPos(aGrvCpos[i,1]), aGrvCpos[i,2]))
           NEXT
        ENDIF
        
        SA2->(MSUNLOCK())
        cNewMsg+=IF(Campo1='1',STR0250,IF(Campo1='2',STR0251,STR0252)) //'FABRICANTE'###'FORNECEDOR'###'FABR/FORN '

ENDCASE
// SVG - 06/05/2011 -
If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"IN100CADASTRA")
EndIf


EVAL(bMessage,cNewmsg)
DBSELECTAREA(cAliasCad)
RETURN

*--------------------*
Function VerNumMsmm()
*--------------------*
LOCAL nRetorno:=0, cFil:=cFilSYP
IF lMsmm
   SYP->(DBSEEK(cFilSYP+'z',.T.))
   SYP->(DBSKIP(-1))
   IF cFil = SYP->YP_FILIAL
      nRetorno:=VAL(SYP->YP_CHAVE)
   ENDIF
ENDIF
RETURN nRetorno

*---------------------*
FUNCTION IN100RESUMO()
*---------------------*
LOCAL cResumo1, cResumo2, cBranco:='', cResumo3, cQuem, cResumo4, cResumo5, cResumo6, nAux:=0
PRIVATE oDlgResumo

cResumo1:=STR0253+STRZERO(nResumoCer,6) //'Aceitos........: '
cResumo2:=STR0254+STRZERO(nResumoErr,6) //'Rejeitados...: '
cResumo4:=STR0255+DTOC(nResumoData) //'Data Int.......: '
cResumo5:=STR0256+nResumoInic //'Hora Inicial..: '
cResumo6:=STR0257+nResumoFim //'Hora Final....: '
cResumo3:=''

nAux:=IF(EMPTY(ALLTRIM(cTit2Principal)),0.9,0.4)

If nResumoAlt#0 .AND. cFuncao $ (CAD_SI+'/'+CAD_PO+'/'+CAD_IT)  // SI , PO e IT (Exportacao)
   cQuem := If(cFuncao=CAD_SI,STR0258,IF(cFuncao=CAD_PO,STR0259,IF(cFuncao=CAD_IT,STR0042,'')))
   cResumo3:=STR0260+ALLTRIM(STR(nResumoAlt,6)+' '+cQuem+IF(cFuncao=CAD_IT,STR0043,STR0261)+Lower(STR0092)+".") //'Existe(m) '###' de alteracao com (IDIOMA OU item) rejeitado.'
   cResumo3:=SPAC(56-LEN(ALLTRIM(cResumo3)))+ALLTRIM(cResumo3)
Elseif !Empty(nResumoArq)
   If STR0262 $ nResumoArq //"vide "
      cResumo3:=SPAC(54-LEN(ALLTRIM(nResumoArq)))+ALLTRIM(nResumoArq)
   Else
      cResumo3:=SPAC(47-LEN(ALLTRIM(nResumoArq)))+ALLTRIM(nResumoArq)
   EndIf
EndIf

If Empty(cMemo)//ASR 18/11/2005
   DEFINE MSDIALOG oDlgResumo TITLE STR0263 From 9,25 To 25,60 OF GetWndDefault() //"Resumo"
Else
   DEFINE MSDIALOG oDlgResumo TITLE STR0263 From 9,25 To 27,60 OF GetWndDefault() //ASR 18/11/2005 - "Resumo"
EndIf
@ nAux,0.5 SAY cTit1Principal OF oDlgResumo
If ! EMPTY(ALLTRIM(cTit2Principal))
   @ 1.1,0.5 SAY cTit2Principal OF oDlgResumo
EndIf
@ 2.2,5.2 SAY cResumo4 OF oDlgResumo
@ 3.0,5.2 SAY cResumo5 OF oDlgResumo
@ 3.8,5.2 SAY cResumo6 OF oDlgResumo
@ 4.6,5.2 SAY cResumo1 OF oDlgResumo
@ 5.4,5.2 SAY cResumo2 OF oDlgResumo
@ 6.4,0.5 SAY cResumo3 OF oDlgResumo

If Empty(cMemo)//ASR 18/11/2005
   @ 97,050 BUTTON STR0110 SIZE 34,11 FONT oDlgResumo:oFont ACTION(oDlgResumo:End()) OF oDlgResumo PIXEL //"&Retorna"
Else
   //TRP-05/11/12
   If AvFlags("AVINT_FINANCEIRO_EIC") 
      @ 117,050 BUTTON STR0110 SIZE 34,11 FONT oDlgResumo:oFont ACTION(AvLogView(aMemo,"Atenção"),oDlgResumo:End()) OF oDlgResumo PIXEL //ASR 18/11/2005 - "&Retorna"
   Else
      @ 87 ,2 GET cMemo MEMO HSCROLL SIZE 134,24 OF oDlgResumo PIXEL	//ASR 18/11/2005
      @ 117,050 BUTTON STR0110 SIZE 34,11 FONT oDlgResumo:oFont ACTION(oDlgResumo:End()) OF oDlgResumo PIXEL //ASR 18/11/2005 - "&Retorna"
   Endif
EndIf

ACTIVATE MSDIALOG oDlgResumo CENTERED

cMemo := ""//ASR 18/11/2005

RETURN NIL

*--------------------*
FUNCTION IN100FOCUS()
*--------------------*
oMark:oBrowse:Default()
oMark:oBrowse:Refresh()
//oMark:oBrowse:Reset()
SetFocus(oMark:oBrowse:hWnd)
oMark:oBrowse:Refresh()
RETURN .T.

*---------------------*
FUNCTION IN100ValTipo()
*---------------------*
Do Case
   Case cTipoBrow == STR0019 //"Geral"
        lGeral    := .T.
        cParamInic:= CHR(0)
        cParamFim := CHR(255)
        cValid    := ".T."
        nOrem     := 1
   Case cTipoBrow == STR0032 //"Aceitos"
        lGeral    := .F.
        cParamInic:= "T"
        cParamFim := "T"
        cValid    := cValOk
        nOrem     := 2
   Case cTipoBrow == STR0033 //"Rejeitados"
        lGeral    := .F.
        cParamInic:= "F"
        cParamFim := "F"
        cValid    := cValRej
        nOrem     := 2
EndCase
cBrowAux:=cTipoBrow

If cFuncao = CAD_DE  //Envio ao Despachante
   Int_DspHe->(DBSETORDER(nOrem))
Else
   ('Int_'+cFuncao)->(DBSETORDER(nOrem))
EndIf
IN100FOCUS()
oMark:oBrowse:GOTOP()

RETURN .T.

*--------------------------*
Function IN100Filtro(lTipo)
*--------------------------*
If lTipo
   Return cParamInic
Else
   Return cParamFim
EndIf

*-------------------------------*
Function IN100GRVRESUMO()
*-------------------------------*
LOCAL nIR:=0,cAux:='',cAux2:='',nVez:=0, nTamMemo, i
LOCAL cLinha:=cLinha1:=cLinha2:=cLinha3:=cLinha4:=cLinha5:=cLinha6:=cLinha7:=''
aArqMemo:={}

//If cModulo="EEC"
//   AADD(aArqMemo,'INT_FF'); AADD(aArqMemo,'INT_CL'); AADD(aArqMemo,'INT_LK')
//   AADD(aArqMemo,'INT_TC'); AADD(aArqMemo,'INT_IT'); AADD(aArqMemo,'INT_PE')
//Else
//   AADD(aArqMemo,'INT_FP'); AADD(aArqMemo,'INT_CC'); AADD(aArqMemo,'INT_CI')
//   AADD(aArqMemo,'INT_FB'); AADD(aArqMemo,'INT_LI'); AADD(aArqMemo,'INT_NB')
//   AADD(aArqMemo,'INT_TC'); AADD(aArqMemo,'INT_SI'); AADD(aArqMemo,'INT_PO')
//   AADD(aArqMemo,'INT_DE'); AADD(aArqMemo,'INT_DI')
//EndIf

For I:=1 To LEN(aOpcoes)
    If aOpcoes[I,3] # 'RE'
       AADD(aArqMemo,'INT_'+aOpcoes[I,3])
    EndIf
Next

mMemoResumo:=''
nTamMemo:=LEN(aArqMemo)+IF((LEN(aArqMemo)-INT(LEN(aArqMemo)))>0,1,0)

For nIR:=1 TO nTamMemo STEP 2

    If nIR <= LEN(aArqMemo)
       cAux :=STR0021+STUFF(ALLTRIM(aOpcoes[nIR,1]),AT("&",ALLTRIM(aOpcoes[nIR,1])),1,"") //"Integracao de "
       If (nIR+1) <= LEN(aArqMemo)
          cAux2:=STR0021+STUFF(ALLTRIM(aOpcoes[nIR+1,1]),AT("&",ALLTRIM(aOpcoes[nIR+1,1])),1,"") //"Integracao de "
       Else
          cAux2:=""
       EndIf
    Else
       cAux :=cAux2:=""
    EndIf
    cLinha:=SPAC(INT((36-LEN(ALLTRIM(MEMOLINE(cAux,25,1))))/2))+ALLTRIM(UPPER(MEMOLINE(cAux,25,1)))
    cLinha+=SPAC(38-LEN(cLinha))+"|"
    cLinha+=SPAC(INT((36-LEN(ALLTRIM(MEMOLINE(cAux2,25,1))))/2))+ALLTRIM(UPPER(MEMOLINE(cAux2,25,1)))
    mMemoResumo+=cLinha+NewLine

    cLinha:=SPAC(INT((36-LEN(ALLTRIM(MEMOLINE(cAux,25,2))))/2))+ALLTRIM(UPPER(MEMOLINE(cAux,25,2)))
    cLinha+=SPAC(38-LEN(cLinha))+"|"
    cLinha+=SPAC(INT((36-LEN(ALLTRIM(MEMOLINE(cAux2,25,2))))/2))+ALLTRIM(UPPER(MEMOLINE(cAux2,25,2)))
    mMemoResumo+=cLinha+NewLine

    mMemoResumo+=SPAC(38)+"|"+NewLine

    cLinha:=cLinha1:=cLinha2:=cLinha3:=cLinha4:=cLinha5:=cLinha6:=cLinha7:=''

    For nVez:=0 to 1
        nResumoCer := nResumoErr := nResumoAlt := 0
        nResumoInic:= nResumoFim := nResumoArq := ''
        nResumoData:= AVCTOD('  /  /  ')
        If (nIR+nVez) <= LEN(aArqMemo)
           If aArqMemo[nIR+nVez] # 'NADA'
              If FILE( aArqMemo[nIR+nVez]+'.INT')
                 restore from ( aArqMemo[nIR+nVez]+'.INT') additive
                 cLinha +=IF(nVez=0,SPAC(4),SPAC(38-LEN(cLinha ))+"|"+SPAC(4))+STR0264+DTOC(nResumoData) //'Data Integracao.: '
                 cLinha1+=IF(nVez=0,SPAC(4),SPAC(38-LEN(cLinha1))+"|"+SPAC(4))+STR0265+nResumoInic //'Hora Inicial....: '
                 cLinha2+=IF(nVez=0,SPAC(4),SPAC(38-LEN(cLinha2))+"|"+SPAC(4))+STR0266+nResumoFim //'Hora Final......: '
                 cLinha3+=IF(nVez=0,SPAC(4),SPAC(38-LEN(cLinha3))+"|"+SPAC(4))+STR0267+STRZERO(nResumoCer,6) //'Aceitos.........: '
                 cLinha4+=IF(nVez=0,SPAC(4),SPAC(38-LEN(cLinha4))+"|"+SPAC(4))+STR0268+STRZERO(nResumoErr,6) //'Rejeitados......: '
                 cLinha5+=IF(nVez=0,SPAC(38),"|")
                 If nResumoAlt#0 .AND. If(cModulo="EEC",(nIR=5 .OR. nIR=6),(nIR=7 .OR. nIR=8)) // SI e PO e PE
                    cLinha6+=IF(nVez=0,SPAC(4),SPAC(38-LEN(cLinha6))+"|"+SPAC(4))+STR0260+ALLTRIM(STR(nResumoAlt,6)+' '+If(nIR=7,STR0258,STR0259)+STR0269) //'Existe(m) '###'SI(s)'###'PO(s)'###' de'
                    cLinha7+=IF(nVez=0,SPAC(4),SPAC(38-LEN(cLinha7))+"|"+SPAC(4))+STR0270 //'alteracao com item rejeitado.'
                 Elseif ! EMPTY(nResumoArq)
                    cLinha6+=IF(nVez=0,SPAC(4),SPAC(38-LEN(cLinha6))+"|"+SPAC(4))+MEMOLINE(nResumoArq,32,1)
                    cLinha7+=IF(nVez=0,SPAC(4),SPAC(38-LEN(cLinha7))+"|"+SPAC(4))+MEMOLINE(nResumoArq,32,2)
                 Else
                    cLinha6+=IF(nVez=0,SPAC(38),SPAC(38-LEN(cLinha6))+"|")
                    cLinha7+=IF(nVez=0,SPAC(38),SPAC(38-LEN(cLinha7))+"|")
                 EndIf
              Else
                 cLinha +=IF(nVez=0,SPAC(38),SPAC(38-LEN(cLinha ))+"|")
                 cLinha1+=IF(nVez=0,SPAC(38),SPAC(38-LEN(cLinha1))+"|")
                 cLinha2+=IF(nVez=0,SPAC(4),SPAC(38-LEN(cLinha2))+"|"+SPAC(4))+'Nao existe integracao.'
                 cLinha3+=IF(nVez=0,SPAC(38),SPAC(38-LEN(cLinha3))+"|")
                 cLinha4+=IF(nVez=0,SPAC(38),SPAC(38-LEN(cLinha4))+"|")
                 cLinha5+=IF(nVez=0,SPAC(38),SPAC(38-LEN(cLinha5))+"|")
                 cLinha6+=IF(nVez=0,SPAC(38),SPAC(38-LEN(cLinha6))+"|")
                 cLinha7+=IF(nVez=0,SPAC(38),SPAC(38-LEN(cLinha7))+"|")
              EndIf
           Else
              cLinha +=IF(nVez=0,SPAC(38),SPAC(38-LEN(cLinha ))+"|")
              cLinha1+=IF(nVez=0,SPAC(38),SPAC(38-LEN(cLinha1))+"|")
              cLinha2+=IF(nVez=0,SPAC(4),SPAC(38-LEN(cLinha2))+"|"+SPAC(4))+STR0271 //'Nao existe integracao.'
              cLinha3+=IF(nVez=0,SPAC(38),SPAC(38-LEN(cLinha3))+"|")
              cLinha4+=IF(nVez=0,SPAC(38),SPAC(38-LEN(cLinha4))+"|")
              cLinha5+=IF(nVez=0,SPAC(38),SPAC(38-LEN(cLinha5))+"|")
              cLinha6+=IF(nVez=0,SPAC(38),SPAC(38-LEN(cLinha6))+"|")
              cLinha7+=IF(nVez=0,SPAC(38),SPAC(38-LEN(cLinha7))+"|")
           EndIf
        Else
           cLinha +=IF(nVez=0,SPAC(38),SPAC(38-LEN(cLinha ))+"|")
           cLinha1+=IF(nVez=0,SPAC(38),SPAC(38-LEN(cLinha1))+"|")
           cLinha2+=IF(nVez=0,SPAC(38),SPAC(38-LEN(cLinha2))+"|")
           cLinha3+=IF(nVez=0,SPAC(38),SPAC(38-LEN(cLinha3))+"|")
           cLinha4+=IF(nVez=0,SPAC(38),SPAC(38-LEN(cLinha4))+"|")
           cLinha5+=IF(nVez=0,SPAC(38),SPAC(38-LEN(cLinha5))+"|")
           cLinha6+=IF(nVez=0,SPAC(38),SPAC(38-LEN(cLinha6))+"|")
           cLinha7+=IF(nVez=0,SPAC(38),SPAC(38-LEN(cLinha7))+"|")
        EndIf
    Next
    mMemoResumo+=cLinha+NewLine
    mMemoResumo+=cLinha1+NewLine
    mMemoResumo+=cLinha2+NewLine
    mMemoResumo+=cLinha3+NewLine
    mMemoResumo+=cLinha4+NewLine
    mMemoResumo+=cLinha5+NewLine
    mMemoResumo+=cLinha6+NewLine
    mMemoResumo+=cLinha7+NewLine
    mMemoResumo+=REPL("-",38)+IF(nIR=LEN(aArqMemo) .OR. (nIR+1)=LEN(aArqMemo),"-","|")+REPL("-",36)+NewLine
    If (nIR+1) < LEN(aArqMemo)
       mMemoResumo+=SPAC(38)+"|"+NewLine
    EndIf
Next

Return .T.

*--------------------*
FUNCTION IN100Param()
*--------------------*
local nVolta, oActive, cAlias:=ALIAS()
LOCAL TULT_SP, TULT_CI, TULT_FB, TULT_LI, TULT_NB, TULT_FP, TULT_TC, TARQ_H, TULT_DI
LOCAL TARQ_I,  TARQ_CI, TARQ_FB, TARQ_LI, TARQ_NB, TARQ_TC, TARQ_FP, TARQ_DI
LOCAL TINC_CI, TINC_FA, TINC_FO, TINC_LI, TINC_CO, TINC_LE,  TINC_CC
LOCAL TINC_AG, TINC_FW, TINC_IMP, TINC_CON, TINC_NBM, TINC_FAM, TINC_BAN, TINC_UNI
LOCAL TULT_DE, TARQ_DE, TARQ_TMP
LOCAL nCol1, nCol2, nCol3, nCol4, nCol5
PRIVATE nLin
PRIVATE oDlg5, oGet
// SVG - 16/05/2011 - Para customização na tela de parametros.
Private aTela:={ STR0275,;
                 STR0276,;
                 STR0224,;
                 STR0277,;
                 STR0140,;
                 STR0278,;
                 STR0279,;
                 STR0280,;
                 STR0281,;
                 STR0282,;
                 cTitNFE,;
                 STR0672}
TULT_SP :=Int_Param->NPAULT_SP
TULT_CI :=Int_Param->NPAULT_CI
TULT_FB :=Int_Param->NPAULT_FB
TULT_LI :=Int_Param->NPAULT_LI
TULT_NB :=Int_Param->NPAULT_NB
TULT_FP :=Int_Param->NPAULT_FP
//TULT_TP :=Int_Param->NPAULT_TP
TULT_TC :=Int_Param->NPAULT_TC
TULT_DE :=Int_Param->NPAULT_DE
TULT_DI :=Int_Param->NPAULT_DI
TULT_CC :=Int_Param->NPAULT_CC
TULT_FE :=Int_Param->NPAULT_FE
TULT_NU :=Int_Param->NPAULT_NU
TARQ_H  :=Int_Param->NPAARQ_H
TARQ_I  :=Int_Param->NPAARQ_I
TARQ_CI :=Int_Param->NPAARQ_CI
TARQ_FB :=Int_Param->NPAARQ_FB
TARQ_LI :=Int_Param->NPAARQ_LI
TARQ_NB :=Int_Param->NPAARQ_NB
TARQ_TC :=Int_Param->NPAARQ_TC
TARQ_FP :=Int_Param->NPAARQ_FP
TARQ_TP :=Int_Param->NPAARQ_TP
TARQ_DE :=Int_Param->NPAARQ_DE
TARQ_DI :=Int_Param->NPAARQ_DI
TARQ_CC :=Int_Param->NPAARQ_CC
TARQ_FE :=Int_Param->NPAARQ_FE
TARQ_NU :=Int_Param->NPAARQ_NU
TARQ_TMP:=Int_Param->NPAARQ_TMP
TINC_CI :=Int_Param->NPAINC_CI
TINC_FA :=Int_Param->NPAINC_FA
TINC_FO :=Int_Param->NPAINC_FO
TINC_LI :=Int_Param->NPAINC_LI
TINC_CO :=Int_Param->NPAINC_CO
TINC_LE :=Int_Param->NPAINC_LE
TINC_CC :=Int_Param->NPAINC_CC
TINC_AG :=Int_Param->NPAINC_AG
TINC_UNI:=Int_Param->NPAINC_UNI
TINC_FW :=Int_Param->NPAINC_FW
TINC_IMP:=Int_Param->NPAINC_IMP
TINC_CON:=Int_Param->NPAINC_CON
TINC_NBM:=Int_Param->NPAINC_NBM
TINC_FAM:=Int_Param->NPAINC_FAM
TINC_BAN:=Int_Param->NPAINC_BAN

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"PARAMCARGA")
EndIf



DEFINE MSDIALOG oDlg5 FROM  40,   0 TO 387,626 TITLE STR0272 PIXEL OF GetWndDefault() //"Parâmetros da Integração"

nLin:=3
@ nLin, 080 SAY STR0273 SIZE 66,  7 OF oDlg5 PIXEL //"Ultimo Processamento"
@ nLin, 151 SAY STR0274 SIZE 84,  7 OF oDlg5 PIXEL //"Arquivos de Entrada (.TXT)"
// SVG - 16/05/2011 - Para customização na tela de parametros.
If aScan(aTela,{ |x| x == STR0275} ) > 0
   nLin+=12
   @ nLin, 006 SAY STR0275 SIZE 76,  7 OF oDlg5 PIXEL //"S.I. / P.O. - Capa/Detalhe"
   @ nLin, 096 MSGET oGet VAR TULT_SP SIZE 32, 10 OF oDlg5 PIXEL
   @ nLin, 151 MSGET oGet VAR TARQ_H  SIZE 47, 10 OF oDlg5 PIXEL
   @ nLin, 209 MSGET oGet VAR TARQ_I  SIZE 47, 10 OF oDlg5 PIXEL
EndIf
If aScan(aTela,{ |x| x == STR0276 }) > 0
   nLin+=10
   @ nLin, 006  SAY STR0276 SIZE 74,  7 OF oDlg5 PIXEL //"Itens"
   @ nLin, 096 MSGET oGet VAR TULT_CI SIZE 32, 10 OF oDlg5 PIXEL
   @ nLin, 151 MSGET oGet VAR TARQ_CI SIZE 47, 10 OF oDlg5 PIXEL
EndIf
If aScan(aTela,{ |x| x ==STR0224 }) > 0
   nLin+=12
   @ nLin, 006 SAY STR0224 SIZE 74,  7 OF oDlg5 PIXEL //"Fabricante/Fornecedor"
   @ nLin, 096 MSGET oGet VAR TULT_FB SIZE 32, 10 OF oDlg5 PIXEL
   @ nLin, 151 MSGET oGet VAR TARQ_FB SIZE 47, 10 OF oDlg5 PIXEL
EndIf
If aScan(aTela,{ |x| x == STR0277}) > 0
   nLin+=11
   @ nLin, 006 SAY STR0277 SIZE 74,  7 OF oDlg5 PIXEL //"Item/Fabr/Forn"
   @ nLin, 096 MSGET oGet VAR TULT_LI SIZE 32, 10 OF oDlg5 PIXEL
   @ nLin, 151 MSGET oGet VAR TARQ_LI SIZE 47, 10 OF oDlg5 PIXEL
EndIf
If aScan(aTela,{ |x| x == STR0140}) > 0
   nLin+=12
   @ nLin, 006 SAY STR0140 SIZE 74,  7 OF oDlg5 PIXEL //"NCM"
   @ nLin, 096 MSGET oGet VAR TULT_NB SIZE 32, 10 OF oDlg5 PIXEL
   @ nLin, 151 MSGET oGet VAR TARQ_NB SIZE 47, 10 OF oDlg5 PIXEL
EndIf
If aScan(aTela,{ |x| x == STR0278}) > 0
   nLin+=10
   @ nLin, 006 SAY STR0278 SIZE 74,  7 OF oDlg5 PIXEL //"Família de Produtos"
   @ nLin, 096 MSGET oGet VAR TULT_FP SIZE 32, 10 OF oDlg5 PIXEL
   @ nLin, 151 MSGET oGet VAR TARQ_FP SIZE 47, 10 OF oDlg5 PIXEL
EndIf
If aScan(aTela,{ |x| x == STR0279}) > 0
   nLin+=12
   @ nLin, 006 SAY STR0279 SIZE 74,  7 OF oDlg5 PIXEL //"Conversão de Moedas"
   @ nLin, 096 MSGET oGet VAR TULT_TC SIZE 32, 10 OF oDlg5 PIXEL
   @ nLin, 151 MSGET oGet VAR TARQ_TC SIZE 47, 10 OF oDlg5 PIXEL
EndIf
If aScan(aTela,{ |x| x == STR0280 }) > 0
   nLin+=11
   @ nLin, 006 SAY STR0280 SIZE 74,  7 OF oDlg5 PIXEL //"Despesas Despachante"
   @ nLin, 096 MSGET oGet VAR TULT_DE SIZE 32, 10 OF oDlg5 PIXEL
   @ nLin, 151 MSGET oGet VAR TARQ_DE SIZE 47, 10 OF oDlg5 PIXEL
EndIf
If aScan(aTela,{ |x| x ==  STR0281} ) > 0
   nLin+=11
   @ nLin,006 SAY STR0281 SIZE 74,  7 OF oDlg5 PIXEL //"Data de Recebimentos"
   @ nLin,096 MSGET oGet VAR TULT_DI SIZE 32, 10 OF oDlg5 PIXEL
   @ nLin,151 MSGET oGet VAR TARQ_DI SIZE 47, 10 OF oDlg5 PIXEL
EndIf
If aScan(aTela, { |x| x == STR0282} ) > 0
   nLin+=12
   @ nLin,006 SAY STR0282 SIZE 74,  7 OF oDlg5 PIXEL //"Unidade Requisitante"
   @ nLin,096 MSGET oGet VAR TULT_CC SIZE 32, 10 OF oDlg5 PIXEL
   @ nLin,151 MSGET oGet VAR TARQ_CC SIZE 47, 10 OF oDlg5 PIXEL
EndIf
If aScan(aTela,{ |x| x == cTitNFE }) > 0
   nLin+=12
   @ nLin,006 SAY cTitNFE SIZE 74,  7 OF oDlg5 PIXEL //"Nota Fiscal de Entrada"
   @ nLin,096 MSGET oGet VAR TULT_FE SIZE 32, 10 OF oDlg5 PIXEL
   @ nLin,151 MSGET oGet VAR TARQ_FE SIZE 47, 10 OF oDlg5 PIXEL
EndIf
If aScan(aTela, { |x| x == STR0672 }) > 0
   nLin+=12
   @ nLin,006 SAY STR0672 SIZE 74,  7 OF oDlg5 PIXEL //"Recebimento de numerário"
   @ nLin,096 MSGET oGet VAR TULT_NU SIZE 32, 10 OF oDlg5 PIXEL
   @ nLin,151 MSGET oGet VAR TARQ_NU SIZE 47, 10 OF oDlg5 PIXEL
EndIf
//***SVG 
If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"PARAMGET")
EndIf

nLin+=14
//nLin :=128
nLin1:=nLin
nCol1:=008
nCol2:=070
nCol3:=140
nCol4:=210
nCol5:=270

nLin +=06
@ nLin,nCol1 CHECKBOX  oActive  VAR TINC_CI  PROMPT  STR0120  OF oDlg5 PIXEL SIZE 50,10 FONT oDlg5:oFont //"Item"
@ nLin,nCol2 CHECKBOX  oActive4 VAR TINC_NBM PROMPT  STR0140  OF oDlg5 PIXEL SIZE 50,10 FONT oDlg5:oFont //"NCM"              MJB-SAP-1200
@ nLin,nCol3 CHECKBOX  oActive7 VAR TINC_CC  PROMPT  STR0287  OF oDlg5 PIXEL SIZE 50,10 FONT oDlg5:oFont //"Centro de Custo"  MJB-SAP-1200
@ nLin,nCol4 CHECKBOX  oActive0 VAR TINC_AG  PROMPT  STR0290  OF oDlg5 PIXEL SIZE 50,10 FONT oDlg5:oFont //"Agente"           MJB-SAP-1200
@ nLin,nCol5 CHECKBOX  oActivec VAR TINC_CO  PROMPT  STR0293  OF oDlg5 PIXEL SIZE 40,10 FONT oDlg5:oFont //"Comprador"        MJB-SAP-1200
nLin +=11
@ nLin,nCol1 CHECKBOX  oActive2 VAR TINC_FA  PROMPT  STR0250  OF oDlg5 PIXEL SIZE 50,10 FONT oDlg5:oFont //"Fabricante"
@ nLin,nCol2 CHECKBOX  oActive5 VAR TINC_FAM PROMPT  STR0285  OF oDlg5 PIXEL SIZE 50,10 FONT oDlg5:oFont //"Família"          MJB-SAP-1200
@ nLin,nCol3 CHECKBOX  oActive8 VAR TINC_IMP PROMPT  STR0288  OF oDlg5 PIXEL SIZE 50,10 FONT oDlg5:oFont //"Importador"       MJB-SAP-1200
@ nLin,nCol4 CHECKBOX  oActivea VAR TINC_FW  PROMPT  STR0291  OF oDlg5 PIXEL SIZE 50,10 FONT oDlg5:oFont //"Forwarder"        MJB-SAP-1200
@ nLin,nCol5 CHECKBOX  oActived VAR TINC_FO  PROMPT  STR0251  OF oDlg5 PIXEL SIZE 40,10 FONT oDlg5:oFont //"Fornecedor"       MJB-SAP-1200
nLin +=11
@ nLin,nCol1 CHECKBOX  oActive3 VAR TINC_LI  PROMPT  STR0277  OF oDlg5 PIXEL SIZE 50,10 FONT oDlg5:oFont //"Item/Fabr/Forn"   MJB-SAP-1200
@ nLin,nCol2 CHECKBOX  oActive6 VAR TINC_LE  PROMPT  STR0286  OF oDlg5 PIXEL SIZE 50,10 FONT oDlg5:oFont //"Local de Entrega" MJB-SAP-1200
@ nLin,nCol3 CHECKBOX  oActive9 VAR TINC_CON PROMPT  STR0289  OF oDlg5 PIXEL SIZE 50,10 FONT oDlg5:oFont //"Consignatário"    MJB-SAP-1200
@ nLin,nCol4 CHECKBOX  oActiveb VAR TINC_BAN PROMPT  STR0292  OF oDlg5 PIXEL SIZE 50,10 FONT oDlg5:oFont //"Banco/Agencia"
nLin +=12
@ nLin1, 3 TO nLin, 311 LABEL STR0283 OF oDlg5  PIXEL //"Inclusões Automáticas"

@ 45, 203 TO 79, 311 LABEL STR0295 OF oDlg5 PIXEL //"Diret¢rio dos Arq. Tempor rios"
@ 60, 210 MSGET oGet VAR TARQ_TMP  VALID IN100PARVAL(TARQ_TMP)  SIZE 95, 10    OF oDlg5 PIXEL

DEFINE SBUTTON FROM 100,220 TYPE 1 ACTION (nVolta:=1,oDlg5:End()) ENABLE OF oDlg5
DEFINE SBUTTON FROM 100,270 TYPE 2 ACTION (oDlg5:End()) ENABLE OF oDlg5

oGet:bGotFocus = { || oGet:SetPos( 0 ), nil }
nVolta = 0

nLin += 250
oDlg5:nHeight:=nLin

ACTIVATE MSDIALOG oDlg5 CENTERED


IF nVolta = 1
   Reclock("Int_Param",.F.)
   DBSELECTAREA(cAlias)
   Int_Param->NPAULT_SP   :=TULT_SP
   Int_Param->NPAULT_CI   :=TULT_CI
   Int_Param->NPAULT_FB   :=TULT_FB
   Int_Param->NPAULT_LI   :=TULT_LI
   Int_Param->NPAULT_NB   :=TULT_NB
   Int_Param->NPAULT_FP   :=TULT_FP
//   Int_Param->NPAULT_FP   :=TULT_TP
   Int_Param->NPAULT_TC   :=TULT_TC
   Int_Param->NPAULT_DE   :=TULT_DE
   Int_Param->NPAULT_DI   :=TULT_DI
   Int_Param->NPAULT_CC   :=TULT_CC
   Int_Param->NPAULT_FE   :=TULT_FE
   Int_Param->NPAULT_NU   :=TULT_NU
   Int_Param->NPAARQ_H    :=ALLTRIM(TARQ_H)
   Int_Param->NPAARQ_I    :=ALLTRIM(TARQ_I)
   Int_Param->NPAARQ_CI   :=ALLTRIM(TARQ_CI)
   Int_Param->NPAARQ_FB   :=ALLTRIM(TARQ_FB)
   Int_Param->NPAARQ_LI   :=ALLTRIM(TARQ_LI)
   Int_Param->NPAARQ_NB   :=ALLTRIM(TARQ_NB)
   Int_Param->NPAARQ_TC   :=ALLTRIM(TARQ_TC)
   Int_Param->NPAARQ_FP   :=ALLTRIM(TARQ_FP)
// Int_Param->NPAARQ_TP   :=ALLTRIM(TARQ_TP)
   Int_Param->NPAARQ_DE   :=ALLTRIM(TARQ_DE)
   Int_Param->NPAARQ_DI   :=ALLTRIM(TARQ_DI)
   Int_Param->NPAARQ_CC   :=ALLTRIM(TARQ_CC)
   Int_Param->NPAARQ_FE   :=ALLTRIM(TARQ_FE)
   Int_Param->NPAARQ_NU   :=ALLTRIM(TARQ_NU)
   Int_Param->NPAARQ_TMP  :=UPPER(ALLTRIM(TARQ_TMP))
   Int_Param->NPAINC_CI   :=TINC_CI
   Int_Param->NPAINC_FA   :=TINC_FA
   Int_Param->NPAINC_FO   :=TINC_FO
   Int_Param->NPAINC_LI   :=TINC_LI
   Int_Param->NPAINC_CO   :=TINC_CO
   Int_Param->NPAINC_LE   :=TINC_LE
   Int_Param->NPAINC_CC   :=TINC_CC
   Int_Param->NPAINC_AG   :=TINC_AG
   Int_Param->NPAINC_UNI  :=TINC_UNI
   Int_Param->NPAINC_FW   :=TINC_FW
   Int_Param->NPAINC_IMP  :=TINC_IMP
   Int_Param->NPAINC_CON  :=TINC_CON
   Int_Param->NPAINC_NBM  :=TINC_NBM
   Int_Param->NPAINC_FAM  :=TINC_FAM
   Int_Param->NPAINC_BAN  :=TINC_BAN

   If EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"PARAMGRAVA")
   EndIf

   DBCOMMIT()
   Int_Param->(MSUNLOCK())
ENDIF

RETURN .T.


*-----------------------------*
Function IN100PARVAL(TARQ_TMP)
*-----------------------------*
IF ! EMPTY(ALLTRIM(TARQ_TMP))
   If ! AvIsDir(ALLTRIM(TARQ_TMP)) // Path nao existe
      IN_MSG(STR0025)                     // Diretorio especificado nao encontrado.
      RETURN (.F.)
   EndIf
ENDIF
RETURN .T.


*-------------------------*
Function E_cgc(cCGC,lHelp)
*-------------------------*
LOCAL nCnt,i,j,cDVC,nSum,nDIG,cDIG:="",nSavRec,nSavOrd

IF lHelp = NIL
   lHelp:= .T.
ENDIF

cCGC    := IIF(cCgc  == Nil,&(ReadVar()),cCGC)
If cCgc == "00000000000000"
   Return .T.
Endif

nTamanho:=Len(AllTrim(cCGC))

cDVC:=SubStr(cCGC,13,2)
cCGC:=SubStr(cCGC,1,12)

FOR j := 12 TO 13
    nCnt := 1
    nSum := 0
    FOR i := j TO 1 Step -1
        nCnt++
        IF nCnt>9;nCnt:=2;EndIf
        nSum += (Val(SubStr(cCGC,i,1))*nCnt)
    Next i
    nDIG := IIF((nSum%11)<2,0,11-(nSum%11))
    cCGC := cCGC+STR(nDIG,1)
    cDIG := cDIG+STR(nDIG,1)
Next j
lRet:=IIF(cDIG==cDVC,.T.,.F.)

IF !lRet
   IF nTamanho < 14
      cDVC:=SubStr(cCGC,10,2)
      cCPF:=SubStr(cCGC,1,9)
      cDIG:=""

      FOR j := 10 TO 11
          nCnt := j
          nSum := 0
          For i:= 1 To Len(Trim(cCPF))
              nSum += (Val(SubStr(cCPF,i,1))*nCnt)
              nCnt--
          Next i
          nDIG:=IIF((nSum%11)<2,0,11-(nSum%11))
          cCPF:=cCPF+STR(nDIG,1)
          cDIG:=cDIG+STR(nDIG,1)
      Next j

      IF cDIG != cDVC
         IF lHelp
            HELP(" ",1,"CGC")
         ENDIF
      Endif

      lRet:=IIF(cDIG==cDVC,.T.,.F.)
      IF lRet;m->a1_cgc:=cCPF+Space(3);EndIF
   Else
      IF lHelp
         HELP(" ",1,"CGC")
      ENDIF
   EndIF
EndIF
Return lRet

*--------------------*
FUNCTION IN100LerFE()
*--------------------*
LOCAL cNota, lDetMsg:=.F.,cCod_I:='',cForn:='' //, cSerie WFS 18/11/08
//LOCAL cMsgPO:=cTitNFE+': '+Int_FE->NFENOTA //"Nota Fiscal de Entrada"
LOCAL lPos:=lPLI:=lForn:=lOKPO:=lProc:=lItem:=lOKTEC:=lLiSus:=.T.,lOK:=.F.
LOCAL cTipoNF  := "1"
//WFS 18/11/08
LOCAL lpassou
LOCAL aForn := {}
Local lValQtde:= EasyGParam("MV_EIC0032",,.F.)
Local nQUANT
Local cNFEHAWB
Private cNumero, cSerie, dDtEmis

DO Case
   Case INT_FE->NFEESPECIE = "NFE"
        cTipoNF := "1"
   Case INT_FE->NFEESPECIE = "NFC"
        cTipoNF := "2"
   Case INT_FE->NFEESPECIE = "NFU"
        cTipoNF := "3"
   Case INT_FE->NFEESPECIE = "NFM" 
        cTipoNF := "5"
   Case INT_FE->NFEESPECIE = "NFF" 
        cTipoNF := "6"
   Case INT_FE->NFEESPECIE = "NFT"//AWR - 16/02/2009
        cTipoNF := "9"
Endcase

SW6->(DBSETORDER(1))
SW2->(DBSETORDER(1))
SB1->(DBSETORDER(1))
SF1->(DBSETORDER(1))
SA2->(DBSETORDER(1))
SA5->(DBSETORDER(3))
SYU->(DBSETORDER(2))
SWZ->(DBSETORDER(1))
SW4->(DBSETORDER(1))
Int_FE->NFEITEM_OK:="T"
Int_FE->NFEMSG    :=""
cForn:=SPACE(nlenForn)//Int_FE->NFEEXPORT AWR-SAP 22/2/2001 SO.:0026 OS.: 0232/02 FCD
cSerie:= Int_FE->NFESERIE
IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"LERFE")
ENDIF

IF LEN(ALLTRIM(Int_FE->NFENOTA)) > LEN(SF1->F1_DOC)
   EVAL(bMsg,"Tamanho do Nro da Nota fiscal da integracao difere da base")
ENDIF 

IF cTipoNF $ "5,6" .AND. !lMV_NF_MAE
   EVAL(bMsg,"Sistema não está parametrizado para tratar notas mãe e filha")
ENDIF


SF1->(DBSETORDER(1))
IF EMPTY(cNota:=Int_FE->NFENOTA)
   EVAL(bMsg,STR0535+STR0546) //"Número da Nota Fiscal"" não informado(a)"
//WFS 18/11/08 ---
ElseIf (!EasyGParam("MV_NFEDESP",.T.)) .OR. (EasyGParam("MV_NFEDESP",,.F.))
   If SF1->(DBSEEK(cFilSF1+cNota+cSerie))
   //ELSEIF SF1->(DBSEEK(cFilSF1+cNota+cSerie))
      lMensagem:=.F.
      DO WHILE SF1->(!EOF()) .AND. SF1->F1_FILIAL = cFilSF1 .AND. SF1->F1_DOC = cNota .AND. SF1->F1_SERIE = cSerie
         IF !EMPTY(SF1->F1_HAWB)
            lMensagem:=.T.
            EXIT
         ENDIF
         SF1->(DBSKIP())
      ENDDO
      IF lMensagem
         EVAL(bMsg,STR0535+STR0545) //"Número da Nota Fiscal" " já cadastrado(a)"
      ENDIF   
   ENDIF
ELSE
   IF EMPTY(cSerie:= AllTrim(EasyGParam("MV_SER_NFE")))
      EVAL(bMsg,"Serie não informada (parâmetro MV_SER_NFE)") 
   ELSE
	  SX5->(dbSetOrder(1))
      IF !SX5->(dbSeek(If(EasyEntryPoint("CHGX5FIL"),ExecBlock("CHGX5FIL"),xFilial("SX5"))+"01"+Avkey(cSerie,"X5_CHAVE")))  // GFP - 30/01/2014
         EVAL(bMsg,"Serie não cadastrada (tabela 01-SX5)") 
      ENDIF
   ENDIF
ENDIF

// ----
lProc:=.T.
SF1->(DBSETORDER(5))
IF EMPTY(Int_FE->NFEHAWB)
   lProc:=.F.
   EVAL(bMsg,STR0527+STR0546) // Processo " não informado(a)"
ELSEIF !SW6->(DBSEEK(cFilSW6+AvKey(Int_FE->NFEHAWB,"W6_HAWB")))
   lProc:=.F.
   EVAL(bMsg,STR0527+STR0544 ) // Processo " sem cadastro"
ELSEIF cTipoNF <> "6" .AND. SF1->(DBSEEK(cFilSF1+AvKey(Int_FE->NFEHAWB,"W6_HAWB")+cTipoNF))
   lProc:=.F.
   EVAL(bMsg,STR0705)//"Processo já possui Nota Fiscal"
ELSEIF cTipoNF = "6" .AND. !SF1->(DBSEEK(cFilSF1+AvKey(Int_FE->NFEHAWB,"W6_HAWB")+"5"))   
   lProc:=.F.
   EVAL(bMsg,"Processo não possui nota mãe.")
ELSEIF cTipoNF = "2" .AND. !SF1->(DBSEEK(cFilSF1+AvKey(Int_FE->NFEHAWB,"W6_HAWB")+"1")) .AND. !SF1->(DBSEEK(cFilSF1+AvKey(Int_FE->NFEHAWB,"W6_HAWB")+"3")) .AND. !SF1->(DBSEEK(cFilSF1+AvKey(Int_FE->NFEHAWB,"W6_HAWB")+"5"))
   lProc:=.F.
   EVAL(bMsg,"Processo não possui nota primeira, unica ou nota mãe.")
ENDIF
SF1->(DBSETORDER(1))

IF lProc
   SW8->(DBSETORDER(1))
   SW9->(DBSETORDER(3))
   IF !SW8->(DBSEEK(cFilSW8+SW6->W6_HAWB)) .OR.;
      !SW9->(DBSEEK(cFilSW9+SW6->W6_HAWB))
      EVAL(bMsg,STR0720)//"Nota Fiscal não pode ser gerada, Processo nao possui Invoices.
   ENDIF  
   SW9->(DBSETORDER(1))
   
ENDIF

lForn:=.T.

If Empty(SW6->W6_DT_EMB)
   EVAL(bMsg,"Processo sem Data de Embarque preenchida.") //"Processo sem Data de Embarque preenchida."
EndIf
//MFR 28/09/2021 OSSME-6230
If Empty(SW6->W6_DT_DESE)
   EVAL(bMsg,STR0794) //"Processo sem Data de Desembaraço preenchida."
EndIf

IF IN100NaoNum(Int_FE->NFEQTDITEM)
   EVAL(bMsg,STR0381+STR0549)//"Quantidade"  " inválido(a)" 
ENDIF
//WFS 18/11/08 ---
If !EasyGParam("MV_NFEDESP",.T.) .OR. EasyGParam("MV_NFEDESP",,.F.)   
   IF ! IN100CTD(Int_FE->NFEDT_EMIS,.T.,'AAAAMMDD')                          //MJB-SAP-1100
      EVAL(bMsg,STR0465+' '+STR0569+STR0546) //Data NFE Emissao " não informado(a)"
   ENDIF
EndIf
// ---

IF IN100NaoNum(Int_FE->NFEVALMERC)
   EVAL(bMsg,STR0565+STR0549) //"Vlr. Mercadoria"  " inválido(a)" 
ENDIF

IF IN100NaoNum(Int_FE->NFETOTNOTA)
   EVAL(bMsg,STR0536+STR0549) //"Valor da NF"  " inválido(a)" 
ENDIF

IF !EMPTY(INT_FE->NFECFOP) .AND. !SWZ->(DbSeek(cFilSWZ+ALLTRIM(INT_FE->NFECFOP)))
   EVAL(bMsg,STR0581+STR0544,.T.) //"C.F.O." " sem cadastro"
ENDIF

IF !Int_FD->(DBSEEK(cNota))
   EVAL(bMsg,STR0572) //"Nota não possui itens"
ENDIF                                                                   

QuebraLote()

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"VALFE")
ENDIF

IN100VerErro(cErro,cAviso)
cErro:=NIL ; cAviso:=NIL
lpassou := .F.
SW8->(dbSetOrder(6))
INT_FD->(dbseek(INT_FE->NFENOTA)) // RJB 21/02/2006 POSICIONA NO PRIMEIRO DA NOTA
aCheckItens := {}//JVR - 25/02/2010 - utilizada na validação de quantidade.
DO WHILE ! Int_FD->(EOF()) .AND. Int_FD->NFDNOTA == cNota

   //JVR - 25/02/10 - Tratamento para validação de quantidade de item na integração.
   If EasyGParam("MV_VAL_INT",,.F.)//JVR - 24/03/10 - "Valida os valores da integracao da NF"
      cChaveBusca := AvKey(Int_FD->NFDHAWB,"W6_HAWB") + AvKey(Int_FD->NFDFATURA,"W9_INVOICE") + Int_FD->NFDCOD_I
      nPosItem:= Ascan(aCheckItens, {|x| x[1] == cChaveBusca})
      If nPosItem == 0
         aAdd(aCheckItens,{cChaveBusca,;//chave
                           Val(Int_FD->NFDQUANT),;//Valor encontrado no arquivo de integração.
                           BuscaQtdInv(AvKey(Int_FD->NFDHAWB,"W6_HAWB"), AvKey(Int_FD->NFDFATURA,"W9_INVOICE"), Int_FD->NFDCOD_I)})//Valor do item na invoice.
   
         nPosItem:= Ascan(aCheckItens, {|x| x[1] == cChaveBusca})
      Else
         aCheckItens[nPosItem][2] += Val(Int_FD->NFDQUANT)
      EndIf
      If aCheckItens[nPosItem][3] < aCheckItens[nPosItem][2]//Qtde da invoice X Qtde da integração
         EVAL(bMsg,"Quantidade do Item na itegração maior do que a cadastrada na invoice do Easy.")
      EndIf                   
   EndIf

  Int_FD->NFDTIPO  := 'I'
  Int_FD->NFDINT_OK:= 'T'
  Int_FD->NFDMSG   := ''
  cCod_I  := AvKey( LEFT(Int_FD->NFDCOD_I ,LEN(SB1->B1_COD   )), "B1_COD")   //NCF - 28/03/2011 - Acerto na chave do Item
  cPo_NUM := AvKey(Int_FD->NFDPO_NUM,"W2_PO_NUM")//LEFT(Int_FD->NFDPO_NUM,LEN(SW2->W2_PO_NUM))
  cNFEHAWB:= AvKey(Int_FE->NFEHAWB,"W7_HAWB")
  IF EasyEntryPoint("IN100CLI")
     ExecBlock("IN100CLI",.F.,.F.,"LERFD")
  ENDIF

  lForn:=lOKPO:=.T.
  IF EMPTY(cPo_NUM)
     lForn:=lOKPO:=.F.
     EVAL(bMsg,STR0553+STR0546) //"No. do P.O. não informado(a)"
  ELSEIF !SW2->(DBSEEK(cFilSW2+AVKEY(cPo_NUM,"W2_PO_NUM")))                                                              //MJB-SAP-0401
     lForn:=lOKPO:=.F.
     EVAL(bMsg,STR0553+STR0544) //"No. do P.O. sem cadastro" 
     
  //AOM - 07/01/10   
  ELSEIF lpassou .AND. ASCAN(aForn,SW2->W2_FORN) = 0 
     lForn:=lOKPO:=.F.
     EVAL(bMsg,STR0779) //"Não é permitido mais de um fornecedor na NF"
  ELSE
     cForn:=SW2->W2_FORN // AWR-SAP 22/2/2001
     AADD(aForn,cForn)
     lpassou := .T.
  ENDIF

  lItem:=.T.
  IF EMPTY(cCod_I)
     lItem:=.F.
     EVAL(bMsg,STR0556+STR0546) //"Código do Item" " não informado(a)"
  ELSEIF !SB1->(DBSEEK(cFilSB1+cCod_I))
     lItem:=.F.
     EVAL(bMsg,STR0556+STR0544) //"Código do Item" " sem cadastro"
  ENDIF

  lPos:=.T.
  IF IN100NaoNum(Int_FD->NFDITEM)
     lPos:=.F.
     EVAL(bMsg,STR0296+STR0549) //"Posição" " inválido(a)"
  ELSE
     Int_FD->NFDITEM  :=STRZERO(VAL(Int_FD->NFDITEM),nTamPosicao)
  ENDIF

  lOKTEC:=.T.
  IF IN100NaoNum(Int_FD->NFDCLASFIS)
     lOKTEC:=.f.
     EVAL(bMsg,STR0125+STR0549) //"N.C.M." " inválido(a)" 
  ELSEIF !SYD->(DBSEEK(cFilSYD+Int_FD->NFDCLASFIS))//+Int_FD->NFDEX_NCM))
     lOKTEC:=.f.
     EVAL(bMsg,STR0125+STR0544) //"N.C.M." " sem cadastro"
  ENDIF

  IF lOKPO .AND. lItem
     SW3->(DBSETORDER(8))
     IF !SW3->(DBSEEK(cFilSW3+AVKEY(cPo_NUM,"W3_PO_NUM")+Int_FD->NFDITEM))                                               //MJB-SAP-0401
        EVAL(bMsg,STR0573) //"Item não cadastrado no P.O."
     ELSEIF lOKTEC
        IF Int_FD->NFDCLASFIS # SW3->W3_TEC .AND.;
           Int_FD->NFDCLASFIS # SB1->B1_POSIPI
           EVAL(bMsg,STR0574,.T.)  //"N.C.M. não cadastada para este item"
        ENDIF
     ENDIF
  ENDIF
  
  lPLI:=.T.
  IF EMPTY(Int_FD->NFDPLI)
     EVAL(bMsg,STR0578+STR0546) // "P.L.I." " não informado(a)"
     lPLI:=.F.
  ENDIF

  lOK:=.F.
  IF lProc .AND. lItem .AND. lOKPO .AND. lPLI .AND. lPos
     SW7->(dbsetorder(4))
     SW7->(dbseek(cFilSW7+cNFEHAWB+cPo_NUM+INT_FD->NFDITEM))                                   //MJB-SAP-0401   
     DO While cFilSW7         == sw7->W7_FILIAL .and.;                                                //MJB-SAP-0401
              cNFEHAWB			== SW7->W7_HAWB   .and.;
              cPo_NUM         == SW7->W7_PO_NUM .and.;
              INT_FD->NFDITEM == SW7->W7_POSICAO
        IF cCod_I  == SW7->W7_COD_I .AND. SW7->W7_PGI_NUM == INT_FD->NFDPLI
           lOK:=.T.
           EXIT
        endif
        SW7->(dbskip())
     Enddo
     IF !lOK
        EVAL(bMsg,STR0575) //"Item não cadastrado no Processo"
     ELSE                                  
        // EOB - 29/04/09 - Chamado 718829 - Não permitir a integração do item da NF que esteja com a NCM diferente 
        // do item do desembaraço, pois dá problema de rateio na geração da NF complementar
        IF Int_FD->NFDCLASFIS # SW7->W7_NCM
           EVAL(bMsg,STR0778)  //"N.C.M. divergente do item do processo."
        ENDIF
        
        //JVR - 24/03/2010 - Tratamento para gravação de adição sem necessidade de numero de invoice na integração.
        lAchou := .F.
        SW9->(DbSetOrder(3))
        If SW9->(DbSeek(cFilSW9 + cNFEHAWB))
           While SW9->(!EOF()) .and. SW9->W9_HAWB == cNFEHAWB
              If SW8->(DbSeek(cFilSW8 + SW9->(W9_HAWB + W9_INVOICE) + cPo_NUM + INT_FD->NFDITEM + INT_FD->NFDPLI))
                 lAchou := .T.
                 Exit
              EndIf
              SW9->(DbSkip())
           EndDo     
        EndIf
        If !lAchou
           EVAL(bMsg, "Item não cadastrado na invoice")
        EndIf
        
        nQUANT:= Val(INT_FD->NFDQUANT)
        If cTipoNF == '6'
           If !((lValQtde .And. nQUANT > ((nQUANT * 0.05) + SW7->W7_SALDO_Q)) .Or.(!lValQtde .AND. nQUANT > (SW7->W7_SALDO_Q)))
              EVAL(bMsg, STR0791 + ": " + cCod_I) // "Valor e/ou quantidade maior que o informado na Nota Fiscal Mãe (NFM)."
           EndIf
        EndIf

      ENDIF
   ENDIF

  IF IN100NaoNum(Int_FD->NFDQUANT)
     EVAL(bMsg,STR0381+STR0549) //"Quantidade" " inválido(a)" 
  ENDIF

  IF lItem .AND. lOK .AND. lForn
  
     IF SA5->(DBSEEK(cFilSA5+cCod_i+cForn+SW7->W7_FABR))   // Jonato em 27-11-00
        IF ! EMPTY(SA5->A5_UNID)
           Int_FD->NFDUNI:= SA5->A5_UNID
        ELSE
           Int_FD->NFDUNI:= SB1->B1_UM
        ENDIF
     ELSE
        Int_FD->NFDUNI:= SB1->B1_UM
     ENDIF

  ENDIF

  IF IN100NaoNum(Int_FD->NFDVALOR)
     EVAL(bMsg,STR0536+STR0549) //"Valor da NF" " inválido(a)" 
  ENDIF

  IF IN100NaoNum(Int_FD->NFDFOBRS)  .AND. cTipoNF <> "2"
     EVAL(bMsg,STR0310+STR0549) //"Valor FOB" " inválido(a)" 
  ENDIF

  IF IN100NaoNum(Int_FD->NFDPESOL) .AND. cTipoNF <> "2"
     EVAL(bMsg,STR0127+STR0549) //"Peso Líquido" " inválido(a)" 
  ENDIF                                        

  SW6->(DBSEEK(cFilSW6+AvKey(Int_FD->NFDHAWB,"W6_HAWB")))
  IF !lMV_PIS_EIC .AND. (SW6->W6_DTREG_D >= CTOD("01/05/2004"))
     EVAL(bMsg,STR0739)//"Sistema não preparado para Pis/Cofins" 
  ENDIF                                               
  
  IF lMV_GRCPNFE//Campos novos NFE - AWR 04/11/2008
     IF !EMPTY(SW6->W6_DI_NUM) .AND. EMPTY(INT_FD->NFDADICAO)
        EVAL(bMsg,"Numero da adicao nao informado para o item: "+cCod_I)
     ENDIF
     IF !EMPTY(SW6->W6_DI_NUM) .AND. EMPTY(INT_FD->NFDSEQ_ADI)
        EVAL(bMsg,"Sequencia dentro da adicao nao informada para o item : "+cCod_I)
     ENDIF
  ENDIF
	
  //THTS - 16/08/2019 - Validacao para os campos de No. PLI/Reg. e LI Sustitutiva - OSSME-3064
  If SW4->(dbSeek(cFilSW4 + INT_FD->NFDPLI)) .And. SW4->W4_FLUXO == "7" .And. !Empty(INT_FD->NFDPLIREG)
		EVAL(bMsg,"Item não anuente, não deve ser associada uma LI: " + cCod_I)//"Item não anuente, não deve ser associada uma LI:"
		lLiSus := .F. //Utilizada para nao efetuar a verificacao da LI Substitutiva quando invalidar pelo item nao anuente
  EndIf
  If lLiSus .And. !Empty(INT_FD->NFDLISUBS) .And. Empty(INT_FD->NFDPLIREG)
		EVAL(bMsg,"Informada a LI Substit., porém não foi informado o No.LI: " + cCod_I)//"Informada a LI Substit., porém não foi informado o No.LI:"
  EndIf
  
  IF EasyEntryPoint("IN100CLI")
     ExecBlock("IN100CLI",.F.,.F.,"VALFD")
  ENDIF

  IF cErro # NIL
     Int_FD->NFDMSG:=cErro ; cErro:= NIL ; lDetMsg:=.T. ; cAviso:= NIL
     Int_FD->NFDINT_OK := "F"
  ELSE
     Int_FD->NFDINT_OK := "T"
     IF cAviso # NIL
        Int_FD->NFDMSG:=cAviso ; cAviso:= NIL
     ENDIF
  ENDIF

  If Int_FE->NFEITEM_OK = "T" .AND. !Int_FD->NFDINT_OK = "T"
     Int_FE->NFEITEM_OK:= "F"
     Int_FE->NFEINT_OK := "F"
  EndIf
     
  Int_FD->(DBSKIP())
 
ENDDO

IF EMPTY(ALLTRIM(Int_FE->NFEMSG)) .AND. lDetMsg
   Int_FE->NFEMSG :=STR0354 //".....VIDE ITENS"
ENDIF

IF Int_FE->NFEINT_OK = "T"
   nResumoCer+=1
ELSE
   nResumoErr+=1
ENDIF

SW3->(DBSETORDER(1))
SYU->(DBSETORDER(1))

//RETURN .T.
Return Int_FE->NFEINT_OK // BAK - alteração para nova integração com despachante

**************** INICIO PO *****************************************************
*-----------------------------------------------------------------------------
FUNCTION IN100PO()
*-----------------------------------------------------------------------------
TB_Col_D:={}

AADD(TB_Col_D,{ {|| IN100Status()}                             ,"",STR0036 }) //"Status"
AADD(TB_Col_D,{ {|| IN100TIPO() }                              ,"",STR0037 }) //"Tipo"
AADD(TB_Col_D,{ {|| TRANSFORM(LEFT(NIPCOD_I,nLenItem),_PictItem)}   ,"",STR0120 }) //"Item"
AADD(TB_Col_D,{ {|| NIPPOSICAO}                                ,"",STR0296 }) //"Posicao"
AADD(TB_Col_D,{ {|| TRANSFORM(VAL(NIPQTDE),_PictQtde)}              ,"",STR0297 }) //"Qtde"                //MJB-SAP-0401
AADD(TB_Col_D,{ {|| TRANSFORM(VAL(NIPPRECO),_PictPrUn)}             ,"",STR0298 }) //"Preco Unitario"
AADD(TB_Col_D,{ {|| TRANSFORM(VAL(NIPQTDE)*VAL(NIPPRECO),_PictPrUn)},"",STR0299 }) //"Preco Total"
AADD(TB_Col_D,{ {|| NIPFABR}                                   ,"",STR0250 }) //"Fabricante"
AADD(TB_Col_D,{ {|| NIPCC+'-'+TRANSFORM(NIPSI_NUM,_PictSI)}         ,"",_LIT_R_CC+STR0300}) //"-S.I."
AADD(TB_Col_D,{ {|| IN100CTD(NIPDT_ENTR)}                      ,"",STR0301 }) //"Entrega"
AADD(TB_Col_D,{ {|| IN100CTD(NIPDT_EMB)}                       ,"",STR0302 }) //"Embarque"
If lNIPTEC
   AADD(TB_Col_D,{ {|| NIPTEC}                                    ,"",STR0140 }) //"N.C.M."
EndIf
AADD(TB_Col_D,{ {|| NIPFABR_01}                                ,"",STR0303 }) //"2§ Fabr."
AADD(TB_Col_D,{ {|| NIPFABR_02}                                ,"",STR0304 }) //"3§ Fabr."
AADD(TB_Col_D,{ {|| NIPFABR_03}                                ,"",STR0305 }) //"4§ Fabr."
AADD(TB_Col_D,{ {|| NIPFABR_04}                                ,"",STR0306 }) //"5§ Fabr."
AADD(TB_Col_D,{ {|| NIPFABR_05}                                ,"",STR0307 }) //"6§ Fabr."
IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"COLIP")
ENDIF
AADD(TB_Col_D,{ {|| IN100E_Msg(.T.)}                                  ,"",STR0112   } ) // "Mensagem" 

AADD(TB_Cols,{ {|| Int_PO->NPOMODELO}                                 ,"",STR0106   } ) //"Modelo"
AADD(TB_Cols,{ {|| TRANSFORM(LEFT(Int_PO->NPOPO_NUM, If( AvFlags("AVINTEG") , AVSX3("W3_PO_NUM",3) , 15  )  ),_PictPO)}  ,"", STR0308  } ) //"P.O."
AADD(TB_Cols,{ {|| IN100CTD(Int_PO->NPOPO_DT)}                        ,"", STR0309  } ) //"Data P.O."
AADD(TB_Cols,{ {|| TRANSFORM(Int_PO->NPOFOB_TOT,_PictFob)}                 ,"", STR0310  } ) //"Valor FOB"
AADD(TB_Cols,{ {|| Int_PO->NPO_POLE}                                  ,"", STR0311  } ) //"Local Entrega"
AADD(TB_Cols,{ {|| Int_PO->NPOCOMPRA}                                 ,"", STR0293  } ) //"Comprador"
AADD(TB_Cols,{ {|| Int_PO->NPOTIPO_EM}                                ,"", STR0312  } ) //"Tipo Embarque"
AADD(TB_Cols,{ {|| Int_PO->NPOORIGEM}                                 ,"", STR0313  } ) //"Origem"
AADD(TB_Cols,{ {|| Int_PO->NPODEST}                                   ,"", STR0314  } ) //"Destino"
AADD(TB_Cols,{ {|| TRANSFORM(Int_PO->NPOCOND_PAG,AVSX3("W2_COND_PA",06))}  ,"", STR0315  } ) //"Cond. Pagto"
AADD(TB_Cols,{ {|| Int_PO->NPODIAS_PAG}                               ,"", STR0316  } ) //"Dias Pagto"
AADD(TB_Cols,{ {|| Int_PO->NPOAGENTE}                                 ,"", STR0290  } ) //"Agente"
AADD(TB_Cols,{ {|| Int_PO->NPOIMPORT}                                 ,"", STR0288  } ) //"Importador"
AADD(TB_Cols,{ {|| Int_PO->NPOMOEDA}                                  ,"", STR0240  } ) //"Moeda"
AADD(TB_Cols,{ {|| TRANSFORM(VAL(Int_PO->NPOINLAND), cPict15_2)}           ,"", STR0317  } ) //"Inland Charg"
AADD(TB_Cols,{ {|| TRANSFORM(VAL(Int_PO->NPOPACKING),cPict15_2)}           ,"", STR0318  } ) //"Packing Charg"
AADD(TB_Cols,{ {|| TRANSFORM(VAL(Int_PO->NPODESCONT),cPict15_2)}           ,"", STR0319  } ) //"Desconto"
AADD(TB_Cols,{ {|| TRANSFORM(VAL(Int_PO->NPOFRETEIN),cPict15_2)}           ,"", STR0320  } ) //"Int'l Freight"
AADD(TB_Cols,{ {|| IF(Int_PO->NPOFREPPCC='PP',STR0321,IF(Int_PO->NPOFREPPCC='CC',STR0322,PADR(Int_PO->NPOFREPPCC,7)))},"",STR0323} ) //'Prepaid'###'Collect'###"Tipo Frete"
AADD(TB_Cols,{ {|| Int_PO->NPOCONSIG}                                 ,"",STR0324   } ) //"Consignatario"
AADD(TB_Cols,{ {|| Int_PO->NPOFORN}                                   ,"",STR0251   } ) //"Fornecedor"
AADD(TB_Cols,{ {|| Int_PO->NPONR_PRO}                                 ,"",STR0325   } ) //"No. Proforma"
AADD(TB_Cols,{ {|| IN100CTD(Int_PO->NPODT_PRO)}                       ,"",STR0326   } ) //"Dt. Proforma"
AADD(TB_Cols,{ {|| TRANSFORM(VAL(Int_PO->NPOPARID_US),'@E 999,999.999999')},"",STR0327   } ) //"Paridade"
AADD(TB_Cols,{ {|| IN100CTD(Int_PO->NPODT_PAR)}                       ,"",STR0328   } ) //"Dt Paridade"
AADD(TB_Cols,{ {|| TRANSFORM(VAL(Int_PO->NPOPESO_B),cPict13_3)}            ,"",STR0329   } ) //"Peso Bruto"
AADD(TB_Cols,{ {|| Int_PO->NPOCLIENTE}                                ,"",STR0330   } ) //"Cliente"
AADD(TB_Cols,{ {|| Int_PO->NPOFORWARD}                                ,"",STR0291   } ) //"Forwarder"
AADD(TB_Cols,{ {|| Int_PO->NPOINCOTER}                                ,"",STR0331   } ) //"Incoterms"
AADD(TB_Cols,{ {|| MEMOLINE(Int_PO->NPOOBS,30,1)}                     ,"",STR0332   } ) //"Observação"

//MJB-SAP-0900 order tambem deve ser mudado quando chamado por outro programa
//SYE->(DbSetOrder(2))    // abertura de todos os indices devido a problemas
                        // na BuscaTaxa sob o ADS - mjb0597

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"COLPO")
ENDIF
AADD(TB_Cols,{ {|| IN100E_Msg(.T.)}                         ,"",STR0112} ) // "Mensagem"       

RETURN .T.
                                         
*--------------------*
FUNCTION IN100LerPO()
*--------------------*
//LOCAL nFob_Tot:=0, nParidade:=0, nPO_Num, lMudou:=.F.,aTabReg:={},cOcor
LOCAL nFob_Tot:=0, nParidade:=0, nPO_Num, lMudou:=.F.,cOcor // AST  - 02/04/09 - Declaração do vetor aTabReg movida para a função IN100Integ (cFunção == CAD_PO), na alteração do PO com integração BPCS,
                                                            // é criada uma capa para cada detalhe, na alteração dos itens identicos, o campo W3_REG estava sendo gravado com 1 para todos os itens.

LOCAL cCod_I, NrReg:=1, cForn, lDetMsg:=.F., cPOMsg,cFor, nSeq_PO:=NPOSEQ_PO, PChave_P, cAuxCC, cAuxSI

LOCAL bComprador, bLocal, bDtEntr:=FIELDWBLOCK("NIPDT_ENTR",SELECT("Int_IP")), lAchouW1

LOCAL cMsgPO:=STR0333+TRANSFORM(Int_PO->NPOPO_NUM,_PictPO), lAchou, nRecW1, nRegNIP  //"PROCESSANDO P.O. "
Local lIntDraw := EasyGParam("MV_EIC_EDC",,.T.), lPesqED4:=.T., lAnuDrawback := EasyGParam("MV_ANUDRAW",,.F.)
LOCAL cChaveNIP, cChavePO, cPosPO
Local lTipoItem := ED7->( FieldPos("ED7_TPITEM") ) > 0  .And.  ED7->( FieldPos("ED7_PD") ) > 0
Local ni := 1

PRIVATE lSI_Invalida:=.f.
PRIVATE lCambLiq := lCambAd := .F.     //NCF - 05/11/2010 - Verificações de câmbio

Int_PO->NPOITEM_OK:="T"
Int_PO->NPOMSG    :=""
Int_IP->NIPMSG    :=""

lSairPO := .F.
IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"LERPO")
ENDIF
IF lSairPO
   RETURN .T.
ENDIF

IF EMPTY(nPO_Num:=Int_PO->NPOPO_NUM)
   EVAL(bMsg,STR0553+STR0546) //  NAO INFORMADO
ENDIF

If Type("bUpDate") <> "B"
   bUpDate:= Nil
EndIf

If ! EMPTY(nPO_Num)
   If ! SW2->(DBSEEK(cFilSW2+AVKEY(nPO_Num,"W2_PO_NUM")))                                   //MJB-SAP-0401
      If Int_PO->NPOTIPO # INCLUSAO
         If Int_PO->NPOTIPO = ALTERACAO .AND. lIncAltPO
            Int_PO->NPOTIPO:='I'
         Else
            EVAL(bMsg,STR0553+STR0544)  //  NUM_PO SEM CADASTRO
         Endif
      EndIf
   ElseIf Int_PO->NPOTIPO = INCLUSAO
      EVAL(bMsg,STR0553+STR0545)  // NUM_PO COM CADASTRO
   Else
      lMudou:=.F.

//      IF !Empty(Int_PO->NPOIMPORT) .and. Int_PO->NPOTIPO == ALTERACAO .and. RTRIM(SW2->W2_IMPORT) <> RTRIM(Int_PO->NPOIMPORT)
//         Int_PO->NPOIMPORT := SW2->W2_IMPORT
//      ENDIF

      //NCF - 04/11/2010 - Validação para não permitir integração quando quantidade vir alterada e PO possuir câmbio de adiantamento 
      If Int_PO->NPOTIPO # INCLUSAO      
         aOrdWB := SaveOrd("SWB") 
         SWB->(DbSetOrder(1))
         SWB->(DbSeek(xFilial("SWB")+AvKey(SW2->W2_PO_NUM,"WB_HAWB")+"A"))
         While SWB->(!Eof()) .And. SWB->WB_FILIAL+SWB->WB_HAWB+SWB->WB_PO_DI == xFilial("SWB")+Avkey(SW2->W2_PO_NUM,"WB_HAWB")+"A"
            lCambAd := .T.
            If !Empty(SWB->WB_CA_DT)
               lCambLiq := .T.
               Exit
            EndIf
            SWB->(DbSkip())
         EndDo
         RestOrd(aOrdWB)
         IF Int_PO->NPOTIPO == EXCLUSAO .And. lCambAd
            EVAL(bMsg,STR0782) //"PO não pode ser excluído pois possui parcela de adiantamento"
         ENDIF        
      EndIf
      
      If Int_PO->NPOTIPO == EXCLUSAO .or. (Int_PO->NPOTIPO == ALTERACAO .and. ((!Empty(Int_PO->NPOMOEDA) .and. Alltrim(SW2->W2_MOEDA) <> Alltrim(Int_PO->NPOMOEDA)) .or.;
      (!Empty(Int_PO->NPOCLIENTE) .and. Alltrim(SW2->W2_CLIENTE) <> Alltrim(Int_PO->NPOCLIENTE)) .or.;
      (!Empty(Int_PO->NPOINCOTER) .and. Alltrim(SW2->W2_INCOTER) <> Alltrim(Int_PO->NPOINCOTER))))

         SW3->(DBSEEK(cFilSW3+AVKEY(nPO_Num,"W3_PO_NUM")))                                          //MJB-SAP-0401
         SW3->(DBEVAL({||lMudou:=(SW3->W3_QTDE#W3_SALDO_Q)},{||SW3->W3_FLUXO="1"},;
                      {||!lMudou .AND.SW3->W3_PO_NUM==SW2->W2_PO_NUM.AND.SW3->W3_FILIAL==cFilSW3})) //MJB-SAP-0401
          
         If !lMudou
            SW5->(DBSETORDER(3))
            SW5->(DBSEEK(cFilSW5+nPO_Num))                                                        //MJB-SAP-0401
            SW5->(DBEVAL({||lMudou:=(SW5->W5_QTDE#W5_SALDO_Q)},{||SW5->W5_FLUXO="7"},;
                         {||!lMudou .AND. SW5->W5_PO_NUM==SW2->W2_PO_NUM.AND.SW5->W5_FILIAL==cFilSW5})) //MJB-SAP-0401
         EndIf
       
         IF Int_PO->NPOTIPO == ALTERACAO .AND. Empty(Alltrim(Int_PO->NPOFORN))  // VI 22/11/03
            Int_PO->NPOFORN:=SW2->W2_FORN   // APENAS P/ GRAVAR ITENS
         ENDIF
          
         If Int_PO->NPOTIPO == EXCLUSAO .and. lMudou
            EVAL(bMsg,STR0553+STR0334) //NUM_PO EM ANDAMENTO"
         ElseIf Int_PO->NPOTIPO == ALTERACAO .and. lMudou
            IF !Empty(Int_PO->NPOFORN) .and. RTRIM(SW2->W2_FORN) <> RTRIM(Int_PO->NPOFORN)
               EVAL(bMsg,STR0335) //" FORNECEDOR NAO PODE SER ALTERADO "
            ENDIF
            If !Empty(Int_PO->NPOMOEDA) .and. Alltrim(SW2->W2_MOEDA) <> Alltrim(Int_PO->NPOMOEDA)
               EVAL(bMsg,STR0240+STR0738) //" MOEDA NAO PODE SER ALTERADO "
            EndIf
            If !Empty(Int_PO->NPOCLIENTE) .and. Alltrim(SW2->W2_CLIENTE) <> Alltrim(Int_PO->NPOCLIENTE)
               EVAL(bMsg,STR0330+STR0738) //" CLIENTE NAO PODE SER ALTERADO "
            EndIf
            If !Empty(Int_PO->NPOINCOTER) .and. Alltrim(SW2->W2_INCOTER) <> Alltrim(Int_PO->NPOINCOTER)
               EVAL(bMsg,STR0331+STR0738) //" INCOTERM NAO PODE SER ALTERADO "
            EndIf
         EndIf
      EndIf
   ENDIF
ENDIF

IF Int_PO->NPOTIPO == EXCLUSAO
   IF EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"VALPO")
   ENDIF
   IN100VerErro(cErro,cAviso)
   IF Int_PO->NPOINT_OK = "T"
      nResumoCer+=1
   ELSE
      nResumoErr+=1
   ENDIF

   if ValType(bUpDate) == "B"  
      Int_IP->(DBSEEK(nPO_Num+nSeq_PO)) 
      DO WHILE ! Int_IP->(EOF()) .AND. Int_IP->NIPPO_NUM == nPO_Num .AND. Int_IP->NIPSEQ_PO == nSeq_PO    
         Int_IP->NIPINT_OK := "T"
         
         cFuncao:="IP"
         Eval(bUpDate, Int_IP->NIPMSG,Int_IP->NIPINT_OK)
         cFuncao:="PO"
         
         Int_IP->(dbSkip())
      EndDo
   endif
   
   RETURN
ENDIF

bLocal    :=FIELDBLOCK('NPO_POLE')
bComprador:=FIELDBLOCK('NPOCOMPRA')
IN100Capa(Int_PO->NPOPO_DT,STR0336,bLocal,bComprador,Int_PO->NPOTIPO) //"DATA DO P.O."
IN100POCheck(Int_PO->NPOFORN)

IF Int_PO->NPOTIPO == ALTERACAO
   Int_PO->NPOFORN:=SW2->W2_FORN   // APENAS P/ GRAVAR ITENS
ENDIF

cForn :=Int_PO->NPOFORN

IF ! Int_IP->(DBSEEK(nPO_Num+nSeq_PO)) .AND. Int_PO->NPOTIPO # 'A'
   EVAL(bMsg,STR0337) //"P.O. NAO POSSUI ITENS"
ENDIF

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"VALPO")
ENDIF
IN100VerErro(cErro,cAviso)
cErro:=NIL ; cAviso:=NIL

lAutoInclui:=(Int_Param->NPAINC_CI  .OR. Int_Param->NPAINC_FA .OR. ;
              Int_Param->NPAINC_FO)

lSI_Invalida := .f.
lLESI := .f.
cAuxCC:=""
cAuxSI:=""
//aTabIP:={}
//aTabSI:={}
If lIntDraw
   ED4->(dbSetOrder(3))
   ED0->(dbSetOrder(2))
   cFilED4:=xFilial("ED4")
   cFilED0:=xFilial("ED0")
EndIf
DO WHILE ! Int_IP->(EOF()) .AND. Int_IP->NIPPO_NUM == nPO_Num .AND. Int_IP->NIPSEQ_PO == nSeq_PO

  IF !lParam
     IncProc(STR0551+nPO_Num+" "+STR0296+": "+Int_IP->NIPPOSICAO)
  EndIf

  IF EasyEntryPoint("IN100CLI")
     ExecBlock("IN100CLI",.F.,.F.,"LERIP")
  ENDIF

  IF EMPTY(Int_IP->NIPPOSICAO)
     EVAL(bMsg,STR0338+STR0546) //"POSICAO DO ITEM NAO INFORMADO
  ELSE
     Int_IP->NIPPOSICAO:=STRZERO(VAL(Int_IP->NIPPOSICAO),nTamPosicao)
  ENDIF

  IF EMPTY(ALLTRIM(Int_IP->NIPCC))
     IF ! lModelo
        EVAL(bMsg,_LIT_R_CC+STR0300+STR0546)  // NAO INFORMADO
     ELSE
        Int_IP->NIPCC:=SWU->WU__CC
        EVAL(bMsg,STR0550+STR0547,.T.) // DO MODELO CENTRO_CUSTO
     ENDIF
  ENDIF

  cIncCC:=cIncCI:=cIncFA:=' '

  IF EMPTY(Int_IP->NIPTIPO)
     EVAL(bMsg,STR0339+STR0546) //"TIPO DO ITEM NAO INFORMADO
  ELSEIF Int_IP->NIPTIPO $ 'i.a.e'
     Int_IP->NIPTIPO := UPPER(Int_IP->NIPTIPO)
  ELSEIF ! Int_IP->NIPTIPO $ 'I.A.E'
     EVAL(bmsg,STR0548+STR0549) // TIPO_INT INVALIDO
  ENDIF

  cCod_I:= AvKey( LEFT(Int_IP->NIPCOD_I,nLenItem), "B1_COD")            //NCF - 28/03/2011 - Acerto na chave do Item

  cIncCI:=IN100VerItem(LEFT(Int_IP->NIPCOD_I,nLenItem))

  SW3->(DBSETORDER(8))
  cChavePes:=(AVKEY(nPO_Num,"W3_PO_NUM")+Int_IP->NIPPOSICAO)
  SW3->(DBSEEK(cFilSW3+cChavePes))                                                                    //MJB-SAP-0401
 
  //NCF - 04/11/2010
  If Int_IP->NIPTIPO # INCLUSAO .And. SW3->(!EOF()) .And. SW3->W3_QTDE # Val(Int_IP->NIPQTDE)  
     If lCambLiq
        EVAL(bMsg,"("+cChavePes+") "+STR0780+CHR(13)+CHR(10)+STR0781) // (###)Quantidade do item não pode ser alterada. Motivo: PO possui câmbio de adiantamento com parcela baixada
     EndIf
  EndIf
 
  IF SW3->(EOF()) .AND. Int_IP->NIPTIPO#INCLUSAO
     If Int_IP->NIPTIPO = ALTERACAO .AND. lIncAltPO
        Int_IP->NIPTIPO:= 'I'
     Else
        EVAL(bMsg,STR0340+": ("+cChavePes+")" ) //"ITEM DO P.O. NAO CADASTRADO "
     Endif
  
  ELSEIF ! SW3->(EOF()) .AND. Int_IP->NIPTIPO=INCLUSAO 
     EVAL(bMsg,STR0342+": ("+cChavePes+")") //" ITEM DO P.O. JA CADASTRADO"

  ELSEIF ! SW3->(EOF()) .AND. Int_IP->NIPTIPO#INCLUSAO 
     lAchou = .T.
     NrReg := SW3->W3_REG
     Int_IP->NIPREG :=STR(NrReg,nTamReg,0)

     //NOPADO POR FDR - 29/04/13 - PERMITIR ALTERAÇÃO DA UNIDADE REQ.(SW3->W3_CC)
     /*If Int_IP->NIPCC # SW3->W3_CC
        EVAL(bMsg,STR0013) // "UNID.REQ. NAO PODE SER ALTERADA "
     Endif*/

     If Int_IP->NIPSI_NUM # SW3->W3_SI_NUM
        EVAL(bMsg,STR0040) // "SI NAO PODE SER ALTERADA "
     ENDIF
  ENDIF

  IF Int_IP->NIPTIPO == INCLUSAO
     nRegNIP:=Int_IP->(RECNO())
     cChavePO :=RTRIM(Int_IP->NIPPO_NUM)
     cPosPO:=Int_IP->NIPPOSICAO

     If (cOcorIP:=ASCAN(aTabIP,{|chave| chave[1]==Int_IP->NIPPOSICAO .and. chave[3] == Int_IP->NIPPO_NUM })) # 0
        If aTabIP[cOcorIP,2] # nRegNIP
           EVAL(bMsg,STR0343)
        ENDIF
     Else
        AADD(aTabIP,{Int_IP->NIPPOSICAO, nRegNIP, Int_IP->NIPPO_NUM})
     EndIf
     
     cChaveNIP:=Int_IP->NIPCC+Int_IP->NIPSI_NUM
     cChavePO :=RTRIM(Int_IP->NIPPO_NUM)

     If cAuxCC+cAuxSI # Int_IP->NIPCC+Int_IP->NIPSI_NUM
        If (cOcorSI:=ASCAN(aTabSI,{|chave| chave[1]==Int_IP->NIPCC+Int_IP->NIPSI_NUM})) # 0
           lSI_Invalida := aTabSI[cOcorSI,2] 
           lLESI := .T.
        Else
           AADD(aTabSI,{Int_IP->NIPCC+Int_IP->NIPSI_NUM, .F.})
           lLESI := .F.           
        EndIf
    
     EndIf
    
     IF ! lLESI
        cAuxCC:=Int_IP->NIPCC
        cAuxSI:=Int_IP->NIPSI_NUM
        Int_IP->(DBSETORDER(2))
        Int_IP->(DBSEEK(cChaveNIP))
        DO WHILE ! Int_IP->(EOF()) .AND. cChaveNIP=(Int_IP->NIPCC+Int_IP->NIPSI_NUM)
           IF cChavePO # RTRIM(Int_IP->NIPPO_NUM) 
              lSI_Invalida := .T.
              EXIT
           ENDIF
           Int_IP->(DBSKIP())
        ENDDO

        Int_IP->(DBSETORDER(1))
        Int_IP->(DBGOTO(nRegNIP))

        SW1->(DBSETORDER(1))
                
        SW1->(DBSEEK(cFilSW1+cChaveNIP))                                                              //MJB-SAP-0401
        DO WHILE ! SW1->(EOF()).AND.cChaveNIP=(SW1->W1_CC+SW1->W1_SI_NUM).AND.cFilSW1==SW1->W1_FILIAL //MJB-SAP-0401
           IF cChavePO # RTRIM(SW1->W1_PO_NUM) .AND. SW1->W1_SEQ # 0
              lSI_Invalida := .T.
              EXIT
           ENDIF
           SW1->(DBSKIP())
        ENDDO
        lLESI := .T.
     ENDIF

     If EasyEntryPoint("IN100CLI")
        ExecBlock("IN100CLI",.F.,.F.,"VAL_DE_SI")//RJB 22/12/2002
     EndIf

     IF lSI_Invalida
        EVAL(bMsg,STR0344+": ("+cChaveNIP+")") //"S.I. PERTENCE A OUTRO P.O. "
     ENDIF
  ENDIF

  IF Int_IP->NIPTIPO#EXCLUSAO
     IF EMPTY(ALLTRIM(Int_IP->NIPFLUXO)) .AND. Int_IP->NIPTIPO=ALTERACAO
        Int_IP->NIPFLUXO := SW3->W3_FLUXO
     ELSE
        IF EMPTY(Int_IP->NIPFLUXO)
           IF ! EMPTY(SB1->B1_ANUENTE)
              Int_IP->NIPFLUXO := IF(SB1->B1_ANUENTE$cSim,"1","7")
           ELSE
              Int_IP->NIPFLUXO := "7"
           ENDIF
        ELSEIF ! Int_IP->NIPFLUXO$"1.7"
           EVAL(bMsg,STR0345) //" FLUXO DO ITEM INCORRETO "
        ENDIF
     ENDIF
  ENDIF

  If Int_IP->NIPFLUXO == "1"
     lPesqED4 := .F.
  Else
     lPesqED4 := .T.
  EndIf

  IF (Int_IP->NIPTIPO=ALTERACAO .OR. Int_IP->NIPTIPO=EXCLUSAO) .AND. ! SW3->(EOF()) .AND. lAchou
     IF SW3->W3_FLUXO="1"
        If (!lAlteraPO .or. Int_IP->NIPTIPO=EXCLUSAO .or. Int_IP->NIPFLUXO == "7") .and.;
           SW3->W3_QTDE#SW3->W3_SALDO_Q
           EVAL(bMsg,STR0346) //"ITEM EM ANDAMENTO"
        ElseIf Int_IP->NIPTIPO=ALTERACAO
           nRecW3Aux:=SW3->(RECNO())
           DO WHILE ! SW3->(EOF()) .AND. cFilSW3=SW3->W3_FILIAL .AND. cChavePes == (SW3->W3_PO_NUM+SW3->W3_POSICAO) //MJB-SAP-0401
              If SW3->W3_SEQ = 0
                 If (SW3->W3_QTDE - SW3->W3_SALDO_Q) > Val(Int_IP->NIPQTDE)
                    EVAL(bMsg,STR0346) //"ITEM EM ANDAMENTO"
                 //** AAF 07/08/08 - Não permitir alterar código de item para item com saldo em uso
                 Elseif SW3->W3_QTDE <> SW3->W3_SALDO_Q .AND. AllTrim(Int_IP->NIPCOD_I) <> AllTrim(SW3->W3_COD_I)
                    EVAL(bMsg,STR0346) //"ITEM EM ANDAMENTO"
                 //**
                 //ACB - 13/12/2010 - Verifica se o item esta embarcado e validando o fabricante
                 Elseif SW3->W3_QTDE <> SW3->W3_SALDO_Q .AND. !Empty(Int_IP->NIPFABR) .AND. AllTrim(Int_IP->NIPFABR) <> AllTrim(SW3->W3_FABR)
                    EVAL(bMsg,STR0346+": "+SW5->W5_COD_I) //"ITEM EM ANDAMENTO"
                 //**
                 EndIf
                 Exit
              EndIf
              SW3->(DBSKIP())
           ENDDO
           SW3->(DBGOTO(nRecW3Aux))
        EndIf
     ELSEIF SW3->W3_FLUXO="7"
        nRecW3Aux:=SW3->(RECNO())
        DO WHILE ! SW3->(EOF()) .AND. cFilSW3=SW3->W3_FILIAL .AND. cChavePes == (SW3->W3_PO_NUM+SW3->W3_POSICAO) //MJB-SAP-0401
           IF SW3->W3_SEQ # 0
              SW5->(DBSETORDER(8))
              SW5->(DBSEEK(cFilSW5+SW3->W3_PGI_NUM+cChavePes))                                        //MJB-SAP-0401
              WHILE ! SW5->(EOF()) .AND. cFilSW5 = SW5->W5_FILIAL .AND.;                              //MJB-SAP-0401
                    (SW3->W3_PGI_NUM+SW3->W3_PO_NUM+SW3->W3_POSICAO) == (SW5->W5_PGI_NUM+SW5->W5_PO_NUM+SW5->W5_POSICAO) //MJB-SAP-0401

                 IF SW3->W3_REG == SW5->W5_REG .AND. SW5->W5_SEQ==0
                    IF (!lAlteraPO .or. Int_IP->NIPTIPO=EXCLUSAO .or. Int_IP->NIPFLUXO == "1") .and. SW5->W5_QTDE # SW5->W5_SALDO_Q
                       EVAL(bMsg,STR0346) //"ITEM EM ANDAMENTO"
                       lPesqED4:=.F.
                    ElseIf Int_IP->NIPTIPO=ALTERACAO .and. (SW5->W5_QTDE - SW5->W5_SALDO_Q) > Val(Int_IP->NIPQTDE)
                       EVAL(bMsg,STR0346) //"ITEM EM ANDAMENTO"
                       lPesqED4:=.F.
                    //** AAF 07/08/08 - Não permitir alterar código de item para item com saldo em uso
                    Elseif SW5->W5_QTDE <> SW5->W5_SALDO_Q .AND. AllTrim(Int_IP->NIPCOD_I) <> AllTrim(SW5->W5_COD_I)
                       EVAL(bMsg,STR0346+": "+SW5->W5_COD_I) //"ITEM EM ANDAMENTO"
                    //**
   					//ACB - 13/12/2010 - Verifica se o item esta embarcado e validando o fabricante
                    Elseif SW5->W5_QTDE <> SW5->W5_SALDO_Q .AND. !Empty(Int_IP->NIPFABR) .AND. AllTrim(Int_IP->NIPFABR) <> AllTrim(SW3->W3_FABR)
                       EVAL(bMsg,STR0346+": "+SW5->W5_COD_I) //"ITEM EM ANDAMENTO"
                    ENDIF
                    EXIT
                 ENDIF
                 SW5->(DBSKIP())
              EndDo
              exit
           ENDIF
           SW3->(DBSKIP())
        ENDDO
        SW3->(DBGOTO(nRecW3Aux))
     ENDIF
  ENDIF

  If lIntDraw .and. lPesqED4 .and. lAnuDrawback .and. Int_IP->NIPTIPO=INCLUSAO
//     ED4->(dbSeek(cFilED4+Left(Int_IP->NIPCOD_I,nLenItem)+Str(1,15,5)+"!",.T.))
     cCGC     := BuscaCNPJ(Int_PO->NPOIMPORT)
     cItem    := Left(Int_IP->NIPCOD_I,nLenItem)
     aItensPrin := {}
     If lTipoItem
        aItensPrin := IG400AllItens("I",cItem)
     EndIf
     SY6->(dbSeek(cFilSY6+Int_PO->NPOCOND_PA+Int_PO->NPODIAS_PA))
     cCamb := If(SY6->Y6_TIPOCOB<>"4","1","2")
     ED4->(dbSetOrder(3))
     ED4->(dbSeek(cFilED4+cCGC+cItem+cCamb+DtoS(dDataBase),.T.))
     Do While !ED4->(EOF()) .and. ED4->ED4_FILIAL==cFilED4 .and. ED4->ED4_CNPJIM==cCGC .and. ED4->ED4_ITEM==cItem .and.;
     ED4->ED4_CAMB==cCamb
        If ED0->ED0_AC <> ED4->ED4_AC .or. ED0->ED0_FILIAL <> cFilED0
           ED0->(dbSeek(cFilED0+ED4->ED4_AC))
        EndIf
        If !Empty(ED4->ED4_AC) .and. (ED4->ED4_QT_LI > 0 .or.;
        (ED0->ED0_TIPOAC=="06" .and. ED4->ED4_NCM = "99999999" .and. ED4->ED4_VL_LI > 0)) .and. Empty(ED0->ED0_DT_ENC)
           Int_IP->NIPFLUXO := "1"
           Exit
        EndIf
        ED4->(dbSkip())
     EndDo
     
     If Int_IP->NIPFLUXO != "1"
        For ni := 1  to  Len(aItensPrin)
           If !Empty(aItensPrin[ni][2])
              cUnid := BUSCA_UM(aItensPrin[ni][1]+Left(Int_IP->NIPFABR,nLenFabr)+Left(Int_PO->NPOFORN,nLenForn),Left(Int_IP->NIPCC,nLenCC)+Left(Int_IP->NIPSI_NUM,nLenSI))
              ED4->(dbSetOrder(7))
              If ED4->(dbSeek(cFilED4+aItensPrin[ni][2]+AvKey(Int_IP->NIPTEC,"ED4_NCM")+aItensPrin[ni][1]+cUnid) )
                 If ED0->ED0_AC <> ED4->ED4_AC .or. ED0->ED0_FILIAL <> cFilED0
                    ED0->(dbSeek(cFilED0+ED4->ED4_AC))
                 EndIf
                 If !Empty(ED4->ED4_AC) .and. (ED4->ED4_QT_LI > 0 .or.;
                 (ED0->ED0_TIPOAC=="06" .and. ED4->ED4_NCM = "99999999" .and. ED4->ED4_VL_LI > 0)) .and. Empty(ED0->ED0_DT_ENC)
                    Int_IP->NIPFLUXO := "1"
                    Exit
                 EndIf
              EndIf
           Else
              ED4->(dbSetOrder(3))
              ED4->(dbSeek(cFilED4+cCGC+aItensPrin[ni][1]+cCamb+DtoS(dDataBase),.T.))  //SoftSeek
              If ED0->ED0_AC <> ED4->ED4_AC .or. ED0->ED0_FILIAL <> cFilED0
                 ED0->(dbSeek(cFilED0+ED4->ED4_AC))
              EndIf
              Do While !ED4->(EOF()) .and. ED4->ED4_FILIAL==cFilED4 .and. ED4->ED4_CNPJIM==cCGC .and. ED4->ED4_ITEM==aItensPrin[ni][1] .and.;
              ED4->ED4_CAMB==cCamb
                 If ED0->ED0_AC <> ED4->ED4_AC .or. ED0->ED0_FILIAL <> cFilED0
                    ED0->(dbSeek(cFilED0+ED4->ED4_AC))
                 EndIf
                 If !Empty(ED4->ED4_AC) .and. (ED4->ED4_QT_LI > 0 .or.;
                 (ED0->ED0_TIPOAC=="06" .and. ED4->ED4_NCM = "99999999" .and. ED4->ED4_VL_LI > 0)) .and. Empty(ED0->ED0_DT_ENC)
                    Int_IP->NIPFLUXO := "1"
                    Exit
                 EndIf
                 ED4->(dbSkip())
              EndDo
           EndIf
        Next ni
     EndIf

  EndIf
  
  IF (Int_IP->NIPTIPO=ALTERACAO .OR. Int_IP->NIPTIPO=EXCLUSAO) .AND. ! SW3->(EOF()) .AND. lAchou
     IF SW3->W3_FLUXO="1"
        If (!lAlteraPO .or. Int_IP->NIPTIPO=EXCLUSAO .or. Int_IP->NIPFLUXO == "7") .and.;
           SW3->W3_QTDE#SW3->W3_SALDO_Q
           EVAL(bMsg,STR0346) //"ITEM EM ANDAMENTO"
        ElseIf Int_IP->NIPTIPO=ALTERACAO
           nRecW3Aux:=SW3->(RECNO())
           DO WHILE ! SW3->(EOF()) .AND. cFilSW3=SW3->W3_FILIAL .AND. cChavePes == (SW3->W3_PO_NUM+SW3->W3_POSICAO) //MJB-SAP-0401
              If SW3->W3_SEQ = 0
                 If (SW3->W3_QTDE - SW3->W3_SALDO_Q) > Val(Int_IP->NIPQTDE)
                    EVAL(bMsg,STR0346) //"ITEM EM ANDAMENTO"
                 //** AAF 07/08/08 - Não permitir alterar código de item para item com saldo em uso
                 Elseif SW3->W3_QTDE <> SW3->W3_SALDO_Q .AND. AllTrim(Int_IP->NIPCOD_I) <> AllTrim(SW3->W3_COD_I)
                    EVAL(bMsg,STR0346) //"ITEM EM ANDAMENTO"
                 //**
					//ACB - 13/12/2010 - Verifica se o item esta embarcado e validando o fabricante
                 Elseif SW3->W3_QTDE <> SW3->W3_SALDO_Q .AND. !Empty(Int_IP->NIPFABR) .AND. AllTrim(Int_IP->NIPFABR) <> AllTrim(SW3->W3_FABR)
                    EVAL(bMsg,STR0346+": "+SW5->W5_COD_I) //"ITEM EM ANDAMENTO"
                 EndIf
                 Exit
              EndIf
              SW3->(DBSKIP())
           ENDDO
           SW3->(DBGOTO(nRecW3Aux))
        EndIf
     ELSEIF SW3->W3_FLUXO="7"
        nRecW3Aux:=SW3->(RECNO())
        DO WHILE ! SW3->(EOF()) .AND. cFilSW3=SW3->W3_FILIAL .AND. cChavePes == (SW3->W3_PO_NUM+SW3->W3_POSICAO) //MJB-SAP-0401
           IF SW3->W3_SEQ # 0
              SW5->(DBSETORDER(8))
              SW5->(DBSEEK(cFilSW5+SW3->W3_PGI_NUM+cChavePes))                                        //MJB-SAP-0401
              WHILE ! SW5->(EOF()) .AND. cFilSW5 = SW5->W5_FILIAL .AND.;                              //MJB-SAP-0401
                    (SW3->W3_PGI_NUM+SW3->W3_PO_NUM+SW3->W3_POSICAO) == (SW5->W5_PGI_NUM+SW5->W5_PO_NUM+SW5->W5_POSICAO) //MJB-SAP-0401

                 IF SW3->W3_REG == SW5->W5_REG .AND. SW5->W5_SEQ==0
                    IF (!lAlteraPO .or. Int_IP->NIPTIPO=EXCLUSAO .or. Int_IP->NIPFLUXO == "1") .and. SW5->W5_QTDE # SW5->W5_SALDO_Q
                       EVAL(bMsg,STR0346) //"ITEM EM ANDAMENTO"
                       lPesqED4:=.F.
                    ElseIf Int_IP->NIPTIPO=ALTERACAO .and. (SW5->W5_QTDE - SW5->W5_SALDO_Q) > Val(Int_IP->NIPQTDE)
                       EVAL(bMsg,STR0346) //"ITEM EM ANDAMENTO"
                       lPesqED4:=.F.
                    //** AAF 07/08/08 - Não permitir alterar código de item para item com saldo em uso
                    Elseif SW5->W5_QTDE <> SW5->W5_SALDO_Q .AND. AllTrim(Int_IP->NIPCOD_I) <> AllTrim(SW5->W5_COD_I)
                       EVAL(bMsg,STR0346+": "+SW5->W5_COD_I) //"ITEM EM ANDAMENTO"
					//ACB - 13/12/2010 - Verifica se o item esta embarcado e validando o fabricante                       
                    Elseif SW5->W5_QTDE <> SW5->W5_SALDO_Q .AND. !Empty(Int_IP->NIPFABR) .AND. AllTrim(Int_IP->NIPFABR) <> AllTrim(SW3->W3_FABR)
                       EVAL(bMsg,STR0346+": "+SW5->W5_COD_I) //"ITEM EM ANDAMENTO"
                    //**
                    ENDIF
                    EXIT
                 ENDIF
                 SW5->(DBSKIP())
              EndDo
              exit
           ENDIF
           SW3->(DBSKIP())
        ENDDO
        SW3->(DBGOTO(nRecW3Aux))
     ENDIF
  ENDIF
  
  lAchouW1 = .F.
  nRecW1:=0
  SW1->(DBSETORDER(2))
  If SW1->(DBSEEK(cFilSW1+AVKEY(Int_IP->NIPPO_NUM, "W1_PO_NUM")+Int_IP->NIPPOSICAO))                                      //MJB-SAP-0401
     nRecW1:=SW1->(Recno())
           lAchouW1 = .t.
  ENDIF

  SW1->(DBSETORDER(1))

  IF ! lAchouW1 .AND. Int_IP->NIPTIPO#INCLUSAO
     EVAL(bMsg,STR0553+STR0347+": ("+Int_IP->NIPPO_NUM+Int_IP->NIPPOSICAO+")") //NUM_PO ITEM DA S.I. NAO CADASTRADO"
  ELSEIF lAchouW1 .AND. Int_IP->NIPTIPO=INCLUSAO
     EVAL(bMsg,STR0553+STR0348+": ("+Int_IP->NIPPO_NUM+Int_IP->NIPPOSICAO+")") //NUM_PO ITEM DA S.I. JA CADASTRADO"
  ENDIF

  IF Int_IP->NIPTIPO # EXCLUSAO

     IF lNIPTEC .AND. !EMPTY(Int_IP->NIPTEC) .AND. !Int_Param->NPAINC_NBM .AND. ;
        !SYD->(DBSEEK(cFilSYD+AVKey(Int_IP->NIPTEC,"YD_TEC")+Int_IP->NIPEX_NCM+Int_IP->NIPEX_NBM))
        EVAL(bmsg,STR0140+STR0544+": ("+Int_IP->NIPTEC+Int_IP->NIPEX_NCM+Int_IP->NIPEX_NBM+")") //"NCM SEM CADASTRO
     ENDIF
     //ACB - 16/12/2010 - Trecho do codigo jogado para cima devido a validação de fabricante.                                       
	 If Empty(Alltrim(Int_IP->NIPFABR)) .AND. Int_IP->NIPTIPO="A" 
        Int_IP->NIPFABR := SW3->W3_FABR
     EndIf

     cIncFA:=IN100VerFF('1',Int_IP->NIPFABR)

     If Empty(Alltrim(Int_IP->NIPFABR)) .AND. Int_IP->NIPTIPO="A" 
        Int_IP->NIPFABR := SW3->W3_FABR
     EndIf

     SA5->(DBSETORDER(3))
     IF ! SA5->(DBSEEK(cFilSA5+cCod_I+Int_IP->NIPFABR+cForn))
        IF ! Int_Param->NPAINC_LI                                         //MJB-SAP-1200
           //EVAL(bMsg,STR0349+STR0544+": ("+cCod_I+Int_IP->NIPFABR+cForn+")") //'LIGACAO ITEM/FABR/FORN SEM CADASTRO
           EVAL(bMsg,STR0349+STR0544+": (Item: "+cCod_I+" Fabr.: "+Int_IP->NIPFABR+" Forn.: "+cForn+")")
        ENDIF
     ENDIF
         
     SA5->(DBSETORDER(1))
     IN100VerQtDt(Int_IP->NIPQTDE,bDtEntr)

     IF EMPTY(ALLTRIM(Int_IP->NIPCLASS))
        IF ! lModelo
           EVAL(bMsg,STR0350+STR0549) //'TIPO DE MATERIAL INVALIDO
        ELSE
           Int_IP->NIPCLASS:=SWU->WU_TIPOSI
           EVAL(bMsg,STR0350+STR0547,.T.) //'TIPO DE MATERIAL DO MODELO
        ENDIF
     ELSEIF ! SX5->(dbSeek(cFilSX5+'Y1'+Int_IP->NIPCLASS))
           EVAL(bMsg,STR0350+STR0544+": ("+Int_IP->NIPCLASS+")") //'TIPO DE MATERIAL SEM CADASTRO
     ENDIF
  ENDIF

  IF EMPTY(Int_IP->NIPCC) .OR. EMPTY(Int_IP->NIPSI_NUM)
     EVAL(bMsg,_LIT_R_CC+STR0300+STR0549)  // INVALIDO

  ELSEIF SW0->(DBSEEK(cFilSW0+Int_IP->NIPCC+Int_IP->NIPSI_NUM))                                       //MJB-SAP-0401
         IF Int_PO->NPOTIPO == INCLUSAO
        EVAL(bMsg,_LIT_R_CC+STR0300+STR0545+": ("+Int_IP->NIPCC+Int_IP->NIPSI_NUM+")")  // COM CADASTRO
         ENDIF

  ELSEIF ! SY3->(DBSEEK(cFilSY3+Int_IP->NIPCC))
      IF ! Int_Param->NPAINC_CC
         EVAL(bMsg,STR0550+STR0544+": ("+Int_IP->NIPCC+")")  // SEM CADASTRO CENTRO_CUSTO
      ELSE
         cIncCC:='S'
      ENDIF

  ENDIF

  IF Int_IP->NIPTIPO # EXCLUSAO
     IF ! EMPTY(ALLTRIM(Int_IP->NIPDT_EMB))
        IF ! IN100CTD(Int_IP->NIPDT_EMB,.T.)
           EVAL(bMsg,STR0563+STR0549) // DATA_EMBARQUE INVALIDO
        ENDIF
     ELSEIF ! lModelo
           EVAL(bMsg,STR0563+STR0546)  // DATA_EMBARQUE NAO INFORMADO
     ELSE
         Int_IP->NIPDT_EMB:=IN100DTC(dDataBase+SWU->WU_DIAS_EM)
         EVAL(bMsg,STR0563+STR0547,.T.) // DATA_EMBARQUE DO MODELO
     ENDIF

     IF IN100NaoNum(Int_IP->NIPPRECO)
        EVAL(bMsg,STR0351+STR0549) //'PRECO UNITARIO INVALIDO
     ENDIF

     cIncFA:=IN100VerFabr(cIncFA,Int_IP->NIPFABR_01,'-1',' 2o.')
     cIncFA:=IN100VerFabr(cIncFA,Int_IP->NIPFABR_02,Int_IP->NIPFABR_01,' 3o.')
     cIncFA:=IN100VerFabr(cIncFA,Int_IP->NIPFABR_03,Int_IP->NIPFABR_02,' 4o.')
     cIncFA:=IN100VerFabr(cIncFA,Int_IP->NIPFABR_04,Int_IP->NIPFABR_03,' 5o.')
     cIncFA:=IN100VerFabr(cIncFA,Int_IP->NIPFABR_05,Int_IP->NIPFABR_04,' 6o.')
  ENDIF

  IF Int_IP->NIPTIPO # EXCLUSAO .AND. (Int_IP->NIPTIPO == INCLUSAO .OR. LEFT(Int_IP->NIPCOD_I,nLenItem) # SW3->W3_COD_I) .AND. cErro = NIL
  
     IF (cOcor:=ASCAN(aTabReg,{|chave| chave[1]==Int_IP->NIPCC+Int_IP->NIPSI_NUM+LEFT(Int_IP->NIPCOD_I,nLenItem)})) # 0
        NrReg := aTabReg[cOcor,2] + 1
        aTabReg[cOcor,2] := NrReg
     ELSE
        cChave:=Int_IP->NIPCC+Int_IP->NIPSI_NUM+LEFT(Int_IP->NIPCOD_I,nLenItem)
        cFor  :=Int_IP->NIPCC+Int_IP->NIPSI_NUM
        NrReg :=IN100VerReg(cChave,;
                {||SW1->W1_CC+SW1->W1_SI_NUM+SW1->W1_COD_I=cChave .AND. SW1->W1_FILIAL==cFilSW1})     //MJB-SAP-0401

        NrReg += 1

        AADD(aTabReg,{Int_IP->NIPCC+Int_IP->NIPSI_NUM+LEFT(Int_IP->NIPCOD_I,nLenItem),NrReg})
     ENDIF
     IF NrReg > 9999
        NrReg :=0
        EVAL(bMsg,STR0352) //"ITEM REPETIU MAIS DE 9999 VEZES "
     ENDIF
  ELSEIF Int_IP->NIPTIPO == ALTERACAO
     
     IF nRecW1 # 0
        SW1->(DBGOTO(nRecW1))
        NrReg:=SW1->W1_REG
     ELSE
        EVAL(bMsg,_LIT_R_CC+STR0300+STR0546)  // NAO INFORMADO
     ENDIF
  ENDIF

  IF EasyEntryPoint("IN100CLI")
     ExecBlock("IN100CLI",.F.,.F.,"VALIP")
  ENDIF

  IF cErro # NIL
     Int_IP->NIPMSG:=cErro ; cErro:= NIL ; lDetMsg:=.T. ; cAviso:= NIL
     Int_IP->NIPINT_OK := "F"
  ELSE
     Int_IP->NIPINT_OK := "T"
     Int_IP->NIPREG    :=STR(NrReg,nTamReg,0)
     Int_IP->NIPINCLUI :=cIncCI+cIncFA+cIncCC
     IF cAviso # NIL
///     Int_IP->NIPMSG:=cAviso ; cAviso:= NIL ; lDetMsg:=.T.
        Int_IP->NIPMSG:=cAviso ; cAviso:= NIL
     ENDIF
  ENDIF

  if ValType(bUpDate) == "B"
     cFuncao:="IP"
     Eval(bUpDate, Int_IP->NIPMSG,Int_IP->NIPINT_OK)
     cFuncao:="PO"
  endif


  nFob_Tot+=VAL( STR( VAL(Int_IP->NIPPRECO) * VAL(Int_IP->NIPQTDE) ,nLenItem,2 ) )
  If Int_PO->NPOITEM_OK = "T" .AND. ! Int_IP->NIPINT_OK = "T"
     Int_PO->NPOITEM_OK:="F"
  EndIf

  If EasyEntryPoint("IN100CLI")
     ExecBlock("IN100CLI",.F.,.F.,"VER_ERRO_IP")//AWR 22/08/2001
  EndIf
  
  Int_IP->(DBSKIP())
ENDDO
If lIntDraw
   ED4->(dbSetOrder(1))
   ED0->(dbSetOrder(1))
EndIf

Int_PO->NPOFOB_TOT:= nFob_Tot

IF lDetMsg .AND. Int_PO->NPOTIPO == INCLUSAO
   Int_PO->NPOINT_OK := "F"
ENDIF

IF EMPTY(ALLTRIM(Int_PO->NPOMSG)) .AND. lDetMsg
   Int_PO->NPOMSG :=STR0354 //".....VIDE ITENS"
ENDIF

IF Int_PO->NPOINT_OK = "T"
   nResumoCer+=1
ELSE
   nResumoErr+=1
ENDIF

IF Int_PO->NPOINT_OK = "T" .AND. Int_PO->NPOTIPO='A' .AND. ! Int_PO->NPOITEM_OK = "T"
   nResumoAlt+=1
ENDIF

IF Int_PO->NPOINT_OK = "T"     .AND.;
   Int_PO->NPOTIPO = ALTERACAO .AND.;
   EasyEntryPoint("ICPADIN1")

   // Rdmake Padrao para que os dados da capa do PO sejam mantidos ignorando os dados do TXT

   ExecBlock("ICPADIN1",.F.,.F.)

ENDIF

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"VER_PO_IP")
EndIf

RETURN NIL


*-----------------------------------------------------------------------------
FUNCTION IN100Capa(Dt,MsgDt,bLocal,bComprador,cTipoInt)
*-----------------------------------------------------------------------------
LOCAL nComprador:=EVAL(bComprador), LocalEnt:=EVAL(bLocal)

IF ! EMPTY(ALLTRIM(DT)) .AND. cTipoInt = ALTERACAO
     IF EMPTY(IN100CTD(Dt,.T.))
          EVAL(bMsg,MsgDt+STR0549)  // INVALIDO
     ENDIF
ELSEIF cTipoInt = INCLUSAO
     IF EMPTY(IN100CTD(Dt,.T.))
         EVAL(bMsg,MsgDt+STR0549) // INVALIDO
     ENDIF
ENDIF

IF EMPTY(ALLTRIM(LocalEnt)) .AND. cTipoInt # ALTERACAO
   IF ! lModelo
      EVAL(bMsg,STR0554+STR0546)  // LOCAL_ENTREGA NAOINFORMADO
   ELSE
      EVAL(bLocal,SWU->WU__POLE)
      LocalEnt:=SWU->WU__POLE
      EVAL(bMsg,STR0554+STR0547,.T.)  // LOCAL_ENTREGA DOMODELO
   ENDIF
ENDIF

IF ! EMPTY(ALLTRIM(LocalEnt))
   IF ! SY2->(DBSEEK(cFilSY2+LocalEnt)) .AND. ! Int_Param->NPAINC_LE
      EVAL(bMsg,STR0554+STR0544+": ("+LocalEnt+")")  // LOCAL_ENTREGA SEMCADASTRO
   ENDIF
ENDIF

IF EMPTY(ALLTRIM(nComprador)) .AND. cTipoInt # ALTERACAO
   IF ! lModelo
      EVAL(bMsg,STR0555+STR0546)  // COMPRADOR NAOINFORMADO
   ELSE
      EVAL(bComprador,SWU->WU_COMPRA)
      nComprador:=SWU->WU_COMPRA
      EVAL(bMsg,STR0555+STR0547,.T.)  // COMPRADOR DOMODELO
   ENDIF
ENDIF

IF ! EMPTY(ALLTRIM(nComprador))
   SY1->(dbsetorder(1))
   IF ! SY1->(DBSEEK(cFilSY1+nComprador)) .AND. ! Int_Param->NPAINC_CO
      EVAL(bMsg,STR0555+STR0544+": ("+nComprador+")")  // COMPRADOR SEMCADASTRO
   ENDIF
ENDIF
RETURN .T.        

*---------------------------------------------------------------------------------------------------*
FUNCTION IN100POCheck(cForn)
*---------------------------------------------------------------------------------------------------*
LOCAL cVia, cOrigem, cDestino, nCliente
LOCAL c2Via, c2Origem, c2Destino, cCond_PA, cNDias_PA
LOCAL cSimb2 := BuscaDolar()//GetNewPar("MV_SIMB2","US$")
//MJB-SAP-1100 IF ! EMPTY(cVia:=ALLTRIM(Int_PO->NPOTIPO_EM))
IF ! EMPTY(cVia:=Int_PO->NPOTIPO_EM)                                      //MJB-SAP-1100 
   IF ! SYQ->(DBSEEK(cFilSYQ+cVia))                                       //MJB-SAP-0501
      EVAL(bMsg,STR0355+STR0544+": ("+Int_PO->NPOTIPO_EM+")") //"VIA DE TRANSPORTE SEM CADASTRO
   ENDIF
ELSEIF ! lModelo .AND. Int_PO->NPOTIPO # "A"
       EVAL(bMsg,STR0355+STR0546) //"VIA DE TRANSPORTE NAO INFORMADO
ELSEIF Int_PO->NPOTIPO # "A"
       cVia               :=SWU->WU_TIPO_EM
       Int_PO->NPOTIPO_EM :=SWU->WU_TIPO_EM
       EVAL(bMsg,STR0355+STR0547,.T.) //"VIA DE TRANSPORTE DO MODELO
ENDIF
cOrigem:=Int_PO->NPOORIGEM
IF ! EMPTY(ALLTRIM(Int_PO->NPOORIGEM))
   IF ! SYR->(DBSEEK(cFilSYR+cVia+cOrigem))                               //MJB-SAP-0501
      EVAL(bMsg,STR0356+": ("+cVia+cOrigem+")") //"ORIGEM INEXISTENTE P/ VIA DE TRANSPORTE"
   ENDIF
ELSEIF ! lModelo .AND. Int_PO->NPOTIPO # "A"
       EVAL(bMsg,STR0313+STR0546) //"ORIGEM NAO INFORMADO
ELSEIF Int_PO->NPOTIPO # "A"
       cOrigem          :=SWU->WU_ORIGEM
       Int_PO->NPOORIGEM:=SWU->WU_ORIGEM
       EVAL(bMsg,STR0313+STR0547,.T.) //"ORIGEM DOMODELO
ENDIF
cDestino:=Int_PO->NPODEST
IF !EMPTY(ALLTRIM(Int_PO->NPODEST))
   IF ! SYR->(DBSEEK(cFilSYR+cVia+cOrigem+cDestino))                      //MJB-SAP-0501
      EVAL(bMsg,STR0357+": ("+cVia+cOrigem+cDestino+")") //"ORIGEM/DESTINO INEXISTENTE P/ ESTA VIA"
   ENDIF
ELSEIF ! lModelo .AND. Int_PO->NPOTIPO # "A"
       EVAL(bMsg,STR0314+STR0546) //"DESTINO NAO INFORMADO
ELSEIF Int_PO->NPOTIPO # "A"
       cDestino         :=SWU->WU_DEST
       Int_PO->NPODEST  :=SWU->WU_DEST
       EVAL(bMsg,STR0314+STR0547,.T.) //"DESTINO DO MODELO
ENDIF

IF Int_PO->NPOTIPO = "A"
   IF SW2->(DBSEEK(cFilSW2+AVKEY(Int_PO->NPOPO_NUM,"W2_PO_NUM")))                            //MJB-SAP-0401
      IF EMPTY(ALLTRIM(cVia))
         c2Via:=SW2->W2_TIPO_EM
      ENDIF
      IF EMPTY(ALLTRIM(cOrigem))
         c2Origem:=SW2->W2_ORIGEM
      ENDIF
      IF EMPTY(ALLTRIM(cDestino))
         c2Destino:=SW2->W2_DEST
      ENDIF
      IF EMPTY(ALLTRIM(Int_PO->NPOCOND_PA))
         cCond_PA := SW2->W2_COND_PA
      ELSE
         cCond_PA := Int_PO->NPOCOND_PA
      ENDIF
      IF EMPTY(ALLTRIM(Int_PO->NPODIAS_PA))
         cNDias_PA := STR(SW2->W2_DIAS_PA,3,0)
      ELSE
         cNDias_PA:= STR(VAL(Int_PO->NPODIAS_PA),3,0)
      ENDIF
   ELSE
      cCond_PA := Int_PO->NPOCOND_PA
      cNDias_PA:= STR(VAL(Int_PO->NPODIAS_PA),3,0)
      c2Via    := cVia
      c2Origem := cOrigem
      c2Destino:= cDestino
   ENDIF
ELSE
   cCond_PA := Int_PO->NPOCOND_PA
   cNDias_PA:= STR(VAL(Int_PO->NPODIAS_PA),3,0)
   c2Via    := cVia
   c2Origem := cOrigem
   c2Destino:= cDestino
ENDIF

IF SY6->(IN100VerCad(Int_PO->NPOCOND_PA,STR0358,.F.)) //"CONDICAO PAGTO"
   Int_PO->NPOCOND_PA:=SWU->WU_COND_PA
   Int_PO->NPODIAS_PA:=STR(SWU->WU_DIAS_PA,3,0)
   cCond_PA := SWU->WU_COND_PA
   cNDias_PA:= STR(SWU->WU_DIAS_PA,3,0)
   EVAL(bMsg,STR0359+STR0547,.T.) //"CONDICAO PAGTO / No.DIAS DOMODELO
ENDIF

IF ! SY6->(DBSEEK(cFilSY6+cCond_PA+cNDias_PA))
   EVAL(bMsg,STR0359+STR0544+": ("+cCond_PA+cNDias_PA+")") //"CONDICAO PAGTO / No.DIAS SEMCADASTRO
ENDIF

IF SY4->(IN100VerCad(Int_PO->NPOAGENTE,STR0360,Int_Param->NPAINC_AG)) //"AGENTE EMBARCADOR"
   Int_PO->NPOAGENTE:=SWU->WU_AGENTE
   EVAL(bMsg,STR0360+STR0547,.T.) //"AGENTE EMBARCADOR DO MODELO
ENDIF

IF SY4->(IN100VerCad(Int_PO->NPOFORWARD,STR0291,Int_Param->NPAINC_FW,.T.)) //"FORWARDER"
   Int_PO->NPOFORWARD:=SWU->WU_FORWARD
   EVAL(bMsg,STR0291+STR0547,.T.) //"FORWARDER DO MODELO
ENDIF

IF SYT->(IN100VerCad(Int_PO->NPOIMPORT,STR0288,Int_Param->NPAINC_IMP)) //"IMPORTADOR"
   Int_PO->NPOIMPORT:=SWU->WU_IMPORT
   EVAL(bMsg,STR0288+STR0547,.T.) //"IMPORTADOR DO MODELO
ELSEIF !EMPTY(Int_PO->NPOIMPORT) .AND. SYT->(DBSEEK(cFilSYT+Int_PO->NPOIMPORT)) .AND. SYT->YT_IMP_CON == '2'
   EVAL(bMsg,STR0361+": ("+Int_PO->NPOIMPORT+")") //"IMPORT. JA CAD. COMO CONSIG."
ENDIF

IF SYT->(IN100VerCad(Int_PO->NPOCONSIG,STR0324,Int_Param->NPAINC_CON,.T.)) //"CONSIGNATARIO"
   Int_PO->NPOCONSIG:=SWU->WU_CONSIG
   EVAL(bMsg,STR0324+STR0547,.T.) //"CONSIGNATARIO DOMODELO
ELSEIF SYT->(DBSEEK(cFilSYT+Int_PO->NPOCONSIG)) .AND. SYT->YT_IMP_CON == '1'
   EVAL(bMsg,STR0362+": ("+Int_PO->NPOCONSIG+")") //"CONSIG. JA CAD. COMO IMPORT."
ENDIF

IF ! (EMPTY(Int_PO->NPOIMPORT) .AND. Int_PO->NPOTIPO = "A") .AND. ;
   ! (EMPTY(Int_PO->NPOCONSIG) .AND. Int_PO->NPOTIPO = "A")
   IF Int_PO->NPOIMPORT == Int_PO->NPOCONSIG
      EVAL(bMsg,STR0363+": ("+Int_PO->NPOCONSIG+")") //"IMPORT. IGUAL AO CONSIG."
   ENDIF
ENDIF

IF SYE->(IN100VerCad(Int_PO->NPOMOEDA,STR0240,.F.)) //"MOEDA"
   Int_PO->NPOMOEDA:=SWU->WU_MOEDA
   EVAL(bMsg,STR0240+STR0547,.T.) //"MOEDA DO MODELO
   IF ! SYE->(DBSEEK(cFilSYE+Int_PO->NPOMOEDA))
      EVAL(bMsg,STR0364+": ("+Int_PO->NPOMOEDA+")") //"MOEDA DO MODELO S/ TAXA DE CONVERSAO"
   ENDIF
ENDIF

IF !(EMPTY(Int_PO->NPOPARID_US) .AND. Int_PO->NPOTIPO = "A" )
   IF IN100NaoNum(Int_PO->NPOPARID_US)
      IF ! IN100CTD(Int_PO->NPODT_PAR,.T.)
         Int_PO->NPODT_PAR:=Int_PO->NPOPO_DT
      ENDIF                                
      
      IF EMPTY(cSimb2)
         cSimb2 := "US$"
      ENDIF              
           
      SYE->(DBSEEK(cFilSYE))
      Int_PO->NPOPARID_US:=STR(BuscaTaxa(AVKEY(Int_PO->NPOMOEDA,"YE_MOEDA"), IN100CTD(Int_PO->NPODT_PAR),,.F.) /;
                                BuscaTaxa(AVKEY(cSimb2,"YE_MOEDA"), IN100CTD(Int_PO->NPODT_PAR),,.F.),15,8 )

   ELSEIF ! IN100CTD(Int_PO->NPODT_PAR,.T.)
          Int_PO->NPODT_PAR:=Int_PO->NPOPO_DT
   ENDIF
ENDIF

IF !(EMPTY(ALLTRIM(Int_PO->NPOFREPPCC)) .AND. Int_PO->NPOTIPO = "A" .AND. ! lMODELO)
   IF !EMPTY(Int_PO->NPOFREPPCC)
      IF UPPER(Int_PO->NPOFREPPCC) # 'PP' .AND. UPPER(Int_PO->NPOFREPPCC) # 'CC'
         EVAL(bMsg,STR0564+STR0549) // TIPO_FRETE INVALIDO
      ELSE
         Int_PO->NPOFREPPCC:=UPPER(Int_PO->NPOFREPPCC)
      ENDIF
   ELSEIf Int_PO->NPOTIPO = "I" .AND. lModelo
      Int_PO->NPOFREPPCC:=SWU->WU_FREPPCC
      EVAL(bMsg,STR0564+STR0547,.T.) // TIPO_FRETE DO MODELO
   ELSEIf Int_PO->NPOTIPO = "I" .AND. ! lModelo
      EVAL(bMsg,STR0564+STR0546)  // TIPO_FRETE NAO INFORMADO
   ENDIF
   IF Int_PO->NPOFREPPCC = 'PP' .AND. VAL(Int_PO->NPOFRETEIN) = 0
      EVAL(bMsg,STR0365+STR0546) //"VALOR INT'L FRETE NAO INFORMADO
   ENDIF
ENDIF

IF VAL(Int_PO->NPOINLAND) < 0
   EVAL(bMsg,STR0366+STR0549) //"INLAND CHARG NEGATIVO INVALIDO
ENDIF

IF VAL(Int_PO->NPOPACKING) < 0
   EVAL(bMsg,STR0367+STR0549) //"PACKING CHARG NEGATIVO INVALIDO
ENDIF

IF VAL(Int_PO->NPODESCONT) < 0
   EVAL(bMsg,STR0368+STR0549) //"DESCONTO NEGATIVO INVALIDO
ENDIF

IF VAL(Int_PO->NPOFRETEIN) < 0
   EVAL(bMsg,STR0369+STR0549) //"INT'L FREIGHT NEGATIVO INVALIDO
ELSEIF VAL(Int_PO->NPOFRETEIN) > 0 .AND. Int_PO->NPOFREPPCC # 'PP'
   EVAL(bMsg,STR0323+STR0549+STR0370) //"TIPO FRETE"###" P/ INT'L FRETE INVALIDO
ENDIF

IN100VerFF('2',cForn)

IF !(EMPTY(ALLTRIM(Int_PO->NPONR_PRO)) .AND. Int_PO->NPOTIPO = "A" )
   IF !EMPTY(Int_PO->NPONR_PRO)
      IF !IN100CTD(Int_PO->NPODT_PRO,.T.)
         EVAL(bMsg,STR0371+STR0546) //"DATA DA PROFORMA NAO INFORMADO
      ENDIF
   ELSEIF ! EMPTY(IN100CTD(Int_PO->NPODT_PRO))
      EVAL(bMsg,STR0372+STR0546) //"No. DA PROFORMA NAO INFORMADO
   ENDIF
ENDIF

IF !EMPTY(nCliente:=ALLTRIM(Int_PO->NPOCLIENTE))
   IF ! SA1->(DBSEEK(cFilSA1+nCliente))
      EVAL(bMsg,STR0330+STR0544+": ("+nCliente+")") //"CLIENTE SEM CADASTRO
   ENDIF
ENDIF

IF ! EMPTY(ALLTRIM(Int_PO->NPOINCOTERM))
   IF ! SYJ->(DBSEEK(cFilSYJ+Int_PO->NPOINCOTERM))
      EVAL(bMsg,STR0331+STR0544+": ("+Int_PO->NPOINCOTERM+")") //"INCOTERMS SEM CADASTRO
   ENDIF
ENDIF

IF !(EMPTY(ALLTRIM(Int_PO->NPOOBS)) .AND. Int_PO->NPOTIPO = "A" )
   IF lModelo .AND. EMPTY(ALLTRIM(Int_PO->NPOOBS)) .AND. VAL(SWU->WU_OBS) > 0
      Int_PO->NPOOBS:=MSMM(SWU->WU_OBS,nSWU_OBS,,,3)
      EVAL(bMsg,STR0373+STR0547,.T.) //"OBSERVACOES NO P.O. DO MODELO
   ENDIF
ENDIF
RETURN .T.

*---------------------------------------------------------------------------------------------------*
FUNCTION IN100VerItem(COD_I)
*---------------------------------------------------------------------------------------------------*
LOCAL Inclui:=' '

IF EMPTY(COD_I)
   EVAL(bMsg,STR0556+STR0546)  // CODIGO_ITEM NAO INFORMADO
ELSEIF ! SB1->(DBSEEK(cFilSB1+COD_I))
       IF ! Int_Param->NPAINC_CI
          EVAL(bMsg,STR0556+STR0544)  // CODIGO_ITEM SEM CADASTRO
       ELSE
          Inclui:='S'
       ENDIF
ENDIF
RETURN Inclui

*---------------------------------------------------------------------------------------------------*
FUNCTION IN100VerReg(cChave,bWhile)
*---------------------------------------------------------------------------------------------------*
LOCAL NrReg :=0

SW1->(DBSETORDER(1))
SW1->(DBSEEK(cFilSW1+cChave))                                                                         //MJB-SAP-0401
SW1->(DBEVAL({|| IF(SW1->W1_REG>NrReg,NrReg:=SW1->W1_REG,)},,bWhile))

RETURN NrReg

*---------------------------------------------------------------------------------------------------*
FUNCTION IN100VerFF(Qual,cCod)
*---------------------------------------------------------------------------------------------------*
LOCAL c_Fb_Fn, cId_Fb_Fn:='3', cParam:='NPAINC_'
LOCAL nParam, cInclui:=' ', cCodMod, cTipo

IF cFuncao == CAD_PO
   cTipo:=Int_PO->NPOTIPO
ELSE
   cTipo:=Int_SI->NSITIPO
ENDIF

//ASK 17/12/2007 - No caso de ser alteração e estiver em branco, busca do Modelo.
//IF EMPTY(ALLTRIM(cCod)) .AND. cTipo = "A"
//   RETURN ' '
//ENDIF

IF Qual='1'
   c_Fb_Fn  :=STR0250 //'FABRICANTE'
   cId_Fb_Fn+='1'
   nParam   :=Int_Param->(FIELDPOS(cParam+='FA'))
   cCodMod  :=SWU->WU_FABR
ELSE
   c_Fb_Fn  :=STR0251 //'FORNECEDOR'
   cId_Fb_Fn+='2'
   nParam   :=Int_Param->(FIELDPOS(cParam+='FO'))
   cCodMod  :=SWU->WU_FORN
ENDIF

IF EMPTY(ALLTRIM(cCod))
   IF ! lModelo
      IF cFuncao # CAD_PO
         RETURN ' '
      ENDIF
      EVAL(bMsg,c_Fb_Fn+STR0546)  // NAO INFORMADO
   ELSE
       cCod:=cCodMod
       IF cFuncao == CAD_PO
          IF(Qual='1',Int_IP->NIPFABR:=cCodMod,;
                      Int_PO->NPOFORN:=cCodMod)
          EVAL(bMsg,c_Fb_Fn+STR0547,.T.) // DO MODELO
       ENDIF
   ENDIF
ENDIF

IF ! SA2->(DBSEEK(cFilSA2+cCod))
   IF ! Int_Param->(FIELDGET(nParam))
      EVAL(bMsg,c_Fb_Fn+STR0544+": ("+cCod+")")  // SEM CADASTRO
   ELSE
      cInclui:='S'
   ENDIF
ELSEIF ! (LEFT(SA2->A2_ID_FBFN,1) $ cId_Fb_Fn)
       EVAL(bMsg,STR0374+cCod+STR0375+c_Fb_Fn) //"CODIGO "###" NAO SE REFERE A "
ENDIF
RETURN cInclui

*---------------------------------------------------------------------------------------------------*
FUNCTION IN100VerFabr(cIncluir,cCod,cCodAnt,cOrdem)
*---------------------------------------------------------------------------------------------------*
IF ! EMPTY(cCod) .AND. ! cCod=replicate('0',AVSX3('W7_FABR',3))//'000000' SO.:0026 OS.: 0232/02 FCD
   IF EMPTY(cCodAnt)
      EVAL(bMsg,cOrdem+STR0376+STR0546) //' FABRICANTE NAO INFORMADO
      RETURN cIncluir
   ENDIF

   IF cCod = Int_IP->NIPFABR .OR. cCod = Int_PO->NPOFORN
      EVAL(bMsg,STR0377+cCod+STR0378) //'FABRICANTE '###' JA INFORMADO'
      RETURN cIncluir
   ENDIF

   IF ! SA2->(DBSEEK(cFilSA2+cCod))
      IF ! Int_Param->NPAINC_FA
         EVAL(bMsg,STR0250+cOrdem+STR0544+": ("+cCod+")") //'FABRICANTE SEM CADASTRO
      ELSE
         cIncluir:='S'
      ENDIF
   ELSEIF ! (LEFT(SA2->A2_ID_FBFN,1) $ '1.3')
        EVAL(bMsg,STR0379+cCod+STR0380) //'CODIGO '###' NAO SE REFERE A FABRICANTE'
   ENDIF
ENDIF
RETURN cIncluir

*---------------------------------------------------------------------------------------------------*
FUNCTION IN100VerQtDt(Qtde,bDtEntr)
*---------------------------------------------------------------------------------------------------*
LOCAL DtEntr:=EVAL(bDtEntr)

IF VAL(Qtde) = 0
   EVAL(bMsg,STR0381+STR0546) //'QUANTIDADE NAO INFORMADO
ENDIF

IF EMPTY(DtEntr)
   IF ! lModelo
      EVAL(bMsg,STR0562+STR0546)  // DATA_ENTREGA NAO INFORMADO
   ELSE
      EVAL(bDtEntr,IN100DTC(dDataBase+SWU->WU_DIAS_NE))
      EVAL(bMsg,STR0562+STR0547,.T.)  // DATA_ENTREGA DO MODELO
   ENDIF
ELSEIF ! IN100CTD(DtEntr,.T.)
       EVAL(bMsg,STR0562+STR0549) // DATA_ENTREGA INVALIDO
ENDIF
RETURN .T.

*--------------------------------------------------*
FUNCTION IN100VerCad(Codigo,Campo,AutoInclui,Vazio)
*--------------------------------------------------*
LOCAL lUsaModelo:=.F.

IF ! (EMPTY(Codigo) .AND. Int_PO->NPOTIPO = "A")
   IF ! EMPTY(Codigo)
      IF ! DBSEEK(xFilial()+Codigo) .AND. ! AutoInclui
         EVAL(bMsg,Campo+STR0544+": ("+Codigo+")")  // SEM CADASTRO
      ENDIF
   ELSEIF !lModelo
      IF Vazio = NIL
         EVAL(bMsg,Campo+STR0546)  // NAO INFORMADO
      ENDIF
   ELSE
      lUsaModelo:=.T.
   ENDIF
ENDIF

RETURN lUsaModelo

*---------------------*
Function IN100BrowIt()
*---------------------*
Local i, j
Local xConteudo

Private nBrowVolta,nBrowFcount,cBrowAlias:="",cBrowCondicao,cBrowChave,cBrowTitJan
private oPanel7 //LRL 05/04/04
IF cFuncao=CAD_PO
   cBrowAlias    := 'Int_IP'
   cBrowChave    := Int_PO->NPOPO_NUM+Int_PO->NPOSEQ_PO
   cBrowCondicao := Int_PO->NPOPO_NUM+Int_PO->NPOSEQ_PO
   bMessage      := FIELDWBLOCK('NIPMsg'   ,SELECT('Temp'))
   bStatus       := {|x|If(x=Nil,Temp->NIPINT_OK="T",Temp->NIPINT_OK:=x)}
   bTipo         := FIELDWBLOCK('NIPTIPO'  ,SELECT('Temp'))
   cBrowTitJan   := STR0382+Int_Po->NPOPO_NUM //"Itens do P.O.: "
ELSEIF cFuncao=CAD_FE
   cBrowAlias    := 'Int_FD'
   cBrowChave    := Int_FE->NFENOTA
   cBrowCondicao := Int_FE->NFENOTA
   bMessage      := FIELDWBLOCK('NFDMsg'   ,SELECT('Temp'))
   bStatus       := {|x|If(x=Nil,Temp->NFDINT_OK="T",Temp->NFDINT_OK:=x)}
   bTipo         := FIELDWBLOCK('NFDTIPO'  ,SELECT('Temp'))
   cBrowTitJan   := cTitNFE+": "+Int_FE->NFENOTA
ELSEIf cFuncao=CAD_SI
   cBrowAlias    := 'Int_IS'
   cBrowChave    := Int_SI->NSI_CC+Int_SI->NSI_NUM+Int_SI->NSISEQ_SI
   cBrowCondicao := Int_SI->NSI_CC+Int_SI->NSI_NUM+Int_SI->NSISEQ_SI
   bMessage      := FIELDWBLOCK('NISMsg'   ,SELECT('Temp'))
   bStatus       := {|x|If(x=Nil,Temp->NISINT_OK="T",Temp->NISINT_OK:=x)}   
   bTipo         := FIELDWBLOCK('NISTIPO'  ,SELECT('Temp'))
   cBrowTitJan   := STR0383+Int_SI->NSI_NUM //"Itens do S.I.: "
ELSEIF cFuncao=CAD_IT
   cBrowAlias    := 'Int_ID'
   cBrowChave    := Int_IT->NITCOD_I
   cBrowCondicao := Int_IT->NITCOD_I
   bMessage      := FIELDWBLOCK('NIDMsg'   ,SELECT('Temp'))
   bStatus       := {|x|If(x=Nil,Temp->NIDINT_OK="T",Temp->NIDINT_OK:=x)}   
   bTipo         := FIELDWBLOCK('NIDTIPO'  ,SELECT('Temp'))
   cBrowTitJan   := STR0044+Int_IT->NITCOD_I   // "Idiomas do Item : "

ELSEIF cFuncao = CAD_CI .And. lEIC_EEC                                    //MJB-SAP-0101
   cBrowAlias    := 'Int_ID'                                              //MJB-SAP-0101
   cBrowChave    := Int_CI->NCICOD_I                                      //MJB-SAP-0101
   cBrowCondicao := Int_CI->NCICOD_I                                      //MJB-SAP-0101
   bMessage      := FIELDWBLOCK('NIDMsg'   ,SELECT('Temp'))               //MJB-SAP-0101
   bStatus       := {|x|If(x=Nil,Temp->NIDINT_OK="T",Temp->NIDINT_OK:=x)} //MJB-SAP-0101   
   bTipo         := FIELDWBLOCK('NIDTIPO'  ,SELECT('Temp'))               //MJB-SAP-0101
   cBrowTitJan   := STR0044+Int_CI->NCICOD_I   // "Idiomas do Item : "    //MJB-SAP-0101

ELSEIF cFuncao=CAD_PE
   cBrowAlias    := 'Int_PD'
   cBrowChave    := Int_PE->NPEPEDIDO+Int_PE->NPESEQ
   cBrowCondicao := Int_PE->NPEPEDIDO+Int_PE->NPESEQ
   bMessage      := FIELDWBLOCK('NPDMsg'   ,SELECT('Temp'))
   bStatus       := {|x|If(x=Nil,Temp->NPDINT_OK="T",Temp->NPDINT_OK:=x)}   
   bTipo         := FIELDWBLOCK('NPDTIPO'  ,SELECT('Temp'))
   cBrowTitJan   := STR0474+" : "+Int_PE->NPEPEDIDO
ELSEIF cFuncao=CAD_NU
   cBrowAlias    := 'Int_DN'
   cBrowChave    := Int_NU->NNUREFDES
   cBrowCondicao := Int_NU->NNUREFDES
   bMessage      := FIELDWBLOCK('NDNMsg'   ,SELECT('Temp'))
   bStatus       := {|x|If(x=Nil,Temp->NDNINT_OK="T",Temp->NDNINT_OK:=x)}   
   bTipo         := FIELDWBLOCK('NDNTIPO'  ,SELECT('Temp'))
   cBrowTitJan   := STR0674+" : "+Int_NU->NNUREFDES
ELSEIF cFuncao=CAD_NC
       cBrowAlias    := 'Int_ND'
       cBrowChave    := Int_NC->(NNCPRO+NNCSER+NNCNF+NNCREC) // By JPP - 28/11/2006 - 16:50 - Inclusão do campo NNCREC na chave. 
       cBrowCondicao := Int_NC->(NNCPRO+NNCSER+NNCNF+NNCREC) // By JPP - 28/11/2006 - 16:50 - Inclusão do campo NNCREC na chave. 
       bMessage      := FIELDWBLOCK('NNDMsg'   ,SELECT('Temp'))
       bStatus       := {|x|If(x=Nil,Temp->NNDINT_OK="T",Temp->NNDINT_OK:=x)}   
       bTipo         := FIELDWBLOCK('NNDTIPO'  ,SELECT('Temp'))
       cBrowTitJan   := STR0474+" : "+Int_NC->NNCPRO
Else
   If EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"BROWITEM")
   EndIf
 
ENDIF

If EMPTY(ALLTRIM(cBrowAlias))
   Return                
EndIf

DBSELECTAREA('Temp')
avzap()

nBrowFcount := (cBrowAlias)->(FCount())

(cBrowAlias)->(DBGOTOP())
(cBrowAlias)->(DBSEEK(cBrowChave))

DO WHILE ! (cBrowAlias)->(EOF()) .AND. cBrowChave == cBrowCondicao
   IN100RecLock('Temp')
   FOR i := 1 TO nBrowFcount
      IF !( TEMP->(FieldName(i)) == 'DELETE' .Or. TEMP->(FieldName(i)) == 'DBDELETE')
         j := (cBrowAlias)->(FieldPos(TEMP->(FieldName(i))))
         xConteudo := (cBrowAlias)->(FieldGet(j))

         IF VALTYPE(xConteudo) = "C"
            xConteudo := ALLTRIM(xConteudo)
         EndIf

        Temp->(FIELDPUT(i, xConteudo))
      ENDIF    
   NEXT

   (cBrowAlias)->(DBSKIP())
   IF cFuncao=CAD_PO
      cBrowCondicao := Int_IP->NIPPO_NUM+Int_IP->NIPSEQ_PO
   ELSEIF cFuncao=CAD_FE
      cBrowCondicao := Int_FD->NFDNOTA
   ELSEIF cFuncao=CAD_NU
      cBrowCondicao := Int_DN->NDNREFDES
   ELSEIF cFuncao=CAD_SI
      cBrowCondicao := Int_IS->NISCC+Int_IS->NISSI_NUM+Int_IS->NISSEQ_SI
   ELSEIF cFuncao=CAD_IT
      cBrowCondicao := Int_ID->NIDCOD_I
   ELSEIF cFuncao=CAD_PE
      cBrowCondicao := Int_PD->NPDPEDIDO+Int_PD->NPDSEQ
   ELSEIF cFUNCAO = CAD_NC
          cBrowCondicao := Int_ND->(NNDPRO+NNDSER+NNDNF+NNDREC) // By JPP - 28/11/2006 - 16:50 - Inclusão do campo NNDREC na chave. 
   Else
      If EasyEntryPoint("IN100CLI")
         ExecBlock("IN100CLI",.F.,.F.,"BROWITEMCOND")
      EndIf
   ENDIF
ENDDO

IF Temp->(EasyRecCount("Temp")) == 0
   IN100RecLock('Temp')
ENDIF              

Temp->(DBGOTOP())

DEFINE MSDIALOG oDlg7 TITLE cBrowTitJan ;
   From oMainWnd:nTop+125,oMainWnd:nLeft+5 To oMainWnd:nBottom-60,oMainWnd:nRight-10 OF oDlg2 PIXEL
  @ 00,00 MsPanel oPanel7 Prompt "" Size 60,19 of oDlg7 //LRL 05/04/04 - Painel para  Alinhamento Mdi
  @ 3,(oDlg7:nClientWidth-80)/2 BUTTON STR0029 SIZE 34,13 FONT oDlg7:oFont ACTION (IN100E_MSG()) OF oPanel7 PIXEL //"&Mensagem"

  oTrab:=MsSelect():New(('Temp'),,,TB_Col_D,@lInverte,@cMarca,{35,1,(oDlg7:nHeight-30)/2,(oDlg7:nClientWidth-4)/2})
  oTrab:oBrowse:bWhen:={|| DBSELECTAREA('Temp'),.T.}

  nBrowVolta:=0

  If EasyEntryPoint("IN100CLI")
     ExecBlock("IN100CLI",.F.,.F.,"BOTAO_DET_PO")
  ENDIF
  oDlg7:lMaximized:=.t.
  oPanel7:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
  oTrab:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
  
ACTIVATE MSDIALOG oDlg7 ON INIT (EnchoiceBar(oDlg7,{||nBrowVolta:=1,oDlg7:End()}, {||oDlg7:End()})) //LRL 05/04/04 - Alinhamento MDI. //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

bMessage:=FIELDWBLOCK('N'+cFuncao+'Msg'   ,SELECT('Int_'+cFuncao))
bStatus :={|x| if(x=nil,('Int_'+cFuncao)->&('N'+cFuncao+'INT_OK')="T",('Int_'+cFuncao)->&('N'+cFuncao+'INT_OK'):=x)}
bTipo   :=FIELDWBLOCK('N'+cFuncao+'TIPO'  ,SELECT('Int_'+cFuncao))

SELEC ('Int_'+cFuncao)
RETURN .T.

*----------------------------------------------------------------------------
FUNCTION IN100_Open(bMsg,aAlias,lAbre)
*----------------------------------------------------------------------------
LOCAL cFileName, nInd

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abertura de arquivos                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

For nInd:=1 TO LEN(aAlias)

    cFileName:="S"+aAlias[nInd]

    Eval(bMsg,STR0384+cFileName+STR0385) //"ABRINDO ARQUIVO "###" - AGUARDE...    "

    If SELECT(cFileName) = 0
       If !ChkFile(cFileName,.F.)
          IN_MSG(STR0386+cFileName,STR0039) //"NÆo foi poss¡vel abrir Arquivo IN100"###"Informação"
          lAbre:=.F.
       Endif
    Endif

Next

RETURN .T.

*---------------------------------------------------------------------------------------------------*
FUNCTION IN100GrvPO()
*---------------------------------------------------------------------------------------------------*
LOCAL nSeq_SLi, i
LOCAL IncluiCI, IncluiFA, IncluiFO, bSave:=bMessage, nCont:=0
LOCAL cAgente:=Int_PO->NPOAGENTE, cForward:=Int_PO->NPOFORWARD
LOCAL cCompra:=Int_PO->NPOCOMPRA, cForn:=Int_PO->NPOFORN, cFabr, cAlias
LOCAL nFob
aTabW0:={}
aTabW4:={}

Int_IP->(DBSEEK(Int_PO->NPOPO_NUM+Int_PO->NPOSEQ_PO))

cAlias:=ALIAS()
DBSELECTAREA("Int_PO")
SW3->(DBSETORDER(1))

If EasyEntryPoint("IN100CLI")                                                                             //MJB-SAP-0401
   ExecBlock("IN100CLI",.F.,.F.,"PREPARAGRVPO")                                                       //MJB-SAP-0401
Endif                                                                                                 //MJB-SAP-0401

IF Int_PO->NPOTIPO = ALTERACAO .OR. Int_PO->NPOTIPO = EXCLUSAO
   IF SW2->(DBSEEK(cFilSW2+AVKEY(Int_PO->NPOPO_NUM,"W2_PO_NUM")))                                                        //MJB-SAP-0401
      IF ! Softlock("SW2")
         Int_PO->NPOMSG   :=STR0387 //'P.O. EM USO'
         Int_PO->NPOINT_OK:="F"
         MSUNLOCKALL()
         RETURN
      ENDIF
      IF SW3->(DBSEEK(cFilSW3+AVKEY(Int_PO->NPOPO_NUM,"W3_PO_NUM")))                                     //MJB-SAP-0401
         DO WHILE ! SW3->(EOF()) .AND. Int_PO->NPOPO_NUM == SW3->W3_PO_NUM .AND. cFilSW3==SW3->W3_FILIAL //MJB-SAP-0401
            //TRP-02/10/07
            If !lParam
               oDlgProc:SetText(STR0773+SW3->W3_POSICAO) 
            Endif
            IF SW0->(DBSEEK(cFilSW0+SW3->W3_CC+SW3->W3_SI_NUM))                                       //MJB-SAP-0401
               IF ! Softlock("SW0")
                  Int_PO->NPOMSG   :=STR0388 //'S.I. EM USO'
                  Int_PO->NPOINT_OK:="F"
                  MSUNLOCKALL()
                  RETURN
               ENDIF
            ENDIF
            IF SW4->(DBSEEK(cFilSW4+SW3->W3_PGI_NUM))                                                 //MJB-SAP-0401
               IF ! Softlock("SW4")
                  Int_PO->NPOMSG   :=STR0389 //'L.I. EM USO'
                  Int_PO->NPOINT_OK:="F"
                  MSUNLOCKALL()
                  RETURN
               ENDIF
            ENDIF
            SW3->(DBSKIP())
         ENDDO
      ELSE
         MSUNLOCKALL()
         RETURN
      ENDIF
   ENDIF
   Reclock("SW2",.F.)
ENDIF
DBSELECTAREA("Int_PO")

IF Int_PO->NPOTIPO = EXCLUSAO

   Begin Transaction

   IN100DelPO()
   
   End Transaction   
   
   RETURN
ENDIF

IF Int_PO->NPOTIPO = INCLUSAO .OR. Int_PO->NPOTIPO = "A"

   IF ! (EMPTY(Int_PO->NPO_POLE) .AND. Int_PO->NPOTIPO = "A")
      IF Int_Param->NPAINC_LE .AND. ! SY2->(DBSEEK(cFilSY2+AvKey(Int_PO->NPO_POLE,"Y2_SIGLA")))
         Int_PO->(IN100Cadastra(CAD_LE,Int_PO->NPO_POLE))
      ENDIF
   ENDIF

   IF ! (EMPTY(cCompra) .AND. Int_PO->NPOTIPO = "A")
      IF Int_Param->NPAINC_CO .AND. ! SY1->(DBSEEK(cFilSY1+AvKey(cCompra,"Y1_COD")))
         Int_PO->(IN100Cadastra(CAD_CO,cCompra))
      ENDIF
   ENDIF

   IF ! (EMPTY(cAgente) .AND. Int_PO->NPOTIPO = "A")
      IF Int_Param->NPAINC_AG .AND. ! SY4->(DBSEEK(cFilSY4+AvKey(cAgente,"Y4_COD")))
         Int_PO->(IN100Cadastra(CAD_AG,cAgente))
      ENDIF
   ENDIF

   IF ! (EMPTY(cForward) .AND. Int_PO->NPOTIPO = "A")
      IF Int_Param->NPAINC_FW .AND. ! EMPTY(cForward) .AND. ;
         ! SY4->(DBSEEK(cFilSY4+AvKey(cForward,"Y4_COD")))
         Int_PO->(IN100Cadastra(CAD_AG,cForward))
      ENDIF
   ENDIF

   IF ! (EMPTY(Int_PO->NPOIMPORT) .AND. Int_PO->NPOTIPO = "A")
      IF Int_Param->NPAINC_IMP .AND. ! SYT->(DBSEEK(cFilSYT+AvKey(Int_PO->NPOIMPORT,"YT_COD_IMP")))
         Int_PO->(IN100Cadastra(CAD_IM,Int_PO->NPOIMPORT,'1'))
      ENDIF
   ENDIF

   IF ! (EMPTY(Int_PO->NPOCONSIG) .AND. Int_PO->NPOTIPO = "A")
      IF Int_Param->NPAINC_CON .AND. ! SYT->(DBSEEK(cFilSYT+AvKey(Int_PO->NPOCONSIG,"YT_COD_IMP")))
         Int_PO->(IN100Cadastra(CAD_IM,Int_PO->NPOCONSIG,'2'))
      ENDIF
   ENDIF

   IF ! (EMPTY(cForn) .AND. Int_PO->NPOTIPO = "A")
      IF Int_Param->NPAINC_FO .AND. !  SA2->(DBSEEK(cFilSA2+AvKey(cForn,"A2_COD")))
         IN100TabFabFor(cForn,'2')
      ENDIF
   ENDIF

ENDIF

cFuncao := CAD_IP
bMessage:= FIELDWBLOCK('NIPMSG',SELECT('Int_IP'))

nSeq_SLi := "*NADA*"
IF Int_PO->NPOTIPO == ALTERACAO
   SW3->(DBSEEK(cFilSW3+AVKEY(Int_PO->NPOPO_NUM,"W3_PO_NUM")))                                         //MJB-SAP-0401
   DO WHILE ! SW3->(EOF()) .AND. Int_PO->NPOPO_NUM=SW3->W3_PO_NUM .AND. cFilSW3 ==SW3->W3_FILIAL      //MJB-SAP-0401
      //TRP-02/10/07
      If !lParam
         oDlgProc:SetText(STR0773+SW3->W3_POSICAO) 
      Endif
      IF SW3->W3_FLUXO="7" .AND. ! EMPTY(SW3->W3_PGI_NUM)
         nSeq_Sli := SW3->W3_PGI_NUM
         EXIT
      ENDIF
      SW3->(DBSKIP())
   ENDDO
ENDIF
If EasyEntryPoint("IN100CLI")
  ExecBlock("IN100CLI",.F.,.F.,"ENTRE_PO_E_IP")
ENDIF

Begin Transaction

lTravaPO:=.T.
   
SW3->(DBSETORDER(8))
SW5->(DBSETORDER(8))
SW1->(DBSETORDER(1))

DO WHILE ! Int_IP->(EOF()) .AND. Int_IP->NIPPO_NUM = Int_PO->NPOPO_NUM .AND. Int_PO->NPOSEQ_PO = Int_IP->NIPSEQ_PO

  IF !lParam
     IncProc(STR0430+Int_PO->NPOPO_NUM+" "+STR0296+": "+Int_IP->NIPPOSICAO)
  EndIf

  IF ! Int_IP->NIPINT_OK = "T"
     Int_IP->(DBSKIP())
     LOOP
  ENDIF

  If EasyEntryPoint("IN100CLI")
     ExecBlock("IN100CLI",.F.,.F.,"ANTES_GRVIP")
  ENDIF

  IF nSeq_SLi = "*NADA*" .AND. Int_IP->NIPFLUXO="7" 
     cAlias:=ALIAS()
     //SETMV("MV_SEQ_LI",EasyGParam("MV_SEQ_LI")+1)
     nSeq_SLi       :="*"+EasyGetMVSeq("MV_SEQ_LI")+"*"
     DBSELECTAREA("Int_PO")
  ENDIF

  IncluiCI:=!EMPTY(LEFT(Int_IP->NIPINCLUI,1))
  IncluiFA:=!EMPTY(SUBS(Int_IP->NIPINCLUI,2,1))
  IncluiCC:=!EMPTY(RIGHT(Int_IP->NIPINCLUI,1))
  cFabr   :=Int_IP->NIPFABR
  cCCusto := Int_IP->NIPCC

  IF IncluiCI .AND. ! SB1->(DBSEEK(cFilSB1+AvKey(LEFT(Int_IP->NIPCOD_I,NLENITEM),"B1_COD")))
     Int_IP->(IN100Cadastra(CAD_CI,LEFT(NIPCOD_I,NLENITEM)))
  ENDIF

  IF IncluiFA .AND. ! SA2->(DBSEEK(cFilSA2+AvKey(cFabr,"A2_COD")))
     IN100TabFabFor(cFabr,'1')
  ENDIF

  IF IncluiCC .AND. ! SY3->(DBSEEK(cFilSY3+AvKey(cCCusto,"Y3_COD")))
     Int_IP->(IN100Cadastra(CAD_CC,cCCusto,Int_PO->NPO_POLE))
  ENDIF

  IF lNIPTEC .AND. !EMPTY(Int_IP->NIPTEC) .AND. Int_Param->NPAINC_NBM .AND. ;
     !SYD->(DBSEEK(cFilSYD+AVKey(Int_IP->NIPTEC,"YD_TEC")+AvKey(Int_IP->NIPEX_NCM,"YD_EX_NCM")+Int_IP->NIPEX_NBM))
     Int_IP->(IN100Cadastra(CAD_NB,Int_IP->NIPTEC,Int_IP->NIPEX_NCM,Int_IP->NIPEX_NBM))
  ENDIF

  SA5->(DBSETORDER(3))
  IF lNIPTEC .And. Int_Param->NPAINC_LI .AND. ;
   ! SA5->(DBSEEK(cFilSA5+AvKey(LEFT(Int_IP->NIPCOD_I,AvSX3("A5_PRODUTO",AV_TAMANHO)),"A5_PRODUTO")+AvKey(cFabr,"A5_FABR")+AvKey(cForn,"A5_FORNECE")))
     Int_IP->(IN100Cadastra(CAD_LI,AvKey(LEFT(NIPCOD_I,AvSX3("A5_PRODUTO",AV_TAMANHO)),"A5_PRODUTO"),AvKey(cFabr,"A5_FABR"),AvKey(cForn,"A5_FORNECE"),if(!SB1->(EOF()),SB1->B1_UM,"")))
  ENDIF
  SA5->(DBSETORDER(1))

  IF Int_IP->NIPTIPO=EXCLUSAO //Int_IP->NIPTIPO=ALTERACAO .OR.

     IF Int_IP->NIPTIPO=EXCLUSAO
        IF ASCAN(aTabW0,{|chave| chave[1] == Int_IP->NIPCC+Int_IP->NIPSI_NUM}) = 0
           AADD(aTabW0,{Int_IP->NIPCC+Int_IP->NIPSI_NUM,0})
        ENDIF
     ENDIF

     IN100DelItem()
  ENDIF

  IF Int_IP->NIPTIPO=ALTERACAO .OR. Int_IP->NIPTIPO=INCLUSAO
     Int_IP->(IN100SI_PO(++nCont,nSeq_Sli))
  ENDIF
  
  Int_IP->(DBSKIP())
ENDDO

DBSELECTAREA("Int_PO")
SW0->(DBSETORDER(1))
SW1->(DBSETORDER(1))
SW2->(DBSETORDER(1))
SW3->(DBSETORDER(1))
SW4->(DBSETORDER(1))
SW5->(DBSETORDER(1))
cAlias:=ALIAS()

IF ! SW3->(DBSEEK(cFilSW3+AVKEY(Int_PO->NPOPO_NUM,"W3_PO_NUM")))                                      //MJB-SAP-0401
   IF SW2->(DBSEEK(cFilSW2+AVKEY(Int_PO->NPOPO_NUM,"W2_PO_NUM")))                                     //MJB-SAP-0401
      MSMM(SW2->W2_OBS,,,,2)
      SW2->(DBDELETE())
   ENDIF
ELSE
   nFob:=0
   nForAux:=space(nLenForn) //SO.:0026 OS.:0232/02 FCD
   DO WHILE ! SW3->(EOF()) .AND. AVKEY(Int_PO->NPOPO_NUM,"W3_PO_NUM") == SW3->W3_PO_NUM .AND. SW3->W3_FILIAL==cFilSW3
      //TRP-02/10/07
      If !lParam
         oDlgProc:SetText(STR0773+SW3->W3_POSICAO) 
      Endif
      IF SW3->W3_SEQ = 0
         nFob+=(SW3->W3_QTDE * SW3->W3_PRECO)
         nForAux:=SW3->W3_FORN
      ENDIF
      SW3->(DBSKIP())
   ENDDO
   IF SW2->(DBSEEK(cFilSW2+AVKEY(Int_PO->NPOPO_NUM,"W2_PO_NUM")))                       //MJB-SAP-0401
      Reclock("SW2",.F.)   
      IF Int_PO->NPOTIPO = "A"
         SW2->W2_INTEGRA  := "S"
         cUltPosPO:=INVERPOS()             //Procura Ultima Posicao Item
         IF ! EMPTY(ALLTRIM(cUltPosPO))
            SW2->W2_POSICAO := cUltPosPO  // Grava Ultima Posicao Item
         ENDIF
         IF ! EMPTY(ALLTRIM(Int_PO->NPOPO_DT))
            SW2->W2_PO_DT    := IN100CTD(Int_PO->NPOPO_DT)
         ENDIF
         IF ! EMPTY(ALLTRIM(Int_PO->NPOCOMPRA))
            SW2->W2_COMPRA   := Int_PO->NPOCOMPRA
         ENDIF
         IF ! EMPTY(ALLTRIM(Int_PO->NPOTIPO_EM))
            SW2->W2_TIPO_EM  := Int_PO->NPOTIPO_EM
         ENDIF
         IF ! EMPTY(ALLTRIM(Int_PO->NPOORIGEM))
            SW2->W2_ORIGEM   := Int_PO->NPOORIGEM
         ENDIF
         IF ! EMPTY(ALLTRIM(Int_PO->NPODEST))
            SW2->W2_DEST     := Int_PO->NPODEST
         ENDIF
         IF ! EMPTY(ALLTRIM(Int_PO->NPOCOND_PA))
            SW2->W2_COND_PA  := Int_PO->NPOCOND_PA
         ENDIF
         IF ! EMPTY(ALLTRIM(Int_PO->NPODIAS_PA))
            SW2->W2_DIAS_PA  := VAL(Int_PO->NPODIAS_PA)
         ENDIF
         IF ! EMPTY(ALLTRIM(Int_PO->NPOAGENTE))
            SW2->W2_AGENTE   := Int_PO->NPOAGENTE
         ENDIF
         IF ! EMPTY(ALLTRIM(Int_PO->NPOIMPORT))
            SW2->W2_IMPORT   := Int_PO->NPOIMPORT
         ENDIF
         IF ! EMPTY(ALLTRIM(Int_PO->NPOMOEDA))
            SW2->W2_MOEDA    := Int_PO->NPOMOEDA
         ENDIF
         IF ! EMPTY(Int_PO->NPOINLAND)
            SW2->W2_INLAND   := VAL(Int_PO->NPOINLAND)
         ENDIF
         IF ! EMPTY(Int_PO->NPOPACKING)
            SW2->W2_PACKING  := VAL(Int_PO->NPOPACKING)
         ENDIF
         IF ! EMPTY(Int_PO->NPODESCONT)
            SW2->W2_DESCONT  := VAL(Int_PO->NPODESCONT)
         ENDIF
         IF ! EMPTY(Int_PO->NPOFRETEIN)
            SW2->W2_FRETEIN  := VAL(Int_PO->NPOFRETEIN)
         ENDIF
         IF ! EMPTY(ALLTRIM(Int_PO->NPOFREPPCC))
            SW2->W2_FREPPCC  := Int_PO->NPOFREPPCC
         ENDIF
         IF ! EMPTY(ALLTRIM(Int_PO->NPOCONSIG))
            SW2->W2_CONSIG   := Int_PO->NPOCONSIG
         ENDIF
         IF ! EMPTY(ALLTRIM(Int_PO->NPONR_PRO))
            SW2->W2_NR_PRO   := Int_PO->NPONR_PRO
         ENDIF
         IF ! EMPTY(ALLTRIM(Int_PO->NPODT_PRO))
            SW2->W2_DT_PRO   := IN100CTD(Int_PO->NPODT_PRO)
         ENDIF
         IF ! EMPTY(Int_PO->NPOPARID_US)
            SW2->W2_PARID_U  := VAL(Int_PO->NPOPARID_US)
         ENDIF
         IF ! EMPTY(ALLTRIM(Int_PO->NPODT_PAR))
            SW2->W2_DT_PAR   := IN100CTD(Int_PO->NPODT_PAR)
         ENDIF
         IF ! EMPTY(Int_PO->NPOPESO_B)
            SW2->W2_PESO_B   := VAL(Int_PO->NPOPESO_B)
         ENDIF
         IF ! EMPTY(ALLTRIM(Int_PO->NPOCLIENTE))
            SW2->W2_CLIENTE  := Int_PO->NPOCLIENTE
         ENDIF
         IF ! EMPTY(ALLTRIM(Int_PO->NPOFORWARD))
            SW2->W2_FORWARD  := Int_PO->NPOFORWARD
         ENDIF
         IF ! EMPTY(ALLTRIM(Int_PO->NPOINCOTER))
            SW2->W2_INCOTERM := Int_PO->NPOINCOTER
         ENDIF
         IF ! EMPTY(ALLTRIM(Int_PO->NPOINT_DT))
            SW2->W2_DT_INTEG := IN100CTD(Int_PO->NPOINT_DT)
         ENDIF

         IF ! EMPTY(ALLTRIM(Int_PO->NPOOBS))
            MSMM(SW2->W2_OBS,nSW2_OBS,,Int_PO->NPOOBS,1,,,"SW2","W2_OBS")
            Reclock("SW2",.F.)
         ENDIF

         If EasyEntryPoint("IN100CLI")
            ExecBlock("IN100CLI",.F.,.F.,"GRVPO")
         ENDIF
      ENDIF

      IF ! EMPTY(ALLTRIM(nForAux))
         SW2->W2_FORN := nForAux
      ENDIF
      SW2->W2_FOB_TOT := nFob
      If EasyEntryPoint("IN100CLI")
        ExecBlock("IN100CLI",.F.,.F.,"GRVTOTPO")
      ENDIF
      
   ENDIF
ENDIF

FOR I=1 TO LEN(aTabW0)
    IF ! SW1->(DBSEEK(cFilSW1+aTabW0[I,1]))                                                           //MJB-SAP-0401
       IF SW0->(DBSEEK(cFilSW0+aTabW0[I,1]))                                                          //MJB-SAP-0401
          Reclock("SW0",.F.)
          SW0->(DBDELETE())
       ENDIF
    ENDIF
NEXT

FOR I=1 TO LEN(aTabW4)
    IF ! SW5->(DBSEEK(cFilSW5+aTabW4[I,1]))                                                           //MJB-SAP-0401
       IF SW4->(DBSEEK(cFilSW4+aTabW4[I,1]))                                                          //MJB-SAP-0401
          Reclock("SW4",.F.)
          SW4->(DBDELETE())
       ENDIF
    ELSE
       nFob:=0
       DO WHILE ! SW5->(EOF()) .AND. aTabW4[I,1] = SW5->W5_PGI_NUM .AND. cFilSW5==SW5->W5_FILIAL      //MJB-SAP-0401
          //TRP-02/10/07
          If !lParam
             oDlgProc:SetText(STR0773+SW5->W5_POSICAO) 
          Endif
          IF SW5->W5_SEQ = 0
             nFob+=(SW5->W5_QTDE * SW5->W5_PRECO)
          ENDIF
          SW5->(DBSKIP())
       ENDDO
       IF SW4->(DBSEEK(cFilSW4+aTabW4[I,1]))                                                          //MJB-SAP-0401
          Reclock("SW4",.F.)
          SW4->W4_FOB_TOT   := VAL(STR(nFob,15,2))
          SW4->W4_INLAND    := IF(!EMPTY(Int_PO->NPOINLAND ),VAL(Int_PO->NPOINLAND) ,SW4->W4_INLAND  )
          SW4->W4_FRETEINT  := IF(!EMPTY(Int_PO->NPOFRETEIN),VAL(Int_PO->NPOFRETEIN),SW4->W4_FRETEINT)
          SW4->W4_PACKING   := IF(!EMPTY(Int_PO->NPOPACKING),VAL(Int_PO->NPOPACKING),SW4->W4_PACKING )
          SW4->W4_DESCONTO  := IF(!EMPTY(Int_PO->NPODESCONT),VAL(Int_PO->NPODESCONT),SW4->W4_DESCONTO)
          SW4->(MSUNLOCK())
       ENDIF
    ENDIF
NEXT
DBSELECTAREA(cAlias)

MSUNLOCKALL()

End Transaction   

cFuncao := CAD_PO
bMessage:= bSave
RETURN NIL
*---------------------------------------------------------------------------------------------------*
FUNCTION IN100GrvFE()
*---------------------------------------------------------------------------------------------------*
LOCAL npos := 0
//WFS 18/11/08
Local lNumNfAuto:= .T.
LOCAL cTpNrNfs   := EasyGParam("MV_TPNRNFS",,"1") //TDF - 29/06/11
Local lValQtde   := EasyGParam("MV_EIC0032",,.F.)	// GCC - 03/12/2013 - Habilita a possibilidade de gerar NF Filhas com quantidade superior a 5% da manifestada.
Local lSubII     :=  EasyGParam("MV_EIC0064",,.F.) //MFR 01/10/2020 OSSME-5276 parâmetro para subtrair o II ou não do valor do item
Local nPerMajCOF := 0  // GFP - 11/06/2013 - Majoração COFINS
Local nPerMajPIS := 0  // GFP - 11/06/2013 - Majoração PIS
Local nValCMaj := 0, nValPMaj := 0  // GFP - 22/09/2015
Local lRet := .T.
Local cObsDI := "" //MCF - 15/04/2016
Local oWNRateio
Local cNFEHAWB
Local cPedidoSiga := ""
Local cConta   := ""
Local cItemCta := ""
Local cClvl    := ""
Local cCTCusto := ""
Local nValUnit := 0
//TRP - 31/07/2012 - Tratamento de Majoração do Cofins
Private lCposCofMj := SYD->(FieldPos("YD_MAJ_COF")) > 0 .And. SYT->(FieldPos("YT_MJCOF")) > 0 .And. SWN->(FieldPos("WN_VLCOFM")) > 0 .And.;                                                    //NCF - 20/07/2012 - Majoração PIS/COFINS
                      SWN->(FieldPos("WN_ALCOFM")) > 0  .And. SWZ->(FieldPos("WZ_TPCMCOF")) > 0 .And. SWZ->(FieldPos("WZ_ALCOFM")) > 0 .And.;
                      EIJ->(FieldPos("EIJ_ALCOFM")) > 0 .And. SW8->(FieldPos("W8_VLCOFM")) > 0 .And. EI2->(FieldPos("EI2_VLCOFM")) > 0 
Private lCposPisMj := SYD->(FieldPos("YD_MAJ_PIS")) > 0 .And. SYT->(FieldPos("YT_MJPIS")) > 0 .And. SWN->(FieldPos("WN_VLPISM")) > 0 .And.;                                                    //NCF - 20/07/2012 - Majoração PIS/COFINS
                      SWN->(FieldPos("WN_ALPISM")) > 0  .And. SWZ->(FieldPos("WZ_TPCMPIS")) > 0 .And. SWZ->(FieldPos("WZ_ALPISM")) > 0 .And.;
                      EIJ->(FieldPos("EIJ_ALPISM")) > 0 .And. SW8->(FieldPos("W8_VLPISM")) > 0 .And. EI2->(FieldPos("EI2_VLPISM")) > 0    //GFP - 11/06/2013 - Majoração PIS

PRIVATE lMudouNum := .F. // TDF - 29/06/11
PRIVATE cTipoNF  := "1", cForn:= cPo_NUM:= cCod_I := ''
PRIVATE aGrv_SF1 := {},lMSErroAuto := .F. 
PRIVATE lMV_EASY_SIM:=EasyGParam("MV_EASY") $ cSim
PRIVATE lMV_AV_MERC :=EasyGParam("MV_AV_MERC",,"S") $ cSim
//JWJ 18/05/2006: Controle para a numeração dos itens (WN_LINHA) POR NOTA
Private aNFLin := {}
Private nNFLin := 0
Private cIntICMS := EasyGParam("MV_EIC0010",,"1")   // GCC - 25/06/2013 - Define a origem da alíquota ICMS na integração de NF


DO Case
   Case INT_FE->NFEESPECIE = "NFE"
        cTipoNF := "1"
   Case INT_FE->NFEESPECIE = "NFC"
        cTipoNF := "2"
   Case INT_FE->NFEESPECIE = "NFU"//AWR - 16/02/2009
        cTipoNF := "3"
   Case INT_FE->NFEESPECIE = "NFT"
        cTipoNF := "9"            
   Case INT_FE->NFEESPECIE = "NFM" 
        cTipoNF := "5"
   Case INT_FE->NFEESPECIE = "NFF"
        cTipoNF := "6"
Endcase
SB1->(DBSETORDER(1))
SW2->(DBSETORDER(1))
SW6->(DBSETORDER(1))
SYU->(DBSETORDER(2))
SW7->(dbsetorder(4))
SW3->(DBSETORDER(8))
SW6->(DBSEEK(cFilSW6+AvKey(Int_FE->NFEHAWB,"W6_HAWB")))
SWN->(DBSETORDER(3)) //JWJ 22/05/06

IF cProcesso # AvKey(Int_FE->NFEHAWB,"W6_HAWB")
   cProcesso:=AvKey(Int_FE->NFEHAWB,"W6_HAWB")
ENDIF

If Type("bUpDate") <> "B"
   bUpDate:= Nil
EndIf

Begin Transaction

Begin Sequence
//WFS 18/11/2008 - Tratamento para a NFe ---
If !EasyGParam("MV_NFEDESP",.T.) .OR. EasyGParam("MV_NFEDESP",,.F.)
   cNumero:= AllTrim(INT_FE->NFENOTA)
   cSerie := AllTrim(INT_FE->NFESERIE)
   dDtEmis:= AllTrim(INT_FE->NFEDT_EMIS)
   If EMPTY(cControle) .OR. cProcesso # AvKey(Int_FE->NFEHAWB,"W6_HAWB")
      cControle:=INT_FE->NFENOTA+INT_FE->NFESERIE
   EndIf
Else
//Tabela EIX: constam apenas as notas estornadas que não tiveram a sua numeração reaproveitada
   cSerie:= AllTrim(EasyGParam("MV_SER_NFE"))
   dDtEmis:= DTOS(dDataBase)
   
   If EasyGParam("MV_REAPNNF",,.F.)
      //Se existir a tabela EIX
      SX2->(DBSetOrder(1))
      If SX2->(DBSeek("EIX"))
         EIX->(DBSetOrder(1))
         EIX->(DBGoTop())
         //Procurando o processo e o tipo de nota vindos da integração
         If EIX->(DBSeek(xFilial()+cProcesso))
         	SF1->(dbSetOrder(1))
            While (cProcesso == EIX->EIX_HAWB)
               If cTipoNF == EIX->EIX_TIPONF
                  cNumero:= ALLTRIM(EIX->EIX_DOC)
                  cSerie := ALLTRIM(EIX->EIX_SERIE)
                  EIX->(Reclock("EIX",.F.))
                  EIX->(DBDelete())
                  MsUnlock()               
                  IF !SF1->(DBSeek(xFilial("SF1")+cNumero+cSerie))
                     lNumNFAuto := .F.
                  	 EXIT
                  ENDIF
               EndIf
               EIX->(DBSkip())
            EndDo
         EndIf
      EndIf
   EndIf
   //Se não serão reaproveitadas as notas estornadas ou a nota não foi encontrada na tabela EIX
   //TDF - 29/06/11   
   If ((EasyGParam("MV_REAPNNF",,.F.) == .F. ) .Or. lNumNfAuto)
      
      IF TYPE("cNumero") == "U"
         cNumero:=""
      ENDIF
           
      If cTpNrNfs == "1" .OR. cTpNrNfs == "2"
		 cNumero:= NxTSx5Nota(cSerie,.T.,cTpNrNfs) //LRS - 08/07/2015
      ElseIf cTpNrNfs == "3"
         //lMudouNum := .T.
         cNumero   := Ma461NumNF(.T.,cSerie)
      EndIf

   EndIf   
   If !Empty(cNumero) .And. !Empty(cSerie) .And. (EMPTY(cControle) .OR. cProcesso # AvKey(Int_FE->NFEHAWB,"W6_HAWB"))
      cControle := AvKey(cNumero,"F1_DOC") + AvKey(cSerie,"F1_SERIE")
   EndIf
EndIf
//WFS ---

IF lMV_EASY_SIM

   SC7->(DBSETORDER(1))
   aItens:={}//Limpa os itens da tabela para nao acumular para a proxima nota
   INT_FD->(dbseek(INT_FE->NFENOTA))


   DO WHILE INT_FD->NFDNOTA == INT_FE->NFENOTA .AND. !INT_FD->(EOF())

      cCod_I := AvKey( LEFT(Int_FD->NFDCOD_I ,LEN(SB1->B1_COD)), "B1_COD")             //NCF - 28/03/2011 - Acerto na chave do Item
      cPo_NUM:= AvKey(Int_FD->NFDPO_NUM,"W2_PO_NUM")//LEFT(Int_FD->NFDPO_NUM,LEN(SW2->W2_PO_NUM))
		cNFEHAWB:=AvKey(Int_FE->NFEHAWB,"W7_HAWB")
      SB1->(DbSeek(cFilSB1+cCod_I))
      SW2->(DbSeek(cFilSW2+AVKEY(cPo_NUM,"W2_PO_NUM")))
      SW3->(DBSEEK(cFilSW3+AVKEY(cPo_NUM,"W3_PO_NUM")+Int_FD->NFDITEM))
      SW7->(dbseek(cFilSW7+cNFEHAWB+cPo_NUM+INT_FD->NFDITEM))
      SA2->(DBSEEK(cFilSA2+SW2->W2_FORN+SW2->W2_FORLOJ))
      cForn:=SW2->W2_FORN

      DO WHILE cFilSW7         == SW7->W7_FILIAL .and.;
               cNFEHAWB 		 == SW7->W7_HAWB   .and.;
               cPo_NUM         == SW7->W7_PO_NUM .and.;
               INT_FD->NFDITEM == SW7->W7_POSICAO.and.SW7->(!EOF())
         IF cCod_I  == SW7->W7_COD_I .AND. SW7->W7_PGI_NUM == INT_FD->NFDPLI
            EXIT
         Endif
         SW7->(dbskip())
      ENDDO

      SB1->(DBSEEK(cFilSB1+SW7->W7_COD_I))
      cLOCAL:=SB1->B1_LOCPAD
      IF PosO1_It_Solic(SW7->W7_CC,SW7->W7_SI_NUM,cCod_I,SW7->W7_REG,0)
         SW0->(DBSEEK(cFilSW0+SW1->W1_CC+SW1->W1_SI_NUM))
         IF SC1->(DBSEEK(cFilSC1+SW0->W0_C1_NUM+SW1->W1_POSICAO))
            cLOCAL   := SC1->C1_LOCAL
            cConta   := SC1->C1_CONTA 
            cItemCta := SC1->C1_ITEMCTA 
            cClvl    := SC1->C1_CLVL
         ENDIF
      ENDIF

      If ! Empty(SW3->W3_CTCUSTO)
         cCTCusto := SW3->W3_CTCUSTO
      Else
         cCTCusto := SB1->B1_CC
      EndIf
      if EMPTY(cConta) 
         cConta := SB1->B1_CONTA 
      endIf
      if EMPTY(cItemCta)
         cItemCta := SB1->B1_ITEMCC 
      endIf
      if EMPTY(cClvl)
         cClvl := SB1->B1_CLVL
      endIf

      nQTSEGUM:=0
      nQUANT  :=VAL(INT_FD->NFDQUANT) //If(cTipoNF=='2',0,VAL(INT_FD->NFDQUANT) ) //LGS-15/08/2014
      cSEGUM  :=SPACE(LEN(INT_FD->NFDUNI))
      cUNI    :=INT_FD->NFDUNI
      IF lMV_EASY_SIM
         aSegUM:=AV_Seg_Uni(SW7->W7_CC,SW7->W7_SI_NUM,cCod_I,SW7->W7_REG,VAL(INT_FD->NFDQUANT) )
         IF !EMPTY(aSegUM[2])
            If EasyGParam("MV_UNIDCOM",,2) == 2    //LGS-15/08/2014           
               nQTSEGUM:=VAL(INT_FD->NFDQUANT)//If(cTipoNF=='2',0,VAL(INT_FD->NFDQUANT) )
               nQUANT  :=aSegUM[2]			  //If(cTipoNF=='2',0,aSegUM[2])
            //Else
            //   nQTSEGUM:=aSegUM[2]         
            Endif   
            If SW0->(DBSeek(cFilSW0+SW7->W7_CC+SW7->W7_SI_NUM))
               SC1->(DBSETORDER(2))   
               If SC1->(DBSEEK(cFilSC1+cCod_I+SW0->W0_C1_NUM))
                  cUNI  :=SC1->C1_UM
                  cSEGUM:=SC1->C1_SEGUM
               Endif               
               SC1->(DBSETORDER(1))
            Endif
         ENDIF
      ENDIF
      
      IF !SC7->(DBSEEK(cFilSC7+SW2->W2_PO_SIGA+SW7->W7_POSICAO))
         SC7->(DBSEEK(cFilSC7+SW2->W2_PO_SIGA+'01  '+SW7->W7_POSICAO))
      ENDIF       
      
      nCIF:= VAL(INT_FD->NFDFOBRS)+VAL(INT_FD->NFDFRETE)+VAL(INT_FD->NFDSEGURO)+VAL(INT_FD->NFDDESPADU)// SVG - 10/05/2011 - Gravação da despasa aduneira compondo o CIF
      
      
      aItem:={}
      AADD(aItem,{"D1_COD"         ,cCod_I   ,NIL})  // codigo do produto
      IF cTipoNF # '2' .And. cTipoNF # '5'
         AADD(aItem,{"D1_PEDIDO"      ,SW2->W2_PO_SIGA       ,".T."})  // Pedido de compra
         AADD(aItem,{"D1_ITEMPC"      ,SW7->W7_POSICAO       ,".T."})  // Item de Pedido de compra
      ENDIF
      If !Empty(cUNI)
         AADD(aItem,{"D1_UM"          ,cUNI     ,NIL})  // unidade do produto
      ENDIF
      If !Empty(cSEGUM)
         AADD(aItem,{"D1_SEGUM"    ,cSEGUM   ,NIL})
         AADD(aItem,{"D1_QTSEGUM"  ,nQTSEGUM ,NIL})
      Endif	
      
      //MFR 01/10/2020 OSSME-5276
      If EasyGParam("MV_EIC0050",,.F.) .Or. cTipoNF == "2" // GFP - 26/08/2014
         nValUnit := VAL(INT_FD->NFDVALOR)
      Else
         nValUnit := VAL(INT_FD->NFDVALOR)/nQUANT
      EndIf
      if lSubII .And. cTipoNF != "2"
        nValUnit := nValUnit - (VAL(INT_FD->NFDII)/nQUANT)
      EndIf
      
      Aadd(aItem,{"D1_VUNIT"    ,nValUnit,NIL})// valor unitario do item
      Aadd(aItem,{"D1_QUANT", nQUANT, Nil})  // quantidade do produto	     
     //MFR 08/10/2020 OSSME-5185 
      AADD(aItem,{"D1_TOTAL"       , if(nQUANT==0,1,nQuant) * nValUnit,NIL})  // valor total do item (quantidade * preco) //LGS-08/07/2014
    
	  //AAF 21/03/2017 - Enviar o II
      IF SD1->(FIELDPOS("D1_II")) # 0
         AADD(aItem,{"D1_II"       ,VAL(INT_FD->NFDII)   ,".T."})
         AADD(aItem,{"D1_ALIQII"   ,VAL(INT_FD->NFDIITX) ,".T."})
      ENDIF
      
      IF cTipoNF <> '6' .OR. (lMV_NF_MAE .AND. cMV_NFFILHA <> '0')
         AADD(aItem,{"D1_VALIPI"      ,VAL(INT_FD->NFDIPI)   ,NIL})  // valor do IPI
         
         //LGS-27/06/2016 - Valida se foi informado a aliquota para calcular o diferimento
         IF !Empty(INT_FD->NFDPICMDIF)
            nD1_ICMSDIF := DITRANS(VAL(INT_FD->NFDICMS) * INT_FD->NFDPICMDIF/100,2)
            AADD(aItem,{"D1_VALICM"   ,VAL(INT_FD->NFDICMS) - nD1_ICMSDIF  ,NIL})  // valor do ICMS
            AADD(aItem,{"D1_ICMSDIF"  ,nD1_ICMSDIF            ,NIL})
         ELSE 
            AADD(aItem,{"D1_VALICM"   ,VAL(INT_FD->NFDICMS)  ,NIL})  // valor do ICMS
         ENDIF
         
         AADD(aItem,{"D1_IPI"         ,VAL(INT_FD->NFDIPITX) ,NIL})
         AADD(aItem,{"D1_PICM"        ,IF( cIntICMS == "2",VAL(INT_FD->NFDICMSTX),VAL(INT_FE->NFEICMSTX) ),NIL}) // GCC - 25/06/2013 - Grava a alíquota de ICMS da capa ou por Item
         AADD(aItem,{"D1_BASEICM"     ,VAL(INT_FD->NFDBASEICM),NIL})
         AADD(aItem,{"D1_BASEIPI"     ,VAL(INT_FD->NFDVALOR)  ,NIL})
      ENDIF
      IF !EMPTY(INT_FE->NFECFOP)
         AADD(aItem,{"D1_CF"          ,LEFT(ALLTRIM(INT_FE->NFECFOP),LEN(SD1->D1_CF))       ,NIL})  // Classificacao Fiscal                                                
      ENDIF
      AADD(aItem,{"D1_RATEIO"      ,'2'                   ,NIL})  // Rateio por centro de custo "1" Sim ou "2" Nao                                      
      AADD(aItem,{"D1_IPI"         ,VAL(INT_FD->NFDIPITX) ,NIL})
      AADD(aItem,{"D1_PICM"        ,IF( cIntICMS == "2",VAL(INT_FD->NFDICMSTX),VAL(INT_FE->NFEICMSTX) ),NIL})    // GCC - 25/06/2013 - Grava a alíquota de ICMS da capa ou por Item
      AADD(aItem,{"D1_PESO"        ,VAL(INT_FD->NFDPESOL) ,NIL})  // Peso Total do Item
      AADD(aItem,{"D1_FORNECE"     ,cForn                 ,NIL})
      AADD(aItem,{"D1_LOJA"        ,SA2->A2_LOJA          ,NIL})
      AADD(aItem,{"D1_LOCAL"       ,cLOCAL                ,NIL})
      AADD(aItem,{"D1_DOC"         ,cNumero               ,NIL})
      AADD(aItem,{"D1_SERIE"       ,SerieNfId(,4,"D1_SERIE",IN100CTD(dDtEmis,,'AAAAMMDD'),EasyGParam("MV_ESPEIC",,'NFE'),cSerie)                ,NIL})
      AADD(aItem,{"D1_EMISSAO"     ,IN100CTD(dDtEmis,,'AAAAMMDD'),NIL})
      AADD(aItem,{"D1_DTDIGIT"     ,dDataBase             ,NIL})               
      AADD(aItem,{"D1_TIPO"        ,IF(cTipoNF="2","C" ,"N" ),NIL})
      AADD(aItem,{"D1_TIPODOC"     ,IF(cTipoNF="2","13","10"),NIL})
      AADD(aItem,{"D1_TP"          ,SB1->B1_TIPO     ,NIL})
      //MFR OSME-6869  14/09/2021
      If SB1->B1_RASTRO $ "SL"
         AADD(aItem,{"D1_LOTECTL"     ,INT_FD->NFDLOTECTL ,NIL})
         AADD(aItem,{"D1_DTVALID"     ,INT_FD->NFDDTVALLT ,NIL})
      EndIf   

      If !Empty(cSEGUM)
      	AADD(aItem,{"D1_QTSEGUM" ,ConvUm(cCod_I,nQUANT,0,2),NIL})
      Endif
      If EasyGParam("MV_NF_AUTO",, "N") == "S"
         AAdd(aItem,{"D1_FORMUL", "S", Nil})
      EndIf	
      AADD(aItem,{"D1_BASEICM"     ,VAL(INT_FD->NFDBASEICM),NIL})
      AADD(aItem,{"D1_BASEIPI"     ,VAL(INT_FD->NFDVALOR)  ,NIL})
      AADD(aItem,{"D1_TEC"         ,INT_FD->NFDCLASFIS+INT_FD->NFDEX_NCM+SW3->W3_EX_NBM+SW7->W7_OPERACA,NIL})
      AADD(aItem,{"D1_CONHEC"      ,INT_FE->NFEHAWB  ,NIl}) 
      AADD(aItem,{"D1_TIPO_NF"     ,cTipoNF          ,NIL})

      AADD(aItem,{"D1_CC"          ,cCTCusto         ,Nil})
      AADD(aItem,{"D1_CONTA"       ,cConta           ,Nil})
      AADD(aItem,{"D1_ITEMCTA"     ,cItemCta         ,Nil})
      AADD(aItem,{"D1_CLVL"        ,cClvl            ,Nil})

      IF lCposCofMj   // GFP - 21/09/2015
         nValCMaj := 0
         SW2->(DbSeek(xFilial("SW2")+AvKey(Int_FD->NFDPO_NUM,"W2_PO_NUM")))
         SW3->(DBSEEK(xFilial("SW3")+AvKey(Int_FD->NFDPO_NUM,"W2_PO_NUM")+Int_FD->NFDITEM))
         SW6->(DBSEEK(xFilial("SW6")+AvKey(Int_FE->NFEHAWB,"W6_HAWB")))
         SW7->(dbseek(xFilial("SW7")+AvKey(Int_FE->NFEHAWB,"W6_HAWB")+AvKey(Int_FD->NFDPO_NUM,"W2_PO_NUM")+INT_FD->NFDITEM))   
         If !Empty(INT_FD->NFDALMJCOF) 
            SYT->(DBSetOrder(1))
            SYT->(dBSeek(xFILIAL("SYT")+AvKey(SW6->W6_IMPORT,"YT_COD_IMP")))
            
            SYD->(DBSetOrder(1)) 
            SYD->(dbSeek(xFILIAL("SYD")+AvKey(INT_FD->NFDCLASFIS,"WN_TEC")+AvKey(INT_FD->NFDEX_NCM,"WN_EX_NCM")+AvKey(SW3->W3_EX_NBM,"WN_EX_NBM")))  //INT_FD->NFDCLASFIS+INT_FD->NFDEX_NCM+SW3->W3_EX_NBM
            If RecLock("SYD",.F.)
               SYD->YD_MAJ_COF := If(SYT->YT_MJCOF $ cSim, INT_FD->NFDALMJCOF, 0)
               SYD->(MsUnLock())
            EndIf
         EndIf
         nPerMajCOF := EicGetPerMaj(AvKey(INT_FD->NFDCLASFIS,"WN_TEC")+AvKey(INT_FD->NFDEX_NCM,"WN_EX_NCM")+AvKey(SW3->W3_EX_NBM,"WN_EX_NBM"), SW7->W7_OPERACA, SW6->W6_IMPORT, "COFINS")
         nValCMaj   := DITrans(VAL(INT_FD->NFDBASCOF) * (nPerMajCOF / 100), 2)
     
         AADD(aItem,{"D1_VALCMAJ"  , nValCMaj ,NIL})
      ENDIF
      IF lCposPisMj   // GFP - 21/09/2015
         nValPMaj := 0
         SW2->(DbSeek(xFilial("SW2")+AvKey(Int_FD->NFDPO_NUM,"W2_PO_NUM")))
         SW3->(DBSEEK(xFilial("SW3")+AvKey(Int_FD->NFDPO_NUM,"W2_PO_NUM")+Int_FD->NFDITEM))
         SW6->(DBSEEK(xFilial("SW6")+AvKey(Int_FE->NFEHAWB,"W6_HAWB")))
         SW7->(dbseek(xFilial("SW7")+AvKey(Int_FE->NFEHAWB,"W6_HAWB")+AvKey(Int_FD->NFDPO_NUM,"W2_PO_NUM")+INT_FD->NFDITEM))
         
         nPerMajPIS := EicGetPerMaj(AvKey(INT_FD->NFDCLASFIS,"WN_TEC")+AvKey(INT_FD->NFDEX_NCM,"WN_EX_NCM")+AvKey(SW3->W3_EX_NBM,"WN_EX_NBM"), SW7->W7_OPERACA, SW6->W6_IMPORT, "PIS")
         nValPMaj := DITrans(VAL(INT_FD->NFDBASPIS) * (nPerMajPIS / 100), 2)
     
         AADD(aItem,{"D1_VALPMAJ"  , nValPMaj ,NIL})
      ENDIF
      IF cTipoNF=='2' .Or. cTipoNF=='6'  // Alfredo Magalhaes - Microsiga
         IF SWN->(DBSEEK(cFilSWN+SW6->W6_HAWB))	//JWJ - Tratamento igual ao do EICDI154
		      DO WHILE SWN->(!EOF())                    .AND.;
		               SWN->WN_FILIAL  == cFilSWN .AND.;
		               SWN->WN_HAWB    == SW6->W6_HAWB
		               
		         IF SWN->WN_INVOICE == AvKey(Int_FD->NFDFATURA,"WN_INVOICE") .AND.;
		            AvKey(SWN->WN_PO_EIC,"W2_PO_NUM") == AvKey(Int_FD->NFDPO_NUM,"W2_PO_NUM")  .AND.;
		            SWN->WN_PGI_NUM == INT_FD->NFDPLI .AND.;
		            SWN->WN_ITEM    == INT_FD->NFDITEM .AND.;
		            SWN->WN_TIPO_NF $ "1,3,5"

				         AADD(aItem,{"D1_NFORI"    ,SWN->WN_DOC      ,NIL})
				         AADD(aItem,{"D1_SERIORI"  ,SWN->WN_SERIE    ,NIL})
				
				         //JWJ 18/05/2006: Controle para a numeração dos itens (WN_LINHA) POR NOTA
				         IF (nNFLin := ASCAN(aNFLin, {|x|x[1]==SWN->(WN_DOC+WN_SERIE)}) ) == 0
				            AADD(aItem,{"D1_ITEMORI"  ,STRZERO(1, 4) , .F.})
				            AADD(aNFLin, {SWN->(WN_DOC+WN_SERIE), 1})
				         Else
				            aNFLin[nNFLin,2] += 1                                     
				            AADD(aItem,{"D1_ITEMORI"  ,STRZERO(aNFLin[nNFLin,2], 4) , .F.})
				         Endif
					ENDIF
		         SWN->(DbSkip())
		      ENDDO        
         Endif		//SWN->SEEK
      Endif		//CTIPONF=='2'

      IF cTipoNF == "2"
         AADD(aItem,{"D1_DESPESA",0,})   
      ELSEIF cTipoNF <> '6' .OR. (lMV_NF_MAE .AND. cMV_NFFILHA <> '0')// Notas 1 3 9 //AWR - 16/02/2009
         AADD(aItem,{"D1_DESPESA",VAL(INT_FD->NFDDESPESA)   ,NIL}) 
      ENDIF

      IF lMV_PIS_EIC .AND. cTipoNF <> '6' .OR. (lMV_NF_MAE .AND. cMV_NFFILHA <> '0')
         aRelImp  := MaFisRelImp("MT100",{ "SD1" })
         If !Empty( S:= aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_BASEPS2"} ) )
            cCpoBsPis:= aRelImp[S,2]
         EndIf
         If !Empty( S:= aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_VALPS2"} ) )
            cCpoVlPis:= aRelImp[S,2]
         EndIf
         If !Empty( S:= aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_ALIQPS2"} ) )
            cCpoAlPis:= aRelImp[S,2]
         EndIf
         If !Empty( S:= aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_ALIQCF2"} ) )
            cCpoAlCof:= aRelImp[S,2]
         EndIf
         If !Empty( S:= aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_BASECF2"} ) )
            cCpoBsCof:= aRelImp[S,2]
         EndIf 	
         If !Empty( S:= aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_VALCF2"} ) )
            cCpoVlCof:= aRelImp[S,2]
         EndIf
         AADD(aItem,{cCpoBsPis,VAL(INT_FD->NFDBASPIS),})
         AADD(aItem,{cCpoVlPis,VAL(INT_FD->NFDVLRPIS),})
         AADD(aItem,{cCpoAlPis,VAL(INT_FD->NFDPERPIS),})
         AADD(aItem,{cCpoAlCof,VAL(INT_FD->NFDPERCOF),})
         AADD(aItem,{cCpoBsCof,VAL(INT_FD->NFDBASCOF),})
         AADD(aItem,{cCpoVlCof,VAL(INT_FD->NFDVLRCOF),})
      ENDIF
      

      AADD(aItens,ACLONE(aItem))
      
      If EasyEntryPoint("IN100CLI")
         ExecBlock("IN100CLI",.F.,.F.,"GRVFD1")
      ENDIF
      //WFS 18/11/2008 - Tratamento para a NFe ---
      cChave1 := AvKey(Int_FE->NFEHAWB,"W6_HAWB") + cNumero

      if (npos:= ascan(aGrv_SF1,{|aSF1|aSF1[1]==cChave1})) = 0
          aadd(aGrv_SF1,{cChave1            , ;
                     VAL(INT_FD->NFDPESOL)  , ;
                     VAL(INT_FD->NFDFOBRS)  , ;
                     VAL(INT_FD->NFDFRETE)  , ;
                     VAL(INT_FD->NFDSEGURO) , ;
                     nCIF                   , ;           
                     VAL(INT_FD->NFDII)     , ;
                     VAL(INT_FD->NFDIPI)    , ;
                     VAL(INT_FD->NFDICMS)   , ;
                     VAL(INT_FD->NFDDESPESA)} )
      else
         aGrv_SF1[nPos,2] += VAL(INT_FD->NFDPESOL)
         aGrv_SF1[nPos,3] += VAL(INT_FD->NFDFOBRS)
         aGrv_SF1[nPos,4] += VAL(INT_FD->NFDFRETE)
         aGrv_SF1[nPos,5] += VAL(INT_FD->NFDSEGURO)
         aGrv_SF1[nPos,6] += nCIF
         aGrv_SF1[nPos,7] += VAL(INT_FD->NFDII)
         aGrv_SF1[nPos,8] += VAL(INT_FD->NFDIPI)
         aGrv_SF1[nPos,9] += VAL(INT_FD->NFDICMS)
         aGrv_SF1[nPos,10]+= VAL(INT_FD->NFDDESPESA)
      endif

      INT_FD->(dbskip())

   Enddo

   IF !IN100GRVSF1()
      BREAK
   ENDIF

ENDIF

SB1->(DBSETORDER(1))
SW8->(DBSETORDER(6))
aNFLin := {}
nNFLin := 0
nTotal := 0
nQtdItens := 0
nQtdTotal := 0

bAction := {|| (nTotal += val(NFDFOBRS)) , nQtdItens++, nQtdTotal+=val(NFDQUANT) }

INT_FD->( dbgotop() )
INT_FD->( dbeval( bAction , , {|| NFDNOTA == INT_FE->NFENOTA .AND. !eof() }) )
INT_FD->( dbseek(INT_FE->NFENOTA) )

DO WHILE INT_FD->NFDNOTA == INT_FE->NFENOTA .AND. !INT_FD->(EOF()) .AND. !lMSErroAuto

   cCod_I := AvKey( LEFT(Int_FD->NFDCOD_I ,LEN(SB1->B1_COD)), "B1_COD")                 //NCF - 28/03/2011 - Acerto na chave do Item
   cPo_NUM:= AvKey(Int_FD->NFDPO_NUM,"W2_PO_NUM")
	cNFEHAWB:=AvKey(Int_FE->NFEHAWB,"W6_HAWB")
   SW2->(DbSeek(cFilSW2+AVKEY(cPo_NUM,"W2_PO_NUM")))                                           //MJB-SAP-0401
   SW3->(DBSEEK(cFilSW3+AVKEY(cPo_NUM,"W3_PO_NUM")+Int_FD->NFDITEM))                           //MJB-SAP-0401
   SW6->(DBSEEK(cFilSW6+cNFEHAWB))
   SW7->(dbseek(cFilSW7+cNFEHAWB+cPo_NUM+INT_FD->NFDITEM))                                     //MJB-SAP-0401
   SA2->(DBSEEK(cFilSA2+SW2->W2_FORN+SW2->W2_FORLOJ))
   cForn:=SW2->W2_FORN

   DO WHILE cFilSW7         == SW7->W7_FILIAL .and.;
            cNFEHAWB 		 == SW7->W7_HAWB   .and.;
            cPo_NUM         == SW7->W7_PO_NUM .and.;
            INT_FD->NFDITEM == SW7->W7_POSICAO.and.SW7->(!EOF())
      IF cCod_I  == SW7->W7_COD_I .AND. SW7->W7_PGI_NUM == INT_FD->NFDPLI
         EXIT
      Endif
      SW7->(dbskip())
   ENDDO

   if nTotal > SW6->W6_FOB_TOT .and. oWNRateio == nil
                              //New(nValorARatear,nValorTotal,nQtdItens,nDecimais)
      oWNRateio := EasyRateio():New(nTotal,nQtdTotal,nQtdItens,AVSX3("WN_RATEIO",4))
   endif

   SWN->(reclock("SWN",.T.))
   SWN->WN_FILIAL  := cFilSWN
   SWN->WN_TIPO_NF := cTipoNF
   SWN->WN_HAWB    := cNFEHAWB
   //WFS 18/11/2008 - Tratamento para a NFe ---
   //SWN->WN_DOC     := INT_FE->NFENOTA
   //SWN->WN_SERIE   := INT_FE->NFESERIE
   SWN->WN_DOC     := cNumero
   //SWN->WN_SERIE   := cSerie
   SerieNfId("SWN",1,"WN_SERIE",IN100CTD(dDtEmis,,'AAAAMMDD'),EasyGParam("MV_ESPEIC",,'NFE'),cSerie)
   //WFS ---
   SWN->WN_TEC     := INT_FD->NFDCLASFIS
   SWN->WN_EX_NCM  := INT_FD->NFDEX_NCM
   SWN->WN_EX_NBM  := SW3->W3_EX_NBM
   SWN->WN_PO_EIC  := cPo_NUM
   cPedidoSiga     := cPo_NUM
   //MFR 24/10/2019 OSSME-3993
   If SC7->(DBSEEK(cFilSC7+SW2->W2_PO_SIGA+SW7->W7_POSICAO))
      cPedidoSiga:= SW2->W2_PO_SIGA
   ElseIf SC7->(DBSEEK(cFilSC7+SW2->W2_PO_SIGA+'01  '+SW7->W7_POSICAO))
      cPedidoSiga:= SW2->W2_PO_SIGA
   EndIf   
   SWN->WN_PO_NUM  := cPedidoSiga
   SWN->WN_PGI_NUM := INT_FD->NFDPLI
   SWN->WN_ITEM    := INT_FD->NFDITEM
   
   // GCC - 03/12/2013 - Tratamento na quantidade da nota filha para que não seja maior que a nota mãe
   nQtdeNF := Val(INT_FD->NFDQUANT)
   If cTipoNF=='6'
      If (lValQtde .And. nQtdeNF <= ((SW7->W7_QTDE * 0.05) + SW7->W7_SALDO_Q)) .Or.(!lValQtde .AND. (nQtdeNF <= SW7->W7_SALDO_Q))
		   SWN->WN_QUANT := VAL(INT_FD->NFDQUANT)
      Else
		 MsgInfo(STR0791) // "Valor e/ou quantidade maior que o informado na Nota Fiscal Mãe (NFM)."
         lRet := .F.
         Break		
      EndIf
   Else
      SWN->WN_QUANT := VAL(INT_FD->NFDQUANT)
   EndIf

   if nTotal > SW6->W6_FOB_TOT .and. oWNRateio <> nil

      nRateio := oWNRateio:GetItemRateio(VAL(INT_FD->NFDQUANT))
      SWN->WN_RATEIO := Round( nRateio/nTotal , AVSX3("WN_RATEIO",4) )
   endif
      
   If EasyGParam("MV_EIC0050",,.F.)
      SWN->WN_VALOR   := VAL(INT_FD->NFDVALOR)*VAL(INT_FD->NFDQUANT)
   Else
      SWN->WN_VALOR   := VAL(INT_FD->NFDVALOR)
   Endif

     
   SWN->WN_PRECO   := SW7->W7_PRECO  
   SWN->WN_FOB_R   := VAL(INT_FD->NFDFOBRS)
   SWN->WN_PRODUTO := INT_FD->NFDCOD_I     
   SWN->WN_VALIPI  := VAL(INT_FD->NFDIPI) 
   SWN->WN_VALICM  := VAL(INT_FD->NFDICMS)
   SWN->WN_OPERACA := SW7->W7_OPERACA
   SWN->WN_FORNECE := cForn
   SWN->WN_LOJA    := SA2->A2_LOJA
   SWN->WN_ICMS_A  := IF( cIntICMS == "2",VAL(INT_FD->NFDICMSTX),VAL(INT_FE->NFEICMSTX) ) // GCC - 25/06/2013 - Gravar a alíquota de ICMS da capa ou por item
   SWN->WN_DESCR   := INT_FD->NFDDESCR
   SWN->WN_UNI     := INT_FD->NFDUNI
   SWN->WN_IPITX   := VAL(INT_FD->NFDIPITX)
   SWN->WN_IPIVAL  := VAL(INT_FD->NFDIPI)
   SWN->WN_IITX    := VAL(INT_FD->NFDIITX)
   SWN->WN_IIVAL   := VAL(INT_FD->NFDII)
   
   If EasyGParam("MV_EIC0050",,.F.)
      SWN->WN_PRUNI   := VAL(INT_FD->NFDVALOR)  //GFP - 27/08/2014
   Else
      SWN->WN_PRUNI   := VAL(INT_FD->NFDVALOR)/VAL(INT_FD->NFDQUANT) 
   EndIf
   SWN->WN_VL_ICM  := VAL(INT_FD->NFDICMS)
   SWN->WN_PESOL   := VAL(INT_FD->NFDPESOL)
   SWN->WN_SEGURO  := VAL(INT_FD->NFDSEGURO)
   SWN->WN_CIF     := VAL(INT_FD->NFDFOBRS)+;
                      VAL(INT_FD->NFDFRETE)+;
                      VAL(INT_FD->NFDSEGURO)+;
                      IF(lMV_GRCPNFE,VAL(INT_FD->NFDDESPADU),0)// SVG - 10/05/2011 - Gravação da despasa aduneira compondo o CIF
   SWN->WN_DESPESAS:= VAL(INT_FD->NFDDESPESA)
   SWN->WN_DESPICM := VAL(INT_FD->NFDDESPESA) // SVG - 20/12/2010 - Gravação da despasa base de icms
   SWN->WN_FRETE   := VAL(INT_FD->NFDFRETE)
   SWN->WN_SI_NUM  := SW7->W7_SI_NUM
   SWN->WN_CC      := SW7->W7_CC
   SWN->WN_CFO     := LEFT(ALLTRIM(INT_FE->NFECFOP),LEN(SWN->WN_CFO))
   //GFP - 27/08/2014
   If EasyGParam("MV_EIC0050",,.F.)
      SWN->WN_IPIBASE := VAL(INT_FD->NFDVALOR)*VAL(INT_FD->NFDQUANT)
   Else
      SWN->WN_IPIBASE := VAL(INT_FD->NFDVALOR)
   Endif
   SWN->WN_PGI_NUM := SW7->W7_PGI_NUM
   SWN->WN_INVOICE := INT_FD->NFDFATURA
   SWN->WN_LOTECTL := INT_FD->NFDLOTECTL//ASR 16/12/2005
   SWN->WN_DTVALID := INT_FD->NFDDTVALLT//ASR 16/12/2005
   IF cTipoNF <> '6' .OR. (lMV_NF_MAE .AND. cMV_NFFILHA <> '0')
      
      nD1_ICMSDIF  := 0
      
      //LGS-27/06/2016 - Valida se foi informado a aliquota para calcular o diferimento
      If !Empty(INT_FD->NFDPICMDIF)
         nD1_ICMSDIF     := DITRANS(VAL(INT_FD->NFDICMS) * INT_FD->NFDPICMDIF/100,2)
         SWN->WN_PICMDIF := INT_FD->NFDPICMDIF
         SWN->WN_VICMDIF := nD1_ICMSDIF
      EndIf
      
      SWN->WN_VALIPI  := VAL(INT_FD->NFDIPI) 
      SWN->WN_VALICM  := VAL(INT_FD->NFDICMS) - nD1_ICMSDIF //LGS-27/06/2016
      SWN->WN_ICMS_A  := IF( cIntICMS == "2",VAL(INT_FD->NFDICMSTX),VAL(INT_FE->NFEICMSTX) ) // GCC - 25/06/2013 - Grava a alíquota de ICMS da capa ou por item
      SWN->WN_IPITX   := VAL(INT_FD->NFDIPITX)
      SWN->WN_IPIVAL  := VAL(INT_FD->NFDIPI)
      SWN->WN_VL_ICM  := VAL(INT_FD->NFDICMS) - nD1_ICMSDIF //LGS-27/06/2016
      SWN->WN_BASEICM := VAL(INT_FD->NFDBASEICM)
      SWN->WN_PERPIS  := VAL(INT_FD->NFDPERPIS)
      SWN->WN_VLUPIS  := VAL(INT_FD->NFDVLUPIS)
      SWN->WN_BASPIS  := VAL(INT_FD->NFDBASPIS)
      SWN->WN_VLRPIS  := VAL(INT_FD->NFDVLRPIS)
      SWN->WN_PERCOF  := VAL(INT_FD->NFDPERCOF)
      SWN->WN_VLUCOF  := VAL(INT_FD->NFDVLUCOF)
      SWN->WN_BASCOF  := VAL(INT_FD->NFDBASCOF)

      //TRP - 31/07/2012 - Gravação do valor majorado do COFINS
      If lCposCofMj
         // GFP - 30/07/2013
         If !Empty(INT_FD->NFDALMJCOF) 
            SYT->(DBSetOrder(1))
            SYT->(dBSeek(xFILIAL("SYT")+AvKey(SW6->W6_IMPORT,"YT_COD_IMP")))
            
            SYD->(DBSetOrder(1)) 
            SYD->(dbSeek(xFILIAL("SYD")+SWN->(WN_TEC+WN_EX_NCM+WN_EX_NBM)))
            If RecLock("SYD",.F.)
               SYD->YD_MAJ_COF := If(SYT->YT_MJCOF $ cSim, INT_FD->NFDALMJCOF, 0)
               SYD->(MsUnLock())
            EndIf
         EndIf
         SWN->WN_ALCOFM := (nPerMajCOF := EicGetPerMaj(SWN->(WN_TEC+WN_EX_NCM+WN_EX_NBM), SWN->WN_OPERACA, SW6->W6_IMPORT, "COFINS"))
         SWN->WN_VLCOFM := DITrans(SWN->WN_BASCOF * (nPerMajCOF / 100), 2)
      EndIf
      //GFP - 11/06/2013 - Gravação do valor majorado do PIS
      If lCposPisMj
         SWN->WN_ALPISM := (nPerMajPIS := EicGetPerMaj(SWN->(WN_TEC+WN_EX_NCM+WN_EX_NBM), SWN->WN_OPERACA, SW6->W6_IMPORT, "PIS"))
         SWN->WN_VLPISM := DITrans(SWN->WN_BASPIS * (nPerMajPIS / 100), 2)
      EndIf

      SWN->WN_VLRCOF  := VAL(INT_FD->NFDVLRCOF)

   ENDIF   
   IF lMV_GRCPNFE//Campo novo NFE - AWR 04/11/2008
      SWN->WN_ADICAO :=INT_FD->NFDADICAO
      SWN->WN_SEQ_ADI:=INT_FD->NFDSEQ_ADI
      SWN->WN_PREDICM:=VAL(INT_FE->NFEPREDICM)
      SWN->WN_DESCONI:=VAL(INT_FD->NFDDESCONI)
      SWN->WN_VLRIOF :=VAL(INT_FD->NFDVLRIOF)
      SWN->WN_DESPADU:=VAL(INT_FD->NFDDESPADU)
      SWN->WN_ALUIPI :=VAL(INT_FD->NFDALUIPI)
      SWN->WN_QTUIPI :=VAL(INT_FD->NFDQTUIPI)
      SWN->WN_QTUPIS :=VAL(INT_FD->NFDQTUPIS)
      SWN->WN_QTUCOF :=VAL(INT_FD->NFDQTUCOF)
   ENDIF

   cChave1 := SWN->WN_DOC+SWN->WN_SERIE

   //JWJ 18/05/2006: Controle para a numeração dos itens (WN_LINHA) POR NOTA
   IF (nNFLin := ASCAN(aNFLin, {|x|x[1]==cChave1}) ) == 0
      SWN->WN_LINHA := 1
      AADD(aNFLin, {cChave1, 1})
   Else
      aNFLin[nNFLin,2] += 1
      SWN->WN_LINHA := aNFLin[nNFLin,2]
   Endif

   IF lMV_EASY_SIM
      SB1->(DBSEEK(cFilSB1+cCod_I))    
      aSegUM:=AV_Seg_Uni(SW7->W7_CC,SW7->W7_SI_NUM,SW7->W7_COD_I,SW7->W7_REG,SW7->W7_QTDE)
      IF !EMPTY(aSegUM[2])
         IF GetNewPar("MV_UNIDCOM",2) == 2
            SWN->WN_PRECO  :=(SW7->W7_QTDE * SW7->W7_PRECO) / aSegUM[2]
            SWN->WN_QTSEGUM:= If(cTipoNF=='2',0,SW7->W7_QTDE)
            SWN->WN_QUANT  := If(cTipoNF=='2',0,aSegUM[2])
         ELSE
            SWN->WN_QTSEGUM:=aSegUM[2]
         ENDIF
         SWN->WN_SEGUM:=aSegUM[1]
       ENDIF              
   ENDIF
   
   //LGS-04/03/2015
   IF SWN->(FieldPos("WN_NVE")) # 0 .And. INT_FD->(FieldPos("NFDNVE")) # 0
      SWN->WN_NVE := INT_FD->NFDNVE
   ENDIF
   IF SWN->(FieldPos("WN_AC")) # 0 .And. INT_FD->(FieldPos("NFDATO")) # 0
      SWN->WN_AC := INT_FD->NFDATO
   ENDIF
   IF SWN->(FieldPos("WN_AFRMM")) # 0 .And. INT_FD->(FieldPos("NFDAFRMM")) # 0
      SWN->WN_AFRMM := INT_FD->NFDAFRMM
   ENDIF

   IF !lMV_EASY_SIM
   
      if (npos:= ascan(aGrv_SF1,{|aSF1|aSF1[1]==cChave1})) = 0
          aadd(aGrv_SF1,{cChave1         , ;
                     SWN->WN_PESOL   , ;
                     VAL(INT_FD->NFDFOBRS), ;
                     SWN->WN_FRETE   , ;
                     SWN->WN_SEGURO  , ;
                     SWN->WN_CIF     , ;
                     SWN->WN_IIVAL   , ;
                     SWN->WN_IPIVAL  , ;
                     SWN->WN_VL_ICM  , ;
                     SWN->WN_DESPESAS} )
      else
         aGrv_SF1[nPos,2] += SWN->WN_PESOL
         aGrv_SF1[nPos,3] += VAL(INT_FD->NFDFOBRS)
         aGrv_SF1[nPos,4] += SWN->WN_FRETE
         aGrv_SF1[nPos,5] += SWN->WN_SEGURO
         aGrv_SF1[nPos,6] += SWN->WN_CIF
         aGrv_SF1[nPos,7] += SWN->WN_IIVAL
         aGrv_SF1[nPos,8] += SWN->WN_IPIVAL
         aGrv_SF1[nPos,9] += SWN->WN_VL_ICM
         aGrv_SF1[nPos,10]+= SWN->WN_DESPESAS
      endif

   endif

   If EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"GRVFD")
   ENDIF 
   
        
   //igorchiba 23/12/2010
   // chamar a funçao do avinteg para o item da nota fiscal , esta funçao grava na base os campos que não tratados pelo EICIN100
   IF ValType(bUpDate) == "B"
      oldcfuncao:=cfuncao
      cfuncao   :="FD"
      If FindFunction("AvIntExtra")
         EasyExRdm("AvIntExtra")
      EndIf         
      cfuncao   :=oldcfuncao
   ENDIF

   SWN->(MSUNLOCK())
   
   //WFS 18/11/2008 - Tratamento para a NFe ---
   //Se existe o campo WN_INTDESP, gravar com "S"
   If SWN->(FieldPos("WN_INTDESP")) > 0
      SWN->(Reclock("SWN",.F.))
         SWN->WN_INTDESP:= "S"
      SWN->(MSUnlock())
   EndIf
   //WFS ---
            
   //JVR - 24/03/2010 - Tratamento para gravação de adição sem necessidade de numero de invoice na integração.
   SW9->(DbSetOrder(3))
   If lMV_GRCPNFE .and. SW9->(DbSeek(cFilSW9 + SWN->WN_HAWB))//JVR - 22/06/2010 - validação de Campos novos NFE
      While SW9->(!EOF()) .and. SW9->W9_HAWB == AvKey(Int_FE->NFEHAWB,"W9_HAWB")
         If SW8->(DbSeek(cFilSW8 + SW9->(W9_HAWB + W9_INVOICE) + cPo_NUM + INT_FD->NFDITEM + INT_FD->NFDPLI))
            SW8->(Reclock("SW8",.F.))
            SW8->W8_ADICAO  := INT_FD->NFDADICAO
            SW8->W8_SEQ_ADI := INT_FD->NFDSEQ_ADI
            SW8->(MSUnlock())
         EndIf
         SW9->(DbSkip())
      EndDo     
   EndIf

	//THTS - 16/08/2019 - Projeto Recebimento de LI na integração (OSSME-3064)
	If !Empty(INT_FD->NFDPLIREG) //Caso o item possua LI
		SWP->(dbSetOrder(1)) //WP_FILIAL + WP_PGI_NUM + WP_SEQ_LI + WP_NR_MAQ
		If SWP->(dbSeek(cFilSWP + SW7->W7_PGI_NUM + SW7->W7_SEQ_LI))
			SWP->(RecLock("SWP",.F.))
			SWP->WP_REGIST	:= INT_FD->NFDPLIREG
			If !Empty(INT_FD->NFDLISUBS)
				SWP->WP_SUBST	:= INT_FD->NFDLISUBS
			EndIf
			SWP->(MsUnlock())
		EndIf
	EndIf

   INT_FD->(dbskip())
Enddo

IF !lMV_EASY_SIM
   IN100GRVSF1()
ENDIF


SYB->(DBSETORDER(1))
SWD->(DBSETORDER(1))
SWD->(DBSEEK(cFilSWD+AvKey(Int_FE->NFEHAWB,"WD_HAWB")))

DO WHILE SWD->(!EOF()) .AND. SWD->WD_HAWB = AvKey(Int_FE->NFEHAWB,"WD_HAWB")
   IF !SYB->(DbSeek(cFilSYB+SWD->WD_DESPESA )) .Or. (LEFT(SWD->WD_DESPESA,1) $ "129" .And. cTipoNF == '2') //Nota complementar
      SWD->(DBSKIP())
      LOOP
   ENDIF
   
   If (LEFT(SWD->WD_DESPESA,1) $ "12") .Or. (!(SYB->YB_BASECUS $ cNao) .And. (SYB->YB_BASEIMP $ cSim .OR. SYB->YB_BASEICM $ cSim))
      If Empty(SWD->WD_NF_COMP)
         SWD->(RECLOCK("SWD",.F.))
         //WFS 18/11/2008 - Tratamento para a NFe ---
         //SWD->WD_NF_COMP := INT_FE->NFENOTA
         //SWD->WD_SE_NFC  := INT_FE->NFESERIE
         SWD->WD_NF_COMP := cNumero
         SWD->WD_SE_NFC  := cSerie
      EndIf
      //WFS ---
      SWD->(MSUNLOCK())
   ENDIF

   SWD->(DBSKIP())
ENDDO

SW6->(DBSEEK(cFilSW6+AvKey(Int_FE->NFEHAWB,"W6_HAWB")))                                                                //MJB-SAP-0401
SW6->(RecLock("SW6",.F.))

If (cTipoNF=="1" .OR. cTipoNF=="3" .OR. cTipoNF=="5") .AND. !lMSErroAuto
   IF(!EMPTY(INT_FE->NFEDTREGDI),SW6->W6_DTREG_D :=IN100CTD(Int_FE->NFEDTREGDI,,'AAAAMMDD'),)//ASK 17/12/2007 - Gravação da data da di
   
   //MCF - 15/04/2016
   IF !EMPTY(INT_FE->NFENUMDI) .And. !EasyGParam("MV_TEM_DI",,.F.) .And. SW6->(FieldPos("W6_VERSAO")) > 0
      SW6->W6_VERSAO := GeraVersaoDI(.T.,INT_FE->NFENUMDI)
      IF SW6->W6_VERSAO <> "00"
         cObsDI := STR0792 + INT_FE->NFENUMDI // "Retificação da DI número + XXXXXXXXXXX"
         EasyMSMM(,AVSX3("W6_VMDIOBS",AV_TAMANHO),,cObsDI,INCMEMO,,,"SW6","W6_DI_OBS")
      ENDIF
   ENDIF
   
   IF(!EMPTY(INT_FE->NFENUMDI  ),SW6->W6_DI_NUM  :=INT_FE->NFENUMDI,)
   
   //TRP - 31/08/2012 - Gravar os dados da DI na capa do Câmbio.
   IF !EMPTY(INT_FE->NFENUMDI)   
      SWA->(DbSetOrder(1))
      IF SWA->(DbSeek(xFilial("SWA")+ AvKey(Int_FE->NFEHAWB,"WA_HAWB")))
         SWA->(Reclock("SWA",.F.))
         SWA->WA_DI_NUM:= AvKey(Int_FE->NFEHAWB,"WA_HAWB")
         SWA->(MsUnlock())
      ENDIF  
   ENDIF
   
   IF !EMPTY(INT_FE->NFEDTREGDI)  
      SWA->(DbSetOrder(1))
      IF SWA->(DbSeek(xFilial("SWA")+ AvKey(Int_FE->NFEHAWB,"WA_HAWB")))
         SWA->(Reclock("SWA",.F.))
         SWA->WA_DTREG_D:= IN100CTD(Int_FE->NFEDTREGDI,,'AAAAMMDD')
         SWA->(MsUnlock())
      ENDIF  
   ENDIF
   
   //WFS 18/11/2008 - Tratamento para a NFe ---
   //IF(!EMPTY(INT_FE->NFENOTA   ),SW6->W6_NF_ENT  :=alltrim(INT_FE->NFENOTA),)
   //IF(!EMPTY(INT_FE->NFESERIE  ),SW6->W6_SE_NF   :=alltrim(INT_FE->NFESERIE),)
   //IF(!EMPTY(Int_FE->NFEDT_EMIS),SW6->W6_DT_NF   :=IN100CTD(Int_FE->NFEDT_EMIS,,'AAAAMMDD'),)             //MJB-SAP-1100
   SW6->W6_NF_ENT  := AllTrim(cNumero)
   SW6->W6_SE_NF   := AllTrim(cSerie)
   SW6->W6_DT_NF   := IN100CTD(dDtEmis,,'AAAAMMDD')
   //WFS ---
   IF(!EMPTY(INT_FE->NFETOTNOTA),SW6->W6_VL_NF   +=VAL(INT_FE->NFETOTNOTA),)
Endif

If (cTipoNF=="2" .And. Empty(SW6->W6_NF_COMP)) .AND. !lMSErroAuto
   //WFS 18/11/2008 - Tratamento para a NFe ---
   //SW6->W6_NF_COMP:=alltrim(INT_FE->NFENOTA)
   //SW6->W6_SE_NFC :=alltrim(INT_FE->NFESERIE)
   //SW6->W6_DT_NFC :=IN100CTD(Int_FE->NFEDT_EMIS,,'AAAAMMDD')              //MJB-SAP-1100
   SW6->W6_NF_COMP:= AllTrim(cNumero)
   SW6->W6_SE_NFC := AllTrim(cSerie)
   SW6->W6_DT_NFC :=IN100CTD(dDtEmis,,'AAAAMMDD')
   //WFS ---   
   SW6->W6_VL_NFC :=VAL(INT_FE->NFETOTNOTA)
Endif

SW7->(dbsetorder(1))
SW3->(DBSETORDER(1))
SYU->(DBSETORDER(1))

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"GRVFEFIM")
ENDIF

End Sequence

End Transaction

IF lMSErroAuto
   MostraErro()
   RETURN .F.
ENDIF

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"POS_GRVFEFIM")
ENDIF

RETURN lRet

*-----------------------------------------------------------------------------
FUNCTION IN100GRVSF1()
*-----------------------------------------------------------------------------
Local GRV, i
lMSHelpAuto := .F.
lPosSF1:=.T.
SF1->(DBSETORDER(1))
For i := 1 to len(aGrv_SF1)

   aCab := {}
   AADD(aCab,{"F1_TIPO"        ,IF(cTipoNF=='2',"C","N"),NIL})// TIPO DA NOTA - "N"ORMAL OU "C"OMPLEMENTAR
   //WFS 18/11/2008 - Tratamento para a NFe ---
   //AADD(aCab,{"F1_DOC"         ,INT_FE->NFENOTA   ,NIL})   // NUMERO DA NOTA
   //AADD(aCab,{"F1_SERIE"       ,INT_FE->NFESERIE  ,NIL})   // SERIE DA NOTA
   //AADD(aCab,{"F1_EMISSAO"     ,IN100CTD(Int_FE->NFEDT_EMIS,,'AAAAMMDD'),NIL})   // DATA DA EMISSAO DA NOTA                                 
   AADD(aCab,{"F1_DOC"         ,cNumero         ,NIL})   // NUMERO DA NOTA
   AADD(aCab,{"F1_SERIE"       ,SerieNfId(,4,"F1_SERIE",IN100CTD(dDtEmis,,'AAAAMMDD'),EasyGParam("MV_ESPEIC",,'NFE'),cSerie)          ,NIL})   // SERIE DA NOTA
   AADD(aCab,{"F1_EMISSAO"     ,IN100CTD(dDtEmis,,'AAAAMMDD'),NIL})   // DATA DA EMISSAO DA NOTA                                 
   //WFS ---
   AADD(aCab,{"F1_FORNECE"     ,SA2->A2_COD       ,NIL})   // FORNECEDOR  
   AADD(aCab,{"F1_LOJA"        ,SA2->A2_LOJA      ,NIL})   // LOJA DO FORNECEDOR 

   //AADD(aCab,{"F1_ESPECIE"     ,'NFE'             ,NIL})   // NOTA FISCAL DE ENTRADA
   AADD(aCab,{"F1_ESPECIE"     ,EasyGParam("MV_ESPEIC",,'NFE'), NIL})   // NOTA FISCAL DE ENTRADA

   AADD(aCab,{"F1_DTDIGIT"     ,dDataBase         ,NIL})
   AADD(aCab,{"F1_EST"         ,"EX"              ,NIL}) 
   AADD(aCab,{"F1_TIPODOC"     ,IF(cTipoNF="2","13","10"),NIL})
   AADD(aCab,{"F1_TIPO_NF"     ,cTipoNF           ,NIL})
   AADD(aCab,{"F1_HAWB"        ,SW6->W6_HAWB      ,NIL})
   AADD(aCab,{"F1_PESOL"       ,aGrv_SF1[i,2]     ,NIL})
   AADD(aCab,{"F1_PLIQUI"      ,aGrv_SF1[i,2]     ,NIL})  // GFP - 21/09/2015
   AADD(aCab,{"F1_IMPORT"      ," "               ,NIL})
   AADD(aCab,{"F1_FOB_R"       ,aGrv_SF1[i,3]     ,NIL})
   AADD(aCab,{"F1_FRETE"       ,aGrv_SF1[i,4]     ,NIL})
   AADD(aCab,{"F1_SEGURO"      ,aGrv_SF1[i,5]     ,NIL})
   AADD(aCab,{"F1_CIF"         ,aGrv_SF1[i,6]     ,NIL})
   AADD(aCab,{"F1_II"          ,aGrv_SF1[i,7]     ,NIL})
   AADD(aCab,{"F1_CTR_NFC"     ,cControle         ,Nil})

   IF cTipoNF <> '6' .OR. (lMV_NF_MAE .AND. cMV_NFFILHA <> '0')
      AADD(aCab,{"F1_IPI"         ,aGrv_SF1[i,8]     ,NIL})
      AADD(aCab,{"F1_ICMS"        ,aGrv_SF1[i,9]     ,NIL})
      AADD(aCab,{"F1_DESPESA"     ,aGrv_SF1[i,10]    ,NIL})
   ENDIF

   If EasyGParam("MV_NF_AUTO",, "N") == "S"
      AAdd(aCab,{"F1_FORMUL", "S", Nil})
   EndIf

   If EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"GRVFE")
   ENDIF

                                                 
   IF lMV_EASY_SIM 

      MSExecAuto({|x,y| MATA140(x,y)},aCab,aItens)
      IF lMSErroAuto           
         RETURN .F.
      ENDIF
	  //AAF - 24/07/15
      IF EasyGParam("MV_TPNRNFS",,"1") == "2"
         ConfirmSX8()
      ENDIF	  
      lPosSF1 := .T.
      IF (nPos:=ASCAN(aCab,{ |A| A[1]="F1_EST" } )) # 0
         //WFS 18/11/2008 - Tratamento para a NFe ---
         //IF SF1->F1_DOC # INT_FE->NFENOTA
         IF SF1->F1_DOC # cNumero
            //lPosSF1 := SF1->(DBSEEK(cFilSF1+INT_FE->NFENOTA+INT_FE->NFESERIE+SA2->A2_COD+SA2->A2_LOJA))
            lPosSF1 := SF1->(DBSEEK(cFilSF1+cNumero + cSerie + SA2->A2_COD + SA2->A2_LOJA))
         ENDIF
         IF lPosSF1
            SF1->(RecLock("SF1",.F.))
            FOR GRV := nPos TO LEN(aCab) 
                IF ( nPos:=SF1->( FIELDPOS(aCab[GRV,1]) ) ) # 0
                   SF1->( FIELDPUT(nPos,aCab[GRV,2]) )
                ENDIF
            NEXT
            SF1->(MsUnlock())
         ENDIF
      ENDIF

   ELSE

      SF1->(RecLock("SF1",.T.))
      SF1->F1_FILIAL := cFilSF1
      FOR GRV := 1 TO LEN(aCab) 
          IF ( nPos:=SF1->( FIELDPOS(aCab[GRV,1]) ) ) # 0
             SF1->( FIELDPUT(nPos,aCab[GRV,2]) )
          ENDIF
      NEXT
      SF1->(MsUnlock())

   ENDIF                  

   AADD(aNotas,{SF1->F1_HAWB,SF1->F1_DOC+SF1->F1_SERIE})

NEXT

RETURN .T.

*-----------------------------------------------------------------------------
FUNCTION IN100SI_PO(nCont,nSeq_Sli)
*-----------------------------------------------------------------------------
LOCAL cPrefixo:=IF(cFuncao=CAD_IS,"NIS","NIP"), nSequencia, cAlias, lTrocaFluxo:=.F.
local oldcFuncao:=""
Local aOrdSW2:= {}

IF(EasyEntryPoint("IN100CLI"),EXECBLOCK("IN100CLI",.F.,.F.,"INCLUI_ITEM"),)

If cPrefixo == "NIP" .and. Int_IP->NIPTIPO = ALTERACAO
   SW3->(DBSEEK(cFilSW3+AVKEY(Int_IP->NIPPO_NUM,"W3_PO_NUM")+Int_IP->NIPPOSICAO))
   If SW3->W3_FLUXO == "7" .and. Int_IP->NIPFLUXO == "1"
      In100DelItem(.T.)
      lTrocaFluxo := .T.
   EndIf
EndIf

If Type("bUpDate") <> "B"
   bUpDate:= Nil
EndIf

FOR nSequencia:=0 TO 1
    If cPrefixo == "NIP" .and. Int_IP->NIPTIPO = ALTERACAO
       SW1->(DBSEEK(cFilSW1+SW3->W3_CC+SW3->W3_SI_NUM+SW3->W3_COD_I))
       Do While !SW1->(EOF()) .and. SW1->W1_FILIAL==cFilSW1 .and. SW1->W1_CC==SW3->W3_CC .and.;
       SW1->W1_SI_NUM==SW3->W3_SI_NUM .and. SW1->W1_COD_I==SW3->W3_COD_I
          IF SW3->W3_REG = SW1->W1_REG .and. nSequencia = SW1->W1_SEQ
             Exit
          EndIF
          SW1->(dbSkip())
       EndDo
       If !SW1->(Eof()) .AND. SW1->W1_FILIAL == cFilSW1 .AND. SW1->W1_CC == SW3->W3_CC .AND. SW1->W1_SI_NUM == SW3->W3_SI_NUM .AND.;
       SW1->W1_COD_I==SW3->W3_COD_I .AND. SW3->W3_REG = SW1->W1_REG .and. nSequencia = SW1->W1_SEQ
          SW1->(Reclock("SW1",.F.))
       Else
          IN100RecLock('SW1')          
       EndIf
    Else
       IN100RecLock('SW1')
    EndIf
    cCC              := EVAL(FIELDBLOCK(cPrefixo+"CC"))
    cSI              := EVAL(FIELDBLOCK(cPrefixo+"SI_NUM"))
    SW1->W1_FILIAL   := cFilSW1
    SW1->W1_CC       := cCC
    SW1->W1_SI_NUM   := cSI
    If SW1->(FieldPos("W1_POSIT")) # 0  // GFP - 06/06/2013 - Tratamento do campo W1_POSIT
       SW1->W1_POSIT := EVAL(FIELDBLOCK(cPrefixo+"POSICAO"))
    EndIf
    SW1->W1_COD_I    := LEFT(EVAL(FIELDBLOCK(cPrefixo+"COD_I")),NLENITEM)
    SB1->(DBSEEK(cFilSB1+SW1->W1_COD_I))
    IF cFuncao=CAD_IS
       SW1->W1_FLUXO := IF(cFuncao=CAD_IS,"1",IF(SB1->B1_ANUENTE$cSim,"1","7"))
    ELSE
       SW1->W1_FLUXO := EVAL(FIELDBLOCK(cPrefixo+"FLUXO"))
    ENDIF
    SW1->W1_QTDE     := VAL(EVAL(FIELDBLOCK(cPrefixo+"QTDE")))
    SW1->W1_SEQ      := nSequencia
    SW1->W1_FABR     := EVAL(FIELDBLOCK(cPrefixo+"FABR"))
    
    IF EICLOJA()
       SA2->(DbSetOrder(1))
       If SA2->(DbSeek(xFilial("SA2")+SW1->W1_FABR))
          SW1->W1_FABLOJ := SA2->A2_LOJA
       Endif  
    ENDIF
    
    SW1->W1_REG      := VAL(EVAL(FIELDBLOCK(cPrefixo+"REG")))
    SW1->W1_CLASS    := EVAL(FIELDBLOCK(cPrefixo+"CLASS"))
    SW1->W1_POSICAO  := EVAL(FIELDBLOCK(cPrefixo+"POSICAO"))

    IF cFuncao=CAD_IS
       SW1->W1_SALDO_Q := SW1->W1_QTDE
       SW1->W1_DTENTR_ := IN100CTD(NISDTENTR_)
       SW1->W1_FORN    := NISFORN

       IF EICLOJA()
          SA2->(DbSetOrder(1))
          If SA2->(DbSeek(xFilial("SA2")+AvKey(SW1->W1_FORN,"W1_FORN")))
             SW1->W1_FORLOJ := SA2->A2_LOJA
          Endif  
       Endif
    
    ELSE
       SW1->W1_SALDO_Q  := 0
       SW1->W1_DTENTR_  := IN100CTD(NIPDT_ENTR)
       SW1->W1_DT_EMB   := IN100CTD(NIPDT_EMB)
       SW1->W1_FORN     := Int_PO->NPOFORN
       IF nSequencia= 1
          SW1->W1_PO_NUM:= Int_PO->NPOPO_NUM
       ENDIF
    
       IF EICLOJA()
          SA2->(DbSetOrder(1))
          If SA2->(DbSeek(xFilial("SA2")+AvKey(Int_PO->NPOFORN,"W1_FORN")))
             SW1->W1_FORLOJ := SA2->A2_LOJA
          Endif  
       Endif
    
    ENDIF

    If EasyEntryPoint("IN100CLI")
       ExecBlock("IN100CLI",.F.,.F.,"GRVIS")
    ENDIF          
    
    //IAC 23/12/2010
    If cFuncao = CAD_IS
       IF ValType(bUpDate) == "B"
          oldcfuncao:=cfuncao
          cfuncao:="IS"         
          If FindFunction("AvIntExtra")
            EasyExRdm("AvIntExtra")
          EndIf 
          cfuncao:=oldcfuncao
       ENDIF
    ENDIF
    
    If cPrefixo == "NIP" .and. Int_IP->NIPTIPO = ALTERACAO
       SW1->(msUnlock())
    EndIf

    If cFuncao=CAD_IS
       EXIT
    ENDIF

NEXT

//IF ! SW0->(DBSEEK(cFilSW0+SW1->W1_CC+SW1->W1_SI_NUM))                                                 //MJB-SAP-0401
IF ! SW0->(DBSEEK(cFilSW0+Avkey(cCC,"W1_CC")+AvKey(cSI,"W1_SI_NUM")))  //AJP 06/10/06
   IN100RecLock('SW0')
   SW0->W0_FILIAL := cFilSW0
/* AJP 06/10/06
   SW0->W0__CC    := SW1->W1_CC
   SW0->W0__NUM   := SW1->W1_SI_NUM
*/
   SW0->W0__CC    := cCC
   SW0->W0__NUM   := cSI

   IF cFuncao=CAD_IS
      SW0->W0__DT   := IN100CTD(Int_SI->NSI_DT)
      SW0->W0__POLE := Int_SI->NSI_POLE
      SW0->W0_COMPRA:= Int_SI->NSICOMPRA
      SW0->W0_SOLIC := Int_SI->NSISOLIC
      SW0->W0_REFER1:= Int_SI->NSIREFER1
   ELSE
      SW0->W0__DT   :=  IN100CTD(Int_PO->NPOPO_DT)
      SW0->W0__POLE :=  Int_PO->NPO_POLE
      SW0->W0_COMPRA:=  Int_PO->NPOCOMPRA
   ENDIF

   If EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"GRVSI")
   EndIf

/* AJP 06/10/06 - Retirado pois deve ser efetuado apenas apos o Commit
   IF cFuncao=CAD_IS
      RETURN
   EndIf
*/
ENDIF
SW1->(msUnlock())
SW0->(DBCOMMIT())
SW1->(DBCOMMIT())

IF cFuncao=CAD_IS
   RETURN
ENDIF

aOrdSW2:= SaveOrd({"SA2"})

If Int_IP->NIPTIPO = ALTERACAO
   SW3->(Reclock("SW3",.F.))
Else
   IN100RecLock('SW3')
EndIf
SW3->W3_FILIAL  := cFilSW3
SW3->W3_COD_I   := SW1->W1_COD_I
SW3->W3_FLUXO   := NIPFLUXO
If Int_IP->NIPTIPO = ALTERACAO .and. lTrocaFluxo
   SW3->W3_SALDO_Q := SW1->W1_QTDE
Else
   SW3->W3_SALDO_Q := IF(NIPFLUXO="1",SW1->W1_QTDE-(SW3->W3_QTDE-SW3->W3_SALDO_Q),0)
EndIf
SW3->W3_QTDE    := SW1->W1_QTDE
SW3->W3_PRECO   := VAL(NIPPRECO)
SW3->W3_SI_NUM  := SW1->W1_SI_NUM
SW3->W3_PO_NUM  := SW1->W1_PO_NUM
If Int_IP->NIPTIPO <> ALTERACAO
   SW3->W3_DT_EMB  := SW1->W1_DT_EMB
   SW3->W3_DT_ENTR := SW1->W1_DTENTR_
EndIf
SW3->W3_CC      := SW1->W1_CC
SW3->W3_FABR    := SW1->W1_FABR
SW3->W3_FORN    := SW1->W1_FORN
SW3->W3_FABR_01 := If(!Empty(NIPFABR_01),NIPFABR_01,SW3->W3_FABR_01)
SW3->W3_FABR_02 := If(!Empty(NIPFABR_02),NIPFABR_02,SW3->W3_FABR_02)
SW3->W3_FABR_03 := If(!Empty(NIPFABR_03),NIPFABR_03,SW3->W3_FABR_03)
SW3->W3_FABR_04 := If(!Empty(NIPFABR_04),NIPFABR_04,SW3->W3_FABR_04)
SW3->W3_FABR_05 := If(!Empty(NIPFABR_05),NIPFABR_05,SW3->W3_FABR_05)
//SW3->W3_FORN    := SW1->W1_FORN
//FDR - 28/02/12
IF EICLOJA()
   SA2->(DbSetOrder(1))
   If SA2->(DbSeek(xFilial("SA2")+SW1->W1_FORN))
      SW3->W3_FORLOJ := SA2->A2_LOJA
   Endif   
      
   If SA2->(DbSeek(xFilial("SA2")+SW1->W1_FABR))  
      SW3->W3_FABLOJ := SA2->A2_LOJA
      If !Empty(SW3->W3_FAB1LOJ)
         SW3->W3_FAB1LOJ:= SA2->A2_LOJA
      Endif
      If !Empty(SW3->W3_FAB2LOJ)
         SW3->W3_FAB2LOJ:= SA2->A2_LOJA
      Endif
      If !Empty(SW3->W3_FAB3LOJ)
         SW3->W3_FAB3LOJ:= SA2->A2_LOJA
      Endif
      If !Empty(SW3->W3_FAB4LOJ)
         SW3->W3_FAB4LOJ:= SA2->A2_LOJA
      Endif
      If !Empty(SW3->W3_FAB5LOJ)
         SW3->W3_FAB5LOJ:= SA2->A2_LOJA
      Endif
   Endif

ENDIF
SW3->W3_SEQ     := 0
SW3->W3_REG     := SW1->W1_REG
SW3->W3_POSICAO := NIPPOSICAO
SW3->W3_TEC     := If(lNIPTEC,Int_IP->NIPTEC,SB1->B1_POSIPI)
SW3->W3_EX_NCM  := If(lNIPTEC,Int_IP->NIPEX_NCM,SB1->B1_EX_NCM)
SW3->W3_EX_NBM  := If(lNIPTEC,Int_IP->NIPEX_NBM,SB1->B1_EX_NBM)
SW3->W3_NR_CONT := Val(Left(NIPPOSICAO,4)) //ER - 01/02/2007

//TRP - 13/07/2012
SB1->(DBSETORDER(1))
IF SB1->(DBSEEK(cFilSB1+AVKEY(SW1->W1_COD_I,"B1_COD")))
   IF SW3->(FieldPos("W3_PESOL")) > 0 
      SW3->W3_PESOL := SB1->B1_PESO
   ENDIF
   IF SW3->(FieldPos("W3_PESO_BR")) > 0
      SW3->W3_PESO_BR := SB1->B1_PESBRU
   ENDIF
ENDIF

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"GRVIP")
EndIf

If Int_IP->NIPTIPO = ALTERACAO
   SW3->(msUnlock())
EndIf

if type("bUpDate")=="B"
   oldcfuncao:=cfuncao
   cfuncao:="IP"
   If FindFunction("AvIntExtra")
      EasyExRdm("AvIntExtra")
   EndIf
   cfuncao:=oldcfuncao
endif

IF NIPFLUXO="7"
   Do While !SW3->(EOF()) .and. SW3->W3_FILIAL==cFilSW3 .and. SW3->W3_PO_NUM==Int_IP->NIPPO_NUM .and.;
   SW3->W3_POSICAO==Int_IP->NIPPOSICAO
      If SW3->W3_SEQ=1
         Exit
      EndIf
      SW3->(dbSkip())
   EndDo
   If Int_IP->NIPTIPO = ALTERACAO .and. SW3->W3_FILIAL==cFilSW3 .and. SW3->W3_PO_NUM==Int_IP->NIPPO_NUM .and.;
      SW3->W3_POSICAO==Int_IP->NIPPOSICAO .and. SW3->W3_SEQ=1
      SW3->(Reclock("SW3",.F.))
   Else
      IN100RecLock('SW3')
   EndIf
   SW3->W3_FILIAL  := cFilSW3
   SW3->W3_COD_I   := SW1->W1_COD_I
   SW3->W3_FLUXO   := "7"
   SW3->W3_QTDE    := SW1->W1_QTDE
   SW3->W3_SALDO_Q := 0
   SW3->W3_PRECO   := VAL(NIPPRECO)
   SW3->W3_SI_NUM  := SW1->W1_SI_NUM
   SW3->W3_PO_NUM  := SW1->W1_PO_NUM
   If Int_IP->NIPTIPO <> ALTERACAO
      SW3->W3_DT_EMB  := SW1->W1_DT_EMB
      SW3->W3_DT_ENTR := SW1->W1_DTENTR_
   EndIf
   SW3->W3_CC      := SW1->W1_CC
   
   SW3->W3_FORN    := SW1->W1_FORN
   SA2->(DbSetOrder(1))
   If EICLOJA()
      If SA2->(DbSeek(xFilial("SA2")+SW1->W1_FORN))
         SW3->W3_FORLOJ := SA2->A2_LOJA
      Endif 
   Endif
   SW3->W3_FABR    := SW1->W1_FABR
   SW3->W3_FABR_01 := NIPFABR_01
   SW3->W3_FABR_02 := NIPFABR_02
   SW3->W3_FABR_03 := NIPFABR_03
   SW3->W3_FABR_04 := NIPFABR_04
   SW3->W3_FABR_05 := NIPFABR_05
   
   If EICLOJA()
      If SA2->(DbSeek(xFilial("SA2")+SW1->W1_FABR))  
         SW3->W3_FABLOJ := SA2->A2_LOJA
         If !Empty(SW3->W3_FAB1LOJ)
            SW3->W3_FAB1LOJ:= SA2->A2_LOJA
         Endif
         If !Empty(SW3->W3_FAB2LOJ)
            SW3->W3_FAB2LOJ:= SA2->A2_LOJA
         Endif
         If !Empty(SW3->W3_FAB3LOJ)
            SW3->W3_FAB3LOJ:= SA2->A2_LOJA
         Endif
         If !Empty(SW3->W3_FAB4LOJ)
            SW3->W3_FAB4LOJ:= SA2->A2_LOJA
         Endif
         If !Empty(SW3->W3_FAB5LOJ)
            SW3->W3_FAB5LOJ:= SA2->A2_LOJA
         Endif
     Endif
   Endif
   
   //SW3->W3_FORN    := SW1->W1_FORN
   SW3->W3_SEQ     := 1
   SW3->W3_REG     := SW1->W1_REG
   SW3->W3_POSICAO := NIPPOSICAO
   SW3->W3_PGI_NUM := nSeq_SLi

   SW3->W3_TEC     := If(lNIPTEC,Int_IP->NIPTEC,SB1->B1_POSIPI)
   SW3->W3_EX_NCM  := If(lNIPTEC,Int_IP->NIPEX_NCM,SB1->B1_EX_NCM)
   SW3->W3_EX_NBM  := If(lNIPTEC,Int_IP->NIPEX_NBM,SB1->B1_EX_NBM)

   //TRP - 13/07/2012
   SB1->(DBSETORDER(1))
   IF SB1->(DBSEEK(cFilSB1+AVKEY(SW1->W1_COD_I,"B1_COD")))
      IF SW3->(FieldPos("W3_PESOL")) > 0 
         SW3->W3_PESOL := SB1->B1_PESO
      ENDIF
      IF SW3->(FieldPos("W3_PESO_BR")) > 0
         SW3->W3_PESO_BR := SB1->B1_PESBRU
      ENDIF
   ENDIF
   
   If EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"GRVIP")
   EndIf

   If Int_IP->NIPTIPO = ALTERACAO
      SW3->(msUnlock())
   EndIf

   If Int_IP->NIPTIPO = ALTERACAO .and. SW5->(DBSEEK(cFilSW5+SW3->W3_PGI_NUM+SW3->W3_PO_NUM+SW3->W3_POSICAO))
      SW5->(Reclock("SW5",.F.))
   Else
      IN100RecLock('SW5')
   EndIf
   SW5->W5_FILIAL  := cFilSW5                                                                         //MJB-SAP-0401
   SW5->W5_COD_I   := SW1->W1_COD_I
   SW5->W5_FABR    := SW1->W1_FABR
   SW5->W5_FABR_01 := NIPFABR_01
   SW5->W5_FABR_02 := NIPFABR_02
   SW5->W5_FABR_03 := NIPFABR_03
   SW5->W5_FABR_04 := NIPFABR_04
   SW5->W5_FABR_05 := NIPFABR_05
   SW5->W5_FORN    := SW1->W1_FORN
   //FDR - 28/02/12
   IF EICLOJA()
      SW5->W5_FABLOJ := SW3->W3_FABLOJ
      SW5->W5_FAB1LOJ:= SW3->W3_FAB1LOJ
      SW5->W5_FAB2LOJ:= SW3->W3_FAB2LOJ
      SW5->W5_FAB3LOJ:= SW3->W3_FAB3LOJ
      SW5->W5_FAB4LOJ:= SW3->W3_FAB4LOJ
      SW5->W5_FAB5LOJ:= SW3->W3_FAB5LOJ
      SW5->W5_FORLOJ := SW3->W3_FORLOJ   
   ENDIF
   
   SW5->W5_FLUXO   := "7"
   SW5->W5_SALDO_Q := SW1->W1_QTDE-(SW5->W5_QTDE-SW5->W5_SALDO_Q)
   SW5->W5_QTDE    := SW1->W1_QTDE
   SW5->W5_PRECO   := VAL(NIPPRECO)
   SW5->W5_SI_NUM  := SW1->W1_SI_NUM
   SW5->W5_PO_NUM  := SW1->W1_PO_NUM
   SW5->W5_PGI_NUM := nSeq_SLi
   If Int_IP->NIPTIPO <> ALTERACAO
      SW5->W5_DT_EMB  := SW3->W3_DT_EMB  // SVG - 23/10/2010 -
      SW5->W5_DT_ENTR := SW3->W3_DT_ENTR // SVG - 23/10/2010 -
   EndIf
   SW5->W5_SEQ     := 0
   SW5->W5_CC      := SW1->W1_CC
   SW5->W5_REG     := SW1->W1_REG
   SW5->W5_POSICAO := NIPPOSICAO

   //TRP - 13/07/2012
   SB1->(DBSETORDER(1))
   IF SB1->(DBSEEK(cFilSB1+AVKEY(SW3->W3_COD_I,"B1_COD")))
      IF SW5->(FieldPos("W5_PESO")) > 0 
         SW5->W5_PESO := SB1->B1_PESO
      ENDIF
      IF SW5->(FieldPos("W5_PESO_BR")) > 0
         SW5->W5_PESO_BR := SB1->B1_PESBRU
      ENDIF
   ENDIF
   
   If EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"GRVSW5")
   EndIf

   SW5->(msUnlock())

   IF ! SW4->(DBSEEK(cFilSW4+nSeq_SLi))
      IN100RecLock('SW4')
      SW4->W4_FILIAL        := cFilSW4                                                                //MJB-SAP-0401
      SW4->W4_MOEDA         := SW2->W2_MOEDA
      SW4->W4_GI_NUM        := nSeq_SLi
      SW4->W4_PGI_NUM       := nSeq_SLi
      SW4->W4_PGI_DT        := dDataBase
      SW4->W4_IMPORT        := SW2->W2_IMPORT
      SW4->W4_CONSIG        := SW2->W2_CONSIG
      SW4->W4_FLUXO         := "7"
      SW4->W4_DTEDCEX       := SW2->W2_PO_DT
      SW4->W4_DTSDCEX       := SW2->W2_PO_DT
      SW4->W4_EMITIDA       := "S"
      SW4->W4_INLAND        := VAL(Int_PO->NPOINLAND)
      SW4->W4_FRETEINT      := VAL(Int_PO->NPOFRETEIN)
      SW4->W4_PACKING       := VAL(Int_PO->NPOPACKING)
      SW4->W4_DESCONTO      := VAL(Int_PO->NPODESCONT)
      SW4->W4_SISCOMEX      := .T.
      SW4->W4_FOB_TOT       := VAL(STR(SW1->W1_QTDE * VAL(NIPPRECO),15,2))
   ELSE
      cAlias:=ALIAS()
      Reclock("SW4",.F.)
      DBSELECTAREA(cAlias)
      SW4->W4_FOB_TOT       += VAL(STR(SW1->W1_QTDE * VAL(NIPPRECO),15,2))
      SW4->(MSUNLOCK())
   ENDIF
ENDIF

IF SW2->(DBSEEK(cFilSW2+AVKEY(SW3->W3_PO_NUM,"W3_PO_NUM")))                            //MJB-SAP-0401
   cUltPosPO:=INVERPOS()
   IF lTravaPO//:=.T.
      lTravaPO:=.F.
   ENDIF
   Reclock("SW2",.F.)
   SW2->W2_POSICAO:=cUltPosPO
   COMMIT
   RETURN
ENDIF

cUltPosPO:=INVERPOS()

lTravaPO:=.F.
cAlias:=ALIAS()
Reclock("SW2",.T.)
SW2->W2_FILIAL   := cFilSW2                                                                           //MJB-SAP-0401
SW2->W2_PO_NUM   := SW3->W3_PO_NUM
SW2->W2_PO_DT    := IN100CTD(Int_PO->NPOPO_DT)
SW2->W2_COMPRA   := Int_PO->NPOCOMPRA
SW2->W2_TIPO_EM  := Int_PO->NPOTIPO_EM
SW2->W2_ORIGEM   := Int_PO->NPOORIGEM
SW2->W2_DEST     := Int_PO->NPODEST
SW2->W2_COND_PA  := Int_PO->NPOCOND_PA
SW2->W2_DIAS_PA  := VAL(Int_PO->NPODIAS_PA)
SW2->W2_AGENTE   := Int_PO->NPOAGENTE
SW2->W2_IMPORT   := Int_PO->NPOIMPORT
SW2->W2_MOEDA    := Int_PO->NPOMOEDA
SW2->W2_INLAND   := VAL(Int_PO->NPOINLAND)
SW2->W2_PACKING  := VAL(Int_PO->NPOPACKING)
SW2->W2_DESCONT  := VAL(Int_PO->NPODESCONT)
SW2->W2_FRETEIN  := VAL(Int_PO->NPOFRETEIN)
SW2->W2_FREPPCC  := Int_PO->NPOFREPPCC
SW2->W2_CONSIG   := Int_PO->NPOCONSIG
SW2->W2_FORN     := SW3->W3_FORN
//FDR - 28/02/12
IF EICLOJA()
   SW2->W2_FORLOJ:= SW3->W3_FORLOJ
ENDIF
SW2->W2_NR_PRO   := Int_PO->NPONR_PRO
SW2->W2_DT_PRO   := IN100CTD(Int_PO->NPODT_PRO)
SW2->W2_PARID_U  := VAL(Int_PO->NPOPARID_US)
SW2->W2_DT_PAR   := IN100CTD(Int_PO->NPODT_PAR)
SW2->W2_PESO_B   := VAL(Int_PO->NPOPESO_B)
SW2->W2_CLIENTE  := Int_PO->NPOCLIENTE
SW2->W2_FORWARD  := Int_PO->NPOFORWARD
SW2->W2_INCOTERM := Int_PO->NPOINCOTER
SW2->W2_DT_INTEG := IN100CTD(Int_PO->NPOINT_DT)
SW2->W2_FOB_TOT  := Int_PO->NPOFOB_TOT
SW2->W2_INTEGRA  := "S"
SW2->W2_POSICAO  := cUltPosPO // SAM - 14/05/2001 . Gravacao da Ultima Posicao

//Gravação dos campos W2_IMPENC, W2_IMPCO E W2_E_LC - OSSME-5921 - RNLP
SW2->W2_IMPENC := "2"   
SW2->W2_IMPCO := "2" 
SW2->W2_E_LC := "2" 

RestOrd(aOrdSW2,.T.)

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"GRVPO")
ENDIF

IF ! EMPTY(Int_PO->NPOOBS)
   IF Int_PO->NPOTIPO=INCLUSAO
      nNumMsmm+=1
   ENDIF
   MSMM(IF(Int_PO->NPOTIPO=ALTERACAO,SW2->W2_OBS,IF(lMsmm,STRZERO(nNumMsmm,6),)),nSW2_OBS,,Int_PO->NPOOBS,1,,,"SW2","W2_OBS")
ENDIF

DBSELECTAREA(cAlias)
// MJB-SAP-1100 COMMIT
RETURN .T.
*-----------------------------------------------------------------------------
FUNCTION IN100DelPO()
*-----------------------------------------------------------------------------
LOCAL nSeq_SLi,cAlias

SW2->(DBSEEK(cFilSW2+AVKEY(Int_PO->NPOPO_NUM,"W2_PO_NUM")))                                           //MJB-SAP-0401
cAlias:=ALIAS()
Reclock("SW2",.F.)
DBSELECTAREA(cAlias)
SW5->(DBSETORDER(3)) // JBS-05/01/05, RJB 06/08/2004
SW5->(DBSEEK(cFilSW5+SW2->W2_PO_NUM))                                                                 //MJB-SAP-0401

cAlias:=ALIAS()
WHILE ! SW5->(EOF()) .AND. SW5->W5_PO_NUM == SW2->W2_PO_NUM .AND. cFilSW5==SW5->W5_FILIAL             //MJB-SAP-0401
   nSeq_SLi := SW5->W5_PGI_NUM
   Reclock("SW5",.F.)
   SW5->(DBDELETE())
   SW5->(DBSKIP())
ENDDO
DBSELECTAREA(cAlias)

cAlias:=ALIAS()
IF nSeq_SLi # NIL .AND. SW4->(DBSEEK(cFilSW4+nSeq_SLi))                                               //MJB-SAP-0401
   Reclock("SW4",.F.)
   SW4->(DBDELETE())
ENDIF
DBSELECTAREA(cAlias)

SW3->(DBSEEK(cFilSW3+AVKEY(SW2->W2_PO_NUM,"W2_PO_NUM")))                                                                 //MJB-SAP-0401

If(EasyEntryPoint("IN100CLI"),ExecBlock("IN100CLI",.F.,.F.,"ANTES_DEL_PO"),)

cAlias:=ALIAS()
WHILE ! SW3->(EOF()) .AND. SW3->W3_PO_NUM == SW2->W2_PO_NUM .AND. SW3->W3_FILIAL==cFilSW3             //MJB-SAP-0401

  SW0->(DBSEEK(cFilSW0+SW3->W3_CC+SW3->W3_SI_NUM))                                                    //MJB-SAP-0401
  DBSELECTAREA(cAlias)

  SW1->(DBSEEK(cFilSW1+SW0->W0__CC+SW0->W0__NUM))                                                     //MJB-SAP-0401
  SW1->(DBEVAL({||Reclock("SW1",.F.),SW1->(DBDELETE()) },,;
               {||SW1->W1_CC==SW0->W0__CC .AND. SW1->W1_SI_NUM==SW0->W0__NUM .AND. SW1->W1_FILIAL==cFilSW1})) //MJB-SAP-0401
  DBSELECTAREA(cAlias)
  SW1->(DBCOMMIT())

  IF ! SW0->(EOF())
     Reclock("SW0",.F.)
     DBSELECTAREA(cAlias)
     SW0->(DBDELETE())
     SW0->(DBCOMMIT())
  ENDIF

  IF Int_PO->NPOTIPO = EXCLUSAO
     EVAL(bMessage,_LIT_R_CC+STR0392) //"/S.I. EXCLUIDA"
  ENDIF

  Reclock("SW3",.F.)
  SW3->(DBDELETE())
  SW3->(DBCOMMIT())
  SW3->(DBSKIP())
  DBSELECTAREA(cAlias)

ENDDO

IF(EasyEntryPoint("IN100CLI"),EXECBLOCK("IN100CLI",.F.,.F.,"DEL_PO"),)
IF Int_PO->NPOTIPO = EXCLUSAO
   MSMM(SW2->W2_OBS,,,,2)
   Reclock("SW2",.F.)
   SW2->(DBDELETE())
   SW2->(DBCOMMIT())
   EVAL(bMessage,_LIT_R_CC+STR0393) //"/S.I. E P.O. EXCLUIDOS"
ENDIF
RETURN .T.
*-----------------------------------------------------------------------------
FUNCTION IN100DelItem(lAlt)
*-----------------------------------------------------------------------------
LOCAL cAlias:=ALIAS(), cOcor, nRecW3Aux, lAchouW5:=.F.
lAlt:=If(lAlt=NIL,lAlt:=.F.,lAlt)

If(EasyEntryPoint("IN100CLI"),ExecBlock("IN100CLI",.F.,.F.,"DELETAR_ITEM"),)
SW3->(DBSETORDER(8))

IF SW3->(DBSEEK(cFilSW3+AVKEY(Int_IP->NIPPO_NUM,"W3_PO_NUM")+Int_IP->NIPPOSICAO))                         //MJB-SAP-0401

   nRecW3Aux:=SW3->(RECNO())

   DO WHILE ! SW3->(EOF()) .AND. SW3->W3_FILIAL = cFilSW3 .AND. ;                                        //MJB-SAP-0401
          (Int_IP->NIPPO_NUM+Int_IP->NIPPOSICAO) == (SW3->W3_PO_NUM+SW3->W3_POSICAO) 

         IF ! EMPTY(ALLTRIM(SW3->W3_PGI_NUM)) 
         lAchouW5:=.t.
         IF ASCAN(aTabW4,{|chave| chave[1] == SW3->W3_PGI_NUM}) = 0
            AADD(aTabW4,{SW3->W3_PGI_NUM,0})
         ENDIF
         EXIT
      ENDIF
      SW3->(DBSKIP())
   ENDDO

   IF lAchouW5
      SW5->(DBSETORDER(8))
      SW5->(DBSEEK(cFilSW5+SW3->W3_PGI_NUM+SW3->W3_PO_NUM+SW3->W3_POSICAO))                           //MJB-SAP-0401

      DO WHILE ! SW5->(EOF()) .AND. SW5->W5_FILIAL = cFilSW5 .AND. ;                                     //MJB-SAP-0401
                 (SW3->W3_PGI_NUM+SW3->W3_PO_NUM+SW3->W3_POSICAO) = ;
                 (SW5->W5_PGI_NUM+SW5->W5_PO_NUM+SW5->W5_POSICAO)

            IF SW3->W3_REG = SW5->W5_REG 
            Reclock("SW5",.F.)
            SW5->(DBDELETE())
         ENDIF
         SW5->(DBSKIP())
      ENDDO
   ENDIF
   SW3->(DBGOTO(nRecW3Aux))

   If !lAlt
      SW1->(DBSETORDER(1))
      SW1->(DBSEEK(cFilSW1+SW3->W3_CC+SW3->W3_SI_NUM+SW3->W3_COD_I))                                     //MJB-SAP-0401

      WHILE ! SW1->(EOF()) .AND. SW1->W1_FILIAL = cFilSW1 .AND.;                                         //MJB-SAP-0401
              (SW3->W3_CC+SW3->W3_SI_NUM+SW3->W3_COD_I) = ;
              (SW1->W1_CC+SW1->W1_SI_NUM+SW1->W1_COD_I)
            
         IF SW3->W3_REG = SW1->W1_REG 
            Reclock("SW1",.F.)
            SW1->(DBDELETE())
         ENDIF
         SW1->(DBSKIP())
      ENDDO

      WHILE ! SW3->(EOF()) .AND. SW3->W3_FILIAL = cFilSW3 .AND. ;                                        //MJB-SAP-0401
             (Int_IP->NIPPO_NUM+Int_IP->NIPPOSICAO) = (SW3->W3_PO_NUM+SW3->W3_POSICAO) 
            
            Reclock("SW3",.F.)
            If(EasyEntryPoint("IN100CLI"),ExecBlock("IN100CLI",.F.,.F.,"DEL_ITEM_PO"),)
            SW3->(DBDELETE())
         
         SW3->(DBSKIP())
      ENDDO
   Else
      WHILE ! SW3->(EOF()) .AND. SW3->W3_FILIAL = cFilSW3 .AND. ;                                        //MJB-SAP-0401
             (Int_IP->NIPPO_NUM+Int_IP->NIPPOSICAO) = (SW3->W3_PO_NUM+SW3->W3_POSICAO) 
         
         If SW3->W3_SEQ <> 0   
            Reclock("SW3",.F.)
            If(EasyEntryPoint("IN100CLI"),ExecBlock("IN100CLI",.F.,.F.,"DEL_ITEM_PO"),)
            SW3->(DBDELETE())
         EndIf
         
         SW3->(DBSKIP())
      ENDDO
      SW3->(DBGOTO(nRecW3Aux))
   EndIf
ENDIF
DBSELECTAREA(cAlias)
RETURN 
*********************************************** INICIO S.I. ********************
*-----------------------------------------------------------------------------
FUNCTION IN100SI()
*-----------------------------------------------------------------------------
LOCAL _LIT_R_CC := IF(EMPTY(ALLTRIM(EasyGParam("MV_LITRCC"))),(AVSX3("W0__CC")[5]),ALLTRIM(EasyGParam("MV_LITRCC")))

TB_Col_D:={}

AADD(TB_Col_D,{ {|| IN100Status()}                ,"" ,STR0036         }) //"Status"
AADD(TB_Col_D,{ {|| IN100TIPO() }                 ,"" ,STR0037           }) //"Tipo"
AADD(TB_Col_D,{ {|| TRANSFORM(NISCOD_I,_PictItem)}     ,"" ,STR0120           }) //"Item"
AADD(TB_Col_D,{ {|| TRANSFORM(VAL(NISQTDE),cPict13_3)} ,"" ,STR0297           }) //"Qtde"
AADD(TB_Col_D,{ {|| IN100CTD(NISDTENTR_)}         ,"" ,STR0301        }) //"Entrega"
AADD(TB_Col_D,{ {|| NISFABR}                      ,"" ,STR0250     }) //"Fabricante"
AADD(TB_Col_D,{ {|| NISFORN}                      ,"" ,STR0251     }) //"Fornecedor"
AADD(TB_Col_D,{ {|| BuscaClass(NISCLASS,.F.)}     ,"" ,STR0394  }) //"Classificação"
IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"COLIS")
ENDIF
AADD(TB_Col_D,{ {|| IN100E_Msg(.T.)}              ,"" ,STR0112       }) // "Mensagem"


AADD(TB_Cols,{ {|| Int_SI->NSIMODELO}                        ,"" ,STR0106      }) //"Modelo"
AADD(TB_Cols,{ {|| Int_SI->NSI_CC+'-'+TRANSFORM(Int_SI->NSI_NUM,_PictSI)} ,"" ,_LIT_R_CC+STR0300}) //"-S.I."
AADD(TB_Cols,{ {|| IN100CTD(Int_SI->NSI_DT)}                 ,"" ,STR0395   }) //"Data S.I."
AADD(TB_Cols,{ {|| Int_SI->NSI_POLE}                         ,"" ,STR0311}) //"Local Entrega"
AADD(TB_Cols,{ {|| Int_SI->NSICOMPRA}                        ,"" ,STR0293   }) //"Comprador"

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"COLSI")
ENDIF
AADD(TB_Cols,{ {|| IN100E_Msg(.T.)}                  ,"" ,STR0112    }) // "Mensagem"

RETURN .T.

*---------------------------------------------------------------------------------------------------*
FUNCTION IN100LerSI()
*---------------------------------------------------------------------------------------------------*
LOCAL cCod_I, NrReg:=1, lMudou,aTabReg:={},cOcor, cSIMsg

LOCAL cIncCI, cIncFA, cIncFO, lAchou, lDetMsg:=.F., cPosSI,nRegNIS, cChaveIS

LOCAL bComprador, bLocal, bDtEntr:=FIELDWBLOCK("NISDTENTR_",SELECT("Int_IS"))

LOCAL cMsgSI:=STR0396+NSI_CC+'-'+NSI_NUM //'PROCESSANDO C.C. - S.I. '

LOCAL cOldFuncao

Int_SI->NSIITEM_OK:="T"

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"LERSI")
ENDIF

IF EMPTY(Int_SI->NSI_CC)
   EVAL(bMsg,STR0550+STR0546)  // NAOINFORMADO 
ENDIF

IF ! SY3->(DBSEEK(cFilSY3+Int_SI->NSI_CC))
   EVAL(bMsg,STR0550+STR0544)  // SEMCADASTRO CENTRO_CUSTO 
ENDIF

IF EMPTY(ALLTRIM(NSI_NUM))
   EVAL(bMsg,STR0397+STR0546) //"No. S.I. NAOINFORMADO
ENDIF

IF ! EMPTY(ALLTRIM(NSI_CC)) .AND. ! EMPTY(ALLTRIM(NSI_NUM))
   IF ! SW0->(DBSEEK(cFilSW0+Int_SI->NSI_CC+Int_SI->NSI_NUM))                                         //MJB-SAP-0401

      IF NSITIPO # INCLUSAO
         EVAL(bMsg,_LIT_R_CC+STR0300+STR0544)  // SEMCADASTRO
      ENDIF

   ELSEIF NSITIPO = INCLUSAO

          EVAL(bMsg,_LIT_R_CC+STR0300+STR0545)  // COMCADASTRO
   ELSE
          lMudou:=.F.

          IF NSITIPO == EXCLUSAO

             SW1->(DBSEEK(cFilSW1+Int_SI->NSI_CC+Int_SI->NSI_NUM))                                    //MJB-SAP-0401
             SW1->(DBEVAL({|| lMudou:=(SW1->W1_QTDE # SW1->W1_SALDO_Q)}    ,,;
                                      {||!lMudou                         .AND. ;
                                     SW1->W1_CC     == Int_SI->NSI_CC    .AND. ;
                                     SW1->W1_SI_NUM == Int_SI->NSI_NUM   .AND. ;
                                     SW1->W1_FILIAL == cFilSW1}))                                     //MJB-SAP-0401

             IF lMudou
                EVAL(bMsg,_LIT_R_CC+STR0300+STR0398) //' EM ANDAMENTO'
             ENDIF
          ENDIF
   ENDIF
ENDIF

IF NSITIPO == EXCLUSAO
   IF EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"VALSI")
   ENDIF
   IN100VerErro(cErro,cAviso)
   IF Int_SI->NSIINT_OK = "T"
      nResumoCer+=1
   ELSE
      nResumoErr+=1
   ENDIF
   RETURN
ENDIF

bLocal    :=FIELDBLOCK('NSI_POLE')
bComprador:=FIELDBLOCK('NSICOMPRA')

IN100Capa(NSI_DT,STR0399,bLocal,bComprador,Int_SI->NSITIPO) //"DATA DA S.I."

IF ! Int_IS->(DBSEEK(Int_SI->NSI_CC+Int_SI->NSI_NUM+Int_SI->NSISEQ_SI)) .AND. Int_SI->NSITIPO # ALTERACAO
   EVAL(bMsg,STR0400) //"S.I. NAO POSSUI ITENS"
ENDIF

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"VALSI")
ENDIF
IN100VerErro(cErro,cAviso)
cErro:=NIL ; cAviso:=NIL

If Type("bUpDate") <> "B"
   bUpDate:= Nil
EndIf

WHILE ! Int_IS->(EOF()) .AND. Int_IS->NISCC      == Int_SI->NSI_CC   .AND.;
                              Int_IS->NISSI_NUM  == Int_SI->NSI_NUM  .AND.;
                              Int_IS->NISSEQ_SI  == Int_SI->NSISEQ_SI

  IF EasyEntryPoint("IN100CLI")
     ExecBlock("IN100CLI",.F.,.F.,"LERIS")
  ENDIF


  IF EMPTY(Int_IS->NISPOSICAO)
     EVAL(bMsg,STR0401+STR0546) //" POSICAO DO ITEM NAOINFORMADO
  ELSE
     Int_IS->NISPOSICAO:=STRZERO(VAL(Int_IS->NISPOSICAO),4,0)
  ENDIF

  cIncCI:=cIncFA:=cIncFO:=' '

  cCod_I:=AvKey( LEFT(Int_IS->NISCOD_I,NLENITEM), "B1_COD")          //NCF - 28/03/2011 - Acerto na chave do Item

  cIncCI:=IN100VerItem(LEFT(Int_IS->NISCOD_I,NLENITEM))

  IF EMPTY(Int_IS->NISTIPO)
     EVAL(bMsg,STR0402+STR0546) //" TIPO DO P.O. NAOINFORMADO
  ELSEIF Int_IS->NISTIPO $ 'i.a.e'
     Int_IS->NISTIPO := UPPER(Int_IS->NISTIPO)
  ELSEIF ! Int_IS->NISTIPO $ 'I.A.E'
     EVAL(bmsg,STR0548+STR0549)  // TIPO_INT INVALIDO
  ENDIF

  IF Int_IS->NISTIPO == INCLUSAO
     nRegNIS:=Int_IS->(RECNO())
     cChaveIS :=Int_IS->NISCC+Int_IS->NISSI_NUM
     cPosIS:=Int_IS->NISPOSICAO
     Int_IS->(DBSEEK(cChaveIS))
     DO WHILE ! Int_IS->(EOF()) .AND. cChaveIS = Int_IS->NISCC+Int_IS->NISSI_NUM
        IF Int_IS->NISPOSICAO = cPosIS .AND. nRegNIS>Int_IS->(RECNO())
           EVAL(bMsg,STR0343) //"ITEM REPETIU A POSICAO"
           EXIT
        ENDIF
        Int_IS->(DBSKIP())
     ENDDO
     Int_IS->(DBGOTO(nRegNIS))
  ENDIF

  SW1->(DBSETORDER(1))
  cChavePes:=(Int_IS->NISCC+Int_IS->NISSI_NUM+LEFT(Int_IS->NISCOD_I,NLENITEM))
  SW1->(DBSEEK(cFilSW1+cChavePes))                                                                    //MJB-SAP-0401
  IF SW1->(EOF()) .AND. Int_IS->NISTIPO#INCLUSAO
     EVAL(bMsg,STR0403) //" ITEM DA S.I. NAO CADASTRADA"
  ELSEIF ! SW1->(EOF())
     lAchou = .f.
     DO WHILE ! SW1->(EOF()) .AND. cFilSW1=SW1->W1_FILIAL .AND. cChavePes == (SW1->W1_CC+SW1->W1_SI_NUM+SW1->W1_COD_I) //MJB-SAP-0401
        IF SW1->W1_POSICAO == Int_IS->NISPOSICAO .AND. SW1->W1_SEQ = 0
           lAchou = .t.
           NrReg:=SW1->W1_REG
           IF SW1->W1_QTDE # SW1->W1_SALDO_Q
              EVAL(bMsg,STR0404) //'ITEM DA SI EM ANDAMENTO'
           ENDIF
           exit
        ENDIF
        SW1->(DBSKIP())
     ENDDO

     IF ! lAchou .AND. Int_IS->NISTIPO # INCLUSAO
        EVAL(bMsg,STR0403) //" ITEM DA S.I. NAO CADASTRADA"
     ELSEIF Int_IS->NISTIPO=INCLUSAO .AND. lAchou
        EVAL(bMsg,STR0405) //" ITEM DA S.I. JA CADASTRADA"
     ELSE
        Int_IS->NISREG:= STR(SW1->W1_REG,nTamReg,0)
     ENDIF
  ENDIF

  IF Int_IS->NISTIPO # EXCLUSAO
     cIncFA:=IN100VerFF('1',Int_IS->NISFABR)
     cIncFO:=IN100VerFF('2',Int_IS->NISFORN)
     IF (EMPTY(Int_IS->NISFABR) .AND. ! EMPTY(Int_IS->NISFORN))
        EVAL(bMsg,STR0250+STR0546) //'FABRICANTE NAO INFORMADO'
     ENDIF

     IF (EMPTY(Int_IS->NISFORN) .AND. ! EMPTY(Int_IS->NISFABR))
        EVAL(bMsg,STR0251+STR0546) //'FORNECEDOR NAO INFORMADO'
     ENDIF

     IN100VerQtDt(Int_IS->NISQTDE,bDtEntr)

     cChave:=Int_SI->NSI_CC+Int_IS->NISSI_NUM+cCod_I

     IF EMPTY(ALLTRIM(Int_IS->NISCLASS))
        IF ! lModelo
           EVAL(bMsg,STR0350+STR0549) //'TIPO DE MATERIAL INVALIDO
        ELSE
           Int_IS->NISCLASS:=SWU->WU_TIPOSI
           EVAL(bMsg,STR0350+STR0547,.T.) //'TIPO DE MATERIAL DOMODELO
        ENDIF
     ELSEIF ! SX5->(dbSeek(cFilSX5+'Y1'+Int_IS->NISCLASS))
            EVAL(bMsg,STR0350+STR0544) //'TIPO DE MATERIAL SEMCADASTRO
     ENDIF
  ENDIF

  IF EasyEntryPoint("IN100CLI")
     ExecBlock("IN100CLI",.F.,.F.,"VALIS2")
  ENDIF

  IF Int_IS->NISTIPO == INCLUSAO .AND. cErro = NIL
     IF (cOcor:=ASCAN(aTabReg,{|chave| chave[1] == cChave})) # 0
        NrReg := aTabReg[cOcor,2] + 1
        aTabReg[cOcor,2] := NrReg
     ELSE
        cChave:=Int_IS->NISCC+Int_IS->NISSI_NUM+LEFT(Int_IS->NISCOD_I,NLENITEM)
        cFor  :=Int_IS->NISCC+Int_IS->NISSI_NUM
        NrReg :=IN100VerReg(cChave,;
                {||SW1->W1_CC+SW1->W1_SI_NUM+SW1->W1_COD_I=cChave .AND. SW1->W1_FILIAL==cFilSW1})     //MJB-SAP-0401

        NrReg += 1

        AADD(aTabReg,{Int_IS->NISCC+Int_IS->NISSI_NUM+LEFT(Int_IS->NISCOD_I,NLENITEM),NrReg})
     ENDIF
     IF NrReg > 9999
        NrReg :=0
        EVAL(bMsg,STR0352) //"ITEM REPETIU MAIS DE 9999 VEZES "
     ENDIF
  ENDIF

  IF EasyEntryPoint("IN100CLI")
     ExecBlock("IN100CLI",.F.,.F.,"VALIS")
  ENDIF
  IF cErro # NIL
     Int_IS->NISMSG:=cErro
     Int_IS->NISINT_OK := "F"
     cErro:= NIL
     lDetMsg:=.T.
  ELSE
     Int_IS->NISINT_OK:= "T"
     Int_IS->NISREG   :=STR(NrReg,nTamReg,0)
     Int_IS->NISINCLUI:=cIncCI+cIncFA+cIncFO
     IF cAviso # NIL
        Int_IS->NISMSG:=cAviso ; cAviso:= NIL
     ENDIF
  ENDIF

  if valtype(bUpDate)=="B"	//--- ADC 09/02/2011 Para tratamento da integração EICIN100 x AvInteg
     cOldFuncao := cFuncao
     cFuncao    := "IS"
     Eval(bUpDate, Int_IS->NISMSG,Int_IS->NISINT_OK)
     cFuncao    := cOldFuncao
     If Int_IS->NISINT_OK == "F"
        lDetMsg := .T.
     EndIf
  endif

  If Int_SI->NSIITEM_OK = "T" .AND. ! Int_IS->NISINT_OK = "T"
     Int_SI->NSIITEM_OK:="F"
  EndIf

  Int_IS->(DBSKIP())
ENDD

IF lDetMsg .AND. Int_SI->NSITIPO == INCLUSAO
   Int_SI->NSIINT_OK := "F"
ENDIF

IF EMPTY(ALLTRIM(Int_SI->NSIMSG)) .AND. lDetMsg
   Int_SI->NSIMSG :=STR0354 //".....VIDE ITENS"
ENDIF

IF Int_SI->NSIINT_OK = "T"
   nResumoCer+=1
ELSE
   nResumoErr+=1
ENDIF

IF Int_SI->NSIINT_OK = "T" .AND. Int_SI->NSITIPO='A' .AND. ! Int_SI->NSIITEM_OK = "T"
   nResumoAlt+=1
ENDIF
RETURN .T.

*---------------------------------------------------------------------------------------------------*
FUNCTION IN100GrvSI()
*---------------------------------------------------------------------------------------------------*
LOCAL IncluiCI, IncluiFA, IncluiFO, nFabr, nForn, bSave:=bMessage, cCCusto, cAlias, i
LOCAL _LIT_R_CC := IF(EMPTY(ALLTRIM(EasyGParam("MV_LITRCC"))),(AVSX3("W0__CC")[5]),ALLTRIM(EasyGParam("MV_LITRCC")))

aTabW0:={}

IF Int_SI->NSITIPO = EXCLUSAO .OR. Int_SI->NSITIPO == ALTERACAO
   SW0->(DBSEEK(cFilSW0+Int_SI->NSI_CC+Int_SI->NSI_Num))                                              //MJB-SAP-0401
   IF ! Reclock("SW0",.F.)
      RETURN
   ENDIF
   DBSELECTAREA('Int_SI')
ENDIF
IF Int_SI->NSITIPO = EXCLUSAO
   Begin Transaction

   SW1->(DBSEEK(cFilSW1+SW0->W0__CC+SW0->W0__NUM))                                                    //MJB-SAP-0401
   SW1->(DBEVAL({||Reclock("SW1",.F.), DBDELETE() },,;
                {||SW1->W1_CC     == SW0->W0__CC .AND. ;
                   SW1->W1_SI_NUM == SW0->W0__NUM .AND. SW1->W1_FILIAL==cFilSW1}))                    //MJB-SAP-0401
   SW0->(DBDELETE())
   SW0->(MSUNLOCK())
   DBSELECTAREA('Int_SI')
   EVAL(bMessage,_LIT_R_CC+STR0392) //"/S.I. EXCLUIDA"
   
   End Transaction
   
   RETURN
ENDIF

Begin Transaction

IF ! (EMPTY(Int_SI->NSI_POLE) .AND. Int_SI->NSITIPO = "A")
   IF Int_Param->NPAINC_LE .AND. ! SY2->(DBSEEK(cFilSY2+AvKey(Int_SI->NSI_POLE,"Y2_SIGLA")))
      Int_SI->(IN100Cadastra(CAD_LE,NSI_POLE))
   ENDIF
ENDIF

IF ! (EMPTY(Int_SI->NSICOMPRA) .AND. Int_SI->NSITIPO = "A")
   IF Int_Param->NPAINC_CO .AND. ! SY1->(DBSEEK(cFilSY1+AvKey(Int_SI->NSICOMPRA,"Y1_COD")))
      Int_SI->(IN100Cadastra(CAD_CO,NSICOMPRA))
   ENDIF
ENDIF

If(EasyEntryPoint("IN100CLI"),ExecBlock("IN100CLI",.F.,.F.,"ANTES_GRV_IS"),)

cFuncao := CAD_IS
bMessage:= FIELDWBLOCK('NISMSG',SELECT('Int_IS'))
Int_IS->(DBSEEK(Int_SI->NSI_CC+Int_SI->NSI_NUM+Int_SI->NSISEQ_SI))

WHILE ! Int_IS->(EOF()) .AND. Int_IS->NISCC    == Int_SI->NSI_CC .AND. ;
                              Int_IS->NISSI_NUM== Int_SI->NSI_NUM .AND. ;
                              Int_IS->NISSEQ_SI== Int_SI->NSISEQ_SI

  lLoop:=.F.
  If(EasyEntryPoint("IN100CLI"),ExecBlock("IN100CLI",.F.,.F.,"LOOP_GRV_IS"),)

  IF ! Int_IS->NISINT_OK = "T" .OR. lLoop
     Int_IS->(DBSKIP())
     LOOP
  ENDIF

  IncluiCI:=!EMPTY(LEFT(Int_IS->NISINCLUI,1))
  IncluiFA:=!EMPTY(SUBS(Int_IS->NISINCLUI,2,1))
  IncluiFO:=!EMPTY(RIGHT(Int_IS->NISINCLUI,1))
  nFabr   := Int_IS->NISFABR
  nForn   := Int_IS->NISFORN

  IF IncluiCI .AND. ! SB1->(DBSEEK(cFilSB1+AvKey(LEFT(Int_IS->NISCOD_I,NLENITEM),"B1_COD")))
     Int_IS->(IN100Cadastra(CAD_CI,NISCOD_I))
  ENDIF                   
  
  IF lNIPTEC .AND. !EMPTY(Int_IP->NIPTEC) .AND. Int_Param->NPAINC_NBM .AND. ;
     !SYD->(DBSEEK(cFilSYD+AVKey(Int_IP->NIPTEC,"YD_TEC")+AVKey(Int_IP->NIPEX_NCM,"YD_EX_NCM")+Int_IP->NIPEX_NBM))
     Int_CI->(IN100Cadastra(CAD_NB,Int_IP->NIPTEC,Int_IP->NIPEX_NCM,Int_IP->NIPEX_NBM))
  ENDIF

  IF IncluiFA .AND. ! SA2->(DBSEEK(cFilSA2+AvKey(nFabr,"A2_COD")))
     IN100TabFabFor(nFabr,'1')
  ENDIF

  IF IncluiFO .AND. ! SA2->(DBSEEK(cFilSA2+AvKey(nForn,"A2_COD")))
     IN100TabFabFor(nForn,'2')
  ENDIF
  If lNIPTEC
     SA5->(DBSEEK(cFilSA5+AvKey(LEFT(Int_IP->NIPCOD_I,AvSX3("A5_PRODUTO",AV_TAMANHO)),"A5_PRODUTO")+AvKey(cFabr,"A5_FABR")+AvKey(cForn,"A5_FORNECE")))
  EndIf
  SA5->(DBSETORDER(3))
  IF Int_Param->NPAINC_LI .AND. ! EMPTY(nFabr) .AND. !EMPTY(nForn) .AND. ;
   ! SA5->(DBSEEK(cFilSA5+AvKey(LEFT(Int_IS->NISCOD_I,AvSX3("A5_PRODUTO",AV_TAMANHO)),"A5_PRODUTO")+AvKey(nFabr,"A5_FABR")+AvKey(nForn,"A5_FORNECE")))
     Int_IS->(IN100Cadastra(CAD_LI,NISCOD_I,nFabr,nForn))
  ENDIF
  SA5->(DBSETORDER(1))

  IF Int_IS->NISTIPO=ALTERACAO .OR. Int_IS->NISTIPO=EXCLUSAO

     IF Int_IS->NISTIPO=EXCLUSAO
        IF ASCAN(aTabW0,{|chave| chave[1] == Int_IS->NISCC+Int_IS->NISSI_NUM}) = 0
           AADD(aTabW0,{Int_IS->NISCC+Int_IS->NISSI_NUM,0})
        ENDIF
     ENDIF

     IN100DelIS()
  ENDIF

  IF Int_IS->NISTIPO=ALTERACAO .OR. Int_IS->NISTIPO=INCLUSAO
     Int_IS->(IN100SI_PO())
  ENDIF
  Int_IS->(DBSKIP())
ENDDO

DBSELECTAREA('Int_SI')
FOR I=1 TO LEN(aTabW0)
    IF ! SW1->(DBSEEK(cFilSW1+aTabW0[I,1]))                                                           //MJB-SAP-0401
       IF SW0->(DBSEEK(cFilSW0+aTabW0[I,1]))                                                          //MJB-SAP-0401
          SW0->(DBDELETE())
       ENDIF
    ENDIF
NEXT

IF Int_SI->NSITIPO = ALTERACAO
   IF SW0->(DBSEEK(cFilSW0+Int_SI->NSI_CC+Int_SI->NSI_Num))                                           //MJB-SAP-0401
      SW0->W0__DT   :=IF(!EMPTY(ALLTRIM(IN100CTD(Int_SI->NSI_DT))),IN100CTD(Int_SI->NSI_DT),SW0->W0__DT)
      SW0->W0__POLE :=IF(!EMPTY(ALLTRIM(Int_SI->NSI_POLE)) ,Int_SI->NSI_POLE,SW0->W0__POLE)
      SW0->W0_COMPRA:=IF(!EMPTY(ALLTRIM(Int_SI->NSICOMPRA)),Int_SI->NSICOMPRA,SW0->W0_COMPRA)
      SW0->W0_SOLIC :=IF(!EMPTY(ALLTRIM(Int_SI->NSISOLIC)) ,Int_SI->NSISOLIC,SW0->W0_SOLIC)
      SW0->W0_REFER1:=IF(!EMPTY(ALLTRIM(Int_SI->NSIREFER1)),Int_SI->NSIREFER1,SW0->W0_REFER1)

      If EasyEntryPoint("IN100CLI")
         ExecBlock("IN100CLI",.F.,.F.,"GRVSI")
      ENDIF
   ENDIF
ENDIF

cFuncao := CAD_SI
bMessage:= bSave
SW0->(MSUNLOCK())

End Transaction   

DBSELECTAREA('Int_SI')
RETURN NIL

*-----------------------------------------------------------------------------
FUNCTION IN100DelIS()
*-----------------------------------------------------------------------------
LOCAL cAlias

SW1->(DBSETORDER(1))
cChavePes:=(Int_IS->NISCC+Int_IS->NISSI_NUM+LEFT(Int_IS->NISCOD_I,NLENITEM))

SW1->(DBSEEK(cFilSW1+cChavePes))                                                                      //MJB-SAP-0401
DO WHILE ! SW1->(EOF()) .AND. cFilSW1=SW1->W1_FILIAL .AND. cChavePes == (SW1->W1_CC+SW1->W1_SI_NUM+SW1->W1_COD_I) //MJB-SAP-0401
   IF SW1->W1_POSICAO == Int_IS->NISPOSICAO .AND. VAL(Int_IS->NISREG) == SW1->W1_REG
      Reclock("SW1",.F.)
      SW1->(DBDELETE())
   ENDIF
   SW1->(DBSKIP())
ENDDO
DBSELECTAREA(cAlias)
RETURN .T.

*********************************************************************************************
*  Funcoes novas feitas por A.C.D.  06.03.98                                                *
*********************************************************************************************

*------------------------------------------------------------------------------------------*
FUNCTION IN100ItemFabrFor()
*------------------------------------------------------------------------------------------*
AADD(TB_Cols,{ {|| TRANSFORM(Left(Int_LI->NLICOD_I,NLENITEM),_PictItem) }   , "", STR0120                   }) //"Item"
AADD(TB_Cols,{ {|| Int_LI->NLIFABR }                             , "", STR0250             }) //"Fabricante"
AADD(TB_Cols,{ {|| Int_LI->NLIFORN }                             , "", STR0251             }) //"Fornecedor"
AADD(TB_Cols,{ {|| Int_LI->NLIPART_N }                           , "", STR0408            }) //"Part-Number"
AADD(TB_Cols,{ {|| IF(Int_LI->NLISTATUS='1',STR0096,IF(NLISTATUS='2',STR0095,PADL(NLISTATUS,3)))}, "", STR0161}) //'Sim'###'Nao'###"Homologado"
AADD(TB_Cols,{ {|| TRANSFORM(VAL(Int_LI->NLIVLCOT_US),_PictPrUn) }    , "", STR0409      }) //"Valor Cotacao US$"
AADD(TB_Cols,{ {|| TRANSFORM(VAL(Int_LI->NLIQT_COT),cPict13_3) }      , "", STR0410           }) //"Qtde. Cotada"
AADD(TB_Cols,{ {|| Int_LI->NLILEAD_T }                           , "", STR0411    }) //"Lead Time Forneci/o"
AADD(TB_Cols,{ {|| IN100CTD(Int_LI->NLIULT_ENT) }                , "", STR0412         }) //"Ultima Entrega"
AADD(TB_Cols,{ {|| TRANSFORM(VAL(Int_LI->NLIULT_FOB),_PictPrUn) }     , "", STR0413             }) //"Ultimo FOB"
AADD(TB_Cols,{ {|| TRANSFORM(VAL(Int_LI->NLILOTE_MIN),'@E 99,999.99')}, "", STR0414            }) //"Lote Minimo"
AADD(TB_Cols,{ {|| TRANSFORM(VAL(Int_LI->NLILOTE_MUL),'@E 99,999.99')}, "", STR0415          }) //"Lote Multiplo"
AADD(TB_Cols,{ {|| Int_LI->NLIPART_OPC }                         , "", STR0416 }) //"Part-Numbers Opcionais"
AADD(TB_Cols,{ {|| Int_LI->NLIMOE_US }                           , "", STR0417       }) //"Moeda Fornecedor"
AADD(TB_Cols,{ {|| Int_LI->NLIUNID }                             , "", STR0121                }) //"Unidade"

ASIZE(TBRCols,0)
AADD(TBRCols,{ "IN100Status()"                        , STR0036            }) //"Status"
AADD(TBRCols,{ "IN100Tipo()"                          , STR0037              }) //"Tipo"
AADD(TBRCols,{ "IN100CTD(Int_LI->NLIINT_DT)"                  , STR0071          }) //"Dt Integ"
AADD(TBRCols,{ {||TRANSFORM(Left(Int_LI->NLICOD_I,NLENITEM),_PictItem)} ,STR0120          }) //"Item"
AADD(TBRCols,{ "Int_LI->NLIFABR"                              , STR0418            }) //"Fabric"
AADD(TBRCols,{ "Int_LI->NLIFORN"                              , STR0419            }) //"Fornec"
AADD(TBRCols,{ "Int_LI->NLIPART_N"                            , STR0408       }) //"Part-Number"
AADD(TBRCols,{ {||IF(NLISTATUS='1',STR0096,IF(Int_LI->NLISTATUS='2',STR0095,PADL(NLISTATUS,3)))},STR0420}) //'Sim'###'Nao'###"Homol"
AADD(TBRCols,{ "TRANSFORM(VAL(Int_LI->NLIVLCOT_US),_PictPrUn)"     , STR0409 }) //"Valor Cotacao US$"
AADD(TBRCols,{ "TRANSFORM(VAL(Int_LI->NLIQT_COT),cPict13_3)"       , STR0410      }) //"Qtde. Cotada"
AADD(TBRCols,{ "Int_LI->NLILEAD_T"                            , STR0421         }) //"Lead Time"
AADD(TBRCols,{ "IN100CTD(Int_LI->NLIULT_ENT)"                 , STR0422         }) //"Ult.Entr."
AADD(TBRCols,{ "TRANSFORM(VAL(Int_LI->NLIULT_FOB),_PictPrUn)"      , STR0413        }) //"Ultimo FOB"
AADD(TBRCols,{ "TRANSFORM(VAL(Int_LI->NLILOTE_MIN),'@E 99,999.99')", STR0423          }) //"Lote Min"
AADD(TBRCols,{ "TRANSFORM(VAL(Int_LI->NLILOTE_MUL),'@E 99,999.99')", STR0424         }) //"Lote Mult"
AADD(TBRCols,{ "Int_LI->NLIMOE_US"                            , STR0240             }) //"Moeda"
AADD(TBRCols,{ "Int_LI->NLIUNID"                              , STR0425               }) //"Uni"

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"COLLI")
ENDIF
AADD(TB_Cols,{ {|| IN100E_Msg(.T.) }                     , "", STR0112               }) // "Mensagem"

RETURN .T.

*------------------------------------------------------------------------------------------*
FUNCTION IN100LerLI()
*------------------------------------------------------------------------------------------*
IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"LERLI")
ENDIF

IF EMPTY(Int_LI->NLICOD_I)
   EVAL(bmsg,STR0556+STR0546) // CODIGO_ITEM NAOINFORMADO
ENDIF

IF ! SB1->(DBSEEK(cFilSB1+LEFT(Int_LI->NLICOD_I,NLENITEM) ))
   EVAL(bMsg,STR0426+ALLTRIM(Int_LI->NLICOD_I) + STR0544) //'ITEM SEMCADASTRO
ENDIF

SA5->( DbSetOrder( 3 ) )

//AAF - 25/10/13
IF ! SA5->(DBSEEK(cFilSA5+Avkey(Int_LI->NLICOD_I, "A5_PRODUTO" )+AvKey(Int_LI->NLIFABR, "A5_FABR")+Avkey(Int_LI->NLIFORN,"A5_FORNECE") ))


   IF Int_LI->NLITIPO = EXCLUSAO  //# INCLUSAO
      EVAL(bMsg, STR0558+STR0544)  // LIGACAO_ITFB SEM CADASTRO
   ENDIF

   IF Int_LI->NLITIPO = ALTERACAO
      cAlias := Alias()
      Reclock( "Int_LI", .F. )
      DbSelectArea( cAlias )

      Int_LI->NLITIPO := INCLUSAO

      Int_LI->( MsUnlock() )
   ENDIF

ELSEIF Int_LI->NLITIPO = INCLUSAO
   EVAL(bMsg,STR0558+STR0545)  // LIGACAO_ITFB COMCADASTRO

ELSEIF Int_LI->NLITIPO == EXCLUSAO

   EVAL( bMsg, STR0427+Int_LI->NLIFABR+; //"PESQUISANDO FABRICANTE "
               STR0428+Int_LI->NLIFORN,0 ) //" FORNECEDOR "

   SW3->( DbSetOrder( 3 ) )
   SW3->(DBSEEK(cFilSW3+LEFT(Int_LI->NLICOD_I, nLenItem)))                                            //MJB-SAP-0401

   DO WHILE ! SW3->(EOF()) .AND. ;
      LEFT(SW3->W3_COD_I,nLenItem) == LEFT(Int_LI->NLICOD_I,nLenItem) .AND. cFilSW3==SW3->W3_FILIAL   //MJB-SAP-0401

      IF SW3->W3_FABR == Int_LI->NLIFABR  .AND.  SW3->W3_FORN == Int_LI->NLIFORN
         EVAL(bMsg,STR0429+TRANSFORM(SW3->W3_PO_NUM,_PictPO )) //"LIGACAO PERTENCE AO P.O. "
         EXIT
      ENDIF
      SW3->(DBSKIP())
   ENDDO

   SW3->( DbSetOrder( 1 ) )

ENDIF

SA5->( DbSetOrder( 1 ) )

IF Int_LI->NLITIPO == EXCLUSAO
   IF EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"VALLI")
   ENDIF
   IN100VerErro(cErro,cAviso)
   IF Int_LI->NLIINT_OK = "T"
      nResumoCer+=1
   ELSE
      nResumoErr+=1
   ENDIF
   RETURN
ENDIF

IF SA5->(EOF())
   IF EMPTY(ALLTRIM(Int_LI->NLIFABR))
      EVAL(bMsg,STR0250+STR0546) //'FABRICANTE NAO INFORMADO'
   ELSEIF ! SA2->(DBSEEK(cFilSA2+Int_LI->NLIFABR ))
      IF ! Int_Param->NPAINC_FA
         EVAL(bMsg,STR0377+Int_LI->NLIFABR+STR0544) //"FABRICANTE SEMCADASTRO
      ENDIF
   ELSEIF AT(Left(SA2->A2_ID_FBFN,1),'13') = 0
      EVAL(bMsg,STR0431) //'FABRICANTE CADASTRADO COMO FORNECEDOR'
   ENDIF

   IF EMPTY(ALLTRIM(Int_LI->NLIFORN))
      EVAL(bMsg,STR0251+STR0546) //'FORNECEDOR NAO INFORMADO'
   ELSEIF ! SA2->(DBSEEK(cFilSA2+Int_LI->NLIFORN ))
      IF ! Int_Param->NPAINC_FO
         EVAL(bMsg,STR0432+Int_LI->NLIFORN+STR0544) //"FORNECEDOR SEMCADASTRO
      ENDIF
   ELSEIF AT(Left(SA2->A2_ID_FBFN,1),'23') = 0
      EVAL(bMsg,STR0433) //'FORNECEDOR CADASTRADO COMO FABRICANTE'
   ENDIF
ENDIF


IF ! EMPTY(Int_LI->NLIMOE_US) .AND. ! SYF->(DBSEEK(cFilSYF+Int_LI->NLIMOE_US))
   EVAL(bMsg,STR0240+STR0544) //"MOEDA SEMCADASTRO
ENDIF

IF ! EMPTY(LEFT(Int_LI->NLIUNID,nTamUM)) .AND. ! SAH->(DBSEEK(cFilSAH+ALLTRIM(LEFT(Int_LI->NLIUNID,nTamUM))))
// EVAL(bmsg,STR0137+STR0544,.T.) //"UNIDADE MEDIDA SEMCADASTRO
   EVAL(bmsg,STR0137+STR0544) //"UNIDADE MEDIDA SEMCADASTRO
ENDIF

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"VALLI")
ENDIF
IN100VerErro(cErro,cAviso)

IF Int_LI->NLIINT_OK = "T"
   nResumoCer+=1
ELSE
   nResumoErr+=1
ENDIF
RETURN .T.

*------------------------------------------------------------------------------------------*
FUNCTION IN100GrvLI()
*------------------------------------------------------------------------------------------*
LOCAL cAlias

IF Int_LI->NLITIPO # INCLUSAO

   SA5->( DbSetOrder( 3 ) )

   SA5->(DBSEEK(cFilSA5+LEFT(Int_LI->NLICOD_I, nLenItem) +;
                                    Int_LI->NLIFABR       +;
                                    Int_LI->NLIFORN       ))

   SA5->( DbSetOrder( 1 ) )

   IF SA5->(EOF())  .AND.  Int_LI->NLITIPO = ALTERACAO
      EVAL(bmsg,STR0434+STR0544+STR0141) //"ITEM/FABRICANTE/FORNECEDOR"### SEMCADASTRO P/ ALTERACAO"
      RETURN
   ENDIF

   cAlias:=ALIAS()
   Reclock("SA5",.F.)
   DBSELECTAREA(cAlias)

   IF Int_LI->NLITIPO = EXCLUSAO
      SA5->(DBDELETE())
      SA5->(DBCOMMIT())
      SA5->(MSUNLOCK())

      If EasyEntryPoint("IN100CLI")
         ExecBlock("IN100CLI",.F.,.F.,"EXCLI")
      EndIf
      
      RETURN
   

   ENDIF
ENDIF


IF Int_LI->NLITIPO = INCLUSAO
   IN100RecLock('SA5')
   SB1->(DBSEEK(cFilSB1+LEFT(Int_LI->NLICOD_I,NLENITEM)))
   SA2->(DBSEEK(cFilSA2+Int_LI->NLIFORN))
   SA5->A5_FILIAL   := cFilSA5
   SA5->A5_PRODUTO  := Int_LI->NLICOD_I
   SA5->A5_FABR     := Int_LI->NLIFABR
// SA5->A5_NOMPROD  := SB1->B1_DESC
   SA5->A5_FORNECE  := Int_LI->NLIFORN
// SA5->A5_NOMEFOR  := SA2->A2_NOME
   SA5->A5_LOJA     := '.'
   SA5->A5_FALOJA   := '.'
ENDIF

IF(!EMPTY(Int_LI->NLIPART_N)           ,SA5->A5_CODPRF   := Int_LI->NLIPART_N,)
IF(!EMPTY(Int_LI->NLISTATUS)           ,SA5->A5_STATUS   := Int_LI->NLISTATUS,)
IF(VAL(Int_LI->NLIVLCOT_US)#0          ,SA5->A5_VLCOTUS  := VAL(Int_LI->NLIVLCOT_US),)
IF(VAL(Int_LI->NLIQT_COT)#0            ,SA5->A5_QT_COT   := VAL(Int_LI->NLIQT_COT),)
IF(VAL(Int_LI->NLILEAD_T)#0            ,SA5->A5_LEAD_T   := VAL(Int_LI->NLILEAD_T),)
IF(!EMPTY(IN100CTD(Int_LI->NLIULT_ENT)),SA5->A5_ULT_ENT  := IN100CTD(Int_LI->NLIULT_ENT),)
IF(VAL(Int_LI->NLIULT_FOB)#0           ,SA5->A5_ULT_FOB  := VAL(Int_LI->NLIULT_FOB),)
IF(VAL(Int_LI->NLILOTE_MIN)#0          ,SA5->A5_LOTEMIN  := VAL(Int_LI->NLILOTE_MIN),)
IF(VAL(Int_LI->NLILOTE_MUL)#0          ,SA5->A5_LOTEMUL  := VAL(Int_LI->NLILOTE_MUL),)
IF(!EMPTY(Int_LI->NLIPART_OPC)         ,SA5->A5_PARTOPC  := Int_LI->NLIPART_OPC,)
IF(!EMPTY(Int_LI->NLIMOE_US)           ,SA5->A5_MOE_US   := Int_LI->NLIMOE_US,)
IF(!EMPTY(LEFT(Int_LI->NLIUNID,nTamUM)),SA5->A5_UNID     := LEFT(Int_LI->NLIUNID,nTamUM),)

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"GRVLI")
EndIf

IF ! SA2->(DBSEEK(cFilSA2+AvKey(SA5->A5_FABR,"A2_COD"))) .AND. Int_Param->NPAINC_FA
   Int_LI->(IN100Cadastra(CAD_FB,SA5->A5_FABR,'3'))
ENDIF

IF ! SA2->(DBSEEK(cFilSA2+AvKey(SA5->A5_FORNECE,"A2_COD"))) .AND. Int_Param->NPAINC_FO
   Int_LI->(IN100Cadastra(CAD_FB,SA5->A5_FORNECE,'3'))
ENDIF

SA5->(MSUNLOCK())
RETURN .T.

*----------------------*
FUNCTION IN100Familia()
*----------------------*

AADD(TB_Cols,{ {|| Int_FP->NFPCOD                     }, "", STR0142                      }) //"Codigo"
AADD(TB_Cols,{ {|| Int_FP->NFPNOME                    }, "", STR0143                        }) //"Nome"

If cModulo = "EEC"
  AADD(TB_Cols,{ {|| Int_FP->NFPIDIOMA                     }, "", STR0043                      }) //"idioma"
  AADD(TB_Cols,{ {|| Int_FP->NFPGRUPO                    }, "", STR0741                        }) //"GRUPO"
ENDIF


ASIZE(TBRCols,0)
AADD(TBRCols,{ "IN100Status()"      , STR0036 }) //"Status"
AADD(TBRCols,{ "IN100Tipo()"        , STR0037 }) //"Tipo"
AADD(TBRCols,{ "IN100CTD(Int_FP->NFPINT_DT)", STR0071 }) //"Dt Integ"
AADD(TBRCols,{ "Int_FP->NFPCOD"             , STR0142 }) //"Codigo"
AADD(TBRCols,{ "Int_FP->NFPNOME"            , STR0143 }) //"Nome"
If cModulo = "EEC"
   AADD(TBRCols,{ "Int_FP->NFPIDIOMA"            , STR0043  }) //IDIOMA
   AADD(TBRCols,{ "Int_FP->NFPGRUPO"            , STR0741 }) //GRUPO
ENDIF


IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"COLFP")
ENDIF

AADD(TB_Cols,{ {|| IN100E_Msg(.T.) }, "", STR0112 }) // "Mensagem"
AADD(TBRCols,{ {||IN100E_MSG(.T.)  }      ,STR0112}) //"Mensagem"

RETURN .T.

*--------------------*
FUNCTION IN100LerFP()
*--------------------*
Local cAlias

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"LERFP")
ENDIF

IF EMPTY(Int_FP->NFPCOD)
   EVAL(bMsg,STR0560+STR0546)  // CODIGO_FAM NAOINFORMADO
ENDIF              

If cModulo = "EIC"          
   SYC->(DBSETORDER(1))                     
   lAchouSYC := SYC->(DBSEEK(cFilSYC+Int_FP->NFPCOD))
ElseIf cModulo = "EEC"
                          
   If Empty(Alltrim(Int_FP->NFPIDIOMA))
      Int_FP->NFPIDIOMA := EasyGParam("MV_AVG0035",,"PORT.")
   ElseIf ! SX5->(DBSEEK(cFilSX5+'ID'+Int_FP->NFPIDIOMA))
      EVAL(bmsg,STR0740) // Idioma sem cadastro
   ENDIF
   SYC->(DBSETORDER(4))
   lAchouSYC := SYC->(DBSEEK(cFilSYC+AVKey(INIDIOMA(Int_FP->NFPIDIOMA),"YC_IDIOMA")+Int_FP->NFPCOD))
EndIf

IF ! lAchouSYC

   IF Int_FP->NFPTIPO = EXCLUSAO        //  # INCLUSAO
      EVAL(bMsg,STR0560+STR0544)  // CODIGO_FAM SEMCADASTRO
   ENDIF

   IF Int_FP->NFPTIPO = ALTERACAO
      cAlias := Alias()
      Reclock( "Int_FP", .F. )
      DbSelectArea( cAlias )

      Int_FP->NFPTIPO := INCLUSAO

      Int_FP->( MsUnlock() )
   ENDIF

ELSEIF Int_FP->NFPTIPO = INCLUSAO
   EVAL(bMsg,STR0560+STR0545)  // CODIGO_FAM COMCADASTRO

ENDIF

IF Int_FP->NFPTIPO == EXCLUSAO
   IF EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"VALFP")
   ENDIF
   IN100VerErro(cErro,cAviso)
   IF Int_FP->NFPINT_OK = "T"
      nResumoCer+=1
   ELSE
      nResumoErr+=1
   ENDIF
   RETURN
ENDIF

IF EMPTY(Int_FP->NFPNOME) .AND. SYC->(EOF())
   EVAL(bMsg,STR0435+STR0546) //"NOME DA FAMILIA NAOINFORMADO
ENDIF

If cModulo = "EEC" .And. ! Empty(Alltrim(Int_FP->NFPGRUPO)) .And.;
! EEH->(DBSEEK(cFilEEH+AVKey(AVKey(Int_FP->NFPIDIOMA,"X5_CHAVE")+"-"+SX5->X5_DESCRI,"EEH_IDIOMA")+AVKey(Int_FP->NFPGRUPO,"EEH_COD")))
   EVAL(bMsg,"Grupo inválido") 
EndIf

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"VALFP")
ENDIF

IN100VerErro(cErro,cAviso)

IF Int_FP->NFPINT_OK = "T"
   nResumoCer+=1
ELSE
   nResumoErr+=1
ENDIF
RETURN .T.

*------------------------------------------------------------------------------------------*
FUNCTION IN100GrvFP()
*------------------------------------------------------------------------------------------*
LOCAL cAlias

IF Int_FP->NFPTIPO # INCLUSAO

   If cModulo = "EIC"          
      SYC->(DBSETORDER(1))                     
      lAchouSYC := SYC->(DBSEEK(cFilSYC+Int_FP->NFPCOD))
   ElseIf cModulo = "EEC"
      SYC->(DBSETORDER(4))
      lAchouSYC := SYC->(DBSEEK(cFilSYC+AVKey(INIDIOMA(Int_FP->NFPIDIOMA),"YC_IDIOMA")+AVKey(INIDIOMA(Int_FP->NFPCOD),"YC_COD")))
   EndIf

   IF !lAchouSYC  .AND.  Int_FP->NFPTIPO = ALTERACAO
      EVAL(bmsg,STR0434+STR0544+STR0141) //"ITEM/FABRICANTE/FORNECEDOR"### SEMCADASTRO P/ ALTERACAO"
      RETURN
   ENDIF
   cAlias:=ALIAS()
   Reclock("SYC",.F.)
   DBSELECTAREA(cAlias)

   IF Int_FP->NFPTIPO = EXCLUSAO
      SYC->(DBDELETE())
      SYC->(DBCOMMIT())
      SYC->(MSUNLOCK())
     
      If EasyEntryPoint("IN100CLI")
         ExecBlock("IN100CLI",.F.,.F.,"EXCFP")
      EndIf
      
      RETURN

   ENDIF
ENDIF

IF Int_FP->NFPTIPO = INCLUSAO
   IN100RecLock('SYC')
   SYC->YC_FILIAL   := cFilSYC
   SYC->YC_COD:=Int_FP->NFPCOD
   If cModulo = "EEC"          
      SYC->YC_IDIOMA  := AVKey(INIDIOMA(Int_FP->NFPIDIOMA),"YC_IDIOMA") //INIDIOMA(Int_FP->NFPIDIOMA)
   EndIf

ENDIF

IF(!EMPTY(Int_FP->NFPNOME)   ,SYC->YC_NOME    :=Int_FP->NFPNOME,)

If cModulo = "EEC"          
   IF(!EMPTY(Int_FP->NFPGRUPO)   ,SYC->YC_COD_RL  :=Int_FP->NFPGRUPO,)
EndIf

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"GRVFP")
EndIf

SYC->(MSUNLOCK())
Return Nil

*------------------------------------------------------------------------------------------*
FUNCTION IN100DespDespachante()
*------------------------------------------------------------------------------------------*
Local nVolta
LOCAL lTemOBs    := IF(Int_DspHe->(FIELDPOS("NDH_OBS")) # 0,.T.,.F.)
LOCAL lTemAdiant := IF(Int_DspDe->(FIELDPOS("NDDADIANTA")) # 0,.T.,.F.)
Local lIntDesp := IsInCallStack("EICEI100")
SYB->(DBSETORDER(1))

// BAK - Alteração realizada para nova integração com despachante
If !lIntDesp
   cNameNDH:=AllTrim(Int_Param->NPAARQ_DE)+".NDH"
   cNameNDD:=AllTrim(Int_Param->NPAARQ_DE)+".NDD"
   cNameNTX:=AllTrim(Int_Param->NPAARQ_DE)+".NTX"
EndIf
ASIZE(TB_Cols,0)

AADD( TB_Cols, { {|| IN100Status()                          }, "", STR0036             } ) //"Status"
AADD( TB_Cols, { {|| Int_DspHe->NDHREFDESP                 }, "", STR0436    } ) //"Ref.Despachante"
AADD( TB_Cols, { {|| Int_DspHe->NDHHOUSE                   }, "", STR0437       } ) //"Nr. Processo"
AADD( TB_Cols, { {|| IN100CTD(Int_DspHe->NDHDCHEG,,"DDMMAAAA")}, "", STR0438            } ) //"Chegada"     //MJB-SAP-1100
AADD( TB_Cols, { {|| IN100CTD(Int_DspHe->NDHDRECDOC,,"DDMMAAAA")  }, "", STR0439           } ) //"Rec.Doc." //MJB-SAP-1100
AADD( TB_Cols, { {|| Int_DspHe->NDHDESP                    }, "", STR0440        } ) //"Despachante"
AADD( TB_Cols, { {|| Int_DspHe->NDHAGENTE                  }, "", STR0290             } ) //"Agente"
AADD( TB_Cols, { {|| IN100CTD(Int_DspHe->NDHDPAGIMP,,"DDMMAAAA")  }, "", STR0441        } ) //"Pagto. Imp." //MJB-SAP-1100
AADD( TB_Cols, { {|| Int_DspHe->NDHDI_NUM                  }, "", STR0442        } ) //"Numero D.I."
//Campo novo - AWR 22/4/2003
AADD( TB_Cols, { {|| IN100CTD(Int_DspHe->NDHDTREGDI,,"DDMMAAAA")  }, , "Dt Reg DI" } )
//Campo novo - AWR 22/4/2003
//AADD( TB_Cols, { {|| TRANSFORM(Int_DspHe->NDHTX_FOB,cPict15_8)  }, "", STR0443        } ) //"Taxa D.I."
AADD( TB_Cols, { {|| IN100CTD(Int_DspHe->NDHDDESEMB,,"DDMMAAAA")}, "", STR0444   } ) //"Desembaraco"   //MJB-SAP-1100
AADD( TB_Cols, { {|| Int_DspHe->NDHFRETMOE                 }, "", STR0445        } ) //"Moeda Frete"
AADD( TB_Cols, { {|| TRANSFORM(Int_DspHe->NDHFRETVAL,cPict15_2) }, "", STR0446+" PP"  } ) //"Valor Frete"
//Campos novos - AWR 22/4/2003
AADD( TB_Cols, { {|| TRANSFORM(Int_DspHe->NDHVLFRECC,cPict15_2) }, "", STR0446+" CC"  } ) //"Valor Frete"
AADD( TB_Cols, { {|| TRANSFORM(Int_DspHe->NDHVLFRETN,cPict15_2) }, "", STR0446+" TN"  } ) //"Valor Frete"
//Campos novos - AWR 22/4/2003
AADD( TB_Cols, { {|| TRANSFORM(Int_DspHe->NDHFRETTAX,cPict15_8) }, "", STR0447        } ) //"Taxa Frete"
AADD( TB_Cols, { {|| Int_DspHe->NDHSEGUMOE                 }, "", STR0448        } ) //"Moeda Seguro"
AADD( TB_Cols, { {|| TRANSFORM(Int_DspHe->NDHSEGUVAL,cPict15_2) }, "", STR0449        } ) //"Valor Seguro"
AADD( TB_Cols, { {|| TRANSFORM(Int_DspHe->NDHSEGUTAX,cPict15_8) }, "", STR0450        } ) //"Taxa Seguro"
AADD( TB_Cols, { {|| TRANSFORM(Int_DspHe->NDHTX_USD,cPict15_8)  }, "", STR0451         } ) //"Taxa Dolar"
AADD( TB_Cols, { {|| Int_DspHe->NDHMASTER                  }, "", STR0452             } ) //"Master"
AADD( TB_Cols, { {|| Int_DspHe->NDHTIPODEC                 }, "", STR0453         } ) //"Tipo Decl."
AADD( TB_Cols, { {|| Int_DspHe->NDHURFDESP                 }, "", STR0454      } ) //"URF Despachos"
AADD( TB_Cols, { {|| Int_DspHe->NDHURFENTR                 }, "", STR0455        } ) //"URF Entrada"
AADD( TB_Cols, { {|| Int_DspHe->NDHRECALFA                 }, "", STR0456       } ) //"Recinto Alf."
AADD( TB_Cols, { {|| Int_DspHe->NDHMODALDE                 }, "", STR0457         } ) //"Modalidade"
AADD( TB_Cols, { {|| Int_DspHe->NDHTIPOCON                 }, "", STR0458       } ) //"Tipo Proces."
AADD( TB_Cols, { {|| Int_DspHe->NDHTIPODOC                 }, "", STR0459        } ) //"Tipo Docto."
AADD( TB_Cols, { {|| Int_DspHe->NDHUTILCON                 }, "", STR0460      } ) //"Util. Proces."
AADD( TB_Cols, { {|| Int_DspHe->NDHIDENTIF                 }, "", STR0461 } ) //"Identifica‡„o"
AADD( TB_Cols, { {|| TRANSFORM(Int_DspHe->NDHPESOBRU,cPict15_4) }, "", STR0329         } ) //"Peso Bruto"
AADD( TB_Cols, { {|| TRANSFORM(Int_DspHe->NDHFOB_TOT,cPict15_2) }, "", STR0462          } ) //"Total Fob"
AADD( TB_Cols, { {|| Int_DspHe->NDHFAT_DES                 }, "", STR0463 } ) //"Fatura Despachante"
AADD( TB_Cols, { {|| Int_DspHe->NDHNF_ENT                  }, "", STR0464         } ) //"Numero NFE"
AADD( TB_Cols, { {|| IN100CTD(Int_DspHe->NDHDT_NF,,"DDMMAAAA")}, "", STR0465           } ) //"Data NFE"     //MJB-SAP-1100
AADD( TB_Cols, { {|| TRANSFORM(Int_DspHe->NDHVL_NF,cPict15_2)   }, "", STR0466          } ) //"Valor NFE"
AADD( TB_Cols, { {|| IN100CTD(Int_DspHe->NDHDT_ENTR,,"DDMMAAAA")}, "", STR0467       } ) //"Data Entrega"   //MJB-SAP-1100
AADD( TB_Cols, { "NDHHAWB",,"Processo-EIC"})
IF lMV_GRCPNFE//Campo novo NFE - AWR 04/11/2008
   AADD( TB_Cols, { "NDHLOCALN" ,"",AVSX3("W6_LOCALN",5)})
   AADD( TB_Cols, { "NDHUFDESEM","",AVSX3("W6_UFDESEM",5)})
ENDIF
IF lTemObs
  AADD(TB_Cols,{ {|| Int_DspHe->NDH_OBS },"",STR0468  }) //"Observa‡Æo"
ENDIF

ASIZE(TB_Col_D,0)

AADD( TB_Col_D, { {|| Int_DspDe->NDDDESPESA               }, "", STR0469}) //"Despesa"
AADD( TB_Col_D, { {|| IN100CTD(Int_DspDe->NDDDPAGTO,,"DDMMAAAA") }, "", STR0470}) //"Pagto." //MJB-SAP-1100 
AADD( TB_Col_D, { {|| TRANSFORM(Int_DspDe->NDDVALOR,cPict15_2) }, "", STR0471}) //"Valor"
AADD( TB_Col_D, { {|| Int_DspDe->NDDEFEPREV               }, "", STR0037}) //"Tipo"
AADD( TB_Col_D, { {|| Int_DspDe->NDDPAGOPOR               }, "", STR0472}) //"Pagador"
IF lTemAdiant
   AADD(TB_Col_D,{ {|| Int_DspDe->NDDADIANTA },"","Adiantamento"  })
ENDIF
AADD( TB_Col_D, { {|| IN100E_MSG(.T.)                       }, "", STR0112 } ) //"Mensagem"

ASIZE(TBRCols,0)

AADD( TBRCols, { {|| Int_DspHe->(DbSeek(Int_DE->NDEHOUSE)),IN100Status(),IN100Status() }, STR0036             } ) //"Status"
AADD( TBRCols, { {|| Int_DspHe->NDHREFDESP                 }, STR0436 } ) //"Ref.Despachante"
AADD( TBRCols, { {|| Int_DspHe->NDHHOUSE                   }, STR0437 } ) //"Nr. Processo"
AADD( TBRCols, { {|| IN100CTD(Int_DspHe->NDHDCHEG,,"DDMMAAAA")}, STR0438 } ) //"Chegada" //MJB-SAP-1100 
AADD( TBRCols, { {|| IN100CTD(Int_DspHe->NDHDRECDOC,,"DDMMAAAA")  }, STR0439 } ) //"Rec.Doc." //MJB-SAP-1100 
AADD( TBRCols, { {|| Int_DspHe->NDHDESP                    }, STR0440 } ) //"Despachante"
AADD( TBRCols, { {|| Int_DspHe->NDHAGENTE                  }, STR0290 } ) //"Agente"
AADD( TBRCols, { {|| IN100CTD(Int_DspHe->NDHDPAGIMP,,"DDMMAAAA")  }, STR0441 } ) //"Pagto. Imp." //MJB-SAP-1100 
AADD( TBRCols, { {|| Int_DspHe->NDHDI_NUM                  }, STR0442 } ) //"Numero D.I."
//AADD( TBRCols, { {|| TRANSFORM(Int_DspHe->NDHTX_FOB,cPict15_8)  }, STR0443 } ) //"Taxa D.I."
AADD( TBRCols, { {|| IN100CTD(Int_DspHe->NDHDDESEMB,,"DDMMAAAA")  }, STR0444 } ) //"Desembaraco" //MJB-SAP-1100 
AADD( TBRCols, { {|| IN100CTD(Int_DspHe->NDHDT_ENTR,,"DDMMAAAA")}, STR0467 } ) //"Data Entrega" //MJB-SAP-1100 

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"COLDE")
ENDIF

AADD( TB_Cols, { {|| IN100E_Msg(.T.)                         }, "", STR0112           } ) // "Mensagem"

AADD( TBRCols, { {|| IN100E_Msg(.T.)                         }, STR0112           } ) // "Mensagem"

bMessage:=FIELDWBLOCK('NDHMSG',SELECT('Int_DspHe'))
bStatus :={|x| if(x=nil,Int_DspHe->NDHINT_OK="T",Int_DspHe->NDHINT_OK:=x)}
   
RETURN .T.

*------------------------------------------------------------------------------------------*
FUNCTION IN100LerDE()
*------------------------------------------------------------------------------------------*
LOCAL bSave1:=bMessage, nRec, nOldArea:=Select(), nStru, nR, cTexto, nInicio, nRecDe, lTemMoeda:=.F.
LOCAL bSave2:=bStatus,nPos

cErro:=cAviso:=NIL   // limpa mensagens geradas para o Int_DE

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"LERDE")
ENDIF

cErro:=cAviso:=NIL   // limpa mensagens geradas para o Int_DspHe

DbSelectArea("Int_DspDe")
IF Int_DspDe->(DBSEEK(Int_DspHe->NDHHOUSE))

 do while !Int_DspDe->(EOF()) .AND. Int_DspDe->NDDHOUSE == Int_DspHe->NDHHOUSE
   Int_DspDe->NDDMSG:="" 
 
   bMessage:=FIELDWBLOCK('NDDMSG',SELECT('Int_DspDe'))
   bStatus :={|x| if(x=nil,Int_DspDe->NDDINT_OK="T",Int_DspDe->NDDINT_OK:=x)}
   
   //RRV - 29/10/2012 - Define default se informação estiver em branco (Default = Pago pelo Despachante)
   If Empty(Int_DspDe->NDDPAGOPOR)
      Int_DspDe->NDDPAGOPOR := "1"
   EndIf   
   
   IN100VerDD()
   
   IN100VerErro(cErro,cAviso)
   cErro:=cAviso:=NIL  //ASK 20/03/07 Limpa mensagens geradas para o Int_DspDe
  Int_DspDe->(DBSKIP())
  ENDDO
Endif                                                              

DbSelectArea("Int_DspHe")
Int_DspHe->NDHMSG:=""
cErro:=cAviso:=NIL   // limpa mensagens geradas para o Int_DspHe

bMessage:=FIELDWBLOCK('NDHMSG',SELECT('Int_DspHe'))
bStatus :={|x| if(x=nil,Int_DspHe->NDHINT_OK="T",Int_DspHe->NDHINT_OK:=x)}

IN100VerDH()   
If Int_DspDe->(DbSeek(Int_DspHe->NDHHOUSE))
  DO WHILE Int_DspDe->(!EOF()) .AND. ALLTRIM(Int_DspHe->NDHHOUSE) == ALLTRIM(Int_DspDe->NDDHOUSE)
    IF Int_DspDe->NDDINT_OK = "F"
      EVAL(bMsg,"..."+Capital(STR0262)+" "+STR0280)//"VIDE " "Despesas Despachante"
      EXIT
    ENDIF
    Int_DspDe->(DBSKIP())
 ENDDO
ENDIF
IN100VerErro(cErro,cAviso)

   IF Int_DspHe->NDHINT_OK = "T"
      nResumoCer+=1
   ELSE
      nResumoErr+=1
   ENDIF

   
DbSelectArea("Int_DspTX")

cErro:=cAviso:=NIL   // limpa mensagens geradas para o Int_DspHe
IF   Int_DspTX->(DBSEEK(Int_DspHe->NDHHOUSE))
  
  Do WHILE ! Int_DspTX->(EOF()) .AND. Int_DspHe->NDHHOUSE  == Int_DspTX->NTXHOUSE
   Int_DspTx->NTXMSG :="" 

   bMessage:=FIELDWBLOCK('NTXMSG',SELECT('Int_DspTx'))
   bStatus :={|x| if(x=nil,Int_DspTx->NTXINT_OK="T",Int_DspTx->NTXINT_OK:=x)}

//-------------------------------- Validacao
   IF EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"LERTX")
   ENDIF

   SW9->(DBSETORDER(3)) 
   SYF->(DbSetOrder(3))

   If Int_DspTx->NTXTAXA <= 0
      EVAL(bMsg,"Taxa Invalida.")
   Endif

   If !SYF->(DbSeek(cFilSYF+Int_DspTx->NTXMOEDA))

      EVAL(bMsg,"Moeda nao cadastrada.")

   ELSEIF SW9->(DBSEEK(cFilSW9+RTRIM(Int_DspHe->NDHHAWB)))
/*      IF ASCAN(aMoeProcTx,Int_DspTx->NTXHAWB+Int_DspTx->NTXMOEDA) = 0
         AADD(aMoeProcTx,Int_DspTx->NTXHAWB+Int_DspTx->NTXMOEDA)*/	//ASR 01/12/2005
      IF (nPosMoe := ASCAN(aMoeProcTx,Int_DspHe->NDHHAWB+Int_DspTx->NTXMOEDA)) == 0
         AADD(aMoeProcTx,Int_DspHe->NDHHAWB+Int_DspTx->NTXMOEDA)
      ELSE
         //EVAL(bMsg,"Moeda Duplicada.")
      ENDIF
      Int_DspTx->NTXINT_OK := "T"
      lTemMoeda:=.F.  
      
      If Int_DspTx->NTXMOEDA <> "790" //CCH - 02/07/2008 - Tratamento para a moeda 790 (R$) na integração de despesas do Despachante
                                                       //- Caso a moeda enviada na integração seja 790, não efetua a validação da mesma no processo
      
         SYF->(DbSetOrder(1))
         DO WHILE SW9->(!EOF()) .AND. SW9->W9_FILIAL == cFilSW9 .AND.;
                   RTRIM(SW9->W9_HAWB)  == RTRIM(Int_DspHe->NDHHAWB)
            IF SYF->(DbSeek(cFilSYF+SW9->W9_MOE_FOB)) .AND.;
               SYF->YF_COD_GI == Int_DspTx->NTXMOEDA
               lTemMoeda:=.T.
               EXIT
            ENDIF 
            SW9->(DBSKIP())
         ENDDO

         IF !EMPTY(Int_DspHe->NDHFRETMOE)  .AND. Int_DspTx->NTXMOEDA == Int_DspHe->NDHFRETMOE
            lTemMoeda := .T.
         ENDIF

         IF !EMPTY(Int_DspHe->NDHSEGUMOE)  .AND. Int_DspTx->NTXMOEDA == Int_DspHe->NDHSEGUMOE
            lTemMoeda := .T.
         ENDIF

         //IF !lTemMoeda
         //   EVAL(bMsg,"Processo nao possui essa Moeda : " + Int_DspTx->NTXMOEDA)  //Bloco retirado, 
         //ENDIF                                                                    //pois ao integrar um arquivo TXT do Despachante na fase de DI
                                                                                    //o sistemas apresentava rejeição da taxa da moeda, impedindo a integração.
      Endif
   EndIf

   IF EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"VALTX")
   Endif                
    IN100VerErro(cErro,cAviso)

   Int_DspTX->(DBSKIP())
ENDDO    
//------------------------------- Validacao


   If cErro # NIL
         IF Int_DspHe->NDHINT_OK = "T"
            nResumoCer-=1
            nResumoErr+=1
            Int_DspHe->NDHINT_OK:="F"
         ENDIF
         cMenErroTx:="..."+Capital(STR0262)+" Taxas"// "VIDE"
         IF AT(cMenErroTx,Int_DspHe->NDHMSG) = 0
            IF AT(STR0100,Int_DspHe->NDHMSG) = 0//'*** ERRO(S):'
               Int_DspHe->NDHMSG:=STR0100+NewLine+NewLine+cMenErroTx+;
                                          NewLine+NewLine+ALLTRIM(Int_DspHe->NDHMSG)//'*** ERRO(S):'
            ELSE
               IF (nPos:=AT(NewLine+NewLine+STR0101,Int_DspHe->NDHMSG)) # 0//'*** AVISO(S):'
                  Int_DspHe->NDHMSG:=STUFF(Int_DspHe->NDHMSG,nPos,0,cMenErroTx)
               ELSE
                  Int_DspHe->NDHMSG:=RTRIM(Int_DspHe->NDHMSG)+cMenErroTx
               ENDIF
            ENDIF
         ENDIF
   Endif

Endif

//********************************************** AWR 23/04/2003
bMessage:=bSave1
bStatus :=bSave2
DbSelectArea(nOldArea)

//RETURN .T.
Return Int_DspHe->NDHINT_OK // BAK - alteração para nova integração com despachante
*------------------------------------------------------------------------------------------*
FUNCTION IN100GrvDE()
*------------------------------------------------------------------------------------------*
LOCAL cAlias, nAlias, cPref, scAlias, nc:=0
LOCAL lTemOBs    := IF(Int_DspHe->(FIELDPOS("NDH_OBS")) # 0,.T.,.F.)
LOCAL lTemAdiant := IF(Int_DspDe->(FIELDPOS("NDDADIANTA")) # 0,.T.,.F.)
Local cDesp := "", lGrv := .F. //JVR - 18/11/09
Local i                        //NCF - 04/10/2011
Local lRetBlock                //RRV - 30/08/2012 - Trata o retorno do ponto de entrada.
Local lAlt:= .F.  
Local cDescDesp := ""  
Local cDescForn:= ""
Local cMoeda:= "" 
Local lGerTIT:=EasyGParam("MV_EIC0020",,.F.) //LRS - 14/08/2018
Local lNaoGrava:= .F.
Local lAcerta:= .F.
Local lAchouDesp := .F., lLinha := .F. //LGS - 08/04/2014
Local nRecSW6Old := SW6->(Recno())
Local lDespInteg
Private lDeletaSWD := .T., nTotalDesp := 0, nFOB_TOT := 0	//ASR 18/11/05
PRIVATE nFreteDesp:=0,nFobDesp:=0,lTemDDI:=.T., lTemDDP:=.T.,nSegDesp:=0
PRIVATE cAdiantafob:= cadiantafrete := cadiantaseg := "2"
PRIVATE cpagoporfob:= cpagoporfrete := cpagoporseg := "2"
PRIVATE lMV_EASY_SIM:=EasyGParam("MV_EASY") $ cSim
PRIVATE lMV_EASYFIN :=EasyGParam("MV_EASYFIN") $ cSim
PRIVATE nDespCount,nDespValor
PRIVATE aOrdSWD := {}

Private lAltFrete := .F.
private lAltSeguro:= .F.

If lMV_EASYFIN .And. IsBlind()
   lMV_EASYFIN := .F. //THTS - 26/04/2021 - Caso esteja sendo executada a integração de despesa via job, não deve ser efetuada a integração com o financeiro, pois é necessária interação via tela.
EndIf


dDtEmis := EasyGParam("MV_DTEMIS",,"SW9->W9_DT_EMIS")
Int_DspDe->(DbSeek(Int_Dsphe->NDHHOUSE))

//LGS-08/04/2014 - Chamada da função que identifica a linha da despesa
If SWD->(FieldPos("WD_LINHA"))>0
	While Int_DspDe->(!Eof())
		DSPDELin(Int_DspDe->NDDHOUSE,Int_DspDe->NDDDESPESA)
	    Int_DspDe->(DbSkip())
	EndDo
	lLinha := .T.
	Int_DspDe->(DbGoTop())
EndIf

SW6->( DbSetOrder( 9 ) )
SW6->(DbSeek(cFilSW6+Int_DspHe->NDHREFDESP))
//NCF - 11/11/2016 - Verificação condicionada ao tamanho do campo e uso da tabela DE/PARA 
If Len(Int_DspHe->NDHDESP) <> AVSX3("W6_DESP",AV_TAMANHO)
   aDspch := GetDpTabDP(Int_DspHe->NDHDESP,Int_DspHe->NDHREFDESP)
   If Len(aDspch) == 1
         SW6->(DbGoTo(aDspch[1][2]))
   Else
      If SW6->(Eof())
         SW6->(DbGoto(nRecSW6Old)) 
      EndIf
   EndIf
Else                                                         //MJB-SAP-0401
   Do While !SW6->(EOF()) .and. Int_DspHe->NDHREFDESP == SW6->W6_REF_DES .and. Int_DspHe->NDHDESP <> SW6->W6_DESP
      SW6->(dbSkip())
   EndDo
EndIf
SW6->( DbSetOrder( 1 ) )
SW6->(DBSEEK(cFilSW6+RTRIM(Int_DspHe->NDHHAWB))) //LRS -13/07/2017

aMemo:= {}

scAlias:=If(Empty(ALIAS()),"SWD",Alias())
Reclock("SW6",.F.)
DBSELECTAREA(scAlias)

SW6->W6_CHEG     := IN100CTD(Int_DspHe->NDHDCHEG,,"DDMMAAAA")             //MJB-SAP-1100

SW6->W6_DTRECDOC := IN100CTD(Int_DspHe->NDHDRECDOC,,"DDMMAAAA")           //MJB-SAP-1100

SYF->( DbSetOrder( 3 ) )

SW6->W6_DESP     := If(!Empty(Int_DspHe->NDHDESP) .And. Len(Int_DspHe->NDHDESP) == AVSX3("W6_DESP",AV_TAMANHO),Int_DspHe->NDHDESP,SW6->W6_DESP)
SW6->W6_AGENTE   := If(!Empty(Int_DspHe->NDHAGENTE),Int_DspHe->NDHAGENTE,SW6->W6_AGENTE)
If(!Empty(Int_DspHe->NDHDPAGIMP),If(CTOD(Int_DspHe->NDHDPAGIMP) > SW6->W6_DT_DESE, ,SW6->W6_DT       := IN100CTD(Int_DspHe->NDHDPAGIMP,,"DDMMAAAA")),)           //MJB-SAP-1100
If(!Empty(Int_DspHe->NDHDPAGIMP),SW6->W6_DTREG_D  := IN100CTD(Int_DspHe->NDHDPAGIMP,,"DDMMAAAA"),)           //MJB-SAP-1100
SW6->W6_DI_NUM   := If(!Empty(Int_DspHe->NDHDI_NUM),Int_DspHe->NDHDI_NUM,SW6->W6_DI_NUM)
SW6->W6_DT_DESE  := if(!Empty(Int_DspHe->NDHDDESEMB),IN100CTD(Int_DspHe->NDHDDESEMB,,"DDMMAAAA"),SW6->W6_DT_DESE)           //MJB-SAP-1100

//Acerto da Taxa de Frete - MPG - OSSME-4645 - 12/05/2020
If(!Empty(Int_DspHe->NDHFRETMOE),SW6->W6_FREMOED  := (SYF->(DbSeek(cFilSYF+Int_DspHe->NDHFRETMOE)),SYF->YF_MOEDA),)
If ! Empty(Int_DspHe->NDHFRETTAX)
   lAltFrete := SW6->W6_TX_FRET <> Int_DspHe->NDHFRETTAX
   SW6->W6_TX_FRET  := Int_DspHe->NDHFRETTAX
endif
If ! Empty(Int_DspHe->NDHVLFRECC)
   if ! lAltFrete
      lAltFrete := SW6->W6_VLFRECC <> Int_DspHe->NDHVLFRECC
   endif
   SW6->W6_VLFRECC  := Int_DspHe->NDHVLFRECC
endif
If ! Empty(Int_DspHe->NDHVLFRETN)
   SW6->W6_VLFRETN  := Int_DspHe->NDHVLFRETN
endif
If ! Empty(Int_DspHe->NDHFRETVAL)
   SW6->W6_VLFREPP  := Int_DspHe->NDHFRETVAL
endif

//Acerto da Taxa de Seguro - MPG - OSSME-4645 - 12/05/2020
If(!Empty(Int_DspHe->NDHSEGUMOE),SW6->W6_SEGMOED  := (SYF->(DbSeek(cFilSYF+Int_DspHe->NDHSEGUMOE)),SYF->YF_MOEDA),)
If ! Empty(Int_DspHe->NDHSEGUTAX)
   lAltSeguro := SW6->W6_TX_SEG <> Int_DspHe->NDHSEGUTAX
   SW6->W6_TX_SEG   := Int_DspHe->NDHSEGUTAX
endif
If ! Empty(Int_DspHe->NDHSEGUVAL)
   if ! lAltSeguro
      lAltSeguro := SW6->W6_VL_USSE <> Int_DspHe->NDHSEGUVAL
   endif
   SW6->W6_VL_USSE  := Int_DspHe->NDHSEGUVAL
endif
SW6->W6_VLSEGMN  := (SW6->W6_VL_USSE*SW6->W6_TX_SEG)

If ! Empty(Int_DspHe->NDHTX_USD)
   SW6->W6_TX_US_D  := Int_DspHe->NDHTX_USD 
endif

SW6->W6_MAWB     := Int_DspHe->NDHMASTER
SW6->W6_TIPODES  := IF(!EMPTY(Int_DspHe->NDHTIPODEC),STRZERO(Int_DspHe->NDHTIPODEC,2,0),"  ")   //TRP - 13/07/10 - Acerto na gravacão do campo Tipo Declaracão.
SW6->W6_URF_DES  := Strzero(Int_DspHe->NDHURFDESP,7,0)
SW6->W6_URF_ENT  := Strzero(Int_DspHe->NDHURFENTR,7,0)
SW6->W6_REC_ALF  := Int_DspHe->NDHRECALFA
SW6->W6_MODAL_D  := IF(VAL(Int_DspHe->NDHMODALDE)=0,'1',Int_DspHe->NDHMODALDE)
SW6->W6_TIPOCON  := STRZERO(Val(Int_DspHe->NDHTIPOCON),2,0)
SW6->W6_TIPODOC  := ALLTRIM(Int_DspHe->NDHTIPODOC)
SW6->W6_UTILCON  := Int_DspHe->NDHUTILCON
SW6->W6_IDEMANI  := Int_DspHe->NDHIDENTIF
SW6->W6_PESO_BR  := Int_DspHe->NDHPESOBRU
SW6->W6_FAT_DES  := Int_DspHe->NDHFAT_DES
cDataDI  := IN100CTD(Int_DspHe->NDHDTREGDI,,"DDMMAAAA")
If(!Empty(cDataDI)              ,SW6->W6_DTREG_D  := cDataDI,)
IF(!EMPTY(Int_DspHe->NDHVL_NF  ),SW6->W6_VL_NF    := Int_DspHe->NDHVL_NF,)
IF(!EMPTY(Int_DspHe->NDHDT_ENTR),SW6->W6_DT_ENTR  := IN100CTD(Int_DspHe->NDHDT_ENTR,,"DDMMAAAA"),)           //MJB-SAP-1100
IF(!EMPTY(Int_DspHe->NDHNF_ENT ),SW6->W6_NF_ENT   := alltrim(Int_DspHe->NDHNF_ENT),)
IF(!EMPTY(Int_DspHe->NDHDT_NF  ),SW6->W6_DT_NF    := IN100CTD(Int_DspHe->NDHDT_NF,,"DDMMAAAA"),)             //MJB-SAP-1100
IF lMV_GRCPNFE//Campos novos NFE - AWR 05/11/2008
   If EasyGParam("MV_EIC0031",,.F.)  // GFP - 08/08/2013 
      IF(!EMPTY(Int_DspHe->NDHLOCALN) ,SW6->W6_LOCALN :=Int_DspHe->NDHLOCALN ,)
   EndIf
   IF(!EMPTY(Int_DspHe->NDHUFDESEM),SW6->W6_UFDESEM:=Int_DspHe->NDHUFDESEM,)
ENDIF

//TRP - 31/08/2012 - Gravar os dados da DI na capa do Câmbio.
IF !EMPTY(Int_DspHe->NDHDI_NUM)   
   SWA->(DbSetOrder(1))
   IF SWA->(DbSeek(xFilial("SWA")+ SW6->W6_HAWB))
      SWA->(Reclock("SWA",.F.))
      SWA->WA_DI_NUM:= Int_DspHe->NDHDI_NUM
      SWA->(MsUnlock())
   ENDIF  
ENDIF
   
IF !EMPTY(cDataDI)  
   SWA->(DbSetOrder(1))
   IF SWA->(DbSeek(xFilial("SWA")+ SW6->W6_HAWB))
      SWA->(Reclock("SWA",.F.))
      SWA->WA_DTREG_D:= cDataDI
      SWA->(MsUnlock())
   ENDIF  
ENDIF
   
IF EasyEntryPoint("IC086IN1")
  ExecBlock("IC086IN1",.F.,.F.,2)
ENDIF
IF lTemObs
  IF !EMPTY (SW6->W6_OBS) .AND. ! EMPTY(Int_DspHe->NDH_OBS)
    MSMM(SW6->W6_OBS,,,,2)
  ENDIF
  IF !EMPTY(Int_DspHe->NDH_OBS)
     MSMM(,TAMSX3("W6_VM_OBS")[1],,Int_DspHe->NDH_OBS,1,,,"SW6","W6_OBS")
  ENDIF
ENDIF
IF EasyEntryPoint("IN100CLI")
  ExecBlock("IN100CLI",.F.,.F.,"INT_DESP_GRAVA_SW6")
ENDIF

SYF->( DbSetOrder( 1 ) )

If Type("bUpDate") <> "B"
   bUpDate:= Nil
EndIf

///*************************** AWR 23/04/2003
IF Int_DspTx->(DbSeek(Int_DspHe->NDHHOUSE))
   SW9->(DBSETORDER(3))
   SYF->(DbSetOrder(1))
ENDIF
aAltInvoice := {}
DO While Int_DspTx->(!Eof()) .And. Int_DspTx->NTXHOUSE = Int_DspHe->NDHHOUSE
   IF Int_DspTx->NTXINT_OK # "T"
      Int_DspTx->(DbSkip())
      LOOP
   ENDIF
   If SW9->(DBSEEK(cFilSW9+RTRIM(Int_DspHe->NDHHAWB)))
      DO WHILE SW9->(!EOF()) .AND. SW9->W9_FILIAL == cFilSW9 .AND.;
                             RTRIM(SW9->W9_HAWB)  == RTRIM(Int_DspHe->NDHHAWB)
         IF SYF->(DbSeek(cFilSYF+SW9->W9_MOE_FOB)) .AND. SYF->YF_COD_GI == Int_DspTx->NTXMOEDA
            // EOB - 18/07/08 - Verifica se for integrado com o Financeiro e se a taxa integrada é diferente da invoice
            IF lMV_EASYFIN .AND.  cPaisLoc = "BRA" .AND. SW9->W9_TX_FOB <> Int_DspTx->NTXTAXA .AND. !lGerTIT //LRS - 15/08/2018
               AADD(aAltInvoice, {SW9->W9_HAWB, SW9->W9_INVOICE, SW9->W9_FORN })
            ENDIF
            SW9->(RECLOCK("SW9",.F.))
            SW9->W9_TX_FOB := Int_DspTx->NTXTAXA
            SW9->(MSUNLOCK())
            nFOB_TOT += SW9->W9_TX_FOB * SW9->W9_FOB_TOT	//ASR 01/12/2005
         ENDIF 
         SW9->(DBSKIP())
      ENDDO
   Endif
   If SW6->(DBSEEK(cFilSW6+RTRIM(Int_DspHe->NDHHAWB)))
     SW6->(RECLOCK("SW6",.F.))
      SW6->W6_FOB_TOT := nFOB_TOT	//ASR 01/12/2005
     IF SYF->(DbSeek(cFilSYF+SW6->W6_FREMOED)) .AND.;
       SYF->YF_COD_GI == Int_DspTx->NTXMOEDA
       SW6->W6_TX_FRET := Int_DspTx->NTXTAXA
     ENDIF
     IF SYF->(DbSeek(cFilSYF+SW6->W6_SEGMOED)) .AND.;
       SYF->YF_COD_GI == Int_DspTx->NTXMOEDA
       SW6->W6_TX_SEG := Int_DspTx->NTXTAXA
     ENDIF
     SW6->(MSUNLOCK())
   ENDIF
   //IAC 23/12/2010
   if valtype(bUpDate)=="B"
      oldcfuncao:=cfuncao
      cfuncao   :="TX"
      If FindFunction("AvIntExtra")
         EasyExRdm("AvIntExtra")
      EndIf
      cfuncao   :=oldcfuncao
   endif

   Int_DspTx->(DbSkip())
ENDDO

SW9->(dbSetOrder(1))                                   
lExisCpoSWB:= SWB->(FIELDPOS("WB_LOJA" )) # 0 .AND. SWB->(FIELDPOS("WB_TIPOTIT")) # 0 .AND. SWB->(FIELDPOS("WB_PREFIXO")) # 0 
SWB->(dbSetOrder(1))
cFilSWB := xFilial("SWB")
FOR nc:=1 TO LEN(aAltInvoice)
   SWB->(dbSeek(cFilSWB+aAltInvoice[nc,1]+"D"+aAltInvoice[nc,2]+aAltInvoice[nc,3]))
   DO While SWB->(!Eof()) .AND. SWB->WB_FILIAL == cFilSWB .AND. SWB->WB_HAWB == aAltInvoice[nc,1] .AND. SWB->WB_PO_DI == "D";
                          .AND. SWB->WB_INVOICE == aAltInvoice[nc,2] .AND. SWB->WB_FORN == aAltInvoice[nc,3] 
      // EOB - 18/07/08 - Verifica se existe o título gerado para a parcela de câmbio da invoice 
      IF  lExisCpoSWB .AND. !EMPTY(SWB->WB_PREFIXO+SWB->WB_NUMDUP+SWB->WB_PARCELA+SWB->WB_TIPOTIT)
          lBaixa:=IsBxE2Eic(SWB->WB_PREFIXO,SWB->WB_NUMDUP,SWB->WB_TIPOTIT,SWB->WB_FORN,SWB->WB_LOJA)        
          // EOB - 18/07/08 - Se o título não estiver baixado, deleta e gera novamente.
          INCLUI := ALTERA := .F.
          IF !lBaixa .AND. FI400TITFIN("SWB_INT","4",.T.)
             //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
             SW9->(dbSeek(cFilSW9+SWB->WB_INVOICE+SWB->WB_FORN+EICRetLoja("SWB", "WB_LOJA")+SWB->WB_HAWB))
             cPrefixo  := SWB->WB_PREFIXO             //M->E2_PREFIXO
             cIniDocto := SWB->WB_NUMDUP              //M->E2_NUM
             cTIPO_Tit := SWB->WB_TIPOTIT             //M->E2_TIPO
             cCodFor   := SWB->WB_FORN                //M->E2_FORNECE
             cLojaFor  := SWB->WB_LOJA                //M->E2_LOJA
             cParcela  := SWB->WB_PARCELA             //M->E2_PARCELA
             nMoedSubs := SimbToMoeda(SWB->WB_MOEDA)  //M->E2_MOEDA
             nValorS   := SWB->WB_FOBMOE              //M->E2_VALOR
             cEMISSAO  := &(dDtEmis)                  //M->E2_EMISSAO
             cDtVecto  := SWB->WB_DT_VEN              //M->E2_VENCTO
             IF cEMISSAO > cDtVecto
                cEMISSAO:=cDtVecto                    //M->E2_EMISSAO - Atencao: a data de emissao nao pode ser maior que a de vencimento
             ENDIF
             nTxMoeda  := SW9->W9_TX_FOB              //M->E2_TXMOEDA
             cHistorico:= "P: "+ALLTRIM(SWB->WB_HAWB)+" I: "+ALLTRIM(SWB->WB_INVOICE)//M->E2_HIST
          
          INCLUI := .T.
			 FI400TITFIN("SWB_INT","2")// Inclusao 
          ENDIF          
      ENDIF
      SWB->(dbSkip())
   ENDDO
NEXT

///*************************** AWR 23/04/2003
DBSELECTAREA("SWD")//AWR - Preciso ter certeza que o arquivo esta aberto se na a funcao SELECT("SWD") devolve 0
SWD->(DbSetOrder(1))//AWR - 20/04/2010
Int_DspDe->(DbSeek(Int_DspHe->NDHHOUSE))

nDespesas := 0

//TRP-05/11/12
If AvFlags("AVINT_FINANCEIRO_EIC")
   AADD(aMemo,{"Despesas Integradas:",.T.})
   AADD(aMemo,{"---------------------------------------------------------------------------",.T.})
   AADD(aMemo,{"Processo:" + Alltrim(SW6->W6_HAWB),.T.})
   AADD(aMemo,{CHR(13)+CHR(10),.T.})
Endif


While Int_DspDe->(!Eof()) .And. Int_DspDe->NDDHOUSE == Int_DspHe->NDHHOUSE

   //AJP 19/06/06 Executar um Ponto de Entrada antes de efetuar a gravação das despesas
   If EasyEntryPoint("IN100CLI")
      If ValType(lRetBlock := ExecBlock("IN100CLI",.F.,.F.,"INT_DESP_ANTES_SWD")) == "L" .And. !lRetBlock //RRV - 30/08/2012 - Trata o retorno do ponto de entrada.\
         Loop
      EndIf
   EndIf
   //FIM AJP 19/06/06

   If Int_DspDe->NDDDESPESA $ "101.102.103"
      If Int_DspDe->NDDDESPESA = "101"
         nFobDesp  := Int_DspDe->NDDVALOR
         IF lTemAdiant
            cAdiantafob := IF(Int_DspDe->NDDADIANTA $ cSim,"1","2")
            cPagoPorfob := Int_DspDe->NDDPAGOPOR
         ENDIF
      ElseIf Int_DspDe->NDDDESPESA = "102"
         IF lTemAdiant
            cAdiantafrete := IF(Int_DspDe->NDDADIANTA $ cSim,"1","2")
            cPagoPorfrete := Int_DspDe->NDDPAGOPOR
         Endif
         nFreteDesp:= Int_DspDe->NDDVALOR
      ElseIf Int_DspDe->NDDDESPESA = "103"
         IF lTemAdiant
            cAdiantaseg := IF(Int_DspDe->NDDADIANTA $ cSim,"1","2")
            cPagoPorseg := Int_DspDe->NDDPAGOPOR 
         ENDIF
         nSegDesp  := Int_DspDe->NDDVALOR
      EndIf
        
      IF EasyEntryPoint("IN100CLI")
         ExecBlock("IN100CLI",.F.,.F.,"GRVDESP_CIF")
  	  ENDIF
  		
      Int_DspDe->(DbSkip())       
      Loop
   EndIf

   cAlias := "SWD"
   nAlias := Select("SWD")
   cPref  := "WD_"
   scAlias := ALIAS()

   If lTemDDI
      lTemDDI := .F.
      //Deleta as Despesas
//    (cAlias)->(DBGoTop())//AWR - 20/04/2010
      SWD->(DbSeek(xFilial()+SW6->W6_HAWB))
      While (cAlias)->(!Eof()) .AND. (cAlias)->(FieldGet(FieldPos(cPref+"FILIAL"))) == xFilial(cAlias) .AND.;
            (cAlias)->(FieldGet(FieldPos(cPref+"HAWB"))) == SW6->W6_HAWB
 
         //TRP-05/11/12        
         If AvFlags("AVINT_FINANCEIRO_EIC") 
            lDeletaSWD := .F.
         Endif
         
         IF(EasyEntryPoint("IN100CLI"),ExecBlock("IN100CLI",.F.,.F.,"DELDESP"),)
         If lDeletaSWD//ASR 19/11/2005 - Variavel para o ponto de entrada
            If (cAlias)->(FieldGet(FieldPos(cPref+"FILIAL"))) == xFilial(cAlias) .AND.;
               (cAlias)->(FieldGet(FieldPos(cPref+"HAWB"))) == SW6->W6_HAWB .AND.;     //Se a despesa foi 
               (cAlias)->(FieldGet(FieldPos(cPref+"INTEGRA"))) .AND.;                  //integrada e não   
               Empty((cAlias)->(FieldGet(FieldPos(cPref+"NF_COMP")))) .AND.;           //tem nota fiscal
               Empty((cAlias)->(FieldGet(FieldPos(cPref+"SE_NFC"))))                   // apaga a despesa
               lDelDesp := .T.
               // EOB - 16/07/08 - Se tiver integração com o Financeiro e existir o título gerado, tenta deletar o título. Se obter sucesso, deleta a despesa também.
               INCLUI := ALTERA := .F.
               IF lMV_EASYFIN .AND.  cPaisLoc = "BRA" .AND. !EMPTY(SWD->(WD_PREFIXO+WD_CTRFIN1+WD_PARCELA+WD_TIPO))/*+WD_FORN+WD_LOJA))*/ //LRS - 07/11/2017
                  lDelDesp := FI400TITFIN("SWD_INT","4",.T.)        // Exclusao 
               ENDIF
               IF lDelDesp
                  Reclock(cAlias,.F.)
                  (cAlias)->(DbDelete())
                  (cAlias)->(MsUnlock())
               ENDIF
            EndIf
         EndIf
         (cAlias)->(DbSkip())
      EndDo
   EndIf
   //JVR - 18/11/09            
   cDesp := EasyGParam("MV_D_II"  ,,"201") + "/"
   cDesp += EasyGParam("MV_D_IPI" ,,"202") + "/"
   cDesp += EasyGParam("MV_D_ICMS",,"203") + "/"
   cDesp += EasyGParam("MV_D_PIS" ,,"204") + "/"
   cDesp += EasyGParam("MV_D_COF" ,,"205") + "/"                           

   lGrv     := .F.
   lSobrepor:= .F.//AWR - 20/04/2010

   If Int_DspDe->NDDDESPESA $ cDesp//Verifica se é imposto.
      If IN100VALDESP(Int_DspDe->NDDDESPESA)//Valida se foi inclusão automatica. ("T" quando DI Eletronica e Despesa lançada automaticamente na tabela EII com o codigo do debito)
         (cAlias)->(DbSetOrder(1))
         If (cAlias)->(DbSeek(xFilial()+SW6->W6_HAWB+Int_DspDe->NDDDESPESA))
            //NCF - 04/10/2011 - Apagar todas as despesas adiantadas referentes à despesa efetiva  
            Do While (cAlias)->(!EOF()) .And. (cAlias)->WD_DESPESA == Int_DspDe->NDDDESPESA 
               Reclock(cAlias,.F.)
               (cAlias)->(DbDelete())
               (cAlias)->(MsUnlock())
               (cAlias)->(DbSkip())             
            EndDo
         EndIf
         lGrv := .T.
      Else//se inclusão aut. falsa. Faz pergunta.
         SWD->(DbSetOrder(1))
         If SWD->(DbSeek(xFilial()+SW6->W6_HAWB+Int_DspDe->NDDDESPESA))
            
            //TRP - 03/10/2012 - Cenário AvInteg
            If AvFlags("AVINT_FINANCEIRO_EIC") 
             
               cDescDesp:= ""
              
               SYB->(DbSetOrder(1))
      		   If SYB->(DbSeek(xFilial("SYB")+Int_DspDe->NDDDESPESA))
                  cDescDesp:= Left(SYB->YB_DESCR,LEN(SYB->YB_DESCR))
                  cMoeda:= Left(SYB->YB_MOEDA,LEN(SYB->YB_MOEDA))   
               Endif
               
               SA2->(DbSetOrder(1))
               If SA2->(DBSEEK(cFilSA2+SWD->WD_FORN+SWD->WD_LOJA))
                  cDescForn:= SA2->A2_NREDUZ
               Endif
               
               lNaoGrava:= .F.
               lAcerta := .F.
               aOrdAuxSWD:= SaveOrd({"SWD"})
               //Verifica se os dados chave são exatamente iguais
               DO While SWD->(!Eof()) .AND. cFilSWD == SWD->WD_FILIAL .AND.;
                  SWD->WD_HAWB == SW6->W6_HAWB .AND. SWD->WD_DESPESA == Int_DspDe->NDDDESPESA 
                  
                  If (SWD->WD_DESPESA == Int_DspDe->NDDDESPESA  .AND. SWD->WD_DES_ADI == IN100CTD(Int_DspDe->NDDDPAGTO,,"DDMMAAAA") .AND. SWD->WD_VALOR_R == Int_DspDe->NDDVALOR)
                     lNaoGrava:= .T.
                     EXIT 
                  ElseIf SWD->WD_DESPESA == Int_DspDe->NDDDESPESA  .AND. SWD->WD_DES_ADI == IN100CTD(Int_DspDe->NDDDPAGTO,,"DDMMAAAA") .AND. SWD->WD_VALOR_R <> 0 .AND. !Empty(SWD->WD_CTRLERP)
                     lNaoGrava:= .T.
                     AADD(aMemo,{Int_DspDe->NDDDESPESA + Space(1) + cDescDesp  + Space(2) +  cMoeda + Space(1) + TRANSFORM(Int_DspDe->NDDVALOR,cPict17_2)  + Space(4) + DTOC(IN100CTD(Int_DspDe->NDDDPAGTO,,'DDMMAAAA'))   ,.T.})
                     AADD(aMemo,{"Integração da Despesa "+ Int_DspDe->NDDDESPESA + " ignorada, pois já foi enviada ao ERP.",.T.})
                     AADD(aMemo,{"Aguardar o retorno do título do ERP e reprocessar o arquivo.",.T.})
                     AADD(aMemo,{CHR(13)+CHR(10),.T.})
                     AADD(aMemo,{CHR(13)+CHR(10),.T.})
                     cMemo:= "Despesas Integradas:"
                     EXIT
                  ElseIf SWD->WD_DESPESA == Int_DspDe->NDDDESPESA  .AND. SWD->WD_DES_ADI == IN100CTD(Int_DspDe->NDDDPAGTO,,"DDMMAAAA") .AND. SWD->WD_VALOR_R <> Int_DspDe->NDDVALOR .AND. Empty(SWD->WD_TITERP)
                     lAcerta:= .T.
                     EXIT   
                  ElseIf SWD->WD_DESPESA == Int_DspDe->NDDDESPESA  .AND. SWD->WD_DES_ADI == IN100CTD(Int_DspDe->NDDDPAGTO,,"DDMMAAAA") .AND. SWD->WD_VALOR_R <> Int_DspDe->NDDVALOR .AND. !Empty(SWD->WD_TITERP)
                     If MSGYESNO("Despesa Existente"+CHR(13)+CHR(10)+;
                                 "-----------------------------------"+CHR(13)+CHR(10)+;
                     		     "Despesa: "+Int_DspDe->NDDDESPESA+" - "+ cDescDesp +CHR(13)+CHR(10)+;
                                 "Data: "+DTOC(SWD->WD_DES_ADI)+CHR(13)+CHR(10)+;
                                 "Valor : "+ALLTRIM(TRANSFORM(SWD->WD_VALOR_R,cPict17_2))+CHR(13)+CHR(10)+;
                                 "Processo: "+Alltrim(SW6->W6_HAWB)+CHR(13)+CHR(10)+;
                                 CHR(13)+CHR(10)+;
                                 "Despesa Integrada"+CHR(13)+CHR(10)+;
                                 "-----------------------------------"+CHR(13)+CHR(10)+;
                                 "Despesa: "+Int_DspDe->NDDDESPESA+" - "+ cDescDesp +CHR(13)+CHR(10)+;
                                 "Data: "+DTOC(IN100CTD(Int_DspDe->NDDDPAGTO,,"DDMMAAAA"))+CHR(13)+CHR(10)+;
                                 "Valor : "+ALLTRIM(TRANSFORM(Int_DspDe->NDDVALOR,cPict17_2))+CHR(13)+CHR(10)+;
                                 "SOBREPOR ?","Forn: "+SWD->WD_FORN+SWD->WD_LOJA+"-"+cDescForn)
                        lAcerta:= .T.
                        Int_DspDe->NDD_LOG := "S"
                        EXIT
                     Else
                        lNaoGrava:= .T.
                        EXIT   
                     Endif
                  Endif
               
                  SWD->(DbSkip())
               Enddo
               
               RestOrd(aOrdAuxSWD,.T.)
               
               If lNaoGrava
                  Int_DspDe->NDD_GRAVA := "N"
                  Int_DspDe->(DbSkip())
                  Loop
               ElseIf lAcerta
                  Int_DspDe->NDD_GRAVA := " "
                  Int_DspDe->(DbSkip())
                  Loop
               Endif 
               
               If !Empty(SWD->WD_DES_ADI) .AND. SWD->WD_VALOR_R == 0 
                  lSobrepor:= .T.
               Endif
            
               
               If !Empty(SWD->WD_DES_ADI) .AND. SWD->WD_VALOR_R <> 0 
                  If SWD->WD_DES_ADI <> IN100CTD(Int_DspDe->NDDDPAGTO,,"DDMMAAAA")
                     lGrv := .T.   
                  Endif
               Endif
               
            Else
                              
               If !lSched .AND. MSGYESNO("A Despesa de imposto "+Int_DspDe->NDDDESPESA+" já existe com o valor de R$ "+ALLTRIM(TRANSFORM(SWD->WD_VALOR_R,cPict17_2))+;//AWR - 20/04/2010
                                     ". Deseja SOBREPOR com o valor de R$ "+ALLTRIM(TRANSFORM(Int_DspDe->NDDVALOR,cPict17_2))+" ?","Fornecedor: "+SWD->WD_FORN+SWD->WD_LOJA)
                  lSobrepor:= .T.
                  //DelOldTitF()  //NCF - 19/01/2021 - Se optar por sobrepor, estornar o título financeiro gerado para a despesa
               ELSEIf lSched .OR. MSGYESNO("A Despesa de imposto "+Int_DspDe->NDDDESPESA+" já existe com o valor de R$ "+ALLTRIM(TRANSFORM(SWD->WD_VALOR_R,cPict17_2))+;//AWR - 20/04/2010
                                     ". Deseja INCLUIR outra com o valor de R$ "+ALLTRIM(TRANSFORM(Int_DspDe->NDDVALOR,cPict17_2))+" ?","Fornecedor: "+SWD->WD_FORN+SWD->WD_LOJA)
                  lGrv := .T.
               ELSE
                  lGrv := .F.
               ENDIF
         
            Endif
         
         Else
            lGrv := .T.
         EndIf
      EndIf
   Else //se não for imposto, verifica se despesa não tem Nota.
      //(cAlias)->(DBGoTop())//AWR - 20/04/2010
      If lLinha //LGS-08/04/2014
         SWD->( DbSetOrder(6) )
      EndIf
      If SWD->(DbSeek(xFilial()+SW6->W6_HAWB+Int_DspDe->NDDDESPESA+IF(AvFlags("AVINT_FINANCEIRO_EIC"),Int_DspDe->NDD_LINHA,"")))
         //TRP - 05/11/12 - CENARIO AVINTEG
         If AvFlags("AVINT_FINANCEIRO_EIC") 
            
               cDescDesp:= ""
               
               SYB->(DbSetOrder(1))
      		   If SYB->(DbSeek(xFilial("SYB")+Int_DspDe->NDDDESPESA))
                  cDescDesp:= Left(SYB->YB_DESCR,LEN(SYB->YB_DESCR))
                  cMoeda:= Left(SYB->YB_MOEDA,LEN(SYB->YB_MOEDA))   
               Endif
               
               SA2->(DbSetOrder(1))
               If SA2->(DBSEEK(cFilSA2+SWD->WD_FORN+SWD->WD_LOJA))
                  cDescForn:= SA2->A2_NREDUZ
               Endif 
               
               lNaoGrava:= .F.
               lAcerta := .F.
               aOrdAuxSWD:= SaveOrd({"SWD"})
               //Verifica se os dados chave são exatamente iguais
               DO While SWD->(!Eof()) .AND. cFilSWD == SWD->WD_FILIAL .AND.;
                  SWD->WD_HAWB == SW6->W6_HAWB .And. SWD->WD_DESPESA == Int_DspDe->NDDDESPESA
                  
                  If SWD->WD_DESPESA == Int_DspDe->NDDDESPESA  .AND. SWD->WD_DES_ADI == IN100CTD(Int_DspDe->NDDDPAGTO,,"DDMMAAAA") .AND. SWD->WD_VALOR_R == Int_DspDe->NDDVALOR 
                     lNaoGrava:= .T. 
                     EXIT
                  ElseIf SWD->WD_DESPESA == Int_DspDe->NDDDESPESA  .AND. SWD->WD_DES_ADI == IN100CTD(Int_DspDe->NDDDPAGTO,,"DDMMAAAA") .AND. SWD->WD_VALOR_R <> 0 .AND. !Empty(SWD->WD_CTRLERP)
                     lNaoGrava:= .T.
                     AADD(aMemo,{Int_DspDe->NDDDESPESA + Space(1) + cDescDesp  + Space(2) +  cMoeda + Space(1)+ TRANSFORM(Int_DspDe->NDDVALOR,cPict17_2)  + Space(4) + DTOC(IN100CTD(Int_DspDe->NDDDPAGTO,,'DDMMAAAA'))   ,.T.})
                     AADD(aMemo,{"Integração da Despesa "+ Int_DspDe->NDDDESPESA + " ignorada, pois já foi enviada ao ERP.",.T.})
                     AADD(aMemo,{"Aguardar o retorno do título do ERP e reprocessar o arquivo.",.T.})
                     AADD(aMemo,{CHR(13)+CHR(10),.T.})
                     AADD(aMemo,{CHR(13)+CHR(10),.T.}) 
                     cMemo:= "Despesas Integradas:"
                     EXIT
                  ElseIf SWD->WD_DESPESA == Int_DspDe->NDDDESPESA  .AND. SWD->WD_DES_ADI == IN100CTD(Int_DspDe->NDDDPAGTO,,"DDMMAAAA") .AND. SWD->WD_VALOR_R <> Int_DspDe->NDDVALOR .AND. Empty(SWD->WD_TITERP)
                     lAcerta:= .T.
                     EXIT   
                  ElseIf SWD->WD_DESPESA == Int_DspDe->NDDDESPESA  .AND. SWD->WD_DES_ADI == IN100CTD(Int_DspDe->NDDDPAGTO,,"DDMMAAAA") .AND. SWD->WD_VALOR_R <> Int_DspDe->NDDVALOR .AND. !Empty(SWD->WD_TITERP)
                     If MSGYESNO("Despesa Existente"+CHR(13)+CHR(10)+;
                                 "-----------------------------------"+CHR(13)+CHR(10)+;
                     		     "Despesa: "+Int_DspDe->NDDDESPESA+" - "+ cDescDesp +CHR(13)+CHR(10)+;
                                 "Data: "+DTOC(SWD->WD_DES_ADI)+CHR(13)+CHR(10)+;
                                 "Valor : "+ALLTRIM(TRANSFORM(SWD->WD_VALOR_R,cPict17_2))+CHR(13)+CHR(10)+;
                                 "Processo: "+Alltrim(SW6->W6_HAWB)+CHR(13)+CHR(10)+;
                                 CHR(13)+CHR(10)+;
                                 "Despesa Integrada"+CHR(13)+CHR(10)+;
                                 "-----------------------------------"+CHR(13)+CHR(10)+;
                                 "Despesa: "+Int_DspDe->NDDDESPESA+" - "+ cDescDesp +CHR(13)+CHR(10)+;
                                 "Data: "+DTOC(IN100CTD(Int_DspDe->NDDDPAGTO,,"DDMMAAAA"))+CHR(13)+CHR(10)+;
                                 "Valor : "+ALLTRIM(TRANSFORM(Int_DspDe->NDDVALOR,cPict17_2))+CHR(13)+CHR(10)+;
                                 "SOBREPOR ?","Forn: "+SWD->WD_FORN+SWD->WD_LOJA+"-"+cDescForn)
                        lAcerta:= .T.
                        Int_DspDe->NDD_LOG := "S"
                        EXIT
                     Else
                        lNaoGrava:= .T.
                        EXIT 
                     Endif
                  Endif
               
                  SWD->(DbSkip())
               Enddo
               
               RestOrd(aOrdAuxSWD,.T.)
               
               If lNaoGrava
                  Int_DspDe->NDD_GRAVA := "N"
                  Int_DspDe->(DbSkip())
                  Loop
               ElseIf lAcerta
                  Int_DspDe->NDD_GRAVA := " "
                  Int_DspDe->(DbSkip())
                  Loop
               Endif 
               
               If !Empty(SWD->WD_DES_ADI) .AND. SWD->WD_VALOR_R == 0 
                  lSobrepor:= .T.
               Endif
            
               If !Empty(SWD->WD_DES_ADI) .AND. SWD->WD_VALOR_R <> 0 
                  If SWD->WD_DES_ADI <> IN100CTD(Int_DspDe->NDDDPAGTO,,"DDMMAAAA")
                     lGrv := .T.   
                  Endif
               Endif
         
         Else
         
            //Se não tiver Nota, faz pergunta de que se deseja incluir um novo registro no SWD.
            If !Empty(SWD->WD_NF_COMP) //.AND. Empty(SWD->WD_SE_NFC)//AWR - 20/04/2010
//             If lSched .OR. MSGYESNO("A Despesa "+Int_DspDe->NDDDESPESA + " já foi utilizada um valor total de " + ;//AWR - 20/04/2010
//                                  AllTrim(STR(nTotalDesp)) + ". Deseja incluir um novo registro da despesa?")
            If lSched .OR. MSGYESNO("A Despesa "+Int_DspDe->NDDDESPESA+" foi usada na Nota com o valor de R$ "+ALLTRIM(TRANSFORM(SWD->WD_VALOR_R,cPict17_2))+;//AWR - 20/04/2010
                                        ". Deseja INCLUIR outra com o valor de R$ "+ALLTRIM(TRANSFORM(Int_DspDe->NDDVALOR,cPict17_2))+" ?","Fornecedor: "+SWD->WD_FORN+SWD->WD_LOJA)
               lGrv := .T.
            ELSE
               lGrv := .F.
            ENDIF 

         Else

            If !lSched .AND. MSGYESNO("A Despesa "+Int_DspDe->NDDDESPESA+" já existe com o valor de R$ "+ALLTRIM(TRANSFORM(SWD->WD_VALOR_R,cPict17_2))+;//AWR - 20/04/2010
                                      ". Deseja SOBREPOR com o valor de R$ "+ALLTRIM(TRANSFORM(Int_DspDe->NDDVALOR,cPict17_2))+" ?","Fornecedor: "+SWD->WD_FORN+SWD->WD_LOJA)
               lSobrepor:= .T.
            ELSE
               lGrv := .F.
            ENDIF

            EndIf
         Endif
      Else
         lGrv := .T.
      EndIf
      
      If lLinha
         SWD->( DbSetOrder(1) )
      EndIf
   EndIf  

   IF lSobrepor//AWR - 20/04/2010
      Int_DspDe->NDD_GRAVA := " "
   ELSEIf lGrv
//    Reclock("Int_DspDe",.F.)//AWR - 20/04/2010
      Int_DspDe->NDD_GRAVA := "S"
//    Int_DspDe->(MsUnlock()) //AWR - 20/04/2010
   Else
//    Reclock("Int_DspDe",.F.)//AWR - 20/04/2010
      Int_DspDe->NDD_GRAVA := "N"
//    Int_DspDe->(MsUnlock()) //AWR - 20/04/2010
   EndIf
   //JVR - 18/11/09

   // EOB - 15/07/08 - Verifica se haverá despesas que não se refete a adiantamento ao despachante
   If (Int_DspDe->NDD_GRAVA == " " .OR. Int_DspDe->NDD_GRAVA == "S") .AND. ( EMPTY(Int_DspDe->NDDADIANTA) .OR. ALLTRIM(Int_DspDe->NDDADIANTA) $ cNao )
      nDespesas++
   EndIf 

   Int_DspDe->(DbSkip())
EndDo

// EOB - 15/07/08 - Se tiver integrado com o financeiro e tiver despesas que não são de adiantamento, pergunta se quer gerar os títulos no C.Pagar
lGer_Tit := .F.
IF lMV_EASYFIN .AND.  cPaisLoc = "BRA" .AND. nDespesas > 0
   If !lSched 
      lGer_Tit := MSGYESNO("Deseja gerar títulos no Contas a pagar para as despesas integradas?")
   Else
      lGer_Tit := .T.
   Endif
ENDIF

//BAK - Alteração para a nova integração despachante, as variaveis era somente atribuitas dentro do laço
cAlias := "SWD"
nAlias := Select("SWD")
cPref  := "WD_"


//ASR 18/11/2005 - GRAVAÇÃO
//LGS-08/04/2014 - Valida se no arquivo que esta sendo integrado tem despesa que o codigo começe com 1 e seta para não integrar essas despesas.
Int_DspDe->(DBGoTop()) //LRS - 12/07/2017
EIC->(DbSetOrder(1))
Int_DspDe->(DbSeek(Int_DspHe->NDHHOUSE))
While Int_DspDe->(!Eof()) .And. Int_DspDe->NDDHOUSE == Int_DspHe->NDHHOUSE   
   If SubStr(Int_DspDe->NDDDESPESA,1,3) $ '102,103' 
   	  Int_DspDe->NDD_GRAVA := "N"
   EndIf
   SWD->(DbSetOrder(1))
   IF SWD->(DbSeek(xFilial()+SW6->W6_HAWB+Avkey(Int_DspDe->NDDDESPESA,"WD_DESPESA") )) 
      IF EIC->(DbSeek(xFilial("EIC")+SW6->W6_HAWB+AvKey(Int_DspDe->NDDDESPESA,"EIC_DESPES") ))       
        IF !EMPTY(SWD->WD_CTRFIN1)
            If EasyGParam("MV_EASYFIN",,"N") == "S"
                Int_DspDe->NDD_GRAVA := "N"
            EndIf
        EndIF
      ENDIF
   EndIF
   Int_DspDe->(DbSkip())
EndDo

Int_DspDe->(DBGoTop())
Int_DspDe->(DbSeek(Int_DspHe->NDHHOUSE)) 

While Int_DspDe->(!Eof()) .And. Int_DspDe->NDDHOUSE == Int_DspHe->NDHHOUSE
   If Int_DspDe->NDD_GRAVA == " " .OR. Int_DspDe->NDD_GRAVA == "S"
      If Empty(cMemo)
         cMemo := "Despesas Integradas:"+CHR(13)+CHR(10)//ASR 18/11/2005
      ENDIF
      If Int_DspDe->NDD_GRAVA == " "//Sobrepor//AWR - 20/04/2010 
            
         //NCF - 04/10/2011 - Apurar se existem mais de uma despesa de imposto adiantada
         aOrdSWD := SaveOrd({"SWD"})
         nDespCount := 0
         SWD->(DbSetOrder(1))
         SWD->(DbSeek(xFilial()+SW6->W6_HAWB+Int_DspDe->NDDDESPESA ))
         If !AvFlags("AVINT_FINANCEIRO_EIC") 
            Do While SWD->(!Eof()) .And. SWD->WD_HAWB == SW6->W6_HAWB .And. SWD->WD_DESPESA == Int_DspDe->NDDDESPESA
               If nDespCount >= 2
                  Exit
               Else
                  If SWD->WD_BASEADI $ cSim
                     nDespCount++ 
                  EndIf
               EndIf
               SWD->(DbSkip())         
            EndDo
             
            //NCF - 04/10/2011 - Apagar as despesas de adiantamento e manter somente uma para sobrepor com a efetiva integrada        
            //TRP-05/11/12
         
            If nDespCount > 1
               For i := 1 to nDespCount-1
                  If SWD->(DbSeek(xFilial()+SW6->W6_HAWB+Int_DspDe->NDDDESPESA))
                     DelOldTitF()  //NCF - 19/01/2021 - Se optar por sobrepor, estornar o título financeiro gerado para a despesa
                     Reclock("SWD",.F.)
                     SWD->(DbDelete())
                     SWD->(MsUnlock())               
                  EndIf
               Next i
            EndIf
         Endif
         
         RestOrd(aOrdSWD,.T.)

         If AvFlags("AVINT_FINANCEIRO_EIC") 
            lAchouDesp:= .F.
            IF SWD->(DbSeek(xFilial("SWD")+SW6->W6_HAWB+Int_DspDe->NDDDESPESA))
               DO While SWD->(!Eof()) .AND. cFilSWD == SWD->WD_FILIAL .AND.;
                        SWD->WD_HAWB == SW6->W6_HAWB .And. SWD->WD_DESPESA == Int_DspDe->NDDDESPESA
         
                        If (SWD->WD_DESPESA == Int_DspDe->NDDDESPESA .AND. SWD->WD_VALOR_R == 0) .OR. (SWD->WD_DESPESA == Int_DspDe->NDDDESPESA  .AND. SWD->WD_DES_ADI == IN100CTD(Int_DspDe->NDDDPAGTO,,"DDMMAAAA") )   
                           If SWD->WD_LINHA == Int_DspDe->NDD_LINHA //LGS-08/04/2014
                              lAchouDesp:= .T.
                              EXIT
                           EndIf   
               	        Endif
               	
               	   SWD->(DbSkip())
               Enddo
            Else   
               Int_DspDe->(DbSkip())
               LOOP
            ENDIF
            lAlt:= .T.
            If lAchouDesp 
               SWD->(Reclock(cAlias,.F.))
            Else
               SWD->(Reclock(cAlias,.T.))
               Int_DspDe->NDD_GRAVA := "S"   
               lAlt:= .F.
            Endif
         
         Else
            IF !SWD->(DbSeek(xFilial()+SW6->W6_HAWB+Int_DspDe->NDDDESPESA))
               Int_DspDe->(DbSkip())
               LOOP
            Endif
            SWD->(Reclock(cAlias,.F.))
         ENDIF
         
       
      ELSE//Incluir
         lAlt:= .F.
         SWD->(Reclock(cAlias,.T.))
      ENDIF
      
      SYB->(DbSetOrder(1))
      If SYB->(DbSeek(xFilial("SYB")+Int_DspDe->NDDDESPESA))
         cDescDesp:= Left(SYB->YB_DESCR,LEN(SYB->YB_DESCR))
         cMoeda:= Left(SYB->YB_MOEDA,LEN(SYB->YB_MOEDA))   
      Endif
      
      If lAlt .AND. lAchouDesp .AND. AvFlags("AVINT_FINANCEIRO_EIC") 
          (cAlias)->(FieldPut(FieldPos(cPref+"VALOR_R"), Int_DspDe->NDDVALOR))
          (cAlias)->(FieldPut(FieldPos(cPref+"DES_ADI"), IN100CTD(Int_DspDe->NDDDPAGTO,,'DDMMAAAA')))
                 
                     //Código da Despesa , Descrição da Despesa, Moeda, Valor, Data
          AADD(aMemo,{Int_DspDe->NDDDESPESA + Space(1) + cDescDesp  + Space(2) +  cMoeda + Space(1) + TRANSFORM(Int_DspDe->NDDVALOR,cPict17_2)  + Space(4) + DTOC(IN100CTD(Int_DspDe->NDDDPAGTO,,'DDMMAAAA'))   ,.T.})
          If Int_DspDe->NDD_LOG == "S"
             AADD(aMemo,{"O valor da Despesa "+ Int_DspDe->NDDDESPESA + " foi alterado.",.T.})
             AADD(aMemo,{"Providenciar o envio da alteração ao ERP Título: "+SWD->WD_TITERP,.T.})
             AADD(aMemo,{CHR(13)+CHR(10),.T.})
             AADD(aMemo,{CHR(13)+CHR(10),.T.})
          Endif
      Elseif !lAlt
         lDespInteg := (cAlias)->&(cPref+"INTEGRA") //NCF - 21/01/2021 - Verificar se é despesa integrada antes da alteração.
         (cAlias)->(FieldPut(FieldPos(cPref+"FILIAL"), xFilial(cAlias)))
         (cAlias)->(FieldPut(FieldPos(cPref+"HAWB"), SW6->W6_HAWB))
         (cAlias)->(FieldPut(FieldPos(cPref+"DES_ADI"), IN100CTD(Int_DspDe->NDDDPAGTO,,'DDMMAAAA')))
         (cAlias)->(FieldPut(FieldPos(cPref+"DESPESA"), Int_DspDe->NDDDESPESA))         
         (cAlias)->(FieldPut(FieldPos(cPref+"VALOR_R"), Int_DspDe->NDDVALOR))
         (cAlias)->(FieldPut(FieldPos(cPref+"PAGOPOR"), Int_DspDe->NDDPAGOPOR))       
         (cAlias)->(FieldPut(FieldPos(cPref+"INTEGRA"), .T.))   
         If Alltrim(SW6->W6_TIPOFEC) == "DA" 
            (cAlias)->(FieldPut(FieldPos(cPref+"DA"),"1"))
         End If    
         
         If AvFlags("AVINT_FINANCEIRO_EIC")
            AADD(aMemo,{Int_DspDe->NDDDESPESA + Space(1) + cDescDesp  + Space(2) +  cMoeda + Space(1)+ TRANSFORM(Int_DspDe->NDDVALOR,cPict17_2) + Space(4) +  DTOC(IN100CTD(Int_DspDe->NDDDPAGTO,,'DDMMAAAA'))   ,.T.})
         Else
            cMemo += Int_DspDe->NDDDESPESA+" - "+AllTrim(STR(Int_DspDe->NDDVALOR))+CHR(13)+CHR(10)
         Endif
         
         IF cPref = "WD_"
            If !lTemAdiant .OR. EMPTY(ALLTRIM(Int_DspDe->NDDADIANTA)) .OR. !ALLTRIM(Int_DspDe->NDDADIANTA) $ (cSim+cNao)
               IF Int_DspDe->NDDPAGOPOR = "1"
                  Eval(FieldwBlock(cPref+"BASEADI",nAlias),"1")
               ENDIF    
            Else
               Eval(FieldwBlock(cPref+"BASEADI",nAlias),if(Int_DspDe->NDDADIANTA $ cSim,"1","2"))
            EndIf
         ENDIF
      
         //NCF - 09/09/2010 - Grava Fornecedor e Loja do Despachante (dados necessários para compensação do título)
         If Int_DspDe->NDDPAGOPOR = "1"
            (cAlias)->(FieldPut(FieldPos(cPref+"FORN"), SY5->Y5_FORNECE))
            (cAlias)->(FieldPut(FieldPos(cPref+"LOJA"), SY5->Y5_LOJAF  ))   
         Endif
      
         //TRP  - 04/10/12 - Tratamento para AvInteg.
         If AvFlags("AVINT_FINANCEIRO_EIC")
	        (cAlias)->(FieldPut(FieldPos(cPref+"LINHA"), DI500SWDLin(SW6->W6_HAWB,Int_DspDe->NDDDESPESA) )) 
	        SYB->(DbSetOrder(1))
	        If SYB->(DbSeek(xFilial("SYB")+Int_DspDe->NDDDESPESA))
	           (cAlias)->(FieldPut(FieldPos(cPref+"FGDEBCC"), SYB->YB_FGDEBCC ))   
	           (cAlias)->(FieldPut(FieldPos(cPref+"FGTITUL"), SYB->YB_FGTITUL )) 
	        Endif
	        (cAlias)->(FieldPut(FieldPos(cPref+"DA"), IF(SW6->W6_TIPOFEC='DA','1','2') ))  
	     EndIf
      
      Endif

      //NCF - 19/01/2021 - Se optar por sobrepor despesa/imposto incluso manualmente com título financeiro, estornar o título gerado para a despesa.
      If lSobrepor .And. !lDespInteg
         DelOldTitF()  
      EndIf  

      IF EasyEntryPoint("IN100CLI")
         ExecBlock("IN100CLI",.F.,.F.,"GRVDESP")
      ENDIF
      DBSELECTAREA(scAlias)    // Volta a area que foi trocada por RecLock().
      If (cAlias)->(IsLocked())
         (cAlias)->(MsUnlock())
      Endif
      // EOB - 15/07/08 - Gera os títulos das despesas integradas
      IF lGer_Tit .AND. ( EMPTY(Int_DspDe->NDDADIANTA) .OR. ALLTRIM(Int_DspDe->NDDADIANTA) $ cNao ) .AND. !AvFlags("AVINT_FINANCEIRO_EIC") //TRP-05/11/12
         
         INCLUI:= .T.  //TRP - 25/07/2011 - Para não dar erro no FINA050.PRX - Chamado 087956
         
         dbSelectArea("SWD")
		   FOR nc := 1 TO FCount()
		      M->&(FIELDNAME(nc)) := CRIAVAR(FIELDNAME(nc))
		   NEXT 
         M->WD_DESPESA := Int_DspDe->NDDDESPESA
   		SYB->(DBSEEK(cFilSYB+M->WD_DESPESA))
         cPrefixo  := AVKEY("EIC","E2_PREFIXO")   //M->E2_PREFIXO
         cCodFor   := SPACE(LEN(SE2->E2_FORNECE)) //M->E2_FORNECE
         cLojaFor  := SPACE(LEN(SE2->E2_LOJA))    //M->E2_LOJA
         nMoedSubs := 1                           //M->E2_MOEDA
         nValorS   := Int_DspDe->NDDVALOR         //M->E2_VLCRUZ
         cHistorico:="P: "+ALLTRIM(SW6->W6_HAWB)+' '+ALLTRIM(SYB->YB_DESCR)
         
         IF FI400TITFIN("SWD_INT","2")
            SWD->(RecLock("SWD",.F.))
            SWD->WD_PREFIXO := M->WD_PREFIXO
            SWD->WD_DOCTO   := M->WD_DOCTO
            SWD->WD_CTRFIN1 := M->WD_CTRFIN1
            SWD->WD_PARCELA := M->WD_PARCELA
            SWD->WD_TIPO    := M->WD_TIPO
            SWD->WD_FORN    := M->WD_FORN
            SWD->WD_LOJA    := M->WD_LOJA
            SWD->WD_DES_ADI := M->WD_DES_ADI
            SWD->WD_GERFIN  := "1"
            SWD->WD_DTENVF  := M->WD_DTENVF
            SWD->(MsUnlock())
			
            SE2->(DBSETORDER(1))
            IF SE2->(DBSEEK(xFilial("SE2")+SWD->WD_PREFIXO+SWD->WD_CTRFIN1+SWD->WD_PARCELA+SWD->WD_TIPO+SWD->WD_FORN+SWD->WD_LOJA))
               SE2->(RECLOCK("SE2",.F.))
               SE2->E2_ORIGEM:="SIGAEIC"
               SE2->(MSUNLOCK())
            ENDIF
		 ENDIF
	  ENDIF
   EndIf
   Int_DspDe->(DbSkip())
EndDo

// caso sofra alteração e o cambfre e cambseg estejam desabilitados - MPG - OSSME-4645 - 12/05/2020
if lMV_EASYFIN .and. (lAltFrete .or. lAltSeguro)
   lFinanceiro := .T.
   
   if lAltFrete .and. ! avFlags("GERACAO_CAMBIO_FRETE")
      if ! EIC->( dbsetorder(1),dbseek( xFilial("EIC") + SW6->W6_HAWB + AvKey("102","EIC_DESPES") ))
         if FI400TITFIN("SW6_102","4",.T.)
            AVINCFRETESEG("102")
         endif
      endif
   endif

   if lAltSeguro .and. ! avFlags("GERACAO_CAMBIO_SEGURO")
      if ! EIC->( dbsetorder(1),dbseek( xFilial("EIC") + SW6->W6_HAWB + AvKey("102","EIC_DESPES") ))
         if FI400TITFIN("SW6_103","4",.T.)
            AVINCFRETESEG("103")
         endif
      endif
   endif

endif

IF lGer_Tit
    axFl2DelWork:={}
	EICFI400("INTEG_DESP")
    IF Select("WorkTP") # 0
       IF TYPE("axFl2DelWork") = "A" .AND. LEN(axFl2DelWork) > 0
          WorkTP->(E_EraseArq(axFl2DelWork[1]))
          FOR nc:=2 TO LEN(axFl2DelWork)
              //MFR 18/12/2018 OSSME-1974
              FERASE(axFl2DelWork[nc]+TeOrdBagExt())
          NEXT
       ENDIF
    ENDIF
ENDIF
	
SW6->(MsUnlock())
DbCommitAll()

VrCambio()

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"GRVDE")
ENDIF

RETURN .T.

*------------------------------------------------------------------------------------------*
FUNCTION IN100Despesas()
*------------------------------------------------------------------------------------------*
LOCAL nVolta, sbMessage := bMessage, sbStatus := bStatus
LOCAL lTemAdiant := IF(Int_DspDe->(FIELDPOS("NDDADIANTA")) # 0,.T.,.F.)
LOCAL oPanelDesp    // ACSJ - 19/05/2004 - Ajustes para MDI                    

bMessage:=FIELDWBLOCK( 'NDDMsg', SELECT('Temp') )
bStatus :={|x| if(x=nil,Temp->NDDINT_OK="T",Temp->NDDINT_OK:=x)}

PRIVATE TB_Col_D := { { {|| IN100Status()                        },, STR0036    },; //"Status"
                      { {|| Temp->NDDDESPESA                     },, "Despesa"  },;
                      { {|| IN100CTD(Temp->NDDDPAGTO,,'DDMMAAAA')},, "Pagto."   },; //MJB-SAP-1100
                      { {|| TRANSFORM(Temp->NDDVALOR,cPict17_2)       },, "Valor"    },;
                      { {|| Temp->NDDEFEPREV                     },, "Tipo"     },;
                      { {|| Temp->NDDPAGOPOR                     },, "Pagador"  }} 
                   
IF lTemAdiant
   AADD(TB_Col_D,{ {|| Temp->NDDADIANTA }, "", "Adiantamento"})
ENDIF

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"COLDESP")
ENDIF

AADD(TB_Col_D, { {|| IN100E_Msg(.T.) }, "", "Mensagem" } )

DBSELECTAREA('Temp')
avzap()

Int_DspDe->( DbSeek( Int_DspHe->NDHHOUSE ) )


DO WHILE !Int_DspDe->( EOF() )  .AND.  Int_DspHe->NDHHOUSE == Int_DspDe->NDDHOUSE

   IN100RecLock('Temp')

   Temp->NDDINT_OK  := Int_DspDe->NDDINT_OK
   Temp->NDDHOUSE   := Int_DspDe->NDDHOUSE
   Temp->NDDDPAGTO  := Int_DspDe->NDDDPAGTO
   Temp->NDDDESPESA := Int_DspDe->NDDDESPESA
   Temp->NDDVALOR   := Int_DspDe->NDDVALOR
   Temp->NDDEFEPREV := Int_DspDe->NDDEFEPREV
   Temp->NDDPAGOPOR := Int_DspDe->NDDPAGOPOR
   Temp->NDDMSG     := In100QuebraMensagem( Alltrim(Int_DspDe->NDDMSG) )
   IF lTemAdiant
      Temp->NDDADIANTA := Int_DspDe->NDDADIANTA
   ENDIF

   IF EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"GRV_TMP_DESP")   //TRP-01/05/08- Inclusão de ponto de entrada
   ENDIF 
   Temp->( MsUnlock() )

   Int_DspDe->( DbSkip() )

ENDDO

IF Temp->(EasyRecCount("Temp") ) == 0
   IN100RecLock('Temp')
ENDIF

Temp->( DbGoTop() )

DEFINE MSDIALOG oDlg6 TITLE STR0474 + Int_DspHe->NDHHAWB ;
       From oMainWnd:nTop+125,oMainWnd:nLeft+5 To oMainWnd:nBottom-60,oMainWnd:nRight-10 OF oDlg2 PIXEL//"Itens do Processo "

        bMessage:=FIELDWBLOCK( 'NDDMsg', SELECT('Temp') )
        
        @00,00 MSPanel oPanelDesp Prompt "" Size 60,19 of oDlg6    // ACSJ - 19/05/2004 - Ajuste MDI

        @ 5,((oDlg6:nClientWidth-4)/2)-85 BUTTON STR0029 SIZE 34,11 FONT oDlg6:oFont ACTION (IN100E_MSG()) OF oPanelDesp PIXEL //"&Mensagem"   // ACSJ - 19/05/2004 - Ajustes MDI
        @ 5,((oDlg6:nClientWidth-4)/2)-35 BUTTON STR0031 SIZE 34,11 FONT oDlg6:oFont ACTION (IN100Txt())   OF oPanelDesp PIXEL //"&Gera Txt"   // ACSJ - 19/05/2004 - Ajustes MDI
        @ 5,((oDlg6:nClientWidth-4)/2)-135 BUTTON "Taxas" SIZE 34,11 ACTION (IN100DeTaxas()) OF oPanelDesp /*oDlg6*/ PIXEL

        oTrab:=MsSelect():New(('Temp'),,,TB_Col_D,@lInverte,@cMarca,{35,1,(oDlg6:nHeight-30)/2,(oDlg6:nClientWidth-4)/2})
        oTrab:oBrowse:bWhen:={|| DBSELECTAREA('Temp'),.T.}

        nVolta:=0
        oDlg6:lMaximized:=.T.
		
		oPanelDesp:Align := CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
        oTrab:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
		
ACTIVATE MSDIALOG oDlg6 ON INIT (EnchoiceBar(oDlg6,{||nVolta:=1,oDlg6:End()},{||oDlg6:End()}))   // ACSJ - 19/05/2004 - Ajustes MDI //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

bMessage := sbMessage
bStatus  := sbStatus

DbSelectArea( "Int_DspHe" )



RETURN .T.

*------------------------------------------------------------------------------------------*
FUNCTION IN100DeTaxas()
*------------------------------------------------------------------------------------------*
LOCAL stbStatus := bStatus
LOCAL stbMessage:= bMessage,oDlgTx
LOCAL scParamInic:= cParamInic,oTrabTx
PRIVATE TB_Col_D := { }
AADD(   TB_Col_D, {{|| IN100Status()},, STR0036}) //"Status"
AADD(   TB_Col_D, { "NTXMOEDA"       ,,"Moeda" })
AADD(   TB_Col_D, { "NTXTAXA",,"Taxa",cPict15_8})

cParamInic:=Int_DspHe->NDHHOUSE
bMessage  :=FIELDWBLOCK( 'NTXMSG', SELECT('Int_DspTx') )
bStatus   :={|x| if(x=nil,Int_DspTx->NTXINT_OK="T",Int_DspTx->NTXINT_OK:=x)}

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"COLDETX")
ENDIF

AADD(TB_Col_D, { {|| IN100E_Msg(.T.) }, , "Mensagem" } )

Int_DspTx->( DbSeek( Int_DspHe->NDHHOUSE ) )

DEFINE MSDIALOG oDlgTx TITLE "Taxas do Processo: " + Int_DspHe->NDHHAWB ;
       From oMainWnd:nTop+125,oMainWnd:nLeft+180 To oMainWnd:nBottom-90,oMainWnd:nRight-180 PIXEL

    @ 18,050 BUTTON STR0029 SIZE 34,11 ACTION (IN100E_MSG()) OF oDlgTx PIXEL //"&Mensagem"
    @ 18,095 BUTTON STR0031 SIZE 34,11 ACTION (IN100Txt())   OF oDlgTx PIXEL //"&Gera Txt"

    oTrabTx:=MsSelect():New(('Int_DspTx'),,,TB_Col_D,@lInverte,@cMarca,{35,1,(oDlgTx:nHeight-30)/2,(oDlgTx:nClientWidth-4)/2},"IN100Filtro(.T.)","IN100Filtro(.T.)")
    oTrabTx:oBrowse:bWhen:={|| DBSELECTAREA('Int_DspTx'),.T.}

ACTIVATE MSDIALOG oDlgTx ON INIT EnchoiceBar(oDlgTx,{||oDlgTx:End()},{||oDlgTx:End()})

bMessage  := stbMessage
bStatus   := stbStatus
cParamInic:= scParamInic

DbSelectArea( "Temp" )

RETURN .T.

*---------------------------------------------------------------------------------------------------*
FUNCTION IN100VerDH()
*---------------------------------------------------------------------------------------------------*
Local nRec, nIgual:=0, cProc, cRef, cDesp
Local aNotCmposSX3 := {{"RECNO","N",10,0}}
Local aDspch := {}
Local cDspDEPARA := ""
Private lIntFrt

SW6->( DbSetOrder( 9 ) )
SYU->(DbSetOrder(2))

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"LERDH")
ENDIF

If Empty(Int_DspHe->NDHREFDESP)
   EVAL(bMsg,STR0475+STR0546) //"REF.DESPACHANTE NAO INFORMADO

ElseIf !SW6->( DbSeek( cFilSW6+Int_DspHe->NDHREFDESP ) )
   EVAL(bMsg,STR0475+STR0544) //"REF.DESPACHANTE SEMCADASTRO
Elseif !Empty(SW6->W6_DT_ENCE)
   EVAL(bMsg,"Processo já está encerrado!")   //TRP-11/02/09- Valida os processos já encerrados.
Else
   
   //SVG- 05/02/09
   If !Empty(Int_DspHe->NDHDPAGIMP)   
      If !Empty(Int_DspHe->NDHDDESEMB)
         If IN100CTD(Int_DspHe->NDHDPAGIMP,,"DDMMAAAA") > IN100CTD(Int_DspHe->NDHDDESEMB,,"DDMMAAAA")
            EVAL(bMsg,STR0777) //"Data de Pagamento de Impostos Inválida."
         EndIf
      ElseIf !Empty(SW6->W6_DT_DESE) // AST - 02/03/09 - Data do desembaraço pode estar em branco no sistema
         If IN100CTD(Int_DspHe->NDHDPAGIMP,,"DDMMAAAA") > SW6->W6_DT_DESE
            EVAL(bMsg,STR0777) //"Data de Pagamento de Impostos Inválida."
         EndIf
      EndIf        
   EndIf
   nRec := Int_DspHe->(RecNo())
   cProc := Int_DspHe->NDHHOUSE
   cDesp := Int_DspHe->NDHDESP
   cRef  := Int_DspHe->NDHREFDESP
   Int_DspHe->(dbGoTop())
   Do While !Int_DspHe->(EOF()) .and. Int_DspHe->(RecNo()) < nRec
      If Int_DspHe->NDHHOUSE <> cProc .and. Int_DspHe->NDHDESP == cDesp .and. Int_DspHe->NDHREFDESP == cRef .and. nRec > Int_DspHe->(RecNo())
         nIgual := 1
         Exit
      EndIf
      Int_DspHe->(dbSkip())
   EndDo
   Int_DspHe->(dbGoTo(nRec))
   If nIgual = 1
      EVAL(bMsg,STR0058) //"Ref.Despach. ja informada p/ outro proc."
      nIgual := 0
   EndIf
   //NCF - 11/11/2016 - Verificação condicionada ao tamanho do campo e uso da tabela DE/PARA
   If Len(Int_DspHe->NDHDESP) <> AVSX3("W6_DESP",AV_TAMANHO)
      aDspch := GetDpTabDP(Int_DspHe->NDHDESP,Int_DspHe->NDHREFDESP)
      nIgual := Len(aDspch)
      If nIgual == 1
         cDspDEPARA := aDspch[1][1]
         nRec       := aDspch[1][2]
      EndIf 
   Else       
      cQuery := 'SELECT R_E_C_N_O_ RECNO, W6_DESP YU_EASY  '
      cQuery += ' FROM '+RetSQLName("SW6")+' SW6'
      cQuery += " WHERE SW6.W6_REF_DES = '"  +AvKey(Int_DspHe->NDHREFDESP,"W6_REF_DES")+"'
      cQuery += " AND SW6.W6_DESP = '"      +AvKey(Int_DspHe->NDHDESP   ,"W6_DESP"   )+"'  
      cQuery += " AND SW6.D_E_L_E_T_ = ' '" 
      
      EasyWkQuery(cQuery,"REFDESPROC",,aNotCmposSX3,)
      
      nIgual := REFDESPROC->(EasyRecCount("REFDESPROC"))      
      If nIgual == 1
         cDspDEPARA := AvKey(REFDESPROC->YU_EASY,"W6_DESP")
         nRec       := REFDESPROC->RECNO
      EndIf  
      /*Do While !SW6->(EOF()) .and. Int_DspHe->NDHREFDESP == SW6->W6_REF_DES
      If Int_DspHe->NDHDESP == SW6->W6_DESP
         nIgual += 1
         nRec := SW6->(RecNo())
      EndIf
      SW6->(DBSKIP())
      EndDo*/
   EndIf

   If Select("REFDESPROC") > 0
      REFDESPROC->(DbCloseArea())
   EndIf
         
   If nIgual > 1
      EVAL(bMsg,STR0056) //"Ref.Despach. existe em outro(s) proc(s)."
   ElseIf nIgual = 1
      SW6->(dbGoTo(nRec))
      Int_DspHe->NDHHAWB:=SW6->W6_HAWB
   Else
      EVAL(bMsg,STR0057) //"REF. sem cadastro p/ este despachante"
   EndIf
Endif
SW6->( DbSetOrder( 1 ) )


If Empty(Alltrim(Int_DspHe->NDHDESP))
   EVAL(bMsg,STR0477+STR0546) //"DESPACHANTE NAO INFORMADO
ElseIf ! SY5->(DbSeek(cFilSY5+ If( Empty(cDspDEPARA),Int_DspHe->NDHDESP,cDSPDEPARA) ))
   EVAL(bMsg,STR0477+STR0544) //"DESPACHANTE SEMCADASTRO
Endif

If !EMPTY(Int_DspHe->NDHAGENTE) .AND. !SY4->(DbSeek(cFilSY4+Int_DspHe->NDHAGENTE))
   //SVG - 05/10/2010 - 28/08/2009 - Verificação do agente GipLite na tabela De/Para e no Cadastro de Agentes
   If !SYU->(DbSeek(xFilial("SYU")+ If( Empty(cDspDEPARA),Int_DspHe->NDHDESP,cDSPDEPARA) +"3"+Int_DspHe->NDHAGENTE)) .or. !SY4->(DbSeek(cFilSY4+Alltrim(SYU->YU_EASY))) 
      EVAL(bMsg,STR0478+STR0544) //Agente sem Cadastro
   Else//SVG - 05/10/2010 - Grava o Agente da tabela de/para para o agente do arquivo de integração
      Int_DspHe->NDHAGENTE:= Alltrim(SYU->YU_EASY)
   EndIf   
Endif

IF Int_DspHe->NDHFRETVAL#0 .OR. Int_DspHe->NDHVLFRECC#0 .OR.  Int_DspHe->NDHVLFRETN#0

   SYF->( DbSetOrder( 3 ) )
   If (!EMPTY(Int_DspHe->NDHFRETMOE) .AND. !SYF->(DbSeek(cFilSYF+Int_DspHe->NDHFRETMOE)) ) .OR.;
     EMPTY(Int_DspHe->NDHFRETMOE)
      EVAL(bMsg,STR0479+STR0544) //"MOEDA DO FRETE SEM CADASTRO
   Endif
   SYF->( DbSetOrder( 1 ) )

   nRecNTX := Int_Dsptx->(RECNO())

   IF !EMPTY(Int_DspHe->NDHFRETMOE) .and. Int_Dsptx->(DbSeek(Int_Dsphe->NDHHOUSE+Int_Dsphe->NDHFRETMOE))

     IF !EMPTY(Int_DspHe->NDHFRETTAX ) .AND. Int_DspHe->NDHFRETTAX # Int_DspTx->NTXTAXA

       EVAL(bMsg,"Taxas Divergentes na Moeda de Frete")
     ELSE 

       Int_DspHe->NDHFRETTAX:=Int_DspTx->NTXTAXA
     ENDIF


   ELSEIF !EMPTY(Int_DspHe->NDHFRETMOE) 

     If EMPTY(Int_DspHe->NDHFRETTAX ) 
        EVAL(bMsg,STR0480+STR0546) //"TAXA CONVERSAO FRETE NAO INFORMADO

     ENDIF

   ENDIF 

   Int_Dsptx->(DBGOTO(nRecNTX))
ElseIf !Empty(Int_DspHe->NDHFRETMOE) // .OR.  Int_DspHe->NDHFRETTAX # 0
   EVAL(bMsg,STR0481+STR0544) //"VALOR DO FRETE SEM CADASTRO 
Endif

IF Int_DspHe->NDHSEGUVAL # 0

   SYF->( DbSetOrder( 3 ) )
   If (!EMPTY(Int_DspHe->NDHSEGUMOE) .AND. !SYF->(DbSeek(cFilSYF+Int_DspHe->NDHSEGUMOE))) .OR.;
      EMPTY(Int_DspHe->NDHSEGUMOE)
      EVAL(bMsg,STR0482+STR0544) //"MOEDA DO SEGURO SEMCADASTRO
   Endif
   SYF->( DbSetOrder( 1 ) )

   
   nRecNTX := Int_Dsptx->(RECNO())



   IF !EMPTY(Int_DspHe->NDHSEGUMOE) .and. Int_Dsptx->(DbSeek(Int_Dsphe->NDHHOUSE+Int_Dsphe->NDHSEGUMOE))

     IF !EMPTY(Int_DspHe->NDHSEGUTAX ) .AND. Int_DspHe->NDHSEGUTAX # Int_DspTx->NTXTAXA

       EVAL(bMsg,"Taxas Divergentes na Moeda de Seguro")
     ELSE 

       Int_DspHe->NDHSEGUTAX:=Int_DspTx->NTXTAXA
     ENDIF


   ELSEIF !EMPTY(Int_DspHe->NDHSEGUMOE) 


     IF  EMPTY(Int_DspHe->NDHSEGUTAX)  
        EVAL(bMsg,STR0483+STR0546) //"TAXA CONVERSAO SEGURO NAOINFORMADO
     ENDIF 

   ENDIF 



   Int_Dsptx->(DBGOTO(nRecNTX))

ElseIf !Empty(Int_DspHe->NDHSEGUMOE) //  .OR. Int_DspHe->NDHSEGUTAX # 0
      EVAL(bMsg,STR0484+STR0544) //"VALOR DO SEGURO SEMCADASTRO

Endif

//JAP - 04/09/2006                   
IF !Empty(Int_DspHe->NDHDI_NUM) // Número da di
   IF !Empty(Int_DspHe->NDHDTREGDI) //Data de Registro da DI
      IF !Empty(Int_DspHe->NDHDPAGIMP) //Data de pagamento dos Impostos
         IF Int_DspHe->NDHDPAGIMP > Int_DspHe->NDHDTREGDI 
            EVAL(bMsg,STR0771)
         ENDIF
      ENDIF
   ENDIF
//ELSE                                               
   //EVAL(bMsg,STR0772)  //Nopado por TRP em 01/04/08, pois o campo nro da DI não é obrigatório na montagem do txt.
ENDIF

// ISS - 12/04/10 - Ponto de entrada para a validar a necessidade de exibição das mensagens abaixo, STR0705 e STR0774
lIntFrt:= .T.
If EasyEntryPoint("EICIN100")
   ExecBlock("EICIN100",.F.,.F.,"ANTES_VALID")
EndIf   

//ASK 18/09/2007 - Validação para não integrar FRETE e SEGURO quando a nota fiscal já foi gerada.
SYF->( DbSetOrder( 3 ) )
If lVerifNota .AND. ( Int_DspHe->NDHFRETVAL # SW6->W6_VLFREPP .OR. Int_DspHe->NDHVLFRECC # SW6->W6_VLFRECC .OR.;
   Int_DspHe->NDHVLFRETN # SW6->W6_VLFRETN .OR. Int_DspHe->NDHFRETTAX # SW6->W6_TX_FRET .OR.;
   (SYF->(DbSeek(cFilSYF+Int_DspHe->NDHFRETMOE)),SYF->YF_MOEDA) # SW6->W6_FREMOED       .OR.;
   Int_DspHe->NDHSEGUVAL # SW6->W6_VL_USSE .OR. Int_DspHe->NDHSEGUTAX # SW6->W6_TX_SEG  .OR.;//Int_DspHe->NDHSEGUVAL # SW6->W6_VLSEGMN .OR. Int_DspHe->NDHSEGUTAX # SW6->W6_TX_SEG  .OR.; AOM - 12/01/10
   (SYF->(DbSeek(cFilSYF+Int_DspHe->NDHSEGUMOE)),SYF->YF_MOEDA) # SW6->W6_SEGMOED ) .AND. lIntFrt
     
   SWN->(DbSetOrder(3))
   //If SWN->(DbSeek(xFilial("SWN") + AvKey(Int_DspHe->NDHHOUSE,"WN_HAWB") + "1"))  AOM - 12/01/10
   If SWN->(DbSeek(xFilial("SWN") + AvKey(Int_DspHe->NDHHAWB,"WN_HAWB") + "1")) 
      EVAL(bMsg,STR0705) //"Processo já possui nota fiscal.
      EVAL(bMsg,STR0774) //"Não será possível alterar Frete/Seguro"
      EVAL(bMsg,"Processo:"+Int_DspHe->NDHHOUSE+"/ Nota Fiscal : "+SWN->WN_DOC)
   EndIf 
EndIf   
IF lMV_GRCPNFE //Campos novos NFE - AWR 05/11/2008
   IF !Empty(Int_DspHe->NDHHAWB)//Se esse campo NAO for branco, quer dizer que ACHOU o Processo
      IF !EMPTY(SW6->W6_DI_NUM) .OR. !Empty(Int_DspHe->NDHDI_NUM) // Número da di
         /*IF EMPTY(SW6->W6_LOCALN)                 // Nopado por GFP - 05/10/2012
            IF EMPTY(Int_DspHe->NDHLOCALN)
               EVAL(bMsg,"Local do desembaraco nao informado.")  
            ENDIF
         ENDIF*/
         IF EMPTY(SW6->W6_UFDESEM)
            IF EMPTY(Int_DspHe->NDHUFDESEM)
               EVAL(bMsg,"UF do desembaraco nao informada.")  
            ELSEIF !SX5->(DBSEEK(cFilSX5+"12"+Int_DspHe->NDHUFDESEM))
               EVAL(bMsg,"UF do desembaraco invalida: "+Int_DspHe->NDHUFDESEM)
            ENDIF
         ENDIF
      ENDIF
   ENDIF
ENDIF

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"VALDH")
ENDIF
Return .T.
*---------------------------------------------------------------------------------------------------*
FUNCTION IN100VerDD()
*---------------------------------------------------------------------------------------------------*

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"LERDD")
ENDIF


If !IN100CTD(Int_DspDe->NDDDPAGTO,.T.,'DDMMAAAA')                         //MJB-SAP-1100
   EVAL(bMsg,STR0485+STR0549) //"DATA PAGTO INVALIDO
Endif

If !SYB->(DbSeek(cFilSYB+Int_DspDe->NDDDESPESA))
   EVAL(bMsg,STR0486+STR0544) //"DESPESA SEMCADASTRO
Endif
// SVG - 19/04/2010 - Permitida a Inclusão de despesas zeradas
/*If Empty(Int_DspDe->NDDVALOR)
   EVAL(bMsg,STR0487+STR0546) //"VALOR PAGTO NAOINFORMADO
Endif
*/
If .Not. (Int_DspDe->NDDPAGOPOR $ "1,2")
   EVAL(bMsg,"Tipo de pagamento Invalido") //"VALOR PAGTO NAOINFORMADO
Endif                 
     
//ASK 19/11/2007 - Validação para não integrar despesas base de imposto quando o processo já possuir nota fiscal
//AAF 26/11/2007 - Verifica se tem nota primeira e o novo parâmetro.
SWN->(DbSetOrder(3))
SYB->(DBSETORDER(1))
If lVerifNota .AND. SUBS(Int_DspDe->NDDDESPESA,1,1) $ "34567";
   .AND. SYB->(DBSEEK(cFilSYB + Int_DspDe->NDDDESPESA));
   .AND. (SYB->YB_BASEIMP $ cSim .OR. SYB->YB_BASEICM $ cSim);
   .AND. SWN->(DbSeek(xFilial("SWN") + AvKey(Int_DspDe->NDDHOUSE,"WN_HAWB") + "1"))
   
   EVAL(bMsg, STR0775)//"Despesa não será integrada, "
   EVAL(bMsg, STR0776)// "pois o processo já possui Nota Fiscal"
EndIf

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"VALDD")
Endif
RETURN .T.
*----------------------------------------------------------------------------------------------*
FUNCTION In100GrvSWD(PHawb,PData,PDespesa,PValor,PDiferenca,PDespVar,PDataVar,PDespCheck, PVlrComp,pAdianta,pPagopor)
*--------------------------------------------------------------------------------------------------*
Local cAlias
Local cadianta := if(pAdianta == nil,"2" ,pAdianta)
Local cpagopor := if(ppagopor == nil,"2" ,ppagopor)
_CalcDespCamb := EasyGParam("MV_CAMBIL")
IF _CalcDespCamb
   RETURN
ENDIF
SWD->(DBSETORDER(1))

IF ! SWD->( DBSEEK(cFilSWD+PHawb+PDespesa) )
   IF PValor # 0
      IN100RecLock('SWD')
      SWD->WD_FILIAL  := cFilSWD
      SWD->WD_DESPESA := PDespesa
      SWD->WD_HAWB    := PHawb
      SWD->WD_DES_ADI := PData
      SWD->WD_VALOR_R := PValor
      SWD->WD_BASEADI := cAdianta
      SWD->WD_PAGOPOR := cPagopor
      //RMD - 30/08/12 - Tratamento da sequência da despesa para AvInteg
      If AvFlags("AVINT_FINANCEIRO_EIC")
	      SWD->WD_LINHA := DI500SWDLin(PHawb,PDespesa)
	  EndIf
   ENDIF

ELSE
   cAlias:=ALIAS()
   Reclock("SWD",.F.)
   DBSELECTAREA(cAlias)

   IF PValor # 0
      IF SWD->WD_DES_ADI # PData .OR. SWD->WD_VALOR_R # PValor 
         SWD->WD_DES_ADI := PData
         SWD->WD_VALOR_R := PValor
      ENDIF
   ELSE
      SWD->(DBDELETE())
   ENDIF

ENDIF

SWD->(MSUNLOCK())

IF lGrava
   IF ! SWD->(DBSEEK( cFilSWD+PHawb+PDespVar))
      IF PDiferenca # 0
         IN100RecLock('SWD')
         SWD->WD_FILIAL  := cFilSWD
         SWD->WD_DESPESA := PDespVar
         SWD->WD_HAWB    := PHawb
         SWD->WD_DES_ADI := PDataVar
         SWD->WD_VALOR_R := PDiferenca
         SWD->WD_BASEADI := cAdianta
         SWD->WD_PAGOPOR := cPagoPor
         //RMD - 30/08/12 - Tratamento da sequência da despesa para AvInteg
         If AvFlags("AVINT_FINANCEIRO_EIC")
	        SWD->WD_LINHA := DI500SWDLin(PHawb,PDespVar)
	     EndIf
      ENDIF
   ELSE
      cAlias:=ALIAS()
      Reclock("SWD",.F.)
      DBSELECTAREA(cAlias)

      IF PDiferenca # 0
         IF SWD->WD_DES_ADI # PDataVar  .OR.  SWD->WD_VALOR_R # PDiferenca
            SWD->WD_DES_ADI := PDataVar
            SWD->WD_VALOR_R := PDiferenca
         ENDIF
      ELSE
         SWD->(DBDELETE())
      ENDIF
   ENDIF

   SWD->(MSUNLOCK())
Else 
   PDiferenca:=0
ENDIF

If ! SWD->(DBSEEK(cFilSWD+PHawb+PDespCheck))
   IF PVlrComp # 0 .AND. (PVlrComp-PValor-PDiferenca) # 0
      IN100RecLock('SWD')
      SWD->WD_FILIAL  := cFilSWD
      SWD->WD_DESPESA := PDespCheck
      SWD->WD_HAWB    := PHawb
      SWD->WD_DES_ADI := PDataVar
      SWD->WD_VALOR_R := (PVlrComp-PValor-PDiferenca)
      SWD->WD_BASEADI := cAdianta
      SWD->WD_PAGOPOR := cPagopor
      //RMD - 30/08/12 - Tratamento da sequência da despesa para AvInteg
      If AvFlags("AVINT_FINANCEIRO_EIC")
         SWD->WD_LINHA := DI500SWDLin(PHawb,PDespCheck)
      EndIf
   ENDIF
ELSE
   cAlias:=ALIAS()
   Reclock("SWD",.F.)
   DBSELECTAREA(cAlias)

   IF PVlrComp # 0 .AND. (PVlrComp-PValor-PDiferenca) # 0
      IF SWD->WD_DES_ADI # PDataVar  .OR.  SWD->WD_VALOR_R # (PVlrComp-PValor-PDiferenca) 
         SWD->WD_DES_ADI := PDataVar
         SWD->WD_VALOR_R := (PVlrComp-PValor-PDiferenca) 
      ENDIF
   ELSE
      SWD->(DBDELETE())
   ENDIF
ENDIF

SWD->(MSUNLOCK())

RETURN

*---------------------------------------*
FUNCTION In100QuebraMensagem(lcMensagem)
*---------------------------------------*
Local cParte:="", i

For i:=1 to MlCount( lcMensagem, LEN_MSG ) + 1
   cParte += MemoLine( lcMensagem, LEN_MSG, i ) +  NewLine
Next

Return cParte

*-----------------*
FUNCTION IN100NU()
*-----------------*

ASIZE(TB_Cols,0)

AADD( TB_Cols, { {|| IN100Status()                      }, "", STR0036 } ) //"Status"
AADD( TB_Cols, { {|| Int_NU->NNUREFDES                  }, "", STR0436 } ) //"Nr. Processo"
AADD( TB_Cols, { {|| IN100CTD(Int_NU->NNUDCHEG,,'DDMMAAAA')}, "", STR0438 } ) //"Chegada" //MJB-SAP-1100
AADD( TB_Cols, { {|| IN100CTD(Int_NU->NNUDRECDOC,,'DDMMAAAA')}, "", STR0439 } ) //"Rec.Doc." //MJB-SAP-1100
AADD( TB_Cols, { {|| Int_NU->NNUDESP                    }, "", STR0440 } ) //"Despachante"
AADD( TB_Cols, { {|| Int_NU->NNUAGENTE                  }, "", STR0290 } ) //"Agente"
AADD( TB_Cols, { {|| Int_NU->NNUMASTER                  }, "", STR0452 } ) //"Master"
AADD( TB_Cols, { {|| Int_NU->NNUTIPODEC                 }, "", STR0453 } ) //"Tipo Decl."
AADD( TB_Cols, { {|| Int_NU->NNUURFDESP                 }, "", STR0454 } ) //"URF Despachos"
AADD( TB_Cols, { {|| Int_NU->NNUURFENTR                 }, "", STR0455 } ) //"URF Entrada"
AADD( TB_Cols, { {|| Int_NU->NNURECALFA                 }, "", STR0456 } ) //"Recinto Alf."
AADD( TB_Cols, { {|| Int_NU->NNUMODALDE                 }, "", STR0457 } ) //"Modalidade"
AADD( TB_Cols, { {|| Int_NU->NNUTIPOCON                 }, "", STR0458 } ) //"Tipo Proces."
AADD( TB_Cols, { {|| Int_NU->NNUTIPODOC                 }, "", STR0459 } ) //"Tipo Docto."
AADD( TB_Cols, { {|| Int_NU->NNUUTILCON                 }, "", STR0460 } ) //"Util. Proces."
AADD( TB_Cols, { {|| Int_NU->NNUIDENTIF                 }, "", STR0461 } ) //"Identifica‡„o"
AADD( TB_Cols, { {|| TRANSFORM(Val(Int_NU->NNUPESOBRU),cPict15_4) }, "", STR0329 } ) //"Peso Bruto"
AADD( TB_Cols, { {|| Int_NU->NNUNF_ENT                  }, "", STR0464 } ) //"Numero NFE"
AADD( TB_Cols, { {|| IN100CTD(Int_NU->NNUDT_ENTR,,"DDMMAAAA")}, "", STR0467 } ) //"Data Entrega" //MJB-SAP-1100
AADD( TB_Cols, { {|| Int_NU->NNU_OBS                    }, "", STR0468 } ) //"Observa‡Æo"
AADD( TB_Cols, { {|| IN100E_Msg(.T.)                    }, "", STR0112 } ) // "Mensagem"

ASIZE(TB_Col_D,0)

AADD( TB_Col_D, { {|| IN100Status()                         }, "", STR0036 } ) //"Status"
AADD( TB_Col_D, { {|| NDNDESPESA                            }, "", STR0469 } ) //"Despesa"
AADD( TB_Col_D, { {|| IN100CTD(NDNDPAGTO,,"DDMMAAAA")       }, "", STR0470 } ) //"Pagto." //MJB-SAP-1100
AADD( TB_Col_D, { {|| TRANSFORM(Val(NDNVALOR),cPict15_2)         }, "", STR0471 } ) //"Valor"
AADD( TB_Col_D, { {|| If(NDNPAGOPOR=="1", STR0440, STR0288) }, "", STR0472 } ) //"Pagador"
AADD( TB_Col_D, { {|| If(NDNADIANTA=="S", STR0096, STR0095) }, "", STR0673 } ) //"Adiantamento"
AADD( TB_Col_D, { {|| IN100E_MSG(.T.)                       }, "", STR0112 } ) //"Mensagem"

ASIZE(TBRCols,0)

AADD( TBRCols, { {|| Int_DN->(DbSeek(Int_DN->NDNREFDES)),IN100Status(),IN100Status()}, STR0036             } ) //"Status"
AADD( TBRCols, { {|| Int_NU->NNUREFDES                  }, STR0437 } ) //"Nr. Processo"
AADD( TBRCols, { {|| IN100CTD(Int_NU->NNUDCHEG,,"DDMMAAAA")}, STR0438 } ) //"Chegada" //MJB-SAP-1100
AADD( TBRCols, { {|| IN100CTD(Int_NU->NNUDRECDOC,,"DDMMAAAA")}, STR0439 } ) //"Rec.Doc." //MJB-SAP-1100
AADD( TBRCols, { {|| Int_NU->NNUDESP                    }, STR0440 } ) //"Despachante"
AADD( TBRCols, { {|| Int_NU->NNUAGENTE                  }, STR0290 } ) //"Agente"
AADD( TBRCols, { {|| Int_NU->NNUMASTER                  }, STR0452 } ) //"Master"
AADD( TBRCols, { {|| Int_NU->NNUTIPODEC                 }, STR0453 } ) //"Tipo Decl."
AADD( TBRCols, { {|| Int_NU->NNUURFDESP                 }, STR0454 } ) //"URF Despachos"
AADD( TBRCols, { {|| Int_NU->NNUURFENTR                 }, STR0455 } ) //"URF Entrada"
AADD( TBRCols, { {|| Int_NU->NNURECALFA                 }, STR0456 } ) //"Recinto Alf."
AADD( TBRCols, { {|| Int_NU->NNUMODALDE                 }, STR0457 } ) //"Modalidade"
AADD( TBRCols, { {|| Int_NU->NNUTIPOCON                 }, STR0458 } ) //"Tipo Proces."
AADD( TBRCols, { {|| Int_NU->NNUTIPODOC                 }, STR0459 } ) //"Tipo Docto."
AADD( TBRCols, { {|| Int_NU->NNUUTILCON                 }, STR0460 } ) //"Util. Proces."
AADD( TBRCols, { {|| Int_NU->NNUIDENTIF                 }, STR0461 } ) //"Identifica‡„o"
AADD( TBRCols, { {|| TRANSFORM(Val(Int_NU->NNUPESOBRU),cPict15_4) }, STR0329 } ) //"Peso Bruto"
AADD( TBRCols, { {|| Int_NU->NNUNF_ENT                  }, STR0464 } ) //"Numero NFE"
AADD( TBRCols, { {|| IN100CTD(Int_NU->NNUDT_ENTR,,"DDMMAAAA")}, STR0467 } ) //"Data Entrega" //MJB-SAP-1100
AADD( TBRCols, { {|| Int_NU->NNU_OBS                    }, STR0468 } ) //"Observa‡Æo"
IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"COLNU")
ENDIF
AADD( TBRCols, { {|| IN100E_Msg(.T.)                    }, STR0112 } ) // "Mensagem"

bMessage:=FIELDWBLOCK('NNUMSG',SELECT('Int_NU'))
bStatus :={|x| if(x=nil,Int_NU->NNUINT_OK="T",Int_NU->NNUINT_OK:=x)}

RETURN .T.

*------------------------------------------------------------------------------------------*
FUNCTION IN100LerNU()
*------------------------------------------------------------------------------------------*
LOCAL lDetMsg:=.F.
Local aOrd := SaveOrd("SYU")
Local cDspDEPARA := "", nREc := 0
IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"LERNU")
ENDIF
SYU->(DbSetOrder(2))
SY4->(DbSetOrder(1))    //NCF - 30/06/2010
/*If Select("EIC") <= 0
   EVAL(bMsg,STR0706) // "Arquivo de solicitação de numerário não está disponível, entre em contato com o suporte Average"
EndIf*/

SW6->(dbSetOrder(9))
If !SW6->(DbSeek(cFilSW6+Left(Int_NU->NNUREFDES,LEN(SW6->W6_REF_DES))))                               //MJB-SAP-0401
   EVAL(bMsg,STR0475+STR0544) //"REF.DESPACHANTE SEMCADASTRO
Endif
SW6->(dbSetOrder(1))

If Empty(Int_NU->NNUDESP)                                                 //MJB-SAP-0201
   EVAL(bMsg,STR0477+STR0546) //"DESPACHANTE NAOINFORMADO                 //MJB-SAP-0201
Else

   //NCF - 11/11/2016 - Verificação condicionada ao tamanho do campo e uso da tabela DE/PARA
   aDspch := GetDpTabDP(Int_NU->NNUDESP,Int_NU->NNUREFDES)
   nIgual := Len(aDspch)
   If nIgual == 1
      cDspDEPARA := aDspch[1][1]
      nRec       := aDspch[1][2]
      SW6->(DbGoTo(nRec))  
   EndIf 

   if !SY5->(DbSeek(cFilSY5 + avKey( If( Empty(cDspDEPARA),Int_NU->NNUDESP,cDSPDEPARA), "Y5_COD" )))
      EVAL(bMsg,STR0477+STR0544) //"DESPACHANTE SEMCADASTRO
   endif

Endif

If !Empty(Int_NU->NNUAGENTE) .And. !SY4->(DbSeek(cFilSY4+Int_NU->NNUAGENTE)) //MJB-SAP-0201

   //CCH - 28/08/2009 - Verificação do agente GipLite na tabela De/Para e no Cadastro de Agentes
   If !SYU->(DbSeek(xFilial("SYU")+If(Empty(cDspDEPARA),Int_NU->NNUDESP,cDspDEPARA)+"3"+Int_NU->NNUAGENTE)) .or. !SY4->(DbSeek(cFilSY4+Alltrim(SYU->YU_EASY))) 
      EVAL(bMsg,STR0478+STR0544) //Agente sem Cadastro
   Else  //SVG - 05/10/2010 - Grava o Agente da tabela de/para para o agente do arquivo de integração
      Int_NU->NNUAGENTE:= Alltrim(SYU->YU_EASY)
   EndIf   
   
Endif

IF(Int_NU->NNUDCHEG=="00000000",Int_NU->NNUDCHEG:="",)//AWR-SAP 22/2/2001
If !Empty(Alltrim(Int_NU->NNUDCHEG)) .AND. !IN100CTD(Int_NU->NNUDCHEG,.T.,"DDMMAAAA") //MJB-SAP-1100
   EVAL(bMsg,STR0675+STR0549) //"DATA DE CHEGADA INVALIDA
Endif

IF(Int_NU->NNUDRECDOC=="00000000",Int_NU->NNUDRECDOC:="",)//AWR-SAP 22/2/2001
If !Empty(Alltrim(Int_NU->NNUDRECDOC)) .AND. !IN100CTD(Int_NU->NNUDRECDOC,.T.,"DDMMAAAA") //MJB-SAP-1100
   EVAL(bMsg,STR0676+STR0549) //"Data de Receb. Docs. INVALIDA
Endif

If ! Empty(Alltrim(Int_NU->NNUURFDESP)) .AND. !SJ0->(DbSeek(cFilSJ0+Strzero(Val(Int_NU->NNUURFDESP),7,0)))
   EVAL(bMsg,STR0454+STR0544) //"URF DESPACHO SEMCADASTRO
Endif

If ! Empty(Alltrim(Int_NU->NNUURFENTR)) .AND. !SJ0->(DbSeek(cFilSJ0+Strzero(Val(Int_NU->NNUURFENTR),7,0)))
   EVAL(bMsg,STR0455+STR0544) //"URF ENTREGA SEMCADASTRO
Endif

If ! Empty(Alltrim(Int_NU->NNURECALFA)) .AND. !SJA->(DbSeek(cFilSJA+Int_NU->NNURECALFA))
   EVAL(bMsg,STR0456+STR0544) //"Recinto Alf. SEMCADASTRO
Endif

If !EMPTY(Int_NU->NNUTIPOCON) .AND. !SX5->(DBSEEK(cFilSX5+"47"+Int_NU->NNUTIPOCON))
   EVAL(bMsg,STR0458+STR0544) //"Tipo Proces. SEMCADASTRO
Endif                   

IF ! EMPTY(ALLTRIM(Int_NU->NNUPESOBRU)) .AND. IN100NaoNum(Int_NU->NNUPESOBRU)
   EVAL(bmsg,STR0329+STR0549)  // Peso Bruto INVALIDO
ENDIF

IF(Int_NU->NNUDT_ENTR=="00000000",Int_NU->NNUDT_ENTR:="",)//AWR-SAP 22/2/2001

If !Empty(Alltrim(Int_NU->NNUDT_ENTR)) .AND. !IN100CTD(Int_NU->NNUDT_ENTR,.T.,"DDMMAAAA") //MJB-SAP-1100
   EVAL(bMsg,STR0677+STR0549) //"Data de Entrega da Merc. INVALIDA
Endif              

IF !Empty(Int_NU->NNUTIPODOC) .AND. (ISALPHA(ALLTRIM(Int_NU->NNUTIPODOC)) .OR. VAL(Int_NU->NNUTIPODOC) < 0 .OR. VAL(Int_NU->NNUTIPODOC) > 5)
   EVAL(bMsg,AVSX3("W6_TIPODOC",5)+STR0549)
ENDIF

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"VALNU")
ENDIF

IN100VerErro(cErro,cAviso)
cErro:=cAviso:=NIL   // limpa mensagens geradas para o Int_NU

INT_DN->(dbSeek(INT_NU->NNUREFDES))

While !(INT_DN->(Eof())) .And. INT_NU->NNUREFDES == INT_DN->NDNREFDES

   IF EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"LERDN")
   ENDIF

   If !IN100CTD(INT_DN->NDNDPAGTO,.T.,"DDMMAAAA") //MJB-SAP-1100
      EVAL(bMsg,STR0485+STR0549) //"DATA PAGTO INVALIDO
   Endif
                        
   If !SYB->(DbSeek(cFilSYB+INT_DN->NDNDESPESA))
      EVAL(bMsg,STR0486+STR0544) //"DESPESA SEMCADASTRO
   Endif

   If Empty(INT_DN->NDNVALOR)
      EVAL(bMsg,STR0487+STR0546) //"VALOR PAGTO NAOINFORMADO
   ElseIf IN100NaoNum(INT_DN->NDNVALOR)
      EVAL(bmsg,STR0487+STR0549,.T.)  // VALOR PAGTO INVALIDO
   Endif

   If Empty(INT_DN->NDNPAGOPOR)
      EVAL(bMsg,STR0678+STR0546) //"Pago Por NAOINFORMADO
   ElseIf ! INT_DN->NDNPAGOPOR $ ('1/2')
      EVAL(bmsg,STR0678+STR0549)  //"Pago Por INVALIDO
   Endif

   If Empty(INT_DN->NDNADIANTA)
      EVAL(bMsg,STR0673+STR0546) //"Adiantamento NAOINFORMADO
   ElseIf ! INT_DN->NDNADIANTA $ ('S/N')
      EVAL(bmsg,STR0673+STR0549)  //"Adiantamento INVALIDO
   Endif

   IF EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"VALDN")
   ENDIF

   IF cErro # NIL
      Int_DN->NDNMSG:=cErro ; cErro:= NIL ; lDetMsg:=.T. ; cAviso:= NIL
      Int_DN->NDNINT_OK := "F"
   ELSE
      Int_DN->NDNINT_OK := "T"
      IF cAviso # NIL
         Int_DN->NDNMSG:=cAviso ; cAviso:= NIL
      ENDIF
   ENDIF

   INT_DN->(dbSkip())
EndDo

IF lDetMsg 
   Int_NU->NNUINT_OK := "F"
ENDIF

IF EMPTY(ALLTRIM(Int_NU->NNUMSG)) .AND. lDetMsg
   Int_NU->NNUMSG :=STR0679 //".....Vide Despesas"
ENDIF

IF Int_NU->NNUINT_OK = "T"
   nResumoCer+=1
ELSE
   nResumoErr+=1
ENDIF

RestOrd(aOrd,.T.)

RETURN Int_NU->NNUINT_OK

*--------------------*
FUNCTION IN100GrvNU()
*--------------------*
SW6->(dbSetOrder(9))
SW6->(DbSeek(cFilSW6+Left(Int_NU->NNUREFDES,LEN(SW6->W6_REF_DES))))                                   //MJB-SAP-0401
SW6->(dbSetOrder(1))

SY5->(DBSetOrder(1)) //Y5_FILIAL+Y5_COD

Reclock("SW6",.F.)
If(!Empty(Int_NU->NNUDCHEG)  ,SW6->W6_CHEG     := IN100CTD(Int_NU->NNUDCHEG,,"DDMMAAAA"),) //MJB-SAP-1100
If(!Empty(Int_NU->NNUDRECDOC),SW6->W6_DTRECDOC := IN100CTD(Int_NU->NNUDRECDOC,,"DDMMAAAA"),) //MJB-SAP-1100
If(!Empty(Int_NU->NNUDESP) .And. Len(Int_NU->NNUDESP) == AVSX3("W6_DESP",AV_TAMANHO),SW6->W6_DESP := Int_NU->NNUDESP,)//NCF - 27/12/2016
If(!Empty(Int_NU->NNUAGENTE) ,SW6->W6_AGENTE   := Int_NU->NNUAGENTE,)
If(!Empty(Int_NU->NNUMASTER) ,SW6->W6_MAWB     := Int_NU->NNUMASTER,)
If(!Empty(Int_NU->NNUTIPODEC),SW6->W6_TIPODES  := Alltrim(StrZero(Val(Int_NU->NNUTIPODEC),2,0)),)
If(!Empty(Int_NU->NNUURFDESP),SW6->W6_URF_DES  := Strzero(Val(Int_NU->NNUURFDESP),7,0),)
If(!Empty(Int_NU->NNUURFENTR),SW6->W6_URF_ENT  := Strzero(Val(Int_NU->NNUURFENTR),7,0),)
If(!Empty(Int_NU->NNURECALFA),SW6->W6_REC_ALF  := Int_NU->NNURECALFA,)
If(!Empty(Int_NU->NNUMODALDE),SW6->W6_MODAL_D  := IF(VAL(Int_NU->NNUMODALDE)=0,'1',Int_NU->NNUMODALDE),)
If(!Empty(Int_NU->NNUTIPOCON),SW6->W6_TIPOCON  := STRZERO(Val(Int_NU->NNUTIPOCON),2,0),)
If(!Empty(Int_NU->NNUTIPODOC),SW6->W6_TIPODOC  := STR(Val(Int_NU->NNUTIPODOC),1),)
If(!Empty(Int_NU->NNUUTILCON),SW6->W6_UTILCON  := Int_NU->NNUUTILCON,)
If(!Empty(Int_NU->NNUIDENTIF),SW6->W6_IDEMANI  := Int_NU->NNUIDENTIF,)
If(!Empty(Int_NU->NNUPESOBRU),SW6->W6_PESO_BR  := Val(Int_NU->NNUPESOBRU),)
If(!Empty(Int_NU->NNUNF_ENT) ,SW6->W6_FAT_DES  := Int_NU->NNUNF_ENT,)
If(!Empty(Int_NU->NNUDT_ENTR),SW6->W6_DT_ENTR  := IN100CTD(Int_NU->NNUDT_ENTR,,"DDMMAAAA"),) //MJB-SAP-1100

//posicionar o despachante
SY5->(DBSeek(xFilial() + SW6->W6_DESP))

INT_DN->(dbSeek(INT_NU->NNUREFDES))

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"GRVNU")
ENDIF

EIC->(dbSeek(cFilEIC+SW6->W6_HAWB))
DO While !(EIC->(Eof())) .And. EIC->EIC_FILIAL+EIC->EIC_HAWB ==;
    cFilEIC+SW6->W6_HAWB
   If Empty(EIC->EIC_DT_EFE)
      Reclock("EIC",.F.)
      EIC->(DbDelete())
      EIC->(MsUnLock())
   EndIf
   EIC->(dbSkip())
EndDo

If Type("bUpDate") <> "B"
   bUpDate:= Nil
EndIf

DO While !(INT_DN->(Eof())) .And. INT_NU->NNUREFDES == INT_DN->NDNREFDES

   nAlias :=Select("EIC")

   EIC->(DbSeek(cFilEIC+SW6->W6_HAWB))
   scAlias:=ALIAS()

   IN100RecLock("EIC")

   Eval(FieldwBlock("EIC_FILIAL" ,nAlias), cFilEIC )
   Eval(FieldwBlock("EIC_HAWB"   ,nAlias),SW6->W6_HAWB)
   Eval(FieldwBlock("EIC_DT_DES" ,nAlias),IN100CTD(Int_DN->NDNDPAGTO,,"DDMMAAAA")) //MJB-SAP-1100
   Eval(FieldwBlock("EIC_DESPES" ,nAlias),Int_DN->NDNDESPESA)
   Eval(FieldwBlock("EIC_VALOR"  ,nAlias),Val(Int_DN->NDNVALOR))
   Eval(FieldwBlock("EIC_PAGOPO" ,nAlias),Int_DN->NDNPAGOPOR)
   Eval(FieldwBlock("EIC_ARQ"    ,nAlias),Upper(Int_Param->NPAARQ_NU))
  	Eval(FieldwBlock("EIC_USER"   ,nAlias),__CUSERID)//Upper(AllTrim(Substr(cUsuario,7,15))))AWR 06/03/2001

   If EMPTY(ALLTRIM(Int_DN->NDNADIANTA)) .OR. ! ALLTRIM(Int_DN->NDNADIANTA) $ 'SN'
      IF Int_DN->NDNPAGOPOR = "1"
         Eval(FieldwBlock("EIC_BASEAD",nAlias),"1")
      ENDIF    
   Else
      Eval(FieldwBlock("EIC_BASEAD",nAlias),If(Int_DN->NDNADIANTA=="S", "1", "2"))
   EndIf
   //NCF - 13/10/2010 - Grava Fornecedor e Loja do Despachante
   Eval(FieldwBlock("EIC_FORN" ,nAlias),SY5->Y5_FORNECE)
   Eval(FieldwBlock("EIC_LOJA" ,nAlias),SY5->Y5_LOJAF  )
   
   IF EasyEntryPoint("IN100CLI")
       ExecBlock("IN100CLI",.F.,.F.,"GRVDN") //Grava demais campos dos itens do numerario
   ENDIF
   DBSELECTAREA(scAlias)    // Volta a area que foi trocada por RecLock().

   
   //IAC 23/12/2010
   IF valtype(bUpDate)=="B"
      oldcfuncao:=cfuncao
      cfuncao   :="DN"
      If FindFunction("AvIntExtra")
         EasyExRdm("AvIntExtra")
      EndIf
      cfuncao   :=oldcfuncao
   ENDIF

   EIC->(MsUnlock())

   Int_DN->(DbSkip())

Enddo

SW6->(MsUnlock())
//DbCommitAll()

//FDR - 22/01/13
IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"WORKFLOW")
ENDIF

RETURN .T.

************************************** IMPRESSAO *******************************
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±³Fun‡„o   ³IN100Inicio_Print³ Autor ³ Victor Iotti         ³ Data ³ 16.05.97 ³±
±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±³Descri‡„o³ Impressao da Integracao do PO / SI                               ³±
±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±³Uso      ³ SIGAEIC                                                          ³±
±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
FUNCTION IN100Inicio_Print(cTit)
LOCAL   nInd, cAreaH:='Int_', cAreaD:='Int_'

LOCAL wnrel    := If(cModulo="EIC","EICIN100",If(cModulo="EDC","EDCIN100","EECIN100"))
LOCAL cDesc1   := STR0488 //"Emissao da Integracao do P.O."
LOCAL cDesc2   := " "
LOCAL cDesc3   := " "
LOCAL cString  := 'Int_'+cFuncao
LOCAL bTit, bCab, bDet, bKeyDet, bWhile, nAuxI

PRIVATE nComprimido := EasyGParam("MV_COMP"), aRelIN100Cli:={}
PRIVATE tamanho :="G"
PRIVATE Titulo  :=STR0489 //"Integracao do P.O."
PRIVATE aReturn := { STR0016, 1,STR0017, 2, 2, 1, cValid, nOrem } //"Zebrado"###"Importa‡Æo"
PRIVATE nomeprog:="EICIN100",nLastKey := 0,nBegin:=0,aLinha:={ }
PRIVATE aDriver :=ReadDriver()
PRIVATE lPrimeiro:=.F., cCabec1, cCabec2, nTotReg, nTamCab
PRIVATE cPI1 := AVSX3("EEM_VLNF"  ,AV_PICTURE),;   //  By JPP - 23/05/2005 - 9:30 - Definição das Pictures 
      cPI2 := AVSX3("EEM_VLMERC",AV_PICTURE),;
      cPI3 := AVSX3("EEM_VLFRET",AV_PICTURE),;
      cPI4 := AVSX3("EEM_VLSEGU",AV_PICTURE),;
      cPI5 := AVSX3("EEM_OUTROS",AV_PICTURE)
      

IF cFuncao = CAD_SI
   cAreaH +='SI'
   cAreaD +='IS'
   bTit   :={|| SWU->(DBSEEK(cFilSWU+Int_SI->NSIMODELO)),IN100TitSI(cTit) }
   bCab   :={|| IN100CabSI() }
   bDet   :={|| IN100DetSI(cTit) }
   bKeyDet:={|| Int_SI->NSI_CC+Int_SI->NSI_NUM+Int_SI->NSISEQ_SI }
   bWhile :={|| Int_IS->NISCC     == Int_SI->NSI_CC  .AND. ;
                Int_IS->NISSI_NUM == Int_SI->NSI_NUM .AND. ;
                Int_IS->NISSEQ_SI == Int_SI->NSISEQ_SI}
   cCabec1:= STR0490 //"Emissao da Integracao da S.I."
   cCabec2:= ""
   cDesc1 := STR0490 //"Emissao da Integracao da S.I."
   nTamCab:= 9
   TITULO := STR0021 + "S.I."
ElseIf cFuncao = CAD_IT
   cAreaH +='IT'
   cAreaD +='ID'
   bTit   :={||STR0021+STR0042,IN100TitIT(cTit)}
   bCab   :={|| IN100CabIT() }
   bDet   :={|| IN100DetID(cTit) }
   bKeyDet:={|| Int_IT->NITCOD_I }
   bWhile :={|| Int_ID->NIDCOD_I == Int_IT->NITCOD_I }
   cCabec1:= STR0045  // "Emissão da Integração de Item"
   cCabec2:= ""
   nTamCab:= 9
ElseIf cFuncao = CAD_PE
   cAreaH +='PE'
   cAreaD +='PD'
   cTIT   := STR0707
   bTit   :={|| STR0707,IN100TitPE(cTit) }
   bCab   :={|| IN100CabPE() }
   bDet   :={|| IN100DetPE(cTit)  }
   bKeyDet:={|| Int_PE->NPEPEDIDO + Int_PE->NPESEQ }
   bWhile :={|| Int_PE->NPEPEDIDO + Int_PE->NPESEQ == Int_PD->NPDPEDIDO+Int_PD->NPDSEQ}
   cCabec1:= STR0046  // "Emissão da Integração do Processo"
   cCabec2:= ""
   nTamCab:= 18
   TITULO := cDESC1 := STR0707
   //wnrel:=SetPrint(cString,wnrel,"",@Titulo,cDesc1,cDesc2,cDesc3,.F.,,.T.,Tamanho,,.F.)
ElseIf cFuncao = CAD_PO
   cAreaH +='PO'
   cAreaD +='IP'
   bTit   :={|| SWU->(DBSEEK(cFilSWU+Int_PO->NPOMODELO)),IN100TitPO(cTit) }
   bCab   :={|| IN100CabPO() }
   bDet   :={|| IN100DetPO(cTit) }
   bKeyDet:={|| Int_PO->NPOPO_NUM+Int_PO->NPOSEQ_PO }
   bWhile :={|| Int_PO->NPOPO_NUM == Int_IP->NIPPO_NUM .AND.;
                Int_PO->NPOSEQ_PO == Int_IP->NIPSEQ_PO}
   cCabec1:= STR0491 //"Emissao da Integracao da P.O."
   cCabec2:= ""
   nTamCab:= 18
ElseIf cFuncao = CAD_NU
                        Private nTotDesp := 0
   cAreaH +='NU'
   cAreaD +='DN'
   cDesc1 := STR0681 //"Emissao da Integracao do numerário"
   cDesc2 := " "
   cDesc3 := " "
   cCabec1:= STR0681 //"Emissao do Recebimento do numerário"
   cCabec2:= ""
   nTamCab:= 18              
   nLinhas:= 80
   tamanho:= " "
   Titulo := STR0021+STR0672
   bTit   :={|| IN100TitNU(STR0672) }
   bCab   :={|| IN100CabNU() }
   bDet   :={|| IN100DetNU(cTit) }
   bKeyDet:={|| Int_NU->NNUREFDES }
   bWhile :={|| (!(Int_DN->(Eof())) .And. Int_NU->NNUREFDES == Int_DN->NDNREFDES)}
ElseIf cFuncao = CAD_DE
   cAreaH +='DspHe'
   cAreaD +='DspDe'
   nLinhas:= 80
   tamanho :="P"
   nComprimido := 1
   bTit    :={||IN100TitDE(cTit) }
   bCab    :={||IN100CabDe() }
   bDet    :={||IN100DetDe(cTit) }   
   bMessage:=FIELDWBLOCK('NDHMSG',SELECT('Int_DspHe'))
   bStatus :={|x| if(x=nil,Int_DspHe->NDHINT_OK="T",Int_DspHe->NDHINT_OK:=x)}
   bKeyDet :={||Int_DspHe->NDHHOUSE}
   bWhile  :={||Int_DspHe->NDHHOUSE == Int_DspDe->NDDHOUSE}
   cCabec1:= STR0718 //"Emissao da Integracao Desp. Despachante"
   cCabec2:= ""
   cDesc1 := STR0718 //"Emissao da Integracao Desp. Despachante"
   nTamCab:= 9
   cString:= "Int_DspHe"
   TITULO := STR0021 + "Despesas do Despachante"   
ElseIf cFuncao = CAD_NC    // By JPP - 23/05/2005 - 9:30 - Criação do relatorio de Integração de notas fiscais de saída. 
   cAreaH +='NC'
   cAreaD +='ND'
   cTIT   := STR0766 // "Integração Notas Fiscais de Saída"
   bTit   :={|| STR0767,IN100TitNC(cTit) } // "Notas Fiscais de Saída"
   bCab   :={|| IN100CabNC() }
   bDet   :={|| IN100DetNC(cTit)  }
   bKeyDet:={|| INT_NC->NNCPRO+INT_NC->NNCSER+INT_NC->NNCNF }  
   bWhile :={|| INT_NC->NNCPRO+INT_NC->NNCSER+INT_NC->NNCNF == INT_ND->NNDPRO+INT_ND->NNDSER+INT_ND->NNDNF}
   cCabec1:= STR0767 // "Notas Fiscais de Saída"
   cCabec2:= ""
   nTamCab:= 18
   TITULO := cDESC1 := STR0767 // "Notas Fiscais de Saída"
EndIf                        

If EasyEntryPoint("IN100CLI") 
   ExecBlock("IN100CLI",.F.,.F.,"RELATO")
   For nAuxI:=1 TO LEN(aRelIN100Cli)
       Eval(MEMVARBLOCK(aRelIN100Cli[nAuxI,1]),aRelIN100Cli[nAuxI,2])
   Next
EndIf
                            
nTotReg:=(cAreaH)->(Easyreccount(cAreaH))
(cAreaH)->(DBGOTOP())
IF nTotReg = 0
   IN_MSG(STR0492,STR0039) //"N„o h  registros a serem impressos."###"Informação"
   RETURN .F.
ENDIF

wnrel:=SetPrint(cString,wnrel,"",@Titulo,cDesc1,cDesc2,cDesc3,.F.,,.T.,Tamanho,,.F.)

If nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

RptStatus({|lEnd| IN100RelSIPO(cTit,cAreaD,@lEnd,wnRel,cString,bTit,bCab,bDet,bKeyDet,bWhile,cAreaH)},Titulo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
   Set Printer TO
   Commit
   OurSpool(wnrel)
Endif
MS_FLUSH()
SET FILTER TO
Return

*-----------------------------------------------------------------------------
FUNCTION IN100RelSIPO(cTit,cAreaD,lEnd,wnRel,cString,bTit,bCab,bDet,bKeyDet,bWhile,cAreaH)
*-----------------------------------------------------------------------------
LOCAL nLinha
M_Pag:= 1
Limite:=130
Li:= 80

SetRegua(nTotReg)

If aReturn[4] == 1                              // Comprimido
   @ 001,000 PSAY &(aDriver[1])
ElseIf aReturn[4] == 2                          // Normal
   @ 001,000 PSAY &(aDriver[2])
EndIf

DBSELECTAREA(cAreaH)
DBGOTOP()
DBEVAL( {|| IN100PrintSIPO(cAreaD,bTit,bCab,bDet,bKeyDet,bWhile,@lEnd,wnRel,cString,cAreaH) } )
DBGOTOP()
(cAreaD)->(DBGOTOP())

IF Li != 80
   Li++
   roda(0,"",tamanho)
End
(cAreaD)->(DBGOTOP())

RETURN .T.

*--------------------------------------------------------------------------------------
FUNCTION IN100PrintSIPO(cAreaD,bTit,bCab,bDet,bKeyDet,bWhile,lEnd,wnRel,cString,cAreaH)
*--------------------------------------------------------------------------------------
LOCAL cKeyDet:=EVAL(bKeyDet)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a Regua                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IncRegua()
DBSELECTAREA(cAreaH)
If &(cValid)
   IF (Li+nTamCab) > 55
      EVAL(bTit)
   ELSE
      //135
      @ Li++,001 PSAY REPLI("=",135)
      EVAL(bCab)
   ENDIF
   (cAreaD)->(DBSEEK(cKeyDet))
   (cAreaD)->(DBEVAL(bDet,,bWhile))
EndIf
RETURN .T.

*-----------------------------------------------------------------------------
FUNCTION IN100RelMsg()
*-----------------------------------------------------------------------------
LOCAL nInd, nLinMsg, nColMsg, cMessage, nTotLin, nLin1

IF lPrimeiro
   lPrimeiro:=.F.
   RETURN .T.
ENDIF

nLin1  :=1
nColMsg:=20
nLinMsg:=Li

cMessage:=ALLTRIM(EVAL(bMessage))
nTotLin :=MLCOUNT(cMessage,LEN_MSG)

FOR nInd:=nLin1 TO nTotLin
    If ! EMPTY(ALLTRIM(MEMOLINE(cMessage,LEN_MSG,nInd)))
       @ nLinMsg++,nColMsg PSAY MEMOLINE(cMessage,LEN_MSG,nInd)
    Endif
NEXT

Li:=nLinMsg

RETURN .T.

*-----------------------------------------------------------------------------
FUNCTION IN100TitPO(cTit,lEnd)
*-----------------------------------------------------------------------------
Cabec(cTit,cCabec1,cCabec2,nomeprog,tamanho,nComprimido)

*TIPO.............: INCLUSAO
*Modelo Utilizado.: xx xxxxxxxxxxxxxxxxxxxx           Data Integracao..: xx/xx/xx
*No. P.O..........: xxxxxxxxxxxxxxx                   Data P.O.........: xx/xx/xx
*Local de Entrega.: xx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx Comprador........: xx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*Via/Origem/Dest..: xx / xx / xx                      Cond Pagto /Dias : x.x.xxx / xxx
*Agente...........: xx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx Importador.......: xx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*Inland Charg.....: 999999999999.99                   Packing Charg....: 999999999999.99
*Desconto.........: 999999999999.99                   Int'l Freight....: 999999999999.99
*Tipo de Frete....: xx                                Consignatario....: xx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*Fornecedor.......: 123456 xxxxxxxxxxxxxxxxxxxxxxxxxx Proforma / Data..: 123456789012345 / ddmmaa
*Paridade / Data..: 123456.123456 / ddmmaa            Peso Bruto.......: 123456789.123
*Cliente..........: 123456 xxxxxxxxxxxxxxxxxxxxxxxxxx Agente...........: xxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*FOB..............: xxx 9,999,999,999.9999            Incoterms........: xxxxxxxxx
*Mensagem.........: 20                                54
*-----------------------------------------------------------------------------*
*Item                           C.C./S.I.     Fabric    Quantidade Embarque Entrega  Preco Unitario Tipo Material 2o.Fab 3o.Fab 4o.Fab 5o.Fab 6o.Fab Mensagem
*------------------------------ ------------- ------ ------------- -------- ------- --------------- ------------- ------ ------ ------ ------ ------ ---------------------------------------
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 12345-1234/56 123456 123456789,012  ddmmaa  ddmmaa  123456789.12345 xxxxxxxxxxxxx 123456 123456 123456 123456 123456 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*1                              32            46     53             68      76      84              100           114    121    128    135    142    149
//SO.:0026 OS.:0232 FCD
*Item                           C.C./S.I.                       Fabric    Quantidade Embarque Entrega  Preco Unitario Tipo Material     2o.Fab     3o.Fab     4o.Fab     5o.Fab     6o.Fab Mensagem
*------------------------------ --------------------------- ---------- ------------- -------- ------- --------------- ------------- ---------- ---------- ---------- ---------- ---------- ---------------------------------------
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 1234567890-1234/56789012345 1234567890 123456789,012  ddmmaa  ddmmaa  123456789.12345 xxxxxxxxxxxxx 1234567890 1234567890 1234567890 1234567890 1234567890 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*1                              32              48          60         71             86      94      102             118           132        143        154        165        176        187                                   225

SY2->(DBSEEK(cFilSY2+Int_PO->NPO_POLE))
SYT->(DBSEEK(cFilSYT+Int_PO->NPOIMPORT))
SA2->(DBSEEK(cFilSA2+Int_PO->NPOFORN))
SA1->(DBSEEK(cFilSA1+Int_PO->NPOCLIENTE))
SY4->(DBSEEK(cFilSY4+Int_PO->NPOAGENTE))

IN100CabPO()
RETURN .T.

*-----------------------------------------------------------------------------
FUNCTION IN100CabPO()
*-----------------------------------------------------------------------------
LOCAL cStatus:=IF(EVAL(bStatus),STR0493,STR0494) //"ACEITO"###"REJEITADO"
LOCAL cStaItem:=IF(Int_PO->NPOTIPO='A',IF(Int_PO->NPOITEM_OK = "T","",STR0495),"") //"              PO POSSUI ITEM REJEITADO"

SY2->(DBSEEK(cFilSY2+Int_PO->NPO_POLE))
SYT->(DBSEEK(cFilSYT+Int_PO->NPOIMPORT))
SA2->(DBSEEK(cFilSA2+Int_PO->NPOFORN))
SA1->(DBSEEK(cFilSA1+Int_PO->NPOCLIENTE))
SY4->(DBSEEK(cFilSY4+Int_PO->NPOAGENTE)) 
SY1->(DBSEEK(cFilSY1+Int_PO->NPOCOMPRA))//FDR - 27/02/2012

@ Li++,001 PSAY STR0496+IN100TIPO()+"  /  "+cStatus+cStaItem //"TIPO /  Status...: "

Li++
@ Li,001 PSAY STR0497+SWU->WU_DESCR //"Modelo Utilizado.: "
@ Li,054 PSAY STR0498+DTOC(IN100CTD(EVAL(bDtInteg))) //"Data Integracao..: "

Li++
@ Li,001 PSAY STR0499+TRANSFORM(Int_PO->NPOPO_NUM,_PictPO) //"No. P.O..........: "
@ Li,054 PSAY STR0500+DTOC(IN100CTD(Int_PO->NPOPO_DT)) //"Data P.O.........: "

Li++
@ Li,001 PSAY STR0501+Int_PO->NPO_POLE+" "+SY2->Y2_DESC //"Local de Entrega.: "
@ Li,054 PSAY STR0502+Int_PO->NPOCOMPRA+" "+SY1->Y1_NOME //"Comprador........: "

Li++
@ Li,001 PSAY STR0503+Int_PO->NPOTIPO_EM+" / "+Int_PO->NPOORIGEM+" / "+Int_PO->NPODEST //"Via/Origem/Dest..: "
@ Li,054 PSAY STR0504+Int_PO->NPOCOND_PA+" / "+Int_PO->NPODIAS_PA //"Cond Pagto /Dias.: "

Li++
@ Li,001 PSAY STR0505+Int_PO->NPOAGENTE+" "+LEFT(SY4->Y4_NOME,29) //"Agente...........: "
@ Li,054 PSAY STR0506+Int_PO->NPOIMPORT+" "+SYT->YT_NOME //"Importador.......: "

Li++
SYT->(DBSEEK(cFilSYT+Int_PO->NPOCONSIG))
@ Li,001 PSAY STR0507+Int_PO->NPOFREPPCC //"Tipo de Frete....: "
@ Li,054 PSAY STR0508+Int_PO->NPOCONSIG+" "+SYT->YT_NOME //"Consignatario....: "

Li++
@ Li,001 PSAY STR0509+PADL(Int_PO->NPOFORN,nLenForn,'0')+" "+SA2->A2_NREDUZ //"Fornecedor.......: " SO.:0026 OS.:0232/02 FCD
@ Li,054 PSAY STR0510+Int_PO->NPONR_PRO+" / "+DTOC(IN100CTD(Int_PO->NPODT_PRO)) //"Proforma / Data..: "

Li++
@ Li,001 PSAY STR0511+TRANSFORM(Val(Int_PO->NPOPARID_U),"@EZ 999,999,999.999999")+" / "+DTOC(IN100CTD(Int_PO->NPODT_PAR)) //"Paridade / Data..: "
@ Li,054 PSAY STR0512+TRANSFORM(Val(Int_PO->NPOPESO_B),"@EZ 999,999,999.999") //"Peso Bruto.......: "

Li++
SY4->(DBSEEK(cFilSY4+Int_PO->NPOFORWARD))
@ Li,001 PSAY STR0513+Int_PO->NPOCLIENTE+" "+LEFT(SA1->A1_NOME,25) //"Cliente..........: "
@ Li,054 PSAY STR0514+Int_PO->NPOFORWARD+" "+SY4->Y4_NOME //"Forwarder........: "

Li++
@ Li,001 PSAY STR0515+TRANSFORM(Val(Int_PO->NPOINLAND),"@EZ 999,999,999.99") //"Inland Charg.....: "
@ Li,054 PSAY STR0516+TRANSFORM(Val(Int_PO->NPOPACKING),"@EZ 999,999,999.99") //"Packing Charg....: "

Li++
@ Li,001 PSAY STR0517+TRANSFORM(Val(Int_PO->NPODESCONT),"@EZ 999,999,999.99") //"Desconto.........: "
@ Li,054 PSAY STR0518+TRANSFORM(Val(Int_PO->NPOFRETEIN),"@EZ 999,999,999.99") //"Int'l Freight....: "

Li++
@ Li,001 PSAY STR0519+Int_PO->NPOMOEDA+" "+; //"FOB..............: "
                                  TRANSFORM(Int_PO->NPOFOB_TOT,"@R 9,999,999,999.9999")
@ Li,054 PSAY STR0520+Int_PO->NPOINCOTER //"Incoterms........: "

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"IMPCAPAPO1")
EndIf

Li++
@ Li,001 PSAY STR0521 //"Mensagem.........: "
IN100RelMsg()

IF Li <= 55
   @++Li,001 PSAY STR0522
                  //Item                            Posicao   C.C./S.I.                      Fabric    Quantidade  Embarque  Entrega   Preco Unitario Tipo Material   Mensagem"
   @++Li,001 PSAY "------------------------------ -------- ---------------------------  ---------- -------------  --------  -------  ---------------  -------------  ---------------------------------------"
   Li++

   If EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"IMPCABIPITENS")
   EndIf

ENDIF
RETURN .T.

*-----------------------------------------------------------------------------
FUNCTION IN100DetPO(cTit,lEnd)
*-----------------------------------------------------------------------------
LOCAL Indice, nLinMsg:=MLCOUNT(ALLTRIM(Int_IP->NIPMSG),LEN_MSG)

IF Li > 55
   IN100TitPO(cTit,@lEnd)
ENDIF

@ Li,001 PSAY TRANSFORM(LEFT(Int_IP->NIPCOD_I,NLENITEM),_PictItem)
@ Li,032 PSAY Int_IP->NIPPOSICAO
@ Li,041 PSAY Int_IP->NIPCC+"-"+Int_IP->NIPSI_NUM
@ Li,070 PSAY Int_IP->NIPFABR
@ Li,081 PSAY Int_IP->NIPQTDE
@ Li,096 PSAY DTOC(IN100CTD(Int_IP->NIPDT_EMB))
@ Li,105 PSAY DTOC(IN100CTD(Int_IP->NIPDT_ENTR))
@ Li,115 PSAY Int_IP->NIPPRECO
@ Li,133 PSAY BuscaClass(Int_IP->NIPCLASS,.F.)

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"IMPIPITENS")
EndIf

FOR Indice:=1 TO nLinMsg
    IF(Li > 55, IN100TitPO(cTit),)   //58
    @Li++,158 PSAY MEMOLINE(Int_IP->NIPMSG,LEN_MSG,Indice)
NEXT
IF(nLinMsg=0,Li++,)
RETURN .T.

*-----------------------------------------------------------------------------
FUNCTION IN100TitSI(cTit,lEnd)
*-----------------------------------------------------------------------------
Cabec(cTit,cCabec1,cCabec2,nomeprog,tamanho,nComprimido)

*Modelo Utilizado.: xx xxxxxxxxxxxxxxxxxxxx           Data Integracao..: xx/xx/xx
*C.C. / S.I. .....: xxxxxxxxxxxxxxx                   Data S.I.........: xx/xx/xx
*Local de Entrega.: xx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*Comprador........: xx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*Mensagem.........: 20                                54
*-----------------------------------------------------------------------------*
*Item                              Quantidade Entrega Fabricante Fornecedor Tipo Material Mensagem
*------------------------------ ------------- ------- ---------- ---------- ------------- ----------------------------------------
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 123456789,012 ddmmaa   123456     123456                  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*1                              32            46       55         66        76            90          93
*Item                              Quantidade Entrega Fabricante Fornecedor Tipo Material Mensagem
*------------------------------ ------------- ------- ---------- ---------- ------------- ----------------------------------------
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 123456789,012 ddmmaa  1234567890 1234567890              xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*1                              32            46      54         65        76            90          93

SY2->(DBSEEK(cFilSY2+Int_SI->NSI_POLE))
SY1->(DBSEEK(cFilSY1+Int_SI->NSICOMPRA))

IN100CabSI()
RETURN .T.
*-----------------------------------------------------------------------------
FUNCTION IN100CabSI()
*-----------------------------------------------------------------------------
LOCAL cStatus:=IF(EVAL(bStatus),STR0493,STR0494) //"ACEITO"###"REJEITADO"
LOCAL cStaItem:=IF(Int_SI->NSITIPO='A',IF(Int_SI->NSIITEM_OK = "T","",STR0523),"") //"              SI POSSUI ITEM REJEITADO"

SY2->(DBSEEK(cFilSY2+Int_SI->NSI_POLE))
SY1->(DBSEEK(cFilSY1+Int_SI->NSICOMPRA))

@ Li++,001 PSAY STR0496+IN100TIPO()+"  /  "+cStatus+cStaItem //"TIPO /  Status...: "
@ Li  ,001 PSAY STR0497+SWU->WU_COD+" "+SWU->WU_DESCR //"Modelo Utilizado.: "
@ Li++,054 PSAY STR0498+DTOC(IN100CTD(EVAL(bDtInteg))) //"Data Integracao..: "
@ Li  ,001 PSAY STR0524+STR(VAL(Int_SI->NSI_CC),nLenSi,0)+' - '+; //"C.C. / S.I.  ....: " SO.:0026 OS.:0232/02 FCD
                                     TRANSFORM(Int_SI->NSI_NUM,_PictSI)
@ Li,054 PSAY STR0525+DTOC(IN100CTD(Int_SI->NSI_DT)) //"Data S.I.........: "

Li++
@ Li,001 PSAY STR0501+Int_SI->NSI_POLE+" "+SY2->Y2_DESC //"Local de Entrega.: "

Li++
@ Li,001 PSAY STR0502+Int_SI->NSICOMPRA+" "+SY1->Y1_NOME //"Comprador........: "

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"IMPCAPASI1")
EndIf

Li++
@ Li,001 PSAY STR0521 //"Mensagem.........: "
IN100RelMsg()

IF Li <= 55
   @++Li,001  PSAY STR0526 //"Item                              Quantidade Entrega Fabricante Fornecedor Tipo Material Mensagem"
   @++Li,001  PSAY "------------------------------ ------------- ------- ---------- ---------- ------------- ----------------------------------------"
   Li++
   If EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"IMPCABISITENS")
   EndIf
ENDIF
RETURN .T.

*-----------------------------------------------------------------------------
FUNCTION IN100DetSI(cTit)
*-----------------------------------------------------------------------------
LOCAL Indice, nLinMsg:=MLCOUNT(ALLTRIM(Int_IS->NISMSG),LEN_MSG)

IF Li > 55
   IN100TitSI(cTit,@lEnd)
ENDIF

@ Li,001 PSAY TRANSFORM(LEFT(Int_IS->NISCOD_I,NLENITEM),_PictItem)
@ Li,032 PSAY Int_IS->NISQTDE
@ Li,046 PSAY DTOC(IN100CTD(Int_IS->NISDTENTR_))
@ Li,058 PSAY Int_IS->NISFABR  //SO.:0026 OS.:0232/02 FCD
@ Li,071 PSAY Int_IS->NISFORN  //SO.:0026 OS.:0232/02 FCD 
@ Li,084 PSAY BuscaClass(Int_IS->NISCLASS,.F.)

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"IMPISITENS")
EndIf

FOR Indice:=1 TO nLinMsg
    IF(Li > 55, IN100TitSI(cTit),)
    @Li++,90 PSAY MEMOLINE(Int_IS->NISMSG,LEN_MSG,Indice)
NEXT
IF(nLinMsg=0,Li++,)
RETURN .T.

*-----------------------------------------------------------------------------
FUNCTION IN100TitNU(cTit,lEnd)
*-----------------------------------------------------------------------------
Cabec(cTit,cCabec1,cCabec2,nomeprog,tamanho,nComprimido)

*Processo.........: 99999999999999                    Data Integracao..: xx/xx/xx
*Despachante......: 999-xxxxxxxxxXxxxxxxxxxXxxxxxxxxxXxxxxxxxxxX
*Agente...........: 999-xxxxxxxxxXxxxxxxxxxXxxxxxxxxxXxxxxxxxxxX
*Data de chegada..: xxxxxxxxxxxxxxx                   Data Receb.Docs..: xx/xx/xx
*Numero do Master.: xxxxxxxxxXxxxxxxxx                Tipo de Declar...: xx
*URF Despachos....: 9999999                           URF Entrada..... : 9999999
*Rec.Alfandegado..: 9999999                           Modal.Despacho...: x
*Tipo de Conhecim.: XX                                Tipo de Documento: XX
*Utilização.......: X                                 Identificação....: 999999999999.99
*Peso Bruto.......: 99999,99999.9999                  Fat.Serviços.....: 999999
*Data da Entrega..: 99/99/2000                        
*Observação.......: xxxxxxxxxXxxxxxxxxxXxxxxxxxxxXxxxxxxxxxX
*.................: xxxxxxxxxXxxxxxxxxxXxxxxxxxxxXxxxxxxxxxX
*Mensagem.........: 20                                54
*-----------------------------------------------------------------------------*
*Despesa                   DT.PAGTO   PAGO POR      ADIANT             VALOR R$
*------------------------------ ------------- ------ ------------- -------- ------- --------------- ------------- ------ ------ ------ ------ ------ ---------------------------------------
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 12345-1234/56 123456 123456789,012  ddmmaa  ddmmaa  123456789.12345 xxxxxxxxxxxxx 123456 123456 123456 123456 123456 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*1                              32            46     53             68      76      84              100           114    121    128    135    142    149

IN100CabNU()
RETURN .T.

*-----------------------------------------------------------------------------
FUNCTION IN100CabNU()
*-----------------------------------------------------------------------------
//LOCAL cStatus:=IF(EVAL(bStatus),STR0493,STR0494) //"ACEITO"###"REJEITADO"
*LOCAL cStaItem:=IF(Int_NU->NNUINT_OK,"T","") //"              PO POSSUI ITEM REJEITADO"
LOCAL nCount := 0

SW6->(dbSetOrder(9))
SW6->(dbSeek(cFilSW6+Left(Int_NU->NNUREFDES,LEN(SW6->W6_REF_DES))))                                   //MJB-SAP-0401
SW6->(dbSeek(cFilSW6+Left(Int_NU->NNUREFDES,15)))                                                     //MJB-SAP-0401
SW6->(dbSetOrder(1))
SY4->(DBSEEK(cFilSY4+Int_NU->NNUAGENTE))
SY5->(DBSEEK(cFilSY5+SW6->W6_DESP ))
SJA->(DbSeek(cFilSJA+Int_NU->NNURECALFA)) // Rec.Alf
SJB->(DbSeek(cFilSJB+AllTrim(StrZero(Val(Int_NU->NNUTIPODEC),2,0))))

@ Li,001 PSAY STR0682+SW6->W6_HAWB                      //"Processo.........: "
@ Li,060 PSAY STR0683+Int_NU->NNUREFDES                 //"Ref.Despachante..: "

Li++
@ Li,001 PSAY STR0684+Int_NU->NNUDESP+" "+SY5->Y5_NOME  //"Despachante......: "

Li++
@ Li,001 PSAY STR0685+Int_NU->NNUAGENTE+" "+LEFT(SY4->Y4_NOME,29) //"Agente...........: "

Li++
@ Li,001 PSAY STR0686+DTOC(IN100CTD(Int_NU->NNUDCHEG,,"DDMMAAAA"))   //"Data de chegada..: " //MJB-SAP-1100
@ Li,060 PSAY STR0687+DTOC(IN100CTD(Int_NU->NNUDRECDOC,,"DDMMAAAA")) //"Data Receb.Docs..: " //MJB-SAP-1100

Li++
@ Li,001 PSAY STR0688+Int_NU->NNUMASTER                           //"Numero do Master.: "
@ Li,060 PSAY STR0689+StrZero(Val(Int_NU->NNUTIPODEC),2,0)+" "+SJB->JB_DESCR //"Tipo de Declar...: "

Li++
SJ0->(DbSeek(cFilSJ0+Strzero(Val(Int_NU->NNUURFDESP),7,0)))
@ Li,001 PSAY STR0690+Int_NU->NNUURFDESP+" "+Left(SJ0->J0_DESC,30)   //"URF Despachos....: "
SJ0->(DbSeek(cFilSJ0+Strzero(Val(Int_NU->NNUURFENTR),7,0)))
@ Li,060 PSAY STR0691+Int_NU->NNUURFENTR+" "+Left(SJ0->J0_DESC,30)   //"URF Entrada..... : "

Li++
*Rec.Alfandegado..: 9999999                           Modal.Despacho...: x
@ Li,001 PSAY STR0692+Int_NU->NNURECALFA+" "+Left(SJA->JA_DESCR,30)  //"Rec.Alfandegado..: "
@ Li,060 PSAY STR0693+Int_NU->NNUMODALDE+" "+BSCXBOX("W6_MODAL_D", AllTrim(Int_NU->NNUMODALDE))//"Modal.Despacho...: "

Li++
SX5->(DBSEEK(cFilSX5+"47"+Int_NU->NNUTIPOCON))
@ Li,001 PSAY STR0694+Int_NU->NNUTIPOCON+Left(SX5->X5_DESCRI,30) //"Tipo de Conhecim.: "
@ Li,060 PSAY STR0695+Int_NU->NNUTIPODOC+" "+BSCXBOX("W6_TIPODOC", AllTrim(Int_NU->NNUTIPODOC))//"Tipo de Documento: "

Li++
@ Li,001 PSAY STR0696+Int_NU->NNUUTILCON+" "+BSCXBOX("W6_UTILCON", AllTrim(Int_NU->NNUUTILCON))                         //"Utilização.......: "
@ Li,060 PSAY STR0697+Int_NU->NNUIDENTIF                         //"Identificação....: "

Li++
@ Li,001 PSAY STR0698+TRANSFORM(Val(Int_NU->NNUPESOBRU), "@E 999,999.99") //"Peso Bruto.......: "
@ Li,060 PSAY STR0699+Int_NU->NNUNF_ENT                          //"Fat.Serviços.....: "

Li++
@ Li,001 PSAY STR0700+DTOC(IN100CTD(Int_NU->NNUDT_ENTR,,'DDMMAAAA')) //"Data da Entrega..: " //MJB-SAP-1100

Li++
@ Li,001 PSAY STR0701                                            //"Observação.......: "

cObservacao := Alltrim(INT_NU->NNU_OBS)
nTotLin     := MLCOUNT(cObservacao,40)
FOR nCount:=1 TO nTotLin
    If ! EMPTY(ALLTRIM(MEMOLINE(cObservacao,40,nCount)))
       @ LI,020 PSAY MEMOLINE(cObservacao,40,nCount)
       LI++
    Endif
NEXT

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"IMPCAPANU")
EndIf

If(Empty(cObservacao), LI++,)

@ Li,001 PSAY STR0521 //"Mensagem.........: "
IN100RelMsg()

IF Li <= nLinhas
   @++Li,001 PSAY STR0702 //"DESPESA                   DT.PAGTO   PAGO POR      ADIANT             VALOR R$ MENSAGEM"
   *                         999-xxxxxxxxxXxxxxxxxxxX  99/99/99   DESPACHANTE    SIM     999,999,999,999.99
   *                         0123456789d123456789v123456789t123456789q123456789c123456789s123456789s123456789o123456789n123456789c123456789d123456789v123456789t12
   @++Li,001 PSAY           "------------------------- --------   -----------   ------  ------------------- ----------------------------------------"
   Li++

   If EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"IMPCABDN")
   EndIf

ENDIF
RETURN .T.

*-----------------------------------------------------------------------------
FUNCTION IN100DetNU(cTit,lEnd)
*-----------------------------------------------------------------------------
LOCAL nRecno,Indice, nLinMsg:=MLCOUNT(ALLTRIM(Int_DN->NDNMSG),LEN_MSG)

IF Li > nLinhas
   IN100TitNU(cTit,@lEnd)
ENDIF
SYB->(dbSeek(cFilSYB+Int_DN->NDNDESPESA))

@ Li,001 PSAY Int_DN->NDNDESPESA+" "+Substr(SYB->YB_DESCR,1,20)
@ Li,027 PSAY DTOC(IN100CTD(Int_DN->NDNDPAGTO,,"DDMMAAAA"))               //MJB-SAP-1100
@ Li,038 PSAY If(Int_DN->NDNPAGOPOR=="1", STR0440, STR0288)
@ Li,053 PSAY If(Int_DN->NDNADIANTA=="S", STR0096, STR0095)
@ Li,061 PSAY TransForm(Val(Int_DN->NDNVALOR), "@E 999,999,999,999.99")
nTotdesp += Val(Int_DN->NDNVALOR)

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"IMPDNDESP")
EndIf

FOR Indice:=1 TO nLinMsg
    IF(Li > 55, IN100TitNU(cTit),)   //58
    @Li++,80 PSAY MEMOLINE(Int_DN->NDNMSG,LEN_MSG,Indice)
NEXT
IF(nLinMsg=0,Li++,)

nRecno := Int_DN->(Recno())
Int_DN->(dbSkip())

If (Int_NU->NNUREFDES != Int_DN->NDNREFDES .Or. Int_DN->(Eof()))
                        @ Li,001 PSAY Replicate("-", 130)
                        Li++
                        @ Li,001 PSAY STR0703
                        @ Li,061 PSAY TransForm(nTotDesp, "@E 999,999,999,999.99")
                        nTotDesp := 0
                        Li       := 99
EndIf
Int_DN->(dbGoTo(nRecno))
Return(Nil)

*-----------------------------------------------------------------------------
FUNCTION IN100TitDE(cTit,lEnd)
*-----------------------------------------------------------------------------
Cabec(cTit,cCabec1,cCabec2,nomeprog,tamanho,nComprimido)
                                 
*Status...........: 99999999999999                    *Ref.Despachante..: 999-xxxxxxxxxXxxxxxxxxxXxxxxxxxxxXxxxxxxxxxX
*Pgto Imposto.....: XX                                *Nr. Processo.....: 999-xxxxxxxxxXxxxxxxxxxXxxxxxxxxxXxxxxxxxxxX
*Data chegada.....: xxxxxxxxxxxxxxx                   *Rec.Docto........: xxxxxxxxxXxxxxxxxx                
*Agente...........: 9999999                           *Despachante......: 9999999                           
*Numero da D.I....: X                                 *Taxa da D.I......: 99999,99999.9999                  
*Dt Entrega.......: 99/99/99
*Observacao.......: xxxxxxxxxXxxxxxxxxxXxxxxxxxxxXxxx
*Mensagem.........: 20                                54
*-----------------------------------------------------------------------------*
*Despesa                        DT.PAGTO     PAGO POR      ADIANT   VALOR R$
*------------------------------ ------------- ------ ------------- -------- ------- --------------- ------------- ------ ------ ------ ------ ------ ---------------------------------------
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 12345-1234/56 123456 123456789,012  ddmmaa  ddmmaa  123456789.12345 xxxxxxxxxxxxx 123456 123456 123456 123456 123456 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*1                              32            46     53             68      76      84              100           114    121    128    135    142    149

IN100CabDe()
RETURN .T.

*-----------------------------------------------------------------------------
FUNCTION IN100CabDe()
*-----------------------------------------------------------------------------
LOCAL cStatus:=IF(EVAL(bStatus),STR0493,STR0494) //"ACEITO"###"REJEITADO"
LOCAL nCount := 0
LOCAL cSpace := LEN(STR0708)
LOCAL nTNDesp:= 0

SW6->(dbSetOrder(9))
SW6->(dbSeek(cFilSW6+Left(Int_DspHe->NDHREFDESP,LEN(SW6->W6_REF_DES))))                                   //MJB-SAP-0401
SW6->(dbSeek(cFilSW6+Left(Int_DspHe->NDHREFDESP,15)))                                                     //MJB-SAP-0401
SW6->(dbSetOrder(1))
SY4->(DBSEEK(cFilSY4+Int_DspHe->NDHAGENTE))
SY5->(DBSEEK(cFilSY5+Int_DspHe->NDHDESP))

@ Li,001 PSAY STR0709+cStatus//IN100Status()             //"Status...........: "
@ Li,040 PSAY STR0683+Int_DspHe->NDHREFDESP             //"Ref.Despachante..: "					//LGS-30/12/2014

Li++
@ Li,001 PSAY STR0710+DTOC(IN100CTD(Int_DspHe->NDHDPAGIMP,,"DDMMAAAA")) //"Pgto Imposto..: "
@ Li,040 PSAY STR0708+Int_DspHe->NDHHOUSE//+" "+SY5->Y5_NOME  //"Nro Processo.....: " 			//LGS-30/12/2014
Li++
nTNDesp := Len(SY5->Y5_NOME) //LGS-30/12/2014 - Incluido o nome na linha abaixo para nao sobresair informaçoes no relatorio.
If nTNDesp > 21
   @ Li,040 PSAY SPACE(cSpace)+SubStr(SY5->Y5_NOME,1,(nTNDesp-20)) //SY5->Y5_NOME
   Li++
   If Empty(SubStr(SY5->Y5_NOME,21,1))
      @ Li,040 PSAY SPACE(cSpace)+SubStr(SY5->Y5_NOME,22,nTNDesp)
   Else
      @ Li,040 PSAY SPACE(cSpace)+SubStr(SY5->Y5_NOME,21,nTNDesp)
   EndIf
Else
   @ Li,040 PSAY SPACE(cSpace)+SY5->Y5_NOME
EndIf

Li++                                                                          
@ Li,001 PSAY STR0711+DTOC(IN100CTD(Int_DspHe->NDHDCHEG,,"DDMMAAAA"))   //"Data de chegada..: " 
@ Li,040 PSAY STR0712+DTOC(IN100CTD(Int_DspHe->NDHDRECDOC,,"DDMMAAAA")) //"Data Receb.Docs..: " //LGS-30/12/2014

Li++
@ Li,001 PSAY STR0713+Int_DspHe->NDHAGENTE//+" "+LEFT(SY4->Y4_NOME,29) //"Agente...........: "
@ Li,040 PSAY STR0714+Int_DspHe->NDHDESP                               //"Despachante......: "	//LGS-30/12/2014

Li++               
@ Li,001 PSAY STR0716+Int_DspHe->NDHDI_NUM                //"Nro D.I.....: "
@ Li,040 PSAY STR0717+Alltrim(TRANSFORM(Int_DspHe->NDHTX_FOB,cPict15_8))//"Taxa D.I...: "			//LGS-30/12/2014

Li++
@ Li,001 PSAY STR0715+DTOC(IN100CTD(Int_DspHe->NDHDT_ENTR)) //"Data da Entrega..:" 
Li++
@ Li,001 PSAY STR0701                                       //"Observação.......: "

cObservacao := Alltrim(Int_DspHe->NDH_OBS)
nTotLin     := MLCOUNT(cObservacao,40)
FOR nCount:=1 TO nTotLin
    If ! EMPTY(ALLTRIM(MEMOLINE(cObservacao,40,nCount)))
       @ LI,020 PSAY MEMOLINE(cObservacao,40,nCount)
       LI++
    Endif
NEXT

If(Empty(cObservacao), LI++,)

@ Li,001 PSAY STR0521 //"Mensagem.........: "
IN100RelMsg()
Li++   

IF Li <= nLinhas
   @++Li,001 PSAY STR0719 //"DESPESA                   DT.PAGTO   PAGO POR      ADIANT             VALOR R$"
   *                         999-xxxxxxxxxXxxxxxXX  99/99/99   DESPACHANTE     SIM     999,999,999,999.99
   *                         0123456789d123456789v123456789t123456789q123456789c123456789s123456789s123456789o123456789n123456789c123456789d123456789v123456789t12
   @++Li,001 PSAY           "---------------------  ---------  -------------  -------  -------------------"
   Li++

ENDIF
RETURN .T.

*---------------------------
FUNCTION IN100DetDe(cTit)
*---------------------------
LOCAL nLinMsg, nTotdesp:= 0 
SYB->(dbSetOrder(1))

IF Li > nLinhas
   IN100TitDe(cTit)
ENDIF             
Int_DspDe->(DBGOTOP())
Int_DspDe->( DbSeek(Int_DspHe->NDHHOUSE)) 
WHILE !Int_DspDe->( EOF() )  .AND.  Int_DspHe->NDHHOUSE == Int_DspDe->NDDHOUSE
   SYB->(dbSeek(cFilSYB+Int_DspDe->NDDDESPESA))     
   @ Li,001 PSAY Int_DspDe->NDDDESPESA+" "+Substr(SYB->YB_DESCR,1,15)
   @ Li,025 PSAY DTOC(IN100CTD(Int_DspDe->NDDDPAGTO,,"DDMMAAAA"))               
   @ Li,035 PSAY If(Int_DspDe->NDDPAGOPOR=="1", STR0440, STR0288)
   @ Li,050 PSAY If(Int_DspDe->NDDADIANTA=="S", STR0096, STR0095)
   @ Li,058 PSAY TRANSFORM(Int_DspDe->NDDVALOR, "@E 999,999,999,999.99")
   nTotdesp += Int_DspDe->NDDVALOR
   Li++
   Int_DspDe->(dbSkip())      
EndDo                   
Li++               

IF(nLinMsg=0,Li++,)

*-----------------------------------*
FUNCTION IN100TabFabFor(cFBFO,cTipo)
*-----------------------------------*
LOCAL nOrdem:=0
nOrdem := ASCAN(aTabFabFor,{|chave| chave[1] == cFBFO})
IF nOrdem = 0
   AADD(aTabFabFor,{cFBFO,cTipo})
ELSE
   IF aTabFabFor[nOrdem,2] # cTipo
      aTabFabFor[nOrdem,2] := '3'
   ENDIF
ENDIF
RETURN NIL

*----------------------------*
FUNCTION IN100RecLock(cAlias)
*----------------------------*
LOCAL lRetorno:=.f.,cAliasAnt:=Alias()
lRetorno:=Reclock( cAlias, .T. )
DBSELECTAREA(cAliasAnt)
RETURN lRetorno

*------------------------*
FUNCTION IN100DI(TB_Cols)
*------------------------*
Local	aStr:=INT_DI->(dBStruct())
//* FSY - 26/08/2013 - Endentação
AADD(TB_Cols,{{||Int_DI->NDIHAWB}                                                                          ,"" ,STR0527}) //"Processo"
AADD(TB_Cols,{{||IF(!EMPTY(IN100CTD(Int_DI->NDIDT_ENTR)),IN100CTD(Int_DI->NDIDT_ENTR),NDIDT_ENTR)}         ,"" ,STR0528}) //"Data de Recebimento"
AADD(TB_Cols,{{||Int_DI->NDINF_ENT}                                                                        ,"" ,cTitNFE}) //"Nota Fiscal de Entrada"
AADD(TB_Cols,{{||Int_DI->NDISERIENF}                                                                       ,"" ,STR0530}) //"Serie da NF de Entrada"
AADD(TB_Cols,{{||IF(!EMPTY(IN100CTD(Int_DI->NDIDT_NF)),IN100CTD(Int_DI->NDIDT_NF),NDIDT_NF)}               ,"" ,STR0531}) //"Data da Nota Fiscal"
AADD(TB_Cols,{{||IF(VAL(Int_DI->NDIDI_NUM)>0,TRANSFORM(VAL(Int_DI->NDIDI_NUM),AVSX3("W6_DI_NUM",6)),NDIDI_NUM)},"" ,STR0532}) //"Numero da D.I."//FSY - 23/08/2013 - Adicionado a função AVSX3("W6_DI_NUM",6) 
AADD(TB_Cols,{{||IF(VAL(Int_DI->NDIVL_NF)>0,TRANSFORM(VAL(Int_DI->NDIVL_NF),cPict15_2),NDIVL_NF)}              ,"" ,STR0533}) //"Valor da Nota Fiscal"
If SW6->(FieldPos("W6_DIRE"))>0
   AADD(TB_Cols,{{||IF(VAL(Int_DI->NDIDIRE)>0,TRANSFORM(VAL(Int_DI->NDIDIRE),AVSX3("W6_DIRE",6)),NDIDIRE)}        ,"" ,STR0786 }) //"Numero da DIRE."//FSY - 23/08/2013 - Adicionado o campo Nº DIRE.
End If
//*                 
ASIZE(TBRCols,0)
AADD(TBRCols,{{|| IN100Status()}                              , STR0036 }) //"Status"
AADD(TBRCols,{{|| IN100TIPO() }                               , STR0037   }) //"Tipo"
AADD(TBRCols,{{|| IN100CTD(EVAL(bDtInteg))}                   , STR0071 }) //"Dt Integ"
AADD(TBRCols,{{|| Int_DI->NDIHAWB}                                    , STR0527}) //"Processo"
AADD(TBRCols,{{|| IF(!EMPTY(IN100CTD(Int_DI->NDIDT_ENTR)),IN100CTD(Int_DI->NDIDT_ENTR),NDIDT_ENTR)}, STR0528}) //"Data de Recebimento"
AADD(TBRCols,{{|| Int_DI->NDINF_ENT}                                  , cTitNFE} ) //"Nota Fiscal de Entrada"
AADD(TBRCols,{{|| Int_DI->NDISERIENF}                                 , STR0530} ) //"Serie da NF de Entrada"
AADD(TBRCols,{{|| IF(!EMPTY(IN100CTD(Int_DI->NDIDT_NF)),IN100CTD(Int_DI->NDIDT_NF),NDIDT_NF)}, STR0531}) //"Data da Nota Fiscal"
AADD(TBRCols,{{|| Int_DI->NDIDI_NUM}                                  , STR0532}) //"Numero da D.I."
AADD(TBRCols,{{|| IF(VAL(Int_DI->NDIVL_NF)>0,TRANSFORM(VAL(Int_DI->NDIVL_NF),'@e 999,999,999,999.99'),NDIVL_NF)}, STR0533}) //"Valor da Nota Fiscal"
AADD(TBRCols,{{|| IN100E_MSG(.T.)}                            , STR0112  }) //"Mensagem"

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"COLDI")
ENDIF

If	aScan(aStr,{|x| x[01]=="NDITIPONF"})>0
   //--- Se existir o campo NDITIPONF na estrutura da tabela de trabalho, indicará que a interface está sendo
   //		executada pelo AvInteg, e que portanto, terá um tratamento diferenciado na gravação do registro.
	AADD(TB_Cols,{{||Int_DI->NDITIPONF}, "", "Tipo NF"})
	AADD(TBRCols,{{||Int_DI->NDITIPONF}, "Tipo NF"})
EndIf

AADD(TB_Cols,{{||IN100E_Msg(.T.)}                            ,"" ,STR0112  }) // "Mensagem"

RETURN .T.

*--------------------*
FUNCTION IN100LerDI()
*--------------------*
LOCAL nRegDI:=0, nRegInt:=0, lAchou:=.f., nDI_NUM:=Int_DI->NDIDI_NUM
LOCAL cHAWB:=Int_DI->NDIHAWB, xNDIDi_num
Local	aStr:=INT_DI->(dBStruct())
SW6->(DBSETORDER(1))

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"LERDI")
ENDIF

If EMPTY(Int_DI->NDIHAWB)
   EVAL(bMsg,STR0552+STR0546) // HOUSE NAOINFORMADO 
ElseIf ! SW6->(DBSEEK(cFilSW6+Int_DI->NDIHAWB))
   EVAL(bMsg,STR0552+STR0544)  // HOUSE SEMCADASTRO
ENDIF

If	aScan(aStr,{|x| x[01]=="NDITIPONF"})>0
  	//--- Se existir o campo NDITIPONF na estrutura da tabela de trabalho, indicará que a interface está sendo
   //		executada pelo AvInteg, e que portanto, terá um tratamento diferenciado na gravação do registro.
   If Int_DI->NDITIPONF$"136"	//--- Se a NF for Primeira, Única ou Filha, exige o preenchimento da Data de Recebimento...
      IF EMPTY(IN100CTD(Int_DI->NDIDT_ENTR))
         EVAL(bMsg,STR0534+STR0546) //"DATA DO RECEBIMENTO NAOINFORMADO
      ENDIF
   EndIf
Else
   IF EMPTY(IN100CTD(Int_DI->NDIDT_ENTR))
      EVAL(bMsg,STR0534+STR0546) //"DATA DO RECEBIMENTO NAOINFORMADO
   ENDIF
EndIf

IF EMPTY(Int_DI->NDINF_ENT)
   EVAL(bMsg,STR0535+STR0546) //"NUMERO DA NOTA FISCAL NAOINFORMADO
ENDIF

IF EMPTY(IN100CTD(Int_DI->NDIDT_NF))
   EVAL(bMsg,STR0531+STR0546) //"DATA DA NOTA FISCAL NAOINFORMADO
ENDIF

IF VAL(Int_DI->NDIVL_NF)=0 .AND. ! EMPTY(Int_DI->NDIVL_NF)
   EVAL(bMsg,STR0536+STR0549) //"VALOR DA NF INVALIDO
ENDIF
//* FSY - 23/08/2013 - Tratamento para currier 1 = Sim 
IF SW6->(FieldPos("W6_CURRIER"))>0 .And. SW6->W6_CURRIER == "1"
   IF VAL(Int_DI->NDIDIRE)=0 .AND. ! EMPTY(Int_DI->NDIDIRE)
     EVAL(bMsg,STR0787) //"Número da DIRE invalido
   ENDIF
   IF ! EMPTY(Int_DI->NDIDI_NUM)
      EVAL(bMsg,STR0788)//Processo tipo currier, remova o número da DI
   ENDIF   
ELSE
   IF VAL(Int_DI->NDIDI_NUM)=0 .AND. ! EMPTY(Int_DI->NDIDI_NUM)
      EVAL(bMsg,STR0537+STR0549) //"NUMERO DA DI INVALIDO
   ENDIF
   IF ! EMPTY(Int_DI->NDIDIRE)
      EVAL(bMsg,STR0789)//Apenas processo tipo currier utilizam o número da DIRE, remova o número da DIRE
   ENDIF
ENDIF
//*
If VAL(Int_DI->NDIDI_NUM)#0 .AND. ! EMPTY(Int_DI->NDIHAWB) .AND. SIX->(DBSEEK('SW6B')) .And. (EasyGParam("MV_TEM_DI",,.F.) .Or. !EasyGParam("MV_TEM_DI",,.F.) .And. SW6->(FieldPos("W6_VERSAO")) == 0)
   nRegDI:=SW6->(RECNO())
   SW6->(DBSETORDER(11))
   IF AVSX3("W6_DI_NUM",2)=="N" //MCF - 18/04/2016
      SW6->(DBSEEK(cFilSW6+STR(VAL(Int_DI->NDIDI_NUM),10,0)))
   Else
      SW6->(DBSEEK(cFilSW6+Int_DI->NDIDI_NUM))
   EndIf
   xNDIDi_num:=IF(AVSX3("W6_DI_NUM",2)=="N",VAL(Int_DI->NDIDI_NUM),Int_DI->NDIDI_NUM)
   Do While ! SW6->(EOF()) .AND. xNDIDi_num=SW6->W6_DI_NUM .AND. cFilSW6=SW6->W6_FILIAL
      If Int_DI->NDIHAWB # SW6->W6_HAWB
         lAchou:=.T.
         Exit
      Endif
      SW6->(DBSKIP())
      xNDIDi_num:=IF(AVSX3("W6_DI_NUM",2)=="N",VAL(Int_DI->NDIDI_NUM),Int_DI->NDIDI_NUM)
   EndDo
   SW6->(DBSETORDER(1))
   SW6->(DBGOTO(nRegDI))

   If ! lAchou
      nRegInt:=Int_DI->(RECNO())
      Int_DI->(DBSETORDER(3))
      Int_DI->(DBSEEK(nDI_NUM))
      Do While ! Int_DI->(EOF()) .AND. nDI_NUM=Int_DI->NDIDI_NUM
         If Int_DI->NDIHAWB # cHAWB .AND. nRegInt > Int_DI->(RECNO())
            lAchou:=.T.
            Exit
         EndIf
         Int_DI->(DBSKIP())
      EndDo
      Int_DI->(DBSETORDER(1))
      Int_DI->(DBGOTO(nRegInt))
   EndIf

   If lAchou
      EVAL(bMsg,STR0538) //"NUMERO DA DI PERTENCE A OUTRO PROCESSO"
   EndIf

Endif


IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"VALDI")
ENDIF
IN100VerErro(cErro,cAviso)

IF Int_DI->NDIINT_OK = "T"
   nResumoCer+=1
ELSE
   nResumoErr+=1
ENDIF
RETURN .T.
*---------------------------------------------------------------------------------------------------*
FUNCTION IN100GrvDI()
*---------------------------------------------------------------------------------------------------*
Local	aStr:=INT_DI->(dBStruct())
Local cObsDI := "" //MCF - 15/04/2016
PRIVATE nFreteDesp:=0,nFobDesp:=0,nSegDesp:=0
cAlias:=ALIAS()
IF SW6->(DBSEEK(cFilSW6+Int_DI->NDIHAWB))
   Reclock("SW6",.F.)
	If	aScan(aStr,{|x| x[01]=="NDITIPONF"})>0
   	//--- Se existir o campo NDITIPONF na estrutura da tabela de trabalho, indicará que a interface está sendo
	   //		executada pelo AvInteg, e que portanto, terá um tratamento diferenciado na gravação do registro.
		SW6->W6_DT_ENTR   := If(Empty(SW6->W6_DT_ENTR).AND.!Empty(Int_DI->NDIDT_ENTR),IN100CTD(Int_DI->NDIDT_ENTR),SW6->W6_DT_ENTR)
		Do	Case
		   Case Int_DI->NDITIPONF$"135"
              SW6->W6_NF_ENT    := AllTrim(Int_DI->NDINF_ENT)
              SW6->W6_SE_NF     := If(!Empty(AllTrim(Int_DI->NDISERIENF)),AllTrim(Int_DI->NDISERIENF),SW6->W6_SE_NF)
              SW6->W6_VL_NF     := If(SW6->W6_VL_NF==0.AND.Val(Int_DI->NDIVL_NF)>0,Val(Int_DI->NDIVL_NF),SW6->W6_VL_NF)
              SW6->W6_DT_NF     := If(SW6->W6_DT_NF<>IN100CTD(Int_DI->NDIDT_NF),IN100CTD(Int_DI->NDIDT_NF),SW6->W6_DT_NF)
         Case Int_DI->NDITIPONF=="2"
              SW6->W6_NF_COMP   := AllTrim(Int_DI->NDINF_ENT)
              SW6->W6_SE_NFC    := If(!Empty(AllTrim(Int_DI->NDISERIENF)),AllTrim(Int_DI->NDISERIENF),SW6->W6_SE_NFC)
              SW6->W6_VL_NFC    := If(Val(Int_DI->NDIVL_NF)>0,Val(Int_DI->NDIVL_NF),SW6->W6_VL_NFC)
              SW6->W6_DT_NFC    := If(!Empty(Int_DI->NDIDT_NF),IN100CTD(Int_DI->NDIDT_NF),SW6->W6_DT_NFC)
      EndCase
	Else
      SW6->W6_DT_ENTR   := IN100CTD(Int_DI->NDIDT_ENTR)
      SW6->W6_NF_ENT    := ALLTRIM(Int_DI->NDINF_ENT)      
      SW6->W6_DT_NF     := IN100CTD(Int_DI->NDIDT_NF)
      SW6->W6_VL_NF     := VAL(Int_DI->NDIVL_NF)  
      // SW6->W6_DT_ENCE   := IN100CTD(Int_DI->NDIDT_NF) - TLM 07/04/2008 - Data de encerramento não pode ser preenchida, pois pode existir notas complementares no processo.
      SW6->W6_SE_NF     := IF(!EMPTY(ALLTRIM(Int_DI->NDISERIENF)),ALLTRIM(Int_DI->NDISERIENF),SW6->W6_SE_NF)
   EndIf
   Int_DI->NDIINT_DT := IN100DTC(dDataBase)
   xNDIDi_num:=IF(AVSX3("W6_DI_NUM",2)=="N",VAL(Int_DI->NDIDI_NUM),Int_DI->NDIDI_NUM)
   //* FSY - 26/08/2013 
   If SW6->(FieldPos("W6_DIRE"))>0
      xNDIRE_num:=IF(AVSX3("W6_DIRE"  ,2)=="N",VAL(Int_DI->NDIDIRE)  ,Int_DI->NDIDIRE  )//FSY - 23/08/2013 - Verifica se o NºDIRE é numerio ou caracter no dicionario de dados.
   End If      
   If SW6->(FieldPos("W6_CURRIER"))>0 .And. SW6->W6_CURRIER == "1"//FSY - 23/08/2013 - Tratamento rara registro currier, grava o numero da DIRE.
      If SW6->(FieldPos("W6_DIRE"))>0
         SW6->W6_DIRE    := IF(!EMPTY(xNDIRE_num),xNDIRE_num,SW6->W6_DIRE  )
      EndIf
   Else
      
      //MCF - 15/04/2016
      IF !EMPTY(xNDIDi_num) .And. !EasyGParam("MV_TEM_DI",,.F.) .And. SW6->(FieldPos("W6_VERSAO")) > 0
         SW6->W6_VERSAO := GeraVersaoDI(.T.,xNDIDi_num)
         IF SW6->W6_VERSAO <> "00"
            cObsDI := STR0792 + xNDIDi_num // "Retificação da DI número + XXXXXXXXXXX"
            EasyMSMM(,AVSX3("W6_VMDIOBS",AV_TAMANHO),,cObsDI,INCMEMO,,,"SW6","W6_DI_OBS")
         ENDIF
      ENDIF
      
      SW6->W6_DI_NUM  := IF(!EMPTY(xNDIDi_num),xNDIDi_num,SW6->W6_DI_NUM)
   EndIf
   //*
   //TRP - 31/08/2012 - Gravar os dados da DI na capa do Câmbio.
   IF !EMPTY(xNDIDi_num)   
      SWA->(DbSetOrder(1))
      IF SWA->(DbSeek(xFilial("SWA")+ Int_DI->NDIHAWB))
         SWA->(Reclock("SWA",.F.))
         SWA->WA_DI_NUM:= xNDIDi_num
         SWA->(MsUnlock())
      ENDIF  
   ENDIF
   
   If EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"GRVDI")
   EndIf

   SW6->(MSUNLOCK())
   nFobDesp:=nFreteDesp:=nSegDesp:=0

   If ALLTRIM(EasyGParam("MV_DT_VAR")) $("W6_DT_ENTR/W6_DT_NF/W6_DT_ENCE")
      VrCambio()
   EndIf
ENDIF
DBSELECTAREA(cAlias)
RETURN .T.
*----------------------------*
Function IN100ImpResumo(cTit)
*----------------------------*
#DEFINE COURIER_10 oFont1
#DEFINE COURIER_16 oFont2

LOCAL nI:=0,MLin:=0, nPag:=0

AVPRINT oPrn NAME cTit

   DEFINE FONT oFont1  NAME "Courier New" SIZE 0,10 OF  oPrn
   DEFINE FONT oFont2  NAME "Courier New" SIZE 0,16 OF  oPrn

   AVPAGE

      MLin:=150
      oPrn:Box(MLin,50,MLin+150,2320)
      MLin+=40
      oPrn:Say(MLin,(2320/2),UPPER(cTit),COURIER_16,,,,2)
      MLin+=80
      oPrn:Box(MLin,50  ,MLin+480,1160)
      oPrn:Box(MLin,1160,MLin+480,2320)
      MLin+=40
      oPrn:oFont:=COURIER_10
      nPag:=1
      For nI=1 to (MLCOUNT(ALLTRIM(mMemoResumo),75)-1)
          
          If nPag >= 78
             AVNEWPAGE                                
             MLin:=150
                         oPrn:Box(MLin,50,MLin+150,2320)
                         MLin+=40
                         oPrn:Say(MLin,(2320/2),UPPER(cTit),COURIER_16,,,,2)
                         MLin+=80
                         oPrn:Box(MLin,50  ,MLin+480,1160)
                         oPrn:Box(MLin,1160,MLin+480,2320)
             MLin+=40
             oPrn:oFont:=COURIER_10
             nPag:=1
          EndIf
      
          If LEFT(MEMOLINE(mMemoResumo,75,nI),1)='-'
             oPrn:Box(MLin,50  ,MLin+480,1160)
             oPrn:Box(MLin,1160,MLin+480,2320)
          Else
             oPrn:Say(MLin,180 ,SUBSTR(MEMOLINE(mMemoResumo,75,nI),1,38))
             oPrn:Say(MLin,1300,SUBSTR(MEMOLINE(mMemoResumo,75,nI),40,38))
             MLin+=40
          EndIf
          nPag+=1          
      Next

   AVENDPAGE

AVENDPRINT

oFont1:End()
oFont2:End()

Return .T.


*-----------------*
FUNCTION IN100CC()
*-----------------*

AADD(TB_Cols,{ {|| Int_CC->NCCCOD                     }, "", STR0142                      }) //"Codigo"
AADD(TB_Cols,{ {|| Int_CC->NCCDESC                    }, "", STR0539                   }) //"Descricao"
AADD(TB_Cols,{ {|| Int_CC->NCCLE                      }, "", STR0286            }) //"Local de Entrega"
AADD(TB_Cols,{ {|| IF(SY2->(DBSEEK(cFilSY2+Int_CC->NCCLE)),SY2->Y2_DESC,"")}, "", STR0540 }) //"Desc. Local de Entrega"

ASIZE(TBRCols,0)
AADD(TBRCols,{ "IN100Status()"      , STR0036       }) //"Status"
AADD(TBRCols,{ "IN100Tipo()"        , STR0037         }) //"Tipo"
AADD(TBRCols,{ "IN100CTD(Int_CC->NCCINT_DT)", STR0071     }) //"Dt Integ"
AADD(TBRCols,{ "Int_CC->NCCCOD"             , STR0142       }) //"Codigo"
AADD(TBRCols,{ "Int_CC->NCCDESC"            , STR0539    }) //"Descricao"
AADD(TBRCols,{ "Int_CC->NCCLE"              , STR0311}) //"Local Entrega"

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"COLCC")
ENDIF

AADD(TB_Cols,{ {|| IN100E_Msg(.T.)            }, "", STR0112                    }) // "Mensagem"

RETURN .T.

*--------------------*
FUNCTION IN100LerCC()
*--------------------*
Local cAlias

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"LERCC")
ENDIF

IF EMPTY(Int_CC->NCCCOD)
   EVAL(bMsg,STR0541+STR0546) //"CODIGO DA UNID. REQ. NAOINFORMADO
ENDIF

IF ! SY3->(DBSEEK(cFilSY3+Int_CC->NCCCOD))

   IF Int_CC->NCCTIPO = EXCLUSAO        //  # INCLUSAO
      EVAL(bMsg,STR0541+STR0544) //"CODIGO DA UNID. REQ. SEMCADASTRO
   ENDIF

   IF Int_CC->NCCTIPO = ALTERACAO
      cAlias := Alias()
      Reclock( "Int_CC", .F. )
      DbSelectArea( cAlias )

      Int_CC->NCCTIPO := INCLUSAO

      Int_CC->( MsUnlock() )
   ENDIF

ELSEIF Int_CC->NCCTIPO = INCLUSAO
   EVAL(bMsg,STR0541+STR0545) //"CODIGO DA UNID. REQ. COMCADASTRO

ENDIF

IF Int_CC->NCCTIPO == EXCLUSAO
   IF EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"VALCC")
   ENDIF

   IN100VerErro(cErro,cAviso)
   IF Int_CC->NCCINT_OK = "T"
      nResumoCer+=1
   ELSE
      nResumoErr+=1
   ENDIF
   RETURN
ENDIF

IF EMPTY(Int_CC->NCCDESC) .AND. SY3->(EOF())
   EVAL(bMsg,STR0542+STR0546) //"DESCR. DA UNID.REQ. NAOINFORMADO
ENDIF

IF EMPTY(Int_CC->NCCLE) .AND. SY3->(EOF())
   EVAL(bMsg,STR0286+STR0546) //"LOCAL DE ENTREGA NAOINFORMADO
ENDIF

IF ! EMPTY(Int_CC->NCCLE) .AND. ! SY2->(DBSEEK(cFilSY2+Int_CC->NCCLE)) .AND. ! Int_Param->NPAINC_LE
   EVAL(bMsg,STR0286+STR0544) //"LOCAL DE ENTREGA SEMCADASTRO
ENDIF

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"VALCC")
ENDIF

IN100VerErro(cErro,cAviso)

IF Int_CC->NCCINT_OK = "T"
   nResumoCer+=1
ELSE
   nResumoErr+=1
ENDIF
RETURN .T.

*------------------------------------------------------------------------------------------*
FUNCTION IN100GrvCC()
*------------------------------------------------------------------------------------------*
LOCAL cAlias

IF Int_CC->NCCTIPO # INCLUSAO
   SY3->(DBSEEK(cFilSY3+Int_CC->NCCCOD))

   IF SY3->(EOF())  .AND.  Int_CC->NCCTIPO = ALTERACAO
      EVAL(bmsg,STR0543+STR0544+STR0141) //"CODIGO DA UNID. REA."### SEMCADASTRO P/ ALTERACAO"
      RETURN
   ENDIF
   cAlias:=ALIAS()
   Reclock("SY3",.F.)
   DBSELECTAREA(cAlias)

   IF Int_CC->NCCTIPO = EXCLUSAO
      SY3->(DBDELETE())
      SY3->(DBCOMMIT())
      SY3->(MSUNLOCK())
 
      If EasyEntryPoint("IN100CLI")
         ExecBlock("IN100CLI",.F.,.F.,"EXCCC")
      EndIf
      
      RETURN

   ENDIF
ENDIF

IF Int_CC->NCCTIPO = INCLUSAO
   IN100RecLock('SY3')
   SY3->Y3_FILIAL := cFilSY3
   SY3->Y3_COD    :=Int_CC->NCCCOD
ENDIF

IF(!EMPTY(Int_CC->NCCDESC)   ,SY3->Y3_DESC   := Int_CC->NCCDESC,)
IF(!EMPTY(Int_CC->NCCLE)     ,SY3->Y3_LE     := Int_CC->NCCLE,)

IF Int_Param->NPAINC_LE .AND. ! SY2->(DBSEEK(cFilSY2+AvKey(Int_CC->NCCLE,"Y2_SIGLA")))
   Int_CC->(IN100Cadastra(CAD_LE,Int_CC->NCCLE))
ENDIF

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"GRVCC")
ENDIF

SY3->(MSUNLOCK())

Return .T.
**************** INICIO NFE *****************************************************
*-----------------------------------------------------------------------------
FUNCTION IN100NFE()
*-----------------------------------------------------------------------------
Local lCposCofMj := SYD->(FieldPos("YD_MAJ_COF")) > 0 .And. SYT->(FieldPos("YT_MJCOF")) > 0 .And. SWN->(FieldPos("WN_VLCOFM")) > 0 .And.;
                    SWN->(FieldPos("WN_ALCOFM")) > 0  .And. SWZ->(FieldPos("WZ_TPCMCOF")) > 0 .And. SWZ->(FieldPos("WZ_ALCOFM")) > 0 .And.;
                    EIJ->(FieldPos("EIJ_ALCOFM")) > 0 .And. SW8->(FieldPos("W8_VLCOFM")) > 0 .And. EI2->(FieldPos("EI2_VLCOFM")) > 0   // GFP - 29/08/2014
TB_Col_D:={}

IF !lMV_PIS_EIC
   MSGINFO(STR0739)//"Sistema não preparado para Pis/Cofins" 
ENDIF
AADD(TB_Col_D,{ {||IN100Status()}                              ,"",STR0036 }) //"Status"
AADD(TB_Col_D,{ {||IN100TIPO() }                               ,"",STR0037 }) //"Tipo"
AADD(TB_Col_D,{ {||NFDNOTA}                                    ,"",cTitNFE }) //"Nota Fiscal de Entrada"
AADD(TB_Col_D,{ {||NFDSERIE}                                   ,"",STR0530 }) //"Serie da NF de Entrada"
AADD(TB_Col_D,{ {|| TRANSFORM(NFDCLASFIS,AVSX3("B1_POSIPI",6)) }    ,"",STR0125 }) //"N.C.M."
AADD(TB_Col_D,{ {||NFDEX_NCM }                                 ,"",STR0126 }) //"EX. N.C.M."
AADD(TB_Col_D,{ {||TRANSFORM(NFDCOD_I,_PictItem)}                   ,"",STR0120 }) //"Item"
AADD(TB_Col_D,{ {||LEFT(NFDDESCR,25)}                          ,"",STR0539 }) //"Descricao"
AADD(TB_Col_D,{ {||NFDUNI }                                    ,"",STR0121 }) //"Unidade"
AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDPESOL)  ,AVSX3("WN_PESOL",6))}   ,"",STR0127 }) //"Peso Liquido"
AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDQUANT)  ,cPictcom) }            ,"",STR0297 }) //"Qtde"
AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDVALOR ) ,cPict15_2)}            ,"",STR0565 }) //"Vlr. Mercadoria"
AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDFOBRS)  ,cPict15_2)}            ,"",STR0310 }) //"Valor FOB"
AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDFRETE ) ,cPict15_2)}            ,"",STR0446 }) //"Valor Frete"
AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDSEGURO) ,cPict15_2)}            ,"",STR0449 }) //"Valor Seguro"
AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDIITX  ) ,cPict05_2)}            ,"",STR0233 }) //"% II"
AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDII    ) ,cPict15_2)}            ,"",STR0567 }) //"I.I."
AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDIPITX ) ,cPict05_2)}            ,"",STR0234 }) //"% IPI"
AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDIPI   ) ,cPict15_2)}            ,"",STR0566 }) //"I.P.I."
AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDICMSTX ),cPict05_2)}            ,"",STR0235 }) //"% ICMS"   //NCF - 11/02/2011
AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDBASEICM),cPict15_2)}            ,"",AVSX3("WN_BASEICM",5) })
AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDICMS  ) ,cPict15_2)}            ,"",STR0568 }) //"I.C.M.S."
AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDDESPESA),cPict15_2)}            ,"",STR0469 }) //"Despesa"
AADD(TB_Col_D,{ {|| NFDITEM }                                  ,"",STR0296 }) //"Posição"
AADD(TB_Col_D,{ {|| NFDPO_NUM }                                ,"",STR0308 }) //"P.O."
AADD(TB_Col_D,{ {|| NFDPLI }                                   ,"",STR0578 }) //"P.L.I."
AADD(TB_Col_D,{ {|| NFDFATURA }                                ,"",AVSX3("W9_INVOICE",5) })
IF lMV_PIS_EIC
   AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDPERPIS),AVSX3("WN_PERPIS",6))},"",AVSX3("WN_PERPIS",5) })
   AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDVLUPIS),AVSX3("WN_VLUPIS",6))},"",AVSX3("WN_VLUPIS",5) })
   AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDBASPIS),AVSX3("WN_BASPIS",6))},"",AVSX3("WN_BASPIS",5) })
   AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDVLRPIS),AVSX3("WN_VLRPIS",6))},"",AVSX3("WN_VLRPIS",5) })
   AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDPERCOF),AVSX3("WN_PERCOF",6))},"",AVSX3("WN_PERCOF",5) })
   AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDVLUCOF),AVSX3("WN_VLUCOF",6))},"",AVSX3("WN_VLUCOF",5) })
   AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDBASCOF),AVSX3("WN_BASCOF",6))},"",AVSX3("WN_BASCOF",5) })
   AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDVLRCOF),AVSX3("WN_VLRCOF",6))},"",AVSX3("WN_VLRCOF",5) })
ENDIF
If lCposCofMj     // GFP - 30/07/2013
   AADD( TB_Col_D, { {|| TRANSFORM(NFDALMJCOF,AVSX3("WN_ALCOFM",6))},"",AVSX3("WN_ALCOFM",5) })//"% M.COFINS"
EndIf  

//LGS-27/06/2016 - % ICMS DIFERIMENTO
AADD(TB_Col_D, { {||TRAN(NFDPICMDIF  ,AVSX3("WZ_ICMSDIF" ,6))},"",AVSX3("WZ_ICMSDIF" ,5) })

IF lMV_GRCPNFE//Campos novos NFE - AWR 06/11/2008
   AADD(TB_Col_D,{"NFDADICAO" ,"","Adicao"     })
   AADD(TB_Col_D,{"NFDSEQ_ADI","","Seq. Adicao"})
   AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDDESCONI),AVSX3("WN_DESCONI",6))},"",AVSX3("WN_DESCONI",5) })
   AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDVLRIOF) ,AVSX3("WN_VLRIOF" ,6))},"",AVSX3("WN_VLRIOF" ,5) })
   AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDDESPADU),AVSX3("WN_DESPADU",6))},"",AVSX3("WN_DESPADU",5) })
   AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDALUIPI) ,AVSX3("WN_ALUIPI" ,6))},"",AVSX3("WN_ALUIPI" ,5) })
   AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDQTUIPI) ,AVSX3("WN_QTUIPI" ,6))},"",AVSX3("WN_QTUIPI" ,5) })
   AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDQTUPIS) ,AVSX3("WN_QTUPIS" ,6))},"",AVSX3("WN_QTUPIS" ,5) })
   AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDQTUCOF) ,AVSX3("WN_QTUCOF" ,6))},"",AVSX3("WN_QTUCOF" ,5) })
ENDIF

//THTS - 16/08/2019 - Projeto Recebimento de LI na integração (OSSME-3064)
AADD(TB_Col_D,{ {|| TRANSFORM(NFDPLIREG,AVSX3("WP_REGIST ",6)) }    ,"",AVSX3("WP_REGIST ",5) }) //No. PLI/Reg.
AADD(TB_Col_D,{ {|| TRANSFORM(NFDLISUBS,AVSX3("WP_SUBST  ",6)) }    ,"",AVSX3("WP_SUBST  ",5) }) //LI Sustitutiva

/* //THTS - 16/08/2019 - NOPADO da tela, pois os campos nao estao documentados no layout de integracao da Nota
//LGS-03/03/2015
IF SWN->(FieldPos("WN_NVE"))   # 0
   AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDNVE)  ,AVSX3("WN_NVE" ,6))},"",AVSX3("WN_NVE" ,5) })
ENDIF
IF SWN->(FieldPos("WN_AC"))    # 0
   AADD(TB_Col_D,{ {||TRANSFORM(VAL(NFDATO)  ,AVSX3("WN_AC" ,6))},"",AVSX3("WN_AC" ,5) })
ENDIF
IF SWN->(FieldPos("WN_AFRMM")) # 0
   AADD(TB_Col_D, { {||TRANSFORM(NFDAFRMM  ,AVSX3("WN_AFRMM" ,6))},"",AVSX3("WN_AFRMM" ,5) })
ENDIF
*/
IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"COLFD")
ENDIF

AADD(TB_Col_D,{ {|| IN100E_Msg(.T.)}                        ,"",STR0112} ) // "Mensagem" 

ASIZE(TB_Cols,0)
AADD(TB_Cols,{ {||IN100Status()}                           ,"",STR0036 }) //"Status"
AADD(TB_Cols,{ {||IN100TIPO() }                            ,"",STR0037 }) //"Tipo"
AADD(TB_Cols,{ {||IN100StaIte()}                           ,"",STR0048 }) //"Tem Item Rejeitado"
AADD(TB_Cols,{ {||Int_FE->NFENOTA}                         ,"",cTitNFE }) //"Nota Fiscal de Entrada"
AADD(TB_Cols,{ {||Int_FE->NFESERIE}                        ,"",STR0530 }) //"Serie da NF de Entrada"
AADD(TB_Cols,{ {||Int_FE->NFEHAWB}                         ,"",STR0527 }) //"Processo"
AADD(TB_Cols,{ {||Int_FE->NFECFOP}                         ,"",STR0581 }) //"C.F.O."
AADD(TB_Cols,{ {||Int_FE->NFEEXPORT+' '+Int_FE->NFENOMEXPO},"",STR0251 }) //"Fornecedor"
AADD(TB_Cols,{ {||IN100CTD(Int_FE->NFEDT_EMIS,,'AAAAMMDD')},"",STR0569 }) //"Emissao" //MJB-SAP-1100
AADD(TB_Cols,{ {||IN100CTD(Int_FE->NFEDT_ENTR,,'AAAAMMDD')},"",STR0301 }) //"Entrega" //MJB-SAP-1100
AADD(TB_Cols,{ {||TRANSFORM(VAL(Int_FE->NFEFRETE  ),cPict15_2)} ,"",STR0446 }) //"Valor Frete"
AADD(TB_Cols,{ {||TRANSFORM(VAL(Int_FE->NFESEGURO ),cPict15_2)} ,"",STR0449 }) //"Valor Seguro"
AADD(TB_Cols,{ {||TRANSFORM(VAL(Int_FE->NFEVALMERC),cPict15_2)} ,"",STR0565 }) //"Vlr. Mercadoria"
AADD(TB_Cols,{ {||TRANSFORM(VAL(Int_FE->NFETOTNOTA),cPict15_2)} ,"",STR0536 }) //"Valor da NF"
AADD(TB_Cols,{ {||TRANSFORM(VAL(Int_FE->NFEBASEIPI),cPict15_2)} ,"",STR0570 }) //"Base IPI"
AADD(TB_Cols,{ {||TRANSFORM(VAL(Int_FE->NFEIPI    ),cPict15_2)} ,"",STR0566 }) //"I.P.I."
AADD(TB_Cols,{ {||TRANSFORM(VAL(Int_FE->NFEBASEICM),cPict15_2)} ,"",STR0571 }) //"Base ICMS"
AADD(TB_Cols,{ {||TRANSFORM(VAL(Int_FE->NFEICMSTX ),cPict05_2)} ,"",STR0235 }) //"% ICMS"
AADD(TB_Cols,{ {||TRANSFORM(VAL(Int_FE->NFEICMS   ),cPict15_2)} ,"",STR0568 }) //"I.C.M.S."
AADD(TB_Cols,{ {||TRANSFORM(VAL(Int_FE->NFEQTDITEM),'99'     )} ,"",STR0297+' '+STR0426 }) //"Qtde" "Item "
IF lMV_GRCPNFE//Campo novo NFE - AWR 04/11/2008
   AADD(TB_Cols,{ {||TRANSFORM(VAL(Int_FE->NFEPREDICM),AVSX3("WN_PREDICM",6))},"",AVSX3("WN_PREDICM",5) })
ENDIF
IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"COLFE")
ENDIF
AADD(TB_Cols,{ {|| IN100E_Msg(.T.)}                         ,"",STR0112} ) // "Mensagem"       

RETURN .T.

*-----------------------------------------------------------*
Function MarkBrw(cArea,TB_Cols,lInverte,cMarca,oDlg2,lGeral)
*-----------------------------------------------------------*
// GFP 26/08/2011 - Alteração de tamanho do MSSelect para servir as versões 11 e 11.5
oMark:=MsSelect():New( cArea ,,,TB_Cols,@lInverte,@cMarca,{/*35*/40,1,(oDlg2:nHeight+95/*-30*/)/2,(oDlg2:nClientWidth-4)/2},IF(!lGeral,"IN100Filtro(.T.)",),IF(!lGeral,"IN100Filtro(.F.)",),oDlg2)
oMark:oBrowse:bWhen:={|| DBSELECTAREA(cArea),.T.}

//FDR - 07/05/12
oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

If lGeral
   (cArea)->(DbGoTop())
Else
   (cArea)->(DbSeek(cParamInic))
EndIf
oMark:oBrowse:SetFocus()
IF ! lGERAL //LCS.28/04/2009 - 11:55
   IN100FOCUS() //LCS.28/04/2009 - 11:55
ENDIF //LCS.28/04/2009 - 11:55
Return nil

*--------------------*
Function IN100LERRD()
*--------------------*
  If EasyEntryPoint("IN100CLI")
     ExecBlock("IN100CLI",.F.,.F.,"LERRD")
  EndIf
Return nil

*--------------------*
Function IN100GRVRD()
*--------------------*
  If EasyEntryPoint("IN100CLI")
     ExecBlock("IN100CLI",.F.,.F.,"GRVRD")
  EndIf
Return nil

*---------------------------*
Function In100DefEstru(cArq)
*---------------------------*
Local i, cAux := '', aAux := {}
Local lCposCofMj := SYD->(FieldPos("YD_MAJ_COF")) > 0 .And. SYT->(FieldPos("YT_MJCOF")) > 0 .And. SWN->(FieldPos("WN_VLCOFM")) > 0 .And.;
                    SWN->(FieldPos("WN_ALCOFM")) > 0  .And. SWZ->(FieldPos("WZ_TPCMCOF")) > 0 .And. SWZ->(FieldPos("WZ_ALCOFM")) > 0 .And.;
                    EIJ->(FieldPos("EIJ_ALCOFM")) > 0 .And. SW8->(FieldPos("W8_VLCOFM")) > 0 .And. EI2->(FieldPos("EI2_VLCOFM")) > 0   // GFP - 29/08/2014

Do Case
                                                                                         
   Case cArq == "PA" // Arquivo de Parametros
        AADD(aEstruDef,{"NPAEMP"    ,"C", 2,0})
        AADD(aEstruDef,{"NPAFILIAL" ,"C", Len(SM0->M0_CODFIL),0}) //DFS - 13/03/12 - Pegar o tamanho da filial no SIGAMAT
        AADD(aEstruDef,{"NPAUSUARIO","C",20,0})
        AADD(aEstruDef,{"NPAULT_FE" ,"D", 8,0})
        AADD(aEstruDef,{"NPAULT_TP" ,"D", 8,0})
        AADD(aEstruDef,{"NPAULT_SP" ,"D", 8,0})
        AADD(aEstruDef,{"NPAULT_CI" ,"D", 8,0})
        AADD(aEstruDef,{"NPAULT_FB" ,"D", 8,0})
        AADD(aEstruDef,{"NPAULT_LI" ,"D", 8,0})
        AADD(aEstruDef,{"NPAULT_NB" ,"D", 8,0})
        AADD(aEstruDef,{"NPAULT_FP" ,"D", 8,0})
        AADD(aEstruDef,{"NPAULT_TC" ,"D", 8,0})
        AADD(aEstruDef,{"NPAULT_DE" ,"D", 8,0})
        AADD(aEstruDef,{"NPAULT_DI" ,"D", 8,0})
        AADD(aEstruDef,{"NPAULT_CC" ,"D", 8,0})
        AADD(aEstruDef,{"NPAULT_CL" ,"D", 8,0})
        AADD(aEstruDef,{"NPAULT_FF" ,"D", 8,0})
        AADD(aEstruDef,{"NPAULT_IT" ,"D", 8,0})
        AADD(aEstruDef,{"NPAULT_PE" ,"D", 8,0})
        AADD(aEstruDef,{"NPAULT_LK" ,"D", 8,0})
        AADD(aEstruDef,{"NPAULT_NU" ,"D", 8,0})
        AADD(aEstruDef,{"NPAULT_NS" ,"D", 8,0})
        AADD(aEstruDef,{"NPAULT_EP" ,"D", 8,0})
        AADD(aEstruDef,{"NPAULT_UC" ,"D", 8,0})
        AADD(aEstruDef,{"NPAULT_CE" ,"D", 8,0})
        AADD(aESTRUDEF,{"NPAULT_NC" ,"D", 8,0})
        AADD(aEstruDef,{"NPAARQ_TP" ,"C", 8,0})
        AADD(aEstruDef,{"NPAARQ_FE" ,"C", 8,0})
        AADD(aEstruDef,{"NPAARQ_H"  ,"C", 8,0})
        AADD(aEstruDef,{"NPAARQ_I"  ,"C", 8,0})
        AADD(aEstruDef,{"NPAARQ_CI" ,"C", 8,0})
        AADD(aEstruDef,{"NPAARQ_FB" ,"C", 8,0})
        AADD(aEstruDef,{"NPAARQ_LI" ,"C", 8,0})
        AADD(aEstruDef,{"NPAARQ_NB" ,"C", 8,0})
        AADD(aEstruDef,{"NPAARQ_TC" ,"C", 8,0})
        AADD(aEstruDef,{"NPAARQ_FP" ,"C", 8,0})
        AADD(aEstruDef,{"NPAARQ_DE" ,"C", 8,0})
        AADD(aEstruDef,{"NPAARQ_DI" ,"C", 8,0})
        AADD(aEstruDef,{"NPAARQ_CC" ,"C", 8,0})
        AADD(aEstruDef,{"NPAARQ_LK" ,"C", 8,0})
        AADD(aEstruDef,{"NPAARQ_NU" ,"C", 8,0})
        AADD(aEstruDef,{"NPAARQ_TMP","C",30,0})
        AADD(aEstruDef,{"NPAARQ_CL" ,"C", 8,0})
        AADD(aEstruDef,{"NPAARQ_FF" ,"C", 8,0})
        AADD(aEstruDef,{"NPAARQ_IT" ,"C", 8,0})
        AADD(aEstruDef,{"NPAARQ_ID" ,"C", 8,0})
        AADD(aEstruDef,{"NPAARQ_PE" ,"C", 8,0})
        AADD(aEstruDef,{"NPAARQ_PD" ,"C", 8,0})
        AADD(aEstruDef,{"NPAARQ_NS" ,"C", 8,0})
        AADD(aEstruDef,{"NPAARQ_EP" ,"C", 8,0})
        AADD(aEstruDef,{"NPAARQ_CE" ,"C", 8,0})
        AADD(aEstruDef,{"NPAARQ_UC" ,"C", 8,0})
        AADD(aESTRUDEF,{"NPAARQ_NC" ,"C", 8,0})
        AADD(aESTRUDEF,{"NPAARQ_ND" ,"C", 8,0})
        AADD(aEstruDef,{"NPAINC_CI" ,"L", 1,0})
        AADD(aEstruDef,{"NPAINC_FA" ,"L", 1,0})
        AADD(aEstruDef,{"NPAINC_FO" ,"L", 1,0})
        AADD(aEstruDef,{"NPAINC_LI" ,"L", 1,0})
        AADD(aEstruDef,{"NPAINC_CO" ,"L", 1,0})
        AADD(aEstruDef,{"NPAINC_LE" ,"L", 1,0})
        AADD(aEstruDef,{"NPAINC_CC" ,"L", 1,0})
        AADD(aEstruDef,{"NPAINC_AG" ,"L", 1,0})
        AADD(aEstruDef,{"NPAINC_FW" ,"L", 1,0})
        AADD(aEstruDef,{"NPAINC_IMP","L", 1,0})
        AADD(aEstruDef,{"NPAINC_CON","L", 1,0})
        AADD(aEstruDef,{"NPAINC_NBM","L", 1,0})
        AADD(aEstruDef,{"NPAINC_FAM","L", 1,0})
        AADD(aEstruDef,{"NPAINC_BAN","L", 1,0})
        AADD(aEstruDef,{"NPAINC_UNI","L", 1,0})
        AADD(aEstruDef,{"NPAINC_NS" ,"L", 1,0})
        IF lTemED9Cpos//AWR - 07/04/2009
           AADD(aEstruDef,{"NPAULT_NR" ,"D", 8,0})
           AADD(aEstruDef,{"NPAARQ_NR" ,"C", 8,0})
        ENDIF

        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"PA")
        EndIf


   Case cArq == "CI"  // Arquivo de Itens
        AADD(aEstruDef,{"NCITIPO"   ,"C",  1,0})
        AADD(aEstruDef,{"NCIINT_DT" ,"C",  6,0})
        AADD(aEstruDef,{"NCICOD_I"  ,"C", 30,0})
        AADD(aEstruDef,{"NCIUNI"    ,"C",  3,0})
        AADD(aEstruDef,{"NCIDESC_P" ,"C",360,0})
        AADD(aEstruDef,{"NCIDESC_I" ,"C",360,0})
        AADD(aEstruDef,{"NCIDESC_GI","C",480,0})
        AADD(aEstruDef,{"NCITEC"    ,"C",  8,0})
        AADD(aEstruDef,{"NCIPESO_L" ,"C", 18,0})
        AADD(aEstruDef,{"NCIVLREF_U","C", 15,0})
        AADD(aEstruDef,{"NCIFPCOD"  ,"C",  2,0})
        AADD(aEstruDef,{"NCIANUENTE","C",  1,0})
        AADD(aEstruDef,{"NCIQUALTEC","C",  3,0})

        If lEIC_EEC .Or. cModulo == "EDC"                                 //MJB-SAP-1100
           AADD(aEstruDef,{"NCIEMBAL"  ,"C", 20,0})                       //MJB-SAP-1100
           AADD(aEstruDef,{"NCIQTDEMB" ,"C", 10,0})                       //MJB-SAP-1100
           If SB1->(FieldPos("B1_IMPORT")) > 0
              AADD(aEstruDef,{"NCIIMPORT","C",  1,0}) //AOM - Produto Importado (B1_IMPORT)
           EndIf
           AADD(aEstruDef,{"NCIITEM_OK","C",  1,0})                       //MJB-SAP-1100
        Endif 

        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"CI")
        EndIf

        AADD(aEstruDef,{"NCIINT_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NCIMSG"    ,"M", 10,0})

   Case cArq == "FB"  // Arquivo de Fabricante / Fornecedor
        AADD(aEstruDef,{"NFBTIPO"   ,"C",  1,0})
        AADD(aEstruDef,{"NFBINT_DT" ,"C",  6,0})
        AADD(aEstruDef,{"NFBCOD"    ,"C",  nLenForn,0})//SO.:0026 OS.:0232/02 FCD
        AADD(aEstruDef,{"NFBNOME"   ,"C", 40,0})
        AADD(aEstruDef,{"NFBNOME_R" ,"C", 15,0})
        AADD(aEstruDef,{"NFBEND"    ,"C", 40,0})
        AADD(aEstruDef,{"NFBNR_END" ,"C",  6,0})
        AADD(aEstruDef,{"NFBBAIRRO" ,"C", 20,0})
        AADD(aEstruDef,{"NFBCIDADE" ,"C", 20,0})
        AADD(aEstruDef,{"NFBESTADO" ,"C", 20,0})
        AADD(aEstruDef,{"NFBCOD_P"  ,"C",  3,0})
        AADD(aEstruDef,{"NFBCEP"    ,"C",  8,0})
        AADD(aEstruDef,{"NFBCX_POST","C",  5,0})
        AADD(aEstruDef,{"NFBCONTATO","C", 50,0})
        AADD(aEstruDef,{"NFBDEPTO"  ,"C", 30,0})
        AADD(aEstruDef,{"NFBFONES"  ,"C", 50,0})
        AADD(aEstruDef,{"NFBTELEX"  ,"C", 20,0})
        AADD(aEstruDef,{"NFBFAX"    ,"C", 20,0})
        AADD(aEstruDef,{"NFB_ID_FBF","C",  1,0})
        AADD(aEstruDef,{"NFBSTATUS" ,"C",  1,0})
        AADD(aEstruDef,{"NFBREPRES" ,"C", 52,0})
        AADD(aEstruDef,{"NFBREPR_EN","C", 52,0})
        AADD(aEstruDef,{"NFBID_REPR","C",  1,0})
        AADD(aEstruDef,{"NFBREPR_BA","C",  4,0})
        AADD(aEstruDef,{"NFBREPR_AG","C",  7,0})
        AADD(aEstruDef,{"NFBREPR_CO","C", 11,0})
        AADD(aEstruDef,{"NFBREPR_CG","C", 14,0})
        AADD(aEstruDef,{"NFBFORN_BA","C",  4,0})
        AADD(aEstruDef,{"NFBFORN_AG","C",  7,0})
        AADD(aEstruDef,{"NFBFORN_CO","C", 20,0})
        AADD(aEstruDef,{"NFBCOMI_SO","C",  1,0})
        AADD(aEstruDef,{"NFBRET_PAI","C",  1,0})
        AADD(aEstruDef,{"NFBPROC_1" ,"C",  3,0})
        AADD(aEstruDef,{"NFBPROC_2" ,"C",  3,0})
        AADD(aEstruDef,{"NFBPROC_3" ,"C",  3,0})
        AADD(aEstruDef,{"NFBREPRTEL","C", 50,0})
        AADD(aEstruDef,{"NFBREPRFAX","C", 20,0})
        AADD(aEstruDef,{"NFBREPCONT","C", 50,0})
        AADD(aEstruDef,{"NFBREPRMUN","C", 20,0})
        AADD(aEstruDef,{"NFBREPREST","C", 20,0})
        AADD(aEstruDef,{"NFBREPPAIS","C",  3,0})
        AADD(aEstruDef,{"NFBREPRCEP","C",  8,0})
        AADD(aEstruDef,{"NFBSWIFT"  ,"C", 30,0})
        AADD(aEstruDef,{"NFBREPRBAI","C", 20,0})
        AADD(aEstruDef,{"NFBREPREMA","C", 30,0})
        AADD(aEstruDef,{"NFBEMAIL"  ,"C", 30,0})
        AADD(aEstruDef,{"NFBCEP2"   ,"C", 10,0})

        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"FB")
        EndIf

        AADD(aEstruDef,{"NFBINT_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NFBMSG"    ,"M", 10,0})

   Case cArq == "NB"  // Arquivo de NCM
        AADD(aEstruDef,{"NNBTIPO"   ,"C",  1,0})
        AADD(aEstruDef,{"NNBINT_DT" ,"C",  6,0})
        AADD(aEstruDef,{"NNBNCM"    ,"C",  8,0})
        AADD(aEstruDef,{"NNBNALADI" ,"C",  7,0})
        AADD(aEstruDef,{"NNBNAL_SH" ,"C",  8,0})
        AADD(aEstruDef,{"NNBDESC_P" ,"C", 40,0})
        AADD(aEstruDef,{"NNBALADI"  ,"C",  3,0})
        AADD(aEstruDef,{"NNBPER_II" ,"C",  6,0})
        AADD(aEstruDef,{"NNBPER_IPI","C",  6,0})
        AADD(aEstruDef,{"NNBICMS_RE","C",  6,0})
        AADD(aEstruDef,{"NNBUNID"   ,"C",  3,0})
        AADD(aEstruDef,{"NNBDL_NALA","C", 10,0})
        AADD(aEstruDef,{"NNBDL_GATT","C", 10,0})
        AADD(aEstruDef,{"NNBQUALNCM","C",  3,0})
        AADD(aEstruDef,{"NNBDESTAQU","C",  3,0})

        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"NB")
        EndIf

        AADD(aEstruDef,{"NNBINT_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NNBMSG"    ,"M", 10,0})

   Case cArq == "TC"  // Arquivo de Taxas
        AADD(aEstruDef,{"NTCTIPO"   ,"C",  1,0})
        AADD(aEstruDef,{"NTCINT_DT" ,"C",  6,0})  // 8 Para ano com 4 digitos exportacao
        AADD(aEstruDef,{"NTCDATA"   ,"C",  6,0})  // 8 Para ano com 4 digitos exportacao
        AADD(aEstruDef,{"NTCMOEDA"  ,"C",  3,0})
        AADD(aEstruDef,{"NTCVLCON_C","C", 15,0})
        AADD(aEstruDef,{"NTCVLFISCA","C", 15,0})
        AADD(aEstruDef,{"NTCVLCOMPR","C", 15,0})

        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"TC")
        EndIf

        AADD(aEstruDef,{"NTCINT_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NTCMSG"    ,"M", 10,0})

   Case cArq == "PO"  // Arquivo de P.O.
        AADD(aEstruDef,{"NPOTIPO"   ,"C",  1,0})
        AADD(aEstruDef,{"NPOINT_DT" ,"C",  6,0})
        AADD(aEstruDef,{"NPOMODELO" ,"C",  2,0})
        AADD(aEstruDef,{"NPOPO_NUM" ,"C", If( AvFlags("AVINTEG") , AVSX3("W3_PO_NUM",3) , 15  ),0})
        AADD(aEstruDef,{"NPOPO_DT"  ,"C",  6,0})
        AADD(aEstruDef,{"NPO_POLE"  ,"C",  2,0})
        AADD(aEstruDef,{"NPOCOMPRA" ,"C",  3,0})
        AADD(aEstruDef,{"NPOTIPO_EM","C",  2,0})
        AADD(aEstruDef,{"NPOORIGEM" ,"C",  3,0})
        AADD(aEstruDef,{"NPODEST"   ,"C",  3,0})
        AADD(aEstruDef,{"NPOCOND_PA","C",  5,0})
        AADD(aEstruDef,{"NPODIAS_PA","C",  3,0})
        AADD(aEstruDef,{"NPOAGENTE" ,"C",  3,0})
        AADD(aEstruDef,{"NPOIMPORT" ,"C",  2,0})
        AADD(aEstruDef,{"NPOMOEDA"  ,"C",  3,0})
        AADD(aEstruDef,{"NPOINLAND" ,"C", 15,0})
        AADD(aEstruDef,{"NPOPACKING","C", 15,0})
        AADD(aEstruDef,{"NPODESCONT","C", 15,0})
        AADD(aEstruDef,{"NPOFRETEIN","C", 15,0})
        AADD(aEstruDef,{"NPOFREPPCC","C",  2,0})
        AADD(aEstruDef,{"NPOCONSIG" ,"C",  2,0})
        AADD(aEstruDef,{"NPOFORN"   ,"C",  nLenForn,0})//SO.:0026 OS.:0232/02 FCD
        AADD(aEstruDef,{"NPONR_PRO" ,"C", 15,0})
        AADD(aEstruDef,{"NPODT_PRO" ,"C",  6,0})
        AADD(aEstruDef,{"NPOPARID_U","C", 13,0})
        AADD(aEstruDef,{"NPODT_PAR" ,"C",  6,0})
        AADD(aEstruDef,{"NPOPESO_B" ,"C", 13,0})
        AADD(aEstruDef,{"NPOCLIENTE","C",  nLenCli,0})//SO.:0026 OS.:0232/02 FCD
        AADD(aEstruDef,{"NPOFORWARD","C",  3,0})
        AADD(aEstruDef,{"NPOINCOTER","C",  3,0})
        AADD(aEstruDef,{"NPOFILL_01","C",  5,0})
        AADD(aEstruDef,{"NPOOBS"    ,"C",420,0})
        AADD(aEstruDef,{"NPOSEQ_PO" ,"C",  6,0})

        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"PO")
        EndIf

        AADD(aEstruDef,{"NPOINT_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NPOFOB_TOT","N", 15,2})
        AADD(aEstruDef,{"NPOITEM_OK","C",  1,0})
        AADD(aEstruDef,{"NPOMSG"    ,"M", 10,0})
        
   Case cArq == "IP"  // Arquivo de Itens do P.O.
        AADD(aEstruDef,{"NIPPO_NUM" ,"C", 15,0})
        AADD(aEstruDef,{"NIPCOD_I"  ,"C", 30,0})
        AADD(aEstruDef,{"NIPCC"     ,"C",  nLenCC,0})  //SO.:0026 OS.:0232/02 FCD
        AADD(aEstruDef,{"NIPSI_NUM" ,"C",  nLenSI,0})  //SO.:0026 OS.:0232/02 FCD
        AADD(aEstruDef,{"NIPFABR"   ,"C",  nLenFabr,0})//SO.:0026 OS.:0232/02 FCD
        AADD(aEstruDef,{"NIPQTDE"   ,"C", 13,0})
        AADD(aEstruDef,{"NIPDT_EMB" ,"C",  6,0})
        AADD(aEstruDef,{"NIPDT_ENTR","C",  6,0})
        AADD(aEstruDef,{"NIPPRECO"  ,"C", 15,0})
        AADD(aEstruDef,{"NIPCLASS"  ,"C",  1,0})
        AADD(aEstruDef,{"NIPFABR_01","C",  nLenFabr,0})//SO.:0026 OS.:0232/02 FCD
        AADD(aEstruDef,{"NIPFABR_02","C",  nLenFabr,0})//SO.:0026 OS.:0232/02 FCD
        AADD(aEstruDef,{"NIPFABR_03","C",  nLenFabr,0})//SO.:0026 OS.:0232/02 FCD
        AADD(aEstruDef,{"NIPFABR_04","C",  nLenFabr,0})//SO.:0026 OS.:0232/02 FCD
        AADD(aEstruDef,{"NIPFABR_05","C",  nLenFabr,0})//SO.:0026 OS.:0232/02 FCD
        AADD(aEstruDef,{"NIPPOSICAO","C",nTamPosicao,0})
        AADD(aEstruDef,{"NIPSEQ_PO" ,"C",  6,0})
        AADD(aEstruDef,{"NIPSEQ_IP" ,"C",  6,0})
        AADD(aEstruDef,{"NIPFLUXO"  ,"C",  1,0})
        AADD(aEstruDef,{"NIPTIPO"   ,"C",  1,0})
        AADD(aEstruDef,{"NIPTEC"    ,"C",  8,0})
        AADD(aEstruDef,{"NIPEX_NCM" ,"C",  3,0})
        AADD(aEstruDef,{"NIPEX_NBM" ,"C",  3,0})

        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"IP")
        EndIf

        AADD(aEstruDef,{"NIPINCLUI" ,"C",  3,0})
        AADD(aEstruDef,{"NIPREG"    ,"C",nTamReg,0})
        AADD(aEstruDef,{"NIPINT_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NIPMSG"    ,"M", 10,0})

   Case cArq == "SI"  // Arquivo de S.I.
        AADD(aEstruDef,{"NSITIPO"   ,"C",  1,0})
        AADD(aEstruDef,{"NSIINT_DT" ,"C",  6,0})
        AADD(aEstruDef,{"NSIMODELO" ,"C",  2,0})
        AADD(aEstruDef,{"NSI_CC"    ,"C",  nLenCC,0}) //SO.:0026 OS.:0232/02 FCD
        AADD(aEstruDef,{"NSI_NUM"   ,"C",  nLenSI,0}) //SO.:0026 OS.:0232/02 FCD
        AADD(aEstruDef,{"NSI_DT"    ,"C",  6,0})
        AADD(aEstruDef,{"NSI_POLE"  ,"C",  2,0})
        AADD(aEstruDef,{"NSICOMPRA" ,"C",  3,0})
        AADD(aEstruDef,{"NSISOLIC"  ,"C", 40,0})
        AADD(aEstruDef,{"NSIREFER1" ,"C", 11,0})
        AADD(aEstruDef,{"NSISEQ_SI" ,"C",  6,0})

        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"SI")
        EndIf

        AADD(aEstruDef,{"NSIINT_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NSIITEM_OK","C",  1,0})
        AADD(aEstruDef,{"NSIMSG"    ,"M", 10,0})        

   Case cArq == "IS"  // Arquivo Itens da S.I.
        AADD(aEstruDef,{"NISCC"     ,"C",  nLenCC,0})//SO.:0026 OS.:0232/02 FCD
        AADD(aEstruDef,{"NISSI_NUM" ,"C",  nLenSi,0})//SO.:0026 OS.:0232/02 FCD
        AADD(aEstruDef,{"NISCOD_I"  ,"C", 30,0})
        AADD(aEstruDef,{"NISQTDE"   ,"C", 13,0})
        AADD(aEstruDef,{"NISDTENTR_","C",  6,0})
        AADD(aEstruDef,{"NISFABR"   ,"C",  nLenFabr,0})//SO.:0026 OS.:0232/02 FCD
        AADD(aEstruDef,{"NISFORN"   ,"C",  nLenForn,0})//SO.:0026 OS.:0232/02 FCD
        AADD(aEstruDef,{"NISCLASS"  ,"C",  1,0})
        AADD(aEstruDef,{"NISPOSICAO","C",nTamPosicao,0})
        AADD(aEstruDef,{"NISSEQ_SI" ,"C",  6,0})
        AADD(aEstruDef,{"NISSEQ_IS" ,"C",  6,0})
        AADD(aEstruDef,{"NISTIPO"   ,"C",  1,0})

        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"IS")
        EndIf

        AADD(aEstruDef,{"NISREG"    ,"C",  AVSX3("W1_REG",3),0})
        AADD(aEstruDef,{"NISINCLUI" ,"C",  3,0})
        AADD(aEstruDef,{"NISINT_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NISMSG"    ,"M", 10,0})        

   Case cArq == "LI"  // Arquivo de Itens/Fabr./Forn.
        AADD(aEstruDef,{"NLITIPO"   ,"C",  1,0})
        AADD(aEstruDef,{"NLIINT_DT" ,"C",  6,0})
        AADD(aEstruDef,{"NLICOD_I"  ,"C", 30,0})
        AADD(aEstruDef,{"NLIFABR"   ,"C",  nLenFabr,0})//SO.:0026 OS.:0232/02 FCD
        AADD(aEstruDef,{"NLIFORN"   ,"C",  nLenForn,0})//SO.:0026 OS.:0232/02 FCD
        AADD(aEstruDef,{"NLIPART_N" ,"C", 20,0})
        AADD(aEstruDef,{"NLISTATUS" ,"C",  1,0})
        AADD(aEstruDef,{"NLIVLCOT_U","C", 15,0})
        AADD(aEstruDef,{"NLILEAD_T" ,"C",  5,0})
        AADD(aEstruDef,{"NLIQT_COT" ,"C", 13,0})
        AADD(aEstruDef,{"NLIULT_ENT","C",  6,0})
        AADD(aEstruDef,{"NLIULT_FOB","C", 15,0})
        AADD(aEstruDef,{"NLILOTE_MI","C",  8,0})
        AADD(aEstruDef,{"NLILOTE_MU","C",  8,0})
        AADD(aEstruDef,{"NLIPART_OP","C", 48,0})
        AADD(aEstruDef,{"NLIMOE_US" ,"C",  3,0})
        AADD(aEstruDef,{"NLIUNID"   ,"C",  3,0})

        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"LI")
        EndIf

        AADD(aEstruDef,{"NLIINT_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NLIMSG"    ,"M", 10,0})       

   Case cArq == "TP"  // Arquivo de TABELAS DE PRECO
        AADD(aEstruDef,{"NTPTIPO"   ,"C",  1,0})
        AADD(aEstruDef,{"NTPINT_DT" ,"C",  8,0})	        
        AADD(aEstruDef,{"NTPPRO"    ,"C",  15,0})
        AADD(aEstruDef,{"NTPPAI"    ,"C",  3,0})
        AADD(aEstruDef,{"NTPMPA"    ,"C",  3,0})
        AADD(aEstruDef,{"NTPPPA"    ,"C",  17,0})
        AADD(aEstruDef,{"NTPINI"    ,"C",  8,0})
        AADD(aEstruDef,{"NTPFIM"    ,"C",  8,0})
        AADD(aEstruDef,{"NTPCLI"    ,"C",  6,0})
        AADD(aEstruDef,{"NTPMCL"    ,"C",  3,0})
        AADD(aEstruDef,{"NTPLOJ"    ,"C",  2,0})
        AADD(aEstruDef,{"NTPPR1"    ,"C",  17,0})                
        AADD(aEstruDef,{"NTPIN2"    ,"C",  8,0})
        AADD(aEstruDef,{"NTPFI2"    ,"C",  8,0}) 
        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"TP")
        EndIf
        AADD(aEstruDef,{"NTPTIP2"   ,"C",  1,0})  //Tipo Auxiliar
        AADD(aEstruDef,{"NTPINT_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NTPMSG"    ,"M", 10,0})

   Case cArq == "FP"  // Arquivo de Familia de Itens.
        AADD(aEstruDef,{"NFPTIPO"   ,"C",  1,0})
        AADD(aEstruDef,{"NFPINT_DT" ,"C",  6,0})
        AADD(aEstruDef,{"NFPCOD"    ,"C",  2,0})
        AADD(aEstruDef,{"NFPNOME"   ,"C", 25,0})
        If cModulo = "EEC"
           AADD(aEstruDef,{"NFPIDIOMA","C",  6,0})
           AADD(aEstruDef,{"NFPGRUPO" ,"C", 15,0})        
        ENDIF

        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"FP")
        EndIf

        AADD(aEstruDef,{"NFPINT_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NFPMSG"    ,"M", 10,0})

   Case cArq == "DE"  // Arquivo de Despesas do Despachante.
        AADD(aEstruDef,{"NDETIPOREG","C",  2,0})
        AADD(aEstruDef,{"NDEHOUSE"  ,"C", 18,0})
        AADD(aEstruDef,{"NDEDADOS"  ,"C",667,0})
        
        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"DE")
        EndIf
        
        AADD(aEstruDef,{"NDETIPO"   ,"C",  1,0})
        AADD(aEstruDef,{"NDEINT_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NDEINT_DT" ,"C",  6,0})
        AADD(aEstruDef,{"NDEMSG"    ,"M", 10,0})
        AADD(aEstruDef,{"NDE_Grava" ,"C",  1,0})//ASR 19/11/2005 - CAMPO PARA CONTROLE SE A DESPESA SERÁ GRAVADA

   Case cArq == "DH"  // Arquivo de Despesas do Despachante 2.
        AADD(aEstruDef,{"NDHTIPOREG","C", 02,0}) // RHP
        AADD(aEstruDef,{"NDHHOUSE"  ,"C", 18,0})
        AADD(aEstruDef,{"NDHDCHEG"  ,"C",  8,0})
        AADD(aEstruDef,{"NDHDRECDOC","C",  8,0})
        AADD(aEstruDef,{"NDHDESP"   ,"C",  3,0})
        AADD(aEstruDef,{"NDHAGENTE" ,"C",  3,0})
        AADD(aEstruDef,{"NDHDPAGIMP","C",  8,0})
        AADD(aEstruDef,{"NDHDI_NUM" ,AVSX3("W6_DI_NUM",2), 10,0})
        AADD(aEstruDef,{"NDHTX_FOB" ,"N", 15,8})
        AADD(aEstruDef,{"NDHDDESEMB","C",  8,0})
        AADD(aEstruDef,{"NDHFRETMOE","C",  3,0})
        AADD(aEstruDef,{"NDHFRETVAL","N", 15,2})
        AADD(aEstruDef,{"NDHFRETTAX","N", 15,8})
        AADD(aEstruDef,{"NDHSEGUVAL","N", 15,2})
        AADD(aEstruDef,{"NDHSEGUMOE","C",  3,0})
        AADD(aEstruDef,{"NDHSEGUTAX","N", 15,8})
        AADD(aEstruDef,{"NDHTX_USD" ,"N", 15,8})
        AADD(aEstruDef,{"NDHREFDESP","C", 15,0})
        AADD(aEstruDef,{"NDHMASTER" ,"C", 18,0})
        AADD(aEstruDef,{"NDHTIPODEC","N",  2,0})
        AADD(aEstruDef,{"NDHURFDESP","N",  7,0})
        AADD(aEstruDef,{"NDHURFENTR","N",  7,0})
        AADD(aEstruDef,{"NDHRECALFA","C",  7,0})
        AADD(aEstruDef,{"NDHMODALDE","C",  1,0})
        AADD(aEstruDef,{"NDHTIPOCON","C",  2,0})
        AADD(aEstruDef,{"NDHTIPODOC","C",  2,0})
        AADD(aEstruDef,{"NDHUTILCON","C",  1,0})
        AADD(aEstruDef,{"NDHIDENTIF","C", 15,0})
        AADD(aEstruDef,{"NDHPESOBRU","N", 15,4})
        AADD(aEstruDef,{"NDHFOB_TOT","N", 15,2})
        AADD(aEstruDef,{"NDHFAT_DES","C",  6,0})
        AADD(aEstruDef,{"NDHNF_ENT" ,"C", 20,0})
        AADD(aEstruDef,{"NDHDT_NF"  ,"C",  8,0})
        AADD(aEstruDef,{"NDHVL_NF"  ,"N", 15,2})
        AADD(aEstruDef,{"NDHDT_ENTR","C",  8,0})
        //Campos novos - AWR 22/4/2003
        AADD(aEstruDef,{"NDHDTREGDI","C",  8,0})
        AADD(aEstruDef,{"NDHVLFRECC","N", 15,2})
        AADD(aEstruDef,{"NDHVLFRETN","N", 15,2})
        AADD(aEstruDef,{"NDH_OBS"   ,"C",250,0})
        IF lMV_GRCPNFE//Campos novos NFE - AWR 05/11/2008
           AADD(aEstruDef,{"NDHLOCALN" ,"C", 30,0})
           AADD(aEstruDef,{"NDHUFDESEM","C", 02,0})
        ENDIF

        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"DH")
        EndIf
        
        AADD(aEstruDef,{"NDHHAWB"   ,"C", LEN(SW6->W6_HAWB),0})
        AADD(aEstruDef,{"NDHINT_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NDHMSG"    ,"M", 10,0})

   Case cArq == "TX"  // Arquivo de Taxas do Despachante - 3
        AADD(aEstruDef,{"NTXTIPOREG","C",  2,0}) //RHP
        AADD(aEstruDef,{"NTXHOUSE"  ,"C", 18,0})
        AADD(aEstruDef,{"NTXMOEDA"  ,"C",  3,0})
        AADD(aEstruDef,{"NTXTAXA"   ,"N", 15,8})

        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"TX")
        EndIf

        AADD(aEstruDef,{"NTXHAWB"   ,"C", LEN(SW6->W6_HAWB),0})
        AADD(aEstruDef,{"NTXINT_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NTXMSG"    ,"M", 10,0})

   Case cArq == "DD"  // Arquivo de Despesas do Despachante - 4
        AADD(aEstruDef,{"NDDTIPOREG","C",  2,0}) //RHP
        AADD(aEstruDef,{"NDDHOUSE"  ,"C", 18,0})
        AADD(aEstruDef,{"NDDDPAGTO" ,"C",  8,0})
        AADD(aEstruDef,{"NDDDESPESA","C",  3,0})
        AADD(aEstruDef,{"NDDVALOR"  ,"N", 17,2})
        AADD(aEstruDef,{"NDDEFEPREV","C",  1,0})
        AADD(aEstruDef,{"NDDPAGOPOR","C",  1,0})
        AADD(aEstruDef,{"NDDADIANTA","C",  1,0})

        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"DD")
        EndIf

        AADD(aEstruDef,{"NDDINT_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NDDMSG"    ,"M", 10,0})
        AADD(aEstruDef,{"NDD_GRAVA" ,"C",  1,0})//ASR 19/11/2005 - CAMPO PARA CONTROLE SE A DESPESA SERÁ GRAVADA
        AADD(aEstruDef,{"NDD_LOG"   ,"C",  1,0})  //TRP - 24/10/2012 - Campo auxiliar para gravção do Log da Integração quando AvInteg.
		AADD(aEstruDef,{"NDD_LINHA" ,"C",  4,0})  //LGS - 08/04/2014   
   Case cArq == "DI"  // Arquivo de Data de Recebimento
        AADD(aEstruDef,{"NDIINT_DT" ,"C",  6,0})
        AADD(aEstruDef,{"NDIHAWB"   ,"C", 17,0})
        AADD(aEstruDef,{"NDIDT_ENTR","C",  6,0})
        AADD(aEstruDef,{"NDINF_ENT" ,"C", 20,0})
        AADD(aEstruDef,{"NDIDT_NF"  ,"C",  6,0})
        AADD(aEstruDef,{"NDIDI_NUM" ,"C", 10,0})
        AADD(aEstruDef,{"NDIVL_NF"  ,"C", 15,0})
        AADD(aEstruDef,{"NDISERIENF","C",  3,0})

        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"DI")
        EndIf

        AADD(aEstruDef,{"NDIDIRE"   ,"C", 12,0})//FSY - 23/08/2013 - Numero da DIRE

        AADD(aEstruDef,{"NDIINT_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NDIMSG"    ,"M", 10,0})

   Case cArq == "CC"  // Arquivo de Unidade Requisitante
        AADD(aEstruDef,{"NCCTIPO"   ,"C",  1,0})
        AADD(aEstruDef,{"NCCINT_DT" ,"C",  6,0})
        AADD(aEstruDef,{"NCCCOD"    ,"C",  nLenCC,0})//SO.:0026 OS.:0232/02 FCD
        AADD(aEstruDef,{"NCCDESC"   ,"C", 50,0})
        AADD(aEstruDef,{"NCCLE"     ,"C",  2,0})

        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"CC")
        EndIf

        AADD(aEstruDef,{"NCCINT_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NCCMSG"    ,"M", 10,0})

   Case cArq == "CL"  // Arquivo de Clientes Exportacao
        AADD(aEstruDef,{"NCLTIPO"   ,"C",  1,0})
        AADD(aEstruDef,{"NCLINT_DT" ,"C",  8,0})
        AADD(aEstruDef,{"NCLCOD"    ,"C", 15,0})
        AADD(aEstruDef,{"NCLLOJA"   ,"C",  2,0})
        AADD(aEstruDef,{"NCLNOME"   ,"C", 40,0})
        AADD(aEstruDef,{"NCLNREDUZ" ,"C", 15,0})
        AADD(aEstruDef,{"NCLEND"    ,"C", 40,0})
        AADD(aEstruDef,{"NCLBAIRRO" ,"C", 30,0})
        AADD(aEstruDef,{"NCLCIDADE" ,"C", 20,0})
        AADD(aEstruDef,{"NCLESTADO" ,"C", 20,0})
        AADD(aEstruDef,{"NCLPAIS"   ,"C",  3,0})
        AADD(aEstruDef,{"NCLCEP"    ,"C", 15,0})
        AADD(aEstruDef,{"NCLCP"     ,"C", 20,0})
        AADD(aEstruDef,{"NCLTEL"    ,"C", 20,0})
        AADD(aEstruDef,{"NCLTELEX"  ,"C", 20,0})
        AADD(aEstruDef,{"NCLFAX"    ,"C", 20,0})
        AADD(aEstruDef,{"NCLBANCO1" ,"C", 15,0})
        AADD(aEstruDef,{"NCLBANCO2" ,"C", 15,0})
        AADD(aEstruDef,{"NCLBANCO3" ,"C", 15,0})
        AADD(aEstruDef,{"NCLBANCO4" ,"C", 15,0})
        AADD(aEstruDef,{"NCLBANCO5" ,"C", 15,0})
        AADD(aEstruDef,{"NCLEMAIL"  ,"C", 30,0})
        AADD(aEstruDef,{"NCLHOMEPG" ,"C", 30,0})
        AADD(aEstruDef,{"NCLMARCAC" ,"C",120,0})
        AADD(aEstruDef,{"NCLAGENTE" ,"C", 15,0})
        AADD(aEstruDef,{"NCLCOMISS" ,"C",  5,0})
        AADD(aEstruDef,{"NCLOBS"    ,"C",360,0})
        AADD(aEstruDef,{"NCLTIPOCLI","C",  1,0})
        AADD(aEstruDef,{"NCLDEST1"  ,"C",  3,0})
        AADD(aEstruDef,{"NCLDEST2"  ,"C",  3,0})
        AADD(aEstruDef,{"NCLDEST3"  ,"C",  3,0})
        AADD(aEstruDef,{"NCLCONDPG" ,"C",  5,0})
        AADD(aEstruDef,{"NCLDIASPG" ,"C",  3,0})

        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"CL")
        EndIf

        AADD(aEstruDef,{"NCLINT_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NCLMSG"    ,"M", 10,0})

   Case cArq == "FF"  // Arquivo de Fabricante / Fornecedor Exportacao
        AADD(aEstruDef,{"NFFTIPO"   ,"C",  1,0})
        AADD(aEstruDef,{"NFFINT_DT" ,"C",  8,0})
        AADD(aEstruDef,{"NFFCOD"    ,"C", 15,0})
        AADD(aEstruDef,{"NFFLOJA"   ,"C",  2,0})
        AADD(aEstruDef,{"NFFNOME"   ,"C", 40,0})
        AADD(aEstruDef,{"NFFNOME_R" ,"C", 15,0})
        AADD(aEstruDef,{"NFFEND"    ,"C", 40,0})
        AADD(aEstruDef,{"NFFNR_END" ,"C",  6,0})
        AADD(aEstruDef,{"NFFBAIRRO" ,"C", 20,0})
        AADD(aEstruDef,{"NFFCIDADE" ,"C", 20,0})
        AADD(aEstruDef,{"NFFESTADO" ,"C",  nLenEst,0})  //SO.:0032 OS.:0298/02 FCD
        AADD(aEstruDef,{"NFFCOD_P"  ,"C",  3,0})
        AADD(aEstruDef,{"NFFCEP"    ,"C",  8,0})
        AADD(aEstruDef,{"NFFCX_POST","C",  5,0})
        AADD(aEstruDef,{"NFFFONES"  ,"C", 50,0})
        AADD(aEstruDef,{"NFFTELEX"  ,"C", 15,0})
        AADD(aEstruDef,{"NFFFAX"    ,"C", 50,0})
        AADD(aEstruDef,{"NFF_ID_FBF","C",  7,0})//LBL - 27/11/2013
        AADD(aEstruDef,{"NFFSTATUS" ,"C",  1,0})
        AADD(aEstruDef,{"NFFFORN_BA","C", 15,0})
        AADD(aEstruDef,{"NFFFORN_AG","C", 15,0})
        AADD(aEstruDef,{"NFFFORN_CO","C", 10,0})
        AADD(aEstruDef,{"NFFINSCEST","C", 18,0})
        AADD(aEstruDef,{"NFFINSCMUN","C", 18,0})
        AADD(aEstruDef,{"NFFPROC_1" ,"C",  3,0})
        AADD(aEstruDef,{"NFFPROC_2" ,"C",  3,0})
        AADD(aEstruDef,{"NFFPROC_3" ,"C",  3,0})
        AADD(aEstruDef,{"NFFSWIFT"  ,"C", 30,0})
        AADD(aEstruDef,{"NFFEMAIL"  ,"C", 30,0})
        AADD(aEstruDef,{"NFFHOMEPG" ,"C", 30,0})
        AADD(aEstruDef,{"NFFGRUPO"  ,"C",  3,0})
        AADD(aEstruDef,{"NFFCNPJCPF","C", 14,0})

        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"FF")
        EndIf

        AADD(aEstruDef,{"NFFINT_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NFFMSG"    ,"M", 10,0})

   Case cArq == "LK"  // Arquivo de Itens/Fabr./Forn. Exportacao
        AADD(aEstruDef,{"NLKTIPO"   ,"C",  1,0})
        AADD(aEstruDef,{"NLKINT_DT" ,"C",  8,0})
        AADD(aEstruDef,{"NLKCOD_I"  ,"C", 25,0})
        AADD(aEstruDef,{"NLKFABR"   ,"C", 15,0})
        AADD(aEstruDef,{"NLKLOJAFA" ,"C",  2,0})
        AADD(aEstruDef,{"NLKFORN"   ,"C", 15,0})
        AADD(aEstruDef,{"NLKLOJAFO" ,"C",  2,0})
        AADD(aEstruDef,{"NLKPART_N" ,"C", 20,0})
        AADD(aEstruDef,{"NLKMOEDA"  ,"C",  3,0})
        AADD(aEstruDef,{"NLKVLCOT_U","C", 15,0})
        AADD(aEstruDef,{"NLKLEAD_T" ,"C",  5,0})
        AADD(aEstruDef,{"NLKQT_COT" ,"C", 13,0})
        AADD(aEstruDef,{"NLKULT_ENT","C",  8,0})
        AADD(aEstruDef,{"NLKLOTE_MI","C",  8,0})
        AADD(aEstruDef,{"NLKLOTE_MU","C",  8,0})
        AADD(aEstruDef,{"NLKPART_OP","C", 48,0})
        AADD(aEstruDef,{"NLKUNID"   ,"C", 15,0})

        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"LK")
        EndIf

        AADD(aEstruDef,{"NLKINT_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NLKMSG"    ,"M", 10,0})

   Case cArq == "IT"  // Arquivo de Itens Exportacao
        AADD(aEstruDef,{"NITTIPO"   ,"C",  1,0})
        AADD(aEstruDef,{"NITINT_DT" ,"C",  8,0})
        AADD(aEstruDef,{"NITCOD_I"  ,"C", 25,0})
        AADD(aEstruDef,{"NITDESC_G" ,"C", 30,0})
        AADD(aEstruDef,{"NITUNI"    ,"C", 15,0})
        AADD(aEstruDef,{"NITLOCAL"  ,"C",  2,0})
        AADD(aEstruDef,{"NITNCM"    ,"C", 10,0})
        AADD(aEstruDef,{"NITEXNCM"  ,"C",  3,0})
        AADD(aEstruDef,{"NITEXNBM"  ,"C",  3,0})
        AADD(aEstruDef,{"NITPESO_L" ,"C", 11,0})
        AADD(aEstruDef,{"NITFAMILIA","C", 15,0})
        AADD(aEstruDef,{"NITEMBAL"  ,"C", 20,0})
        AADD(aEstruDef,{"NITQTDEMB" ,"C", 10,0})
        AADD(aEstruDef,{"NITNALNCCA","C",  7,0})
        AADD(aEstruDef,{"NITNALSH"  ,"C",  8,0})
        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"IT")
        EndIf

        AADD(aEstruDef,{"NITINT_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NITITEM_OK","C",  1,0})
        AADD(aEstruDef,{"NITMSG"    ,"M", 10,0})        

   Case cArq == "ID"  // Arquivo de Itens (Idiomas) Exportacao
        AADD(aEstruDef,{"NIDTIPO"   ,"C",  1,0})
        AADD(aEstruDef,{"NIDCAD"    ,"C",  1,0})
        AADD(aEstruDef,{"NIDCOD_I"  ,"C", 25,0})
        AADD(aEstruDef,{"NIDIDIOMA" ,"C",  6,0})
        AADD(aEstruDef,{"NIDDESCID" ,"C",360,0})
        
        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"ID")
        EndIf

        AADD(aEstruDef,{"NIDINT_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NIDMSG"    ,"M", 10,0})

   Case cArq == "PE"  // Arquivo de Processos de Exportacao
        AADD(aEstruDef,{"NPETIPO"   ,"C",  1,0})
        AADD(aEstruDef,{"NPEINT_DT" ,"C",  8,0})
        AADD(aEstruDef,{"NPEPEDIDO" ,"C", 20,0})
        AADD(aEstruDef,{"NPEDTPROC" ,"C",  8,0})
        AADD(aEstruDef,{"NPEDTPEDI" ,"C",  8,0})
        AADD(aEstruDef,{"NPEAMOSTR" ,"C",  1,0})
        AADD(aEstruDef,{"NPEFIM_PE" ,"C",  8,0})
        AADD(aEstruDef,{"NPEDTSLCR" ,"C",  8,0})
        AADD(aEstruDef,{"NPEIMPORT" ,"C", 15,0})
        AADD(aEstruDef,{"NPEIMLOJA" ,"C",  2,0})
        AADD(aEstruDef,{"NPEIMPODE" ,"C", 30,0})
        AADD(aEstruDef,{"NPEENDIMP" ,"C", 60,0})
        AADD(aEstruDef,{"NPEEND2IM" ,"C", 60,0})
        AADD(aEstruDef,{"NPEREFIMP" ,"C", 40,0})
        AADD(aEstruDef,{"NPEEXLIMP" ,"C",  1,0})
        AADD(aEstruDef,{"NPELICIMP" ,"C", 60,0})
        AADD(aEstruDef,{"NPEDTLIMP" ,"C",  8,0})
        AADD(aEstruDef,{"NPECLIENT" ,"C", 15,0})
        AADD(aEstruDef,{"NPECLLOJA" ,"C",  2,0})
        AADD(aEstruDef,{"NPEFORN"   ,"C", 15,0})
        AADD(aEstruDef,{"NPEFOLOJA" ,"C",  2,0})
        AADD(aEstruDef,{"NPERESPON" ,"C", 35,0})
        AADD(aEstruDef,{"NPEEXPORT" ,"C", 15,0})
        AADD(aEstruDef,{"NPEEXLOJA" ,"C",  2,0})
        AADD(aEstruDef,{"NPECONSIG" ,"C", 15,0})
        AADD(aEstruDef,{"NPECOLOJA" ,"C",  2,0})
        AADD(aEstruDef,{"NPEBENEF"  ,"C", 15,0})
        AADD(aEstruDef,{"NPEBELOJA" ,"C",  2,0})
        AADD(aEstruDef,{"NPEBENEDE" ,"C", 30,0})
        AADD(aEstruDef,{"NPEENDBEN" ,"C", 60,0})
        AADD(aEstruDef,{"NPEEND2BE" ,"C", 60,0})
        AADD(aEstruDef,{"NPECONDPA" ,"C",  5,0})
        AADD(aEstruDef,{"NPEDIASPA" ,"C",  3,0})
        AADD(aEstruDef,{"NPEMPGEXP" ,"C",  3,0})
        AADD(aEstruDef,{"NPEINCOTE" ,"C",  3,0})
        AADD(aEstruDef,{"NPEVIA"    ,"C", 15,0})
        AADD(aEstruDef,{"NPEORIGEM" ,"C",  3,0})
        AADD(aEstruDef,{"NPEDEST"   ,"C",  3,0})
        AADD(aEstruDef,{"NPETIPTRA" ,"C",  1,0})
        AADD(aEstruDef,{"NPEMARCAC" ,"C",120,0})
        AADD(aEstruDef,{"NPEMOEDA"  ,"C",  3,0})
        AADD(aEstruDef,{"NPEFRPPCC" ,"C",  2,0})
        AADD(aEstruDef,{"NPEFRPREV" ,"C", 15,0})
        AADD(aEstruDef,{"NPEFRPCOM" ,"C", 15,0})
        AADD(aEstruDef,{"NPESEGPRE" ,"C", 15,0})
        AADD(aEstruDef,{"NPEDESPIN" ,"C", 15,0})
        AADD(aEstruDef,{"NPEDESCON" ,"C", 15,0})
        AADD(aEstruDef,{"NPEPRECOA" ,"C",  1,0})
        AADD(aEstruDef,{"NPEEMBAFI" ,"C", 20,0})
        AADD(aEstruDef,{"NPECALCEM" ,"C",  1,0})
        AADD(aEstruDef,{"NPECUBAGE" ,"C", 15,0})
        AADD(aEstruDef,{"NPEIDIOMA" ,"C",  6,0})
        AADD(aEstruDef,{"NPESL_LC"  ,"C",  8,0})
        AADD(aEstruDef,{"NPELC_NUM" ,"C", 10,0})
        AADD(aEstruDef,{"NPESL_EME" ,"C",  8,0})
        AADD(aEstruDef,{"NPEPGTANT" ,"C",  1,0})
        AADD(aEstruDef,{"NPETIPCOM" ,"C",  1,0})
        AADD(aEstruDef,{"NPETIPCVL" ,"C",  1,0})
        AADD(aEstruDef,{"NPEVALCOM" ,"C", 15,0})
        AADD(aEstruDef,{"NPEREFAGE" ,"C", 20,0})
        AADD(aEstruDef,{"NPEGENERI" ,"C",360,0})
        AADD(aEstruDef,{"NPEOBSPED" ,"C",360,0})
        AADD(aEstruDef,{"NPEOBS"    ,"C",360,0})
        AADD(aEstruDef,{"NPESEQ"    ,"C",  6,0})
        AADD(aEstruDef,{"NPENOTIFY" ,"C", 15,0})  //MJB-SAP-1100 - campo novo
        AADD(aEstruDef,{"NPENOLOJA" ,"C",  2,0})  //MJB-SAP-1100 - campo novo

        If EECFLAGS("CAFE_OPCIONAL")
           AADD(aEstruDef,{"NPETP"     ,"C",  1,0})  //Tipo do Pedido de Exportação.       
        EndIf

        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"PE")
        EndIf

        AADD(aEstruDef,{"NPEINT_OK" ,"C",  1,0})                                        
        AADD(aEstruDef,{"NPEITEM_OK","C",  1,0})
        AADD(aEstruDef,{"NPEMSG"    ,"M", 10,0})

   Case cArq == "PD"  // Arquivo de Processos de Exportacao (Detalhe)        
        AADD(aEstruDef,{"NPDTIPO"   ,"C",  1,0})
        AADD(aEstruDef,{"NPDPEDIDO" ,"C", 20,0})
        AADD(aEstruDef,{"NPDCOD_I"  ,"C", 25,0})
        AADD(aEstruDef,{"NPDDECIT"  ,"C",360,0})
        AADD(aEstruDef,{"NPDFORN"   ,"C", 15,0})
        AADD(aEstruDef,{"NPDFOLOJA" ,"C",  2,0})
        AADD(aEstruDef,{"NPDFABR"   ,"C", 15,0})
        AADD(aEstruDef,{"NPDFALOJA" ,"C",  2,0})
        AADD(aEstruDef,{"NPDPART_N" ,"C", 20,0})
        AADD(aEstruDef,{"NPDDTPREM" ,"C",  8,0})
        AADD(aEstruDef,{"NPDDTENTR" ,"C",  8,0})
        AADD(aEstruDef,{"NPDUNIDAD" ,"C", 15,0})
        AADD(aEstruDef,{"NPDSLDINI" ,"C", 15,0})
        AADD(aEstruDef,{"NPDEMBAL1" ,"C", 20,0})
        AADD(aEstruDef,{"NPDQE"     ,"C", 10,0})
        AADD(aEstruDef,{"NPDQTDEM1" ,"C", 10,0})
        AADD(aEstruDef,{"NPDPRECO"  ,"C", 17,0})
        AADD(aEstruDef,{"NPDPRECOI" ,"C", 17,0})
        AADD(aEstruDef,{"NPDPSLQUN" ,"C", 17,0})
        AADD(aEstruDef,{"NPDPSLQTO" ,"C", 17,0})
        AADD(aEstruDef,{"NPDFPCOD"  ,"C", 15,0})
        AADD(aEstruDef,{"NPDGPCOD"  ,"C", 15,0})
        AADD(aEstruDef,{"NPDDPCOD"  ,"C", 15,0})
        AADD(aEstruDef,{"NPDPOSIPI" ,"C", 10,0})
        AADD(aEstruDef,{"NPDNLNCCA" ,"C",  7,0})
        AADD(aEstruDef,{"NPDNALSH"  ,"C",  8,0})
        AADD(aEstruDef,{"NPDPOSICAO","C",  6,0})
        AADD(aEstruDef,{"NPDSEQ"    ,"C",  6,0})
        AADD(aEstruDef,{"NPDSEQITEM","C",  6,0})
        AADD(aEstruDef,{"NPDREFCLI" ,"C", 20,0})

        AADD(aEstruDef,{"NPDPSBRUN" ,"C", 17,0})             //MJB-SAP-1200 - campo novo
        AADD(aEstruDef,{"NPDPSBRTO" ,"C", 17,0})             //MJB-SAP-1200 - campo novo

        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"PD")
        EndIf

        AADD(aEstruDef,{"NPDITEM_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NPDINT_OK"  ,"C",  1,0})
        AADD(aEstruDef,{"NPDMSG"     ,"M", 10,0})

   Case cArq == "FG" // Arquivo GERAL da Nota

        AADD(aEstruDef,{"NFGTIPO   ","C",  1,0})
        AADD(aEstruDef,{"NFGCAMPO1 ","C",255,0})
        AADD(aEstruDef,{"NFGCAMPO2 ","C",255,0})
        AADD(aEstruDef,{"NFGCAMPO3 ","C",255,0})

        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"FG")
        EndIf

   Case cArq == "FE" // Arquivo de Nota

        AADD(aEstruDef,{"NFETIPO"   ,"C",  1,0})
        AADD(aEstruDef,{"NFEEMPRESA","C",  2,0})
        AADD(aEstruDef,{"NFEFILIAL" ,"C",  2,0})  // FDR - 15/08/2013
        //IF lMV_GRCPNFE//Campo novo NFE - AWR 04/11/2008
        AADD(aEstruDef,{"NFENOTA"   ,"C",  9,0})//TDF - 21/05/10
		//ELSE
        //AADD(aEstruDef,{"NFENOTA"   ,"C",  6,0})
  		//ENDIF
        AADD(aEstruDef,{"NFEFILLER1","C",  6,0})
        AADD(aEstruDef,{"NFEICMSTX" ,"C",  7,0})
        AADD(aEstruDef,{"NFECFOP"   ,"C",  6,0})
        AADD(aEstruDef,{"NFECFP"    ,"C",  5,0})
        AADD(aEstruDef,{"NFECGC"    ,"C", 14,0})
        AADD(aEstruDef,{"NFECODIPI" ,"C",  3,0})
        AADD(aEstruDef,{"NFEHAWB"   ,"C", 17,0})
        AADD(aEstruDef,{"NFEQTDITEM","C",  2,0})
        AADD(aEstruDef,{"NFEDT_REF ","C",  6,0})
        AADD(aEstruDef,{"NFEDT_EMIS","C",  8,0})
        AADD(aEstruDef,{"NFEDT_ENTR","C",  8,0})
        AADD(aEstruDef,{"NFEFILLER2","C",  6,0})
        AADD(aEstruDef,{"NFEDTREGDI","C",  8,0})
        AADD(aEstruDef,{"NFEFILLER3","C",  2,0})
        AADD(aEstruDef,{"NFEINOUT"  ,"C",  1,0})
        AADD(aEstruDef,{"NFEESPECIE","C",  3,0})
        AADD(aEstruDef,{"NFECANCEL" ,"C",  1,0})
        AADD(aEstruDef,{"NFEFILLER4","C",  1,0})
        AADD(aEstruDef,{"NFEENTRADA","C",  1,0})
        AADD(aEstruDef,{"NFENUMDI"  ,"C", 10,0})
        AADD(aEstruDef,{"NFESERIE"  ,"C",  3,0})
        AADD(aEstruDef,{"NFESITUTRI","C",  2,0})
        AADD(aEstruDef,{"NFESITRI_E","C",  5,0})
        AADD(aEstruDef,{"NFESITRI_F","C",  5,0})
        AADD(aEstruDef,{"NFEUF_EMIT","C",  2,0})
        AADD(aEstruDef,{"NFEVIATRAN","C",  1,0})
        AADD(aEstruDef,{"NFEFRETE  ","C", 15,0})
        AADD(aEstruDef,{"NFEICMS   ","C", 15,0})
        AADD(aEstruDef,{"NFEBASEICM","C", 15,0})
        AADD(aEstruDef,{"NFEIMPORT ","C", 04,0})
        AADD(aEstruDef,{"NFETRANSP ","C", 20,0})
        AADD(aEstruDef,{"NFESEGURO ","C", 15,0})
        AADD(aEstruDef,{"NFEIPI    ","C", 15,0})
        AADD(aEstruDef,{"NFEVALMERC","C", 15,0})
        AADD(aEstruDef,{"NFETOTNOTA","C", 15,0})
        AADD(aEstruDef,{"NFEBASEIPI","C", 15,0})
        AADD(aEstruDef,{"NFEFILLER5","C", 02,0})
        AADD(aEstruDef,{"NFEEXPORT ","C", 04,0})
        AADD(aEstruDef,{"NFENOMEXPO","C", 60,0})
        AADD(aEstruDef,{"NFEPO_NUM" ,"C", 17,0})
        IF lMV_GRCPNFE//Campo novo NFE - AWR 04/11/2008
           AADD(aEstruDef,{"NFEPREDICM","C",06,0})
        ENDIF
        
        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"FE")
        EndIf

      	AADD(aEstruDef,{"NFEINT_DT" ,"C",  6,0})
        AADD(aEstruDef,{"NFEINT_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NFEITEM_OK","C",  1,0})
        AADD(aEstruDef,{"NFEMSG"    ,"M", 10,0})

   Case cArq == "FD" // Arquivo de Detalhes da Nota
        nTamQtde:=GETNEWPAR("MV_NFDQUAN",11)
        nTamQtde:=IF(nTamQtde=0,11,nTamQtde)
        AADD(aEstruDef,{"NFDTIPO   ","C",  01,0})
        AADD(aEstruDef,{"NFDEMPRESA","C",  02,0})
        AADD(aEstruDef,{"NFDFILIAL ","C",  02,0})  // FDR - 15/08/2013
        //IF lMV_GRCPNFE//Campo novo NFE - AWR 04/11/2008
	    AADD(aEstruDef,{"NFDNOTA   ","C",  09,0})//TDF - 21/05/10
	    //ELSE
	    //AADD(aEstruDef,{"NFDNOTA   ","C",  06,0})
	    //ENDIF
        AADD(aEstruDef,{"NFDNUMLANC","C",  06,0})
        AADD(aEstruDef,{"NFDCLASFIS","C",  10,0})
        AADD(aEstruDef,{"NFDCOD_I"  ,"C",  20,0})
        AADD(aEstruDef,{"NFDTRIICMS","C",  01,0})
        AADD(aEstruDef,{"NFDTRIIPI ","C",  01,0})
        AADD(aEstruDef,{"NFDNUMITEM","C",  02,0})
        AADD(aEstruDef,{"NFDQUANT"  ,"C",nTamQtde,0})
        AADD(aEstruDef,{"NFDUNI    ","C",  03,0})
        AADD(aEstruDef,{"NFDIPI    ","C",  15,0})
        AADD(aEstruDef,{"NFDVALOR  ","C",  15,0})
        AADD(aEstruDef,{"NFDENTRADA","C",  01,0})
        AADD(aEstruDef,{"NFDQTDEREC","C",  11,0})
        AADD(aEstruDef,{"NFDDESCR  ","C", 150,0})
        AADD(aEstruDef,{"NFDFOBRS  ","C",  15,0})
        AADD(aEstruDef,{"NFDFRETE  ","C",  15,0})
        AADD(aEstruDef,{"NFDSEGURO ","C",  15,0})
        AADD(aEstruDef,{"NFDII     ","C",  15,0})
        AADD(aEstruDef,{"NFDIPITX  ","C",  05,0})
        AADD(aEstruDef,{"NFDDESPESA","C",  15,0})
        AADD(aEstruDef,{"NFDHAWB   ","C",  17,0})
        AADD(aEstruDef,{"NFDEX_NCM ","C",  03,0})
        AADD(aEstruDef,{"NFDFATURA ","C",  15,0})
        AADD(aEstruDef,{"NFDICMS   ","C",  15,0})
        AADD(aEstruDef,{"NFDPESOL  ","C",  11,0})
        AADD(aEstruDef,{"NFDITEM   ","C",nTamPosicao,0})
        AADD(aEstruDef,{"NFDIITX   ","C",  05,0})
        AADD(aEstruDef,{"NFDPO_NUM ","C",  17,0})
        AADD(aEstruDef,{"NFDPLI"    ,"C",  10,0})
        AADD(aEstruDef,{"NFDSERIE"  ,"C",  03,0})
        AADD(aEstruDef,{"NFDBASEICM","C",  15,0})
        AADD(aEstruDef,{"NFDFOBUNO" ,"C",  15,0})//VALOR FOB UNITARIO NA MOEDA DE ORIGEM
        AADD(aEstruDef,{"NFDPERPIS" ,"C",  06,0})
        AADD(aEstruDef,{"NFDVLUPIS" ,"C",  09,0})
        AADD(aEstruDef,{"NFDBASPIS" ,"C",  15,0})
        AADD(aEstruDef,{"NFDVLRPIS" ,"C",  15,0})
        AADD(aEstruDef,{"NFDPERCOF" ,"C",  06,0})
        AADD(aEstruDef,{"NFDVLUCOF" ,"C",  09,0})
        AADD(aEstruDef,{"NFDBASCOF" ,"C",  15,0})
        AADD(aEstruDef,{"NFDVLRCOF" ,"C",  15,0})
        IF lMV_GRCPNFE//Campo novo NFE - AWR 04/11/2008
           AADD(aEstruDef,{"NFDADICAO" ,"C",03,0})
           AADD(aEstruDef,{"NFDSEQ_ADI","C",03,0})
           AADD(aEstruDef,{"NFDDESCONI","C",15,0})
           AADD(aEstruDef,{"NFDVLRIOF" ,"C",15,0})
           AADD(aEstruDef,{"NFDDESPADU","C",15,0})
           AADD(aEstruDef,{"NFDALUIPI" ,"C",15,0})
           AADD(aEstruDef,{"NFDQTUIPI" ,"C",11,0})
           AADD(aEstruDef,{"NFDQTUPIS" ,"C",11,0})
           AADD(aEstruDef,{"NFDQTUCOF" ,"C",11,0})
        ENDIF
        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"FD")
        EndIf                                

        AADD(aEstruDef,{"NFDLOTECTL","C", 10,0})
        AADD(aEstruDef,{"NFDDTVALLT","D", 08,0})
        AADD(aEstruDef,{"NFDICMSTX ","C",  05,0}) //NCF - 11/02/2011
        If lCposCofMj    // GFP - 30/07/2013
           AADD(aEstruDef,{"NFDALMJCOF" ,"N", 06,2})   
        EndIf
        
        AADD(aEstruDef,{"NFDPICMDIF" ,"N", 08,4}) //LGS-27/06/2016 - % ICMS DIFERIMENTO
        
        //THTS - 16/08/2019 - Projeto Recebimento de LI na integração (OSSME-3064)
        AADD(aEstruDef,{"NFDPLIREG" ,"C", 10,0}) //No. PLI/Reg.
        AADD(aEstruDef,{"NFDLISUBS" ,"C", 10,0}) //LI Sustitutiva

        AADD(aEstruDef,{"NFDINCLUI" ,"C", 03,0})
        AADD(aEstruDef,{"NFDINT_OK" ,"C", 01,0})
        AADD(aEstruDef,{"NFDMSG"    ,"M", 10,0})
        
        //LGS-03/03/2015
        If SWN->(FieldPos("WN_NVE"))   # 0
           AADD(aEstruDef,{"NFDNVE"    ,"C",03,0})
        EndIf
        If SWN->(FieldPos("WN_AC"))    # 0
           AADD(aEstruDef,{"NFDATO"    ,"C",13,0})
        EndIf
        If SWN->(FieldPos("WN_AFRMM")) # 0
           AADD(aEstruDef,{"NFDAFRMM"  ,"N",14,2})
        EndIf

   Case cArq == "NG" // Arquivo GERAL do Recebimento de numerário

        AADD(aEstruDef,{"NNGTIPOREG","C",  2,0})
        AADD(aEstruDef,{"NNGCAMPO1 ","C",250,0})
        AADD(aEstruDef,{"NNGCAMPO2 ","C",134,0})

        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"NG")
        EndIf

   Case cArq == "NU"  // Arquivo do Recebimento de numerário
        AADD(aEstruDef,{"NNUTIPOREG","C", 02,0})
        AADD(aEstruDef,{"NNUREFDES" ,"C", 18,0})
        AADD(aEstruDef,{"NNUDCHEG"  ,"C", 08,0})
        AADD(aEstruDef,{"NNUDRECDOC","C", 08,0})
        AADD(aEstruDef,{"NNUDESP"   ,"C", 03,0})
        AADD(aEstruDef,{"NNUAGENTE" ,"C", 03,0})
        AADD(aEstruDef,{"NNUMASTER" ,"C", 18,0})
        AADD(aEstruDef,{"NNUTIPODEC","C", 02,0})
        AADD(aEstruDef,{"NNUURFDESP","C", 07,0})
        AADD(aEstruDef,{"NNUURFENTR","C", 07,0})
        AADD(aEstruDef,{"NNURECALFA","C", 07,0})
        AADD(aEstruDef,{"NNUMODALDE","C", 01,0})
        AADD(aEstruDef,{"NNUTIPOCON","C", 02,0})
        AADD(aEstruDef,{"NNUTIPODOC","C", 02,0})
        AADD(aEstruDef,{"NNUUTILCON","C", 01,0})
        AADD(aEstruDef,{"NNUIDENTIF","C", 15,0})
        AADD(aEstruDef,{"NNUPESOBRU","C", 15,0})
        AADD(aEstruDef,{"NNUNF_ENT" ,"C", 06,0})
        AADD(aEstruDef,{"NNUDT_ENTR","C", 08,0})
        AADD(aEstruDef,{"NNU_OBS"   ,"C",250,0})
        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"NU_EST")
        EndIf
        AADD(aEstruDef,{"NNUTIPO"   ,"C",  1,0})
        AADD(aEstruDef,{"NNUINT_OK" ,"C", 01,0})
        AADD(aEstruDef,{"NNUINT_DT" ,"C",  6,0})
        AADD(aEstruDef,{"NNUMSG"    ,"M", 10,0})

        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"NU")
        EndIf

   Case cArq == "DN" // Arquivo de Detalhes do Recebimento de numerário
        AADD(aEstruDef,{"NDNTIPO   ","C", 02,0})
        AADD(aEstruDef,{"NDNREFDES" ,"C", 18,0})
        AADD(aEstruDef,{"NDNDPAGTO" ,"C", 08,0})
        AADD(aEstruDef,{"NDNDESPESA","C", 03,0})
        AADD(aEstruDef,{"NDNVALOR"  ,"C", 17,0})
        AADD(aEstruDef,{"NDNPAGOPOR","C", 01,0})
        AADD(aEstruDef,{"NDNADIANTA","C", 01,0})
                                                                                                                                         
        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"DN")
        EndIf                                

        AADD(aEstruDef,{"NDNINT_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NDNITEM_OK","C",  1,0})
        AADD(aEstruDef,{"NDNMSG"    ,"M", 10,0})

   CASE cArq == "NS"  // Arquivo de Notas Fiscais de Saida SEM ITENS
        AADD(aEstruDef,{"NNSTIPO"   ,"C",001,0})
        AADD(aEstruDef,{"NNSINT_DT" ,"C",008,0})
        AADD(aESTRUDEF,{"NNSPRO"    ,"C",020,0})
        AADD(aESTRUDEF,{"NNSNF"     ,"C",AVSX3("EE9_NF",3),0})
        AADD(aESTRUDEF,{"NNSSER"    ,"C",003,0})
        AADD(aESTRUDEF,{"NNSDT"     ,"C",008,0})
        AADD(aESTRUDEF,{"NNSTNF"    ,"C",001,0})
        AADD(aESTRUDEF,{"NNSVNF"    ,"C",015,0})
        AADD(aESTRUDEF,{"NNSVME"    ,"C",015,0})
        AADD(aESTRUDEF,{"NNSVFR"    ,"C",015,0})
        AADD(aESTRUDEF,{"NNSVSE"    ,"C",015,0})
        AADD(aESTRUDEF,{"NNSTOU"    ,"C",015,0})
        AADD(aESTRUDEF,{"NNSPED"    ,"C",020,0})
        AADD(aESTRUDEF,{"NNSITE"    ,"C",015,0})
        AADD(aESTRUDEF,{"NNSPOS"    ,"C",006,0})
        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos NFs de Saida
           ExecBlock("IN100CLI",.F.,.F.,"NS")
        EndIf
        AADD(aEstruDef,{"NNSINT_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NNSMSG"    ,"M", 10,0})
   
   CASE cARQ == "NC" //Notas Fiscais de Saida.
   
        AADD(aEstruDef,{"NNCTIPO"   ,"C",001,0})
        AADD(aEstruDef,{"NNCINT_DT" ,"C",008,0})
        AADD(aESTRUDEF,{"NNCPRO"    ,"C",020,0})
        AADD(aESTRUDEF,{"NNCNF"     ,"C",006,0})
        AADD(aESTRUDEF,{"NNCSER"    ,"C",003,0})
        AADD(aESTRUDEF,{"NNCDT"     ,"C",008,0})
        AADD(aESTRUDEF,{"NNCTNF"    ,"C",001,0})
        AADD(aESTRUDEF,{"NNCVNF"    ,"C",015,0})
        AADD(aESTRUDEF,{"NNCVME"    ,"C",015,0})
        AADD(aESTRUDEF,{"NNCVFR"    ,"C",015,0})
        AADD(aESTRUDEF,{"NNCVSE"    ,"C",015,0})
        AADD(aESTRUDEF,{"NNCTOU"    ,"C",015,0})
        AADD(aESTRUDEF,{"NNCTX"     ,"C",015,0})
        AADD(aEstruDef,{"NNCVNFM"   ,"C",015,0})
        AADD(aEstruDef,{"NNCVMEM"   ,"C",015,0})
        AADD(aEstruDef,{"NNCTXENFM" ,"C",015,0}) //Taxa de emissão da NF p/ NF e Mercadoria.
        AADD(aEstruDef,{"NNCVFRM"   ,"C",015,0})
        AADD(aEstruDef,{"NNCTXFR"   ,"C",015,0})
        AADD(aEstruDef,{"NNCVSEM"   ,"C",015,0})
        AADD(aEstruDef,{"NNCTXSE"   ,"C",015,0})
        AADD(aEstruDef,{"NNCTOUM"   ,"C",015,0})
        AADD(aEstruDef,{"NNCTXOD"   ,"C",015,0})
        AADD(aEstruDef,{"NNCCF"     ,"C",005,0})
        AADD(aEstruDef,{"NNCREC"    ,"C",006,0})
        AADD(aEstruDef,{"NNCDTI"    ,"C",008,0})
        AADD(aEstruDef,{"NNCHOI"    ,"C",006,0})
        AADD(aEstruDef,{"NNCUSI"    ,"C",015,0})

        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"NC")
        EndIf

        /*
        AMS - 30/08/2005. Posicionado os campos abaixo de acordo com o layout de integração padrão.
        */
        /*
        Inclusão de novos campos para capa da NF.
        Alexsander Martins dos Santos
        24/08/2004 às 15:22
        */
        /*
        AADD(aEstruDef,{"NNCVNFM",    "C", 15,0}) //Valor N.F. na moeda.
        AADD(aEstruDef,{"NNCVMEM",    "C", 15,0}) //Valor da Merc. na moeda.
        AADD(aEstruDef,{"NNCVFRM",    "C", 15,0}) //Vl.Frete na moeda.
        AADD(aEstruDef,{"NNCTXFR",    "C", 15,0}) //Tx.Frete.
        AADD(aEstruDef,{"NNCVSEM",    "C", 15,0}) //Vl.Seguro na moeda.
        AADD(aEstruDef,{"NNCTXSE",    "C", 15,0}) //Tx. Seguro.
        AADD(aEstruDef,{"NNCTOUM",    "C", 15,0}) //Total das Outras despesas na moeda.
        AADD(aEstruDef,{"NNCTXOD",    "C", 15,0}) //Tx. Outras despesas.
        */
        If EEM->(FieldPos("EEM_CNPJ")) > 0  // By JPP - 17/03/2006 - 16:00 - Novo campo chave utilizado na pesquisa da NF.
           AADD(aEstruDef,{"NNCCNPJ",    "C", 14,0})
        EndIf   

        AADD(aEstruDef,{"NNCINT_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NNCITEM_OK","C",  1,0})
        AADD(aEstruDef,{"NNCMSG"    ,"M", 10,0})

   CASE cARQ == "ND"

        AADD(aEstruDef,{"NNDTIPO"   ,"C",  1,0})
        AADD(aEstruDef,{"NNDINT_DT" ,"C",008,0})
        AADD(aESTRUDEF,{"NNDPRO"    ,"C",020,0})
        AADD(aESTRUDEF,{"NNDNF"     ,"C",006,0})
        AADD(aESTRUDEF,{"NNDSER"    ,"C",003,0})
        AADD(aESTRUDEF,{"NNDVNF"    ,"C",015,0})
        AADD(aEstruDef,{"NNDVNFM"   ,"C",015,0})
        AADD(aESTRUDEF,{"NNDVME"    ,"C",015,0})
        AADD(aEstruDef,{"NNDVMEM"   ,"C",015,0})
        AADD(aESTRUDEF,{"NNDVFR"    ,"C",015,0})
        AADD(aEstruDef,{"NNDVFRM"   ,"C",015,0})
        AADD(aESTRUDEF,{"NNDVSE"    ,"C",015,0})
        AADD(aEstruDef,{"NNDVSEM"   ,"C",015,0})
        AADD(aESTRUDEF,{"NNDTOU"    ,"C",015,0})
        AADD(aEstruDef,{"NNDTOUM"   ,"C",015,0})
        AADD(aESTRUDEF,{"NNDPED"    ,"C",020,0})
        AADD(aESTRUDEF,{"NNDITE"    ,"C",019,0})
//      AADD(aESTRUDEF,{"NNDPOS"    ,"C",006,0})
        AADD(aESTRUDEF,{"NNDQTD"    ,"C",015,0})
        AADD(aESTRUDEF,{"NNDPOS"    ,"C",006,0})
        AADD(aEstruDef,{"NNDREC"    ,"C",006,0})

        IF EasyEntryPoint("IN100CLI")  // RDMAKE QUE CONTEM A ESTRUTURA DOS ARQUIVOS CLIENTE
           EXECBLOCK("IN100CLI",.F.,.F.,"ND")
        ENDIF

        /*
        AMS - 30/08/2005. Posicionado os campos abaixo de acordo com o layout de integração padrão.
        */
        /*
        Inclusão de novos campos para itens da NF.
        Alexsander Martins dos Santos
        24/08/2004 às 15:22
        */
        /*
        AADD(aEstruDef,{"NNDVNFM", "C", 15,0}) //Vl.NF na moeda.
        AADD(aEstruDef,{"NNDVMEM", "C", 15,0}) //Vl.Merc. na moeda.
        AADD(aEstruDef,{"NNDVFRM", "C", 15,0}) //Vl.Frete na moeda.
        AADD(aEstruDef,{"NNDVSEM", "C", 15,0}) //Vl.Seguro na moeda.
        AADD(aEstruDef,{"NNDTOUM", "C", 15,0}) //Tot.Outras despesas na moeda.
        */
        
        If EES->(FieldPos("EES_CNPJ")) > 0    // By JPP - 17/03/2006 - 16:00 - Novo campo chave utilizado na pesquisa do itens da NF.
           AADD(aEstruDef,{"NNDCNPJ",    "C", 14,0})
        EndIf  

        AADD(aEstruDef,{"NNDITEM_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NNDINT_OK"  ,"C",  1,0})
        AADD(aEstruDef,{"NNDMSG"     ,"M", 10,0})

************* DrawBack

   Case cArq == "EP"  // Arquivo de Estruturas do Produto Capa
        AADD(aEstruDef,{"NEPTIPO"   ,"C",  1,0})
        AADD(aEstruDef,{"NEPINT_DT" ,"C",  8,0})
        AADD(aEstruDef,{"NEPPROD"   ,"C", 30,0})
        AADD(aEstruDef,{"NEPUMP"    ,"C",  2,0})
        AADD(aEstruDef,{"NEPQTDBASE","C", 12,0})
        AADD(aEstruDef,{"NEPITEM"   ,"C", 30,0})
        AADD(aEstruDef,{"NEPSEQ"    ,"C",  3,0})
        AADD(aEstruDef,{"NEPQTDITEM","C", 12,0})        
        AADD(aEstruDef,{"NEPUMITEM" ,"C",  2,0})        
        AADD(aEstruDef,{"NEPPERDA"  ,"C",  5,0})                
        
        //** AAF 02/06/05 - Valor comercial a Perda
        If SG1->( FieldPos("G1_VLCOMPE") ) > 0
           AADD(aEstruDef,{"NEPVLCOMPE","C",1,0})
        Endif
        //**
        
        AADD(aEstruDef,{"NEPDTINIVA","C",  8,0})                
        AADD(aEstruDef,{"NEPDTFIMVA","C",  8,0})                
        AADD(aEstruDef,{"NEPOBS"    ,"C", 45,0})                        
        AADD(aEstruDef,{"NEPTIPOQTD","C",  1,0})                        
        AADD(aEstruDef,{"NEPGRUPO"  ,"C",  3,0})
        AADD(aEstruDef,{"NEPOPCACAB","C",  4,0})                        
        AADD(aEstruDef,{"NEPREVINI" ,"C",  3,0})                        
        AADD(aEstruDef,{"NEPREVFIM" ,"C",  3,0})                        

        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"EP")
        EndIf

        AADD(aEstruDef,{"NEPINT_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NEPMSG"    ,"M", 10,0})

   Case cArq == "UC"  // Arquivo de Conversão de Unidades
        AADD(aEstruDef,{"NUCTIPO"   ,"C",  1,0})
        AADD(aEstruDef,{"NUCINT_DT" ,"C",  8,0})
        AADD(aEstruDef,{"NUCUMDE"   ,"C",  2,0})
        AADD(aEstruDef,{"NUCUMPARA" ,"C",  2,0})
        AADD(aEstruDef,{"NUCPRODUTO","C", 30,0})
        AADD(aEstruDef,{"NUCCONV"   ,"C", 14,0})

        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"UC")
        EndIf

        AADD(aEstruDef,{"NUCINT_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NUCMSG"    ,"M", 10,0})        

   Case cArq == "CE"  // Arquivo de Conversão de Unidades
        //Alcir Alves - 16-12-05 - novas modificações 
        aadd(aEstruDef,{'NCETIPO','C',1,0})
        aadd(aEstruDef,{'NCEINT_DT','C',8,0})
        aadd(aEstruDef,{'NCETIPOIE','C',1,0})
        aadd(aEstruDef,{'NCECNPJ','C',14,0})
        aadd(aEstruDef,{'NCELINUM','C',10,0})
        aadd(aEstruDef,{'NCEDINUM','C',10,0})
        aadd(aEstruDef,{'NCEAD','C',3,0})
        aadd(aEstruDef,{'NCEAC','C',13,0})
        aadd(aEstruDef,{'NCEDTDI','C',8,0})
        aadd(aEstruDef,{'NCEDTLI','C',8,0})
        aadd(aEstruDef,{'NCECODI','C',/*15*/30,0})
        aadd(aEstruDef,{'NCEPOSDI','C',4,0})
        aadd(aEstruDef,{'NCEDESC','C',60,0})
        aadd(aEstruDef,{'NCEPESO','C',11,4})
        aadd(aEstruDef,{'NCEQTDN','C',15,5})
        aadd(aEstruDef,{'NCEUMN','C',2,0})
        aadd(aEstruDef,{'NCEQTD','C',15,5})
        aadd(aEstruDef,{'NCEUM','C',2,0})
        aadd(aEstruDef,{'NCENCM','C',10,0})
        aadd(aEstruDef,{'NCEVLEMB','C',14,2})
        aadd(aEstruDef,{'NCETXUSS','C',15,8})
        aadd(aEstruDef,{'NCEINV','C',15,0})
        aadd(aEstruDef,{'NCEFR','C',15,2})
        aadd(aEstruDef,{'NCEMOEFR','C',3,0})
        aadd(aEstruDef,{'NCETXFR','C',15,8})
        aadd(aEstruDef,{'NCESE','C',15,2})
        aadd(aEstruDef,{'NCEMOESE','C',3,0})
        aadd(aEstruDef,{'NCETXSE','C',15,8})
        aadd(aEstruDef,{'NCESEUSS','C',15,2})
        aadd(aEstruDef,{'NCENF','C',AVSX3("ED8_NF",3),0})
        aadd(aEstruDef,{'NCESERIE','C',3,0})
        aadd(aEstruDef,{'NCEEMISSA','C',8,0})
        aadd(aEstruDef,{'NCEMOEDA','C',3,0})
        aadd(aEstruDef,{'NCEVALORI','C',17,7})
        aadd(aEstruDef,{'NCETXMOE','C',15,8})
        aadd(aEstruDef,{'NCESEQS','C',3,0})
        aadd(aEstruDef,{'NCEMRD','N',15,2}) //Alcir Alves - 11-01-06
        aadd(aEstruDef,{'NCEARMD','N',15,2}) //Alcir Alves - 11-01-06
        aadd(aEstruDef,{'NCEINLAN','N',15,2}) //Alcir Alves - 11-01-06
        aadd(aEstruDef,{'NCEOUTD','N',15,2}) //Alcir Alves - 11-01-06
        aadd(aEstruDef,{'NCEPACK','N',15,2}) //Alcir Alves - 11-01-06
        aadd(aEstruDef,{'NCEDESCT','N',15,2}) //Alcir Alves - 11-01-06
        
        //AOM - 21/10/10 - Campos para Compras Nacionais
        aadd(aEstruDef,{'NCEPED','C',15,0})
        aadd(aEstruDef,{'NCEFORN','C',6,0})
        aadd(aEstruDef,{'NCELOJA','C',2,0})
        
        //*** GFP - 24/08/2011 - Campos de Impostos
        aAdd(aEstruDef,{'NCEVLII'  ,'N',15,2})
        aAdd(aEstruDef,{'NCEVLIPI' ,'N',15,2})
        aAdd(aEstruDef,{'NCEVLICMS','N',15,2})
        aAdd(aEstruDef,{'NCEVLPIS' ,'N',15,2}) 
        aAdd(aEstruDef,{'NCEVLCOF' ,'N',15,2})  
        
        //AOM - 05/12/2011 - Sequencia Mercado Interno
        If AVFLAGS("SEQMI") 
           AADD(aEstruDef,{"NCESEQMI","C",04,0})
        EndIf

        //AADD(aEstruDef,{"NCERE"     ,"C", 12,0})   //RE
        //AADD(aEstruDef,{"NCEDT_RE"  ,"C",  8,0})   //Data do RE
        //AADD(aEstruDef,{"NCEDT_EMB" ,"C",  8,0})   //Data do Embarque (Exportação)

        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"CE")
        EndIf

        AADD(aEstruDef,{"NCEINT_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NCEMSG"    ,"M", 10,0})

   Case cArq == "NR"  // Arquivo de RE´s Externas - AWR - 08/04/09

        AADD(aEstruDef,{"NNRTIPO"  ,"C",01,0})
        AADD(aEstruDef,{"NNRINT_DT","C",08,0})
        AADD(aEstruDef,{"NNREXPORT","C",14,0})
        AADD(aEstruDef,{"NNRRE"    ,"C",12,0})
        AADD(aEstruDef,{"NNRPOSICA","C",04,0})
        AADD(aEstruDef,{"NNRDTRE"  ,"C",08,0})
        AADD(aEstruDef,{"NNRDTEMB" ,"C",08,0})
        AADD(aEstruDef,{"NNRPROD"  ,"C",30,0})
        AADD(aEstruDef,{"NNRDESC"  ,"C",60,0})
        AADD(aEstruDef,{"NNRPESO"  ,"C",17,0})
        AADD(aEstruDef,{"NNRQTD"   ,"C",15,0})
        AADD(aEstruDef,{"NNRUM"    ,"C",02,0})
        AADD(aEstruDef,{"NNRVL_FOB","C",15,0})
        AADD(aEstruDef,{"NNRTX_MOE","C",15,0})
        AADD(aEstruDef,{"NNRVALMOE","C",15,0})
        AADD(aEstruDef,{"NNRMOEDA" ,"C",03,0})
        AADD(aEstruDef,{"NNRNF"    ,"C",06,0})
        AADD(aEstruDef,{"NNRSERIE" ,"C",03,0})
        AADD(aEstruDef,{"NNREMISSA","C",08,0})
        AADD(aEstruDef,{"NNRNCM"   ,"C",10,0})
        AADD(aEstruDef,{"NNRVAL_SE","C",15,0})
        AADD(aEstruDef,{"NNRVALCOM","C",15,0})
        AADD(aEstruDef,{"NNRVALORI","C",15,0})
        AADD(aEstruDef,{"NNRUMNCM" ,"C",02,0})
        AADD(aEstruDef,{"NNRQTDNCM","C",15,0})
        AADD(aEstruDef,{"NNRTX_USS","C",15,0})
        AADD(aEstruDef,{"NNRDTAVRB","C",08,0}) 
        
        // BAK - Tratamento para o campo do Ato Concessório e Seq. Ato) com base nos campos (ED9_AC e ED9SEQSIS) - 24/08/2011
        AADD(aEstruDef,{"NNRAC"    ,"C",13,0})
        AADD(aEstruDef,{"NNRSEQSIS","C",03,0})
        

        
        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,"NR")
        EndIf

        AADD(aEstruDef,{"NNRINT_OK" ,"C",  1,0})
        AADD(aEstruDef,{"NNRMSG"    ,"M", 10,0})

   Case lRdmake  // Arquivo do Usuario
        
        If EasyEntryPoint("IN100CLI")  // Rdmake que contem a estrutura dos Arquivos Cliente
           ExecBlock("IN100CLI",.F.,.F.,cArq)
        EndIf        

EndCase

// JWJ 11/09/09: Eliminar campos duplicados no array e considerar o último cadastradao
For i := Len(aEstruDef) To 1 Step -1
	IF !(aEstrudef[i,1]+';') $ cAux
		AADD(aAux, nil)
		AINS(aAux, 1)
		aAux[1] := aClone(aEstruDef[i])
		cAux += aEstrudef[i,1]+';'
	ENDIF
Next
aEstruDef := ACLONE(aAux)

Return(.T.)

*------------------------*
STATIC FUNCTION INVERPOS()
*------------------------*
// SAM - 14/05/2001 . Verifica Ultima Posicao Gravada
nRecSW3:=SW3->(recno()) 
nOrdSW3:=SW3->(INDEXORD())
SW3->(DBSETORDER(8))
SW3->(DBSEEK(cFilSW3+AVKEY(Int_PO->NPOPO_NUM,"W3_PO_NUM")+'9999',.T.))
IF !(cFilSW3+Int_PO->NPOPO_NUM==SW3->W3_FILIAL+SW3->W3_PO_NUM)
   SW3->(DBSKIP(-1))
ENDIF
IF !(cFilSW3+Int_PO->NPOPO_NUM==SW3->W3_FILIAL+SW3->W3_PO_NUM)
   cUltPosPO:=''
ELSE
   cUltPosPO:=SW3->W3_POSICAO
ENDIF
SW3->(DBSETORDER(nOrdSW3))
sw3->(dbgoto(nRecSW3))
RETURN cUltPosPO

*-------------------------*
Static Function VrCambio()// AWR  24/04/2003
*-------------------------*
LOCAL cCampoDT_VAR
LOCAL dDataDT_VAR :=AVCTOD("")
LOCAL cComtrole   :=ALLTRIM(GETNEWPAR("MV_CAMBAUT","NNN"))
LOCAL cDataFOB := ""
Local cDataFre := ""
Local cDataSeg := ""
PRIVATE nDecimais :=AVSX3("W9_FOB_TOT",4)
PRIVATE lGrava

// EJA - 13/11/2018 - Atribui a data de variação de acordo com MV_DT_VAR para cada variável passada na função.
// As variáveis passadas por parâmetros serão alteradas após passar pela função.
DI501GetDataVar(@cDataFOB, @cDataFre, @cDataSeg)

cCampoDT_VAR := ALLTRIM(cDataFOB)
IF !EMPTY(cCampoDT_VAR)
   dDataDT_VAR := SW6->(FIELDGET(FIELDPOS(ALLTRIM(cCampoDT_VAR))))
ENDIF

//*****************************  FOB  *****************************
   lGrava:=SUBSTR(cComtrole,1,1) $ cSim
   nDiferenca := 0
   nFobTotal  := 0

   SW8->(DBSETORDER(1))
   SW9->(DBSETORDER(3))                           
   SW9->(DBSEEK(cFilSW9+SW6->W6_HAWB))
   DO WHILE SW9->(!EOF()) .AND. SW9->W9_HAWB   == SW6->W6_HAWB .AND.;
                                SW9->W9_FILIAL == cFilSW9
      IF EMPTY(SW9->W9_TX_FOB)
         nFobTotal  := 0
         EXIT
      ENDIF           
      nValorDT_VAR:=DI500TRANS( DI500RetVal("TOT_INV", "TAB", .T., .T.) )  // EOB - 11/06/08 - Chamada da função DI500RetVal
      nFobTotal   +=nValorDT_VAR
      IF ! EMPTY(cCampoDT_VAR)
         nDiferenca  +=DI500TRANS(DI500RetVal("TOT_INV", "TAB", .T.)*BuscaTaxa(SW9->W9_MOE_FOB,dDataDT_VAR,.T.,.F.,.T.))-nValorDT_VAR // EOB - 11/06/08 - Chamada da função DI500RetVal
      ENDIF
      SW9->(DBSKIP())

   ENDDO

   nFobTotal:=nFobTotal-(SW6->W6_VLFREPP*SW6->W6_TX_FRET)

   IF nFobTotal # 0 
      DI400Grvddi(SW6->W6_HAWB,SW6->W6_DT,"101",nFobTotal,nDiferenca,"701",dDataDT_VAR,"711")
   ELSE
      DI400Grvddi(SW6->W6_HAWB,SW6->W6_DT,"101",0,0,"701",dDataDT_VAR,"711")
   ENDIF

//*****************************  FRETE  *****************************
    cCampoDT_VAR := ALLTRIM(cDataFre)
    IF !EMPTY(cCampoDT_VAR)
        dDataDT_VAR := SW6->(FIELDGET(FIELDPOS(ALLTRIM(cCampoDT_VAR))))
    ENDIF

   lGrava:=SUBSTR(cComtrole,2,1) $ cSim

   nFrete:=ValorFrete(SW6->W6_HAWB,,,2)
   IF nFrete # 0 .AND. SW6->W6_TX_FRET # 0
      nValorDT_VAR := DI500Trans(nFrete * SW6->W6_TX_FRET)
      nDiferenca := 0
      IF ! EMPTY(cCampoDT_VAR)
         nDiferenca := DI500Trans(nFrete * BuscaTaxa(SW6->W6_FREMOED,dDataDT_VAR,.T.,.F.)-nValorDT_VAR)
      ENDIF
      DI400Grvddi(SW6->W6_HAWB,SW6->W6_DT,"102",nValorDT_VAR,nDiferenca,"702",dDataDT_VAR,"712", SW6->W6_FORNECF, SW6->W6_LOJAF)
   ELSE
      DI400Grvddi(SW6->W6_HAWB,SW6->W6_DT,"102",0,0,"702",dDataDT_VAR,"712", SW6->W6_FORNECF, SW6->W6_LOJAF)
   ENDIF

//*****************************  SEGURO  *****************************
    cCampoDT_VAR := ALLTRIM(cDataSeg)
    IF !EMPTY(cCampoDT_VAR)
        dDataDT_VAR := SW6->(FIELDGET(FIELDPOS(ALLTRIM(cCampoDT_VAR))))
    ENDIF

   lGrava:=SUBSTR(cComtrole,3,1) $ cSim

   IF SW6->W6_VL_USSE # 0 .AND. SW6->W6_TX_SEG # 0 .AND. SW6->W6_TX_US_D # 0
      nDiferenca   := 0
      nValorDT_VAR := DI500Trans(SW6->W6_VL_USSE * SW6->W6_TX_SEG)
      SW6->(Reclock("SW6",.F.))	//ASR - 04/10/2005 - ADICIONADO PARA GRAVAR O VALOR DO SEGURO NA SW6
      SW6->W6_VLSEGMN := nValorDT_VAR
      SW6->(MSUNLOCK())
      IF !EMPTY(cCampoDT_VAR)
         nDiferenca := DI500Trans(SW6->W6_VL_USSE * BuscaTaxa(SW6->W6_SEGMOED,dDataDT_VAR,.T.,.F.) - nValorDT_VAR)
      ENDIF
      DI400Grvddi(SW6->W6_HAWB,SW6->W6_DT,"103",nValorDT_VAR,nDiferenca,"703",dDataDT_VAR,"713", SW6->W6_FORNECS, SW6->W6_LOJAS)
   ELSE
      DI400Grvddi(SW6->W6_HAWB,SW6->W6_DT,"103",0,0,"703",dDataDT_VAR,"713", SW6->W6_FORNECS, SW6->W6_LOJAS)
   ENDIF

//***************************************************

RETURN .T.

*----------------------*
FUNCTION IN100CONVUM()
*----------------------*
AADD(TB_Cols,{{||Int_UC->NUCUMDE}                  ,"",STR0725 }) //Unidade de Medida DE
AADD(TB_Cols,{{||Int_UC->NUCUMPARA}                ,"",STR0726 }) //Unidade de Medida do Produto
AADD(TB_Cols,{{||Int_UC->NUCCONV}                  ,"",STR0727 }) //Qtd Base
AADD(TB_Cols,{{||Int_UC->NUCPRODUTO}               ,"",STR0733 }) //Produto

ASIZE(TBRCols,0)
AADD(TBRCols,{{||IN100Status()}            , STR0019 }) //Status
AADD(TBRCols,{{||IN100TIPO() }             , STR0020 }) //Tipo
AADD(TBRCols,{{||IN100CTD(EVAL(bDtInteg))} , STR0021 }) //Dt Integ
AADD(TBRCols,{{||Int_UC->NUCUMDE}                  , STR0725 }) //Unidade de Medida DE
AADD(TBRCols,{{||Int_UC->NUCUMPARA}                , STR0726 }) //Unidade de Medida do Produto
AADD(TBRCols,{{||Int_UC->NUCCONV}                  , STR0727 }) //Qtd Base
AADD(TBRCols,{{||Int_UC->NUCPRODUTO}               , STR0733 }) //Produto

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"COLUC")
ENDIF
AADD(TBRCols,{{||IN100E_MSG(.T.)}          ,STR0112      }) //Mensagem
AADD(TB_Cols,{{||IN100E_Msg(.T.)}          ,"",STR0112   }) //Mensagem
SAH->(DBSETORDER(1))
SJ5->(DBSETORDER(1))

RETURN .T.

*--------------------*
FUNCTION IN100LerUC()
*--------------------*
Local cSG1:="", cProdExp

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"LERUC")
ENDIF     

If EMPTY(Int_UC->NUCUMDE)
   EVAL(bmsg,STR0728+STR0546)  // UM DE NAO INFORMADO
ElseIf ! SAH->(DBSEEK(cFilSAH+AVKEY(Int_UC->NUCUMDE,"AH_UNIMED")))
   EVAL(bmsg,STR0728+STR0544)  // UM DE SEM CADASTRO
ENDIF

If EMPTY(Int_UC->NUCUMPARA)
   EVAL(bmsg,STR0729+STR0546)  // UM PARA NAO INFORMADO
ElseIf ! SAH->(DBSEEK(cFilSAH+AVKEY(Int_UC->NUCUMPARA,"AH_UNIMED")))
   EVAL(bmsg,STR0729+STR0544)  // UM PARA SEM CADASTRO
ENDIF

If Int_UC->NUCUMPARA == Int_UC->NUCUMDE
   EVAL(bmsg,STR0735)  // UM PARA SEM CADASTRO
EndIf

IF Len(Int_UC->NUCPRODUTO) > Len((cAliasSB1)->B1_COD)
   cProdExp := Left(Int_UC->NUCPRODUTO,Len((cAliasSB1)->B1_COD))
Else
   cProdExp := Int_UC->NUCPRODUTO+Space(Len((cAliasSB1)->B1_COD)-Len(Int_UC->NUCPRODUTO))
Endif

If !EMPTY(Int_UC->NUCUMPARA) .AND.;
!Empty(Int_UC->NUCPRODUTO) .and. !(cAliasSB1)->(DBSEEK(cFilSB1Aux+cProdExp)) .and.;
!SB1->(DBSEEK(cFilSB1+AVKEY(Int_UC->NUCPRODUTO,"J5_COD_I")))
   EVAL(bmsg,STR0730+STR0544)  // PRODUTO PARA SEM CADASTRO
ENDIF

If !Empty(Int_UC->NUCPRODUTO)
   cSG1:=AVKEY(Int_UC->NUCUMDE,"J5_DE")+AVKEY(Int_UC->NUCUMPARA,"J5_PARA")+AVKEY(Int_UC->NUCPRODUTO,"J5_COD_I")
Else
   cSG1:=AVKEY(Int_UC->NUCUMDE,"J5_DE")+AVKEY(Int_UC->NUCUMPARA,"J5_PARA")
EndIf

IF ! SJ5->(DBSEEK(cFilSJ5+cSG1))
   IF Int_UC->NUCTIPO = EXCLUSAO  
      EVAL(bmsg,STR0731+STR0544)  // Conversao DE-PARA sem cadastro
   ENDIF

   IF Int_UC->NUCTIPO = ALTERACAO
      Int_UC->NUCTIPO := INCLUSAO
   ENDIF

ELSEIF Int_UC->NUCTIPO = INCLUSAO
   EVAL(bmsg,STR0731+STR0545)  // Conversao DE PARA ja cadastro
ENDIF                                    

IF Int_UC->NUCTIPO == EXCLUSAO
   IF EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"VALUC")
   ENDIF
   IN100VerErro(cErro,cAviso)
   IF Int_UC->NUCINT_OK = "T"
      nResumoCer+=1
   ELSE
      nResumoErr+=1
   ENDIF
   RETURN
ENDIF                

If EMPTY(Int_UC->NUCCONV)
   EVAL(bmsg,STR0241+STR0546)  // Taxa de Conversao NAO INFORMADO
ElseIf IN100NaoNum(Int_UC->NUCCONV)
   EVAL(bmsg,STR0241+STR0549)  // Taxa de Conversao Invalido
ElseIf Val(Int_UC->NUCCONV) < 0
   EVAL(bmsg,STR0241+STR0732)  // Taxa de Conversao negativa
ENDIF

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"VALUC")
ENDIF

IN100VerErro(cErro,cAviso)
IF Int_UC->NUCINT_OK = "T"
   nResumoCer+=1
ELSE
   nResumoErr+=1
ENDIF

Return .T.

*--------------------*
FUNCTION IN100GrvUC()
*--------------------*

IF Int_UC->NUCTIPO # INCLUSAO

   If !Empty(Int_UC->NUCPRODUTO)
      SJ5->(DBSEEK(cFilSJ5+AVKEY(Int_UC->NUCUMDE,"J5_DE")+AVKEY(Int_UC->NUCUMPARA,"J5_PARA")+AVKEY(Int_UC->NUCPRODUTO,"J5_COD_I")))
   Else
      SJ5->(DBSEEK(cFilSJ5+AVKEY(Int_UC->NUCUMDE,"J5_DE")+AVKEY(Int_UC->NUCUMPARA,"J5_PARA")))
   EndIf
   cAlias:=ALIAS()
   Reclock("SJ5",.F.)
   DBSELECTAREA(cAlias)

   IF Int_UC->NUCTIPO = EXCLUSAO
      SJ5->(DBDELETE())
      SJ5->(DBCOMMIT())
      SJ5->(MSUNLOCK())

      If EasyEntryPoint("IN100CLI")
         ExecBlock("IN100CLI",.F.,.F.,"EXCUC")
      EndIf
      
      RETURN

   ENDIF
ENDIF

IF Int_UC->NUCTIPO = INCLUSAO
   IN100RecLock('SJ5')
   SJ5->J5_FILIAL := cFilSYE
   SJ5->J5_DE     := Int_UC->NUCUMDE   
   SJ5->J5_PARA   := Int_UC->NUCUMPARA 
   SJ5->J5_COD_I  := Int_UC->NUCPRODUTO
ENDIF
IF(VAL(Int_UC->NUCCONV)#0,SJ5->J5_COEF := Val(Int_UC->NUCCONV),)

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"GRVUC")
EndIf

SJ5->(MSUNLOCK())
Return .T.

//Alcir Alves - função padrão de envio de e-mail - 04-05-05
//1  cDe      - rementente do e-mail - Ex. "Alcir@ig.com.br"
//2  cPara    - destinatário do e-mail - Ex. "Alcir.alves@average.com.br"
//3  cAssunto - Assunto do e-mail - Ex. "Teste de envio automático de mailing"
//4  cCorpo   - corpo do e-mail - Ex. "Mensagem automática"
//5  cServ    - servidor SMTP de envio - Ex. "smtp.ig.com.br"
//6  cConta   - usuário da conta - Ex. "alcir@ig.com.br"
//7  cSenha   - senha do e-mail - Ex. "senha"
//8  lAut     - Indica se o servidor de envio de e-mails necessita de autenticação. - .T.(sim) ou .F.(não)
//9  cUsrAut  - Usuário para autenticação no servidor de envio de e-mails - Ex. "avrg023"
//10 cPswAut  - Senha para autenticação no servidor de envio de e-mails - Ex. "senhaaut"
*--------------------------------------*
//Alcir Alves - função padrão de envio de e-mail - 04-05-05
//                  1    2       3      4      5     6      7     8      9      10
FUNCTION EICINmail(cDe,cPara,cAssunto,cCorpo,cServ,cConta,cSenha,lAut,cUsrAut,cPswAut) 
*--------------------------------------*
Local lfRet:=.t.
Local lOK:=.f.
Local cServer  :=iif(cServ==Nil,AllTrim(EasyGParam("MV_RELSERV",," ")),cServ)
Local cAccount :=iif(cConta==Nil,AllTrim(EasyGParam("MV_RELACNT",," ")),cConta)
Local cPassword:=iif(cSenha==Nil,AllTrim(EasyGParam("MV_RELPSW",," ")),cSenha)
Local cFrom    :=iif(cDe==Nil,AllTrim(EasyGParam("MV_RELMFRO",," ")),cDe) 
Local cTo      :=iif(cPara==Nil,AllTrim(EasyGParam("MV_RELMTO",," ")),cPara)  //AllTrim(EasyGParam("MV_RESPINT"))
Local cSubject :=cAssunto
Local lAutentica  := iif(lAut==Nil,EasyGParam("MV_RELAUTH",,.F.),lAut) //Determina se o Servidor de Email necessita de Autenticação
Local cUserAut    := iif(cUsrAut==Nil,Alltrim(EasyGParam("MV_RELAUSR",,cAccount)),cUsrAut) //Usuário para Autenticação no Servidor de Email
Local cPassAut    := iif(cPswAut==Nil,Alltrim(EasyGParam("MV_RELAPSW",,cPassword)),cPswAut) //Senha para Autenticação no Servidor de Email
Private cBody  :=cCorpo


If !Empty(cServer) .And. !Empty(cAccount)  .And. !Empty(cTo)
      CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK
      IF (lOK)
         If lAutentica
            If !MailAuth(cUserAut,cPassAut)
               MSGINFO(STR0770,STR0094)//"Falha na Autenticação do Usuário"###"ERRO"
               DISCONNECT SMTP SERVER RESULT lOk
               IF !lOk
                  GET MAIL ERROR cErrorMsg
                  MSGINFO(STR0741) //"Erro durante a desconexão"
               ENDIF   
               lfRet := .F.
            EndIf
         EndIf
        
         If lfRet
            SEND MAIL FROM cFrom TO cTo SUBJECT cSubject BODY cBody RESULT lOK
            IF !(lOK)
               msgstop(STR0740) //"Erro durante o envio"
               lfRet:=.f.
    //         ConOut("Erro durante o envio")
               //Msgstop(mailgeterr())
            ENDIF
            DISCONNECT SMTP SERVER RESULT lOK
 			               
            IF !(lOK)
               msgstop(STR0741) //"Erro durante a desconexão"
               lfRet:=.f.
            ENDIF
         EndIf
      Else
         msgstop(STR0742)  //"Erro durante a conexão"
         lfRet:=.f.
	  ENDIF
EndIF

RETURN lfRet

/*
Funcao      : IN100TitNC
Parametros  : Titulo
Retorno     : NIL
Objetivos   : Imprimir Titulo da Nota Fiscal de Saida.
Autor       : Julio de Paula Paz 
Data/Hora   : 23/05/2005 - 9:00
Revisao     : 
Obs.        : 
*/
*-----------------------------*
FUNCTION IN100TitNC(cTit,lEnd)
*-----------------------------*
Cabec(cTit,cCabec1,cCabec2,nomeprog,tamanho,nComprimido)

* Status...............: XXXXXXXXXX                          Tipo.................: XXXXXXXX
* Dt Integ.............: 99/99/9999                          Tem Item Rejeitado...: XXX
* Código do Processo...: XXXXXXXXXXXXXXXXXXXX                Nota Fiscal..........: 999999
* Serie da Nota Fiscal.: XX                                  Data da Nota Fiscal..: 99/99/9999
* Tipo de Nota Fiscal..: XXXXXXX                             Valor da Nota Fiscal.: 999.999.999,99
* Valor da Mercadoria..: 999.999.999,99                      Valor do Frete.......: 999.999.999,99
* Valor do Seguro......: 999.999.999,99                      Valor Outras Despesas: 999.999.999,99
* Taxa.................: 999.999.999,99                      61                     84
* 02                     25
*------------------------------------------------------------------------------------------------------------------*
*Status     Tipo     Valor da N.F.  VALOR DA MERCADORIA Valor do Frete Valor do Seguro VAL.OUTRAS DESP. Pedido               Item                 Sequen. Quantidade     Mensagem
*---------- -------- -------------- ------------------- -------------- --------------- ---------------- -------------------- -------------------- ------- -------------- -------------------------------
*XXXXXXXXXX XXXXXXXX 999.999.999,99 999.999.999,99      999.999.999,99 999.999.999,99  999.999.999,99   XXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX 999999  999.999.999,99 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
*01         12       21             41                  56             72              89               104                  125                  147     160            169 


*---------------------------------------------------------------------------------------------------------*
IN100CabNC()
RETURN .T.

/*
Funcao      : IN100TitNC
Parametros  : Titulo
Retorno     : NIL
Objetivos   : Imprimir Cabeçalho da Nota Fiscal de Saida.
Autor       : Julio de Paula Paz 
Data/Hora   : 23/05/2005 - 9:30
Revisao     : 
Obs.        : 
*/

*--------------------*
FUNCTION IN100CabNC()
*--------------------*

Li++
@ Li,  02 PSay STR0750 // "Status...............:" 
@ Li,  25 PSay IN100Status()
@ Li,  61 PSay STR0751 // "Tipo.................:" 
@ Li,  84 PSay IN100TIPO()
Li++
@ Li,  02 PSay STR0752 // "Dt Integ.............:" 
@ Li,  25 PSay IN100CTD(EVAL(bDtInteg))
@ Li,  61 PSay STR0753 // "Tem Item Rejeitado...:"
@ Li,  84 PSay IN100StaIte()
Li++
@ Li,  02 PSay STR0754 // "Código do Processo...:"
@ Li,  25 PSay INT_NC->NNCPRO 
@ Li,  61 PSay STR0755 // "Nota Fiscal..........:"
@ Li,  84 PSay INT_NC->NNCNF
Li++
@ Li,  02 PSay STR0756 // "Serie da Nota Fiscal.:"
@ Li,  25 PSay INT_NC->NNCSER 
@ Li,  61 PSay STR0757 // "Data da Nota Fiscal..:"
@ Li,  84 PSay IN100CTD(INT_NC->NNCDT) 
Li++
@ Li,  02 PSay STR0758 // "Tipo de Nota Fiscal..:"
@ Li,  25 PSay IN100TIPNC()
@ Li,  61 PSay STR0759 // "Valor da Nota Fiscal.:"
@ Li,  84 PSay Transform(Val(INT_NC->NNCVNF),cPI1)
Li++
@ Li,  02 PSay STR0760 // "Valor da Mercadoria..:"
@ Li,  25 PSay Transform(Val(INT_NC->NNCVME),cPI2)
@ Li,  61 PSay STR0761 // "Valor do Frete.......:"
@ Li,  84 PSay Transform(Val(INT_NC->NNCVFR),cPI3)
Li++
@ Li,  02 PSay STR0762 // "Valor do Seguro......:"
@ Li,  25 PSay Transform(Val(INT_NC->NNCVSE),cPI4)
@ Li,  61 PSay STR0763 // "Valor Outras Despesas:"
@ Li,  84 PSay Transform(Val(INT_NC->NNCTOU),cPI5)
Li++
@ Li,  02 PSay STR0764 // "Taxa.................:"
@ Li,  25 PSay Transform(Val(INT_NC->NNCTX) ,cPI5)
Li++
Li++
@ Li,  01 PSay STR0765 // "Status     Tipo     Valor da N.F.  Valor da Mercadoria Valor do Frete Valor do Seguro Val.Outras Desp. Pedido               Item                 Sequen. Quantidade Mensagem"
Li++
@ Li,  01 PSay "---------- -------- -------------- ------------------- -------------- --------------- ---------------- -------------------- -------------------- ------- ---------- ------------------------------------------------------------"
Li++
Return .t.
/*
Funcao      : IN100TitNC
Parametros  : Titulo
Retorno     : NIL
Objetivos   : Imprimir os itens da Nota Fiscal de Saida.
Autor       : Julio de Paula Paz 
Data/Hora   : 23/05/2005 - 9:30
Revisao     : 
Obs.        : 
*/
*-----------------------------*
Function IN100DetNC(cTit,lEnd)
*-----------------------------*
LOCAL cMsg:= INT_ND->NNDMSG , I 
If Li > 55
   IN100TitPO(cTit,@lEnd)
EndIf 

@ Li, 01 PSay IN100Status()
@ Li, 12 PSay IN100TIPO() 
@ Li, 21 PSay TRANSFORM(VAL(INT_ND->NNDVNF),cPI1)
@ Li, 41 PSay TRANSFORM(VAL(INT_ND->NNDVME),cPI2)
@ Li, 56 PSay TRANSFORM(VAL(INT_ND->NNDVFR),cPI3)
@ Li, 72 PSay TRANSFORM(VAL(INT_ND->NNDVSE),cPI4) 
@ Li, 89 PSay TRANSFORM(VAL(INT_ND->NNDTOU),cPI5) 
@ Li,104 PSay INT_ND->NNDPED               
@ Li,125 PSay INT_ND->NNDITE               
@ Li,147 PSay INT_ND->NNDPOS    
@ Li,160 PSay INT_ND->NNDQTD
//@ Li,169 PSay IN100E_Msg(.T.)
//Li++
For I:=1 to MlCount(AllTrim(cMsg),LEN_MSG) 
    @ Li,165 PSay MemoLine(cMsg,LEN_MSG,I)
    Li++
Next
If MlCount(AllTrim(cMsg),LEN_MSG) = 0
   Li++
EndIf
Return .t.


/*
Funcao     : In100Control()
Parametros : Nenhum
Retorno    : .t.,.f.
Objetivos  : Fazer controle para que 2 ou mais usuários não façam uma mesma integração ao mesmo tempo
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 11/07/05 - 11:00
*/

*---------------------*
Function In100Control(cArq,cExt)
*---------------------*
Local nOldArea := Select()
Local lRet := .t., nTam := 3
//Local cName := cDirStart+"EECIN100" , cFile := cName + GetDBExtension() 
Local cName, cFile
Local aStruct := {{"WK_OPCAO","C",nTam,0}}
Local cAlias  := cAliasControl
Local cIndexKey := aStruct[1][1]
Local cDRVOpen
// Local cFileExt

cName := cDirStart + (CriaTrab(,.F.)) // TLM 16/01/2008 - Para gerar diferentes nomes para o índice.
cFile := cDirStart + "EECIN100" + GetDBExtension()

/*
AMS - 11/10/2005. Tratamento para utilizar o RDD "DBFCDX" quando o ADS Server for para o RDD local.
*/
If RealRDD() == "ADSSERVER"
   cDRVOpen := "DBFCDX"
Else
   cDRVOpen := "DBFCDXADS"
EndIf

Begin Sequence

   cFile := "EECIN100"
   // cFileExt := IN100File(cArq,cExt)
   If !MSFILE(cFile)
      MSCREATE(cFile,aStruct,"TOPCONN")
   EndIf 

   If Select(cAlias) = 0 //Abre o arquivo, se não estiver aberto ainda (no caso do arquivo já existir)
      dbUseArea(.T.,"TOPCONN",cFile,cAlias,.T.,.F.)
      //IndRegua(cAlias,cName+TeOrdBagExt(),cIndexKey,"AllwayTrue()","AllwaysTrue()")
      IN100IndRg( {{cAlias , cFile , {cIndexKey} }}   )
   EndIf
   
   DbSelectArea(cAlias)
   (cAlias)->(DbSetOrder(1))
   If (cAlias)->(DbSeek(StrZero(nOpcao,nTam))) //se a opção já existir no arquivo
      If (cAlias)->(!MsRLock())                //e estiver travada, dá mensagens, de acordo com a situação:
         If lParam
            ConOut(STR0768) //"A integração não pôde ser realizada. Motivo: No momento há outro usuário executando esta mesma integração."
         Else
            MsgInfo(STR0768,STR0769) //"A integração não pôde ser realizada. Motivo: No momento há outro usuário executando esta mesma integração.","Aviso"
         EndIf
         lRet := .f.
         Break
      EndIf
   Else //Se a opção não existir na tabela, então é appendada e fica locada até a finalização da integração.
      (cAlias)->(RecLock(cAlias,.t.),;
                 WK_OPCAO := StrZero(nOpcao,nTam))
   EndIf
   (cAlias)->(DbCommit())
End Sequence

DbSelectArea(nOldArea)

Return lRet

/*
Funcao     : In100Unlock()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Dar unlock no registro de controle de usuários
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 11/07/05 - 16:57
*/

*---------------------*
Function In100Unlock()
*---------------------*
Begin Sequence

   If lControlUser .And. !lPrevia
      If Select(cAliasControl) > 0 .And. Type("nOpcao") = "N"
         (cAliasControl)->(DbSetOrder(1))
         If (cAliasControl)->(DbSeek(StrZero(nOpcao,(DbStruct()[1][3]) ) ) )
            (cAliasControl)->(MsRUnlock(),DbCommit()) //Desaloca o registro
         EndIf
      EndIf
   EndIf

End Sequence

Return Nil
*-------------------------------------*
 Function INRatLote(PQtdeTXT)
*-------------------------------------*
Local P,nValor

nPerc:=SWV->WV_QTDE/PQtdeTXT  // RJB 26/04/2006         //VAL(Int_FD->NFDQUANT) //nQtde

Int_FD->NFDQUANT   := STR(SWV->WV_QTDE,LEN(Int_FD->NFDQUANT),04)
Int_FD->NFDLOTECTL := SWV->WV_LOTE
Int_FD->NFDDTVALLT := SWV->WV_DT_VALI

If EasyEntryPoint("IN100CLI")                       // RJB 21/02/2006
   ExecBlock("IN100CLI",.F.,.F.,"ATUALIZA_FD")
EndIf

//Rateio
FOR P := 1 TO LEN(aValor)
   nValor := aValor[P,1] * nPerc
   IF aValor[P,4] = nPosPesol
      Int_FD->(FieldPut( aValor[P,4] , STR(nValor,11,4) ))
   else
      Int_FD->(FieldPut( aValor[P,4] , STR(nValor,15,2) ))
   endif   
NEXT
//Somatoria
FOR P := 1 TO LEN(aValor)
   aValor[P,2]:= aValor[P,2] + VAL(Int_FD->(FieldGet( aValor[P,4] )))
NEXT
Return
*------------------------------------------------*
FUNCTION QuebraLote()
*------------------------------------------------*
LOCAL D,J,C,N,nPosicao,lInvoice:=.T.,nTamReg:=AVSX3("WV_REG",3)
LOCAL aRecInt_FD:={}
LOCAL nRecnoFD:=Int_FD->(RECNO())
LOCAL nSWVRecno:=0    // RJB 26/01/2005
LOCAL nQtd_Lote := 0  // RJB 26/01/2005
PRIVATE nPosPesol

DO WHILE ! Int_FD->(EOF()) .AND. Int_FD->NFDNOTA == Int_FE->NFENOTA
   AADD(aRecInt_FD,Int_FD->(RECNO()))
   Int_FD->(DBSKIP())
ENDDO

Int_FD->(DBGOTO(nRecnoFD))

ProcRegua(LEN(aRecInt_FD))

SWV->(DBSETORDER(1))


aCampos:={}   // campos que serao duplicados 
//Campos que nao podem ser rateados
aCpos:={}
AADD(aCpos,"NFDQUANT")
AADD(aCpos,"NFDPESOL" )
AADD(aCpos,"NFDQUANT" )
AADD(aCpos,"NFDVALOR" )
AADD(aCpos,"NFDFOBRS" )
AADD(aCpos,"NFDFRETE" )
AADD(aCpos,"NFDSEGURO" )
AADD(aCpos,"NFDIITX" )
AADD(aCpos,"NFDII" )
AADD(aCpos,"NFDIPITX" )
AADD(aCpos,"NFDIPI" )
AADD(aCpos,"NFDICMSTX") //NCF - 11/02/2011 - Alíquota de ICMS por item
AADD(aCpos,"NFDBASEICM" )
AADD(aCpos,"NFDICMS" )
AADD(aCpos,"NFDDESPESA" )
//AADD(aCpos,"NFDPERPIS")
//AADD(aCpos,"NFDVLUPIS")
AADD(aCpos,"NFDBASPIS")
AADD(aCpos,"NFDVLRPIS")
//AADD(aCpos,"NFDPERCOF")
//AADD(aCpos,"NFDVLUCOF")
AADD(aCpos,"NFDBASCOF")
AADD(aCpos,"NFDVLRCOF")
AADD(aCpos,"NFDPESOL" )
AADD(aCpos,"NFDQUANT" )
//AADD(aCpos,"NFDLOTE")     RJB 21/02/2006
//AADD(aCpos,"NFDDTVALID")  RJB 21/02/2006
AADD(aCpos,"NFDLOTECTL")   //  RJB 21/02/2006
AADD(aCpos,"NFDDTVALLT")   //  RJB 21/02/2006

aValor:={}   
AADD(aValor,{0,0,0,Int_FD->(FIELDPOS("NFDPESOL" ))})
//AADD(aValor,{0,0,0,Int_FD->(FIELDPOS("NFDQUANT" ))})
AADD(aValor,{0,0,0,Int_FD->(FIELDPOS("NFDVALOR" ))})
AADD(aValor,{0,0,0,Int_FD->(FIELDPOS("NFDFOBRS" ))})
AADD(aValor,{0,0,0,Int_FD->(FIELDPOS("NFDFRETE" ))})
AADD(aValor,{0,0,0,Int_FD->(FIELDPOS("NFDSEGURO" ))})
AADD(aValor,{0,0,0,Int_FD->(FIELDPOS("NFDIITX" ))})
AADD(aValor,{0,0,0,Int_FD->(FIELDPOS("NFDII" ))})
AADD(aValor,{0,0,0,Int_FD->(FIELDPOS("NFDIPITX" ))})
AADD(aValor,{0,0,0,Int_FD->(FIELDPOS("NFDIPI" ))})
AADD(aValor,{0,0,0,Int_FD->(FIELDPOS("NFDICMSTX" ))})  //NCF - 11/02/2011 - Grava Alíquota de ICMS por item
AADD(aValor,{0,0,0,Int_FD->(FIELDPOS("NFDBASEICM" ))})
AADD(aValor,{0,0,0,Int_FD->(FIELDPOS("NFDICMS" ))})
AADD(aValor,{0,0,0,Int_FD->(FIELDPOS("NFDDESPESA"))})
//AADD(aValor,{0,0,0,Int_FD->(FIELDPOS("NFDPERPIS"))})
//AADD(aValor,{0,0,0,Int_FD->(FIELDPOS("NFDVLUPIS"))})
AADD(aValor,{0,0,0,Int_FD->(FIELDPOS("NFDBASPIS"))})
AADD(aValor,{0,0,0,Int_FD->(FIELDPOS("NFDVLRPIS"))})
//AADD(aValor,{0,0,0,Int_FD->(FIELDPOS("NFDPERCOF"))})
//AADD(aValor,{0,0,0,Int_FD->(FIELDPOS("NFDVLUCOF"))})
AADD(aValor,{0,0,0,Int_FD->(FIELDPOS("NFDBASCOF"))})
AADD(aValor,{0,0,0,Int_FD->(FIELDPOS("NFDVLRCOF"))})

If EasyEntryPoint("IN100CLI")                       // RJB 21/02/2006
   ExecBlock("IN100CLI",.F.,.F.,"CARGA_AVALOR")
EndIf

nPosPesol:=Int_FD->(FIELDPOS("NFDPESOL" ))


DBSELECTAREA("Int_FD")
FOR nPosicao := 1 TO FCOUNT()
   IF VALTYPE(FIELDGET(nPosicao)) $ "CDL" .AND. ASCAN(aCpos,FIELD(nPosicao)) = 0
      AADD(aCampos,FIELD(nPosicao)) // campos que serao duplicados 
// ELSEIF VALTYPE(FIELDGET(nPosicao)) $ "N" .AND. ASCAN(aCampos,FIELD(nPosicao)) = 0
//    AADD(aValor,{0,0,0,nPosicao})
   ENDIF
NEXT
aDados:=ARRAY(LEN(aCampos))

SW7->(dbsetorder(4))
FOR N := 1 TO LEN(aRecInt_FD)


    Int_FD->(dbGoTo(aRecInt_FD[N]))

    cCod_I  := AvKey( LEFT(Int_FD->NFDCOD_I ,LEN(SB1->B1_COD   )), "B1_COD")             //NCF - 28/03/2011 - Acerto na chave do Item
    cPo_NUM := AvKey(Int_FD->NFDPO_NUM,"W2_PO_NUM")
    Int_FD->NFDITEM  :=STRZERO(VAL(Int_FD->NFDITEM),nTamPosicao)

    IF ! SW7->(dbseek(cFilSW7+AvKey(Int_FE->NFEHAWB,"W7_HAWB")+cPo_NUM+INT_FD->NFDITEM))                                   //MJB-SAP-0401   
//       EVAL(bMsg,"ITEM NAO CAD. NO EMBARQUE - P.O. "+ALLTRIM(cPo_NUM)+" LINHA "+INT_FD->NFDITEM)   // RJB 26/01/2005
    ENDIF

    IncProc("Verificando Lotes, Item: " +Int_FD->NFDCOD_I)

    lAchouSWV:= .F.
    IF LEFT(Int_FD->NFDPLI,1) == "*" .OR. lInvoice
       lAchouSWV:=SWV->(dbSeek(cFilSWV+SW6->W6_HAWB+SW7->W7_PGI_NUM+SW7->W7_PO_NUM+SW7->W7_CC+SW7->W7_SI_NUM+SW7->W7_COD_I+STR(SW7->W7_REG,nTamReg)) )
    ELSE
       lAchouSWV:=SWV->(dbSeek(cFilSWV+SPACE(LEN(SWV->WV_HAWB))+SW7->W7_PGI_NUM+SW7->W7_PO_NUM+SW7->W7_CC+SW7->W7_SI_NUM+SW7->W7_COD_I+STR(SW7->W7_REG,nTamReg)) )
    ENDIF

    IF lAchouSWV

       nQtde       := VAL(Int_FD->NFDQUANT)
       FOR D := 1 TO LEN(aValor)
           aValor[D,1]:= VAL(Int_FD->(FieldGet( aValor[D,4] )))
       NEXT

       AEVAL(aValor,{|t,I|aValor[I,2]:=0})
 
**** RJB 26/01/2005 VALIDAR QUANTIDADE , COM QUANTIDADE NO LOTE
       nSWVRecno := SWV->(RECNO())

       IF LEFT(Int_FD->NFDPLI,1) == "*" .OR. lInvoice
          cHAWB:=SW7->W7_HAWB
       ELSE
          cHAWB:=SPACE(LEN(SWV->WV_HAWB))
       ENDIF
       nQtd_Lote := 0
       DO While !SWV->(Eof())                      .And.;
                SWV->WV_FILIAL  == cFilSWV  .And.;
                SWV->WV_HAWB    == cHAWB    .AND.;
                SWV->WV_PGI_NUM == SW7->W7_PGI_NUM .And.; 
                SWV->WV_PO_NUM  == SW7->W7_PO_NUM  .And.; 
                SWV->WV_CC      == SW7->W7_CC      .And.; 
                SWV->WV_SI_NUM  == SW7->W7_SI_NUM  .And.; 
                SWV->WV_COD_I   == SW7->W7_COD_I   .And.; 
                SWV->WV_POSICAO == SW7->W7_POSICAO
  
            nQtd_Lote += SWV->WV_QTDE

            SWV->(dbSkip())

            IF LEFT(Int_FD->NFDPLI,1) == "*" .OR. lInvoice
               cHAWB:=SW6->W6_HAWB
            ELSE
               cHAWB:=SPACE(LEN(SWV->WV_HAWB))
            ENDIF
       EndDo

       SWV->(DBGOTO(nSWVRecno))
****
       IF nQtd_Lote = nQtde // RJB 26/01/2005 - NAO DISTRIBUIR QDO QTDE DIVERGE

          INRatLote(nQtde)

          SWV->(dbSkip())
          IF LEFT(Int_FD->NFDPLI,1) == "*" .OR. lInvoice
             cHAWB:=SW7->W7_HAWB
          ELSE
             cHAWB:=SPACE(LEN(SWV->WV_HAWB))
          ENDIF
          DO While !SWV->(Eof())                      .And.;
                   SWV->WV_FILIAL  == cFilSWV  .And.;
                   SWV->WV_HAWB    == cHAWB    .AND.;
                   SWV->WV_PGI_NUM == SW7->W7_PGI_NUM .And.; 
                   SWV->WV_PO_NUM  == SW7->W7_PO_NUM  .And.; 
                   SWV->WV_CC      == SW7->W7_CC      .And.; 
                   SWV->WV_SI_NUM  == SW7->W7_SI_NUM  .And.; 
                   SWV->WV_COD_I   == SW7->W7_COD_I   .And.; 
                   SWV->WV_POSICAO == SW7->W7_POSICAO
  
               For j := 1 To LEN(aCampos)
                   aDados[J]:=Int_FD->(FieldGet(FieldPos(aCampos[j])))
               Next

               Int_FD->(DBAPPEND())

               For j := 1 To LEN(aCampos)
                   IF !EMPTY(aDados[J])
                      Int_FD->(FieldPut(FieldPos(aCampos[j]),aDados[J]))
                   ENDIF
               Next

               INRatLote(nQtde)

               SWV->(dbSkip())

               IF LEFT(Int_FD->NFDPLI,1) == "*" .OR. lInvoice
                  cHAWB:=SW6->W6_HAWB
               ELSE
                  cHAWB:=SPACE(LEN(SWV->WV_HAWB))
               ENDIF
          EndDo
   
          //Diferenca  :=Total Original - Somatoria
          FOR D := 1 TO LEN(aValor)
              aValor[D,3]:= aValor[D,1] - aValor[D,2]
              nValor := VAL(Int_FD->(FieldGet( aValor[D,4] ))) + aValor[D,3]
              IF aValor[d,4] = nPosPesol
                 Int_FD->(FieldPut( aValor[D,4] , STR(nValor,11,4) ))
              else
                 Int_FD->(FieldPut( aValor[D,4] , STR(nValor,15,2) ))           
              endif
          NEXT
       ELSE    // RJB 26/01/2005
          EVAL(bMsg,"A quantidade do Item - Item "+ALLTRIM(SW7->W7_COD_I)+" P.O. "+ALLTRIM(cPo_NUM)+" Linha "+ALLTRIM(INT_FD->NFDITEM)+" esta diferente do Lote")   // RJB 26/01/2005
       ENDIF   // RJB 26/01/2005
   Endif

NEXT
Int_FD->(DBGOTO(nRecnoFD))//ASR 10/01/2006 - PARA RESTAURAR A POSICAO INICIAL DA TABELA
Return(NIL)

/*
Funcao     : IN100VALDESP()
Parametros : Nenhum
Retorno    : lRet
Objetivos  : Validar se foi inclusão automatica da despesa.
Autor      : Jean Victor Rocha
Data/Hora  : 18/11/2009
*/
*-------------------------*
Function IN100VALDESP(cDesp)
*-------------------------*
Local lRet     := .F.
Local nICMS    := 0
Local lTemAdicao:= GETNEWPAR("MV_TEM_DI",.F.)
IF !lTemAdicao//AWR - 20/04/2010
   Return .F.
ENDIF
cCod_D_II   := EasyGParam("MV_D_II"  ,,"201")
cCod_D_IPI  := EasyGParam("MV_D_IPI" ,,"202")
cCod_D_ICMS := EasyGParam("MV_D_ICMS",,"203")
cCod_D_PIS  := EasyGParam("MV_D_PIS" ,,"204")
cCod_D_COF  := EasyGParam("MV_D_COF" ,,"205")

cCod_EII:=ALLTRIM(GETNEWPAR("MV_COD_EII","2892,3345,5602,5629"))

aCodValEII:={}
DO WHILE !EMPTY(cCod_EII)
   nPos:=AT(',',cCod_EII)
   IF nPos # 0 
      AADD(aCodValEII,SUBSTR(cCod_EII,1,nPos-1))
      cCod_EII:=SUBSTR(cCod_EII,nPos+1)
   ELSE
      AADD(aCodValEII,cCod_EII)
      cCod_EII:=""
   ENDIF
ENDDO

DO CASE                  
   
   //*****************************  I.I    *****************************
   CASE cDesp = cCod_D_II                                                                                     
      EII->(DbSetOrder(1))
      If lTemAdicao .and. SW6->W6_ADICAOK $ cSim .AND. EII->(DbSeek(xFilial() + SW6->W6_HAWB + aCodValEII[1])) .AND. Len(aCodValEII) > 0
         lRet := .T.
      EndIf
  
   //*****************************  I.P.I   *****************************
   CASE cDesp = cCod_D_IPI
      EII->(DbSetOrder(1))
      If lTemAdicao .and. SW6->W6_ADICAOK $ cSim .AND. EII->(DbSeek(xFilial() + SW6->W6_HAWB + aCodValEII[2])) .AND. Len(aCodValEII) > 1
         lRet := .T.
      EndIf

   //*****************************  I.C.M.S   *****************************   
   CASE cDesp = cCod_D_ICMS
      nICMS:=0    
      EIJ->(DbSetOrder(1))
      EIJ->(DbSeek(xFilial() + SW6->W6_HAWB))   
      Do While EIJ->(!EOF()) .and. EIJ->EIJ_HAWB = SW6->W6_HAWB
         nICMS  += EIJ->EIJ_VLICMS
         EIJ->(DbSkip())
      EndDo
      If lTemAdicao .and. SW6->W6_ADICAOK $ cSim .AND. !Empty(nICMS)
         lRet := .T.
      EndIf
  
   //*****************************  PIS    *****************************   
   CASE cDesp = cCod_D_PIS
      EII->(DbSetOrder(1))
      If lTemAdicao .and. SW6->W6_ADICAOK $ cSim .AND. EII->(DbSeek(xFilial() + SW6->W6_HAWB + aCodValEII[3])) .AND. Len(aCodValEII) > 2
         lRet := .T.
      EndIf
      
   //*****************************  COFINS  *****************************   
   CASE cDesp = cCod_D_COF
      EII->(DbSetOrder(1))    
      If lTemAdicao .and. SW6->W6_ADICAOK $ cSim .AND. EII->(DbSeek(xFilial() + SW6->W6_HAWB + aCodValEII[4])) .AND. Len(aCodValEII) > 3
         lRet := .T.
      EndIf

ENDCASE
   
Return lRet      

/*
Funcao     : BuscaQtdInv()
Parametros : cHawb    = Numero do processo
             cInvoice = numero da Invoice
             cCodItem = Codigo do item para busca
Retorno    : cQuantidade = valor da quantidade total do item na invoice.  (Tipo Numerico)
Objetivos  : Retornar o valor da quantidade para um determinado item.
Autor      : Jean Victor Rocha
Data/Hora  : 25/02/2010
*/
*----------------------------------------------------*
Static Function BuscaQtdInv(cHawb, cInvoice, cCodItem)
*----------------------------------------------------*
Local nQuantidade := 0
Local aOrd := SaveOrd("SW8")

SW8->(DbSetOrder(1))
If SW8->(DbSeek(xFilial("SW8") + cHawb + cInvoice))
   While SW8->(!EOF())               .and.;
         SW8->W8_HAWB    == cHawb    .and.;
         SW8->W8_INVOICE == cInvoice
      If SW8->W8_COD_I == AVKEY(cCodItem,"W8_COD_I")
         nQuantidade += SW8->W8_QTDE
      EndIf
      SW8->(DbSkip())
   EndDo

EndIf

RestOrd(aOrd,.T.)

Return nQuantidade

*------------------------------------------------------*
Static Function AvLogView(xMsg,cTitulo,cLabel, aButtons, bValid)
*------------------------------------------------------*
Local lRet := .F., i, j
Local oDlg, oMemo, oFont := TFont():New("Courier New",09,15)

Local bOk      := {|| If( Eval(bValid), (AVNote(.t.,cMsg),lRet:=.T.,oDlg:End()), )},;
      bCancel  := {|| AVNote(.t.,cMsg),oDlg:End()}

Local cMsg := ""   
Local nQuebra := 88
Local cLib

Default xMsg     := ""
Default cTitulo  := ""
Default cLabel   := ""
Default aButtons := {}
Default bValid   := {|| .T. }

Begin Sequence
   
   GetRemoteType(@cLib) 
   If "WIN" $ cLib
      aAdd(aButtons, {"NOTE" ,{||  AVNote(.f.,cMsg,"EECView.txt")},"NotePad",})
   EndIf

   If ValType(xMsg) = "C"
      cMsg := xMsg
   ElseIf ValType(xMsg) = "A"
      For i := 1 To Len(xMsg)
         If xMsg[i][2] // Posição que define se fará quebra de linha
            For j := 1 To MLCount(xMsg[i][1],nQuebra)
               cMsg += MemoLine(xMsg[i][1], nQuebra, j) + ENTER
            Next
         Else
            cMsg += xMsg[i][1]
         EndIf
      Next
   EndIf
   // **

  
   Define MsDialog oDlg Title cTitulo From 9,0 To 47,105 of oDlg

      @ 15,05 To 270,410 Label cLabel Pixel Of oDlg
      @ 25,10 Get oMemo Var cMsg MEMO HSCROLL FONT oFont Size 395,240 READONLY Of oDlg  Pixel

      oMemo:lWordWrap := .F.
      oMemo:EnableVScroll(.t.)
      oMemo:EnableHScroll(.t.)

   Activate MsDialog oDlg On Init Enchoicebar(oDlg,bOk,bCancel,,,,,,aButtons,) Centered 

End Sequence

Return lRet

*----------------------------------------*
Static Function AVNote(lApaga,cMsg,cFile)
*----------------------------------------*
Local lRet:=.t., cDir:=GetTempPath(),hFile

Default lApaga := .f. // Se .t. apaga arquivo temporário.
Default cFile  := "EECView.txt"

Begin Sequence

   If !lApaga
      hFile := EasyCreateFile(cDir+cFile)

      fWrite(hFile,cMsg,Len(cMsg))

      fClose(hFile)

      //WinExec("NotePad "+cDir+cFile)
      ShellExecute("open",cDir + cFile,"","", 1)
   Else
      If File(cDir+cFile)
         fErase(cDir+cFile)
      EndIf
   EndIf

End Sequence

Return lRet

/*
Funcao     : DSPDELin()
Parametros : cHawb    = Numero do processo
             cDespesa = numero da despesa
Retorno    : Nil
Objetivos  : Numerar de ordem crescente as despesas, agrupando por codigo
			 para ser utilizado na gravação da despesa na tabela SWD.
Autor      : Laercio Gonçalves de Souza Junior
Data/Hora  : 08/04/2014
*/
*----------------------------------------*
Function DSPDELin(cHawb,cDespesa)
*----------------------------------------*
Local cLinha 
Local nLinha := 0
Local nOrd   := INT_DSPDE->(IndexOrd())
Local nReg   := INT_DSPDE->(RecNo())

//IndRegua("Int_DspDe", "NDD"+cRegNPAT+"0"+TeOrdBagExt(),"NDDHOUSE+NDDDESPESA")
//IN100IndRg( {{"Int_DspDe" , "NDD"+cRegNPAT , {"NDDHOUSE","NDDHOUSE+NDDDESPESA"} }}  ) //NCF - 20/04/2021 - Movido para IN100_Abre()

If Int_DspDe->(DbSeek(cHawb + cDespesa))
	While Int_DspDe->(!Eof()) .And. Int_DspDe->NDDDESPESA == cDespesa
		If !Empty(Int_DspDe->NDD_LINHA)
			nLinha ++
		EndIf
		Int_DspDe->(DbSkip())
	EndDo    
EndIf
             
If nLinha == 0
   cLinha := StrZero(1,AvSX3("WD_LINHA",AV_TAMANHO))
Else
   nLinha ++
   cLinha := StrZero(nLinha,AvSX3("WD_LINHA",AV_TAMANHO))
EndIf

Int_DspDe->( DBGoTo(nReg) )
Int_DspDe->NDD_LINHA := cLinha
Int_DspDe->(dbSetOrder(nOrd),dbGoTo(nReg))

Return Nil
                  
*----------------------------------------*
FUNCTION IN100PesqVal()                  //LGS-04/03/2015
*----------------------------------------*
LOCAL aOrdFD := {}
Local oRatAFRMM
Local nAFRMM

IF SWN->(FieldPos("WN_NVE"))   # 0 .And.;
   SWN->(FieldPos("WN_AC"))    # 0 .And.;
   SWN->(FieldPos("WN_AFRMM")) # 0
   aOrdFD := SaveOrd({"SW8","SW6"})
   SW8->(DBSETORDER(6))
   INT_FD->(DBGOTOP())
   nAFRMM := Posicione("SWD",1,xFilial("SWD")+AvKey(Int_FD->NFDHAWB,"W6_HAWB")+AvKey(EasyGParam("MV_CODAFRM",,"405"),"WD_DESPESA"),"WD_VALOR_R")
   If lRatPeso
      oRatAFRMM := EasyRateio():New(nAFRMM,MDI_PESOL,INT_FD->(EasyRecCount()),AvSX3("WN_AFRMM",AV_DECIMAL))
   Else
      oRatAFRMM := EasyRateio():New(nAFRMM,MDI_TOTNF,INT_FD->(EasyRecCount()),AvSX3("WN_AFRMM",AV_DECIMAL))
   EndIf
   DO WHILE INT_FD->(!EOF())
      IF SW8->(DBSEEK(xFilial("SW8") + TRIM(INT_FD->(AvKey(NFDHAWB,"W6_HAWB")+AvKey(NFDFATURA,"W9_INVOICE")+AvKey(NFDPO_NUM,"W2_PO_NUM"))) ))
         INT_FD->NFDNVE := SW8->W8_NVE
         INT_FD->NFDATO := atoConcess()
      ENDIF
      
      IF SW6->(DBSEEK(xFilial("SW6") + AvKey(Int_FD->NFDHAWB,"W6_HAWB"))) .And. SW8->(DBSEEK(xFilial("SW8") + AvKey(Int_FD->NFDHAWB,"W6_HAWB")))
         INT_FD->NFDAFRMM := DI154CaAFRMM(lRatPeso,,,oRatAFRMM)
      ENDIF
      
      INT_FD->(DBSKIP())
   ENDDO
   INT_FD->(DBGOTOP())
   RestOrd(aOrdFD)
ENDIF

RETURN NIL

Static Function atoConcess()
Local atoCon
If EasyGParam("MV_EIC_EDC",,.F.) == .F.
    SW4->(dbSetOrder(1))
    SW4->(dbSeek(xFilial("SW4") + SW8->W8_PGI_NUM))
    atoCon := SW4->W4_ATO_CON
Else
    atoCon := SW8->W8_AC
EndIf
Return atoCon



/*
Funcao     : GetDpTabDP()
Parametros : cDespTXT = Código do despachante no arquivo TXT
             cREfDesp = Código de referência do despachante no arquivo TXT
Retorno    : aDesp, onde: aDesp[x][1] = Codigo do despachante no processo
                          aDesp[x][2] = Nro. do registro do processo na tabela
                          aDesp[x][3] = Código do processo
             obs: retorna vazio se não informado o cod. TXT do despachante                         
Objetivos  : Retornar o código do despachante no processo através de uma
             referência para os casos em que exista cadastro de conversão
             na tabela DE/PARA
Autor      : Nilson César C. Filho
Data/Hora  : 17/11/2016
*/
*--------------------------------------------*
STATIC FUNCTION GetDpTabDP(cDespTXT,cRefDesp)
*--------------------------------------------*
Local aDesp      := {}
Local cQuery     := ""
Local nOldArea   := SELECT()
Local aNotCmpos  := {{"RECNO","N",10,0}}
Default cDespTXt := ""
Default cRefDesp := ""

If !Empty(cDespTXT)

   cQuery := "SELECT SW6.W6_FILIAL,SW6.W6_HAWB, SW6.W6_REF_DES, SYU.YU_GIP_1, SYU.YU_EASY, SW6.R_E_C_N_O_ Recno"
   cQuery += " FROM "+RetSQLName("SW6")+" SW6"
   cQuery += " INNER JOIN "+RetSQLName("SYU")+" SYU"
   cQuery += " ON SW6.W6_DESP = SYU.YU_EASY"
   cQuery += " AND SYU.YU_GIP_1 = '"    +AvKey(cDespTXT   ,"YU_GIP_1"  )+"'" 
   cQuery += " AND SYU.YU_TIP_CAD = '5'" //LRS - 01/11/2017

   If !Empty(cRefDesp)
      cQuery += " AND SW6.W6_REF_DES = '"  +AvKey(cRefDesp   ,"W6_REF_DES")+"'"
   EndIf

   cQuery += " AND SW6.D_E_L_E_T_ = ' ' AND SYU.D_E_L_E_T_ = ' '"    
   cQuery += " AND SW6.W6_FILIAL = '" + cFilSW6 + "' AND SYU.YU_FILIAL = '" + cFilSY5 + "' "

   If Select("REFDESPROC") > 0
      REFDESPROC->(DbCloseArea())
   EndIf
      
   EasyWkQuery(cQuery,"REFDESPROC",,aNotCmpos,)
    
   Do while REFDESPROC->(!Eof())
      aAdd(aDesp,{REFDESPROC->YU_EASY,REFDESPROC->RECNO ,REFDESPROC->W6_HAWB})

      REFDESPROC->(DbSkip())
   EndDo 
   
   REFDESPROC->(DbCloseArea())
   DBSELECTAREA(nOldArea)
EndIf

return aDesp

/*
Funcao      : IN100IndRg
Parâmetros  : aInd -> { cAliasTab  = Alias da Tabela,
                        cAliasArq  = Nome do arquivo físico da tabela, 
                        aChaves    = Array com a(s) chave(s) de cada índice a ser adicionao ao arquivo }
Retorno     : lRet
Objetivos   : Verificar se existem os índices da tabela listados no array e criá-los caso não existam.
Autor       : Nilson César
Data/Hora   : 08/08/2018
*/
STATIC FUNCTION IN100IndRg( aInd )

//aInd := { cAliasTab , cAliasArq , cChave }

Local lTmpBco    := TETempBanco()
Local cSeqInd    := "0"
Local lRet       := .T.
Local aInds := {}
Local i,j
Private aIndCustom := {} //Array que será manipulado via Ponto de Entrada para customizações - criação de novos índices


For i:=1 to Len( aInd )
   aIndCustom := {}
   IF(EasyEntryPoint("EICIN100"),Execblock("EICIN100",.F.,.F.,{"CRIA_INDICE", aInd[i]}),)
   cSeqInd    := "0"
   For j:=1 To Len(aInd[i][3])
      If !MsFile( aInd[i][2] , aInd[i][2] + cSeqInd + TEOrdBagExt(), "TOPCONN")
         Index on &(aInd[i][3][j]) to &( aInd[i][2] + cSeqInd + TEOrdBagExt())
      EndIf
      aAdd(aInds, aInd[i][2] + cSeqInd + TEOrdBagExt())
      cSeqInd := Soma1(cSeqInd)
   Next j
   cSeqInd    := "0"
   For j:=1 To Len(aIndCustom)
      If !MsFile( aInd[i][2] , aInd[i][2] + "CUSTOM" + cSeqInd + TEOrdBagExt(), "TOPCONN")
         Index on &(aIndCustom[j]) to &( aInd[i][2] + "CUSTOM" + cSeqInd + TEOrdBagExt())
      EndIf
      aAdd(aInds, aInd[i][2] + "CUSTOM" + cSeqInd + TEOrdBagExt())
      cSeqInd := Soma1(cSeqInd)
   Next j
   (aInd[i][1])->(DBClearIndex())
   For j:=1 To Len(aInds)
      DbSetIndex(aInds[j])
   Next
   DbSetOrder(1)
Next i

Return lRet

/*
Função     : CMPSTRUCT
Objetivo   : Comparar o array aEstruDef, onde é definida a estrutura dos arquivos de integração, com a estrutura no banco de dados, 
				 para saber se houve mudança e precisa recriar o arquivo no banco;
Retorno    : Lógico: .T. se houve mudança na estrutura e .F. se não houve mudança na estrutura;
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 16/08/2019
*/
Static Function CMPSTRUCT(cAlias)
Local lRet 			:= .F.
Local aEstruBanc 	:= (cAlias)->(dbstruct())
Local aCpyEstru   := aClone(aEstruDef)

If Len(aEstruBanc) != Len(aCpyEstru)
	lRet := .T.
Else
	aSort(aEstruBanc,,,{|x,y| x[1] < y[1]} )
	aSort(aCpyEstru ,,,{|x,y| x[1] < y[1]} )
	If aScanX(aEstruBanc,{|x,y| Alltrim(x[1]) != Alltrim(aCpyEstru[y][1]) .Or. Alltrim(x[2]) != Alltrim(aCpyEstru[y][2]) .Or. Alltrim(x[3]) != Alltrim(aCpyEstru[y][3]) .Or. Alltrim(x[4]) != Alltrim(aCpyEstru[y][4]) }) > 0
		lRet := .T.
	EndIf
EndIf

Return lRet

/*
Função     : DelOldTitF
Objetivo   : Verificar existência despesa de mesmo código inclusa manualmente e estornar o título financeiro a pagar desta despesa.
Retorno    : Lógico: .T. se encontrar o título e estornar com sucesso ou após usuário optar por prosseguir com a geração de um novo;
                     título caso o anterior não seja localizado ou estornado.
Autor      : NCF - 19/01/2021
Data/Hora  : 19/01/2021
*/
Static Function DelOldTitF()
Local lRet := .T.
Local aOrd := SaveOrd({"SWD","SE2"})

If !Empty(SWD->WD_CTRFIN1)
   SE2->(DBSETORDER(1))
   If (lRet := SE2->(DBSEEK(xFilial("SE2")+SWD->WD_PREFIXO+SWD->WD_CTRFIN1+SWD->WD_PARCELA+SWD->WD_TIPO+SWD->WD_FORN+SWD->WD_LOJA)) )
      INCLUI := ALTERA := .F.
      If !( lRet :=  FI400TITFIN("SWD_INT","4") )
         MsgInfo("Não foi possível estornar o título a pagar anterior desta despesa no módulo financeiro!")
      Else
         lLockedSWD := SWD->(IsLocked())
         If( !lLockedSWD, SWD->(RecLock("SWD",.F.)) ,  )          
         SWD->WD_CTRFIN1 := ""
         SWD->WD_DOCTO   := ""
         If( !lLockedSWD, SWD->(MsUnlock()) , )
      EndIf
   Else
      MsgInfo("Não foi possível localizar o título a pagar anterior desta despesa no módulo financeiro para realização do estorno!")
   EndIf
EndIf

RestOrd(aOrd,.T.)

Return lRet
