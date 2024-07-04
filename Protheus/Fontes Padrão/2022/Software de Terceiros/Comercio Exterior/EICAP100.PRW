//#include "Colors.ch"
//#include "FiveWin.ch"
#include "Average.ch"
#include "EICAP100.CH"
#Include "TOPCONN.CH"

#COMMAND E_RESET_AREA => SW2->(DBSETORDER(1)) ; SA5->(DBSETORDER(1)) ;
                       ; Work->(E_EraseArq(WorkFile)) ;
                       ; DBSELECTAREA(nOldArea)
#define ENTER CHR(13)+CHR(10)
#define MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)
#define FINAL_ENCHOICE MEIO_DIALOG-1
#define COLUNA_FINAL   (oDlg:nClientWidth-4)/2
#define FINAL_SELECT   (oDlg:nClientHeight-6)/2

#define VISUAL    2
#define INCLUSAO  3
#define ALTERACAO 4
#define ESTORNO   5

//** GFC - 08/03/06 - Eventos de cambio
#define PRINCIPAL    "101"
#define FRETE        "102"
#define SEGURO       "103"
#define COM_REMETER  "120"
#define COM_CTAGRAF  "121"
#define COM_ADEDUZIR "122"
#define EV_EMBARQUE  "600"
#define EV_LIQ_PRC   "630"
#define EV_ESTORNO   "999"  // PLB 18/07/06
#define TIPO_MODULO  "IMPORT"
#define ADIANT_EAI   "609" // Jacomo Lisa 25/06/2014 - Quando integrado com o Logix e for Adiantamento, não utilizar mais o codigo 101 e sim 609

// GCC - 16/08/2013 - Adiantamentos
#define ADIANT_PO	"01"
#define ADIANT_FOR	"02"
#define CREDITO		"03"

/*
Funcao      : EICAP100
Objetivos   : Ajustar o relatório para a versão 811 - Release 4
Autor       : Juliano Paulino Alves - JPA
Data 	    : 16/08/2006
Obs         :
Revisão     :
*/
***********************
Function EICAP100
***********************
lRet := EICAP100R3(.T.)
RETURN lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICAP100 ³ Autor ³ AVERAGE-VICTOR IOTTI  ³ Data ³ 16/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Manutencao de Cambio                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function EICAP100R3(p_R4)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

LOCAL i:=1, nOldArea:=SELECT()
LOCAL lPergunte := .T. //MCF - 28/12/2015
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private _PictApe := ALLTRIM(X3Picture("WR_NUM"))
Private _PictLc  := ALLTRIM(X3Picture("YH_LC_NUM"))
Private _PictPO  := ALLTRIM(X3Picture("W2_PO_NUM"))
Private lMV_EIC_EAI := EasyGParam('MV_EIC_EAI',,.F.) // Jacomo Lisa - 25/06/2014 - Integração Logix
Private cFornSA2 := Space(AVSX3("A2_COD",3)) // MCF - 17/12/2014
Private cLojaSA2 := Space(AVSX3("A2_LOJA",3)) // MCF - 17/12/2014
//**IGOR CHIBA 29/09/09 verificando se integra dados para ERP financeiro
Private LCAMBIO_EIC := AVFLAGS('AVINT_CAMBIO_EIC')

IF LCAMBIO_EIC
   //verificando se integração de cambio esta ativa
   Private  cEICFI05 := EasyGParam('MV_EICFI05',,'') //define codigo da integração de CBO
   Private lEICFI05  := .F.
   Private  cEICFI06 := EasyGParam('MV_EICFI06',,'') //define codigo da integração de INVOICE
   Private lEICFI06  := .F.
   Private  cEICFI07 := EasyGParam('MV_EICFI07',,'') //define codigo da integração de INVOICE ANTECIPADA
   Private lEICFI07  := .F.
   Private  cEICFI08 := EasyGParam('MV_EICFI08',,'') //define codigo da integração de PA
   Private lEICFI08  := .F.
   E00->(DBSETORDER(1))
   IF E00->(DBSEEK(XFILIAL('E00')+AVKEY(cEICFI05,'E00_COD') ))  .AND. E00->E00_SITUAC=='1'//esta ativo  CAMBIO
      lEICFI05:=.T.
   ENDIF
   IF E00->(DBSEEK(XFILIAL('E00')+AVKEY(cEICFI06,'E00_COD') ))  .AND. E00->E00_SITUAC=='1'//esta ativo  INVOICE
      lEICFI06:=.T.
   ENDIF
   IF E00->(DBSEEK(XFILIAL('E00')+AVKEY(cEICFI07,'E00_COD') ))  .AND. E00->E00_SITUAC=='1'//esta ativo  INV ANTECIPADA
      lEICFI07:=.T.
   ENDIF
   IF E00->(DBSEEK(XFILIAL('E00')+AVKEY(cEICFI08,'E00_COD') ))  .AND. E00->E00_SITUAC=='1'//esta ativo  PAGAMENTO ANTECIPADO
      lEICFI08:=.T.
   ENDIF
   Private lIntegStat  := EasyGParam("MV_EICFI21",,.F.)  // PLB 15/04/10 - Status de Retorno do ERP

   //DRL 31/05/2010, criacao de uma work para nao entrar no begin transaction.
   aSemSX3 := {}
   aAdd(aSemSX3, {"WK_TIPO"   , "C", 01                    ,00}) //(inclusao, alteração , exclusao)
   aAdd(aSemSX3, {"WK_FASE1"  , "C", 05                    ,00}) //(INVOICE, CAMBIO,PAGAMENTO ANTECIPADO)
   aAdd(aSemSX3, {"WK_LANCA"  , "C", 02                    ,00}) //(Tipo lançamento)
   //Campos Chave
   aAdd(aSemSX3, {"WK_FILIAL" , "C", FWSizeFilial()       , 00})
   aAdd(aSemSX3, {"WK_HAWB"   , "C", AvSx3("WB_HAWB"   ,3), 00})
   aAdd(aSemSX3, {"WK_PO_DI"  , "C", AvSx3("WB_PO_DI"  ,3), 00})
   aAdd(aSemSX3, {"WK_INVOICE", "C", AvSx3("WB_INVOICE",3), 00})
   aAdd(aSemSX3, {"WK_FORN"   , "C", AvSx3("WB_FORN"   ,3), 00})
   aAdd(aSemSX3, {"WK_LOJA"   , "C", AvSx3("WB_LOJA"   ,3), 00})
   aAdd(aSemSX3, {"WK_LINHA"  , "C", AvSx3("WB_LINHA"  ,3), 00})
   aAdd(aSemSX3, {"WK_PARCELA", "C", AvSx3("WB_PARCELA",3), 00})

   aAdd(aSemSX3, {"WK_ALIAS"  , "C",03                    , 00})
   aAdd(aSemSX3, {"WK_RECNO"  , "N",07                    , 00})

   If Select("WORK_AVINT") > 0
      WORK_AVINT->(dbCloseArea())
   EndIf

	IF EasyEntryPoint("EICAP100")
	   ExecBlock("EICAP100",.F.,.F.,"ESTRUTURA_WORK_AVINT")
	ENDIF

   cArqDBF := E_CRIATRAB(,aSemSX3,"WORK_AVINT",,.F.)

ENDIF
//**
PRIVATE aRotina := MenuDef()
Private lSair := .F.  // GFP - 05/07/2013 - Variavel para Ponto de Entrada.

PRIVATE lR4       := If(p_R4==NIL,.F.,p_R4)// .AND. FindFunction("TRepInUse") .And. TRepInUse()
PRIVATE cProcSXB   //TRP-13/05/08 Variável utilizada no retorno da consulta padrão EDP
SIX->(DBSETORDER(1))
IF SIX->(DBSEEK("SWB5")) .AND. !EasyGParam("MV_AVG0182",,.F.)
   aRotina[1,2]:="AP100Busca"
   SIX->(DBSEEK("SWA"))
   aTabIndex := {}
   DO WHILE ! SIX->(EOF()) .AND. SIX->INDICE == "SWA"
      AADD(aTabIndex,{Capital(SIX->DESCRICAO),IF("DTOS" $ UPPER(SIX->CHAVE) .OR. "DTOC" $ UPPER(SIX->CHAVE),SIX->CHAVE,SPACE(100))})
      SIX->(DBSKIP())
   ENDDO
   SIX->(DBSEEK("SWB5"))
   AADD(aTabIndex,{Capital(SIX->DESCRICAO),SPACE(100)})
ENDIF

//** GFC - 08/03/06 - Finimp
Private lWB_EVENT := SWB->( FieldPos("WB_EVENT"  ) ) > 0 .And. SWB->( FieldPos("WB_TIPOC"  ) ) > 0
Private lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .And. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .And.;
                     EF2->( FieldPos("EF2_TPMODU") ) > 0 .And. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .And.;
                     EF3->( FieldPos("EF3_TPMODU") ) > 0 .And. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .And.;
                     EF4->( FieldPos("EF4_TPMODU") ) > 0 .And. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .And.;
                     EF6->( FieldPos("EF6_SEQCNT") ) > 0 .And. EF3->( FieldPos("EF3_ORIGEM") ) > 0 .And.;
                     SWB->( FieldPos("WB_PARVIN" ) ) > 0 .And. SWB->( FieldPos("WB_ORIGEM" ) ) > 0
//Tabela de cadastro de Financiamentos.
Private lCadFin := ChkFile("EF7") .AND. ChkFile("EF8") .AND. ChkFile("EF9")
Private lEIC_EFF  := EasyGParam("MV_EIC_EFF",,.F.)
Private cTx_100, cTx_520
Private nColDel:=17, nColSeqEF3:=18, nColSeqArray:=19
Private lMultiFil := VerSenha(115) .and. Posicione("SX2",1,"EF1","X2_MODO") == "C" .and.;
                     Posicione("SX2",1,"SWB","X2_MODO") == "E" .AND. EF3->(FieldPos("EF3_FILORI")) > 0

EC6->(DbSetOrder(6))
EC6->(DbSeek(xFilial("EC6")+"FINIMP"+'100'))
cTX_100 := EC6->EC6_TXCV
EC6->(DbSeek(xFilial("EC6")+"FINIMP"+'520'))
cTX_520 := EC6->EC6_TXCV
EC6->(DbSetOrder(1))
//**

//** AAF - Funções do Financiamento
Private lPrePag := EF1->(FieldPos("EF1_CAREPR")) > 0 .and. EF1->(FieldPos("EF1_TPCAPR")) > 0 .and.;
                   EF1->(FieldPos("EF1_PARCPR")) > 0 .and. EF1->(FieldPos("EF1_PERIPR")) > 0 .and.;
                   EF1->(FieldPos("EF1_TPPEPR")) > 0 .and. EF1->(FieldPos("EF1_CAREJR")) > 0 .and.;
                   EF1->(FieldPos("EF1_TPCAJR")) > 0 .and. EF1->(FieldPos("EF1_PARCJR")) > 0 .and.;
                   EF1->(FieldPos("EF1_PERIJR")) > 0 .and. EF1->(FieldPos("EF1_TPPEJR")) > 0 .and.;
                   EF1->(FieldPos("EF1_PREPAG")) > 0 .and. EF1->(FieldPos("EF1_CLIENT")) > 0 .and.;
                   EF1->(FieldPos("EF1_CLLOJA")) > 0 .and. EF1->(FieldPos("EF1_ROF"	  )) > 0 .and.;
                   EF1->(FieldPos("EF1_INI_IR")) > 0 .and. EF1->(FieldPos("EF1_FIM_IR")) > 0 .and.;
                   EF1->(FieldPos("EF1_PERCIR")) > 0 .and. EF1->(FieldPos("EF1_REAJIR")) > 0 .and.;
                   EF3->(FieldPos("EF3_SLDLIQ")) > 0 .and. EF3->(FieldPos("EF3_LIQ_RS")) > 0 .and.;
                   EF3->(FieldPos("EF3_NROP"  )) > 0 .and. EF3->(FieldPos("EF3_EV_VIN")) > 0 .and.;
                   EF3->(FieldPos("EF3_PARVIN")) > 0 .and. EF3->(FieldPos("EF3_SLDVIN")) > 0

Private cMod    := "I"
Private lACCACE := .T.
//**

PRIVATE cDelFunc , cProcesso := " "

//** igor chiba definindo se vai ter integração dos cambios no muro do financeiro 29/09/09
IF LCAMBIO_EIC
   PRIVATE aParInv :={}
   PRIVATE aLanca  :={}
ENDIF
//**
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Determina se a despesa 101 deve ser gerada no Emb/Des ou Camb³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE _CalcDespCamb := EasyGParam("MV_CAMBIL")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := STR0006 //"Controle de Cambio"
PRIVATE TDt_AuxCont, TDt_AuxVen
PRIVATE cMarca    := GetMark(), lInverte := .F., aDeletados:={}, aEAIDeletados:= {}
PRIVATE aCampos   :={}, THouse
PRIVATE cBancoRec:=cAgeRec:=cSwift:=cConta := ""
Private bSeek :={|| SWB->(DBSEEK(xFilial()+SWA->WA_HAWB+SWA->WA_PO_DI)) }
Private bWhile:={|| xFilial("SWB") == SWB->WB_FILIAL .And.;
					SWB->WB_HAWB   == M->WA_HAWB     .And.;
					SWB->WB_PO_DI  == SWA->WA_PO_DI       }
Private bFor:={||.T.}
/*PRIVATE bSeek     :={||SWB->(DBSEEK(xFilial()+M->WA_HAWB)) }
PRIVATE bWhile    :={|| xFilial("SWB") = SWB->WB_FILIAL .AND. ;
                     SWB->WB_HAWB = M->WA_HAWB}, */

PRIVATE _OkForn:= _OkPagto:= _OkBanco:= .F., cSV, lSegundaVez:=.F.,lPrimeiraVez:=.T.//AWR

PRIVATE TDt_Ven, TFobMoe, TTipo, TabPo:= {}, TabPgi:= {}, Tab_RecDi:= {}

PRIVATE aCampoSWB:={}
    AADD(aCampoSWB,{{||TRB->(APE100_Tipo())}                             , "", STR0008					  } ) //"Tipo Reg."
    AADD(aCampoSWB,{{||TRANS(TRB->WB_LOTE,AllTrim(x3Picture("WB_LOTE")))}, "", STR0009    			  } ) //"Nr. FFC"
    AADD(aCampoSWB,{"WB_DT_CONT"                                         , "", STR0010  				  } ) //"Contratacao"
    AADD(aCampoSWB,{{||TRANS(TRB->WB_LC_NUM,_PictLc)}                    , "", STR0011   				  } ) //"L/C No."
    AADD(aCampoSWB,{"WB_DT_VEN"                                          , "", STR0012  				  } ) //"Vencto"
    AADD(aCampoSWB,{{||TRB->(APE100DTLIM(WB_DT_VEN))}                    , "", STR0013  				  } ) //"Limite"
    AADD(aCampoSWB,{"WB_CA_NUM"                                          , "", STR0014  			 	  } ) //"Cambio"
    AADD(aCampoSWB,{"WB_DT_DESE"                                         , "", STR0015  				  } ) //"Dt. Desemb"
    AADD(aCampoSWB,{"WB_MOEDA"                                           , "", STR0043  				  } ) //"Moeda"
    AADD(aCampoSWB,{{||TRANS(TRB->WB_FOBMOE,AVSX3("WB_FOBMOE" ,6))}	    ,"" , STR0016					  } ) //"Valor"
    AADD(aCampoSWB,{"WB_PGTANT"                                          ,"" , AVSX3("WB_PGTANT",5), AVSX3("WB_PGTANT",6)} ) //"Vlr Pago Ant"
    AADD(aCampoSWB,{{||TRANS(TRB->WB_CA_TX,AVSX3("WB_CA_TX",6))}         , "", STR0031  				  } ) //"Tx. Cambio"
    AADD(aCampoSWB,{{||TRANS(IIF(Left(TRB->WB_TIPOREG,1)=="P",TRB->WB_PGTANT,TRB->WB_FOBMOE)*TRB->WB_CA_TX,'@E 9,999,999,999.99')},"", STR0032 } ) //"Valor em R$"
    AADD(aCampoSWB,{"WB_CA_DT"                                           , "", AVSX3("WB_CA_DT")[5]+" "  } ) //"Liquidacao"
    AADD(aCampoSWB,{"WB_NR_ROF"                                          , "", STR0017  				  } ) //"No. ROF"
    AADD(aCampoSWB,{"WB_DT_ROF"                                          , "", STR0018  				  } ) //"Data do ROF"
    AADD(aCampoSWB,{{||TRANS(TRB->WB_NUM,_PictApe)}                      , "", STR0019  				  } ) //"Aviso Banc."
    AADD(aCampoSWB,{"WB_DT"                                              , "", STR0020  				  } ) //"Data Aviso"
    AADD(aCampoSWB,{{||TRB->(Ape_BrwBco())}                              , "", STR0030  				  } ) //"Banco/Agencia"
    
    AADD(aCampoSWB,{"WB_TIPO"                                            , "", STR0033  				  } ) //"Tipo"
    AADD(aCampoSWB,{"WB_INVOICE"                                         , "", STR0034					  } ) //"Invoices"
    AADD(aCampoSWB,{"WB_FORN"                                        	  , "", AVSX3("WB_FORN",5)		  } ) //"Fornecedor"
    AADD(aCampoSWB,{"WB_LIM_BAC"                                     	  , "", AVSX3("WB_LIM_BAC")[5]+" "} ) //"Limite CI/BACEN"
    AADD(aCampoSWB,{"WB_ENV_BAC"                                     	  , "", STR0035  				  } ) //"Envio CI/BACEN"
    AADD(aCampoSWB,{{||MEMOLINE(TRB->WB_VM_OBS,30,1)}                	  , "", STR0036  				  })

//**igor chiba INCLUINDO CAMPO TITULO ERP E TIT ERP VINCULADO
IF LCAMBIO_EIC
   AADD(aCampoSWB,{'WB_TITERP'                             , '', AVSX3("WB_TITERP" ,5)})
   AADD(aCampoSWB,{'WB_TITERPV'                            , '', AVSX3("WB_TITERPV",5)})
   AADD(aCampoSWB,{{|| BSCXBOX('WB_TITRET',TRB->WB_TITRET)}, '', AVSX3("WB_TITRET" ,5)})    // PLB 15/04/10 - Status de Retorno do ERP
ENDIF

If SWB->(FieldPos("WB_SLDELI")) > 0
   AADD(aCampoSWB,{{||TRANS(TRB->WB_SLDELI,AVSX3("WB_SLDELI" ,6))}      , "", STR0324					  }) //"Saldo Elim." // GCC - 17/01/2014 - Inclusão do campo Saldo Eliminado
EndIf
If SWB->(FieldPos("WB_SLDTRF")) > 0
   AADD(aCampoSWB,{{||TRANS(TRB->WB_SLDTRF,AVSX3("WB_SLDTRF" ,6))}      , "", AVSX3("WB_SLDTRF" ,AV_TITULO)}) //"Saldo Elim." // GCC - 17/01/2014 - Inclusão do campo Saldo Eliminado
EndIf

If SX3->(dbSetOrder(2),dbSeek("WB_CHVASS"))
   AADD(aCampoSWB,{"WB_CHVASS"                                     	  , "", AVSX3("WB_CHVASS",5)   	  }) //"Chave Pagto Associado"
EndIf

//    {"WB_PGTASS"                                     	  , "", AVSX3("WB_PGTASS",5)   	  } ,; //"Pagto Associado"

//**
//JPA - 16/08/2006 - Relatório Personalizavel - Release 4
Private oReport

EICAddLoja(aCampoSWB, "WB_LOJA", Nil , AVSX3("WB_FORN",5))
//** GFC - 08/03/06 - Campo Evento
If lWB_EVENT
   aAdd(aCampoSWB,NIL)
   aIns(aCampoSWB,1)
   aCampoSWB[1] := {"WB_EVENT", "", AVSX3("WB_EVENT",5)}

   aAdd(aCampoSWB,NIL)
   aIns(aCampoSWB,20)
   aCampoSWB[20] := {{|| BSCXBOX("WB_TIPOC",TRB->WB_TIPOC)}, "", AVSX3("WB_TIPOC",5)}
EndIf
//**
If lEffTpMod
   nPos := aScan(aCampoSWB,{|x| x[3]==STR0034})
   aAdd(aCampoSWB,NIL)
   aIns(aCampoSWB,nPos+1)
   aCampoSWB[nPos+1] := {"WB_LINHA", "", AVSX3("WB_LINHA",5)}
EndIf

Private aPos:= { 15,  1, 70, 315 }, aPos2:={15,1,140,315}
Private aCamposRel := ;
   {{{||TRB->(APE100_Tipo())}                             , "", STR0008					} ,; // "Tipo Reg."
    {{||TRANS(TRB->WB_LOTE,AllTrim(x3Picture("WB_LOTE")))}, "", STR0009					} ,; // "Nr. FFC"
    {{||TRB->WB_DT_CONT}                                  , "", STR0010					} ,; // "Contratacao"
    {{||TRANS(TRB->WB_LC_NUM,_PictLc)}                    , "", STR0011					} ,; // "L/C No."
    {{||TRB->WB_DT_VEN}                                   , "", STR0012					} ,; // "Vencto"
    {{||TRB->(APE100DTLIM(WB_DT_VEN))}                    , "", STR0013					} ,; // "Limite"
    {{||TRB->WB_CA_NUM}                                   , "", STR0014					} ,; // "Cambio"
    {{||TRB->WB_MOEDA}                                    , "", STR0043					} ,; // Moeda
    {{||TRANS(TRB->WB_FOBMOE,AVSX3("WB_FOBMOE",6))}       , "", STR0016					} ,; // "Valor"
    {{||TRB->WB_CA_DT}                                    , "", AVSX3("WB_CA_DT")[5]+" "} ,; // "Liquidacao"
    {{||TRB->WB_NR_ROF}                                   , "", STR0017					} ,; // "No. ROF"
    {{||TRB->WB_DT_ROF}                                   , "", STR0018					} ,; // "Data do ROF"
    {{||TRANS(TRB->WB_NUM,_PictApe)}                      , "", STR0019					} ,; // "Aviso Banc."
    {{||TRB->WB_DT}                                       , "", STR0020					} ,; // "Aviso Banc."
    {{||TRANS(TRB->WB_CA_TX,AVSX3("WB_CA_TX",6))}         , "", STR0031					} ,; // "Tx. Cambio"
    {{||TRANS(IIF(Left(TRB->WB_TIPOREG,1)=="P",TRB->WB_PGTANT,TRB->WB_FOBMOE)*TRB->WB_CA_TX,'@E 9,999,999,999.99')},"", STR0032 } ,; //"Valor em R$"
    {{||TRB->WB_INVOICE}                                  , "", STR0034					} } //"Invoices"

//    {{||TRB->WB_CHVASS }                                  , "", AVSX3("WB_CHVASS",5)    } ,; //"Chave Pagto Associado"
//    {{||TRB->WB_PGTASS }                                  , "", AVSX3("WB_PGTASS",5)   	}}   //"Pagto Associado"
//    {{||TRB->WB_SLDELI}                                   , "", STR0324					} ,; // "Saldo Elim." // GCC - 17/01/2014 - // GCC - 17/01/2014 - Inclusão do campo Saldo Eliminado

PRIVATE lNestle:=EasyEntryPoint("IF209FI0")
Private lExisteContabil := .F. // INTEGRA COM SIGAECO
Private aRCampos:= E_CriaRCampos(aCamposRel,"C")
Private aDados := {"TRB"  ,;
                   STR0106,; //CAMBIO/SEGURO
                   ""     ,;
                   ""     ,;
                   "G"    ,;
                   "220"  ,;
                   ""     ,;
                   ""     ,;
                   STR0106,;
                   {"Zebrado",1,"IMPORTACAO",1,2,1,"",1},;
                   "EICAP100",;
                   {{||.T.},{||.T.}}}
Private aFixo:={}
//** GFC - 18/11/05 - Câmbio de frete, seguro, comissão e embarque
Private lWB_TP_CON := SWB->(FieldPos("WB_TP_CON" )) > 0 .and. SW9->(FieldPos("W9_FORNECC")) > 0 .and.;
                      SW9->(FieldPos("W9_LOJAC"  )) > 0 .and. SW9->(FieldPos("W9_COMPV"  )) > 0 .and.;
                      SW9->(FieldPos("W9_PERCOM" )) > 0 .and. SW9->(FieldPos("W9_VALCOM" )) > 0 .and.;
                      SWB->(FieldPos("WB_TIPOCOM")) > 0 .and. SW6->(FieldPos("W6_CONDP_F")) > 0 .and.;
                      SW6->(FieldPos("W6_DIASP_F")) > 0 .and. SW6->(FieldPos("W6_CONDP_S")) > 0 .and.;
                      SW6->(FieldPos("W6_DIASP_S")) > 0 .and. SWB->(FieldPos("WB_TIPOCOM")) > 0

Private lWB_ALTERA := SWB->(FieldPos("WB_ALTERA" )) > 0

//Private lGeraPrinc  := EasyGParam("MV_CAMBPRI",,.F.)
Private lGravaFin_EIC := EasyGParam("MV_FIN_EIC",,.F.)// .AND. EasyGParam("MV_EASYFIN",,"N")<>"S"  // GFP - 02/06/2015
Private lGeraFrete    := EasyGParam("MV_CAMBFRE",,.F.)
Private lGeraSeg      := EasyGParam("MV_CAMBSEG",,.F.)
Private lGeraCom      := EasyGParam("MV_CAMBCOM",,.F.)
Private lCompAut      := EasyGParam("MV_COMPAUT",,.F.) // EOB - 03/2009 - parâmetro que indica se haverá tratamento de compensação automática no Financeiro

Private aCores :={}//BHF-22/05/09
Private cMotBxF12 := ""
/*If lWB_TP_CON
   Ap100Dicio()
EndIf*/
//**

IF EasyEntryPoint("EICAP100") //OS 0639/01 FCD
   ExecBlock("EICAP100",.F.,.F.,"CAMPO_TRB")
ENDIF

cFil:=xFilial("SWB")
DbSelectArea("SWA")
FOR i := 1 TO FCount()
    M->&(FIELDNAME(i)) := FieldGet(i)
NEXT

bSetKey:=SetKey(VK_F12)
//ASK 13/02/07 12:07 - Incluso no AtuSx do P9R1
//SX1->(DBSETORDER(1))
IF GetNewPar("MV_EASYFIN","N") = "S" //.AND. SX1->(DBSEEK("EICTMB"))
   Pergunte("EICTMB",.F.)
   cMotBxF12 := MV_PAR01
   SetKey (VK_F12,{|| Pergunte("EICTMB",.T.),cMotBxF12 := MV_PAR01})
ENDIF
//AWR - 3/6/4
bSetKeyF11:=SetKey(VK_F11)
//SX1->(DBSETORDER(1))
IF GetNewPar("MV_EASYFIN","N") = "S" //.AND. SX1->(DBSEEK("EICFI5"))
   SetKey(VK_F11,{|| lPergunte := Pergunte("EICFI5",.T.) /*,If(lPergunte,AtuEICFI5(),)*/ }) //NCF - 18/12/2017
ENDIF
//AWR - 3/6/4
SX3->(DBSETORDER(2))
lExisteContabil := IF(SX6->(DBSEEK(xFilial("SX6") + "MV_EIC_ECO")) .AND. EasyGParam("MV_EIC_ECO") == "S" .AND.;
                      SX3->(DBSEEK("WB_CONTAB")),.T.,.F.)

lCposAntecip:=.T./*EasyGParam("MV_PG_ANT",,.F.) */ // NCF - 15/05/2020 - Parametro descontinuado

Private lTemChave := SX3->(DBSeek("EF1_BAN_FI")) .and. SX3->(DBSeek("EF1_PRACA" )) .and.;
                     SX3->(DBSeek("EF2_BAN_FI")) .and. SX3->(DBSeek("EF2_PRACA" )) .and.;
                     SX3->(DBSeek("EF3_BAN_FI")) .and. SX3->(DBSeek("EF3_PRACA" )) .and.;
                     SX3->(DBSeek("EF4_BAN_FI")) .and. SX3->(DBSeek("EF4_PRACA" )) .and.;
                     SX3->(DBSeek("EF1_AGENFI")) .and. SX3->(DBSeek("EF1_NCONFI")) .and.;
                     SX3->(DBSeek("EF3_AGENFI")) .and. SX3->(DBSeek("EF3_NCONFI")) .and.;
                     SX3->(DBSeek("ECE_BANCO" )) .and. SX3->(DBSeek("ECE_PRACA" )) .and.;
                     SX3->(DBSeek("EF3_OBS"   )) .and. SX3->(DBSeek("EF3_NROP"  ))

Private cTipoProc := "" //LRS - 25/11/2016 - Variavel para salvar o tipo do processo.
Private lAdtMultFil := VerSenha(115) .and. Posicione("SX2",1,"SWA","X2_MODO") == "E" .And. Posicione("SX2",1,"SWB","X2_MODO") == "E" .AND. ; 
                                               SWA->(FieldPos("WA_FILORI")) > 0 .AND. SWB->(FieldPos("WB_FILORI")) > 0 .AND. lCposAntecip //LRS - 04/12/2017

SX3->(DBSETORDER(1))

DbSelectArea("SWB")
SWA->(E_InitVar())
aCampos:=ARRAY(FCOUNT())

If lCposAntecip
   
   If lAdtMultFil
      AADD(aCampoSWB,{"WB_FILORI",, AVSX3("WB_FILORI",5), AVSX3("WB_FILORI",6)} )
   EndIf
  
   AADD(aCampoSWB,{"WB_NUMPO" ,, AVSX3("WB_NUMPO" ,5), AVSX3("WB_NUMPO" ,6)} )
    
   aSemSx3 := {{"TRB_ALI_WT","C",03,0},; //TRP - 25/01/07 - Campos do WalkThru
               {"TRB_REC_WT","N",10,0}}

   aAdd(aSemSx3,{"W2_FORN"  , AVSX3("W2_FORN"  ,2), AVSX3("W2_FORN"  ,3),0})			// NCF - 29/04/2011 - Campo para Filtro de Fornecedores dos P.O`s de adiantamento
   aAdd(aSemSx3,{"WB_CA_NUM", AVSX3("WB_CA_NUM",2), AVSX3("WB_CA_NUM",3),0})            // GFP - 19/02/2013
    //MFR 24/04/2019 OSSME-2859  //MFR 24/04/2019 OSSME-2859
   aAdd(aSemSx3,{"WB_NUMDUP", AVSX3("WB_NUMDUP",2), AVSX3("WB_NUMDUP",3),0})

   If lAdtMultFil
      aAdd(aSemSx3,{"WB_FILORI", AVSX3("WA_FILIAL",2), AVSX3("WA_FILIAL",3),0})            //NCF - 25/09/2017
   EndIf

   aHeader:={}
   aCampos:={"WA_PO_DI", "WB_NUMPO", "W2_MOEDA", "WA_PGTANT", "WA_SLDANT", "WB_PGTANT"}	// GCC - 26/09/2013 - Incluido campo WA_PO_DI
   cFileWork1 := E_CriaTrab(,aSemSx3,"Work1")
   cFileWork2 := E_Create(,.F.)

   IF !USED()
      Help(" ",1,"E_NAOHAREA")
      RETURN .F.
   ENDIF
   IndRegua("Work1",cFileWork1+TEOrdBagExt(),"WB_NUMPO+WA_PO_DI")
   If lAdtMultFil
      IndRegua("Work1",cFileWork2+TEOrdBagExt(),"WB_FILORI+WB_NUMPO+WA_PO_DI")

      Set Index to (cFileWork1+TEOrdBagExt()),(cFileWork2+TEOrdBagExt())
   EndIf
   aHeader:={}
   aCampos:={"WB_HAWB", "W2_MOEDA", "WB_PGTANT", "WB_NUMPO", "WB_PO_DI"}         //NCF - 30/04/2018 - Incluido campo WB_PO_DI
   //** PLB 06/09/07 - Possibilitar a vinculação por Parcela de Adiantamento
   AAdd( aCampos, "WB_LINHA"  )
   AAdd( aCampos, "WB_CA_NUM" )
   //**
   aAdd(aSemSx3,{"TRB_VLVINC", AVSX3("WB_PGTANT",2), AVSX3("WB_PGTANT",3),AVSX3("WB_PGTANT",4)}) //Adiciona na work2 um campo com o saldo a vincular
   FileWork:=E_CriaTrab(,aSemSx3,"Work2")
   IF !USED()
      Help(" ",1,"E_NAOHAREA")
	  RETURN .F.
   ENDIF
   IndRegua("Work2",FileWork+TEOrdBagExt(),If(lAdtMultFil,"WB_FILORI+WB_NUMPO+WB_PO_DI","WB_NUMPO+WB_PO_DI"))

EndIf

IF(lExisteContabil,AADD(aCampoSWB,{"WB_CONTAB" , "",STR0109  } ),) //"Contabilidade

IF EasyEntryPoint("EICAP100")															// ACL - 07-02-02
   ExecBlock("EICAP100",.F.,.F.,"MBROWSE")
ENDIF

DbSelectArea("SWA")
MBrowse( 6, 1,22,75,"SWA",aFixo,,,,,aCores)//BHF-22/05/09

SetKey(VK_F12,bSetKey)
SetKey(VK_F11,bSetKeyF11)

If lCposAntecip
   Work2->(E_EraseArq(FileWork))
   Work1->(E_EraseArq(cFileWork1,cFileWork2))
Endif

DBSELECTAREA(nOldArea)

SX3->(DbSetOrder(1))

Return .T.

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 06/02/07 - 11:07
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina  := { { STR0001,"AxPesqui" ,0,1},; //"Pesquisar"
                    { STR0002,"APEMANSWA",0,2},; //"Visual"
                    { STR0003,"APEMANSWA",0,3},; //"Inclui"
                    { STR0004,"APEMANSWA",0,4},; //"Altera" //AOM - 29/01/2010
                    { STR0005,"APEMANSWA",0,5} } //"Exclui" //AOM - 29/01/2010
                    //{ STR0004,"APEMANSWA",0,4,20},; //"Altera"
                    //{ STR0005,"APEMANSWA",0,5,21} } //"Exclui"

IF AvFlags("EIC_EAI")//EasyGParam('MV_EIC_EAI',,.F.)
   AADD(aRotina, { STR0142,"APEMANSWA",0,6} ) //Liquidação
   AADD(aRotina, { STR0372,"IntTitPend",0,7} )//Integrar Títulos Pendentes
ENDIF

IF EasyGParam("MV_EASYFIN",,"N")=="S"
   AADD(aRotina, { "Config.Int.FIN","SetF11FIN",0,8} )//"Config.Int.FIN"
ENDIF

IF EasyEntryPoint("EICAP100")															// ACL - 07-02-02
   ExecBlock("EICAP100",.F.,.F.,"MBROWSE")
ENDIF

// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("IAP100MNU")
	aRotAdic := ExecBlock("IAP100MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡„o    ³APEMANUSWA ³ Autor ³ AVERAGE-VICTOR IOTTI  ³ Data ³ 15.06.98 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡„o ³ Manutencao do arquivo SWA e SWB.                            ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe e ³ APEMANUSWA(ExpC1,ExpN1,ExpN2)                               ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Parametros³ ExpC1 = Alias do arquivo                                    ³±
±±³          ³ ExpN1 = Numero do registro                                  ³±
±±³          ³ ExpN2 = Numero da Opcao (Visualizar,Incluir,Alterar,Excluir)³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso       ³ Generico                                                    ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function APEMANSWA(cAlias,nReg,nOpc)
Local lGravaOk := .T.,i, nVez, bVal_Ok
Local cAlias1:="SWB", cNomArq, oDlg, cNewTit:="", nI, lGrava:=.t.
Local lBrowse := .f.
Local aRLockList := {}		// PLB - 25/07/2006 - Variavel para Tratamento Multi-Usuario Financiamento
Local aSemSx3				// RMD - 13/11/2007 - Nova Legislação Cambial
Local nRecno := 0
Local lManipOK := .T.		// PLB - 15/04/2010 - Status de Processamento
Local lContabili :=.T.
Local lTemCambLiq:=.F.		// SVG - 17/06/2011 - Variavel que validará a exclusão.
Local lEstAdt := .F.
Local cMsgAdt := ""

Private nOpca:=0,aTela[0][0], aGets[0], nUsado:=0, PAlteracao:=.F., oObj, aHeader[0]
Private nLinhaTRB := IF(nOPC=3,0,SWA->WA_LINHA)
Private MWA_OBS:=""
Private MWB_OBS:=""
Private lLiqLogix := .F. // Jacomo Lisa - 25/06/2014
IF(nOPC == 6, (lLiqLogix := .T. ,nOPC:= 4) , )// Jacomo Lisa - 25/06/2014 - Logix: liga uma variavel de controle, e a rotina de liquidação execulta a Alteração padrão
Private nOpcSWB := nOPC
Private njafoi := 0,nPos_aRotina:=nOpc, lSair:=.f.
//ISS - 08/12/10 - Inclusão do campo WA_VM_OBS para que o mesmo possa ser alterado.
//Private aCamposSWA := {"WA_VM_OBS","WB_OBS","WA_SE_AP","WA_SE_DT","WA_SE_VEN","WA_SE_AVD","WA_SE_AVDD","WA_SE_VAL","WA_SE_FRQ"}//ASR 01/12/2005   - Jacomo lisa - 27/06/2014 Nopado
// Jacomo  27/06/2014 - Quando integrado com o logix, e estiver na rotina de liquidação [APEMANSWA(6)] não permitir alterações
Private aCamposSWA := IF(!lLiqLogix ,{"WA_VM_OBS","WB_OBS","WA_SE_AP","WA_SE_DT","WA_SE_VEN","WA_SE_AVD","WA_SE_AVDD","WA_SE_VAL","WA_SE_FRQ"}, {} )
Private lConf_Grava
//** GFC - 28/03/06
Private aVincula  := {}, aExcVinc:={}, nSeqArray := 1, aParcVinc:={}
Private aLiquida  := {}
//**
//AAF 21/11/05 - Alteração de Demurrage no Câmbio da Importação.
Private aDemurrage := {}
//BHF 06/04/2009 - Alteração para organização das parcelas de câmbio.
Private aInvVinc := {}
Private aBotoes
Private nTotPgtAnt := 0  // GFP - 19/07/2013

If lEIC_EFF  .And.  lEFFTpMod
   Private aVinList   := {}		// PLB - 25/07/06 - Variavel para tratamento multi-usuário
   Private lAumVlCont := .F.	// PLB - 25/07/06 - Variavel que verifica se o usuario aumentou o Valor do Contrato de Importacao pelas Vinculacoes
   Private aNewVlCont := {}
   Private lIsContab  := .F.    // PLB - 18/06/07 - Identifica se o Contrato de Financiamento foi Contabilizado - Usada no EFFEX400
EndIf
// SVG - 18/02/2010 -
//*** Verifica se existe o tratamento para vinculação direta de adiantamento com parcelas a pagar (1:1) para compensação automática.
Private lAdVinculado := EasyGParam("MV_COMPAUT",,.F.) .And. SWB->(FieldPos("WB_CHAVE")) > 0
//***

Private aEstComp := {}
Private aAltParc := {}    // GFP - 10/05/2013 - Variavel para AvInteg
Private lElimSaldo := .F. //LGS-02/05/2014
Private cTipAd:= ""

SWB->(DBSETORDER(1))
//**igor chiba  29/09/09 nao deixar excluir ou alterar cambios que nao tenham titulo erp
IF LCAMBIO_EIC
   aParInv:={}

   IF nPos_aRotina=5 .OR. nPos_aRotina=4 //EXCLUINDO OU ALTERANDO
      If nPos_aRotina=5  // PLB 15/04/10 - Status de Processamento
         lManipOK := .T.
      // PLB 26/04/10 Controlar alteração apenas por Parcela (SWB)
      /*
      ElseIf nPos_aRotina=4
         lManipOK := .F.
      */
      EndIf
      cFilSWB:=xfilial('SWB')
      SWB->(DBSETORDER(1))
      cProcesso := SWA->WA_HAWB
      SWB->(DBSEEK(cFilSWB+cProcesso))
      DO WHILE SWB->(!EOF()) .AND. SWB->WB_HAWB == cProcesso  .AND. SWB->WB_FILIAL == cFilSWB
         //IF EMPtY(SWB->WB_TITERP)
            //IF SWA->WA_PO_DI == 'D' .AND. lEICFI05
            //   MSGINFO('Cambio nao pode ser manipulado pois existe parcela sem titulo ERP.')
            //   RETURN .T.
            //ELSEIF  SWA->WA_PO_DI == 'A' .AND. lEICFI08  .AND.  nPos_aRotina=5
            //   MSGINFO('Pgto.Antecipado nao pode ser manipulado pois existe parcela sem titulo ERP.')
            //   RETURN .T.
            //ENDIF
         //IF IIF( lIntegStat, SWB->WB_TITRET$cNao , EMPTY(SWB->WB_TITERP) )  // PLB 15/04/10 - Status de Processamento
         IF IIF( lIntegStat, SWB->WB_TITRET$cNao , .F. )  // PLB 15/04/10 - Status de Processamento
            If nPos_aRotina=5
               lManipOK := .F.
               Exit
            EndIf
         // PLB 26/04/10 Controlar alteração apenas por Parcela (SWB)
         /*
         ELSEIF nPos_aRotina = 4  // PLB 15/04/10 - Status de Processamento
            lManipOK := .T.
            Exit
         */
         ENDIF
         SWB->(DBSKIP())
      ENDDO

      If !lManipOK  // PLB 15/04/10 - Status de Processamento
         If SWA->WA_PO_DI == 'D' .AND. lEICFI05
            MSGINFO(STR0242) //STR0242 'Cambio nao pode ser manipulado pois não houve retorno do ERP.'
            Return .T.
         ElseIF  (SWA->WA_PO_DI == 'A' .Or. SWA->WA_PO_DI == 'F' .Or. SWA->WA_PO_DI == 'C') .And. lEICFI08	// GCC - 26/08/2013 - Tratamento para as novas modalidades de pagamentos antecipados
            MSGINFO(STR0243) //STR0243 'Pgto.Antecipado nao pode ser manipulado pois não houve retorno do ERP.'
            Return .T.
         EndIf
      EndIf

   EndIf
EndIf
//**
// Jacomo Lisa - 20/08/2014 incluida a validação de exclusão
IF AvFlags("EIC_EAI") .AND. nOPC == 5 .AND.  SWA->WA_PO_DI == 'D' .And. SWB->(DBSeek(xFilial() + SWA->WA_HAWB)) //wfs jun/2017- permitir exclusão quando não houver parcelas
   MSGSTOP(STR0356, STR0079)//"Não é possivel excluir o controle de câmbio pois possui integração com o Financeiro",
   Return .F.
ENDIF

/* Permite acessar a liquidação apenas quando não houver pendências de integração para o processo. */
If AvFlags("EIC_EAI") .And. lLiqLogix .And. StatusPend(SWA->WA_HAWB)
   MsgStop(STR0357, STR0063) //"Existem pendências de integração para esse processo. Execute a rotina de integrações de títulos pendentes.", "Atenção"
   lSair:= .T.
EndIf

//LRS - Não permitir excluir Controle Câmbio sem antes excluir a invoice.
IF nOPC == 5 .AND.  SWA->WA_PO_DI == 'D' .And. SWB->(DBSeek(xFilial() + SWA->WA_HAWB)) //wfs jun/2017- permitir exclusão quando não houver parcelas
   MSGSTOP(STR0373, STR0079)//"Não é permitido a exclusão do controle de câmbio. Para realizar a exclusão deve-se excluir a invoice do processo.",
   Return .F.
ENDIF

If nOPC > 3 .AND. SWA->WA_PO_DI <> 'D' .AND. !lCposAntecip
   EasyHelp("Não é permitida manutenção de registros de pagamento antecipado pois o parametro 'MV_PG_ANT' está desligado.")
   Return .F.
EndIf

IF EasyEntryPoint("EICAP100")  // FMB - 22/10/04
	ExecBlock("EICAP100",.F.,.F.,"MANUT_SWA")
Endif

If lSair
	Return .T.
EndIf

If lCposAntecip
   Work1->(avzap())
   Work2->(avzap())
ENDIF

IF nOpc = 2 // Visual
   bVal_OK:={||oDlg:End()}
ELSEIF STR(nOpc,1)=='3' // Inclui
   bVal_OK:={||nOpca:=1,APE_GerTab(M->WA_HAWB),If(APESWALINOk(),oDlg:End(),nOpca := 0)}
ELSEIF STR(nOpc,1)=='4' //Altera
   bVal_OK:={||nOpca:=1,If(APESWALINOk(),oDlg:End(),nOpca := 0)}
ELSEIF nOpc == 5 // Deleta
   IF !AP100NAOContab(nOpc)
     bVal_OK:={||oDlg:End()}
     nVez := 0
     RETURN(nOpcA)
   ENDIF
   SWB->(dbSetorder(1))  // GFP - 29/08/2014
   SWB->(DBSEEK(xFilial("SWB") + SWA->WA_HAWB))
   DO WHILE !SWB->(eof()) .AND. SWB->WB_FILIAL==xFilial("SWB") .AND. SWB->WB_HAWB==SWA->WA_HAWB .AND. SWB->(FieldPos("WB_SLDTRF")) > 0
      If !Empty(SWB->WB_SLDTRF)  // GFP - 29/08/2014 - Não deve permitir exclusão de parcelas que possuem saldos transferidos.
         MsgStop(STR0346,STR0079)  // "Cambio não pode ser excluído, pois há saldo transferido." ### "Aviso"
         Return .F.
      EndIf
      SWB->(DbSkip())
   ENDDO
//   IF !(lCposAntecip /*.AND. LEFT(M->WA_PO_DI,1) == "A"*/)
      lSairFI400:=.F.
      lOutFI400:=.F.   //TRP- 20/03/09- Variável que retorna se o câmbio possui parcelas de adiantamento.
      EICFI400("VAL_EXCLUI")
      // SVG - 17/06/2011 - Validação da exclusão.
      If EasyGParam("MV_EASYFIN",,"N")<>"S" .AND. !AvFlags("EIC_EAI")
         cFilSWB := xFilial("SWB")
         SWB->(dbSetorder(1))
         SWB->(DBSEEK(cFilSWB + SWA->WA_HAWB))
         DO WHILE !SWB->(eof()) .AND. SWB->WB_FILIAL==cFilSWB .AND. SWB->WB_HAWB==SWA->WA_HAWB
         //TDF - 16/12/2011 - Verifica se a parcela liquidada é a mesma que esta sendo excluída.
		    IF  LEFT(SWA->WA_PO_DI,1) == LEFT(SWB->WB_PO_DI,1) .AND. !Empty(SWB->WB_CA_DT)
		       lTemCambLiq := .T.
		       EXIT
		    ENDIF
		    SWB->(dbSkip())
		 ENDDO
         If SWA->WA_PO_DI <> "C" .AND. lTemCambLiq  // GFP - 05/05/2014
            HELP("",1,"AVG0000393") //"Cambio não pode ser excluida, pois há Título Baixado"###"Informação"
            Return .F.
         EndIf
      EndIf
      IF lSairFI400 .OR. lOutFI400
         RETURN(nOpcA)
      ENDIF
  // ENDIF
   bVal_OK:={||IIF(nOpc==5 .And. !ValFin("TOT"),,(nOpca:=1,APEDEL(cAlias,cAlias1),oDlg:End()))}  // PLB 13/10/06
ENDIF

IF nOpc = 3
   lSegundaVez:=.F.
   nVez:=2
ELSE
   lSegundaVez:=.T.
   nVez:=1
ENDIF
bCampo   := { |nCPO| Field(nCPO) }

dbSelectArea(cAlias)
IF STR(nOpc,1)$'24'
   IF EasyRecCount(cAlias) == 0
      Return (.T.)
   EndIf
   dbSelectArea(cAlias1)
   dbSetOrder(1)
   dbSeek(xFilial()+SWA->WA_HAWB+SWA->WA_PO_DI)
   If EOF()
      Help(" ",1,"EICSEMIT")
//    Return .T.
   Endif
EndIf

dbSelectArea(cAlias)
FOR i := 1 TO FCount()
    IF nOpc=3
       M->&(FIELDNAME(i)) := CRIAVAR(FIELDNAME(i))
    ELSE
       M->&(EVAL(bCampo,i)) := FieldGet(i)
    ENDIF
NEXT i
DbSelectArea("SWB")
aCampos:=ARRAY(FCOUNT())
aHeader:={}
aSemSX3:= {{"TRB_GERA","L",1,0},;
           {"TRB_ALT" ,"L",8,0},;// AWR - CONTROLE /P O FINANCEIRO - 31/05/2004
           {"WB_RECNO","N",8,0}}
//RMD - 13/11/07 - Nova Legislação Cambial
//EOB - 31/07/09 - Troca de EECFlags p/ AvFlags (Avgeral)
If AvFlags("CAMBIO_EXT")
   aAdd(aSemSx3, {"WK_VALBCO", AvSx3("EYR_VALOR", AV_TIPO), AvSx3("EYR_VALOR", AV_TAMANHO), AvSx3("EYR_VALOR", AV_DECIMAL)})
EndIf
//TRP - 31/01/07 - Campos do WalkThru
AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
AADD(aSemSX3,{"TRB_REC_WT","N",10,0})
//SVG - 19/07/2010 - Verificação para campos marcados como não usados entrarem na Work
SX3->(DBSETORDER(2))
If SX3->(DBSEEK("WB_PARCELA"))
   If Ascan(aSemSX3,{|x|x[1] == "WB_PARCELA" }) = 0 .And. !X3USO(SX3->X3_USADO)
      AADD(aSemSX3,{"WB_PARCELA","C",AVSX3("WB_PARCELA",3),0})
   EndIf
EndIf
//SVG - 19/07/2010 - Verificação para campos marcados como não usados entrarem na Work
If SX3->(DBSEEK("WB_NUMDUP"))
   If Ascan(aSemSX3,{|x|x[1] == "WB_NUMDUP" }) = 0 .And. !X3USO(SX3->X3_USADO)
      AADD(aSemSX3,{"WB_NUMDUP","C",AVSX3("WB_NUMDUP",3),0})
   EndIf
EndIf
//SVG - 19/07/2010 - Nopado , verificação inclusa acima.
 /*ElseIf !X3USO(SX3->X3_USADO)//TDF 29/06/10-Verifica se o campo é usado antes de adicionar no array
      AADD(aSemSX3,{"WB_NUMDUP","C",AVSX3("WB_NUMDUP",3),0})*/

// SVG - 18/02/2010 -
//Verifica se o tratamento de adiantamento direto está habilitado para incluir campo na Work
If lAdVinculado
   AADD(aSemSX3,{"WB_CHAVE",AVSX3("WB_CHAVE",AV_TIPO),AVSX3("WB_CHAVE",AV_TAMANHO),0})
EndIf

IF LCAMBIO_EIC
   IF lCposAntecip
      AADD(aSemSX3,{"TRB_SLDANT",AVSX3("WB_FOBMOE",2),AVSX3("WB_FOBMOE",3),AVSX3("WB_FOBMOE",4)})
   ENDIF
ENDIF

If SWB->(FieldPos("WB_PGTASS")) > 0
   AADD(aSemSX3,{"WB_PGTASS",AVSX3("WB_PGTASS",2),AVSX3("WB_PGTASS",3),AVSX3("WB_PGTASS",4)})
   AADD(aSemSX3,{"WKCHVADVIN",AVSX3("WB_PGTASS",2),AVSX3("WB_PGTASS",3),AVSX3("WB_PGTASS",4)}) // NCF - 04/06/2020
EndIf

If AvFlags("EAI_PGANT_INV_NF")
   AAdd(aSemSX3, {"WB_TITADI", AvSx3("WB_TITADI", AV_TIPO), AvSx3("WB_TITADI", AV_TAMANHO), AvSx3("WB_TITADI", AV_DECIMAL)})
EndIf

aAdd(aSemSX3,{"DBDELETE","L",1,0}) //THTS - 01/11/2017 - Este campo deve sempre ser o ultimo campo da Work
cNomArq:=E_CriaTrab(cAlias1,aSemSX3) //,{"W9_MOE_FOB","C",3,0}})

IndRegua("TRB",cNomArq+TEOrdBagExt(),"WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN+WB_LOJA+WB_LINHA")

cNomArq2:=E_Create(,.F.)
//IndRegua("TRB",cNomArq2+OrdBagExt(),"WB_NUMPO")
// PLB 06/09/07 - Para pesquisa por Parcela
IndRegua("TRB",cNomArq2+TEOrdBagExt(),"WB_NUMPO+WB_LINHA")

cNomArq3:=E_Create(,.F.)
IndRegua("TRB",cNomArq3+TEOrdBagExt(),"WB_INVOICE+WB_LINHA")

cNomArq4:=E_Create(,.F.)
IndRegua("TRB",cNomArq4+TEOrdBagExt(),"WB_INVOICE+WB_ORIGEM")

cNomArq5:=E_Create(,.F.)
IndRegua("TRB",cNomArq5+TEOrdBagExt(),"WB_INVOICE+WB_PARVIN+WB_LINHA")

cNomArq6:=E_Create(,.F.)
IndRegua("TRB",cNomArq6+TEOrdBagExt(),"WB_LINHA")

SET INDEX TO (cNomArq+TEOrdBagExt()), (cNomArq2+TEOrdBagExt()), (cNomArq3+TEOrdBagExt()), (cNomArq4+TEOrdBagExt()), (cNomArq5+TEOrdBagExt()), (cNomArq6+TEOrdBagExt())

SX3->(DBSETORDER(2))

PAlteracao:=.F.
Begin Sequence
   IF nOpc=4
      PAlteracao:=.T.
      If !APE100GrTRB(cAlias1,bSeek,bFor,bWhile,nOpc)               //NCF - 20/03/09 - Adicionado a tipo de opção nos parâmetros
        //** PLB 25/07/06 - Tratamento Multi-Usuario Financiamento  //                 da função
        If lEIC_EFF  .And.  lEFFTpMod
           Break
        EndIf
        //**
      EndIf
      IF TRB->(Easyreccount("TRB")) < 1
         Help(" ",1,"EA200SEMIT")

      ENDIF
   ENDIF
   IF STR(nOpc,1)=='4'
      APE_GerTab(M->WA_HAWB)
      APE100PosGI()
      ApeVal_House(,.F.)
   ELSEIF STR(nOpc,1)$'25'
   //EOS   If ! E_GravaTRB(cAlias1,bSeek,bFor,bWhile)
     If !APE100GrTRB(cAlias1,bSeek,bFor,bWhile,nOpc)       // NCF - 20/03/09 - Adicionado a tipo de opção nos parâmetros da função
         IF STR(nOpc,1)$'2'
            Help(" ",1,"EICSEMIT")

         ENDIF
      Endif
   ENDIF
   aDeletados:={}

   If lCposAntecip .AND. (LEFT(M->WA_PO_DI,1) == "A" .Or. LEFT(M->WA_PO_DI,1) == "F" .Or. LEFT(M->WA_PO_DI,1) == "C") 	// GCC - 26/08/2013
      aCamposRel := ;
      {{{||TRB->(APE100_Tipo())}                             		 , "", STR0008 					},; // "Tipo Reg."
       {{||TRANS(TRB->WB_LOTE,AllTrim(x3Picture("WB_LOTE")))}		 , "", STR0009 					},; // "Nr. FFC"
       {{||TRB->WB_DT_CONT}                                  		 , "", STR0010 					},; // "Contratacao"
       {{||TRANS(TRB->WB_LC_NUM,_PictLc)}                	 		 , "", STR0011 					},; // "L/C No."
       {{||TRB->WB_DT_VEN}                               	 		 , "", STR0012 					},; // "Vencto"
       {{||TRB->(APE100DTLIM(WB_DT_VEN))}                	 		 , "", STR0013 					},; // "Limite"
       {{||TRB->WB_CA_NUM}                               	 		 , "", STR0014 					},; // "Cambio"
       {{||TRANS(TRB->WB_PGTANT,AVSX3("WB_PGTANT",6))}   	 		 , "", STR0016           		},; // "Valor"
       {{||TRB->WB_CA_DT}                                	 		 , "", AVSX3("WB_CA_DT")[5]+" " },; // "Liquidacao"
       {{||TRB->WB_NR_ROF}                               	 		 , "", STR0017 					},; // "No. ROF"
       {{||TRB->WB_DT_ROF}                               	 		 , "", STR0018 					},; // "Data do ROF"
       {{||TRANS(TRB->WB_NUM,_PictApe)}                  	 		 , "", STR0019 					},; // "Aviso Banc."
       {{||TRB->WB_DT}                                   	 		 , "", STR0020 					},; // "Data Aviso"
       {{||TRANS(TRB->WB_CA_TX,AVSX3("WB_CA_TX",6))}     	 		 , "", STR0031 					},; // "Tx. Cambio"
       {{||TRANS(TRB->WB_PGTANT*TRB->WB_CA_TX,'@E 9,999,999,999.99')}, "", STR0032 					},; // "Valor em R$"
       {{||TRB->WB_INVOICE}                              			 , "", STR0034 					}} // "Invoices"

       //{{||TRANS(TRB->WB_SLDELI,AVSX3("WB_SLDELI",6))}				 , "", STR0324					},; // "Saldo Elim." // GCC - 17/01/2014 - Inclusão do campo Saldo Eliminado
       //{{||TRB->WB_CHVASS}                              			 , "", "Pagto Associado"	    }}  // "Pagto Associado"
   Endif

   aRCampos:= E_CriaRCampos(aCamposRel,"C")
   nRecno:=SWA->(RECNO())

   IF lPrimeiraVez//AWR
      lPrimeiraVez:=.F.
      IF TRB->(FIELDPOS("WB_PREFIXO")) # 0
         AADD(aCampoSWB,{"WB_PREFIXO",,AVSX3("WB_PREFIXO",5),AVSX3("WB_PREFIXO",6)} )
      ENDIF
      IF TRB->(FIELDPOS("WB_NUMDUP")) # 0
         AADD(aCampoSWB,{"WB_NUMDUP" ,,AVSX3("WB_NUMDUP" ,5),AVSX3("WB_NUMDUP" ,6)} )
      ENDIF
      IF TRB->(FIELDPOS("WB_PARCELA")) # 0
         AADD(aCampoSWB,{"WB_PARCELA",,AVSX3("WB_PARCELA",5),AVSX3("WB_PARCELA",6)} )
      ENDIF
      IF TRB->(FIELDPOS("WB_TIPOTIT")) # 0
         AADD(aCampoSWB,{"WB_TIPOTIT",,AVSX3("WB_TIPOTIT",5),AVSX3("WB_TIPOTIT",6)} )
      ENDIF
      If SWB->(FieldPos("WB_DESCO")) # 0 .And. SWB->(FieldPos("WB_VLIQ")) # 0 //MCF - 19/01/2017
         AADD(aCampoSWB,{"WB_DESCO",,AVSX3("WB_DESCO",5),AVSX3("WB_DESCO",6)} )
         AADD(aCampoSWB,{"WB_VLIQ",,AVSX3("WB_VLIQ",5),AVSX3("WB_VLIQ",6)   } )
      EndIf

      If AvFlags("EAI_PGANT_INV_NF")
         AAdd(aCampoSWB, {"WB_TITADI",, AvSx3("WB_TITADI", AV_TITULO), AvSx3("WB_TITADI", AV_PICTURE)})
      EndIf
      /*IF TRB->(FIELDPOS("WB_FORN")) # 0
         AADD(aCampoSWB,{"WB_FORN"   ,,AVSX3("WB_FORN"   ,5),AVSX3("WB_FORN"   ,6)} )
      ENDIF
      IF TRB->(FIELDPOS("WB_LOJA")) # 0
         AADD(aCampoSWB,{"WB_LOJA"   ,,AVSX3("WB_LOJA"   ,5),AVSX3("WB_LOJA"   ,6)} )
      ENDIF*/
   ENDIF
   Private lExibeMsAd := .T. //Utilizada para exibir ou nao a msg de saldo de adiantamento. Utilizada pelo PE EXIBE_MSG_ADTO
   If EasyEntryPoint("EICAP100")
      ExecBlock("EICAP100",.F.,.F., "EXIBE_MSG_ADTO")
   Endif
   If lExibeMsAd .And. nOpc == 4 .And. SWA->WA_PO_DI == "D" .And. !Empty( cMsgAdt := TemAdiant())
      EECView(STR0412 + " - " + Alltrim(SWA->WA_HAWB) + ENTER + STR0413 + ENTER + ENTER + cMsgAdt,,,,,,.T.) //"Processo/PO"####"Existem valores de adiantamento disponíveis para associação."
   EndIf
   
   aCamposSWA := AddCpoUser(aCamposSWA,"SWA","1")  // GFP - 28/08/2014

   FOR nI := 1 to nVez
      WHILE .T.
           nOpca := 0

           IF nI=2
              lSegundaVez:=.T.
              If !lCposAntecip .Or. (Left(M->WA_PO_DI,1) <> "A" .And. Left(M->WA_PO_DI,1) <> "F" .And. Left(M->WA_PO_DI,1) <> "C")	// GCC - 26/08/2013
                 IF lGrava
                    ApeCalc(M->WA_HAWB)
                    IF EasyEntryPoint("EICAP100")
                      ExecBlock("EICAP100",.F.,.F.,"APOS_INCLUI_TRB")
                    Endif
                    lGrava:=.f.
                 ENDIF
              ENDIF
           ENDIF
           aBotoes:={}
           IF STR(nOpc,1) $ '2,5'
              Aadd(aBotoes,{"BMPVISUAL",{||nOpca:=2,oDlg:End()},STR0072}) //"Visualizar Parcela"
           ELSE
              IF lSegundaVez
                 IF !AvFlags("EIC_EAI") .OR. !lLiqLogix // Jacomo Lisa - 25/06/2014 | Se não tiver integrado com o Logix, abilita as seguintes funcionalidades
                    IF lContabili
                       Aadd(aBotoes,{"BMPVISUAL",{||nOpca:=3,oDlg:End()},STR0073}) //"Incluir Parcela"
                       Aadd(aBotoes,{"EDIT"     ,{||nOpca:=4,oDlg:End()},STR0399}) //"Alterar Parcela"
                       Aadd(aBotoes,{"EXCLUIR"  ,{||(nOpca:=5,lEstAdt:=.F.),oDlg:End()},STR0400}) //"Excluir Parcela"
                    Else
                       Aadd(aBotoes,{"EDIT"     ,{||nOpca:=4,oDlg:End()},STR0399}) //"Alterar Parcela"
                    ENDIF
                    IF EasyEntryPoint("EICAP100")
                   	   ExecBlock("EICAP100",.F.,.F.,"BTINCLUI")
                    ENDIF
                    Aadd(aBotoes,{"BMPVISUAL",{||nOpca:=8,oDlg:End()},STR0072}) //"Visualizar Parcela"
                    IF LCAMBIO_EIC
                       IF M->WA_PO_DI == 'D'
                          Aadd(aBotoes,{"PMSRELA",{||AP100VINPA()}, 'Vincular P.A'})
                       ENDIF
                    ENDIF
                    If lEFFTpMod .and. lEIC_EFF
                       Aadd(aBotoes,{"BAIXATIT",{|| If(AP100FieldOk("VINC")   ,AP100Vinc("INCLUIR") ,)}, STR0126}) //"Vincular Contrato"
                       Aadd(aBotoes,{"SDUERASE",{|| If(AP100FieldOk("VINCEST"),AP100Vinc("ESTORNAR"),)}, STR0128}) //"Estonar Vinculação de Contrato"
                    EndIf
                 ENDIF
                 // Jacomo Lisa - 25/06/2014  Qnd integrado com o logix, não pode liquidar e nem estornar
                 IF !AvFlags("EIC_EAI")  .OR. lLiqLogix .and. IF(AvFlags("EIC_EAI") .AND. LEFT(M->WA_PO_DI,1) == "D" .AND. !lLiqLogix ,.F.,.T.)
                    Aadd(aBotoes,{"LIQCHECK" ,{|| IF (IsVazio("TRB")        ,MSGINFO(STR0150), ApeManutSWB(6) )}, STR0143}) //"Liquidar Parcela"
                    Aadd(aBotoes,{"NOCHECKED",{|| IIF(AP100FieldOK("LIQEST"),(ApeManutSWB(7), oObj:oBrowse:Refresh()),)}, STR0144}) //"Estornar Liquidação da Parcela"
                 ENDIF

              ENDIF
           ENDIF

           // GCC - 15/01/2014 - Rotina de eliminar saldo de pagamentos antecipados
           If SWB->(FieldPos("WB_SLDELI")) > 0 .AND. Left(M->WA_PO_DI,1) $ "A,F,C" .And. STR(nOpc,1) $ "4"
              aAdd(aBotoes,{"ELIMSLDO" ,{|| AP100ElSdo("TRB")}, STR0327})
           EndIf
                                                                                      //Jacomo Lisa - Se for integrado com o Logix, não permitir pagamentos antecipados
           IF lCposAntecip .AND. lSegundaVez .AND. LEFT(M->WA_PO_DI,1) == "D" .AND. STR(nOpc,1) $ '3,4' .AND. IF(AvFlags("EIC_EAI") .AND. LEFT(M->WA_PO_DI,1) == "D"  .AND. !lLiqLogix ,.F.,.T.)
              //Aadd(aBotoes,{"POSCLI",{|| AP100POsAdto(.F., .T.) }, STR0232}) //Pagamentos Antecipados
              Aadd(aBotoes,{"POSCLI", {|| AP100POsAdto(.F., .T.,"01") }, STR0401}) //"Associar Pagamento Antecipado do PO"
              Aadd(aBotoes,{"POSCLI", {|| AP100POsAdto(.F., .T.,"02") }, STR0402}) //"Associar Adiantamento ao Fornecedor"
              If !AvFlags("EIC_EAI")
                  Aadd(aBotoes,{"POSCLI", {|| AP100POsAdto(.F., .T.,"03") }, STR0403}) //"Associar Crédito ao Fornecedor"
              EndIf
              Aadd(aBotoes,{"EXCLUIR",{|| (nOpca:=5,lEstAdt:=.T.),oDlg:End()}, STR0404}) //"Estornar Associação"
           ENDIF

           IF STR(nOpc,1) # '1'.AND. STR(nOpc,1) # '5'.AND.STR(nOpc,1) #'3'           //NCF - 11/05/09 - Modificada a posição do botão
              Aadd(aBotoes,{"S4WB010N",{|| (If (lR4 .AND. FindFunction("TRepInUse") .And. TRepInUse(),(oReport:=ReportDef(),oReport:PrintDialog()),E_Report(aDados,aRCampos))/*JPA - 17/08/2006*/) }, STR0105})
           ENDIF

           IF EasyEntryPoint("EICAP100")
              ExecBlock("EICAP100",.F.,.F.,"ALTERA_COLUNA")
           Endif

           //aDados[7]:= ALLTRIM(AVSX3("W6_HAWB",5)) + " : " + SWA->WA_HAWB
           //aDados[8]:= STR0107 + " : " + APE100_PO("T")

           oMainWnd:ReadClientCoords()
           aGets:={}
           aTela:={}
           aRotina := MenuDef()        // GFP - 24/04/2013 - Forçar carregamento do aRotina correto.

           DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0037) ; // "Aviso Bancário"
            From oMainWnd:nTop+125,oMainWnd:nLeft+5 To oMainWnd:nBottom-60,oMainWnd:nRight-10 OF oMainWnd PIXEL

           IF nI == 2 .AND. nOpc == 3
              MWA_OBS:=M->WA_VM_OBS
           ENDIF
           oEnCh1 := MsMGet():New( cAlias, nReg, nOpc, , , , , IF(nI=1.AND.nOpc=3,{15,1,FINAL_SELECT,COLUNA_FINAL},{15,1,FINAL_ENCHOICE,COLUNA_FINAL}),IF(nOpc=4, aCamposSWA, ) , 3 )	//ASR 01/12/2005 - aCamposSWA

           IF nI == 2 .AND. nOpc == 3
              M->WA_VM_OBS:=MWA_OBS
           ENDIF

           lValid:=.F.
           IF nI == 2 .OR. nOpc#3
              lBrowse := .t.
              IF(lCposAntecip,AP100GrvWork(),)
              dbSelectArea("TRB")

              lValid:=.T.

              //by GFP - 28/09/2010 :: 14:27 - Inclusão da função para carregar campos criados pelo usuario.
              aCampoSWB := AddCpoUser(aCampoSWB,"SWB","2")

              oObj:=MsSelect():New("TRB",,,aCampoSWB,@lInverte,@cMarca,{FINAL_ENCHOICE+1,1,FINAL_SELECT,COLUNA_FINAL})
              oObj:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
              IF !AvFlags("EIC_EAI") .OR. !lLiqLogix //Jacomo lisa - 27/06/2014 - Desabilita a opcao de duplo click quando estiver na rotina de liquidação (6)
                 oObj:bAval :={||IF(STR(nOpc,1)$'34',nOpca:=4,nOpca:=2),oDlg:End()}//ApeManutSWB(4),ApeManutSWB(2))}
              ENDIF
              oObj:oBrowse:bwhen :={||(dbSelectArea("TRB"),.t.)}
           ENDIF
           oEnCh1:oBox:Align := iif(lBrowse, CONTROL_ALIGN_TOP, CONTROL_ALIGN_ALLCLIENT) //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
           oDlg:lMaximized := .T.
           ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bVal_OK,{||oDlg:End()},,aBotoes),if(nI == 2 .OR. nOpc#3,oObj:oBrowse:Refresh(),)) //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

		   IF LEFT(M->WA_PO_DI,1) == "F" .AND. nOpca == 1 //MCF - 17/12/2014
		   	     IF !NaoVazio(M->WA_HAWB)
		   	     	LOOP
		   	     ELSEIF Empty(TRB->WB_FORN)
		   	     	nForn := AP100Forn()
		   	     	IF nForn == 0
           				LOOP
           			ENDIF
           		 ENDIF
           ENDIF

           //** PLB 25/07/06 - Tratamento Multi-Usuario Financiamento
           If lEIC_EFF  .And.  lEFFTpMod
              aRLockList := SWB->( DBRLockList() )
              For i := 1  to  Len(aRLockList)
                 SWB->( DBGoTo(aRLockList[i]) )
                 SWB->( MSUnLock() )
              Next i
              aRLockList := EF1->( DBRLockList() )
              For i := 1  to  Len(aRLockList)
                 EF1->( DBGoTo(aRLockList[i]) )
                 EF1->( MSUnLock() )
              Next i
           EndIf
           //**
           //** PLB 25/07/06 - Tratamento Multi-Usuario Financiamento
           If lEIC_EFF  .And.  lEFFTpMod  .And.  lAumVlCont
              If nOpca == 1
                 AP100VlCnt("EFETIVA")
              EndIf
              aNewVlCont := {}
              lAumVlCont := .F.
           EndIf
           //**

           IF nOpc == 3 .AND. nOpca == 1
              IF !ApeVal_House(M->WA_HAWB,.T.)
                 LOOP
              ENDIF
           ENDIF
           IF STR(nOpca,1) $ "2,3,4,5,6,7,8"
              ApeManutSWB(nOpca,lEstAdt)
              LOOP
           ENDIF

           IF nOpcA == 0
              nI:=2
              EXIT
           ENDIF

           If nOpcA == 1 .AND. lSegundaVez
              IF STR(nOpc,1)$'34'
                 If !Obrigatorio(aGets,aTela)
                    Loop
                 Endif
              Endif

              if EasyGParam("MV_EASYFIN",,"N") == "S"    // Jonato em 11 de Agosto de 2004
                 if select("__SE2") == 0            // Essa rotina foi inclusa para não dar erro qdo ADS, dentro do FINA080
                    chkfile("SE2",.F.,"__SE2")
                 else
                    dbselectarea("__SE2")
                 endif
              endif

              IF nOpc=3
                 If LCAMBIO_EIC
                    WORK_AVINT->(avzap())
                 EndIF
                 Begin Transaction
                    //JAP - 10/08/06
                    lConf_Grava := .T.
                    IF EasyEntryPoint("EICAP100")
                       ExecBlock("EICAP100",.F.,.F.,"CONF_GRAVA")
                    ENDIF
                    IF lConf_Grava
                       Processa({||lGravaOk := APE100Grava(cAlias,cAlias1)})
                       If !lGravaOk
                          //Help(" ",1,"A110NAORE")
                          DisarmTransaction()
                       Else
                      //Processa Gatilhos
   //                    EvalTrigger()
   //                      If __lSX8
   //                          ConfirmSX8()
   //                      Endif
                       EndIf
   	   			  ENDIF
                 End Transaction
                 IF !lConf_Grava .Or. !lGravaOk
                    Loop
                 ENDIF
                 If LCAMBIO_EIC //DRL - 02/06/10, Caso Seja Pelo AvInteg
                    GravaInte17()
                 EndIf
              ELSEIF nOpc=4
                 If LCAMBIO_EIC
                    WORK_AVINT->(avzap())
                 EndIF

                 /* WFS 10/12/2014 - Quando habilitada a integração com o LOGIX, a função APE100GRAVA() é chamada da função INTAP110(),
                  duplicando o registro referente ao adiantamento usado para realização da compensação.*/
                 If !AvFlags("EIC_EAI") .Or. !lLiqLogix
                    
                    aNumPos:= {}
                    Begin TransAction
                       SWA->(DBGOTO(nRecno))
                       Processa({|| lGravaOk:= APE100Grava(cAlias,cAlias1)})
                       If(!lGravaOk)
                            DisarmTransaction()
                       EndIf
                    End TransAction

                    If !lGravaOk
                        Loop
                    EndIf
                   
                    //wfs - quando for integração via mensagem única, executar a atualização fora do controlde de transações.
                    If AvFlags("EIC_EAI")
                       RefazProv()
                    EndIf

                 EndIf

                 //
                 If LCAMBIO_EIC //DRL - 02/06/10, Caso exista a integração pelo AvInteg...
                    GravaInte17()
                 EndIf
                 //
              ENDIF
   ////    ElseIf __lSX8 .AND. lSegundaVez .AND. nOpc=3
   ////       RollBackSX8()  // Verificar com Wagner (MS) se e necessario
           Endif
         Exit
      END
   NEXT
End Sequence
IF EasyEntryPoint("EICAP100")
  ExecBlock("EICAP100",.F.,.F.,"APOS_GRAVA")
ENDIF

aAltParc := {} // GFP - 10/05/2013
lSegundaVez:=.F.

IF lCposAntecip
   TRB->(E_EraseArq(cNomArq,cNomArq2))
ELSE
   TRB->(E_EraseArq(cNomArq))
ENDIF

dbSelectArea(cAlias)

//RRC - 29/11/2013 - Integração SIGAEIC x SIGAESS relativo a despesas
 //MFR 03/12/2019 OSSME-4024
If nOpca == 1 .And. AvFlags("CONTROLE_SERVICOS_AQUISICAO") .And. EasyGParam("MV_ESS0022",,.T.) .And. SWD->(FieldPos("WD_MOEDA")) > 0 ;
   .And. SWD->(FieldPos("WD_VL_MOE")) > 0 .And. SWD->(FieldPos("WD_TX_MOE")) > 0 .And. Left(M->WA_PO_DI,1) == "D"
   DI500ESS(SWA->WA_HAWB,ALTERAR)
EndIf

If SWA->(Eof() .Or. Bof())
   SWA->(DbGoTop())
EndIf

Return( nOpcA )

*------------------------------*
FUNCTION APEDEL(cAlias,cAlias1)
*------------------------------*
LOCAL nCnt, lTemFFC:=.F.,cChaveSWB:=xFilial("SWB")+SWA->WA_HAWB+SWA->WA_PO_DI          //MJB-SAP-1100
LOCAL nRecSWA:=SWA->(RECNO()), i
Local cProcesso:=""
Local aOrdRec := {}, aRegsDel := {}  // GFP - 06/05/2014

If Type("lCambio_eic") <> "L"
   lCambio_eic:= AVFLAGS("AVINT_CAMBIO_EIC")
EndIf


SWB->(dbSeek(cChaveSWB))
DO While !SWB->(Eof()) .And. SWB->(WB_FILIAL+WB_HAWB)+SWB->WB_PO_DI == cChaveSWB            //MJB-SAP-1100
    If ! Empty(SWB->WB_LOTE)                                              //MJB-SAP-1100
       lTemFFC:=.T.                                                       //MJB-SAP-1100
       Exit                                                               //MJB-SAP-1100
    Endif                                                                 //MJB-SAP-1100
    SWB->(DbSkip())                                                       //MJB-SAP-1100
Enddo                                                                     //MJB-SAP-1100

If lTemFFC                                                                //MJB-SAP-1100
   Help("", 1, "AVG0000176")                                              //MJB-SAP-1100
   RETURN .T.
Endif                                                                     //MJB-SAP-1100

IF !MsgYesNo(STR0038,STR0039)//"Confirma Exclusão ?"###"Excluir"
   RETURN .T.
ENDIF

If LCAMBIO_EIC //DRL 02/06/10
   WORK_AVINT->(avzap())
EndIF

If EasyEntryPoint("EICAP100")
   ExecBlock("EICAP100",.F.,.F.,"CONFIRMA_EXCLUIR")
EndIf

Begin Transaction
dbSelectArea( cAlias1 )
dbSeek(xFilial()+SWA->WA_HAWB+SWA->WA_PO_DI)
nCnt := 0
aNumPos := {}
DO While !Eof() .And. xFilial("SWB")+SWA->WA_HAWB == SWB->WB_FILIAL+SWB->WB_HAWB ;
				.And. SWB->WB_PO_DI               == SWA->WA_PO_DI
    If _CalcDespCamb
       IF !EMPTY(SWB->WB_CA_DT) .And. !(lCposAntecip .And. (SWA->WA_PO_DI == "A" .Or. SWA->WA_PO_DI == "F" .Or. SWA->WA_PO_DI == "C"))  // GCC - 26/08/2013
          IF SWD->( DBSEEK(xFilial()+SWA->WA_HAWB+ "101" + DTOS(SWB->WB_CA_DT)) )
             RecLock("SWD", .F.)
             SWD->(DbDelete())
             SWD->(MsUnLock())
          ENDIF
       ENDIF
    EndIf

    lExcluiu := EICFI400("EXCLUI_TITULO")

    IF lExcluiu
       RecLock(cAlias1,.F.)
       If lCambio_eic
          APEDelIntF()	//---	Preparação da WORK_AVINT para interfaces AvInteg
       EndIf
       If EasyEntryPoint("ICPAP001")
          ExecBlock("ICPAP001",.F.,.F.,"EXCLUINDO TUDO")
       EndIf

       If EasyEntryPoint("EICAP100")
          ExecBlock("EICAP100",.F.,.F.,"EXCLUINDO TUDO")
       EndIf

       MSMM(SWB->WB_OBS,,,,2)
       If lCposAntecip
          If SWA->WA_PO_DI == "D" .AND. Left(SWB->WB_TIPOREG,1) == "P" .AND. !Empty(SWB->WB_NUMPO)
             // Bete 06/09/05 - array c/ pedidos
   	         IF ASCAN(aNumPos,SWB->WB_NUMPO) == 0
	            AADD(aNumPos,SWB->WB_NUMPO)
	         ENDIF

			 // GCC - Tratamento para ambos os controles de câmbio ( PO, Fornecedor e Crédito)
             If SWA->(DbSeek(xFilial("SWA")+SWB->WB_NUMPO+"A"))
                SWA->(RecLock("SWA", .F.))
                SWA->WA_SLDANT += SWB->WB_PGTANT
                SWA->(MsUnlock())
             ElseIf SWA->(DbSeek(xFilial("SWA")+SWB->WB_NUMPO+"F"))
                SWA->(RecLock("SWA", .F.))
                SWA->WA_SLDANT += SWB->WB_PGTANT
                SWA->(MsUnlock())
             ElseIf SWA->(DbSeek(xFilial("SWA")+SWB->WB_NUMPO+"C"))
                SWA->(RecLock("SWA", .F.))
                SWA->WA_SLDANT += SWB->WB_PGTANT
                SWA->(MsUnlock())
             Endif
             SWA->(DbGoTo(nRecSWA))

          ElseIf SWA->WA_PO_DI == "A" .Or. SWA->WA_PO_DI == "C" .Or. SWA->WA_PO_DI == "F"
             // Bete 06/09/05 - array c/ pedidos
             cNumPO := LEFT(SWA->WA_HAWB, Len(SW2->W2_PO_NUM))
   	         If Ascan(aNumPos,cNumPO) == 0
	            Aadd(aNumPos,cNumPO)
	         EndIf
          Endif

          // GCC - 05/02/2014 - Atualização do Saldo no pagamento antecipado associado
		  If SWB->(FieldPos("WB_PGTASS")) > 0 .AND. !Empty(SWB->WB_PGTASS) .And. SWB->WB_PO_DI == "C" //LGS-11/09/2014
		     aAdd(aRegsDel, {SWB->(WB_FILIAL+WB_HAWB+AvKey("A","WB_PO_DI")+WB_INVOICE+WB_FORN+WB_LOJA+WB_LINHA), SWB->WB_PGTANT})  // GFP - 15/05/2014
		     aOrdRec := SWB->({IndexOrd(),RecNo()})
		     nValParc := SWB->WB_PGTANT
		     If SWB->(DbSeek(SWB->WB_PGTASS))
			    RecLock("SWB", .F.)
			    SWB->WB_SLDTRF -= nValParc
			    SWB->(MsUnlock())

			    If SWA->(dbSeek(xFilial()+SWB->WB_HAWB+SWB->WB_PO_DI))
   			       SWA->(RecLock("SWA",.F.))
			       SWA->WA_SLDANT += nValParc
			       SWA->(MsUnLock())
			    EndIf
		     EndIf
		     SWB->(DbSetOrder(aOrdRec[1]))
		     SWB->(DbGoTo(aOrdRec[2]))
	      EndIf

       Endif
	   cProcesso := SWB->WB_HAWB
       SWB->(dbDelete())
       (cAlias1)->(MsUnlock())
    Else
      Exit//THTS - 13/06/2022 - Se deu algum erro de integração
    ENDIF
    nCnt++
    (cAlias1)->(dbSkip())
EndDo

If lExcluiu // caso tenha dado erro na integracao, nao continua as gravacoes

   If M->WA_PO_DI == "C"  // GFP - 06/05/2014
      MsAguarde({|| AP100RestReg(aRegsDel)}, "Atualizando registros") //"Pesquisa de Itens"
   EndIf

   IF !SWB->(dbSeek(cChaveSWB))
      dbSelectArea("SWA")
      SWA->(DBGOTO(nRecSWA))
      SWA->(RecLock("SWA",.F.))
      MSMM(SWA->WA_OBS,,,,2)
      If lCposAntecip
         If (SWA->WA_PO_DI == "A" .Or. SWA->WA_PO_DI == "F" .Or. SWA->WA_PO_DI == "C" )	// GCC - 26/08/2013
            AP100ArqSYS(.F.) // Excluir o registro no SYS
            lGeraPrv := .T.
            cNumPO := LEFT(SWA->WA_HAWB, Len(SW2->W2_PO_NUM))
         Endif
      Endif
      SWA->(RecLock("SWA",.F.))
      SWA->(DbDelete())
      SWA->(MSUNLOCK())
   ENDIF

   // Bete 01/07/05  -  Para refazer os titulos provisorios com o FOB total do pedido
   IF EasyGParam("MV_EASYFPO",,"N") == "S"	//ASR - 16/09/2005 - GERA TITULOS DE PREVISÃO DE DESPESAS NO FINANCEIRO SE FOR IGUAL "S"
      FOR i:=1 TO LEN(aNumPos)
         cNumPO := LEFT(aNumPos[i], LEN(SW2->W2_PO_NUM))
         nOrderSW2:=SW2->(INDEXORD())
         SW2->(DBSETORDER(1))
         IF SW2->(DBSEEK(XFILIAL("SW2")+cNumPO))  //
            lBaixada:=.F.
            IF AVFLAGS("EIC_EAI")
               AvProvRecalc(cNumPO)//reapuração dos provisórios
            Else
               Processa({|| FI400ANT_PO(cNumPO,.T.,@lBaixada)})
               Processa({|| FI400POS_PO(cNumPO,lBaixada) })
            EndIf
         ENDIF
         SW2->(DBSETORDER(nOrderSW2))
      NEXT
   ENDIF
EndIf

dbSelectArea( cAlias1 )

End Transaction
//
If LCAMBIO_EIC //DRL - 02/06/10, Caso exista a integração pelo AvInteg...
   GravaInte17()
EndIf
//
RETURN .T.

*------------------------------------*
FUNCTION APEDelIntF()	//---	Preparação da WORK_AVINT para interfaces AvInteg
*------------------------------------*
If M->WA_PO_DI == 'D'
	//
	If	lEICFI05  .AND.  !Empty(SWB->WB_TITERP)  //INTERFACE CÂMBIO	// PLB 15/04/10 - Verifica Existencia de Título para enviar Operação
		WORK_AVINT->(dbAppend())
		WORK_AVINT->WK_TIPO   := 'E'
		WORK_AVINT->WK_FASE1  := 'CBO'
		WORK_AVINT->WK_LANCA  := 'EX'
		WORK_AVINT->WK_FILIAL := SWB->WB_FILIAL
		WORK_AVINT->WK_HAWB   := SWB->WB_HAWB
		WORK_AVINT->WK_PO_DI  := SWB->WB_PO_DI
		WORK_AVINT->WK_INVOICE:= SWB->WB_INVOICE
		WORK_AVINT->WK_FORN   := SWB->WB_FORN
		WORK_AVINT->WK_LOJA   := SWB->WB_LOJA
		WORK_AVINT->WK_LINHA  := SWB->WB_LINHA
		WORK_AVINT->WK_ALIAS  := "SWB"
		WORK_AVINT->WK_RECNO  := SWB->(RecNo())
		//
		IF EasyEntryPoint("EICAP100")
		   ExecBlock("EICAP100",.F.,.F.,"APEDELINTF_ESTORNO_EXC_CBO_D_WORK_AVINT")
		ENDIF
		//
	EndIf
	//
	If (nPOs:=ASCAN(aParInv,{|x| x[1]==SWB->WB_INVOICE+SWB->WB_FORN})) <> 0
		aParInv[nPos][2]--
	EndIf
	//
	If aParInv[nPos][2]==0
		//
		SW9->(DBSETORDER(1))
		SW9->(DBSEEK(XFILIAL('SW9')+SWB->WB_INVOICE+SWB->WB_FORN))
		//
		If	lEICFI06	//INTERFACE INVOICE
			//---	Como há interface de INVOICE, então, apaga-se o título anterior da Invoice, pois será solicitada a inclusão de um novo título para a mesma...
			SW9->(RECLOCK('SW9',.F.))
			SW9->W9_TITERP:=''
			SW9->(MSUNLOCK())
			SW9->(DBCOMMIT())
			//
			WORK_AVINT->(dbAppend())
			WORK_AVINT->WK_TIPO   := 'I'
			WORK_AVINT->WK_FASE1  := 'INV'
			WORK_AVINT->WK_LANCA  := 'AB'
			WORK_AVINT->WK_FILIAL := SW9->W9_FILIAL
			WORK_AVINT->WK_HAWB   := SW9->W9_HAWB
			WORK_AVINT->WK_INVOICE:= SW9->W9_INVOICE
			WORK_AVINT->WK_FORN   := SW9->W9_FORN
			WORK_AVINT->WK_ALIAS  := "SW9"
			WORK_AVINT->WK_RECNO  := SW9->(RecNo())
			//
			IF EasyEntryPoint("EICAP100")
			   ExecBlock("EICAP100",.F.,.F.,"APEDELINTF_ESTORNO_INC_INV_WORK_AVINT")
			ENDIF
			//
		ElseIf	lEICFI07	//INTERFACE DE INVOICE ANTECIPADA
			//
			//--- Como NÃO HÁ a interface de INVOICE (conforme IF lEICFI06 anterior) e há a interface de INVOICE ANTECIPADA, neste caso, o título que está
			//		inserido na tabela de INVOICES é o mesmo da INVOICE ANTECIPADA. Por isso, os dois campos serão APAGADOS para receberem o mesmo número de
			//		título quando o retorno da interface de INVOICE ANTECIPADA ocorrer...
			SW9->(RECLOCK('SW9',.F.))
			SW9->W9_TITERP:=''
			SW9->(MSUNLOCK()) //quando excluir todos cambios apenas integrar a invoice
			SW9->(DBCOMMIT())
			//
			EW4->(DBSETORDER(2))
			EW4->(DBSEEK(XFILIAL('EW4')+SWB->WB_HAWB+SWB->WB_INVOICE+SWB->WB_FORN))
			EW4->(RECLOCK('EW4',.F.))
			EW4->EW4_TITERP:=''
			EW4->(MSUNLOCK())
			EW4->(DBCOMMIT())
			//se tiver INVOICE ANTECIPADA integrar INCLUSÃO
			//
			WORK_AVINT->(dBAppend())
			WORK_AVINT->WK_TIPO   := 'I'
			WORK_AVINT->WK_FASE1  := 'INVANT'
			WORK_AVINT->WK_LANCA  := 'AB'
			WORK_AVINT->WK_FILIAL := EW4->EW4_FILIAL
			WORK_AVINT->WK_HAWB   := EW4->EW4_HAWB
			WORK_AVINT->WK_INVOICE:= EW4->EW4_INVOIC
			WORK_AVINT->WK_FORN   := EW4->EW4_FORN
			WORK_AVINT->WK_ALIAS  := "EW4"
			WORK_AVINT->WK_RECNO  := EW4->(RecNo())
			//
			IF EasyEntryPoint("EICAP100")
			   ExecBlock("EICAP100",.F.,.F.,"APEDELINTF_ESTORNO_INC_INVANT_WORK_AVINT")
			ENDIF
			//
		EndIf
	EndIf
Else //integrar exclusao de parcela de pagamento antecipado
	If	lEICFI08  .AND.  !Empty(SWB->WB_TITERP)  //---	INTERFACE PAGAMENTO ANTECIPADO	// PLB 15/04/10 - Verifica Existencia de Título para enviar Operação
		WORK_AVINT->(dbAppend())
		WORK_AVINT->WK_TIPO   := 'E'
		WORK_AVINT->WK_FASE1  := 'PA'
		WORK_AVINT->WK_LANCA  := 'EX'
		WORK_AVINT->WK_FILIAL := XFILIAL('SWB')
		WORK_AVINT->WK_HAWB   := SWB->WB_HAWB
		WORK_AVINT->WK_INVOICE:= SWB->WB_INVOICE
		WORK_AVINT->WK_PARCELA:= SWB->WB_PARCELA
		WORK_AVINT->WK_ALIAS  := "SWB"
		WORK_AVINT->WK_RECNO  := SWB->(RecNo())
		//
		If EasyEntryPoint("EICAP100")
			ExecBlock("EICAP100",.F.,.F.,"APEDELINTF_ESTORNO_EXC_PA_WORK_AVINT")
		EndIf
		//
	EndIf
EndIf
Return .T.

*------------------------------------*
FUNCTION ApeVal_House(THouse,_ChkHou)
*------------------------------------*
LOCAL cChave
PRIVATE lNotOk:=.F.
THouse:=M->WA_HAWB
IF _ChkHou
   IF ! APE100Crit("HOUSE","WA_HAWB")
      RETURN .F.
   ENDIF

   IF EasyEntryPoint("EICAP100")
      ExecBlock("EICAP100",.F.,.F.,"INCLUIR_HAWB")
   ENDIF

   IF lNotOk
      RETURN .F.
   ENDIF
ELSE
   SW6->(DBSEEK(xFilial()+THouse+LEFT(M->WA_PO_DI,1)))
ENDIF

If !lCposAntecip .OR. (LEFT(M->WA_PO_DI,1) == "F" .Or. LEFT(M->WA_PO_DI,1) == "C")
	Return .T.
EndIf

If !lCposAntecip .OR. LEFT(M->WA_PO_DI,1) # "A"
   SW7->(DBSEEK(xFilial()+THouse))
   SW2->(DBSEEK(xFilial()+SW7->W7_PO_NUM))
   SW4->(DBSEEK(xFilial()+SW7->W7_PGI_NUM))
Else
   SW2->(DBSEEK(xFilial()+AllTrim(THouse)))
Endif

cBancoRec:=cAgeRec:=cSwift:=cConta := ""

IF SA2->(DBSEEK(xFilial()+SW2->W2_FORN+EICRetLoja("SW2","W2_FORLOJ")))
   _OkForn:= .T.
   cBancoRec:= SA2->A2_BANCO
   cAgeRec  := SA2->A2_AGENCIA
   cSwift   := SA2->A2_SWIFT
   cConta   := SA2->A2_NUMCON
ENDIF
SA6->(DBSETORDER(1))
IF SA6->(DBSEEK(xFilial()+SA2->A2_BANCO))
   _OkBanco:= .T.
ENDIF

M->WA_FB_NOME:=SA2->A2_NREDUZ
M->WA_BC_NOME:=SA6->A6_NOME

SX3->(DBSETORDER(2))

If !lCposAntecip .or. LEFT(M->WA_PO_DI,1) <> "A"
    M->WA_DI_NUM :=SW6->W6_DI_NUM
    M->WA_DTREG_D:=SW6->W6_DTREG_D
Endif

IF(lNestle,ExecBlock("IF209FI0",.F.,.F.,"1"),)
lRefresh:=.T.

IF ! _ChkHou .OR. lSegundaVez
   RETURN .T.
ENDIF

If lCposAntecip .AND. LEFT(M->WA_PO_DI,1) == "A"
   cChave := SW2->W2_COND_PA+STR(SW2->W2_DIAS_PA,3,0)
   If !CondInv(cChave,.T.)
      Return .F.
   EndIf
   M->WA_CPAGTO :=TRAN(SY6->Y6_COD,'@R 9.9.999')+SPACE(01)+MSMM(SY6->Y6_DESC_P,42,1)
Else
//   IF !Empty( SW6->W6_COND_PA )  RJB 25/10/2004 CAMPO ESTA SENDO PREENCHIDO MAS NAO É MAIS UTILIZADO (JS) - ENTREPOSTO
//      cChave := SW6->W6_COND_PA+STR(SW6->W6_DIAS_PA,3,0)
//      If !CondInv(cChave,.T.)
//         Return .F.
//      EndIf
//      If !lCposAntecip .or. LEFT(M->WA_PO_DI,1) <> "A"
//         IF M->WA_PER_JUR#0
//            M->WA_PER_IR:=EasyGParam("MV_IR_CAMB")
//         ENDIF
//      Endif
//      M->WA_CPAGTO :=TRAN(SY6->Y6_COD,'@R 9.9.999')+SPACE(01)+MSMM(SY6->Y6_DESC_P,42,1)
//   ELSE
      If !lCposAntecip .or. LEFT(M->WA_PO_DI,1) <> "A"
         SW9->(DBSETORDER(3))
//       SW8->(DbSetOrder(2))
         SW9->(DBSEEK(xFilial("SW9")+SW6->W6_HAWB))

         DO WHILE ! SW9->(EOF()) .AND. SW6->W6_HAWB == SW9->W9_HAWB .AND. xFilial("SW9")=SW9->W9_FILIAL
            cChave := SW9->W9_COND_PA+STR(SW9->W9_DIAS_PA,3,0)

            If CondInv(cChave,.F.)
               lFaz := .T.
            Else
               lFaz := .F.
            EndIf
            If lFaz
               IF M->WA_PER_JUR#0
                  M->WA_PER_IR:=EasyGParam("MV_IR_CAMB")
               ENDIF

               M->WA_CPAGTO :=TRAN(SY6->Y6_COD,'@R 9.9.999')+SPACE(01)+MSMM(SY6->Y6_DESC_P,42,1)
            EndIf
            SW9->(dbSkip())
         EndDo

         SW9->(DBSETORDER(1))
//       SW8->(DBSETORDER(1))
      Else
         cChave := SW2->W2_COND_PA+STR(SW2->W2_DIAS_PA,3,0)
         If !CondInv(cChave,.T.)
            Return .F.
         EndIf
         M->WA_CPAGTO :=TRAN(SY6->Y6_COD,'@R 9.9.999')+SPACE(01)+MSMM(SY6->Y6_DESC_P,42,1)
      Endif
//   EndIf
Endif
lRefresh:=.t.
RETURN .T.

*-----------------------*
Function ApeCalc(THouse)
*-----------------------*
Ape_Venctos(THouse)
If !lCposAntecip
   TRB->(DBSEEK(THouse))
   WHILE ! TRB->(EOF()) .AND. TRB->WB_HAWB = THouse
      IF ALLTRIM(TRB->WB_TIPO) == 'ANTECIPADO'
         TRB->(DbDelete())
      ENDIF
      TRB->(DBSKIP())
   ENDDO
Endif
TRB->(DBGOTOP())
lRefresh:=.t.

RETURN .T.

*----------------------------*
FUNCTION Ape_Venctos(_PHouse)
*----------------------------*
LOCAL WWind, _LenTab:= 0
LOCAL Valor_Inv, _UltFor:= 0 , _SmAux:= 0

LOCAL lAgfa := EasyEntryPoint("IF140CA1")
LOCAL ldataEMB := SX6->(DBSEEK(xFilial("SX6")+"MV_DTB_APD")) .AND. !EMPTY(EasyGParam("MV_DTB_APD"))

//** GFC - 18/11/05 - Tratar o retorno da função
Local lRet:=.T.
//**

PRIVATE aPriTabInv := aTabInv:={}
PRIVATE Wind:=1 , lCalcula:=.T.
PRIVATE dDtEMB := CTOD(""),cDatEmb := SPACE(14)

If lWB_EVENT
   EC6->(dbSetOrder(1))
EndIf

Begin Sequence //** GFC - 18/11/05

   //** GFC - 24/11/05
  // If lGravaFin_EIC    //ASK 03/12/2007
  //    lRet := .F.
  //    Break
  // EndIf
   //**

   DBSELECTAREA('SY6')
   SW9->(DBSETORDER(3))

   IF SW9->(DBSEEK(xFilial()+_PHouse))

      DO WHILE ! SW9->(EOF()) .AND. _PHouse == SW9->W9_HAWB .AND. xFilial("SW9")=SW9->W9_FILIAL
         IF !lDataEMB //ASK 17/07/2007 - Tratamento do parâmetro MV_DTB_APD
            cDatEmb := "SW6->W6_DT_EMB"
         ELSE
            cDatEmb := ALLTRIM(GetNewPar("MV_DTB_APD","SW6->W6_DT_EMB"))
         ENDIF

         If SubStr(cDatEmb,4,2) == "->"  //Caso o conteúdo do parâmetro possuir o Alias do Campo "SW6->"
            If Left(cDatEmb,3) $ "SW6,SW9"
               dDtEMB:= &cDatEmb
            EndIf
         ElseIf SubStr(cDatEmb,3,1) == "_" //Caso o conteúdo do parâmentro possuir apenas o campo
            If Left(cDatEmb,2) == "W6"
               dDtEMB := &("SW6->" + cDatEmb )
            ElseIf Left(cDatEmb,2) == "W9"
               dDtEMB := &("SW9->" + cDatEmb )
            EndIf
         EndIf
         IF EMPTY(dDtEMB)
            dDtEMB := SW6->W6_DT_EMB
            IF EMPTY(dDtEMB)
               dDtEMB := SW6->W6_DT_ETA
               IF EMPTY(dDtEMB)
                  lRet := .F.
                  Break
               ENDIF
            ENDIF
         ENDIF
         dDtaVista:=IF(!EMPTY(SW6->W6_DT_DESE),SW6->W6_DT_DESE,dDtEMB)

         Valor_Inv:=IF(lAgfa,ExecBlock("IF140CA1",.F.,.F.,"INVOICE"),DI500RetVal("TOT_INV", "TAB", .T.))// EOB - 14/07/08 - chamada da função DI500RetVal

         IF EasyEntryPoint("EICAP100") //OS 0639/01 FCD
            ExecBlock("EICAP100",.F.,.F.,"VENCTO_SW9")
         ENDIF

         IF lCalcula  //RDMAKE
            EicCalcPagto(SW9->W9_INVOICE+SW9->W9_FORN+IF(EICLOJA(),SW9->W9_FORLOJ,""),Valor_Inv,dDtEMB,dDtaVista,(SW9->W9_COND_PA+STR(SW9->W9_DIAS_PA,3)),aTabInv,,,,,If(lWB_TP_CON .and. lGeraCom,SW9->W9_VALCOM,0)) //OS 0639/01
         ENDIF

         SW9->(DBSKIP())
      ENDDO

   ENDIF

   SW9->(DBSETORDER(1))

   IF EasyEntryPoint("EICAP100")
      ExecBlock("EICAP100",.F.,.F.,"ANTES_INCLUI_TRB")
   ENDIF

   _LenTab:= LEN( aTabInv )
   WWind:= 1

   IF _LenTab == 0 .OR. LEN( aTabInv[1] ) == NIL
      RETURN
   ENDIF

   FOR WWind = 1 TO _LenTab
      Wind := WWind
      IF EMPTY(aTabInv[ Wind,3 ])//Data
         _SmAux += aTabInv[Wind,2] //Valor
         LOOP
      ENDIF
      TInvoice:= LEFT(aTabInv[Wind,1],LEN(SWB->WB_INVOICE)) //Chave
      // GFP - 04/10/2011
      cForn   := Substr(aTabInv[Wind,1], AvSx3("WB_INVOICE", AV_TAMANHO)+1,AvSx3("A2_COD", AV_TAMANHO)) //RIGHT(aTabInv[Wind,1],LEN(SA2->A2_COD)) //Chave
  //    If EICLoja()
         TLoja   := SubStr(aTabInv[Wind,1], AvSx3("WB_INVOICE", AV_TAMANHO)+AvSx3("A2_COD", AV_TAMANHO)+1, AvSx3("A2_LOJA", AV_TAMANHO))
  //    EndIF
      TFobMoe := aTabInv[Wind,2] //Valor
      TDt_Ven := aTabInv[Wind,3] //Data
      TTipo   := aTabInv[Wind,4] //Tipo
      THouse  := _PHouse
      _SmAux  += TFobMoe +IF(lAgfa,ExecBlock("IF140CA1",.F.,.F.,"TFRETE") ,0) // RHP

      SW9->(DBSEEK(xFilial("SW9")+aTabInv[Wind,1]))
      TRB->(DBAPPEND())
      TRB->WB_HAWB    := THouse
      TRB->WB_DT_VEN  := TDt_Ven
      TRB->WB_FOBMOE  := TFobMoe
      TRB->WB_TIPO    := TTipo
      TRB->WB_INVOICE := TInvoice
      TRB->WB_FORN    := cForn
  //    If EICLOJA()
         TRB->WB_LOJA := TLoja
  //    EndIF
      TRB->WB_TIPOREG := '1'
      TRB->WB_BCO_REC := cBancoRec
      TRB->WB_AGENREC := cAgeRec
      TRB->WB_SWIFT   := cSwift
      TRB->WB_CON_REC := cConta
      TRB->WB_MOEDA   := SW9->W9_MOE_FOB
      TRB->TRB_ALI_WT:= "SWB"
      TRB->TRB_REC_WT:=  SWB->(Recno())
   //---	ADC	02/12/2009	Não pode gravar o título na invoice no câmbio...
      //** igor chiba 01/10/09 gravando titulo do erp da invoice no cambio
      //IF lCAMBIO_EIC
      //   TRB->WB_TITERP := SW9->W9_TITERP
      //ENDIF
      //**

      //CCH - 17/08/2009 - Nopado pois o banco para pagamento não pode ser carregado automaticamente. Deverá ser escolhido pelo próprio usuário

    /*IF SA2->(DBSEEK(xFilial()+TRB->WB_FORN)) .AND. !EMPTY(SA2->A2_BANCO)//AWR - 20/06/2006
       TRB->WB_BANCO  := SA2->A2_BANCO
       TRB->WB_AGENCIA:= SA2->A2_AGENCIA
       IF TRB->(FIELDPOS("WB_CONTA")) # 0
          TRB->WB_CONTA:=SA2->A2_NUMCON
       ENDIF
    ENDIF*/

      //** GFC - 24/11/05 - Câmbio de frete, seguro, comissão e embarque
      If lWB_TP_CON
         TRB->WB_TP_CON  := "2"
         TRB->WB_TIPOCOM := SW9->W9_TIPOCOM
      EndIf
      //**
      //** GFC - 08/03/06 - Gravar Evento (Finimp)
      If lWB_EVENT
         TRB->WB_EVENT    := PRINCIPAL
         If EC6->(dbSeek(xFilial("EC6")+"IMPORT"+PRINCIPAL))
            TRB->WB_TIPOC := If(EC6->EC6_RECDES=="1","R","P")
         Else
            TRB->WB_TIPOC := "P" //BHF-29/05/09
         EndIf
      EndIf
      //**
      If lCposAntecip
         TRB->WB_PO_DI := M->WA_PO_DI
      Else
         TRB->WB_PO_DI := "D"
      Endif

      //** PLB 25/10/06 - Grava Linha quando inclusão de parcela
      If Empty(TRB->WB_LINHA)
         nLinhaTRB := Ap100ApuLinha("TRB")//JVR - 13/03/10
         //nLinhaTRB += 1
         TRB->WB_LINHA  := PADL(nlinhaTRB,4,"0")
      EndIf
      //**

      IF(lAgfa,ExecBlock("IF140CA1",.F.,.F.,"GRAVA_TRB"),)

      IF EasyEntryPoint("EICAP100")
         ExecBlock("EICAP100",.F.,.F.,"INCLUI_TRB")
      ENDIF

//** igor chiba adicionando nº de  parcelas para serem usadas na exclusão do cambio 29/09/09
      IF LCAMBIO_EIC
         IF nPos_aRotina = 5 .OR. nPos_aRotina = 4 //exclusao
            IF (nPOs:=ASCAN(aParInv,{|x| x[1] == TRB->WB_INVOICE + TRB->WB_FORN })) = 0
               AADD(aParInv,{TRB->WB_INVOICE + TRB->WB_FORN ,1})
            ELSE
               aParInv[nPos][2]++
            ENDIF
         ENDIF
      ENDIF
      //**
      //** PLB - 25/10/06 - Financiamento de Importação
      If lEFFTpMod .and. lEIC_EFF .and. lWB_EVENT .And. TRB->WB_EVENT == PRINCIPAL   //101
         GrvaVincula()
      EndIf
      //**

      //** GFC - 24/11/05 - Câmbio de frete, seguro, comissão e embarque
      If aTabInv[Wind,7] > 0
         TRB->(DBAPPEND())
         TRB->WB_HAWB    := THouse
         TRB->WB_DT_VEN  := TDt_Ven
         TRB->WB_FOBMOE  := aTabInv[Wind,7]
         TRB->WB_TIPO    := TTipo
         TRB->WB_INVOICE := TInvoice
         TRB->WB_FORN    := SW9->W9_FORNECC
         TRB->WB_LOJA := SW9->W9_LOJAC
         TRB->WB_TIPOREG := 'C'  //Comissão
         TRB->WB_BCO_REC := cBancoRec
         TRB->WB_AGENREC := cAgeRec
         TRB->WB_SWIFT   := cSwift
         TRB->WB_CON_REC := cConta
         TRB->WB_MOEDA   := SW9->W9_MOE_FOB
         TRB->WB_TP_CON  := "4"
         TRB->WB_TIPOCOM := SW9->W9_TIPOCOM
         TRB->TRB_ALI_WT:= "SWB"
         TRB->TRB_REC_WT:= SWB->(Recno())

         If lCposAntecip
            TRB->WB_PO_DI := M->WA_PO_DI
         Else
            TRB->WB_PO_DI := "D"
         Endif
         //** GFC - 08/03/06 - Gravar Evento (Finimp)
         If lWB_EVENT
            If SW9->W9_TIPOCOM == "1" //A remeter
               TRB->WB_EVENT   := COM_REMETER
            ElseIf SW9->W9_TIPOCOM == "2" //A deduzir da fatura
               TRB->WB_EVENT   := COM_ADEDUZIR
            Else //Conta Gráfica
               TRB->WB_EVENT   := COM_CTAGRAF
            EndIf
            If EC6->(dbSeek(xFilial("EC6")+"IMPORT"+TRB->WB_EVENT))
               TRB->WB_TIPOC := If(EC6->EC6_RECDES=="1","R","P")
            Else
               TRB->WB_TIPOC := "P" //BHF-29/05/09
            EndIf
         EndIf
         //**
      EndIf
      //**

   NEXT
   dbSelectArea("TRB")
   dbGoTop()

   //** GFC - 24/11/05 - Câmbio de frete, seguro, comissão e embarque
   If lWB_TP_CON .and. lGeraFrete
      aTabInv:={}
      EicCalcPagto("FRETE"+SW6->W6_FORNECF,SW6->W6_VLFRECC,dDtEMB,dDtaVista,(SW6->W6_CONDP_F+STR(SW6->W6_DIASP_F,3)),aTabInv) //OS 0639/01

      FOR WWind = 1 TO Len(aTabInv)
         Wind := WWind
         IF EMPTY(aTabInv[ Wind,3 ])//Data
            LOOP
         ENDIF

         SW9->(DBSEEK(xFilial("SW9")+aTabInv[Wind,1]))
         TRB->(DBAPPEND())
         TRB->WB_HAWB    := _PHouse
         TRB->WB_DT_VEN  := aTabInv[Wind,3]
         TRB->WB_FOBMOE  := aTabInv[Wind,2]
         TRB->WB_TIPO    := aTabInv[Wind,4]
         TRB->WB_INVOICE := "FRETE"
         TRB->WB_FORN    := RIGHT(aTabInv[Wind,1],LEN(SA2->A2_COD))
         TRB->WB_TIPOREG := 'A'
         IF SA2->(DBSEEK(xFilial("SA2")+TRB->WB_FORN+EICRetLoja("TRB","WB_LOJA")))
            //If EICLoja()
               TRB->WB_LOJA := SubStr(aTabInv[Wind,1], AvSx3("WB_INVOICE", AV_TAMANHO)+AvSx3("A2_COD", AV_TAMANHO), AvSx3("A2_LOJA", AV_TAMANHO))
            //EndIf
            TRB->WB_BCO_REC := SA2->A2_BANCO
            TRB->WB_AGENREC := SA2->A2_AGENCIA
            TRB->WB_SWIFT   := SA2->A2_SWIFT
            TRB->WB_CON_REC := SA2->A2_NUMCON
         ENDIF
         TRB->WB_MOEDA   := SW6->W6_FREMOED
         TRB->TRB_ALI_WT:= "SWB"
         TRB->TRB_REC_WT:= SWB->(Recno())


         //** GFC - 24/11/05 - Câmbio de frete, seguro, comissão e embarque
         If lWB_TP_CON
            TRB->WB_TP_CON  := "4"
         EndIf
         //**
         If lCposAntecip
            TRB->WB_PO_DI := M->WA_PO_DI
         Else
            TRB->WB_PO_DI := "D"
         Endif
         //** GFC - 08/03/06 - Gravar Evento (Finimp)
         If lWB_EVENT
            TRB->WB_EVENT   := FRETE
            If EC6->(dbSeek(xFilial("EC6")+"IMPORT"+FRETE))
               TRB->WB_TIPOC := If(EC6->EC6_RECDES=="1","R","P")
		    Else
               TRB->WB_TIPOC := "P" //BHF-29/05/09
            EndIf
         EndIf
         //**
      Next WWind
   EndIf

   If lWB_TP_CON .and. lGeraSeg
      aTabInv:={}
      EicCalcPagto("SEGURO"+SW6->W6_FORNECS,SW6->W6_VL_USSE,dDtEMB,dDtaVista,(SW6->W6_CONDP_S+STR(SW6->W6_DIASP_S,3)),aTabInv) //OS 0639/01

      FOR WWind = 1 TO Len(aTabInv)
         Wind := WWind
         IF EMPTY(aTabInv[ Wind,3 ])//Data
            LOOP
         ENDIF

         SW9->(DBSEEK(xFilial("SW9")+aTabInv[Wind,1]))
         TRB->(DBAPPEND())
         TRB->WB_HAWB    := _PHouse
         TRB->WB_DT_VEN  := aTabInv[Wind,3]
         TRB->WB_FOBMOE  := aTabInv[Wind,2]
         TRB->WB_TIPO    := aTabInv[Wind,4]
         TRB->WB_INVOICE := "SEGURO"
         TRB->WB_FORN    := RIGHT(aTabInv[Wind,1],LEN(SA2->A2_COD))
         TRB->WB_TIPOREG := 'B'
         IF SA2->(DBSEEK(xFilial("SA2")+TRB->WB_FORN+EICRetLoja("TRB","WB_LOJA")))
            //If EICLoja()
               TRB->WB_LOJA := SubStr(aTabInv[Wind,1], AvSx3("WB_INVOICE", AV_TAMANHO)+AvSx3("A2_COD", AV_TAMANHO), AvSx3("A2_LOJA", AV_TAMANHO))
            //EndIf
            TRB->WB_BCO_REC := SA2->A2_BANCO
            TRB->WB_AGENREC := SA2->A2_AGENCIA
            TRB->WB_SWIFT   := SA2->A2_SWIFT
            TRB->WB_CON_REC := SA2->A2_NUMCON
         ENDIF
         TRB->WB_MOEDA   := SW6->W6_SEGMOED
         TRB->TRB_ALI_WT:= "SWB"
         TRB->TRB_REC_WT:= SWB->(Recno())

         //** GFC - 24/11/05 - Câmbio de frete, seguro, comissão e embarque
         If lWB_TP_CON
            TRB->WB_TP_CON  := "4"
         EndIf
         //**
         If lCposAntecip
            TRB->WB_PO_DI := M->WA_PO_DI
         Else
            TRB->WB_PO_DI := "D"
         Endif
         //** GFC - 08/03/06 - Gravar Evento (Finimp)
         If lWB_EVENT
            TRB->WB_EVENT   := SEGURO
            If EC6->(dbSeek(xFilial("EC6")+"IMPORT"+SEGURO))
               TRB->WB_TIPOC := If(EC6->EC6_RECDES=="1","R","P")
            Else
               TRB->WB_TIPOC := "P" //BHF-29/05/09
            EndIf
         EndIf
         //**
      Next WWind
   EndIf
   //**

End Sequence

RETURN lRet

*--------------------------*
FUNCTION APE_GerTab(THouse)
*--------------------------*
LOCAL nRecno:=SWB->(RECNO())

If lCposAntecip .AND. (LEFT(M->WA_PO_DI,1)=="A" .Or. LEFT(M->WA_PO_DI,1)=="F" .Or. LEFT(M->WA_PO_DI,1)=="C")
   If njafoi == 0 .AND. inclui
      njafoi := 1
      lRetFunc := AP100GERADI()
      nJaFoi := IF(lRetFunc, 1, 0)
      return lRetFunc
   Endif
Else

   ASIZE(TabPo,0); ASIZE(TabPgi,0)

   SW6->(DBSEEK(xFilial()+THouse))
   SW7->(DBSEEK(xFilial()+THouse))

   DO WHILE ! SW7->(EOF()) .AND. xFilial("SW7")=SW7->W7_FILIAL
      IF SW7->W7_HAWB # THouse
         EXIT
      ENDIF
      IF ASCAN(TabPo, SW7->W7_PO_NUM) = 0
         AADD( TabPo, SW7->W7_PO_NUM )
      ENDIF
      IF ASCAN(TabPgi, SW7->W7_PGI_NUM) = 0
         AADD( TabPgi, SW7->W7_PGI_NUM )
      ENDIF
      SW7->(DBSKIP())
   ENDDO

   ASIZE(Tab_RecDi,0)
   DBSELECTAREA("SWB")
   DBSETORDER(1)
   SWB->(DBSEEK(xFilial()+THouse+LEFT(M->WA_PO_DI,1)))
   DO WHILE  _CalcDespCamb .And. !SWB->(EOF()) .AND.;
             SWB->WB_HAWB == THouse .AND.;
             xFilial("SWB")==SWB->WB_FILIAL.AND.;
             SWB->WB_PO_DI==LEFT(M->WA_PO_DI,1)

      IF ! EMPTY(SWB->WB_CA_DT)
         IF SWD->( DBSEEK(xFilial()+SWA->WA_HAWB+ "101" + DTOS(SWB->WB_CA_DT)) )
            AADD( Tab_RecDi, { SWB->(RECNO()),SWD->(RECNO()) } )
         ENDIF
      ENDIF
      SWB->(DBSKIP())
   ENDDO
   SWB->(DBGOTO(nRecno))
ENDIF
If IsVazio("TRB")//ASK 03/12/2007 - Inclusão
  Return .T.
EndIf

dbSelectArea("TRB")
dbGoTop()
RETURN

/*
±±±±±±±±±±±±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡„o    ³APE100Crit ³ Autor ³ PADRAO GETDADDB       ³ Data ³ 12.07.96 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡„o ³ Faz as Valida‡oes necessarias aos campos da GETDADDB        ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso       ³ EICAPE100                                                   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FUNCTION APE100Crit(MFlag,cCampo,PAlteracao)

Local ValorFob, _MRecord, _Soma:= 0, _Tamanho,cFornecedor:="", Wind, cLoj:= ""
Local _Encontrou:= .F., uDado,nPerc:=0
Local cRno, cBco
Local nRecno := 0
Local nOrdSWB:= 0
Local lRetorno:=.T. ,nOrdSW9:=SW9->(INDEXORD())
Local lEncParc := .F.
Local aOrdSWB := {} //NCF - 10/06/2010
Local nSalApu := 0 // GFP - 17/04/2014
Local cMoeLocal := "XXX"  //NCF - 31/07/2017
Local cMoeBanco := "YYY"
Local cMoeCambi := "ZZZ"
Local cNumMoeda := "" //THTS - 12/09/2017

PRIVATE cMoedaDolar := BuscaDolar()//EasyGParam("MV_SIMB2",,"US$")
PRIVATE cFlag

IF cCampo==NIL
   uDado:=&(READVAR())
   cCampo:=Subs(READVAR(),4)
ELSE
   uDado:=M->(&cCampo)
ENDIF

cFlag := MfLag
lSair:=.F.
cVldCampo := cCampo
IF(EasyEntryPoint("EICAP100"),Execblock("EICAP100",.F.,.F.,"ANT_VALID_SWB"),)
IF lSair
   RETURN lRetorno
ENDIF

DO CASE
   CASE MFlag == 'PEDIDO'
        IF !EMPTY(M->WB_NUMPO) .AND. !Work1->(DBSeek(M->WB_NUMPO))
           MSGINFO(STR0130,STR0043)  //"Pedido nao encontrado."
           Return .F.
        Endif
        IF !EMPTY(M->WB_NUMPO)
           SW2->(DBSEEK(xFilial()+M->WB_NUMPO))
           IF Work1->W2_MOEDA # SW2->W2_MOEDA
              MSGINFO(STR0131)  //"Moeda do Pedido difere da moeda do Processo."
              RETURN .F.
           ENDIF
        ENDIF

        RETURN .T.

   CASE MFlag == 'PGTANT'
        /*IF !EMPTY(M->WB_PGTANT) .AND. LEFT(M->WA_PO_DI,1) == 'D' .AND.;
           M->WB_TIPOREG = 'P'  .AND. EMPTY(M->WB_NUMPO)
           Help(" ",1,"AVG0005365")//LRL 08/01/04MSGINFO("Pedido nao preenchido.",STR0043)
           Return .F.
        ENDIF
        */
        IF !EMPTY(M->WB_PGTANT) .AND. LEFT(M->WA_PO_DI,1) == 'D' .AND.; //CCH - 09/06/09 - Validação na vinculação das parcelas de câmbio.
           Left(M->WB_TIPOREG,1) # 'P'                                          //(Pagto Antecipado x Parcela Principal)

           DO WHILE TRB->(!EOF())

              IF Left(TRB->WB_TIPOREG,1) == 'P'
                 IF (TRB->WB_FORN # M->WB_FORN .AND. (!EICLOJA() .OR. TRB->WB_LOJA # M->WB_LOJA )) .OR. TRB->WB_MOEDA # M->WB_MOEDA
                    lEncParc := .T.
                 ENDIF
              ENDIF

              TRB->(DBSKIP())
           END DO

	       IF lEncParc
	          MsgInfo(STR0244,STR0063) //STR0244 "Não é permitido vincular pagamentos antecipados com parcelas principais de fornecedores diferentes" //STR0063  "Atenção"
	          Return .F.
	       ENDIF

        ENDIF
        //SVG - 08/06/2011 - Não permite a alteração do WB_PGTANT com MV_COMPAUT ligado, visto que esse processo é feito automaticamente.
        If lCompAut .and. LEFT(M->WA_PO_DI,1) == 'D' .and. !EMPTY(M->WB_PGTANT) .and. M->WB_PGTANT <> TRB->WB_PGTANT
           MsgInfo(STR0245)//STR0245 "Não é permitida a alteração do valor pago antecipado com compensação automática ligada."
           Return .F.
        EndIf

        If M->WA_PO_DI $ 'CF'
        	If Empty(M->WB_PGTANT) .Or. M->WB_PGTANT <= 0
           		MsgInfo(STR0321)
        		Return .F.
        	EndIF
        EndIf

		If SWB->(FieldPos("WB_PGTASS")) > 0 .AND. !Empty(M->WB_CHVASS)
			aOrdSWASWB := Saveord({"SWA", "SWB"})  // RMD - 14/03/2014

			SWB->(DbSetOrder(1))
			SWB->(DbSeek(M->WB_PGTASS))
			//SWA->(DbSetOrder(1))  // RMD - 14/03/2014
			//If SWA->(dbSeek(xFilial()+SWB->WB_HAWB+SWB->WB_PO_DI)) .And. SWA->WA_SLDANT < M->WB_PGTANT
			nSalApu := SWB->WB_PGTANT - SWB->WB_SLDELI - SWB->WB_SLDTRF - ApuVlComp("SWB")  // GFP - 17/04/2014
			If nSalApu < M->WB_PGTANT
				MsgInfo(STR0336, STR0063)//"Valor da parcela não pode ser maior que o pagamento antecipado associado." ## "Atenção"
				RestOrd(aOrdSWASWB, .T.)
				Return .F.
			EndIf
			RestOrd(aOrdSWASWB, .T.)
		EndIf

		Return .T.

   // SVG - 22/07/09 -
   CASE MFlag == 'TP_CON'
      IF lWB_TP_CON
         If Empty(M->WB_TP_CON)
            MsgInfo(STR0237)
            Return .F.
         EndIf
      ENDIF

   CASE MFlag == 'CORRETO'
        If Select("TRB") > 0 //AAF 06/05/2006 - Não valida se for chamado do FFC.

           //TRP - 14/03/2012 - Nopado pois mesmo para um Câmbio de Adiantamento o sistema deve calcular o valor de Corretagem.
           /*IF lCposAntecip .AND. LEFT(M->WA_PO_DI,1) == "A"
              RETURN .T.
           ENDIF*/

           IF !EMPTY(M->WB_CORRETO)
              SYW->(DBSETORDER(1))
              IF !SYW->(DBSEEK(xFilial()+M->WB_CORRETO))
                 Help("", 1, "AVG0000179")
                 M->WB_VM_CORR := ""
                 lRetorno:=.F.
              ELSE
                 M->WB_VM_CORR := SYW->YW_NOME
                 IF !EMPTY(M->WB_CA_DT) .AND. !EMPTY(M->WB_FOBREAL)
                    If lCposAntecip .AND. LEFT(M->WA_PO_DI,1) == "A" .And. !(LEFT(M->WA_PO_DI,1) $ "CF")
                       SW2->(DBSEEK(XFILIAL()+AvKEY(M->WA_HAWB,"W2_PO_NUM")))
                    Else
                       SW7->(DBSEEK(XFILIAL()+M->WA_HAWB))
                       SW2->(DBSEEK(XFILIAL()+SW7->W7_PO_NUM))
                    Endif

                    IF SW2->W2_MOEDA $ cMoedaDolar  // "US$,USD"
                       If Left(M->WA_PO_DI,1) == "A" // RRV 08/08/2012 - Caso seja pagamento antecipado utiliza o campo de valor antecipado da parcela.
                          nVlUS:=M->WB_PGTANT
                       Else
                          nVlUS:=M->WB_FOBMOE
                       EndIf
                    ElseIf Left(M->WA_PO_DI,1) $ "CF" // GCC - 25/09/2013 - Tratamento para pagamento antecipado vinculado a Fornecedor / Credito
					   nVlUS:=M->WB_PGTANT
					Else
                       nVlUS:=M->WB_FOBREAL / BuscaTaxa(cMoedaDolar,M->WB_CA_DT,,.F.)
                    EndIf

                    IF (nPerc:=PorcCorretor(nVlUS,M->WB_FOBREAL)) # 0
                       M->WB_VL_CORR:= PorcCorretor(nVlUS,M->WB_FOBREAL)
                    ENDIF
                 ENDIF
              ENDIF
           ELSE
              M->WB_VM_CORR := ""
              M->WB_VL_CORR := 0
           ENDIF
           lRefresh:=.T.
        EndIf

   CASE MFlag == 'INVOICE'
      IF lCposAntecip .And. Left(M->WA_PO_DI,1) <> "D"		// GCC - 23/08/2013
         M->WB_MOEDA := SW2->W2_MOEDA//FSY - 13/03/2014 - Carrega o campo WB_MOEDA.
         RETURN .T.
      ENDIF

      IF ! EMPTY(M->WB_INVOICE)
           SW8->(DBSETORDER(1))

           //SE IGUAL DADOS DO F3
           IF SW9->W9_FILIAL+SW9->W9_HAWB+SW9->W9_INVOICE==xFilial("SW9")+M->WA_HAWB+M->WB_INVOICE
              cFornecedor:=SW9->W9_FORN
              IF EICLOJA()
                 cLoj:= SW9->W9_FORLOJ
              ENDIF
           ENDIF
           IF !SW8->(DBSEEK(xFilial()+M->WA_HAWB+M->WB_INVOICE+cFornecedor+IF(EICLOJA(),cLoj,"")))
              Help("", 1, "AVG0000180")
              lRetorno:=.F.
           ENDIF

           If Empty(M->WB_HAWB)
              M->WB_HAWB := M->WA_HAWB
           Endif

           SW9->(DBSETORDER(1))
           //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
           SW9->(DBSEEK(xFilial("SW9")+M->WB_INVOICE+SW8->W8_FORN+EICRetLoja("SW8","W8_FORLOJ")+M->WB_HAWB))

           M->WB_MOEDA := SW9->W9_MOE_FOB//FSY - 13/03/2014 - Carrega o campo WB_MOEDA.

           SA2->(DBSEEK(xFilial("SA2")+SW8->W8_FORN+EICRetLoja("SW8","W8_FORLOJ")))
           M->WB_FORN:=SA2->A2_COD
           IF EICLOJA()
              M->WB_LOJA:= SA2->A2_LOJA
           ENDIF
           M->WB_FORNDES:=SA2->A2_NREDUZ
           SW9->(DBSETORDER(nOrdSW9))
      //** GFC - 18/11/05 - Cambio para frete, seguro, comissão e embarque
      Else
         If Left(SWB->WB_TIPOREG,1) $ ("1/C")
            MsgInfo(STR0121) //"A Invoice deve ser preenchida para parcelas de Principal e de Comissão."
            lRetorno:=.F.
         EndIf
      //**
      ENDIF

   CASE MFlag == 'HOUSE'

        If !(lCposAntecip .And. (LEFT(M->WA_PO_DI,1) $ "AFC"))
           IF EMPTY(ALLTRIM(M->WA_HAWB))
              Help("", 1, "AVG0000181")
              lRetorno:=.F.
           ELSE
              IF ! SW6->(DBSEEK(xFilial()+M->WA_HAWB))
	             Help("", 1, "AVG0000182")
                 lRetorno:=.F.
              ENDIF

              IF lRetorno
                 SW7->(DBSEEK(xFilial()+M->WA_HAWB))
                 IF SW7->W7_FLUXO = "4"
                    Help("", 1, "AVG0000183")
                    lRetorno:=.F.
                 ENDIF
              ENDIF

              IF lRetorno
                 IF SWA->(DBSEEK(xFilial()+M->WA_HAWB+'D'))
                    Help("", 1, "AVG0000184")
                    lRetorno:=.F.
                 ENDIF
              ENDIF
		     ENDIF
        ElseIf LEFT(M->WA_PO_DI,1) $ "A|F|C"
           If LEFT(M->WA_PO_DI,1) == "A"
              //Quando o numero do Pedido vem do F3, o mesmo vem com tamanho de 15
              IF (nTamP:=LEN(M->WA_HAWB)) < (nTamH:=LEN(SWA->WA_HAWB))
                 M->WA_HAWB:=M->WA_HAWB+SPACE(nTamH-nTamP)
              ENDIF
           EndIf
		   SWA->(DbSetOrder(1))
		   lRetorno:=APTemAdto(M->WA_HAWB)
		EndIf

   CASE MFlag == 'DTCONT'
        If Select("TRB") > 0 //AAF 06/05/2006 - Não valida se for chamado do FFC.
           If lCposAntecip .And. (Left(M->WA_PO_DI,1) $ "AFC")	// GCC - 23/08/2013
              Return .T.
           EndIf

           IF !EMPTY(uDado) .AND. uDado < SW6->W6_DT_EMB
              Help("", 1, "AVG0000185")
           ELSE
              IF ! PAlteracao .OR. (TDt_AuxCont#uDado .AND. SY6->Y6_DIAS_PA = -1) .OR. EMPTY(M->WB_LIM_BAC)
                 IF EMPTY(uDado) .and. SY6->Y6_DIAS_PA = -1
                    M->WB_LIM_BAC := AVCTOD('')
                 ELSEIF SY6->Y6_DIAS_PA = -1
                    M->WB_LIM_BAC := uDado + 60 // Data Limite p/ envio do C.I. ao BACEN
                 ELSE
                    M->WB_LIM_BAC := M->WB_DT_VEN
                 ENDIF
                 TDt_AuxCont:=uDado
                 TDt_AuxVen :=M->WB_DT_VEN
              ENDIF
           ENDIF
        EndIf

   CASE MFlag == 'DTROF'
        IF EMPTY(uDado) .AND. ! EMPTY(M->WB_NR_ROF)
           Help("", 1, "AVG0000186")
           lRetorno:=.F.
        ENDIF

   CASE MFlag == 'VENCTO'
        IF EMPTY(uDado)
           Help(" ",1,"VCTOEMBRAN")
           lRetorno:=.F.
        ELSE
           IF ! PAlteracao .OR. (TDt_AuxVen#uDado .and. SY6->Y6_DIAS_PA # -1) .OR. EMPTY(M->WB_LIM_BAC)
              IF EMPTY(M->WB_DT_CONT) .AND. SY6->Y6_DIAS_PA = -1
                 M->WB_LIM_BAC := AVCTOD('')
              ELSEIF SY6->Y6_DIAS_PA = -1
                 M->WB_LIM_BAC := M->WB_DT_CONT + 60 // Data Limite p/ envio do C.I. ao BACEN
              ELSE
                 M->WB_LIM_BAC := M->WB_DT_VEN
              ENDIF
              TDt_AuxCont:=M->WB_DT_CONT
              TDt_AuxVen :=M->WB_DT_VEN
           ENDIF
        ENDIF

   CASE MFlag == 'DTLIMBAC'
        IF EMPTY(uDado) .And. !Empty(M->WB_DT_CONT) //MCF - 17/04/2015 - A data de limite do envio será obrigatório
        	Help("", 1, "AVG0000187")			      //quando a data de contratação estiver preenchido.
        	lRetorno:=.F.
        ENDIF

   CASE MFlag == 'DT'
        IF EMPTY(M->WB_DT) .AND. ! EMPTY(M->WB_NUM)
           Help(" ",1,"AVISOBRANC")
           lRetorno:=.F.
        ENDIF

   CASE MFlag == "LC"
        IF ! EMPTY(uDado)
           IF ! SWC->(DBSEEK(xFilial()+uDado))
              Help(" ",1,"LCNAOCAD")
              lRetorno:=.F.
           ELSE
              IF SYH->(DBSEEK(xFilial()+uDado))
                 _Tamanho:=LEN(IF(SWC->WC_BASE=="2",TabPo,TabPgi))
                 DO WHILE ! SYH->(EOF()) .AND. SYH->YH_LC_NUM == uDado .AND. xFilial("SYH")=SYH->YH_FILIAL
                    IF SWC->WC_BASE == "2"
                       FOR Wind = 1 TO _Tamanho
                           IF TabPo[wind] == SYH->YH_PO_GI
                              _Encontrou:= .T.
                              EXIT
                           ENDIF
                       NEXT
                    ELSE
                       FOR Wind = 1 TO _Tamanho
                           IF TabPgi[wind] == LEFT(SYH->YH_PO_GI,10)
                              _Encontrou:= .T.
                              EXIT
                           ENDIF
                       NEXT
                    ENDIF
                    SYH->(DBSKIP())
                 ENDDO
                 IF ! _Encontrou
                    Help("", 1, "AVG0000188")
                    lRetorno:=.F.
                 ENDIF
              ENDIF
              IF lRetorno .AND. ! EMPTY(SWC->WC_BANCO) .AND. ! EMPTY(SWC->WC_AGENCIA)
                 M->WB_BANCO  :=SWC->WC_BANCO
                 M->WB_AGENCIA:=SWC->WC_AGENCIA
              ENDIF
           ENDIF
        ENDIF

   CASE MFlag == "BCO"

        //cRno := SA6->(Recno())// SVG - 16/09/2010 -
        If !Empty(uDado)
           SA6->(DBSEEK(xFilial()+uDado)) //MCF - 21/07/2015
        Endif

        If Empty(uDado)
           If !Empty(M->WB_NUM)
              Help(" ",1,"BCOBRANCO")
              lRetorno:=.F.
           EndIf
        //LRS - 18/05/2016 - Nopado pois foi criado consulta padrão para retorno correto dos campos BCOEIC
        /* M->WB_DES_BCO:=""
           M->WB_AGENCIA:=""
           M->WB_CONTA  :=""

        ElseIf SA6->A6_COD == uDado
           M->WB_DES_BCO:=SA6->A6_NREDUZ
           M->WB_AGENCIA:=SA6->A6_AGENCIA // SVG - 16/09/2010 -
           M->WB_CONTA  :=SA6->A6_NUMCON
        */
        Else
        //DFS - 04/10/2010 - Criação de tratamento para posicionar corretamente na conta selecionada.
           If !Empty(M->WB_AGENCIA) .AND. !Empty(M->WB_CONTA)
              If !SA6->(DBSEEK(xFilial()+uDado+M->WB_AGENCIA+M->WB_CONTA))//uDado))
                 Help(" ",1,"BCONAOCAD")
                 lRetorno:=.F.
              EndIf
           ElseIf !Empty(M->WB_AGENCIA)
              If !SA6->(DBSEEK(xFilial()+uDado+M->WB_AGENCIA))
                 Help(" ",1,"BCONAOCAD")
                 lRetorno:=.F.
              Endif
           Else
              If !SA6->(DBSEEK(xFilial()+uDado))
                 Help(" ",1,"BCONAOCAD")
                 lRetorno:=.F.
              Endif
           EndIf
        EndIf

        //RMD - 31/10/16 - Preenche os campos de indicação de contrato de câmbio ou movimento no exterior.
        If SWB->(FieldPos("WB_MODAL")) > 0 .And. TRB->(FieldPos("WB_MOEDA")) > 0
           If SA6->A6_MOEDA == 1
              M->WB_MODAL := "1"
              M->WB_PRINBC := 0
              M->WB_VLMBCO := 0
           Else
              M->WB_MODAL  := "2"
              If !Empty(M->WB_CA_DT)
                 AP100GATDT(2)
              EndIf
           EndIf
        EndIf

        //THTS - 13/09/2017 - Valida moeda do Banco
        If lRetorno
            lRetorno := APE100Crit("TAXABCO")
        EndIf
        //LRS - 24/10/2017 - Validar a conta bloqueada
        If lRetorno .AND. !Empty(M->WB_BANCO) .AND. !Empty(M->WB_AGENCIA) .AND. !Empty(M->WB_CONTA)
           lRetorno := APE100Crit('CONTA')
        EndIF
        //SA6->(DbGoTo(cRno)) // SVG - 16/09/2010 -

   CASE MFlag == "AGE"

        //cRno := SA6->(Recno())// SVG - 16/09/2010 -

        If !Empty(uDado)
           If Empty(M->WB_BANCO)
              Help("", 1, "AVG0000189")
              lRetorno:=.F.
           Else
                // SVG - 16/09/2010 - Pode ja estar posicionado via F3
              If SA6->A6_AGENCIA <> M->WB_AGENCIA .OR.  SA6->A6_COD <> M->WB_BANCO
                 If !SA6->(DbSeek(xFilial("SA6")+M->WB_BANCO+uDado))
                    Help("", 1, "AVG0000189")
                    lRetorno:=.F.
                 EndIf

              EndIf
           EndIf
        EndIf
        /*// SVG - 16/09/2010 - //LRS - 18/04/18 - Nopado para não gatilhar campo conta se estiver digitando os campos na mao
        If SA6->A6_AGENCIA == uDado
           M->WB_DES_BCO:=SA6->A6_NREDUZ
           M->WB_AGENCIA:=SA6->A6_AGENCIA
           M->WB_CONTA  :=SA6->A6_NUMCON
        EndIf*/
        //RMD - 31/10/16 - Preenche os campos de indicação de contrato de câmbio ou movimento no exterior.
        If SWB->(FieldPos("WB_MODAL")) > 0 .And. TRB->(FieldPos("WB_MOEDA")) > 0
           If SA6->A6_MOEDA == 1
              M->WB_MODAL := "1"
              M->WB_PRINBC := 0
              M->WB_VLMBCO := 0
           Else
              M->WB_MODAL  := "2"
              If !Empty(M->WB_CA_DT)
                 AP100GATDT(2)
              EndIf
           EndIf
        EndIf

        //LRS - 24/10/2017 - Validar a conta bloqueada
        If lRetorno .AND. !Empty(M->WB_BANCO) .AND. !Empty(M->WB_AGENCIA) .AND. !Empty(M->WB_CONTA)         
           lRetorno := APE100Crit('CONTA')
        EndIF

        //SA6->(DbGoTo(cRno))// SVG - 16/09/2010 -

   CASE MFlag == "CONTA"
        
        uDado:=M->WB_CONTA
        If lRetorno .AND. !Empty(M->WB_BANCO) .AND. !Empty(M->WB_AGENCIA) .AND. !Empty(M->WB_CONTA) 
            If SA6->(DbSeek(xFilial("SA6")+M->WB_BANCO+M->WB_AGENCIA+uDado))            
                IF SA6->A6_BLOCKED == "1" //LRS - 19/10/2017
                    Help( " ", 1, "CCBLOCKED" )
                    Return .F.
                EndIF
            EndIF
        EndIF

        If !Empty(uDado)
           If Empty(M->WB_BANCO)
              MsgStop(STR0132)  //"Conta não cadastrada para este Banco/Agencia"
              lRetorno:=.F.
           Else
              If !SA6->(DbSeek(xFilial("SA6")+M->WB_BANCO+M->WB_AGENCIA+uDado))
                 MsgStop(STR0132)  //"Conta não cadastrada para este Banco/Agencia"
                 lRetorno:=.F.
              EndIf
           EndIf
        EndIf
        
        //RMD - 31/10/16 - Preenche os campos de indicação de contrato de câmbio ou movimento no exterior.
        If SWB->(FieldPos("WB_MODAL")) > 0 .And. TRB->(FieldPos("WB_MOEDA")) > 0
           If SA6->A6_MOEDA == 1
              M->WB_MODAL := "1"
              M->WB_PRINBC := 0
              M->WB_VLMBCO := 0
           Else
              M->WB_MODAL  := "2"
              If !Empty(M->WB_CA_DT)
                 AP100GATDT(2)
              EndIf
           EndIf
        EndIf

        //SA6->(DbGoTo(cRno)) SVG

   CASE MFlag == "BCOREC"

        cRno := SA6->(Recno())

        If Empty(uDado)
           If !Empty(M->WB_CON_REC)
              Help(" ",1,"BCOBRANCO")
              lRetorno:=.F.
           EndIf

           M->WB_DESBCOR:=""
        Else
           If !SA6->(DBSEEK(xFilial()+uDado))
              Help(" ",1,"BCONAOCAD")
              lRetorno:=.F.
           EndIf
        EndIf

        SA6->(DbGoTo(cRno))

        If SA6->A6_COD == uDado
           M->WB_DESBCOR:=SA6->A6_NREDUZ
           M->WB_AGENREC:=SA6->A6_AGENCIA
        EndIf

   CASE MFlag == "AGEREC"

        cRno := SA6->(Recno())

        If !Empty(uDado)
           If !SA6->(DbSeek(xFilial("SA6")+M->WB_BCO_REC+uDado))
              Help("", 1, "AVG0000189")
              lRetorno:=.F.
           EndIf
        EndIf

        SA6->(DbGoTo(cRno))

   CASE MFlag == "CAMBIO"
        IF EMPTY(uDado)
           M->WB_FOBREAL:=0
        ENDIF
        lRefresh:=.T.

        //ACB 03/08/2010 //atribuido valor a variel de memória para que não venha nill e gere erro.
        If Type("M->WA_PO_DI") == "U"
           M->WA_PO_DI   := SWB->WB_PO_DI
        End If

        //NCF - 10/06/2010 - Não valida se existir mais de um PA com mesmo No. de contrato quando integrado com compras e financeiro
//      IF !Empty(M->WB_CA_NUM) .And. EasyGParam("MV_EASYFIN",,"N") == "S" .And.  LEFT(M->WA_PO_DI,1) == "A"
        IF !Empty(M->WB_CA_NUM) .And. EasyGParam("MV_EASYFIN",,"N") == "S" .And.  (LEFT(M->WA_PO_DI,1) == "A" .Or. LEFT(M->WA_PO_DI,1) == "F" .Or. LEFT(M->WA_PO_DI,1) == "C")
           aOrdSWB := SaveOrd("SWB")
           SWB->(DbSetOrder(6))
           IF SWB->(DbSeek(xFilial()+M->WB_CA_NUM))
              Do While !SWB->(EOF()) .And. SWB->(xFilial()) == SWB->WB_FILIAL .And.;
                        SWB->WB_CA_NUM == M->WB_CA_NUM .And. SWB->(RecNo()) <> If(Select("TRB") > 0,TRB->WB_RECNO,Work1->WKREC_SWB)
//                 If SWB->WB_PO_DI == "A" .And. !EasyGParam("MV_EIC0006",,.F.)                      //NCF - 23/10/2010 - Parametro para definir execução da validação
                 If (SWB->WB_PO_DI == "A" .Or. SWB->WB_PO_DI == "F" .Or. LEFT(M->WA_PO_DI,1) == "C") .And. !EasyGParam("MV_EIC0006",,.F.)                      //NCF - 23/10/2010 - Parametro para definir execução da validação // GCC - 23/08/2013
                    MsgStop(STR0246+CHR(13)+CHR(10)+STR0247, STR0079) //STR0246 "Já existe parcela de adiantamento com este número de contrato" //STR0247 "Insira outro número de contrato"  //STR0079 "Aviso"
                    lRetorno := .F.
                    Exit
                 Else
                    SWB->(DbSkip())
                 EndIf
              EndDo
           ENDIF
           RestOrd(aOrdSWB, .T.)
        ENDIF

   CASE MFlag == "TAXA"
      If Select("TRB") > 0 //AAF 06/05/2006 - Não valida se for chamado do FFC.
         IF ! EMPTY(M->WB_CA_DT) .AND. EMPTY(uDado)
            Help(" ",1,"TXBRANCO")
            lRetorno:=.F.
         ENDIF
      
         //THTS - 13/09/2017 - Valida moeda do Banco
         If lRetorno
            lRetorno:= APE100Crit("TAXABCO")
         EndIf

         IF lRetorno
            IF EMPTY(M->WB_CA_DT)
               M->WB_CA_TX:=0
            ENDIF
            IF (Left(TRB->WB_PO_DI,1) == "A" .Or. Left(TRB->WB_PO_DI,1) == "F" .Or. Left(TRB->WB_PO_DI,1) == "C") .AND. Left(M->WB_TIPOREG,1) == "P"
               M->WB_FOBREAL:=Round(Ape_Vl_Real((M->WB_PGTANT - M->WB_DESCO),M->WB_CA_TX), AvSx3("WB_FOBREAL", AV_DECIMAL))//FDR - 22/11/13
               M->WB_VLIQ := M->WB_PGTANT - M->WB_DESCO
            ELSE
               M->WB_FOBREAL:=Round(Ape_Vl_Real((M->WB_FOBMOE - M->WB_DESCO),M->WB_CA_TX), AvSx3("WB_FOBREAL", AV_DECIMAL))//FDR - 22/11/13
               M->WB_VLIQ := M->WB_FOBMOE - M->WB_DESCO
            ENDIF
            
         ENDIF
           
         lRefresh:=.T.
         //RMD - 31/10/16 - Preenche os campos de indicação de contrato de câmbio ou movimento no exterior.
         If lRetorno .And. SWB->(FieldPos("WB_PRINBC")) > 0 .And. M->WB_MODAL == "2" .And. !Empty(M->WB_CA_DT) .And. !Empty(M->WB_CA_TX) .And. !Empty(Posicione("SA6", 1, xFilial("SA6")+M->(WB_BANCO+WB_AGENCIA+WB_CONTA), "A6_MOEEASY"))
            M->WB_PRINBC := M->WB_CA_TX / BuscaTaxa(Posicione("SA6", 1, xFilial("SA6")+M->(WB_BANCO+WB_AGENCIA+WB_CONTA), "A6_MOEEASY"), M->WB_CA_DT)
            M->WB_VLMBCO := Round(M->WB_PRINBC * M->WB_FOBMOE, AvSx3("WB_FOBREAL", AV_DECIMAL))
         Else
            M->WB_PRINBC := 0
            M->WB_VLMBCO := 0
         EndIf
      EndIf

   CASE MFlag == "CADT"
        If Select("TRB") > 0 //AAF 06/05/2006 - Muda a validação caso a chamada seja do FFC.
           If Empty(M->WB_HAWB)
              M->WB_HAWB := M->WA_HAWB
           Endif
           //acb - 18/10/2010
           SW9->(DBSETORDER(1))
           //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
           SW9->(DBSEEK(xFilial("SW9")+M->WB_INVOICE+TRB->WB_FORN+EICRetLoja("TRB","WB_LOJA")+M->WB_HAWB))
           IF EMPTY(M->WB_CA_DT)
              M->WB_CA_TX  := 0
              M->WB_FOBREAL:=0
//           ELSEIF lCposAntecip .AND. LEFT(M->WA_PO_DI,1) == "A" .AND. EMPTY(M->WB_PGTANT)
           ELSEIF lCposAntecip .AND. (LEFT(M->WA_PO_DI,1) == "A" .Or. LEFT(M->WA_PO_DI,1) == "F" .Or. LEFT(M->WA_PO_DI,1) == "C") .AND. EMPTY(M->WB_PGTANT)	// GCC - 23/08/2013
              Help(" ",1,"AVG0005366") //LRL 08/01/04 MSGINFO("Valor do Pagamento Antecipado nao preenchido.",STR0043)
              RETURN .F.
           ElseIf lEFFTpMod .and. lEIC_EFF .and.;
           (nPos := aScan(aVincula, {|x| x[9]==TRB->WB_INVOICE .and. x[10]==If(!Empty(TRB->WB_PARFIN), TRB->WB_PARFIN, TRB->WB_LINHA) })) > 0 .and.;
           !Empty(aVincula[nPos,3]) .and. M->WB_CA_DT < aVincula[nPos,11]
              MsgInfo(STR0125+" ("+DtoC(EF3->EF3_DT_EVE)+").") //"A Data de Liquidação não pode ser menor que a Data de Vinculação" ###
              Return .F.
//             ElseIf EasyGParam("MV_EASYFIN",,"N") == "S" .and. LEFT(M->WA_PO_DI,1) # "A";
             ElseIf EasyGParam("MV_EASYFIN",,"N") == "S" .and. (LEFT(M->WA_PO_DI,1) # "A" .And. LEFT(M->WA_PO_DI,1) # "F" .And. LEFT(M->WA_PO_DI,1) # "C");	// GCC - 23/08/2013
                    .and. M->WB_HAWB == SW9->W9_HAWB .AND. M->WB_INVOICE == SW9->W9_INVOICE
                If M->WB_CA_DT < SW9->W9_DT_EMIS
                   MsgInfo(STR0239,"ATENÇÃO")
                   Return .F.
                EndIf
           ENDIF
           //RMD - 31/10/16 - Preenche os campos de indicação de contrato de câmbio ou movimento no exterior.
           If SWB->(FieldPos("WB_MODAL")) > 0 .And. TRB->(FieldPos("WB_MOEDA")) > 0 .And. M->WB_MODAL <> "1" .And. !Empty(M->WB_CA_DT)
              AP100GATDT(2)
           EndIf
           lRefresh:=.T.
        ElseIf lEIC_EFF .and. lEFFTpMod
           //** AAF 06/05/2006
           nRec := Work1->( RecNo() )
           Work1->( dbGoTop() )
           Do While !Work1->( EoF() )
              If EF3->(dbSetOrder(7), dbSeek(xFilial("EF3")+"I"+Work1->W6_HAWB+Work1->A2_COD+Work1->WB_LOJA+Work1->WB_INVOICE+Work1->WB_LINHA+EV_EMBARQUE)) .OR.;
                 EF3->(dbSetOrder(2), dbSeek(xFilial("EF3")+"I"+EV_EMBARQUE+Work1->EEQ_NRINVO+Work1->EEQ_PARC))

                 If M->WB_CA_DT < EF3->EF3_DT_EVE
                    MsgInfo(STR0125+" ("+DtoC(EF3->EF3_DT_EVE)+").")  //"A Data de Liquidação não pode ser menor que a Data de Vinculação" ###
                    Return .F.
                 EndIf
              EndIf

              // * FSM - 29/03/2012
              SW6->(DBSetOrder(1))//W6_FILIAL+W6_HAWB
              SW9->(DBSetOrder(1))//W9_FILIAL+W9_INVOICE+W9_FORN+W9_FORLOJ+W9_HAWB
              If SW6->( DBSeek(xFilial("SW6") + Work1->W6_HAWB ) ) .And.;
                 SW9->( DBSeek(xFilial("SW9") + Work1->WB_INVOICE + Work1->A2_COD + Work1->WB_LOJA  + Work1->W6_HAWB  ) )

                 dEmissao := &(Iif(Empty(EasyGParam("MV_DTEMIS",,"SW9->W9_DT_EMIS")),"SW9->W9_DT_EMIS",EasyGParam("MV_DTEMIS",,"SW9->W9_DT_EMIS")))

                 If M->WB_CA_DT < dEmissao
                     MsgInfo(STR0313,STR0079) //#"A data de liquidação deve ser maior que todas as datas de Emissão de invoices dos processos do lote." ##"Aviso"
                     Return .F.
                 EndIf

              EndIf
              // * FSM

              Work1->( dbSkip() )
           EndDo

           Work1->( dbGoTo(nRec) )
           // **
        EndIf

   CASE MFlag == "FOB"
        IF lCposAntecip .AND. Left(M->WB_TIPOREG,1) == "P"
           RETURN .T.
        ENDIF

//      IF EMPTY( uDado )
//         Help(" ",1,"FOBBRANCO")
//         lRetorno:=.F.
//      ENDIF

        IF lRetorno .AND. uDado < 0
           Help(" ",1,"FOBNEGATIV")
           lRetorno:=.F.
        ENDIF

        IF lRetorno
           _MRecord:= SWB->(RECNO())
           SWB->(DBSEEK(xFilial()+M->WA_HAWB+M->WA_PO_DI))
           SWB->(DBEVAL({ || _Soma += WB_FOBMOE },,;
                         {|| WB_FILIAL = xFilial("SWB") .And. WB_HAWB = M->WA_HAWB ;
                             .And. WB_PO_DI = M->WA_PO_DI}))
           SWB->(DBGOTO(_MRecord))

           If PAlteracao
              SWB->(DBGOTO(TRB->WB_RECNO))
           ENDIF

           _Soma-= IF(PAlteracao,SWB->WB_FOBMOE,0)

           M->WB_FOBREAL:=Ape_Vl_Real(M->WB_FOBMOE,M->WB_CA_TX)
        ENDIF
        lRefresh:=.T.

        APE100Crit("DESCONTO")  // GFP - 21/08/2015

        //AAF 21/11/05 - Validação para Demurrage no Câmbio da Importação.
        If lRetorno .AND. Left(M->WB_TIPOREG,1) == 'D'
           lRetorno := DM100ValImp()
        Endif

   CASE MFlag == "CEDENTE"
        IF M->WA_CODCEDE # '1' .AND. M->WA_CODCEDE # '2'
           Help("", 1, "AVG0000190")
           lRetorno:=.F.
        ELSE
           IF M->WA_CODCEDE = '1'
              SWB->(DbSeek(xFilial("SWB")+M->WA_HAWB))    // GFP - 29/01/2013
              SA2->(DbSeek(xFilial("SA2")+SWB->WB_FORN+SWB->WB_LOJA))  // GFP - 29/01/2013
              M->WA_CEDENTE:= IF(_OkForn,SA2->A2_NREDUZ,SPACE(20))
              M->WA_CEDENTE:= M->WA_FB_NOME
           ELSE
              M->WA_CEDENTE:= IF(SA6->(DBSEEK(xFilial()+SA2->A2_BANCO)),SUBST(SA6->A6_NOME,1,20),SPACE(20))
//            M->WA_CEDENTE:= M->WA_BC_NOME
           ENDIF
        ENDIF

   CASE MFlag == "SOMA"
        IF lCposAntecip .AND. nTipo == 4
           IF LEFT(M->WA_PO_DI,1)=='D' .AND. Left(M->WB_TIPOREG,1)<>'P' .AND. M->WB_PGTANT > 0 ;
              .AND. (M->WB_PGTANT + M->WB_FOBMOE) > (TRB->WB_PGTANT + TRB->WB_FOBMOE)
              MSGINFO(STR0133 + CHR(13)+CHR(10) +;  //"Atencao! Vl.antecipado + vl.parcela esta maior que "
                      STR0205,STR0043)        //"o vl. original da parcela!"
              RETURN .F.
           ENDIF
        ENDIF
		RETURN .T.

   //** GFC - 23/11/05 - Câmbio de frete, seguro, comissão e embarque
   CASE MFlag == "TIPOREG"
        IF lWB_TP_CON
           If Left(M->WB_TIPOREG,1) == "C"
              If Empty(M->WB_HAWB)
                 M->WB_HAWB := M->WA_HAWB
              Endif
              //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
              If SW9->(DBSEEK(xFilial("SW9")+M->WB_INVOICE+M->WB_FORN+EICRetLoja("M","WB_LOJA")+M->WB_HAWB))
                 M->WB_TIPOCOM := SW9->W9_TIPOCOM
              Else
                 M->WB_TIPOCOM := "1"
              EndIf
           /*Else
              M->WB_TIPOCOM := ""*/
           EndIf

           If Left(M->WB_TIPOREG,1) $ ("ABC")
              M->WB_TP_CON := "4"
              If Left(M->WB_TIPOREG,1) $ ("AB") .and. SW6->(DBSEEK(xFilial("SW6")+M->WA_HAWB))
                 M->WB_FORN   := If(Left(M->WB_TIPOREG,1)="A", SW6->W6_FORNECF, SW6->W6_FORNECS)
                 M->WB_LOJA   := If(Left(M->WB_TIPOREG,1)="A", SW6->W6_LOJAF, SW6->W6_LOJAS)
                 M->WB_MOEDA  := If(Left(M->WB_TIPOREG,1)="A", SW6->W6_FREMOED, SW6->W6_SEGMOED)
                 M->WB_DT_VEN := If(Left(M->WB_TIPOREG,1)="A", SW6->W6_VENCFRE, SW6->W6_VENCSEG)
                 IF If(Left(M->WB_TIPOREG,1)="A", SW6->W6_DIASP_F, SW6->W6_DIASP_S) < 900
                    M->WB_FOBMOE := If(Left(M->WB_TIPOREG,1)="A", SW6->W6_VLFRECC, SW6->W6_VL_USSE)
                 EndIf
              ElseIf Left(TRB->WB_TIPOREG,1) $ ("AB") .and. SW6->(DBSEEK(xFilial("SW6")+M->WA_HAWB))
                 M->WB_FORN   := ""
                 M->WB_LOJA   := ""
                 M->WB_MOEDA  := ""
                 M->WB_DT_VEN := AvCtoD("")
                 M->WB_FOBMOE := 0
              EndIf
           ElseIf Left(M->WB_TIPOREG,1) = "1"
              M->WB_TP_CON := "2"
           /*Else
              M->WB_TP_CON := ""*/
           EndIf
        ENDIF
   //**

   Case MFlag == "FORNECE"
		If M->WB_PO_DI $ "CF"
			/*If Empty(M->WB_FORN)
				MsgInfo(STR0322)	//-- Conteúdo inválido para os campos Fornecedor e/ou Loja!
				Return .F.
			Else*/
				If !SA2->(DbSeek(xFilial("SA2")+M->WB_FORN))
					MsgInfo(STR0323)	//-- Fornecedor informado não esta cadastrado!
					Return .F.
				EndIf
			//EndIF
		EndIf

   Case MFlag == "LOJA"
		If M->WB_PO_DI $ "CF"
			If Empty(M->WB_LOJA)
				MsgInfo(STR0322)	//-- Conteúdo inválido para os campos Fornecedor e/ou Loja!
				Return .F.
			Else
				If !SA2->(DbSeek(xFilial("SA2")+M->WB_FORN+M->WB_LOJA))
					MsgInfo(STR0323)	//-- Fornecedor informado não esta cadastrado!
					Return .F.
				EndIf
			EndIF
		EndIf

   Case MFlag == "CHVASS"
	    If Empty(M->WB_CHVASS)
	    	M->WB_PGTASS := ""
	    	Return .T.
	    EndIf

	    If !Empty(M->WB_CHVASS)
			If Upper(AllTrim(Ap100PGTASS(M->WB_PGTASS))) <> Upper(AllTrim(M->WB_CHVASS))
				MsgInfo(STR0337, STR0063)//"Utilize a consulta padrão (F3) para selecionar um pagamento antecipado" ## "Atenção"
				Return .F.
			EndIf
		EndIf

		Return .T.
	// GFP - 21/08/2015
	CASE MFlag == 'DESCONTO'
   
      If Left(TRB->WB_PO_DI,1) == "D" // MPG - 26/09/2019

         if M->WB_FOBMOE < M->WB_DESCO
            msginfo(STR0391,STR0063) //"O desconto não pode ser maior que o valor da parcela","Atenção"
            Return .F.
         else
            M->WB_VLIQ := M->WB_FOBMOE - M->WB_DESCO
            M->WB_FOBREAL := (M->WB_FOBMOE - M->WB_DESCO) * M->WB_CA_TX
            Return .T.
         endif

      ELSEIf (Left(TRB->WB_PO_DI,1) == "A" .Or. Left(TRB->WB_PO_DI,1) == "F" .Or. Left(TRB->WB_PO_DI,1) == "C") // MPG - 26/09/2019

         if M->WB_PGTANT < M->WB_DESCO
            msginfo(STR0392,STR0063) //"O desconto não pode ser maior que o valor do adiantamento","Atenção"
            Return .F.
         else
            M->WB_VLIQ := M->WB_PGTANT - M->WB_DESCO
            M->WB_FOBREAL := (M->WB_PGTANT - M->WB_DESCO) * M->WB_CA_TX
            Return .T.
         endif

      ENDIF
    // MCF - 30/12/2015
	CASE MFlag == 'MOEDA'
	   SYE->(DBSETORDER(2))
	   IF !SYE->(DBSEEK(xFilial()+M->WB_MOEDA))
	      Help("", 1, "AVG0000359")//'Não existe cotação para esta moeda'###"Informação"
	      SYE->(DBSETORDER(1))
	      Return .F.
	   ENDIF
    
    Case MFlag == "TAXABCO" //THTS - 13/09/2017

        //NCF - 31/07/2017 - Validação da liquidação em banco de moeda estrangeira
        If EasyGParam("MV_EASYFIN",,"N") == "S" .And. !Empty(M->WB_BANCO) // THTS - 12/09/2017 - Nao valida moeda do banco se o banco nao estiver preenchido
           cMoeLocal := Alltrim(EasyGParam("MV_SIMB1"))
           cNumMoeda := Alltrim(STR(SA6->A6_MOEDA)) //THTS - 12/09/2017 - Moeda Cadastrada no Banco
           cMoeBanco := If( !Empty(SA6->A6_MOEEASY), SA6->A6_MOEEASY , EasyGParam( "MV_SIMB"+cNumMoeda,.F.,cNumMoeda) ) //THTS - 12/09/2017 - Se nao existir o parametro, retorna o numero da moeda           
           cMoeCambi := M->WB_MOEDA

           If cMoeBanco <> cMoeLocal
              If cMoeBanco <> cMoeCambi .AND. !EasyGParam("MV_MOEDBCO",, .F.)
                 MsgStop(STR0376+cMoeCambi+STR0377+cMoeBanco,STR0063) //#"Não é possível liquidar um título da moeda XXX" #" utilizando uma conta bancária em banco de moeda YYY"
                 lRetorno:=.F.
              /*Else
                 If "M->WB_CA_TX" == UPPER(READVAR()) .And. M->WB_CA_TX <> 1
                    MsgInfo(STR0378,STR0063) //#"Taxa para liquidação não pode ser diferente de 1 pois a moeda do título e da conta bancária são iguais!"
                 EndIf              
                 M->WB_CA_TX := 1*/
              EndIf
           EndIf
        EndIf

ENDCASE
lRefresh:=.t.

IF(EasyEntryPoint("EICAP100"),Execblock("EICAP100",.F.,.F.,"APOS_VALID_SWB"),)


RETURN lRetorno

*-------------------*
FUNCTION Ape_BrwBco()
*-------------------*
RETURN WB_BANCO + " " + Ape_Bco(WB_BANCO+WB_AGENCIA+IF(TRB->(FIELDPOS("WB_CONTA"))#0,TRB->WB_CONTA,""),'NOME') + " " + WB_AGENCIA

*--------------------------------*
FUNCTION Ape_Bco(_Codigo,_QualRet)
*--------------------------------*
IF SA6->(DBSEEK(xFilial()+_Codigo))
   RETURN IF( _QualRet = 'NOME',SA6->A6_NREDUZ, SA6->A6_AGENCIA )
ELSE
   RETURN SPACE(38)
ENDIF

lRefresh:=.t.

RETURN .T.

Function parcAlterd()
    IF (LEFT(SWA->WA_PO_DI,1) == "A" .Or. LEFT(SWA->WA_PO_DI,1) == "F" .Or. LEFT(SWA->WA_PO_DI,1) == "C") .AND. TRB->WB_PGTANT # SWB->WB_PGTANT .OR. SWB->WB_DT_VEN <> TRB->WB_DT_VEN	// GCC - 23/08/2013
        Return .T.
    ELSEIF TRB->WB_FOBMOE # SWB->WB_FOBMOE .OR. SWB->WB_DT_VEN <> TRB->WB_DT_VEN
        Return .T.
    ENDIF
Return .F.

*------------------------------------------*
FUNCTION ApeManutSWB(nTipo,lEstAdt)
*------------------------------------------*
Local oDlg, cAlias:=Alias(), nReg1, /*MSaldo:=0 MSaldo_A:=0*/ cNewTit:='', WIND , I
//** GFC - 23/11/05 - Câmbio de frete, seguro, comissão e embarque
Local aValorAd101 := {}
Local aPo 		  := {}
Local cCtrl 	  := ""
Local cFornPar	  := ""
Local cLojaPar	  := ""
Local cMoedaPar   := ""
Local nInc
Local nPos
Local nPos2
Local lBaixouP    := .F.
Local lFinanceiro := GetNewPar("MV_EASYFIN","N")=="S"// .AND. GetNewPar("MV_EASY","N")=="S"
Local lBxConc     := EasyGParam("MV_BXCONC",.T.,.F.) == "1"
Local nRecSWA     := SWA->(Recno())
Local aOrdSE2     := SaveOrd({"SE2"}) //LGS-07/07/2016
Private lParcFilha:= If (EasyGParam("MV_GERFILH",,"S")=="S",.T.,.F.) //CCH - 06/04/09 - Tratamento para Alteração/Inclusão/Exclusão de Parcelas no Câmbio
Private lBaixa    :=.T. //SVG - 22/10/09 -                      //Caso seja alterada uma parcela, o parâmetro irá controlar se será gerado nova parcela com a diferença
//                                                             //ou apenas abaterá o valor da parcela principal
Private aSWB,aButtons:= NIL,nManut:=nTipo, nTotParc := 0, lVolta
Private aSWA_OLD  := {}
Private aTRB_OLD  := {}

//EJA - 20/12/2018
SWB->(dbSetOrder(1))//WB_FILIAL+WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN+WB_LOJA+WB_LINHA
SWB->(dbSeek(xFilial("SWB") +  TRB->( WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN+WB_LOJA+WB_LINHA  )   ))
// Se a parcela foi alterada, o sistema deve impedir a liquidação ou estorno.
If (nTipo == 6 .Or. nTipo == 7) .And. parcAlterd()
    EasyHelp(STR0384, STR0079)
    Return .F.
EndIf
// Se a parcela foi estornada, o sistema deve impedir a liquidação
If nTipo == 6 .And. (TRB->WB_CA_DT <> SWB->WB_CA_DT) .And. Empty(TRB->WB_CA_DT)
    EasyHelp(STR0385, STR0079)
    Return .F.
EndIf
// Se a parcela foi liquidada, o sistema deve impedir o estorno
If nTipo == 7 .And. (TRB->WB_CA_DT <> SWB->WB_CA_DT) .And. !Empty(TRB->WB_CA_DT)
    EasyHelp(STR0386, STR0079)
    Return .F.
EndIf
// Se opção foi alterarada, e a parcela foi liquidada ou estornada, não permitir alteração
If nTipo == 4 .And. (TRB->WB_CA_DT <> SWB->WB_CA_DT)
    EasyHelp(STR0387, STR0079)
    Return .F.
EndIf

If nTipo == 5 //Exclusão
   If !lEstAdt .And. Left(TRB->WB_PO_DI,1) == "D" .AND. Left(TRB->WB_TIPOREG,1) == "P"
      EasyHelp(STR0405, STR0079) // Não é possível excluir uma parcela de adiantamento associado. Utilize a opção de menu "Estornar Associação". //STR0079 "Aviso"
      Return .F.
   EndIf
   If lEstAdt .And. Left(TRB->WB_PO_DI,1) == "D" .AND. Left(TRB->WB_TIPOREG,1) != "P"
      EasyHelp(STR0406, STR0079) // 'A opção de Menu "Estornar Associação" deve ser utilizada em parcelas de Adiantamento.' //STR0079 "Aviso"
      Return .F.
   EndIf
   /* trecho comentado por RNLP - OSSME-5438
   If lEstAdt .And. Left(TRB->WB_PO_DI,1) == "D" .And. TRB->WB_TIPOREG == "P" .And. !CANESTSEQ(TRB->WB_CHAVE, TRB->WB_FILORI, TRB->WB_NUMPO, TRB->WB_INVOICE, TRB->WB_FORN, TRB->WB_LOJA, TRB->WB_LINHA)
      EasyHelp("Não é possível estornar a associação deste adiantamento, pois a parcela de câmbio possui um outro adiantamento associado. Para prosseguir, deve ser estornada a última associação efetuada primeiro.",STR0079)//""###"Aviso"
      Return .F.
   EndIf
   */
EndIf

If EasyGParam("MV_EASYFIN",,"N") == "S" .And. EasyGParam("MV_CTLIPAG",,.F.) .AND. nTipo == 6 //MCF - 18/08/2016 - Acrescido validação para apenas quando for estorno //LGS-07/07/2016
   SE2->(DbSetOrder(6))
   If SE2->(dbSeek(xFilial("SE2")+TRB->(WB_FORN+WB_LOJA+WB_PREFIXO+WB_NUMDUP+WB_PARCELA+WB_TIPOTIT)))
      If Empty(SE2->E2_DATALIB)
         EasyHelp(STR0374 + ENTER + STR0375,STR0079)
         RestOrd(aOrdSE2,.T.)
         Return .F.
      EndIf
   EndIf
   RestOrd(aOrdSE2,.T.)
EndIf

If AvFlags("EIC_EAI") .AND. TRB->WB_PO_DI == "D" .AND. Left(TRB->WB_TIPOREG,1) == "P" .AND. nTipo == 7 //Estorno Liquidacao de Adiantamento
   nTipo := 5

   cChave      := TRB->WB_CHAVE
   nRecno      := TRB->(RECNO())

   //Guarda os dados da parcela compensada.
   TRB->(DBGOTOP())
   While TRB->(!EOF())
      If TRB->(WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN+WB_LOJA+WB_LINHA) == Alltrim(cChave)

		 DbSelectArea("TRB")
         aAdd(aTRB_Old,{TRB->(RecNo()),{}})
         FOR i := 1 TO FCount()
            AADD(aTRB_Old[Len(aTRB_Old)][2],{(FIELDNAME(i)) , FieldGet(i)  })
         NEXT i

		 Exit
      EndIf

      TRB->(DBSKIP())
   EndDo

   TRB->(DBGOTO(nRecno))
EndIf

nPGTANT := 0
SW6->(DBSETORDER(1))
IF lCposAntecip
   aSWB:={"WB_INVOICE", "WB_TIPOREG", "WB_BANCO"  , "WB_DES_BCO", "WB_AGENCIA",;
          "WB_NUM"	  , "WB_DT"     , "WB_LC_NUM" , "WB_NR_ROF" , "WB_DT_ROF" ,;
          "WB_DT_CONT", "WB_DT_VEN" , "WB_CA_NUM" , "WB_LIM_BAC", "WB_ENV_BAC",;
          "WB_VM_OBS" , "WB_RETIDO" , "WB_CORRETO", "WB_VL_CORR", "WB_DESPESA",;
          "WB_VM_TREG", "WB_VM_CORR", "WB_DT_DESE", "WB_BCO_REC", "WB_AGENREC",;
          "WB_CON_REC", "WB_NAT_CON", "WB_DES_BCO", "WB_DESBCOR", "WB_SWIFT"  ,;
          "WB_PGTANT" , "WB_FORN"   , "WB_LOJA"   , "WB_MOEDA"  }//, "WB_CHVASS"  }

   IF LEFT(M->WA_PO_DI,1) == "D"
      IF nPos_aRotina == INCLUSAO .OR. nPos_aRotina == ALTERACAO
         aButtons:={}
         aAdd(aButtons,{"POSCLI" ,{|| AP100POsAdto(.F., .T.) },STR0232})  // "Pagamentos Antecipados"
      ENDIF
      IF nTipo = 3//Inclusao
         AADD(aSWB,"WB_CA_DT"  )
         AADD(aSWB,"WB_MOEDA"  ) //AAF - 18/11/05 - Adicionado campo Moeda.
         AADD(aSWB,"WB_FOBMOE" )
         AADD(aSWB,"WB_CA_TX"  )
         AADD(aSWB,"WB_FOBREAL")
         AADD(aSWB,"WB_NUMPO"  )
      ELSEIF Left(TRB->WB_TIPOREG,1) = 'P' //Parcela Antecipada
         AADD(aSWB,"WB_NUMPO"  )
      ELSEIF Left(TRB->WB_TIPOREG,1) # 'P' //Outras Parcelas
         AADD(aSWB,"WB_CA_DT"  )
         AADD(aSWB,"WB_MOEDA"  ) //AAF - 18/11/05 - Adicionado campo Moeda.
         AADD(aSWB,"WB_FOBMOE" )
         AADD(aSWB,"WB_CA_TX"  )
         AADD(aSWB,"WB_FOBREAL")
      ENDIF
   ELSE
      AADD(aSWB, "WB_CA_DT"  )
      AADD(aSWB, "WB_CA_TX"  )
      AADD(aSWB, "WB_FOBREAL")

      If SWB->(FieldPos("WB_PGTASS")) > 0 .AND. M->WA_PO_DI == "C" //AAF 17/02/2014 - Permite transferência de adiantamento para outro processo utilizando o tipo crédito
         AADD(aSWB, "WB_CHVASS")
      EndIf
   ENDIF
ELSE
   aSWB:={ "WB_INVOICE", "WB_TIPOREG", "WB_BANCO"  , "WB_DES_BCO", "WB_AGENCIA",;
           "WB_NUM"    , "WB_DT"     , "WB_LC_NUM" , "WB_NR_ROF" , "WB_DT_ROF" ,;
           "WB_DT_CONT", "WB_DT_VEN" , "WB_CA_NUM" , "WB_CA_TX"  , "WB_MOEDA"  ,; //AAF - 18/11/05 - Adicionado campo Moeda.
           "WB_FOBMOE" , "WB_FOBREAL", "WB_CA_DT"  , "WB_LIM_BAC", "WB_ENV_BAC",;
           "WB_VM_OBS" , "WB_RETIDO" , "WB_CORRETO", "WB_VL_CORR", "WB_DESPESA",;
           "WB_VM_TREG", "WB_VM_CORR", "WB_DT_DESE", "WB_BCO_REC", "WB_AGENREC",;
           "WB_CON_REC", "WB_NAT_CON", "WB_DES_BCO", "WB_DESBCOR", "WB_SWIFT"   }

Endif
//** igor chiba  29/09/09 colocando os campos novos criados de titulo de erp e titulo erp vinculado
IF LCAMBIO_EIC
   AADD(aSWB,"WB_TITERP" )
   AADD(aSWB,"WB_TITERPV")
   AADD(aSWB,"WB_TITRET" )  // PLB 15/04/10 - Status de Retorno do ERP
ENDIF
//**

//** GFC - 18/11/05 - Câmbio de frete, seguro, comissão e embarque
If lWB_TP_CON
   AADD(aSWB,"WB_COMAG"  )
   AADD(aSWB,"WB_TP_CON" )
   AADD(aSWB,"WB_TIPOCOM")
EndIf
//**
//** GFC - 08/03/06 - Gravar Evento (Finimp)
If lWB_EVENT
   AADD(aSWB,"WB_EVENT")
   AADD(aSWB,"WB_TIPOC")
EndIf
//**

IF TRB->(FIELDPOS("WB_CONTA")) # 0
	AADD(aSWB,"WB_CONTA")
Endif

If SWB->(FieldPos("WB_DESCO")) > 0 .And. SWB->(FieldPos("WB_VLIQ")) > 0 //MCF - 19/01/2017
   AADD(aSWB,'WB_DESCO')
   AADD(aSWB,'WB_VLIQ' )
EndIf

DbSelectArea("SWA")//JL
FOR i := 1 TO FCount()
    //M->&(FIELDNAME(i)) := FieldGet(i) igor chiba 13/08/14 nao pode zerar variavel de memoria
    AADD(aSWA_OLD,{(FIELDNAME(i)) , FieldGet(i)  })
NEXT

DbSelectArea("TRB")//JL
aAdd(aTRB_Old,{TRB->(RecNo()),{}})
FOR i := 1 TO FCount()
    //M->&(FIELDNAME(i)) := FieldGet(i)igor chiba 13/08/14 nao pode zerar variavel de memoria
    AADD(aTRB_Old[Len(aTRB_Old)][2],{(FIELDNAME(i)) , FieldGet(i)  })
NEXT

aGet_SWB:=ACLONE(aSWB)

//IF EasyGParam("MV_EASYFIN",,"N") = "S" .AND. EasyGParam("MV_EASY",,"N") = "S"

If M->WA_PO_DI == "C" .AND. (nTipo == 4 .OR. nTipo == 5)  // GFP - 05/05/2014
   If SWB->(FieldPos("WB_PGTASS")) > 0 .AND. !Empty(TRB->WB_CA_DT) .AND. Empty(TRB->WB_PGTASS) .And. TRB->WB_TIPOTIT <> "NCF"  // Para processos liquidados sem associação de crédito, ou seja, originados de registros de Adto.
      MsgInfo(STR0343 + ENTER + STR0344,STR0079) // "Operação não permitida para câmbio do tipo Crédito." ### "Favor efetuar tal operação no processo original." ### "Aviso"
      Return .F.
   EndIf
EndIf

IF nTipo = 6// AWR - 06/07/2004
   //Jacomo Lisa - 06/08/2014 -- Incluida a Validação para quando for integrado com o Logix, o Evento for 609 (Antecipado) e o centro de Custo do Evento contabil não estiver preenchido
   //Não permitir a liquidação/Estorno da parcela
   IF AvFlags("EIC_EAI") .AND. TRB->WB_EVENT $ "608/609"
      EC6->(DbSETORDER(1))
      IF EC6->(DbSeek(xFilial("EC6")+"IMPORT"+TRB->WB_EVENT)) .AND. EMPTY(EC6->EC6_CCUSTO)
         EASYHELP(StrTran(STR0358, "####", AllTrim(TRB->WB_EVENT)), STR0063) //"Evento contábil #### não possui centro de custo configurado para integração. Verifique a configuração deste evento no cadastro de 'Eventos Contábeis'.", "Atenção
         RETURN .F.
      ENDIF
   ENDIF
   IF AvFlags("EIC_EAI") .AND. TRB->WB_PO_DI == "D" .AND. (!AvFlags("EAI_PGANT_INV_NF") .OR. (SW6->(DBSEEK(xFilial("SW6")+TRB->WB_HAWB)) .AND. !EMPTY(SW6->W6_DT_NF) ) ) .AND. TRB->WB_EVENT <> "101" .AND. EMPTY(TRB->WB_NUMDUP)
      EASYHELP(STR0359, STR0063) //"Invoice está com integração pendente ao ERP. Processe a integração para que seja possível liquidar o câmbio","Atenção!!")
      RETURN .F.
   ENDIF

   If LCambio_EIC    // GFP - 10/05/2013
      If aScan(aAltParc, {|x| x[1] == TRB->WB_INVOICE .AND. x[2] == TRB->WB_LINHA}) > 0
         MsgInfo(STR0360, STR0079) //"Existem integrações pendentes com o ERP. Efetue a gravação do registro antes de prosseguir.", "Aviso"
         Return .F.
      EndIf
   EndIf

   //SVG - 22/10/2009 -
   IF(EasyEntryPoint("EICAP100"),Execblock("EICAP100",.F.,.F.,"LIQUIDA"),)
   If !lBaixa
      Return .F.
   EndIf

   //ASK 21/06/07 - Caso exista Câmbio de adiantamento com saldo e que possa ser utilizado no processo, o sistema avisará.
   If lCposAntecip
      SW7->(DbSeek(xFilial("SW7") + M->WA_HAWB))
      Do While SW7->(!eof()) .And. SW7->W7_HAWB == M->WA_HAWB
         If (nPosPo:= aScan(aPo,{|X| X[1]== SW7->W7_PO_NUM})) = 0
            Aadd( aPo, {SW7->W7_PO_NUM} )
         EndIf
         SW7->(DbSkip())
      EndDo
      For i := 1 to len(aPO)
         If SW2->(DbSeek(xFilial("SW2") + aPo[i][1]))
            Aadd(aPo[i], SW2->W2_MOEDA)
         Else
            Aadd(aPo[i], "")
         EndIf
      Next

      For i := 1 to len(aPo)
         SWA->(DbSeek(xFilial("SWA") + aPO[i][1]))
         If Alltrim(aPo[i][1]) == Alltrim(SWA->WA_HAWB) .And. aPo[i][2] == TRB->WB_MOEDA .AND. SWA->WA_PO_DI == "A" .AND. SWA->WA_SLDANT > 0
            cCtrl+= "N° " + Transform(SWA->WA_CTRL,AvSx3("WA_CTRL",6)) + Chr(13) + Chr(10)
         EndIf
      Next

      If !Empty(cCtrl)
         MsgInfo( STR0149 + Chr(13) + Chr(10) + cCtrl, STR0079 )//"Este processo possui Controle de Câmbio de Adiantamento:"
      EndIf
   EndIf
   //JAP - 25/08/06 - Não permite liquidar a parcela se o titulo já estiver compensado no financeiro.
   IF !lCompAut .AND. !ValidaSE2("Liquidação")
      Return .F.
   EndIf
   IF !EMPTY(TRB->WB_CA_TX) .AND. !EMPTY(TRB->WB_CA_DT)
      MSGINFO(STR0134)  //"Parcela já esta Liquidada."
      Return .F.
   EndIf

   //RMD - 12/12/12
   If lCAMBIO_EIC .AND. lEICFI06 .And. Empty(SW9->W9_TITERP)
      MsgInfo("Parcela sem retorno do número do título no ERP. Não será possível liquidar.", "Aviso")
      Return .F.
   EndIf

   //** AAF 06/05/2006 - Não permitir liquidar se houver FFC.
   IF !EMPTY(TRB->WB_LOTE)
      MSGINFO(STR0135)  //"Utilize a Manutenção de FFC para liquidação desta parcela."
      Return .F.
   EndIf
   //**

   aSWB:={"WB_BANCO" , "WB_DES_BCO", "WB_AGENCIA", "WB_DT_CONT", "WB_CA_NUM" , "WB_CA_TX" ,;
          "WB_FOBMOE", "WB_FOBREAL", "WB_CA_DT"  , "WB_DT_DESE", "WB_CORRETO", "WB_VL_CORR"}
   If lCposAntecip
      aSWB:={"WB_BANCO"  , "WB_DES_BCO", "WB_AGENCIA", "WB_DT_CONT", "WB_CA_NUM",;
             "WB_CA_TX"  , "WB_PGTANT" , "WB_FOBMOE" , "WB_FOBREAL", "WB_CA_DT" ,;
             "WB_DT_DESE", "WB_CORRETO","WB_VL_CORR"                             }
   Endif

   IF TRB->(FIELDPOS("WB_CONTA")) # 0
    	AADD(aSWB,"WB_CONTA")
   ENDIF

   If SWB->(FieldPos("WB_DESCO")) > 0 .And. SWB->(FieldPos("WB_VLIQ")) > 0 //MCF - 19/01/2017
      AADD(aSWB,'WB_DESCO')
      AADD(aSWB,'WB_VLIQ' )
   EndIf

   If SWB->(FieldPos("WB_MOTBX")) > 0 .And. M->WA_PO_DI == "D" .And.  GetNewPar("MV_EASYFIN","N") = "S"
      AADD(aSWB,'WB_MOTBX')
   EndIf
   
   aGet_SWB:=ACLONE(aSWB)

      IF (nPosCA:=ASCAN(aGet_SWB,"WB_FOBMOE")) # 0
         ADEL(aGet_SWB,nPosCA)
         ASIZE(aGet_SWB,LEN(aGet_SWB)-1)
      ENDIF
      IF (nPosCA:=ASCAN(aGet_SWB,"WB_PGTANT")) # 0
         ADEL(aGet_SWB,nPosCA)
         ASIZE(aGet_SWB,LEN(aGet_SWB)-1)
      ENDIF

ELSEIF nTipo = 7

	  // EOB - 03/2009 - alteração no tratamento do estorno, setando variaveis quando ha compensação e/ou liquidação no financeiro
	  lParcComp := .F.
	  lParcLiq  := .F.
      IF lCompAut .AND. LEFT(M->WA_PO_DI,1) == "D" .AND. Left(TRB->WB_TIPOREG,1) <> "P" .AND. TRB->WB_PGTANT > 0 .AND. !ValidaSE2("Ver_Comp")
         lParcComp := .T.
      ENDIF
     //Jacomo Lisa - 06/08/2014 -- Incluida a Validação para quando for integrado com o Logix, o Evento for 609 (Antecipado) e o centro de Custo do Evento contabil não estiver preenchido
     //Não permitir a liquidação/Estorno da parcela
      IF AvFlags("EIC_EAI") .AND. TRB->WB_EVENT == "609"
         EC6->(DbSETORDER(1))
         IF EC6->(DbSeek(xFilial("EC6")+"IMPORT"+TRB->WB_EVENT)) .AND. EMPTY(EC6->EC6_CCUSTO)
            EASYHELP(StrTran(STR0358, "####", AllTrim(TRB->WB_EVENT)), STR0063) //"Evento contábil #### não possui centro de custo configurado para integração. Verifique a configuração deste evento no cadastro de 'Eventos Contábeis'.", "Atenção"
            RETURN .F.
         ENDIF
      ENDIF

      If LCambio_EIC     // GFP - 10/05/2013 - Inclusão do registro a ser estornado para futura verificação quando AvInteg
         aAdd(aAltParc, {TRB->WB_INVOICE, TRB->WB_LINHA})
      EndIf

      //TDF - 12/12/12 - Não permite o estorno da liquidação de um pagamento antecipado, caso a data da emissão do título PA seja maior que a data base.
      If lFinanceiro .AND. Left(TRB->WB_TIPOREG,1) == "P"
      SE2->(DbSetOrder(6))
         If SE2->(dbSeek(xFilial("SE2")+TRB->(WB_FORN+WB_LOJA+WB_PREFIXO+WB_NUMDUP+WB_PARCELA+MVPAGANT)))
            If SE2->E2_EMISSAO > dDataBase
               SE5->(DbSetOrder(7))
	           If SE5->(dbSeek(xFilial("SE5")+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)))
		          Help( " ", 1, "NODELPA" )
		          Return .F.
	           EndIf
            EndIf
         EndIf
      EndIf

     //TDF - 12/12/2014 - Tratamento para não permitir alteração no câmbio quando o parâmetro MV_BXCONC = 2 e a parcela já foi conciliada no financeiro.
     If lFinanceiro
     SE2->(DbSetOrder(6))
         If SE2->(dbSeek(xFilial("SE2")+TRB->(WB_FORN+WB_LOJA+WB_PREFIXO+WB_NUMDUP+WB_PARCELA+MVPAGANT)))
            SE5->(DbSetOrder(2))
            If SE5->(dbSeek(xFilial("SE5")+If(TRB->WB_TIPOTIT == "NCF", M->WB_TIPOTIT, "PA" )+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+Dtos(SE2->E2_EMISSAO)+SE2->E2_FORNECE+SE2->E2_LOJA)) .OR. SE5->(dbSeek(xFilial("SE5")+"BA"+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+Dtos(SE2->E2_EMISSAO)+SE2->E2_FORNECE+SE2->E2_LOJA))
               If !lBxConc .And. !Empty(SE5->E5_RECONC)
                  MsgInfo(STR0253, STR0063) // "Pagamento Antecipado não pode ser alterado pois foi conciliado/reconciliado no financeiro - Verifique o parâmetro MV_BXCONC" // "Aviso"
               Return .F.
               Endif
            EndIf
         EndIf
     EndIf

      IF !EMPTY(TRB->WB_CA_TX) .AND. !EMPTY(TRB->WB_CA_DT)
         lParcLiq := .T.
      ELSE
         If lParcComp
            MSGINFO("Parcela nao esta Liquidada. Para estornar a Associação do Adiantamento, selecionar a parcela de Pagamento Antecipado e utilize a opção 'Estornar Associação'.")  //"Parcela nao esta Liquidada. Para estornar a Associação do Adiantamento, utilizar a opção 'Estornar Associação'."
            Return .F.
         Else
            MSGINFO(STR0136)  //"Parcela nao esta Liquidada."
            Return .F.
         EndIf
      ENDIF

      //** SVG 05/10/2009 - Não permitir liquidar se houver vinculado a algum processo.
      If Left(TRB->WB_PO_DI,1) == "D" .AND. Left(TRB->WB_TIPOREG,1) == "P"
         MSGINFO( STR0249, STR0079) // STR0249 "Não é possível estornar uma parcela de adiantamento. //STR0079 "Aviso"
         Return .F.
      EndIf
      If (Left(TRB->WB_PO_DI,1) == "A" .Or. Left(TRB->WB_PO_DI,1) == "F" .Or. Left(TRB->WB_PO_DI,1) == "C")	// GCC - 23/08/2013
         If isCompensado(TRB->WB_HAWB,TRB->WB_LINHA,TRB->WB_FORN,TRB->WB_LOJA,xFilial("SWB"))
            MSGINFO(STR0238)
            Return .F.
         EndIf
      EndIf
      //**

      //** AAF 06/05/2006 - Não permitir liquidar se houver FFC.
      IF !EMPTY(TRB->WB_LOTE)
         MSGINFO(STR0124)  //"Utilize a Manutenção de FFC para estornar a liquidação desta parcela."
         Return .F.
      //**

      // EOB - 03/2009 - faz a pergunta de confirmação de estorno conforme as variáveis que indica se a parcela esta compensada e/ou liquidada
      ELSEIF lAdVinculado .And. lParcComp .AND. AvFlags("EIC_EAI") //LRS - 24/07/2018 - so valida se for logix
         MsgInfo(STR0250) //STR0080 "Parcela possui compensação, será necessário excluir o adiantamento vinculado para estornar a compensação."
         Return .F.
      ELSEIF lParcLiq .And. MSGYESNO( STR0137)

      If SWB->(FieldPos("WB_SLDTRF")) > 0  //LGS-09/10/2014 //MCF - 15/09/2014 - Validação pra verificar crédito transferido.
		 If !Empty(TRB->WB_SLDTRF)
      	    MsgStop(STR0347) // "Cambio não pode ser estornado, pois há saldo transferido." ### "Aviso"
      	    Return .F.
		 EndIf
      EndIf

         //** PLB 12/05/10 - Inicio - Inclusao de Ponto de Entrada para Validar se efetua Estorno de Liquidação
         lVolta := .F.
         IF(EasyEntryPoint("EICAP100"),Execblock("EICAP100",.F.,.F.,"ANTES_ESTORNO_BAIXA"),)
         IF lVolta
            dbSelectArea(cAlias)
            return .F.
         ENDIF
         //** PLB 12/05/10 - Fim - Inclusao de Ponto de Entrada para Validar se efetua Estorno de Liquidação

         //** PLB 25/07/06 - Tratamento Multi-Usuario Financiamento
         If lEIC_EFF .And. lEFFTpMod .AND. lParcLiq
            EF3->( DBSetOrder(7) )
            If EF3->( DBSeek(xFilial("EF3")+Left(TIPO_MODULO,1)+TRB->WB_HAWB+TRB->WB_FORN+TRB->WB_LOJA+TRB->WB_INVOICE+TRB->WB_LINHA+EV_EMBARQUE) )
               EF1->( DBSetOrder(1) )
               EF1->( DBSeek(xFilial("EF1")+EF3->EF3_TPMODU+EF3->EF3_CONTRA+EF3->EF3_BAN_FI+EF3->EF3_PRACA+EF3->EF3_SEQCNT) )
               If !SoftLock("EF1")
                  Return .F.
               EndIf
            EndIf
         EndIf
         //**
         
         //LRS - 06/11/2018 - techo nopado esta fazendo errado a volta da compensacao
         /*// EOB - 03/2009 - Volta o valor compensado a parcela
         IF lParcComp
            TRB->WB_FOBMOE += TRB->WB_PGTANT
            TRB->WB_PGTANT := 0
            TRB->TRB_ALT := .T.
         ENDIF*/

         // EOB - 03/2009 - Limpa os dados da liquidação da parcela
         IF lParcLiq
            TRB->WB_CA_TX:=0
            TRB->WB_CA_DT:=CTOD("")
            If SWB->(FieldPos("WB_PGTASS")) > 0  // GFP - 17/04/2014
               TRB->WB_PGTASS := ""
            EndIf
            If lCposAntecip .AND. (LEFT(M->WA_PO_DI,1) == "A" .Or. LEFT(M->WA_PO_DI,1) == "F" .Or. LEFT(M->WA_PO_DI,1) == "C")	// GCC - 23/08/2013
               M->WA_SLDANT-=TRB->WB_PGTANT
            ENDIF
         ENDIF

         //** GFC - 03/04/06 - Financiamento da Importação
         If lEFFTpMod .and. lEIC_EFF .AND. lParcLiq
            If (nPos := aScan(aVincula,{|x| x[9]==TRB->WB_INVOICE .and. x[10]==If(Empty(TRB->WB_PARFIN), TRB->WB_LINHA, TRB->WB_PARFIN)})) > 0 .and.;  // Verifica se a parcela esta vinculada
               !Empty(aVincula[nPos,3])
               If (nPos2 := aScan(aLiquida, {|x| x[1]==TRB->WB_LINHA})) > 0 .and. aLiquida[nPos2,3] = TRB->WB_CA_TX
                  aDel(aLiquida,nPos2)
                  aSize(aLiquida,LEN(aLiquida)-1)
               Else
                  aAdd(aLiquida,{TRB->WB_LINHA,"ESTORNAR", ,aVincula[nPos,1], TRB->(RecNo()) })
               EndIf
            EndIf
         EndIf

         IF AvFlags("EIC_EAI") .AND. STR(nTipo,1) == "7" //Jacomo Lisa - Inclui a integração quando for Logix
            SWA->(DBGOTO(nRecSWA))
            If !INTAP110(5, nTipo)//igor chiba tratamento foi todo feito dentro dessa funcao //wfs jun/2017 - segundo parâmetro para diferenciar estorno da liquidação da exclusão da parcela
               Return .F.
            EndIf
         ENDIF

         IF(EasyEntryPoint("EICAP100"),Execblock("EICAP100",.F.,.F.,"ESTORNO_BAIXA"),)
      ENDIF

//      IF STR(nTipo,1) $ "7" .AND. LEFT(M->WA_PO_DI,1) == "A" //JAP - Foi incluso no estorno da baixa de adiantamentos pois é necessário excluir o PA e incluir o PR.
      IF STR(nTipo,1) $ "7" .AND. (LEFT(M->WA_PO_DI,1) == "A" .Or. LEFT(M->WA_PO_DI,1) == "F" .Or. LEFT(M->WA_PO_DI,1) == "C")	// GCC - 23/08/2013
          TRB->TRB_ALT := .T. // AWR - CONTROLE /P O FINANCEIRO - 31/05/2004
      ENDIF

      /* wfs - movido para dentro da confirmação do usuário, quanto ao estorno (trecho acima)
      IF AvFlags("EIC_EAI") .AND. STR(nTipo,1) == "7" //Jacomo Lisa - Inclui a integração quando for Logix
         SWA->(DBGOTO(nRecSWA))
         INTAP110(5)//igor chiba tratamento foi todo feito denttro dessa funcao
      ENDIF*/


      Return .T.
ELSE

   If LCambio_EIC    // GFP - 10/05/2013
      If aScan(aAltParc, {|x| x[1] == TRB->WB_INVOICE .AND. x[2] == TRB->WB_LINHA}) > 0
         MsgInfo(STR0360, STR0079) //"Existem integrações pendentes com o ERP. Efetue a gravação do registro antes de prosseguir.", "Aviso"
         Return .F.
      EndIf
   EndIf

   If (nTipo = 4 .AND. !Empty(TRB->WB_CA_TX) .AND. !Empty(TRB->WB_CA_DT) .AND. !(Left(M->WA_PO_DI,1) == "D" .AND. Left(TRB->WB_TIPOREG,1) = "P" ) )//ER - 27/10/2007 - Se a parcela estiver liquidada, só poderá alterar o campo Contrato.

       aGet_SWB := {"WB_CA_NUM"}

   ELSEIF STR(nTipo,1) $ "4,5"

      //If nTipo = 5 .AND. !Empty(TRB->WB_CA_TX) .AND. !Empty(TRB->WB_CA_DT) .And. TRB->WB_TIPOREG == "1"// SVG - 17/06/2011 - Valdação da exclusão.
      If nTipo = 5 .AND. !Empty(TRB->WB_CA_TX) .AND. !Empty(TRB->WB_CA_DT) .And. Left(TRB->WB_TIPOREG,1) == "1" .AND. !lLiqLogix //LGS-19/11/2014 //JACOMO LISA - 27/06/2014 - Não permitir a exclusão para parcelas do tipo Invoice e Pagamento Antecipado
         HELP("",1,"AVG0000393") //"Cambio não pode ser excluida, pois há Título Baixado"###"Informação"
         Return .F.
      EndIf

      If SWB->(FieldPos("WB_SLDTRF")) > 0 .AND. nTipo = 5 .AND. !Empty(TRB->WB_SLDTRF)  // GFP - 29/08/2014 - Não deve permitir exclusão de parcelas que possuem saldos transferidos.
         MsgStop(STR0346,STR0079)  // "Cambio não pode ser excluído, pois há saldo transferido." ### "Aviso"
         Return .F.
      EndIf

      IF AvFlags("EIC_EAI") .and. nTipo = 5 .AND. !lLiqLogix
         IF (!EMPTY(TRB->WB_CHAVE))
            MSGALERT(STR0361, STR0079)//"Compensação de adiantamento liquidada. É necessário realizar o estorno da liquidação", "Aviso"
            RETURN .F.
         ENDIF
         IF (!EMPTY(TRB->WB_CA_DT))
            MSGALERT(STR0362, STR0079) //"Parcela liquidada. É necessário estornar a liquidação primeiro.", "Aviso"
            RETURN .F.
         ENDIF
      ENDIF
       // EOB - 03/2009 - Se não houver compensação automática, mas tiver compensação no Financeiro, libera apenas o contrato para alterar.
       IF !lCompAut
          IF nTipo = 4
             IF !ValidaSE2("Alteracao")
   	            aGet_SWB := {"WB_CA_NUM"}
  	         ENDIF
  	      ELSE
             IF !ValidaSE2("Exclusão")
   	            RETURN .F.
  	         ENDIF
  	      ENDIF

	   // EOB - 03/2009 - Verifica se a parcela foi compensada no Financeiro e não permite a alteração ou exclusao
	   ELSEIF LEFT(M->WA_PO_DI,1) == "D"
         IF Left(TRB->WB_TIPOREG,1) <> "P" .AND. TRB->WB_PGTANT > 0 .AND. lFinanceiro//!ValidaSE2("Ver_Comp")
             If nTipo = 4
                aGet_SWB := {"WB_CA_NUM"}   //TDF - 21/11/11 - Pode ser alterado o número de contrato
             Else
               MSGINFO(STR0190+ STR0074+" "+STR0191)
               RETURN .F.
             EndIF

         // EOB - 03/2009 - Verifica se a parcela de adiantamento está sendo utilizada em outra parcela e não permite a alteração ou exclusao
         ELSEIF Left(TRB->WB_TIPOREG,1) == "P"
            nRecTRB := TRB->(recno())
            cForn   := TRB->WB_FORN
            //IF EICLOJA()
               TLoja := TRB->WB_LOJA
            //ENDIF
            cMoeda  := TRB->WB_MOEDA
            aValorAd101 := {}
            TRB->(dbGotop())
            lAdiant := .F.
            DO WHILE !TRB->(eof())
               IF Left(TRB->WB_TIPOREG,1) <> "P" .AND. TRB->WB_FORN == cForn .AND. (!EICLOJA() .OR. TRB->WB_LOJA == TLoja ) .AND. TRB->WB_MOEDA == cMoeda .AND. !Empty(TRB->WB_CA_DT) .AND. TRB->WB_PGTANT > 0
                  aAdd(aValorAd101, TRB->WB_PGTANT)
                  //lAdiant := .T.
                  //EXIT
               ENDIF
               TRB->(dbSkip())
            ENDDO
            TRB->(dbgoto(nRecTRB))
            For nInc := 1 To Len(aValorAd101)
               If aScan(aValorAd101, TRB->WB_PGTANT) > 0
                  lAdiant := .T.
                  Exit
               EndIf
            Next
            IF lAdiant //.And. !lAdVinculado//JVR - 31/03/10 - lAdVinculadosss
               MSGINFO(STR0190+IF(ntipo=4,STR0075,STR0074)+STR0236)
               RETURN .F.
            ENDIF
         ENDIF

	   ElseIf (Left(M->WA_PO_DI,1) == "A" .Or. Left(M->WA_PO_DI,1) == "F" .Or. Left(M->WA_PO_DI,1) == "C")	// GCC - 23/08/2013
          If !ValidaSE2("Ver_Comp")
             MsgInfo(STR0190+If(nTipo = 4, STR0251, STR0252)+STR0191) //STR0251 "alteração "  //STR0252 "exclusão "
             Return .F.
	      EndIf

	   ENDIF
   EndIf

   IF (nPosCA:=ASCAN(aGet_SWB,"WB_DT_DESE")) # 0     //NCF - 25/08/09 - Desabilita a entrada de dados no campo
      ADEL (aGet_SWB, nPosCA         )               //quando se tratar de inclusão/alteração de parcela de câmbio
      ASIZE(aGet_SWB, LEN(aGet_SWB)-1)
   ENDIF
   IF (nPosCA:=ASCAN(aGet_SWB,"WB_CA_DT"  )) # 0
      ADEL (aGet_SWB, nPosCA         )
      ASIZE(aGet_SWB, LEN(aGet_SWB)-1)
   ENDIF
   IF (nPosCA:=ASCAN(aGet_SWB,"WB_CA_TX"  )) # 0
      ADEL (aGet_SWB, nPosCA         )
      ASIZE(aGet_SWB, LEN(aGet_SWB)-1)
   ENDIF
   IF (nPosCA:=ASCAN(aGet_SWB,"WB_FORN"  )) # 0 .AND. Left(M->WA_PO_DI,1) == "F" 		//MCF - 17/12/2014 - Desabilita a entrada de dados quando
   	  ADEL (aGet_SWB, nPosCA         )													//tipo for igual F=Adiant.Fornec.
      ASIZE(aGet_SWB, LEN(aGet_SWB)-1)
   ENDIF
   IF (nPosCA:=ASCAN(aGet_SWB,"WB_LOJA"  )) # 0 .AND. Left(M->WA_PO_DI,1) == "F"
      ADEL (aGet_SWB, nPosCA         )
      ASIZE(aGet_SWB, LEN(aGet_SWB)-1)
   ENDIF
   IF (nPosCA:=ASCAN(aGet_SWB,"WB_INVOICE"  )) # 0 .AND. Left(M->WA_PO_DI,1) == "F"
      ADEL (aGet_SWB, nPosCA         )
      ASIZE(aGet_SWB, LEN(aGet_SWB)-1)
   ENDIF

ENDIF

//EndIf

PRIVATE aTela[0][0],aGets[0]//,nUsado:=0

Private cParcela

//RMD - Nova legislação de câmbio
//EOB - 31/07/09 - Troca de EECFlags p/ AvFlags (Avgeral)
If AvFlags("CAMBIO_EXT")
   aAdd(aSWB, "WB_TIPOPAG")
   aAdd(aGet_SWB, "WB_TIPOPAG")
EndIf

IF EasyEntryPoint("EICAP100") //OS 0639/01 FCD
   ExecBlock("EICAP100",.F.,.F.,"ARRAYSWB")
ENDIF

IF STR(nTipo,1) $ "4,5"
   IF lCposAntecip
      IF nTipo = 4 .AND. !EMPTY(TRB->WB_NUMPO) .AND. !Work1->(DBSeek(TRB->WB_NUMPO))
         aGet_SWB := {"WB_CA_NUM"}  //TDF - 21/11/11 - Pode ser alterado o número de contrato
         /*MSGInfo(STR0139)  //"Parcela nao pode ser alterada."
         return .T.*/
      ENDIF

      SWB->(DBSETORDER(5))
      IF (LEFT(M->WA_PO_DI,1) == 'A' .Or. LEFT(M->WA_PO_DI,1) == 'F' .Or. LEFT(M->WA_PO_DI,1) == 'C') .And. !EMPTY(TRB->WB_CA_DT) .And.;	// GCC - 23/08/2013
         SWB->(DBSEEK(xFilial()+M->WA_HAWB))
         SWB->(DBSETORDER(1))
         aGet_SWB := {"WB_CA_NUM"}  //TDF - 21/11/11 - Pode ser alterado o número de contrato
         /*MSGInfo(STR0139)  //"Parcela nao pode ser alterada."
         return .T.*/
      ENDIF


   ENDIF
   SWB->(DBSETORDER(1))

   IF TRB->(EOF()) .AND. TRB->(BOF())
      Help("", 1, "AVG0000191")
      lRefresh:=.t.
      dbSelectArea(cAlias)
      return .F.
   ENDIF
     //SVG - 05/11/2010 -
   lVinc := .F.
   IF lCposAntecip
      aOrd := SaveOrd({"SWB"})
      SWB->(DBSETORDER(5))
      If (TRB->WB_PO_DI == 'A' .Or. TRB->WB_PO_DI == 'F' .Or. TRB->WB_PO_DI == 'C') .And. SWB->(DbSeek(xFilial()+TRB->WB_HAWB))	// GCC - 23/08/2013
         RestOrd(aOrd,.T.)
         lVinc:= .T.
      EndIf
      RestOrd(aOrd,.T.)
   ENDIF

   If !Empty(TRB->WB_LOTE) .And.  lVinc //EMPTY(TRB->WB_NUMPO) .AND. Work1->(DBSeek(TRB->WB_NUMPO))      //MJB-SAP-1100
      Help("", 1, "AVG0000176")
      lRefresh:=.t.                                                       //MJB-SAP-1100
      dbSelectArea(cAlias)                                                //MJB-SAP-1100
      return .F.                                                          //MJB-SAP-1100
   Endif                                                                  //MJB-SAP-1100
   If !Empty(TRB->WB_CONTAB)
      MsgStop(STR0113,STR0079) //"Cambio Contabilizado nao pode ser alterado ou excluido")
      lRefresh:=.t.
      dbSelectArea(cAlias)
      return .F.
   Endif

ENDIF

//JAP - 28/09/06 - Impede a liquidação de parcelas com saldo igual a zero.
IF GetNewPar("MV_EASYFIN","N") == "S" .AND. STR(nTipo,1) == "6"
   IF LEFT(M->WA_PO_DI,1) == "D" .AND. Left(TRB->WB_TIPOREG,1) <> "P" .AND. TRB->WB_FOBMOE == 0
      MsgStop(STR0140,STR0079)  //"Parcelas com saldo zerado não podem ser liquidadas."
      Return .F.
   ENDIF
ENDIF
dbSelectArea("TRB")

nReg1 :=RECNO()
If lCposAntecip .AND. LEFT(M->WA_PO_DI,1) == "A"
   SW2->(DBSEEK(xFilial()+Left(M->WA_HAWB,AvSX3("W2_PO_NUM",AV_TAMANHO))))
ElseIf LEFT(M->WA_PO_DI,1) == "D"
   SW7->(DBSEEK(xFilial()+M->WA_HAWB))
   SW2->(DBSEEK(xFilial()+SW7->W7_PO_NUM))

   IF SY6->Y6_DIAS_PA >= 900
      FOR Wind = 1 TO 10
          _Dias:= "Y6_DIAS_" + STRZERO(Wind,2) ; _Dias:= SY6->(FIELDGET( FIELDPOS(_Dias) ))
          _Perc:= "Y6_PERC_" + STRZERO(Wind,2) ; _Perc:= SY6->(FIELDGET( FIELDPOS(_Perc) ))/ 100
          IF _Perc = 0
             LOOP
          ENDIF
      NEXT
   ENDIF
   TRB->(DBGOTOP())
   TRB->(DBEVAL({ || TRB->WB_HAWB = M->WA_HAWB}))

   TRB->(DBGOTO(nReg1))
ENDIF

// GCC - 26/09/2013 - Carregar os campos fornecedor, loja e moeda de acordo com a primeira parcela
If TRB->(Easyreccount("TRB")) # 0
   cFornPar	 := TRB->WB_FORN
   cLojaPar	 := TRB->WB_LOJA
   cMoedaPar := TRB->WB_MOEDA
EndIf

IF nTipo == 3
   TRB->(DBGOBOTTOM())
   TRB->(DBSKIP())
ENDIF
DBSELECTAREA("SWB")

IF TRB->(FIELDPOS("WB_DES_BCO")) # 0
   M->WB_DES_BCO := TRB->WB_DES_BCO		// DFS - Possibilita a utilização do programa no estorno de liquidação
ENDIF                                   //       para um adiantamento sem que o sistema apresente error.log

FOR I := 1 TO FCount()
    IF (nPos:=TRB->(FIELDPOS( SWB->(FIELDNAME(I)) ))) # 0
       M->&(FIELDNAME(I)) := TRB->(FIELDGET(nPos))
    ENDIF
NEXT

//JVR - 26/10/2009 - Carrega tipo de contrato tipo 2.
If lWB_TP_CON .And. nTipo = 3
   M->WB_TP_CON := "2"
EndIf

TDt_AuxCont :=M->WB_DT_CONT
TDt_AuxVen  :=M->WB_DT_VEN

//RMD - 13/11/07 - Nova Legislação de câmbio
//EOB - 31/07/09 - Troca de EECFlags p/ AvFlags (Avgeral)
If AvFlags("CAMBIO_EXT")
   If TRB->(FieldPos("WK_VALBCO") > 0)
      M->WK_VALBCO := TRB->WK_VALBCO
   EndIf
EndIf

// GCC - 19/09/2013 - Pré-Carregamento de campos para as parcelas quando for um controle de câmbio do tipo Adiant. Forn. e Credito.
M->WB_VLIQ:= M->WB_FOBMOE - M->WB_DESCO
If M->WA_PO_DI == "F" .Or. M->WA_PO_DI == "C" .Or. M->WA_PO_DI == "A"
    M->WB_HAWB    := M->WA_HAWB
    If !AvFlags("EIC_EAI")
	    M->WB_EVENT   := PRINCIPAL
    EndIf
   If nTipo == 3
	   M->WB_INVOICE := M->WA_HAWB
   Else
      M->WB_INVOICE := IIF(!Empty(TRB->WB_INVOICE),TRB->WB_INVOICE,M->WA_HAWB)
   EndIf

	M->WB_PO_DI   := M->WA_PO_DI
   
	M->WB_TIPOREG := 'P'
	If !Empty(cFornPar) .And. !Empty(cLojaPar) .And. !Empty(cMoedaPar)		// GCC - 26/09/2013 - Carregar os campos fornecedor, loja e moeda de acordo com a primeira parcela
	 	M->WB_FORN	:= cFornPar
	  	M->WB_LOJA	:= cLojaPar
		M->WB_MOEDA	:= cMoedaPar
	EndIf
   M->WB_VLIQ:= M->WB_PGTANT - M->WB_DESCO
EndIf

// GCC - 26/09/2013 - Desabilita a entrada de dados no campo quando se tratar de inclusão/alteração de parcela de câmbio quando o mesmo já obtém um parcela.
If TRB->(Easyreccount("TRB")) # 0 .And. STR(nTipo,1) $ "3,4,5"
   If (nPosCA:=ASCAN(aGet_SWB,"WB_MOEDA")) # 0
      ADel (aGet_SWB, nPosCA         )
      ASize(aGet_SWB, Len(aGet_SWB)-1)
   EndIF
   If (nPosCA:=ASCAN(aGet_SWB,"WB_LOJA" )) # 0
      ADel (aGet_SWB, nPosCA         )
      ASize(aGet_SWB, Len(aGet_SWB)-1)
   EndIF
   If (nPosCA:=ASCAN(aGet_SWB,"WB_FORN" )) # 0
      ADel (aGet_SWB, nPosCA         )
      ASize(aGet_SWB, Len(aGet_SWB)-1)
   EndIF
EndIF

IF AvFlags("EIC_EAI") .and. STR(nTipo,1) == "4" .AND. M->WA_PO_DI == "D" //Alteração
   If (nPosCA:=ASCAN(aGet_SWB,"WB_EVENT")) # 0
      ADel (aGet_SWB, nPosCA         )
      ASize(aGet_SWB, Len(aGet_SWB)-1)
   EndIF
   If (nPosCA:=ASCAN(aGet_SWB,"WB_INVOICE")) # 0
      ADel (aGet_SWB, nPosCA         )
      ASize(aGet_SWB, Len(aGet_SWB)-1)
   EndIF
   If (nPosCA:=ASCAN(aGet_SWB,"WB_TIPOREG")) # 0
      ADel (aGet_SWB, nPosCA         )
      ASize(aGet_SWB, Len(aGet_SWB)-1)
   EndIF
   If (nPosCA:=ASCAN(aGet_SWB,"WB_MOEDA")) # 0
      ADel (aGet_SWB, nPosCA         )
      ASize(aGet_SWB, Len(aGet_SWB)-1)
   EndIF
ENDIF


If STR(nTipo,1) $ "2,5"
   If (nPosCA:=ASCAN(aGet_SWB,"WB_c")) # 0
      ADel (aGet_SWB, nPosCA         )
      ASize(aGet_SWB, Len(aGet_SWB)-1)
   EndIF
EndIF

If(Empty(Alltrim(M->WB_BCO_REC)), M->WB_BCO_REC := cBancoRec, )
If(Empty(Alltrim(M->WB_AGENREC)), M->WB_AGENREC := cAgeRec	, )
If(Empty(Alltrim(M->WB_SWIFT  )), M->WB_SWIFT   := cSwift	, )
If(Empty(Alltrim(M->WB_CON_REC)), M->WB_CON_REC := cConta	, )
IF(SWB->(FieldPos("WB_MOTBX")) > 0 .And. M->WA_PO_DI == "D" .And.  GetNewPar("MV_EASYFIN","N") = "S" .And. nTipo == 6 .And. Empty(M->WB_MOTBX), (M->WB_MOTBX := cMotBxF12),)
If lWB_EVENT
   If(Empty(Alltrim(M->WB_TIPOC)), M->WB_TIPOC := "P", )
EndIf

lInclusao:=.F.

If nTipo == 3
   lInclusao:=.T.
   If lCposAntecip
      If (Left(M->WA_PO_DI,1) == "A" .Or. Left(M->WA_PO_DI,1) == "F" .Or. Left(M->WA_PO_DI,1) == "C")	// GCC - 23/08/2013
         lInclusao:=.F.
      EndIf
   EndIf
EndIf

lVolta := .F.
IF(EasyEntryPoint("EICAP100"),Execblock("EICAP100",.F.,.F.,"ANTES_TELA_SWB"),)
//**igor chiba não deixar cambios serem manipulados se nao tiver nº titulo erp 29/09/09
IF LCAMBIO_EIC
   //IF nManut <> 2
   IF nManut <> 2  .AND.  nManut <> 8
      //IF EMPtY(TRB->WB_TITERP)
      //IF IIF(lIntegStat, TRB->WB_TITRET$cNao, EMPtY(TRB->WB_TITERP) )  // PLB 15/04/10 - Status de Retorno do ERP
      IF IIF(lIntegStat, TRB->WB_TITRET$cNao, .F. )  // PLB 15/04/10 - Status de Retorno do ERP
         IF TRB->WB_PO_DI ='D'  .AND. lEICFI05
           lVolta:=.T.
           //MSGINFO('Cambio nao pode ser manipulado por nao possuir número do titulo.')
           MSGINFO(STR0242)  // PLB 15/04/10 - Status de Processamento //STR0242 'Cambio nao pode ser manipulado pois não houve retorno do ERP.'
         ELSEIF (TRB->WB_PO_DI == 'A' .Or. TRB->WB_PO_DI == 'F' .Or. TRB->WB_PO_DI == 'C') .And. lEICFI08		// GCC - 23/08/2013
            lVolta:=.T.
            //MSGINFO('Pagto.Antecipado nao pode ser manipulado por nao possuir número do titulo.')
            MSGINFO(STR0243)  // PLB 15/04/10 - Status de Processamento //STR0243 'Pagto.Antecipado nao pode ser manipulado pois não houve retorno do ERP.'
         ENDIF
      ENDIF
   ENDIF
ENDIF
//**
IF lVolta
   dbSelectArea(cAlias)
   return .F.
ENDIF
lSoAteraCotrato:= .F.
aSWB:= AddCpoUser(aSWB,"SWB","1")  // RPM

//RMD - 31/10/16 - Preenche os campos de indicação de contrato de câmbio ou movimento no exterior.
If SWB->(FieldPos("WB_MODAL")) > 0 .And. SWB->(FieldPos("WB_PRINBC")) > 0 .And. SWB->(FieldPos("WB_VLMBCO")) > 0
   aAdd(aSWB, "WB_MODAL")
   aAdd(aSWB, "WB_PRINBC")
   aAdd(aSWB, "WB_VLMBCO")
EndIf

If ( nPosCpoDesc := aScan(aSWB,"WB_DESCO") ) > 0 .And. M->WA_PO_DI $ "A|C|F"
   aDel(aSWB,nPosCpoDesc)
   aSize(aSWB,Len(aSWB)-1)
EndIf

WHILE .T.
    nOpc1 := 0

//  cNewTit:=STR0080+SW2->W2_MOEDA+" "+ALLTRIM(TRAN( MSaldo,"@E 9,999,999,999.9999" ))//"Item do Aviso   Saldo "
    cNewTit:=""
    oMainWnd:ReadClientCoords()
    DEFINE MSDIALOG oDlg TITLE cNewTit ;
         From oMainWnd:nTop+125,oMainWnd:nLeft+5 To oMainWnd:nBottom-60,oMainWnd:nRight-10 OF oMainWnd PIXEL
//EOS  IF(nTipo=3,lInclusao:=.T.,lInclusao:=.F.)

    IF nTipo == 4
       MWB_OBS:=TRB->WB_VM_OBS
       IF lCposAntecip
          nTotParc := M->WB_PGTANT + M->WB_FOBMOE
       ENDIF
       If EasyGParam("MV_COMPAUT",,.F.) .And. SWB->(FieldPos("WB_CHAVE")) > 0 // SVG - 18/02/2010 - Novo tratamento de viculação direta de adiantamento,
          IF EMPTY(M->WB_CA_DT) .AND. !EMPTY(M->WB_FOBMOE)  //TDF - 21/11/11 - Não permite alteração em parcela já compensada
             If M->WB_TIPOTIT <> "INV"                                         //	                   não permite a alteração pois será tudo automático
                aAdd(aGet_SWB, "WB_PGTANT")
                aAdd(aGet_SWB, "WB_FOBMOE")
             Else
                aAdd(aGet_SWB, "WB_PGTANT")
             EndIf
          ELSE
             lSoAteraCotrato:= .T.
          ENDIF
       EndIf
    ENDIF

    MWB_OBS:=TRB->WB_VM_OBS

    cFiltroF3Rof := "I" //AAF - 17/04/06 - Filtro para o F3 do campo ROF

	aGet_SWB:= AddCpoUser(aGet_SWB,"SWB","1")

    If SWB->(FieldPos("WB_PGTASS")) > 0
       If !Empty(TRB->WB_PGTASS)
          M->WB_CHVASS := Ap100PGTASS(TRB->WB_PGTASS)
       Else
          M->WB_CHVASS := CriaVar("WB_CHVASS")
       EndIf
    EndIf

	SW6->(DBSEEK(xFilial("SW6")+M->WA_HAWB)) //Gustavo - Para funcionar F3 do campo Invoice (talvez não necessario mas para garantir que o ponteiro não tenha sido alterado)
    oEnCh1 := MsMGet():New( "SWB", nReg1, 4, , , ,aSWB, {15,1,FINAL_SELECT,COLUNA_FINAL},IF(STR(nTipo,1)$'2,5,8',{},IF(!AP100NaoContab(nTipo,.F.),{"WB_OBS"},aGet_SWB)) , 3)


    IF nTipo == 4
       M->WB_VM_OBS:=MWB_OBS
    ENDIF

    IF nTipo == 3 .AND. LEFT(M->WA_PO_DI,1) == "F" //MCF - 17/12/2014
    	IF SWB->(DbSeek(xFilial("SWB")+M->WA_HAWB))
    		cFornSA2 := SWB->WB_FORN
    		cLojaSA2 := SWB->WB_LOJA
    	ENDIF
    	M->WB_FORN := cFornSA2
    	M->WB_LOJA := cLojaSA2
    ENDIF

//  ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpc1:=1,IF(APEMANSWB(nTipo,nReg1),oDlg:End(),nOpc1:=0)},{|| oDlg:End() } ) ,lRefresh:=.T. )
    oEnCh1:oBox:Align := CONTROL_ALIGN_ALLCLIENT //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,;
                                               {||nOpc1:=1,IF(APEMANSWB(nTipo,nReg1,lEstAdt),oDlg:End(),nOpc1:=0)},;
                                               {||oDlg:End()},,aButtons)) //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

    IF nOpc1 == 0
       EXIT
    ENDIF

    dbSelectArea("TRB")

    If nTipo == 3
       TRB->(DBAPPEND())
       EICFI400("PERG_GERA")
       lParcFilha := .T. //CCH - 06/04/09
    Else
       TRB->(DBGOTO(nReg1))
       If Left(TRB->WB_TIPOREG,1) <> "P" .OR. M->WA_PO_DI <> "D"  // GFP - 17/04/2014
          //** GFC - 03/04/06 - Quebra automática de parcelas
          If lEffTpMod .and. nTipo = 4 .and. EasyGParam("MV_GERFILH",,"S")=="S" .And. !AP100TrataParc() //SVG - 02/08/2010 - Inclusão da verificaçã para a geração ou não de parcela com o valor da diferença.
             Exit
          EndIf
          //**
       EndIf
       lParcFilha := If (EasyGParam("MV_GERFILH",,"S")=="S",.T.,.F.) //CCH - 06/04/09
       //cParcela:= IncParcInvo("1")
       //IncParcInvo("2")
    EndIf

//If lParcFilha //CCH - 06/04/09
// TDF - 19/08/10 - Atualizações
//    If lCposAntecip .AND. LEFT(M->WA_PO_DI,1) == "A"
    If lCposAntecip .AND. (LEFT(M->WA_PO_DI,1) == "A" .Or. LEFT(M->WA_PO_DI,1) == "F" .Or. LEFT(M->WA_PO_DI,1) == "C")	// GCC - 23/08/2013
       nPGTANT := 0
       If !EMPTY(TRB->WB_CA_DT) .AND. EMPTY(M->WB_CA_DT)
          nPGTANT := -TRB->WB_PGTANT//Eh do TRB por que ele pode tirar a data e alterar o valor
       ElseIf EMPTY(TRB->WB_CA_DT) .AND. !EMPTY(M->WB_CA_DT)
          nPGTANT := M->WB_PGTANT
       ELSEIF TRB->WB_PGTANT # M->WB_PGTANT .AND. !EMPTY(TRB->WB_CA_DT) .AND. !EMPTY(M->WB_CA_DT)
          nPGTANT := M->WB_PGTANT - TRB->WB_PGTANT
       EndIf
       M->WA_SLDANT += nPGTANT
       M->WA_PGTANT += If(nTipo==3,Round(M->WB_PGTANT,2), If(nTipo==5,-Round(M->WB_PGTANT,2),0) ) //NCF - 02/06/2020
       If LEFT(M->WA_PO_DI,1) == "A"
          M->WB_MOEDA := SW2->W2_MOEDA
		  M->WB_FORN  := SW2->W2_FORN//ASR 15/09/2005 - Gravação do Fornecedor na parcela de adiantamento
		  If EICLOJA()
		     M->WB_LOJA:= SW2->W2_FORLOJ
          EndIf
       ElseIf Left(M->WA_PO_DI,1) == "F" .Or. Left(M->WA_PO_DI,1) == "C"
          If nTipo <> 6
             M->WA_CEDENTE	:= SA2->A2_NREDUZ
             M->WA_FB_NOME	:= SA2->A2_NREDUZ
          	 M->WA_BC_NOME	:= SA6->A6_NOME
          	 //M->WB_MOEDA	:= SYE->YE_MOEDA			// GCC - 23/09/2013
          EndIf
          M->WB_PGTANT := Round(M->WB_PGTANT,2)
          nTotPgtAnt   += M->WB_PGTANT
	   EndIf
    ELSE
       If Left(M->WB_TIPOREG,1) == '1'
          If Empty(M->WB_HAWB)
              M->WB_HAWB := M->WA_HAWB
           Endif
          //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
          If SW9->(DBSEEK(xFilial("SW9")+M->WB_INVOICE+M->WB_FORN+EICRetLoja("M","WB_LOJA")+M->WB_HAWB))
             M->WB_MOEDA := SW9->W9_MOE_FOB
          Endif
       Endif
       //** GFC - 23/11/05 - Câmbio de frete, seguro, comissão e embarque
       If lWB_TP_CON .and. lGeraCom .and. Left(M->WB_TIPOREG,1)="1" .and. Empty(TRB->WB_CA_DT) .AND. !EMPTY(M->WB_CA_DT)
          lBaixouP := .T.
       EndIf
       //**
    ENDIF

    //** AAF - 21/11/05 - Alteração de Demurrage no Câmbio.
    If Left(M->WB_TIPOREG,1) == 'D' .AND. Str(nTipo,1) $ '4/5'
       If (nPos := aScan(aDemurrage,{|X| X[1] == M->WB_NUMPO})) == 0
          DM100PosDem(M->WB_NUMPO,"I")
          If Str(nTipo,1) == '4'
             aAdd(aDemurrage,{M->WB_NUMPO,EG0->EG0_NEG_VL + M->WB_FOBMOE - TRB->WB_FOBMOE })
          ElseIf Str(nTipo,1) == '5'
             aAdd(aDemurrage,{M->WB_NUMPO,EG0->EG0_NEG_VL - TRB->WB_FOBMOE })
          Endif
       Else
          If Str(nTipo,1) == '4'
             aDemurrage[nPos][2] += M->WB_FOBMOE - TRB->WB_FOBMOE
          ElseIf Str(nTipo,1) == '5'
             aDemurrage[nPos][2] -= TRB->WB_FOBMOE
          Endif
       EndIf
    Endif
    //**

//**TDF - 28/07/11 - Tratamento para não permitir alteração no câmbio quando o parâmetro MV_BXCONC = 2 e a parcela já foi conciliada no financeiro.
    If lFinanceiro
       SE2->(DbSetOrder(6))
       SE5->(DbSetOrder(2))
       If SE2->(dbSeek(xFilial("SE2")+M->(WB_FORN+WB_LOJA+WB_PREFIXO+WB_NUMDUP+WB_PARCELA)))  //14/05/2020 - Adaptar Seek para título NCF
	      If SE5->(dbSeek(xFilial("SE5")+If(M->WB_TIPOTIT == "NCF", M->WB_TIPOTIT, "PA" )+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+Dtos(SE2->E2_EMISSAO)+SE2->E2_FORNECE+SE2->E2_LOJA)) .OR. SE5->(dbSeek(xFilial("SE5")+"BA"+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+Dtos(SE2->E2_EMISSAO)+SE2->E2_FORNECE+SE2->E2_LOJA))
	         If !lBxConc .And. !Empty(SE5->E5_RECONC) .And. !lSoAteraCotrato
		        MsgInfo(STR0253, STR0063 ) //STR0253 "Pagamento Antecipado não pode ser alterado pois foi conciliado/reconciliado no financeiro - Verifique o parâmetro MV_BXCONC" //STR0063  "Atenção"
			    Return .F.
		     Endif
	      EndIf
       EndIf
	EndIF
//**

    IF ! STR(nTipo,1) $ '2,5'
       If lCposAntecip
          M->WB_PO_DI := M->WA_PO_DI
       Else
          M->WB_PO_DI := "D"
       ENDIF
       AVREPLACE("M","TRB")
	   //THTS - 14/10/2019 - Ajuste de chave criado para o projeto do grupo de campos do Hawb, PO_NUM e Invoice
	   TRB->WB_CHAVE := AP100WBCHV(TRB->WB_CHAVE)
     //  TRB->WB_PARCELA := cParcela     //TRP-31/03/09- Gravação do campo parcela na inclusão de uma nova parcela de câmbio.

       If EMPTY(TRB->WB_LINHA)
          nLinhaTRB := Ap100ApuLinha("TRB")//JVR - 13/03/10
          //nLinhaTRB += 1
          TRB->WB_LINHA  := PADL(nlinhaTRB,4,"0")
       ENDIF

       nRecTRB := TRB->(Recno())  // GFP - 29/08/2014
       DO WHILE ! TRB->(Eof())
       		If Empty(TRB->WB_LINHA)
       			nLinhaTRB += 1
       	  		TRB->WB_LINHA  := PADL(nlinhaTRB,4,"0")
       		Endif
       		TRB->(dbSkip())
       Enddo
       TRB->(DbGoTo(nRecTRB))  // GFP - 29/08/2014

    ENDIF

    IF STR(nTipo,1) $ "3" .OR. (STR(nTipo,1) $ "6" .And. (LEFT(M->WA_PO_DI,1) == "A" .Or. LEFT(M->WA_PO_DI,1) == "F" .Or. LEFT(M->WA_PO_DI,1) == "C" )) // GCC - 23/08/2013 - Verificar a necessidade de manter a modalidade Credito na condição
       TRB->TRB_ALT := .T. // AWR - CONTROLE /P O FINANCEIRO - 31/05/2004
    ENDIF

    //** GFC - Quebra automática de parcelas
    If lEFFTpMod .and. nTipo <> 5 .and. Empty(TRB->WB_ORIGEM)
       TRB->WB_PARVIN := TRB->WB_LINHA
    EndIf
    //**

    //** GFC - 03/04/06 - Financiamento da Importação
    If lEFFTpMod .and. lEIC_EFF .and. nTipo = 6
       If (nPos := aScan(aVincula,{|x| x[9]==TRB->WB_INVOICE .and. x[10]==If(Empty(TRB->WB_PARFIN), TRB->WB_LINHA, TRB->WB_PARFIN)})) > 0 .and.;  // Verifica se a parcela esta vinculada
       !Empty(aVincula[nPos,3])
          aAdd(aLiquida,{TRB->WB_LINHA,"INCLUIR",TRB->WB_CA_TX, , TRB->(RecNo())})
       EndIf
    EndIf
    //**

    //** GFC - 23/11/05 - Câmbio de frete, seguro, comissão e embarque
    If lBaixouP
       nRecTRB := TRB->(RecNo())
       TRB->(dbGoTop())
       Do While !TRB->(EOF())
          If Left(TRB->WB_TIPOREG,1) = "C" .and. TRB->WB_INVOICE == M->WB_INVOICE .and. TRB->WB_DT_VEN==M->WB_DT_VEN
             TRB->WB_BANCO   := M->WB_BANCO
             TRB->WB_AGENCIA := M->WB_AGENCIA
             TRB->WB_NUM     := M->WB_NUM
             TRB->WB_DT      := M->WB_DT
             TRB->WB_LC_NUM  := M->WB_LC_NUM
             TRB->WB_NR_ROF  := M->WB_NR_ROF
             TRB->WB_DT_ROF  := M->WB_DT_ROF
             TRB->WB_DT_CONT := M->WB_DT_CONT
             TRB->WB_CA_NUM  := M->WB_CA_NUM
             TRB->WB_DT_DESE := M->WB_DT_DESE
             TRB->WB_CA_DT   := M->WB_CA_DT
             TRB->WB_CA_TX   := M->WB_CA_TX
             TRB->WB_FOBREAL := TRB->WB_FOBMOE * TRB->WB_CA_TX
             TRB->WB_LIM_BAC := M->WB_LIM_BAC
             TRB->WB_ENV_BAC := M->WB_ENV_BAC
             TRB->WB_PGTASS  := M->WB_PGTASS
          EndIf
          TRB->(dbSkip())
       EndDo
       TRB->(dbGoTo(nRecTRB))
    EndIf

    //Jacomo Lisa - Incluida a mudança de Evento quando for liquidação da principal
    IF AvFlags("EIC_EAI") .AND. STR(nTipo,1) == "6" .AND. TRB->WB_EVENT == "101"
       IF AvFlags("EAI_PGANT_INV_NF") .AND. SW6->(DBSEEK(xFilial("SW6")+TRB->WB_HAWB)) .AND. EMPTY(SW6->W6_DT_NF)
          TRB->WB_EVENT := "608"
       ENDIF
    ENDIF

    //Jacomo Lisa - 06/08/2014 -- Incluida a integração do Logix nos cenários de Liquidação/Estorno.
    IF AvFlags("EIC_EAI") .AND. STR(nTipo,1) == "6"
       SWA->(DBGOTO(nRecSWA))
       INTAP110(3)//igor chiba tratamento todo para dentro da funcao
       TRB->(DBGoTop())
    ENDIF

    EXIT
ENDDO

lRefresh:=.t.

dbSelectArea(cAlias)
return .T.

*------------------------------*
FUNCTION APEMANSWB(nTipo,nReg1,lEstAdt)
*------------------------------*
LOCAL lRet:=.T., lVinculou
Local nAuxTipo:= 0

//** PLB 25/07/06 - Tratamento Multi-Usuario Financiamento
Local nOrd := 0
Local lEstCompEAI:= .F.

//FDR - 04/07/12 - Ponto de entrada para validar a liquidação do câmbio
IF EasyEntryPoint("EICAP100")
   lRet:= ExecBlock("EICAP100",.F.,.F.,"BOTAO_LIQUIDA_OK")
   lRet:= If(lRet == NIL,.T.,lRet)  // GFP - 06/01/2014
ENDIF

If !Empty(M->WB_CA_DT) .And. M->WB_DT_DESE > M->WB_CA_DT
   MsgInfo(STR0254,STR0063) //STR0254 "Data da Liquidação deve ser maior ou igual Data de Desembolso" //STR0063  "Atenção"
   Return .F.
EndIf

If AvFlags("EIC_EAI")
   If !Empty(M->WB_CA_DT) .And. Empty(M->WB_CA_NUM)
      MsgStop(STR0371, STR0063) //"O número do contrato de câmbio deve ser informado.", "Atenção"
      Return .F.
   EndIf
EndIf
If lEIC_EFF .And. lEFFTpMod .And. (nTipo==4 .Or. nTipo==5 .Or. nTipo==6)
   nOrd := EF3->( IndexOrd() )
   EF3->( DBSetOrder(7) )
   If nTipo == 4  .Or.  nTipo == 5
      If EF3->( DBSeek(xFilial("EF3")+Left(TIPO_MODULO,1)+M->WB_HAWB+M->WB_FORN+M->WB_LOJA+M->WB_INVOICE+M->WB_LINHA+EV_EMBARQUE) )
         //NCF - 09/05/2019 - Invalida alteração de valor caso parcela esteja vinculada a contrato
         If M->WB_FOBMOE <> TRB->WB_FOBMOE
            MsgStop(STR0389 + STR0390 ,STR0063)  //"Valor da parcela não pode ser alterado pois o saldo está vinculado à um contrato de financiamento!"
            Return .F.                           //"Faça primeiramente o estorno da vinculação desta parcela ao seu referido contrato na manutenção do contrato de financiamento para posteriormente fazer esta alteração na parcela na manutenção do câmbio!"
         EndIf
         EF1->( DBSetOrder(1) )
         EF1->( DBSeek(xFilial("EF1")+EF3->EF3_TPMODU+EF3->EF3_CONTRA+EF3->EF3_BAN_FI+EF3->EF3_PRACA+EF3->EF3_SEQCNT) )
         If !SoftLock("EF1")
            lRet := .F.
         EndIf
      EndIf
   ElseIf nTipo == 6
      If EF3->( DBSeek(xFilial("EF3")+Left(TIPO_MODULO,1)+TRB->WB_HAWB+TRB->WB_FORN+TRB->WB_LOJA+TRB->WB_INVOICE+TRB->WB_LINHA+EV_EMBARQUE) )
        //NCF - 09/05/2019 - Invalida alteração de valor caso parcela esteja vinculada a contrato
         If M->WB_FOBMOE <> TRB->WB_FOBMOE
            MsgStop(STR0389 + STR0390 ,STR0063)  //"Valor da parcela não pode ser alterado pois o saldo está vinculado à um contrato de financiamento!"
            Return .F.                           //"Faça primeiramente o estorno da vinculação desta parcela ao seu referido contrato na manutenção do contrato de financiamento para posteriormente fazer esta alteração na parcela na manutenção do câmbio!"
         EndIf
         EF1->( DBSetOrder(1) )
         EF1->( DBSeek(xFilial("EF1")+EF3->EF3_TPMODU+EF3->EF3_CONTRA+EF3->EF3_BAN_FI+EF3->EF3_PRACA+EF3->EF3_SEQCNT) )
         If !SoftLock("EF1")
            lRet := .F.
         EndIf
      EndIf
   EndIf
   EF3->( DBSetOrder(nOrd) )
EndIf
//**

If lRet
   IF nTipo # 5
      IF nTipo = 6 // AWR - 06/07/2004
         IF ( EMPTY(M->WB_BANCO) .OR. EMPTY(M->WB_AGENCIA) .OR. EMPTY(M->WB_CA_DT) ) .OR.;
          ( (!AvFlags("CAMBIO_EXT") .OR. M->WB_TIPOPAG <> "2") .AND. EMPTY(M->WB_CA_TX) ) //AAF 08/02/08 - Não verificar liquidação para movimentação no exterior. EOB - 31/07/09 - Troca de EECFlags p/ AvFlags (Avgeral)

            MSGSTOP(STR0141) //"Campos: Banco, Agencia, Liquidacao e Taxa devem ser preenchidos."
            RETURN .F.
         ENDIF// AWR - 06/07/2004
         If !(lRet:=APESWBLinOk(nTipo))
            Return lRet
         EndIf
      ELSEIF nTipo # 2
         lRet:=Obrigatorio(aGets,aTela)
         IF lRet
            lRet:=APESWBLinOk(nTipo)
         ENDIF
      ENDIF
   ELSE
      IF lExisteContabil
        IF !EMPTY(TRB->WB_CONTAB)
          Help("", 1, "AVG0000192")
          RETURN .T.
        Endif
      ENDIF

      TRB->(DBGOTO(nReg1))

      lSairFI400:=.F.
      EICFI400("VAL_PARC_EXCLUI")
      IF lSairFI400
         RETURN .F.
      ENDIF

      //AAF - 21/11/05 - Exclusão de Demurrage.
      IF IIF(lEstAdt,MsgYesNo(STR0407,STR0408),MsgYesNo(STR0081,STR0082)) .AND. If(Left(TRB->WB_TIPOREG,1) == 'D',DM100EstImp(),.T.) .and.;//"Confirma Estorno ?"####"Estornar"###'Confirma Exclusão ? '###'Excluir'
      If(lEffTpMod, IIF(ValFin("PARC"),Ap1DelParc(),.F.), .T.)  // PLB 13/10/06
         IF TRB->WB_RECNO # 0
            AADD(aDeletados,TRB->WB_RECNO)
         ENDIF
         nRecPrinc := 0
         //JVR - 31/03/10 - atualização dos valores da tela no caso de estorno.
         If lAdVinculado
            //Adiciona o Array com informações necessarias para o estorno
            aAdd(aEstComp,{ TRB->WB_CHAVE               ,;
                            GetInfSe2("RECNO", TRB->WB_CHAVE ),;
                            GetInfSe2("CHAVE_PA", TRB->WB_CHAVE ),;
                            TRB->WB_RECNO,;
                            TRB->WB_FILORI;
                            })
			//Salva informações iniciais da TRB.
            nValEstorno := TRB->WB_PGTANT
            cChave      := TRB->WB_CHAVE
            nRecno      := TRB->(RECNO())
            If AVFLAGS('AVINT_CAMBIO_EIC')
               cNumTitERP  := TRB->WB_TITERP  // AVG - Limpar TITERPV da principal
            EndIf
            //Edita as informações da TRB.
            TRB->(DBGOTOP())
            While TRB->(!EOF())
               If TRB->(WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN+WB_LOJA+WB_LINHA) == Alltrim(cChave)
                  TRB->WB_PGTANT -= nValEstorno
                  TRB->WB_FOBMOE += nValEstorno
                  nRecPrinc := TRB->(RecNo())
                  If EasyGParam("MV_EIC0043",,.F.)  // GFP - 17/03/2014
                     TRB->WB_CA_DT  := CTOD("")
                  EndIf
                  // AVG - Limpar TITERPV da principal
                  If AVFLAGS('AVINT_CAMBIO_EIC')
                     If TRB->WB_TITERPV = cNumTitERP
                        TRB->WB_TITERPV = '' 
                     EndIf
                  EndIf
                  // AVG - Limpar TITERPV da principal
                  Exit
               EndIf
               TRB->(DBSKIP())
            EndDo
            TRB->(DBGOTO(nRecno))
         EndIf

         If lCposAntecip
//            IF LEFT(M->WA_PO_DI,1) == "A" .AND. !EMPTY(TRB->WB_CA_DT)
            IF (Left(M->WA_PO_DI,1) == "A" .Or. Left(M->WA_PO_DI,1) == "F" .Or. Left(M->WA_PO_DI,1) == "C") .AND. !EMPTY(TRB->WB_CA_DT)	// GCC - 23/08/2013
               M->WA_SLDANT-=M->WB_PGTANT
            ENDIF
         ENDIF
         cAux_NumPO := TRB->WB_NUMPO
         TRB->DBDELETE := .T.//ASR 26/12/2005 - NÃO PERMITE GRAVAR CAPA SEM DETALHE - GRAVA .T. PARA VALIDAR DEPOIS #### THTS - 03/10/2017 - Alterado o nome para DBDELETE
         TRB->(DBDELETE())
		 nRecCompAdi := TRB->(RecNo())
         IF SELECT("WORK1") > 0 .And. lAdVinculado		//NCF - 03/08/2010 - Atualização do saldo temporário de adiantamento
            IF Work1->(DbSeek(cAux_NumPO))
               Work1->WA_SLDANT := Work1->WA_SLDANT - ApuSldWork1(cAux_NumPo)
               lEstCompEAI:= .T.
            ENDIF
         ENDIF

		 //AAF 03/09/2014
		 If AvFlags("EIC_EAI")
         // wfs jul/2017 - diferenciar estorno da compensação da exclusão da parcela
            If lEstCompEAI
                nAuxTipo:= 7
            EndIf
            TRB->(dbGoTo(nRecCompAdi))
			INTAP110(5, nAuxTipo) //Baixa referente a compensação de adiantamento.//wfs jul/2017 - segundo parâmetro para diferenciar estorno da compensação da exclusão da parcela
            aEstComp := {}
			Return .T.
		 EndIf
      ENDIF
   ENDIF
EndIf

//RMD - 12/11/07 - Nova legislação de câmbio
//EOB - 31/07/09 - Troca de EECFlags p/ AvFlags (Avgeral)
If AvFlags("CAMBIO_EXT")
   lVinculou := .F.
   If lRet .And. (nTipo == 3 .Or. nTipo == 4 .Or. nTipo == 6)
      If M->WB_TIPOPAG == "2"
         If !IsBancoExt(M->WB_BANCO, M->WB_AGENCIA, M->WB_CONTA)
            MsgStop(STR0255 + ENTER + STR0256, STR0063) //STR0255 "O banco informado não controla movimentações no exterior." //STR0256 "Verifique o cadastro do banco." //STR0063  "Atenção"
            lRet := .F.
         EndIf
         /* JPM - 13/01/2010 - não é a data de desembolso que sensibiliza as movimentações no exterior, e sim a data de liquidação.
         If lRet .And. nTipo <> 6 .And. (!Empty(M->WB_DT_DESE) .And. Empty(TRB->WB_DT_DESE))
            MsgStop("Quando o pagamento for do tipo transferência no exterior a data do desembolso deve ser informada na opção 'Liquidação'", "Atenção")
            lRet := .F.
         EndIf
         */
         //** AAF 03/03/08 - Verifica se existe natureza associada ao evento
         If lRet .And. Empty(GetNatureza("IMP", M->WB_EVENT))
            MsgStop(STR0257, STR0063)//STR0257 "Não é possivel realizar a transferencia no exterior pois não há natureza de movimentação associada a este evento. Verifique o cadastro de eventos contábeis." //STR0063  "Atenção"
            lRet := .F.
         EndIf
         //**
      EndIf
   EndIf
   If lRet .And. nTipo == 6 .And. M->WB_TIPOPAG == "2"

      //** AAF 05/03/08 - Verificar saldo na conta
      nSaldo := AD101GetSld(M->WB_BANCO,;
                            M->WB_AGENCIA,;
                            M->WB_CONTA,;
                            Left(DtoS(M->WB_CA_DT), 6))

      If TRB->WB_RECNO > 0
         nRec := SWB->(RecNo())
         SWB->(dbGoTo(TRB->WB_RECNO))
      EndIF
      //**

      If Ad101ChkInv("TRB", "M", "IMP", INCLUIR, TRB->WB_RECNO <> 0)
//         M->WK_VALBCO := Ad101ValBco(If(M->WB_PO_DI == 'A', M->WB_PGTANT, M->WB_FOBMOE),;
         M->WK_VALBCO := Ad101ValBco(If( (M->WB_PO_DI == 'A' .Or. M->WB_PO_DI == 'F' .Or. M->WB_PO_DI == 'C'), M->WB_PGTANT, M->WB_FOBMOE),;	// GCC - 23/08/2013
                                     M->WB_MOEDA,;
                                     Posicione("SA6", 1, xFilial("SA6")+M->(WB_BANCO+WB_AGENCIA+WB_CONTA), "A6_MOEEASY"),;
                                     ,;
                                     M->WB_CA_DT,;
                                     IsReceita(M->WB_EVENT))

         lRet := M->WK_VALBCO > 0
         //** AAF 05/03/08 - Verificar saldo na conta
         If lRet .AND. (nSaldo < M->WK_VALBCO)
            MsgStop(STR0258+AllTrim(Left(DtoS(M->WB_CA_DT), 6))+":"+ENTER+; //STR0258 "Não há saldo na conta para pagamento por transfêrencia no exterior no mês "
                    STR0259+AllTrim(SA6->A6_MOEEASY)+Transform(nSaldo      ,AvSx3("WB_FOBMOE",AV_PICTURE))+ENTER+ENTER+; // ** JPM - 10/12/2009 - mostrar saldo e valor //STR0259 "Saldo no Banco: "
                    STR0260+AllTrim(SA6->A6_MOEEASY)+Transform(M->WK_VALBCO,AvSx3("WB_FOBMOE",AV_PICTURE)), STR0063) //STR0260 "Valor a Pagar : " //STR0063  "Atenção"
            lRet := .F.
         Else
            lVinculou := .T.
         EndIf
         //**
      ElseIf Ad101ChkInv("SWB", "M", "IMP", ALTERAR, TRB->WB_RECNO <> 0) //AAF 05/03/08 - Verificar pela Base. //Ad101ChkInv("TRB", "M", "IMP", ALTERAR, TRB->WB_RECNO <> 0)
//         M->WK_VALBCO := Ad101ValBco(If(M->WB_PO_DI == 'A', M->WB_PGTANT, M->WB_FOBMOE),;
         M->WK_VALBCO := Ad101ValBco(If( (M->WB_PO_DI == 'A' .Or. M->WB_PO_DI == 'F' .Or. M->WB_PO_DI == 'C'), M->WB_PGTANT, M->WB_FOBMOE),;	// GCC - 23/08/2013
                                     M->WB_MOEDA,;
                                     Posicione("SA6", 1, xFilial("SA6")+M->(WB_BANCO+WB_AGENCIA+WB_CONTA), "A6_MOEEASY"),;
                                     If(M->WK_VALBCO > 0, M->WK_VALBCO,),;
                                     M->WB_CA_DT,;
                                     IsReceita(M->WB_EVENT))

         lRet := M->WK_VALBCO > 0

         nOrd := EYR->(IndexOrd())
         EYR->( dbSetOrder(5) )
         If lRet .AND. EYR->( dbSeek(xFilial("EYR")+xFilial("SWB")+SWB->(WB_HAWB+WB_INVOICE+WB_LINHA)) )
            //** AAF 05/03/08 - Verificar saldo na conta
            If nSaldo < M->WK_VALBCO - EYR->EYR_VALOR
               MsgStop(STR0258+AllTrim(Left(DtoS(M->WB_CA_DT), 6))+":"+ENTER+; //STR0258 "Não há saldo na conta para pagamento por transfêrencia no exterior no mês "
                       STR0259+AllTrim(SA6->A6_MOEEASY)+Transform(nSaldo                       ,AvSx3("WB_FOBMOE",AV_PICTURE))+ENTER+ENTER+; // ** JPM - 10/12/2009 - mostrar saldo e valor ////STR0259 "Saldo no Banco: "
                       STR0260+AllTrim(SA6->A6_MOEEASY)+Transform(M->WK_VALBCO - EYR->EYR_VALOR,AvSx3("WB_FOBMOE",AV_PICTURE)), STR0063) //STR0260 "Valor a Pagar : " //STR0063  "Atenção"
               lRet := .F.
            Else
               lVinculou := .T.
            EndIf
            //**
         EndIf
         EYR->( dbSetOrder(nOrd) )

      EndIf

      SWB->(dbGoTo(nRec)) //AAF 05/03/08

   EndIf
EndIf

RETURN lRet

*------------------------------*
FUNCTION Ape_Vl_Real(_Fob,_Taxa)
*------------------------------*
LOCAL _Valor:= 0

IF lCposAntecip .AND. Left(M->WB_TIPOREG,1) == "P"//IF por causa do X3_RELACAO
   nFob:=M->WB_PGTANT
ENDIF
IF _Taxa <> 0
   _Valor:= _Fob * _Taxa
ENDIF
RETURN _Valor

*--------------------------------------*
FUNCTION APE100_Tipo()
*--------------------------------------*
SX5->( DbSetOrder( 1 ) )
SX5->( DbSeek( xFilial()+"Y6"+TRB->WB_TIPOREG ) )
RETURN Left(TRB->WB_TIPOREG,1)+'-'+LEFT(X5DESCRI(),15)

*---------------------*
Function APESWALinOk()
*---------------------*
LOCAL aCampos:={ {"WA_CODCEDE","CEDENTE" } }, nInd ,P
LOCAL lRet := .T., nRec
//** GFC - 22/11/05 - Câmbio de frete, seguro, comissão e embarque
Local nFrete:=0, nSeguro:=0, aComissao:={}, nComissao:=0, aComInv:={}
//**
Local nParcel := 0
Local lExibeMSG := .T.
//TDF - 18/04/11 - Integração com financeiro
Local lFinanceiro:=GetNewPar("MV_EASYFIN","N")=="S"// .AND. GetNewPar("MV_EASY","N")=="S"
Private lRetVal := .T.
Private lInvDifere := .F.
SX3->(DbSetOrder(2))
Private lW2ConaPro := SX3->(DbSeek("W2_CONAPRO")) .AND. EasyGParam("MV_AVG0170",,.F.)  //CCH - 05/06/09 - Teste do parâmetro MV_AVG0170 para definir se habilita Controle de Alçadas no EIC.
Private lBloqAlc := .T.

//**igor chiba  nao deixar incluir se a invoice nao tiver tit.erp  01/10/09
IF lCAMBIO_EIC .AND. lEICFI06
   IF nPos_aRotina = 3 .AND. M->WA_PO_DI == 'D'
      SW9->(DBSETORDER(3))
      IF SW9->(DBSEEK(xfilial('SW9')+M->WA_HAWB)) .AND. EMPTY(SW9->W9_TITERP)
         MSGINFO(STR0261) //STR0261 'Cambio não pode ser incluído, pois invoice não possui título ERP.'
         RETURN .F.
      ENDIF
   ENDIF
ENDIF
//**
IF !AvFlags("EIC_EAI") .And. lW2ConaPro .And. !Empty(SW2->W2_CONAPRO) .And. SW2->W2_CONAPRO<>"L"
   MsgStop(STR0263,STR0063) //STR0263 "Pedido não liberado pela Alçada!" //STR0063  "Atenção"
   lBloqAlc := .F.
   Return lBloqAlc
ENDIF

If EasyGParam("MV_EASYFIN",,"N") == "S"  //SVG - 11/08/08 CH:706874 verifica se está integrado, antes de setar a tabela SE2
   SE2->(DBSETORDER(1))   //TLM  12/02/2008 - Atualiza a data de vencimento na tabela SE2
   TRB->(DBGOTOP())    // GFP - 18/01/2013 - Sistema deve atualizar datas de vencimento de todas as parcelas.
      DO WHILE TRB->(!EOF())
         If SE2->(DBSEEK(xFilial()+TRB->WB_PREFIXO+TRB->WB_NUMDUP+TRB->WB_PARCELA+TRB->WB_TIPOTIT+TRB->WB_FORN+TRB->WB_LOJA)) .And. TRB->WB_DT_VEN # SWB->WB_DT_VEN
         //TDt_AuxVen # NIL .And. TDt_AuxVen # SWB->WB_DT_VEN
            SE2->(RecLock("Se2",.F.))
            SE2->E2_VENCTO := TRB->WB_DT_VEN //TDt_AuxVen
            SE2->E2_VENCREA:= DataValida(TRB->WB_DT_VEN,.T.)//DataValida(TDt_AuxVen,.T.)
            SE2->(MsUnlock())
         EndIf
         TRB->(DBSKIP())
      ENDDO
EndIf
IF lValid .AND. TRB->(Easyreccount("TRB")) < 1 //NCF - 20/08/2019 - Não permitir gravar registro(SWA) sem detalhes(SWB)
   Help("", 1, "AVG0000193")
   Return .F.
ENDIF

IF EasyEntryPoint("EICAP100") //OS 0639/01 FCD
   ExecBlock("EICAP100",.F.,.F.,"VALIDA_HAWB")
ENDIF

FOR nInd:=1 TO LEN(aCampos)
    IF ! APE100Crit(aCampos[nInd,2],aCampos[nInd,1],PAlteracao)
       lRet:=.F.
       EXIT
    ENDIF
NEXT

If lSegundaVez //** GFC - 23/11/05
   IF lCposAntecip //.AND. lSegundaVez - Comentado por GFC - 23/11/05
      nTotal   := 0
      nFobMoe  := 0
      nPgtAnt  := 0
      nPgAntDI := 0
      aToPOs   := {}
      aTotal   := {}
      aTotalInv:= {}
      aFobMoe  := {}
      aFobInv  := {}
      aPgtAnt  := {}
      nFrete   := 0
      nSeguro  := 0
      aComissao:= {}
      aComInv  := {}
      nComissao:= 0
      IF LEFT(M->WA_PO_DI,1) == 'D'  // total do processo
         SW9->(dbSetOrder(3))
         SW9->(dbSeek(xFilial()+M->WA_HAWB))
         DO WHILE !SW9->(Eof()) .AND. SW9->W9_Filial == xFilial("SW9") ;
         .AND. SW9->W9_Hawb   == M->WA_HAWB

            SY6->(DBSETORDER(1))
            IF SY6->(DBSEEK(xFilial("SY6")+SW9->W9_COND_PA+STR(SW9->W9_DIAS_PA,3) )) .AND. ;
            SY6->Y6_TIPOCOB <> "4" // EOS - Somente se tiver cob. cambial
               Valor_Inv:= DI500RetVal("TOT_INV", "TAB", .T.)  // EOB - 14/07/08 - chamada da função DI500RetVal

               If EasyGParam("MV_IN327" ,,.F.) .AND. !Empty(SW9->W9_DESCONT)
                  Valor_Inv -= SW9->W9_DESCONT
               EndIf

               nPos := ASCAN( aTotal, { |X| X[1] == SW9->W9_MOE_FOB } )
               IF nPos == 0
                  AADD( aTotal, { SW9->W9_MOE_FOB, Valor_Inv, If(lWB_TP_CON .and. lGeraCom,SW9->W9_VALCOM,0) } )
               ELSE
                  aTotal[nPos,2] += Valor_Inv
                  aTotal[nPos,3] += If(lWB_TP_CON .and. lGeraCom,SW9->W9_VALCOM,0)
               ENDIF
               //** GFC - 21/11/05 - Câmbio de frete, seguro, comissão e embarque
               nPos := ASCAN( aTotalInv, { |X| X[1] == SW9->W9_INVOICE } )
               IF nPos == 0
                  AADD( aTotalInv, { SW9->W9_INVOICE, Valor_Inv, If(lWB_TP_CON .and. lGeraCom,SW9->W9_VALCOM,0), SW9->W9_MOE_FOB } )
               ELSE
                  aTotalInv[nPos,2] += Valor_Inv
                  aTotalInv[nPos,3] += If(lWB_TP_CON .and. lGeraCom,SW9->W9_VALCOM,0)
               ENDIF
               //**
               nTotal += Valor_Inv
            ENDIF
            SW9->(dbSkip())
         ENDDO
         SW9->(dbSetOrder(1))

      ElseIf LEFT(M->WA_PO_DI,1) == 'A' .AND. SW2->(DBSEEK(xFilial("SW2")+Left(M->WA_HAWB,AvSX3("W2_PO_NUM",AV_TAMANHO))))
         SW2->(DbSeek(xFilial()+M->WA_HAWB))  // total do pedido
         nTotal:=ValorPed()+SW2->W2_INLAND+SW2->W2_PACKING+SW2->W2_SEGURIN+SW2->W2_FRETEIN-SW2->W2_DESCONT+SW2->W2_OUT_DES //LRS - 31/08/2017

      ElseIf LEFT(M->WA_PO_DI,1) == 'F' .Or. LEFT(M->WA_PO_DI,1) == 'C'
         If SWA->(DbSeek(xFilial("SWA")+M->WA_HAWB))
            nTotal := SWA->WA_PGTANT
         Else
            nTotal := M->WA_PGTANT
         EndIf
      EndIf

      lSemInv := " "
      TRB->(DBGOTOP())
      DO WHILE TRB->(!EOF())
         IF Left(TRB->WB_TIPOREG,1) == "P"
            IF EMPTY(TRB->WB_INVOICE)
               lSemInv := TRB->WB_PO_DI
            ENDIF
            nPos := ASCAN( aPgtAnt, { |X| X[1] == TRB->WB_MOEDA } )
            IF nPos == 0
               AADD( aPgtAnt, { TRB->WB_MOEDA, TRB->WB_PGTANT  } )
            ELSE
               aPgtAnt[nPos,2] += TRB->WB_PGTANT
            ENDIF
            nPgtAnt+=TRB->WB_PGTANT   // Parcela de Adiantamento gerada como tipo P
            IF !EMPTY(TRB->WB_NUMPO)
               IF (nPos:=ASCAN(aToPOs,{|A| A[1]==TRB->WB_NUMPO })) = 0
                  AADD(aToPOs,{TRB->WB_NUMPO,TRB->WB_PGTANT})
               ELSE
                  aToPOs[nPos,2]+=TRB->WB_PGTANT
               ENDIF
            ENDIF
         ELSEIF Left(TRB->WB_TIPOREG,1) == "1" .AND. TRB->WB_PO_DI == "D"
         /* ISS - 18/01/11 - Validação para a cotação da moeda do financeiro, caso exista uma cotação e a mesma esteja zerada,
            o sistema não abate as parcelas INV e PA no financeiro, liberar a vinculação do EIC somente quando a cotação estiver correta */
            If lFinanceiro  //TDF - 18/04/11 Verifica se está integrado com o financeiro
               IF lCompAut .AND. lCposAntecip .AND. TRB->WB_PGTANT > 0
                  If !ValidBaixa()
                     If lExibeMSG
                        MsgInfo(STR0043 + " " + TRB->WB_MOEDA + STR0230 + DTOC(dDatabase) + STR0240)
                        lExibeMSG := .F.
                     EndIf
                     Return .F.
                  EndIf
               EndIf
            EndIf

            nPos := ASCAN( aFobMoe, { |X| X[1] == TRB->WB_MOEDA } )
            IF nPos == 0
               AADD( aFobMoe, { TRB->WB_MOEDA, TRB->WB_FOBMOE  } )
            ELSE
               aFobMoe[nPos,2] += TRB->WB_FOBMOE
            ENDIF
            nFobMoe+=TRB->WB_FOBMOE
            nPgAntDi+=TRB->WB_PGTANT  // Esta dentro de uma parcela de DI digitando o adto

            //** GFC - 22/11/05 - Câmbio de frete, seguro, comissão e embarque
            nPos := ASCAN( aFobInv, { |X| X[1] == TRB->WB_INVOICE } )
            IF nPos == 0
               AADD( aFobInv, { TRB->WB_INVOICE, TRB->WB_FOBMOE + TRB->WB_PGTANT })//If(TRB->WB_FOBMOE<>0, TRB->WB_FOBMOE, TRB->WB_PGTANT)  } )
            ELSE
               aFobInv[nPos,2] += TRB->WB_FOBMOE + TRB->WB_PGTANT//If(TRB->WB_FOBMOE<>0, TRB->WB_FOBMOE, TRB->WB_PGTANT)
            ENDIF
            //**
         //** GFC - 22/11/05 - Câmbio de frete, seguro, comissão e embarque
         ElseIf Left(TRB->WB_TIPOREG,1) == "A"  // Frete
            nFrete  += TRB->WB_FOBMOE
         ElseIf Left(TRB->WB_TIPOREG,1) == "B"  // Seguro
            nSeguro += TRB->WB_FOBMOE
         ElseIf Left(TRB->WB_TIPOREG,1) == "C"  // Comissão
            nPos := ASCAN( aComissao, { |X| X[1] == TRB->WB_MOEDA } )
            IF nPos == 0
               AADD( aComissao, { TRB->WB_MOEDA, TRB->WB_FOBMOE  } )
            ELSE
               aComissao[nPos,2] += TRB->WB_FOBMOE
            ENDIF

            nPos := ASCAN( aComInv, { |X| X[1] == TRB->WB_INVOICE } )
            IF nPos == 0
               AADD( aComInv, { TRB->WB_INVOICE, TRB->WB_FOBMOE  } )
            ELSE
               aComInv[nPos,2] += TRB->WB_FOBMOE
            ENDIF
         //**
         ENDIF
         IF EasyEntryPoint("EICAP100")
            ExecBlock("EICAP100",.F.,.F.,"ADICIONA_PARCELA")   //TRP-12/12/07 - Inclusão de ponto de entrada
         ENDIF
      
         //wfs jun/2017 - exibir mensagem de divergência quando não houver invoice relacionada à parcela de câmnbio não integrada
         If AvFlags("EIC_EAI") .And. Len(aTotal) == 0
            AAdd(aTotal, {TRB->WB_MOEDA, 0, 0})
         EndIf

         TRB->(DBSKIP())
      ENDDO
      /*
      FOR P := 1 TO LEN(aToPOs)
          IF Work1->(DBSEEK(aToPOs[P,1])) .AND.;
             aToPOs[P,2] > Work1->WB_PGTANT
             MSGSTOP(STR0192+ALLTRIM(aToPOs[P,1])+CHR(13)+CHR(10)+;    // "Pedido: " ###
                     STR0193+ALLTRIM(TRANS(aToPOs[P,2],AVSX3("WA_SLDANT",6)))+CHR(13)+CHR(10)+;  // "Somatoria das Parcelas Antecipadas: " ###
                     STR0194+ALLTRIM(TRANS(Work1->WB_PGTANT,AVSX3("WA_PGTANT",6))),STR0195)  // "e maior que o Saldo do Pedido: " ### , "Saldo dos Pedidos"
             lRet:=.F.
          ENDIF
      NEXT
      */
      cMem:=""
      IF LEFT(M->WA_PO_DI,1) == 'A' .Or. LEFT(M->WA_PO_DI,1) == 'C'	// .AND. lRet
         IF nPgtAnt > nTotal
            MsgAlert(STR0339,STR0063)  // GFP - 16/04/2014 // "A soma do valor associado e do valor do adiantamento ultrapassam o valor total a pagar do processo." ### "Atenção"
            lRet:=.F.
         ENDIF
      ENDIF
//   IF !lRet  //ACB - 12/05/2010
     IF (!lRet .and. nPgtAnt # nTotal .AND. (LEFT(M->WA_PO_DI,1) == 'A' .Or. LEFT(M->WA_PO_DI,1) == 'C' .AND. SW2->(DBSEEK(xFilial("SW2")+Left(M->WA_HAWB,AvSX3("W2_PO_NUM",AV_TAMANHO)))))) .AND. M->WA_PO_DI <> "C" // GFP - 16/04/2014
         MSGSTOP(STR0196+ALLTRIM(TRANS(nPgtAnt,AVSX3("WB_PGTANT",6)))+CHR(13)+CHR(10)+cMem+;  // "Parcelas Antecipadas: " ###
                 STR0197+ALLTRIM(TRANS(nTotal,AVSX3("WB_PGTANT",6)))+CHR(13)+CHR(10)+;        // "difere do Total do Processo: " ###
                 STR0198+ALLTRIM(TRANS( ABS(nTotal-(nPgtAnt+nFobMoe)) ,AVSX3("WB_PGTANT",6))),STR0199)  // "Total da Diferenca: " ### , "Totais das Parcelas"
         lRet:=.F.
      ELSEIF nPgAntDi > nPgtAnt
         MSGSTOP(STR0200 + CHR(13)+CHR(10)+;  // "Valores antecipados cadastrados estao maiores que os valores "
                 STR0201, STR0202 )       // "cadastrados com o tipo 'P' de Pagamento Antecipado " , "Diferença"
         lRet:=.F.
      ELSEIF !EMPTY(lSemInv)
         MSGSTOP(STR0203+IIF(lSemInv=="A","Proforma ","")+;  // "Ha registros de Pgto Antecipado sem a " ###
                 STR0204, STR0063 )  // "Invoice cadastrada" , "Atenção"
         lRet:=.F.
      ENDIF

      FOR P := 1 TO LEN(aTotal)
          nSomaAnt  := 0
          nSomaFob  := 0
          nAnt      := ASCAN( aPgtAnt  , { |X| X[1] == aTotal[P,1] } )
          nFob      := ASCAN( aFobMoe  , { |Y| Y[1] == aTotal[P,1] } )
          IF nAnt > 0
             nSomaAnt := aPgtAnt[nAnt,2]
          ENDIF
          IF nFob > 0
             nSomaFob := aFobMoe[nFob,2]
          ENDIF

          //** GFC - 22/11/05 - Câmbio de frete, seguro, comissão e embarque
          If lWB_TP_CON
             nCom := ASCAN( aComissao, { |Y| Y[1] == aTotal[P,1] } )
             IF nCom > 0
                nComissao := aComissao[nCom,2]
             ENDIF
          EndIf
          //**

          IF !(aTotal[P,2] = nSomaAnt + nSomaFob)
             // EOS - qdo nao tem adiantamentos e o total das parcelas de cambio nao bate
             // com o total do processo, perguntar se valores estao corretos...
             IF nSomaAnt == 0// .Or. EasyGParam("MV_GERFILH",,"S")=="N"
                cInfo := STR0206+aTotal[P,1]+CHR(13)+CHR(10)+;  // "Diferenca encontrada em " ##
                         STR0207+ALLTRIM(TRANS(aTotal[P,2],AVSX3("WB_PGTANT",6)))+CHR(13)+CHR(10)+;  // "Total do processo  : " ###
                         STR0208+ALLTRIM(TRANS(nSomaFob,AVSX3("WB_FOBMOE",6)))+CHR(13)+CHR(10)+;  // "Parcelas de cambio : " ###
                         STR0209+ALLTRIM(TRANS( ABS(aTotal[P,2]-nSomaFob),AVSX3("WB_FOBMOE",6)))//+CHR(13)+CHR(10)+;  // "Total da Diferença : " ###
                         //STR0210  // "Confirma as alterações?" , "Diferença"
                IF AvFlags("EIC_EAI")
                   If M->WA_PO_DI == "D"
                      MSGSTOP(cInfo, STR0202)
                      lRet := .F.
                   EndIf
                ELSE
                   lRet := MsgYesNo(cInfo + Chr(13) + Chr(10) + STR0210, STR0202)  // "Confirma as alterações?" , "Diferença"
                ENDIF
             lInvDifere := .T.
             ELSE
                cInfo:= STR0206+aTotal[P,1]+CHR(13)+CHR(10)+;  // "Diferenca encontrada em " ###
                        STR0207 +ALLTRIM(TRANS(aTotal[P,2],AVSX3("WB_PGTANT",6)))+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;  // "Total do processo  : " ###
                        STR0211 +ALLTRIM(TRANS(nSomaAnt,AVSX3("WB_PGTANT",6)))+CHR(13)+CHR(10)+;  // "  Total Antecipado  : " ###
                        "+ "+STR0208+ALLTRIM(TRANS(nSomaFob,AVSX3("WB_PGTANT",6)))+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;  // "Parcelas de cambio : " ###
                        STR0209 +ALLTRIM(TRANS( ABS(aTotal[P,2]-(nSomaAnt+nSomaFob)) ,AVSX3("WB_PGTANT",6)))//+CHR(13)+CHR(10)+; // "Total da Diferença : " ###
						//STR0210 // "Confirma as alterações?" , "Diferença na moeda"
                IF AvFlags("EIC_EAI")
                   If M->WA_PO_DI == "D"
                      MSGSTOP(cInfo, STR0212)
                      lRet := .F.
                   EndIf
                ELSE
                   lRet := MsgYesNo(cInfo + Chr(13) + Chr(10) + STR0210, STR0212)  // "Confirma as alterações?" , "Diferença"
                ENDIF

                EXIT
             ENDIF
          //** GFC - 22/11/05 - Câmbio de frete, seguro, comissão e embarque
          ElseIf lWB_TP_CON .and. lGeraCom .and. aTotal[P,3] <> nComissao
             cInfo := STR0213+aTotal[P,1]+CHR(13)+CHR(10)+;  // "Dif. de comissão encontrada em " ###
                      STR0214+ALLTRIM(TRANS(aTotal[P,3],AVSX3("WB_PGTANT",6)))+CHR(13)+CHR(10)+;  // "Total de comissao  : " ###
                      STR0215+ALLTRIM(TRANS(nComissao,AVSX3("WB_FOBMOE",6)))+CHR(13)+CHR(10)+;  // "Parcelas de com.   : " ###
                      STR0209+ALLTRIM(TRANS( ABS(aTotal[P,3]-nComissao),AVSX3("WB_FOBMOE",6)))//+CHR(13)+CHR(10)+;  // "Total da Diferença : " ###
                      //STR0210  // "Confirma as alterações?" , "Diferença"
             IF AvFlags("EIC_EAI") .AND. M->WA_PO_DI == "D"
                MSGSTOP(cInfo, STR0212)
                lRet := .F.
             ELSE
                lRet := MsgYesNo(cInfo + Chr(13) + Chr(10) + STR0210, STR0212)  // "Confirma as alterações?" , "Diferença"
             ENDIF
          //**
          ENDIF
      NEXT

      //** GFC - 22/11/05 - Câmbio de frete, seguro, comissão e embarque
      If lRet .AND. lGravaFin_EIC
         FOR P := 1 TO LEN(aTotalInv)
             nSomaFob  := 0
             nFob      := ASCAN( aFobInv  , { |Y| Y[1] == aTotalInv[P,1] } )
             IF nFob > 0
                nSomaFob := aFobInv[nFob,2]
             ENDIF

             If lWB_TP_CON
                nCom := ASCAN( aComInv, { |Y| Y[1] == aTotalInv[P,1] } )
                IF nCom > 0
                   nComissao := aComInv[nCom,2]
                ENDIF
             EndIf

             IF !(aTotalInv[P,2] = nSomaFob)
                cInfo := STR0218+Alltrim(aTotalInv[P,1])+STR0219+aTotalInv[P,4]+CHR(13)+CHR(10)+;  // "Diferença em " ### " na moeda " ###
                         STR0207+ALLTRIM(TRANS(aTotalInv[P,2],AVSX3("WB_FOBMOE",6)))+CHR(13)+CHR(10)+;  // "Total do processo  : "
                         STR0208+ALLTRIM(TRANS(nSomaFob,AVSX3("WB_FOBMOE",6)))+CHR(13)+CHR(10)+;  // "Parcelas de cambio : " ###
                         STR0209+ALLTRIM(TRANS( ABS(aTotalInv[P,2]-nSomaFob),AVSX3("WB_FOBMOE",6)))//+CHR(13)+CHR(10)+;  // "Total da Diferença : " ###
                         //STR0210// "Confirma as alterações?" , "Diferença"
                IF AvFlags("EIC_EAI") .AND. M->WA_PO_DI == "D"
                   MSGSTOP(cInfo, STR0202)
                   lRet := .F.
                ELSE
                   lRet := MsgYesNo(cInfo + Chr(13) + Chr(10) + STR0210, STR0202)  // "Confirma as alterações?" , "Diferença"
                ENDIF
                lInvDifere := .T.
             ElseIf lWB_TP_CON .and. lGeraCom .and. aTotalInv[P,3] <> nComissao
                cInfo := STR0220+Alltrim(aTotalInv[P,1])+STR0219+aTotalInv[P,4]+CHR(13)+CHR(10)+;  // "Dif. de comissão em " ### " na moeda " ###
                         STR0214+ALLTRIM(TRANS(aTotalInv[P,3],AVSX3("WB_FOBMOE",6)))+CHR(13)+CHR(10)+;  // "Total de comissao  : " ###
                         STR0215+ALLTRIM(TRANS(nComissao,AVSX3("WB_FOBMOE",6)))+CHR(13)+CHR(10)+;  // "Parcelas de com.   : " ###
                         STR0209+ALLTRIM(TRANS( ABS(aTotalInv[P,3]-nComissao),AVSX3("WB_FOBMOE",6)))//+CHR(13)+CHR(10)+;  // "Total da Diferença : " ###
                         //STR0210  // "Confirma as alterações?" , "Diferença"
                IF AvFlags("EIC_EAI") .AND. M->WA_PO_DI == "D"
                   MSGSTOP(cInfo, STR0202)
                   lRet := .F.
                ELSE
                   lRet := MsgYesNo(cInfo + Chr(13) + Chr(10) + STR0210, STR0202)  // "Confirma as alterações?" , "Diferença"
                ENDIF

             ENDIF
         Next P
      EndIf

      If lWB_TP_CON
         SW6->(DBSEEK(xFilial()+M->WA_HAWB))
         If lRet .AND. lGeraFrete .And. nFrete <> 0
            If SW6->W6_VLFRECC <> nFrete
               cInfo := STR0221+CHR(13)+CHR(10)+;  // "Dif. de Frete encontrada "
                        STR0222+ALLTRIM(TRANS(SW6->W6_VLFRECC,AVSX3("W6_VLFRECC",6)))+CHR(13)+CHR(10)+;  // "Total de Frete     : " ###
                        STR0223+ALLTRIM(TRANS(nFrete,AVSX3("W6_VLFRECC",6)))+CHR(13)+CHR(10)+;  // "Parcelas de frete  : " ###
                        STR0209+ALLTRIM(TRANS( ABS(SW6->W6_VLFRECC-nFrete),AVSX3("W6_VLFRECC",6)))//+CHR(13)+CHR(10)+;  // "Total da Diferença : " ###
                        //STR0210  // "Confirma as alterações?" , "Diferença"
             IF AvFlags("EIC_EAI") .AND. M->WA_PO_DI == "D"
                MSGSTOP(cInfo, STR0202)
                lRet := .F.
             ELSE
                lRet := MsgYesNo(cInfo + Chr(13) + Chr(10) + STR0210, STR0202)  // "Confirma as alterações?" , "Diferença"
             ENDIF

            EndIf
         EndIf
         //If lRet .AND. lGeraSeg //comentado por wfs 22/06/2017
         If lRet .AND. lGeraSeg .And. lGravaFin_EIC .And. nSeguro <> 0 ///wfs 22/06/2017- mesmo quando integrado com o SIGAFIN, o parâmetro MV_FIN_EIC é considerado (vide avflags GERACAO_CAMBIO_SEGURO)
            If SW6->W6_VL_USSE <> nSeguro
               cInfo := STR0224+CHR(13)+CHR(10)+;  // "Dif. de seguro encontrada "
                        STR0225+ALLTRIM(TRANS(SW6->W6_VL_USSE,AVSX3("WB_PGTANT",6)))+CHR(13)+CHR(10)+;  // "Total de seguro    : " ###
                        STR0226+ALLTRIM(TRANS(nSeguro,AVSX3("WB_FOBMOE",6)))+CHR(13)+CHR(10)+;  // "Parcelas de seguro : "
                        STR0209+ALLTRIM(TRANS( ABS(SW6->W6_VL_USSE-nSeguro),AVSX3("WB_FOBMOE",6)))//+CHR(13)+CHR(10)+;  // "Total da Diferença : " ###
                        //STR0210// "Confirma as alterações?" , "Diferença"
             IF AvFlags("EIC_EAI") .AND. M->WA_PO_DI == "D"
                MSGSTOP(cInfo, STR0202)
                lRet := .F.
             ELSE
                lRet := MsgYesNo(cInfo + Chr(13) + Chr(10) + STR0210, STR0202)  // "Confirma as alterações?" , "Diferença"
             ENDIF

            EndIf
         EndIf
         //**
      EndIf
   Else
      nTotal   := 0
      nFobMoe  := 0
      nPgtAnt  := 0
      nPgAntDI := 0
      aToPOs   := {}
      aTotal   := {}
      aTotalInv:= {}
      aFobMoe  := {}
      aFobInv  := {}
      aPgtAnt  := {}
      nFrete   := 0
      nSeguro  := 0
      aComissao:= {}
      aComInv  := {}
      nComissao:= 0
      IF LEFT(M->WA_PO_DI,1) == 'D'  // total do processo
         SW9->(dbSetOrder(3))
         SW9->(dbSeek(xFilial()+M->WA_HAWB))
         DO WHILE !SW9->(Eof()) .AND. SW9->W9_Filial == xFilial("SW9") ;
                                .AND. SW9->W9_Hawb   == M->WA_HAWB

            SY6->(DBSETORDER(1))
            IF SY6->(DBSEEK(xFilial("SY6")+SW9->W9_COND_PA+STR(SW9->W9_DIAS_PA,3) )) .AND. ;
            SY6->Y6_TIPOCOB <> "4" // EOS - Somente se tiver cob. cambial
               Valor_Inv:= DI500RetVal("TOT_INV", "TAB", .T.) // EOB - 14/07/08 - chamada da função DI500RetVal

               nPos := ASCAN( aTotal, { |X| X[1] == SW9->W9_MOE_FOB } )
               IF nPos == 0
                  AADD( aTotal, { SW9->W9_MOE_FOB, Valor_Inv, If(lWB_TP_CON .and. lGeraCom,SW9->W9_VALCOM,0) } )
               ELSE
                  aTotal[nPos,2] += Valor_Inv
                  aTotal[nPos,3] += If(lWB_TP_CON .and. lGeraCom,SW9->W9_VALCOM,0)
               ENDIF
               //** GFC - 21/11/05 - Câmbio de frete, seguro, comissão e embarque
               nPos := ASCAN( aTotalInv, { |X| X[1] == SW9->W9_INVOICE } )
               IF nPos == 0
                  AADD( aTotalInv, { SW9->W9_INVOICE, Valor_Inv, If(lWB_TP_CON .and. lGeraCom,SW9->W9_VALCOM,0), SW9->W9_MOE_FOB } )
               ELSE
                  aTotalInv[nPos,2] += Valor_Inv
                  aTotalInv[nPos,3] += If(lWB_TP_CON .and. lGeraCom,SW9->W9_VALCOM,0)
               ENDIF
               //**
               nTotal += Valor_Inv
            ENDIF
            SW9->(dbSkip())
         ENDDO
         SW9->(dbSetOrder(1))
      ENDIF
      lSemInv := " "
      TRB->(DBGOTOP())
      DO WHILE TRB->(!EOF())
         IF Left(TRB->WB_TIPOREG,1) == "1" .AND. TRB->WB_PO_DI == "D"
            nPos := ASCAN( aFobMoe, { |X| X[1] == TRB->WB_MOEDA } )
            IF nPos == 0
               AADD( aFobMoe, { TRB->WB_MOEDA, TRB->WB_FOBMOE  } )
            ELSE
               aFobMoe[nPos,2] += TRB->WB_FOBMOE
            ENDIF
            nFobMoe+=TRB->WB_FOBMOE
            //** GFC - 22/11/05 - Câmbio de frete, seguro, comissão e embarque
            nPos := ASCAN( aFobInv, { |X| X[1] == TRB->WB_INVOICE } )
            IF nPos == 0
               AADD( aFobInv, { TRB->WB_INVOICE, TRB->WB_FOBMOE + TRB->WB_PGTANT /*If(TRB->WB_FOBMOE<>0, TRB->WB_FOBMOE, TRB->WB_PGTANT)*/  } )
            ELSE
               aFobInv[nPos,2] += TRB->WB_FOBMOE + TRB->WB_PGTANT //If(TRB->WB_FOBMOE<>0, TRB->WB_FOBMOE, TRB->WB_PGTANT)
            ENDIF
            //**
            nParcel++
         //** GFC - 22/11/05 - Câmbio de frete, seguro, comissão e embarque
         ElseIf Left(TRB->WB_TIPOREG,1) == "A"  // Frete
            nFrete  += TRB->WB_FOBMOE
         ElseIf Left(TRB->WB_TIPOREG,1) == "B"  // Seguro
            nSeguro += TRB->WB_FOBMOE
         ElseIf Left(TRB->WB_TIPOREG,1) == "C"  // Comissão
            nPos := ASCAN( aComissao, { |X| X[1] == TRB->WB_MOEDA } )
            IF nPos == 0
               AADD( aComissao, { TRB->WB_MOEDA, TRB->WB_FOBMOE  } )
            ELSE
               aComissao[nPos,2] += TRB->WB_FOBMOE
            ENDIF

            nPos := ASCAN( aComInv, { |X| X[1] == TRB->WB_INVOICE } )
            IF nPos == 0
               AADD( aComInv, { TRB->WB_INVOICE, TRB->WB_FOBMOE  } )
            ELSE
               aComInv[nPos,2] += TRB->WB_FOBMOE
            ENDIF
         //**
         ENDIF
         TRB->(DBSKIP())
      ENDDO

      FOR P := 1 TO LEN(aTotal)
          nSomaFob  := 0
          nFob      := ASCAN( aFobMoe  , { |Y| Y[1] == aTotal[P,1] } )
          IF nFob > 0
             nSomaFob := aFobMoe[nFob,2]
          ENDIF

          //** GFC - 22/11/05 - Câmbio de frete, seguro, comissão e embarque
          If lWB_TP_CON
             nCom := ASCAN( aComissao, { |Y| Y[1] == aTotal[P,1] } )
             IF nCom > 0
                nComissao := aComissao[nCom,2]
             ENDIF
          EndIf
          //**

          //IF !(aTotal[P,2]  nSomaFob)
            IF !(Abs((aTotal[P,2] - nSomaFob)) <= 0.01*aTotal[P,2])
             // EOS - qdo nao tem adiantamentos e o total das parcelas de cambio nao bate
             // com o total do processo, perguntar se valores estao corretos...
             cInfo := STR0206+aTotal[P,1]+CHR(13)+CHR(10)+;  // "Diferença encontrada em " ###
                      STR0207+ALLTRIM(TRANS(aTotal[P,2],AVSX3("WB_PGTANT",6)))+CHR(13)+CHR(10)+;  // "Total do processo  : " ###
                      STR0208+ALLTRIM(TRANS(nSomaFob,AVSX3("WB_FOBMOE",6)))+CHR(13)+CHR(10)+;  // "Parcelas de cambio : " ###
                      STR0209+ALLTRIM(TRANS( ABS(aTotal[P,2]-nSomaFob),AVSX3("WB_FOBMOE",6)))//+CHR(13)+CHR(10)+;  // "Total da Diferença : " ###
                      //STR0210 // "Confirma as alterações?" , "Diferença"
             IF AvFlags("EIC_EAI")
                If M->WA_PO_DI == "D"
                   MSGSTOP(cInfo, STR0202)
                   lRet := .F.
                EndIf
             ELSE
                lRet := MsgYesNo(cInfo + Chr(13) + Chr(10) + STR0210, STR0202)  // "Confirma as alterações?" , "Diferença"
             ENDIF

          //** GFC - 22/11/05 - Câmbio de frete, seguro, comissão e embarque
          ElseIf lWB_TP_CON .and. lGeraCom .and. nComissao <> 0 .And. aTotal[P,3] <> nComissao
             cInfo := STR0213+aTotal[P,1]+CHR(13)+CHR(10)+;  // "Dif. de comissão encontrada em " ###
                      STR0214+ALLTRIM(TRANS(aTotal[P,3],AVSX3("WB_PGTANT",6)))+CHR(13)+CHR(10)+;  // "Total de comissao  : " ###
                      STR0215+ALLTRIM(TRANS(nComissao,AVSX3("WB_FOBMOE",6)))+CHR(13)+CHR(10)+;  // "Parcelas de com.   : " ###
                      STR0209+ALLTRIM(TRANS( ABS(aTotal[P,3]-nComissao),AVSX3("WB_FOBMOE",6)))//+CHR(13)+CHR(10)+;  // "Total da Diferença : " ###
                      //STR0210 // "Confirma as alterações?" , "Diferença"

             IF AvFlags("EIC_EAI") .AND. M->WA_PO_DI == "D"
                MSGSTOP(cInfo, STR0202)
                lRet := .F.
             ELSE
                lRet := MsgYesNo(cInfo + Chr(13) + Chr(10) + STR0210, STR0202)  // "Confirma as alterações?" , "Diferença"
             ENDIF


          //**
          ENDIF
      NEXT

      //** GFC - 22/11/05 - Câmbio de frete, seguro, comissão e embarque
      If lRet
         FOR P := 1 TO LEN(aTotalInv)
             nSomaFob  := 0
             nFob      := ASCAN( aFobInv  , { |Y| Y[1] == aTotalInv[P,1] } )
             IF nFob > 0
                nSomaFob := aFobInv[nFob,2]
             ENDIF

             If lWB_TP_CON
                nCom := ASCAN( aComInv, { |Y| Y[1] == aTotalInv[P,1] } )
                IF nCom > 0
                   nComissao := aComInv[nCom,2]
                ENDIF
             EndIf

             IF !(aTotalInv[P,2] = nSomaFob)
                cInfo := STR0218+Alltrim(aTotalInv[P,1])+STR0219+aTotalInv[P,4]+CHR(13)+CHR(10)+;  // "Diferença em " ### " na moeda " ###
                         STR0207+ALLTRIM(TRANS(aTotalInv[P,2],AVSX3("WB_FOBMOE",6)))+CHR(13)+CHR(10)+;  // "Total do processo  : " ###
                         STR0208+ALLTRIM(TRANS(nSomaFob,AVSX3("WB_FOBMOE",6)))+CHR(13)+CHR(10)+;  // "Parcelas de cambio : " ###
                         STR0209+ALLTRIM(TRANS( ABS(aTotalInv[P,2]-nSomaFob),AVSX3("WB_FOBMOE",6)))//+CHR(13)+CHR(10)+;  // "Total da Diferença : " ###
                         //STR0210  // "Confirma as alterações?" , "Diferença"
               IF AvFlags("EIC_EAI") .AND. M->WA_PO_DI == "D"
                  MSGSTOP(cInfo, STR0202)
                  lRet := .F.
               ELSE
                  lRet := MsgYesNo(cInfo + Chr(13) + Chr(10) + STR0210, STR0202)  // "Confirma as alterações?" , "Diferença"
               ENDIF

             ElseIf lWB_TP_CON .and. lGeraCom .and. nComissao <> 0 .And. aTotalInv[P,3] <> nComissao
                cInfo := STR0220+Alltrim(aTotalInv[P,1])+STR0219+aTotalInv[P,4]+CHR(13)+CHR(10)+;  // "Dif. de comissão em " ### " na moeda " ###
                         STR0214+ALLTRIM(TRANS(aTotalInv[P,3],AVSX3("WB_FOBMOE",6)))+CHR(13)+CHR(10)+;  // "Total de comissao  : " ###
                         STR0215+ALLTRIM(TRANS(nComissao,AVSX3("WB_FOBMOE",6)))+CHR(13)+CHR(10)+;  // "Parcelas de com.   : "
                         STR0209+ALLTRIM(TRANS( ABS(aTotalInv[P,3]-nComissao),AVSX3("WB_FOBMOE",6)))//+CHR(13)+CHR(10)+;  // "Total da Diferença : " ###
                         //STR0210  // "Confirma as alterações?" , "Diferença"
               IF AvFlags("EIC_EAI") .AND. M->WA_PO_DI == "D"
                  MSGSTOP(cInfo, STR0202)
                  lRet := .F.
               ELSE
                  lRet := MsgYesNo(cInfo + Chr(13) + Chr(10) + STR0210, STR0202)  // "Confirma as alterações?" , "Diferença"
               ENDIF

             ENDIF
         Next P
      EndIf

      If lWB_TP_CON
         SW6->(DBSEEK(xFilial()+M->WA_HAWB))
         If lRet .and. lGeraFrete .And. lGravaFin_EIC .And. nFrete <> 0 //WFS - 19/01/12
            If SW6->W6_VLFRECC <> nFrete
               cInfo := STR0221+CHR(13)+CHR(10)+;  // "Dif. de Frete encontrada "
                        STR0222+ALLTRIM(TRANS(SW6->W6_VLFRECC,AVSX3("W6_VLFRECC",6)))+CHR(13)+CHR(10)+;  // "Total de Frete     : " ###
                        STR0223+ALLTRIM(TRANS(nFrete,AVSX3("W6_VLFRECC",6)))+CHR(13)+CHR(10)+;  // "Parcelas de frete  : "
                        STR0209+ALLTRIM(TRANS( ABS(SW6->W6_VLFRECC-nFrete),AVSX3("W6_VLFRECC",6)))//+CHR(13)+CHR(10)+;  // "Total da Diferença : " ###
                        //STR0210
               IF AvFlags("EIC_EAI") .AND. M->WA_PO_DI == "D"
                  MSGSTOP(cInfo, STR0202)
                  lRet := .F.
               ELSE
                  lRet := MsgYesNo(cInfo + Chr(13) + Chr(10) + STR0210, STR0202)  // "Confirma as alterações?" , "Diferença"
               ENDIF
            EndIf
         EndIf
         If lRet .and. lGeraSeg .And. lGravaFin_EIC .And. nSeguro <> 0 //WFS - 19/01/12
            If SW6->W6_VL_USSE <> nSeguro
               cInfo := STR0224+CHR(13)+CHR(10)+;  // "Dif. de seguro encontrada "
                        STR0225+ALLTRIM(TRANS(SW6->W6_VL_USSE,AVSX3("WB_PGTANT",6)))+CHR(13)+CHR(10)+;  // "Total de seguro    : " ###
                        STR0226+ALLTRIM(TRANS(nSeguro,AVSX3("WB_FOBMOE",6)))+CHR(13)+CHR(10)+;  // "Parcelas de seguro : " ###
                        STR0209+ALLTRIM(TRANS( ABS(SW6->W6_VL_USSE-nSeguro),AVSX3("WB_FOBMOE",6)))//+CHR(13)+CHR(10)+;  // "Total da Diferença : " ###
                        //STR0210
               IF AvFlags("EIC_EAI") .AND. M->WA_PO_DI == "D"
                  MSGSTOP(cInfo, STR0202)
                  lRet := .F.
               ELSE
                  lRet := MsgYesNo(cInfo + Chr(13) + Chr(10) + STR0210, STR0202)  // "Confirma as alterações?" , "Diferença"
               ENDIF
            EndIf
         EndIf
      EndIf
      //**
   EndIf
ENDIF

If !Empty(lRet) .and. lRet <> Nil
   lRetVal := lRet
EndIf

lRetVal := lRet //CCH - 01/06/09

If(EasyEntryPoint("EICAP100"),ExecBlock("EICAP100",.F.,.F.,"VALIDA_TELA_CAMBIO"),) //CCH - 01/06/09 - Inclusão de ponto de entrada conforme solicitado por João Pedro.
                                                                               //Utilização para execução de transações SAP antes das gravações das parcelas
lRet := lRetVal  //CCH - 01/06/09


TRB->(DBGOTOP())

Return( lRet )

*---------------------*
Function APESWBLinOk(nTipo)
*---------------------*
Local lRet := .T., MLimBac:=M->WB_LIM_BAC, nInd
Private aValidaWB :={ {"WB_DT"     , "DT"      },;
                      {"WB_CA_DT"  , "CADT"    },;
                      {"WB_DT_CONT", "DTCONT"  },;
                      {"WB_DT_VEN" , "VENCTO"  },;
                      {"WB_LC_NUM" , "LC"      },;
                      {"WB_AGENCIA", "AGE"     },;
                      {"WB_CA_NUM" , "CAMBIO"  },;
                      {"WB_CA_TX"  , "TAXA"    },;
                      {"WB_FOBMOE" , "FOB"     },;
                      {"WB_DT_ROF" , "DTROF"   },;
                      {"WB_LIM_BAC", "DTLIMBAC"},;
                      {"WB_BANCO"  , "BCO"     },;
                      {"WB_TP_CON" , "TP_CON"  }}
Private lVldSwb := .T.
Private nTipoOp := nTipo

If TRB->(FIELDPOS("WB_CONTA")) # 0
	Aadd(aValidaWB,{"WB_CONTA", "CONTA" })
EndIf

// GCC - 24/10/2013 - Validação do valor da parcela e código do fornecedor quando tratar de pagamento antecipado por fornecedor ou por crédito.
If M->WB_PO_DI $ "CF"
	Aadd(aValidaWB,{"WB_CONTA", "PGTANT" })
	Aadd(aValidaWB,{"WB_FORN" , "FORNECE"})
	Aadd(aValidaWB,{"WB_LOJA" , "LOJA"   })
EndIf

M->WB_LIM_BAC := MLimBac

If EasyEntryPoint("EICAP100")
   ExecBlock("EICAP100",.F.,.F.,"VALIDA_SWB")
EndIf

If !lVldSwb
   Return .F.
EndIf

If nTipo <> 6
   For nInd:=1 To Len(aValidaWB)
       If ! APE100Crit(aValidaWB[nInd,2],aValidaWB[nInd,1],PAlteracao)
          lRet:=.F.
          Exit
       EndIf
   Next
EndIf

/* *** RMD - 21/12/16 - Validação das taxas cadastradas quando utilizada a baixa de câmbio com banco em uma moeda estrangeira
                        diferente da moeda da parcela.
                        Isso porque o financeiro depende das taxas cadastradas para ambas as moedas (parcela e banco) na data da baixa
                        para efetuar os calculos corretos.
*/
If EasyGParam("MV_EASYFIN",,"N") == "S" .AND. FindFunction("Af200ChkMd") .And. !Empty(M->WB_CA_DT) .And. (nTipo == 3 .Or. Empty(TRB->WB_CA_DT))
	If !Empty(Posicione("SA6", 1, xFilial("SA6")+M->(WB_BANCO+WB_AGENCIA+WB_CONTA), "A6_MOEEASY")) .AND. SimbToMoeda(SA6->A6_MOEEASY) > 1
		lRet := Af200ChkMd(M->WB_MOEDA, M->WB_CA_DT) .And.;
				Af200ChkMd(Posicione("SA6", 1, xFilial("SA6")+M->(WB_BANCO+WB_AGENCIA+WB_CONTA), "A6_MOEEASY"), M->WB_CA_DT)
	EndIf
EndIf

Return( lRet )

/**
 * EJA - 25/10/2018
 * Elimina saldo ou estorna a eliminação de acordo com a mudança no valor do saldo eliminado.
 */
Static Function elimOuEstor()

    Local lRet := .T.

    If TRB->WB_SLDELI > SWB->WB_SLDELI //Eliminação de saldo
        Return eliminarOp(3)
    ElseIf TRB->WB_SLDELI < SWB->WB_SLDELI //Estorno de eliminação de saldo
        Return eliminarOp(5)
    EndIf
Return lRet

Static Function eliminarOp(nOpc)
    
    Local lRet := .T., nPosMotBx
    Private aTitBx  := {}
    Private lMsErroAuto := .F.

    Aadd(aTitBx, {"E2_PREFIXO", TRB->WB_PREFIXO, NIL})
    Aadd(aTitBx, {"E2_NUM",     TRB->WB_NUMDUP,  NIL})
    Aadd(aTitBx, {"E2_PARCELA", TRB->WB_PARCELA, NIL})
    Aadd(aTitBx, {"E2_TIPO",    TRB->WB_TIPOTIT, NIL})
    Aadd(aTitBx, {"E2_FORNECE", TRB->WB_FORN,    NIL})
    Aadd(aTitBx, {"E2_LOJA",    TRB->WB_LOJA,    NIL})

    If (nOpc == 3)
        Aadd(aTitBx, {"AUTMOTBX",   "DAC",            NIL})
        Aadd(aTitBx, {"AUTDTBAIXA", dDataBase,        NIL})
        Aadd(aTitBx, {"AUTHIST",    "Baixa",          NIL})
        Aadd(aTitBx, {"AUTVLRME",   TRB->WB_SLDELI,   NIL})
      If(EasyEntryPoint("EICAP100"),ExecBlock("EICAP100",.F.,.F.,"ELIMINAR_SALDO_MOTBX"),)
    EndIf

    //NCF - 09/05/2020 - Não envia o valor quando o motivo de baixa não movimenta banco.
    If ( nPosMotBx := aSCan(aTitBx,{|x|x[1]=="AUTMOTBX"} ) ) > 0 .And.  !MovBcoBx(substr(aTitBx[nPosMotBx][2],1,3))                                       
       aDel(  aTitBx, aScan(aTitBx,{|x|x[1] == "AUTVLRME"}) )
       aSize( aTitBx, Len(aTitBx) - 1 )
    EndIf

    MsExecAuto({|x, y| FINA080(x, y)}, aTitBx, nOpc) // nOpc = 3 para inclusão do título; nOpc = 5 para cancelamento de título
 
    If lMsErroAuto
        MostraErro()
        lRet := .F.
    EndIf

Return lRet

*------------------------------------------*
Static Function APE100Grava(cAlias,cAlias1)
*------------------------------------------*
Local bCampo, _DelIncAlt:= SPACE(01), _MindDi
Local xVar, BVar:={||.t.}, nTamanho:=TAMSX3("WB_VM_OBS")[1],xControle
Local aNaoGrava :={}, nInd , aOrdCmb
Local nI, nY, i, nPos //LRL 23/01/04
Local lAltAux := .F. //** GFC - 07/12/05
Local aTaxaLiq := {}, lLiquida := .F.  // PLB - 07/04/06
Local lAntAux:=.T., cAntAux:=""        // TLM - 13/06/08
Local cProcesso, cLinha, cInvoice
// ** JPM 10/12/2009 - Nova Leg. Cambial
Local lIncluiMov, lExcluiMov
Local lCredito :=  .F. // GFP - 30/04/2014
Local aOrd := {}  // GFP - 06/05/2014
Local aChaves
Local aAltParc :={} //igor chiba 13/08/14 array com parcelas que sofreram alteracoes
Private lTitSWB := lTitCrd := .F. //LGS-11/09/2014
Private lAux //Boolean genérica para utilização em rdmakes.
Private nNewRecSWB := 0  // PLB 25/10/06
Private cCondTipo := "" //NCF - 07/04/2010
Private lMoviFin := .T. //LRS - 06/10/2016
Private lReturn := .T.

BEGIN SEQUENCE

If AvFlags("WORKFLOW")
   aChaves := EasyGroupWF("CAMBIO_EIC")
EndIf

ProcRegua(TRB->(Easyreccount("TRB"))+LEN(aDeletados)+1)

bCampo := {|nCPO| Field(nCPO) }

dbSelectArea(cAlias)
/*
IF PAlteracao
   DBGOTO(nRecno)
ENDIF
*/
//LRS - 06/10/2016 - Ponto de entrada para liberar movimentação anterior a data MV_DATAFIN
If(EasyEntryPoint("EICAP100"),ExecBlock("EICAP100",.F.,.F.,"MOVI_LIMITE_FIN"),)

IF lMoviFin .And. EasyGParam("MV_EASYFIN",,"N") == "S" .And. !AVDTFINVAL() //   //If EasyGParam("MV_DATAFIN") > DDATABASE OSSME-6483 MFR 11/01/2022
   //MsgInfo(STR0264+; //STR0264 "Não são permitidas movimentações financeiras com datas menores que a data"
   //STR0265+ ENTER + STR0266, STR0041)  //STR0265 "limite de movimentações no Financeiro." //STR0266 "Solução: Verificar parametro MV_DATAFIN" //STR0041  "Informação"
   //Mensagem já é exibida na funcao que está dentro da avdtfinval
   Return .F.
EndIf



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava arquivo SWA ( APE )                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(M->WA_CTRL)
   If !Empty( xControle := EasyGParam("MV_CTRL_WA") ) .And. VAL(LEFT(xControle,AvSX3("WA_CTRL",AV_TAMANHO)-2)) > 1
      xControle:=VAL(LEFT(xControle,4))+1
      xControle:=PADL(xControle,AvSX3("WA_CTRL",AV_TAMANHO)-2,"0")+RIGHT(STR(YEAR(dDataBase),4,0),2)
      M->WA_CTRL:=xControle
      PutMV("MV_CTRL_WA",xControle)
   Else
      M->WA_CTRL:=EasyGetMVSeq("MV_CTRL_WA")
   EndIf
EndIf

IncProc()

If EMPTY(ALLTRIM(M->WA_CEDENTE))
   IF M->WA_CODCEDE == '1'
      M->WA_CEDENTE:= M->WA_FB_NOME
   ELSE
      M->WA_CEDENTE:= M->WA_BC_NOME
   ENDIF
EndIf

// GFP - 07/11/2014 - Atualiza campo WA_PGTANT
If M->WA_PO_DI == "A"
   M->WA_PGTANT := 0
   nRecno := TRB->(Recno())
   TRB->(DbGoTop())
   Do While TRB->(!Eof())
      M->WA_PGTANT += TRB->WB_PGTANT
      TRB->(DbSkip())
   EndDo
   TRB->(DbGoTo(nRecno))
EndIf

SWA->(DBSetOrder(1)) //WA_FILIAL+WA_HAWB+WA_PO_DI
SWA->(DBSeek(xFilial() + M->WA_HAWB + M->WA_PO_DI))

dbSelectArea(cAlias)
E_Grava(cAlias,!PAlteracao)
nRecTRBDa := SWA->(RECNO())
//LGS-02/05/2014 - Quando usar a função de eliminar saldo deve atualizar o saldo tambem na SE2 mantendo assim a integridade dos dados.
/*
If @lElimSaldo .And.;
   SE2->(DBSEEK(xFilial()+TRB->WB_PREFIXO+TRB->WB_NUMDUP+TRB->WB_PARCELA+TRB->WB_TIPOTIT+TRB->WB_FORN+TRB->WB_LOJA))
   SE2->(RecLock("SE2",.F.))
   SE2->E2_SALDO := SWA->WA_SLDANT
   SE2->(MsUnlock())
EndIf
*/

IF PAlteracao
   MSMM(SWA->WA_OBS,,,,2)
//   IF lCposAntecip .AND. SWA->WA_PO_DI == "A" // RJB 05/10/2005 ESTAVA EXCLUINDO DO SYS OS TIPO "P" INDEVIDAMENTE
   IF lCposAntecip .AND. (SWA->WA_PO_DI == "A" .Or. SWA->WA_PO_DI == "F" .Or. SWA->WA_PO_DI == "C" ) // GCC - 23/08/2013
      AP100ArqSYS(.F.)
   ENDIF
ENDIF
//If lCposAntecip .AND. SWA->WA_PO_DI == "A"
IF lCposAntecip .AND. (SWA->WA_PO_DI == "A" .Or. SWA->WA_PO_DI == "F" .Or. SWA->WA_PO_DI == "C") // GCC - 23/08/2013
   AP100ArqSYS(.T.) //Funcao para gravar no arquivo SYS o valores % por centro de custo
Endif

If !PAlteracao
   If !Empty(M->WA_VM_OBS)
      MSMM(,TAMSX3("WA_VM_OBS")[1],,M->WA_VM_OBS,1,,,"SWA","WA_OBS")
   EndIf
Else
   If Empty(SWA->WA_OBS)
      MSMM(,TAMSX3("WA_VM_OBS")[1],,M->WA_VM_OBS,1,,,"SWA","WA_OBS")
   Else
      MSMM(SWA->WA_OBS,TAMSX3("WA_VM_OBS")[1],,M->WA_VM_OBS,1,,,"SWA","WA_OBS")
   EndIf
EndIf

dbSelectArea("TRB")

aParcAdi := {}
FOR nI=1 to LEN(aDeletados)
    IncProc()
	SWB->(DBGOTO(aDeletados[nI]))

	SWB->(DbSeek(xFilial()+SWB->WB_NUMPO))

	/*If SWB->WB_PO_DI == "C"
		SWB->(DBGOTO(aDeletados[nI]))
		AP100CrBX(6)
	Else*/
		SWB->(DBGOTO(aDeletados[nI]))
		EICFI400("EXCLUI_TITULO")
	//EndIf

    RecLock("SWB",.F.)
    cLinha := SWB->WB_LINHA
    cProcesso := SWB->WB_HAWB
    cInvoice := SWB->WB_INVOICE
    If EasyEntryPoint("ICPAP001")
       ExecBlock("ICPAP001",.F.,.F.,"EXCLUINDO ITENS")
    EndIf
    If EasyEntryPoint("EICAP100")
       ExecBlock("EICAP100",.F.,.F.,"EXCLUINDO ITENS")
    EndIf
    //** TLM 13/06/2008 - Caso tenha dois ou mais PO's com pagamento antecipado vinculado a um embarque,
    //                    no seek da SWA abaixo estava desposicionando da parcela do embarque.
    If lAntAux .And. lCposAntecip
       cAntAux:= SWA->WA_HAWB     // Variavel cAntAux guarda a referência do HAWB que está inicialmente posicionado.
       lAntAux:=.f.
    EndIf

    If lCposAntecip                               // Caso o array aDeletados seja maior que um, é necessário posicionar
       SWA->(DBSeek(xFilial("SWA")+cAntAux+"D"))  // novamente no HAWB original, tipo "D", para que o valor da segunda parcela
    Endif                                         // excluída seja incluído no saldo da parcela andiantada, tipo "A", campo SWA->WA_SLDANT.
    //**
    MSMM(SWB->WB_OBS,,,,2)
    
    If lCposAntecip .AND. SWA->WA_PO_DI == "D" .AND.;
       Left(SWB->WB_TIPOREG,1) == "P" .AND. !Empty(SWB->WB_NUMPO)
        AtuSldSWA("ESTCOMP") //NCF - 05/06/2020
        // EOB - 03/2009 - Array com as parcelas deletadas a fim de verificar na função BuscaPA (EICFI400) se o adiantamento estava sendo utilizado nas parcelas
        AADD( aParcAdi, { SWB->WB_FORN, SWB->WB_MOEDA, SWB->WB_NUMPO, SWB->WB_LINHA, SWB->WB_CA_NUM, IF(EICLOJA(),SWB->WB_LOJA,"") } )
    Endif
    //RMD - Nova legislação de câmbio
    //EOB - 31/07/09 - Troca de EECFlags p/ AvFlags (Avgeral)
    If AvFlags("CAMBIO_EXT")
       AD101GrvInv("SWB", "TRB", "IMP", .T.,,@lIncluiMov,@lExcluiMov)
    EndIf

    SWB->(DBDELETE())
    SWB->(MSUNLOCK())
NEXT
If AvFlags("EIC_EAI")
   aDeletados:= {}
EndIf
SWA->(DBGOTO(nRecTRBDa))

nLinhaTRB:= SWA->WA_LINHA
nFOBMOE  := 0

aNaoGrava := {"WB_NUMDUP","WB_PARCELA","WB_EAS"}
IF SWB->(FIELDPOS("WB_PREFIXO")) # 0 .AND. SWB->(FIELDPOS("WB_TIPOTIT")) # 0 .AND. SWB->(FIELDPOS("WB_LOJA")) # 0
   AADD( aNaoGrava, "WB_PREFIXO" )
   AADD( aNaoGrava, "WB_TIPOTIT" )
   AADD( aNaoGrava, "WB_LOJA"    )
ENDIF
If AvFlags("EAI_PGANT_INV_NF")
   AAdd(aNaoGrava, "WB_TITADI")
EndIf
//** GFC - 31/03/06 - Estorna Vinculação
If lEFFTpMod .and. lEIC_EFF
   Begin TransAction

   For ni:=1 To Len(aExcVinc)
      AtuVincEF3("EXCLUIR",ni)
   Next

   End TransAction
EndIf
//**

IncParcInvo("1") //BHF - 06/04/2009

aNumPOs := {}
TRB->(DBGOTOP())
lTitCrd := If (TRB->WB_PO_DI == "C",.T.,.F.)
aParcComp := {}
DO WHILE ! TRB->(EOF())

	If SWB->(FieldPos("WB_PGTASS")) > 0 //LGS-14/11/2014
	   lTitSWB    := SWB->(DbSeek(xFilial("SWB")+TRB->WB_HAWB+TRB->WB_PO_DI)) .And.;
                    (SWB->WB_PO_DI == "A" .And. !Empty(SWB->WB_DT_DESE) .And. !Empty(SWB->WB_PGTASS))//LGS-11/09/2014
    EndIf
	nNewRecSWB := 0
    lCancBaixa := .F.
    lAltTotal  := .F.
    nOpcEnvia  := 0 // JACOMO LISA - 27/06/2014
    IncProc()
    nFOBMOE  := 0
    SWA->(DBGOTO(nRecTRBDa))
    IF PAlteracao .AND. TRB->WB_RECNO # 0 .And. !lTitSWB //LGS-11/09/2014
       If !elimOuEstor()
            Return .F.
       EndIf
       SWB->(DBGOTO(TRB->WB_RECNO))
       SWB->(RecLock("SWB",.F.))

       // - BHF - 06/04/2009
       IncParcInvo("2")

       IF !EMPTY(SWB->WB_CA_TX) .AND. !EMPTY(SWB->WB_CA_DT) .AND. !EMPTY(SWB->WB_BANCO) .AND. ;
          !EMPTY(SWB->WB_AGENCIA) //.AND. TRB->WB_FOBMOE = SWB->WB_FOBMOE
          IF TRB->WB_CA_TX   # SWB->WB_CA_TX   .OR. TRB->WB_CA_DT   # SWB->WB_CA_DT   .OR.;
             TRB->WB_BANCO   # SWB->WB_BANCO   .OR. TRB->WB_AGENCIA # SWB->WB_AGENCIA .OR.;
             TRB->WB_DT_DESE # SWB->WB_DT_DESE .OR.;
             IF(SWB->(FIELDPOS("WB_CONTA")) # 0,(TRB->WB_CONTA # SWB->WB_CONTA),.F.)

             IF !EICFI400("BAIXA_TITULO","FORCA_CANCELAR")
                TRB->(DBSKIP())
                LOOP
             ENDIF

             SWB->(DBGOTO(TRB->WB_RECNO))
             SWB->(RecLock("SWB",.F.))

          ENDIF
       ENDIF

       //JAP - 28/08/06 - Verifica se é pagamento antecipado.
       /*IF LEFT(SWA->WA_PO_DI,1) == "A" .AND. TRB->WB_PGTANT # SWB->WB_PGTANT
          TRB->TRB_ALT := .T. // AWR - CONTROLE /P O FINANCEIRO DENTRO EICFI400.PRW - 20/06/2006
       ELSEIF TRB->WB_FOBMOE # SWB->WB_FOBMOE
          TRB->TRB_ALT := .T. // AWR - CONTROLE /P O FINANCEIRO DENTRO EICFI400.PRW - 20/06/2006
       ENDIF*/

       /********************************************************************************************/
       /** CCH - 13/07/09 - Bloco acima nopado para organização.                                  **/
       /** Abaixo, reestruturado o tratamento para alteração de títulos provisórios no Financeiro **/
       /** Inserida validação para verificar se a data de vencimento de um título foi alterado    **/
       /********************************************************************************************/

//       IF LEFT(SWA->WA_PO_DI,1) == "A" .AND. TRB->WB_PGTANT # SWB->WB_PGTANT .OR. SWB->WB_DT_VEN <> TRB->WB_DT_VEN
       IF (LEFT(SWA->WA_PO_DI,1) == "A" .Or. LEFT(SWA->WA_PO_DI,1) == "F" .Or. LEFT(SWA->WA_PO_DI,1) == "C") .AND. TRB->WB_PGTANT # SWB->WB_PGTANT .OR. SWB->WB_DT_VEN <> TRB->WB_DT_VEN	// GCC - 23/08/2013
          TRB->TRB_ALT := .T.
       ELSEIF TRB->WB_FOBMOE # SWB->WB_FOBMOE .OR. SWB->WB_DT_VEN <> TRB->WB_DT_VEN
          TRB->TRB_ALT := .T.
       ENDIF

       If lCposAntecip  .and. SWA->WA_PO_DI == "D"
          If Left(SWB->WB_TIPOREG,1) == "P" .AND. !Empty(SWB->WB_NUMPO)
             IF TRB->WB_PGTANT # SWB->WB_PGTANT
                nFOBMOE := TRB->WB_PGTANT - SWB->WB_PGTANT
             EndIf
          EndIf
       EndIf

       lAltTotal := TRB->(WB_FOBMOE + WB_PGTANT) <> SWB->(WB_FOBMOE + WB_PGTANT)

       //** GFC - 07/12/05
       If lWB_ALTERA .and. (SWB->WB_DT_VEN <> TRB->WB_DT_VEN .or. lAltTotal)//SWB->WB_FOBMOE <> TRB->WB_FOBMOE)
          lAltAux := .T.
          //IGOR CHIBA ENVIAR SE HOUVE ALTERACAO NO FOB OU DATA
          /* Integração EAI
             Armazenamento do RecNo, para somente das parcelas que sofreram alterações */
          nPos:= AScan(aAltParc, {|x| x[1] == SWB->WB_INVOICE + SWB->WB_FORN})
          If nPos == 0
             AAdd(aAltParc, {SWB->WB_INVOICE + SWB->WB_FORN, {SWB->(RecNo())}})
          Else
             AAdd(aAltParc[nPos][2],  SWB->(RecNo()))
          EndIf
       ELSEIF (SWB->WB_DT_VEN <> TRB->WB_DT_VEN .or. lAltTotal) //SWB->WB_FOBMOE <> TRB->WB_FOBMOE)
          //IGOR CHIBA ENVIAR SE HOUVE ALTERACAO NO FOB OU DATA
          /* Integração EAI
             Armazenamento do RecNo, para somente das parcelas que sofreram alterações */
          nPos:= AScan(aAltParc, {|x| x[1] == SWB->WB_INVOICE + SWB->WB_FORN})
          If nPos == 0
             AAdd(aAltParc, {SWB->WB_INVOICE+SWB->WB_FORN, {SWB->(RecNo())}})
          Else
             AAdd(aAltParc[nPos][2], SWB->(RecNo()))
          EndIf
       EndIf
       //**

    ELSE
       IF !lTitSWB //LGS-11/09/2014
          SWB->(RecLock("SWB",.T.))
          SWB->WB_FILIAL:=xFilial("SWB")
          /* Quando a parcela de adiantamento for usada para compensação,
             tratar a gravação do RecNo pois, após a integração da baixa que ocorre
             no momento da associação, o sistema fará a atualização da base de dados.
             Se o RecNo não for gravado, na confirmação da tela câmbio ocorrerá nova
             atualização da base de dados, replicando os registros. */
          If AvFlags("EIC_EAI")
             If TRB->WB_PO_DI == "D" .And. Left(TRB->WB_TIPOREG,1) == "P"
                TRB->WB_RECNO:=SWB->(RecNo())
             EndIf
          EndIf
          nNewRecSWB := SWB->( RecNo() )  // PLB 25/10/06 - Necesssário para gravacao dos dados do contrato da tabela SWB
          TRB->TRB_GERA := .T.
          If LCAMBIO_EIC  // PLB 15/04/10 - Status de Retorno do ERP
             TRB->WB_TITRET := "1"
          EndIf
          If lCposAntecip .AND. SWA->WA_PO_DI == "D" .AND.;
             Left(TRB->WB_TIPOREG,1) == "P" .AND. !Empty(TRB->WB_NUMPO)
             nFOBMOE := TRB->WB_PGTANT
          ENDIF

          IncParcInvo("2") //BHF - 06/04/2009

          //** GFC - 07/12/05
          If lWB_ALTERA
             lAltAux := .T.
          EndIf
          //**

          //lAltTotal := .T.

          //IGOR CHIBA INCLUSAO MANDA TODO MUNDO NAO PRECISA TESTAR NADA
          //IF ASCAN(aAltParc, TRB->WB_INVOICE+TRB->WB_FORN) == 0
          /* Integração EAI
             Armazenamento do RecNo, para somente das parcelas que sofreram alterações,
             refletindo em quebra (nova parcela) e aglutinação. */
          If lAltTotal .Or. TRB->WB_RECNO == 0
             nPos:= AScan(aAltParc, {|x| x[1] == TRB->WB_INVOICE + TRB->WB_FORN})
             If nPos == 0
                AAdd(aAltParc, {TRB->WB_INVOICE + TRB->WB_FORN, {SWB->(RecNo())}})
             Else
                AAdd(aAltParc[nPos][2], SWB->(RecNo()))
             EndIf
          ENDIF
       EndIf
    ENDIF
    //RMD - Nova legislação de câmbio
    //EOB - 31/07/09 - Troca de EECFlags p/ AvFlags (Avgeral)
    If AvFlags("CAMBIO_EXT")
       AD101GrvInv("SWB", "TRB", "IMP",, TRB->WB_RECNO <> 0, @lIncluiMov,@lExcluiMov)//DFS - 12/12/11 - Inclusão das variaveis nos dois ultimos parametros, para que, ao testá-las, o conteúdo não seja NIL.
    EndIf

    If(EasyEntryPoint("EICAP100"),ExecBlock("EICAP100",.F.,.F.,"ANTES_GRAVA_SWB"),)

    //**igor chiba 29/09/09 gravando qual tipo de lançamento
    IF LCAMBIO_EIC
//      IF M->WA_PO_DI == 'A'  //PAGAMENTO ANTECIPADO
      IF (M->WA_PO_DI == 'A' .Or. M->WA_PO_DI == 'F' .Or. M->WA_PO_DI == 'C') //PAGAMENTO ANTECIPADO	// GCC - 23/08/2013
         IF TRB->WB_RECNO <> 0
            IF EMPTY(SWB->WB_CA_DT) .AND. !EMPTY(TRB->WB_CA_DT) //liquidação
               AADD(aLanca,{TRB->WB_INVOICE+TRB->WB_PARCELA,'LQ'})
            ELSEIF EMPTY(TRB->WB_CA_DT) .AND. !EMPTY(SWB->WB_CA_DT)//ESTORNO liquidação
               AADD(aLanca,{TRB->WB_INVOICE+TRB->WB_PARCELA,'EL'})
            ENDIF
         ENDIF
      ELSE  //INVOICE
         IF TRB->WB_RECNO <> 0
            IF EMPTY(SWB->WB_CA_DT) .AND. !EMPTY(TRB->WB_CA_DT) //liquidação
               AADD(aLanca,{TRB->WB_INVOICE+TRB->WB_LINHA,'LQ'})
            ELSEIF EMPTY(TRB->WB_CA_DT) .AND. !EMPTY(SWB->WB_CA_DT)//ESTORNO liquidação
               AADD(aLanca,{TRB->WB_INVOICE+TRB->WB_LINHA,'EL'})
            ELSE //DRL controle sobre alteracao e compensacao - considera o SWB posicionado
               For ni := 1 To Len( TRB->(dbStruct()) )
                   If SWB->(FieldPos(TRB->(FieldName(ni)))) > 0 .And. TRB->(FieldGet(ni)) <> SWB->( FieldGet(FieldPos(TRB->(FieldName(ni)))) )
                      If TRB->WB_PGTANT <> 0
                         AADD(aLanca,{TRB->WB_INVOICE+TRB->WB_LINHA,'CP'}) //DRL
                         EXIT
                      Else
                         AADD(aLanca,{TRB->WB_INVOICE+TRB->WB_LINHA,'AB'}) //DRL
                         EXIT
                      EndIf
                   EndIf
               Next
            ENDIF
         ENDIF
      ENDIF
    ENDIF
    //**

    If SWB->(FieldPos("WB_PGTASS")) > 0 .AND. PAlteracao .AND. TRB->WB_RECNO # 0 .AND. !Empty(SWB->WB_PGTASS)
      nValParc := SWB->WB_PGTANT
		aSWB := SWB->({IndexOrd(),RecNo()})
		aSWA := SWA->({IndexOrd(),RecNo()})
		If SWB->(DbSeek(SWB->WB_PGTASS))
			RecLock("SWB", .F.)
			SWB->WB_SLDTRF -= nValParc
			SWB->(MsUnlock())
  	        If SWA->(dbSeek(xFilial()+SWB->WB_HAWB+SWB->WB_PO_DI))
   			SWA->(RecLock("SWA",.F.))
			   SWA->WA_SLDANT += nValParc
			   SWA->(MsUnLock())
			EndIf
		EndIf
		SWB->(DbSetOrder(aSWB[1]),DbGoTo(aSWB[2]))
		SWA->(DbSetOrder(aSWA[1]),DbGoTo(aSWA[2]))
    EndIf
   //NCF - 02/06/2020
	If TRB->WB_RECNO == 0 .AND. PAlteracao
      nValParc := TRB->WB_PGTANT
      lPosSWB  := .F.
		If !Empty(TRB->WB_PGTASS)
         aOrdCmb  := SaveOrd({"SWA","SWB"})
         If SWB->(DbSeek(xFilial()+TRB->WB_PGTASS))  //Parc.Adto.PO associado à Parc.Cred.Fornecedor (transferência)
			   RecLock("SWB", .F.)
			   SWB->WB_SLDTRF += nValParc
			   SWB->(MsUnlock())
		      If SWA->(dbSeek(xFilial()+SWB->WB_HAWB+SWB->WB_PO_DI)) .AND. SWA->WA_SLDANT >= nValParc
   			   SWA->(RecLock("SWA",.F.))
			      SWA->WA_SLDANT -= nValParc
			      SWA->(MsUnLock())
			   EndIf
         EndIf
         RestOrd(aOrdCmb,.T.)
      EndIf
	EndIf

    If !lTitSWB
    	SWB->(AVREPLACE("TRB","SWB"))// AWR
    EndIf
    //** GFC - 07/12/05
    If lWB_ALTERA .And. !lTitSWB
       If lAltAux
          SWB->WB_ALTERA := "1"
       Else
          SWB->WB_ALTERA := "2"
       EndIf
       lAltAux := .F.
    EndIf
    //**

    SWB->WB_HAWB:=SWA->WA_HAWB
    IF Empty(SWB->WB_DT_DIG)
       SWB->WB_DT_DIG := dDataBase
    ENDIF
    If EMPTY(SWB->WB_LINHA)
       nLinhaTRB := Ap100ApuLinha("SWB", SWB->(WB_HAWB + WB_PO_DI + WB_INVOICE + WB_FORN + WB_LOJA))//JVR - 13/03/10
       //nLinhaTRB += 1
       SWB->WB_LINHA  := PADL(nlinhaTRB,4,"0")
    ENDIF

    IF PAlteracao .AND. TRB->WB_RECNO # 0 .AND. !EMPTY(SWB->WB_OBS)// AWR
       MSMM(SWB->WB_OBS,,,,2)
    ENDIF
    IF !EMPTY(TRB->WB_VM_OBS) .OR. !EMPTY(SWB->WB_OBS)// AWR
       SWB->(MSMM(,nTamanho,,TRB->WB_VM_OBS,1,,,"SWB","WB_OBS"))
    ENDIF

    If EasyEntryPoint("ICPAP001")
       ExecBlock("ICPAP001",.F.,.F.,"GRAVA SWB")
    ENDIF

    If EasyEntryPoint("EICAP100")
       ExecBlock("EICAP100",.F.,.F.,"GRAVA SWB")
    ENDIF

    IF PAlteracao .AND. TRB->WB_RECNO # 0// .And. !lTitSWB
       // EOB - 03/2009 - tratamento para compensação automática no financeiro
       IF lCompAut .AND. lCposAntecip .AND. SWA->WA_PO_DI == "D"  // EOB 11/03/09
          IF Left(SWB->WB_TIPOREG,1) <> "P"
             IF TRB->TRB_ALT
                lExecBaixa := .T.
                // EOB - 03/2009 - se o título estava compensado e sofreu alteração, estorna a compensação
                IF !ValidaSE2("Ver_Comp")
    	            lReturn := EICFI400("COMP_TITULO", "ESTORNO")
    	           lExecBaixa := .F.
                ENDIF
                // EOB - 03/2009 - se utiliza adiantamento, inclui a parcela no array a compensar a fim de estornar
                // todas compensações primeiramente para depois efetuar todas as compensações que foram alteradas
                IF SWB->WB_PGTANT > 0
                   AADD(aParcComp, {SWB->(RECNO()), TRB->(RECNO()) })
                //ELSEIF TRB->WB_PGTANT == 0 //TRP- 21/01/2010 - (Compatibilização com a versão 811) - Não há compensação, somente alteração de valor de parcela...
                ENDIF

                If lExecBaixa .AND. lAltTotal
                   lReturn := EICFI400("BAIXA_TITULO")
                EndIf

                TRB->TRB_ALT := .F.
             ELSEIF !Empty(TRB->WB_CA_DT)
		        lReturn := EICFI400("BAIXA_TITULO")
		     ENDIF
          ENDIF
//       ELSEIF (!lCposAntecip .OR. SWA->WA_PO_DI == "A" .OR. SWB->WB_TIPOREG <> "P") //.And. !Empty(TRB->WB_CA_DT) //NCF - 04/06/2020
       ELSEIF (!lCposAntecip .OR. (SWA->WA_PO_DI == "A" .Or. SWA->WA_PO_DI == "F" .Or. SWA->WA_PO_DI == "C") .OR. Left(SWB->WB_TIPOREG,1) <> "P") // GCC - 23/08/2013
          lReturn := EICFI400("BAIXA_TITULO")// AWR - 19/06/2006 - Essa funcao de Baixa ja verefica os campos necessarios p/ refazer o titulo baixado ou nao
       ENDIF

    ELSE
       //** AAF 29/07/08 - Adicionada condição para não gerar titulos provisórios caso o MV_EASYFPO esteja desligado.
//       If SWA->WA_PO_DI == "A"
       If (SWA->WA_PO_DI == "A" .Or. SWA->WA_PO_DI == "F" .Or. SWA->WA_PO_DI == "C")	// GCC - 23/08/13
          If (!EMPTY(SWB->WB_CA_TX) .AND. !EMPTY(SWB->WB_CA_DT) .AND. !EMPTY(SWB->WB_BANCO) .AND. !EMPTY(SWB->WB_AGENCIA)) .OR.;
          EasyGParam("MV_EASYFCA",,"N") == "S" //CCH - 27/11/08 - Criado parâmetro para controle dos títulos apenas no Câmbio
          //EasyGParam("MV_EASYFPO",,"N") == "S"

             lReturn := EICFI400("INCLUI_TITULO")// AWR - ESTAVA ANTES DA GRAVACAO DO SWB
          EndIf
       ElseIf Left(SWB->WB_TIPOREG,1) <> "P"
          lReturn := EICFI400("INCLUI_TITULO")// AWR - ESTAVA ANTES DA GRAVACAO DO SWB
       EndIf
       //**
    ENDIF

    If EasyGParam("MV_EASYFIN",,"N") == "S" .And. !lReturn  //NCF - 12/03/2019
       Break
    EndIf
    
    //JAP - 25/08/06 - Verifica se é adiantamento e deleta os provisórios.
    //IF lCposAntecip .AND. (LEFT(SWA->WA_PO_DI,1) == "A" .Or. LEFT(SWA->WA_PO_DI,1) == "F" .Or. SWA->WA_PO_DI == "C")	// GCC - 23/08/2013 Propósito da chamada da função FI400ANT_PO é 
    // apenas para exclusão dos títulos provisórios do Purchase Order, não fazendo sentido ser chamada com o Adiantamento ao Fornecedor ou com Crédito
    IF lCposAntecip .AND. LEFT(SWA->WA_PO_DI,1) == "A"
       lBaixada := .F.
       cCondTipo := Iif(!Empty(TRB->WB_CA_TX) .AND. Empty(SWB->WB_CA_TX),"INCLUI","")
       Processa({|| FI400ANT_PO(SWA->WA_HAWB,.T.,@lBaixada,,,cCondTipo)})
    ENDIF
    //** AAF 21/11/05 - Alteração de Demurrage.
    If Left(SWB->WB_TIPOREG,1) == 'D'
       DM100GrvImp()
    Endif
    //**

   if TRB->WB_RECNO <> 0
      SWB->(DBGOTO(TRB->WB_RECNO))
   else
      SWB->(DBGOTO(nNewRecSWB))
   endif

   SWB->(MSUNLOCK())

    If lCposAntecip
       SWA->(DBGOTO(nRecTRBDa))
       IF SWA->WA_PO_DI == "D" .AND. nFOBMOE # 0
            If Left(TRB->WB_TIPOREG,1) == "P" .AND. !Empty(TRB->WB_NUMPO)	// Bete 05/09/05 - pegar do TRB
                // Bete 05/09/05 - array c/ pedidos
                IF !EMPTY(TRB->WB_NUMPO)
                    IF ASCAN(aNumPos,TRB->WB_NUMPO) == 0
                        AADD(aNumPos,TRB->WB_NUMPO)
                    ENDIF
                ENDIF
                Work1->(DbSeek(If(lAdtMultfil,TRB->WB_FILORI,"")+TRB->WB_NUMPO))
                AtuSldSWA("INCCOMP") // NCF - 05/06/2020
            Endif            
       ELSEIF SWA->WA_PO_DI == "A"
          // Bete 06/09/05 - array c/ pedidos
          cNumPO := LEFT(SWA->WA_HAWB, LEN(SW2->W2_PO_NUM))
          IF ASCAN(aNumPos,cNumPO) = 0
	          AADD(aNumPos,cNumPO)
	      ENDIF
       ELSEIF (SWA->WA_PO_DI == "C" .Or. SWA->WA_PO_DI == "F")	// GCC - 27/08/13
          cNumPO := LEFT(SWA->WA_HAWB, LEN(SW2->W2_PO_NUM))
       EndIf
    EndIf

    APE100Calc()

    //** GFC - 31/03/06 - Grava Vinculação
    If lEFFTpMod .and. lEIC_EFF .and. lWB_Event .And. TRB->WB_EVENT == "101"
       If (nPos := aScan(aVincula, {|x| x[9]==TRB->WB_INVOICE .and. x[10]==If(!Empty(TRB->WB_PARFIN),TRB->WB_PARFIN,TRB->WB_LINHA) })) > 0 .and.;
       (aVincula[nPos,4] = NIL .or. Empty(aVincula[nPos,4])) .and.;
       EF1->(dbSeek(xFilial("EF1")+Left(TIPO_MODULO,1)+aVincula[nPos,3]+aVincula[nPos,14]+aVincula[nPos,15]+aVincula[nPos,20]))
          AtuVincEF3("INCLUIR",nPos)
       EndIf
    EndIf
    //**

    TRB->(DBSKIP())
EndDo

// *** GFP - 25/04/2011 :: 11:00 - Tratamento de Workflow na rotina de Cambio
If AvFlags("WORKFLOW")
   EasyGroupWF("CAMBIO_EIC",aChaves)
EndIf

If M->WA_PO_DI == "C"  // GFP - 06/05/2014
   lCredito := .T.
ElseIf M->WA_PO_DI == "A"
   aOrd := SaveOrd("SWB")
   lCredito := SWB->(DbSeek(xFilial("SWB")+SWA->WA_HAWB+AvKey("C","WB_PO_DI")))
   RestOrd(aOrd,.T.)
EndIf
/* //NCF - 01/06/2020 - Nopado (Gravação incorreta da SWA - Saldo do adiantamento)
If lCredito  // GFP - 30/04/2014
   ChkAltCred(If(nOpca == 1,"I",If(nOpca == 2, "A","")),M->WA_PO_DI)
EndIf
*/
//If !lTitSWB .And. !lTitCrd
//   AP100AtuSWB()
//EndIf
//AP100WFlow("CB")
//AP100WFlow("LQ")
// *** Fim GFP

For nI:=1 To Len(aParcComp)

    If !lReturn
        Exit
    EndIf

	//If SWA->WA_PO_DI <> "C"
		SWB->(DbGoto(aParcComp[nI,1]))
		TRB->(DbGoto(aParcComp[nI,2]))

		lReturn := EICFI400("COMP_TITULO", "COMPENSA")

		If !Empty(TRB->WB_CA_TX) .AND. !Empty(TRB->WB_CA_DT) .AND. lReturn
			lReturn := EICFI400("BAIXA_TITULO")
		EndIf
	/*Else
    	SWB->(DbGoto(aParcComp[1,1]))
		TRB->(DbGoto(aParcComp[1,2]))
		AP100CrBx(3)
	EndIf*/
Next

If EasyEntryPoint("EICAP100")
   ExecBlock("EICAP100",.F.,.F.,"APOS GRAVAR SWB")
ENDIF

//** igor chiba 29/09/09
IF LCAMBIO_EIC
   SW9->(DBSETORDER(1))
   IF M->WA_PO_DI == 'D' //CAMBIO
      IF PAlteracao
         TRB->(DBGOTOP())
         DO WHILE TRB->(!EOF())
            nPos  := ASCAN(aLanca,{|x| x[1]==TRB->WB_INVOICE+TRB->WB_LINHA })
            IF nPos <> 0
               cLanca:= aLanca[nPos][2]
            ELSE
               cLanca:= 'AB'
            ENDIF

            IF TRB->TRB_ALT .OR. nPos <> 0
               If cLanca == "LQ"  .OR.  !Empty(TRB->WB_TITERP)  // PLB 15/04/10 - Verifica Existencia de Título para enviar Operação
               	//
               	//---	Envia a LIQUIDAÇÃO CAMBIAL do título da parcela de câmbio
               	//
                  WORK_AVINT->(dbAppend())
                  WORK_AVINT->WK_TIPO   := 'A'
                  WORK_AVINT->WK_FASE1  := 'CBO'
                  WORK_AVINT->WK_LANCA  := cLanca
                  WORK_AVINT->WK_FILIAL := xFilial('SWB')
                  WORK_AVINT->WK_HAWB   := TRB->WB_HAWB
                  WORK_AVINT->WK_PO_DI  := TRB->WB_PO_DI
                  WORK_AVINT->WK_INVOICE:= TRB->WB_INVOICE
                  WORK_AVINT->WK_FORN   := TRB->WB_FORN
                  WORK_AVINT->WK_LOJA   := TRB->WB_LOJA
                  WORK_AVINT->WK_LINHA  := TRB->WB_LINHA
                  WORK_AVINT->WK_ALIAS  := "SWB"
                  WORK_AVINT->WK_RECNO  := TRB->WB_RECNO
						//
						If EasyEntryPoint("EICAP100")
							ExecBlock("EICAP100",.F.,.F.,"APE100GRAVA_LIQUIDACAO_CBO_WORK_AVINT")
						EndIf
						//
	            EndIf
            ELSEIF EMPTY(TRB->WB_RECNO)
              	//
              	//---	Envia a INCLUSÃO de uma parcela de câmbio via ALTERAÇÃO CAMBIAL
              	//
               WORK_AVINT->(dbAppend())
               WORK_AVINT->WK_TIPO   := 'I'
               WORK_AVINT->WK_FASE1  := 'CBO'
               WORK_AVINT->WK_LANCA  := cLanca
               WORK_AVINT->WK_FILIAL := xFilial('SWB')
               WORK_AVINT->WK_HAWB   := TRB->WB_HAWB
               WORK_AVINT->WK_PO_DI  := TRB->WB_PO_DI
               WORK_AVINT->WK_INVOICE:= TRB->WB_INVOICE
               WORK_AVINT->WK_FORN   := TRB->WB_FORN
               WORK_AVINT->WK_LOJA   := TRB->WB_LOJA
               WORK_AVINT->WK_LINHA  := TRB->WB_LINHA
               WORK_AVINT->WK_ALIAS  := "SWB"
               WORK_AVINT->WK_RECNO  := 0
					//
					If EasyEntryPoint("EICAP100")
						ExecBlock("EICAP100",.F.,.F.,"APE100GRAVA_ALTERACAO_INC_CBO_WORK_AVINT")
					EndIf
					//
            ENDIF
            TRB->(DBSKIP())
         ENDDO
         aLanca:={}

      ELSE//incluindo invoice
         aInv:={}
         TRB->(DBGOTOP())
         DO WHILE TRB->(!EOF())
           	//
           	//---	Envia a INCLUSÃO de uma parcela de câmbio via INCLUSÃO CAMBIAL
           	//
            WORK_AVINT->(dbAppend())
            WORK_AVINT->WK_TIPO   := 'I'
            WORK_AVINT->WK_FASE1  := 'CBO'
            WORK_AVINT->WK_LANCA  := 'AB'
            WORK_AVINT->WK_FILIAL := xFilial("SWB")
            WORK_AVINT->WK_HAWB   := TRB->WB_HAWB
            WORK_AVINT->WK_PO_DI  := TRB->WB_PO_DI
            WORK_AVINT->WK_INVOICE:= TRB->WB_INVOICE
            WORK_AVINT->WK_FORN   := TRB->WB_FORN
            WORK_AVINT->WK_LOJA   := TRB->WB_LOJA
            WORK_AVINT->WK_LINHA  := TRB->WB_LINHA
            WORK_AVINT->WK_ALIAS  := "SWB"
            WORK_AVINT->WK_RECNO  := 0
			//
			If EasyEntryPoint("EICAP100")
				ExecBlock("EICAP100",.F.,.F.,"APE100GRAVA_INCLUSAO_INC_CBO_WORK_AVINT")
			EndIf
			//

            //integrar a exclusao da invoice da parcela
            IF (ASCAN(aInv,{|x| x[1] == TRB->WB_HAWB+TRB->WB_INVOICE }) )==0
               aadd(aInv,{TRB->WB_HAWB+TRB->WB_INVOICE})
               //
		         SW9->(DBSETORDER(1))
               SW9->(DBSEEK(XFILIAL('SW9')+TRB->WB_INVOICE+TRB->WB_FORN))
					//
					If	lEICFI06 //DRL 07/06/10 Existe a interface de INVOICES
      		     	//
   		        	//---	Envia a EXCLUSÃO do título da INVOICE, pois está sendo enviado o TÍTULO DEFINITIVO (Parcela de câmbio via INCLUSÃO CAMBIAL)
		           	//
                  WORK_AVINT->(dbAppend())
                  WORK_AVINT->WK_TIPO   := 'E'
                  WORK_AVINT->WK_FASE1  := 'INV'
                  WORK_AVINT->WK_LANCA  := 'EX'
                  WORK_AVINT->WK_FILIAL := SW9->W9_FILIAL
                  WORK_AVINT->WK_HAWB   := SW9->W9_HAWB
                  WORK_AVINT->WK_INVOICE:= SW9->W9_INVOICE
                  WORK_AVINT->WK_FORN   := SW9->W9_FORN
                  WORK_AVINT->WK_ALIAS  := "SW9"
                  WORK_AVINT->WK_RECNO  := SW9->(RECNO())
						//
						If EasyEntryPoint("EICAP100")
							ExecBlock("EICAP100",.F.,.F.,"APE100GRAVA_INCLUSAO_EXC_INV_WORK_AVINT")
						EndIf
					ElseIf lEICFI07	//INTERFACE DE INVOICE ANTECIPADA
      		     	//
   		        	//---	Envia a EXCLUSÃO do título da INVOICE ANTECIPADA, pois está sendo enviado o TÍTULO DEFINITIVO (Parcela de câmbio via INCLUSÃO CAMBIAL)
		           	//
			         EW4->(DBSETORDER(2))
	               EW4->(DBSEEK(XFILIAL('EW4')+TRB->WB_HAWB+TRB->WB_INVOICE+TRB->WB_FORN))
                  WORK_AVINT->(dbAppend())
                  WORK_AVINT->WK_TIPO   := 'E'
                  WORK_AVINT->WK_FASE1  := 'INVANT'
                  WORK_AVINT->WK_LANCA  := 'EX'
                  WORK_AVINT->WK_FILIAL := EW4->EW4_FILIAL
                  WORK_AVINT->WK_HAWB   := EW4->EW4_HAWB
                  WORK_AVINT->WK_INVOICE:= EW4->EW4_INVOIC
                  WORK_AVINT->WK_FORN   := EW4->EW4_FORN
                  WORK_AVINT->WK_ALIAS  := "EW4"
                  WORK_AVINT->WK_RECNO  := EW4->(RECNO())
						//
						If EasyEntryPoint("EICAP100")
							ExecBlock("EICAP100",.F.,.F.,"APE100GRAVA_INCLUSAO_EXC_INVANT_WORK_AVINT")
						EndIf
						//
                  //se tiver invoice normal integrar exclusao
               ENDIF
            ENDIF
            TRB->(DBSKIP())
         ENDDO
      ENDIF

//   ELSEIF M->WA_PO_DI == 'A'
   ELSEIF (M->WA_PO_DI == 'A' .Or. M->WA_PO_DI == 'F' .Or. M->WA_PO_DI == 'C')	// GCC - 27/08/2013
      IF PAlteracao
         TRB->(DBGOTOP())
         DO WHILE TRB->(!EOF())
            nPos  := ASCAN(aLanca,{|x| x[1]==TRB->WB_INVOICE+TRB->WB_PARCELA })
            IF nPos <> 0
               cLanca:= aLanca[nPos][2]
            ELSE
               cLanca:= 'AB'
            ENDIF

            IF TRB->TRB_ALT .OR. nPos <> 0
               If cLanca == "LQ"  .OR.  !Empty(TRB->WB_TITERP)  // PLB 15/04/10 - Verifica Existencia de Título para enviar Operação
      		     	//
   		        	//---	Envia a LIQUIDAÇÃO CAMBIAL da parcela (Título) do Câmbio Antecipado
		           	//
                  WORK_AVINT->(dbAppend())
                  WORK_AVINT->WK_TIPO   := 'A'
                  WORK_AVINT->WK_FASE1  := 'PA'
                  WORK_AVINT->WK_LANCA  := cLanca
                  WORK_AVINT->WK_FILIAL := xFilial("SWB")
                  WORK_AVINT->WK_HAWB   := TRB->WB_HAWB
                  WORK_AVINT->WK_PO_DI  := TRB->WB_PO_DI
                  WORK_AVINT->WK_INVOICE:= TRB->WB_INVOICE
                  WORK_AVINT->WK_FORN   := TRB->WB_FORN
                  WORK_AVINT->WK_LOJA   := TRB->WB_LOJA
                  WORK_AVINT->WK_LINHA  := TRB->WB_LINHA
                  WORK_AVINT->WK_ALIAS  := "SWB"
                  WORK_AVINT->WK_RECNO  := TRB->WB_RECNO
                  WORK_AVINT->WK_PARCELA:= TRB->WB_PARCELA
				  //
				  If EasyEntryPoint("EICAP100")
				     ExecBlock("EICAP100",.F.,.F.,"APE100GRAVA_LIQUIDACAO_PAGANT_WORK_AVINT")
                  EndIf
			      //
               EndIf
            ELSEIF EMPTY(TRB->WB_RECNO)
     		   //
   	           //--- Envia a INCLUSÃO CAMBIAL de uma parcela de Câmbio Antecipado via ALTERAÇÃO
	           //
               WORK_AVINT->(dbAppend())
               WORK_AVINT->WK_TIPO   := 'I'
               WORK_AVINT->WK_FASE1  := 'PA'
               WORK_AVINT->WK_LANCA  := cLanca
               WORK_AVINT->WK_FILIAL := xFilial("SWB")
               WORK_AVINT->WK_HAWB   := TRB->WB_HAWB
               WORK_AVINT->WK_PO_DI  := TRB->WB_PO_DI
               WORK_AVINT->WK_INVOICE:= TRB->WB_INVOICE
               WORK_AVINT->WK_FORN   := TRB->WB_FORN
               WORK_AVINT->WK_LOJA   := TRB->WB_LOJA
               WORK_AVINT->WK_LINHA  := TRB->WB_LINHA
               WORK_AVINT->WK_ALIAS  := "SWB"
               WORK_AVINT->WK_RECNO  := 0
               WORK_AVINT->WK_PARCELA:= TRB->WB_PARCELA
               //
               If EasyEntryPoint("EICAP100")
			      ExecBlock("EICAP100",.F.,.F.,"APE100GRAVA_ALTERACAO_INC_PAGANT_WORK_AVINT")
               EndIf
			   //
            ENDIF

            TRB->(DBSKIP())
         ENDDO
         aLanca:={}
      ELSE
         TRB->(DBGOTOP())
         DO WHILE TRB->(!EOF())
           	//
           	//---	Envia a INCLUSÃO de uma parcela de câmbio antecipado via INCLUSÃO CAMBIAL
           	//
            WORK_AVINT->(dbAppend())
            WORK_AVINT->WK_TIPO   := 'I'
            WORK_AVINT->WK_FASE1  := 'PA'
            WORK_AVINT->WK_LANCA  := 'AB'
            WORK_AVINT->WK_FILIAL := xFilial("SWB")
            WORK_AVINT->WK_HAWB   := TRB->WB_HAWB
            WORK_AVINT->WK_PO_DI  := TRB->WB_PO_DI
            WORK_AVINT->WK_INVOICE:= TRB->WB_INVOICE
            WORK_AVINT->WK_FORN   := TRB->WB_FORN
            WORK_AVINT->WK_LOJA   := TRB->WB_LOJA
            WORK_AVINT->WK_LINHA  := TRB->WB_LINHA
            WORK_AVINT->WK_ALIAS  := "SWB"
            WORK_AVINT->WK_RECNO  := 0
            WORK_AVINT->WK_PARCELA:= TRB->WB_PARCELA
				//
				If EasyEntryPoint("EICAP100")
					ExecBlock("EICAP100",.F.,.F.,"APE100GRAVA_INCLUSAO_INC_PAGANT_WORK_AVINT")
				EndIf
				//
            TRB->(DBSKIP())
         ENDDO
      ENDIF
   ENDIF

ENDIF
//**
//** GFC - 03/04/06 - Financiamento de Importação - Liquidação
If lEFFTpMod .and. lEIC_EFF
   Begin TransAction

//** PLB 10/04/06  -  Alteracao de Taxa de Liquidacao de Financiamento
   aTaxaLiq := {}
   nOldRec := EF3->( RecNo() )
   nOldInd := EF3->( IndexOrd() )
   EF3->( DBSetOrder(7) )
   For nInd:=1 to Len(aLiquida)
      TRB->(dbGoTo(aLiquida[nInd,5]))
      If  (nPos := aScan(aVincula,{|x| x[9]==TRB->WB_INVOICE .and. x[10]==If(Empty(TRB->WB_PARFIN), TRB->WB_LINHA, TRB->WB_PARFIN)})) > 0
         EF3->( DBSeek(xFilial("EF3")+Left(TIPO_MODULO,1)+aVincula[nPos][6]+aVincula[nPos][7]+aVincula[nPos][8]+aVincula[nPos][9]+aVincula[nPos][10]+"600") )
         EF1->( DBSeek(xFilial("EF1")+Left(TIPO_MODULO,1)+aVincula[nPos,3]+aVincula[nPos,14]+aVincula[nPos,15]+aVincula[nPos,20]))

         If EF3->EF3_MOE_IN  !=  EF1->EF1_MOEDA  // PLB 27/07/06 - Verifica se a moeda da invoice é diferente da moeda do contrato.
            If aLiquida[nInd,2] == "INCLUIR"
               nTxCon := BuscaTaxa(EF1->EF1_MOEDA,TRB->WB_CA_DT,,.F.,.T.,,"1")
               AAdd( aTaxaLiq , { aVincula[nPos][03] ,;  // Contrato
                                  aVincula[nPos][14] ,;  // Banco
                                  aVincula[nPos][15] ,;  // Praca
                                  aVincula[nPos][20] ,;  // Sequencia Contrato
                                  aVincula[nPos][09] ,;  // Invoice
                                  aVincula[nPos][10] ,;  // Parcela
                                  TRB->WB_CA_DT      ,;  // Data Liquidacao
                                  aVincula[nPos][18] ,;  // Moeda Invoice
                                  aLiquida[nInd][03] ,;  // Taxa Liquidacao
                                  aVincula[nPos][17] ,;  // Valor Moeda Invoice
                                  EF1->EF1_MOEDA     ,;  // Moeda Contrato
                                  nTxCon             ,;  // Taxa Contrato
                                  aVincula[nPos][17]*aLiquida[nInd][03]/nTxCon } ) // Valor Moeda Contrato
               lLiquida := .T.
            EndIf
         EndIf
      EndIf
   Next
   EF3->( DBSetOrder(nOldInd) )
   EF3->( DBGoTo(nOldRec) )
   If lLiquida
      aTaxaLiq := EX401GetLiq(aTaxaLiq)
   EndIf
//**

   For nInd:=1 to Len(aLiquida)
      TRB->(dbGoTo(aLiquida[nInd,5]))
      If (nPos := aScan(aVincula,{|x| x[9]==TRB->WB_INVOICE .and. x[10]==If(Empty(TRB->WB_PARFIN), TRB->WB_LINHA, TRB->WB_PARFIN)})) > 0
         EF1->(dbSeek(xFilial("EF1")+Left(TIPO_MODULO,1)+aVincula[nPos,3]+aVincula[nPos,14]+aVincula[nPos,15]+aVincula[nPos,20]))

         If aLiquida[nInd,2] == "INCLUIR"
            //** PLB 10/04/06
            EF3->( DBSetOrder(7) )
            EF3->( DBSeek(xFilial("EF3")+Left(TIPO_MODULO,1)+aVincula[nPos][6]+aVincula[nPos][7]+aVincula[nPos][8]+aVincula[nPos][9]+aVincula[nPos][10]+EV_EMBARQUE) )
            If lLiquida .And. (nPos2 := AScan(aTaxaLiq,{|x| x[6]==aLiquida[nInd][1]})) > 0
               aVincula[nPos][12] := aTaxaLiq [nPos2][12]
            EndIf
            //**

            EX400Liquida(EF1->EF1_CONTRA,TRB->WB_INVOICE,;
                         If(!Empty(TRB->WB_PARFIN), TRB->WB_PARFIN, TRB->WB_LINHA), TRB->WB_HAWB,;
                         aVincula[nPos,1] ,;
                         TRB->WB_MOEDA, EF1->EF1_MOEDA,"EF1","EF3","CAMB",aLiquida[nInd,3],TRB->WB_CA_DT, ,TRB->WB_CA_DT,If(lMulTiFil,xFilial("SWB"),Nil),;
                         ,,,,TRB->WB_BANCO, TRB->WB_AGENCIA, /*TRB->WB_CONTA*/EF1->EF1_NCONFI, aVincula[nPos,15],,;
                         aVincula[nPos,1] * aLiquida[nInd,3], ,TRB->WB_CA_NUM, aVincula[nPos,16],;
                         Left(TIPO_MODULO,1), EF1->EF1_SEQCNT, "SWB", TRB->WB_FORN, TRB->WB_LOJA, TRB->WB_PO_DI,IIF(lLiquida .And. nPos2 > 0,aTaxaLiq[nPos2][13],))

         ElseIf aLiquida[nInd,2] == "ESTORNAR"
            EF3->(dbSetOrder(1))
            If EF3->(dbSeek(xFilial("EF3")+Left(TIPO_MODULO,1)+aVincula[nPos,3]+aVincula[nPos,14]+aVincula[nPos,15]+aVincula[nPos,20]+EV_LIQ_PRC))
               cSeq := ""
               Do While EF3->(!Eof()) .And. EF3->EF3_FILIAL == xFilial("EF3") .And. EF3->EF3_TPMODU==Left(TIPO_MODULO,1) .and.;
               aVincula[nPos,3] == EF3->EF3_CONTRA .And. EF3->EF3_CODEVE==EV_LIQ_PRC .and.;
               EF3->EF3_BAN_FI+EF3->EF3_PRACA+EF3->EF3_SEQCNT==aVincula[nPos,14]+aVincula[nPos,15]+aVincula[nPos,20]
                  If EF3->EF3_INVIMP == TRB->WB_INVOICE .and. If(!Empty(TRB->WB_PARFIN), EF3->EF3_LINHA==TRB->WB_PARFIN, EF3->EF3_LINHA==TRB->WB_LINHA) .and.;
                  EF3->EF3_VL_INV = aLiquida[nInd,4]
                     cSeq := EF3->EF3_SEQ
                  Endif
                  EF3->(DbSkip())
               Enddo
               If !Empty(cSeq)
                  Ap1EstLiq(cSeq,nPos)
               Endif
            EndIf
         EndIf
      EndIf
   Next nInd
   lLiquida := .F.

   End TransAction

EndIf
//**
//Jacomo Lisa - 12/08/2014 -- Incluida a integração para os itens Alterados
IF AvFlags("EIC_EAI") .AND. (M->WA_PO_DI == "D") .AND. LEN(aAltParc) <> 0//IGOR CHIBA SE TIVER PARCELA A SER ENVIADA(lAltAux .OR. lAltTotal)
   SW6->(DBSETORDER(1))
   SW6->(DBSEEK(xFilial("SW6")+M->WA_HAWB))
   If (!AvFlags("EAI_PGANT_INV_NF") .OR. (!EMPTY(SW6->W6_DT_NF)) )
      lTitEAI_OK := .T.
      IF !EICAP110(.T.,3,SWA->WA_HAWB,"D",,.T.,,aAltParc,'SWB') //EICAP110(lEnvio,nOpc,cHawb,cFaseAP,cTipParc,lJumpVal,cTipo,aAltParc,cTabAlias)
         lTitEAI_OK := .F.
      ENDIF
   ENDIF
ENDIF

SWA->(DBGOTO(nRecTRBDa))

// Bete 01/07/05 - Para refazer os titulos provisorios do FOB, descontando os valores adiantados
// Bete 05/09/05 - Refazer provisórios dos POs envolvidos no processo.
If lCposAntecip
   IF EasyGParam("MV_EASYFPO",,"N") == "S"//ASR - 16/09/2005 - GERA TITULOS DE PREVISÃO DE DESPESAS NO FINANCEIRO SE FOR IGUAL "S"
      /* comentado por WFS - migrado para static funcion RefazProv()
      FOR i:=1 TO LEN(aNumPos)
          cNumPO := LEFT(aNumPos[i], LEN(SW2->W2_PO_NUM))
          nOrderSW2:=SW2->(INDEXORD())
          SW2->(DBSETORDER(1))
          IF SW2->(DBSEEK(XFILIAL("SW2")+cNumPO))  //
             lBaixada:=.F.
             //JAP - 21/06/08
//             IF LEFT(SWA->WA_PO_DI,1) <> "A"
             IF AVFLAGS("EIC_EAI")
                AvProvRecalc(cNumPO) //reapuração de títulos provisórios
             Else
                IF (LEFT(SWA->WA_PO_DI,1) <> "A" .And. LEFT(SWA->WA_PO_DI,1) <> "F" .And. LEFT(SWA->WA_PO_DI,1) <> "C")	// GCC - 27/08/2013
                    Processa({|| FI400ANT_PO(cNumPO,.T.,@lBaixada)})
                ENDIF
                Processa({|| FI400POS_PO(cNumPO,lBaixada) })
             EndIf
          ENDIF
          SW2->(DBSETORDER(nOrderSW2))
      NEXT*/
      //wfs - quando for integração via mensagem única, executar a atualização fora do controlde de transações.
      If !AvFlags("EIC_EAI")
         RefazProv()
      EndIf
   ENDIF
ENDIF
SWA->(RecLock("SWA", .F.))
SWA->WA_LINHA := nLinhaTRB

(cAlias)->(MsUnlock())

END SEQUENCE

RETURN lReturn

*--------------------*
FUNCTION APE100Calc()
*--------------------*
LOCAL _DelIncAlt:= SPACE(01) , _MindDi
PRIVATE lAvIntFinEIC:= AvFlags("AVINT_FINANCEIRO_EIC")
If _CalcDespCamb
_MindDi  := ASCAN(Tab_RecDi, { |_M| _M[1] == SWB->(RECNO()) } )

IF _MindDi # 0
   SWD->(DBGOTO(Tab_RecDi[_MindDi,2])) ; RecLock("SWD",.F.)
   _DelIncAlt:= IF( EMPTY(TRB->WB_CA_DT), "D" ,"A" )	// GCC - 03/09/2013 - Verificar se o correto é colocar SWA->WA_PO_DI no lugar do "A"
ELSE
   IF ! EMPTY(TRB->WB_CA_DT) .AND. _CalcDespCamb
      IF ! SWD->( DBSEEK(xFilial()+SWA->WA_HAWB+ "101" + DTOS(SWB->WB_CA_DT)) )
         RecLock("SWD",.T.)
         //AAF 21/09/2009 - Gravacao do campo linha para chave unica do SWD.
         If lAvIntFinEIC
            SWD->WD_LINHA := DI500SWDLin(SWA->WA_HAWB,"101")
         EndIf
      ELSE
         RecLock("SWD",.F.)
      ENDIF
      _DelIncAlt:= "I"
      SWD->WD_FILIAL := xFilial("SWD")
   ENDIF
ENDIF

IF _DelIncAlt # SPACE(01)
   IF _DelIncAlt = "D"
      SWD->(DBDELETE()) ; Tab_RecDi[_MindDi,1]:= Tab_RecDi[_MindDi,2]:= 0
      SWD->(MSUNLOCK())
   ELSE
      SWD->WD_HAWB    := SWA->WA_HAWB
      SWD->WD_DESPESA := "101"
      SWD->WD_DES_ADI:= TRB->WB_CA_DT
      SWD->WD_VALOR_R := SWD->WD_VALOR_R+(TRB->WB_FOBMOE * TRB->WB_CA_TX)
      IF( _DelIncAlt = "I", AADD( Tab_RecDi,{ SWB->(RECNO()) , SWD->(RECNO()) }) , )
      SWD->(MSUNLOCK())
   ENDIF
ENDIF
EndIf
RETURN

*--------------------------*
FUNCTION APE100PosGI(cHouse)
*--------------------------*
cHouse:=M->WA_HAWB
SW7->(DBSEEK(xFilial()+cHouse))
SW4->(DBSEEK(xFilial()+SW7->W7_PGI_NUM))
RETURN NIL

*--------------------------------------------*
FUNCTION APE100GrTRB(cAlias1,bSeek,bFor,bWhile,nOpcao)   //NCF - 20/05/09 - Adicionada a variável "nOpcao" que não permite
*--------------------------------------------*           //       o bloqueio dos campos em caso de visualização do câmbio.
//** GFC - 28/03/06
If lEFFTpMod .and. lEIC_EFF
   EF3->(dbSetOrder(7))
EndIf
//**

(cAlias1)->(EVAL(bSeek))
DO WHILE EVAL(bWhile)

  IF ! EVAL(bFor)
     (cAlias1)->(DBSKIP())
     LOOP
  ENDIF

  //TRP - 28/06/2011 - Inicia as variáveis de memória dos campos de Banco e Agencia para não dar erro no MsSeek no FINA080. (Chamado 087453)
  M->WB_BANCO  := SWB->WB_BANCO
  M->WB_AGENCIA:= SWB->WB_AGENCIA
  M->WB_CONTA  := SWB->WB_CONTA

  IF(EasyEntryPoint("EICAP100"),Execblock("EICAP100",.F.,.F.,"INIMEMO"),) //TRP - 07/10/2011 - Ponto de Entrada para iniciar qualquer variável de memória.

  TRB->(DBAPPEND())

  AVREPLACE("SWB","TRB")// AWR - 31/05/2004

  //THTS - 14/10/2019 - Ajuste de chave criado para o projeto do grupo de campos do Hawb, PO_NUM e Invoice
  TRB->WB_CHAVE := AP100WBCHV(TRB->WB_CHAVE)
  
  //** igor chiba adicionando nº de  parcelas para serem usadas na exclusão do cambio 29/09/09
  IF LCAMBIO_EIC
     IF nPos_aRotina = 5 .OR. nPos_aRotina = 4
       IF (nPOs:=ASCAN(aParInv,{|x| x[1] == TRB->WB_INVOICE + TRB->WB_FORN })) = 0
          AADD(aParInv,{TRB->WB_INVOICE + TRB->WB_FORN ,1})
       ELSE
          aParInv[nPos][2]++
       ENDIF
     ENDIF
  ENDIF
  //**
  TRB->WB_RECNO  := SWB->(RECNO())
  TRB->WB_VM_OBS := SWB->(MSMM(WB_OBS,TAMSX3("WB_VM_OBS")[1],,,3))
  TRB->TRB_ALI_WT:= "SWB"
  TRB->TRB_REC_WT:= SWB->(Recno())

//  IF EICLOJA()
     TRB->WB_LOJA:= SWB->WB_LOJA
 // ENDIF

  If lWB_EVENT
     EC6->(DbSetOrder(1))
     If EC6->(dbSeek(xFilial("EC6")+"IMPORT"+TRB->WB_EVENT))
        TRB->WB_TIPOC := If(EC6->EC6_RECDES=="1","R","P")
     Else
        TRB->WB_TIPOC := "P"
     EndIf
  EndIf

  //** PLB 25/07/06 - Tratamento Multi-Usuario Financiamento
  If lEIC_EFF  .And.  lEFFTpMod .AND. nOpcao # 2      //NCF - 20/05/09 - Em caso de "visualização", os campos
     If !SoftLock("SWB")                              //      do SWB não são bloqueados
        Return .F.
     EndIf
  EndIf
  //**

  If !lCposAntecip
     TRB->WB_PO_DI := "D"
  EndIf

  //** GFC - Quebra de parcela automática
  If lEFFTpMod
     cParvin:=""
     If Empty(TRB->WB_PARVIN) .And. Empty(TRB->WB_ORIGEM)
         TRB->WB_PARVIN := TRB->WB_LINHA
     ElseIf Empty(TRB->WB_PARVIN) .And. !Empty(TRB->WB_ORIGEM)
         nPosTmp := TRB->(RecNo())
         aOrdTmp := SaveOrd("TRB")

         If lCposAntecip
            TRB->(DbSetOrder(3))
         Else
            TRB->(dbSetOrder(2))
         EndIf
         If TRB->(DbSeek(TRB->WB_INVOICE+TRB->WB_ORIGEM))
            cParVin := TRB->WB_PARVIN
         EndIf

         TRB->(DbGoTo(nPosTmp))
         TRB->WB_PARVIN := cParVin
         RestOrd(aOrdTmp)
      EndIf
  EndIf
  //**

/*TRB->WB_NUM      :=(cAlias1)->WB_NUM
  TRB->WB_DT       :=(cAlias1)->WB_DT
  TRB->WB_DT_VEN   :=(cAlias1)->WB_DT_VEN
  TRB->WB_LC_NUM   :=(cAlias1)->WB_LC_NUM
  TRB->WB_BANCO    :=(cAlias1)->WB_BANCO
  TRB->WB_AGENCIA  :=(cAlias1)->WB_AGENCIA
  TRB->WB_CA_NUM   :=(cAlias1)->WB_CA_NUM
  TRB->WB_CA_TX    :=(cAlias1)->WB_CA_TX
  TRB->WB_FOBMOE   :=(cAlias1)->WB_FOBMOE
  TRB->WB_CA_DT    :=(cAlias1)->WB_CA_DT
  TRB->WB_TIPO     :=(cAlias1)->WB_TIPO
  TRB->WB_DT_CONT  :=(cAlias1)->WB_DT_CONT
  TRB->WB_LIM_BAC  :=(cAlias1)->WB_LIM_BAC
  TRB->WB_HAWB     :=(cAlias1)->WB_HAWB
  TRB->WB_DT_REAL  :=(cAlias1)->WB_DT_REAL
  TRB->WB_LOTE     :=(cAlias1)->WB_LOTE
  TRB->WB_INVOICE  :=(cAlias1)->WB_INVOICE
  TRB->WB_FORN     :=(cAlias1)->WB_FORN
  TRB->WB_OBS      :=(cAlias1)->WB_OBS
  TRB->WB_DT_DIG   :=(cAlias1)->WB_DT_DIG
  TRB->WB_DT_ROF   :=(cAlias1)->WB_DT_ROF
  TRB->WB_ENV_BAC  :=(cAlias1)->WB_ENV_BAC
  TRB->WB_NR_ROF   :=(cAlias1)->WB_NR_ROF
  TRB->WB_TIPOREG  :=(cAlias1)->WB_TIPOREG
  TRB->WB_RETIDO   :=(cAlias1)->WB_RETIDO
  TRB->WB_CORRETO  :=(cAlias1)->WB_CORRETO
  TRB->WB_VL_CORR  :=(cAlias1)->WB_VL_CORR
  TRB->WB_DESPESA  :=(cAlias1)->WB_DESPESA
  TRB->WB_DT_DESE  :=(cAlias1)->WB_DT_DESE
  TRB->WB_BCO_REC  :=(cAlias1)->WB_BCO_REC
  TRB->WB_AGENREC  :=(cAlias1)->WB_AGENREC
  TRB->WB_SWIFT    :=(cAlias1)->WB_SWIFT
  TRB->WB_CON_REC  :=(cAlias1)->WB_CON_REC
  If lCposAntecip
     TRB->WB_PO_DI := (cAlias1)->WB_PO_DI
     TRB->WB_PGTANT:= (cAlias1)->WB_PGTANT
     TRB->WB_NUMPO := (cAlias1)->WB_NUMPO
  Else
     TRB->WB_PO_DI := "D"
  EndIf
  TRB->WB_MOEDA  := (cAlias1)->WB_MOEDA //  SW9->W9_MOE_FOB

  IF SX3->(DBSEEK("WB_NAT_CON"))
     TRB->WB_NAT_CON  :=(cAlias1)->WB_NAT_CON
  ENDIF
  IF lExisteContabilidade
     TRB->WB_CONTAB := (cAlias1)->WB_CONTAB
  ENDIF */

  //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
  SW9->(DBSEEK(xFilial("SW9")+(cAlias1)->WB_INVOICE+(cAlias1)->WB_FORN+EICRetLoja(cAlias1,"WB_LOJA")+(cAlias1)->WB_HAWB))
  IF EasyEntryPoint("EICAP100") //OS 0639/01 FCD
     cAliasRDM:= cAlias1
     ExecBlock("EICAP100",.F.,.F.,"GRAVA_TRB")
  ENDIF

  //** GFC - 23/03/06 - Financiamento de Importação
  If lEFFTpMod .and. lEIC_EFF .and. lWB_EVENT .And. TRB->WB_EVENT == PRINCIPAL //101
     GrvaVincula()
  EndIf
  //**

  //RMD - 13/11/07 - Nova Legislação Cambial
  //EOB - 31/07/09 - Troca de EECFlags p/ AvFlags (Avgeral)
  If AvFlags("CAMBIO_EXT")
     If AD101FndInv("IMP", SWB->WB_FILIAL, SWB->WB_HAWB, SWB->WB_INVOICE, SWB->WB_LINHA)
        TRB->WK_VALBCO := EYR->EYR_VALOR
     EndIf
  EndIf

  If lAdtMultFil
     TRB->WB_FILORI := If(!Empty(SWB->WB_FILORI),SWB->WB_FILORI,xFilial("SWB"))   //NCF - 28/09/2017 - Carregar para os adiantamentos antigos
  EndIf
  
  SWB->(DBSKIP())
ENDDO

//** GFC - 28/03/06
If lEFFTpMod .and. lEIC_EFF
   EF3->(dbSetOrder(1))
EndIf
//**

dbSelectArea("TRB")
dbGoTop()
RETURN .T.

***************************************************************************

*----------------------------------------------------------------------------
FUNCTION APE100_PO(PTipo)
*----------------------------------------------------------------------------
LOCAL aTab_PO:={}, _Ret:=''

If Type("_PictPO") == "U"
   Private _PictPO  := ALLTRIM(X3Picture("W2_PO_NUM"))
EndIf

SW7->(DBSEEK(xFilial()+SWA->WA_HAWB))

WHILE ! SW7->(EOF()) .AND. SWA->WA_HAWB   == SW7->W7_HAWB ;
                     .AND. xFilial("SW7") == SW7->W7_FILIAL

   IF ASCAN(aTab_PO,TRAN(SW7->W7_PO_NUM,_PictPO)) = 0
      AADD(aTab_PO,TRAN(SW7->W7_PO_NUM,_PictPO))
   ENDIF

   IF PTipo == "P" ; EXIT ; ENDIF

   SW7->(DBSKIP())
ENDDO

IF EMPTY(aTab_PO)
   RETURN SPACE(LEN(SW2->W2_PO_NUM))
ENDIF

IF PTipo = "P"
   RETURN aTab_PO[1]
ELSE
   AEVAL(aTab_PO,{|Pedido| _Ret+=ALLTRIM(Pedido)+","})
   _Ret := SUBSTR(_Ret,1,LEN(_Ret)-1)
   RETURN _Ret
ENDIF

//JPA - 16/08/2006 - Definições do relatório personalizável
****************************
Static Function ReportDef()
****************************
//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTabelas := {"SW9", "SA2"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := {}

//Parâmetros:            Relatório , Titulo ,  Pergunte , Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("EICAP100", STR0014, ""  , {|oReport| ReportPrint(oReport)}, STR0014)

//Define como padrão o formato Paisagem
oReport:oPage:lLandscape := .T.
oReport:oPage:lPortrait := .F.

//Define os objetos com as seções do relatório
oSecao1 := TRSection():New(oReport,STR0267,aTabelas,aOrdem) //STR0267 "Eventos do Câmbio"
oSecao2 := TRSection():New(oReport,STR0268,{"TRB"},{})  // JPA - 17/08/06 //STR0268 "Processo/Pedidos"

//Definição das colunas de impressão da seção 1
TRCell():New(oSecao1, "TIPOREG", "TRB", STR0008                 , /*Picture*/                 , 12 , /*lPixel*/, {||TRB->(APE100_Tipo())})
TRCell():New(oSecao1, "NRFFC"  , "TRB", STR0009                 , /*Picture*/                 , 10 , /*lPixel*/, {||TRANS(TRB->WB_LOTE,AllTrim(x3Picture("WB_LOTE")))})
TRCell():New(oSecao1, "CONTRAT", "TRB", STR0010                 , /*Picture*/                 , 13 , /*lPixel*/, {||TRB->WB_DT_CONT})
TRCell():New(oSecao1, "LC_NR"  , "TRB", STR0011                 , /*Picture*/                 , 10 , /*lPixel*/, {||TRANS(TRB->WB_LC_NUM,_PictLc)})
TRCell():New(oSecao1, "VENCTO" , "TRB", STR0012                 , /*Picture*/                 , 08 , /*lPixel*/, {||TRB->WB_DT_VEN})
TRCell():New(oSecao1, "CAMBIO" , "TRB", STR0013                 , /*Picture*/                 , 08 , /*lPixel*/, {||TRB->(APE100DTLIM(WB_DT_VEN))})
TRCell():New(oSecao1, "LIMITE" , "TRB", STR0014                 , /*Picture*/                 , 14 , /*lPixel*/, {||TRB->WB_CA_NUM})
TRCell():New(oSecao1, "MOEDA"  , "TRB", STR0043                 , /*Picture*/                 , 06 , /*lPixel*/, {||TRB->WB_MOEDA})
TRCell():New(oSecao1, "VALOR"  , "TRB", STR0016                 , /*Picture*/                 , 20 , /*lPixel*/, {||TRANS(IIF(Left(TRB->WB_TIPOREG,1)=="P",TRB->WB_PGTANT,TRB->WB_FOBMOE),'@E 9,999,999,999.99')}) //RRV - 07/01/2013 - Imprime valor de acordo com o tipo de Cambio.
TRCell():New(oSecao1, "LIQUID" , "TRB", STR0044                 , /*Picture*/                 , 13 , /*lPixel*/, {||TRB->WB_CA_DT})
TRCell():New(oSecao1, "NO_ROF" , "TRB", STR0017                 , /*Picture*/                 , 10 , /*lPixel*/, {||TRB->WB_NR_ROF})
TRCell():New(oSecao1, "DT_ROF" , "TRB", STR0018                 , /*Picture*/                 , 13 , /*lPixel*/, {||TRB->WB_DT_ROF})
TRCell():New(oSecao1, "AVISOBC", "TRB", STR0019                 , /*Picture*/                 , 10 , /*lPixel*/, {||TRANS(TRB->WB_NUM,_PictApe)})
TRCell():New(oSecao1, "DTAV_BC", "TRB", STR0020                 , /*Picture*/                 , 08 , /*lPixel*/, {||TRB->WB_DT})
TRCell():New(oSecao1, "TXCAMB" , "TRB", STR0031                 , /*Picture*/                 , 14 , /*lPixel*/, {||TRANS(TRB->WB_CA_TX,AVSX3("WB_CA_TX",6))})
TRCell():New(oSecao1, "VALORRS", "TRB", STR0032                 , /*Picture*/                 , 20 , /*lPixel*/, {||TRANS(IIF(Left(TRB->WB_TIPOREG,1)=="P",TRB->WB_PGTANT,TRB->WB_FOBMOE)*TRB->WB_CA_TX,'@E 9,999,999,999.99')})
TRCell():New(oSecao1, "INVOICE", "TRB", STR0034                 , /*Picture*/                 , 12 , /*lPixel*/, {||TRB->WB_INVOICE})

oReport:Section(STR0267):Cell("VALOR"   ):SetHeaderAlign("CENTER") //STR0267 "Eventos do Câmbio" //RRV - 07/01/2013 - Ajuste de alinhamento.
oReport:Section(STR0267):Cell("VALORRS" ):SetHeaderAlign("RIGHT") //STR0267 "Eventos do Câmbio"
oReport:Section(STR0267):Cell("TXCAMB"  ):SetHeaderAlign("RIGHT") //STR0267 "Eventos do Câmbio"

/*RRV - 07/01/2013 - Nopado por cortar informações no relatório.
//JWJ 11/01/07: Ajuste no espaçamento das colunas
AEVAL(oSecao1:aCell, {|X| X:SetColSpace(2) })
AEVAL(oSecao2:aCell, {|X| X:SetColSpace(2) })

oReport:Section(STR0267):Cell("VALOR"   ):SetColSpace(5) //STR0267 "Eventos do Câmbio"
oReport:Section(STR0267):Cell("VALORRS"   ):SetColSpace(5)//STR0267 "Eventos do Câmbio"*/

//TRP - 10/09/07 - Impressão do total da coluna Valor em R$
oSecao1:SetTotalInLine(.F.)
oSecao1:SetTotalText(STR0269) //STR0269 "Total:"
oTotal:= TRFunction():New(oSecao1:Cell("VALORRS"),NIL,"SUM",/*oBreak*/,"","@E 9,999,999,999.99",{|| IIF(Left(TRB->WB_TIPOREG,1)=="P",TRB->WB_PGTANT,TRB->WB_FOBMOE)*TRB->WB_CA_TX },.T.,.F.)
oTotal:SetTotalInLine(.F.)
// JPA - 17/08/06 - Definição das colunas de impressão da seção 2
TRCell():New(oSecao2,"WB_HAWB" , "TRB", STR0270  , /*Picture*/, 030 , /*lPixel*/, /*{|| code-block de impressao }*/) //STR0270 "Processo"
oReport:Section(STR0271):Cell("WB_HAWB"):SetCellBreak() //STR0271 "Processo/Pedidos"

TRCell():New(oSecao2,STR0272 , "", STR0107  , /*Picture*/, 030 , /*lPixel*/, {||APE100_PO("T")}) //STR0272 "Pedido"
oReport:Section(STR0271):Cell("WB_HAWB"):SetCellBreak() //STR0271 "Processo/Pedidos"

oReport:bOnPageBreak :={||oReport:Section(STR0271):PrintLine()} //STR0271 "Processo/Pedidos"

//Necessário para carregar os perguntes mv_par**
//Pergunte(oReport:uParam,.F.) TLM 09/11/07 - Nenhum parâmetro está sendo passado no TReport

Return oReport

************************************
Static Function ReportPrint(oReport)
************************************
Local oSection := oReport:Section(STR0267) //STR0267 "Eventos do Câmbio"

//Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.
TRPosition():New(oReport:Section(STR0267),"SA2",1,{|| xFilial()+EC5->EC5_FORN}) //STR0267 "Eventos do Câmbio"
TRPosition():New(oReport:Section(STR0267),"SW9",1,{|| xFilial("SA2")+SA2->A2_NOME}) //STR0267 "Eventos do Câmbio"

oReport:SetMeter(TRB->(EasyRecCount("TRB")))
TRB->(dbGoTop())

oReport:Section(STR0271):Init() //STR0271 "Processo/Pedidos"
//Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section(STR0267):Init() //STR0267 "Eventos do Câmbio"

//Laço principal
Do While TRB->(!EoF()) .And. !oReport:Cancel()
   oReport:Section(STR0267):PrintLine() //Impressão da linha //STR0267 "Eventos do Câmbio"
   oReport:IncMeter()                     //Incrementa a barra de progresso

   TRB->( dbSkip() )
EndDo

//Fim da impressão da seção 1
oReport:Section(STR0267):Finish() //STR0267 "Eventos do Câmbio"
//Fim da impressão da seção 2
oReport:Section(STR0271):Finish() //STR0271 "Processo/Pedidos"
TRB->(DBGOTOP())

return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICAP200 ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 24.02.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualizacao do Historico                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICAP200()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICAP200(aParams)

LOCAL WorkFile, nOldArea:=SELECT()

LOCAL T_DBF:={ {"WKTIPO"    , "C", 1, 0 } ,;
               {"WKANOMES"  , "C", 6, 0 } ,;
               {"WKAGE_DES" , "C", 3, 0 } ,;
               {"WKHAWB"    , "C",AvSx3("W6_HAWB", AV_TAMANHO), 0 } ,;//   {"WKPO_NUM"  , "C",15, 0 } ,; AWR 17/02/2000
               {"WKFILIAL"  , "C",FWSizeFilial(), 0 } }

LOCAL cCadastro:=STR0104, lValidAno:=.F. ,; //"Atualiza‡ao do Hist¢rico"
      MRest:= "X"

LOCAL bMsg:= {|msg|MsProcTxt(msg)}
PRIVATE b_posqt:={|mes| FIELDPOS("WK_QT_PO"+mes)}, MAtualizou, _ANO,;
        b_posvl:={|mes| FIELDPOS("WK_VL_US"+mes)},;
        dUlt_Atz
Private _PictPO
//MFR TE-4855-WCC-497982-MTRADE-669 02/03/2017
//lP_SCHED := IF(lP_SCHED==NIL,.F.,lP_SCHED)
lP_SCHED := IF(ValType(aParams) == "A" .Or. ValType(aParams) == "L",.T.,.F.)
if ValType(aParams) == "A"
  RpcSetType(3)
  RpcSetEnv(aParams[1],aParams[2])
endif
_PictPO := ALLTRIM(X3Picture("W2_PO_NUM"))

SW2->(DBSETORDER(4)) ; SA5->(DBSETORDER(3))

WorkFile := E_CriaTrab(,T_DBF,"Work") //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados

IndRegua("Work",WorkFile+TEOrdBagExt(),"WKTIPO+WKAGE_DES+WKANOMES+WKHAWB") // WKPO_NUM")AWR 17/02/2000

TAno := YEAR(dDataBase)

DO WHILE .T.
   IF ! lP_SCHED
      MRest:="X"
      dUlt_Atz:=EasyGParam("MV_ULT_ATZ") //heder - reexibir nova data de atualizacao

      DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,15 To 18,55 OF oMainWnd

         @ 0.8,0.8 SAY STR0085 //"Ultima atualiza‡ao"
         @ 0.8,8.0 MSGET dUlt_Atz SIZE /*30*/40,10  WHEN .F.          // GFP - 17/04/2012 - Ajuste do tamanho do campo Data
         @ 2.5,0.8 SAY STR0086 // "Ano a ser atualizado"
         @ 2.5,8.0 MSGET TAno Picture "9999"     SIZE 20,8 OF oDlg Valid (lValidAno:=AP200ValAno(TAno))

         DEFINE SBUTTON FROM 11,115 TYPE 1 ACTION IF(lValidAno .OR. EVAL(AP200ValAno),(MRest:="S",oDlg:End()),) ENABLE OF oDlg
         DEFINE SBUTTON FROM 31,115 TYPE 2 ACTION (MRest:="X",oDlg:End()) ENABLE OF oDlg

      ACTIVATE MSDIALOG oDlg CENTERED

      If MRest # "S"
         E_RESET_AREA
         Return .F.
      Endif

      MAtualizou:= .F.
      Processa({|| AP200Gera()},STR0087) //"Pesquisa de Informa‡oes"
      //Help("", 1, "AVG0000194") //ATUALIZAÇÃO COMPLETADA
      MsgInfo(STR0045)//JVR - substituido por msginfo. Melhoria.
   Else
      //TAno      := MV_PAR06 //LRS - 05/05/2017
      lValidAno := AP200ValAno(TAno)
      If  lValidAno
         MAtualizou := .F.
         AP200Gera(lP_SCHED) //"Pesquisa de Informa‡oes"
         ConOut(STR0273) //STR0273 "Atualização Realizada"
         MRest:="S"
      ELSE
          ConOut(STR0274) //STR0274 "Ano Incorreto"
      EndIf
      EXIT

    ENDIF
ENDDO



*---------------------------------------------------------------------------
Function AP200Gera(lP_SCHED)
*---------------------------------------------------------------------------
Local _PictItem := ALLTRIM(X3Picture("B1_COD"))


LOCAL MTab_CC:={}, MTot_Cus_US, MFob_Moe, MCus_US, MSeq, MInd, MInd2
LOCAL nTot

//igorchiba 08/07/2010 manipular ponto de entrada
PRIVATE aTipo:={ AVSX3("W0__CC",5) , STR0090 ,; //"Fornecedor"
                                     STR0091,; //"Despachante"
                                     STR0092 ,;//"Comprador"
                                     STR0093 ,,;//"Agente"
                                     STR0094 }//"Cliente"

lP_SCHED := IF(lP_SCHED==NIL,.F.,lP_SCHED)

_ANO:=StrZero(TAno,4)

DBSELECTAREA("SWK")

nTot:=Easyreccount("SWK") - 8

IF ! lP_SCHED
   ProcRegua(nTot)
ENDIF
IF(EasyEntryPoint("EICAP100"),Execblock("EICAP100",.F.,.F.,"INIVAR"),)//igorchiba 08/07/2010

FOR MInd=1 TO LEN(aTipo)////igorchiba 08/07/2010 nao deixar fixo
    IF MInd = 6
       LOOP
    ENDIF

    DbSeek(xFilial()+STR(Mind,1,0)+_ANO)

    MsgAtu:=STR0095+aTipo[MInd] + " "  //"Zerando valores - "

    DO WHILE ! EOF() .AND. STR(MInd,1,0) = WK_TIPO .AND. _ANO = WK_ANO ;
                     .AND. SWK->WK_FILIAL == xFilial("SWK")

          IncProc(MsgAtu+ALLTRIM(WK_CODIGO)+IF(EICLOJA(),ALLTRIM(WK_CODLOJ),""))

       RecLock("SWK",.F.)

       FOR MInd2=1 TO 12
           //MSeq=PADL(MInd2,2,"0")
           MSeq=StrZero(MInd2,2)
           FIELDPUT(EVAL(b_posqt,MSeq),0)
           FIELDPUT(EVAL(b_posvl,MSeq),0)
       NEXT

       MsUnlock()
       DBSKIP()
    ENDDO
NEXT

DBSELECTAREA("SWJ")

nTot:=Easyreccount("SWJ") - 3

IF ! lP_SCHED
   ProcRegua(nTot)
ENDIF

FOR Mind=1 TO 2

    DbSeek(xFilial()+STR(Mind,1,0)+_ANO)

    MsgAtu:=STR0097+;  //"Zerando valores de "
              IF(MInd=1,STR0098,STR0099)//"FOB do Item "###"Custo do Item "

    DO WHILE ! EOF() .AND. STR(MInd,1,0) = WJ_TIPO .AND. _ANO = WJ_ANO ;
                     .AND. SWJ->WJ_FILIAL == xFilial("SWJ")

          IncProc(MsgAtu+TRAN(WJ_CODIGO,_PictItem))

       RecLock("SWJ",.F.)

       FOR MInd2=1 TO 12
           //MSeq=PADL(MInd2,2,"0")
           MSeq=StrZero(MInd2,2)
           FIELDPUT(FIELDPOS("WJ_FOB_"+MSeq),0)
           FIELDPUT(FIELDPOS("WJ_CUS_"+MSeq),0)
           FIELDPUT(FIELDPOS("WJ_QTD_"+MSeq),0)
       NEXT

       MsUnlock()
       DBSKIP()
    ENDDO
NEXT

MsgAtu:=STR0100 //"Atualizando valores - P.O. "

DBSELECTAREA("SW2")

SW2->(DbSeek(xFilial()+DTOS(AVCTOD('01/01/'+_ANO)),.T.))

ProcRegua(Easyreccount("SW2"))

WHILE ! EOF() .AND. YEAR(W2_PO_DT) = TAno .AND.;
                    SW2->W2_FILIAL == xFilial("SW2")

   ASIZE(MTab_CC,0)

   //MMes      := PADL(MONTH(W2_PO_DT),2,"0")
   MMes      := StrZero(MONTH(W2_PO_DT),2)
   MValor_Acu:= 0

   IncProc(MsgAtu+TRAN(W2_PO_NUM,_PictPO))

   DBSELECTAREA("SW3")

   DbSeek(xFilial()+SW2->W2_PO_NUM)

   DO WHILE ! EOF() .AND. SW2->W2_PO_NUM = SW3->W3_PO_NUM .AND. SW3->W3_FILIAL = xFilial("SW3")

      IF SW3->W3_SEQ <> 0
         SW3->(DbSkip()) ; LOOP
      ENDIF

      IF ASCAN(MTab_CC,SW3->W3_CC) = 0
         AADD(MTab_CC,SW3->W3_CC)
      ENDIF

      MValor     := CalcFob_Us(SW3->W3_PRECO,SW3->W3_QTDE)
      MValor_Acu := MValor_Acu + MValor

      //If SA5->(DbSeek(xFilial()+SW3->W3_COD_I+SW3->W3_FABR+SW3->W3_FORN)) .And.;
      If EICSFabFor(xFilial("SA5")+SW3->W3_COD_I+SW3->W3_FABR+SW3->W3_FORN, EICRetLoja("SW3", "W3_FABLOJ"), EICRetLoja("SW3", "W3_FORLOJ")) .AND.;
         SW2->W2_PO_DT > SA5->A5_ULT_ENT
         RecLock("SA5",.F.)
         SA5->A5_ULT_ENT:= SW2->W2_PO_DT
         SA5->A5_ULT_FOB:= MValor
         SA5->(MsUnLock())
      ENDIF

      AP200Grv_HM("V","1",MMes,SW3->W3_CC,MValor)
      IF ! SWJ->(DbSeek(xFilial()+'1'+_ANO+SW3->W3_COD_I))
         RecLock("SWJ",.T.)
         SWJ->WJ_FILIAL:= xFilial("SWJ")
         SWJ->WJ_TIPO  := '1'
         SWJ->WJ_ANO   := _ANO
         SWJ->WJ_CODIGO:= SW3->W3_COD_I
      ELSE
         RecLock("SWJ",.F.)
      ENDIF

      MInd :=SWJ->(FIELDPOS("WJ_FOB_"+MMes))
      MSeq :=SWJ->(FIELDPOS("WJ_QTD_"+MMes))
      SWJ->(FIELDPUT(MInd, SWJ->(FIELDGET(MInd))+MValor))
      SWJ->(FIELDPUT(MSeq ,SWJ->(FIELDGET(MSeq))+SW3->W3_QTDE))
      SWJ->(MsUnLock())
      SW3->(DbSkip()) ; LOOP
   ENDDO

   AP200Grv_HM("V","2",MMes,SW2->W2_FORN,MValor_Acu,IF(EICLOJA(),SW2->W2_FORLOJ,""))

   AP200Grv_HM("V","4",MMes,SW2->W2_COMPRA,MValor_Acu)

   AP200Grv_HM("V","7",MMes,SW2->W2_CLIENTE,MValor_Acu,IF(EICLOJA(),SW2->W2_CLILOJ,""))

   FOR Mind=1 TO LEN(MTab_CC)
       AP200Grv_HM("Q","1",MMes,MTab_CC[MInd],1)
   NEXT

   AP200Grv_HM("Q","2",MMes,SW2->W2_FORN,1,IF(EICLOJA(),SW2->W2_FORLOJ,""))

   AP200Grv_HM("Q","4",MMes,SW2->W2_COMPRA,1)

   AP200Grv_HM("Q","7",MMes,SW2->W2_CLIENTE,1,IF(EICLOJA(),SW2->W2_CLILOJ,""))

   //igorchiba 08/07/2010 gerar novos itens
   IF EasyEntryPoint("EICAP100") //OS 0639/01 FCD
      ExecBlock("EICAP100",.F.,.F.,"AP200GERPD")
   ENDIF

   DBSELECTAREA("SW2")

   DBSKIP()

ENDDO

DBSETORDER(1)
DBSELECTAREA("Work") ; AvZap()

DBSELECTAREA("SW6")

SW6->(DBSEEK(xFilial("SW6")))

MsgAtu:= STR0101 //"Agentes/Despachantes - Conheci/o "
IF ! lP_SCHED
   ProcRegua(Easyreccount("SW6"))
ENDIF

WHILE ! SW6->(EOF()) .AND. SW6->W6_FILIAL == xFilial("SW6")

   IncProc(MsgAtu+W6_HAWB)

   MAno_Des:= YEAR(W6_DT_DESE)
   MAno_Age:= YEAR(W6_DT_EMB)

   IF MAno_Des <> TAno .AND.  MAno_Age <> TAno
      DBSKIP() ; LOOP
   ENDIF

   MCus_US:=MFob_Moe:=MValor_Des:=MValor_Age:=MTot_Cus_US:= 0

   MAge:= W6_AGENTE
   MDes:= W6_DESP

   DBSELECTAREA("SW7")

   SW7->(DbSeek(xFilial()+SW6->W6_HAWB))

   WHILE ! SW7->(EOF()) .AND. SW6->W6_HAWB = SW7->W7_HAWB .AND. SW7->W7_FILIAL = xFilial("SW7")

      SW2->(DbSeek(xFilial()+SW7->W7_PO_NUM))

      MValor:= CalcFob_Us(W7_PRECO,W7_QTDE)

      IF MAno_Age = TAno   && Agente

         //MMes    :=PADL(MONTH(SW6->W6_DT_EMB),2,"0")
         MMes    :=StrZero(MONTH(SW6->W6_DT_EMB),2)

         IF ! Work->(DBSEEK("5"+SW6->W6_AGENTE+_ANO+MMes+SW7->W7_HAWB))//SW7->W7_PO_NUM))
            Work->(DBAPPEND())
            Work->WKTIPO    := "5"
            Work->WKANOMES  := _ANO + MMes
            Work->WKAGE_DES := SW6->W6_AGENTE
            Work->WKHAWB    := SW7->W7_HAWB//W7_PO_NUM AWR 17/02/2000
         ENDIF
         MValor_Age:= MValor_Age + MValor
      ENDIF

      IF MAno_Des = TAno   && Despachante

/*         IF EMPTY(MTot_Cus_US)
            MTot_Cus_US:= Custo_em_US()
         ENDIF

  */
         MMes    := StrZero(MONTH(SW6->W6_DT_DESE),2)

    /*     MCus_US := MTot_Cus_US * ;
                   ((MFob_Moe:=SW7->W7_PRECO*SW7->W7_QTDE)/SW6->W6_FOB_TOT)*/

         IF ! SWJ->(DbSeek(xFilial()+'2'+_ANO+SW7->W7_COD_I+SW7->W7_FORN+EICRetLoja("SW7","W7_FORLOJ")))
              RecLock("SWJ",.T.)
              SWJ->WJ_FILIAL:= xFilial("SWJ")
              SWJ->WJ_TIPO  := '2'
              SWJ->WJ_ANO   := _ANO
              SWJ->WJ_CODIGO:= SW7->W7_COD_I
              SWJ->WJ_FORN  := SW7->W7_FORN
              IF EICLOJA()
                 SWJ->WJ_FORLOJ:= SW7->W7_FORLOJ
              ENDIF
         ELSE
              RecLock("SWJ",.F.)
         ENDIF

         SWJ->WJ_MOEDA := SW2->W2_MOEDA
         MInd :=FIELDPOS("WJ_FOB_"+MMes)
         MInd2:=FIELDPOS("WJ_CUS_"+MMes)
         MSeq :=FIELDPOS("WJ_QTD_"+MMes)
         FIELDPUT(MInd, FIELDGET(MInd) +MFob_Moe)
         FIELDPUT(MInd2,FIELDGET(MInd2)+MCus_US)
         FIELDPUT(MSeq ,FIELDGET(MSeq) +SW7->W7_QTDE)
         SWJ->(MsUnLock())

         DBSELECTAREA("SW7")

         IF ! Work->(DBSEEK("3"+SW6->W6_DESP+_ANO+MMes+SW7->W7_HAWB))//SW7->W7_PO_NUM))
            Work->(DBAPPEND())
            Work->WKFILIAL   := xFilial()
            Work->WKTIPO     := "3"
            Work->WKANOMES   := _ANO + MMes
            Work->WKAGE_DES  := SW6->W6_DESP
            Work->WKHAWB     := SW7->W7_HAWB //W7_PO_NUM AWR 17/02/2000
         ENDIF
         MValor_Des:= MValor_Des + MValor
      ENDIF

      DBSKIP()

   ENDDO

   DBSELECTAREA("SW6")

   IF MValor_Age > 0
      MMes:= PADL(MONTH(W6_DT_EMB),2,"0")
      AP200Grv_HM("V","5",MMes,W6_AGENTE,MValor_Age)
   ENDIF

   IF MValor_Des > 0
      MMes:= PADL(MONTH(W6_DT_DESE),2,"0")
      AP200Grv_HM("V","3",MMes,W6_DESP,MValor_Des)
   ENDIF

   DBSKIP()
ENDDO

DBSELECTAREA("Work") ; DBGOTOP()

WHILE ! Work->(EOF())
   MTipo   := WKTIPO
   MAnoMes := WKANOMES
   MAge_Des:= WKAGE_DES
   MTOT_PO := 0
   WHILE ! Work->(EOF()) .AND. MTipo = WKTIPO .AND. MAnoMes=WKANOMES ;
                 .AND. MAge_Des = WKAGE_DES
      MTot_Po++
     Work->( DBSKIP())
   ENDDO

   IF MTot_Po > 0
      AP200Grv_HM("Q",MTipo,SUBSTR(MAnoMes,5,2),MAGE_DES,MTot_Po)
   ENDIF

ENDDO

IF MAtualizou
   If SX6->(DbSeek(SM0->M0_CODFIL+"MV_ULT_ATZ")).OR.SX6->(DbSeek(Space(FWSizeFilial())+"MV_ULT_ATZ"))
      SETMV("MV_ULT_ATZ",dDataBase)
   Endif
ENDIF

Return .T.
*----------------------------------------------------------------------------
FUNCTION AP200Grv_HM(PV_Q,PTipo,PMes,PCodigo,PValor,PLoja)
*----------------------------------------------------------------------------
LOCAL _pos, oldselect:=SELECT()
Default PLoja:= ""

MAtualizou:= .T.

DBSELECTAREA("SWK")

_pos:=EVAL(IF(PV_Q="V",b_posvl,b_posqt),PMes)

If(ValType(PCodigo)="N",PCodigo:=STR(PCodigo,6,0),)

IF ! DbSeek(xFilial()+PTipo+_ANO+PCodigo+IF(EICLOJA(),PLoja,""))
   RecLock("SWK",.T.)
   SWK->WK_FILIAL:= xFilial("SWK")
   SWK->WK_TIPO  := PTipo
   SWK->WK_ANO   := _ANO
   SWK->WK_CODIGO:= PCodigo
   IF EICLOJA()
      SWK->WK_CODLOJ:= PLoja
   ENDIF
ELSE
   RecLock("SWK",.F.)
ENDIF
FIELDPUT(_pos,FIELDGET(_pos)+PValor)
MsUnLock()
DBSELECTAREA(oldselect)
RETURN NIL
*----------------------------------------------------------------------------
Function AP200ValAno(TAno)
*----------------------------------------------------------------------------
IF EMPTY(TANO)
   Help("", 1, "AVG0000195")
   Return .F.
ENDIF
Return .T.

*---------------------------------------------------------------------------*
* Uso....: Dicionario SXB
*---------------------------------------------------------------------------*
Function Ap100Cfg() // CAF 21/08/1998 - 15:00
*---------------------------------------------------------------------------*
Local oDlg := GetWndDefault()    // Acessa obj. Dlg - ConPad1
Local oBrw, oCol, bMS_Combo, bMS_Visualiza

Local bSet_Combo := {|| bMS_Combo := oDlg:aControls[3]:bChange,;
                        oDlg:aControls[3]:bChange := ;
               {|| oDlg:Cargo := NIL, EVAL(bMS_Combo,oDlg:aControls[3]) } }

Local bSet_Visualiza:=  {|| bMS_Visualiza := oDlg:aControls[9]:bAction,;
                            oDlg:aControls[9]:bAction := ;
               {|| EVAL(bMS_Visualiza,oDlg:aControls[9]), SetWndDefault(oDlg) } }

Static hMarca, hDesmarca

IF ValType(oDlg) != "O" .OR. oDlg:Cargo != Nil
   Return ( SW6->W6_HAWB ) // Retorna o campo do browse
ENDIF

oBrw := oDlg:aControls[1]   // Acessa obj. Brw - ConPad1
*---->> Nem sempre o Wnd default e o obj. DLG - ConPad1 ...
IF ValType(oBrw) != "O" .OR. oBrw:ClassName() != "TCBROWSE"
   Return ( SW6->W6_HAWB ) // Retorna o campo do browse
ENDIF
*----//
oDlg:Cargo  := "AVERAGE - AP100CFG()"

IF oBrw:Cargo == NIL
   oDlg:bPainted     := {|| oBrw:Cargo := "AVERAGE - AP100CFG()",;
                         Eval(bSet_Combo),;
                         Eval(bSet_Visualiza),;
                         oDlg:bPainted  := Nil  }
ENDIF

DEFAULT hMarca    := LoadBitmap(GetResources(),"LBOK")
DEFAULT hDesmarca := LoadBitmap(GetResources(),"LBNO")

oCol := TcColumn():New(" ", {|| IIF(ChangeColor(),hMarca,hDesmarca) } )
oCol:lBitmap := .T.
oCol:lNoLite := .T.
oCol:nWidth  := 14
oBrw:AddColumn( oCol )
oBrw:nFreeze := 1

Return ( SW6->W6_HAWB ) // Retorna o campo do browse

*-------------------------------------------------*
Function ChangeColor() // CAF 24/08/1998 - 10:00
*-------------------------------------------------*
Local nRecSWA:=SWA->(Recno())
Local lRet := .T.

IF ! SWA->(dbSeek(xFilial()+SW6->W6_HAWB))
   lRet := .F.
ENDIF

SWA->(dbGoTo(nRecSWA))

Return ( lRet )

*----------------------------------------------------*
Function PorcCorretor(nValor_US,nValor_RL,nTxCambio)
*----------------------------------------------------*
LOCAL nPorc:=0,nValorReal:=0

IF nTxCambio == NIL
   nTxCambio := M->WB_CA_TX
ENDIF

DO CASE
   CASE nValor_US <= SYW->YW_VLR_MIN
        nPorc:=SYW->YW_PERCENT

   CASE nValor_US <= SYW->YW_VLR_02
        nPorc:=SYW->YW_PERC_02

   CASE nValor_US <= SYW->YW_VLR_03
        nPorc:=SYW->YW_PERC_03

   CASE nValor_US <= SYW->YW_VLR_04
        nPorc:=SYW->YW_PERC_04

   CASE nValor_US >= SYW->YW_VLR_05
        nPorc:=SYW->YW_PERC_05
ENDCASE


IF nValor_RL # NIL
   nValorReal := nValor_RL * (nPorc/100)
ELSE
   nValorReal := (nValor_US * nTxCambio) * (nPorc/100)
ENDIF

   IF !EMPTY(SYW->YW_MINIMO)
      IF nValorReal < (SYW->YW_MINIMO * nTxCambio)
         nValorReal := SYW->YW_MINIMO * nTxCambio
      ENDIF
   ENDIF
   IF !EMPTY(SYW->YW_MAXIMO)
      IF nValorReal > (SYW->YW_MAXIMO * nTxCambio)
         nValorReal := SYW->YW_MAXIMO * nTxCambio
      ENDIF
   ENDIF

Return ( nValorReal )

*-------------------------------------------------*
FUNCTION AP100SUBCAB()
*-------------------------------------------------*
Linha++
@ Linha,T_Len[1,2] PSAY ALLTRIM(AVSX3("W6_HAWB",5)) + " : " + SWA->WA_HAWB
  Linha++
@ Linha,T_Len[1,2] PSAY STR0107 + " : " + APE100_PO("T")
  Linha++

RETURN STR0008
*-------------------------------------------------*
FUNCTION APE100DTLIM(dData)
*-------------------------------------------------*
LOCAL dLimite :=AVCTOD(SPACE(8))
IF EMPTY(dData)
  RETURN dLimite
ENDIF

dLimite := dData -2
DO WHILE .T.
 IF DOW(dLimite)== 1 .OR. DOW(dLimite) == 7 // DOMINGO OU SABADO
   dLimite -= IF(Dow(dLimite)==7,-1,IF(DOW(dLimite)==1,2,0))
 ELSE
   EXIT
 ENDIF
ENDDO
RETURN (dLimite)

*-------------------------------------------------*
FUNCTION AP100NAOContab(cOpcaoMenu,lTodos)
*-------------------------------------------------*
Default lTodos := .T.//AAF 11/12/04

IF lExisteContabil
  If lTodos//AAF 11/12/04 - Verifica todas as parcelas
     SWB->(dbSeek(xFilial()+SWA->WA_HAWB+IF(lCposAntecip,SWA->WA_PO_DI,'')))

     While !SWB->(Eof()) .And. xFilial("SWB")+SWA->WA_HAWB = SWB->WB_FILIAL+SWB->WB_HAWB ;
                         .And. IF(lCposAntecip,SWB->WB_PO_DI==SWA->WA_PO_DI,.T.)
       IF !EMPTY(SWB->WB_CONTAB)
          IF cOpcaoMenu = 5
            Help("", 1, "AVG0000196")
          ENDIF
          RETURN .F.
       Endif
       SWB->(DBSKIP())
     ENDDO
  Else
     //AAF 11/12/04 - Verifica se foi contabilizada apenas a parcela selecionada.
     If !Empty(TRB->WB_CONTAB)
       IF cOpcaoMenu = 5
         Help("", 1, "AVG0000196")
       ENDIF
       RETURN .F.
     Endif
  Endif
ENDIF

IF lCposAntecip .AND. cOpcaoMenu == 5
   If(Select("TRB") > 0 .And. TRB->WB_RECNO <> 0 , SWB->(DbGoTo(TRB->WB_RECNO)),) //SWB->(DBSETORDER(5))
//   IF SWA->WA_PO_DI == 'A' .AND. SWB->(DBSEEK(xFilial()+SWA->WA_HAWB))
   IF (SWA->WA_PO_DI == 'A' .Or. SWA->WA_PO_DI == 'F' .Or. SWA->WA_PO_DI == 'C' ) .AND. HasAdVinEm() //SWB->(DBSEEK(xFilial()+SWA->WA_HAWB))	// GCC - 27/08/2013
      IF Select("TRB") > 0
         IF TRB->WB_PARCELA == SWB->WB_PARCELA //TDF - 05/03/12 - VERIFICA A PARCELA DE CAMBIO.
            SWB->(DBSETORDER(1))
            MSGInfo(STR0151)  // "Adiantamento nao pode ser excluido, pois possui parcelas utilizadas em Processos."
            return .F.
         EndIf
      ELSE
         SWB->(DBSETORDER(1))
         MSGInfo(STR0151)  // "Adiantamento nao pode ser excluido, pois possui parcelas utilizadas em Processos."
         return .F.
      ENDIF
   ENDIF
   SWB->(DBSETORDER(1))
ENDIF

//ASR - 21/09/2005 - INCLUSÃO DE VALIDAÇÃO DE ESTORNO DE CAMBIO

/*IF (!lCposAntecip .OR. SWA->WA_PO_DI != 'A') .AND. EasyGParam("MV_EASYFIN",,"N") == "S" .AND. cOpcaoMenu == 5
	MsgInfo(STR0152)  // "Cambio não pode ser estornado, pois há títulos de invoices gerados no financeiro."
	Return .F.
ENDIF*/
RETURN .T.

// Autor: Alex Wallauer
// Data : 15 Mar. 2001
*-------------------------------------------------------------------------------------------------------------*
FUNCTION EicCalcPagto(cChave,nValor_Inv,dDtEMB,dDtaVista,cCondPagDias,aTabInv,cNum,cPoNum,cTipoReg,lIgnoraPO,;
                      nValCom,lAtuM,aTotInv)
*-------------------------------------------------------------------------------------------------------------*
LOCAL nPercAux:=nVlr_Aux:=X:=nDias:=nPerc:=nValComAux:=0 ,n:=0
LOCAL cTabTipo:='',nInd:=SY6->(INDEXORD()),dDtEMB_Aux ,X
Local nParcs := FI400Parcs() //DFS - 06/06/11 - Chamada da função na variavel para tratar o sistema quando houver mais de 10 parcelas na condição de pagamento
PRIVATE lCondPa := .T.   //OS 0639/01 FCD
PRIVATE cTipoRegistro:= cTipoReg
DEFAULT lIgnoraPO:=.f.
aPRITabInv   :=aTabInv

IF(cPoNum==NIL,cPoNum:="",)
IF(nValCom==NIL,nValCom:=0,)
IF(lAtuM==NIL,lAtuM:=.T.,)

IF cCondPagDias # NIL .AND. !EMPTY(cCondPagDias)
   SY6->(DBSETORDER(1))
   IF !SY6->(DBSEEK(xFilial("SY6")+cCondPagDias))
      RETURN .F.
   ENDIF
   IF EasyEntryPoint("EICAP100") //OS 0639/01 FCD
      ExecBlock("EICAP100",.F.,.F.,"COND_PAG")
   ENDIF

   IF SY6->Y6_TIPOCOB == "4".AND.lCondPa  //OS 0639/01 FCD
      RETURN .F.
   ENDIF

   IF SY6->Y6_DIAS_PA >= 900
      nPercAux := 0
      FOR X = 1 TO nParcs
          nDias:= "Y6_DIAS_" + STRZERO(X,2)
          nDias:= SY6->(FIELDGET( FIELDPOS(nDias) ))
          nPerc:= "Y6_PERC_" + STRZERO(X,2)
          nPerc:= SY6->(FIELDGET( FIELDPOS(nPerc) ))
          IF nDias < 0
             nPercAux+=nPerc
          ENDIF
      NEXT
//      IF nPercAux = 100
//         RETURN .F.
//      ENDIF
   ENDIF
   SY6->(DBSETORDER(nInd))
ENDIF


DO CASE
   CASE SY6->Y6_DIAS_PA = -1

        nPos:=ASCAN(aTabInv,{|X|X[1]==cChave.AND.X[3]==dDtaVista .AND. if(lIgnoraPO,.t., X[6]==cPoNum)})
        IF nPos == 0 .OR. cTipoReg # NIL
           AADD(aTabInv,{cChave,nValor_Inv,dDtaVista,'A VISTA',cNum,cPoNum,nValCom})
           nPos:= LEN(aTabInv) // Precisa para o Rdmake
        ELSE
           aTabInv[nPos,2]+=nValor_Inv
           aTabInv[nPos,7]+=nValCom
        ENDIF
        IF EasyEntryPoint("EICAP100")
          ExecBlock("EICAP100",.F.,.F.,"TABINV")
        ENDIF

   CASE SY6->Y6_DIAS_PA >= 0 .AND. SY6->Y6_DIAS_PA < 900

        dDtEMBNew:=ProximoMes(dDtEMB,SY6->Y6_COD,SY6->Y6_DIAS_PA)

        nPos:=ASCAN(aTabInv,{|X|X[1]==cChave.AND.X[3]==(dDtEMBNew+SY6->Y6_DIAS_PA) .AND. if(lIgnoraPO,.t., X[6]==cPoNum)})
        IF nPos == 0.OR. cTipoReg # NIL
           AADD(aTabInv,{cChave,nValor_Inv,dDtEMBNew+SY6->Y6_DIAS_PA,'A PRAZO',cNum,cPoNum,nValCom})
           nPos:= LEN(aTabInv) // Precisa para o Rdmake
        ELSE
           aTabInv[nPos,2]+=nValor_Inv
           aTabInv[nPos,7]+=nValCom
        ENDIF

        IF EasyEntryPoint("EICAP100")
          ExecBlock("EICAP100",.F.,.F.,"TABINV")
        ENDIF

   OTHERWISE

       FOR X = 1 TO nParcs
          nPerc:= "Y6_PERC_"+STRZERO(X,2)
          nPerc:= SY6->(FIELDGET( FIELDPOS(nPerc) ))/ 100
          IF nPerc = 0
             LOOP
          ENDIF
          nDias:= "Y6_DIAS_"+STRZERO(X,2)
          nDias:= SY6->(FIELDGET( FIELDPOS(nDias) ))
          IF nDias < 0
             dDtEMB_Aux:= dDtEMB + nDias
             cTabTipo  := 'ANTECIPADO'
             /* wfs 19/07/2017 - assumir a data base como vencimento para a geração de títulos provisórios no ERP.
                Se a data do embarque for menor que a data base, assumir a data do embarque, o que impedirá que a parcela antecipada
                seja maior que a parcela póstecipada e forçará o usuário a revisar a data de embarque. */
             If AvFlags("AVINT_PR_EIC")
                If dDtEMB_Aux < dDataBase
                   If dDtEMB < dDataBase
                      dDtEMB_Aux:= dDtEMB
                   Else
                      dDtEMB_Aux:= dDataBase
                   EndIf
                EndIf
             EndIf
          ELSEIF nDias = 0
             dDtEMB_Aux:= dDtEMB
             cTabTipo  := 'NO EMBARQUE'
          ELSE
             dDtEMB_Aux:= dDtEMB + nDias
             cTabTipo  := 'A CONTAR DO EMBARQUE'
          ENDIF
          nPos:=ASCAN(aTabInv,{|X|X[1]==cChave.AND.X[3]==dDtEMB_Aux .AND. if(lIgnoraPO,.t., X[6]==cPoNum)})
          nVal_Inv_ad:= 0
		    //SVG - 30/11/2010 - Inserido array com o valor das parcelas separadas devido a problemas de arredondamento
          //TDF - 16/12/2011 - Tratamento nopado pois estava calculando errado o valor das parcelas de cambio quando o processo possuia mais de uma invoice.
          /*If Type("aTotInv") <> "U"
		       For n:= 1 to Len(aTotInv)
                nVal_Inv_ad += Round(aTotInv[n] * nPerc, 2)
             Next
             IF nPos == 0 .OR. cTipoReg # NIL
                AADD(aTabInv,{cChave,nVal_Inv_ad,dDtEMB_Aux,cTabTipo,cNum,cPoNum,Round(nValCom*nPerc,2)})
                nPos:= LEN(aTabInv) // Precisa para o Rdmake
             ELSE
                aTabInv[nPos,2]+= nVal_Inv_ad
                aTabInv[nPos,7]+=ROUND(nValCom*nPerc,2)
             ENDIF
             nVlr_Aux   += nVal_Inv_ad
             nValComAux += ROUND(nValCom*nPerc,2)
          Else  */
             IF nPos == 0 .OR. cTipoReg # NIL
                AADD(aTabInv,{cChave,ROUND(nValor_Inv*nPerc,2),dDtEMB_Aux,cTabTipo,cNum,cPoNum,Round(nValCom*nPerc,2)})
                nPos:= LEN(aTabInv) // Precisa para o Rdmake
             ELSE
                aTabInv[nPos,2]+=ROUND(nValor_Inv*nPerc,2)
                aTabInv[nPos,7]+=ROUND(nValCom*nPerc,2)
             ENDIF
             nVlr_Aux   += ROUND(nValor_Inv*nPerc,2)
             nValComAux += ROUND(nValCom*nPerc,2)
		    //EndIf
          //*** SVG - 30/11/2010 -
          IF EasyEntryPoint("EICAP100")
             ExecBlock("EICAP100",.F.,.F.,"TABINV")
          ENDIF

       NEXT

       IF nValor_Inv # nVlr_Aux .AND. ASCAN(aTabInv,{|X|X[1]==cChave}) # 0
          aTabInv[LEN(aTabInv),2] += (nValor_Inv - nVlr_Aux)
       ENDIF

       IF nValCom # nValComAux .AND. ASCAN(aTabInv,{|X|X[1]==cChave}) # 0
          aTabInv[LEN(aTabInv),2] += (nValCom - nValComAux)
       ENDIF

ENDCASE

If lAtuM
   M->WB_CPAGTO :=TRANSFORM(SY6->Y6_COD,'@R 9.9.999')+SPACE(01)+MSMM(SY6->Y6_DESC_P,42,1)
EndIf

// GCC - 27/05/2013 - Ponto de entrada utilizado para alterar valores no array aTabInv
If EasyEntryPoint("EICAP100")
	ExecBlock("EICAP100", .F., .F., "FINAL_EICCALCPAGTO")
EndIf

Return .T.

*-----------------------------------*
Static Function CondInv(cChave,lProc)
*-----------------------------------*
Local Wind //LRL 23/01/04
IF SY6->(DBSEEK(xFilial()+cChave))

   IF SY6->Y6_TIPOCOB == "4"
      If lProc
         MsgInfo(STR0040,STR0041) //'PAGAMENTO SEM COBERTURA CAMBIAL, NÇO PODE SER CADASTRADO.'###"Informa‡Æo"
      Else
         MsgInfo(STR0110+SW9->W9_INVOICE+CHR(13)+CHR(10)+STR0040,STR0041) //'PAGAMENTO SEM COBERTURA CAMBIAL, NÇO PODE SER CADASTRADO.'###"Informa‡Æo"
      EndIf
      RETURN .F.
   ENDIF

   M->WA_PER_JUR:=SY6->Y6_LIBORSP
   IF SY6->Y6_DIAS_PA > 0 .AND. SY6->Y6_DIAS_PA < 900
      M->WA_DIA_JUR := SY6->Y6_DIAS_PA
      IF M->WA_PER_IR # 0
         M->WA_DIA_IR  := SY6->Y6_DIAS_PA
      ELSE
         M->WA_DIA_IR  := 0
      ENDIF
   ENDIF

   _OkPagto:= .T.
   IF SY6->Y6_DIAS_PA >= 900
      xPerc := 0
      FOR Wind = 1 TO 10
          _Dias:= "Y6_DIAS_" + STRZERO(Wind,2) ; _Dias:= SY6->(FIELDGET( FIELDPOS(_Dias) ))
          _Perc:= "Y6_PERC_" + STRZERO(Wind,2) ; _Perc:= SY6->(FIELDGET( FIELDPOS(_Perc) ))

          IF _Dias < 0
             xPerc+=_Perc
          ENDIF
      NEXT
   ENDIF
ENDIF

Return .T.

*--------------------------------*
FUNCTION AP100GerAdi()
*--------------------------------*
Local _Valor := 0 ,nParc:= 0,_Dias:= 0,_Perc:= 0  ,Wind , oRateio
Local lPrimeiraVez:=.T.
Local lNewProforma := ChkFile("EYZ") .AND. ChkFile("EW0")
Local nProforma:= 0
Local lCredito := M->WA_PO_DI == "C", lGerSWB := .F.
//LRS - 29/08/2017 - Validação de frete e seguro
Local lFrete  := SW2->(FieldPos("W2_FREINC")) > 0 .And. SW2->W2_FREINC $ "2" .AND. AvRetInco(SW2->W2_INCOTER,"CONTEM_FRETE")
Local lSeguro := SW2->(FieldPos("W2_SEGINC")) > 0 .And. SW2->W2_SEGINC $ "2" .AND. AvRetInco(SW2->W2_INCOTER,"CONTEM_SEG")
//DFS - 08/05/13 - Variáveis para manipulação via ponto de entrada
Private dDataEmb:=CTOD("")
Private _nDias := 0

SW2->(DBSETORDER(1))

// GCC - 19/09/2013 - Tratamento para adiantamento vinculado a Fornecedor ou Credito por Fornecedor
If Left(M->WA_PO_DI,1) $ "F|C" 
   Return !SW2->(DBSEEK(xFilial("SW2")+Left(M->WA_HAWB,AvSX3("W2_PO_NUM",AV_TAMANHO)))) 
EndIf

If lCredito .AND. nOpca == 1  // Inclusão de registro
   GerAdiCred(@lGerSWB)
   If lGerSWB
      Return .T.
   EndIf
EndIf

SW2->(DBSEEK(xFilial("SW2")+Left(M->WA_HAWB,AvSX3("W2_PO_NUM",AV_TAMANHO))))

IF SY6->(DBSEEK(xFilial("SY6")+SW2->W2_COND_PA+STR(SW2->W2_DIAS_PA,3,0)))

   IF SY6->Y6_TIPOCOB == "4" .OR. SY6->Y6_DIAS_PA < 900
      MSGINFO(STR0153,STR0043)  // "Nao ha adiantamentos nesta PO"
      Return .f.
   ELSE
      IF lPrimeiraVez
         lPrimeiraVez:=.F.
         SW3->(DBSETORDER(1))
         SW3->(DBSEEK(xFilial("SW3")+SW2->W2_PO_NUM))
         dDataEmb:=SW3->W3_DT_EMB
         DO WHILE SW3->(!EOF()) .AND. xFilial("SW3")=SW3->W3_FILIAL .AND. SW3->W3_PO_NUM = SW2->W2_PO_NUM
            IF SW3->W3_SEQ # 0 .OR. EMPTY(SW3->W3_DT_EMB)
               SW3->(DBSKIP())
               LOOP
            ENDIF
            IF SW3->W3_DT_EMB < dDataEmb
               dDataEmb := SW3->W3_DT_EMB
            ENDIF
            SW3->(DBSKIP())
            LOOP
         ENDDO
         IF EMPTY(dDataEmb)
            dDataEmb:=SW2->W2_PO_DT
         ENDIF
      ENDIF
      //LRS - 29/08/2017 - Validações adicionado de frete e seguro por variavel
      //If SW2->(FieldPos("W2_FREINC")) > 0 .And. SW2->W2_FREINC $ "2" .AND. AvRetInco(SW2->W2_INCOTER,"CONTEM_FRETE")
      //   oRateio := EasyRateio():New(((ValorPed()+SW2->W2_INLAND+SW2->W2_FRETEIN+SW2->W2_PACKING+SW2->W2_OUT_DES)-SW2->W2_DESCONT),100,10,2)
      //Else
         oRateio := EasyRateio():New(((ValorPed()+SW2->W2_INLAND+SW2->W2_PACKING+SW2->W2_OUT_DES+If(lseguro,SW2->W2_SEGURIN,0);
         +IF(lFrete,SW2->W2_FRETEIN,0))-SW2->W2_DESCONT),100,10,2)
      //EndIf

      xPerc := 0
      _Valor := 0
      nParc  := 0
      FOR Wind = 1 TO 10

          _Dias:= "Y6_DIAS_" + STRZERO(Wind,2)
          _Dias:= SY6->(FIELDGET( FIELDPOS(_Dias) ))
          _Perc:= "Y6_PERC_" + STRZERO(Wind,2)
          _Perc:= SY6->(FIELDGET( FIELDPOS(_Perc) ))

          IF _Dias < 0
             nParc += 1
             _Valor:= _Valor+(((ValorPed()+SW2->W2_INLAND+SW2->W2_FRETEIN+SW2->W2_PACKING+SW2->W2_OUT_DES)-SW2->W2_DESCONT)*(_Perc/100))

             TRB->(DBAPPEND())
             TRB->WB_HAWB    := M->WA_HAWB
             //TRB->WB_EVENT   := PRINCIPAL	//AOM - 04/07/2012
             TRB->WB_EVENT   := IF(!AvFlags("EIC_EAI"),PRINCIPAL,ADIANT_EAI) //Jacomo Lisa - 25/06/2014 - Quando integrado com Logix, enviar o codigo 609 ao invez de 101
	         TRB->WB_PO_DI   := Left(M->WA_PO_DI,1)//"A"
	         TRB->WB_DT_DIG  := dDataBase
             TRB->WB_TIPOREG := 'P'
             TRB->WB_DT_VEN  := dDataEmb+_Dias  //SW2->W2_PO_DT +(-(_Dias))

             //SVG - 08/05/09 -
             //LRS - 08/04/2016 - Subistituido Round por NoRound
             //If SW2->(FieldPos("W2_FREINC")) > 0 .And. SW2->W2_FREINC $ "2" .AND. AvRetInco(SW2->W2_INCOTER,"CONTEM_FRETE") /* FDR - 23/12/10*/ //SW2->W2_INCOTER $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP"
             //   TRB->WB_PGTANT  := NoRound((((ValorPed()+SW2->W2_INLAND+SW2->W2_FRETEIN+SW2->W2_PACKING+SW2->W2_OUT_DES)-SW2->W2_DESCONT)*(_Perc/100)),2)
             //Else
             //   TRB->WB_PGTANT  := NoRound((((ValorPed()+SW2->W2_INLAND+SW2->W2_PACKING+SW2->W2_OUT_DES)-SW2->W2_DESCONT)*(_Perc/100)),2)
             //EndIf

             TRB->WB_PGTANT  := oRateio:GetItemRateio(_Perc)

             //TRB->WB_PGTANT  := NoRound(TRB->WB_PGTANT,2)
             nTotPgtAnt += TRB->WB_PGTANT    // GFP - 19/07/2013

             //TRP - 01/03/2013 - Ajuste na exibição do Número da Proforma Invoice no Controle de Câmbio.
             nProforma:= 0
             If lNewProforma
                EYZ->(DbSetOrder(1))
                If EYZ->(DbSeek(xFilial("EYZ")+ SW2->W2_PO_NUM ))
                   Do While !EYZ->(EOF()) .AND. EYZ->EYZ_FILIAL == xFilial("EYZ") .AND. EYZ->EYZ_PO_NUM == SW2->W2_PO_NUM
                      nProforma += 1
                      EYZ->(DbSkip())
                   Enddo
                   If nProforma > 1
                      TRB->WB_INVOICE := Alltrim(SW2->W2_NR_PRO)+"....."
                   Else
                      TRB->WB_INVOICE := SW2->W2_NR_PRO
                   Endif
                Else
                   TRB->WB_INVOICE := SW2->W2_NR_PRO
                Endif
             Else
                TRB->WB_INVOICE := SW2->W2_NR_PRO
             Endif

             TRB->WB_MOEDA   := SW2->W2_MOEDA
             TRB->WB_FORN    := SW2->W2_FORN
             IF EICLOJA()
                TRB->WB_LOJA := SW2->W2_FORLOJ
             ELSE //SVG - 28/10/2010 - Tratamento para o preenchimento do campo Loja do SWB para quem não tem novo tratamento EICLOJA
                If SA2->(DbSeek(xFilial("SA2")+SW2->W2_FORN))
                   TRB->WB_LOJA := SA2->A2_LOJA
                EndIf
             ENDIF
             TRB->WB_TP_CON := "2"  //TRP-08/05/08
             TRB->TRB_ALI_WT := "SWB"
             TRB->TRB_REC_WT := SWB->(Recno())
             xPerc+=_Perc
             //DFS - 08/05/13 - Ponto de Entrada para manipulação de adiantamento
             _nDias := _Dias
             IF(EasyEntryPoint("EICAP100"),Execblock("EICAP100",.F.,.F.,"GRV_TRB_ADIANTAMENTO"),)
             _Dias := _nDias
          ENDIF
      NEXT
      IF xPerc == 0
         msginfo(STR0153,STR0043)  // "Nao ha adiantamentos nesta PO"
         Return .f.
      ENDIF
   ENDIF
Else
    Help(" ",1,"AVG0005367")//LRL 08/01/04 msginfo("Nao existe Condicao de Pagamento Cadastrada.",STR0043)
    Return .f.
ENDIF

Return .t.
*-----------------------------------------*
Function AP100POsAdto(lHelp, lPag, cTipoAdt)
*------------------------------------------*
Local oDlg
Local nSaldo:= 0
Local aTb_Campos:={}
Local i
Local nTamChave
Local oBrowse
Local aStruct := {}
Local aColunas:= {}
Local aSeek   := {}
Local aFields := {}
Local aCampos := {"WB_FILORI","WB_NUMPO","WB_PO_DI","WB_LINHA","WB_HAWB","W2_MOEDA","WB_PGTANT","WB_CA_NUM"}
Local oColumn
Local nI

Private cMoedaProc:=''
Private b2Click:={|| AP100CriaParc(lHelp,,If(lAdtMultFil,Work1->WB_FILORI,NIL)), oDlg:End() }
Private bOK    :=b2Click//AWR - 29/09/2010 - O botao de OK tem que fazer o mesmo do 2 clique no MSSELECT pq pode ter mais de 1 parcela
           //AWR - 29/09/2010 - Correcao do seguinte erro: Incluindo o adiantamento pelo botao OK somava todas parcelas e incluia a linha 0001 do PO depois pelo 2 clique conseguia incluir novamente a parcela da linha 0002 do PO que ja estava somada.
Private aSWA_OLD  := {}
Private aTRB_OLD  := {}

If !PosAdtExBlock()   // GFP - 16/12/2013
    Return .F.
EndIf

If  TRB->WB_PO_DI == "D" .and. TRB->WB_EVENT != "101"
   MsgInfo(STR0414)  // "O evento selecionado não é 1-Principal. Não será possível prosseguir com a operação de Associar um Pagamento Antecipado."
   Return .F.
EndIf

If  TRB->WB_PO_DI == "D" .and. Left(TRB->WB_TIPOREG,1) == "P"
   MsgInfo(STR0276)  // "Selecione uma parcela a pagar"
   Return .F.
EndIf

If  TRB->WB_PO_DI == "D" .and. Left(TRB->WB_TIPOREG,1) != "P" .And. (TRB->WB_FOBMOE == 0 .Or. !Empty(TRB->WB_CA_DT))
   MsgInfo(STR0415)  // "Parcela não possui saldo para compensação."
   Return .F.
EndIf

//THTS - 11/10/2019 - Caso tenha sido alterado o tamanho dos campos de HAWB, INVOICE ou PO, o tamanho do campo CHAVE deve ser ajustado para contemplar todos os campos da chave abaixo
nTamChave := AVSX3("WB_HAWB",3) + AVSX3("WB_PO_DI",3) + AVSX3("WB_INVOIC",3) + AVSX3("WB_FORN",3) + AVSX3("WB_LOJA",3) + AVSX3("WB_LINHA",3)
If nTamChave > AVSX3("WB_CHAVE",3) .Or. nTamChave > AVSX3("WB_PGTASS",3)
    MsgInfo(StrTran(STR0393, "XXX", AllTrim(Str(nTamChave)));//"Para utilizar o Pagamento Antecipado, o tamanho dos campos 'Chave' (WB_CHAVE/WB_PGTASS) deve ser maior ou igual a XXX."
	+ENTER + STR0394;//"Estes campos 'Chave' são compostos pelos campos 'Processo \ Tipo \ Invoice \ Cod. Forn. \ Loja \ Linha'."
	+ENTER + STR0395)//"Para habilitar o Pagamento Antecipado, será necessário configurar o tamanho dos campos 'Chave' (WB_CHAVE / WB_PGTASS), através do Módulo Configurador."
    Return .F.
EndIf

IF AvFlags("EAI_PGANT_INV_NF") .AND. SW6->(DBSEEK(xFilial("SW6")+TRB->WB_HAWB)) .AND. EMPTY(SW6->W6_DT_NF)
   MSGALERT(STR0370, STR0079) //"O adiantamento não pode ser compensado sem que o processo possua emissão da nota fiscal.", "Aviso"
   RETURN .F.
ENDIF

DbSelectArea("SWA")//JL
FOR i := 1 TO FCount()
    AADD(aSWA_OLD,{(FIELDNAME(i)) , FieldGet(i)  })
NEXT i

DbSelectArea("TRB")//JL
aAdd(aTRB_Old,{TRB->(RecNo()),{}})
FOR i := 1 TO FCount()
    AADD(aTRB_Old[Len(aTRB_Old)][2],{(FIELDNAME(i)) , FieldGet(i)  })
NEXT  i

If !AP100GrvWork(@nSaldo, lPag, cTipoAdt)
    Return .F.
EndIf

IF(EasyEntryPoint("EICAP100"),Execblock("EICAP100",.F.,.F.,"ANTES_ADTO"),) //igor chiba 17/09/09

If lAdtMultFil
   AADD(aTB_Campos,{"WB_FILORI", , AVSX3("WA_FILORI",5), AVSX3("WA_FILORI", 6)})
EndIf

AADD(aTB_Campos,{"WA_PO_DI" , , AVSX3("WB_PO_DI" ,5)					   })
AADD(aTB_Campos,{"WB_NUMPO" , , AVSX3("WB_NUMPO" ,5)					   })
AADD(aTB_Campos,{"WB_CA_NUM", , AVSX3("WB_CA_NUM",5), AVSX3("WB_CA_NUM", 6)}) // GFP - 19/02/2013
AADD(aTB_Campos,{"W2_MOEDA" , , AVSX3("W2_MOEDA" ,5)					   })
AADD(aTB_Campos,{"WA_PGTANT", , AVSX3("WA_PGTANT",5), AVSX3("WA_PGTANT", 6)})
AADD(aTB_Campos,{"WA_SLDANT", , AVSX3("WA_SLDANT",5), AVSX3("WA_SLDANT", 6)})

For nI := 1 to Len(aCampos)
  /* Campos usados no filtro */
   AAdd(aFields, {aCampos[nI] ,AvSx3(aCampos[nI]    , AV_TITULO), AvSx3(aCampos[nI]    , AV_TIPO) , AvSx3(aCampos[nI]    , AV_TAMANHO) , AvSx3(aCampos[nI]    , AV_DECIMAL), AvSx3(aCampos[nI]   ,AV_PICTURE)})    
Next nI
//"WB_FILORI+WB_NUMPO
AAdd(aSeek, {AvSx3("WB_FILORI", AV_TITULO) + " + " + AvSx3("WB_NUMPO", AV_TITULO),;
               {{"", AvSx3("WB_FILORI", AV_TIPO), AvSx3("WB_FILORI", AV_TAMANHO), AvSx3("WB_FILORI", AV_DECIMAL), AvSx3("WB_FILORI", AV_TITULO)},;
                {"", AvSx3("WB_NUMPO" , AV_TIPO), AvSx3("WB_NUMPO" , AV_TAMANHO), AvSx3("WB_NUMPO" , AV_DECIMAL), AvSx3("WB_NUMPO" , AV_TITULO)}}, 3})

IF Work1->(Easyreccount("Work1")) # 0
   If TemSaldoAdt("Work1")
      Work1->(DbClearFilter())  //NCF - 29/04/2011 - Filtro de Fornecedores e Moeda dos Pagamentos de Adiantamento
      Work1->(DbSetFilter({||TRB->WB_FORN == Work1->W2_FORN .And. TRB->WB_MOEDA == Work1->W2_MOEDA},"TRB->WB_FORN == Work1->W2_FORN .And. TRB->WB_MOEDA == Work1->W2_MOEDA"))

      DEFINE MSDIALOG oDlg TITLE STR0232 FROM DLG_LIN_INI, DLG_COL_INI To DLG_LIN_FIM, DLG_COL_FIM OF oMainWnd PIXEL // "Pagamentos Antecipados"
      
      oBrowse := FWBrowse():New(oDlg)
      oBrowse:SetDataTable(.T.)
      oBrowse:SetAlias("Work2")
      oBrowse:SetDescription(STR0409 + TRB->WB_PARCELA + STR0410 + Alltrim(Transform(TRB->WB_FOBMOE,AvSx3("WB_FOBMOE",AV_PICTURE)))) //"Selecione o Pagamento Antecipado para associar com a parcela: "####" – Valor: "
      
      aStruct := Work2->(dbStruct())
      aColunas:= {}
      For nI := 1 To Len(aCampos)
         
         If (nPos := aScan(aStruct,{|x| x[1] == aCampos[nI]})) > 0

               oColumn := FWBrwColumn():New()

               oColumn:SetType(AvSX3(aStruct[nPos,1])[2])
               oColumn:SetTitle(Alltrim(RetTitle(aStruct[nPos,1])))
               oColumn:SetSize(aStruct[nPos,3])
               oColumn:SetDecimal(aStruct[nPos,4])
               oColumn:SetPicture(AvSX3( aStruct[nPos][1], 6, "Work2" ))
      
               If AvSX3(aStruct[nPos,1])[2] == "D"
                  oColumn:SetData(&('{ || DToC(' + Work2->(aStruct[nPos,1]) + ') }'))
               Else
                  oColumn:SetData(&('{ || ' + Work2->(aStruct[nPos,1]) + ' }'))
               EndIf

               aAdd(aColunas,oColumn)

               If aCampos[nI] == "WB_PGTANT" //QUando adicionar o campo WB_PGTANT, adiciona mais um com as mesmas caracteristicas para o campo TRB_VLVINC
                  oColumn := FWBrwColumn():New()

                  oColumn:SetType(AvSX3(aStruct[nPos,1])[2])
                  oColumn:SetTitle(STR0411) //"Vlr a Associar"
                  oColumn:SetSize(aStruct[nPos,3])
                  oColumn:SetDecimal(aStruct[nPos,4])
                  oColumn:SetPicture(AvSX3( aStruct[nPos][1], 6, "Work2" ))
                  oColumn:SetData(&('{ || TRB_VLVINC }'))

                  aAdd(aColunas,oColumn)
               EndIf
         EndIf
      Next nI
      oBrowse:SetColumns(aColunas)
      oBrowse:SetLocate() 
      oBrowse:SetFieldFilter(aFields)
      oBrowse:AddFilter('Default',"Work2->WB_NUMPO <> ' ' .And. Work2->W2_MOEDA == TRB->WB_MOEDA",.T.,.T.)
      oBrowse:SetUseFilter()
      oBrowse:SetSeek(, aSeek)
      
      oBrowse:Activate()
      oDlg:lMaximized := .T. 
      ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| AP100CriaParc(lHelp,.F.,If(lAdtMultFil,Work2->WB_FILORI,NIL)), oDlg:End() },{|| oDlg:End() },,)) CENTERED 
         
   Else
      MSGINFO(STR0396) //Não há saldo disponível para prosseguir com a vinculação/compensação da parcela 
   EndIf   
Else
   MSGINFO(STR0154,STR0043)  // "Nao foram encontrados adiantamentos para este processo!"
Endif

Work1->(DbClearFilter())

Return .T.

Static Function PosAdtExBlock()
Local lRet := .T.
Private lExit := .F.

   If EasyEntryPoint("EICAP100")
      ExecBlock("EICAP100", .F., .F., "POSADTO_VALID")
      If lExit
         lRet := .F.
      EndIf
   EndIf

Return lRet

*-----------------------------------------*
Function AP100GrvWork(nSaldo, lPagAnt, cTipoAdt)
*------------------------------------------*
Local cFilSW7  :=xFilial("SW7")
Local cFilSW2  :=xFilial("SW2")
Local cFilSWA  :=xFilial("SWA")
Local cFilSWB  :=xFilial("SWB")

LOCAL nRecSWA  :=SWA->(RECNO())
LOCAL aPOs  := {}
Local nPo //LRL 23/01/04
Local nValPgtAnt := 0
Local lDelWORK   :=.F.  //igor chiba 29/09/09
Local aOrdSW2 := {}
nSaldo:=0

//** GCC - 10/09/2013 - Tratamento referente a tipo de adiantamento
Default lPagAnt := .F.

If lPagAnt
	cTipAd:= cTipoAdt
	If ADIANT_PO == cTipoAdt	    // 01 - Adiantamento vinculado a PO
		Work1->(avzap())
		Work2->(avzap())
	ElseIf ADIANT_FOR == cTipoAdt	// 02 - Adiantamento vinculado a Fornecedor
		Return AP100ForAD()
	ElseIf CREDITO == cTipoAdt		// 03 - Adiantamento Via Crédito
		Return AP100CrtAD()
	ElseIf cTipoAdt == "99"
		Work1->(avzap())
		Work2->(avzap())
		Return .F.
	EndIf
EndIf
//**

SW7->(DBSETORDER(1))
IF SW7->(DBSEEK(xFilial()+M->WA_HAWB))
	SW2->(DBSETORDER(1))
	SW2->(DBSEEK(xFilial()+SW7->W7_PO_NUM))
	cMoedaProc:=SW2->W2_MOEDA
	// EOS - Cria array com todas as POS do processo
	DO WHILE !SW7->(EOF())	.AND. SW7->W7_Filial == cFilSW7 ;
							.AND. SW7->W7_HAWB   == M->WA_HAWB
		IF ASCAN( aPOs, SW7->W7_PO_NUM ) == 0
			AADD( aPOs, SW7->W7_PO_NUM )
		ENDIF
		SW7->(dbSkip())
	ENDDO
ENDIF

If(EasyEntryPoint("EICAP100"),Execblock("EICAP100",.F.,.F.,"GRV_WORK"),)  // GFP - 07/11/2013

aOrdSW2 := SaveOrd({"SW2"})	//NCF - 29/04/2011

SWB->(DBSETORDER(5))

SWA->(DBSETORDER(1))
FOR nPo:=1 TO LEN(aPOs)
	SWA->(DBSEEK(cFilSWA+AvKey(aPOs[nPO],"WA_HAWB")+"A"))
	DO While !SWA->(Eof()) .And. SWA->WA_FILIAL        == cFilSWA   .AND. ;
								 AvKey(SWA->WA_HAWB,"W2_PO_NUM") == aPOs[nPO] .AND. ;
								 SWA->WA_PO_DI=='A'
		IF (lPagAnt .And. SWA->WA_SLDANT > 0) .Or. !lPagAnt //THTS - 19/02/2018 - Se for compensacao (lPagAnt) so carrega a work com os adt com saldo. Se nao for compensacao (!lPagAnt) carrega mesmo sem saldo
			IF !Work1->(DBSEEK(SWA->WA_HAWB)) .AND. SW2->(DBSEEK(cFilSW2+ AvKey(SWA->WA_HAWB,"W2_PO_NUM")))	//Seek do Pedido antecipado 
				Work1->(DBAPPEND())
				Work1->WA_PO_DI := "A" //BSCXBOX("WA_PO_DI", SWA->WA_PO_DI)
				Work1->WB_NUMPO := SWA->WA_HAWB
				Work1->WA_PGTANT:= SWA->WA_PGTANT//Valor total do Pedido
				Work1->WA_SLDANT:= SWA->WA_SLDANT - ApuSldWork1(SWA->WA_HAWB)	//Saldo do Pedido	//NCF - 03/08/2010 - Reapuração do Saldo de adiantamento da Work1
				//Work1->WA_SLDANT:= SWA->WA_PGTANT - ApuSldWork1(SWA->WA_HAWB)
				Work1->WB_PGTANT:= SWA->WA_SLDANT								//Saldo disponivel para a alteracao do Processo
				Work1->W2_MOEDA := SW2->W2_MOEDA
				Work1->TRB_ALI_WT:= "SWA"
				Work1->TRB_REC_WT:= SWA->(Recno())

				SW2->(DbSeek(xFilial("SW2")+AvKey(aPOs[nPO],"W2_PO_NUM")))      //NCF - 29/04/2011 - Grava o Fornecedor para filtro na tela dos adiantamentos
				Work1->W2_FORN := SW2->W2_FORN
				RestOrd(aOrdSW2)

				SWB->(DBSETORDER(1))   // GFP - 19/02/2013
				If SWB->(DBSEEK(cFilSWB+SWA->WA_HAWB+SWA->WA_PO_DI))
					Work1->WB_CA_NUM := SWB->WB_CA_NUM
                     //MFR 24/04/2019 OSSME-2859
                    Work1->WB_NUMDUP := SWB->WB_NUMDUP
				EndIf

            If lAdtMultfil
               Work1->WB_FILORI := SWA->WA_FILIAL       //NCF - 28/03/2018        
            EndIf

				SWB->(DBSETORDER(1/*5*/))
				SWB->(DBSEEK(cFilSWB+SWA->WA_HAWB+SWA->WA_PO_DI))  //NCF - 30/04/2018
				DO While !SWB->(Eof()) .And. SWB->WB_FILIAL == cFilSWB .And. SWB->WB_HAWB == SWA->WA_HAWB .And. SWB->WB_PO_DI == SWA->WA_PO_DI //SWB->WB_NUMPO  == SWA->WA_HAWB
					//**igor chiba nao apendar dados se uma parcela nao tiver titulo ERP 29/09/09
					IF LCAMBIO_EIC  .AND.  lEICFI05
					//IF EMPTY(SWB->WB_TITERP)
					//IF IIF(lIntegStat, SWB->WB_TITRET$cNao, EMPTY(SWB->WB_TITERP) )  // PLB 15/04/10 - Status de Retorno do ERP
						IF IIF(lIntegStat, SWB->WB_TITRET$cNao, .F. )  // PLB 15/04/10 - Status de Retorno do ERP
							lDelWORK:=.T.
							EXIT
						ENDIF
					ENDIF
					//**

					If lAdVinculado .And. !Empty(SWB->WB_CHAVE)// .OR. M->WA_HAWB == SWB->WB_HAWB
						SWB->(dbSkip())
						LOOP
					EndIf

                    Work2->(DBAPPEND())
					Work2->WB_HAWB  := SWB->WB_HAWB
					Work2->WB_NUMPO := SWB->WB_NUMPO
					Work2->W2_MOEDA := SW2->W2_MOEDA
					Work2->WB_PGTANT:= SWB->WB_PGTANT
               Work2->WB_NUMDUP:= SWB->WB_NUMDUP
					Work2->TRB_ALI_WT:= "SWB"
					Work2->TRB_REC_WT:= SWB->(Recno())

					IF M->WA_HAWB == SWB->WB_HAWB
						Work1->WB_PGTANT += SWB->WB_PGTANT
					ENDIF
					//** PLB 06/09/07
					Work2->WB_LINHA  := SWB->WB_LINHA
					Work2->WB_CA_NUM := SWB->WB_CA_NUM
					//**
                    If lAdtMultfil
                        Work2->WB_FILORI := SWA->WA_FILIAL       //NCF - 28/03/2018        
                    EndIf

                    Work2->WB_PO_DI := SWB->WB_PO_DI            //NCF - 30/04/2018

					SWB->(dbSkip())
				EndDo

				SWB->(DBSETORDER(1))
				SWB->(DBSEEK(cFilSWB+SWA->WA_HAWB+'A'))
				DO While !SWB->(Eof()) .And. SWB->WB_FILIAL == cFilSWB .And. SWB->WB_HAWB == SWA->WA_HAWB .AND. SWB->WB_PO_DI  == 'A'
					IF EMPTY(SWB->WB_CA_DT)
						SWB->(dbSkip())
						LOOP
					ENDIF
					//** PLB 06/09/07 - Não incluir caso todo o saldo já esteja vinculado em um processo
					nValPgtAnt := SWB->WB_PGTANT
					Work2->( DBSetOrder(1) )
					If Work2->( DBSeek(If(lAdtMultfil,SWB->WB_FILORI,"")+SWB->(WB_HAWB+WB_PO_DI) ))
						Do While Work2->( !EoF()  .And.  WB_NUMPO == SWB->WB_HAWB .And. WB_PO_DI ==  SWB->WB_PO_DI )    //NCF - 30/04/2018
							If !Empty(Work2->WB_HAWB)  .And.  SWB->WB_LINHA == Work2->WB_LINHA
								nValPgtAnt -= Work2->WB_PGTANT
							EndIf
						    Work2->( DBSkip() )
						EndDo
					EndIf

					// JVR - 22/03/10
					If lAdVinculado
						nValPgtAnt -= ApuValWork2(If(lAdtMultfil,SWA->WA_FILIAL,NIL))
					EndIf

					If nValPgtAnt <= 0
						SWB->( DBSkip() )
						Loop
					EndIf


					//**igor chiba nao apendar dados se uma parcela nao tiver titulo ERP 29/09/09
					IF LCAMBIO_EIC .AND. lEICFI05
					//IF EMPTY(SWB->WB_TITERP)
						//IF IIF(lIntegStat, SWB->WB_TITRET$cNao, EMPTY(SWB->WB_TITERP) )  // PLB 15/04/10 - Status de Retorno do ERP
						IF IIF(lIntegStat, SWB->WB_TITRET$cNao, .F. )  // PLB 15/04/10 - Status de Retorno do ERP
							lDelWORK:=.T.
							EXIT
						EndIf
					EndIf
					//**

					//**
					Work2->(DBAPPEND())
					Work2->WB_NUMPO := SWA->WA_HAWB
					Work2->W2_MOEDA := SW2->W2_MOEDA
					//Work2->WB_PGTANT:= SWB->WB_PGTANT
					//** PLB 06/09/07 - Possibilitar vinculação de cada parcela de um adiantamento separadamente
					Work2->WB_PGTANT := nValPgtAnt
               Work2->TRB_VLVINC:= IIF(TRB->WB_FOBMOE > Work2->WB_PGTANT,Work2->WB_PGTANT,TRB->WB_FOBMOE)
					Work2->WB_LINHA  := SWB->WB_LINHA
					Work2->WB_CA_NUM := SWB->WB_CA_NUM
					//**
               If lAdtMultfil
                  Work2->WB_FILORI := SWA->WA_FILIAL       //NCF - 28/03/2018        
               EndIf

               Work2->WB_PO_DI := SWB->WB_PO_DI            //NCF - 30/04/2018

					Work2->TRB_ALI_WT:= "SWB"
					Work2->TRB_REC_WT:= SWB->(Recno())
					SWB->(dbSkip())
             	ENDDO
			EndIf
			If cMoedaProc == Work1->W2_MOEDA
				nSaldo += SWA->WA_SLDANT
			ENDIF
		EndIf

		//** igor chiba deletando work1 caso seus cambios nao tenham n°tit erp 29/09/09
		If LCAMBIO_EIC
			If lDelWork
				WORK1->(RECLOCK('WORK1',.F.))
				WORK1->(DBDELETE())
				lDelWORK:=.F.
			EndIf
		EndIf
		//**
		SWA->(dbSkip())
	ENDDO
NEXT

SWA->(DBSETORDER(1))
SWB->(DBSETORDER(1))
SWA->(DBGOTO(nRecSWA))

Return .T.


*----------------------------------*
Function AP100Hist(lSelecao,lHelp)
*----------------------------------*
Local oDlg,oM
LOCAL aTb_Campos:={}

// PLB 06/09/07
Local cTitle := ""
Local lRet := .F.
Local nLinhaIni := nLinhaFim := nColumIni := nColumFim := 0
Default lSelecao := .F.  //Informa se é para exibição ou para seleção de itens

If lSelecao
   cTitle := STR0379  //STR0232  // "Pagamentos Antecipados"
Else
   cTitle := STR0155  // "Processos Antecipados"
EndIf

IF Work2->(DBSEEK(  If(lAdtMultFil,Work1->(WB_FILORI+WB_NUMPO+WA_PO_DI),Work1->(WB_NUMPO+WA_PO_DI))  )) //NCF - 30/04/2018
   If lAdtMultFil
      AADD(aTB_Campos,{"WB_FILORI",,AVSX3("WA_FILORI",5),AVSX3("WA_FILORI", 6)})
   EndIf
   AADD(aTB_Campos,{"WB_NUMPO" ,,AVSX3("WB_NUMPO" ,5)})
   //** PLB 06/09/07
   If lSelecao
      AADD(aTB_Campos,{"WB_LINHA",,AVSX3("WB_LINHA",5)})
   EndIf
   //**
   AADD(aTB_Campos,{"WB_HAWB"  ,,AVSX3("WB_HAWB"  ,5)})
   AADD(aTB_Campos,{"W2_MOEDA" ,,AVSX3("W2_MOEDA" ,5)})
   AADD(aTB_Campos,{"WB_PGTANT",,AVSX3("WB_PGTANT",5),AVSX3("WB_PGTANT",6)})
   //** PLB 06/09/07
   If lSelecao
      AADD(aTB_Campos,{"WB_CA_NUM",,AVSX3("WB_CA_NUM",5)})
   EndIf
   //**
   nLinhaFim := 20
   nColumFim := 100 //70
   //DEFINE MSDIALOG oDlg TITLE STR0155 FROM 0,0 To 20,50 OF oMainWnd  // "Processos Antecipados" 
   DEFINE MSDIALOG oDlg TITLE cTitle FROM nLinhaIni,nColumIni To nLinhaFim,nColumFim OF oMainWnd

      oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165)
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
    //by GFP - 28/09/2010 :: 14:51 - Inclusão da função para carregar campos criados pelo usuario.
    aTb_Campos := AddCpoUser(aTb_Campos,"Work2","2")

    Work2->(DBGOTOP())
    oM:=MsSelect():New("Work2",,,aTb_Campos,.F.,"XX",{01,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2},"AP100Filtro","AP100Filtro")
    oM:oBrowse:bwhen:={||dbSelectArea("Work2"),.T.}
    //** PLB 06/09/07
    oM:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
    If lSelecao
       oM:bAval:={|| IIF( AP100CriaParc(lHelp,.F.,If(lAdtMultFil,Work1->WB_FILORI,NIL)), ( oDlg:End(), lRet:=.T. ), ),oM:oBrowse:Refresh() }
    EndIf
    //**

   ACTIVATE MSDIALOG oDlg ON INIT (oM:oBrowse:Refresh()) CENTERED
Else
   MSGINFO(STR0156,STR0043)  // "Nao foram encontrados Processos com este Pedido"
Endif

Return lRet

*--------------------------------------*
Function AP100CriaParc(lHelp,lOneParc,cFilSWB)
*--------------------------------------*

LOCAL lRet:= .T.

// PLB 06/09/07 - Caso haja mais de uma parcela busca por parcela especifica
//Local cFilSWB := xFilial("SWB")

//JVR - 15/03/10
Local nTRBRecno:= 0

// GCC - 12/09/2013
Local cPo := ""
Local cTipo

Local nRecParcPag
Local nRecParcAD
Local nValParcPag
Local cChave:=cChaveAd:=cAux := ""
Default cFilSWB := xFilial("SWB")
// SVG - 18/02/2010 -
If lAdVinculado
   If Left(TRB->WB_TIPOREG,1) == "P"
      Alert(STR0276) //STR0276 "Selecione uma parcela a pagar."
      Return .F.
   EndIf
   //MCF 09/08/2016 - Guarda Recno() e Valor da parcela selecionada
   //Guarda o Recno da parcela a pagar
   nRecParcPag := TRB->(Recno()) //Work2->(Recno()) //MCF - 21/07/2016
   //Guarda o valor da parcela
   //RMD - 05/12/16 - Caso não tenha mais de um adiantamento no pedido considera o valor da TRB.
   //If ValType(lOneParc) <> "L" .Or. lOneParc
      nValParcPag := TRB->WB_FOBMOE //WHRS 2017 - 505035 / MTRADE-501 - Problema ao compensar adiantamento com mais de uma parcela no EIC.
   /*Else
      nValParcPag := Work2->WB_PGTANT//TRB->WB_FOBMOE
   EndIf*/
EndIf
Default lOneParc := .T.

//SW7->(DBSEEK(xFilial()+M->WA_HAWB))
//SW2->(DBSEEK(xFilial()+SW7->W7_PO_NUM))
//IF Work1->W2_MOEDA # SW2->W2_MOEDA
//   MSGINFO("Moeda do Pedido difere da moeda do Processo.")
//   RETURN .F.
//ENDIF

IF lHelp
   RETURN .T.
ENDIF

IF TYPE("oObj:obrowse") # 'O'
   RETURN .T.
ENDIF
If lAdtMultFil
   Work1->(dbSetOrder(2)) //WB_FILORI+WB_NUMPO+WA_PO_DI
   Work1->(dbSeek(Work2->WB_FILORI + Work2->WB_NUMPO + Work2->WB_PO_DI))
Else
   Work1->(dbSetOrder(1)) //WB_NUMPO+WA_PO_DI
   Work1->(dbSeek(Work2->WB_NUMPO + Work2->WB_PO_DI))
EndIf
/*
//RMD - 13/01/17 - Obtem o valor a ser vinculado no início da função e, caso o usuário cancele, aborta a execução.
If lAdVinculado .And. !(nValVinc := DefValVinculado(nValParcPag)) > 0
	Return .F.
EndIf
*/
nValVinc := Work2->TRB_VLVINC //Valor a ser compensado
nTRBRecno := TRB->(RECNO())//JVR - 15/03/10

TRB->(DBSETORDER(2))
IF lRet .AND. (!TRB->(DBSEEK(Work1->WB_NUMPO+IIF(lOneParc,"",Work2->WB_LINHA))) .Or. lAdVinculado)

   //** PLB 06/09/07
   If !lOneParc  .And.  !Empty(Work2->WB_HAWB)
      MsgInfo(STR0157)  // "Parcela utilizada em outro Processo."
      TRB->(DbGoTo(nTRBRecno))//JVR - 15/03/10 - retorna para o registro inicial.
      RETURN .F.
   EndIf
   //**

   TRB->(DBAPPEND())

   If AvFlags("EIC_EAI")
      aAdd(aTRB_Old,{TRB->(RecNo()),NIL})
   EndIf
                                             //NCF - 19/10/2017 - Usar a informação de tipo de adiantamento da capa para posicionar já que no adiant. fornecedor pode ser informado o mesmo WB_NUMPO da parcela principal do desembaraço.
   IF SWB->(DBSEEK(cFilSWB+Work1->WB_NUMPO + Work1->WA_PO_DI ))

      //** PLB 06/09/07 - Posicionar na Parcela desejada do Adiantamento
      If !lOneParc
         Do While SWB->( !Eof()  .And.  WB_FILIAL+WB_HAWB == cFilSWB+Work1->WB_NUMPO )
            If SWB->WB_LINHA == Work2->WB_LINHA .AND. SWB->WB_PO_DI <> 'D'//WHRS 06/04/17 TE-5271 511456 / MTRADE-761 - PROBLEMA NA VINCULAÇÃO PAGAMENTO ANTECIPADO
               Exit
            EndIf
            SWB->( DBSkip() )
         EndDo
      EndIf
      //**

      //MCF - 21/05/2014
      M->WB_BANCO  := SWB->WB_BANCO
      M->WB_AGENCIA:= SWB->WB_AGENCIA
      M->WB_CONTA  := SWB->WB_CONTA

      AVREPLACE("SWB","TRB")
/*    TRB->WB_DT_VEN   := SWB->WB_DT_VEN
      TRB->WB_BANCO    := SWB->WB_BANCO
      TRB->WB_AGENCIA  := SWB->WB_AGENCIA
      TRB->WB_CA_NUM   := SWB->WB_CA_NUM
      TRB->WB_CA_TX    := SWB->WB_CA_TX
      TRB->WB_CA_DT    := SWB->WB_CA_DT
      TRB->WB_DT_CONT  := SWB->WB_DT_CONT
      TRB->WB_DT_REAL  := SWB->WB_DT_REAL
      TRB->WB_INVOICE  := SWB->WB_INVOICE
      TRB->WB_FORN     := SWB->WB_FORN
      TRB->WB_DT_DESE  := SWB->WB_DT_DESE*/
      TRB->WB_CONTAB   := CToD("  /  /  ") //AAF 06/08/2012 - Não copiar a data de contabilização.
      //THTS - 14/10/2019 - Ajuste de chave criado para o projeto do grupo de campos do Hawb, PO_NUM e Invoice
   	  TRB->WB_CHAVE := AP100WBCHV(TRB->WB_CHAVE)
   ENDIF

//   IF EICLOJA()
     TRB->WB_LOJA:= SWB->WB_LOJA
//   ENDIF

   TRB->WB_HAWB     := M->WA_HAWB
   TRB->WB_DT_DIG   := dDataBase
   TRB->WB_TIPOREG  := 'P'
   TRB->WB_PO_DI    := "D"
   TRB->WB_PGTANT   := Work1->WA_SLDANT
   TRB->WB_MOEDA    := Work1->W2_MOEDA
   //** PLB 06/09/07
   /*If lOneParc
      TRB->WB_PGTANT   := Work1->WA_SLDANT
   Else
      TRB->WB_PGTANT := Work2->WB_PGTANT
   EndIf*/
   //**
   // SVG - 18/02/2010 -
   //***
   /* Caso esteja habilitada a rotina de vinculação de adiantamento com parcela de cambio,
      permite que o usuário defina o valor a ser vinculado.
   */

   If lAdVinculado
      If nValVinc > 0 //RMD - 13/01/17 - Movido para o início da função, possibilitando o cancelamento //Apresenta a tela com o total da parcela e o valor a vincular
         TRB->WB_PGTANT := nValVinc
         //Work1->WA_SLDANT -= nValVinc//JVR
         nRecParcAD := TRB->(Recno())
         cChaveAd   := SWB->(WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN+WB_LOJA+WB_LINHA)
         TRB->WKCHVADVIN := cChaveAd   //TRB->WB_PGTASS := cChaveAd   //NCF - 
         //TRB->WB_CHVASS    := Upper(AllTrim(Ap100PGTASS(SWB->WB_FILIAL+cChaveAd)))
         //Posiciona na parcela a pagar
         //cChaveAd:= TRB->(WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN+WB_LOJA+WB_LINHA)//JVR- Nopado, pois não pode gravar no WB_CHAVE quando for tipo 1.
         If lCambio_EIC
            cTitAnt := TRB->WB_TITERP  // GFP - 04/07/2013
         EndIf
         TRB->(DbGoTo(nRecParcPag))
         TRB->WB_FOBMOE  := (TRB->WB_FOBMOE - nValVinc)  // Subtrai o valor digitado pelo o usuário do total da parcela
         TRB->WB_PGTANT  += nValVinc// Preenche o campo de pag antecipado com o valor digitado pelo o usuário
         If lCambio_EIC
            TRB->WB_TITERPV := cTitAnt  // GFP - 04/07/2013 - Vinculação do titulo PA no CBO
         EndIf
		 If EasyGParam("MV_EIC0043",,.F.)  // GFP - 17/03/2014
            TRB->WB_CA_DT  := dDataBase
         EndIf
		 /*If TRB->(FieldPos("WB_CHAVE")) > 0 //JVR- Nopado, pois não pode gravar no WB_CHAVE quando for tipo 1.
            TRB->WB_CHAVE := cChaveAd
         EndIf*/
         //Pega a chave da parcela a pagar
         cChave := TRB->(WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN+WB_LOJA+WB_LINHA)
         //Retorna para a parcela antecipada
         TRB->(DbGoTo(nRecParcAD))
         //Grava no campo chave a chave da parcela a pagar
         TRB->WB_NUMPO := Work1->WB_NUMPO
         If TRB->(FieldPos("WB_CHAVE")) > 0
            TRB->WB_CHAVE := cChave
         EndIf
         If lAdtMultFil
            TRB->WB_FILORI := Work1->WB_FILORI
         EndIf
         
      Else
         TRB->(dbDelete()) //Estorno da parcela criada devido ao cancelamento do usuário
         lRet := .F.
      EndIf

      cPo := Work1->WB_NUMPO
      cTipo := Work1->WA_PO_DI
      //Atualiza a work1 e work2
      Work1->(avzap())
      Work2->(avzap())
      //AP100GrvWork() // GCC - 12/09/2013 - Gravar a Work1 e Work2 de acordo com o pagamento antecipado escolhido
      AP100ResWK(cPo, cTipo)
   EndIf
   //***

   dbSelectArea("SWB")

   //TRB->WB_NUMPO    := Work1->WB_NUMPO
   //TRB->WB_MOEDA    := Work1->W2_MOEDA //RMD - 12/01/17 - A work1 está vazia neste momento, mas a moeda já foi carregada no append da TRB
   TRB->WB_FOBMOE   := 0
   TRB->WB_VM_OBS   := MSMM(SWB->WB_OBS,AVSX3("WB_VM_OBS",3))
   If !AvFlags("EIC_EAI")
      IF(TRB->(FIELDPOS("WB_NUMDUP" ))#0, TRB->WB_NUMDUP :="", )
      IF(TRB->(FIELDPOS("WB_PARCELA"))#0, TRB->WB_PARCELA:="", )
      IF(TRB->(FIELDPOS("WB_TIPOTIT"))#0, TRB->WB_TIPOTIT:="", )
      IF(TRB->(FIELDPOS("WB_PREFIXO"))#0, TRB->WB_PREFIXO:="", )
   EndIf

   IF(EasyEntryPoint("EICAP100"),Execblock("EICAP100",.F.,.F.,"GRV_TRB_CRIAPARC"),)

ELSE
   MSGINFO(STR0158)  // "Pedido ja possui parcela."
   lRet:= .F.
ENDIF

//AAF 03/09/2014
If lRet .AND. AvFlags("EIC_EAI")
   INTAP110(3) //Baixa referente a compensação de adiantamento.
Endif

TRB->(DBSETORDER(1))
//TRB->(DBGOTOP())
TRB->(DBGOTO(nTRBRecno))

oObj:oBrowse:Refresh()

RETURN lRet

/*
Função....: DefValVinculado(nValPagar)
Autor.....: Saimon Vinicius Gava  - SVG -
Descrição.: Definição dos valores para a vinculação do adiantamento com a parcela a pagar.
Observ....: Assume que está posicionado no adiantamento já incluido na work TRB.
Data......: 09/02/2010
Parâmetros: nValPagar - Valor da parcela a pagar.
Retorno...:
Empresa...: Average Tecnologia LTDA
*/
*------------------------------------------------*
Static Function DefValVinculado(nValPagar)
*------------------------------------------------*
Local oDlg
Local lOk

//Valor a ser vinculado (definido pelo usuário) - No momento, somente disponível a vinculação do valor total.
Local nValCpSel := 0
Local cPicture := "@E 999,999,999,999.99"
Local bCompare := If( lAdtMultFil, {|| WORK1->(WB_FILORI+WB_NUMPO+WA_PO_DI) <> WORK2->(WB_FILORI+WB_NUMPO+WB_PO_DI) } ,{|| WORK1->(WB_NUMPO+WA_PO_DI) <> WORK2->(WB_NUMPO+WB_PO_DI) } )
Local cChave   := If( lAdtMultFil, Work1->(WB_FILORI+WB_NUMPO+WA_PO_DI) , Work1->(WB_NUMPO+WA_PO_DI) )
Private oGet_X, cGet_X := ""

/**** Nopado por TDF
//SVG - 01/07/2011 - Nopado pois estava trazendo o valor total da parcela, não o saldo disponivel
//nValCpSel := SWB->WB_PGTANT //DFS - Tratamento para trazer o valor de cada parcela e não o valor total.
//Valor do adiantamento incluido
nValCpSel := TRB->WB_PGTANT //SVG - 01/07/2011 - Tratamento para trazer o valor do saldo disponivel e não o valor total.
nValCpSel := WORK2->WB_PGTANT //TDF - 21/10/2011 - Tratamento para trazer o valor da parcela, sempre atualizando o saldo por parcela.
****/

//nValCpSel := WORK1->WA_SLDANT
If Eval(bCompare)
   Work2->(DBSEEK(cChave))
EndIf

//WORK2->(DbSeek(WORK1->WB_NUMPO))  // GFP - 29/08/2014 //LRS - 13/05/2016 - Nopado, Work2 já seekado

// Desnopado por GFP - 10/02/2014 - Nopado por GCC - 12/09/2013 - Vinculação de Pagamento Antecipado Parcial
nValCpSel := WORK2->WB_PGTANT //TDF - 22/03/2012 - Tratamento para trazer o valor da parcela, sempre atualizando o saldo por parcela
/* GFP - 10/02/2014
nValCpSel := Work1->WB_PGTANT
*/
If nValCpSel > nValPagar
   nValCpSel := nValPagar
EndIf

nValMax := nValCpSel

   DEFINE MSDIALOG oDlg TITLE STR0277 FROM 178,181 TO 330,600 Of oMainWnd pixel //STR0277 "Vinculação de Adiantamento"

      oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165)
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      @14,6 SAY STR0278 PIXEL OF oPanel //STR0278 "Valor da Parcela"
      @14,64 MSGET nValPagar WHEN .F. PICTURE cPicture SIZE 55,8 RIGHT PIXEL OF oPanel

      @30,8  SAY STR0279 PIXEL OF oPanel //STR0279 "Valor a Vincular"
      @30,64 MSGET nValCpSel WHEN .F. PICTURE cPicture SIZE 55,8 RIGHT PIXEL OF oPanel Valid (DefVldVinc(nValCpSel,nValPagar)) //Bloqueado pois a função MaIntBxCP não está tratando corretamente compensação parcial de adiantamento.

      /* TDF - 31/07/2012
       MsGet criada para setar o focu do objeto, pois as teclas de atalho (ctrl+o e ctrl+x) não estavam funcinando em ambiente MDI.
       O erro acontecia pois as 2 outras MSGET possuem WHEN .F.
       Caso o WHEN seja alterado para .T. , apagar as linha abaixo*/

      @1200,1200 MsGet oGet_x Var cGet_x Of oDlg
      oGet_X:SetFocus()

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| (lOk := DefVldVinc (nValCpSel,nValPagar) ), oDlg:End() }, ;
                                                    {|| lOk := .F., oDlg:End()} ) Centered

If !lOk
   nValCpSel := 0
Endif

Return nValCpSel

/*
Função....: DefVldVinc()
Autor.....: Saimon Vinicius Gava  - SVG -
Descrição.: Validação do Valor a vincular digitado pelo usuário
Data......: 09/02/2010
Parâmetros: nValCpSel - Valor digitado pelo usuário.
            nValPagar - Valor da parcela a pagar.
Retorno...: lRet - Lógico
Empresa...: Average Tecnologia LTDA
*/
Static Function DefVldVinc(nValCpSel,nValPagar,cRot)

Private lRetvalid := .T. //LRS - 29/06/2017
Default cRot := "VAL_VINC"

IF(EasyEntryPoint("EICAP100"),Execblock("EICAP100",.F.,.F.,'VALID_VINCULACAO'),) //LRS - 29/06/2017

// GCC- 15/01/2014 - Implementado validação dos valores da função elimina saldo

IF Valtype(lRetValid) <> "L" 
   lRetvalid := .T.
EndIF

If lRetValid
    Do Case
        Case  cRot == "VAL_VINC"
            If nValCpSel > nValPagar
                MsgInfo(STR0280, STR0063) //STR0280 "Valor digitado maior que o valor da parcela a pagar."###"Atenção"
                lRetvalid:= .F.
            ElseIf nValCpSel <= 0
                MsgInfo(STR0281,STR0063)//"Não há saldo disponível para compensação da parcela."###"Atenção"
                lRetvalid:= .F.
            //ElseIf IF(AP100OneParc(),Work1->WA_SLDANT,TRB->WB_PGTANT) < nValCpSel  //JVR - 12/03/10 - validação de acordo com o saldo do PA.
            ElseIf nValPagar < nValCpSel  //WHRS 2017 - 505035 / MTRADE-501 - Problema ao compensar adiantamento com mais de uma parcela no EIC.
                MsgInfo(STR0282 + IF(AP100OneParc(If(lAdtMultFil,Work1->WB_FILORI,NIL))," ",STR0283) + STR0284, STR0063) //"Valor digitado maior que o Saldo"###" da parcela "###" disponivel."###"Atenção"
                lRetvalid := .F.
            EndIf
        Case cRot == "ELIMINA_SALDO"
            If nValPagar < 0
                MsgInfo(STR0325, STR0063) // "Valor a ser eliminado não pode ser negativo."###"Atenção"
                lRetvalid:= .F.
            Elseif nValCpSel + TRB->WB_SLDELI - nValPagar < 0
                MsgInfo(STR0326, STR0063) // "Valor a ser eliminado não pode ser maior que o saldo disponivel."###"Atenção"
                lRetvalid:= .F.
            EndIf
    EndCase
EndIF

ReTurn lRetvalid


*-------------------------------------------*
Function AP100Filtro()
*-------------------------------------------*
RETURN If(lAdtMultFil,Work1->(WB_FILORI+WB_NUMPO+WA_PO_DI),Work1->(WB_NUMPO+WA_PO_DI) )

*-------------------------------------------*
Function AP100ArqSYS(lIncSYS)//Funcao para gravar no arquivo SYS o valores % por centro de custo
*------------------------------------------*//dependendo do Conteudo da Variavel lIncSYS (.T.=INCLUSAO ) (.F.=EXCLUSAO)
Local Wind, nVlrPOTot := 0  //Valor Total da PO
PRIVATE cCCAux, aSYS_CC := {}
If lIncSYS
   SW2->(DBSETORDER(1))
   If SW2->(DBSeek(xFilial("SW2")+Left(M->WA_HAWB,AvSX3("W2_PO_NUM",AV_TAMANHO))))
      SW3->(DBSETORDER(1))
      If SW3->(DBSeek(xFilial("SW3")+AvKey(M->WA_HAWB,"W3_PO_NUM")))
         Do While xFilial("SW3")==SW3->W3_FILIAL .AND. AvKey(M->WA_HAWB,"W3_PO_NUM")==SW3->W3_PO_NUM.AND.!SW3->(EOF())
            IF SW3->W3_SEQ == 0
               cCCAux:=SW3->W3_CC
               If EasyEntryPoint("EICAP100")
                  ExecBlock("EICAP100",.F.,.F.,"CALCULO_SYS")
               EndIf
               Ind:= ASCAN(aSYS_CC,{|Tab| Tab[1] ==  cCCAux} )
               IF Ind == 0
                  AADD( aSYS_CC,{ cCCAux, SW3->W3_QTDE * SW3->W3_PRECO } )
               ELSE
                  aSYS_CC[Ind,2]+= SW3->W3_QTDE * SW3->W3_PRECO
               ENDIF
            ENDIF
            SW3->(DBSkip())
         Enddo
         IF(EasyEntryPoint("EICAP100"),Execblock("EICAP100",.F.,.F.,"ANTES_GRV_SYS"),)
         FOR Wind = 1 TO LEN(aSYS_CC)
             SYS->(RecLock("SYS",.T.))
             SYS->YS_FILIAL  := xFilial("SYS")
             SYS->YS_TPMODU  := "I"      //Modulo I=Importacao E=Exportacao(Campo Chave)
             SYS->YS_MOEDA   := SW2->W2_MOEDA
             SYS->YS_FORN    := SW2->W2_FORN
             IF EICLOJA()
                SYS->YS_FORLOJ := SW2->W2_FORLOJ
             ENDIF
             SYS->YS_TIPO    := "P"
             SYS->YS_HAWB    := M->WA_HAWB
             SYS->YS_CC      := aSYS_CC[Wind,1]
             SYS->YS_PERC    := aSYS_CC[Wind,2] / ValorPed()
             SYS->(MSUnlock())
         NEXT
      Endif
   Endif
Else
   SYS->( DbSetOrder( 1 ) )
   SYS->( DbSeek( xFilial("SYS") + "IP" + M->WA_HAWB ) )
//   DO While !SYS->(EOF()) .AND. SYS->YS_FILIAL=xFilial("SYS") .AND. SYS->YS_HAWB=M->WA_HAWB // RJB 05/10/2005
   DO While !SYS->(EOF()) .AND. SYS->YS_FILIAL=xFilial("SYS") .AND. SYS->YS_HAWB=M->WA_HAWB .AND. SYS->YS_TPMODU == "I" .AND. SYS->YS_TIPO == "P" // RJB 05/10/2005
      SYS->(RecLock("SYS",.F.,.T.))
      SYS->(DBDELETE())
      SYS->(MSUnlock())
      SYS->(DBSKIP())
   EndDO
Endif
RETURN .T.
//Funcao chamada da funcao APE100Crit("HOUSE","WA_HAWB"), que eh chamada da funcao
//ApeVal_House(M->WA_HAWB,.T.), que eh chamado do X3_VALID do campo WA_HAWB
*----------------------------*
FUNCTION APTemAdto(cPedido)
*----------------------------*
Local nValor,Wind1,nDias,nPerc
Local cMsgPgtAnt, aBoxWAPODI := ComboX3Box("WA_PO_DI")
Local nOldArea,cSWAAdt,cFilSWA,cWAPODI,lTemAdto := .F.

If lCposAntecip
	If !Empty(cPedido) .And. M->WA_PO_DI $ "A|F|C"

      nOldArea  := Select()
      cSWAAdt   := GetNextAlias()
      cFilSWA   := xFilial("SWA")
      BeginSQL Alias cSWAAdt
         SELECT WA_FILIAL,WA_HAWB,WA_PO_DI 
         FROM %table:SWA% SWA
         WHERE SWA.%NotDel% 
         AND SWA.WA_FILIAL = %exp:cFilSWA%
         AND SWA.WA_HAWB   = %exp:cPedido%
         AND SWA.WA_PO_DI IN ('A','F','C')
      EndSql
      If (cSWAAdt)->(!Eof()) .And. (cSWAAdt)->(!Bof())
         lTemAdto := .T.
         cWAPODI  := (cSWAAdt)->WA_PO_DI 
      EndIf
      (cSWAAdt)->(DBCloseArea())    
      If( nOldArea > 0 , DbSelectArea(nOldArea) , ) 

		If lTemAdto //SWA->(DbSeek(xFilial("SWA")+cPedido/*+Left(M->WA_PO_DI,1)*/)) // GCC - 18/09/2013 - Refazer a mensagem de alerta
         cMsgPgtAnt := STR0314  + ENTER + ENTER
         cMsgPgtAnt += Strtran(STR0397,"####",Alltrim(cPedido)) + ENTER //"ID do pagamento antecipado: #### "
         cMsgPgtAnt += StrTran(STR0398,"$$$$",  If( Left(cWAPODI,1) == "A", aBoxWAPODI[aScan(aBoxWAPODI,{|x| Left(x,1) == "A"})] ,; //"Tipo de pagamento antecipado: $$$$ "
                                                If( Left(cWAPODI,1) == "F", aBoxWAPODI[aScan(aBoxWAPODI,{|x| Left(x,1) == "F"})] ,;
                                                                            aBoxWAPODI[aScan(aBoxWAPODI,{|x| Left(x,1) == "C"})] )))
			MsgInfo(cMsgPgtAnt,STR0043)                                              //"Pagamento antecipado ja cadastrado"
			Return .F.
		EndIf 
      If M->WA_PO_DI == "A"
		   IF !EXISTCPO("SW2",AvKey(cPedido,"W2_PO_NUM"))
			   Return .F.
		   Endif
      EndIf
	Else
		Return .T.
	Endif

	//LRS - 25/11/2016 - Validação para trazer corretamente a informação do PO, caso o cliente
	//Selecione no processo Embarque, e o embarque não tem o mesmo nome do numero da P.O.
	IF cTipoProc == "E" .OR. Empty(cTipoProc)
	   SW6->(DBSETORDER(1))
	   If SW6->(DBSEEK(xFilial("SW6")+Avkey(cPedido,"W6_HAWB")))  //NCF - 19/12/2016 - Só posicionar o PO se achar com mesmo nro. do Embarque
	      SW2->(DBSEEK(xFilial("SW2")+SW6->W6_PO_NUM))
	   EndIf
	Else
	   SW2->(DBSEEK(xFilial("SW2")+Avkey(cPedido,"W2_PO_NUM")))
	EndIF

	IF Alltrim(cPedido) <> Alltrim(SW2->W2_PO_NUM)
	   SW2->(DBSEEK(xFilial("SW2")+Avkey(cPedido,"W2_PO_NUM")))
	EndIF
   If M->WA_PO_DI == "A" //So valida a condicao de pagamento se for adiantamento de PO
      If SY6->(DbSeek(xFilial()+SW2->W2_COND_PA+STR(SW2->W2_DIAS_PA,3,0)))

         If SY6->Y6_TIPOCOB == "4" .OR. SY6->Y6_DIAS_PA < 900
            MSGINFO(STR0160,STR0043)  // "Condicao de pagamento do Pedido sem cobertura ou nao possui Parcelas"
            Return .F.
         Else
            nPerc  := 0
            nValor := 0
            lTemParcAdta := .F.
            For Wind1:= 1 TO 10
               nDias:= "Y6_DIAS_" + STRZERO(Wind1,2)
               nDias:= SY6->(FIELDGET( FIELDPOS(nDias) ))
               nPerc:= "Y6_PERC_" + STRZERO(Wind1,2)
               nPerc:= SY6->(FIELDGET( FIELDPOS(nPerc) ))

               If nDias < 0
                  nValor+= ((ValorPed()+SW2->W2_INLAND+;
                     SW2->W2_PACKING+SW2->W2_FRETEIN-SW2->W2_DESCONT+SW2->W2_OUT_DES)*(nPerc/100))
                  lTemParcAdta := .T.
               EndIf
            Next
            If !lTemParcAdta
               MsgInfo(STR0161,STR0043)  // "Pedido nao possui parcelas Antecipadas"
               Return .F.
            EndIf
         Endif
      Else
         If SW2->(!Eof())
            MsgInfo(STR0162,STR0043)  // "Condicao de Pagamento nao cadastrada"
            Return .F.
         EndIf
      EndIf
   EndIf
Endif

Return .T.

*--------------------------------------------------------------------*
Function AP100BrowseSXB()//Chamado do SXB, XB_ALIAS = 'EDP'
*--------------------------------------------------------------------*
LOCAL cCampo:=UPPER(READVAR()),cAux
Local lAux := .T.
Local oDlg
Local cTipo

IF cCampo == "M->WB_INVOICE"
   IF LEFT(M->WA_PO_DI,1) == "D"
      IF ConPad1(,,,'SW9')
         M->WB_INVOICE:=SW9->W9_INVOICE
      ENDIF
   ElseIf LEFT(M->WA_PO_DI,1) == "A" // GCC - 18/09/2013 - Quando adiantamento fornecedor não deve ter consulta padrão
      cAux:=''
      IF ConPad1(,,,'SW2',cAux)
         M->WB_INVOICE:=SW2->W2_NR_PRO
      ENDIF
   ENDIF

ELSEIF cCampo == "M->WA_HAWB"

   IF LEFT(M->WA_PO_DI,1) == "D"
      IF ConPad1(,,,'HAW')
         cProcSXB:=SW6->W6_HAWB  //TRP-13/05/08
         M->WA_HAWB:=SW6->W6_HAWB
         lAux := .T.
      ELSE
         lAux := .F.
      ENDIF
   ElseIf LEFT(M->WA_PO_DI,1) == "A"
      IF ConPad1(,,,'SW2')
         cProcSXB:=SW2->W2_PO_NUM   //TRP-13/05/08
         M->WA_HAWB:=SW2->W2_PO_NUM
         lAux := .T.
      ELSE
         lAux := .F.
      ENDIF
   ElseIf LEFT(M->WA_PO_DI,1) $ "F|C"
      MSGINFO(STR0353)
      lAux := .T.
   EndIf

ELSEIF cCampo == "M->WB_NUMPO"

   IF Left(M->WB_TIPOREG,1) == 'P'
      IF AP100POsAdto(.T.)
         M->WB_PGTANT:= Work1->WA_SLDANT
         M->WB_NUMPO := Work1->WB_NUMPO
         lRefresh:=.T.
         RETURN Work1->WB_NUMPO
      ENDIF
   ELSE
      MSGSTOP(STR0216)  // "Parcela nao e 'P'=Pagamento Antecipado"
   ENDIF

ElseIf cCampo == "M->WB_FORN"
	If LEFT(M->WA_PO_DI,1) == "F" .Or. LEFT(M->WA_PO_DI,1) == "C"
		IF ConPad1(,,,'SA2')
			M->WB_FORN    := SA2->A2_COD
			M->WB_LOJA    := SA2->A2_LOJA
			lAux := .T.
		Else
			lAux := .F.
		EndIf
	EndIf
EndIf

Return lAux


*--------------------------------------*
//AWR 18/09/2002
Function ProximoMes(dData,cCond,nDias)//Funcao usada em outros programas
*--------------------------------------*
IF SY6->(FIELDPOS("Y6_PROMES")) # 0 .AND. SY6->(DBSEEK(xFilial()+cCond+STR(nDias,3)))
   IF SY6->Y6_TIPO == "1" .AND. SY6->Y6_PROMES $ cSim
      nMesAtual:=MONTH(dData)
      DO WHILE .T.
         dData++
         nMes:=MONTH(dData)
         IF MONTH(dData) # nMesAtual
            EXIT
         ENDIF
      ENDDO
      dData:=(dData-1)
   ENDIF
ENDIF

Return dData

*--------------------------------*
FUNCTION AP100Busca()
*--------------------------------*
Local oDlg
Local cCombo
Local oMsBtn
Local aTabItens := {}  , I
FOR I := 1 TO LEN(aTabIndex)
    AADD(aTAbItens,aTabIndex[I,1])
NEXT
cCombo := aTabItens[1]
cChave := SPACE(60)
lPorCA := .F.

DO WHILE .T.
   nOpcao   := 0

   DEFINE MSDIALOG oDlg TITLE STR0001 FROM 9,0 TO 18,40 OF oMainWnd //"Pesquisa"

    @ 0.5,0.6 COMBOBOX cCombo ITEMS aTabItens SIZE 150,50 OF oDlg
    @ 2,0.6  MSGET cChave SIZE 150,7 PICTURE "@!"

    DEFINE SBUTTON oMsBtn FROM 45,085 TYPE 1 ACTION (nOpcao:=1, oDlg:End()) ENABLE OF oDlg
    DEFINE SBUTTON oMsBtn FROM 45,125 TYPE 2 ACTION (oDlg:End()) ENABLE OF oDlg

   ACTIVATE DIALOG oDlg CENTERED

   IF nOpcao == 1
      IF cCombo == aTabIndex[Len(aTabIndex),1]
         lPorCA := .T.
      ENDIF
      IF !AP100Pesq(cCombo,lPorCA)
         LOOP
      ENDIF
   ENDIF
   EXIT
ENDDO

lPorPO:=.F.

RETURN .T.
*---------------------------------------*
FUNCTION AP100Pesq(cCombo,lPorCA)
*---------------------------------------*
LOCAL nOrd := SWA->(INDEXORD())

IF lPorCA
   aTabCANUM := {}
   SWB->(DBSETORDER(5))
   IF SWB->(DBSEEK(xFilial("SWB")+RTrim(cChave)))
      cChave:=SWB->WB_CA_NUM
      DO WHILE !SWB->(EOF()) .AND. SWB->WB_FILIAL == xFilial("SWB") .AND. cChave = SWB->WB_CA_NUM
         IF ASCAN(aTabCANUM,SWB->WB_HAWB) == 0
            AADD (aTabCANUM,SWB->WB_HAWB)
         ENDIF
         SWB->(DBSKIP())
      ENDDO
      IF LEN(aTabCANUM) # 0
         IF LEN(aTabCANUM) # 1
            cChave:=AP100Selec(aTabCANUM)
         ELSE
            cChave:=aTabCANUM[1]
         ENDIF
         IF !EMPTY(cChave)
            SWA->(DBSETORDER(1))
            SWA->(DBSEEK(xFilial()+cChave))
            APEMANSWA("SWA",SWA->(RECNO()),2)
            RETURN .T.
         ENDIF
         RETURN .F.
      ENDIF
   ELSE
      IF !EMPTY(cChave)
         HELP(" ",1,"PESQ01")
         RETURN .F.
      ENDIF
   ENDIF
ELSE
   nPos := ASCAN(aTabIndex,{|var| var[1] ==  cCombo})
   IF nPos # 0
      IF !EMPTY(aTabIndex[nPos,2])
         cChave:= ALLTRIM(ConvData(aTabIndex[nPos,2],cChave))
      Else
         cChave:= RTrim(cChave)
      ENDIF
      SWA->(DBSETORDER(nPos))
      IF !SWA->(DBSEEK(xFilial()+cChave)) .AND. !EMPTY(cChave)
         HELP(" ",1,"PESQ01")
         RETURN .F.
      ENDIF
   ENDIF
ENDIF

SWA->(DBSETORDER(nOrd))

RETURN .T.
*---------------------------------------*
FUNCTION AP100Selec(aTabCANUM)
*---------------------------------------*
LOCAL oDlg,nOpcao
cCANUM:=aTabCANUM[1]
DO WHILE .T.
   nOpcao   := 0

   DEFINE MSDIALOG oDlg TITLE STR0233 FROM 0,0 TO 9,33 OF oMainWnd  // "Selecione para Visualizar"

    @ 0.5,0.6 SAY AVSX3("WA_HAWB",5)+"s"
    @ 1.5,0.6 COMBOBOX cCANUM ITEMS aTabCANUM SIZE 65,65 OF oDlg

    DEFINE SBUTTON oMsBtn FROM 05,085 TYPE 1 ACTION (nOpcao:=1, oDlg:End()) ENABLE OF oDlg
    DEFINE SBUTTON oMsBtn FROM 25,085 TYPE 2 ACTION (oDlg:End()) ENABLE OF oDlg

   ACTIVATE DIALOG oDlg CENTERED

   IF nOpcao == 1
      RETURN cCANUM
   ENDIF

   EXIT

ENDDO

RETURN ''

/*
Função      : AP100Vinc()
Objetivo    : Financiamento da Importação
Parametro   : cOp -> String que indica a opção da Vinculação (INCLUIR, ESTORNAR ou VISUALIZAR)
Retorno     : Lógico. Sempre .T.
Autor       : GFC - Gustavo Fabro da Costa Carreiro
Data        : 03/2006.
*/
*----------------------------------------------------------------------------------------------------*
Static Function AP100Vinc(cOp)
*----------------------------------------------------------------------------------------------------*
Local nSelecao:=0, cFilOri:="", cSeqAux, nOldRec, aEvento:={}
Local ni:=0, nOpc, oDlg, nPos, lSaiVinc:=.F., aVinc := {}
Local aAlt := {}, nxi:=0
Local lOk  := .f.
Local aBotao := {}
Local cMoeEF1 := "" , nSaldoCnt := 0 , nPos2 := 0
Local nSaldo := 0, nRecno := 0 //MCF - 06/10/2015

//** PLB 27/02/07 - Utilizada no Walk-Thru
Local cUsado := {}
SX3->( DBSetOrder(2) )
SX3->( DBSeek("EF3_FILIAL") )
cUsado := SX3->X3_USADO
//**

Private aHeader := {}, oGetDados
Private aCols   := {}
Private cOpcao := cOP

If cOp == "ESTORNAR"
   Aadd(aHeader, {STR0285,"MARCA","@!",1,0,nil,nil,"C",nil,nil }) //STR0285 "Marca"
EndIf

// GCC - 13/11/2013 - Identação
Aadd(aHeader, {AVSX3("EF2_CONTRA",5), "EF2_CONTRA",AVSX3("EF2_CONTRA",6), AVSX3("EF2_CONTRA",3), AVSX3("EF2_CONTRA",4), Nil, Nil, AVSX3("EF2_CONTRA",2), Nil, Nil })
Aadd(aHeader, {STR0286              , "EF2_BAN_FI",AVSX3("EF2_BAN_FI",6), AVSX3("EF2_BAN_FI",3), AVSX3("EF2_BAN_FI",4), Nil, Nil, AVSX3("EF2_BAN_FI",2), Nil, Nil }) //STR0286 "Banco"
Aadd(aHeader, {STR0287              , "EF1_DES_FI",AVSX3("A6_NREDUZ" ,6), AVSX3("A6_NREDUZ" ,3), AVSX3("A6_NREDUZ" ,4), Nil, Nil, AVSX3("A6_NREDUZ" ,2), Nil, Nil }) //STR0287 "Nome do Banco"
Aadd(aHeader, {AVSX3("EF3_PRACA",5) , "EF3_PRACA" ,AVSX3("EF3_PRACA" ,6), AVSX3("EF3_PRACA" ,3), AVSX3("EF3_PRACA" ,4), Nil, Nil, AVSX3("EF3_PRACA" ,2), Nil, Nil })
Aadd(aHeader, {AVSX3("EF5_DESCRI",5), "EF5_DESCRI",AVSX3("EF5_DESCRI",6), AVSX3("EF5_DESCRI",3), AVSX3("EF5_DESCRI",4), Nil, Nil, AVSX3("EF5_DESCRI",2), Nil, Nil })
Aadd(aHeader, {AVSX3("EF2_SEQCNT",5), "EF2_SEQCNT",AVSX3("EF2_SEQCNT",6), AVSX3("EF2_SEQCNT",3), AVSX3("EF2_SEQCNT",4), Nil, Nil, AVSX3("EF2_SEQCNT",2), Nil, Nil })
Aadd(aHeader, {STR0288              , "FOBMOE"    ,AVSX3("WB_FOBMOE" ,6), AVSX3("WB_FOBMOE" ,3), AVSX3("WB_FOBMOE" ,4), Nil, Nil, AVSX3("WB_FOBMOE" ,2), Nil, Nil })  //STR0288 "Vl a Vincular"
Aadd(aHeader, {STR0289              , "DT_VINC"   ,AVSX3("EF3_DT_EVE",6), AVSX3("EF3_DT_EVE",3), AVSX3("EF3_DT_EVE",4), Nil, Nil, AVSX3("EF3_DT_EVE",2), Nil, Nil })//STR0289 "Dt. Vinculação"
Aadd(aHeader, {AVSX3("WB_FOBMOE",5) , "VL_ORI"    ,AVSX3("WB_FOBMOE" ,6), AVSX3("WB_FOBMOE" ,3), AVSX3("WB_FOBMOE" ,4), Nil, Nil, AVSX3("WB_FOBMOE" ,2), Nil, Nil })
Aadd(aHeader, {STR0290              , "TX_VINC"   ,AVSX3("EF3_TX_MOE",6), AVSX3("EF3_TX_MOE",3), AVSX3("EF3_TX_MOE",4), Nil, Nil, AVSX3("EF3_TX_MOE",2), Nil, Nil }) //STR0290 "Tx. Vinculação"
Aadd(aHeader, {AVSX3("WB_MOEDA",5)  , "WB_MOEDA"  ,AVSX3("WB_MOEDA"  ,6), AVSX3("WB_MOEDA"  ,3), AVSX3("WB_MOEDA"  ,4), Nil, Nil, AVSX3("WB_MOEDA"  ,2), Nil, Nil })
Aadd(aHeader, {AVSX3("WB_DT_VEN",5) , "WB_DT_VEN" ,AVSX3("WB_DT_VEN" ,6), AVSX3("WB_DT_VEN" ,3), AVSX3("WB_DT_VEN" ,4), Nil, Nil, AVSX3("WB_DT_VEN" ,2), Nil, Nil })
Aadd(aHeader, {STR0291              , "DT_RECEB"  ,AVSX3("EF3_DT_FIX",6), AVSX3("EF3_DT_FIX",3), AVSX3("EF3_DT_FIX",4), Nil, Nil, AVSX3("EF3_DT_FIX",2), Nil, Nil }) //STR0291 "Dt. Receb. Dinheiro"
// ** PLB 27/02/07 - Walk-Thru
Aadd(aHeader, {"Alias WT"           ,"EF3_ALI_WT",""                    ,3                     ,0                     ,""  ,cUsado,"C"                 ,"EF3","V" })
Aadd(aHeader, {"Recno WT"           ,"EF3_REC_WT",""                    ,10                    ,0                     ,""  ,cUsado,"N"                 ,"EF3","V" })
//**

// PLB 25/07/06 - Variavel para tratamento multi-usuario
If lEIC_EFF  .And.  lEFFTpMod
   aVinList := {}
EndIf

For ni:=1 to Len(aVincula)
   If aVincula[ni,13] <> "SALDO" .and. aVincula[ni,9] == TRB->WB_INVOICE .and. aVincula[ni,10] == TRB->WB_LINHA
      Aadd(aCols,Array(Len(aHeader)+3))
      nPos := Len(aCols)
      If cOp == "ESTORNAR"
         aCols[nPos,GDFieldPos("MARCA")] := " "
         nColDel     :=17
         nColSeqEF3  :=18
         nColSeqArray:=19
      Else
         nColDel     :=16
         nColSeqEF3  :=17
         nColSeqArray:=18
      EndIf
      aCols[nPos,GDFieldPos("EF2_CONTRA")] := aVincula[ni,03]
      aCols[nPos,GDFieldPos("EF2_BAN_FI")] := aVincula[ni,14]
      aCols[nPos,GDFieldPos("EF1_DES_FI")] := If(SA6->(DbSeek(xFilial("SA6")+aVincula[ni,14])), SA6->A6_NREDUZ, "")
      aCols[nPos,GDFieldPos("EF3_PRACA")]  := aVincula[ni,15]
      If EF5->(DBSeek(xFilial("EF5")+aVincula[ni,15]))
         aCols[nPos,GDFieldPos("EF5_DESCRI")] := EF5->EF5_DESCRI
      Endif
      aCols[nPos,GDFieldPos("EF2_SEQCNT")] := aVincula[ni,20]
      aCols[nPos,GDFieldPos("FOBMOE")]     := aVincula[ni,01]
      aCols[nPos,GDFieldPos("DT_VINC")]    := aVincula[ni,11]
      aCols[nPos,GDFieldPos("VL_ORI")]     := aVincula[ni,01]
      aCols[nPos,GDFieldPos("TX_VINC")]    := aVincula[ni,12]
      aCols[nPos,GDFieldPos("WB_MOEDA")]   := aVincula[ni,18]
      aCols[nPos,GDFieldPos("WB_DT_VEN")]  := aVincula[ni,19]
      aCols[nPos,GDFieldPos("DT_RECEB")]   := aVincula[ni,02]
      //** PLB 27/02/07 - Walk-Thru
      If aVincula[ni,16] != NIL  .And.  aVincula[ni,16] != 0
         aCols[nPos,GDFieldPos("EF3_ALI_WT")] := "EF3"
         aCols[nPos,GDFieldPos("EF3_REC_WT")] := aVincula[ni,16]
      Else
         aCols[nPos,GDFieldPos("EF3_REC_WT")] := 0
      EndIf
      //**
      aCols[nPos,nColDel]      := .F.
      aCols[nPos,nColSeqEF3]   := aVincula[ni,4]
      aCols[nPos,nColSeqArray] := aVincula[ni,5]
      //** PLB 25/07/06 - Tratamento Multi-Usuario Financiamento
      If lEIC_EFF  .And.  lEFFTpMod
         If cOp == "INCLUIR"  .And.  !Empty(aCols[nPos,GDFieldPos("EF2_CONTRA")])
            AAdd( aVinList ,{ aCols[nPos,GDFieldPos("EF2_CONTRA")] ,;
                              aCols[nPos,GDFieldPos("EF2_BAN_FI")] ,;
                              aCols[nPos,GDFieldPos("EF3_PRACA")]  ,;
                              aCols[nPos,GDFieldPos("EF2_SEQCNT")]    })
         EndIf
      EndIf
      //**
   EndIf
Next ni

If cOp = "ESTORNAR"
   aBotao := { {"LBTIK" ,{||  VincMarkEst(.T.) }, STR0292} } //"Marca/Desmarca Todos" //STR0292 "Marca/Desmarca Todos"
   nOpc := 4
ElseIf cOp = "INCLUIR"
   nOpc := 4
   aAlt := {"EF2_CONTRA","EF2_BAN_FI","EF3_PRACA","FOBMOE","DT_VINC","TX_VINC","EF2_SEQCNT"}
ElseIf cOp = "VISUALIZAR"
   nOpc := 4
EndIf

If Len(aVincula) > 0

   Do While .T.

      nSelecao:=0
      lSaiVinc := .F.
      aVinc := {}
      DEFINE MSDIALOG oDlg TITLE If(cOp = "ESTORNAR", STR0293, STR0294) ; //STR0293 "Estorno da Vinculacao" //STR0294 "Vinculação"
      FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
      OF oMainWnd PIXEL

      	  oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 06/10/2015
         oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

         nLinha :=(oDlg:nClientHeight-4)/2
         //                             1   2    3               4              5     6           7 8  9  10  11 12   13            14             18
         oGetDados := MsGetDados():New(4, 01, nLinha, (oDlg:nClientWidth-4)/2, 4,"AllwaysTrue()", , ,.F.,aAlt, , ,Len(aCols),"AP100FIELDOK",,,, oPanel)

         If cOp = "ESTORNAR"
            oGetDados:oBrowse:blDblClick:= {|| VincMarkEst(.F.), oGetDados:ForceRefresh()}
         EndIf
         oGetDados:oBROWSE:Badd := {||.F.}

      If cOp <> "VISUALIZAR"
         ACTIVATE MSDIALOG oDlg ON INIT (oGetDados:oBrowse:Refresh(), EnchoiceBar(oDlg,{||nSelecao:=1,oDlg:End()},{||nSelecao:=0,oDlg:End()},,aBotao))
      Else
         ACTIVATE MSDIALOG oDlg ON INIT (oGetDados:oBrowse:Refresh(), EnchoiceBar(oDlg,{||nSelecao:=0,oDlg:End()},{||nSelecao:=0,oDlg:End()},,))
      Endif

      If nSelecao = 1

         //** PLB 25/07/06 - Tratamento Multi-Usuario Financiamento
         For ni := 1 to Len(aCols)
            If !Empty(aCols[ni,GDFieldPos("EF2_CONTRA")]) .And. IIF(cOp=="ESTORNAR",!Empty(aCols[ni,GDFieldPos("MARCA")]),.T.)
               If EF1->( DBSeek(xFilial("EF1")+Left(TIPO_MODULO,1)+aCols[ni,GDFieldPos("EF2_CONTRA")]+aCols[ni,GDFieldPos("EF2_BAN_FI")]+aCols[ni,GDFieldPos("EF3_PRACA")]+aCols[ni,GDFieldPos("EF2_SEQCNT")]) )
                  If !SoftLock("EF1")
                     lSaiVinc := .T.
                     Exit
                  EndIf
               EndIf
            EndIf
         Next ni
         If !lSaiVinc  .And.  cOp == "INCLUIR"  .And.  Len(aVinList) > 0
            For ni := 1  to  Len(aVinList)
               If EF1->( DBSeek(xFilial("EF1")+Left(TIPO_MODULO,1)+aVinList[ni][1]+aVinList[ni][2]+aVinList[ni][3]+aVinList[ni][4]) )
                  If !SoftLock("EF1")
                     lSaiVinc := .T.
                  EndIf
               EndIf
            Next ni
         EndIf
         If lSaiVinc
            lSaiVinc := .F.
            Loop
         EndIf
         //**

         If cOp = "ESTORNAR"
            For ni:=1 to Len(aCols)
               If !Empty(aCols[ni,GDFieldPos("MARCA")]) .And. !Empty(aCols[ni,nColSeqArray])
                  If (nPos := aScan(aVincula, {|x| x[5]==aCols[ni,nColSeqArray]} )) > 0
                     If !Empty(aCols[ni,nColSeqEF3])
                        aAdd(aExcVinc, {If(!Empty(aVincula[nPos,22]), aVincula[nPos,22], aVincula[nPos,10]), aCols[ni,GDFieldPos("EF2_CONTRA")], aCols[ni,nColSeqEF3], aCols[ni,GDFieldPos("EF2_BAN_FI")], aCols[ni,GDFieldPos("EF3_PRACA")], aCols[ni,GDFieldPos("EF2_SEQCNT")], aVincula[nPos,16], TRB->(RecNo()), .T. })
                     EndIf
                     //** PLB 25/07/06 - Controla aumento do valor do contrato
                     nPos2 := AScan(aNewVlCont,{|x| x[1]==aVincula[nPos,3]+aVincula[nPos,14]+aVincula[nPos,15]+aVincula[nPos,20]})
                     If nPos2 > 0
                        EF1->( DBSeek(xFilial("EF1")+Left(TIPO_MODULO,1)+aVincula[nPos,3]+aVincula[nPos,14]+aVincula[nPos,15]+aVincula[nPos,20]) )
                        If aVincula[nPos,16] != NIL  .And.  aVincula[nPos,16] != 0
                           EF3->( DBGoTo(aVincula[nPos,16]) )
                           If (aNewVlCont[nPos2][2] - EF3->EF3_VL_MOE) > EF1->EF1_SLD_PM
                              aNewVlCont[nPos2][2] -= EF3->EF3_VL_MOE
                              aNewVlCont[nPos2][3] -= EF3->EF3_VL_REA
                           Else
                              ADel(aNewVlCont,nPos2)
                              ASize(aNewVlCont,Len(aNewVlCont)-1)
                              If Len(aNewVlCont) == 1
                                 lAumVlCont := .F.
                              EndIf
                           EndIf
                        Else
                           cMoeEF1 := Posicione("EF1",1,xFilial("EF1")+Left(TIPO_MODULO,1)+aVincula[nPos,3]+aVincula[nPos,14]+aVincula[nPos,15]+aVincula[nPos,20],"EF1->EF1_MOEDA")
                           If cMoeEF1 == aVincula[nPos,18]
                              If (aNewVlCont[nPos2][2] - aVincula[nPos,1]) > EF1->EF1_SLD_PM
                                 aNewVlCont[nPos2][2] -= aVincula[nPos,1]
                                 aNewVlCont[nPos2][3] -= aVincula[nPos,1] * aVincula[nPos,12]
                              Else
                                 ADel(aNewVlCont,nPos2)
                                 ASize(aNewVlCont,Len(aNewVlCont)-1)
                                 If Len(aNewVlCont) == 1
                                    lAumVlCont := .F.
                                 EndIf
                              EndIf
                           Else
                              If (aNewVlCont[nPos2][2] - (aVincula[nPos,1] * aVincula[nPos,12] / BuscaTaxa(cMoeEF1,aVincula[nPos,11],,.F.,.T.,,cTX_100))) > EF1->EF1_SLD_PM
                                 aNewVlCont[nPos2][2] -= aVincula[nPos,1] * aVincula[nPos,12] / BuscaTaxa(cMoeEF1,aVincula[nPos,11],,.F.,.T.,,cTX_100)
                                 aNewVlCont[nPos2][3] -= aVincula[nPos,1] * aVincula[nPos,12]
                              Else
                                 ADel(aNewVlCont,nPos2)
                                 ASize(aNewVlCont,Len(aNewVlCont)-1)
                                 If Len(aNewVlCont) == 1
                                    lAumVlCont := .F.
                                 EndIf
                              EndIf
                           EndIf

                        EndIf
                     EndIf
                     //**
                     aVincula[nPos,03] := Space(Len(EF2->EF2_CONTRA))
                     aVincula[nPos,14] := Space(Len(EF2->EF2_BAN_FI))
                     aVincula[nPos,15] := Space(Len(EF3->EF3_PRACA))
                     aVincula[nPos,20] := Space(Len(EF2->EF2_SEQCNT))
                     aVincula[nPos,12] := BuscaTaxa(TRB->WB_MOEDA,dDataBase,,.F.,.T.,,cTX_100)
                     aVincula[nPos,11] := dDataBase
                     aVincula[nPos,04] := Space(Len(EF3->EF3_SEQ))
                     aVincula[nPos,16] := NIL
                  EndIf
               EndIf
            Next ni
         ElseIf cOp == "INCLUIR"
            //** Verifica saldo do contrato
            For ni:=1 to Len(aVincula)
               If !Empty(aVincula[ni,3]) .and. !Empty(aVincula[ni,4]) .and. aVincula[ni,10] <> TRB->WB_LINHA
                  If (nPos := aScan(aVinc,{|x| x[1]==aVincula[ni,3] .and. x[2]==aVincula[ni,14] .and. x[3]==aVincula[ni,15] .and. x[4]==aVincula[ni,20] })) = 0
                     aAdd(aVinc,{aVincula[ni,3], aVincula[ni,14], aVincula[ni,15], aVincula[ni,20], 0, 0})
                     If aVincula[ni,16] != NIL  .And.  aVincula[ni,16] != 0
                        EF3->( DBGoTo(aVincula[ni,16]) )
                        aVinc[Len(aVinc),5] := EF3->EF3_VL_MOE
                        aVinc[Len(aVinc),6] := EF3->EF3_VL_REA
                     Else
                        cMoeEF1 := Posicione("EF1",1,xFilial("EF1")+Left(TIPO_MODULO,1)+aVincula[ni,3]+aVincula[ni,14]+aVincula[ni,15]+aVincula[ni,20],"EF1->EF1_MOEDA")
                        If cMoeEF1 == aVincula[ni,18]
                           aVinc[Len(aVinc),5] := aVincula[ni,1]
                        Else
                           aVinc[Len(aVinc),5] := aVincula[ni,1] * aVincula[ni,12] / BuscaTaxa(cMoeEF1,aVincula[ni,11],,.F.,.T.,,cTX_100)
                        EndIf
                        aVinc[Len(aVinc),5] += EX401EvSum(EV_EMBARQUE,"EF3",xFilial("EF1")+Left(TIPO_MODULO,1)+aVinc[Len(aVinc),1]+aVinc[Len(aVinc),2]+aVinc[Len(aVinc),3]+aVinc[Len(aVinc),4])
                        aVinc[Len(aVinc),6] := aVincula[ni,1] * aVincula[ni,12]
                     EndIf
                  Else
                     If aVincula[ni,16] != NIL  .And.  aVincula[ni,16] != 0
                        EF3->( DBGoTo(aVincula[ni,16]) )
                        aVinc[nPos,5] += EF3->EF3_VL_MOE
                        aVinc[nPos,6] += EF3->EF3_VL_REA
                     Else
                        cMoeEF1 := Posicione("EF1",1,xFilial("EF1")+Left(TIPO_MODULO,1)+aVincula[ni,3]+aVincula[ni,14]+aVincula[ni,15]+aVincula[ni,20],"EF1->EF1_MOEDA")
                        If cMoeEF1 == aVincula[ni,18]
                           aVinc[nPos,5] += aVincula[ni,1]
                           aVinc[nPos,6] += aVincula[ni,1] * aVincula[ni,12]
                        Else
                           aVinc[nPos,5] += aVincula[ni,1] * aVincula[ni,12] / BuscaTaxa(cMoeEF1,aVincula[ni,11],,.F.,.T.,,cTX_100)
                           aVinc[nPos,6] += aVincula[ni,1] * aVincula[ni,12]
                        EndIf
                     EndIf
                  EndIf
               EndIf
            Next ni
            For ni:=1 to Len(aCols)
               If !Empty(aCols[ni,GDFieldPos("EF2_CONTRA")]) .and. Empty(aCols[ni,nColSeqEF3])
                  cMoeEF1 := Posicione("EF1",1,xFilial("EF1")+Left(TIPO_MODULO,1)+aCols[ni,GDFieldPos("EF2_CONTRA")]+aCols[ni,GDFieldPos("EF2_BAN_FI")]+aCols[ni,GDFieldPos("EF3_PRACA")]+aCols[ni,GDFieldPos("EF2_SEQCNT")],"EF1->EF1_MOEDA")
                  If (nPos := aScan(aVinc,{|x| x[1]==aCols[ni,GDFieldPos("EF2_CONTRA")] .and. x[2]==aCols[ni,GDFieldPos("EF2_BAN_FI")] .and. x[3]==aCols[ni,GDFieldPos("EF3_PRACA")] .and. x[4]==aCols[ni,GDFieldPos("EF2_SEQCNT")] })) = 0
                     aAdd(aVinc,{aCols[ni,GDFieldPos("EF2_CONTRA")], aCols[ni,GDFieldPos("EF2_BAN_FI")], aCols[ni,GDFieldPos("EF3_PRACA")], aCols[ni,GDFieldPos("EF2_SEQCNT")], 0, 0})
                     If cMoeEF1 == aCols[ni,GDFieldPos("WB_MOEDA")]
                        aVinc[Len(aVinc),5] := aCols[ni,GDFieldPos("FOBMOE")]
                     Else
                        aVinc[Len(aVinc),5] := aCols[ni,GDFieldPos("FOBMOE")] * aCols[ni,GDFieldPos("TX_VINC")] / BuscaTaxa(cMoeEF1,aCols[ni,GDFieldPos("DT_VINC")],,.F.,.T.,,cTX_100)
                     EndIf
                     aVinc[Len(aVinc),6] := aCols[ni,GDFieldPos("FOBMOE")] * aCols[ni,GDFieldPos("TX_VINC")]
                  Else
                     If cMoeEF1 == aCols[ni,GDFieldPos("WB_MOEDA")]
                        aVinc[nPos,5] += aCols[ni,GDFieldPos("FOBMOE")]
                     Else
                        aVinc[nPos,5] += aCols[ni,GDFieldPos("FOBMOE")] * aCols[ni,GDFieldPos("TX_VINC")] / BuscaTaxa(cMoeEF1,aCols[ni,GDFieldPos("DT_VINC")],,.F.,.T.,,cTX_100)
                     EndIf
                     aVinc[nPos,6] += aCols[ni,GDFieldPos("FOBMOE")] * aCols[ni,GDFieldPos("TX_VINC")]
                  EndIf
               EndIf
            Next ni

            EF1->(dbSetOrder(1))
            For ni:=1 to Len(aVinc)
               nPos := AScan(aNewVlCont,{|x| x[1]==aVinc[ni,1]+aVinc[ni,2]+aVinc[ni,3]+aVinc[ni,4]})
               If nPos > 0
                  nSaldoCnt := aNewVlCont[nPos][2]
               Else
                  EF1->(dbSeek(xFilial("EF1")+Left(TIPO_MODULO,1)+aVinc[ni,1]+aVinc[ni,2]+aVinc[ni,3]+aVinc[ni,4]))
                  nSaldoCnt := EF1->EF1_SLD_PM
               EndIf
               If aVinc[ni,5] > nSaldoCnt
                  //MsgInfo("Valor a vincular não pode ser maior que saldo do contrato. "+Trans(EF1->EF1_SLD_PM,AVSX3("EF1_SLD_PM",6))) //
                  If !AP100VlCnt("VALIDA",aVinc[ni,1]+aVinc[ni,2]+aVinc[ni,3]+aVinc[ni,4],nSaldoCnt,aVinc[ni,5],aVinc[ni,6])
                     lSaiVinc := .T.
                     Exit
                  EndIf
               EndIf
            Next ni
            //**

            If !lSaiVinc
               For ni:=1 to Len(aCols)
                  If !Empty(aCols[ni,nColSeqArray]) .and. (nPos := aScan(aVincula, {|x| x[5]==aCols[ni,nColSeqArray]} )) > 0
                     If !Empty(aVincula[nPos,4]) .and.;
                     ( (!Empty(aVincula[nPos,3]) .and. aVincula[nPos,3] <> aCols[ni,GDFieldPos("EF2_CONTRA")]) .or.;
                     (!Empty(aVincula[nPos,13]) .and. aVincula[nPos,13] <> aCols[ni,GDFieldPos("EF2_BAN_FI")]) .or.;
                     (!Empty(aVincula[nPos,14]) .and. aVincula[nPos,14] <> aCols[ni,GDFieldPos("EF3_PRACA")]) .or.;
                     (!Empty(aVincula[nPos,19]) .and. aVincula[nPos,19] <> aCols[ni,GDFieldPos("EF2_SEQCNT")]) )
                        aAdd(aExcVinc,{ If(!Empty(aVincula[nPos,22]), aVincula[nPos,22], aVincula[nPos,10]), aCols[ni,GDFieldPos("EF2_CONTRA")], aCols[ni,nColSeqEF3], aCols[ni,GDFieldPos("EF2_BAN_FI")], aCols[ni,GDFieldPos("EF3_PRACA")], aCols[ni,GDFieldPos("EF2_SEQCNT")], aVincula[nPos,16], TRB->(RecNo()), .T. })
                     EndIf

                     aVincula[nPos,03] := aCols[ni,GDFieldPos("EF2_CONTRA")]
                     aVincula[nPos,14] := aCols[ni,GDFieldPos("EF2_BAN_FI")]
                     aVincula[nPos,15] := aCols[ni,GDFieldPos("EF3_PRACA")]
                     aVincula[nPos,20] := aCols[ni,GDFieldPos("EF2_SEQCNT")]
                     aVincula[nPos,01] := aCols[ni,GDFieldPos("FOBMOE")]
                     aVincula[nPos,11] := aCols[ni,GDFieldPos("DT_VINC")]
                     aVincula[nPos,12] := aCols[ni,GDFieldPos("TX_VINC")]
                     aVincula[nPos,18] := aCols[ni,GDFieldPos("WB_MOEDA")]
                     aVincula[nPos,19] := aCols[ni,GDFieldPos("WB_DT_VEN")]
                     aVincula[nPos,02] := aCols[ni,GDFieldPos("DT_RECEB")]
                     aVincula[nPos,04] := aCols[ni,nColSeqEF3]
                     aVincula[nPos,05] := aCols[ni,nColSeqArray]
                     aVincula[nPos,13] := ""
                  Else
                     aAdd(aVincula,{aCols[ni,GDFieldPos("FOBMOE")], aCols[ni,GDFieldPos("DT_RECEB")], aCols[ni,GDFieldPos("EF2_CONTRA")],;
                                    aCols[ni,nColSeqEF3], aCols[ni,nColSeqArray], TRB->WB_HAWB, TRB->WB_FORN, TRB->WB_LOJA, TRB->WB_INVOICE,;
                                    TRB->WB_LINHA, aCols[ni,GDFieldPos("DT_VINC")], aCols[ni,GDFieldPos("TX_VINC")], "" ,;
                                    aCols[ni,GDFieldPos("EF2_BAN_FI")], aCols[ni,GDFieldPos("EF3_PRACA")], 0, aCols[ni,GDFieldPos("VL_ORI")],;
                                    aCols[ni,GDFieldPos("WB_MOEDA")], aCols[ni,GDFieldPos("WB_DT_VEN")], aCols[ni,GDFieldPos("EF2_SEQCNT")], TRB->(RecNo()), TRB->WB_PARFIN})
                     nSeqArray ++
                  EndIf
                  If nPos > 0  .And.  (nPos := aScan(aExcVinc,{|x| x[1]==If(Empty(aVincula[nPos,10]), aVincula[nPos,22], aVincula[nPos,10]) .and. x[2]==aCols[ni,GDFieldPos("EF2_CONTRA")] .and. x[3]==aCols[ni,nColSeqEF3] .and. x[4]==aCols[ni,GDFieldPos("EF2_BAN_FI")] .and. x[5]==aCols[ni,GDFieldPos("EF3_PRACA")] .and. x[6]==aCols[ni,GDFieldPos("EF2_SEQCNT")] } )) > 0
                     aDel(aExcVinc,nPos)
                     aSize(aExcVinc,LEN(aExcVinc)-1)
                  EndIf
               Next ni

              For nI:= 1 to Len(aCols)//MCF - 06/10/2015
                 If aCols[nI,GDFieldPos("FOBMOE")] > 0
                    nSaldo := TRB->WB_FOBMOE - aCols[nI,GDFieldPos("FOBMOE")]
                    If nSaldo > 0
	                   RegToMemory("TRB",.F.,.F.)
	                   M->WB_FOBMOE := aCols[nI,GDFieldPos("FOBMOE")]
	                   nRecno := TRB->(RECNO())
	                   AP100TrataParc(.F.)
	                   TRB->(DbGoTo(nRecno))
	                   TRB->WB_FOBMOE := aCols[nI,GDFieldPos("FOBMOE")]
	                 Endif
	              Endif
               Next nI

            EndIf
         EndIf
      EndIf

      If !lSaiVinc
         Exit
      EndIf

   EndDo
EndIf

Return .T.

/*
Função      : VincMarkEst()
Objetivo    : Financiamento da Importação - Estornar Vinculação ao contrato de financiamento
Parametro   : lTodos -> Lógico que indica se é para marcar todos (.T.) ou apenas o atual (.F.)
Retorno     : Lógico. Sempre .T.
Autor       : GFC - Gustavo Fabro da Costa Carreiro
Data        : 03/2006.
*/
*----------------------------------------------------------------------------------------------------*
Static Function VincMarkEst(lTodos)
*----------------------------------------------------------------------------------------------------*
Local nInd, cMarca

If lTodos
   If Empty(aCols[1,GDFieldPos("MARCA")])
      cMarca := "X"
   Else
      cMarca := " "
   EndIf

   For nInd := 1 to Len(aCols)
      If !Empty(aCols[nInd,GDFieldPos("EF2_CONTRA")])
         aCols[nInd,GDFieldPos("MARCA")] := cMarca
      EndIf
   Next nInd
ElseIf !Empty(aCols[n,GDFieldPos("EF2_CONTRA")])
   If Empty(aCols[n,GDFieldPos("MARCA")])
      aCols[n,GDFieldPos("MARCA")] := "X"
   Else
      aCols[n,GDFieldPos("MARCA")] := " "
   EndIf
EndIf

Return .T.

/*
Função      : AP100When(cCampo)
Objetivo    : Financiamento da Importação - Validação dos Whens dos campos do SWA e SWB
Parametro   : cCampo - String que indicará para qual campo deve ser validado o When
Retorno     : Lógico. .T. caso o campo possa ser editado e .F. caso não possa
Autor       : GFC - Gustavo Fabro da Costa Carreiro
Data        : 03/2006.
*/
*----------------------------------------------------------------------------------------------------*
Function AP100When(cCampo)
*----------------------------------------------------------------------------------------------------*
Local lRet:=.T.

Do Case
	Case cCampo == "WB_CA_NUM"
		If Select("TRB") > 0 //AAF 06/05/2006 - Impede a verificação quando a rotina é chamada pelo FFC.
			EF3->(dbSetOrder(7))
			If (nManut=4 .or. nManut=6) .and. EF3->(dbSeek(xFilial("EF3")+Left(TIPO_MODULO,1)+TRB->WB_HAWB+TRB->WB_FORN+;
				TRB->WB_LOJA+TRB->WB_INVOICE+If(Empty(TRB->WB_PARFIN),TRB->WB_LINHA,TRB->WB_PARFIN)+EV_EMBARQUE))
				lRet := .F.
			EndIf
		EndIf

	Case cCampo == "WB_FORN"
		If M->WB_PO_DI == "D" .Or. M->WB_PO_DI == "A"
			lRet := .F.
		EndIf

		If SWB->(DbSeek(xfilial("SWB") + M->WA_HAWB))
			M->WB_FORN := SWB->WB_FORN
			M->WB_LOJA := SWB->WB_LOJA
			lRet := .F.
		EndIf
	//Jacomo Lisa - 17/07/2014
	Case SWB->(FieldPos("WB_TPBXFI")) > 0 .AND.  cCampo == "WB_TPBXFI"
	    If nManut <> 6 //Qndo diferente de liquidação, desabilitar a alteraçao do campo
	       Return .F.
	    Endif

        EF3->(dbSetOrder(7)) //EF3_FILIAL+EF3_TPMODU+EF3_HAWB+EF3_FORN+EF3_LOJAFO+EF3_INVIMP+EF3_LINHA+EF3_CODEVE
        EF1->(dbSetOrder(1)) //EF1_FILIAL+EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT
        EF7->(dbSetOrder(1)) //EF7_FILIAL+EF7_FINANC
        If Select("TRB") > 0
           IF !EF3->(dbSeek(xFilial("EF3")+Left(TIPO_MODULO,1)+TRB->WB_HAWB+TRB->WB_FORN+;
			  TRB->WB_LOJA+TRB->WB_INVOICE+If(Empty(TRB->WB_PARFIN),TRB->WB_LINHA,TRB->WB_PARFIN)+EV_EMBARQUE))
			  Return .F.
		   ELSEIF EF1->(DbSeek(xFilial("EF1")+Left(TIPO_MODULO,1)+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT)) .AND.;
		          EF7->(DbSeek(xFilial("EF7")+EF1->TP_FIN))
			  TRB->WB_TPBXFI :=EF7->EF7_TPBXFI
			  lRet := .T.
           ENDIF
        Else
           IF !EF3->(dbSeek(xFilial("EF3")+Left(TIPO_MODULO,1)+M->WB_HAWB+M->WB_FORN+;
			  M->WB_LOJA+M->WB_INVOICE+If(Empty(M->WB_PARFIN),M->WB_LINHA,M->WB_PARFIN)+EV_EMBARQUE))
			  Return .F.
		   ELSEIF EF1->(DbSeek(xFilial("EF1")+Left(TIPO_MODULO,1)+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT)) .AND.;
		          EF7->(DbSeek(xFilial("EF7")+EF1->TP_FIN))
			  TRB->WB_TPBXFI :=EF7->EF7_TPBXFI
			  lRet := .T.
           ENDIF
        Endif
EndCase

Return lRet

/*
Função      : GrvaVincula()
Objetivo    : Financiamento da Importação - Grava array de controle de vinculações
Parametro   :
Retorno     : Lógico. Sempre .T.
Autor       : GFC - Gustavo Fabro da Costa Carreiro
Data        : 03/2006.
*/
*----------------------------------------------------------------------------------------------------*
Static Function GrvaVincula()
*----------------------------------------------------------------------------------------------------*
Local nValTot := 0, nPos := 0, lAddArray := .T., nVlControle:=0, nInd

If EF3->(dbSeek(xFilial("EF3")+Left(TIPO_MODULO,1)+TRB->WB_HAWB+TRB->WB_FORN+TRB->WB_LOJA+TRB->WB_INVOICE+If(Empty(TRB->WB_PARFIN),TRB->WB_LINHA,TRB->WB_PARFIN)+EV_EMBARQUE))
   Do While !EF3->(EOF()) .and. xFilial("EF3")==EF3->EF3_FILIAL .and. EF3->EF3_HAWB==TRB->WB_HAWB .and.;
   EF3->EF3_FORN==TRB->WB_FORN .and. EF3->EF3_LOJAFO==TRB->WB_LOJA .and. EF3->EF3_INVIMP==TRB->WB_INVOICE .and.;
   EF3->EF3_LINHA==If(Empty(TRB->WB_PARFIN),TRB->WB_LINHA,TRB->WB_PARFIN) .and.;
   EF3->EF3_CODEVE == EV_EMBARQUE .and. EF3->EF3_TPMODU == Left(TIPO_MODULO,1) .and. (nValTot < TRB->WB_FOBMOE .Or. nValTot < TRB->WB_PGTANT)

      If (nPos:=aScan(aVincula,{|x| x[16]==EF3->(RecNo())})) > 0
         For nInd:=nPos to Len(aVincula)
            nVlControle += aVincula[nInd,1]
         Next nInd
      EndIf

      If nVlControle < EF3->EF3_VL_INV
         aAdd(aVincula,{(If(TRB->WB_FOBMOE+TRB->WB_PGTANT > (EF3->EF3_VL_INV-nVlControle), (EF3->EF3_VL_INV-nVlControle), TRB->WB_FOBMOE+TRB->WB_PGTANT)),EF3->EF3_DT_FIX,EF3->EF3_CONTRA,;
                         EF3->EF3_SEQ, nSeqArray,TRB->WB_HAWB, TRB->WB_FORN, TRB->WB_LOJA, TRB->WB_INVOICE,;
                         TRB->WB_LINHA, EF3->EF3_DT_EVE, EF3->EF3_TX_MOE, "" ,;
                         EF3->EF3_BAN_FI, EF3->EF3_PRACA ,EF3->(RecNo()),If(TRB->WB_FOBMOE+TRB->WB_PGTANT > (EF3->EF3_VL_INV-nVlControle), (EF3->EF3_VL_INV-nVlControle), TRB->WB_FOBMOE+TRB->WB_PGTANT),;
                         TRB->WB_MOEDA, TRB->WB_DT_VEN, EF3->EF3_SEQCNT, TRB->(RecNo()), TRB->WB_PARFIN})
         nSeqArray += 1
         nValTot += If(TRB->WB_FOBMOE+TRB->WB_PGTANT > (EF3->EF3_VL_INV-nVlControle), (EF3->EF3_VL_INV-nVlControle), TRB->WB_FOBMOE+TRB->WB_PGTANT)
         If (nPoS:=aScan(aParcVinc,{|x| x[1]== EF3->EF3_INVIMP .And. x[2]== EF3->EF3_LINHA  })) = 0
            Aadd(aParcVinc, {EF3->EF3_INVIMP, EF3->EF3_LINHA, TRB->WB_FOBMOE+TRB->WB_PGTANT, EF3->EF3_VL_INV} )
         Endif
      EndIf
      nVlControle := 0
      EF3->(dbSkip())
   EndDo
   If nValTot < TRB->WB_FOBMOE  .Or. nValTot < TRB->WB_PGTANT
      aAdd(aVincula,{(TRB->WB_FOBMOE+TRB->WB_PGTANT) - nValTot,,Space(Len(EF1->EF1_CONTRA)),;
                      Space(Len(EF3->EF3_SEQ)), nSeqArray, TRB->WB_HAWB, TRB->WB_FORN, TRB->WB_LOJA,;
                      TRB->WB_INVOICE, TRB->WB_LINHA, dDataBase,;
                      BuscaTaxa(TRB->WB_MOEDA,dDataBase,,.F.,.T.,,cTX_100), "SALDO",;
                      Space(Len(EF3->EF3_BAN_FI)), Space(Len(EF3->EF3_PRACA)),,(TRB->WB_FOBMOE+TRB->WB_PGTANT) - nValTot,;
                      TRB->WB_MOEDA, TRB->WB_DT_VEN, Space(Len(EF3->EF3_SEQCNT)), TRB->(RecNo()), TRB->WB_PARFIN})
      nSeqArray += 1
   EndIf
Else
   If (nPoS:=aScan(aParcVinc,{|x| x[1]==TRB->WB_INVOICE .And. x[2]==If(Empty(TRB->WB_PARFIN),TRB->WB_LINHA,TRB->WB_PARFIN) })) > 0
      aParcVinc[nPos,3] += TRB->WB_FOBMOE+TRB->WB_PGTANT   // Saldo Vinculado
      If aParcVinc[nPos,3] <= aParcVinc[nPos,4]
         EF3->(dbSeek(xFilial("EF3")+Left(TIPO_MODULO,1)+TRB->WB_HAWB+TRB->WB_FORN+TRB->WB_LOJA+TRB->WB_INVOICE+If(Empty(TRB->WB_PARFIN),TRB->WB_LINHA,TRB->WB_PARFIN)))
         aAdd(aVincula,{(If(TRB->WB_FOBMOE+TRB->WB_PGTANT > (EF3->EF3_VL_INV-nVlControle), (EF3->EF3_VL_INV-nVlControle), TRB->WB_FOBMOE+TRB->WB_PGTANT)),EF3->EF3_DT_FIX,EF3->EF3_CONTRA,;
                         EF3->EF3_SEQ, nSeqArray,TRB->WB_HAWB, TRB->WB_FORN, TRB->WB_LOJA, TRB->WB_INVOICE,;
                         TRB->WB_LINHA, EF3->EF3_DT_EVE, EF3->EF3_TX_MOE, "" ,;
                         EF3->EF3_BAN_FI, EF3->EF3_PRACA ,EF3->(RecNo()),If(TRB->WB_FOBMOE+TRB->WB_PGTANT > (EF3->EF3_VL_INV-nVlControle), (EF3->EF3_VL_INV-nVlControle), TRB->WB_FOBMOE+TRB->WB_PGTANT),;
                         TRB->WB_MOEDA, TRB->WB_DT_VEN, EF3->EF3_SEQCNT, TRB->(RecNo()), TRB->WB_PARFIN})
         nSeqArray += 1
         lAddArray := .F.
      Endif
   Endif
   If lAddArray
      aAdd(aVincula,{(TRB->WB_FOBMOE+TRB->WB_PGTANT) - nValTot, ,Space(Len(EF1->EF1_CONTRA)),;
                      Space(Len(EF3->EF3_SEQ)), nSeqArray, TRB->WB_HAWB, TRB->WB_FORN, TRB->WB_LOJA,;
                      TRB->WB_INVOICE, TRB->WB_LINHA, dDataBase,;
                      BuscaTaxa(TRB->WB_MOEDA,dDataBase,,.F.,.T.,,cTX_100), "",;
                      Space(Len(EF3->EF3_BAN_FI)), Space(Len(EF3->EF3_PRACA)),,(TRB->WB_FOBMOE+TRB->WB_PGTANT) - nValTot,;
                      TRB->WB_MOEDA, TRB->WB_DT_VEN, Space(Len(EF3->EF3_SEQCNT)), TRB->(RecNo()), TRB->WB_PARFIN})
      nSeqArray += 1
   Endif
EndIf

Return .T.

/*
Função      : AP100FieldOk()
Objetivo    : Financiamento da Importação - Valida digitação das informações de vinculação
Parametro   : cField -> Campo a ser editado.
Retorno     : Lógico. Sempre .T.
Autor       : GFC - Gustavo Fabro da Costa Carreiro
Data        : 03/2006.
*/
*-----------------------------------------------------------------------------------------------------------*
Function AP100FieldOk(cField)
*-----------------------------------------------------------------------------------------------------------*
Local lRet := .T., /*cCampo,*/ cContraVal, cBancVal, cPracaVal
Local nPos
PRIVATE lContinua:=.T.  //igor chiba
Private cCampo

If cField = NIL
   cCampo := Right(ReadVar(),Len(ReadVar())-3)
Else
   cCampo := cField
EndIf
If cCampo == "EF2_CONTRA" .or. cCampo == "EF2_BAN_FI" .or. cCampo == "EF3_PRACA" .or. cCampo == "EF2_SEQCNT"

   If cCampo = "EF2_CONTRA" .and. Valtype(cContraVal) == "U"
      cContraVal := M->EF2_CONTRA
   Elseif cCampo = "EF2_BAN_FI" .and. Valtype(cBancVal) == "U"
      cBancVal   := M->EF2_BAN_FI
   Elseif cCampo = "EF3_PRACA" .and. Valtype(cPracaVal) == "U"
      cPracaVal  := M->EF3_PRACA
   Endif

   If cCampo == "EF2_BAN_FI"
      If Empty(aCols[n,GDFieldPos("EF2_CONTRA")]) .and. !Empty(M->EF2_BAN_FI)
         MsgInfo(STR0163+AllTrim(AvSX3("EF2_CONTRA",AV_TITULO))+STR0164)  // "O campo " ### " deve ser digitado primeiro"
         lRet := .f.
      Endif
   ElseIf cCampo == "EF3_PRACA"
      If Empty(aCols[n,GDFieldPos("EF2_BAN_FI")]) .and. !Empty(M->EF3_PRACA)
         MsgInfo(STR0163+AllTrim(AvSX3("EF2_BAN_FI",AV_TITULO))+STR0164) // "O campo " ### " deve ser digitado primeiro"
         lRet := .f.
      Endif
   ElseIf cCampo == "EF2_SEQCNT"
      If Empty(aCols[n,GDFieldPos("EF3_PRACA")]) .and. !Empty(M->EF2_SEQCNT)
         MsgInfo(STR0163+AllTrim(AvSX3("EF3_PRACA",AV_TITULO))+STR0164) // "O campo " ### " deve ser digitado primeiro"
         lRet := .f.
      Endif
   Endif

   If lRet
      If cCampo == "EF2_CONTRA" .and. !Empty(M->EF2_CONTRA)
         If !EF1->(dbSeek(xFilial("EF1")+Left(TIPO_MODULO,1)+M->EF2_CONTRA))
            MsgInfo(AllTrim(AvSX3("EF2_CONTRA",AV_TITULO))+STR0165) // ### " não existe."
            lRet := .F.
         Endif
      ElseIf cCampo == "EF2_BAN_FI" .and. !Empty(M->EF2_BAN_FI)
         If !EF1->(dbSeek(xFilial("EF1")+Left(TIPO_MODULO,1)+aCols[n,GDFieldPos("EF2_CONTRA")]+M->EF2_BAN_FI))
            MsgInfo(AllTrim(AvSX3("EF2_CONTRA",AV_TITULO))+"+"+AllTrim(AvSX3("EF2_BAN_FI",AV_TITULO))+STR0165) // ### " não existe."
            lRet := .f.
         Else
            If SA6->(DBSeek(xFilial("SA6")+M->EF2_BAN_FI))
               aCols[n,GDFieldPos("EF1_DES_FI")] := SA6->A6_NREDUZ
            Endif
         Endif
      ElseIf cCampo == "EF3_PRACA"  .and. !Empty(M->EF3_PRACA)
         If !EF1->(dbSeek(xFilial("EF1")+Left(TIPO_MODULO,1)+aCols[n,GDFieldPos("EF2_CONTRA")]+aCols[n,GDFieldPos("EF2_BAN_FI")]+M->EF3_PRACA))
            MsgInfo(AllTrim(AvSX3("EF2_CONTRA",AV_TITULO))+"+"+AllTrim(AvSX3("EF2_BAN_FI",AV_TITULO))+"+"+AllTrim(AvSX3("EF3_PRACA",AV_TITULO))+STR0165) // ### " não existe."
            lRet := .f.
         Else
            If EF5->(DBSeek(xFilial("EF5")+M->EF3_PRACA))
               aCols[n,GDFieldPos("EF5_DESCRI")] := EF5->EF5_DESCRI
            Endif
         Endif
      ElseIf cCampo == "EF2_SEQCNT"  .and. !Empty(M->EF2_SEQCNT)
         If !EF1->(dbSeek(xFilial("EF1")+Left(TIPO_MODULO,1)+aCols[n,GDFieldPos("EF2_CONTRA")]+aCols[n,GDFieldPos("EF2_BAN_FI")]+aCols[n,GDFieldPos("EF3_PRACA")]+M->EF2_SEQCNT))
            MsgInfo(AllTrim(AvSX3("EF2_CONTRA",AV_TITULO))+"+"+AllTrim(AvSX3("EF2_BAN_FI",AV_TITULO))+"+"+AllTrim(AvSX3("EF3_PRACA",AV_TITULO))+"+"+AllTrim(AvSX3("EF2_SEQCNT",AV_TITULO))+STR0165) // ### " não existe."
            lRet := .f.
         Endif
      Endif

      If cCampo = "EF2_CONTRA" .and. lRet
         If !Empty(EF1->EF1_DT_ENC)
            MsgInfo(STR0166+Alltrim(EF1->EF1_CONTRA)+" "+STR0147+Dtoc(EF1->EF1_DT_ENC))  // "O contrato " ### "já foi Encerrado em: " ###
            lRet := .F.
         Else
            If Empty(aCols[n,GDFieldPos("EF2_BAN_FI")]) .or. Empty(aCols[n,GDFieldPos("EF3_PRACA")]) .or.;
            Empty(aCols[n,GDFieldPos("EF2_SEQCNT")])
               aCols[n,GDFieldPos("EF2_BAN_FI")] := EF1->EF1_BAN_FI
               If SA6->(DBSeek(xFilial("SA6")+aCols[n,GDFieldPos("EF2_BAN_FI")]))
                  aCols[n,GDFieldPos("EF1_DES_FI")] := SA6->A6_NREDUZ
               Endif
               aCols[n,GDFieldPos("EF3_PRACA")] := EF1->EF1_PRACA
               If EF5->(DBSeek(xFilial("EF5")+aCols[n,GDFieldPos("EF3_PRACA")]))
                  aCols[n,GDFieldPos("EF5_DESCRI")] := EF5->EF5_DESCRI
               Endif
               aCols[n,GDFieldPos("EF2_SEQCNT")] := EF1->EF1_SEQCNT
            EndIf
         EndIf
      Endif

      If lRet
         If !Empty(EF1->EF1_DT_JUR)
            MsgInfo(STR0168)  // "Não é possível vincular a invoice, pois a data de inicio do juros está preenchida no contrato."
            lRet := .F.
         ElseIf lRet .and. TRB->WB_DT_VEN > EF1->EF1_DT_VEN
            MsgInfo(STR0169+Alltrim(TRB->WB_INVOICE)+" "+STR0170+" "+Alltrim(TRB->WB_LINHA)+STR0171) //"Invoice" # "Parcela" # "possui data de vencimento maior que a data limite para vinculação."
         EndIf
      EndIf

   Endif

ElseIf cCampo == "FOBMOE"
   If Empty(aCols[n,GDFieldPos("EF2_CONTRA")])
      MsgInfo(STR0172)  // "Campo só pode ser alterado caso parcela esteja vinculada a um contrato."
      lRet := .F.
   ElseIf M->FOBMOE <= 0
      Help(" ",1,"AVG0005232")  // "Valor deve ser maior que zero."
      lRet := .F.
   ElseIf M->FOBMOE > aCols[n,GDFieldPos("VL_ORI")]
      MsgInfo(STR0173)  // "Valor maior que o saldo da parcela."
      lRet := .F.
   ElseIf EF1->(dbSeek(xFilial("EF1")+Left(TIPO_MODULO,1)+aCols[n,GDFieldPos("EF2_CONTRA")]+aCols[n,GDFieldPos("EF2_BAN_FI")]+aCols[n,GDFieldPos("EF3_PRACA")]+aCols[n,GDFieldPos("EF2_SEQCNT")])) .and. M->FOBMOE > EF1->EF1_SLD_PM
      MsgInfo(STR0174+" "+Trans(EF1->EF1_SLD_PM,AVSX3("EF1_SLD_PM",6)))  // "Valor a vincular não pode ser maior que saldo do contrato." ###
      lRet := .F.
   /*ElseIf M->FOBMOE < aCols[n,GDFieldPos("FOBMOE")] //Nopado por MCF - 06/10/2015 - Não gerar parcela automatica
      nAux := aCols[n,GDFieldPos("FOBMOE")] - M->FOBMOE
      aCols[n,GDFieldPos("FOBMOE")] := M->FOBMOE
      If (nPos := aScan(aCols,{|x| Empty(x[GDFieldPos("EF2_CONTRA")]) })) > 0 .and.;
      (nPos<>n .or. (nPos := aScan(aCols,{|x| Empty(x[GDFieldPos("EF2_CONTRA")]) }, n+1)) > 0)
         aCols[nPos,GDFieldPos("FOBMOE")] += nAux
      Else
         aAdd(aCols,aClone(aCols[n]))
         nPos := Len(aCols)
         aCols[nPos,GDFieldPos("FOBMOE")]     := nAux
         aCols[nPos,GDFieldPos("EF2_CONTRA")] := Space(Len(EF2->EF2_CONTRA))
         aCols[nPos,GDFieldPos("EF2_BAN_FI")] := Space(Len(EF2->EF2_BAN_FI))
         aCols[nPos,GDFieldPos("EF1_DES_FI")] := ""
         aCols[nPos,GDFieldPos("EF3_PRACA")]  := Space(Len(EF3->EF3_PRACA))
         aCols[nPos,GDFieldPos("EF5_DESCRI")] := ""
         aCols[nPos,GDFieldPos("EF2_SEQCNT")] := Space(Len(EF2->EF2_SEQCNT))
         aCols[nPos,GDFieldPos("TX_VINC")]    := aCols[n,GDFieldPos("TX_VINC")]
         aCols[nPos,GDFieldPos("DT_VINC")]    := dDataBase
         //** PLB 27/02/07 - Walk-Thru
         aCols[nPos,GDFieldPos("EF3_ALI_WT")] := ""
         aCols[nPos,GDFieldPos("EF3_REC_WT")] := 0
         //**
         aCols[nPos,nColSeqEF3]               := ""
         aCols[nPos,nColSeqArray]             := ""
      EndIf
      oGetDados:ForceRefresh()*/
   EndIf

ElseIf cCampo == "LIQEST"
   If lEFFTpMod .and. lEIC_EFF .and. (nPos:=aScan(aVincula,{|x| x[10]==If(Empty(TRB->WB_PARFIN), TRB->WB_LINHA, TRB->WB_PARFIN)}))>0 .and.;
   !Empty(aVincula[nPos,3]) .And. EF1->(dbSeek(xFilial("EF1")+Left(TIPO_MODULO,1)+aVincula[nPos,3]+aVincula[nPos,14]+aVincula[nPos,15]+aVincula[nPos,20]))
      If !Empty(EF1->EF1_DT_ENC)
         Msginfo(STR0146+" ("+Alltrim(EF1->EF1_CONTRA)+") "+STR0147+DtoC(EF1->EF1_DT_ENC))  //"Liquidação não pode ser estornada pois o Contrato de Financiamento " ### "já foi Encerrado em: " ###
         lRet := .F.
      ElseIf !Empty(EF1->EF1_DT_JUR)  // PLB 25/10/06
         Msginfo(STR0146+" ("+Alltrim(EF1->EF1_CONTRA)+") "+STR0148)  //"Liquidação não pode ser estornada pois o Contrato de Financiamento " ### " está com a Data de Início de Juros preenchida."
         lRet := .F.
      EndIf
   EndIf
   If !AP100NAOContab(ESTORNO, .F.)
      lRet:= .F.
   EndIf

   If AvFlags("EAI_PGANT_INV_NF")
      If TRB->WB_EVENT == "608" .And. !Empty(TRB->WB_NUMDUP) //o título efetivo é criado e compensado
         MsgInfo(STR0363, STR0063) //"Este título foi compensado com a emissão da nota fiscal e não pode ser estornado manualmente.", Atenção
         lRet:= .F.
      EndIf
   EndIf

   If lRet .And. AvFlags("EIC_EAI")
      /* Consistir o envio da sequencia de baixa de forma a esclarecer ao usuário
         que o estorno deve ser realizado de forma reversa a execução da baixa: da
         última para a primeria. */
      lRet:= AP112ValidSeqBaixa()
   EndIf

    If TRB->WB_SLDELI > 0
        MsgInfo(STR0381, STR0063)// "Existe saldo eliminado no item liquidado. Para estornar a liquidação, estorne o saldo eliminado."
        lRet := .F.
    EndIf

   If lRet .And. lCposAntecip
        AP100GrvWork()
   EndIf
ElseIf Left(cCampo,3) == "LIQ"
   If lEFFTpMod .and. lEIC_EFF
      If (nPos:=aScan(aVincula,{|x| x[3]==If(Empty(TRB->WB_PARFIN), TRB->WB_LINHA, TRB->WB_PARFIN)}))>0 .and.;
      !Empty(aVincula[nPos,3]) .And. EF1->(dbSeek(xFilial("EF1")+Left(TIPO_MODULO,1)+aVincula[nPos,3]+aVincula[nPos,14]+aVincula[nPos,15]+aVincula[nPos,20])) .And. !Empty(EF1->EF1_DT_ENC)
         Msginfo(STR0175+" ("+Alltrim(EF1->EF1_CONTRA)+") "+STR0147+DtoC(EF1->EF1_DT_ENC))  // "Parcela não pode ser liquidada pois o Contrato" ### "já foi Encerrado em: "
         lRet := .F.
      EndIf
   EndIf

ElseIf cCampo == "VINC"
   If !Empty(TRB->WB_CA_DT)
      MsgInfo(STR0167)  // "Parcela não pode ser alterada pois está liquidada."
      lRet := .F.
   ElseIf lWB_EVENT .AND. TRB->WB_EVENT <> PRINCIPAL
      MsgInfo(STR0176+PRINCIPAL+".") //"Não é possível efetuar a Vinculação para Eventos diferentes de '101'"###"Aviso"
      lRet := .F.
   ElseIf TRB->WB_PO_DI == "D" .and. Left(TRB->WB_TIPOREG,1) == "P"
      MsgInfo(STR0177)  // "Parcelas de adiantamento não podem ser vinculadas a um contrato de financiamento."
      lRet := .F.
   EndIf

ElseIf cCampo == "VINCEST"
   If (nPos:=aScan(aVincula,{|x| x[9]==TRB->WB_INVOICE .and. x[10]==TRB->WB_LINHA })) = 0
      lRet:=.F.
      MsgInfo(STR0178,STR0179)  // "A Parcela não está Vinculada!" , "Estorno Impossibilitado..."
   EndIf
   If lRet
      If !Empty(TRB->WB_CA_DT)
         MsgInfo(STR0180,STR0179)  // "A Parcela já está Liquidada!" , "Estorno Impossibilitado..."
         lRet:= .F.
      ElseIf !Empty(TRB->WB_PARFIN)
         nRec     := TRB->(RecNo())
         cCharAux := TRB->WB_PARFIN
         TRB->(dbGoTop())
         Do While !TRB->(EOF())
            If TRB->WB_PARFIN == cCharAux .and. !Empty(TRB->WB_CA_DT)
               MsgInfo(STR0181,STR0179)  // "Esta parcela faz parte de uma vinculação maior que já foi parcialmente liquidada." , "Estorno Impossibilitado..."
               lRet := .F.
               Exit
            EndIf
            TRB->(dbSkip())
         EndDo
         TRB->(dbGoTo(nRec))
      Endif
   EndIf
ElseIf cCampo == "DT_VINC"
      EF1->(DBSETORDER(1))
      If Empty(M->DT_VINC)
         MsgInfo(STR0182+STR0184)  // "Data de Vinculação" " deve ser preenchida."
         lRet := .F.
      ElseIf EF1->(dbSeek(xFilial("EF1")+Left(TIPO_MODULO,1)+aCols[n,GDFieldPos("EF2_CONTRA")]+aCols[n,GDFieldPos("EF2_BAN_FI")]+aCols[n,GDFieldPos("EF3_PRACA")]+aCols[n,GDFieldPos("EF2_SEQCNT")])) .and. M->DT_VINC < EF1->EF1_DT_JUR
         MsgInfo(STR0182+STR0183+" "+Dtoc(EF1->EF1_DT_JUR))  // "Data de Vinculação" " deve ser maior que a data de início de juros " ###
         lRet := .F.
      ElseIf !Empty(TRB->WB_DT_DESE) .and. M->DT_VINC < TRB->WB_DT_DESE
         MsgInfo(STR0182+STR0185+" ("+DtoC(TRB->WB_DT_DESE)+")")  // "Data de Vinculação" " não pode ser menor que a Data de Desembaraço."
         lRet := .F.
      ElseIf M->DT_VINC > dDataBase
         MsgInfo(STR0182+STR0186)  // "Data de Vinculação" " não pode ser maior que a data corrente do sistema."
         lRet := .F.
      Else
         aCols[n,GDFieldPos("TX_VINC")] := BuscaTaxa(TRB->WB_MOEDA,M->DT_VINC,,.F.,.T.,,cTX_100)
      EndIF
ElseIf cCampo == "TX_VINC"
      If !(M->TX_VINC > 0)
         Help(" ",1,"AVG0005232") //MsgInfo("Valor deve ser maior que zero.")
         lRet := .F.
      EndIf
EndIf
//**igor chiba  bloqueando alteração em parcelas que não tenham n° titulo  29/09/09
IF lRet  .AND.  LCAMBIO_EIC
   //IF EMPtY(TRB->WB_TITERP)  //SE MUDOU ALGUM VALOR QUE Ñ PD OU NAO TEM TITULO NAO PODE ALTERAR MURO
   //IF IIF(lIntegStat, TRB->WB_TITRET$cNao, EMPtY(TRB->WB_TITERP) )    // PLB 15/04/10 - Status de Retorno do ERP
   IF IIF(lIntegStat, TRB->WB_TITRET$cNao, .F. )    // PLB 15/04/10 - Status de Retorno do ERP
      //lContinua:=.T.
      IF TRB->WB_PO_DI ='D'.AND. lEICFI05
         //MSGINFO('Cambio nao pode ser manipulado por nao possuir número do titulo.')
         MSGINFO(STR0242)  // PLB 15/04/10 - Status de Processamento //STR0242 'Cambio nao pode ser manipulado pois não houve retorno do ERP.'
         lRet := .F.
//        ELSEIF TRB->WB_PO_DI ='A'.AND. lEICFI08
        ELSEIF (TRB->WB_PO_DI ='A' .Or. TRB->WB_PO_DI ='F') .AND. lEICFI08	// GCC - 27/08/2013
         //MSGINFO('Pagto.Antecipado nao pode ser manipulado por nao possuir número do titulo.')
         MSGINFO(STR0243)  // PLB 15/04/10 - Status de Processamento //STR0243 'Pgto.Antecipado nao pode ser manipulado pois não houve retorno do ERP.'
         lRet := .F.
      ENDIF
   ENDIF
ENDIF
//**

lContinua := lRet
IF(EasyEntryPoint("EICAP100"),Execblock("EICAP100",.F.,.F.,"FIELDOK"),)
lRet:=lContinua

Return lRet

/*
Função      : AtuVincEF3()
Objetivo    : Financiamento da Importação - Atualiza Vinculo com o EF3
Parametro   : cTipo     -> Tipo da rotina, "EXCLUIR" para estorno da vinculação e "INCLUIR" para vinculação.
              nPosArray -> Possição no Array.
Retorno     : Lógico. Sempre .T.
Autor       : GFC - Gustavo Fabro da Costa Carreiro
Data        : 03/2006.
*/
*-------------------------------------------------------------------------------------------------------*
Static Function AtuVincEF3(cTipo,nPosArray)
*-------------------------------------------------------------------------------------------------------*
Local cSeq, cCont
Local nOrdemEF3 := EF3->(IndexOrd())
Local cBanco, cAgencia, cConta, cSeqCnt

If(nPosArray=NIL,nPosArray:=0,)

EF3->(DbSetOrder(4))

If cTipo=="EXCLUIR"
   EF3->(dbGoTo(aExcVinc[nPosArray,7]))
   If ! (EF3->(EOF()) .and. EF3->(BOF()))
      cSeq    := EF3->EF3_SEQ
      cCont   := EF3->EF3_CONTRA
      cBanc   := EF3->EF3_BAN_FI
      cPrac   := EF3->EF3_PRACA
      cSeqCnt := EF3->EF3_SEQCNT
      EF3->(dbSeek(xFilial("EF3")+Left(TIPO_MODULO,1)+cCont+cBanc+cPrac+cSeqCnt+cSeq))

      EF1->(dbSeek(xFilial("EF1")+Left(TIPO_MODULO,1)+cCont+cBanc+cPrac+cSeqCnt))

      If FindFunction("EFFEX101") //AvFlags("SIGAEFF_SIGAFIN")
         oEFFContrato := AvEFFContra():LoadEF1()
      EndIf

      Do While !EF3->(EOF()) .and. EF3->EF3_FILIAL==xFilial("EF3") .and. EF3->EF3_TPMODU==Left(TIPO_MODULO,1) .and.;
      EF3->EF3_CONTRA+EF3->EF3_BAN_FI+EF3->EF3_PRACA+EF3->EF3_SEQCNT==cCont+cBanc+cPrac+cSeqCnt .and.;
      EF3->EF3_SEQ == cSeq

         EX400AtuSaldos("VIN",,,"IMP")

         If cTipo == "EXCLUIR" .and. EF3->EF3_CODEVE == EV_EMBARQUE  .And.  aExcVinc[nPosArray][9]
            EX400MotHis("VIN",EF1->EF1_CONTRA,EF1->EF1_BAN_FI,EF1->EF1_PRACA,EF1->EF1_TP_FIN, , EF3->EF3_INVIMP, EF3->EF3_LINHA, EF3->EF3_CODEVE, EF3->EF3_SEQ, TIPO_MODULO, EF1->EF1_SEQCNT, "SWB", EF3->EF3_FORN, EF3->EF3_LOJAFO)
         EndIf

         If FindFunction("EFFEX101") //AvFlags("SIGAEFF_SIGAFIN")
            oEFFContrato:EventoEF3("ESTORNO")
         EndIf

         EF3->(RecLock("EF3",.F.))
         If !Empty(EF3->EF3_NR_CON)
            EF3->EF3_EV_EST := EF3->EF3_CODEVE //EF3->(DBDELETE())
            EF3->EF3_DT_EST := dDataBase
            EF3->EF3_CODEVE := EV_ESTORNO
            EF3->EF3_NR_CON := Space(Len(EF3->EF3_NR_CON))
         Else
            EF3->(dbDelete())
         EndIf
         EF3->(msUnlock())
         EF3->(dbSkip())
      EndDo
      TRB->(dbGoTo(aExcVinc[nPosArray,8]))
      If !TRB->(EOF()) .and. !TRB->(BOF()) .and. Alltrim(TRB->WB_CA_NUM) == Alltrim(cCont)
         TRB->WB_CA_NUM := ""
         TRB->WB_NR_ROF := ""
      EndIf
   EndIf

ElseIf cTipo == "INCLUIR" .and. !Empty(aVincula[nPosArray,3]) .and. Empty(aVincula[nPosArray,4])

   EF1->(dbSeek(xFilial("EF1")+Left(TIPO_MODULO,1)+aVincula[nPosArray,3]+aVincula[nPosArray,14]+aVincula[nPosArray,15]+aVincula[nPosArray,20]))

   EX400GrvEventos(EF1->EF1_CONTRA,TRB->WB_INVOICE, TRB->WB_HAWB, aVincula[nPosArray,1], dDataBase,;
   TRB->WB_MOEDA,aVincula[nPosArray,10],EF1->EF1_MOEDA,"EF1","EF3","CAMB",,aVincula[nPosArray,12],aVincula[nPosArray,11],If(lMulTiFil,xFilial("SWB"),Nil),;
   aVincula[nPosArray,14],aVincula[nPosArray,15], ,Left(TIPO_MODULO,1),EF1->EF1_SEQCNT, "SWB", TRB->WB_FORN, TRB->WB_LOJA, TRB->WB_PO_DI)

   //Atualiza o número da operação e o banco na fatura
   cBanco  := EF1->EF1_BAN_FI
   cAgencia:= EF1->EF1_AGENFI
   cConta  := EF1->EF1_NCONFI
   If !Empty(EF1->EF1_BAN_MO)
      cBanco  := EF1->EF1_BAN_MO
      cAgencia:= EF1->EF1_AGENMO
      cConta  := EF1->EF1_NCONMO
   Endif

   //** PLB 25/10/06 - Verifica se está desposicionado no SWB
   If SWB->( EoF() )  .And.  nNewRecSWB != 0
      SWB->( DBGoTo(nNewRecSWB) )
   EndIf
   //**

   SWB->(RecLock("SWB",.F.))
   If Alltrim(SWB->WB_CA_NUM) <> Alltrim(EF1->EF1_CONTRA) .Or.;
      Alltrim(SWB->WB_BANCO)  <> Alltrim(cBanco) .Or.;
      Alltrim(SWB->WB_AGENCIA)<> Alltrim(cAgencia) .or.;
      Alltrim(SWB->WB_NR_ROF) <> Alltrim(EF1->EF1_ROF) // .Or.;
//      Alltrim(TRB->WB_CONTA)  <> Alltrim(cConta)

      If(Empty(SWB->WB_CA_NUM) ,SWB->WB_CA_NUM := EF1->EF1_CONTRA,)
      If(Empty(SWB->WB_NR_ROF) ,SWB->WB_NR_ROF := EF1->EF1_ROF,)
      If(Empty(SWB->WB_BANCO)  ,SWB->WB_BANCO  := cBanco,)
      If(Empty(SWB->WB_AGENCIA),SWB->WB_AGENCIA:= cAgencia,)
      //If(Empty(TRB->WB_CONTA)  ,TRB->WB_CONTA  := cConta,)
   Endif
   SWB->(msUnlock())

EndIf

EF3->(DbSetOrder(nOrdemEF3))

Return .T.

/*
Funcao      : AP1EstLiq()
Parametros  : cSeq - Sequencia do lançamento no EF3.
Retorno     : Lógico, sempre .T.
Objetivos   : Estorno da Liquidação.
Autor       : Gustavo Carreiro - GFC.
Data        : 31/03/2006
*/
*-----------------------------------------------------*
Function AP1EstLiq(cSeq,nPos)
*-----------------------------------------------------*
Local nOrd := EF3->(IndexOrd()), nRec := EF3->(RecNo())

cFilEF3 := xFilial("EF3")
EF3->(dbSetOrder(4))
EF3->(dbSeek(xFilial("EF3")+Left(TIPO_MODULO,1)+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+EF1->EF1_SEQCNT+cSeq))
Do While EF3->(!Eof()) .And. EF3->EF3_FILIAL == xFilial("EF3") .And. EF3->EF3_TPMODU==Left(TIPO_MODULO,1) .and.;
EF1->EF1_CONTRA == EF3->EF3_CONTRA .and. EF3->EF3_SEQ == cSeq .and.;
EF3->EF3_BAN_FI+EF3->EF3_PRACA+EF3->EF3_SEQCNT==aVincula[nPos,14]+aVincula[nPos,15]+aVincula[nPos,20]
   EX400AtuSaldos("LIQ",,,"IMP")
   If EF3->EF3_CODEVE == EV_LIQ_PRC
      EX400MotHis("LIQ", EF1->EF1_CONTRA, EF1->EF1_BAN_FI, EF1->EF1_PRACA, EF1->EF1_TP_FIN, , EF3->EF3_INVIMP, EF3->EF3_LINHA, EF3->EF3_CODEVE, EF3->EF3_SEQ, TIPO_MODULO, EF1->EF1_SEQCNT, "SWB", EF3->EF3_FORN, EF3->EF3_LOJAFO)
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
EndDo
EF3->(dbSetOrder(nOrd))
EF3->(dbGoTo(nRec))

Return .T.

/*
Funcao      : AP100TrataParc()
Parametros  : lAutomatico - Indica se a quebra da parcela foi automatica (.T.) ou manual via alteração (.F., default).
Retorno     : Nil.
Objetivos   : Quebra de Parcelas.
Autor       : Gustavo Carreiro - GFC.
Data        : 31/03/2006
Revisão     : Thiago Rinaldi Pinto
Data        : 09/06/2010
*/
*------------------------------------------*
Static Function AP100TrataParc(lAutomatico)
*------------------------------------------*
Local nRec := 0, nVlAtual:= 0, nVlOld := 0, cNumParc:=0, nPos:=0, nTxvAux:=0
Local lRet:=.t., aOrd, cParc, cOrigem, nRecTemp:=0, dDtVincAux:=AvCtoD("  /  /  ")
Local cSequAux:=If(lEffTpMod .and. lEIC_EFF,Space(Len(EF3->EF3_SEQ)),""),;
      cContrAux:=If(lEffTpMod .and. lEIC_EFF,Space(Len(EF3->EF3_CONTRA)),"")

Local cBanco := If(lEffTpMod .and. lEIC_EFF .and. lTemChave, Space(Len(EF3->EF3_BAN_FI)),"")
Local cPraca := If(lEffTpMod .and. lEIC_EFF .and. lTemChave, Space(Len(EF3->EF3_PRACA)),"")

Local lTemDiferenca := .f.

//Variáveis utilizadas para o financiamento
Local ni, nVlArrayEEQ:=0, cParFinAux, nVlParfin:=0, nRecAux, nVlParAux:=0, nx, cParcAux:=""

Local aSaveOrd      := SaveOrd({"TRB", "EF3"})
Local nVlAjuste     := 0
Local nTotParcAgrup := 0

Local cWorkEEQContra:= ""

Local aParcAgrup    := {}
Local aParcela      := {}
Local cEvento
Local cInvoice

Local lVinculada := .F.

Local cParcWB
Local cNumDupWB
Private lWB_EVENT := SWB->(FieldPos("WB_EVENT")) > 0

If(lAutomatico=NIL,lAutomatico:=.F.,)
If(lWB_EVENT, cEvento := TRB->WB_EVENT, )

Begin Sequence

   For nPos := 1 To TRB->(fCount())
      aAdd(aParcela, TRB->(FieldGet(nPos)))
   Next

   nRecIni  := TRB->(RecNo())
   //** JWJ - Ajuste para considerara o pgto antecipado nos calculos: 11/10/2006
   nVlAtual := M->WB_FOBMOE + M->WB_PGTANT
   nVlOld   := TRB->WB_FOBMOE + TRB->WB_PGTANT
   //**

   /*
   Reprogramação de Recebimentos/Vencimentos p/ mais de duas parcelas.
   */

   nVlAjuste := (nVlOld - nVlAtual)  //TRP - 09/06/10 - Valor de Ajuste - Diferenca do valor gravado para o novo valor informado.

   cParcAux  := TRB->WB_LINHA
   cInvoice  := TRB->WB_INVOICE


   //** PLB 20/04/07 - Caso a parcela esteja vinculada força a criação de uma nova parcela
   If lEIC_EFF
      lVinculada := ( nPos := aScan(aVincula,{|x| x[9]==TRB->WB_INVOICE .and. x[10]==If(Empty(TRB->WB_PARFIN), TRB->WB_LINHA, TRB->WB_PARFIN)}) ) > 0  .And.  !Empty(aVincula[nPos,3])
   EndIf
   //**

   If nVlAjuste = 0
      Break
   EndIf

   If lCposAntecip
      TRB->(dbSetOrder(5))
   Else
      TRB->(dbSetOrder(4))
   EndIf
   TRB->(dbSkip())

   /*
   Ajuste Positivo
   */
   If nVlAjuste > 0

      cParc := M->WB_LINHA

      /*
      Procura abaixo da parcela alterada, uma parcela em aberto. Encontrando, a mesma tera no
      seu valor, acrescido o valor de ajuste.
      */
      //IncParcInvo("1")
      Do While TRB->(!Eof()) .and. TRB->WB_INVOICE == cInvoice .and. !lAutomatico  .And.  IIF(lEIC_EFF, !lVinculada, .T. ) .AND. M->WA_PO_DI == "D"  // GFP - 17/04/2014

         Private lAceita := .T. //AAF 30/10/2008 - Para uso em rdmakes.

         If lWB_EVENT .and. TRB->WB_EVENT <> cEvento
            TRB->(dbSkip())
            Loop
         EndIf

         // PLB 20/04/07 - Caso a parcela esteja vinculada não ocorre a distribuição do ajuste
         If lEIC_EFF  .And.  ( nPos := aScan(aVincula,{|x| x[9]==TRB->WB_INVOICE .and. x[10]==If(Empty(TRB->WB_PARFIN), TRB->WB_LINHA, TRB->WB_PARFIN)}) ) > 0  .And.  !Empty(aVincula[nPos,3])
            TRB->(dbSkip())
            Loop
         EndIf

          // PLB 18/05/10 - Caso a Parcela já tenha Título no ERP ou ainda não tenha recebido o retorno do título
         IF LCAMBIO_EIC  .AND.  ( !EMPTY(TRB->WB_TITERP)  .OR.  IIF(lIntegStat, TRB->WB_TITRET$cNao, .F. ) )
            TRB->(dbSkip())
            Loop
         EndIf
         //** AAF 30/10/2008
         IF EasyEntryPoint("EICAP100")
            ExecBlock("EICAP100",.F.,.F.,"SELECAO_PARCELA_QUEBRA")
         ENDIF
         //**

         If !lAceita
            TRB->(dbSkip())
            Loop
         EndIf

         If Empty(TRB->WB_CA_DT)
            TRB->WB_FOBMOE += nVlAjuste
            Exit
         EndIf

         TRB->(dbSkip())

      EndDo

      /*
      Não encontrando a parcela em aberto é criada uma parcela igual a alterada com o valor
      do ajuste.
      */
      If (TRB->(Eof()) .or. lAutomatico  .Or.  IIF(lEIC_EFF,lVinculada,.F.) .Or. TRB->WB_INVOICE # cInvoice) .OR. M->WA_PO_DI <> "D"  // GFP - 17/04/2014

         TRB->(dbGoTo(nRecIni)) //Posiciona na parcela alterada.

         /*
         Calcula e atualiza variaveis para parcelas de financiamento.
         */
         If lEIC_EFF
            nPos := aScan(aVincula,{|x| x[9]==TRB->WB_INVOICE .and. x[10]==If(Empty(TRB->WB_PARFIN), TRB->WB_LINHA, TRB->WB_PARFIN)})
            If nPos>0
               For ni:=nPos to Len(aVincula)
                  If aVincula[ni,10]==If(Empty(TRB->WB_PARFIN), TRB->WB_LINHA, TRB->WB_PARFIN) .and. !Empty(aVincula[ni,3])
                     nVlArrayEEQ += aVincula[ni,1]
                  EndIf
               Next ni
               nVlParAux:=0
               //If !Empty(aVincula[nPos,3]) .and. nVlAtual < nVlArrayEEQ - Nopado por MCF - 06/10/2015
                  cContrAux     := aVincula[nPos,3]
                  cBanco        := aVincula[nPos,14]
                  //** PLB 20/04/07 - Atualiza arrays referente vinculações com o financiamento para regerar as parcelas
                  aVincula[nPos][1]  := nVlAtual
                  aVincula[nPos][4]  := ""
                  aVincula[nPos][17] := nVlAtual
                  AAdd(aVincula,AClone(aVincula[nPos]))
                  aVincula[Len(aVincula)][1]  := nVlAjuste
                  aVincula[Len(aVincula)][17] := nVlAjuste
                  aVincula[Len(aVincula)][5]  := aVincula[Len(aVincula)-1][5] + 1 //MCF - 06/10/2015
                  aVincula[Len(aVincula)][21] := TRB->( RecNo() )
                  aVincula[Len(aVincula)][3]  :=  Space(Len( aVincula[Len(aVincula)][3]))
                  aVincula[Len(aVincula)][15] := Space(Len( aVincula[Len(aVincula)][15]))
                  aVincula[Len(aVincula)][14] := Space(Len( aVincula[Len(aVincula)][14]))
                  aVincula[Len(aVincula)][20] := Space(Len( aVincula[Len(aVincula)][20]))
                  //AAdd(aExcVinc, {If(!Empty(aVincula[nPos,22]), aVincula[nPos,22], aVincula[nPos,10]), aVincula[nPos,3], aVincula[nPos,4], aVincula[nPos,14], aVincula[nPos,15], aVincula[nPos,20], aVincula[nPos,16], TRB->(RecNo()),.F. }) // Nopado por MCF - 06/10/2015
                  //**
               //EndIf
               cSequAux        := aVincula[nPos,4]
               dDtVincAux      := aVincula[nPos,11]
               nTxvAux         := aVincula[nPos,12]
               cPraca          := aVincula[nPos,15]
            EndIf
         EndIF

         If TRB->(FieldPos("WB_NUMDUP")) > 0
            cNumDupWB:= TRB->WB_NUMDUP
         EndIf

         /*
         Recupera o número da ultima parcela.
         */
         TRB->(dbSetOrder(6))
         TRB->(DbGoBottom())
         cNumParc := TRB->(WB_LINHA)

         TRB->(dbAppend())

         /*
         A parcela criada, irá conter os dados sem alteração da parcela alterada.
         */
         For nPos := 1 To Len(aParcela)
            TRB->(FieldPut(nPos, aParcela[nPos]))
         Next

         TRB->WB_PREFIXO := ""
         TRB->WB_TIPOTIT := ""

         If	LCAMBIO_EIC
         	TRB->WB_TITERP	:=	""
         	TRB->WB_TITRET	:=	"1"  // PLB 15/04/10 - Status de Retorno do ERP
         EndIf
         //TRP-02/09/08
         //cParcela := IncParcInvo("2",nVlAjuste > 0)

         If TRB->(FieldPos("WB_PARCELA")) > 0
            TRB->WB_PARCELA := ""
         Else
            Return .T.
         EndIf

         If TRB->(FieldPos("WB_NUMDUP")) > 0
            If  AvFlags("EIC_EAI")
               TRB->WB_NUMDUP:= ""
            Else
               TRB->WB_NUMDUP:= cNumDupWB
            EndIf
         EndIf

         If TRB->(FieldPos("WB_DESCO")) # 0  // GFP - 21/08/2015
	         TRB->WB_DESCO := 0
	      EndIf
	      If TRB->(FieldPos("WB_VLIQ")) # 0  // GFP - 21/08/2015
	         TRB->WB_VLIQ := 0
	      EndIf


         TRB->(If(M->WA_PO_DI <> "D", WB_PGTANT := nVlAjuste, WB_FOBMOE  := nVlAjuste),;
               WB_LINHA   := Soma1(cNumParc,Len(SWB->WB_LINHA)),;
               WB_ORIGEM  := M->WB_LINHA,;
               WB_RECNO   := 0)

         TRB->TRB_ALI_WT:= "SWB"
         TRB->TRB_REC_WT:= 0

         /*
         Inicio da gravação da parcela de financiamento.
         */

         If lAutomatico
            aVincula[nSeqArray-1,10] := TRB->WB_LINHA
         EndIf
         If lEIC_EFF

            //** PLB 23/04/07
            If Len(aVincula) > 0 //NCF - 19/04/2016             //If lVinculada //MCF - 06/10/2015
               aVincula[Len(aVincula)][10] := TRB->WB_LINHA
            EndIf
            //**

            //** GFC - Será apurado a seguir se é parcela de financiamento
            TRB->WB_PARFIN := ""
            TRB->WB_CA_NUM := ""
            //**

            EF3->(dbSetOrder(7))
            IF EF3->(dbSeek(xFilial("EF3")+Left(TIPO_MODULO,1)+TRB->WB_HAWB+TRB->WB_FORN+TRB->WB_LOJA+TRB->WB_INVOICE+If(Empty(M->WB_PARFIN), cParc, M->WB_PARFIN)+EV_EMBARQUE))
               nVlArrayEEQ := 0
               nRecAux := EF3->(RecNo())
               Do While !EF3->(EOF()) .and. EF3->EF3_TPMODU==Left(TIPO_MODULO,1) .and. EF3->EF3_FILIAL==xFilial("EF3") .and.;
                  EF3->EF3_HAWB==TRB->WB_HAWB .and. EF3->EF3_FORN==TRB->WB_FORN .and. EF3->EF3_LOJAFO==TRB->WB_LOJA .and.;
                  EF3->EF3_INVIMP==TRB->WB_INVOICE .and. EF3->EF3_LINHA==If(Empty(M->WB_PARFIN), cParc, M->WB_PARFIN) .and.;
                  EF3->EF3_CODEVE == EV_EMBARQUE
                  nVlArrayEEQ += EF3->EF3_VL_INV
                  EF3->(dbSkip())
               EndDo
               EF3->(dbGoTo(nRecAux))

               //Soma todas parcelas com mesmo Parfin
               nRecAux := TRB->(RecNo())
               nVlParfin := 0
               TRB->(dbGoTop())
               TRB->(dbSeek(cInvoice))
               Do While !TRB->(EOF()) .and. TRB->WB_INVOICE == cInvoice
                  If TRB->(RecNo()) <> nRecIni .and. (TRB->WB_PARFIN == EF3->EF3_LINHA .or.;
                     (Empty(TRB->WB_PARFIN) .and. TRB->WB_LINHA == EF3->EF3_LINHA)) .and. TRB->WB_INVOICE == cInvoice
                     nVlParfin += TRB->WB_FOBMOE
                  EndIf
                  TRB->(dbSkip())
               EndDo
               TRB->(dbGoTo(nRecAux))

               If (nVlAtual + nVlParfin) < nVlArrayEEQ
                  //TRB->WB_PARFIN := EF3->EF3_LINHA
                  TRB->WB_CA_NUM := EF3->EF3_CONTRA
                  TRB->WB_NR_ROF := EF3->EF3_ROF
               ElseIf (nPos := aScan(aVincula, {|x| x[9]==TRB->WB_INVOICE .and. x[10]==If(Empty(M->WB_PARFIN), cParc, M->WB_PARFIN) })) > 0
                  //TRB->WB_PARFIN := EF3->EF3_LINHA
                  TRB->WB_CA_NUM := EF3->EF3_CONTRA
                  TRB->WB_NR_ROF := EF3->EF3_ROF
               Else
                  For ni:=nPos to Len(aVincula)
                     If aVincula[ni,10]==EF3->EF3_LINHA .and. Empty(aVincula[ni,3])
                        aVincula[ni,10] := TRB->WB_LINHA
                        aVincula[ni,22] := TRB->WB_LINHA
                     EndIf
                  Next ni
               Endif
            ElseIf (nPos := aScan(aVincula, {|x| x[9]==TRB->WB_INVOICE .and. x[10]==If(Empty(M->WB_PARFIN), cParc, M->WB_PARFIN) })) > 0 .and. !Empty(aVincula[nPos,3])
               //TRB->WB_PARFIN := EF3->EF3_LINHA
               TRB->WB_CA_NUM := EF3->EF3_CONTRA
               TRB->WB_NR_ROF := EF3->EF3_ROF
            Endif

         EndIF

         /*
         Final da gravação da parcela de financiamento.
         */

      EndIf

   /*
   Ajuste Negativo
   */
   Else

      /*
      Procura abaixo da parcela alterada, uma parcela em aberto cuja seu valor seja igual ao
      valor de ajuste (valor absoluto). Encontrando, a mesma é excluida.
      */
      While TRB->(!Eof()) .and. TRB->WB_INVOICE == cInvoice

         If lWB_EVENT .and. TRB->WB_EVENT <> cEvento
            TRB->(dbSkip())
            Loop
         EndIf

         // PLB 18/05/10 - Caso a Parcela já tenha Título no ERP ou ainda não tenha recebido o retorno do título
         IF LCAMBIO_EIC  .AND.  ( !EMPTY(TRB->WB_TITERP)  .OR.  IIF(lIntegStat, TRB->WB_TITRET$cNao, .F. ) )
            TRB->(dbSkip())
            Loop
         EndIf
         If Empty(TRB->WB_CA_DT) .and. TRB->WB_FOBMOE == ABS(nVlAjuste)
            //** GFC - Não permitir que o novo valor da parcela invalide os valores vinculados a contratos de financiamento
            If lEIC_EFF .and.;
               (nPos := aScan(aVincula, {|x| x[9]==TRB->WB_INVOICE .and. x[10]==TRB->WB_LINHA })) > 0 .and. !Empty(aVincula[nPos,3]) .and.;
               !Empty(aVincula[nPos,16]) .and. aVincula[nPos,22] <> cParcAux
               MsgInfo(STR0187+Alltrim(TRB->WB_LINHA))  // "O valor informado não será permitido pois invalidaria as vinculações da parcela "
               lRet := .F.
               Break
            //**
            Else
               //** GFC
               If lEIC_EFF
                  If aScan(aVincula, {|x| x[9]==TRB->WB_INVOICE .and. x[10]==TRB->WB_LINHA }) = 0
                     nVlParAux := TRB->WB_FOBMOE
                  Else
                     nVlParAux := 0
                  EndIf
               EndIf
               //**
               If !Empty(TRB->WB_RECNO)
                  AADD(aDeletados,TRB->WB_RECNO)
                  /* wfs
                     array adeletados com estrutura diferente, dependendo da origem da chamada*/
                  If AvFlags("EIC_EAI")
                     AAdd(aEAIDeletados, {"SWB", TRB->WB_RECNO})
                  EndIF
               Endif
               TRB->(dbDelete())
               EndIf

               Exit
            EndIf

            TRB->(dbSkip())

      End

      If TRB->(Eof()) .OR. TRB->WB_INVOICE <> cInvoice

         TRB->(dbGoTo(nRecIni))
         TRB->(dbSkip(-1))

         /*
         Procura acima da parcela alterada, uma parcela em aberto cuja seu valor seja igual ao
         valor de ajuste (valor absoluto). Encontrando, a mesma é parcela é excluida.
         */
         While TRB->(!Bof()) .and. TRB->WB_INVOICE == cInvoice

            If lWb_EVENT  .And.  TRB->WB_EVENT <> cEvento
               TRB->(dbSkip(-1))
               Loop
            EndIf

            // PLB 18/05/10 - Caso a Parcela já tenha Título no ERP ou ainda não tenha recebido o retorno do título
            IF LCAMBIO_EIC  .AND.  ( !EMPTY(TRB->WB_TITERP)  .OR.  IIF(lIntegStat, TRB->WB_TITRET$cNao, .F. ) )
               TRB->(dbSkip(-1))
               Loop
            EndIf
            If Empty(TRB->WB_CA_NUM) .and. TRB->WB_FOBMOE = ABS(nVlAjuste)
               //** GFC - Não permitir que o novo valor da parcela invalide os valores vinculados a contratos de financiamento
               If lEIC_EFF .and.;
                  (nPos := aScan(aVincula, {|x| x[9]==TRB->WB_INVOICE .and. x[10]==TRB->WB_LINHA })) > 0 .and. !Empty(aVincula[nPos,3]) .and.;
                  !Empty(aVincula[nPos,16]) .and. aVincula[nPos,22] <> cParcAux
                  MsgInfo(STR0187+Alltrim(TRB->WB_LINHA))  // "O valor informado não será permitido pois invalidaria as vinculações da parcela "
                  lRet := .F.
                  Break
               //**
               Else
                  //** GFC
                  If lEIC_EFF
                     If aScan(aVincula, {|x| x[9]==TRB->WB_INVOICE .and. x[10]==TRB->WB_LINHA }) = 0
                        nVlParAux := TRB->WB_FOBMOE
                     Else
                        nVlParAux := 0
                     EndIf
                  EndIf
                  //**
                  If !Empty(TRB->WB_RECNO)
                     aAdd(aDeletados,TRB->WB_RECNO)
                  Endif
                  TRB->(dbDelete())
               EndIf

               Exit
            EndIf

            TRB->(dbSkip(-1))

         End

         If TRB->(Bof()) .OR. TRB->WB_INVOICE <> cInvoice

            TRB->(dbGoTo(nRecIni))
            TRB->(dbSkip())

            /*
            Procura abaixo da parcela alterada, uma parcela em aberto cuja seu valor seja maior que
            o valor de ajuste (valor absoluto). Encontrando, a mesma tera no seu valor, um abatimento
            do valor de ajuste.
            */
            While TRB->(!Eof()) .and. TRB->WB_INVOICE == cInvoice

               If lWB_EVENT .And. TRB->WB_EVENT <> cEvento
                  TRB->(dbSkip())
                  Loop
               EndIf

                // PLB 18/05/10 - Caso a Parcela já tenha Título no ERP ou ainda não tenha recebido o retorno do título
               IF LCAMBIO_EIC  .AND.  ( !EMPTY(TRB->WB_TITERP)  .OR.  IIF(lIntegStat, TRB->WB_TITRET$cNao, .F. ) )
                  TRB->(dbSkip())
                  Loop
               EndIf
               If Empty(TRB->WB_CA_DT) .and. TRB->WB_FOBMOE > ABS(nVlAjuste)
                  //** GFC - Não permitir que o novo valor da parcela invalide os valores vinculados a contratos de financiamento
                  If lEIC_EFF .and. (nPos := aScan(aVincula, {|x| x[9]==TRB->WB_INVOICE .and. x[10]==TRB->WB_LINHA })) > 0 .and.;
                     !Empty(aVincula[nPos,3]) .and. !Empty(aVincula[nPos,16]) .and. aVincula[nPos,22] <> cParcAux .and.;
                     (TRB->WB_FOBMOE - ABS(nVlAjuste)) < aVincula[nPos,1]
                     MsgInfo(STR0187+Alltrim(TRB->WB_LINHA))  // "O valor informado não será permitido pois invalidaria as vinculações da parcela "
                     lRet := .F.
                     Break
                  //**
                  Else
                     //** GFC
                     If lEIC_EFF
                        If aScan(aVincula, {|x| x[9]==TRB->WB_INVOICE .and. x[10]==TRB->WB_LINHA }) = 0
                           nVlParAux := ABS(nVlAjuste)
                        Else
                           nVlParAux := 0
                        EndIf
                     EndIf
                     //**
                     TRB->WB_FOBMOE += nVlAjuste
                  EndIf

                  Exit
               EndIf

               TRB->(dbSkip())

            End

            If TRB->(Eof()) .OR. TRB->WB_INVOICE <> cInvoice

               TRB->(dbGoTo(nRecIni))
               TRB->(dbSkip(-1))

               /*
               Procura acima da parcela alterada, uma parcela em aberto cuja seu valor seja maior que
               o valor de ajuste (valor absoluto). Encontrando, a mesma tera no seu valor, um abatimento
               do valor de ajuste.
               */
               While TRB->(!Bof()) .and. TRB->WB_INVOICE == cInvoice

                  If lWB_EVENT  .AND.  TRB->WB_EVENT <> cEvento
                     TRB->(dbSkip(-1))
                     Loop
                  EndIf

                   // PLB 18/05/10 - Caso a Parcela já tenha Título no ERP ou ainda não tenha recebido o retorno do título
                  IF LCAMBIO_EIC  .AND.  ( !EMPTY(TRB->WB_TITERP)  .OR.  IIF(lIntegStat, TRB->WB_TITRET$cNao, .F. ) )
                     TRB->(dbSkip(-1))
                     Loop
                  EndIf
                  If Empty(TRB->WB_CA_DT) .and. TRB->WB_FOBMOE > ABS(nVlAjuste)
                     //** GFC - Não permitir que o novo valor da parcela invalide os valores vinculados a contratos de financiamento
                     If lEIC_EFF .and. (nPos := aScan(aVincula, {|x| x[9]==TRB->WB_INVOICE .and. x[10]==TRB->WB_LINHA })) > 0 .and.;
                        !Empty(aVincula[nPos,3]) .and. !Empty(aVincula[nPos,16]) .and. aVincula[nPos,22] <> cParcAux .and.;
                        (TRB->WB_FOBMOE - ABS(nVlAjuste)) < aVincula[nPos,1]
                        MsgInfo(STR0187+Alltrim(TRB->WB_LINHA))  // "O valor informado não será permitido pois invalidaria as vinculações da parcela "
                        lRet := .F.
                        Break
                     //**
                     Else
                        //** GFC
                        If lEIC_EFF .and. Abs(nVlAjuste) > 0
                           If aScan(aVincula, {|x| x[9]==TRB->WB_INVOICE .and. x[10]==TRB->WB_LINHA }) = 0
                              nVlParAux := ABS(nVlAjuste)
                           Else
                              nVlParAux := 0
                           EndIf
                        EndIf
                        //**
                        TRB->WB_FOBMOE += nVlAjuste
                     EndIf

                     Exit
                  EndIf

                  TRB->(dbSkip(-1))

               End

               If TRB->(Bof())

                  TRB->(dbGoTo(nRecIni))
                  TRB->(dbSkip())

                  /*
                  Procura abaixo da parcela alterada, um agrupamento de parcelas não liquidadas, onde
                  seu valor seja igual ou maior ao valor do ajuste. Encontrando e o valor sendo igual,
                  ao valor de ajuste, serao excluidas as parcelas que formam o agrupamento. O valor do
                  agrupamento sendo maior que o valor de ajuste, serão agrupadas em uma unica parcela
                  e tera no seu valor, um abatimento do valor de ajuste.
                  */
                  While TRB->(!Eof()) .and. TRB->WB_INVOICE == cInvoice

                     If lWB_EVENT  .AND.  TRB->WB_EVENT <> cEvento
                        TRB->(dbSkip())
                        Loop
                     EndIf

                      // PLB 18/05/10 - Caso a Parcela já tenha Título no ERP ou ainda não tenha recebido o retorno do título
                     IF LCAMBIO_EIC  .AND.  ( !EMPTY(TRB->WB_TITERP)  .OR.  IIF(lIntegStat, TRB->WB_TITRET$cNao, .F. ) )
                        TRB->(dbSkip())
                        Loop
                     EndIf
                     If Empty(TRB->WB_CA_DT)
                        aAdd(aParcAgrup, TRB->(Recno()))

                        nTotParcAgrup += TRB->WB_FOBMOE

                        Do Case

                           Case nTotParcAgrup == ABS(nVlAjuste)

                              //** GFC - Não permitir que o novo valor da parcela invalide os valores vinculados a contratos de financiamento
                              If lEIC_EFF
                                 For nx:=1 to Len(aParcAgrup)
                                    TRB->(dbGoTo(aParcAgrup[nx]))
                                    If (nPos := aScan(aVincula, {|x| x[9]==TRB->WB_INVOICE .and. x[10]==TRB->WB_LINHA })) > 0 .and.;
                                       !Empty(aVincula[nPos,3]) .and.;
                                       !Empty(aVincula[nPos,16]) .and. aVincula[nPos,22] <> cParcAux
                                       MsgInfo(STR0187+Alltrim(TRB->WB_LINHA))  // "O valor informado não será permitido pois invalidaria as vinculações da parcela "
                                       lRet := .F.
                                       Break
                                    EndIf
                                 Next nx
                                 nVlParAux := ABS(nVlAjuste)
                              EndIf
                              //**

                              TRB->(aEval(aParcAgrup, {|x| dbGoTo(x),;
                                   If(!Empty(WB_RECNO), aAdd(aDeletados, WB_RECNO),),;
                                   dbDelete()}))

                              Exit

                           Case nTotParcAgrup > ABS(nVlAjuste)

                              //** GFC - Não permitir que o novo valor da parcela invalide os valores vinculados a contratos de financiamento
                              If lEIC_EFF
                                 For nx:=2 to Len(aParcAgrup)
                                 TRB->(dbGoTo(aParcAgrup[nx]))
                                 If (nPos := aScan(aVincula, {|x| x[9]==TRB->WB_INVOICE .and. x[10]==TRB->WB_LINHA })) > 0 .and.;
                                    !Empty(aVincula[nPos,3]) .and.;
                                    !Empty(aVincula[nPos,16]) .and. aVincula[nPos,22] <> cParcAux
                                    MsgInfo(STR0187+Alltrim(TRB->WB_LINHA))  // "O valor informado não será permitido pois invalidaria as vinculações da parcela "
                                    lRet := .F.
                                    Break
                                 EndIf
                                 Next nx

                                 TRB->(dbGoTo(aParcAgrup[1]))

                                 If (nPos := aScan(aVincula, {|x| x[9]==TRB->WB_INVOICE .and. x[10]==TRB->WB_LINHA })) > 0 .and.;
                                    !Empty(aVincula[nPos,3]) .and.;
                                    !Empty(aVincula[nPos,16]) .and. aVincula[nPos,22] <> cParcAux .and.;
                                    (TRB->WB_FOBMOE - ABS(nVlAjuste)) < aVincula[nPos,1]
                                    MsgInfo(STR0187+Alltrim(TRB->WB_LINHA))  // "O valor informado não será permitido pois invalidaria as vinculações da parcela "
                                    lRet := .F.
                                    Break
                                 EndIf
                              EndIf
                              //**

                              TRB->(aEval(aParcAgrup, {|x| dbGoTo(x),;
                                                           If(!Empty(WB_RECNO), aAdd(aDeletados, WB_RECNO),),;
                                                           If(lEIC_EFF,If(aScan(aVincula, {|x| x[9]==TRB->WB_INVOICE .and. x[10]==TRB->WB_LINHA }) > 0, nVlParAux += nVlAjuste, nVlParAux += 0),),; //** GFC
                                                           dbDelete()}, 2))

                              TRB->(dbGoTo(aParcAgrup[1]),;
                                   WB_FOBMOE := nTotParcAgrup)

                              //** GFC
                              If lEIC_EFF
                                 If aScan(aVincula, {|x| x[9]==TRB->WB_INVOICE .and. x[10]==TRB->WB_LINHA }) = 0
                                    nVlParAux := ABS(nVlAjuste)
                                 Else
                                    nVlParAux := 0
                                 EndIf
                              EndIf
                              //**

                              TRB->WB_FOBMOE += nVlAjuste

                              Exit

                        End Case

                     EndIf

                     TRB->(dbSkip())

                  End

                  If TRB->(Eof())

                     aParcAgrup    := {}
                     nTotParcAgrup := 0

                     TRB->(dbGoTop())
                     TRB->(dbSeek(cInvoice))

                     /*
                     Procura a partir da primeira parcela, um agrupamento de parcelas não liquidadas, onde
                     seu valor seja igual ou maior ao valor do ajuste. Encontrando e o valor sendo igual,
                     ao valor de ajuste, serao excluidas as parcelas que formam o agrupamento. O valor do
                     agrupamento sendo maior que o valor de ajuste, serão agrupadas em uma unica parcela
                     e tera seu valor, um abatimento do valor de ajuste.
                     */
                     While TRB->(!Eof()) .and. TRB->WB_INVOICE == cInvoice

                        If lWB_EVENT .AND. TRB->WB_EVENT <> cEvento
                           TRB->(dbSkip())
                           Loop
                        EndIf

                         // PLB 18/05/10 - Caso a Parcela já tenha Título no ERP ou ainda não tenha recebido o retorno do título
                        IF LCAMBIO_EIC  .AND.  ( !EMPTY(TRB->WB_TITERP)  .OR.  IIF(lIntegStat, TRB->WB_TITRET$cNao, .F. ) )
                           TRB->(dbSkip())
                           Loop
                        EndIf

                        If TRB->(Recno()) <> nRecIni .and. Empty(TRB->WB_CA_DT)

                           aAdd(aParcAgrup, TRB->(Recno()))

                           nTotParcAgrup += TRB->WB_FOBMOE

                           Do Case

                              Case nTotParcAgrup == ABS(nVlAjuste)

                                 //** GFC - Não permitir que o novo valor da parcela invalide os valores vinculados a contratos de financiamento
                                 If lEIC_EFF
                                    For nx:=1 to Len(aParcAgrup)
                                       TRB->(dbGoTo(aParcAgrup[nx]))
                                       If (nPos := aScan(aVincula,{|x| x[10]==TRB->WB_LINHA})) > 0 .and. !Empty(aVincula[nPos,3]) .and.;
                                          !Empty(aVincula[nPos,16]) .and. aVincula[nPos,22] <> cParcAux
                                          MsgInfo(STR0187+Alltrim(TRB->WB_LINHA))  // "O valor informado não será permitido pois invalidaria as vinculações da parcela "
                                          lRet := .F.
                                          Break
                                       EndIf
                                    Next nx
                                 EndIf
                                    //**

                                 TRB->(aEval(aParcAgrup, {|x| dbGoTo(x),;
                                                              If(!Empty(WB_RECNO), aAdd(aDeletados, WB_RECNO),),;
                                                              If(lEIC_EFF,If(aScan(aVincula, {|x| x[9]==TRB->WB_INVOICE .and. x[10]==TRB->WB_LINHA }) > 0, nVlParAux += nVlAjuste, nVlParAux += 0),),; //** GFC
                                                              dbDelete()}))

                                 Exit

                              Case nTotParcAgrup > ABS(nVlAjuste)

                                 //** GFC - Não permitir que o novo valor da parcela invalide os valores vinculados a contratos de financiamento
                                 If lEIC_EFF
                                    For nx:=2 to Len(aParcAgrup)
                                       TRB->(dbGoTo(aParcAgrup[nx]))
                                       If (nPos := aScan(aVincula,{|x| x[10]==TRB->WB_LINHA})) > 0 .and. !Empty(aVincula[nPos,3]) .and.;
                                          !Empty(aVincula[nPos,16]) .and. aVincula[nPos,22] <> cParcAux
                                          MsgInfo(STR0187+Alltrim(TRB->WB_LINHA))  // "O valor informado não será permitido pois invalidaria as vinculações da parcela "
                                          lRet := .F.
                                          Break
                                       EndIf
                                    Next nx

                                    TRB->(dbGoTo(aParcAgrup[1]))

                                    If (nPos := aScan(aVincula,{|x| x[10]==TRB->WB_LINHA})) > 0 .and. !Empty(aVincula[nPos,3]) .and.;
                                       !Empty(aVincula[nPos,16]) .and. aVincula[nPos,22] <> cParcAux .and.;
                                       (TRB->WB_FOBMOE - ABS(nVlAjuste)) < aVincula[nPos,1]
                                          MsgInfo(STR0187+Alltrim(TRB->WB_LINHA))  // "O valor informado não será permitido pois invalidaria as vinculações da parcela "
                                          lRet := .F.
                                          Break
                                       EndIf
                                    EndIf
                                    //**

                                    TRB->(aEval(aParcAgrup, {|x| dbGoTo(x),;
                                                              If(!Empty(WB_RECNO), aAdd(aDeletados, WB_RECNO),),;
                                                              If(lEIC_EFF,If(aScan(aVincula, {|x| x[9]==TRB->WB_INVOICE .and. x[10]==TRB->WB_LINHA }) > 0, nVlParAux += nVlAjuste, nVlParAux += 0),),; //** GFC
                                                              dbDelete()}, 2))

                                    TRB->(dbGoTo(aParcAgrup[1]),;
                                          WB_FOBMOE := nTotParcAgrup)

                                    //** GFC
                                    If lEIC_EFF
                                       If aScan(aVincula, {|x| x[9]==TRB->WB_INVOICE .and. x[10]==TRB->WB_LINHA }) = 0
                                          nVlParAux := ABS(nVlAjuste)
                                       Else
                                          nVlParAux := 0
                                       EndIf
                                    EndIf
                                    //**

                                    TRB->WB_FOBMOE += nVlAjuste

                                    Exit

                           End Case

                        EndIf

                        TRB->(dbSkip())

                     End

                    /*
                    A condição abaixo não deve ser atendida, caso seja, o campo WB_FOBMOE está sem a validação para não
                    permitir que seja informado valores menor que zero ou maior que o total das parcelas em aberto.
                    */
                    If TRB->(Eof())
                       MsgStop(STR0217, STR0063)  // "O valor informado não é válido para atualização das parcelas." , "Atenção"
                       lRet := .F.
                       Break
                    EndIf
                 EndIf
              EndIf
           EndIf
        EndIf
      EndIf
   EndIf

   TRB->(dbGoTo(nRecIni))

End Sequence

Return lRet


*--------------------------------------------------------------------------------------------------------*
Static Function Ap1DelParc()
*--------------------------------------------------------------------------------------------------------*
Local nRecno := TRB->(RecNo()), aOrd := SaveOrd("TRB"), nVlOld:=0
Local nPos, cOrigem, cParFinAux := TRB->WB_LINHA, nInd
Local lParcPaiLiq:=.f. // Parcela pai liquidada.
Local nVlParc := 0
Local cEvento := "", cInvoice:=""
Local lParc_Found := .F.

FOR nInd := 1 TO TRB->(FCOUNT())
   M->&(TRB->(FIELDNAME(nInd))) := TRB->(FIELDGET(nInd))
NEXT

// ** Controle para estorno de parcelas que possuem parcela de origem.
If lParcFilha
   cOrigem  := TRB->WB_ORIGEM
   cEvento  := TRB->WB_EVENT
   cInvoice := TRB->WB_INVOICE
   nVlOld  := TRB->WB_FOBMOE
EndIf

If lCposAntecip
   TRB->(dbSetOrder(5))
Else
   TRB->(dbSetOrder(4))
EndIf

/*
Localiza abaixo da parcela a ser excluida uma parcela em aberto para ser amortizada.
*/
Do While TRB->(!Eof()) .and. TRB->WB_INVOICE == cInvoice

   If lWB_EVENT .AND. TRB->WB_EVENT <> cEvento
      TRB->(dbSkip())
      Loop
   EndIf

   If TRB->(Recno() <> nRecno .and. Empty(WB_CA_DT))
      lParc_Found := .T.
      Exit
   EndIf

   TRB->(dbSkip())

EndDo

/*
Não encontrando, é verificada as parcelas acima da parcela a ser excluida.
*/
If !lParc_Found

   TRB->(dbGoTo(nRecno))
   While TRB->(!Bof()) .and. TRB->WB_INVOICE == cInvoice

      If lWB_EVENT .AND. TRB->WB_EVENT <> cEvento
         TRB->(dbSkip(-1))
         Loop
      EndIf

      If TRB->(Recno() <> nRecno .and. Empty(WB_CA_DT))
         lParc_Found := .T.
         Exit
      EndIf

      TRB->(dbSkip(-1))

   End

EndIf

If lParc_Found // Parcela desmembrada

   If lEIC_EFF
      If (nPos := aScan(aVincula,{|x| x[10]==TRB->WB_LINHA .and. x[9]==TRB->WB_INVOICE })) > 0
         If !Empty(aVincula[nPos,3])
            MsgInfo(STR0188+TRB->WB_LINHA+STR0189+Alltrim(aVincula[nPos,3])+".")  // "Parcela não pode ser excluída pois a parcela desmembrada " ### " está vinculada ao contrato " ###
            Return .F.
         EndIf

         aVincula[nPos,1] := TRB->WB_FOBMOE+nVlOld

         If (nPos := aScan(aVincula,{|x| x[9]==cInvoice .and. x[10]==cParFinAux})) > 0 .and. !Empty(aVincula[nPos,3])
            aAdd(aExcVinc, {If(!Empty(aVincula[nPos,22]), aVincula[nPos,22], aVincula[nPos,10]), aVincula[nPos,3], aVincula[nPos,4], aVincula[nPos,14], aVincula[nPos,15], aVincula[nPos,20], aVincula[nPos,16], TRB->(RecNo()),.T. })
            aDel(aVincula,nPos)
            aSize(aVincula,LEN(aVincula)-1)
            nSeqArray -= 1
         EndIf
      EndIf

   EndIf

   // ** Atualiza o valor da parcela.
   //TRB->WB_FOBMOE += nVlOld

EndIf

TRB->(DBGOTO(nRecno))

RestOrd(aOrd,.t.)

Return .T.

//--------------------------------------------------------------------------------------------------------//
//   Função      : AP100VlCnt()                                                                           //
//   Objetivo    : Financiamento da Importação                                                            //
//   Parametro   : cOp -> String que indica a opção da Alteracao do Valor do Contrato (VALIDA, EFETIVA)   //
//   Retorno     : Lógico                                                                                 //
//   Autor       : PLB - Pedro Luiz Baroni                                                                //
//   Data        : 07/2006.                                                                               //
//--------------------------------------------------------------------------------------------------------//
*----------------------------------------------------------------------------------------------------------*
Static Function AP100VlCnt(cOp,cChave,nOldVl,nNewVl,nNewVlRea)
*----------------------------------------------------------------------------------------------------------*

 Local lRet  := .T. ,;
       ni    := 1   ,;
       nPos  := 0   ,;
       nVinc := 0

   If cOp == NIL
      cOp := ""
   EndIf

   If cChave == NIL
      cChave := ""
   EndIf


   Do Case

      Case cOp == "VALIDA"
         EF1->( DBSetOrder(1) )
         EF1->( DBSeek(xFilial("EF1")+Left(TIPO_MODULO,1)+cChave) )
         lRet := MsgYesNo(STR0227+CHR(13)+CHR(10) ;            // "O valor a vincular e maior que o valor do contrato."
                         +STR0228+AllTrim(EF1->EF1_CONTRA) ;  // "Deseja efetivar a vinculacao e aumentar o valor do contrato " ###
                         +STR0229+AllTrim(EF1->EF1_SEQCNT) ;  // " Sequencia "
                         +STR0230+EF1->EF1_MOEDA+" "+AllTrim(Trans(nOldVl,AVSX3("EF1_SLD_PM",6)));      // " de " ###
                         +STR0231+EF1->EF1_MOEDA+" "+AllTrim(Trans(nNewVl,AVSX3("EF1_SLD_PM",6)))+"?")  // " para " ###
         If lRet
            lAumVlCont := .T.
            nPos := AScan( aNewVlCont,{|x| x[1]==cChave } )
            If nPos == 0
               AAdd(aNewVlCont,Array(3))
               aNewVlCont[Len(aNewVlCont)][1] := cChave
               aNewVlCont[Len(aNewVlCont)][2] := nNewVl
               aNewVlCont[Len(aNewVlCont)][3] := nNewVlRea
            Else
               aNewVlCont[nPos][2] := nNewVl
               aNewVlCont[nPos][3] := nNewVlRea
            EndIf
         EndIf


      Case cOp == "EFETIVA"
         EF1->( DBSetOrder(1) )
         For ni := 1  to  Len(aNewVlCont)
            EF1->( DBSeek(xFilial("EF1")+Left(TIPO_MODULO,1)+aNewVlCont[ni][1]) )
            RecLock("EF1",.F.)
            EF1->EF1_VL_MOE := aNewVlCont[ni][2]
            EF1->EF1_SLD_PM := aNewVlCont[ni][2]
            EF1->EF1_SLD_PR := aNewVlCont[ni][3]
            EF1->( MSUnLock() )
         Next ni

   End Case


Return lRet


//------------------------------------------------------------------------------------------------------------------//
//   Função      : ValidaSE2()                                                                                      //
//   Objetivo    : Não permitir alterar/exclusão/estorno da parcela se o titulo já estiver compensado no financeiro //
//   Parametro   : cTipoAltera -> String que indica a opção para tratamento da parcela                              //
//   Retorno     : Lógico                                                                                           //
//   Autor       : JAP - José Augusto Pereira Alves                                                                 //
//   Data        : 01/09/2006.                                                                                      //
//------------------------------------------------------------------------------------------------------------------//
*-------------------------------------*
Static Function ValidaSE2(cTipoAltera)
*-------------------------------------*

//JAP - 25/08/06 - Não permite alterar a parcela se o titulo já estiver compensado no financeiro.
   IF TRB->WB_RECNO > 0
      SWB->(DBGoto(TRB->WB_RECNO))
      IF (Left(M->WA_PO_DI,1) == "D" .And. Left(SWB->WB_TIPOREG,1) <> "P") .Or. (Left(M->WA_PO_DI,1) == "A" .Or. Left(M->WA_PO_DI,1) == "F")	// GCC - 27/08/2013
         IF !Empty(SWB->WB_PREFIXO) .And. !Empty(SWB->WB_NUMDUP) .And. !Empty(SWB->WB_PARCELA) .AND.;
            !Empty(SWB->WB_TIPOTIT) .And. SWB->WB_TIPOTIT <> "PR"

            cForn:=SWB->WB_FORN
            cLoja:=SWB->WB_LOJA
            IF Empty(cForn)
               cFilSW9:=xFilial("SW9")
               //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
               SW9->(DBSETORDER(1))
               SW9->(DBSEEK(xFilial("SW9")+SWB->WB_INVOICE+SWB->WB_FORN+EICRetLoja("SWB","WB_LOJA")+SWB->WB_HAWB))
               DO WHILE SW9->(!EOF()) .AND. SW9->W9_FILIAL  == cFilSW9 .AND. SW9->W9_INVOICE == SWB->WB_INVOICE
                  IF SW9->W9_NUM == SWB->WB_NUMDUP
                     cForn:=SW9->W9_FORN
                     EXIT
                  ENDIF
                  SW9->(DBSKIP())
               ENDDO
            ENDIF

            IF EMPTY(cLoja)
               SA2->(DBSEEK(xFilial("SA2")+cForn))
               cLoja:=SA2->A2_LOJA
            ENDIF

            SE2->(DBSETORDER(1))
            IF SE2->(DBSEEK(xFilial()+SWB->WB_PREFIXO+SWB->WB_NUMDUP+SWB->WB_PARCELA+SWB->WB_TIPOTIT+cForn+cLoja))
               IF SE2->E2_SALDO != SE2->E2_VALOR
                  IF cTipoAltera <> "Ver_Comp"
                     MSGINFO(STR0190+cTipoAltera+STR0191)  // "Não é possível a " ### " da parcela, visto que se encontra compensada no financeiro."
                  ENDIF
                  Return .F.
               ENDIF
            ENDIF
         ENDIF

      // EOB - 03/2009 - verifica se há compensações para o título de adiantamento
      ELSEIF lCompAut .AND. LEFT(M->WA_PO_DI,1) == "D" .AND. Left(TRB->WB_TIPOREG,1) == "P"
    	 IF BuscaPA(TRB->WB_FORN, TRB->WB_MOEDA, TRB->(RECNO()),IF(EICLOJA(),TRB->WB_LOJA,""))
            cForn:=SWB->WB_FORN
            cLoja:=SWB->WB_LOJA
            IF EMPTY(cForn)
               cFilSW9:=xFilial("SW9")
               //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
               SW9->(DBSETORDER(1))
               SW9->(DBSEEK(xFilial("SW9")+SWB->WB_INVOICE+SWB->WB_FORN+EICRetLoja("SWB","WB_LOJA")+SWB->WB_HAWB))
               DO WHILE SW9->(!EOF()) .AND. SW9->W9_FILIAL  == cFilSW9 .AND. SW9->W9_INVOICE == SWB->WB_INVOICE
                  IF SW9->W9_NUM == SWB->WB_NUMDUP
                     cForn:=SW9->W9_FORN
                     EXIT
                  ENDIF
                  SW9->(DBSKIP())
               ENDDO
            ENDIF

            IF EMPTY(cLoja)
               SA2->(DBSEEK(xFilial("SA2")+cForn))
               cLoja:=SA2->A2_LOJA
            ENDIF
            SE2->(DBSETORDER(1))
            IF SE2->(DBSEEK(xFilial()+SWB->WB_PREFIXO+SWB->WB_NUMDUP+SWB->WB_PARCELA+SWB->WB_TIPOTIT+cForn+cLoja))
               IF SE2->E2_SALDO != SE2->E2_VALOR
                  Return .F.
               ENDIF
            ENDIF
    	 ENDIF
      ENDIF
   ENDIF

Return .T.


*---------------------------------------------------------------------------------------------*
// PLB 13/10/06 - Verifica se há vinculos com o financiamento para permitir exclusão do câmbio
*---------------------------------------------------------------------------------------------*
Static Function ValFin(cTpExc)
*---------------------------------------------------------------------------------------------*
 Local lRet := .T.  ,;
       nRec := 0    ,;
       nOrd := 0

   If lEIC_EFF  .And.  lEFFTpMod

      nRec := EF3->( RecNo() )
      nOrd := EF3->( IndexOrd() )
      EF3->( DBSetOrder(7) )

      Do Case

         Case cTpExc == "TOT"
            TRB->( DBGoTop() )
            Do While  !TRB->( EoF() )  .And.  lRet
               If EF3->( DBSeek(xFilial("EF3")+Left(TIPO_MODULO,1)+TRB->WB_HAWB+TRB->WB_FORN+TRB->WB_LOJA+TRB->WB_INVOICE+If(Empty(TRB->WB_PARFIN),TRB->WB_LINHA,TRB->WB_PARFIN)+EV_EMBARQUE) )
                  lRet := .F.
                  MsgInfo(STR0122)  //"O contrato possui parcelas vinculadas ao financiamento e não pode ser excluído."
               EndIf
               TRB->( DBSkip() )
            EndDo
            TRB->( DBGoTop() )

         Case cTpExc == "PARC"
               If EF3->( DBSeek(xFilial("EF3")+Left(TIPO_MODULO,1)+TRB->WB_HAWB+TRB->WB_FORN+TRB->WB_LOJA+TRB->WB_INVOICE+If(Empty(TRB->WB_PARFIN),TRB->WB_LINHA,TRB->WB_PARFIN)+EV_EMBARQUE) )
                  lRet := .F.
                  MsgInfo(STR0123+AllTrim(EF3->EF3_CONTRA)+".")  //"Parcela não pode ser excluída pois está vinculada ao contrato de financiamento " ## "."
               EndIf

      EndCase

      EF3->( DBSetOrder(nOrd) )
      EF3->( DBGoTo(nRec) )

   EndIf

Return lRet


//------------------------------------------------------------------------------------------------------------------//
//   Função      : AP100OneParc()                                                                                   //
//   Objetivo    : Verificar se o Pedido possui mais de uma parcela de Adiantamento                                 //
//   Parametro   :                                                                                                  //
//   Retorno     : Lógico                                                                                           //
//   Autor       : PLB - Pedro Baroni                                                                               //
//   Data        : 06/09/2007                                                                                       //
//------------------------------------------------------------------------------------------------------------------//

*-------------------------------------------------------------*
Static Function AP100OneParc(cFilSWB)
*-------------------------------------------------------------*

 Local aOrd     := {}   ,;
       cA		:= ""	,;
       lOneParc := .T.  ,;
       nParc    := 0

   aOrd := SaveOrd({"SWB"})

Default cFilSWB := xFilial("SWB")

   SWB->( DBSetOrder(1) )

   //** GCC - 28/08/2013 - Pesquisar as parcelas para pagamento antecipado vinculado a PO ou a Fornecedor
   If SWB->(DbSeek(cFilSWB+Work1->WB_NUMPO+"A"))
	  cA := "A"
   ElseIf SWB->(DbSeek(cFilSWB+Work1->WB_NUMPO+"F"))
	  cA := "F"
   ElseIf SWB->(DbSeek(cFilSWB+Work1->WB_NUMPO+"C"))
	  cA := "C"
   EndIf
   //**

   Do While SWB->( !EoF()  .And.  WB_FILIAL+WB_HAWB+WB_PO_DI == cFilSWB+Work1->WB_NUMPO+cA )  .And.  nParc < 2
      nParc++
      SWB->( DBSkip() )
   EndDo

   If nParc > 1
      lOneParc := .F.
   EndIf

   RestOrd(aOrd,.T.)

Return lOneParc

Function AP100GATDT(nOrd)
Local xRet
Do Case
   Case nOrd == 1
      xRet := If(.T., M->WB_DT_DESE, M->WB_CA_DT)
   Case nOrd == 2
      //Nopado por WFS em 15/04/2010
      //xRet := If(.T., BuscaTaxa(M->WB_MOEDA, M->WB_CA_DT,, .F.), M->WB_CA_TX)
      M->WB_CA_TX:= BuscaTaxa(M->WB_MOEDA, M->WB_CA_DT,, .F.)
      APE100Crit('TAXA')
      xRet:= M->WB_CA_TX
   Case nOrd == 3
      If .T.
         APE100Crit('TAXA')
      EndIf
      xRet := M->WB_CA_TX
End Case

Return xRet
/*
Função....: ValorPed
Autor.....: Alessandro Alves Ferreira (AAF)
Data......: 21/08/2008
Parâmetros: cPoNum = Numero do PO
Retorno...: Valor total na condição de compra do pedido
*/
********************************
Static Function ValorPed(cPoNum)
********************************
Local nVal := 0
Local nOldOrd := SW3->(IndexOrd())
Local nOldRec := SW3->(RecNo())
Default cPoNum := SW2->W2_PO_NUM
Private lLoop  := .F.//igor chiba 21/09/09

SW3->(DBSETORDER(7)) // FILIAL+PO+SEQ
SW3->(dbSeek(xFilial("SW3")+cPoNum))
DO WHILE SW3->( !EoF() .AND. W3_FILIAL==xFilial("SW3") .AND. W3_PO_NUM = cPoNum .AND. W3_SEQ == 0 )
   lLoop:=.F.
   IF(EasyEntryPoint("EICAP100"),ExecBlock("EICAP100",.F.,.F.,"SKIP_LOOP_SW3"),) //igor chiba 21/09/09
   IF lLoop
      SW3->(DBSKIP())
      LOOP
   ENDIF

   nVal += Round(SW3->W3_QTDE * SW3->W3_PRECO,AvSX3("W9_FOB_TOT",AV_DECIMAL))

   SW3->(DBSKIP())
ENDDO

SW3->(dbSetOrder(nOldOrd))
SW3->(dbGoTo(nOldRec))

Return nVal

/*
Função....: IncParcInvo()
Autor.....: Bruno Henrique Fonsatte
Descrição.: Numeração de parcelas de câmbio
Data......: 06/04/2009
Parâmetros: - nOpc
			{"1" - Incrementa Array}
			{"2" - Busca Próxima parcela}
			- lAltVlr
			{Alteração do valor da parcela}
Retorno...: Ultima parcela da Invoice relacionada(Caracter)
*/
*****************************************
Static Function IncParcInvo(nOpc,lAltVlr)
*****************************************
Local cUltParc := Alltrim(EasyGParam("MV_1DUP"))
Local i, nPosic, cInvEnc
Local lVolta := .F.
Local nPosicao := TRB->(Recno())
Default lAltVlr := .F.

cInvEnc  := TRB->WB_INVOICE
//NCF-20/05/09
If TRB->(FieldPos("WB_PARCELA")) > 0
   cParcEnc := TRB->WB_PARCELA
Else
   Return .T.
EndIf

If nOpc = "1" // MCF 13/08/2014
	TRB->(DbGoTop())
Endif

If TRB->(BOF()) .and. TRB->(EOF())
   Return Nil
EndIf


If Empty(TRB->WB_INVOICE) // MCF 13/08/2014
	TRB->WB_INVOICE := M->WB_INVOICE
EndIf

If nOpc = "1" // - Incrementação do array de invoices e parcelas
   //aInvVinc := {}
   TRB->(DbGoTop())
   Do While TRB->(!EOF())
      If aScan(aInvVinc,{|x| x[1] == TRB->WB_INVOICE}) == 0
         aAdd(aInvVinc,{TRB->WB_INVOICE, TRB->WB_PARCELA})
      Else
         nPosic := aScan(aInvVinc,{|x| x[1] == TRB->WB_INVOICE})
		 // Se a parcela da tabela for menor que a encontrada no vetor, substitui.
         If aInvVinc[nPosic][2] < TRB->WB_PARCELA //MCF - 11/02/2014
            aInvVinc[nPosic][2] := TRB->WB_PARCELA
         EndIf
      EndIf
      TRB->(DbSkip())
   End Do
   TRB->(DbGoTo(nPosicao))
ElseIf nOpc = "2" // - Incrementa a proxima parcela e retorna valor.
   nPosic := aScan(aInvVinc,{|x| x[1] == If(!Empty(TRB->WB_INVOICE),TRB->WB_INVOICE,M->WB_INVOICE)})   //Se work não estiver gravado
   If (If(!Empty(TRB->WB_INVOICE),TRB->WB_INVOICE,M->WB_INVOICE)) == aInvVinc[nPosic][1]
      If Empty(aInvVinc[nPosic][2])
         aInvVinc[nPosic][2] := cUltParc
         //aInvVinc[nPosic][2] := Asc(aInvVinc[nPosic][2])
         //aInvVinc[nPosic][2] := CHR(aInvVinc[nPosic][2])
         If !Empty(TRB->WB_INVOICE)
            TRB->WB_PARCELA := aInvVinc[nPosic][2]
         Else
            M->WB_PARCELA :=aInvVinc[nPosic][2]
         EndIf
         lVolta := .T.
      Else
         If (Empty(TRB->WB_PARCELA) .and. !TRB->(EOF())) .Or. lAltVlr
            /*aInvVinc[nPosic][2] := Asc(aInvVinc[nPosic][2])+1 //MCF - 11/02/2015
            aInvVinc[nPosic][2] := CHR(aInvVinc[nPosic][2])*/
            aInvVinc[nPosic][2] := SomaIt(Alltrim(aInvVinc[nPosic][2]))
            lVolta := .T.
            TRB->WB_PARCELA := aInvVinc[nPosic][2]
         Else
            Return Nil
         EndIf
      EndIf
      If lVolta
         Return aInvVinc[nPosic][2]
      EndIf
   EndIf
EndIf

Return .T.

/*
Função....: Ap100ApuLinha
Autor.....: Jean Victor Rocha
Data......: 13/03/2010
Objetivo..: Retornar/Validar o valor da linha a ser utilizado no WB_LINHA.
Parâmetros: cAlias  = Alias a ser buscado (WORK ou SWB).
            cChave  = chave de buca contendo: cHawb   = Processo.
                                              cPO_DI  = WB_PO_DI a que se refere a linha a ser criada/validada.
                                              cInvoice= invoice.
                                              cFOrn   = Fornecedor
                                              cLoja   = Loja.
Retorno...: nLinha  = Valor da proxima linha.
*/
*-------------------------------------------*
Static Function Ap100ApuLinha(cAlias, cChave)
*-------------------------------------------*
Local aOrd   := SaveOrd(cAlias)
Local nLinha := 0

If cAlias == "TRB"
   (cAlias)->(DbGoTop())
   While (cAlias)->(!EOF())
      If !EMPTY((cAlias)->WB_LINHA) .and. Val((cAlias)->WB_LINHA) > nLinha
         nLinha := Val((cAlias)->WB_LINHA)
      EndIf
      (cAlias)->(DbSkip())
   EndDo

ElseIf cAlias == "SWB"
   (cAlias)->(DbSetOrder(1))
   If (cAlias)->(DbSeek(xFilial(cAlias) + cChave   ))
      While (cAlias)->(!EOF()) .and.;
      cChave == (cAlias)->(WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN+WB_LOJA)
         If !EMPTY((cAlias)->WB_LINHA) .and. Val((cAlias)->WB_LINHA) > nLinha
            nLinha := Val((cAlias)->WB_LINHA)
         EndIf
         (cAlias)->(DbSkip())
      EndDo
   EndIf
EndIf

nLinha += 1

RestOrd(aOrd,.T.)

Return nLinha

/*
Função....: ApuValwork2
Autor.....: Jean Victor Rocha
Data......: 22/03/2010
Objetivo..: Apura o valor na Work2
Parâmetros:
Retorno...:
*/
*--------------------*
Function ApuValwork2(cFilTRB)
*--------------------*
Local aOrd    := TRB->(GetArea())
Local cChave  := SWB->(WB_HAWB+WB_INVOICE+WB_FORN+WB_LOJA+WB_LINHA)
Local nPgtAnt := 0
Local nRecOld, i
Default cFilTRB := xfilial("SWB")

TRB->(DbGoTop())
While TRB->(!EOF())                                                                                                           //NCF - 30/04/2018 - Há casos de adiantamentos de tipos diferentes onde toda a chave vai ser igual exceto o campo *_NUMDUP.
   If !Empty(TRB->WB_CHAVE) .AND. TRB->(WB_NUMPO+WB_INVOICE+WB_FORN+WB_LOJA+WB_LINHA) == cChave .And. If(lAdtMultfil,TRB->WB_FILORI == cFilTRB,.T.) .And. TRB->WB_EVENT == SWB->WB_EVENT .And. IIf(AvFlags("EIC_EAI"), TRB->WB_NUMDUP == SWB->WB_NUMDUP, .T.)
      nPgtAnt += TRB->WB_PGTANT
   EndIf
   TRB->(DBSKIP())
EndDo

nRecOld := SWB->(RecNo())

cQry := "Select R_E_C_N_O_ AS RECNO From "+RetSqlName("SWB")+" SWB "
cQry += "Where D_E_L_E_T_ <> '*'"
If lAdtMultFil
   cQry += "	And WB_FILORI = '"+SWB->WB_FILIAL+"'"
EndIf
cQry += "	And WB_HAWB  <> '"+M->WA_HAWB    +"'"
cQry += "	And WB_CHAVE <> ' '					"
cQry += "	And WB_NUMPO =  '"+SWB->WB_HAWB	 +"'"
cQry += "	And WB_LINHA =  '"+SWB->WB_LINHA +"'"
cQry += "	And WB_FORN  =  '"+SWB->WB_FORN  +"'"
cQry += "	And WB_LOJA  =  '"+SWB->WB_LOJA  +"'"
//cQry += "	And WB_PO_DI =  '"+SWB->WB_PO_DI  +"'"

DbUseArea(.T., "TOPCONN", TcGenQry(,,cQry), "QRY", .F.)

Do While QRY->(!Eof())
	SWB->(dbGoTo(QRY->RECNO))

	nPgtAnt += SWB->WB_PGTANT
   	QRY->(dbSkip())
EndDo

QRY->(dbCloseArea())

SWB->(dbGoTo(nRecOld))

If SWB->(FieldPos("WB_SLDELI")) > 0
   nPgtAnt += SWB->WB_SLDELI
EndIf

If SWB->(FieldPos("WB_SLDTRF")) > 0
   nPgtAnt += SWB->WB_SLDTRF
EndIf


//Work2->WB_PGTANT:= SWB->WB_PGTANT - If(type("nValVinc") <> "U", nValVinc,0)

RestArea(aOrd)

Return nPgtAnt

/*
Função....: GetInfSe2
Autor.....: Jean Victor Rocha
Data......: 06/04/2010
Objetivo..: Busca informações do SE2, baseado em informações da TRB.
Parâmetros: cOpc
            cChave
Retorno...: xReturn
*/
*------------------------------*
Function GetInfSe2(cOpc, cChave)
*------------------------------*
Local aOrd := SaveOrd({"TRB", "SE2", "SWB"})
Local xRetorno

Begin Sequence

   Do Case

      Case cOpc == "CHAVE_INV"
         xRetorno := ""
         TRB->(DbGoTop())
         While TRB->(!EOF())
            If TRB->(WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN+WB_LOJA+WB_LINHA) == Alltrim(cChave)
               xRetorno := AvKey(TRB->WB_PREFIXO+TRB->WB_NUMDUP+TRB->WB_PARCELA+TRB->WB_TIPOTIT+TRB->WB_FORN+TRB->WB_LOJA,"E5_DOCUMEN")
               Exit
            EndIf
            TRB->(DbSkip())
         EndDo

      Case cOpc == "CHAVE_PA"
         xRetorno := ""
         BuscaPA(TRB->WB_FORN, TRB->WB_MOEDA, TRB->(Recno()),IF(EICLOJA(),TRB->WB_LOJA,""),If(lAdtMultFil,TRB->WB_FILORI,NIL))
         xRetorno := AvKey(SWB->WB_PREFIXO+SWB->WB_NUMDUP+SWB->WB_PARCELA+SWB->WB_TIPOTIT+SWB->WB_FORN+SWB->WB_LOJA,"E5_DOCUMEN")

      Case cOpc == "RECNO"
         xRetorno := 0
         SE2->(DbSetOrder(1))
         //Posiciona no SE2 do INV
         If SE2->(Dbseek(xFilial("SE2")+GetInfSe2("CHAVE_INV", cChave)))
            xRetorno :=  SE2->(RECNO())
         EndIf

   EndCase

End Sequence

RestOrd(aOrd, .T.)

Return xRetorno

/*
Função....: ApuSldWork1
Autor.....: Nilson César C. Filho
Data......: 03/08/2010
Objetivo..: Apurar o saldo de adiantamento utilizado para o PO.
Parâmetros: cNumPO - Numero do PO
Retorno...: nVlrAnt - Valor já utilizado do saldo de adiantamento
*/
*--------------------*
Function ApuSldwork1(cNumPO,cFilSWA)
*--------------------*
Local aOrd    := SaveOrd("TRB")
Local nVlrAnt := 0
Local i, nRecOld
Default cFilSWA := xFilial("SWA")

TRB->(DbGoTop())
While TRB->(!EOF())
   If TRB->(FIELDPOS("WB_CHAVE")) # 0 .AND. !Empty(TRB->WB_CHAVE) .AND. TRB->WB_NUMPO == cNumPO .AND. Left(TRB->WB_TIPOREG,1) == 'P' .AND. TRB->WB_RECNO == 0 .And. If(lAdtMultfil,cFilSWA == TRB->WB_FILORI,.T.) 
      nVlrAnt += TRB->WB_PGTANT
   EndIf
   TRB->(DBSKIP())
EndDo
RestOrd(aOrd, .T.)

nRecOld := SWB->(RecNo())

For i := 1 To Len(aEstComp)

   SWB->(dbGoTo(aEstComp[i][4]))
   If !SWB->(EoF())
      nVlrAnt -= SWB->WB_PGTANT
   EndIf

Next i

SWB->(dbGoTo(nRecOld))

Return nVlrAnt
/*
Funcao  :AP100VINPA
Autor   :Igor chiba
Data    :14/09/09
Objetivo:Efetuar vinculações entre cambios e pagamentos antecipados
*/
*---------------------------------*
Function AP100VINPA()
*---------------------------------*
Local   aHeaderOld := aClone(aHeader)
Local   aCamposOld := aClone(aCampos)
Local   lOk        :=.F.
Local   nOpc       := 0
Local   bOk        :={||nOpc:=1,lOk:=VlVincPA(),oDlg:End()}
Local   bCancel    :={||nOpc:=0,oDlg:End()}
Local   oDlg
Local   cPictVal   := AVSX3('WB_PGTANT',AV_PICTURE)
Local   aSemSx3    := TRB->(DBSTRUCT())

//Private nVlPgAnt   := 0
Private nSldPgAnt   := 0

Private cMoePgAnt  := ''
Private cFornPgAnt := ''
Private aCampos    := {}
Private aHeader    := {}
Private cNomArq6   := ''

Private cMarca     := ''
Private lInverte   := .F.
Private aButtons   := {}
Private oMSSelect
Private cOldArea   := ALIAS()

IF Left(TRB->WB_TIPOREG,1)  <> 'P'
   MSGINFO(STR0295) //STR0295 'Escolha uma parcela de adiantamento.'
   RETURN .T.
ENDIF

IF SELECT('TRB2') > 0
   TRB2->(DBCLOSEAREA())
ENDIF
cNomArq6:=E_CriaTrab(,aSemSx3,'TRB2')

//valores da linha de pagamento antecipado
//nVlPgAnt  := TRB->WB_PGTANT
nSldPgAnt  := TRB->WB_PGTANT
cMoePgAnt := TRB->WB_MOEDA
cFornPgAnt:= TRB->WB_FORN
cTitERP   := TRB->WB_TITERP//tito ERP do pagamento antecipado
cParcERP  := TRB->WB_PARCELA //DRL - 21/11/11 - Parcela do Pagamento Antecipado
nRecPA    := TRB->(RECNO())

TRB->(DBGOTOP())
DO WHILE TRB->(!EOF())
   IF TRB->WB_MOEDA == cMoePgAnt .AND. TRB->WB_FORN == cFornPgAnt .AND.  Left(TRB->WB_TIPOREG,1) == '1'//cambios com mesmo fornecedor e moeda do adiantamento
      IF EMPTY(TRB->WB_TITERPV) .OR. TRB->WB_TITERPV == cTitERP//AWR - 29/06/2010 - Correcao do Erro: Quando tem mais de uma parcela antecipada se perdia no saldo na vinculacao
         //IF IIF(lIntegStat, TRB->WB_TITRET$cNao, EMPTY(TRB->WB_TITERP) )  // PLB 15/04/10 - Status de Retorno do ERP
         IF IIF(lIntegStat, TRB->WB_TITRET$cNao, .F. )  // PLB 15/04/10 - Status de Retorno do ERP
            MSGINFO(STR0296)  // PLB 15/04/10 - Status de Retorno do ERP //STR0296 'Existe parcela sem Retorno do Titulo do ERP.'
            RETURN .T.
         ENDIF
         TRB2->(DBAPPEND())
         AVREPLACE('TRB','TRB2')
         TRB2->WB_RECNO := TRB->(RECNO())
         nSldPgAnt -= TRB->WB_PGTANT            // PLB 21/06/10 - Controle de Saldo de Adiantamento considerando parcelas já vinculadas
      ENDIF
   ENDIF
   TRB->(DBSKIP())
ENDDO
TRB2->(DBGOTOP())

aAdd(aButtons,{"SDUSETDEL",  {||AP100ManPGT('1')    },"Vincular"})
aAdd(aButtons,{"SDUSOFTSEEK",{||AP100ManPGT('2')    },"Devolver"})

aCpoSWB:=;
  { {{||TRB2->(TipoWK2())}                                     , "", "Tipo Reg."  } ,; //
    {"WB_MOEDA"                                             , "", "Moeda" },; //
    {{||TRANS(TRB2->WB_FOBMOE,AVSX3("WB_FOBMOE",6))}        , "","Valor"  } ,; //
    {"WB_PGTANT"                                            ,"","Vl.Pago Ant.",AVSX3("WB_PGTANT" ,6)} ,; //
    {"WB_INVOICE"                                           , "","Invoices"} ,; //
    {"WB_TIPO"                                              , "","Tipo" } ,; //
    {"WB_LINHA"                                             , "", 'Linha'  },;//"Tipo"
    {"WB_NUMPO" ,,AVSX3("WB_NUMPO" ,5),AVSX3("WB_NUMPO" ,6)},;
    {"WB_PARCELA",,AVSX3("WB_PARCELA",5),AVSX3("WB_PARCELA",6)}}


DO WHILE .T.
   nLIn1   := 15
   nCol1   := 3
   nLin2   := 100
   nCol2   := 400
   lOk     :=.F.
   nOpc    := 0
   DEFINE MSDIALOG oDlg TITLE STR0300 FROM  0,0 TO 280,800 OF oDlg PIXEL //STR0300 'Parcelas a Vincular'
      oMSSelect:= MsSelect():New("TRB2",,,aCpoSWB,@lInverte,@cMarca,{nLIn1,nCol1,nLin2,nCol2})
      //oMSSelect:bAval:={||ManutPGT()}               // PLB 21/06/10 - Rotina ManutPGT não existe, controle via botões VINCULAR ou DEVOLVER
      @nLin2+10,nCol1    SAY  STR0301   OF oDlg PIXEL //STR0301 'Saldo Pgt. Antecipado'
      //@nLin2+10,nCol1+60 MSGET nVlPgAnt PICTURE cPictVal WHEN .F.  OF oDlg PIXEL
      @nLin2+10,nCol1+60 MSGET nSldPgAnt PICTURE cPictVal WHEN .F.  OF oDlg PIXEL

   ACTIVATE  MSDIALOG oDlg  ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons)CENTERED
   TRB2->(DBGOTOP())
   IF nOpc = 1
      IF lOk
         DO WHILE  TRB2->(!EOF())
            TRB->(DBGOTO(TRB2->WB_RECNO))
            TRB->(RECLOCK('TRB',.F.))
            TRB->WB_PGTANT  := TRB2->WB_PGTANT
            TRB->WB_FOBMOE  := TRB2->WB_FOBMOE
            TRB->WB_TITERPV := TRB2->WB_TITERPV
            TRB->WB_PARVIN  := TRB2->WB_PARCELA
            TRB2->(DBSKIP())
         ENDDO
         //atualizando linha do PA
         TRB->(DBGOTO(nRecPA))
         //TRB->(RECLOCK('TRB',.F.))
         /* PLB 21/06/10 - Controle de Saldo de Adiantamento considerando parcelas já vinculadas
         TRB->WB_PGTANT:=nVlPgAnt
         */
         EXIT
      ELSE
         LOOP
      ENDIF
   ELSE
      EXIT
   ENDIF
ENDDO

TRB2->(E_ERASEARQ(cNomArq6))
TRB->(DBGOTOP())
aHeader := aHeaderOld
aCampos := aCamposOld
DBSELECTAREA(cOldArea)

RETURN .T.

/*
Funcao  :VlVincPA
Autor   :Igor chiba
Data    :14/09/09
Objetivo:Validar tela final de parcelas da invoice com o adiantamento
*/

*---------------------------------*
STATIC FUNCTION VlVincPA()
*---------------------------------*
Local lRet:=.T.

TRB2->(DBGOTOP())
DO WHILE TRB2->(!EOF())
   IF !EMPTY(TRB2->WB_PGTANT) .AND.  !EMPTY(TRB2->WB_FOBMOE)  //uma parcela não pode estar parcialmente vinculada a um P.A
      MSGINFO(STR0302+TRB2->WB_LINHA+STR0303+chr(13)+chr(10)+; //STR0302 'Parcela linha: ' //STR0303 ' parcialmente vinculada.'
             STR0304) //STR0304 'Uma parcela não pode estar parcialmente vinculada, duplique a mesma para poder lançar a quantidade desejada.'
      lRet:=.F.
      EXIT
   ENDIF
   TRB2->(DBSKIP())
ENDDO
TRB2->(DBGOTOP())

Return lREt

/*
Funcao  :AP100ManPGT
Autor   :Igor chiba
Data    :14/09/09
Objetivo:Tela de manutenção que exibe cambios que podem ser vinculados a um pagamento antecipado
*/
*---------------------------------*
STATIC Function AP100ManPGT(cEscolha)
*---------------------------------*
Local oDlg
Local lOk    :=.F.
Local nOpc   :=0
Local bOk    :={||lOk:=ValPgt(cEscolha),nOpc:=1,oDlg:End()}
Local bCancel:={||nOpc:=0,oDlg:End()}
Local nLin1  :=15
Local nLin2  :=28
Local nCol1  :=5
Local nCol2  :=40
Local nCol3  :=100
Local nCol4  :=150

Private cPictVal   := AVSX3('WB_PGTANT',AV_PICTURE)

DO WHILE .T.
   cInvoice := TRB2->WB_INVOICE
   cLinha   := TRB2->WB_LINHA
   //nVlr     := TRB2->WB_FOBMOE
   If cEscolha == '1'
      nVlr     := TRB2->WB_FOBMOE
   ElseIf cEscolha == '2'
      nVlr     := TRB2->WB_PGTANT
   EndIf
   nVlAnt   := TRB2->WB_PGTANT
   lOk      :=.F.
   nOpc     :=0

   DEFINE MSDIALOG oDlg TITLE STR0305 FROM  0,0 TO 100,400 OF oDlg PIXEL //STR0305 'Parcelas a Vincular'

      @nLin1,nCol1  SAY  STR0169  OF oDlg PIXEL //STR0169 := "Invoice "
      @nLin1,nCol2  MSGET cInvoice SIZE 40,8 WHEN .F.  OF oDlg PIXEL
      @nLin1,nCol3  SAY  STR0299    OF oDlg PIXEL //STR0299 'Linha'
      @nLin1,nCol4  MSGET cLinha  SIZE 20,8  WHEN .F.  OF oDlg PIXEL

      If cEscolha == '1'
         @nLin2,nCol1  SAY  STR0306   OF oDlg PIXEL //STR0306 'Vincular'
      ElseIf cEscolha == '2'
         @nLin2,nCol1  SAY  STR0307   OF oDlg PIXEL //STR0307 'Devolver'
      EndIf
      @nLin2,nCol2  MSGET nVlr     SIZE 50,8 PICTURE cPictVal  OF oDlg PIXEL
      @nLin2,nCol3  SAY  STR0308   OF oDlg PIXEL //STR0308 'Vlr.Pago Antecip.'
      @nLin2,nCol4  MSGET nVlAnt   SIZE 50,8 PICTURE cPictVal  WHEN .F.  OF oDlg PIXEL

   ACTIVATE  MSDIALOG oDlg  ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   IF nOpc=1
      IF LOK
         IF cEscolha == '1'
            TRB2->(RECLOCK('TRB2',.F.))
            TRB2->WB_FOBMOE  -=  nVlr
            TRB2->WB_PGTANT  +=  nVlr
            TRB2->WB_TITERPV :=  cTitERP
            TRB2->WB_PARVIN  :=  cParcERP //DRL 21/11/11
            //nVlPgAnt -=  nVlr
            nSldPgAnt -=  nVlr
         ELSE
            TRB2->(RECLOCK('TRB2',.F.))
            TRB2->WB_FOBMOE +=  nVlr
            TRB2->WB_PGTANT -=  nVlr
            //nVlPgAnt +=  nVlr
            nSldPgAnt +=  nVlr
            IF EMPTY(TRB2->WB_PGTANT)
               TRB2->WB_TITERPV := ''
               TRB2->WB_PARVIN  := '' //DRL 21/11/11
            ENDIF
         ENDIF
         EXIT
      ELSE
         LOOP
      ENDIF
  ELSEIF nOpc=0
     EXIT
  ENDIF
ENDDO

RETURN .T.
/*
Funcao  :ValPgt
Autor   :Igor chiba
Data    :14/09/09
Objetivo:Validando valores digitados de quanto irei vincular
*/
*---------------------------------*
Static Function ValPgt(cEscolha)
*---------------------------------*
Local lREt:=.T.

IF cEscolha == '1'
   IF nVlr > (TRB2->WB_FOBMOE)
      lREt:=.F.
      MSGINFO(STR0309+TRANSFORM(TRB2->WB_FOBMOE,cPictVal)) //Str0309 'Valor máximo a vincular:'
      Return lREt
   ENDIF

   //IF nVlr > nVlPgAnt
   IF nVlr > nSldPgAnt
      lREt:=.F.
      //MSGINFO('Valor excede Pgt.Antecipado:'+TRANSFORM(nVlPgAnt,cPictVal))
      MSGINFO(STR0310+TRANSFORM(nSldPgAnt,cPictVal)) //STR0310 'Valor excede Pgt.Antecipado:'
      Return lREt
   ENDIF

   IF nVlr < 0
      lREt:=.F.
      MSGINFO(STR0311) //STR0311 'Valor inválido.'
      Return lREt
   ENDIF

ELSE
   IF nVlr > TRB2->WB_PGTANT
      lREt:=.F.
      MSGINFO(STR0312+TRANSFORM(TRB2->WB_PGTANT,cPictVal))//STR0312 'Valor máximo a estornar: '
      Return lREt
   ENDIF

   IF nVlr < 0
      lREt:=.F.
      MSGINFO(STR0311)//STR0311 'Valor inválido.'
      Return lREt
   ENDIF

ENDIF

Return lREt

/*
Funcao  : TipoWK2()
Autor   :Igor chiba
Data    :14/09/09
Objetivo:Tipo de cambio  da tela de vinculação
*/
*--------------------------------------*
STATIC FUNCTION  TipoWK2()
*--------------------------------------*
SX5->( DbSetOrder( 1 ) )
SX5->( DbSeek( xFilial()+"Y6"+TRB2->WB_TIPOREG ) )
RETURN Left(TRB2->WB_TIPOREG,1)+'-'+LEFT(X5DESCRI(),15)

/*
Funcao  : GravaInte17()
Autor   : Daniel Lima
Data    : 02/06/10
Objetivo: Gravacao no EICINTEI17 Atraves da WORK_AVINT
*/
*===========================*
Static Function GravaInte17()
*===========================*
Local		cChave		:=	""
Local		cSQLChv		:= ""
Local		cFase1		:=	""
Private	cChave_RDM	:=	""
Private	cSQLChv_RDM	:= ""
Private	cFase1_RDM	:=	""
WORK_AVINT->(dbGoTop())
Do While WORK_AVINT->(!EOF())
	//
	cFase1 := AllTrim(WORK_AVINT->WK_FASE1)
	//
	Do Case
		Case WORK_AVINT->WK_ALIAS == "SWB"
			//
			If WORK_AVINT->WK_TIPO == 'A' .And. cFase1 == 'CBO'
				cChave:=WORK_AVINT->(WK_FILIAL+WK_HAWB+WK_PO_DI+WK_INVOICE+WK_FORN+WK_LOJA+WK_LINHA)
				cSQLChv:="WB_FILIAL  = '" + WORK_AVINT->WK_FILIAL  + "' AND " +;
							"WB_HAWB    = '" + WORK_AVINT->WK_HAWB    + "' AND " +;
							"WB_PO_DI   = '" + WORK_AVINT->WK_PO_DI   + "' AND " +;
							"WB_INVOICE = '" + WORK_AVINT->WK_INVOICE + "' AND " +;
							"WB_FORN    = '" + WORK_AVINT->WK_FORN    + "' AND " +;
							"WB_LOJA    = '" + WORK_AVINT->WK_LOJA    + "' AND " +;
							"WB_LINHA   = '" + WORK_AVINT->WK_LINHA   + "' "
			//
			ElseIf WORK_AVINT->WK_TIPO == 'A'
				cChave:=WORK_AVINT->(WK_FILIAL+WK_HAWB+WK_INVOICE+WK_PARCELA)
				cSQLChv:="WB_FILIAL  = '" + WORK_AVINT->WK_FILIAL  + "' AND " +;
							"WB_HAWB    = '" + WORK_AVINT->WK_HAWB    + "' AND " +;
							"WB_INVOICE = '" + WORK_AVINT->WK_INVOICE + "' AND " +;
							"WB_PARCELA = '" + WORK_AVINT->WK_PARCELA + "' "
			//
			ElseIf WORK_AVINT->WK_TIPO == 'I' .And. cFase1 == 'PA'
				cChave:=WORK_AVINT->(WK_FILIAL+WK_HAWB+WK_INVOICE+WK_PARCELA)
				cSQLChv:="WB_FILIAL  = '" + WORK_AVINT->WK_FILIAL  + "' AND " +;
							"WB_HAWB    = '" + WORK_AVINT->WK_HAWB    + "' AND " +;
							"WB_INVOICE = '" + WORK_AVINT->WK_INVOICE + "' AND " +;
							"WB_PARCELA = '" + WORK_AVINT->WK_PARCELA + "' "
			//
			ElseIf WORK_AVINT->WK_TIPO == 'I' .And. cFase1 == 'CBO'
				cChave:=WORK_AVINT->(WK_FILIAL+WK_HAWB+WK_PO_DI+WK_INVOICE+WK_FORN+WK_LOJA+WK_LINHA)
				cSQLChv:="WB_FILIAL  = '" + WORK_AVINT->WK_FILIAL  + "' AND " +;
							"WB_HAWB    = '" + WORK_AVINT->WK_HAWB    + "' AND " +;
							"WB_PO_DI   = '" + WORK_AVINT->WK_PO_DI   + "' AND " +;
							"WB_INVOICE = '" + WORK_AVINT->WK_INVOICE + "' AND " +;
							"WB_FORN    = '" + WORK_AVINT->WK_FORN    + "' AND " +;
							"WB_LOJA    = '" + WORK_AVINT->WK_LOJA    + "' AND " +;
							"WB_LINHA   = '" + WORK_AVINT->WK_LINHA   + "' "
			//
			ElseIf WORK_AVINT->WK_TIPO == 'E' .AND. cFase1 == 'CBO'
				cChave:=WORK_AVINT->(WK_FILIAL+WK_HAWB+WK_PO_DI+WK_INVOICE+WK_FORN+WK_LOJA+WK_LINHA)
				cSQLChv := "R_E_C_N_O_ = "+cValToChar(WORK_AVINT->WK_RECNO)
			//
			ElseIf WORK_AVINT->WK_TIPO == 'E' .AND. cFase1 == 'PA'
				cChave:=WORK_AVINT->(WK_FILIAL+WK_HAWB+WK_INVOICE+WK_PARCELA)
				cSQLChv := "R_E_C_N_O_ = "+cValToChar(WORK_AVINT->WK_RECNO)
			EndIf

		Case WORK_AVINT->WK_ALIAS == "EW4"
			//
			If WORK_AVINT->WK_TIPO == 'I' .Or. WORK_AVINT->WK_TIPO == 'A'
				cChave:= WORK_AVINT->(WK_FILIAL+WK_HAWB+WK_INVOICE+WK_FORN)
				cSQLChv:="EW4_FILIAL = '" + WORK_AVINT->WK_FILIAL  + "' AND " +;
							"EW4_HAWB   = '" + WORK_AVINT->WK_HAWB    + "' AND " +;
							"EW4_INVOIC = '" + WORK_AVINT->WK_INVOICE + "' AND " +;
							"EW4_FORN   = '" + WORK_AVINT->WK_FORN    + "' "
			//
			ElseIf WORK_AVINT->WK_TIPO == 'E'
				cChave:= WORK_AVINT->(WK_FILIAL+WK_HAWB+WK_INVOICE+WK_FORN)
				cSQLChv := "R_E_C_N_O_ = "+cValToChar(WORK_AVINT->WK_RECNO)
			EndIf

		Case WORK_AVINT->WK_ALIAS == "SW9"
			//
			If WORK_AVINT->WK_TIPO == 'I' .Or. WORK_AVINT->WK_TIPO == 'A'
				cChave:= WORK_AVINT->(WK_FILIAL+WK_HAWB+WK_INVOICE+WK_FORN)
				cSQLChv:="W9_FILIAL  = '" + WORK_AVINT->WK_FILIAL  + "' AND " +;
							"W9_HAWB    = '" + WORK_AVINT->WK_HAWB    + "' AND " +;
							"W9_INVOICE = '" + WORK_AVINT->WK_INVOICE + "' AND " +;
							"W9_FORN    = '" + WORK_AVINT->WK_FORN    + "' "
			//
			ElseIf WORK_AVINT->WK_TIPO == 'E'
				cChave  := WORK_AVINT->(WK_FILIAL+WK_HAWB+WK_INVOICE+WK_FORN)
				cSQLChv := "R_E_C_N_O_ = "+cValToChar(WORK_AVINT->WK_RECNO)
			EndIf
	EndCase
	//
	cChave_RDM	:=	cChave
	cSQLChv_RDM	:= cSQLChv
	cFase1_RDM	:=	cFase1
	If EasyEntryPoint("EICAP100")
		ExecBlock("EICAP100",.F.,.F.,"GRAVAINTE17_LOOP_WORK_AVINT_ANTES_EI17")
	EndIf

	If lSair // GFP - 05/07/2013
	   WORK_AVINT->(DbSkip())
	   Loop
	EndIf

	cChave		:=	cChave_RDM
	cSQLChv		:= cSQLChv_RDM
	cFase1		:=	cFase1_RDM
	//
   If FindFunction("EICINTEI17")
      EasyExRdm("EICINTEI17", WORK_AVINT->WK_TIPO,cFase1,cChave,AllTrim(WORK_AVINT->WK_LANCA),cSQLChv)	   
   EndIf
   //
	If EasyEntryPoint("EICAP100")
		ExecBlock("EICAP100",.F.,.F.,"GRAVAINTE17_LOOP_WORK_AVINT_DEPOIS_EI17")
	EndIf
	WORK_AVINT->(dbSkip())
EndDo
//Apara os registros gravados
WORK_AVINT->(avzap())
Return .T.

/*
Funcao  : ValidBaixa()
Autor   : Ivo Santana Santos
Data    : 18/01/11
Objetivo: Verificar se a cotação da moeda no financeiro está corretamente preenchida, diferente de 0.
*/
Static Function ValidBaixa()

Local cPar := ""
Local lRet := .T.
Local i := 0

Begin Sequence

SM2->(DbGoTop())
SM2->(DbSetOrder(1))

If SM2->(DbSeek(dDataBase))
   //MFR 24/04/2019 OSSME-2788
   /*
   For i:=2 To 5
   cPar := "MV_SIMB"+Alltrim(STR(i))
      If EasyGParam(cPar) == TRB->WB_MOEDA
         If SM2->(Empty(&("SM2->M2_MOEDA"+Alltrim(STR(i)))))
            lRet := .F.
            Break
         EndIf
      EndIf
   Next i
   */
   lREt := iif( SimbToMoeda(TRB->WB_MOEDA) == 0, .F. , .T.)
EndIf

End Sequence

Return lRet

/*
Função....: AP100Opcao
Autor.....: Gustavo Cunha
Data......: 26/08/2013
Objetivo..: Retornar a opção de tipo de adiantamento na rotina de inclusão manual de câmbio
Parâmetros: Nenhum
Retorno...: cTipo -> 01 -> Adiantamento vinculado a Purchase Order (PO)
				     02 -> Adiantamento vinculado a Fornecedor
				     03 -> Adiantamento Crédito
*/
Function AP100Opcao()

Local aTipo   := { STR0315 ,; 	// 01= Adiantamento por PO
			       STR0316 ,;	// 02= Adiantamento por Fornecedor
				   STR0317  } 	// 03= Credito por Fornecedor
Local cTipo   := "00"
Local cTitulo := STR0318 // "Adiantamentos"
Local lRet	  := .F.
Local oDlg
Local nLinhaIni := nLinhaFim := nColumIni := nColumFim := 0
nLinhaFim := 200
nColumFim := 625 //350

Define MsDialog oDlg Title cTitulo From nLinhaIni, nColumIni To nLinhaFim, nColumFim Pixel

	oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165)
	oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

	@ 010, 010 Say      STR0319				 Size 100, 020 Of oPanel Pixel
	@ 020, 010 ComboBox cTipo  Items  aTipo  Size 100, 020 Of oPanel Pixel

Activate MsDialog oDlg On Init EnchoiceBar(oDlg,{|| oDlg:End()}, {|| oDlg:End(), cTipo := "99"}) Centered

If cTipo == "00"
	MsgInfo(STR0320) // Opção Inválida!
	AP100Opcao()
EndIf

Return cTipo


/*
Função....: AP100ForAD
Autor.....: Gustavo Cunha
Data......: 26/08/2013
Objetivo..: Inclusão de um pagameto antecipado vinculado a Fornecedor
Parâmetros: Nenhum
Retorno...: .T.
*/
Function AP100ForAD()

Local aOrdSW2	:= {}
Local aAdtFor	:= {}
Local cFilSW2	:= xFilial("SW2")
Local cFilSWA	:= xFilial("SWA")
Local cFilSWB	:= xFilial("SWB")
Local cTpAd		:= ""
Local lDelWORK	:= .F.  //igor chiba 29/09/09
Local nRecSWA 	:= SWA->(Recno())
Local nI		:= 0
Local nValPgtAnt:= 0
Local aFiliais := {}
Local cQuery
Local cQueryForn
Local cFilMulti := ""

nSaldo:=0

Work1->(avzap())
Work2->(avzap())

/*
SW7->(DbSetOrder(1))
If SW7->(DbSeek(xFilial()+M->WA_HAWB))
	SA2->(DbSetOrder(1))
	SA2->(DbSeek(xFilial()+SW7->W7_FORN))
	SWA->(DbGoTop())
	
	If lAdtMultFil
	   aFiliais := AvgSelectFil(,"SWA")
	EndIf
	
	Do While SWA->(!Eof())
		If (SWA->WA_CEDENTE == SA2->A2_NREDUZ) .And. !(SWA->WA_PO_DI $ "ACD") .And. If(lAdtMultFil,aScan(aFiliais,SWA->WA_FILIAL) > 0,.T.)
			If Ascan( aAdtFor, {|x| x[1] == SWA->WA_HAWB .And. x[2] == SWA->WA_PO_DI .And. If(lAdtMultFil,x[3] == SWA->WA_FILIAL, .T.) } ) == 0
				Aadd( aAdtFor, {SWA->WA_HAWB,SWA->WA_PO_DI,SWA->WA_FILIAL}) //MCF - 16/04/2015
			EndIf
		EndIf
		SWA->(DbSkip())
	EndDo
EndIf
*/

If lAdtMultFil
   aFiliais := AvgSelectFil(,"SWA")
   If aFiliais[1] == "WND_CLOSE"
        Return .F.
   EndIf
   For nI:= 1 To Len(aFiliais)
      if nI <> 1
         cFilMulti += ","
      EndIf
      cFilMulti += "'" + aFiliais[nI] + "'"
   Next
EndIf

cQuery := "SELECT DISTINCT WA_HAWB, WA_PO_DI, WA_FILIAL FROM " + RetSqlName("SWA")
cQuery += " WHERE WA_HAWB IN (SELECT WB_HAWB FROM " + RetSqlName("SWB") + " WHERE WB_FORN = '" + TRB->WB_FORN + "' AND WB_LOJA = '" + TRB->WB_LOJA + "'"

If lAdtMultFil
   cQuery+= " AND WB_FILIAL in (" + cFilMulti + ") AND WA_FILIAL IN (" + cFilMulti + ")"
Else
   cQuery+= " AND WB_FILIAL = '" + cFilSWB + "' AND WA_FILIAL = '" + cFilSWA + "' " // LRS - 26/10/2018
EndIf

If TcSrvType() <> "AS/400"
   cQuery+= " AND D_E_L_E_T_ <> '*'" 
EndIf

cQuery+= ")"

cQuery+= " AND WA_PO_DI IN ('A', 'F') AND WA_SLDANT > 0"

If TcSrvType() <> "AS/400"
   cQuery+= " and D_E_L_E_T_ <> '*' "
EndIf

If Select("QryForn") > 0
   QryForn->(DBCloseArea())
EndIf

cQuery:= ChangeQuery(cQuery)
TCQuery cQuery Alias "QryForn" New

QryForn->(DBGoTop())

While QryForn->(!Eof())
   AAdd(aAdtFor, {QryForn->WA_HAWB, QryForn->WA_PO_DI, QryForn->WA_FILIAL})
   QryForn->(DBSkip())
EndDo

QryForn->(DBCloseArea())

SWA->(DbSetOrder(1))
SWB->(DbSetOrder(5))

For nI:=1 To Len(aAdtFor)

    If lAdtMultFil
        cFilSWA := aAdtFor[nI][3]
        cFilSWB := cFilSWA
    EndIf
 
	SWA->(DbSeek(cFilSWA+aAdtFor[nI][1]+aAdtFor[nI][2]))
	cTpAd := SWA->WA_PO_DI
	Do While SWA->(!Eof())	.And. SWA->WA_FILIAL == cFilSWA    ;
							.And. SWA->WA_HAWB	 == aAdtFor[nI][1]; //MCF - 16/04/2015
							.And. SWA->WA_PO_DI  == cTpAd

		If SWA->WA_SLDANT > 0
			Work1->(DbAppend())
			Work1->WA_PO_DI  := cTpAd //"F"											// GCC - 26/09/2013
			Work1->WB_NUMPO  := SWA->WA_HAWB
			Work1->WA_PGTANT := SWA->WA_PGTANT//Valor total do Pedido
			Work1->WA_SLDANT := SWA->WA_SLDANT - ApuSldWork1(SWA->WA_HAWB,If(lAdtMultfil,SWA->WA_FILIAL,NIL))	//Saldo do Pedido //NCF - 03/08/2010 - Reapuração do Saldo de adiantamento da Work1
			//Work1->WA_SLDANT:= SWA->WA_PGTANT - ApuSldWork1(SWA->WA_HAWB)
			Work1->WB_PGTANT := SWA->WA_SLDANT								//Saldo disponivel para a alteracao do Processo
			Work1->TRB_ALI_WT:= "SWA"
			Work1->TRB_REC_WT:= SWA->(Recno())

			SWB->(DbSetOrder(1))   // GFP - 19/02/2013
			If SWB->(DbSeek(cFilSWB+SWA->WA_HAWB+SWA->WA_PO_DI)) //NCF - 30/04/2018
				Work1->WB_CA_NUM := SWB->WB_CA_NUM
                 //MFR 24/04/2019 OSSME-2859
                Work1->WB_NUMDUP := SWB->WB_NUMDUP
			EndIf

			Work1->W2_FORN    := SWB->WB_FORN
			Work1->W2_MOEDA	  := SWB->WB_MOEDA

         If lAdtMultfil
            Work1->WB_FILORI := SWA->WA_FILIAL       //NCF - 25/09/2017        
         EndIf
        
			SWB->(DBSETORDER(1/*5*/))
			SWB->(DbSeek(cFilSWB+SWA->WA_HAWB+SWA->WA_PO_DI)) //NCF - 30/04/2018
			Do While !SWB->(Eof())	.And. SWB->WB_FILIAL == cFilSWB ;
									.And. SWB->WB_HAWB == SWA->WA_HAWB; //SWB->WB_NUMPO == SWA->WA_HAWB
                                    .And. SWB->WB_PO_DI == SWA->WA_PO_DI //NCF - 27/04/2018                                    
				//**igor chiba nao apendar dados se uma parcela nao tiver titulo ERP 29/09/09
				If LCAMBIO_EIC  .AND.  lEICFI05
					//IF EMPTY(SWB->WB_TITERP)
					//IF IIF(lIntegStat, SWB->WB_TITRET$cNao, EMPTY(SWB->WB_TITERP) )  // PLB 15/04/10 - Status de Retorno do ERP
					If Iif(lIntegStat, SWB->WB_TITRET$cNao, .F. )  // PLB 15/04/10 - Status de Retorno do ERP
						lDelWORK:=.T.
						Exit
					EndIf
				EndIf
				//**

				If lAdVinculado .And. !Empty(SWB->WB_CHAVE)// .OR. M->WA_HAWB == SWB->WB_HAWB
					SWB->(DbSkip())
					Loop
				EndIf

				Work2->(DbAppend())
				Work2->WB_HAWB	  := SWB->WB_HAWB
				Work2->WB_NUMPO	  := SWB->WB_NUMPO
				Work2->W2_MOEDA	  := SWB->WB_MOEDA
				Work2->WB_PGTANT  := SWB->WB_PGTANT
				Work2->TRB_ALI_WT := "SWB"
				Work2->TRB_REC_WT := SWB->(Recno())
				Work1->W2_FORN    := SWB->WB_FORN
				Work1->W2_MOEDA	  := SWB->WB_MOEDA

				If M->WA_HAWB == SWB->WB_HAWB
					Work1->WB_PGTANT += SWB->WB_PGTANT
				EndIf
				//** PLB 06/09/07
				Work2->WB_LINHA  := SWB->WB_LINHA
				Work2->WB_CA_NUM := SWB->WB_CA_NUM
				//**
            If lAdtMultfil
               Work2->WB_FILORI := SWA->WA_FILIAL       //NCF - 25/09/2017        
            EndIf

            Work2->WB_PO_DI := SWB->WB_PO_DI //NCF - 30/04/2018

				SWB->(DbSkip())
			EndDo

			SWB->(DbSetOrder(1))
			SWB->(DbSeek(cFilSWB+SWA->WA_HAWB+cTpAd))
			Do While !SWB->(Eof()) .And. SWB->WB_FILIAL == cFilSWB .And. SWB->WB_HAWB == SWA->WA_HAWB .AND. SWB->WB_PO_DI  == cTpAd
				If Empty(SWB->WB_CA_DT)
					SWB->(DbSkip())
					Loop
				EndIf
				//** PLB 06/09/07 - Não incluir caso todo o saldo já esteja vinculado em um processo
				nValPgtAnt := SWB->WB_PGTANT
				Work2->( DbSetOrder(1) )                                   //NCF - 30/04/2018
				If Work2->( DBSeek(If(lAdtMultfil,SWB->WB_FILORI,"")+SWB->(WB_HAWB+WB_PO_DI) ))   
					Do While Work2->( !Eof()  .And.  WB_NUMPO == SWB->WB_HAWB .And. WB_PO_DI == SWB->WB_PO_DI )   //NCF - 30/04/2018
						If !Empty(Work2->WB_HAWB)  .And.  SWB->WB_LINHA == Work2->WB_LINHA
							nValPgtAnt -= Work2->WB_PGTANT
						EndIf
						Work2->( DbSkip() )
					EndDo
				EndIf

				// JVR - 22/03/10
				If lAdVinculado
					nValPgtAnt -= ApuValWork2(If(lAdtMultfil,SWA->WA_FILIAL,NIL))
				EndIf

				If nValPgtAnt <= 0
					SWB->( DbSkip() )
					Loop
				EndIf

				//**igor chiba nao apendar dados se uma parcela nao tiver titulo ERP 29/09/09
				If LCAMBIO_EIC .And. lEICFI05
					//IF EMPTY(SWB->WB_TITERP)
					//IF IIF(lIntegStat, SWB->WB_TITRET$cNao, EMPTY(SWB->WB_TITERP) )  // PLB 15/04/10 - Status de Retorno do ERP
					If Iif(lIntegStat, SWB->WB_TITRET $ cNao, .F. )  // PLB 15/04/10 - Status de Retorno do ERP
						lDelWORK:=.T.
						Exit
					EndIf
				EndIf
				//**

				//**
				Work2->(DbAppend())
				Work2->WB_NUMPO := SWA->WA_HAWB
				Work2->W2_MOEDA := SWB->WB_MOEDA
				//Work2->WB_PGTANT:= SWB->WB_PGTANT
				//** PLB 06/09/07 - Possibilitar vinculação de cada parcela de um adiantamento separadamente
				Work2->WB_PGTANT := nValPgtAnt
            Work2->TRB_VLVINC:= IIF(TRB->WB_FOBMOE > Work2->WB_PGTANT,Work2->WB_PGTANT,TRB->WB_FOBMOE)
				Work2->WB_LINHA  := SWB->WB_LINHA
				Work2->WB_CA_NUM := SWB->WB_CA_NUM
				//**
            If lAdtMultfil
               Work2->WB_FILORI := SWA->WA_FILIAL       //NCF - 25/09/2017        
            EndIf

            Work2->WB_PO_DI := SWB->WB_PO_DI  //NCF - 30/04/2018

				Work2->TRB_ALI_WT:= "SWB"
				Work2->TRB_REC_WT:= SWB->(Recno())
				SWB->(dbSkip())
   			EndDo

			nSaldo += SWA->WA_SLDANT
		EndIf

		//** igor chiba deletando work1 caso seus cambios nao tenham n°tit erp 29/09/09
		If LCAMBIO_EIC
			If lDelWork
				Work1->(RECLOCK('WORK1',.F.))
				Work1->(DBDELETE())
				lDelWORK:=.F.
			EndIf
		EndIf
		//**
		SWA->(DbSkip())
	EndDo

Next

SWA->(DbSetOrder(1))
SWB->(DbSetOrder(1))
SWA->(DbGoTo(nRecSWA))

Return .T.


/*
Função....: AP100ResWK
Autor.....: Gustavo Cunha
Data......: 26/08/2013
Objetivo..: Gravar a Work1 e Work2 de acordo com o pagamento antecipado escolhido pelo usuário
Parâmetros: cNumPO -> Numero do Pedido
Retorno...: .T.
*/
Function AP100ResWK(cNumPO, cTpAd)

Local cFilSWA	:= xFilial("SWA")
Local cFilSWB	:= xFilial("SWB")
//Local cTpAd		:= ""
Local lDelWORK	:= .F.  //igor chiba 29/09/09
Local nRecSWA 	:= SWA->(Recno())
Local nValPgtAnt:= 0
Default cTpAd:= "A"

nSaldo:=0

SWA->(DbSetOrder(1))
SWB->(DbSetOrder(5))

SWA->(DbSeek(cFilSWA+cNumPO+cTpAd))
//cTpAd := SWA->WA_PO_DI

Do While !SWA->(Eof())	.And. SWA->WA_FILIAL == cFilSWA ;
						.And. SWA->WA_HAWB	 == cNumPO	;
						.And. SWA->WA_PO_DI	 == cTpAd
	If SWA->WA_SLDANT > 0
		If !Work1->(DbSeek(SWA->WA_HAWB))
			Work1->(DBAPPEND())
			Work1->WA_PO_DI := SWA->WA_PO_DI  // GCC - 26/09/2013
			Work1->WB_NUMPO := SWA->WA_HAWB
			Work1->WA_PGTANT:= SWA->WA_PGTANT								//Valor total do Pedido
			Work1->WA_SLDANT:= SWA->WA_SLDANT - ApuSldWork1(SWA->WA_HAWB)	//Saldo do Pedido //NCF - 03/08/2010 - Reapuração do Saldo de adiantamento da Work1
			//Work1->WA_SLDANT:= SWA->WA_PGTANT - ApuSldWork1(SWA->WA_HAWB)
			Work1->WB_PGTANT:= SWA->WA_SLDANT								//Saldo disponivel para a alteracao do Processo
			Work1->TRB_ALI_WT:= "SWA"
			Work1->TRB_REC_WT:= SWA->(Recno())

			SWB->(DbSetOrder(1))   // GFP - 19/02/2013
			If SWB->(DbSeek(cFilSWB+SWA->WA_HAWB))
				Work1->WB_CA_NUM := SWB->WB_CA_NUM
                 //MFR 24/04/2019 OSSME-2859
                Work1->WB_NUMDUP := SWB->WB_NUMDUP
			EndIf

			Work1->W2_MOEDA := SWB->WB_MOEDA
			Work1->W2_FORN  := SWB->WB_FORN

         If lAdtMultfil
            Work1->WB_FILORI := SWA->WA_FILIAL       //NCF - 28/03/2018        
         EndIf

			SWB->(DBSETORDER(1/*5*/))
			SWB->(DbSeek(cFilSWB+SWA->WA_HAWB))
			Do While !SWB->(Eof())	.And. SWB->WB_FILIAL == cFilSWB ;
									.And. SWB->WB_HAWB == SWA->WA_HAWB//SWB->WB_NUMPO == SWA->WA_HAWB
				//**igor chiba nao apendar dados se uma parcela nao tiver titulo ERP 29/09/09
				If LCAMBIO_EIC  .AND.  lEICFI05
					//IF EMPTY(SWB->WB_TITERP)
					//IF IIF(lIntegStat, SWB->WB_TITRET$cNao, EMPTY(SWB->WB_TITERP) )  // PLB 15/04/10 - Status de Retorno do ERP
					If Iif(lIntegStat, SWB->WB_TITRET$cNao, .F. )  // PLB 15/04/10 - Status de Retorno do ERP
						lDelWORK:=.T.
						Exit
					EndIf
				EndIf
				//**

				If lAdVinculado .And. !Empty(SWB->WB_CHAVE)// .OR. M->WA_HAWB == SWB->WB_HAWB
					SWB->(DbSkip())
					Loop
				EndIf

				Work2->(DbAppend())
				Work2->WB_HAWB	  := SWB->WB_HAWB
				Work2->WB_NUMPO	  := SWB->WB_NUMPO
				Work2->W2_MOEDA	  := SWB->WB_MOEDA
				Work2->WB_PGTANT  := SWB->WB_PGTANT
				Work2->TRB_ALI_WT := "SWB"
				Work2->TRB_REC_WT := SWB->(Recno())

				If M->WA_HAWB == SWB->WB_HAWB
					Work1->WB_PGTANT += SWB->WB_PGTANT
				EndIf
				//** PLB 06/09/07
				Work2->WB_LINHA  := SWB->WB_LINHA
				Work2->WB_CA_NUM := SWB->WB_CA_NUM
				//**
            If lAdtMultfil
               Work2->WB_FILORI := SWB->WB_FILIAL       //NCF - 28/03/2018        
            EndIf

            Work2->WB_PO_DI := SWB->WB_PO_DI  //NCF - 30/04/2018

				SWB->(DbSkip())
			EndDo

			SWB->(DbSetOrder(1))
			SWB->(DbSeek(cFilSWB+SWA->WA_HAWB+cTpAd))
			Do While !SWB->(Eof()) .And. SWB->WB_FILIAL == cFilSWB .And. SWB->WB_HAWB == SWA->WA_HAWB .AND. SWB->WB_PO_DI  == cTpAd
				If Empty(SWB->WB_CA_DT)
					SWB->(DbSkip())
					Loop
				EndIf
				//** PLB 06/09/07 - Não incluir caso todo o saldo já esteja vinculado em um processo
				nValPgtAnt := SWB->WB_PGTANT
				Work2->( DbSetOrder(1) )
				If Work2->( DBSeek(If(lAdtMultfil,SWB->WB_FILORI,"")+SWB->(WB_HAWB+WB_PO_DI) ))
					Do While Work2->( !Eof()  .And.  WB_NUMPO == SWB->WB_HAWB .And. WB_PO_DI == SWB->WB_PO_DI )   //NCF - 30/04/2018
						If !Empty(Work2->WB_HAWB)  .And.  SWB->WB_LINHA == Work2->WB_LINHA
							nValPgtAnt -= Work2->WB_PGTANT
						EndIf
						Work2->( DbSkip() )
					EndDo
				EndIf

				// JVR - 22/03/10
				If lAdVinculado
					nValPgtAnt -= ApuValWork2(If(lAdtMultfil,SWA->WA_FILIAL,NIL))
				EndIf

				If nValPgtAnt <= 0
					SWB->( DbSkip() )
					Loop
				EndIf

				//**igor chiba nao apendar dados se uma parcela nao tiver titulo ERP 29/09/09
				If LCAMBIO_EIC .And. lEICFI05
					//IF EMPTY(SWB->WB_TITERP)
					//IF IIF(lIntegStat, SWB->WB_TITRET$cNao, EMPTY(SWB->WB_TITERP) )  // PLB 15/04/10 - Status de Retorno do ERP
					If Iif(lIntegStat, SWB->WB_TITRET $ cNao, .F. )  // PLB 15/04/10 - Status de Retorno do ERP
						lDelWORK:=.T.
						Exit
					EndIf
				EndIf
				//**

				//**
				Work2->(DbAppend())

            If lAdtMultfil
               Work2->WB_FILORI := SWB->WB_FILIAL
            EndIf
                
				Work2->WB_NUMPO := SWA->WA_HAWB
				Work2->W2_MOEDA := SWB->WB_MOEDA
				//Work2->WB_PGTANT:= SWB->WB_PGTANT
				//** PLB 06/09/07 - Possibilitar vinculação de cada parcela de um adiantamento separadamente
				Work2->WB_PGTANT := nValPgtAnt
				Work2->WB_LINHA  := SWB->WB_LINHA
				Work2->WB_CA_NUM := SWB->WB_CA_NUM
				//**
            Work2->WB_PO_DI := SWB->WB_PO_DI  //NCF - 30/04/2018

				Work2->TRB_ALI_WT:= "SWB"
				Work2->TRB_REC_WT:= SWB->(Recno())
				SWB->(dbSkip())
   		EndDo
		EndIf
		If cMoedaProc == Work1->W2_MOEDA
			nSaldo += SWA->WA_SLDANT
		EndIf
	EndIf

	//** igor chiba deletando work1 caso seus cambios nao tenham n°tit erp 29/09/09
	If LCAMBIO_EIC
		If lDelWork
			Work1->(RECLOCK('WORK1',.F.))
			Work1->(DBDELETE())
			lDelWORK:=.F.
		EndIf
	EndIf
	//**

	SWA->(DbSkip())
EndDo

SWA->(DbSetOrder(1))
SWB->(DbSetOrder(1))
SWA->(DbGoTo(nRecSWA))

Return .T.

/*
Função....: AP100CrtAD
Autor.....: Gustavo Cunha
Data......: 26/08/2013
Objetivo..: Inclusão de um pagameto antecipado vinculado a Credito por fornecedor
Parâmetros: Nenhum
Retorno...: .T.
*/
Function AP100CrtAD()

Local aAdtCred	:= {}
Local cFilSWA	:= xFilial("SWA")
Local cFilSWB	:= xFilial("SWB")
Local cTpAd		:= ""
Local lDelWORK	:= .F.  //igor chiba 29/09/09
Local nRecSWA 	:= SWA->(Recno())
Local nI		:= 0
Local nSaldo	:= 0
Local nValPgtAnt:= 0
Local cQuery
Local cFilMulti:= ""

Work1->(avzap())
Work2->(avzap())
/*
SW7->(DbSetOrder(1))
If SW7->(DbSeek(xFilial()+M->WA_HAWB))
	SA2->(DbSetOrder(1))
	SA2->(DbSeek(xFilial()+SW7->W7_FORN))
	SWA->(DbGoTop())
	
	If lAdtMultFil
      aFiliais := AvgSelectFil(,"SWA")
	  If aFiliais[1] == "WND_CLOSE"
		Return .F.
	  EndIf
    EndIf
	
	Do While SWA->(!Eof())
		If (SWA->WA_CEDENTE == SA2->A2_NREDUZ) .And. SWA->WA_PO_DI == "C" .And. If(lAdtMultFil,aScan(aFiliais,SWA->WA_FILIAL) > 0,.T.)
			If Ascan( aAdtCred, {|x| x[1] == SWA->WA_HAWB .And. If(lAdtMultFil,x[2] == SWA->WA_FILIAL, .T.)} ) == 0
				Aadd( aAdtCred, {SWA->WA_HAWB,SWA->WA_FILIAL} )
			EndIf
		EndIf
		SWA->(DbSkip())
	EndDo
EndIf
*/

If lAdtMultFil
   aFiliais := AvgSelectFil(,"SWA")
   If aFiliais[1] == "WND_CLOSE"
        Return .F.
   EndIf
   For nI:= 1 To Len(aFiliais)
      if nI <> 1
         cFilMulti += ","
      EndIf
      cFilMulti += "'" + aFiliais[nI] + "'"
   Next
EndIf

cQuery:= "select WA_HAWB, WA_FILIAL from " + RetSqlName("SWA")
cQuery+= " where WA_HAWB in (select WB_HAWB from " + RetSqlName("SWB") + " where WB_FORN = '" + TRB->WB_FORN + "' and  WB_LOJA = '" + TRB->WB_LOJA + "'"

If lAdtMultFil
   cQuery+= " and WB_FILIAL in (" + cFilMulti + ")"
Else
   cQuery+= " and WB_FILIAL = '" + cFilSWB + "' "
EndIf

If TcSrvType() <> "AS/400"
   cQuery+= " and D_E_L_E_T_ <> '*') " 
Else
   cQuery+= ")"
EndIf

If lAdtMultFil
   cQuery+= " and WA_FILIAL in (" + cFilMulti + ")"
Else
   cQuery+= " and WA_FILIAL = '" + cFilSWA + "' "
EndIf
cQuery+= " and WA_PO_DI = 'C' and WA_SLDANT > 0"

If TcSrvType() <> "AS/400"
   cQuery+= " and D_E_L_E_T_ <> '*' "
EndIf

If Select("QRYCREDITO") > 0
   QRYCREDITO->(DBCloseArea())
EndIf

cQuery:= ChangeQuery(cQuery)
TCQuery cQuery Alias "QRYCREDITO" New

QRYCREDITO->(DBGoTop())
While QRYCREDITO->(!Eof())
   AAdd(aAdtCred, {QRYCREDITO->WA_HAWB, QRYCREDITO->WA_FILIAL})
   QRYCREDITO->(DBSkip())
EndDo

QRYCREDITO->(DBCloseArea())

SWA->(DbSetOrder(1))
SWB->(DbSetOrder(5))

For nI:=1 To Len(aAdtCred)

    If lAdtMultFil
       cFilSWA := aAdtCred[nI][2]
       cFilSWB := cFilSWA 
    EndIf
   
	SWA->(DbSeek(cFilSWA+aAdtCred[nI][1]+'C'))
	cTpAd := SWA->WA_PO_DI
	Do While SWA->(!Eof())	.And. SWA->WA_FILIAL == cFilSWA     ;
							.And. SWA->WA_HAWB	 == aAdtCred[nI][1];
							.And. SWA->WA_PO_DI  == cTpAd

		If SWA->WA_SLDANT > 0
			Work1->(DbAppend())
			Work1->WA_PO_DI  := "C"											// GCC - 26/09/2013
			Work1->WB_NUMPO  := SWA->WA_HAWB
			Work1->WA_PGTANT := SWA->WA_PGTANT//Valor total do Pedido
			Work1->WA_SLDANT := SWA->WA_SLDANT - ApuSldWork1(SWA->WA_HAWB,If(lAdtMultfil,SWA->WA_FILIAL,NIL))	//Saldo do Pedido //NCF - 03/08/2010 - Reapuração do Saldo de adiantamento da Work1
			//Work1->WA_SLDANT:= SWA->WA_PGTANT - ApuSldWork1(SWA->WA_HAWB)
			Work1->WB_PGTANT := SWA->WA_SLDANT								//Saldo disponivel para a alteracao do Processo
			Work1->TRB_ALI_WT:= "SWA"
			Work1->TRB_REC_WT:= SWA->(Recno())

			SWB->(DbSetOrder(1))   // GFP - 19/02/2013
			If SWB->(DbSeek(cFilSWB+SWA->WA_HAWB))
				Work1->WB_CA_NUM := SWB->WB_CA_NUM
                 //MFR 24/04/2019 OSSME-2859
                Work1->WB_NUMDUP := SWB->WB_NUMDUP
			EndIf

			Work1->W2_FORN    := SWB->WB_FORN
			Work1->W2_MOEDA	  := SWB->WB_MOEDA

         If lAdtMultfil
            Work1->WB_FILORI := SWA->WA_FILIAL       //NCF - 25/09/2017        
         EndIf

			SWB->(DBSETORDER(1/*5*/))
			SWB->(DbSeek(cFilSWB+SWA->WA_HAWB+SWA->WA_PO_DI))
			Do While !SWB->(Eof())	.And. SWB->WB_FILIAL == cFilSWB ;
									.And. SWB->WB_HAWB == SWA->WA_HAWB;//SWB->WB_NUMPO == SWA->WA_HAWB
                                    .And. SWB->WB_PO_DI == SWA->WA_PO_DI //NCF - 27/04/2018 
				//**igor chiba nao apendar dados se uma parcela nao tiver titulo ERP 29/09/09
				If LCAMBIO_EIC  .AND.  lEICFI05
					//IF EMPTY(SWB->WB_TITERP)
					//IF IIF(lIntegStat, SWB->WB_TITRET$cNao, EMPTY(SWB->WB_TITERP) )  // PLB 15/04/10 - Status de Retorno do ERP
					If Iif(lIntegStat, SWB->WB_TITRET$cNao, .F. )  // PLB 15/04/10 - Status de Retorno do ERP
						lDelWORK:=.T.
						Exit
					EndIf
				EndIf
				//**

				If lAdVinculado .And. !Empty(SWB->WB_CHAVE)// .OR. M->WA_HAWB == SWB->WB_HAWB
					SWB->(DbSkip())
					Loop
				EndIf

				Work2->(DbAppend())
				Work2->WB_HAWB	   := SWB->WB_HAWB
				Work2->WB_NUMPO	:= SWB->WB_NUMPO
				Work2->W2_MOEDA	:= SWB->WB_MOEDA
				Work2->WB_PGTANT  := SWB->WB_PGTANT
				Work2->TRB_ALI_WT := "SWB"
				Work2->TRB_REC_WT := SWB->(Recno())
		        Work1->W2_FORN    := SWB->WB_FORN
				Work1->W2_MOEDA	  := SWB->WB_MOEDA

				If M->WA_HAWB == SWB->WB_HAWB
					Work1->WB_PGTANT += SWB->WB_PGTANT
				EndIf
				//** PLB 06/09/07
				Work2->WB_LINHA  := SWB->WB_LINHA
				Work2->WB_CA_NUM := SWB->WB_CA_NUM
				//**

            If lAdtMultfil
               Work2->WB_FILORI := SWA->WA_FILIAL       //NCF - 25/09/2017        
            EndIf

            Work2->WB_PO_DI := SWB->WB_PO_DI  //NCF - 30/04/2018

				SWB->(DbSkip())
			EndDo

			SWB->(DbSetOrder(1))
			SWB->(DbSeek(cFilSWB+SWA->WA_HAWB+cTpAd))
			Do While !SWB->(Eof()) .And. SWB->WB_FILIAL == cFilSWB .And. SWB->WB_HAWB == SWA->WA_HAWB .AND. SWB->WB_PO_DI  == cTpAd
				If Empty(SWB->WB_CA_DT)
					SWB->(DbSkip())
					Loop
				EndIf
				//** PLB 06/09/07 - Não incluir caso todo o saldo já esteja vinculado em um processo
				nValPgtAnt := SWB->WB_PGTANT
                Work2->( DbSetOrder(1) ) //"WB_FILORI+WB_PONUM+WB_PO_DI"
				If Work2->( DBSeek(If(lAdtMultfil,SWB->WB_FILORI,"")+SWB->(WB_HAWB+WB_PO_DI) ))
					Do While Work2->( !Eof()  .And.  WB_NUMPO == SWB->WB_HAWB .And. WB_PO_DI == SWB->WB_PO_DI )   //NCF - 30/04/2018
						If !Empty(Work2->WB_HAWB)  .And.  SWB->WB_LINHA == Work2->WB_LINHA
							nValPgtAnt -= Work2->WB_PGTANT
						EndIf
						Work2->( DbSkip() )
					EndDo
				EndIf

				// JVR - 22/03/10
				If lAdVinculado
					nValPgtAnt -= ApuValWork2(If(lAdtMultfil,SWA->WA_FILIAL,NIL))
				EndIf

				If nValPgtAnt <= 0
					SWB->( DbSkip() )
					Loop
				EndIf

				//**igor chiba nao apendar dados se uma parcela nao tiver titulo ERP 29/09/09
				If LCAMBIO_EIC .And. lEICFI05
					//IF EMPTY(SWB->WB_TITERP)
					//IF IIF(lIntegStat, SWB->WB_TITRET$cNao, EMPTY(SWB->WB_TITERP) )  // PLB 15/04/10 - Status de Retorno do ERP
					If Iif(lIntegStat, SWB->WB_TITRET $ cNao, .F. )  // PLB 15/04/10 - Status de Retorno do ERP
						lDelWORK:=.T.
						Exit
					EndIf
				EndIf
				//**

				//**
				Work2->(DbAppend())
				Work2->WB_NUMPO := SWA->WA_HAWB
				Work2->W2_MOEDA := SWB->WB_MOEDA
				//Work2->WB_PGTANT:= SWB->WB_PGTANT
				//** PLB 06/09/07 - Possibilitar vinculação de cada parcela de um adiantamento separadamente
				Work2->WB_PGTANT := nValPgtAnt
            Work2->TRB_VLVINC:= IIF(TRB->WB_FOBMOE > Work2->WB_PGTANT,Work2->WB_PGTANT,TRB->WB_FOBMOE)
				Work2->WB_LINHA  := SWB->WB_LINHA
				Work2->WB_CA_NUM := SWB->WB_CA_NUM
				//**
				
            If lAdtMultfil
               Work2->WB_FILORI := SWA->WA_FILIAL       //NCF - 25/09/2017        
            EndIf

            Work2->WB_PO_DI := SWB->WB_PO_DI  //NCF - 30/04/2018

				Work2->TRB_ALI_WT:= "SWB"
				Work2->TRB_REC_WT:= SWB->(Recno())
				SWB->(dbSkip())
   			EndDo

			nSaldo += SWA->WA_SLDANT
		EndIf

		//** igor chiba deletando work1 caso seus cambios nao tenham n°tit erp 29/09/09
		If LCAMBIO_EIC
			If lDelWork
				Work1->(RECLOCK('WORK1',.F.))
				Work1->(DBDELETE())
				lDelWORK:=.F.
			EndIf
		EndIf
		//**
		SWA->(DbSkip())
	EndDo
Next

SWA->(DbSetOrder(1))
SWB->(DbSetOrder(1))
SWA->(DbGoTo(nRecSWA))

Return .T.

/*
Função....: AP100CrBX(nOptEx)
Autor.....: Gustavo Cunha
Data......: 15/10/2013
Objetivo..: Realizar a baixa de titulos no financeiro com base dos pagamentos antecipado da modalidade de Crédito por Fornecedor
Parâmetros: nOptEx -> Opção de execução do ExecAuto (3 - Baixa de Título, 5 - Cancelamento de baixa e 6 - Exclusão de Baixa)
Retorno...: .T.
*/
Function AP100CrBX(nOptEx)

Local   cAutMotbx   := "NORMAL"
Local 	cHist		:= "Credito"
Private lMsHelpAuto := .t.
Private lMsErroAuto := .f.

If SX1->(DBSEEK("EICTMB"+Space(4)))
	Pergunte("EICTMB",.F.)
	IF !EMPTY(MV_PAR01)
		cAutMotbx:=ALLTRIM(MV_PAR01)
	ENDIF
ENDIF

SE2->(DbSetOrder(1))
cFilSE2 := xFilial("SE2")

aBaixa:={}
Aadd(aBaixa,{"E2_PREFIXO" ,""		,Nil}) //01
Aadd(aBaixa,{"E2_NUM"     ,""       ,Nil}) //02
Aadd(aBaixa,{"E2_PARCELA" ,""       ,Nil}) //03
Aadd(aBaixa,{"E2_TIPO"    ,""       ,Nil}) //04
Aadd(aBaixa,{"E2_FORNECE" ,""       ,Nil}) //05
Aadd(aBaixa,{"E2_LOJA"    ,""       ,Nil}) //06
Aadd(aBaixa,{"AUTMOTBX"   ,cAutMotbx,Nil}) //07
Aadd(aBaixa,{"AUTBANCO"   ,""       ,Nil}) //08
Aadd(aBaixa,{"AUTAGENCIA" ,""       ,Nil}) //09
Aadd(aBaixa,{"AUTCONTA"   ,""       ,Nil}) //10
Aadd(aBaixa,{"AUTDTBAIXA" ,CTOD("") ,Nil}) //11
Aadd(aBaixa,{"AUTHIST"    ,cHist	,Nil}) //12
Aadd(aBaixa,{"AUTDESCONT" ,0        ,Nil}) //13
Aadd(aBaixa,{"AUTMULTA"   ,0        ,Nil}) //14
Aadd(aBaixa,{"AUTJUROS"   ,0        ,Nil}) //15
Aadd(aBaixa,{"AUTOUTGAS"  ,0        ,Nil}) //16
Aadd(aBaixa,{"AUTVLRME"   ,0        ,Nil}) //17
Aadd(aBaixa,{"AUTCHEQUE"  ,""       ,Nil}) //18
Aadd(aBaixa,{"AUTTXMOEDA" ,0        ,Nil}) //19
Aadd(aBaixa,{"AUTDTDEB"   ,CTOD("") ,Nil}) //20

aBaixa[01,2]:= SE2->E2_PREFIXO
aBaixa[02,2]:= SE2->E2_NUM
aBaixa[03,2]:= SE2->E2_PARCELA
aBaixa[04,2]:= SE2->E2_TIPO
aBaixa[05,2]:= SE2->E2_FORNECE
aBaixa[06,2]:= SE2->E2_LOJA
aBaixa[08,2]:= SA6->A6_COD
aBaixa[09,2]:= SA6->A6_AGENCIA
aBaixa[10,2]:= SA6->A6_NUMCON
aBaixa[11,2]:= dDataBase
aBaixa[17,2]:= TRB->WB_PGTANT
aBaixa[19,2]:= SE2->E2_TXMOEDA
aBaixa[20,2]:= dDataBase

//NCF - 09/05/2020 - Não envia o valor quando o motivo de baixa não movimenta banco.
If !MovBcoBx(substr(cAutMotbx,1,3))                                      
   aDel(  aBaixa, aScan(aBaixa,{|x|x[1] == "AUTVLRME"}) )
   aSize( aBaixa, Len(aBaixa) - 1 )
EndIf

RegToMemory("SE2")
aEval(aBaixa, {|x| M->&(x[1]) := x[2] })
Private LF080AUTO := .T.
Private LF050AUTO := .T.

MSExecAuto({|x,y|FINA080(x,y)},aBaixa,nOptEx)

If lMSErroAuto
	MostraErro()
	Return .F.
EndIf

Return .T.

/*
Função....: AP100ElSdo(cAlias,nSaldoElim)
Autor.....: Gustavo Cunha
Descrição.: Eliminação de saldo dos pagamentos antecipados
Data......: 27/01/2014
Parâmetros: cAlias 	   -> Alias da Tabela
			nSaldoElim -> Não Obrigatório, valor que será eliminado do pagamento antecipado
Retorno...: lRet -> .T. Quando o saldo foi eliminado com sucesso
					.F. Quando o saldo não foi eliminado com sucesso
*/
*------------------------------------------------*
Function AP100ElSdo(cAlias,nSaldoElim)
*------------------------------------------------*
Local cProcesso  := SWA->WA_HAWB
Local lRet		 := .T.
Local nVlrComp	 := 0
Local nSaldoDisp := 0
Local lconfirma := .F.
Local cPicture	 := AvSX3("WB_SLDELI")[6]

Default nSaldoElim := (cAlias)->WB_SLDELI

Begin Sequence

	If Empty((cAlias)->WB_CA_DT)  // GFP - 14/04/2014 - Sistema não pode eliminar saldo de parcelas sem data de liquidação.
	   EasyHelp(STR0338,STR0079)//"Não é possível eliminar saldo de parcelas que não estejam liquidadas."
	   Return .F.
	EndIf

	If nSaldoElim == 0

        If (cAlias)->WB_RECNO > 0
            nVlrComp := ApuVlComp(cAlias)
        EndIf

	    nSaldoDisp := ((cAlias)->WB_PGTANT - (cAlias)->WB_SLDTRF - nVlrComp ) //LGS-02/05/2014
        If nSaldoDisp == 0
            EasyHelp(STR0341,STR0079)//"Adiantamento não possui saldo disponivel para ser eliminado."
            Break
        EndIf

        lRet := MsgYesNo(STR0380 + AllTrim(Transform(nSaldoDisp, cPicture)) + "?", STR0328) // STR0328 = "Eliminação de Saldo" // STR0380 = "Deseja eliminar o saldo no valor de "
        If lRet
		    Reclock(cAlias,.F.)
		    (cAlias)->WB_SLDELI := nSaldoDisp
		    (cAlias)->(MsUnLock())
		    lElimSaldo := .T. //LGS-02/05/2014
            If cAlias == "TRB"  // GFP - 14/04/2014
                M->WA_SLDANT -= nSaldoDisp
            EndIf
	    EndIf
    Else//estorno
        lRet := MsgYesNo(STR0382 + AllTrim(Transform(nSaldoElim, cPicture)) + "?", STR0328) // STR0382 = "Deseja restaurar o saldo no valor de "
        If lRet
            Reclock(cAlias,.F.)
		    (cAlias)->WB_SLDELI := 0
		    (cAlias)->(MsUnLock())
		    lElimSaldo := .T. //LGS-02/05/2014
            If cAlias == "TRB"  // GFP - 14/04/2014
                M->WA_SLDANT += nSaldoElim
            EndIf
        EndIf
	EndIf
End Sequence
Return lRet

/*
Função....: ApuVlComp(cAlias)
Autor.....: Gustavo Cunha
Descrição.: Apuração do valor compensado do pagamento antecipado
Data......: 27/01/2014
Parâmetros: cAlias -> Alias da Tabela
Retorno...: nPgtAnt-> Retorna o valor já compensado do pagamento antecipado
*/
Static Function ApuVlComp(cAlias)

Local cQry 	  := ""
Local nPgtAnt := 0
Local nRecOld := SWB->(RecNo())

cQry := "Select R_E_C_N_O_ AS RECNO From "+RetSqlName("SWB")+" SWB "
cQry += "Where D_E_L_E_T_ <> '*'"
cQry += "	And WB_FILIAL =  '"+xFilial("SWB")    +"'"
cQry += "	And WB_CHAVE  <> '"+Space(AvSx3("WB_CHAVE",3))+"'"  // GFP - 25/04/2014 - Ajustado tamanho do campo WB_CHAVE para funcionar corretamente em Oracle
cQry += "	And WB_NUMPO  =  '"+(cAlias)->WB_HAWB +"'"
cQry += "	And WB_LINHA  =  '"+(cAlias)->WB_LINHA+"'"
cQry += "	And WB_FORN   =  '"+(cAlias)->WB_FORN +"'"
cQry += "	And WB_LOJA   =  '"+(cAlias)->WB_LOJA +"'"

DbUseArea(.T., "TOPCONN", TcGenQry(,,cQry), "COMP", .F.)

Do While COMP->(!Eof())
	SWB->(dbGoTo(COMP->RECNO))
	nPgtAnt += SWB->WB_PGTANT
   	COMP->(dbSkip())
EndDo

COMP->(dbCloseArea())

SWB->(DbGoTo(nRecOld))

Return nPgtAnt

/*
Função....: Ap100PGTASS(cChave)
Autor.....: Gustavo Cunha
Descrição.: Formatação da Chave
Data......: 05/02/2014
Parâmetros: cChave -> Chave do pagamento antecipado associado (Indice 1 da tabela SWB)
Retorno...: cDescr -> Retorna a chave formatada para melhor visualização do usuário
*/
Static Function Ap100PGTASS(cChave)
Local cDescr := ""
Local aWB := SWB->({IndexOrd(),RecNo()})
Local i

SWB->(dbSetOrder(1))
SWB->(dbSeek(cChave))

aCpos := EasyQuebraChave(SWB->(IndexKey()),.F.)
For i := 1 To Len(aCpos)
   cDescr += AllTrim(AvSX3(aCpos[i],AV_TITULO))+": "+AllTrim(cValToChar(SWB->(FieldGet(FieldPos(aCpos[i])))))+" "
Next i

SWB->(DbSetOrder(aWB[1]))
SWB->(DbGoTo(aWB[2]))

Return cDescr


/*
Função....: AP100F3PgAss()
Autor.....: Gustavo Cunha
Descrição.: Consulta Padrão do campo WB_CHVASS
Data......: 05/02/2014
Parâmetros: Nenhum
Retorno...: Nenhum
*/
Function AP100F3PgAss()

Local aF3_Campos:= {}
Local aCampoF3	:= {}
Local cChave    := ""
Local cFilSWA   := xFilial("SWA")
Local cForLoj	:= M->(WB_FORN+WB_LOJA)
Local cMarca	:= GetMark()
Local cQry      := ""
Local cRet		:= ""
Local cTitulo   := "Associação de Parcelas"
Local lRet		:= .T.
Local oDlg

If Empty(M->WB_FORN) .Or. Empty(M->WB_LOJA)
	MsgInfo("Os campos Fornecedor e/ou loja devem ser preenchidos.", STR0063) // "Os campos Fornecedor e/ou loja devem ser preenchidos."###"Atenção"
	Return
EndIf

Aadd(aF3_Campos,{"WB_FILIAL" , AvSx3("WB_FILIAL" , 2), AvSx3("WB_FILIAL" , 3), AvSx3("WB_FILIAL" , 4)})
Aadd(aF3_Campos,{"WB_PO_DI"  , AvSx3("WB_PO_DI"  , 2), AvSx3("WB_PO_DI"  , 3), AvSx3("WB_PO_DI"  , 4)})
Aadd(aF3_Campos,{"WB_HAWB"   , AvSx3("WB_HAWB"   , 2), AvSx3("WB_HAWB"   , 3), AvSx3("WB_HAWB"   , 4)})
Aadd(aF3_Campos,{"WB_PGTANT" , AvSx3("WB_PGTANT" , 2), AvSx3("WB_PGTANT" , 3), AvSx3("WB_PGTANT" , 4)})
Aadd(aF3_Campos,{"WA_SLDANT" , AvSx3("WA_SLDANT" , 2), AvSx3("WA_SLDANT" , 3), AvSx3("WA_SLDANT" , 4)})
Aadd(aF3_Campos,{"WB_INVOICE", AvSx3("WB_INVOICE", 2), AvSx3("WB_INVOICE", 3), AvSx3("WB_INVOICE", 4)})
Aadd(aF3_Campos,{"WB_FORN"   , AvSx3("WB_FORN"   , 2), AvSx3("WB_FORN"   , 3), AvSx3("WB_FORN"   , 4)})
Aadd(aF3_Campos,{"WB_LOJA"   , AvSx3("WB_LOJA"   , 2), AvSx3("WB_LOJA"   , 3), AvSx3("WB_LOJA"   , 4)})
Aadd(aF3_Campos,{"WB_LINHA"  , AvSx3("WB_LINHA"  , 2), AvSx3("WB_LINHA"  , 3), AvSx3("WB_LINHA"  , 4)})
Aadd(aF3_Campos,{"WB_BANCO"  , AvSx3("WB_BANCO"  , 2), AvSx3("WB_BANCO"  , 3), AvSx3("WB_BANCO"  , 4)})
Aadd(aF3_Campos,{"WB_CONTA"  , AvSx3("WB_CONTA"  , 2), AvSx3("WB_CONTA"  , 3), AvSx3("WB_CONTA"  , 4)})
Aadd(aF3_Campos,{"WB_AGENCIA", AvSx3("WB_AGENCIA", 2), AvSx3("WB_AGENCIA", 3), AvSx3("WB_AGENCIA", 4)})
Aadd(aF3_Campos,{"WB_DT_CONT", AvSx3("WB_DT_CONT", 2), AvSx3("WB_DT_CONT", 3), AvSx3("WB_DT_CONT", 4)})
Aadd(aF3_Campos,{"WB_CA_NUM" , AvSx3("WB_CA_NUM" , 2), AvSx3("WB_CA_NUM" , 3), AvSx3("WB_CA_NUM" , 4)})
Aadd(aF3_Campos,{"WB_DT_DESE", AvSx3("WB_DT_DESE", 2), AvSx3("WB_DT_DESE", 3), AvSx3("WB_DT_DESE", 4)})
Aadd(aF3_Campos,{"WB_CA_DT"  , AvSx3("WB_CA_DT"  , 2), AvSx3("WB_CA_DT"  , 3), AvSx3("WB_CA_DT"  , 4)})
Aadd(aF3_Campos,{"WB_CA_TX"  , AvSx3("WB_CA_TX"  , 2), AvSx3("WB_CA_TX"  , 3), AvSx3("WB_CA_TX"  , 4)})
Aadd(aF3_Campos,{"WB_DT_VEN" , AvSx3("WB_DT_VEN" , 2), AvSx3("WB_DT_VEN" , 3), AvSx3("WB_DT_VEN" , 4)}) // RMD - 14/03/2014
Aadd(aF3_Campos,{"WB_MOEDA"  , AvSx3("WB_MOEDA"  , 2), AvSx3("WB_MOEDA"  , 3), AvSx3("WB_MOEDA"  , 4)}) // RMD - 14/03/2014
Aadd(aF3_Campos,{"WB_TIPOPAG", AvSx3("WB_TIPOPAG", 2), AvSx3("WB_TIPOPAG", 3), AvSx3("WB_TIPOPAG", 4)}) // RMD - 14/03/2014

Aadd(aF3_Campos,{"WB_PREFIXO", AvSx3("WB_PREFIXO", 2), AvSx3("WB_PREFIXO", 3), AvSx3("WB_PREFIXO", 4)}) // NCF - 05/06/2020
Aadd(aF3_Campos,{"WB_NUMDUP" , AvSx3("WB_NUMDUP" , 2), AvSx3("WB_NUMDUP" , 3), AvSx3("WB_NUMDUP" , 4)}) // NCF - 05/06/2020
Aadd(aF3_Campos,{"WB_PARCELA", AvSx3("WB_PARCELA", 2), AvSx3("WB_PARCELA", 3), AvSx3("WB_PARCELA", 4)}) // NCF - 05/06/2020
Aadd(aF3_Campos,{"WB_TIPOTIT", AvSx3("WB_TIPOTIT", 2), AvSx3("WB_TIPOTIT", 3), AvSx3("WB_TIPOTIT", 4)}) // NCF - 05/06/2020

Aadd(aF3_Campos,{"WB_RECNO"  , "N"                   , 10                    , 0})

//THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados
cFileWork_F3 := E_CriaTrab(,aF3_Campos,"Work_F3")

//Criar Work Campos do F3
cQry := "Select SWB.R_E_C_N_O_ AS RECNO From "+RetSqlName("SWB")+" SWB "
cQry += "Inner Join "+RetSqlName("SWA")+" SWA "
cQry += "	On  WA_HAWB  = WB_HAWB  "
cQry += "	And WA_PO_DI = WB_PO_DI "
cQry += "Where SWA.D_E_L_E_T_ <> '*' AND SWB.D_E_L_E_T_ <> '*' "
cQry += "	And WA_FILIAL =  '"+cFilSWA+"'"
cQry += "	And WA_HAWB   <>  '"+M->WA_HAWB+"'"
cQry += "	And WA_PO_DI  IN ('A','F')"
cQry += "	And WA_SLDANT >  0"
cQry += "	And WB_FORN   =  '"+M->WB_FORN +"'"
cQry += "	And WB_LOJA   =  '"+M->WB_LOJA +"'"
cQry += "	And WB_CA_DT  <> '        '"  // GFP - 14/04/2014 - Ajustado tamanho do campo WB_CA_DT para funcionar corretamente em Oracle

DbUseArea(.T., "TOPCONN", TcGenQry(,,cQry), "QRY_F3", .F.)

Do While QRY_F3->(!Eof())
	SWB->(DbGoTo(QRY_F3->Recno))

    nSaldoDisp := SWB->WB_PGTANT - SWB->WB_SLDELI - SWB->WB_SLDTRF - ApuVlComp("SWB")
    If SWB->WB_SLDTRF == 0  // GFP - 14/05/2014
       nSaldoDisp -= ChkAssoc(SWB->(WB_FILIAL+WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN+WB_LOJA+WB_LINHA))  // GFP - 17/04/2014
    EndIf

    If nSaldoDisp > 0
    	Work_F3->(DbAppend())
		Work_F3->WB_FILIAL  := SWB->WB_FILIAL
		Work_F3->WB_PO_DI   := SWB->WB_PO_DI
		Work_F3->WB_HAWB    := SWB->WB_HAWB
		Work_F3->WB_PGTANT  := SWB->WB_PGTANT
		Work_F3->WA_SLDANT  := nSaldoDisp
		Work_F3->WB_PO_DI   := SWB->WB_PO_DI
		Work_F3->WB_INVOICE := SWB->WB_INVOICE
		Work_F3->WB_FORN    := SWB->WB_FORN
		Work_F3->WB_LOJA    := SWB->WB_LOJA
		Work_F3->WB_LINHA   := SWB->WB_LINHA
		Work_F3->WB_CONTA   := SWB->WB_CONTA
		Work_F3->WB_BANCO   := SWB->WB_BANCO
		Work_F3->WB_AGENCIA := SWB->WB_AGENCIA
		Work_F3->WB_CA_NUM  := SWB->WB_CA_NUM
		Work_F3->WB_CA_TX   := SWB->WB_CA_TX
		Work_F3->WB_CA_DT   := SWB->WB_CA_DT
		Work_F3->WB_DT_CONT := SWB->WB_DT_CONT
		Work_F3->WB_DT_DESE := SWB->WB_DT_DESE
		Work_F3->WB_DT_VEN  := SWB->WB_DT_VEN   // RMD - 14/03/2014
		Work_F3->WB_MOEDA   := SWB->WB_MOEDA
		Work_F3->WB_TIPOPAG := SWB->WB_TIPOPAG

		Work_F3->WB_PREFIXO := SWB->WB_PREFIXO  // NCF - 05/06/2020
		Work_F3->WB_NUMDUP  := SWB->WB_NUMDUP
		Work_F3->WB_PARCELA := SWB->WB_PARCELA
		Work_F3->WB_TIPOTIT := SWB->WB_TIPOTIT     

		Work_F3->WB_RECNO   := SWB->(Recno())
    EndIf

   	QRY_F3->(DbSkip())
EndDo

QRY_F3->(dbCloseArea())

Aadd(aCampoF3,{"WB_PO_DI" , , AvSx3("WB_PO_DI" ,5), AvSx3("WB_PO_DI" ,6)})
Aadd(aCampoF3,{"WB_HAWB"  , , AvSx3("WB_HAWB"  ,5), AvSx3("WB_HAWB"  ,6)})
Aadd(aCampoF3,{"WB_PGTANT", , AvSx3("WB_PGTANT",5), AvSx3("WB_PGTANT",6)})
Aadd(aCampoF3,{"WA_SLDANT", , AvSx3("WA_SLDANT",5), AvSx3("WB_PGTANT",6)})

Define MsDialog oDlg Title cTitulo From 0,0 To 25,75 Of oMainWnd

	Work_F3->(DbGoTop())
	oF3:=MsSelect():New("Work_F3",,,aCampoF3,,cMarca,{25,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2})
	oF3:bAval:= {|| oDlg:End()}
   oF3:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

Activate MsDialog oDlg On Init EnchoiceBar(oDlg,{|| oDlg:End()}, {|| oDlg:End(), lRet := .F.}) Centered

cChave := Work_F3->(WB_FILIAL+WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN+WB_LOJA+WB_LINHA)

If lRet
	M->WB_PGTASS  := cChave
	M->WB_CHVASS  := Ap100PGTASS(cChave)
	M->WB_PGTANT  := If(Work_F3->WA_SLDANT <= M->WB_PGTANT,Work_F3->WA_SLDANT,M->WB_PGTANT)  // GFP - 06/05/2014
	M->WB_CONTA   := Work_F3->WB_CONTA
	M->WB_BANCO   := Work_F3->WB_BANCO
	M->WB_AGENCIA := Work_F3->WB_AGENCIA
	M->WB_CA_NUM  := Work_F3->WB_CA_NUM
	M->WB_CA_TX   := Work_F3->WB_CA_TX
	M->WB_CA_DT   := Work_F3->WB_CA_DT
	M->WB_DT_CONT := Work_F3->WB_DT_CONT
	M->WB_DT_DESE := Work_F3->WB_DT_DESE
	M->WB_DT_VEN  := Work_F3->WB_DT_VEN   // RMD - 14/03/2014
	M->WB_MOEDA   := Work_F3->WB_MOEDA
	M->WB_TIPOPAG := Work_F3->WB_TIPOPAG
	M->WB_FOBREAL := M->WB_PGTANT * Work_F3->WB_CA_TX

   M->WB_PREFIXO := Work_F3->WB_PREFIXO  // NCF - 05/06/2020
	M->WB_NUMDUP  := Work_F3->WB_NUMDUP  
	M->WB_PARCELA := Work_F3->WB_PARCELA 
	M->WB_TIPOTIT := Work_F3->WB_TIPOTIT 
EndIf

oEnCh1:Refresh()

//Work_F3->(DbCloseArea())
//FErase(cFileWork_F3)
If Select("Work_F3") > 0
    Work_F3->(E_EraseArq(cFileWork_F3)) //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados
EndIf

Return lRet

/*
Função....: AP100F3PgRet()
Autor.....: Nilson Cesar
Descrição.: Retornar resultado da consulta padrão SWBF3
Data......: 27/12/2018
Parâmetros: Nenhum
Retorno...: cChaveRet - conteúdo para o campo WB_CHVASS
*/
Function AP100F3PgRet()

Local cChaveRet := ""

If !Empty(M->WB_CHVASS)
   cChaveRet := M->WB_CHVASS
EndIf

Return cChaveRet


/*
Função....: ChkAssoc()
Autor.....: Guilherme Fernandes Pilan - GFP
Descrição.: Verifica se registro atual já está associado ao cambio.
Data......: 16/04/2014 - 17:08
*/
*----------------------------------*
Static Function ChkAssoc(cChave)
*----------------------------------*
Local nValorAss := 0
Local aOrd := SaveOrd("TRB")

Begin Sequence
   TRB->(DbGoTop())
   Do While TRB->(!Eof())
      If !Empty(TRB->WB_PGTASS) .AND. AllTrim(TRB->WB_PGTASS) == AllTrim(cChave)
         nValorAss := TRB->WB_PGTANT
         Break
      EndIf
      TRB->(DbSkip())
   EndDo
End Sequence

RestOrd(aOrd,.T.)
Return nValorAss
/*
Função....: INTAP110()
Autor.....: Jacomo Lisa
Descrição.: Chama a Integração do Logix (EICAP110)
Data......: 07/08/2014
Revisão...: wfs jun/2017
            Correção na integração da exclusão de parcelas de câmbio da invoice.
            Adicionado segundo parâmetro para diferenciar a exclusão da parcela do estorno da liquidação.
*/
*----------------------------------*
Static Function INTAP110(nOpc, nTipo)
*----------------------------------*
Local lRet      := .T.,i
Local nRecTRB   := 0
Local aEnvia_AP := {}
LOCAL cAlias1   :="SWB"
LOCAL aOrd      := SaveOrd({"SWA","SWB","TRB"})
Local nRecSWA 	:= SWA->(Recno())
Local lGravaOk  :=.F.
Local j
Default nOpc    := 3
Default nTipo   := 0

SWA->(DBGOTO(nRecSWA))

DO CASE

   CASE nOpc == 3

      IF (M->WA_PO_DI == "D" .AND. AvFlags("EAI_PGANT_INV_NF") .AND. SW6->(DBSEEK(xFilial("SW6")+TRB->WB_HAWB)) .AND. EMPTY(SW6->W6_DT_NF) .AND.  TRB->WB_EVENT == "608" ).OR. M->WA_PO_DI $ "A/F/C"
         nRecTRB := TRB->(RECNO())


         IF TRB->WB_PO_DI == "D" .OR. (TRB->WB_PO_DI $ "A/F/C" .AND. !EMPTY(TRB->WB_CA_DT)  .AND.  EMPTY(TRB->WB_NUMDUP) )
              //EICAP110(lEnvio,nOpc,cHawb       ,cFaseAP      ,cTipParc,lJumpVal,cTipo,aAltParc,cTabAlias)
            IF !EICAP110(.T.   ,nOpc,TRB->WB_HAWB,TRB->WB_PO_DI,NIL     ,NIL     ,NIL  ,NIL     ,'TRB')
               lRet=.F.
            ENDIF
            /*If TRB->WB_PO_DI == "A" .And. TRB->WB_EVENT == "609" .and. lRet
               //Ap100ChgPR(3,"TRB")
               AvProvRecalc(SWA->WA_HAWB)
            EndIf*/
         ENDIF

      ELSEIF TRB->WB_EVENT <> "608" .AND. (!EMPTY(TRB->WB_NUMDUP) .OR. Left(TRB->WB_TIPOREG,1) == "P")
	     nRecComp := NIL
		 If Left(TRB->WB_TIPOREG,1) == "P"
		    cChave      := TRB->WB_CHAVE
            nRecno      := TRB->(RECNO())

            TRB->(DBGOTOP())
            While TRB->(!EOF())
               If TRB->(WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN+WB_LOJA+WB_LINHA) == Alltrim(cChave)
			      nRecComp := TRB->(RecNo())
		          Exit
               EndIf
               TRB->(DBSKIP())
            EndDo

            TRB->(DBGOTO(nRecno))
		 EndIf

         IF !EICAP111(.T.,3,TRB->WB_HAWB,TRB->WB_RECNO,'TRB',,,nRecComp) // LIQUIDACAO DOS TITU
            lRet:= .F.
         ENDIF
      ENDIF

   CASE nOpc == 5

      //IF (M->WA_PO_DI == "D" .AND. AvFlags("EAI_PGANT_INV_NF") .AND. SW6->(DBSEEK(xFilial("SW6")+TRB->WB_HAWB)) .AND. EMPTY(SW6->W6_DT_NF) .AND.  TRB->WB_EVENT == "608" ).OR. M->WA_PO_DI == "A"
      //wfs - tratar tanto exclusão da parcela de câmbio pela rotina de controle de câmbio quanto o estorno da liquidação
      If (M->WA_PO_DI == "D" .AND.;
         (nTipo <> 7 .Or. AvFlags("EAI_PGANT_INV_NF") .AND. SW6->(DBSEEK(xFilial("SW6")+TRB->WB_HAWB)) .AND. EMPTY(SW6->W6_DT_NF) .AND.  TRB->WB_EVENT == "608" ));
         .OR. M->WA_PO_DI $ "A/F/C"
                  
         SWA->(DBGOTO(nRecSWA))

         IF TRB->WB_PO_DI == "D" .OR. (TRB->WB_PO_DI $ "A/F/C" .AND.   EMPTY(TRB->WB_CA_DT)  .AND. !EMPTY(TRB->WB_NUMDUP) )
              //EICAP110(lEnvio,nOpc,cHawb       ,cFaseAP      ,cTipParc,lJumpVal,cTipo,aAltParc,cTabAlias)
            IF !EICAP110(.T.   ,nOpc,TRB->WB_HAWB,TRB->WB_PO_DI,NIL     ,NIL     ,NIL  ,NIL     ,'TRB')
               lRet:= .F.
               //Retirar do array aDeletados, para não comprometer a tabela SWB
               i:= AScan(aDeletados, TRB->WB_RECNO)
               If i <> 0
                  ASize(aDeletados, Len(aDeletados) - 1)
               EndIf
            ENDIF
            IF lRet .AND. AvFlags("EAI_PGANT_INV_NF") .AND. SW6->(DBSEEK(xFilial("SW6")+TRB->WB_HAWB)) .AND. EMPTY(SW6->W6_DT_NF)
              TRB->WB_EVENT := "101"
            ENDIF
            /*If TRB->WB_PO_DI == "A" .And. TRB->WB_EVENT == "609" .and. lRet
               //Ap100ChgPR(5,"TRB")
               AvProvRecalc(SWA->WA_HAWB)
            EndIf*/
         ENDIF

      ELSEIF  M->WA_PO_DI == "D" .AND. TRB->WB_EVENT <> "608"
         IF !EICAP112(.T.,3,TRB->WB_HAWB,TRB->WB_RECNO,'TRB')
            lRet:= .F.
         ENDIF
      ENDIF

ENDCASE

dbSelectArea("SWA")
SWA->(DBGOTO(nRecSWA))
IF !lRet
   FOR i := 1 TO LEN(aSWA_OLD)
      M->&(aSWA_OLD[i][1])   := aSWA_OLD[i][2]
   NEXT i

   FOR j := 1 To Len(aTRB_OLD)
      TRB->(dbGoTo(aTRB_OLD[j][1]))

	  If ValType(aTRB_OLD[j][2]) == "U"
	     TRB->(dbDelete())
	  Else
	     If TRB->(Deleted())
		    TRB->(dbRecall())
		 EndIf

         FOR i := 1 TO LEN(aTRB_OLD[j][2])
            TRB->&(aTRB_OLD[j][2][i][1]) := aTRB_OLD[j][2][i][2]
         NEXT i
	  EndIf
   NEXT j
Else
   Processa({||lGravaOk:=APE100Grava("SWA",cAlias1)})
   If !lGravaOk
      Help(" ",1,"A110NAORE")
   ENDIF
EndIf

RestOrd(aOrd,.T.)
Return lRet

/*
Função....: IntTitPend()
Autor.....: Jacomo Lisa
Descrição.: Chama a Integração do Logix qndo há itens pendentes(EICAP110)
Data......: 07/08/2014
*/
*---------------------------------------------------*
Function IntTitPend()
*---------------------------------------------------*
Local lTitEAI_OK := .T.
Private aInts   := {{},{}}
Private aOpcoes := {}
SW6->(DBSETORDER(1))
AADD(aOpcoes,"Atual")
AADD(aOpcoes,"Todos")
AADD(aOpcoes,"Sair")


nBotao:=AVISO(STR0063,; //"Atencao"
              STR0348+; //"Esta opção é utilizada para enviar títulos ao ERP referentes à Invoices não Integradas do processo de Importação"
              STR0349,; //"Selecione o botão 'Atual' para o processo posicionado ou o botão 'Todos' para processar todas as invoices que estejam pendentes."
              aOpcoes,3)

IF nBotao = 1//"Atual"
   IF SWA->WA_PO_DI <> "D"
      MSGALERT(STR0350) //"Opção não disponível para esse tipo de câmbio"
      Return .T.
   ENDIF
   IF SW6->(DBSEEK(xFilial("SW6")+SWA->WA_HAWB))
      IF SW6->W6_TITOK == "1" .And. SW6->W6_TITOK == AP110AtuStatus(SW6->W6_HAWB, .F.)// Se não estiver OK o processo, não permite enviar
         MSGALERT(STR0351) //"Processo não possui títulos pendentes para Integração"
         Return .T.
      ENDIF
      MsAguarde({|| AP100IProcP()}, STR0364) //"Integrando processo..."

      If Len(aInts[1]) > 0
         MsgInfo(StrTran(STR0365, "####", AllTrim(SW6->W6_HAWB)), STR0079) //"Integrações financeiras do processo #### realizadas com sucesso.", Aviso
      EndIf

      /* Realiza a atualização/ correção do status do processo com relação as integrações com o financeiro. */
      AP110AtuStatus(SW6->W6_HAWB)
   ENDIF
   Return .T.
ELSEIF nBotao = 2//"Todos"
   IF MSGYESNO(STR0352) //"Tem certeza que deseja integrar todas as Invoices pendentes?"
      oProgress := EasyProgress():New()

      oProgress:SetProcess({|| AP100IProcP(.T.) }, STR0364) //"Integrando processos..."
      oProgress:Init()

      cMsg := ""
      If Len(aInts[1]) > 0
         cMsg += STR0366 + ENTER //"Integrações financeiras realizadas com sucesso para os processos:"
         aEval(aInts[1],{|X| cMsg+= AllTrim(X)+ENTER})
         cMsg += ENTER
      EndIf

      If Len(aInts[2]) > 0
         cMsg += STR0367 + ENTER //"Ocorreram falhas nas integrações financeiras para do processo:"
         cMsg += AllTrim(aInts[2][1])+ENTER
      EndIf

      If !Empty(cMsg)
         EECView(cMsg)
      EndIf
   ENDIF

   RETURN .T.
ELSE //Botao Sair ou X

   RETURN .F.//"Sair" - Nao faz nada

ENDIF

RETURN .T.

Static Function AP100IProcP(lTodos)
Local lTitEAI_OK := .T.
Local cQry
Private aDelCambio:= {}
Default lTodos   := .F.

If lTodos
   cQry := "Select W6_HAWB, R_E_C_N_O_ AS RECNO from "+RetSQLName("SW6")+" SW6 where W6_TITOK <> '1' AND "+RetSqlCond("SW6")

   nTot := EasyQryCount(cQry)

   If nTot == 0
      MsgInfo(STR0368, STR0079) //"Não há processos com integrações financeiras pendentes", Aviso
   Else
      EasyQry(cQry,"QRYW6")

      oProgress:SetRegua(nTot)

      QRYW6->(dbGoTop())
      DO WHILE QRYW6->(!EOF()) .AND. lTitEAI_OK
         SW6->(dbGoTo(QRYW6->RECNO))
         lTitEAI_OK := AP100IProcP(.F.)

         If !oProgress:IncRegua()
            MsgInfo(STR0369, STR0063) //"Processo interrompido pelo usuário", Atenção
            EXIT
         EndIf

         QRYW6->(DBSKIP())
      ENDDO

      QRYW6->(dbCloseArea())
   EndIf
Else
   
   aDelCambio:= {} //wfs jun/2017 - array para armazenar os recnos das parcelas de câmbio que tiveram o título excluído na execução da rotina de integrações pendentes

   If (!AvFlags("EAI_PGANT_INV_NF") .OR. (!EMPTY(SW6->W6_DT_NF)) ) .AND. !EICAP110(.T.,3,SW6->W6_HAWB,"D","1",.T.,"1",,, AvFlags("EAI_PGANT_INV_NF")) .OR.;
   !EICAP110(.T.,3,SW6->W6_HAWB,"D","A",.T.,"A") .OR.;
   !EICAP110(.T.,3,SW6->W6_HAWB,"D","B",.T.,"B") .Or.;
   !EICAP110(.T.,5,SW6->W6_HAWB,"D","1",.T.,"1",,, AvFlags("EAI_PGANT_INV_NF")) //wfs - exclusão
      lTitEAI_OK := .F.
   Else
      IF (AvFlags("EAI_PGANT_INV_NF") .AND. (!EMPTY(SW6->W6_DT_NF))) //Compensação das parcelas do tipo 608
         lTitEAI_OK := EICAP110(.T.,3,SW6->W6_HAWB,"D","1",.T.,"1",,, .T.) .And. EICAP111(.T.,3,SW6->W6_HAWB,        ,         ,"1",.T.)
      ELSEIF (AvFlags("EAI_PGANT_INV_NF") .AND. (EMPTY(SW6->W6_DT_NF))) //Estorno da Compensação das parcelas do tipo 608
         lTitEAI_OK := EICAP112(.T.,3,SW6->W6_HAWB,        ,         ,"1",.T.) .And. EICAP110(.T.,5,SW6->W6_HAWB,"D","1",.T.,"1",,, .T.)

      ENDIF
   EndIf

   If lTitEAI_OK
      aAdd(aInts[1],SW6->W6_HAWB)
      //wfs jun/2017 - Exclusão das parcelas de câmbio que tiveram o título excluído
      DeleteCambio(aDelCambio)
   Else
      aAdd(aInts[2],SW6->W6_HAWB)
   EndIf
EndIf

Return lTitEAI_OK

/*
Função....: GerAdiCred()
Autor.....: Guilherme Fernandes Pilan - GFP
Descrição.: Gera as parcelas de crédito espelhadas no registro de adiantamento do processo.
Data......: 30/04/2014 :: 10:00
*/
*----------------------------------*
Static Function GerAdiCred(lGerSWB)
*----------------------------------*
Local cQry := ""

cQry := "Select SWB.*, SWA.*,  SWB.R_E_C_N_O_ AS WB_RECNO From "+RetSqlName("SWB")+" SWB "
cQry += "Inner Join "+RetSqlName("SWA")+" SWA "
cQry += "On SWA.WA_HAWB  = SWB.WB_HAWB "
cQry += "And SWA.WA_PO_DI = SWB.WB_PO_DI "
cQry += "Where SWA.D_E_L_E_T_ <> '*' AND SWB.D_E_L_E_T_ <> '*' "
cQry += "And SWA.WA_FILIAL =  '"+xFilial("SWA")+"' "
cQry += "And SWA.WA_HAWB   = '"+M->WA_HAWB+"' "
cQry += "And SWA.WA_PO_DI  = 'A' "
cQry += "And SWA.WA_SLDANT >  0 "

EasyWkQuery(cQry,"QRY",{"WB_FILIAL+WB_HAWB"}, {{"WB_RECNO", "N", 10, 0}})

QRY->(DbGoTop())
M->WA_PGTANT := QRY->WA_PGTANT
M->WA_SLDANT := 0 //QRY->WA_SLDANT
If QRY->(!Bof()) .AND. QRY->(!Eof())
   Do While QRY->(!Eof())
      TRB->(DBAPPEND())
      AvReplace("QRY","TRB")
	   //THTS - 14/10/2019 - Ajuste de chave criado para o projeto do grupo de campos do Hawb, PO_NUM e Invoice
	   //TRB->WB_CHAVE   := AP100WBCHV(TRB->WB_CHAVE)
      TRB->WB_PO_DI   := "C"
      TRB->TRB_ALI_WT := "SWB"
      TRB->TRB_REC_WT := 0 //QRY->WB_RECNO
      //NCF - 22/05/2020
      TRB->WB_CA_NUM  := ''
      TRB->WB_DT_DESE := cToD("  /  /  ")
      TRB->WB_CA_DT   := cToD("  /  /  ")
      TRB->WB_CA_NUM  := ''
      TRB->WB_DT_CONT := cToD("  /  /  ")
      TRB->WB_CA_TX   := 0
      TRB->WB_LIM_BAC := cToD("  /  /  ")
      TRB->WB_DT_DIG  := cToD("  /  /  ")
      TRB->WB_NUMDUP  := ''
      TRB->WB_PARCELA := ''
      TRB->WB_TIPOTIT := ''
      TRB->WB_PREFIXO := ''
      TRB->WB_VLIQ    := 0
      TRB->WB_PGTASS  := ''
      TRB->WB_RECNO   := 0
      QRY->(DbSkip())
   EndDo
   lGerSWB := .T.
EndIf

If Select("QRY") # 0
   QRY->(DbCloseArea())
EndIf

Return

/*
Função....: ChkAltCred()
Autor.....: Guilherme Fernandes Pilan - GFP
Descrição.: Checa se é necessário ajustar registro de adiantamento x crédito
Data......: 30/04/2014 :: 14:44
*/
*-----------------------------------------*
Static Function ChkAltCred(cTipo,cOrigem)
*-----------------------------------------*
Local aOrd := SaveOrd({"SWA","SWB"})
Local cQry := ""
Local cTpCamb := If(cOrigem == "C","A",If(cOrigem == "A","C",""))

lTitCrd := If(Type("lTitCrd")<>"L",.T.,@lTitCrd)//LGS-11/09/2014

Begin Sequence

   SWB->(DbSetOrder(1))

   cQry := "Select * From "+RetSqlName("SWB")+" SWB "
   cQry += "Inner Join "+RetSqlName("SWA")+" SWA "
   cQry += "On SWA.WA_HAWB  = SWB.WB_HAWB "
   cQry += "And SWA.WA_PO_DI = SWB.WB_PO_DI "
   cQry += "Where SWA.D_E_L_E_T_ <> '*' AND SWB.D_E_L_E_T_ <> '*' "
   cQry += "And SWA.WA_FILIAL =  '"+xFilial("SWA")+"' "
   cQry += "And SWA.WA_HAWB   = '"+SWA->WA_HAWB+"' "
   If lTitCrd
   	  cQry += "And SWA.WA_PO_DI  = '"+cOrigem+"' "
   Else
   	  cQry += "And SWA.WA_PO_DI  = '"+cTpCamb+"' " //LGS-11/09/2014
   EndIf
   cQry += "And SWA.WA_SLDANT >  0 "
   EasyWkQuery(cQry,"QRY",{"WB_FILIAL+WB_HAWB"})

   QRY->(DbGoTop())
   If QRY->(Bof()) .AND. QRY->(Eof())
      Break
   EndIf

   If SWA->(DbSeek(xFilial("SWA")+QRY->WB_HAWB+cTpCamb))
      If SWA->(RecLock("SWA",.F.))
         SWA->WA_PGTANT := QRY->WA_PGTANT
         SWA->WA_SLDANT := QRY->WA_SLDANT
      EndIf
   EndIf

   If SWA->(DbSeek(xFilial("SWA")+QRY->WB_HAWB+cOrigem)) //LGS-11/09/2014
      If SWA->(RecLock("SWA",.F.))
	     SWA->WA_PGTANT := QRY->WA_PGTANT
	     SWA->WA_SLDANT := QRY->WA_SLDANT
	  EndIf
   EndIf

   Do While .T.
      If SWB->(DbSeek(xFilial("SWB")+QRY->WB_HAWB+AvKey(cTpCamb,"WB_PO_DI")))
         //Força gravar o nro do titulo no financeiro (SE2)
         QRY->WB_NUMDUP  := SWB->WB_NUMDUP
         QRY->WB_TIPOTIT := SWB->WB_TIPOTIT
		 QRY->WB_PREFIXO := SWB->WB_PREFIXO
         If SWB->(RecLock("SWB", .F.))
            SWB->(DbDelete())
            SWB->(MsUnlock())
         EndIf
      Else
         Exit
      EndIf
   EndDo

   Do While QRY->(!Eof())
      If SWB->(RecLock("SWB", .T.))
         AvReplace("QRY","SWB")
         SWB->WB_PO_DI := cTpCamb
         SWB->(MSUnlock())
      EndIf
      QRY->(DbSkip())
   EndDo

End Sequence

If Select("QRY") # 0
   QRY->(DbCloseArea())
EndIf

RestOrd(aOrd,.T.)
Return

/*
Função....: AP100RestReg()
Autor.....: Guilherme Fernandes Pilan - GFP
Descrição.: Ajusta registro de adiantamento x crédito durante estorno.
Data......: 30/04/2014 :: 14:44
*/
*-----------------------------------------*
Static Function AP100RestReg(aRegistros)
*-----------------------------------------*
Local aOrd := SaveOrd({"SWA","SWB"})
Local i := 0
Local lSWB := .F.

Begin Sequence
   If !SWB->(DbSeek(xFilial("SWB")+M->WA_HAWB+AvKey("A","WB_PO_DI"))) .OR.;
      !SWA->(DbSeek(xFilial("SWA")+M->WA_HAWB+AvKey("A","WA_PO_DI"))) .OR.;
      Len(aRegistros) == 0
      Break
   EndIf

   For i := 1 To Len(aRegistros)
      lSWB := .F.
      If SWB->(DbSeek(aRegistros[i][1])) .Or.;
         SWB->(DbSeek(xFilial("SWB")+M->WA_HAWB+AvKey("A","WB_PO_DI"))) //LGS-11/09/2014
         If SWB->(RecLock("SWB",.F.))
            SWB->WB_BANCO    := ""
            SWB->WB_AGENCIA  := ""
            SWB->WB_CONTA    := ""
            SWB->WB_DT_CONT  := CTOD("")
            SWB->WB_CA_NUM   := ""
            SWB->WB_DT_DESE  := CTOD("")
            SWB->WB_CA_DT    := CTOD("")
            SWB->WB_CA_TX    := 0
            SWB->WB_LIM_BAC  := CTOD("")
            SWB->WB_PGTASS   := ""
            SWB->(MsUnlock())
            lSWB := .T.
         EndIf
         If lSWB .AND. SWA->(RecLock("SWA",.F.))
            SWA->WA_SLDANT -= aRegistros[i][2]
            SWA->(MsUnlock())
         EndIf
      EndIf
   Next i

End Sequence

RestOrd(aOrd,.T.)
Return

/*
Função....: AP100AtuSWB()
Autor.....: Laercio G Souza Junior - LGS
Descrição.: Ajusta SWB caso ja tenha registro gravado de parcela de credito, coloca como liquidado e atualiza o saldo do cambio.
Data......: 11/09/2014 :: 17:15
*/
*-----------------------------*
Static Function AP100AtuSWB()
*-----------------------------*
Local aOrd := SaveOrd({"SWB"})
Local aSWB_Campos:= {}
Local lSWBLocked := .F.

Aadd(aSWB_Campos,{"WB_FILIAL"  , AvSx3("WB_FILIAL"  , 2), AvSx3("WB_FILIAL"    , 3), AvSx3("WB_FILIAL"  , 4)})
Aadd(aSWB_Campos,{"WB_HAWB"    , AvSx3("WB_HAWB"    , 2), AvSx3("WB_HAWB"      , 3), AvSx3("WB_HAWB"    , 4)})
Aadd(aSWB_Campos,{"WB_BANCO"   , AvSx3("WB_BANCO"   , 2), AvSx3("WB_BANCO"     , 3), AvSx3("WB_BANCO"   , 4)})
Aadd(aSWB_Campos,{"WB_AGENCIA" , AvSx3("WB_AGENCIA" , 2), AvSx3("WB_AGENCIA"   , 3), AvSx3("WB_AGENCIA" , 4)})
Aadd(aSWB_Campos,{"WB_CONTA"   , AvSx3("WB_CONTA"   , 2), AvSx3("WB_CONTA"     , 3), AvSx3("WB_CONTA"   , 4)})
Aadd(aSWB_Campos,{"WB_DT_VEN"  , AvSx3("WB_DT_VEN"  , 2), AvSx3("WB_DT_VEN"    , 3), AvSx3("WB_DT_VEN"  , 4)})
Aadd(aSWB_Campos,{"WB_DT_CONT" , AvSx3("WB_DT_CONT" , 2), AvSx3("WB_DT_CONT"   , 3), AvSx3("WB_DT_CONT" , 4)})
Aadd(aSWB_Campos,{"WB_DT_DESE" , AvSx3("WB_DT_DESE" , 2), AvSx3("WB_DT_DESE"   , 3), AvSx3("WB_DT_DESE" , 4)})
Aadd(aSWB_Campos,{"WB_CA_DT"   , AvSx3("WB_CA_DT"   , 2), AvSx3("WB_CA_DT"     , 3), AvSx3("WB_CA_DT"   , 4)})
Aadd(aSWB_Campos,{"WB_CA_TX"   , AvSx3("WB_CA_TX"   , 2), AvSx3("WB_CA_TX"     , 3), AvSx3("WB_CA_TX"   , 4)})
Aadd(aSWB_Campos,{"WB_BCO_REC" , AvSx3("WB_BCO_REC" , 2), AvSx3("WB_BCO_REC"   , 3), AvSx3("WB_BCO_REC" , 4)})
Aadd(aSWB_Campos,{"WB_AGENREC" , AvSx3("WB_AGENREC" , 2), AvSx3("WB_AGENREC"   , 3), AvSx3("WB_AGENREC" , 4)})
Aadd(aSWB_Campos,{"WB_CON_REC" , AvSx3("WB_CON_REC" , 2), AvSx3("WB_CON_REC"   , 3), AvSx3("WB_CON_REC" , 4)})
Aadd(aSWB_Campos,{"WB_TIPOC"   , AvSx3("WB_TIPOC"   , 2), AvSx3("WB_TIPOC"     , 3), AvSx3("WB_TIPOC"   , 4)})
Aadd(aSWB_Campos,{"WB_PARVIN"  , AvSx3("WB_PARVIN"  , 2), AvSx3("WB_PARVIN"    , 3), AvSx3("WB_PARVIN"  , 4)})

If SWB->(FieldPos("WB_PGTASS")) > 0 //MCF-15/09/2014
   Aadd(aSWB_Campos,{"WB_PGTASS"  , AvSx3("WB_PGTASS"  , 2), AvSx3("WB_PGTASS"    , 3), AvSx3("WB_PGTASS"  , 4)})
EndIf

cFileSWB_Campos := E_CriaTrab(,aSWB_Campos,"SWB_Campos") //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados

If SWB->(DbSeek(xFilial("SWB")+SWB->WB_HAWB+AvKey("C","WB_PO_DI")))
   SWB_Campos->(DbAppend())
   SWB_Campos->WB_FILIAL  := SWB->WB_FILIAL
   SWB_Campos->WB_HAWB	  := SWB->WB_HAWB
   SWB_Campos->WB_BANCO	  := SWB->WB_BANCO
   SWB_Campos->WB_AGENCIA := SWB->WB_AGENCIA
   SWB_Campos->WB_CONTA	  := SWB->WB_CONTA
   SWB_Campos->WB_DT_VEN  := SWB->WB_DT_VEN
   SWB_Campos->WB_DT_CONT := SWB->WB_DT_CONT
   SWB_Campos->WB_DT_DESE := SWB->WB_DT_DESE
   SWB_Campos->WB_CA_DT	  := SWB->WB_CA_DT
   SWB_Campos->WB_CA_TX	  := SWB->WB_CA_TX
   SWB_Campos->WB_BCO_REC := SWB->WB_BCO_REC
   SWB_Campos->WB_AGENREC := SWB->WB_AGENREC
   SWB_Campos->WB_CON_REC := SWB->WB_CON_REC
   SWB_Campos->WB_TIPOC	  := SWB->WB_TIPOC
   SWB_Campos->WB_PARVIN  := SWB->WB_PARVIN
   If SWB->(FieldPos("WB_PGTASS")) > 0 //MCF-15/09/2014
      SWB_Campos->WB_PGTASS  := SWB->WB_PGTASS
   EndIf
   RestOrd(aOrd,.T.)
EndIf

If SWB_Campos->(!Eof())
   If( (lSWBLocked  := !SWB->(IsLocked())) , SWB->(RecLock("SWB",.F.)) , )
   SWB->WB_FILIAL  := SWB_Campos->WB_FILIAL
   SWB->WB_HAWB	   := SWB_Campos->WB_HAWB
   SWB->WB_BANCO   := SWB_Campos->WB_BANCO
   SWB->WB_AGENCIA := SWB_Campos->WB_AGENCIA
   SWB->WB_CONTA   := SWB_Campos->WB_CONTA
   SWB->WB_DT_VEN  := SWB_Campos->WB_DT_VEN
   SWB->WB_DT_CONT := SWB_Campos->WB_DT_CONT
   SWB->WB_DT_DESE := SWB_Campos->WB_DT_DESE
   SWB->WB_CA_DT   := SWB_Campos->WB_CA_DT
   SWB->WB_CA_TX   := SWB_Campos->WB_CA_TX
   SWB->WB_BCO_REC := SWB_Campos->WB_BCO_REC
   SWB->WB_AGENREC := SWB_Campos->WB_AGENREC
   SWB->WB_CON_REC := SWB_Campos->WB_CON_REC
   SWB->WB_TIPOC   := SWB_Campos->WB_TIPOC
   SWB->WB_PARVIN  := SWB_Campos->WB_PARVIN
   If SWB->(FieldPos("WB_PGTASS")) > 0 //MCF-15/09/2014
      SWB->WB_PGTASS  := SWB_Campos->WB_PGTASS
   EndIf
   If lSWBLocked
      SWB->(MsUnlock())
   EndIf
EndIf

If Select("SWB_Campos") > 0
    SWB_Campos->(E_EraseArq(cFileSWB_Campos)) //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados
EndIf

Return Nil

/*
Função....: AP100Forn()
Autor.....: Marcos R R Cavini Filho - MCF
Descrição.: Apresenta tela de seleção de fornecedor.
Data......: 17/12/2014 11:00
*/
*-----------------------------*
Static Function AP100Forn()
*-----------------------------*
Local nOp
Local lRet:=.T.
cFornSA2 := Space(AVSX3("A2_COD",3))
cLojaSA2 := Space(AVSX3("A2_LOJA",3))

While lRet

	DEFINE MSDIALOG oDlgF TITLE STR0090 FROM 5,5 TO 150 ,340 OF oMainWnd PIXEL

	oPanel:= TPanel():New(0, 0, "", oDlgF,, .F., .F.,,, 90, 165)
	oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

	@ 20,010 Say STR0354 of oPanel PIXEL //Fornecedor
	@ 20,028 MSGET cFornSA2  F3 "VV6A"  VALID ExistCpo("SA2", cFornSA2) SIZE 60,08  of oPanel PIXEL
	@ 20,110 Say STR0355 of oPanel PIXEL //Loja
   @ 20,122 MSGET cLojaSA2  VALID ExistCpo("SA2", cFornSA2 + cLojaSA2) SIZE 30,08  of oPanel PIXEL

   ACTIVATE MSDIALOG oDlgF ON INIT EnchoiceBar(oDlgF,{||nOp:=1,oDlgF:End()},{||nOp:=0,oDlgF:End()}) CENTERED

   IF nOp=1 .AND. Empty(cFornSA2)
   	NAOVAZIO(cFornSA2)
   ELSE
   	lRet:=.F.
   ENDIF

END
RETURN(nOp)

/*
Funcao      : StatusPend()
Parâmetros  : Número do processo de embarque/ desembaraço
Retorno     : Lógico - indica se existem pendências de integração financeira para o processo
Objetivos   :
Autor       : WFS
Data 	     : 01/2015
Obs         :
Revisão     :
*/
Static Function StatusPend(cProcesso)
Local lRet:= .F.
Local aOrd:= SaveOrd({"SW6"})


   SW6->(DBSetOrder(1)) //W6_FILIAL+W6_HAWB
   SW6->(DBSeek(xFilial() + cProcesso))

   lRet:= SW6->W6_TITOK == "2" //pendências de integração

RestOrd(aOrd, .T.)
Return lRet

/*
Funcao      : AP100PAdLq(cPoNum,cAliasWB)
Parâmetros  : cPoNum - numero do Purchase Order (P.O) a ser verificado
            : cAliasWB - Alias do Arquivo (TRB - Arq.Temporário / SWB - Tabela)
Retorno     : nRet - Quantidade de Parcelas de Adiantamento liquidadas
Objetivos   : Retornar a quantidade de parcelas liquidadas para determinado P.O
Autor       : NCF
Data 	     : 18/10/2016
Obs         :
Revisão     :
*/
Function AP100PAdLq(cPONum,cAliasWB)

Local cQuery
Local nRecTRB
Local nRet := 0
Default cAliasWB := If( IsInCallStack("EICAP100") .And. Select("TRB")   > 0 .And. ;
                                        TRB->(FieldPos("WB_PO_DI"))   > 0 .And. ;
                                        TRB->(FieldPos("WB_TIPOREG")) > 0 .And. ;
                                        TRB->(FieldPos("WB_EVENT"))   > 0 .And. ;
                                        TRB->(FieldPos("WB_CA_DT"))   > 0 .And. ;
                                        TRB->(FieldPos("WB_EVENT"))   > 0 , "TRB" , "SWB")
Default cPONum := ""

If !Empty(cPoNum)
  If cAliasWB == "TRB"
      nRecTRB := TRB->(Recno())
      TRB->(DbGoTop())
      Do While TRB->(!Eof())
         If TRB->WB_PO_DI   == AvKey('A',"WB_PO_DI")   .And. ;
            TRB->WB_TIPOREG == AvKey('P',"WB_TIPOREG") .And. ;
            TRB->WB_EVENT   == AvKey('609',"WB_EVENT") .And. ;
            !Empty(TRB->WB_CA_DT) .And. TRB-> WB_CA_TX  <> 0
            nRet++
            Exit
         EndIf
         TRB->(DbSkip())
      EndDo
      TRB->(DbGoto(nRecTRB))
   Else
      If Select("TOTREGS") > 0
         TOTREGS->(DbCloseArea())
      EndIf

      cQuery := "SELECT COUNT(R_E_C_N_O_) TOTALPARCS"
      cQuery += " FROM "+RetSQLName("SWB")
      cQuery += " WHERE WB_HAWB    = '"+AvKey(cPONum,"WB_HAWB"   )+"'"
      cQuery += " AND   WB_PO_DI   = '"+AvKey('A'   ,"WB_PO_DI"  )+"'"
      cQuery += " AND   WB_TIPOREG = '"+AvKey('P'   ,"WB_TIPOREG")+"'"
      cQuery += " AND   WB_EVENT   = '"+AvKey('609' ,"WB_EVENT"  )+"'"
      cQuery += " AND   WB_CA_DT   <> '        '"
      cQuery += " AND   WB_CA_TX   <> 0 "
      cQuery += " AND   D_E_L_E_T_ = ' '"
      dbUseArea( .t., "TopConn", TCGenQry(,,cQuery),"TOTREGS", .F., .F. )

      nRet := TOTREGS->TOTALPARCS

      TOTREGS->(DbCloseArea())
  EndIf
Else
   nRet := 0
EndIf

return nRet

/*
Funcao      : DeleteCambio()
Parâmetros  : Array com os Recnos na SWB
Retorno     : 
Objetivos   : Excluir as parcelas de câmbio sem vínculo com a invoice que tiveram o título excluído no ERP
Autor       : WFS
Data 	      : jun/2017
Obs         : 
Revisão     :
*/
Static Function DeleteCambio(aRecnos)
Local x
Local aOrd:= SaveOrd({"SW9"})

Begin Sequence

   For x:= 1 To Len(aRecnos)

      SWB->(DBGoTo(aRecnos[x]))
      SW9->(DBSetOrder(1)) //W9_FILIAL+W9_INVOICE+W9_FORN+W9_FORLOJ+W9_HAWB

      /* caso a parcela não possua número de título e não possua invoice, estará pendente de exclusão da parcela de câmbio*/
      If SWB->WB_PO_DI == "D" .And. SWB->WB_EVENT = "101" .And. Empty(SWB->WB_NUMDUP) .And.;
         !SW9->(DBSeek(xFilial() + SWB->WB_INVOICE + SWB->WB_FORN + SWB->WB_LOJA + SWB->WB_HAWB))
         
         SWB->(RecLock("SWB", .F.))
         SWB->(DBDelete())
         SWB->(MsUnlock())

      EndIf
   Next

End Sequence

RestOrd(aOrd)
Return 

/*
Funcao      : RefazProv()
Parâmetros  : 
Retorno     : 
Objetivos   : Refazer títulos provisórios na integração com o ERP
Autor       : WFS
Data 	      : jul/2017
Obs         : 
Revisão     :
*/
Static Function RefazProv()
Local i
Local cNumPO:= ""
Local lBaixada
Local nOrderSW2

   nOrderSW2:= SW2->(IndexOrd())

   SW2->(DBSetOrder(1)) //W2_FILIAL+W2_PO_NUM

   For i:= 1 To Len(aNumPos)
      
      cNumPO:= Left(aNumPos[i], Len(SW2->W2_PO_NUM))     

      If SW2->(DBSeek(xFilial("SW2") + cNumPO))
         lBaixada:=.F.
         If AvFlags("EIC_EAI")
            AvProvRecalc(cNumPO) //reapuração de títulos provisórios
         Else
            If (LEFT(SWA->WA_PO_DI,1) <> "A" .And. LEFT(SWA->WA_PO_DI,1) <> "F" .And. LEFT(SWA->WA_PO_DI,1) <> "C")	// GCC - 27/08/2013
               Processa({|| FI400ANT_PO(cNumPO,.T.,@lBaixada)})
            EndIf            
            Processa({|| FI400POS_PO(cNumPO,lBaixada) })
         EndIf
      EndIf
   Next
   SW2->(DBSetOrder(nOrderSW2))

Return

/*
Funcao      : AP100WBCHV()
Parâmetros  : Chave (WB_CHAVE ou WB_CHVASS)
Retorno     : cRet - Chave corresponte ao campo WB_CHAVE ou WB_CHVASS.
Objetivos   : Verifiar o campo WB_CHAVE e WB_CHVASS, para o caso dos campos da chave terem seus tamanhos alterados.
Autor       : THTS - Tiago Henrique Tudisco dos Santos
Data 	      : 14/10/2019
*/
Function AP100WBCHV(cChaveOri)
Local cRet 		:= cChaveOri
Local cHawb		:= ""
Local cPODI		:= ""
Local cInvoice	:= ""
Local cForn		:= ""
Local cLoja		:= ""
Local cLinha 	:= ""
Local nPosIni	:= 1
Local cChave    := ""
Local aAreaSWB  := SWB->(GetArea())
Local aTamPadrao := {{'WB_HAWB'		,17},;
					 {'WB_PO_DI'	,1 },;
					 {'WB_INVOICE'	,15},;
					 {'WB_FORN'		,6 },;
					 {'WB_LOJA'		,2 },;
					 {'WB_LINHA'	,4 }}
If !Empty(cChaveOri)
    SWB->(dbSetOrder(1))//WB_FILIAL, WB_HAWB, WB_PO_DI, WB_INVOICE, WB_FORN, WB_LOJA, WB_LINHA
    If SWB->(dbSeek(xFilial("SWB") + cChaveOri))
        cRet := cChaveOri
    Else
        cHawb	:= SubStr(cChaveOri,nPosIni,aTamPadrao[1][2])
        nPosIni += aTamPadrao[1][2]
        cPODI	:= SubStr(cChaveOri,nPosIni,aTamPadrao[2][2])
        nPosIni += aTamPadrao[2][2]
        cInvoice:= SubStr(cChaveOri,nPosIni,aTamPadrao[3][2])
        nPosIni += aTamPadrao[3][2]
        cForn	:= SubStr(cChaveOri,nPosIni,aTamPadrao[4][2])
        nPosIni += aTamPadrao[4][2]
        cLoja	:= SubStr(cChaveOri,nPosIni,aTamPadrao[5][2])
        nPosIni += aTamPadrao[5][2]
        cLinha 	:= SubStr(cChaveOri,nPosIni,aTamPadrao[6][2])

        cChave	:= AvKey(cHawb,aTamPadrao[1][1]) + AvKey(cPODI,aTamPadrao[2][1]) + AvKey(cInvoice,aTamPadrao[3][1]) + AvKey(cForn,aTamPadrao[4][1]) + AvKey(cLoja,aTamPadrao[5][1]) + AvKey(cLinha,aTamPadrao[6][1])

        If SWB->(dbSeek(xFilial("SWB") + cChave))
            cRet := cChave
        EndIf
    EndIf

    RestArea(aAreaSWB)
EndIf
Return cRet

Static Function HasAdVinEm()
Local cQry, cNextAlias, lRet := .F.

     cQry := "Select R_E_C_N_O_ AS RECNO From "+RetSqlName("SWB")+" SWB "
     cQry += "Where D_E_L_E_T_ = ' '"
     cQry += "	And WB_FILIAL = '"+xFilial("SWB")+"'"
     cQry += "	And WB_HAWB  <> '"+SWB->WB_HAWB  +"'"
     cQry += "	And WB_CHAVE <> ' '"
     cQry += "	And WB_NUMPO =  '"+SWA->WA_HAWB	 +"'"
     cQry += "	And WB_FORN  =  '"+SWB->WB_FORN  +"'"
     cQry += "	And WB_LOJA  =  '"+SWB->WB_LOJA  +"'"
     cQry += "	And WB_PO_DI =  '"+SWA->WA_PO_DI +"'"

      cNextAlias := GetNextAlias()
      cQuery     := ChangeQuery(cQry)
      MPSysOpenQuery(cQry, cNextAlias)
      
      If (cNextAlias)->(!Bof()) .And. (cNextAlias)->(!Eof())
         lRet:= .T.
      EndIf

      (cNextAlias)->(DBCloseArea())

Return lRet


Static Function AtuSldSWA(cOp)
Local lPosSWA := .F.
Local lRet    := .F.

//NCF - 04/06/2020 - Posiciona o tipo de Adiant conforme nova gravação baseada em SX5 Chave Y6 ou conforme o legado.
If  Left(SWB->WB_TIPOREG,1) == "P" 	
   If   SWA->(DBSeek(If(lAdtMultfil,SWB->WB_FILORI,xFilial("SWA"))+SWB->WB_NUMPO+"A")) ;
   .Or. SWA->(DBSeek(If(lAdtMultfil,SWB->WB_FILORI,xFilial("SWA"))+SWB->WB_NUMPO+"F")) ;
   .Or. SWA->(DBSeek(If(lAdtMultfil,SWB->WB_FILORI,xFilial("SWA"))+SWB->WB_NUMPO+"C"))
      lPosSWA := .T. 
   EndIf
Endif

If lPosSWA
   SWA->(RecLock("SWA", .F.))
   SWA->WA_SLDANT +=  ( SWB->WB_PGTANT * If( cOp == "ESTCOMP", 1 , -1) )
   SWA->(MSUnlock())
   lRet := .T.
EndIf

Return lRet

Function SetF11FIN()
Return Pergunte("EICFI5",.T.)


/*
Funcao      : isCompensado()
Parâmetros  : 
Retorno     : lRer - Retorna se existe alguma parcela de câmbio compensada com o Adiantamento
Objetivos   :  Verifica se existe alguma parcela de câmbio compensada com o Adiantamento
Autor       : THTS - Tiago Henrique Tudisco dos Santos
Data 	      : 14/10/2020
*/
Static Function isCompensado(cNumPO,cLinha,cForn,cLoja,cFilOri)
Local lRet  := .F.
Local cQuery:= ""

cQuery := " SELECT WB_HAWB "
cQuery += " FROM " + RetSqlName("SWB") + " "
cQuery += " WHERE "
If lAdtMultFil
   cQuery += " WB_FILORI = '" + cFilOri + "' AND "
EndIf

cQuery += " WB_NUMPO  = '" + cNumPO + "' AND "
cQuery += " WB_PO_DI  = 'D' AND "
cQuery += " WB_TIPOREG= '"+AvKey('P'   ,"WB_TIPOREG")+"' AND "
cQuery += " WB_CHAVE  <>' ' AND "
cQuery += " WB_LINHA  = '" + cLinha + "' AND "
cQuery += " WB_FORN   = '" + cForn  + "' AND "
cQuery += " WB_LOJA   = '" + cLoja  + "' AND "
cQuery += " D_E_L_E_T_= ' ' "

If EasyQryCount(cQuery) > 0
   lRet := .T.
EndIf

Return lRet

/*
Funcao      : TemAdiant()
Parâmetros  : -
Retorno     : cRet - Mensagem com os totais de cada tipo de adto
Objetivos   : Retorna uma mensagem caso exista adiantamento para ser utilizado pelo processo. Caso não tenha retornará em branco
Autor       : THTS - Tiago Henrique Tudisco dos Santos
Data 	      : 04/11/2020
*/
Static Function TemAdiant()
Local cRet := ""
Local cQuery
Local aFiliais
Local nI
Local nJ
Local cFilMulti := ""
Local cAliasAdt := GetNextAlias()
Local aMoedaProc:= MoedasProc() //Retorna as moedas do processo
Local aForneProc:= FornecProc() //Retorna os fornecedores/loja do processo
Local aPOProc   := POsProc() //Retorna os POs do processo
Local aTotPO    := {{},{}}
Local aTotFor   := {}
Local aTotCred  := {}
Local nPosMoeda
Local nPoProc
Local cMsgPO1 := ""
Local cMsgPO2 := ""
Local cMsgFor := ""
Local cMsgCred:= ""
Local aSwbArea:= Saveord({"SWB"})

SWB->(dbSetorder(7))
SWB->(dbSeek(xFilial("SWB") + SWA->WA_HAWB + "101")) //WB_FILIAL, WB_HAWB, WB_EVENT, WB_PARCELA

If SWB->(!Eof())

   cQuery := " SELECT DISTINCT WA_SLDANT,WB_MOEDA,WA_PO_DI,WA_HAWB,WA_FILIAL "
   cQuery += " FROM " + RetSqlName("SWA") + " WA INNER JOIN "+ RetSqlName("SWB") + " WB ON (WA_FILIAL = WB_FILIAL AND WA_HAWB = WB_HAWB) "
   cQuery += " WHERE "

   If lAdtMultFil
      aFiliais := AvgSelectFil(.F.,"SWA")
      For nI:= 1 To Len(aFiliais)
         if nI <> 1
            cFilMulti += ","
         EndIf
         cFilMulti += "'" + aFiliais[nI] + "'"
      Next
      cQuery += "   WB_FILIAL IN (" + cFilMulti + ") "
      cQuery += "   AND WA_FILIAL IN (" + cFilMulti + ") "
   Else
      cQuery += "   WB_FILIAL = '" + xFilial("SWB") +"' "
      cQuery += "   AND WA_FILIAL = '" + xFilial("SWA") +"' "
   EndIf
   cQuery += " AND ( "
   For nI := 1 To Len(aForneProc)
         
      cQuery += " (WB_FORN = '" + aForneProc[nI][1] + "' "
      cQuery += "   AND WB_LOJA = '" + aForneProc[nI][2] + "')"
      If nI < Len(aForneProc)
         cQuery += " OR "
      EndIf
   Next
   cQuery += " ) "
   cQuery += "   AND WA_PO_DI IN ('A','F','C') " 
   cQuery += "   AND WB_CA_DT <> ' ' "
   cQuery += "   AND WB_PGTANT - "
   cQuery += "    ISNULL(( "
   cQuery += " 		SELECT SUM(WB_PGTANT) + SUM(WB_SLDELI) + SUM(WB_SLDTRF) "
   cQuery += " 		FROM " + RetSqlName("SWB") + " SWB "
   cQuery += " 		WHERE D_E_L_E_T_ <> '*' "
   cQuery += " 		  AND WB_FILORI   = WB.WB_FILIAL "
   cQuery += " 		  AND WB_CHAVE    <> ' ' "
   cQuery += " 		  AND WB_NUMPO    = WB.WB_HAWB "
   cQuery += " 		  AND WB_LINHA    = WB.WB_LINHA "
   cQuery += " 		  AND WB_FORN     = WB.WB_FORN "
   cQuery += " 		  AND WB_LOJA     = WB.WB_LOJA "
   cQuery += " 		),0) > 0 "
   cQuery += "   AND WA.D_E_L_E_T_ <> '*' "
   cQuery += "   AND WB.D_E_L_E_T_ <> '*' "
   cQuery += " ORDER BY WA_PO_DI "

   cQuery := ChangeQuery(cQuery)
   DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), cAliasAdt, .T., .T.)

   While (cAliasAdt)->(!Eof())
      Do Case

         Case (cAliasAdt)->(WA_PO_DI) == "A"  //Adiantamento de PO
            If aScan(aPOProc,{ |x| x == (cAliasAdt)->(WA_HAWB) }) > 0
               nPOProc := 1 //Primeira posição, totais de adto do tipo PO que estao vinculados ao processo
            Else
               nPOProc := 2 //Segunda posicao, totais de adto do tipo PO que não estao vinculados ao processo
            EndIf
            If (nPosMoeda := aScan(aTotPo[nPOProc],{ |x| x[1] == (cAliasAdt)->(WB_MOEDA)})) > 0
               aTotPO[nPoProc][nPosMoeda][2] += (cAliasAdt)->(WA_SLDANT)
            Else
               aAdd(aTotPO[nPOProc],{(cAliasAdt)->(WB_MOEDA),(cAliasAdt)->(WA_SLDANT)})
            EndIf         
         Case (cAliasAdt)->(WA_PO_DI) == "F" //Adiantamento de Fornecedor
            If (nPosMoeda := aScan(aTotFor,{ |x| x[1] == (cAliasAdt)->(WB_MOEDA)})) > 0
               aTotFor[nPosMoeda][2] += (cAliasAdt)->(WA_SLDANT)
            Else
               aAdd(aTotFor,{(cAliasAdt)->(WB_MOEDA),(cAliasAdt)->(WA_SLDANT)})
            EndIf  
         Case (cAliasAdt)->(WA_PO_DI) == "C" //Credito ao Fornecedor
            If (nPosMoeda := aScan(aTotCred,{ |x| x[1] == (cAliasAdt)->(WB_MOEDA)})) > 0
               aTotCred[nPosMoeda][2] += (cAliasAdt)->(WA_SLDANT)
            Else
               aAdd(aTotCred,{(cAliasAdt)->(WB_MOEDA),(cAliasAdt)->(WA_SLDANT)})
            EndIf  

      EndCase
      (cAliasAdt)->(dbSkip())
   End

   For nI := 1 To Len(aTotPO) //Monta a mensagem com valores por PO
      For nJ := 1 To Len(aTotPO[nI]) //Separa os valores de PO do processo dos valores de PO em geral
         If !Empty(aTotPO[nI][nJ][2]) .And. aScan(aMoedaProc,{ |x| x == aTotPO[nI][nJ][1] }) > 0
            If nI == 1
               cMsgPO1 += Alltrim(aTotPO[nI][nJ][1]) + " " + Alltrim(TRANS(aTotPO[nI][nJ][2], AvSX3("WB_PGTANT",6))) + ENTER
            Else
               cMsgPO2 += Alltrim(aTotPO[nI][nJ][1]) + " " + Alltrim(TRANS(aTotPO[nI][nJ][2], AvSX3("WB_PGTANT",6))) + ENTER
            EndIf
         EndIf
      Next
   Next

   For nI := 1 To Len(aTotFor) //Monta a mensagem com valores por Fornecedor
      If !Empty(aTotFor[nI][2]) .And. aScan(aMoedaProc,{ |x| x == aTotFor[nI][1] }) > 0
         cMsgFor += Alltrim(aTotFor[nI][1]) + " " + Alltrim(TRANS(aTotFor[nI][2], AvSX3("WB_PGTANT",6))) + ENTER
      EndIf
   Next

   For nI := 1 To Len(aTotCred) //Monta a mensagem com valores por Credito ao Fornecedor
      If !Empty(aTotCred[nI][2]) .And. aScan(aMoedaProc,{ |x| x == aTotCred[nI][1] }) > 0
         cMsgCred += Alltrim(aTotCred[nI][1]) + " " + Alltrim(TRANS(aTotCred[nI][2], AvSX3("WB_PGTANT",6))) + ENTER
      EndIf
   Next

   If !Empty(cMsgPO1)
      cRet += STR0416 + ENTER + cMsgPO1 + ENTER //"Adiantamentos de POs do Processo: "
   EndIf
   If !Empty(cMsgPO2)
      cRet += STR0417 + ENTER + cMsgPO2 + ENTER //"Adiantamentos de Outros POs: "
   EndIf
   If !Empty(cMsgFor)
      cRet += STR0418 + ENTER + cMsgFor + ENTER //"Adiantamentos de Fornecedor: "
   EndIf
   If !Empty(cMsgCred)
      cRet += STR0419 + ENTER + cMsgCred + ENTER //"Créditos ao Fornecedor: "
   EndIf

   (cAliasAdt)->(dbCloseArea())

EndIf

RestOrd(aSwbArea, .T.)

Return cRet

/*
Funcao      : MoedasProc()
Parâmetros  : -
Retorno     : aRet - Array com as moedas
Objetivos   : Verifica todas as moedas que são usadas pelas parcelas contidas no processo
Autor       : THTS - Tiago Henrique Tudisco dos Santos
Data 	      : 04/11/2020
*/
Static Function MoedasProc()
Local aRet := {}
Local cQuery      := ""
Local cMoedAlias  := GetNextAlias() 

cQuery := " SELECT DISTINCT WB_MOEDA "
cQuery += " FROM " + RetSqlName("SWB") + " "
cQuery += " WHERE WB_FILIAL = '" + xFilial("SWB") + "' "
cQuery += "   AND WB_HAWB   = '" + SWA->WA_HAWB   + "' "
cQuery += "   AND WB_PO_DI  = '" + SWA->WA_PO_DI  + "' "
cQuery += "   AND D_E_L_E_T_= ' ' "

cQuery := ChangeQuery(cQuery)
DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), cMoedAlias, .T., .T.)

While (cMoedAlias)->(!Eof())
   aAdd(aRet,(cMoedAlias)->(WB_MOEDA))
   (cMoedAlias)->(dbSkip())
End

(cMoedAlias)->(dbCloseArea())

Return aRet

/*
Funcao      : FornecProc()
Parâmetros  : -
Retorno     : aRet - Array com os fornecedores/loja
Objetivos   : Verifica todos os fonnecedores/loja que são usados pelas parcelas contidas no processo
Autor       : THTS - Tiago Henrique Tudisco dos Santos
Data 	      : 04/11/2020
*/
Static Function FornecProc()
Local aRet := {}
Local cQuery      := ""
Local cFornAlias  := GetNextAlias() 

cQuery := " SELECT DISTINCT WB_FORN,WB_LOJA "
cQuery += " FROM " + RetSqlName("SWB") + " "
cQuery += " WHERE WB_FILIAL = '" + xFilial("SWB") + "' "
cQuery += "   AND WB_HAWB   = '" + SWA->WA_HAWB   + "' "
cQuery += "   AND WB_PO_DI  = '" + SWA->WA_PO_DI  + "' "
cQuery += "   AND WB_EVENT  = '101' "
cQuery += "   AND D_E_L_E_T_= ' ' "

cQuery := ChangeQuery(cQuery)
DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), cFornAlias, .T., .T.)

While (cFornAlias)->(!Eof())
   aAdd(aRet,{(cFornAlias)->(WB_FORN),(cFornAlias)->(WB_LOJA)})
   (cFornAlias)->(dbSkip())
End

(cFornAlias)->(dbCloseArea())

Return aRet

/*
Funcao      : POsProc()
Parâmetros  : -
Retorno     : aRet - Array com os POs
Objetivos   : Verifica todos os POs que são usados no processo
Autor       : THTS - Tiago Henrique Tudisco dos Santos
Data 	      : 04/11/2020
*/
Static Function POsProc()
Local aRet := {}
Local cQuery      := ""
Local cPOAlias  := GetNextAlias() 

cQuery := " SELECT DISTINCT W7_PO_NUM "
cQuery += " FROM " + RetSqlName("SW7") + " "
cQuery += " WHERE W7_FILIAL = '" + xFilial("SW7") + "' "
cQuery += "   AND W7_HAWB   = '" + SWA->WA_HAWB   + "' "
cQuery += "   AND D_E_L_E_T_= ' ' "

cQuery := ChangeQuery(cQuery)
DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), cPOAlias, .T., .T.)

While (cPOAlias)->(!Eof())
   aAdd(aRet,(cPOAlias)->(W7_PO_NUM))
   (cPOAlias)->(dbSkip())
End

(cPOAlias)->(dbCloseArea())

Return aRet

/*
Funcao      : AP110CBOX()
Parâmetros  : Campo que deverá ter a lista comboBox preenchida
Retorno     : Retorna a lista Combobox do campo desejado Ex: WA_PO_DI
Objetivos   : Verificar se a parcela de câmbio possui invoice no processo
Autor       : Ramon Prado
Data        : Jul/2021
*/
Function AP110CBOX(cCampo)
Local aArea := getArea()
Local cRet  := ""

If cCampo == 'WA_PO_DI'
   If AvFlags("EIC_EAI")
      cRet := 'D=Desembaraco;A=Adiant. PO;F=Adiant. Fornec.'   
   Else      
      cRet := 'D=Desembaraco;A=Adiant. PO;F=Adiant. Fornec.;C=Credito'
   EndIf   
EndIf

RestArea(aArea)
Return cRet


Static Function TemSaldoAdt(cAlias)
Local cQuery

cQuery := " SELECT WB_NUMPO "
cQuery += " FROM " + TETEMPNAME(cAlias)
cQuery += " WHERE WA_SLDANT >  0 "
cQuery += "   AND D_E_L_E_T_= ' ' "

Return EasyQryCount(cQuery) > 0
/*
Função     : CANESTSEQ()
Parâmetros : cChave  - Chave correspondente à parcela de invoice associada ao adiantamento
             cHawb   - Numero do processo que foi criado o adiantamento 
             cInvoice- Numero da invoice do adiantamento
             cForn   - Fornecedor do adiantamento
             cLoja   - Loja do adiantamento
             cLinha  - Linha correspondente ao adiantamento associado
Retorno    : lRet    - Retorna se a ultima sequencia de baixa para a parcela de cambio é referente a parcela que esta sendo estornada
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 17/11/2020
*/
/*
Static Function CANESTSEQ(cChave, cFilOri, cHawb, cInvoice, cForn, cLoja, cLinha)

Local lRet     := .T.
Local aOrdTRB  := SaveOrd({"TRB","SWB"})
Local cAlias   := GetNextAlias()
Local cQuery   := ""
Local lAchou   := .F.

TRB->(DbSetOrder(1)) //WB_HAWB, WB_PO_DI, WB_INVOICE, WB_FORN, WB_LOJA, WB_LINHA
If TRB->(DbSeek(cChave))

   cQuery := " SELECT E5_DOCUMEN, E5_SEQ "
   cQuery += " FROM " + RetSqlName("SE5") + " "
   cQuery += " WHERE E5_FILIAL  = '" + xFilial("SWB") + "' "
   cQuery += "   AND (E5_TIPODOC = 'CP' "
   cQuery += " 	OR E5_TIPODOC = 'BA') "
   cQuery += "   AND E5_PREFIXO = '" + TRB->WB_PREFIXO + "' "
   cQuery += "   AND E5_NUMERO  = '" + TRB->WB_NUMDUP  + "' "
   cQuery += "   AND E5_PARCELA = '" + TRB->WB_PARCELA + "' "
   cQuery += "   AND E5_TIPO    = '" + TRB->WB_TIPOTIT + "' "
   cQuery += "   AND E5_CLIFOR  = '" + TRB->WB_FORN    + "' "
   cQuery += "   AND E5_LOJA    = '" + TRB->WB_LOJA    + "' "
   cQuery += "   AND E5_SITUACA <> 'C' "
   cQuery += "   AND E5_RECPAG  =  'P' "
   cQuery += "   AND E5_MOTBX   =  'CMP' "
   cQuery += "   AND E5_ORIGEM  = 'EICAP100' "
   cQuery += "   AND D_E_L_E_T_ = ' ' "
   cQuery += " ORDER BY E5_SEQ DESC "
   
   cQuery := ChangeQuery(cQuery)
   dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cAlias, .F.)

   If (cAlias)->(!Eof())
      //VERIRICAR A QUESTAO DA FILIAL DE ORIGEM
      SWB->(dbSetOrder(1)) //WB_FILIAL, WB_HAWB, WB_PO_DI, WB_INVOICE, WB_FORN, WB_LOJA, WB_LINHA
      If SWB->(dbSeek(cFilOri + cHawb + "A" + cInvoice + cForn + cLoja + cLinha))
         lAchou := .T.
      ElseIf SWB->(dbSeek(cFilOri + cHawb + "F" + cInvoice + cForn + cLoja + cLinha))
         lAchou := .T.
      ElseIf SWB->(dbSeek(cFilOri + cHawb + "C" + cInvoice + cForn + cLoja + cLinha))
         lAchou := .T.
      EndIf

      If lAchou .And. (cAlias)->(E5_DOCUMEN) != AvKey(SWB->(WB_PREFIXO + WB_NUMDUP + WB_PARCELA + WB_TIPOTIT + WB_FORN + WB_LOJA),"E5_DOCUMEN")
         lRet := .F.
      EndIf
   EndIf

EndIf

(cAlias)->(dbCloseArea())
RestOrd(aOrdTRB, .T.)

Return lRet
*/
//-------------------------------------------------------------------------------------*
//                            FIM DO PROGRAMA EICAP100.PRW
//-------------------------------------------------------------------------------------*
