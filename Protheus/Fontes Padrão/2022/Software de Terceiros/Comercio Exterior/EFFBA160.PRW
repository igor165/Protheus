#INCLUDE "EFFBA160.ch"
#INCLUDE "avprint.ch"
#INCLUDE "Average.ch"
#INCLUDE "TOPCONN.CH"

#define EV_EMBARQUE     "600"
#define EV_LIQ_PRC      "630"
#define EV_PRINC_PREPAG "700"
#define EV_JUROS_PREPAG "710"  //Parcelas de juros de pré-pagamento/securitização

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ EFFBA160³ Autor ³ Thomaz Augusto Netto   ³ Data ³21/02/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Relatório de ACE's em Aberto                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

*---------------------*
Function EFFBA160()
*---------------------*
Local nOpca := 1, lRet := .F.
Local bOk:={||(nOpca:=1, oDlg:End() )}
Local bCancel:={||(nOpca:=0, oDlg:End() )}
LOCAL nIndSx3 // - ACSJ - 24/03/2005 - Guarda o Indice Atual do SX3
LOCAL nIndEF3 // - ACSJ - 24/03/2005 - Guarda o Indice Atual do SX3
LOCAL nOrdEF3 // - ACSJ - 24/03/2005 - Guarda o Indice Atual do SX3

//HVR - Novos campos do FinImp
Private lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                     EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                     EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                     EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                     EF6->( FieldPos("EF6_SEQCNT") ) > 0 .AND. EF3->( FieldPos("EF3_ORIGEM") ) > 0 .and.;
                     EF3->( FieldPos("EF3_ROF"   ) ) > 0

//HVR PrePagamento - Securitização
Private lPrePag     := EF1->(FieldPos("EF1_CAREPR")) > 0 .and. EF1->(FieldPos("EF1_TPCAPR")) > 0 .and.;
                       EF1->(FieldPos("EF1_PARCPR")) > 0 .and. EF1->(FieldPos("EF1_PERIPR")) > 0 .and.;
                       EF1->(FieldPos("EF1_TPPEPR")) > 0 .and. EF1->(FieldPos("EF1_CAREJR")) > 0 .and.;
                       EF1->(FieldPos("EF1_TPCAJR")) > 0 .and. EF1->(FieldPos("EF1_PARCJR")) > 0 .and.;
                       EF1->(FieldPos("EF1_PERIJR")) > 0 .and. EF1->(FieldPos("EF1_TPPEJR")) > 0 .and.;
                       EF1->(FieldPos("EF1_PREPAG")) > 0 .and.;
                       EF1->(FieldPos("EF1_CLIENT")) > 0 .and. EF1->(FieldPos("EF1_CLLOJA")) > 0 .and.;
                       EF1->(FieldPos("EF1_ROF"))    > 0 .and. EF1->(FieldPos("EF1_INI_IR")) > 0 .and.;
                       EF1->(FieldPos("EF1_FIM_IR")) > 0 .and. EF1->(FieldPos("EF1_PERCIR")) > 0 .and.;
                       EF1->(FieldPos("EF1_REAJIR")) > 0 .and. EF3->(FieldPos("EF3_SLDLIQ")) > 0 .and.;
                       EF3->(FieldPos("EF3_LIQ_RS")) > 0 .and. EF3->(FieldPos("EF3_NROP")) > 0 .and.;
                       EF3->(FieldPos("EF3_EV_VIN")) > 0 .and. EF3->(FieldPos("EF3_PARVIN")) > 0 .and.;
                       EF3->(FieldPos("EF3_SLDVIN")) > 0

Private cFiltroF3Fin := "E/I"             // PLB 14/07/06 - Variavel utilizada no F3 "EFA"
Private lEvCont := .F.                   // PLB 14/07/06 - Variavel utilizada no F3 "EFA"
Private lCadFin := ChkFile("EF7") .AND. ChkFile("EF8") .AND. ChkFile("EF9") //HVR
If lCadFin
   cFilEF7 := xFilial("EF7")
EndIf
Private lTemRof := EF3->(FieldPos("EF3_ROF")) > 0 //HVR

//ALCIR ALVES -14-02-05  CASO EXISTA NOVOS CAMPOS DA CHAVE EF1,EF2 E EF3
Private lExistBCO := EF1->(FieldPos("EF1_BAN_FI")) > 0 .and. EF1->(FieldPos("EF1_PRACA")) > 0 .and.;
                     EF2->(FieldPos("EF2_BAN_FI")) > 0 .and. EF2->(FieldPos("EF2_PRACA")) > 0 .and.;
                     EF3->(FieldPos("EF3_BAN_FI")) > 0 .and. EF3->(FieldPos("EF3_PRACA")) > 0 .and.;
                     EF4->(FieldPos("EF4_BAN_FI")) > 0 .and. EF4->(FieldPos("EF4_PRACA")) > 0
 
PRIVATE bancoAtu:="-" //banco atual   
PRIVATE cTpAtu:="-" //HVR Tipo de Cambio atual   
PRIVATE cliAtu:="-" //CLIENTE ATUAL

PRIVATE acliTot:={} //Totais por cliente
PRIVATE abncTotVL:={} //Totais valor vinculado por banco
PRIVATE abncTotIN:={} //Totais valor da invoice por banco

//HVR
PRIVATE aTpTotVL:={} //HVR Totais valor vinculado por tipo de cambio
PRIVATE aTpTotIN:={} //HVR Totais valor da invoice por tipo de cambio

PRIVATE abncTVL_F:={} //Totais valor vinculado por banco filial
PRIVATE abncTIN_F :={} //Totais valor da invoice por banco filial

PRIVATE afilTot:={} //Totais por filial


Private cBanco:= SPACE(AVSX3("EF1_BAN_FI",03)), cMoeda:= SPACE(AVSX3("EF1_MOEDA",03))
Private aHeader[0],aCampos:={}, cNomArq,IsEF1C:=.f.
Private cPictTx:= AVSX3("EF2_TX_FIX", 06), cPictData:= AVSX3("EF2_DT_INI", 06)
Private cPictBan:= AVSX3("EF1_BAN_FI", 06), cPictMoe:= AVSX3("EF1_MOEDA", 06)
Private cPictVl:= AVSX3("EF1_SLD_PM", 06), cPictDesc:= AVSX3("A6_NOME", 06)
Private cPictDesM:= AVSX3("YF_DESC_SI", 06)
Private lFilOri := SX3->( dbSeek("EF1_FILORI") )                                 //AAF - 03/01/05 - Indica se existe o campo com filial de origem.
Private lVerOut := Posicione("SX2",1,"EF1","X2_MODO") == "E" .AND. VerSenha(115) //AAF - 03/01/05 - Indica se o usuário pode ver outras filiais.

Private cFiliais := "'"
Private aFiliais := AvgSelectFil(.T.,"EF1")
//Private aFiliais := AvgSelectFil(.T.,"SWB")
aEval(aFiliais,{|x,y| cFiliais += x + iIF(y == Len(aFiliais),"'","','")})

Private cMarca := GetMark(), lInverte := .F., oFont
Private aRCampos:={}, aDados:= {}, cFilSA6:= xFilial("SA6")
Private cFilEF1:= xFilial("EF1"), cFilEF2:= xFilial("EF2")
Private nTotVlMoe:= nTotVlMVin:= nTotVlMPAG := 0, aTotMoe:= {}
Private cFilSYF:= xFilial("SYF"), aTotBan:= {}, TB_Campos:= {}
Private aTotFil := {} //AAF 03/01/05 - Total por Filial.      
Private nQuebraS:=0, nQue:=0 //HVR
Private aDescCpo:= {}
// ACSJ - 24/03/2005 - Verifica a existencia do campo EF1_ROF no SX3
nIndSx3 := SX3->(IndexOrd())
SX3->(DBSetOrder(2))
SX3->(DBSetOrder(nIndSX3))
// ACSJ -------------------- FIM

//Alcir Alves - 07-01-05
IF LEN(aFiliais)==1 .AND. ALLTRIM(aFiliais[1])="" 
    IsEF1C:=.t.
ENDIF

//ASK 13/02/07 14:11 - Incluso no AtuSx do P9R1
//EFFBADIC()  //Cria SX1
  
dbSelectArea("EF1")
If Pergunte("EFFBA1",.T.)
   //cBanco  := mv_par12
   cMoeda  := mv_par12
      
   // ACSJ - 24/03/2004 --- INCIO
   if lTemRof    
      cRof   := mv_par13
      cBanco := mv_par14
      cTipo  := mv_par15
      nDest  := mv_par16
   else
      cBanco := mv_par13
      cTipo  := mv_par14
      nDest  := mv_par15
   Endif               
      
   If ValType(cTipo) == "C" //ASK 22/10/2007 - Trocada a variável cTipo para nTipo para não dar erro de tipo de variavel
      nTipo := Val(cTipo)
   Else
      nTipo := cTipo   
   EndIf      
   
   EFFBACriaWork()
   IF nDest==1
      MsAguarde({|| lRet := EFFBAGeraDados()}, STR0001) //"Aguarde... Lendo Dados do Arquivo..."
   ELSE
      MsAguarde({|| EFFBAGravaWork() },STR0002) 
      WORK_EXPORT(IIF(nDest==2,.F.,.T.))                
   ENDIF
    //
ENDIF

If Select("Work") > 0
   WORK->(E_EraseArq(cNomArq))
EndIf

Return .T.

*------------------------------*
STATIC FUNCTION EFFBAGeraDados()
*------------------------------*
Local oDlg, nOpc

MsAguarde({|| EFFBAGravaWork() },STR0002) //"Atualizando Arquivos..."

aDados :={"WORK",;
           STR0003,; //"Este Relatorio irá imprimir todos "
           STR0004,; //"os ACE's em Aberto "
           "",;
           "G",;
           220,;
           "",;
           "",;
           (STR0018+" - "+IIF(nTipo==1,STR0040,STR0039)),; //"Relatório - ACE's em Aberto"
           {STR0006, 1, STR0007 , 2, 2, 1, "",1 },; //"ZEBRADO"###"IMPORTAÇÃO"
           "EFFBA160",;
           { {|| EFFBAGrvTotal() } , { || EFFBAGrvTotal("GERAL") }  }  } 

AADD(TB_Campos,{{ ||If(Empty(Work->FLAG),Work->CONTRA,)  }  , "", STR0033 } ) //"CONTRATO"
If lEFFTpMod
   AADD(TB_Campos,{{ ||If(Empty(Work->FLAG),Work->EF1_SEQCNT,)  }  , "", STR0048 } ) //HVR "SEQ." SEQUENCIA DO CONTRATO
EndIf
AADD(TB_Campos,{{ ||If(Empty(Work->FLAG), Work->TPFIN,)  }  , "", STR0036 } ) //Tipo de contrato
IF lExistBCO
   AADD(TB_Campos,{{ ||If(Empty(Work->FLAG),Work->PRACA,)  }  , "", STR0035 } ) //PRACA
