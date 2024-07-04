#INCLUDE "Eiclo100.ch"
#include "Average.ch"
#INCLUDE "AvPrint.ch"

#COMMAND E_RESET_AREA => Work1->(E_EraseArq(cNomArq,WorkNTX, cNomArq2))   ;
                       ; DBSELECTAREA(nOldArea) ; SWB->(DBSETORDER(1))   ;
                       ; SW9->(DBSETORDER(1))   ; EEQ->(DBSETORDER(1))

#define EV_EMBARQUE  "600"
#define TIPO_MODULO  "IMPORT"
#define EV_LIQ_PRC   "630"
#define EV_ESTORNO   "999"
#define MAX_COUNT    2000

//Funcao    : EICLO100
//Autor     : AVERAGE/ALEX WALLAUER
//Data      : 02/06/1998
//Descricao : Manutencao Perfeita de FFCs
//Sintaxe   : EICLO100()
// Uso      : SIGAEIC
//
//GCC - 28/08/2013
//Atualização:Tratamento para trazer os valores de pagamento antecipado vinculado a PO quanto a Fornecedor
//
//JWJ - 04/01/2007
//Atualização: Movi o código que carregava os arrays aPedido, aNCM e aMaterial para dentro do botão de impressão para otimizar o processamento da rotina
/*Revisão: WFS - mar/2016
           - consulta específica - multi-filial (tela)
           - alteração do número do lote - tela
           - baixa e estorno de títulos - multi-filial
           - botões/ sobreposição - identidade visual
*/
*------------------*
Function EICLO100()
*------------------*
LOCAL nOldArea:=SELECT()//, TB_Campos:={}
LOCAL iFil:=1, nInd, bOK
Local lIsAllMark := .F.
PRIVATE cMarca:=GetMark(), lInverte:=.F., aHeader[0],cNomArq,TB_Campos:={}
PRIVATE lVariosImport:=GETNEWPAR("MV_CAMBIMP",.F.)//Lotes com mais de um Importador
PRIVATE nTamFLAG := AVSX3("W2_OK",3)
Private cNrFFC := ""
Private oParcSel, nParcSel := 0 //LAM - 09/10/06
Private nQtdParSel := 0 //THTS - 24/01/2018 - Guarda a quantidade de parcelas selecionadas
Private bBlock //TRP-30/01/09
Private aButtons := {}
lCposAntecip:=.T. /*EasyGParam("MV_PG_ANT",,.F.) */ // NCF - 15/05/2020 - Parametro descontinuado

Private lEICFFCEAI := AvFlags("EIC_FFC_EAI")

//**IGOR CHIBA 29/09/09 verificando se integra dados parar ERP financeiro
Private LCAMBIO_EIC:= AVFLAGS('AVINT_CAMBIO_EIC')

IF LCAMBIO_EIC

   Private  cEICFI05 := EasyGParam('MV_EICFI05',,'') //define codigo da integração de CAMBIO
   Private lEICFI05  := .F.

   E00->(DBSETORDER(1))
   IF E00->(DBSEEK(XFILIAL('E00')+AVKEY(cEICFI05,'E00_COD') ))  .AND. E00->E00_SITUAC='1'//esta ativo  CAMBIO
      lEICFI05:=.T.
   ENDIF

   Private lIntegStat  := EasyGParam("MV_EICFI21",,.F.)  // PLB 15/04/10 - Status de Retorno do ERP

ENDIF
//**
//** GFC - 01/12/05 - Filtro por tipo de contrato
Private lWB_TP_CON := SWB->(FieldPos("WB_TP_CON")) > 0 .AND. SWB->(FieldPos("WB_TIPOCOM")) > 0 .AND.;
                      SWB->( FieldPos("WB_TIPOC") ) > 0   //TRP 20/11/2007
//**


//TRP - 08/11/2011 - Declaração de variável utilizada no EICFI400.PRW
Private lWB_EVENT := SWB->(FieldPos("WB_EVENT")) > 0 .and. SWB->(FieldPos("WB_TIPOC")) > 0

//** HVR - 14/03/2006 - Nova estrutura das tabelas de financiamento - EF1_TPMODU e EF1_SEQCNT.
Private lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                     EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                     EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                     EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                     EF6->( FieldPos("EF6_SEQCNT") ) > 0
                     


Private lEIC_EFF  := EasyGParam("MV_EIC_EFF",,.F.)
//** HVR
//Tabela de cadastro de Financiamentos.
Private lCadFin := ChkFile("EF7") .AND. ChkFile("EF8") .AND. ChkFile("EF9")
Private cFiltroF3ROF := "I"  // PLB 27/03/07 - Variavel utilizada do F3 do ROF da Invoice
//HVR 14/03/06 - Usuario pode Ver outras  Filiais
Private lMultiFil
Private cxFil := cFilAnt
If lEIC_EFF
   Private lIsContab := .F.  // PLB 13/06/07 - Identifica se o Contrato de Financiamento foi Contabilizado
EndIf

SX3->(DbSetOrder(2))
lMultiFil  := VerSenha(115) .and. Posicione("SX2",1,"EF1","X2_MODO") == "C" .and.;
              Posicione("SX2",1,"SWB","X2_MODO") == "E" .AND. SX3->(DbSeek("EF3_FILORI"))
SX3->(DbSetOrder(1))
//HVR***

//DRL 21/08/08 - CAMPO CONTA
Private lWB_CONTA := SWB->(FieldPos("WB_CONTA")) # 0

//AAF 10/05/2006 - F3 para FFC em Multifiliais.
lF3MFil := SXB->( dbSeek("FFCIMP") )

If AvFlags("EIC_EAI") .And. !lEICFFCEAI //THTS - 23/01/2018 - Verifica se esta apto a executar FFC para ambientes EAI
   MsgAlert(STR0143, STR0142)//"Funcionalidade não disponível para este cenário de negócio."####"Aviso"
   Return
EndIf

//HVR - 14/03/2006 - Inicio - Escolher as filiais
Private cFil   := ""
IF lMultiFil
   aFiliais  := AvgSelectFil(lMultiFil,"SWB")
ELSE
   aFiliais  := {xFilial("SWB")}
End IF
//HVR 17/04/2006 - VERIFICADO A AUSÊNCIA PARA EEQ
//HVR***

aCampos:={"WB_DT_VEN","WB_INVOICE","A2_COD","A2_NREDUZ","W9_MOE_FOB","W6_DI_NUM",;
          "WB_FOBMOE","W9_COND_PA","W9_DIAS_PA","W6_MAWB","W6_HAWB","W6_IMPORT",;
          "WB_CA_DT","WB_CA_TX","WB_CA_NUM", "YT_NOME_RE"} //OS640/01 FCD
AAdd(aCampos,"WB_LINHA"  )
AAdd(aCampos,"WB_LOJA"   )          //HVR WB_LOJA
If lEFFTpMod
   AAdd(aCampos,"WB_EVENT"  )          //HVR 17/03/2006 - Adicionado Evento no MsSelect
   AAdd(aCampos,"EEQ_NRINVO")          //HVR 19/04/2006 - CAMPO DA INVOICE PARA SWB OU EEQ
   AAdd(aCampos,"EEQ_PARC"  )
   AAdd(aCampos,"WB_PARFIN" )          //HVR 20/04/2006 - CAMPO PARFIN EEQ OU SWB
   AAdd(aCampos,"EEQ_PARFIN")
   AAdd(aCampos,"EEQ_VL"    )
EndIf

