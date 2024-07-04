#INCLUDE "Eicgi400.ch"
#include "Average.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE "TOPCONN.CH"

#define GI_NORMAL     (MOpcao = 1)
#define GI_APROVADA   (MOpcao = 2)
#define GI_PORTARIA78 (MOpcao = 3)
#define GI_PORTARIA15 (MOpcao = 4)
#define GI_ENTREPOST  (MOpcao = 5)
#define GI_NACIONALIZ (MOpcao = 6)
#define ITENS_LI      5
#DEFINE PLI (MOpcao= 1)
#define GENERICO      "06"
#define NCM_GENERICA  "99999999"
#define VISUAL    2
#define INCLUSAO  3
#define ALTERACAO 4
#define ESTORNO   5
// Particulares às LSIs
//#define LSI       6    // JBS - 10/12/2003
#define INCLUI_LSI 1   // JBS - 05/01/2004
#define ALTERA_LSI 2   // JBS - 05/01/2004
#define EXCLUI_LSI 3   // JBS - 05/01/2004
#define VISUAL_LSI 4   // JBS - 05/01/2004

STATIC bCloseAll


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICGI401 ³ Autor ³ AVERAGE-RS            ³ Data ³ 12/04/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Confeccao de L.I.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC / V407                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*
Alteração: Alessandro Jose Porta (AJP)
Data/Hora: 05/06/2007 - 16H00
Objetivo : Efetuar a quebra da LI conforme o saldo do ato concessorio.
*/
Function EICGI401()
PRIVATE cCadastro := STR0001 //"Confec‡Æo/Manuten‡Æo da L.I."
PRIVATE MOpcao    := 1
PRIVATE nQual := 0
PRIVATE lVisual := .F.
Private AENV_PO:= {}

RETURN GI400Main(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICGI400 ³ Autor ³ AVERAGE-RS            ³ Data ³ 12/04/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Confeccao de P.L.I                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICGI400(lAltGI430)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := STR0002 //"Confec‡Æo/Manuten‡Æo de P.L.I."
PRIVATE MOpcao    := 1
Private cFilSA5:=xFilial("SA5"), cFilSB1:=xFilial("SB1"),cFilEW5:=xFilial("EW5"),nxPosBrw:=0 //DRL - 18/09/09 - Invoices Antecipadas
Private cFilSW5:=xFilial("SW5"), cFilSW4:=xFilial("SW4"), cFilSY6:=xFilial("SY6")
Private cFilED0, cFilED4, cFilED2, cFilED3
Private lMostraAC:=.T. //Usado no Rdmake da Embraer. - TAN
Private cFiltroSY8 := ""
Private aEnv_PO := {} //Jacomo Lisa - 04/06/2014
Private lPesoBruto := SW3->(FieldPos("W3_PESO_BR")) > 0 .And. SW5->(FieldPos("W5_PESO_BR")) > 0 .And. SW7->(FieldPos("W7_PESO_BR")) > 0 .And.;
                      SW8->(FieldPos("W8_PESO_BR")) > 0 .And. EasyGParam("MV_EIC0014",,.F.) //FSM - 02/09/2011
Default lAltGI430 := .F. //TRP-15/10/07
IF ! AmIin(17,50)
   HELP("",1,"AVG0000404") //"Função não autorizada para este módulo !"
   Return NIL
Endif

//TRP-15/10/07
If lAltGI430
   GI400Main(.F.,.T.)
Else
   GI400Main(.F.)
Endif

Return NIL
*--------------------------*
Function GI400Main(lFlag,lAltGI430)
*--------------------------*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL i:=1,nOrderSX3:=(IndexOrd())
Local cFilMbrow := "" //THTS - 03/05/2017 - 512357 / MTRADE-782 - Utilizado para filtrar a mBrowse 

Private lLI := lFlag//FSY - 03/10/2010 variavel para indicar se é rotina de LI ou PLI
Private lTem_DSI := EasyGParam("MV_TEM_DSI",,.F.)//Verifica se tem manutenção de LSI // JBS 11/11/2003

Private lTipoItem := ED7->( FieldPos("ED7_TPITEM") ) > 0  .And.  ED7->( FieldPos("ED7_PD") ) > 0

Private lPesoBruto := SW3->(FieldPos("W3_PESO_BR")) > 0 .And. SW5->(FieldPos("W5_PESO_BR")) > 0 .And. SW7->(FieldPos("W7_PESO_BR")) > 0 .And.;
                      SW8->(FieldPos("W8_PESO_BR")) > 0 .And. EasyGParam("MV_EIC0014",,.F.) //FSM - 02/09/2011

PRIVATE lManuLI:=lFlag
PRIVATE cRotinaOPC := "LI"   // Quando tiver LSI, virar com "LSI"


PRIVATE TInv_Ant, TForn_Inv   //rdmakes
PRIVATE TFornInvLoj:= ""

PRIVATE cDelFunc
PRIVATE aCampos :={}
PRIVATE nPeso_Un:=0
PRIVATE bSeek   :={||SW5->(DBSEEK(xFilial()+SW4->W4_PGI_NUM)) }
PRIVATE bWhile  :={||xFilial("SW5")  = SW5->W5_FILIAL  .AND. ;
                   SW5->W5_PGI_NUM = SW4->W4_PGI_NUM }, bFor:={||SW5->W5_SEQ==0}

PRIVATE FileWork, FileWork2, FileWork3, WKSaldo, WorkNTX2, WorkNTX3, WorkNTX4, WorkNTX5, WorkNTX6, WorkNTX7
PRIVATE cMarca   := GetMark(), lInverte := .F.,lVolta:=.F.//VARIAVEL RDMAKE
PRIVATE cPictFob := ALLTRIM(X3Picture("W6_FOB_TOT"))
PRIVATE cPictInl := ALLTRIM(X3Picture("W6_INLAND"))
PRIVATE cPictFri := ALLTRIM(X3Picture("W6_FRETEIN"))
PRIVATE cPictPac := ALLTRIM(X3Picture("W6_PACKING"))
PRIVATE cPictDes := ALLTRIM(X3Picture("W6_DESCONT"))
PRIVATE cPictNBM := ALLTRIM(X3Picture("B1_POSIPI"))
PRIVATE cPictPeso:= ALLTRIM(X3Picture("W5_PESO"))
PRIVATE dDtEmb   := ALLTRIM(X3Picture("W5_DT_EMB")) //DFS - 19/10/11 - Inclusão da picture do campo data de embarque
PRIVATE dDtEnt   := ALLTRIM(X3Picture("W5_DT_ENTR")) //DFS - 19/10/11 - Inclusão da picture do campo data de entrega
PRIVATE nTamQ    := AVSX3("W5_QTDE",3)
PRIVATE nDecQ    := AVSX3("W5_QTDE",4)
PRIVATE nTamP    := AVSX3("W5_PRECO",3)
PRIVATE nDecP    := AVSX3("W5_PRECO",4)
PRIVATE nTamT    := AVSX3("W6_FOB_TOT",3)
PRIVATE nDecT    := AVSX3("W6_FOB_TOT",4)
PRIVATE TPacking :=0   //variavel para rdmake
PRIVATE TInland  :=0   //variavel para rdmake
PRIVATE TOutDesp :=0   //variavel para rdmake
PRIVATE TDesconto:=0   //variavel para rdmake
PRIVATE TFreteIntl:=0
PRIVATE TSeguro   :=0
PRIVATE TFretIte := TSeguIte := TInlaIte := TDescIte := TPackIte := 0
PRIVATE lSelPO  := .T.
PRIVATE TImport := TConsig    := SPACE(02)
PRIVATE MTabPO  := {}
PRIVATE MDesconto := MInland := MPacking := MFreteIntl := MSeguro := 0
PRIVATE MIncoterm := MMoeda  := SPACE(03)
PRIVATE cExporta  := SPACE(06)
PRIVATE MForn     := SPACE(LEN(SW2->W2_FORN))
PRIVATE MDias_Pag := 0
PRIVATE MCond_Pag := SPACE(05)
PRIVATE MDesc_Pag := SPACE(50)
PRIVATE lMV_EIC_EAI:= AvFlags("EIC_EAI") //EasyGParam("MV_EIC_EAI",,.F.)//AWF - 30/06/2014 - logix

If EICLoja()
   PRIVATE cExportLoj:= SPACE(LEN(SW2->W2_EXPLOJ))
   PRIVATE MFornLoja := SPACE(LEN(SW2->W2_FORLOJ))
EndIf

PRIVATE aRotina := MenuDef(.T., ProcName(1))
PRIVATE lInvAnt

PRIVATE LSI := LEN(aRotina)

Private aCposSW4 := {}  // NCF - 25/05/09 - Array com os campos que serão mostrados na Enchoice de "Manutenção de PLI"

Private aCorrespWork := {} //AOM - 09/04/2011 - Array para manipular as work no objeto de Operações Especiais


Private aCorrespW5 :={}
Private aW5MeCorresp := {}

AADD(aCorrespW5,{"W5_COD_I"  ,"WKCOD_I"    })
AADD(aCorrespW5,{"W5_FABR"   ,"WKFABR"     })
AADD(aCorrespW5,{"W5_FABR_01","WKFABR_01"  })
AADD(aCorrespW5,{"W5_FABR_02","WKFABR_02"  })
AADD(aCorrespW5,{"W5_FABR_03","WKFABR_03"  })
AADD(aCorrespW5,{"W5_FABR_04","WKFABR_04"  })
AADD(aCorrespW5,{"W5_FABR_05","WKFABR_05"  })
AADD(aCorrespW5,{"W5_FORN"   ,"WKFORN"     })
AADD(aCorrespW5,{"W5_PRECO"  ,"WKPRECO"    })
AADD(aCorrespW5,{"W5_QTDE"   ,"WKQTDE"     })
AADD(aCorrespW5,{"W5_SALDO_Q","WKSALDO_Q"  })
AADD(aCorrespW5,{"W5_SI_NUM" ,"WKSI_NUM"   })
AADD(aCorrespW5,{"W5_PO_NUM" ,"WKPO_NUM"   })
AADD(aCorrespW5,{"W5_CC"     ,"WKCC"       })
AADD(aCorrespW5,{"W5_DT_ENTR","WKDT_ENTR"  })
AADD(aCorrespW5,{"W5_DT_EMB" ,"WKDT_EMB"   })
AADD(aCorrespW5,{"W5_REG"    ,"WKREG"      })
AADD(aCorrespW5,{"W5_TEC"    ,"WKTEC"      })
AADD(aCorrespW5,{"W5_EX_NCM" ,"WK_EX_NCM"  })
AADD(aCorrespW5,{"W5_EX_NBM" ,"WK_EX_NBM"  })
AADD(aCorrespW5,{"W5_POSICAO","WKPOSICAO"  })
AADD(aCorrespW5,{"W5_SEQ_LI" ,"WKSEQ_LI"   })
AADD(aCorrespW5,{"W5_PESO"   ,"WKPESO_L"   })
AADD(aCorrespW5,{"W5_PGI_NUM","WKPGI_NUM"  })
AADD(aCorrespW5,{"W5_AC"     ,"WKAC"       })
AADD(aCorrespW5,{"W5_SEQSIS" ,"WKSEQSIS"   })
AADD(aCorrespW5,{"W5_QT_AC"  ,"WKQT_AC"    })
AADD(aCorrespW5,{"W5_QT_AC2" ,"WKQT_AC2"   })
AADD(aCorrespW5,{"W5_VL_AC"  ,"WKVL_AC"    })
AADD(aCorrespW5,{"W5_INVANT" ,"WKINVOIC"   })

If AvFlags("RATEIO_DESP_PO_PLI")
   AADD(aCorrespW5,{"W5_FRETE"   ,"WKFRETE"   })
   AADD(aCorrespW5,{"W5_SEGURO"  ,"WKSEGUR"   })
   AADD(aCorrespW5,{"W5_INLAND"  ,"WKINLAN"   })
   AADD(aCorrespW5,{"W5_DESCONT" ,"WKDESCO"   })
   AADD(aCorrespW5,{"W5_PACKING" ,"WKPACKI"   })
EndIf

AADD(aW5MeCorresp,{"W5_PRECO"  ,"TFobUnit"   })
AADD(aW5MeCorresp,{"W5_PESO"   ,"TPeso_L"    })
AADD(aW5MeCorresp,{"W5_DT_ENTR","TDtEntrega" })
AADD(aW5MeCorresp,{"W5_DT_EMB" ,"TDtEmbarque"})
AADD(aW5MeCorresp,{"W5_COD_I"  ,"cItem"      })
AADD(aW5MeCorresp,{"W5_AC"     ,"cAC"        })
AADD(aW5MeCorresp,{"W5_SEQSIS" ,"cSeqSis"    })
AADD(aW5MeCorresp,{"W5_QTDE"   ,"TSaldo_Q"   })

IF lMV_EIC_EAI//AWF - 30/06/2014
   AADD(aCorrespW5,{"WKQTSEGUM","W5_QTSEGUM"})
   AADD(aW5MeCorresp,{"WKQTSEGUM","W5_QTSEGUM"})
ENDIF

aAdd(aCorrespWork,{"SW5","Work",aCorrespW5   })
aAdd(aCorrespWork,{"SW5","M"   ,aW5MeCorresp })

//AOM - 14/04/2011 - Flag para verificar se Operação Especial está habilitada
Private lOperacaoEsp := AvFlags("OPERACAO_ESPECIAL")

SX3->(DbSetOrder(2))
lW2ConaPro:=SX3->(DbSeek("W2_CONAPRO")) .AND. EasyGParam("MV_AVG0170",,.F.)  //TRP-28/08/08- Teste do parâmetro MV_AVG0170 para definir se habilita Controle de Alçadas no EIC.
lInvAnt := SX3->(dbSeek("EW4_INVOIC")) .AND. SX3->(dbSeek("EW5_INVOIC")) .AND.; //DRL - 16/09/09 - Invoices Antecipadas
           SX2->(dbSeek("EW4")) .AND. SX2->(dbSeek("EW5")) .AND. SIX->(dbSeek("EW4")) .AND. SIX->(dbSeek("EW5"))
SX3->(DbSetOrder(1))

//VARIAVEIS PARA A HUNTER AWR 09/11/1999
PRIVATE lHunter :=EasyEntryPoint("IC010PO1")
//*** VARIAVEL PARA A TELA QUATRO
PRIVATE MTotal, MTotal2, MTotPeso
MTotal:=0
MTotal2:=0
MTotPeso:=0
Private lCposNVAE := (EIM->(FIELDPOS("EIM_FASE")) # 0 .And. SW5->(FIELDPOS("W5_NVE")) # 0 .And. EasyGParam("MV_EIC0011",,.F.) )          //NCF - 08/08/2011 - Classificação N.V.A.E na PLI
// VARIAVEIS PARA RDMAKE DA SUFRAMA
PRIVATE cWorkArq,cNomSuf,cOutSuf
Private lIntDraw := EasyGParam("MV_EIC_EDC",,.F.) //Verifica se existe a integração com o Módulo SIGAEDC
IF !EICLoja()
   cIndice4 := "WKTEC+WKFABR+WKSHNA_NTX+WKALADI+WK_EX_NBM+WK_EX_NCM"+If(lIntDraw, "+WKAC" , "" )+If(lCposNVAE,"+WKNVE","")
Else
   cIndice4 := "WKTEC+WKFABR+W5_FABLOJ+WKSHNA_NTX+WKALADI+WK_EX_NBM+WK_EX_NCM"+If(lIntDraw, "+WKAC" , "" )+If(lCposNVAE,"+WKNVE","")
EndIf
PRIVATE lLote:=EasyGParam("MV_LOTEEIC") $ cSim
PRIVATE dIniEmb:=dFimEmb:=AVCTOD("")
Private _PictPrUn := ALLTRIM(X3Picture("W3_PRECO")), _PictQtde := ALLTRIM(X3Picture("W3_QTDE"))
Private _PictPO := ALLTRIM(X3Picture("W2_PO_NUM")), _FirstYear := Right(Padl(Set(_SET_EPOCH),4,"0"),2)

If lIntDraw
   Private lMUserEDC := FindFunction("EDCMultiUser")
   If lMUserEDC
      Private oMUserEDC := EDCMultiUser():Novo()
   EndIf
   cFilED4 := xFilial("ED4")
   cFilED0 := xFilial("ED0")
   cFilED2 := xFilial("ED2")
   cFilED3 := xFilial("ED3")
EndIf
SYX->(DBSETORDER(3))

// PLB 06/08/07 - Referente tratamento de Incoterm, Frete e Regime de Tributação na LI (ver chamado 054617)
Private lW4_Reg_Tri := SW4->( FieldPos("W4_REG_TRI") ) > 0
Private lW4_Fre_Inc := SW4->( FieldPos("W4_FREINC" ) ) > 0
Private bValFrete := {|| }; bValSeguro := {|| }
Private lSegInc := SW4->(FIELDPOS("W4_SEGINC")) # 0 .AND. SW4->(FIELDPOS("W4_SEGURO")) # 0 // EOB - 14/07/08 - Inclusão do tratamento de incoterm com seguro
Private TCondPgto := TLastCondPG := "" //NCF - 30/03/11 - Variável para controle da condição de pagamento na apropriação de item do Drawback

//NCF - 08/08/2011 - Classificação N.V.A.E na PLI
If lCposNVAE
   Private aSemSX3EIM  := {}
   Private aSemSX3CEIM := {}
   Private aSemSX3GEIM := {}
   Private cFileWkEIM, cFileWkCEIM, cFileWkGEIM
   Private cFileWK_01, cFileWK_02, cFileWK_03, cFileWK_04, cFileWK_05, cFileWK_06, cFileWK_07, cFileWK_08
EndIf
Private lNVEProduto := AvFlags("NVE_POR_PRODUTO")

Default lAltGI430 := .F. //TRP-15/10/07
If lW4_Fre_Inc
   bValFrete := { || (M->W4_FREINC $ cNao) .And. EMPTY(M->W4_FRETEIN) .And. AvRetInco(AllTrim(M->W4_INCOTER),"CONTEM_FRETE")}/*FDR - 28/12/10*/  //(AllTrim(M->W4_INCOTER) $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP")//JVR - 10/11/2009
   //bValFrete := { || (M->W4_FREINC $ cSim) .OR. !(AllTrim(M->W4_INCOTER) $ "CFR,CIF,CIP,CPT,DAF,DES,DEQ,DDU,DDP,FCA") .OR. !EMPTY(M->W4_FRETEIN) } // BHF - 27/02/09
Else
   bValFrete := { || .F. }
EndIf

// EOB - 14/07/08 - Tratamento para incoterm com seguro
If lSeginc
    bValSeguro := { || (M->W4_SEGINC $ cNao) .And. EMPTY(M->W4_SEGURO) .And. AvRetInco(AllTrim(M->W4_INCOTER),"CONTEM_SEG")}/*FDR - 28/12/10*/  //(AllTrim(M->W4_INCOTER) $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP")//JVR - 10/11/2009
   //bValSeguro := { || !(M->W4_SEGINC $ cSim) .OR. !(AllTrim(M->W4_INCOTER) $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP") .OR. !EMPTY(M->W4_SEGURO) }
Else
   bValSeguro := { || .F. }
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Variaveis com nome dos campos de Bancos de Dados        ³
//³ para serem usadas na funcao de inclusao                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCamposTira := {}

If lIntDraw
   aAdd(aCamposTira,"W4_ATO_CON")
   aAdd(aCamposTira,"W4_SUB_ATO")
EndIf

SX3->(DbSetOrder(1))                                                                               //NCF - 04/06/09 - Retira do array dos campos a serem mostrados
SX3->(DBSeek("SW4"))                                                                               //                 na Enchoice, os campos "W4_ATO_COM" e "W4_SUB_ATO"
While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SW4"                                                 //                 quando o parâmetro "MV_EIC_EDC" estiver ligado.
   If X3Uso(SX3->X3_USADO) .AND. aScan(aCamposTira,{|X| AllTrim(X) == AllTrim(SX3->X3_CAMPO)}) == 0
      Aadd(aCposSW4,AllTrim(SX3->X3_CAMPO))
   EndIF
   SX3->(dbSkip())
Enddo

DbSelectArea("SW4")
FOR i := 1 TO FCount()
  M->&(FIELDNAME(i)) := FieldGet(i)
NEXT

DbSelectArea("SW5")
FOR i := 1 TO FCount()
    M->&(FIELDNAME(i)) := FieldGet(i)
NEXT

aCampos:=ARRAY(FCOUNT())

PRIVATE aPos:= { 15,  1, 70, 540 }

SWP->(DBSETORDER(1))
SYX->(DBSETORDER(1))

aCamposSWP:= {}
if lFlag
   aadd( aCamposSWP , {AvSx3("WP_PGI_NUM", AV_TITULO) , "WP_PGI_NUM" } )
   aadd( aCamposSWP , {AvSx3("WP_SEQ_LI" , AV_TITULO) , "WP_SEQ_LI"  } )
   aadd( aCamposSWP , {AvSx3("WP_TRANSM" , AV_TITULO) , "WP_TRANSM"  } )
   aadd( aCamposSWP , {AvSx3("WP_PROT"   , AV_TITULO) , "WP_PROT"    } )
   aadd( aCamposSWP , {"No. LI" , "WP_REGIST"  } )
   aadd( aCamposSWP , {AvSx3("WP_SUBST"  , AV_TITULO) , "WP_SUBST"   } )
   aadd( aCamposSWP , {AvSx3("WP_VENCTO" , AV_TITULO) , "WP_VENCTO"  } )
   aadd( aCamposSWP , {AvSx3("WP_STAT"   , AV_TITULO) , "WP_STAT"    } )
   aadd( aCamposSWP , {AvSx3("WP_DTSITU" , AV_TITULO) , "WP_DTSITU"  } )
   aadd( aCamposSWP , {AvSx3("WP_CANCEL" , AV_TITULO) , "WP_CANCEL"  } )
   aadd( aCamposSWP , {AvSx3("WP_URF_DES", AV_TITULO) , "WP_URF_DES" } )
endif

//TRP-15/10/07
If lAltGI430
   GI400Altera("SWP",nRec,4)
Else
   //THTS - 03/05/2017 - 512357 / MTRADE-782 - Ponto de Entrada para criar um foltro na mBrowse
   If EasyEntryPoint("EICGI400")
      cFilMbrow := ExecBlock("EICGI400",.F.,.F.,"FILTRO_MBROWSE")
      If ( ValType(cFilMbrow) <> "C" )
        cFilMbrow := ""
      EndIf      
   EndIf

   mBrowse( 6, 1,22,75,"SWP",aCamposSWP,,,,,,,,,,,,,cFilMbrow)
Endif
SYX->(DBSETORDER(1))
Return .T.
/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 17/01/07 - 13:31
*/
Static Function MenuDef(lMBrowse, cOrigem)
Local aRotAdic := {}
Local aRotina :=  { { STR0005   ,"AxPesqui"   , 0 , 1     },;//"Pesquisar"
                    { STR0006   ,"GI400Visual", 0 , 2     },;//"Visual"
                    { STR0007   ,"GI400Inclui", 0 , 3     },;//"Incluir"
                    { STR0008   ,"GI400Altera", 0 , 4     },;//"Alterar" //RRV - 06/10/2012
                    { STR0009   ,"GI400Estorn", 0 , 6     }} //"Estornar"

Default cOrigem  := AvMnuFnc()
//Default lMBrowse := .F. - Nopado pois é necessário retornar todas as opções da rotina. Apenas o menufuncional não pode exibi-las (funcao GETMENUDEF é do menu funcional).
Default lMBrowse := OrigChamada()

cOrigem := Upper(AllTrim(cOrigem))

//IF !IsInCallStack("GETMENUDEF") //comentado por wfs
   //lManuLI := .F. //LRS - 23/05/2017 
//EndIF

If FindFunction("EICGI151_B")
   aAdd(aRotina,{ STR0182, "EICGI151_B", 0, 6})//"Substituidas"
EndIf

If EasyGParam("MV_TEM_DSI",,.F.)//Verifica se a manutenção de LSI está habilitada
   aAdd(aRotina, {"Incluir &LSI", "GI400LSI_MAIN", 0, 3})//"Incluir LSI"
EndIf

//If (lMBrowse .And. lManuLI) .Or. (!lMBrowse .And. cOrigem $ "EICGI401")
If cOrigem $ "EICGI401"
   aSize(aRotina, 0)
   aRotina := {{ STR0005, "AxPesqui"   , 0, 1    },;//"Pesquisar"
               { STR0006, "GI401Altera", 0, 2    },;//"Visual"  AOM - 08/04/2010 - chamando a rotina "GI401Altera" para apresentar a enchoice da LI.
               { STR0008, "GI401Altera", 0, 4, 20},;//"Alterar"
               { STR0239, "ElimSaldo"  , 0, 5    },;//"Elimina saldo"
               { STR0349, "GI400Estorn", 0, 7    }} //"Cancelar"
EndIf

aAdd(aRotina, { "Extrato de Licença de Importação", "GI400PDF", 0, 2    }) //RMD - 31/01/18

If EasyEntryPoint("EICGI400")
   ExecBlock("EICGI400",.F.,.F.,"AROTINA")
EndIF

// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("IGI400MNU")
	aRotAdic := ExecBlock("IGI400MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GI400Visual³ Autor ³ PADRAO PARA GETDADDB  ³ Data ³ 12.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa para visualizacao dos Itens da SI                  ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void GI400Visual(ExpC1,ExpN1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                    ³±±
±±³          ³ ExpN1 = Numero do registro                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*----------------------------------------------------------------------------*
Function GI400Visual(cAlias,nReg,nOpc)
*----------------------------------------------------------------------------*
LOCAL bSeek, bWhile, bFor,TB_CAMPOS, i
LOCAL nOpca := 0, oDlg, oGet
LOCAL cAlias1:="SW5", cNomArq
LOCAL bOk:={||nopca:=2,oDlg:End()}
LOCAL bCancel:={||oDlg:End()}
LOCAL nOrderSWP := SWP->(INDEXORD())
Local oEnchoice //LRL 22/03/04
Local cSeek := ""  // PLB 22/02/07
Local bCond := {||.T.}
Local bAction1 := {||.T.}
Local bAction2 := {||.T.}
Private aTRBSemSX3 := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0],nUsado:=0,lTab := .F.
PRIVATE aHeader[0],Continua, nNumLin:=0
PRIVATE nBasePLI:=2
PRIVATE aBotoesVis := {}   //TRP-17/03/08- Array utilizado em rdmake- Chamado 072098

//AOM - 14/04/2011 - Operacao Especial
If lOperacaoEsp
   Private oOperacao := EASYOPESP():New() //AOM - 09/04/2011 - Inicializando a classe para tratamento de operações especiais
EndIf

nQual := nOpc
aAdd(aBotoesVis,{"FORM",{||CalcTotSeqLI("LI")},STR0303,}) // BHF-31/07/2008 - 10:16 - Calcular totais Peso/Preço por Seq.LI //STR0303 "Totais da LI"
IF lCposNVAE
   AADD(aBotoesVis,{"produto",{|| (GI400NVE(oDlg,nQual),TRB->(DbGoTop())) },STR0378,STR0378}) //"Classificacao NVE"
EndIf  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  // NCF-10/07/09 - 15:12 - Alteração no título do botão
//³ Salva a integridade dos campos de Bancos de Dados            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SWP->(DBSETORDER(1))
SW4->(DBSEEK(xFILIAL("SW4")+SWP->WP_PGI_NUM))
IF lTem_DSI   // JBS - 15/11/2003
   IF SWP->WP_LSI == "1"
      M->W4_COD_PRO := SWP->WP_PAIS_PR
      GI400LSI_MAIN(cAlias,nReg,nOpc)
      GI_Final({|| .T. },"SWP")
      RETURN(.T.)
   ENDIF
ENDIF

SWP->(DBSETORDER(1))
IF lManuLI//nOpc == ITENS_LI
   SW5->(DBSETORDER(7))
   cSeek    := xFilial("SW5")+SWP->( WP_PGI_NUM+WP_SEQ_LI )
   bWhile   := { || SW5->( W5_FILIAL+W5_PGI_NUM+W5_SEQ_LI ) }
   bCond    := { || .T. }
ELSE
   SW5->(DBSETORDER(1))
   cSeek    := xFilial("SW5")+SW4->W4_PGI_NUM
   bWhile   := { || SW5->( W5_FILIAL+W5_PGI_NUM ) }
   bCond    := { || .T. }
ENDIF
bAction1 := { || Eval(bWhile) == cSeek .and. SW5->W5_SEQ == 0 }

cAlias:="SW4"

dbSelectArea(cAlias)
IF EasyRecCount(cAlias) == 0
   cAlias:="SWP"
   DBSELECTAREA(cAlias)
   Return (.T.)
EndIf

SW4->(DBSETORDER(1))     //  rs  - quando incluia a pli não estava posicionando na ordem correta - rs 15/10/05
IF !SW4->(DBSEEK(xFILIAL("SWP")+SWP->WP_PGI_NUM))
   Help(" ",1,"EICSEMITEM")
   cAlias:="SWP"
   DBSELECTAREA(cAlias)
   Return .T.
ENDIF

FOR i := 1 TO FCount()
   M->&(FIELDNAME(i)) := FieldGet(i)
NEXT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aCampos:=ARRAY(SW5->(FCOUNT()))

aNoHeader := { "W5_FABR_01", "W5_FABR_02", "W5_FABR_03", "W5_FABR_04", "W5_FABR_05" }
If EICLoja()
  AADD(aNoHeader,"W5_FAB1LOJ")
  AADD(aNoHeader,"W5_FAB2LOJ")
  AADD(aNoHeader,"W5_FAB3LOJ")
  AADD(aNoHeader,"W5_FAB4LOJ")
  AADD(aNoHeader,"W5_FAB5LOJ")
EndIf
aCpoVirtual := { "W5_DESC_P", "W5_FABR_N", "W5_FORN_N", "W5_FOBUN"}// FSY - 24/06/2013 Incluido campo virtual W5_FOBUN

bRecSemX3 := {|| AEval(aTRBSemSX3,{|x| M->&(x[1]) := NIL } ), .T.}
FillGetDB(nOpc, "SW5", "TRB",,7, cSeek, bWhile, { { bCond, bAction1, bAction2 } } ,/*aNoFields*/,/*aYesFields*/,,,,aNoHeader,,,aCpoVirtual,{|a, b| AfterHeader("TRB",@a,@b) }, , bRecSemX3)
cNomArq := AvTrabName("TRB")

If TRB->( EasyRecCount("TRB") ) == 0  // ! E_GravaTRB(cAlias1,bSeek,bFor,bWhile,,{|| GI400NCM() })
   Help(" ",1,"EICSEMITEM")
   TRB->(E_EraseArq(cNomArq,cNomArq,,,.F.))
   cAlias:="SWP"
   DBSELECTAREA(cAlias)
   Return .T.
Endif

TRB->( DBGoTop() )
Do While TRB->( !EoF() )
   SW5->( DBGoTo(TRB->W5_REC_WT) )
   GI400NCM()
   TRB->( DBSkip() )
EndDo

IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"ANTES_TELA_VISUAL"),)     //TRP-17/03/08- Inclusão de ponto de entrada- Chamado 072098

DO While .T.

  oMainWnd:ReadClientCoors()
  DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0013) ;//"Manutecao de PLI"
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
          OF oMainWnd PIXEL

   nMeio:=INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 )
   oEnChoice:=MsMget():New( cAlias, nReg, nOpc, , , ,aCposSW4, { 15,  1, nMeio-1 , (oDlg:nClientWidth-4)/2 } , , 3 )
   lTab   := .T.
   ASIZE(aCampos,0)
   dbSelectArea("TRB")
   dbGoTop()
   TRB->(oGet:=MsGetDB():New(nMeio,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2,nOpc,"E_LinOk","E_TudOk","",.F.,{""} , ,.F., ,"TRB"))
   oGet:oBrowse:bwhen:={||(dbSelectArea("TRB"),.t.)}

   oEnchoice:oBox:Align:=CONTROL_ALIGN_TOP
   oGet:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
   oGet:oBrowse:Refresh()   //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

  ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk,bCancel,,aBotoesVis))//Alinamento MDI //LRL 22/03/04 //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
  EXIT

Enddo

TRB->(E_EraseArq(cNomArq,cNomArq,,,.F.))
cAlias:="SWP"
dbSelectArea(cAlias)
SWP->(DBSETORDER(nOrderSWP))

//AOM - 07/04/11
If lOperacaoEsp
   oOperacao:DeleteWork()
EndIf

Return( nOpca )

*----------------------------------------------------------------------------*
FUNCTION AVECriaTrab(cAlias,cAliasWork)
*----------------------------------------------------------------------------*
LOCAL  aCamposTRB:={}, cNomArq, Item
PRIVATE aNewCampos:={}, aNewHeader:={}//Por causa do rdmake

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria WorkFile para GetDadDB()                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF(cAliasWork==NIL,cAliasWork:="TRB",)
aCamposTRB:= CriaEstru(aCampos,@aHeader,cAlias)
FOR Item:=1 to LEN(aHeader)
    IF aHeader[Item,2] = "W5_FABR_0"
       LOOP
    ENDIF
    IF Item == 2
       AADD(aNewHeader,{STR0011,"W5_NBMTEC","@!",21,0," ","   ","C",,"V"}) //"NBM/TEC/SEQ."
       AADD(aNewCampos,{"W5_NBMTEC","C",21,0})
    ENDIF

    IF Item == 4
       IF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"16"),)//AWR 09/11/1999
       AADD(aNewHeader,{STR0012,"W5_FAMILIA","@!",25,0," ","   ","C",,"V"}) //"Familia"
       AADD(aNewCampos,{"W5_FAMILIA","C",25,0})
    ENDIF

    AADD(aNewCampos,{aCamposTRB[Item,1],aCamposTRB[Item,2],aCamposTRB[Item,3],aCamposTRB[Item,4]})

    AADD(aNewHeader,{ TRIM(aHeader[Item,1]), aHeader[Item,2], aHeader[Item,3],;
                      aHeader[Item,4], aHeader[Item,5], aHeader[Item,6],;
                      aHeader[Item,7], aHeader[Item,8], aHeader[Item,9], aHeader[Item,10] } )

NEXT

IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"BROWSE_VISUALIZAR"),)

ASIZE(aCamposTRB,0)
ASIZE(aHeader,0)
aCamposTRB:=ACLONE(aNewCampos)
aHeader:=ACLONE(aNewHeader)

AAdd(aCamposTRB,{"DBDELETE","L",1,0})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho e indice                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomArq := E_CriaTrab(,aCamposTRB,cAliasWork) //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados

Curlen  := 70-(nUsado:=LEN(aHeader))    // acerto p/ rolagem horizontal no DOS
RETURN cNomArq

*----------------------------------------------------------------------------*
Function GI400NCM()
*----------------------------------------------------------------------------*
LOCAL cDesc := ""
SB1->(DbSeek(xFilial("SB1")+TRB->W5_COD_I))
SYC->(DbSeek(xFilial("SYC")+SB1->B1_FPCOD))
SA2->(DbSeek(xFilial("SA2")+TRB->W5_FABR))
TRB->W5_FABR_N:=SA2->A2_NREDUZ

SA2->(DbSeek(xFilial("SA2")+TRB->W5_FORN+EICRetLoja("TRB","W5_FORLOJ")))
TRB->W5_FORN_N:=SA2->A2_NREDUZ

M->WK_TEC    := Busca_Ncm("SW5","NCM")
M->WK_EX_NCM := Busca_Ncm("SW5","EX_NCM")
M->WK_EX_NBM := Busca_Ncm("SW5","EX_NBM")

cDesc:= MSMM(SB1->B1_DESC_P,AVSX3("B1_VM_P",3),,,)
IF AvFlags("SUFRAMA")  .AND. !EMPTY(M->W4_PROD_SU)
  SYX->(DBSETORDER(3))
  IF SYX->(DBSEEK(xFilial("SYX")+M->W4_PROD_SU+SB1->B1_COD))
    cDesc := MEMOLINE(SYX->YX_DES_ZFM,40,1)
  ENDIF
  SYX->(DBSETORDER(1))
ENDIF
lOk_NBM:=.T.
IF ! SYD->(DBSEEK(xFilial()+M->WK_TEC+M->WK_EX_NCM+M->WK_EX_NBM))
  lOk_NBM:=.F.
ENDIF

TRB->W5_NBMTEC :=TRANSFORM(M->WK_TEC,cPictNBM)+"/"+M->WK_EX_NCM+"/"+M->WK_EX_NBM

//TRB->W5_PESO:=If(SW5->W5_PESO==0,SB1->B1_PESO,SW5->W5_PESO) // FCD 04/07/2001
TRB->W5_PESO := If(SW5->W5_PESO==0,B1Peso(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ")),SW5->W5_PESO) // RA - 04/11/03 - O.S.1112/03
TRB->W5_FAMILIA:=SYC->YC_NOME
TRB->W5_DESC_P:= cDesc

IF lMV_EIC_EAI//AWF - 25/06/2014
   aSegUM:=Busca_2UM(SW5->W5_PO_NUM,SW5->W5_POSICAO)
   IF LEN(aSegUM) > 0
      TRB->W3_UM     :=aSegUM[1]
      TRB->W3_SEGUM  :=aSegUM[2]
      nFATOR         :=aSegUM[3]
      TRB->W3_QTSEGUM:=TRB->W5_QTDE*nFATOR
   ENDIF
ENDIF

IF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"17"),)//AWR 09/11/1999
IF(EasyEntryPoint("ICPADGI2"),ExecBlock("ICPADGI2",.F.,.F.,"PESO"),)
IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"GRAVA_TRB"),)
RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GI400Inclui ³ Autor ³ PADRAO PARA GETDADDB  ³ Data ³ 14.04.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa exclusivo para inclusao de P.L.I                    ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void GI400Inclui(ExpC1,ExpN1)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                     ³±±
±±³          ³ ExpN1 = Numero do registro                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GI400Inclui(cAlias,nReg,nOpc)

LOCAL oDlg, bCreate:={||GI_Create() /*.And. If(SWP->(FIELDPOS("WP_FOB_TOT")) # 0,(SWP->(RecLock("SWP",.F. )),SWP->WP_FOB_TOT := SW4->W4_FOB_TOT,SWP->(MsUnlock())),.T.)*/}, cOldAlias:=SELECT("SX3") //MCF - 15/12/2015 - Não existe gravação da tabela SWP  // GFP - 17/04/2013
                                                                                                                                                                                                     //no momento que executa a gravação do bloco de código.
PRIVATE MOpcao:=1, aApropria:={}, TPo_Num:=SPACE(LEN(SW7->W7_PO_NUM)), aAntDraw:={}, aArrayED3:={}, aPosica:={}, aAltSW5:={}
PRIVATE nBasePLI:=2,lSelec_Base := .F.
//AOM - 14/04/2011 - Operacao Especial
If lOperacaoEsp
   Private oOperacao := EASYOPESP():New() //AOM - 09/04/2011 - Inicializando a classe para tratamento de operações especiais
EndIf

IF AvFlags("SUFRAMA") .AND.EasyEntryPoint("EICGI333")
  IF !ExecBlock("EICGI333",.F.,.F.,"ABRIR")
     RETURN .F.
  ENDIF
ENDIF
lSelPO:=.T.
nQual := 3
DBSELECTAREA("SW4")
SW4->(E_InitVar())

M->W4_DESC_GE := ""

// EOS - OS 553/02 - Inclusão de botão na Toolbar, para exibir uma tela solicitando a PO
//                   de referência, a fim de trazer da PO dados comuns nas 2 operações.
aBtnBar := {}
ASIZE(aBtnBar, 4)
aBtnBar[1] := STR0183 //PO de Referencia
aBtnBar[2] := {|| GI400PORef() }
aBtnBar[3] := "BMPINCLUIR"  //"NOVACELULA"
aBtnBar[4] := STR0183//STR0196 //LRL 23/03/04 - "PO de Ref"
E_Inclui("SW4",;
         nReg ,;
         nOpc ,;
         {||GI_Init(@bCloseAll)},;
         {||E_Valid(aGets,{|campo| GI400Val(campo)}).AND.(IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"VALIDA"),.T.))},;
         bCreate,;
         {||GI_Final(bCloseAll,cOldAlias)},;
         IF(GetNewPar("MV_POREF","N") = "S", aBtnBar,),;
         ,;
         ,;
         STR0013,; //"Manute‡Æo de PLI"
         ,;
         ,;
         aCposSW4)  //NCF - 26/05/09

IF AvFlags("SUFRAMA") .AND.EasyEntryPoint("EICGI333")
  ExecBlock("EICGI333",.F.,.F.,"FECHAR")
ENDIF

IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"FIM_GI400INCLUI"),)	//JWJ - 05/10/2005

If lIntDraw  .And.  lMUserEDC
//   ED4->(msUnlockAll()) //Retira todos os SoftLocks do ED4.
   oMUserEDC:Fim()    // PLB 27/11/06 - Solta registros presos e reinicializa objeto
EndIf

aApropria:={}
aAntDraw :={}
aArrayED3:={}
aPosica  :={}

//AOM - 07/04/11
If lOperacaoEsp
   oOperacao:DeleteWork()
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GI400Altera ³ Autor ³ PADRAO PARA GETDADDB  ³ Data ³ 14.04.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa exclusivo para alteracao de P.L.I                   ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void GI400Altera(ExpC1,ExpN1)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias  Do Arquivo                                     ³±±
±±³          ³ ExpN1 = Numero Do Registro                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GI400Altera(cAlias,nReg,nOpc)

LOCAL oDlg, bCreate, cOldAlias:=SELECT("SX3")
LOCAL bFunction := {||If(GI400Atu(bValid),oDlg:End(),)}
LOCAL cResource := "SALVAR"   // nome do resource
LOCAL cToolTip  := STR0014 //"Salva & Sai"
Local cTitle    := STR0202 //LRL 23/03/04 -Titulo para versão MDI - "Salva/Sai"
//LOCAL bValid    :={||E_Valid(aGets,{|campo| GI400Val(campo)}).AND.IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"VALIDA_ALTERA"),.T.)}
// PLB 06/08/07 - Incluida validação para tratamento de Incoterm e Frete
LOCAL bValid    := { || E_Valid(aGets,{|campo| GI400Val(campo)})                                             ;
                       .And. IIF(Eval(bValFrete) ,(Help(" ",1,"E_FREVALOR"),.F.), .T.)                       ;   //"Valor do frete não informado."
                       .And. IIF(Eval(bValSeguro),(Help(" ",1,"E_SEGVALOR"),.F.), .T.)                       ;   //"Valor do seguro não informado."
                       .And. IIF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"VALIDA_ALTERA"),.T.)    }
//LOCAL lTem_DSI := EasyGParam("MV_TEM_DSI",,.F.) //Verifica se tem manutenção de LSI // ACSJ - 28/04/2004
                                                                               // Alteração feita para resolver
                                                                               // QNC 001690/2004-00 de 28/04/2004
                                                                               // Conforme orientação do Sr. Jonato
Private lAltera:=.F., aApropria := {}, aAltSW5:={}, aAntDraw:={}, aArrayED3:={}, aPosica:={}, lReturn := .T.
PRIVATE nBasePLI:=2,lSelec_Base := .F.
PRIVATE LSI := LEN(aRotina)
PRIVATE FileWork2, FileWork3

//AOM - 14/04/2011 - Operacao Especial
If lOperacaoEsp
   Private oOperacao := EASYOPESP():New() //AOM - 09/04/2011 - Inicializando a classe para tratamento de operações especiais
EndIf

lGravouTudo:=.F.
nQual := 4
lSelPO:=.T.
IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"VALID_ALTERACAO"),.T.)
IF !lReturn
    RETURN .F.
ENDIF

bCreate:={||GI_Create(),GI400Atu_LI()}

PRIVATE MOpcao:=1
IF AvFlags("SUFRAMA") .AND.EasyEntryPoint("EICGI333")
  IF !ExecBlock("EICGI333",.F.,.F.,"ABRIR")
     RETURN .F.
  ENDIF
ENDIF

DBSELECTAREA("SW4")

SWP->(DBSETORDER(1))
SW4->(DBSEEK(xFILIAL("SW4")+SWP->WP_PGI_NUM))
IF .NOT. RecLock("SW4",.F.)  // Lock p/ alteracao
   SW4->(MsUnlock())
   Return .F.
ENDIF
IF lTem_DSI   // JBS - 15/11/2003
   IF SWP->WP_LSI == "1"
      M->W4_COD_PRO := SWP->WP_PAIS_PR
      GI400LSI_MAIN(cAlias,nReg,nOpc)  // Alteração
      GI_Final({|| .T. },"SWP")
      RETURN(.T.)
   ENDIF
ENDIF
SW4->(E_InitVar())
M->W4_COD_PRO := SWP->WP_PAIS_PR
E_Inclui("SW4",nReg,nOpc,{||GI_Init(@bCloseAll)},bValid,;
         bCreate,{||GI_Final(bCloseAll,cOldAlias)},{cToolTip,bFunction,cResource,cTitle},,@oDlg,STR0013,,,aCposSW4) //"Manute‡Æo de PLI"
SW4->(MsUnLock())

IF AvFlags("SUFRAMA") .AND.EasyEntryPoint("EICGI333")
  ExecBlock("EICGI333",.F.,.F.,"FECHAR")
ENDIF

aApropria := {}
aAntDraw  := {}
aArrayED3 := {}
aPosica   := {}
aAltSW5   := {}

IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"FIM_GI400ALTERA"),)	//JWJ - 05/10/2005

If ((Type("lIntDraw") == "L" .And. lIntDraw) .Or. EasyGParam("MV_EIC_EDC",,.F.))  .And.;
   ((Type("lMUserEDC") == "L" .And. lMUserEDC) .Or. FindFunction("EDCMultiUser")) .And. Type("oMUserEDC") == "O"
   //   ED4->(msUnlockAll()) //Retira todos os SoftLocks do ED4.
   oMUserEDC:Fim()    // PLB 27/11/06 - Solta registros presos e reinicializa objeto
EndIf

//AOM - 07/04/11
If lOperacaoEsp
   oOperacao:DeleteWork()
EndIf

RETURN .T.

*---------------------------------------------------------------------------*
Function GI400Atu(bValid)
*---------------------------------------------------------------------------*
LOCAL cPointE:="EICGI02E", cPointS:="EICGI02S"
LOCAL lPointE:=EasyEntryPoint(cPointE), lPointS:=EasyEntryPoint(cPointS)

If !Obrigatorio(aGets,aTela) .or. !Eval(bValid)
   Return .F.
Endif
If MsgYesNo(STR0015,STR0016) //'Confirma a Gravação? '###'Capa do L.I.'
   W4_GI_NUM:=SW4->W4_GI_NUM

   If lPointE .And. !ExecBlock(cPointE)
      Return .F.
   Endif
   lVolta:=.F.
   IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"VALIDA_ALTERA"),)

   IF lVolta
      Return .F.
   ENDIF

   //NCF - 08/08/2011 - Classificação N.V.A.E na PLI
   If lCposNVAE
      GI400EIMGrava()
   EndIf

   MsAguarde({|lEnd| GI_Grava({|msg| MsProcTxt(msg)},.F.) },;
                STR0017) //"Manuten‡Æo de L.I."

   SwpGrava() //FSM - 12/11/2010

   lGravouTudo:=.T.
   If(lPointS,ExecBlock(cPointS),)
Else
   Return .F.
Endif
Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GI400Estorno³ Autor ³ PADRAO PARA GETDADDB  ³ Data ³ 13.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Estorno de P.L.I                                 ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void GI400Estorno(ExpC1,ExpN1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                     ³±±
±±³          ³ ExpN1 = Numero do registro                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GI400Estorno(cAlias,nReg,nOpc)

LOCAL oDlg, FileWork, MTotal:=0 ,oMark, oPanel
LOCAL _LIT_R_CC := IF(EMPTY(ALLTRIM(EasyGParam("MV_LITRCC"))),(AVSX3("W0__CC",5)), ALLTRIM(EasyGParam("MV_LITRCC")))
LOCAL _PictItem := ALLTRIM(X3PICTURE("B1_COD"))
LOCAL _PictPGI  := ALLTRIM(X3PICTURE("W4_PGI_NUM"))
LOCAL _PictSI   := ALLTRIM(X3PICTURE("W0__NUM"))
LOCAL bOk:={||If(GI410Estorno(),oDlg:End(),)}
LOCAL bCancel:={||oDlg:End()}

PRIVATE MConta:=0, MAprovada:=.F.
PRIVATE aSeqLi:={},aCampos:={},cHeader :=""
PRIVATE nBasePLI:=2
PRIVATE aTabsNVE := {} // NCF - 07/12/11 - Classificação N.V.A.E na PLI

//AOM - 14/04/2011 - Operacao Especial
If lOperacaoEsp
   Private oOperacao := EASYOPESP():New() //AOM - 09/04/2011 - Inicializando a classe para tratamento de operações especiais
EndIf

//GCC - 12/07/2013 - Verifica se a rotina consiste em estorno (Manutenção PLi) ou cancelamento (Manutenção Li)
If lManuLI
	If Empty(SWP->WP_REGIST)
		EasyHelp(STR0350) //"Não é possível cancelar LI, pois o processo não esta registrado! Acesse a rotina Manutenção PLi e efetue o estorno."
		Return .F.
	EndIf
Else
	If !Empty(SWP->WP_REGIST)
		EasyHelp(STR0351) //"Não é possível estornar PLi, pois o processo já esta registrado! Acesse a rotina Manutenção Li e efetue o cancelamento."
		Return .F.
	EndIf
EndIf

nQual := 5
TPacking  := TInland    := TOutDesp  := TDesconto  := TFreteIntl := TSeguro := 0

// usado no rdmake Hunter
aDBF_Stru:= { {"WKCOD_I","C",AVSX3("W5_COD_I",3),0},{"WKDESCR","C",36,0},;
              {"WKFABR","C",AVSX3("W5_FABR",3),0}     , {"WKNOME_FAB","C",15,0} ,;  //SO.:0026 OS.:0228/02 FCD
              {"WKFORN","C",AVSX3("W5_FORN",3),0}     , {"WKNOME_FOR","C",15,0} ,;  //SO.:0026 OS.:0228/02 FCD
              {"WKREG","N",AVSX3("W5_REG",3),0}      , {"WKFLUXO","C",1,0}     ,;
              {"WKQTDE"   ,"N",nTamQ,nDecQ} ,;
              {"WKPRECO"  ,"N",nTamP,nDecP} ,;
              {"WKSALDO_Q","N",nTamQ,nDecQ} ,;
              {"WKSALDO_O","N",nTamQ,nDecQ} ,;
              {"WKCC","C",AVSX3("W5_CC",3),0}       , {"WKSI_NUM","C",AVSX3("W5_SI_NUM",3),0}    ,; //SO0026 OS.:0228/02 FCD
              {"WKPO_NUM","C",AvSx3("W2_PO_NUM", AV_TAMANHO),0}  , {"WKDT_EMB","D",8,0}    ,;
              {"WKDT_ENTR","D",8,0}  , {"WKDTENTR_S","D",8,0}  ,;
              {"WKFLAG","L",1,0}     , {"WKNBM","C",03,0}      ,;
              {"WKPESO_L","N",AVSX3("W5_PESO",3),AVSX3("W5_PESO",4)},;  //TRP-28/02/08
                    {"WKRECNO_IG","N",9,0}  ,;
              {"WKFAMILIA","C",AVSX3("YC_COD",3),0 } ,;
                    {"WKFLAGWIN","C",2,0} ,;
              {"WKSEQ_LI","C",3,0}   ,;
                    {"OR_FILIAL","C",2,0}  , {"WK_OK","C",2,0},;
              {"WK_EX_NCM","C",AVSX3("B1_EX_NCM",3),AVSX3("B1_EX_NCM",4)} ,;
              {"WK_EX_NBM","C",AVSX3("B1_EX_NBM",3),AVSX3("B1_EX_NBM",4)}}

AADD(aDBF_Stru,{"WKPOSICAO","C",LEN(SW3->W3_POSICAO),0}) //AWR 10/02/99

//TRP - 07/02/07 - Campos do WalkThru
AADD(aDBF_Stru,{"TRB_ALI_WT","C",03,0})
AADD(aDBF_Stru,{"TRB_REC_WT","N",10,0})

//FSM - 31/08/2011 - Adção do campo Peso bruto
If lPesoBruto
   AADD(aDBF_Stru,{"WKW5PESOBR" ,AVSX3("W5_PESO_BR",AV_TIPO),AVSX3("W5_PESO_BR",AV_TAMANHO) ,AVSX3("W5_PESO_BR",AV_DECIMAL)})
EndIf
If AvFlags("RATEIO_DESP_PO_PLI")
   AADD(aDBF_Stru,{"WKFRETE" ,AVSX3("W5_FRETE",AV_TIPO),AVSX3("W5_FRETE",AV_TAMANHO) ,AVSX3("W5_FRETE",AV_DECIMAL)})
   AADD(aDBF_Stru,{"WKSEGUR",AVSX3("W5_SEGURO",AV_TIPO),AVSX3("W5_SEGURO",AV_TAMANHO) ,AVSX3("W5_SEGURO",AV_DECIMAL)})
   AADD(aDBF_Stru,{"WKINLAN",AVSX3("W5_INLAND",AV_TIPO),AVSX3("W5_INLAND",AV_TAMANHO) ,AVSX3("W5_INLAND",AV_DECIMAL)})
   AADD(aDBF_Stru,{"WKDESCO",AVSX3("W5_DESCONT",AV_TIPO),AVSX3("W5_DESCONT",AV_TAMANHO) ,AVSX3("W5_DESCONT",AV_DECIMAL)})
   AADD(aDBF_Stru,{"WKPACKI",AVSX3("W5_PACKING",AV_TIPO),AVSX3("W5_PACKING",AV_TAMANHO) ,AVSX3("W5_PACKING",AV_DECIMAL)})
EndIf
//AOM - 08/04/07 - Operações Especiais
If lOperacaoEsp
 AADD(aDBF_Stru,{"W5_CODOPE" ,AVSX3("W5_CODOPE",2), AVSX3("W5_CODOPE",3),AVSX3("W5_CODOPE",4)})
 AADD(aDBF_Stru,{"W5_DESOPE" ,AVSX3("W5_DESOPE",2), AVSX3("W5_DESOPE",3),AVSX3("W5_DESOPE",4)})
EndIf

If EICLoja()
   AADD(aDBF_Stru,{"W5_FABLOJ" ,"C",AVSX3("W5_FABLOJ",3) ,0})
   AADD(aDBF_Stru,{"W5_FABLOJ1","C",AVSX3("W5_FAB1LOJ",3),0})
   AADD(aDBF_Stru,{"W5_FABLOJ2","C",AVSX3("W5_FAB2LOJ",3),0})
   AADD(aDBF_Stru,{"W5_FABLOJ3","C",AVSX3("W5_FAB3LOJ",3),0})
   AADD(aDBF_Stru,{"W5_FABLOJ4","C",AVSX3("W5_FAB4LOJ",3),0})
   AADD(aDBF_Stru,{"W5_FABLOJ5","C",AVSX3("W5_FAB5LOJ",3),0})
   AADD(aDBF_Stru,{"W5_FORLOJ" ,"C",AVSX3("W5_FORLOJ" ,3),0})
EndIf

If lIntDraw
   AADD(aDBF_Stru,{"WKSEQSIS" ,"C", AVSX3("ED4_SEQSIS",3),0})
   AADD(aDBF_Stru,{"WKVL_AC" ,"N", AVSX3("ED4_VALEMB",3),AVSX3("ED4_VALEMB",4)})
   AADD(aDBF_Stru,{"WKAC" ,"C", AVSX3("ED4_AC",3),0})
   AADD(aDBF_Stru,{"WKQT_AC" ,"N", AVSX3("ED4_QTD",3),AVSX3("ED4_QTD",4)})
   AADD(aDBF_Stru,{"WKQT_AC2" ,"N", AVSX3("ED4_QTDNCM",3),AVSX3("ED4_QTDNCM",4)})
EndIf
If lInvAnt //DRL - 17/09/09 - Invoices Antecipadas
   AADD(aDBF_Stru,{"WKINVOIC", AVSX3("EW5_INVOIC",2), AVSX3("EW5_INVOIC",3), AVSX3("EW5_INVOIC",4)})
EndIf
IF lMV_EIC_EAI//AWF - 30/06/2014
   AADD(aDBF_Stru,{"WKUNI"    ,"C",AVSX3("W3_UM"     ,3),0})
   AADD(aDBF_Stru,{"WKSEGUM"  ,"C",AVSX3("W3_SEGUM"  ,3),0})
   AADD(aDBF_Stru,{"WKQTSEGUM","N",AVSX3("W3_QTSEGUM",3),AVSX3("W3_QTSEGUM" ,4)})
   AADD(aDBF_Stru,{"WKFATOR"  ,"N",AVSX3("J5_COEF"   ,3),AVSX3("J5_COEF",4)})
ENDIF

//by GFP - 14/10/2010 - 09:58
aDBF_Stru := AddWkCpoUser(aDBF_Stru,"SW5")

IF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"8LI"),)//AWR 10/11/1999
IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"STRU"),)//CES 28/08/01

SW4->(DBSETORDER(1))
IF ! SW4->(DBSEEK(xFILIAL("SW4")+SWP->WP_PGI_NUM))
   Help(" ",1,"E_NAOHAITE")
   Return .F.
ENDIF

IF .NOT. RecLock("SW4",.F.,.T.) // lock p/ delecao
   SW4->(MsUnlock())
   Return .F.
ENDIF

SW5->(DBSETORDER(1))
IF ! SW5->(DBSEEK(xFILIAL("SW5")+SWP->WP_PGI_NUM))
   Help(" ",1,"E_NAOHAITE")
   Return .F.
ENDIF
IF SW4->W4_FLUXO = "5"
   Help(" ",1,"E_GINAOCAD")
   Return .F.
ENDIF

FileWork := E_CriaTrab(,aDBF_Stru,"Work") //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados

IF ! USED()
   Help(" ",1,"E_NAOHARE")
   RETURN .F.
ENDIF

If EICLoja()
   IndRegua("Work",FileWork+TEOrdBagExt(),"WKSEQ_LI+WKPO_NUM+WKCC+WKSI_NUM+WKCOD_I+WKFABR+W5_FABLOJ+WKFORN+W5_FORLOJ+STR(WKREG,"+Alltrim(Str(AVSX3("W5_REG",3)))+",0)")
Else
   IndRegua("Work",FileWork+TEOrdBagExt(),"WKSEQ_LI+WKPO_NUM+WKCC+WKSI_NUM+WKCOD_I+WKFABR+WKFORN+STR(WKREG,"+Alltrim(Str(AVSX3("W5_REG",3)))+",0)")
EndIf
IF W4_FLUXO = '2'
   MAprovada:= .T.
ENDIF

MsAguarde({|| SW5->(GI400WorkEstorno({|msg|MsProcTxt(msg)},@MTotal)) }, STR0018) //"Pesquisa de Itens"

IF MTotal = 0
   Help(" ",1,"E_NAOITEST")
   Work->(E_EraseArq(FileWork,FileWork))
   Return .F.
ENDIF

If !lManuLI  .And.  lIntDraw  .And.  lMUserEDC  .And.  !oMUserEDC:Reserva("PLI","ESTORNA")
   Return .F.
EndIf

Work->(DBGOTOP())

aCampos:={ }
If nQual # 4
   AADD(aCampos,{"WKFLAGWIN" ,"",""})
EndIf

AADD(aCampos,{"WKSEQ_LI"  ,"",STR0019 }                        ) //"Seq."
AADD(aCampos,{"WKPO_NUM"  ,"",OemToAnsi(STR0020),_PictPO}      ) //"N§ P.O."
AADD(aCampos,{"WKCC"      ,"",_LIT_R_CC}                       )
AADD(aCampos,{"WKSI_NUM"  ,"",OemToAnsi(STR0021),_PictSI}      ) //"N§ SI"
AADD(aCampos,{"WKPOSICAO" ,"",STR0022}                         ) //"Posicao" AWR 10/02/99
AADD(aCampos,{"WKCOD_I"   ,"",STR0023,_PictItem}               ) //"Item"
IF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"20"),)//AWR 10/11/1999
AADD(aCampos,{"WKFAMILIA" ,"",STR0024}                         ) //"Fam¡lia"
AADD(aCampos,{"WKDESCR"   ,"",STR0025}                         ) //"Descri‡ao para P.L.I."
AADD(aCampos,{"WKFABR"    ,"",STR0026}                         ) //"Fabricante"
AADD(aCampos,{"WKNOME_FAB","",STR0027}                         ) //"Nome"
AADD(aCampos,{"WKFORN"    ,"",STR0028}                         ) //"Fornecedor"
AADD(aCampos,{"WKNOME_FOR","",STR0027}                         ) //"Nome"
AADD(aCampos,{"WKQTDE"    ,"",STR0029,_PictQtde}               ) //"Quantidade"
IF lMV_EIC_EAI//AWF - 30/06/2014
   AADD(aCampos,{"WKUNI"    ,"",AVSX3("W3_UM"     ,AV_TITULO)})
   AADD(aCampos,{"WKQTSEGUM","",AVSX3("W3_QTSEGUM",AV_TITULO),AVSX3("W3_QTSEGUM" ,6)})
   AADD(aCampos,{"WKSEGUM"  ,"",AVSX3("W3_SEGUM"  ,AV_TITULO)})
   AADD(aCampos,{"WKFATOR"  ,"","Fator Conv 2UM"  ,AVSX3("J5_COEF",6) })
ENDIF
AADD(aCampos,{"WKSALDO_Q" ,"",STR0030,_PictQtde}               ) //"Saldo"
AADD(aCampos,{"WKPESO_L"  ,"",AVSX3("W5_PESO",5),AVSX3("W5_PESO",6)}) //CCH - 07/08/09 - Gravação do novo campo de Peso Líquido Unitário
AADD(aCampos,{"WKPRECO"   ,"",STR0031,_PictPrUn}               )//"Pre‡o Unit rio"
AADD(aCampos,{"WKDT_EMB"  ,"",STR0032}                         ) //"Embarque"
AADD(aCampos,{"WKDT_ENTR" ,"",STR0033}                         ) //"Entrega"

//FSM - 31/08/2011 -
If lPesoBruto
   AADD(aCampos,{"WKW5PESOBR" ,"",AVSX3("W5_PESO_BR",AV_TITULO),AVSX3("W5_PESO_BR",AV_PICTURE)}) //"Peso Bruto"
EndIf
If AvFlags("RATEIO_DESP_PO_PLI")
   AADD(aCampos,{"WKFRETE" ,"",AVSX3("W5_FRETE",AV_TITULO),AVSX3("W5_FRETE",AV_PICTURE)}) //"Frete"
   AADD(aCampos,{"WKSEGUR","",AVSX3("W5_SEGURO",AV_TITULO),AVSX3("W5_SEGURO",AV_PICTURE)}) //"Seguro"
   AADD(aCampos,{"WKINLAN","",AVSX3("W5_INLAND",AV_TITULO),AVSX3("W5_INLAND",AV_PICTURE)}) //"Inland"
   AADD(aCampos,{"WKDESCO","",AVSX3("W5_DESCONT",AV_TITULO),AVSX3("W5_DESCONT",AV_PICTURE)}) //"Desconto"
   AADD(aCampos,{"WKPACKI","",AVSX3("W5_PACKING",AV_TITULO),AVSX3("W5_PACKING",AV_PICTURE)}) //"Packing"
EndIf
If lIntDraw .and. Empty(M->W4_ATO_CON)
   AADD(aCampos,{"WKAC"      ,"",AVSX3("ED0_AC",5)}               ) //"Ato Concessorio"
EndIf

//AOM - 08/04/2011
If lOperacaoEsp
   AADD(aCampos,{"W5_CODOPE" ,"",AVSX3("W5_CODOPE",5)})
   AADD(aCampos,{"W5_DESOPE" ,"",AVSX3("W5_DESOPE",5)})
EndIf

//by GFP - 13/10/2010 - 15:12
aCampos := AddCpoUser(aCampos,"SW5","2")

nBrowse:=1
If lInvAnt .And. nBasePLI == 1 //DRL - 16/09/09 - Invoices Antecipadas
   ASIZE(aCampos, Len(aCampos)+1)
   nxPosBrw := If(nQual==4,04,05)
   aIns(aCampos,nxPosBrw)
   aCampos[nxPosBrw] := {"WKINVOIC","","Inv.Antecip."}
EndIf
IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"BROWSE"),)//CES 28/08/01

oMainWnd:ReadClientCoors()
DEFINE MSDIALOG oDlg TITLE (STR0013+" "+ALLTRIM(TRANSFORM(SW4->W4_PGI_NUM,_PictPGI))) ; //"Manute‡Æo de PLI"
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
             OF oMainWnd PIXEL

   oMark:= MsSelect():New("Work","WKFLAGWIN",,aCampos,@lInverte,@cMarca,{30,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2})

   @01,01 MsPanel oPanel Prompt "" Size 20,15 of oDlg //LRL 23/03/04 - Painel para alinhamento na versão MDI
   @2,(oDlg:nClientWidth-6)/2-120 BUTTON STR0034 SIZE 75,11 ACTION (GI410_Marca(.T.), oMark:oBrowse:Refresh()) OF oPanel PIXEL //"Marca/Desmarca Todos"
   @2,(oDlg:nClientWidth-6)/2-040 BUTTON STR0035              SIZE 34,11 ACTION (If(GI410Estorno(),oDlg:End(),))           OF oPanel PIXEL //"Estorna"

   oMark:bAval:={||GI410_Marca(.F.), oMark:oBrowse:Refresh()}

   oPanel:Align:=CONTROL_ALIGN_TOP
   oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
   oMark:oBrowse:Refresh() //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk,bCancel,,)) //LRL 23/03/04 Alinhamento MDI //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

Work->(E_EraseArq(FileWork,FileWork))
SW4->(MsUnlock())  // Desbloqueia o registro
IF SELECT("Work_EIT") <> 0
   //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados
   Work_EIT->(E_EraseArq(FileWork2))
   FErase(FileWork2+TEOrdBagExt())
ENDIF

If lIntDraw  .And.  lMUserEDC
   oMUserEDC:Fim()    // PLB 27/11/06 - Solta registros presos e reinicializa objeto
EndIf

//AOM - 07/04/11
If lOperacaoEsp
   oOperacao:DeleteWork()
EndIf

Return .T.


*----------------------------------------------------------------------------
Function GI400WorkEstorno(bMsg,MTotal)
*----------------------------------------------------------------------------

SW5->(DBSEEK(xFilial()+SW4->W4_PGI_NUM))
WHILE .NOT. EOF() .AND. SW5->W5_PGI_NUM == SW4->W4_PGI_NUM .AND. SW5->W5_FILIAL== xFilial("SW5")

  Eval(bMsg,STR0036+SW5->W5_COD_I+; //"Processando Item "
            STR0037+TRANSFORM(SW5->W5_PO_NUM,_PictPO)) //" - P.O. "

  MConta++
  //*FSY, AAF - 07/10/2013 - Ajustado para validação do estorno.
  IF SW5->W5_SEQ <> 0
     IF ASCAN(aSeqLi,SW5->W5_SEQ_LI) == 0 .AND. ! EMPTY(SW5->W5_SEQ_LI)
        AADD(aSeqLi,SW5->W5_SEQ_LI)
     ENDIF
  //*FSY
     DBSKIP() ;  LOOP
  ENDIF

  DBSELECTAREA("Work")
  Work->(DBAPPEND())
  //AOM - 08/04/2011
  AVREPLACE("SW5","Work")
  If lOperacaoEsp
     Work->W5_DESOPE := POSICIONE("EJ0",1,xFilial("EJ0")+ SW5->W5_CODOPE ,"EJ0_DESC")
  EndIf
  Work->WKCOD_I    :=   SW5->W5_COD_I
  Work->WKFABR     :=   SW5->W5_FABR
  Work->WKFORN     :=   SW5->W5_FORN
  Work->WKREG      :=   SW5->W5_REG
  Work->WKFLUXO    :=   SW5->W5_FLUXO
  Work->WKQTDE     :=   SW5->W5_QTDE
  Work->WKPRECO    :=   SW5->W5_PRECO
  Work->WKSALDO_Q  :=   SW5->W5_SALDO_Q
  Work->WKCC       :=   SW5->W5_CC
  Work->WKSI_NUM   :=   SW5->W5_SI_NUM
  Work->WKPO_NUM   :=   SW5->W5_PO_NUM
  Work->WKDT_EMB   :=   SW5->W5_DT_EMB
  Work->WKDT_ENTR  :=   SW5->W5_DT_ENTR
  Work->WKRECNO_IG :=   SW5->(RECNO())
  Work->WKSEQ_LI   :=   SW5->W5_SEQ_LI
  Work->WKPOSICAO  :=   SW5->W5_POSICAO  //AWR 10/02/99
  Work->WKFLAG     :=   .F.
  Work->WK_EX_NCM  :=   SW5->W5_EX_NCM
  Work->WK_EX_NBM  :=   SW5->W5_EX_NBM

  //FSM - 31/08/2011 - "Peso Bruto Unitário"
  If lPesoBruto
   Work->WKW5PESOBR := SW5->W5_PESO_BR
  EndIf
  If AvFlags("RATEIO_DESP_PO_PLI")
   Work->WKFRETE := SW5->W5_FRETE
   Work->WKSEGUR := SW5->W5_SEGURO
   Work->WKINLAN := SW5->W5_INLAND
   Work->WKDESCO := SW5->W5_DESCONT
   Work->WKPACKI := SW5->W5_PACKING
  EndIf
  MTotal+=(Work->WKQTDE * Work->WKPRECO)
  Work->TRB_ALI_WT:= "SW5"
  Work->TRB_REC_WT:= SW5->(Recno())
  E_ItFabFor(,SW4->W4_PROD_SU,"LI") // posiciona SB1 atualiza descricao do item p/ gi, nome
               // reduzido do fabricante e do fornecedor

  // Work->WKPESO_L :=  If(SW5->W5_PESO==0,SB1->B1_PESO,SW5->W5_PESO)//FCD 04/07/2001
  Work->WKPESO_L := If(SW5->W5_PESO==0,B1Peso(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ")),SW5->W5_PESO)//RA - 14/10/03 - O.S. 1030/03
  Work->WKFAMILIA :=  SB1->B1_FPCOD
  If EICLoja()
     Work->W5_FABLOJ:= SW5->W5_FABLOJ
     Work->W5_FORLOJ:= SW5->W5_FORLOJ
  EndIf
  If lIntDraw .and.  Empty(M->W4_ATO_CON)
     Work->WKAC      := SW5->W5_AC
     Work->WKSEQSIS  := SW5->W5_SEQSIS
  EndIf

  IF lMV_EIC_EAI//AWF - 25/06/2014
     aSegUM:=Busca_2UM(SW5->W5_PO_NUM,SW5->W5_POSICAO)
     IF LEN(aSegUM) > 0
        Work->WKUNI    :=aSegUM[1]
        Work->WKSEGUM  :=aSegUM[2]
        Work->WKFATOR  :=aSegUM[3]
        Work->WKQTSEGUM:=Work->WKQTDE*Work->WKFATOR
     ENDIF
  ENDIF

  IF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"19"),)//AWR 10/11/1999
  IF(EasyEntryPoint("ICPADGI2"),ExecBlock("ICPADGI2",.F.,.F.,"PESO_L"),.F.)

  If lInvAnt .And. SW5->(FIELDPOS("W5_INVANT")) > 0 //DRL - 16/09/09 - Invoices Antecipadas
     If !Empty(SW5->W5_INVANT)
        nBasePLI := 1
        WORK->WKINVOIC := SW5->W5_INVANT
        If SW5->W5_PESO == 0
           nxOrdEW5:=EW5->(IndexOrd())
           EW5->(dbSetOrder(2))
           If EW5->(dbSeek(xFilial("EW5")+SW3->W3_PO_NUM+SW3->W3_POSICAO+SW5->W5_INVANT+SW5->W5_FORN+EICRetLoja("SW5","W5_FORLOJ")))
              WORK->WKPESO_L := EW5->EW5_PESOL
           EndIf
           EW5->(dBSetOrder(nxOrdEW5))
        EndIf
     EndIF
  EndIf

  IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"WKDESPESAS"),.F.)

  DBSELECTAREA("SW5")
  SW5->(DBSKIP())

ENDDO
Return .T.

*--------------------------*
FUNCTION GI410_Marca(lTodos)
*--------------------------*
Local nRecord:=RECNO(), nSeq_Li:=WKSEQ_LI, aRecord:={}, nRecord1:=RECNO()
Local nRetorno:=.T., TNro_Pgi:=SW4->W4_PGI_NUM, Wind
Local cSeqItemEmbarcado := ""
Local nCount := 0
Local cSeqNoMarc := ""

IF WKFLAGWIN == cMarca
   IF lTodos
      Work->(DBGOTOP())
      //Work->(DBEVAL( {||Work->WKFLAG:=.F.,Work->WKFLAGWIN:=SPACE(02) })) - NOPADO POR AOM - 09/04/2011 - Tratamento abaixo
      While Work->(!EOF())
         //AOM - 09/04/2011 - Chamar o objeto de OPE ESP
         If !ValidOpeGI("MARCA_ITS_PLI")
            RETURN .F.
         EndIf
         Work->WKFLAG:=.F.
         Work->WKFLAGWIN:=SPACE(02)
      Work->(DbSkip())
      EndDo
   ELSE
      //AOM - 09/04/2011 - Chamar o objeto de OPE ESP
      If !ValidOpeGI("MARCA_ITS_PLI")
         RETURN .F.
      EndIf

      IF EMPTY(Work->WKSEQ_LI)
         Work->WKFLAG:= .F.
         Work->WKFLAGWIN:=SPACE(02)
         RETURN
      ENDIF
      nSeq_Li:=Work->WKSEQ_LI
      Work->(DBSEEK(nSeq_Li))
      DO WHILE ! Work->(EOF()) .AND. Work->WKSEQ_LI == nSeq_Li
         Work->WKFLAG:=.F.
         Work->WKFLAGWIN:=SPACE(02)
         If lTem_DSI.and. nQual == LSI  // JBS - 26/12/2003
            Work->WKFLAGLSI:=  ""
            Work->WKSEQ_LI :=  ""
         EndIf
         Work->(DBSKIP())
      ENDDO
   ENDIF
   Work->(DBGOTO(nRecord))
   RETURN .F.
ENDIF

IF lTodos
   Work->(DBGOTOP())
   DO WHILE ! Work->(EOF())
   		  //WHRS 22/02/17 -TE-4935 501948 / MTRADE-348 VALIDAR SE A ITEM DA LI NÃO SENDO USADO EM UM EMBARQUE
         If !validPliEmbarcada()
            nCount++
         	 cSeqNoMarc += work->WKSEQ_LI + ","
         EndIf
      IF ! EMPTY(Work->WKSEQ_LI)
         EXIT
      ELSE
         //AOM - 09/04/2011 - Chamar o objeto de OPE ESP
         If !ValidOpeGI("MARCA_ITS_PLI")
           RETURN .F.
         EndIf
         Work->WKFLAG:=.T.
         Work->WKFLAGWIN:=cMarca
      ENDIF
      Work->(DBSKIP())
   ENDDO
   	   //WHRS 22/02/17 -TE-4935 501948 / MTRADE-348 VALIDAR SE A ITEM DA LI NÃO SENDO USADO EM UM EMBARQUE
      IF nCount > 0
         cSeqNoMarc := Substr(cSeqNoMarc,1,Len(cSeqNoMarc)-1)
         cSeqItemEmbarcado += STR0379 + cSeqNoMarc + STR0380
         MSGINFO(cSeqItemEmbarcado,STR0062)
         Return .F.
      EndIf
ELSE
	//WHRS 22/02/17 -TE-4935 501948 / MTRADE-348 VALIDAR SE A ITEM DA LI NÃO SENDO USADO EM UM EMBARQUE
   If !validPliEmbarcada()
      cSeqNoMarc += work->WKSEQ_LI
   	   cSeqItemEmbarcado += STR0379 + cSeqNoMarc + STR0380
      MSGINFO(cSeqItemEmbarcado,STR0062)
      Return .F.
   EndIf
   IF EMPTY(nSeq_Li)
      //AOM - 09/04/2011 - Chamar o objeto de OPE ESP
      If ValidOpeGI("MARCA_ITS_PLI")
         Work->WKFLAG:=.T.
         Work->WKFLAGWIN:=cMarca
         RETURN
      EndIf
      nRetorno := .F.
   ENDIF
   Work->(DBSEEK(nSeq_Li))
ENDIF

SWP->(DBSETORDER(1)) // RJB 21/07/2004

DO WHILE ! EOF()
   IF SWP->(DBSEEK(xFilial()+TNro_Pgi+Work->WKSEQ_LI))
      /*
      TDF - 21/12/2010

      IF ! EMPTY(SWP->WP_NR_MAQ) .AND. EMPTY(SWP->WP_MICRO)
         HELP("",1,"AVG0000405") //"Atenção! para estornar esta P.L.I. processo não tem número de micro"
         RETURN .F.
         Work->(DBSKIP()) ; LOOP
      ENDIF
      */
      lCom_Regist:=.T.
      IF ! EMPTY(SWP->WP_REGIST)
         lCom_Regist:=.F.
      ENDIF
      nSeq_Li:=Work->WKSEQ_LI; lMsg_Dada:=.F.
      DO WHILE ! Work->(EOF()) .AND. Work->WKSEQ_LI == nSeq_Li
         IF lCom_Regist
            IF ASCAN(aSeqLi,Work->WKSEQ_LI) # 0
               IF ! lMsg_Dada
                  HELP("",1,"AVG0000406",,nSeq_Li,3,05)
                  lMsg_Dada:=.T.
                  //NCF - 08/08/2011 - Classificação N.V.A.E na PLI
                  If lCposNVAE .And. Work->(FieldPos("WKNVE"))>0 //LGS-12/05/2015
                     IF ASCAN(aTabsNVE,Work->WKNVE) == 0
                        aAdd(aTabsNVE,Work->WKNVE)
                     EndIf
                  EndIf
                  RETURN .F.
               ENDIF
               Work->(DBSKIP()) ; LOOP
            ENDIF
         ENDIF
         AADD(aRecord,Work->(RECNO()))
         Work->(DBSKIP())
      ENDDO
      nRecord:=Work->(RECNO())
      FOR Wind = 1 TO LEN(aRecord)
          Work->(DBGOTO(aRecord[wind]))
          Work->WKFLAG:=.T.
          Work->WKFLAGWIN:=cMarca
      NEXT
      Work->(DBGOTO(nRecord))
   ELSE
      Work->(DBSKIP())
   ENDIF
   IF ! lTodos
      Work->(DBGOTO(nRecord1))
      RETURN .T.
   ENDIF
ENDDO
Work->(DBGOTO(nRecord1))

RETURN nRetorno

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³......... ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 20.09.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Conjunto de funcoes originarias do GI400                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC  / V407                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
*--------------------------------------------------------------------------*
FUNCTION GI_Create(WFlag)
*--------------------------------------------------------------------------*
// VARIAVEIS PARA A TELA HUM
PRIVATE TNro_Pgi , TNro_Gi  , TPos    , TSuframa  , TEmis_Bf , TTipo_Comm,;
        TVal_Comm, TOut_Comm, TTipoDoc, TTipoAplic, TProdSuf , dDtLibera

TPacking  := TInland    := TOutDesp  := TDesconto  := TFreteIntl := TSeguro := 0
MDesconto := MInland    := MPacking  := MFreteIntl := MSeguro    := TPeso_L := TPeso_B := 0
TFretIte := TSeguIte := TInlaIte := TDescIte := TPackIte := 0
TTipo_Comm := TVal_Comm := 0

TOut_Comm := SPACE(20)
TProdSuf  := SPACE(08)
TEmis_Bf  := SPACE(01)
TNro_Pgi  := M->W4_PGI_NUM
TSuframa  := M->W4_SUFRAMA
cCondicao := M->W4_COND_ME
TDt_Pgi   := dDataBase
TDesc_Ger := ''
TTipoDoc  := ' '
TTipoAplic:= '  '
TPos      := SPACE(20)

// VARIAVEIS PARA A TELA DOIS
PRIVATE Po_Import:=Po_Origem:=Po_PProcedencia:="", lTemFlag:=.F.

// VARIAVEIS PARA A TELA TRES
PRIVATE TSaldo_Q, TFobUnit, TDt_Emb, TDt_Ent, TPeso, cAc:="", cSeqSis:="" , cCodOpe := ""
TSaldo_Q     := TFobUnit   := TPeso_L
TDtEmbarque  := AVCTOD(SPACE(08))
TDtEntrega   := AVCTOD(SPACE(08))
MSalvaFilter := SPACE(01)
MTabPO:={}

DO WHILE .T.
   ASIZE(MTabPO,0)

   MControla:= .T. ; MControle:= .T.
   MTotal   := 0  //; MTotPeso := 0

   RETURN G_Tela1(1,WFlag)
ENDDO
RETURN NIL

*----------------------------------------------------------------------------
FUNCTION G_Tela1(MChamada,WFlag)
*----------------------------------------------------------------------------
Local lTemItAprop := .F.                                    //NCF - 30/03/11
Local cOldFilter := ""                                      //NCF - 05/04/11
IF (MChamada = 1 .AND. lSelPO) .OR. Work->(EasyRecCount("Work")) == 0
   TPacking := TFreteIntl := TInland:=TOutDesp:=TSeguro:=0
   TPorta_Dt    := AVCTOD(SPACE(08))
   TDesc_Ger    := TObs          := TTexto34 := ''
   TDesconto    := 0

   MForn     := SPACE(LEN(SW2->W2_FORN))
   cExporta  := SPACE(06)
   MMoeda    := SPACE(03)
   MIncoterm := SPACE(03)

   //AOM - 09/08/2011 - Nao considera a cond pgto qndo é LI simplificada
   IF lIntDraw .And. EMPTY(M->W4_COND_PA) .AND. !isInCallStack("GI400LSI_MAIN")                  //NCF - 30/03/11 - Quando integrado ao Drawback deve ser informada a condição de pagamento
      MsgInfo(STR0241)
      Return .F.
   ENDIF
   IF !lIntDraw                                             //NCF - 30/03/11 - Quando integrado ao Drawback, a condição de pagamento do item apropriado deve
      MCond_Pag := SPACE(05)                                //                 ser validada diante da condição da PLI e não do PO.
      MDias_Pag := 0
   ELSE
      MCond_Pag := M->W4_COND_PA
      MDias_Pag := M->W4_DIAS_PA
      TLastCondPG := TCondPgto
      TCondPgto := M->W4_COND_PA
   ENDIF

   If EICLoja()
      cExportLoj:= SPACE(LEN(SW2->W2_EXPLOJ))
      MFornLoja := SPACE(LEN(SW2->W2_FORLOJ))
   EndIf
   MChamada:= 2
   IF lIntDraw .And. TLastCondPG <> TCondPgto .And. Work->(EasyRecCount("Work")) <> 0   //NCF - 30/03/11 - Validação para alteração na condição de pagamento da PLI
      cOldFilter := Work->(DbFilter())
      Work->(DbClearFilter())
      Work->(DbGoTop())
      Do While Work->(!Eof())
         IF !EMPTY(Work->WKAC)
            lTemItAprop := .T.
            Exit
         ENDIF
         Work->(DbSkip())
      EndDo
      Work->(DbSetFilter({||&cOldFilter},cOldFilter))
      If lTemItAprop
         If !MsgYesNo(STR0242+CHR(13)+CHR(10)+STR0243+CHR(13)+CHR(10)+STR0244+CHR(13)+CHR(10)+STR0245)
            M->W4_COND_PA := TLastCondPG
         Else
            G_Tela2(1,WFlag)
         Endif
      EndIf
   ELSE
      G_Tela2(1,WFlag)
   ENDIF
ELSE
   IF lIntDraw .And. TLastCondPG <> TCondPgto .And. Work->(EasyRecCount("Work")) <> 0   //NCF - 30/03/11 - Validação para alteração na condição de pagamento da PLI
      cOldFilter := Work->(DbFilter())
      Work->(DbClearFilter())
      Work->(DbGoTop())
      Do While Work->(!Eof())
         IF !EMPTY(Work->WKAC)
            lTemItAprop := .T.
            Exit
         ENDIF
         Work->(DbSkip())
      EndDo
      Work->(DbSetFilter({||&cOldFilter},cOldFilter))
      If lTemItAprop
         If !MsgYesNo(STR0242+CHR(13)+CHR(10)+STR0243+CHR(13)+CHR(10)+STR0244+CHR(13)+CHR(10)+STR0245)
            M->W4_COND_PA := TLastCondPG
         Else
            G_Tela2(2,WFlag)
         Endif
      EndIf
   ELSE
      G_Tela2(2,WFlag)
   ENDIF
ENDIF
   IF MControla = .F.
      DBSELECTAREA("SW2")
      MsUnlock()
      RETURN .T.
   ENDIF
RETURN .F.

*----------------------------------------------------------------------------
FUNCTION G_Tela2(MChamada)
*----------------------------------------------------------------------------
LOCAL   nOpca, cTit:=OemToAnsi(STR0042) //'N§ P.O.   '
LOCAL lValidPO:=.F., cImpCons,cImport
LOCAL bPaint:={||oMark:oBrowse:Refresh(),oMark:oBrowse:Reset()}
LOCAL _IniPO := SPACE(LEN(SW7->W7_PO_NUM))
LOCAL _LIT_CC := AVSX3("W0__CC")[5]
LOCAL _PictItem := ALLTRIM(X3PICTURE("B1_COD"))
LOCAL _PictSI   := ALLTRIM(X3PICTURE("W0__NUM"))
LOCAL _PictTec  := ALLTRIM(X3PICTURE("B1_POSIPI"))
LOCAL DataVazia := AVCTOD("  /  /  ")
LOCAL lSuframa := IF (AvFlags("SUFRAMA")  .AND. !EMPTY(M->W4_PROD_SU),.T.,.F.)
LOCAL bBotMonta := bOK_GI := {||nOpcGI:=1,oDlg:End()}        // JBS 10/12/2003
LOCAL bCancel_GI:= {||MControla:=.F.,oDlg:End()}   // JBS 10/12/2003
LOCAL lMensagem := .F.
LOCAL nOpBase:=0, oDlgBase, nxOrdEW5 //DRL - 18/09/09 - Invoices Antecipadas
Private cFilEW5 := xFilial("EW5")
Private aBotoesLSI:= {}
Private oPanSelItem // LRL 23/03/04
Private oDlg ,oMark // Por causa dos Rdmakes
Private nQtdAux, cUnid, nQtdNcmAux,lLaco:=.T., lAlt_Botao := .T.
Private cFilSW2 := xFilial("SW2"), cFilSW5 := xFilial("SW5") //Usado no Rdmake da Embraer. - TAN
Private nOrderWK := 3

If lTem_DSI  // JBS 09/12/2003
   lMensagem:=.T.    // Mostra Mensagem se não tiver item Marcado no PO
   If (SWP->WP_LSI == "1".and.(nQual == ALTERACAO .or.nQual == VISUAL)).or. nQual == LSI //6

      lVisual    := (nQual == VISUAL)  //2
      lAlt_Botao := nQual == ALTERACAO //nQual <> LSI .and. SWP->WP_LSI <> "1"

      bBotMonta:={|| if(Gi400ItemMArcados(lMensagem,.T.),(nOpcGI:=1,oDlg:End()),)} // JBS 10/12/2003
      AADD(aBotoesLSI,{"BUDGET" ,{|| if(Gi400ItemMArcados(lMensagem),if(GI400LSI(nQual),oDlg:End(),),)},STR0017,STR0206})//STR0017 "Manutencao de LSI" //  "SLI" //

      IF lVisual
         nQual := ALTERACAO
      ELSE
         AADD(aBotoesLSI,{"NEXT",bBotMonta,STR0060,nil }) //STR060 Monta LI
      ENDIF
      bOK_GI:= {|| if(Gi400ItemMArcados(lMensagem),if(GI400LSI(nQual),(nOpcGI:=1,oDlg:End()),),)}  //AOM - 09/08/2011
   EndIf
Endif

// FDR - 12/12/2011 - Tratamento de inclusão dos botões no Ações Relacionadas
AADD(aBotoesLSI,{"PESQUISA",{||EICGI400DESC(nQual)},STR0149,STR0149  })

If nQual == 3 //.OR. nQual == 6
   AADD(aBotoesLSI,{"RESPONSA",{||GI400MarcAll()},STR0034/*,STR0199*/  })
Endif

AADD(aBotoesLSI,{"BMPORD1",{||GI400OrdOpt(oDlg)},STR0276,STR0276 })

//IF nQual == INCLUSAO //NCF - 08/05/2018 - Permitir a manutenção de NVE também na alteração
   //NCF - 08/08/2011 - Classificação N.V.A.E na PLI
   IF lCposNVAE    
      AADD(aBotoesLSI,{"produto",{|| (GI400NVE(oDlg,nQual),Work->(DBGOTOP()),oMark:oBrowse:Refresh())},STR0378,STR0378}) //"Classificacao NVE"
   EndIf            
//ENDIF

//Botões//LRS - 30/05/2017
If nQual # ALTERACAO
  If nBasePli <> 1
      AAdd(aBotoesLSI,{,{|| MControla:=.T.,oDlg:End()}, STR0357, STR0357}) //Adicionar P.O.
      AAdd(aBotoesLSI,{,bBotMonta, STR0060, STR0060}) //Montar L.I.
      AAdd(aBotoesLSI,{,{||GI_Altera()}, STR0219, STR0219}) //"Alterar NCM."

      If lIntDraw .and. Empty(M->W4_ATO_CON) .And. lMostraAC
        AAdd(aBotoesLSI,{,{||MsAguarde({|| GI400ApuraAC("I")},STR0178)}, STR0157, STR0157}) //Apropriar A.C.
      EndIf
  EndIf
Else
  If lAlt_Botao
      AAdd(aBotoesLSI,{,{||GI_Altera()}, STR0219, STR0219}) //"Alterar NCM."
  EndIf
  If lIntDraw .And. Empty(M->W4_ATO_CON) .And. lMostraAC 
      AAdd(aBotoesLSI,{,{|| GI400AltAC(.F.)}, STR0169, STR0169}) //"Alterar A.C."
      AAdd(aBotoesLSI,{,{||MsAguarde({|| GI400ApuraAC("A")},STR0178)}, STR0157, STR0157}) //"Apropriar A.C."
      AAdd(aBotoesLSI,{,{||MsAguarde({|| GI400AltAC(.T.)}          )}, STR0352, STR0352}) //"Desapropriar A.C."
  EndIf
  SWP->(DBSetOrder(1))
  SWP->(DBSeek(xFilial("SWP")+Work->WKPGI_NUM+Work->WKSEQ_LI))
  If Empty(SWP->WP_REGIST)
      //DFS - 18/10/11 - Inclusão do botão alterar na enchoicebar da PLI quando não for enviado ao Siscomex
      AADD(aBotoesLSI,{"EDIT",{||G_Tela3(.T.,.T.)},STR0008, STR0008})//"Alterar","Alterar"
  EndIf
EndIf

aCampos:={}

DO WHILE .T.
   IF MChamada = 1
      TPo_Num:= _IniPO
      MTotal2:= 0
      nLin1:=0.4
      nCol1:=0.8
      nCol2:=5

      IF lInvAnt .And. nQual # 4 //DRL - 17/09/09 - Invoices Antecipadas
			IF !lSelec_Base
				nBasePli := 1
				DEFINE MSDIALOG oDlgBase TITLE STR0304 FROM 09,10 TO 17,48 OF oMainWnd//STR0304 "Base da PLI
				@	0.2, 0.3 TO	    4.2,18.9 OF oDlgBase
				@	015, 010 RADIO  nBasePLI ITEMS STR0251,STR0252 3D SIZE 60,13 //STR0251 "Invoice Antecipada" //STR0252 "PO"
				@	04.2,021 BUTTON STR0200 SIZE 30,11 ACTION (nOpBase:=1,oDlgBase:End()) OF oDlgBase // OK
				@	04.2,029 BUTTON STR0201 SIZE 30,11 ACTION (nOpBase:=0,oDlgBase:End()) OF oDlgBase // CANCELAR
				ACTIVATE	MSDIALOG	oDlgBase	CENTERED
				//
				If nOpBase == 0
					nBasePLI := 0
					RETURN NIL
				ENDIF
				//
				lSelec_Base := .T.
				//ACB - 13/01/2011 - Nopado pois ao selecione o PO ele sempre volta para a tela principal para depois
				//selecione o PO
			   /*	IF nBasePLI <> 1
					RETURN NIL
				ENDIF*/
			ENDIF
			IF LEN(mTabPO) == 0 .AND. nBasePLI == 1
				GI400SelInv()
			ENDIF
		ENDIF

      IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"BASE_DA_PLI"),)
      IF nBasePLI == 0
         EXIT
      ELSEIF nBasePLI <> 1
         DO WHILE .T.

            dIniEmb:=dFimEmb:=AVCTOD("")
            WORK->(DBSETORDER(2))
            nOpca:=0
            If nQual # 4

               IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"INICIA_VARIAVEIS"),)

               DEFINE MSDIALOG oDlg TITLE STR0043 From 9,0 To 20,75 OF oMainWnd//"Selecao de P.O."

               oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 21, 50)
               oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

               IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"TELA_GET_PO"),)

               @ nLin1,nCol1 SAY cTit SIZE 40,8 OF oPanel
               @ nLin1,nCol2 MSGET TPO_Num F3 "SW2" PICTURE _PictPO VALID GI400PO(TPo_Num) OF oPanel SIZE 80,10
               nLin1++

               @ nLin1,nCol1 SAY   STR0044 SIZE 35,8  OF oPanel//"Emb. Inicial"
               @ nLin1,nCol2 MSGET dIniEmb  SIZE 50,8 OF oPanel
               nLin1++
               @ nLin1,nCol1 SAY   STR0045   SIZE 35,8 OF oPanel//"Emb. Final"
               @ nLin1,nCol2 MSGET dFimEmb  SIZE 50,8  OF oPanel VALID (IF(E_Periodo_Ok(@dIniEmb,@dFimEmb).AND.GI_ValidPO(),(nOpca:=1),))

               ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,;
                        {||nOpca:=1,IF(E_Periodo_Ok(@dIniEmb,@dFimEmb) .AND. GI_ValidPO(),oDlg:End(),)},;
                        {||nOpca:=0,oDlg:End()}) CENTERED
            Else
               MsAguarde({|lEnd| GI_GravaWork({|msg| MsProcTxt(msg)}) },STR0018)
               nOpca:=1
            EndIf

            If nOpca = 0
               DBSELECTAREA("SW2")
               MsUnlock()
               RETURN .F.
            Endif

            DBSELECTAREA("Work")
            EXIT
         ENDDO
      EndIf
   ELSE
      IF EMPTY( TPo_Num )
         DBSELECTAREA("Work")
         Work->(DBGOBOTTOM())
         WHILE ! Work->(BOF())
            IF Work->WKFLAG
               TPo_Num:= Work->WKPO_NUM
               EXIT
            ENDIF
            Work->(DBSKIP(-1))
         ENDDO
      ENDIF
   ENDIF

   DBSELECTAREA("Work")
   Work->(DBSETORDER(nOrderWK))

   If nQual # ALTERACAO   .And. nBasePLI <> 1
      SET FILTER TO WKPO_NUM = TPo_Num
   EndIf
   Work->(DBGOTOP()) // RHP

   If nQual # ALTERACAO
      AADD(aCampos,{"WKFLAGWIN"  ,"",""})
   Endif
   AADD(aCampos,{"WKTEC"   ,"",STR0046,_PictTEC}) //"TEC"
   AADD(aCampos,{"WK_EX_NCM","",STR0047}) //"Ex-NCM"
   AADD(aCampos,{"WK_EX_NBM","",STR0048}) //"Ex-NBM"
   AADD(aCampos,{"WKCC"    ,"",_LIT_CC})
   AADD(aCampos,{"WKSI_NUM","",OemToAnsi(STR0049),_PictSI}) //"N§ S.I."
   AADD(aCampos,{"WKPOSICAO"  ,"",STR0022}) //AWR 10/02/99 //"Posi‡Æo"
   AADD(aCampos,{"WKCOD_I"    ,"",STR0023,_PictItem}) //"Item"
   AADD(aCampos,{"WKPART_N"   ,"",STR0050}) //"Part Number"

   IF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"20"),)//AWR 10/11/1999
   If EasyEntryPoint("EICGI400")                      //TAN 25/06/02
      ExecBlock("EICGI400",.F.,.F.,"APROPRIAAC")
   Endif

   AADD(aCampos,{"WKFAMILIA"  ,"",STR0024}) //"Fam¡lia"
   AADD(aCampos,{"WKDESCR"    ,"",STR0051}) //"Descri‡Æo p/ L.I."
   AADD(aCampos,{{||Work->WKFABR+' '+Work->WKNOME_FAB},"",STR0026}) //"Fabricante"

   IF EICLOJA()
      EICAddLoja(aCampos, "W5_FABLOJ",, STR0026)
   ENDIF

   AADD(aCampos,{{||Work->WKFORN+' '+Work->WKNOME_FOR},"",STR0028}) //"Fornecedor"

    IF EICLOJA()
      EICAddLoja(aCampos, "W5_FORLOJ",, STR0028)
   ENDIF

   AADD(aCampos,{"WKPRECO"    ,"",STR0031,_PictPrUn}) //"Pre‡o Unit rio"
   AADD(aCampos,{"WKPRTOT"    ,"",OemToAnsi(STR0052),_PictPrUn}) //"Pre‡o Total"
   IF lMV_EIC_EAI//AWF - 30/06/2014
      AADD(aCampos,{"WKQTDE"    ,"",STR0029,_PictQtde}               ) //"Quantidade"//AWF - 30/06/2014
      AADD(aCampos,{"WKUNI"    ,"",AVSX3("W3_UM"     ,AV_TITULO)})
      AADD(aCampos,{"WKQTSEGUM","",AVSX3("W3_QTSEGUM",AV_TITULO),AVSX3("W3_QTSEGUM" ,6)})
      AADD(aCampos,{"WKSEGUM"  ,"",AVSX3("W3_SEGUM"  ,AV_TITULO)})
      AADD(aCampos,{"WKFATOR"  ,"","Fator Conv 2UM"  ,AVSX3("J5_COEF",6) })
   ENDIF
   AADD(aCampos,{"WKSALDO_Q"  ,"",STR0053,_PictQtde}) //"Saldo Qtde"
   AADD(aCampos,{"WKPESO_L"   ,"",STR0054,AVSX3("W5_PESO",6)}) //"Peso Unit rio"      //TRP-28/02/08

   //FSM 31/08/2011 - "Peso Bruto Unitário"
   If lPesoBruto
      AADD(aCampos,{"WKW5PESOBR" ,"",AVSX3("W5_PESO_BR",AV_TITULO), AVSX3("W5_PESO_BR",AV_PICTURE)}) //"Peso Bru Uni"
   EndIf
   If AvFlags("RATEIO_DESP_PO_PLI")
      AADD(aCampos,{"WKFRETE" ,"",AVSX3("W5_FRETE",AV_TITULO),AVSX3("W5_FRETE",AV_PICTURE)}) //"Frete"
      AADD(aCampos,{"WKSEGUR","",AVSX3("W5_SEGURO",AV_TITULO),AVSX3("W5_SEGURO",AV_PICTURE)}) //"Seguro"
      AADD(aCampos,{"WKINLAN","",AVSX3("W5_INLAND",AV_TITULO),AVSX3("W5_INLAND",AV_PICTURE)}) //"Inland"
      AADD(aCampos,{"WKDESCO","",AVSX3("W5_DESCONT",AV_TITULO),AVSX3("W5_DESCONT",AV_PICTURE)}) //"Desconto"
      AADD(aCampos,{"WKPACKI","",AVSX3("W5_PACKING",AV_TITULO),AVSX3("W5_PACKING",AV_PICTURE)}) //"Packing"
   EndIf
   AADD(aCampos,{"WKDT_EMB","",STR0032}) //"Embarque"
   AADD(aCampos,{"WKDT_ENTR","",STR0033}) //"Entrega"
   If lIntDraw .and. Empty(M->W4_ATO_CON) .and. lMostraAC
      AADD(aCampos,{"WKAC"      ,"",AVSX3("ED0_AC",5)}                   ) //"Ato Concessorio"
   EndIf

   //AOM - 08/04/2011
   If lOperacaoEsp
      AADD(aCampos,{"W5_CODOPE" ,"",AVSX3("W5_CODOPE",5)})
      AADD(aCampos,{"W5_DESOPE" ,"",AVSX3("W5_DESOPE",5)})
   EndIf

   //NCF - 08/08/2011 - Classificação N.V.A.E na PLI
   If lCposNVAE
       AADD(aCampos,{"WKNVE","","Tab N.V.E"})
   EndIf

   //GFP 20/10/2010
   aCampos := AddCpoUser(aCampos,"SW5","2")

   nBrowse:=2
   If lInvAnt .And. nBasePLI == 1 //DRL - 16/09/09 - Invoices Antecipadas
      ASIZE(aCampos, Len(aCampos)+1)
      nxPosBrw := If(nQual==4,04,05)
      aIns(aCampos,nxPosBrw)
      aCampos[nxPosBrw] := {"WKINVOIC","","Inv.Antecip."}
   EndIf
   IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"BROWSE"),)//CES 28/08/01

   Do While .T.
    Work->(DBGOTOP()) // RHP
      oMainWnd:ReadClientCoors()
      DEFINE MSDIALOG oDlg TITLE STR0055  ;         //"Sele‡Æo de Itens"
             FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
               OF oMainWnd PIXEL

      @01,01 MsPanel oPanSelItem Prompt "" Size 25,45 of oDlg

      If lInvAnt .And. (nQual # 4 .AND. nBasePLI == 1) ////DRL - 17/09/09 - Invoices Antecipadas
         @1.4,0.6 SAY STR0068          SIZE 40,08 OF oPanSelItem //STR0068 "No. P.L.I."
         @1.4,8.0 MSGET M->W4_PGI_NUM       WHEN .F.    SIZE 40,08 OF oPanSelItem
         @2.4,0.6 SAY STR0251  SIZE 60,08  OF oPanSelItem // STR0251 "Invoice Antecipada"
         @2.4,8.0 MSGET TInv_Ant            WHEN .F.    SIZE 60,08  OF	oPanSelItem
         @18,(oDlg:nClientWidth-6)/2-100	BUTTON	STR0253 SIZE 40,11 ACTION ( Gi400SelInv() ) of oPanSelItem PIXEL //STR0253 "Muda Invoice"
         @18,(oDlg:nClientWidth-6)/2-50		BUTTON	STR0060 SIZE 40,11 ACTION ( nOpcGI:=1,oDlg:End() ) of oPanSelItem PIXEL // STR0060 "Monta LI"
      ENDIF

      IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"ALTERA_TELA_ITEM"),)
      If nQual # ALTERACAO
          IF nBasePli <> 1
             @0.4,0.6 SAY STR0056 SIZE 40,8 OF oPanSelItem //'No. P.O.'
             @0.4,5.0 MSGET TPo_Num PICTURE _PictPO WHEN .F.   SIZE 70,7 OF oPanSelItem

             SYT->(DBSEEK(xFILIAL()+TImport))
             cImport:=TImport+" - "+LEFT(SYT->YT_NOME,15)
             @1.4,0.6 SAY STR0057  FONT oDlg:oFont SIZE 45,8 OF oPanSelItem //"Importador "
             @1.4,5.0 MSGET cImport WHEN .F. SIZE 85,8 OF oPanSelItem
             SYT->(DBSEEK(xFILIAL()+TConsig))
             cImpCons:=TConsig+" - "+LEFT(SYT->YT_NOME,15)
             @1.4,17  SAY STR0058 FONT oDlg:oFont SIZE 45,8 OF oPanSelItem //"Consignatario"
             @1.4,22  MSGET cImpCons WHEN .F.    SIZE 85,8 OF oPanSelItem
             @2.4,0.6 SAY STR0044 SIZE 40,8 OF oPanSelItem //"Emb. Inicial"
             @2.4,17  SAY STR0045 SIZE 40,8 OF oPanSelItem //"Emb. Final"
             dAuxIniEmb:=IF(dIniEmb==AVCTOD("01/01/"+_FirstYear),DataVazia,dIniEmb)
             @2.4,5  MSGET dAuxIniEmb SIZE 35,8 OF oPanSelItem WHEN .F.
             dAuxFimEmb:=IF(dFimEmb==AVCTOD("31/12/2999"),DataVazia,dFimEmb)
             @2.4,22 MSGET dAuxFimEmb SIZE 35,8 OF oPanSelItem WHEN .F.
             //@8,(oDlg:nClientWidth-6)/2-80 BUTTON STR0059 SIZE 40,11 ACTION (MControla:=.T.,oDlg:End())  OF oPanSelItem  PIXEL //"Muda P.O." - identidade visual
             //@8,(oDlg:nClientWidth-6)/2-40 BUTTON STR0060 SIZE 40,11 ACTION (EVAL(bBotMonta)) OF oPanSelItem PIXEL //"Monta LI" - identidade visual

             IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"PESQUI"),)
             /* Identidade visual
             If lIntDraw .and. Empty(M->W4_ATO_CON) .And. lMostraAC
                @24,(oDlg:nClientWidth-6)/2-80 BUTTON STR0157 SIZE 40,11 ACTION MsAguarde({||GI400ApuraAC("I")},STR0178) OF oPanSelItem PIXEL //"Apropria A.C." # //Apropriando A.C.
             EndIf*/
          EndIf
      Else
          @0.4,0.6 SAY 'No. P.L.I.' SIZE 40,8  OF oPanSelItem
          @0.4,5.0 Say M->W4_PGI_NUM Size 40,8 OF oPanSelItem

          IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"ALT_BOTAO"),)

          /* Identidade visual
          IF lAlt_Botao
             @8,(oDlg:nClientWidth-6)/2-80 BUTTON STR0219 SIZE 40,11 ACTION (GI_Altera()) OF oPanSelItem PIXEL //"Alterar NCM." - identidade visual
          ENDIF

          If lIntDraw .And. Empty(M->W4_ATO_CON) .And. lMostraAC
             @8, (oDlg:nClientWidth-6)/2-40 BUTTON STR0169 SIZE 40,11 ACTION (GI400AltAC(.F.)) OF oPanSelItem PIXEL //"Alterar A.C."
             @24,(oDlg:nClientWidth-6)/2-80 BUTTON STR0157 SIZE 40,11 ACTION MsAguarde({||GI400ApuraAC("A")},STR0178) OF oPanSelItem PIXEL //"Apropria A.C." # //Apropriando A.C.
             @24,(oDlg:nClientWidth-6)/2-40 BUTTON STR0352 SIZE 40,11 ACTION MsAguarde({||GI400AltAC(.T.)},STR0355) OF oPanSelItem PIXEL //"Desapropria A.C."  // GFP - 28/04/2014
          EndIf*/
      EndIf

      IF(lSuframa .AND. EasyEntryPoint("EICGI333").And.nQual # 4,ExecBlock("EICGI333",.F.,.F.,"BOTAO"),)//RHP 12/09/00
      If nQual # ALTERACAO
         oMark:= MsSelect():New("Work","WKFLAGWIN",,aCampos,@lInverte,@cMarca,{56,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2})
         oMark:bAval:={|| G_Tela3(),EVAL(bPaint)}
         IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"BAVAL"),)
      Else
         oMark:= MsSelect():New("Work",,,aCampos,@lInverte,@cMarca,{45,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2})

         SWP->(DBSetOrder(1))
         SWP->(DBSeek(xFilial("SWP")+Work->WKPGI_NUM+Work->WKSEQ_LI))
         If !Empty(SWP->WP_REGIST)
            // Peso do item não pode ser alterado pois a LI já foi enviada ao SISCOMEX
            oMark:bAval:={||EICGI400DESC(nQual)}
         Else
            //NCF - 12/01/2010 - Alteração somente do peso
            oMark:bAval:={|| G_Tela3(.T.),EVAL(bPaint)}
            //DFS - 18/10/11 - Inclusão do botão alterar na enchoicebar da PLI quando não for enviado ao Siscomex
            //AADD(aBotoesLSI,{"EDIT",{||G_Tela3(.T.,.T.)},STR0008, STR0008})//"Alterar","Alterar" - movido para fora do while
         EndIf
      EndIf

      oPanSelItem:Align:=CONTROL_ALIGN_TOP       //LRL 23/03/04
      oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //Alinhamento MDI

	   	//AAdd(aBotoesLSI,{,{||GI_Altera()}, STR0219, STR0219}) //"Alterar NCM."

      nOpcGI:=0
      MControla:=.F.
      Work->(DBGOTOP())
      ACTIVATE MSDIALOG oDlg ON INIT (Enchoicebar(oDlg,bOK_GI,BCancel_GI,,aBotoesLSI), oMark:oBrowse:Refresh())

      If nOpcGI == 1
         lLaco := .T.

         //--- Verifica se foi solicitada a LI para todos os produtos com anuência
         //    com sua quantidade TOTAL da Commercial Invoice (quando a PLI for
         //    montada com base na Invoice Antecipada).
         If lInvAnt .And. nBasePLI == 1 //DRL - 16/09/09 - Invoices Antecipadas
            nxOrdEW5 := EW5->(IndexOrd())
            EW5->(dbSetOrder(2))
            If EW5->(dbSeek(cFilEW5+WORK->WKPO_NUM+WORK->WKPOSICAO+WORK->WKINVOIC+WORK->WKFORN))
               If WORK->WKQTDE <> EW5->EW5_QTDE
                  MsgStop(STR0254) // STR0254 "É necessário solicitar a PLI da quantidade total do produto!"
                  lLaco	:= .F.
               EndIf
            EndIf
            EW5->(dbSetOrder(nxOrdEW5))
         EndIf

         IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"VALID_ITENS_INV"),) //  LDR
         If lLaco
            If  G_Tela4() == 0  //  LDR
                Exit
            Endif
         Endif
      Else
         lLaco := .F.
         IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"VALID_MUDA_PO"),) //  LDR
         If lLaco
            loop
         Endif

         aCampos:={}
         Exit
      Endif
   EndDo

  IF MControle = .F.
     MControla:= .F.
     RETURN .F.
  ENDIF

  IF MControla = .F.
     MControla:= .T.
     RETURN .T.
  ENDIF
  IF nBasePLI <> 1
     SET FILTER TO
     DBGOTOP()
     WHILE ! EOF()
       IF .NOT. WKFLAG
          DBDELETE()
       ENDIF
       DBSKIP()
     ENDDO
  EndIf
  MChamada:= 1

EndDo
*-------------------*
FUNCTION DbuGI400A()
*-------------------*
PARAMETER PModo
lTemFlag := .F.

DO CASE
    CASE PModo < 4
         MRetorno:= 1

    CASE LASTKEY()  = -2
         IF GI_PORTARIA78                // A.C.D.
            Work->(DBGOTOP())
            WHILE ! Work->(EOF())
               IF Work->WKFLAG
                  lTemFlag := .T.
                  EXIT
               ENDIF
               Work->(DBSKIP())
            ENDDO
            IF(!lTemFlag,Po_Import:="",)
         ENDIF
         IF MTotal = 0
            MForn     := SPACE(LEN(SW2->W2_FORN))
            cExporta  := SPACE(06)
            MMoeda    := SPACE(03)
            MIncoterm := SPACE(03)
            mCond_Pag := SPACE(05)
            MDias_Pag := 0
            MTabPo    :={}
            If EICLoja()
               cExportLoj:= SPACE(LEN(SW2->W2_EXPLOJ))
               MFornLoja := SPACE(LEN(SW2->W2_FORLOJ))
            EndIf
         ENDIF
         MRetorno:= 0
    CASE LASTKEY()  = -3 .OR. LASTKEY() = 13
         G_Tela3()
         MRetorno:= 2

    CASE LASTKEY()  = -4
         MControla  = .T.
         MSalvaFilter = TPo_Num
         MRecno     = RECNO()
         SET FILTER TO
         IF ! GI400_LIS()
            MControle:=.F.
            MRetorno :=0
         ELSE
            SET FILTER TO WKFLAG == .T.
            MRetorno:=G_Tela4()
            IF MControla = .T.
               MRetorno = 2
               SET FILTER TO WKPO_NUM = MSalvaFilter
               DBGOTO(MRecno)
            ELSE
               MControle = .F.
               MRetorno  = 0
            ENDIF
         ENDIF


    CASE LASTKEY()  = K_ESC
         IF Abandona()
            MRetorno := 0
            MControla:= .F.
         ELSE
            MRetorno:= 1
         ENDIF

    OTHERWISE
         MRetorno:= 1
ENDCASE

RETURN MRetorno
*----------------------------------------------------------------------------
Function GI400MarcAll()
*----------------------------------------------------------------------------
LOCAL lMarcaNew:=!Work->WKFLAG, lMenErro:=.F.
PRIVATE lDespreza_Itens_All:= .F.

Work->(DBGOTOP())
DO WHILE Work->(!EOF())

   IF EMPTY(Work->WKPESO_L)   // LDR - 31/05/04 - OS 0795/04
      Work->(DBSKIP())
      LOOP
   ENDIF

   IF Work->WKFLAG .AND. !lMarcaNew

      If !ValidOpeGI("MARCATODOS_ITS_PLI")
         lMenErro:=.T.
         Work->(DBSKIP())
         LOOP
      EndIf

      IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"DESMARCA_ITEM"),) // JBS - 16/07/2003 11:05
      MTotal   := MTotal - VAL(STR(Work->WKPRECO * Work->WKQTDE,15,2))
      MTotal2  := MTotal2 - 1
      MTotPeso -= (Work->WKQTDE * Work->WKPESO_L)
      Work->WKSALDO_Q  :=  Work->WKSALDO_O
      Work->WKDT_ENTR  :=  Work->WKDTENTR_S
      Work->WKFLAG     :=  .F.
      Work->WKSEQ_LI   :=  SPACE(3)
      Work->WKFLAGWIN  :=  SPACE(2)
      If lTem_DSI.and. nQual == LSI
         Work->WKFLAGLSI:=  ""
         Work->WKSEQ_LI :=  ""
      EndIf
   ELSEIF !Work->WKFLAG .AND. lMarcaNew

      IF !GI400MarkValid(.T.)
         lMenErro:=.T.
         Work->(DBSKIP())
         LOOP
      ENDIF


      If !ValidOpeGI("MARCATODOS_ITS_PLI")
         lMenErro:=.T.
         Work->(DBSKIP())
         LOOP
      EndIf


      IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"DESPREZA_ITENS_ALL"),)

      IF lDespreza_Itens_All
         Work->(DBSKIP())
         LOOP
      ENDIF

      WorK->WKQTDE      :=    Work->WKSALDO_Q
      //WorK->WKSALDO_Q   :=    0
      WorK->WKFLAG      :=    .T.
      WorK->WKFLAGWIN   :=    cMarca
      IF(EasyEntryPoint("ICPADGI2"),ExecBlock("ICPADGI2",.F.,.F.,"GRAVAWORKITEM_ALL"),)
      MTotal   := MTotal + VAL(STR(WorK->WKPRECO * WorK->WKQTDE,15,2))
      MTotPeso += (WorK->WKQTDE * WorK->WKPESO_L)
      MTotal2  := MTotal2 + 1

   ENDIF

   Work->(DBSKIP())

ENDDO
Work->(DBGOTOP())

IF TYPE('oMark') = "O"
   oMark:oBrowse:Refresh()
ENDIF
IF lMenErro
   HELP("",1,"AVG0005358")//LRL 08/01/04 MSGINFO("Existe itens com inconsistencias, que nao podem ser marcados.")
ENDIF

RETURN .T.

*----------------------------------------------------------------------------
Function G_Tela3(lAltSoPeso, lBtAltDados)
*----------------------------------------------------------------------------
LOCAL oDlg, nOpcA:=0, lValid:=.T., nOldED4Rec, nAPos , i , nPos, cCodANVE
LOCAL aValid:={'Saldo_Q','VlUnit','Dt_Emb','Dt_Ent','Peso_L'}
LOCAL _PictItem := ALLTRIM(X3PICTURE("B1_COD"))
LOCAL _PictPGI  := ALLTRIM(X3PICTURE("W4_PGI_NUM"))
LOCAL bValid:={||lValid:=.T.,;
                 AEVAL(aValid,{|campo|If(lValid,lValid:=GI400Val(campo),)}),;
                 lValid }
LOCAL lAltQtd:= .F. //AAF 14/07/05 - Flag que indica se a quantidade foi alterada, para atualização no AC.
LOCAL nFobUn//FSY - 14/06/2013
Local cMsgRet := ""

PRIVATE nL1, nL2, nL3, nL4, nL5, nL6, nL7, nL8, nL9, nL10, nL11, nL12 , nL13, nL14, nL15, nL16, nL17, ;
        nC1, nC2, nC3, nC4, nC5, nC6, nC7

PRIVATE cMens :="", nQtdAux, cUnid, cItem, TDtPrvEntr, lMostraMem := .T., nQtdNcmAux
Private cItens := ""  // Para ser utilizado nas consultas padrao "ED4" e "E29"
DEFAULT lAltSoPeso := .F.
DEFAULT lBtAltDados:= .F. //DFS - 18/10/2011 - Inclusão de valor default para o segundo parâmetro da função

IF Work->WKFLAG
   //AOM - 11/04/2011 - Operação Especial
   If !ValidOpeGI("DESMARCA_IT_PLI")
      Return .F.
   EndIf

   IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"DESMARCA_ITEM"),) // JBS - 16/07/2003 11:13
   MTotal   := MTotal - VAL(STR(Work->WKPRECO * Work->WKQTDE,15,2))
   MTotal2  := MTotal2 - 1

   MTotPeso -= (Work->WKQTDE * Work->WKPESO_L)

   Work->WKSALDO_Q  :=  Work->WKSALDO_O
   Work->WKDT_ENTR  :=  Work->WKDTENTR_S
   Work->WKFLAG     :=  .F.
   Work->WKSEQ_LI   :=  SPACE(3)
   Work->WKFLAGWIN  :=  SPACE(2)
   If lCposNVAE
      Work->WKNVE      := ""
   EndIf
   If lBtAltDados //DFS - 18/10/2011 - Se a variável lógica for .T., faz a recursão.
      G_Tela3(.T.,.F.)
   EndIf
   RETURN
ENDIF

DBSELECTAREA("Work")

IF !GI400MarkValid(.F.)
   RETURN .F.
ENDIF


//AOM - 25/05/2011 - Carregar a Memória com os campos nomeados igual ao dicionário de acordo com o Arraya "CorrespW5"
For i := 1 To Work->(FCount())

   If (nPos := Ascan(aCorrespW5, {|x| AllTrim(x[2]) == AllTrim(Work->(FIELDNAME(i)))})) > 0
      M->&(aCorrespW5[nPos][1]) := Work->(FieldGet(i))
   EndIf

Next i

nL1:=44  ; nL2:=57 ; nL3:=70  ; nL4:=83  ; nL5:=96  ; nL6:=109; nL65:=122 ; nL7:=135
nL71:=148 ; nL72:=161; nL73:=174; nL74:=187; nL75:=200
nL8:=213 ; nL9:=226; nL10:=239; nL11:=252; nL12:=265
nL8:=148 ; nL9:=161; nL10:=174; nL11:=187; nL12:=200
nC1:=6  ; nC2:=48  ; nC3:=144 ; nC4:=184 ; nC5:=72  ; nC6:=106; nC7:=206

nLinha1:=9;nColuna1:=0
nLinha2:=42;nColuna2:=80
nOpca:=0
IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"TELA_ITENS"),)

DEFINE MSDIALOG oDlg TITLE STR0067 FROM nLinha1,nColuna1 TO nLinha2,nColuna2 OF oMainWnd //"Dados do Item"

    TSaldo_Q   := Work->WKSALDO_Q
    TFobUnit   := Work->WKPRECO
    TPeso_L    := Work->WKPESO_L
    //FSM - 31/08/2011 - "Peso Bruto Unitário"
    If lPesoBruto
       TPeso_B    := Work->WKW5PESOBR
    EndIf
    If AvFlags("RATEIO_DESP_PO_PLI")
       TFretIte := Work->WKFRETE
       TSeguIte := Work->WKSEGUR
       TInlaIte := Work->WKINLAN
       TDescIte := Work->WKDESCO
       TPackIte := Work->WKPACKI
    EndIf
    TDtEntrega := Work->WKDT_ENTR
    TDtPrvEntr := TDtEntrega
    TDtEmbarque:= Work->WKDT_EMB
    nFobTotal  := Work->WKSALDO_Q * Work->WKPRECO
    //AOM - 09/04/2011
    If lOperacaoEsp
      cCodOpe := Work->W5_CODOPE
    EndIf

    nFobUn     := GI400ApVal(.F.) / TSaldo_Q //FSY - 14/06/2013

    If lIntDraw
       cItem   := Work->WKCOD_I
       cItens  += cItem
       IF EMPTY(M->W4_COND_PA)                           //NCF - 29/03/2011 - Nao permite a apropriação de ato se a cond. pagto. da PLI estiver vazia
          Work->WKAC     := SPACE(LEN(Work->WKAC))
          Work->WKSEQSIS := SPACE(LEN(Work->WKSEQSIS))
       ENDIF
       cAC     := Work->WKAC
       cSeqSis := Work->WKSEQSIS
       If !Empty(cAC)
          ED0->(dbSetOrder(2))
          ED4->(dbSetOrder(2))
          ED4->(dbSeek(cFilED4+cAC+Work->WKSEQSIS))
          If ED0->ED0_AC <> ED4->ED4_AC .or. ED0->ED0_FILIAL <> cFilED0
             ED0->(dbSeek(cFilED0+ED4->ED4_AC))
             ED0->(dbSetOrder(1))
          EndIf
          If cItem != ED4->ED4_ITEM
             cItem := IG400BuscaItem("I",cItem,ED4->ED4_PD)  // PLB 14/11/06
             cItens += "///"+cItem
          Else
             cItens += "///"+IG400BuscaItem("I",cItem,ED4->ED4_PD)  // PLB 14/11/06
          EndIf
          VerificaQTD(.F.,,,ED0->ED0_TIPOAC,cItem)
          If ED0->ED0_TIPOAC <> GENERICO .or. ED4->ED4_NCM <> NCM_GENERICA
             TSaldo_Q   := Work->WKQTDE
             nFobTotal  := TSaldo_Q * TFobUnit
          EndIf
       Else
          cItens += "///"+IG400BuscaItem("I",cItem)  // PLB 14/11/06
       EndIf
    EndIf

    oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165)
    oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

    @18.2,nC1 SAY STR0068 SIZE 50,8 PIXEL OF oPanel //"No. P.L.I "
    @18.2,nC2 MSGET M->W4_PGI_NUM PICTURE _PictPgi WHEN .F.  SIZE 60,7 PIXEL OF oPanel
    @18.2,nC3 SAY STR0069          SIZE 50,8 PIXEL OF oPanel  //"Data"
    @18.2,nC4 MSGET M->W4_PGI_DT  PICTURE "@D"     WHEN .F.  SIZE 40,8 PIXEL OF oPanel

    @31.2,nC1 SAY STR0070      SIZE 50,8 PIXEL OF oPanel //"No. P.O "
    @31.2,nC2 MSGET TPO_Num    PICTURE _PictPo  WHEN .F.  SIZE 60,7 PIXEL OF oPanel

    If lIntDraw .and. Empty(M->W4_ATO_CON) .And. lMostraAC
       ED4->( DBGoTop() )
       @31.2,nC3 SAY AVSX3("ED0_AC",5) SIZE 50,8 PIXEL OF oPanel //"Ato Concessorio "                        // NCF - 11/01/2010       // NCF - 30/03/2011
       @31.2,nC4 MSGET cAC F3 "ED4" PICTURE AVSX3("ED0_AC",6) VALID (ValidaAC("ATO")) SIZE 60,7 PIXEL OF oPanel WHEN !lAltSoPEso .And. !EMPTY(M->W4_COND_PA)

       @31.2,250 SAY STR0195 SIZE 50,8 PIXEL OF oPanel //"Seq. A.C. "                                                                                     // NCF - 30/03/2011
       @31.2,275 MSGET cSeqSis /*F3 "E29"*/ PICTURE AVSX3("ED4_SEQSIS",6) VALID (ValidaAC("",Work->WKCOD_I)) SIZE 30,7 PIXEL OF oPanel When !Empty(cAc) .And. !EMPTY(M->W4_COND_PA)
    EndIf

    @nL1,nC1 SAY STR0071 SIZE 50,8 PIXEL OF oPanel  //'C¢digo Item'
    @nL2,nC1 SAY STR0072 SIZE 40,8 PIXEL OF oPanel //'Fabricante'
    @nL3,nC1 SAY STR0073 SIZE 40,8 PIXEL OF oPanel //'Fornecedor'

    @nL4,nC1 SAY STR0074 SIZE 35,8 PIXEL OF oPanel //'Saldo Qtde'
    @nL4,nC3 SAY STR0075 SIZE 40,8 PIXEL OF oPanel //'Embarque'

    //@nL5,nC1 SAY STR0076 SIZE 50,8 PIXEL //'FOB Unit rio'
    @nL5,nC1 SAY STR0346 SIZE 50,8 PIXEL OF oPanel //'Preço Unitário' //FSY - 13/06/2013 - alterada o nome.
    @nL5,nC3 SAY STR0077 SIZE 40,8 PIXEL OF oPanel //'Entrega'

    //@nL6,nC1 SAY STR0078 SIZE 40,8 PIXEL //'FOB Total'
    @nL6,nC1 SAY STR0347 SIZE 40,8 PIXEL OF oPanel //'Preço Total'//FSY - 13/06/2013 - alterada o nome.

    @nL6,nC3 SAY STR0079 SIZE 40,8 PIXEL OF oPanel //'Peso L¡quido'
    If nQual != 3//FSY - 02/07/2013 - Não poderá ser exibida na inclusão
       @nL7,nC1 SAY STR0076 SIZE 50,8 PIXEL OF oPanel //'FOB Unitário' //FSY - 13/06/2013
    End If
    //FSM 31/08/2011 - "Peso Bruto Unitário"
    If lPesoBruto
       @nL65,nC1 SAY STR0348  SIZE 40,8 PIXEL OF oPanel //'Peso Bruto Uni'
    EndIf

    IF !Empty(Work->WKFABR_01+Work->WKFABR_02+Work->WKFABR_03+Work->WKFABR_04+Work->WKFABR_05)
       @nL7,nC1 SAY STR0080 SIZE 200,8 PIXEL OF oPanel //'Outros C¢digos de Fabricante (Endere‡os p/ L.I.)'
    ENDIF

    //AOM - 09/04/2011
    If lOperacaoEsp
       @nL8,nC1 SAY AVSX3("W5_CODOPE",AV_TITULO) SIZE 40,8 PIXEL OF oPanel //Codigo Operação
    EndIf

    @nL1,nC2 SAY TRANSFORM(Work->WKCOD_I,_PictItem)+" "+ALLTRIM(Work->WKDESCR)  SIZE 150,8 PIXEL OF oPanel
    @nL2,nC2 SAY Work->WKFABR+" "+ IF(EICLOJA(),Work->W5_FABLOJ+ " ","")+Work->WKNOME_FAB SIZE 140,8 PIXEL OF oPanel
    @nL3,nC2 SAY Work->WKFORN+" "+ IF(EICLOJA(),Work->W5_FORLOJ+ " ","")+Work->WKNOME_FOR SIZE 140,8 PIXEL OF oPanel
    IF lMV_EIC_EAI//AWF - 25/06/2014
       @nL4,nC2 SAY WORK->WKUNI           SIZE 35,8 PIXEL OF oPanel
    ENDIF
    @nL5,nC2 SAY MMoeda                SIZE 35,8 PIXEL OF oPanel
    @nL6,nC2 SAY MMoeda                SIZE 35,8 PIXEL OF oPanel

    @nL8,nC1 SAY Work->WKFABR_01 + " " + IF(EICLOJA(),Work->W5_FAB1LOJ+ " ","") +SUBSTR(BuscaFabr_Forn(Work->WKFABR_01,IF(EICLOJA(),Work->W5_FAB1LOJ,"")),1,15) SIZE 150,8 PIXEL OF oPanel
    @nL8,nC6 SAY Work->WKFABR_02 + " " + IF(EICLOJA(),Work->W5_FAB2LOJ+ " ","") + SUBSTR(BuscaFabr_Forn(Work->WKFABR_02,IF(EICLOJA(),Work->W5_FAB2LOJ,"")),1,15) SIZE 150,8 PIXEL OF oPanel
    @nL8,nC7 SAY Work->WKFABR_03 + " " + IF(EICLOJA(),Work->W5_FAB3LOJ+ " ","") + SUBSTR(BuscaFabr_Forn(Work->WKFABR_03,IF(EICLOJA(),Work->W5_FAB3LOJ,"")),1,15) SIZE 150,8 PIXEL OF oPanel
    @nL9,nC1 SAY Work->WKFABR_04 + " " + IF(EICLOJA(),Work->W5_FAB4LOJ+ " ","") + SUBSTR(BuscaFabr_Forn(Work->WKFABR_04,IF(EICLOJA(),Work->W5_FAB4LOJ,"")),1,15) SIZE 150,8 PIXEL OF oPanel
    @nL9,nC6 SAY Work->WKFABR_05 + " " + IF(EICLOJA(),Work->W5_FAB5LOJ+ " ","") + SUBSTR(BuscaFabr_Forn(Work->WKFABR_05,IF(EICLOJA(),Work->W5_FAB5LOJ,"")),1,15) SIZE 150,8 PIXEL OF oPanel
    @nL3,nC3 SAY STR0081 SIZE 40,8 PIXEL OF oPanel  //'Part Number'

    @nL3,nC4 MSGET Work->WKPART_N               WHEN  .F.                 SIZE 70,8 PIXEL OF oPanel
    IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"DADOS_ITENS_1"),)
    @nL4,nC2 MSGET TSaldo_Q    PICTURE _PictQtde VALID GI400Val('Saldo_Q') SIZE 60,8 PIXEL OF oPanel WHEN !lAltSoPeso
    @nL5,nC2 MSGET TFobUnit    PICTURE _PictPrUn VALID GI400Val('VlUnit')  SIZE 60,8 PIXEL OF oPanel WHEN !lAltSoPeso

    @nL4,nC4 MSGET TDtEmbarque PICTURE dDtEmb    VALID GI400Val('Dt_Emb')  SIZE 40,8 PIXEL OF oPanel //DFS - 19/10/11 - Retirada do When do campo, para que, possa alterar a data de embarque
    @nL5,nC4 MSGET TDtEntrega  PICTURE dDtEnt    VALID GI400Val('Dt_Ent')  SIZE 40,8 PIXEL WHEN lMostraMem OF oPanel //DFS - 19/10/11 - Retirada do When do campo, para que, possa alterar a data de entrega    //GFP - 19/04/2012 - Inserido novamente WHEN para que cliente customize a alteração do campo.
    @nL6,nC4 MSGET TPeso_L     PICTURE cPictPeso VALID GI400Val('Peso_L') .and. GI400val('Peso_Tot')  SIZE 50,8 PIXEL OF oPanel
    IF lMV_EIC_EAI//AWF - 25/06/2014
       M->W5_QTSEGUM:=Work->WKQTSEGUM
       cSegUN:= TRANSFORM(M->W5_QTSEGUM,AVSX3("W3_QTSEGUM",6))+" "+WORK->WKSEGUM
       @nL65,nC3 SAY AVSX3("W3_QTSEGUM",AV_TITULO) SIZE 40,8 PIXEL OF oPanel
       @nL65,nC4 MSGET cSegUN SIZE 60,8 PIXEL OF oPanel  WHEN .F.
    ENDIF
 // @nL6,nC4 MSGET TPeso_L     PICTURE cPictPeso VALID GI400Val('Peso_L')  SIZE 50,8 PIXEL

    @nL6,nC2 MSGET oFobTotal  Var nFobTotal     PICTURE _PictPrUn         SIZE 60,8 PIXEL OF oPanel  WHEN .F. RIGHT

    //FSM - 31/08/2011 - "Peso Bruto Unitário"
    If lPesoBruto
       @nL65,nC2 MSGET TPeso_B    PICTURE AVSX3("W5_PESO_BR",AV_PICTURE) VALID Positivo()  SIZE 50,8 PIXEL OF oPanel
    EndIf
    If nQual != 3//FSY - 02/07/2013 - Não poderá ser exibida na inclusão
       @nL7,nC2 MSGET nFobUn      PICTURE _PictPrUn SIZE 60,8 PIXEL OF oPanel WHEN .F.//FSY - 13/06/2013
    End If
    //@nL6,nC5 MSGET oFobTotal  Var nFobTotal     PICTURE _PictPrUn         SIZE 60,8 PIXEL OF oPanel WHEN .F. RIGHT

    //AOM - 09/04/2011
    If lOperacaoEsp
       @nL8,nC2 MSGET cCodOpe  F3 "EJ0"   PICTURE "@!"  VALID ValidOpe('cCodOpe_W5')  SIZE 30,7 PIXEL OF oPanel WHEN Work->WKSALDO_Q > 0 // Se for maior que zero nao está embarcado
    EndIf
    If AvFlags("RATEIO_DESP_PO_PLI")
       @nL72,nC1 SAY AVSX3("W5_FRETE",AV_TITULO) SIZE 40,8 PIXEL OF oPanel
       @nL72,nC2 MSGET TFretIte PICTURE _PictPrUn SIZE 60,8 PIXEL OF oPanel WHEN .F.

       @nL72,nC3 SAY AVSX3("W5_SEGURO",AV_TITULO) SIZE 40,8 PIXEL OF oPanel
       @nL72,nC4 MSGET TSeguIte PICTURE _PictPrUn SIZE 60,8 PIXEL OF oPanel WHEN .F.

       @nL73,nC1 SAY AVSX3("W5_INLAND",AV_TITULO) SIZE 40,8 PIXEL OF oPanel
       @nL73,nC2 MSGET TInlaIte PICTURE _PictPrUn SIZE 60,8 PIXEL OF oPanel WHEN .F.

       @nL73,nC3 SAY AVSX3("W5_DESCONT",AV_TITULO) SIZE 40,8 PIXEL OF oPanel
       @nL73,nC4 MSGET TDescIte PICTURE _PictPrUn SIZE 60,8 PIXEL OF oPanel WHEN .F.

       @nL74,nC1 SAY AVSX3("W5_PACKING",AV_TITULO) SIZE 40,8 PIXEL OF oPanel
       @nL74,nC2 MSGET TPackIte PICTURE _PictPrUn SIZE 60,8 PIXEL OF oPanel WHEN .F.
    EndIf

    IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"DADOS_ITENS"),)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,;
         {|| If(EVAL(bValid) .and. ValidaAC("TELA3") .and. ValidOpeGI("BTN_MK_IT_PLI")/*AOM - 11/04/2011 - Valida operação especial */,(nOpcA:=1,oDlg:End()),)},;
         {|| nOpcA:=0, oDlg:End()}) CENTERED

If nOpcA = 0
   SELECT Work
   RETURN
Endif

IF nOpcA = 1
   DBSELECTAREA("Work")

   lAltQtd:= WorK->WKQTDE<>TSaldo_Q //AAF 14/07/05 - Alteração na Quantidade.
   If !lAltSoPEso
      WorK->WKQTDE      :=    TSaldo_Q
      WorK->WKSALDO_Q   :=    TSaldo_Q
      WorK->WKPRECO     :=    TFobUnit
      WorK->WKDT_EMB    :=    TDtEmbarque
      WorK->WKDT_ENTR   :=    TDtEntrega
      WorK->WKPESO_L    :=    TPeso_L
      WorK->WKFLAG      :=    .T.
      WorK->WKFLAGWIN   :=    cMarca
   Else
      WorK->WKFLAG      :=    .T.
      WorK->WKPESO_L    :=    TPeso_L
      WorK->WKDT_EMB    :=    TDtEmbarque //DFS - 19/10/11 - Inclusão do campo Embarque para alteração
      WorK->WKDT_ENTR   :=    TDtEntrega  //DFS - 19/10/11 - Inclusão do campo Entrega para alteração
      WorK->WKFLAGWIN   :=    cMarca
   EndIF

   IF lMV_EIC_EAI//AWF - 25/06/2014
      Work->WKQTSEGUM := M->W5_QTSEGUM//WorK->WKQTDE*Work->WKFATOR
   ENDIF

   //FSM - 31/08/2011 - "Peso Bruto Unitário"
   If lPesoBruto
      Work->WKW5PESOBR  :=    TPeso_B
   EndIf

   If AvFlags("RATEIO_DESP_PO_PLI")
      Work->WKFRETE := TFretIte
      Work->WKSEGUR := TSeguIte
      Work->WKINLAN := TInlaIte
      Work->WKDESCO := TDescIte
      Work->WKPACKI := TPackIte
   EndIf

   //AOM - 09/04/2011
   If lOperacaoEsp
      Work->W5_CODOPE := cCodOpe
      Work->W5_DESOPE := POSICIONE("EJ0",1,xFilial("EJ0")+ Work->W5_CODOPE ,"EJ0_DESC")
   EndIf

   If lIntDraw .and. (cAC<>Work->WKAC .or. cSeqSis<>Work->WKSEQSIS .or. lAltQtd)//AAF 14/07/05 - Verifica alteração de Quantidade.
      ED0->(dbSetOrder(2))
      If !Empty(Work->WKAC)
         nOldED4Rec := ED4->(RecNo())
         If ED4->(dbSeek(cFilED4+Work->WKAC+Work->WKSEQSIS))
            ED4->(msUnlock())
            DelSaldoAC()
         EndIf
         ED4->(dbGoTo(nOldED4Rec))
      EndIf
      If !Empty(cAC)
         If ED0->ED0_AC <> cAC .or. ED0->ED0_FILIAL <> cFilED0
            ED0->(dbSeek(cFilED0+cAC))
         EndIf
         ED4->(dbSetOrder(2))
         ED4->(dbSeek(cFilED4+cAC+cSeqSis))
         VerificaQTD(.F.,,,ED0->ED0_TIPOAC,cItem)
         //Verifica Saldo
         If ((ED0->ED0_TIPOAC == GENERICO .and. ED4->ED4_NCM = NCM_GENERICA) .OR.;
            ( ED4->ED4_QT_LI >= nQtdAux .AND. ED4->ED4_SNCMLI >= nQtdNcmAux )) .AND.;//AAF 22/08/05 - Verifica Saldo NCM.
            ( ED4->ED4_CAMB==VerCobertura(MCond_Pag,MDias_Pag)) /*AOM - 21/07/10 - Valida se a cond. de pagto esta COM/SEM cobertura, pois para efetuar a apropriação deve verificar se os
                                                                itens do ato Concessório esta de acordo com a cobertura na cond. pagto*/
            cMsgRet += GI400ValAnt(ED0->ED0_PD,ED4->ED4_ITEM,ED4->ED4_SEQSIS)
            Apropria(.F.,ED0->ED0_TIPOAC,,cItem)

            If lAltQtd //AAF 14/07/05
               //** PLB 29/11/06 - Destrava o Ato concessorio anterior
               If !Empty(Work->( WKAC+WKSEQSIS ))
                  nOrderSW5 := SW5->( IndexOrd() )
                  nRecnoSW5 := SW5->( RecNo() )
                  SW5->( DBSetOrder(1) )
                  If SW5->( DBSeek(cFilSW5+M->W4_PGI_NUM+Work->WKCC+Work->WKSI_NUM+Work->WKCOD_I) )  ;
                     .And.  SW5->( W5_AC+W5_SEQSIS ) == Work->( WKAC+WKSEQSIS )  .And.  lMUserEDC
                     If oMUserEDC:Reserva("PLI","ALT_ATO_3")
                        Work->WKAC     := ""
                        Work->WKSEQSIS := ""
                     EndIf
                  Else
                     If lMUserEDC
                        oMUserEDC:Solta("PLI","ALT_ATO")
                     EndIf
                     Work->WKAC     := ""
                     Work->WKSEQSIS := ""
                  EndIf
                  SW5->( DBSetOrder(nOrderSW5) )
                  SW5->( DBGoTo(nRecnoSW5) )
               EndIf
               //**
            EndIf

         Else

            cMotivo := STR0255 +Chr(13)+Chr(10) // STR255 "Divergência na apropriação"
            cMotivo += STR0256 +ED4->ED4_AC+STR0257+ED4->ED4_SEQSIS+Chr(13)+Chr(10) //STR0256 "Ato Concessório " // STR0257 " sequência "

            If Valtype(nQtdAux) == "N" .And. ED4->ED4_QT_LI < nQtdAux
               cMotivo += STR0258 +ED4->ED4_UMITEM+": "+TransForm(ED4->ED4_QT_LI,AvSX3("ED4_QT_LI",AV_PICTURE))+Chr(13)+Chr(10) //STR0258 "   Saldo em "
               cMotivo += STR0259 +ED4->ED4_UMITEM+": "+TransForm(nQtdAux,AvSX3("ED4_QT_LI",AV_PICTURE))+Chr(13)+Chr(10) //STR0259 "   Quantidade do item a vincular em "
            EndIf

            If ED4->ED4_UMITEM <> ED4->ED4_UMNCM .AND.  Valtype(nQtdNcmAux) == "N" .AND. ED4->ED4_SNCMLI < nQtdNcmAux
               cMotivo += STR0258 +ED4->ED4_UMNCM+": "+TransForm(ED4->ED4_QT_LI,AvSX3("ED4_QT_LI",AV_PICTURE))+Chr(13)+Chr(10) //STR0258 "   Saldo em "
               cMotivo += STR0259+ED4->ED4_UMNCM+": "+TransForm(nQtdAux,AvSX3("ED4_QT_LI",AV_PICTURE))+Chr(13)+Chr(10) //STR0259 "   Quantidade do item a vincular em "
            EndIf

            If ED4->ED4_CAMB <> VerCobertura(MCond_Pag,MDias_Pag)//AOM - 21/07/10
               If ED4->ED4_CAMB == "1"
                  cMotivo += STR0260 + Alltrim(ED4->ED4_ITEM)+ STR0261 + Chr(13)+Chr(10) //STR0260 "   O item " //STR0261 " não pode ser apropriado, pois no Ato Concessório o mesmo possui Cobertura Cambial"
                  cMotivo += STR0262 + Chr(13)+Chr(10) //STR0262 " e a condição de pagamento utilizada está Sem cobertura Cambial. Para que o item possa ser apropriado as condições devem estar em comum."
               ElseIf ED4->ED4_CAMB == "2"
                  cMotivo += STR0260 + Alltrim(ED4->ED4_ITEM)+ STR0261 + Chr(13)+Chr(10) //STR0260 "   O item " //STR0261 " não pode ser apropriado, pois no Ato Concessório o mesmo possui Cobertura Cambial"
                  cMotivo += STR0262 + Chr(13)+Chr(10) //STR0262 " e a condição de pagamento utilizada está Sem cobertura Cambial. Para que o item possa ser apropriado as condições devem estar em comum."
               EndIf
            EndIf

            //AOM - 15/09/2011
            If ED4->ED4_QT_LI<=0
               cMotivo += STRTRAN(STR0302,"###",AllTrim(ED4->ED4_AC)) + AllTrim(Transform(ED4->ED4_QT_LI,AVSX3("ED4_QT_LI",6))) //"Saldo da LI insuficiente no Ato Concessório ### para o Item selecionado. Saldo atual no Ato Concessório de : "
            EndIf

            cMotivo += Chr(13)+Chr(10)

            EECView(cMotivo,STR0263) //STR0263 "Divergências - Não foi possível apropriar o Ato Concessório"
            //ConfirmaAC(cAC,0,.F.,,cItem)
            // PLB 18/07/07 - Não apropria caso não haja saldo
            //MsgInfo(STR0191+Alltrim(cAc)+" "+STR0019+Alltrim(cSeqSis)+STR0158) //"O Ato Concessorio " # " seq. " # " nao serve para apropriação deste item. Tente selecionar um item correspondente através da tecla <F3>."
         EndIf
      ElseIf !Empty(Work->WKAC)
         //** PLB 29/11/06 - Destrava o Ato concessorio anterior
         nOrderSW5 := SW5->( IndexOrd() )
         nRecnoSW5 := SW5->( RecNo() )
         SW5->( DBSetOrder(1) )
         If SW5->( DBSeek(cFilSW5+M->W4_PGI_NUM+Work->WKCC+Work->WKSI_NUM+Work->WKCOD_I) )  ;
            .And.  SW5->( W5_AC+W5_SEQSIS ) == Work->( WKAC+WKSEQSIS )  .And.  lMUserEDC
            If oMUserEDC:Reserva("PLI","ALT_ATO_3")
               Work->WKAC     := ""
               Work->WKSEQSIS := ""
            EndIf
         Else
            If lMUserEDC
               oMUserEDC:Solta("PLI","ALT_ATO")
            EndIf
            Work->WKAC     := ""
            Work->WKSEQSIS := ""
         EndIf
         SW5->( DBSetOrder(nOrderSW5) )
         SW5->( DBGoTo(nRecnoSW5) )
         //**
      EndIf
   EndIf

   IF Work->WKFLAG .AND. lCposNVAE
      EIM->(DbSetOrder(3))
      //MFR 26/11/2018 OSSME-1483
      //IF EIM->(DbSeek(xFilial("EIM")+AvKey("CD","EIM_FASE")+AvKey(Work->WKCOD_I,"EIM_HAWB"))) .AND. AllTrim(Work->WKTEC) == AllTrim(Posicione("SB1",1,xFilial("SB1")+AvKey(Work->WKCOD_I,"B1_COD"),"B1_POSIPI")) .AND.;
      IF EIM->(DbSeek(GetFilEIM("CD")+AvKey("CD","EIM_FASE")+AvKey(Work->WKCOD_I,"EIM_HAWB"))) .AND. AllTrim(Work->WKTEC) == AllTrim(Posicione("SB1",1,xFilial("SB1")+AvKey(Work->WKCOD_I,"B1_COD"),"B1_POSIPI")) .AND.;
         MsgYesNo(STR0363 + ENTER + STR0364,STR0354)  // "Existem itens marcados no processo que já possuem classificação N.V.A.E. originada do cadastro de Produto." ### "Deseja importar as informações de N.V.A.E. para estes itens?"      
         cCodANVE := If(lNVEProduto,GI400GerNVE(),"")
         //MFR 26/11/2018 OSSME-1483
         //Do While EIM->(!Eof()) .AND. EIM->(EIM_FILIAL+EIM_FASE+EIM_HAWB) == xFilial("EIM")+AvKey("CD","EIM_FASE")+AvKey(Work->WKCOD_I,"EIM_HAWB")
         Do While EIM->(!Eof()) .AND. EIM->(EIM_FILIAL+EIM_FASE+EIM_HAWB) == GetFilEIM("CD")+AvKey("CD","EIM_FASE")+AvKey(Work->WKCOD_I,"EIM_HAWB")
            WORK_GEIM->(DbSetOrder(1))
            If !WORK_GEIM->(DbSeek(EIM->(EIM_NIVEL+EIM_ATRIB+EIM_ESPECI+If(lNVEProduto,EIM_NCM,""))))
               WORK_GEIM->(DbAppend())
               AvReplace("EIM","WORK_GEIM")
               WORK_GEIM->EIM_FASE := "LI"
               Work_GEIM->EIM_CODIGO := cCodANVE
               WORK_EIM->(DbAppend())
               AvReplace("WORK_GEIM","WORK_EIM")
               WORK_EIM->EIM_HAWB := M->W4_PGI_NUM
            Else
               If AvKey(WORK_GEIM->EIM_HAWB,"W3_COD_I") == Work->WKCOD_I .And. WORK_GEIM->EIM_NCM == Work->WKTEC 
                  cCodANVE := Work_GEIM->EIM_CODIGO
                  EXIT
               EndIf
            EndIf
            EIM->(DbSkip())
         EndDo
         //WORK_EIM->(DbGoTop())
         Work->WKNVE := cCodANVE//WORK_EIM->EIM_CODIGO

         WORK_CEIM->(DbAppend())
         Work_CEIM->EIM_CODIGO:=Work->WKNVE
         Work_CEIM->WKTEC     :=Work->WKTEC
      ENDIF
   ENDIF
   
   IF(EasyEntryPoint("ICPADGI2"),ExecBlock("ICPADGI2",.F.,.F.,"GRAVAWORKITEM"),)
   IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"GRAVAWORKITEM"),)

   MTotal   := MTotal + VAL(STR(WorK->WKPRECO * WorK->WKQTDE,15,2))

   MTotPeso += (WorK->WKQTDE * WorK->WKPESO_L)

   //TRP- 02/03/07 - Gravação do preço total
   //Work->WKPRTOT := MTotal
   Work->WKPRTOT := Val(Str(Work->WKSALDO_O * Work->WKPRECO,nTamP,nDecP)) //ER - 28/09/2007

   MTotal2  := MTotal2 + 1
   DBSELECTAREA("Work")
ENDIF

If ! Empty(cMsgRet)
  lMsgAC := .T.
  If EasyEntryPoint("EICGI400")
    Execblock("EICGI400",.F.,.F.,"MSG_AC")
  EndIf
  If lMsgAC <> nil .and. lMsgAC
    MsgInfo(cMsgRet,"Ato Concessório")
  EndIf
EndIf

RETURN
*----------------------------------------------------------------------------
Function GI400MarkValid(lTodos)
*----------------------------------------------------------------------------
//CCH - 21/10/2008 - Início
//Variáveis utilizadas para uso em Customização
Private lRet  := .T.
Private lSair := .F.

//Ponto de Entrada para Desvio da Validação
IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"DESVIA_VALIDACAO"),)

If lSair
   Return lRet
EndIf
//CCH - 21/10/2008 - Fim

cMens :=""

SB1->(DBSEEK(xFilial()+Work->WKCOD_I))
//IF M->W4_SUFRAMA = "S" .AND. !EMPTY(M->W4_PROD_SU) CCH - 21/10/2008 - Removida validação para acerto do controle de fluxo da rotina.
IF !EMPTY(M->W4_PROD_SU)
   SYX->(DBSETORDER(3))
   IF !SYX->(DBSEEK(xFilial()+M->W4_PROD_SU+Work->WKCOD_I))
      IF( !lTodos , HELP("",1,"AVG0000407") ,) //"Item não cadastrado no PPB"
      SYX->(DBSETORDER(1))
      RETURN .F.
   ENDIF
   SYX->(DBSETORDER(1))
   IF EMPTY(SYX->YX_DES_ZFM)
      cMens:= STR0264 //STR0264 "Descricao da Lista de Engenharia"
   ENDIF
   IF EMPTY(SYX->YX_TEC)
      IF(!EMPTY(cMens),cMens+=", ",)
      cMens:= cMens + STR0265 //STR0265 "Ncm da Lista de Engenharia"
   ENDIF
   IF EMPTY(SYX->YX_INSUMO)
      IF(!EMPTY(cMens),cMens+=", ",)
      cMens:= cMens +STR0266   //+ MENSAGEM DE INSUMO //STR0266 "Insumo"
   ENDIF
   IF EMPTY(SB1->B1_ESPECIF)
      IF(!EMPTY(cMens),cMens+=", ",)
      cMens:= cMens + STR0267  // +MENSAGEM DE DESCRICAO ESPECIFICA //STR0267 "Descricao Especifica"
   ENDIF
   IF EMPTY(SB1->B1_MAT_PRI)
      IF(!EMPTY(cMens),cMens+=", ",)
      cMens:= cMens  + STR0268 //+ MENSAGEM DE MATERIA PRIMA //STR0268 "Materia Prima"
   ENDIF
   If SW3->(FieldPos("W3_PART_N")) # 0 //ASK 05/10/2007
      SW3->(DBSetOrder(8))
      SW3->(DbSeek(xFilial("SW3") + SW5->W5_PO_NUM + SW5->W5_POSICAO))
      If !Empty(SW3->W3_PART_N)
         cPart:= SW3->W3_PART_N
      Else
         cPart := SA5->(BuscaPart_N())
      EndIf
   Else
      cPart := SA5->(BuscaPart_N())
   EndIf
   //cPart := SA5->(BuscaPart_N())
   //IF EMPTY(SA5->A5_CODPRF)
   IF EMPTY(cPart)
      IF(!EMPTY(cMens),cMens+=", ",)
      cMens:= cMens +STR0269 //+ MENSAGEM DE PART NUMBER  //STR0269 "Part-number"
   ENDIF
   IF EMPTY(SA5->A5_PARTOPC)
      IF(!EMPTY(cMens),cMens+=", ",)
      cMens:= cMens + STR0270 //+ MENSAGEM DE PART NUMBER //STR0270 "Part-number opcional"
   ENDIF

   If(EasyEntryPoint("ICPADSUF"),ExecBlock("ICPADSUF",.F.,.F.,"MENSAGEM"),)

   IF !EMPTY(cMens)
      IF( !lTodos , Help(" ",1,"AVG0000112",,AllTrim(cMens)+".",2,0) ,)
      RETURN .F.
   ENDIF

ELSE

  IF EMPTY(Work->WKDESCR)
     IF( !lTodos , HELP("",1,"AVG0000408") ,)//'Descrição deste item não preenchida'
     RETURN .F.
  ENDIF

ENDIF

IF EMPTY(Work->WKTEC)
   IF( !lTodos , HELP("",1,"AVG0000409") ,)//"Item sem classificação T.E.C. , não pode ser selecionado"
   RETURN .F.
ENDIF

IF Work->WKDT_EMB < dDataBase
   IF( !lTodos , HELP("",1,"AVG0000410") ,)//"Data do embarque deste item menor que a data de hoje"
ENDIF

RETURN lRet
*------------------*
FUNCTION GI400_LIS()
*------------------*
Local  nSeq:=0, nProx:=0  // GFP - 06/01/2014
Private nMaxItens:= EICParISUF() //EasyGParam("MV_NR_ISUF",.F.,78)/*60*/ //FDR - 09/01/12 - Conteúdo padrão conforme SISCOMEX
Private cEx_NBM:= SPACE(AVSX3("B1_EX_NBM",3)),;
        cEx_NCM:= SPACE(AVSX3("B1_EX_NCM",3)),;
        cRegTri:= SPACE(AVSX3("EIJ_REGTRI",3)) //GFP 07/02/2011 :: 11:43
Private lPri:=.T. , cVar_Quebra:="" , cCpo_Quebra:="",cVar_QuebEYJ:="" , cCpo_QuebEYJ:="", nOrdem:=4, lQuebra_Espe:=.F.
Private cTec,nFab,cNal,nAla,nCont:=0, cAto, lPriQuebraEsp:=.T.

If nMaxItens == 0 //ASK - 18/06/07 Se o MV_NR_ISUF estiver sem conteúdo, o padrão atribuído será 78.
   nMaxItens:= 78 //60
EndIf

MTotal:=MTotPeso:=0
IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"VARIAVEIS"),)

Work->(DBSETORDER(nOrdem))
Work->(DBGOTOP())
DO WHILE ! Work->(EOF())
   IF ! Work->WKFLAG
      Work->(DBSKIP())
      LOOP
   ENDIF

      //MTotal   += Work->WKQTDE * Work->WKPRECO
	  //MTotPeso += Work->WKQTDE * Work->WKPESO_L

   /* LGS - 21/08/2013 - Quando a P.l.i. tem desembaraco o campo Work->WKQTDE vai estar vazio e se entrar novamente na
      P.l.i. os valores vão estar todos zerados, dessa forma gravo o valor total para o campo Work->WKQTDORI e este passa a ser usado como
      validação para esse caso. Neste momento verifico se esta vazio, isso é preciso pq na inclusão ainda nao tenho esse campo com qtde ele
      vai estar vazio. */

   If Empty(Work->WKQTDORI)	//LGS - 21/08/2013
      MTotal   += Work->WKQTDE * Work->WKPRECO
	  MTotPeso += Work->WKQTDE * Work->WKPESO_L
   Else
      MTotal   += WorK->WKQTDORI * Work->WKPRECO
	  MTotPeso += WorK->WKQTDORI * Work->WKPESO_L
   EndIf

   IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"GRAVA_VARIAVEIS"),)

   IF AvFlags("DESTAQUE_QUEBRA_LI") //LRS - 18/01/18
      If lPri
         cVar_QuebEYJ := Work->WKDESTEYJ
      EndIf
      cCpo_QuebEYJ := Work->WKDESTEYJ
   EndIF

   IF lPri
      lPri:=.F.
      If(lIntDraw , cAto:= Work->WKAC ,)
      If(lCposNVAE, cNve := Work->WKNVE,)    //NCF - 08/08/2011 - Classificação N.V.A.E na PLI
      cTec:= Work->WKTEC
      nFab:= Work->WKFABR
      cNal:= Work->WKSHNA_NTX
      nAla:= Work->WKALADI
      cEx_NBM:= Work->WK_EX_NBM
      cEx_NCM:= Work->WK_EX_NCM
   ENDIF
   Work->(DBSKIP())
   nProx:= Work->(RECNO())
   Work->(DBSKIP(-1))
   nCont++

   IF GI400QuebraLI()

      IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"QUEBRA"),)

      nSeq++
      If(lIntDraw , cAto:= Work->WKAC ,)
      If(lCposNVAE, cNve := Work->WKNVE,)    //NCF - 08/08/2011 - Classificação N.V.A.E na PLI
      cTec:= Work->WKTEC
      nFab:= Work->WKFABR
      cNal:= Work->WKSHNA_NTX
      nAla:= Work->WKALADI
      cEx_NBM:= Work->WK_EX_NBM
      cEx_NCM:= Work->WK_EX_NCM
      //cRegTri:= Work->WKREGTRI      //GFP 07/02/2011 :: 11:44
      nCont:= 1
   ENDIF
   if !lTem_DSI .or.cRotinaOPC <>"LSI" // JBS 18/12/2003
      Work->WKSEQ_LI:= STRZERO(nSeq,3)
   endif
   Work->(DBGOTO(nProx))
END
Work->(DBGOTOP())

IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"RETURN_GI400_LIS"),)

RETURN .T.

*----------------------------------------------------------------------*
Function GI400QuebraLI()
*----------------------------------------------------------------------*
PRIVATE lQuebrou:=.F.

IF lQuebra_Espe   // Há Quebra Especial ?  - RS 27/03/06
   IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"QUEBRAESPECIAL"),)
   RETURN lQuebrou
ENDIF

IF cTec # Work->WKTEC        .OR. nFab # Work->WKFABR  .OR. ;
   cNal # Work->WKSHNA_NTX   .OR. nAla # Work->WKALADI .OR. nCont > nMaxItens .OR. ;
   cEx_NBM # Work->WK_EX_NBM .OR. cEx_NCM # Work->WK_EX_NCM .or. (lIntDraw .and. cAto<>Work->WKAC) .OR. ;   //cRegTri # Work->WKREGTRI .OR.;              // GFP 07/02/2011 :: 11:42
   (lCposNVAE .And. cNve <> Work->WKNVE) .OR.; //NCF - 08/08/2011 - Classificação N.V.A.E na PLI
   cVar_Quebra # cCpo_Quebra .OR. (Avflags("DESTAQUE_QUEBRA_LI") .AND. cVar_QuebEYJ # cCpo_QuebEYJ)

   lQuebrou:=.T.
ENDIF

RETURN lQuebrou
*----------------------------------------------------------------------------
Function G_Tela4()
*----------------------------------------------------------------------------
LOCAL MPos:= 18, aBotoes := {}
LOCAL MSalvaFilter:= TPo_Num, MRecno:= RECNO(), cTot
LOCAL nRetorno, oDlg, oMark, mret
LOCAL _LIT_CC := AVSX3("W0__CC")[5]
LOCAL _PictItem := ALLTRIM(X3PICTURE("B1_COD"))
LOCAL _PictPGI  := ALLTRIM(X3PICTURE("W4_PGI_NUM"))
LOCAL _PictSI   := ALLTRIM(X3PICTURE("W0__NUM"))
Local oPanCFinal //LRL 23/03/04
IF PLI .OR. GI_PORTARIA78 .OR. GI_PORTARIA15 .OR. GI_ENTREPOST
   cTot:=STR0082 //'Total PLI   '
ELSE
   cTot:=STR0083 //'Total G.I   '
ENDIF

MControla := .T.
IF nQual # 4
   DBSELECTAREA("WORK")
   SET FILTER TO WKFLAG == .T.
ENDIF
//FDR - 14/10/11 - NVEs na fase PLI
If lCposNVAE
   If !ValNVEPLI()
      Return
   EndIf
EndIf

IF ! GI400_LIS()
   MControle:=.F.
   MRetorno :=0
ENDIF

aCampos1:= aCampos
aCampos:={}
aCampos:={ {"WKSEQ_LI"   ,"",STR0084},; //"Seq.LI"
           {"WKTEC"      ,"",STR0085,"@R 9999.99.99"} ,; //"NCM"
           {"WKSHNA_NTX" ,"",STR0086},; //"NALADI"
           {"WKALADI"    ,"",STR0087 },; //"ALADI"
           {"WKPO_NUM"   ,"",OemToAnsi(STR0020),_PictPO},; //"N§ P.O."
           {"WKCC"       ,"",_LIT_CC},;
           {"WKSI_NUM"   ,"",OemToAnsi(STR0049),_PictSI} } //"N§ S.I."

If lIntDraw .and. Empty(M->W4_ATO_CON) .and. lMostraAC
   AADD(aCampos,{"WKAC"      ,"",AVSX3("ED0_AC",5)}               ) //"Ato Concessorio"
EndIf
AADD(aCampos,{"WKPOSICAO"  ,"",STR0022})//AWR 10/02/99 //"Posi‡Æo"
AADD(aCampos,{"WKCOD_I"    ,"",STR0023,_PictItem}) //"Item"
AADD(aCampos,{"WKPART_N"   ,"",STR0050}) //"Part Number"
AADD(aCampos,{"WKFAMILIA"  ,"",STR0024}) //"Familia"
AADD(aCampos,{"WKDESCR"    ,"",STR0088}) //"Descricao p/ P.L.I."
AADD(aCampos,{{||Work->WKFABR+' '+Work->WKNOME_FAB},"",STR0026}) //"Fabricante"

IF EICLOJA()
   EICAddLoja(aCampos, "W5_FABLOJ",, STR0026)
ENDIF

AADD(aCampos,{{||Work->WKFORN+' '+Work->WKNOME_FOR},"",STR0028}) //"Fornecedor"

IF EICLOJA()
   EICAddLoja(aCampos, "W5_FORLOJ",, STR0028)
ENDIF

AADD(aCampos,{"WKQTDE"     ,"",STR0029,_PictQtde}) //"Quantidade"
IF lMV_EIC_EAI//AWF - 30/06/2014
   AADD(aCampos,{"WKUNI"    ,"",AVSX3("W3_UM"     ,AV_TITULO)})
   AADD(aCampos,{"WKQTSEGUM","",AVSX3("W3_QTSEGUM",AV_TITULO),AVSX3("W3_QTSEGUM" ,6)})
   AADD(aCampos,{"WKSEGUM"  ,"",AVSX3("W3_SEGUM"  ,AV_TITULO)})
   AADD(aCampos,{"WKFATOR"  ,"","Fator Conv 2UM"  ,AVSX3("J5_COEF",6) })
ENDIF
AADD(aCampos,{"WKPRECO"    ,"",STR0089,_PictPrUn}) //'Preco Unit rio'
AADD(aCampos,{"WKPESO_L"   ,"",STR0090,cPictPeso}) //'Peso Unit rio'
//FSM - 01/09/2011 - "Peso Bruto Unitário"
If lPesoBruto
   aAdd(aCampos,{"WKW5PESOBR",,AVSX3("W5_PESO_BR",5),AVSX3("W5_PESO_BR",6)})
EndIf
If AvFlags("RATEIO_DESP_PO_PLI")
   AADD(aCampos,{"WKFRETE" ,,AVSX3("W5_FRETE",5),AVSX3("W5_FRETE",6)}) //"Frete"
   AADD(aCampos,{"WKSEGUR",,AVSX3("W5_SEGURO",5),AVSX3("W5_SEGURO",6)}) //"Seguro"
   AADD(aCampos,{"WKINLAN",,AVSX3("W5_INLAND",5),AVSX3("W5_INLAND",6)}) //"Inland"
   AADD(aCampos,{"WKDESCO",,AVSX3("W5_DESCONT",5),AVSX3("W5_DESCONT",6)}) //"Desconto"
   AADD(aCampos,{"WKPACKI",,AVSX3("W5_PACKING",5),AVSX3("W5_PACKING",6)}) //"Packing"
EndIf
AADD(aCampos,{"WKDT_EMB"   ,"",STR0075}) //'Embarque'
AADD(aCampos,{"WKDT_ENTR"  ,"",STR0077 }) //'Entrega'

//AOM - 09/04/2011
If lOperacaoEsp
   AADD(aCampos,{"W5_CODOPE" ,"",AVSX3("W5_CODOPE",AV_TITULO) })
   AADD(aCampos,{"W5_DESOPE" ,"",AVSX3("W5_DESOPE",AV_TITULO) })
EndIf

//GFP 20/10/2010
aCampos := AddCpoUser(aCampos,"SW5","2")

nBrowse:=3
If lInvAnt .And. nBasePLI == 1 //DRL - 16/09/09 - Invoices Antecipadas
   ASIZE(aCampos, Len(aCampos)+1)
   nxPosBrw := If(nQual==4,04,05)
   aIns(aCampos,nxPosBrw)
   aCampos[nxPosBrw] := {"WKINVOIC","","Inv.Antecip."}
EndIf
IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"BROWSE"),)//CES 28/08/01

Work->(DBSETORDER(nOrderWK))

aadd(aBotoes,{"BMPTABLE",{|| CalcTotSeqLI("PLI")}, STR0271, STR0271}) //Calcula Totais da LI
aadd(aBotoes,{"BMPTABLE",{|| GI400Anuent()}, STR0210, STR0210}) //Orgão Anuente


oMainWnd:ReadClientCoors()
DEFINE MSDIALOG oDlg TITLE STR0091 ; //'Conferˆncia Final'
                     FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight -10 ;
                     OF oMainWnd PIXEL

IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"TELA CONFERENCIA FINAL"),)//ASR 02/03/2006

@01,01 MsPanel oPanCFinal Prompt "" Size 25,40 of oDlg
@8,006 SAY STR0068  SIZE 45,8 OF oPanCFinal PIXEL //"No. P.L.I "
@8,132 SAY STR0069        SIZE 45,8 OF oPanCFinal PIXEL //"Data"
@21,006 SAY cTot + MMoeda SIZE 65,8 OF oPanCFinal PIXEL //"FOB Total"
@21,132 SAY STR0092 SIZE 45,8 OF oPanCFinal PIXEL //'Peso Total '

@8,045 MSGET M->W4_PGI_NUM PICT _PictPgi  WHEN .F. SIZE 60,8 OF oPanCFinal PIXEL
@8,164 MSGET M->W4_PGI_DT  PICT "@D"      WHEN .F. SIZE 35,8 OF oPanCFinal PIXEL
@21,045 MSGET MTotal        PICT cPictFob  WHEN .F. SIZE 65,8 OF oPanCFinal PIXEL RIGHT
@21,164 MSGET MTotPeso      PICT "@E 99999,999,999,999.9999999" WHEN .F. SIZE 80,8 OF oPanCFinal PIXEL RIGHT
//If nQual # 4
//@6,(oDlg:nClientWidth-6)/2-40 BUTTON OemToAnsi(STR0093) SIZE 34,11 ACTION (If(DbuGI400B()=0,oDlg:End(),)) OF oPanCFinal PIXEL //"Grava PLI"
/* Identidade visual - mesma operação da ação salvar.
@19,(oDlg:nClientWidth-6)/2-40 BUTTON OemToAnsi(STR0093) SIZE 34,11 ACTION (If((mret:=DbuGI400B())=0,oDlg:End(),)) OF oPanCFinal PIXEL //"Grava PLI"   // GFP - 04/03/2015*/
//Else
//    @16,(oDlg:nClientWidth-6)/2-40 BUTTON OemToAnsi(STR0093) SIZE 34,11 ACTION (If(GravaGI400(),oDlg:End(),)) PIXEL
//EndIf


// Este botao somente sera habilitado Quando for PLI/LI e no caso de ser uma alteracao
// habilitara tambem para "LI" o WP_LSI<>"1", ou seja a LSI tera esta opcao na capa,
// atraves da teclal F3.

//if ( (cRotinaOPC <> "LSI") .AND. (cRotinaOPC=="LI" .AND. SWP->WP_LSI<>"1") )
//Botões "Orgao Anuente" e "Calcula Totais da LI" retirados e adicionados na Lista de Acoes
//if cRotinaOPC == "LI"
//   @19,(oDlg:nClientWidth-6)/2-100 BUTTON OemToAnsi(STR0210) SIZE 50,11 ACTION (GI400Anuent()) PIXEL //"Orgao Anuente"
//endif

//@19,(oDlg:nClientWidth-6)/2-160 BUTTON STR0271 SIZE 50,11 ACTION (CalcTotSeqLI("PLI")) PIXEL // Calcula Seq.LI - BHF- 30/07/08 //#define STR0271 "Calcula Totais da L.I."

IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"ANTES_MSSELECT"),)//ASK 28/12/2007

oMark:= MsSelect():New("Work","WKFLAGWIN",,aCampos,@lInverte,@cMarca,{45,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2})
Work->(DbGoTop())
oPanCFinal:Align:=CONTROL_ALIGN_TOP
oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
oMark:oBrowse:Refresh() //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,;
                                {||If((mret:=DbuGI400B())=0,oDlg:End(),)},;
                                {||oDlg:End()},,aBotoes))
                                //Alinhamento MDI //LRL 23/03/04 //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

IF MControla
   nRetorno:= 2
   IF nQual # ALTERACAO
     SET FILTER TO WKPO_NUM = MSalvaFilter
   ENDIF
   DBGOTO(MRecno)
ELSE
   MControle:= .F.
   nRetorno := 0
   DBSELECTAREA("Work")
   AvZap("Work")
   IF lTem_DSI // JBS - 15/11/2003
      Work_SWP->(avzap())
   ENDIF
ENDIF
aCampos := {}
aCampos := aCampos1
//if ( (cRotinaOPC <> "LSI") .AND. (cRotinaOPC=="LI" .AND. SWP->WP_LSI<>"1") )
if cRotinaOPC == "LI"
   if mRet = 0
      GI400GravaEIT()    // Grava os registro do Work_EIT no EIT
   endif
endif

IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"FIM_TELA4"),)

RETURN nRetorno
*-----------------------*
FUNCTION GI400GravaEIT()//FSY - Ajustes para gravar corretamente os registros na WORK_EIT
*-----------------------*
//LOCAL cFilEIT:=xFilial("EIT")
Work_EIT->(dbgotop())

Do While work_EIT->(!Eof())

   If Work_EIT->EIT_RECNO > 0
      EIT->(dbGoTo( WORK_EIT->EIT_RECNO  ))
   Else
      EIT->(dbAppend())
   EndIf

   If Work_EIT->EIT_FLAG
      RecLock("EIT",.F.)
      EIT->(dbDelete())
   Else
      RecLock("EIT",.F.)
      AvReplace("WORK_EIT","EIT")
   End If

   EIT->(MsUnlock())
   WORK_EIT->( DbSkip() )

EndDo

Work_EIT->(avzap())
RETURN .T.
*--------------------------*
FUNCTION GI400Anuent()   // Criada por RS em 25/10/05
*--------------------------*
// Funcao que le o EIT e carrega todos os orgaos anuentes na Work_EIT e da manutencao
// para novos registros do cadastro de Processos Anuentes.
// o EIT e gravado para integração com o SISCOMEX atraves do EICOR100, que leva estes
// registros para a tabela PROCESSO_ANUENTE do banco REGIMP.MDB. Quando o EICOR100 le
// o EIT gera o A1Pxxxxx.dbf (temporario) que sera lido posteriormente pelo SISC
// que grava no PROCESSO_ANUENTE do banco REGIMP.MDB.

LOCAL lInfOrgAnu

SX3->(dbsetorder(2))
lInfOrgAnu:=SX3->(DBSEEK("B1_ORG_ANU")) .AND. SX3->(DBSEEK("B1_PRO_ANU"))

// Carrega do cadastro de itens (SB1) os campos de anuencia somente para quem tem os campos
// no SX3.

IF lInfOrgAnu   // APENAS PARA QUEM TEM INFORMACOES DE ORGAOS ANUENTES NO SX3
   Processa({||GI400grvOrgAnu()})
ENDIF

GI400BroWKEIT()
RETURN .T.
*--------------------*
FUNCTION GI400EITGr(cPgi)
*--------------------*
LOCAL cPgi_Num:=IF(cPgi==NIL,M->W4_PGI_NUM,cPgi)
Local lGrava := .T.
IF EIT->EIT_PGI_NU <> cPgi_Num
   RETURN .T.
ENDIF
/*
IF ! Work_EIT->(dbseek(cPgi_Num+EIT->EIT_SEQ_LI+EIT->EIT_NUMERO))
   Work_EIT->(dbappend())
   AvReplace("EIT","Work_EIT")
ENDIF
*/

// ** PLB 23/02/07
Work_EIT->( DBSeek(cPgi_Num+EIT->EIT_SEQ_LI+EIT->EIT_NUMERO) )
Do While Work_EIT->( !EoF()  )  .And.  Work_EIT->( EIT_PGI_NU+EIT_SEQ_LI+EIT_NUMERO ) == EIT->( EIT_PGI_NU+EIT_SEQ_LI+EIT_NUMERO )
   If Work_EIT->EIT_ORGAO == EIT->EIT_ORGAO
      lGrava := .F.
      Exit
   EndIf
   Work_EIT->( DBSkip() )
EndDo
If lGrava
   Work_EIT->(dbappend())
   AvReplace("EIT","Work_EIT")
   WORK_EIT->EIT_RECNO := EIT->(RecNo())      //FSY - 03/10/2013 - Campo para orientação das WORK_EIT e WORK_TMP
   WORK_EIT->EIT_WKREC := Work_EIT->(RecNo()) //FSY - 03/10/2013 - Campo para orientação das WORK_EIT e WORK_TMP
EndIf
// **

RETURN .T.

*----------------------*
FUNCTION GI400grvOrgAnu
*----------------------*
LOCAL cSeqLi:=Work->WKSEQ_LI
LOCAL nRecWK := Work->(RECNO()), nIndWK:=Work->(INDEXORD())

SB1->(dbsetorder(1))

ProcRegua(Work->(EasyRecCount("Work")))

cFilSB1:=xFilial("SB1")
Work->(DBSETORDER(5))   // Muda o indice do work para SEQ. da LI
Work->(DBSEEK(cSeqLi))
WHILE ! Work->(EOF()) .AND. Work->WKSEQ_LI == cSeqLi
  IncProc(STR0211) // Gravando dados de Processo Anuente

  IF SB1->(dbseek(cFilSB1+Work->WKCOD_I)) .AND. ! EMPTY(SB1->B1_ORG_ANU)
     IF ! Work_EIT->(DBSEEK(M->W4_PGI_NUM+Work->WKSEQ_LI+SB1->B1_PRO_ANU))
        Work_EIT->(dbappend())
        Work_EIT->EIT_NUMERO:=SB1->B1_PRO_ANU
        Work_EIT->EIT_ORGAO:= SB1->B1_ORG_ANU
        Work_EIT->EIT_PGI_NU:=M->W4_PGI_NUM
        Work_EIT->EIT_SEQ_LI:=Work->WKSEQ_LI
     ENDIF
  ENDIF
  Work->(dbskip())
END

Work->(DBSETORDER(nIndWK))
Work->(DBGOTO(nRecWK))
RETURN NIL

//FSY - 03/10/2013 - Ajustada para que os orgões anuente sejam editaveis de forma correta utilizando WORK_TMP para visualizar, WORK_EIT como intermedio da tabela EIT
*-------------------------*
FUNCTION GI400BroWKEIT(cPgi,cSeqLi)
*-------------------------*
Local aTB_Campos,cTitulo:=STR0218 //"Manutencao de Processos Anuentes"
Local nPos,nTam
Local bOkEIT    :={||nOpcEIT:=1,oDlgEI:End()},nOpcEIT:=0
Local bCancelEIT:={||nOpcEIT:=0,oDlgEI:End()},nAlias:=SELECT()
Local cUsado:=Posicione("SX3",2,"EIT_ORGAO","X3_USADO")
Local aNoFields := {}
Local aAreaWork := GetArea()
Local aOrdWork	:= SaveOrd("Work")
local cFileTemp
Local aStru_TMP := {}
Local nRegCount
Private aTRBSemSX3 := {}
Private lValidRepetidos:=.T.,aCpos:={},nLargura:=300
Private WP_SEQ_LI

nLargura := 200

Private aCampos := ARRAY(Work_EIT->(FCOUNT())), aHeader := {},aEdita :={"EIT_NUMERO","EIT_ORGAO"}

aHeader:={{AvSx3("EIT_NUMERO",5),"EIT_NUMERO",AvSx3("EIT_NUMERO",6),AvSx3("EIT_NUMERO",3),0,"GI400EITValid()",cUsado ,"C","EIT"},;
          {AvSx3("EIT_ORGAO" ,5),"EIT_ORGAO" ,AvSx3("EIT_ORGAO" ,6),AvSx3("EIT_ORGAO" ,3),0,"GI400EITValid()",cUsado ,"C","EIT"}}
If EIT->(FieldPos("EIT_TRATA")) # 0 .AND. EIT->(FieldPos("EIT_CDSTA")) # 0 .AND. EIT->(FieldPos("EIT_STAT")) # 0 .AND.;
   EIT->(FieldPos("EIT_DTANU")) # 0 .AND. EIT->(FieldPos("EIT_DTVAL")) # 0 .AND. EIT->(FieldPos("EIT_TEXTO")) # 0  // GFP - 20/02/2015
   aAdd(aHeader,{AvSx3("EIT_TRATA",5),"EIT_TRATA" ,AvSx3("EIT_TRATA",6),AvSx3("EIT_TRATA",3),0,"",cUsado ,"C","EIT"})
   aAdd(aHeader,{AvSx3("EIT_STAT",5) ,"EIT_STAT"  ,AvSx3("EIT_STAT",6) ,AvSx3("EIT_STAT",3) ,0,"",cUsado ,"C","EIT"})
   aAdd(aHeader,{AvSx3("EIT_DTANU",5),"EIT_DTANU" ,AvSx3("EIT_DTANU",6),AvSx3("EIT_DTANU",3),0,"",cUsado ,"D","EIT"})
   aAdd(aHeader,{AvSx3("EIT_DTVAL",5),"EIT_DTVAL" ,AvSx3("EIT_DTVAL",6),AvSx3("EIT_DTVAL",3),0,"",cUsado ,"D","EIT"})
EndIf
lVisual    := (nQual == VISUAL)

If lVisual
   cTitulo+=" LI nr: "+ALLTRIM(cPgi)+'-'+cSeqLi
EndIf

bRecSemX3 := {|| AEval(aTRBSemSX3,{|x| M->&(x[1]) := NIL } ), .T.}
cSeek     := xFilial("EIT")+IIF(cSeqLI==NIL,M->W4_PGI_NUM+Work->WKSEQ_LI,cPgi+cSeqLI)
bWhile    := {||cSeek}
bCond     := {||.T.}
bAction1  := {||.F.}
bAction2  := {||.F.}

dbSelectArea("EIT")
aStru_TMP := {{"EIT_NUMERO","C",len(EIT->EIT_NUMERO),0},;
              {"EIT_ORGAO" ,"C",len(EIT->EIT_ORGAO),0 },;
              {"EIT_FLAG"  ,"L",1                  ,0 },;
              {"EIT_WKREC" ,"N",7                  ,0 }}
If EIT->(FieldPos("EIT_TRATA")) # 0 .AND. EIT->(FieldPos("EIT_CDSTA")) # 0 .AND. EIT->(FieldPos("EIT_STAT")) # 0 .AND.;
   EIT->(FieldPos("EIT_DTANU")) # 0 .AND. EIT->(FieldPos("EIT_DTVAL")) # 0 .AND. EIT->(FieldPos("EIT_TEXTO")) # 0  // GFP - 20/02/2015
   aAdd(aStru_TMP,{"EIT_TRATA","C",AvSx3("EIT_TRATA",3),0})
   aAdd(aStru_TMP,{"EIT_STAT" ,"C",AvSx3("EIT_STAT",3) ,0})
   aAdd(aStru_TMP,{"EIT_DTANU","D",AvSx3("EIT_DTANU",3),0})
   aAdd(aStru_TMP,{"EIT_DTVAL","D",AvSx3("EIT_DTVAL",3),0})
EndIf

cFileTemp := E_CriaTrab(,aStru_TMP,"Work_TMP") //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados

IF !USED()
   Help(" ",1,"E_NAOHAREA")
   RETURN .F.
ENDIF

M->WP_SEQ_LI:=IF(cSeqLI==NIL,Work->WKSEQ_LI,cSeqLI)
M->W4_PGI_NUM:=IF(cSeqLI==NIL,M->W4_PGI_NUM,cPgi)
Work_EIT->(dbseek(M->W4_PGI_NUM+M->WP_SEQ_LI))

GI400GrvTemp(.T.)
dbSelectArea("Work_TMP")
Work_TMP->(DBGOTOP())

nPos:= 3
nRegCount:= Work_TMP->(EasyRecCount("Work_TMP"))
IF lVisual
   nPos := 2
ELSEIF  nRegCount > 0
   nPos := 4
ELSEIF nRegCount == 0
   nPos:= 3
   Work_TMP->(DBAppend())
ENDIF

DEFINE MSDIALOG oDlgEI;
TITLE cTitulo ;
FROM oMainWnd:nTop   +200,oMainWnd:nLeft +1 ;
TO   oMainWnd:nBottom -100,oMainWnd:nRight-nLargura OF oMainWnd PIXEL

//Work_EIT->(oMarkEI:=MsGetDB():New(15,1,(oDlgEI:nClientHeight-6)/2,(oDlgEI:nClientWidth-4)/2,nPos,"GI400EITValid()","","",.T.,,,.F.,,"Work_TMP"))
//Work_EIT->(oMarkEI:=MsGetDB():New(15,1,(oDlgEI:nClientHeight-4)/2,(oDlgEI:nClientWidth-2)/2,nPos,"GI400EITValid()","","",.T.,,,.F.,,"Work_TMP"))

// GCC - 10/06/2013 - Alteração da validação de linha por campo, pois por linha não estava sendo validado corretamente.
Work_EIT->(oMarkEI:=MsGetDB():New(15,1,(oDlgEI:nClientHeight-4)/2,(oDlgEI:nClientWidth-2)/2,nPos,,"","",.T.,,,.F.,,"Work_TMP","GI400EITValid()"))

oMarkEI:oBrowse:bwhen:={||(dbSelectArea("Work_TMP"),.t.)}
oMarkEI:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlgEI ON INIT EnchoiceBar(oDlgEI,bOkEIT,bCancelEIT) CENTERED

If nOpcEIT==1 .and. !lVisual
   GI400GrvTemp(.F.)
End If

WORK_TMP->(E_EraseArq(cFileTemp))

select(nAlias)
Return .T.

*--------------------------*
Function GI400EITValid()
*--------------------------*
Local cGet:=ReadVar(), cVar
cVar:=alltrim(subStr(cGet,4))

Do Case
   Case Lastkey()=27
        Return(.T.)

   Case cVar == "EIT_NUMERO"
        IF EMPTY(M->EIT_NUMERO)
           MSGINFO(STR0216,STR0062)   // "Numero Processo nao Preenchido"
           RETURN .F.
        ENDIF
/*
        nRec:=Work_EIT->(RECNO())
        IF Work_EIT->(dbseek(M->W4_PGI_NUM+Work->WKSEQ_LI+M->EIT_NUMERO))
           MSGINFO(STR0211,STR0062)  // "Numero Processo ja Cadastrado"
           Work_EIT->(dbgoto(nRec))
           RETURN .F.
        ENDIF
        Work_EIT->(dbgoto(nRec))
*/
   Case cVar == "EIT_ORGAO"
        IF  EMPTY(M->EIT_ORGAO)
            MSGINFO(STR0213,STR0062)  // "Orgao Anuente nao Preechido"
            RETURN .F.
        ENDIF

        //JAP - 13/09/06
        IF ! SX5->(DBSEEK(xFilial("SX5")+"AO"+M->EIT_ORGAO))
           MSGINFO(STR0214,STR0062)  //"Orgao Anuente nao encontrado"
           return .f.
        ENDIF
Otherwise
   If Empty(Work_TMP->EIT_NUMERO) .and. Empty(Work_TMP->EIT_ORGAO) .AND. !Work_TMP->EIT_FLAG //DELETE
      MSGINFO(STR0215,STR0062)
      Return .F.
   EndIf
EndCase
Return .t.
*----------------------------------------------------------------------------
FUNCTION DbuGI400B(PModo)
*----------------------------------------------------------------------------
LOCAL ErroPO, MRecno := Work->( RECNO() ), MRetorno := 1, nLastKey,i
LOCAL cPointE:="EICGI01E", cPointS:="EICGI01S",cPos:=""
LOCAL lPointE:=EasyEntryPoint(cPointE), lPointS:=EasyEntryPoint(cPointS)
Local aPOsRateio, nPosPO, nPesoPO, nPesoUni, nValorItem, nPesoItem

#DEFINE DBU_SAIR   1
#DEFINE DBU_GRAVAR 2

PModo:=4
nLastKey:=DBU_GRAVAR

lVolta:=.F.

//** AAF 28/09/05 - Validação do Fundamento Legal de Drawback.
If lIntDraw .AND. Empty(M->W4_ATO_CON) .AND. M->W4_REGIMP == '16' //Fundamento Legal de Drawback
   nOldRec:= Work->( RecNo() )
   lTemAC:= .F.

   Work->( dbGoTop() )
   If Work->( !EoF() .AND. !BoF() )
      lRet := .F.
      Do While !Work->( EoF() )
         If !Empty(Work->WKAC)
            lTemAC := .T.
            EXIT
         Endif

         Work->( dbSkip() )
      EndDo
   EndIf
   Work->( dbGoTo(nOldRec) )

   If !lTemAC
      MsgStop(STR0207)//"Ao menos um dos itens deve estar atrelado a Ato Concessório, para P.L.I. com Fundamento Legal 16(Drawback)."
      RETURN 999
   Endif
Endif
//**

TInland := TFreteIntl := TPacking := TDesconto := TOutDesp := 0
aOldDesp := {0,0,0,0,0,0}

aOrd := SaveOrd({"SW2","SW3"})
aPOsRateio := {}
nOldRec:= Work->( RecNo() )
Work->( dbGoTop() )
Do While !Work->( EoF() )

  If (nPosPO := aScan(aPOsRateio,{|X| X[1] == WORK->WKPO_NUM})) == 0
    nPesoPO := 0

    SW2->(dbSetOrder(1))
    SW2->(dbSeek(xFilial("SW2")+WORK->WKPO_NUM))

    SW3->(dbSetOrder(8))
    SW3->(dbSeek(xFilial("SW3")+WORK->WKPO_NUM))
    Do While SW3->(!Eof() .AND. W3_FILIAL+W3_PO_NUM == xFilial("SW3")+WORK->WKPO_NUM)

    If SW3->W3_SEQ = 0
        nPesoUni := If(SW3->(FieldPos("W3_PESOL")) # 0,SW3->W3_PESOL, B1Peso(SW3->W3_CC,SW3->W3_SI_NUM,SW3->W3_COD_I,SW3->W3_REG,SW3->W3_FABR,SW3->W3_FORN))
        nPesoPO  += Round(SW3->W3_QTDE * nPesoUni,AvSX3("W6_PESOL",AV_DECIMAL))
    EndIf

    SW3->(dbSkip())
    EndDo

    aAdd(aPOsRateio,{WORK->WKPO_NUM,SW2->W2_FOB_TOT,nPesoPO,SW2->W2_INLAND,SW2->W2_DESCONT,SW2->W2_PACKING,SW2->W2_OUT_DES,SW2->W2_FRETEIN,SW2->W2_SEGURIN,SW2->W2_RAT_POR}) //LRS - 22/08/2016 - Adicionado no array o seguro da SW2
    nPosPO := Len(aPOsRateio)
  EndIf

  nPesoItem := Round(Work->WKQTDE * Work->WKPESO_L,AvSX3("W6_PESOL",AV_DECIMAL))
  nValorItem:= Round(Work->WKQTDE * Work->WKPRECO,2)

  aOldDesp[1] += WORK->WKINLAN
  aOldDesp[2] += WORK->WKFRETE
  aOldDesp[3] += WORK->WKPACKI
  aOldDesp[4] += WORK->WKDESCO
  aOldDesp[5] := M->W4_OUT_DES //Esta despesa não possui campo nos itens, então pegar o total da capa para mostrar na tela
  aOldDesp[6] += WORK->WKSEGUR

  TInland    += aPOsRateio[nPosPO][4] * nValorItem / aPOsRateio[nPosPO][2]
  TDesconto  += aPOsRateio[nPosPO][5] * nValorItem / aPOsRateio[nPosPO][2]
  TPacking   += aPOsRateio[nPosPO][6] * nValorItem / aPOsRateio[nPosPO][2]
  TOutDesp   += aPOsRateio[nPosPO][7] * nValorItem / aPOsRateio[nPosPO][2]
  TFreteIntl += aPOsRateio[nPosPO][8] * nPesoItem / aPOsRateio[nPosPO][3]
  TSeguro    += aPOsRateio[nPosPO][9] * nPesoItem / aPOsRateio[nPosPO][3]  //LRS - 22/08/2016

  Work->( dbSkip() )
EndDo
Work->( dbGoTo(nOldRec) )
RestOrd(aOrd)

//If (M->W4_INLAND+M->W4_FRETEIN+M->W4_PACKING+M->W4_DESCONT+M->W4_OUT_DES >0 .AND. TInland+TFreteIntl+TPacking+TDesconto+TOutDesp==0 .OR.;
//(aOldDesp[1] == TInland .AND.aOldDesp[2] == TFreteIntl .AND. aOldDesp[3] == TPacking .AND. aOldDesp[4] == TDesconto .AND. aOldDesp[5] == TOutDesp .AND. aOldDesp[6] == TSeguro) .OR.;
//!MsgYesNo("Deseja carregar as despesas dos POs para esta P.L.I.?"))
  TInland   := aOldDesp[1]
  TFreteIntl:= aOldDesp[2]
  TPacking  := aOldDesp[3]
  TDesconto := aOldDesp[4]
  TOutDesp  := aOldDesp[5]
  TSeguro   := aOldDesp[6]
//EndIf

IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"VERIFICA_SALDO"),)

IF lVolta
   RETURN 999
ENDIF

DO CASE
    CASE PModo < 4
         MRetorno:= 1

    CASE nLastKey  = DBU_SAIR
         MRetorno := 0

    CASE nLastKey  = DBU_GRAVAR

          IF VAL(STR(MTotal,18,2)) <= 0
             RETURN 1
          ENDIF

          IF PLI .OR. GI_PORTARIA15

            aOldDesp := {TInland,TFreteIntl,TPacking,TDesconto,TOutDesp,TSeguro}
        
            IF ! PO420Cha(MTotal,"I",,"PP")
                RETURN 1
            ENDIF
        
             M->W4_INLAND :=TInland
             M->W4_FRETEIN:=TFreteIntl
             M->W4_PACKING:=TPacking
             M->W4_DESCONT:=TDesconto
             M->W4_OUT_DES:=TOutDesp
             
             // EOB - 14/07/08 - Tratamento para incoterm com seguro
             IF lSegInc
                M->W4_SEGURO:=TSeguro
             ENDIF
			 
              If (aOldDesp[1] <> TInland .OR.;
                  aOldDesp[2] <> TFreteIntl .OR.;
                  aOldDesp[3] <> TPacking .OR.;
                  aOldDesp[4] <> TDesconto .OR.;
                  aOldDesp[5] <> TOutDesp .OR.; //Outras despesas nao tem campo nos itens...
                  aOldDesp[6] <> TSeguro) .AND.;
                  MsgYesNo("Deseja fazer o rateio das despesas para os itens da P.L.I.")

                  //Refaz os rateios em caso de alteração dos valores.
                  //Considera o critério de rateio do primeiro PO
                  //MTotal := TFreteIntl+TSeguro+TInland+TDesconto+TPacking
                  nOldRec:= Work->( RecNo() )
                  PO400RatFrSg(TFreteIntl,TSeguro,TInland,TDesconto,TPacking,MTotal,if(len(aPOsRateio)>0,aPOsRateio[1][10],"2"),WORK->(EasyRecCount("Work")),TOutDesp)
                  Work->( dbGoTo(nOldRec) )
              EndIf
			 
             //** AAF 18/07/08 - Atualização do valor FOB para Drawback em caso de incoterm EXW.
             If Type("lIntDraw") == "L" .AND. lIntDraw
                nOldRec:= Work->( RecNo() )

                Work->( dbGoTop() )
                Do While !Work->( EoF() )
                   If !Empty(Work->WKAC)
                      Work->WKVL_AC   := GI400ApVal()
                   Endif

                   Work->( dbSkip() )
                EndDo
                Work->( dbGoTo(nOldRec) )

             EndIf
             //**
          ENDIF

       //** PLB 06/08/07
       If Eval(bValFrete)
          Help(" ",1,"E_FREVALOR")  // "Valor do Frete não informado."
          RETURN 1
       EndIf
       //**

       // EOB - 14/07/08
       If Eval(bValSeguro)
          Help(" ",1,"E_SEGVALOR")  // "Valor do Seguro não informado."
          //Nao bloqueia a inclusao da PLI, apenas avisa que nao foi informado o valor do Seguro.
       EndIf

       IF EasyEntryPoint("EICGI400") //ASK 17/12/2007 - Inclusão do ponto de entrada que existia na v609A
          IF !ExecBlock("EICGI400",.F.,.F.,"VALIDA_PLI")
             RETURN 1
          ENDIF
       EndIf

       IF MsgYesNo(STR0095,STR0096) # .T. //'Confirma a Gravação ? '###'Fechamento'
          MRetorno := 1
       ELSEIf lPointE .And. !ExecBlock(cPointE)
          MRetorno := 1
       ELSE
          DO WHILE .T.

             IF !GI400GetNewPGI()
                MRetorno:= 1
                EXIT
             ENDIF
             //NCF - 08/08/2011 - Classificação N.V.A.E na PLI
             If lCposNVAE
                GI400EIMGrava()
             EndIf
             MsAguarde({|| GI_Grava({|msg| MsProcTxt(msg)},Inclui) },STR0017) //"Manutencao de L.I."

             If lInvAnt .AND. (nQual # 4 .AND. nBasePLI == 1) //DRL - 16/09/09 - Invoices Antecipadas
                nxOrdEW5:=EW5->(IndexOrd())
                EW5->(dBSetOrder(2))
                WORK->(dbGoTop())
                While WORK->(!Eof())
                      If EW5->(dbSeek(cFilEW5+WORK->WKPO_NUM+WORK->WKPOSICAO+WORK->WKINVOIC+WORK->WKFORN+EICRetLoja("Work","W5_FORLOJ")))
                         EW5->(RecLock("EW5",.F.))
                         If WORK->WKFLAG // item marcado
                              EW5->EW5_PGI_NU := M->W4_PGI_NUM
                         Else
                              EW5->EW5_PGI_NU := Space(Len(EW5->EW5_PGI_NU))
                         EndIf
                         EW5->(MSUNLOCK())
			      	EndIf
                      WORK->(dbSkip())
                EndDo
                EW5->(dBSetOrder(nxOrdEW5))
             EndIf
             IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"GI_GRAVA"),)

             IF !Inclui
                GravaGI400()
             ENDIF
             IF AvFlags("EIC_EAI")
                /* Verifica se existem pedidos originados por processo de entreposto e
                   retorna os pedidos válidos para a geração da programação de entregas*/
                aEnv_PO:= PO420PedOri(aEnv_PO)
                For i = 1 To Len(aEnv_PO) //SSS -  REG 4.5 03/06/14
                   If !EICPO420(.T.,4,,"SW2",.F.,aEnv_PO[I])// EICPO420(lEnvio,nOpc,aCab,cAlias,lWk,cPo_num)
                      cPos+=ALLTRIM(aEnv_PO[I])+", "
                   EndIf
                Next
                /*If Empty(cPos)
                   MsgInfo("Integrado com Sucesso") //Saldo eliminado com sucesso
                Else*/
                If !Empty(cPos)
                   MsgInfo("Acesse os Purchase orders "+cpos+" para realização dos ajustes necessários.")
                EndIf
                aEnv_PO:= {}
             ENDIF
             If(lPointS,ExecBlock(cPointS),)
             MRetorno  := 0
             MControla := .F.

             EXIT

          ENDDO
       ENDIF

    OTHERWISE
       MRetorno:= 1
ENDCASE

RETURN MRetorno
*-------------------------------------------------------------*
FUNCTION GI400GetNewPGI()//AWR 16/08/2002
*-------------------------------------------------------------*
LOCAL bOK:=AVSX3("W4_PGI_NUM",7)//Devolve a Validacao do SX3: X3_VALID
LOCAL nOpca:=0

IF EVAL(bOK)
   RETURN .T.
ENDIF

bOK:={||IF( EVAL(AVSX3("W4_PGI_NUM",7)) , (nOpca:=1,oDlg:End()) ,) }

DEFINE MSDIALOG oDlg TITLE STR0272 From 0,0 To 8,35 OF oMainWnd //STR0272 "Alteracao do No. da P.L.I."

   @ 1.8,.8 SAY AVSX3("W4_PGI_NUM",5) //X3_TUTULO
   @ 1.8, 5 MSGET M->W4_PGI_NUM SIZE 50,8 PICTURE AVSX3("W4_PGI_NUM",6) F3 ALLTRIM(AVSX3("W4_PGI_NUM",8))//X3_PICTURE //X3_F3

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOK, {|| nOpca:=0,oDlg:End()} ) CENTERED

M->W4_PGI_NUM:=ALLTRIM(M->W4_PGI_NUM)
M->W4_PGI_NUM:=M->W4_PGI_NUM+SPACE( LEN(SW4->W4_PGI_NUM)-LEN(M->W4_PGI_NUM) )//X3_TAMANHO
TNro_Pgi     :=M->W4_PGI_NUM

IF nOpca = 1
   RETURN .T.
ENDIF

RETURN .F.

*----------------------------------------------------------------------------
FUNCTION GI_ValidPO()
*----------------------------------------------------------------------------
LOCAL _IniPO   := SPACE(LEN(SW7->W7_PO_NUM))
LOCAL nRegWork := WORK->(EasyRecCount("Work"))     // igor chiba 08/05/09   armazenar total registros da work

lValid:=.T.
IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"VALID_GET_PO"),)
IF !lValid
   RETURN .F.
ENDIF

IF PLI
   IF LEN(MTabPO) = 0  .OR.  nRegWork = 0 // igor chiba 08/05/09 carregar novamente quando mudar P.O
      TImport:= SW2->W2_IMPORT
      TConsig:= SW2->W2_CONSIG
      M->W4_IMPORT := SW2->W2_IMPORT
      M->W4_CONSIG := SW2->W2_CONSIG
      cImpCons:=SW2->W2_IMPORT+'/'+SW2->W2_CONSIG
   ENDIF

ENDIF

IF PLI
   IF TImport <> SW2->W2_IMPORT   .AND. nRegWork = 0// igor chiba 08/05/09  nao validar se nao tive itens
      HELP("",1,"AVG0000412")//"Importador do P.O. é diferente do importador da guia"
      Return .F.
   ENDIF

   IF TConsig <> SW2->W2_CONSIG  .AND. nRegWork = 0// igor chiba 08/05/09  nao validar se nao tive itens
      HELP("",1,"AVG0000413")//"Consignat rio do P.O. ‚ diferente do consignat rio da guia"
      Return .F.
   ENDIF
ENDIF

IF MMoeda = SPACE(03) .OR. nRegWork = 0// igor chiba 08/05/09 carregar novamente quando mudar P.O  e ainda nao tiver item
   MMoeda       := IF(EMPTY(M->W4_MOEDA) .OR. nRegWork = 0  ,SW2->W2_MOEDA,M->W4_MOEDA)
   M->W4_MOEDA  := MMoeda
   MIncoterm    := IF(EMPTY(M->W4_INCOTER) .OR. nRegWork = 0,SW2->W2_INCOTER,M->W4_INCOTER)
   M->W4_FREINC := SW2->W2_FREINC //LRS - 04/07/2016 - Carregar o frete incluso
   If AvFlags("RATEIO_DESP_PO_PLI")
      M->W4_SEGINC := SW2->W2_SEGINC //LRS - 04/07/2016 - Carregar o Seguro incluso
   EndIF
   M->W4_INCOTER:= MIncoterm
   MForn        := SW2->W2_FORN
   cExporta     := SW2->W2_EXPORTA
   If EICLoja()
      cExportLoj:= SW2->W2_EXPLOJ
      MFornLoja := SW2->W2_FORLOJ
   EndIf
   IF EMPTY(M->W4_COND_PA) .OR. nRegWork = 0
     MCond_Pag    := SW2->W2_COND_PA
     M->W4_COND_PA:= MCond_Pag
     MDias_Pag    := SW2->W2_DIAS_PA
     M->W4_DIAS_PA:= MDias_Pag
   ENDIF
   SY6->(DBSETORDER(1))
   SY6->(DBSEEK(xFILIAL("SY6")+MCond_Pag+STR(MDias_Pag,3,0)))
   MDesc_Pag := IF(EMPTY(M->W4_VM_COPA) .OR. nRegWork = 0 ,MSMM(SY6->Y6_DESC_P,AVSX3("Y6_VM_DESP",3),,,3) ,M->W4_VM_COPA)//W4_VM_COPA,AVSX3("Y6_VM_DESP",3),1) ,M->W4_VM_COPA)
   M->W4_VM_COPA:=MDesc_Pag

   SYR->(DBSEEK(xFilial()+SW2->W2_TIPO_EM+SW2->W2_ORIGEM+SW2->W2_DEST))
 // fim igor chiba 08/05/09 carregar novamente quando mudar P.O  e ainda nao tiver item
ENDIF

IF GI_APROVADA .AND. ( EMPTY(MCond_Pag) .OR. nRegWork = 0 ) //igor chiba 08/05/09 carregar novamente quando mudar P.O  e ainda nao tiver item
   MCond_Pag := W2_COND_PAG
   MDias_Pag := W2_DIAS_PAG
   SY6->(DBSETORDER(1))
   SY6->(DBSEEK(xFILIAL("SY6")+MCond_Pag+STR(MDias_Pag,3,0)))
   MDesc_Pag := MSMM(SY6->Y6_DESC_P,AVSX3("Y6_VM_DESP",3),,,3)
ENDIF

IF SW2->W2_MOEDA <> MMoeda .AND.  nRegWork = 0 // igor chiba 08/05/09  nao validar se nao tive itens
   HELP("",1,"AVG0000414",,MMoeda,1,27)//'A moeda deste P.O. não é '
   TPo_Num:= _IniPO
   IF GI_APROVADA
      MCond_Pag := SPACE(5)
   ENDIF
   Return .F.
ENDIF

IF (SW2->W2_FORN <> MForn .Or. (EICLoja() .And. SW2->W2_FORLOJ <> MFornLoja)) .AND.  nRegWork = 0 // igor chiba 08/05/09  nao validar se nao tive itens
   HELP("",1,"AVG0000415",,MForn+MFornLoja,1,33)//'O fornecedor deste P.O. não é '
   TPo_Num:= _IniPO
   IF GI_APROVADA
      MCond_Pag := SPACE(5)
   ENDIF
   Return .F.
ENDIF

IF (SW2->W2_EXPORTA # cExporta .Or. (EICLoja() .And. SW2->W2_EXPLOJ # cExportLoj)) .AND.  nRegWork = 0 // igor chiba 08/05/09  nao validar se nao tive itens
   HELP("",1,"AVG0000416",,cExporta+cExportLoj,1,33)//'O Exportador deste P.O. não é '
   Return .F.
ENDIF


/*IF SW2->W2_COND_PA <> MCond_Pag .OR. SW2->W2_DIAS_PA <> MDias_Pag
   HELP("",1,"AVG0000417",,MCond_Pag + '-' + STRZERO(MDias_Pag,3,0),2,02) //A condição de pagamento deste P.O. não é
   TPo_Num:= _IniPO
   IF GI_APROVADA
      MCond_Pag := SPACE(5)
   ENDIF
   Return .F.
ENDIF*/

IF .NOT. RecLock("SW2",.F.)
   SW2->(MsUnlock())
   TPo_Num:= _IniPO
   Return .F.
ENDIF

IF nBasePLI <> 1
   DBSELECTAREA("Work")
   SET FILTER TO WKPO_NUM = TPo_Num
EndIf
DBSELECTAREA("SW3")
SW3->(DBSETORDER(1))
SW3->(DBSEEK(xFilial()+TPo_Num))
MCont:= 0
aDestaque:={}

MsAguarde({|lEnd| GI_GravaItens({|msg| MsProcTxt(msg)}) },STR0018) //"Pesquisa de Itens"

DBSELECTAREA("Work")
WORK->(DBGOTOP())
IF MCont = 0
   IF nBasePLI <> 1 // EOS - Inibi msg qdo invoice antecipada
      HELP("",1,"AVG0000428")//MsgInfo(STR0109,STR0062) //'Não há itens deste pedido a serem selecionados'###"Informação"
   ENDIF
   SET FILTER TO
   IF MTotal = 0
      MMoeda := SPACE(03)
   ENDIF
   IF !lSelPo   //EOS - signigica que não está pedindo PO pois estrou com PO de ref.
      GI400Vars()
      lSelPo := .T.
   ENDIF
   Return .F.
ELSE
   IF ASCAN(MTabPO,TPo_Num) = 0
      AADD(MTabPO,TPo_Num)
//    TPos:= ALLTRIM(TPos) + TRANS(TPo_Num,_PictPO)+IF(EMPTY(TPo_Num)," ",",")
      IF PLI   .OR. GI_PORTARIA15
         MPacking   += SW2->W2_PACKING
         MFreteIntl += SW2->W2_FRETEIN
         MInland    += SW2->W2_INLAND
         MDesconto  += SW2->W2_DESCONT
         TPacking   += SW2->W2_PACKING
         TFreteIntl += SW2->W2_FRETEIN
         TSeguro    += If(AvFlags("RATEIO_DESP_PO_PLI"),SW2->W2_SEGURIN,0)
         TInland    += SW2->W2_INLAND
         TDesconto  += SW2->W2_DESCONT
         TOutDesp   += SW2->W2_OUT_DES
      ENDIF
   ENDIF
ENDIF
M->W4_INLAND :=TInland
M->W4_PACKING:=TPacking
M->W4_DESCONT:=TDesconto
M->W4_FRETEIN:=TFreteIntl
M->W4_SEGURO := TSeguro  //LRS - 21/07/2016
M->W4_OUT_DES :=TOutDesp

Return .T.
*----------------------------------------------------------------------------
FUNCTION GI_GravaItens(bMsg)
*----------------------------------------------------------------------------
LOCAL nTecAntes, lNVEProd := .T., lMostraMsg := .T.
LOCAL _PictItem := ALLTRIM(X3PICTURE("B1_COD"))
PRIVATE lW3Skip := .F.

DO WHILE ! SW3->(EOF()) .AND. SW3->W3_PO_NUM = TPo_Num .AND. SW3->W3_FILIAL==xFilial("SW3")

   Eval(bMsg,STR0110+TRANSFORM(SW3->W3_COD_I,_PictItem)) //"Verificando saldo do Ötem "

   IF SW3->W3_SEQ <> 0 .OR. SW3->W3_SALDO_Q <= 0
      SW3->(DBSKIP())
      LOOP
   ENDIF
   lLoop:=.F.
   IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"SKIP_LOOP_SW3"),)
   IF lLoop
      SW3->(DBSKIP())
      LOOP
   ENDIF

   IF !EMPTY(dIniEmb) .AND. !EMPTY(dFimEmb)
      IF SW3->W3_DT_EMB < dIniEmb  .OR. SW3->W3_DT_EMB > dFimEmb
         SW3->( DBSKIP() )  ;  LOOP
      ENDIF
   ENDIF

   IF GI_PORTARIA78
      IF SW3->W3_PORTARI <> 7 .AND. SW3->W3_PORTARI <> 8
         SW3->(DBSKIP())
         LOOP
      ENDIF
   ELSE
      IF SW3->W3_PORTARI = 7 .OR. SW3->W3_PORTARI = 8
         SW3->(DBSKIP())
         LOOP
      ENDIF
   ENDIF

   IF GI_APROVADA
      IF .NOT. PosO1_ItEs(TNro_Pgi,SW3->W3_COD_I,SW3->W3_FABR,SW3->W3_FORN,1,0)
         DBSELECTAREA("SW3")
         SW3->(DBSKIP())
         LOOP
      ENDIF
   ENDIF

   IF ! SB1->(DBSEEK(xFilial()+SW3->W3_COD_I))
      HELP("",1,"AVG0000429",,TRANSFORM(SW3->W3_COD_I,_PictItem)+STR0112,1,15)//MsgInfo(STR0111 + TRAN(SW3->W3_COD_I,_PictItem) + ; //"Atenção, item "
          //STR0112,STR0039) //" não cadastrado"###"Atenção"
      SW3->(DBSKIP()) ; LOOP
   ENDIF

   M->WK_TEC    := Busca_NCM("SW3","NCM")
   M->WK_EX_NCM := Busca_NCM("SW3","EX_NCM")
   M->WK_EX_NBM := Busca_NCM("SW3","EX_NBM")

   cDescricao := MSMM(SB1->B1_DESC_GI,AVSX3("B1_VM_GI",3),,,3 )
   IF AvFlags("SUFRAMA") .AND. !EMPTY(M->W4_PROD_SU)
     SYX->(DBSETORDER(3))
     IF SYX->(DBSEEK(xFilial("SYX")+M->W4_PROD_SU+SB1->B1_COD))
        nTecAntes := M->WK_TEC
        M->WK_TEC := ALLTRIM(IF(!EMPTY(SYX->YX_TEC),LEFT(SYX->YX_TEC,8),M->WK_TEC))+SPACE(2)
        IF M->WK_TEC # nTecAntes
          M->WK_EX_NCM:=SPACE(LEN(SB1->B1_EX_NCM))
          M->WK_EX_NBM:=SPACE(LEN(SB1->B1_EX_NBM))
        ENDIF
        cDescricao := IF(!EMPTY(SYX->YX_DES_ZFM),LEFT(SYX->YX_DES_ZFM,36) ,cDescricao)
     ENDIF
     SYX->(DBSETORDER(1))
   ENDIF
   lOk_NBM:=.T.
   IF ! SYD->(DBSEEK(xFilial()+M->WK_TEC+M->WK_EX_NCM+M->WK_EX_NBM))//SB1->B1_POSIPI+SB1->B1_EX_NCM+SB1->B1_EX_NBM
     lOk_NBM:=.F.
   ENDIF

   DBSELECTAREA("Work")
   Work->(DBSETORDER(1))
   IF Work->(DBSEEK(TPo_Num+SW3->W3_CC+SW3->W3_SI_NUM + ;
             SW3->W3_COD_I + SW3->W3_FABR+EICRetLoja("SW3","W3_FABLOJ")+SW3->W3_FORN+ ;
             EICRetLoja("SW3","W3_FORLOJ")+ STR(SW3->W3_REG,AVSX3("W3_REG",3),0)))
      lW3Skip := .T.

      If lInvAnt .And. nBasePLI == 1 //DRL - 17/09/09 - Invoices Antecipadas
			lW3Skip := .F.
			WHILE	WORK->(!EOF())			 		.AND.	WORK->WKPO_NUM			==	TPo_Num			.AND.;
				WORK->WKCC		==	SW3->W3_CC		.AND.	WORK->WKSI_NUM			==	SW3->W3_SI_NUM	.AND.;
				WORK->WKCOD_I	==	SW3->W3_COD_I	.AND.	WORK->WKFABR			==	SW3->W3_FABR	.AND.;
				IIf(EICLoja(),WORK->W5_FABLOJ ==  SW3->W3_FABLOJ,"")  .AND.   WORK->WKFORN    	==	SW3->W3_FORN	.AND.;
				IIf(EICLoja(),WORK->W5_FORLOJ ==  SW3->W3_FORLOJ,"")  .AND.   STR(WORK->WKREG,2,0)	==	STR(SW3->W3_REG,2,0)
				//
				IF WORK->WKINVOIC == TInv_Ant .AND.  WORK->WKFORN == TForn_Inv .AND. IIF(EICLoja(),WORK->W5_FORLOJ == TFornInvLoj,.T.)
					lW3Skip := .T.
					EXIT
				ENDIF
				WORK->(dbSkip())
			ENDDO
		ENDIF
      IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"JA_ITEM_WORK"),)
      IF lW3Skip
         MCont  := MCont + 1
         MTotal2:= MTotal2 + 1
         DBSELECTAREA("SW3")
         SW3->(DBSKIP())
         LOOP
      EndIf
   ENDIF

   lW3Skip := .F.

   If lInvAnt .And. nBasePLI == 1 //DRL - 17/09/09 - Invoices Antecipadas
      If SaldoEW5() <= 0
         lW3Skip := .T.
      EndIf
   EndIf

   /* RMD - 20/12/19 - Deve possibilitar o registro de PLI para itens anuentes do processo de Nacionalização, mesmo se já possuirem LI na Admissão
   //NCF - 18/08/2011 - Não carregar itens anuentes de PN que possuem PLI na fase de PO
   If SW3->W3_FLUXO == "1"
      If !EMPTY(SW3->W3_PO_DA) .AND. !EMPTY(SW3->W3_POSI_DA) .AND. !EMPTY(SW3->W3_PGI_DA).And. !( At("*", SW3->W3_PGI_DA)==1 .And. Rat("*", SW3->W3_PGI_DA )==Len(SW3->W3_PGI_DA) ) //FSM - 18/05/212
         lW3Skip := .T.
      EndIf
   EndIf
   */

   IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"VAL_ITEM_WORK"),)

   IF lW3Skip
      SW3->(DBSKIP())
      LOOP
   ENDIF

   Work->(DBSETORDER(2))
   Work->(DBAPPEND())
   //AOM - 08/04/2011
   IF lOperacaoEsp
      Work->W5_CODOPE := SW3->W3_CODOPE
      Work->W5_DESOPE := POSICIONE("EJ0",1,xFilial("EJ0")+ SW3->W3_CODOPE ,"EJ0_DESC")
   ENDIF
   Work->WKCOD_I    :=   SW3->W3_COD_I
   Work->WKFABR     :=   SW3->W3_FABR
   Work->WKFABR_01  :=   SW3->W3_FABR_01
   Work->WKFABR_02  :=   SW3->W3_FABR_02
   Work->WKFABR_03  :=   SW3->W3_FABR_03
   Work->WKFABR_04  :=   SW3->W3_FABR_04
   Work->WKFABR_05  :=   SW3->W3_FABR_05
   Work->WKFORN     :=   SW3->W3_FORN
   Work->WKPRECO    :=   SW3->W3_PRECO
   Work->WKFLUXO    :=   SW3->W3_FLUXO
   Work->WKQTDE     :=   SW3->W3_SALDO_Q
   Work->WKSALDO_Q  :=   SW3->W3_SALDO_Q
   Work->WKSALDO_O  :=   SW3->W3_SALDO_Q
   Work->WKSI_NUM   :=   SW3->W3_SI_NUM
   Work->WKPO_NUM   :=   SW3->W3_PO_NUM
   Work->WKCC       :=   SW3->W3_CC
   Work->WKDT_ENTR  :=   SW3->W3_DT_ENTR
   Work->WKDTENTR_S :=   SW3->W3_DT_ENTR
   Work->WKDT_EMB   :=   SW3->W3_DT_EMB
   Work->WKRECNO_IP :=   SW3->(RECNO())
   Work->WKREG      :=   SW3->W3_REG
   Work->WKFLAG     :=   .T.
   Work->WKFLAGWIN  :=   cMarca
   Work->WKDESCR    :=   cDescricao  //MSMM(SB1->B1_DESC_GI,36,1 )
   Work->WKTEC      :=   M->WK_TEC
   Work->WK_EX_NCM  :=   M->WK_EX_NCM
   Work->WK_EX_NBM  :=   M->WK_EX_NBM
   //Work->WKPESO_L :=   B1Peso(SW3->W3_CC,SW3->W3_SI_NUM,SW3->W3_COD_I,SW3->W3_REG,SW3->W3_FABR,SW3->W3_FORN) // RA - 04/11/03 - O.S. 1112/03 / Antes=> SB1->B1_PESO
   //CCH - 07/08/09 - Gravação do novo campo de Peso Líquido Unitário
   Work->WKPESO_L   := If (SW3->(FieldPos("W3_PESOL")) # 0,SW3->W3_PESOL, B1Peso(SW3->W3_CC,SW3->W3_SI_NUM,SW3->W3_COD_I,SW3->W3_REG,SW3->W3_FABR,SW3->W3_FORN, EICRetLoja("SW3", "W3_FABLOJ"), EICRetLoja("SW3","W3_FORLOJ")))

   //FSM - 31/08/2011 - "Peso Bruto Unitário"
   If lPesoBruto
     Work->WKW5PESOBR := SW3->W3_PESO_BR //SB1->B1_PESBRU //Grava o peso bruto do produto
   EndIf
   If AvFlags("RATEIO_DESP_PO_PLI")
      Work->WKFRETE := SW3->W3_FRETE
      Work->WKSEGUR := SW3->W3_SEGURO
      Work->WKINLAN := SW3->W3_INLAND
      Work->WKDESCO := SW3->W3_DESCONT
      Work->WKPACKI := SW3->W3_PACKING

      Work->W5_FRETE   := SW3->W3_FRETE
      Work->W5_SEGURO  := SW3->W3_SEGURO
      Work->W5_INLAND  := SW3->W3_INLAND
      Work->W5_DESCONT := SW3->W3_DESCONT
      Work->W5_PACKING := SW3->W3_PACKING
   EndIf

   Work->WKFAMILIA  :=   SB1->B1_FPCOD
   Work->WKDESTAQUE :=   SYD->YD_DESTAQU
   Work->WKNALADI   :=   SYD->YD_NALADI
   Work->WKALADI    :=   GI400BuscaAcordo("ALADI",3)  //CCH - 03/08/09 - Função para busca do Aladi e Naladi de acordo com NCM/Inclusão/Alteração e L.I.
   Work->WKSHNA_NTX :=   GI400BuscaAcordo("NALADI",3) //CCH - 03/08/09 - Função para busca do Aladi e Naladi de acordo com NCM/Inclusão/Alteração e L.I.
   Work->WKNAL_SH   :=   SYD->YD_NAL_SH
   Work->WKUNI_NBM  :=   SYD->YD_UNID
   Work->WKPOSICAO  :=   SW3->W3_POSICAO //AWR 10/02/99

   //Work->WKALADI    :=   SYD->YD_ALADI
   //Work->WKSHNA_NTX :=   IF(!EMPTY(SYD->YD_NAL_SH),SYD->YD_NAL_SH,SYD->YD_NALADI)
   // Work->WKPART_N   :=   SA5->(BuscaPart_N())
   If EICLoja()
      Work->W5_FABLOJ  := SW3->W3_FABLOJ
      Work->W5_FAB1LOJ := SW3->W3_FAB1LOJ
      Work->W5_FAB2LOJ := SW3->W3_FAB2LOJ
      Work->W5_FAB3LOJ := SW3->W3_FAB3LOJ
      Work->W5_FAB4LOJ := SW3->W3_FAB4LOJ
      Work->W5_FAB5LOJ := SW3->W3_FAB5LOJ
      Work->W5_FORLOJ  := SW3->W3_FORLOJ
   EndIf
   If SW3->(FieldPos("W3_PART_N")) # 0  .And. !Empty(SW3->W3_PART_N) //ASK 05/10/07
      Work->WKPART_N := SW3->W3_PART_N
   Else
      Work->WKPART_N := SA5->(BuscaPart_N())
   EndIf

   IF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"21"),)//AWR 10/11/1999
   If nBasePLI == 1 //DRL - 17/09/09 - Invoices Antecipadas
      WORK->WKINVOIC  := TInv_Ant
      WORK->WKQTDE    := SaldoEW5()
      WORK->WKSALDO_Q := WORK->WKQTDE
      WORK->WKSALDO_O := WORK->WKQTDE
      If !EW5->(EOF())
         WORK->WKPESO_L  := EW5->EW5_PESOL
      EndIf
   EndIf
   
   IF AvFlags("DESTAQUE_QUEBRA_LI") //LRS - 18/01/18
   EYJ->(DbSetOrder(1)) //Filial + Cod. Produto
      If EYJ->(DbSeek(xFilial("EYJ") + AvKey(Work->WKCOD_I,"EYJ_COD")))
          IF !Empty(EYJ->EYJ_DESTAQ)
            Work->WKDESTEYJ  := EYJ->EYJ_DESTAQ
            Work->WKDESTAQUE := Work->WKDESTEYJ
          EndIF
      EndIF
   EndIF

   IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"GRAVA_DESPESAS"),)//CES 28/08/01

   IF !lOk_NBM .OR. EMPTY(Work->WKPESO_L)
      IF EMPTY(WKTEC)
         Work->WKFLAG    := .F.
         Work->WKFLAGWIN := SPACE(2)
      ENDIF
   ELSE
      MTotPeso += SW3->W3_SALDO_Q * Work->WKPESO_L  //SB1->B1_PESO
   ENDIF

/*   IF WKDT_EMB < dDataBase
      Work->WKFLAG := .F.
      Work->WKFLAGWIN := SPACE(2)
   ENDIF*/

   IF EMPTY(cDescricao)  //SB1->B1_DESC_GI)
      Work->WKFLAG    := .F.
      Work->WKFLAGWIN := SPACE(2)
   ENDIF

   IF EMPTY(Work->WKPESO_L) // LDR - 31/05/04 - OS 0795/04
      Work->WKFLAG    := .F.
      Work->WKFLAGWIN := SPACE(2)
   ENDIF

   IF AvFlags("SUFRAMA") .AND. ! EMPTY(M->W4_PROD_SU)
      SYX->(DBSETORDER(3))
      IF ! SYX->(DBSEEK(xFilial()+M->W4_PROD_SU+SW3->W3_COD_I))
           Work->WKFLAG := .F.
           Work->WKFLAGWIN:=SPACE(02)
      ELSEIF EMPTY(Work->WKPART_N) .OR. EMPTY(SB1->B1_ESPECIF) .OR. EMPTY(SB1->B1_MAT_PRI) .OR.;
             EMPTY(SA5->A5_PARTOPC) .OR. EMPTY(SYX->YX_INSUMO) .OR. EMPTY(SYX->YX_DES_ZFM)
          Work->WKFLAG := .F.
          Work->WKFLAGWIN:=SPACE(02)
      ENDIF
      SYX->(DBSETORDER(1))
   ENDIF

   IF lMV_EIC_EAI//AWF - 25/06/2014
      Work->WKUNI    :=SW3->W3_UM
      Work->WKSEGUM  :=SW3->W3_SEGUM
      Work->WKFATOR  :=SW3->W3_QTSEGUM/SW3->W3_QTDE
      Work->WKQTSEGUM:=SW3->W3_QTSEGUM
   ENDIF

   Work->WKPRTOT:=VAL(STR(SW3->W3_SALDO_Q * SW3->W3_PRECO,nTamP,nDecP))

   IF Work->WKFLAG
      MTotPeso += SW3->W3_SALDO_Q * Work->WKPESO_L //SB1->B1_PESO  // LAB 13.06.97
      MTotal:= MTotal + VAL(STR(SW3->W3_SALDO_Q * SW3->W3_PRECO,nTamP,nDecP))
      MTotal2:= MTotal2 + 1
   ENDIF

   IF SA2->(DBSEEK(xFilial()+SW3->W3_FABR+EICRetLoja("SW3","W3_FABLOJ")))
      //DBSELECTAREA("Work")
      Work->WKNOME_FAB := SA2->A2_NREDUZ
   ENDIF

   IF SA2->(DBSEEK(xFilial()+SW3->W3_FORN+EICRetLoja("SW3","W3_FABLOJ")))
      //DBSELECTAREA("Work")
      Work->WKNOME_FOR := SA2->A2_NREDUZ
   ENDIF

   IF Work->WKFLAG .AND. lCposNVAE
      EIM->(DbSetOrder(3))
      //MFR 26/11/2018 OSSME-1483
      //IF EIM->(DbSeek(xFilial("EIM")+AvKey("CD","EIM_FASE")+AvKey(Work->WKCOD_I,"EIM_HAWB"))) .AND. AllTrim(Work->WKTEC) == AllTrim(Posicione("SB1",1,xFilial("SB1")+AvKey(Work->WKCOD_I,"B1_COD"),"B1_POSIPI")) .AND.;
      IF EIM->(DbSeek(GetFilEIM("CD")+AvKey("CD","EIM_FASE")+AvKey(Work->WKCOD_I,"EIM_HAWB"))) .AND. AllTrim(Work->WKTEC) == AllTrim(Posicione("SB1",1,xFilial("SB1")+AvKey(Work->WKCOD_I,"B1_COD"),"B1_POSIPI")) .AND.;
         If(lMostraMsg,MsgYesNo(STR0363 + ENTER + STR0364,STR0354),.T.)  // "Existem itens marcados no processo que já possuem classificação N.V.A.E. originada do cadastro de Produto." ### "Deseja importar as informações de N.V.A.E. para estes itens?"
         cCodANVE := If(lNVEProduto,GI400GerNVE(),"")
         //MFR 26/11/2018 OSSME-1483
         //Do While EIM->(!Eof()) .AND. EIM->(EIM_FILIAL+EIM_FASE+EIM_HAWB) == xFilial("EIM")+AvKey("CD","EIM_FASE")+AvKey(Work->WKCOD_I,"EIM_HAWB")
         Do While EIM->(!Eof()) .AND. EIM->(EIM_FILIAL+EIM_FASE+EIM_HAWB) == GetFilEIM("CD")+AvKey("CD","EIM_FASE")+AvKey(Work->WKCOD_I,"EIM_HAWB")
            WORK_GEIM->(DbSetOrder(1))
            If !WORK_GEIM->(DbSeek(EIM->(EIM_NIVEL+EIM_ATRIB+EIM_ESPECI+If(lNVEProduto,EIM_NCM,""))))
               WORK_GEIM->(DbAppend())
               AvReplace("EIM","WORK_GEIM")
               WORK_GEIM->EIM_FASE := "LI"
               Work_GEIM->EIM_CODIGO := cCodANVE
               WORK_EIM->(DbAppend())
               AvReplace("WORK_GEIM","WORK_EIM")
               WORK_EIM->EIM_HAWB := M->W4_PGI_NUM
            Else
               If AvKey(WORK_GEIM->EIM_HAWB,"W3_COD_I") == Work->WKCOD_I .And. WORK_GEIM->EIM_NCM == Work->WKTEC // 
                  cCodANVE := Work_GEIM->EIM_CODIGO
                  EXIT
               EndIf
            EndIf
            EIM->(DbSkip())
         EndDo
         //WORK_EIM->(DbGoTop())
         Work->WKNVE := cCodANVE //WORK_EIM->EIM_CODIGO  
         
         WORK_CEIM->(DbAppend())
         Work_CEIM->EIM_CODIGO:=Work->WKNVE
         Work_CEIM->WKTEC     :=Work->WKTEC
         lMostraMsg := .F.
      ENDIF
      lNVEProd := .F.
   ENDIF

   DBSELECTAREA("SW3")
   SW3->(DBSKIP())
   MCont:= MCont + 1

ENDDO

Return .T.

*----------------------------------------------------------------------------
FUNCTION GI400Val(MFlagy,MNumero)
*----------------------------------------------------------------------------
Private MFlag:=MFlagy, lRet:=.T.

If lIntDraw  // GFP - 29/01/2014
   ED4->(DBSeek(xFilial() + Work->WKAC + Work->WKSEQSIS)) //wfs 17/12/13
EndIf

DO CASE
   CASE MFlag = 'Saldo_Q'
        IF EMPTY( TSaldo_Q ) .OR. TSaldo_Q < 0 //AAF 09/09/05
           HELP("",1,"AVG0000367")//MsgInfo(STR0113,STR0039) //'Quantidade não preenchida'###"Atenção"
           RETURN .F.
        ELSE
           IF PLI .OR. GI_PORTARIA78 .OR. GI_PORTARIA15 .OR. GI_ENTREPOST
              IF TSaldo_Q > WKSALDO_Q
                HELP("",1,"AVG0000430")//MsgInfo(STR0114,STR0039) //'Quantidade não pode ser maior que o saldo'###"Atenção"
                RETURN .F.
              ENDIF
              If lIntDraw .and. !Empty(cAC) .and. cAC == Work->WKAC .and. AVTransUnid(cUnid,ED4->ED4_UMITEM,Work->WKCOD_I,TSaldo_Q,.F.) > ED4->ED4_QT_LI .and.;
              (ED0->ED0_TIPOAC <> GENERICO .or. ED4->ED4_NCM <> NCM_GENERICA) .AND.;
              AVTransUnid(cUnid,ED4->ED4_UMNCM,Work->WKCOD_I,TSaldo_Q,.F.) > ED4->ED4_SNCMLI//AAF 23/08/05 - Verifica também a quantidade na NCM.
                 HELP("",1,"AVG0000430")//MsgInfo(STR0114,STR0039) //'Quantidade não pode ser maior que o saldo'###"Atenção"
                RETURN .F.
              ENDIF
/*           ELSE
              IF TSaldo_Q > SWE->WE_SALDO_Q
                MsgInfo(STR0115 + ALLTRIM(TRANSF(SWE->WE_SALDO_Q,'@E 999,999,999.999'))+ STR0116,STR0039) //'Quantidade não pode ser maior que '###'( Saldo da G.I. )'###"Atenção"
                RETURN .F.
              ENDIF       */
           ENDIF
        ENDIF
        If AvFlags("RATEIO_DESP_PO_PLI")
           TFretIte := Work->W5_FRETE   * (TSaldo_Q/WORK->WKQTDE)
           TSeguIte := Work->W5_SEGURO  * (TSaldo_Q/WORK->WKQTDE)
           TInlaIte := Work->W5_INLAND  * (TSaldo_Q/WORK->WKQTDE)
           TDescIte := Work->W5_DESCONT * (TSaldo_Q/WORK->WKQTDE)
           TPackIte := Work->W5_PACKING * (TSaldo_Q/WORK->WKQTDE)
        EndIf
        nFobTotal  := TSaldo_Q * TFobUnit
        IF AvFlags("EIC_EAI")//AWF - 25/06/2014
           M->W5_QTSEGUM:=TSaldo_Q*Work->WKFATOR
          cSegUN:= TRANS(M->W5_QTSEGUM,AVSX3("W3_QTSEGUM",6))+" "+WORK->WKSEGUM//AWF - 01/07/2014
        ENDIF
        oFobTotal:Refresh()
   CASE MFlag = 'NCM'
      IF EMPTY(cNCM)
         HELP("",1,"AVG0000431")//MsgInfo(STR0085+STR0147,STR0039) // NCM nÃO PREENCHIDA
         RETURN .F.
      ELSEIF SYD->(!DbSeek(xFilial("SYD")+cNCM))
         HELP("",1,"AVG0000432")//MsgInfo(STR0085+STR0148,STR0039) // NCM não cadastrado
        RETURN .F.
      ENDIF
   CASE MFlag = 'EX-NCM'
      IF !Empty(cExNCM).And.SYD->(!DbSeek(xFilial("SYD")+cNCM+cExNCM))
         HELP("",1,"AVG0000433")//MsgInfo(STR0085 + "/" + STR0047+STR0148 ,STR0039) //NCM/Ex-NCM não CadastradA
        RETURN .F.
      ENDIF
   CASE MFlag = 'EX-NBM'
      IF !Empty(cExNBM).And.SYD->(!DbSeek(xFilial("SYD")+cNCM+cExNCM+cExNBM))
         HELP("",1,"AVG0000434")//MsgInfo(STR0085 + "/" + STR0047+"/"+STR0048+ STR0148,STR0039)//'Ncm /Ex-NCM/Ex-NBM nÆo encontrada'
        RETURN .F.
      ENDIF
   CASE MFlag = 'VlUnit'
        IF EMPTY(TFobUnit)
           HELP("",1,"AVG0000435")//MsgInfo(STR0117,STR0039) //'FOB unit rio nÆo preenchido'###"Atenção"
           RETURN .F.
        ENDIF
        nFobTotal  := TSaldo_Q * TFobUnit
        oFobTotal:Refresh()
   CASE MFlag = 'Dt_Emb'
        IF EMPTY( TDtEmbarque )
           HELP("",1,"AVG0000436")//MsgInfo(STR0118,STR0039) //'Data de embarque não preenchida'###"Atenção"
           RETURN .F.
        ENDIF
        SY9->(dbSetOrder(2))
        dtEntCalc := TDtEmbarque + SYR->YR_TRANS_T + IF(SY9->(DBSEEK(xFilial()+SW2->W2_DEST)),(SY9->Y9_LT_DES + SY9->Y9_LT_TRA),EasyGParam("MV_LT_DESE"))
        SY9->(dbSetOrder(1))

        If EMPTY(TDtEntrega)
           TDTEntrega:= dtEntCalc
        ELSEIF TDtEmbarque <> WORK->WKDT_EMB .AND. dtEntCalc <> TDtEntrega
           If MsgYesNo( STR0184 + DTOC(dtEntCalc) + CHR(13)+CHR(10)+ STR0185, STR0126 )=.T.
              tDtEntrega := dtEntCalc
           ENDIF
        EndIF

        IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"RECALC_DT_ENTREGA"),)
   CASE MFlag = 'Dt_Ent'
        IF EMPTY( TDtEntrega )
           HELP("",1,"AVG0000437")//MsgInfo(STR0119,STR0039) //'Data de entrega não preenchida'###"Atenção"
           RETURN .F.
        ENDIF

   CASE MFlag = 'CodDes'
        IF VAL(SUBSTR(EVAL(B_Numero),2,3)) = 0
           RETURN .T.
        ENDIF
        IF ! SY7->(DBSEEK(xFilial()+EVAL(B_Numero)))
           HELP("",1,"AVG0000438")//MsgInfo(STR0121,STR0062) //'Mensagem não cadastrada'###"Informação"
           RETURN .F.
        ENDIF
        IF SY7->Y7_POGI # "2"
           HELP("",1,"AVG0000439")//MsgInfo(STR0122,STR0062) //'Esta mensagem não pertence ao corpo da guia'###"Informação"
           RETURN .F.
        ENDIF
        M->W4_VM_DESG += SY7->Y7_TEXTO
   CASE MFlag = 'Peso_L'
        IF EMPTY(TPESO_L)
           HELP("",1,"AVG0000440")//MsgInfo(STR0123,STR0039) //"Peso l¡quido nÆo preenchido"###"Atenção"
           RETURN .F.
        ENDIF

   //ACB - 28/02/2011 - Tratamento para validar o peso total do processo.
   CASE MFlag = 'Peso_Tot'
      If !ComparaPeso(TSaldo_Q,TPESO_L,"EIJ_PESOL",,) //Atenção, fonte chamado do AVGERAL.PRW
         Return .f.
      EndIf

   //** PLB 06/08/07 - Validação do campo de FUndamento Legal (W4_REGIMP)
   Case MFlag == "REGIMP"
        If !( M->W4_REGIMP $ cFiltroSY8 )
           If Empty(cFiltroSY8)
              MsgStop(STR0223)  //"Regime não possui Fundamentos Legais cadastrados."
           Else
              MsgStop(STR0224+cFiltroSY8)  //"Regime somente aceita Fund. Legal: "
           EndIf
           Return .F.
        EndIf

ENDCASE

IF EasyEntryPoint("EICGI400")
   ExecBlock("EICGI400",.F.,.F.,"VAL_ITEM")
   Return lRet
EndIf

RETURN .T.

*------------------------------------------------------------------------------
Function GI400Subst(cAlias,nCodigo)
*------------------------------------------------------------------------------
IF EMPTY(nCodigo)
   RETURN .T.
ENDIF
(cAlias)->(DBSETORDER(5))
IF ! ExistCpo(cAlias,nCodigo)
   RETURN .F.
ENDIF
(cAlias)->(DBSETORDER(1))
RETURN .T.

*------------------------------------------------------------------------------
FUNCTION GI_Final(bCloseAll,cOldAlias)
*------------------------------------------------------------------------------
//LOCAL lTem_DSI := EasyGParam("MV_TEM_DSI",,.F.) //Verifica se tem manutenção de LSI // ACSJ - 28/04/2004
                                                                               // Alteração feita para resolver
                                                                               // QNC 001690/2004-00 de 28/04/2004
                                                                               // Conforme orientação do Sr. Jonato

EVAL(bCloseAll)
//THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados
Work->(E_EraseArq(FileWork))
FERASE(FileWork+TEOrdBagExt())
FERASE(WorkNTX2+TEOrdBagExt())
FERASE(WorkNTX3+TEOrdBagExt())
FERASE(WorkNTX4+TEOrdBagExt())
FERASE(WorkNTX5+TEOrdBagExt())
FERASE(WorkNTX6+TEOrdBagExt())
//NCF - 07/12/11 - Classificação N.V.A.E na PLI
If lCposNVAE
   FERASE(WorkNTX7+TEOrdBagExt())
EndIf

IF lTem_DSI     // JBS 14/11/2003
   Work_SWP->(E_EraseArq(FileWork3))  //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados
   FERASE(FileWork3+TEOrdBagExt())
ENDIF

IF SELECT("Work_EIT") <> 0
   Work_EIT->(E_EraseArq(FileWork2))  //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados 
   FERASE(FileWork2+TEOrdBagExt())
ENDIF

//NCF - 08/08/2011 - Classificação N.V.A.E na PLI
If lCposNVAE
   IF SELECT("Work_EIM") <> 0
      Work_EIM->(dbclosearea())
   ENDIF
   IF SELECT("Work_CEIM") <> 0
      Work_CEIM->(dbclosearea())
   ENDIF
   IF SELECT("Work_GEIM") <> 0
      Work_GEIM->(dbclosearea())
   ENDIF
EndIf

DBSELECTAREA(cOldAlias)

IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"INDICE_DELETAR"),)//RJB 07/08/03

RETURN .T.

*----------------------------------------------------------------------------
FUNCTION GI410Estorno()
*----------------------------------------------------------------------------
LOCAL nRecno:=Work->(RECNO()), lMarca:=.F.
PRIVATE lLaco:=.T.
Work->(DBGOTOP())
Work->(DBEVAL({||IF(WKFLAGWIN==cMarca,lMarca:=.T.,)}))
Work->(DBGOTO(nRecno))

IF ! lMarca
   HELP("",1,"AVG0000441")//MsgInfo(STR0124 ,STR0062) //"Não existem registros marcados"###"Informação"
   Return .F.
ENDIF

//--- Verifica se foi solicitada a LI para todos os produtos com anuência
//    com sua quantidade TOTAL da Commercial Invoice (quando a PLI for
//    montada com base na Invoice Antecipada).
If lInvAnt .And. nBasePLI == 1 //DRL - 16/09/09 - Invoices Antecipadas
   nxOrdEW5 := EW5->(IndexOrd())
   EW5->(dbSetOrder(2))
   If EW5->(dbSeek(cFilEW5+WORK->WKPO_NUM+WORK->WKPOSICAO+WORK->WKINVOIC+WORK->WKFORN))
      If WORK->WKQTDE <> EW5->EW5_QTDE
         MsgStop(STR0254) //STR0254 "É necessário solicitar a PLI da quantidade total do produto!"
         lLaco	:= .F.
      EndIf
   EndIf
   EW5->(dbSetOrder(nxOrdEW5))
EndIf

IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"VALID_ITENS_INV"),) //  LDR

IF ! lLaco
   Return .F.
ENDIF

IF MsgYesNo(STR0125,STR0126) # .T. //"Confirma o Estorno desta P.L.I. ? "###"Confirmação"
   Return .F.
ENDIF

MsAguarde({|| GI_Estorno({|msg|MsProcTxt(msg)})},STR0127) //"Estorno em andamento..."

If nBasePLI == 1
   nxOrdEW5:=EW5->(IndexOrd())
   EW5->(dbSetOrder(3))
   WORK->(dbGoTop())
   WHILE !WORK->(eof())
         IF WORK->WKFLAG
            IF EW5->(dbSeek(xFilial("EW5")+SW4->W4_PGI_NUM+WORK->WKINVOIC+WORK->WKFORN+WORK->WKPO_NUM+WORK->WKPOSICAO))
               EW5->(RecLock("EW5",.F.))
               EW5->EW5_PGI_NU := SPACE(LEN(EW5->EW5_PGI_NU))
               EW5->(MSUNLOCK())
            ENDIF
         ENDIF
         WORK->(dbSkip())
   ENDDO
   EW5->(dBSetOrder(nxOrdEW5))
ENDIF

IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"GI_ESTORNO"),)

Return .T.
*----------------------------------------------------------------------------
FUNCTION GI_Estorno(bMsg)
*----------------------------------------------------------------------------
LOCAL _IniPO := SPACE(LEN(SW7->W7_PO_NUM)), Wind ,i,cPos:=""
LOCAL TNro_Pgi:=SW4->W4_PGI_NUM, MTotal:=SW4->W4_FOB_TOT
LOCAL TemnoIG000 := .F., aSeqLi:={}, aStru:= { {"TFNR_MAQ","C",02,0} ,;
                                               {"TF_MICRO","C",08,0} ,;
                                               {"TF_INTEG","D",08,0} }
LOCAL bFecha:={|cArq|FCLOSE(cArq)}
LOCAL aFecha_Flg:={}
LOCAL _PictItem := ALLTRIM(X3PICTURE("B1_COD"))

PRIVATE nVlrSaldo:=SW4->W4_FOB_TOT //p/ Rdmake
DBGOTOP()

MPo_Num:= _IniPO
nW5_REG:=AVSX3("W5_REG",3)
SWP->(DBSETORDER(1)) // RJB 21/07/2004
DO WHILE .NOT. EOF()
  Eval(bMsg,OemToAnsi(STR0036+TRANSFORM(WKCOD_I,_PictItem))) //"Processando Item "

  IF ! WKFLAG .AND. ! WKFLAGWIN == cMarca
    DBSKIP() ;  LOOP
  ENDIF

  TemnoIG000 := .F.
  DBSELECTAREA("SW3")

  IF PosO2_ItPedidos(TNro_Pgi,Work->WKCC,Work->WKSI_NUM,Work->WKCOD_I,Work->WKFABR,Work->WKFORN,Work->WKREG,IF(EICLOJA(),Work->W5_FABLOJ,""),IF(EICLOJA(), Work->W5_FORLOJ,""))
      RecLock("SW3",.F.,.T.)
      SW3->(DBDELETE())
    SW3->(MsUnlock())
  ENDIF

  IF PosO1_ItPedidos(Work->WKPO_NUM,Work->WKCC,Work->WKSI_NUM,Work->WKCOD_I,Work->WKFABR,Work->WKFORN,Work->WKREG,0,IF(EICLOJA(),Work->W5_FABLOJ,""),IF(EICLOJA(), Work->W5_FORLOJ,""))
    RecLock("SW3",.F.)
    SW3->W3_SALDO_Q:=SW3->W3_SALDO_Q + Work->WKQTDE//Work->WKSALDO_Q //*FSY, AAF 07/10/2013 - Modificada validação de estorno.
    SW3->(MsUnlock())
  ENDIF
  DBSELECTAREA("SW5")
  SW5->(DBGOTO(Work->WKRECNO_IG))

  If AvFlags("EIC_EAI") //MCF - 04/04/2016
     IF ascan(aEnv_PO,SW5->W5_PO_NUM + SW5->W5_POSICAO) == 0
        aadd(aEnv_PO,SW5->W5_PO_NUM + SW5->W5_POSICAO)
     ENDIF
  EndIf

  IF SW5->W5_SEQ=0 .AND. SWP->(DBSEEK(xFilial()+TNro_Pgi+SW5->W5_SEQ_LI)) .AND. !EMPTY(SWP->WP_REGIST)
     EIS->(RECLOCK("EIS",.T.))

     EIS->EIS_FILIAL:=xFilial("EIS")
     EIS->EIS_SEQ_LI:=SW5->W5_SEQ_LI
     EIS->EIS_PO_NUM:=SW5->W5_PO_NUM
     EIS->EIS_COD_I :=SW5->W5_COD_I
     EIS->EIS_QTDE  :=SW5->W5_QTDE
     EIS->EIS_PESO  :=SW5->W5_PESO
     EIS->EIS_PRECO :=SW5->W5_PRECO
     EIS->EIS_CC    :=SW5->W5_CC
     EIS->EIS_SI_NUM:=SW5->W5_SI_NUM
     EIS->EIS_TEC   :=SWP->WP_NCM
     EIS->EIS_EX_NBM:=SW5->W5_EX_NBM
     EIS->EIS_EX_NCM:=SW5->W5_EX_NCM
     EIS->EIS_FABR  :=SW5->W5_FABR
     EIS->EIS_FORN  :=SW5->W5_FORN
     EIS->EIS_DOCTO :=SW5->W5_DOCTO_F
     EIS->EIS_DEF_RE:=SW5->W5_DEF_REQ
     EIS->EIS_PARCIA:=SW5->W5_PARCIAL
     EIS->EIS_PGI_NU:=SW5->W5_PGI_NUM
     EIS->EIS_FLUXO :=SW5->W5_FLUXO
     EIS->EIS_REG   :=SW5->W5_REG
     EIS->EIS_DT_SHI:=SW5->W5_DT_SHIP
     EIS->EIS_POSICA:=SW5->W5_POSICAO
     EIS->EIS_DT    :=SW4->W4_DT
     If !Empty(SW4->W4_ATO_CON)
        EIS->EIS_AC :=SW4->W4_ATO_CON
     ElseIf lIntDraw
        EIS->EIS_AC :=SW5->W5_AC
        EIS->EIS_SEQSIS:=SW5->W5_SEQSIS
        EIS->EIS_QT_AC :=SW5->W5_QT_AC
        EIS->EIS_VL_AC :=SW5->W5_VL_AC
     EndIf
     EIS->EIS_OPERAC:=SW5->W5_OPERACA
     EIS->EIS_NR_MAQ:=SWP->WP_NR_MAQ
     EIS->EIS_MICRO :=SWP->WP_MICRO
     EIS->EIS_VENCTO:=SWP->WP_VENCTO
     EIS->EIS_REGIST:=SWP->WP_REGIST
     EIS->EIS_ENV_OR:=SWP->WP_ENV_ORI
     EIS->EIS_RET_OR:=SWP->WP_RET_ORI
     EIS->EIS_GIP_OR:=SWP->WP_GIP_ORI
     EIS->EIS_DT_EST:=dDataBase

     If EICLoja()
        EIS->EIS_FABLOJ:=SW5->W5_FABLOJ
        EIS->EIS_FORLOJ:=SW5->W5_FORLOJ
     EndIf
     EIS->(MSUNLOCK())
  EndIf

   IF lLote
//    IF EasyEntryPoint("EICLOTE")
//       ExecBlock("EICLOTE",.F.,.F.,"ESTORNO") //
//    Endif
      IF SWV->(dbSeek(xFilial()+SPACE(17)+SW5->(W5_PGI_NUM+W5_PO_NUM+W5_CC+W5_SI_NUM+W5_COD_I+Str(W5_REG,nW5_REG))))
         //Exclui registros do arquivo de lotes ...
         DO While !SWV->(Eof()) .And. SWV->WV_FILIAL == xFilial("SWV") .And.;
                SWV->WV_HAWB == SPACE(LEN(SWV->WV_HAWB)).AND.;
                SW5->(W5_PGI_NUM+W5_PO_NUM+W5_CC+W5_SI_NUM+W5_COD_I+Str(W5_REG,nW5_REG)) == ;
                SWV->(WV_PGI_NUM+WV_PO_NUM+WV_CC+WV_SI_NUM+WV_COD_I+Str(WV_REG,nW5_REG))
            SWV->(RecLock("SWV",.F.))
            SWV->(dbDelete())
            SWV->(MSUnlock())
            SWV->(dbSkip())
         Enddo
      Endif
   ENDIF

   IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"SOMAFOB"),)
   MTotal -= SW5->W5_QTDE*SW5->W5_PRECO

   If lIntDraw .and. !Empty(SW5->W5_AC)
      ED4->(dbSetOrder(2))
      If ED4->(dbSeek(cFilED4+SW5->W5_AC+SW5->W5_SEQSIS))
            ED4->(RecLock("ED4",.F.))
         If ED0->ED0_TIPOAC <> GENERICO .or. Alltrim(ED4->ED4_NCM) <> NCM_GENERICA
            ED4->ED4_QT_LI  += SW5->W5_QT_AC
            ED4->ED4_SNCMLI += SW5->W5_QT_AC2
         EndIf
         ED4->ED4_VL_LI  += SW5->W5_VL_AC
         ED4->(msUnlock())
         ED4->(dbSetOrder(1))
      EndIf
   EndIf

   //AOM - 09/04/2011 - Gravação do estorno de operações especiais
   If lOperacaoEsp
      oOperacao:SaveOperacao()
   EndIf

   //AAF 04/10/2013 - Não existe controle de saldo de LI. Pela legislação, uma LI só pode ser utiliza em um único desembaraço.
   //IF SW5->W5_QTDE - SW5->W5_SALDO_Q <= 0
     IF SW5->W5_SEQ_LI # SPACE(3)
       IF SWP->(DBSEEK(xFilial()+TNro_Pgi+SW5->W5_SEQ_LI))
         IF ASCAN(aSeqLi,{|Tab| Tab[1]==SW5->W5_SEQ_LI})==0
           AADD(aSeqLi,{SW5->W5_SEQ_LI,SWP->WP_NR_MAQ,SWP->(RECNO())})
         ENDIF
       ENDIF
     ENDIF
     RecLock("SW5",.F.,.T.)
     SW5->( DBDELETE())
     MConta:= MConta - 1
     TemnoIG000 := .T.
   /*ELSE
     RecLock("SW5",.F.)
     SW5->W5_QTDE :=  SW5->W5_QTDE  -  SW5->W5_SALDO_Q
     SW5->W5_SALDO_Q  := 0
     MTotal +=SW5->W5_QTDE*SW5->W5_PRECO
     TemnoIG000 := .T.
   ENDIF*/
   MsUnlock()

   IF EMPTY(MPo_Num)
     MPo_Num:= Work->WKPO_NUM
   ELSE
     IF Work->WKPO_NUM <> MPo_Num
       Grava_Ocor(MPo_Num,dDataBase,STR0129 + IF(MConta = 0,STR0130,STR0131)) //'ESTORNO DA P.L.I. - '###'TOTAL'###'PARCIAL'
     ENDIF
   ENDIF
/*
   IF MAprovada

     IF PosO1_ItEs(TNro_Pgi,Work->WKCOD_I,Work->WKFABR,Work->WKFORN,1,0)

       RecLock("SWE",.F.)

       IF Work->WKQTDE - Work->WKSALDO_Q = 0
         SWE->WE_SALDO_Q  := SWE->WE_SALDO_Q + Work->WKQTDE
       ELSE
         SWE->WE_SALDO_Q  := SWE->WE_SALDO_Q + Work->WKSALDO_Q
       ENDIF
       DBSKIP()

       DO WHILE !SWE->(EOF()) .AND. TNro_Pgi = SWE->WE_PGI_NUM .AND.;
                xFilial("SWE") == SWE->WE_FILIAL
         IF SWE->WE_COD_I = Work->WKCOD_I .AND. ;
            SWE->WE_FABR  = Work->WKFABR  .AND. ;
            SWE->WE_FORN  = Work->WKFORN  .AND. ;
            SWE->WE_SEQ   # 0
           RecLock("SWE",.F.,.T.)
           SWE->(DBDELETE())
           SWE->(MsUnlock())
           IF !TemnoIG000
             MTotal -= SWE->WE_QTDE*SWE->WE_PRECO
           ENDIF
         ENDIF
         SWE->(DBSKIP())
       ENDDO
     ENDIF
   ENDIF
  */
   RecLock("SW4",.F.)
   SW4->W4_FOB_TOT := MTotal
   SW4->(MsUnlock())

*****************************************************************************
   DBSELECTAREA("Work")
   Work->(DBSKIP())
ENDDO
IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"ESTORNO"),)

Grava_Ocor(MPo_Num,dDataBase,STR0129 + IF(MConta = 0,STR0130,STR0131)) //'ESTORNO DA P.L.I. - '###'TOTAL'###'PARCIAL'

IF MConta = 0 .AND. .NOT. MAprovada

   MSMM(SW4->W4_DESC_GE,,,,2)   // exclui campo memo
   RecLock("SW4",.F.,.T.)
   DBSELECTAREA("SW4")
   DBDELETE()
   MsUnlock()
ENDIF


SW5->(DBSETORDER(7))
ASORT(aSeqLi,,,{|X,Y|X[2]<Y[2]})
lPri:=.T. ; cSvMaq:= SPACE(2) ; cNomeArq:= SPACE(8)
SX2->(DBSEEK("SWP"))

FOR Wind = 1 TO LEN(aSeqLi)
    IF !SW5->(DBSEEK(xFilial()+TNro_Pgi+aSeqLi[Wind,1]))
       SWP->(DBGOTO(aSeqLi[Wind,3]))
       IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"ANTES_DELET"),)
       RecLock("SWP",.F.,.T.)

       GI400DelCposSWP(.T.)
       //
       // Deleta a LSI
       //
       SWP->(DBDELETE())
       SWP->(MsUnlock())
    ENDIF
NEXT
//NCF - 08/08/2011 - Classificação N.V.A.E na PLI
If lCposNVAE
   GI400NVEDel(TNro_Pgi)
EndIf

AEVAL(aFecha_Flg,bFecha)
IF(SELECT("WKCapa") # 0,WKCapa->(DBCLOSEAREA()),)
IF AvFlags("EIC_EAI")
   /* Verifica se existem pedidos originados por processo de entreposto e
      retorna os pedidos válidos para a geração da programação de entregas*/
   aEnv_PO:= PO420PedOri(aEnv_PO)
   For i = 1 To Len(aEnv_PO) //SSS -  REG 4.5 03/06/14
      If !EICPO420(.T.,4,,"SW2",.F.,aEnv_PO[I])// EICPO420(lEnvio,nOpc,aCab,cAlias,lWk,cPo_num)
         cPos+=ALLTRIM(aEnv_PO[I])+", "
      EndIf
   Next
   /*If Empty(cPos)
      MsgInfo("Integrado com Sucesso") //Saldo eliminado com sucesso
   Else*/
   If !Empty(cPos)
      MsgInfo("Acesse os Purchase orders "+cpos+" para realização dos ajustes necessários.")
   EndIf
   aEnv_PO:= {}
ENDIF

DBSELECTAREA("Work")
MControla:=.F.
RETURN .T.

*--------------------------------*
FUNCTION GI400DelCposSWP(lSWP)
*--------------------------------*
GI400DelEIT(lSWP) // Evita Conflitos    // RS 25/10/05
If lTem_DSI
   //GI400DelEIT(lSWP) // Evita Conflitos   nopado por RS 25/10/05
   if !empty(SWP->WP_ESPECIF)   // Especificações
      MSMM(SWP->WP_ESPECIF,,,,2)
   endif
   if !empty(SWP->WP_INFCOMP)  // Informações Complementares
      MSMM(SWP->WP_INFCOMP,,,,2)
   endif
EndIf
RETURN .T.

*------ FIM GIEstorno ------*
FUNCTION GI420VAL()
*---------------------------*
*Help(" ",1,"E_GI420VAL")
RETURN .T.

*------------------------------------------------------------------------------
FUNCTION GI_Init(bCloseAll)
*------------------------------------------------------------------------------
LOCAL lRetorno:=.F.

MsAguarde({||GI_InitWork({|msg|MsProcTxt(msg)},@lRetorno,@bCloseAll) },;
               STR0132) //"Inicializa‡Æo"

Return ( lRetorno )
*------------------------------------------------------------------------------
FUNCTION GI_InitWork(bMsg,lRetorno,bCloseAll)
*------------------------------------------------------------------------------
LOCAL lAbre:=.T.
//LOCAL lTem_DSI := EasyGParam("MV_TEM_DSI",,.F.)//Verifica se tem manutenção de LSI // ACSJ - 28/04/2004
                                                                              // Alteração feita para resolver
                                                                              // QNC 001690/2004-00 de 28/04/2004
                                                                              // Conforme orientação do Sr. Jonato

LOCAL Struct2:= { {"WKCOD_I"  ,"C",AVSX3("W5_COD_I",3),0} , {"WKFABR"   ,"C", AVSX3("W5_FABR",3),0}  ,;
                  {"WKFORN"   ,"C", AVSX3("W5_FORN",3),0} ,;
                  {"WKSALDO_Q","N",nTamQ,nDecQ},;
                  {"WKSALDO_O","N",nTamQ,nDecQ},;
                  {"WKFABR_01","C", AVSX3("W5_FABR",3),0} ,;
                  {"WKFABR_02","C", AVSX3("W5_FABR",3),0} , {"WKFABR_03","C", AVSX3("W5_FABR",3),0}  ,;
                  {"WKFABR_04","C", AVSX3("W5_FABR",3),0} , {"WKFABR_05","C", AVSX3("W5_FABR",3),0} }

PRIVATE Struct1:={{"WKCOD_I"   ,"C",AVSX3("W5_COD_I",3),0} , {"WKDESCR"   ,"C",AVSX3("B1_VM_GI",3),0} ,;
                  {"WKFABR"    ,"C", AVSX3("W5_FABR",3),0} , {"WKNOME_FAB","C",15,0} ,;
                  {"WKFORN"    ,"C", AVSX3("W5_FORN",3),0} , {"WKNOME_FOR","C",15,0} ,;
                  {"WKREG"     ,"N", AVSX3("W5_REG",3),0} , {"WKFLUXO"   ,"C", 1,0} ,;
                  {"WKQTDE"    ,"N",nTamQ,nDecQ},;
				  {"WKQTDORI"  ,"N",nTamQ,nDecQ},; //LGS - 16/08/2013
                  {"WKPRECO"   ,"N",nTamP,nDecP},;
                  {"WKSALDO_Q" ,"N",nTamQ,nDecQ},;
                  {"WKSALDO_O" ,"N",nTamQ,nDecQ},;
                  {"WKCC"      ,"C", AVSX3("W5_CC",3),0} , {"WKSI_NUM"  ,"C", AVSX3("W5_SI_NUM",3),0} ,;
                  {"WKPO_NUM"  ,"C",AvSx3("W2_PO_NUM", AV_TAMANHO),0} , {"WKDT_EMB"  ,"D", 8,0} ,;
                  {"WKDT_ENTR" ,"D", 8,0} , {"WKDTENTR_S","D", 8,0} ,;
                  {"WKTEC"     ,"C",10,0} , {"WKFAMILIA" ,"C", AVSX3("YC_COD",3),0} ,;
                  {"WKFLAG"    ,"L", 1,0} , {"WK_EX_NCM"  ,"C",LEN(SB1->B1_EX_NCM),0} ,;
                  {"WKPESO_L"  ,"N",16,8} , {"WKFABR_01" ,"C", AVSX3("W5_FABR",3),0} ,;
                  {"WKFABR_02" ,"C", AVSX3("W5_FABR",3),0} , {"WKFABR_03" ,"C", AVSX3("W5_FABR",3),0} ,;
                  {"WKPART_N"  ,"C",LEN(IF(SW3->(FieldPos("W3_PART_N")) # 0,SW3->W3_PART_N,SA5->A5_CODPRF)),0} ,;
                  {"WKFABR_04" ,"C", AVSX3("W5_FABR",3),0} , {"WKFABR_05" ,"C", AVSX3("W5_FABR",3),0} ,;
                  {"WKRECNO_IP","N", 9,0} , {"WK_EX_NBM"  ,"C",LEN(SB1->B1_EX_NBM),0}   ,;
                  {"WKFLAGWIN" ,"C", 2,0} , {"WKPRTOT"   ,"N",nTamP,nDecP} ,;
                  {"OR_FILIAL" ,"C", 2,0} , {"WKSEQ_LI"  ,"C",03,0}             ,;
                  {"WKNALADI"  ,"C",07,0} , {"WKALADI"   ,"C",03,0}             ,;
                  {"WKDESTAQUE","C",AVSX3("YD_DESTAQU",3),0} , {"WKNAL_SH"  ,"C",08,0},;//LRS - 13/01/2016
                  {"WKSHNA_NTX","C",08,0} , {"WKUNI_NBM" ,"C",03,0}             ,;
                  {"WKPGI_NUM" ,"C",AVSX3("W5_PGI_NUM",3),0}                    ,;//NCF - 11/01/2010
                  {"WKREGTRI"  ,"C",AVSX3("EIJ_REGTRI",3),AVSX3("EIJ_REGTRI",4)},;//GFP - 08/02/2011
                  {"WP_NR_MAQ" ,"C",AVSX3("WP_NR_MAQ" ,3),0                      },;//*FSY - 01/10/2013
                  {"WP_NAT_LSI","C",AVSX3("WP_NAT_LSI",3),0                      },;
                  {"WP_MICRO"  ,"C",AVSX3("WP_MICRO"  ,3),0                      },;
                  {"WP_PROT"   ,"C",AVSX3("WP_PROT"   ,3),0                      },;
                  {"WP_TRANSM" ,"D",AVSX3("WP_TRANSM" ,3),0                      },;
                  {"WP_VENCTO" ,"D",AVSX3("WP_VENCTO" ,3),0                      },;
                  {"WP_REGIST" ,"C",AVSX3("WP_REGIST" ,3),0                      },;
                  {"WP_SUBST"  ,"C",AVSX3("WP_SUBST"  ,3),0                      },;
                  {"WP_ERRO"   ,"C",AVSX3("WP_ERRO"   ,3),0                      },;
                  {"WP_NALADI" ,"C",AVSX3("WP_NALADI" ,3),0                      },;
                  {"WP_ALADI"  ,"C",AVSX3("WP_ALADI"  ,3),0                      },;
                  {"WP_DESTAQ" ,"C",AVSX3("WP_DESTAQ" ,3),0                      },;
                  {"WP_FABLOJ" ,"C",AVSX3("WP_FABLOJ" ,3),0                      },;
                  {"WP_ENV_ORI","D",AVSX3("WP_ENV_ORI",3),0                      },;
                  {"WP_RET_ORI","D",AVSX3("WP_RET_ORI",3),0                      },;
                  {"WP_GIP_ORI","C",AVSX3("WP_GIP_ORI",3),0                      },;
                  {"WP_NAL_SH" ,"C",AVSX3("WP_NAL_SH" ,3),0                      },;
                  {"WP_ARQ"    ,"C",AVSX3("WP_ARQ"    ,3),0                      },;
                  {"WP_SUFRAMA","C",AVSX3("WP_SUFRAMA",3),0                      },;
                  {"WP_FLAGWIN","C",AVSX3("WP_FLAGWIN",3),0                      },;
                  {"WP_NR_ALI" ,"C",AVSX3("WP_NR_ALI" ,3),0                      },;
                  {"WP_MERCOS" ,"C",AVSX3("WP_MERCOS" ,3),0                      },;
                  {"WP_DT_ENVD","D",AVSX3("WP_DT_ENVD",3),0                      },;
                  {"WP_LSI"    ,"C",AVSX3("WP_LSI"    ,3),0                      },;
                  {"WP_MOTIVO" ,"C",AVSX3("WP_MOTIVO" ,3),0                      },;
                  {"WP_TEC_CL" ,"C",AVSX3("WP_TEC_CL" ,3),0                      },;
                  {"WP_QT_EST" ,"N",AVSX3("WP_QT_EST" ,3),AVSX3("WP_QT_EST",4) },;
                  {"WP_MATUSA" ,"C",AVSX3("WP_MATUSA" ,3),0                      },;
                  {"WP_PAISORI","C",AVSX3("WP_PAISORI",3),0                      },;
                  {"WP_ESPECIF","C",AVSX3("WP_ESPECIF",3),0                      },;
                  {"WP_INFCOMP","C",AVSX3("WP_INFCOMP",3),0                      }}
                  //*FSY - 01/10/2013 - Ajuste para gravar os dados da SWP na rotina de PLI na ação "Alterar"

If Type("lPesoBruto") <> "l"
   lPesoBruto := SW3->(FieldPos("W3_PESO_BR")) > 0 .And. SW5->(FieldPos("W5_PESO_BR")) > 0 .And. SW7->(FieldPos("W7_PESO_BR")) > 0 .And.;
                 SW8->(FieldPos("W8_PESO_BR")) > 0 .And. EasyGParam("MV_EIC0014",,.F.) //FSM - 02/09/2011
EndIf

IF lTem_DSI
   AADD(Struct1,{"WKSEQ_LSI" ,"C",03,0})
   AADD(Struct1,{"WKFLAGLSI" ,"C",02,0})
ENDIF
//NCF - 08/08/2011 - Classificação N.V.A.E na PLI
If lCposNVAE
    AADD(Struct1,{"WKNVE" ,"C", AVSX3("W5_NVE",3),0})
    If ("CTREE" $ RealRDD())
       AADD(Struct1,{"WKFILTRO","C",01,0})
    EndIf
EndIf

If EICLoja()
   AADD(Struct2,{"W5_FABLOJ" ,"C",AVSX3("W5_FABLOJ",3) ,0})
   AADD(Struct2,{"W5_FAB1LOJ","C",AVSX3("W5_FAB1LOJ",3),0})
   AADD(Struct2,{"W5_FAB2LOJ","C",AVSX3("W5_FAB2LOJ",3),0})
   AADD(Struct2,{"W5_FAB3LOJ","C",AVSX3("W5_FAB3LOJ",3),0})
   AADD(Struct2,{"W5_FAB4LOJ","C",AVSX3("W5_FAB4LOJ",3),0})
   AADD(Struct2,{"W5_FAB5LOJ","C",AVSX3("W5_FAB5LOJ",3),0})
   AADD(Struct2,{"W5_FORLOJ" ,"C",AVSX3("W5_FORLOJ",3) ,0})
   AADD(Struct1,{"W5_FABLOJ" ,"C",AVSX3("W5_FABLOJ",3) ,0})
   AADD(Struct1,{"W5_FAB1LOJ","C",AVSX3("W5_FAB1LOJ",3),0})
   AADD(Struct1,{"W5_FAB2LOJ","C",AVSX3("W5_FAB2LOJ",3),0})
   AADD(Struct1,{"W5_FAB3LOJ","C",AVSX3("W5_FAB3LOJ",3),0})
   AADD(Struct1,{"W5_FAB4LOJ","C",AVSX3("W5_FAB4LOJ",3),0})
   AADD(Struct1,{"W5_FAB5LOJ","C",AVSX3("W5_FAB5LOJ",3),0})
   AADD(Struct1,{"W5_FORLOJ" ,"C",AVSX3("W5_FORLOJ",3) ,0})
EndIf

//FSM - 31/08/2011 - "Peso Bruto Unitário"
If lPesoBruto
   AADD(Struct1,{"WKW5PESOBR" ,AVSX3("W5_PESO_BR",AV_TIPO),AVSX3("W5_PESO_BR",AV_TAMANHO) ,AVSX3("W5_PESO_BR",AV_DECIMAL)})
EndIf
If AvFlags("RATEIO_DESP_PO_PLI")
   AADD(Struct1,{"WKFRETE",AVSX3("W5_FRETE",AV_TIPO),AVSX3("W5_FRETE",AV_TAMANHO) ,AVSX3("W5_FRETE",AV_DECIMAL)})
   AADD(Struct1,{"WKSEGUR",AVSX3("W5_SEGURO",AV_TIPO),AVSX3("W5_SEGURO",AV_TAMANHO) ,AVSX3("W5_SEGURO",AV_DECIMAL)})
   AADD(Struct1,{"WKINLAN",AVSX3("W5_INLAND",AV_TIPO),AVSX3("W5_INLAND",AV_TAMANHO) ,AVSX3("W5_INLAND",AV_DECIMAL)})
   AADD(Struct1,{"WKDESCO",AVSX3("W5_DESCONT",AV_TIPO),AVSX3("W5_DESCONT",AV_TAMANHO) ,AVSX3("W5_DESCONT",AV_DECIMAL)})
   AADD(Struct1,{"WKPACKI",AVSX3("W5_PACKING",AV_TIPO),AVSX3("W5_PACKING",AV_TAMANHO) ,AVSX3("W5_PACKING",AV_DECIMAL)})
   If SW3->(FieldPos("W3_OUT_DES")) > 0
      AADD(Struct1,{"WKOUTDE",AVSX3("W3_OUT_DES",AV_TIPO),AVSX3("W3_OUT_DES",AV_TAMANHO) ,AVSX3("W3_OUT_DES",AV_DECIMAL)}) //Campo criado para compatibilizacao, nao sera atualizado pela PLI, somente pelo PO
   EndIf

   AADD(Struct1,{"W5_FRETE" ,AVSX3("W5_FRETE",AV_TIPO),AVSX3("W5_FRETE",AV_TAMANHO) ,AVSX3("W5_FRETE",AV_DECIMAL)})
   AADD(Struct1,{"W5_SEGURO",AVSX3("W5_SEGURO",AV_TIPO),AVSX3("W5_SEGURO",AV_TAMANHO) ,AVSX3("W5_SEGURO",AV_DECIMAL)})
   AADD(Struct1,{"W5_INLAND",AVSX3("W5_INLAND",AV_TIPO),AVSX3("W5_INLAND",AV_TAMANHO) ,AVSX3("W5_INLAND",AV_DECIMAL)})
   AADD(Struct1,{"W5_DESCONT",AVSX3("W5_DESCONT",AV_TIPO),AVSX3("W5_DESCONT",AV_TAMANHO) ,AVSX3("W5_DESCONT",AV_DECIMAL)})
   AADD(Struct1,{"W5_PACKING",AVSX3("W5_PACKING",AV_TIPO),AVSX3("W5_PACKING",AV_TAMANHO) ,AVSX3("W5_PACKING",AV_DECIMAL)})
EndIf
lIntDraw := EasyGParam("MV_EIC_EDC",,.F.)

AADD(Struct1,{"WKPOSICAO" ,"C",LEN(SW3->W3_POSICAO),0}) //AWR 10/02/99
If lIntDraw
   AADD(Struct1,{"WKAC" ,"C", AVSX3("ED4_AC",3),0})
   AADD(Struct1,{"WKSEQSIS" ,"C", AVSX3("ED4_SEQSIS",3),0})
   AADD(Struct1,{"WKQT_AC"  ,"N",AVSX3("ED4_QT_LI",3),AVSX3("ED4_QT_LI",4)})
   AADD(Struct1,{"WKQT_AC2" ,"N",AVSX3("ED4_SNCMLI",3),AVSX3("ED4_SNCMLI",4)})
   AADD(Struct1,{"WKVL_AC"  ,"N",AVSX3("ED4_VL_LI",3),AVSX3("ED4_VL_LI",4)})
EndIf
AADD(Struct1,{"TRB_ALI_WT","C",03,0}) //TRP - 25/01/07 - Campos do WalkThru
AADD(Struct1,{"TRB_REC_WT","N",10,0})
If lInvAnt //DRL - 17/09/09 - Invoices Antecipadas
   AADD(Struct1,{"WKINVOIC",AVSX3("EW5_INVOIC",2),AVSX3("EW5_INVOIC",3),AVSX3("EW5_INVOIC",4)})
EndIf

//AOM - 08/04/2011
If lOperacaoEsp
   AADD(Struct1,{"W5_CODOPE" ,AVSX3("W5_CODOPE",2),AVSX3("W5_CODOPE",3),AVSX3("W5_CODOPE",4)})
   AADD(Struct1,{"W5_DESOPE" ,AVSX3("W5_DESOPE",2),AVSX3("W5_DESOPE",3),AVSX3("W5_DESOPE",4)})
   AADD(Struct2,{"W5_CODOPE" ,AVSX3("W5_CODOPE",2),AVSX3("W5_CODOPE",3),AVSX3("W5_CODOPE",4)})
   AADD(Struct2,{"W5_DESOPE" ,AVSX3("W5_DESOPE",2),AVSX3("W5_DESOPE",3),AVSX3("W5_DESOPE",4)})
EndIf

IF lMV_EIC_EAI//AWF - 30/06/2014
   AADD(Struct1,{"WKUNI"    ,"C",AVSX3("W3_UM"     ,3),0})
   AADD(Struct1,{"WKSEGUM"  ,"C",AVSX3("W3_SEGUM"  ,3),0})
   AADD(Struct1,{"WKQTSEGUM","N",AVSX3("W3_QTSEGUM",3),AVSX3("W3_QTSEGUM" ,4)})
   AADD(Struct1,{"WKFATOR"  ,"N",AVSX3("J5_COEF"   ,3),AVSX3("J5_COEF",4)})
ENDIF

Eval(bMsg,STR0133) //"GERANDO ARQUIVOS DE TRABALHO..."

IF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"18"),)//AWR 10/11/1999
IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"WORK"),)//CES 28/08/01

IF AvFlags("DESTAQUE_QUEBRA_LI") //LRS - 18/01/18
   AADD(Struct1,{"WKDESTEYJ","C", AVSX3("EYJ_DESTAQ",3),0})
EndIF

//by GFP - 14/10/2010 - 09:58
Struct1 := AddWkCpoUser(Struct1,"SW5")

//*** GFP - 19/08/2011 - Criação campo Filtro para tratamento.
aAdd(Struct1,{"WK_FILTRO", "C", 1, 0})

FileWork := E_CriaTrab(,Struct1,"Work") //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados

//NCF - 08/08/2011 - Classificação N.V.A.E na PLI
If lCposNVAE

   aHeader := array(0)
   aCampos := array(EIM->(fcount()))

   aSemSX3EIM  := {{"WK_RECNO" , "N", 10,0 }}
   aSemSX3CEIM := {{"WKTEC"     ,"C", 10,0 }}
   aSemSX3GEIM := {{"WK_RECNO" , "N", 10,0 },{ "EIM_ALI_WT", "C", 3,0 },{ "EIM_REC_WT", "N", 10,0 }}

   If !(Select("Work_EIM") <> 0)
      cFileWkEIM  := E_CriaTrab("EIM",aSemSX3EIM ,"Work_EIM" ,,)
   Else
      Work_EIM->(avzap())
   EndIf

   If !(Select("Work_CEIM") <> 0)
      cFileWkCEIM := E_CriaTrab("EIM",aSemSX3CEIM,"Work_CEIM",,)
   Else
      Work_CEIM->(avzap())
   EndIf

   If !(Select("Work_GEIM") <> 0)
      aAdd(aSemSX3GEIM,{"DBDELETE","L",1,0}) //THTS - 01/11/2017 - Este campo deve sempre ser o ultimo campo da Work
      cFileWkGEIM := E_CriaTrab("EIM",aSemSX3GEIM,"Work_GEIM",,)
   Else
      Work_GEIM->(avzap())
   EndIf

   cFileWK_01 := E_Create(,.F.)
   IndRegua("Work_EIM" ,cFileWK_01+TEOrdBagExt() ,"EIM_ADICAO+EIM_NIVEL+EIM_ATRIB+EIM_ESPECI")
   cFileWK_02 := E_Create(,.F.)
   IndRegua("Work_EIM" ,cFileWK_02+TEOrdBagExt() ,"EIM_CODIGO") 
 
   If !lNVEProduto
      cFileWK_07 := E_Create(,.F.)
      IndRegua("Work_EIM",cFileWK_07+TEOrdBagExt() ,"EIM_HAWB+EIM_NIVEL+EIM_CODIGO+EIM_ATRIB+EIM_ESPECI") 
   Else
      cFileWK_07 := E_Create(,.F.)
      IndRegua("Work_EIM",cFileWK_07+TEOrdBagExt() ,"EIM_HAWB+EIM_NIVEL+EIM_CODIGO+EIM_ATRIB+EIM_ESPECI+EIM_NCM")  
      cFileWK_08 := E_Create(,.F.)
      IndRegua("Work_EIM",cFileWK_08+TEOrdBagExt() ,"EIM_NCM+EIM_CODIGO") 
   EndIf 

   If !lNVEProduto   
      SET INDEX TO (cFileWK_01+TEOrdBagExt()),(cFileWK_02+TEOrdBagExt()),(cFileWK_07+TEOrdBagExt())      
   Else
      SET INDEX TO (cFileWK_01+TEOrdBagExt()),(cFileWK_02+TEOrdBagExt()),(cFileWK_07+TEOrdBagExt()),(cFileWK_08+TEOrdBagExt())
   EndIf

   cFileWK_03 := E_Create(,.F.)
   IndRegua("Work_CEIM",cFileWk_03+TEOrdBagExt() ,"EIM_CODIGO")
   SET INDEX TO (cFileWK_03+TEOrdBagExt())
   
   cFileWK_06 := E_Create(,.F.)
   IndRegua("Work_GEIM",cFileWK_06+TEOrdBagExt() ,"EIM_NIVEL+EIM_ATRIB+EIM_ESPECI"+If(lNVEProduto,"+EIM_NCM",""))   
   SET INDEX TO (cFileWK_06+TEOrdBagExt())
   
EndIf

dbSelectArea("Work")
IF ! USED()
   Help(" ",1,"E_NAOHAREA") ; lRetorno:=.F.
   Return .T.
ENDIF

If !EICLoja()
   IndRegua("Work",FileWork+TEOrdBagExt(),"WKPO_NUM+WKCC+WKSI_NUM+WKCOD_I+WKFABR+WKFORN+STR(WKREG,"+Alltrim(Str(AVSX3("W5_REG",3)))+",0)",;//+WKREGTRI",;
            "AllwaysTrue()",;
            "AllwaysTrue()",;
            STR0134) //"Processando Arquivo Temporário..."
Else
   IndRegua("Work",FileWork+TEOrdBagExt(),"WKPO_NUM+WKCC+WKSI_NUM+WKCOD_I+WKFABR+W5_FABLOJ+WKFORN+W5_FORLOJ+STR(WKREG,"+Alltrim(Str(AVSX3("W5_REG",3)))+",0)",;//+WKREGTRI",;
            "AllwaysTrue()",;
            "AllwaysTrue()",;
            STR0134) //"Processando Arquivo Temporário..."

EndIf

//*** GFP - 19/08/2011 - Criação campo Filtro para tratamento.
aAdd(Struct1,{"WK_FILTRO", "C", 1, 0})

WorkNTX3:=E_Create(Struct1,.F.)
IndRegua("Work",WorkNTX3+TEOrdBagExt(),"WKTEC",;
         "AllwaysTrue()",;
         "AllwaysTrue()",;
         STR0134) //"Processando Arquivo Temporário..."

WorkNTX2:=E_Create(Struct1,.F.)
IndRegua("Work",WorkNTX2+TEOrdBagExt(),"WKRECNO_IP",;
         "AllwaysTrue()",;
         "AllwaysTrue()",;
         STR0134) //"Processando Arquivo Temporário..."

WorkNTX4:=E_Create(Struct1,.F.)

IndRegua("Work",WorkNTX4+TEOrdBagExt(),cIndice4,; //"WKTEC+WKFABR+WKSHNA_NTX+WKALADI+WK_EX_NBM+WK_EX_NCM"+If(lIntDraw, "WKAC" , "" )
         "AllwaysTrue()",;
         "AllwaysTrue()",;
         STR0134) //"Processando Arquivo Temporário..."

WorkNTX5:=E_Create(Struct1,.F.)


IndRegua("Work",WorkNTX5+TEOrdBagExt(),"WKSEQ_LI",; //"WKSEQ_LI
         "AllwaysTrue()",;
         "AllwaysTrue()",;
         STR0134) //"Processando Arquivo Temporário..."
WorkNTX6:=E_Create(Struct1,.F.)
IndRegua("Work",WorkNTX6+TEOrdBagExt(),"WKCOD_I",; //"WKSEQ_LI
         "AllwaysTrue()",;
         "AllwaysTrue()",;
         STR0134) //"Processando Arquivo Temporário..."

//NCF - 08/08/2011 - Classificação N.V.A.E na PLI
If lCposNVAE
   WorkNTX7:=E_Create(Struct1,.F.)
   IndRegua("Work",WorkNTX7+TEOrdBagExt(),"WKNVE"+If(lNVEProduto,"+WKTEC",""),;
         "AllwaysTrue()",;
         "AllwaysTrue()",;
         STR0134) //"Processando Arquivo Temporário..."  

EndIf  

//NCF - 08/08/2011 - Classificação N.V.A.E na PLI
IF !lCposNVAE
  SET INDEX TO (FileWork+TEOrdBagExt()),(WorkNTX2+TEOrdBagExt()),(WorkNTX3+TEOrdBagExt()),(WorkNTX4+TEOrdBagExt()),(WorkNTX5+TEOrdBagExt()),(WorkNTX6+TEOrdBagExt())
ELSE
  SET INDEX TO (FileWork+TEOrdBagExt()),(WorkNTX2+TEOrdBagExt()),(WorkNTX3+TEOrdBagExt()),(WorkNTX4+TEOrdBagExt()),(WorkNTX5+TEOrdBagExt()),(WorkNTX6+TEOrdBagExt()),(WorkNTX7+TEOrdBagExt())
ENDIF

IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"INDICE"),)//RJB 07/08/03
DBSETORDER(2)

aHeader := array(0)
aCampos := array(EIT->(fcount()))

FileWork2 := GI400CriaEIT()
IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"CARREGA_EIT"),)  // Leitura dos Orgaos Anuentes - RS - 02/05/06

   ****************************** Fim *********************************
IF lTem_DSI
   /*
     11/11/2003  - JBS
     Criação da Work_SWP, com a mesma estrutura do SWP
     Apenas se for manutenção de LSI
     Work para controlar As LSIs
   */
   aSemSx3 :={{"WKRECNO",  "N",12,0},;
              {"WKFLAGWIN","C",02,0},;
              {"WKFLAG",   "L",01,0},;
              {"TRB_ALI_WT","C",03,0},; //TRP - 25/01/07 - Campos do WalkThru
              {"TRB_REC_WT","N",10,0}}

   aHeader   := array(0)
   aCampos   := array(SWP->(fcount()))
   FileWork3 := E_CriaTrab("SWP",aSemSx3,"WORK_SWP")
   IndRegua("WORK_SWP",FileWork3+TEOrdBagExt(),"WP_SEQ_LI+WP_NCM")

   ****************************** Fim *********************************
ENDIF

bCloseAll:={||.T.}

Return (lRetorno:=.T.)

*-------------------*
FUNCTION GI400TemCdc()
*-------------------*
/*
IF ! EV->(DBSEEK(EVD->EVDINVOICE+STR(EVD->EVDFORN,6,0)))
   RETURN .F.
ENDIF
IF EV->EVTEM_CDC = "S" .AND. EMPTY(EV->EVLIB_CDC)
   RETURN .F.
ENDIF*/
RETURN .T.

*--------------------------------*
FUNCTION BuscaMod(PModalidade)
*--------------------------------*
LOCAL cModalidade
DO CASE
   CASE SW2->W2_MODALID    ="1" ; cModalidade := STR0135 //"DRAWBACK"
   CASE SW2->W2_MODALID    ="2" ; cModalidade := STR0136 //"NAO DRAWBACK"
   CASE SW2->W2_MODALID    ="3" ; cModalidade := STR0137 //"ISENTO"
   CASE SW2->W2_MODALID    =" " ; cModalidade := STR0138 //"REPARO"
   OTHERWISE                    ; cModalidade := " "
ENDCASE
RETURN cModalidade

*-----------------*
PROCEDURE Gi1_Tela5
*-----------------*
//LOCAL aSemSx3:={ {"W5_REG"  ,"N",AVSX3("W5_REG",3),0} ,;
//                 {"W5_FLUXO","C",1,0} }

LOCAL aSvCampos :=ACLONE(aCampos)
LOCAL aSvaHeader:=ACLONE(aHeader), cNomArq, M_Fluxo:='1'
LOCAL M_W_Rec := RECNO() , M_W_Tela
//** PLB 26/02/07 - Walk Thru
Local ni          := 1       ,;
      aYesFields  := {}      ,;
      bRecSemX3   := {||}    ,;
      bCond       := {||}    ,;
      bAction1    := {||}    ,;
      bAction2    := {||}    ,;
      aNoHeader   := {}      ,;
      cSeek       := ""      ,;
      cFieldName  := ""      ,;
      bWhile      := {||}
Private aTRBSemSX3 := {}  ,;
        aUserCpos  := {}
//**

PRIVATE nOpc:=2

ASIZE(aCampos,0)
ASIZE(aHeader,0)

aCampos:={"W5_FABR_01",  "W5_COD_I"  , "B1_FPCOD"  ,;
          "W5_HAWB"   ,  "W6_DT_HAWB", "W5_QTDE"   ,;
          "W5_SALDO_Q",  "W5_PO_NUM" , "W5_PRECO"  ,;
          "W5_CC"     ,  "W5_SI_NUM" , "W5_DESC_P" ,;
          "W5_FABR"   ,  "W5_FABR_N" , "W5_FORN"   ,;
          "W5_FORN_N" ,  "W5_DT_EMB" , "W5_DT_ENTR"}

If EICLoja()
   AADD(aCampos,{"W5_FAB1LOJ"})
   AADD(aCampos,{"W5_FABLOJ"})
   AADD(aCampos,{"W5_FORLOJ"})
EndIf



IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"CPOS_SW5"),) // JBS - 16/07/2003 11:17
SW5->(DBSETORDER(1))

//** PLB 26/02/07 - Walk Thru
SX3->( DBSetOrder(2) )
For ni := 1  to  Len(aCampos)
   SX3->( DBSeek(IncSpace(aCampos[ni],10,.F.)) )
   If Left(aCampos[ni],3) == "W5_"
      If SX3->X3_CONTEXT == "V"
         AAdd( aUserCpos, aCampos[ni] )
      Else
         AAdd( aYesFields, aCampos[ni] )
      EndIf
   Else
      AAdd( aUserCpos, aCampos[ni] )
   EndIf
Next ni
cSeek     := ""
bWhile    := { || cSeek }
bCond     := { || .T. }
bAction1  := { || .F. }
bAction2  := { || .F. }
aNoHeader := { "W5_REG", "W5_FLUXO" }
bRecSemX3 := {|| AEval(aTRBSemSX3,{|x| M->&(x[1]) := NIL } ), .T.}
FillGetDB(nOpc, "SW5", "Work_Zoom",,1, cSeek, bWhile, { { bCond, bAction1, bAction2 } } ,/*aNoFields*/,aYesFields,,,,aNoHeader,,,/*aCpoVirtual*/,{|a, b| AfterHeader("Work_Zoom",@a,@b), OrdHeader(@a,aCampos) }, , bRecSemX3)
cNomArq := AvTrabName("Work_Zoom")
//**

DBSELECTAREA("SW5")
IF SW4->W4_FLUXO = '1' .OR. SW4->W4_FLUXO = '7' .OR. SW4->W4_FLUXO = '4' .OR. SW4->W4_FLUXO = '5'
   M_Fluxo = '1'
   PosOrd1_It_Guias(SW4->W4_PGI_NUM,TRB->W5_CC,TRB->W5_SI_NUM,TRB->W5_COD_I,TRB->W5_FABR,TRB->W5_FORN,TRB->W5_REG,0,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ"))
ELSE
   M_Fluxo = '2'
   SW5->(DBSEEK(xFILIAL()+SW4->W4_PGI_NUM))
ENDIF

Work_Zoom->(avzap())

Processa({|lEnd|GI400GrZoom(M_Fluxo)})
aHeader[1][1]:=SPACE(06)
DBSELECTAREA("Work_Zoom")
DBGOTOP()
DEFINE MSDIALOG oDlg TITLE STR0010;// FROM 9,0 TO 28,80 OF oMainWnd //"Zoom"
         FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
             OF oMainWnd PIXEL

    Work_Zoom->(oGet:=MsGetDB():New(13,1,(oDlg:nClientHeight-2)/2,(oDlg:nClientWidth-2)/2,nOpc,"E_LinOk","E_TudOk","",.F., , ,.F., ,"Work_Zoom"))

     oGet:oBrowse:bwhen:={||(dbSelectArea("Work_Zoom"),.t.)}

	 oGet:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
	 oGet:oBrowse:Refresh() //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

    ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nopca:=2,oDlg:End()},{||oDlg:End()},,)) //Alinhamento na versão MDI //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT


aCampos:=ACLONE(aSvCampos)
aHeader:=ACLONE(aSvaHeader)
Work_Zoom->(DBCLOSEAREA())
//FERASE(cNomArq+GetDBExtension())
E_EraseArq(cNomArq) //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados
DBSELECTAREA("TRB")
RETURN .T.

*----------------------------------------------------------------------------*
FUNCTION GI400GrZoom(M_Fluxo)
*----------------------------------------------------------------------------*
ProcRegua(SW5->(EasyRecCount("SW5")))
DO WHILE SW5->(!EOF()) .AND.;
         SW5->W5_FILIAL  == xFilial("SW5").AND.;
         SW5->W5_PGI_NUM == SW4->W4_PGI_NUM

   IncProc(STR0139) //"Lendo Arquivo de Itens da L.I"

   IF M_Fluxo = '1'
      IF TRB->W5_CC    <> W5_CC    .OR. TRB->W5_SI_NUM <> W5_SI_NUM  .OR. ;
         TRB->W5_COD_I <> W5_COD_I
         EXIT
      ENDIF

      IF  (TRB->W5_FABR   <> W5_FABR .And. Iif(EICLoja(),TRB->W5_FABLOJ <> W5_FABLOJ,.T.))  .OR. ;
          (TRB->W5_FORN   <> W5_FORN .And. Iif(EICLoja(),TRB->W5_FORLOJ <> W5_FORLOJ,.T.))  .OR. ;
          TRB->W5_REG     <> W5_REG   .OR. ;
          TRB->W5_PO_NUM  <> W5_PO_NUM
          DBSKIP() ; LOOP
      ENDIF
   ELSE
      IF TRB->W5_COD_I <> W5_COD_I .OR. (TRB->W5_FABR <> W5_FABR .And. Iif(EICLoja(),TRB->W5_FABLOJ <> W5_FABLOJ,.T.)) .OR. ;
         (TRB->W5_FORN  <> W5_FORN .And. Iif(EICLoja(),TRB->W5_FORLOJ <> W5_FORLOJ,.T.))  .OR. TRB->W5_PO_NUM  <> W5_PO_NUM
         DBSKIP() ; LOOP
      ENDIF
   ENDIF


   SW6->(DBSEEK(xFilial()+SW5->W5_HAWB))
   DBSELECTAREA("Work_Zoom")
   Work_Zoom->(DBAPPEND())
   Work_Zoom->W5_COD_I    :=   SW5->W5_COD_I
   Work_Zoom->W5_FABR     :=   SW5->W5_FABR
   Work_Zoom->W5_FORN     :=   SW5->W5_FORN
   Work_Zoom->W5_REG      :=   SW5->W5_REG
   Work_Zoom->W5_FABR_01  :=   IF(EMPTY(SW5->W5_HAWB),STR0030,STR0140)  //"Saldo"###"Desemb"
   Work_Zoom->W5_QTDE     :=   SW5->W5_QTDE
   Work_Zoom->W5_PRECO    :=   SW5->W5_PRECO
   Work_Zoom->W5_SALDO_Q  :=   SW5->W5_SALDO_Q
   Work_Zoom->W5_CC       :=   SW5->W5_CC
   Work_Zoom->W5_SI_NUM   :=   SW5->W5_SI_NUM
   Work_Zoom->W5_PO_NUM   :=   SW5->W5_PO_NUM
   Work_Zoom->W5_DT_EMB   :=   SW5->W5_DT_EMB
   Work_Zoom->W5_DT_ENTR  :=   SW5->W5_DT_ENTR
   Work_Zoom->W5_HAWB     :=   SW5->W5_HAWB
   Work_Zoom->W5_FLUXO    :=   SW5->W5_FLUXO
   Work_Zoom->W6_DT_HAWB  :=   SW6->W6_DT_HAWB

   If EICLoja()
      Work_Zoom->W5_FABLOJ := SW5->W5_FABLOJ
      Work_Zoom->W5_FORLOJ := SW5->W5_FORLOJ
      Work_Zoom->W5_FAB1LOJ:= SW5->W5_FAB1LOJ
   EndIf

   IF SB1->(DBSEEK(xFilial()+SW5->W5_COD_I))
      Work_Zoom->W5_DESC_P  := MSMM(SB1->B1_DESC_GI,AVSX3("B1_VM_GI",3),,,3 )
      IF AvFlags("SUFRAMA") .AND. !EMPTY(M->W4_PROD_SU)
        SYX->(DBSETORDER(3))
        IF SYX->(DBSEEK(xFilial("SYX")+M->W4_PROD_SU+SB1->B1_COD))
          Work_Zoom->W5_DESC_P := MEMOLINE(SYX->YX_DES_ZFM,36,1)
        ENDIF
        SYX->(DBSETORDER(1))
      ENDIF
      Work_Zoom->B1_FPCOD   := SB1->B1_FPCOD
   ENDIF

   IF SA2->(DBSEEK(xFilial()+SW5->W5_FABR)+EICRetLoja("SW5","W5_FABLOJ"))
      Work_Zoom->W5_FABR_N := SA2->A2_NREDUZ
   ENDIF

   IF SA2->(DBSEEK(xFilial()+SW5->W5_FORN +EICRetLoja("SW5","W5_FORLOJ")))
      Work_Zoom->W5_FORN_N := SA2->A2_NREDUZ
   ENDIF

   //** PLB 26/02/07 - Walk-Thru
   Work_Zoom->W5_ALI_WT := "SW5"
   Work_Zoom->W5_REC_WT := SW5->( RecNo() )
   //**

   IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"WORK_ZOOM"),) // JBS - 16/07/2003 11:20
   DBSELECTAREA("SW5")
   DBSKIP()
ENDDO
RETURN NIL

*----------------------------------------------------------------------------*
FUNCTION GI400Atu_Li()
*----------------------------------------------------------------------------*
LOCAL bWhile := {|| SWP->WP_PGI_NUM = M->W4_PGI_NUM .AND.;
                    SWP->WP_FILIAL == xFilial("SWP")  }
      bGrava := {|| SWP->(RecLock("SWP",.F. ))      ,;
                    SWP->WP_SUBST:=SW4->W4_LISUBST ,;
                    SWP->(MsUnlock())}
SWP->(DBSETORDER(1))
IF SWP->(DBSEEK(xFilial()+M->W4_PGI_NUM))
   SWP->(DBEVAL(bGrava,,bWhile))
ENDIF
RETURN .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GI401Altera ³ Autor ³ PADRAO PARA GETDADDB  ³ Data ³ 14.04.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa exclusivo para alteracao de L.I                     ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void GI401Altera(ExpC1,ExpN1)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                     ³±±
±±³          ³ ExpN1 = Numero do registro                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GI401Altera(cAlias,nReg,nOpc)

LOCAL oDlg, bCreate, i, s
LOCAL bFunction:={||If(GI400Atu(bValid),oDlg:End(),)}
LOCAL cResource :="SALVAR"   // nome do resource
LOCAL cToolTip  :=STR0014 //"Salva & Sai"
LOCAL bValid    :={||.T.}
LOCAL cTitulo   := STR0141 // Manutenção da LI
PRIVATE TB_Campos := {}, aSemSX3 := {}, cMarca := GetMark(), lInverte := .F.   //GFP - 02/03/2013
bCreate:={|| GI401GravaSWP(cAlias),GI400GravaEIT()}//FSY 26/09/2013 - inserido a função GI400GravaEIT para efetuar gravaçao na tabela EIT ao confirmar

PRIVATE MOpcao:=1
nQual := nOpc
DBSELECTAREA(cAlias)

//IF ! EMPTY( SWP->WP_NR_MAQ )
//   MsgInfo("Item já enviado para o siscomex, L.I. Não pode ser alterado","Informação")
//   RETURN .F.
//ENDIF

FOR i := 1 TO FCount()
   //AOM - 26/03/2010
   If FIELDNAME(i) == "WP_INFCOMP"
      //M->&(FIELDNAME(i)) := FieldGet(i)
      M->WP_INF_VM       := SWP->(MSMM(WP_INFCOMP, , , ,3)) //TAMSX3("WP_INF_VM")[1]
   Elseif FIELDNAME(i) == "WP_ESPECIF"
      M->WP_ESP_VM       := SWP->(MSMM(WP_ESPECIF, , , ,3))
   Else
    M->&(FIELDNAME(i)) := FieldGet(i)
   EndIf

NEXT

aDarGets:=NIL
aCpoLSI :={"WP_NAT_LSI","WP_URF_DES","WP_MERCOS" ,"WP_PAIS_PR","WP_LSI"   ,"WP_QT_EST","WP_ESP_VM",;
           "WP_INF_VM" ,"WP_REG_TRI","WP_FUN_REG","WP_MOTIVO" ,"WP_TEC_CL","WP_MATUSA","WP_PROCANU"}
aMostraCpo:={}
SX3->(DBSETORDER(1))
SX3->(DBSEEK("SWP"))
DO WHILE !SX3->(EOF()) .AND. SX3->X3_ARQUIVO = "SWP"
   IF ASCAN(aCpoLSI, ALLTRIM(SX3->X3_CAMPO) ) = 0 .AND.;
      X3Uso(SX3->X3_USADO)
      AADD(aMostraCpo,SX3->X3_CAMPO)
   ENDIF
   SX3->(DBSKIP())
ENDDO

If lTem_DSI
   IF SWP->WP_LSI == "1"
      aCpoLSI :={"WP_VENCTO" ,"WP_REGIST" ,"WP_ESP_VM" ,"WP_INF_VM",;//"WP_PROCANU"
                 "WP_NAT_LSI","WP_URF_DES","WP_MERCOS" ,"WP_PAIS_PR","WP_QT_EST",;
                 "WP_REG_TRI","WP_FUN_REG","WP_MOTIVO" ,"WP_TEC_CL" ,"WP_MATUSA"}
      aDarGets  :={"WP_VENCTO","WP_REGIST"}
      aMostraCpo:=ACLONE(aCpoLSI)
      cTitulo   := "Manutencao de LSI" // Manutenção da LI
   ENDIF
ENDIF

IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"ANTES_ALTERA_LI"),.T.)

// GFP - 02/03/2013 - Inclusão de grid de itens na Manutenção de LI.
For i := 1 To SW5->(FCount())
   AADD(aSemSX3,{SW5->(FIELDNAME(i)), AVSX3(SW5->(FIELDNAME(i)),2), AVSX3(SW5->(FIELDNAME(i)),3) ,AVSX3(SW5->(FIELDNAME(i)),4)})
Next i

GI400GerWkW5()

E_Inclui(cAlias,nReg,nOpc,{||GI_Init(@bCloseAll)},;
                                  bValid                 ,;
                                  bCreate,{||GI_Final(bCloseAll)},,aMostraCpo,@oDlg,cTitulo,aDarGets,,,"TRB_SW5",TB_Campos)//"Manute‡Æo de LI/Man"
If Select("TRB_SW5") > 0
  TRB_SW5->(DbCloseArea())
EndIf
RETURN
/*
FERASE(WKSaldo+GetDBExtension())
FERASE(WKSaldo+OrdBagExt())
*/ //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados
E_EraseArq(WKSaldo)
E_EraseArq(WKSaldo+TEOrdBagExt())
Return .T.

*------------------------------*
Function GI401GravaSWP(cAlias)
*------------------------------*
SWP->(RecLock("SWP",.F.))
AVREPLACE("M","SWP")
//AOM - 26/03/2010 Gravação campo Memo
If SWP->(FieldPos("WP_INFCOMP") > 0)
      MSMM(SWP->WP_INFCOMP,,,,2)
      MSMM(, TamSX3("WP_INF_VM")[1],,M->WP_INF_VM,1,,,"SWP","WP_INFCOMP")
EndIf
If SWP->(FieldPos("WP_ESPECIF") > 0)
      MSMM(SWP->WP_ESPECIF,,,,2)
      MSMM(, TamSX3("WP_ESP_VM")[1],,M->WP_ESP_VM,1,,,"SWP","WP_ESPECIF")
EndIf
IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"GRAVASWP"),.T.)
SWP->(MsUnlock())
RETURN .T.

*----------------------------*
FUNCTION GI400VALID(TProdSuf)
*----------------------------*
IF EMPTY(TProdSuf) .AND. M->W4_TIPOAPL<>"01"
   RETURN .T.
ENDIF
IF ! SYZ->(DBSEEK(xFilial()+TProdSuf))
   HELP("",1,"AVG0000442")//MsgInfo(STR0142,STR0062) //"Produto não encontrado"###"Informação"
   RETURN .F.
ENDIF
RETURN .T.

*----------------------------------------------------------------------------
FUNCTION GI400PO()
*----------------------------------------------------------------------------
LOCAL _IniPO := SPACE(LEN(SW7->W7_PO_NUM))
LOCAL lRetRdmake,cSpace,cChave
PRIVATE lRetornaValid := .T.

IF EMPTY( TPo_Num )
   HELP("",1,"AVG0000443")//MsgInfo(STR0143,STR0039) //'N£mero do P.O. nÆo informado'###"Atenção"
   Return .F.
ENDIF

cSpace:=SPACE(LEN(WORK->WKPO_NUM)-LEN(ALLTRIM(TPo_Num)))
cChave:=ALLTRIM(TPo_Num)+cSpace


If lW2ConaPro .And. SW2->(DbSeek(xFilial()+cChave)) .And. ;
   !Empty(SW2->W2_CONAPRO) .And. SW2->W2_CONAPRO<>"L"
   MsgStop(STR0225,STR0062)  // "Pedido nao liberado pela Alcada"  "Atencao"
   Return .F.
Endif

//IGOR CHIBA -AVERAGE 23/05/2014 tratamento
//para que, quando a integração via mensagem única estiver habilitada (MV_EIC_EAI), apenas seja possível utilizar Purchase Order cujo status seja aprovado
IF SW2->(DbSeek(xFilial()+cChave)) .AND. AvFlags("EIC_EAI") .AND. SW2->W2_CONAPRO <> '1'
   EasyHelp("O Purchase Order está aguardando aprovação no ERP")
   Return .F.
ENDIF


DBSELECTAREA("SW2")
DBSETORDER(1)
IF ! SW2->(DBSEEK(xFilial()+cChave))
   HELP("",1,"AVG0000444")//MsgInfo(STR0144,STR0062) //'Pedido não cadastrado'###"Informação"
   TPo_Num:= _IniPO
   Return .F.
ENDIF

IF ! EMPTY(M->W4_PROD_SU)
   M->W4_SUFRAMA:="S"
ENDIF

IF EasyEntryPoint("ICPADGI1")
  cModalidade:=" "  
  lRetRdmake := EasyExRdm("U_ICPADGI1","PLI")
  IF VALTYPE(lRetRdmake) ="L" .AND. lRetRdmake == .F.
    RETURN .F.
  ENDIF
ENDIF
IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"VALIDA_PO"),)
IF !lRetornaValid
  RETURN .F.
ENDIF
RETURN .T.

*--------------------*
Function GI_GravaWork()
*--------------------*
LOCAL nindW5 := SW5->(INDEXORD()),cDescricao,nindB1:=SB1->(INDEXORD())
LOCAL nIndSWP:= SWP->(INDEXORD()),nRecSWP

LOCAL bWhile := {|| EIT->EIT_PGI_NU== M->W4_PGI_NUM .AND.;
                    EIT->EIT_FILIAL == xFilial("EIT")  }
LOCAL bGrava := {|| GI400EITGr()}
LOCAL lInfOrgAnu
Work->(avzap())

SW5->(DBSETORDER(1))
SB1->(DBSETORDER(1))
If SW5->(DBSEEK(xFilial("SW5")+M->W4_PGI_NUM))
  Do While SW5->(!Eof()) .AND. SW5->W5_PGI_NUM == M->W4_PGI_NUM .AND. xFilial("SW5") == SW5->W5_FILIAL

   IF SW5->W5_SEQ # 0
      SW5->(DBSKIP())
      LOOP
   ENDIF

   lLoop:=.F.
   IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"SKIP_LOOP_SW5"),)
   IF lLoop
      SW5->(DBSKIP())
      LOOP
   ENDIF

   SB1->(DBSEEK(xFilial("SB1")+SW5->W5_COD_I))

   M->WK_TEC    := Busca_NCM('SW5',"NCM")
   M->WK_EX_NCM := Busca_NCM('SW5',"EX_NCM")
   M->WK_EX_NBM := Busca_NCM('SW5',"EX_NBM")

   cDescricao := MSMM(SB1->B1_DESC_GI,AVSX3("B1_VM_GI",3),1 )

   IF AvFlags("SUFRAMA") .AND. !EMPTY(M->W4_PROD_SU)
     SYX->(DBSETORDER(3))
      IF SYX->(DBSEEK(xFilial("SYX")+M->W4_PROD_SU+SB1->B1_COD))
          cDescricao := IF(!EMPTY(SYX->YX_DES_ZFM),LEFT(SYX->YX_DES_ZFM,36) ,cDescricao)
      ENDIF
      SYX->(DBSETORDER(1))
   ENDIF

   SYD->(DBSEEK(xFilial()+M->WK_TEC+M->WK_EX_NCM+M->WK_EX_NBM))

   Work->(DBAPPEND())
   //AOM - 08/04/2011
   AVREPLACE("SW5","Work")
   IF lOperacaoEsp
      Work->W5_DESOPE := POSICIONE("EJ0",1,xFilial("EJ0")+ SW5->W5_CODOPE ,"EJ0_DESC")
   ENDIF
   Work->WKCOD_I    :=   SW5->W5_COD_I
   Work->WKFABR     :=   SW5->W5_FABR
   Work->WKFABR_01  :=   SW5->W5_FABR_01
   Work->WKFABR_02  :=   SW5->W5_FABR_02
   Work->WKFABR_03  :=   SW5->W5_FABR_03
   Work->WKFABR_04  :=   SW5->W5_FABR_04
   Work->WKFABR_05  :=   SW5->W5_FABR_05
   Work->WKFORN     :=   SW5->W5_FORN
   Work->WKPRECO    :=   SW5->W5_PRECO
   Work->WKFLUXO    :=   " " // Usado como flag para Saber se quer modificar o SB1
   Work->WKQTDE     :=   SW5->W5_SALDO_Q
   Work->WKSALDO_Q  :=   SW5->W5_SALDO_Q
   Work->WKSALDO_O  :=   SW5->W5_SALDO_Q
   Work->WKSI_NUM   :=   SW5->W5_SI_NUM
   Work->WKPO_NUM   :=   SW5->W5_PO_NUM
   Work->WKCC       :=   SW5->W5_CC
   Work->WKDT_ENTR  :=   SW5->W5_DT_ENTR
   Work->WKDTENTR_S :=   SW5->W5_DT_ENTR
   Work->WKDT_EMB   :=   SW5->W5_DT_EMB
   Work->WKRECNO_IP :=   SW5->(RECNO())
   Work->WKREG      :=   SW5->W5_REG
   Work->WKTEC      :=   M->WK_TEC
   Work->WK_EX_NCM  :=   M->WK_EX_NCM
   Work->WK_EX_NBM  :=   M->WK_EX_NBM
   Work->WKPOSICAO  :=   SW5->W5_POSICAO
   Work->WKDESCR    :=   cDescricao  //MSMM(SB1->B1_DESC_GI,36,1 )
   Work->WKFAMILIA  :=   SB1->B1_FPCOD
   Work->WKDESTAQUE :=   SYD->YD_DESTAQU
   Work->WKNALADI   :=   SYD->YD_NALADI
   Work->WKNAL_SH   :=   SYD->YD_NAL_SH
   Work->WKALADI    :=   GI400BuscaAcordo("ALADI",4)  //CCH - 03/08/09 - Função para busca do Aladi e Naladi de acordo com NCM/Inclusão/Alteração e L.I.
   Work->WKSHNA_NTX :=   GI400BuscaAcordo("NALADI",4) //CCH - 03/08/09 - Função para busca do Aladi e Naladi de acordo com NCM/Inclusão/Alteração e L.I.
   Work->WKUNI_NBM  :=   SYD->YD_UNID
   Work->WKFLAG     :=   .T.
   Work->WKSEQ_LI   :=   IF(nQual <> 4,SPACE(3),SW5->W5_SEQ_LI)
   Work->WKPESO_L   :=   SW5->W5_PESO //FCD 04/07/2001
   Work->WKQTDORI   :=   SW5->W5_QTDE //LGS - 16/08/2013 
   If lCposNVAE  
      Work->WKNVE   :=   SW5->W5_NVE 
   EndIf
   //*FSY - 01/10/2013 - Ajuste para gravar os dados da SWP na rotina de PLI na ação "Alterar"
   Work->WP_NR_MAQ  :=   SWP->WP_NR_MAQ
   Work->WP_NAT_LSI :=   SWP->WP_NAT_LSI
   Work->WP_MICRO   :=   SWP->WP_MICRO
   Work->WP_PROT    :=   SWP->WP_PROT
   Work->WP_TRANSM  :=   SWP->WP_TRANSM
   Work->WP_VENCTO  :=   SWP->WP_VENCTO
   Work->WP_REGIST  :=   SWP->WP_REGIST
   Work->WP_SUBST   :=   SWP->WP_SUBST
   Work->WP_ERRO    :=   SWP->WP_ERRO
   Work->WP_NALADI  :=   SWP->WP_NALADI
   Work->WP_ALADI   :=   SWP->WP_ALADI
   Work->WP_DESTAQ  :=   SWP->WP_DESTAQ
   Work->WP_FABLOJ  :=   SWP->WP_FABLOJ
   Work->WP_ENV_ORI :=   SWP->WP_ENV_ORI
   Work->WP_RET_ORI :=   SWP->WP_RET_ORI
   Work->WP_GIP_ORI :=   SWP->WP_GIP_ORI
   Work->WP_NAL_SH  :=   SWP->WP_NAL_SH
   Work->WP_ARQ     :=   SWP->WP_ARQ
   Work->WP_SUFRAMA :=   SWP->WP_SUFRAMA
   Work->WP_FLAGWIN :=   SWP->WP_FLAGWIN
   Work->WP_NR_ALI  :=   SWP->WP_NR_ALI
   Work->WP_MERCOS  :=   SWP->WP_MERCOS
   Work->WP_DT_ENVD :=   SWP->WP_DT_ENVD
   Work->WP_LSI     :=   SWP->WP_LSI
   Work->WP_MOTIVO  :=   SWP->WP_MOTIVO
   Work->WP_TEC_CL  :=   SWP->WP_TEC_CL
   Work->WP_QT_EST  :=   SWP->WP_QT_EST
   Work->WP_MATUSA  :=   SWP->WP_MATUSA
   Work->WP_PAISORI :=   SWP->WP_PAISORI
   Work->WP_ESPECIF :=   SWP->WP_ESPECIF
   Work->WP_INFCOMP :=   SWP->WP_INFCOMP
   //*FSY - 01/10/2013

   //FSM 31/08/2011 - "Peso Bruto Unitário"
   If lPesoBruto
      Work->WKW5PESOBR := SW5->W5_PESO_BR
   EndIf
   If AvFlags("RATEIO_DESP_PO_PLI")
      Work->WKFRETE := SW5->W5_FRETE
      Work->WKSEGUR := SW5->W5_SEGURO
      Work->WKINLAN := SW5->W5_INLAND
      Work->WKDESCO := SW5->W5_DESCONT
      Work->WKPACKI := SW5->W5_PACKING
   EndIf
   Work->WKPRTOT    :=   VAL(STR(SW5->W5_SALDO_Q * SW5->W5_PRECO,nTamP,nDecP))
   Work->WKPGI_NUM  :=   SW5->W5_PGI_NUM // NCF - 11/01/2010
   //Work->WKREGTRI   :=   M->W4_REG_TRI //EIJ->EIJ_REGTRI  // GFP - 25/09/2015
   //   Work->WKSHNA_NTX :=   IF(!EMPTY(SYD->YD_NAL_SH),SYD->YD_NAL_SH,SYD->YD_NALADI)
   //   Work->WKALADI    :=   SYD->YD_ALADI
   //   Work->WKPART_N   :=   SA5->(BuscaPart_N())

   If EICLoja()
      Work->W5_FABLOJ  :=   SW5->W5_FABLOJ
      Work->W5_FAB1LOJ :=   SW5->W5_FAB1LOJ
      Work->W5_FAB2LOJ :=   SW5->W5_FAB2LOJ
      Work->W5_FAB3LOJ :=   SW5->W5_FAB3LOJ
      Work->W5_FAB4LOJ :=   SW5->W5_FAB4LOJ
      Work->W5_FAB5LOJ :=   SW5->W5_FAB5LOJ
      Work->W5_FORLOJ  :=   SW5->W5_FORLOJ
   EndIf

   If SW3->(FieldPos("W3_PART_N")) # 0  //ASK 05/10/07
      SW3->(DBSetOrder(8))
      SW3->(DbSeek(xFilial("SW3") + SW5->W5_PO_NUM + SW5->W5_POSICAO))
      If !Empty(SW3->W3_PART_N)
         Work->WKPART_N := SW3->W3_PART_N
      Else
         Work->WKPART_N := SA5->(BuscaPart_N())
      EndIf
   Else
      Work->WKPART_N := SA5->(BuscaPart_N())
   EndIf

   If lIntDraw
      Work->WKAC    :=   SW5->W5_AC
      Work->WKSEQSIS:=   SW5->W5_SEQSIS
      Work->WKQT_AC :=   SW5->W5_QT_AC
      Work->WKQT_AC2:=   SW5->W5_QT_AC2
      Work->WKVL_AC :=   SW5->W5_VL_AC
   EndIf
   If lTem_DSI.and.cRotinaOPC == "LSI"  // JBS 18/12/2003
      Work->WKSEQ_LI  := SW5->W5_SEQ_LI
   EndIf
   IF(EasyEntryPoint("ICPADGI2"),ExecBlock("ICPADGI2",.F.,.F.,"PESO_L"),.F.)

   If lInvAnt .And. SW5->(FIELDPOS("W5_INVANT")) > 0 //DRL - 16/09/09 - Invoices Antecipadas
      If !Empty(SW5->W5_INVANT)
         nBasePLI := 1
         WORK->WKINVOIC := SW5->W5_INVANT
         If SW5->W5_PESO == 0
            nxOrdEW5:=EW5->(IndexOrd())
            EW5->(dbSetOrder(2))
            If EW5->(dbSeek(xFilial("EW5")+SW3->W3_PO_NUM+SW3->W3_POSICAO+SW5->W5_INVANT+SW5->W5_FORN+EICRetLoja("SW5","W5_FORLOJ")))
               WORK->WKPESO_L := EW5->EW5_PESOL
            EndIf
            EW5->(dBSetOrder(nxOrdEW5))
         EndIf
      EndIF
   EndIf

   IF lMV_EIC_EAI//AWF - 25/06/2014
      aSegUM:=Busca_2UM(SW5->W5_PO_NUM,SW5->W5_POSICAO)
      IF LEN(aSegUM) > 0
         Work->WKUNI    :=aSegUM[1]
         Work->WKSEGUM  :=aSegUM[2]
         Work->WKFATOR  :=aSegUM[3]
         Work->WKQTSEGUM:=Work->WKQTDE*Work->WKFATOR
      ENDIF
   ENDIF

   IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"WKDESPESAS"),)

  SW5->(DbSkip())
 EndDo
 SW5->(DBSETORDER(nIndW5))
 SB1->(DBSETORDER(nIndB1))
ENDIF
// Apenas se for PLI/LI

//if ( (cRotinaOPC <> "LSI") .AND. (cRotinaOPC=="LI" .AND. SWP->WP_LSI<>"1") )
if cRotinaOPC == "LI"

   Work_EIT->(avzap())
   // Carrega primeiro do EIT

   EIT->(dbseek(xFilial("EIT")+M->W4_PGI_NUM))
   EIT->(DBEVAL(bGrava,,bWhile))

   // Carrega do cadastro de itens (SB1) os campos de anuencia somente para quem tem os campos
   // no SX3.

   SX3->(dbsetorder(2))
   lInfOrgAnu:=SX3->(DBSEEK("B1_ORG_ANU")) .AND. SX3->(DBSEEK("B1_PRO_ANU"))

   IF lInfOrgAnu   // APENAS PARA QUEM TEM INFORMACOES DE ORGAOS ANUENTES NO SX3
      Processa({||GI400grvOrgAnu()})
   ENDIF
endif
IF lTem_DSI
   SWP->(DBSETORDER(1))
   SWP->(DBSEEK(xFilial("SWP")+SW4->W4_PGI_NUM))
   IF SWP->WP_LSI == "1"
      GI400WorkSWP()
   ENDIF
ENDIF

Return

*--------------------*
Function GI_Altera()
*--------------------*
Local oDlg,nOpcao:=0,cItem,cIndex,lCase:=.F.
Local nRecWK
Local nRecWK_SWP  // JBS - 05/01/2004

Private cNCM:=Work->WKTEC,cExNCM:=Work->WK_EX_NCM,cExNBM:=Work->WK_EX_NBM
cIndex="Index"+TEOrdBagExt()

Do While .T.

   DEFINE MSDIALOG oDlg TITLE STR0273  From 9,0 To 20,75 OF oMainWnd // STR0273 "Selecao de NCM"

   oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165)
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   @ 1.0,1 SAY "NCM:" OF oPanel SIZE 20,8
   @ 1.0,5  MSGET cNCM   F3 AVSX3("W3_TEC",8)    PICTURE AVSX3("W3_TEC",6)    Valid GI400Val('NCM')    OF oPanel SIZE 42,8

   @ 2.0,1  SAY "EX-NCM:" OF oPanel SIZE 10,8
   @ 2.0,5  MSGET cExNCM F3 AVSX3("W3_EX_NCM",8) PICTURE AVSX3("W5_EX_NCM",6) Valid GI400Val('EX-NCM') OF oPanel SIZE 30,8

   @ 2.0,12 SAY "EX-NBM:" OF oPanel SIZE 10,8
   @ 2.0,15 MSGET cExNBM F3 AVSX3("W3_EX_NBM",8) PICTURE AVSX3("W5_EX_NBM",6) Valid GI400Val('EX-NBM') OF oPanel SIZE 30,8

   @ 60,10 CheckBox lCase PROMPT STR0274 OF oPanel SIZE 100,8 //STR0274 "Alterar no Cadastro de Produto"

   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,{||(nOpcao:=1,oDlg:End())},{||oDlg:End()}) CENTERED

   If nOpcao ==1
      CItem:=Work->WKCOD_I
      nRecWK := Work->(RECNO())
      If lTem_DSI.and.cRotinaOPC=="LSI"  // JBS 05/01/2004
         nRecWK_SWP := Work_SWP->(RECNO())
      EndIf
      IF AvFlags("SUFRAMA") .AND. !EMPTY(M->W4_PROD_SU).AND. EasyEntryPoint("EICGI333")
         If !ExecBlock("EICGI333",.F.,.F.,"ALTERA")
            Loop
         EndIf
      ENDIF
      nIND:= Work->(IndexOrd())
      Work->(DBSETORDER(0))
      Work->(DbGoTop())
      Do While Work->(!EOF())
         If cItem==Work->WKCOD_I
            Work->WKTEC:=cNCM
            Work->WK_EX_NCM:=cExNCM
            Work->WK_EX_NBM:=cExNBM
            Work->WKUNI_NBM:=If(SYD->(DBSEEK(xFilial()+cNCM+cExNCM+cExNBM)),SYD->YD_UNID,) // SVG - 23/07/09 -
            Work->WKFLUXO:= IF(lCase,"*"," ")

            If lTem_DSI.and.cRotinaOPC=="LSI"  // JBS 05/01/2004
               If Work_SWP->(dbSeek(Work->WKSEQ_LI))
                  Work_SWP->WP_NCM := Work->WKTEC
               EndIF
            Endif

         EndIf
         If !lTem_DSI.or.cRotinaOPC=="LI"  // JBS 05/01/2004
            Work->WKSEQ_LI := "  "
            Work->WKFLAG := .T.
         EndIf
         Work->(DbSkip())
      ENDDO

      Work->(DBSETORDER(nInd))
      Work->(DBGOTO(nRecWK))
      If lTem_DSI.and.cRotinaOPC=="LSI"  // JBS 05/01/2004
         Work_SWP->(DBGOTO(nRecWK_SWP))
      EndIf

      IF AvFlags("SUFRAMA") .AND. !EMPTY(M->W4_PROD_SU).AND. EasyEntryPoint("EICGI333")
         ExecBlock("EICGI333",.F.,.F.,"ATUALIZA")
      EndIf

      lAltera:=.T.
   EndIf
   Exit
EndDo
Work->(DbGotop())
oMark:oBrowse:Refresh()
Ferase(cIndex)
//E_EraseArq(cIndex) //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados
Return .T.

*--------------------*
Function GravaGI400()
*--------------------*
Local nOrderSWP:=SWP->(IndexOrd()),nOrderSW3:=SW3->(INDEXORD())
Local indWork ,cNcm,cTec,nFab,cNal,nAla,nOrderWK:=Work->(IndexOrd())
Local nAltPos, nPreco, nOrdWork := 0
PRIVATE nSeq:=1 ,nInd ,nFob:=0

IF cRotinaOPC=="LSI" // JBS - 17/11/2003
   nTamEsp:=AVSX3("WP_ESP_VM",3)
   nTamInf:=AVSX3("WP_INF_VM",3)
ENDIF

If !Inclui

   SWP->(DbSetOrder(1))
   IF SWP->(DBSEEK(xFilial("SWP")+M->W4_PGI_NUM))
      Do While SWP->WP_FILIAL==xFilial("SWP").And. SWP->WP_PGI_NUM==M->W4_PGI_NUM
         RecLock("SWP",.F.,.F.)
         SWP->(DbDelete())
         SWP->(MsUnLock())
         SWP->(DbSkip())
      EndDo
   ENDIF
   IF cRotinaOPC#"LSI" // JBS - 26/11/2003
     indWork:=E_CREATE(,.F.)
     IndRegua("Work",indWork+TEOrdBagExt(),cIndice4,; //"WKTEC+WKFABR+WKSHNA_NTX+WKALADI+WK_EX_NBM+WK_EX_NCM"+If(lIntDraw, "WKAC" , "" )
              STR0275) // STR0275 "Indexando Arquivo  Temporario..."
   else
      Work->(DBSETORDER(4))
   EndIf
   Work->(DBGOTOP())
   Do While Work->(!Eof())
      If lIntDraw .and. Empty(M->W4_ATO_CON)
         nAltPos := ASCAN(aAltSW5,{|X| X[1]==M->W4_PGI_NUM .and. X[2]==Work->WKPO_NUM .and. X[3]=Work->WKPOSICAO})
         If nAltPos > 0
            SW5->(dbSetOrder(8))
            ED4->(dbSetOrder(2))
            SW5->(dbSeek(cFilSW5+aAltSW5[nAltPos,1]+aAltSW5[nAltPos,2]+aAltSW5[nAltPos,3]))
            SW5->(RecLock("SW5",.F.))
            If ED4->(dbSeek(cFilED4+SW5->W5_AC+SW5->W5_SEQSIS))
               If ED0->ED0_AC <> ED4->ED4_AC .or. ED0->ED0_FILIAL <> cFilED0
                  ED0->(dbSeek(cFilED0+ED4->ED4_AC))
               EndIf
               ED4->(RecLock("ED4",.F.))
               ED4->ED4_VL_LI  += SW5->W5_VL_AC
               If ED0->ED0_TIPOAC <> GENERICO .or. Alltrim(ED4->ED4_NCM) <> NCM_GENERICA
                  ED4->ED4_QT_LI  += SW5->W5_QT_AC
                  ED4->ED4_SNCMLI += SW5->W5_QT_AC2
               EndIf
            EndIf
            SW5->W5_AC     := Work->WKAC
            SW5->W5_SEQSIS := Work->WKSEQSIS
            If Empty(Work->WKAC)
               SW5->W5_QT_AC  := 0
               SW5->W5_VL_AC  := 0
            Else
               nPreco := GI400ApVal() //ConvVal(If(!Empty(MMoeda),MMoeda,SW4->W4_MOEDA),Work->WKQTDE * Work->WKPRECO)
               SW5->W5_VL_AC  := nPreco
               ED4->(dbSeek(cFilED4+Work->WKAC+Work->WKSEQSIS))
               If ED0->ED0_AC <> ED4->ED4_AC .or. ED0->ED0_FILIAL <> cFilED0
                  ED0->(dbSetOrder(2))
                  ED0->(dbSeek(cFilED0+ED4->ED4_AC))
                  ED0->(dbSetOrder(1))
               EndIf
               cItemAx := Work->WKCOD_I
               If cItemAx != ED4->ED4_ITEM
                  cItemAx := IG400BuscaItem("I",cItemAx,ED4->ED4_PD)  // PLB 14/11/06
               EndIf
               VerificaQTD(.F.,,,ED0->ED0_TIPOAC,cItemAx)
               ED4->(RECLOCK("ED4",.F.))
               ED4->ED4_VL_LI  -=  nPreco
               If ED0->ED0_TIPOAC <> GENERICO .or. Alltrim(ED4->ED4_NCM) <> NCM_GENERICA
                  ED4->ED4_QT_LI  -= nQtdAux
                  ED4->ED4_SNCMLI -= nQtdNcmAux  // PLB 18/07/07
                  SW5->W5_QT_AC  := nQtdAux
                  SW5->W5_QT_AC2 := nQtdNcmAux
               EndIf
               ED4->(msUnlock())
            EndIf
            SW5->(msUnlock())
         EndIf
      EndIf

      SW5->(DbSetOrder(1))
      SW5->(DbSeek(xFilial("SW5")+M->W4_PGI_NUM+Work->WKCC+Work->WKSI_NUM+Work->WKCOD_I))

      Do While SW5->(!Eof()).And.SW5->W5_PGI_NUM==M->W4_PGI_NUM .And.SW5->W5_CC==Work->WKCC .And.;
               SW5->W5_COD_I==Work->WKCOD_I .AND. xFilial("SW5") == SW5->W5_FILIAL
         If (lIntDraw .and. SW5->W5_AC==Work->WKAC) .or. !lIntDraw
            RecLock("SW5",.F.)
            SW5->W5_SEQ_LI:=Work->WKSEQ_LI
            SW5->W5_TEC := Work->WKTEC //MCF - 19/06/2015
            SW5->W5_EX_NCM := Work->WK_EX_NCM
            SW5->W5_EX_NBM := Work->WK_EX_NBM
            //FSM 31/08/2011 - "Peso Bruto Unitário"
            If lPesoBruto
               SW5->W5_PESO_BR := Work->WKW5PESOBR
            EndIf
            If AvFlags("RATEIO_DESP_PO_PLI")
               SW5->W5_FRETE   := Work->WKFRETE 
               SW5->W5_SEGURO  := Work->WKSEGUR 
               SW5->W5_INLAND  := Work->WKINLAN 
               SW5->W5_DESCONT := Work->WKDESCO 
               SW5->W5_PACKING := Work->WKPACKI 
            EndIf
            IF lCposNVAE
               SW5->W5_NVE := Work->WKNVE
            ENDIF
			IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"GRAVAGI400_SW5"),)  //JWJ 07/10/2005
            SW5->(MsUnLock())
         EndIf
         SW5->(DbSkip())
      EndDo

      // NCF - 12/01/2010 - Gravação de alteração no peso dos itens da PLI
      SW5->(DbGoTo(Work->WKRECNO_IP))
      IF Work->WKPESO_L <> SW5->W5_PESO
         RecLock("SW5",.F.)
         SW5->W5_PESO := Work->WKPESO_L
         SW5->(MsUnLock())
      ENDIF

      // DFS - 18/10/2011 - Gravação de alteração na data de Embarque dos itens da PLI
      IF Work->WKDT_EMB <> SW5->W5_DT_EMB
         RecLock("SW5",.F.)
         SW5->W5_DT_EMB := Work->WKDT_EMB
         SW5->(MsUnLock())
      ENDIF

      // DFS - 18/10/2011 - Gravação de alteração na data de Entrega dos itens da PLI
      IF Work->WKDT_ENTR  <> SW5->W5_DT_ENTR
         IF AvFlags("EIC_EAI") .And. ascan(aEnv_PO,SW5->W5_PO_NUM + SW5->W5_POSICAO) == 0
            aadd(aEnv_PO,SW5->W5_PO_NUM + SW5->W5_POSICAO)
         ENDIF
         RecLock("SW5",.F.)
         SW5->W5_DT_ENTR := Work->WKDT_ENTR
         SW5->(MsUnLock())
      ENDIF

      IF lCposNVAE .And. Work->WKNVE <> SW5->W5_NVE
         RecLock("SW5",.F.)
         SW5->W5_NVE := Work->WKNVE
         SW5->(MsUnLock())
      ENDIF 

      IF Work->WKFLUXO=="*"
          SB1->(DBSETORDER(1))
          IF SB1->(DBSEEK(xFilial("SB1")+Work->WKCOD_I))
             SB1->(RECLOCK("SB1"),.F.)
             SB1->B1_POSIPI := Work->WKTEC
             SB1->B1_EX_NCM := Work->WK_EX_NCM
             SB1->B1_EX_NBM := Work->WK_EX_NBM
             SB1->(MSUNLOCK())
          ENDIF
       ENDIF

     IF cRotinaOPC=="LI".AND.!SWP->(DBSEEK(xFilial("SWP")+M->W4_PGI_NUM+Work->WKSEQ_LI))  // JBS - 17/11/2003
       RecLock("SWP",.T.)
       SWP->WP_FILIAL  := xFilial("SWP")
       SWP->WP_PGI_NUM := M->W4_PGI_NUM
       SWP->WP_SEQ_LI  := Work->WKSEQ_LI
       SWP->WP_NCM     := Work->WKTEC
       SWP->WP_NALADI  := Work->WKNALADI
       SWP->WP_ALADI   := Work->WKALADI
       SWP->WP_FABR    := Work->WKFABR
       //SWP->WP_DESTAQ  := Work->WKDESTAQUE //LRS - 13/01/2016
       SWP->WP_NAL_SH  := Work->WKNAL_SH
       SWP->WP_UNID    := Work->WKUNI_NBM

       //*FSY - 01/10/2013 - Ajuste para gravar os dados da SWP na rotina de PLI na ação "Alterar"
       SWP->WP_NR_MAQ  := Work->WP_NR_MAQ
       SWP->WP_NAT_LSI := Work->WP_NAT_LSI
       SWP->WP_MICRO   := Work->WP_MICRO
       SWP->WP_PROT    := Work->WP_PROT
       SWP->WP_TRANSM  := Work->WP_TRANSM
       SWP->WP_VENCTO  := Work->WP_VENCTO
       SWP->WP_REGIST  := Work->WP_REGIST
       SWP->WP_SUBST   := Work->WP_SUBST
       SWP->WP_ERRO    := Work->WP_ERRO
       SWP->WP_NALADI  := Work->WP_NALADI
       SWP->WP_ALADI   := Work->WP_ALADI
       //SWP->WP_DESTAQ  := Work->WP_DESTAQ //LRS - 13/01/2016
       SWP->WP_FABLOJ  := Work->WP_FABLOJ
       SWP->WP_ENV_ORI := Work->WP_ENV_ORI
       SWP->WP_RET_ORI := Work->WP_RET_ORI
       SWP->WP_GIP_ORI := Work->WP_GIP_ORI
       SWP->WP_NAL_SH  := Work->WP_NAL_SH
       SWP->WP_ARQ     := Work->WP_ARQ
       SWP->WP_SUFRAMA := Work->WP_SUFRAMA
       SWP->WP_FLAGWIN := Work->WP_FLAGWIN
       SWP->WP_NR_ALI  := Work->WP_NR_ALI
       SWP->WP_MERCOS  := Work->WP_MERCOS
       SWP->WP_DT_ENVD := Work->WP_DT_ENVD
       SWP->WP_LSI     := Work->WP_LSI
       SWP->WP_MOTIVO  := Work->WP_MOTIVO
       SWP->WP_TEC_CL  := Work->WP_TEC_CL
       SWP->WP_QT_EST  := Work->WP_QT_EST
       SWP->WP_MATUSA  := Work->WP_MATUSA
       SWP->WP_PAISORI := Work->WP_PAISORI
       SWP->WP_ESPECIF := Work->WP_ESPECIF
       SWP->WP_INFCOMP := Work->WP_INFCOMP
      
       IF AvFlags("DESTAQUE_QUEBRA_LI") //LRS - 18/01/18
          EYJ->(DbSetOrder(1)) //Filial + Cod. Produto
          If EYJ->(DbSeek(xFilial("EYJ") + AvKey(Work->WKCOD_I,"EYJ_COD")))
             IF !Empty(EYJ->EYJ_DESTAQ)
                SWP->WP_DESTAQ  := EYJ->EYJ_DESTAQ
             Else
                SWP->WP_DESTAQ  := SYD->YD_DESTAQU
             EndIF
          EndIF
       Else
          SWP->WP_DESTAQ  := SYD->YD_DESTAQU //LRS - 13/01/2016
       EndIF

       //*FSY - 01/10/2013

       //SwpGrava() //FSM - 12/11/2010

       If lIntDraw .and. Empty(M->W4_ATO_CON)
          SWP->WP_AC      := Work->WKAC
       EndIf
       SWP->WP_PAIS_PR := M->W4_COD_PRO
       //** PLB 06/08/07 - Tratamento de Regime de Tributação da PLI
       If lW4_Reg_Tri
          SWP->WP_REG_TRI := M->W4_REG_TRI
          SWP->WP_FUN_REG := M->W4_REGIMP
       EndIf
       //**
       IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"GRAVAGI400_SWP"),)   //JWJ 07/10/2005
       SWP->(MsUnLock())

       SwpGrava() //FSM - 14/06/2011

     EndIf
     Work->(DbSkip())
   EndDo
   IF cRotinaOPC=="LSI" // JBS - 17/11/2003
      //
      // Gravando a Work_SWP quando for uma LSI -> Capa da LSI
      //
      Work_SWP->(dbGotop())
      M->WP_PGI_NUM := Work_SWP->WP_PGI_NUM

      nOrdWork := Work->(IndexOrd())
      Work->(dbSetOrder(5))

      Do While work_SWP->(!eof())
         // JBS - 26/12/2003
         If !Work->(dbSeek(Work_SWP->WP_SEQ_LI)).or.!Work->WKFLAG
            Work_SWP->(dbSkip())
            Loop
         EndIf

         If !SWP->(dbseek(xFilial("SWP")+Work_SWP->WP_PGI_NUM+Work_SWP->WP_SEQ_LI))
            SWP->(RecLock("SWP",.T.))
            AvReplace("Work_SWP","SWP")
            MSMM(,nTamEsp,,Work_SWP->WP_ESP_VM,1,,,"SWP","WP_ESPECIF")
            MSMM(,nTamInf,,Work_SWP->WP_INF_VM,1,,,"SWP","WP_INFCOMP")
            SWP->WP_FILIAL := xFilial("SWP")
            SWP->(MsUnlock())
         EndIf

         Work_SWP->(dbSkip())

      EndDo
      Work->(dbSetOrder(nOrdWork))

      // JBS 25/11/2003
      // Gravação dos Numeros e Orgaos dos Processo Anuentes...
      // -------------------------------------------------------
      // Apaga no EIT, Todas as ocorrencias da LSI para Evitar
      // Conflitos antes de registrar alterações da Work_EIT.
      //
      GI400DelEIT(.F.) // Evita Conflitos
      //
      //  Após apagar as Ocorrencias da LSI, Grava os Dados da Work_EIT   - JBS 24/11/2003
      //
      GI400APPEND_EIT() // Grava EIT

   ENDIF

   IF cRotinaOPC#"LSI" // JBS - 26/12/2003 ->Manter Compatibilidade
      //FERASE(indWork)
      E_EraseArq(indWork) //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados
   ENDIF

   SWP->(DbSetOrder(nOrderSWP))

EndIf

Return .T.

*----------------------*
Function GI400ConsAnu()
*----------------------*
Local nOpc := 0, cPgi:=SWP->WP_PGI_NUM, aSeqLI
Local bOk     := {|| nOpc:=1,oDlgAnu:End() }
Local bCancel := {|| oDlgAnu:End() }
Local bValid:={||IF(ASCAN(aSeqLi,cSeqLI)<>0,.T.,.F.)}
Local cSeqLI, oDlgANU
Local nLastArea := SELECT()                          //NCF-06/04/2011

FileWork2 := GI400CriaEIT()   // Cria Work_EIT
aSeqLI:={}
Processa({||GI400LESWP(@aSeqLI)})

IF lManuLI
   cSeqLi:=aSeqLI[1]  // Pega a que estiver parada
   GI400BroWKEIT(cPgi,cSeqLi)
ELSE

   Begin Sequence
      DEFINE MSDIALOG oDlgAnu TITLE STR0218 FROM 07,0 TO 14.8,50 OF oMainWnd // - BHF - 16/10/08 - Alinhamento MDI

      @ 020,05 SAY STR0218 OF oDlgAnu SIZE 232,10 PIXEL //"Seq. Li" //STR0218  "Sequencia LI's"
      @ 020,45 COMBOBOX cSeqLI ITEMS aSeqLI SIZE 35,10 OF oDlgAnu PIXEL VALID EVAL(bValid)

      ACTIVATE MSDIALOG oDlgAnu on Init EnchoiceBar(oDlgAnu, bOk , bCancel) CENTERED

      IF nOpc == 1
         GI400BroWKEIT(cPgi,cSeqLi)
      ENDIF
   End Sequence
ENDIF

IF SELECT("Work_EIT") <> 0
   Work_EIT->(E_EraseArq(FileWork2)) //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados
   FERASE(FileWork2+TEOrdBagExt())
ENDIF

SELECT(nLastArea)                         //NCF-06/04/2011

Return .T.                                //NCF-06/04/2011

*--------------------*
Function GI400LESWP(aSeqLI)
*--------------------*
Local cFilSWP:=xFilial("SWP"), cPgi:=SWP->WP_PGI_NUM, cFilEIT:=xFilial("EIT")
Local nRecSWP:=SWP->(RECNO())
LOCAL bWhile := {|| EIT->EIT_PGI_NU== cPgi .AND. EIT->EIT_SEQ_LI==SWP->WP_SEQ_LI,;
                    EIT->EIT_FILIAL == xFilial("EIT")  }

LOCAL cSeqLI
LOCAL bGrava := {|| GI400EITGr(cPgi)}

ProcRegua(SWP->(EasyRecCount("SWP")))

IF lManuLI
   cSeqLI:=SWP->WP_SEQ_LI
ENDIF

SWP->(dbseek(cFilSWP+cPgi))
WHILE ! SWP->(EOF()) .and. SWP->WP_FILIAL == cFilSWP .and. SWP->WP_PGI_NUM == cPgi
  IncProc(STR0211+' '+SWP->WP_SEQ_LI) // Gravando dados de Processo Anuente
  IF lManuLI  // Quando for Manut LI, na consulta ele ja esta parado naquela seq.
     IF SWP->WP_SEQ_LI <> cSeqLI
        SWP->(DBSKIP());LOOP
     ENDIF
  ENDIF
  IF ASCAN(aSeqLI,SWP->WP_SEQ_LI) == 0
     EIT->(dbseek(cFilEIT+SWP->WP_PGI_NUM+SWP->WP_SEQ_LI))
     EIT->(DBEVAL(bGrava,,bWhile))
     AADD(aSeqLI,SWP->WP_SEQ_LI)
  ENDIF
  SWP->(DBSKIP())
END
SWP->(dbgoto(nRecSWP))
RETURN NIL

*---------------------------------*
STATIC FUNCTION EICGI400DESC(nOpc)
*---------------------------------*
LOCAL bBotao:={||oDlg4:End()}, i
LOCAL nTotal:=80,nTop:=nLeft:=nBottom:=nRight:=0,cAlias:=ALIAS() //,ENTER:=CHR(13)+CHR(10)
LOCAL cCodigo,cDesc:=""
LOCAL aOrd := SaveOrd({"SB1","SYX"})
LOCAL oMark,aTb_Campos:={},aSem:={}

PRIVATE aCampos:={},aHeader:={}
nOpc:=IF(nOpc==NIL,2,nOpc)
AADD(aSem,{"WKDESCR","C",nTotal,0})
AADD(aSem,{"TRB_ALI_WT","C",03,0}) //TRP - 25/01/07 - Campos do WalkThru
AADD(aSem,{"TRB_REC_WT","N",10,0})

cFile:=E_CriaTrab(,aSem,"WORK_DESC")

SB1->(DBSETORDER(1))
SYX->(DBSETORDER(3))

IF nOpc==2
   cCodigo:=TRB->W5_COD_I
ELSE
   cCodigo:=WORK->WKCOD_I
ENDIF

IF SB1->(DBSEEK(xFilial("SB1")+cCodigo))
   cDesc:= MSMM(SB1->B1_DESC_GI,AVSX3("B1_VM_GI",3))
   cDesc:=STRTRAN(cDesc,ENTER," ")
   IF AvFlags("SUFRAMA")  .AND. !EMPTY(SW4->W4_PROD_SU)
      IF SYX->(DBSEEK(xFilial("SYX")+SW4->W4_PROD_SU+SB1->B1_COD))
         cDesc :=SYX->YX_DES_ZFM
      ENDIF
   ENDIF
ENDIF

FOR i:=1 TO MLCOUNT(cDesc,nTotal)
   IF !EMPTY(MEMOLINE(cDesc,nTotal,i))
      WORK_DESC->(DBAPPEND())
      WORK_DESC->WKDESCR:=MEMOLINE(cDesc,nTotal,i)
      WORK_DESC->TRB_ALI_WT:= "SB1"
      WORK_DESC->TRB_REC_WT:=  SB1->(Recno())
   ENDIF
NEXT

AADD(aTb_Campos,{"WKDESCR"    ,"",STR0088}) //"Descri‡Æo p/ P.L.I."

//DFS - Ponto de Entrada para trazer a descrição do P.O. na PLI
If EasyEntryPoint("EICGI400")
   ExecBlock("EICGI400",.F.,.F.,"MEMO_ITEM")
Endif

oMainWnd:ReadClientCoors()

DEFINE MSDIALOG oDlg4 TITLE (STR0088+" "+STR0071+" "+cCodigo);// FROM nTop,nLeft TO nBottom,nRight
       FROM oMainWnd:nTop+150,oMainWnd:nLeft+10 TO oMainWnd:nBottom-90,oMainWnd:nRight-30 OF oMainWnd PIXEL

WORK_DESC->(DBGOTOP())
oMark:= MsSelect():New("WORK_DESC",,,aTb_Campos,@lInverte,@cMarca,{15,2,(oDlg4:nClientHeight-6)/2,(oDlg4:nClientWidth-3.5)/2})
oMark:oBrowse:Refresh()

oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
oMark:oBrowse:Refresh()          //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT


ACTIVATE MSDIALOG oDlg4  ON INIT (ENCHOICEBAR(oDlg4,bBotao,bBotao)) //Alinhamento para versão MDI //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

RestOrd(aOrd)
WORK_DESC->(E_EraseArq(cFile))
DBSELECTAREA(cAlias)
RETURN .T.

/*
Função          : Conjunto de funções para Drawback
Objetivo        : Apropriação de Ato Concessório
Autor           : Gustavo Carreiro
Data/Hora       :
Obs.            :
*/
*--------------------------------*
Static Function GI400ApuraAC(cRot)
*--------------------------------*
Local cAto:="", dDtVal, nSalLI, cPos:=""
Local cAto2:="", dDtVal2, nSalLI2, cPos2:=""
Local cPos3:=""
Local cMelhor:="", lSaldo
Local aItem := {}, ni := 1, cOldItem := ""
Local cMsgRet := ""
Private cAto4 := "", cPos4 := "", aNaoApropria := {}, lAlternativo := .F.
Private nNivel1:=0, nNivel2:=0, nNivel3:=0, nNivel4 := 0 //Controla novas buscas
Private lMens:=.F., lMensUM:=.F., cCamb:=VerCobertura(MCond_Pag,MDias_Pag), cRotina := cRot
Private cItem
nQtdAux:=0
nQtdNcmAux:=0
cUnid  :=""

ED0->(dbSetOrder(2))
SA5->(dbSetOrder(3))
cCGC := BuscaCNPJ(M->W4_IMPORT)   //Função BuscaCNPJ() está no EDCAC400.PRW

Work->(dbGoTop())
Do While !Work->(EOF())
   cItem := Work->WKCOD_I
   cPos:=""; cAto:=""; cPos2:=""; cAto2:=""; cPos3:=""; lOk:=.F.
   lAlternativo := .F.
   If cRotina == "A" .and. !Empty(Work->WKAC)
      Work->(dbSkip())
      Loop
   EndIf
   If (cRotina == "I" .and. Work->WKFLAGWIN <> cMarca) .or. ! lMostraAC
      Work->(dbSkip())
      Loop
   EndIf
   If !Empty(Work->WKAC)
      ED4->(dbSetOrder(2))
      ED4->(dbSeek(cFilED4+Work->WKAC+Work->WKSEQSIS))
      If cItem != ED4->ED4_ITEM
         cItem := IG400BuscaItem("I",cItem,ED4->ED4_PD)  // PLB 14/11/06
      EndIf
      ED4->(msUnlock())
      DelSaldoAC()
      Work->(RecLock("Work",.F.))
      Work->WKSALDO_Q := Work->WKSALDO_O
      Work->WKQTDE    := Work->WKSALDO_O
      Work->WKAC      := ""
      Work->WKSEQSIS  := ""
      Work->(msUnlock())
   EndIf
   ED4->(dbSetOrder(3))
   ED4->(dbSeek(cFilED4+cCGC+cItem+cCamb+DtoS(dDataBase),.T.))  //SoftSeek
   If nNivel1 > 0
      ED4->(dbSkip(nNivel1))
   EndIf
   If ED0->ED0_AC <> ED4->ED4_AC .or. ED0->ED0_FILIAL <> cFilED0
      ED0->(dbSeek(cFilED0+ED4->ED4_AC))
   EndIf
   If ED4->ED4_FILIAL==cFilED4 .and. ED4->ED4_CNPJIM==cCGC .and. ED4->ED4_ITEM==cItem .and. ED4->ED4_CAMB==cCamb
      If !Empty(ED4->ED4_AC) .and. (ED4->ED4_QT_LI > 0 .or.;
      (ED0->ED0_TIPOAC==GENERICO .and. ED4->ED4_NCM = NCM_GENERICA .and. ED4->ED4_VL_LI > 0)) .and.;
      Empty(ED0->ED0_DT_ENC) .and. VerSaldoAC(1,ED0->ED0_TIPOAC) .and.;
      if(EasyGParam("MV_EDC0005",,.F.), ED0->ED0_STATUS == "6", .T.)  // ALS - 12/12/2007 - Caso esteja habilitado o envio para o Siscomex Web o Status deve ser Deferido
         cPos    := ED4->ED4_SEQSIS
         cAto    := ED4->ED4_AC
         dDtVal  := ED4->ED4_DT_VAL
         nSalLI  := ED4->ED4_QT_LI
         lOk     := .T.
      Else
         nNivel1 += 1
      EndIf
   Else
      nNivel1 := 0
   EndIf
   ED4->(dbSetOrder(4))
   ED4->(dbSeek(cFilED4+cCGC+Work->WKTEC+Space(Len(ED4->ED4_ITEM))+cCamb+DtoS(dDataBase),.T.))  //SoftSeek
   If nNivel2 > 0
      ED4->(dbSkip(nNivel2))
   EndIf
   If ED0->ED0_AC <> ED4->ED4_AC .or. ED0->ED0_FILIAL <> cFilED0
      ED0->(dbSeek(cFilED0+ED4->ED4_AC))
   EndIf
   If ED4->ED4_FILIAL==cFilED4 .and. ED4->ED4_CNPJIM==cCGC .and. Work->WKTEC==ED4->ED4_NCM .and. Empty(ED4->ED4_ITEM) .and. ED4->ED4_CAMB==cCamb
      If !Empty(ED4->ED4_AC) .and. (ED4->ED4_QT_LI > 0 .or.;
      (ED0->ED0_TIPOAC==GENERICO .and. ED4->ED4_NCM = NCM_GENERICA .and. ED4->ED4_VL_LI > 0)) .and.;
      Empty(ED0->ED0_DT_ENC) .and. VerSaldoAC(1,ED0->ED0_TIPOAC) .and.;
      if(EasyGParam("MV_EDC0005",,.F.), ED0->ED0_STATUS == "6", .T.)  // ALS - 12/12/2007 - Caso esteja habilitado o envio para o Siscomex Web o Status deve ser Deferido
         cPos2   := ED4->ED4_SEQSIS
         cAto2   := ED4->ED4_AC
         dDtVal2 := ED4->ED4_DT_VAL
         nSalLI2 := ED4->ED4_QT_LI
         lOk     := .T.
      Else
         nNivel2 += 1
      EndIf
   Else
      nNivel2 := 0
   EndIf

   ED4->(dbSeek(cFilED4+cCGC+AvKey("99999999","ED4_NCM")+Space(Len(ED4->ED4_ITEM))+cCamb+DtoS(dDataBase),.T.))  //SoftSeek
   If nNivel3 > 0
      ED4->(dbSkip(nNivel3))
   EndIf
   If ED0->ED0_AC <> ED4->ED4_AC .or. ED0->ED0_FILIAL <> cFilED0
      ED0->(dbSeek(cFilED0+ED4->ED4_AC))
   EndIf
   If ED4->ED4_FILIAL==cFilED4 .and. ED4->ED4_CNPJIM==cCGC .and. Alltrim(ED4->ED4_NCM)=="99999999" .and. Empty(ED4->ED4_ITEM) .and. ED4->ED4_CAMB==cCamb
      If !Empty(ED4->ED4_AC) .and. ED4->ED4_VL_LI > 0 .and. Empty(ED0->ED0_DT_ENC) .and. VerSaldoAC(1,GENERICO) .and.;
      if(EasyGParam("MV_EDC0005",,.F.), ED0->ED0_STATUS == "6", .T.)  // ALS - 12/12/2007 - Caso esteja habilitado o envio para o Siscomex Web o Status deve ser Deferido
         cPos3   := ED4->ED4_SEQSIS
         lOk     := .T.
      Else
         nNivel3 += 1
      EndIf
   Else
      nNivel3 := 0
   EndIf

   If !Empty(cPos) .and. !Empty(cPos2)
      If MelhorAC(dDtVal,nSalLI,dDtVal2,nSalLI2)
         cMelhor := cAto+cPos
      Else
         cMelhor := cAto2+cPos2
      EndIf
   ElseIf Empty(cPos) .and. Empty(cPos2)
      cMelhor := ""
   ElseIf Empty(cPos2)
      cMelhor := cAto+cPos
   Else
      cMelhor := cAto2+cPos2
   EndIf

   ED4->(dbSetOrder(2))
   If cMelhor == cAto+cPos .and. !Empty(cMelhor)
      If !Empty(cPos3)
         If MelhorAC(dDtVal,nSalLI,ED4->ED4_DT_VAL,0)
            ED4->(dbSeek(cFilED4+cAto+cPos))
         EndIf
      Else
         ED4->(dbSeek(cFilED4+cAto+cPos))
      EndIf
   ElseIf cMelhor == cAto2+cPos2 .and. !Empty(cMelhor)
      If !Empty(cPos3)
         If MelhorAC(dDtVal2,nSalLI2,ED4->ED4_DT_VAL,0)
            ED4->(dbSeek(cFilED4+cAto2+cPos2))
         EndIf
      Else
         ED4->(dbSeek(cFilED4+cAto2+cPos2))
      EndIf
   //ElseIf Empty(cPos3)
   //   lOk := .F.
   EndIf
   If ED0->ED0_AC <> ED4->ED4_AC .or. ED0->ED0_FILIAL <> cFilED0
      ED0->(dbSeek(cFilED0+ED4->ED4_AC))
   EndIf

   // PLB 16/11/06 - Verifica se os itens são alternativos, em caso afirmativo busca Ato com os itens principais
   If Len(aItem := IG400AllItens("I",cItem)) > 0
      nRecED4 := 0
      If lOk
         nRecED4 := ED4->( Recno() )
         dDtVal2 := ED4->ED4_DT_VAL
         nSalLI2 := ED4->ED4_QT_LI
      EndIf
      For ni := 1  to  Len(aItem)
         If !Empty(aItem[ni][2])
            cUnid := Busca_UMNCM(aItem[ni][1]+Work->WKFABR+Work->WKFORN,Work->WKCC+WORK->WKSI_NUM)
            ED4->(dbSetOrder(7))
            If ED4->(dbSeek(cFilED4+aItem[ni][2]+Work->WKTEC+aItem[ni][1]+cUnid) )  .And.  AScan(aNaoApropria,{ |x| x==ED4->( RecNo() ) }) == 0
               If ED0->ED0_AC <> ED4->ED4_AC .or. ED0->ED0_FILIAL <> cFilED0
                  ED0->(dbSeek(cFilED0+ED4->ED4_AC))
               EndIf
               If !Empty(ED4->ED4_AC) .and. ED4->ED4_QT_LI > 0  .and.;
               Empty(ED0->ED0_DT_ENC) .and. VerSaldoAC(1,ED0->ED0_TIPOAC) .and.;
               if(EasyGParam("MV_EDC0005",,.F.), ED0->ED0_STATUS == "6", .T.)  // ALS - 12/12/2007 - Caso esteja habilitado o envio para o Siscomex Web o Status deve ser Deferido
                  dDtVal1 := ED4->ED4_DT_VAL
                  nSalLI1 := ED4->ED4_QT_LI
                  If !lOk  .Or.  dDtVal1 < dDtVal2  .Or.  (dDtVal1 == dDtVal2 .and. nSalLI1 < nSalLI2)
                     cPos4   := ED4->ED4_SEQSIS
                     cAto4   := ED4->ED4_AC
                     dDtVal2 := ED4->ED4_DT_VAL
                     nSalLI2 := ED4->ED4_QT_LI
                     cOldItem:= cItem
                     cItem   := aItem[ni][1]
                     lOk     := .T.
                     nRecED4 := ED4->( Recno() )
                     lAlternativo := .T.
                  EndIf
               EndIf
            EndIf
         Else
            ED4->(dbSetOrder(3))
            ED4->(dbSeek(cFilED4+cCGC+aItem[ni][1]+cCamb+DtoS(dDataBase),.T.))  //SoftSeek
            If nNivel4 > 0
               ED4->(dbSkip(nNivel4))
            EndIf
            If ED0->ED0_AC <> ED4->ED4_AC .or. ED0->ED0_FILIAL <> cFilED0
               ED0->(dbSeek(cFilED0+ED4->ED4_AC))
            EndIf
            If ED4->ED4_FILIAL==cFilED4 .and. ED4->ED4_CNPJIM==cCGC .and. ED4->ED4_ITEM==aItem[ni][1] .and. ED4->ED4_CAMB==cCamb  .And.  AScan(aNaoApropria,{ |x| x==ED4->( RecNo() ) }) == 0
               If !Empty(ED4->ED4_AC) .and. ED4->ED4_QT_LI > 0 .and.;
                  Empty(ED0->ED0_DT_ENC) .and. VerSaldoAC(1,ED0->ED0_TIPOAC) .and.;
                  if(EasyGParam("MV_EDC0005",,.F.), ED0->ED0_STATUS == "6", .T.)  // ALS - 12/12/2007 - Caso esteja habilitado o envio para o Siscomex Web o Status deve ser Deferido
                  dDtVal1 := ED4->ED4_DT_VAL
                  nSalLI1 := ED4->ED4_QT_LI
                  If !lOk  .Or.  dDtVal1 < dDtVal2  .Or.  (dDtVal1 == dDtVal2 .and. nSalLI1 < nSalLI2)
                     cPos4   := ED4->ED4_SEQSIS
                     cAto4   := ED4->ED4_AC
                     dDtVal2 := ED4->ED4_DT_VAL
                     nSalLI2 := ED4->ED4_QT_LI
                     cOldItem:= cItem
                     cItem   := aItem[ni][1]
                     lOk     := .T.
                     nRecED4 := ED4->( Recno() )
                     lAlternativo := .T.
                  EndIf
               Else
                  nNivel4 += 1
               EndIf
            Else
               nNivel4 := 0
            EndIf
         EndIf
      Next ni
      ED4->( DBGoTo(nRecED4) )
   EndIf

   If lOk
      If !VerificaQTD(.T.,ED4->ED4_AC,ED4->ED4_SEQSIS,ED0->ED0_TIPOAC,cItem) .and.;
      (ED0->ED0_TIPOAC<>GENERICO .or. ED4->ED4_NCM <> NCM_GENERICA)
         lMensUM := .T.
         Loop
      EndIf

      lSaldo := VerSaldoAC(2,ED0->ED0_TIPOAC)
      //Verifica Saldo
      If (ED0->ED0_TIPOAC==GENERICO .and. ED4->ED4_NCM=NCM_GENERICA) .or. (ED4->ED4_QT_LI >= nQtdAux .and. lSaldo)
  
          cMsgRet += GI400ValAnt(ED0->ED0_PD,ED4->ED4_ITEM,ED4->ED4_SEQSIS)
          Apropria(.T.,ED0->ED0_TIPOAC,,cItem)
  
      Else
         //ConfirmaAC(cAto,cPos,.T.,If(!lSaldo,2,1),cItem)
         //** PLB 18/07/07 - Procura outro Ato caso não haja saldo
         If cAto == ED4->ED4_AC  .And.  cPos == ED4->ED4_SEQSIS
            nNivel1 += 1
         ElseIf cAto4 == ED4->ED4_AC .and. cPos4 == ED4->ED4_SEQSIS
            nNivel4 += 1
         ElseIf Alltrim(ED4->ED4_NCM) <> "99999999"
            nNivel2 += 1
         Else
            nNivel3 += 1
         EndIf
         //**
      EndIf
      If nNivel1 > 0 .or. nNivel2 > 0 .or. nNivel3 > 0  .Or.  nNivel4 > 0  .Or.  Len(aNaoApropria) > 0
         Loop
      EndIf
   Else
      If nNivel1 > 0 .or. nNivel2 > 0 .or. nNivel3 > 0  .Or.  nNivel4 > 0
         Loop
      Else
         If !Empty(cOldItem)
            cItem := cOldItem
         EndIf
         MsgInfo(STR0168+Alltrim(cItem)+" "+STR0022+" "+Alltrim(Work->WKPOSICAO)+ENTER+;
                 STR0277 + Alltrim(Str(Work->WKQT_AC))+; // STR0277 "Saldo Disponível: "
                 STR0278 +Alltrim(Work->WKAC)) //"Nenhum Ato Concessorio encontrado para o item " # "Posição" //STR0278 " no A.C. "
      EndIf
   EndIf

   Work->(dbSkip())
EndDo

If lMensUM
   HELP("",1,"AVG0005359")//LRL 08/01/04 MsgInfo(STR0171)//"Alguns Atos nao puderam ser utilizados pois nao possuem conversao com a Unidade de Medida do Produto. Cadastre uma conversao para as unidades de medida."
ElseIf lMens
   MsgInfo(STR0167) //"Alguns Itens nao puderam ser apropriados pois o A.C. estava sendo usado para outro processo."
EndIf

If ! Empty(cMsgRet)
  lMsgAC := .T.
  If EasyEntryPoint("EICGI400")
    Execblock("EICGI400",.F.,.F.,"MSG_AC")
  EndIf
  If lMsgAC <> nil .and. lMsgAC
    MsgInfo(cMsgRet,"Ato Concessório")
  EndIf
EndIf

ED4->(dbSetOrder(1))
SA5->(dbSetOrder(1))
ED0->(dbSetOrder(1))
dbSelectArea("Work")
Work->(dbGoTop())
oMark:oBrowse:Refresh()

Return .T.

*---------------------------------------------------*
Static Function Apropria(lBotao,cTipoAC,nTipo,cCod_I)
*---------------------------------------------------*
Local lAutQtde:=.F., nPreco, nQuant, cMoedaDolar:=BuscaDolar()//EasyGParam("MV_SIMB2",,"US$")
Local lLockOK := .T.
If(nTipo=NIL,nTipo=1,)

If ED4->ED4_NCM <> Work->WKTEC .and. Left(ED4->ED4_NCM,8) <> NCM_GENERICA
   MsgInfo(STR0179+Alltrim(ED4->ED4_AC)+STR0180+Alltrim(Work->WKPOSICAO)+STR0181) //"NCM do Item no Ato Concessorio " # " é diferente da NCM do Item da Posicao " # " na L.I. Ato nao podera ser utilizado."
   If lBotao
      nNivel1 += 1
   Else
      WorK->WKSALDO_Q := TSaldo_Q
   EndIf
   Return .T.
EndIf

// PLB 18/07/07 - Quando não há saldo no Ato Concessório não há apropriação
/*
If nTipo = 2
   nAPos  := ASCAN(aApropria,{|X| X[1]==ED4->ED4_AC .and. X[2]=ED4->ED4_SEQSIS})
   nQuant := ED4->ED4_QT_LI - aApropria[nAPos,3]
   nQuant2:= ED4->ED4_SNCMLI - aApropria[nAPos,5]
Else
   nQuant := ED4->ED4_QT_LI
   nQuant2:= ED4->ED4_SNCMLI
EndIf
*/
//** PLB 29/11/06 - Verifica se é possivel a apropriação do Ato Concessório
If lMUserEDC
   nOrderSW5 := SW5->( IndexOrd() )
   nRecnoSW5 := SW5->( RecNo() )
   SW5->( DBSetOrder(1) )
   If !SW5->( DBSeek(cFilSW5+M->W4_PGI_NUM+Work->WKCC+Work->WKSI_NUM+Work->WKCOD_I) )  ;
      .Or.  Empty(Work->( WKAC+WKSEQSIS ))  .Or.  SW5->( W5_AC+W5_SEQSIS ) != Work->( WKAC+WKSEQSIS )
      lLockOK := oMUserEDC:Reserva("PLI","ALT_ATO_2")
      If !Empty(Work->( WKAC+WKSEQSIS ))
         oMUserEDC:Solta("PLI","ALT_ATO")
      EndIf
   Else
      lLockOK := oMUserEDC:Reserva("PLI","ALT_ATO_1")
   EndIf
   SW5->( DBSetOrder(nOrderSW5) )
   SW5->( DBGoTo(nRecnoSW5) )
EndIf
//**
//If !SoftLock("ED4")
If !lLockOK
   If !lBotao
      MsgInfo(STR0166) //"Item do Ato Concessorio esta sendo utilizado em outro processo e nao podera ser apropriado."
      WorK->WKSALDO_Q := TSaldo_Q
   Else
      lMens := .T.
      If Empty(ED4->ED4_ITEM) .and. Left(ED4->ED4_NCM,8) <> NCM_GENERICA
         nNivel2 += 1
      ElseIf Empty(ED4->ED4_ITEM) .and. Left(ED4->ED4_NCM,8) = NCM_GENERICA
         nNivel3 += 1
      ElseIf cAto4 == ED4->ED4_AC .and. cPos4 == ED4->ED4_SEQSIS
         nNivel4 += 1
      Else
         nNivel1 += 1
      EndIf
   EndIf
   Return .T.
EndIf

nPreco := GI400ApVal()

If ED4->ED4_VL_LI < nPreco .or. !VerSaldoAC(2,cTipoAC,.T.)
   If (cTipoAC == GENERICO .and. ED4->ED4_NCM = NCM_GENERICA) .or. EasyGParam("MV_ACSLDVL",,.F.)
      MostraValor(nPreco,lBotao)
      WorK->WKSALDO_Q := TSaldo_Q
      If (nPosaPos:=aScan(aPosica,Work->WKPOSICAO)) > 0
         nPos:=aScan(aAntDraw,{|x| x[2]==Work->WKCOD_I})
         aAntDraw[nPos,3] += nQtdAux
         ADEL(aPosica,nPosaPos)
         ASIZE(aPosica,LEN(aPosica)-1)
      EndIf
      Return .T.
   Else
      MsgInfo(STR0165+CHR(13)+CHR(10)+STR0173+Alltrim(cCod_I)+" "+cMoedaDolar+;  //"Valor total do Item maior que saldo em valor do A.C." # "Valor do Item "
      TRANSFORM(nPreco,AVSX3("ED4_VL_LI",6))+CHR(13)+CHR(10)+STR0174+Alltrim(ED4->ED4_AC)+" "+cMoedaDolar+;  //"Valor no A.C. "
      TRANSFORM(ED4->ED4_VL_LI,AVSX3("ED4_VL_LI",6)))
   EndIf
EndIf
// PLB 18/07/07 - Quando não há saldo no Ato Concessório não há apropriação
/*
If (nQuant < nQtdAux .OR. nQuant2 < nQtdNCMAux)  .and. (cTipoAC <> GENERICO .or. ED4->ED4_NCM <> NCM_GENERICA)
   lAutQtde := .T.
EndIf
*/

Work->(RecLock("Work",.F.))
Work->WKAC      := ED4->ED4_AC
Work->WKSEQSIS  := ED4->ED4_SEQSIS
Work->WKQT_AC   := nQtdAux
Work->WKQT_AC2  := nQtdNcmAux
Work->WKVL_AC   := nPreco
// PLB 18/07/07 - Quando não há saldo no Ato Concessório não há apropriação
/*
If lAutQtde
   If !lBotao
      Work->WKSALDO_Q += Work->WKQTDE - nQuant
   ElseIf Work->WKFLAG .and. Work->WKSALDO_Q<>Work->WKSALDO_O
      Work->WKSALDO_Q += Work->WKQTDE - nQuant
   EndIf
   Work->WKQTDE    := AVTransUnid(ED4->ED4_UMITEM,cUnid,cCod_I,nQuant)
EndIf
*/

If lMostraAC
   WorK->WKFLAG    := .T.
   Work->WKFLAGWIN := cMarca
EndIf

nAPos := ASCAN(aApropria,{|X| X[1]==Work->WKAC .and. X[2]=Work->WKSEQSIS})
If nAPos > 0
   aApropria[nAPos,3] += Work->WKQT_AC
   aApropria[nAPos,4] += Work->WKVL_AC
   aApropria[nAPos,5] += Work->WKQT_AC2
Else
   AADD(aApropria,{Work->WKAC,Work->WKSEQSIS,Work->WKQT_AC,Work->WKVL_AC,Work->WKQT_AC2})
EndIf

If lBotao .and. cRotina == "A"
   aADD(aAltSW5,{M->W4_PGI_NUM,Work->WKPO_NUM,Work->WKPOSICAO})
EndIf

If lBotao
   nNivel1 := 0
   nNivel2 := 0
   nNivel3 := 0
   nNivel4 := 0
EndIf

Return .T.

/**-------------------------------------------------------*
Static Function ConfirmaAC(cAto,cPos,lBotao,nTipo,cCod_I)
*-------------------------------------------------------*
Local oDlg, nOp:=0, oBtnOK, oBtnNO, nAPos, nQtdeLI
If(nTipo=NIL,nTipo:=1,)

If nTipo = 2
   nAPos := ASCAN(aApropria,{|X| X[1]==ED4->ED4_AC .and. X[2]=ED4->ED4_SEQSIS})
EndIf

If ED4->ED4_QT_LI < nQtdAux
   DEFINE MSDIALOG oDlg TITLE STR0164 ; //"Confirmacao de Apropriacao"
          FROM 15,03 To 30,46 OF oMainWnd

      @0.5,0.5   SAY STR0162 //"O Ato Concessorio escolhido para este item possui Saldo menor que "
      @1,0.5  SAY STR0163 //"Quantidade do Item na unidade de medida do item no A.C."
      @2,3 SAY AVSX3(If(!Empty(ED4->ED4_ITEM),"ED4_ITEM","ED4_NCM"),5) SIZE 50,8
      @2,9 MSGET If(!Empty(ED4->ED4_ITEM),ED4->ED4_ITEM,ED4->ED4_NCM) PICTURE If(!Empty(ED4->ED4_ITEM),"@!",AVSX3("ED4_NCM",6)) WHEN .F. SIZE 60,7
      @3,3 SAY AVSX3("ED0_AC",5) SIZE 50,8
      @3,9 MSGET ED4->ED4_AC PICTURE "@!" WHEN .F. SIZE 60,7
      @4,3 SAY AVSX3("W5_QTDE",5) SIZE 50,8
      @4,9 MSGET nQtdAux PICTURE AVSX3("ED4_QT_LI",6) WHEN .F. SIZE 60,7
      @5,3 SAY STR0188 SIZE 50,8 //"Saldo no A.C."
      @5,9 MSGET If(nTipo=1,ED4->ED4_QT_LI,ED4->ED4_QT_LI-aApropria[nAPos,3]) PICTURE AVSX3("ED4_QT_LI",6) WHEN .F. SIZE 60,7
      @8,7 BUTTON oBtnOK PROMPT STR0159 SIZE 40,13 ACTION (nOp:=1,oDlg:End()) OF oDlg //"Confirma A.C."
      If lBotao
         @8,19 BUTTON oBtnNO PROMPT STR0160 SIZE 55,13 ACTION (nOp:=2,oDlg:End()) OF oDlg //"Apropria outro A.C."
      Else
         @8,19 BUTTON oBtnNO PROMPT STR0161 SIZE 50,13 ACTION (nOp:=0,oDlg:End()) OF oDlg //"Cancela"
      EndIf
      nQtdeLI:= nQtdAux
   ACTIVATE MSDIALOG oDlg CENTERED
Else
   //** AAF - 09/09/05 - Validação da Quantidade na Unidade de NCM.
   DEFINE MSDIALOG oDlg TITLE STR0164 ; //"Confirmacao de Apropriacao"
          FROM 15,03 To 30,52 OF oMainWnd

      @0.5,0.5 SAY STR0208//"O Ato Concessorio escolhido para este item possui Saldo na NCM menor que "
      @1,0.5  SAY STR0209//"Quantidade do Item na unidade de medida da NCM no A.C."
      @2,3 SAY AVSX3(If(!Empty(ED4->ED4_ITEM),"ED4_ITEM","ED4_NCM"),5) SIZE 50,8
      @2,9 MSGET If(!Empty(ED4->ED4_ITEM),ED4->ED4_ITEM,ED4->ED4_NCM) PICTURE If(!Empty(ED4->ED4_ITEM),"@!",AVSX3("ED4_NCM",6)) WHEN .F. SIZE 60,7
      @3,3 SAY AVSX3("ED0_AC",5) SIZE 50,8
      @3,9 MSGET ED4->ED4_AC PICTURE "@!" WHEN .F. SIZE 60,7
      @4,3 SAY AVSX3("W5_QTDE",5) SIZE 50,8
      @4,9 MSGET nQtdNcmAux PICTURE AVSX3("ED4_SNCMLI",6) WHEN .F. SIZE 60,7
      @5,3 SAY STR0188 SIZE 50,8 //"Saldo no A.C."
      @5,9 MSGET If(nTipo=1,ED4->ED4_SNCMLI,ED4->ED4_SNCMLI-aApropria[nAPos,5]) PICTURE AVSX3("ED4_QT_LI",6) WHEN .F. SIZE 60,7
      @8,7 BUTTON oBtnOK PROMPT STR0159 SIZE 40,13 ACTION (nOp:=1,oDlg:End()) OF oDlg //"Confirma A.C."
      If lBotao
         @8,19 BUTTON oBtnNO PROMPT STR0160 SIZE 55,13 ACTION (nOp:=2,oDlg:End()) OF oDlg //"Apropria outro A.C."
      Else
         @8,19 BUTTON oBtnNO PROMPT STR0161 SIZE 50,13 ACTION (nOp:=0,oDlg:End()) OF oDlg //"Cancela"
      EndIf
      nQtdeLI:= nQtdNcmAux
   ACTIVATE MSDIALOG oDlg CENTERED
   //**
Endif

If nOp=1
   IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,{"AJUSTA_SALDO_LI",nQtdeLI}),)  //TRP-05/07/07
   If GI400ValAnt(ED0->ED0_PD,ED4->ED4_ITEM)
      Apropria(lBotao,,nTipo,cCod_I)
   ElseIf lBotao
      If cAto == ED4->ED4_AC .and. cPos == ED4->ED4_SEQSIS
         nNivel1 += 1
      ElseIf cAto4 == ED4->ED4_AC .and. cPos4 == ED4->ED4_SEQSIS
         nNivel4 += 1
      ElseIf Alltrim(ED4->ED4_NCM) <> "99999999"
         nNivel2 += 1
      Else
         nNivel3 += 1
      EndIf
   EndIf
ElseIf nOp=2
   If lAlternativo
      AAdd(aNaoApropria,ED4->( RecNo() ))
   ElseIf cAto == ED4->ED4_AC .and. cPos == ED4->ED4_SEQSIS
      nNivel1 += 1
   ElseIf cAto4 == ED4->ED4_AC .and. cPos4 == ED4->ED4_SEQSIS
      nNivel4 += 1
   ElseIf Alltrim(ED4->ED4_NCM) <> "99999999"
      nNivel2 += 1
   ElseIf Alltrim(ED4->ED4_NCM)  == NCM_GENERICA
      nNivel3 += 1
   EndIf
EndIf

nOp:=0

Return .T.*/

*------------------------------------*
Static Function ValidaAC(cTipo,cCod_I)
*------------------------------------*
Local cCGC
Private lRet := .T. //Usado no Rdmake da Embraer. - TAN
Private cMotivo := ""

If !lIntDraw
   Return .T.
EndIf

cCGC := BuscaCNPJ(M->W4_IMPORT)   //Função BuscaCNPJ() está no EDCAC400.PRW
ED0->(dbSetOrder(2))
ED4->(dbSetOrder(2))
SA5->(dbSetOrder(3))

If cTipo=="ATO"
   //29.mai.2009 - 720288 - Trata campo de AC. apagado com Seq. preenchida - HFD
   If Empty(cAc) .AND. !Empty(cSeqSis)
      M->(cSeqSis) := space(3)
   endIf
   If !Empty(cAc) .and. !ExistCpo("ED0",cAc,2)
      lRet:=.F.
   ElseIf EasyGParam("MV_EDC0005",,.F.) //ALS - 11/12/2007 Caso Siscomex Web esteja ativado verifica se o Ato foi Deferido
      ED0->(dbSeek(cFilED0+cAc))
      If !Empty(cAc)    // SVG - 19/09/09 Verifica se o Ato Concessório foi preenchido
         If ED0->(dbSeek(cFilED0+cAc)) .And. !ED0->ED0_STATUS == "6" //Deferido
            EasyHelp(STR0382 + " ("+Alltrim(cAc)+")." + ENTER + STR0383) //"Ato concessório não deferido" ####"Para prosseguir, verifique se o campo Situação foi atualizado com a integração com o Easy Drawback Web"
            lRet:=.F.
         EndIf
      EndIf
   EndIf
ElseIf cTipo=="TELA3"
   If !Empty(cAc)  .Or.  !Empty(cSeqSis)
      If Empty(cSeqSis)
         MsgInfo(STR0189) //"Necessário preencher a Seq. do Ato Concessório."
         lRet:=.F.
      ElseIf Empty(cAc)
         MsgInfo(STR0190) //"A Seq. não pode ser informada para Ato Concessório vazio."
         lRet:=.F.
      ElseIf !HaveConvert(cCod_I,ED0->ED0_MODAL,.T.)
         lRet:=.F.
      ElseIf ED4->(dbSeek(cFilED4+cAC+cSeqSis))                                        //NCF - 30/03/11 - Verificação da Cond.Pgto do item e da PLI no botão "OK"
         IF ED4->ED4_CAMB <> VerCobertura(M->W4_COND_PA,M->W4_DIAS_PA)
            cMotivo := STR0255 +Chr(13)+Chr(10) //STR0255 "Divergência na apropriação"
            cMotivo += STR0256 +ED4->ED4_AC+STR0257+ED4->ED4_SEQSIS+Chr(13)+Chr(10) //STR0256 "Ato Concessório " //STR0257 " sequência "
            If ED4->ED4_CAMB == "1"
               cMotivo += STR0260 +Alltrim(ED4->ED4_ITEM)+ STR0261 + Chr(13)+Chr(10) //STR0260 "   O item " //STR0261 " não pode ser apropriado, pois no Ato Concessório o mesmo possui Cobertura Cambial"
               cMotivo += STR0262 + Chr(13)+Chr(10) //STR0262 " e a condição de pagamento utilizada está Sem cobertura Cambial. Para que o item possa ser apropriado as condições devem estar em comum."
            ElseIf ED4->ED4_CAMB == "2"
               cMotivo += STR0260 +Alltrim(ED4->ED4_ITEM)+ STR0261  + Chr(13)+Chr(10)//STR0260 "   O item " //STR0261 " não pode ser apropriado, pois no Ato Concessório o mesmo possui Cobertura Cambial"
               cMotivo += STR0262 + Chr(13)+Chr(10) //STR0262 " e a condição de pagamento utilizada está Sem cobertura Cambial. Para que o item possa ser apropriado as condições devem estar em comum."
            EndIf

                              //AOM - 15/09/2011
            If ED4->ED4_QT_LI<=0
               cMotivo += STRTRAN(STR0302,"###",AllTrim(ED4->ED4_AC)) + AllTrim(Transform(ED4->ED4_QT_LI,AVSX3("ED4_QT_LI",6))) //"Saldo da LI insuficiente no Ato Concessório ### para o Item selecionado. Saldo atual no Ato Concessório de : "
            EndIf

             EECView(cMotivo,STR0263) //STR0263 "Divergências - Não foi possível apropriar o Ato Concessório"
            lRet:=.F.
         ENDIF
      EndIf
   EndIf
ElseIf cAC<>Work->WKAC .or. cSeqSis<>Work->WKSEQSIS .or. IF(lIntDraw,TCondPgto<>M->W4_COND_PA,.T.)
                                                         //NCF - 30/03/11 - Alterada a condição de pagamento com item apropriado
   If !Empty(cAC) .and. !Empty(cSeqSis)
      If !ExistCpo("ED4",cAc+cSeqSis,2)  // PLB 24/04/06 - Inclusao de verificacao de Ato+Sequencia
         lRet := .F.
      ElseIf !Empty(ED4->ED4_ITEM)
         If cAC <> ED4->ED4_AC .or. cSeqSis <> ED4->ED4_SEQSIS
            ED4->(dbSeek(cFilED4+cAC+cSeqSis))
         EndIf
         If ED0->ED0_AC <> ED4->ED4_AC .or. ED0->ED0_FILIAL <> cFilED0
            ED0->(dbSeek(cFilED0+ED4->ED4_AC))
         EndIf
         If ED4->ED4_ITEM != cCod_I
             cCod_I := IG400BuscaItem("I",cCod_I,ED4->ED4_PD)  // PLB 14/11/06
         EndIf
         If ED4->ED4_FILIAL<>cFilED4 .or. ED4->ED4_CNPJIM<>cCGC .or. ED4->ED4_ITEM<>cCod_I .or.;
         (ED4->ED4_QT_LI<=0 .and. (ED0->ED0_TIPOAC<>GENERICO .or. ED4->ED4_NCM<>NCM_GENERICA)) .or. ;
         !Empty(ED0->ED0_DT_ENC) .or. (ED4->ED4_VL_LI<=0 .and. ED0->ED0_TIPOAC==GENERICO .and. ED4->ED4_NCM=NCM_GENERICA) .or. !VerSaldoAC(1,ED0->ED0_TIPOAC) .or. ;
         ( ED4->ED4_CAMB<>VerCobertura(MCond_Pag,MDias_Pag)) /*AOM - 21/07/10 - Valida se a cond. de pagto esta COM/SEM cobertura, pois para efetuar a apropriação deve verificar se os
                                                                itens do ato Concessório esta de acordo com a cobertura na cond. pagto*/
            If Empty(ED0->ED0_DT_ENC)
               If !Empty(cMotivo)
                  EECView(cMotivo,STR0263) //STR0263 "Divergências - Não foi possível apropriar o Ato Concessório"
               Else

                  cMotivo := STR0255 + Chr(13)+Chr(10) // STR0255 "Divergência na apropriação"
                  cMotivo += STR0256 +ED4->ED4_AC+ STR0257 +ED4->ED4_SEQSIS+Chr(13)+Chr(10) //STR0256 "Ato Concessório " //STR0257 " sequência "

                  If Valtype(nQtdAux) == "N" .AND. ED4->ED4_QT_LI < nQtdAux
                     cMotivo += STR0258 + ED4->ED4_UMITEM+": "+TransForm(ED4->ED4_QT_LI,AvSX3("ED4_QT_LI",AV_PICTURE))+Chr(13)+Chr(10) //STR0258 "   Saldo em "
                     cMotivo += STR0259 +ED4->ED4_UMITEM+": "+TransForm(nQtdAux,AvSX3("ED4_QT_LI",AV_PICTURE))+Chr(13)+Chr(10) //STR0259 "   Quantidade do item a vincular em "
                  EndIf

                  If ED4->ED4_UMITEM <> ED4->ED4_UMNCM .AND. Valtype(nQtdNcmAux) == "N" .AND. ED4->ED4_SNCMLI < nQtdNcmAux
                     cMotivo += STR0258 + ED4->ED4_UMNCM+": "+TransForm(ED4->ED4_QT_LI,AvSX3("ED4_QT_LI",AV_PICTURE))+Chr(13)+Chr(10) //STR0258 "   Saldo em "
                     cMotivo += STR0259 +ED4->ED4_UMNCM+": "+TransForm(nQtdAux,AvSX3("ED4_QT_LI",AV_PICTURE))+Chr(13)+Chr(10)  //STR0259 "   Quantidade do item a vincular em "
                  EndIf

                  If ED4->ED4_CAMB <> VerCobertura(MCond_Pag,MDias_Pag)//AOM - 21/07/10
                     If ED4->ED4_CAMB == "1"
                        cMotivo += STR0260 + Alltrim(ED4->ED4_ITEM)+ STR0261 + Chr(13)+Chr(10) //STR0260 "   O item " //STR0261 " não pode ser apropriado, pois no Ato Concessório o mesmo possui Cobertura Cambial"
                        cMotivo += STR0262 + Chr(13)+Chr(10) //STR0262 " e a condição de pagamento utilizada está Sem cobertura Cambial. Para que o item possa ser apropriado as condições devem estar em comum."
                     ElseIf ED4->ED4_CAMB == "2"
                        cMotivo += STR0260 + Alltrim(ED4->ED4_ITEM)+ STR0261  + Chr(13)+Chr(10)//STR0260 "   O item " //STR0261 " não pode ser apropriado, pois no Ato Concessório o mesmo possui Cobertura Cambial"
                        cMotivo += STR0262  //STR0262 " e a condição de pagamento utilizada está Sem cobertura Cambial. Para que o item possa ser apropriado as condições devem estar em comum."
                     EndIf
                  EndIf

                  //AOM - 15/09/2011
                  If ED4->ED4_QT_LI<=0
                     cMotivo += STRTRAN(STR0302,"###",AllTrim(ED4->ED4_AC)) + AllTrim(Transform(ED4->ED4_QT_LI,AVSX3("ED4_QT_LI",6))) //"Saldo da LI insuficiente no Ato Concessório ### para o Item selecionado. Saldo atual no Ato Concessório de : "
                  EndIf

                  If ED0->ED0_IMPORT <> SW2->W2_IMPORT
                     cMotivo += STR0355 //LRS - 05/06/2014 - Mensagem erro divergência de importador ### "Importador do Purchase Order é diferente do importador do Ato Concessório"
                  EndIF

                  cMotivo += Chr(13)+Chr(10)

                  EECView(cMotivo, STR0263)//STR0263 "Divergências - Não foi possível apropriar o Ato Concessório"

                  //MsgInfo(STR0191+Alltrim(ED4->ED4_AC)+" "+STR0019+Alltrim(ED4->ED4_SEQSIS)+STR0158) //"O Ato Concessorio " # " seq. " # " nao serve para apropriação deste item. Tente selecionar um item correspondente através da tecla <F3>."
               EndIf
            Else
               MsgInfo(STR0172) //"Ato Concessorio Encerrado."
            EndIf
            lRet := .F.
         ElseIf !VerificaQTD(.F.,,,ED0->ED0_TIPOAC,cCod_I,.T.)
            //MsgInfo(STR0170) //"Não é possivel apropriar este item ao Ato Concessorio pois não existe conversão entre as Unidades de Medida. Cadastre uma conversao para as unidades de medida."
            lRet := .F.
         ElseIf cTipo<>"ALTERAR"
            TSaldo_Q   := Work->WKSALDO_Q
            nFobTotal  := TSaldo_Q * TFobUnit
         EndIf
         If lRet .and. ED4->ED4_DT_VAl < dDataBase
            MsgInfo(STR0177) //"Ato Concessorio escolhido esta com a Data de Validade expirada."
         EndIf
      ElseIf !ED4->( EoF() ) .Or. !ED4->( BoF() )  // PLB 24/04/06 - Alteracao de .And. para .Or.
         If cAC <> ED4->ED4_AC .or. cSeqSis <> ED4->ED4_SEQSIS
            ED4->(dbSeek(cFilED4+cAC+cSeqSis))
         EndIf
         If ED0->ED0_AC <> ED4->ED4_AC .or. ED0->ED0_FILIAL <> cFilED0
            ED0->(dbSeek(cFilED0+ED4->ED4_AC))
         EndIf
         If ED4->ED4_FILIAL<>cFilED4 .or. ED4->ED4_CNPJIM<>cCGC .or. !Empty(ED0->ED0_DT_ENC) .or.;
         (Work->WKTEC<>ED4->ED4_NCM .and. Left(ED4->ED4_NCM,8)<>NCM_GENERICA) .or.;
         (ED4->ED4_QT_LI <= 0 .and. (ED0->ED0_TIPOAC<>GENERICO .or. ED4->ED4_NCM<>NCM_GENERICA)) .or.;
         (ED4->ED4_VL_LI <= 0 .and. ED0->ED0_TIPOAC==GENERICO .and. ED4->ED4_NCM=NCM_GENERICA) .or. !VerSaldoAC(1,ED0->ED0_TIPOAC) .or. ;
         ( ED4->ED4_CAMB<>VerCobertura(MCond_Pag,MDias_Pag)) /*AOM - 21/07/10 - Valida se a cond. de pagto esta COM/SEM cobertura, pois para efetuar a apropriação deve verificar se os
                                                                itens do ato Concessório esta de acordo com a cobertura na cond. pagto*/

            If Empty(ED0->ED0_DT_ENC)
               If !Empty(cMotivo)
                  EECView(cMotivo,STR0263)  //STR0263 "Divergências - Não foi possível apropriar o Ato Concessório"
               Else
                  cMotivo := STR0255 +Chr(13)+Chr(10) //STR0255 "Divergência na apropriação"
                  cMotivo += STR0256 +ED4->ED4_AC+ STR0257 +ED4->ED4_SEQSIS+Chr(13)+Chr(10) //STR0256 "Ato Concessório " //STR0257 " sequência "

                  If Valtype(nQtdAux) == "N" .AND. ED4->ED4_QT_LI < nQtdAux
                     cMotivo += STR0258 + ED4->ED4_UMITEM+": "+TransForm(ED4->ED4_QT_LI,AvSX3("ED4_QT_LI",AV_PICTURE))+Chr(13)+Chr(10) //STR0258 "   Saldo em "
                     cMotivo += STR0259 + ED4->ED4_UMITEM+": "+TransForm(nQtdAux,AvSX3("ED4_QT_LI",AV_PICTURE))+Chr(13)+Chr(10) //STR0259 "   Quantidade do item a vincular em "
                  EndIf

                  If ED4->ED4_UMITEM <> ED4->ED4_UMNCM .AND. Valtype(nQtdNcmAux) == "N" .AND. ED4->ED4_SNCMLI < nQtdNcmAux
                     cMotivo += STR0258 + ED4->ED4_UMNCM+": "+TransForm(ED4->ED4_QT_LI,AvSX3("ED4_QT_LI",AV_PICTURE))+Chr(13)+Chr(10)//STR0258 "   Saldo em "
                     cMotivo += STR0259 + ED4->ED4_UMNCM+": "+TransForm(nQtdAux,AvSX3("ED4_QT_LI",AV_PICTURE))+Chr(13)+Chr(10)//STR0259 "   Quantidade do item a vincular em "
                  EndIf

                  If ED4->ED4_CAMB <> VerCobertura(MCond_Pag,MDias_Pag)//AOM - 21/07/10
                     If ED4->ED4_CAMB == "1"
                        cMotivo += STR0260 + Alltrim(ED4->ED4_ITEM)+ STR0261 + Chr(13)+Chr(10) // STR0260 "   O item "  //STR0261 " não pode ser apropriado, pois no Ato Concessório o mesmo possui Cobertura Cambial"
                         cMotivo += STR0262 + Chr(13)+Chr(10) //STR0262 " e a condição de pagamento utilizada está Sem cobertura Cambial. Para que o item possa ser apropriado as condições devem estar em comum."
                     ElseIf ED4->ED4_CAMB == "2"
                        cMotivo += STR0260 +Alltrim(ED4->ED4_ITEM)+ STR0261 + Chr(13)+Chr(10) // STR0260 "   O item "  //STR0261 " não pode ser apropriado, pois no Ato Concessório o mesmo possui Cobertura Cambial"
                        cMotivo += STR0262 + Chr(13)+Chr(10) //STR0262 " e a condição de pagamento utilizada está Sem cobertura Cambial. Para que o item possa ser apropriado as condições devem estar em comum."
                     EndIf
                  EndIf

                  //AOM - 15/09/2011
                  If ED4->ED4_QT_LI<=0
                     cMotivo += STRTRAN(STR0302,"###",AllTrim(ED4->ED4_AC)) + AllTrim(Transform(ED4->ED4_QT_LI,AVSX3("ED4_QT_LI",6))) //"Saldo da LI insuficiente no Ato Concessório ### para o Item selecionado. Saldo atual no Ato Concessório de : "
                  EndIf

                  cMotivo += Chr(13)+Chr(10)

                  EECView(cMotivo,STR0263) //STR0263 "Divergências - Não foi possível apropriar o Ato Concessório"

                  MsgInfo(STR0191+Alltrim(ED4->ED4_AC)+STR0019+Alltrim(ED4->ED4_SEQSIS)+STR0158) //"O Ato Concessorio " # " seq. " # " nao serve para apropriação deste item. Tente selecionar um item correspondente através da tecla <F3>."
               Endif
            Else
               MsgInfo(STR0172) //"Ato Concessorio Encerrado."
            EndIf
            lRet := .F.
         ElseIf !VerificaQTD(.F.,,,ED0->ED0_TIPOAC,cCod_I,.T.)
            //MsgInfo(STR0170) //"Nao e possivel apropria este item ao Ato Concessorio pois item nao possui nao existe conversao entre as Unidades de Medida. Cadastre uma conversao para as unidades de medida."
            lRet := .F.
         ElseIf cTipo<>"ALTERAR"
            TSaldo_Q := Work->WKSALDO_Q
            nFobTotal  := TSaldo_Q * TFobUnit
         EndIf
         If lRet .and. ED4->ED4_DT_VAl < dDataBase
            MsgInfo(STR0177) //"Ato Concessorio escolhido esta com a Data de Validade expirada."
         EndIf
      EndIf
   ElseIF cTipo<>"ALTERAR"
      TSaldo_Q := Work->WKSALDO_Q
      nFobTotal  := TSaldo_Q * TFobUnit
   EndIf
EndIf

If EasyEntryPoint("EICGI400")
   ExecBlock("EICGI400",.F.,.F.,"VALIDAC")
Endif

SA5->(dbSetOrder(1))
ED0->(dbSetOrder(1))

Return lRet

// GFP - 28/04/2014 - Ajuste para utilização da função GI400AltAC para desapropriação de todos os itens, visto que já possui tratamento de saldo.
*-----------------------------------*
Static Function GI400AltAC(lTodos)
*-----------------------------------*
Local nOpcao:=0, oDlgAC, oPanel
Local cMsgRet := ""
Default lTodos := .F.
Private cItem
Private cItens := ""  // Para ser utilizado nas consultas padrao "ED4" e "E29"

cFilED4:=xFilial("ED4")
cFilED0:=xFilial("ED0")
cFilSW8:=xFilial("SW8")
nQtdAux:=0
nQtdNcmAux:=0
cUnid:=""

If !lTodos
   cItem := Work->WKCOD_I
   cItens += cItem

   ED4->(dbSetOrder(2))
   cAC:=Work->WKAC
   cSeqSis:=Work->WKSEQSIS

   If !Empty(cAC)
      ED4->(dbSeek(cFilED4+Work->WKAC+Work->WKSEQSIS))
      If cItem != ED4->ED4_ITEM
         cItem := IG400BuscaItem("I",cItem,ED4->ED4_PD)  // PLB 14/11/06
         cItens += "///"+cItem
      Else
         cItens += "///"+IG400BuscaItem("I",cItem,ED4->ED4_PD)  // PLB 14/11/06
      EndIf
      //** AAF 03/05/05 - Verifica se o Item já foi Desembaraçado.
      aOrd   := SaveOrd({"SW8"})
      lAchou := .F.
      SW8->( dbSetOrder(5) )

      If SW8->( dbSeek(cFilSW8+Work->WKAC+Work->WKCOD_I) )
         Do While !SW8->( EoF() ) .AND. SW8->( W8_FILIAL + W8_AC + W8_COD_I ) == cFilSW8+Work->WKAC+Work->WKCOD_I
            If SW8->( W8_SEQSIS+W8_PGI_NUM+W8_PO_NUM+W8_POSICAO ) == Work->WKSEQSIS + M->W4_PGI_NUM + Work->WKPO_NUM + Work->WKPOSICAO
               lAchou:= .T.
               EXIT
            Endif

            SW8->( dbSkip() )
         EndDo
      Endif

      If lAchou
         MsgStop(STR0226)  // "Ato Concessório não pode ser alterado pois o item já está na fase de Desembaraço."
         Return .F.
      Endif

      RestOrd(aOrd)
      //**
   Else
      cItens += "///"+IG400BuscaItem("I",cItem)  // PLB 14/11/06
   EndIf

   //AAF 04/05/05 - Ajustes na tela de Alteração do Ato. Adicionado o Campo Seq. A.C.
   DEFINE MSDIALOG oDlgAC TITLE STR0279 ; //STR0279 "Novo ato concessorio"
          FROM 9,0 TO 20,75 OF oMainWnd

      oPanel:= TPanel():New(0, 0, "", oDlgAC,, .F., .F.,,, 0, 0)
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      @01,02 SAY AVSX3("ED0_AC",5) SIZE 50,8 Of oPanel
      @01,07 MSGET cAC F3 "ED4" PICTURE AVSX3("ED0_AC",6) SIZE 80,8 Of oPanel

      @02,02 SAY STR0195 SIZE 50,8 Of oPanel //"Seq. A.C. "
      @02,07 MSGET cSeqSis F3 "E26" PICTURE AVSX3("ED4_SEQSIS",6) when !Empty(cAC) SIZE 80,8 Of oPanel

   ACTIVATE MSDIALOG oDlgAC ON INIT EnchoiceBar(oDlgAC,{||nOpcao:=1,ED4->( dbSetOrder(2) ),(Empty(cAC) .OR. (ExistCpo("ED4",cAc+cSeqSis,2) .AND. ED4->( dbSeek(cFilED4+cAc+cSeqSis) ))) .AND. If(ValidaAC("ALTERAR",Work->WKCOD_I),oDlgAC:End(),nOpcao:=0)},{||nOpcao:=0,oDlgAC:End()}) CENTERED
Else
   If MsgYesNo(STR0353,STR0354) // "Deseja desapropriar o Ato Concessório de todos os itens da P.L.I.?"  ###  "Questão"
      cAC := ""
      nOpcao := 3
   Else
      Return .F.
   EndIf
EndIf

If nOpcao=1
   cMsgRet += GrvSldAto(cAC)
Else
   Work->(DbGoTop())
   Do While Work->(!Eof())

      If Empty(Work->WKAC)
         Work->(DbSkip())
         Loop
      EndIf

      lAchou := .F.
      ED4->(dbSetOrder(2))
      ED4->(dbSeek(cFilED4+Work->WKAC+Work->WKSEQSIS))
      SW8->( dbSetOrder(5) )
      If SW8->( dbSeek(cFilSW8+Work->WKAC+Work->WKCOD_I) )
         Do While !SW8->( EoF() ) .AND. SW8->( W8_FILIAL + W8_AC + W8_COD_I ) == cFilSW8+Work->WKAC+Work->WKCOD_I
            If SW8->( W8_SEQSIS+W8_PGI_NUM+W8_PO_NUM+W8_POSICAO ) == Work->WKSEQSIS + M->W4_PGI_NUM + Work->WKPO_NUM + Work->WKPOSICAO
               lAchou:= .T.
               EXIT
            Endif
            SW8->( dbSkip() )
         EndDo
      Endif

      If lAchou
         MsgStop(STR0226)  // "Ato Concessório não pode ser alterado pois o item já está na fase de Desembaraço."
         Return .F.
      Endif

      cMsgRet += GrvSldAto(cAC)
      Work->(DbSkip())
   EndDo
   Work->(DbGoTop())  // Posiciona no primeiro registro.
EndIf

If ! Empty(cMsgRet)
  lMsgAC := .T.
  If EasyEntryPoint("EICGI400")
    Execblock("EICGI400",.F.,.F.,"MSG_AC")
  EndIf
  If lMsgAC <> nil .and. lMsgAC
    MsgInfo(cMsgRet,"Ato Concessório")
  EndIf
EndIf

nOpcao := 0
oMark:oBrowse:Refresh()
ED4->(dbSetOrder(1))

Return .T.

*----------------------------------------------------------------*
Static Function VerificaQTD(lBotao,cAto,cPos,cTipoAC,cCod_I,lMens)
*----------------------------------------------------------------*
lMens := If(lMens=NIL,.F.,lMens)

If cTipoAC <> GENERICO .or. ED4->ED4_NCM <> NCM_GENERICA
   cUnid := BUSCA_UM(cCOD_I+Work->WKFABR+Work->WKFORN,Work->WKCC+WORK->WKSI_NUM)
EndIf

//** PLB 18/07/07
If ( cTipoAC == GENERICO  .And.  ED4->ED4_NCM == NCM_GENERICA )  .Or.  cUnid == ED4->ED4_UMITEM
   nQtdAux := Work->WKQTDE
ElseIf AvVldUn(ED4->ED4_UMITEM)
   nQtdAux := Work->WKPESO_L * Work->WKQTDE
Else
   nQtdAux := AVTransUnid(cUnid,ED4->ED4_UMITEM,cCod_I,Work->WKQTDE,If(cTipoAC<>GENERICO .or. ED4->ED4_NCM<>NCM_GENERICA,.T.,.F.))
EndIf

If ( cTipoAC == GENERICO  .And.  ED4->ED4_NCM == NCM_GENERICA )  .Or.  cUnid == ED4->ED4_UMNCM
   nQtdNcmAux := Work->WKQTDE
ElseIf AvVldUn(ED4->ED4_UMNCM)
   nQtdNcmAux := Work->WKPESO_L * Work->WKQTDE
ElseIf ED4->ED4_UMITEM == ED4->ED4_UMNCM
   nQtdNcmAux := nQtdAux
Else
   nQtdNcmAux := AVTransUnid(cUnid,ED4->ED4_UMNCM,cCod_I,Work->WKQTDE,If(cTipoAC<>GENERICO .or. ED4->ED4_NCM<>NCM_GENERICA,.T.,.F.))
   If Empty(nQtdNcmAux)  .And.  !Empty(nQtdAux)
      nQtdNcmAux := AVTransUnid(ED4->ED4_UMITEM,ED4->ED4_UMNCM,cCod_I,nQtdAux,If(cTipoAC<>GENERICO .or. ED4->ED4_NCM<>NCM_GENERICA,.T.,.F.))
   EndIf
EndIf
//**

//nQtdAux    := Round(nQtdAux , 5) LRL
//nQtdNcmAux := Round(nQtdNcmAux , 5) 28/10/04

If nQtdAux = NIL .or. nQtdNcmAux = NIL
   If lBotao
      If cAto4 == ED4->ED4_AC .and. cPos4 == ED4->ED4_SEQSIS
         nNivel4 += 1
      ElseIf !Empty(ED4->ED4_ITEM)
         nNivel1 += 1
      ElseIf Alltrim(ED4->ED4_NCM) <> "99999999"
         nNivel2 += 1
      Else
         nNivel3 += 1
      EndIf
   EndIf
   If lMens
      If nQtdAux = NIL
         MsgInfo(STR0170+Alltrim(cUnid)+STR0192+Alltrim(ED4->ED4_UMITEM)+").")   //"Não é possivel apropriar este item ao Ato Concessorio pois não existe conversão entre a U.M. do Pedido (" # ") e a U.M. do Item ("
      Else
         MsgInfo(STR0170+Alltrim(cUnid)+STR0193+Alltrim(ED4->ED4_UMNCM)+").") //"Não é possivel apropriar este item ao Ato Concessorio pois não existe conversão entre a U.M. do Pedido (" # ") e a U.M. de Compra ("
      EndIf
   EndIf
   Return .F.
EndIf

nQtdAux    := Round(nQtdAux , 5) //LRL
nQtdNcmAux := Round(nQtdNcmAux , 5)// 28/10/04
Return .T.

*----------------------------*
Static Function VerCobertura(cCond_Pag,nDias_Pag) //NCF - 30/03/11 - Alterada a função para receber dados da condição de pagamento
*----------------------------*                    //                  como parâmetro e não fixo.
Static cFilSY6:=xFilial("SY6")
Local cCobCamb
SY6->(dbSeek(cFilSY6+cCond_Pag+str(nDias_Pag,3,0)))
cCobCamb := If(SY6->Y6_TIPOCOB<>"4","1","2")
Return cCobCamb

*----------------------------------------*
Static Function MostraValor(nValor,lBotao)
*----------------------------------------*
Local oDlg, oBtnOK, oBtnNO, nAPos

nAPos := ASCAN(aApropria,{|X| X[1]==ED4->ED4_AC .and. X[2]=ED4->ED4_SEQSIS})

DEFINE MSDIALOG oDlg TITLE STR0164 ; //"Ato Concessorio Generico"
       FROM 15,03 To 30,47 OF oMainWnd

   @0.5,0.5 SAY STR0175 //"O melhor Ato Concessorio para este item e Generico e possui Saldo "
   @1,0.5  SAY STR0176 //"Valor menor que Valor do Item em Dolar. Ato nao pode ser apropriado."
   @2,3    SAY AVSX3(If(!Empty(ED4->ED4_ITEM),"ED4_ITEM","ED4_NCM"),5) SIZE 50,8
   @2,10.5 MSGET If(!Empty(ED4->ED4_ITEM),ED4->ED4_ITEM,ED4->ED4_NCM) PICTURE If(!Empty(ED4->ED4_ITEM),"@!",AVSX3("ED4_NCM",6)) WHEN .F. SIZE 60,7
   @3,3    SAY AVSX3("ED0_AC",5) SIZE 50,8
   @3,10.5 MSGET ED4->ED4_AC PICTURE "@!" WHEN .F. SIZE 60,7
   @4,3    SAY AVSX3("W5_PRECO",5) SIZE 50,8
   @4,10.5 MSGET nValor PICTURE AVSX3("ED4_VL_LI",6) WHEN .F. SIZE 60,7
   @5,3    SAY AVSX3("ED4_VL_LI",5) SIZE 50,8
   @5,10.5 MSGET If(nAPos<=0,ED4->ED4_VL_LI,ED4->ED4_VL_LI-aApropria[nAPos,4]) PICTURE AVSX3("ED4_VL_LI",6) WHEN .F. SIZE 60,7
   DEFINE SBUTTON FROM 85,70 TYPE 1 ACTION(oDlg:End()) ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

Work->WKFLAG:=.F.
Work->WKFLAGWIN:=SPACE(02)

If lBotao
   If !Empty(ED4->ED4_ITEM)
      nNivel1 += 1
   ElseIf Alltrim(ED4->ED4_NCM) <> "99999999"
      nNivel2 += 1
   Else
      nNivel3 += 1
   EndIf
EndIf

Return .T.

*----------------------------------------------*
Static Function VerSaldoAC(nTipo,cTipoAC,lValor)
*----------------------------------------------*
Local nAPos
If(lValor=NIL, lValor:=.F., )

If nTipo = 1
   If cTipoAC <> GENERICO .or. ED4->ED4_NCM <> NCM_GENERICA
      nAPos := ASCAN(aApropria,{|X| X[1]==ED4->ED4_AC .and. X[2]=ED4->ED4_SEQSIS})
      If nAPos > 0
         //If (ED4->ED4_QT_LI - aApropria[nAPos,3]) <= 0 .OR. (ED4->ED4_SNCMLI - aApropria[nAPos,5]) <= 0 //comentado por wfs 17/12/13
         If (ED4->ED4_QT_LI - aApropria[nAPos,3]) < 0 .OR. (ED4->ED4_SNCMLI - aApropria[nAPos,5]) < 0

            cMotivo := STR0255 +Chr(13)+Chr(10) //STR0255 "Divergência na apropriação"
            cMotivo += STR0256 +ED4->ED4_AC+ STR0257 +ED4->ED4_SEQSIS+Chr(13)+Chr(10) //STR0256 "Ato Concessório" //STR0257 " sequência "

            If ED4->ED4_QT_LI < aApropria[nAPos,3]
               cMotivo += STR0258 + ED4->ED4_UMITEM+": "+TransForm(ED4->ED4_QT_LI,AvSX3("ED4_QT_LI",AV_PICTURE))+Chr(13)+Chr(10) //STR0258 "   Saldo em "
               cMotivo += STR0259 + ED4->ED4_UMITEM+": "+TransForm(aApropria[nAPos,3],AvSX3("ED4_QT_LI",AV_PICTURE))+Chr(13)+Chr(10) //STR0259 "   Quantidade do item a vincular em "
            EndIf

            If ED4->ED4_UMITEM <> ED4->ED4_UMNCM .AND. ED4->ED4_SNCMLI < aApropria[nAPos,5]
               cMotivo += STR0258 + ED4->ED4_UMNCM+": "+TransForm(ED4->ED4_SNCMLI,AvSX3("ED4_SNCMLI",AV_PICTURE))+Chr(13)+Chr(10)//STR0258 "   Saldo em "
               cMotivo += STR0259 + ED4->ED4_UMNCM+": "+TransForm(aApropria[nAPos,5],AvSX3("ED4_SNCMLI",AV_PICTURE))+Chr(13)+Chr(10)//STR0259 "   Quantidade do item a vincular em "
            EndIf

            cMotivo += Chr(13)+Chr(10)

            Return .F.
         EndIf
      EndIf
   Else
      nAPos := ASCAN(aApropria,{|X| X[1]==ED4->ED4_AC .and. X[2]=ED4->ED4_SEQSIS})
      If nAPos > 0
         //If (ED4->ED4_VL_LI - aApropria[nAPos,4]) <= 0 //comentado por wfs em 17/12/13
         If (ED4->ED4_VL_LI - aApropria[nAPos,4]) < 0
            cMotivo := STR0255 + Chr(13)+Chr(10) //STR0255 "Divergência na apropriação"
            cMotivo += STR0256 + ED4->ED4_AC+ STR0257 +ED4->ED4_SEQSIS+Chr(13)+Chr(10) //STR0256 "Ato Concessório"  //STR0257 " sequência "

            If ED4->ED4_VL_LI < aApropria[nAPos,4]
               cMotivo += STR0280 + TransForm(ED4->ED4_VL_LI,AvSX3("ED4_VL_LI",AV_PICTURE))+Chr(13)+Chr(10) //STR0280 "   Saldo em US$:"
               cMotivo += STR0281+TransForm(aApropria[nAPos,4],AvSX3("ED4_VL_LI",AV_PICTURE))+Chr(13)+Chr(10) //str0281 "   Valor total a vincular em US$: "            EndIf
            EndIf

            cMotivo += Chr(13)+Chr(10)

            Return .F.
         EndIf
      EndIf
   EndIf
Else
   If !lValor .and. (cTipoAC <> GENERICO .or. ED4->ED4_NCM <> NCM_GENERICA)
      nAPos := ASCAN(aApropria,{|X| X[1]==ED4->ED4_AC .and. X[2]=ED4->ED4_SEQSIS})
      If nAPos > 0
         If (ED4->ED4_QT_LI - (aApropria[nAPos,3]+nQtdAux)) < 0  .OR. (ED4->ED4_SNCMLI - (aApropria[nAPos,5]+nQtdNCMAux)) < 0
            cMotivo := STR0255 + Chr(13)+Chr(10) //STR0255 "Divergência na apropriação"
            cMotivo += STR0256 + ED4->ED4_AC + STR0257 + ED4->ED4_SEQSIS+Chr(13)+Chr(10) //STR0256 "Ato Concessório" //STR0257 " sequência "
            If ED4->ED4_QT_LI < (aApropria[nAPos,3]+nQtdAux)
               cMotivo += STR0258 + ED4->ED4_UMITEM+": "+TransForm(ED4->ED4_QT_LI,AvSX3("ED4_QT_LI",AV_PICTURE))+Chr(13)+Chr(10) //STR0258 "   Saldo em "
               cMotivo += STR0259 + ED4->ED4_UMITEM+": "+TransForm((aApropria[nAPos,3]+nQtdAux),AvSX3("ED4_QT_LI",AV_PICTURE))+Chr(13)+Chr(10) //STR0259 "   Quantidade do item a vincular em "
            EndIf

            If ED4->ED4_UMITEM <> ED4->ED4_UMNCM .AND. ED4->ED4_SNCMLI < (aApropria[nAPos,5]+nQtdNCMAux)
               cMotivo += STR0258 + ED4->ED4_UMNCM+": "+TransForm(ED4->ED4_SNCMLI,AvSX3("ED4_SNCMLI",AV_PICTURE))+Chr(13)+Chr(10) //STR0258 "   Saldo em "
               cMotivo += STR0259 + ED4->ED4_UMNCM+": "+TransForm((aApropria[nAPos,5]+nQtdNCMAux),AvSX3("ED4_SNCMLI",AV_PICTURE))+Chr(13)+Chr(10) //STR0259 "   Quantidade do item a vincular em "
            EndIf

            cMotivo += Chr(13)+Chr(10)

            Return .F.
         EndIf
      EndIf
   Else
      nAPos := ASCAN(aApropria,{|X| X[1]==ED4->ED4_AC .and. X[2]=ED4->ED4_SEQSIS})
      If nAPos > 0
         If (ED4->ED4_VL_LI - (aApropria[nAPos,4]+GI400ApVal())) < 0 /*ConvVal(If(!Empty(MMoeda),MMoeda,SW4->W4_MOEDA),Work->WKQTDE * Work->WKPRECO)*/

            cMotivo := STR0255 + Chr(13)+Chr(10) //STR0255 "Divergência na apropriação"
            cMotivo += STR0256 +ED4->ED4_AC+ STR0257 +ED4->ED4_SEQSIS+Chr(13)+Chr(10)//STR0256 "Ato Concessório " //STR0257 " sequência "

            If ED4->ED4_VL_LI < aApropria[nAPos,4]+GI400ApVal()
               cMotivo += STR0280 + TransForm(ED4->ED4_VL_LI,AvSX3("ED4_VL_LI",AV_PICTURE))+Chr(13)+Chr(10) //STR0280 "   Saldo em US$:"
               cMotivo += STR0281 + TransForm(aApropria[nAPos,4]+GI400ApVal(),AvSX3("ED4_VL_LI",AV_PICTURE))+Chr(13)+Chr(10) //str0281 "   Valor total a vincular em US$: "
            EndIf

            cMotivo += Chr(13)+Chr(10)

            Return .F.
         EndIf
      EndIf
   EndIf
EndIf

Return .T.

*--------------------------*
Static Function DelSaldoAC()
*--------------------------*
nAPos := ASCAN(aApropria,{|X| X[1]==Work->WKAC .and. X[2]=Work->WKSEQSIS})
If nAPos > 0
   If ED0->ED0_AC <> aApropria[nAPos,1] .or. ED0->ED0_FILIAL <> cFilED0
      ED0->(dbSeek(cFilED0+aApropria[nAPos,1]))
   EndIf
   If ED0->ED0_TIPOAC <> GENERICO .or. ED4->ED4_NCM <> NCM_GENERICA
      aApropria[nAPos,3] -= Work->WKQT_AC
      aApropria[nAPos,4] -= Work->WKVL_AC
      If aApropria[nAPos,3] <= 0
         ADEL(aApropria,nAPos)
         ASIZE(aApropria,LEN(aApropria)-1)
      EndIf
   Else
      aApropria[nAPos,4] -= Work->WKVL_AC
      If aApropria[nAPos,4] <= 0
         ADEL(aApropria,nAPos)
         ASIZE(aApropria,LEN(aApropria)-1)
      EndIf
   EndIf
EndIf

If (nPosaPos:=aScan(aPosica,Work->WKPOSICAO)) > 0
   nPos:=aScan(aAntDraw,{|x| x[2]==Work->WKCOD_I})
   If nPos == 0
      nPos := aScan(aAntDraw,{|x| x[2]==IG400BuscaItem("I",Work->WKCOD_I,,Work->WKAC)})  // PLB 17/11/06
   EndIf
   If nPos > 0
      aAntDraw[nPos,3] += Work->WKQT_AC
      ADEL(aPosica,nPosaPos)
      ASIZE(aPosica,LEN(aPosica)-1)
   EndIf
EndIf

Return .T.

*-------------------------------------------------------*
Static Function MelhorAC(dDtVal1,nSalLI1,dDtVal2,nSalLI2)
*-------------------------------------------------------*
Local lRet:=.F.
If dDtVal1 < dDtVal2 .or. (dDtVal1 = dDtVal2 .and. (nSalLI2 = 0 .or. nSalLI1 < nSalLI2))
   lRet := .T.
Else
   lRet := .F.
EndIf

Return lRet

*--------------------------------------------*
Function BuscaItemGen(cItemPara)
*--------------------------------------------*
 Local cItemDe

   If ED7->( FieldPos("ED7_TPITEM") ) > 0  .And.  ED7->( FieldPos("ED7_PD") ) > 0

      cItemDe := IG400BuscaItem(,cItemPara)

   Else

      If ED7->(dbSeek(xFilial("ED7")+cItemPara))
         cItemDe := ED7->ED7_DE
      Else
         cItemDe := cItemPara
      EndIf
   EndIF

Return cItemDe

*----------------------------------------------------------------------------------------------*
Function GI400ApVal(lConverte)// FSY - 14/06/2013 - Parametro lógico adicionado para converter o valor pela moeda.
*----------------------------------------------------------------------------------------------*
Local nValor, nRecAux:=Work->(RecNo()), nPesoTot:=0, nValAux:=0, nValorTot:=0
Default lConverte:= .T.

nValAux := Work->WKQTDE * Work->WKPRECO

//** AAF 16/07/08 - Adicionar Inland e Packing ao valor EXW para chegar ao valor FOB.
If ALLTRIM(M->W4_INCOTER) $ "EXW"
   Work->(dbGoTop())
   Do While !Work->(EOF())
      nValorTot += Work->WKQTDE * Work->WKPRECO
      Work->(dbSkip())
   EndDo
   Work->(dbGoTo(nRecAux))
   nValAux += ((M->W4_INLAND+M->W4_PACKING + M->W4_OUT_DES) - M->W4_DESCONT)*nValAux/nValorTot //SVG - 15/10/2009 -
EndIf
//**

IF lW4_Fre_Inc  .And.  (M->W4_FREINC $ cSim) .AND. AvRetInco(ALLTRIM(M->W4_INCOTER),"CONTEM_FRETE")/*FDR - 28/12/10*/  //ALLTRIM(M->W4_INCOTER) $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP"
   Work->(dbGoTop())
   Do While !Work->(EOF())
      nPesoTot += Work->WKPESO_L * Work->WKQTDE
      Work->(dbSkip())
   EndDo
   Work->(dbGoTo(nRecAux))
   nValAux := nValAux - (M->W4_FRETEIN*((Work->WKPESO_L * Work->WKQTDE)/nPesoTot))
EndIf

// EOB - 14/07/08 - Inclusão do tratamento de incoterm com seguro
IF lSegInc  .And.  (M->W4_SEGINC $ cSim) .AND. AvRetInco(ALLTRIM(M->W4_INCOTER),"CONTEM_SEG")/*FDR - 28/12/10*/  //ALLTRIM(M->W4_INCOTER) $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP"
   Work->(dbGoTop())
   Do While !Work->(EOF())
      nValorTot += Work->WKQTDE * Work->WKPRECO
      Work->(dbSkip())
   EndDo
   Work->(dbGoTo(nRecAux))
   nValAux := nValAux - (M->W4_SEGURO*(nValAux/nValorTot))
EndIf

If lConverte // FSY - 14/06/2013 - Parametro lógico adicionado para converter o valor pela moeda.
	nValor := ConvVal(If(!Empty(MMoeda),MMoeda,SW4->W4_MOEDA),nValAux, ,,.T.)
Else
	nValor := nValAux
EndIf

Return nValor

// EOS - OS 553/02 - Funcao para selecao da PO de referencia
*----------------------------------------------------------------------------
FUNCTION GI400PORef()
*----------------------------------------------------------------------------
LOCAL nOpSelPO, cTit:=OemToAnsi(STR0042) //'N§ P.O.   '
LOCAL oDlgSelPO, lValidPO := .F.
Local oPanel

//cMarca := GetMArk()

IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"PO_REF"),)  // RS 01/11/05 - DEICMAR
WHILE .T.
   WORK->(DBSETORDER(2))
   nOpSelPO:=0
   DEFINE MSDIALOG oDlgSelPO TITLE STR0043 From 9,0 To 20,75 OF GetWndDefault() //"Seleção de P.O."  // GFP - 04/03/2015

      oPanel:= TPanel():New(0, 0, "", oDlgSelPO,, .F., .F.,,, 0, 0)
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      @ 2.8,2.8 SAY cTit SIZE 40,8  Of oPanel// GFP - 04/03/2015
      @ 2.8,7   MSGET TPO_Num F3 "SW2" PICTURE _PictPO VALID GI400PO(TPo_Num) Of oPanel SIZE 80,10  // GFP - 04/03/2015

   ACTIVATE MSDIALOG oDlgSelPO ON INIT EnchoiceBar(oDlgSelPO,;
                     {||nOpSelPO:=1, GI400Vars() .AND. IF(lValidPo:=GI_ValidPO(),oDlgSelPO:End(),)},;
                     {||nOpSelPO:=0, oDlgSelPO:End()}) CENTERED

   If nOpSelPO = 0
      lSelPO :=.T.
      DBSELECTAREA("SW2")
      MsUnlock()
      EXIT
   ElSEIF nOpSelPO = 1 .AND. lValidPO .AND. !EMPTY(TPO_Num)
      lSelPO  :=.F.
      lRefresh:=.T.
      EXIT
   ENDIF
ENDDO
RETURN NIL

*--------------------
FUNCTION GI400Vars()
*--------------------
mTabPO    := {}
MDesconto := MInland := MPacking := MFreteIntl := MSeguro := 0
TImport   := TConsig := SPACE(02)
MIncoterm := MMoeda  := SPACE(03)
cExporta  := SPACE(06)
MForn     := SPACE(LEN(SW2->W2_FORN))
MDias_Pag := 0
MCond_Pag := SPACE(05)
MDesc_Pag := SPACE(50)

If EICLoja()
   cExportLoj:= SPACE(LEN(SW2->W2_EXPLOJ))
   MFornLoja := SPACE(LEN(SW2->W2_FORLOJ))
EndIf

IF Work->(LASTKEY()) > 0
   Work->(avzap())
ENDIF
RETURN .T.
// EOS - OS 553/02 - Funcao para selecao da PO de referencia
*----------------------------------------------------------------------------------------------*
Static Function GI400ValAnt(cPed,cItem,cSeq)
*----------------------------------------------------------------------------------------------*
Local nPos, nPosED3, nTotED3:=0, nSalED3:=0, cProd, nPosaPos
Local cAviso := ""

cFilED2:=xFilial("ED2")
cFilED3:=xFilial("ED3")

If ED0->ED0_MODAL <> "1"
  Return "" //.T.
EndIf

ED3->(dbSetOrder(8))
ED2->(dbSetOrder(1))

ED2->(dbSeek(cFilED2+cPed+cItem))
Do While !ED2->(EOF()) .and. ED2->ED2_FILIAL==cFilED2 .and. ED2->ED2_PD==cPed .and.;
ED2->ED2_ITEM==cItem
   If !Empty(ED2->ED2_PROD) .and. !Empty(ED2->ED2_SEQ)

      //AAF 13/07/05 - Utilizar quantidade calculada para baixa do saldo.
      nQtdCal := Round(ED2->ED2_QTD * ((100 - Max(ED2->(ED2_PERCPE - ED2_PERCAP),0)) / 100 ),AvSx3("ED2_QTD",4))

      If (nPosED3:=aScan(aArrayED3,{|x| x[1]==ED2->ED2_PROD})) = 0
         ED3->(dbSeek(cFilED3+cPed+ED2->ED2_PROD))
         nTotED3 := 0
         nSalED3 := 0
         Do While !ED3->(EOF()) .and. ED3->ED3_FILIAL==cFilED3 .and. ED3->ED3_PD==cPed .and.;
         ED3->ED3_PROD==ED2->ED2_PROD
            cProd   := ED3->ED3_PROD
            nTotED3 += ED3->ED3_QTD
            nSalED3 += ED3->ED3_SALDO
            ED3->(dbSkip())
         EndDo
         aAdd(aArrayED3,{cProd,nTotED3,nSalED3})
         If (nPos:=aScan(aAntDraw,{|x| x[2]==ED2->ED2_ITEM})) = 0
            //AAF 13/07/05 - Quantidade para o controle de saldo é a quantidade calculada.
            //aAdd(aAntDraw,{cProd,ED2->ED2_ITEM,(ED2->ED2_QTD/aArrayED3[Len(aArrayED3),2]) * aArrayED3[Len(aArrayED3),3],.T.})
            aAdd(aAntDraw,{cProd,ED2->ED2_ITEM,(nQtdCal/aArrayED3[Len(aArrayED3),2]) * aArrayED3[Len(aArrayED3),3],.T.})
         ElseIf aAntDraw[nPos,4]
            //aAntDraw[nPos,3] += (ED2->ED2_QTD/aArrayED3[Len(aArrayED3),2]) * aArrayED3[Len(aArrayED3),3]
            aAntDraw[nPos,3] += (nQtdCal/aArrayED3[Len(aArrayED3),2]) * aArrayED3[Len(aArrayED3),3]
         EndIf
      Else
         If (nPos:=aScan(aAntDraw,{|x| x[2]==ED2->ED2_ITEM})) = 0
            //AAF 13/07/05 - Quantidade para o controle de saldo é a quantidade calculada.
            //aAdd(aAntDraw,{aArrayED3[nPosED3,1],ED2->ED2_ITEM,(ED2->ED2_QTD/aArrayED3[nPosED3,2]) * aArrayED3[nPosED3,3],.T.})
            aAdd(aAntDraw,{aArrayED3[nPosED3,1],ED2->ED2_ITEM,(nQtdCal/aArrayED3[nPosED3,2]) * aArrayED3[nPosED3,3],.T.})
         ElseIf aAntDraw[nPos,4]
            //AAF 13/07/05 - Quantidade para o controle de saldo é a quantidade calculada.
            //aAntDraw[nPos,3] += (ED2->ED2_QTD/aArrayED3[nPosED3,2]) * aArrayED3[nPosED3,3]
            aAntDraw[nPos,3] += (nQtdCal/aArrayED3[nPosED3,2]) * aArrayED3[nPosED3,3]
         EndIf
      EndIf
   Endif
   ED2->(dbSkip())
EndDo

nPos:=aScan(aAntDraw,{|x| x[2]==cItem})
If nPos > 0
   aAntDraw[nPos,4] := .F.
   If aAntDraw[nPos,3] >= nQtdAux
      If (nPosaPos:=aScan(aPosica,Work->WKPOSICAO)) = 0
         aAntDraw[nPos,3] -= nQtdAux
         aAdd(aPosica,Work->WKPOSICAO)
      EndIf
      Return ""
   Else
    //MsgInfo(STR0187+" "+Alltrim(ED0->ED0_AC)) //"Item não não possui produto de exportação que atenda a esta demanda em sua estrutura, de acordo com a anterioridade, no AC"
    cAviso := "PO: "+Alltrim(cPed)+" Item: "+Alltrim(cItem)+" Seq: "+Alltrim(cSeq)+" não possui produto de exportação que atenda a esta demanda de acordo com a anterioridade, no AC: " +Alltrim(ED0->ED0_AC) + CRLF // MPG
    //Return .F.  //** GFC - 10/08/06
   EndIf
ElseIf !Empty(cItem) //AAF - 07/02/06 - Verificação para Drawback Genérico.
  // MsgInfo(STR0187+" "+Alltrim(ED0->ED0_AC)) //"Item não não possui produto de exportação que atenda a esta demanda em sua estrutura, de acordo com a anterioridade, no AC"
  cAviso := "PO: "+Alltrim(cPed)+" Item: "+Alltrim(cItem)+" Seq: "+Alltrim(cSeq)+" não possui produto de exportação que atenda a esta demanda de acordo com a anterioridade, no AC: " +Alltrim(ED0->ED0_AC) + CRLF // MPG
  //Return .F.  //** GFC - 10/08/06
EndIf

Return cAviso

*-----------------------------------------------------------*
FUNCTION GI400LSI_MAIN(cAlias,nReg,nOpc)   // JBS 11/11/2003
*-----------------------------------------------------------*
Local oDlgLSI, i
Local nOpca        := 0
Local bOk_Main     := {|| If(Obrigatorio(aGets,aTela), EVAL(bLSI), ) } //{|| nOpca:=1,oDlgLSI:End()}
Local bCancel_Main := {|| nOpca:=0,oDlgLSI:End()}
Local lNoFolder    := .T.    // Não mostrar folder na Enchoice
LOCAL bLSI:= {|| GI_Create(), IF(lGravouTudo:=.T.,(nOpca:=0,oDlgLSI:End()),) }
Local oEnchoice //LRL 23/03/04
Private aBotoesLSI:= {}
Private aCpos := {"W4_PGI_NUM","W4_PGI_DT","W4_NAT_LSI"} // Campos a serem mostrados na Enchoice
Private aTELA[0][0]
Private aGETS[0]
Private aHeader[0] //, aCampos:= {}
PRIVATE nBasePLI:=2
Private lAUTPCDI := DI500AUTPCDI()	//JWJ 31/08/2006
Private lSelec_Base := .F.

//AOM - 23/08/2011 - Operacao Especial
If lOperacaoEsp
   Private oOperacao := EASYOPESP():New() //AOM - 09/04/2011 - Inicializando a classe para tratamento de operações especiais
EndIf

lGravouTudo:=.F.

AADD(aBotoesLSI,{STR0203  ,{|| If(Obrigatorio(aGets,aTela), EVAL(bLSI), ) },STR0282,STR0203})//"Proximo"  //STR0282 "Próxima Tela"

cAlias := "SW4"
nQual  := nOPC
cRotinaOPC := "LSI"

dbSelectArea(cAlias)

For i := 1 to FCount()
    M->&(FieldName(i)) := If(nOpc==LSI,CriaVar(FieldName(i)),fieldGet(i))
Next

M->W4_PGI_DT  := IF(nOpc==LSI,dDataBase,SW4->W4_PGI_DT)
M->W4_VM_DESG := space(65)
M->W4_VM_COPA := space(65)

GI_Init(@bCloseAll)

If nOpc <> LSI //6
   GI_CREATE()
   nOpca := 2
EndIf

Do While nOpc == LSI //6

   nOpca  := 0
   aTELA  := {}
   aGETS  := {}
   aHeader:= {}
   oMainWnd:ReadClientCoors()

   DEFINE ;
   MSDIALOG oDlgLSI;
   TITLE OemToAnsi("LSI") ;  //"Manutecao de LSI"
   FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   OF oMainWnd PIXEL

   oEnChoice:=MsMGet():New(cAlias, nReg, nOpc,,,,aCpos, {  15,  1,(oDlgLSI:nClientHeight-6)/2,(oDlgLSI:nClientWidth-4)/2 },,3,,,,,,,,,lNoFolder)
   oEnChoice:oBox:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   ACTIVATE MSDIALOG oDlgLSI ON INIT (enchoicebar(oDlgLSI,bOk_Main,bCancel_Main,,aBotoesLSI)) //LRL 23/03/04 - Alinhamento MDI //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   Exit

EndDo
//--------------------------------------------------------------------------------
// JBS - 12/12/2003  Apagar Works apenas na Inclusao de LSI e Nunca na Alteração
// A Função Original o Fará no final do Processamento...
//--------------------------------------------------------------------------------
If nOpc == LSI   // JBS 12/12/2003
   GI_Final(bCloseAll)
EndIf
cRotinaOPC := "LI"
RETURN(nOpca<>0)

*-----------------------------------------------------------*
FUNCTION GI400LSI(nOpc)        // JBS 12/11/2003
*-----------------------------------------------------------*
Local oDlgLSI0
Local nOpca       := 0
Local bOk_LSI     := {|| nOpca:= 0,oDlgLSI0:End()}
Local bCancel_LSI := {|| nOpca:= 0,oDlgLSI0:End()}
Local aTelaBkp    := aClone(aTela)
Local aGetsBKP    := aClone(aGets)
Local aHeaderB    := aClone(aHeader)
Local nRecWork    := Work->(Recno())

Private aBotoesLSI:= {}
Private aCamposSWP:= {}
Private aTab_Nat  := {}, cFiltroSJV := "" // JBS - 26/11/2003

aTELA  := {}
aGETS  := {}
aHeader:= {}

cAlias := "SWP"
nQual  := nOPC
nReg   := (cAlias)->(recno())

dbSelectArea(cAlias)

aCamposSWP := {}
AADD(aCamposSWP,{"WP_SEQ_LI",,"LSI",AVSX3("WP_NAT_LSI",6)})
AADD(aCamposSWP,{"WP_NAT_LSI",,AVSX3("WP_NAT_LSI",5) ,AVSX3("WP_NAT_LSI",6)})
AADD(aCamposSWP,{"WP_URF_DES",,AVSX3("WP_URF_DES",5) ,AVSX3("WP_URF_DES",6)})
AADD(aCamposSWP,{"WP_MERCOS" ,,AVSX3("WP_MERCOS" ,5) ,AVSX3("WP_MERCOS" ,6)})
AADD(aCamposSWP,{"WP_PAIS_PR",,AVSX3("WP_PAIS_PR",5) ,AVSX3("WP_PAIS_PR" ,6)})

AADD(aCamposSWP,{"WP_REG_TRI",,AVSX3("WP_REG_TRI",5) ,AVSX3("WP_REG_TRI",6)})
AADD(aCamposSWP,{"WP_FUN_REG",,AVSX3("WP_FUN_REG",5) ,AVSX3("WP_FUN_REG",6)})
AADD(aCamposSWP,{"WP_MOTIVO" ,,AVSX3("WP_MOTIVO" ,5) ,AVSX3("WP_MOTIVO" ,6)})
AADD(aCamposSWP,{"WP_TEC_CL" ,,AVSX3("WP_TEC_CL" ,5) ,AVSX3("WP_TEC_CL" ,6)})
AADD(aCamposSWP,{"WP_MATUSA" ,,AVSX3("WP_MATUSA" ,5) ,AVSX3("WP_MATUSA" ,6)})
AADD(aCamposSWP,{"WP_ESP_VM" ,,AVSX3("WP_ESP_VM" ,5) ,AVSX3("WP_ESP_VM" ,6)})
AADD(aCamposSWP,{"WP_INF_VM" ,,AVSX3("WP_INF_VM" ,5) ,AVSX3("WP_INF_VM" ,6)})

If !lVisual
   If nQual == LSI // Incluir LSI
      AADD(aBotoesLSI,{"BMPINCLUIR",{|| GI400LSIManut(1,nOPC),oMarkSWP:oBrowse:Refresh()},STR0007,STR0007 })//"Incluir" //MCF-04/05/2015
      AADD(aBotoesLSI,{"EDIT"      ,{|| GI400LSIManut(2,nOPC),oMarkSWP:oBrowse:Refresh()},STR0008,STR0008 })//"Alterar"
      AADD(aBotoesLSI,{"EXCLUIR"   ,{|| GI400LSIManut(3,nOPC),oMarkSWP:oBrowse:Refresh()},STR0283,STR0283 }) //STR0283 "Excluir"
   Else // Alterar LSI
      AADD(aBotoesLSI,{"EDIT"      ,{|| GI400LSIManut(2,nOPC),oMarkSWP:oBrowse:Refresh()},STR0008,STR0008 })//"Alterar" -Anterior
   EndIf
Else
   AADD(aBotoesLSI,{"PESQUISA"  ,{|| GI400LSIManut(4,nOPC),oMarkSWP:oBrowse:Refresh()},STR0006,STR0204}) //STR0006 "Visualizar"
EndIf
AADD(aBotoesLSI,{"PREV"      ,{|| nOpca:= 0,oDlgLSI0:End()},STR0284 ,STR0205})//"Tela Anterior" - Anterior //STR0284 "Tela Anterior"

Do While .T.
   aTELA:={}
   aGETS:={}
   aHeader:={}
   nOpca  := 0

   oMainWnd:ReadClientCoors()
   DEFINE;
   MSDIALOG oDlgLSI0;
   TITLE STR0310; //"Manutenção de LSI" ;
   FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   OF oMainWnd PIXEL

   Work_SWP->(dbGotop())

   //by GFP - 14/10/2010 - 11:53
   aCamposSWP := AddCpoUser(aCamposSWP,"SWP","2")

   oMarkSWP:=MsSelect():New("Work_SWP","WKFLAGWIN",,aCamposSWP,@lInverte,@cMarca,{15,1,(oDlgLSI0:nClientHeight-6)/2,(oDlgLSI0:nClientWidth-4)/2})
   IF !lVisual
      oMarkSWP:bAval:={|| GI400LSIManut(2,nOPC),oMarkSWP:oBrowse:Refresh()}
   ELSE
      oMarkSWP:bAval:={|| GI400LSIManut(4,nOPC),oMarkSWP:oBrowse:Refresh()}
   ENDIF

   oMarkSWP:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
   oMarkSWP:oBrowse:Refresh() //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   ACTIVATE MSDIALOG oDlgLSI0 ON INIT (enchoicebar(oDlgLSI0,bOk_LSI,bCancel_LSI,,aBotoesLSI)) //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   Exit

EndDo
Work->(dbGoto(nRecWork))
RETURN(nOpca<>0)
*-----------------------------------------------------------*
FUNCTION GI400LSIManut(nTipo,nOPC)        // JBS 12/11/2003
*-----------------------------------------------------------*
Local nOpca      := 0,oDlgManut, nInd, i
Local bOk_Man    := {|| IF(Eval(bValid),(nOpca:=1,oDlgManut:End()),)}
Local bValid     := {|| Obrigatorio(aGets,aTela).AND.E_Valid(aGets,{|campo| GI400LSIVALID(campo,.T.)})}
Local bCancel_Man:= {|| nOpca:=0,oDlgManut:End()}
Local aTelaBkp   :=aClone(aTela)
Local aGetsBKP   :=aClone(aGets)
Local aHeaderB   :=aClone(aHeader)
Local aCamposBKP :=aClone(aCampos)
Local lTemItemParaLSI:= .F.
Local lItemMarcado   := .F.
Local cTitulo    := ""
Local lNoFolder  := .T.
Local lRetorno   := .F.
Local nRecWork   := Work->(recno())

Private aCamposSWP:={},aDarGets:={},aMostrar:={}
Private nPos_aRotina:=nOpc,cEspecif
Private cFiltroSJP:=""
Private cFiltroSY8:=""
Private cFiltroSJR:=""
Private cClassif  :=""
Private AcamposLSI := aClone(aCampos)
Private nRecMarcado:= 0
Private nTipoOpera := nTipo
Private oEncItens //LRL 23/03/04
If Work_SWP->(Bof().and.Eof())
   If nTipo <> INCLUI_LSI
      HELP("",1,"AVG0000671")// MSGSTOP("Nao Existe LSI! Disponivel apenas a Opcao de Incluir!")
      Return(.f.)
   EndIf
Endif

Do Case
   Case nTipo == INCLUI_LSI // Inclusao de Itens da LSI
        cTituto:=STR0007    //"Inclusao"

        dbselectarea("Work_SWP")
        dbGotop()

        If EOF() .AND. BOF()
           dbselectarea("SWP")
           For nInd := 1 to FCount()
               M->&(FieldName(nInd)) := CriaVar(FieldName(nInd))
           Next
        Else
           For nInd := 1 to FCount()
               M->&(FieldName(nInd)) := FieldGet(nInd)
           Next
        EndIf
        M->WP_PROCANU:="Tecle F3"
        M->WP_NAT_LSI:=M->W4_NAT_LSI

        GI400Simples()

        cFiltroSY8:=""
        cFiltroSJR:=""
        cClassif  :=""

        DI500DSIRegra(M->WP_NAT_LSI,M->WP_REG_TRI,M->WP_FUN_REG,M->WP_MOTIVO,.T.)

        Work->(dbGoTop())

        Do While Work->(!EOF())
           If empty(Work->WKSEQ_LI).and.Work->WKFLAG
              lTemItemParaLSI:=.T.
           EndIf
           Work->(dbSkip())
        EndDo
        If !lTemItemParaLSI
           HELP("",1,"AVG0000672")// MSGSTOP("Nao existe item Disponivel para incluir um nova LSI.")
           return .F.
        EndIf

        aCamposLSI[1]:= {"WKFLAGLSI",,""}

        M->WP_SEQ_LI := GI400GerNrLSI()  // JBS 17/12/2003  - Gerando o Nro da LSI
        M->WP_LSI    := "1"
        M->WP_PGI_NUM:= M->W4_PGI_NUM

        //*** GFP - 19/08/2011 - Nopado e Alterado
        //Work->(DbSetFilter({|| Empty(Work->WKSEQ_LI).and.Work->WKFLAG}, "Empty(Work->WKSEQ_LI).and.Work->WKFLAG"))

        Work->(DBEVAL({|| If(Empty(Work->WKSEQ_LI).and.Work->WKFLAG, Work->WK_FILTRO := "S",Work->WK_FILTRO := "")}))
        Work->(dbSetFilter({|| Work->WK_FILTRO == "S" }, "Work->WK_FILTRO == 'S'"))
        //*** Fim GFP

        Work->(dbGoTop())

   Case nTipo == ALTERA_LSI // Alteração de Itens da LSI
        cTituto:=STR0008    //"Alterar"

        bCancel_Man    := NIL
        lTemItemParaLSI:= .F.

        dbselectarea("Work_SWP")

        For nInd := 1 to FCount()
            M->&(FieldName(nInd)) := FieldGet(nInd)
        Next
        if nQual == LSI
           aCamposLSI[1]:= {"WKFLAGLSI",,""}
        Else
           aDel(aCamposLSI,1)
           aSize(aCamposLSI,len(aCamposLSI)-1)
//           aCamposLSI[1]:= {"WKSEQ_LI",,"Seq LSI"}
        EndIf

        GI400Simples()

        cFiltroSY8:=""
        cFiltroSJR:=""
        cClassif  :=""

        DI500DSIRegra(M->WP_NAT_LSI,M->WP_REG_TRI,M->WP_FUN_REG,M->WP_MOTIVO,.T.)

        M->WP_ESP_VM := Work_SWP->WP_ESP_VM
        M->WP_INF_VM := Work_SWP->WP_INF_VM

        If !empty(M->WP_PAIS_PR)
           If SYA->(dbSeek(xfilial("SYA")+M->WP_PAIS_PR))
              M->WP_PRO_NOM := SYA->YA_DESCR
           Endif
        Endif

        Work->(dbGoTop())

        Do While Work->(!EOF())
           Work->WKSEQ_LSI := Work->WKSEQ_LI
           If Work->WKSEQ_LI  == M->WP_SEQ_LI
              Work->WKFLAGLSI := cMarca
              Work->WKSEQ_LI  := ""
              nRecMarcado := Work->(recno())
              If nQual == 4 .or. nQual == 2  // Alteração ou Visualização da LSI
                 work->WKFLAG := .T.
              EndIf
           EndIf
           If Empty(Work->WKSEQ_LI).and.Work->WKFLAG
              lTemItemParaLSI:=.T.
           EndIf

           Work->(dbSkip())
        EndDo

        If !lTemItemParaLSI
           HELP("",1,"AVG0000673")// MSGSTOP("LSI nao possui itens!")
           return .F.
        EndIf

        Work->(DbSetFilter({|| Empty(Work->WKSEQ_LI).and.Work->WKFLAG}, "(Empty(Work->WKSEQ_LI).or.Work->WKSEQ_LI = M->WP_SEQ_LI).and.Work->WKFLAG"))
        Work->(dbGoTop())

   Case nTipo == EXCLUI_LSI //Exclusao da LSI
        cTituto:= STR0283 //"Excluir" //STR0283 "Excluir"

        dbselectarea("Work_SWP")
        aDel(aCamposLSI,1)
        aSize(aCamposLSI,len(aCamposLSI)-1)
//      aCamposLSI[1]:= {"WKSEQ_LI",,"Seq LSI"}

        For nInd := 1 to FCount()
            M->&(FieldName(nInd)) := FieldGet(nInd)
        Next
        M->WP_PROCANU := "Tecle F3"
        M->WP_ESP_VM := Work_SWP->WP_ESP_VM
        M->WP_INF_VM := Work_SWP->WP_INF_VM

        GI400Simples()

        cFiltroSY8:=""
        cFiltroSJR:=""
        cClassif  :=""

        DI500DSIRegra(M->WP_NAT_LSI,M->WP_REG_TRI,M->WP_FUN_REG,M->WP_MOTIVO,.T.)


        Work->(DbSetFilter({|| Work->WKSEQ_LI = M->WP_SEQ_LI.and.Work->WKFLAG},"Work->WKSEQ_LI = M->WP_SEQ_LI.and.Work->WKFLAG"))
        Work->(dbGoTop())

   Case nTipo == VISUAL_LSI // Visualizar de Itens da LSI
        cTituto:=STR0286 // STR0286 "Visualização"

        dbSelectarea("Work_SWP")
        aCamposLSI[1]:= {"WKSEQ_LI",,"Seq LSI"}
        nOpc := 2  // Visualização
        For nInd := 1 to FCount()
            M->&(FieldName(nInd)) := FieldGet(nInd)
        Next

        GI400Simples()

        cFiltroSY8:=""
        cFiltroSJR:=""
        cClassif  :=""

        DI500DSIRegra(M->WP_NAT_LSI,M->WP_REG_TRI,M->WP_FUN_REG,M->WP_MOTIVO,.T.)

        SWP->(dbGoTo(Work_SWP->WKRECNO))

        M->WP_PROCANU := STR0285 //str0285 "Tecle F3"

        M->WP_ESP_VM := Work_SWP->WP_ESP_VM
        M->WP_INF_VM := Work_SWP->WP_INF_VM

        Work->(dbGoTop())

        Do While Work->(!EOF())
           If Work->WKSEQ_LI  == M->WP_SEQ_LI
              Work->WKFLAGLSI := cMarca
              If nQual == 4 .or. nQual == 2  // Alteração ou Visualização da LSI
                 work->WKFLAG := .T.
              EndIf
           EndIf
           Work->(dbSkip())
        EndDo

        Work->(DbSetFilter({|| Work->WKSEQ_LI = M->WP_SEQ_LI.and.Work->WKFLAG},"Work->WKSEQ_LI = M->WP_SEQ_LI.and.Work->WKFLAG"))
        Work->(dbGoTop())

EndCase

cAlias := "SWP"
nQual  := nOPC
nReg   := SWP->(RECNO()) //Work_SWP->WKRECNO //(cAlias)->(recno())

Aadd(aCamposLSI,{"",,,""})
aIns(aCamposLSI,2)
aCamposLSI[2] := {"WKTEC"      ,"",STR0085,"@R 9999.99.99"}

aCamposSWP := {}

AADD(aCamposSWP,{"WP_NAT_LSI",,AVSX3("WP_NAT_LSI",5) ,AVSX3("WP_NAT_LSI",6)})
AADD(aCamposSWP,{"WP_URF_DES",,AVSX3("WP_URF_DES",5) ,AVSX3("WP_URF_DES",6)})
AADD(aCamposSWP,{"WP_MERCOS" ,,AVSX3("WP_MERCOS" ,5) ,AVSX3("WP_MERCOS" ,6)})
AADD(aCamposSWP,{"WP_PAIS_PR",,AVSX3("WP_PAIS_PR",5) ,AVSX3("WP_PAIS_PR" ,6)})
AADD(aCamposSWP,{"WP_PRO_NOM",,AVSX3("WP_PAIS_PR",5) ,AVSX3("WP_PAIS_PR" ,6)})

AADD(aCamposSWP,{"WP_REG_TRI",,AVSX3("WP_REG_TRI",5) ,AVSX3("WP_REG_TRI",6)})
AADD(aCamposSWP,{"WP_FUN_REG",,AVSX3("WP_FUN_REG",5) ,AVSX3("WP_FUN_REG",6)})
AADD(aCamposSWP,{"WP_MOTIVO" ,,AVSX3("WP_MOTIVO" ,5) ,AVSX3("WP_MOTIVO" ,6)})
AADD(aCamposSWP,{"WP_TEC_CL" ,,AVSX3("WP_TEC_CL" ,5) ,AVSX3("WP_TEC_CL" ,6)})
AADD(aCamposSWP,{"WP_QT_EST" ,,AVSX3("WP_QT_EST" ,5) ,AVSX3("WP_QT_EST" ,6)})
AADD(aCamposSWP,{"WP_MATUSA" ,,AVSX3("WP_MATUSA" ,5) ,AVSX3("WP_MATUSA" ,6)})

aDarGets:={}     // Array de Campos a serem editaveis
aMostrar:={}     // Array de Campos a serem mostrados

for i := 1 to len(aCamposSWP)
    if (nTipo==INCLUI_LSI.or.(nTipo==ALTERA_LSI.and.aCamposSWP[i,1]<>"WP_SEQ_LI")) // Na inclusão ou na alteração
       aadd(aDarGets,aCamposSWP[i,1])                               // Relação de campos editaveis
    endif
    aadd(aMostrar,aCamposSWP[i,1])                                  // Campos a serem mostrados
next

aadd(aDarGets,"WP_ESP_VM")
aadd(aDarGets,"WP_INF_VM")
aadd(aDarGets,"WP_PROCANU")
aadd(aMostrar,"WP_ESP_VM")
aadd(aMostrar,"WP_INF_VM")
aadd(aMostrar,"WP_PROCANU")
IF nTipo == VISUAL_LSI // Visualizar de Itens da LSI
   aDarGetsl:={}
ENDIF
aBotoesLSI:={}
//AADD(aBotoesLSI,{"RESPONSA",{|| GI400LSIPesq(oMarkItens:oBrowse,nOPC,nTipo) },"Marca/Desmarca Todos"})
aTELAold:=ACLONE(aTELA)
aGETSold:=ACLONE(aGETS)

Do While .T.
   lNoFolder := .T.
   aTELA:={}
   aGETS:={}

   oMainWnd:ReadClientCoors()

   DEFINE ;
   MSDIALOG oDlgManut ;
   TITLE OemToAnsi(cTitulo) ;      //"Manutecao de LSI"
   FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   OF oMainWnd PIXEL

   nMeio:=INT( ((oMainWnd:nBottom-60)-(oMainWnd:nTop+125) ) / 4 )
   dbSelectArea("SWP")
   oEnCItens:=MsMget():New("SWP", nReg, nOpc,,,,aMostrar,{ 15,  1, nMeio-1 , (oDlg:nClientWidth-4)/2 },aDarGets,3)
   dbSelectArea("Work")
   dbGoTop()
   oMarkItens:=msSelect():New("Work",IF(nTipo==INCLUI_LSI.or.(nTipo==ALTERA_LSI.and.nQual==LSI),"WKFLAGLSI",),,aCamposLSI,lInverte,cMarca,{nMeio,1,(oDlgManut:nClientHeight-6)/2,(oDlgManut:nClientWidth-4)/2})
   oMarkItens:oBrowse:bWhen:={|| dbSelectArea('Work'),oMarkItens:oBrowse,.T.}
   IF nTipo==INCLUI_LSI.or.(nTipo==ALTERA_LSI.and.nQual==LSI)
      oMarkItens:bAval:={|| GI400MarkLSI(.F.,oMarkItens:oBrowse:Refresh(),nTipo),oMarkItens:oBrowse:Refresh() }
   ELSE
      oMarkItens:bAval:={|| .F. }
   ENDIF

   ACTIVATE MSDIALOG oDlgManut ON INIT (enchoicebar(oDlgManut,bOk_Man,bCancel_Man,,aBotoesLSI),;
                                       oEncItens:oBox:Align:=CONTROL_ALIGN_TOP,;         //LRL 23/03/04
                                       oMarkItens:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT, oMarkItens:oBrowse:Refresh())//Alinhamento MDI

   IF nTipo == VISUAL_LSI // Visualizar de Itens da LSI
      Exit
   EndIf

   If nOpca == 0

      dbSelectArea("Work")
      Set Filter to

      If nTipo == INCLUI_LSI // Inclusao                  // Se for inclusao e foi pressionado o Botao Cancela
         Work->(dbGoTop())                       // Desmarca todos os itens marcados
         Do While Work->(!eof())
            If empty(Work->WKSEQ_LSI)
               Work->WKFlagLSI := " "
            EndIf
            Work->(dbSkip())
         EndDo
      ElseIf nTipo == ALTERA_LSI // Alteração
         Work->(dbGoTop())
         Do While Work->(!eof())
            Work->WKSEQ_LI := Work->WKSEQ_LSI   // Volta ao que estava antes
            Work->(dbSkip())
         EndDo
      EndIf
      Exit
   EndIf


   Processa({||lRetorno := GI400LSIGRVWORK(nTipo)})

   If lRetorno  // JBS 18/12/2003
      Exit
   EndIf

EndDo

aTELA:=ACLONE(aTELAold)
aGETS:=ACLONE(aGETSold)

dbSelectArea("Work")
Set Filter to
Work->(dbGoToP())
Work_SWP->(dbGoTop())
RETURN(nOpc<>0)
*-------------------------------------------------------------------------------------*
FUNCTION GI400MarkLSI(lTodos,oBrw,nTipo,cNCM)
*-------------------------------------------------------------------------------------*
Local cNewMarca := if(!empty(Work->WKFLAGLSI),Space(2),cMarca)
Local nRecWork  := Work->(recno())

If !Empty(cNewMarca)
   If nRecMarcado > 0
      Work->(dbGoto(nRecMarcado))
      Work->WKFLAGLSI := Space(2)
   EndIf
   Work->(dbGoto(nRecWork))
   Work->WKFLAGLSI := cNewMarca
   nRecMarcado := nRecWork
Else
   Work->WKFLAGLSI := Space(2)
   nRecMarcado     := 0
EndIf

RETURN .T.
*-----------------------------------------------------------*
FUNCTION GI400LSIGRVWORK(ntipo)        // JBS 13/11/2003
*-----------------------------------------------------------*
Local lTemItensMarcados:=.F., lRetorno := .T.

ProcRegua(Work->(EasyRecCount("Work")))
Work->(dbGotop())
Do While Work->(!EOF())
   if nTipo==EXCLUI_LSI.and.!empty(Work->WKSEQ_LI)
      lTemItensMarcados :=.T.
      Work->WKSEQ_LI  := ""   // Disponibiliza o item para
      Work->WKFLAGLSI := ""   // Outras LSI
   elseif !empty(Work->WKFLAGLSI).and.empty(Work->WKSEQ_LI)
      Work->WKSEQ_LI  := M->WP_SEQ_LI    // Determina a Sequencia da LSI
      M->WP_NCM       := Work->WKTEC     // Determina a NCM da LSI
      lTemItensMarcados:=.T.
   endif
   Work->(dbSkip())
EndDo
//
//  1a. Condição: Existem itens selecionados e esta em qualquer uma da Opções (Inc, Alt, Exc ou Vis)
//  2a. Condição: Não Existem nesta LSI e o usuario deseja apagar a CAPA.
//
If lTemItensMarcados.or.(!lTemItensMarcados.and.nTipo == EXCLUI_LSI)  // 2a. Cond. Não ha itens mas existe LSI.
   If nTipo == INCLUI_LSI                                    // Adicionar um registro para nova LSI (Incluir)
      Work_SWP->(dbAppend())
      AvReplace("M","Work_SWP")
      Work_SWP->TRB_ALI_WT:= "SWP"
      Work_SWP->TRB_REC_WT:=  SWP->(Recno())
   ElseIf nTipo == ALTERA_LSI  // Na Alteração uma LSI deixou de existir e outra foi gerada (Alterar)
      AvReplace("M","Work_SWP")

   ElseIf nTipo == EXCLUI_LSI  // Exluindo uma LSI   (Excluir)
      // Apagando numero de Orgaos de Processos Anuentes desta LSI
      Work_EIT->(dbGoTop())
      Work_EIT->(dbSeek(M->W4_PGI_NUM+M->WP_SEQ_LI))
      Do While Work_EIT->(!EOF()).and.Work_EIT->EIT_SEQ_LI==M->WP_SEQ_LI
         Work_EIT->(dbDelete())
         Work_EIT->(dbSkip())
      EndDo
      Work_SWP->(dbDelete())
   EndIf
Elseif nTipo # VISUAL_LSI   // Se não for Visualização
   HELP("",1,"AVG0000670")//MSGINFO("Nao ha itens selecionados","Atencao")
   lRetorno:= .F.
EndIf
RETURN(lRetorno)
*----------------------------------------*
FUNCTION GI400WorkSWP()
*----------------------------------------*
LOCAL nIndSWP:=SWP->(INDEXORD())
Work_SWP->(avzap())
nTamEsp:=AVSX3("WP_ESP_VM",3)
nTamInf:=AVSX3("WP_INF_VM",3)

SWP->(DBSETORDER(1))
SB1->(DBSETORDER(1))
If SWP->(DBSEEK(xFilial("SWP")+SW4->W4_PGI_NUM))
   Do While SWP->(!Eof()).AND.;
            SWP->WP_PGI_NUM == SW4->W4_PGI_NUM .AND.;
            xFilial("SWP") == SWP->WP_FILIAL

      Work_SWP->(DBAPPEND())
      AvReplace("SWP","Work_SWP")
      Work_SWP->WP_PROCANU := STR0285 //str0285 "Tecle F3"
      Work_SWP->WKRECNO := SWP->(Recno())
      Work_SWP->WP_ESP_VM:=MSMM(SWP->WP_ESPECIF,nTamEsp,,,3)
      Work_SWP->WP_INF_VM:=MSMM(SWP->WP_INFCOMP,nTamInf,,,3)
      Work_SWP->TRB_ALI_WT:= "SWP"
      Work_SWP->TRB_REC_WT:=  SWP->(Recno())
      SWP->(DbSkip())
   EndDo
   // JBS - 24/11/2003 - Carregando a Work_EIT -> Com Nros de Processos de cada LSI
   If EIT->(dbSeek(xFilial("EIT")+SW4->W4_PGI_NUM))
      Do While EIT->EIT_FILIAL==xFilial("EIT").and.SW4->W4_PGI_NUM==EIT->EIT_PGI_NU.and.EIT->(!eof())
         Work_EIT->(DBAPPEND())
         AvReplace("EIT","Work_EIT")
         WORK_EIT->EIT_RECNO := EIT->(RecNo())
         EIT->(DbSkip())
      EndDo
   EndIf
   SWP->(DBSETORDER(nIndSWP))
ENDIF
Return
*---------------------------------------------*
FUNCTION GI400LSIValid(cVar,lTudo) // JBS 22/11/2003
*---------------------------------------------*
Local lRetorno := .T.
Local cGet:=ReadVar()
Local nRecSwp
cVar:=iif(cVar==Nil,alltrim(subStr(cGet,4)),cVar)
DEFAULT lTudo := .F.
If Select("Work_Swp") > 0
   nRecSwp:=Work_Swp->(Recno())
EndIf

Do Case
   Case Lastkey()=27
        Return(.T.)

   Case cVar=="WP_MERCOS"   // "Selecione Uma das Opcoes (1-Sim, 2-Nao)"
        If empty(M->WP_MERCOS)
           HELP("",1,"AVG0000674")// MSGINFO("Selecione uma das Opcoes de MercoSul (1-Sim, 2-Nao)","Atencao")
           lRetorno:=.F.
        EndIf

   Case cVar=="WP_NAT_LSI" .AND. !lTudo // "Natureza de LSI não Informada" / "Natureza de LSI nao Cadastrada"
        If empty(M->WP_NAT_LSI)
           MSGINFO(STR0220+AVSX3("WP_NAT_LSI",15),"Atencao") // "Natureza de Operacao da LSI nao Informada na Pasta: "
           lRetorno:=.F.
        ElseIf !SJV->(dbSeek(xfilial("SJV")+M->WP_NAT_LSI))
           HELP("",1,"AVG0000675")// MSGINFO("Natureza de LSI nao Cadastrada","Atencao")  // "Natureza de LSI nao Cadastrada"
           lRetorno:=.F.
        ElseIf Select("Work_Swp") > 0
           if !Work_Swp->(EOF().and.BOF())
              Work_SWP->(DBGOTOP())

              DO WHILE Work_Swp->(!EOF())
                 IF ((nTipoOpera <> INCLUI_LSI .and. nRecSWP # Work_Swp->(Recno())).AND.Work_SWP->WP_NAT_LSI # M->WP_NAT_LSI).or.;
                     (nTipoOpera == INCLUI_LSI .and. Work_SWP->WP_NAT_LSI # M->WP_NAT_LSI.AND.!Empty(Work_SWP->WP_NAT_LSI))

                     MSGINFO(STR0221+Work_SWP->WP_NAT_LSI,STR0062)  // "Natureza da Operacao difere das anteriores: "  "Atencao"
                     lRetorno := .F.
                     Exit
                 ENDIF
                 Work_Swp->(dbSkip())
              ENDDO

              Work_SWP->(dbGoto(nRecSwp))

           EndIf
           If lRetorno.and.(Work_SWP->WP_NAT_LSI # M->WP_NAT_LSI.or.Empty(Work_SWP->WP_NAT_LSI))
              M->WP_REG_TRI := SPACE(LEN(SWP->WP_REG_TRI))
              M->WP_FUN_REG := SPACE(LEN(SWP->WP_FUN_REG))
              M->WP_MOTIVO  := SPACE(LEN(SWP->WP_MOTIVO ))
              GI400Simples()
           Endif
        Endif

   Case (cVar $ 'WP_REG_TRI,WP_FUN_REG,WP_MOTIVO,WP_TEC_CL') .OR. lTudo

        lFunReg:=(cVar == 'WP_FUN_REG'.OR. lTudo)
        lMotivo:=(cVar == 'WP_MOTIVO' .OR. lTudo)
        lClassi:=(cVar == 'WP_TEC_CL' .OR. lTudo)

        IF Type("cFiltroSJP") == "C" .And. M->WP_REG_TRI $ cFiltroSJP //"1,2,3,5,6,7,8"

           cFiltroSY8:=""
           cFiltroSJR:=""
           cClassif  :=""
           DI500DSIRegra(M->WP_NAT_LSI,M->WP_REG_TRI,M->WP_FUN_REG,M->WP_MOTIVO,.T.)

           IF !lTudo
              IF M->WP_REG_TRI = "1"
                 M->WP_FUN_REG := SPACE(LEN(SWP->WP_FUN_REG))
              ENDIF
              IF EMPTY(cFiltroSJR)//!(M->WP_REG_TRI $ '5,6,7')
                 M->WP_MOTIVO := SPACE(LEN(SWP->WP_MOTIVO))
              ENDIF
           ENDIF

           IF lFunReg .AND. !EMPTY(cFiltroSY8) .AND. !(M->WP_FUN_REG $ cFiltroSY8)
              MSGSTOP(STR0224+cFiltroSY8)   //"Regime somente aceita Fund. Legal: "
              lRetorno := .F.
           ENDIF

           IF lMotivo
              IF EMPTY(cFiltroSJR)
                 IF !EMPTY(M->WP_MOTIVO)
                    HELP("",1,"AVG0000676")// MSGSTOP("Motivo nao deve ser preenchido para esse Fundamento Legal")
                    lRetorno := .F.
                 ENDIF
              ELSEIF !(M->WP_MOTIVO $ cFiltroSJR)
	                 MSGSTOP(STR0227+cFiltroSJR)   // "Fundamento somente aceita Motivo: "
                 lRetorno := .F.
              ENDIF
           ENDIF

           IF lClassi .AND. !EMPTY(cClassif) .AND. !(SubStr(M->WP_TEC_CL,1,1) $ cClassif)
              MSGSTOP(STR0228+cClassif)  // "Classificacao deve ser : "
              lRetorno := .F.
           ENDIF
        //MFR 15/10/2019 OSSME-3638
        ELSEIF Type("cFiltroSJP") == "C" .And. (cVar $ 'WP_REG_TRI' .OR. lTudo) .AND. M->WP_NAT_LSI # "12"
           MSGSTOP(STR0229+cFiltroSJP)  // "A Declaracao somente aceita Reg. Trib.: "
           lRetorno := .F.
        ENDIF

   Case cVar=="WP_URF_DES"  // "U.R.F de Destino não Cadastrada"
        If !empty(M->WP_URF_DES)
           If !SJ0->(dbSeek(xfilial("SJ0")+M->WP_URF_DES))
              HELP("",1,"AVG0000677")// MSGINFO("U.R.F de Destino não Cadastrada","Atencao")
              lRetorno:=.F.
           Endif
        Endif

   Case cVar=="WP_PAIS_PR"  // "Pais de Procedencia"
        If !empty(M->WP_PAIS_PR)
           If !SYA->(dbSeek(xfilial("SYA")+M->WP_PAIS_PR))
              HELP("",1,"AVG0000678")// MSGINFO("Codigo de Pais Procedencia não Cadastrado","Atencao")
              lRetorno:=.F.
           else
              M->WP_PRO_NOM := SYA->YA_DESCR
           Endif
        Endif

   Case cVar=="WP_REGIST"  //LGS-28/06/2016
        If !Empty(M->WP_REGIST)
           aOrdWP := SaveOrd({"SWP"})
           SWP->(DbSetOrder(5))
           If SWP->(DbSeek(xFilial("SWP")+M->WP_REGIST))
              MsgInfo(STR0358, STR0344)
              lRetorno:=.F.
           EndIf
           RestOrd(aOrdWP,.T.)
        EndIf

endCase
If Select("Work_Swp") > 0
   Work_SWP->(dbGoto(nRecSwp))
EndIf

RETURN(lRetorno)

//FSY - 03/10/2013 - Ajustada para que os orgões anuente sejam editaveis de forma correta utilizando WORK_TMP para visualizar, WORK_EIT como intermedio da tabela EIT
*--------------------------------------------------------------------*
Function GI400BrowseEI()//Chamado do SXB, XB_ALIAS = 'EIT'
*--------------------------------------------------------------------*
Local aTB_Campos,cTituto:="Manutenção de Processos Anuentes",nPos,nTam //"Manutencao de Processos Anuentes"
Local bOkEIT    :={||nOpcEIT:=1,oDlgEI:End()},nOpcEIT:=0
Local bCancelEIT:={||nOpcEIT:=0,oDlgEI:End()},nAlias:=SELECT(), cFileTemp
Local cUsado:=Posicione("SX3",2,"EIT_ORGAO","X3_USADO")
Local aNoFields := {}
Private lValidRepetidos:=.T.,aCpos:={},nLargura:=300//, aStru_TMP
Private aCamposEIT:= {"EIT_NUMERO","EIT_ORGAO"}  //TRP - 30/11

If Empty(M->WP_SEQ_LI)      //Se o numero da LSI não estiver preenchido, não pode Prosseguir, pois este é base na
   HELP("",1,"AVG0000670")  //MSGINFO("Nao ha itens selecionados","Atencao")
   Return(.f.)              //chave de relacionamente entre EIT e Works
EndIf

Private aCampos := ARRAY(EIT->(FCOUNT())), aHeader := {},aEdita :={"EIT_NUMERO","EIT_ORGAO"}

nLargura := 400

//usado no MsGetDB
aHeader:={{AvSx3("EIT_NUMERO",5),"EIT_NUMERO",AvSx3("EIT_NUMERO",6),AvSx3("EIT_NUMERO",3),0,"GI400LSIValid()",cUsado ,"C","EIT"},;
          {AvSx3("EIT_ORGAO" ,5),"EIT_ORGAO" ,AvSx3("EIT_ORGAO" ,6),AvSx3("EIT_ORGAO" ,3),0,"GI400LSIValid()",cUsado ,"C","EIT"}}
If EIT->(FieldPos("EIT_TRATA")) # 0 .AND. EIT->(FieldPos("EIT_CDSTA")) # 0 .AND. EIT->(FieldPos("EIT_STAT")) # 0 .AND.;
   EIT->(FieldPos("EIT_DTANU")) # 0 .AND. EIT->(FieldPos("EIT_DTVAL")) # 0 .AND. EIT->(FieldPos("EIT_TEXTO")) # 0  // GFP - 20/02/2015
   aAdd(aHeader,{AvSx3("EIT_TRATA",5),"EIT_TRATA" ,AvSx3("EIT_TRATA",6),AvSx3("EIT_TRATA",3),0,"",cUsado ,"C","EIT"})
   aAdd(aHeader,{AvSx3("EIT_STAT",5) ,"EIT_STAT"  ,AvSx3("EIT_STAT",6) ,AvSx3("EIT_STAT",3) ,0,"",cUsado ,"C","EIT"})
   aAdd(aHeader,{AvSx3("EIT_DTANU",5),"EIT_DTANU" ,AvSx3("EIT_DTANU",6),AvSx3("EIT_DTANU",3),0,"",cUsado ,"D","EIT"})
   aAdd(aHeader,{AvSx3("EIT_DTVAL",5),"EIT_DTVAL" ,AvSx3("EIT_DTVAL",6),AvSx3("EIT_DTVAL",3),0,"",cUsado ,"D","EIT"})
EndIf
dbSelectArea("EIT")
aStru_TMP := {{"EIT_NUMERO","C",len(EIT->EIT_NUMERO),0},;
              {"EIT_ORGAO" ,"C",len(EIT->EIT_ORGAO),0 },;
              {"EIT_FLAG"  ,"L",1                  ,0 },;
              {"EIT_WKREC" ,"N",7                  ,0 }}
If EIT->(FieldPos("EIT_TRATA")) # 0 .AND. EIT->(FieldPos("EIT_CDSTA")) # 0 .AND. EIT->(FieldPos("EIT_STAT")) # 0 .AND.;
   EIT->(FieldPos("EIT_DTANU")) # 0 .AND. EIT->(FieldPos("EIT_DTVAL")) # 0 .AND. EIT->(FieldPos("EIT_TEXTO")) # 0  // GFP - 20/02/2015
   aAdd(aStru_TMP,{"EIT_TRATA","C",AvSx3("EIT_TRATA",3),0})
   aAdd(aStru_TMP,{"EIT_STAT" ,"C",AvSx3("EIT_STAT",3) ,0})
   aAdd(aStru_TMP,{"EIT_DTANU","D",AvSx3("EIT_DTANU",3),0})
   aAdd(aStru_TMP,{"EIT_DTVAL","D",AvSx3("EIT_DTVAL",3),0})
EndIf

IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"ADD_WORK_TMP"),)    //TRP - 30/11

cFileTemp := E_CriaTrab(,aStru_TMP,"Work_TMP") //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados

GI400GrvTemp(.T.)

nPos:= 3
WORK_TMP->(DBGOTOP())
lVisual    := (nQual == VISUAL)
IF lVisual
   nPos := 2
ELSEIF WORK_TMP->(EasyRecCount("Work_TMP")) >= 0
   nPos := 3
ENDIF

If !lVisual .And. (WORK_TMP->(EOF()) .Or. WORK_TMP->(BOF()))
   WORK_TMP->(dbAppend())
End If

DEFINE MSDIALOG oDlgEI  ;
TITLE           cTituto ;
FROM            oMainWnd:nTop   +200,oMainWnd:nLeft +1 ;
TO              oMainWnd:nBottom-200,oMainWnd:nRight-nLargura OF oMainWnd PIXEL

oPanel:= TPanel():New(0, 0, "", oDlgEI,, .F., .F.,,, 90, 165)
oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

WORK_TMP->(dbGotop())
WORK_TMP->(oMarkEI:=MsGetDB():New(28,1,(oPanel:nClientHeight-6)/2,(oPanel:nClientWidth-4)/2, nPos , ,"","",.T. , aCamposEIT , , , ,"Work_TMP") )     //TRP - 30/11
oMarkEI:oBrowse:bwhen:={||(dbSelectArea("Work_TMP"),.t.)}

ACTIVATE MSDIALOG oDlgEI ON INIT EnchoiceBar(oDlgEI,bOkEIT,bCancelEIT) CENTERED

If nOpcEIT==1 .and. !lVisual
   WORK_TMP->(DBEVAL( {|| GI400GrvTemp(.F.) }))
endif

WORK_TMP->(E_EraseArq(cFileTemp))
select(nAlias)

Return .T.

//FSY - 03/10/2013 - Ajustada para que grave corretamente os registros entre a WORK_EIT e WORK_TMP
*--------------------------------------------------*
Function GI400GrvTemp(lGravaTemp)
*--------------------------------------------------*
Local   aNoFields := {}

WORK_EIT->(dbGotop())
WORK_TMP->(dbGotop())

// Grava na Work_Tmp os Registros da WORK_EIT ->Fazer MsGet na WORK_TMP
If lGravaTemp

   dbSelectArea("Work_TMP")
   SX3->( DBSetOrder(1) )
   SX3->( DBSeek("EIT") )

   Do While SX3->X3_ARQUIVO == "EIT"
      AAdd( aNoFields, AllTrim(SX3->X3_CAMPO) )
      SX3->( DBSkip() )
   EndDo

   While WORK_EIT->(!EOF())
      If !WORK_EIT->EIT_FLAG
         WORK_TMP->(dbAppend())
         WORK_TMP->EIT_NUMERO := WORK_EIT->EIT_NUMERO
         WORK_TMP->EIT_ORGAO  := WORK_EIT->EIT_ORGAO
         WORK_TMP->EIT_WKREC  := WORK_EIT->EIT_WKREC
         If EIT->(FieldPos("EIT_TRATA")) # 0 .AND. EIT->(FieldPos("EIT_CDSTA")) # 0 .AND. EIT->(FieldPos("EIT_STAT")) # 0 .AND.;
            EIT->(FieldPos("EIT_DTANU")) # 0 .AND. EIT->(FieldPos("EIT_DTVAL")) # 0 .AND. EIT->(FieldPos("EIT_TEXTO")) # 0  // GFP - 20/02/2015
            WORK_TMP->EIT_TRATA := WORK_EIT->EIT_TRATA
            WORK_TMP->EIT_STAT  := WORK_EIT->EIT_STAT
            WORK_TMP->EIT_DTANU := WORK_EIT->EIT_DTANU
            WORK_TMP->EIT_DTVAL := WORK_EIT->EIT_DTVAL
         EndIf
         IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"CARREGA_WORK_TMP"),)   //TRP - 30/11
      End If
   Work_EIT->( DbSkip() )
   End Do

// Grava na Work_EIT os Registros da WORK_TMP ->São Resultados do MsGetDB
Else

   While WORK_TMP->(!EOF())

      If ! (WORK_EIT->(DELETED()) := WORK_TMP->(DELETED()) .OR. Empty(WORK_TMP->EIT_NUMERO) .OR. Empty(WORK_TMP->EIT_ORGAO))

               If lLi

                  If Work_TMP->EIT_WKREC > 0
                     WORK_EIT->(dbGoTo( WORK_TMP->EIT_WKREC   ))
                  Else
                     WORK_EIT->(dbAppend())
                  End If
                  WORK_TMP->EIT_WKREC  := WORK_EIT->(RECNO())//Insere recno da WORK_EIT que servira como referencia na WORK_TMP
                  Work_EIT->EIT_NUMERO := WORK_TMP->EIT_NUMERO
                  WORK_EIT->EIT_ORGAO  := WORK_TMP->EIT_ORGAO
                  WORK_EIT->EIT_SEQ_LI := M->WP_SEQ_LI
	              WORK_EIT->EIT_PGI_NU := M->WP_PGI_NUM
                  Work_EIT->EIT_WKREC  := WORK_TMP->EIT_WKREC
                  If EIT->(FieldPos("EIT_TRATA")) # 0 .AND. EIT->(FieldPos("EIT_CDSTA")) # 0 .AND. EIT->(FieldPos("EIT_STAT")) # 0 .AND.;
                     EIT->(FieldPos("EIT_DTANU")) # 0 .AND. EIT->(FieldPos("EIT_DTVAL")) # 0 .AND. EIT->(FieldPos("EIT_TEXTO")) # 0  // GFP - 20/02/2015
                     WORK_EIT->EIT_TRATA := WORK_TMP->EIT_TRATA
                     WORK_EIT->EIT_STAT  := WORK_TMP->EIT_STAT
                     WORK_EIT->EIT_DTANU := WORK_TMP->EIT_DTANU
                     WORK_EIT->EIT_DTVAL := WORK_TMP->EIT_DTVAL
                  EndIf
               Else
                  If Work_TMP->EIT_WKREC > 0
                     WORK_EIT->(dbGoTo( WORK_TMP->EIT_WKREC   ))
                  Else
                     WORK_EIT->(dbAppend())
                  End If
                  WORK_TMP->EIT_WKREC  := WORK_EIT->(RECNO())//Insere recno da WORK_EIT que servira como referencia na WORK_TMP
                  Work_EIT->EIT_NUMERO := WORK_TMP->EIT_NUMERO
	              Work_EIT->EIT_ORGAO  := WORK_TMP->EIT_ORGAO
	              Work_EIT->EIT_SEQ_LI := Work->WKSEQ_LI
	              Work_EIT->EIT_PGI_NU := M->W4_PGI_NUM
	              Work_EIT->EIT_WKREC  := WORK_TMP->EIT_WKREC
	              If EIT->(FieldPos("EIT_TRATA")) # 0 .AND. EIT->(FieldPos("EIT_CDSTA")) # 0 .AND. EIT->(FieldPos("EIT_STAT")) # 0 .AND.;
                     EIT->(FieldPos("EIT_DTANU")) # 0 .AND. EIT->(FieldPos("EIT_DTVAL")) # 0 .AND. EIT->(FieldPos("EIT_TEXTO")) # 0  // GFP - 20/02/2015
                     WORK_EIT->EIT_TRATA := WORK_TMP->EIT_TRATA
                     WORK_EIT->EIT_STAT  := WORK_TMP->EIT_STAT
                     WORK_EIT->EIT_DTANU := WORK_TMP->EIT_DTANU
                     WORK_EIT->EIT_DTVAL := WORK_TMP->EIT_DTVAL
                  EndIf
               End If
            
               IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"CARREGA_WORK_EIT2"),)   //TRP - 30/11
            
            Work_EIT->EIT_FLAG   := WORK_TMP->EIT_FLAG
            //AvReplace("WORK_TMP","WORK_EIT")

      End If

      WORK_TMP->( DbSkip() )
      WORK_EIT->( DbSkip() )
   End Do

   WORK_TMP->(avzap())

EndIf

RETURN .T.
*--------------------------------------------------*
Function GI400EIValid(lGravaTemp) // JBS 24/11/2003
// Validar o MsGetDB do Cadastro de Processos Anuentes
*--------------------------------------------------*
If Empty(Work_TMP->EIT_NUMERO) .and. Empty(Work_TMP->EIT_ORGAO) .AND. !Work_TMP->EIT_FLAG //DELETE
   HELP("",1,"AVG0000679")// MSGINFO("Numero e Orgao Anuente não Informados!","Atencao")
   Return .F.
EndIf
Return .T.

*--------------------------------------------------*
Function GI400DelEIT(lSWP)     //    JBS 25/11/2003
*--------------------------------------------------*
/*                  LSI
 Esta função pode ser chamada do Estorno de LSI  ->lSWP := .T. (Testa EIT com SWP....: PGI + LSI)
 Tambem é Chamada na Gravação do Arquivo EIT     ->lSWP := .F. (Testa EIT com Var.Mem: PGI )
*/
EIT->(dbSetOrder(1)) // Filial + PGI + SEQ_LI + Numero
If EIT->(dbSeek(xFilial("EIT")+iif(lSWP,SWP->WP_PGI_NUM+SWP->WP_SEQ_LI,M->W4_PGI_NUM)))
   Do While EIT->(!EOF()).and.iif(lSWP,;
                      SWP->WP_PGI_NUM==EIT->EIT_PGI_NU.and.SWP->WP_SEQ_LI==EIT->EIT_SEQ_LI,;
                      M->W4_PGI_NUM==EIT->EIT_PGI_NU).and.xFilial("EIT")==EIT->EIT_FILIAL
      EIT->(RecLock("EIT",.F.))    // efetua Trava
      EIT->(dbDelete())
      EIT->(dbSkip())
   EndDo
EndIf
Return(.T.)
*--------------------------------------------------*
Function GI400APPEND_EIT()   // JBS 25/11/2003
*--------------------------------------------------*
/*                  LSI
  Grava o arquivo EIT Com o conteudo da Work_EIT
  Chamada EIGGI400 e EIC
*/
Local nOrdWork := Work->(indexOrd())

Work->(dbSetOrder(5))

Work_EIT->(dbGotop())

Do While work_EIT->(!eof())

   // JBS - 26/12/2003
   If !Work->(dbSeek(Work_EIT->EIT_SEQ_LI)).or.!Work->WKFLAG
      Work_EIT->(dbSkip())   // Descarta capa da LSI sem Itens
      Loop
   EndIf

   RecLock("EIT",.T.)    // efetua Append e Trava
   AvReplace("Work_EIT","EIT")

   EIT->EIT_FILIAL := xFilial()
   EIT->(MsUnlock())

   Work_EIT->(dbSkip())

EndDo

Work->(dbSetOrder(nOrdWork))

Return(.T.)

*---------------------------------------------------*
// JBS - 08/12/2003 - Projeto LSI
Function GI400Simples()
*---------------------------------------------------*
cFiltroSJP:=cFiltroSY8:=cFiltroSJR:=cClassif:=""

IF SJW->(EOF()).AND.SJW->(BOF())
   HELP("",1,"AVG0000680")// MSGINFO("Arquivo de Regras da DSI esta vazio: Entre no Menu Atualizacoes/Tabelas Siscomex/Sisccad (Siscomex) e Importe a Opcao Regras da DSI.")
   RETURN .F.
ENDIF

SJW->(DBSETORDER(1))
IF SJW->(DBSEEK(xFilial()+M->WP_NAT_LSI))
   DO WHILE SJW->(!EOF()) .AND. xFilial("SJW") == SJW->JW_FILIAL .AND. SJW->JW_NAT_OPE == M->WP_NAT_LSI
      IF !(SJW->JW_REGIME $ cFiltroSJP)
         cFiltroSJP+=SJW->JW_REGIME+","
      ENDIF
      IF !(SJW->JW_FUND_LE $ cFiltroSY8) .AND. SJW->JW_FUND_LE # "00"
         cFiltroSY8+=SJW->JW_FUND_LE+","
      ENDIF
      IF !(SJW->JW_MOTIVO $ cFiltroSJR) .AND. SJW->JW_MOTIVO # "00"
         cFiltroSJR+=SJW->JW_MOTIVO+","
      ENDIF
      SJW->(DBSKIP())
   ENDDO
   IF !EMPTY(cFiltroSJP)
      cFiltroSJP:=LEFT(cFiltroSJP,LEN(cFiltroSJP)-1)
   ENDIF
   IF !EMPTY(cFiltroSY8)
      cFiltroSY8:=LEFT(cFiltroSY8,LEN(cFiltroSY8)-1)
   ENDIF
   IF !EMPTY(cFiltroSJR)
      cFiltroSJR:=LEFT(cFiltroSJR,LEN(cFiltroSJR)-1)
   ENDIF
ENDIF
RETURN(.T.)
*---------------------------------------------------*
FUNCTION GI400SXBFiltra(cAlias)  // JBS - 08/12/2003
*---------------------------------------------------*
Local lRetorno := .T.

IF cAlias = "SJP"         // Cadastro de tabela de regimes tributarios
   IF TYPE("cFiltroSJP")="C"
      lRetorno := SJP->JP_CODIGO $ cFiltroSJP
   ENDIF

ELSEIF cAlias = "SY8"     // Cadastro de fundamento legal
   IF TYPE("cFiltroSY8")="C"
      lRetorno := SY8->Y8_COD $ cFiltroSY8
   ENDIF

ELSEIF cAlias = "SJR"     // Cadastro de motivo de admissao temporaria
   IF TYPE("cFiltroSJR")="C"
      lRetorno := (M->WP_FUN_REG == SJR->JR_FUNDLEG) .AND. SJR->JR_CODIGO $ cFiltroSJR
   ENDIF

ENDIF
RETURN(lRetorno)
*---------------------------------------------------*
FUNCTION GI400F_WHEN(cAlias)       // JBS 08/12/2003
*---------------------------------------------------*
Local lRetorno := .T.
Local cVar := ReadVar()

Do Case
   Case cVar == "M->WP_REG_TRI"                //MFR 15/10/2019 OSSME-3638
        lRetorno := !Empty(M->WP_NAT_LSI) .or. !lTem_DSI

   Case cVar == "M->WP_FUN_REG"
        lRetorno := (!Empty(M->WP_NAT_LSI).and.!Empty(M->WP_REG_TRI)) .or. !lTem_DSI

   Case cVar == "M->WP_MOTIVO"
        lRetorno := (!Empty(M->WP_NAT_LSI).and.!Empty(M->WP_FUN_REG)) .or. !lTem_DSI

// Case cVar == "M->WP_NAT_LSI"
//      lRetorno := empty(M->WP_MOTIVO).and.empty(M->WP_REG_TRI).and.empty(M->WP_FUN_REG)

EndCase

RETURN(lRetorno)
*---------------------------------------------------------------*
FUNCTION GI400ItemMarcados(lMensagem,lBtOK)  // JBS 16/12/2003
//  Testa se existe Registro Marcado apenas Qdo Tiver LSI
*---------------------------------------------------------------*
Local lRetorno := .F.
Local lEmpty_Seq_LI := .F.

Default lMensagem := .F.
Default lBtOK     := .F.

Work->(dbGoTop())
Do While Work->(!EOF())
   If Work->WKFLAG
      lRetorno := .T.
      If Empty(Work->WKSEQ_LI)
         lEmpty_Seq_LI := .T.
      EndIf
   EndIf
   Work->(dbSkip())
EndDo
Work->(dbGotop())

If !lRetorno
   If lMensagem
      HELP("",1,"AVG0000670")  //MSGINFO("Nao ha itens selecionados","Atencao")
   EndIf
ElseIf lBtOK // Se Foi Chamado pelo Botão que Confirma a Gravação da LSI
   lRetorno := !Work_SWP->(Eof().and.Bof())
   If !lRetorno .and. lMensagem
      HELP("",1,"AVG0000681")// MSGINFO("Dados da LSI nao informados!","Atencao")  // "Dados da LSI não informados!"
   Elseif lEmpty_Seq_LI
      lRetorno := !lEmpty_Seq_LI
      If lMensagem
         HELP("",1,"AVG0000682")// MSGINFO("Existe um ou mais itens sem Dados para LSI!","Atencao")  // "Existe um ou mais itens sem Dados para LSI!"
      EndIf
   EndIf
EndIf

Work->(dbGotop())
Work_SWP->(dbGotop())

RETURN(lRetorno)
*------------------------------------------------*
Function GI400GerNrLSI()
// Gerar Automaticamento o Nro da LSI
*------------------------------------------------*
Local nNrNewLSI:=1
Do While Work_SWP->(dbSeek(StrZero(nNrNewLSI,3,0)))
   nNrNewLSI++
EndDo
Return (StrZero(nNrNewLSI,3,0))
*----------------------*
FUNCTION GI400CriaEIT()
*----------------------*
Private aStru_EIT:={{"EIT_NUMERO","C",len(EIT->EIT_NUMERO),0},;
                  {"EIT_ORGAO" ,"C",len(EIT->EIT_ORGAO),0 },;
                  {"EIT_SEQ_LI","C",len(EIT->EIT_SEQ_LI),0},;
                  {"EIT_PGI_NU","C",len(EIT->EIT_PGI_NU),0},;
                  {"EIT_RECNO" ,"N",7,0},;//FSY - 30/09/2013 - campo para gravar o recno da base EIT
                  {"EIT_FLAG"  ,"L",1,0},;//FSY - 30/09/2013 - campo para o controle de registro que foi marcado por delete
                  {"EIT_WKREC" ,"N",7,0}} //FSY - 30/09/2013 - campo para gravar o recno entre a WORK_EIT e a WORK_TMP
If EIT->(FieldPos("EIT_TRATA")) # 0 .AND. EIT->(FieldPos("EIT_CDSTA")) # 0 .AND. EIT->(FieldPos("EIT_STAT")) # 0 .AND.;
   EIT->(FieldPos("EIT_DTANU")) # 0 .AND. EIT->(FieldPos("EIT_DTVAL")) # 0 .AND. EIT->(FieldPos("EIT_TEXTO")) # 0  // GFP - 20/02/2015        //TRP - 30/11
   aAdd(aStru_EIT,{"EIT_TRATA","C",AvSx3("EIT_TRATA",3),0})
   aAdd(aStru_EIT,{"EIT_STAT" ,"C",AvSx3("EIT_STAT",3) ,0})
   aAdd(aStru_EIT,{"EIT_DTANU","D",AvSx3("EIT_DTANU",3),0})
   aAdd(aStru_EIT,{"EIT_DTVAL","D",AvSx3("EIT_DTVAL",3),0})
EndIf

IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"ADD_WORK_EIT"),)   //TRP - 30/11

cWork_EIT := E_CriaTrab(,aStru_EIT,"Work_EIT") //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados

IF !USED()
   Help(" ",1,"E_NAOHAREA")
   RETURN .F.
ENDIF
AvZap("Work_EIT")

IndRegua("Work_EIT",cWork_EIT+TEOrdBagExt(),"EIT_PGI_NU+EIT_SEQ_LI+EIT_NUMERO")
//*FSY 03/10/2013 - Ajuste para gravar EIT corretamente
If lLI
   EIT->( DBSetOrder(1) )
   EIT->( dbGotop() )
   EIT->(dbSeek(xFilial("EIT")+M->WP_PGI_NUM+M->WP_SEQ_LI))
   While EIT->(!EOF()) .And. M->WP_SEQ_LI == EIT->EIT_SEQ_LI .AND.  M->WP_PGI_NUM  == EIT->EIT_PGI_NU
      Work_EIT->(dbAppend())
      Work_EIT->EIT_NUMERO := EIT->EIT_NUMERO
      Work_EIT->EIT_ORGAO  := EIT->EIT_ORGAO
      Work_EIT->EIT_SEQ_LI := EIT->EIT_SEQ_LI
      Work_EIT->EIT_PGI_NU := EIT->EIT_PGI_NU
      Work_EIT->EIT_RECNO  := EIT->(RECNO())//FSY - 30/09/2013 - campo para gravar o recno da base EIT
      Work_EIT->EIT_WKREC  := WORK_EIT->(RECNO())//FSY - 30/09/2013 - campo para gravar o recno entre a WORK_EIT e a WORK_TMP
      If EIT->(FieldPos("EIT_TRATA")) # 0 .AND. EIT->(FieldPos("EIT_CDSTA")) # 0 .AND. EIT->(FieldPos("EIT_STAT")) # 0 .AND.;
         EIT->(FieldPos("EIT_DTANU")) # 0 .AND. EIT->(FieldPos("EIT_DTVAL")) # 0 .AND. EIT->(FieldPos("EIT_TEXTO")) # 0  // GFP - 20/02/2015
         Work_EIT->EIT_TRATA := EIT->EIT_TRATA
         Work_EIT->EIT_STAT  := EIT->EIT_STAT
         Work_EIT->EIT_DTANU := EIT->EIT_DTANU
         Work_EIT->EIT_DTVAL := EIT->EIT_DTVAL
      EndIf
      IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"CARREGA_WORK_EIT1"),)   //TRP - 30/11
      
      EIT->( DbSkip() )
   End Do
End If
//*FSY
RETURN cWork_EIT

*-------------------------------------------------------*
Static Function AfterHeader(cAliasWork,aHeader,aSemSX3)
*-------------------------------------------------------*

 Local Item := 1
 Local bCpo  := {||}
 Local aCpos := {}
 Private aNewCampos:={}, aNewHeader:={}//Por causa do rdmake

   Do Case

      Case cAliasWork == "TRB"

         For Item:=1 to LEN(aHeader)
            IF aHeader[Item,2] = "W5_FABR_0"
               LOOP
            ENDIF
            IF Item == 2
               AADD(aNewHeader,{STR0011,"W5_NBMTEC","@!",21,0," ","    ","C","TRB","V"}) //"NBM/TEC/SEQ."
               AAdd(aNewCampos,{"W5_NBMTEC","C",21,0})
            ENDIF

            IF Item == 4
               IIF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"16"),)
               AADD(aNewHeader,{STR0012,"W5_FAMILIA","@!",25,0," ","    ","C","TRB","V"}) //"Familia"
               AAdd(aNewCampos,{"W5_FAMILIA","C",25,0})
            ENDIF

            AADD(aNewCampos,{aHeader[Item,2],aHeader[Item,8],aHeader[Item,4],aHeader[Item,5]})

            AADD(aNewHeader,{ TRIM(aHeader[Item,1]), aHeader[Item,2], aHeader[Item,3],;
                              aHeader[Item,4], aHeader[Item,5], aHeader[Item,6],;
                              aHeader[Item,7], aHeader[Item,8], aHeader[Item,9], aHeader[Item,10] } )

            IF lMV_EIC_EAI//AWF - 22/07/2014
               IF aHeader[Item,2] = "W5_QTDE"
                  AADD(aNewHeader,{AVSX3("W3_UM",AV_TITULO),"W3_UM",AVSX3("W3_UM",6),AVSX3("W3_UM",3),0," ","    ","C","TRB","V"})
                  AAdd(aNewCampos,{"W3_UM","C",AVSX3("W3_UM",3),0})
                  AADD(aNewHeader,{AVSX3("W3_QTSEGUM",AV_TITULO),"W3_QTSEGUM",AVSX3("W3_QTSEGUM",6),AVSX3("W3_QTSEGUM",3),AVSX3("W3_QTSEGUM",4)," ","    ","N","TRB","V"})
                  AAdd(aNewCampos,{"W3_QTSEGUM","N",AVSX3("W3_QTSEGUM",3),AVSX3("W3_QTSEGUM",4)})
                  AADD(aNewHeader,{AVSX3("W3_SEGUM",AV_TITULO),"W3_SEGUM",AVSX3("W3_SEGUM",6),AVSX3("W3_SEGUM",3),0," ","    ","C","TRB","V"})
                  AAdd(aNewCampos,{"W3_SEGUM","C",AVSX3("W3_SEGUM",3),0})
               ENDIF
            ENDIF

         Next Item

         IIF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"BROWSE_VISUALIZAR"),)

         For Item := 1  to  Len(aNewHeader)
            If AScan(aHeader,{|x| x[2] == aNewHeader[Item][2]}) == 0
               AAdd( aSemSX3, aNewCampos[Item] )
            EndIf
         Next Item

         ASize(aHeader,0)
         aHeader    := ACLONE(aNewHeader)


      Case cAliasWork == "Work_TMP"

         bCpo  := {|cCpo| SX3->( DBSeek(cCpo) ), ;
                          AAdd(aSemSx3, {cCpo, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL}) ,;
                          AAdd(aHeader,{Rtrim( SX3->(X3Titulo())),Rtrim( SX3->X3_CAMPO ),SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,"Work_TMP",SX3->X3_CONTEXT}) }
         aCpos := { "EIT_NUMERO", "EIT_ORGAO" }
         SX3->( DBSetOrder(2) )
         AEval(aCpos, {|a| Eval(bCpo, a) })

      Case cAliasWork == "Work_Zoom"

         bCpo  := {|cCpo| SX3->( DBSeek(cCpo) ), ;
                          AAdd(aSemSx3, {cCpo, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL}) ,;
                          AAdd(aHeader,{Rtrim( SX3->(X3Titulo())),Rtrim( SX3->X3_CAMPO ),SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,"Work_TMP",SX3->X3_CONTEXT}) }
         SX3->( DBSetOrder(2) )
         AEval(aUserCpos, {|a| Eval(bCpo, a) })

   EndCase

   aTRBSemSX3 := AClone(aSemSX3)

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GI400RegTri³ Autor ³ Pedro Baroni          ³ Data ³ 06/08/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina para filtro de Fundamentos Legais, de acordo com o   ³±±
±±³          ³ Regime de Tributação                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Boolean GI400RegTri(cRegime)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cRegime = Regime de Tributação atual                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*------------------------------------------------------------------*
Function GI400RegTri(cRegime)
*------------------------------------------------------------------*

 Default cRegime := ""

   M->W4_REGIMP  := Space(Len(M->W4_REGIMP ))
   M->W4_VM_REGI := Space(Len(M->W4_VM_REGI))
   If !Empty(cRegime)
      cFiltroSY8 := ""
      SY8->( DBGoTop() )
      Do While SY8->( !EOF() )
         If SY8->( cRegime == Y8_REG_TRI  .Or.  cRegime == Y8_REGTRI2  )
            If !Empty(cFiltroSY8)
               cFiltroSY8 += ", "
            EndIf
            cFiltroSY8 += SY8->Y8_COD
         EndIf
         SY8->( DBSkip() )
      EndDo
   EndIf


Return .T.
*------------------------------------------------------------*
Static Function HaveConvert(cCodItem,cTipoAC,lMessage)
*------------------------------------------------------------*

 Local lHave := .T.

 Default cCodItem := ""
 Default cTipoAC  := ""
 Default lMessage := .F.

   Begin Sequence

      If !Empty(cCodItem)  .And.  ( !(cTipoAC == GENERICO)  .Or.  !(ED4->ED4_NCM == NCM_GENERICA) )

         If cUnid != ED4->ED4_UMITEM              ;
            .And.  !AvVldUn(ED4->ED4_UMITEM)      ;
            .And.  !AvCanTrans(ED4->ED4_UMITEM,cUnid,cCodItem)

            lHave := .F.
            If lMessage
              MsgInfo(STR0170+Alltrim(ED4->ED4_UMITEM)+STR0192+Alltrim(cUnid)+").")   //"Não é possivel apropriar este item ao Ato Concessorio pois não existe conversão entre a U.M. do Pedido (" # ") e a U.M. do Item ("
            EndIf
            Break
         EndIf

         If cUnid != ED4->ED4_UMNCM                            ;
            .And.  !AvVldUn(ED4->ED4_UMNCM)                    ;
            .And.  ED4->ED4_UMNCM != ED4->ED4_UMITEM           ;
            .And.  !AvCanTrans(ED4->ED4_UMNCM,cUnid,cCodItem)  ;
            .And.  !AvCanTrans(ED4->ED4_UMNCM,ED4->ED4_UMITEM,cCodItem)

            lHave := .F.
            If lMessage
               MsgInfo(STR0170+Alltrim(ED4->ED4_UMITEM)+STR0193+Alltrim(ED4->ED4_UMNCM)+").") //"Não é possivel apropriar este item ao Ato Concessorio pois não existe conversão entre a U.M. do Pedido (" # ") e a U.M. de Compra ("
            EndIf
            Break
         EndIf

      EndIf

   End Sequence


Return lHave



//*----------------------------------------------------------------------------//
//Programa : CalcTotSeqLI()
//Parâmetro: cModo = PLI ou LI
//Objetivo : Função para calcular e exibir total FOB e Peso Total, armazenados
//		   na Work para cada Sequencia de LI por Nº P.L.I.
//Autor    : Bruno Henrique R. Fonsatte. **BHF**
//Data/Hora: 30/07/08 - 09:33
//Revisão  :
//Obs      :
//------------------------------------------------------------------------------*/
*-------------------------------------
Static Function CalcTotSeqLI(cModo)
*-------------------------------------
Local oDlgSeq

Local bOk := {||oDlgSeq:End()}
Local bCancel := {||oDlgSeq:End()}

Local _PictPeso := "@E 99999,999,999,999.9999999"
Local _PictPGI  := ALLTRIM(X3PICTURE("W4_PGI_NUM"))
Local _Ncm := ALLTRIM(X3PICTURE("W5_TEC"))

Local cSeqLI
Local cNcm
Local cTot := STR0082 //'Total PLI'
Local cNPLI := M->W4_PGI_NUM //"No. P.L.I"
Local nPesoTot := CriaVar("W5_PESO")
Local nPrecoTotPLI := CriaVar("W5_PRECO")


nPrecoTotPLI := 0
nPesoTot := 0

Do Case
Case cModo == "PLI"
   cSeqLI := Work->WKSEQ_LI

   cNcm   := Work->WKTEC
   Work->(DbGoTop())
   While Work->(!EOF())
      If cSeqLI == Work->WKSEQ_LI
         nPrecoTotPLI += Work->WKQTDE * Work->WKPRECO
         nPesoTot += Work->WKQTDE * Work->WKPESO_L
      EndIf
      Work->(DbSkip())
   EndDo
   Work->(DbGoTop())
Case cModo == "LI"
   cSeqLI := TRB->W5_SEQ_LI
   cNcm   := TRB->W5_NBMTEC
   TRB->(DbGoTop())
   While TRB->(!EOF())
      If cSeqLI == TRB->W5_SEQ_LI
         nPrecoTotPLI += TRB->W5_QTDE * TRB->W5_PRECO
         nPesoTot += TRB->W5_QTDE * TRB->W5_PESO
      EndIf
      TRB->(DbSkip())
   EndDo
   TRB->(DbGoTop())
EndCase

Define MsDialog oDlgSeq Title  STR0303  From 20,30 To 38,80 of oMainWnd // - BHF - 16/10/08 - Alinhamento MDI // STR0303 "Totais da LI"

 @35,10  Say STR0068  of oDlgSeq Pixel //"No. P.L.I "
 @55,10  Say STR0084 of oDlgSeq Pixel  //"No. Seq.LI"
 @75,10  Say STR0085  of oDlgSeq Pixel //"No. NCM"
 @95,10 Say cTot + MMoeda of oDlgSeq Pixel //FOB Total
 @115,10 Say STR0092  of oDlgSeq Pixel //'Peso Total'

 @35,48  MsGet oCnpli Var cNPLI PICT _PictPgi Size 60,8 of oDlgSeq Pixel //"No. P.L.I"
 oCnpli:lReadOnly := .T.
 @55,48  MsGet oCSeqLI Var cSeqLI  Size /*35*/60,8 of oDlgSeq Pixel //"Seq.LI"
 oCSeqLI:lReadOnly := .T.
 @75,48  MsGet oCncm Var cNcm PICT _Ncm Size /*40*/60,8 of oDlgSeq Pixel //"NCM"
 oCncm:lReadOnly := .T.
 @95,48 MsGet OTotPLI Var nPrecoTotPLI PICT cPictFob Size /*44*/60,8 of oDlgSeq Pixel //"Total PLI"
 OTotPLI:lReadOnly := .T.
 @115,48 MsGet oPesoTot Var nPesoTot PICT cPictPeso  Size /*40*/60,8 of oDlgSeq Pixel //"Peso Total"
 oPesoTot:lReadOnly := .T.

Activate MsDialog oDlgSeq on init EnchoiceBar(oDlgSeq,bOk,bCancel) Centered

Return Nil


//*----------------------------------------------------------------------------//
//Programa : ElimSaldo
//Parâmetro: cAlias - Alias da mBrowse que chamou a função
//Objetivo : Chamada das funções para controle de eliminação de saldo de LI
//Autor    : Anderson Soares Toledo
//Data     : 10/02/09
//Revisão  :
//Obs      :
//------------------------------------------------------------------------------*/
Function ElimSaldo(cAlias)
   Local cFile
   Local cMarca := getMark()
   Local cPLI := (cAlias)->WP_PGI_NUM
   Local cSeqLI := (cAlias)->WP_SEQ_LI

   Private aCampos := {}, aHeader := {}
   Private aElimina := {}, aNaoElimina := {}  // GFP - 12/03/2013

   CriaWork(@cFile) // Cria o arquivo de trabalho WK_LI
   PreencheWork(cPLI,cMarca,cSeqLI) // Adiciona os registros na work

   If !(WK_LI->(BOF()) .And. WK_LI->(EOF()))
      DlgElimSaldo(cMarca, cPLI) // Exibe tela para manutenção de saldo das LI's
   Else
      //msgInfo(STR0230) // Não existem registros com saldo.
      msgInfo(STR0288 + Alltrim(cPLI) + STR0289) //STR0288 "Não existem registros com saldo, ou nenhum item da LI: "  STR0289 " está embarcado."
   EndIf

   WK_LI->(E_EraseArq(cFile))

return

//*----------------------------------------------------------------------------//
//Programa : criaWork
//Parâmetro: cFile - nome do arquivo que será criada a work (passado por referencia)
//Objetivo : Criar um arquivo de trabalho
//Autor    : Anderson Soares Toledo
//Data     : 10/02/09
//Revisão  :
//Obs      :
//------------------------------------------------------------------------------*/
Static Function CriaWork(cFile)
   Local aEstru :=  {{"WK_FLAG"   ,"C", 2                    ,0},;
                     {"WK_PO_NUM" ,"C", AvSX3("W5_PO_NUM",3) ,0},;
                     {"WK_COD_I"  ,"C", AvSX3("W5_COD_I",3)  ,0},;
                     {"WK_QTDE"   ,"N", AvSX3("W5_QTDE",3)   ,AvSX3("W5_QTDE",4)},;
                     {"WK_SALDO_Q","N", AvSX3("W5_SALDO_Q",3),AvSX3("W5_SALDO_Q",4)},;
                     {"WK_DT_EMB" ,"D", 8                    ,0},;
                     {"WK_DT_ENTR","D", 8                    ,0},;
                     {"WK_RECNO"  ,"N", 8                    ,0}}

   aEstru:= AddWkCpoUser(aEstru,"SW5") //LRS 29/12/2014

   cFile := E_CriaTrab(,aEstru,"WK_LI")

return

//*----------------------------------------------------------------------------//
//Programa : PreencheWork
//Parâmetro: cPLI   - Nª da PLI que deseja obter os dados da SW5
//           cMarca - caracter obtido através da função getMark
//Objetivo : Preencher a work com os itens da LI que tenham saldo
//Autor    : Anderson Soares Toledo
//Data     : 10/02/09
//Revisão  :
//Obs      :
//------------------------------------------------------------------------------*/
Static Function PreencheWork(cPLI,cMarca,cSeqLI)
   Local aOrd := SaveOrd("SW5")

    #IFDEF TOP
       Local cQry

       cQry := "select W5_PO_NUM, W5_COD_I, W5_QTDE, W5_SALDO_Q, W5_DT_EMB, W5_DT_ENTR, R_E_C_N_O_"
       cQry += " from "+RetSqlName("SW5")
       cQry += " where W5_SALDO_Q > 0 And W5_PGI_NUM = '"+cPLI+"' And W5_SEQ_LI = '"+cSeqLI+"' And W5_Filial = '"+xFilial("SW5")+"' And W5_SEQ = 0"
       //cQry += " And W5_SALDO_Q <> W5_QTDE"   //TRP-05/05/09- Não carregar itens que não foram embarcados. Nopado por RRV - 05/10/2012
       If TcSrvType() <> "AS/400"
          cQry += " And D_E_L_E_T_<>'*'"
       Else
          cQry += " And @DELETED@<>'*'"
       EndIf

       cQry := ChangeQuery(cQry)
       DbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"Qry",.F.,.T.)

       While Qry->(!EOF())
          WK_LI->(dbAppend())
//        WK_LI->WK_FLAG    := cMarca      //SSS -  REG 4.5 03/06/14
          WK_LI->WK_PO_NUM  := Qry->W5_PO_NUM
          WK_LI->WK_COD_I   := Qry->W5_COD_I
          WK_LI->WK_QTDE    := Qry->W5_QTDE
          WK_LI->WK_SALDO_Q := Qry->W5_SALDO_Q
          WK_LI->WK_DT_EMB  := sTod(Qry->W5_DT_EMB)
          WK_LI->WK_DT_ENTR := sTod(Qry->W5_DT_ENTR)
          WK_LI->WK_RECNO   := Qry->R_E_C_N_O_
          Qry->(dbSkip())
       EndDo

       Qry->(dbCloseArea())
    #ELSE
       Local cFiltro
       Private bFiltro

       cFiltro := "W5_SALDO_Q > 0 .And. W5_PGI_NUM == '"+cPLI+"' .And. W5_SEQ_LI = '"+cSeqLI+"' .And. W5_FILIAL == '"+xFilial("SW5")+"' .And. W5_SEQ == 0 .And. W5_SALDO_Q <> W5_QTDE"
       bFiltro := &("{||"+cFiltro+"}")

       SW5->(dbSetFilter(bFiltro, cFiltro ))
       SW5->(dbGoTop())

       While SW5->(!EOF())
          WK_LI->(dbAppend())
          WK_LI->WK_FLAG    := cMarca
          WK_LI->WK_PO_NUM  := SW5->W5_PO_NUM
          WK_LI->WK_COD_I   := SW5->W5_COD_I
          WK_LI->WK_QTDE    := SW5->W5_QTDE
          WK_LI->WK_SALDO_Q := SW5->W5_SALDO_Q
          WK_LI->WK_DT_EMB  := SW5->W5_DT_EMB
          WK_LI->WK_DT_ENTR := SW5->W5_DT_ENTR
          WK_LI->WK_RECNO   := SW5->(Recno())
          SW5->(dbSkip())
       EndDo

       SW5->(dbClearFilter())
    #ENDIF

    RestOrd(aOrd)
Return

//*----------------------------------------------------------------------------//
//Programa : DlgElimSaldo
//Parâmetro: cMarca - caracter obtido através da função getMark
//           cPLI   - Nª da PLI que deseja obter os dados da SW5
//Objetivo : Apresentar tela com com os itens com saldo, para o usuário selecionar
//           quais itens deseja eliminar o saldo da LI e eliminar o residuo no Compras, quando integrado
//Autor    : Anderson Soares Toledo
//Data     : 10/02/09
//Revisão  :
//Obs      :
//------------------------------------------------------------------------------*/
Static Function DlgElimSaldo(cMarca,cPLI)
   Local oDlg, oMark,i
   Local aCposBrowse := {}
   Local bOk := {|| lOk := .T.,oDlg:End()}
   Local bCancel := {|| oDlg:End()}
   Local lOk := .F.
   Local aOrd
   Local aPos := {0,0,DLG_LIN_FIM/2,DLG_COL_FIM-150}
   Local cEmissao,cPedido,cProduto,cForn // Utilizados para a chamada da função MA235PC, elimina residuos no compras
   Local lCompras := EasyGParam("MV_EASY",,"N") $ "S" // Verifica se está integrado com o módulo de compras
   Local aRecSC7 := {} //MCF - 12/05/2016 - Parâmetro novo utilizado na função MA235PC


   PRIVATE lMT235G1//Variavél declarada para uso da rotina MA235PC, não utilizada no Easy.

   aAdd(aCposBrowse,{"WK_FLAG"   ,,})
   aAdd(aCposBrowse,{"WK_PO_NUM" ,,STR0231}) //nº PO
   aAdd(aCposBrowse,{"WK_COD_I"  ,,STR0232}) //Cód. Item
   aAdd(aCposBrowse,{"WK_QTDE"   ,,STR0233,AvSX3("W5_QTDE"   ,6)}) //Quantidade
   aAdd(aCposBrowse,{"WK_SALDO_Q",,STR0234,AvSX3("W5_SALDO_Q",6)}) //Saldo
   aAdd(aCposBrowse,{"WK_DT_EMB" ,,STR0235}) //Dt. Embarque
   aAdd(aCposBrowse,{"WK_DT_ENTR",,STR0236}) //Dt. Entrega

   WK_LI->(dbGoTop())

   DEFINE MSDIALOG oDlg TITLE STR0237+" - "+alltrim(cPLI) FROM 0,0 To aPos[3]+5,aPos[4] Pixel //Saldo da Li - ###

      //GFP 20/10/2010
      aCposBrowse := AddCpoUser(aCposBrowse,"SW5","2")

      oMark := MsSelect():New("WK_LI","WK_FLAG",,aCposBrowse,@lInverte,@cMarca,{aPos[1]+31,aPos[2]+2,aPos[3]/2,aPos[4]/2})

      oMark:bAval:={||GI400_Marca(cMarca), oMark:oBrowse:Refresh()}   //SSS -  REG 4.5 03/06/14

   Activate MSDIALOG oDlg on Init EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   If lOk
      If apMsgYESNO(STR0240) //Deseja realmente eliminar os saldos dos itens selecionados?
         aOrd := SaveOrd({"SW2","SW5"})
         lMT235G1 := EasyEntryPoint("MT235G1") // utilizada na função MA235PC

         SW2->(dbSetOrder(1))
         SW3->(dbSetOrder(1))

         aElimina := {}
         aPedidos := {}
         WK_LI->(dbGoTop())
         While WK_LI->(!EOF())
            If WK_LI->WK_FLAG == cMarca
               SW5->(dbGoTo(WK_LI->WK_RECNO))
               RecLock("SW5",.F.)
               SW5->W5_SALDO_Q := 0
               MsUnlock("SW5")

               If ascan(aPedidos,WK_LI->WK_PO_NUM + SW5->W5_POSICAO)  = 0
                  aAdd(aPedidos,WK_LI->WK_PO_NUM + SW5->W5_POSICAO) //SSS -  REG 4.5 03/06/14
               EndIf

               If lCompras
                  SW2->(dbSeek(xFilial("SW2")+SW5->W5_PO_NUM))

                  cEmissao := SW2->W2_PO_DT
                  cPedido  := SW2->W2_PO_SIGA
                  cForn    := SW2->W2_FORN
                  cProduto := SW5->W5_COD_I

                  MA235PC(100,1,cEmissao,cEmissao,cPedido,cPedido,cProduto,cProduto,cForn,cForn,,,,,.F.,aRecSC7) //Elimina Residuo no SIGACOM //MCF - 12/05/2016

                  // GFP - 12/03/2013 - Elimina saldo do PO
                  SW2->(DbSeek(xFilial("SW2")+SW5->W5_PO_NUM))
                  SW3->(DbSeek(xFilial("SW3")+SW5->W5_PO_NUM))
                  Do While SW3->(!Eof()) .AND. SW3->W3_FILIAL == xFilial("SW3") .AND. SW3->W3_PO_NUM == SW5->W5_PO_NUM
                     If WK_LI->WK_COD_I == SW3->W3_COD_I
                        aAdd(aElimina, {SW3->W3_POSICAO,WK_LI->WK_SALDO_Q})  // GFP - 19/03/2013
                        Exit
                     EndIf
                     SW3->(DbSkip())
                  EndDo
                  POZERASLDMANUT(.T.)
               Else //AWF - 04/06/2014 - Ficou no ELSE por que na integracao com o compras o campo W3_SLD_ELI já esta sendo gravado
                  SW3->(dbSetOrder(8))
                  SW3->(DbSeek(xFilial("SW3")+SW5->W5_PO_NUM+SW5->W5_POSICAO))   //SSS -  REG 4.5 03/06/14
                  Do While SW3->(!Eof()) .AND. SW3->W3_FILIAL == xFilial("SW3") .AND. SW3->W3_PO_NUM == SW5->W5_PO_NUM  .AND. SW3->W3_POSICAO == SW5->W5_POSICAO
                     If SW3->W3_SEQ = 0
                        SW3->(RecLock("SW3",.F.))
                        SW3->W3_SLD_ELI := SW3->W3_SLD_ELI + WK_LI->WK_SALDO_Q
                        SW3->(MsUnlock())
                     ElseIf SW5->W5_PGI_NUM == SW3->W3_PGI_NUM
                        SW3->(RecLock("SW3",.F.))
                        SW3->W3_SLD_ELI := WK_LI->WK_SALDO_Q
                        SW3->(MsUnlock())
                     EndIf
                     SW3->(DbSkip())
                  EndDo
               EndIf
            EndIf
            WK_LI->(dbSkip())
         EndDo
         SW3->(dbSetOrder(1))
         RestOrd(aOrd,.T.)

         IF AvFlags("EIC_EAI")
            cPos:=""
            /* Verifica se existem pedidos originados por processo de entreposto e
               retorna os pedidos válidos para a geração da programação de entregas*/
            aPedidos:= PO420PedOri(aPedidos)
            For i = 1 To Len(aPedidos) //SSS -  REG 4.5 03/06/14
                If !EICPO420(.T.,4,,"SW2",.F.,aPedidos[I])// EICPO420(lEnvio,nOpc,aCab,cAlias,lWk,cPo_num)
                   cPos+=ALLTRIM(aPedidos[I])+", "
                EndIf
             Next
             If Empty(cPos)
                MsgInfo(STR0238) //Saldo eliminado com sucesso
             Else
                MsgInfo("Acesse os Purchase orders "+cpos+" para realização dos ajustes necessários.")
             EndIf
         Else
             MsgInfo(STR0238) //Saldo eliminado com sucesso
         EndIf
      EndIf
   EndIf

return

/*
Função....: Busca_UMNCM()
Autor.....: Caio César Henrique
Descrição.: Busca Unidade de Medida da NCM para um Produto Específico
Data......: 23/04/2009
Parâmetros: - cChave - Chave de Busca por Produto
Retorno...: Unidade de Medida da NCM de um Produto
*/

Static Function Busca_UMNCM(cChave)

Local nTamPRD  := AVSX3("B1_COD",3)
Local lProdOk  := .F.
Local cNCM     := ""
Local cUnidNCM := ""
Local cRetorno := ""

SB1->(DbSetOrder(1))
SYD->(DbSetOrder(1))

lProdOk := SB1->(DbSeek(xFilial("SB1")+SubStr(cChave,1,nTamPRD)))

If lProdOK
   cNCM := Alltrim(SB1->B1_POSIPI)
   If SYD->(DbSeek(AvKey(xFilial("SYD"),"YD_FILIAL")+AvKey(cNCM,"YD_TEC")))
      cUnidNCM := Alltrim(SYD->YD_UNID)
   Else
      MsgStop( STR0290 +Alltrim(SB1->B1_COD)) //STR0290 "Não foi localizada a NCM do Produto: "
   EndIf
Else
   MsgStop( STR0291 +Alltrim(SB1->B1_COD)) //STR0291 "Produto não localizado no Cadastro de Produtos: "
EndIf

cRetorno := If (!Empty(cUnidNCM),cUnidNCM,"")

Return cRetorno

//*--------------------------------------------------------------------------------//
//Programa : GI400HabAladi()
//Objetivo : Habilitar o campo WP_ALADI (Aladi) na Alteração de L.I. quando o acordo
//           tarifário for ALADI
//Autor    : Caio César Henrique
//Data     : 03/08/2009
//Revisão  :
//Obs      :
//---------------------------------------------------------------------------------*/

Function GI400HabAladi()

Local lWhen := .F.
Local cPLI := ""
Local aOrd := SaveOrd({"SX3","SW4"})

SX3->(DbSetOrder(2))
SW4->(DbSetOrder(1))

cPLI := Posicione("SW4",1,xFilial("SW4")+SWP->WP_PGI_NUM,"W4_PGI_NUM")

If SW4->(FieldPos("W4_ACO_TAR")) # 0 .and. SX3->(DbSeek(AvKey("W4_ACO_TAR","X3_CAMPO")))

   If SW4->(DbSeek(xFilial("SW4")+Alltrim(cPLI))).and. SW4->W4_ACO_TAR == "2"
      lWhen := .T.
   EndIf

Else

   Alert(STR0292)//STR0292 "Campo W4_ACO_TER não existente na Base!"

EndIf

RestOrd(aOrd,.T.)

Return lWhen

//*--------------------------------------------------------------------------------//
//Programa : GI400BuscaAcordo(cTipo)
//Parâmetro: cTipo = Tipo de acordo - Naladi/Aladi
//Objetivo : Buscar o código Aladi/Naladi de acordo com NCM/L.I./Inclusão/Alteração
//Autor    : Caio César Henrique
//Data     : 03/08/2009
//Revisão  :
//Obs      :
//---------------------------------------------------------------------------------*/

Static Function GI400BuscaAcordo(cTipo,cModo)

Local cAcordo := ""
Local aOrd := SaveOrd({"SW4","SWP"})

SWP->(DbSetOrder(1))

Do Case

   Case cTipo == "ALADI"

      If cModo <> Nil .and. cModo == INCLUSAO
         If M->W4_ACO_TAR # "2"
            cAcordo := Space(Len("W4_ACO_TAR"))
            Return cAcordo
         Else
            cAcordo := SYD->YD_ALADI
         EndIf
      Else
         If cModo == ALTERACAO
            If M->W4_ACO_TAR # "2"
               cAcordo := Space(Len("W4_ACO_TAR"))
               Return cAcordo
            Else
               cAcordo := Posicione("SWP",1,xFilial("SWP")+SW4->W4_PGI_NUM,"WP_ALADI")
            EndIf
         EndIf
      EndIf

   Case cTipo == "NALADI"

      If cModo <> Nil .and. cModo == INCLUSAO
         cAcordo := If(!Empty(SYD->YD_NAL_SH),SYD->YD_NAL_SH,SYD->YD_NALADI)
      Else
         If cModo == ALTERACAO
            cAcordo := Posicione("SWP",1,xFilial("SWP")+SW4->W4_PGI_NUM,"WP_NAL_SH")
            If Empty(cAcordo)
               cAcordo := Posicione("SWP",1,xFilial("SWP")+SW4->W4_PGI_NUM,"WP_NALADI")
            EndIf
         EndIf
      EndIf

End Case

RestOrd(aOrd,.T.)

Return cAcordo

//DRL - 16/09/09 - Invoices Antecipadas
*===========================*
Static Function GI400SelInv()
*===========================*
While .T.
	TInv_Ant :=Space(Len(EW4->EW4_INVOIC))
	TForn_Inv:=Space(Len(EW4->EW4_FORN))
	If EICLoja()
	   TFornInvLoj:= Space(Len(EW4->EW4_FORLOJ))
	EndIf
	nOpca:=0
	//
//	Define MsDialog oDlgInv Title "Seleção de Invoice Antecipada" From 9,0 To 18,45 Of oMainWnd//GetWndDefault()
	Define MsDialog oDlgInv Title STR0293 From 9,0 To 21,50 Of oMainWnd//GetWndDefault()//ACB - 13/01/2011 - aumento da tela para que o botão confirmar não seja cortado//STR0293 "Seleção de Invoice Antecipada"

	oPanel:= TPanel():New(0, 0, "", oDlgInv,, .F., .F.,,, 90, 165)
	oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

	@ 2.4,0.8 Say   STR0294  Size 40,8 Of oPanel //STR0294 "Inv.antecipada"
	@ 2.4,08 MsGet TInv_Ant F3 "EW4_1" Picture "@!"  Of oPanel Size 80,10//VALID GI400ValInv()
	Activate MsDialog oDlgInv ;
				On Init	EnchoiceBar(oDlgInv,;
											{|| If(GI400ValInv(),(nOpca:=1,oDlgInv:End()),)},;
											{|| nOpca:=0,oDlgInv:End()}) Centered
	If nOpca == 0
		nBasePLI := 0
		TInv_Ant := Space(Len(EW4->EW4_INVOIC))
		Return .F.
	EndIf
	Exit
EndDo
Return.T.

*===========================*
Static Function GI400ValInv()
*===========================*
Local cFilEW5 := xFilial("EW5"), aPedido := {}

If Empty(TInv_Ant)
	MSGINFO(STR0295) //STR0295 "Invoice não Informada"
	Return .F.
EndIf

EW5->(dbSetOrder(1))
IF !EW5->(DBSEEK(xFilial()+TInv_Ant))
	MSGINFO(STR0296) //STR0296 "Invoice nao Cadastrada."
	RETURN .F.
EndIf
TForn_Inv := EW5->EW5_FORN
If EICLoja()
   TFornInvLoj:= EW5->EW5_FORLOJ
EndIf

While EW5->(!EOF()) .AND.;
		EW5->EW5_FILIAL == cFilEW5 .AND.;
		EW5->EW5_INVOIC == TInv_Ant
	If ASCAN(aPedido,EW5->EW5_PO_NUM) == 0
		If !SW2->(dbSeek(xFilial("SW2")+EW5->EW5_PO_NUM))
			MSGINFO( STR0297 + ALLTRIM(EW5->EW5_PO_NUM)+STR0298) //STR0297 "Pedido: " //STR0298 " nao localizado no SW2. Base desbalanceada!"
			EW5->(dbSkip())
		EndIf
		TPo_Num := EW5->EW5_PO_NUM
		If GI_VALIDPO()
			AADD(aPedido,EW5->EW5_PO_NUM)
		EndIf
	EndIf
	EW5->(dbSkip())
ENDDO

IF LEN(aPedido) == 0
	MSGINFO(STR0299) //STR0299 "Não existem itens para selecao"
	RETURN .F.
EndIf
WORK->(dbGotop())
RETURN .T.

*========================*
Static Function SaldoEW5()
*========================*
Local nQtdePLI := 0, nSaldoEW5 := 0
Local nxOrdEW5 := EW5->(IndexOrd())
Local nxOrdSW5 := SW5->(IndexOrd())
Local nxRecSW5 := SW5->(RecNo())
EW5->(dbSetOrder(2))
IF EW5->(dbSeek(xFilial("EW5")+SW3->W3_PO_NUM+SW3->W3_POSICAO+TInv_Ant+TForn_Inv+IIF(EICLoja(),TFornInvLoj,"")))
	nSaldoEW5 := EW5->EW5_QTDE
EndIf
EW5->(dbSetOrder(nxOrdEW5))
SW5->(dbSetOrder(3))
SW5->(dbSeek(xFilial("SW5") + SW3->W3_PO_NUM + SW3->W3_COD_I))
While !SW5->(EOF()).AND.SW5->W5_PO_NUM	==	SW3->W3_PO_NUM .AND. SW5->W5_COD_I==SW3->W3_COD_I
	If SW5->W5_SEQ		==	0				.AND.;
		SW5->W5_INVANT	==	TInv_Ant		.AND.;
		SW5->W5_FORN	==	TForn_Inv	.AND. IIF(EICLoja(),SW5->W5_FORLOJ==TFornInvLoj,.T.) .AND. ;
		SW5->W5_POSICAO ==	SW3->W3_POSICAO
		nQtdePLI += SW5->W5_QTDE
	EndIf
	SW5->(dbSkip())
EndDo
SW5->(dbSetOrder(nxOrdSW5))
SW5->(dBGoTo(nxRecSW5))
Return (nSaldoEW5 - nQtdePLI)

/*
Função:    GI400OrdOpt
Autor:     Saimon Vinicius Gava
Data:      24/07/2009
Descrição: função para criação do menu para ordenação.
*/
*--------------------------------*
Static Function GI400OrdOpt(oDlg)
*--------------------------------*
Local oMenu

SaveInter()

MENU oMenu POPUP
   MENUITEM STR0300   Action GI400OrdPos("NCM") //STR0300 "Por NCM"
   MENUITEM STR0301   Action GI400OrdPos("ITEM") //STR0301 "Por Código Item"
   MENUITEM STR0201   Action oMenu:End()  //STR0201  "Cancelar"
ENDMENU

//If lComEdit
   If SetMDIChild()
      oMenu:Activate(250,70,oMainWnd)
   Else
      oMenu:Activate(95,150,oMainWnd)
   EndIf
/*Else
   If SetMDIChild()
      oMenu:Activate(370,70,oMainWnd)
   Else
      oMenu:Activate(190,150,oMainWnd)
   EndIf
EndIf
  */
RestInter()

Return Nil

/*
Função:    GI400OrdPos
Autor:     Saimon Vinicius Gava
Data:      09/06/2011
Descrição: Função de ordenação dos itens na tela Usado no botão "Ordena Itens"
*/
*--------------------------------*
Static Function GI400OrdPos(cTipo)
*--------------------------------*

Do Case
   Case cTipo == "NCM"
      WORK->(dbSetOrder(3))
      WORK->(dbGoTop())

   Case cTipo == "ITEM"
      WORK->(dbSetOrder(5))
      WORK->(dbGoTop())
End Case

oMainWnd:Refresh()
oMark:oBrowse:Refresh()

Return .T.
*===========================*
Static Function SwpGrava() // FSM - 12/11/2010 - Grava as informações da tabela SW4 para a SW6:
*===========================*
Local lRet := .F.

Begin Transaction
  If RecLock("SWP",.F.)
     SWP->WP_NAT_LSI := M->W4_NAT_LSI
     SWP->WP_URF_DES := M->W4_URF_DES
     SWP->WP_AC      := M->W4_ATO_CON
     If SWP->(FieldPos("WP_FOB_TOT")) # 0 // GFP - 17/04/2013
        SWP->WP_FOB_TOT := M->W4_FOB_TOT  // GFP - 02/03/2013
     EndIf
     lRet := .T.
     SWP->(MsUnlock())
   EndIf
End Transaction

Return lRet
/*
Função    : ValidOpeGI()
Objetivos : Executa regra de Operação Especial de acordo com o parametro passado
Parametros: cParam - Indica o trecho onde é feito o tratamento de Operação especial
Retorno   : .T. - Caso tenha ocorrido a operação com sucesso
            .F. - Caso não tenha a operação com sucesso
Autor     : Allan Oliveira Monteiro
Revisão   :
Data      : 10/04/2011
*/

Static Function ValidOpeGI(cParam)
Local lRet := .T.

Begin Sequence

   //Verifica se o campo da operação existe
   If !lOperacaoEsp
      Break
   EndIf

   DO CASE

      CASE cParam == "BTN_MK_IT_PLI"

         oOperacao:InitTrans()

         //Verifica se o codigo da operação está preenchido na work, se estiver efetua o estorno
         If !EMPTY(Work->W5_CODOPE) .And. nQual # 3
            If oOperacao:InitOperacao(Work->W5_CODOPE, "SW5", {{"SW5","Work"}}, .F.,.T.,cParam)//Estorno
               Work->W5_CODOPE := ""
               Work->W5_DESOPE := ""
            Else
               lRet := .F.
            EndIf
         EndIf

         If lRet .And. !EMPTY(cCodOpe)
            lRet := oOperacao:InitOperacao(cCodOpe , "SW5", {{"SW5","M"}}, .T.,.T.,cParam)//Inclusão
         EndIf

         oOperacao:EndTrans(lRet)

      CASE cParam == "DESMARCA_IT_PLI"

         If nQual == 3 .And. !Empty(Work->W5_CODOPE)// nQual == 3 - Inclusão
            If oOperacao:InitOperacao(Work->W5_CODOPE, "SW5", {{"SW5","Work"}}    , .F.,.T.,cParam)//Estorno
               Work->W5_CODOPE := ""
               Work->W5_DESOPE := ""
            Else
               lRet := .F.
               Break
            EndIf
         EndIf

      CASE cParam == "MARCATODOS_ITS_PLI"


         If Work->WKFLAG .And. !EMPTY(Work->W5_CODOPE)
            If oOperacao:InitOperacao(Work->W5_CODOPE, "SW5", {{"SW5","Work"}}    , .F.,.T.,cParam)//Estorno
               Work->W5_CODOPE := ""
               Work->W5_DESOPE := ""
            Else
               lRet := .F.
               Break
            EndIf
         EndIf

         If !Work->WKFLAG .And.  !EMPTY(Work->W5_CODOPE)
            If !oOperacao:InitOperacao(Work->W5_CODOPE, "SW5", {{"SW5","Work"}}    , .T.,.T.,cParam)//Estorno
               lRet := .F.
               Break
            EndIf
         EndIf

      CASE cParam == "MARCA_ITS_PLI"

         If !Empty(Work->W5_CODOPE) .And. Work->WKFLAGWIN <> cMarca
            If !oOperacao:InitOperacao(Work->W5_CODOPE, "SW5", {{"SW5","Work"}}    , .T.,.T.,cParam)//Inclusao
               lRet:= .F.
               Break
            EndIf
         ENDIF

         If Empty(Work->W5_CODOPE)  .And. Work->WKFLAGWIN == cMarca
            If oOperacao:InitOperacao(Work->W5_CODOPE, "SW5", {{"SW5","Work"}}    , .F.,.T.,cParam)//Estorno
               Work->W5_CODOPE := ""
               Work->W5_DESOPE := ""
            Else
               lRet := .F.
               Break
            EndIf
         ENDIF

   ENDCASE

End Sequence

Return lRet

/******************************************************************************************
ROTINA     : GI400NVE()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Rotina de Classificação NVE na fase de PLI
Autor      : Nilson César C. Filho (adaptada da rotina de NVE na fase de DI)
Data/Hora  : 03/08/2011
Revisão    :
*******************************************************************************************/
Function GI400NVE(oDlg,nOpc)                //NCF - 03/08/2011

LOCAL   lTemItens:=.F.,T,aPosUp,aPosDn,lMarcado,nRecWk,aHeaBKP,i
LOCAL   aOrd := SaveOrd("SW7")
Local cFiltro := "AllTrim(W5_NVE) == AllTrim(cNVE)", bFiltro := &("{||"+cFiltro+"}")
Local nRegCount:= 0, aOrdTRB
Local bCancNVE := {|| (nSelOp:=0,lOpcCanc:=.T.,oDlg:End()) }
Local bOKNVE   := If( nOpc == 2 , bCancNVE ,   {|| IF( GI400NVEVal("OK"),(nSelOp:=0,oDlg:End()) , ) } )
PRIVATE aForn:={},aPOs:={}		 
PRIVATE cPLI,cPO,cInvoice,oMarkItens,nSelOp
PRIVATE oCboPLI,oCboPO,oInv,oCboFor
PRIVATE aBotaoNVE:={},bBlocSel:={||.T.}
PRIVATE bAtributo:={|| Work_GEIM->EIM_ATRIB == SJL->JL_ATRIB }//AWR - Usado no filtro do SXB do F3 do SJL no EIM_ESPECI
PRIVATE cFiltroSW5 := If(nQual == 3, "!EMPTY(Work->WKFLAGWIN) ","Work->WKFLAG ") + ".AND. ALLTRIM(M->W5_TEC) $ Left(Work->WKTEC, Len(ALLTRIM(M->W5_TEC)))"
PRIVATE cClassif := ""
PRIVATE aWkSW5Bkp := {} , lOpcCanc := .F.
IF !SJK->(DBSEEK(xFilial()))
   MSGSTOP(STR0305)//"Cadastro de Atributos para Valoracao esta vazio: Entre no Menu Atualizacoes/Tabelas Siscomex/Sisccad (Siscomex) e Importe a Opcao Atrib. p/ Valoracao Aduaneira."
   RETURN .F.
ENDIF

If nOpc == 2
   aHeaBKP := aHeader
   GI_Init(@bCloseAll)
EndIf

IF !SJL->(DBSEEK(xFilial()))
   MSGSTOP(STR0306)//"Cadastro de Especificacoes para Valoracao esta vazio: Entre no Menu Atualizacoes/Tabelas Siscomex/Sisccad (Siscomex) e Importe a Opcao Especificacoes p/ Valoracao."
   RETURN .F.
ENDIF

DBSELECTAREA("Work_CEIM")
AvZap("Work_CEIM")

nRecWk := Work->(Recno())
lMarcado := .F.
Work->(DbGoTop())
Do While Work->(!Eof())
   If Work->WKFLAG
      lMarcado := .T.
      Exit
   EndIf
   Work->(DbSkip())
EndDo
Work->(DbGoTop())

If (nOpc == 3 .OR. nOpc == 4) .AND. !lMarcado
   Alert(STR0375) //"Não existem itens marcados para Classificação NVE."
   Return .F.
EndIf

SW7->(DbSetOrder(2)) //W7_FILIAL+W7_PO_NUM+W7_HAWB
IF SW7->(DbSeek(xFilial("SW7")+AvKey(Work->WKPO_NUM,"W7_PO_NUM")))
   DO WHILE SW7->(!Eof()) .AND. SW7->W7_FILIAL == xFilial("SW7") .AND. SW7->W7_PO_NUM == AvKey(Work->WKPO_NUM,"W7_PO_NUM")
      Work->(DbSetOrder(6))
      If Work->(DbSeek(SW7->W7_COD_I))
         EIM->(DbSetOrder(3))
         //MFR 26/11/2018 OSSME-1483
         //IF EIM->(DbSeek(xFilial("EIM")+AvKey("DI","EIM_FASE")+AvKey(SW7->W7_HAWB,"EIM_HAWB")))
         IF EIM->(DbSeek(GetFilEIM("DI")+AvKey("DI","EIM_FASE")+AvKey(SW7->W7_HAWB,"EIM_HAWB")))
            Alert(STR0365)  //"Tabela de NVE deste item não poderá ser alterada, pois o item possui Tabela de NVE vinculada na Fase de Desembaraço."
            RestOrd(aOrd,.T.)
            RETURN .F.  
         EndIf
      EndIf
      SW7->(DBSKIP())
   ENDDO
ENDIF
RestOrd(aOrd,.T.)

IF nOpc == 2
   aOrdTRB := SaveOrd("TRB")
   TRB->(DbGotop())
   EIM->(DbSetOrder(3))
   Work_EIM->(DbSetOrder(3))
   Do While TRB->(!Eof())
      If !Empty(TRB->W5_NVE)
         IF EIM->(DbSeek(GetFilEIM("LI")+AvKey("LI","EIM_FASE")+AvKey(SW4->W4_PGI_NUM,"EIM_HAWB")+AvKey(TRB->W5_NVE,"EIM_CODIGO"))) .And. !Work_EIM->(DbSeek(EIM->(EIM_HAWB+EIM_NIVEL+EIM_CODIGO)))
            DO While !EIM->(Eof()) .AND. EIM->EIM_FILIAL ==  GetFilEIM("LI") .AND. EIM->EIM_FASE == AvKey("LI","EIM_FASE") .AND. EIM->EIM_HAWB == AvKey(SW4->W4_PGI_NUM,"EIM_HAWB") .AND. EIM->EIM_CODIGO == AvKey(TRB->W5_NVE,"EIM_CODIGO")
               Work_EIM->(DBAPPEND())
               AVREPLACE("EIM","Work_EIM")
               EIM->(dbSkip())
            ENDDO   
         ENDIF
      ENDIF
      TRB->(DbSkip())
   ENDDO
   RestOrd(aOrdTRB,.T.)
ElSE
   Work->(DBGOTOP())
   DO WHILE Work->(!EOF())

      IF (nOpc == 3 /*.OR. nOpc == 4*/) .AND. EMPTY(Work->WKFLAGWIN)  //NCF - 23/05/2018 - Na alteração, passar por todos os itens.
         Work->(DBSKIP())
         LOOP
      ENDIF

      IF ASCAN( aPOs, Work->WKPO_NUM ) == 0 .And. Empty(Work->WKNVE)
         AADD ( aPOs, Work->WKPO_NUM )
         cPO:=aPOs[1]
      ENDIF

      IF(EasyEntryPoint("EICGI400"),Execblock("EICGI400",.F.,.F.,"WHILE_SW8_NVES"),)

      IF lCposNVAE .And. !EMPTY(Work->WKNVE) .AND. !Work_CEIM->(DBSEEK(Work->WKNVE))
         Work_CEIM->(DBAPPEND())
         Work_CEIM->EIM_CODIGO:=Work->WKNVE
         Work_CEIM->WKTEC     :=Work->WKTEC

         If nOpc == 4 //NCF - 24/05/2018 - Recarregar a Work para permitir salvar alterações das tabelas na alteração da PLI
            EIM->(DbSetOrder(3))
            Work_EIM->(DbSetOrder(3))
            //MFR 26/11/2018 OSSME-1483
            //IF EIM->(DbSeek(xFilial("EIM")+AvKey("LI","EIM_FASE")+AvKey(SW4->W4_PGI_NUM,"EIM_HAWB")+AvKey(Work->WKNVE,"EIM_CODIGO"))) .And. !Work_EIM->(DbSeek(EIM->(EIM_HAWB+EIM_NIVEL+EIM_CODIGO)))
            IF EIM->(DbSeek(GetFilEIM("LI")+AvKey("LI","EIM_FASE")+AvKey(SW4->W4_PGI_NUM,"EIM_HAWB")+AvKey(Work->WKNVE,"EIM_CODIGO"))) .And. !Work_EIM->(DbSeek(EIM->(EIM_HAWB+EIM_NIVEL+EIM_CODIGO)))
               //DO While !EIM->(Eof()) .AND. EIM->EIM_FILIAL == xFilial("EIM") .AND. EIM->EIM_FASE == AvKey("LI","EIM_FASE") .AND. EIM->EIM_HAWB == AvKey(SW4->W4_PGI_NUM,"EIM_HAWB") .AND. EIM->EIM_CODIGO == AvKey(Work->WKNVE,"EIM_CODIGO")
               DO While !EIM->(Eof()) .AND. EIM->EIM_FILIAL ==  GetFilEIM("LI") .AND. EIM->EIM_FASE == AvKey("LI","EIM_FASE") .AND. EIM->EIM_HAWB == AvKey(SW4->W4_PGI_NUM,"EIM_HAWB") .AND. EIM->EIM_CODIGO == AvKey(Work->WKNVE,"EIM_CODIGO")
                  Work_EIM->(DBAPPEND())
                  AVREPLACE("EIM","Work_EIM")
                  EIM->(dbSkip())
               ENDDO   
            ENDIF
         EndIf

      ENDIF
      aAdd(aWkSW5Bkp,{Work->(Recno()),Work->WKNVE,""}) //NCF - 18/05/2018 - Guardar vinculação original para possível restauração
      Work->(DBSKIP())
   ENDDO
ENDIF

nCol   := 130
nLin   := 4
lNVEInclui:=.F.

aCposMostra:={}
//AADD(aBotaoNVE,{"PREV"    ,{|| IF(GI400TemNVEOK(.T.),(nSelOp:=1,oDlg:End()),) },STR0311 /*"Tabela Anterior"*/,STR0205 /*"Anterior"*/})
//AADD(aBotaoNVE,{"NEXT"    ,{|| IF(GI400TemNVEOK(.T.),(nSelOp:=2,oDlg:End()),) },STR0312 /*"Proxima Tabela"*/ ,STR0203 /*"Proxima"*/ })
AADD(aBotaoNVE,{"NEXT"    ,{|| GI400LegNVE() },STR0366,STR0366}) //"Legendas"
If nOpc == 3 .OR. nOpc == 4
   AADD(aBotaoNVE,{"NEXT"    ,{|| (GI400SelNVE(),oMarkItens:oBrowse:Refresh() ) },STR0317,STR0317}) //"Selecao de Itens"
EndIf
aTelaSW5:=ACLONE(aTela)
aGetsSW5:=ACLONE(aGets)
aTela:={}
aGets:={}
nSelOp:=0
aCamposSW5:={}
If nOpc == 3 .OR. nOpc == 4
   AADD(aCamposSW5,{"WKFLAGWIN" ,,""})
   AADD(aCamposSW5,{"WKNVE"     ,,STR0313 /*"Tab N.V.E."*/})
   AADD(aCamposSW5,{"WKTEC"     ,,AVSX3("W5_TEC"    ,5),AVSX3("W3_TEC",6)})
   AADD(aCamposSW5,{"WKPO_NUM"  ,,AVSX3("W5_PO_NUM" ,5)})
   AADD(aCamposSW5,{"WKCOD_I"   ,,AVSX3("W5_COD_I",5)})
   AADD(aCamposSW5,{"WKPRECO"   ,,AVSX3("W5_PRECO"  ,5)})
   AADD(aCamposSW5,{"WKSALDO_Q" ,,AVSX3("W5_SALDO_Q",5)})
   AADD(aCamposSW5,{"WKCOD_I"   ,,AVSX3("W5_COD_I"  ,5)})
   AADD(aCamposSW5,{"WKFORN"    ,,AVSX3("W5_FORN"   ,5)})  
Else
   AADD(aCamposSW5,{"W5_NVE"     ,,STR0313 /*"Tab N.V.E."*/})
   AADD(aCamposSW5,{"W5_NBMTEC"  ,,AVSX3("W5_TEC"    ,5),AVSX3("W5_TEC",6)})
   AADD(aCamposSW5,{"W5_PO_NUM"  ,,AVSX3("W5_PO_NUM" ,5)})
   AADD(aCamposSW5,{"W5_COD_I"   ,,AVSX3("W5_COD_I",5)})
   AADD(aCamposSW5,{"W5_PRECO"   ,,AVSX3("W5_PRECO"  ,5)})
   AADD(aCamposSW5,{"W5_SALDO_Q" ,,AVSX3("W5_SALDO_Q",5)})
   AADD(aCamposSW5,{"W5_COD_I"   ,,AVSX3("W5_COD_I"  ,5)})
   AADD(aCamposSW5,{"W5_FORN"    ,,AVSX3("W5_FORN"   ,5)})  
EndIf                                                		
aHeader:= {}
SX3->( DBSetOrder(1) )
SX3->( DBSeek("EIM") )
Do While !SX3->(EOF()) .And. SX3->X3_ARQUIVO == "EIM"
   If X3USO(SX3->X3_USADO) .AND. !(AllTrim(SX3->X3_CAMPO) == "EIM_HAWB" .OR. AllTrim(SX3->X3_CAMPO) == "EIM_NIVEL")
      AADD(aHeader,   { TRIM(SX3->X3_TITULO),;
                             SX3->X3_CAMPO,;
                             SX3->X3_PICTURE,;
                             SX3->X3_TAMANHO,;
                             SX3->X3_DECIMAL,;
                             SX3->X3_VALID,;
                             SX3->X3_USADO,;
                             SX3->X3_TIPO,;
                             "Work_GEIM",;
                             SX3->X3_CONTEXT}   )
   EndIF
   SX3->(DbSkip())
EndDO
//** PLB 26/02/07 - Walk-Thru
SX3->( DBSetOrder(2) )
SX3->( DBSeek("EIM_FILIAL") )
cUsado := SX3->X3_USADO
//AAdd( aHeader, { "Alias WT", "EIM_ALI_WT", "", 3,  0, NIL, cUsado, "C", "Work_GEIM", "" } )
//AAdd( aHeader, { "Recno WT", "EIM_REC_WT", "", 10, 0, NIL, cUsado, "N", "Work_GEIM", "" } )
//**
aCpos:={"EIM_ADICAO","EIM_CODIGO","EIM_FASE  "}
If lNVEProduto
   aAdd(aCpos,"EIM_NCM")
EndIf 
nPos :=0
nTam :=LEN(aHeader)-LEN(aCpos)
FOR T := 1 TO LEN(aCpos)//Tira os Campos que nao deve aparecer no MSGETDB
    IF (nPos:=ASCAN(aHeader,{|H|H[2]==aCpos[T]})) # 0
       ADEL(aHeader,nPos)
       ASIZE(aHeader,LEN(aHeader)-1)
    ENDIF
NEXT
IF(nPos#0,ASIZE(aHeader,nTam),)

IF(EasyEntryPoint("EICGI400"),Execblock("EICGI400",.F.,.F.,"COLUNAS_BOTOES_NVES"),)

Work_CEIM->(DBGOTOP())

DO WHILE .T.

   IF nSelOp = 1     // Anterior
      Work_CEIM->(DBSKIP(-1))
      IF Work_CEIM->(BOF())
         Work_CEIM->(DBGOBOTTOM())
      ENDIF
   ELSEIF nSelOp = 2 // Proximo
      Work_CEIM->(DBSKIP())
      IF Work_CEIM->(EOF())
         Work_CEIM->(DBGOTOP())
      ENDIF
   ELSEIF nSelOp = 4 // Exclusao
      Work_CEIM->(DBSKIP(-1))
   ENDIF
      aNVE := GI400VerNVE(nOpc)
      If aNVE[3] == 0
         If nOpc == 2
            GI_Final({||.T.},"TRB")
            aHeader := aHeaBKP
         EndIf
         Return .F.
      Else
         cNVE      := aNVE[1]
         Work_EIM->(DBSETORDER(2)) //Codigo da Nve
         Work_EIM->(DBSEEK(cNVE))
         If nOpc == 3
            M->W5_TEC := aNVE[2]
         Else
            M->W5_TEC := WORK_EIM->EIM_NCM
         EndIf

         If aNVE[3] # 3
            //Work_EIM->(DbGoTop())
            cClassif := Work_EIM->EIM_NIVEL
         Else
            IF GI400GetNCM()
               EXIT
            ENDIF
            cNVE := GI400GerNVE()
            lNVEInclui  := .T.
         EndIf
         If aNVE[3] == 5
            If MsgYesNo(STR0371,STR0370)//"Deseja excluir a NVE vinculada?" ## "Atenção"
               GI400GrvNVE(4,cNVE,M->W5_TEC)
            EndIf
            EXIT
         EndIf
      EndIf
   
   nRegCount:= Work_GEIM->(EasyRecCount("Work_GEIM"))
   If nOpc # 3 .OR. ( nRegCount == 0 .OR. nqual == INCLUSAO)
      GI400GEIMGrv(cNVE)      
   EndIf
   Work_GEIM->(DBGOTOP())

   nPos:=nqual//Verifica se a MS GETDB deve aparecer com um registro em branco ou nao e serao editavel
   IF Work_GEIM->(EasyRecCount("Work_GEIM")) > 0 .AND. nqual == INCLUSAO
      nPos:= ALTERACAO
   ELSEIF Work_GEIM->(EasyRecCount("Work_GEIM")) == 0 .AND. nqual == ALTERACAO
      nPos:= INCLUSAO
   ENDIF
   nSelOp := 0
   aAdvSize := MsAdvSize()
   oMainWnd:ReadClientCoors()

   DEFINE MSDIALOG oDlg TITLE STR0314 +" - "+cNVE FROM 0, 0 TO aAdvSize[6], aAdvSize[5] OF oMainWnd PIXEL

    oPanelTela:= TPanel():New(0,0, "", oDlg, /*Fonte Texto*/, /*se texto no centro*/,/*uParam*/, /*Cor Texto*/, /*Cor fundo*/, /*largura*/, 40/*altura*/)
    oPanelTela:Align:= CONTROL_ALIGN_ALLCLIENT

    oPanelTop:= TPanel():New(0, 0, "", oPanelTela)
    oPanelTop:nHeight := oPanelTela:nClientHeight*0.06
    oPanelTop:Align := CONTROL_ALIGN_TOP

    oPanelLeft:= TPanel():New(0, 0, "", oPanelTela)
    oPanelLeft:Align := CONTROL_ALIGN_LEFT
    oPanelLeft:nWidth := oDlg:nWidth
    oPanelLeft:nHeight := oPanelTela:nClientHeight*0.47

    oPanelBot:= TPanel():New(0, 0, "", oPanelTela)
    oPanelBot:Align := CONTROL_ALIGN_BOTTOM
    oPanelBot:nHeight := oPanelTela:nClientHeight*0.47

      nMeio := /*86*/ 175

      @ 05,05 SAY STR0340 /*"N.C.M."*/ OF oPanelTop PIXEL
      @ 05,35 MSGET M->W5_TEC PICTURE AVSX3("W3_TEC",6) F3 "SJ_" SIZE 45,08 OF oPanelTop PIXEL  WHEN .F.

      @ 05,105 SAY STR0374 OF oPanelTop PIXEL  //"Nível Classif."
      @ 05,145 COMBOBOX oClassif VAR cClassif ITEMS StrTokArr(AllTrim(Posicione("SX3",2,"EIM_NIVEL","X3_CBOX")),";") SIZE 75,08 OF oPanelTop PIXEL PIXEL WHEN .F.

      Work_GEIM->(DbSetOrder(0))
      If nOpc == 3 .OR. nOpc == 4
         oMarkEI:=MsGetDB():New(0, 0, 0, 0 ,nPos,'GI400NVEVal("LINHA")',"","",.T.,,,.F.,,"Work_GEIM",,.F.,   ,oPanelLeft)
      Else
         oMarkEI:=MsGetDB():New(0, 0, 0, 0 ,2   ,''                    ,"","",.F.,,,.F.,,"Work_GEIM",,.F.,.F.,oPanelLeft,,,"")
      EndIf      
      oMarkEI:oBrowse:bwhen:={|| (dbSelectArea("Work_GEIM"),.T.) }
      oMarkEI:ForceRefresh()
      oMarkEI:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

      DBSELECTAREA("Work")
      Work->(DBSETORDER(1))

      // SVG - 13/07/09 -
      If ("CTREE" $ RealRDD())
         Work->(DBEVAL({||;
         If(&(cFiltroSW5),Work->WKFILTRO:="S",Work->WKFILTRO:="")}))
         SET FILTER TO Work->WKFILTRO == "S"
      Else
         SET FILTER TO &(cFiltroSW5)
      EndIf

      If nOpc == 3 .OR. nOpc == 4
         Work->(DBGOTOP())
         IF SetMDIChild()
            nMeio+=10
         ENDIF
         oMarkItens:=MSSELECT():New("Work","WKFLAGWIN",,aCamposSW5,lInverte,cMarca,,,,oPanelBot)
         oMarkItens:oBrowse:bWhen:={|| DBSELECTAREA('Work'),DBSETORDER(1),.T.} 
         oMarkItens:bAval:={|| GI400MarNVE() }
         oMarkItens:obrowse:ACOLUMNS[1]:BDATA:={|| IF(EMPTY(Work->WKNVE),"BR_VERMELHO",IF(Work->WKNVE==cNVE,"BR_AZUL","BR_VERDE")) }
         oMarkItens:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
      Else
         TRB->(dbSetFilter(bFiltro, cFiltro ))
         TRB->(DBGOTOP())
         oMarkItens:=MSSELECT():New("TRB",,,aCamposSW5,,,,,,oPanelBot /*{oPanelTop:nTop,oPanelTop:nWidth,oPanelTop:nBottom,oPanelTop:nHeight}*/  )
      EndIf

      oDlg:lMaximized:=.T.   
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bOKNVE, bCancNVE ,,aBotaoNVE) CENTERED

   IF nSelOp # 0

      IF GI400TemNVEOK(.T.)
         Processa({|| GI400GrvNVE(nSelOp,cNVE) })
      ENDIF

      IF nSelOp = 3 // Inclusao
         lNVEInclui := .T.
      ENDIF

      LOOP
   ELSE
      If lOPcCanc
         For i:=1 To Len(aWkSW5Bkp)
            Work->(DbGoTo(aWkSW5Bkp[i][1]))
            Work->WKNVE := aWkSW5Bkp[i][2]
         Next i
         lOpcCanc := .F.
      EndIf
      aWkSW5Bkp := {} 
   ENDIF

   EXIT

Enddo

Work_EIM->(DBSETORDER(1))
Work->(DBSETORDER(1))
DBSELECTAREA("Work")
SET FILTER TO
aTela:=ACLONE(aTelaSW5)
aGets:=ACLONE(aGetsSW5)
RestOrd(aOrd,.T.)

If nOpc == 2
   GI_Final({||.T.},"TRB")
   aHeader := aHeaBKP
   TRB->(DbClearFilter())
EndIf
Return NIL
*-----------------------------------*
FUNCTION GI400GetNCM()
*-----------------------------------*
LOCAL oDlgNCM,lSair:=.T.,oClassif
Local nLin,nCol
cClassif := Posicione("SJK",1,xFilial("SJK")+AvKey(M->W5_TEC,"JK_NCM"),"JK_NIVEL")

nLin := oMainWnd:nClientHeight * 0.2
nCol := oMainWnd:nClientWidth * 0.2
DEFINE MSDIALOG oDlgNCM TITLE STR0318 FROM 0,0 TO nLin,nCol PIXEL Of oMainWnd //"Manutencao de NVEs" If(SetMDIChild(),50,35)

    nLin := 45
    nCol := 10
    @ nLin+2,nCol SAY STR0340 SIZE 35,10 OF oDlgNCM PIXEL  //"N.C.M"
    nCol += 35
    @ nLin,nCol MSGET M->W5_TEC PICTURE AVSX3("W3_TEC",6) F3 "SJ_" VALID GI400NVEVal("NCM") SIZE 45,10 PIXEL
    
    nLin += 25
    nCol := 10
    @ nLin+2,nCol SAY STR0374 SIZE 35,10 OF oDlgNCM PIXEL  //"Nível Classif."
    nCol += 35
    @ nLin,nCol COMBOBOX oClassif VAR cClassif ITEMS StrTokArr(AllTrim(Posicione("SX3",2,"EIM_NIVEL","X3_CBOX")),";") SIZE 75,10 PIXEL WHEN .F. OF oDlgNCM
                                                       //bOk                                                    //bCancel
ACTIVATE MSDIALOG oDlgNCM ON INIT EnchoiceBar(oDlgNCM, {|| IF(GI400NVEVal("NCM"),(lSair:=.F.,oDlgNCM:End()),) }, {|| (lSair:=.T.,oDlgNCM:End()) }) CENTERED

RETURN lSair
*-----------------------------------*
FUNCTION GI400DelNV()
*-----------------------------------*
IF Work_GEIM->DBDELETE
   RETURN .F.
ENDIF
RETURN .T.
*-------------------------------------*
FUNCTION GI400TemNVEOK(lVerItens,lMSG)
*-------------------------------------*
LOCAL lTemLinha:= .F.,T
LOCAL nRec1 :=Work_GEIM->(RECNO())
LOCAL nRecno:=Work->(RECNO())
LOCAL nOrder:=Work->(INDEXORD())
LOCAL aTab:={}
DEFAULT lVerItens := .T.
DEFAULT lMSG := .T.

SJL->(DBSETORDER(1))//JL_FILIAL+JL_NCM+JL_ATRIB+JL_ESPECIF
Work_GEIM->(DBGOTOP())
DO WHILE Work_GEIM->(!EOF())
   IF Work_GEIM->DBDELETE
      Work_GEIM->(dbSkip())
      LOOP
   ENDIF
   IF EMPTY(Work_GEIM->(EIM_NIVEL+EIM_ATRIB+EIM_ESPECI))
      Work_GEIM->(dbSkip())
      LOOP
   ENDIF
   cTECSeek:=M->W5_TEC
   nTamTEC:=LEN(M->W5_TEC)
   FOR T := 1 TO nTamTEC
       IF !SJL->(DBSEEK(xFilial()+cTECSeek))
          cTECSeek:=LEFT(M->W5_TEC,nTamTEC-T)+SPACE(T)
       ELSE
          EXIT
       ENDIF
   NEXT
   IF ASCAN(aTab,Work_GEIM->(EIM_NIVEL+EIM_ATRIB)) = 0
      AADD(aTab,Work_GEIM->(EIM_NIVEL+EIM_ATRIB))
   ELSE
      If Posicione('SJK',1,xFilial("SJK")+AvKey(Work_GEIM->EIM_NCM,"JK_NCM")+AvKey(Work_GEIM->EIM_ATRIB,"JK_ATRIB"),'JK_MULTIPL') == 'N'
         MSGSTOP(STR0319) //"Atributo não pode ser duplicado."  
         Work_GEIM->(DBGOTO(nRec1))
         Return .F.
      EndIf
   ENDIF
   IF !SJL->(DBSEEK(xFilial()+cTECSeek+AvKey(Work_GEIM->EIM_ATRIB,"JL_ATRIB")+AvKey(Work_GEIM->EIM_ESPECI,"JL_ESPECIF")))
      MSGSTOP(STR0320 /*"NCM nao possui essa NVE: "*/+cTECSeek+Work_GEIM->(EIM_ATRIB+EIM_ESPECI)+ STR0321 )/*" no Cadastro de Especificacoes para Valoracao."*/
      Work_GEIM->(DBGOTO(nRec1))
      RETURN .F.
   ELSEIF SJL->JL_NIVEL # Work_GEIM->EIM_NIVEL
      MSGSTOP(STR0322 /*"NCM nao possui esse Nivel: "*/+Work_GEIM->EIM_NIVEL,STR0323 /*"Nivel da NCM atual: "*/+SJL->JL_NIVEL)
      Work_GEIM->(DBGOTO(nRec1))
      Return .F.
   ENDIF
   lTemLinha:= .T.
   Work_GEIM->(dbSkip())
ENDDO
Work_GEIM->(DBGOTO(nRec1))

IF !lTemLinha
   IF lMSG
      MSGSTOP(STR0324) /*"Preencha as N.V.E.'s."*/
   ENDIF
   RETURN .F.
ENDIF

IF lVerItens
   Work->(DBSETORDER(7))
   IF !Work->(DBSEEK(cNVE))
      MSGSTOP(STR0325) //"Nao existem itens marcados para essa NVE."
      Work->(DBSETORDER(nOrder))
      Work->(DBGOTO(nRecno))
      Return .F.
   ENDIF
   Work->(DBSETORDER(nOrder))
   Work->(DBGOTO(nRecno))
ENDIF

Work_GEIM->(DBGOTOP())

Return .T.

*-----------------------------------*
FUNCTION GI400GerNVE()
*-----------------------------------*
LOCAL nCodigo:=1
Work_EIM->(DBSETORDER(2))
DO WHILE Work_EIM->(DBSEEK(STRZERO(nCodigo,3)))
   nCodigo++
ENDDO
Work_EIM->(DBSETORDER(1))
Return STRZERO(nCodigo,3)

*-----------------------------------*
FUNCTION GI400MarNVE()
*-----------------------------------*
IF !GI400NVEVal("MARCA")   
   If !(ALLTRIM(M->W5_TEC) $ Left(Work->WKTEC, Len(ALLTRIM(M->W5_TEC)))) 
      //Work->WKADICAO:=""
      Work->WKNVE   :=""
      //GI400Controle(1)
   ENDIF
   RETURN .F.
ENDIF

IF EMPTY(Work->WKNVE)
   Work->WKNVE := cNVE
ELSEIF Work->WKNVE == cNVE
   Work->WKNVE := ""
ELSE
   Work->WKNVE := cNVE
ENDIF
//Work->WKADICAO:=""
//GI400Controle(1)

Return .T.

*---------------------------------------------------------------------------------------------------------*
FUNCTION GI400NVEVal(cCampo,cChave)
*---------------------------------------------------------------------------------------------------------*
LOCAL nRecno,nOrder,T
LOCAL aTab:={}
LOCAL lRet := .T.

If Type("lCposNVAE") == "U"
   lCposNVAE := (EIM->(FIELDPOS("EIM_FASE")) # 0 .And. SW5->(FIELDPOS("W5_NVE")) # 0 .And. GetMV("MV_EIC0011",,.F.) )
EndIf

IF cCampo == "OK"

   IF EMPTY(M->W5_TEC) .AND. !GI400TemNVEOK(.F.,.F.)
      Return .T.
   ENDIF

   IF !GI400TemNVEOK(.T.)
      RETURN .F.
   ENDIF

   IF !GI400NVEVal("LINHA")
      RETURN .F.
   ENDIF

   Processa({|| GI400GrvNVE(nSelOp,cNVE) })

ELSEIF cCampo == "NCM"

// IF EMPTY(M->W5_TEC) .AND. !GI400TemNVEOK(.F.,.F.)
//    Return .T.
// ENDIF

   IF EMPTY(M->W5_TEC)
      MSGSTOP(STR0326) //"NCM nao preenchida."
      Return .F.
   ENDIF

   SJK->(DBSETORDER(1))
   IF !SJK->(DBSEEK(xFilial()+M->W5_TEC))
      MSGSTOP(STR0327)//"NCM nao encontrada no Cadastro de Atributos para Valoracao."
      Return .F.
   ENDIF
   
   cClassif := SJK->JK_NIVEL

   nRecno:=Work->(RECNO())
   nOrder:=Work->(INDEXORD())
   DBSELECTAREA("Work")
   SET FILTER TO
   Work->(DBSETORDER(3))
   IF !Work->(DBSEEK(ALLTRIM(M->W5_TEC)))
      MSGSTOP(STR0328)//"NCM nao encontrada nos itens deste PO."
      Work->(DBSETORDER(nOrder))
      Work->(DBGOTO(nRecno))
      Return .F.
   ELSEIF !Work->WKFLAG
      Alert(STR0375) //"Não existem itens marcados para Classificação NVE."
      Work->(DBSETORDER(nOrder))
      Work->(DBGOTO(nRecno))
      Return .F.
   ENDIF
   Work->(DBSETORDER(nOrder))
   Work->(DBGOTO(nRecno))

ELSEIF cCampo == "MARCA"

   IF EMPTY(M->W5_TEC)
      MSGSTOP(STR0326)//"NCM nao preenchida."
      Return .F.
   ENDIF
     
   If !(ALLTRIM(M->W5_TEC) $ Left(Work->WKTEC, Len(ALLTRIM(M->W5_TEC)))) 
      MSGSTOP(STR0329)//"NCM selecionada difere do Item."
      Return .F.
   ENDIF

   IF !GI400TemNVEOK(.F.)
      Return .F.
   ENDIF

ELSEIF cCampo == "LINHA"

   IF Work_GEIM->DBDELETE
      RETURN .T.
   ENDIF
   IF EMPTY(Work_GEIM->(EIM_NIVEL+EIM_ATRIB+EIM_ESPECI))
      MSGSTOP(STR0330)//"Preencha os campos ou precione 'DEL' na linha atual."
      Return .F.
   ENDIF
   SJL->(DBSETORDER(1))//JL_FILIAL+JL_NCM+JL_ATRIB+JL_ESPECIF
   cTECSeek:=M->W5_TEC
   nTamTEC:=LEN(M->W5_TEC)
   FOR T := 1 TO nTamTEC
       IF !SJL->(DBSEEK(xFilial()+cTECSeek))
          cTECSeek:=LEFT(M->W5_TEC,nTamTEC-T)+SPACE(T)
       ELSE
          EXIT
       ENDIF
   NEXT
   IF !SJL->(DBSEEK(xFilial()+cTECSeek+AvKey(Work_GEIM->EIM_ATRIB,"JL_ATRIB")+AvKey(Work_GEIM->EIM_ESPECI,"JL_ESPECIF")))
      MSGSTOP(STR0331)//"NCM nao possui essa NVE no Cadastro de Especificacoes para Valoracao."
      Return .F.
   ELSEIF SJL->JL_NIVEL # Work_GEIM->EIM_NIVEL
      MSGSTOP(STR0332/*"NCM atual, Atributo e Especificacao nao tem esse Nivel."*/,STR0323 /*"Nivel da NCM atual: "*/+SJL->JL_NIVEL)
      Return .F.
   ENDIF
   nRec:=Work_GEIM->(RECNO())
   Work_GEIM->(DBGOTOP())
   aTab:={}
   DO WHILE Work_GEIM->(!EOF())
      IF Work_GEIM->DBDELETE
         Work_GEIM->(dbSkip())
         LOOP
      ENDIF
      IF ASCAN(aTab,Work_GEIM->(EIM_NIVEL+EIM_ATRIB)) = 0
         AADD(aTab,Work_GEIM->(EIM_NIVEL+EIM_ATRIB))
      ELSE
         If Posicione('SJK',1,xFilial("SJK")+AvKey(Work_GEIM->EIM_NCM,"JK_NCM")+AvKey(Work_GEIM->EIM_ATRIB,"JK_ATRIB"),'JK_MULTIPL') == 'N'
            MSGSTOP(STR0319)//"Atributo não pode ser duplicado."
            Work_GEIM->(DBGOTO(nRec))
            Return .F.
         EndIf
      ENDIF
      Work_GEIM->(DBSKIP())
   ENDDO
   Work_GEIM->(DBGOTO(nRec))

ELSEIF cCampo == 'EIM_NIVEL'

   IF lCposNVAE
      IF EMPTY(M->W5_TEC)
         MSGSTOP(STR0326)//"NCM nao preenchida."
         Return .F.
      ENDIF
      SJL->(DBSETORDER(1))
      cTECSeek:=M->W5_TEC
      nTamTEC:=LEN(M->W5_TEC)
      FOR T := 1 TO nTamTEC
         IF !SJL->(DBSEEK(xFilial()+cTECSeek))
            cTECSeek:=LEFT(M->W5_TEC,nTamTEC-T)+SPACE(T)
         ELSE
            EXIT
         ENDIF
      NEXT
      IF EMPTY(M->EIM_NIVEL)
         MSGSTOP(STR0333)//"Nivel nao preenchido."
         lRet:= .F.
      ELSEIF !SJL->(DBSEEK(xFilial()+cTECSeek+TRIM(Work_GEIM->EIM_ATRIB)+TRIM(Work_GEIM->EIM_ESPECI)))
         MSGSTOP(STR0332)//"NCM atual, Atributo e Especificacao nao tem esse Nivel."
         lRet:= .F.
      ELSEIF SJL->JL_NIVEL # M->EIM_NIVEL
         MSGSTOP(STR0332/*"NCM atual, Atributo e Especificacao nao tem esse Nivel."*/,STR0323 /*"Nivel da NCM atual: "*/+SJL->JL_NIVEL)
         lRet:= .F.
      ENDIF
   ENDIF

   RETURN lRet

ELSEIF cCampo == 'EIM_ATRIB'

   IF lCposNVAE
      IF EMPTY(M->EIM_ATRIB)
         M->EIM_DES_AT:=Work_GEIM->EIM_DES_AT:=""
         Return .T.
      ENDIF
      IF EMPTY(M->W5_TEC)
         MSGSTOP(STR0326)//"NCM nao preenchida."
         Return .F.
      ENDIF
      SJK->(DBSETORDER(1))
      cTECSeek:=M->W5_TEC
      nTamTEC:=LEN(M->W5_TEC)
      FOR T := 1 TO nTamTEC
         IF !SJK->(DBSEEK(xFilial()+cTECSeek))
            cTECSeek:=LEFT(M->W5_TEC,nTamTEC-T)+SPACE(T)
         ELSE
            EXIT
         ENDIF
      NEXT
      IF !SJK->(DBSEEK(xFilial()+cTECSeek+ALLTRIM(M->EIM_ATRIB)))
         MSGSTOP(STR0334)//"NCM atual nao tem esse Atributo."
         lRet:= .F.
      ELSE
         Work_GEIM->EIM_NIVEL := SJK->JK_NIVEL //If(Empty(Work_GEIM->EIM_NIVEL),SJK->JK_NIVEL,Work_GEIM->EIM_NIVEL)
         If lNVEProduto
            Work_GEIM->EIM_NCM := If(Empty(Work_GEIM->EIM_NCM),SJK->JK_NCM,Work_GEIM->EIM_NCM)
         EndIf
         IF SJK->JK_NIVEL # Work_GEIM->EIM_NIVEL
            MSGSTOP(STR0335/*"NCM atual e Atributo nao tem esse Nivel."*/,STR0323 /*"Nivel da NCM atual: "*/+SJK->JK_NIVEL)
            lRet:= .F.
         ENDIF
      ENDIF
      M->EIM_DES_AT:=Work_GEIM->EIM_DES_AT:=SJK->JK_DES_ATR
      M->EIM_DES_ES:=Work_GEIM->EIM_DES_ES:=""
      M->EIM_ESPECI:=Work_GEIM->EIM_ESPECI:=""
     ELSE
        cTECSeek:=M->W5_TEC
        nTamTEC:=LEN(M->W5_TEC)
        FOR T := 1 TO nTamTEC
           IF !SJK->(DBSEEK(xFilial()+cTECSeek+M->EIM_ATRIB))
              cTECSeek:=LEFT(M->W5_TEC,nTamTEC-T)+SPACE(T)
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
        If Work_GEIM->(Recno()) <> nRecWk .AND. Work_GEIM->EIM_NIVEL+Work_GEIM->EIM_ATRIB == cChave .And. Posicione('SJK',1,xFilial("SJK")+AvKey(M->W5_TEC,"JK_NCM")+AvKey(M->EIM_ATRIB,"JK_ATRIB"),'JK_MULTIPL') == 'N'
           Alert(STR0376) // "Atributo não pode ser duplicado."
           Work_GEIM->(DbGoTo(nRecWk))
           Work_GEIM->EIM_DES_AT := If(Empty(Work_GEIM->EIM_ATRIB),"",Posicione("SJK",1,xFilial()+cTECSeek+Work_GEIM->EIM_ATRIB,"JK_DES_ATR"))
           Return .F.
        EndIf
        Work_GEIM->(DbSkip())
     EndDo
     Work_GEIM->(DbGoTo(nRecWk))
     RETURN lRet

ELSEIF cCampo == 'EIM_ESPECI'

   IF lCposNVAE
      IF EMPTY(M->EIM_ESPECI)
         M->EIM_DES_ES:=Work_GEIM->EIM_DES_ES:=""
         Return .T.
      ENDIF
      IF EMPTY(M->W5_TEC)
         MSGSTOP(STR0326) //"NCM nao preenchida."
         Return .F.
      ENDIF
      SJL->(DBSETORDER(1))
      cTECSeek:=M->W5_TEC
      nTamTEC:=LEN(M->W5_TEC)
      FOR T := 1 TO nTamTEC
         IF !SJL->(DBSEEK(xFilial()+cTECSeek))
            cTECSeek:=LEFT(M->W5_TEC,nTamTEC-T)+SPACE(T)
         ELSE
            EXIT
         ENDIF
      NEXT
      IF !SJL->(DBSEEK(xFilial()+cTECSeek+Work_GEIM->EIM_ATRIB+ALLTRIM(M->EIM_ESPECI)))
         MSGSTOP(STR0336)//"NCM atual e Atributo nao tem essa Especificacao."
         lRet:= .F.
      ELSE
         Work_GEIM->EIM_NIVEL := SJL->JL_NIVEL //If(Empty(Work_GEIM->EIM_NIVEL),SJL->JL_NIVEL,Work_GEIM->EIM_NIVEL)
         If lNVEProduto
            Work_GEIM->EIM_NCM := If(Empty(Work_GEIM->EIM_NCM),SJK->JK_NCM,Work_GEIM->EIM_NCM)
         EndIf
         IF SJL->JL_NIVEL # Work_GEIM->EIM_NIVEL
            MSGSTOP(STR0332/*"NCM atual, Atributo e Especificacao nao tem esse Nivel."*/,STR0323 /*"Nivel da NCM atual: "*/+SJL->JL_NIVEL)
            lRet:= .F.
         ENDIF
      ENDIF

      nRecWk := Work_GEIM->(Recno())
      cChave := Work_GEIM->EIM_NIVEL+Work_GEIM->EIM_ATRIB+M->EIM_ESPECI
      Work_GEIM->(DbGoTop())
      Do While Work_GEIM->(!Eof())
         If Work_GEIM->(Recno()) <> nRecWk .AND. Work_GEIM->EIM_NIVEL+Work_GEIM->EIM_ATRIB+Work_GEIM->EIM_ESPECI == cChave
            Alert(STR0381) //"Especificação não pode ser duplicada para um mesmo atributo." 
            Work_GEIM->(DbGoTo(nRecWk))
            Work_GEIM->EIM_DES_ES := If(Empty(Work_GEIM->EIM_ESPECI),"",Posicione("SJL",1,xFilial()+cTECSeek+Work_GEIM->EIM_ATRIB+Work_GEIM->EIM_ESPECI,"JL_DES_ESP"))
            Return .F.
         EndIf
         Work_GEIM->(DbSkip())
      EndDo
      Work_GEIM->(DbGoTo(nRecWk))

      M->EIM_DES_ES:=Work_GEIM->EIM_DES_ES:=SJL->JL_DES_ESP
   ELSE
      cTECSeek:=M->W5_TEC
      nTamTEC:=LEN(M->W5_TEC)
      FOR T := 1 TO nTamTEC
         IF !SJL->(DBSEEK(xFilial()+cTECSeek+Work_TEMP->EIM_ATRIB+M->EIM_ESPECI))
            cTECSeek:=LEFT(M->W5_TEC,nTamTEC-T)+SPACE(T)
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

ENDIF

Return .T.

*-----------------------------------*
FUNCTION GI400SelNVE()
*-----------------------------------*
LOCAL oDlg, oRadio
LOCAL nLin := 17
LOCAL nColR:= 20 
LOCAL nCol := nColR+121
LOCAL nColS:= nCol-25//35
LOCAL nSoma:= 16
LOCAL nMarcaOK:=0

IF EMPTY(M->W5_TEC)
   MSGSTOP(STR0326)//"NCM nao preenchida."
   Return .F.
ENDIF

IF !GI400TemNVEOK(.F.)
   Return .F.
ENDIF

bBlocSel:={||.T.}

DO WHILE .T.

   nLin := 50
   
   DEFINE MSDIALOG oDlg TITLE STR0337 FROM 0,0 TO 19,63 Of oMainWnd  //"Seleciona Itens para Marcar"

   nOpRad:=4
   @nLin   ,nColR   TO nLin+75, nColR+84 LABEL STR0338 OF oDlg PIXEL //"Selecao"
   @nLin+07,nColR+5 RADIO oRadio VAR nOpRad ITEMS STR0345,STR0199,STR0377 3D SIZE 60,16 ;
                                            PIXEL OF oDlg ON CHANGE (GI400BOXNVE(.T.)) //"Pedido" ## "Todos" ## "Itens não vinculados"
   nLin+=10
   
   @nLin+.6, nColS SAY STR0345 OF oDlg PIXEL  //"Pedido"
   @nLin,    nCol  COMBOBOX oCboPO  VAR cPO      ITEMS aPOs     SIZE 75,18 PIXEL WHEN {|| nOpRad==1 }
   nLin+=nSoma

   @ nLin+.6,nColS SAY STR0340 OF oDlg PIXEL  //"N.C.M."
   @ nLin,   nCol  MSGET M->W5_TEC PICTURE AVSX3("W3_TEC",6) SIZE 75,18 PIXEL WHEN .F.

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| (nMarcaOK:=1,oDlg:End()) }, {|| (nMarcaOK:=0,oDlg:End()) }) CENTERED


   IF nMarcaOK = 1

      IF nOpRad == 1  //"Pedido"
         bBlocSel := {|| RTRIM(Work->WKPO_NUM ) == RTRIM(cPO)}
      ELSEIF nOpRad == 2  //"Todos"
         bBlocSel := {|| .T.}
      ElseIf nOpRad == 3  //"Itens não vinculados"
         bBlocSel := {|| Empty(Work->WKNVE) }
      ENDIF

      IF !GI400CrgNVE(cNVE,bBlocSel,.F.)
         MSGSTOP(STR0341)//"Nao existem itens compativeis p/ essa selecao."
         LOOP
      ELSE
         IF GI400TemNVEOK(.F.)
            Processa({|| GI400GrvNVE(nSelOp,cNVE) })
         ENDIF
      ENDIF

   ENDIF

   EXIT

ENDDO

Work_EIM->(DBSETORDER(1))

RETURN .T.
*------------------------------*
FUNCTION GI400BoxNVE()
*------------------------------*
IF(nOpRad=1, oCboPO:ENABLE(), oCboPO:DISABLE()) // Escolheu PO
//IF(nOpRad=2,   oInv:ENABLE(),   oInv:DISABLE()) // Escolheu Invoice
//IF(nOpRad=3,oCboPLI:ENABLE(),oCboPLI:DISABLE()) // Escolheu PLI

RETURN .T.
*-------------------------------------------------------------------------------------*
FUNCTION GI400GrvNVE(nSelOp,cChave,cTEC)
*-------------------------------------------------------------------------------------*
LOCAL nCont:=xTotal:=0,lGrvItem:=.F.

lGravaSoCapa:=.F.   

ProcRegua( Work_EIM->(EasyRecCount("Work_GEIM")) )

IF nSelOp = 4 // Exclui NVE
   IF Work_CEIM->(DBSEEK(cChave))
      IncProc()
      Work_CEIM->(DBDELETE())
      DBSELECTAREA("Work_CEIM")
      PACK
   ENDIF
   DBSELECTAREA("Work")
   SET FILTER TO
   Work->(DBSETORDER(7))
   DO WHILE Work->(DBSEEK(cChave+If(!Empty(cTEC),cTEC,"")))
      Work->WKNVE:=""
      //Work->WKADICAO:=""
   ENDDO
   Work->(DBSETORDER(1))
   //GI400Controle(1)

   // SVG - 13/07/09 -
   If ("CTREE" $ RealRDD())
      Work->(DBEVAL({|| If(&(cFiltroSW5),Work->WKFILTRO:="S",Work->WKFILTRO:="")}))
      SET FILTER TO Work->WKFILTRO == "S"
   Else
      SET FILTER TO &(cFiltroSW5)
   EndIf
ENDIF

lGravaEIM:=.T.
Work_EIM->(DBSETORDER(2))
Work_EIM->(DBSEEK(cChave))
lDeletou:=.F.
DO While !Work_EIM->(Eof()) .AND. Work_EIM->EIM_CODIGO == cChave

   IncProc()
// IF nSelOp = 4 .AND. !EMPTY(Work_GEIM->WK_RECNO) // Exclui NVE
//    AADD(aDeletados,{"EIM",Work_GEIM->WK_RECNO})
// ENDIF
   lDeletou:=.T.
   Work_EIM->(DBDELETE())
   Work_EIM->(dbSkip())

ENDDO
Work_EIM->(DBSETORDER(1))

IF lDeletou
   DBSELECTAREA("Work_EIM")
   PACK
ENDIF

IF nSelOp = 4 // Exclui NVE
   RETURN .T.
ENDIF

ProcRegua(Work_GEIM->(EasyRecCount("Work_GEIM")))

Work_GEIM->(DBGOTOP())
DO WHILE Work_GEIM->(!EOF())

   IncProc()

   IF Work_GEIM->DBDELETE
//    IF !EMPTY(Work_GEIM->WK_RECNO)
//       AADD(aDeletados,{"EIM",Work_GEIM->WK_RECNO})
//    ENDIF
      Work_GEIM->(dbSkip())
      LOOP
   ENDIF

   IF EMPTY(Work_GEIM->(EIM_NIVEL+EIM_ATRIB+EIM_ESPECI))
      Work_GEIM->(dbSkip())
      LOOP
   ENDIF

   Work_EIM->(DBAPPEND())

   AVREPLACE("Work_GEIM","Work_EIM")

   Work_EIM->EIM_CODIGO:=cChave
   If lNVEProduto
      Work_EIM->EIM_NCM     :=M->W5_TEC
   EndIf
   Work_EIM->EIM_FASE    :="LI"
   Work_EIM->EIM_HAWB    :=M->W4_PGI_NUM

   lNVEInclui:=.F.
   lGrvItem  :=.T.

   Work_GEIM->(dbSkip())
ENDDO

IF lGrvItem
   IF !Work_CEIM->(DBSEEK(cChave))
      Work_CEIM->(DBAPPEND())
      Work_CEIM->EIM_CODIGO:=cChave
      Work_CEIM->WKTEC     :=M->W5_TEC
   ENDIF
ENDIF

Work_GEIM->(DBGOTOP())
Work_EIM->(DBGOTOP())

RETURN .T.
*-----------------------------------------------------------------------------------------------------------------*
FUNCTION GI400CrgNVE(cNVE,bBlocSel,lZap)
*-----------------------------------------------------------------------------------------------------------------*
DBSELECTAREA("Work")
SET FILTER TO

ProcRegua(Work->(EasyRecCount("Work")))
Work->(DBSETORDER(1))//WKINVOICE+WKFORN+WKPO_NUM+WKPOSICAO+WKPGI_NUM
Work->(dbGoTop())
lTemItens := .F.
DO While !Work->(Eof())

   IncProc()

   IF !Work->WKFLAG
      Work->(DBSKIP())
      LOOP
   ENDIF

   IF !EVAL(bBlocSel)
      Work->(DBSKIP())
      LOOP
   ENDIF
      
   IF !EMPTY(M->W5_TEC) .AND. !(ALLTRIM(M->W5_TEC) $ Left(Work->WKTEC, Len(ALLTRIM(M->W5_TEC))))
      Work->(DBSKIP())
      LOOP
   ENDIF

   Work->WKNVE   :=cNVE
   //Work_SW8->WKADICAO:=""

   lTemItens := .T.

   Work->(dbSkip())

ENDDO
IF lTemItens
   //GI400Controle(1)
ENDIF

DBSELECTAREA("Work")
Work->(DBSETORDER(1))

// SVG - 13/07/09 -
If ("CTREE" $ RealRDD())
   Work->(DBEVAL({|| If(&(cFiltroSW5),Work->WKFILTRO:="S",Work->WKFILTRO:="")}))
   SET FILTER TO Work->WKFILTRO == "S"
Else
   SET FILTER TO &(cFiltroSW5)
EndIf

DBGOTOP()

Return lTemItens
*------------------------------------------------------------------------------*
FUNCTION GI400GEIMGrv(cNVE)
*------------------------------------------------------------------------------*
Local bWhile := {|| !Work_EIM->(Eof()) .AND. Work_EIM->(EIM_HAWB+EIM_NIVEL+EIM_CODIGO) == cChave }
Local bCond  := If( lNVEProduto , {|| Select("Work_NVE") # 0 .AND. AllTrim(Work_EIM->EIM_NCM) $ Left(Work_NVE->WK_TEC, Len(AllTrim(Work_EIM->EIM_NCM))) } , {|| .T. } )
DBSELECTAREA("Work_GEIM")
//ZAPs
AvZap("Work_GEIM")

cChave := AvKey(M->W4_PGI_NUM,"EIM_HAWB")+AvKey(cClassif,"EIM_NIVEL")+AvKey(cNVE,"EIM_CODIGO")
Work_EIM->(DBSETORDER(3))  //EIM_HAWB+EIM_NIVEL+EIM_CODIGO+EIM_ATRIB+EIM_ESPECI

IF Work_EIM->(DBSEEK(cChave))
   DO While Eval(bWhile)
      If Eval(bCond)
         Work_GEIM->(DBAPPEND())
         AVREPLACE("Work_EIM","Work_GEIM")
         Work_GEIM->EIM_ALI_WT := "EIM"
         Work_GEIM->EIM_REC_WT := Work_EIM->WK_RECNO
      EndIf
      Work_EIM->(dbSkip())
   ENDDO   
ENDIF
Work_EIM->(DBSETORDER(1))

RETURN .T.
*------------------------------------------------------------------------------*
FUNCTION GI400EIMGrava()
*------------------------------------------------------------------------------*
//MFR 26/11/2018
//LOCAL cFilEIM:=xFilial("EIM")
LOCAL cFilEIM:=GetFilEIM("LI")

IF !lCposNVAE
   RETURN .F.
ENDIF

EIM->(DBSETORDER(1))
EIM->(DBSEEK(cFilEIM+AvKey(M->W4_PGI_NUM,"EIM_HAWB")))
DO While !EIM->(Eof()) .AND. AvKey(M->W4_PGI_NUM,"EIM_HAWB") == EIM->EIM_HAWB   .AND.;
                                  cFilEIM == EIM->EIM_FILIAL
   IF EIM->EIM_FASE == "LI"
      EIM->(RECLOCK("EIM",.F.))
      EIM->(DBDELETE())
      EIM->(MSUNLOCK())
   ENDIF
   EIM->(dbSkip())

ENDDO

Work->(DBSETORDER(7))
Work_EIM->(DBGOTOP())
DO While !Work_EIM->(Eof())
   IF !EMPTY(Work_EIM->EIM_CODIGO) .AND. !Work->(DBSEEK(Work_EIM->EIM_CODIGO))// Se o codigo estiver em branco pode ser EIM de processo antigo que so tem na adicao
      Work_EIM->(dbSkip())
      LOOP
   ENDIF
   EIM->(RECLOCK("EIM",.T.))
   AVREPLACE("Work_EIM","EIM")
   EIM->EIM_FILIAL:= cFilEIM
   EIM->EIM_HAWB  := M->W4_PGI_NUM
   EIM->EIM_FASE  := "LI"
   If lNVEProduto
      EIM->EIM_NCM := Work_EIM->EIM_NCM
   EndIf
   EIM->(MSUNLOCK())
   Work_EIM->(dbSkip())
ENDDO
Work->(DBSETORDER(1))

RETURN  .T.


FUNCTION GI400NVEDel(cPLI)

EIM->(DbSetOrder(1))
//MFR 26/11/2018 OSSME-1483
//If EIM->(DbSeek(xFilial("EIM")+AvKey(cPLI,"W6_HAWB")))
If EIM->(DbSeek(GetFilEIM("LI")+AvKey(cPLI,"W6_HAWB")))
   Do While !EIM->(Eof()) .And. EIM->EIM_HAWB == AvKey(cPLI,"W6_HAWB");
                          .And. aScan(aTabsNVE,EIM->EIM_CODIGO) == 0
      EIM->(RecLock("EIM",.F.))
      EIM->(DbDelete())
      EIM->(MsUnlock())
      EIM->(DbSkip())
   EndDo
EndIf

Return .T.

/*
Funcao      : ValNVEPLI()
Parametros  : -
Retorno     : .T. - Caso o usuário deseja prosseguir sem a classificação N.V.A.E
              .F. - Caso o usuário não deseja prosseguir sem a classificação N.V.A.E
Objetivos   : Verificar e questionar o usuário sobre as NCMs
              que estão sem classificação N.V.A.E na fase de PLI
Autor       : Flavio D. Ricardo - FDR
Data/Hora   : 14/10/11
Revisao     :
Obs.        :
*/

Function ValNVEPLI()

Local cNCM:=""
Local aNCM:={}
Local aOrdWKS := SaveOrd({"Work"})
Local T
Local cTECSeek
Local nTamTEC := 0
Local xFilSJL:=xFilial("SJL")

Work->(DBGOTOP())
DO WHILE Work->(!EOf()) .AND. lCposNVAE

   IF EMPTY(Work->WKFLAGWIN) .OR. !EMPTY(Work->WKNVE) .OR. ASCAN(aNCM,Work->WKTEC) # 0
      Work->(DBSKIP())
      LOOP
   ENDIF

   AADD(aNCM,Work->WKTEC)
   cTECSeek:=Work->WKTEC
   nTamTEC :=LEN(Work->WKTEC)
   FOR T := 1 TO nTamTEC
      IF !SJL->(DBSEEK(xFilSJL+cTECSeek))
         cTECSeek:=LEFT(Work->WKTEC,nTamTEC-T)+SPACE(T)
      ELSE
         cNCM+=Work->WKTEC+", "
         EXIT
      ENDIF
   NEXT

   Work->(DBSKIP())
ENDDO

IF lCposNVAE .AND. !EMPTY(cNCM)
   IF !MSGYESNO(STR0342/*"Itens das seguintes NCM's não possuem NVE: "*/+cNCM+STR0343/*"Deseja gerar a PLI mesmo assim?"*/,STR0344)//"Aviso"
      RETURN .F.
   ENDIF
ENDIF

RestOrd(aOrdWKS)

Return .T.

/*
Funcao     : GI400GerWkW5()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Criação da work para exibição de grid
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 02/03/2013 - 12:30
*/
*----------------------------*
Function GI400GerWkW5()
*----------------------------*
Local aOrd := SaveOrd({"SW5","SB1","SA2"})

If !(Select("TRB_SW5") <> 0)
   cFileWkSW5 := E_CriaTrab("SW5",aSemSX3,"TRB_SW5")
Else
   TRB_SW5->(avzap())
EndIf

cFileWkSW5 := E_Create(,.F.)
IndRegua("TRB_SW5" ,cFileWkSW5+TEOrdBagExt() ,"W5_PGI_NUM")

//SW5->(DbSetOrder(1))   //W5_FILIAL+W5_PGI_NUM+W5_CC+W5_SI_NUM+W5_COD_I
//If SW5->(DbSeek(xFilial("SW5")+M->WP_PGI_NUM))

SW5->(DbSetOrder(7))//W5_FILIAL+W5_PGI_NUM+W5_SEQ_LI+STR(W5_SEQ, 2, 0)+W5_COD_I+STR(W5_PRECO, 15, 5)  // GFP - 06/01/2014
If SW5->(DbSeek(xFilial("SW5")+M->WP_PGI_NUM+M->WP_SEQ_LI))   // GFP - 06/01/2014
   Do While SW5->(!Eof()) .AND. SW5->W5_FILIAL == xFilial("SW5") .AND. SW5->W5_PGI_NUM == M->WP_PGI_NUM .AND. SW5->W5_SEQ_LI == M->WP_SEQ_LI  // GFP - 06/01/2014
      //LRS - 06/04/2016
      IF SW5->W5_SEQ <> 0
      	  SW5->(DbSkip())
      else
	      TRB_SW5->(DBAPPEND())
	      AvReplace("SW5","TRB_SW5")

	      SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
	      SB1->(DbSeek(xFilial("SB1")+SW5->W5_COD_I))
	      TRB_SW5->W5_DESC_P := MSMM(SB1->B1_DESC_P,,,,3) //AVSX3("B1_VM_P",3)

	      SA2->(DbSetOrder(1))  //A2_FILIAL+A2_COD+A2_LOJA
	      SA2->(DbSeek(xFilial("SA2")+AvKey(SW5->W5_FABR,"A2_COD")+If(EICLoja(),AvKey(SW5->W5_FABLOJ,"A2_LOJA"),"")))
	      TRB_SW5->W5_FABR_N := SA2->A2_NREDUZ

	      SA2->(DbSeek(xFilial("SA2")+AvKey(SW5->W5_FORN,"A2_COD")+If(EICLoja(),AvKey(SW5->W5_FORLOJ,"A2_LOJA"),"")))
	      TRB_SW5->W5_FORN_N := SA2->A2_NREDUZ

	      SW5->(DbSkip())
      EndIF
   EndDo
EndIf

TRB_SW5->(DbGoTop())  // GFP - 06/01/2014

TB_Campos := {}
AADD(Tb_Campos,{"W5_SEQ_LI",,AVSX3("W5_SEQ_LI",5)})
AADD(Tb_Campos,{"W5_PO_NUM",,AVSX3("W5_PO_NUM",5)})
AADD(Tb_Campos,{"W5_COD_I",,AVSX3("W5_COD_I",5)})
AADD(Tb_Campos,{"W5_QTDE",,AVSX3("W5_QTDE",5),AVSX3("W5_QTDE",6)})
AADD(Tb_Campos,{"W5_SALDO_Q",,AVSX3("W5_SALDO_Q",5),AVSX3("W5_SALDO_Q",6)})
AADD(Tb_Campos,{"W5_PESO",,AVSX3("W5_PESO",5),AVSX3("W5_PESO",6)})
AADD(Tb_Campos,{"W5_PRECO",,AVSX3("W5_PRECO",5),AVSX3("W5_PRECO",6)})
AADD(Tb_Campos,{"W5_CC",,AVSX3("W5_CC",5)})
AADD(Tb_Campos,{"W5_SI_NUM",,AVSX3("W5_SI_NUM",5)})
AADD(Tb_Campos,{"W5_DESC_P",,AVSX3("W5_DESC_P",5)})
AADD(Tb_Campos,{"W5_FABR",,AVSX3("W5_FABR",5)})
AADD(Tb_Campos,{"W5_FABLOJ",,AVSX3("W5_FABLOJ",5)})
AADD(Tb_Campos,{"W5_FABR_N",,AVSX3("W5_FABR_N",5)})
AADD(Tb_Campos,{"W5_FORN",,AVSX3("W5_FORN",5)})
AADD(Tb_Campos,{"W5_FORLOJ",,AVSX3("W5_FORLOJ",5)})
AADD(Tb_Campos,{"W5_FORN_N",,AVSX3("W5_FORN_N",5)})
AADD(Tb_Campos,{"W5_DT_EMB",,AVSX3("W5_DT_EMB",5)})
AADD(Tb_Campos,{"W5_DT_ENTR",,AVSX3("W5_DT_ENTR",5)})
AADD(Tb_Campos,{"W5_PGI_NUM",,AVSX3("W5_PGI_NUM",5)})
AADD(Tb_Campos,{"W5_AC",,AVSX3("W5_AC",5)})

RestOrd(aOrd,.T.)
Return

/*
Programa   : GI400CALCFOB
Objetivo   : Função replicada do GI400ApVal() com alterações para ser utilizada no calculo do FOB unitário na opção 'Visualizar' da Rotina P.L.I.
Retorno    : Valor FOB unitário(Valor do produto sem as taxas e despesas, dividido pelo saldo do item)
Autor      : FABIO SATORU YAMAMOTO
Data/Hora  : 14/06/2013
*/
Function GI400CALCFOB()
Local  nRecAux
Local  nPesoTot:=0, nValAux:=0, nValorTot:=0

If Select("TRB") == 0  // GFP - 01/04/2014
   Return 0
EndIf

nRecAux := TRB->(RecNo())
nValAux := TRB->W5_QTDE * TRB->W5_PRECO

//Adicionar Inland e Packing ao valor EXW para chegar ao valor FOB.
If ALLTRIM(M->W4_INCOTER) $ "EXW"
   TRB->(dbGoTop())
   Do While !TRB->(EOF())
      nValorTot += TRB->W5_QTDE * TRB->W5_PRECO
      TRB->(dbSkip())
   EndDo
   TRB->(dbGoTo(nRecAux))
   nValAux += ((M->W4_INLAND+M->W4_PACKING + M->W4_OUT_DES) - M->W4_DESCONT)*nValAux/nValorTot
EndIf

IF lW4_Fre_Inc  .And.  (M->W4_FREINC $ cSim) .AND. AvRetInco(ALLTRIM(M->W4_INCOTER),"CONTEM_FRETE")//ALLTRIM(M->W4_INCOTER) $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP"
   TRB->(dbGoTop())
   Do While !TRB->(EOF())
      nPesoTot += TRB->W5_PESO * TRB->W5_QTDE
      TRB->(dbSkip())
   EndDo
   TRB->(dbGoTo(nRecAux))
   nValAux := nValAux - (M->W4_FRETEIN*((TRB->W5_PESO * TRB->W5_QTDE)/nPesoTot))
EndIf

//Inclusão do tratamento de incoterm com seguro
IF lSegInc  .And.  (M->W4_SEGINC $ cSim) .AND. AvRetInco(ALLTRIM(M->W4_INCOTER),"CONTEM_SEG")//ALLTRIM(M->W4_INCOTER) $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP"
   TRB->(dbGoTop())
   Do While !TRB->(EOF())
      nValorTot += TRB->W5_QTDE * TRB->W5_PRECO
      TRB->(dbSkip())
   EndDo
   TRB->(dbGoTo(nRecAux))
   nValAux := nValAux - (M->W4_SEGURO*(nValAux/nValorTot))
EndIf

nValAux := nValAux/TRB->W5_SALDO_Q

Return nValAux

// GFP - 28/04/2014
*-----------------------------*
Static Function GrvSldAto(cAC)
*-----------------------------*
Local cMsgRet := ""

Begin Sequence
   If cAC<>Work->WKAC .or. ED4->ED4_SEQSIS<>Work->WKSEQSIS
      ED0->(dbSetOrder(2))
      aADD(aAltSW5,{M->W4_PGI_NUM,Work->WKPO_NUM,Work->WKPOSICAO})
      If !Empty(Work->WKAC)
         DelSaldoAC()
      EndIf
      If !Empty(cAC)
         If ED0->ED0_AC <> ED4->ED4_AC .or. ED0->ED0_FILIAL <> cFilED0
            ED0->(dbSeek(cFilED0+ED4->ED4_AC))
         EndIf
         //Verifica Saldo
         If ((ED4->ED4_QT_LI >= nQtdAux .AND. ED4->ED4_SNCMLI >= nQtdNCMAux ) .or. (ED0->ED0_TIPOAC==GENERICO .and. ED4->ED4_NCM=NCM_GENERICA)) .and. ;
            ( ED4->ED4_CAMB==VerCobertura(MCond_Pag,MDias_Pag)) /*AOM - 21/07/10 - Valida se a cond. de pagto esta COM/SEM cobertura, pois para efetuar a apropriação deve verificar se os
                                                                itens do ato Concessório esta de acordo com a cobertura na cond. pagto*/

            cMsgRet += GI400ValAnt(ED0->ED0_PD,ED4->ED4_ITEM,ED4->ED4_SEQSIS)
            Apropria(.F.,ED0->ED0_TIPOAC,,cItem)
            
         Else
            //ConfirmaAC(cAC,0,.F.,,cItem)

                  cMotivo := STR0255 +Chr(13)+Chr(10) //STR0255 "Divergência na apropriação"
                  cMotivo += STR0256 +ED4->ED4_AC+ STR0257 +ED4->ED4_SEQSIS+Chr(13)+Chr(10) //STR0256 "Ato Concessório" //STR0257 " sequência "

                  If Valtype(nQtdAux) == "N"  .AND. ED4->ED4_QT_LI < nQtdAux
                     cMotivo += STR0258 + ED4->ED4_UMITEM+": "+TransForm(ED4->ED4_QT_LI,AvSX3("ED4_QT_LI",AV_PICTURE))+Chr(13)+Chr(10) //STR0258 "   Saldo em "
                     cMotivo += STR0259 + ED4->ED4_UMITEM+": "+TransForm(nQtdAux,AvSX3("ED4_QT_LI",AV_PICTURE))+Chr(13)+Chr(10) //STR0259 "   Quantidade do item a vincular em "
                  EndIf

                  If ED4->ED4_UMITEM <> ED4->ED4_UMNCM .AND.  Valtype(nQtdNcmAux) == "N" .AND. ED4->ED4_SNCMLI < nQtdNcmAux
                     cMotivo += STR0258 + ED4->ED4_UMNCM+": "+TransForm(ED4->ED4_QT_LI,AvSX3("ED4_QT_LI",AV_PICTURE))+Chr(13)+Chr(10) //STR0258 "   Saldo em "
                     cMotivo += STR0259 + ED4->ED4_UMNCM+": "+TransForm(nQtdAux,AvSX3("ED4_QT_LI",AV_PICTURE))+Chr(13)+Chr(10)
                  EndIf

                  If ED4->ED4_CAMB <> VerCobertura(MCond_Pag,MDias_Pag)//AOM - 21/07/10
                     If ED4->ED4_CAMB == "1"
                        cMotivo += STR0260 +Alltrim(ED4->ED4_ITEM)+STR0261 + Chr(13)+Chr(10) //STR0260 "   O item " //STR0261 " não pode ser apropriado, pois no Ato Concessório o mesmo possui Cobertura Cambial"
                        cMotivo += STR0262 + Chr(13)+Chr(10) //STR0262 " e a condição de pagamento utilizada está Sem cobertura Cambial. Para que o item possa ser apropriado as condições devem estar em comum."
                     ElseIf ED4->ED4_CAMB == "2"
                        cMotivo += STR0260 + Alltrim(ED4->ED4_ITEM)+STR0261 + Chr(13)+Chr(10)
                        cMotivo += STR0262 + Chr(13)+Chr(10)
                     EndIf
                  EndIf

                  //AOM - 15/09/2011
                  If ED4->ED4_QT_LI<=0
                     cMotivo += STRTRAN(STR0302,"###",AllTrim(ED4->ED4_AC)) + AllTrim(Transform(ED4->ED4_QT_LI,AVSX3("ED4_QT_LI",6))) //"Saldo da LI insuficiente no Ato Concessório ### para o Item selecionado. Saldo atual no Ato Concessório de : "
                  EndIf

                  cMotivo += Chr(13)+Chr(10)

                  EECView(cMotivo,STR0263)// STR0263 "Divergências - Não foi possível apropriar o Ato Concessório"


            // PLB 18/07/07 - Não apropria caso não haja saldo
//            MsgInfo(STR0191+Alltrim(cAc)+" "+STR0019+Alltrim(cSeqSis)+STR0158) //"O Ato Concessorio " # " seq. " # " nao serve para apropriação deste item. Tente selecionar um item correspondente através da tecla <F3>."
         EndIf
      ElseIf !Empty(Work->WKAC)
         //** PLB 29/11/06 - Destrava o Ato concessorio anterior
         nOrderSW5 := SW5->( IndexOrd() )
         nRecnoSW5 := SW5->( RecNo() )
         SW5->( DBSetOrder(1) )
         If SW5->( DBSeek(cFilSW5+M->W4_PGI_NUM+Work->WKCC+Work->WKSI_NUM+Work->WKCOD_I) )  ;
            .And.  SW5->( W5_AC+W5_SEQSIS ) == Work->( WKAC+WKSEQSIS )  .And.  lMUserEDC
            If oMUserEDC:Reserva("PLI","ALT_ATO_3")
               Work->WKAC     := ""
               Work->WKSEQSIS := ""
            EndIf
         Else
            If lMUserEDC
               oMUserEDC:Solta("PLI","ALT_ATO")
            EndIf
            Work->WKAC     := ""
            Work->WKSEQSIS := ""
         EndIf
         SW5->( DBSetOrder(nOrderSW5) )
         SW5->( DBGoTo(nRecnoSW5) )
         //**
      EndIf
      ED0->(dbSetOrder(1))
      lAltera := .T.//AAF 16/05/05 - Permite gravar a alteração no Ato Concessório.
   EndIf
End Sequence

Return cMsgRet
*---------------------------------*
Static Function GI400_Marca(cMarca)//SSS -  REG 4.5 03/06/14
*---------------------------------*
Local aOrd   := SaveOrd({"SW7","SWN","SW5"})
Local aProcs := {}
Local lAchou,i

SW7->(DbSetOrder(2))

If Empty(WK_LI->WK_FLAG)
      SW5->(DbGoto(WK_LI->WK_RECNO))
      If SW7->(DbSeek(xFilial()+WK_LI->WK_PO_NUM))
         Do While SW7->(!Eof()) .And. SW7->W7_FILIAL = xFilial("SW7") .And. SW7->W7_PO_NUM = WK_LI->WK_PO_NUM

            If SW7->W7_POSICAO == SW5->W5_POSICAO .AND. SW7->W7_PGI_NUM == SW5->W5_PGI_NUM
               Aadd(aProcs,SW7->W7_HAWB)
            EndIf

            SW7->( DbSkip() )

         EndDo
      EndIf

      lAchou := .F.

      SWN->(DbSetOrder(3))
      For i =  1 To Len(aProcs)

          If SWN->(DbSeek( xFilial("SWN")+aProcs[i] ) )
             lAchou:=.T.
             Exit
          EndIf

      Next

      If !lAchou
         IF !MsgYesNo(STR0356) //"Não foi localizada a Nota Fiscal de recebimento deste item. Deseja prosseguir com a marcação do item para eliminação do saldo ?"
            Return .f.
         ENDIF
      EndIf

      WK_LI->WK_FLAG := cMarca

Else

      WK_LI->WK_FLAG := ""

EndIf
RestOrd(aOrd)
Return .t.

/*
Autor : Marcos Roberto Ramos Cavini Filho
Data  : 15/12/2015
Objetivo: Grava as informações da tabela SW4 para a SW6.
*/
Function GI400SWPGrava()
Return SwpGrava()
/*
Funcao    : GI400When()
Autor     : Guilherme Fernandes Pilan - GFP
Data      : 01/02/2016
Retorna   : Tratamento de When dos campos de dicionario.
*/
*------------------------------*
Function GI400When(cCampo)
*------------------------------*
Local lRet := .T.

Do Case
   Case (cCampo == "W4_SEGINC"  .OR. cCampo == "W4_FREINC"  .OR. cCampo == "W4_RAT_POR" .OR.;
         cCampo == "W4_FRETEIN" .OR. cCampo == "W4_SEGURIN" .OR. cCampo == "W4_INLAND"  .OR.;
         cCampo == "W4_DESCONT" .OR. cCampo == "W4_PACKING")
      If AvFlags("RATEIO_DESP_PO_PLI")
         lRet := .F.
      EndIf
End Case

Return lRet

/*
Funcao    : GI400ValGerArq()
Autor     : Guilherme Fernandes Pilan - GFP
Data      : 20/09/2016 :: 16:45
Retorna   : Validação dos campos obrigatórios para geração de arquivo de integração Siscomex Web Importação.
*/
*----------------------------*
Function GI400ValGerArq()
*----------------------------*
Local cErro := ""
Local aOrd := SaveOrd({"SWP","SW4","SW5","SY6"})

SW4->(DBSetOrder(1))  //W4_FILIAL+W4_PGI_NUM
SW4->(DBSEEK(xFilial("SW4")+SWP->WP_PGI_NUM))

SW5->(DBSetOrder(7))  //W5_FILIAL+W5_PGI_NUM+W5_SEQ_LI+STR(W5_SEQ, 2, 0)+W5_COD_I+STR(W5_PRECO, 15, 5)
SW5->(DBSEEK(xFilial("SW5")+SWP->WP_PGI_NUM+SWP->WP_SEQ_LI))

SY6->(DbSetOrder(1))  //Y6_FILIAL+Y6_COD+STR(Y6_DIAS_PA,3,0)
If SY6->(DbSeek(xFilial("SY6")+SW4->(W4_COND_PA+Str(W4_DIAS_PA,3,0)))) .And. Empty(SY6->Y6_TIPOCOB) /*(SY6->Y6_TIPOCOB == "4" .OR. Empty(SY6->Y6_TIPOCOB))*/ //AAF 27/10/2017 - Validar apenas se está preenchido o tipo de cobertura.
   cErro += STR0360 + ENTER //"Condição de Pagamento informada não possui tipo de cobertura cambial informada."
EndIf

/****** VALIDAÇÕES LI - SWP ******/
If Empty(SWP->WP_NCM)
   cErro += STR0361 + AllTrim(SW5->W5_COD_I) + ENTER //"NCM não preenchida para o item: "
EndIf
//RMD - 08/12/17 - Campo já é validado na central de integrações
//If !Empty(SWP->WP_REGIST)
//   cErro += STR0362 + ENTER  //"Processo já possui Número de LI informado."
//EndIf

If !Empty(cErro)

   DEFINE FONT oFont NAME "Courier New" SIZE 0,15
   DEFINE MSDIALOG oDLGDescr TITLE STR0359 + AllTrim(SWP->WP_PGI_NUM) + "-" + AllTrim(SWP->WP_SEQ_LI); //"Inconsistencias Encontradas, processo: "
          From 00,00 To 32,70 OF oMainWnd

     oDLGDescr:SetFont(oFont)
     @32,2 GET cErro MEMO HSCROLL SIZE 275,210 OF oDLGDescr PIXEL

   ACTIVATE MSDIALOG oDLGDescr ON INIT EnchoiceBar(oDLGDescr,{||oDLGDescr:End()},{||oDLGDescr:End()},.F.) CENTERED

EndIf

RestOrd(aOrd,.T.)
Return Empty(cErro)

/*
Funcao    : GI400LegNVE()
Autor     : Guilherme Fernandes Pilan - GFP 	            
Data      : 11/11/2016
Retorna   : Legendas de NVE
*/
*------------------------------*
Function GI400LegNVE()
*------------------------------*
Local aColors := {{"BR_VERMELHO" , STR0367},;  //"Itens sem vinculação"
                  {"BR_AZUL"     , STR0368},;  //"Itens já vinculados à tabela atual"
                  {"BR_VERDE"    , STR0369}}   //"Itens já vinculados em outra tabela"
Return BrwLegenda(STR0318, STR0366, aColors)   // "Manutenção de NVEs" ## "Legendas"

/*
Função    : validPliEmbarcada()
Objetivos : Verifica se o item selecionado está em um processo de embarque
Retorno   : .T. - Caso não tenha sido embarcada
            .F. - Caso tenha sido embarcada
Autor     : Wanderson Reliquias
Revisão   : 
Data      : 22/02/2017
*/
Static Function validPliEmbarcada()
Local lRet := .T.
Local cQuery := "" 
Local nOldArea:=SELECT()

If select("TOTALREG")> 0
   TOTALREG->(dbClosearea())
EndIf

cQuery := "SELECT COUNT(*) TOTAL FROM "+RetSQLName("SW7") + " where W7_FILIAL = '" + xFilial("SW7") +; 
			"' AND W7_PO_NUM = '" + AvKey(Work->WKPO_NUM, "W7_PO_NUM") +; 
			"' AND W7_POSICAO = '" +AvKey(Work->WKPOSICAO, "W7_POSICAO") +; 
			"' AND W7_PGI_NUM = '" + AvKey(if(work->(fieldPos("WKPGI_NUM")) > 0, work->WKPGI_NUM, SW4->W4_PGI_NUM), "W7_PGI_NUM") +;
			"' AND D_E_L_E_T_ <> '*' " //MCF - 22/03/2017
       
      TcQuery ChangeQuery(cQuery) ALIAS "TOTALREG" NEW
      nCont:= TOTALREG->TOTAL
      
      IF nCont > 0
      	lRet := .F.
      endIf

      TOTALREG->( dbCloseArea() )
      DBSELECTAREA(nOldArea)

return lRet
/*
Funcao    : GI400PDF()
Autor     : Miguel Prado Gontijo - MPG
Data      : 20/03/2019
Retorna   : Abre o PDF do processo de LI
*/
Function GI400PDF()
Local cLIPDF   := alltrim(SWP->WP_REGIST)+".pdf"
Local cPathPDF := "\comex\siscomexweb\processados\extrato_li\"

   If Empty(cLIPDF)
      EasyHelp("Visualização disponível somente para processos já registrados.")
   ElseIf !file( cPathPDF+cLIPDF )
      If File( GetTempPath(.T.)+cLIPDF )
         ShellExecute("open", GetTempPath(.T.)+cLIPDF ,"","", 1)
         if !AvCpyFile( GetTempPath(.T.)+cLIPDF , cPathPDF+cLIPDF ,,.F.)
            EasyHelp("Não foi possível copiar o arquivo "+GetTempPath(.T.)+cLIPDF + ENTER + "Para o local "+cPathPDF+cLIPDF)
         endif
      elseif file( "\comex\siscomexweb\processados\"+cLIPDF )
         if !AvCpyFile( "\comex\siscomexweb\processados\"+cLIPDF , cPathPDF+cLIPDF ,,.T.)
            EasyHelp("Não foi possível copiar o arquivo \comex\siscomexweb\processados\"+cLIPDF + ENTER + "Para o local "+cPathPDF+cLIPDF)
         else
            if AvCpyFile( cPathPDF+cLIPDF , GetTempPath(.T.)+cLIPDF ,,.F.)
               ShellExecute("open", GetTempPath(.T.)+cLIPDF ,"","", 1)
            endif
         endif
      else
         EasyHelp("Arquivo não encontrado. Consulte o status da LI na rotina de transmissão ao Siscomex para obter o arquivo PDF.")
      endif
   Else
      if AvCpyFile( cPathPDF+cLIPDF , GetTempPath(.T.)+cLIPDF ,,.F.)
         ShellExecute("open", GetTempPath(.T.)+cLIPDF ,"","", 1)
      endif
   EndIf

Return
/*
Funcao    : GI400VerNVE()
Autor     : Guilherme Fernandes Pilan - GFP 	            
Data      : 06/12/2016
Retorna   : Exibe tela com relação de todas as NVEs por NCMs.
*/
*------------------------------*
Function GI400VerNVE(nOpc)
*------------------------------*
Local oDlg, oGetDb
Local cQuery := "", cFileWK_01, cFileWkEIM
Local i := 0, nOp := 0
Local aProd := {}, aButtons := {}, aSemSX3 := {}, aCamposWK := {}
Private aCampos[0], aHeader[0]

If Select("Work_NVE") # 0
   Work_NVE->(DbCloseArea())
EndIf

aAdd(aSemSX3,{"WK_TEC"  , "C", AVSX3("B1_POSIPI",3) ,0})
aAdd(aSemSX3,{"WK_NVE"  , "C", AVSX3("EIM_CODIGO",3),0})
aAdd(aSemSX3,{"WK_COD_I", "C", AVSX3("W5_COD_I",3)  ,0})

cFileWkEIM  := E_CriaTrab(,aSemSX3,"Work_NVE")
cFileWK_01 := E_Create(,.F.)
IndRegua("Work_NVE" ,cFileWK_01+TEOrdBagExt() ,"WK_TEC+WK_NVE+WK_COD_I")   
cFileWK_02 := E_Create(,.F.)
IndRegua("Work_NVE" ,cFileWK_02+TEOrdBagExt() ,"WK_NVE")  
SET INDEX TO (cFileWK_01+TEOrdBagExt()),(cFileWK_02+TEOrdBagExt())

If nOpc == 3 .OR. nOpc == 4
   Work->(DbGoTop())
   Do While Work->(!Eof())
      If (nOpc == 4 .OR. Work->WKFLAG) .AND. !Empty(Work->WKNVE) .AND. aScan(aProd,{|X| X[3] == Work->WKNVE}) == 0
         aadd(aProd,{Work->WKCOD_I,Work->WKTEC,Work->WKNVE})
      EndIf
      Work->(DbSkip())
   EndDo
Else
   TRB->(DbGoTop())
   Do While TRB->(!Eof())
      If !Empty(TRB->W5_NVE) .AND. aScan(aProd,StrTran(SubStr(TRB->W5_NBMTEC,1,At("/",TRB->W5_NBMTEC)-1),".","")) == 0
         aadd(aProd,{TRB->W5_COD_I,StrTran(SubStr(TRB->W5_NBMTEC,1,At("/",TRB->W5_NBMTEC)-1),".",""),TRB->W5_NVE})
      EndIf
      TRB->(DbSkip())
   EndDo
Endif

AADD(aCamposWK,{"WK_NVE"   ,"",AVSX3("W5_NVE"   ,5)})
AADD(aCamposWK,{"WK_TEC"   ,"",AVSX3("B1_POSIPI"  ,5)})
 
Work_NVE->(DbGoTop())
If nOpc # 2 .AND. Len(aProd) == 0
   Work_NVE->(avzap())
EndIf

If Len(aProd) # 0
   For i := 1 To Len(aProd)
      Work_NVE->(DbAppend())
      //Work_NVE->WK_COD_I := aProd[i][1]
      Work_NVE->WK_TEC   := aProd[i][2]
      Work_NVE->WK_NVE   := aProd[i][3]
   Next i
EndIf

Work_NVE->(DbSetOrder(2))
Work_NVE->(DbGoTop())

If nOpc == 2
   AADD(aButtons,{"NEXT"    ,{|| nOp := 2, oDlg:End() },"Visualizar" ,"Visualizar"})  //"Visualizar"
Else
   AADD(aButtons,{"NEXT"    ,{|| nOp := 3, oDlg:End() },STR0007 ,STR0007})  //"Incluir"
   If Work_NVE->(EasyRecCount("Work_NVE")) # 0
      AADD(aButtons,{"NEXT"    ,{|| nOp := 4, oDlg:End() },STR0008 ,STR0008})  //"Alterar"
      AADD(aButtons,{"NEXT"    ,{|| nOp := 5, oDlg:End() },STR0283 ,STR0283})  //"Excluir"
   EndIf
EndIf

DEFINE MSDIALOG oDlg TITLE STR0372 From DLG_LIN_INI,DLG_COL_INI To DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd Pixel //"Relação de NVEs do processo: "
   oDlg:lMaximized:=.T.
   Work_NVE->(DbSetOrder(0))

   oSelect := MSSELECT():New("Work_NVE",,,aCamposWK,,,{1,1,100,100},,,oDlg)
   oSelect:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   oSelect:oBrowse:bWhen:={|| .T.}
   oSelect:oBrowse:Refresh()

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOp := 0, oDlg:End()},{||nOp := 0, oDlg:End()},,aButtons) CENTERED

If nOp == 0
   Return {0,0,0}
Else
   nRecnoWkNVE := Work_NVE->(Recno())
   Work_NVE->(DbSetOrder(1))
   Work_NVE->(DbGoTo(nRecnoWkNVE))
   Return {Work_NVE->WK_NVE,Work_NVE->WK_TEC,nOp}
EndIf

Return NIL

/*
Funcao    : GI400WkEIM()
Autor     : Guilherme Fernandes Pilan - GFP 	            
Data      : 07/12/2016
Retorna   : Gravação da Work_EIM.
*/
*-----------------------------------*
Function GI400WkEIM(cPGI, cNVE, nOpc)
*-----------------------------------*
AvZap("Work_EIM")
EIM->(DbSetOrder(3))

//MFR 26/11/2018 OSSME-1483
IF EIM->(DbSeek(GetFilEIM("LI")+AvKey("LI","EIM_FASE")+AvKey(cPGI,"EIM_HAWB")+AvKey(cNVE,"EIM_CODIGO")))
   //MFR 26/11/2018 OSSME-1483
   DO While !EIM->(Eof()) .AND. EIM->EIM_FILIAL == GetFilEIM("LI") .AND. EIM->EIM_FASE == AvKey("LI","EIM_FASE") .AND. EIM->EIM_HAWB == AvKey(cPGI,"EIM_HAWB") .AND. EIM->EIM_CODIGO == AvKey(cNVE,"EIM_CODIGO")
      Work_EIM->(DBAPPEND())
      AVREPLACE("EIM","Work_EIM")
      EIM->(dbSkip())
   ENDDO   
ENDIF
EIM->(DBSETORDER(1))

If nOpc # 2
   Work->(DBGOTOP())
   DO WHILE Work->(!EOF())
      IF !Work->WKFLAG
         Work->(DBSKIP())
         LOOP
      ENDIF
      IF !EMPTY(Work->WKNVE) .AND. !Work_CEIM->(DBSEEK(Work->WKNVE))
         Work_CEIM->(DBAPPEND())
         AvReplace("Work_EIM","Work_CEIM")
         Work_CEIM->EIM_CODIGO:=Work->WKNVE
         Work_CEIM->WKTEC     :=Work->WKTEC
      ENDIF
      Work->(DbSkip())
   EndDo
ENDIF

Return NIL