ENDIF
AADD(TB_Campos,{{ ||If(Empty(Work->FLAG),Work->DT_VENC,)  }  , "", STR0034 } ) //DT DO VENCIMENTO
IF nTipo==1 // Detalhamento por taxas 
   AADD(TB_Campos,{{ ||If(Empty(Work->FLAG), Transf(Work->MOEDA, cPictMoe),)  }  , "", STR0010 } ) //"Moeda"
   AADD(TB_Campos,{{ ||If(Empty(Work->FLAG), Transf(Work->DES_MOE, cPictDesM),)  }  , "", STR0011 } ) //"Descrição Moeda"
   AADD(TB_Campos,{{ || Work->TIPO   }  , "", STR0046 } ) //"Tipo" //Alcir Alves - 20-05-05
   AADD(TB_Campos,{{ ||Transf(Work->TAXA,  cPictTx)   }  , "", STR0012 } ) //"Taxa de Juros"
   AADD(TB_Campos,{{ ||Transf(Work->DTINI, cPictData) }  , "", STR0013 } ) //"Data Inicial"
   AADD(TB_Campos,{{ ||Transf(Work->DTFIM, cPictData) }  , "", STR0014 } ) //"Data Final"
   AADD(TB_Campos,{{ ||If(Empty(Work->FLAG),Transf(Work->VALOR, cPictVl),) }  , "", STR0015 } ) //"Valor"
   AADD(TB_Campos,{{ ||If(Empty(Work->FLAG),Transf(Work->VLVINC,cPictVl),) }  , "", STR0016 } ) //"Valor a Vincular"
   AADD(TB_Campos,{{ ||If(Empty(Work->FLAG),Transf(Work->VLAPAG,cPictVl),) }  , "", STR0017 } ) //"Valor a Pagar"
ELSE
   AADD(TB_Campos,{{ ||If(Empty(Work->FLAG), Work->PREEMB,)  }  , "", STR0029 } ) //PROCESSO
   AADD(TB_Campos,{{ ||If(Empty(Work->FLAG), Work->INVOIC,)  }  , "", STR0030 } ) //INVOICE
   AADD(TB_Campos,{{ ||If(Empty(Work->FLAG), Work->EF3_PARC,)  }  , "", STR0049 } ) //HVR PARCELA
   AADD(TB_Campos,{{ ||If(Empty(Work->FLAG), Transf(Work->MOEDA, cPictMoe),)  }  , "", STR0010 } ) //"Moeda"
   AADD(TB_Campos,{{ ||If(Empty(Work->FLAG), Transf(Work->DES_MOE, cPictDesM),)  }  , "", STR0011 } ) //"Descrição Moeda"
   AADD(TB_Campos,{{ ||If(Empty(Work->FLAG),Transf(Work->VLMOE,cPictVl),)  }  , "", STR0041 } ) //VALOR NA MOEDA
   AADD(TB_Campos,{{ ||If(Empty(Work->FLAG), Work->INVMOE,)  }  , "", STR0053 } ) //MOEDA DA INVOICE
   AADD(TB_Campos,{{ ||If(Empty(Work->FLAG), Transf(Work->INVVL,cPictVl),)  }  , "", STR0043 } ) //INVOICE VALOR
   If lEFFTpMod  // PLB 14/07/06
      AADD(TB_Campos,{{ ||If(Empty(Work->FLAG), Work->TPVINC,)  }  , "", STR0055 } ) //INVOICE VALOR  //"Tp. Vinc."
   EndIf
ENDIF

If lTemRof
   AADD(TB_Campos,{{ ||If(Empty(Work->FLAG), Work->ROF,)  }  , "", STR0037 } ) //ROF
Endif

aRCampos:= E_CriaRCampos(TB_Campos,"C")
EFFGERAREL(aDados,aRCampos)

WORK->(E_EraseArq(cNomArq))

Return .T.

*------------------------------*
Static Function EFFBACriaWork()
*------------------------------*
aEstru := {}
AADD(aEstru,{ "FILIAL" , AVSX3("EF1_FILIAL", 02), AVSX3("EF1_FILIAL", 03), AVSX3("EF1_FILIAL", 04)})
AADD(aDescCpo,{AVSX3("EF1_FILIAL", 5)})
//Alcir Alves - 16-02-05
AADD(aEstru,{ "CONTRA"     , AVSX3("EF1_CONTRA", 02), AVSX3("EF1_CONTRA", 03), AVSX3("EF1_CONTRA", 04)}) //CONTRATO
AADD(aDescCpo,{AVSX3("EF1_CONTRA", 5)}) //CONTRATO
IF lEFFTpMod
   AADD(aEstru,{ "EF1_TPMODU" , AVSX3("EF1_TPMODU", 02), AVSX3("EF1_TPMODU", 03), AVSX3("EF1_TPMODU", 04)}) //HVR TPMODU
   AADD(aDescCpo,{AVSX3("EF1_TPMODU", 5)}) //HVR TPMODU
   AADD(aEstru,{ "EF3_ORIGEM" , AVSX3("EF3_ORIGEM", 02), AVSX3("EF3_ORIGEM", 03), AVSX3("EF3_ORIGEM", 04)}) //HVR ORIGEM
   AADD(aDescCpo,{AVSX3("EF3_ORIGEM", 5)}) //HVR ORIGEM
   AADD(aEstru,{ "EF1_SEQCNT" , AVSX3("EF1_SEQCNT", 02), AVSX3("EF1_SEQCNT", 03), AVSX3("EF1_SEQCNT", 04)}) //HVR SEQUENCIA DO CONTRATO
   AADD(aDescCpo,{AVSX3("EF1_SEQCNT", 5)}) //HVR SEQUENCIA DO CONTRATO
ENDIF
IF lExistBCO
    AADD(aEstru,{"PRACA"   , AVSX3("EF1_PRACA", 02), AVSX3("EF1_PRACA", 03), AVSX3("EF1_PRACA", 04)}) //CONTRATO
    AADD(aDescCpo,{AVSX3("EF1_PRACA", 5)}) //CONTRATO
ENDIF
AADD(aEstru,{ "PREEMB" , AVSX3("EF3_PREEMB", 02), AVSX3("EF3_PREEMB", 03), AVSX3("EF3_PREEMB", 04)}) //PROCESSO
AADD(aDescCpo,{AVSX3("EF3_PREEMB", 5)}) //PROCESSO
Aadd(aEstru,{"DT_VENC" ,AVSX3("EF1_DT_VEN",2),AVSX3("EF1_DT_VEN",3),AVSX3("EF1_DT_VEN",4)}) //DATA DO VENCIMENTO
Aadd(aDescCpo,{AVSX3("EF1_DT_VEN",5)}) //DATA DO VENCIMENTO
Aadd(aEstru,{"CLIENTE" ,AVSX3("EEQ_IMPORT",2),AVSX3("EEQ_IMPORT",3),AVSX3("EEQ_IMPORT",4)}) //CLIENTE DO PROCESSO
Aadd(aDescCpo,{AVSX3("EEQ_IMPORT",5)}) //CLIENTE DO PROCESSO
IF lEFFTpMod
   Aadd(aEstru,{"EF1_FORN" ,AVSX3("EF1_FORN",2),AVSX3("EF1_FORN",3),AVSX3("EF1_FORN",4)}) //CLIENTE DO PROCESSO
   Aadd(aDescCpo,{AVSX3("EF1_FORN",5)}) //CLIENTE DO PROCESSO
ENDIF
Aadd(aEstru,{"DES_CLI" ,AVSX3("A1_NREDUZ",2),AVSX3("A1_NREDUZ",3),AVSX3("A1_NREDUZ",4)}) //DESCRICAO DO CLIENTE
Aadd(aDescCpo,{AVSX3("A1_NREDUZ",5)}) //DESCRICAO DO CLIENTE
Aadd(aEstru,{"INVOIC"  ,AVSX3("EF3_INVOIC",2),AVSX3("EF3_INVOIC",3),AVSX3("EF3_INVOIC",4)}) //INVOICE
Aadd(aDescCpo,{AVSX3("EF3_INVOIC",5)}) //INVOICE

IF lEFFTpMod
   Aadd(aEstru,{"EF3_PARC",AVSX3("EF3_LINHA" ,2),AVSX3("EF3_LINHA" ,3),AVSX3("EF3_LINHA" ,4)}) //HVR PARCELA LINHA
   Aadd(aDescCpo,{AVSX3("EF3_LINHA" ,5)}) //HVR PARCELA LINHA
ELSE
   Aadd(aEstru,{"EF3_PARC",AVSX3("EF3_PARC"  ,2),AVSX3("EF3_PARC"  ,3),AVSX3("EF3_PARC"  ,4)}) //HVR PARCELA LINHA
   Aadd(aDescCpo,{AVSX3("EF3_PARC"  ,5)}) //HVR PARCELA LINHA
ENDIF

Aadd(aEstru,{"LOJA"    ,AVSX3("EEQ_IMLOJA",2),AVSX3("EEQ_IMLOJA",3),AVSX3("EEQ_IMLOJA",4)}) //LOJA DO PROCESSO
Aadd(aDescCpo,{AVSX3("EEQ_IMLOJA",5)}) //LOJA DO PROCESSO
//
AADD(aEstru,{ "MOEDA"  , AVSX3("EF1_MOEDA", 02), AVSX3("EF1_MOEDA", 03), AVSX3("EF1_MOEDA", 04)})
AADD(aDescCpo,{AVSX3("EF1_MOEDA", 5)})
AADD(aEstru,{ "DES_MOE", AVSX3("YF_DESC_SI", 02), AVSX3("YF_DESC_SI", 03), AVSX3("YF_DESC_SI", 04)})
AADD(aDescCpo,{AVSX3("YF_DESC_SI", 5)})
AADD(aEstru,{ "BANCO"  , AVSX3("EF1_BAN_FI", 02), AVSX3("EF1_BAN_FI", 03), AVSX3("EF1_BAN_FI", 04)})
AADD(aDescCpo,{AVSX3("EF1_BAN_FI", 5)})
AADD(aEstru,{ "DES_BAN", AVSX3("A6_NOME", 02), AVSX3("A6_NOME", 03), AVSX3("A6_NOME", 04)})
AADD(aDescCpo,{AVSX3("A6_NOME", 5)})
AADD(aEstru,{ "TAXA"   , AVSX3("EF2_TX_FIX", 02), AVSX3("EF2_TX_FIX", 03), AVSX3("EF2_TX_FIX", 04)})
AADD(aDescCpo,{AVSX3("EF2_TX_FIX", 5)})
AADD(aEstru,{ "DTINI"  , AVSX3("EF2_DT_INI", 02), AVSX3("EF2_DT_INI", 03), AVSX3("EF2_DT_INI", 04)})
AADD(aDescCpo,{AVSX3("EF2_DT_INI", 5)})
AADD(aEstru,{ "DTFIM"  , AVSX3("EF2_DT_FIM", 02), AVSX3("EF2_DT_FIM", 03), AVSX3("EF2_DT_FIM", 04)})
AADD(aDescCpo,{AVSX3("EF2_DT_FIM", 5)})
AADD(aEstru,{ "VALOR"  , AVSX3("EF1_SLD_PM", 02), AVSX3("EF1_SLD_PM", 03), AVSX3("EF1_SLD_PM", 04)})
AADD(aDescCpo,{AVSX3("EF1_SLD_PM", 5)})
AADD(aEstru,{ "VLVINC" , AVSX3("EF1_SLD_PM", 02), AVSX3("EF1_SLD_PM", 03), AVSX3("EF1_SLD_PM", 04)})
AADD(aDescCpo,{AVSX3("EF1_SLD_PM", 5)})
AADD(aEstru,{ "VLAPAG" , AVSX3("EF1_SLD_PM", 02), AVSX3("EF1_SLD_PM", 03), AVSX3("EF1_SLD_PM", 04)})
AADD(aDescCpo,{AVSX3("EF1_SLD_PM", 5)})
AADD(aEstru,{ "TPFIN"  , "C", 15,0})
AADD(aDescCpo,{ AVSX3("EF1_TP_FIN",5)})
AADD(aEstru,{ "TIPO", "C",15,0})   //Alcir Alves - 20/05/05
AADD(aDescCpo,{ AVSX3("EF2_TP_FIN",5)})   //Alcir Alves - 20/05/05
AADD(aEstru,{ "VLMOE"  ,AVSX3("EF3_VL_MOE", 02),AVSX3("EF3_VL_MOE", 03),AVSX3("EF3_VL_MOE", 04)})
AADD(aDescCpo,{AVSX3("EF3_VL_MOE", 5)})
AADD(aEstru,{ "INVMOE" ,AVSX3("EF3_MOE_IN", 02),AVSX3("EF3_MOE_IN", 03),AVSX3("EF3_MOE_IN", 04)})
AADD(aDescCpo,{AVSX3("EF3_MOE_IN", 5)})
AADD(aEstru,{ "INVVL"  ,AVSX3("EF3_VL_INV", 02),AVSX3("EF3_VL_INV", 03),AVSX3("EF3_VL_INV", 04)})
AADD(aDescCpo,{AVSX3("EF3_VL_INV", 5)})