// AWR - 02/06/04
IF(SWB->(FIELDPOS("WB_PREFIXO")) # 0 , AADD(aCampos,"WB_PREFIXO"),)
IF(SWB->(FIELDPOS("WB_NUMDUP" )) # 0 , AADD(aCampos,"WB_NUMDUP") ,)
IF(SWB->(FIELDPOS("WB_PARCELA")) # 0 , AADD(aCampos,"WB_PARCELA"),)
IF(SWB->(FIELDPOS("WB_TIPOTIT")) # 0 , AADD(aCampos,"WB_TIPOTIT"),)
// AWR - 02/06/04
//IF(lCposAntecip,AADD(aCampos,"WB_PO_DI"),)
AAdd( aCampos, "WB_PO_DI" )  // PLB 25/09/06

//** GFC - 01/12/05 - Filtro por tipo de contrato (Mostrar no browse)
If lWB_TP_CON
   AADD(aCampos,"WB_TP_CON")
EndIf
//**

If lEICFFCEAI //THTS - 24/01/2018 - Manutencao de FFC via EAI
    aAdd(aCampos,"WB_SEQBX")
    aAdd(aCampos,"WB_SEQLOTE")
EndIf

aSemSX3:={{"WKREC_SWB","N",6,0},{"WKFLAG","C",nTamFLAG,0}}

AADD(aSemSX3,{"TRB_ALI_WT","C",03,0}) //TRP - 25/01/07 - Campos do WalkThru
AADD(aSemSX3,{"TRB_REC_WT","N",10,0})

If lEFFTpMod  //HVR 16/03/2005 - Filial e SWBEEQ
   AAdd( aSemSX3 , {"SWBEEQ"   , "C", 3                   , 0} )
EndIf
AAdd( aSemSX3 , {"WB_FILIAL", "C", AVSX3("WB_FILIAL",3), 0} )

SX3->(dbSetOrder(1))
SX3->(dbSeek("SWB"))
Do While SX3->(!EoF() .AND. X3_ARQUIVO == "SWB")

   If aScan(aCampos,{|X| AllTrim(X) == AllTrim(SX3->X3_CAMPO)}) == 0 .AND. aScan(aSemSX3,{|X| AllTrim(X[1]) == AllTrim(SX3->X3_CAMPO)}) == 0
      aAdd(aSemSX3,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
   EndIf

   SX3->(dbSkip())
EndDo

// ** JPM - 11/12/2009 - Nova Legislação Cambial
If EECFlags("CAMBIO_EXT")
   AAdd( aSemSX3 , {"WK_VINCEXP", "C", 1, 0} )
   AAdd( aSemSX3 , {"WK_VALBCO" , AvSx3("EYR_VALOR", AV_TIPO), AvSx3("EYR_VALOR", AV_TAMANHO), AvSx3("EYR_VALOR", AV_DECIMAL)} )
EndIf

IF EasyEntryPoint("EICLO100") //OS 0640/01 FCD
   ExecBlock("EICLO100",.F.,.F.,"CAMPO_1")
ENDIF

//TRP- 30/04/09 - Para evitar que a Work1 utilizada na rotina de Câmbio esteja em uso ainda no FFC.
If Select("Work1") > 0
   Work1->(dbCloseArea())
EndIf

AAdd( aSemSX3 , {"WKTPREG", "C", 30, 0} )
cNomArq:=E_CriaTrab(,aSemSX3,"Work1")

WorkNTX:=E_Create({},.F.)//APENAS GERA UM NOME PARA O INDICE 2
cNomArq2:=E_Create({},.F.)

IndRegua("Work1",cNomArq+TEOrdBagExt(),"DTOS(WB_DT_VEN)"+If(lEFFTpMod,"+EEQ_NRINVO","+WB_INVOICE"))
IndRegua("Work1",WorkNTX+TEOrdBagExt(),"A2_COD+W9_MOE_FOB"+IIF(lWB_Tp_Con,"+WB_TP_CON+WB_CA_NUM",""))
If lEFFTpMod
   IndRegua("Work1",cNomArq2+TEOrdBagExt(),"DTOS(WB_DT_VEN)+WB_INVOICE")//Cria o índice 3
EndIf

IF EasyEntryPoint("EICLO100") //OS 0640/01 FCD
   ExecBlock("EICLO100",.F.,.F.,"ORDEMLO")
ENDIF

If lEFFTpMod  //TRP-18/09/07
  SET INDEX TO (cNomArq+TEOrdBagExt()),(WorkNTX+TEOrdBagExt()),(cNomArq2+TEOrdBagExt())
Else
  SET INDEX TO (cNomArq+TEOrdBagExt()),(WorkNTX+TEOrdBagExt())
EndIf
IF EasyEntryPoint("EICLO100") //OS 0640/01 FCD
   ExecBlock("EICLO100",.F.,.F.,"SETORDLO")
ENDIF

PRIVATE TLote:=SPACE(LEN(SWB->WB_LOTE)), TImport:=SPACE(LEN(SYT->YT_COD_IMP))
PRIVATE TAno:=SUBSTR(PADL(YEAR(dDataBase),4),3,2), nTotFFC:=0, TemDI:=STR0001 //"Sim"
PRIVATE TForn:=SPACE(LEN(SA2->A2_COD)), TMoeda:=SPACE(LEN(SYF->YF_MOEDA))
PRIVATE DtIniVenc:=AVCTOD(''), DtFinVenc:=AVCTOD(''), cObs:='', TAgencia:=SWB->WB_AGENCIA
PRIVATE TBanco:=SWB->WB_BANCO
Private cTpCon:="2"
Private cCaNum:="" //AAF 19/06/2006
Private cEvent := Space(3) //HVR 16/03/06
Private cNrOp    := Space(AvSX3("WB_CA_NUM"  ,AV_TAMANHO)) //HVR 16/03/06
//HVR 16/03/06 - Tipo de Cambio
Private cTipo    := ""
Private aTipos   := {}//COMBOX3BOX("WB_TIPOC") //ComboX3Box("WB_TIPOC", X3Cbox())
//HVR***
Private cLoja:= ""

IF EICLOJA()
   cLoja:= SPACE(LEN(SA2->A2_LOJA))
ENDIF

// HVR 09/03/2006 - Adicionado o campo cNrOpSq para identificar a sequencia do contrato (Validando se o campo existe)
If lEFFTpMod
	cNrOpSq := Space(AvSX3("EF1_SEQCNT"  ,AV_TAMANHO))
	aTipos  := COMBOX3BOX("WB_TIPOC")
EndIf
//HVR***

PRIVATE cCadastro:=STR0002, lGet:=.F., oMemo, oImp //"Manutencao de Lote"

PRIVATE cImpDesc:="",cForDesc:="",cMoeDesc:="",cBanDesc:=""

PRIVATE cPicImp   :=ALLTRIM(X3Picture("W2_IMPORT"))
PRIVATE cPicLot   :=ALLTRIM(X3Picture("WB_LOTE"))
PRIVATE cPicFor   :=ALLTRIM(X3Picture("A2_COD"))
PRIVATE cPicVlCor :=ALLTRIM(X3Picture("WB_VL_CORR"))
PRIVATE cPicDespe :=ALLTRIM(X3Picture("WB_DESPESA"))
PRIVATE cPicFobMoe:=ALLTRIM(X3Picture("WB_FOBMOE"))
PRIVATE cPicRetido:=ALLTRIM(X3Picture("WB_RETIDO"))
Private cPicCaNum :=ALLTRIM(X3Picture("WB_CA_NUM"))
PRIVATE cPicComag :=If(lWB_TP_CON, Alltrim(X3Picture("WB_FOBMOE")), ALLTRIM(X3Picture("WB_COMAG"))) //** GFC - 01/12/05 - Utilizar o Valor da parcela de comissão ao invés do campo WB_COMAG
PRIVATE cPictCa_Tx:=ALLTRIM(X3Picture("WB_CA_TX")),lGetImp:=.T.
PRIVATE oPanel1 //LRL 22/04/04

//*** RMD - 23/11/07 - Nova legislação de câmbio
Private nAD101_VLTO := 0, nAD101_VLPC := 0
//***

AADD(TB_Campos,{"WKFLAG"    ,"", "  "})
AADD(TB_Campos,{"WB_FILIAL" ,"", STR0133}) //"Filial" //HVR 16/03/2006
AADD(TB_Campos,{"WB_DT_VEN" ,"", STR0003}) //"Vecto"
AADD(TB_Campos,{"WKTPREG"   ,"", STR0145}) //"Tipo Reg"
If lEFFTpMod
   //AADD(TB_Campos,{"SWBEEQ"    ,"", STR0137}) //"FLAG SWB EEQ" //HVR
   AADD(TB_Campos,{"WB_EVENT"  ,"", STR0134}) //"Evento" //HVR 16/03/2006
   AADD(TB_Campos,{{|| IF(WORK1->SWBEEQ == "SWB", WORK1->WB_INVOICE, WORK1->EEQ_NRINVO)},"", STR0004}) //"Invoices" //HVR 19/04/2006 - CAMPO DA INVOICE PARA SWB OU EEQ
   AADD(TB_Campos,{{|| IF(WORK1->SWBEEQ == "SWB", WORK1->WB_LINHA, WORK1->EEQ_PARC)},"", STR0140}) //"LINHA" //HVR 19/04/2006 - CAMPO DA INVOICE PARA SWB OU EEQ
Else
   AADD(TB_Campos,{{|| WORK1->WB_INVOICE },"", STR0004}) //"Invoices" //JWJ 06/10/2006
   AADD(TB_Campos,{"WB_LINHA" ,"", STR0140}) //"Loja For" //HVR
EndIf
AADD(TB_Campos,{"WB_LOJA"   ,"", STR0136}) //"Loja For" //HVR
AADD(TB_Campos,{"W6_HAWB"   ,"", STR0005}) //"No. Processo"
AADD(TB_Campos,{"A2_COD"    ,"", STR0006}) //"Cod For"
AADD(TB_Campos,{"WB_LOJA"   ,"", STR0136}) //"Loja For" //HVR
AADD(TB_Campos,{"A2_NREDUZ" ,"", STR0007}) //"Fornecedor"
IF lVariosImport
   AADD(TB_Campos,{{||Work1->W6_IMPORT+" - "+Work1->YT_NOME_RE} ,"",AVSX3("W2_IMPORT",5)})
ENDIF
AADD(TB_Campos,{"W9_MOE_FOB","",STR0008,}) //"Moeda"
AADD(TB_Campos,{"WB_FOBMOE" ,"",STR0009,cPicFobMoe}) //"Valor"
AADD(TB_Campos,{"W9_COND_PA","",STR0010}) //"Cond Pag"
AADD(TB_Campos,{"W9_DIAS_PA","",STR0011}) //"Dias"
AADD(TB_Campos,{"W6_DI_NUM" ,"",STR0012}) //"D. I."
AADD(TB_Campos,{"WB_CA_NUM" ,"",STR0139}) //"Numero da Operação"
AADD(TB_Campos,{"W6_MAWB"   ,"",STR0013}) //"Num. AWB"
// AWR - 02/06/04
IF Work1->(FIELDPOS("WB_PREFIXO")) # 0
   AADD(TB_Campos,{"WB_PREFIXO",,AVSX3("WB_PREFIXO",5),AVSX3("WB_PREFIXO",6)} )
ENDIF
IF Work1->(FIELDPOS("WB_NUMDUP")) # 0
   AADD(TB_Campos,{"WB_NUMDUP" ,,AVSX3("WB_NUMDUP" ,5),AVSX3("WB_NUMDUP" ,6)} )
ENDIF
IF Work1->(FIELDPOS("WB_PARCELA")) # 0
   AADD(TB_Campos,{"WB_PARCELA",,AVSX3("WB_PARCELA",5),AVSX3("WB_PARCELA",6)} )
ENDIF
IF Work1->(FIELDPOS("WB_TIPOTIT")) # 0
   AADD(TB_Campos,{"WB_TIPOTIT",,AVSX3("WB_TIPOTIT",5),AVSX3("WB_TIPOTIT",6)} )
ENDIF
//** GFC - 01/12/05 - Filtro por tipo de contrato (Mostrar no browse)
If lWB_TP_CON
   AADD(TB_Campos,{{|| BscXBox("WB_TP_CON",Work1->WB_TP_CON)} ,"",AVSX3("WB_TP_CON",5)})
EndIf
//**igor chiba 29/09/09 incluindo campos de titulo ERP
IF LCAMBIO_EIC
   AADD(TB_Campos,{"WB_TITERP"  ,"",'Título.ERP'  })
   AADD(TB_Campos,{"WB_TITERPV" ,"",'Tít.ERP Vinc'})
   AADD(TB_Campos,{"WB_TITRET"  ,'','Título ERP Ret.' })    // PLB 15/04/10 - Status de Retorno do ERP
ENDIF

If lEICFFCEAI //THTS - 24/01/2018 - Manutencao de FFC via EAI
    AADD(TB_Campos,{"WB_SEQBX"    ,"",AVSX3("WB_SEQBX"  ,5)})
    AADD(TB_Campos,{"WB_SEQLOTE"  ,"",AVSX3("WB_SEQLOTE",5)})
EndIf

//**
//**
// AWR - 02/06/04
nLif:= 30  //OS 0640/01 FCD
//** GFC - 01/12/05 - Filtro por tipo de contrato
IF EasyEntryPoint("EICLO100") //OS 0640/01 FCD
   ExecBlock("EICLO100",.F.,.F.,"DIALOG01")
ENDIF

//ER - 04/05/2007
bSetKey:=SetKey(VK_F12)
SX1->(DBSETORDER(1))
IF GetNewPar("MV_EASYFIN","N") = "S" .AND. SX1->(DBSEEK("EICTMB"))
   Pergunte("EICTMB",.F.)
   SetKey(VK_F12,{|| Pergunte("EICTMB",.T.) })
ENDIF

WHILE .T.
  If aFiliais[1]=="WND_CLOSE"
     Exit
  EndIf
  TLote:=SPACE(LEN(SWB->WB_LOTE))
  DEFINE MSDIALOG oDlg TITLE cCadastro From 7,0 To nLif,80 OF oMainWnd

  oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 95, 165) //MCF - 21/07/2015
  oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

  nLin :=10
  nOpca:=0
  l1Vez:=.T.

  //TRP-19/03/08- Inclusão do 3º parâmetro para definir o objeto da tela.
  LO100Say(nLin,.T., oPanel)
  LO100Get(nLin,.T., oPanel)

  ACTIVATE MSDIALOG oDlg ON INIT ;
           EnchoiceBar(oDlg,{||IF(LO100Val('Import') .And. IIF(lWB_TP_CON,LO100Val('TpCon'),.T.),(nOpca:=1,oDlg:End()),)},;
                            {||nOpca:=0,oDlg:End()}) CENTERED

  IF nOpca = 0
     E_RESET_AREA
     Return .F.
  ENDIF

  IF !EMPTY(ALLTRIM(TLote))
     lLoteBran:=.F.
     l1Vez    :=.F.
     cSayBotao:=STR0014 //"&Grava FFC"
     IF !LO100Val('AFC1')
        LOOP
     ENDIF
  ELSE
     cSayBotao:=STR0015 //"&Gera FFC's"
     lLoteBran:=.T.
  ENDIF

  cFilSWB:=xFilial("SWB")
  nCont  :=0
  nContEEQ  :=0 //EEQ
  bFor   :={|| .T. }

  IF lCposAntecip
     bFor:={|| LO100For() }
  ENDIF

// ** JPM - 17/12/2009 - zerar variáveis e setar índices fora do FOR de filiais, que foi acrescentado posteriormente
  nTotFFC:=0
  aPedido:={}
  aMaterial:={}
  aNcm:={}
  SW9->(DBSETORDER(1))
  nCont := 0
  If lEFFTpMod
     nTotFFCEEQ:=0
     aPedidoEEQ:={}
     aMaterialEEQ:={}
     aNcmEEQ:={}
     EEC->(DBSETORDER(1))
     EEQ->(DBSETORDER(10))
     nContEEQ := 0
  EndIf

//HVR 22/03/2006 - Conceito Multi Filial
  FOR iFil=1 TO LEN(aFiliais) //for de todas as filiais do selecionadas
     cFilSWB := aFiliais[iFil]
     If lEFFTpMod
        cFilEEQ := If(Posicione("SX2",1,"EEQ","X2_MODO") == "E",aFiliais[iFil],xFilial("EEQ"))    //eeq
     EndIf
     IF lLoteBran //Se lote em branco

        SWB->(DBSETORDER(4))
        SWB->(DBSEEK(cFilSWB,.T.)) //HVR xFilial("SWB") por cFilSWB
        bWhile:={||SWB->WB_FILIAL==cFilSWB .AND. EMPTY(SWB->WB_LOTE) .AND. EMPTY(SWB->WB_CA_DT)}

        If lEFFTpMod
           EEQ->(DBSETORDER(4)) //eeq
           EEQ->(DBSEEK(cFilEEQ,.T.)) //HVR xFilial("SWB") por cFilSWB //eeq
           bWhileEEQ:={||EEQ->EEQ_FILIAL==cFilEEQ  .AND. EEQ->EEQ_FFCIMP==TLote .AND. EMPTY(EEQ->EEQ_PGT)} //EEQ
        EndIf

        IF EasyEntryPoint("EICLO100") //OS 0640/01 FCD
           ExecBlock("EICLO100",.F.,.F.,"BWHILE_1A")
        ENDIF

   	 IF EasyEntryPoint("EICLO100") //OS 0640/01 FCD
           ExecBlock("EICLO100",.F.,.F.,"BWHILE_1B")
        ENDIF
     ELSE

        SWB->(DBSETORDER(4))
        SWB->(DBSEEK(cFilSWB+TLote)) //HVR xFilial("SWB") por cFilSWB
        If lEFFTpMod
           EEQ->(DBSETORDER(10)) //EEQ
           EEQ->(DBSEEK(cFilEEQ+TLote)) //EEQ    //HVR 11/04/06
        EndIf

        IF EMPTY(SWB->WB_CA_DT)
           bWhile:={||SWB->WB_FILIAL==cFilSWB .AND. SWB->WB_LOTE==TLote .AND. EMPTY(SWB->WB_CA_DT)}
   	       IF EasyEntryPoint("EICLO100") //OS 0640/01 FCD
              ExecBlock("EICLO100",.F.,.F.,"BWHILE_2")
           ENDIF
        ELSE
           bWhile:={||SWB->WB_FILIAL==cFilSWB .AND. SWB->WB_LOTE==TLote}
           IF EasyEntryPoint("EICLO100") //OS 0640/01 FCD
              ExecBlock("EICLO100",.F.,.F.,"BWHILE_3")
           ENDIF
        ENDIF

        If lEFFTpMod
           IF EMPTY(EEQ->EEQ_PGT) //EEQ
              bWhileEEQ:={||EEQ->EEQ_FILIAL==cFilEEQ .AND. EEQ->EEQ_FFCIMP==TLote .AND. EMPTY(EEQ->EEQ_PGT)} //EEQ
      	       IF EasyEntryPoint("EICLO100") //EEQ
                 ExecBlock("EICLO100",.F.,.F.,"BWHILE_2") //EEQ
              ENDIF//EEQ
           ELSE//EEQ
              bWhileEEQ:={||EEQ->EEQ_FILIAL==cFilEEQ .AND. EEQ->EEQ_FFCIMP==TLote} //EEQ
              IF EasyEntryPoint("EICLO100") //EEQ
                 ExecBlock("EICLO100",.F.,.F.,"BWHILE_3")//EEQ
              ENDIF//EEQ
           ENDIF//EEQ
        EndIf


     ENDIF

     Processa({|lEnd|ProcRegua(MAX_COUNT),;
       SWB->(DBEVAL({|| LO100Wk1Grv(TForn,TMoeda,TLote,TImport,cFilSWB,IF(EICLOJA(),cLoja,"")), },bFor,bWhile))},;
       STR0016) //"Pesquisando Informa‡äes..."

// ** JPM - 17/12/2009 - Setar total das parcelas fora do FOR de filiais, que foi acrescentado posteriormente
//     nParcSel := nTotFFC //LAM - 09/10/06

     If lEFFTpMod
        Processa({|lEnd|ProcRegua(MAX_COUNT),;
          EEQ->(DBEVAL({|| LO100EEQGrv(TForn,TMoeda,TLote,TImport,cFilEEQ,IF(EICLOJA(),cLoja,"")), },/*bFor*/,bWhileEEQ))},;
          STR0016) //"Pesquisando Informa‡äes..."
     EndIf
  NEXT
//HVR*** Fim do for das filiais

  nParcSel := nTotFFC
  nQtdParSel := 0
  DBSELECTAREA("Work1")

  IF Work1->(Easyreccount("Work1")) > 0
     nLinAux:=nLin
     DO WHILE .T.

         nLin:=nLinAux
         oMainWnd:ReadClientCoors()
         DEFINE MSDIALOG oDlg TITLE cCadastro ;
             FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
        	     OF oMainWnd PIXEL
             @ 00,00 MsPanel oPanel1 Prompt "" Size 60,70+46 of oDlg //LRL 22/04/04
             lGerouFFC:=lGet:=.F.
             nOpca    :=1
             nLin :=6  //TRP-19/03/08

             //TRP-19/03/08- Inclusão do 3º parâmetro para definir o objeto da tela.
             LO100Say(nLin,.F., oPanel1)
             LO100Get(nLin,.F., oPanel1)

             Work1->(DBGOTOP())
             If lEFFTpMod .And. cTpCon == "2"
                Work1->(DbSetOrder(3))
             EndIf

             oMark:= MsSelect():New("Work1","WKFLAG",,TB_Campos,@lInverte,@cMarca,{81,1,(oDlg:nClientHeight-2)/2,(oDlg:nClientWidth-2)/2})
             oMark:bAval := {|| DoubleClik()}

   	       IF EasyEntryPoint("EICLO100") //OS 0640/01 FCD
                ExecBlock("EICLO100",.F.,.F.,"BMARCA")
             ENDIF

             #define COLBUTTONS1 235 // 241
             #define COLBUTTONS2 275 // 281
  //54

             /* Identidade visual */
            aButtons:= {}
            If lLoteBran
              aAdd(aButtons, {"LBTIK", {|| MarcaTodos(oMark) }, "Marca/ Desmarca Todos", "Marca/ Desmarca Todos"})
              AAdd(aButtons, {"LBTIK", {|| If(EMPTY(Work1->WB_CA_DT),LO100AllMark(oMark),MsgInfo("FFC liquidado. Estorne a liquidação.")) }, STR0017 + "...", STR0017 + "..."}) //"Todos"
            EndIf

             //@ 55,COLBUTTONS1 BUTTON cSayBotao SIZE 34,11 ACTION (If(EMPTY(Work1->WB_CA_DT),(nOpca:=2,oDlg:End()),MsgInfo("FFC liquidado. Estorne a liquidação."))) OF oPanel1 PIXEL
             AAdd(aButtons, {"LBTIK", {|| If(EMPTY(Work1->WB_CA_DT),(nOpca:=2,oDlg:End()),MsgInfo("FFC liquidado. Estorne a liquidação.")) }, cSayBotao , cSayBotao})
             bOk:= {||If(EMPTY(Work1->WB_CA_DT),(nOpca:=2,oDlg:End()),MsgInfo("FFC liquidado. Estorne a liquidação."))}

            IF EasyEntryPoint("EICLO100") //OS 0640/01 FCD  12/11/01
              ExecBlock("EICLO100",.F.,.F.,"TELAFFC1")
            ENDIF

             //DEFINE SBUTTON FROM 42,235 /*286*/ TYPE 6 ACTION (nOpca:=5,oDlg:End()) ENABLE OF oPanel1
            AAdd(aButtons, {"LBTIK", {|| nOpca:=5,oDlg:End() }, "Imprimir", "Imprimir"})

            IF !lLoteBran //Se lote nao em branco
              
              If !lIsAllMark //THTS - 01/02/2018 - Quando preenchido o lote, marca todos os itens e nao executa mais a rotina para nao desmarcar os itens
                MarcaTodos(oMark)
                lIsAllMark := .T.
              EndIf

              IF SWB->(MFilSeek(TLote)) .OR. (lEFFTpMod .And. EEQ->(DBSETORDER(10), MFilSeek(TLote)))

                //@ 54,COLBUTTONS2 BUTTON STR0018 SIZE 34,11 ACTION (nOpca:=3,oDlg:End()) OF oDlg PIXEL WHEN ((!SWB->( EoF() ) .AND. EMPTY(SWB->WB_CA_DT)) .OR. (!EEQ->( EoF() ) .AND. EMPTY(EEQ->EEQ_PGT))) //"&Fechamento"
                If ((!SWB->( EoF() ) .AND. EMPTY(SWB->WB_CA_DT)) .OR. (!EEQ->( EoF() ) .AND. EMPTY(EEQ->EEQ_PGT)))
                  AAdd(aButtons, {"LBTIK", {|| nOpca:=3,oDlg:End() }, STR0018, STR0018}) //"&Fechamento"
                EndIf

                   //JVR - 29/05/09 - Alteração do nome do botão em caso de FFC fechada ou não.
                If(!EMPTY(SWB->WB_CA_DT) .OR. !EMPTY(EEQ->EEQ_PGT),cBotao:=STR0019,cBotao:=STR0031)//"&Estorno" // "&Excluir"

                  //@ 67,COLBUTTONS2 BUTTON cBotao SIZE 34,11 ACTION (nOpca:=4,oDlg:End()) OF oDlg PIXEL
                  AAdd(aButtons, {"LBTIK", {|| nOpca:=4,oDlg:End()}, cBotao, cBotao})
                ENDIF
            ENDIF

            bStart := {|| LO100Val("Import",.T.,oDlg),;
                          LO100Val("Fornec",.T.,oDlg),;
                          LO100Val("Moeda",.T.,oDlg),;
                          LO100Val("Banco",.T.,oDlg) }
        //ISS - 27/10/10 - Inclusão do array com botões adicionais, neste caso contendo o botão "Marca/Desmarca Todos"

		oPanel1:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
		oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
		oMark:oBrowse:Refresh() //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

        ACTIVATE MSDIALOG oDlg ON INIT ;
                 (EnchoiceBar(oDlg, bOk,; //{||nOpca:=1,oDlg:End()}
                                   {||nOpca:=0,oDlg:End()},,;
                                   aButtons),;
                                   Eval(bStart)) //LRL 22/04/04 - Alinhamento MDI //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

        SetKey(VK_F12,bSetKey)
        IF EasyEntryPoint("EICPFFC1")
           If !(ExecBlock("EICPFFC1",.F.,.F.,"ATUALIZA"))
              Loop
           EndIf
        EndIf

        IF EasyEntryPoint("EICLO100")
           ExecBlock("EICLO100",.F.,.F.,"ATUALIZA")
        ENDIF

        IF nOpca = 2
           LO100FFCs()
           IF !lGerouFFC
              LOOP
           ENDIF
           nOpca:=1
        ENDIF

        IF nOpca = 3
           IF LO100Baixa(.T.,TLote,lLoteBran)  //MJB-SAP-1100
              nOpca:=1
           ELSE
              LOOP
           ENDIF
        ENDIF

        IF nOpca = 4
           IF LO100Baixa(.F.,TLote,lLoteBran)  //MJB-SAP-1100
              nOpca:=1
           ELSE
              LOOP
           ENDIF
        ENDIF

        IF nOpca = 5
           LO100Ret(TLote)
           LOOP
        ENDIF

        IF EasyEntryPoint("EICPFFC1")
           ExecBlock("EICPFFC1",.F.,.F.,"FECHA")
        EndIf

        IF EasyEntryPoint("EICLO100")
           ExecBlock("EICLO100",.F.,.F.,"FECHA")
        ENDIF

        Work1->(avzap())
        lIsAllMark := .F.
        If nOpca = 0
           E_RESET_AREA
           Return .F.
        Endif
        EXIT
     ENDDO
  ELSE
     Help("", 1, "AVG0003014")//"NÆo h  Registros com essas informa‡äes"###"Informação"
  ENDIF
ENDDO
RETURN NIL
*----------------------------------------------------------------------------
FUNCTION LO100For()
*----------------------------------------------------------------------------
IF SWB->WB_PO_DI == 'D'
   IF Left(SWB->WB_TIPOREG,1) == 'P' .OR. EMPTY(SWB->WB_FOBMOE)
      RETURN .F.
   ENDIF
ENDIF

RETURN .T.
*----------------------------------------------------------------------------
FUNCTION LO100Say(nLin,lTela1, oObjPai)
*----------------------------------------------------------------------------
LOCAL nColS1:=8 , nColS2:=148

@ nLin  ,nColS1 SAY STR0022 OF oObjPai  PIXEL //"N§ FFC"
@ nLin  ,nColS2+2 SAY STR0023 OF oObjPai Pixel FONT oDlg:oFont COLOR CLR_HBLUE
nLin+=13
@ nLin  ,nColS1 SAY STR0007 OF oObjPai PIXEL //"Fornecedor"
@ nLin  ,nColS2+13 SAY STR0024 OF oObjPai PIXEL //"       Moeda"
nLin+=13
@ nLin  ,nColS1 SAY STR0025 OF oObjPai PIXEL //"DI"
@ nLin  ,nColS2 SAY STR0026 OF oObjPai PIXEL //"Dt Vencto Inicial"
nLin+=18
@ nLin  ,nColS1 SAY STR0027 OF oObjPai PIXEL //"Banco"
@ nLin  ,nColS2+2 SAY STR0028 OF oObjPai PIXEL //"Dt Vencto Final"
nLin+=13
//** GFC - 01/12/05 - Filtro por tipo de contrato
If lWB_TP_CON
   @ nLin  ,nColS1 SAY AVSX3("WB_TP_CON",5) OF oObjPai Pixel FONT oDlg:oFont COLOR CLR_HBLUE // "Tipo Contra."
EndIf
//**

If lEFFTpMod   //HVR 16/03/2006 - Código do Evento.
   @ nLin, nColS2 Say "Evento" OF oObjPai Pixel //FONT oDlg:oFont COLOR CLR_HBLUE -Não será mais obrigatório
EndIf

nLin+=18
@ nLin, nColS1 Say AVSX3("WB_CA_NUM",AV_TITULO) OF oObjPai Pixel
If lEFFTpMod      // HVR 16/03/2006 - Adicionado o campo cNrOpSq para identificar a sequencia do contrato - verifica se este campo já existe
   @ nLin,nColS2 Say AVSX3("EF1_SEQCNT",AV_TITULO) OF oObjPai Pixel
EndIf

nLin+=14

If lWB_TP_CON
   @ nLin, nColS1 Say AvSX3("WB_TIPOC", AV_TITULO) OF oObjPai Pixel   //TRP 20/11/2007 - Tipo de Cambio.
EndIf

//LAM - 09/10/06 - Valor Total das Parcelas Selecionadas
If !lTela1
   @ nLin  ,nColS2 SAY "Tot. de Parcelas" OF oObjPai Pixel  // "Tipo Contra." //HVR 22/03/2006 //17/04/2006
EndIf


IF lTela1
   nLin+=13
   @ nLin,nColS1 SAY STR0029 OF oObjPai PIXEL //"Observa‡Æo"
ENDIF

IF EasyEntryPoint("EICLO100") //OS 0640/01 FCD
   ExecBlock("EICLO100",.F.,.F.,"DIALOSAY")
ENDIF
RETURN NIL
*----------------------------------------------------------------------------
FUNCTION LO100Get(nLin,lTela1, oObjPai)
*----------------------------------------------------------------------------
LOCAL nColG1:=40 , nColG2:=192, aTpCon:={}

If lWB_TP_CON
   aTpCon := COMBOX3BOX("WB_TP_CON")
   aAdd(aTpCon,"")
EndIf

@ nLin, nColG1    MSGET TLote F3 if(lMultiFil .AND. lF3MFil,"FFCIMP","FFC") PICTURE cPicLot WHEN lTela1;
                        VALID LO100Val('AFC1',.F.,oDlg) SIZE 30,8 OF oObjPai PIXEL
@ nLin, nColG2    MSGET oImp VAR TImport F3 "SYT" PICTURE cPicImp WHEN lGet;
                        VALID LO100Val('Import',.F.,oDlg) SIZE 10,8 OF oObjPai PIXEL
@ nLin, nColG2+25 MSGET cImpDesc PICTURE "@!" WHEN .F. SIZE 90,8 OF oObjPai PIXEL

nLin+=13
@ nLin, nColG1    MSGET TForn F3 "SA2A" PICTURE cPicFor WHEN lGet;
                        VALID LO100Val('Fornec',.F.,oDlg) SIZE 30,8 OF oObjPai PIXEL
IF EICLOJA()
   @ nLin, nColG1+35 MSGET cLoja PICTURE "@!" WHEN .T.;
                     VALID LO100Val('Loja',.F.,oDlg) SIZE 15,8 OF oObjPai PIXEL //FDR - 29/12/2011
ENDIF

@ nLin, nColG1+50 MSGET cForDesc PICTURE "@!" WHEN .F. SIZE 080,8 OF oObjPai PIXEL

@ nLin, nColG2+7    MSGET TMoeda F3 "SYF" PICTURE "@!" WHEN lGet ;
                        VALID LO100Val('Moeda',.F.,oDlg) SIZE 08,8 OF oObjPai PIXEL
@ nLin, nColG2+38 MSGET cMoeDesc PICTURE "@!" WHEN .F. SIZE 58,8 OF oObjPai PIXEL

nLin+=13
@ nLin, nColG1 COMBOBOX TemDI ITEMS {STR0001,STR0030}; //"Sim"###"NÆo"
                        WHEN lGet SIZE 40,30 OF oObjPai PIXEL

@ nLin, nColG2    MSGET DtIniVenc WHEN lGet ;
                        VALID LO100Val('DtFin') SIZE 32,8 OF oObjPai PIXEL

nLin+=18

@ nLin, nColG1    MSGET TBanco   WHEN .F.  SIZE 20,8 OF oObjPai PIXEL
@ nLin, nColG1+25 MSGET cBanDesc PICTURE "@!" WHEN .F. SIZE 70,8 OF oObjPai PIXEL
@ nLin, nColG2    MSGET DtFinVenc WHEN lGet;
                        VALID LO100Val('DtFin') SIZE 32,8 OF oObjPai PIXEL

nLin+=13

//** GFC - 01/12/05 - Filtro por tipo de contrato
If lWB_TP_CON
   @ nLin, nColG1 COMBOBOX cTpCon ITEMS aTpCon WHEN lGet;
                  /*VALID LO100Val('TpCon',.F.,oDlg)*/ SIZE 80,30 OF oObjPai PIXEL //HVR 22/03/2006 - Obrigatório Valid
EndIf
//**

If lEFFTpMod      // HVR 16/03/2006 - Adicionado o campo cNrOpSq para identificar a sequencia do contrato - verifica se este campo já existe
   //HVR 16/03/2006 - Código do Evento/Numero da Operacao/Sequencia
   @ nLin ,nColG2 MsGet cEvent Picture "@!" SIZE 040,08 F3("E21") OF oObjPai PIXEL//;
                        //When(Empty(cFFC) .And. lOkEVENT .And. EECFlags("FRESEGCOM")) Valid(Af300Val(17)) Pixel Of oDlg
EndIf
 // ISS - 29/03/10 - Alteração no tamanho das linhas "puladas" de um get para o outro
//nLin+=26
nLin+=18
@ nLin, nColG1 MsGet cNrOp  Picture AVSX3("WB_CA_NUM",AV_PICTURE) /*Valid(Vazio() .Or. AF300Val(15,cMoeda))*/ Size 040,08 Pixel Of oObjPai
//TRP 20/11/2007 - Seq. Contrato.
//nLin-=13
If lEFFTpMod
   @ nLin,nColG2 MsGet cNrOpSq  Picture AVSX3("EF1_SEQCNT",AV_PICTURE) Size 040,08 Pixel OF oObjPai
EndIf

nLin+=13

//TRP 20/11/2007 - Tipo de Cambio.
If lWB_TP_CON
   @ nLin, nColG1 ComboBox cTipo Items aTipos Size 80, 08 Pixel OF oObjPai
EndIf

//LAM - 09/10/06 - Valor Total das Parcelas Selecionadas
If !lTela1
   @ nLin,nColG2 MsGet oParcSel Var nParcSel Picture "@E 999,999,999.9999" WHEN .F. Size 060,08 Pixel OF oObjPai
EndIF


nLin+=13
IF lTela1
   LO100Val('AFC1',.F.,oDlg)
   @ nLin, nColG1 GET oMemo Var cObs MEMO SIZE 180,23 WHEN LO100FOC() OF oObjPai PIXEL
ENDIF
IF EasyEntryPoint("EICLO100") //OS 0640/01 FCD
   ExecBlock("EICLO100",.F.,.F.,"DIALOGET")
ENDIF
RETURN NIL

*------------------*
Function LO100FOC()
*------------------*
If Empty(TLote) .AND. lGetImp
   lGetImp:=.F.
   oImp:SetFocus()
   oDlg:Refresh()
EndIf
Return .T.

*----------------------------------------------------------------------------
FUNCTION LO100Val(MFlag,lDisplay,oDlg)
*----------------------------------------------------------------------------
LOCAL  cRno, cBco,cImport, I
Private lRetorno := .T.,cFlag :=MFlag,lDsplay:=lDisplay//Para rdmake - RHP
IF(lDisplay=Nil,lDisplay:=.F.,)

lExit:= .F.
IF EasyEntryPoint("EICLO100")
   ExecBlock("EICLO100",.F.,.F.,"ANTES_VALID")  //TRP-06/06/08-Inclusão de ponto de entrada
ENDIF

//TRP-06/06/08
IF lExit
   Return lRetorno
ENDIF
Do Case
   Case MFlag = 'AFC1'
        IF EMPTY(ALLTRIM(TLote))
           lGet:=.T.
           lGetImp:=.T.
           TBanco  :=SPACE(3)
           cObs    :=""
        ELSE
           SWB->(DBSETORDER(4))
           IIF(lEFFTpMod,EEQ->(DBSETORDER(10)),)
           If !SWB->(MFilSeek(TLote)) .AND. IIF(lEFFTpMod,!EEQ->(MFilSeek(TLote)),.T.) //HVR .AND. ->
              Help("", 1, "AVG0003015")//"N£mero de FFC nÆo cadastrado"###"Informação"
              Return .F.
           Endif

		   // GCC - 27/08/2013 - Tratamento para as novas modalidades de pagamentos antecipados
           If lCposAntecip .And. SWB->WB_PO_DI == 'A'
              SW2->(MFilSeek(Alltrim(SWB->WB_HAWB), SWB->WB_FILIAL))//Pedidos
              TForn := SW2->W2_FORN
              If EICLOJA()
                 cLoja := SW2->W2_FORLOJ
              EndIf
              TMoeda   :=SW2->W2_MOEDA
              If(lWB_TP_CON, cTpcon := SWB->WB_TP_CON, ) //HVR
              If (!SWB->(MFilSeek(TLote)), cImport := EEQ->EEQ_IMPORT, cImport := SW2->W2_IMPORT) //HVR .OR. ->

           ElseIf (SWB->WB_PO_DI == 'F' .Or. SWB->WB_PO_DI == 'C')
			  TForn  := SWB->WB_FORN
			  cLoja  := SWB->WB_LOJA
			  TMoeda := SWB->WB_MOEDA
			  cTpcon := SWB->WB_TP_CON
			  cImport:= ""

           Else
              SW6->(MFilSeek(SWB->WB_HAWB,SWB->WB_FILIAL))  //Declaracao
              SW7->(MFilSeek(SWB->WB_HAWB,SWB->WB_FILIAL))  //It_Declaracao
              SW2->(MFilSeek(SW7->W7_PO_NUM,SWB->WB_FILIAL))//Pedidos
              SW9->(MFilSeek(SWB->WB_INVOICE+SWB->WB_FORN+EICRetLoja("SWB","WB_LOJA"),SWB->WB_FILIAL))
              TForn    :=SW9->W9_FORN
              If EICLOJA()
                 cLoja := SW9->W9_FORLOJ
              EndIf
              TMoeda   :=SW9->W9_MOE_FOB
//              IF (!SWB->(DBSEEK(xFilial("SWB")+TLote)), cImport  :=EEQ->EEQ_IMPORT, cImport  :=SW6->W6_IMPORT) //HVR .OR. ->
              If !SWB->(MFilSeek(TLote))  //HVR ->
                 cImport  :=EEQ->EEQ_IMPORT
                 If(lWB_TP_CON, cTpcon   :=EEQ->EEQ_TP_CON,)
              Else
                 cImport  :=SW6->W6_IMPORT
                 If(lWB_TP_CON, cTpcon   :=SWB->WB_TP_CON,)
              EndIf //HVR***
           EndIf

		     If !lVariosImport
              TImport  :=cImport
           Else
              If (!SWB->(MFilSeek(TLote)), TImport:=SPACE(LEN(SYT->YT_COD_IMP)), cImport  :=EEQ->EEQ_IMPORT) //HVR .OR. ->
           EndIf

           TemDI    :=If(Empty(SW6->W6_DI_NUM),STR0030,STR0001) //"NÆo"###"Sim"
           TBanco   :=SWB->WB_BANCO
           TAgencia :=SWB->WB_AGENCIA
           DtIniVenc:=AVCTOD("")// Last Change by CAF - 10/5/1998
           DtFinVenc:=AVCTOD("")// Last Change by CAF - 10/5/1998

           lGet    := .F.
           lGetImp := .F.
           IF l1Vez
              cObs :=""
              For I:= 1 To MLCOUNT(MSMM(SWB->WB_OBS))
                  cOBS+=ALLTRIM(MSMM(SWB->WB_OBS,35,I))+CHR(13)+CHR(10)
              Next
           EndIf
        EndIf

        IF EasyEntryPoint("EICLO100") // FCD 16/01/02
           ExecBlock("EICLO100",.F.,.F.,"DIALOGE2")
        ENDIF

        IF oDlg != NIL
           LO100VAL("Import",.T.,oDlg)
           LO100VAL("Fornec",.T.,oDlg)
           LO100VAL("Moeda",.T.,oDlg)
           LO100VAL("Banco",.T.,oDlg)
        EndIf

        IF ValType('oMemo') == "M"
           oMemo:Refresh()
        EndIf

   Case MFlag = 'Import'
        SYT->(dbSeek(xFilial()+TImport))
        IF lDisplay
           if !lVariosImport .AND. SYT->(dbSeek(xFilial()+TImport))
              cImpDesc := LEFT(SYT->YT_NOME_RE,25)
		   ElseIf !Empty(Tlote)
			  cImpDesc :=SUBSTR(STR0017,2)
           Else
              cImpDesc:=" "
           endif
           RETURN .T.
        ENDIF

        IF !lVariosImport .AND. EMPTY(TImport)
           Help("", 1, "AVG0003016")//"C¢digo do Importador deve ser informado"###"Informação"
           RETURN .F.
        ELSEIF !EMPTY(TImport) .AND. ! SYT->(DBSEEK(xFilial("SYT")+TImport))
           Help("", 1, "AVG0003017")//"C¢digo do Importador nÆo cadastrado"###"Informação"
           RETURN .F.
        ENDIF
        cImpDesc := LEFT(SYT->YT_NOME_RE,25)

        IF !lVariosImport
           cImpDesc := LEFT(SYT->YT_NOME_RE,25)
        ELSEIF EMPTY(TImport)
           cImpDesc :=SUBSTR(STR0017,2)//TODOS
        ENDIF

   Case MFlag = 'Fornec'
        cForDesc := SPACE(15)
        IF lDisplay
          IF SA2->(dbSeek(xFilial("SA2")+TForn+IF(EICLOJA(),If(Empty(cLoja),"",cLoja),"")))
              cLoja := SA2->A2_LOJA //FDR - 29/12/2011
              cForDesc := LEFT(SA2->A2_NREDUZ,15)
           endif
          RETURN .T.
        ENDIF

        IF !EMPTY(TForn) .AND. !Empty(cLoja) .AND. !SA2->(DBSEEK(xFilial("SA2")+TForn+IF(EICLOJA(),cLoja,"")))
           Help("", 1, "AVG0003018")//"C¢digo do Fornecedor nÆo cadastrado"###"Informação"
           RETURN .F.
        ENDIF
        IF SA2->(dbSeek(xFilial("SA2")+TForn+IF(EICLOJA(),If(Empty(cLoja),"",cLoja),"")))
           cLoja := SA2->A2_LOJA //FDR - 29/12/2011
           cForDesc := LEFT(SA2->A2_NREDUZ,15)
        ENDIF
        IF EasyEntryPoint("EICLO100")
          IF !(ExecBlock("EICLO100",.F.,.F.,"LOVAL_FORN"))
            RETURN .F.
          ENDIF
        ENDIF

   //FDR - 29/12/2011
   Case MFlag = 'Loja'
        IF !Empty(cLoja) .AND. !SA2->(dbSeek(xFilial("SA2")+TForn+IF(EICLOJA(),If(Empty(cLoja),"",cLoja),"")))
           Help("", 1, "AVG0005380")
           RETURN .F.
        ENDIF

   Case MFlag = 'MINMAX'
        IF !EMPTY(M->YW_MINIMO) .AND. !EMPTY(M->YW_MAXIMO)
           IF M->YW_MINIMO > M->YW_MAXIMO
		      Help("", 1, "AVG0003019")//"Valor Máximo menor que Valor Mínimo"###"Informação"
		      Return .F.
		   ELSEIF EMPTY(M->YW_MINIMO) .OR. EMPTY(M->YW_MAXIMO)
		      Return .T.
		   ENDIF
	    ENDIF

   Case MFlag = 'CORR'
        IF !EMPTY(M->WB_CORRETO)
           IF !SYW->(DBSEEK(xFilial("SYW")+M->WB_CORRETO))
              Help("", 1, "AVG0003020")//"C¢digo do Corretor nÆo cadastrado"###"Informação"
              M->WB_VL_CORR:=0
              RETURN .F.
           ELSE
              M->WB_VL_CORR:=PorcCorretor(nTotFFC,,M->WB_CA_TX)
           ENDIF
        ENDIF

   Case MFlag = 'Moeda'
        cMoeDesc := SPACE(35)
        IF lDisplay
           if SYF->(dbSeek(xFilial()+TMoeda))
              cMoeDesc := LEFT(SYF->YF_DESC_SI,25)
           endif
           RETURN .T.
        ENDIF

        IF !EMPTY(TMoeda) .AND. !SYF->(DBSEEK(xFilial("SYF")+TMoeda))
           Help("", 1, "AVG0003021")//"C¢digo da Moeda nÆo cadastrado"###"Informação"
           RETURN .F.
        ENDIF

        if SYF->(dbSeek(xFilial()+TMoeda))
           cMoeDesc := LEFT(SYF->YF_DESC_SI,25)
        ENDIF
        IF EasyEntryPoint("EICLO100")
          IF !(ExecBlock("EICLO100",.F.,.F.,"LOVAL_MOEDA"))
            RETURN .F.
          ENDIF
        ENDIF

   Case MFlag = 'DtFin'
        IF !EMPTY(DtFinVenc)
           IF DtIniVenc > DtFinVenc
              Help("", 1, "AVG0003006")//"Data Inicial Maior que Data Final"###"Informação"
              RETURN .F.
           ENDIF
        ENDIF

   Case MFlag == "Banco"
        cBanDesc := ""
        IF lDisplay
           if SA6->(dbSeek(xFilial()+TBanco+TAgencia))
              cBanDesc := SA6->A6_NREDUZ
           endif
           RETURN .T.
        ENDIF

        IF EMPTY(TBanco)
           IF EMPTY(TAviso)
              RETURN .T.
           ELSE
              Help("", 1, "AVG0003022")//"C¢digo do Banco nÆo Preenchido"###"Informação"
              RETURN .F.
           ENDIF
        ENDIF
        cRno:=SA6->(recno()); cBco:=SA6->A6_COD
        IF !SA6->(DBSEEK(xFilial("SA6")+TBanco+TAgencia))
           Help("", 1, "AVG0003023")//"C¢digo do Banco nÆo Cadastrado"###"Informação"
           RETURN .F.
        ENDIF
        IF(cBco == SA6->A6_COD,SA6->(DBGOTO(cRno)),)
        TAgencia:=SA6->A6_AGENCIA

   Case MFlag == "Banco2"
        cBanDesc := ""
        IF lDisplay
           if SA6->(dbSeek(xFilial()+M->WB_BANCO))
              cBanDesc := SA6->A6_NREDUZ
           endif
           RETURN .T.
        ENDIF

        IF EMPTY(M->WB_BANCO)
           IF EMPTY(M->WB_NUM)
              RETURN .T.
           ELSE
              Help("", 1, "AVG0003022")//"C¢digo do Banco nÆo Preenchido"###"Informação"
              RETURN .F.
           ENDIF
        ENDIF
        cRno:=SA6->(recno()); cBco:=SA6->A6_COD
        IF !SA6->(DBSEEK(xFilial("SA6")+M->WB_BANCO))
           Help("", 1, "AVG0003023")//"C¢digo do Banco nÆo Cadastrado"###"Informação"
           RETURN .F.
        ENDIF
        IF(cBco == SA6->A6_COD,SA6->(DBGOTO(cRno)),)
        M->WB_AGENCIA:=SA6->A6_AGENCIA

   Case MFlag = "Agencia"
        IF !EMPTY(M->WB_AGENCIA)
           IF !SA6->(DBSEEK(xFilial("SA6")+M->WB_BANCO+M->WB_AGENCIA))
              Help("", 1, "AVG0003024")//"C¢digo da Agencia nÆo Cadastrada para esse Banco"###"Informação"
              RETURN .F.
           ENDIF
        ENDIF


//HVR 22/03/2006 - Tipo do COntrato Obrigatorio
   Case MFlag = 'TpCon'
        IF cTpCon == ""
           If (Type("M->WB_TIPOREG") == "C") .And. (Left(M->WB_TIPOREG,1) $ "1ABC")
              cTpCon := "2"
              Return .T.
           Else
              MsgStop(STR0135) // Tipo de Contrato não Informado
              Return .F.
           EndIf
        Else
           RETURN .T.
        ENDIF
//HVR***

   CASE MFlag = 'DT'
        IF EMPTY(M->WB_DT) .AND. ! EMPTY(M->WB_NUM)
           Help("", 1, "AVG0003025")//"Data do Aviso Banc rio nÆo Preenchida"###"Informação"
           RETURN .F.
        ENDIF

   CASE MFlag = "CAMBIO"

   CASE MFlag = "CADT"

   CASE MFlag = "Aviso"
        IF EMPTY(M->WB_NUM)
           Help("", 1, "AVG0003026")//"Aviso Banc rio nÆo Preenchida"###"Informação"
           RETURN .F.
        ENDIF
   CASE MFlag = "LIQFFC"
        If Work1->SWBEEQ == "SWB" .AND. ( Empty(M->WB_BANCO) .OR. Empty(M->WB_CA_DT ) .OR. Empty(M->WB_CA_TX) )
           MsgStop("Os campos "+AvSx3("WB_BANCO",5)+", "+AvSx3("WB_CA_DT",5)+" e "+AvSx3("WB_CA_TX",5)+" devem estar preenchidos.")
           Return .F.
        ElseIf Work1->SWBEEQ == "EEQ" .AND. ( Empty(M->EEQ_BANC) .OR. Empty(M->EEQ_PGT ) .OR. Empty(M->EEQ_TX) )
           MsgStop("Os campos "+AvSx3("EEQ_BANC",5)+", "+AvSx3("EEQ_PGT",5)+" e "+AvSx3("EEQ_TX",5)+" devem estar preenchidos.")
           Return .F.
        EndIf
        //SVG - 31/07/09 - Troca de EECFlags p/ AvFlags (Avgeral)
        If AvFlags("CAMBIO_EXT")
           If Empty(M->WB_TIPOPAG)
              MsgInfo("Favor informar o tipo de pagamento.", "Atenção")
              Return .F.
           EndIf
           If Empty(M->WB_CONTA)
              MsgInfo("Favor informar a conta utilizada.","Atenção")
              Return .F.
           EndIf
           If M->WB_TIPOPAG == "2"

              SA6->(DBSetOrder(1))
              SA6->(DBSeek(SA6->(xFilial() + M->(WB_BANCO + WB_AGENCIA + WB_CONTA))))

              nAD101_VLTO := Ad101ValBco(nParcSel,;
                                         M->WB_MOEDA,;
                                         SA6->A6_MOEEASY,; //Posicione("SA6", 1, xFilial("SA6")+M->(WB_BANCO+WB_AGENCIA+WB_CONTA), "A6_MOEEASY"),; nopado por WFS
                                         ,;
                                         M->WB_CA_DT,;
                                         .F.)

              nAD101_VLPC := 0
              If !(lRetorno := (nAD101_VLTO > 0))
                 Return .F.
              EndIf

              //** JPM - 13/01/2010 - verificar saldo na conta.
              nSaldo := AD101GetSld(M->WB_BANCO,;
                                    M->WB_AGENCIA,;
                                    M->WB_CONTA,;
                                    Left(DtoS(M->WB_CA_DT), 6))

              If (nSaldo < nAD101_VLTO)
                  MsgStop("Não há saldo na conta para pagamento por transfêrencia no exterior no mês "+AllTrim(Left(DtoS(M->WB_CA_DT), 6))+":"+ENTER+;
                          "Saldo no Banco: "+AllTrim(SA6->A6_MOEEASY)+Transform(nSaldo     ,AvSx3("WB_FOBMOE",AV_PICTURE))+ENTER+ENTER+; // ** JPM - 10/12/2009 - mostrar saldo e valor
                          "Valor a Pagar : "+AllTrim(SA6->A6_MOEEASY)+Transform(nAD101_VLTO,AvSx3("WB_FOBMOE",AV_PICTURE)), "Atenção")
                  Return .F.
              EndIf
              //** JPM - 13/01/2010 - verificar saldo na conta. FIM

           EndIf

        EndIf

ENDCASE
IF EasyEntryPoint("EICLO100")
   ExecBlock("EICLO100",.F.,.F.,"VALID")
ENDIF

Return lRetorno

*----------------------------------------------------------*
FUNCTION LO100Wk1Grv(TForn,TMoeda,TLote,TImport,cFil,cLoja)
*----------------------------------------------------------*
Local cMoeda, cImpor, cConPag, nDiasPag, cForne
Local cFilSW2 := cFil //xFilial("SW2")
Local cFilSW6 := cFil //xFilial("SW6")
Local cFilSW7 := cFil //xFilial("SW7")
Local cFilSW9 := cFil //xFilial("SW9")
Local cFilSYT := If(Posicione("SX2",1,"SYT","X2_MODO") == "E", cFil, xFilial("SYT"))

// GCC - 17/10/2013 - Ajustes para as novas modalidades de pagamento antecipado
If lCposAntecip .And. SWB->WB_PO_DI == 'A'		// Pagamento Antecipado vinculado a PO
	SW2->(DbSeek(cFilSW2+LEFT(SWB->WB_HAWB,Len(SW2->W2_PO_NUM))))
	cMoeda	:= SW2->W2_MOEDA
	cImpor	:= SW2->W2_IMPORT
	cConPag	:= SW2->W2_COND_PA
	nDiasPag:= SW2->W2_DIAS_PA
	cForne 	:= SW2->W2_FORN
ElseIf lCposAntecip .And. (SWB->WB_PO_DI == 'F' .Or. SWB->WB_PO_DI == 'C')		// Pagamento Antecipado vinculado a Fornecedor ou Crédito
	cMoeda	:= SWB->WB_MOEDA
	cImpor	:= ""
	cConPag	:= SWB->WB_FORMPAG
	nDiasPag:= ""
	cForne 	:= SWB->WB_FORN
Else
	SW6->(DbSeek(cFilSW6+SWB->WB_HAWB											 ))	//Declaracao
	SW7->(DbSeek(cFilSW7+SWB->WB_HAWB											 ))	//It_Declaracao
	SW2->(DbSeek(cFilSW2+SW7->W7_PO_NUM											 ))	//Pedidos
	SW9->(DbSeek(cFilSW9+SWB->WB_INVOICE+SWB->WB_FORN+EICRetLoja("SWB","WB_LOJA"))) //Invoices
	cMoeda	:= SW9->W9_MOE_FOB
	cImpor	:= SW6->W6_IMPORT
	cConPag	:= SW9->W9_COND_PA
	nDiasPag:= SW9->W9_DIAS_PA
	cForne 	:= SW9->W9_FORN
EndIf

IncProc(STR0043+SWB->WB_HAWB) //"Pesquisando Processo: "
nCont++

IF nCont > MAX_COUNT
   ProcRegua(MAX_COUNT)
   nCont := 0
ENDIF

If lEICFFCEAI .And. SWB->WB_EVENT $ "608|609" //THTS - 24/01/2018 - Manutencao de FFC via EAI ### Evento de adto nao podera ser considerado em ambientes com EAI habilitado
    Return .T.
EndIf

IF !EMPTY(SWB->WB_DT_VEN)
   IF !EMPTY(DtIniVenc) .AND. SWB->WB_DT_VEN < DtIniVenc
      IF EasyEntryPoint("EICLO100")  //FCD 13/11/01
         If (ExecBlock("EICLO100",.F.,.F.,"VALIDAVENC"))
            Return .t.
         EndIf
      ELSE
        RETURN .T.
      ENDIF
   ENDIF
   IF !EMPTY(DtFinVenc) .AND. SWB->WB_DT_VEN > DtFinVenc
      IF EasyEntryPoint("EICLO100")//FCD 13/11/01
         If (ExecBlock("EICLO100",.F.,.F.,"VALIDAVENC"))
            Return .t.
         EndIf
      ELSE
        RETURN .T.
      ENDIF
   ENDIF
ENDIF

//** GFC - 01/12/05 - Filtro por tipo de contrato
If lWB_TP_CON
   If !Empty(cTpCon) .and. SWB->WB_TP_CON <> Left(cTpCon,1)
      Return .T.
   EndIf
   //If !Empty(cTipo) .And. (SWB->WB_TIPOC <> cTipo)//RMD - 11/06/08
   If !Empty(cTipo) .And. (!Empty(SWB->WB_TIPOC) .AND. SWB->WB_TIPOC <> cTipo) //AAF 23/07/08 - Verifica se não é vazio.
      Return .T.
   EndIf
EndIf
//**

//ISS - 03/12/10 - Corrigida a condição abaixo para que essa considere a loja do fornecedor quando o EIC estiver usando o tratamento de loja.
IF !EMPTY(TForn ) .AND. !EMPTY(cLoja) .AND. (SWB->WB_FORN # TForn .OR. (!EICLOJA() .OR. SWB->WB_LOJA # cLoja))
   RETURN .T.
ENDIF

If lEFFTpMod
   //HVR 17/03/2006 - Considerar Filtro cEvent
   IF !EMPTY(cEvent ) .AND. SWB->WB_EVENT # cEvent
      RETURN .T.
   ENDIF
   //HVR***
EndIf
//HVR 17/03/2006 - Considerar Filtro Contrato
IF !EMPTY(cNrOp) .AND. SWB->WB_CA_NUM # cNrOp
   RETURN .T.
ENDIF
//HVR***

IF !EMPTY(TMoeda) .AND. cMoeda # TMoeda
   RETURN .T.
ENDIF

IF !EMPTY(TImport) .AND. cImpor # TImport
   RETURN .T.
ENDIF

//Acb - 10/11/2010
If !Empty(TForn) .And. cForne # TForn
   Return .T.
EndIf
IF !lCposAntecip .OR. SWB->WB_PO_DI == 'D'
   IF EMPTY(TLote) .AND. TemDI # IF(EMPTY(SW6->W6_DI_NUM),STR0030,STR0001) //"NÆo"###"Sim"
      RETURN .T.
   ENDIF
ENDIF
IF EasyEntryPoint("EICLO100") //OS 0640/01 FCD
   If !ExecBlock("EICLO100",.F.,.F.,"MODALID")
      Return .T.
   Endif
ENDIF

//TRP - 28/06/2011 - Inicia as variáveis de memória dos campos de Banco, Agencia e Conta para não dar erro no MsSeek no FINA080. (Chamado 735912)
M->WB_BANCO  := SWB->WB_BANCO
M->WB_AGENCIA:= SWB->WB_AGENCIA
M->WB_CONTA  := SWB->WB_CONTA

Work1->(DBAPPEND())
AvReplace("SWB","Work1")//AAF 12/03/09

Work1->WB_FILIAL := SWB->WB_FILIAL //HVR 16/03/2006 - Filial na MsSelect
Work1->WB_DT_VEN := SWB->WB_DT_VEN
Work1->WB_CA_NUM := SWB->WB_CA_NUM
Work1->A2_COD    := SWB->WB_FORN
Work1->A2_NREDUZ := BuscaFabr_Forn(SWB->WB_FORN,SWB->WB_LOJA)
Work1->W9_MOE_FOB:= cMoeda
Work1->WKREC_SWB := SWB->(RECNO())
Work1->WB_LOJA   := SWB->WB_LOJA //HVR
Work1->WB_LINHA:= SWB->WB_LINHA
If lEFFTpMod
   Work1->SWBEEQ    := 'SWB' //HVR
   Work1->WB_EVENT:= SWB->WB_EVENT //HVR 17/03/2006 - Evento na MsSelect
   Work1->WB_PARFIN:= SWB->WB_PARFIN
EndIf
Work1->WB_CA_DT  := SWB->WB_CA_DT
Work1->WB_INVOICE:= SWB->WB_INVOICE
Work1->W6_IMPORT := cImpor
Work1->W9_COND_PA:= cConPag
Work1->W9_DIAS_PA:= nDiasPag
//Work1->WKFLAG    := cMarca        //ISS - 27/10/10 - Os cambios começaram desmarcados agora
Work1->WKFLAG    :=SPACE(nTamFLAG)
Work1->TRB_ALI_WT:= "SWB"
Work1->TRB_REC_WT:= SWB->(Recno())

Work1->WKTPREG   := FFCTpReg(SWB->WB_TIPOREG,20)
IF lCposAntecip .AND. (SWB->WB_PO_DI == 'A' .Or. SWB->WB_PO_DI == 'F' .Or. SWB->WB_PO_DI == 'C') // GCC - 27/08/2013 - Tratamento para as novas modalidades de pagamentos antecipados
   Work1->WB_FOBMOE := SWB->WB_PGTANT
   Work1->WB_PGTANT := 0
   Work1->W6_HAWB   := SWB->WB_HAWB
   Work1->WB_PO_DI  := SWB->WB_PO_DI
ELSE
   IF lCposAntecip
      Work1->WB_PO_DI:=SWB->WB_PO_DI
   Else
      Work1->WB_PO_DI := "D"  // PLB 25/09/06
   ENDIF
   Work1->W6_DI_NUM := SW6->W6_DI_NUM
   Work1->W6_MAWB   := SW6->W6_MAWB
   Work1->W6_HAWB   := SW7->W7_HAWB
   Work1->WB_FOBMOE := SWB->WB_FOBMOE
ENDIF

//** GFC - 01/12/05 - Filtro por tipo de contrato (mostrar no browse)
If lWB_TP_CON
   Work1->WB_TP_CON := SWB->WB_TP_CON
EndIf
//**
// SVG - 09/12/10 - Zerado pois nesse momento não existem parcelas marcadas
//nTotFFC +=Work1->WB_FOBMOE

IF SYT->(DBSEEK(cFilSYT+cImpor))
   Work1->YT_NOME_RE:=LEFT(SYT->YT_NOME_RE,25)
ENDIF

// AWR - 02/06/04
IF(Work1->(FIELDPOS("WB_PREFIXO")) # 0 , Work1->WB_PREFIXO:=SWB->WB_PREFIXO,)
IF(Work1->(FIELDPOS("WB_NUMDUP" )) # 0 , Work1->WB_NUMDUP :=SWB->WB_NUMDUP ,)
IF(Work1->(FIELDPOS("WB_PARCELA")) # 0 , Work1->WB_PARCELA:=SWB->WB_PARCELA,)
IF(Work1->(FIELDPOS("WB_TIPOTIT")) # 0 , Work1->WB_TIPOTIT:=SWB->WB_TIPOTIT,)
// AWR - 02/06/04


If EasyEntryPoint("EICLO100") //OS 0640/01 FCD
   ExecBlock("EICLO100",.F.,.F.,"APOSGRAVA")
EndIf

TBanco  :=SWB->WB_BANCO
TAgencia:=SWB->WB_AGENCIA

If TYPE("SWB->WB_CONTA") == "C"
   //*** RMD - 23/11/07 - Nova legislação de câmbio
   TConta := SWB->WB_CONTA
   //***
EndIf
SW8->(DBSETORDER(1))
SW7->(DBSETORDER(1))
RETURN .T.

//HVR 17/03/2006 - Grava na Work 1 os registros da tabela EEQ conforme Filtro
*---------------------------------------------------------*
FUNCTION LO100EEQGrv(TForn,TMoeda,TLote,TImport,cFil,cLoja)
*---------------------------------------------------------*
Local cMoeda,cImpor,cConPag,nDiasPag, cForne
Local cFilSYT:=If(Posicione("SX2",1,"SYT","X2_MODO") == "E",cFil,xFilial("SYT"))

IncProc(STR0043+EEQ->EEQ_PREEMB)
nContEEQ++

If lEICFFCEAI //THTS - 24/01/2018 - Manutencao de FFC via EAI ### Nao sera considerado dados da EEQ para FFC Imp. quando integrado ao Logix
    Return .T.
EndIf

IF nContEEQ > MAX_COUNT
   ProcRegua(MAX_COUNT)
   nContEEQ := 0
ENDIF

If !EMPTY(EEQ->EEQ_FFC) .AND. !EMPTY(EEQ->EEQ_FFCIMP)
   Return .T.
EndIf

If !EMPTY(EEQ->EEQ_PGT) .AND. EMPTY(TLOTE)
   Return .T.
EndIf

If lWB_TP_CON
   If !Empty(cTpCon) .and. EEQ->EEQ_TP_CON <> Left(cTpCon,1)
      Return .T.
   EndIf
   If !Empty(cTipo) .And. EEQ->EEQ_TIPO <> cTipo//RMD - 11/06/08
      Return .T.
   EndIf
EndIf

IF !EMPTY(TForn ) .AND. !EMPTY(cLoja) .AND. EEQ->EEQ_FORN # TForn .AND. (!EICLOJA() .OR. EEQ->EEQ_FOLOJA == cLoja)
   RETURN .T.
ENDIF

IF !EMPTY(cEvent ) .AND. EEQ->EEQ_EVENT # cEvent
   RETURN .T.
ENDIF

IF !EMPTY(cNrOp) .AND. EEQ->EEQ_NROP # cNrOp
   RETURN .T.
ENDIF

IF !EMPTY(TMoeda) .AND. cMoeda # TMoeda
   RETURN .T.
ENDIF

//Acb - 10/11/2010
If !Empty(TForn) .And. cForne # TForn
   Return .T.
EndIf
// ** Período de Vencimento.
If !Empty(DtIniVenc) .And. EEQ->EEQ_VCT >= DtIniVenc
   RETURN .T.
EndIf

If !Empty(DtFinVenc) .And. EEQ->EEQ_VCT <= DtFinVenc
   RETURN .T.
EndIf

IF EasyEntryPoint("EICLO100") //OS 0640/01 FCD
   If !ExecBlock("EICLO100",.F.,.F.,"MODALID")
      Return .T.
   Endif
ENDIF

cMoeda:=EEQ->EEQ_MOEDA
cImpor:=EEQ->EEQ_IMPORT
cConPag:=EEC->EEC_CONDPA
nDiasPag:=EEC->EEC_DIASPA
cForne := EEQ->EEQ_FORN // Acb - 10/11/2010

Work1->(DBAPPEND())
Work1->SWBEEQ    := 'EEQ' //HVR
Work1->WB_FILIAL := EEQ->EEQ_FILIAL
Work1->WB_DT_VEN := EEQ->EEQ_VCT
Work1->WB_CA_NUM := EEQ->EEQ_NROP
Work1->A2_COD    := cForne//EEQ->EEQ_FORN//Acb - 10/11/2010
Work1->WB_LOJA   := EEQ->EEQ_FOLOJA
Work1->A2_NREDUZ := BuscaFabr_Forn(SWB->WB_FORN,SWB->WB_LOJA)
Work1->W9_MOE_FOB:= cMoeda
Work1->WKREC_SWB := EEQ->(RECNO())
Work1->WB_EVENT:= EEQ->EEQ_EVENT
Work1->EEQ_NRINVO:= EEQ->EEQ_NRINVO //HVR 19/04/2006 - CAMPO DA INVOICE PARA SWB OU EEQ
Work1->EEQ_PARC:= EEQ->EEQ_PARC
Work1->EEQ_PARFIN:= EEQ->EEQ_PARFIN //HVR 20/04/2006 - CAMPO PARFIN EEQ OU SWB
Work1->W6_IMPORT := cImpor
Work1->W9_COND_PA:= cConPag
Work1->W9_DIAS_PA:= nDiasPag
//Work1->WKFLAG    := cMarca        //ISS - 27/10/10 - Os cambios começaram desmarcados agora
Work1->WKFLAG    :=SPACE(nTamFLAG)
Work1->W6_DI_NUM := ""
Work1->W6_MAWB   := ""
Work1->W6_HAWB   := EEQ->EEQ_PREEMB
Work1->WB_FOBMOE := EEQ->EEQ_VL
Work1->WB_TP_CON := EEQ->EEQ_TP_CON
Work1->TRB_ALI_WT:= "EEQ"
Work1->TRB_REC_WT:= EEQ->(Recno())

nTotFFC +=Work1->EEQ_VL

IF SYT->(DBSEEK(cFilSYT+cImpor))
   Work1->YT_NOME_RE:=LEFT(SYT->YT_NOME_RE,25)
ENDIF

IF(Work1->(FIELDPOS("EEQ_PARC")) # 0 , Work1->EEQ_PARC:=EEQ->EEQ_PARC,)

If EasyEntryPoint("EICLO100")
   ExecBlock("EICLO100",.F.,.F.,"APOSGRAVA")
EndIf

TBanco  :=EEQ->EEQ_BANC
TAgencia:=EEQ->EEQ_AGEN
RETURN .T.
//HVR***

*------------------------------*
FUNCTION LO100AllMark(oMarkAll)
*------------------------------*
LOCAL nRecno      := Work1->(RECNO())//, cNewMarca
PRIVATE bFor      := {||EMPTY(cGetProc) .OR. cGetProc=Work1->W6_HAWB}
Private cNewMarca := IF(Work1->WKFLAG==cMarca,SPACE(nTamFLAG),cMarca)

lAchou   :=.T.
cGetProc :=Work1->W6_HAWB

IF LO100GetProcesso()
   IF !EMPTY(cGetProc)
      Work1->(DBEVAL({|| cNewMarca:= IF( Work1->WKFLAG==cMarca , SPACE(nTamFlag), cMarca), lAchou:=.F. },;
                     {|| cGetProc == Work1->W6_HAWB .AND. lAchou}))
   ENDIF

    Work1->(DBGOTOP())
    While ! Work1->(Eof())
      If cGetProc == Work1->W6_HAWB
          If Work1->WKFLAG != cNewMarca
            If lEICFFCEAI .and. nQtdParSel >= 100 .and. cNewMarca == cMarca
              MsgInfo(STR0144, STR0142)//"O limite de parcelas selecionadas quando o ambiente está integrado ao Logix é de 100 parcelas."####"Aviso"
              Exit
            EndIf
            Work1->WKFLAG:=cNewMarca
            If Work1->WKFLAG==cMarca
              AtuTotParc("A")
            Else
              AtuTotParc("B")
            EndIf
          EndIf
      EndIf
      Work1->(DbSkip())
    EndDo

   IF EasyEntryPoint("EICLO100") //OS 0640/01 FCD
      ExecBlock("EICLO100",.F.,.F.,"BMARCA1")
   ENDIF

   Work1->(DBGOTO(nRecno))
ENDIF
oMarkAll:oBrowse:Refresh()
oMarkAll:oBrowse:Reset()
RETURN NIL

*--------------------------*
FUNCTION LO100GetProcesso()
*--------------------------*
LOCAL nLin:=1, nColS:=0.8, nColG:=6.4, oDlg, nOpca:= 0

DEFINE MSDIALOG oDlg TITLE STR0044 From 9,0 To 17,35 OF oMainWnd //"Sele‡Æo"
   @ nLin,nColS SAY STR0045 //"Marcar Processo"
   @ nLin,nColG MSGET cGetProc SIZE 75,8 OF oDlg
   @ 3.5,14 BUTTON STR0046  SIZE 30,11 ACTION (nOpca:=1,oDlg:End()) OF oDlg //"OK"
ACTIVATE MSDIALOG oDlg CENTERED

IF nOpca = 0
   RETURN .F.
ENDIF
RETURN .T.

*---------------------*
Function LO100FFCs()
*---------------------*
LOCAL aSemSx3, cLote:="",TB_Campo1 :={}
LOCAL aSvCampos :=ACLONE(aCampos), lOK := .F.
LOCAL aSvaHeader:=ACLONE(aHeader), cNomArq
LOCAL nRecno1   :=Work1->(RECNO()), oMemo2, oDlg ,oPanel
PRIVATE cFFCs:="",aGetFFCs:={}
PRIVATE lButFFC := .T.,nRecno2 //FCD 12/11/01
Private aButtons:= {}

IF lLoteBran
   Work1->(DBGOTOP())
   WHILE !Work1->(EOF())
      IF !EMPTY(Work1->WKFLAG)
         lOK := .T.
         EXIT
      ENDIF
      Work1->(DBSKIP())
   ENDDO
   IF !lOK
      Help("", 1, "AVG0003027")//"NÆo h  Registros Marcados"###"Informação"
      Work1->(DBGOTO(nRecno1))
     RETURN .T.
   ENDIF
ENDIF

ASIZE(aCampos,0)
ASIZE(aHeader,0)

aCampos:={"WB_LOTE","A2_COD","WB_LOJA","A2_NREDUZ","W9_MOE_FOB","WB_DT_VEN","WB_TP_CON","WB_CA_NUM","W6_HAWB",; //HVR WB_LOJA
          "WB_INVOICE","WB_LINHA","WB_FOBMOE"}

If lEFFTpMod
   AAdd( aCampos, "WB_EVENT"   )  //HVR 17/03/2006 - Adicionado Event
   AAdd( aCampos, "EEQ_NRINVO" )  //HVR 19/04/2006 - CAMPO DA INVOICE PARA SWB OU EEQ
   AAdd( aCampos, "EEQ_PARC"   )
   AAdd( aCampos, "WB_PARFIN"  )  //HVR 20/04/2006 - CAMPO PARFIN EEQ OU SWB
   AAdd( aCampos, "EEQ_PARFIN" )
EndIf

aSemSX3:={{"WKREC_SWB","N",6,0},;
          {"WKFLAG"   ,"C",nTamFLAG,0}}

// ** JPM - 11/12/2009 - Nova Legislação Cambial
If EECFlags("CAMBIO_EXT")
   AAdd( aSemSX3 , {"WK_VINCEXP", "C", 1, 0} )
   AAdd( aSemSX3 , {"WK_VALBCO" , AvSx3("EYR_VALOR", AV_TIPO), AvSx3("EYR_VALOR", AV_TAMANHO), AvSx3("EYR_VALOR", AV_DECIMAL)} )
EndIf

If lEFFTpMod
   AAdd( aSemSX3, {"SWBEEQ"   ,"C",3,0} )
EndIf
AAdd(aSemSX3, {"WB_FILIAL","C",AVSX3("WB_FILIAL",3),0} )  //HVR 16/03/2005 - Filial
AAdd(aSemSX3, {"WB_PO_DI" ,"C",AVSX3("WB_PO_DI",3),0} )
AADD(aSemSX3,{"TRB_ALI_WT","C",03,0}) //TRP - 25/01/07 - Campos do WalkThru
AADD(aSemSX3,{"TRB_REC_WT","N",10,0})
AAdd( aSemSX3 , {"WKTPREG", "C", 30, 0} )
cNomArq:=E_CriaTrab(,aSemSX3, "Work2")
IndRegua("Work2",cNomArq+TEOrdBagExt(),"WB_LOTE",)
Processa( { |lEnd|cLote:=LO100Wk2Grv(cMarca) },STR0048) //"Gerando FFC's..."
Work2->(DBGOTOP())
Work1->(DBGOTOP())
AADD(TB_Campo1,{"WB_LOTE"   ,"","FFC's",cPicLot })
AADD(TB_Campo1,{"A2_COD"    ,"",STR0006 })//"Cod For"
AADD(TB_Campo1,{"WB_LOJA"   ,"",STR0136 })//"Loja For" //HVR
AADD(TB_Campo1,{"A2_NREDUZ" ,"",STR0007}) //"Fornecedor"
AADD(TB_Campo1,{"W9_MOE_FOB","",STR0008,})//"Moeda"
AADD(TB_Campo1,{"WB_FILIAL" ,"",STR0133}) //"Filial" //HVR 16/03/2006 - Flilial na MsSelect
AADD(TB_Campo1,{"WB_DT_VEN" ,"",STR0139}) //"Vecto"
AADD(TB_Campo1,{"WKTPREG"   ,"", STR0145}) //"Tipo Reg"
If lWB_Tp_Con
   AADD(TB_Campo1,{"WB_TP_CON" ,"",STR0138}) //"Tipo Con"  //HVR
EndIf
If lEFFTpMod
   //AADD(TB_Campo1,{"SWBEEQ"    ,"",STR0137}) //"Origem" //HVR
   AADD(TB_Campo1,{"WB_EVENT"  ,"",STR0134}) //"Evento" //HVR 16/03/2006 - Evento na MsSelect
   AADD(TB_Campo1,{{|| IF(WORK1->SWBEEQ=="SWB",WORK2->WB_INVOICE,WORK2->EEQ_NRINVO)},"",STR0004}) //"Invoices"
Else
   AADD(TB_Campo1,{"WB_INVOICE","",STR0004}) //"Invoices"  //HVR 19/04/2006 - CAMPO DA INVOICE PARA SWB OU EEQ
EndIf
AADD(TB_Campo1,{"WB_CA_NUM" ,"",STR0139}) //"Num Op"  //HVR
AADD(TB_Campo1,{"W6_HAWB"   ,"",STR0049}) //"Num. HAWB"
AADD(TB_Campo1,{"WB_FOBMOE" ,"",STR0009,cPicFobMoe}) //"Valor"

Aadd(aButtons,{"S4WB011N",{||LO100GetFFCs(),oMark2:oBrowse:Refresh(),oMark2:oBrowse:Reset()},STR0052,STR0052})   //"Altera FFC"

IF EasyEntryPoint("EICLO100") //OS 0640/01 FCD  12/11/01
   ExecBlock("EICLO100",.F.,.F.,"TELAFFC")
ENDIF


DO WHILE .T.
   nOpca:=1

   IF lLoteBran
      nOpca:=0//Para Sair quando Clicar no "X"

      oMainWnd:ReadClientCoors()
      DEFINE MSDIALOG oDlg TITLE STR0050 ; //"Gera‡Æo de FFC's"
             FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
        	     OF oMainWnd PIXEL
      @ 00,00 MsPanel oPanel Prompt "" Size 60,40 of oDlg //LRL 22/04/04 -Painel para alinhamento MDI.
      @ 0.8,1.0 SAY STR0051 of oPanel //"N§ de FFC's Gerados: "
      @ 0.8,8.0 GET oMemo2  Var cFFCs WHEN .F. MEMO SIZE 180,23 OF oPanel

	  IF EasyEntryPoint("EICLO100") //OS 0640/01 FCD  12/11/01
         ExecBlock("EICLO100",.F.,.F.,"TELAFFC")
      ENDIF
      If lButFFC  //FCD 12/11/01
         //@ 10,270 BUTTON STR0052 SIZE 34,11 ACTION (LO100GetFFCs(),oMark2:oBrowse:Refresh(),oMark2:oBrowse:Reset()) OF oPanel PIXEL //"Altera FFC"
      Endif
      oMark2:= MsSelect():New("Work2",,,TB_Campo1,@lInverte,@cMarca,{53,1,(oDlg:nClientHeight-2)/2,(oDlg:nClientWidth-2)/2})

	  oPanel:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	  oMark2:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	  oMark2:oBrowse:Refresh() //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

      ACTIVATE MSDIALOG oDlg ON INIT ;
               (EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},;
                                {||nOpca:=0,oDlg:End()},,;
                                aButtons))  //LRL 22/04/04 Alinhamento MDI
   ENDIF

   IF nOpca = 1
      nRecno2:=Work2->(RECNO())
  	  IF EasyEntryPoint("EICLO100") //OS 0640/01 FCD
         If !ExecBlock("EICLO100",.F.,.F.,"VAL_SCPE2")
            Exit
         Endif
      ENDIF

      IF lLoteBran
         lFFCs_OK :=.F.
         nRecno2:=Work2->(RECNO())
         Work2->(DBGOTOP())
         Work2->(DBEVAL({||.T.},,{||lFFCs_OK:=LO100OkFFC(Work2->WB_LOTE,nRecno2,Work2->WB_FILIAL)}))
         IF !lFFCs_OK
            Work2->(DBGOTO(nRecno2))
            LOOP
         ENDIF
         IF !MsgYesNo(STR0053,STR0054)// # "S" //"Confirma Geração do(s) FFC(s) ?"###"Geração"
            Work2->(DBGOTO(nRecno2))
            LOOP
         ENDIF
      ELSE
         IF !MsgYesNo(STR0055,STR0056)// # "S" //"Confirma Atualização do FFC ?"###"Atualização"
            EXIT
         ENDIF
      ENDIF
      Processa( {|| LO100GrvFFC(cLote) },STR0057) //"Gravando FFC's..."
      lGerouFFC:=.T.

  	  IF EasyEntryPoint("EICLO100") //OS 0640/01 FCD
         If !ExecBlock("EICLO100",.F.,.F.,"VAL_SCPE1")
            Exit
         Endif
      ENDIF
   ENDIF
   EXIT
ENDDO

aCampos:=ACLONE(aSvCampos)
aHeader:=ACLONE(aSvaHeader)

Work2->(E_EraseArq(cNomArq))

DBSELECTAREA("Work1")
Work1->(DBSETORDER(1))
Work1->(DBGOTO(nRecno1))

RETURN .T.

*-----------------------------------*
FUNCTION LO100OkFFC(cFFC,nRecno,cFil)
*-----------------------------------*

IF SWB->(MFilSeek(cFFC,cFil))
   Help("", 1, "AVG0003028",,TRANS(cFFC,cPicLot)+STR0059,1,16)//"N£mero de FFC: "###" j  existe no Cadastro"###"Informação"
   RETURN .F.
EndIf

RETURN .T.

*-----------------------*
Function LO100GetFFCs()
*-----------------------*
#define FIMGET Work2->(DBGOTO(nRecno1)) ; RETURN .F.
LOCAL nRecno1  :=Work2->(RECNO())
LOCAL cCadastro:=STR0060, oDlg //"Altera‡Æo do FFC"
Local oPanel
LOCAL nIndice
cGetLote:= Work2->WB_LOTE
cAuxLote:= Work2->WB_LOTE

WHILE .T.
   nOpca:= 0

   DEFINE MSDIALOG oDlg TITLE cCadastro From 10,0 To 20,85 OF oMainWnd

      oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 0, 0)

      nLin:=1.6 ; nColS:=0.9 ; nColG:=9.0
      @ nLin,nColS SAY STR0061 Of oPanel//"Novo C¢digo de FFC"
      @ nLin,nColG MSGET cGetLote PICT cPicLot SIZE 33,8 OF oPanel

      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      ACTIVATE MSDIALOG oDlg ON INIT ;
               EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},;
                                {||nOpca:=0,oDlg:End()}) CENTERED

   IF nOpca = 0
      FIMGET
   ENDIF

   IF Work2->(DBSEEK(cGetLote))
      Help("", 1, "AVG0003029")//"N£mero de FFC j  cadastrado para Gera‡Æo"###"Informação"
      Work2->(DBGOTO(nRecno1))
      LOOP
   ENDIF

   IF SWB->(MFilSeek(cGetLote))
      Help("", 1, "AVG0003030")//"N£mero de FFC j  existe no Cadastro"###"Informação"
      LOOP
   Endif

   IF !MsgYesNo(STR0064,STR0065)// # "S" //"Confirma Alteração do FFC ?"###"Alteração"
      LOOP
   ENDIF

   bExecute:={|aGet,nInd|IF(aGet[1]==cAuxLote,LO100AtuFFC(aGet[2],nInd),IncProc(STR0066+aGet[1]))} //"Processando Lote Nr. "
   IF(EasyEntryPoint("EICLO100"),ExecBlock("EICLO100",.F.,.F.,"ANTES_PROCESSA"),)
   Processa({||ProcRegua(LEN(aGetFFCs)) , AEVAL(aGetFFCs,bExecute) },STR0067) //"Gravando Novos FFC's..."

   EXIT
ENDDO

cFFCs := StrTran(cFFCs,AllTrim(TRANS(cAuxLote,cPicLot)),AllTrim(TRANS(cGetLote,cPicLot)) ) //JVR - 29/05/09 - Atualizar o nº FFC qyue apresenta na tela.

Work2->(DBSEEK(cGetLote))
RETURN .T.

*--------------------------------*
FUNCTION LO100AtuFFC(nRecno,nInd)
*--------------------------------*
IncProc(STR0066+cAuxLote) //"Processando Lote Nr. "
Work2->(DBGOTO(nRecno))
Work2->WB_LOTE:=cGetLote
aGetFFCs[nInd,1]:=cGetLote
RETURN .T.

*---------------------*
FUNCTION LO100Wk2Grv()
*---------------------*
LOCAL nLote:=EasyGParam("MV_SEQLOTE")
LOCAL cLote:=IF(lLoteBran,LO100NumLote(nLote+1),TLote)
LOCAL cForn:="", cMoeda:="", cTpCon:="", cCaNum:=""
Private bQuebraLote := {|| cForn # Work1->A2_COD  .OR. cMoeda # Work1->W9_MOE_FOB .OR. IIF(lWB_TP_CON,cTpCon # Work1->WB_TP_CON .OR. cCaNum # Work1->WB_CA_NUM,.F.) }

Work1->(DBSETORDER(2))
Work1->(DBGOTOP())
ProcRegua(Work1->(Easyreccount("Work1")))

//BHF - 24/06/08 - Inclusão do ponto de entrada para alteração do critério de quebra dos lotes.
If EasyEntryPoint("EICLO100")
   ExecBlock("EICLO100", .F., .F., "QUEBRA_LOTE")
EndIf

DO WHILE !Work1->(EOF())
   IncProc(STR0066+cLote) //"Processando Lote Nr. "

   IF EMPTY(Work1->WKFLAG) .AND. lLoteBran
      Work1->(DBSKIP())
      LOOP
   ENDIF

   //IF cForn # Work1->A2_COD  .OR. cMoeda # Work1->W9_MOE_FOB .OR. IIF(lWB_TP_CON,cTpCon # Work1->WB_TP_CON .OR. cCaNum # Work1->WB_CA_NUM,.F.)
   If Eval(bQuebraLote)//BHF - 24/06/08 - Concentrados os critério de quebra dos lotes na variável bQuebraLote
      cLote :=IF(lLoteBran,LO100NumLote(nLote+=1),cLote)
      cForn :=Work1->A2_COD
      cMoeda:=Work1->W9_MOE_FOB
      If lWB_TP_CON
         cTpCon:=Work1->WB_Tp_Con
         cCaNum:=Work1->WB_Ca_Num
      EndIf

      cFFCs +=TRANS(cLote,cPicLot)+", "
   ENDIF

   Work2->(DBAPPEND())
   Work2->WB_LOTE   :=cLote
   Work2->A2_COD    :=Work1->A2_COD
   Work2->WB_LOJA   :=Work1->WB_LOJA
   Work2->A2_NREDUZ :=Work1->A2_NREDUZ
   Work2->W9_MOE_FOB:=Work1->W9_MOE_FOB
   Work2->WB_Filial :=Work1->WB_Filial   //HVR 16/03/2006 - Filial
   Work2->WB_DT_VEN :=Work1->WB_DT_VEN
   Work2->TRB_ALI_WT:="SWB"
   Work2->TRB_REC_WT:=SWB->(Recno())

   If lWB_TP_CON
      Work2->WB_TP_CON :=Work1->WB_TP_CON   //HVR
      Work2->WB_CA_NUM :=Work1->WB_CA_NUM   //HVR
   EndIf
   Work2->W6_HAWB   :=Work1->W6_HAWB
   Work2->WB_FOBMOE :=Work1->WB_FOBMOE
   Work2->WKREC_SWB :=Work1->WKREC_SWB
   If lEFFTpMod
      Work2->SWBEEQ    :=Work1->SWBEEQ
      Work2->WB_EVENT  :=Work1->WB_EVENT    //HVR 17/03/2006 - Evento
      Work2->EEQ_NRINVO:=Work1->EEQ_NRINVO  //HVR 19/04/2006 - CAMPO DA INVOICE PARA SWB OU EEQ
      Work2->EEQ_PARC  :=Work1->EEQ_PARC  //HVR 20/04/2006 - CAMPO PARC-LINHA EEQ-SWB
      Work2->EEQ_PARFIN:=Work1->EEQ_PARFIN //HVR 20/04/2006 - CAMPO PARFIN EEQ OU SWB
      Work2->WB_PARFIN:=Work1->WB_PARFIN
   EndIf
   Work2->WB_INVOICE:=Work1->WB_INVOICE
   Work2->WB_LINHA  :=Work1->WB_LINHA
   Work2->WKFLAG    :=Work1->WKFLAG
   Work2->WB_PO_DI  :=Work1->WB_PO_DI
   Work2->WKTPREG   := FFCTpReg(Work1->WB_TIPOREG,30)
   AADD(aGetFFCs,{cLote,Work2->(RECNO())})
   Work1->(DBSKIP())
ENDDO

cFFCs:=ALLTRIM(LEFT(cFFCs,LEN(cFFCs)-2))
RETURN cLote

* --------------------------*
FUNCTION LO100NumLote(nLote)
*---------------------------*
RETURN PADL(nLote,5,'0')+SUBSTR(PADL(YEAR(dDataBase),4),3,2)

*-----------------------------*
FUNCTION LO100GrvFFC(cLote)
*-----------------------------*
SWB->(DBSETORDER(4))
IF !lLoteBran
   ProcRegua((Work2->(Easyreccount("Work2"))*2))

   WHILE !Work2->(EOF())
      //** AAF 04/05/06 - Retira FFC do EEQ.
      IF lEFFTpMod  .And. WORK2->SWBEEQ = "EEQ"
         EEQ->(DBGOTO(Work2->WKREC_SWB))
         EEQ->(RecLock("EEQ",.F.))
         EEQ->EEQ_FFCIMP := ""
         EEQ->(MsUNLOCK())
      ELSE
         LO100TiraFFC(Work2->WKREC_SWB)
      EndIf
      //**
      IncProc(STR0068+Work2->W6_HAWB) //"Atualizando Processo: "
      Work2->(DBSKIP())
   ENDDO
ELSE
   ProcRegua(Work2->(Easyreccount("Work2")))
ENDIF

Work2->(DBGOTOP())
WHILE ! Work2->(EOF())
   IF !lEFFTpMod  .Or.  WORK2->SWBEEQ = "SWB" //HVR
      IncProc(STR0068+Work2->W6_HAWB) //"Atualizando Processo: "
      IF EMPTY(Work2->WKFLAG)
         Work2->(DBSKIP()) ; LOOP
      ENDIF
      SWB->(DBGOTO(Work2->WKREC_SWB))
      SWB->(RecLock("SWB",.F.))
      SWB->WB_LOTE := Work2->WB_LOTE
      If !Empty(cOBS)//ASR - 10/11/2006 - Grava memo nas parcelas do lote somente quando for escrito uma nova OBS
	      SWB->(MSMM(IF(EMPTY(SWB->WB_OBS),NIL,SWB->WB_OBS),35,,cOBS,1,,,"SWB","WB_OBS"))
	  End If
      SWB->(MsUNLOCK())

      IF EasyEntryPoint("EICLO100") //OS 0640/01 FCD
         ExecBlock("EICLO100",.F.,.F.,"APOSGRVSWB")
      ENDIF
      Work2->(DBSKIP())
   ENDIF      //HVR

   IF lEFFTpMod  .And.  WORK2->SWBEEQ = "EEQ"  //HVR
      IncProc(STR0068+Work2->W6_HAWB) //"Atualizando Processo: "
      IF EMPTY(Work2->WKFLAG)
         Work2->(DBSKIP()) ; LOOP
      ENDIF
      EEQ->(DBGOTO(Work2->WKREC_SWB))
      EEQ->(RecLock("EEQ",.F.))
      EEQ->EEQ_FFCIMP := Work2->WB_LOTE
      SWB->(MsUNLOCK())

      IF EasyEntryPoint("EICLO100")
         ExecBlock("EICLO100",.F.,.F.,"APOSGRVEEQ")
      ENDIF
      Work2->(DBSKIP())
   ENDIF                          //HVR
ENDDO
IF lLoteBran
   SETMV("MV_SEQLOTE",SUBSTR(cLote,1,5))
ENDIF

RETURN NIL

*---------------------------------------------------------------------------------------
FUNCTION LO100Baixa(Bai_Est,PLote,lLoteBran)  //MJB-SAP-1100
*---------------------------------------------------------------------------------------
#define FIMBAIXA Work1->(DBGOTO(nRecno1)) ; RETURN .F.
LOCAL nRecno1  :=Work1->(RECNO())
LOCAL cCadastro:=STR0069 //"Baixa do FFC"
Local bValid := {|| lValid:=.T., AEval(aValid,{|MFlag| If(lValid,lValid:=LO100Val(MFlag),) } ), lValid }
Local aOrd := {}
LOCAL aValid:={"DT","Banco2","Agencia","CAMBIO","CADT","CORR"}
Local lCallSap:=(GetNewPar("MV_SAP_INT","N") == "S")                              //MJB-SAP-1100
Local nInd

PRIVATE oDlgBaixa
Private aGets:={}, aTela:={}
If lEFFTpMod
   AAdd( aValid, "LIQFFC" )
EndIf

//Igor Chiba 11/09/09
lSair   := .F.
If(EasyEntryPoint("EICLO100"), ExecBlock("EICLO100",.F.,.F.,"VALFECHA_EST"),)//JVR - 16/09/09
IF lSair
   RETURN .F.
ENDIF

//**igor chiba 29/09/09 validando todos que nao tiverem titulo erp
IF LCAMBIO_EIC .AND. lEICFI05
   nRecWork:=WORK1->(RECNO())
   WORK1->(DBGOTOP())
   DO WHILE WORK1->(!EOF())
      //IF EMPTY(WORK1->WB_TITERP)  .AND.  !EMPTY(WORK1->WKFLAG)
      IF IIF(lIntegStat, WORK1->WB_TITRET$cNao, EMPTY(WORK1->WB_TITERP) )  .AND.  !EMPTY(WORK1->WKFLAG)  // PLB 15/04/10 - Status de Retorno do ERP
         //MSGINFO('Cambio da Invoice:'+WORK1->WB_INVOICE+'nao pode ser liquidada/estornada por não possuir título ERP.')
         MSGINFO('Cambio da Invoice:'+WORK1->WB_INVOICE+'nao pode ser liquidada/estornada por não possuir retorno do ERP.')  // PLB 15/04/10 - Status de Retorno do ERP
         RETURN .F.
      ENDIF
      WORK1->(DBSKIP())
   ENDDO
   WORK1->(DBGOTO(nRecWork))
ENDIF
//**
If lCallSap                                                               //MJB-SAP-1100
   lMsgSAP := .T.
   lSair   := .F.
   IF EasyEntryPoint("EICLO100")
      ExecBlock("EICLO100",.F.,.F.,IF(Bai_Est, "MENSAGEM_SAP_FECHAMENTO", "MENSAGEM_SAP_ESTORNO"))
   ENDIF
   If lMsgSAP
   If Bai_Est                                                             //MJB-SAP-1100
      SW9->(DBSEEK(Work1->WB_FILIAL+SWB->WB_INVOICE+TForn+IF(EICLOJA(),cLoja,"")))                 //MJB-SAP-1100
      If Val(SW9->W9_SAPDOCF) > 0                                         //MJB-SAP-1100
         IF !MsgYesNo(STR0080+" o envio do titulo ao SAP ?")              //MJB-SAP-1100
            Return .F.                                                    //MJB-SAP-1100
         Endif                                                            //MJB-SAP-1100
      Endif                                                               //MJB-SAP-1100
   Else                                                                   //MJB-SAP-1100
      Help("", 1, "AVG0003031")//"Atencao - Estornar esta FFC manualmente no SAP !"         //MJB-SAP-1100
   Endif                                                                  //MJB-SAP-1100
   EndIf
   If lSair
      Return .F.
   EndIf
Endif                                                                     //MJB-SAP-1100

IF Bai_Est

   If !lEFFTpMod  .Or.  Work1->SWBEEQ <> "EEQ"
      SWB->(DBGOTO(Work1->WKREC_SWB))
   Else
      EEQ->(DBGOTO(Work1->WKREC_SWB))
   EndIf

ENDIF

WHILE .T.
   IF Bai_Est
      nOpca:= 0

      //DEFINE MSDIALOG oDlgBaixa TITLE cCadastro From 9,0 To 35,45 OF oMainWnd
      DEFINE MSDIALOG oDlgBaixa TITLE cCadastro From 9,0 To 35,75 OF oMainWnd
         nLin:=1.4 ; nColS:=0.9 ; nColG:=8.5

            If !lEFFTpMod  .Or.  Work1->SWBEEQ == "SWB"
               aCampos := {"WB_BANCO" ,"WB_DES_BCO","WB_AGENCIA","WB_NUM","WB_DT","WB_CA_NUM","WB_DT_CONT","WB_CA_DT","WB_CA_TX","WB_DT_DESE",;
                           "WB_MOEDA","WB_NAT_CON","WB_BCO_REC","WB_AGENREC","WB_CON_REC","WB_VM_OBS","WB_CORRETO","WB_VM_CORR"}//,"WB_LC_NUM","WB_VL_CORR","WB_DESPESA","WB_FORMPAG"}
               aAltera := {"WB_BANCO" ,             "WB_AGENCIA","WB_NUM","WB_DT","WB_CA_NUM","WB_DT_CONT","WB_CA_DT","WB_CA_TX","WB_DT_DESE",;
                                     "WB_NAT_CON","WB_BCO_REC","WB_AGENREC","WB_CON_REC","WB_VM_OBS","WB_CORRETO","WB_VM_CORR"}//,"WB_LC_NUM","WB_VL_CORR","WB_DESPESA","WB_FORMPAG"}

               //SVG - 31/07/09 - Troca de EECFlags p/ AvFlags (Avgeral)
               If AvFlags("CAMBIO_EXT")
                  aAdd(aCampos, "WB_TIPOPAG")
                  aAdd(aAltera, "WB_TIPOPAG")
                  aAdd(aCampos, "WB_CONTA")
                  aAdd(aAltera, "WB_CONTA")
                  aAdd(aCampos, "WB_EVENT")
                  aAdd(aAltera, "WB_EVENT")
               ElseIf lWB_CONTA
                  aADD(aCampos,"WB_CONTA")
               EndIf
              //SVG-12/12/08- Inclusão de campos incluidos pelo configurador e que forem usados, no array da msmget.
               SX3->(DBSETORDER(1))
               SX3->(dbSeek("SWB"))

               While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SWB"
                  If SX3->X3_PROPRI=="U" .AND. Ascan(aCampos,SX3->X3_CAMPO)==0 .AND. X3Uso(SX3->X3_USADO)
                     aAdd(aCampos,SX3->X3_CAMPO)
                  EndIF
                  SX3->(dbSkip())
               Enddo

               For nInd := 1 To SWB->(FCount())
                  M->&(SWB->(FieldName(nInd))) := SWB->(FieldGet(nInd))
               Next nInd

               /*For nInd := 1 To Len(aCampos)
                  If SWB->( FieldPos(aCampos[nInd]) ) > 0
                     M->&(aCampos[nInd]) := SWB->&(aCampos[nInd])
                  EndIf
               Next*/

               M->WB_DES_BCO := E_FIELD("WB_BANCO","A6_NOME",,,1)
               M->WB_TIPOREG := Left(SWB->WB_TIPOREG,1)
               M->WB_VM_OBS  := cObs
               M->WA_PO_DI   := SWB->WB_PO_DI

               SYW->(DBSETORDER(1))
               If SYW->(DBSEEK(xFilial()+M->WB_CORRETO))
                  M->WB_VM_CORR := SYW->YW_NOME
               EndIf

               //** Variaveis para os campos da enchoice.
               nManut:= 4
               PALTERACAO := .T.
               //**
            Else
               aValid:={"LIQFFC"}

               aCampos := {"EEQ_SOL","EEQ_DTNEGO","EEQ_DECAM","EEQ_BANC","EEQ_NOMEBC","EEQ_AGEN","EEQ_NCON","EEQ_RFBC","EEQ_CORR","EEQ_DTCE","EEQ_NROP",;
                           "EEQ_PGT","EEQ_MOEDA","EEQ_TX","EEQ_OBS","EEQ_CORR"}
               aAltera := {"EEQ_SOL","EEQ_DTNEGO","EEQ_DECAM","EEQ_BANC",            ,"EEQ_AGEN","EEQ_NCON","EEQ_RFBC","EEQ_CORR","EEQ_DTCE","EEQ_NROP",;
                           "EEQ_PGT",           ,"EEQ_TX","EEQ_OBS","EEQ_CORR"}

               For nInd := 1 To EEQ->(FCount())
                  M->&(EEQ->(FieldName(nInd))) := EEQ->(FieldGet(nInd))
               Next nInd

               /*
               For nInd := 1 To Len(aCampos)
                  M->&(aCampos[nInd]) := EEQ->&(aCampos[nInd])
               Next
               */

               //** Variaveis para os campos da enchoice.
               lFinanciamento := EasyGParam("MV_EFF",,.F.)
               lTelaVincula := .F. //FSM - 01/03/2012
               //M->EEQ_TP_CON := EEQ->EEQ_TP_CON
               M->EEQ_VL     := 0
            EndIf

            oEnch:= MsMGet():New(IIF(lEFFTpMod,Work1->SWBEEQ,"SWB"),RECNO(),4,,,,aCampos,{01,01,100,200},,,,,,,,,,,.T.)//19o. parametro com .T.: Desabilita as Pastas )
            oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

         IF EasyEntryPoint("EICLO100")
            ExecBlock("EICLO100",.F.,.F.,"GET_BAIXA")
         ENDIF

      ACTIVATE MSDIALOG oDlgBaixa ON INIT ;
                 EnchoiceBar(oDlgBaixa,{||nOpca:=1,IF(EVAL(bValid),oDlgBaixa:End(),)},;
                                  {||nOpca:=0,oDlgBaixa:End()}) CENTERED

      If nOpca == 1
         If !lEFFTpMod  .Or.  Work1->SWBEEQ == "SWB"
            TAviso     := M->WB_NUM
            TDt_Aviso  := M->WB_DT
            //TLc_Num    := M->WB_LC_NUM
            TBanco     := M->WB_BANCO
            TAgencia   := M->WB_AGENCIA
            TConta     := M->WB_CONTA
            TCambio    := M->WB_CA_NUM
            TTx_Cambio := M->WB_CA_TX
            TDt_Cambio := M->WB_CA_DT
            TCorretor  := M->WB_CORRETO
            TVl_Corr   := M->WB_VL_CORR
            //TVl_Despesa:= M->WB_DESPESA
            //TDt_FormPag:= M->WB_FORMPAG
            TDt_Cont   := M->WB_DT_CONT
            TDt_Dese   := M->WB_DT_DESE

            //** AAF 06/05/2006 - Campos Novos na Tela da Liquidação.
            TNatCon    := M->WB_NAT_CON
            TBcoRec    := M->WB_BCO_REC
            TAgenRec   := M->WB_AGENREC
            TConRec    := M->WB_CON_REC
            cObs       := M->WB_VM_OBS
            TCorreto   := M->WB_VM_CORR
            //**

         Else
            TSol       := M->EEQ_SOL
            TDtNego    := M->EEQ_DTNEGO
            TDecam     := M->EEQ_DECAM
            TBanco     := M->EEQ_BANC
            TAgen      := M->EEQ_AGEN
            TConta     := M->EEQ_NCON
            TRef       := M->EEQ_RFBC
            TCorr      := M->EEQ_CORR
            TCredExt   := M->EEQ_DTCE
            TCambio    := M->EEQ_NROP
            TDt_Cambio := M->EEQ_PGT
            TTx_Cambio := M->EEQ_TX
            cObs       := M->EEQ_OBS
         EndIf

      EndIf

      If nOpca = 0
         FIMBAIXA
      EndIf

   ENDIF
   // SVG - 05/11/2010 -
   IF lCposAntecip .And. !Bai_Est
      aOrd := SaveOrd({"SWB"})
      SWB->(DBSETORDER(5))
      IF (SWB->WB_PO_DI == 'A' .Or. SWB->WB_PO_DI == 'F' .Or. SWB->WB_PO_DI == 'C') .AND. SWB->(DBSEEK(xFilial()+SWB->WB_HAWB))	// GCC - 27/08/2013
         RestOrd(aOrd,.T.)
         MSGInfo(STR0141)  //TRP - 05/09/12 - STR0141 - "Adiantamento nao pode ser excluido, pois possui parcelas utilizadas em Processos."
         FIMBAIXA
      ENDIF
      RestOrd(aOrd,.T.)
   ENDIF

   IF !MsgYesNo(STR0080+IF(Bai_Est,STR0081,STR0082)+STR0083,STR0084)// # "S" //"Confirma "###"a Baixa"###"o Estorno da Baixa"###" do FFC ?"###"Confirmação"
      IF Bai_Est
         LOOP
      ELSE
         FIMBAIXA
      ENDIF
   ElseIf !Bai_Est   // PLB 27/07/06 - Variaveis utilizadas em LC100GrvBaixa()
      If !lEFFTpMod  .Or.  Work1->SWBEEQ == "SWB"
         TTx_Cambio := SWB->WB_CA_TX
         TDt_Cambio := SWB->WB_CA_DT
      Else
         TDt_Cambio := EEQ->EEQ_PGT
         TTx_Cambio := EEQ->EEQ_TX
      EndIf
   ENDIF

   Processa({|lEnd| LO100GrvBaixa(Bai_Est,PLote,lCallSap)})
   EXIT
ENDDO

RETURN .T.

*---------------------------------------------------------------------------------------
FUNCTION LO100GrvBaixa(Bai_Est,PLote,lCallSap)  //MJB-SAP-1100
*---------------------------------------------------------------------------------------
Local nParcAd_Tt := 0 // Total das Parcelas de Adiantamento
Local nParcAd_At := 0// Parcela de Adiantamento corrente
Local nValTot := 0, ni:= 0,  nPos := 0, lAddArray := .T., nVlControle:=0, nInd
Local aTaxaLiq := {}, lLiquida := .F.  //HVR -  função EX400TxLiq
LOCAL cSQLChv  := ""
// ** JPM - 11/12/2009 - Nova Leg. Cambial
Local lIncluiMov, lExcluiMov
Local aCambioBx := {}
local lRetEAI   := .T.
Local lDisarmTra:= .F.
Private cMotivo:= "" //Variavel usada para gravar todos os Motivos (EF4) iguais ao primeiro registro preenchido do estorno
Private cFFCMot:= "" //Variavel para ser usada na gravação do Motivo campos DE e PARA do EF4

//HVR
Private lPrePag := EF1->(FieldPos("EF1_CAREPR")) > 0 .and. EF1->(FieldPos("EF1_TPCAPR")) > 0 .and.;
                   EF1->(FieldPos("EF1_PARCPR")) > 0 .and. EF1->(FieldPos("EF1_PERIPR")) > 0 .and.;
                   EF1->(FieldPos("EF1_TPPEPR")) > 0 .and. EF1->(FieldPos("EF1_CAREJR")) > 0 .and.;
                   EF1->(FieldPos("EF1_TPCAJR")) > 0 .and. EF1->(FieldPos("EF1_PARCJR")) > 0 .and.;
                   EF1->(FieldPos("EF1_PERIJR")) > 0 .and. EF1->(FieldPos("EF1_TPPEJR")) > 0 .and.;
                   EF1->(FieldPos("EF1_PREPAG")) > 0 .and. ;
                   EF1->(FieldPos("EF1_CLIENT")) > 0 .and. EF1->(FieldPos("EF1_CLLOJA")) > 0 .and.;
                   EF1->(FieldPos("EF1_ROF"))    > 0 .and. EF1->(FieldPos("EF1_INI_IR")) > 0 .and.;
                   EF1->(FieldPos("EF1_FIM_IR")) > 0 .and. EF1->(FieldPos("EF1_PERCIR")) > 0 .and.;
                   EF1->(FieldPos("EF1_REAJIR")) > 0 .and. EF3->(FieldPos("EF3_SLDLIQ")) > 0 .and.;
                   EF3->(FieldPos("EF3_LIQ_RS")) > 0 .and. EF3->(FieldPos("EF3_NROP")) > 0 .and.;
                   EF3->(FieldPos("EF3_EV_VIN")) > 0 .and. EF3->(FieldPos("EF3_PARVIN")) > 0 .and.;
                   EF3->(FieldPos("EF3_SLDVIN")) > 0

//HVR***

//HVR
SX3->(DBSETORDER(2))

Private lTemChave := SX3->(DBSeek("EF1_BAN_FI")) .and. SX3->(DBSeek("EF1_PRACA")) .and.;
                     SX3->(DBSeek("EF2_BAN_FI")) .and. SX3->(DBSeek("EF2_PRACA")) .and.;
                     SX3->(DBSeek("EF3_BAN_FI")) .and. SX3->(DBSeek("EF3_PRACA")) .and.;
                     SX3->(DBSeek("EF4_BAN_FI")) .and. SX3->(DBSeek("EF4_PRACA")) .and.;
                     SX3->(DBSeek("EF1_AGENFI")) .and. SX3->(DBSeek("EF1_NCONFI")) .and.;
                     SX3->(DBSeek("EF3_AGENFI")) .and. SX3->(DBSeek("EF3_NCONFI")) .and.;
                     SX3->(DBSeek("ECE_BANCO"))  .and. SX3->(DBSeek("ECE_PRACA"))  .and.;
                     SX3->(DBSeek("EF3_OBS"))   .AND. SX3->(DBSeek("EF3_NROP"))
SX3->(DBSETORDER(1))
//HVR***
Private cTx_100, cTx_520  //HVR
Private cMod    := "I"    //HVR
Private aRotina:= {} //HVR Somente para rodar ex401get
Private aHeader:= {}, aCols:= {} //HVR Somente para rodar ex401get
PRIVATE cBaixa := "N" //OS 0640/01 FCD
Private lACCACE := .T. //HVR


//HVR Busca o Tipo de Taxa do evento contabil
If lEFFTpMod
   EC6->(DbSetOrder(6))
   EC6->(DbSeek(xFilial("EC6")+"FINIMP"+'100'))
   cTX_100 := EC6->EC6_TXCV
   EC6->(DbSeek(xFilial("EC6")+"FINIMP"+'520'))
   cTX_520 := EC6->EC6_TXCV
   EC6->(DbSetOrder(1))
EndIf
//HVR***


//HVR Somente para rodar ex401get
      AADD(aRotina,{ "" ,"AxPesqui"  ,0,1}) //"Pesquisar"
      AADD(aRotina,{ "" ,"EX400Manut",0,2}) //"Visualizar"
      AADD(aRotina,{ "" ,"EX400Manut",0,3}) //"Incluir"
      AADD(aRotina,{ "" ,"EX400Manut",0,4}) //"Alterar"
//hvr***

IF EasyEntryPoint("EICLO100") //OS 0640/01 FCD
   ExecBlock("EICLO100",.F.,.F.,IF(Bai_Est, "ANTES_FECHAMTO", "ANTES_ESTORNO"))
EndIf

ProcRegua(Work1->(Easyreccount("Work1")))

If lEFFTpMod
  //HVR*** VINCULACAO CONTRATO (Baixa e Estorno)
  IF Bai_Est == .T. //HVR Baixa
    Work1->(DBGOTOP())
    WHILE ! Work1->(EOF())
      IF lEIC_EFF .AND. lEFFTPMOD
        IF;
         (IF;
           (Work1->SWBEEQ <> "EEQ",;
              (EF3->(dbSetOrder(7), dbSeek(xFilial("EF3")+Left(TIPO_MODULO,1)+WORK1->W6_HAWB+WORK1->A2_COD+WORK1->WB_LOJA+WORK1->WB_INVOICE+WORK1->WB_LINHA+EV_EMBARQUE)));
           ,;
              (EF3->(dbSetOrder(2), dbSeek(xFilial("EF3")+Left(TIPO_MODULO,1)+EV_EMBARQUE+WORK1->EEQ_NRINVO+WORK1->EEQ_PARC)));
           );
         )


           EF1->(dbSeek(xFilial("EF1")+Left(TIPO_MODULO,1)+EF3->EF3_CONTRA+EF3->EF3_BAN_FI+EF3->EF3_PRACA+EF3->EF3_SEQCNT))

          If EF3->EF3_MOE_INV <> EF1->EF1_MOEDA
              AAdd( aTaxaLiq ,;
                 {EF3->EF3_CONTRA,;     // Contrato
                 EF3->EF3_BAN_FI,;      // Banco
                 EF3->EF3_PRACA,;       // Praca
                 EF3->EF3_SEQCNT,;      // Sequencia Contrato
                 IF(WORK1->SWBEEQ=="SWB",WORK1->WB_INVOICE,WORK1->EEQ_NRINVO),;    // Invoice//HVR 19/04/2006 - CAMPO DA INVOICE PARA SWB OU EEQ
                 IF(WORK1->SWBEEQ=="SWB",WORK1->WB_LINHA,WORK1->EEQ_PARC),;      // Parcela
                 TDt_Cambio,;           // Data Liquidacao //WORK1->WB_CA_DT  TDt_Cambio
                 EF3->EF3_MOE_INV,;     // Moeda Invoice
                 TTx_Cambio,;           // Taxa Liquidacao
                 WORK1->WB_FOBMOE,;     // Valor Moeda Invoice
                 EF1->EF1_MOEDA,;       // Moeda Contrato
                 BuscaTaxa(EF1->EF1_MOEDA,TDt_Cambio,,.F.,.T.,,"1") ,;    // Taxa Contrato
                 (TTx_Cambio*WORK1->WB_FOBMOE)/BuscaTaxa(EF1->EF1_MOEDA,TDt_Cambio,,.F.,.T.,,"1")}) //EF3->EF3_VL_MOE} )     // Valor Moeda Contrato

                 //If(EF3->EF3_MOE_INV <> EF1->EF1_MOEDA,BuscaTaxa(EF1->EF1_MOEDA,TDt_Cambio,,.F.,.T.,,"1"),TTx_Cambio),;    // Taxa Contrato     //AAF 04/05/06 - Caso seja moeda iguais utilizar a mesma taxa.
                 //(TTx_Cambio*WORK1->WB_FOBMOE)/If(EF3->EF3_MOE_INV <> EF1->EF1_MOEDA,BuscaTaxa(EF1->EF1_MOEDA,TDt_Cambio,,.F.,.T.,,"1"),TTx_Cambio)}) //EF3->EF3_VL_MOE} )     // Valor Moeda Contrato

              lLiquida:=.T.
          EndIf
        EndIf
      ENDIF
      Work1->(DBSKIP())
    ENDDO

    If lLiquida
      aTaxaLiq := EX401GetLiq(aTaxaLiq)
    EndIf
  ELSE  //HVR Estorno da Baixa da Liquidação
    lRet := .T.

    Work1->(DBGOTOP())
    WHILE ! Work1->(EOF()) .AND. lRet
      IF ((Work1->SWBEEQ <> "EEQ");
            .And. (EF3->(dbSetOrder(7), dbSeek(xFilial("EF3")+Left(TIPO_MODULO,1)+WORK1->W6_HAWB+WORK1->A2_COD+WORK1->WB_LOJA+WORK1->WB_INVOICE+If(!Empty(Work1->WB_PARFIN),Work1->WB_PARFIN,Work1->WB_LINHA)+EV_LIQ_PRC)) ) );     //HVR SWB //HVR 19/04/2006 - CAMPO DA INVOICE PARA SWB OU EEQ
            .OR. ((Work1->SWBEEQ == "EEQ");
            .AND. (EF3->(dbSetOrder(2), dbSeek(xFilial("EF3")+Left(TIPO_MODULO,1)+EV_LIQ_PRC+WORK1->EEQ_NRINVO+WORK1->EEQ_PARC)) ) ) //HVR SWB //HVR 19/04/2006 - CAMPO DA INVOICE PARA SWB OU EEQ

         EF1->(dbSeek(xFilial("EF1")+Left(TIPO_MODULO,1)+EF3->EF3_CONTRA+EF3->EF3_BAN_FI+EF3->EF3_PRACA+EF3->EF3_SEQCNT))
         cSeq := EF3->EF3_SEQ
      Else
         cSeq := ""
      Endif

      cFFCMot := TLote
      If !Empty(cSeq)
         LO1EstLiq(cSeq)
      Endif

      Work1->(DBSKIP())
    ENDDO

    If !lRet
      Return .F.
    EndIf
  ENDIF
  //HVR***/ Fim da Vinculação (baixa e estorno)

EndIf

//NCF - 10/06/2010 - Loop para calcular total das parcelas de adiantamento
Work1->(DBGOTOP())
While ! Work1->(EOF())
   If (Work1->WB_PO_DI == "A" .Or. Work1->WB_PO_DI == "F" .Or. Work1->WB_PO_DI == "C") .AND. !EMPTY(Work1->WKFLAG)	// GCC - 27/08/2013
      nParcAd_Tt++
   EndIf
   Work1->(DBSKIP())
EndDo

Begin TransAction

Work1->(DBGOTOP())
WHILE ! Work1->(EOF())
   IncProc(STR0068+Work1->W6_HAWB) //"Atualizando Processo: "

   //If EMPTY(Work1->WKFLAG) .OR. (EMPTY(SWB->WB_CA_DT) .AND. !Bai_Est)  //JVR - 29/05/09 - tratamento par exclusão de FFC, caso não esteja fechado.
   If EMPTY(Work1->WKFLAG) .OR. (EMPTY(Work1->WB_CA_DT) .AND. !Bai_Est)  //TDF - 12/03/10

      IF lEFFTpMod  .And.  WORK1->SWBEEQ = "EEQ"  //HVR
         EEQ->(DBGOTO(Work1->WKREC_SWB))
         EEQ->(RecLock("EEQ",.F.))
         EEQ->EEQ_FFCIMP := ""
         EEQ->(MsUNLOCK())
      ELSE
         LO100TiraFFC(Work1->WKREC_SWB)
      ENDIF
      Work1->(DBSKIP()) ; LOOP

   ENDIF
   IF !lEFFTpMod  .Or.  WORK1->SWBEEQ=="SWB"
      SWB->(DBGOTO(Work1->WKREC_SWB))
      nPGTANT := 0
      If lCposAntecip .AND. (SWB->WB_PO_DI == "A" .Or. SWB->WB_PO_DI == "F" .Or. SWB->WB_PO_DI == "C")	// GCC - 27/08/2013
         If !EMPTY(SWB->WB_CA_DT) .AND. (!Bai_Est .OR. EMPTY(TDt_Cambio))
            nPGTANT := -SWB->WB_PGTANT
         ElseIf EMPTY(SWB->WB_CA_DT) .AND. (!Bai_Est .OR. !EMPTY(TDt_Cambio))
            nPGTANT := SWB->WB_PGTANT
         EndIf
      ENDIF
   ELSE
      EEQ->(DBGOTO(WORK1->WKREC_SWB))

      nPGTANT := 0
   ENDIF


   //TRP- 30/01/09
   bBlock:= {|| IF(!lEFFTpMod  .Or.  WORK1->SWBEEQ=="SWB",SWB->WB_LOTE,EEQ->EEQ_FFCIMP) == PLote}

   IF EasyEntryPoint("EICLO100")
      ExecBlock("EICLO100",.F.,.F.,"BAIXA_LOTE")
   ENDIF

  IF Eval(bBlock)

   //IF (IF(!lEFFTpMod  .Or.  WORK1->SWBEEQ=="SWB",SWB->WB_LOTE,EEQ->EEQ_FFCIMP)) == PLote

    IF lEIC_EFF .And. lEFFTpMod  .And. WORK1->SWBEEQ = "EEQ"//  .And.  Bai_Est - RMD - 24/06/08
            If lLiquida
               nPos2 := AScan(aTaxaLiq,{|x| x[5]==EEQ_NRINVO .AND. x[6]==WORK1->EEQ_PARC})
            EndIf

            If EF3->(dbSetOrder(2), dbSeek(xFilial("EF3")+Left(TIPO_MODULO,1)+EV_EMBARQUE+WORK1->EEQ_NRINVO+WORK1->EEQ_PARC)) //HVR SWB //HVR 19/04/2006 - CAMPO DA INVOICE PARA SWB OU EEQ

               EF1->( dbSetOrder(1) )
               EF1->( dbSeek(xFilial("EF1")+Left(TIPO_MODULO,1)+EF3->EF3_CONTRA+EF3->EF3_BAN_FI+EF3->EF3_PRACA+EF3->EF3_SEQCNT))

               EX400Liquida(EF1->EF1_CONTRA,;
                  			 WORK1->EEQ_NRINVO,;
                            IF(!EMPTY(WORK1->EEQ_PARFIN),WORK1->EEQ_PARFIN,WORK1->EEQ_PARC),; //HVR 20/04/2006 - CAMPO PARFIN EEQ OU SWB
                            Work1->W6_HAWB,;
                            Work1->WB_FOBMOE,;
                            Work1->W9_MOE_FOB,; //EEC->EEC_MOEDA,;
                            EF1->EF1_MOEDA,;
                            "EF1",;
                            "EF3",;
                            "FFC",;
                            TTx_Cambio,;
                            TDt_Cambio,;
                            ,;
                            TDt_Cambio,;
                            If(lMultiFil,xFilial("EEQ"),Nil),;
                            ,;
                            ,;
                            ,;
                            ,;
                            TBanco,;
                            TAgen,;
                            EF1->EF1_NCONFI,;
                            EF3->EF3_PRACA,;
                            ,;
                            WORK1->WB_FOBMOE*TTx_Cambio,;
                            ,;
                            WORK1->WB_CA_NUM,;    //TMP->EEQ_NROP,;
                            ,;                                                              //nRecEF3Liq,;
                            Left(TIPO_MODULO,1),;                                           //cTpModu,
                            EF1->EF1_SEQCNT,;                                               //cSeqCon,
                            "EEQ",;                                                         //cOrigem,
                            WORK1->A2_COD,;                                                 //cForn,
                            WORK1->WB_LOJA,;                                                //cLojaFo,
                            WORK1->WB_PO_DI,;                                               //cPo_Di,
                            IIF(lLiquida .And. nPos2>0,aTaxaLiq[nPos2][13],))               //nVlMoeLiq

            EndIf//RMD - 24/06/08


               IF EasyEntryPoint("EICLO100")
                  ExecBlock("EICLO100",.F.,.F.,IF(Bai_Est, "ANTES_GRAVA_FECHAMENTO_EEQ", "ANTES_GRAVA_ESTORNO_EEQ"))  //TRP-06/06/08-Inclusão de ponto de entrada
               ENDIF
               RecLock("EEQ",.F.)

               //** AAF 06/05/2006 - Campos novos na tela de Liquidação
               EEQ->EEQ_SOL    := If(Bai_Est .AND. Empty(EEQ->EEQ_SOL)   ,TSol      ,AVCTOD('')                 )
               EEQ->EEQ_DTNEGO := If(Bai_Est .AND. Empty(EEQ->EEQ_DTNEGO),TDtNego   ,AVCTOD('')                 )
               EEQ->EEQ_DECAM  := If(Bai_Est .AND. Empty(EEQ->EEQ_DECAM) ,TDecam    ,Space(Len(EEQ->EEQ_DECAM )))
               EEQ->EEQ_BANC   := If(Bai_Est .AND. Empty(EEQ->EEQ_BANC)  ,TBanco    ,Space(Len(EEQ->EEQ_BANC  )))
               EEQ->EEQ_AGEN   := If(Bai_Est .AND. Empty(EEQ->EEQ_AGEN)  ,TAgen     ,Space(Len(EEQ->EEQ_AGEN  )))
               EEQ->EEQ_NCON   := If(Bai_Est .AND. Empty(EEQ->EEQ_NCON)  ,TConta    ,Space(Len(EEQ->EEQ_NCON  )))
               EEQ->EEQ_RFBC   := If(Bai_Est .AND. Empty(EEQ->EEQ_RFBC)  ,TRef      ,Space(Len(EEQ->EEQ_RFBC  )))
               EEQ->EEQ_CORR   := If(Bai_Est .AND. Empty(EEQ->EEQ_CORR)  ,TCorr     ,Space(Len(EEQ->EEQ_CORR  )))
               EEQ->EEQ_DTCE   := If(Bai_Est .AND. Empty(EEQ->EEQ_DTCE)  ,TCredExt  ,AVCTOD('')                 )
               EEQ->EEQ_NROP   := If(Bai_Est .AND. Empty(EEQ->EEQ_NROP)  ,TCambio   ,Space(Len(EEQ->EEQ_NROP  )))
               EEQ->EEQ_PGT    := If(Bai_Est .AND. Empty(EEQ->EEQ_PGT)   ,TDt_Cambio,AVCTOD('')                 )
               EEQ->EEQ_TX     := If(Bai_Est .AND. Empty(EEQ->EEQ_TX)    ,TTx_Cambio,0                          )
               EEQ->EEQ_OBS    := If(Bai_Est .AND. Empty(EEQ->EEQ_OBS)   ,cObs      ,Space(Len(EEQ->EEQ_OBS   )))

               IF EasyEntryPoint("EICLO100")
                  ExecBlock("EICLO100",.F.,.F.,IF(Bai_Est, "FECHAMENTO_EEQ", "ESTORNA_EEQ"))  //TRP-06/06/08-Inclusão de ponto de entrada
               EndIf
               EEQ->(MsUNLOCK())
            //EndIf - RMD - 24/06/08
    Else

            If lEIC_EFF .And. lEFFTpMod  .And.  Bai_Est
               If lLiquida
                  nPos2 := AScan(aTaxaLiq,{|x| x[5]==WORK1->WB_INVOICE .AND. x[6]==WORK1->WB_LINHA})
               EndIf

               If EF3->(dbSetOrder(7), dbSeek(xFilial("EF3")+Left(TIPO_MODULO,1)+WORK1->W6_HAWB+WORK1->A2_COD+WORK1->WB_LOJA+WORK1->WB_INVOICE+If(!Empty(Work1->WB_PARFIN),Work1->WB_PARFIN,Work1->WB_LINHA)+EV_EMBARQUE))     //HVR SWB //HVR 19/04/2006 - CAMPO DA INVOICE PARA SWB OU EEQ

                  EF1->( dbSetOrder(1) )
                  EF1->( dbSeek(xFilial("EF1")+Left(TIPO_MODULO,1)+EF3->EF3_CONTRA+EF3->EF3_BAN_FI+EF3->EF3_PRACA+EF3->EF3_SEQCNT))

                                                                                            //Ex400liquida
                  EX400Liquida(EF3->EF3_CONTRA,;                                               //cContrato
                               WORK1->WB_INVOICE,;                                             //,cInvoice
                               If(!Empty(SWB->WB_PARFIN), SWB->WB_PARFIN, SWB->WB_LINHA),;     //,cParc //HVR 20/04/2006 - CAMPO PARFIN EEQ OU SWB
                               Work1->W6_HAWB,;                                                //,cPreemb
                               Work1->WB_FOBMOE,;                                              //,nValor
                               Work1->W9_MOE_FOB,;                                             //,cMoeInv
                               EF1->EF1_MOEDA,;                                                //,cMoeCont
                               "EF1",;                                                         //cAliasEF1,
                               "EF3",;                                                         //cAliasEF3,
                               "CAMB",;                                                        //cChamada,
                               TTx_Cambio,;                                                    //nTx,
                               TDt_Cambio,;                                                    //dData,
                               ,;                                                              //dDtLiq,
                               TDt_Cambio,;                                                    //dDtRealLiq,
                               If(lMulTiFil,xFilial("SWB"),Nil),;                              //cFilOri,;
                               ,;                                                              //nVlMoeAnt,
                               ,;                                                              //nVlMoeAtu,
                               ,;                                                              //nVlReaAnt,
                               ,;                                                              //nVlReaAtu,
                               TBanco,;                                                        //cBanco,
                               TAgencia,;                                                      //cAgencia,;
                               /*TRB->WB_CONTA*/EF1->EF1_NCONFI,;                              //cConta,
                               EF3->EF3_PRACA,;                                                //cPraca,
                               ,;                                                              //lBxForc,
                               WORK1->WB_FOBMOE*TTx_Cambio,;                                   //nValorRea,
                               ,;                                                              //cParcAux,
                               WORK1->WB_CA_NUM,;                                              //cNrOp,
                               ,;                                                              //nRecEF3Liq,;
                               Left(TIPO_MODULO,1),;                                           //cTpModu,
                               EF1->EF1_SEQCNT,;                                               //cSeqCon,
                               "SWB",;                                                         //cOrigem,
                               WORK1->A2_COD,;                                                 //cForn,
                               WORK1->WB_LOJA,;                                                //cLojaFo,
                               WORK1->WB_PO_DI,;                                               //cPo_Di,
                               IIF(lLiquida .And. nPos2>0,aTaxaLiq[nPos2][13],))               //nVlMoeLiq
               EndIf
            Endif
            //HVR***

            /*
            If lCposAntecip
               IF SWB->WB_PO_DI == "A" .AND. SWA->(DBSeek(xFilial("SWA")+SWB->WB_HAWB+"A"))
                  SWA->(RecLock("SWA", .F.))
                  SWA->WA_SLDANT += nPGTANT
                  SWA->(MSUnlock())
               ENDIF
            Endif
            */

            // ** GCC - 27/08/2013
            If lCposAntecip
              If SWB->WB_PO_DI == "A"
                If SWA->(DBSeek(xFilial("SWA")+SWB->WB_HAWB+"A"))
                  SWA->(RecLock("SWA", .F.))
                  SWA->WA_SLDANT += nPGTANT
                  SWA->(MSUnlock())
                EndIf
              ElseIf (SWB->WB_PO_DI == "F" .Or. SWB->WB_PO_DI == "C")
                If SWA->(DBSeek(xFilial("SWA")+SWB->WB_HAWB+SWB->WB_PO_DI))
                  SWA->(RecLock("SWA", .F.))
                  SWA->WA_SLDANT += nPGTANT
                  SWA->(MsUnlock())
                EndIf
              EndIf
            Endif
            // **

            RegToMemory("SWA")

            IF EasyEntryPoint("EICLO100")
               ExecBlock("EICLO100",.F.,.F.,IF(Bai_Est, "ANTES_GRAVA_FECHAMENTO", "ANTES_GRAVA_ESTORNO"))
            ENDIF

            //RMD - Nova legislação de câmbio
            //SVG - 31/07/09 - Troca de EECFlags p/ AvFlags (Avgeral)
            If AvFlags("CAMBIO_EXT")
               AD101GrvInv("SWB", If(Bai_Est,"M","Work1"), "IMPFFC", !Bai_Est, .T.,@lIncluiMov,@lExcluiMov)
            EndIf

            //** AAF 11/03/09 - Exclusao de titulo PA
//            If !Bai_Est .AND. (!lCposAntecip .OR. SWA->WA_PO_DI == "A" .OR. SWB->WB_TIPOREG <> "P" )
            If !Bai_Est .And. (!lCposAntecip .OR. (SWA->WA_PO_DI == "A" .Or. SWA->WA_PO_DI == "F" .Or. SWA->WA_PO_DI == "C") .OR. Left(SWB->WB_TIPOREG,1) <> "P" )	// GCC - 27/08/2013
              IF !Empty(SWB->WB_CA_TX)   .And. !Empty(SWB->WB_CA_DT) .And. !Empty(SWB->WB_BANCO) .And. ;
                !Empty(SWB->WB_AGENCIA) .And. Work1->WB_FOBMOE = SWB->WB_PGTANT
                IF Work1->WB_CA_TX   # SWB->WB_CA_TX   .Or. Work1->WB_CA_DT   # SWB->WB_CA_DT   .Or.;
                  Work1->WB_BANCO   # SWB->WB_BANCO   .Or. Work1->WB_AGENCIA # SWB->WB_AGENCIA .Or.;
                  Work1->WB_DT_DESE # SWB->WB_DT_DESE .Or. If(SWB->(FIELDPOS("WB_CONTA")) # 0,(Work1->WB_CONTA # SWB->WB_CONTA),.F.)

                  IF !EICFI400("BAIXA_TITULO","FORCA_CANCELAR_LO100")
                    Work1->(DBSKIP())
                    LOOP
                  ENDIF

                  SWB->(DBGOTO(Work1->WKREC_SWB))
                  SWB->(RecLock("SWB",.F.))

                ENDIF
              ENDIF
            EndIf
            SWB->(DBGOTO(Work1->WKREC_SWB))
            SWB->(RecLock("SWB",.F.))
            SWB->WB_NUM     := IF(Bai_Est,TAviso    ,SPACE(10))
            SWB->WB_DT      := IF(Bai_Est,TDt_Aviso ,AVCTOD(''))
            //SWB->WB_LC_NUM  := IF(Bai_Est,TLc_Num   ,SPACE(10))
            SWB->WB_BANCO   := IF(Bai_Est,TBanco    ,SPACE(4))
            SWB->WB_AGENCIA := IF(Bai_Est,TAgencia  ,SPACE(7))
            SWB->WB_CONTA   := IF(Bai_Est,TConta    ,SPACE(11))  //AOM - 19/03/2010

            //NCF - 10/06/2010 - Verifica se é parcela de adiantamento para pre-encher No. do cheque
            If (SWB->WB_PO_DI == "A" .Or. SWB->WB_PO_DI == "F" .Or. SWB->WB_PO_DI == "C")	// GCC - 27/08/2013
               nParcAd_At++

               If Len(AllTrim(cNrOp)) <= 9 .AND. nParcAd_Tt > 1
                  SWB->WB_CA_NUM := IF(Bai_Est,AllTrim(TCambio)+"-"+STRZERO(nParcAd_At,2)+"/"+STRZERO(nParcAd_Tt,2),If(Empty(SWB->WB_CA_NUM), SPACE(15), SWB->WB_CA_NUM))
               Else
                  SWB->WB_CA_NUM := IF(Bai_Est,TCambio,If(Empty(SWB->WB_CA_NUM), SPACE(15), SWB->WB_CA_NUM))
               EndIf
            Else
               SWB->WB_CA_NUM  := IF(Bai_Est,TCambio   , If(Empty(SWB->WB_CA_NUM), SPACE(15), SWB->WB_CA_NUM))
            EndIf

            SWB->WB_CA_TX   := IF(Bai_Est,TTx_Cambio,0)
            SWB->WB_CA_DT   := IF(Bai_Est,TDt_Cambio,AVCTOD(''))
            SWB->WB_CORRETO := IF(Bai_Est,TCorretor  ,SPACE(15))
            //SWB->WB_VL_CORR := IF(Bai_Est,TVl_Corr  ,0) // AST - 26/11/08
            SWB->WB_VL_CORR := IF(Bai_Est,PorcCorretor(SWB->WB_FOBMOE,,M->WB_CA_TX),0) //SVG - 12/12/08 Rateio de corretagem por processo
            /*
            IF Bai_Est
               SWB->WB_VL_CORRT:= TVl_Corr
            ELSE
               SWB->WB_VL_CORRT:= 0
            ENDIF
            */

            //SWB->WB_DESPESAT:= IF(Bai_Est,TVl_Despesa,0)
            //SWB->WB_FORMPAG := IF(Bai_Est,TDt_FormPag,SPACE(20))
            SWB->WB_DT_CONT := IF(Bai_Est,TDt_Cont   ,AVCTOD(''))
            SWB->WB_DT_DESE := IF(Bai_Est,TDt_Dese   ,AVCTOD(''))
            SWB->(MSMM(IF(EMPTY(SWB->WB_OBS),NIL,SWB->WB_OBS),35,,cOBS,1,,,"SWB","WB_OBS"))

            //** AAF 06/05/2006 - Campos novos na tela de Liquidação
            SWB->WB_NAT_CON := If(Bai_Est .AND. Empty(SWB->WB_NAT_CON),AvKey(TNatCon,"WB_NAT_CON"),Space(Len(SWB->WB_NAT_CON)))
            SWB->WB_BCO_REC := If(Bai_Est .AND. Empty(SWB->WB_BCO_REC),TBcoRec ,Space(Len(SWB->WB_BCO_REC)))
            SWB->WB_AGENREC := If(Bai_Est .AND. Empty(SWB->WB_AGENREC),TAgenRec,Space(Len(SWB->WB_AGENREC)))
            SWB->WB_CON_REC := If(Bai_Est .AND. Empty(SWB->WB_CON_REC),TConRec ,Space(Len(SWB->WB_CON_REC)))
            //**

            // ** JPM - 17/12/2009
            If EECFlags("CAMBIO_EXT") .And. Bai_Est
               SWB->WB_TIPOPAG := M->WB_TIPOPAG
               SWB->WB_EVENT   := M->WB_EVENT
            EndIf

            SWB->(DBGOTO(Work1->WKREC_SWB))
            SWA->(DBSEEK(XFILIAL()+SWB->WB_HAWB+SWB->WB_PO_DI))
            //** AAF 11/03/09 - Geracao do titulo PA
            
            If lEICFFCEAI //THTS - 23/01/2018 - Verifica se esta apto a executar FFC para ambientes EAI
                aAdd(aCambioBx,SWB->(Recno())) //Armazena o Recno da SWB para utilizar no Adapter de integracao EICAP113
            Else
                If lCposAntecip .AND. (SWA->WA_PO_DI == "A" .Or. SWA->WA_PO_DI == "F" .Or. SWA->WA_PO_DI == "C")	// GCC - 28/08/2013
                  if ! EICFI400("BAIXA_PA_LO100")
                     DisarmTransaction()
                  endif
                Else
                  if ! EICFI400("BAIXA_TIT_LO100") //HVR INTEGRAÇÃO MICROSIGA
                     DisarmTransaction()
                  endif
                EndIf
            EndIf

            IF EasyEntryPoint("EICPFFC1")
               ExecBlock("EICPFFC1",.F.,.F.,IF(Bai_Est, "FECHAMENTO", "ESTORNA"))
            EndIf

            IF EasyEntryPoint("EICLO100")
               ExecBlock("EICLO100",.F.,.F.,IF(Bai_Est, "FECHAMENTO", "ESTORNA"))    //TRP-06/06/08-Inclusão de ponto de entrada
            EndIf
            SWB->(MsUNLOCK())
         ENDIF

         If lCallSap .and. Bai_Est .and. FindFunction("AVR3FFC")             //MJB-SAP-1100 |26/05/08 - CCH - Validação para verificar se a função AVR3FFC() existe
            EasyExRdm("AVR3FFC", .F.,Bai_Est)            
         Endif                                                               

   ENDIF
   Work1->(DBSKIP())

ENDDO

If lEICFFCEAI .And. Len(aCambioBx) > 0 //THTS - 23/01/2018 - Verifica se esta apto a executar FFC para ambientes EAI
    If Bai_Est
      lRetEAI := EICAP113("SWB",aCambioBx)
    Else
      lRetEAI := EICAP114("SWB",aCambioBx)
    EndIf
    If ! lRetEAI
      DisarmTransaction()
      lDisarmTra := .T. //Se executou o DisarmTransaction, nao executa mais nada ate o Return da funcao
    EndIf
EndIf

IF !lDisarmTra .And. EasyEntryPoint("EICLO100")  // TLM 14/05/2008
   ExecBlock("EICLO100",.F.,.F.,IF(Bai_Est,"FIM_GRAVA_FECHAMENTO", "FIM_GRAVA_ESTORNO"))
ENDIF

End TransAction

//** igor chiba 29/09/09 integrando liquidação de parcelas
IF !lDisarmTra .And. LCAMBIO_EIC
   WORK1->(DBGOTOP())
   DO WHILE WORK1->(!EOF())
      IF !EMPTY(WORK1->WB_CA_DT)   //INTEGRANDO ESTORNO DE PA E CBO
         // GCC - 21/10/2013 - Tratamentos para as novas modalidades de pagamento antecipado
         IF (WORK1->WB_PO_DI  == 'A' .Or. WORK1->WB_PO_DI  == 'F' .Or. WORK1->WB_PO_DI  == 'C') 	//PA
            If !Empty(WORK1->WB_TITERP)  // PLB 15/04/10 - Verifica Existencia de Título para enviar Operação
               cChave  := cFilSWB+WORK1->WB_HAWB+WORK1->WB_INVOICE+WORK1->WB_PARCELA
               cSQLChv := "WB_FILIAL  = '"+cFilSWB          +"' AND "+;
                          "WB_HAWB    = '"+WORK1->WB_HAWB   +"' AND "+;
                          "WB_INVOICE = '"+WORK1->WB_INVOICE+"' AND "+;
                          "WB_PARCELA = '"+WORK1->WB_PARCELA+"' "
               If FindFunction("EICINTEI17")           
                  EasyExRdm("EICINTEI17", 'A','PA',cChave,'EL',cSQLChv)
               EndIf                  
            EndIf
         ELSEIF WORK1->WB_PO_DI  == 'D' //CAMBIO
            If !Empty(WORK1->WB_TITERP)  // PLB 15/04/10 - Verifica Existencia de Título para enviar Operação
               cChave:= cFilSWB+WORK1->WB_HAWB+WORK1->WB_INVOICE+WORK1->WB_LINHA
               cSQLChv := "WB_FILIAL  = '"+cFilSWB          +"' AND "+;
                          "WB_HAWB    = '"+WORK1->WB_HAWB   +"' AND "+;
                          "WB_INVOICE = '"+WORK1->WB_INVOICE+"' AND "+;
                          "WB_LINHA   = '"+WORK1->WB_LINHA  +"' "
               If FindFunction("EICINTEI17")
                  EasyExRdm("EICINTEI17", 'A','CBO',cChave,'EL',cSQLChv)
               EndIf                  
            EndIf
         ENDIF
      ELSEIF EMPTY(WORK1->WB_CA_DT)
         // GCC - 21/10/2013 - Tratamentos para as novas modalidades de pagamento antecipado
         IF (WORK1->WB_PO_DI  == 'A' .Or. WORK1->WB_PO_DI  == 'F' .Or. WORK1->WB_PO_DI  == 'C') 	//PA
            cChave:= cFilSWB+WORK1->WB_HAWB+WORK1->WB_INVOICE+WORK1->WB_PARCELA
            cSQLChv := "WB_FILIAL  = '"+cFilSWB          +"' AND "+;
                       "WB_HAWB    = '"+WORK1->WB_HAWB   +"' AND "+;
                       "WB_INVOICE = '"+WORK1->WB_INVOICE+"' AND "+;
                       "WB_PARCELA = '"+WORK1->WB_PARCELA+"' "
            If FindFunction("EICINTEI17")
               EasyExRdm("EICINTEI17", 'A','PA',cChave,'LQ',cSQLChv)
            EndIf            
         ELSEIF WORK1->WB_PO_DI  == 'D' //CAMBIO
            cChave:= cFilSWB+WORK1->WB_HAWB+WORK1->WB_INVOICE+WORK1->WB_LINHA
            cSQLChv := "WB_FILIAL  = '"+cFilSWB          +"' AND "+;
                       "WB_HAWB    = '"+WORK1->WB_HAWB   +"' AND "+;
                       "WB_INVOICE = '"+WORK1->WB_INVOICE+"' AND "+;
                       "WB_LINHA   = '"+WORK1->WB_LINHA  +"' "
            If FindFunction("EICINTEI17")           
               EasyExRdm("EICINTEI17", 'A','CBO',cChave,'LQ',cSQLChv)
            EndIf               
         ENDIF
      ENDIF
      WORK1->(DBSKIP())
   ENDDO
ENDIF
//**



If !lDisarmTra .And. lCallSap .and. Bai_Est .and. FindFunction("AVR3FFC")                   //MJB-SAP-1100 |26/05/08 - CCH - Validação para verificar se a função AVR3FFC() existe
   If FindFunction("EICINTEI17")
      EasyExRdm("AVR3FFC", .T., Bai_Est)
   EndIf      
Endif                                                                     //MJB-SAP-1100

RETURN NIL


/*//HVR 19/04/2006 - CAMPO DA INVOICE PARA SWB OU EEQ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFunção    ³LO1EstLiq() ºAutor  ³Henrique Raineire º Data ³  19/04/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Parametros  : cSeq - Sequencia do lançamento no EF3.        º±±
±±º          ³Retorno     : Lógico, sempre .T.                            º±±
±±º          ³Objetivos   : Estorno da Liquidação.                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*-----------------------------------------------------*
Function LO1EstLiq(cSeq)
*-----------------------------------------------------*
Local nOrd := EF3->(IndexOrd()), nRec := EF3->(RecNo())

cFilEF3 := xFilial("EF3")
EF3->(dbSetOrder(4))
EF3->(dbSeek(xFilial("EF3")+Left(TIPO_MODULO,1)+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+EF1->EF1_SEQCNT+cSeq))

EX400AtuSaldos("LIQ",,,"IMP")
If EF3->EF3_CODEVE == EV_LIQ_PRC
   cMotivo := EX400MotHis("FFC", EF1->EF1_CONTRA, EF1->EF1_BAN_FI, EF1->EF1_PRACA, EF1->EF1_TP_FIN, , IF(WORK1->SWBEEQ=="SWB",EF3->EF3_INVIMP,EF3->EF3_INVOIC), IF(WORK1->SWBEEQ=="SWB",EF3->EF3_LINHA,EF3->EF3_PARC), EF3->EF3_CODEVE, EF3->EF3_SEQ, TIPO_MODULO, EF1->EF1_SEQCNT, WORK1->SWBEEQ, EF3->EF3_FORN, EF3->EF3_LOJAFO, cMotivo, cFFCMot) //HVR PERGUNTAR SOMENTE UMA VEZ O MOTIVO
EndIf
EF3->(RecLock("EF3",.F.))
If !Empty(EF3->EF3_NR_CON)
   EF3->EF3_EV_EST := EF3->EF3_CODEVE
   EF3->EF3_DT_EST := dDataBase
   EF3->EF3_CODEVE := EV_ESTORNO
   EF3->EF3_NR_CON := Space(Len(EF3->EF3_NR_CON))
Else
   EF3->(dbDelete())
EndIf
EF3->(msUnlock())
EF3->(dbSkip())
EF3->(dbSetOrder(nOrd))
EF3->(dbGoTo(nRec))

Return .T.
//HVR***


*-----------------------------*
FUNCTION LO100TiraFFC(nRecno)
*-----------------------------*
SWB->(DBGOTO(nRecno))

IF EasyEntryPoint("EICLO100")
   ExecBlock("EICLO100",.F.,.F.,"ANTES_TIRA_FFC")
ENDIF

// GCC - 28/08/2013 - Tratamento para ambos os tipos de pagamentos antecipados tanto vinculado a PO (A) quanto a Fornecedor (F)
If lCposAntecip
	If SWB->WB_PO_DI == "A" .And. !Empty(SWB->WB_CA_DT)
		If SWA->(DbSeek(xFilial("SWA")+SWB->WB_HAWB+"A"))
			SWA->(RecLock("SWA", .F.))
			SWA->WA_SLDANT -= SWB->WB_PGTANT
			SWA->(MSUnlock())
		Endif
	ElseIf (SWB->WB_PO_DI == "F" .Or. SWB->WB_PO_DI == "C") .And. !Empty(SWB->WB_CA_DT)
		If SWA->(DbSeek(xFilial("SWA")+SWB->WB_HAWB+SWB->WB_PO_DI))
			SWA->(RecLock("SWA", .F.))
			SWA->WA_SLDANT -= SWB->WB_PGTANT
			SWA->(MSUnlock())
		Endif
	Endif
Endif

SWB->(RecLock("SWB",.F.))
SWB->WB_LOTE    := SPACE(7)
//SWB->WB_DT_PAG:= AVCTOD('')
SWB->WB_DT_CONT := AVCTOD('')
SWB->WB_DT_DESE := AVCTOD('')
SWB->WB_NUM     := SPACE(10)
SWB->WB_DT      := AVCTOD('')
//SWB->WB_LC_NUM  := SPACE(10)
SWB->WB_BANCO   := SPACE(4)
SWB->WB_AGENCIA := SPACE(7)
SWB->WB_CONTA   := ""
//SWB->WB_CA_NUM  := SPACE(15)
SWB->WB_CA_TX   := 0
SWB->WB_CA_DT   := AVCTOD('')
SWB->WB_CORRETO := SPACE(15)
SWB->WB_VL_CORR := 0
//SWB->WB_DESPESAT:= 0
SWB->WB_DT_CONT := AVCTOD('')
//SWB->WB_FORMPAG := SPACE(20)
SWB->(MSMM(SWB->WB_OBS,,,,2))

EICFI400("BAIXA_TIT_LO100") //HVR INTEGRAÇÃO MICROSIGA

IF EasyEntryPoint("EICPFFC1")
   ExecBlock("EICPFFC1",.F.,.F.,"TIRA_FFC")
EndIf

IF EasyEntryPoint("EICLO100")
   ExecBlock("EICLO100",.F.,.F.,"TIRA_FFC")
ENDIF

SWB->(MsUNLOCK())
RETURN NIL

*-------------------------------*
Function LO100RetWK1()
*-------------------------------*
Local nWK := 0

Work1->(DBGOTOP())
SW3->(DbSetOrder(7))//W3_FILIAL+W3_PO_NUM+STR(W3_SEQ,2)+STR(W3_NR_CONT,3)
SW7->(DBSETORDER(4))
SW8->(DBSETORDER(2))

nCont := 0
While !Work1->(EOF())
   IncProc("Por favor aguarde ...")
   nWK++
   IF nWK > MAX_COUNT
      nWK := 0
      ProcRegua(MAX_COUNT)
   ENDIF

   IF !Empty(Work1->WKFLAG)
      nCont++
      cFil := Work1->WB_FILIAL

		IF Work1->WB_TIPOREG=="P"
		   If SW2->(DBSEEK(cFil + Work1->W6_HAWB )) .And. SW3->(DBSEEK(cFil+SW2->W2_PO_NUM))

		      Do While SW3->(!Eof()) .And. SW3->W3_FILIAL+SW3->W3_PO_NUM==cFil+SW2->W2_PO_NUM

		         If (nAscan:=Ascan(aMaterial,{|a|a[3]==SW3->W3_PO_NUM+SW2->W2_DES_IPI}))==0
		            AADD(aMaterial,{Alltrim(SW3->W3_PO_NUM),SW2->W2_DES_IPI,SW3->W3_PO_NUM+SW2->W2_DES_IPI})
		         EndIf

		         If (nAscan:=Ascan(aNCM,{|a|a[3]==SW3->W3_PO_NUM+SW3->W3_TEC}))==0
		            AADD(aNCM,{Alltrim(SW3->W3_PO_NUM),SW3->W3_TEC,SW3->W3_PO_NUM+SW3->W3_TEC})
		         EndIf

		         SW3->(DbSkip())
		      EndDo
		   EndIf
		   //SW3->(DbSetOrder(1))
		Else

		   IF SW8->(DBSEEK(cFil+Work1->WB_INVOICE+Work1->A2_COD+EICRetLoja("Work1","WB_LOJA")))

		      DO WHILE SW8->(!EOF()) .AND. cFil+SW8->W8_INVOICE+SW8->W8_FORN=cFil+Work1->WB_INVOICE+Work1->A2_COD .AND. (!EICLOJA() .OR. SW8->W8_FORLOJ = Work1->WB_LOJA )

		         SW7->(DBSEEK(cFil+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM))
		         SW2->(DBSEEK(cFil+SW7->W7_PO_NUM))

		         IF (nAscan:=Ascan(aMaterial,{|a|a[3]==SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8","W8_FORLOJ")+SW2->W2_DES_IPI}))==0
		            AADD(aMaterial,{SW8->W8_INVOICE+SW8->W8_FORN,SW2->W2_DES_IPI,SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8","W8_FORLOJ")+SW2->W2_DES_IPI})
		         ENDIF

		         IF (nAscan:=Ascan(aNCM,{|a|a[3]==SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8","W8_FORLOJ")+SW7->W7_NCM}))==0
		            AADD(aNCM,{SW8->W8_INVOICE+SW8->W8_FORN,SW7->W7_NCM,SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8","W8_FORLOJ")+SW7->W7_NCM})
		         ENDIF

		         IF (nAscan:=Ascan(aPedido,{|a|a[3]==SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8","W8_FORLOJ")+SW8->W8_PO_NUM}))==0
		            AADD(aPedido,{SW8->W8_INVOICE+SW8->W8_FORN,SW8->W8_PO_NUM,SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8","W8_FORLOJ")+SW8->W8_PO_NUM})
		         ENDIF
		         SW8->(DBSKIP())
		      ENDDO
		   ENDIF
		EndIf

   Endif
   Work1->(DBSKIP())
Enddo

IF nCont == 0
   Help("", 1, "AVG0003032")//"NÆo h  registros marcado para impressÆo"###"Informação"
   Return .F.
ENDIF

Return .T.


*-------------------------------*
FUNCTION LO100Ret(TLote)
*-------------------------------*
#DEFINE FIMRET DBSELECTAREA("Work1"); Work1->(DBSETORDER(1)); Work1->(DBGOTOP()); RETURN NIL
#DEFINE COURIER_08                    oFont1
#DEFINE TIMES_NEW_ROMAN_08_NEGRITO    oFont2
#DEFINE COURIER_08_NEGRITO            oFont3
#DEFINE COURIER_10_NEGRITO            oFont4
LOCAL nLinTela:=1.6, nColS:=0.9, nColG:=6.0
Local lRet
Local oPanel
PRIVATE cAssi1:=cAssi2:=SPACE(35), nCont:=0

Processa({|lEnd| lRet := LO100RetWK1() } )

IF ! lRet
   Return .F.
Endif

Work1->(DBSETORDER(2))
Work1->(DBGOTOP())

DEFINE MSDIALOG oDlg TITLE STR0086 From 0,0 To 15, 50 OF oMainWnd //"Assinaturas para ImpressÆo"
   nOk := 0

   oPanel:=TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 0, 0)
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   @ nLinTela,nColS SAY STR0087 Of oPanel//"1§  Assinatura"
   @ nLinTela,nColG MSGET cAssi1 SIZE 95,08 OF oPanel

   nLinTela++

   @ nLinTela,nColS SAY STR0088 Of oPanel//"2§  Assinatura"
   @ nLinTela,nColG MSGET cAssi2 SIZE 95,08 OF oPanel

ACTIVATE MSDIALOG oDlg ON INIT ;
         EnchoiceBar(oDlg,{||nOk:=1,oDlg:End()},;
                          {||nOk:=0,oDlg:End()},,,,,,,.F.) CENTERED

IF nOK = 0
   FIMRET
ENDIF

AVPRINT oPrn NAME STR0089 //"Financeiro Cambio"

   DEFINE FONT oFont1  NAME "Courier New"        SIZE 0,08                  OF oPrn
   DEFINE FONT oFont2  NAME "Times New Roman"    SIZE 0,08  BOLD            OF oPrn
   DEFINE FONT oFont3  NAME "Courier New"        SIZE 0,08  BOLD            OF oPrn
   DEFINE FONT oFont4  NAME "Courier New"        SIZE 0,10  BOLD            OF oPrn

   AVPAGE
   nLin    :=99999
   cForn   :=Work1->A2_COD
   cMoeda  :=Work1->W9_MOE_FOB
   //** PLB 25/09/06
   If lWB_TP_CON
      cTpCon := Work1->WB_TP_CON
      cCaNum := Work1->WB_CA_NUM
   EndIf
   //**
   nTotFob :=nTotComag:=0
   nTotVlRS:=nTotFrete:=0
   lPriVez :=.T.

   nCol1:=050
   nCol2:=nCol1+435
   nCol3:=nCol2+240
   nCol4:=nCol3+470
   nCol5:=nCol4+240
   nCol6:=nCol5+300
   nCol7:=nCol6+170
   nCol8:=nCol7+230

   Processa({||LO100Imp(TLote)},STR0090) //"Processando FFCs..."

   oFont1:End()
   oFont2:End()
   oFont3:End()
   oFont4:End()

   AVENDPAGE

AVENDPRINT
FIMRET

*-------------------------------*
FUNCTION LO100Imp(TLote)
*-------------------------------*
LOCAL lAgfa := EasyEntryPoint("IF140CA1")
LOCAL cPictDi:=AVSX3("W6_DI_NUM",6),cPictNcm:=AVSX3("B1_POSIPI",6)
LOCAL cImport,cConPag,nDiaPag,dDataDoc,dDataEmiss,nValSWB:=0 ,nContNCM, nContPO, nContMat
Local nComag := 0 //** GFC - 01/12/05 - Utilizar o Valor da parcela de comissão ao invés do campo WB_COMAG
PRIVATE cIncoterm:=""

ProcRegua(nCont)

SW9->(DBSETORDER(1))
SW8->(DBSETORDER(1))
SW2->(DBSETORDER(1))
SW7->(DBSETORDER(1))

DO WHILE ! Work1->(EOF())
   IF EMPTY(Work1->WKFLAG)
      Work1->(DBSKIP())
      LOOP
   ENDIF

   IncProc(STR0091+Work1->W6_HAWB) //"Imprimindo Processo: "

   IF cForn # Work1->A2_COD  .OR. cMoeda # Work1->W9_MOE_FOB .OR. IIF(lWB_TP_CON,cTpCon # Work1->WB_TP_CON .OR. cCaNum # Work1->WB_CA_NUM,.F.)
      LO100Fim(TLote)
      cForn :=Work1->A2_COD
      cMoeda:=Work1->W9_MOE_FOB
      If lWB_TP_CON
         cTpCon:=Work1->WB_Tp_Con
         cCaNum:=Work1->WB_Ca_Num
      EndIf
      SA2->(DBSEEK(xFilial("SA2")+Work1->A2_COD))//Fornecedores
      SWB->(DBGOTO(Work1->WKREC_SWB))
      LO100Cab(TLote)
   ENDIF


   SWB->(DBGOTO(Work1->WKREC_SWB))
   SA2->(DBSEEK(xFilial("SA2")+Work1->A2_COD))                //Fornecedores

   IF lCposAntecip .And. SWB->WB_PO_DI == 'A' // GCC - 28/08/2013 - Tratamento para as novas modalidades de pagamento antecipado
      SW2->(MFilSEEK(Work1->W6_HAWB, SWB->WB_FILIAL))//Pedidos
      SW3->(MFilSEEK(Work1->W6_HAWB, SWB->WB_FILIAL))//Itens - Pedidos
      SB1->(dbSEEK(xFilial("SB1")+SW3->W3_COD_I ))//itens
      cImport	:= SW2->W2_IMPORT
      cConPag	:= SW2->W2_COND_PA
      nDiaPag	:= SW2->W2_DIAS_PA
      dDataDoc	:= SW2->W2_PO_DT
      dDataEmiss:= SW2->W2_DT_PRO
      cIncoterm	:= SW2->W2_INCOTER
      nValSWB	:= SWB->WB_PGTANT

   ElseIf lCposAntecip .And. (SWB->WB_PO_DI == 'C' .Or. SWB->WB_PO_DI == 'F')
      cImport	:= ""
      cConPag	:= SWB->WB_FORMPAG
      nDiaPag	:= ""
      dDataDoc  := SWB->WB_DT_REAL
      dDataEmiss:= SWB->WB_DT_REAL
      cIncoterm := ""
      nValSWB	:= SWB->WB_PGTANT

   Else
      SW9->(MFilSEEK(SWB->WB_INVOICE+SWB->WB_FORN+EICRetLoja("SWB","WB_LOJA")),SWB->WB_FILIAL)  //Invoices Capa  FMB - 10/11/04
      lEncontrouInvoice:=.f.
      Do While !SW9->(EOF()) .AND. SW9->W9_FILIAL == MultxFil("SW9",SWB->WB_FILIAL) .AND. ;
         SW9->W9_INVOICE == SWB->WB_INVOICE .AND. SW9->W9_FORN == SWB->WB_FORN .AND. (!EICLOJA() .OR. SW9->W9_FORLOJ == SWB->WB_LOJA)
         IF SW9->W9_HAWB == SWB->WB_HAWB
            lEncontrouInvoice:=.t.
            exit
         ENDIF
         SW9->(DBSKIP())
      Enddo
      IF !lEncontrouInvoice
         MSGINFO(STR0130 + ALLTRIM(SWB->WB_INVOICE) + ;
         		  STR0131 + ALLTRIM(SWB->WB_FORN) +;
         		  IF(EICLOJA(), "Loja:" + ALLTRIM(SWB->WB_LOJA),"") +;
         		  STR0132 + ALLTRIM(SWB->WB_HAWB))
         Work1->(DBSKIP())
         LOOP
		ENDIF

      SW8->(MFilSEEK(SWB->WB_HAWB+SWB->WB_INVOICE,SWB->WB_FILIAL))	//Invoices Itens
      SW2->(MFilSEEK(SW8->W8_PO_NUM,SWB->WB_FILIAL				))	//Pedidos
      SW6->(MFilSEEK(SWB->WB_HAWB,SWB->WB_FILIAL				))	//Declaracao
      SW7->(MFilSEEK(SWB->WB_HAWB,SWB->WB_FILIAL				))	//It_Declaracao
      SA4->(DbSeek  (xFilial("SA4")+SW6->W6_TRANS               ))	//Transportadores
      SB1->(DbSeek  (xFilial("SB1")+SW7->W7_COD_I				))	//itens
      cImport	:=SW6->W6_IMPORT
      cConPag  	:=SW9->W9_COND_PA
      nDiaPag	:=SW9->W9_DIAS_PA
      dDataDoc 	:=SW6->W6_DT_HAWB
      dDataEmiss:=SW9->W9_DT_EMIS
//      cIncoterm:=IF(EMPTY(SW6->W6_INCOTER),SW2->W2_INCOTER,SW6->W6_INCOTER)
      cIncoterm :=SW9->W9_INCOTER//ASR 19/10/2005
      nValSWB	:=SWB->WB_FOBMOE
   ENDIF

   SA6->(DBSEEK(xFilial("SA6")+SWB->WB_BANCO+SWB->WB_AGENCIA))//Bancos
   SYT->(DBSEEK(xFilial("SYT")+cImport))                      //Importadores
   SY6->(DBSEEK(xFilial("SY6")+cConPag+STR(nDiaPag,3,0)))//Condicoes de Pagamento
   IF EasyEntryPoint("EICLO100")
     ExecBlock("EICLO100",.F.,.F.,"QUEBRA_CABEC")
   ENDIF
   IF nLin > 2800
      LO100Cab(TLote)
   ENDIF

   oPrn:Say(nLin,nCol1,STR0092+": "+SWB->WB_INVOICE,COURIER_08_NEGRITO)  //"Fatura"
   oPrn:Say(nLin,nCol2,STR0093+" "+DTOC(dDataEmiss),COURIER_08_NEGRITO)  //"de"
   oPrn:Say(nLin,nCol3,STR0100+": "+Work1->W6_HAWB,COURIER_08_NEGRITO)   //"Processo "
   oPrn:Say(nLin,nCol4,STR0093+" "+DTOC(dDataDoc),COURIER_08_NEGRITO)    //"de"

   If Work1->WB_TIPOREG <> "P"

      oPrn:Say(nLin,nCol5,AVSX3("W6_IDENTVE",5)+":"+SW6->W6_IDENTVE,COURIER_08_NEGRITO)//EMBARCACAO

      nLin+=40

      oPrn:Say(nLin,nCol1,STR0096+": "+SW6->W6_HOUSE,COURIER_08_NEGRITO)                //"Conhec"
      oPrn:Say(nLin,nCol2,STR0093+" "+DTOC(SW6->W6_DT_HAWB),COURIER_08_NEGRITO)         //"de"
      oPrn:Say(nLin,nCol3,STR0097+": "+TRAN(SW6->W6_DI_NUM,cPictDi),COURIER_08_NEGRITO) //"D.I."
      oPrn:Say(nLin,nCol4,STR0093+" "+DTOC(SW6->W6_DTREG_D),COURIER_08_NEGRITO)         //"de"
      oPrn:Say(nLin,nCol5,AVSX3("WB_NR_ROF",5)+":"+SWB->WB_NR_ROF,COURIER_08_NEGRITO)   //"de"
   EndIf
   nLin+=40
   oPrn:Say(nLin,nCol1,STR0099+": "+SWB->WB_NUM,COURIER_08_NEGRITO)                     //"Nr. Cobr."
   nLin+=40
   oPrn:Say(nLin,nCol1,STR0098+": ",COURIER_08_NEGRITO)                                 //"Pedido"

   If Work1->WB_TIPOREG == "P"//Antecipado
      oPrn:Say(nLin,nCol1+120,Work1->W6_HAWB,COURIER_08_NEGRITO)
   ElseIf (nAscan:=Ascan(aPedido,{|a|a[1]==SWB->WB_INVOICE+SWB->WB_FORN+EICRetLoja("SWB","WB_LOJA")}) )>0
      cAuxiliar:=cControle:=""
      For nContPO:=nAscan  To Len(aPedido)
         If aPedido[nContPO][1]#SWB->WB_INVOICE+SWB->WB_FORN+EICRetLoja("SWB","WB_LOJA")
            Exit
         EndIf

         If Empty(aPedido[nContPO,2])
            Loop
         EndIf

         If Len(cAuxiliar+alltrim(aPedido[nContPO,2]))>100
           oPrn:Say(nLin,nCol1+120,cAuxiliar,COURIER_08_NEGRITO)
           nLin +=40
           cAuxiliar:=cControle:=""
           L0100Querbra()
         EndIf

         cAuxiliar+=cControle+ALLTRIM(aPedido[nContPO,2])
         oPrn:Say(nLin,nCol1+120,cAuxiliar,COURIER_08_NEGRITO)

         If Empty(cControle)
            cControle:=","
         EndIf
      Next
   EndIf
   IF(EasyEntryPoint("EICLO100"),ExecBlock("EICLO100",.F.,.F.,"APOS_PROCESSO"),)

   nLin+=40
   L0100Querbra()
   oPrn:Say(nLin,nCol1,STR0095+": ",COURIER_08_NEGRITO) //"NCM"

   If Work1->WB_TIPOREG == "P" .And. (nAscan:=Ascan(aNCM,{|a|a[1]==AllTrim(SWB->WB_HAWB)}) )>0 //Adiantamento
      cAuxiliar:=cControle:=""
      For nContNCM:=nAscan  To Len(aNCM)

         If aNCM[nContNCM][1]#Alltrim(SWB->WB_HAWB)
            Exit
         EndIf

         If Empty(aNCM[nContNCM,2])
           Loop
         EndIf

         If Len(cAuxiliar+alltrim(aNCM[nContNCM,2]))>120
           oPrn:Say(nLin,nCol1+80,cAuxiliar,COURIER_08_NEGRITO)
           nLin+=40
           cAuxiliar:=cControle:=""
           L0100Querbra()
         EndIf

         cAuxiliar+=cControle+ALLTRIM(TRANS(aNCM[nContNCM,2],cPictNcm))
         oPrn:Say(nLin,nCol1+80,cAuxiliar,COURIER_08_NEGRITO)

         If Empty(cControle)
            cControle:=","
         EndIf

      Next

   ElseIf (nAscan:=Ascan(aNCM,{|a|a[1]==SWB->WB_INVOICE+SWB->WB_FORN+EICRetLoja("SWB","WB_LOJA")}) )>0
      cAuxiliar:=cControle:=""

      For nContNCM:=nAscan  To Len(aNCM)

         If aNCM[nContNCM][1]#SWB->WB_INVOICE+SWB->WB_FORN+EICRetLoja("SWB","WB_LOJA")
            Exit
         EndIf

         If Empty(aNCM[nContNCM,2])
           Loop
         EndIf

         If Len(cAuxiliar+alltrim(aNCM[nContNCM,2]))>120
           oPrn:Say(nLin,nCol1+80,cAuxiliar,COURIER_08_NEGRITO)
           nLin+=40
           cAuxiliar:=cControle:=""
           L0100Querbra()
         EndIf

         cAuxiliar+=cControle+ALLTRIM(TRANS(aNCM[nContNCM,2],cPictNcm))
         oPrn:Say(nLin,nCol1+80,cAuxiliar,COURIER_08_NEGRITO)

        If Empty(cControle)
           cControle:=","
        EndIf

      Next
   Endif

   nLin+=40
   L0100Querbra()

   oPrn:Say(nLin,nCol1,STR0094+": ",COURIER_08_NEGRITO) //"Mercadoria"


   If Work1->WB_TIPOREG == "P" .And. (nAscan:=Ascan(aMaterial,{|a|a[1]==AllTrim(SWB->WB_HAWB)}) )>0 //Adiantamento
      cAuxiliar:=cControle:=""
      For nContMat:=nAscan  To Len(aMaterial)

        If aMaterial[nContMat][1]#Alltrim(SWB->WB_HAWB)
             Exit
          EndIf

          If Empty(aMaterial[nContMat,2])
             Loop
          EndIf

         If Len(cAuxiliar+aMaterial[nContMat,2])>120
            oPrn:Say(nLin,nCol1+185,cAuxiliar,COURIER_08_NEGRITO)
            nLin+=40
            cAuxiliar:=cControle:=""
            L0100Querbra()
         EndIf

         cAuxiliar+=cControle+(aMaterial[nContMat,2])
         oPrn:Say(nLin,nCol1+185,cAuxiliar,COURIER_08_NEGRITO)

         If Empty(cControle)
            cControle:=","
         EndIf

      Next

   ElseIf (nAscan:=Ascan(aMaterial,{|a|a[1]==SWB->WB_INVOICE+SWB->WB_FORN+EICRetLoja("SWB","WB_LOJA")}) )>0
      cAuxiliar:=cControle:=""


      For nContMat:=nAscan  To Len(aMaterial)

        If aMaterial[nContMat][1]#SWB->WB_INVOICE+SWB->WB_FORN+EICRetLoja("SWB","WB_LOJA")
           Exit
        EndIf

        If Empty(aMaterial[nContMat,2])
           Loop
        EndIf

        If Len(cAuxiliar+aMaterial[nContMat,2])>120
           oPrn:Say(nLin,nCol1+185,cAuxiliar,COURIER_08_NEGRITO)
           nLin+=40
           cAuxiliar:=cControle:=""
           L0100Querbra()
        EndIf

        cAuxiliar+=cControle+(aMaterial[nContMat,2])

        oPrn:Say(nLin,nCol1+185,cAuxiliar,COURIER_08_NEGRITO)

        If Empty(cControle)
           cControle:=","
        EndIf

      Next
   Endif

   nLin+=40
   L0100Querbra()
   
   oPrn:Say(nLin,nCol1,STR0146 + FFCTpReg(SWB->WB_TIPOREG,30), COURIER_08_NEGRITO) //""Tipo de Registro: "
   
   nLin+=40
   L0100Querbra()
//   oPrn:Say(nLin,nCol1,STR0126+SWB->WB_FORMPAG, COURIER_08_NEGRITO) //"FORMA DE PAGAMENTO:"
   oPrn:Say(nLin,nCol1,STR0126+" "+MSMM(SY6->Y6_DESC_P,48), COURIER_08_NEGRITO) //"FORMA DE PAGAMENTO:"//ASR 19/10/2005

   nLin+=40
   L0100Querbra()
   IF lAgfa
      ExecBlock("IF140CA1",.F.,.F.,"IMPRIME LOTE1")
   ELSE
     oPrn:Say(nLin,nCol1,AVSX3("W6_INCOTER",5)+": "+cIncoterm, COURIER_08_NEGRITO)//INCOTERM
     oPrn:Say(nLin,nCol2,IF(Left(SWB->WB_TIPOREG,1)#"A",cMoeda+" "+ALLTRIM(TRANS(nValSWB,cPicFobMoe)),"0,00"), COURIER_08_NEGRITO)//MOEDA E VALOR INVOICE
   ENDIF
   IF(EasyEntryPoint("EICLO100"),ExecBlock("EICLO100",.F.,.F.,"ANTES_RETIDO"),)

   //** GFC - 01/12/05 - Utilizar o Valor da parcela de comissão ao invés do campo WB_COMAG
//   If lWB_TP_CON .and. SWB->WB_TIPOREG == "1" .and. (!lCposAntecip .or. SWB->WB_PO_DI <> "A")
   If lWB_TP_CON .and. Left(SWB->WB_TIPOREG,1) == "1" .and. (!lCposAntecip .or. (SWB->WB_PO_DI <> "A" .And. SWB->WB_PO_DI <> "F" .And. SWB->WB_PO_DI <> "C"))	// GCC - 28/08/2013
      nComag := LO100Comag()
   Else
      nComag := SWB->WB_COMAG
   EndIf
   //**

   oPrn:Say(nLin,nCol4,STR0103+": "+ALLTRIM(TRANS(SWB->WB_RETIDO,cPicRetido)),COURIER_08_NEGRITO) //"Retido"
   oPrn:Say(nLin,nCol6,STR0104+": "+ALLTRIM(TRANS(nComag ,cPicComag )),COURIER_08_NEGRITO) //"Comag"
   nLin+=40
   L0100Querbra()

   cPictInland:=AVSX3("W9_INLAND",6)
   cPictPackin:=AVSX3("W9_PACKING",6)
   cPictFretei:=AVSX3("W9_FRETEIN",6)
   cPictDescon:=AVSX3("W9_DESCONT",6)

   oPrn:Say(nLin,nCol1,AVSX3("W9_INLAND" ,5)+": "+ALLTRIM(TRAN(SW9->W9_INLAND,cPictInland)),COURIER_08_NEGRITO)
   oPrn:Say(nLin,nCol2,AVSX3("W9_PACKING",5)+": "+ALLTRIM(TRAN(SW9->W9_PACKING,cPictPackin)),COURIER_08_NEGRITO)
   oPrn:Say(nLin,nCol4,AVSX3("W9_FRETEIN",5)+": "+ALLTRIM(TRAN(SW9->W9_FRETEIN,cPictFretei)),COURIER_08_NEGRITO)
   oPrn:Say(nLin,nCol6,AVSX3("W9_DESCONT",5)+": "+ALLTRIM(TRAN(SW9->W9_DESCONT,cPictDescon)),COURIER_08_NEGRITO)

   nLin+=70

   nTotFob   +=IF(Left(SWB->WB_TIPOREG,1)#"A",nValSWB,0)
   nTotVlRS  +=nValSWB
   nTotComag +=nComag
   nTotFrete +=IF(Left(SWB->WB_TIPOREG,1)=="A",nValSWB,0)

   Work1->(DBSKIP())
ENDDO
Work1->(DBSKIP(-1))
LO100Fim(TLote)
SW9->(DBSETORDER(1))                                                      //MJB-SAP-1200

RETURN NIL

*-------------------------------*
FUNCTION LO100Cab(TLote)
*-------------------------------*
Local nRecSA6 // *** CAF 21/08/1998
LOCAL dDtVen:=AVCTOD("")

IF !lPriVez
   AVNEWPAGE
ENDIF
lPriVez:=.F.
nLin   := 090

oPrn:Say( nLin    , nCol1 , SM0->M0_NOME ,COURIER_10_NEGRITO)
oPrn:Say( nLin    , 920 , STR0089,COURIER_10_NEGRITO) //"FINANCEIRO CAMBIO"
oPrn:Say( nLin    , 2100, STR0105,COURIER_10_NEGRITO,,,,1) //"FFC NR.:"
oPrn:Say( nLin    , 2102, TRANS(TLote,cPicLot), TIMES_NEW_ROMAN_08_NEGRITO)
nLin+=50
oPrn:Say( nLin    , nCol1, STR0106,COURIER_10_NEGRITO) //"FINANCAS/CAMBIO/IMPORTACAO"
oPrn:Say( nLin    , 2100, STR0107,COURIER_10_NEGRITO,,,,1) //"EMISSAO:"
oPrn:Say( nLin    , 2102, DTOC(dDataBase)+" ", TIMES_NEW_ROMAN_08_NEGRITO)
nLin+=50
oPrn:Line( nLin    ,nCol1   ,nLin  , 2240 )
oPrn:Line( nLin+1  ,nCol1-10,nLin+1, 2240 )
oPrn:Line( nLin+=10,nCol1   ,nLin  , 2240 )
oPrn:Line( nLin+1  ,nCol1-10,nLin+1, 2240 )
nLin+=20
oPrn:Say( nLin, nCol1, STR0108,COURIER_10_NEGRITO) //"OPERACAO: "
oPrn:Say( nLin, nCol1+200, STR0109  , TIMES_NEW_ROMAN_08_NEGRITO) //"COMPRA DE DIVISAS"
oPrn:Say( nLin, 975 ,STR0110, TIMES_NEW_ROMAN_08_NEGRITO) //"I M P O R T A C A O"
oPrn:Say( nLin, 2100,STR0111,COURIER_10_NEGRITO,,,,1) //"VENCIMENTO:"
IF Work1->W9_DIAS_PA # -1
   dDtVen:=Work1->WB_DT_VEN
ENDIF
oPrn:Say( nLin, 2102, DTOC(dDtVen)+" ", TIMES_NEW_ROMAN_08_NEGRITO)
nLin+=50
oPrn:Line( nLin    , nCol1, nLin  , 2240 ) ;  oPrn:Line( nLin+1,  100, nLin+1, 2240 )
oPrn:Line( nLin+=10, nCol1, nLin  , 2240 ) ;  oPrn:Line( nLin+1,  100, nLin+1, 2240 )
nLin+=30

oPrn:Say(nLin,nCol1,STR0112+" "+ALLTRIM(SA2->A2_COD)+"-"+ALLTRIM(SA2->A2_NOME),TIMES_NEW_ROMAN_08_NEGRITO) //"EXPORTADOR:"

nLin+=40

cEndereco:=ALLTRIM(SA2->A2_END)+", "+ALLTRIM(SA2->A2_NR_END)

If !Empty(SA2->A2_CEP)
cEndereco+= " - "+TRANS(SA2->A2_CEP,"@R 99999-999")
EndIf

If !Empty(SA2->A2_BAIRRO)
   cEndereco+= " - " + ALLTRIM(SA2->A2_BAIRRO)
EndIf

If !Empty(SA2->A2_ESTADO)
   cEndereco+= " - " + ALLTRIM(SA2->A2_ESTADO)
EndIf

If !Empty(SA2->A2_PAIS)
   SYA->(DbSetOrder(1))
   If SYA->(DbSeek(xFilial("SYA")+SA2->A2_PAIS))
      cEndereco+= " - " + SYA->YA_DESCR
   EndIf
EndIf

oPrn:Say(nLin,nCol1+210,cEndereco,TIMES_NEW_ROMAN_08_NEGRITO)

nLin+=40
nRecSA6 := SA6->(Recno())
SA6->(dbSeek(xFilial()+SA2->A2_BANCO+SA2->A2_AGENCIA))
oPrn:Say( nLin,nCol1, STR0113+" "+ALLTRIM(SA6->A6_COD)+"-"+ALLTRIM(SA6->A6_NOME)+STR0114+ALLTRIM(SA2->A2_NUMCON),TIMES_NEW_ROMAN_08_NEGRITO) //"REMETER PARA:"
SA6->(dbGoTo(nRecSA6))

nLin+=40
oPrn:Say(nLin,nCol1+215,STR0115+ALLTRIM(SA2->A2_SWIFT),TIMES_NEW_ROMAN_08_NEGRITO) //SWIFT: "

nLin+=70
RETURN NIL

*-----------------------*
FUNCTION LO100Fim(TLote)
*-----------------------*
LOCAL nColr1    :=090
LOCAL nColr2    :=295
LOCAL nColr3    :=865 // ATENCAO : NO RDMAKE IF140CA1 DA AGFA ESTES VALORES ESTAO FIXOS
LOCAL nColr4    :=1115
LOCAL nColr5    :=1545
LOCAL nColr6    :=1800
LOCAL nColr7    :=2225
LOCAL nTaxFobMoe:=nTaxFobMoe:=nTotVlRS*SWB->WB_CA_TX
LOCAL nColrAss1 :=820
LOCAL nColrAss2 :=1520
LOCAL nLenAssi  :=LEN(cAssi1)
LOCAL lAgfa := EasyEntryPoint("IF140CA1")
LOCAL cPictTot  :="@E 999,999,999,999.99"
nLin+=20

IF nLin > 2780
   LO100Cab(TLote)
ENDIF

oPrn:Box(nLin+1,nCol1,nLin+320,2240)
nLin+=10

oPrn:Say(nLin,nColr1,STR0027              , COURIER_08_NEGRITO) //"BANCO"
oPrn:Say(nLin,230   ,SA6->A6_NREDUZ       , COURIER_08)
oPrn:Say(nLin,950   ,STR0071              , COURIER_08_NEGRITO) //"DATA"
oPrn:Say(nLin,1060  ,DTOC(SWB->WB_DT)+" " , COURIER_08)
oPrn:Say(nLin,1300  ,STR0008              , COURIER_08_NEGRITO) //"MOEDA"
oPrn:Say(nLin,1450  ,SW9->W9_MOE_FOB+"  "+TRANS(nTotVlRS,cPictTot),  COURIER_08)
nLin+=40

oPrn:Say(nLin,nColr1,STR0076              , COURIER_08_NEGRITO) //"CORRETOR"
SYW->(dbSeek(xFilial()+SWB->WB_CORRETO))   //Corretores
oPrn:Say(nLin,300   ,SWB->WB_CORRETO+" - "+SYW->YW_NOME, COURIER_08)
oPrn:Say(nLin,950   ,STR0116              , COURIER_08_NEGRITO) //"TAXA"
oPrn:Say(nLin,1060  ,TRANS(SWB->WB_CA_TX,cPictCA_TX), COURIER_08)
nLin+=70

oPrn:Say(nLin,nColr1,STR0117              , COURIER_08_NEGRITO) //"CONDICOES:"
oPrn:Say(nLin,nColr2,STR0118              , COURIER_08_NEGRITO) //"VALOR R$.:"
oPrn:Say(nLin,nColr3-10,TRANS(nTaxFobMoe,cPictTot), COURIER_08,,,,1)
IF lAgfa
  ExecBlock("IF140CA1",.F.,.F.,"TOTAL FOB")
ELSE
   oPrn:Say(nLin,nColr3,"TOTAL "+cIncoterm+"..:" , COURIER_08_NEGRITO)
ENDIF

oPrn:Say(nLin,nColr4,cMoeda                , COURIER_08)
oPrn:Say(nLin,nColr5-15,TRANS(nTotFob   ,cPictTot), COURIER_08,,,,1)
oPrn:Say(nLin,nColr5,STR0120             , COURIER_08_NEGRITO) //"TOTAL COMAG..:"
oPrn:Say(nLin,nColr6,cMoeda                , COURIER_08)
oPrn:Say(nLin,nColr7,TRANS(nTotComag,cPictTot), COURIER_08,,,,1)
nLin+=40

oPrn:Say(nLin,nColr2,STR0121             , COURIER_08_NEGRITO) //"DESPESAS:"
oPrn:Say(nLin,nColr3-10,TRANS(SWB->WB_DESPESA,cPicDespe), COURIER_08,,,,1)
IF(lAgfa,ExecBlock("IF140CA1",.F.,.F.,"IMPRIME TOTAL"),)
nLin+=40

oPrn:Say(nLin,nColr3-10,"------------------", COURIER_08,,,,1)
IF(lAgfa,ExecBlock("IF140CA1",.F.,.F.,"TRACINHO"),)
oPrn:Say(nLin,nColr5,STR0123                , COURIER_08_NEGRITO) //"CORRETAGEM R$:"
oPrn:Say(nLin,nColr7,TRANS(SWB->WB_VL_CORR,cPicVlCor), COURIER_08,,,,1)
nLin+=40

oPrn:Say(nLin,nColr2,STR0124                , COURIER_08_NEGRITO) //"TOTAL R$:"
oPrn:Say(nLin,nColr3-10,TRANS((nTaxFobMoe+SWB->WB_DESPESA),cPictTot), COURIER_08,,,,1)

IF(lAgfa,ExecBlock("IF140CA1",.F.,.F.,"IMPRIME CIF"),)

nLin+=160

oPrn:Say(nLin,nColrAss1,REPL('-',nLenAssi), COURIER_08)
oPrn:Say(nLin,nColrAss2,REPL('-',nLenAssi), COURIER_08)
nLin+=30

oPrn:Say(nLin,nColrAss1+320,ALLTRIM(cAssi1), COURIER_08,,,,2)
oPrn:Say(nLin,nColrAss2+320,ALLTRIM(cAssi2), COURIER_08,,,,2)
nLin+=100

oPrn:Box(nLin,nCol1-25 ,nLin+200,2240)
oPrn:Line(nLin,nCol2-150,nLin+200,nCol2-150)

oPrn:Say(nLin+100,nColr1,"Importador:"+SYT->YT_COD_IMP, COURIER_08_NEGRITO)
nLin+=10
oPrn:Say(nLin,nCol2-130,"Razao Social:"+SYT->YT_NOME,COURIER_08_NEGRITO)
nLin+=75
oPrn:Say(nLin,nCol2-130,"C.N.P.J.:"+TRANS(SYT->YT_CGC,AVSX3("YT_CGC",6)),COURIER_08_NEGRITO)

nTotFob   :=0
nTotVlRS  :=0
nTotComag :=0
nTotFrete :=0

RETURN NIL

*--------------------------------*
Static Function L0100Querbra()
*--------------------------------*
IF nLin > 2800
   LO100Cab(TLote)
ENDIF
Return .T.

/*
Função      : LO100Comag()
Objetivo    : Ao invés de utilizar o campo WB_COMAG como valor da comissão do principal, deve utilizar o valor
              do registro de Comissão, vinculada a invoice e com a mesma data de vencimento.
Parametro   : -
Retorno     : Numérico. Valor da comissão.
Autor       : GFC - Gustavo Fabro da Costa Carreiro
Data        : 12/2005.
*/
*-----------------------------------------------------------------------------------------------------*
Static Function LO100Comag()
*-----------------------------------------------------------------------------------------------------*
Local nValComag:=0, nRecWB:=SWB->(RecNo()), dDtVenc:=SWB->WB_DT_VEN, nOrdWB:=SWB->(IndexOrd())
Local cHawb:=SWB->WB_HAWB, cPo_Di:=SWB->WB_PO_DI, cInvoice:=SWB->WB_INVOICE, cForn:=SWB->WB_FORN, cLoj:= ""
Local cFilWB  := SWB->WB_FILIAL
Local cFilSWB := cFilSWB:= MultxFil("SWB",cFilWB)

IF EICLOJA()
   cLoj:= SWB->WB_LOJA
ENDIF

SWB->(dbSetOrder(1))
SWB->(MFilSeek(cHawb+cPo_Di+cInvoice+cForn,cFilWB))

Do While !SWB->(EOF()) .and. SWB->WB_FILIAL== cFilSWB.and. cHawb==SWB->WB_HAWB .and.;
cPo_Di==SWB->WB_PO_DI .and. cInvoice==SWB->WB_INVOICE .and. cForn==SWB->WB_FORN .AND. (!EICLOJA() .OR. cLoj == SWB->WB_LOJA)
   If Left(SWB->WB_TIPOREG,1) == "C" .and. SWB->WB_DT_VEN == dDtVenc
      nValComag += SWB->WB_FOBMOE
   EndIf
   SWB->(dbSkip())
EndDo
SWB->(dbSetOrder(nOrdWB))
SWB->(dbGoTo(nRecWB))

Return If(nValComag=0, SWB->WB_COMAG, nValComag)

**************************************
//** AAF 09/05/2006 - Conceito Multifilial para o FFC.
**************************************
Static Function MFilSeek(cChave, cFil, aFil)
**************************************
Local lRet:= .F.
Local nInd

If ValType(cFil) == "U"
   cFil := ""
EndIf

If ValType(aFil) == "U"
   aFil := aFiliais
EndIf

If Posicione("SX2",1,Alias(),"X2_MODO") == "E"

   If Empty(cFil)

      For nInd := 1 To Len(aFil)

         If dbSeek(aFil[nInd]+cChave)
            lRet := .T.
            EXIT
         EndIf

      Next

   Else

      lRet := dbSeek(cFil+cChave)

   EndIf

Else

   lRet := dbSeek(xFilial(Alias())+cChave)

EndIf

Return lRet

**************************************
//** AAF 09/05/2006 - Conceito Multifilial para o FFC.
******************************
Static Function MultxFil(cAlias,cFil)
******************************
Local cRet

If Posicione("SX2",1,cAlias,"X2_MODO") == "E"
   cRet := cFil
Else
   cRet := xFilial(cAlias)
EndIf

Return cRet

/*
Função   :LO100F3
Autor    :Alessandro Alves Ferreira
Data     :10/05/06
Objetivo :F3 para o Numero do FFC.
*/
*--------------------------*
Function LO100F3()
*--------------------------*
Local oDlg,oGetDD,i
Local lRet      := .F.
Local cCadastro := "FFC"
Private aROTINA := {{"","",0,1}}
Private aHeader := {}
Private aCols   := {}

   cSeek  := ""
   cWhile := ""

   IF EICLOJA()
      aYesFields   := { "WB_LOTE", "WB_HAWB", "WB_FORN", "WB_LOJA", "WB_INVOICE", "WB_LINHA" }
   ELSE
      aYesFields   := { "WB_LOTE", "WB_HAWB", "WB_FORN", "WB_INVOICE", "WB_LINHA" }
   ENDIF

   bAfterHeader := { ||OrdHeader(@aHeader,aYesFields) }
   FillGetDados(4,"SWB",1,cSeek,{||&cWhile},{||.T.},,aYesFields,,,{||GrvCols()},,,,,,bAfterHeader,)

dbSelectArea("SWB")
DEFINE MSDIALOG oDlg TITLE cCadastro FROM 0,0 TO 400,800 OF oMainWnd  PIXEL

   oGetDD:= MsGetDados():New(0,000,120,220,1,"",   ,  ,.f.,      ,nil,.t.,1500,"")
   oGetDD:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT (oGetDD:oBrowse:Refresh(), EnchoiceBar(oDlg,{||lRet:= .T. , oDlg:End()},{||oDlg:End()},,)) CENTERED

If lRet
   cNrFFC := aCols[n][1]
EndIf

Return lRet

*----------------------------------------------------*
Static Function GrvCols()
*----------------------------------------------------*
Local i := 0

#IFDEF TOP
   cFils := ""
   aEval(aFiliais,{|x,y| cFils += x + iIF(y == Len(aFiliais),"'","','")})


   IF EICLOJA()
      cQuery := "Select SWB.WB_LOTE, SWB.WB_HAWB, SWB.WB_FORN, SWB.WB_LOJA, SWB.WB_INVOICE, SWB.WB_LINHA, 'SWB' AS ALIAS, SWB.R_E_C_N_O_ AS RECNO FROM "+RetSqlName("SWB")+" SWB "
   ELSE
      cQuery := "Select SWB.WB_LOTE, SWB.WB_HAWB, SWB.WB_FORN, SWB.WB_INVOICE, SWB.WB_LINHA, 'SWB' AS ALIAS, SWB.R_E_C_N_O_ AS RECNO FROM "+RetSqlName("SWB")+" SWB "
   ENDIF

   cQuery += "Where SWB.D_E_L_E_T_ <> '*' AND (SWB.WB_LOTE <> ' ' OR SWB.WB_LOTE <> '"+Space(AvSx3("WB_LOTE",3))+"') AND WB_FILIAL IN('"
   cQuery += cFils+") "

   If lEFFTpMod
      IF EICLOJA()
         cQuery += "UNION Select EEQ.EEQ_FFCIMP, EEQ.EEQ_PREEMB, EEQ.EEQ_FORN, EEQ.EEQ_FOLOJA, EEQ.EEQ_NRINVO, EEQ.EEQ_PARC, 'EEQ' AS ALIAS, EEQ.R_E_C_N_O_ AS RECNO FROM "+RetSqlName("EEQ")+" EEQ "
      ELSE
         cQuery += "UNION Select EEQ.EEQ_FFCIMP, EEQ.EEQ_PREEMB, EEQ.EEQ_FORN, EEQ.EEQ_NRINVO, EEQ.EEQ_PARC, 'EEQ' AS ALIAS, EEQ.R_E_C_N_O_ AS RECNO FROM "+RetSqlName("EEQ")+" EEQ "
      ENDIF

      cQuery += "Where EEQ.D_E_L_E_T_ <> '*' AND (EEQ.EEQ_FFCIMP <> ' ' OR EEQ.EEQ_FFCIMP <> '"+Space(AvSx3("EEQ_FFCIMP",3))+"') AND EEQ_FILIAL IN('"
      cQuery += cFils+") "
   EndIf

   cQuery := ChangeQuery(cQuery)
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.F.,.T.)

   Do While !TRB->( EoF() )
      If aScan(aCols,{|x| x[1] == TRB->WB_LOTE }) == 0
         aAdd(aCols,Array(Len(aHeader)+1))

         n := Len(aCols)

         aCols[n][1] := TRB->WB_LOTE
         aCols[n][2] := TRB->WB_HAWB
         aCols[n][3] := TRB->WB_FORN
         IF EICLOJA()
            aCols[n][4] := TRB->WB_LOJA
            aCols[n][5] := TRB->WB_INVOICE
            aCols[n][6] := TRB->WB_LINHA
            aCols[n][7] := TRB->ALIAS
            aCols[n][8] := TRB->RECNO
            aCols[n][9] := .F.
         ELSE
            aCols[n][4] := TRB->WB_INVOICE
            aCols[n][5] := TRB->WB_LINHA
            aCols[n][6] := TRB->ALIAS
            aCols[n][7] := TRB->RECNO
            aCols[n][8] := .F.
         ENDIF

         //IF EICLOJA()
           // aCols[n][9] := TRB->WB_LOJA
         //ENDIF
      EndIf

      TRB->( dbSkip() )
   EndDo

   TRB->( dbCloseArea() )
#ELSE

   For i:=1 To Len(aFiliais)

      SWB->( dbSeek(aFiliais[i]) )
      Do While !SWB->( EoF() )  .And. SWB->WB_FILIAL == aFiliais[i]
         IF Left(SWB->WB_TIPOREG,1)=="P" .OR. !EMPTY(SWB->WB_CA_DT) .OR. SWB->WB_PGTANT<>0 // Flavio pediu para nao trazer os que tiver valor antecipado
            SWB->(DBSKIP())
            LOOP
         ENDIF

         If aScan(aCols,{|x| x[1] == SWB->WB_LOTE }) == 0
            aAdd(aCols,Array(Len(aHeader)+1))

            n := Len(aCols)

            aCols[n][1] := SWB->WB_LOTE
            aCols[n][2] := SWB->WB_HAWB
            aCols[n][3] := SWB->WB_FORN
            aCols[n][4] := SWB->WB_INVOICE
            aCols[n][5] := SWB->WB_LINHA
            aCols[n][6] := "SWB"
            aCols[n][7] := SWB->( RecNo() )
            aCols[n][8] := .F.
            IF EICLOJA()
               aCols[n][9] := SWB->WB_LOJA
            ENDIF
         EndIf

         SWB->( dbSkip() )
      EndDo

   Next

#ENDIF

Return

/*
Função   :AtuTotParc
Autor    :Luiz Augusto Mota Filho
Data     :09/10/06
Objetivo :Atualizar campo de Valor Total das parcelas selecionadas
*/
*--------------------------*
Function AtuTotParc(cParam)
*--------------------------*
If cParam == "A"
	nParcSel := nParcSel + WORK1->WB_FOBMOE
  nQtdParSel++
Else
	nParcSel := nParcSel - WORK1->WB_FOBMOE
  nQtdParSel--
EndIf

oParcSel:Refresh()

Return .T.


//ISS - 27/10/10 - Função para o botão "Marca/Desmarca Todos"
*---------------------------*
Static Function MarcaTodos(oMarkAll)
*---------------------------*

Local lMark := .F.

Begin Sequence
   Work1->(DbGoTop())
   While Work1->(!EOF()) .And. !lMark
      If Work1->WKFLAG == Space(nTamFLAG)
        If lEICFFCEAI .and. nQtdParSel >= 100
          lMark := .F.
        Else
          lMark := .T.
        EndIf
      EndIf
      Work1->(DbSkip())
   EndDo
   Work1->(DbGoTop())
   If lMark
      If lEICFFCEAI //THTS - 23/01/2018
        While Work1->(!EOF()) .And. nQtdParSel < 100
          If Work1->WKFLAG == Space(nTamFLAG)
              Work1->WKFLAG := cMarca
              AtuTotParc("A") // SVG - 09/12/10 - Totalização das parcelas
          EndIf
          Work1->(DbSkip())
        EndDo
        If Work1->(!EOF()) .And. nQtdParSel = 100
          MsgInfo(STR0144, STR0142)//"O limite de parcelas selecionadas quando o ambiente está integrado ao Logix é de 100 parcelas."####"Aviso"
        EndIf
      Else   
        While Work1->(!EOF())
          If Work1->WKFLAG == Space(nTamFLAG)
              Work1->WKFLAG := cMarca
              AtuTotParc("A") // SVG - 09/12/10 - Totalização das parcelas
          EndIf
          Work1->(DbSkip())
        EndDo
      EndIf
   Else
      While Work1->(!EOF())
         If Work1->WKFLAG <> SPACE(nTamFLAG)
            Work1->WKFLAG := SPACE(nTamFLAG)
            AtuTotParc("B")// SVG - 09/12/10 - Totalização das parcelas
         EndIf
         Work1->(DbSkip())
      EndDo
   EndIf
End Sequence
Work1->(DbGoTop())

oMarkAll:oBrowse:Refresh()
oMarkAll:oBrowse:Reset()

Return lMark

/*
Função      : DoubleClik()
Objetivo    : Executa o duplo clique na marcacao dos itens na FFC
Autor       : THTS - Tiago Henrique Tudisco dos Santos
Data        : 24/01/2018
*/
Static Function DoubleClik()

If EMPTY(Work1->WB_CA_DT)
    If lEICFFCEAI //THTS - 24/01/2018 - FFC para EAI
        IF Work1->WKFLAG==cMarca
            Work1->WKFLAG := SPACE(nTamFLAG)
            AtuTotParc("B")
        Else
            If nQtdParSel < 100
                Work1->WKFLAG := cMarca
                AtuTotParc("A")
            Else
                MsgInfo(STR0144, STR0142)//"O limite de parcelas selecionadas quando o ambiente está integrado ao Logix é de 100 parcelas."####"Aviso"
            EndIf
        EndIf
    Else
        IF Work1->WKFLAG==cMarca
            Work1->WKFLAG := SPACE(nTamFLAG)
            AtuTotParc("B")
        Else
            Work1->WKFLAG := cMarca
            AtuTotParc("A")
        EndIf
    EndIf
    oMark:oBrowse:Refresh()
    oMark:oBrowse:Reset()
Else
    MsgInfo("FFC liquidado. Estorne a liquidação.")
EndIf

Return

*--------------------------------------*
Static Function FFCTpReg(cTipo,nTam)
*--------------------------------------*
Default nTam := 15
SX5->( DbSetOrder( 1 ) )
SX5->( DbSeek( xFilial()+"Y6" + cTipo ) )
RETURN Left(cTipo,1)+'-'+LEFT(X5DESCRI(),nTam)

*----------------------------------------------------------------------------*
*                        FIM DO PROGRAMA EICLO100.PRW                        *
*----------------------------------------------------------------------------*