If lEFFTpMod // PLB 14/07/06
   AADD(aEstru,{ "TPVINC" , "C" , 9 , 0 } )
   AADD(aDescCpo,{ AVSX3("EF3_EV_VIN",5)} )
EndIf

// ACSJ - 24/03/2005 - Verificação do campo EF1_ROF - Inicio
If lTemRof
   AADD(aEstru,{ "ROF" , AVSX3("EF3_ROF", 02), AVSX3("EF3_ROF", 03), AVSX3("EF3_ROF", 04)}) //HVR ROF EF1 PARA EF3
   AADD(aDescCpo,{ AVSX3("EF3_ROF", 5)}) //HVR ROF EF1 PARA EF3
Endif
// -------------------------------------------- Fim

If EasyEntryPoint("EFFBA160")
    ExecBlock("EFFBA160", .F., .F.,"ADD_WORK_STRU")
EndIf

AADD(aEstru,{ "FLAG"   , "C", 1, 0 })
AADD(aDescCpo,{ "Flag"})

If Select("Work") > 0
   Work->( DBCloseArea() )       
EndIf
cNomArq:=E_CriaTrab(,aEstru,"Work")
IF lEFFTpMod //THTS - 25/09/2017 - TE-6431 - Temporario no Banco de Dados
   IndRegua("Work",cNomArq+TEOrdBagExt(),"EF1_TPMODU+FILIAL+BANCO+CLIENTE+MOEDA") //HVR TPMODU
ELSE
   IndRegua("Work",cNomArq+TEOrdBagExt(),"FILIAL+BANCO+MOEDA") //HVR
ENDIF
Return .T.

*-------------------------------*
Static Function EFFBAGravaWork()
*-------------------------------*
Local lPVez:= .F.
Local nFil //AAF 03/01/05 - Multifiliais
Local cFilSoma := ""                                                                     
//ASK 05/11/2007
Local lMultiFil  := VerSenha(115) .and. Posicione("SX2",1,"EF1","X2_MODO") == "C" .and.; 
              Posicione("SX2",1,"EEQ","X2_MODO") == "E" .AND. SX3->(DbSeek("EF3_FILORI"))


WORK->(avzap())

EF1->(DBSETORDER(1))
EF3->(DBSETORDER(1))
EEQ->(DBSETORDER(1))
EEC->(DBSETORDER(1))
EF2->(DBSETORDER(1))
SA6->(DBSETORDER(1))
SYF->(DBSETORDER(1))

For nFil := 1 To Len(aFiliais)
   cFilSoma := aFiliais[nFil]  // PLB 13/07/06 - Utilizada em EFFBAEvSoma()
   EF1->(dbseek(aFiliais[nFil]))
   Do While EF1->(!EOF()) .And. EF1->EF1_FILIAL==aFiliais[nFil]
      nTotVlMoe  := 0
      nTotVlMVin := 0
      nTotVlMPAG := 0

      If !Empty(EF1->EF1_DT_ENC) 
         EF1->(DbSkip())
         Loop
      Endif

      If !Empty(cBanco)
         If cBanco <> EF1->EF1_BAN_FI
            EF1->(DbSkip())
   	      Loop
         Endif
      Endif

      If !Empty(cMoeda)
         If cMoeda <> EF1->EF1_MOEDA
            EF1->(DbSkip())
		      Loop
         Endif
      Endif
          
      //HVR FILTRO TIPO DE CAMBIO
      If lEFFTpMod
         If IIF(lTemRof,mv_par17,mv_par16) == 1 .And. EF1->EF1_TPMODU # "I"
            EF1->(DbSkip())
            Loop
         ElseIf IIF(lTemRof,mv_par17,mv_par16) == 2 .And. EF1->EF1_TPMODU # "E"
            EF1->(DbSkip())
            Loop
         EndIf
      EndIf
      //HVR
      IF !EMPTY(mv_par01) .AND. EF1->EF1_CONTRA#mv_par01  //CONTRATO
         EF1->(DbSkip())
         Loop
      ENDIF
      //HVR FILTRO SEQUENCIA DO CONTRATO
      IF lEFFTpMod
         IF !Empty(IIF(lTemRof, mv_par19,mv_par18)) .AND. EF1->EF1_SEQCNT # IIF(lTemRof, mv_par19,mv_par18)  //SEQ CONTRATO
            EF1->(DbSkip())
            Loop
         ENDIF
      ENDIF
      //HVR***
      IF !EMPTY(mv_par02) .AND. EF1->EF1_DT_CON<mv_par02  //DATA INICIAL
         EF1->(DbSkip())
         Loop
      ENDIF
      IF !EMPTY(mv_par03) .AND. EF1->EF1_DT_CON>mv_par03 //DATA FINAL
         EF1->(DbSkip())
         Loop
      ENDIF
      IF !EMPTY(mv_par04) .AND. EF1->EF1_TP_FIN#mv_par04 //TIPO DE FINANCIAMENTO
         EF1->(DbSkip())
         Loop
      ENDIF
      IF !EMPTY(mv_par06) .AND. EF1->EF1_EXPORT#mv_par06 //EXPORTADOR
         EF1->(DbSkip())
         Loop
      ENDIF
      IF !EMPTY(mv_par07) .AND. EF1->EF1_LOJA#mv_par07 //LOJA EXPORTADOR
         EF1->(DbSkip())
         Loop
      ENDIF                                                   
      // ACSJ - 24/03/2005 - Verificação do campo EF1_ROF
      If lTemRof .AND. EF3->(DbSeek(aFiliais[nFil]+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")) ) //HVR TPMODU
         IF !EMPTY(cRof) .AND. EF3->EF3_ROF#cRof //ROF
            EF1->(DbSkip())
            Loop
         ENDIF
      Endif
      IF nTipo==1 // Detalhamento por taxas  - ALCIR ALVES - 17-02-05
         cWhile:={|| .t.}

         IF lExistBCO
            EF2->(DbSeek(aFiliais[nFil]+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")) ) //HVR TPMODU E SEQCNT
            cWhile:={|| EF2->EF2_BAN_FI==EF1->EF1_BAN_FI  .and. EF2->EF2_PRACA==EF1->EF1_PRACA .And. IF(lEFFTpMod,EF2->EF2_SEQCNT==EF1->EF1_SEQCNT,.T.) } //HVR SEQCNT
         ELSE
            EF2->(DbSeek(aFiliais[nFil]+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA))      //HVR TPMODU
         ENDIF
         //
         SA6->(DbSeek(cFilSA6+EF1->EF1_BAN_FI))
         SYF->(DbSeek(cFilSYF+EF1->EF1_MOEDA))
         lPVez:= .T.
         IF !EF2->(EOF()) .And. EF2->EF2_FILIAL == aFiliais[nFil] .AND. EF2->EF2_CONTRA == EF1->EF1_CONTRA .AND. IF(lEFFTpMod,EF2->EF2_TPMODU == EF1->EF1_TPMODU,.T.) .and. eval(cWhile) //HVR TPMODU
            If IIF(!lEFFTpMod .Or. EF1->EF1_CAMTRA=="2",EF1->EF1_SLD_PM<>0 .or. EF1->EF1_SL2_PM<>0,IIF(EF1->EF1_TPMODU=="E",EF1->EF1_SLD_PM>0,Empty(EF1->EF1_DT_JUR)))  // PLB 13/07/06
            //if EF1->EF1_SLD_PM<>0 .or. EF1->EF1_SL2_PM<>0 //Alcir Alves -20-05-05
               IF lEFFTpMod
                  nPosic:= aScan(aTotMoe,{|x| x[1]==EF1->EF1_TPMODU .And. x[2]==EF1->EF1_MOEDA })
               ELSE
                  nPosic:= aScan(aTotMoe,{|x| x[1]==EF1->EF1_MOEDA })
               ENDIF
               If nPosic = 0
                  nTotVlMoe := EF1->EF1_VL_MOE
                  If !lEFFTpMod .Or. EF1->EF1_CAMTRA=="2"
                     nTotVlMVin := EF1->EF1_SLD_PM
                     nTotVlMPAG := EF1->EF1_SL2_PM
                  Else
                     nTotVlMVin := EF1->EF1_VL_MOE - EFFBAEvSoma(cFilSoma,EV_EMBARQUE)
                     nTotVlMPAG := EFFBAEvSoma(cFilSoma,EV_EMBARQUE) - EFFBAEvSoma(cFilSoma,EV_LIQ_PRC)
                  EndIf
               Else
                  nTotVlMoe += EF1->EF1_VL_MOE
                  If !lEFFTpMod .Or. EF1->EF1_CAMTRA=="2"
                     nTotVlMVin += EF1->EF1_SLD_PM
                     nTotVlMPAG += EF1->EF1_SL2_PM
                  Else
                     nTotVlMVin += EF1->EF1_VL_MOE - EFFBAEvSoma(cFilSoma,EV_EMBARQUE)
                     nTotVlMPAG += EFFBAEvSoma(cFilSoma,EV_EMBARQUE) - EFFBAEvSoma(cFilSoma,EV_LIQ_PRC)
                  EndIf
               ENDIF
            Endif
         ENDIF   
         //If EF1->EF1_SLD_PM<>0 .or. EF1->EF1_SL2_PM<>0 //Alcir Alves -20-05-05
         If IIF(!lEFFTpMod .Or. EF1->EF1_CAMTRA=="2",EF1->EF1_SLD_PM<>0 .or. EF1->EF1_SL2_PM<>0,IIF(EF1->EF1_TPMODU=="E",EF1->EF1_SLD_PM>0,Empty(EF1->EF1_DT_JUR)))  // PLB 13/07/06
            Do While !EF2->(EOF()) .And. EF2->EF2_FILIAL == aFiliais[nFil] .AND. EF2->EF2_CONTRA == EF1->EF1_CONTRA .AND. IF(lEFFTpMod,EF2->EF2_TPMODU == EF1->EF1_TPMODU,.T.) .and. eval(cWhile) //HVR TPMODU
               Work->(DbAppend())
                  //Alcir Alves - 16-02-05
               Work->CONTRA := EF1->EF1_CONTRA
            
               //HVR
               IF lEFFTpMod
                  Work->EF1_SEQCNT := EF1->EF1_SEQCNT
               ENDIF
               //HVR***
               Work->DT_VENC:= EF1->EF1_DT_VEN
               Work->FILIAL := aFiliais[nFil]
               Work->BANCO  := EF1->EF1_BAN_FI
               Work->DES_BAN:= SA6->A6_NOME
               if lTemRof .AND. EF3->(DbSeek(aFiliais[nFil]+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")) ) //HVR TPMODU // - ACSJ - 24/03/2005 - Verificação do campo EF1_ROF
                  Work->ROF:=EF3->EF3_ROF                                         
               Endif            
               IF lExistBCO
                  Work->PRACA:=EF1->EF1_PRACA
               ENDIF
               IF lEFFTpMod   
                  WORK->EF1_TPMODU := EF1->EF1_TPMODU //HVR
                  WORK->EF3_ORIGEM := EF3->EF3_ORIGEM //HVR
               ENDIF
               Work->MOEDA  := EF1->EF1_MOEDA
               Work->DES_MOE:= SYF->YF_DESC_SI
               Work->TAXA   := EF2->EF2_TX_FIX
               Work->DTINI  := EF2->EF2_DT_INI
               Work->DTFIM  := EF2->EF2_DT_FIM
             
               //** PLB 07/07/06
               If lCadFin
                  Work->TIPO := Posicione("EF7",1,cFilEF7+EF2->EF2_TP_FIN,"EF7_DESCRI")
               Else
                  Work->TIPO := Tabela("CG",EF2->EF2_TP_FIN,.F.)
               EndIf
               //**
               //Work->TIPO  := Tabela("CG",EF1->EF1_TP_FIN,.F.)//IIF(EF2->EF2_TP_FIN="01","ACC","ACE")     //Alcir Alves -20-05-05
            
               If lPVez
                  Work->FLAG   := " "
                  Work->VALOR  :=EF1->EF1_VL_MOE //Alcir Alves -20-05-05 //(EF1->EF1_SLD_PM + EF1->EF1_SL2_PM)
                  //IF !lEFFTpMod .Or. WORK->EF1_TPMODU <> "I" //HVR
                  //** PLB 13/07/06 - Adequacao ao FINIMP
                  If !lEFFTpMod .Or. EF1->EF1_CAMTRA=="2"
                     Work->VLVINC := EF1->EF1_SLD_PM
                  	Work->VLAPAG := EF1->EF1_SL2_PM
                  Else
                     Work->VLVINC := EF1->EF1_VL_MOE - EFFBAEvSoma(cFilSoma,EV_EMBARQUE)
                  	Work->VLAPAG := EFFBAEvSoma(cFilSoma,EV_EMBARQUE) - EFFBAEvSoma(cFilSoma,EV_LIQ_PRC)
                  EndIf
                  //**
                  If lCadFin
                     Work->TPFIN := Posicione("EF7",1,cFilEF7+EF1->EF1_TP_FIN,"EF7_DESCRI")
                  Else
                     Work->TPFIN :=Tabela("CG",EF1->EF1_TP_FIN,.F.)//IIF(EF1->EF1_TP_FIN="01","ACC","ACE")     //Alcir Alves -23-05-05
                  EndIf
               Else
                  Work->VALOR  := 0
                  Work->VLVINC := 0
                  Work->VLAPAG := 0
                  Work->FLAG   := "S"
               Endif     
               //HVR TOTAL A PAGAR -> EVENTOS 700 SEM TAXA
               /*IF lEFFTpMod .AND. WORK->EF1_TPMODU = "I"   
                  IF lEFFTpMod
                     EF3->(DbSeek(aFiliais[nFil]+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")) )
                     cWhile:={|| EF3->EF3_BAN_FI==EF1->EF1_BAN_FI  .and. EF3->EF3_PRACA==EF1->EF1_PRACA .and. IF(lEFFTpMod, EF3->EF3_SEQCNT==EF1->EF1_SEQCNT, .T.) } 
                  ELSE
                  	EF3->(DbSeek(aFiliais[nFil]+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA))  //HVR
	               ENDIF
                  lPVez:= .T.
                  Work->VLAPAG := 0
                  aTotPagar:={} //array com os agrupamentos dos processos e clientes que fazem parte de um determinado contrato
                  Do While !EF3->(EOF()) .And. EF3->EF3_FILIAL == aFiliais[nFil] .AND. IF(lEFFTpMod, EF3->EF3_TPMODU == EF1->EF1_TPMODU,.T.) .AND. EF3->EF3_CONTRA == EF1->EF1_CONTRA .and. eval(cWhile) //HVR
   	               IF EF3->EF3_CODEVE <> "700"
                        EF3->(DbSkip())
                        Loop
                     ENDIF
      	            IF !Empty(EF3->EF3_TX_MOE)
         	            EF3->(DbSkip())
         	            Loop
            	      ENDIF
                     Work->VLAPAG += EF3->EF3_VL_MOE
                     EF3->(DbSkip())                
                     Loop
                  Enddo 
               ENDIF	*/
//HVR***            
               lPvez:= .F.
               If EasyEntryPoint("EFFBA160")
                  ExecBlock("EFFBA160", .F., .F.,"GRAVA_WORK_SINTETICO")
               EndIf
               Work->(dbCommit())
               EF2->(DbSkip())
            EndDo
         endif
      ELSE //detalhamento por invoice - analitico - ALCIR ALVES - 17-02-05
         cWhile:={|| .t.}
         IF lExistBCO
            EF3->(DbSeek(aFiliais[nFil]+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")) ) //HVR TPMODU
            cWhile:={|| EF3->EF3_BAN_FI==EF1->EF1_BAN_FI  .and. EF3->EF3_PRACA==EF1->EF1_PRACA .and. IF(lEFFTpMod, EF3->EF3_SEQCNT==EF1->EF1_SEQCNT, .T.) } //HVR SEQCNT
         ELSE
            EF3->(DbSeek(aFiliais[nFil]+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA))  //HVR
         ENDIF
         SA6->(DbSeek(cFilSA6+EF1->EF1_BAN_FI))
         SYF->(DbSeek(cFilSYF+EF1->EF1_MOEDA))
         lPVez:= .T.
         aCliente:={} //array com os agrupamentos dos processos e clientes que fazem parte de um determinado contrato
         Do While !EF3->(EOF()) .And. EF3->EF3_FILIAL == aFiliais[nFil] .AND. IF(lEFFTpMod, EF3->EF3_TPMODU == EF1->EF1_TPMODU,.T.) .AND. EF3->EF3_CONTRA == EF1->EF1_CONTRA .and. eval(cWhile) //HVR
          	nIndEF3:=EF3->(RecNo()) //HVR  
          	nOrdEF3:=EF3->(Indexord())          	                          
 	      //IF EF3->EF3_CODEVE <> "600" .OR. IF(lEFFTpMod, IF(EF3->EF3_ORIGEM="SWB", EF3->(DbSetOrder(7),DBSEEK(EF3->EF3_FILIAL+IF(lEFFTpMod, EF3->EF3_TPMODU,"")+EF3->EF3_HAWB+EF3->EF3_FORN+EF3->EF3_LOJAFO+EF3->EF3_INVIMP+EF3->EF3_LINHA+"630") ), EF3->(DbSetOrder(3),DBSEEK(EF3->EF3_FILIAL+IF(lEFFTpMod, EF3->EF3_TPMODU,"")+EF3->EF3_INVOIC+EF3->EF3_PARC+"630") )),.F.)//HVR
   	        IF EF3->EF3_CODEVE <> "600" .OR. IF(lEFFTpMod .AND. EF3->EF3_ORIGEM="SWB", EF3->(DbSetOrder(7),DBSEEK(EF3->EF3_FILIAL+IF(lEFFTpMod, EF3->EF3_TPMODU,"")+EF3->EF3_HAWB+EF3->EF3_FORN+EF3->EF3_LOJAFO+EF3->EF3_INVIMP+EF3->EF3_LINHA+"630") ), EF3->(DbSetOrder(3),DBSEEK(EF3->EF3_FILIAL+IF(lEFFTpMod, EF3->EF3_TPMODU,"")+EF3->EF3_INVOIC+EF3->EF3_PARC+"630") ))//ASK 05/11/2007
               EF3->(DBSetOrder(nOrdEF3)) //HVR
               EF3->(DBGOTO(nIndEF3))
               EF3->(DbSkip())
        	   Loop
           	ENDIF
           	EF3->(DBSetOrder(nOrdEF3)) //HVR
           	EF3->(DBGOTO(nIndEF3)) //HVR
            IF !EMPTY(mv_par08) .AND. IF(lEFFTpMod, IF(EF3->EF3_TPMODU = "I",EF3->EF3_HAWB#AvKey(mv_par08,"EF3_HAWB"),EF3->EF3_PREEMB#mv_par08),EF3->EF3_PREEMB#mv_par08) //PROCESSO //HVR PARA IMPORTACAO HAWB
               EF3->(DbSkip())
               Loop
            ENDIF
            IF !EMPTY(mv_par09) .AND. IF(lEFFTpMod, IF(EF3->EF3_TPMODU = "I", EF3->EF3_INVIMP#AvKey(mv_par09,"EF3_INVIMP"), EF3->EF3_INVOIC#mv_par09), EF3->EF3_INVOIC#mv_par09) //INVOICE //HVR PARA IMPORTAÇÃO INVIMP
               EF3->(DbSkip())
               Loop
            ENDIF

//          EEC->(DBSEEK(EF3->EF3_FILORI+EF3->EF3_PREEMB))
            EEC->(DBSEEK(If(lMultiFil,EF3->EF3_FILORI,xFilial("EEC"))+EF3->EF3_PREEMB))//ASK 05/11/2007
            IF IIF(!lEFFTpMod,!EEC->(EOF()),IIF(EF3->EF3_ORIGEM=="SWB",SW6->( DBSetOrder(1), DBSeek(If(lMultiFil,EF3->EF3_FILORI,xFilial("SW6"))+EF3->EF3_HAWB)),EEQ->(DBSEEK(If(lMultiFil,EF3->EF3_FILORI,xFilial("EEQ"))+EF3->EF3_PREEMB+EF3->EF3_PARC)))) //HVR IMPORTACAO OU EEQ

               If lEFFTpMod  // PLB 14/07/06

                  IF !EMPTY(mv_par10) .AND. (EF1->EF1_IMPORT#AvKey(mv_par10,"EF1_IMPORT") .Or. IIF(EF3->EF3_ORIGEM=="SWB",SW6->W6_IMPORT#AvKey(mv_par10,"W6_IMPORT"),EEQ->EEQ_IMPORT#mv_par10)) //IMPORTADOR //HVR importacao
                     EF3->(DbSkip())
                     Loop
                  ENDIF
                  IF !EMPTY(mv_par11) .AND. (EF1->EF1_LOJAIM#mv_par11 .Or. IIF(EF3->EF3_ORIGEM=="SWB",.F.,EEQ->EEQ_IMLOJA#mv_par11)) //LOJA DO IMPORTADOR
                     EF3->(DbSkip())
                     Loop
                  ENDIF
               
               Else

                  IF !EMPTY(mv_par10) .AND. EEC->EEC_IMPORT#mv_par10 //IMPORTADOR
                     EF3->(DbSkip())
                     Loop
                  ENDIF
                  IF !EMPTY(mv_par11) .AND. EEC->EEC_IMLOJA#mv_par11 //LOJA DO IMPORTADOR
                     EF3->(DbSkip())
                     Loop
                  ENDIF

               EndIf
               // PLB 07/07/06 - Todas as invoices vinculadas devem ser relacionadas nao apenas uma por processo
               /*If aScan(aCliente,{|x| x[1]==(EF3->EF3_CONTRA+iif(lExistBCO,EF3->EF3_PRACA,"")+IF(lEFFTpMod .And. EF3->EF3_TPMODU="I",EF3->EF3_HAWB,EF3->EF3_PREEMB) )} )== 0 //HVR HAWB
                  IF lEFFTpMod
                     Aadd(aCliente,{(EF3->EF3_CONTRA+iif(lExistBCO,EF3->EF3_PRACA,"")+IF(EF3->EF3_TPMODU = "I", EF3->EF3_HAWB, EF3->EF3_PREEMB) )} )
                  ELSE
                     Aadd(aCliente,{(EF3->EF3_CONTRA+iif(lExistBCO,EF3->EF3_PRACA,"")+EF3->EF3_PREEMB )} )
                  ENDIF
               Else
                  EF3->(DBSKIP())              
                  loop
               Endif*/
               Work->(DbAppend())
               Work->FILIAL := aFiliais[nFil]
               IF lEFFTpMod
                  WORK->EF1_TPMODU := EF1->EF1_TPMODU //HVR
                  WORK->EF3_ORIGEM := EF3->EF3_ORIGEM //HVR
               ENDIF
               Work->BANCO  := EF1->EF1_BAN_FI
               Work->DES_BAN:= SA6->A6_NOME
               IF lExistBCO
                  Work->PRACA:=EF1->EF1_PRACA
               ENDIF
               //Alcir Alves - 17-02-05
                
               IF lCadFin //HVR EF7 OU X5
                  //EF7->(DBSETORDER(1))
                  //EF7->(DBSEEK(xFilial("EF7")+EF1->EF1_TP_FIN) )
                  //WORK->TPFIN:=EF7->EF7_DESCRI
                  Work->TPFIN := Posicione("EF7",1,cFilEF7+EF1->EF1_TP_FIN,"EF7_DESCRI")
               ELSE
                  Work->TPFIN:=Tabela("CG",EF1->EF1_TP_FIN,.F.)
               ENDIF //HVR
               
               If lTemRof //HVR TPMODU// - ACSJ - 24/03/2005 - Verificação do campo EF1_ROF
                  Work->ROF:=EF3->EF3_ROF
               Endif
               Work->CONTRA :=EF1->EF1_CONTRA 
               If lEFFTpMod
                  Work->EF1_SEQCNT :=EF1->EF1_SEQCNT //HVR SEQCNT
               EndIf
               IF lEFFTpMod  .And.  EF3->EF3_ORIGEM = "SWB"  //HVR HAWB OU PREEMB
                  Work->PREEMB   :=EF3->EF3_HAWB
                  Work->INVOIC   :=EF3->EF3_INVIMP 
                  Work->EF3_PARC :=EF3->EF3_LINHA //HVR PARCELA
               ELSE
                  Work->PREEMB   :=EF3->EF3_PREEMB
                  Work->INVOIC   :=EF3->EF3_INVOIC 
                  Work->EF3_PARC :=EF3->EF3_PARC //HVR PARCELA
               ENDIF

               If lEFFTpMod  // PLB 14/07/06
                  If Left(EF3->EF3_EV_VIN,2) == Left(EV_JUROS_PREPAG,2)
                     WORK->TPVINC  := STR0057  //"Juros"
                  Else
                     WORK->TPVINC  := STR0056  //"Principal"
                  EndIf
               EndIf

               Work->VLMOE:=EF3->EF3_VL_MOE
               Work->INVMOE:=EF3->EF3_MOE_IN
               Work->INVVL:=EF3->EF3_VL_INV
               Work->DT_VENC:=EF1->EF1_DT_VEN
               IF lEFFTpMod  .And.  EF3->EF3_ORIGEM = "SWB"
                  WORK->CLIENTE :=EF3->EF3_FORN
               ELSE
                  Work->CLIENTE:=EEQ->EEQ_IMPORT
               ENDIF
               Work->DES_CLI:=alltrim(POSICIONE("SA1",1,XFILIAL("SA1")+EEQ->EEQ_IMPORT,"A1_NREDUZ"))
               Work->LOJA:=EEQ->EEQ_IMLOJA
               Work->MOEDA  := EF1->EF1_MOEDA
               Work->DES_MOE:= SYF->YF_DESC_SI
               IF lEFFTpMod
                  nPosic:= aScan(abncTotVL,{|x| x[1]==(Work->EF1_TPMODU+work->filial+work->banco) .And. x[3]==work->moeda}) //HVR TPMODU
               ELSE
                  nPosic:= aScan(abncTotVL,{|x| x[1]==(work->filial+work->banco) .And. x[3]==work->moeda}) //HVR TPMODU
               ENDIF
               If nPosic = 0
                  IF lEFFTpMod
                     Aadd(abncTotVL,{(Work->EF1_TPMODU+work->filial+work->banco),WORK->VLMOE,work->moeda}) //HVR TPMODU
                  ELSE
                     Aadd(abncTotVL,{(work->filial+work->banco),WORK->VLMOE,work->moeda}) //HVR TPMODU
                  ENDIF
               Else
                  abncTotVL[nPosic,2]+=WORK->VLMOE
               Endif
 
               IF lEFFTpMod
                  nPosic:= aScan(abncTotIn,{|x| x[1]==(Work->EF1_TPMODU+work->filial+work->banco) .and. x[3]==work->invmoe})  //HVR TPMODU
               ELSE
                  nPosic:= aScan(abncTotIn,{|x| x[1]==(work->filial+work->banco) .and. x[3]==work->invmoe})  //HVR TPMODU
               ENDIF
               If nPosic = 0
                  IF  lEFFTpmod
                     Aadd(abncTotIn,{(Work->EF1_TPMODU+work->filial+work->banco),WORK->invvl,work->invmoe})  //HVR TPMODU
                  ELSE
                     Aadd(abncTotIn,{(work->filial+work->banco),WORK->invvl,work->invmoe})  //HVR TPMODU
                  ENDIF
               Else
                  abncTotIn[nPosic,2]+=WORK->INVVL
               Endif
               //HVR - Total por Tipo de Cambio
               IF lEFFTpMod
                  nPosic:= aScan(aTpTotVL,{|x| x[1]==(Work->EF1_TPMODU) .AND. X[3] == WORK->MOEDA})
               ELSE
                  nPosic:= aScan(aTpTotVL,{|x| x[2]==WORK->MOEDA})
               ENDIF
               If nPosic = 0
                  IF lEFFTpMod
                     Aadd(aTpTotVL,{Work->EF1_TPMODU,WORK->VLMOE,work->moeda})
                  ELSE
                     Aadd(aTpTotVL,{WORK->VLMOE,work->moeda})
                  ENDIF
               Else
                  aTpTotVL[nPosic,IIF(lEFFTpMod,2,1)]+=WORK->VLMOE
               Endif
               IF lEFFTpMod
                  nPosic:= aScan(aTpTotIn,{|x| x[1]+x[3]==Work->EF1_TPMODU+work->invmoe})   // 02/03/2009 - CCM 
                  If nPosic = 0
                     Aadd(aTpTotIn,{Work->EF1_TPMODU,WORK->invvl,work->invmoe})
                  Else
                     aTpTotIN[nPosic,2]+=WORK->INVVL
                  Endif
               ENDIF
               //  totais por filial
               IF lEFFTpMod
                  nPosic:= aScan(abncTVL_F,{|x| x[1]==(Work->EF1_TPMODU+work->filial) .And. x[3]==work->moeda}) //hvr tpmodu
               ELSE
                  nPosic:= aScan(abncTVL_F,{|x| x[1]==(work->filial) .And. x[3]==work->moeda}) //hvr tpmodu
               ENDIF
               If nPosic = 0
                  IF lEFFTpMod
                     Aadd(abncTVL_F,{(Work->EF1_TPMODU+work->filial),WORK->VLMOE,work->moeda}) //HVR TPMODU
                  ELSE
                     Aadd(abncTVL_F,{(work->filial),WORK->VLMOE,work->moeda}) //HVR TPMODU
                  ENDIF
               Else
                  abncTVL_F[nPosic,2]+=WORK->VLMOE
               Endif
               IF lEFFTpMod
                  nPosic:= aScan(abncTIn_F,{|x| x[1]==(Work->EF1_TPMODU+work->filial) .and. x[3]==work->invmoe}) //HVR TPMODU
               ELSE
                  nPosic:= aScan(abncTIn_F,{|x| x[1]==(work->filial) .and. x[3]==work->invmoe}) //HVR TPMODU
               ENDIF
               If nPosic = 0
                  IF lEFFTpMod
                     Aadd(abncTIn_F,{(Work->EF1_TPMODU+work->filial),WORK->invvl,work->invmoe})
                  ELSE
                     Aadd(abncTIn_F,{(work->filial),WORK->invvl,work->invmoe})
                  ENDIF
               Else
                  abncTIn_F[nPosic,2]+=WORK->INVVL
               Endif
            ENDIF
            
            If EasyEntryPoint("EFFBA160")
               ExecBlock("EFFBA160", .F., .F.,"GRAVA_WORK_ANALITICO")
            EndIf
            Work->(dbCommit())
            EF3->(DbSkip())
         EndDo      
      ENDIF
      
      IF nTipo==1 // Detalhamento por taxas  

         IF lExistBCO
            EF2->(DbSeek(aFiliais[nFil]+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")) ) //HVR TPMODU E SEQCNT
            cWhile:={|| EF2->EF2_BAN_FI==EF1->EF1_BAN_FI  .and. EF2->EF2_PRACA==EF1->EF1_PRACA .And. IF(lEFFTpMod,EF2->EF2_SEQCNT==EF1->EF1_SEQCNT,.T.) } //HVR SEQCNT
         ELSE
            EF2->(DbSeek(aFiliais[nFil]+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA))      //HVR TPMODU
         ENDIF

         SA6->(DbSeek(cFilSA6+EF1->EF1_BAN_FI))
         SYF->(DbSeek(cFilSYF+EF1->EF1_MOEDA))
         lPVez:= .T.
         IF !EF2->(EOF()) .And. EF2->EF2_FILIAL == aFiliais[nFil] .AND. EF2->EF2_CONTRA == EF1->EF1_CONTRA .AND. IF(lEFFTpMod,EF2->EF2_TPMODU == EF1->EF1_TPMODU,.T.) .and. eval(cWhile) //HVR TPMODU
            If IIF(!lEFFTpMod .Or. EF1->EF1_CAMTRA=="2",EF1->EF1_SLD_PM<>0 .or. EF1->EF1_SL2_PM<>0,IIF(EF1->EF1_TPMODU=="E",EF1->EF1_SLD_PM>0,Empty(EF1->EF1_DT_JUR)))  // PLB 13/07/06
            //if EF1->EF1_SLD_PM<>0 .or. EF1->EF1_SL2_PM<>0 //Alcir Alves -20-05-05
               IF lEFFTpMod
                  nPosic:= aScan(aTotMoe,{|x| x[1]==EF1->EF1_TPMODU .And. x[2]==EF1->EF1_MOEDA })
               ELSE
                  nPosic:= aScan(aTotMoe,{|x| x[1]==EF1->EF1_MOEDA })
               ENDIF
               If nPosic = 0
                  IF lEFFTpMod
                     Aadd(aTotMoe, {EF1->EF1_TPMODU, EF1->EF1_MOEDA, nTotVlMoe, nTotVlMVin, nTotVlMPAG })
                  ELSE
                     Aadd(aTotMoe, {EF1->EF1_MOEDA, nTotVlMoe, nTotVlMVin, nTotVlMPAG })
                  ENDIF
               Else
                  IF lEFFTpMod
                     aTotMoe[nPosic,3]+= nTotVlMoe
                     aTotMoe[nPosic,4]+= nTotVlMVin
                     aTotMoe[nPosic,5]+= nTotVlMPAG
                  ELSE
                     aTotMoe[nPosic,2]+= nTotVlMoe
                     aTotMoe[nPosic,3]+= nTotVlMVin
                     aTotMoe[nPosic,4]+= nTotVlMPAG
                  ENDIF
                  If !lEFFTpMod .Or. EF1->EF1_CAMTRA=="2"
                     nTotVlMVin := EF1->EF1_SLD_PM
                     nTotVlMPAG := EF1->EF1_SL2_PM
                  Else
                     nTotVlMVin := EF1->EF1_VL_MOE - EFFBAEvSoma(cFilSoma,EV_EMBARQUE)
                     nTotVlMPAG := EFFBAEvSoma(cFilSoma,EV_EMBARQUE) - EFFBAEvSoma(cFilSoma,EV_LIQ_PRC)
                  EndIf
               Endif
            ENDIF
         ENDIF

         IF !EF2->(EOF()) .And. EF2->EF2_FILIAL == aFiliais[nFil] .AND. EF2->EF2_CONTRA == EF1->EF1_CONTRA .AND. IF(lEFFTpMod,EF2->EF2_TPMODU == EF1->EF1_TPMODU,.T.) .and. eval(cWhile) //HVR TPMODU
            If IIF(!lEFFTpMod .Or. EF1->EF1_CAMTRA=="2",EF1->EF1_SLD_PM<>0 .or. EF1->EF1_SL2_PM<>0,IIF(EF1->EF1_TPMODU=="E",EF1->EF1_SLD_PM>0,Empty(EF1->EF1_DT_JUR)))  // PLB 13/07/06
            //if EF1->EF1_SLD_PM<>0 .or. EF1->EF1_SL2_PM<>0 //Alcir Alves -20-05-05
               IF lEFFTpMod
                  nPos:= aScan(aTotBan,{|x| x[1]=EF1->EF1_TPMODU .AND. x[2]==EF1->EF1_FILIAL .AND. x[3]==EF1->EF1_BAN_FI .And. x[4]==EF1->EF1_MOEDA })
               Else
                  nPos:= aScan(aTotBan,{|x| x[1]=EF1->EF1_FILIAL .AND. x[2]==EF1->EF1_BAN_FI .And. x[3]==EF1->EF1_MOEDA })
               Endif
               If nPos = 0
                  IF lEFFTpMod
                     Aadd(aTotBan, {EF1->EF1_TPMODU, EF1->EF1_FILIAL, EF1->EF1_BAN_FI, EF1->EF1_MOEDA, nTotVlMoe, nTotVlMVin, nTotVlMPAG })
                  ELSE   
                     Aadd(aTotBan, {EF1->EF1_FILIAL, EF1->EF1_BAN_FI, EF1->EF1_MOEDA, nTotVlMoe, nTotVlMVin, nTotVlMPAG })
                  ENDIF
               Else
                  IF lEFFTpMod
                     aTotBan[nPos,5]+= nTotVlMoe
                     aTotBan[nPos,6]+= nTotVlMVin
                     aTotBan[nPos,7]+= nTotVlMPAG
                  ELSE
                     aTotBan[nPos,4]+= nTotVlMoe
                     aTotBan[nPos,5]+= nTotVlMVin
                     aTotBan[nPos,6]+= nTotVlMPAG
                  ENDIF
               Endif
            ENDIF
         ENDIF

         //** AAF 03/01/05 - Total por Filial.
         IF !EF2->(EOF()) .And. EF2->EF2_FILIAL == aFiliais[nFil] .AND. EF2->EF2_CONTRA == EF1->EF1_CONTRA .AND. IF(lEFFTpMod,EF2->EF2_TPMODU == EF1->EF1_TPMODU,.T.) .and. eval(cWhile) //HVR TPMODU
            If IIF(!lEFFTpMod .Or. EF1->EF1_CAMTRA=="2",EF1->EF1_SLD_PM<>0 .or. EF1->EF1_SL2_PM<>0,IIF(EF1->EF1_TPMODU=="E",EF1->EF1_SLD_PM>0,Empty(EF1->EF1_DT_JUR)))  // PLB 13/07/06
            //if EF1->EF1_SLD_PM<>0 .or. EF1->EF1_SL2_PM<>0 //Alcir Alves -20-05-05
               IF  lEFFTpMod
                  nPosFil:= aScan(aTotFil,{|x| x[1]=EF1->EF1_TPMODU .AND. x[2]==EF1->EF1_FILIAL .AND. x[3]==EF1->EF1_MOEDA })
               ELSE
                  nPosFil:= aScan(aTotFil,{|x| x[1]=EF1->EF1_FILIAL .AND. x[2]==EF1->EF1_MOEDA })
               ENDIF
               If nPosFil == 0
                  IF lEFFTpMod
                     aAdd(aTotFil, {EF1->EF1_TPMODU, EF1->EF1_FILIAL, EF1->EF1_MOEDA, nTotVlMoe, nTotVlMVin, nTotVlMPAG })
                  ELSE
                     aAdd(aTotFil, {EF1->EF1_FILIAL, EF1->EF1_MOEDA, nTotVlMoe, nTotVlMVin, nTotVlMPAG })
                  ENDIF
               Else    
                  IF lEFFTpMod
                     aTotFil[nPosFil,4]+= nTotVlMoe
                     aTotFil[nPosFil,5]+= nTotVlMVin
                     aTotFil[nPosFil,6]+= nTotVlMPAG
                  ELSE
                     aTotFil[nPosFil,3]+= nTotVlMoe
                     aTotFil[nPosFil,4]+= nTotVlMVin
                     aTotFil[nPosFil,5]+= nTotVlMPAG
                  ENDIF
               Endif
            ENDIF
         ENDIF
      EndIF
      EF1->(DbSkip())
   EndDo
Next nFil

Return .T.

*---------------------------------------------*
Static Function EFFGERAREL(aDados,aRCampos)
*---------------------------------------------*
Local nRecno:=RECNO()
Private cFilAtu:="-", lPriVez := .T., lTot:= .T.

aDados[7]:= If(!Empty(cBanco), STR0019+cBanco, STR0020)+Space(192)+If(!Empty(cMoeda), STR0021+cMoeda, STR0022) //"Banco - "###"Banco - Todos"###"Moeda - "###"Moeda - Todas"

WORK->(DbGotop())

//** AAF 04/01/05
If WORK->( EoF() )
   Help(" ",1,"AVG0005112") //"Não ha dados para a Impressao!
   Return .F.
Endif
//**

cBanco := WORK->BANCO 
cMoeda := WORK->MOEDA
cFilAtu:= WORK->FILIAL //AAF - 03/01/05 - Quebra por Filial
IF lEFFTpMod
   cTpModu:= Work->EF1_TPMODU //HVR Quebra por Tipo de Cambio
ENDIF
E_Report(aDados,aRCampos)

DBGOTO(nRecno)

Return .T.

*----------------------------------*
Static Function EFFBAGrvTotal(cTot)
*----------------------------------*
Local i, j                   
Local nCol  // PLB 10/07/06

If lPriVez  //.and. !IsEF1C
   Mod_head()
   Fil_Head()
   Bnc_head()
   IF nTipo = 2
      Cli_head() // QUEBRA POR CLIENTE
   EndIf
EndIf

If nTipo=1 .And. !lPriVez
   If cTot=="GERAL"  .Or.  (lEFFTpMod .And. cTpAtu <> Work->EF1_TPMODU)  // Detalhamento por taxas - Alcir Alves - 17-02-05 

      TotBCO()
      Totfil()
//      TotTp()
   
      PulaLinha()  
      @ Linha,000 PSAY __PrtThinline()
      PulaLinha()

      //IF lEFFTpMod
      ASORT(aTotMoe,,,{|X,Y|X[1]+IIF(lEFFTpMod,X[2],"")<Y[1]+IIF(lEFFTpMod,Y[2],"")}) //Ordena por Modulo e Moeda
      For j:= 1 to Len(aTotMoe)
         If cTot=="GERAL" .Or. ( lEFFTpMod .And. ((aTotMoe[j,1] = "E" .And. !Empty(Work->EF1_TPMODU)) .OR. (Empty(Work->EF1_TPMODU) .And. aTotMoe[j,1]= "I")))
            //** PLB 10/07/06
            If lEFFTpMod
               nCol := 144+AVSX3("EF1_PRACA",03)+5
            ElseIf lExistBCO
               nCol := 144+AVSX3("EF1_PRACA",03)
            Else
               nCol := 144
            EndIf
            //**
            If lEFFTpMod  // PLB 10/07/06
               @ Linha, 002 PSAY STR0024+aTotMoe[j,2]+STR0025 //"Total Geral - Moeda ("###")"
               @ Linha, nCol PSAY Transf(aTotMoe[j,3], cPictVl)
               nCol += 20
               @ Linha, nCol PSAY Transf(aTotMoe[j,4], cPictVl)
               nCol += 19
               @ Linha, nCol PSAY Transf(aTotMoe[j,5], cPictVl)
            Else
               @ Linha, 002 PSAY STR0024+aTotMoe[j,1]+STR0025 //"Total Geral - Moeda ("###")"
               @ Linha, nCol PSAY Transf(aTotMoe[j,2], cPictVl)
               nCol += 20
               @ Linha, nCol PSAY Transf(aTotMoe[j,3], cPictVl)
               nCol += 19
               @ Linha, nCol PSAY Transf(aTotMoe[j,4], cPictVl)
            EndIf
            PulaLinha()          
         EndIf        
      Next j               
      @ Linha,000 PSAY __PrtThinline()
      If lEFFTpMod
         PulaLinha()
         cTpAtu := Work->EF1_TPMODU      
         IF !( Work->(EOF()) )
            Linha:=69
         EndIF
         //PulaLinha()
         Mod_Head()
         Fil_Head()
         Bnc_head()
      EndIf
   ElseIf WORK->FILIAL <> cFilAtu
      TotBCO()
      Totfil()
      IF lEFFTpMod
         TotTp()
      ENDIF
      Fil_Head()
      Bnc_head()   
   ElseIf bancoAtu#Work->BANCO
      TotBCO()
      PulaLinha()
      Bnc_head()
   Endif
EndIf
   
If nTipo=2 .And. !lPriVez

   If cTot == "GERAL"  .Or.  (lEFFTpMod .And. cTpAtu <> Work->EF1_TPMODU)
      TotBCO()
      Totfil()
      IF lEFFTpMod
         TotTp()
      ENDIF
      @ Linha,000 PSAY __PrtThinline()
      PulaLinha()  

      If lEFFTpMod
         ASORT(aTotMoe,,,{|X,Y|X[1]+X[2]<Y[1]+Y[2]}) //Ordena por Modulo e Moeda
      Else
         ASORT(aTotMoe,,,{|X,Y|X[1]<Y[1]}) //Ordena por Moeda
      EndIf
      For j:= 1 to Len(aTotMoe)
         If cTot=="GERAL" .Or. ( lEFFTpMod .And. ((aTotMoe[j,1] = "E" .And. !Empty(Work->EF1_TPMODU)) .OR. (Empty(Work->EF1_TPMODU) .And. aTotMoe[j,1]= "I")))
            //** PLB 10/07/06
            If lEFFTpMod
               nCol := 144+AVSX3("EF1_PRACA",03)+5
            ElseIf lExistBCO
               nCol := 144+AVSX3("EF1_PRACA",03)
            Else
               nCol := 144
            EndIf
            //**
            If lEFFTpMod
               @ Linha, 002 PSAY STR0024+aTotMoe[j,2]+STR0025 //"Total Geral - Moeda ("###")"
               @ Linha, nCol PSAY Transf(aTotMoe[j,3], cPictVl)
               nCol += 20
               @ Linha, nCol PSAY Transf(aTotMoe[j,4], cPictVl)
               nCol += 19
               @ Linha, nCol PSAY Transf(aTotMoe[j,5], cPictVl)
            Else
               @ Linha, 002 PSAY STR0024+aTotMoe[j,1]+STR0025 //"Total Geral - Moeda ("###")"
               @ Linha, nCol PSAY Transf(aTotMoe[j,2], cPictVl)
               nCol += 20
               @ Linha, nCol PSAY Transf(aTotMoe[j,3], cPictVl)
               nCol += 19
               @ Linha, nCol PSAY Transf(aTotMoe[j,4], cPictVl)
            EndIf
            PulaLinha()          
         EndIf        
      Next j               
      @ Linha,000 PSAY __PrtThinline()
      If lEFFTpMod
         PulaLinha()
         cTpAtu := Work->EF1_TPMODU
         IF !( Work->(EOF()) )
            Linha:=69
         EndIF
         //PulaLinha()
         Mod_Head()
         Fil_Head()
         Bnc_head()
         Cli_head()
      EndIf

   ElseIf WORK->FILIAL <> cFilAtu
      TotBCO()
      Totfil()
//      TotTp()
      Fil_Head()
      Bnc_head()   
      Cli_head()   
   ElseIf bancoAtu#Work->BANCO
      TotBCO()
      Bnc_head()
      Cli_head()
   Endif
EndIf
lPriVez := .F.

Return .T.

*--------------------------*
Static Function PulaLinha()
*--------------------------*
IF Linha > 55
   Linha := Cabec(aDados[9],aDados[7],aDados[8],aDados[11],aDados[5],EasyGParam("MV_COMP"))
   Linha := 09
Else
   Linha++
Endif
Return .T.

// Função responsavel pela exportação de works para excel ou arquivo de texto
*---------------------------------------------------------------------------------------
STATIC FUNCTION WORK_EXPORT(lExcel) // 02/03/09 - Caio Moscatiello  - revisão
*---------------------------------------------------------------------------------------
TR350ARQUIVO("work",,aClone(aDescCpo),,,lExcel)

Return .T.

//cabecalho da quebra por banco
*---------------------------------------------------------------------------------------
FUNCTION Bnc_head() // 17-02-05 - Alcir Alves
*---------------------------------------------------------------------------------------
   IF bancoAtu#Work->BANCO .and. !work->(eof())
      PulaLinha()
      @ Linha,000 PSAY Repli("-", 220) 
      PulaLinha()
      @ Linha,002 PSAY STR0019+Work->BANCO+" - "+Work->DES_BAN
      PulaLinha()
      @ Linha,000 PSAY Repli("-", 220) 
      //PulaLinha()
      bancoAtu:=Work->BANCO
   ENDIF
return .T.

//total por quebra por banco
*---------------------------------------------------------------------------------------
FUNCTION TotBCO() // 17-02-05 - Alcir Alves
*---------------------------------------------------------------------------------------
local i:=0
Local nCol

IF nTipo==1 // Detalhamento por taxas - Alcir Alves - 17-02-05
   lTot:= .T.
   If lEFFTpMod
      ASORT(aTotBan,,,{|X,Y|X[1]+X[2]+X[3]<Y[1]+Y[2]+Y[3]}) //Ordena por Modulo +Filial + Banco + Moeda      
   Else
      ASORT(aTotBan,,,{|X,Y|X[1]+X[2]+X[3]<Y[1]+Y[2]+Y[3]}) //Ordena por Filial + Banco + Moeda      
   EndIf
   PulaLinha()
   For i:= 1 to Len(aTotBan)
      If aTotBan[i][1]+aTotBan[i][2]+IIF(lEFFTpMod,aTotBan[i][3],"") <> IIF(lEFFTpMod,cTpAtu,"")+cFilAtu+bancoAtu
         Loop
      Else
         //** PLB 10/07/06
         If lEFFTpMod
            nCol := 145+AVSX3("EF1_PRACA",03)+5
         ElseIf lExistBCO
            nCol := 145+AVSX3("EF1_PRACA",03)
         Else
            nCol := 145
         EndIf
         //**
         If lEFFTpMod
            If lTot
               @ Linha, 0 PSAY STR0023+aTotBan[i,3]+" "+STR0027+aTotBan[i,4] //"Saldo do Banco "###"na Moeda "
               lTot:= .F.
            Else
               @ Linha, 0 PSAY Space(Len(STR0023+aTotBan[i,3]))+" "+STR0027+aTotBan[i,4] //"Saldo do Banco "###"na Moeda "
            Endif             
            @ Linha,nCol /*IIF(lExistBCO,150+AVSX3("EF1_PRACA",03),150)*/ PSAY Transf(aTotBan[i,5], cPictVl)
            nCol += 19
            @ Linha,nCol /*IIF(lExistBCO,169+AVSX3("EF1_PRACA",03),169)*/ PSAY Transf(aTotBan[i,6], cPictVl)
            nCol += 19
            @ Linha,nCol /*IIF(lExistBCO,188+AVSX3("EF1_PRACA",03),188)*/ PSAY Transf(aTotBan[i,7], cPictVl)          
            PulaLinha()
         Else
            If lTot
               @ Linha, 0 PSAY STR0023+aTotBan[i,2]+" "+STR0027+aTotBan[i,3] //"Saldo do Banco "###"na Moeda "
               lTot:= .F.
            Else
               @ Linha, 0 PSAY Space(Len(STR0023+aTotBan[i,2]))+" "+STR0027+aTotBan[i,3] //"Saldo do Banco "###"na Moeda "
            Endif             
            @ Linha,nCol /*IIF(lExistBCO,150+AVSX3("EF1_PRACA",03),150)*/ PSAY Transf(aTotBan[i,4], cPictVl)
            nCol += 19
            @ Linha,nCol /*IIF(lExistBCO,169+AVSX3("EF1_PRACA",03),169)*/ PSAY Transf(aTotBan[i,5], cPictVl)
            nCol += 19
            @ Linha,nCol /*IIF(lExistBCO,188+AVSX3("EF1_PRACA",03),188)*/ PSAY Transf(aTotBan[i,6], cPictVl)          
            PulaLinha()
         EndIf
      Endif
   Next i
ELSE
   PulaLinha()                          //TOTAIS POR BANCO - VALORES VINCULADOS  - Alcir Alves - 18-02-05
   @ Linha,000 PSAY Repli("-", 220) 
   PulaLinha()        
   @ Linha,0 PSAY STR0023 + " - " + STR0044
   ASORT(aBncTotVL,,,{|X,Y|X[1]+X[3]<Y[1]+Y[3]}) //Ordena por Modulo +Filial + Banco + Moeda      
   for i:=1 to len(abncTotVL)
      //** PLB 10/07/06
      If lEFFTpMod
         nCol := 100+AVSX3("EF1_PRACA",03)+5
      ElseIf lExistBCO
         nCol := 100+AVSX3("EF1_PRACA",03)
      Else
         nCol := 100
      EndIf
      //**
      IF abncTotVL[i,1] = IIF(lEFFTpMod,cTpAtu,"")+cFilAtu+bancoAtu
         @ Linha,nCol PSAY abncTotVL[i,3]
         nCol += 36
         @ Linha,nCol PSAY Transf(abncTotVL[i,2],cPictVl)
         PulaLinha()        
      ENDIF
   next
   @ Linha,000 PSAY Repli("-", 220) 
   PulaLinha()        
   @ Linha,0 PSAY  STR0023 + " - " + STR0045  //TOTAIS POR BANCO - VALORES DA INVOICE
   ASORT(aBncTotIN,,,{|X,Y|X[1]+X[3]<Y[1]+Y[3]}) //Ordena por Modulo +Filial + Banco + Moeda      
   for i:=1 to len(abncTotIN)
      //** PLB 10/07/06
      If lEFFTpMod
         nCol := 157+AVSX3("EF1_PRACA",03)+5
      ElseIf lExistBCO
         nCol := 157+AVSX3("EF1_PRACA",03)
      Else
         nCol := 157
      EndIf
      //**
      IF abncTotIN[i,1] = IIF(lEFFTpMod,cTpAtu,"")+cFilAtu+bancoAtu// .Or. Left(abncTotVL[i,1],1)=""//WORK->EF1_TPMODU //HVR
         @ Linha,nCol PSAY abncTotIN[i,3]
         nCol += 7
         @ Linha,nCol PSAY Transf(abncTotIN[i,2],cPictVl)
         PulaLinha()        
      ENDIF
   next
   @ Linha,000 PSAY Repli("-", 220) 
   PulaLinha()        
ENDIF

return .t.

//total por quebra de Modulo
*---------------------------------------------------------------------------------------
FUNCTION TotTp() // 17-02-05 - Alcir Alves
*---------------------------------------------------------------------------------------
local i:=0

@ Linha,0 PSAY STR0044+": "+IF(cTpAtu="I",STR0051,STR0052)
PulaLinha()
If lEFFTpMod
   ASORT(aTpTotVL,,,{|X,Y|X[1]+X[3]<Y[1]+Y[3]}) //Ordena por Modulo + Moeda      
Else
   ASORT(aTpTotVL,,,{|X,Y|X[2]<Y[2]}) //Ordena por Modulo + Moeda      
EndIf
for i:=1 to len(aTpTotVL)
   IF IIF(lEFFTpMod,aTpTotVL[i,1]=cTpAtu,.T.) //HVR
      @ Linha,115 PSAY aTpTotVL[i,3]
      @ Linha,151 PSAY Transf(aTpTotVL[i,2],cPictVl)
      PulaLinha()
   ENDIF
next

@ Linha,000 PSAY Repli("-", 220) 
PulaLinha()        
@ Linha,0 PSAY STR0045+": "+IF(cTpAtu="I",STR0051,STR0052)
PulaLinha()
ASORT(aTpTotIN,,,{|X,Y|X[1]+X[3]<Y[1]+Y[3]}) //Ordena por Modulo +Filial + Banco + Moeda      
for i:=1 to len(aTpTotIN)
   IF aTpTotIN[i,1]=cTpAtu //HVR
      @ Linha,172 PSAY aTpTotIN[i,3]
      @ Linha,179 PSAY Transf(aTpTotIN[i,2],cPictVl)
      PulaLinha()        
   ENDIF
next
@ Linha,000 PSAY Repli("-", 220) 
PulaLinha()        

Return .T.

//cabecalho da quebra por cliente
*---------------------------------------------------------------------------------------
static function Cli_head()  //Alcir Alves - 18-02-05                                                            
*---------------------------------------------------------------------------------------
   IF cliAtu#Work->cliente .and. !work->(eof())
      PulaLinha()
      IF lEFFTpMod .AND. WORK->EF1_TPMODU = "I"
         SA2->(DBSETORDER(1))
         SA2->(DBSEEK(xFilial("SA2")+ALLTRIM(WORK->CLIENTE)) )
         @ Linha,000 PSAY STR0054+alltrim(Work->cliente)+" - "+ALLTRIM(SA2->A2_NREDUZ)
      ELSE
         @ Linha,000 PSAY STR0038+alltrim(Work->cliente)+" - "+Work->des_cli+space(6)+STR0032+Work->LOJA
      ENDIF
      cliAtu:=Work->cliente                                                                          
   ENDIF
return .t.


*---------------------------------------------------------------------------------------
FUNCTION Mod_head()
*---------------------------------------------------------------------------------------
   If !lPriVez .And. lEFFTpMod  .And.  Work->EF1_TPMODU = "I"
//     aTpTotVL:={}
//     aTpTotIN:={}
     IF nTipo==1 // Detalhamento por taxas - Alcir Alves - 17-02-05 
        PulaLinha()
        @ Linha,000 PSAY "    "+STR0033+"     "+STR0048+" "+STR0036+"  "+STR0035+"   "+STR0034+" "+STR0010+"        "+STR0011+"          "+STR0046+"    "+STR0012+"   "+STR0013+" "+STR0014+"       "+STR0015+"         "+STR0016+"    "+STR0017+"     "+STR0037
        PulaLinha()
        @ Linha,000 PSAY " =============== ==== ================== ========== ============= ===== ============================== =============== ================ ============ ========== ================== ================== ================== ========"
     Else 
        PulaLinha()
        @ Linha,000 PSAY "    "+STR0033+"     "+STR0048+" "+STR0036+"  "+STR0035+"   "+STR0034+"       "+STR0029+"             "+STR0030+"        "+STR0049+" "+STR0010+"        "+STR0011+"           "+STR0041+"   "+STR0053+"   "+STR0043+"    "+STR0055+" "+STR0037
        PulaLinha()
        @ Linha,000 PSAY " =============== ==== ================== ========== ============= ==================== ==================== ===== ===== ============================== ================== ======== ================== ========= ========"
     EndIf
   EndIf
   
   If lEFFTpMod
      cTpAtu := Work->EF1_TPMODU
      IF !Empty(Work->EF1_TPMODU )
         PulaLinha()
         @ Linha,000 PSAY Repli("*", 220) 
         PulaLinha()
         @ Linha,000 PSAY __PrtLeft(STR0050+": "+IF(cTpAtu="I", STR0051, STR0052) ) //"Módulo" "Importação" "Exportação"
         PulaLinha()
         @ Linha,000 PSAY Repli("*", 220) 
      EndIF
   EndIf
//EndIf   

return .T.
       
**************************************************************************
Function TotFil()  
***************************************************************************

Local i

If !IsEF1C
 IF nTipo==1 // Detalhamento por taxas - Alcir Alves - 17-02-05 
    if !IsEF1C // Alcir Alves - 07-01-05
       PulaLinha()
       @ Linha,000 PSAY Repli("-", 220) 
       PulaLinha()
       @ Linha,000 PSAY __PrtLeft(STR0026+cFilAtu+" - "+AvgFilName({cFilAtu})[1])//"FILIAL "
       PulaLinha()
       @ Linha,000 PSAY Repli("-", 220) 
       PulaLinha()
    endif

    If lEFFTpMod
       ASORT(aTotFil,,,{|X,Y|X[1]+X[2]+X[3]<Y[1]+Y[2]+Y[3]}) //Ordena por Modulo, Filial e Moeda 
    Else
       ASORT(aTotFil,,,{|X,Y|X[1]+X[2]<Y[1]+Y[2]}) //Ordena por Filial e Moeda 
    End

    For i:= 1 to Len(aTotFil)
       If aTotFil[i][1]+aTotFil[i][2]+IIF(lEFFTpMod,aTotFil[i][3],"") <> IIF(lEFFTpMod,cTpAtu,"")+cFilAtu+bancoAtu
             Loop
       Else
          If lEFFTpMod  // PLB 10/07/06
             @ Linha, 002 PSAY STR0027+aTotBan[i][4] //"Total da Filial "###"na Moeda "
             @ Linha, IIF(lExistBCO,150+AVSX3("EF1_PRACA",03),155) PSAY Transf(aTotFil[i][4], cPictVl)
             @ Linha, IIF(lExistBCO,169+AVSX3("EF1_PRACA",03),164) PSAY Transf(aTotFil[i][5], cPictVl)
             @ Linha, IIF(lExistBCO,188+AVSX3("EF1_PRACA",03),205) PSAY Transf(aTotFil[i][6], cPictVl)
          Else
             @ Linha, 002 PSAY STR0027+aTotBan[i][3] //"Total da Filial "###"na Moeda "
             @ Linha, IIF(lExistBCO,150+AVSX3("EF1_PRACA",03),155) PSAY Transf(aTotFil[i][3], cPictVl)
             @ Linha, IIF(lExistBCO,169+AVSX3("EF1_PRACA",03),164) PSAY Transf(aTotFil[i][4], cPictVl)
             @ Linha, IIF(lExistBCO,188+AVSX3("EF1_PRACA",03),205) PSAY Transf(aTotFil[i][5], cPictVl)
          EndIf
          PulaLinha()
       Endif
    Next i 
    @ Linha,000 PSAY Repli("-", 220) 
    PulaLinha()
   
 Else //HVR (cTipo=2) ANALITICO

    if !IsEF1C // Alcir Alves - 07-01-05
       PulaLinha()
       @ Linha,000 PSAY Repli("-", 220) 
       PulaLinha()
       @ Linha,002 PSAY __PrtLeft(STR0026+cFilAtu+" - "+AvgFilName({cFilAtu})[1])//"FILIAL "
       PulaLinha()
       @ Linha,000 PSAY Repli("-", 220) 
       PulaLinha()
    endif
    
    ASORT(abncTVL_F,,,{|X,Y| X[1]<Y[1]}) //Ordena por Modulo, Filial
    //@ Linha,0 PSAY STR0044
    for i:=1 to len(abncTVL_F)
       If aBncTVL_F[i][1] <> IIF(lEFFTpMod,cTpAtu,"")+cFilAtu
             Loop
       Else
          @ Linha,85 PSAY abncTVL_F[i,3]
          @ Linha,121 PSAY Transf(abncTVL_F[i,2],cPictVl)
          PulaLinha()        
       EndIf
    next

    @ Linha,0 PSAY STR0045  //TOTAIS POR filial - VALORES DA INVOICE
    PulaLinha()        

    ASORT(abncTIN_F,,,{|X,Y| X[1]<Y[1]}) //Ordena por Modulo, Filial
    for i:=1 to len(abncTIN_F)
       If aBncTIN_F[i][1] <> IIF(lEFFTpMod,cTpAtu,"")+cFilAtu
             Loop
       Else
          @ Linha,146 PSAY abncTIN_F[i,3]
          @ Linha,157 PSAY Transf(abncTIN_F[i,2],cPictVl)
          PulaLinha()        
       EndIf
    next
 EndIf
ENDIF

Return .T.

**********************************************************
Function Fil_Head()
**********************************************************
   If !IsEF1C
      PulaLinha()
      @ Linha,000 PSAY Repli("*", 220) 
      PulaLinha()
      @ Linha,002 PSAY __PrtLeft(STR0028+cFilAtu+" - "+AvgFilName({cFilAtu})[1])//"FILIAL "
      PulaLinha()
      @ Linha,000 PSAY Repli("*", 220) 
      PulaLinha()
      abncTVL_F:={}
      abncTIN_F:={}
      cBanco:="-"
      bancoAtu:="-"
      CliAtu:="-"
   EndIf
Return .T.

//**----------------------------------------------**
//**----------------------------------------------**
// PLB - Pedro Baroni      13/07/06
// Funcao Soma valores por evento em um contrato
//**----------------------------------------------**
*--------------------------------------------------*
Static Function EFFBAEvSoma(cFil,cCodEve)
*--------------------------------------------------*
 Local nRecEF3 := 0  ,;
       nOrdEF3 := 0  ,;
       nSoma   := 0

   nRecEF3 := EF3->( RecNo() )
   nOrdEF3 := EF3->( IndexOrd() )

   EF3->( DBSetOrder(1) )
   EF3->( DbSeek(cFil+EF1->EF1_TPMODU+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+EF1->EF1_SEQCNT+cCodEve) )

   Do While !EF3->( EoF() )  .And.  EF3->EF3_CODEVE == cCodEve ;
            .And. EF3->(EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT) == cFil+EF1->(EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT)
      If cCodeve != EV_EMBARQUE  .Or.  EF3->EF3_EV_VIN == EV_PRINC_PREPAG  .Or.  EF1->EF1_TPMODU == "I"
         nSoma += EF3->EF3_VL_MOE
      EndIf
      EF3->( DBSkip() )
   EndDo

   EF3->( DBSetOrder(nOrdEF3) )
   EF3->( DBGoTo(nRecEF3) )

Return nSoma
