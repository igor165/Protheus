#INCLUDE "Eicpo400.ch"
#INCLUDE "Average.ch"
#INCLUDE "FWBROWSE.ch"//JL
#Include "EEC.ch"
#INCLUDE "TOPCONN.CH"

STATIC CONSULTA:="1"
STATIC ESTORNO :="2"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Constantes da funcao AVGravaSC7 - integracao com SIGACOM     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
STATIC INCLUSAO := 1
STATIC ALTERACAO:= 2
STATIC EXCLUSAO := 3

#DEFINE MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)
#DEFINE FINAL_ENCHOICE MEIO_DIALOG-1
#DEFINE COLUNA_FINAL   (oDlg:nClientWidth-4)/2
#DEFINE FINAL_SELECT   (oDlg:nClientHeight-6)/2
#DEFINE ENTER          CHR(13)+CHR(10)             // *** GFP 03/02/2011

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICPO401 ³ Autor ³ Crsitiano A. Ferreira ³ Data ³ 12/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Programa de Manutencao de P.O. de Nacionalizacao           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICPO401
EICPO400('N')

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³EICPO400  ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 13/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Programa de Manutencao de P.O.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICPO400(cPar,aCabAu,aItemAu,nOpcAu)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL i:=1, FileHelp, OldArea:=SELECT(), FileSW0
LOCAL aStru:={ {"WK_FABR","C",AvSx3("W3_FABR",3),0} ,{"WKNOME_FB","C",30,0},; //FCD SO0026
               {"TRB_ALI_WT","C",03,0},{"TRB_REC_WT","N",10,0} } //TRP - 25/01/07 - Campos do WalkThru



Local lRet:= .T.
LOCAL _PictItem := ALLTRIM(X3PICTURE("B1_COD"))
//ExecAuto no PO
Private lPOAuto := ( aCabAu <> NIL ) .And. ( aItemAu <> NIL )
Private lAlcada   := EasyGParam("MV_AVG0170",,.F.) // CCH - 08/06/09 - Verifica se o controle de alçadas está ligado
PRIVATE cMV_EASYFIN := GetNewPar("MV_EASYFIN","N")  // LDR
Private nOpcAuto:= nOpcAu
Private aCabAuto:= aCabAu
Private aCabItem:= aItemAu
Private aCorrespW3 := {} //AOM - 07/04/2011 - Estrutura DE/PARA da work da SW3 para trocas na Operação
PRIVATE lValidaData := .T., lSkip := .F.//ASR 25/08/2005 - VARIAVEL USADA NO PONTO DE ENTRADA "ANTES_GRAVA_WORK_SW3"
Private lPode_Alt := .T.
PRIVATE lTrava:= .F.
PRIVATE nOpcAux
Private TSeguro := 0
Private cCentroCusto // ACB - 18/03/2011 - enviao do centro de custo ao compras.
Private lEXECAUTO_COM := /*EasyGParam("MV_EIC0008",,.F.) FIXO TRUE OSSME-6437 MFR 06/12/2021 */ EasyGParam("MV_EASY",,"N") == "S"
Private nNum := 1, lCopiou := .F.  // GFP - 26/02/2013
//Private lMV_EIC_EAI := EasyGParam("MV_EIC_EAI",,.F.)
IF(EasyGParam("MV_EIC0044",,"1") == "2", lNewTelaSI := .T.,lNewTelaSI := .F.)//JL
Private cCotacao := "",cItem := "" // Utilizada para o novo filtro de SI quando integrado com o Logix
Private aCpos_SW2 := {}
InsNInco()//FSM - 28/12/10 - Inserir novos Incoterms (DAT/DAP) na base de dados
Private lEnvioOK :=.T.//JL
Private lPO400FIL:=.T.//IGOR CHIBA 23/07/14 TRATA DO OK DO PERGUNTE


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Modulo ativo eh o SIGAEIC                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ! AmIin(17)
   HELP("", 1, "AVG0000323")//MsgStop(STR0001,STR0002) //"Função não autorizada para este módulo !"###"Aviso"
   RETURN NIL
ENDIF
If lPoAuto
   If SW2->(FieldPos("W2_SIAUTO")) == 0 .OR. SW0->(FieldPos("W0_SIAUTO")) == 0
      EasyHelp(STR0324 ,STR0002) //STR0324 "Rotina não está preparada para utilizacao de ExecAuto. Favor contatar o suporte da Trade-Easy" STR0002 "Aviso
      Return Nil
   Endif
Endif
SX3->(DBSETORDER(2))
lCposAntecip:=SX3->(DBSEEK("WA_PGTANT")) .AND. SX3->(DBSEEK("WA_SLDANT")).AND.;//SO.:0058/02 OS.:0357/02 FCD variavel para verificar se existem os
              SX3->(DBSEEK("WA_PO_DI"))  .AND. SX3->(DBSEEK("WA_LINHA")) .AND.;// campos para o tratamento do pagamento antecipado.
              SX3->(DBSEEK("WB_PGTANT")) .AND. SX3->(DBSEEK("WB_PO_DI")) .AND.;
              SX3->(DBSEEK("WB_NUMPO"))  .AND. SX3->(DBSEEK("WB_LINHA")) .AND.;
              SIX->(DBSEEK("SWB5"))      .AND. SIX->(DBSEEK("SWA2"))     .AND.;
              SXB->(DBSEEK("EDP"))
SX3->(DBSETORDER(1))
SX3->(DBSEEK("SW2"))
IF lNewTelaSI//JL
  bWhileSx3 := {||!(SX3->X3_CAMPO $ "W2__DT_COT/W2__NR_COT").AND. X3Uso(SX3->X3_USADO)}
ELSE
  bWhileSx3 := {||X3Uso(SX3->X3_USADO)}
ENDIF

DO WHILE SX3->(!EOF()) .AND. SX3->X3_ARQUIVO == "SW2"//JL
   IF EVAL(bWhileSx3)
      AADD(aCpos_SW2,SX3->X3_CAMPO)
   ENDIF
   SX3->(DBSKIP())
ENDDO
If lCposAntecip
   lCposAntecip:= .T./*EasyGParam("MV_PG_ANT",,.F.) */ // NCF - 15/05/2020 - Parametro descontinuado  // Jonato em 17/Agosto/2004
ENDIF
EICAddWkLoja(aStru, "W3_FABLOJ", "WK_FABR")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³      1 - Pesquisa e Posiciona em um Banco de Dados           ³
//³      2 - Simplesmente Mostra os Campos                       ³
//³      3 - Inclui registros no Bancos de Dados                 ³
//³      4 - Altera o registro corrente                          ³
//³      5 - Remove o registro corrente do Banco de Dados        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cProg, lFilDa:=EasyGParam("MV_FIL_DA")
PRIVATE cMV_EASY := EasyGParam("MV_EASY")  // LDR
IF(cPar=NIL,cProg:="PO",cProg:="PN")
PRIVATE lCancel := .F.,funccanc ,cMotivo:=""
PRIVATE nLenFabr:=AVSX3("A2_COD",3) //SO.:0026 OS.: 0243/02 FCD
PRIVATE nLenForn:=AVSX3("A2_COD",3) //SO.:0026 OS.: 0243/02 FCD
PRIVATE nLenCli :=AVSX3("A1_COD",3) //SO.:0026 OS.: 0243/02 FCD
PRIVATE nLenCC  :=AVSX3("W0__CC",3) //SO.:0026 OS.: 0243/02 FCD
PRIVATE nLenSi  :=AVSX3("W0__NUM",3)//SO.:0026 OS.: 0243/02 FCD
PRIVATE nLenOK  :=AVSX3("W2_OK",3)  //SO.:0026 OS.: 0243/02 FCD
PRIVATE aRotina := MenuDef(.T., If(cPar == "PO", ProcName(), ProcName(1)))
PRIVATE lRegTriPO := SW3->(FieldPos("W3_GRUPORT")) # 0 .AND. SIX->(dbSeek("EIJ2"))
PRIVATE aCores := {}
Private cFilBrow  := ""

PRIVATE lNotPOErroAuto:= .T.

Private __KeepUsrFiles //Tratamento específico para manter arquivos de trabalho - Vide EECAE109.

//Habilita Legenda
IF AvFlags("EIC_EAI")
   AAdd(aCores, {"SW2->W2_CONAPRO == '1' "  , "BR_VERDE"       })
   AAdd(aCores, {"SW2->W2_CONAPRO <> '1'"   , "BR_VERMELHO"    })
ELSEIF cMV_EASY $ cSim .And. lAlcada
   AAdd(aCores, {"SW2->W2_CONAPRO == 'B' "  , "BR_AZUL"        })
   AAdd(aCores, {"SW2->W2_CONAPRO == 'R' "  , "BR_VERMELHO"    })
   AAdd(aCores, {"SW2->W2_CONAPRO == 'L' .or. empty(SW2->W2_CONAPRO) "  , "BR_VERDE"   })
ENDIF

//BHF - 10/07/2008
IF EasyEntryPoint("EICPO400")
   ExecBlock("EICPO400",.F.,.F.,"AROTINA")
ENDIF

__KeepUsrFiles:= SaveTempFiles() //Tratamento específico para manter arquivos de trabalho - Vide EECAE109.

//IF cProg#"PN"
//   EICPO410(1)
//ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro:= IF(cProg#"PN",STR0008,STR0221) //"Purchase Order"
PRIVATE aCampos  :={}
PRIVATE cNomeW3,cNomeW1,aSolic:={},lCopiaPO:=.F.,lSiCopia:=.F.,lSiReferencia:=.F.  //Variaveis para copia do P.O.
PRIVATE bSeek :={||SW3->(DBSEEK(xFilial()+SW2->W2_PO_NUM)) }
PRIVATE bWhile:={||xFilial("SW3") = SW3->W3_FILIAL  .AND. ;
                   SW3->W3_PO_NUM = SW2->W2_PO_NUM }, bFor:={||.T.}

PRIVATE TInland, TPacking,TDesconto, TFreteIntl,TOutDesp,TSeguro
PRIVATE FileWork, WorkNTX2, cWkPO_EIJ
PRIVATE cMarca := GetMark(), lInverte := .F.
PRIVATE nSeq_SLi:=SPACE(10)
PRIVATE aPLIs    := {}
PRIVATE nPosicao := VAL(SW2->W2_POSICAO)
PRIVATE lPOdaIntegracao:=.F.
PRIVATE cLitPerg := STR0009 //"Estorno"
SX3->(DBSETORDER(2))
PRIVATE lCancelaSaldo    :=EasyGParam("MV_CANSALD") $ cSim
PRIVATE lExiste_Midia    :=EasyGParam("MV_SOFTWAR") $ cSim
SX3->(DBSETORDER(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variavel para o Ponto de Entrada "SelecionaSI"          |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cRecSTR:= STR0053
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variavel indicando se o cliente usa ForeCast            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lForeCast := (AllTrim(EasyGParam("MV_FORECAS"))$cSim)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis para NEC, NESTLE, SEAL...                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cArqRdmake:= "EICPONEC"
PRIVATE cArqNestle:= "PONESTLE"
PRIVATE lSeal  := EasyEntryPoint("IC193PO1"), cSay1, cSay2
PRIVATE lHunter:= EasyEntryPoint("IC010PO1")//AWR 09/11/1999
PRIVATE lNec   := EasyEntryPoint(cArqRdmake)
PRIVATE lNestle:= EasyEntryPoint(cArqNestle)
PRIVATE lNobel := EasyEntryPoint("IC163PO1")
PRIVATE lRdMake:= EasyEntryPoint("EICPPO02")
PRIVATE cPrice := 0, aGetsNaciona
PRIVATE lLibQt := GETNEWPAR("MV_LIBQTEM", .F.) //PARA ACEITAR SALDO DE QTDE. NEGATIVO (THISSEN)
Private lSolic:=.T., aFornSW1 := {}  // EOS - OS 486/02 Inclusao de SI de referencia
Private _PictPrUn := ALLTRIM(X3Picture("W3_PRECO")), _PictPO := ALLTRIM(X3Picture("W2_PO_NUM"))
Private _PictQtde := ALLTRIM(X3Picture("W3_QTDE")), _PictPrTot := ALLTRIM(X3Picture("W2_FOB_TOT"))
Private cFiltro   := ""

Private cDESC_PO:= EasyGParam("MV_DESC_PO",,"I") // JVR - 05/01/10 - Inserido seleção da descrição por parametro."I/P/GI"
If(!(cDesc_PO $ "I/P/GI"), cDESC_PO := "I",)

Private lCpoCtCust := (EasyGParam("MV_EASY")$cSim) .And. SW3->(FIELDPOS("W3_CTCUSTO")) > 0 // NCF - 22/06/2010 - Flag do campo de Centro de Custo

Private lPesoBruto := SW3->(FieldPos("W3_PESO_BR")) > 0 .And. SW5->(FieldPos("W5_PESO_BR")) > 0 .And. SW7->(FieldPos("W7_PESO_BR")) > 0 .And.;
                      SW8->(FieldPos("W8_PESO_BR")) > 0 .And. EasyGParam("MV_EIC0014",,.F.) //FSM - 02/09/2011 - Campo de peso bruto unitario

Private aCorrespWork := {} //AOM - 07/04/2011 - Array para manipular as work no objeto de Operações Especiais

//AOM - 14/04/2011 - Flag para verificar se Operação Especial está habilitada
Private lOperacaoEsp := AvFlags("OPERACAO_ESPECIAL") .And. !lPOAuto

Private lPedNac := cProg == "PN" // GFP - 26/03/2014

Private oUpdAtu //BAK - 22/08/11
Private oBufferUM:= tHashMap():New() //bufferização da busca pela unidade de medida

/*
If GetRemoteType() == 5 //LGS-28/06/2016
   AjustaSmartHtml()
EndIf
*/
//Flag para buffer do avsx3()
//AvlSX3Buffer(AvFlags("EIC_EAI")) //RMD - 21/03/19 - Utiliza sempre o buffer, independente do ERP
AvlSX3Buffer(.T.)

   If ChkFile("EJ2") .And. !EJ2->(DbSeek(xFilial()))  // RMD - 28/03/2013
      //BAK - Tratamento para carga padrão das tabelas EJ0, EJ1, EJ2 - 22/08/2011
      If FindFunction("AvUpdate01")
         oUpdAtu := AvUpdate01():New()
      EndIf

      If ValType(oUpdAtu) == "O" .AND. &("MethIsMemberOf(oUpdAtu,'TABLEDATA')") .AND. Type("oUpdAtu:lSimula") == "L"
         If ChkFile("EJ0") .And. ChkFile("EJ1") .And. ChkFile("EJ2")
            oUpdAtu:aChamados := {{nModulo,{|o| EIDadosEJ0(o)}}}
            oUpdAtu:Init(,.T.)
         EndIf
      EndIf
   EndIf

//AOM - 07/04/2011 - Itens PO para operações especiais
AADD(aCorrespW3,{"W3_COD_I"   ,"WKCOD_I"     })
AADD(aCorrespW3,{"W3_FABR"    ,"WKFABR"      })
AADD(aCorrespW3,{"W3_FORN"    ,"WKFORN"      })
AADD(aCorrespW3,{"W3_REG"     ,"WKREG"       })
AADD(aCorrespW3,{"W3_FLUXO"   ,"WKFLUXO"     })
AADD(aCorrespW3,{"W3_QTDE"    ,"WKQTDE"      })
AADD(aCorrespW3,{"W3_PRECO"   ,"WKPRECO"     })
AADD(aCorrespW3,{"W3_SALDO_Q" ,"WKSALDO_Q"   })
AADD(aCorrespW3,{"W3_CC"      ,"WKCC"        })
AADD(aCorrespW3,{"W3_SI_NUM"  ,"WKSI_NUM"    })
AADD(aCorrespW3,{"W3_PO_NUM"  ,"WKPO_NUM"    })
AADD(aCorrespW3,{"W3_DT_EMB"  ,"WKDT_EMB"    })
AADD(aCorrespW3,{"W3_DT_ENTR" ,"WKDT_ENTR"   })
AADD(aCorrespW3,{"W3_SEQ"     ,"WKSEQ"       })
AADD(aCorrespW3,{"W3_PORTARI" ,"WKPORTARIA"  })
AADD(aCorrespW3,{"W3_FABR_01" ,"WKFABR_01"   })
AADD(aCorrespW3,{"W3_FABR_02" ,"WKFABR_02"   })
AADD(aCorrespW3,{"W3_FABR_03" ,"WKFABR_04"   })
AADD(aCorrespW3,{"W3_FABR_05" ,"WKFABR_05"   })
AADD(aCorrespW3,{"W3_POSICAO" ,"WKPOSICAO"   })
AADD(aCorrespW3,{"W3_REG_TRI" ,"WK_REG_TRI"  })
AADD(aCorrespW3,{"W3_TEC"     ,"WK_TEC"      })
AADD(aCorrespW3,{"W3_EX_NCM"  ,"WK_EX_NCM"   })
AADD(aCorrespW3,{"W3_EX_NBM"  ,"WK_EX_NBM"   })
AADD(aCorrespW3,{"W3_SEM_PED" ,"WKSEM_PO"    })
AADD(aCorrespW3,{"W3_QTD_EMB" ,"WKQTDE_EMB"  })
AADD(aCorrespW3,{"W3_PESOL"   ,"WKPESOL"     })
AADD(aCorrespW3,{"W3_REG_MIN" ,"WK_REG_MIN"  })
AADD(aCorrespW3,{"W3_FORECAS" ,"WK_FORECAS"  })
AADD(aCorrespW3,{"W3_PART_N"  ,"WKPART_N"    })
AADD(aCorrespW3,{"W3_SOFTWAR" ,"WKSOFTWAR"   })
AADD(aCorrespW3,{"W3_SLD_ELI" ,"WKSLD_ELI"   })
AADD(aCorrespW3,{"W3_CTCUSTO" ,"WKCTCUSTO"   })


aOrdSX3 := SaveOrd("SX3",1) //LGS-28/06/2016
SX3->(dbSeek("SW3"))
Do While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SW3"
   If SX3->X3_PROPRI=="U" .AND. X3Uso(SX3->X3_USADO) .AND. X3Obrigat(SX3->X3_CAMPO)
      AADD(aCorrespW3,{AllTrim(SX3->X3_CAMPO) ,AllTrim(SX3->X3_CAMPO) })
   EndIf
   SX3->(dbSkip())
EndDo
RestOrd(aOrdSX3,.T.)

//Adicionando na Work de correspondencia
aAdd(aCorrespWork,{"SW3","Work",aCorrespW3   })

M->W3_SHIP_DT  := AVCTOD("")//Variavel para a SEAL
M->W3_SHIP_RE  := AVCTOD("")//Variavel para a SEAL
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Variaveis com nome dos campos de Bancos de Dados        ³
//³ para serem usadas na funcao de inclusao                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/* wfs mar/2017 - adequação para uso do EECCRIATRAB(), com a passagem do 7º parâmetro*/
FileHelp:= e_criatrab(,aStru,"Work_Hlp",,,, SaveTempFiles())

aHeader:={}
aCampos:={"W1_SI_NUM"}

aSemSX3:= {{"WKSI_ORI","C",AVSX3("W1_SI_NUM" ,3),0},;
           {"W0_C1_NUM","C",AVSX3("W0_C1_NUM",3),0}}

//TRP - 25/01/07 - Campos do WalkThru
AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
AADD(aSemSX3,{"TRB_REC_WT","N",10,0})

IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"Work_SI"),) //SVG - 04/08/2009 -

/* wfs mar/2017 - adequação para uso do EECCRIATRAB(), com a passagem do 7º parâmetro */
FileSW0:=E_CriaTrab(,aSemSX3,"Work_SI",,,, SaveTempFiles())

/* wfs mar/2017 - adequação para uso do EECIndRequa */
E_IndRegua("Work_SI",FileSW0+TEOrdBagExt(),"W1_SI_NUM")
Set Index to (FileSW0+TEOrdBagExt())

DbSelectArea("SW2")

aCampos:=ARRAY(FCOUNT())

bSetKey:=SetKey(VK_F12)

//ASK 13/02/07 11:22 - Incluso no AtuSx do P9R1
//SX1->(DBSETORDER(1))
IF cMV_EASYFIN = "S" //.AND. SX1->(DBSEEK("EICFI4"))
   SetKey (VK_F12,{|| Pergunte("EICFI4",.T.) })
   Pergunte("EICFI4",.F.)
ENDIF
lNoBaixa:=.T.//Esta variavel deve ser mantida para compatibilidade com os
//Antigos Clientes que a utilizao. (AWR) 5 de Abril de 2001.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SA5->(DBSETORDER(3))
SW5->(DBSETORDER(3))

IF(EasyEntryPoint("EICPOITE"),ExecBlock("EICPOITE",.F.,.F.,"MENU"),)

PO_Filter(.T.)
If ( Type("lPOAuto") == "U" .OR. !lPOAuto )
   geraBrowse()
Else

   Begin Transaction

   Default nOpcAuto := 3
   MBrowseAuto(nOpcAuto,aCabAuto,"SW2",,.T.)  // GFP - 23/08/2013

   If !lNotPOErroAuto
      RollBackDelTran("")
   EndIf

   End Transaction
Endif

SA5->(DBSETORDER(1))
SW5->(DBSETORDER(1))
PO_Filter(.F.)

SetKey(VK_F12,bSetKey)

/* wfs mar/2017 - adequação para uso do EECEraseArq(), com a passagem do 4º parâmetro */
Work_Hlp->(E_EraseArq(FileHelp,,, SaveTempFiles()))
Work_SI->(E_EraseArq(FileSW0,,, SaveTempFiles()))

DBSELECTAREA(OldArea)

//desativa flag de uso do buffer do avsx3
AvlSX3Buffer(.F.)

Return lRet

/*
Funcao     : geraBrowse()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Gera o browse
Autor      : Maurício Frison
Data/Hora  : maio/2020
*/
Static Function geraBrowse()
Local aLegenda := {}
Local lLegenda := .F.

   oBrowse := FWmBrowse():New()
   oBrowse:SetDescription(STR0008) //"Purchase Order"
   oBrowse:SetAlias("SW2")
   oBrowse:DisableDetails()
   oBrowse:ForceQuitButton()
   oBrowse:SetAttach( .T. )

   IF cMV_EASY $ cSim .And. lAlcada
      oBrowse:SetViewsDefault(GetVisions())
   ENDIF

   if len(aCores) > 0
      lLegenda := .T.
      aEval(aCores, {|x| aadd(aLegenda, x ) } )
   endif

   if lLegenda
      aEval(aLegenda, {|x| oBrowse:AddLegend(x[1], x[2]) }) 
   EndIf

   If !Empty(cFilBrow)
      oBrowse:SetFilterDefault(cFilBrow)
   EndIf

   //Habilita a exibição de visões e gráficos
   oBrowse:SetMenuDef("EICPO400")
   //oBrwDespNac:CIDVIEWDEFAULT := '1' //View Despesa como Default
   oBrowse:Activate()

return .t.
/*
Função     : GetVisions()
Objetivo   : Retorna as visões definidas para o Browse
*/
Static Function GetVisions()
Local oDSView
Local aVisions := {}
Local aColumns := aClone(aCpos_SW2)
Local aContextos := {STR0422,STR0423,STR0424} //"Bloqueado/Em aprovação" "Reprovado" e "Aprovado"
Local i
aSize(aColumns,len(aColumns)+1)
AINS(aColumns, 1)  
aColumns[1]:='W2_FILIAL'
For i := 1 To Len(aContextos)
    oDSView := FWDSView():New()
    oDSView:SetName(AllTrim(Str(i)) + "-" + aContextos[i])
    oDSView:SetPublic(.T.)
    oDSView:SetCollumns(aColumns)
    oDSView:SetOrder(1)
    oDSView:SetID(AllTrim(Str(i)))
    oDSView:AddFilter( AllTrim(Str(i)) + "-" + aContextos[i] , if(i==1, 'W2_CONAPRO=="B"',if(i==2, 'W2_CONAPRO=="R"', 'W2_CONAPRO=="L"')))
    aAdd(aVisions, oDSView)
Next

Return aVisions


/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 25/01/07 - 14:50
*/
Static Function MenuDef(lMBrowse, cOrigem)
Local aRotAdic := {}
Private aRotina :=  { { STR0003,"AxPesqui"  , 0 , 1},; //"Pesquisar"
                    { STR0004,"PO400Visua", 0 , 2} } //"Visual"
PRIVATE cMV_EASY := EasyGParam("MV_EASY")  // LDR
Private lAlcada   := EasyGParam("MV_AVG0170",,.F.) // CCH - 08/06/09 - Verifica se o controle de alçadas está ligado

Default cOrigem  := AvMnuFnc()
//Default lMBrowse := .F. - Nopado pois é necessário retornar todas as opções da rotina. Apenas o menufuncional não pode exibi-las (funcao GETMENUDEF é do menu funcional).
Default lMBrowse := OrigChamada()

cOrigem := Upper(AllTrim(cOrigem))

IF(Type("cProg") == "U"  , cProg   := "PO" , )
IF(Type("lPedNac") == "U", lPedNac := !(lMBrowse .And. cProg # "PN") , )
IF(Type("lPO") == "U"    , lPO     := !lMBrowse .And. cOrigem $ "EICPO400" , )

If !lPedNac .Or. lPO
   Aadd(aRotina,{ STR0005,"PO400Inclu", 0 , 3}) //"Inclui"
EndIf

/*ISS- 01/09 - O botão "Alterar" não deve ser exibido na rotina "Pedido de Nacionalização", pois
               ao alterar um pedido de nacionalização o sistema vai procurar informações deste processo
               em outros módulos (caso tenha integrações ativadas) e com isso pode gerar erros ou faturas e títulos
               indevidos, uma vez que o sistema ira tratar a PN como se fosse um PO. */
//If !lPedNac  // NCF - 16/06/2011 - nopado - a alteração deve ser permitida somente para a anuência ou não dos itens.
   Aadd(aRotina,{ STR0006,"PO400Alter", 0, 4 }) //"Altera"
//EndIf

Aadd(aRotina,{ STR0007,"PO400Estor", 0, 5 }) //"Estorna"
AAdd( aRotina, { STR0289, "MsDocument", 0, 4 } ) //STR0289 = "CONHECIMENTO" //"Conhecimento" - DRL 08/09/09
If !lPedNac .Or. lPO .Or. cPaisLoc != "BRA"
   Aadd(aRotina,{ STR0269,"PO400ZERA" , 0, 2 }) //"Elimina Saldo" //ASK
EndIf
If lPedNac
   Aadd(aRotina,{ STR0282,"PO400Prorrog", 0, 4 }) //"Prorrogar"
EndIf

//IGOR CHIBA  26/05/14 se tiver ativo envio EAI criar legenda
IF AvFlags("EIC_EAI")//EasyGParam("MV_EIC_EAI",,.F.)
   Aadd(aRotina,{ STR0391,"PO400LEG", 0, 2 }) //"Legenda"
ELSEIF cMV_EASY $ cSim .And. lAlcada
   Aadd(aRotina,{ STR0391,"PO400ALC", 0, 2 }) //"Legenda"
ENDIF

If AvFlags("AVINT_PR_EIC")
   Aadd(aRotina, {STR0405, "PO400Prov", 0, 2}) //"Despesas provisórias"
EndIf

if existfunc("PO151Imp")
   aAdd( aRotina, {STR0435, "PO151Imp", 0, 2} ) // "Impressão"
endif

//LRS - 09/11/2017
IF cProg#"PN"
   EICPO410(1)
ENDIF

// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("IPO400MNU")
	aRotAdic := ExecBlock("IPO400MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³PO400Visua³ Autor ³ PADRAO PARA GETDADDB  ³ Data ³ 12.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Programa para visualizacao dos Itens da SI                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void PO400Visua(ExpC1,ExpN1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PO400Visua(cAlias,nReg,nOpc)

LOCAL nOpca := 0,cSavMenuh,I,nInd
LOCAL oDlg, oGet
LOCAL oSelVis,oEncVis //LRL 18/03/04 - Criados para alinhamento na versão MDI
LOCAL cAlias1:="SW3", FileWork
LOCAL _LIT_R_CC := IF(EMPTY(ALLTRIM(EasyGParam("MV_LITRCC"))),(AVSX3("W0__CC",5)), ALLTRIM(EasyGParam("MV_LITRCC")))
LOCAL _PictItem := ALLTRIM(X3PICTURE("B1_COD"))
LOCAL _PictSI   := ALLTRIM(X3PICTURE("W0__NUM"))

PRIVATE nQtdEmb:=0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0],aHeader[0]
PRIVATE MConta:=MTotal:=0, TPO_NUM:=SW2->W2_PO_NUM

PRIVATE aBotoes := {}   //TRP-17/03/08- Array utilizado em rdmake- Chamado 072098
//ISS - 29/04/11 -
Private lTrataPgAntecipado := .T.

lSair := .F.

//AOM - 14/04/2011 - Operacao Especial
If lOperacaoEsp
   Private oOperacao := EASYOPESP():New() //AOM - 07/04/2011 - Inicializando a classe para tratamento de operações especiais
EndIf
IF lRegTriPO
   AADD(aBotoes, {"PRECO" ,{|| PO400RegPesq() },STR0411, STR0411}) //"Regime de Tributacao","Reg.Trib."// JWJ 21/10/09
ENDIF

nOpcAux:= nOpc
lMod_Alter := .F.

If ! EICPO400PROG()
   Return .F.
EndIf

TPO_SIGA:=SW2->W2_PO_SIGA //AWR 9/6/99

dbSelectArea(cAlias)
IF EasyRecCount() == 0
   Return (.T.)
EndIf

// *** CAF 17/03/1999 E_Inclui ja cria as variaveis. SW2->(E_InitVar())

SW3->(DBSETORDER(7))
IF !SW3->(DBSEEK(xFilial()+SW2->W2_PO_NUM))
   Help(" ",1,"E_NAOHAITE")
ENDIF

If !PO400GeraWork(@FileWork,CONSULTA)
   Return
Endif

IF MTotal = 0
   Help(" ",1,"E_NAOHAITE")
ENDIF

TB_Campos:={}
bQtde_Emb:={||IF(Work->WKFLUXO=="7",TRANSFORM(Work->WKQTDE_EMB,_PictQtde), STR0010 )} //'   Anuencia    '
bQtde_LI :={||IF(Work->WKFLUXO=="1",TRANSFORM(Work->WKQTDE_LI,_PictQtde), STR0290 )} //'   Nao Anuente    '
//bQtde    :={||IF(Work->WKFLUXO=="1",TRAN(Work->(WKQTDE_LI+WKSALDO_Q),_PictQtde),TRAN(Work->WKSALDO_Q,_PictQtde))} //'   Nao Anuente    '

bTotal:={||TRANSFORM(Work->WKQTDE*Work->WKPRECO,_PictPrTot)}

AADD(Tb_Campos,{{||PO400PESQ('CC')},,_LIT_R_CC })
AADD(Tb_Campos,{"WKSI_NUM",,STR0011,_PictSI}) //"No.SI"
AADD(Tb_Campos,{"WKPOSICAO",,STR0012}) //"Posicao"
AADD(Tb_Campos,{"WKCOD_I" ,,STR0013,_PictItem}) //"Item"
AADD(Tb_Campos,{"WKPART_N",,STR0014}) //"Part Number"

If cPaisLoc=="BRA"
   AADD(Tb_Campos,{{||IF(Work->WKFLUXO=='7',STR0015,STR0016)},,STR0017}) //'Nao'###'Sim'###"Anuencia"
EndIf

IF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"7"),)//AWR 09/11/1999

AADD(Tb_Campos,{"WKDESCR" ,,AVSX3("B1_DESC_"+cDESC_PO,AV_TITULO)}) //"Descricao em ###"
AADD(Tb_Campos,{{||PO400PESQ('FB')},,STR0019}) //"Fabricante"
//AADD(Tb_Campos,{{||PO400PESQ('FO')},,"Fornecedor"})  // VI 08/10/99

IF lExiste_Midia .AND. !EMPTY(SW2->W2_VLMIDIA)//AWR 21/10/1999
   AADD(Tb_Campos,{"WK_QTMIDIA",,AVSX3("B1_QTMIDIA",5),AVSX3("B1_QTMIDIA",6)})
   AADD(Tb_Campos,{"WK_VLTOTMI",,STR0021,AVSX3("W2_VLMIDIA",6)}) //"Vlr. Total Midia"
ENDIF

AADD(Tb_Campos,{"WKQTDE"   ,,STR0022,_PictQtde}) //"Quantidade"

IF AvFlags("EIC_EAI")//AWF - 25/06/2014
   AADD(Tb_Campos,{"WKUNI"  ,,AVSX3("W3_UM",AV_TITULO)})
ELSE
   IF EICLOJA()
      AADD(Tb_Campos,{{||BUSCA_UM(Work->WKCOD_I+Work->WKFABR+Work->WKFORN,WORK->WKCC+WORK->WKSI_NUM,WORK->W3_FABLOJ,WORK->W3_FORLOJ)},,STR0020})
   ELSE
      AADD(Tb_Campos,{{||BUSCA_UM(Work->WKCOD_I+Work->WKFABR+Work->WKFORN,WORK->WKCC+WORK->WKSI_NUM,"","")},,STR0020}) //"Uni"
   ENDIF
ENDIF

IF AvFlags("EIC_EAI")//AWF - 25/06/2014
   AADD(Tb_Campos,{"WKQTSEGUM",,AVSX3("W3_QTSEGUM",AV_TITULO),AVSX3("W3_QTSEGUM" ,6)})
   AADD(Tb_Campos,{"WKSEGUM"  ,,AVSX3("W3_SEGUM",AV_TITULO)})
   If SW0->(FieldPos("W0_REFER1")) > 0 //NCF - 26/09/2016
      AADD(Tb_Campos,{"WKREFER1"  ,,AVSX3("W0_REFER1",AV_TITULO)})
   EndIf
ENDIF

IF cPaisLoc=="BRA"
   AADD(Tb_Campos,{bQtde_Li   ,,AVSX3("W3_QTD_LI")[5]}) //"Qtde em LI"
ENDIF
If SW3->(FieldPos("W3_PESOL")) # 0 //CCH - 07/08/09 - Inclusão do peso líquido unitário
   AADD(Tb_Campos,{"WKPESOL",,AVSX3("W3_PESOL",5),AVSX3("W3_PESOL",6)})
EndIf
//AADD(Tb_Campos,{bQtde_Emb  ,,STR0023}) //"Qtde Embarcada"
AADD(Tb_Campos,{"WKQTDE_EMB",,STR0023,_PictQtde}) //"Qtde Embarcada"
AADD(Tb_Campos,{"WKSALDO_Q",,STR0024,_PictQtde}) //"Saldo Qtde" - ASK 28/03/07
//AADD(Tb_Campos,{{|| PO400Saldo() },,STR0024,_PictQtde}) //"Saldo Qtde" - AWR 19/04/04
AADD(Tb_Campos,{"WKSEM_PO" ,,AVSX3("W3_SEM_PED")[5],AVSX3("W3_SEM_PED",6)})
AADD(Tb_Campos,{"WKPRECO"  ,,STR0025,_PictPrUn}) //"Preco Unit"
AADD(Tb_Campos,{bTotal,,STR0026}) //"Valor Total"
AADD(Tb_Campos,{"WKDT_EMB" ,,STR0027}) //"Embarque"
AADD(Tb_Campos,{"WKDT_ENTR",,STR0028}) //"Entrega"

If lNestle
   ExecBlock(cArqNestle,.F.,.F.,"8")
Endif

IF lRdMake
   ExecBlock("EICPPO02",.F.,.F.,"15")
ENDIF

If lForeCast
   AADD(Tb_Campos,{{||IF(WK_FORECAS=="S",STR0029,STR0030)},,STR0031}) //CAF 22/10/98 //"Sim"###"Nao"###"Forecast"
Endif

AADD(Tb_Campos,{{||SX5->(dbSeek(xFilial()+"Y2"+Work->WK_REG_TRI)),AllTrim(X5DESCRI())},,AVSX3("W3_REG_TRI")[5]})
AADD(Tb_Campos,{"WK_REG_MIN",,OemToAnsi(STR0032)}) //AWR 22/4/98 //"Registro no Minist‚rio / OrgÆo P£blico"
AADD(Tb_Campos,{"WK_TEC"   ,,AVSX3("W3_TEC"   )[5]})
AADD(Tb_Campos,{"WK_EX_NCM",,AVSX3("W3_EX_NCM")[5]})
AADD(Tb_Campos,{"WK_EX_NBM",,AVSX3("W3_EX_NBM")[5]})
IF cPaisLoc # "BRA"  .AND. SW1->(FIELDPOS("W1_NATUREZ")) # 0
   AADD(TB_Campos,{"WKNATUREZA",,AVSX3("W1_NATUREZ",5)})
ENDIF


//AOM - 12/04/2011 - Adiciona na Tela de visualização as operações especiais
If lOperacaoEsp
  AADD(Tb_Campos,{"W3_CODOPE",,AVSX3("W3_CODOPE")[5]})
  AADD(Tb_Campos,{"W3_DESOPE",,AVSX3("W3_DESOPE")[5]})
EndIf

//TRP- 01/06/09 - Campo Software para novo Tratamento de Mídia e Software
If SW3->(FieldPos("W3_SOFTWAR")) # 0 .And. EasyGParam("MV_CONSOFT",, "N") $ cSim
   AADD(Tb_Campos,{{||IF(Work->WKSOFTWAR=='2',STR0015,STR0016)},,AVSX3("W3_SOFTWAR",5)})
Endif

If lCpoCtCust
   AADD(Tb_Campos,{"WKCTCUSTO",,AVSX3("W3_CTCUSTO",5),AVSX3("W3_CTCUSTO",6)})
EndIf
If lPesoBruto                                                                   //NCF - 25/08/2011 - Campo do Peso Bruto Unitário
   AADD(Tb_Campos,{"WKPSBRUTO",,AVSX3("W3_PESO_BR",5),AVSX3("W3_PESO_BR",6)})
EndIf

If AvFlags("RATEIO_DESP_PO_PLI")
   AADD(Tb_Campos,{"WKFRETE",,AVSX3("W3_FRETE",5)  ,AVSX3("W3_FRETE",6)})
   AADD(Tb_Campos,{"WKSEGUR",,AVSX3("W3_SEGURO",5) ,AVSX3("W3_SEGURO",6)})
   AADD(Tb_Campos,{"WKINLAN",,AVSX3("W3_INLAND",5) ,AVSX3("W3_INLAND",6)})
   AADD(Tb_Campos,{"WKDESCO",,AVSX3("W3_DESCONT",5),AVSX3("W3_DESCONT",6)})
   AADD(Tb_Campos,{"WKPACKI",,AVSX3("W3_PACKING",5),AVSX3("W3_PACKING",6)})
   If SW3->(FieldPos("W3_OUT_DES")) > 0
      AADD(Tb_Campos,{"WKOUTDE",,AVSX3("W3_OUT_DES",5),AVSX3("W3_OUT_DES",6)})
   EndIf
EndIf

IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"BROWSE_VISUALIZAR"),)

IF(lSeal,ExecBlock("IC193PO1",.F.,.F.,"1"),) //AWR 01/10/1999

TB_Campos:= AddCpoUser(TB_Campos,"SW3","2")

// *** CAF 09/09/1998 10:53
FOR nInd := 1 TO SW2->(FCount())
   SW2->( M->&(FIELDNAME(nInd)) := FieldGet(nInd) )
NEXT
// *** CAF 09/09/1998 10:53

If Type("lPOAuto") == "U"
   lPOAuto:= .F.
EndIf 

While .T.
   If !lPOAuto  // GFP - 26/08/2013
      oMainWnd:ReadClientCoords()
   EndIf
   DEFINE MSDIALOG oDlg TITLE IF(!Empty(M->W2_HAWB_DA),STR0222+AllTrim(TRANSFORM(M->W2_HAWB_DA,AVSX3("W2_HAWB_DA",6))),cCadastro) ; //"Pedido de Nacionalização - DA: "
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
          OF oMainWnd PIXEL

   oEncVis:=MsMget():New(cAlias,nReg,nOpc,,,,,{15,1,FINAL_ENCHOICE,COLUNA_FINAL},,3,,,,oDlg)

   dbSelectArea("Work")
   dbGoTop()

   oSelVis:=MsSelect():New("Work",,,TB_Campos,@lInverte,@cMarca,{FINAL_ENCHOICE+1,1,FINAL_SELECT,COLUNA_FINAL,oDlg})

   oEncvis:oBox:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oSelVis:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oSelVis:oBrowse:Refresh() //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oDlg:lMaximized:=.T.

   aAdd(aBotoes,{/*<Resource (Depreciado)>*/,/*<Action>*/, STR0379,STR0379,,,GetOrders(oSelVis:oBrowse)} )
   //DFS - 31/01/13 - Inclusão de refresh na tela para atualizar os itens.
   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nopca:=2,oDlg:End()},{||oDlg:End()},,aBotoes),oSelVis:oBrowse:Refresh())//LRL 18/03/04 - Para Alinhamento na versão MDI //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   Exit
Enddo
IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"FIM_VISUALIZACAO"),)

//AOM - 07/04/11
If lOperacaoEsp
   oOperacao:DeleteWork()
EndIf

PO_Final(FileWork,WorkNTX2)

DBSELECTAREA("SW2")

Return( nOpca )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PO400Inclu³ Autor ³ PADRAO PARA GETDADDB  ³ Data ³ 13.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa exclusivo para inclusao de S.I.                   ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void PO400Inclu(ExpC1,ExpN1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PO400Inclu(cAlias,nReg,nOpc)
Local cFilterOld,nInd
Local lRet := .T.

PRIVATE MTem_Guia := .F., WFlag:='1'
PRIVATE nQtd_Gi,nSld_Gi, MTotal,lTudoOK
PRIVATE aButtons:={}
PRIVATE MExiste:=.F., TCc,TSi_Num, TPO_NUM, TPO_SIGA ,cSiOri//Solicitacao Original
PRIVATE oDlgPrv, bOkPrv,cIndex,cIndex4
PRIVATE aBotoesInc := {}  //TRP-03/04/08
Private lDepoisGrvIncPO := .F. //GFP - 18/04/2016
//AOM - 14/04/2011 - Operacao Especial
If lOperacaoEsp
   Private oOperacao := EASYOPESP():New() //AOM - 07/04/2011 - Inicializando a classe para tratamento de operações especiais
EndIf
lMod_Alter := .F.
lPode_Alt := .T.
lTrava:= .F.
lCopiaPO := .F. // GCC - 03/06/2013 - Permitir que na cópia do PO o botão SI Refe esteja habilitado.
nOpcAux:= nOpc
PO_Filter(.F.)

W_Flag_Seq:= .F.
nSeq_Sli := ""
MTotal   := 0
MFob_Abs := 0
MTotFob  := 0
TNr_Cont := 0
TCc      := SPACE(nlenCC)//LEN(SW0->W0__CC))  FCD SO.:0026  OS.:0243/02
TSi_Num  :=cSiOri := SPACE(nlenSi)//LEN(SW0->W0__NUM))FCD SO.:0026  OS.:0243/02
nQtd_Gi  := nSld_GI:=0
TDt_Po   := AVCTOD("")
aSize(aPLIs,0)

Processa( {|| lTudoOK:=PO400CriaTemp()} )
IF !lTudoOK
   Help(" ",1,"E_NAOHAREA")
   RETURN .T.
ENDIF

FOR nInd := 1 TO SW2->(FCount())
   M->&(SW2->(FIELDNAME(nInd))) := SW2->(CRIAVAR(FIELDNAME(nInd)))
NEXT

// AWR 09/06/99
IF EasyGParam("MV_NRPO",,'N') $ cSim
   M->W2_PO_NUM := "." // So inicializei com ponto para passar pela validacao da primeira tela , AWR  27/05/99
ENDIF

IF cMV_EASY $ cSim
   M->W2_PO_SIGA:= "." // So inicializei com ponto para passar pela validacao da primeira tela , AWR  09/06/99
Endif
SY1->(DBSetOrder(1)) //WFS
If !lSiReferencia .AND. !lNewTelaSI//JL
   Aadd(aBotoesInc,{"S4WB005N", {|| PO400SelPO(cAlias,nReg,nOpc)}, STR0257} )
EndIf

IF GetNewPar("MV_SIREF","N") = "S"  .And. !lCopiaPO .AND. !lNewTelaSI//JL
   Aadd(aBotoesInc,{"BAIXATIT", {|| PO400SiRef()}, STR0258} ) // SI Referência
EndIf

IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"INCLUIR"),.T.)

// EOS - OS 0486/02 - Foi incluso no 13º parametro da funcao E_Inclui, a funcao
// PO400BtnBar p/ criar a ToolBar com o novo botao = Si de referencia que ao escolher
// o Centro de custo e a Si, traz algumas informacoes da SI como Fornecedor, moeda e
// comprador e os ítens da SI.
lret:=E_Inclui(cAlias,;
               nReg,;
               nOpc,;
               {|| PO_Init(@FileWork,@WorkNTX2,"1")},;
               {|| E_Valid(aGets,{|campo| PO420Val(campo)}).AND.PO420Val("TUDO").AND.IF(lRdMake,ExecBlock("EICPPO02",.F.,.F.,"14"),.T.) },;
               {|| PO_Create()},;
               {|| PO_Final(FileWork,WorkNTX2,cIndex,cIndex4)},;
               If(Len(aBotoesInc) > 0,aBotoesInc,),;
               ,;
               ,;
               ,;
               ,;
               ,;
               aCpos_SW2)//JL
lDepoisGrvIncPO := lRet  // GFP - 18/04/2016
IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"DEPOIS_GRAVA_INC_PO"),)

PO_Filter(.T.)

//AOM - 04/05/2011 - Operacao Especial
If lOperacaoEsp
   oOperacao:DeleteWork()
EndIf

//DFS - 11/03/13 - Verificar se a TRB tem registros.
If Select("TRB") > 0
   TRB->(E_EraseArq(cNomeW1,,, SaveTempFiles())) // wfs mar/2017 - adequação para uso do EECEraseArq() - 4º parâmetro
Endif

/* wfs mar/2017 - adequação para uso do EECEraseArq(), com a passagem do 4º parâmetro */
Work_SW3->(E_EraseArq(cNomeW3,,, SaveTempFiles()))

If lPOAuto
   If lNotPOErroAuto
      lNotPOErroAuto:= lRet
   Endif
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PO400Alter³ Autor ³ PADRAO PARA GETDADDB  ³ Data ³ 13.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa exclusivo para alteracao de Or‡amentos.           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void PO400Alter(ExpC1,ExpN1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PO400Alter(cAlias,nReg,nOpc)
LOCAL bFunction:={||If(PO400Atu(bValid),oDlg:End(),)},oDlg,nInd
LOCAL cResource :="SALVAR"   // nome do resource
LOCAL cToolTip  :=STR0033 //"Salva & Sai"
LOCAL bValid    :={||E_Valid(aGets,{|campo| PO420Val(campo,,,.T.)}).AND.PO420Val("TUDO",,,.T.)}
LOCAL cTitle    := STR0261 //LRL 17/03/04 -"Salva/Sai"
Local lRet      := .F.
Local aOrdSC7:= {}
LOCAL cFilSW := xFilial("SW3")
PRIVATE MConta:=MTotal:=0
PRIVATE MTem_Guia := .F., WFlag:='2' , nQtd_Gi,nSld_Gi, MTotal
PRIVATE MExiste:=.T., TCc,TSi_Num,cSiOri, TW1_REG:= "", TCod_i:= ""
Private lCtr_Alcada := .F. // By JPP - 05/02/2008 - 11:15
PRIVATE aBotoesAlt := {}  //TRP-03/01/08

PRIVATE lValidaPO := .F. // AST - 18/05/2009 - Variável utilizada no ponto de entrada "VAL_ALCADA_ALTERA_TELA_PO"
                         //                    para verificar se o PO pode ser alterado. Chamado: 719819

//AOM - 14/04/2011 - Operacao Especial
If lOperacaoEsp
   Private oOperacao := EASYOPESP():New() //AOM - 07/04/2011 - Inicializando a classe para tratamento de operações especiais
EndIf

Private aDeletaAuto:= {}
Private lDepoisAltIncPO := .F. //MCF - 25/01/2016 Variável para ser utilizado no ponto de entrada DEPOIS_ALTERA_INC_PO
nSeq_Sli := ""  // GFP - 31/01/2014
TPO_NUM:=SW2->W2_PO_NUM
TPO_SIGA:=SW2->W2_PO_SIGA
lCopiaPO:=.F.;lSiCopia:=.F.;lSiReferencia:=.F.  //AWR - 6/8/2004 //Variaveis para copia do P.O.
lPode_Alt := .T.
lTrava:= .F.
nOpcAux:= nOpc

IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"VAL_ALCADA_ALTERA_TELA_PO"),) // By JPP - 05/02/2008 - 11:15

// AST - 18/05/2009 - Caso o PO não tenha possa ser alterado, sai do programa (verificação realizada através de rdmake)
If lValidaPO
   return .F.
EndIf

If ! EICPO400PROG()
   Return .F.
EndIf

If ( Type("lPOAuto") == "U" .OR. !lPOAuto )
   If SW2->(FieldPos("W2_SIAUTO")) # 0
      If !Empty(SW2->W2_SIAUTO)
         MsgInfo(STR0325) //STR0325 "PO Automático não pode ser alterado!"
         Return .F.
      Endif
   Endif
Endif
lMod_Alter := .T.

TPO_NUM:=SW2->W2_PO_NUM
TPO_SIGA:=SW2->W2_PO_SIGA

SW3->(DBSEEK(xFilial()+TPO_NUM))

// Bete - 23/05/06 - Se o pedido já foi liberado pela alçada e já passou para uma fase seguinte, não deve permitir alteração
IF SW2->(FIELDPOS("W2_CONAPRO")) # 0 .AND. SW2->W2_CONAPRO = "L" .AND. EasyGParam("MV_AVG0170",,.F.)  //TRP-28/08/08- Teste do parâmetro MV_AVG0170 para definir se habilita Controle de Alçadas no EIC.
   lProx_Fase := .F.
   If Select("SQLAUX") > 0
      SQLAUX->(DbCloseArea())
   EndIf   
   BeginSQL Alias "SQLAUX"
      Select R_E_C_N_O_ RECSW3 From %table:SW3% SW3
      Where SW3.%NotDel% And SW3.W3_SEQ > 0 AND SW3.W3_FLUXO = "1" AND SW3.W3_PO_NUM = %exp:TPO_NUM% AND SW3.W3_FILIAL = %exp:cFilSW%
   EndSql

   If SQLAUX->(!Eof() .And. !Bof())     
      lProx_Fase := .T.
   EndIf
  

   IF !lProx_Fase
      If Select("SQLAUX") > 0
         SQLAUX->(DbCloseArea())
      EndIf   
      BeginSQL Alias "SQLAUX"
         Select R_E_C_N_O_ RECSW5 From %table:SW5% SW5
         Where SW5.%NotDel% And SW5.W5_SEQ > 0 AND SW5.W5_FLUXO = "7" AND SW5.W5_PO_NUM = %exp:TPO_NUM% AND SW5.W5_FILIAL = %exp:cFilSW%
      EndSql

      If SQLAUX->(!Eof() .And. !Bof())        
         lProx_Fase := .T.
      EndIf
   ENDIF
/* Nopado por GFP - 16/12/2013 - Retirado validação para que o sistema atenda a POs parcialmente embarcados.
   IF lProx_Fase .And. !lCtr_Alcada // By JPP - 05/02/2008 - 11:15 - Inclusão da validação - !lCtr_Alcada
      MSGINFO(STR0291)  //STR0291 = "Pedido nao pode ser alterado pois foi liberado pela Alcada e se encontra em fase posterior!"
      RETURN .F.
   ENDIF*/
ENDIF

MTotal   := 0
MFob_Abs := 0
MTotFob  := 0

W_Flag_Seq:= .F.
TNr_Cont := 0
TCc      := SW3->W3_CC
TSi_Num  := cSiOri :=SW3->W3_SI_NUM
nQtd_Gi  := nSld_GI:=0


IF .NOT. RecLock("SW2",.F.)
   SW2->(MsUnlock())
   Return .F.
ENDIF

// Cria os Arquivos Temporarios

PO_Init(@FileWork,@WorkNTX2,"2")

IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"ALTERAR"),)    //TRP-03/04/08- Inclusão de ponto de entrada
// CAF *** 16/03/99 Melhorias NEC MsAguarde({|lEnd|PO_Existe({|msg|MsProcTxt(msg)},1)},"Pesquisa de Itens")
cFilSW5 := xFilial("SW5")
IF SW5->(DBSEEK(cFilSW5+SW2->W2_PO_NUM))
   IF SW5->W5_FLUXO = "5"
//    Msg("NUMERO DO PEDIDO NAO CADASTRADO - TECLE ENTER",1000,.T.)
      Help(" ",1,"E_PONAOCAD")
      Return .F.
   ENDIF
   lAnuente := PO400Anuente(TPO_NUM)
   MTem_Guia:= lAnuente
ELSE
   MTem_Guia:= .F.
ENDIF
// A variável trava verifica se já houve embarques efetuados, travando a alteração de alguns campos na capa do PO.
// Transferi esta validação para cá, visto que na função PO_EXISTE, só será executada na carga dos itens, mas a variável é utilizada para consistir
// alterações da capa
cFilSW3 := xFilial("SW3")


If Select("SQLAUX") > 0
   SQLAUX->(DbCloseArea())
EndIf   

BeginSQL Alias "SQLAUX"
         Select R_E_C_N_O_ RECSW3 From %table:SW3% SW3
         Where SW3.%NotDel% And SW3.W3_PO_NUM = %exp:TPO_NUM% AND SW3.W3_FILIAL = %exp:cFilSW3% AND SW3.W3_QTDE <> SW3.W3_SALDO_Q
EndSql

DO WHILE !SQLAUX->(EOF() .or. BOF()) 
      nQtd_Gi:=nSld_GI:=0
      nQtdEmb:= 0
      SW3->(DBGOTO(SQLAUX->RECSW3))
      Po420_IgPos("1")

      lPode_Alt := IF(nSld_Gi = nQtd_Gi,.T.,.F.)
      IF !lPode_Alt
         lTrava := .T.
      ENDIF
   SQLAUX->(dbSkip())
ENDDO

SQLAUX->(DBCloseArea())

FOR nInd := 1 TO SW2->(FCount())
   M->&(SW2->(FIELDNAME(nInd))) := SW2->(CRIAVAR(FIELDNAME(nInd)))
NEXT i

TDt_Po := SW2->W2_PO_DT
MForn  := SW2->W2_FORN

IF EICLOJA()
   MLoja  := SW2->W2_FORLOJ
ENDIF

TNr_Alter:= SW2->W2_NR_ALTE + 1

// *** CAF 17/03/1999 E_Inclui ja cria as variaveis. SW2->(E_InitVar())
aSize(aPLIs,0)

lPOdaIntegracao:=(SW2->W2_INTEGRA == "S")

IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"ANTES_ALTERA_TELA_PO"),)

//ISS - 27/04/11 - Não habilita o botão "Salva Sai" quando estiver integrado com o compras.
If !cMV_EASY $ cSim .AND. !EasyGParam("MV_AVG0170",,.F.) //DFS - 29/04/13 - Só apresentar o botão se não houver integração com o Compras e Controle de Alçadas habilitado.
   aAdd(aBotoesAlt,{cResource,bFunction,cToolTip,cTitle}) // NCF - 10/03/09 - Alteração na ordem dos parametros
EndIF

(lRet:= E_Inclui(cAlias,;
       nReg,;
       nOpc,;
       {||.T.},;
       {||E_Valid(aGets,{|campo| PO420Val(campo)}).AND.PO420Val("TUDO").AND.IF(lRdMake,ExecBlock("EICPPO02",.F.,.F.,"14"),.T.)},;
       {||PO_Create()},;
       {||PO_Final(FileWork,WorkNTX2)},;
       aBotoesAlt,;
       ,;
       @oDlg,;
       IF(!Empty(M->W2_HAWB_DA),STR0222+AllTrim(TRANSFORM(M->W2_HAWB_DA,AVSX3("W2_HAWB_DA",6))),cCadastro),;
       aGetsNaciona,;
       ,;
       aCpos_SW2))//JL

lDepoisAltIncPO := lRet //MCF - 25/01/2016 Variável para ser utilizado no ponto de entrada DEPOIS_ALTERA_INC_PO
IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"DEPOIS_ALTERA_INC_PO"),) //LRS - 18/09/2015

//AOM - 04/05/2011 - Operacao Especial
If lOperacaoEsp
   oOperacao:DeleteWork()
EndIf

If lPOAuto
   If lNotPOErroAuto
      lNotPOErroAuto:= lRet
   Endif
Endif

Return lRet

*-----------------------------------------------------------------------------
Function PO400Atu(bValid)
*-----------------------------------------------------------------------------
   LOCAL Wind
   LOCAL cPointE:="EICPO02E",cPointS:="EICPO02S"
   LOCAL lPointE:=EasyEntryPoint(cPointE), lPointS:=EasyEntryPoint(cPointS)
   Local lW2ConaPro:=SW2->(FIELDPOS("W2_CONAPRO")) # 0 .AND. EasyGParam("MV_AVG0170",,.F.)
   Local lAltDesp := ChkAltDesp()
   Local lCapaPOAlt := .F. , i //FDR - 11/05/12

   //FDR - 11/05/12
   Private aAltValCap := {"W2_PO_DT",;
                        "W2_INLAND",;
                        "W2_PACKING",;
                        "W2_OUT_DES",;
                        "W2_MOEDA",;
                        "W2_DT_PAR",;
                        "W2_COND_PA",;
                        "W2_FRETEIN",;
                        "W2_DESCONT"}

   if lW2ConaPro
      aadd(aAltValCap,"W2_COMPRA")
   endif

   If !Obrigatorio(aGets,aTela) .or. !Eval(bValid)
      Return .F.
   Endif

   MTotFOB   :=M->W2_FOB_TOT
   TInland   :=M->W2_INLAND
   TOutDesp  :=M->W2_OUT_DES
   TFreteIntl:=M->W2_FRETEIN
   TPacking  :=M->W2_PACKING
   TDesconto :=M->W2_DESCONT
   TSeguro   :=If(AvFlags("RATEIO_DESP_PO_PLI"),M->W2_SEGURIN,0)

   MTotFOB += TInland + TFreteIntl + TPacking + TOutDesp + TSeguro - TDesconto

   /*ISS - 25/11/10 - Tratamento para Validar o valor do total do PO, assim não permitindo
                     a alteração da capa no caso este valor esteja negativo.*/
   If !(MTotFOB > 0) /*MTotFOB < 1*/ //NCF - 06/04/2011 - Alterada a Validação para permitir qulquer valor de FOB maior que 0.00
      //Help("", 1, "AVG0000333",,IF(M->W2_FREPPCC=="PP",STR0104," "),2,18) //MsgInfo(STR0103+IF(M->W2_FREPPCC=="PP",STR0104," "),STR0037) //"Desconto não pode ser maior que F.O.B + INLAND + PACKING "###"+ FRETE"###"Atenção"
      MsgInfo(STR0292 + If(M->W2_FREPPCC=="PP",", FRETE.","."),STR0037) //STR0292 = "O valor de desconto não pode ser maior ou igual do que o montante das taxas FOB, INLAND, PACKING"
      Return .F.
   EndIf
   If MsgYesNo(STR0034,STR0035)=.T. //'Confirma a Gravação ? '###'Capa do P.O.'
      If lPointE .And. !ExecBlock(cPointE)
         Return .F.
      Endif
   //  E_Msg("Atualizando dados da capa do P.O. - aguarde...")
      TPO_NUM:=SW2->W2_PO_NUM
      TPO_SIGA:=SW2->W2_PO_SIGA

      IF lAlcada   //CCH - 08/06/09 - Controle de geração de títulos provisórios quando controle de alçadas estiver ligado
         IF SW2->(FIELDPOS("W2_CONAPRO")) # 0 .AND. SW2->W2_CONAPRO = "L"
            EICFI400("ANT_GRV_PO","A")
         ENDIF
      ELSE
         EICFI400("ANT_GRV_PO","A")
      ENDIF

      //FDR - 11/05/12
      For i:=1 To Len(aAltValCap)
         If SW2->&(aAltValCap[i]) != M->&(aAltValCap[i])
            lCapaPOAlt := .T.
            Exit
         End
      Next i

      PO420GrvPO000("1") // EIC.PRG

      IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"DEPOIS_GRAVA_ALT_PO"),)

      IF lAlcada   //CCH - 08/06/09 - Controle de geração de títulos provisórios quando controle de alçadas estiver ligado
         IF SW2->(FIELDPOS("W2_CONAPRO")) # 0 .AND. SW2->W2_CONAPRO = "L"
            EICFI400("POS_GRV_PO","A")
         ENDIF
      ELSE
            EICFI400("POS_GRV_PO","A")
      ENDIF

      SW4->(DBSETORDER(1))
      If(lPointS,ExecBlock(cPointS),)

      FOR Wind = 1 TO LEN(aPLIs)
         IF SW4->(DBSEEK(xFilial("SW4")+aPLIs[Wind]))
            nSeq_SLi:= SW4->W4_PGI_NUM ; Po420GrvGI()
         ENDIF
      NEXT
   Else
      Return .F.
   Endif

   //ISS - 24/02/11 - Força integração com o compras quando dos campos de despesa for alterado.
   If lAltDesp .AND. !lEXECAUTO_COM

      //ACB - 18/03/2011 - Envio do centro de custo ao compras.
      If lCpoCtCust
         cCentroCusto := SW3->W3_CTCUSTO
      Else
         cCentroCusto := SW3->W3_CC
      EndIf

      AVGravaSC7(2,SW3->W3_COD_I,SW3->W3_QTDE,SW3->W3_PRECO,;
                              IF(!EMPTY(ALLTRIM(SW2->W2_PO_SIGA)),SW2->W2_PO_SIGA,LEFT(SW3->W3_PO_NUM,6)),SW0->W0__POLE,cCentroCusto,;
                              SW3->W3_FORN,If(EICLoja(), SW3->W3_FORLOJ, '01'),SW2->W2_PO_DT,;
                              SW0->W0_C1_NUM,SW3->W3_DT_ENTR,SW3->W3_POSICAO,SW3->W3_POSICAO,;//'01'
                              Nil,"EICPO400",Nil,SW3->W3_SI_NUM,SW3->W3_REG,SW2->W2_MOEDA,"N", SW2->W2_PO_NUM,;
                              If(lW2ConaPro,SW2->W2_CONAPRO,Nil),SW2->(W2_INLAND+W2_PACKING+W2_OUT_DES+W2_FRETEIN),SW2->W2_DESCONT)

   //FDR - 11/05/12
   ElseIf lEXECAUTO_COM .And. lCapaPOAlt
      If !PO400GravaPC(nOpcAux)
         lRetExecAuto:= .F.
         DisarmTransaction()
         Work->(DBGoTop())
      EndIf
   EndIf

Return .T.
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PO400Estor³ Autor ³ PADRAO PARA GETDADDB  ³ Data ³ 13.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Estorno de S.I.                                ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void PO400Estor(ExpC1,ExpN1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PO400Estor(cAlias,nReg,nOpc)
LOCAL oDlg, aCampos:={},oMark, FileWork, oPanel
LOCAL nL1:=18, nL2:=31, nL3:=44, nC1:=6, nC2:=144
LOCAL cForn
LOCAL cPictFob := ALLTRIM(X3Picture("W4_FOB_TOT")) //mjb150999
LOCAL _LIT_R_CC := IF(EMPTY(ALLTRIM(EasyGParam("MV_LITRCC"))),(AVSX3("W0__CC")[5]), ALLTRIM(EasyGParam("MV_LITRCC")))
LOCAL _PictItem := ALLTRIM(X3PICTURE("B1_COD"))
LOCAL _PictSI   := ALLTRIM(X3PICTURE("W0__NUM"))
LOCAL cTitJan   := ""
LOCAL nValTot:=0  // Jonato em 13 de Agosto de 2004, p/ não estornar valores superiores a parcela de câmbio antecipada
LOCAL nValItens:=0
LOCaL cShowHawb := ""
LOCAL cShowHawbax := ""
Local lRet:= .T.

PRIVATE aTELA[0][0],aGETS[0], nQtd_Gi,aHeader[0],nSld_Gi,nQtdEmb
PRIVATE MConta:=MTotal:=0, TPO_NUM:=SW2->W2_PO_NUM
PRIVATE cLitBotao := aRotina[nOpc,1]
PRIVATE lTemSWB:=.f.
PRIVATE nValAdi:=0
PRIVATE nVlr_Limite:= ((SW2->W2_FOB_TOT+SW2->W2_INLAND+SW2->W2_FRETEIN+SW2->W2_PACKING-SW2->W2_DESCONT)+If(AvFlags("RATEIO_DESP_PO_PLI"),SW2->W2_SEGURIN,0)) - PO400VALSWB(.T.)
PRIVATE aBotoesEst := {}  //TRP-03/04/08
//ISS - 29/04/11 -
Private lTrataPGAntecipado := .T.
lSair := .F.
//AOM - 14/04/2011 - Operacao Especial
If lOperacaoEsp
   Private oOperacao := EASYOPESP():New() //AOM - 07/04/2011 - Inicializando a classe para tratamento de operações especiais
EndIf
Private aDeletaAuto:= {}
lMod_Alter := .F.
nOpcAux := nOpc
nQtdEmb := 0

AAdd(aBotoesEst, {"EDIT", {|| PO400Marca(@nValtot,@nValItens), oMark:oBrowse:Refresh()}, STR0309}) //"Marca/Desmarca Todos" //wfs - adequação de identidade visual

If ! EICPO400PROG()
   IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"ANTES_ESTORNA"),)  // TLM 18/02/2008
   Return .F.
EndIf

//ISS - 29/04/11 - Ponto de entrada para a validação do pagamento antecipado
If(EasyEntryPoint("EICPO400"), ExecBlock("EICPO400",.F.,.F.,"PO400ESTOR_VERIFICA_PAG_ANT"),)

If lSair
   Return .F.
EndIf

// BHF - 20/02/09 - Verificação de adiantamentos
SWA->(DbsetOrder(1))
If SWA->(Dbseek(xFilial("SWA")+SW2->W2_PO_NUM))
   If SWA->WA_PO_DI = "A" .And. lTrataPGAntecipado
      MsgAlert(STR0293,STR0037) //STR0293 = "P.O. possui adiantamento registrado no cambio! Verifique." //STR0037 = "Atenção".
      //Return .F.
   EndIf
EndIf

If ( Type("lPOAuto") == "U" .OR. !lPOAuto )
   If SW2->(FieldPos("W2_SIAUTO")) # 0
      If !Empty(SW2->W2_SIAUTO)
         MsgInfo(STR0326) //STR0326 "PO Automático não pode ser excluído!"
         Return .F.
      Endif
   Endif
Endif

lPABaixada:=.F.
EICFI400("PA_BAIXADA")
IF lPABaixada
   EICFI400('MENSAGEM')
   RETURN .F.
ENDIF

TPO_SIGA:=SW2->W2_PO_SIGA

IF .NOT. RecLock("SW2",.F.,.T.) // lock p/ delecao
   SW2->(MsUnlock())
   Return .F.
ENDIF

SW3->(DBSETORDER(7))
IF ! SW3->(DBSEEK(xFilial("SW3")+SW2->W2_PO_NUM))
   Help(" ",1,"E_NAOHAITE")
   SW2->(MsUnlock())
   Return .F.
ENDIF

IF SW3->W3_FLUXO = "5"
   Help(" ",1,"E_PONAOCAD")
   SW2->(MsUnlock())
   Return .F.
ENDIF

PRIVATE lLeuTodosItens:=.T.//AWF - 21/07/2014 - LOGIX - Variavel usada na funcao Function EICPO420(lEnvio,nOpc,aCab,cAlias,lWk,cPo_num) do LOGIX

If !PO400GeraWork(@FileWork,ESTORNO)
   Return .F.
Endif

IF MTotal = 0  // .or. nQtdEmb # 0
   //Help("", 1, "AVG0000324")//"Pedido não pode ser estornado, pois possui processo em andamento."###"Atenção"  -- ACB 01/04/2010 14:25
   //acb - 01/04/2010 14:25 - Tratamento para listar os processo em aberto no embarque ao tentar estornar a po
   SW7->(DBsetOrder(2))
   SW7->(DBSeek(xFilial("SW7")+SW2->W2_PO_NUM))
   Do While SW7->(!EOF()) .and. SW7->W7_PO_NUM == SW2->W2_PO_NUM
      cShowHawb := SW7->W7_HAWB
         cShowHawbax += cShowHawb
      SW7->(DBSKIP())
   End do
   If Len(cShowHawbax) > 0
      eecview(STR0294+ ENTER +STR0295+ ENTER + ENTER + cShowHawbax) //STR0294 = "Pedido não pode ser estornado, pois possui processo em andamento"    //STR0295 = "O(s) processo(s) são:"
      //Work->(E_EraseArq(FileWork,,, SaveTempFiles())) /* wfs mar/2017 - adequação para uso do EECEraseArq(), com a passagem do 4º parâmetro */
      PO_Final(FileWork,WorkNTX2)
      //DBSELECTAREA("SW2")
      //SW2->(MsUnlock())
      Return .F.
   EndIf
ENDIF

bQtde_Emb:={||IF(Work->WKFLUXO=="7",TRANSFORM(Work->WKQTDE_EMB,_PictQtde),STR0010 )} //'   ANUENCIA    '
bQtde_LI :={||IF(Work->WKFLUXO=="1",TRANSFORM(Work->WKQTDE_LI,_PictQtde), STR0290 )} //'   Nao Anuente    ' //STR0290 = "Não Anuente"
//bQtde    :={||IF(Work->WKFLUXO=="1",TRAN(Work->(WKQTDE_LI+WKSALDO_Q),_PictQtde),TRAN(Work->WKSALDO_Q,_PictQtde))} //'   Nao Anuente    '
bQtde    := {|| TRANSFORM(Work->WKQTDE,_PictQtde) }

SA2->(DBSEEK(xFilial()+SW2->W2_FORN+EICRetLoja("SW2","W2_FORLOJ")))
cForn:=ALLTRIM(SA2->A2_NREDUZ)//Nopado por FDR - 12/01/12 /*SW2->W2_FORN+'-'+ALLTRIM(SA2->A2_NREDUZ)*/

TB_Campos := { }
AADD(TB_Campos,{"WKFLAGWIN"                      ,,"     "}              )
AADD(TB_Campos,{"WKCC"                           ,,_LIT_R_CC}            )
AADD(TB_Campos,{{||TRANSFORM(Work->WKSI_NUM, _PictSI)}      ,,STR0038}   ) //"N§ SI"
AADD(TB_Campos,{"WKPOSICAO"                      ,,STR0012}            ) //"Posicao"
AADD(TB_Campos,{{||TRANSFORM(Work->WKCOD_I,_PictItem)}      ,,STR0013}               ) //"Item"

If cPaisLoc=="BRA"
   AADD(TB_Campos,{{||IF(Work->WKFLUXO=='7',STR0015,STR0016)} ,,STR0017}           ) //'Nao'###'Sim'###"Anuencia"
EndIf

AADD(TB_Campos,{"WKDESCR"                        ,,AVSX3("B1_DESC_"+cDESC_PO,AV_TITULO)}) //"Descricao em ###"

IF lExiste_Midia .AND. !EMPTY(SW2->W2_VLMIDIA)//AWR 21/10/1999
   AADD(Tb_Campos,{"WK_QTMIDIA",,AVSX3("B1_QTMIDIA",5),AVSX3("B1_QTMIDIA",6)})
   AADD(Tb_Campos,{"WK_VLTOTMI",,STR0021,AVSX3("W2_VLMIDIA",6)}) //"Vlr. Total Midia"
ENDIF

IF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"7"),)//AWR 09/11/1999

AADD(TB_Campos,{{||TRANSFORM(Work->WKQTDE, _PictQtde)}   ,,STR0022}    ) //"Quantidade"

IF AvFlags("EIC_EAI")//AWF - 25/06/2014
   AADD(Tb_Campos,{"WKUNI"  ,,AVSX3("W3_UM",AV_TITULO)})
ELSE
   IF EICLOJA()
      AADD(Tb_Campos,{{||BUSCA_UM(Work->WKCOD_I+Work->WKFABR+Work->WKFORN,WORK->WKCC+WORK->WKSI_NUM,WORK->W3_FABLOJ,WORK->W3_FORLOJ)},,STR0020})
   ELSE
      AADD(Tb_Campos,{{||BUSCA_UM(Work->WKCOD_I+Work->WKFABR+Work->WKFORN,WORK->WKCC+WORK->WKSI_NUM,"","")},,STR0020}) //"Uni"
   ENDIF
ENDIF

IF AvFlags("EIC_EAI")//AWF - 25/06/2014
   AADD(Tb_Campos,{"WKQTSEGUM",,AVSX3("W3_QTSEGUM",AV_TITULO),AVSX3("W3_QTSEGUM" ,6)})
   AADD(Tb_Campos,{"WKSEGUM"  ,,AVSX3("W3_SEGUM",AV_TITULO)})
ENDIF

IF cPaisLoc=="BRA"
   AADD(TB_Campos,{ bQtde_LI                                ,,AVSX3("W3_QTD_LI")[5]}) //"Qtde em LI"
ENDIF
AADD(TB_Campos,{ "WKQTDE_EMB"                            ,,STR0023,_PictQtde}) //"Qtde Embarcada"
//AADD(TB_Campos,{ bQtde_Emb                               ,,STR0023}) //"Qtde Embarcada"
AADD(TB_Campos,{{||TRANSFORM(Work->WKSALDO_Q, _PictQtde)},,STR0024}    ) //"Saldo Qtde" //ASK 28/03/07
//AADD(Tb_Campos,{{|| PO400Saldo() },,STR0024,_PictQtde}) //"Saldo Qtde" - AWR 19/04/04
AADD(TB_Campos,{"WKSEM_PO" ,,AVSX3("W3_SEM_PED")[5],AVSX3("W3_SEM_PED",6)})

If SW3->(FieldPos("W3_PESOL")) # 0 //CCH - 07/08/09 - Gravação do novo campo de Peso Líquido Unitário
   AADD(TB_Campos,{"WKPESOL" ,,AVSX3("W3_PESOL")[5],AVSX3("W3_PESOL",6)})
EndIf
AADD(TB_Campos,{{||PADL(Work->WKFABR,nLenFabr,'0') + '-' + Work->WKNOME_FAB},,STR0019}    ) //"Fabricante"

AADD(TB_Campos,{{||TRANSFORM(Work->WKPRECO,_PictPrUn)}              ,,STR0039}         ) //"Preco"
AADD(TB_Campos,{"WKDT_EMB" ,,STR0027 }) //"Embarque"
AADD(TB_Campos,{"WKDT_ENTR",,STR0028 }) //"Entrega"

If lNestle
   ExecBlock(cArqNestle,.F.,.F.,"8")
Endif

IF lRdMake
   ExecBlock("EICPPO02",.F.,.F.,"16")
Endif

If lForeCast
   AADD(Tb_Campos,{{||IF(Work->WK_FORECAS=="S",STR0029,STR0030)},,STR0031}) //CAF 22/10/98 //"Sim"###"Nao"###"Forecast"
Endif

AADD(Tb_Campos,{{||SX5->(dbSeek(xFilial()+"Y2"+Work->WK_REG_TRI)),AllTrim(X5DESCRI())},,AVSX3("W3_REG_TRI")[5]})
AADD(TB_Campos,{"WK_REG_MIN",,STR0032}) //"Registro no Minist‚rio / OrgÆo P£blico"

AADD(Tb_Campos,{"WK_TEC"   ,,AVSX3("W3_TEC"   )[5]})
AADD(Tb_Campos,{"WK_EX_NCM",,AVSX3("W3_EX_NCM")[5]})
AADD(Tb_Campos,{"WK_EX_NBM",,AVSX3("W3_EX_NBM")[5]})
IF cPaisLoc # "BRA"  .AND. SW1->(FIELDPOS("W1_NATUREZ")) # 0
   AADD(TB_Campos,{"WKNATUREZA",,AVSX3("W1_NATUREZ",5)})
ENDIF

If SW3->(FieldPos("W3_PART_N")) # 0 //ASK - 02/10/2007
   AADD(Tb_Campos,{"WKPART_N",,STR0014})
EndIf
//TRP- 01/06/09 - Campo Software para novo Tratamento de Mídia e Software
If SW3->(FieldPos("W3_SOFTWAR")) # 0 .And. EasyGParam("MV_CONSOFT",, "N") $ cSim
   AADD(Tb_Campos,{{||IF(Work->WKSOFTWAR=='2',STR0015,STR0016)},,AVSX3("W3_SOFTWAR",5)})
Endif

If lCpoCtCust
   AADD(Tb_Campos,{"WKCTCUSTO",,AVSX3("W3_CTCUSTO",5),AVSX3("W3_CTCUSTO",6)})
EndIf

If lPesoBruto                                                                     //NCF - 25/08/2011 - Campo do Peso Bruto Unitário
   AADD(Tb_Campos,{"WKPSBRUTO",,AVSX3("W3_PESO_BR",5),AVSX3("W3_PESO_BR",6)})
EndIf

If AvFlags("RATEIO_DESP_PO_PLI")
   AADD(Tb_Campos,{"WKFRETE",,AVSX3("W3_FRETE",5)  ,AVSX3("W3_FRETE",6)})
   AADD(Tb_Campos,{"WKSEGUR",,AVSX3("W3_SEGURO",5) ,AVSX3("W3_SEGURO",6)})
   AADD(Tb_Campos,{"WKINLAN",,AVSX3("W3_INLAND",5) ,AVSX3("W3_INLAND",6)})
   AADD(Tb_Campos,{"WKDESCO",,AVSX3("W3_DESCONT",5),AVSX3("W3_DESCONT",6)})
   AADD(Tb_Campos,{"WKPACKI",,AVSX3("W3_PACKING",5),AVSX3("W3_PACKING",6)})
   If SW3->(FieldPos("W3_OUT_DES")) > 0
      AADD(Tb_Campos,{"WKOUTDE",,AVSX3("W3_OUT_DES",5),AVSX3("W3_OUT_DES",6)})
   EndIf
EndIf

//AOM - 09/04/2011 - Adiciona os campos de OPE ESP. na tela de estorno do PO
If lOperacaoEsp
   AADD(Tb_Campos,{"W3_CODOPE","",AVSX3("W3_CODOPE",5),AVSX3("W3_CODOPE",6)})
   AADD(Tb_Campos,{"W3_DESOPE","",AVSX3("W3_DESOPE",5),AVSX3("W3_DESOPE",6)})
EndIf
//EOB- 21/01/10 - Campo referente ao grupo de regime de tributação
If lRegTriPO
   AADD(Tb_Campos,{"WKGRUPORT",,AVSX3("W3_GRUPORT",5)})
Endif

lSair:=.F.

IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"BROWSE_ESTORNO"),)

IF(lSeal,ExecBlock("IC193PO1",.F.,.F.,"1"),) //AWR 01/10/1999

//TRP-14/05/07
//aOrd := SaveOrd("SX3",1)
//SX3->(dbSeek("SW3"))
//While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SW3"
   //If SX3->X3_PROPRI=="U" .AND. Ascan(TB_Campos, {|x| AllTrim(x[1]) == AllTrim(SX3->X3_CAMPO)})==0 .AND. X3Uso(SX3->X3_USADO)
      //aAdd(TB_Campos,{SX3->X3_CAMPO,,AVSX3(SX3->X3_CAMPO,AV_TITULO),AVSX3(SX3->X3_CAMPO,AV_PICTURE)})
   //EndIF
   //SX3->(dbSkip())
//Enddo
//RestOrd(aOrd)

TB_Campos:= AddCpoUser(TB_Campos,"SW3","2")

IF lSair
   Work->(E_EraseArq(FileWork,,, SaveTempFiles()))/* wfs mar/2017 - adequação para uso do EECEraseArq(), com a passagem do 4º parâmetro */
   Return .T.
ENDIF

If ( Type("lPOAuto") == "U" .OR. !lPOAuto )  // GFP - 26/08/2013
   oMainWnd:ReadClientCoords()
EndIf

cTitJan := IF(!Empty(SW2->W2_HAWB_DA),STR0222+AllTrim(TRANSFORM(SW2->W2_HAWB_DA,AVSX3("W2_HAWB_DA",6))),;
               STR0040+ALLTRIM(TRANSFORM(SW2->W2_PO_NUM,_PictPO))+; //"P.O. "
               STR0041+DTOC( SW2->W2_PO_DT)) //" de "

If ( Type("lPOAuto") == "U" .OR. !lPOAuto )
DEFINE MSDIALOG oDlg TITLE cTitJan ;
      FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
            OF oMainWnd PIXEL
@01.5,01 MSPANEL oPanel PROMPT "" SIZE 30,60 OF oDlg //LRL 19/03/04 -Painel para alinhamento MDI
@ nL1	,nC1 SAY STR0042				SIZE 25,08 of oPanel PIXEL //"Nr. P.O.:"
@ nL1	,nC2 SAY STR0043 				SIZE 25,08 of oPanel PIXEL //"Data: "
@ nL2	,nC1 SAY STR0044 				SIZE 25,08 of oPanel PIXEL //"Forn:"
@ nL3	,nC1 SAY STR0045+SW2->W2_MOEDA 	SIZE 25,08 of oPanel PIXEL //"Total Fob: "

@ nL1-2,nC1+32 MSGET SW2->W2_PO_NUM	 PICTURE _PictPO  WHEN .F. SIZE 55,8 of oPanel PIXEL
@ nL1-2,nC2+20 MSGET SW2->W2_PO_DT	 PICTURE '@D'     WHEN .F. SIZE 40,8 of oPanel PIXEL
@ nL2-1,nC1+32 MSGET cForn           PICTURE '@!'     WHEN .F. SIZE 90,8 of oPanel PIXEL
@ nL3-1,nC1+32 MSGET ROUND(MTotal,2) PICTURE '@E 9,999,999,999.99' WHEN .F. SIZE 60,8 of oPanel PIXEL
//@ nL3,nC1+32 MSGET SW2->W2_FOB_TOT PICTURE cPictFob WHEN .F. SIZE 60,8 of oPanel PIXEL

If cProg#"PN"
   /* wfs - comentado - identidade visual
   @ 20,COLUNA_FINAL-34 BUTTON STR0046 SIZE 34,11 FONT oDlg:oFont   ; //"Todos"
     ACTION (PO400Marca(@nValtot,@nValItens),oMark:oBrowse:Refresh()) OF oPanel PIXEL
                                       //  oMark:bAval:=NIL,;
                                       //  oMark:oBrowse:Refresh()) OF oDlg PIXEL */
Else
   PO400Marca(@nValtot,@nValItens)
EndIf
/* wfs - comentado - identidade visual
@ 33,COLUNA_FINAL-34 BUTTON cLitBotao SIZE 34,11 FONT oDlg:oFont ;
                  ACTION (If(PO410Estorno(),oDlg:End(),)) OF oPanel PIXEL*/

Work->(dbGoTop())

oMark:= MsSelect():New("Work","WKFLAGWIN",,TB_Campos,@lInverte,@cMarca,{59,1,FINAL_SELECT,COLUNA_FINAL})

If cProg="PN"
   oMark:bAval := {|| .T.}
Else
   oMark:bAval := {|| PO400MARITEM(@nValTot,@nValItens)}
   oMark:oBrowse:Refresh()
EndIf

oPanel:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
oMark:oBrowse:Refresh() //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
oDlg:lMaximized:=.T.
//DFS - 31/01/13 - Inclusão de refresh na tela.
ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,;
                {||If(PO410Estorno(),oDlg:End(),)},{||oDlg:End()},,aBotoesEst),oMark:oBrowse:Refresh())//LRL 19/03/04 -Para alinhamento na versão MDI //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

Else
   PO400Marca(@nValtot,@nValItens)
   bAval := {|| .T.}
   lRet:= PO410Estorno()
Endif

SW2->(MsUnlock())
PO_Final(FileWork,WorkNTX2)      //NCF - 22/01/2013 - Fechar a Work do EIJ (Reg.Trib.PO)
SW5->(DbSetOrder(1))

//AOM - 07/04/11 - OPe. Espe.
If lOperacaoEsp
   oOperacao:DeleteWork()
EndIf

DBSELECTAREA("SW2")

Return lRet

*------------------------------------*
Function PO400Marca(nValTot,nValItens)
*------------------------------------*
LOCAL nWkRecno:=Work->(RECNO()), cMarcaFlag:=cMarca

// GCC - 17/06/2013 - Item(s) com processo de embarque não pode ser realizado o estorno.
If Work->WKQTDE_EMB > 0 .Or. If (SW3->(FieldPos("W3_SLD_ELI")) # 0,Work->WKSLD_ELI > 0, .F.)
   Alert(STR0376) /*"Item não pode ser estornado, pois existe processo de embarque ou seu saldo foi eliminado."*/
   Return .F.
EndIf

Work->(DBGOTOP())
WHILE ! Work->(EOF())
//If nOpcAux == 5	//LRS 21/08/2013 - chamado 102381 //LRS 18/09/2013 - chamado 102702 - Correção do chamado 102381 gerou erro em outra rotina
 	If lCposAntecip .and. lTemSWB
       	if ! Work->WKFLAG
         	if nVlr_Limite == 0 .OR. nValTot + (Work->WKQTDE*Work->WKPRECO) == nVlr_Limite
            	PO400VALSWB(.f.,.f.,.t.)
            	EXIT
         	Endif
         	if nValTot + (Work->WKQTDE*Work->WKPRECO) > nVlr_Limite
            	PO400VALSWB(.f.,.t.,.f.)
            	DBSKIP()
            	LOOP
        	 endif
     	 endif
  	Endif
//EndIf	//LRS 21/08/2013 - chamado 102381 //LRS 18/09/2013 - chamado 102702 - Correção do chamado 102381 gerou erro em outra rotina

   If lPOAuto
      If SW0->(FieldPos("W0_SIAUTO")) # 0
         SW0->(DbSetOrder(1))
         If SW0->(Dbseek(xFilial("SW0")+ Work->WKCC + Work->WKSI_NUM))
            //Verifica se a SI é automática
            If SW0->W0_SIAUTO == "1"
               ExecAutoSi(nOpcAuto,.F.,.F.,.T.,aCabAuto,aCabItem,0)
            Endif
         Endif
      Endif
   Endif

   //AOM - 14/04/2011 - Operacao Especial
   If !ValidOpePO("BTN_MK_TDS_ITS_PO")
      LOOP
      Work->(DBSKIP())
   EndIf
   Work->WKFLAG:= !Work->WKFLAG
   IF(! Work->WKFLAG,cMarcaFlag:=SPACE(nLenOk),)//SO0026 FCD OS.:0243/02
   Work->WKFLAGWIN:=cMarcaFlag
   If(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"MarcaTodosEstorno"),)
   if Work->WKFLAG
      nValTot+=Work->WKQTDE*Work->WKPRECO
   else
      nValTot-=Work->WKQTDE*Work->WKPRECO
   endif
   Work->(DBSKIP())
END
Work->(DBGOTO(nWkRecno))

//IF nOpcAux <> 5 //LRS - 21/09/2016 - Não entrar na Função de rateio quando for exclusão/estorno
IF nOpcAux <> 5 .AND. nOpcAux <> 6 .AND. !lPedNac .OR. nOpcAux <> 4 .AND. lPedNac //AAF 16/01/2017 - Considerar nOpcAux de acordo com o aRotina de Pedido de Nacionalizacao
   If(AvFlags("RATEIO_DESP_PO_PLI"),PO400RatFrSg(SW2->W2_FRETEIN,SW2->W2_SEGURIN,SW2->W2_INLAND,;
      SW2->W2_DESCONT,SW2->W2_PACKING,0,SW2->W2_RAT_POR,,SW2->W2_OUT_DES),)
ENDIF

RETURN NIL

*-----------------------------------------------*
Function PO400VALSWB(lRetVlAdi,lDarMsg1,lDarMsg2)
*-----------------------------------------------*
Local cEspaceDif:= SPACE(AvSx3("WA_HAWB",3)-AvSx3("W2_PO_NUM",3))
Private lValidaSWB := .T.

//ISS - 29/04/11 - Ponto de entrada para a validação do SWB.
IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"PO400VALSWB_VALID_PAG_ANT"),)

If ! lValidaSWB
Return 0
EndIf

If ! lCposAntecip
   RETURN 0
Endif
if lRetVlAdi .and. SWB->(DBSEEK(xFilial("SWB")+SW2->W2_PO_NUM+cEspaceDIF+"A")) .and. ;
   nValAdi==0
   Do while ! SWB->(EOF()) .AND. xFilial("SWB") == SWB->WB_FILIAL .AND. ;
      ALLTRIM(SWB->WB_HAWB)== ALLTRIM(SW2->W2_PO_NUM) .AND. SWB->WB_PO_DI == "A"
      nValAdi+= SWB->WB_PGTANT
      ltemSWB:=.t.
      SWB->(DBSKIP())
   Enddo
endif
if lDarMsg1
   MsgInfo( STR0296 +;       //STR0296 = "Atencao! Nao e possivel estornar mais do que "
           alltrim(TRANSFORM(nVlr_Limite,_PictPrTot))+" "+SW2->W2_MOEDA+;
           STR0297 +alltrim(TRANSFORM(nValAdi,_PictPrTot))+" "+SW2->W2_MOEDA + STR0298) //STR0297 = " porque ha adiantamento no valor de " //STR0298 = " no financeiro"
endif
if lDarMsg2
   MsgInfo(STR0299) //STR0299 = "Atencao! Nao e possivel estornar o pedido porque ha adiantamento no financeiro"
endif
RETURN IF(lRetVlAdi,nValAdi,0)

*-----------------------------------------------*
Function PO400GeraWork(FileWork,cOpcao,nValItens)
*-----------------------------------------------*
LOCAL i:=0, aEIJ:= {},cAliasWkTmp
Local bExec
// aDBF_Stru eh private por causa dos rdmakes
PRIVATE aDBF_Stru:= { {"WKCOD_I","C",AVSX3("W3_COD_I",3),0}    , {"WKDESCR","C",AVSX3("B1_VM_" + cDESC_PO,3),0}    ,;
                      {"WKFABR","C",nLenFabr,0}                , {"WKNOME_FAB","C",15,0} ,;
                      {"WKFORN","C",nLenForn,0}                , {"WKNOME_FOR","C",15,0} ,;
                      {"WKREG","N",AVSX3("W3_REG",3),0}        , {"WKFLUXO","C",1,0}     ,; //reg(4)-gfc
                      {"WKQTDE","N",AVSX3("W3_QTDE",3),AVSX3("W3_QTDE",4)}    ,;
                      {"WKQTDE_O","N",AVSX3("W3_QTDE",3),AVSX3("W3_QTDE",4)}    ,;
                      {"WKPRECO","N",AVSX3("W3_PRECO",3),AVSX3("W3_PRECO",4)}    ,;
                      {"WKSALDO_Q","N",AVSX3("W3_SALDO_Q",3),AVSX3("W3_SALDO_Q",4)},;
                      {"WKCC","C",nLenCC,0} ,;
                      {"WKCC_O","C",nLenCC,0},;
                      {"WKSI_ORI","C",nLenSi,0}  ,;
                      {"WKPOSICAO","C",LEN(SW3->W3_POSICAO),0},;
                      {"WKPSPOCOPY","C",LEN(SW3->W3_POSICAO),0},;
                      {"WKFLAGWIN","C",2,0},;
                      {"WKSI_NUM","C",AvSx3("W3_SI_NUM", AV_TAMANHO),0}   ,;
                      {"WKPO_NUM","C",AvSx3("W2_PO_NUM", AV_TAMANHO),0}   ,;
                      {"WKCDPOCOPY","C",AvSx3("W2_PO_NUM", AV_TAMANHO),0},;
                      {"WKDT_EMB","D",8,0}   , {"WKDT_ENTR","D",8,0}   ,;
                      {"WKDTENTR_S","D",8,0} , {"WKSEQ","N",2,0}       ,;
                      {"WKRECNO","N",7,0}    , {"WKFLAG","L",1,0}      ,;
                      {"WKQTDE_LI" ,"N",AVSX3("W3_QTDE",3),AVSX3("W3_QTDE",4)}, ;
                      {"WKQTDE_EMB","N",AVSX3("W3_QTDE",3),AVSX3("W3_QTDE",4)}, ;
                      {"WKPART_N","C",LEN(IF(SW3->(FieldPos("W3_PART_N")) # 0,SW3->W3_PART_N,SA5->A5_CODPRF)),0}   ,;
                      {"WKCCNOME","C",20,0}  , {"WK_REG_MIN","C",AVSX3("W3_REG_MIN",3),0} ,;
                      {"WK_ALTEROU","L",01,0}, {"WK_REG_TRI","C",01,0} ,;
                      {"WK_TEC"     ,"C",10,0}  , {"WK_EX_NCM", "C",LEN(SB1->B1_EX_NCM),0} ,;
                      {"WK_EX_NBM"  ,"C",LEN(SB1->B1_EX_NBM),0}  , {"WKPESO_L","N",AVSX3("W5_PESO",3),AVSX3("W5_PESO",4)},;
                      {"WKSALDO_GI" ,"N",AVSX3("W3_QTDE" ,3),AVSX3("W3_QTDE" ,4)},;
                      {"WKQTDE_GI"  ,"N",AVSX3("W3_QTDE" ,3),AVSX3("W3_QTDE" ,4)} ,;
                      {"WKSEM_PO"   ,"N",15,5},;
                      {"TRB_ALI_WT","C",03,0},; //TRP - 25/01/07 - Campos do WalkThru
                      {"TRB_REC_WT","N",10,0},;
                      {"WKFLAGEIJ" ,"C",2,0},;  // JWJ - 09/12/09 - Flag de marca p/ grupos tributários
                      {"WKPOSIT"   ,"C",4,0} }//LGS-24/10/13
EICAddWkLoja(aDBF_Stru, "W3_FABLOJ", "WKFABR")
EICAddWkLoja(aDBF_Stru, "W3_FORLOJ", "WKFORN")

If SW3->(FieldPos("W3_PESOL")) # 0 //CCH - 07/08/09 - Inclusão do peso líquido unitário
   AADD(aDBF_Stru,{"WKPESOL","N",AVSX3("W3_PESOL",3),AVSX3("W3_PESOL",4)})
EndIf


If SW3->(FieldPos("W3_SLD_ELI")) > 0 //SVG - 23/02/2011 -
   AADD(aDBF_Stru,{"WKSLD_ELI","N",AVSX3("W3_SLD_ELI",3),AVSX3("W3_SLD_ELI",4)})
EndIf

IF(lSeal,ExecBlock("IC193PO1",.F.,.F.,"2"),) //AWR 01/10/1999
IF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"8"),)//RHP 25/02/00

IF lExiste_Midia//AWR 21/10/1999
   AADD(aDBF_Stru,{"WK_QTMIDIA",AVSX3("B1_QTMIDIA",2),AVSX3("B1_QTMIDIA",3),AVSX3("B1_QTMIDIA",4)})
   AADD(aDBF_Stru,{"WK_VLTOTMI",AVSX3("W2_VLMIDIA",2),AVSX3("W2_VLMIDIA",3),AVSX3("W2_VLMIDIA",4)})
ENDIF
IF cPaisLoc # "BRA"  .AND. SW1->(FIELDPOS("W1_NATUREZ")) # 0
   AADD(aDBF_Stru,{"WKNATUREZA","C",AVSX3("W1_NATUREZ",3),0})
ENDIF

If lForeCast
   AADD(aDBF_Stru,{"WK_FORECAS","C",1,0})
Endif

//TRP- 01/06/09 - Campo Software para novo Tratamento de Mídia e Software
If SW3->(FieldPos("W3_SOFTWAR")) # 0 .And. EasyGParam("MV_CONSOFT",, "N") $ cSim
   AADD(aDBF_Stru,{"WKSOFTWAR",AVSX3("W3_SOFTWAR",2),AVSX3("W3_SOFTWAR",3),AVSX3("W3_SOFTWAR",4)})
Endif

If lCpoCtCust
   AADD(aDBF_Stru,{"WKCTCUSTO",AVSX3("W3_CTCUSTO",2),AVSX3("W3_CTCUSTO",3),AVSX3("W3_CTCUSTO",4)})
EndIf

If lPesoBruto  //NCF - 25/08/2011 - Campo do Peso Bruto Unitário
   AADD(aDBF_Stru,{"WKPSBRUTO",AVSX3("W3_PESO_BR",2),AVSX3("W3_PESO_BR",3),AVSX3("W3_PESO_BR",4)})
EndIf

If AvFlags("RATEIO_DESP_PO_PLI")
   AADD(aDBF_Stru,{"WKFRETE",AVSX3("W3_FRETE",2)  ,AVSX3("W3_FRETE",3)  ,AVSX3("W3_FRETE",4)})
   AADD(aDBF_Stru,{"WKSEGUR",AVSX3("W3_SEGURO",2) ,AVSX3("W3_SEGURO",3) ,AVSX3("W3_SEGURO",4)})
   AADD(aDBF_Stru,{"WKINLAN",AVSX3("W3_INLAND",2) ,AVSX3("W3_INLAND",3) ,AVSX3("W3_INLAND",4)})
   AADD(aDBF_Stru,{"WKDESCO",AVSX3("W3_DESCONT",2),AVSX3("W3_DESCONT",3),AVSX3("W3_DESCONT",4)})
   AADD(aDBF_Stru,{"WKPACKI",AVSX3("W3_PACKING",2),AVSX3("W3_PACKING",3),AVSX3("W3_PACKING",4)})
   If SW3->(FieldPos("W3_OUT_DES")) > 0
      AADD(aDBF_Stru,{"WKOUTDE",AVSX3("W3_OUT_DES",2),AVSX3("W3_OUT_DES",3),AVSX3("W3_OUT_DES",4)})
   EndIf
EndIf

//AOM - 07/04/2011 - Criação dos campos cod. ope Esp. e Desc ope. Esp. na Work_SW3 - para copiar um PO para outro
If lOperacaoEsp
   AADD(aDBF_Stru,{"W3_CODOPE",AVSX3("W3_CODOPE",2),AVSX3("W3_CODOPE",3),AVSX3("W3_CODOPE",4)})
   AADD(aDBF_Stru,{"W3_DESOPE",AVSX3("W3_DESOPE",2),AVSX3("W3_DESOPE",3),AVSX3("W3_DESOPE",4)})
EndIf

//FSM - 16/05/2012 - Admissão em Entreposto
If EasyGParam("MV_AVG0211",,.F.) .And. SW3->(FieldPos("W3_ALTANU")) > 0
   AADD(aDBF_Stru,{"WKALTANU", AVSX3("W3_ALTANU",2), AVSX3("W3_ALTANU" ,3), AVSX3("W3_ALTANU" ,4)})
EndIf

IF AvFlags("EIC_EAI")//AWF - 25/06/2014
   AADD(aDBF_Stru,{"WKUNI"    ,"C",AVSX3("W3_UM"     ,3),0})
   AADD(aDBF_Stru,{"WKSEGUM"  ,"C",AVSX3("W3_SEGUM"  ,3),0})
   AADD(aDBF_Stru,{"WKQTSEGUM","N",AVSX3("W3_QTSEGUM",3),AVSX3("W3_QTSEGUM" ,4)})
   AADD(aDBF_Stru,{"WKFATOR"  ,"N",AVSX3("J5_COEF"   ,3),AVSX3("J5_COEF",4)})
   If SW0->(FieldPos("W0_REFER1")) > 0 //NCF - 26/09/2016
      AADD(aDBF_Stru,{"WKREFER1"  ,"C",AVSX3("W0_REFER1"   ,3),AVSX3("W0_REFER1",4)})
   EndIf
ENDIF

If lNestle
   ExecBlock(cArqNestle,.F.,.F.,"1")
Endif

//EOB - 04/01/10 - Inclusão do campo referente ao grupo de regime de tributação na Work dos itens do PO
If lRegTriPO
   AADD(aDBF_Stru,{"WKGRUPORT",AVSX3("W3_GRUPORT",2),AVSX3("W3_GRUPORT",3),AVSX3("W3_GRUPORT",4)})
Endif

IF lRdMake
   ExecBlock("EICPPO02",.F.,.F.,"17")
ENDIF

IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"AADD_WORK"),)

SW5->(DbSetOrder(3))
//TRP-14/05/07
aOrd := SaveOrd("SX3",1)
SX3->(dbSeek("SW3"))

   While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SW3"
      If SX3->X3_PROPRI=="U" .AND. Ascan(aDBF_Stru, {|x| AllTrim(x[1]) == AllTrim(SX3->X3_CAMPO)})==0 .AND. X3Uso(SX3->X3_USADO)
         aAdd(aDBF_Stru,{SX3->X3_CAMPO,AVSX3(SX3->X3_CAMPO,AV_TIPO),AVSX3(SX3->X3_CAMPO,AV_TAMANHO),AVSX3(SX3->X3_CAMPO,AV_DECIMAL)})
      EndIF
      SX3->(dbSkip())
   Enddo
RestOrd(aOrd)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho e indice                                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aDBF_Stru,{"DBDELETE","L",1,0}) //THTS - 01/11/2017 - Este campo deve sempre ser o ultimo campo da Work
//FileWork := E_CriaTrab(,aDBF_Stru,"Work") //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

If IsMemVar("lPOAuto") .And. lPOAuto
   cAliasWkTmp := GetNExtAlias()
   FileWork:=E_CriaTrab(,aDBF_Stru,cAliasWkTmp,,,, SaveTempFiles())
   (cAliasWkTmp)->(DbCloseArea())
   TETempReOpen(TeTempName(cAliasWkTmp),cAliasWkTmp,"Work")
Else
   FileWork:=E_CriaTrab(,aDBF_Stru,"Work")
EndIf

cMarca := GetMark(,"WORK","WKFLAGWIN")
IF ! USED()
   Work->(E_EraseArq(FileWork))
   Help(" ",1,"E_NAOHAREA")
   RETURN .F.
ENDIF

IF EICLOJA()
   IndRegua("Work",FileWork+TEOrdBagExt(), "WKCC+WKSI_NUM+WKCOD_I+WKFABR+W3_FABLOJ+WKFORN+W3_FORLOJ+STR(WKREG,"+Str(AVSX3("W3_REG",3))+",0)")
ELSE
   IndRegua("Work",FileWork+TEOrdBagExt(), "WKCC+WKSI_NUM+WKCOD_I+WKFABR+WKFORN+STR(WKREG,"+Str(AVSX3("W3_REG",3))+",0)")
ENDIF

WorkNTX2:= E_Create(aDBF_Stru,.F.,"Work", FileWork, 1, SaveTempFiles())
E_IndRegua("Work",WorkNTX2+TEOrdBagExt(),"WKPOSICAO",;
           "AllwaysTrue()",;
           "AllwaysTrue()",;
           STR0200) //"Processando Arquivo Temporario..."

/* wfs mar/2017 - adequação para uso do EECGetIndexFile e EECIndRequa */
cIndex:=E_Create(,.F.,"Work", FileWork, 2, SaveTempFiles())
E_IndRegua("Work",cIndex+TEOrdBagExt(),"WKCC+WKSI_ORI",;
           "AllwaysTrue()",;
           "AllwaysTrue()",;
           STR0198) //"Processando Arquivo Temporário..."

If !( Type("lPoAuto")=="L" .And. lPoAuto) //FSM - 17/05/2012
   IncProc(STR0226+"4") //"Criando Indice 4"
EndIf

cIndex4:=E_Create(,.F.,"Work", FileWork, 3, SaveTempFiles())
E_IndRegua("Work",cIndex4+TEOrdBagExt(),"WKCC+WKSI_NUM+WKPOSIT",; //WKPOSICAO
            "AllwaysTrue()","AllwaysTrue()",;
            STR0198) //"Processando Arquivo Temporário..."

SET INDEX TO (FileWork+TEOrdBagExt()),(WorkNTX2+TEOrdBagExt()),(cIndex+TEOrdBagExt()),(cIndex4+TEOrdBagExt())


IF EasyEntryPoint("EICPPO02")
   ExecBlock("EICPPO02",.F.,.F.,"26")
ENDIF

// EOB - 21/01/10 - criação da nova tabela de trabalho WorkPO_EIJ
IF lRegTriPO
    aCamposEIJ := {'EIJ_ADICAO','EIJ_PO_NUM','EIJ_REGTRI','EIJ_FUNREG','EIJ_MOTADI','EIJ_TACOII','EIJ_ACO_II',;
                   'EIJ_ASSII' ,'EIJ_EX_II' ,'EIJ_ATO_II','EIJ_ORG_II','EIJ_NRATII','EIJ_ANO_II','EIJ_TPAII',;
                   'EIJ_ALI_II','EIJ_ALA_II','EIJ_ALR_II','EIJ_PR_II' ,'EIJ_CALCII','EIJ_ALU_II','EIJ_REGIPI',;
                   'EIJ_ASSIPI','EIJ_EX_IPI','EIJ_ATOIPI','EIJ_ORGIPI','EIJ_NROIPI','EIJ_ANOIPI','EIJ_TPAIPI',;
                   'EIJ_ALAIPI','EIJ_ALRIPI','EIJ_ALUIPI','EIJ_QTUIPI','EIJ_REG_PC','EIJ_FUN_PC','EIJ_FRB_PC',;
                   'EIJ_PRB_PC','EIJ_TPAPIS','EIJ_ALAPIS','EIJ_REDPIS','EIJ_ALUPIS','EIJ_QTUPIS','EIJ_TPACOF',;
                   'EIJ_ARDCOF','EIJ_ALCOFM','EIJ_ALPISM','EIJ_ALCOFM','EIJ_ALACOF','EIJ_REDCOF','EIJ_ALUCOF',;
                   'EIJ_QTUCOF','EIJ_OPERAC','EIJ_QTU_II','EIJ_CALIPI'}

	aSX3 := SX3->( {IndexOrd(), Recno() } )
	SX3->(DBSETORDER(2))
	For i:=1 to LEN(aCamposEIJ)
		IF SX3->( DBSEEK(aCamposEIJ[i]) )
	  	   SX3->( AADD(aEIJ, {aCamposEIJ[i], X3_TIPO, X3_TAMANHO, X3_DECIMAL}) )
	    ENDIF
	Next

	AADD(aEIJ, {"WK_RECNO" , "N", 7, 0})

   cWkPO_EIJ := E_CriaTrab(,aEIJ,"WorkPO_EIJ") //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

	IF !USED()
	   Help(" ",1,"E_NAOHAREA") ; lRetorno:=.F.
	   WorkPO_EIJ->(E_EraseArq(cWkPO_EIJ)) //wfs
	   Return .T.
	ENDIF

	IndRegua("WorkPO_EIJ",cWkPO_EIJ +TEOrdBagExt(),"EIJ_ADICAO")
	Set Index To (cWkPO_EIJ+TEOrdBagExt())//,(cWkPO_EIJ2+OrdBagExt())

ENDIF

if nValItens==nil // Jonato em 19 de Agosto. Para não permitir excluir valores que estejam no financeiro
   nValItens:= 0
endif
If ( Type("lPOAuto") == "U" .OR. !lPOAuto )
MsAguarde({||SW3->(PO400Work({|msg|MsProcTxt(msg)},cOpcao,@nValItens))},;
                                        STR0047) //"Pesquisa de Itens"
Else

   bExec:= {||SW3->(PO400Work(,cOpcao,@nValItens))}
   Eval(bExec)

Endif

Return .T.

*----------------------------------------------------------------------------
Function PO400Work(bMsg,cOpcao,nValItens)
*----------------------------------------------------------------------------
LOCAL cKey_SA5 := " ", cKey_SB1 := " "
LOCAL cKey_SY3 := " ", cKey_SYG := " "
LOCAL cFilEIJ := xFilial("EIJ")
LOCAL lAchou := .F. //FDR - 08/05/2013
LOCAL cPoNum := SW2->W2_PO_NUM
PRIVATE cOpcao_Rot:=cOpcao

IF nValItens==nil
   nValItens:=0
Endif
SA5->(DbSetOrder(3))
SW3->(dbSetOrder(7)) // FILIAL+PO+SEQ

If Type("lPOAuto") == "U"
   lPOAuto:= .F.
EndIf 

If Select("ITSW3") > 0
   ITSW3->(DbCloseArea())
EndIf   


BeginSQL Alias "ITSW3"

         SELECT SW3.R_E_C_N_O_ RECNOSW3,
                  EJ0.EJ0_DESC,
                  SB1.B1_MIDIA,
                  SB1.B1_QTMIDIA,
                  SB1.B1_POSIPI,
                  SB1.B1_EX_NCM,
                  SB1.B1_EX_NBM,
                  SW2.W2_VLMIDIA,
                  SW2.W2_IMPORT,
                  SY3.Y3_DESC,
                  SYG.YG_REG_MIN,
                  SA5.A5_CODPRF  
                  FROM %Table:SW3%  SW3 LEFT JOIN %Table:EJ0% EJ0 ON SW3.W3_CODOPE = EJ0.EJ0_COD AND EJ0.EJ0_FILIAL = %exp:xFilial("EJ0")% AND EJ0.%NotDel%
			                               LEFT JOIN %Table:SB1% SB1 ON SB1.B1_FILIAL = %exp:xFilial("SB1")% AND SW3.W3_COD_I = SB1.B1_COD AND SB1.%NotDel%
			                               LEFT JOIN %Table:SW2% SW2 ON SW3.W3_FILIAL = SW2.W2_FILIAL AND SW3.W3_PO_NUM = SW2.W2_PO_NUM  AND SW2.%NotDel%
			                               LEFT JOIN %Table:SY3% SY3 ON SW3.W3_CC = SY3.Y3_COD AND SY3.Y3_FILIAL = %exp:xFilial("SY3")%  AND SY3.%NotDel%
			                               LEFT JOIN %Table:SYG% SYG ON SYG.YG_FILIAL = %exp:xFilial("SYG")% AND SW2.W2_IMPORT = SYG.YG_IMPORTA AND SYG.YG_FABRICA = SW3.W3_FABR AND SYG.YG_FABLOJ = SW3.W3_FABLOJ AND SYG.YG_ITEM = SW3.W3_COD_I AND SYG.%NotDel%
                                        LEFT JOIN %Table:SA5% SA5 ON SA5.A5_FILIAL = %exp:xFilial("SA5")% AND SA5.A5_PRODUTO = SW3.W3_COD_I AND SA5.A5_FABR = SW3.W3_FABR AND SA5.A5_FALOJA = W3_FABLOJ AND SA5.A5_FORNECE = SW3.W3_FORN AND SA5.A5_LOJA = SW3.W3_FORLOJ AND SA5.%NotDel%
                  WHERE SW3.%NotDel% AND SW3.W3_PO_NUM = %exp:cPoNum% AND SW3.W3_FILIAL= %exp:xFilial("SW3")% AND SW3.W3_SEQ = 0
                  ORDER BY SW3.W3_FILIAL,SW3.W3_PO_NUM,SW3.W3_POSICAO
         EndSql

WHILE .NOT. ITSW3->(EOF())

   SW3->(DBGOTO(ITSW3->RECNOSW3))

   If !lPOAuto
      Eval(bMsg,STR0048+ALLTRIM(SW3->W3_COD_I)) //"Processando Item "
   Endif

   MConta:= MConta + 01

   //IF cOpcao = ESTORNO .And. ITSW3->W3_FLUXO # "7" .AND. ITSW3->W3_QTDE - ITSW3->W5_QTDE <= 0 //FDR - 23/04/12 //SW3->W3_SALDO_Q == 0
   IF cOpcao = ESTORNO .And. SW3->W3_FLUXO # "7" .AND. SW3->W3_SALDO_Q == 0
      lLeuTodosItens:=.F.//AWF - 21/07/2014 - Variavel usada na funcao Function EICPO420(lEnvio,nOpc,aCab,cAlias,lWk,cPo_num)
      DBSKIP() ; LOOP
   ENDIF
  
   IF SW3->W3_FLUXO == "7"
      nQtd_Gi:=nSld_Gi:=nQtdEmb:=0
      Po420_IgPos("3")
      nSeq_SLi:= SW5->W5_PGI_NUM
      IF cOpcao = ESTORNO .And. SW3->W3_QTDE - nQtdEmb <= 0 //nSld_Gi == 0
         lLeuTodosItens:=.F.//AWF - 21/07/2014 - Variavel usada na funcao Function EICPO420(lEnvio,nOpc,aCab,cAlias,lWk,cPo_num)
         DBSKIP() ; LOOP
      ENDIF
   ENDIF

   lSkip := .F.//ASR 25/08/2005
   IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"ANTES_GRAVA_WORK_SW3"),)//ASR 25/08/2005
   IF lSkip  //ASR 25/08/2005
      lLeuTodosItens:=.F.//AWF - 21/07/2014 - Variavel usada na funcao Function EICPO420(lEnvio,nOpc,aCab,cAlias,lWk,cPo_num)
      ITSW3->(DBSkip()) ; Loop
   ENDIF

   Work->(DBAPPEND())

   //AOM - 07/04/2011 - Adicionar todos os campo da base para work com o mesmo nome
   AVREPLACE("SW3","Work")
   //AOM - 07/04/2011 - Adiciona descrição da operação na Work_EJ3
   
   If lOperacaoEsp
      Work->W3_DESOPE := ITSW3->EJ0_DESC
   EndIf
   
   REPLACE Work->WKCOD_I    WITH  SW3->W3_COD_I            ,;
           Work->WKFABR     WITH  SW3->W3_FABR             ,;
           Work->W3_FABLOJ  WITH  SW3->W3_FABLOJ           ,;
           Work->WKFORN     WITH  SW3->W3_FORN             ,;
           Work->W3_FORLOJ  WITH  SW3->W3_FORLOJ           ,;
           Work->WKREG      WITH  SW3->W3_REG              ,;
           Work->WKSEQ      WITH  SW3->W3_SEQ              ,;
           Work->WKQTDE     WITH  SW3->W3_QTDE             ,;
           Work->WKQTDE_O   WITH  SW3->W3_QTDE             ,;
           Work->WKPRECO    WITH  SW3->W3_PRECO            ,;
           Work->WKSALDO_Q  WITH  SW3->W3_SALDO_Q          ,;
           Work->WKCC       WITH  SW3->W3_CC               ,;
           Work->WKPOSICAO  WITH  SW3->W3_POSICAO          ,;
           Work->WKSI_NUM   WITH  SW3->W3_SI_NUM           ,;
           Work->WKDT_EMB   WITH  SW3->W3_DT_EMB           ,;
           Work->WKDT_ENTR  WITH  SW3->W3_DT_ENTR          ,;
           Work->WKRECNO    WITH  SW3->(RECNO())           ,;           
           Work->WKFLUXO    WITH  SW3->W3_FLUXO            ,;
           Work->WKCCNOME   WITH  ITSW3->Y3_DESC           ,;
           Work->WK_REG_MIN WITH  ITSW3->YG_REG_MIN        ,;
           Work->WKSEM_PO   WITH  (POSALDO_W1()-Work->WKQTDE_O),;   // AWR 15/04/2004   //POSALDO_W1()               // JBS - 03/02/2004
           Work->TRB_ALI_WT WITH  "SW3",;
           Work->TRB_REC_WT WITH  SW3->(Recno())           ,;
           Work->WKPO_NUM   WITH  SW3->W3_PO_NUM           ,;
           Work->WKPESOL    WITH  SW3->W3_PESOL            ,;
           Work->WKSLD_ELI  WITH  SW3->W3_SLD_ELI
          
   If lCpoCtCust                          //NCF - 22/06/2010
      Work->WKCTCUSTO := SW3->W3_CTCUSTO
   EndIf

   If lPesoBruto  
      Work->WKPSBRUTO := SW3->W3_PESO_BR
   EndIf

   If AvFlags("RATEIO_DESP_PO_PLI")
      Work->WKFRETE := SW3->W3_FRETE
      Work->WKSEGUR := SW3->W3_SEGURO
      Work->WKINLAN := SW3->W3_INLAND
      Work->WKDESCO := SW3->W3_DESCONT
      Work->WKPACKI := SW3->W3_PACKING
      If SW3->(FieldPos("W3_OUT_DES")) > 0
         Work->WKOUTDE := SW3->W3_OUT_DES
      EndIf
   EndIf

   //FSM - 24/05/2012
   If EasyGParam("MV_AVG0211",,.F.)
      Work->WKALTANU := SW3->W3_ALTANU
   EndIf

   // JBS - 03/02/2004
   IF SW3->W3_QTDE # SW3->W3_SALDO_Q
      nQtd_Gi:=nSld_GI:=0
      nQtdEmb := 0
      Po420_IgPos("1")
      Work->WKSALDO_GI  := nSld_Gi
      Work->WKQTDE_GI   := nQtd_Gi
      Work->WKQTDE_EMB  := nQtdEmb
      Work->WKQTDE_LI   := WORK->WKQTDE_GI
   ENDIF

   IF EasyEntryPoint("EICPO400")
      ExecBlock("EICPO400",.F.,.F.,"REPLACE")
   ENDIF
   IF(lSeal,ExecBlock("IC193PO1",.F.,.F.,"3"),) //AWR 01/10/1999
   IF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"9"),)//AWR 09/11/1999

   IF lExiste_Midia           .AND.;
      !EMPTY(ITSW3->W2_VLMIDIA) .AND.;
      ITSW3->B1_MIDIA $ cSim
      Work->WK_QTMIDIA := ITSW3->B1_QTMIDIA
      Work->WK_VLTOTMI := ITSW3->B1_QTMIDIA * ITSW3->W2_VLMIDIA * WORK->WKQTDE
   ENDIF

   IF EasyEntryPoint("IC086PO1")
      ExecBlock("IC086PO1",.F.,.F.,3)
   ENDIF

   IF EMPTY(ALLTRIM(SW3->W3_TEC))
      Work->WK_TEC    := ITSW3->B1_POSIPI
      Work->WK_EX_NCM := ITSW3->B1_EX_NCM
      Work->WK_EX_NBM := ITSW3->B1_EX_NBM
   ELSE
      Work->WK_TEC    := SW3->W3_TEC
      Work->WK_EX_NCM := SW3->W3_EX_NCM
      Work->WK_EX_NBM := SW3->W3_EX_NBM
   ENDIF

   Work->WK_ALTEROU := .F. // Qdo True indica que o registro foi alterado.

   If lForeCast
      Work->WK_FORECAS := SW3->W3_FORECAS
   Endif

   Work->WK_REG_TRI := SW3->W3_REG_TRI

   If lNestle
      ExecBlock(cArqNestle,.F.,.F.,"2")
   Endif

   IF AvFlags("EIC_EAI")//AWF - 25/06/2014
      Work->WKUNI    := SW3->W3_UM
      Work->WKSEGUM  := SW3->W3_SEGUM
      Work->WKQTSEGUM:= SW3->W3_QTSEGUM
      Work->WKFATOR  := Work->WKQTSEGUM/Work->WKQTDE
      Work->WKREFER1 := SI410GtAgp(SW3->W3_SI_NUM)
   ENDIF

   IF SW3->W3_FLUXO == "7"
      Work->WKQTDE_EMB:= nQtdEmb 
      Work->WKSALDO_Q := nSld_Gi //SW3->W3_QTDE - nQtdEmb//nSld_Gi
   ENDIF

   E_ItFabFor(.T.,,"PO")

   PosO1_It_Solic(SW3->W3_CC, SW3->W3_SI_NUM, SW3->W3_COD_I, SW3->W3_REG, 0)
   Work->WKPOSIT    := SW1->W1_POSIT
   
   IF cPaisLoc # "BRA"  .AND. SW1->(FIELDPOS("W1_NATUREZ")) # 0 //out/2019: campo W1_NATUREZ não está no dicionário padrão
      //PosO1_It_Solic(SW3->W3_CC, SW3->W3_SI_NUM, SW3->W3_COD_I, TSW3->W3_REG, 0)
      Work->WKNATUREZA:= SW1->W1_NATUREZ
   ENDIF

   Work->WKPART_N   := SW3->W3_PART_N
   IF EMPTY(Work->WKPART_N)   //ASK  02/10/2007 //correção para não sobrescrever a informação digitada pelo usuário
      Work->WKPART_N   := AllTrim(ITSW3->A5_CODPRF)     
   ENDIF

   //TRP- 01/06/09 - Campo Software para novo Tratamento de Mídia e Software
   If SW3->(FieldPos("W3_SOFTWAR")) # 0 .And. EasyGParam("MV_CONSOFT",, "N") $ cSim
      Work->WKSOFTWAR:= SW3->W3_SOFTWAR
   Endif

   //EOB- 21/01/10 - Gravação do campo Regime de tributação
   If lRegTriPO
      Work->WKGRUPORT := SW3->W3_GRUPORT
   Endif

   MTotal+=( ROUND(SW3->W3_QTDE * SW3->W3_PRECO,2) )
   IF lRdMake
      ExecBlock("EICPPO02",.F.,.F.,"18")
   ENDIF
   nPontoEntrada:=1
   IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"WORK_DESPESAS"),)
   DBSelectArea("ITSW3")
   ITSW3->(DBSKIP())
ENDDO

IF lRegTriPO .And. (Type("Inclui") <> "L" .Or. !Inclui)
   EIJ->(dbSetOrder(2))
   EIJ->(dbSeek(cFilEIJ + SW2->W2_PO_NUM))
   DO WHILE !EIJ->(eof()) .AND. EIJ->EIJ_PO_NUM == SW2->W2_PO_NUM
      If WORKPO_EIJ->(!dbSeek(EIJ->EIJ_ADICAO))
         WORKPO_EIJ->(dbAppend())
         AVREPLACE("EIJ", "WORKPO_EIJ")
         WORKPO_EIJ->WK_RECNO := EIJ->(recno())
      EndIf
      EIJ->(dbSkip())
   ENDDO
ENDIF

Return .T.
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PO400LinOk³ Autor ³ PADRAO PARA GETDADDB  ³ Data ³ 13.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para mudanca/inclusao de linhas do Orcamento. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ExpN1 = PO400LinOk                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Valor devolvido pela fun‡„o                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function PO400LinOk(o)
Local lRet := .T.
// Fazer as consistencias especiais


Return( lRet )
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PO400TudOk³ Autor ³ PADRAO GETDADDB       ³ Data ³ 13.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia geral dos itens de Pedidos de Venda           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ExpN1 = PO400TudOk                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Valor devolvido pela fun‡„o                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function PO400TudOk(o)

// Fazer as consitencias em todo arquivo TRB

Return( .T. )
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³......... ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 17.09.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Conjunto de funcoes originarias do PO420 e PO420A           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
FUNCTION PO_Create(WFlag)

Local bExec
*** VARIAVEIS PARA A TELA HUM
PRIVATE TObs, TImport, TConsig,;
        TObs_Cod, T2Obs_Cod, TDt_Pro_Ant:= M->W2_DT_PRO, lValidSld := .T.

TEmb_Ant   := AVCTOD(SPACE(08))
TEnt_Ant   := AVCTOD(SPACE(08))

TObs       := SPACE(01)                                                            //mjb 16:50 18 Apr,1994
TObs_Cod   := 0
T2Obs_Cod  := 0
TImport    := TConsig := '  '    //mjb 16:50 18 Apr,1994
MVlCon_Cr  := 0
TInland    := 0
TDesconto  := 0
TPacking   := 0
TOutDesp   := 0
TFreteIntl := 0
TSeguro    := 0
TIncoterm  := SPACE(8)

TPO_NUM    :=M->W2_PO_NUM
TPO_SIGA   :=M->W2_PO_SIGA
TObs       :=M->W2_OBS
TInland   :=M->W2_INLAND
TOutDesp  :=M->W2_OUT_DES
TFreteIntl:=M->W2_FRETEIN
TSeguro   :=If(AvFlags("RATEIO_DESP_PO_PLI"),M->W2_SEGURIN,0)
TPacking  :=M->W2_PACKING
TDesconto :=M->W2_DESCONT
MForn      :=M->W2_FORN

IF EICLOJA()
   MLoja  := M->W2_FORLOJ
ENDIF

TIncoTerm  :=M->W2_INCOTER
TImport    :=M->W2_IMPORT
TConsig    :=M->W2_CONSIG

*** VARIAVEIS PARA A TELA TRES
PRIVATE TSaldo_Q,TVlUnit,TDtEmbarque,TDtEntrega,MForn,TForn,TFabr,TFabr_01 ,;
        TFabr_02,TFabr_03,TFabr_04,TFabr_05, TPosicao, cRegMinist, TDtPrvEntr, TCSolicit, TCEmail, TCNome // JBS - 14/07/2003
PRIVATE cForecast := Space(1)

TSaldo_Q   := 0
TVlUnit    := 0
MForn      := ""
TForn      := SPACE(nLenForn)  //SO0026 FCD OS.:0243/02
TFabr      := SPACE(nLenFabr)  //SO0026 FCD OS.:0243/02
TFabr_01   := SPACE(nLenFabr)  //SO0026 FCD OS.:0243/02
TFabr_02   := SPACE(nLenFabr)  //SO0026 FCD OS.:0243/02
TFabr_03   := SPACE(nLenFabr)  //SO0026 FCD OS.:0243/02
TFabr_04   := SPACE(nLenFabr)  //SO0026 FCD OS.:0243/02
TFabr_05   := SPACE(nLenFabr)  //SO0026 FCD OS.:0243/02
TPosicao   := 0
TDtEmbarque:= AVCTOD(SPACE(08))
TDtEntrega := AVCTOD(SPACE(08))
cRegMinist := SPACE(10)

*** VARIAVEL PARA A TELA QUATRO

MSalvaFilter := SPACE(01)
MControla := .T.
MControle := .T.
W_Flag_Seq:= .F.

MTotFOB:=M->W2_FOB_TOT + TInland + TFreteIntl + TPacking + TSeguro - TDesconto

If ( Type("lPOAuto") == "U" .OR. !lPOAuto )
MsAguarde({|lEnd|PO_Existe({|msg|MsProcTxt(msg)},1)},STR0047) //"Pesquisa de Itens"
Else
   bExec:= {|lEnd|PO_Existe(,1)}
   Eval(bExec)
Endif

lContinuaFluxo:=.t.
IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"ANTES_P_TE_2"),)

IF !lContinuaFluxo
   RETURN .T.
ENDIF

lRet := P_Te_2()

If lPoAuto
   If lNotPOErroAuto
      lNotPOErroAuto:= lRet
   Endif
Endif

IF MControla = .F.
   SW0->(MSUnlock())
ENDIF

Return (lRet)

*----------------------------------------------------------------------------
FUNCTION PO_Existe(bMsg,MChamada)
*----------------------------------------------------------------------------
LOCAL cFilEIJ := xFilial("EIJ")
LOCAL cFilSW3 := xFilial("SW3")
LOCAL cKey_SW0 := " "
LOCAL cKey_SYG := " "

If ( Type("lPOAuto") == "U" .OR. !lPOAuto )
   Eval(bMsg,STR0049) //"REGERANDO ARQUIVO DE TRABALHO"
Endif

DBSELECTAREA("SW3")
SB1->(dbSetOrder(1))
SW3->(dbSetOrder(7)) // FILIAL+PO+SEQ
SW3->(DBSEEK(xFilial()+TPO_NUM))

nOrdWork := Work->(IndexOrd())
Work->(dbSetOrder(1))

If Type("lPOAuto") == "U"
   lPOAuto:= .F.
EndIf 

DO WHILE .NOT. SW3->(EOF()) .AND. SW3->W3_PO_NUM = TPO_NUM .AND. SW3->W3_FILIAL == cFilSW3

   If !lPOAuto
      Eval(bMsg,STR0050+ALLTRIM(SW3->W3_COD_I)) //"Lendo Itens do P.O. "
   Endif

   IF SW3->W3_SEQ <> 0
      W_Flag_Seq:= .T.
      EXIT  // *** CAF 13/03/1999 Melhorias NEC
   ENDIF

   IF TNr_Cont < SW3->W3_NR_CONT
      TNr_Cont:= SW3->W3_NR_CONT
   ENDIF

   MFob_Abs += VAL(STR(SW3->W3_QTDE * SW3->W3_PRECO,15,2))

//Nopado por FDR - 01/06/12
/* If SW3->(FIELDPOS("W3_SLD_ELI")) # 0
      MFob_Abs-=VAL(STR(SW3->W3_SLD_ELI * SW3->W3_PRECO,15,2))
   EndIf*/


   If cKey_SYG != SW3->W3_FABR+SW3->W3_COD_I // CAF Melhorias NEC 17/03/1999
      cKey_SYG := SW3->W3_FABR+SW3->W3_COD_I
      SYG->(DBSEEK(xFilial()+SW2->W2_IMPORT+SW3->W3_FABR+EICRetLoja("SW3","W3_FABLOJ")+SW3->W3_COD_I))
   Endif

   If !Work->(dbSeek(SW3->(W3_CC+W3_SI_NUM+W3_COD_I+Str(W3_REG,AVSX3("W3_REG",3)))))
   Work->(DBAPPEND())

   //AOM - 07/04/2011 - Adicionar todos os campo da base para work com o mesmo nome
   AVREPLACE("SW3","Work")
   //AOM - 07/04/2011 - Adiciona descri?o da opera?o na Work_EJ3
   If lOperacaoEsp
      Work->W3_DESOPE := Posicione("EJ0",1,xFilial("EJ0") + AvKey(SW3->W3_CODOPE,"EJ0_COD"),"EJ0_DESC")
   EndIf

   Work->WKPO_NUM   := SW3->W3_PO_NUM
   Work->WKCOD_I    := SW3->W3_COD_I
   Work->WKFABR     := SW3->W3_FABR
   Work->WKFABR_01  := SW3->W3_FABR_01
   Work->WKFABR_02  := SW3->W3_FABR_02
   Work->WKFABR_03  := SW3->W3_FABR_03
   Work->WKFABR_04  := SW3->W3_FABR_04
   Work->WKFABR_05  := SW3->W3_FABR_05
   IF EICLOJA()
      Work->W3_FABLOJ := SW3->W3_FABLOJ
      Work->W3_FAB1LOJ:= SW3->W3_FAB1LOJ
      Work->W3_FAB2LOJ:= SW3->W3_FAB2LOJ
      Work->W3_FAB3LOJ:= SW3->W3_FAB3LOJ
      Work->W3_FAB4LOJ:= SW3->W3_FAB4LOJ
      Work->W3_FAB5LOJ:= SW3->W3_FAB5LOJ
      Work->W3_FORLOJ := SW3->W3_FORLOJ
      Work->W3_FABL_O := SW3->W3_FABLOJ
      Work->W3_FORL_O := SW3->W3_FORLOJ
   ENDIF
   Work->WKFABR_O   := SW3->W3_FABR
   Work->WKFORN     := SW3->W3_FORN
   Work->WKFORN_O   := SW3->W3_FORN
   Work->WKREG      := SW3->W3_REG
   Work->WKSEQ      := SW3->W3_SEQ
   Work->WKQTDE     := SW3->W3_QTDE//SW3->W3_SALDO_Q
   Work->WKQTDE_O   := SW3->W3_QTDE
   Work->WKPRECO    := SW3->W3_PRECO
   Work->WKSALDO_Q  := SW3->W3_SALDO_Q
   Work->WKSALDO_O  := SW3->W3_SALDO_Q
   Work->WKCC       := SW3->W3_CC
   Work->WKSI_NUM   := SW3->W3_SI_NUM
   Work->WKDT_EMB   := SW3->W3_DT_EMB
   Work->WKDT_ENTR  := SW3->W3_DT_ENTR
   Work->WKDTENTR_S := SW3->W3_DT_ENTR
   Work->WKPORTARIA := SW3->W3_PORTARI
   Work->WKDTEMB_S  := SW3->W3_DT_EMB
   Work->WKPRECO_S  := SW3->W3_PRECO
   Work->WKFLAG     := .T.
   Work->WKPOSICAO  := SW3->W3_POSICAO && Alterado por RJB - 15:49 24 Mar,1995
   Work->WKFLAG2    := .T.
   Work->WKFLUXO    := SW3->W3_FLUXO
   Work->WKFLUXO_O  := SW3->W3_FLUXO
   Work->WKFLAGWIN  := cMarca
   Work->WKFLAGWIN2 := cMarca
   Work->WKPRTOT    := DI500TRANS(SW3->W3_PRECO*SW3->W3_QTDE,2)//JVR / 28/10/2009 - DI500TRANS()

   IF AvFlags("EIC_EAI")//AWF - 25/06/2014
      Work->WKUNI    :=SW3->W3_UM
      Work->WKSEGUM  :=SW3->W3_SEGUM
      Work->WKQTSEGUM:=SW3->W3_QTSEGUM
      Work->WKFATOR  :=Work->WKQTSEGUM/Work->WKQTDE
      If SW0->(FieldPos("W0_REFER1")) > 0  //NCF - 26/09/2016
         Work->WKREFER1 := SI410GtAgp(SW3->W3_SI_NUM)
      EndIf
   ELSE
      IF EICLOJA()
         Work->WKUNI      := Work->(BUSCA_UM(Work->WKCOD_I+Work->WKFABR+Work->WKFORN,WORK->WKCC+WORK->WKSI_NUM,WORK->W3_FABLOJ,WORK->W3_FORLOJ))
      ELSE
         Work->WKUNI      := Work->(BUSCA_UM(Work->WKCOD_I+Work->WKFABR+Work->WKFORN,WORK->WKCC+WORK->WKSI_NUM,"",""))
      ENDIF
   ENDIF

   Work->WK_REG_MIN := SYG->YG_REG_MIN  // MFR 13/03/2020 
   Work->WK_ALTEROU := ChkAltDesp()     // .F.  // Qdo True indica que o registro foi alterado.
   Work->WKSEM_PO   := (POSALDO_W1()-Work->WKQTDE_O)   // AWR 15/04/2004   //POSALDO_W1()
   Work->TRB_ALI_WT :=  "SW3"
   Work->WK_TEC    := SW3->W3_TEC
   Work->WK_EX_NCM := SW3->W3_EX_NCM
   Work->WK_EX_NBM := SW3->W3_EX_NBM
   Work->TRB_REC_WT :=  SW3->(Recno())
   Work->WKREC_SW3  :=  SW3->(RECNO()) // SVG - 16/12/2008

   If SW3->(FieldPos("W3_PESOL")) # 0 //CCH - 07/08/09 - Grava?o do novo campo de Peso L?uido Unit?io
      Work->WKPESOL := SW3->W3_PESOL
   EndIf
   If SW3->(FieldPos("W3_SLD_ELI")) > 0 //SVG - 23/02/2011 -
      Work->WKSLD_ELI := SW3->W3_SLD_ELI
   EndIf

   If lCpoCtCust                          //NCF - 22/06/2010
      Work->WKCTCUSTO := SW3->W3_CTCUSTO
   EndIf
   If lPesoBruto                          //NCF - 25/08/2011 - Campo do Peso Bruto Unit?io
      Work->WKPSBRUTO := SW3->W3_PESO_BR
   EndIf
   If AvFlags("RATEIO_DESP_PO_PLI")
      Work->WKFRETE := SW3->W3_FRETE
      Work->WKSEGUR := SW3->W3_SEGURO
      Work->WKINLAN := SW3->W3_INLAND
      Work->WKDESCO := SW3->W3_DESCONT
      Work->WKPACKI := SW3->W3_PACKING
      If SW3->(FieldPos("W3_OUT_DES")) > 0
         Work->WKOUTDE := SW3->W3_OUT_DES
      EndIf
   EndIf
   IF EasyEntryPoint("EICPO400")
      ExecBlock("EICPO400",.F.,.F.,"APPEND")
   ENDIF
   IF EasyEntryPoint("IC086PO1")
      ExecBlock("IC086PO1",.F.,.F.,3)
   ENDIF

    //TRP-14/05/07
   aOrd := SaveOrd("SX3",1)
   SX3->(dbSeek("SW3"))
   While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SW3"
      If SX3->X3_PROPRI=="U" .AND. X3Uso(SX3->X3_USADO) .and. (SX3->X3_ARQUIVO)->(FieldPos(SX3->X3_CAMPO)) > 0
         Eval(FieldWBlock(SX3->X3_CAMPO, Select("Work")),  Eval(FieldWBlock(SX3->X3_CAMPO, Select("SW3"))))
      EndIF
      SX3->(dbSkip())
   Enddo
   RestOrd(aOrd)
   IF lNec
      nExecute:="9"
      Work->(ExecBlock(cArqRdmake,.F.,.F.))
   ENDIF
   IF(lSeal,ExecBlock("IC193PO1",.F.,.F.,"3"),) //AWR 01/10/1999

   IF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"9"),)//RHP 25/02/00

   If(lNestle,Work->(ExecBlock(cArqNestle,.F.,.F.,"2")),)

   If lForeCast
      Work->WK_FORECAS := SW3->W3_FORECAS
   Endif

   IF cKey_SW0 == SW3->W3_CC+SW3->W3_SI_NUM
      Work->WKKIT    := SW0->W0_SIKIT
      Work->WKSERIE  := SW0->W0_KITSERI
      Work->WKQTDKIT := SW0->W0_QTDE
   Else
      IF SW0->( DBSEEK(xFilial()+SW3->W3_CC+SW3->W3_SI_NUM) )
         cKey_SW0 := SW3->W3_CC+SW3->W3_SI_NUM
         Work->WKKIT    := SW0->W0_SIKIT
         Work->WKSERIE  := SW0->W0_KITSERI
         Work->WKQTDKIT := SW0->W0_QTDE
      ENDIF
   ENDIF

   IF SW3->W3_QTDE # SW3->W3_SALDO_Q
      nQtd_Gi:=nSld_GI:=0
      nQtdEmb:= 0

      Po420_IgPos("1")

      Work->WKSALDO_GI  := nSld_Gi
      Work->WKQTDE_GI   := nQtd_Gi
      //Work->WKQTDE_EMB  := (WORK->WKQTDE_GI-WORK->WKSALDO_GI)
      Work->WKQTDE_EMB  := nQtdEmb
      Work->WKQTDE_LI   := (WORK->WKQTDE_GI)
      /*
      lPode_Alt := IF(nSld_Gi = nQtd_Gi,.T.,.F.)  //RHP 05/09/97
      IF !lPode_Alt
         lTrava := .T.
      ENDIF*/
      IF SW3->W3_FLUXO == '7'
//       Work->WKQTDE   := nSld_Gi
         Work->WKSALDO_O:= nSld_Gi
         Work->WKSALDO_Q:= nSld_Gi
         IF ASCAN(aPLIs,SW5->W5_PGI_NUM) == 0
            AADD(aPLIs,SW5->W5_PGI_NUM)
         ENDIF
/*      ELSE
         lTrava:=.T.*/
      ENDIF
   ENDIF

   Work->WK_REG_TRI := SW3->W3_REG_TRI

   MTotal+= VAL(STR(SW3->W3_QTDE * Work->WKPRECO,15,2))

//Nopado por FDR - 01/06/12
/* If SW3->(FIELDPOS("W3_SLD_ELI")) # 0
      MTotal-=VAL(STR(SW3->W3_SLD_ELI * Work->WKPRECO,15,2))
   EndIf*/

   E_ItFabFor(cDESC_PO,,"PO") // posiciona SB1, atualiza descricao do item em ###,
                   // nome reduzido do fabricante e do fornecedor
   
   PosO1_It_Solic(SW3->W3_CC,SW3->W3_SI_NUM,SW3->W3_COD_I,SW3->W3_REG,0)
   Work->WKPOSIT    := SW1->W1_POSIT

   IF cPaisLoc # "BRA"  .AND. SW1->(FIELDPOS("W1_NATUREZ")) # 0
      Work->WKNATUREZA:= SW1->W1_NATUREZ
   ENDIF

   If SW3->(FieldPos("W3_PART_N")) # 0  //ASK 02/10/2007
      Work->WKPART_N := SW3->W3_PART_N
   EndIf

   IF lExiste_Midia         .AND.;
      !EMPTY(M->W2_VLMIDIA) .AND.;
      SB1->B1_MIDIA $ cSim
      Work->WK_QTMIDIA := SB1->B1_QTMIDIA
      Work->WK_VLTOTMI := SB1->B1_QTMIDIA * M->W2_VLMIDIA*Work->WKQTDE
   ENDIF
   //TRP- 01/06/09 - Campo Software para novo Tratamento de M?ia e Software
   If SW3->(FieldPos("W3_SOFTWAR")) # 0 .And. EasyGParam("MV_CONSOFT",, "N") $ cSim
      Work->WKSOFTWAR:= SW3->W3_SOFTWAR
   Endif

   //EOB- 21/01/10 - Campo Regime de Tributa?o
   If lRegTriPO
      IF !EMPTY(SW3->W3_GRUPORT)
         Work->WKGRUPORT:= SW3->W3_GRUPORT
         Work->WKFLAGEIJ := cMarca
      ENDIF
   Endif

   IF lRdMake
      Work->(ExecBlock("EICPPO02",.F.,.F.,"1"))
   ENDIF
   nPontoEntrada:=2
   IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"WORK_DESPESAS"),)
   EndIf
   SW3->(DBSKIP())
ENDDO
Work->(dbSetOrder(nOrdWork))

IF lRegTriPO .And. (Type("Inclui") <> "L" .Or. !Inclui)
   EIJ->(dbSetOrder(2))
   EIJ->(dbSeek(cFilEIJ + SW2->W2_PO_NUM))
   DO WHILE !EIJ->(eof()) .AND. EIJ->EIJ_PO_NUM == SW2->W2_PO_NUM
      If WORKPO_EIJ->(!dbSeek(EIJ->EIJ_ADICAO))
         WORKPO_EIJ->(dbAppend())
         AVREPLACE("EIJ", "WORKPO_EIJ")
         WORKPO_EIJ->WK_RECNO := EIJ->(recno())
      EndIf
      EIJ->(dbSkip())
   ENDDO
ENDIF

Return .T.

*-----------------*
FUNCTION P_Te_2()
// -- Ultima Modif.: 15/9/04
// -- Autor: CDS
// -- Descr: Na Alteracao, nao perguntar o CC e a SI e assumir automaticamente.

*-----------------*
LOCAL _LIT_R_CC := IF(EMPTY(ALLTRIM(EasyGParam("MV_LITRCC"))),(AVSX3("W0__CC")[5]), ALLTRIM(EasyGParam("MV_LITRCC")))
LOCAL _PictItem := ALLTRIM(X3PICTURE("B1_COD"))
LOCAL _PictSI   := ALLTRIM(X3PICTURE("W0__NUM"))
LOCAL _PictCC   := ALLTRIM(X3PICTURE("Y3_COD"))
LOCAL _ColGet:=5+LEN(_LIT_R_CC), LForn:=REPL(CHR(254),nLenForn)
LOCAL nRecno, /*oMark,*/ oPanelSI
LOCAL lValidCC:=.F., lValidSI:=.F.
LOCAL nOpcao := 0
Local  bCancel, lSai:=.F.
Local lFound:=.F.,lTroca:=.F.	   //CDS 15/9/04
Local i,n1,nInc//JL
Local lRet:= .T.
Local aMsgs, iMsg
Local lAutDeleta := lAutInclui := lAutAltera := lAuto := .F.
Local nPO_CC, nPosReg, nPO_SI, nPosCod_i
Local oBrowse,oColumn//JL
Local oDlg //AWF - 08/08/14 - Passei para LOCAL de novo pq dá erro a apertar imprimir o botao imprmiri da FWBROWSE, quem precisa da odl pode usar oDlgx := GetWndDefault()
Local cTitulo		:= "Selecão de Itens"//JL
Local bMarca		:= {|x| (x:= Work->(RecNo()),Work->(DBSETORDER(1)),; //JL
                      P_Te_3(), Work->(dbSetOrder(nOrder)), Work->(dbGoTo(x)), oBrowse:refresh()) }
Local nInd
Local aSeek:= {}, aFilter:= {}
Local oUpdPO400 //THTS - 03/08/2017
Local nCpo
Local aOrdens := {}
Private aButtons := {}
Private lSelecao:=.T.  //SEMPRE .T. 'PARA PADRAO - FOI COLOCADA PARA RDMAKE GRADIENTE
Private bOk
Private nLinha   //oDlg,//AWF - 08/08/14 - Passei para LOCAL de novo pq dá erro a apertar imprimir o botao imprmiri da FWBROWSE, quem precisa da odl pode usar oDlgx := GetWndDefault()
Private lTelaSi := .T. //CCH - 25/08/2009 - Utilizar em ponto de entrada antes da tela de seleção da S.I.
Private lMoeda := .T. //TDF - 19/10/2010
Private oPanel // ACB - 02/12/2010 - Alterada variavel para visualização em ponto de entrada
Private nOpca //DFS - 04/02/11 - Mudança da declaração da variável para utilização em Rdmake
Private cFiltra := "SY3" //LBL - 03/09/2013 - Altera a Consulta Padrão do C.C
Private nOpcPonto //LRS - 11/08/2015
Private nTpX1UPD := 0 //THTS - 03/08/2017 - Utilizada na funcao chamada no AvUudate01.
Private oMarkPTE2

lTelaIte = .F.//replicado da tela de conferência final
IF lRdMake
   lSelecao:=ExecBlock("EICPPO02",.F.,.F.,"ALTERACAO")
ENDIF

If Type("lPOAuto") == "U"
   lPOAuto:= .F.
EndIf 

aAdd(aButtons, {"RESPONSA", {|| PO400MarkIt("M",.T.,,.T.), IF (! lNewTelaSI,oMarkPTE2:oBrowse:Refresh(),oBrowse:refresh())}, STR0340}) //STR0340 "Marcar/Desmarcar"  // GFP - 28/01/2013
IF lNewTelaSI//JL
   aAdd(aButtons, {"LBTIK",{|| nOpca :=FilPergunte(), WORK->(DBGoBottom()),oBrowse:Refresh(.T.)},STR0393,STR0393}) //"Itens"
   aAdd(aButtons, {"LBTIK",{|| CalcTotPO()          , WORK->(DBGOTOP()),oBrowse:Refresh()},STR0276,STR0276})
   //igor chiba 29/07/14 retirar conferencia aAdd(aButtons, {"LBTIK",{|| P_Te_4()             , WORK->(DBGOTOP()),oBrowse:Refresh()},STR0064,STR0064})
   aAdd(aButtons, {"LBTIK",{|| PO420AlteraDatas()   , WORK->(DBGOTOP()),oBrowse:Refresh()},STR0092,STR0092})
   If ALTERA
      AAdd(aButtons, {"EDIT", {|| AtuSegQuant(), oBrowse:Refresh()}, STR0392, STR0392}) //"Quantidade na Segunda Unidade"
   EndIf
Else
	/*wReliquias*/
	aAdd(aButtons, {"LBTIK",{|| lTelaIte := .T.,PO420AlteraDatas()},STR0092,STR0092}) //"Alterar Datas"
   If Empty(ALLTRIM(M->W2_HAWB_DA))
      AAdd(aButtons, {, {|| nOpcao:=99,lSolic:=.T.,lTroca:=.T.,oDlg:End()}, STR0063, STR0063}) //"Trocar S.I."
   EndIf
   AAdd(aButtons, {, {|| CalcTotPO()}, STR0276, STR0276}) //"Totais do PO"
ENDIF
i := 1  //Contador para percorrer todos itens de um Pedido Automático
DO WHILE .T.

   If lPOAuto .AND. Len(aCabItem) >= i
      //If Len(aCabItem) >= i
         If nOpcAuto == 3
            lAutDeleta:= .F.   //Flag para definir se o item será deletado
            lAutInclui:= .T.   //Flag para definir se o item será incluso
            lAutAltera:= .F.   //Flag para definir se o item será alterado
         ElseIf nOpcAuto == 4  //Alteracao Automatica de Pedido

            lAutDeleta:= .F.   //Flag para definir se o item será deletado
            lAutInclui:= .F.   //Flag para definir se o item será incluso
            lAutAltera:= .F.   //Flag para definir se o item será alterado

            //Valida se todos campos necessários para o ExecAuto vieram no array.
            aMsgs:= ValExecAutoCpos(aCabItem[i])
            If Len(aMsgs) > 0
               If lNotPOErroAuto
                  lNotPOErroAuto:= .F.
               Endif

               For iMsg:= 1 to Len(aMsgs)
                  EasyHelp(aMsgs[iMsg],STR0002) //STR0002 "Aviso"
               Next
               i++
               Loop
            Endif

            If (nCpo := aScan(aCabItem[i], {|x| x[1] == "W3_REG" .Or. x[1] == "W3_POSICAO" })) > 0
               If aCabItem[i][nCpo][1] == "W3_REG"
                  cChaveSeek := "WKCC+WKSI_NUM+WKCOD_I+STR(WKREG,"+Str(AVSX3("W3_REG",3))+",0)"
               Else
                  cChaveSeek := Work->(IndexKey(4)) //"WKCC+WKSI_NUM+WKPOSIT"
               EndIf
            EndIf
            
            If EasySeekAuto("WORK", aCabItem[i], 1, aCorrespW3,,cChaveSeek )
               If (nPOsDelA := aScan(aCabItem[i], {|x| x[1] == "AUTDELETA" .AND. x[2] == "S" })) > 0
                  lAutDeleta:= .T.
               Else
                  lAutAltera:= .T.
               EndIf
            Else
               lAutInclui:= .T.
            Endif
         ElseIf nOpcAuto == 5
            lAutDeleta:= .T.   //Flag para definir se o item será deletado
            lAutInclui:= .F.   //Flag para definir se o item será incluso
            lAutAltera:= .F.   //Flag para definir se o item será alterado
         Endif
      //Else
         //Return .F.
      //Endif
   Endif
   If(AvFlags("RATEIO_DESP_PO_PLI") .And. !lPOAuto, PO400RatFrSg(),)
   IF lSelecao //SEMPRE .T. 'PARA PADRAO - FOI COLOCADA PARA RDMAKE GRADIENTE

   IF lRdMake
      IF !ExecBlock("EICPPO02",.F.,.F.,"22")
         //IF MsgYesNo(STR0056,STR0057) //"Deseja Sair?"###"Confirmação de Saída"
            RETURN .F.
         //ELSE
         //   loop
         //ENDIF
      EndIf
   ENDIF

   IF lSolic
      If cProg#"PN"
         // CDS 15/9/04 -- No caso de Alteracao nao perguntar CC e SI --
         If (!Inclui.and.!lTroca .And. !lAutInclui)
            // --- Procurar o Primeiro que coincida ---
            SW3->(DbSetOrder(1))
            If SW3->(DBSeek(xFilial("SW3") + M->W2_PO_NUM))
               TCC := SW3->W3_CC
               TSI_NUM := SW3->W3_SI_NUM
               lFound:=.T.
            Endif
            If lFound
                //THTS - 03/08/2017
                If FindFunction("UPDX1PO400")           
                    UPDX1PO400()                    
                EndIf

   			   lValidCC:=PO_ValidCC(.f.)
		       lValidSI:=PO_ValidSI(.f.,!Inclui)   // GFP - 10/04/2013
			   PO_ValidCC(lValidCC)
	           PO_ValidSI(lValidSI)
	           //TDF - 19/10/2010 - Moeda do PO deve ser igual a da SI.
	           If !lMoeda
	              Return .F.
	           EndIf
            else
               MsgAlert(STR0300,STR0002)   //STR0300 - "Itens do Pedido nao encontrados."
               Return(.F.)
	        Endif
         Else

            If !lPOAuto

            SETKEY(VK_F4,{|| PO400HLPW0()})
            If(EasyEntryPoint("EICPO400"),lTelaSi := ExecBlock("EICPO400",.F.,.F.,"SelecionaSI"),)

               If ValType(lTelaSi) == "U" .or. lTelaSi //CCH - 25/08/2009 - Permite ser alterado por ponto de entrada evitando abertura da tela de seleção da S.I.
                  IF lNewTelaSI//JL
                     nOpca := FilPergunte()
                  ELSE

                     DEFINE MSDIALOG oDlg TITLE STR0051 From 9, 0 To 20, 75 OF oMainWnd //"Seleção de Itens"

                     oPanelSI:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165)
                     oPanelSI:Align:= CONTROL_ALIGN_ALLCLIENT

                     nLinha := 20

                     /* LDB 22/06/2006 */
                     If(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"TELA_SELECAO_SI"),)

                     @ nLinha,30 SAY STR0052 SIZE 90,08 PIXEL OF oPanelSI //"C.C."
                     @ nLinha+13,30 SAY cRecSTR SIZE 90,08 PIXEL OF oPanelSI //'S.I. N§'

                     @ nLinha,180 SAY STR0054 SIZE 25,08 OF oPanelSI PIXEL //'(F3-Help)'
                     @ nLinha+13,180 SAY STR0055 SIZE 25,08 OF oPanelSI PIXEL //'(F4-Help)'

                     @ nLinha,140 MSGET oGetCC VAR TCC F3 cFiltra PICTURE _PictCC ;
                             VALID (lValidCC:=PO_ValidCC(.f.)) PIXEL SIZE 40,08 OF oPanelSI HASBUTTON

                     @ nLinha+13,140 MSGET oGetSI VAR TSi_Num F3 "GETSI"     PICTURE _PictSI ;
                             VALID (lValidSI:= (Vazio() .Or. PO_ValidSI(.f.)) ) PIXEL SIZE 40,08 OF oPanelSI HASBUTTON
//                           VALID (If((lValidSI:=PO_ValidSI(lValidSI)),nOpca:=1, nOpca := 0)) SIZE 30,8 PIXEL OF oDlg
                     oGetSI:bF3 := {|| If(PO400HLPW0(),oGetSI:Refresh(),)}

                     nOpca:=0
//                   EnchoiceBar(oDlg,{||If(PO_ValidCC(lValidCC) .AND. PO_ValidSI(lValidSI),{|| nOpca:=1,oDlg:End()},{|| nOpca:=0})},;
                     ACTIVATE MSDIALOG oDlg ON INIT ;
                     EnchoiceBar(oDlg,{||If(PO_ValidCC(.f.) .AND. PO_ValidSI(.f.),Eval({|| oDlg:End(),nOpca:=1}),Eval({|| nOpca:=0}))},;
                                      {||nOpca:=0,oDlg:End()}) CENTERED
                     SETKEY(VK_F4,NIL)
                  ENDIF
               EndIf
               IF !lNewTelaSI//IGOR CHIBA 18/07/14 SE FOR NOVA TELA CONTINUAR MESMO SE CANCELAR O PERGUNTE
                  If nOpca = 0 .AND. !lTroca //DFS - 04/02/11 - Inclusão de tratamento para que ao clicar no botão troca SI da tela de seleção de itens e apertar X o sistema saia.
                  //IF MsgYesNo(STR0056,STR0057) //"Deseja Sair?"###"Confirmação de Saída"
                     RETURN .F.
                  //ELSE
                  //   LOOP
                  //ENDIF
                  ENDIF
               ENDIF

               lValidSI:=.F.
            Else

               If Len(aCabItem) >= i

                  If nOpcAuto == 3
                     If Select("TRB") > 0
                        TRB->(DbCloseArea())
                     EndIf
                  Endif

                  lAuto:= .F.
                  TCC:= ""
                  TSi_Num:= ""
                  aMsgs:= {}

                  //Valida se todos campos necessários para o ExecAuto vieram no array.
                  aMsgs:= ValExecAutoCpos(aCabItem[i])
                  If Len(aMsgs) > 0

                     If lNotPOErroAuto
                        lNotPOErroAuto:= .F.
                     Endif

                     For iMsg:= 1 to Len(aMsgs)
                        EasyHelp(aMsgs[iMsg],STR0002) //STR0002 "Aviso"
                     Next
                     If nOpcAuto == 3
                        TETempReopen(cNomeW1, "TRB")
                     Endif
                     i++
                     Loop

                  Endif

                  If (nPO_CC:= aScan(aCabItem[i], {|x|x[1] == "W3_CC"})) > 0
                     TCC:= aCabItem[i][nPO_CC][2]
                  Endif

                  If (nPO_SI:= aScan(aCabItem[i], {|x|x[1] == "W3_SI_NUM"})) > 0 .and. !Empty(aCabItem[i][nPO_SI][2])
                     TSi_Num:= aCabItem[i][nPO_SI][2]
                     If SW0->(FieldPos("W0_SIAUTO")) # 0
                        SW0->(DbSetOrder(1))
                        If SW0->(DbSeek(xFilial("SW0")+AvKey(TCC,"W0__CC")+AvKey(TSi_Num,"W0__NUM")))
                           If SW0->W0_SIAUTO == "1"
                              lAuto:= .T.
                           Endif
                        Endif
                     Endif
                  Else
                     lAuto:= .T.

                     If SW2->(FieldPos("W2_SIAUTO")) # 0
                        If Empty(M->W2_SIAUTO)
                           M->W2_SIAUTO := GetSXENum("SW0","W0__NUM")
                           ConfirmSX8()
                           SW0->(DbSetOrder(1))
                           While SW0->(DbSeek(xFilial("SW0")+AvKey(TCC,"W0__CC")+AvKey(M->W2_SIAUTO,"W0__NUM"))) //LRS - 22/09/2016
	                           M->W2_SIAUTO := GetSXENum("SW0","W0__NUM")
	                           ConfirmSX8()
                           EndDO
                        Endif


                        If nPO_SI == 0
                           aAdd(aCabItem[i],NIL)
                           nPO_SI := Len(aCabItem[i])
                        EndIf

                        aCabItem[i][nPO_SI] := {"W3_SI_NUM", M->W2_SIAUTO, Nil}
                     Endif

                  Endif

                  TSi_Num:= aCabItem[i][nPo_SI][2]
                  TCC    := aCabItem[i][nPO_CC][2]
                  
                  TCod_i:= ""
                  If (nPosCod_i := aScan(aCabItem[i], {|x| x[1] == "W3_COD_I" })) > 0
                     TCod_i:= AvKey(aCabItem[i][nPosCod_i][2], "W3_COD_I")
                  EndIf
                  
                  TW1_REG:= ""
                  If (nPOsReg := aScan(aCabItem[i], {|x| x[1] == "W3_REG" })) > 0
                     TW1_REG:= aCabItem[i][nPOsReg][2]
                  EndIf

                  If lAuto
                     lRet:= ExecAutoSI(nOpcAuto,lAutInclui,lAutAltera,lAutDeleta,aCabAuto,aCabItem,i)

                     If SW0->(FieldPos("W0_SIAUTO")) # 0
                        SW0->(DbSetOrder(1))
                        If SW0->(DbSeek(xFilial("SW0")+ Avkey(TCC,"W0__CC") + AvKey(TSi_Num,"W0__NUM"))) .AND. Empty(SW0->W0_SIAUTO)
                           Reclock("SW0",.F.)
                           SW0->W0_SIAUTO:= "1"
                           SW0->(MsUnlock())
                        Endif
                     Endif
                  Endif

                  If nOpcAuto == 3
                     TETempReopen(cNomeW1, "TRB")
                  Endif

                  If PO_ValidCC(.f.) .AND. PO_ValidSI(.f.)
                     nOpca := 1
                  Else
                     nOpca := 0
                     If lNotPOErroAuto
                        lNotPOErroAuto:= .F.
                     Endif
                     lRet:= .F.
                  Endif

                  If nOpca = 0
                     i++
                     loop
                  Endif
               Endif
            Endif

         Endif
      Else
         If lSai
            Return .F.
         EndIf
         lValidSI:=PO_ValidSI(lValidSI)
         lValidCC:=PO_ValidCC(lValidCC)
      EndIf
   ELSE
      IF EMPTY(TCC) .AND. EMPTY(TSi_Num)
         lSolic:=.T.
         LOOP
      ENDIF
   EndIf                //lSolic
ENDIF 				//lSeleccion

   lSelecao:=.T.
   DBSELECTAREA("Work")

   aSelItem:={}
   AADD(aSelItem,{"WKFLAGWIN"  ,"","  "})

   IF EasyEntryPoint("EICPPO02")
      ExecBlock("EICPPO02",.F.,.F.,"28")
   ENDIF

   //WFS 13/08/2014
   AAdd(aSelItem,{"WKSI_NUM", "", AvSx3("W1_SI_NUM", AV_TITULO)}) //Exibição da Ordem/ Número da S.I.
   AAdd(aSelItem,{"WKPOSIT", "", AvSx3("W1_POSIT"   ,AV_TITULO)})    //Posição Item(SI)   
   AADD(aSelItem,{"WKCOD_I"    ,"",STR0013,_PictItem}) //"Item"
   AADD(aSelItem,{"WKDESCR"    ,"",AVSX3("B1_DESC_"+cDESC_PO,AV_TITULO)}) //"Descri‡ao em ###"

   IF lRdMake
      ExecBlock("EICPPO02",.F.,.F.,"2")
   ENDIF

   IF lNec
      nExecute:="5"
      ExecBlock(cArqRdmake,.F.,.F.)
   ENDIF

   If cPaisLoc=="BRA"
      AADD(aSelItem,{{||IF(Work->WKFLUXO=='7',STR0015,STR0016)} ,"",STR0017}) //'Nao'###'Sim'###"Anuencia"
   EndIf

   IF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"10"),)//AWR 09/11/1999

   bQtde_LI := {||IF(Work->WKFLUXO=="1",TRANSFORM(Work->WKQTDE_LI,_PictQtde), STR0290 )} //'   Nao Anuente    '  //STR0290 = "Não Anuente"
   bQtde    := {|| TRAN(Work->WKQTDE,_PictQtde) }
   bQtde_Emb:= {|| IF(Work->WKFLUXO=="7",TRANSFORM(Work->WKQTDE_EMB,_PictQtde), STR0010 )} //'   Anuencia    '

   //WFS 13/08/2014
   AAdd(aSelItem,{"WKDT_EMB", "", AvSx3("W3_DT_EMB", AV_TITULO)}) //Exibição da data de embarque

   AADD(aSelItem,{"WKDT_ENTR"  ,"",STR0028}) //"Entrega"
   AADD(aSelItem,{"WKFABR"     ,"",STR0019}) //"Fabricante"

   IF EICLOJA()
      EICAddLoja(aSelItem, "W3_FABLOJ",, STR0019)
   ENDIF

   AADD(aSelItem,{"WKNOME_FAB" ,"",STR0059}) //"Nome"

   AADD(aSelItem,{bQtde   ,,AVSX3("W3_QTDE")[5]})

IF AvFlags("EIC_EAI")//AWF - 25/06/2014
   AADD(aSelItem,{"WKUNI"  ,,AVSX3("W3_UM",AV_TITULO)})
ELSE
   IF EICLOJA()
      AADD(aSelItem,{{||BUSCA_UM(Work->WKCOD_I+Work->WKFABR+Work->WKFORN,WORK->WKCC+WORK->WKSI_NUM,WORK->W3_FABLOJ,WORK->W3_FORLOJ)},,STR0060}) //"Unidade"
   ELSE
      AADD(aSelItem,{{||BUSCA_UM(Work->WKCOD_I+Work->WKFABR+Work->WKFORN,WORK->WKCC+WORK->WKSI_NUM,"","")},,STR0060}) //"Unidade"
   ENDIF
ENDIF

   IF AvFlags("EIC_EAI")//AWF - 25/06/2014
      AADD(aSelItem,{"WKQTSEGUM",,AVSX3("W3_QTSEGUM",AV_TITULO),AVSX3("W3_QTSEGUM",6) })
      AADD(aSelItem,{"WKSEGUM"  ,,AVSX3("W3_SEGUM",AV_TITULO) })
      AADD(aSelItem,{"WKFATOR"  ,,"Fator Conv 2UM",AVSX3("J5_COEF",6) })
      If SW0->(FieldPos("W0_REFER1")) > 0  //NCF - 26/09/2016
         AADD(aSelItem,{"WKREFER1",,AVSX3("W0_REFER1",AV_TITULO),AVSX3("W0_REFER1",6) })
      EndIf
   ENDIF

   IF cPaisLoc=="BRA"
      AADD(aSelItem,{bQtde_LI,,AVSX3("W3_QTD_LI")[5]})
   ENDIF
   If SW3->(FieldPos("W3_PESOL")) # 0 //CCH - 07/08/09 - Gravação do novo campo de Peso Líquido Unitário
      AADD(aSelItem,{"WKPESOL",,AVSX3("W3_PESOL",5),AVSX3("W3_PESOL",6)})
   EndIf
   AADD(aSelItem,{"WKQTDE_EMB",,STR0023,_PictQtde}) //"Qtde Embarcada"
// AADD(aSelItem,{bQtde_Emb ,,STR0023}) //"Qtde Embarcada"
// AADD(aSelItem,{"WKQTDE_EMB",,AVSX3("W3_QTD_EMB")[5],AVSX3("W3_QTD_EMB",6)})
   AADD(aSelItem,{"WKSALDO_Q"  ,"",STR0024,_PictQtde})  //"Saldo Qtde" //ASK 28/03/04
// AADD(aSelItem,{{|| PO400Saldo() },,STR0024,_PictQtde}) //"Saldo Qtde" - AWR 19/04/04
   AADD(aSelItem,{"WKSEM_PO" ,,AVSX3("W3_SEM_PED")[5],AVSX3("W3_SEM_PED",6)})

   IF lExiste_Midia .AND. !EMPTY(M->W2_VLMIDIA)//AWR 21/10/1999
      AADD(aSelItem,{"WK_QTMIDIA",,AVSX3("B1_QTMIDIA",5),AVSX3("B1_QTMIDIA",6)})
      AADD(aSelItem,{"WK_VLTOTMI",,STR0021,AVSX3("W2_VLMIDIA",6)}) //"Vlr. Total Midia"
   ENDIF

   IF ! EMPTY(SW0->W0_SIKIT)
      AADD(aSelItem,{"WKKIT"  ,"" ,"Kit"  ,_PictItem})
      AADD(aSelItem,{"WKSERIE","" ,"Serie"})
//      AADD(aSelItem,{"WKQTDKIT","","Qtde.Kit",'@E 999,999.99'})
      AADD(aSelItem,{"WKQTDKIT","",AVSX3("W0_QTDE",5),AVSX3("W0_QTDE",6)})//ASR 15/12/2005 - BUSCA DO DICIONARIO
   ENDIF

   If lForeCast
      AADD(aSelItem,{{||IF(WORK->WK_FORECAS=="S",STR0029,STR0030)},,STR0031}) //CAF 22/10/98 //"Sim"###"Nao"###"Forecast"
   Endif
   IF(lSeal,ExecBlock("IC193PO1",.F.,.F.,"4"),) //AWR 01/10/1999
   AADD(aSelItem,{{||SX5->(dbSeek(xFilial()+"Y2"+Work->WK_REG_TRI)),AllTrim(X5DESCRI())},,AVSX3("W3_REG_TRI")[5]})
   AADD(aSelItem,{"WK_REG_MIN","" ,STR0032}) //"Registro no Minist‚rio / OrgÆo P£blico"
   AADD(aSelItem,{"WK_TEC"   ,,AVSX3("W3_TEC"   )[5]})
   AADD(aSelItem,{"WK_EX_NCM",,AVSX3("W3_EX_NCM")[5]})
   AADD(aSelItem,{"WK_EX_NBM",,AVSX3("W3_EX_NBM")[5]})
   IF cPaisLoc # "BRA"  .AND. SW1->(FIELDPOS("W1_NATUREZ")) # 0
      AADD(aSelItem,{"WKNATUREZA",,AVSX3("W1_NATUREZ",5)})
   ENDIF

   If SW3->(FieldPos("W3_PART_N")) # 0 //ASK 02/10/2007
      AADD(aSelItem,{"WKPART_N",,AVSX3("W3_PART_N")[5]})
   EndIf

   //TRP- 01/06/09 - Campo Software para novo Tratamento de Mídia e Software
   If SW3->(FieldPos("W3_SOFTWAR")) # 0 .And. EasyGParam("MV_CONSOFT",, "N") $ cSim
      AADD(aSelItem,{{||IF(Work->WKSOFTWAR=='2',STR0015,STR0016)},,AVSX3("W3_SOFTWAR",5)})
   Endif

   If lCpoCtCust
      AADD(aSelItem,{"WKCTCUSTO",,AVSX3("W3_CTCUSTO",5)})
   EndIf
   If lPesoBruto                                         //NCF - 25/08/2011 - Campo do Peso Bruto Unitário
      AADD(aSelItem,{"WKPSBRUTO",,AVSX3("W3_PESO_BR",5),AVSX3("W3_PESO_BR",6)})
   EndIf
   If AvFlags("RATEIO_DESP_PO_PLI")
      AADD(aSelItem,{"WKFRETE",,AVSX3("W3_FRETE",5)  ,AVSX3("W3_FRETE",6)})
      AADD(aSelItem,{"WKSEGUR",,AVSX3("W3_SEGURO",5) ,AVSX3("W3_SEGURO",6)})
      AADD(aSelItem,{"WKINLAN",,AVSX3("W3_INLAND",5) ,AVSX3("W3_INLAND",6)})
      AADD(aSelItem,{"WKDESCO",,AVSX3("W3_DESCONT",5),AVSX3("W3_DESCONT",6)})
      AADD(aSelItem,{"WKPACKI",,AVSX3("W3_PACKING",5),AVSX3("W3_PACKING",6)})
      If SW3->(FieldPos("W3_OUT_DES")) > 0
         AADD(aSelItem,{"WKOUTDE",,AVSX3("W3_OUT_DES",5),AVSX3("W3_OUT_DES",6)})
      EndIf
   EndIf
   //AOM - 07/04/2011
   If lOperacaoEsp
      AADD(aSelItem,{"W3_CODOPE","",AVSX3("W3_CODOPE",5)})
      AADD(aSelItem,{"W3_DESOPE","",AVSX3("W3_DESOPE",5)})
   EndIf

   aADD(aSelItem,{"WKCC","",AVSX3("W0__CC",5)})
   aADD(aSelItem,{"WKPOSICAO","",AVSX3("W3_POSICAO",5)})
   aADD(aSelItem,{"WKSI_ORI","",AVSX3("W3_SI_NUM",5)})

   IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"BROWSE_INCLUIR_ALTERAR"),)

   //RMD - 12/09/13 - Não desposicionar a Work. A customização não pode ter desposicionado a tabela.
   /*
   Work->(DbSetOrder(1))
   Work->(DBSEEK(AvKey(TCC,"W0__CC") + AvKey(TSi_Num,"W0__NUM")))   // GFP - 23/08/2013
   */

   nRecno:=0
   nOrder:=1
   bOk := {|| IF(PO400VALPO(),(Work->(dbSetOrder(nOrder)),nOpcao:=1,if(P_Te_4()==0,oDlg:End(),nOpcao:=0),Work->(dbSetOrder(nOrder))), Alert(STR0278)) } // DFS - Mensagem se tentar salvar P.O sem item - STR0278 "Não é possível salvar o P.O. sem item"
   bCancel := {|| MControla := .F.,oDlg:End() }

   IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"ANTES_TELA_ITEM"),)

   //TRP-14/05/07
   //aOrd := SaveOrd("SX3",1)
   //SX3->(dbSeek("SW3"))

   //While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SW3"
      //If SX3->X3_PROPRI=="U" .AND. Ascan(aSelItem, {|x| AllTrim(x[1]) == AllTrim(SX3->X3_CAMPO)})==0 .AND. X3Uso(SX3->X3_USADO)
         //aAdd(aSelItem,{SX3->X3_CAMPO,"",AVSX3(SX3->X3_CAMPO,AV_TITULO),AVSX3(SX3->X3_CAMPO,AV_PICTURE)})
      //EndIF
      //SX3->(dbSkip())
   //Enddo
   //RestOrd(aOrd)

   aSelItem:= AddCpoUser(aSelItem,"SW3","2")

   WHILE .T.
      If !lPOAuto
      DBSELECTAREA("Work")

      nOrder := 1 //IF(lSiCopia,3,1)
      nOpcao := 0
      IF lRdMake
         ExecBlock("EICPPO02",.F.,.F.,"3")
      ENDIF

      IF lNec
         nExecute:="6"
         ExecBlock(cArqRdmake,.F.,.F.)
      ENDIF

      Work->(DBSETORDER(nOrder))

      If !lPOAuto  // GFP - 26/08/2013
         oMainWnd:ReadClientCoords()
      EndIf

      DEFINE MSDIALOG oDlg TITLE STR0061; //"Sele‡Æo de Itens"
         FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;
         OF oMainWnd PIXEL

      lFiltSi:=.T.  // S.A.M  --- .T. -> Padrao
                    //            .F. -> Opcao para Intervalos de SI - GRADIENTE

      IF lRdmake
         lFiltSi:=ExecBlock("EICPPO02",.F.,.F.,"SEMFILTRO")
      ENDIF

      If EasyEntryPoint("EICPO400")
         ExecBlock("EICPO400",.F.,.F.,"FILTRA_SI")
      EndIf

      lFiltSi:=IF(lNewTelaSI,.F.,.T.)  // S.A.M  --- .T. -> Padrao   //JL
                    //            .F. -> Opcao para Intervalos de SI - GRADIENTE
      //DFS - 31/01/13 - Inclusão de GoTop para os itens
      Work->(dbGoTop())
      IF lFiltSi
         oMarkPTE2:= MsSelect():New("Work","WKFLAGWIN",,aSelItem,@lInverte,@cMarca,;
                 {35,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2},;
                 "PO400FilCCSI","PO400FilCCSI")
      ELSE
         //DFS - 31/01/13 - Retirado DbGoTop visto que, foi colocado fora do Else
         //WORK->(DBGOTOP())
         IF !(lNewTelaSI)//JL
            oMarkPTE2:= MsSelect():New("Work","WKFLAGWIN",,aSelItem,@lInverte,@cMarca,;
                 {35,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2},,)
         ELSE

            //Pesquisa
            AAdd(aSeek, {AvSx3("W3_CC", AV_TITULO)+ " + " + AvSx3("W3_SI_NUM", AV_TITULO) + " + " + AvSx3("W3_COD_I", AV_TITULO) + " + " + AvSx3("W3_REG", AV_TITULO) + " + " + AvSx3("W1_POSIT", AV_TITULO),;
            	                 {{"", AvSx3("W3_CC", AV_TIPO)     , AvSx3("W3_CC", AV_TAMANHO)     , AvSx3("W3_CC", AV_DECIMAL)     , AvSx3("W3_CC", AV_TITULO)},;
                               {"", AvSx3("W3_SI_NUM", AV_TIPO) , AvSx3("W3_SI_NUM", AV_TAMANHO) , AvSx3("W3_SI_NUM", AV_DECIMAL) , AvSx3("W3_SI_NUM", AV_TITULO)},;
                               {"", AvSx3("W3_COD_I", AV_TIPO)  , AvSx3("W3_COD_I", AV_TAMANHO)  , AvSx3("W3_COD_I", AV_DECIMAL)  , AvSx3("W3_COD_I", AV_TITULO)},;
                               {"", AvSx3("W3_REG", AV_TIPO)    , AvSx3("W3_REG", AV_TAMANHO)    , AvSx3("W3_REG", AV_DECIMAL)    , AvSx3("W3_REG", AV_TITULO)},;
                               {"", AvSx3("W1_POSIT", AV_TIPO)  , AvSx3("W1_POSIT", AV_TAMANHO)  , AvSx3("W1_POSIT", AV_DECIMAL)  , AvSx3("W1_POSIT", AV_TITULO)}}, 1})


            AAdd(aSeek, {AvSx3("W3_POSICAO", AV_TITULO) + " + Registro",;
            	                 {{"", AvSx3("W3_POSICAO", AV_TIPO), AvSx3("W3_POSICAO", AV_TAMANHO), AvSx3("W3_POSICAO", AV_DECIMAL), AvSx3("W3_POSICAO", AV_TITULO)},;
                               {"", AvSx3("W3_POSICAO", AV_TIPO), AvSx3("W3_POSICAO", AV_TAMANHO), AvSx3("W3_POSICAO", AV_DECIMAL), "Registro"}}, 2})

            AAdd(aSeek, {AvSx3("W3_CC", AV_TITULO) + " + " + AvSx3("W3_SI_NUM", AV_TITULO) + " + Orig.",;
                                {{"", AvSx3("W3_CC", AV_TIPO)     , AvSx3("W3_CC", AV_TAMANHO)     , AvSx3("W3_CC", AV_DECIMAL)     , AvSx3("W3_CC", AV_TITULO)},;
                               {"", AvSx3("W3_SI_NUM", AV_TIPO) , AvSx3("W3_SI_NUM", AV_TAMANHO) , AvSx3("W3_SI_NUM", AV_DECIMAL) , AvSx3("W3_SI_NUM", AV_TITULO)+"Orig."}}, 3})


            //Filtro
            AAdd(aFilter, {"WKSI_NUM"   , AvSx3("W3_SI_NUM"   ,AV_TITULO), AvSx3("W3_SI_NUM"   ,AV_TIPO)     , AvSx3("W3_SI_NUM"   ,AV_TAMANHO)     , AvSx3("W3_SI_NUM"   ,AV_DECIMAL), AvSx3("W3_SI_NUM"   ,AV_PICTURE)})
            AAdd(aFilter, {"WKCOD_I"   , AvSx3("W3_COD_I"   ,AV_TITULO), AvSx3("W3_COD_I"   ,AV_TIPO)     , AvSx3("W3_COD_I"   ,AV_TAMANHO)     , AvSx3("W3_COD_I"   ,AV_DECIMAL), AvSx3("W3_COD_I"   ,AV_PICTURE)})
            AAdd(aFilter, {"WKFORN"   , AvSx3("W3_FORN"   ,AV_TITULO), AvSx3("W3_FORN"   ,AV_TIPO)     , AvSx3("W3_FORN"   ,AV_TAMANHO)     , AvSx3("W3_FORN"   ,AV_DECIMAL), AvSx3("W3_FORN"   ,AV_PICTURE)})
            AAdd(aFilter, {"WKPOSIT"   , AvSx3("W1_POSIT"   ,AV_TITULO), AvSx3("W1_POSIT"   ,AV_TIPO)     , AvSx3("W1_POSIT"   ,AV_TAMANHO)     , AvSx3("W1_POSIT"   ,AV_DECIMAL), AvSx3("W1_POSIT"   ,AV_PICTURE)})

            DEFINE FWBROWSE oBrowse DATA TABLE ALIAS "WORK" OF oDlg//JL

               ADD MARKCOLUMN oColumn DATA { || If(EMPTY(Work->WKFLAGWIN), 'LBNO', 'LBOK') } DOUBLECLICK bMarca /*HEADERCLICK bMarcaTodos */OF oBrowse

               AddColumns(aSelItem, "WORK", {"WKFLAGWIN"}, oBrowse)
               
               /* pesquisa */
               oBrowse:SetSeek(, aSeek)

               /* filtro */
               oBrowse:lDbfFilter:= .T.
               oBrowse:SetUseFilter()
               oBrowse:SetFieldFilter(aFilter)

               //oBrowse:SetFilter("EE8_FILIAL+EE8_PEDIDO", xFilial("EE8")+EE7->EE7_PEDIDO, xFilial("EE8")+EE7->EE7_PEDIDO)
               oBrowse:refresh()
            ACTIVATE FWBROWSE oBrowse
            oDlg:lMaximized := .T.

         ENDIF

      ENDIF
      IF !lNewTelaSI//JL
         oMarkPTE2:bAval := {|x| x:=Work->(RecNo()),Work->(DBSETORDER(1)),;
                         P_Te_3(), Work->(dbSetOrder(nOrder)), Work->(dbGoTo(x)), oMarkPTE2:oBrowse:Refresh() }  //CDS 15/09/04
         @01.5,01 MSPANEL oPanel PROMPT "" SIZE 01,20 OF oDlg  //LRL 19/03/04 - Painel para alinhamento MDI
         IF lNec
            @ 018,192 BUTTON STR0062 SIZE 38,11 ACTION (nExecute:="12",; //"Pesquisa/P.N."
                                                        IF(ExecBlock(cArqRdmake,.F.,.F.),;
                                                          (nOpcao:=6,oDlg:End()),)) OF oDlg PIXEL
         ENDIF

         @ 07,005 SAY _LIT_R_CC PIXEL  SIZE 20,08 OF oPanel
         @ 07,096 SAY STR0065 PIXEL SIZE 20,08 OF oPanel //'S.I. N§ '

         @ 05,032 MSGET TCC WHEN .F. PICTURE _PictCC  SIZE 30,8 OF oPanel PIXEL
         @ 05,128 MSGET TSi_Num PICTURE _PictSI WHEN .F. SIZE 35,8 OF oPanel PIXEL


         IF nRecno <> 0
            Work->(DBGOTO(nRecno))// depois do MsSelect por causa do filtro
            nRecno:=0
         ENDIF

         IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"ANTES_GET_SI"),) // SVG - 06/07/2010 -

         If aScan(aButtons,{|x|x[3] == STR0379 }) == 0
            If !INCLUI 
               aAdd(aOrdens,{,{|| PO400OrdenaItens(1,nOpcAux), oMarkPTE2:oBrowse }, STR0427 , STR0427 }) //"Posição (PO)"
            EndIf
            aAdd(aOrdens,{,{|| PO400OrdenaItens(2,nOpcAux), oMarkPTE2:oBrowse:Refresh() }, STR0428, STR0428 }) //"Unidade Requisitante + Solicitação de Importação + Produto"
            aAdd(aOrdens,{,{|| PO400OrdenaItens(3,nOpcAux), oMarkPTE2:oBrowse:Refresh() }, STR0429, STR0429 }) //"Unidade Requisitante + Solicitação de Importação + Sequencia SI"
            aAdd(aButtons,{/*<Resource (Depreciado)>*/,/*<Action>*/, STR0379,STR0379,,,aOrdens} )
         EndIf

	     oPanel:Align:=CONTROL_ALIGN_TOP
	     oMarkPTE2:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
	     oMarkPTE2:oBrowse:Refresh() //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
      ENDIF

      ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk,bCancel,,aButtons)) //LRL 19/03/04 - Alinhamento MDI //JL

      IF lRdMake
         ExecBlock("EICPPO02",.F.,.F.,"4")
      ENDIF

      nOpcPonto := nOpcao //LRS - 11/08/2015
      IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"APOS_GET_SI"),)	//JWJ 15/08/2005 - Chamado 016419

      IF nOpcao = 6
         nRecno:=Work->(RECNO())//Para posicionar no registro DEPOIS DO FILTRO
         LOOP
      ElseIF nOpcao = 0
         IF cProg = "PN"//ASR 15/10/2005
            MControla := .T.
            MControle := .T.
            lSai:=.F.//ASR 15/10/2005
            //IF MsgYesNo(STR0056,STR0057) //"Deseja Sair?"###"Confirmação de Saída"
               lSai:=.T.//ASR 15/10/2005
               RETURN .F.
            //ENDIF
         ELSE
            //IF MsgYesNo(STR0056,STR0057) //"Deseja Sair?"###"Confirmação de Saída"
               RETURN .F.//ASR 17/10/2005 - EXIT
            //ELSE
            //   LOOP
            //ENDIF
         ENDIF
      ENDIF

      Else

         If Len(aCabItem) >= i
            //wfs abr/2017 - tratativa de erro na geração automática do P.O. a partir da S.I.
            lRet:= MarkItemAuto(nOpcAuto,lAutInclui,lAutAltera,lAutDeleta,aCabItem[i])
            If lNotPOErroAuto
               lNotPOErroAuto:= lRet
            Endif

         Endif


         If i > Len(aCabItem)
            If P_Te_4() == 0
               nOpcao := 1
            Else
               nOpcao := 0
               lRet:= .F.
            Endif
            MControla:= .F.
         //Else
           // i++
           // LOOP
         EndIf

      Endif

     EXIT
   ENDDO

   If lPOAuto

      //wfs abr/2017 - tratativa de erro na geração automática do P.O. a partir da S.I.
      If !lNotPOErroAuto
         lRet:= .F.
         Exit
      EndIf

      If Len(aCabItem) >= i
         i++
         Loop
      Endif
   Endif

   IF nOpcao = 99//ASR 17/10/2005
      LOOP
   ENDIF

   IF nOpcao = 0 .AND. cProg = "PN" .AND. ! lSai
      LOOP
   EndIf

   TCc     := SPACE(nLenCC)   //SO0026 FCD OS.:0243/02
   TSi_Num := SPACE(nLenSi)   //SO0026 FCD OS.:0243/02

   IF nOpcao <> 1 .AND. MControle = .F.
      MControla:= .F.
      RETURN .F.
   ENDIF

   IF MControla = .F.
      MControla:= .T.
      RETURN .T.
   ENDIF
ENDDO

Return lRet

Static Function AddColumns(aColumns, cAlias, aRemove, oBrowse)
Local nInc
Local aStruct := (cAlias)->(DbStruct())
Local aBrowse := {}
Local cColumn, bBlock, cType, nSize, nDec, cTitle, cPicture, nAlign

	/* Array da coluna
	[n][01] Título da coluna
	[n][02] Code-Block de carga dos dados
	[n][03] Tipo de dados
	[n][04] Máscara
	[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	[n][06] Tamanho
	[n][07] Decimal
	[n][08] Indica se permite a edição
	[n][09] Code-Block de validação da coluna após a edição
	[n][10] Indica se exibe imagem
	[n][11] Code-Block de execução do duplo clique
	[n][12] Variável a ser utilizada na edição (ReadVar)
	[n][13] Code-Block de execução do clique no header
	[n][14] Indica se a coluna está deletada
	[n][15] Indica se a coluna será exibida nos detalhes do Browse
	[n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
	*/
   For nInc := 1 To Len(aColumns)
      If ValType(aColumns[nInc][1]) == "C"
         If aScan(aRemove, aColumns[nInc][1]) > 0 .Or. aScan(aStruct, {|x| x[1] == aColumns[nInc][1]}) == 0
            Loop
         EndIf
         cColumn := aColumns[nInc][1]
         bBlock := &("{ ||" + cColumn + " }")
         cType := aStruct[aScan(aStruct, {|x| x[1] == cColumn })][2]
         nSize := aStruct[aScan(aStruct, {|x| x[1] == cColumn })][3]
         nDec := aStruct[aScan(aStruct, {|x| x[1] == cColumn })][4]
      ElseIf ValType(aColumns[nInc][1]) == "B"
         cColumn := Nil
         bBlock := aColumns[nInc][1]
         cType := ValType((cAlias)->(Eval(aColumns[nInc][1])))
         nSize := Len((cAlias)->(Eval(aColumns[nInc][1])))
         nDec := If(ValType((cAlias)->(Eval(aColumns[nInc][1])))=="N", 2, Nil)
      EndIf
      cTitle := aColumns[nInc][3]
      cPicture := If(Len(aColumns[nInc]) > 3, aColumns[nInc][4],)
      nAlign := If(cType<>"N", 1, 2)
      aAdd(aBrowse, {cTitle,bBlock,cType,cPicture,nAlign,nSize,nDec,.F.,{||.T.},.F.,{||.T.}, cColumn, {||.T.},.F.,.F.,{}})
   Next
   oBrowse:SetColumns(aBrowse)
Return Nil

*----------------------------------------------------------------------------
FUNCTION PO400FilCCSI
*----------------------------------------------------------------------------
RETURN  (TCC+TSi_Num/*IF(lSiCopia,cSiOri,TSi_Num)*/)
 


*----------------------------------------------------------------------------
FUNCTION P_Te_3(aItemAux)
*----------------------------------------------------------------------------
LOCAL oDlg, nOpcA:=0, lValid:=.T.,nAnuencia, oRadio , i , lRet , nPos, aOrdSW5, j

/*
LOCAL aValid:={'Fabr','Anuente','Porta','Saldo_Q','VlUnit','DtEmbarque',;//'DtEntrega',;
               'Fbr1','Fbr2','Fbr3','Fbr4','Fbr5','CLICK_OK_REG_TRI','TEC3'}
*/
LOCAL bValid:={||lValid:=.T.,;
                 AEVAL(aValid,{|campo|If(lValid,lValid:=PO420Val(campo,"OK"),)}),;
                 lValid }  // lValid

//LOCAL cArqF3:="W13", cCampoF3:="A5_FABR"
//LOCAL oCbx, oGetReg_Min, oGetEmbarcado, oGetCusto, nCusto, cEmbarcado
LOCAL _PictItem := ALLTRIM(X3PICTURE("B1_COD"))
//Local oCombo, cAux
//Local aItensCbo := {STR0029,STR0030} //"Sim"###"Nao"
LOCAL lPoEmbarc:=.F.
LOCAL nIndice,nRecno,nSldSemPed
LOCAL nOrdW5, nRecW5
LOCAL aFields

PRIVATE aMostraCpos:={"W3_COD_I","W3_FABR","W3_FAB_DES","W3_REG_TRI","W3_SALDO_Q","W3_REG_MIN","W3_QTD_EMB",;
                      "W3_PRECO","W3_CUSTO","W3_TEC","W3_EX_NBM","W3_EX_NCM","W3_FABR_01","W3_FABR_02","W3_FABR_03",;
                      "W3_FABR_04","W3_FABR_05","W3_QTDE","W3_SEM_PED","W3_REG_DES"}
PRIVATE lAnuencia:=cPaisLoc=="BRA", lWhen:=.T. // USADO NO RDMAKE ICPADPO1 -PARA HABILITAR OU NAO OS BOTOES
//PRIVATE nL1,nL2,nL3,nL4,nL5,nL6,nL7,nL8,nL9,nL10,nC1,nC2,nC3,nC4,nC5,nC6,nC7,cNomeFabr
nInland:=nPacking:=nOut_Des:=nDescont:=0
PRIVATE oEnchDItem
Private lReturn := .F.
Private aValid:={'Fabr','Anuente','Porta','Saldo_Q','VlUnit','DtEmbarque',;//'DtEntrega',;
                 'Fbr1','Fbr2','Fbr3','Fbr4','Fbr5','CLICK_OK_REG_TRI','TEC3','W3_TEC','W3_PESOL'/*ACB - 25/02/2011*/} // By JPP - 07/12/2007 - 09:30
Private cFabrIt_Old, cLjFabrIt,cPO_Num_It // By JPP - 28/02/2008 - 15:20
Private aCposAltera  // TLM 13/03/2008
Private aButtonsIt := {} //ACB - 06/04/2010
Private aTela[0][0],aGets[0] //JVR - 28/05/09
Private lPermiteDesm := .F. // SVG - 16/08/2011 -
Private lAltPOPost := .T. //LRS - 22/08/2016 - Parametro para nao entrar na validacao de desmarcar item po,quando o mesmo encontra-se em fase posterior.
SWB->(dbSetOrder(1))
EICAddLoja(aMostraCpos, "W3_FABLOJ", Nil, "W3_FABR")
EICAddLoja(aMostraCpos, "W3_FAB1LOJ", Nil, "W3_FABR_01")
EICAddLoja(aMostraCpos, "W3_FAB2LOJ", Nil, "W3_FABR_02")
EICAddLoja(aMostraCpos, "W3_FAB3LOJ", Nil, "W3_FABR_03")
EICAddLoja(aMostraCpos, "W3_FAB4LOJ", Nil, "W3_FABR_04")
EICAddLoja(aMostraCpos, "W3_FAB5LOJ", Nil, "W3_FABR_05")


If SW3->(FieldPos("W3_PESOL")) # 0 //CCH - 07/08/09 - Gravação do novo campo de Peso Líquido Unitário
   Aadd(aMostraCpos,"W3_PESOL")
EndIf

// ** PLB 06/08/07 - Referente tratamento de Incoterm, Frete e Regime de Tributação na LI (ver chamado 054617)
If SW4->( FieldPos("W4_REG_TRI") ) > 0
   Do While ( nPos := AScan( aMostraCpos, { |x| x $ "W3_REG_TRI---W3_REG_DES" } ) ) > 0
      ADel( aMostraCpos, nPos )
      ASize( aMostraCpos, Len(aMostraCpos)-1 )
   EndDo
EndIf
// **

IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"ALTERA_PO_POST"),) //LRS - 22/08/2016

IF lAltPOPost
   If Work->WKFLAG  // GFP - 15/10/2015 - Trava para não permitir desmarcar um item no PO, quando o mesmo encontra-se em fase posterior.
	   aOrdSW5 := SaveOrd("SW5")
	   SW5->( dbSetOrder(3) )
	   SW5->(DbSeek(xFilial("SW5")+AvKey(Work->WKPO_NUM,"W5_PO_NUM")+AvKey(Work->WKCOD_I,"W5_COD_I")))
	   Do While !SW5->(EOF()) .AND. SW5->W5_PO_NUM == AvKey(Work->WKPO_NUM,"W5_PO_NUM") .AND. SW5->W5_FILIAL == xFilial("SW5")
	      IF SW5->W5_POSICAO == Work->WKPOSICAO .AND. SW5->W5_FLUXO <> "7"
	         EasyHelp(STR0408,STR0002)  // "Não é possivel desmarcar o item, pois o mesmo encontra-se em fase de Pedido de Licença de Importação (PLI)." ## "Aviso"
	         RestOrd(aOrdSW5,.T.)
             Return .F.
	      ENDIF
	      SW5->(DBSKIP())
	   EndDo
	   RestOrd(aOrdSW5,.T.)
	EndIf
EndIF

DBSELECTAREA("Work")

Work->WK_ALTEROU := .T.
lPermiteDesm := .F.
IF( EasyEntryPoint("EICPO400"), ExecBlock("EICPO400",.F.,.F.,"INICIA_TE_3"), )

//ER - 21/05/2007 - A variável lReturn pode ter seu valor alterado pelo ponto de Entrada.
If lReturn
   Return
EndIf

/*Quando integração via EAI, não permitir a seleção do item antes que ocorra a integração
do relacionamento produto x fornecedor, devido à informação da segunda unidade de medida.*/
If AvFlags("EIC_EAI")

   SA5->(DBSetOrder(2)) //A5_FILIAL+A5_PRODUTO+A5_FORNECE+A5_LOJA
   If !SA5->(DBSeek(xFilial() + Work->WKCOD_I + M->W2_FORN + EICRetLoja("M", "W2_FORLOJ")))
      EasyHelp(STR0394, STR0037) //"Esse item não pode ser marcado pois não possui a amarração entre o Produto e o Fornecedor escolhido para o processo." //wfs abr/2017 - tratativa de erro na geração automática do P.O. a partir da S.I. 
      Return .F.
   ElseIf Empty(SA5->A5_UNID)
      EasyHelp(STR0395, STR0037) //"Esse item não pode ser marcado pois a unidade de medida da amarração entre o Produto e o Fornecedor não foi informada." //wfs abr/2017 - tratativa de erro na geração automática do P.O. a partir da S.I.
      Return .F.
   EndIf

EndIf

If SW3->(FIELDPOS("W3_SLD_ELI")) # 0
   If Work->WKSLD_ELI > 0
      EasyHelp(STR0301)  //STR0301 = "Item não pode ser alterado, pois seu saldo foi eliminado."
      Return .F. //wfs abr/2017 - tratativa de erro na geração automática do P.O. a partir da S.I.
   EndIf
EndIf
//   //MFR 13/09/2021 OSSME-6182
// ÍNDICE EW5_FILIAL+EW5_PO_NUM+EW5_POSICA+EW5_INVOIC+EW5_FORN+EW5_FORLOJ
nOrdW5 := SW5->(IndexOrd())
nRecW5 := SW5->(Recno())
EW5->(DbSetOrder(2))
if  (Work->WKFLAG .And. EW5->(dbSeek(xFilial("EW5")+Work->WKPO_NUM + Work->WKPOSICAO)))    
    EasyHelp(STR0431,STR0002,STR0432) //"Item não pode ser desmarcado porque já possui invoice antecipada" "Exclua o item da invoice antecipada antes de excluir do Purchase Order"
    Return .F.
EndIf
SW5->(DbSetOrder(nOrdW5))
SW5->(DbGoTo(nRecW5))

//Desmarcar
//IF (!AvFlags("EIC_EAI") .OR. M->W2_CONTR == "2") .AND. ((lPermiteDesm .and. Work->WKFLAG) .or. (Work->WKFLAG .AND. !lPOdaIntegracao .AND. cProg # "PN" .And. Work->WKQTDE_EMB == 0 .And. !SWB->(dbSeek(xFilial("SWB")+M->W2_PO_NUM))))//DRL, 18/06/09, 15:55 - Impossibilitar desmarcar um Item que possua alguma quantidade embarcada. SVG - Ou quando tiver cambio ja lançado //wfs
IF (lPermiteDesm .and. Work->WKFLAG) .or. (Work->WKFLAG .AND. !lPOdaIntegracao .AND. cProg # "PN" .And. Work->WKQTDE_EMB == 0  /* .And. !SWB->(dbSeek(xFilial("SWB")+M->W2_PO_NUM))*/) //MFR 09/09/2021 OSSME-6168  //DRL, 18/06/09, 15:55 - Impossibilitar desmarcar um Item que possua alguma quantidade embarcada. SVG - Ou quando tiver cambio ja lançado
   //AOM - 09/04/2011 - Chamar o objeto de OPE ESP
   If !ValidOpePO("DESMARCA_IT_PO")
      Return .F.
   EndIf

   MTotal   -= VAL(STR(Work->WKPRECO * Work->WKQTDE,15,2))
   MFob_Abs -= VAL(STR(Work->WKPRECO * Work->WKQTDE,15,2))
   Work->WKSALDO_Q  := 0//Work->WKSALDO_O

   If !lCopiaPO
      If Work->WKFLUXO=="1" .AND. Work->WKQTDE_LI > 0 //FDR - 28/05/2013 // AWR 15/04/2004
         Work->WKQTDE := Work->WKQTDE_LI
      EndIf

      Work->WKSEM_PO  := (POSALDO_W1()-Work->WKQTDE)   // AWR 15/04/2004
   Else
      Work->WKSEM_PO  += Work->WKQTDE
      Work->WKQTDE    := Work->WKSEM_PO                // NCF - 28/05/2021 - Quando desmarcado o item, voltar ao saldo que estava quando foi carregado o item na tela para marcação.
   EndIf

	if !Work->WKDTENTR_S = ctod(" / /    ") //wReliquias  499390 MTRADE-288 e MTRADE-291 - Botão "Altera datas" no PO permitir informar data a todos os itens
   		Work->WKDT_ENTR   := Work->WKDTENTR_S
   endIf
   Work->WKFABR      := Work->WKFABR_O
   Work->WKFORN      := Work->WKFORN_O
   If EICLoja()
      Work->W3_FABLOJ := Work->W3_FABL_O
      Work->W3_FORLOJ := Work->W3_FORL_O
   EndIf
   //Work->WKNOME_FAB  := SPACE(15)
   //Work->WKNOME_FOR  := SPACE(15)
   //Work->WKFLAG      := .F.
   //Work->WKFLAGWIN   := SPACE(nLenOk)   //SO0026 FCD OS.:0243/02

   // *** GFP - 03/02/2011 :: 14:25 - Verificação de Regime de Tributação vinculado ao item
   /*If Empty(Work->WKGRUPORT)
      Work->WKNOME_FAB  := SPACE(15)
      Work->WKNOME_FOR  := SPACE(15)
      Work->WKFLAG      := .F.
      Work->WKFLAGWIN   := SPACE(nLenOk)   //SO0026 FCD OS.:0243/02
   Else
      MsgAlert("Item possui Regime de Tributação vinculado." + Replicate(ENTER,3) +;
               "Exclua a vinculação antes de desmarcar o item","Atenção!")
   EndIf*/
   // *** Fim GFP

   // BAK - 26/04/2011 - Utilizou-se a variavel lRegTriPO com o objetivo de verificar se o campo WKGRUPORT existe,
   //                    como tambem foi alterado o If para que possa marca ou desmarcar o item (WKFLAG)
   If lRegTriPO .And. !Empty(Work->WKGRUPORT)
      MsgAlert(STR0327 + Replicate(ENTER,3) +; //STR0327 "Item possui Regime de Tributação vinculado."
               STR0328,STR0329) //STR0328 "Exclua a vinculação antes de desmarcar o item" //STR0329 "Atenção"
   Else
      Work->WKNOME_FAB  := SPACE(15)
      Work->WKNOME_FOR  := SPACE(15)
      Work->WKFLAG      := .F.
      Work->WKFLAGWIN   := SPACE(nLenOk)   //SO0026 FCD OS.:0243/02
   EndIf

   E_ItFabFor(cDESC_PO,,"PO") // posiciona SB1, atualiza descricao do item em ###,
                   // nome reduzido do fabricante e do fornecedor

   MForn := IF(MTotal == 0 .AND. ! W_Flag_Seq,"",MForn)

   IF EasyEntryPoint("EICPO400")                          //  JBS - 14/07/2003
      ExecBlock("EICPO400",.F.,.F.,"DESMARCA_ITEM")
   ENDIF

   RETURN

ENDIF

//Marcar
IF !EMPTY(Work->WKFORN) .AND. !EICEmptyLJ("Work", "W3_FORLOJ")  .AND. (Work->WKFORN <> M->W2_FORN .or. (!EICLOJA() .OR. Work->W3_FORLOJ <> M->W2_FORLOJ))
   Help("", 1, "AVG0000325",,M->W2_FORN,2,1)//"Fornecedor deve ser o mesmo j  informado ! ("###"Informação"
   Return .F. //wfs abr/2017 - tratativa de erro na geração automática do P.O. a partir da S.I.
Endif
aGets:={};aTela:={}

nL1:=18 ; nL2:=31 ; nL3:=44 ; nL4:=57 ; nL5:=70 ; nL6:=83 ; nL7:=96
nL8:=109 ; nL9:=122 ; nL10:=135
nC1:=6 ; nC2:=48 ; nC3 :=128 ; nC4:=168 ; nC5:=64 ; nC6:=200 ; nC7:=230

//TRP-14/05/07
//aOrd := SaveOrd("SX3",1)
//SX3->(dbSeek("SW3"))
   //While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SW3"
      //If SX3->X3_PROPRI=="U" .AND. Ascan(aMostraCpos,Alltrim(SX3->X3_CAMPO))==0 .AND. X3Uso(SX3->X3_USADO)
         //AADD(aMostraCpos,Alltrim(SX3->X3_CAMPO))
      //EndIF
      //SX3->(dbSkip())
   //Enddo
//RestOrd(aOrd)

//TRP-15/05/07
For I := 1 To Work->(FCount())
   M->&((Alias())->(FIELDNAME(I))) := (Alias())->(FieldGet(I))

   //AOM - 25/05/2011 - Carregar a Memória com os campos nomeados igual ao dicionário de acordo com o Arraya "CorrespW3"
   If (nPos := Ascan(aCorrespW3, {|x| AllTrim(x[2]) == AllTrim((Alias())->(FIELDNAME(I)))})) > 0
      M->&(aCorrespW3[nPos][1]) := (Alias())->(FieldGet(I))
   EndIf

Next

//AOM - 20/05/2011
If lOperacaoEsp
   M->W3_DESOPE := Posicione('EJ0',1,xFilial('EJ0') + M->W3_CODOPE ,'EJ0_DESC')
EndIf

//FOR I := 1 TO Len(aMostraCpos)
//   SW3->( M->&(aMostraCpos[I]) := FieldGet(I) )
//NEXT

//AOM - 07/04/2011 - Carregando para memoria cod e desc da operação Especial
If lOperacaoEsp
   If  nOpcAux == 3 //Inclusao
      M->W3_CODOPE := ""
   EndIf
   M->W3_DESOPE := Posicione("EJ0",1,xFilial("EJ0") + AvKey(M->W3_CODOPE,"EJ0_COD"),"EJ0_DESC")
EndIf

SYR->(DBSETORDER(1))                                           //  JBS 28/07/2003
SYR->(DBSEEK(xFilial()+M->W2_TIPO_EM+M->W2_ORIGEM+M->W2_DEST)) //  JBS 28/07/2003
SB1->(DBSEEK(xFilial()+Work->WKCOD_I))
M->W3_COD_I   := Work->WKCOD_I
M->W3_FABR    := Work->WKFABR//IF(!EMPTY(TFabr),TFabr,WKFABR)
M->W3_POSICAO := Work->WKPOSICAO
IF EICLOJA()
   M->W3_FABLOJ    := Work->W3_FABLOJ
ENDIF
cFabrIt_Old := M->W3_FABR // By JPP - 28/02/2008 - 16:20
IF EICLOJA()
   cLjFabrIt  := M->W3_FABR
ENDIF
cPO_Num_It  := Work->WKPO_NUM // By JPP - 28/02/2008 - 16:20
M->W3_FLUXO   := Work->WKFLUXO
//M->W3_SALDO_Q := PO400Saldo() //Esta variavel é atualizada dentro da Funcao POATUALIZA() // IF(lPOdaIntegracao,Work->WKSALDO_O,Work->WKSALDO_Q)
M->W3_SALDO_Q :=IF(lPOdaIntegracao,Work->WKSALDO_O,Work->WKSALDO_Q) //ASK - 28/03/07 Devido a rotina PO400Zera
TPortaria     := Work->WKPORTARIA
M->W2_FORN    := IF(!EMPTY(Work->WKFORN),Work->WKFORN,M->W2_FORN)
IF EICLOJA()
   M->W2_FORLOJ := IF(!EMPTY(Work->W3_FORLOJ),Work->W3_FORLOJ,M->W2_FORLOJ)
ENDIF
TPosicao      := Val(Work->WKPOSICAO)
M->W3_FABR_01 := Work->WKFABR_01
M->W3_FABR_02 := Work->WKFABR_02
M->W3_FABR_03 := Work->WKFABR_03
M->W3_FABR_04 := Work->WKFABR_04
M->W3_FABR_05 := Work->WKFABR_05
IF EICLOJA()
   M->W3_FAB1LOJ := Work->W3_FAB1LOJ
   M->W3_FAB2LOJ := Work->W3_FAB2LOJ
   M->W3_FAB3LOJ := Work->W3_FAB3LOJ
   M->W3_FAB4LOJ := Work->W3_FAB4LOJ
   M->W3_FAB5LOJ := Work->W3_FAB5LOJ
ENDIF
if !Work->WKDTENTR_S = ctod(" / /    ") //wReliquias  499390 MTRADE-288 e MTRADE-291 - Botão "Altera datas" no PO permitir informar data a todos os itens
	M->W3_DT_ENTR := IF(!Work->WKFLAG2,Work->WKDTENTR_S,Work->WKDT_ENTR)
endIf
M->W3_QTDE    := Work->WKQTDE
M->W3_QTD_EMB := Work->WKQTDE_EMB
M->W3_SEM_PED := Work->WKSEM_PO

IF AvFlags("EIC_EAI")//AWF - 25/06/2014
   M->W3_UM     := Work->WKUNI
   M->W3_SEGUM  := Work->WKSEGUM
   M->W3_QTSEGUM:= Work->WKQTSEGUM//AVTransUnid(Work->WKUNI,M->W3_SEGUM,Work->WKCOD_I,M->W3_QTDE,,,,M->W2_FORN,M->W2_FORLOJ)
ENDIF

SA2->(DBSEEK(xFilial()+ M->W3_FABR+EICRetLoja("M","W3_FABLOJ") ))
M->W3_FAB_DES:=SA2->A2_NREDUZ //Nopado por FDR - 12/01/12 /*M->W3_FABR+" - "+SA2->A2_NREDUZ*/

If lForeCast
   M->W3_FORECAS:=WORK->WK_FORECAS
Endif

//FSM - 16/05/2012 - Admissão em Entreposto
If EasyGParam("MV_AVG0211",,.F.) .And. SW3->(FieldPos("W3_ALTANU")) > 0
   M->W3_ALTANU := Work->WKALTANU
EndIf

M->W3_DT_EMB  := Work->WKDT_EMB

IF( EasyEntryPoint("EICPO400"), ExecBlock("EICPO400",.F.,.F.,"INICIA_VAR_ITEM"), )

IF !Work->WKFLAG2                      // Sugere data de Entrega     Jonato Silva
   IF EMPTY(Work->WKDTENTR_S) .and. EMPTY(M->W3_DT_ENTR) //wReliquias  499390 MTRADE-288 e MTRADE-291 - Botão "Altera datas" no PO permitir informar data a todos os itens
      SY9->(dbSetOrder(2))
      Work->WKDT_ENTR:= M->W3_DT_EMB + SYR->YR_TRANS_T + IF(SY9->(DBSEEK(xFilial()+M->W2_DEST)),(SY9->Y9_LT_DES + SY9->Y9_LT_TRA),EasyGParam("MV_LT_DESE"))
      //wReliquias  499390 MTRADE-288 e MTRADE-291 - Botão "Altera datas" no PO permitir informar data a todos os itens
      if Work->WKDT_ENTR = CToD("31/12/1899")
      	Work->WKDT_ENTR:= CToD("  /  /    ")
      endIf
      SY9->(dbSetOrder(1))
   ENDIF
ENDIF

lMostraMem    :=.T.

M->W3_PRECO   := IF(EMPTY(Work->WKPRECO),0,Work->WKPRECO)
M->W3_REG_MIN := Work->WK_REG_MIN
M->W3_CUSTO   := (M->W3_PRECO*M->W3_QTDE)

If lCopiaPO
   M->W3_QTDE    := M->W3_SEM_PED
   M->W3_SALDO_Q := M->W3_SEM_PED
   M->W3_SEM_PED := 0
Else
   POATUALIZA() // Inicia a variavel M->W3_SALDO_Q
EndIf

IF(lSeal,ExecBlock("IC193PO1",.F.,.F.,"5"),)

M->W3_REG_TRI := IF(!Empty(Work->WK_REG_TRI),Work->WK_REG_TRI,;
                    IF(!Empty(M->W2_REG_TRI),M->W2_REG_TRI,CriaVar("W3_REG_TRI")))

   M->W3_TEC    := Work->WK_TEC
   M->W3_EX_NCM := Work->WK_EX_NCM
   M->W3_EX_NBM := Work->WK_EX_NBM

If SW3->(FieldPos("W3_PART_N")) # 0 //ASK - 02/10/2007
   M->W3_PART_N := Work->WKPART_N
   AADD(aMostraCpos,"W3_PART_N")
EndIf

If SW3->(FieldPos("W3_PESOL")) # 0 //CCH - 07/08/09 - Gravação do novo campo de Peso Líquido Unitário
   M->W3_PESOL := Work->WKPESOL
   AADD(aMostraCpos,"W3_PESOL")
EndIf

//TRP- 01/06/09 - Campo Software para novo Tratamento de Mídia e Software
If SW3->(FieldPos("W3_SOFTWAR")) # 0 .And. EasyGParam("MV_CONSOFT",, "N") $ cSim
   M->W3_SOFTWAR := Work->WKSOFTWAR
   AADD(aMostraCpos,"W3_SOFTWAR")
Endif

If lCpoCtCust                    //NCF - 23/06/2010 - Campo do Centro de Custo
   M->W3_CTCUSTO := Work->WKCTCUSTO
   aAdd(aMostraCpos,"W3_CTCUSTO")
EndIf
If lPesoBruto
   M->W3_PESO_BR := Work->WKPSBRUTO
   aAdd(aMostraCpos,"W3_PESO_BR")
EndIf
If AvFlags("RATEIO_DESP_PO_PLI")
   M->W3_FRETE   := Work->WKFRETE
   M->W3_SEGURO  := Work->WKSEGUR
   M->W3_INLAND  := Work->WKINLAN
   M->W3_DESCONT := Work->WKDESCO
   M->W3_PACKING := Work->WKPACKI
   If SW3->(FieldPos("W3_OUT_DES")) > 0
      M->W3_OUT_DES := Work->WKOUTDE
   EndIf
   aAdd(aMostraCpos,"W3_FRETE")
   aAdd(aMostraCpos,"W3_SEGURO")
   aAdd(aMostraCpos,"W3_INLAND")
   aAdd(aMostraCpos,"W3_DESCONT")
   aAdd(aMostraCpos,"W3_PACKING")
   If SW3->(FieldPos("W3_OUT_DES")) > 0
      aAdd(aMostraCpos,"W3_OUT_DES")
   EndIf
EndIf
IF AvFlags("EIC_EAI")//AWF - 25/06/2014
   aAdd(aMostraCpos,"W3_UM")
   aAdd(aMostraCpos,"W3_SEGUM")
   aAdd(aMostraCpos,"W3_QTSEGUM")
ENDIF

If lNestle
   ExecBlock(cArqNestle,.F.,.F.,"3")
Endif

IF lRdMake
   ExecBlock("EICPPO02",.F.,.F.,"19")
ENDIF


nLinhaI:=6.6
nLinhaF:=0
nColunI:=28
nColunF:=80

IF lAnuencia
    AADD(aMostraCpos,"W3_FLUXO")
    AADD(aMostraCpos,"W3_QTD_LI")
ENDIF
If lForeCast
    AADD(aMostraCpos,"W3_FORECAS")
Endif
If cProg#"PN"
    AADD(aMostraCpos,"W3_DT_EMB")
    AADD(aMostraCpos,"W3_DT_ENTR")
EndIf

IF Work->WKFLUXO == "7"
   lPoEmbarc:= (Work->WKSALDO_GI<>Work->WKQTDE_GI)
ELSE
   lPoEmbarc:= (Work->WKQTDE_GI<>0)
ENDIF

IF lPoEmbarc .AND. cProg#"PN"
   lWhen:= .F.
ENDIF

//AOM - 07/04/2011  - Mostra Operação se nao estiver embarcado
If lOperacaoEsp .And. !lPoEmbarc
    AADD(aMostraCpos,"W3_CODOPE")
    AADD(aMostraCpos,"W3_DESOPE")
EndIf

IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"COORDENADA_TELA_ITENS"),)

//mls OS-K/2004 inclusao produto x fornecedor
IF cPaisLoc # "BRA"

   SA2->(DBSETORDER(1))
   SA2->(DBSEEK(XFILIAL("SA2")+M->W2_FORN+EICRetLoja("M","W2_FORLOJ")))
   cLOJA := SA2->A2_LOJA

   SA5->(DbSetOrder(2))

   If !SA5->(DbSeek(xFilial()+Work->WKCOD_I+M->W2_FORN+EICRetLoja("M","W2_FORLOJ")))
      IF MSGYESNO(AllTrim(TRANSFORM(Work->WKCOD_I,_PictItem))+ STR0302 + M->W2_FORN + STR0303) //str0302 = "não registrado para esse fornecedor " //STR0303 = "registrar"
         SA5->(RECLOCK("SA5",.T.))
         SA5->A5_FORNECE :=M->W2_FORN
         SA5->A5_LOJA    :=cLOJA
         SA5->A5_PRODUTO :=Work->WKCOD_I
         SA5->A5_FABR    :=M->W2_FORN
         SA5->A5_FALOJA  :=cLOJA
         SA5->(MSUNLOCK())
      ENDIF
   Endif
   SA5->(DbSetOrder(3))

endif
//mls

aMostraCpos:=(AddCpoUser(aMostraCpos,"SW3","1"))

/* Atualização da segunda unidade de medida, caso tenha alteração/ atualização da conversão
de unidade de medidas do produto x fornecedor. */
If AvFlags("EIC_EAI")
   AAdd(aButtonsIt, {"EDIT", {|| AtuSegQuant(.T.), oEnchDItem:Refresh()}, STR0392 , STR0392}) //"Quantidade na Segunda Unidade"
EndIf
/* //NCF - 27/10/2016 - Permitir alteração de preço mesmo sendo PO orignado de O.C vinda de contrato.
If AvFlags("EIC_EAI") .AND. M->W2_CONTR == "1" .AND. !( Type("lPOAuto") == "L" .AND. lPOAuto )
   If Type("aCposAltera") == "U" .OR. Len(aCposAltera) == 0
      aCposAltera := aClone(aMostraCpos)
      If (nPos := AScan( aCposAltera, { |x| x $ "W3_PRECO" })) > 0
         ADel( aCposAltera, nPos )
         ASize( aCposAltera, Len(aMostraCpos)-1 )
      EndIf
   EndIf
EndIf
*/
If !IsMemVar("lPOAuto")
   lPOAuto:= .F.
EndIf
If !lPOAuto
   DEFINE MSDIALOG oDlg TITLE STR0070 From nLinhaI,nLinhaF To nColunI,nColunF OF oMainWnd //"Dados do Item"



   //  TLM 13/03/2008  - Se o pedido for entreposto, o terceiro parâmetro deve ser 3 pois no aRotina não existe a opção incluir.
   If cProg = "PN"
      //** AAF 20/03/08 - Permitir alterar a Anuencia para pedido de nascionalização.

     //MsmGet(): New ( [ cAlias], [ uPar2], < nOpc>, [ uPar4], [ uPar5], [ uPar6], [ aAcho], [ aPos], [ aCpos], 
      //[ nModelo], [ uPar11], [ uPar12], [ uPar13], [ oWnd], [ lF3], [ lMemoria], [ lColumn], [ caTela], [ lNoFolder], 
      //[ lProperty], [ aField], [ aFolder], [ lCreate], [ lNoMDIStretch], [ uPar25] ) -->      

      oEnchDItem:=MsMGet():New("SW3",;
                               /*Work->WKREC_SW3*/,; //CEO - 16/05/2018 - Comentado, pois no TDN diz 2o param nao usado
                               3,;
                               ,;
                               ,;
                               ,;
                               aMostraCpos,;
                               {15,1,FINAL_SELECT,COLUNA_FINAL},;
                               aCposAltera:=If(lAnuencia,{"W3_FLUXO"},{}),;
                               3,;
                               ,;
                               ,;
                               ,;
                               ,;
                               ,;
                               .T.) // Incluído o array aCposAltera

      oEnchDItem:oBox:Align:=CONTROL_ALIGN_ALLCLIENT //LRL 20/04/04 - Alinhamento MDI
   Else
      oEnchDItem:=MsMGet():New("SW3",;
                               /*WORK->WKREC_SI*/,; //CEO - 16/05/2018 - Comentado, pois no TDN diz 2o param nao usado
                               4,;
                               ,;
                               ,;
                               ,;
                               aMostraCpos,;
                               {15,1,FINAL_SELECT,COLUNA_FINAL},;
                               aCposAltera,;                               
                               3,;
                               ,;
                               ,;
                               ,;
                               ,;
                               ,;
                               .T.)

      oEnchDItem:oBox:Align:=CONTROL_ALIGN_ALLCLIENT //LRL 20/04/04 - Alinhamento MDI
   EndIf
   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,;
                                 {|| nOpcA:=1 , If(Obrigatorio(aGets,aTela) .And. EVAL(bValid) .And. ValidOpePO("BTN_MK_IT")/*AOM - 08/04/2011 - Valida operação especial */,oDlg:End(),nOpcA:=0)},;  //JVR - 28/05/09 - verificação obrigatorio.
                                 {|| nOpcA:=0 , oDlg:End()},,aButtonsIt),; //Acb - 06/04/2010
                                 SX5->(dbSeek(xFilial()+"Y2"+M->W3_REG_TRI)),PO420Val("REG_TRI",,,oDlg)) CENTERED

Else

   If EnchAuto("SW3",TEVldEnch(aItemAux,,{"W3_SALDO_Q"}),{|| Obrigatorio(aGets,aTela) .AND. EVAL(bValid)},nOpcAuto,aMostraCpos)
      nOpca:= 1
   Else
      nOpca:= 0
   Endif

Endif

SETKEY(VK_F4,NIL)

If nOpcA = 0
   DBSELECTAREA("Work")
   RETURN
Endif

IF nOpcA = 1

   IF EasyGParam("MV_EIC0059",,.F.) //MCF - 28/05/2015
      aOrdSWB := SaveOrd({"SWB"})
      SWB->(dbSetOrder(1))
      IF SWB->(dbSeek(xFilial("SWB")+M->W2_PO_NUM)) .AND. SWB->WB_PO_DI == 'A' .And. !Empty(SWB->WB_CA_DT) .And. (M->W3_QTDE # SW3->W3_QTDE .Or. M->W3_PRECO # SW3->W3_PRECO)
         EasyHelp(STR0404)//"Processo possui cambio antecipado liquidado, não será permitido alteração de quantidade e valor."
         RETURN .F. //wfs abr/2017 - tratativa de erro na geração automática do P.O. a partir da S.I.
      ENDIF
      RestOrd(aOrdSWB,.T.)
   ENDIF

   IF lPOdaIntegracao .OR. cProg="PN"
      MTotal   -= VAL(STR(Work->WKPRECO * Work->WKQTDE,15,2))
      MFob_Abs -= VAL(STR(Work->WKPRECO * Work->WKQTDE,15,2))
      MForn    := IF(MTotal=0 .AND. !W_Flag_Seq,"",MForn)
//    Work->WKSALDO_Q  := Work->WKSALDO_O
   ENDIF

   DBSELECTAREA("Work")
   Work->WKQTDE    := M->W3_QTDE
   Work->WKSALDO_Q := M->W3_SALDO_Q//WORK->WKSALDO_Q - IF( M->W3_QTDE <> WORK->WKSALDO_Q , M->W3_QTDE , 0 )
   Work->WKPRECO   := M->W3_PRECO
   Work->WKFABR    := M->W3_FABR
   IF EICLOJA()
      Work->W3_FABLOJ := M->W3_FABLOJ
   ENDIF
   Work->WKFABR_01 := M->W3_FABR_01
   Work->WKFABR_02 := M->W3_FABR_02
   Work->WKFABR_03 := M->W3_FABR_03
   Work->WKFABR_04 := M->W3_FABR_04
   Work->WKFABR_05 := M->W3_FABR_05
   IF EICLOJA()
      Work->W3_FAB1LOJ := M->W3_FAB1LOJ
      Work->W3_FAB2LOJ := M->W3_FAB2LOJ
      Work->W3_FAB3LOJ := M->W3_FAB3LOJ
      Work->W3_FAB4LOJ := M->W3_FAB4LOJ
      Work->W3_FAB5LOJ := M->W3_FAB5LOJ
   ENDIF
   Work->WKPOSICAO := STRZERO(TPosicao,LEN(SW3->W3_POSICAO),0)//Em 27/5/99 voltou a gravar com zeros a esquerda AWR
   Work->WKFORN    := M->W2_FORN
   IF EICLOJA()
      Work->W3_FORLOJ := M->W2_FORLOJ
   ENDIF
   Work->WKDT_EMB  := M->W3_DT_EMB
   Work->WKDT_ENTR := M->W3_DT_ENTR
   Work->WKFLAG    := .T.
   Work->WKFLUXO   := M->W3_FLUXO
   Work->WKFLAGWIN := cMarca                                                                                                  //NCF - 28/05/2021 - Variável M->W3_SEM_PED não atualiza quando não se altera o campo de quantidade na tela.
   Work->WKSEM_PO  := If( lCopiaPO , If( (nSldSemPed := (POSALDO_W1() - M->W3_QTDE)) > 0 , nSldSemPed , 0 ) , M->W3_SEM_PED ) //AWF-26/06/2014 - Tava gravando valor negativo (POSALDO_W1()-Work->WKQTDE)   // AWR 15/04/2004
   Work->WKQTDE_EMB:= M->W3_QTD_EMB

   IF AvFlags("EIC_EAI")//AWF - 25/06/2014
      Work->WKQTSEGUM := M->W3_QTSEGUM
   ENDIF

   //AOM - 07/04/2011 - Carregando para memoria cod e desc da operação Especial
   If lOperacaoEsp .And. ChkFile("EJ0")
      Work->W3_CODOPE := M->W3_CODOPE
      Work->W3_DESOPE := Posicione("EJ0",1,xFilial("EJ0") + AVKEY(M->W3_CODOPE,"EJ0_COD"),"EJ0_DESC")
   EndIf

   IF SW3->(FieldPos("W3_PART_N")) # 0 //ASK 05/10/2007
      Work->WKPART_N  := M->W3_PART_N
   EndIf

   
   If SW3->(FieldPos("W3_PESOL")) # 0 //CCH - 07/08/09 - Gravação do novo campo de Peso Líquido Unitário
      Work->WKPESOL := M->W3_PESOL
   EndIf

   //FSM - 16/05/2012 - Admissão em Entreposto
   If EasyGParam("MV_AVG0211",,.F.) .And. SW3->(FieldPos("W3_ALTANU")) > 0
      Work->WKALTANU := M->W3_ALTANU
   EndIf


   //TRP- 01/06/09 - Campo Software para novo Tratamento de Mídia e Software
   If SW3->(FieldPos("W3_SOFTWAR")) # 0 .And. EasyGParam("MV_CONSOFT",, "N") $ cSim
      Work->WKSOFTWAR:= M->W3_SOFTWAR
   Endif

   If lCpoCtCust                       //NCF - 23/06/2010 - Campo do Centro de Custo
      Work->WKCTCUSTO := M->W3_CTCUSTO
   EndIf
   If lPesoBruto                       //NCF - 25/08/2011 - Campo do Peso Bruto Unitário
      Work->WKPSBRUTO := M->W3_PESO_BR
   EndIf
   If AvFlags("RATEIO_DESP_PO_PLI")
      Work->WKFRETE := M->W3_FRETE
      Work->WKSEGUR := M->W3_SEGURO
      Work->WKINLAN := M->W3_INLAND
      Work->WKDESCO := M->W3_DESCONT
      Work->WKPACKI := M->W3_PACKING
      If SW3->(FieldPos("W3_OUT_DES")) > 0
         Work->WKOUTDE := M->W3_OUT_DES
      EndIf
   EndIf
   IF(lSeal,ExecBlock("IC193PO1",.F.,.F.,"6"),) //AWR 05/05/1999

   IF lRdMake
      ExecBlock("EICPPO02",.F.,.F.,"5")
   ENDIF

   IF EasyEntryPoint("EICPO400")
      ExecBlock("EICPO400",.F.,.F.,"GRAVA_ALTERACAO_ITEM")
   ENDIF
   IF lNec
      nExecute:="9"
      ExecBlock(cArqRdmake,.F.,.F.)
   ENDIF

   If lNestle
      ExecBlock(cArqNestle,.F.,.F.,"6")
   Endif

   If lForecast
      Work->WK_FORECAS := M->W3_FORECAS
   Endif

   IF Work->WKSALDO_Q < 0 .AND. !lLibQt
      Work->WKSALDO_Q := 0  // VARIAVEL NAO UTILIZADA PARA CALCULOS, ZERADA PARA NAO MOSTRAR SALDO NEGATIVO
   ENDIF

   E_ItFabFor(cDESC_PO,,"PO") // posiciona SB1, atualiza descricao do item em ###,
                   // nome reduzido do fabricante e do fornecedor

   IF !EMPTY( Work->WKFABR )
      SYG->(DBSEEK(xFilial()+M->W2_IMPORT+Work->WKFABR+EICRetLoja("Work","W3_FABLOJ")+Work->WKCOD_I))
      Work->WK_REG_MIN := SYG->YG_REG_MIN
   ENDIF

   Work->WK_REG_TRI := M->W3_REG_TRI

   Work->WK_TEC    := M->W3_TEC
   Work->WK_EX_NCM := M->W3_EX_NCM
   Work->WK_EX_NBM := M->W3_EX_NBM

   MTotal  := MTotal + VAL(STR(WORK->WKPRECO * WORK->WKQTDE,15,2))
   MFob_Abs+= VAL(STR(WORK->WKPRECO * WORK->WKQTDE,15,2))

   IF lExiste_Midia         .AND.;
      !EMPTY(M->W2_VLMIDIA) .AND.;
      SB1->B1_MIDIA $ cSim
      Work->WK_VLTOTMI := SB1->B1_QTMIDIA * M->W2_VLMIDIA * Work->WKQTDE
   ENDIF

   IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"GRAVA_ITENS_WORK"),)

   IF EMPTY(MForn)
      MForn := M->W2_FORN
   ENDIF

   IF EICLOJA()
      IF EMPTY(MLoja)
         MLoja:= M->W2_FORLOJ
      ENDIF
   ENDIF

   //TRP-14/05/07
   aFields := FWSX3Util():GetAllFields("SW3", .F.)
   For i := 1 To Len(aFields)
      If GetSx3Cache(aFields[i], "X3_PROPRI") == "U" .AND. X3Uso(GetSx3Cache(aFields[i], "X3_USADO"))
         If Type(M->aFields[i]) == FWSX3Util():GetFieldType(aFields[i])
            Eval(FieldWBlock(aFields[i], Select("Work")), Eval(MemVarBlock(aFields[i])))
         EndIf
      EndIF
   Next

ENDIF
If(AvFlags("RATEIO_DESP_PO_PLI") .And. !lPOAuto,PO400RatFrSg(),)
TEmb_Ant  := M->W3_DT_EMB
DBSELECTAREA("Work")
RETURN .T.
*----------------------------------------------------------------------------
FUNCTION P_Te_4
*----------------------------------------------------------------------------
LOCAL MSalvaFilter:= TCC+TSi_Num, MRecno:= RECNO()
LOCAL nRetorno, oDlg, oMark, oPanel
LOCAL nL1, nL2, nL3 ,nC1, nC3
LOCAL nOpcao := 0, nColPos := 1
LOCAL _LIT_CC := AVSX3("W0__CC")[5]
LOCAL _PictItem := ALLTRIM(X3PICTURE("B1_COD"))
LOCAL _PictSI   := ALLTRIM(X3PICTURE("W0__NUM"))
Local bGravaPO, bAltDatas, bOrdena //LGS-23/10/2013
Local bCancel := {|| oDlg:End() }
Local aBtnsT4 := {}		// JWJ 21/10/09
Local lRet:= .T.

/*wReliquias*/
lTelaIte = .F.

MControla := .T.

DBSELECTAREA("Work")
If lPOAuto .AND. nOpcAuto == 3   // GFP - 15/10/2013
   Work->(DbGoTop())
   Do While Work->(!Eof())
      WORK->WKFLAG := .T.
      Work->(DbSkip())
   EndDo
   Work->(DbGoTop())
EndIf

nOrder:=WORK->(INDEXORD())
IF lRdMake
   ExecBlock("EICPPO02",.F.,.F.,"6")
ENDIF

IF EasyEntryPoint("EICPO400")
   ExecBlock("EICPO400",.F.,.F.,"INICIA_VARIAVEL_CONFERENCIA_FINAL")
ENDIF

IF lNec
   nExecute:="6"
   ExecBlock(cArqRdmake,.F.,.F.)
ENDIF
Work->(DBSETORDER(nOrder))
SET FILTER TO WKFLAG == .T.
MTotal:=0
Work->(DbGoTop())

//Nopado por FDR - 01/06/12
//If SW3->(FIELDPOS("W3_SLD_ELI")) # 0
  // WORK->(DBEVAL({|| MTotal+=DI500Trans((Work->WKQTDE*Work->WKPRECO)-(Work->WKSLD_ELI*Work->WKPRECO),2)},{|| !EMPTY(WORK->WKFLAG)},{||.T.})) //BHF - 25/11/08 - DI500Trans()
//Else
   WORK->(DBEVAL({|| MTotal+=DI500Trans(Work->WKQTDE*Work->WKPRECO,2)},{|| !EMPTY(WORK->WKFLAG)},{||.T.})) //BHF - 25/11/08 - DI500Trans()
//EndIf
Work->(DbGoTop())
M->W2_FOB_GER := MTotal

If(AvFlags("RATEIO_DESP_PO_PLI"),PO400RatFrSg(),)

nL1:=18 ; nL2:= 31 ; nL3:=44
nC1:=6 ; nC3:=144

aCampos:={}
IF EasyEntryPoint("EICPPO02")
   ExecBlock("EICPPO02",.F.,.F.,"29")
ENDIF

AADD(aCampos,{"WKPOSICAO"           ,"",avsx3("W1_POSICAO",AV_TITULO)+" (PO)",avsx3("W1_POSICAO",AV_PICTURE)}) //W1_POSICAO
AADD(aCampos,{"WKCC"                   ,"",_LIT_CC})
AADD(aCampos,{"WKSI_NUM"               ,"",STR0083,_PictSI}) //"N§ S.I."
//if INCLUI
   AADD(aCampos,{"WKPOSIT"             ,"",avsx3("W1_POSIT",AV_TITULO)+" (SI)",avsx3("W1_POSIT",AV_PICTURE)}) //W1_POSIT
//elseif ALTERA
//endif
AADD(aCampos,{"WKCOD_I"                ,"",STR0013,_PictItem}) //"Item"
AADD(aCampos,{"WKDESCR"                ,"",AVSX3("B1_DESC_"+cDESC_PO,AV_TITULO)}) //"Descri‡ao em ###"

IF lRdMake
   ExecBlock("EICPPO02",.F.,.F.,"7")
ENDIF

IF lNec
   nExecute:="11"
   ExecBlock(cArqRdmake,.F.,.F.)
ENDIF

If cPaisLoc=="BRA"
   AADD(aCampos,{{||IF(Work->WKFLUXO=='7',STR0015,STR0016)},"",STR0017}) //'Nao'###'Sim'###"Anuencia"
EndIf

IF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"11"),)//AWR 09/11/1999

AADD(aCampos,{{||Work->WKFABR+" "+Work->WKNOME_FAB} ,"",STR0019}) //"Fabricante"

IF EICLOJA()
   EICAddLoja(aCampos, "W3_FABLOJ",, STR0019)
ENDIF

IF lExiste_Midia .AND. !EMPTY(M->W2_VLMIDIA)//AWR 21/10/1999
   AADD(aCampos,{"WK_QTMIDIA",,AVSX3("B1_QTMIDIA",5),AVSX3("B1_QTMIDIA",6)})
   AADD(aCampos,{"WK_VLTOTMI",,STR0021,AVSX3("W2_VLMIDIA",6)}) //"Vlr. Total Midia"
ENDIF

AADD(aCampos,{"WKQTDE"                 ,"",STR0022,_PictQtde}) //"Quantidade"
IF AvFlags("EIC_EAI")//AWF - 25/06/2014
   AADD(aCampos,{"WKUNI"  ,,AVSX3("W3_UM",AV_TITULO)})
ELSE
   IF EICLOJA()
      AADD(aCampos,{{||BUSCA_UM(Work->WKCOD_I+Work->WKFABR+Work->WKFORN,WORK->WKCC+WORK->WKSI_NUM,WORK->W3_FABLOJ,WORK->W3_FORLOJ)},,STR0060}) //"Unidade"
   ELSE
      AADD(aCampos,{{||BUSCA_UM(Work->WKCOD_I+Work->WKFABR+Work->WKFORN,WORK->WKCC+WORK->WKSI_NUM,"","")},,STR0060}) //"Unidade"
   ENDIF
ENDIF
IF AvFlags("EIC_EAI")//AWF - 25/06/2014
   AADD(aCampos,{"WKQTSEGUM",,AVSX3("W3_QTSEGUM",AV_TITULO),AVSX3("W3_QTSEGUM",6)})
   AADD(aCampos,{"WKSEGUM"  ,,AVSX3("W3_SEGUM",AV_TITULO)})
ENDIF
If SW3->(FieldPos("W3_PESOL")) # 0  //CCH - 07/08/09 - Gravação do novo campo de Peso Líquido Unitário
   AADD(aCampos,{"WKPESOL","",AVSX3("W3_PESOL")[5],AVSX3("W3_PESOL")[6]})
EndIf
AADD(aCampos,{"WKPRECO"                ,"",STR0084,_PictPrUn}) //"Pre‡o Unit rio"
//JVR / 28/10/2009 - DI500TRANS() e picture.

//Nopado por FDR - 01/06/12
//If SW3->(FIELDPOS("W3_SLD_ELI")) # 0
//   AADD(aCampos,{{||DI500TRANS((Work->WKPRECO*Work->WKQTDE)-(Work->WKPRECO*Work->WKSLD_ELI),2)},"",STR0085,'@E 999,999,999,999.99'})//"Pre‡o Total"
//Else
   AADD(aCampos,{{||DI500TRANS((Work->WKPRECO*Work->WKQTDE),2)},"",STR0085,'@E 999,999,999,999.99'})//"Pre‡o Total"
//EndIf

AADD(aCampos,{"WKDT_EMB"               ,"",STR0027}) //"Embarque"
AADD(aCampos,{"WKDT_ENTR"              ,"",STR0028} ) //"Entrega"
If lNestle
   ExecBlock(cArqNestle,.F.,.F.,"9")
Endif
If lForeCast
   AADD(aCampos,{{||IF(Work->WK_FORECAS=="S",STR0029,STR0030)},"",STR0031})//CAF 22/10/98 //"Sim"###"Nao"###"Forecast"
Endif

AADD(aCampos,{{||SX5->(dbSeek(xFilial()+"Y2"+Work->WK_REG_TRI)),AllTrim(X5DESCRI())},,AVSX3("W3_REG_TRI")[5]})
AADD(aCampos,{"WK_REG_MIN","",STR0032} ) //"Registro no Minist‚rio / OrgÆo P£blico"
   AADD(aCampos,{"WK_TEC"   ,,AVSX3("W3_TEC"   )[5]})
   AADD(aCampos,{"WK_EX_NCM",,AVSX3("W3_EX_NCM")[5]})
   AADD(aCampos,{"WK_EX_NBM",,AVSX3("W3_EX_NBM")[5]})

If SW3->(FieldPos("W3_PART_N")) # 0 //ASK 02/10/2007
   AADD(aCampos,{"WKPART_N",,AVSX3("W3_PART_N")[5]})
EndIf

//TRP- 01/06/09 - Campo Software para novo Tratamento de Mídia e Software
If SW3->(FieldPos("W3_SOFTWAR")) # 0 .And. EasyGParam("MV_CONSOFT",, "N") $ cSim
   AADD(aCampos,{{||IF(Work->WKSOFTWAR=='2',STR0015,STR0016)},,AVSX3("W3_SOFTWAR",5)})
Endif

If lCpoCtCust
   AADD(aCampos,{"WKCTCUSTO",,AVSX3("W3_CTCUSTO",5),AVSX3("W3_CTCUSTO",6)})
EndIf

If lPesoBruto //NCF
   AADD(aCampos,{"WKPSBRUTO",,AVSX3("W3_PESO_BR",5),AVSX3("W3_PESO_BR",6)})
EndIf
If AvFlags("RATEIO_DESP_PO_PLI")
   AADD(aCampos,{"WKFRETE",,AVSX3("W3_FRETE",5)  ,AVSX3("W3_FRETE",6)})
   AADD(aCampos,{"WKSEGUR",,AVSX3("W3_SEGURO",5) ,AVSX3("W3_SEGURO",6)})
   AADD(aCampos,{"WKINLAN",,AVSX3("W3_INLAND",5) ,AVSX3("W3_INLAND",6)})
   AADD(aCampos,{"WKDESCO",,AVSX3("W3_DESCONT",5),AVSX3("W3_DESCONT",6)})
   AADD(aCampos,{"WKPACKI",,AVSX3("W3_PACKING",5),AVSX3("W3_PACKING",6)})
   If SW3->(FieldPos("W3_OUT_DES")) > 0
      AADD(aCampos,{"WKOUTDE",,AVSX3("W3_OUT_DES",5),AVSX3("W3_OUT_DES",6)})
   EndIf
EndIf
//AOM - Adiciona campos de operação especial na work para conferencia final do PO
If lOperacaoEsp
   AADD(aCampos,{"W3_CODOPE","",AVSX3("W3_CODOPE",5),AVSX3("W3_CODOPE",6)})
   AADD(aCampos,{"W3_DESOPE","",AVSX3("W3_DESOPE",5),AVSX3("W3_DESOPE",6)})
EndIf

IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"BROWSE_CONFERENCIA"),)

   nOpcao := 0

If ( Type("lPOAuto") == "U" .OR. !lPOAuto )  // GFP - 26/08/2013
   oMainWnd:ReadClientCoords()
EndIf

//TRP-14/05/07
//aOrd := SaveOrd("SX3",1)
//SX3->(dbSeek("SW3"))


   //While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SW3"
      //If SX3->X3_PROPRI=="U" .AND. Ascan(aCampos, {|x| AllTrim(x[1]) == AllTrim(SX3->X3_CAMPO)})==0 .AND. X3Uso(SX3->X3_USADO)
         //aAdd(aCampos,{SX3->X3_CAMPO,"",AVSX3(SX3->X3_CAMPO,AV_TITULO),AVSX3(SX3->X3_CAMPO,AV_PICTURE)})
      //EndIF
      //SX3->(dbSkip())
   //Enddo
//RestOrd(aOrd)
aCampos:= AddCpoUser(aCampos,"SW3","2")

//DFS - 26/10/10 - Ponto de entrada para permitir definir tratamentos no array aCampos.
IF EasyEntryPoint("EICPO400")
   ExecBlock("EICPO400",.F.,.F.,"DEFINIR_ACAMPOS")
ENDIF

//RestOrd(aOrd)
If ( Type("lPOAuto") == "U" .OR. !lPOAuto )
DEFINE MSDIALOG oDlg TITLE STR0086 ; //"Conferência Final"
   FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;
   OF oMainWnd PIXEL
   @01.5,01 MSPANEL oPanel PROMPT "" SIZE 30,60 OF oDlg //LRL 19/03/04 -Painel para alinhamento MDI
   @ nL1,nC1 SAY STR0087 of oPanel PIXEL //"Nr. P.O.: "
   @ nL1,nC3 SAY STR0088 of oPanel PIXEL //"Data.: "

   @ nL1,nC1+40 MSGET M->W2_PO_NUM WHEN .F. SIZE 55,8 of oPanel PIXEL
   @ nL1,nC3+20 MSGET M->W2_PO_DT  WHEN .F. SIZE 40,8 of oPanel PIXEL

   nL3:=nL2
   IF WFLAG == "2" .AND. SW2->W2_NR_ALTE <> 0
      nL3 += 13
      @ nL2,nC1   SAY STR0089 of oPanel PIXEL //"Alteracao "
      @ nL2,nC3   SAY STR0088 of oPanel PIXEL //"Data.: "
      @ nL2,nC1+40 MSGET M->W2_NR_ALTE  SIZE 12,8   WHEN .F. of oPanel PIXEL
      @ nL2,nC3+20 MSGET M->W2_DT_ALTE PICTURE '@D' WHEN .F. SIZE 40,8 of oPanel PIXEL
   ENDIF

   @ nL3,nC1 SAY STR0090+M->W2_MOEDA of oPanel PIXEL //"Fob Total "
   //@ nL3,nC1+40 MSGET MTotal PICTURE _PictPrTot WHEN .F. SIZE 60,8 of oPanel PIXEL
   @ nL3,nC1+40 MSGET MTotal PICTURE '@E 999,999,999,999.99' WHEN .F. SIZE 60,8 of oPanel PIXEL//JVR - 28/10/2009 - apenas 2 casa decimais.
   Work->(oMark:=MsSelect():New("Work","WKFLAGWIN",,aCampos,@lInverte,@cMarca,{60,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2}))

   IF(lSeal,ExecBlock("IC193PO1",.F.,.F.,"4"),) //AWR 05/05/1999

   // AST - 14/01/09 - Verifica se está integrado com SIGACOM, se positivo, verifica se a moeda está cadastrada corretamente
   bGravaPO := {|| if(ConfMoeda(M->W2_MOEDA),Eval({|| nOpcao:=1,if(DbuPO420B()==0,oDlg:End(),nOpcao:=0)}), ), oMark:oBrowse:Refresh()}
   bAltDatas:= {|| PO420AlteraDatas(), oMark:oBrowse:Refresh() }
   //bOrdena  := {|| PO400OrdenaItens(nOpca,nOpcAux), oMark:oBrowse:Refresh() }

   //@16,(oDlg:nClientWidth-4)/2-40 BUTTON STR0091 SIZE 34,11 FONT oDlg:oFont ACTION (Eval(bGravaPO)) OF oPanel PIXEL //"Grava P.O." - identidade visual - mesma operação que a ação SALVAR
   If cProg#"PN"
      //@28,(oDlg:nClientWidth-4)/2-40 BUTTON STR0092  SIZE 34,11 FONT oDlg:oFont ACTION (Eval(bAltDatas)) OF oPanel PIXEL //"Alt.Datas" //LGS-24/10/13 - identidade visual
      AAdd(aBtnsT4, {, bAltDatas, STR0412, STR0412})//"Alterar Datas"
   EndIf
   IF !lNewTelaSI//IGOR CHIBA 25/0714
      //@40,(oDlg:nClientWidth-4)/2-40 BUTTON STR0379 SIZE 34,11 FONT oDlg:oFont ACTION (Eval(bOrdena)) OF oPanel PIXEL //LGS-23/10/13-"Ordena Itens" - identidade visual
      //AAdd(aBtnsT4, {, bOrdena, STR0379, STR0379})//"Ordenar Itens"
      
      aAdd(aBtnsT4,{/*<Resource (Depreciado)>*/,/*<Action>*/, STR0379,STR0379,,,GetOrders(oMark:oBrowse)} )
   ENDIF
   oDlg:lMaximized:=.T.

   If nOpcAux # 5 .AND. lRegTriPO
      // Apenas se não for ESTORNO
      AADD(aBtnsT4, {"PRECO" ,{|| PO400RegPesq() },STR0411, STR0411}) //"Regime de Tributacao","Reg.Trib."// JWJ 21/10/09
   Endif

   oPanel:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oMark:oBrowse:Refresh() //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   //DFS - 31/01/13 - Inclusão de refresh na tela.
   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bGravaPO,bCancel,,aBtnsT4),oMark:oBrowse:Refresh()) //LRL 19/03/04 -Alinhamento MDI //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
Else

   if(ConfMoeda(M->W2_MOEDA))
      nOpcao:= 1
     if DbuPO420B() <> 0
        nOpcao:=0
        lRet:= .F.
      endif
   endif

Endif
   nOpcPonto := nOpcao //LRS - 11/08/2015
   IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"APOS_CONFERENCIAFINAL"),)

   Work->(DBSETORDER(nOrder))

   IF MControla
      SET FILTER TO
      DBGOTO(MRecno)
      nRetorno:= 2
   ELSE
      MControle:= .F.
      nRetorno := 0
      DBSELECTAREA("Work")
      //ZAP
      AvZap("Work")
   ENDIF

RETURN nRetorno

*----------------------------------------------------------------------------
Function PO_ValidCC(lValidCC)
*----------------------------------------------------------------------------
LOCAL _LIT_CC := AVSX3("W0__CC")[5]

SW0->(DBSetOrder(1))

IF lValidCC
   Return .T.
Endif
IF EMPTY( TCc )
   Help("", 1, "AVG0000326",,_LIT_CC,2,1) //MsgInfo(_LIT_CC + STR0093,STR0067) //' da solicitação não informado'###"Informação"
   Return .F.
ENDIF

IF !SY3->(DbSeek( xFilial("SY3") + TCC  )) .Or. ( !SW0->(DBSEEK(xFilial()+TCC)) .AND. !lCopiaPO )
   Help("", 1, "AVG0000327",,_LIT_CC,2,1)//MsgInfo(_LIT_CC+STR0208+STR0094,STR0067) //" não cadastrado"###"Informação"
   Return .F.
ENDIF

Return .T.
*----------------------------------------------------------------------------
Function PO_ValidSI(lValidSI,lAltera)
*----------------------------------------------------------------------------
LOCAL   cSolic:=TSi_Num,nAscan,cCentro:=TCC
Local bExec
Local lRetPeSi := .T.
Local _LIT_CC := AVSX3("W0__CC")[5]  //NCF - 30/11/2017
Default lAltera := .F.    // GFP - 10/04/2013

Private lRetPeSi := .T.

If !IsMemVar("lPoAuto")
   lPoAuto:= .F.
EndIf

IF !lValidSI
   lSiCopia:=.F.
ENDIF
IF lValidSI
   Return .T.
Endif
IF !lNewTelaSI .OR. ( (!EMPTY(ALLTRIM(TSi_Num))) .AND. lNewTelaSI)//JL
   IF EMPTY( TSi_Num )
      Help("", 1, "AVG0000328")//'N£mero da solicita‡Æo nÆo informado'###"Atenção"
      Return .F.
   ELSEIF EMPTY( TCC )
      Help("", 1, "AVG0000326",,_LIT_CC,2,1) //MsgInfo(_LIT_CC + STR0093,STR0067) //' da solicitação não informado'###"Informação"
      Return .F.
   ENDIF
ENDIF
   IF lCopiaPO .and. LEFT(TSi_Num,1)=="*" .AND. !SW0->(DBSEEK(xFilial()+TCC + TSi_Num))//Caso venha de uma Copia "pegar" a Si original(sem a precedencia do caracter '*' )
      lSiCopia:=.T.
      cSolic:=TSi_Num
      IF EMPTY(TSi_Num)
         If !lPoAuto //FSM - 17/05/2012
            Processa({|lEnd| PO400GrW0Hlp()},STR0206 ) //"Gerando Help de S.I."
         EndIf
         WORK_SI->(DBSEEK(cSolic))
         TSi_Num:=WORK_SI->WKSI_ORI
      ELSE
         TSi_Num:=cSiOri
         TCC:=cCentro
      ENDIF

      IF (nAscan:=ASCAN(aSolic,{|a|a[1]+a[2]=AvKey(TSi_Num,"W0__NUM")+TCC}))==0
         Help("", 1, "AVG0000329")//'Solicitação não cadastrada'###"Informação"
         TSi_Num:=cSolic
         TCC:=cCentro
         RETURN .F.
      ENDIF

      cCentro:=TCC
      TCC:=aSolic[nAscan,3]
   ENDIF

   //TRP - 22/05/2007
   If EasyEntryPoint("EICPO400")
      ExecBlock("EICPO400",.F.,.F.,"VALIDA")
      If !lRetPeSi         
         Return .F.
      EndIf
   EndIf
   DBSELECTAREA("SW0")
   IF !lNewTelaSI//JL
      IF !DBSEEK(xFilial()+AvKey(TCC,"W0__CC") + AvKey(TSi_Num,"W0__NUM")) .OR. (cProg#"PN".AND.!EMPTY(ALLTRIM(SW0->W0_HAWB_DA)))  // GFP - 23/08/2013
         Help("", 1, "AVG0000329")//'Solicitação não cadastrada'###"Informação"
         TSi_Num:=cSolic
         TCC:=cCentro
         Return .F.
      ENDIF
   ENDIF

   /*  Nopado por GFP - 27/05/2013 - Sistema deve permitir alteração de moeda do processo.
   If nOpcAux != INCLUIR .Or. !lSiReferencia
      If !Empty(SW0->W0_MOEDA) .And. M->W2_MOEDA != SW0->W0_MOEDA
         Help("", 1, "AVG0000330")//"Moeda da Solicita‡Æo ‚ diferente da moeda do Pedido."###"Atenção"
         TSi_Num:=cSolic
         TCC:=cCentro
         lMoeda:= .F.//TDF - 19/10/2010
         Return .F.
      Endif
   EndIF
   */
   IF lRdMake
      ExecBlock("EICPPO02",.F.,.F.,"8")
   Endif

   IF lNec
      nExecute:="1"
      IF !ExecBlock(cArqRdmake,.F.,.F.)
         Return .F.
      ENDIF
   ENDIF

   /* SoftLock usado para o tratamento de cópia de P.O., recurso
   esse que não estará disponível na integração via EAI*/
   If !AvFlags("EIC_EAI")
      IF ! SoftLock("SW0")
         Return .F.
      ENDIF
   EndIf

   IF lSiCopia
      TSi_Num:=cSolic
      TCC:=cCentro
      RETURN .T.
   ENDIF

   DBSELECTAREA("SW1")
   SW1->(DBSETORDER(1))
   IF !lNewTelaSI .OR. ( (!EMPTY(ALLTRIM(TSi_Num))) .AND. lNewTelaSI )//JL
      SW1->(DBSEEK(xFilial("SW1")+AvKey(TCC,"W1_CC") + AvKey(TSi_Num,"W1_SI_NUM") + IIF(lPOAuto .And. !Empty(TW1_REG), TCod_i + Str(TW1_REG, 4, 0),"")))  // GFP - 23/08/2013
   ELSE
      SW1->(DBSEEK(xFilial("SW1")+AvKey(TCC,"W1_CC") ))
   ENDIF
   MCont:= 0


   If !lPOAuto
      MsAguarde({|lEnd| PO_PesqSI({|msg| MsProcTxt(msg)},lAltera)},STR0098) //"Pesquisando Itens da S.I."   // GFP - 10/04/2013
   Else
      bExec:= {|lEnd| PO_PesqSI(,lAltera)}   // GFP - 10/04/2013
      Eval(bExec)
   Endif


   DBSELECTAREA("Work")
   IF MCont = 0
      Help("", 1, "AVG0000331",,IF(lPOdaIntegracao, STR0100,""),2,14) //'Nao ha itens desta solicitacao a serem selecionados'
      SET FILTER TO
      Return .F.
   ENDIF
//ENDIF
Return .T.

*----------------------------------------------------------------------------
Function PO_PesqSI(bMsg,lAltera)
*----------------------------------------------------------------------------
LOCAL cFilSW1 := xFilial("SW1")
LOCAL aOrdA5:= {}
LOCAL cKey_SYG := " "
Local bWhile
Local lCotacao
Local cAgrupador:= ""
Default lAltera := .F.   // GFP - 10/04/2013
Private lLoop := .F. // DFS - 02/02/11 - Variavel para controlar os itens que devem ser apresentados através de customização

aFornSW1 := {}
SB1->(DbSetOrder(1))
SA5->(DbSetOrder(3))
SWS->(DbSetOrder(2))
SWT->(DbSetOrder(1))//(2))   // Nopado por GFP - 14/06/2013 - Indices 1 e 2 da tabela SWT ficam iguais após execução do UILOJAEIC
Work->(DBSETORDER(1))
DBSELECTAREA("SW1")

PRIVATE lMarcaItem:=.F.//AWR - 27/10/2004
/* GFP - 17/04/2013
If !lAltera .AND. !(Work->(Bof()) .AND. Work->(Eof()))
   Work->(avzap())
EndIf
*/
If Type("cAgrSIPO") == "C"
   cAgrupador:= cAgrSIPO
Else
   cAgrSIPO:= ""
EndIf

If !IsMemVar("lPOAuto")
   lPOAuto:= .F.
EndIf

IF !lNewTelaSI .OR. ( (!EMPTY(ALLTRIM(TSi_Num))) .AND. lNewTelaSI )//JL
   If lPOAuto .And. !Empty(TW1_REG)
      bWhile := {||!SW1->(EOF()) .AND. SW1->W1_CC == TCc .AND. SW1->W1_SI_NUM == TSi_Num .And. SW1->W1_FILIAL == cFilSW1 .And. SW1->W1_COD_I == TCod_i .And. SW1->W1_REG == TW1_REG }
   Else
      bWhile := {||!SW1->(EOF()) .AND. SW1->W1_CC = TCc .AND. SW1->W1_SI_NUM = TSi_Num .And. SW1->W1_FILIAL == cFilSW1 }
   EndIf
ELSE
    bWhile := {|| !SW1->(EOF()) .AND. SW1->W1_CC = TCc .And. SW1->W1_FILIAL == cFilSW1 }
ENDIF

//AHAC - 05/08/2014 - Correção Filtro SI - Deleta não marcados do filtro anterior

If !lPOAuto
   Work->(DBGOTOP())
   DO WHILE Work->(!EOF())
      If(EMPTY(Work->WKFLAGWIN))
         //Work->(DBDELETE())
         Work->DBDELETE := .T. //MCF - 05/05/2015
      ELSE
         MCont++//Conta os marcados
      EndIf
      WORK->(DBSKIP())
   ENDDO
EndIf

DO WHILE EVAL(bWhile)

   If !lPOAuto
      Eval(bMsg,STR0101+ALLTRIM(SW1->W1_COD_I)) //"Processando Item: "
   Endif

   lMarcaItem:=.F.

   IF Work->(DBSEEK(SW1->W1_CC+SW1->W1_SI_NUM+SW1->W1_COD_I+STR(SW1->W1_REG,AVSX3("W1_REG",3),0)/*+SW1->W1_POSIT*/)) // GFP - 03/08/2015 //NCF - 08/12/2015 - (Nopado) - Deve controlar pelo W3_REG
      MCont:= MCont + 1
      //CCH - 12/08/2009 - Verifica se o fornecedor do item é igual ao fornecedor da capa.
      //    - Em caso positivo, mantém o item marcado, caso contrário será desmarcado.
      If lPOAuto  // GFP - 06/12/2013
         If WORK->WKCOD_I == SW1->W1_COD_I
            WORK->WKQTDE := SW1->W1_QTDE
         EndIf
      EndIf
      If !Empty(Work->WKFORN) .and. !Empty(Work->W3_FORLOJ) .and. Work->WKFLAG == .T.
         If !Empty(M->W2_FORN) .AND. !Empty(M->W2_FORLOJ) .and. (Alltrim(M->W2_FORN) <> Alltrim(Work->WKFORN) .or. (Alltrim(Work->W3_FORLOJ) <> Alltrim(M->W2_FORLOJ)))
            MsgInfo(STR0304 +CHR(13)+CHR(10)+; //STR0304 = "O Fornecedor da capa foi alterado após a inclusão e marcação de itens!"
                    STR0305) //STR0305 = "Serão desmarcados todos os itens com fornecedores diferentes do Fornecedor da capa"
            Work->WKFLAG := .F.
            Work->WKFLAGWIN := Space(2)
         EndIf
      EndIf
      SW1->(DBSKIP())
      LOOP
   ENDIF

   IF SW1->W1_SEQ <> 0 .OR. SW1->W1_SALDO_Q == 0
      SW1->(DBSKIP())
      LOOP
   ENDIF

   IF lRdMake
      ExecBlock("EICPPO02",.F.,.F.,"9")
   ENDIF

   IF lNec
      nExecute:="13"
      IF !ExecBlock(cArqRdmake,.F.,.F.)
         LOOP
      ENDIF
   ENDIF
   IF lPOdaIntegracao  .OR. (lCancelaSaldo .AND. EasyEntryPoint("IC086PO1"))//AWR 18/02/99
      SW1->(DBSKIP())
      LOOP
   ENDIF
   IF lSIReferencia
      IF !EMPTY(SW1->W1_FORN) .AND. !Empty(SW1->W1_FORLOJ) .AND. (SW1->W1_FORN <> M->W2_FORN .or. (SW1->W1_FORLOJ <> M->W2_FORLOJ))
         SW1->(DBSKIP())
         LOOP
      ENDIF
   ENDIF

   /* AAF - 14/05/2013 - Não pode ser validado no padrão pois tira a possibilidade de alterar o fornecedor no PO.

   // GFP - 12/04/2013 - Apenas os itens com mesmo fornecedor podem ser exibidos para vinculação.
   If !Empty(SW1->W1_FORN) .And. !(M->W2_FORN == SW1->W1_FORN .AND. If(EICLOJA(), !Empty(SW1->W1_FORLOJ) .And. M->W2_FORLOJ == SW1->W1_FORLOJ,.T.))
      SW1->(DBSKIP())
      LOOP
   EndIf

   */

   IF lNewTelaSI //JL
      IF !lPO400FIL  //IGOR CHIBA 18/07/14 SE CANCELOU PERGUNTE IGNORAR TD
         SW1->(DBSKIP())
         LOOP
      ENDIF

      IF AvFlags("EIC_EAI") .AND. !EMPTY(SW1->W1_C3_NUM)
         cCotacao := "3"
      ENDIF
      IF (cCotacao == "1")
         IF (EMPTY(SW1->W1_NR_CONC))
            SW1->(DBSKIP())
            LOOP
         ENDIF
         IF !SWT->(DBSEEK(xFilial("SWT")+SW1->W1_NR_CONC+SW1->W1_COD_I))
            EasyHelp(STR0396,STR0037) //"Item não possui Cotação"###"Atenção"
            SW1->(DBSKIP())
            LOOP
         ELSE

            //WFS 21/08/2014 - apenas cotações aprovadas
            lCotacao:= .F.
            While SWT->(!Eof()) .And. SWT->WT_FILIAL == SWT->(xFilial()) .And.;
                   SWT->WT_NR_CONC + SWT->WT_COD_I == SW1->W1_NR_CONC + SW1->W1_COD_I

               If SWT->WT_STATUS == "3" .And. SWT->WT_SI_NUM == SW1->W1_SI_NUM //aprovada
                  lCotacao:= .T.
                  Exit
               EndIf
               SWT->(DBSkip())
		    EndDo

		    If !lCotacao
		       SW1->(DBSkip())
		       Loop
		    EndIf

           //IF SWT->WT_FORN <> M->W2_FORN .AND. (!EICLOJA() .OR. SWT->WT_FORLOJ <> M->W2_FORLOJ)
           IF SWT->WT_FORN <> M->W2_FORN .Or. (SWT->WT_FORLOJ <> M->W2_FORLOJ) //wfs 23/08/2014
              SW1->(DBSKIP())
              LOOP
           ELSEIF SWT->WT_COD_PAG <> M->W2_COND_PA .AND. SWT->WT_DIASPAG <> M->W2_DIAS_PA
              SW1->(DBSKIP())
              LOOP
           ENDIF
           IF SWT->WT_MOEDA <> M->W2_MOEDA
              SW1->(DBSKIP())
              LOOP
           ENDIF
           IF SWT->WT_INCOTER <> M->W2_INCOTER
              SW1->(DBSKIP())
              LOOP
           ENDIF
         ENDIF

      ENDIF

      //WFS 21/08/2014 - Quando não for cotação aprovada, considerar apenas as cotações que não estão em processo
      //de cotação, caso contrário, será duplicada a cotação no ERP
      If AllTrim(cCotacao) == "2"

         If SW1->W1_STATUS <> "A" //pendente - cotação não iniciada ou não cancelada
            SW1->(DBSkip())
            Loop
         EndIf
      EndIf

      IF AllTrim(cCotacao) == "3"  // Contrato

         If SW1->W1_STATUS <> "G" //Pendente - Contrato
            SW1->(DBSkip())
            Loop
         EndIf

         If !lPoAuto .And. Empty(cAgrupador)//wfs abr/2017 - pergunte da inclusão manual do P.O. - (26/07) o agrupador terá relevância sobre os campos não editáveis, possibilitando a inclusão de novas S.I. do mesmo contrato
            If SW1->W1_FORN <> M->W2_FORN .Or. SW1->W1_FORLOJ <> M->W2_FORLOJ
               SW1->(DBSKIP())
               LOOP
            EndIf

            If SW1->W1_CONDPG <> M->W2_COND_PA
               SW1->(DBSKIP())
               LOOP
            EndIf

            SW0->(DBSetOrder(1)) //W0_FILIAL+W0__CC+W0__NUM
            SW0->(DBSeek(xFilial() + SW1->W1_CC + SW1->W1_SI_NUM))
            If SW0->W0_MOEDA <> M->W2_MOEDA
               SW1->(DBSKIP())
               LOOP
            EndIf
         EndIf

      ENDIF

      IF (!EMPTY(ALLTRIM(cItem))) .AND. ALLTRIM(SW1->W1_COD_I) <> ALLTRIM(cItem)
         SW1->(DBSKIP())
         LOOP
      ENDIF

      If !( AVFlags("EIC_EAI") .And. !Empty(cAgrupador) )  //NCF - 26/09/2016
         IF (!EMPTY(ALLTRIM(TSi_Num))) .AND. ALLTRIM(SW1->W1_SI_NUM) <> ALLTRIM(TSi_Num)
            SW1->(DBSKIP())
            LOOP
         ENDIF
      EndIf

   ENDIF
   //DFS - 02/02/11 - Inclusão de ponto de entrada para que seja definido os itens que devem aparecer na seleção de itens no PO.
   lLoop := .F.
   If (EasyEntryPoint("EICPO400"), EXECBLOCK("EICPO400",.F.,.F.,"PO_PesqSI_Sel"),)
   If lLoop
      SW1->(DbSkip())
      Loop
   Endif

   If AVFlags("EIC_EAI")                        //NCF - 26/09/2016
      If !Empty(cAgrSIPO) //wfs
         If AllTrim(SI410GtAgp(SW1->W1_SI_NUM)) <> AllTrim(cAgrSIPO)
            SW1->(DbSkip())
            Loop
         EndIf
      EndIf
   EndIf

   // EOS OS 486/02 alimenta uma array com os fornecedores da SI.
   IF ASCAN( aFornSW1, SW1->W1_FORN ) == 0
      AADD( aFornSW1 , {SW1->W1_FORN,SW1->W1_FORLOJ} )
   ENDIF

   //FDR - 14/12/2011 - Validação dos campos de Fornecedor/Fabricante + Loja
   If !Empty(SW1->W1_FABR) .AND. !Empty(SW1->W1_FABLOJ) .AND. !ExistCpo('SA2',SW1->W1_FABR + SW1->W1_FABLOJ)
      MsgInfo(STR0370)//"O fabricante utilizado neste processo encontra-se bloqueado para uso."
      Exit
   Endif

   Work->(DBAPPEND())
   Work->WKFLAG2    := .F.
   Work->WKFLAGWIN2 := Space(AVSX3("W2_OK",3))
   Work->WKCOD_I    := SW1->W1_COD_I
   Work->WKPOSIT    := SW1->W1_POSIT   //LGS-24/10/2013
   
   Work->WKFABR := IF(SW1->W1_FORN==M->W2_FORN .Or. Empty(M->W2_FORN),SW1->W1_FABR,"")
   Work->W3_FABLOJ := IF(SW1->W1_FORLOJ==M->W2_FORLOJ .Or. Empty(M->W2_FORLOJ),SW1->W1_FABLOJ,"")

   if !lSIReferencia // sempre que for SI de referência é feito o loop na linha 4523
      if !empty(SW1->W1_FORN) .and. (SW1->W1_FORN<>M->W2_FORN .or. SW1->W1_FORLOJ<>M->W2_FORLOJ )
         Work->W3_FABLOJ := ""
      endif
   endif

   Work->WKFORN     := IF(SW1->W1_FORN==M->W2_FORN .Or. Empty(M->W2_FORN),SW1->W1_FORN,"")
   Work->W3_FORLOJ := IF(SW1->W1_FORLOJ==M->W2_FORLOJ .Or. Empty(M->W2_FORLOJ),SW1->W1_FORLOJ,"")
   
   Work->WKFABR_O   := Work->WKFABR
   Work->WKFORN_O   := Work->WKFORN
   Work->W3_FABL_O := Work->W3_FABLOJ
   Work->W3_FORL_O := Work->W3_FORLOJ
   Work->WKFLUXO    := SW1->W1_FLUXO
   Work->WKQTDE     := SW1->W1_SALDO_Q  //SW1->W1_QTDE  // By JPP - 12/05/2009
   Work->WKQTDE_O   := 0 //Work->WKQTDE
   Work->WKSALDO_Q  := 0 //SW1->W1_SALDO_Q
   Work->WKSALDO_O  := 0 //SW1->W1_SALDO_Q
   Work->WKSI_NUM   := SW1->W1_SI_NUM
   Work->WKPO_NUM   := SW1->W1_PO_NUM
   Work->WKCDPOCOPY := SW1->W1_PO_NUM
   Work->WKCC       := SW1->W1_CC
   Work->WKREG      := SW1->W1_REG       // para versao siga a posi‡Æo
   Work->WKREC_SI   := SW1->(RECNO())    // ser  gerada no p.o.
   Work->WKPOSICAO  := SW1->W1_POSICAO   && Alterado por RJB - 15:49 24 Mar,1995
   Work->WKPSPOCOPY := SW1->W1_POSICAO
   Work->WKDTEMB_S  := SW1->W1_DT_EMB
   Work->WKDT_EMB   := SW1->W1_DT_EMB
   Work->WKDT_ENTR  := IF(cCotacao == "1" .AND. lNewTelaSI,SWT->WT_DT_FORN,SW1->W1_DTENTR_)//JL
   Work->WKPRECO    := IF(cCotacao == "1" .AND. lNewTelaSI,SWT->WT_VL_UNIT,SW1->W1_PRECO)//JL
   Work->WKSEM_PO   := SW1->W1_SALDO_Q  // JBS - 03/02/2004
   Work->TRB_ALI_WT := "SW1"
   Work->TRB_REC_WT := SW1->(Recno())
   IF AvFlags("EIC_EAI")//AWF - 25/06/2014
      Work->WKUNI     :=BUSCA_UM(,WORK->WKCC+WORK->WKSI_NUM)
      SA5->(DBSETORDER(1))//A5_FILIAL+A5_FORNECE+A5_LOJA+A5_PRODUTO
      IF SA5->(DBSEEK(xFILIAL("SA5")+M->W2_FORN+M->W2_FORLOJ+Work->WKCOD_I ))
         Work->WKSEGUM:=SA5->A5_UNID
      ENDIF
      Work->WKQTSEGUM :=AVTransUnid(Work->WKUNI,Work->WKSEGUM,Work->WKCOD_I,Work->WKQTDE,,,,M->W2_FORN,M->W2_FORLOJ)
      Work->WKFATOR   :=Work->WKQTSEGUM/Work->WKQTDE
      If SW0->(FieldPos("W0_REFER1")) > 0  //NCF - 26/09/2016
         Work->WKREFER1 := SI410GtAgp(SW3->W3_SI_NUM)
      EndIf
   ENDIF

  //DFS - 02/09/09 - Tratamento para trazer do cadastro de produtos o Peso Líquido ao incluir um item com o mesmo produto.
   If SW3->(FieldPos("W3_PESOL")) # 0 .AND. SB1->(dbSeek(xFilial("SB1") + SW1->W1_COD_I))//TDF - 05/11/12 - Posiciona no cadastro de produtos
      Work->WKPESOL := B1Peso(SW1->W1_CC,SW1->W1_SI_NUM ,SW1->W1_COD_I,SW1->W1_REG,SW1->W1_FABR, M->W2_FORN /*SW1->W1_FORN*/ , EICRetLoja("SW1", "W1_FABLOJ"), M->W2_FORLOJ/*EICRetLoja("SW1","W1_FORLOJ")*/)
   Endif

   If lCpoCtCust                           //NCF - 22/06/2010 - Campo do centro de Custo
      Work->WKCTCUSTO := SW1->W1_CTCUSTO
   EndIf

   //TRP- 01/06/09 - Campo Software para novo Tratamento de Mídia e Software
   If SW3->(FieldPos("W3_SOFTWAR")) # 0 .And. EasyGParam("MV_CONSOFT",, "N") $ cSim
       Work->WKSOFTWAR:= "2"
   Endif
   //NCF - 25/08/2011 - Campo do Peso Bruto Unitário
   If lPesoBruto
      Work->WKPSBRUTO := SB1->B1_PESBRU
   EndIf

   IF EMPTY(Work->WKPRECO)
      SA5->(DBSETORDER(3))
      IF !EMPTY(Work->WKFABR)
         //SA5->(DBSEEK(xFILIAL("SA5")+Work->WKCOD_I+Work->WKFABR+Work->WKFORN ))
         IF EICSFabFor(xFilial("SA5")+Work->WKCOD_I+Work->WKFABR+Work->WKFORN, EICRetLoja("Work", "W3_FABLOJ"), EICRetLoja("Work", "W3_FORLOJ"))
            IF SA5->A5_MOE_US == M->W2_MOEDA // TLM 24/06/08
               Work->WKPRECO   := SA5->A5_VLCOTUS
            EndIf
         ENDIF
      ELSE
         SA5->(DBSETORDER(2))
         SA5->(DBSEEK(xFILIAL("SA5")+Work->WKCOD_I+M->W2_FORN+EICRetLoja("M","W2_FORLOJ")))
         IF SA5->A5_MOE_US == M->W2_MOEDA  // TLM 24/06/08
            Work->WKPRECO   := SA5->A5_VLCOTUS
         EndIf
      ENDIF
   ENDIF

   If SW3->(FieldPos("W3_PART_N")) # 0 //ASK 02/10/2007
      If !Empty(Work->WKPART_N)
         SA5->(DbSetOrder(3))
         //SA5->(DbSeek(xFILIAL("SA5")+Work->WKCOD_I+Work->WKFABR+Work->WKFORN ))
         IF EICSFabFor(xFilial("SA5")+Work->WKCOD_I+Work->WKFABR+Work->WKFORN, EICRetLoja("Work", "W3_FABLOJ"), EICRetLoja("Work", "W3_FORLOJ"))
            Work->WKPART_N   := SA5->A5_CODPRF
         ENDIF
      Else
         aOrdA5 := SaveOrd({"SA5"})
         SA5->(DbSetOrder(3))
         IF EICSFabFor(xFilial("SA5")+Work->WKCOD_I+Work->WKFABR+Work->WKFORN, EICRetLoja("Work", "W3_FABLOJ"), EICRetLoja("Work", "W3_FORLOJ"))
            Do While SA5->(!EOF()) .And. SA5->A5_FILIAL = xFilial("SA5") .And. SA5->A5_PRODUTO == Work->WKCOD_I .AND. SA5->A5_FORNECE == Work->WKFORN .AND. SA5->A5_FABR == Work->WKFABR
               If Work->W3_FABLOJ == SA5->A5_FALOJA .AND. Work->W3_FORLOJ == SA5->A5_LOJA
                  Work->WKPART_N   := SA5->A5_CODPRF
                  Exit
               Endif
               SA5->(DbSkip())
            Enddo
         ENDIF
         RestOrd(aOrdA5,.T.)

      EndIf
   EndIf

   IF !EMPTY(M->W2__NR_COT) .AND.;//AWR 4/1/05
      SWS->(DBSEEK(xFilial("SWS")+SW1->W1_CC+SW1->W1_SI_NUM+SW1->W1_COD_I)).AND.;
      SWT->(DBSEEK(xFilial("SWT")+SWS->WS_NR_CONC+SW1->W1_COD_I+M->W2_FORN+EICRetLoja("M","W2_FORLOJ")))

//    Work->WKDT_ENTR := SWS->WS_DTNECES //AWR 4/1/05
      IF !EMPTY(SWT->WT_DT_FORN)
//       Work->WKDT_EMB  := SWT->WT_DT_FORN //AWR 4/1/05
         Work->WKDT_ENTR := SWT->WT_DT_FORN
      ENDIF

      IF !EMPTY(SWT->WT_FOB_UNI) .AND. SWT->WT_MOEDA == M->W2_MOEDA
         Work->WKPRECO:= SWT->WT_FOB_UNI
      ENDIF

   ENDIF
   IF lRdMake
      ExecBlock("EICPPO02",.F.,.F.,"10")
   ENDIF

   IF lNec
      nExecute:="4"
      ExecBlock(cArqRdmake,.F.,.F.)


   ENDIF

   IF(lNobel, ExecBlock("IC163PO1",.F.,.F.),)//Preenche: o fabricante, a quatidade, a dt. embarque, a dt. entrega e o preco, se estirem em branco

   IF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"12"),)//AWR 09/11/1999

   Work->WKDTENTR_S:= Work->WKDT_ENTR
   Work->WKPRECO_S := Work->WKPRECO
   Work->WKPRTOT   := DI500TRANS(Work->WKPRECO*Work->WKQTDE,2)//JVR / 28/10/2009 - DI500TRANS()

   If lForeCast
      Work->WK_FORECAS := SW1->W1_FORECAS
   Endif

   IF(EasyEntryPoint("EICPO400"),EXECBLOCK("EICPO400",.F.,.F.,"ANTES_MARCA_ITEM"),)//AWR - 27/10/2004
   SA5->(DbSetOrder(3)) //SVG - 01/12/08
   IF !EMPTY(SW0->W0_SIKIT) .OR. lNobel .OR. lMarcaItem//AWR - 27/10/2004
      IF !MExiste .AND. !EMPTY(Work->WKDT_EMB) .AND. !EMPTY(Work->WKDT_ENTR) .AND.;
         !EMPTY(Work->WKPRECO).AND.!EMPTY(Work->WKFABR).AND.;//!EMPTY(Work->WKQTDE).AND.
         SA5->(DBSEEK(xFilial()+Work->WKCOD_I+Work->WKFABR+Work->WKFORN))
         Work->WKFLAG    := .T.
         Work->WKFLAGWIN := cMarca
         Work->WKQTDE    := Work->WKSEM_PO// AWR 27/10/2004
         Work->WKSALDO_Q := Work->WKQTDE  // AWR 27/10/2004
         Work->WKSEM_PO  := 0             // AWR 27/10/2004
      ENDIF

      IF !EMPTY(SW0->W0_SIKIT)
         Work->WKKIT    := SW0->W0_SIKIT
         Work->WKSERIE  := SW0->W0_KITSERI
         Work->WKQTDKIT := SW0->W0_QTDE
         MForn          := SW1->W1_FORN
         MLoja       := SW1->W1_FORLOJ
      EndIF

   ENDIF

   IF ! MExiste .And. ! EMPTY(Work->WKFLAGWIN) .AND. cProg#"PN"
      MTotal  +=VAL(STR(Work->WKQTDE*Work->WKPRECO,15,2))
      MFob_Abs+=VAL(STR(Work->WKQTDE*Work->WKPRECO,15,2))
   ENDIF

   E_ItFabFor(cDESC_PO,,"PO")  // posiciona SB1, atualiza descricao do item ###,
                    // nome reduzido do fabricante e do fornecedor

   IF lExiste_Midia         .AND.;
      !EMPTY(M->W2_VLMIDIA) .AND.;
      SB1->B1_MIDIA $ cSim
      Work->WK_QTMIDIA := SB1->B1_QTMIDIA
      Work->WK_VLTOTMI := SB1->B1_QTMIDIA * M->W2_VLMIDIA*Work->WKQTDE
   ENDIF

   IF !EMPTY(Work->WKFABR)
      If cKey_SYG != Work->WKFABR+SW1->W1_COD_I
         cKey_SYG := Work->WKFABR+SW1->W1_COD_I
         SYG->(DBSEEK(xFilial()+M->W2_IMPORT+Work->WKFABR+EICRetLoja("Work","W3_FABLOJ")+SW1->W1_COD_I))
      Endif
      Work->WK_REG_MIN := SYG->YG_REG_MIN
   ENDIF

   Work->WKFLUXO:=If(SB1->B1_ANUENTE $ cSim,"1","7")
   Work->WK_ALTEROU := .T. // Qdo vem do SW1, ALTEROU TRUE para gravar.
   Work->WK_REG_TRI := M->W2_REG_TRI
   Work->WK_TEC     := SB1->B1_POSIPI
   Work->WK_EX_NCM  := SB1->B1_EX_NCM
   Work->WK_EX_NBM  := SB1->B1_EX_NBM
   IF cPaisLoc # "BRA"  .AND. SW1->(FIELDPOS("W1_NATUREZ")) # 0
      Work->WKNATUREZA:= SW1->W1_NATUREZ
   ENDIF

   IF EasyEntryPoint("EICPO400")
     ExecBlock("EICPO400",.F.,.F.,"GRV_WORK_COM_SW1")
   ENDIF

   SW1->(DBSKIP())
   MCont:= MCont + 1
ENDDO

SWS->(DbSetOrder(1))
SWT->(DbSetOrder(1))

Return .T.

*----------------------------------------------------------------------------
FUNCTION DbuPo420B()
*----------------------------------------------------------------------------
LOCAL ErroPO, nLastKey
LOCAL cPointE:="EICPO01E", cPointS:="EICPO01S"
LOCAL lPointE:=EasyEntryPoint(cPointE), lPointS:=EasyEntryPoint(cPointS)
Local _PictPC   := AllTrim(X3Picture("C7_NUM"))
LOCAL aOrdAut
Local i
LOCAL lRet:= .T.
LOCAL nPOsC, nPOSi , cCCusto, nInc , cFilSW0
LOCAL lRetYN:= .F.
//FSM - 21/05/2012
Local aAuxCab := {}
Local aAuxDet := {}
Local nTentNumPO := 0
Local cQuery
Private lGravaPO := Nil //FSY - 19/09/2013 - Variavel usado para retorno do ponto de entrada
PRIVATE MRecno   := Work->( RECNO() ), MRetorno := 1
Private lRetExecAuto:= .T.
//Work->(DBSETORDER(1))
Work->(dbGoTOp())
IF .NOT. (WORK->(!Bof()) .AND. WORK->(!Eof())) .OR. .NOT. ( MExiste .OR. MTotal > 0 )  // GFP - 30/09/2013
   If MTotal = 0
      Help(" ",1,"PO400FOB0")
      //E_Msg("Total igual a zero",1000,.T.)
   endif
   RETURN 1
ENDIF
IF EasyEntryPoint("IC086PO1")
   IF ExecBlock("IC086PO1",.F.,.F.,2)
      RETURN 1
   ENDIF
ENDIF

IF(EasyEntryPoint("EICPO400"),EXECBLOCK("EICPO400",.F.,.F.,"INICIO_GRAVA"),) // JS 30-06-05

ErroPO := .F.
Work->( DBGOTOP() )
Work->( DBEVAL({||IF(Work->WKPRECO=0,ErroPO:=.T.,.F.)},;
               {||!EMPTY(Work->WKKIT)} ) )
Work->( DBGOTO(MRecno) )
///TDF - 19/10/2010 - Força integração da moeda no compras, quando houver alteração da moeda do PO.
SW2->(dbSetOrder(1)) //"W2_FILIAL + W2_PO_NUM
If SW2->(DBSEEK(xFilial()+ M->W2_PO_NUM))
   If M->W2_MOEDA != SW2->W2_MOEDA
      Work->WK_ALTEROU := .T.
   EndIf
EndIf

//ISS - 24/02/11 - Força integração com o compras quando dos campos de despesa for alterado.
If ChkAltDesp()
   Work->WK_ALTEROU := .T.
EndIf

IF ErroPO
   Help("", 1, "AVG0000332")//"Itens com valor unit rio Zerado"###"Atenção"
   RETURN 2
ENDIF

MTotFOB := MTotal + TInland + TFreteIntl + TPacking + TOutDesp + TSeguro - TDesconto

//IF MTotFOB <= 0
/*ISS - 25/11/10 - Gravação dos campos alterados pela função PO420Cha nas variáveis de memória, assim gravando essas alterações caso
                   seja confirmada a gravação. */
IF !(MTotFOB > 0)  //NCF - 06/04/2011 - Alterada a Validação para permitir qualquer valor de FOB maior que 0.00
   //Help("", 1, "AVG0000333",,IF(M->W2_FREPPCC=="PP",STR0104," "),2,18)//MsgInfo(STR0103+IF(M->W2_FREPPCC=="PP",STR0104," "),STR0037) //"Desconto não pode ser maior que F.O.B + INLAND + PACKING "###"+ FRETE"###"Atenção"
   MsgInfo(STR0292 + If(M->W2_FREPPCC=="PP",", FRETE.","."),STR0037)//STR0292 -"O valor de desconto não pode ser maior ou igual do que o montante das taxas FOB, INLAND, PACKING"
   IF ! PO420Cha(MTotal,"I",,M->W2_FREPPCC)
      M->W2_INLAND  := TInland
      M->W2_OUT_DES := TOutDesp
      M->W2_FRETEIN := TFreteIntl
      M->W2_PACKING := TPacking
      M->W2_DESCONT := TDesconto
      If AvFlags("RATEIO_DESP_PO_PLI")
         M->W2_SEGURIN := TSeguro
      EndIf
      RETURN 1
   ENDIF
   M->W2_INLAND  := TInland
   M->W2_OUT_DES := TOutDesp
   M->W2_FRETEIN := TFreteIntl
   M->W2_PACKING := TPacking
   M->W2_DESCONT := TDesconto
   If AvFlags("RATEIO_DESP_PO_PLI")
      M->W2_SEGURIN := TSeguro
   EndIf
ENDIF

If ( Type("lPOAuto") == "U" .OR. !lPOAuto )

   lRetYN:= MsgYesNo(STR0034,STR0105) //'Confirma a Gravação ? '###'Fechamento'

   //*FSY - 19/09/2013 - Ponto de entrada para validaçao customizado
   If(EasyEntryPoint("EICPO400"),EXECBLOCK("EICPO400",.F.,.F.,"VAL_GRAVA_PO"),)
   If  Type("lGravaPO") == "L"
      lRetYN := lGravaPO
   End If
   //*FSY - 19/09/2013

Else
   lRetYN:= .T.
Endif

//FSM - 21/05/2012
If Type("lPOAuto") == "L" .And. lPOAuto
   aAuxCab := aCabAuto
   aAuxDet := aCabItem
EndIf

If lRetYN # .T.
   MRetorno := 1

ELSEIf lPointE .And. !ExecBlock(cPointE)
   MRetorno := 1
ELSE

//MJB150999    AFILL(TabSI_Num,SPACE(06))
//MJB150999    AFILL(TabSI_Dt,AVCTOD(SPACE(08)))

//FSM - 21/05/2012
If Type("lPOAuto") == "L" .And. lPOAuto
   aCabAuto := aAuxCab
   aCabItem := aAuxDet
EndIf

  IF !MExiste .AND. cMV_EASY $ cSim // ALEX, 27/05/1999 , para gerar numero automatico
      M->W2_PO_SIGA := GetNumSC7(.T.)//GetSxeNum("SC7")//AWR 9/6/99
      TPO_SIGA      := M->W2_PO_SIGA
      // TDF - 19/04/10 - ACERTA TAMANHO DO Nº DO TÍTULO.
      TPO_SIGA := Replicate("0",TamSX3("E2_NUM")[1]-Len(Alltrim(TPO_SIGA)))+Alltrim(TPO_SIGA)
   ENDIF

   IF !MExiste .AND. EasyGParam("MV_NRPO",,'N') $ cSim
      IF cMV_EASY $ cSim
         TPO_NUM     := M->W2_PO_SIGA
         M->W2_PO_NUM:= M->W2_PO_SIGA
      ELSE
        cQuery := "SELECT MAX(W2_PO_NUM) AS C7_NUM FROM "+RetSqlName("SW2")+" WHERE D_E_L_E_T_ = ' ' AND ( ";
        + "replace(w2_po_num,' ','') like '0_____' or ";
        +"replace(w2_po_num,' ','') like '1_____' or ";
        +"replace(w2_po_num,' ','') like '2_____' or ";
        +"replace(w2_po_num,' ','') like '3_____' or ";
        +"replace(w2_po_num,' ','') like '4_____' or ";
        +"replace(w2_po_num,' ','') like '5_____' or ";
        +"replace(w2_po_num,' ','') like '6_____' or ";
        +"replace(w2_po_num,' ','') like '7_____' or ";
        +"replace(w2_po_num,' ','') like '8_____' or ";
        +"replace(w2_po_num,' ','') like '9_____')"
        
         //MFR OSSME-3156 11/06/2019         
         M->W2_PO_NUM:= EasyGetNum(,"SC7","C7_NUM",Padr(FWCodEmp("SW2"),FWSizeFilial())+x2path("SC7"),AvSX3("C7_NUM",AV_TAMANHO),cQuery,.T.)
       //M->W2_PO_NUM:= GetNumSC7(.T.)//GetSxeNum("SC7")
       //  IF(lRdmake,ExecBlock("EICPPO02",.F.,.F.,"NUMSEQPO"),)
         TPO_NUM     := M->W2_PO_NUM
         nTentNumPO := 1                                                      //NCF - 04/10/2016
         Do While SW2->(DBSEEK(xFilial()+TPO_NUM)) .And. nTentNumPO <= 999999
            //MFR OSSME-3156 11/06/2019         
            M->W2_PO_NUM:= EasyGetNum(,"SC7","C7_NUM",Padr(FWCodEmp("SW2"),FWSizeFilial())+x2path("SC7"),AvSX3("C7_NUM",AV_TAMANHO),cQuery,.T.)
            //M->W2_PO_NUM:= GetNumSC7(.T.)
            TPO_NUM     := M->W2_PO_NUM
            nTentNumPO += 1
         EndDo
         If nTentNumPO > 999999
            EasyHelp("Todas as numerações automáticas de pedido disponíveis no range de 0 a 999999 já foram utilizadas!",STR0037)
         EndIf
         nTentNumPO := 0
      ENDIF
  ENDIF

   IF(lRdmake,ExecBlock("EICPPO02",.F.,.F.,"NUMSEQPO"),) // ACB - 08/09/2010
 If ( Type("lPOAuto") == "U" .OR. !lPOAuto )
   IF Inclui
      SW2->(DBSETORDER(1))
      cNumPO := TPO_NUM
      DO WHILE .T.
         IF SW2->(DBSEEK(xFilial()+cNumPO))
            MSGINFO(STR0266,STR0037)

            DEFINE MSDIALOG oDlg_PO FROM 01,01 TO 12,36 TITLE " PO"
               @ 03,03 TO 48,136 LABEL ""        OF oDlg_PO PIXEL
               @ 15,15 SAY "Numero do PO" SIZE 80,8 PIXEL
               @ 15,80 MSGET cNumPO              SIZE 40,8 PIXEL
               @ 57,15 BUTTON "&OK"              SIZE 40,15 ACTION (nOpc_PO:=1,oDLG_PO:End()) OF oDlg_PO PIXEL
               @ 57,85 BUTTON "&Cancelar"         SIZE 40,15 ACTION (nOpc_PO:=0,oDLG_PO:End()) OF oDlg_PO PIXEL
            ACTIVATE DIALOG oDlg_PO CENTERED
            IF nOpc_PO == 1
               TPO_NUM      := cNumPO
               M->W2_PO_NUM := cNumPO
            ELSEIF nOpc_PO == 0
		         RETURN 1
		    ENDIF
	     ELSE
	      	EXIT
	     ENDIF
      ENDDO
   ENDIF

   Endif

   IF(EasyEntryPoint("EICPO400"),EXECBLOCK("EICPO400",.F.,.F.,"GRAVA_PO_PC"),) // RJB SOLICITACAO DO RICARDO SILVA

   EICFI400("ANT_GRV_PO","I")

   IF(EasyEntryPoint("EICPO400"),EXECBLOCK("EICPO400",.F.,.F.,"ANTES_GRAVA_PO"),)

   IF lCopiaPO //Deve-se gerar SI automatica
      If !( Type("lPoAuto")=="L" .And. lPoAuto) //FSM - 17/05/2012
         Processa({|| PO400SIAUTO() })
      Else
         PO400SIAUTO()
      EndIf
   ENDIF
   lEnvioOK:= .T.
   IF(EasyEntryPoint("EICPO400"),EXECBLOCK("EICPO400",.F.,.F.,"ALT_DATA_TITULO"),)  //LRS - 7/04/2014 - Ponto de entrada alteração data venc. titulo

   If !( Type("lPoAuto")=="L" .And. lPoAuto) //FSM - 17/05/2012
      Processa({||PO400GrvPosicao()},STR0106) //"Gerando Posicoes"
      Processa({||PO_Grava()   },STR0107) //"Gravacao do P.O."
   Else
      PO400GrvPosicao() //"Gerando Posicoes"
      PO_Grava() //"Gravacao do P.O."
   EndIf
   dbSelectArea("WORK")
   SET FILTER TO WKFLAG == .T. //AWF - 22/07/2014 - Volta o filtro pq pode ter ocorrido algum erro na gravacao e tava voltando para tela sem o filtro

   If !lEnvioOK
      Return 1
   EndIf
   //FDR - 17/05/12
   // GFP - 05/08/2013 - Substituido SetMV por PutMV pois o PutMV possui tratamento de filiais.
   //PutMv("MV_SI_NUM",STRZERO(VAL(EasyGParam("MV_SI_NUM"))/*+1*/+nNum,AVSX3("W1_SI_NUM",3)-1))  // SETMV("MV_SI_NUM",STRZERO(VAL(EasyGParam("MV_SI_NUM"))/*+1*/+nNum,AVSX3("W1_SI_NUM",3)-1))  // GFP - 26/02/2013

   If lExecAuto_COM .And. !lRetExecAuto
      Return 1
   EndIf

   IF(EasyEntryPoint("EICPO400"),EXECBLOCK("EICPO400",.F.,.F.,"ANTES_GRAVAR"),)

   IF lAlcada   //CCH - 08/06/09 - Controle de geração de títulos provisórios quando controle de alçadas estiver ligado
      IF SW2->(FIELDPOS("W2_CONAPRO")) # 0 .AND. SW2->W2_CONAPRO = "L"
         EICFI400("POS_GRV_PO","I")
      ENDIF
   ELSE
      If AvFlags("EIC_EAI") .And. AvFlags("AVINT_PR_EIC")
         If SW2->W2_CONAPRO == "1"
            EICFI400("POS_GRV_PO","I")
         EndIf
      Else
         EICFI400("POS_GRV_PO","I")
      EndIf
   ENDIF

   SW2->(DBSETORDER(1))
   IF SW2->(DBSEEK(xFilial()+TPO_NUM))
      SW2->(RECLOCK("SW2",.F.))
      SW2->W2_POSICAO:=STR(nPosicao,LEN(SW3->W3_POSICAO),0)
      SW2->(MSUNLOCK())
   ENDIF

   If(lPointS,ExecBlock(cPointS),)

   /* WFS 20/08/2014 - validação movida para o AvFluxo
   //Jacomo Lisa - foi incluido a validação para integração com o Logix para execultar o Help
   IF (EasyGParam("MV_EASYFIN") == "S" .OR. AvFlags("EIC_EAI") )  .AND. EasyGParam("MV_EASYFPO") == "S" .AND. EMPTY(M->W2_DESP) // CCM - 01/06/09 - Verifica integração com o financeiro e conteudo da variavel DESPACHANTE.
	  If AvExistHelp("AVG0005374")  // Verifica Se existe o problema do Help  Ou solução do help
	     Help("", 1,"AVG0005374")   // "Não foi possível gerar os títulos provisórios no financeiro pois o campo Despachante não esta preechido." "Preencher o campo Despachante"
	  Endif
   Endif*/
    If !( Type("lPoAuto")=="L" .And. lPoAuto)
        If cMV_EASY $ cSim //LGS-12/12/2014 - Alterado para que apresente a msg apenas se tiver integração entre SIGAEIC x SIGACOM
            If !MExiste
                //Help("", 1, "AVG0000334",,TRANS(TPO_SIGA,_PictPO),1,36)//"O N£mero do Pedido da Micro Siga ‚ : "###"Atenção"
                If SW2->(FieldPos("W2_CONTR")) == 0 .Or. SW2->W2_CONTR == "2"
                        MsgInfo(StrTran(STR0387+" "+"XXX"+" "+STR0388,"XXX", M->W2_PO_SIGA),STR0002) //LRS - 22/05/2014 - Pedido XXX Criado no modulos Compras
                Else
                        MsgInfo(StrTran(STR0389+" "+"XXX"+" "+STR0388,"XXX", M->W2_PO_SIGA),STR0002) //LRS - 22/05/2014 - Autorização de entrega XXX criado no modulo Compras
                EndIf
            EndIf
        ElseIf cMV_EASY $ cNao //LGS-22/12/2014
            If !MExiste .AND. EasyGParam("MV_NRPO",,'N') $ cSim
                If SW2->(FieldPos("W2_CONTR")) == 0 .Or. SW2->W2_CONTR == "2"
                    If !(Type("lPOAuto") == "L" .And. lPOAuto)
                    MsgInfo(StrTran(STR0387+" "+"XXX"+" "+STR0403,"XXX", M->W2_PO_NUM),STR0002) //LRS - 22/05/2014 - Pedido XXX Criado no modulo de Importação                //NCF -16/09/2016 - Troca de MsgInfo para EasyHelp (ExecAuto)
                    EndIf
                Else
                    If !(Type("lPOAuto") == "L" .And. lPOAuto)
                    MsgInfo(StrTran(STR0389+" "+"XXX"+" "+STR0403,"XXX", M->W2_PO_NUM),STR0002) //LRS - 22/05/2014 - Autorização de entrega XXX criado no modulo de Importação
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf
   MForn    := ""
   MRetorno := 0
   MControla:= .F.

   //EXECAUTO
   If lPOAuto
      If nOpcAuto == 4  //Alteracao Automatica de Pedido

         If Len(aDeletaAuto) > 0
            For i:= 1 to Len(aDeletaAuto)


               If (nPOsC := aScan(aDeletaAuto[i][1], {|x| x[1] == "W0__CC" })) > 0
                  cCCusto:= aDeletaAuto[i][1][nPOsC][2]
               EndIf

               If (nPOSi := aScan(aDeletaAuto[i][1], {|x| x[1] == "W0__NUM" })) > 0
                  cSiNum:= aDeletaAuto[i][1][nPOSi][2]
               EndIf

               nInc:= 0
               cFilSW0:= xFilial("SW0")

               aOrdAut := SaveOrd({"SW1"})

               SW1->(DbSetOrder(1))
               If SW1->(DbSeek(xFilial("SW1")+AvKey(cCCusto,"W1_CC")+AvKey(cSiNum,"W0__NUM")))
                  DO WHILE !SW1->(EOF()) .AND. SW1->W1_CC = cCCusto .AND. SW1->W1_SI_NUM = cSiNum .And. SW1->W1_FILIAL == cFilSW0 .AND. nInc <= 1

                     nInc++

                     SW1->(DbSkip())
                  Enddo
               Endif

               RestOrd(aOrdAut,.T.)

               If nInc > 1
                  lRet:= MSExecAuto({|a,b,c,d| EICSI400(a,b,c)},aDeletaAuto[i][1],aDeletaAuto[i][2],4)
                  If !lRet
                     MRetorno:= 1
                  Endif
               Elseif nInc == 1
                  lRet:=MSExecAuto({|a,b,c,d| EICSI400(a,b,c)},aDeletaAuto[i][1],aDeletaAuto[i][2],5)
                  If !lRet
                     MRetorno:= 1
                  Endif
               Endif
            Next i
         Endif
      Endif
   Endif

ENDIF

RETURN MRetorno

*-------------------------*
FUNCTION PO400GrvPosicao() //AWR 18/02/1999
*-------------------------*
SW2->(DBSETORDER(1))
nPosicao:=IF(SW2->(DBSEEK(xFilial()+TPO_NUM)),VAL(SW2->W2_POSICAO),0)

DBSELECTAREA("Work")

If Type("lPoAuto") == "U"
   lPoAuto:= .F.
EndIf

If !(lPoAuto) //FSM - 17/05/2012
   ProcRegua(LASTREC())
EndIf
nOrder := Work->(IndexOrd())
If Empty(nOrder)
   nOrder := 1
EndIf

IF lRdMake
   ExecBlock("EICPPO02",.F.,.F.,"11")
ENDIF

IF lNec
   nExecute:="6"
   ExecBlock(cArqRdmake,.F.,.F.)
ENDIF

IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"ANTES_GRV_POSICAO"),) // LDR

//AAF 2020/01/01 - Não é possível usar a ordem 2 (WKPOSICAO) pois é justamente o campo que sera gravado
If nOrder == 2
   nOrder := 4
EndIf

Work->(DBSETORDER(nOrder)) // RJB 02/06/2004 estava com order posicao

Work->(DBGOTOP())

DO WHILE Work->(!EOF())

   If !(lPoAuto) //FSM - 17/05/2012
      IncProc(STR0110+ALLTRIM(Work->WKCOD_I)) //"Gravando Posicao do Item: "
   EndIf

   IF Work->WKFLAG .AND. !Work->WKFLAG2
      nPosicao:=nPosicao+1
      Work->WKPOSICAO:=STRZERO(nPosicao,LEN(SW3->W3_POSICAO),0)//Em 27/5/99 voltou a gravar com zeros a esquerda AWR
   ENDIF

   Work->(DBSKIP())
ENDDO

Work->(DBSETORDER(nOrder))  //RJB 02/06/2004
DBSETORDER(1)
DBGOTOP()

RETURN .T.

*----------------------------------------------------------------------------
FUNCTION Po420Val(MFlag,PTipo,oDlg,lLBotaoCapa)
*----------------------------------------------------------------------------
LOCAL GetList := {}, QtdeApurada:=0, TipoQtde:=SPACE(13), lSair:=.F.
LOCAL _PictItem := SB1->(ALLTRIM(X3PICTURE("B1_COD")))
LOCAL nPesoCubado:=0
Local aOrd
Local lAux, lRet
Local lRetEicLoja
DEFAULT lLBotaoCapa := .F.
PRIVATE lCase:= .T.,lRetFunc:=.T.,lBotaoCapa := lLBotaoCapa //Usada no Rdmake Eicppo02.prw
PRIVATE cFlag:=MFlag,lValido:=.T.,lRetPE := .T.  // GFP - 10/11/2014

IF TYPE("lRdMake") == "L" .AND. lRdMake//AWR 30/05/01 esta funcao eh chamada de outros programas
   lRetFunc:=ExecBlock("EICPPO02",.F.,.F.,"24")
   IF lRetFunc == .F.
      RETURN
   ENDIF
ENDIF

IF EasyEntryPoint("EICPO400")
   ExecBlock("EICPO400",.F.,.F.,"VALID")
ENDIF

//AvStAction("209",.F.)  // AWR 01/12/2009
//OAP - Substituição feita no antigo EICPOCO
//MFR 08/10/2020 OSSME-5138
//IF EasyGParam("MV_EIC_PCO",,.F.) .AND. SW2->(FIELDPOS("W2_IMPCO")) # 0      //NCF - 19/04/2011 - Incluída verificação de existência do campo
If MFlag == 'W2_IMPCO' .OR. MFlag == 'W2_IMPENC'
   IF M->W2_IMPCO == '1'.AND. M->W2_IMPENC == '1'
      MSGINFO(STR0330) // STR0330 "Pedido nao pode ser Conta e Ordem e Encomenda ao mesmo tempo."
      lValido := .F.
   ENDIF
ENDIF

IF !lCase
   RETURN .T.
ENDIF

IF !lValido
   RETURN .F.
ENDIF

If Type("lExecAuto_Com") <> "L"
   lExecAuto_Com:= /*EasyGParam("MV_EIC0008",,.F.) FIXO .T. .And. OSSME-6437 MFR 06/12/2021 */ EasyGParam("MV_EASY",,"N") == "S"
EndIf
/* Nopado - FSM - 12/09/2011
// ISS - 08/06/10 - Validação do campo no caso do mesmo estar bloqueado (*ALIAS*_MSBLQL), validação feita atravéz da rotina genérica "AvRegOk (AVGERAL).Somente valida se for campo do dicionário.
SX3->(DbSetOrder(2))
If SX3->(DbSeek(MFlag))
   If !AvRegOk(SX3->X3_ARQUIVO, SX3->X3_CAMPO)
      Return .F.
   EndIf
EndIf
*/
DO CASE

   CASE MFlag == "TEC1"

      SYD->(DBSETORDER(1))
      IF !EMPTY(M->W3_TEC )
         IF !SYD->(dbSeek(xFilial()+M->W3_TEC))
            Help("", 1, "AVG0000336")//"C¢digo N.C.M. nÆo cadastrado"###"Informação"
            RETURN .F.
         ENDIF
      ELSE
         M->W3_EX_NCM:=SPACE(3)
         M->W3_EX_NBM:=SPACE(3)

      ENDIF

   CASE MFlag == "TEC2"

      SYD->(DBSETORDER(1))
      IF !SYD->(dbSeek(xFilial("SYD")+M->W3_TEC+M->W3_EX_NCM))
         Help("", 1, "AVG0000337")//"C¢digos N.C.M.s nÆo cadastrado"###"Informação"
         RETURN .F.
      ENDIF

   CASE MFlag == "TEC3"

      SYD->(DBSETORDER(1))
      IF !EMPTY(M->W3_TEC )
         IF !SYD->(dbSeek(xFilial("SYD")+M->W3_TEC+M->W3_EX_NCM+M->W3_EX_NBM))
            Help("", 1, "AVG0000338")//"C¢digos N.C.M.s e N.B.M. nÆo cadastrados"###"Informação"
            RETURN .F.
         ENDIF
      ELSE
         M->W3_EX_NCM:=SPACE(3)
         M->W3_EX_NBM:=SPACE(3)
      ENDIF

   CASE MFlag == "CLICK_OK_REG_TRI"
      IF ! ( Empty(M->W3_REG_TRI) .Or. Eval(AVSX3("W3_REG_TRI")[7]) )
         Return .f.
      Endif

   CASE MFLAg == "REG_TRI"
      IF SX5->(dbSeek(xFilial("SX5")+"Y2"+M->W3_REG_TRI))
         M->W3_REG_DES := X5DESCRI()
      Endif

   CASE MFlag == "PPCC"
      IF AT(M->W2_FREPPCC,"PPCC") == 0
         Help("", 1, "AVG0000339")//"Tipo de Frete Difere de (PP-Prepaid / CC-Collect)"###"Atenção"
         RETURN .F.
      ENDIF

      //IF MTem_Guia .AND. lTrava  .AND. M->W2_FREPPCC != SW2->W2_FREPPCC
      IF (MTem_Guia .or. lTrava)  .AND. M->W2_FREPPCC != SW2->W2_FREPPCC //ER - 15/10/2007
         Help("", 1, "AVG0000341")//"Tipo de Frete não pode ser Alterado, pois P.O. possui L.I"###"Informação"
         RETURN .F.
      ENDIF
   CASE MFlag = "W2_NR_ALTE"
      IF ! EMPTY(M->W2_NR_ALTE) .AND. Inclui
         Help("", 1, "AVG0000342")//"Este campo não pode ser preenchido na Inclusão"###"Atenção"
            RETURN .F.
         ENDIF

   CASE MFlag =="W2_DT_ALTE"
      IF ! EMPTY(M->W2_DT_ALTE) .AND. Inclui
         Help("", 1, "AVG0000342")//"Este campo não pode ser preenchido na Inclusão"###"Atenção"
         RETURN .F.
      ENDIF

   CASE MFlag == 'Fabr'

         SA2->(DbSetOrder(1))
         If !Empty(M->W3_FABR) .And. !TEVlCliFor(M->W3_FABR,M->W3_FABLOJ,"SA2","1|3")
		      RETURN .F.
		   EndIF

        SA5->(DbSetOrder(3))  // a conpad muda o order 
        IF !Empty(M->W3_FABR) .And. !EICSFabFor(xFilial("SA5")+AvKey(Work->WKCOD_I,"A5_PRODUTO")+AvKey(M->W3_FABR,"A5_FABR")+AvKey(M->W2_FORN,"A5_FORNECE"), EICRetLoja("M","W3_FABLOJ"), EICRetLoja("M","W2_FORLOJ"))  // GFP - 11/10/2013
           Help("", 1, "AVG0000343",,AllTrim(TRANSFORM(Work->WKCOD_I,_PictItem))+ STR0118 +AllTrim(M->W3_FABR)+ STR0119 + M->W2_FORN,1,6)//'Item '###' não cadastrado para o Fabr. '###' / Forn. '###"Atenção"
           Return .F.
        Endif

        //Validação da alteração do fabricante
	    aOrd := SaveOrd({"SW5"})
        SW5->(DbSetOrder(3)) //Acb - 14/04/2010
        If (cFabrIt_Old # M->W3_FABR) .and. (!EICLOJA() .OR. cLjFabrIt # M->W3_FABLOJ  ) .And. SW5->(DbSeek(xFilial("SW5")+AvKey(cPO_Num_It,"W3_PO_NUM")+M->W3_COD_I))
            //MFR 20/09/2019
            If Select("SW5IT") > 0
               SW5IT->(DbCloseArea())
            EndIf   
            BeginSQL Alias "SW5IT"
                     Select R_E_C_N_O_ RECSW5 From %table:SW5% SW5
                     Where SW5.%NotDel% And 
                           SW5.W5_SEQ = 0 AND 
                           SW5.W5_POSICAO = %exp:M->W3_POSICAO% AND 
                           SW5.W5_PO_NUM = %exp:cPO_Num_It% AND 
                           SW5.W5_FILIAL = %exp:xFilial("SW5")% AND
                           SW5.W5_COD_I  = %exp:M->W3_COD_I% AND
                           SW5.W5_QTDE <> SW5.W5_SALDO_Q
            EndSql

            If SW5IT->(!Eof() .And. !Bof())     
                    MsgInfo(STR0273,STR0002) // "Este item já possui embarque! O fabricante não poderá ser alterado!"###"Aviso"
                    Return .F.      
            EndIf

/*         While SW5->( !Eof()) .And. SW5->(xFilial("SW5")+AvKey(cPO_Num_It,"W3_PO_NUM")+M->W3_COD_I) == SW5->(W5_FILIAL+W5_PO_NUM+W5_COD_I)
              If SW5->W5_SEQ == 0 .And. SW5->W5_POSICAO == M->W3_POSICAO
                 If SW5->W5_QTDE # SW5->W5_SALDO_Q
                    MsgInfo(STR0273,STR0002) // "Este item já possui embarque! O fabricante não poderá ser alterado!"###"Aviso"
                    Return .F.
                 EndIf
              EndIf
              SW5->(DbSkip())
           EndDo
           */
        EndIf
        RestOrd(aOrd,.T.)

        If Empty(M->W3_PRECO)
           //M->W3_PRECO:= IF(Work->WKPRECO=0,SA5->A5_VLCOTUS,Work->WKPRECO)
           IF Work->WKPRECO=0   // TLM 24/06/08 - Memoria so recebe o valor do A5 se for a mesma moeda, caso contrário recebe a work como o código anterior comentado acima.
              IF SA5->A5_MOE_US == M->W2_MOEDA
                 M->W3_PRECO:=SA5->A5_VLCOTUS
              Else
                 M->W3_PRECO:=Work->WKPRECO
              EndIf
           Else
              M->W3_PRECO:=Work->WKPRECO
           EndIf
        Endif

        SA2->(DBSEEK(xFilial("SA2")+ M->W3_FABR))/*** Nopado por FDR - 20/04/12 ***/ //+EICRetLoja("SW3","W3_FABLOJ")))
        M->W3_FAB_DES:=SA2->A2_NREDUZ//Nopado por FDR - 12/01/12 /*Work->WKFABR+" - "+SA2->A2_NREDUZ*/

      //IF Empty(M->W3_PART_N)  // GFP - 27/01/2014 //LRS - 06/09/2017 - Nopado, pois nao atualiza a informação caso troque de forn.
      If !Empty(SA5->A5_CODPRF) //CEO - 16/05/2017 - Colocada checagem, pois quando o campo A5_CODPRF esta em branco, estava sobrepondo o que o usuario digitou no campo em tela
         M->W3_PART_N := SA5->A5_CODPRF
      EndIf

      lValidSld := .T.  // GFP - 30/11/2015
      If !Empty(Work->WKFABR) .AND. !Empty(Work->W3_FABLOJ)  // GFP - 30/11/2015
         If Work->WKFABR+Work->W3_FABLOJ <> M->W3_FABR+M->W3_FABLOJ
            lValidSld := .F.
         EndIf
      EndIf

   CASE MFlag = 'W2_FORN'
        IF EMPTY( M->W2_FORN )
           Help("", 1, "AVG0000344")//"Fornecedor não preenchido"###"Atenção"
           RETURN .F.
        ENDIF

        SA2->(dbSetOrder(1))
        /*lRetEicLoj := EicLoja()
        If lRetEicLoj
           lAux := SA2->(dbSeek(xFilial("SA2")+M->W2_FORN+M->W2_FORLOJ))
        Else
           lAux := .F.
        EndIf

        //Verifica se o fornecedor esta cadastrado ...
        lRet := ExistCpo("SA2",M->W2_FORN+If(lAux,M->W2_FORLOJ,""))

        IF lRet
           If lRetEicLoj
              M->W2_FORLOJ := SA2->A2_LOJA
           EndIf
           M->W2_NREDUZ := SA2->A2_NREDUZ
        Endif
        */
        //LRS - 19/11/2015 - Verifica se o O fabricante/fornecedor está Bloqueado
        IF !Empty(M->W2_FORLOJ)
	        SA2->(dbSeek(xFilial("SA2")+M->W2_FORN+M->W2_FORLOJ))
	        If SA2->A2_MSBLQL == "1"
			    MsgInfo(STR0409+chr(13)+chr(10)+chr(13)+chr(10)+STR0410)//STR0409:"O fabricante/fornecedor utilizado está bloqueado para uso." / STR0410:"Selecione outro fabricante/fornecedor ou desbloqueie o mesmo."
			    RETURN .F.
			 EndIF

	        IF ! SA2->(DBSEEK(xFilial()+AvKey(M->W2_FORN,"A2_COD") + If(Empty(EicRetLoja("M", "W2_FORLOJ")),"",AvKey(M->W2_FORLOJ,"A2_LOJA")))) //SVG - 26/05/2011 - Ajuste no seek para permitir a digitação dos dados do fornecedor.  // GFP - 30/09/2013
	           Help("", 1, "AVG0000345")//"Fornecedor não cadastrado"###"Informação"
	           RETURN .F.
	        ELSE
	           IF LEFT(SA2->A2_ID_FBFN,1) = "1"
	              Help("", 1, "AVG0000346")//"Registro cadastrado como fabricante"###"Informação"
	              RETURN .F.
	           ENDIF
	           //IF(EICLoja(),M->W2_FORLOJ:=SA2->A2_LOJA,)//SVG - 26/05/2011 - Gatilho da loja do fornecedor do PO.
	        ENDIF

	        IF !Empty(M->W2_DESP)   // GFP - 28/10/2013 - Validação do Fornecedor do Despachante para geração de titulos PR.
	           IF EasyGParam("MV_EASYFIN") $ cSim
	              SY5->(DbSetOrder(1))
	              SY5->(DbSeek(xFilial("SY5")+M->W2_DESP))

	              IF SY5->Y5_FORNECE == M->W2_FORN
	                 MsgInfo(STR0380,STR0037)    //"O Fornecedor do Despachante não pode ser o mesmo Fornecedor do processo." ### "Atenção"
	                 Return .F.
	              //ELSE
	                 //RETURN .T.
	              ENDIF
	           //ELSE
	              //RETURN .T.
	           ENDIF
	//        ELSE
	//           RETURN .T.
	        ENDIF
        EndIF

        //wfs
        If PossuiItem()
           MsgInfo(STR0397, STR0329) //"Este processo possui ao menos um item selecionado. O Fornecedor não pode ser alterado."
           Return .F.
        EndIf

   //FDR - 13/07/2011 - Validação do campo loja do exportador, fornecedor e cliente
   CASE MFlag = "W2_EXPLOJ" .OR. MFlag = "W2_FORLOJ" .OR. MFlag = "W2_CLILOJ"
        cAliasSeek := "SA2"
        IF MFlag = "W2_CLILOJ"
           cAliasSeek := "SA1"
           cCpoSeek   := "W2_CLIENTE"
           cDescMsg   := "cliente "
        ELSEIF MFlag = "W2_EXPLOJ"
           cCpoSeek := "W2_EXPORTA"
           cDescMsg := "exportador "
        ELSE
           cCpoSeek := "W2_FORN"
           cDescMsg := "fornecedor "
        ENDIF
        (cAliasSeek)->(DbSetOrder(1))
        IF !EMPTY(M->&(MFlag)) .AND. ! (cAliasSeek)->(DBSEEK(xFilial()+AvKey(M->&(cCpoSeek),cCpoSeek)+AvKey(M->&(MFlag),MFlag)))   // GFP - 30/09/2013
           MsgInfo(STR0331 + cDescMsg + AllTrim(M->&(cCpoSeek)) + ".",STR0329) //STR0331 "Loja não cadastrada para o " //STR0329 "Atenção"
           RETURN .F.
        ENDIF

        //wfs
        If MFlag = "W2_FORLOJ" .And. PossuiItem()
           MsgInfo(STR0397, STR0329) //"Este processo possui ao menos um item selecionado. O Fornecedor não pode ser alterado."
           Return .F.
        EndIf

   CASE MFlag = 'W2_CLIENTE' // SX3

        IF EMPTY( M->W2_CLIENTE )  .AND. IF(EICLoja(), EICEmptyLJ("M", "W2_CLILOJ"), .T.)
           RETURN .T.
        ENDIF

        IF M->W2_IMPCO == "1" //LRS 15/01/2015 - Só dar a mensagem caso o processo for de Compra e Ordem.
	        //IF !SA1->(DBSEEK(xFilial()+ AvKey(M->W2_CLIENTE,"A1_COD") + AvKey(EICRetLoja("M","W2_CLILOJ"),"A1_LOJA") )) //FSM - 06/07/2011
	        If !SA1->(DBSEEK(xFilial()+ AvKey(M->W2_CLIENTE,"A1_COD") + If(Empty(EICRetLoja("M","W2_CLILOJ")),"",M->W2_CLILOJ) )) // BAK - 14/12/2011
	           Help("", 1, "AVG0000347")//"Cliente não encontrado"###"Informação"
	           RETURN .F.
	        ENDIF
        ENDIF

   //CASE AT(MFlag,'W2_INLAND/W2_DESCONT/W2_PACKING') # 0 //SX3

   CASE MFlag = 'W2__NR_COT'
        IF ! EMPTY(M->W2__NR_COT)
           IF !SWR->(DBSEEK(xFilial()+Left(M->W2__NR_COT,6)))
              Help("", 1, "AVG0000348")//"Atenção - Número da cotação não cadastrado"###"Atenção"
              RETURN .F.
           ENDIF
        ENDIF
        lRetPE := .T.  // GFP - 10/11/2014
        IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"VALIDA_COTACAO"),)  // GFP - 10/11/2014
        RETURN lRetPE  // GFP - 10/11/2014

   CASE MFlag = 'W2_COND_PA'
        IF EMPTY( M->W2_COND_PA )
           Help("", 1, "AVG0000349")//'Condicção de Pagamento não preenchida '###"Atenção"
           RETURN .F.
        ELSE
           // SVG - 01/03/2011 - Tratamento para não permitir alteração da condição de pagamento
           //quando PO tiver embarque com invoice, item anuente com LI ou cambio antecipado.
           If !Inclui .And. IF(Type("cProg")<>"U",cProg # "PN",.T.) //NCF - 09/03/2011 - Permitir nos casos de PO de Nacionalização
              SW9->(dbSetOrder(2)) //W9_FILIAL+W9_INVOICE+W9_FORN
              SW8->(dbSetOrder(6)) //W8_FILIAL+W8_HAWB+W8_INVOICE+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM
              SW9->(dbSeek(xFilial("SW9")+M->W2_FORN))
              While SW9->(!Eof()) .And. M->W2_FORN == SW9->W9_FORN
                 If SW8->(dbSeek(xFilial("SW8")+SW9->W9_HAWB+SW9->W9_INVOICE+M->W2_PO_NUM))  .And. M->W2_COND_PA != SW2->W2_COND_PA
                    MsgInfo(STR0279)//"Processo possui Embarque com Invoice, Não é permitida a Alteração da Condição de Pagamento."
                    Return .F.
                 EndIf
                 SW9->(dbSkip())
              EndDo
              SB1->(dbSetOrder(1))//B1_FILIAL+B1_COD
              SW3->(dbSetOrder(1))//W3_FILIAL+W3_PO_NUM+W3_CC+W3_SI_NUM+W3_COD_I              
              SW3->(dbSeek(xFilial("SW3")+M->W2_PO_NUM))
              //MFR 20/09/2019
               
              If M->W2_COND_PA != SW2->W2_COND_PA .And. lTrava
			      	     If PO400Anuente(M->W2_PO_NUM)  // GFP - 21/03/2014
			      	       Help("", 1, "AVG0005384")//'Condição não pode ser Alterada, pois P.O. possui L.I.'###"Informação"  // GFP - 25/04/2014
			      	     Else
			      	       Help("", 1, "AVG0005383")  // "Condição não pode ser Alterada - P.O. possui embarque vinculado"  ### "Informação"  // GFP - 25/04/2014
			      	     EndIf
				           Return .F.
    			  EndIf                    
             

              SWB->(dbSetOrder(1))
		      If SWB->(dbSeek(xFilial("SWB")+M->W2_PO_NUM)) .AND. SWB->WB_PO_DI == 'A' .And. M->W2_COND_PA != SW2->W2_COND_PA //TDF - 26/11/12 - Testa se é pagamento antecipado (WB_PO_DI = A)
   		         MsgInfo(STR0280)//"Processo possui Cambio Antecipado, Não é permitida a Alteração da Condição de Pagamento."
      			 Return .F.
	     	  EndIf
           EndIf
           //***SVG
/*
           lPABaixada:=.F.
           EICFI400("PA_BAIXADA")
           IF (lTrava .OR. lPABaixada) .AND. M->W2_COND_PA != SW2->W2_COND_PA
              IF lPABaixada
                 EICFI400('MENSAGEM')
              ELSE
                 Help("", 1, "AVG0000350")//MsgInfo(STR0126,STR0067) //'Condição não pode ser Alterada, pois P.O. possui L.I.'###"Informação"
              ENDIF
              RETURN .F.
           ENDIF
 */

           IF !SY6->(DBSEEK(xFilial()+M->W2_COND_PA))
              Help("", 1, "AVG0000351")//'Condi‡Æo nÆo Cadastrada'###"Informação"
              RETURN .F.
           ELSE
              IF !SY6->(DBSEEK(xFilial()+M->W2_COND_PA+STR(M->W2_DIAS_PA,3,0)))
                 SY6->(DBSEEK(xFilial()+M->W2_COND_PA))
                 M->W2_DIAS_PA := SY6->Y6_DIAS_PA
              ENDIF
           ENDIF
           /*ISS - 19/04/11 - Validação para não permitir o uso de uma condição de pagamento que não tenha
                              uma cond. de pag siga vinculada */
           If lExecAuto_Com
              If Empty(SY6->Y6_SIGSE4)
                 MsgInfo(STR0281,STR0002) //Condição de pagamento SIGA não vinculada. Acesse 'Atualizacoes\Tabelas\Condicoes de Pag.', selecione a cond. de pagto cadastrada e preencha o campo 'C. Pagto SIGA'./ Aviso
                 Return .F.
              EndIf
           EndIf
        ENDIF
        M->W2_DESC_PD:=MSMM(SY6->Y6_DESC_P,48,1)

        lRefresh:=.T.

   CASE MFlag = 'W2_DESP' // SVG - 20/07/2009 -
      If !EMPTY(M->W2_DESP)
         If ExistCpo('SY5',M->W2_DESP)
            SY5->(DbSetOrder(1))
            SY5->(DbSeek(xFilial()+M->W2_DESP))
            If !(LEFT(SY5->Y5_TIPOAGE,1) = "6" .OR. LEFT(SY5->Y5_TIPOAGE,1) = " ")
               MsgInfo(STR0275)
               Return .F.
            EndIf
         Else
            Return .F.
         EndIf

       IF !Empty(M->W2_FORN)   // GFP - 28/10/2013 - Validação do Fornecedor do Despachante para geração de titulos PR.
          IF EasyGParam("MV_EASYFIN") $ cSim
             SY5->(DbSetOrder(1))
             SY5->(DbSeek(xFilial("SY5")+M->W2_DESP))
             IF SY5->Y5_FORNECE == M->W2_FORN
                MsgInfo(STR0380,STR0037)    //"O Fornecedor do Despachante não pode ser o mesmo Fornecedor do processo." ### "Atenção"
                RETURN .F.
             ELSE
                RETURN .T.
             ENDIF
          ELSE
             RETURN .T.
          ENDIF
       ELSE
          RETURN .T.
       ENDIF


      EndIf

   CASE MFlag = 'W2_COND_EX'

        IF ValType(pTipo)=="N" .And. pTipo = 1   // Tipo = 1 (Validacao do Dicionario)
           IF !Inclui
              Processa( {|lEnd| lSair:=PO400VerLI() }, STR0128 ) //"Verificando Itens do P.O."
           ENDIF

           IF lSair
              If PO400Anuente(M->W2_PO_NUM)  // GFP - 21/03/2014
                 Help("", 1, "AVG0000350")//'Condição não pode ser Alterada, pois P.O. possui L.I.'###"Informação"
              Else
                 EasyHelp(STR0381,STR0002)  // "Condição não pode ser Alterada - P.O. possui embarque vinculado"  ### "Aviso"
              EndIf
              M->W2_DIAS_EX:=SW2->W2_DIAS_EX
              M->W2_COND_EX:=SW2->W2_COND_EX
              RETURN .F.
           ENDIF
        ENDIF

        IF EMPTY( M->W2_COND_EX )
           M->W2_DESC_EX:=""
           M->W2_DIAS_EX:=0
           lRefresh:=.T.
           RETURN .T.
        ELSE
           IF EMPTY(M->W2_DIAS_EX)
              M->W2_DIAS_EX := SY6->Y6_DIAS_PA
           ENDIF

           IF ! SY6->(DBSEEK(xFilial()+M->W2_COND_EX))
              Help("", 1, "AVG0000351")//'Condi não Cadastrada'###"Informação"
              RETURN .F.
           ELSE
              IF EMPTY(M->W2_DIAS_EX)
                 M->W2_DIAS_EX := SY6->Y6_DIAS_PA
              ENDIF
              IF ! SY6->(DBSEEK(xFilial()+M->W2_COND_EX+STR(M->W2_DIAS_EX,3,0)))
                 SY6->(DBSEEK(xFilial()+M->W2_COND_EX))
                 M->W2_DIAS_EX := SY6->Y6_DIAS_PA
              ENDIF
           ENDIF
        ENDIF
        M->W2_DESC_EX:=MSMM(SY6->Y6_DESC_P,48,1)
        lRefresh:=.T.

   CASE MFlag = 'W2_DIAS_PA'
        /*
        lPABaixada:=.F.
        EICFI400("PA_BAIXADA")
        //IF ((MTem_Guia .AND. lTrava) .OR. lPABaixada) .AND. M->W2_DIAS_PA # SW2->W2_DIAS_PA
        IF ((MTem_Guia .or. lTrava) .OR. lPABaixada) .AND. M->W2_DIAS_PA # SW2->W2_DIAS_PA //ER - 15/10/2007
           IF lPABaixada
              EICFI400('MENSAGEM')
           ELSE
              Help("", 1, "AVG0000352")//MsgInfo(STR0130,STR0067) //"Dias Pagto não pode ser Alterado, pois P.O. possui L.I."###"Informação"
           ENDIF
           RETURN .F.
        ENDIF
          */
        IF !SY6->(DBSEEK(xFilial()+M->W2_COND_PA+STR(M->W2_DIAS_PA,3,0)))
           Help("", 1, "AVG0000353")//'Dias de pagamento não cadastrado'###"Informação"
           RETURN .F.
        ENDIF
        M->W2_DESC_PD:=MSMM(SY6->Y6_DESC_P,48,1)
        lRefresh:=.T.

   CASE MFlag = 'W2_DIAS_EX'

        IF ValType(pTipo)=="N" .And. pTipo = 1   // Tipo = 1 (Validacao do Dicionario)
           IF !Inclui
              Processa( {|lEnd| lSair:=PO400VerLI() }, STR0128 ) //"Verificando Itens do P.O."
           ENDIF

           IF lSair
              If PO400Anuente(M->W2_PO_NUM)  // GFP - 21/03/2014
                 Help("", 1, "AVG0000352")//"Dias Pagto não pode ser Alterado, pois P.O. possui L.I."###"Informação"
              Else
                 EasyHelp(STR0383,STR0002)  // "Dias Pagto não pode ser Alterado - P.O. possui embarque vinculado"  ### "Aviso"
              EndIf
              RETURN .F.
           ENDIF

        ENDIF

        IF !EMPTY(M->W2_COND_EX)
           IF !SY6->(DBSEEK(xFilial()+M->W2_COND_EX+STR(M->W2_DIAS_EX,3,0)))
              Help("", 1, "AVG0000353")//'Dias de pagamento não cadastrado'###"Informação"
              RETURN .F.
           ENDIF
           M->W2_DESC_EX:=MSMM(SY6->Y6_DESC_P,48,1)
           lRefresh:=.T.
        ENDIF


   CASE MFlag = "TUDO"

          SYR->(DBSetOrder(1))
          IF !EMPTY(M->W2_TIPO_EM) .AND. !EMPTY(M->W2_ORIGEM) .AND. !EMPTY(M->W2_DEST)
             IF ! SYR->(DBSEEK(xFilial()+M->W2_TIPO_EM+M->W2_ORIGEM+M->W2_DEST))
                Help("", 1, "AVG0000354")//"N„o existe esta Via de Transporte / Origem / Destino no Cadastro de Fretes"
                RETURN .F.
             ENDIF
          ELSEIF !EMPTY(M->W2_TIPO_EM) .AND. !EMPTY(M->W2_ORIGEM)
             IF ! SYR->(DBSEEK(xFilial()+M->W2_TIPO_EM+M->W2_ORIGEM))
                Help("", 1, "AVG0000355")//"N„o existe esta Via de Transporte / Origem no Cadastro de Fretes"
                RETURN .F.
             ENDIF
          ENDIF

          SY6->(DBSEEK(xFilial()+M->W2_COND_PA))
          IF SY6->Y6_COM_LC$cSim .AND. M->W2_E_LC$cNao
             Help("", 1, "AVG0003135")//Condicao de Pagamento exige carta de credito,Verifique o campo Carta Credit
             RETURN .F.
          ENDIF

          IF !Inclui
             lTudo_OK:=.T.
             EICFI400("TUDO_OK")
             IF !lTudo_OK
                RETURN .F.
             ENDIF
          ENDIF

          RETURN .T.

   //Nopado por TRP em 26/05/08 pois o preenchimento da NCM será obrigatório apenas na fase de Desembaraço.
   /*CASE MFlag = 'W3_TEC' // By JPP - 07/12/2007 - 09:30
        If Empty(M->W3_TEC)
           MsgInfo(STR0272, STR0002) //"O preenchimento do campo Pos.IPI/NCM é obrigatório!" ### "Aviso"
           Return .F.
        EndIf*/

   CASE MFlag = 'W2_FRETEIN'

        IF M->W2_FRETEIN < 0
           Help(" ",1,"PO400FRNEG")
           RETURN .F.
        ENDIF
        // ISS - 01/06/10 - Validação para caso o frete int. seja maior ou igual ao FOB da PO.
        If M->W2_FRETEIN >= M->W2_FOB_TOT .AND. Type("M->W2_FREINC") == "C" .And. M->W2_FREINC = "1" .AND. M->W2_FOB_TOT != 0 ;
           .AND. AvRetInco(AllTrim(M->W2_INCOTER),"CONTEM_FRETE")  /* FSM - 28/12/10 */ //M->W2_INCOTER $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP";
           MsgInfo(STR0306,STR0037) //STR 0306 - "O Frete Int. não pode ser maior ou igual ao valor da FOB." //STR0037 = "Atenção".
           Return .F.
        EndIf
        If(AvFlags("RATEIO_DESP_PO_PLI"),PO400RatFrSg(),)

   CASE MFlag = 'W2_SEGURIN'  // GFP - 28/01/2016

        IF SW2->(FieldPos('W2_SEGURIN')) == 0
           Return .T.
        ENDIF
        IF M->W2_SEGURIN < 0
           Help(" ",1,"PO400SGNEG")
           RETURN .F.
        ENDIF
        If M->W2_SEGURIN >= M->W2_FOB_TOT .AND. Type("M->W2_SEGINC") == "C" .And. M->W2_SEGINC = "1" .AND. M->W2_FOB_TOT != 0 ;
           .AND. AvRetInco(AllTrim(M->W2_INCOTER),"CONTEM_SEGURO")
           MsgInfo(STR0413,STR0037) //"O Seguro não pode ser maior ou igual ao valor da FOB." ## "Atenção".
           Return .F.
        EndIf
        If(AvFlags("RATEIO_DESP_PO_PLI"),PO400RatFrSg(),)

   CASE MFlag = 'W2_INLAND'  // GFP - 28/01/2016

        IF M->W2_INLAND < 0
           EasyHelp(STR0414,STR0002)  // "Valor de Inland não pode ser negativo."  ### "Aviso"
           RETURN .F.
        ENDIF
        If(AvFlags("RATEIO_DESP_PO_PLI"),PO400RatFrSg(),)

   CASE MFlag = 'W2_DESCONT'  // GFP - 28/01/2016

        IF M->W2_DESCONT < 0
           EasyHelp(STR0415,STR0002)  // "Valor de Desconto não pode ser negativo."  ### "Aviso"
           RETURN .F.
        ENDIF
        If(AvFlags("RATEIO_DESP_PO_PLI"),PO400RatFrSg(),)

   CASE MFlag = 'W2_PACKING'  // GFP - 28/01/2016

        IF M->W2_PACKING < 0
           EasyHelp(STR0416,STR0002)  // "Valor de Packing não pode ser negativo."  ### "Aviso"
           RETURN .F.
        ENDIF
        If(AvFlags("RATEIO_DESP_PO_PLI"),PO400RatFrSg(),)

   CASE MFlag = 'W2_AGENTE'
       IF cMV_EASY $ cSim .AND. !EMPTY(M->W2_AGENTE)
           IF SY4->(DBSEEK(XFILIAL("SY4")+M->W2_AGENTE))
              cFornFret:=SY4->Y4_FORN
              cLojaFret:=SY4->Y4_LOJA
              IF SY4->Y4_FORN == M->W2_FORN .AND. (!EICLOJA() .OR. SY4->Y4_LOJA == M->W2_FORLOJ)
                 MsgInfo(STR0250,STR0067) // Fornecedor p/ o Agente nao pode ser igual ao fornecedor das mercadorias
                 RETURN .F.
              ENDIF
           ENDIF
       ENDIF
   CASE MFlag = 'W2_INCOTER'

             /* FDR - 28/12/10 */
             If dDataBase >= CToD("01/01/11") .And. M->W2_INCOTER $ "DEQ/DAF/DES/DDU"
                MsgInfo(STR0307,STR0037) //STR0307 - "Segundo a Norma dos Incoterms 2010, dois novos Incoterms, DAT/DAP, entraram em vigor a partir de janeiro de 2011 em substituição aos DEQ/DAF/DES/DDU." //STR0037 = "Atenção"
             EndIf

             //If MTem_Guia .AND. lTrava .And. M->W2_INCOTER # SW2->W2_INCOTER
             If (MTem_Guia .or. lTrava) .And. M->W2_INCOTER # SW2->W2_INCOTER //ER - 15/10/2007
                If PO400Anuente(M->W2_PO_NUM)  // GFP - 21/03/2014
                   Help("", 1, "AVG0005384")//'Condição não pode ser Alterada, pois P.O. possui L.I.'###"Informação"  // GFP - 25/04/2014
			    Else
			       Help("", 1, "AVG0005383")  // "Condição não pode ser Alterada - P.O. possui embarque vinculado"  ### "Informação"  // GFP - 25/04/2014
                EndIf
                RETURN .F.
             Endif

             //TRP-10/04/08- Caso o incoterm selecionado seja um dos abaixo inicializar o campo W2_FREPPCC com PP(pre-paid), senão com CC (collect)
             If AvRetInco(AllTrim(M->W2_INCOTER),"CONTEM_FRETE")/* FSM - 28/12/10 */ //M->W2_INCOTER $ "CFR/CIP/CIF/CPT/DAF/DES/DDU/DDP/DEQ"
                M->W2_FREPPCC := "PP"
             Else
                M->W2_FREPPCC := "CC"
             Endif
        CASE MFlag = 'Fbr1'

        CASE MFlag = 'Fbr2'

        CASE MFlag = 'Fbr3'

        CASE MFlag = 'Fbr4'

        CASE MFlag = 'Fbr5'


        CASE MFlag = 'Porta'
             IF TPortaria = 0 .OR. TPortaria = 7 .OR. TPortaria = 8 .OR. ;
                TPortaria = 15
                RETURN .T.
             ELSE
                Help("", 1, "AVG0000357")//'N£mero de portaria diferente de 0,7/8,15'###"Atenção"
                RETURN .F.
             ENDIF

        CASE MFlag = 'W2_MOEDA'
             lPABaixada:=.F.
             EICFI400("PA_BAIXADA")
             //If ((MTem_Guia .AND. lTrava) .OR. lPABaixada) .AND. M->W2_MOEDA != SW2->W2_MOEDA
             If ((MTem_Guia .or. lTrava) .OR. lPABaixada) .AND. M->W2_MOEDA != SW2->W2_MOEDA //ER - 15/10/2007
                IF lPABaixada
                   EICFI400('MENSAGEM')
                ElseIf lTrava
                   Help("", 1, "EIC01005") //"Moeda não pode ser alterada - P.O. possui Embarque." //MCF - 15/07/2016
                ELSE
                   Help("", 1, "AVG0000358")//MsgInfo(STR0136,STR0067) //"Moeda não pode ser alterada - P.O. possui LI"###"Informação"
                ENDIF
                RETURN .F.
             Endif

             SYE->(DBSETORDER(2))
             IF ! SYE->(DBSEEK(xFilial()+M->W2_MOEDA))
                Help("", 1, "AVG0000359")//'Não existe cotação para esta moeda'###"Informação"
                SYE->(DBSETORDER(1))
                RETURN .F.
             ENDIF

             SYE->(DBSETORDER(1))

        CASE MFlag = 'Saldo_Q'
             IF lLibQt
                IF AvFlags("EIC_EAI")//EasyGParam("MV_EIC_EAI",,.F.)//AWF - 25/06/2014
                   M->W3_QTSEGUM:=M->W3_QTDE*Work->WKFATOR//AVTransUnid(M->W3_UM,M->W3_SEGUM,M->W3_COD_I,M->W3_QTDE,,,,M->W2_FORN,M->W2_FORLOJ)
                ENDIF
                RETURN .T.
             ENDIF
             IF M->W3_QTDE < 0
                Help("", 1, "AVG0000360")//'Saldo da quantidade não pode ser negativo'###"Atenção"
                RETURN .F.

             ELSEIF M->W3_QTDE = 0
                MsgInfo(STR0251,STR0037) // Saldo de Quantidade Invalido! ### Atenção
                RETURN .F.

             ELSEIF M->W3_QTDE < M->W3_QTD_EMB
                MsgInfo(STR0251,STR0037) // Saldo de Quantidade Invalido! ### Atenção
                RETURN .F.

             ELSEIF M->W3_FLUXO == "1"  .AND. Work->WKFLUXO_O == "1" .AND. M->W3_QTDE < WORK->WKQTDE_GI
                MsgInfo(STR0251,STR0037) // Saldo de Quantidade Invalido! ### Atenção
                RETURN .F.

             ElseIf !ComparaPeso(M->W3_QTDE,, "C7_QUANT", .F.) //ACB - quantidade maxima do C7_QUANT
                Return .F.
             ENDIF

             IF .NOT. MExiste
                IF lValidSld .AND. M->W3_QTDE > POSALDO_W1(.T.)   // GFP - 30/11/2015
                   Help("", 1, "AVG0000361")//'Quantidade maior que o saldo da solicitação'###"Atenção"
                    IF !AvFlags("EIC_EAI")//!EasyGParam("MV_EIC_EAI",,.F.)//JL
                       RETURN .F.
                    ENDIF
                ENDIF
             ELSE
                IF lValidSld .AND. M->W3_QTDE > POSALDO_W1(.T.)   // GFP - 30/11/2015
                    Help("", 1, "AVG0000361")//'Quantidade maior que o saldo da solicitação'###"Atenção"
                    DBSELECTAREA("Work")
                    IF !AvFlags("EIC_EAI")//!EasyGParam("MV_EIC_EAI",,.F.)//JL
                       RETURN .F.
                    ENDIF
                    DBSELECTAREA("Work")
                    IF EasyEntryPoint("IC086PO1")
                       IF !ExecBlock("IC086PO1",.F.,.F.,1)
                          RETURN .F.
                       ENDIF
                    ENDIF
                ELSEIF lCancelaSaldo .AND. Work->WKFLAG2 .AND.;
                   M->W3_QTDE < POSALDO_W1(.T.)  .AND.; //(nQtdePed+M->W3_SEM_PED)  // GFP - 25/04/2015
                   ValType(pTipo)=="C" .And. pTipo = "OK"
                   lCancel:=.T.
                   EICPO410(2)
                   lCancel := .F.
                   Work->WKMOTIVO:=cMotivo
                   //RETURN .T.//AWF - 25/06/2014
                ENDIF
             ENDIF
             IF AvFlags("EIC_EAI")//EasyGParam("MV_EIC_EAI",,.F.)//AWF - 25/06/2014
                M->W3_QTSEGUM:=M->W3_QTDE*Work->WKFATOR//AVTransUnid(M->W3_UM,M->W3_SEGUM,M->W3_COD_I,M->W3_QTDE,,,,M->W2_FORN,M->W2_FORLOJ)
             ENDIF
             lValidSld := .T.  // GFP - 30/11/2015
        CASE MFlag = 'VlUnit'
             IF EMPTY( M->W3_PRECO )
                Help("", 1, "AVG0000362")//'Valor unit rio nÆo preenchido'###"Atenção"
                RETURN .F.
             ENDIF
             IF M->W3_PRECO < 0
                Help("", 1, "AVG0000363")//'Valor unit rio nÆo pode ser negativo'###"Atenção"
                RETURN .F.
             ENDIF
             IF SB1->(DBSEEK(xFilial()+Work->WKCOD_I))
                RETURN .T.
             ELSE
                Help("", 1, "AVG0000364",,TRANSFORM(Work->WKCOD_I,_PictItem)+STR0144,1,8)//'Código '###' não cadastrado'###"Informação"
                RETURN .F.
             ENDIF

        CASE MFlag = 'DtEmbarque'

             IF M->W3_DT_EMB < M->W2_PO_DT
                 Help("", 1, "AVG0000365")//'Data de embarque deve ser maior que a data do P.O.'###"Atenção"
                 RETURN .F.
             ENDIF

             M->W3_PRECO:=IF(M->W3_PRECO==0,Work->WKPRECO,M->W3_PRECO)

             //Sugere data de entrega conforme lead times de desembaraco + transporte
             SY9->(dbSetOrder(2))
             dtEntCalc := M->W3_DT_EMB + SYR->YR_TRANS_T + IF(SY9->(DBSEEK(xFilial()+M->W2_DEST)),(SY9->Y9_LT_DES + SY9->Y9_LT_TRA),EasyGParam("MV_LT_DESE"))
             SY9->(dbSetOrder(1))

             //If EMPTY(M->W3_DT_ENTR) .OR. AvFlags("EIC_EAI")
             //   M->W3_DT_ENTR:= dtEntCalc
             IF M->W3_DT_EMB <> WORK->WKDT_EMB .AND. dtEntCalc <> M->W3_DT_ENTR
                IF !(ValType(pTipo)=="C" .And. pTipo = "OK") .AND. lValidaData	//ASR - 07/10/2005 - SE lValidaData = .T. ENTRA E FAZ A VALIDAÇÃO DA DATA - FOI USADO EM UMA CUSTOMIZAÇÃO DA BRASKEM
                   If ( Type("lPoAuto")=="L" .And. lPoAuto) .OR. MsgYesNo( STR0248 + DTOC(dtEntCalc) + CHR(13)+CHR(10)+ STR0249, STR0186)=.T. //'Data de entrega projetada pelo sistema e : '#'Deseja altera-la?'
                      IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"MUDA_DT_ENTREGA"),)
                      M->W3_DT_ENTR := dtEntCalc
                   ELSE
                      IF !( Type("lPoAuto")=="L" .And. lPoAuto) .AND. M->W3_DT_ENTR < M->W3_DT_EMB
                         Help("", 1, "AVG0000366")//'Data de entrega deve ser maior ou igual que a data de embarque'###"Atenção"
                         RETURN .F.
                      ENDIF
                   ENDIF
                EndIF
             ENDIF

             IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"RECALC_DT_ENTREGA"),)

        CASE MFlag = 'DtEntrega'

             IF M->W3_DT_ENTR < M->W3_DT_EMB
                Help("", 1, "AVG0000366")//'Data de entrega deve ser maior ou igual que a data de embarque'###"Atenção"
                RETURN .F.
             ENDIF

             // calcula a data de entrega conforme lead times de desembaraco + transporte
             SY9->(dbSetOrder(2))
             dtEntCalc := M->W3_DT_EMB + SYR->YR_TRANS_T + IF(SY9->(DBSEEK(xFilial()+M->W2_DEST)),(SY9->Y9_LT_DES + SY9->Y9_LT_TRA),EasyGParam("MV_LT_DESE"))
             SY9->(dbSetOrder(1))
             If AvFlags("EIC_EAI")
                M->W3_DT_ENTR := dtEntCalc
             EndIf
             IF !( Type("lPoAuto")=="L" .And. lPoAuto) .AND. M->W3_DT_ENTR < dtEntCalc .AND. cProg#"PN" .AND. lMostraMem .AND. lValidaData	//ASR - 07/10/2005 - SE lValidaData = .T. ENTRA E FAZ A VALIDAÇÃO DA DATA - FOI USADO EM UMA CUSTOMIZAÇÃO DA BRASKEM
                Help("", 1, "AVG0000368")//'Data de entrega menor que o lead time operacional'###"Atenção"
                lMostraMem:=.F.
             ENDIF

             RETURN .T.

        //ACB - 28/02/2011 - Validação para peso liquido.
        CASE MFLAG = 'W3_PESO'
             IF SW3->(FIELDPOS("W3_PESOL")) # 0
                If !ComparaPeso(M->W3_QTDE,M->W3_PESOL,"EIJ_PESOL",,) //Atenção, fonte chamado do AVGERAL.PRW
                   Return .f.
                EndIf
             EndIf

        CASE MFlag = "W2_IMPORT"

             //If MTem_Guia .AND. lTrava .And. M->W2_IMPORT # SW2->W2_IMPORT
             If (MTem_Guia .or. lTrava) .And. M->W2_IMPORT # SW2->W2_IMPORT //ER - 15/10/2007
                If PO400Anuente(M->W2_PO_NUM)  // GFP - 21/03/2014
                   Help("", 1, "AVG0000370")//"Importador não pode ser alterado - P.O. possui L.I."###"Informação"
                Else
                   EasyHelp(STR0384,STR0002)  // "Importador não pode ser Alterado - P.O. possui embarque vinculado"  ### "Aviso"
                Endif
                RETURN .F.
             Endif

             SYT->(DBSETORDER(1))   //JWJ 02-10-2006
             IF EMPTY(M->W2_IMPORT)
                Help("", 1, "AVG0000371")//'Código do importador não preenchido'###"Atenção"
                RETURN .F.
             ELSEIF ! SYT->(DBSEEK(xFilial()+M->W2_IMPORT))
                Help("", 1, "AVG0000372")//'Código do importador não cadastrado'###"Informação"
                RETURN .F.
             ENDIF

             IF SYT->YT_IMP_CON <> "1"
                Help("", 1, "AVG0000373")//"Código informado não é de importador"###"Informação"
                RETURN .F.
             ENDIF

        CASE MFlag = "W2_CONSIG"

             //If MTem_Guia .AND. lTrava .And. M->W2_CONSIG # SW2->W2_CONSIG
             If (MTem_Guia .or. lTrava) .And. M->W2_CONSIG # SW2->W2_CONSIG //ER - 15/10/2007
                If PO400Anuente(M->W2_PO_NUM)  // GFP - 21/03/2014
                   Help("", 1, "AVG0000374")//"Consignatário não pode ser alterado - P.O. possui L.I."###"Informação"
                Else
                   EasyHelp(STR0385,STR0002)  // "Consignatário não pode ser Alterado - P.O. possui embarque vinculado"  ### "Aviso"
                EndIf
                RETURN .F.
             Endif

             IF ! EMPTY(M->W2_CONSIG)
                IF ! SYT->(DBSEEK(xFilial()+M->W2_CONSIG))
                   Help("", 1, "AVG0000375")//'Código do consignatário não cadastrado'###"Informação"
                   RETURN .F.
                ENDIF

                IF SYT->YT_IMP_CON <> "2"
                   Help("", 1, "AVG0000376")//"Código informado não é de consignatário"###"Informação"
                   RETURN .F.
                ENDIF
             ENDIF

        CASE MFlag == "Anuente"
             DO CASE
                CASE M->W3_FLUXO == "7"
                     IF Work->WKFLUXO_O # "7" .AND. Work->WKQTDE_GI # 0
                        Help("", 1, "AVG0000378")//"Esta informação não pode ser alterada, o item já possui L.I., estorne-a."###"Atenção"
                        RETURN .F.
                     ENDIF

                CASE M->W3_FLUXO == "1"
                     IF Work->WKFLUXO_O == "7"
                        IF Work->WKSALDO_GI # Work->WKQTDE_GI
                           Help("", 1, "AVG0000379")//"Item já tem qtde.embarcada,não pode ser alterado p/ com anuência."###"Informação"
                           RETURN .F.
                        ENDIF
                        WORK->WKQTDE_GI :=0// Esses campos sao zerados por causa da troca de Nao Anuente p/ Anuente
                        Work->WKSALDO_GI:=0// No Anuente o campo WORK->WKQTDE_GI tem que aparecer na tela zerado
                     ENDIF
             ENDCASE

             M->W3_QTD_LI:=IF(M->W3_FLUXO="1",TRANSFORM(WORK->WKQTDE_GI,_PictQtde),STR0290) //STR0290 = "Não Anuente

        CASE MFlag = 'W2_OBS_COD'
             IF ! EMPTY(M->W2_OBS_COD)
                IF ! SY7->(DBSEEK(xFilial()+"1" + STR(M->W2_OBS_COD,3)))
                   Help("", 1, "AVG0000380")//"C¢digo de observa‡Æo inexistente"###"Informação"
                ELSE
                   IF ! MExiste
                      M->W2_OBS:= SY7->Y7_TEXTO
                      SY7->(DBSKIP())
                      IF SY7->Y7_POGI = "1"
                         M->W2_OBS_COD := SY7->Y7_COD
                      ELSE
                         SY7->(DBSKIP(-1))
                      ENDIF
                   ENDIF
                ENDIF
             ENDIF

             RETURN .T.

        CASE MFlag = 'Obs2_Cod'
             IF ! EMPTY(T2Obs_Cod)
                IF ! SY7->(DBSEEK(xFilial()+"1" + STR(T2Obs_Cod,3)))
                   Help("", 1, "AVG0000380")//"C¢digo de observa‡Æo inexistente"###"Informação"
                ELSE
                   IF ! MExiste
                      TObs+=" "+SY7->Y7_TEXTO
                   ENDIF
                ENDIF
             ENDIF

             RETURN .T.

        CASE MFlag = 'W2_EXPORTA'
             IF ! EMPTY(M->W2_EXPORTA)  .AND. !EICEmptyLJ("M", "W2_EXPLOJ")
                IF ! SA2->(DBSEEK(xFilial()+M->W2_EXPORTA+EICRetLoja("M","W2_EXPLOJ")))
                   Help("", 1, "AVG0000381")//"Exportador não cadastrado"###"Informação"
                   RETURN .F.
                ENDIF
             ENDIF


        CASE MFlag = 'W2_TIP_COM'
             IF M->W2_COMIS $ cNao  .OR.  M->W2_COMIS = " "
                IF !EMPTY( M->W2_TIP_COM )
                   Help("", 1, "AVG0000382")//"Tipo da comissão não pode ser preenchido"###"Informação"
                   RETURN .F.
                ENDIF
             ELSE
                IF EMPTY( M->W2_TIP_COM )
                   Help("", 1, "AVG0000383")//"Tipo da comissão não preenchido"###"Atenção"
                   RETURN .F.
                ENDIF
             ENDIF


        CASE MFlag = 'W2_VAL_COM'

             IF M->W2_COMIS $ cSim
                IF M->W2_TIP_COM # '2'  .AND.  M->W2_TIP_COM # '3'
                   IF M->W2_VAL_COM > 0
                      Help("", 1, "AVG0000384")//"Valor da comissão não pode ser preenchido"###"Atenção"
                      RETURN .F.
                   ENDIF
                ELSE
                   IF M->W2_VAL_COM <= 0
                      Help("", 1, "AVG0000385")//"Valor da comissão não preenchido"###"Atenção"
                      RETURN .F.
                   ENDIF
                ENDIF
             ELSE
                IF M->W2_VAL_COM > 0
                   Help("", 1, "AVG0000384")//"Valor da comissão não pode ser preenchido"###"Atenção"
                   RETURN .F.
                ENDIF
             ENDIF


        CASE MFlag = 'W2_PER_COM'

             IF M->W2_COMIS $ cSim
                IF M->W2_TIP_COM # '1'
                   IF M->W2_PER_COM > 0
                      Help("", 1, "AVG0000386")//"Percentual da comissão não pode ser preenchido"###"Atenção"
                      RETURN .F.
                   ENDIF
                ELSE
                   IF M->W2_PER_COM <= 0
                      Help("", 1, "AVG0000387")//"Percentual da comissão não preenchido"###"Atenção"
                      RETURN .F.
                   ENDIF
                ENDIF
             ELSE
                IF M->W2_PER_COM > 0
                   Help("", 1, "AVG0000386")//"Percentual da comissão não pode ser preenchido"###"Atenção"
                   RETURN .F.
                ENDIF
             ENDIF


        CASE MFlag = 'W2_OUT_COM'

             IF M->W2_COMIS $ cSim
                IF M->W2_TIP_COM # '4'
                   IF !EMPTY( M->W2_OUT_COM )
                      Help("", 1, "AVG0000388")//"Outr. Comis. não pode ser preenchido"###"Atenção"
                      RETURN .F.
                   ENDIF
                ELSE
                   IF EMPTY( M->W2_OUT_COM )
                      Help("", 1, "AVG0000390")//"Outr. Comis. não preenchido"###"Atenção"
                      RETURN .F.
                   ENDIF
                ENDIF
             ELSE
                IF !EMPTY( M->W2_OUT_COM )
                   Help("", 1, "AVG0000388")//"Outr. Comis. não pode ser preenchido"###"Atenção"
                   RETURN .F.
                ENDIF
             ENDIF


        CASE MFlag = 'W2_MT3'
             IF M->W2_MT3 < 0
                Help("", 1, "AVG0000391")//"Volume cubado não pode ser negativo"###"Atenção"
                RETURN .F.
             ENDIF

             IF M->W2_MT3 # 0 .And. M->W2_PESO_B == 0 //ASK 25/10/2007 - Se o Peso já estiver preenchido, nao calcula.
                nPesoCubado  := ( M->W2_MT3 / 0.006 )
                M->W2_PESO_B := IF( M->W2_PESO_B > nPesoCubado, M->W2_PESO_B, nPesoCubado )
             ENDIF

        CASE MFlag = 'W2_CONTA20'
             IF M->W2_CONTA20 < 0
                Help("", 1, "AVG0000392")//"Container de 20' não pode ser negativo"###"Atenção"
                RETURN .F.
             ENDIF

        CASE MFlag = 'W2_CONTA40'
             IF M->W2_CONTA40 < 0
                Help("", 1, "AVG0000394")//"Container de 40' não pode ser negativo"###"Atenção"
                RETURN .F.
             ENDIF

        CASE MFlag = 'W2_CON40HC'
             IF M->W2_CON40HC < 0
                Help("", 1, "AVG0000395")//"Container de 40' HC não pode ser negativo"###"Atenção"
                RETURN .F.
             ENDIF

        CASE MFlag = 'W2_OUTROS'
             IF M->W2_OUTROS < 0
                Help("", 1, "AVG0000396")//"Outros não pode ser negativo"###"Atenção"
                RETURN .F.
             ENDIF

        CASE MFlag = 'COMP_VIA'
             IF lMod_Alter .AND. M->W2_TIPO_EM <> SW2->W2_TIPO_EM
                MsgInfo( STR0243 + STR0246 )//Devido a alteracao da via de transporte,'#'as datas de embarque e entrega devem ser alteradas!'
             ENDIF

        CASE MFlag = 'COMP_ORIG'
			 SYR->(DbSeek(xFilial("SYR")+M->(W2_TIPO_EM+W2_ORIGEM)))   // GFP - 02/10/2012
			 IF Empty(SYR->YR_PAIS_OR) .OR. SYR->YR_PAIS_OR == '105' .OR. M->W2_ORIGEM <> SYR->YR_ORIGEM
			    MsgAlert(STR0377,STR0037) //"Origem não permitida."##"Atenção"
			    RETURN .F.
			 ENDIF
			 IF lMod_Alter .AND. M->W2_ORIGEM <> SW2->W2_ORIGEM
                MsgInfo( STR0244 + STR0246 )//'Devido a alteracao da origem, '#'as datas de embarque e entrega devem ser alteradas!'
             ENDIF

        CASE MFLAG = 'COMP_DEST'
             SYR->(DbSeek(xFilial("SYR")+M->(W2_TIPO_EM+W2_ORIGEM+W2_DEST)))   // GFP - 02/10/2012
             IF Empty(SYR->YR_PAIS_OR) .OR. SYR->YR_PAIS_OR == '105' .OR. M->W2_DEST <> SYR->YR_DESTINO
			    MsgAlert(STR0378,STR0037) //"Destino não permitido."##"Atenção"
			    RETURN .F.
			 ENDIF
             IF lMod_Alter .AND. M->W2_DEST <> SW2->W2_DEST
                MsgInfo( STR0245 + STR0246 )//'Devido a alteracao do destino,'#'as datas de embarque e entrega devem ser alteradas!'
             ENDIF
ENDCASE

RETURN .T.

*--------------------------------------------------------------------------------------------
FUNCTION PO400VerLI()
*---------------------------------------------------------------------------------------------

If Type("lPoAuto") == "U"
   lPoAuto:= .F.
EndIf

SW3->( DbSeek( xFilial()+SW2->W2_PO_NUM ) )

If !(lPoAuto) //FSM - 17/05/2012
   ProcRegua( SW3->(LastRec()) )
EndIf

While !SW3->(EOF())  .AND. SW2->W2_PO_NUM = SW3->W3_PO_NUM .AND. SW3->W3_FILIAL == xFilial("SW3")

      If !(lPoAuto) //FSM - 17/05/2012
         IncProc(STR0176 + SW3->W3_COD_I ) //"Processando Item nr. "
      EndIf

      IF SW3->W3_FLUXO = "1"  .AND.  ( SW3->W3_QTDE # SW3->W3_SALDO_Q )
         RETURN .T.
      ENDIF

      IF SW3->W3_FLUXO = "7"

         IF PO420_IgPos( "3", SW3->W3_FABR, If(EICLOJA(),SW3->W3_FABLOJ,"") )
            IF ( SW5->W5_QTDE # SW5->W5_SALDO_Q )
               RETURN .T.
            ENDIF
         ELSE
            RETURN .T.
         ENDIF

      ENDIF

      SW3->( DbSkip() )

End


RETURN .F.


*----------------------------------------------------------------------------
FUNCTION PO_TestFabr(cFabr)
*----------------------------------------------------------------------------
SA5->(DBSEEK(xFilial()+Work->WKCOD_I+cFabr))

IF SA5->(EOF())
        Help("", 1, "AVG0000397")//'Fabricante não cadastrado para este item'###"Informação"
        RETURN .F.
ENDIF

SA2->(DBSEEK(xFilial()+cFabr))

RETURN .T.

*----------------------------------------*
FUNCTION PO420Cha(PValor,PTipo,PPrg,PPCC)
*----------------------------------------*
LOCAL GETLIST:={}, OldTela, Lin:=15,Col:=0
LOCAL oDlg, lInland:=.F., lPacking:=.F., lFreteIntl:=.F., lDesconto:=.F.
LOCAL bValid:={|| (lInland      .OR. GI420Val('Inl')) .AND. ;
                                                (lPacking       .OR. GI420Val('Pac')) .AND. ;
                                                (lFreteIntl .OR. GI420Val('Fre')) .AND. ;
                                                (lDesconto      .OR. GI420Val('Des')) }, lValid:=.T.

LOCAL cPictInl := ALLTRIM(X3Picture("W4_INLAND"))  //mjb150999
LOCAL cPictFri := ALLTRIM(X3Picture("W4_FRETEIN")) //mjb150999
LOCAL cPictPac := ALLTRIM(X3Picture("W4_PACKING")) //mjb150999
LOCAL cPictDes := ALLTRIM(X3Picture("W4_DESCONT")) //mjb150999
LOCAL cPictOut := ALLTRIM(X3Picture("W4_OUT_DES"))
Local oPanel, oDlg:= {}
//ISS - 22/12/10 - Nopada a definição da variável TSeguro como local pois o uso de todas as variáveis são private,
//                 caso ela fique como local o seu valor não será atribuido a variável private TSeguro.
//LOCAL TSeguro  := 0
nL1:=2.0 ; nL2:=3.0 ; nL3:=4.0 ; nL4:=5.0 ;nL5:=6.0
nC1:=0.8 ; nC2:=6
PRIVATE lAlteraI:=lAlteraP:=lAlteraF:=lAlteraD:=lAlteraO:=lAlteraS:=.T.

DEFINE MSDIALOG oDlg TITLE STR0178 From 12,20 To 35,69 OF oMainWnd //"Despesas"        //BHF - 08/08/08 - Tratamento MDI

   aPos:= PosDlg(oDlg)
   oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, aPos[4], aPos[3])
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   IF PTipo = "A"
   *   E_Msg(STR0179,1000,.t.) //"incluir get despesas na alteracao"
   ELSE
      @nL1,nC1 SAY STR0180 Of oPanel//"Inland Charge"
      @nL2,nC1 SAY STR0181 Of oPanel //"Packing Charge"
      @nL3,nC1 SAY STR0182 Of oPanel //"Int'l Freight"
      @nL4,nC1 SAY STR0183 Of oPanel //"Desconto"
      IF SW4->(FIELDPOS("W4_OUT_DES")) # 0
         nL5:=nL4+1
         @nL5,nC1 SAY AVSX3("W4_OUT_DES",5) Of oPanel //Outras Despesas
      ENDIF
      // EOB - 14/07/08 - Tratamento de incoterms com seguro
      IF SW4->(FIELDPOS("W4_SEGURO")) # 0
         nL5++
         @nL5,nC1 SAY AVSX3("W4_SEGURO",5) Of oPanel //Outras Despesas
      ENDIF

   ENDIF

   IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"WHEN_ALTERA"),)

   @nL1,nC2 MSGET TInland   WHEN lAlteraI .AND. IF(PPrg = NIL,.T.,MInland # 0) ;
      PICTURE cPictInl VALID (lInland:=GI420Val('Inl')) SIZE 50,7 Of oPanel

   @nL2,nC2 MSGET TPacking  WHEN lAlteraP .AND.IF(PPrg = NIL,.T.,MPacking # 0) ;
      PICTURE cPictPac VALID (lPacking:=GI420Val('Pac')) SIZE 50,7 Of oPanel

   @nL3,nC2 MSGET TFreteIntl WHEN lAlteraF .AND.(PPCC == "PP" .AND. IF(PPrg=NIL,.T.,TFreteIntl # 0)) ;
      PICTURE cPictFri VALID (lFreteIntl:=GI420Val('Fre')) SIZE 50,7 Of oPanel

   @nL4,nC2 MSGET TDesconto  WHEN lAlteraD .AND.IF(PPrg = NIL,.T.,MDesconto # 0) ;
      PICTURE cPictDes VALID (lDesconto:=GI420Val('Des'))  SIZE 50,7 Of oPanel

   IF SW4->(FIELDPOS("W4_OUT_DES")) # 0
      nL5:=nL4+1
      @nL5,nC2 MSGET TOutDesp  WHEN lAlteraO .AND.IF(PPrg = NIL,.T.,TOutDesp# 0) ;
         PICTURE cPictDes VALID (lOut_Des:=GI420Val('Out_Des'))  SIZE 50,7 Of oPanel
   ENDIF

   // EOB - 14/07/08 - Tratamento de incoterms com seguro
   IF SW4->(FIELDPOS("W4_SEGURO")) # 0
      nL5++
      @nL5,nC2 MSGET TSeguro  WHEN lAlteraS .AND. IF(PPrg = NIL,.T.,TSeguro# 0) ;
         PICTURE cPictDes SIZE 50,7 Of oPanel
   ENDIF

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,;
                               {||oDlg:End()},;
                               {||oDlg:End()}) CENTERED

MTotFOB := PValor + TInland + TFreteIntl + TPacking - TDesconto + TOutDesp + TSeguro

*IF PTipo = "A"
   *E_Msg(STR0179,1000,.t.) //"incluir get despesas na alteracao"
*ENDIF

IF MTotFOB < 0 //1-LGS-01/08/2014
   MsgInfo(STR0390)
   RETURN .F.
ENDIF

RETURN .T.

*-------------------------------------------------------------------------*
FUNCTION LoteMinimoMaximo( QtdeDigitada, LoteMinimo, LoteMultiplo, TipoQtde )  // Robson 13:31 29 Dec,1994   // VI
*-------------------------------------------------------------------------*
LOCAL QtdeApurada := 0

IF QtdeDigitada < LoteMinimo
   QtdeApurada := LoteMinimo
   TipoQtde        := "Lt. Minimo"
ELSE
   IF ! EMPTY( LoteMultiplo )
      TipoQtde  := "Lt. Multiplo"
      IF QtdeDigitada < LoteMultiplo
         QtdeApurada := LoteMultiplo
      ELSE
         IF MOD(QtdeDigitada,LoteMultiplo) <> 0
            QtdeApurada := (INT(QtdeDigitada/LoteMultiplo)+1) * LoteMultiplo
         ENDIF
      ENDIF
   ENDIF
ENDIF

RETURN QtdeApurada

*-----------------------------------*
FUNCTION PO410BuscUN(PChave,PChave1)  //CASO SEJA UTILIZADO EM RDMAKE
*-----------------------------------*
Return BUSCA_UM(PChave,PChave1)

*--------------------
FUNCTION PO410Estorno
*--------------------
LOCAL lMarcou := .F., lRecno := RECNO()
Local lRet    := .T.
LOCAL MMESAGE
PRIVATE cMensa :=STR0009  //"Estorno"
DBGOTOP()
DBEVAL({||lMarcou:=.T.},{||Work->WKFLAG .OR. Work->WKFLAGWIN == cMarca },{||!lMarcou})
DBGOTO(lRecno)

DBSELECTAREA("Work")
If lPOAuto .AND. nOpcAuto == 5   // GFP - 15/10/2013
   Work->(DbGoTop())
   Do While Work->(!Eof())
      WORK->WKFLAG := .T.
      lMarcou:=.T.
      Work->(DbSkip())
   EndDo
   Work->(DbGoTop())
EndIf

IF ! lMarcou
   Help(" ",1,"E_SEMMARCA")
   Return .F.
ENDIF

IF EasyGParam("MV_EASY",,"N") == "S"  // GFP - 24/09/2015
   IF EasyGParam("MV_EIC_PCO",,.F.) .And. SW2->W2_IMPCO == "1" .And. !EasyGParam("MV_PCOIMPO",,.T.) //LRS - 01/03/2018
       SC7->(dbSetOrder(3))
       SYT->(dbSetOrder(1))
       SYT->(DBSeek(xFilial() + SW2->W2_IMPORT))
       SC7->(Dbseek(xFilial("SC7") + SYT->YT_FORN + AVKEY(SYT->YT_LOJA,"A2_LOJA") + SW2->W2_PO_SIGA))
   Else
       SC7->(dbSetOrder(3))
       SC7->(Dbseek(xFilial("SC7") + SW2->W2_FORN + AVKEY(SW2->W2_FORLOJ,"A2_LOJA") + SW2->W2_PO_SIGA))
   EndIF
ENDIF

lSairEst:=.F.

IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"ANTES_ESTORNO_PO"),)

IF lSairEst
   Return .F.
ENDIF

If ( Type("lPOAuto") == "U" .OR. !lPOAuto )
IF MsgYesNo(STR0184+cLitPerg+STR0185,STR0186) # .T. //"Confirma o "###" deste P.O. ? "###"Confirmação"
   Return .F.
   ENDIF
ENDIF

EICPO410(3)

IF lAlcada   //CCH - 08/06/09 - Controle de geração de títulos provisórios quando controle de alçadas estiver ligado
   IF SW2->(FIELDPOS("W2_CONAPRO")) # 0 .AND. SW2->W2_CONAPRO = "L"
      EICFI400("ANT_GRV_PO","E")
   ENDIF
ELSE
   EICFI400("ANT_GRV_PO","E")
ENDIF
   IF AvFlags("EIC_EAI")
      DBSELECTAREA("Work")
      SET FILTER TO
      IF !EICPO420(.T.,5,,"SW2",.T.)//JL
         RETURN .F.
      endif
   ENDIF

If !( Type("lPoAuto")=="L" .And. lPoAuto) //FSM - 17/05/2012
   Processa({|| lRet := PO_Estorno({|msg|MsProcTxt(msg)})},STR0187) //"Estorno em andamento..."
Else
   lRet := PO_Estorno()
EndIf

IF(lRet .And. EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"DEPOIS_ESTORNO_PO"),)

IF lRet .And. lAlcada   //CCH - 08/06/09 - Controle de geração de títulos provisórios quando controle de alçadas estiver ligado
   IF SW2->(FIELDPOS("W2_CONAPRO")) # 0 .AND. SW2->W2_CONAPRO = "L"
      EICFI400("POS_GRV_PO","E")
   ENDIF
ELSEIF lRet
   EICFI400("POS_GRV_PO","E")
ENDIF

Return lRet

*----------------------------------------------------------------------------
FUNCTION PO_Estorno(bMsg)
*----------------------------------------------------------------------------
LOCAL TPO_NUM:=SW2->W2_PO_NUM, aDados:={},TPO_SIGA
LOCAL cCCSI:='', cSI:=''
LOCAL lW2ConaPro := SW2->(FIELDPOS("W2_CONAPRO")) # 0 .AND. EasyGParam("MV_AVG0170",,.F.)  //TRP-28/08/08- Teste do parâmetro MV_AVG0170 para definir se habilita Controle de Alçadas no EIC.
LOCAL aRegTri := {}, cFilEIJ := xFilial("EIJ")
Local i
Local nInc
Local nPOsC,nPosi
Local lRet:= .T.
Local lSC3:= .F.
Local aOrdSC3 := {} //LGS-24/03/2015
PRIVATE lContinua := .T.  //TRP-11/03/2008 - Flag criada para cliente Pão de Açúcar (chamado 071740)
Private lEstornaCapa := .F.  // GFP - 08/04/2014

If Type("lPoAuto") == "U"
   lPoAuto:= .F.
EndIf

TPO_SIGA:=SW2->W2_PO_SIGA

SW5->(DBSETORDER(3))

DBSELECTAREA("Work")
If !(lPoAuto) //FSM - 17/05/2012
   ProcRegua(LASTREC()+3)
EndIf
Work->(DBGOTOP())
Ind:= 1
MMes:= PADL(MONTH(SW2->W2_PO_DT),2,"0")
M->W2_HAWB_DA:=''

//AOM - 09/04/2011 - Salva controle de operações especiais do PO
If lOperacaoEsp
   oOperacao:SaveOperacao()
EndIf

*----------------
Begin Transaction
*----------------

DO WHILE .NOT. Work->(EOF())

   If !(lPoAuto) //FSM - 17/05/2012
      IncProc(STR0188+ALLTRIM(Work->WKCC)+STR0189+ALLTRIM(Work->WKSI_NUM)+STR0190+ALLTRIM(Work->WKCOD_I)) //"Estornando UR: "###" SI: "###" Item: "
   EndIf

// IF ! WKFLAG .AND. ! WKFLAGWIN == cMarca
   IF ! Work->WKFLAGWIN == cMarca
      // EOB - 21/01/10 - Gera array com os regimes que ficaram no PO
      IF lRegTriPO .AND. !EMPTY(Work->WKGRUPORT) .AND. ASCAN(aRegTRi,Work->WKGRUPORT) == 0
         AADD( aRegTri, Work->WKGRUPORT )
      ENDIF

      Work->(DBSKIP())
      LOOP
   ENDIF

   aDados:={Work->WKCOD_I,Work->WKPOSICAO,Work->WKFORN}

   DBSELECTAREA("Work")
   nQtde_IS:=0

   // ACSJ - 28/05/2004 - Criação de ponto de entrada para gravação de arquivo de muro para a MERCK
   IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"Estorno"),)

   IF Work->WKFLUXO == "7"
      IF Work->WKQTDE_EMB == 0
         Po420_EstIG()
         Po420_IpPos("3")                   // DELETA SEQUENCIA 1
         SW3->(DBGOTO(Work->WKRECNO))
         RecLock("SW3",.F.,.T.)

         SW0->(dbSeek(xFilial()+SW3->(W3_CC+W3_SI_NUM)))
         If cProg#"PN" .AND. EMPTY(ALLTRIM(SW0->W0_HAWB_DA))
            //ACB - 18/03/2011 - envio do centro de custo ao compras
            If lCpoCtCust
               cCentroCusto := SW3->W3_CTCUSTO
            Else
               cCentroCusto := SW3->W3_CC
            EndIf

            If !lEXECAUTO_COM
               AVGravaSC7(EXCLUSAO,SW3->W3_COD_I,SW3->W3_QTDE,SW3->W3_PRECO,;
                         IF(!EMPTY(ALLTRIM(SW2->W2_PO_SIGA)),SW2->W2_PO_SIGA,LEFT(SW3->W3_PO_NUM,6)),SW0->W0__POLE,cCentroCusto,;
                         SW3->W3_FORN,If(EICLoja(), SW3->W3_FORLOJ, '01'),SW2->W2_PO_DT,;
                         SW0->W0_C1_NUM,SW3->W3_DT_ENTR,SW3->W3_POSICAO,SW3->W3_POSICAO,;
                         Nil,"EICPO400",Nil,SW3->W3_SI_NUM,SW3->W3_REG,SW2->W2_MOEDA,"N")
            EndIf
         EndIf

         SW3->(DBDELETE())
         SW3->(MsUnlock())
      ELSE
         SW3->(DBGOTO(Work->WKRECNO))
         IF Po420_IgPos("3")
            RecLock("SW5",.F.)
            SW5->W5_QTDE    := Work->WKQTDE_EMB
            SW5->W5_SALDO_Q:= 0
            SW5->(MsUnlock())
         ENDIF
         IF Po420_IpPos("1")
            RecLock("SW3",.F.)
            SW3->W3_QTDE:= Work->WKQTDE_EMB
            SW3->(MsUnlock())
         ENDIF

         SW3->(DBGOTO(Work->WKRECNO))
         RecLock("SW3",.F.)


         SW3->W3_QTDE   :=Work->WKQTDE_EMB
         SW3->W3_SALDO_Q:=0
         SW3->(MsUnlock())


         SW0->(dbSeek(xFilial()+SW3->(W3_CC+W3_SI_NUM)))
         If cProg#"PN" .AND. EMPTY(ALLTRIM(SW0->W0_HAWB_DA))
            //ACB - 18/03/2011 - Envio do centro de custo ao compras.
            If lCpoCtCust
               cCentroCusto := SW3->W3_CTCUSTO
            Else
               cCentroCusto := SW3->W3_CC
            EndIf

            If !lEXECAUTO_COM
               AVGravaSC7(ALTERACAO,SW3->W3_COD_I,SW3->W3_QTDE,SW3->W3_PRECO,;
                        IF(!EMPTY(ALLTRIM(SW2->W2_PO_SIGA)),SW2->W2_PO_SIGA,LEFT(SW3->W3_PO_NUM,6)),SW0->W0__POLE,cCentroCusto,;
                        SW3->W3_FORN,If(EICLoja(), SW3->W3_FORLOJ, '01'),SW2->W2_PO_DT,;
                        SW0->W0_C1_NUM,SW3->W3_DT_ENTR,SW3->W3_POSICAO,SW3->W3_POSICAO,;
                        Nil,"EICPO400",Nil,SW3->W3_SI_NUM,SW3->W3_REG,SW2->W2_MOEDA,"N",SW3->W3_PO_NUM,,SW2->(W2_INLAND+W2_PACKING+W2_OUT_DES+W2_FRETEIN),SW2->W2_DESCONT)  //Acb - 08/10/2010 - Incluido parametro com numero do PO
            EndIf
         EndIf

         nQtde_IS:= Work->WKQTDE_EMB
         MConta:= MConta - 1
      ENDIF
   ELSE
      SW3->(DBGOTO(Work->WKRECNO))
      RecLock("SW3",.F.)
      IF Work->WKQTDE == Work->WKSALDO_Q

         SW0->(dbSeek(xFilial()+SW3->(W3_CC+W3_SI_NUM)))
         If cProg#"PN" .AND. EMPTY(ALLTRIM(SW0->W0_HAWB_DA))
            //ACB - 18/03/2011 - envio do centro de custo ao compras
            If lCpoCtCust
               cCentroCusto := SW3->W3_CTCUSTO
            Else
               cCentroCusto := SW3->W3_CC
            EndIf
            If !lEXECAUTO_COM
               AVGravaSC7(EXCLUSAO,SW3->W3_COD_I,SW3->W3_QTDE,SW3->W3_PRECO,;
                        IF(!EMPTY(ALLTRIM(SW2->W2_PO_SIGA)),SW2->W2_PO_SIGA,LEFT(SW3->W3_PO_NUM,6)),SW0->W0__POLE,cCentroCusto,;
                        SW3->W3_FORN,If(EICLoja(), SW3->W3_FORLOJ, '01'),SW2->W2_PO_DT,;
                        SW0->W0_C1_NUM,SW3->W3_DT_ENTR,SW3->W3_POSICAO,SW3->W3_POSICAO,;
                        Nil,"EICPO400",Nil,SW3->W3_SI_NUM,SW3->W3_REG,SW2->W2_MOEDA,"N")
            EndIf
         EndIf

         SW3->(DBDELETE())

         nQtde_IS:=0
         MConta:= MConta - 1
      ELSE
         SW3->W3_QTDE   := Work->WKQTDE - Work->WKSALDO_Q
         SW3->W3_SALDO_Q:= 0
         nQtde_IS:= Work->WKQTDE - Work->WKSALDO_Q

         SW0->(dbSeek(xFilial()+SW3->(W3_CC+W3_SI_NUM)))
         If cProg#"PN" .AND. EMPTY(ALLTRIM(SW0->W0_HAWB_DA))
            //ACB - 18/03/2011 - envio do centro de custo ao compras
            If lCpoCtCust
               cCentroCusto := SW3->W3_CTCUSTO
            Else
               cCentroCusto := SW3->W3_CC
            EndIf
            If !lEXECAUTO_COM
               AVGravaSC7(ALTERACAO,SW3->W3_COD_I,SW3->W3_QTDE,SW3->W3_PRECO,;
                        IF(!EMPTY(ALLTRIM(SW2->W2_PO_SIGA)),SW2->W2_PO_SIGA,LEFT(SW3->W3_PO_NUM,6)),SW0->W0__POLE,cCentroCusto,;
                        SW3->W3_FORN,If(EICLoja(), SW3->W3_FORLOJ, '01'),SW2->W2_PO_DT,;
                        SW0->W0_C1_NUM,SW3->W3_DT_ENTR,SW3->W3_POSICAO,SW3->W3_POSICAO,;
                        Nil,"EICPO400",Nil,SW3->W3_SI_NUM,SW3->W3_REG,SW2->W2_MOEDA,"N",SW3->W3_PO_NUM,,SW2->(W2_INLAND+W2_PACKING+W2_OUT_DES+W2_FRETEIN),SW2->W2_DESCONT) //Acb - 08/10/2010 - Incluido parametro com numero do PO
            EndIf
         EndIf
      ENDIF
      SW3->(MsUnlock())
   ENDIF

   nQtde_Sub:=0

   DBSELECTAREA("SW1")
   DBSETORDER(2)
   //TRP-11/03/2008- Variável lContinua para, caso .F. desviar o IF abaixo. Tratada no ponto de entrada Estorno e utilizada para o cliente pão de açúcar.
   IF lContinua
      IF PosO2_IT_Solic(TPO_NUM, Work->WKCC, Work->WKSI_NUM, Work->WKCOD_I, ;
                        Work->WKFABR, Work->WKFORN, Work->WKREG, IF(EICLOJA(),Work->W3_FABLOJ,""),IF(EICLOJA(), Work->W3_FORLOJ,""))

         cCCSI:=SW1->W1_CC
         cSI:=SW1->W1_SI_NUM

         IF nQtde_IS == 0
            nQtde_Sub:= SW1->W1_QTDE
            RecLock("SW1",.F.,.T.)
            SW1->(DBDELETE())
         ELSE
            nQtde_Sub:= SW1->W1_QTDE - nQtde_IS
            RecLock("SW1",.F.)
            SW1->W1_QTDE:= nQtde_IS
         ENDIF

         SW1->(MsUnlock())
      ENDIF
   ENDIF

   DBSELECTAREA("SW1")
   SW1->(DBSETORDER(1))
   IF PosO1_IT_Solic(Work->WKCC, Work->WKSI_NUM, Work->WKCOD_I, Work->WKREG, 0)
      RecLock("SW1",.F.)     // lock p/ replace
      SW1->W1_SALDO_Q := SW1->W1_SALDO_Q + nQtde_Sub
      SW1->(MSUnlock())

      //LGS-23/03/2015 - Atualiza a quantidade utilizada no item correspondente da 'SC3' qdo for 'CONTRATO'
      If SW0->(FieldPos("W0_CONTR"))>0 .And. SW2->(FieldPos("W2_CONTR"))>0 .AND. !lEXECAUTO_COM //AAF 30/12/2016 - Nao executar caso seja execauto, pois o mesmo ja atualiza o contrato.
         If SW2->W2_CONTR == '1'
            aOrdSC3 := SaveOrd({"SC3"})
            SC3->(DbSetOrder(1))
            If SC3->(DbSeek(xFilial("SC3")+SW1->(W1_C3_NUM+W1_POSIT)))
               If !SC3->(IsLocked())
                  SC3->(RecLock("SC3",.F.))
                  lSC3 := .T.
               EndIf
               SC3->C3_QUJE := SW1->(W1_QTDE - W1_SALDO_Q)
               If lSC3
                  SC3->(MsUnLock())
               EndIf
            EndIf
            RestOrd(aOrdSC3,.T.)
         EndIf
      EndIf

   ENDIF

   DBCOMMIT()

   DBSELECTAREA("Work")
   Work->(DBSKIP())
ENDDO

lEstornaCapa:=.T.  // GFP - 08/04/2014

//EXECAUTO
If lPOAuto
   If nOpcAuto == 5

      If Len(aDeletaAuto) > 0
         For i:= 1 to Len(aDeletaAuto)

            If (nPOsC := aScan(aDeletaAuto[i][1], {|x| x[1] == "W0__CC" })) > 0
               cCCusto:= aDeletaAuto[i][1][nPOsC][2]
            EndIf

            If (nPOSi := aScan(aDeletaAuto[i][1], {|x| x[1] == "W0__NUM" })) > 0
               cSiNum:= aDeletaAuto[i][1][nPOSi][2]
            EndIf

            nInc:= 0
            cFilSW0:= xFilial("SW0")

            aOrdAut := SaveOrd({"SW1"})

            SW1->(DbSetOrder(1))
            If SW1->(DbSeek(xFilial("SW1")+AvKey(cCCusto,"W1_CC")+AvKey(cSiNum,"W0__NUM")))
               DO WHILE !SW1->(EOF()) .AND. SW1->W1_CC = cCCusto .AND. SW1->W1_SI_NUM = cSiNum .And. SW1->W1_FILIAL == cFilSW0 .AND. nInc <= 1

                  nInc++

                  SW1->(DbSkip())
               Enddo
            Endif

            RestOrd(aOrdAut,.T.)

            If nInc > 1
               lRet:= MSExecAuto({|a,b,c,d| EICSI400(a,b,c)},aDeletaAuto[i][1],aDeletaAuto[i][2],4)
            Elseif nInc == 1
               lRet:= MSExecAuto({|a,b,c,d| EICSI400(a,b,c)},aDeletaAuto[i][1],aDeletaAuto[i][2],5)
            Endif
          Next i
      Endif
   Endif
Endif

PO_FILTER(.F.)
If !(lPoAuto) //FSM - 17/05/2012
   IncProc(STR0191) //"Processando Ocorrencias"
EndIf

If(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"Antes_Estona_Capa"),)

IF lEstornaCapa

   SW3->(DBSETORDER(7)) // FILIAL+PO+SEQ
   IF ! SW3->(DBSEEK(xFilial("SW3")+TPO_NUM))

      DBSELECTAREA("SW2")
      SW2->(DBSETORDER(1))
      SW2->(DBSEEK(xFilial("SW2")+TPO_NUM))
      IF EasyEntryPoint("EICPPO02")
         ExecBlock("EICPPO02",.T.,.T.,"25")
      ENDIF
      MSMM(SW2->W2_OBS,,,,2)   // exclui campo memo

      SW0->(DBSETORDER(1))
      SW1->(DBSETORDER(1))
      SW6->(DBSETORDER(1))
      If cProg="PN"
         M->W2_HAWB_DA:=SW2->W2_HAWB_DA
         If ! EMPTY(ALLTRIM(SW2->W2_HAWB_DA)) .AND. ! EMPTY(cCCSI) .AND. ! EMPTY(cSI)
            If SW0->(DBSEEK(xFilial('SW0')+cCCSI+cSI))
               SW1->(DBSEEK(xFilial('SW1')+cCCSI+cSI))
               Do While ! SW1->(Eof()) .AND. cCCSI=SW1->W1_CC .AND.;
                          cSI=SW1->W1_SI_NUM .AND. xFilial("SW1")=SW1->W1_FILIAL
                  RecLock('SW1',.F.,.T.)
                  SW1->(DBDELETE())
                  SW1->(MsUnlock())
                  SW1->(DBSKIP())
               EndDo
               RecLock('SW0',.F.,.T.)
               SW0->(DBDELETE())
               SW0->(MsUnlock())
            EndIf
            If SW6->(DBSEEK(xFilial('SW6')+M->W2_HAWB_DA))
               RecLock('SW6',.F.)
               SW6->W6_NACIONA:='2'
               SW6->(MsUnlock())
            EndIf
         EndIf
      EndIF
      If(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"EstornoCapa"),)
      RecLock('SW2',.F.,.T.)
      SW2->(DBDELETE())
      SW2->(MsUnlock())
   ELSE
      MFob_Abs := 0 ; MQtos_Abs := 0

      DO WHILE ! SW3->(EOF()) .AND. SW3->W3_PO_NUM = TPO_NUM .and. SW3->W3_FILIAL==xFilial("SW3")
         IF SW3->W3_SEQ # 0
            EXIT
         ENDIF
         MFob_Abs +=  SW3->W3_QTDE * SW3->W3_PRECO
         MQtos_Abs ++
         SW3->(DBSKIP())
      ENDDO

      IF MQtos_Abs > 0
         RecLock("SW2",.F.)
         SW2->W2_FOB_TOT := MFob_Abs
         SW2->(MsUnlock())
      ENDIF
   ENDIF

   //Tratamento para geração do pedido de compras via rotina automática
   //19/04/11
   If lEXECAUTO_COM .And. cProg#"PN" //MCF - 30/06/2015
      lRet := PO400GravaPC(nOpcAux)
      If !lRet
         lRetExecAuto:= .F.   //RNLP - 16/07/20 - retorno da execAuto do modulo compras falhou, dessa forma, nao prossegue na operação via SIGAEIC
         DisarmTransaction()      
      EndIf   
   EndIf

   // EOS - estorna pedido (total ou parcial) do controle de alcada
   If lRet .And. cMV_EASY$cSim .AND. cProg#"PN" .And. lW2ConaPro
      MaAlcDoc({TPO_SIGA,"PC",0,NIL,NIL,NIL},,3)

      SW2->(DBSETORDER(1))
      IF SW2->(DBSEEK(xFilial("SW2")+TPO_NUM))
         // EOS - Pegar moeda correspondente ao SIGACOM
         SYF->(dbSetOrder(1))
         IF SYF->(dbSeek(xFilial("SYF") + SW2->W2_MOEDA))
            nMoe_Com := SYF->YF_MOEFAT
         ENDIF
         MaAlcDoc({TPO_SIGA,"PC",SW2->W2_FOB_TOT,,,SY1->Y1_GRAPROV,,nMoe_Com,,SW2->W2_PO_DT},,1)
      EndIf
   EndIf
ENDIF

If lRet
Grava_Ocor(TPO_NUM,dDataBase,If(EMPTY(ALLTRIM(M->W2_HAWB_DA)),STR0192,STR0223) + IF(MConta = 0,STR0193,STR0194),STR0195) //'ESTORNO DO P.O. - '###'TOTAL'###'SALDO'###"PO"
EndIf

// EOB - 21/01/10 - Estorno dos grupos de regime de tributação
IF lRet .And. lRegTriPO
   EIJ->(dbSetOrder(2))
   EIJ->(dbSeek(cFilEIJ + TPO_NUM))
   DO WHILE !EIJ->(EOF()) .AND. EIJ->EIJ_PO_NUM == TPO_NUM
      IF ASCAN(aRegTri, EIJ->EIJ_ADICAO) == 0
         RecLock("EIJ", .F.)
         EIJ->(dbDelete())
         EIJ->(MsUnlock())
      ENDIF
      EIJ->(dbSkip())
   ENDDO
ENDIF

PO_FILTER(.T.)
*----------------
End Transaction
*----------------

If lRet .And. !(lPoAuto) //FSM - 17/05/2012
   IncProc(STR0191) //"Processando Ocorrencias"
EndIf

MControla:= .F.
DBSELECTAREA("Work")
DBGOTOP()
//RETURN .T.
RETURN lRet
*----------------------------------------------------------
* FIM DO PROGRAMA EICPO400.PRW
*----------------------------------------------------------


*------------------------------------------------------------------------------
FUNCTION PO_InitWork(bMsg,lRetorno,FileWork,WorkNTX2,cTipRot)  // VI
*------------------------------------------------------------------------------
LOCAL i:=0, aEIJ := {}, cAliasWkTmp
// aDBF_Stru eh private por causa dos rdmakes
aDBF_Stru:={{"WKCOD_I"    ,"C",AVSX3("W3_COD_I",3),0},{"WKDESCR"   ,"C",AVSX3("B1_VM_" + cDESC_PO,3),0} ,;
            {"WKFABR"     ,"C",nLenFabr ,0},{"WKFABR_O"  ,"C",nLenFAbr,0}  ,;
            {"WKNOME_FAB" ,"C",15,0},{"WKFORN"    ,"C",nLenForn,0}  ,;
            {"WKFORN_O"   ,"C",nLenForn,0},{"WKNOME_FOR","C",15,0} ,;
            {"WKCOMPRADO","N", 3,0},{"WKREG"     ,"N",AVSX3("W3_REG",3),0}  ,;
            {"WKFLUXO"    ,"C", 1,0},;
            {"WKQTDE"    ,"N",AVSX3("W3_QTDE",3),AVSX3("W3_QTDE",4)} ,;
            {"WKQTDE_O"  ,"N",AVSX3("W3_QTDE",3),AVSX3("W3_QTDE",4)}    ,;
            {"WKPRECO"   ,"N",AVSX3("W3_PRECO",3),AVSX3("W3_PRECO",4)},;
            {"WKSALDO_Q" ,"N",AVSX3("W3_SALDO_Q",3),AVSX3("W3_SALDO_Q",4)} ,;
            {"WKSALDO_O" ,"N",AVSX3("W3_SALDO_Q",3),AVSX3("W3_SALDO_Q",4)},;
            {"WKCC"      ,"C",nLenCC,0}  ,;
            {"WKCC_O","C",nLenCC,0},{"WKSI_ORI","C",nLenSi,0} ,;
            {"WKSI_NUM"   ,"C", nLenSi,0},{"WKPO_NUM"  ,"C",AvSx3("W2_PO_NUM", AV_TAMANHO),0} ,;
            {"WKCDPOCOPY"  ,"C",AvSx3("W2_PO_NUM", AV_TAMANHO),0},;
            {"WKDT_EMB"   ,"D", 8,0},{"WKDT_ENTR" ,"D",8,0}  ,;
            {"WKDTENTR_S" ,"D", 8,0},{"WKFLAG"    ,"L",1,0}  ,;
            {"WKSEQ"      ,"N", 2,0},{"WKFLAG2"   ,"L",1,0}  ,;
            {"WKPORTARIA" ,"N", 2,0},{"WKFABR_01" ,"C",6,0}  ,;
            {"WKFABR_02"  ,"C", nLenFabr,0},{"WKFABR_03" ,"C",nLenFabr,0}  ,;
            {"WKFABR_04"  ,"C", nLenFabr,0},{"WKFABR_05" ,"C",nLenFabr,0}  ,;
            {"WKREC_SI"   ,"N", 7,0},{"WKPOSICAO" ,"C",LEN(SW3->W3_POSICAO),0}  ,;
            {"WKPSPOCOPY" ,"C",LEN(SW3->W3_POSICAO),0}  ,;
            {"WKDTEMB_S"  ,"D", 8,0},;
            {"WKPRECO_S"  ,"N",AVSX3("W3_PRECO" ,3),AVSX3("W3_PRECO" ,4)} ,;
            {"WKSALDO_GI" ,"N",AVSX3("W3_QTDE" ,3),AVSX3("W3_QTDE" ,4)},;
            {"WKQTDE_GI"  ,"N",AVSX3("W3_QTDE" ,3),AVSX3("W3_QTDE" ,4)} ,;
            {"WKFLUXO_O"  ,"C", 1,0},{"WKDESCONTO","N",18,8} ,;
            {"WKPACKING"  ,"N",AVSX3("W6_PACKING",3),AVSX3("W6_PACKING" ,4)},;
            {"WKOUT_DESP" ,"N",AVSX3("W6_FOB_TOT" ,3),AVSX3("W6_FOB_TOT" ,4)} ,;
            {"WKUNI"      ,"C", 3,0},{"WKFLAGWIN" ,"C", 2,0} ,;
            {"WKFLAGWIN2" ,"C", nLenOk,0},;
            {"WKPRTOT"    ,"N",AVSX3("W6_FOB_TOT" ,3),AVSX3("W6_FOB_TOT" ,4)} ,;
            {"WK_ALTEROU" ,"L",01,0},{"WK_REG_TRI","C",01,0} ,;
            {"WK_TEC"     ,"C",10,0},{"WK_EX_NCM" ,"C",LEN(SB1->B1_EX_NCM),0} ,;
            {"WK_EX_NBM"  ,"C",LEN(SB1->B1_EX_NBM),0}, {"WKMOTIVO", "C",60,0},;
            {"WKPESO_L","N",AVSX3("W5_PESO",3),AVSX3("W5_PESO",4)},;
            {"WKSEM_PO","N",15,5}  , {"WKQTDE_EMB","N",15,5}, {"WKQTDE_LI","N",15,5},;
            {"TRB_ALI_WT","C",03,0},; //TRP - 25/01/07 - Campos do WalkThru
            {"TRB_REC_WT","N",10,0},;
            {"WKREC_SW3"   ,"N",7,0},;//SVG -16/12/2008
            {"WKFLAGEIJ","C",2,0},;   // JWJ
            {"WKPOSIT"  ,"C",4,0}} //LGS-24/10/13
lSiCopia:=.F.;lSiReferencia:=.F. //Para controlar na Inclusao Opcoes CopiaPO/SiReferncia

EICAddWkLoja(aDBF_Stru, "W3_FABLOJ", "WKFABR")
EICAddWkLoja(aDBF_Stru, "W3_FORLOJ", "WKFORN")
EICAddWkLoja(aDBF_Stru, "W3_FAB1LOJ", "WKFABR_01")
EICAddWkLoja(aDBF_Stru, "W3_FAB2LOJ", "WKFABR_02")
EICAddWkLoja(aDBF_Stru, "W3_FAB3LOJ", "WKFABR_03")
EICAddWkLoja(aDBF_Stru, "W3_FAB4LOJ", "WKFABR_04")
EICAddWkLoja(aDBF_Stru, "W3_FAB5LOJ", "WKFABR_05")

If EICLoja()
   AADD(aDBF_Stru,{"W3_FABL_O", AvSx3("W3_FABLOJ", AV_TIPO), AVSX3("W3_FABLOJ", AV_TAMANHO), AVSX3("W3_FABLOJ", AV_DECIMAL)})
   AADD(aDBF_Stru,{"W3_FORL_O", AvSx3("W3_FORLOJ", AV_TIPO), AVSX3("W3_FORLOJ", AV_TAMANHO), AVSX3("W3_FORLOJ", AV_DECIMAL)})
EndIf

If SW3->(FieldPos("W3_PESOL")) # 0 //CCH - 07/08/09 - Gravação do novo campo de Peso Líquido Unitário
   AADD(aDBF_Stru,{"WKPESOL","N",AVSX3("W3_PESOL",3),AVSX3("W3_PESOL",4)})
EndIf

IF(lSeal,ExecBlock("IC193PO1",.F.,.F.,"2"),) //AWR 01/10/1999
IF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"8"),)//AWR 09/11/1999

IF lExiste_Midia//AWR 21/10/1999
   AADD(aDBF_Stru,{"WK_QTMIDIA",AVSX3("B1_QTMIDIA",2),AVSX3("B1_QTMIDIA",3),AVSX3("B1_QTMIDIA",4)})
   AADD(aDBF_Stru,{"WK_VLTOTMI",AVSX3("W2_VLMIDIA",2),AVSX3("W2_VLMIDIA",3),AVSX3("W2_VLMIDIA",4)})
ENDIF

//AOM - 07/04/2011 - Criação dos campos cod. ope Esp. e Desc ope. Esp. na Work_SW3 - para copiar um PO para outro
If lOperacaoEsp
   AADD(aDBF_Stru,{"W3_CODOPE",AVSX3("W3_CODOPE",2),AVSX3("W3_CODOPE",3),AVSX3("W3_CODOPE",4)})
   AADD(aDBF_Stru,{"W3_DESOPE",AVSX3("W3_DESOPE",2),AVSX3("W3_DESOPE",3),AVSX3("W3_DESOPE",4)})
EndIf

//FSM - 16/05/2012 - Admissão em Entreposto
If EasyGParam("MV_AVG0211",,.F.)  .And. SW3->(FieldPos("W3_ALTANU")) > 0
   AADD(aDBF_Stru,{"WKALTANU", AVSX3("W3_ALTANU",2), AVSX3("W3_ALTANU" ,3), AVSX3("W3_ALTANU" ,4)})
EndIf

If !( Type("lPoAuto")=="L" .And. lPoAuto) //FSM - 17/05/2012
   ProcRegua(3)
EndIf

AADD(aDBF_Stru,{"WKKIT","C",15,0})
AADD(aDBF_Stru,{"WKSERIE"  ,"C",30,0})
//AADD(aDBF_Stru,{"WKQTDKIT","N",9,3})
AADD(aDBF_Stru,{"WKQTDKIT",AVSX3("W0_QTDE",2),AVSX3("W0_QTDE",3),AVSX3("W0_QTDE",4)})//ASR 15/12/2005 - BUSCA DO DICIONARIO
AADD(aDBF_Stru,{"WK_REG_MIN","C",AVSX3("W3_REG_MIN",3),0})
IF cPaisLoc # "BRA"  .AND. SW1->(FIELDPOS("W1_NATUREZ")) # 0
   AADD(aDBF_Stru,{"WKNATUREZA","C",AVSX3("W1_NATUREZ",3),0})
ENDIF
If lForeCast
   AADD(aDBF_Stru,{"WK_FORECAS","C",1,0})
Endif

If SW3->(FIELDPOS("W3_PART_N")) # 0    //ASK 02/10/2007
   AADD(aDBF_Stru,{"WKPART_N","C",LEN(IF(SW3->(FieldPos("W3_PART_N")) # 0,SW3->W3_PART_N,SA5->A5_CODPRF)),0})
EndIf

//TRP- 01/06/09 - Campo Software para novo Tratamento de Mídia e Software
If SW3->(FieldPos("W3_SOFTWAR")) # 0 .And. EasyGParam("MV_CONSOFT",, "N") $ cSim
   AADD(aDBF_Stru,{"WKSOFTWAR",AVSX3("W3_SOFTWAR",2),AVSX3("W3_SOFTWAR",3),AVSX3("W3_SOFTWAR",4)})
Endif
If SW3->(FieldPos("W3_SLD_ELI")) > 0 //SVG - 23/02/2011 -
   AADD(aDBF_Stru,{"WKSLD_ELI","N",AVSX3("W3_SLD_ELI",3),AVSX3("W3_SLD_ELI",4)})
EndIf

If lCpoCtCust
   AADD(aDBF_Stru,{"WKCTCUSTO",AVSX3("W3_CTCUSTO",2),AVSX3("W3_CTCUSTO",3),AVSX3("W3_CTCUSTO",4)})
EndIf
If lPesoBruto                                                                                    //NCF - 25/08/2011 - Campo do Peso Bruto Unitário
   AADD(aDBF_Stru,{"WKPSBRUTO",AVSX3("W3_PESO_BR",2),AVSX3("W3_PESO_BR",3),AVSX3("W3_PESO_BR",4)})
EndIf
If AvFlags("RATEIO_DESP_PO_PLI")
   AADD(aDBF_Stru,{"WKFRETE",AVSX3("W3_FRETE",2)  ,AVSX3("W3_FRETE",3)  ,AVSX3("W3_FRETE",4)})
   AADD(aDBF_Stru,{"WKSEGUR",AVSX3("W3_SEGURO",2) ,AVSX3("W3_SEGURO",3) ,AVSX3("W3_SEGURO",4)})
   AADD(aDBF_Stru,{"WKINLAN",AVSX3("W3_INLAND",2) ,AVSX3("W3_INLAND",3) ,AVSX3("W3_INLAND",4)})
   AADD(aDBF_Stru,{"WKDESCO",AVSX3("W3_DESCONT",2),AVSX3("W3_DESCONT",3),AVSX3("W3_DESCONT",4)})
   AADD(aDBF_Stru,{"WKPACKI",AVSX3("W3_PACKING",2),AVSX3("W3_PACKING",3),AVSX3("W3_PACKING",4)})
   If SW3->(FieldPos("W3_OUT_DES")) > 0
      AADD(aDBF_Stru,{"WKOUTDE",AVSX3("W3_OUT_DES",2),AVSX3("W3_OUT_DES",3),AVSX3("W3_OUT_DES",4)})
   EndIf
EndIf
//EOB - 04/01/10 - Inclusão do campo referente ao grupo de regime de tributação na Work dos itens do PO
If lRegTriPO
   AADD(aDBF_Stru,{"WKGRUPORT",AVSX3("W3_GRUPORT",2),AVSX3("W3_GRUPORT",3),AVSX3("W3_GRUPORT",4)})
Endif

IF AvFlags("EIC_EAI")//AWF - 25/06/2014
   AADD(aDBF_Stru,{"WKSEGUM"  ,"C",AVSX3("W3_SEGUM"  ,3),0})
   AADD(aDBF_Stru,{"WKQTSEGUM","N",AVSX3("W3_QTSEGUM",3),AVSX3("W3_QTSEGUM" ,4)})
   AADD(aDBF_Stru,{"WKFATOR"  ,"N",AVSX3("J5_COEF"   ,3),AVSX3("J5_COEF",4)})
   If SW0->(FieldPos("W0_REFER1")) > 0 //NCF - 26/09/2016
      AADD(aDBF_Stru,{"WKREFER1"  ,"C",AVSX3("W0_REFER1"   ,3),AVSX3("W0_REFER1",4)})
   EndIf
ENDIF

If lNestle
   ExecBlock(cArqNestle,.F.,.F.,"1")
Endif
If !( Type("lPoAuto")=="L" .And. lPoAuto) //FSM - 17/05/2012
   IncProc(STR0196) //"Criando Arquivo"
EndIf

aHeader:={}
aCampos:={}
IF lRdMake
   ExecBlock("EICPPO02",.F.,.F.,"12")
ENDIF
IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"ADICIONA_WORK"),)
IF lNec
   nExecute:="2"
   ExecBlock(cArqRdmake,.F.,.F.)
ENDIF

//TRP-14/05/07
aOrd := SaveOrd("SX3",1)
SX3->(dbSeek("SW3"))

While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SW3"
      If SX3->X3_PROPRI=="U" .AND. Ascan(aDBF_Stru, {|x| AllTrim(x[1]) == AllTrim(SX3->X3_CAMPO)})==0 .AND. X3Uso(SX3->X3_USADO)
         aAdd(aDBF_Stru,{SX3->X3_CAMPO,AVSX3(SX3->X3_CAMPO,AV_TIPO),AVSX3(SX3->X3_CAMPO,AV_TAMANHO),AVSX3(SX3->X3_CAMPO,AV_DECIMAL)})
      EndIF
      SX3->(dbSkip())
   Enddo
RestOrd(aOrd)

/* wfs mar/2017 - adequação para uso do EECCRIATRAB(), com a passagem do 7º parâmetro */
aAdd(aDBF_Stru,{"DBDELETE","L",1,0}) //THTS - 01/11/2017 - Este campo deve sempre ser o ultimo campo da Work

//FileWork:=E_CriaTrab(,aDBF_Stru,"Work",,,, SaveTempFiles())
If IsMemVar("lPOAuto") .And. lPOAuto
   cAliasWkTmp := GetNExtAlias()
   FileWork:=E_CriaTrab(,aDBF_Stru,cAliasWkTmp,,,, SaveTempFiles())
   (cAliasWkTmp)->(DbCloseArea())
   TETempReOpen(TeTempName(cAliasWkTmp),cAliasWkTmp,"Work")
Else
   FileWork:=E_CriaTrab(,aDBF_Stru,"Work",,,, SaveTempFiles())
EndIf

IF !USED()
   Msg(STR0308,20) //STR0308 - "NAO HA AREA DISPONIVEL PARA ABERTURA DO CADASTRO DE WORK"
   Help(" ",1,"E_NAOHAREA") ; lRetorno:=.F.
   Return .T.
ENDIF

If !( Type("lPoAuto")=="L" .And. lPoAuto) //FSM - 17/05/2012
   IncProc(STR0197) //"Criando Indice 1"
EndIf
/* wfs mar/2017 - adequação para uso do EECIndRequa */
E_IndRegua("Work",FileWork+TEOrdBagExt(),"WKCC+WKSI_NUM+WKCOD_I+STR(WKREG,"+Str(AVSX3("W3_REG",3))+",0)+WKPOSIT",;
           "AllwaysTrue()",;
           "AllwaysTrue()",;
           STR0198) //"Processando Arquivo Temporário..."  // GFP - 03/08/2015

If !( Type("lPoAuto")=="L" .And. lPoAuto) //FSM - 17/05/2012
   IncProc(STR0199) //"Criando Indice 2"
EndIf

/* wfs mar/2017 - adequação para uso do EECGetIndexFile e EECIndRequa*/
WorkNTX2:= E_Create(aDBF_Stru,.F.,"Work", FileWork, 1, SaveTempFiles())
E_IndRegua("Work",WorkNTX2+TEOrdBagExt(),"WKPOSICAO+STR(WKREC_SI,7,0)",;
           "AllwaysTrue()",;
           "AllwaysTrue()",;
           STR0200) //"Processando Arquivo Temporario..."

If !( Type("lPoAuto")=="L" .And. lPoAuto) //FSM - 17/05/2012
   IncProc(STR0226+"3") //"Criando Indice 3"
EndIf

/* wfs mar/2017 - adequação para uso do EECGetIndexFile e EECIndRequa */
cIndex:=E_Create(,.F.,"Work", FileWork, 2, SaveTempFiles())
E_IndRegua("Work",cIndex+TEOrdBagExt(),"WKCC+WKSI_ORI+WKPOSICAO+STR(WKREC_SI,7,0)",;
           "AllwaysTrue()",;
           "AllwaysTrue()",;
           STR0198) //"Processando Arquivo Temporário..."

If !( Type("lPoAuto")=="L" .And. lPoAuto) //FSM - 17/05/2012
   IncProc(STR0226+"4") //"Criando Indice 4"
EndIf

cIndex4:=E_Create(,.F.,"Work", FileWork, 3, SaveTempFiles())
E_IndRegua("Work",cIndex4+TEOrdBagExt(),"WKCC+WKSI_NUM+WKPOSIT",; //WKPOSICAO
            "AllwaysTrue()","AllwaysTrue()",;
            STR0198) //"Processando Arquivo Temporário..."

SET INDEX TO (FileWork+TEOrdBagExt()),(WorkNTX2+TEOrdBagExt()),(cIndex+TEOrdBagExt()),(cIndex4+TEOrdBagExt())

IF lRdMake
   ExecBlock("EICPPO02",.F.,.F.,"13")
ENDIF

IF lNec
   nExecute:="3"
   ExecBlock(cArqRdmake,.F.,.F.)
ENDIF

DBSETORDER(2)

// EOB - 21/01/10 - criação da nova tabela de trabalho
IF lRegTriPO
	aCamposEIJ := {'EIJ_ADICAO','EIJ_PO_NUM','EIJ_REGTRI','EIJ_FUNREG','EIJ_MOTADI','EIJ_TACOII','EIJ_ACO_II',;
    	           'EIJ_ASSII' ,'EIJ_EX_II' ,'EIJ_ATO_II','EIJ_ORG_II','EIJ_NRATII','EIJ_ANO_II','EIJ_TPAII' ,;
        	       'EIJ_ALI_II','EIJ_ALA_II','EIJ_ALR_II','EIJ_PR_II' ,'EIJ_CALCII','EIJ_ALU_II','EIJ_REGIPI',;
            	   'EIJ_ASSIPI','EIJ_EX_IPI','EIJ_ATOIPI','EIJ_ORGIPI','EIJ_NROIPI','EIJ_ANOIPI','EIJ_TPAIPI',;
                   'EIJ_ALAIPI','EIJ_ALRIPI','EIJ_ALUIPI','EIJ_QTUIPI','EIJ_REG_PC','EIJ_FUN_PC','EIJ_FRB_PC',;
	               'EIJ_PRB_PC','EIJ_TPAPIS','EIJ_ALAPIS','EIJ_REDPIS','EIJ_ALUPIS','EIJ_QTUPIS','EIJ_TPACOF',;
                  'EIJ_ARDCOF','EIJ_ALCOFM','EIJ_ALPISM','EIJ_ALACOF','EIJ_REDCOF','EIJ_ALUCOF','EIJ_QTUCOF',;
                  'EIJ_OPERAC','EIJ_QTU_II','EIJ_CALIPI'}

	aSX3 := SX3->( {IndexOrd(), Recno() } )
	SX3->(DBSETORDER(2))
	For i:=1 to LEN(aCamposEIJ)
		IF SX3->( DBSEEK(aCamposEIJ[i]) )
  		   SX3->( AADD(aEIJ, {aCamposEIJ[i], X3_TIPO, X3_TAMANHO, X3_DECIMAL}) )
	    ENDIF
	Next

	AADD(aEIJ, {"WK_RECNO", "N", 7, 0})

   /* wfs mar/2017 - adequação para uso do EECCRIATRAB(), com a passagem do 7º parâmetro no E_CriaTrab*/
   cWkPO_EIJ:= E_CriaTrab(,aEIJ,"WorkPO_EIJ",,,, SaveTempFiles())

   IF !USED()
      Help(" ",1,"E_NAOHAREA") ; lRetorno:=.F.
      WorkPO_EIJ->(E_EraseArq(cWkPO_EIJ,,, SaveTempFiles())) /* wfs mar/2017 - adequação para uso do EECEraseArq(), com a passagem do 4º parâmetro */
      Return .T.
   ENDIF

   /* wfs mar/2017 - adequação para uso do EECIndRequa */
   E_IndRegua("WorkPO_EIJ",cWkPO_EIJ+TEOrdBagExt(),"EIJ_ADICAO")
   Set Index To (cWkPO_EIJ+TEOrdBagExt())

ENDIF

IF MExiste
   TPO_NUM := SW2->W2_PO_NUM
   TNr_Alter:= SW2->W2_NR_ALTE + 1
   TDt_Alter:= dDataBase
   M->W2_NR_ALTE:=SW2->W2_NR_ALTE+1
   M->W2_DT_ALTE:=dDataBase
Else
   TPO_NUM := Space(Len(SW2->W2_PO_NUM))
   TNr_Alter:= 0
   TDt_Alter:= AVCTOD("")
Endif

If SaveTempFiles()

   DBSelectArea("Work")
   AvZap("Work")

   DBSelectArea("WorkPO_EIJ")
   AvZap("WorkPO_EIJ")

EndIf

Return (lRetorno:=.T.)

*------------------------------------------------------------------------------
FUNCTION PO_Final(FileWork,WorkNTX2,cIndex)
*------------------------------------------------------------------------------
Work->(E_EraseArq(FileWork,WorkNTX2,cIndex, SaveTempFiles())) /* wfs mar/2017 - adequação para uso do EECEraseArq(), com a passagem do 4º parâmetro */

IF SELECT("WorkPO_EIJ") <> 0
   WorkPO_EIJ->(DBCLOSEAREA())
   E_EraseArq(cWkPO_EIJ,,, SaveTempFiles()) /* wfs mar/2017 - adequação para uso do EECEraseArq(), com a passagem do 4º parâmetro */
ENDIF

SA5->(DBSETORDER(1))
SW2->(MSUNLOCK())
SW0->(MSUNLOCK())
RETURN .T.
*============================================================================

*---------------------------------------------------------------------------*
FUNCTION PO400HLPA5()
*---------------------------------------------------------------------------*
LOCAL oDlg, Tb_Campos:={}, lRet:=.F.
LOCAL bAction:={||lRet:=.T.,(&(cVarFab):=Work_Hlp->WK_FABR),oDlg:End(),Po420Val(cPoValFab)}
Private cVarFab:=Readvar(),cPoValFab:='      '
IF !(ReadVar() $ "M->W3_FABR/M->W3_FABR_01/M->W3_FABR_02/M->W3_FABR_03/M->W3_FABR_04/M->W3_FABR_05")
   RETURN .F.
ENDIF

IF cVarFab == "M->W3_FABR"
   cPoValFab:='Fabr'
Endif

AADD(Tb_Campos,{"WK_FABR"  ,,STR0201}) //"Codigo"
AADD(Tb_Campos,{"WKNOME_FB",,STR0059}) //"Nome"

EICAddLoja(Tb_Campos, "W3_FABLOJ",, STR0201)
dbSelectArea("Work_Hlp")
AVZap()

Processa({|lEnd| PO400GrHlp()},STR0202 ) //"Gerando Help de Fabricantes"

dbGoTop()

DEFINE MSDIALOG oDlg TITLE STR0203 FROM 4,3 TO 20,55 OF oMainWnd //"Consulta Itens/Fabricantes"

   oMark:= MsSelect():New("Work_Hlp",,,TB_Campos,@lInverte,@cMarca,{20,6,100,160})
   oMark:baval:=bAction

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlgLog, bAction, { || lRet:=.F.,oDlg:End() }) CENTERED

RETURN lRet

*----------------------------------------------------------------------------*
Function PO400GrHlp()
*----------------------------------------------------------------------------*

If Type("lPoAuto") == "U"
   lPoAuto:= .F.
EndIf

If !(lPoAuto) //FSM - 17/05/2012
   ProcRegua(SA5->(LASTREC()))
EndIf
SA5->(DBSETORDER(2))
SA5->(DBSEEK(xFilial()+Work->WKCOD_I+M->W2_FORN+EICRetLoja("M","W2_FORLOJ")))
WHILE ! SA5->(EOF()) .AND. SA5->A5_PRODUTO == Work->WKCOD_I .AND. ;
      SA5->A5_FORNECE == M->W2_FORN .and. SA5->A5_FILIAL == xFilial("SA5") .AND. (!EICLOJA() .OR. SA5->A5_LOJA == M->W2_FORLOJ)

     If !(lPoAuto) //FSM - 17/05/2012
        IncProc(STR0204+SA5->A5_FABR) //"Processando Fabricante nr. "
     EndIf

   SA2->(DBSEEK(xFilial()+SA5->A5_FABR+EICRetLoja("SA5","A5_LOJA")))
   Work_Hlp->(DBAPPEND())
   Work_Hlp->WK_FABR  :=SA5->A5_FABR
   IF EICLOJA()
      Work_Hlp->W3_FABLOJ := SA5->A5_LOJA
   ENDIF
   Work_Hlp->WKNOME_FB:=SA2->A2_NREDUZ
   Work_Hlp->TRB_ALI_WT:="SA5"
   Work_Hlp->TRB_REC_WT:=SA5->(Recno())
   SA5->(DBSKIP())
END
RETURN NIL

*--------------------
FUNCTION PO400HLPW0()
*--------------------
LOCAL oDlg, Tb_Campos:={},lOK:=.F.,nQuant:=AVSX3("W0__NUM",3), nCont
LOCAL bAction:={||lOK:=.T.,(TSi_Num:=Work_SI->W1_SI_NUM,cSiOri:=Work_SI->WKSI_ORI),oDlg:End()}
LOCAL cPictSI:=ALLTRIM(X3Picture("W1_SI_NUM"))
LOCAL cPictSC:=AVSX3("W0_C1_NUM",6),cNomeSC:=AVSX3("W0_C1_NUM",5)
LOCAL _LIT_CC:= AVSX3("W0__CC")[5],bCancel:={||lOK:=.F.,oDlg:End()}
LOCAL bExecute:= {||}
Local oPanel

//DFS - 11/03/13 - Verifica se há registros na TRB
/*
If Select("TRB") > 0
  // wfs mar/2017 - adequação para uso do EECEraseArq(), com a passagem do 4º parâmetro 
   bExecute:= {||TRB->(E_EraseArq(cNomeW1,,, SaveTempFiles())),EICSI400(,,VISUALIZAR)}
Else
   bExecute:= {||EICSI400(,,VISUALIZAR)}
Endif
*/
//MFR 19/08/2020 OSSME-5043, quando clicava no visualizar a SI pelo segunda vez dava error log pq não encontrava o alias TRB
bExecute := {|| If(Select("TRB") > 0,(TRB->(E_EraseArq(cNomeW1,,, SaveTempFiles())),EICSI400(,,VISUALIZAR)),EICSI400(,,VISUALIZAR))}

Private Tb_Campos_temp:={}
Private aButtons := {} //DFS - 18/01/13 - Inclusão de variavel para o botão visualizar na rotina de PO.

IF ReadVar() <> "TSI_NUM"
   RETURN .F.
ENDIF

//DFS - 18/01/13 - Inclusão do botão visualizar na rotina de Seleção de SI na rotina de PO
aAdd(aButtons, {"S4WB008N",  {|| If(SW0->(DbSetOrder(1), DbSeek(xFilial()+TCC+Work_SI->W1_SI_NUM)), Eval(bExecute),) } ,"Visualizar"} )//"Visualizar"

AADD(Tb_Campos,{ {|| IF(EMPTY(Work_SI->WKSI_ORI),TRANSFORM(Work_SI->W1_SI_NUM,cPictSI),Work_SI->W1_SI_NUM/*REPLICATE("*",nQuant)*/) } ,,STR0205})//"No da S.I."

IF lCopiaPO
   AADD(Tb_Campos,{{||TRANSFORM(Work_SI->WKSI_ORI,cPictSI)},,STR0227}) //"Copia da  S.I."
ENDIF

AADD(Tb_Campos,{{||TRANSFORM(Work_SI->W0_C1_NUM,cPictSC)},,cNomeSC}) //"No da S.C."

IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"TB_Campos_SI"),) //SVG - 04/08/2009 -
For nCont:= 1 To Len(Tb_Campos_temp)
   AAdd(Tb_Campos, Tb_Campos_temp[nCont])
Next

IF SELECT("Work_SI") <> 0
   Work_SI->(avzap())
ENDIF

DBSELECTAREA("Work_SI")

Processa({|lEnd| PO400GrW0Hlp()},STR0206 ) //"Gerando Help de S.I."

DEFINE MSDIALOG oDlg TITLE STR0207+ _Lit_CC+STR0208 FROM 4,3 TO 22,75 OF oMainWnd //"Consulta "###" da S.I."

   oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,,,)
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   Work_SI->(dbGoTop())

   oMark:= MsSelect():New("Work_SI",,,TB_Campos,@lInverte,@cMarca,{15,6,120,200},,, oPanel)
   oMark:baval:=bAction

   oMark:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg   ON INIT EnchoiceBar(oDlg,bAction,bCancel,,aButtons)  CENTERED


DBSELECTAREA("SW3")

RETURN lOK

*----------------------------------------------------------------------------*
Function PO400GrW0Hlp()
*----------------------------------------------------------------------------*
LOCAL nRecno:=SW0->(RECNO()),nInd,nTotal:=SW0->(LASTREC()),nTotSI:=LEN(aSolic)
Local nCpoCtr := SW2->(ColumnPos("W2_CONTR")) > 0 .AND. SW0->(ColumnPos("W0_CONTR")) > 0
Local lAppend :=.F.

IF (lCopiaPo)
   nTotal+=nTotSI
ENDIF

If !( Type("lPoAuto")=="L" .And. lPoAuto) //FSM - 17/05/2012
   ProcRegua(nTotal)
EndIf

SW0->(DBSETORDER(1))
SW0->(DBSEEK(xFilial()+TCC))

lDesvia=.F.

IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"DESVIA_WORK_SI"),)

IF !lDesvia
   lDesvia=.T.
   OldArea:=SELECT()
   cCPos:="SW1.W1_SI_NUM W1_SI_NUM "

   cQuery:="SELECT DISTINCT "+cCpos+"  FROM "+ RetSQLName("SW1")+" SW1 WHERE "+;   // RS 13/08/07
         "SW1.W1_FILIAL  = '"+xFilial("SW1")+"' AND "+;
         "SW1.D_E_L_E_T_ <> '*' AND "+;
         "SW1.W1_CC = '"    +TCc    +"' AND "+;
         "SW1.W1_SEQ = 0 AND  SW1.W1_SALDO_Q <> 0"+ " AND "+;
         "(SW1.W1_FORN = '"  +M->W2_FORN  +"' OR SW1.W1_FORN = '"+Space(AvSX3("W1_FORN",AV_TAMANHO))+"') AND "+;
         "(SW1.W1_FORLOJ = '"  +M->W2_FORLOJ  +"' OR SW1.W1_FORLOJ = '"+Space(AvSX3("W1_FORLOJ",AV_TAMANHO))+"')"

   //DFS - Inclusão de tratamento a fim de filtrar os itens da SI
   cQuery:=ChangeQuery(cQuery)
   TcQuery cQuery ALIAS "SW1NEW" NEW
   SW1NEW->(DBGOTOP())
   DO WHILE !SW1NEW->(EOF())
         lAppend:=.F.
         SW0->(DBSEEK(xFilial()+TCC+SW1NEW->W1_SI_NUM))
         If !( Type("lPoAuto")=="L" .And. lPoAuto) //FSM - 17/05/2012
            IncProc(STR0209+SW0->W0__NUM) //"Processando S.I. nr. "
         EndIf

         If nCpoCtr //LRS - 20/01/2014 - Verifica os campos novos de contrato

            If M->W2_CONTR == "1" .AND. SW0->W0_CONTR == "1" //Se tiver Contrato na S.I. //LRS - 20/01/2014
                  If EMPTY(ALLTRIM(SW0->W0_HAWB_DA))
                     Work_SI->(DBAPPEND())
                     Work_SI->W1_SI_NUM:=SW0->W0__NUM
                     Work_SI->W0_C1_NUM:=SW0->W0_C1_NUM
                     Work_SI->TRB_ALI_WT:="SW0"
                     Work_SI->TRB_REC_WT:=SW0->(Recno())
                     lAppend:=.T.
                  EndIf
            ENDIF

            If (M->W2_CONTR == "2" .AND. (SW0->W0_CONTR == "2" .OR. EMPTY(SW0->W0_CONTR)))//Se não tiver Contrato na S.I. //LRS - 20/01/2014
               If EMPTY(ALLTRIM(SW0->W0_HAWB_DA))
                  Work_SI->(DBAPPEND())
                  Work_SI->W1_SI_NUM:=SW0->W0__NUM
                  Work_SI->W0_C1_NUM:=SW0->W0_C1_NUM
                  Work_SI->TRB_ALI_WT:="SW0"
                  Work_SI->TRB_REC_WT:=SW0->(Recno())
                  lAppend:=.T.
               EndIf
            ENDIF
         Else
            If EMPTY(ALLTRIM(SW0->W0_HAWB_DA))
               Work_SI->(DBAPPEND())
               Work_SI->W1_SI_NUM:=SW0->W0__NUM
               Work_SI->W0_C1_NUM:=SW0->W0_C1_NUM
               Work_SI->TRB_ALI_WT:="SW0"
               Work_SI->TRB_REC_WT:=SW0->(Recno())
               lAppend:=.T.
               
            EndIf
         ENDIF
         If lAppend
            If EasyEntryPoint("EICPO400")
               ExecBlock("EICPO400", .F., .F., "GRAVA_WORK_SI")         
            EndIf
         endif
      SW1NEW->(DBSKIP())

   ENDDO

   SW1NEW->(DBCLOSEAREA())
   DBSELECTAREA(OldArea)
ENDIF


  
IF (lCopiaPo)
   For nInd:=1 To nTotSI
      IF aSolic[nInd,2]==TCC
         Work_SI->(DBAPPEND())
         Work_SI->W1_SI_NUM :=aSolic[nInd,4] // "*"+STRZERO(VAL(EasyGParam("MV_SI_NUM"))+1,nNumeroSI)//"*"+aSolic[nInd,1]
         Work_SI->WKSI_ORI  :=aSolic[nInd,1]
         Work_SI->TRB_ALI_WT:="SW0"
         Work_SI->TRB_REC_WT:= 0

      ENDIF
   NEXT
ENDIF

SW0->(DBGOTO(nRecno))
RETURN NIL

/*MJB140298
*----------------------------------------------------------------------------*
Function PO400ApuFob()
*----------------------------------------------------------------------------*
M->W2_FOB_GER:=(M->W2_FOB_TOT+M->W2_INLAND+M->W2_PACKING+M->W2_OUT_DES+M->W2_FRETEIN)- M->W2_DESCONT
lRefresh:=.T.
RETURN .T.
*/

*-----------------------
FUNCTION PO400Paridade()
*----------------------
LOCAL cMoedaDolar:=BuscaDolar()//EasyGParam("MV_SIMB2",,"US$")
M->W2_PARID_U:= BuscaTaxa(cMoedaDolar,M->W2_DT_PAR,.T.) / BuscaTaxa(M->W2_MOEDA,M->W2_DT_PAR,.T.)
lRefresh:=.T.
RETURN .T.

*-------------------*
Function PO400PESQ(nOp)
*-------------------*
DBSELECTAREA("Work")
DO CASE
   CASE nOp == 'CC'
        RETURN WKCC+' '+WKCCNOME
   CASE nOp == 'FB'
        RETURN WKFABR + '-' + WKNOME_FAB
   CASE nOP == 'FO'
        RETURN WKFORN + '-' + WKNOME_FOR
ENDCASE

//LGS-24/10/13
/* wfs mar/2017 - adequação para uso do EECIndRequa */
*-------------------*
Function PO400OrdenaItens(nOpc,nOpcAux)
*-------------------*
Local nOp := nOpc, nOpAux := nOpcAux
Local nOldRecno := work->(recno())

   if nOp == 1
      work->(dbsetorder(2))
   Elseif nOp == 2
      work->(dbsetorder(1))
   elseif nOp == 3
      work->(dbsetorder(4))
   endif
   
   nOrder := work->(IndexOrd())
   
   work->(dbGoTo(noldrecno)) //work->(dbGoTop())

RETURN

*-------------------------*
FUNCTION PO420AlteraDatas()
*-------------------------*
LOCAL nOpcaoAlt:=0, oPanel
LOCAL MSG1:=STR0210 //"Data de entrega sugerida não preenchida."
LOCAL MSG2:=STR0211, nRecno:=Work->(Recno()) //"Data de embarque sugerida não preenchida."
Local nLin1:=1 ; nLin2:= 2.1 ; nLin3:= 2.2 ; nLin4:= 3.1   //igor chiba 18/07/14 ajuste em tela
PRIVATE lLOOP := .F.//ARS 01/09/2005 - VARIAVEL PARA O PONTO DE ENTRADA "VALIDA_DATAS"
PRIVATE dDtEmbarque:=AVCTOD(''), dDtEntrega:=AVCTOD(''), dParaEmbarque:=AVCTOD(''), dParaEntrega:=AVCTOD('')

If(EasyEntryPoint("EICPO400"),Execblock("EICPO400",.F.,.F.,"ALTERA_DATA"),)  // LRS 23/10/13 - Ponto de entrada para alteração nas datas.

WHILE .T.
   nOpcaoAlt:=0
   DEFINE MSDIALOG oDlgDT TITLE STR0212 From 9,05 To 23,79 OF GetWndDefault() //'Alteracao de Datas'

   oPanel:= TPanel():New(0,0, "", oDlgDT,,,,,,0,0)
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   @ nLin1,01 SAY STR0213 Of oPanel //"Data Embarque"
   @ nLin1,20 SAY STR0214 Of oPanel //"Previsao de Entrega"

   @ nLin3,01 SAY STR0286 Of oPanel //"De "
   @ nLin3,09 SAY STR0287 Of oPanel //" para"

   @ nLin3,20 SAY STR0286 Of oPanel //"De "
   @ nLin3,28 SAY STR0287 Of oPanel //" para"

   @ nLin3,02  MSGET dDtEmbarque SIZE 50,10 VALID PO400ValDt("dDtEmbarque") /*AltDatas(dDtEmbarque, "D")*/ Of oPanel
   @ nLin3,11  MSGET dParaEmbarque /*WHEN  !EMPTY( dDtEmbarque )*/ SIZE 50,10 Valid PO400ValDt("dParaEmbarque") Of oPanel

   @ nLin3,21  MSGET dDtEntrega SIZE 50,10 Valid PO400ValDt("dDtEntrega") Of oPanel
   @ nLin3,30  MSGET dParaEntrega /*WHEN  !EMPTY( dDtEntrega )*/ SIZE 50,10 Valid PO400ValDt("dParaEntrega") Of oPanel
/*
   @ nLin3,2.4 MSGET dDtEmbarque SIZE 35,10 VALID AltDatas(dDtEmbarque, "D") Of oPanel
   @ nLin3,09  MSGET dParaEmbarque WHEN  !EMPTY( dDtEmbarque ) SIZE 40,10 Of oPanel

   @ nLin3,18  MSGET dDtEntrega SIZE 35,10 Of oPanel
   @ nLin3,26  MSGET dParaEntrega WHEN  !EMPTY( dDtEntrega ) SIZE 40,10 Of oPanel
*/
   ACTIVATE MSDIALOG oDlgDT ON INIT EnchoiceBar(oDlgDT,{||nOpcaoAlt:=1,oDlgDT:End()},{||oDlgDT:End()}) CENTERED

   IF nOpcaoAlt#0
   //wReliquias TE-3899 499390 - Botão "Altera datas" no PO permitir informar data a todos os itens
   IF !EMPTY( dDtEmbarque ) .AND. EMPTY(dParaEmbarque)
         MsgInfo(MSG2,STR0037) //"Atenção"
         LOOP
      ENDIF

      /*igor chiba 18/07/17 req 4.1 permitir altera para branco
      IF !EMPTY( dDtEmbarque ) .AND. EMPTY(dParaEmbarque)
         MsgInfo(MSG2,STR0037) //"Atenção"
         LOOP
      ENDIF
      /*
      IF !EMPTY( dDtEntrega ) .AND. EMPTY(dParaEntrega)
         MsgInfo(MSG1,STR0037) //"Atenção"
         LOOP
      ENDIF
      */
      IF !EMPTY( dDtEntrega )  .AND.  dDtEntrega <= dDtEmbarque
         Help("", 1, "AVG0000398")//"A previsão de entrega deve ser maior que a de embarque."###"Atenção"
      ENDIF
      //wreliquias lTelaIte para validar tela de seleção de itens TE-3899 499390 - Botão "Altera datas" no PO permitir informar data a todos os itens;
     IF !lTelaIte .AND. EMPTY( dDtEmbarque ) .AND. EMPTY(dDtEntrega)
         EXIT
      ENDIF
      If(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"VALIDA_DATAS"),)//ASR 01/09/2005 - PONTO DE ENTRADA PARA VALIDAÇÃO DAS DATAS
      If lLOOP//ASR 01/09/2005 - SER FOR VERDADEIRO FAZ O LOOP
         Loop
      EndIF
   ENDIF

   IF nOpcaoAlt#0 .AND. MsgYesNo(STR0218,STR0037)==.T. //"Confirma estas datas para os itens ?"###"Atenção"
      Work->( DBGOTOP() )
      Processa({|| PO420AltWork(dDtEmbarque,dParaEmbarque,dDtEntrega,dParaEntrega) })
      Work->(DBGOTO(nRecno))
   ENDIF

   EXIT
END

RETURN .F.

*----------------------------*
FUNCTION AltDatas(dtEmbarq, cData)
*----------------------------*
//IF !EMPTY(dtEmbarq) wReliquias TE-3899 499390 - Botão "Altera datas" no PO permitir informar data a todos os itens
   IF cData == "D"
      lAchouDt := .F.
      Work->(dbGoTop())
      DO WHILE !Work->(eof())
         IF Work->WKDT_EMB = dtEmbarq
            dDtEntrega := Work->WKDT_ENTR
            lAchouDt := .T.
            EXIT
         ENDIF
         Work->(dbSkip())
      ENDDO
      IF !lAchouDt
         MSGINFO( STR0247 )//'Data de embarque informada nao localizada!'
         RETURN .F.
      ENDIF
   ELSE
      IF EMPTY(dParaEntrega)
         SY9->(dbSetOrder(2))
         dParaEntrega:= dtEmbarq + SYR->YR_TRANS_T + IF(SY9->(DBSEEK(xFilial()+M->W2_DEST)),(SY9->Y9_LT_DES + SY9->Y9_LT_TRA),EasyGParam("MV_LT_DESE"))
         SY9->(dbSetOrder(1))
      ENDIF
   ENDIF
//ENDIF
RETURN .T.

*-------------------------*
FUNCTION PO420AltWork(dDtEmbarque,dParaEmbarque,dDtEntrega,dParaEntrega)
*-------------------------*
LOCAL nReg:=0
Private dEntrega_Alt := dParaEntrega // JBS - 14/07/2003

   If Type("lPoAuto") == "U"
      lPoAuto:= .F.
   EndIf

   If !(lPoAuto) //FSM - 17/05/2012
      Work->(ProcRegua(LASTREC()))
   ENdIf
   WHILE  !Work->( EOF() )
      If !(lPoAuto) //FSM - 17/05/2012
         IncProc(STR0219+PADL(++nReg,5,'0')) //"Gravando Registro No "
      EndIf

	   //wReliquias: lTelaIte identifica que vai editar todos os itens*/
	   //wReliquias TE-3899 499390 - Botão "Altera datas" no PO permitir informar data a todos os itens
/*      IF (lTelaIte .OR. Work->WKFLAG) .AND. ( !EMPTY(dDtEmbarque) .OR. !EMPTY(dDtEntrega) )*/
      IF (lTelaIte .OR. Work->WKFLAG)

         //IF !EMPTY( dDtEmbarque ) //wReliquias TE-3899 499390 - Botão "Altera datas" no PO permitir informar data a todos os itens
         IF !EMPTY( dParaEmbarque ) //wReliquias TE-3899 499390 - Botão "Altera datas" no PO permitir informar data a todos os itens
            IF Work->WKDT_EMB = dDtEmbarque
               Work->WKDT_EMB := dParaEmbarque
               Work->WK_ALTEROU := .T.
            ENDIF
         ENDIF

         //IF ! EMPTY( dDtEntrega ) //wReliquias TE-3899 499390 - Botão "Altera datas" no PO permitir informar data a todos os itens
         IF ! EMPTY( dParaEntrega ) //wReliquias TE-3899 499390 - Botão "Altera datas" no PO permitir informar data a todos os itens
            IF Work->WKDT_ENTR = dDtEntrega

               IF EasyEntryPoint("EICPO400") // JBS - 14/07/2003
                  ExecBlock("EICPO400",.F.,.F.,"ALT_DT_ENTREGA")
               ENDIF

               Work->WKDT_ENTR := dEntrega_Alt
               Work->WK_ALTEROU := .T.
            ENDIF
         ENDIF
      ENDIF

      Work->(DBSKIP())

   ENDDO
RETURN NIL


*------------------------------------------------------------------------------
FUNCTION PO_Init(FileWork,WorkNTX2,cTipRot)
*------------------------------------------------------------------------------
LOCAL lRetorno:=.F.
If !( Type("lPoAuto")=="L" .And. lPoAuto) //FSM - 17/05/2012
   Processa({||PO_InitWork({|msg|MsProcTxt(msg)},@lRetorno,@FileWork,@WorkNTX2,cTipRot) },;
                        STR0220) //"Gerando Arquivos de Trabalho..."
Else
   PO_InitWork(,@lRetorno,@FileWork,@WorkNTX2,cTipRot)
EndIf
Return ( lRetorno )

*----------------------
Function PO_Filter(lOn) // Usada também no programa EICPN400.PRW
*----------------------
Local cAlias
IF cProg=="PN"
   aGetsNaciona:={"W2_NR_ALTE","W2_DT_ALTE","W2_NR_PRO" ,"W2_DT_PRO","W2_COND_PA","W2_DIAS_PA",;
                  "W2_COD_MSG","W2_VM_OBS" ,"W2_REG_TRI","W2_REFCLI","W2_VLMIDIA","W2_VENCDA" ,;
                  "W2_ARMAZEM","W2_CLIENTE"}
Else
   aGetsNaciona:=Nil
Endif

If lFilDa
   cAlias:=Alias()
   dbSelectArea("SW2")
   IF cProg="PN"
      cFiltro := "W2_FILIAL='"+xFilial("SW2")+"' .And. W2_HAWB_DA <> '"+Space(Len(SW2->W2_HAWB_DA))+"'"
   Else
      cFiltro := "W2_FILIAL='"+xFilial("SW2")+"' .And. W2_HAWB_DA = '"+Space(Len(SW2->W2_HAWB_DA))+"'"
   Endif
   IF lOn
      SET FILTER TO &cFiltro
   Else
      SET FILTER TO
   Endif
   dbSelectArea(cAlias)
Endif

IF EasyEntryPoint("EICPPO01")
   ExecBlock("EICPPO01",.F.,.F.,"FILTRO")   
ENDIF

//SVG - 03/11/08 - Compatibilização - Inclusão do Ponto de Entrada, verificando variável de parâmetro.
If lOn
   If EasyEntryPoint("EICPO400")
      ExecBlock("EICPO400",.F.,.F.,"USUARIOS")
   EndIf
EndIf

Return NIL

Static Function EICPO400PROG()
LOCAL lCerto:=.T.
If cProg="PN" .AND. EMPTY(ALLTRIM(SW2->W2_HAWB_DA))
   Help(" ",1,"AVG0000088")
   lCerto:=.F.
ElseIf cProg="PO" .AND. ! EMPTY(ALLTRIM(SW2->W2_HAWB_DA))
   Help(" ",1,"AVG0000089")
   lCerto:=.F.
EndIf
Return lCerto
*-----------------------------*
Static Function PO400MARITEM(nValTot,nValItens)
*-----------------------------*
Local cMarcaFlag:=cMarca

//If nOpcAux == 5//LRS 21/08/2013 - chamado 102381 //LRS 18/09/2013 - chamado 102702 - Correção do chamado 102381 gerou erro em outra rotina
	If lCposAntecip .and. lTemSWB
     	if ! Work->WKFLAG
       		 If nVlr_Limite == 0 .OR. nValTot+(Work->WKQTDE*Work->WKPRECO) == nVlr_Limite
          	 PO400VALSWB(.f.,.f.,.t.)
          	 return
       	 Endif
      if nValTot+(Work->WKQTDE*Work->WKPRECO) > nVlr_Limite
           PO400VALSWB(.f.,.t.,.f.)
           return
        endif
     endif
	EndIf
//Endif //LRS 18/09/2013 - chamado 102702 - Correção do chamado 102381 gerou erro em outra rotina



//FDR - 19/06/12
If Work->WKQTDE_EMB > 0 //.OR. If (SW3->(FIELDPOS("W3_SLD_ELI")) # 0,Work->WKSLD_ELI > 0, .F.) //FSY - 23/09/2013 - Removido validação que verifica se o PO contem saldo eliminado. - 102829
   Alert(STR0376) /*"Item não pode ser estornado, pois existe processo de embarque ou seu saldo foi eliminado."*/
   Return .F.
EndIf

//AOM - 09/04/2011 - Operação Especial
If !ValidOpePO("MK_IT_PO")
   Return .F.
EndIf

Work->WKFLAG := !Work->WKFLAG
IF(!Work->WKFLAG,cMarcaFlag:=SPACE(02),)
Work->WKFLAGWIN:=cMarcaFlag
if Work->WKFLAG
   nValTot+=Work->WKQTDE*Work->WKPRECO
else
   nValTot-=Work->WKQTDE*Work->WKPRECO
endif
If(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"MarcaEstorno"),)

Return

*----------------------------------------------------------------------------*
Function EICPO400Pari() //INICIALIZA O CAMPO (X3_RELACAO) / GATILHO (X7_REGRA)
*----------------------------------------------------------------------------*
LOCAL nTaxa1,nTaxa2,nValor:=1
LOCAL cMoedaDolar:=BuscaDolar()//EasyGParam("MV_SIMB2",,"US$")

nTaxa1:=BuscaTaxa(cMoedaDolar,M->W2_DT_PAR,.T.)
nTaxa2:=BuscaTaxa(M->W2_MOEDA,M->W2_DT_PAR,.T.)
IF nTaxa1 > 0 .AND. nTaxa2 > 0
   nValor:=nTaxa2 / nTaxa1  //TRP-16/01/08 - Acerto no cálculo do campo paridade
ENDIF

RETURN nValor

/*
Funcao      : PO400SelPO
Parametro   : nenhum
Retorno     : nenhum
Objetivos   : Copia Capa e Itens  P.O.
Autor       : Cleverson E. da Silva
Data        : 31/05/02
Revisao     :
*/

*--------------------------------------*
FUNCTION PO400SelPO(cAlias,nReg,nOpc)
*--------------------------------------*
LOCAL oDlgPO, oBrwCapa,nSelOp
LOCAL nSelect:= Select(),aButtons:={},aMantem:={STR0016,STR0015},cMantem:=aMantem[1]//aMantem:={Sim,Nao}
LOCAL nRecSW2:= SW2->(RecNo()),cUniReq:=SY3->Y3_COD,nAscan
LOCAL nInd,nSW2Col:=SW2->(FCount())
PRIVATE aCpoSW2:={},aButtonsPo:={}, lSairPo:=.F.	       //CDS 6/10/05
PRIVATE bOkPO :={|| IF(cMantem==aMantem[2],IF(NaoVazio(cUniReq) .AND. ExistCpo("SY3",cUniReq),(nSelOp:= 1,oDlgPO:End(),Processa({|| PO400Itens(.F.,cMantem,cUniReq)}),Processa({||PO400NewCC(cUniReq)}) ),),(nSelOp:= 1,oDlgPO:End())  ) } //CDS 6/10/05
PRIVATE bGetCC :={|| IF(cMantem==aMantem[1],(oSayCC:Disable(),oGetCC:Disable() ),(oSayCC:Enable(),oGetCC:Enable()) )}  //CDS 6/10/05
PRIVATE bCancelPO:={||Work_SW3->(avzap()),oDlgPO:End()}  //CDS 6/10/05
aadd(aButtonsPO,{"PESQUISA" ,{|| DBSELECTAREA("SW2"),AxPesqui()},STR0267})//"Pesq. P.O."
aadd(aButtonsPO,{"BMPVISUAL",{|| Processa({|| PO400Itens(.T.,,cUniReq)})},STR0268})//"Itens P.O."

AADD(aCpoSW2,{"W2_PO_NUM"  ,,AVSX3("W2_PO_NUM",5),AVSX3("W2_PO_NUM",6)})
AADD(aCpoSW2,{"W2_PO_DT"   ,,AVSX3("W2_PO_DT",5)})
AADD(aCpoSW2,{"W2_NR_ALTE"  ,,AVSX3("W2_NR_ALTE",5),AVSX3("W2_NR_ALTE",6)})
AADD(aCpoSW2,{"W2_DT_ALTE"  ,,AVSX3("W2_DT_ALTE",5)})
If !EICLoja()
   AADD(aCpoSW2,{{|| E_Field("W2_FORN","A2_NREDUZ","B")},,AVSX3("W2_FORNDES",6)})
Else
   AADD(aCpoSW2,{{|| AvField("W2_FORN+W2_FORLOJ","A2_NREDUZ","B")},,AVSX3("W2_FORNDES",6)})
EndIf
AADD(aCpoSW2,{{|| TRANS(SW2->(W2_FOB_TOT+W2_INLAND+W2_PACKING+W2_FRETEIN+W2_OUT_DES-W2_DESCONT+If(AvFlags("RATEIO_DESP_PO_PLI"),W2_SEGURIN,0)),AVSX3("W2_FOB_GER",6)) },,AVSX3("W2_FOB_GER",5)})
AADD(aCpoSW2,{"W2_DT_IMP"  ,,AVSX3("W2_DT_IMP",5)})
AADD(aCpoSW2,{{||E_Field("W2_TIPO_EM","YQ_DESCR","U")}  ,,AVSX3("W2_TIPO_EM",5)})
AADD(aCpoSW2,{"W2_ORIGEM"  ,,AVSX3("W2_ORIGEM",5),AVSX3("W2_ORIGEM",6)})
AADD(aCpoSW2,{"W2_DEST"  ,,AVSX3("W2_DEST",5),AVSX3("W2_DEST",6)})
AADD(aCpoSW2,{{||E_Field("W2_COMPRA","Y1_NOME","U")}  ,,AVSX3("W2_COMPRAN",5)})
AADD(aCpoSW2,{"W2_MOEDA"  ,,AVSX3("W2_MOEDA",5),AVSX3("W2_MOEDA",6)})
AADD(aCpoSW2,{"W2_INCOTER"  ,,AVSX3("W2_INCOTER",5),AVSX3("W2_INCOTER",6)})

IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"BROWSE_COPIA"),)



Begin Sequence
   //CDS 6/10/05
   If lSairPO
      BREAK //Sequence
   Endif

   If lCopiou // GFP
      MsgInfo("Processo já possui SI de referencia.","Aviso")
      BREAK
   EndIf

   IF ! SW2->(dbSeek(xFilial()))
      HELP(" ",1,"AVG0000622") //"Não existem registros para a visualização !","Aviso")
      Break
   Endif

   nSelOp := 0
   oMainWnd:ReadClientCoors()
   nMeio:=INT( ((oMainWnd:nBottom-60)-(oMainWnd:nTop+125) ) / 8 )

   DEFINE MSDIALOG oDlgPO TITLE STR0225 FROM ;
          oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
          OF oMainWnd PIXEL //"Seleção de Processos"

      oBrwCapa 		:= MsSelect():New("SW2",,,aCpoSW2,,,{nMeio,1,(oDlgPO:nClientHeight-6)/2,(oDlgPO:nClientWidth-4)/2},;
                                  "xFilial('SW2')","xFilial('SW2')",oDlgPO,,,) //20/06/08 CCH- Parâmetro .T. removido da MSSELECT pois de acordo com a nova sintaxe, foi adicionado o 13º parâmetro e o mesmo recebe caractere, não booleano

      oBrwCapa:bAval :={|| .t.}
      @01.5,01 MSPANEL oPanelPO PROMPT "" SIZE 30,60 OF oDlgPO   //LRL 17/03/04 Painel para alinhamento MDI
      @01.5,01 SAY STR0233 of oPanelPO //"Manter Unidade(s) Requisitante(s)?"
      @01.5,12 COMBOBOX cMantem Items aMantem On Change(Eval(bGetCC)) Size 25,50 Of oPanelPO //sim,nao
      @02.5,01 SAY oSayCC Var STR0234 OF oPanelPO
      @02.5,12 MSGET oGetCC Var cUniReq F3 "SY3" Size 25,08 OF oPanelPO
      oSayCC:Disable()
      oGetCC:Disable()
      oDlgPO:lMaximized:= .T.     //LRL 17/03/04 Maximiliza a Tela na versão MDI
      IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"TELA_COPIA"),)

	  oPanelPO:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	  oBrwCapa:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	  oBrwCapa:oBrowse:Refresh() //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   //DFS - 31/01/13 - Inclusão de refresh na tela
   ACTIVATE MSDIALOG oDlgPO ON INIT (EnchoiceBar(oDlgPO,bOkPO,bCancelPO,,aButtonsPO),oBrwCapa:oBrowse:Refresh())//LRL 17/03/04 - Alinhamento MDI //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT


   WORK_SW3->(DBGOTOP())

   IF nSelOp == 1
      Processa({|| PO400Itens(.F.,cMantem,cUniREq)} )
      Processa({|| PO400CopiaGrv()})
   ENDIF

   IF WORK_SW3->(EasyRecCount())>0
      lCopiaPO:=.T. //Indica que houve a copia de um Pedido
      lSiReferencia:=.F.
   ENDIF

   IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"FIM_COPIA"),)

End Sequence
SW2->(dbGoto(nRecSW2))
Select(nSelect)

Return NIL

*----------------------------*
FUNCTION PO400CriaTemp()
*----------------------------*
Local i
aDBF_Stru:={{"WKCOD_I"    ,"C",AVSX3("W3_COD_I",3),0},{"WKDESCR"   ,"C",AVSX3("B1_VM_" + cDESC_PO,3),0} ,;
            {"WKFABR"     ,"C",nLenFabr ,0},{"WKFABR_O"  ,"C",nLenFAbr,0}  ,;
            {"WKRECNO","N",7,0},;
            {"WKNOME_FAB" ,"C",15,0},{"WKFORN"    ,"C",nLenFabr,0}  ,;
            {"WKFORN_O"   ,"C",nLenForn,0},{"WKNOME_FOR","C",15,0} ,;
            {"WKCOMPRADO","N", 3,0},{"WKREG"     ,"N",AVSX3("W3_REG",3),0}  ,;
            {"WKFLUXO"    ,"C", 1,0},;
            {"WKQTDE_LI" ,"N",AVSX3("W3_QTDE",3),AVSX3("W3_QTDE",4)}, ;
            {"WKQTDE_EMB","N",AVSX3("W3_QTDE",3),AVSX3("W3_QTDE",4)}, ;
            {"WKQTDE"    ,"N",AVSX3("W3_QTDE",3),AVSX3("W3_QTDE",4)} ,;
            {"WKQTDE_O"  ,"N",AVSX3("W3_QTDE",3),AVSX3("W3_QTDE",4)}    ,;
            {"WKPRECO"   ,"N",AVSX3("W3_PRECO",3),AVSX3("W3_PRECO",4)},;
            {"WKSALDO_Q" ,"N",AVSX3("W3_SALDO_Q",3),AVSX3("W3_SALDO_Q",4)} ,;
            {"WKSALDO_O" ,"N",AVSX3("W3_SALDO_Q",3),AVSX3("W3_SALDO_Q",4)},;
            {"WKCC"      ,"C",nLenCC,0}  ,;
            {"WKCC_O"    ,"C",nLenCC,0}  ,{"WKSI_ORI","C",nLenSi,0},;
            {"WKSI_NUM"   ,"C", nLenSi,0},{"WKPO_NUM"  ,"C",AvSx3("W2_PO_NUM", AV_TAMANHO),0} ,;
            {"WKCDPOCOPY" ,"C",AvSx3("W2_PO_NUM", AV_TAMANHO),0},;
            {"WKDT_EMB"   ,"D", 8,0},{"WKDT_ENTR" ,"D",8,0}  ,;
            {"WKDTENTR_S" ,"D", 8,0},{"WKFLAG"    ,"L",1,0}  ,;
            {"WKSEQ"      ,"N", 2,0},{"WKFLAG2"   ,"L",1,0}  ,;
            {"WKPORTARIA" ,"N", 2,0},{"WKFABR_01" ,"C",6,0}  ,;
            {"WKFABR_02"  ,"C", nLenFabr,0},{"WKFABR_03" ,"C",nLenFabr,0}  ,;
            {"WKFABR_04"  ,"C", nLenFabr,0},{"WKFABR_05" ,"C",nLenFabr,0}  ,;
            {"WKREC_SI"   ,"N", 7,0},{"WKPOSICAO" ,"C",LEN(SW3->W3_POSICAO),0}  ,;
            {"WKPSPOCOPY" ,"C",LEN(SW3->W3_POSICAO),0},;
            {"WKDTEMB_S"  ,"D", 8,0},;
            {"WKPRECO_S"  ,"N",AVSX3("W3_PRECO" ,3),AVSX3("W3_PRECO" ,4)} ,;
            {"WKSALDO_GI" ,"N",AVSX3("W3_QTDE" ,3),AVSX3("W3_QTDE" ,4)},;
            {"WKQTDE_GI"  ,"N",AVSX3("W3_QTDE" ,3),AVSX3("W3_QTDE" ,4)} ,;
            {"WKFLUXO_O"  ,"C", 1,0},{"WKDESCONTO","N",18,8} ,;
            {"WKPACKING"  ,"N",AVSX3("W6_PACKING",3),AVSX3("W6_PACKING" ,4)},;
            {"WKOUT_DESP" ,"N",AVSX3("W6_FOB_TOT" ,3),AVSX3("W6_FOB_TOT" ,4)} ,;
            {"WKUNI"      ,"C", 3,0},{"WKFLAGWIN" ,"C", 2,0} ,;
            {"WKFLAGWIN2" ,"C", nLenOk,0},;
            {"WKPRTOT"    ,"N",AVSX3("W6_FOB_TOT" ,3),AVSX3("W6_FOB_TOT" ,4)} ,;
            {"WK_ALTEROU" ,"L",01,0},{"WK_REG_TRI","C",01,0} ,;
            {"WK_TEC"     ,"C",10,0},{"WK_EX_NCM" ,"C",LEN(SB1->B1_EX_NCM),0} ,;
            {"WK_EX_NBM"  ,"C",LEN(SB1->B1_EX_NBM),0}, {"WKMOTIVO", "C",60,0},;
            {"WKPART_N","C",LEN(IF(SW3->(FieldPos("W3_PART_N")) # 0,SW3->W3_PART_N,SA5->A5_CODPRF)),0}   ,;
            {"WKCCNOME","C",20,0}  , {"WK_REG_MIN","C",AVSX3("W3_REG_MIN",3),0} ,;
            {"WKPESO_L","N",AVSX3("W5_PESO",3),AVSX3("W5_PESO",4)},;
            {"TRB_ALI_WT","C",03,0},; //TRP - 25/01/07 - Campos do WalkThru
            {"TRB_REC_WT","N",10,0},;
            {"WKPOSIT"   ,"C",4,0}}


EICAddWkLoja(aDBF_Stru, "W3_FABLOJ", "WKFABR")
EICAddWkLoja(aDBF_Stru, "W3_FORLOJ", "WKFORN")
EICAddWkLoja(aDBF_Stru, "W3_FAB1LOJ", "WKFABR_01")
EICAddWkLoja(aDBF_Stru, "W3_FAB2LOJ", "WKFABR_02")
EICAddWkLoja(aDBF_Stru, "W3_FAB3LOJ", "WKFABR_03")
EICAddWkLoja(aDBF_Stru, "W3_FAB4LOJ", "WKFABR_04")
EICAddWkLoja(aDBF_Stru, "W3_FAB5LOJ", "WKFABR_05")
If EICLoja()
   AADD(aDBF_Stru,{"W3_FABL_O", AvSx3("W3_FABLOJ", AV_TIPO), AVSX3("W3_FABLOJ", AV_TAMANHO), AVSX3("W3_FABLOJ", AV_DECIMAL)})
   AADD(aDBF_Stru,{"W3_FORL_O", AvSx3("W3_FORLOJ", AV_TIPO), AVSX3("W3_FORLOJ", AV_TAMANHO), AVSX3("W3_FORLOJ", AV_DECIMAL)})
EndIf

If SW3->(FieldPos("W3_PESOL")) # 0 //CCH - 07/08/09 - Gravação do novo campo de Peso Líquido Unitário
   AADD(aDBF_Stru,{"WKPESOL","N",AVSX3("W3_PESOL",3),AVSX3("W3_PESOL",4)})
EndIf

IF cPaisLoc # "BRA"  .AND. SW1->(FIELDPOS("W1_NATUREZ")) # 0
   AADD(aDBF_Stru,{"WKNATUREZA","C",AVSX3("W1_NATUREZ",3),0})
ENDIF

If lForeCast
   AADD(aDBF_Stru,{"WK_FORECAS","C",1,0})
Endif

IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"CRIA_TEMP"),) // JBS - 14/07/2003

IF(lSeal,ExecBlock("IC193PO1",.F.,.F.,"2"),) //AWR 01/10/1999
IF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"8"),)//RHP 25/02/00

IF lExiste_Midia//AWR 21/10/1999
   AADD(aDBF_Stru,{"WK_QTMIDIA",AVSX3("B1_QTMIDIA",2),AVSX3("B1_QTMIDIA",3),AVSX3("B1_QTMIDIA",4)})
   AADD(aDBF_Stru,{"WK_VLTOTMI",AVSX3("W2_VLMIDIA",2),AVSX3("W2_VLMIDIA",3),AVSX3("W2_VLMIDIA",4)})
ENDIF

//TRP- 01/06/09 - Campo Software para novo Tratamento de Mídia e Software
If SW3->(FieldPos("W3_SOFTWAR")) # 0 .And. EasyGParam("MV_CONSOFT",, "N") $ cSim
   AADD(aDBF_Stru,{"WKSOFTWAR",AVSX3("W3_SOFTWAR",2),AVSX3("W3_SOFTWAR",3),AVSX3("W3_SOFTWAR",4)})
Endif

If lCpoCtCust
   AADD(aDBF_Stru,{"WKCTCUSTO",AVSX3("W3_CTCUSTO",2),AVSX3("W3_CTCUSTO",3),AVSX3("W3_CTCUSTO",4)})
EndIf
If lPesoBruto                                                                                    //NCF - 25/08/2011 - Campo do Peso Bruto Unitário
   AADD(aDBF_Stru,{"WKPSBRUTO",AVSX3("W3_PESO_BR",2),AVSX3("W3_PESO_BR",3),AVSX3("W3_PESO_BR",4)})
EndIf
If AvFlags("RATEIO_DESP_PO_PLI")
   AADD(aDBF_Stru,{"WKFRETE",AVSX3("W3_FRETE",2)  ,AVSX3("W3_FRETE",3)  ,AVSX3("W3_FRETE",4)})
   AADD(aDBF_Stru,{"WKSEGUR",AVSX3("W3_SEGURO",2) ,AVSX3("W3_SEGURO",3) ,AVSX3("W3_SEGURO",4)})
   AADD(aDBF_Stru,{"WKINLAN",AVSX3("W3_INLAND",2) ,AVSX3("W3_INLAND",3) ,AVSX3("W3_INLAND",4)})
   AADD(aDBF_Stru,{"WKDESCO",AVSX3("W3_DESCONT",2),AVSX3("W3_DESCONT",3),AVSX3("W3_DESCONT",4)})
   AADD(aDBF_Stru,{"WKPACKI",AVSX3("W3_PACKING",2),AVSX3("W3_PACKING",3),AVSX3("W3_PACKING",4)})
   If SW3->(FieldPos("W3_OUT_DES")) > 0
      AADD(aDBF_Stru,{"WKOUTDE",AVSX3("W3_OUT_DES",2),AVSX3("W3_OUT_DES",3),AVSX3("W3_OUT_DES",4)})
   EndIf
EndIf
//AOM - 07/04/2011 - Criação dos campos cod. ope Esp. e Desc ope. Esp. na Work_SW3 - para copiar um PO para outro
If lOperacaoEsp
   AADD(aDBF_Stru,{"W3_CODOPE",AVSX3("W3_CODOPE",2),AVSX3("W3_CODOPE",3),AVSX3("W3_CODOPE",4)})
   AADD(aDBF_Stru,{"W3_DESOPE",AVSX3("W3_DESOPE",2),AVSX3("W3_DESOPE",3),AVSX3("W3_DESOPE",4)})
EndIf

IF AvFlags("EIC_EAI")//AWF - 25/06/2014
   AADD(aDBF_Stru,{"WKSEGUM"  ,"C",AVSX3("W3_SEGUM"  ,3),0})
   AADD(aDBF_Stru,{"WKQTSEGUM","N",AVSX3("W3_QTSEGUM",3),AVSX3("W3_QTSEGUM" ,4)})
   AADD(aDBF_Stru,{"WKFATOR"  ,"N",AVSX3("J5_COEF"   ,3),AVSX3("J5_COEF",4)})
   If SW0->(FieldPos("W0_REFER1")) > 0 //NCF - 26/09/2016
      AADD(aDBF_Stru,{"WKREFER1"  ,"C",AVSX3("W0_REFER1"   ,3),AVSX3("W0_REFER1",4)})
   EndIf
ENDIF

//TRP-14/05/07
aOrd := SaveOrd("SX3",1)
SX3->(dbSeek("SW3"))

While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SW3"
      If SX3->X3_PROPRI=="U" .AND. Ascan(aDBF_Stru, {|x| AllTrim(x[1]) == AllTrim(SX3->X3_CAMPO)})==0 .AND. X3Uso(SX3->X3_USADO)
         aAdd(aDBF_Stru,{SX3->X3_CAMPO,AVSX3(SX3->X3_CAMPO,AV_TIPO),AVSX3(SX3->X3_CAMPO,AV_TAMANHO),AVSX3(SX3->X3_CAMPO,AV_DECIMAL)})
      EndIF
      SX3->(dbSkip())
   Enddo
RestOrd(aOrd)
If !( Type("lPoAuto")=="L" .And. lPoAuto) //FSM - 17/05/2012
   ProcRegua(2)
EndIf

If !( Type("lPoAuto")=="L" .And. lPoAuto) //FSM - 17/05/2012
   IncProc(STR0196)
EndIf
aHeader:={}

//RMD - 27/03/19 - Define os campos da tabela para não incluir os virtuais, evitando problemas de performance no AvReplace
aCampos:={}
aSemSX3 := {}
For i := 1 To SW1->(FCount())
   aAdd(aSemSx3, {SW1->(FieldName(i)), AvSx3(SW1->(FieldName(i)), AV_TIPO), AvSx3(SW1->(FieldName(i)), AV_TAMANHO), AvSx3(SW1->(FieldName(i)), AV_DECIMAL)})
Next
aAdd(aSemSx3, {"RECNO","N",7,0})
aAdd(aSemSx3, {"TRB_ALI_WT","C",03,0})
aAdd(aSemSx3, {"TRB_REC_WT","N",10,0})

/* wfs mar/2017 - adequação para uso do EECCRIATRAB(), com a passagem do 7º parâmetro */
cNomeW1:=E_CriaTrab(/*"SW1" RMD - 27/03/19*/,aSemSx3,"TRB",,,, SaveTempFiles()) //Alias TRB para Gravacao no SI400Grava
/* wfs mar/2017 - adequação para uso do EECIndRequa */
E_INDREGUA("TRB",cNomeW1+TEOrdBagExt(),"W1_CC+W1_SI_NUM+W1_COD_I")

IF !USED()
   RETURN .F.
ENDIF

If !( Type("lPoAuto")=="L" .And. lPoAuto) //FSM - 17/05/2012
   IncProc(STR0196)
EndIf
aHeader:={}
aCampos:={}

/* wfs mar/2017 - adequação para uso do EECCRIATRAB(), com a passagem do 7º parâmetro */
cNomeW3:=E_CriaTrab(,aDBF_Stru,"Work_SW3",,,, SaveTempFiles())

IF !USED()
   RETURN .F.
ENDIF

RETURN .T.

*--------------------------*
FUNCTION PO400Itens(lTela,cMantem,TCCNovo)
*---------------------------*
LOCAL cKey_SA5 := " ", cKey_SB1 := " "
LOCAL cKey_SY3 := " ", cKey_SYG := " ",oBrSelec
LOCAL oDlgItens,nRegua:=5,nContador:=1
LOCAL _LIT_R_CC := IF(EMPTY(ALLTRIM(EasyGParam("MV_LITRCC"))),(AVSX3("W0__CC",5)), ALLTRIM(EasyGParam("MV_LITRCC")))
LOCAL _PictSI   := ALLTRIM(X3PICTURE("W0__NUM"))
LOCAL _PictItem := ALLTRIM(X3PICTURE("B1_COD"))
LOCAL nLinha01,nColuna01,nLinha02,nColuna02,aButtons:={},oDlgProc := GetWndDefault()
Local cSINum  // GFP - 26/02/2013
Local aBufferFabFor := {}//RMD - 21/03/19
Private TB_Campos:={}

If Type("lPoAuto") == "U"
   lPoAuto:= .F.
EndIf

Work_SW3->(avzap())
aSolic:={}

IF(lTela,cMantem:="SIM",)//ASR - 01/10/2005 - IF(lTela,cMantem:=.T.,)//ROBSON 24/08/2005 - SE LTELA .T. A MANTEM A GRAVAÇÃO DO MESMO CENTRO DE CUSTO DO SW3
SA5->(DbSetOrder(3))
SW3->(dbSetOrder(7)) // FILIAL+PO+SEQ
SW3->(DBSEEK(xFilial("SW3")+SW2->W2_PO_NUM))
If !(lPoAuto) //FSM - 17/05/2012
   ProcRegua(nRegua)
EndIf

cSINum := ""  // GFP - 26/02/2013
cSINum := PO400GNrSI(TCCNovo)
WHILE .NOT. SW3->(EOF()) .AND. SW3->W3_PO_NUM = SW2->W2_PO_NUM .AND. SW3->W3_FILIAL == xFilial("SW3")

   /* RMD - 27/03/19 - Movido para após o SKIP da tabela SW3, para somente incrementar nos itens que realmente forem avaliados
   oDlgProc:SetText(STR0008+": "+SW3->W3_PO_NUM)
   If !(lPoAuto) //FSM - 17/05/2012
      IncProc(STR0048+ALLTRIM(SW3->W3_COD_I)) //"Processando Item "
   EndIf
   */

   //FDR - 14/12/2011 - Validação dos campos de Fornecedor/Fabricante + Loja
   If !ExistCpo('SA2',SW3->W3_FABR+If(EICLOJA(),SW3->W3_FABLOJ,""))
      MsgInfo(STR0370)//"O fabricante utilizado neste processo encontra-se bloqueado para uso."
      Exit
   Endif

   IF nContador>nRegua
      nContador:=1
      nRegua:=5
      If !(lPoAuto) //FSM - 17/05/2012
         ProcRegua(nRegua)
      EndIf
   ENDIF

   IF SW3->W3_SEQ <> 0
      SW3->(DBSKIP())
      LOOP
   ENDIF

   oDlgProc:SetText(STR0008+": "+SW3->W3_PO_NUM)
   If !(lPoAuto) //FSM - 17/05/2012
      IncProc(STR0048+ALLTRIM(SW3->W3_COD_I)) //"Processando Item "
   EndIf

   If cKey_SB1 != SW3->W3_COD_I
      cKey_SB1 := SW3->W3_COD_I
      SB1->(DBSEEK(xFilial()+SW3->W3_COD_I))
   Endif

   If cKey_SA5 != SW3->W3_COD_I+SW3->W3_FABR+SW3->W3_FORN
      cKey_SA5 := SW3->W3_COD_I+SW3->W3_FABR+SW3->W3_FORN
      //SA5->(DBSEEK(xFilial()+SW3->W3_COD_I+SW3->W3_FABR+SW3->W3_FORN))
      EICSFabFor(xFilial("SA5")+SW3->W3_COD_I+SW3->W3_FABR+SW3->W3_FORN, EICRetLoja("SW3", "W3_FABLOJ"), EICRetLoja("SW3", "W3_FORLOJ"))
   Endif

   If cKey_SY3 != SW3->W3_CC
      cKey_SY3 := SW3->W3_CC
      SY3->(DbSeek(xFilial()+SW3->W3_CC))
   Endif

   If cKey_SYG != SW3->W3_FABR+SW3->W3_COD_I
      cKey_SYG := SW3->W3_FABR+SW3->W3_COD_I
      SYG->(DBSEEK(xFilial()+SW2->W2_IMPORT+SW3->W3_FABR+EICRetLoja("SW3","W3_FABLOJ")+SW3->W3_COD_I))
   Endif

   //nNum += If(cSINum <> SW3->W3_SI_NUM,1,0)     // GFP - 26/02/2013

   //If cSINum <> SW3->W3_SI_NUM
   //   cSINum := EasyGetMVSeq("MV_SI_NUM")//STRZERO(VAL(EasyGParam("MV_SI_NUM"))+nNum/*1*/,nNumeroSI)
   //EndIf

   Work_SW3->(DBAPPEND())


   //AOM - 07/04/2011 - Adicionar todos os campo da base para work com o mesmo nome
   AVREPLACE("SW3","Work_SW3")
   //AOM - 07/04/2011 - Adiciona descrição da operação na Work_EJ3
   If lOperacaoEsp .And. ChkFile("EJ0")
      Work_SW3->W3_DESOPE := Posicione("EJ0",1,xFilial("EJ0") + AvKey(SW3->W3_CODOPE,"EJ0_COD"),"EJ0_DESC")
   EndIf

   Work_SW3->WKCOD_I   := SW3->W3_COD_I
   Work_SW3->WKFABR    := SW3->W3_FABR
   IF EICLOJA()
       Work_SW3->W3_FABLOJ  := SW3->W3_FABLOJ
   ENDIF
   Work_SW3->WKFORN    := SW3->W3_FORN
   IF EICLOJA()
      Work_SW3->W3_FORLOJ  := SW3->W3_FORLOJ
   ENDIF
   Work_SW3->WKREG     := SW3->W3_REG
   Work_SW3->WKSEQ     := SW3->W3_SEQ
   Work_SW3->WKQTDE    := SW3->W3_QTDE
   Work_SW3->WKQTDE_O  := SW3->W3_QTDE                  // AWR - 5/8/2004 - Incluido
   Work_SW3->WKSALDO_Q := SW3->W3_SALDO_Q//SW3->W3_QTDE // AWR - 5/8/2004 - Alterado
   Work_SW3->WKSALDO_O := SW3->W3_SALDO_Q//SW3->W3_QTDE // AWR - 5/8/2004 - Alterado
   Work_SW3->WKPRECO   := SW3->W3_PRECO
   Work_SW3->WKDTENTR_S:= SW3->W3_DT_ENTR
   Work_SW3->WKFABR_O  := SW3->W3_FABR
   Work_SW3->WKFORN_O  := SW3->W3_FORN
   If EICLoja()
      Work_SW3->W3_FABL_O := SW3->W3_FABLOJ
      Work_SW3->W3_FORL_O := SW3->W3_FORLOJ
   EndIf
   Work_SW3->WKCC      := IF(cMantem == "Nao",TCCNovo,SW3->W3_CC)
   Work_SW3->WKCC_O    := SW3->W3_CC
   //Work_SW3->WKPO_NUM  := SW3->W3_PO_NUM
   Work_SW3->WKCDPOCOPY := SW3->W3_PO_NUM
   Work_SW3->WKPSPOCOPY := SW3->W3_POSICAO
   Work_SW3->WKPOSIT   := SW3->W3_POSICAO //NCF - 30/06/2021 - Manter a posição do item na SI
   Work_SW3->WKSI_NUM  := "*"+cSINum///* "*"+ */SW3->W3_SI_NUM //FDR - 17/05/12      // GFP - 26/02/2013
   Work_SW3->WKSI_ORI  := SW3->W3_SI_NUM
   Work_SW3->WKDT_EMB  := SW3->W3_DT_EMB
   Work_SW3->WKDT_ENTR := SW3->W3_DT_ENTR
   Work_SW3->WKRECNO   := SW3->(RECNO())
   Work_SW3->WKFLUXO   := SW3->W3_FLUXO
   Work_SW3->WKFLUXO_O := SW3->W3_FLUXO
// Work_SW3->WKPART_N  := ALLTRIM(SA5->A5_CODPRF)
   Work_SW3->WKPRECO   := SW3->W3_PRECO
   Work_SW3->WKCCNOME  := SY3->Y3_DESC
   Work_SW3->WK_REG_MIN:= SYG->YG_REG_MIN
   Work_SW3->WKFLAG:=.F.
   //RMD - 21/03/19 - Busca o nome na amarração fabricante x fornecedor e guarda em um buffer
   If (nPosFabFor := aScan(aBufferFabFor, {|x| x[1] == Work_SW3->WKFABR+IF(EICLOJA(),Work_SW3->W3_FABLOJ,"") })) == 0
      Work_SW3->WKNOME_FAB:=BuscaFabr_Forn(Work_SW3->WKFABR,IF(EICLOJA(),Work_SW3->W3_FABLOJ,""))
      aAdd(aBufferFabFor, {Work_SW3->WKFABR+IF(EICLOJA(),Work_SW3->W3_FABLOJ,""), Work_SW3->WKNOME_FAB})
   Else
      Work_SW3->WKNOME_FAB := aBufferFabFor[nPosFabFor][2]
   EndIf
   Work_SW3->TRB_ALI_WT:="SW3"
   If SW3->(FIELDPOS("W3_PART_N")) # 0 //ASK 02/10/2007
      Work_SW3->WKPART_N := SW3->W3_PART_N
   Else
      Work_SW3->WKPART_N := ALLTRIM(SA5->A5_CODPRF)
   EndIf

   If SW3->(FIELDPOS("W3_PESOL")) # 0 //CCH - 07/08/09 - Gravação do novo campo de Peso Líquido Unitário
      Work_SW3->WKPESOL := SW3->W3_PESOL
   EndIf

   If lCpoCtCust                          //NCF - 22/06/2010
      Work_SW3->WKCTCUSTO := SW3->W3_CTCUSTO
   EndIf
   If lPesoBruto                         //NCF - 25/08/2011 - Campo do Peso Bruto Unitário
      Work_SW3->WKPSBRUTO := SW3->W3_PESO_BR
   EndIf
   If AvFlags("RATEIO_DESP_PO_PLI")
      Work_SW3->WKFRETE := SW3->W3_FRETE
      Work_SW3->WKSEGUR := SW3->W3_SEGURO
      Work_SW3->WKINLAN := SW3->W3_INLAND
      Work_SW3->WKDESCO := SW3->W3_DESCONT
      Work_SW3->WKPACKI := SW3->W3_PACKING
      If SW3->(FieldPos("W3_OUT_DES")) > 0
         Work_SW3->WKOUTDE := SW3->W3_OUT_DES
      EndIf
   EndIf
   IF AvFlags("EIC_EAI")//AWF - 25/06/2014
      Work_SW3->WKUNI    :=SW3->W3_UM
      Work_SW3->WKSEGUM  :=SW3->W3_SEGUM
      Work_SW3->WKQTSEGUM:=SW3->W3_QTSEGUM
      Work_SW3->WKFATOR  :=Work_SW3->WKQTSEGUM/Work_SW3->WKQTDE
   ENDIF

   //AWR - 6/8/2004
   IF SW3->W3_QTDE # SW3->W3_SALDO_Q
      nQtd_Gi:=nSld_GI:=0
      nQtdEmb:= 0
      Po420_IgPos("1")
      Work_SW3->WKSALDO_GI  := nSld_Gi
      Work_SW3->WKQTDE_GI   := nQtd_Gi
      //Work_SW3->WKQTDE_EMB  := (Work_SW3->WKQTDE_GI-Work_SW3->WKSALDO_GI)
      Work->WKQTDE_EMB      := nQtdEmb
      Work_SW3->WKQTDE_LI   := (Work_SW3->WKQTDE_GI)
      IF SW3->W3_FLUXO == '7'
         Work_SW3->WKSALDO_O:= nSld_Gi
         Work_SW3->WKSALDO_Q:= nSld_Gi
      ENDIF
   ENDIF
   //AWR - 6/8/2004

   MTotal   += VAL(STR(SW3->W3_QTDE * SW3->W3_PRECO,15,2))
   MFob_Abs += VAL(STR(SW3->W3_QTDE * SW3->W3_PRECO,15,2))

   IF(lSeal,ExecBlock("IC193PO1",.F.,.F.,"3"),) //AWR 01/10/1999
   IF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"9"),)//AWR 09/11/1999

   IF lExiste_Midia           .AND.;
      !EMPTY(SW2->W2_VLMIDIA) .AND.;
      SB1->B1_MIDIA $ cSim
      Work_SW3->WK_QTMIDIA := SB1->B1_QTMIDIA
      Work_SW3->WK_VLTOTMI := SB1->B1_QTMIDIA * SW2->W2_VLMIDIA * SW3->W3_QTDE
   ENDIF

   //TRP- 01/06/09 - Campo Software para novo Tratamento de Mídia e Software
   If SW3->(FieldPos("W3_SOFTWAR")) # 0 .And. EasyGParam("MV_CONSOFT",, "N") $ cSim
      Work_SW3->WKSOFTWAR:= SW3->W3_SOFTWAR
   Endif
// TROCADO PARA PEGAR DIRETO DO WORK_SW3   // ROBSON 25/08/05

// Quando o usuário faz a copia do po esta array asolic gera um registro dentro do help
// das SI´S.
/*
   IF ( ASCAN(aSolic,{|a| a[1]+a[2]==SW3->W3_SI_NUM+SW3->W3_CC})    )==0
      AADD(aSolic,{SW3->W3_SI_NUM,SW3->W3_CC,SW3->W3_CC})
   ENDIF
*/
   IF ( ASCAN(aSolic,{|a| a[1]+a[2]==Work_SW3->WKSI_ORI+Work_SW3->WKCC})    )==0
      AADD(aSolic,{Work_SW3->WKSI_ORI,Work_SW3->WKCC,Work_SW3->WKCC_O,Work_SW3->WKSI_NUM})
   ENDIF


      IF EasyEntryPoint("IC086PO1")
         ExecBlock("IC086PO1",.F.,.F.,3)
      ENDIF

      IF EMPTY(ALLTRIM(SW3->W3_TEC))
         Work_SW3->WK_TEC    := SB1->B1_POSIPI
         Work_SW3->WK_EX_NCM := SB1->B1_EX_NCM
         Work_SW3->WK_EX_NBM := SB1->B1_EX_NBM
      ELSE
         Work_SW3->WK_TEC    := SW3->W3_TEC
         Work_SW3->WK_EX_NCM := SW3->W3_EX_NCM
         Work_SW3->WK_EX_NBM := SW3->W3_EX_NBM
      ENDIF

   If lForeCast
      Work_SW3->WK_FORECAS := SW3->W3_FORECAS
   Endif

   Work_SW3->WK_REG_TRI := SW3->W3_REG_TRI

   If lNestle
      ExecBlock(cArqNestle,.F.,.F.,"2")
   Endif

   IF SB1->(DBSEEK(xFilial()+ Work_SW3->WKCOD_I))
      Work_SW3->WKDESCR :=MSMM(&("SB1->B1_DESC_"+cDESC_PO),AVSX3("B1_VM_"+cDESC_PO,3),1 )
   ENDIF

   IF SA2->(DBSEEK(xFilial()+ Work_SW3->WKFABR+EICRetLoja("SW3", "W3_FABLOJ")))
      Work_SW3->WKNOME_FAB := SA2->A2_NREDUZ
   ENDIF

   IF SA2->(DBSEEK(xFilial()+ Work_SW3->WKFORN+EICRetLoja("SW3", "W3_FORLOJ")))
       Work_SW3->WKNOME_FOR := SA2->A2_NREDUZ
   ENDIF

   IF cPaisLoc # "BRA"  .AND. SW1->(FIELDPOS("W1_NATUREZ")) # 0
      PosO1_It_Solic(SW3->W3_CC,SW3->W3_SI_NUM,SW3->W3_COD_I,SW3->W3_REG,0)
      Work_SW3->WKNATUREZA:= SW1->W1_NATUREZ
   ENDIF

   IF lRdMake
      ExecBlock("EICPPO02",.F.,.F.,"18")
   ENDIF

   nPontoEntrada:=3
   IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"WORK_DESPESAS"),)

   SW3->(DBSKIP())
ENDDO

//FDR - 17/05/12
//SETMV("MV_SI_NUM",STRZERO(VAL(EasyGParam("MV_SI_NUM"))+1,nNumeroSI))

IF !lTela
   RETURN .T.
ENDIF

bTotal:={||TRANSFORM(Work_SW3->WKQTDE*Work_SW3->WKPRECO,_PictPrTot)}


AADD(Tb_Campos,{{||Work_SW3->WKCC+' - '+Work_SW3->WKCCNOME},,_LIT_R_CC })
AADD(Tb_Campos,{"WKSI_ORI",,STR0011,_PictSI}) //"No.SI"
AADD(Tb_Campos,{"WKPOSICAO",,STR0012}) //AWR 10/02/99 //"Posicao"
AADD(Tb_Campos,{"WKCOD_I" ,,STR0013,_PictItem}) //"Item"
AADD(Tb_Campos,{"WKPART_N",,STR0014}) //"Part Number"

If cPaisLoc=="BRA"
   AADD(Tb_Campos,{{||IF(Work_SW3->WKFLUXO=='7',STR0015,STR0016)},,STR0017}) //'Nao'###'Sim'###"Anuencia"
EndIf

IF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"7"),)//AWR 09/11/1999

AADD(Tb_Campos,{"WKDESCR" ,,AVSX3("B1_DESC_"+cDESC_PO,AV_TITULO)}) //"Descricao em ###"
AADD(Tb_Campos,{{||Work_SW3->WKFABR +' - '+Work_SW3->WKNOME_FAB},,STR0019}) //"Fabricante"

IF lExiste_Midia .AND. !EMPTY(SW2->W2_VLMIDIA)//AWR 21/10/1999
   AADD(Tb_Campos,{"WK_QTMIDIA",,AVSX3("B1_QTMIDIA",5),AVSX3("B1_QTMIDIA",6)})
   AADD(Tb_Campos,{"WK_VLTOTMI",,STR0021,AVSX3("W2_VLMIDIA",6)}) //"Vlr. Total Midia"
ENDIF

AADD(Tb_Campos,{"WKQTDE"  ,,STR0022,_PictQtde}) //"Quantidade"

IF AvFlags("EIC_EAI")//AWF - 25/06/2014
   AADD(Tb_Campos,{"WKUNI"  ,,AVSX3("W3_UM",AV_TITULO)})
ELSE
   IF EICLOJA()
      AADD(Tb_Campos,{{||BUSCA_UM(Work_SW3->WKCOD_I+Work_SW3->WKFABR+Work_SW3->WKFORN,WORK_SW3->WKCC+WORK_SW3->WKSI_NUM,WORK->W3_FABLOJ,WORK->W3_FORLOJ)},,STR0020}) //"Uni"
   ELSE
      AADD(Tb_Campos,{{||BUSCA_UM(Work_SW3->WKCOD_I+Work_SW3->WKFABR+Work_SW3->WKFORN,WORK_SW3->WKCC+WORK_SW3->WKSI_NUM,"","")},,STR0020}) //"Uni"
   ENDIF
ENDIF

IF AvFlags("EIC_EAI")//AWF - 25/06/2014
   AADD(Tb_Campos,{"WKQTSEGUM",,AVSX3("W3_QTSEGUM",AV_TITULO),AVSX3("W3_QTSEGUM",6)})
   AADD(Tb_Campos,{"WKSEGUM"  ,,AVSX3("W3_SEGUM",AV_TITULO)})
ENDIF
If SW3->(FIELDPOS("W3_PESOL")) # 0 //CCH - 07/08/09 - Gravação do novo campo de Peso Líquido Unitário
   AADD(Tb_Campos,{"WKPESOL",,AVSX3("W3_PESOL",5),AVSX3("W3_PESOL",6)})
EndIf
AADD(Tb_Campos,{"WKPRECO"  ,,STR0025,_PictPrUn}) //"Preco Unit"
AADD(Tb_Campos,{bTotal,,STR0026}) //"Valor Total"
AADD(Tb_Campos,{"WKDT_EMB" ,,STR0027}) //"Embarque"
AADD(Tb_Campos,{"WKDT_ENTR",,STR0028}) //"Entrega"

//TRP- 01/06/09 - Campo Software para novo Tratamento de Mídia e Software
If SW3->(FieldPos("W3_SOFTWAR")) # 0 .And. EasyGParam("MV_CONSOFT",, "N") $ cSim
   AADD(Tb_Campos,{{||IF(Work_SW3->WKSOFTWAR=='2',STR0015,STR0016)},,AVSX3("W3_SOFTWAR",5)})
Endif
If lNestle
   ExecBlock(cArqNestle,.F.,.F.,"8")
Endif

IF lRdMake
   ExecBlock("EICPPO02",.F.,.F.,"15")
ENDIF

If lForeCast
   AADD(Tb_Campos,{{||IF(WORK_SW3->WK_FORECAS=="S",STR0029,STR0030)},,STR0031}) //CAF 22/10/98 //"Sim"###"Nao"###"Forecast"
Endif

AADD(Tb_Campos,{{||SX5->(dbSeek(xFilial()+"Y2"+Work_SW3->WK_REG_TRI)),AllTrim(X5DESCRI())},,AVSX3("W3_REG_TRI")[5]})
AADD(Tb_Campos,{"WK_REG_MIN",,STR0032}) //AWR 22/4/98 //"Registro no Minist‚rio / OrgÆo P£blico"
AADD(Tb_Campos,{{|| TRANSFORM(WORK_SW3->WK_TEC,AVSX3("YD_TEC",6))},,AVSX3("W3_TEC"   )[5]})
AADD(Tb_Campos,{{|| TRANSFORM(WORK_SW3->WK_EX_NCM,AVSX3("YD_EX_NCM",6))},,AVSX3("W3_EX_NCM")[5]})
AADD(Tb_Campos,{{|| TRANSFORM(WORK_SW3->WK_EX_NBM,AVSX3("YD_EX_NBM",6))},,AVSX3("W3_EX_NBM")[5]})

IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"BROWSE_VISUALIZAR"),)

If !lPOAuto  // GFP - 26/08/2013
   oMainWnd:ReadClientCoords()
EndIf
nLinha01:=15
nColuna01:=1

While .T.


   DEFINE MSDIALOG oDlgItens TITLE IF(!Empty(M->W2_HAWB_DA),STR0222+AllTrim(TRANSFORM(M->W2_HAWB_DA,AVSX3("W2_HAWB_DA",6))),cCadastro)+" "+SW2->W2_PO_NUM ; //"Pedido de Nacionalização - DA: "
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
            OF oMainWnd PIXEL

   nLinha02 :=(oDlgItens:nClientHeight-6)/2
   nColuna02:=(oDlgItens:nClientWidth-4)/2

   Work_SW3->(dbGoTop())

   oBrSelec:=MsSelect():New("Work_SW3",,,TB_Campos,@lInverte,@cMarca,{nLinha01,nColuna01,nLinha02,nColuna02})
   oDlgItens:lMaximized:=.T. //LRL 18/03/04 Maximiliza Janela na versão MDI

   oBrSelec:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oBrSelec:oBrowse:Refresh() //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   //DFS - 31/01/13 - Inclusão de refresh na tela
   ACTIVATE MSDIALOG oDlgItens ON INIT (EnchoiceBar(oDlgItens,{||oDlgItens:End()},{||oDlgItens:End()}),oBrSelec:oBrowse:Refresh())//LRL 18/03/04 Alinhamento MDI    //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   Exit
Enddo

SA5->(DbSetOrder(1))
SW3->(dbSetOrder(1))

RETURN .T.
*---------------------------------*
FUNCTION PO400CopiaGrv()
*---------------------------------*
LOCAL nInd,nSW2Col:=SW2->(FCount())
Private lNaoCopiaSW2:=.F.,cCampoSW2:="", lExecTrig:=.T.			//CDS 6/10/05

If Type("lPoAuto") == "U"
   lPoAuto:= .F.
EndIf

If !(lPoAuto) //FSM - 17/05/2012
   ProcRegua(nSW2Col)
EndIf
SX3->(DBSETORDER(2))

IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"ANTES_COPIA_LOOPSW2"),)		//CDS 6/10/05

DBSELECTAREA("SW2")
FOR nInd := 1 TO nSW2Col
   If !(lPoAuto) //FSM - 17/05/2012
      IncProc(STR0107+" "+SW2->W2_PO_NUM)
   EndIf
   //CDS 6/10/05
   cCampoSW2:=SW2->(FieldName(nInd))
   lNaoCopiaSW2:=.F.
   IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"COPIA_LOOPSW2"),)
   If lNaoCopiaSW2==.T.
      LOOP
   Endif

   IF SW2->(FieldName(nInd))=="W2_PO_NUM"
      IF EMPTY(M->W2_PO_NUM)
         M->W2_PO_NUM:=CRIAVAR("W2_PO_NUM")
      ENDIF
      LOOP
   ENDIF

   M->&(FIELDNAME(nInd)) := SW2->(FieldGet(nInd))

   IF SX3->(DBSEEK(SW2->(FieldName(nInd)))) .AND. !EMPTY(SX3->X3_TRIGGER) .AND. lExecTrig==.T.		//CDS 06/10/05
      RunTrigger(1,,,,SX3->X3_CAMPO)
   ENDIF
NEXT

SX3->(DBSETORDER(1))

M->W2_NR_ALTE:=0
M->W2_DT_ALTE:=CTOD("")
M->W2_VM_OBS:=MSMM(M->W2_OBS,60)
M->W2_FOB_TOT   := 0
M->W2_FOB_GER   := 0
M->W2_PO_DT     := dDataBase //JWJ 02/01/2007
//MFR 13/06/2109 OSSME-3156
//If EasyGParam("MV_EASY",,"N") == "S"
   M->W2_PO_SIGA:= ""
//EndIf

MFOB_ABS        := 0

If !(lPoAuto) //FSM - 17/05/2012
   PROCREGUA(WORK_SW3->(LASTREC()))
EndIf
WORK_SW3->(DBGOTOP())

DO WHILE WORK_SW3->(!EOF())
   If !(lPoAuto) //FSM - 17/05/2012
      IncProc(STR0048+ALLTRIM(WORK_SW3->WKCOD_I))
   EndIf
   WORK->(DBAPPEND())
   AVReplace("WORK_SW3","WORK")

   Work->WKSEM_PO  := Work_SW3->WKQTDE
// Work->WKQTDE    := 0 MCF - 16/03/2017 - O campo QTDE estava ficando zerado e assim acabava caindo na validacao nao permitindo utilizar a funcao de selecionar todos.
   Work->WKQTDE_O  := 0
   Work->WKSALDO_Q := 0
   Work->WKSALDO_O := 0

   WORK_SW3->(DBSKIP())
ENDDO

WORK->(DBGOTOP())

lCopiou := .F.  // GCC - 03/06/2013 // GFP - 26/02/2013

RETURN .T.

*---------------------------*
FUNCTION PO400NewCC(cUniReq)
*---------------------------*
LOCAL nReg:=0,nAscan

If Type("lPoAuto") == "U"
   lPoAuto:= .F.
EndIf

If !(lPoAuto) //FSM - 17/05/2012
   PROCREGUA(WORK_SW3->(LASTREC()))
EndIf
WORK_SW3->(DBGOTOP())

DO WHILE WORK_SW3->(!EOF())
   If !(lPoAuto) //FSM - 17/05/2012
      IncProc(STR0048+ALLTRIM(WORK_SW3->WKCOD_I))
   EndIf

   IF (nAscan:=Ascan(aSolic,{|a| a[1]+a[2]==WORK_SW3->WKSI_ORI+WORK_SW3->WKCC}))>0
      aSolic[nAscan,2]:=cUniReq //3º =C.C. Original
   ENDIF
   WORK_SW3->WKCC  :=cUniReq
   WORK_SW3->WKREG :=nReg++

   WORK_SW3->(DBSKIP())

ENDDO


RETURN .T.

*--------------------------*
FUNCTION PO400SIAUTO()
*--------------------------*
LOCAL cUnidReq:="",cSolic:="",cFilSW0:=xFilial("SW0"),cFilSW1:=xFilial("SW1")
LOCAL nSINUM:=AVSX3("W1_SI_NUM",3)-1,nSeqSI,nInd:=1,cChave
LOCAL aCpos := {"W1_COD_I","W1_FABR"   ,"W1_FORN","W1_CLASS",;
                "W1_QTDE" ,"W1_SALDO_Q","W1_PRECO","W1_DTENTR_",;
                "W1_DT_EMB"}
Local nPosit := 1
//Variaveis para SI400Grava
PRIVATE lUnisys:=EasyEntryPoint("IC159SI0")
PRIVATE lHunter:=EasyEntryPoint("IC010PO1")
PRIVATE aSI400Del:={},aHeader:={},aCamposSW1:={}
Private cSolicitacao
Private lInclui

If Type("lPoAuto") == "U"
   lPoAuto:= .F.
EndIf

aCamposSW1 := CriaEstru(aCpos,@aHeader)

EICAddLoja(aCpos, "W1_FORLOJ", Nil, "W1_FORN")
EICAddLoja(aCpos, "W1_FABLOJ", Nil, "W1_FABR")

If !(lPoAuto) //FSM - 17/05/2012
   PROCREGUA(WORK->(LASTREC()))
EndIf
aOrdWrk := SaveOrd("WORK")
SW1->(DBSETORDER(2))//W1_FILIAL+W1_PO_NUM+W1_POSICAO+W1_CC+W1_SI_NUM
WORK->(DBSETORDER( If(nOrder==2,3,nOrder) ))//WKCC+WKSI_ORI //NCF - 31/05/2021 - Ordem de gravação da SI cópia deve seguir a ordenação setada pelo botão "Ordena Itens".
WORK->(DBGOTOP())

DO WHILE WORK->(!EOF())
   If !(lPoAuto) //FSM - 17/05/2012
      INCPROC()
   EndIf

   IF EMPTY(WORK->WKSI_ORI) .OR. LEFT(WORK->WKSI_NUM,1)<>"*" .OR. Work->WKFLAGWIN <> cMarca
      WORK->(DBSKIP())
      LOOP
   ENDIF

   IF cUnidReq+cSolic<>WORK->WKCC+WORK->WKSI_ORI
      cUnidReq:=WORK->WKCC
      cSolic  :=WORK->WKSI_ORI
//      nSeqSI:=VAL(EasyGParam("MV_SI_NUM"))+1
      DO WHILE .T.
         cSolicitacao:=WORK->WKSI_NUM//"*"+STRZERO(nSeqSI,nSINUM)
         IF SW0->(DBSEEK(cFilSW0+cUnidReq+cSolicitacao))
            EXIT //TDF - 27/07/2012
            //nSeqSI++
            LOOP
         ENDIF
         EXIT
      ENDDO
      //SETMV("MV_SI_NUM",STRZERO(nSeqSI,nSINUM))

      //ISS - 26/08/10 - Ponto de entrada usado para alterar o número da SI automática através da variável cSolicitacao
      If EasyEntryPoint("EICPO400")
         ExecBlock("EICPO400",.F.,.F.,"GRAVA_SICOPIA")
      EndIf

   ENDIF

   DO WHILE WORK->(!EOF()) .AND. cUnidReq+cSolic==WORK->WKCC+WORK->WKSI_ORI

      IF WORK->WKFLAGWIN <> cMarca
         WORK->(DBSKIP())
         LOOP
      ENDIF

      IF SW1->(DBSEEK(cFilSW1+WORK->(/*WKPO_NUM*/WKCDPOCOPY+WKPSPOCOPY/*WKPOSICAO*/+WKCC_O+WKSI_ORI)))
         TRB->(DBAPPEND())
         AVREPLACE("SW1","TRB")
         TRB->W1_CC     := cUnidReq
         TRB->W1_SI_NUM := cSolicitacao
         TRB->W1_SALDO_Q:= WORK->WKQTDE
         TRB->W1_QTDE   := WORK->WKQTDE
         TRB->W1_PO_NUM := M->W2_PO_NUM
         TRB->W1_SEQ    := 0
         TRB->RECNO     := 0
         TRB->TRB_ALI_WT:= "SW1"
         TRB->TRB_REC_WT:= 0

         //ISS - 18/10/10 - Incluindo os dados da posição do item na SI automática.
         If SW1->(FieldPos("W1_POSIT")) > 0
            TRB->W1_POSIT  := StrZero(nPosit,4,0)
         EndIf

         nPosit++

         If lCpoCtCust
            TRB->W1_CTCUSTO := Work->WKCTCUSTO
         EndIf

         If EasyEntryPoint("EICPO400")                           //NCF - 21/10/2010
            ExecBlock("EICPO400",.F.,.F.,"GRAVATRB_SI_AUTO")
         EndIf

      ENDIF
      WORK->WKSI_NUM:=cSolicitacao
      cChave:=WORK->WKCC_O+WORK->WKSI_ORI
      WORK->(DBSKIP())
   ENDDO

   DBSELECTAREA("SW0")
   SW0->(DBSEEK(cFilSW0+cChave))
   FOR nInd := 1 TO SW0->(FCount())
      M->&(FIELDNAME(nInd)) := FieldGet(nInd)
   NEXT nInd
   M->W0__CC :=cUnidReq
   M->W0__NUM:=cSolicitacao
   M->W0__DT := M->W2_PO_DT   //ISS - 18/10/10 - Uso da data do PO na data da SI automática.
   M->W0_C1_NUM := Space(Len(SW0->W0_C1_NUM))  // GFP - 12/05/2015
   lComEdit:=.F. // Variavel que é usada no programa EICSI400 para saber se a inclusão foi feita em MSSELECT ou MSGETDB.
   lInclui := .T.
   SI400Grava("SW0","SW1")
   TRB->(avzap())
ENDDO
SW1->(DBSETORDER(1))
RestOrd(aOrdWrk,.T.)

RETURN .T.

*----------------------------------------------------------------------------*
// EOS - 0486/02 - Abre tela para entrada da SI de referencia
Function PO400SiRef()
*----------------------------------------------------------------------------*
LOCAL _PictSI := ALLTRIM(X3PICTURE("W0__NUM"))
LOCAL _PictCC := ALLTRIM(X3PICTURE("Y3_COD"))
LOCAL lValidCC:=.F., lValidSI:=.F., nOpSi := 0
LOCAL aOrdSC3 := {} //LGS-24/03/2015
Local oPanel, nLinha
Private cFiltraCC := "SY3" //LBL - 30/07/2013

// EOB - 06/08/09 - somente utilizar o botão SI de referência apos ter informado o fornecedor para realizar a carga
// dos itens da SI corretamente
IF EMPTY(M->W2_FORN)
   Help("", 1, "AVG0000344")//"Fornecedor não preenchido"###"Atenção"
   RETURN .F.
ENDIF

IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"FILTRACC"),) //LBL - 30/07/2013

lSiReferencia:=.T.
SETKEY(VK_F4,{||PO400HLPW0()})
DEFINE MSDIALOG oDlg TITLE STR0051 From 9,0 To 20,75 OF oMainWnd //"Sele‡ao de S.I."

   oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165)//LRS - 18/05/2015
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   nLinha := 20

   @ nLinha,30 SAY STR0052 SIZE 90,08 PIXEL OF oPanel //"C.C."
   @ nLinha+13,30 SAY cRecSTR SIZE 90,08 PIXEL OF oPanel //'S.I. N§'

   @ nLinha,210 SAY STR0054 SIZE 25,08 PIXEL OF oPanel //'(F3-Help)'  //SO.:0026 FCD
   @ nLinha+13,210 SAY STR0055 SIZE 25,08 PIXEL OF oPanel //'(F4-Help)' // SO.:0026 FCD

   @ nLinha,140 MSGET oGetCC VAR TCC F3 cFiltraCC PICTURE _PictCC ;
           VALID (lValidCC:=PO_ValidCC(lValidCC)) PIXEL SIZE 40,08 OF oPanel HASBUTTON
   @ nLinha+13,140 MSGET oGetSI VAR TSi_Num F3 "GETSI" PICTURE _PictSI ;
           VALID (If((lValidSI:=PO_ValidSI(lValidSI)),nOpSI:=1,)) SIZE 40,8 PIXEL OF oPanel HASBUTTON
    
    oGetSI:bF3 := {|| If(PO400HLPW0(),oGetSI:Refresh(),)}
   
   nOpSI:=0

ACTIVATE MSDIALOG oDlg ON INIT ;
   EnchoiceBar(oDlg,{||nOpSI:=1,If(lValidCC .AND. lValidSI,oDlg:End(),)},;
                    {||nOpSI:=0,oDlg:End()}) CENTERED

SETKEY(VK_F4,NIL)

IF nOpSI = 0
   lSiReferencia:=.F.
   RETURN .F.
ENDIF
IF !EMPTY(TCC) .AND. !EMPTY(TSi_Num)
   lSolic := .F.
   IF LEN(aFornSW1)==1 .And. !Empty(aFornSW1[1])
      //SVG - 13/09/2011 - Comentado devido a ter a possibilidade de na SI estas informações estarem em branco, pode apagar as inf. inseridas no PO.
      /*M->W2_FORN := aFornSW1[1][1]
      IF EICLOJA()
         M->W2_FORLOJ:= aFornSW1[1][2]
      ENDIF
      IF SA2->(dbSeek(xFilial()+M->W2_FORN+EICRetLoja("M","W2_FORLOJ")))
         M->W2_FORNDES := SA2->A2_NREDUZ
      ENDIF*/
   ENDIF
   M->W2_COMPRA := SW0->W0_COMPRA
   IF SY1->(dbSeek(xFilial()+M->W2_COMPRA))
      M->W2_COMPRAN := SY1->Y1_NOME
   ENDIF
   M->W2_MOEDA  := SW0->W0_MOEDA

   //LGS-23/03/2015 - Busca a condição de pagamento apartir da condicao que foi informada no SC3-Contratos,
   //e pega sempre a primeira condição que esta no cadastro, pq o conceito é 1,1.
   If SW0->(FieldPos("W0_CONTR"))>0 .And. SW2->(FieldPos("W2_CONTR"))>0
      If M->W2_CONTR == '1'
         aOrdSC3 := SaveOrd({"SC3","SW1","SY6"})
         SC3->(DbSetOrder(1))
         If SW1->(DBSEEK(xFilial("SW1")+AvKey(TCC,"W1_CC")+AvKey(TSi_Num,"W1_SI_NUM"))) .And.;
            SC3->(DbSeek(xFilial("SC3")+SW1->W1_C3_NUM))
            SY6->(DbSeek(xFilial("SY6") ))
            Do While SY6->(!Eof()) .And. SY6->Y6_SIGSE4 == SC3->C3_COND
               M->W2_COND_PA := SY6->Y6_COD
               Exit
            EndDo
         EndIf
         RestOrd(aOrdSC3,.T.)
      EndIf
   EndIf

   lRefresh := .T.
ENDIF
lCopiaPO:=.F.
//lSiReferencia:=.T.
//TRP - 22/05/2007
If EasyEntryPoint("EICPO400")
   ExecBlock("EICPO400",.F.,.F.,"SI_REF")
EndIf
RETURN .T.
*-----------------------------*
FUNCTION POSALDO_W1(lMem)// Essa funcao era chamada do X3_RELACAO do campo W3_SEM_PED, nao pode
*-----------------------------*
LOCAL cSI_Original:=Work->WKSI_NUM, nSaldo_SI:=0
Default lMem := .F.  // GFP - 25/04/2015

IF PosO1_It_Solic(Work->WKCC,cSI_Original,Work->WKCOD_I,Work->WKREG,0)
   nSaldo_SI:=SW1->W1_SALDO_Q
ENDIF

IF !EMPTY(WORK->WKSI_ORI)
   //nSaldo_SI:=Work->WKQTDE
   nSaldo_SI   :=Work->WKSEM_PO
   cSI_Original:=WORK->WKSI_ORI
ENDIF

IF !Inclui
   IF PosO2_It_Solic(SW2->W2_PO_NUM,Work->WKCC,cSI_Original,Work->WKCOD_I,If(lMem,M->W3_FABR,Work->WKFABR),If(lMem,M->W3_FORN,Work->WKFORN),Work->WKREG, IF(EICLOJA(),If(lMem,M->W3_FABLOJ,Work->W3_FABLOJ),""),IF(EICLOJA(), If(lMem,M->W3_FORLOJ,Work->W3_FORLOJ),""))   // GFP - 25/04/2015
      nSaldo_SI+=SW1->W1_QTDE
   ENDIF
ENDIF

RETURN nSaldo_SI

*-----------------------------*
FUNCTION PO400Saldo()// Essa funcao é chamada nos Browse's
*-----------------------------*
If Work->WKFLUXO=="1"
   RETURN (Work->WKQTDE - Work->WKQTDE_LI)
ElseIf Work->WKFLUXO=="7"
   RETURN (Work->WKQTDE - Work->WKQTDE_EMB)
Endif

RETURN 0

*-----------------------------*
FUNCTION POATUALIZA()// Essa funcao é chamada do X3_VALID do campo W3_QTDE
*-----------------------------*
Local nSaldoSemPO := POSALDO_W1()
Local nSemPedido  := (nSaldoSemPO - M->W3_QTDE)//JL
M->W3_CUSTO   := (M->W3_QTDE  * M->W3_PRECO)
M->W3_SEM_PED := IF(nSemPedido > 0, nSemPedido,0) // Quando o valor for negativo, zerar.//JL

IF Work->WKFLUXO=="1"
   M->W3_SALDO_Q := (M->W3_QTDE - Work->WKQTDE_LI)
ElseIf Work->WKFLUXO=="7"
   M->W3_SALDO_Q := (M->W3_QTDE - M->W3_QTD_EMB)
Endif

RETURN .T.
*-----------------------------------------------------*
FUNCTION PO400WHEN(cCampo) // OS-0447/04 OC 0012/04
// JBS - 01/04/2004 - Verificando When dos campos
*-----------------------------------------------------*
Local lRetorno := .F.
Local cVm_OBS //MFR 20/09/2019
SWB->(dbSetOrder(1))
If cCampo == "COD_MSG"
   If INCLUI
      lRetorno := .T.
   ElseIf ALTERA
      cVM_OBS := MSMM(M->W2_OBS,60)
      lRetorno := eval({|| if(Empty(M->W2_VM_OBS).and.Empty(cVm_OBS),.t.,.f.)})
   EndIf
ElseIF cCampo == "W3_QTDE" .OR. cCampo == "W3_PRECO"
   lRetorno := .T.  //WhenQtdPrec(cCampo)  // GFP - 06/06/2013 - Sistema deve sempre permitir alteração de Quantidade e Preço dos itens.

ElseIf (cCampo == "W2_SEGINC"  .OR. cCampo == "W2_FREINC"  .OR. cCampo == "W2_RAT_POR" .OR.;
        cCampo == "W2_FRETEIN" .OR. cCampo == "W2_SEGURIN" .OR. cCampo == "W2_INLAND" .OR.;
        cCampo == "W2_DESCONT" .OR. cCampo == "W2_PACKING")
   If !Inclui
      nRecEW5 := EW5->(Recno())
      nRecSW5 := SW5->(Recno())
      EW5->(DbSetOrder(2)) //EW5_FILIAL+EW5_PO_NUM+EW5_POSICA+EW5_INVOIC+EW5_FORN+EW5_FORLOJ
      SW5->(DbSetOrder(3)) //W5_FILIAL+W5_PO_NUM+W5_COD_I
      lRetorno := !(EW5->(DbSeek(xFilial("EW5")+M->W2_PO_NUM)))
      If lRetorno
         If Select("EICSW5") > 0
            EICSW5->(DbCloseArea())
         EndIf   

         BeginSQL Alias "EICSW5"

         SELECT SW5.R_E_C_N_O_ FROM %Table:SW5%  SW5
                WHERE SW5.%NotDel% AND 
                      SW5.W5_FILIAL= %exp:xFilial("SW5")%  AND 
                      SW5.W5_PO_NUM = %exp:M->W2_PO_NUM% AND 
                      SW5.W5_FLUXO = "1"
         EndSql
   
         IF !EICSW5->(EOF() .OR. BOF()) 
             lRetorno := .F.
         EndIf
      EndIf
   Else
      lRetorno := .T.
   EndIf
ElseIf cCampo == "W2_DIAS_PA" .OR. cCampo == "W2_MOEDA"
   lRetorno := If(AvFlags("EIC_EAI") .AND. M->W2_CONTR == "1",.F.,.T.)
ElseIf cCampo == "W2_COND_PA"
   lRetorno := .T.
ElseIf cCampo == 'W2_NR_PRO' .OR. cCampo == 'W2_DT_PRO' //LRS - 24/10/2017
   lRetorno := INCLUI .OR. !(EYZ->(DbSeek(xFilial('EYZ')+SW2->W2_PO_NUM)))
ElseIf cCampo == "W2_IMPCO"                                                       //NCF - 01/06/2020 - Desabilita quando for alteração em ambiente integ. Compras para não alterar fornecedor.
   lRetorno := (!AvFlags("EIC_EAI") .Or. Empty(M->W2_PO_SIGA) .Or. !ALTERA) .And. !( ALTERA .And. EasyGParam("MV_EASY",,"N") == "S" .And. !EasyGParam("MV_PCOIMPO",,.F.) )
EndIF
Return(lRetorno)


*-----------------------------------------------------*
Function PO400ZERA(cAlias,nReg,nOpc)
*-----------------------------------------------------*
LOCAL oDlg, oGet , oEnch
Local bOk, bCancel := {|| oDlg:End()}, bMarcaTodos := {|u| MarcaTodos(cMarca)}
Local aButtons := {{"LBTIK",bMarcaTodos,"Marca/Desmarca Todos","Marc./Des."}}
Local lOk , i
LOCAL cAlias1:="SW3", FileWork
LOCAL _LIT_R_CC := IF(EMPTY(ALLTRIM(EasyGParam("MV_LITRCC"))),(AVSX3("W0__CC",5)), ALLTRIM(EasyGParam("MV_LITRCC")))
LOCAL _PictItem := ALLTRIM(X3PICTURE("B1_COD"))
LOCAL _PictSI   := ALLTRIM(X3PICTURE("W0__NUM"))
Local lRet := .T.
Local nOpcao := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0],aHeader[0]
PRIVATE MConta:=MTotal:=0, TPO_NUM:=SW2->W2_PO_NUM
PRIVATE cMarca := GetMark(), lInverte := .F.
PRIVATE nValEmb := 0
PRIVATE aElimina := {}, aNaoElimina := {}
PRIVATE lEliminaS := .F. //LRS - 23/10/2017
Private cMsgAuto  := ""

If Type("lPoAuto") == "U"
   lPoAuto:= .F.
EndIf

Begin Sequence

   IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"ANTES_ELIMINA"),)

   IF lEliminaS
      Return .F.
   ENDIF

   dbSelectArea(cAlias)
   IF EasyRecCount() == 0
      Return (.T.)
   EndIf

   If ! EICPO400PROG() //Verifica se é Pedido de Nacionalização
      Return .F.
   EndIf
   SW3->(DBSETORDER(7))
   IF !SW3->(DBSEEK(xFilial()+SW2->W2_PO_NUM))
      Help(" ",1,"E_NAOHAITE")
      Break
   ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If !POZERAGeraWork(@FileWork,CONSULTA)
      Break
   Endif

   IF MTotal = 0
      Help(" ",1,"E_NAOHAITE")
      Break
   ENDIF


   TB_Campos:={}
   bQtde_Emb:={||IF(Work->WKFLUXO=="7",TRANSFORM(Work->WKQTDE_EMB,_PictPrUn),;
                                    STR0010 )} //'   Anuencia    '

   bTotal:={||TRANSFORM(Work->WKQTDE*Work->WKPRECO,_PictPrUn)}

   AADD(Tb_Campos,{"WKFLAGZ",,})                                          // Flag Marca/Desmarca  TLM 09/05/2008
   AADD(Tb_Campos,{{||POZERAPESQ('CC')},,_LIT_R_CC })
   AADD(Tb_Campos,{"WKSI_NUM",,STR0011,_PictSI})                          // "No.SI"
   AADD(Tb_Campos,{"WKPOSICAO",,STR0012})                                 // "Posição"
   AADD(Tb_Campos,{"WKCOD_I" ,,STR0013,_PictItem})                        // "Item"
   AADD(Tb_Campos,{"WKPART_N",,STR0014})                                  // "Part Number"
   AADD(Tb_Campos,{{||IF(Work->WKFLUXO=='7',STR0015,STR0016)},,STR0017})  // "Nao"###"Sim"###"Anuencia"
   AADD(Tb_Campos,{"WKDESCR" ,,AVSX3("B1_DESC_"+cDESC_PO,AV_TITULO)})                                  // "Descricao em ###"
   AADD(Tb_Campos,{{||POZERAPESQ('FB')},,STR0019})                         // "Fabricante"

   IF lExiste_Midia .AND. !EMPTY(SW2->W2_VLMIDIA)
      AADD(Tb_Campos,{"WK_QTMIDIA",,AVSX3("B1_QTMIDIA",5),AVSX3("B1_QTMIDIA",6)})
      AADD(Tb_Campos,{"WK_VLTOTMI",,STR0021,AVSX3("W2_VLMIDIA",6)})       // "Vlr. Total Midia"
   ENDIF

   AADD(Tb_Campos,{"WKQTDE"  ,,STR0022,_PictQtde})                       // "Quantidade"

   IF AvFlags("EIC_EAI")//AWF - 25/06/2014
      AADD(Tb_Campos,{"WKUNI"  ,,AVSX3("W3_UM",AV_TITULO)})
   ELSE
      IF EICLOJA()
         AADD(Tb_Campos,{{||BUSCA_UM(Work->WKCOD_I+Work->WKFABR+Work->WKFORN,WORK->WKCC+WORK->WKSI_NUM,WORK->W3_FABLOJ,WORK->W3_FORLOJ)},,STR0020}) //"Uni" //OS:0142/02 SO.:0022/02 FCD
      ELSE
         AADD(Tb_Campos,{{||BUSCA_UM(Work->WKCOD_I+Work->WKFABR+Work->WKFORN,WORK->WKCC+WORK->WKSI_NUM,"","")},,STR0020}) //"Uni" //OS:0142/02 SO.:0022/02 FCD
      ENDIF
   ENDIF

   IF AvFlags("EIC_EAI")//AWF - 25/06/2014
      AADD(Tb_Campos,{"WKQTSEGUM",,AVSX3("W3_QTSEGUM",AV_TITULO),AVSX3("W3_QTSEGUM",6)})
      AADD(Tb_Campos,{"WKSEGUM"  ,,AVSX3("W3_SEGUM",AV_TITULO)})
   ENDIF
   AADD(Tb_Campos,{bQtde_Emb ,,STR0023})                                  // "Qtde Embarcada"
   If SW3->(FIELDPOS("W3_PESOL")) # 0 //CCH - 07/08/09 - Gravação do novo campo de Peso Líquido Unitário
      AADD(Tb_Campos,{"WKPESOL",,AVSX3("W3_PESOL",5),AVSX3("W3_PESOL",6)})
   EndIf
   AADD(Tb_Campos,{"WKSALDO_Q",,STR0024,AVSX3("W3_SALDO_Q",6)})            // "Saldo Qtde"
   AADD(Tb_Campos,{"WKPRECO"  ,,STR0025,_PictPrUn})                       // "Preço Unit"
   AADD(Tb_Campos,{bTotal,,STR0026})                                      // "Valor Total"
   AADD(Tb_Campos,{"WKDT_EMB" ,,STR0027})                                 // "Embarque"
   AADD(Tb_Campos,{"WKDT_ENTR",,STR0028})                                 // "Entrega"

   If lForeCast
      AADD(Tb_Campos,{{||IF(WK_FORECAS=="S",STR0029,STR0030)},,STR0031})  // "Sim"###"Nao"###"Forecast"
   Endif

   AADD(Tb_Campos,{{||SX5->(dbSeek(xFilial()+"Y2"+Work->WK_REG_TRI)),AllTrim(X5DESCRI())},,AVSX3("W3_REG_TRI")[5]})
   AADD(Tb_Campos,{"WK_REG_MIN",,OemToAnsi(STR0032)})                     // "Registro no Ministério / Orgão Público"
   AADD(Tb_Campos,{"WK_TEC"   ,,AVSX3("W3_TEC"   )[5]})
   AADD(Tb_Campos,{"WK_EX_NCM",,AVSX3("W3_EX_NCM")[5]})
   AADD(Tb_Campos,{"WK_EX_NBM",,AVSX3("W3_EX_NBM")[5]})

   //TRP- 01/06/09 - Campo Software para novo Tratamento de Mídia e Software
   If SW3->(FieldPos("W3_SOFTWAR")) # 0 .And. EasyGParam("MV_CONSOFT",, "N") $ cSim
      AADD(Tb_Campos,{{||IF(Work->WKSOFTWAR=='2',STR0015,STR0016)},,AVSX3("W3_SOFTWAR",5)})
   Endif

   If lCpoCtCust
      AADD(Tb_Campos,{"WKCTCUSTO",,AVSX3("W3_CTCUSTO",5),AVSX3("W3_CTCUSTO",6)})
   EndIf
   If lPesoBruto
      AADD(Tb_Campos,{"WKPSBRUTO",,AVSX3("W3_PESO_BR",5),AVSX3("W3_PESO_BR",6)})
   EndIf
   If AvFlags("RATEIO_DESP_PO_PLI")
      AADD(Tb_Campos,{"WKFRETE",,AVSX3("W3_FRETE",5)  ,AVSX3("W3_FRETE",6)})
      AADD(Tb_Campos,{"WKSEGUR",,AVSX3("W3_SEGURO",5) ,AVSX3("W3_SEGURO",6)})
      AADD(Tb_Campos,{"WKINLAN",,AVSX3("W3_INLAND",5) ,AVSX3("W3_INLAND",6)})
      AADD(Tb_Campos,{"WKDESCO",,AVSX3("W3_DESCONT",5),AVSX3("W3_DESCONT",6)})
      AADD(Tb_Campos,{"WKPACKI",,AVSX3("W3_PACKING",5),AVSX3("W3_PACKING",6)})
      If SW3->(FieldPos("W3_OUT_DES")) > 0
         AADD(Tb_Campos,{"WKOUTDE",,AVSX3("W3_OUT_DES",5),AVSX3("W3_OUT_DES",6)})
      EndIf
   EndIf
   TB_Campos:= AddCpoUser(TB_Campos,"SW3","2")

   FOR i := 1 TO SW2->(FCount())
      SW2->( M->&(FIELDNAME(i)) := FieldGet(i) )
   NEXT

   While .T.
      If !lPOAuto  // GFP - 26/08/2013
         oMainWnd:ReadClientCoords()
      EndIf

      DEFINE MSDIALOG oDlg TITLE STR0270+AllTrim(TRANSFORM(M->W2_PO_NUM,AVSX3("W2_PO_NUM",6))); //"Purchase Order - "
             FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
       	     OF oMainWnd PIXEL

      oEnCh:=MsMGet():New(cAlias,nReg,nOpc,,,,,{15,1,FINAL_ENCHOICE,COLUNA_FINAL},,3)

      dbSelectArea("Work")
      dbGoTop()

      oGet:=MsSelect():New("Work","WKFLAGZ",,TB_Campos,@lInverte,@cMarca,{FINAL_ENCHOICE+1,1,FINAL_SELECT,COLUNA_FINAL})
      oGet:bAval := {|| MarcaItem(cMarca) }

      //bOk := {|| If (MsgYesNo(STR0271), ( oDlg:End(),POZERASLDMANUT(.T.)), oDlg:End() )}
      //bOk := {|| If(MsgYesNo(STR0271), nOpcao := 1,), oDlg:End() }
      bOk := {|| nOpcao := 1, oDlg:End() }//TDF - 22/01/10
      oDlg:lMaximized:=.T.
	  oEnch:oBox:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	  oGet:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

      ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk,bCancel,,aButtons)) //LRL 12/04/04 - Alinhamento MDI. //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

      Exit
   Enddo

   If nOpcao == 1

      //FDR - 03/05/12
      aOrd := SaveOrd({"WORK"})

      WORK->(DBGOTOP())
      DO WHILE WORK->(!EOF())
         IF !EMPTY(WORK->WKFLAGZ)
            AADD(aElimina,{WORK->WKPOSICAO,If (SW3->(FIELDPOS("W3_SLD_ELI")) # 0,Work->WKSLD_ELI,0)})
            //LGS-17/10/2013 - Nopado de forma a permitir que seja feito eliminação de 100% de um item que não tenha sido embarcado.
            /*IF WORK->WKQTDE <> WORK->WKSALDO_Q
               AADD(aElimina,{WORK->WKPOSICAO,If (SW3->(FIELDPOS("W3_SLD_ELI")) # 0,Work->WKSLD_ELI,0)})
            ELSE
               AADD(aNaoElimina,{WORK->WKPOSICAO,If(SW3->(FIELDPOS("W3_SLD_ELI")) # 0,Work->WKSLD_ELI,0), WORK->WKCOD_I})
            ENDIF*/
         ENDIF
         WORK->(DBSKIP())
      ENDDO

      RestOrd(aOrd,.T.)

      IF !LEN(aElimina) > 0
         MsgInfo(STR0374+ chr(13)+CHR(10) +STR0375,STR0037)//*** STR0374-->"Não é permitido eliminar 100% do saldo *** ***STR0375-->Favor estornar o pedido." *** ,STR0037-->***"Atenção"***
         lRet := .F.
         BREAK
      ENDIF
      /*** TDF - 22/01/10 - TRATAMENTO PARA NÃO ELIMINAR SALDO QUANDO ADIANTAMENTO É MAIOR ***/

      nValEmb:= 0

      SW5->(DbSetOrder(3))
      SW3->(dbSetOrder(7))

      //TDF - 27/01/10 - Verifica o valor dos itens embarcados
      SW3->(dbSeek(xFilial("SW3")+SW2->W2_PO_NUM))
      If SW3->W3_FLUXO == "7"
         SW5->(DbSeek(xFilial("SW5")+SW3->W3_PO_NUM + SW3->W3_COD_I))
         While SW5->(!EOF()) .AND. SW5->W5_FILIAL == xFilial("SW5") .AND. SW5->W5_PO_NUM = SW3->W3_PO_NUM
            If SW5->W5_SEQ >= 1
               nValEmb += SW5->W5_QTDE * SW5->W5_PRECO
            EndIf
            SW5->(dbSkip())
         EndDo
      EndIf

      //TDF - 27/01/10 - Verifica o valor dos pagamentos antecipados liquidados
      nValPALiq := PO400VALZERA(1, SW2->W2_PO_NUM)

      If nValPALiq > nValEmb
         If !MsgYesNo( STR0311 +; //STR0311 - "Este P.O. possui pagamento antecipado liquidado maior que o valor"
                      STR0312 + ENTER +;  //STR0312 - " da quantidade embarcada."
                      STR0313) //STR0313 - "Deseja prosseguir com a eliminação do saldo?"
            lret := .F.
            Return lRet
         EndIf
      ElseIf(!MsgYesNo(STR0271))
         Break
      EndIf
      
      Begin Transaction      
         lRet := POZERASLDMANUT(.T.) //LRS - 04/10/2017
         If !lRet 
            DisarmTransaction()           
         EndIf 
      End Transaction
      If !lRet  
         If !Empty(cMsgAuto)
            Easyhelp(cMsgAuto, STR0002)   //Mensagem MostraErro de Retorno de erro ocasionado no compras pela Elim. de Residuos 
         Else
            Easyhelp(STR0425, STR0002)   //"Nao foi possível realizar a eliminação de saldo devido a erro ocorrido no módulo compras"
         EndIf
      EndIf    
   EndIf

End Sequence

If Select("Work") > 0
   /* wfs mar/2017 - adequação para uso do EECEraseArq(), com a passagem do 4º parâmetro */
   Work->(E_EraseArq(FileWork,,, SaveTempFiles()))
EndIf

DBSELECTAREA("SW2")

Return lRet

*----------------------------------------------------------------------------
Function POZERAGeraWork(FileWork)
*----------------------------------------------------------------------------
Local cAliasWkTmp
// aDBF_Stru eh private por causa dos rdmakes
PRIVATE aDBF_Stru:= { {"WKFLAGZ","C",2,0} ,;
                      {"WKCOD_I","C",  AVSX3("W3_COD_I",3),0}, {"WKDESCR","C",AVSX3("B1_VM_" + cDESC_PO,3),0}    ,;
                      {"WKFABR","C",   AVSX3("A2_COD",3),0}  , {"WKNOME_FAB","C",15,0} ,;
                      {"WKFORN","C",   AVSX3("A2_COD",3),0}  , {"WKNOME_FOR","C",15,0} ,;
                      {"WKREG","N",    AVSX3("W3_REG",3),0}  , {"WKFLUXO","C",1,0}     ,;
                      {"WKQTDE","N",   AVSX3("W3_QTDE",3),   AVSX3("W3_QTDE",4)},;
                      {"WKPRECO","N",  AVSX3("W3_PRECO",3),  AVSX3("W3_PRECO",4)},;
                      {"WKSALDO_Q","N",AVSX3("W3_SALDO_Q",3),AVSX3("W3_SALDO_Q",4)},;
                      {"WKCC","C",AVSX3("Y3_COD",3),0},;
                      {"WKPOSICAO","C",LEN(SW3->W3_POSICAO),0} , {"WKFLAGWIN","C",2,0}   ,;
                      {"WKSI_NUM","C" ,AVSX3("W0__NUM",3),0}   , {"WKPO_NUM","C",AvSx3("W2_PO_NUM", AV_TAMANHO),0}   ,;
                      {"WKDT_EMB","D",8,0}   , {"WKDT_ENTR","D",8,0}   ,;
                      {"WKDTENTR_S","D",8,0} , {"WKSEQ","N",2,0}       ,;
                      {"WKRECNO","N",7,0}    , {"WKFLAG","L",1,0}      ,;
                      {"WKQTDE_EMB","N",AVSX3("W3_QTDE",3),AVSX3("W3_QTDE",4)},;
                      {"WKPART_N","C",LEN(IF(SW3->(FieldPos("W3_PART_N")) # 0,SW3->W3_PART_N,SA5->A5_CODPRF)),0}   ,;
                      {"WKCCNOME","C",20,0}  , {"WK_REG_MIN","C",AVSX3("W3_REG_MIN",3),0} ,;
                      {"WK_ALTEROU","L",01,0}, {"WK_REG_TRI","C",01,0} ,;
                      {"WK_TEC"  ,"C",10,0}  , {"WK_EX_NCM", "C",LEN(SW3->W3_EX_NCM),0} ,;
                      {"WK_EX_NBM","C",LEN(SW3->W3_EX_NBM),0},;
                      {"WKPOSIT"  ,"C",4,0}}


EICAddWkLoja(aDBF_Stru, "W3_FABLOJ", "WKFABR")
EICAddWkLoja(aDBF_Stru, "W3_FORLOJ", "WKFORN")

If SW3->(FieldPos("W3_PESOL")) # 0 //CCH - 07/08/09 - Gravação do novo campo de Peso Líquido Unitário
   AADD(aDBF_Stru,{"WKPESOL","N",AVSX3("W3_PESOL",3),AVSX3("W3_PESOL",4)})
EndIf

If SW3->(FieldPos("W3_SLD_ELI")) # 0 //SVG - 24/02/2011 -
   AADD(aDBF_Stru,{"WKSLD_ELI","N",AVSX3("W3_SLD_ELI",3),AVSX3("W3_SLD_ELI",4)})
EndIf


IF lExiste_Midia
   AADD(aDBF_Stru,{"WK_QTMIDIA",AVSX3("B1_QTMIDIA",2),AVSX3("B1_QTMIDIA",3),AVSX3("B1_QTMIDIA",4)})
   AADD(aDBF_Stru,{"WK_VLTOTMI",AVSX3("W2_VLMIDIA",2),AVSX3("W2_VLMIDIA",3),AVSX3("W2_VLMIDIA",4)})
ENDIF

If lForeCast
   AADD(aDBF_Stru,{"WK_FORECAS","C",1,0})
Endif

//TRP- 01/06/09 - Campo Software para novo Tratamento de Mídia e Software
If SW3->(FieldPos("W3_SOFTWAR")) # 0 .And. EasyGParam("MV_CONSOFT",, "N") $ cSim
   AADD(aDBF_Stru,{"WKSOFTWAR",AVSX3("W3_SOFTWAR",2),AVSX3("W3_SOFTWAR",3),AVSX3("W3_SOFTWAR",4)})
Endif

If lCpoCtCust
   AADD(aDBF_Stru,{"WKCTCUSTO",AVSX3("W3_CTCUSTO",2),AVSX3("W3_CTCUSTO",3),AVSX3("W3_CTCUSTO",4)})
EndIf
If lPesoBruto                                                                                     //NCF - 25/08/2011 - Campo do Peso Bruto Unitário
   AADD(aDBF_Stru,{"WKPSBRUTO",AVSX3("W3_PESO_BR",2),AVSX3("W3_PESO_BR",3),AVSX3("W3_PESO_BR",4)})
EndIf
If AvFlags("RATEIO_DESP_PO_PLI")
   AADD(aDBF_Stru,{"WKFRETE",AVSX3("W3_FRETE",2)  ,AVSX3("W3_FRETE",3)  ,AVSX3("W3_FRETE",4)})
   AADD(aDBF_Stru,{"WKSEGUR",AVSX3("W3_SEGURO",2) ,AVSX3("W3_SEGURO",3) ,AVSX3("W3_SEGURO",4)})
   AADD(aDBF_Stru,{"WKINLAN",AVSX3("W3_INLAND",2) ,AVSX3("W3_INLAND",3) ,AVSX3("W3_INLAND",4)})
   AADD(aDBF_Stru,{"WKDESCO",AVSX3("W3_DESCONT",2),AVSX3("W3_DESCONT",3),AVSX3("W3_DESCONT",4)})
   AADD(aDBF_Stru,{"WKPACKI",AVSX3("W3_PACKING",2),AVSX3("W3_PACKING",3),AVSX3("W3_PACKING",4)})
   If SW3->(FieldPos("W3_OUT_DES")) > 0
      AADD(aDBF_Stru,{"WKOUTDE",AVSX3("W3_OUT_DES",2),AVSX3("W3_OUT_DES",3),AVSX3("W3_OUT_DES",4)})
   EndIf
EndIf
If AvFlags("EIC_EAI") //WFS 29/08/2014
   AAdd(aDBF_Stru, {"WKUNI"    , AvSx3("W3_UM", AV_TIPO)       , AvSx3("W3_UM", AV_TAMANHO)     , AvSx3("W3_UM", AV_DECIMAL)})
   AAdd(aDBF_Stru, {"WKSEGUM"  , AvSx3("W3_SEGUM", AV_TIPO)   , AvSx3("W3_SEGUM", AV_TAMANHO)  , AvSx3("W3_SEGUM", AV_DECIMAL)})
   AAdd(aDBF_Stru, {"WKQTSEGUM", AvSx3("W3_QTSEGUM", AV_TIPO), AvSx3("W3_QTSEGUM", AV_TAMANHO),AvSx3("W3_QTSEGUM", AV_DECIMAL)})
   AAdd(aDBF_Stru, {"WKFATOR"  , AvSx3("J5_COEF", AV_TIPO)    , AvSx3("J5_COEF", AV_TAMANHO)    , AvSx3("J5_COEF", AV_DECIMAL)})
   If SW0->(FieldPos("W0_REFER1")) > 0 //NCF - 26/09/2016
      AADD(aDBF_Stru,{"WKREFER1"  ,"C",AVSX3("W0_REFER1"   ,3),AVSX3("W0_REFER1",4)})
   EndIf
EndIf

//TRP-14/05/07
aOrd := SaveOrd("SX3",1)
SX3->(dbSeek("SW3"))

While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SW3"
      If SX3->X3_PROPRI=="U" .AND. Ascan(aDBF_Stru, {|x| AllTrim(x[1]) == AllTrim(SX3->X3_CAMPO)})==0 .AND. X3Uso(SX3->X3_USADO)
         aAdd(aDBF_Stru,{SX3->X3_CAMPO,AVSX3(SX3->X3_CAMPO,AV_TIPO),AVSX3(SX3->X3_CAMPO,AV_TAMANHO),AVSX3(SX3->X3_CAMPO,AV_DECIMAL)})
      EndIF
      SX3->(dbSkip())
   Enddo
RestOrd(aOrd)
SW5->(DbSetOrder(3))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho e indice                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aDBF_Stru,{"DBDELETE","L",1,0}) //THTS - 01/11/2017 - Este campo deve sempre ser o ultimo campo da Work
//FileWork := E_CriaTrab(,aDBF_Stru,"Work") //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados
If IsMemVar("lPOAuto") .And. lPOAuto
   cAliasWkTmp := GetNExtAlias()
   FileWork:=E_CriaTrab(,aDBF_Stru,cAliasWkTmp,,,, SaveTempFiles())
   (cAliasWkTmp)->(DbCloseArea())
   TETempReOpen(TeTempName(cAliasWkTmp),cAliasWkTmp,"Work")
Else
   FileWork:=E_CriaTrab(,aDBF_Stru,"Work")
EndIf

IF ! USED()
   Work->(E_EraseArq(FileWork))
   Help(" ",1,"E_NAOHAREA")
   RETURN .F.
ENDIF

IF EICLOJA()
   IndRegua("Work",FileWork+TEOrdBagExt(), "WKCC+WKSI_NUM+WKCOD_I+WKFABR+W3_FABLOJ+WKFORN+W3_FORLOJ+STR(WKREG,"+Alltrim(Str(AVSX3("W3_REG",3)))+",0)")
ELSE
   IndRegua("Work",FileWork+TEOrdBagExt(), "WKCC+WKSI_NUM+WKCOD_I+WKFABR+WKFORN+STR(WKREG,"+Alltrim(Str(AVSX3("W3_REG",3)))+",0)")
ENDIF

If ( Type("lPOAuto") == "U" .OR. !lPOAuto )
MsAguarde({||SW3->(POZERAWork({|msg|MsProcTxt(msg)}))},;
                                        STR0047) //"Pesquisa de Itens"

Else
   bExec:={||SW3->(POZERAWork())}
   Eval(bExec)
Endif


Return .T.


*----------------------------------------------------------------------------
Function POZERAWork(bMsg)
*----------------------------------------------------------------------------
LOCAL cKey_SA5 := " ", cKey_SB1 := " "
LOCAL cKey_SY3 := " ", cKey_SYG := " "

If Type("lPoAuto") == "U"
   lPoAuto:= .F.
EndIf

SA5->(DbSetOrder(3))
SW3->(dbSetOrder(7)) // FILIAL+PO+SEQ

WHILE .NOT. SW3->(EOF()) .AND. SW3->W3_PO_NUM = SW2->W2_PO_NUM .AND. SW3->W3_FILIAL == xFilial("SW3")

   If !lPOAuto
      Eval(bMsg,STR0048+ALLTRIM(W3_COD_I)) // "Processando Item "
   Endif
   MConta:= MConta + 01

   IF SW3->W3_SEQ <> 0
      EXIT
   ENDIF

   IF SW3->W3_FLUXO # "7" .AND. SW3->W3_SALDO_Q == 0
      DBSKIP() ; LOOP
   ENDIF

   IF SW3->W3_FLUXO == "7"
      nQtd_Gi:=nSld_Gi:=0
      Po420_IgPos("3")
      nSeq_SLi:= SW5->W5_PGI_NUM

      IF nSld_Gi == 0
         DBSKIP() ; LOOP
      ENDIF
   ENDIF

   DBSELECTAREA("Work")
   DBAPPEND()

   If cKey_SB1 != SW3->W3_COD_I
      cKey_SB1 := SW3->W3_COD_I
      SB1->(DBSEEK(xFilial()+SW3->W3_COD_I))
   Endif
   If cKey_SA5 != SW3->W3_COD_I+SW3->W3_FABR+SW3->W3_FORN
      cKey_SA5 := SW3->W3_COD_I+SW3->W3_FABR+SW3->W3_FORN
      //SA5->(DBSEEK(xFilial()+SW3->W3_COD_I+SW3->W3_FABR+SW3->W3_FORN))
      EICSFabFor(xFilial("SA5")+SW3->W3_COD_I+SW3->W3_FABR+SW3->W3_FORN, EICRetLoja("SW3","W3_FABLOJ"), EICRetLoja("SW3", "W3_FORLOJ"))
   Endif
   If cKey_SY3 != SW3->W3_CC
      cKey_SY3 := SW3->W3_CC
      SY3->(DbSeek(xFilial()+SW3->W3_CC))
   Endif
   If cKey_SYG != SW3->W3_FABR+SW3->W3_COD_I
      cKey_SYG := SW3->W3_FABR+SW3->W3_COD_I
      SYG->(DBSEEK(xFilial()+SW2->W2_IMPORT+SW3->W3_FABR+EICRetLoja("SW3","W3_FABLOJ")+SW3->W3_COD_I))
   Endif

   REPLACE WKCOD_I    WITH  SW3->W3_COD_I            ,;
           WKFABR     WITH  SW3->W3_FABR             ,;
           WKFORN     WITH  SW3->W3_FORN             ,;
           WKREG      WITH  SW3->W3_REG              ,;
           WKSEQ      WITH  SW3->W3_SEQ              ,;
           WKQTDE     WITH  SW3->W3_QTDE             ,;
           WKPRECO    WITH  SW3->W3_PRECO            ,;
           WKSALDO_Q  WITH  SW3->W3_SALDO_Q          ,;
           WKCC       WITH  SW3->W3_CC               ,;
           WKPOSICAO  WITH  SW3->W3_POSICAO          ,;
           WKSI_NUM   WITH  SW3->W3_SI_NUM           ,;
           WKDT_EMB   WITH  SW3->W3_DT_EMB           ,;
           WKDT_ENTR  WITH  SW3->W3_DT_ENTR          ,;
           WKRECNO    WITH  SW3->(RECNO())           ,;
           WKFLUXO    WITH  SW3->W3_FLUXO            ,;
           WKCCNOME   WITH  SY3->Y3_DESC             ,;
           WK_REG_MIN WITH  SYG->YG_REG_MIN
          //WKPART_N   WITH  ALLTRIM(SA5->A5_CODPRF)  ,;

           IF EICLOJA()
              REPLACE W3_FORLOJ WITH SW3->W3_FORLOJ
              REPLACE W3_FABLOJ WITH SW3->W3_FABLOJ
           ENDIF

  If SW3->(FIELDPOS("W3_PART_N")) # 0 //ASK 02/10/2007
      Work->WKPART_N := SW3->W3_PART_N
   Else
      Work->WKPART_N := ALLTRIM(SA5->A5_CODPRF)
   EndIf

   If SW3->(FIELDPOS("W3_PESOL")) # 0 //CCH - 07/08/09 - Gravação do novo campo de Peso Líquido Unitário
      Work->WKPESOL := SW3->W3_PESOL
   EndIf

   IF lExiste_Midia           .AND.;
      !EMPTY(SW2->W2_VLMIDIA) .AND.;
      SB1->B1_MIDIA $ cSim
      Work->WK_QTMIDIA := SB1->B1_QTMIDIA
      Work->WK_VLTOTMI := SB1->B1_QTMIDIA * SW2->W2_VLMIDIA
   ENDIF

   Work->WK_TEC    := Busca_NCM("SW3","NCM") //SW3->W3_TEC
   Work->WK_EX_NCM := Busca_NCM("SW3","EX_NCM")//SW3->W3_EX_NCM
   Work->WK_EX_NBM := Busca_NCM("SW3","EX_NBM")//SW3->W3_EX_NBM

   Work->WK_ALTEROU := .F. // Qdo True indica que o registro foi alterado.

   If lForeCast
      Work->WK_FORECAS := SW3->W3_FORECAS
   Endif

   Work->WK_REG_TRI := SW3->W3_REG_TRI

   IF SW3->W3_FLUXO == "7"
      Work->WKQTDE_EMB:= nQtd_Gi - nSld_Gi
      Work->WKSALDO_Q := nSld_Gi
   ENDIF

   If SW3->(FIELDPOS("W3_SLD_ELI")) # 0 //SVG - 24/02/2011 -
      Work->WKSLD_ELI := Work->WKSALDO_Q
   EndIf


   //TRP- 01/06/09 - Campo Software para novo Tratamento de Mídia e Software
   If SW3->(FieldPos("W3_SOFTWAR")) # 0 .And. EasyGParam("MV_CONSOFT",, "N") $ cSim
      Work->WKSOFTWAR:= SW3->W3_SOFTWAR
   Endif

   If lCpoCtCust                          //NCF - 22/06/2010
      Work->WKCTCUSTO := SW3->W3_CTCUSTO
   EndIf
   If lPesoBruto                         //NCF - 25/08/2011 - Campo do Peso Bruto Unitário
      Work->WKPSBRUTO := SW3->W3_PESO_BR
   EndIf
   If AvFlags("RATEIO_DESP_PO_PLI")
      Work->WKFRETE := SW3->W3_FRETE
      Work->WKSEGUR := SW3->W3_SEGURO
      Work->WKINLAN := SW3->W3_INLAND
      Work->WKDESCO := SW3->W3_DESCONT
      Work->WKPACKI := SW3->W3_PACKING
      If SW3->(FieldPos("W3_OUT_DES")) > 0
         Work->WKOUTDE := SW3->W3_OUT_DES
      EndIf
   EndIf

   E_ItFabFor(.T.,,"PO")

   MTotal+=( SW3->W3_QTDE * SW3->W3_PRECO )

   //TRP-14/05/07
   aOrd := SaveOrd("SX3",1)
   SX3->(dbSeek("SW3"))
   While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SW3"
      If SX3->X3_PROPRI=="U" .AND. X3Uso(SX3->X3_USADO).and. (SX3->X3_ARQUIVO)->(FieldPos(SX3->X3_CAMPO)) > 0
         Eval(FieldWBlock(SX3->X3_CAMPO, Select("Work")),  Eval(FieldWBlock(SX3->X3_CAMPO, Select("SW3"))))
      EndIF
      SX3->(dbSkip())
   Enddo
   RestOrd(aOrd)
   DBSELECTAREA("SW3")
   DBSKIP()
ENDDO

Return .T.

*-------------------*
Function POZERAPESQ(nOp)
*-------------------*
DBSELECTAREA("Work")
DO CASE
   CASE nOp == 'CC'
        RETURN WKCC+' '+WKCCNOME
   CASE nOp == 'FB'
        RETURN WKFABR + '-' + WKNOME_FAB
   CASE nOP == 'FO'
        RETURN WKFORN + '-' + WKNOME_FOR
ENDCASE
*------------------------------*
Function POZERASLDMANUT(lAlter)
*------------------------------*
Local lCompras := EasyGParam("MV_EASY",,"S") $ cSim
Local lFinanceiro:= EasyGParam("MV_EASYFIN",,"S") $ cSim //FDR - 12/11/12
Local cProduto, cPosicao, nSaldo, i, j, cNaoElimina := "",k
Local aOrdSYT //MCF - 07/04/2015
Local aRecSC7 := {} //MCF - 12/05/2016 - Parâmetro novo utilizado na função MA235PC
Local nTipoPC  := 1 //EJA - 14/07/2017
Local lReturn   := .T.
Local aLog      := {}
Local aPergOld  := {}
Local nx        := 1
Local aPergAux  := {}
Local aDataFonte :=  GetApoInfo("MATA235.PRX")  
Local cFilialSW3
Local cFilialSW5
Local cChaveSW3

Private cFile :=""
Private cMask := "Arquivos Texto (*.TXT) |*.txt|"
Private cMsg  := ''
Private lSair := .F. // SVG - 12/02/09 - Para tratamento em RDMAKE, validação.
PRIVATE lMT235G1 := EasyEntryPoint("MT235G1") //Variavél declarada para uso da rotina MA235PC, não utilizada no Easy.
Private aOrdSW3 := {}
Private nQtd_Gi:=nSld_Gi:=nTotalPO:= 0    //NCF - 01/02/2011
Private lMsHelpAuto     := .T. 
Private lAutoErrNoFile  := .T.
Private lMsErroAuto     := .F.

//Private lValEli := .T.

cMsg += Replicate("-",128)+CHR(13)+CHR(10)
cMsg += STR0314 +AllTrim(SW3->W3_PO_NUM)+ STR0315 +DtoC(dDatabase)+":"+chr(13)+CHR(10) //STR0314 - "Foram eliminados os seguintes saldos do Pedido " //Str 0315 - " no dia "
__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cMsg)

SW2->(dbSetOrder(1))
SW3->(dbSetOrder(8)) //W3_FILIAL, W3_PO_NUM, W3_POSICAO
SW5->(dbSetOrder(8)) //W5_FILIAL, W5_PGI_NUM, W5_PO_NUM, W5_POSICAO

//Work->(DbGoTop())
cFilialSW3 := xFilial("SW3")
cFilialSW5 := xFilial("SW5")
//While !(Work->(Eof()))
For i := 1 TO LEN(aElimina)

//IF Work->WKFLAGZ <> "  "
   // SVG - 08/05/2008
   If EasyEntryPoint("EICPO400")
      ExecBlock("EICPO400",.F.,.F.,"ANTESZERASLD")
   EndIf
   If lSair
      Return .T.
   EndIf
   aVolta := {}  //SSS -  REG 4.5 03/06/14
   SW3->(dbSeek(cFilialSW3+SW2->W2_PO_NUM + AvKey(aElimina[i][1],"W3_POSICAO")))

      cPosicao := SW3->W3_POSICAO
      cProduto := SW3->W3_COD_I
      nSaldo   := 0
      nSeq     := SW3->W3_SEQ

      If SW3->W3_SEQ == 0
         nSaldo := nSaldo + aElimina[i][2] //LRS - 10/05/2017 //SW3->W3_SALDO_Q

         /*Nopado por FDR - 11/04/12
         If lCompras
            lValEli := PO400ValEli(SW2->W2_FORN,Posicione("SA2",1,xFilial("SA2") + SW2->W2_FORN,"A2_LOJA"),SW2->W2_PO_SIGA)
         EndIf*/
         If lCompras .And. lAlter //Se integrado com SIGACOM chama a rotina da microsiga para Eliminar Resíduo.
            cPedido := SW2->W2_PO_SIGA
            cEmissao:= SW2->W2_PO_DT
            cForn   := SW2->W2_FORN
            cLoja   := Posicione("SA2",1,xFilial("SA2") + cForn,"A2_LOJA") //TDF - 16/03/10

            If EasyGParam("MV_EIC_PCO",,.F.) .And. SW2->W2_IMPCO == "1" .And. !EasyGParam("MV_PCOIMPO",,.T.) //MCF - 07/04/2015 - Quando Conta e ordem
               aOrdSYT :=SaveOrd("SYT")                                                           //passa o fornecedor do Importador.
               If SYT->(DBSEEK(xFilial("SYT")+SW2->W2_IMPORT))
                  cForn := SYT->YT_FORN
                  RestOrd(aOrdSYT,.T.)
               Endif
            Endif

            If SW2->W2_CONTR == '1' //Contrato-Sim
                nTipoPC  := 2 //Autorizacao de Entrega
            Else
                nTipoPC  := 1 //Pedido de Compras
            EndIf

            If ValType(aDataFonte) == "A"
               If aDataFonte[4] > CTOD("31/03/2020")
                  //Pergunte da eliminação de residuos do compras
                  Pergunte("MTA235",.F.,,,,, @aPergAux)
                  
                  //salva os Perguntes do compras para restaurar depois da execução
                  aPergOld := aClone(aPergAux)

                  mv_par01 :=  100
                  mv_par02 := cEmissao
                  mv_par03 := cEmissao
                  mv_par04 := cPedido
                  mv_par05 := cPedido
                  mv_par06 := cProduto
                  mv_par07 := cProduto
                  mv_par08 := nTipoPC
                  mv_par09 := cForn
                  mv_par10 := cForn
                  mv_par11 := CTOD("01/01/2000")
                  mv_par12 := CTOD("31/12/2200")           
                  mv_par13 :=  1
                  mv_par14 := cPosicao
                  mv_par15 := cPosicao
                  
                  //Chama a rotina para salvar os parâmetros
                  __SaveParam("MTA235", aPergAux)
                                          
                  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                  //³ mv_par01 - Percentual maximo                        ³
                  //³ mv_par02 - Data de Emissao de:                      ³
                  //³ mv_par03 - Data de Emissao ate:                     ³
                  //³ mv_par04 - Pedido de  :                             ³
                  //³ mv_par05 - Pedido ate :                             ³
                  //³ mv_par06 - Produto de :                             ³
                  //³ mv_par07 - Produto ate:                             ³
                  //³ mv_par08 - Elimina residuo por: 1-Pedido 2-Aut.Entr.³
                  //³                      3-Pedido e Autor. 4-Solicitacao³
                  //³ mv_par09 - Fornecedor de   :                        ³
                  //³ mv_par10 - Fornecedor ate  :                        ³
                  //³ mv_par11 - Data Entrega de :                        ³
                  //³ mv_par12 - Data Entrega ate:                        ³
                  //³ mv_par13 - Elimina SC com OP? 1-Sim  2-Nao          ³
                  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                  lReturn := .F.
                  MsExecAuto({|x| lReturn := MATA235(x)}, .T. )

                  If !lReturn .Or. lMSErroAuto
                     aLog     := GetAutoGrLog()               
                     for nx := 1 to len(aLog)
                        cMsgAuto += Alltrim(aLog[nx]) + ENTER
                     Next              
                  EndIf
               Else
                  MA235PC(100,nTipoPC,cEmissao,cEmissao,cPedido,cPedido,cProduto,cProduto,cForn,cForn,,,cPosicao,cPosicao,.F.,aRecSC7)
                  PosO1_It_Solic(SW3->W3_CC,SW3->W3_SI_NUM,SW3->W3_COD_I,SW3->W3_REG,0) // EJA - Eli Aguiar - Posiciona o SW1, de acordo com dados do SW3
                  MA235CP(100,cEmissao,cEmissao, SW1->W1_C3_NUM ,SW1->W1_C3_NUM,cProduto,cProduto,cForn,cForn,,,SW1->W1_POSIT,SW1->W1_POSIT) // EJA - 14/07/2017 - Elimina saldo do contrato de parceria                 
               EndIf   
            EndIf               
         EndIf

         If lReturn .And. lAlter .and. SW3->W3_FLUXO == "1"
            cDesc  := STR0316 +AllTrim(TRANSFORM(nSaldo, AVSX3("W3_SALDO_Q", 6)))+ STR0317 + cProduto//STR0316 - "Eliminado o saldo de: " //STR0317 -" do item: "
            Grava_Ocor(SW3->W3_PO_NUM, dDataBase, cDesc, "LI")
            cMsg += cDesc + chr(13)+ CHR(10)
            //FDR - 11/05/12
            For j := 1 TO LEN(aNaoElimina)
                cNaoElimina += aNaoElimina[j][3] + chr(13)+CHR(10)
            Next
            If !(Empty(cNaoElimina))
               cDesc := STR0374 + STR0317 + AllTrim(cNaoElimina) //STR0374-->"Não é permitido eliminar 100% do saldo " //STR0317 -" do item: "
               cMsg += cDesc + chr(13)+CHR(10)
            EndIf
   	        
		      //Zera o Saldo
            aAdd(aVolta,{"SW3",SW3->(RECNO()),SW3->W3_SLD_ELI,SW3->W3_SALDO_Q})  //SSS -  REG 4.5 04/06/14
		      RecLock("SW3", .F.)
		      IF SW3->(FIELDPOS("W3_SLD_ELI")) <> 0// SVG - 23/02/2011 -
               SW3->W3_SLD_ELI += aElimina[i][2]//Work->WKSLD_ELI
            ENDIF
            SW3->W3_SALDO_Q := 0
   		   SW3->(MsUnLock())
         EndIf
      EndIf

      SW3->(dbSkip()) //Passa para o SEQ = 1 para conseguir efetuar o seek
      cChaveSW3 := SW3->W3_PGI_NUM + SW3->W3_PO_NUM + SW3->W3_POSICAO//Guarda a chave para poder voltar a SW3 para o SEQ = 0
      SW3->(dbSkip(-1)) //Volta o SEQ para 0, pois ja guardou a chave com a PLI
      If lReturn .And. lAlter .and. SW3->W3_FLUXO == "7" .And. SW5->(dbSeek(cFilialSW5 + cChaveSW3)) //W5_FILIAL, W5_PGI_NUM, W5_PO_NUM, W5_POSICAO
         While !(SW5->(Eof())) .And. SW5->(W5_FILIAL+W5_PGI_NUM+W5_PO_NUM+W5_POSICAO) == cFilialSW5 + cChaveSW3
            nSaldo := nSaldo + aElimina[i][2] //LRS - 10/05/2017 //SW5->W5_SALDO_Q

            If SW5->W5_SEQ == 0 .and. nSaldo > 0
               cDesc := STR0316 +AllTrim(TRANSFORM(SW5->W5_SALDO_Q, AVSX3("W5_SALDO_Q", 6)))+ STR0317 +cProduto //STR0316 - "Eliminado o saldo de: " //STR0317 -" do item: "
               Grava_Ocor(SW5->W5_PO_NUM, dDataBase, cDesc, "PO")
               cMsg += cDesc + chr(13)+CHR(10) + chr(13)+CHR(10)
               //FDR - 11/05/12
               For j := 1 TO LEN(aNaoElimina)
                  cNaoElimina += aNaoElimina[j][3] + chr(13)+CHR(10)
               Next
               If !(Empty(cNaoElimina))
                  cDesc := STR0374 + STR0317 + AllTrim(cNaoElimina) //STR0374-->"Não é permitido eliminar 100% do saldo " //STR0317 -" do item: "
                  cMsg += cDesc + chr(13)+CHR(10)
               EndIf

               aAdd(aVolta,{"SW5",SW5->(RECNO()),0,SW5->W5_SALDO_Q} )   //SSS -  REG 4.5 04/06/14
               RecLock("SW5", .F.)
               SW5->W5_SALDO_Q := 0
               SW5->(MsUnLock())
               //Zera Saldo
               If SW3->(FIELDPOS("W3_SLD_ELI")) # 0
                  RecLock("SW3", .F.)
                  SW3->W3_SLD_ELI := aElimina[i][2]//Work->WKSLD_ELI
                  SW3->(MsUnLock())
               EndIf
            EndIf
            SW5->(dbSkip())
         EndDo
      EndIf   
//Endif
//Work->(DbSkip())
Next
//EndDo

///Envia
If lReturn .And. AvFlags("EIC_EAI") .And. !EICPO420(.T.,4,,"SW2",.F.,)  //SSS -  REG 4.5 03/06/14

    For k = 1 To Len( aVolta )  //SSS -  REG 4.5 03/06/14
        If aVolta[k,1] = "SW3"
           SW3->(DbGoto( aVolta[k,2] ) )
           RecLock("SW3", .F.)
           SW3->W3_SLD_ELI := aVolta[k,3]
           SW3->W3_SALDO_Q := aVolta[k,4]
           SW3->(MsUnLock())
        ElseIf aVolta[k,1] = "SW5"
           SW5->(DbGoto( aVolta[k,2] ) )
           RecLock("SW5", .F.)
           SW5->W5_SALDO_Q := aVolta[k,4]
           SW5->(MsUnLock())
        EndIf
   Next

   MsgStop("Acesse o Pedido " + AllTrim(SW2->W2_PO_NUM) + " para realização dos ajustes necessários.")
   lReturn := .F.
   Return lReturn
EndIf


//FDR - 11/04/12
If lReturn .And. lCompras .AND. LEN(aElimina) > 0
   MsgInfo(STR0373,STR0037) /*** Foram eliminados os resíduos do pedido de compras no SIGACOM" ***/ /*Atenção*/
EndIf

If lReturn
   //*** TDF - 21/01/10 - Elimina TODOS os títulos provisórios (PR), visto que nenhum item terá saldo neste ponto.
   Processa({|| DeleImpDesp(SW2->W2_PO_SIGA, "PR", "PO") })
   Processa({|| FI400ANT_PO(SW2->W2_PO_NUM) })
   //If nTotalPO > 0 //NCF - 01/02/2011 - Não gera título PR quando o saldo do PO é totalmente eliminado  // SVG - 21/02/11 - Nopado, pois é necessário gerar PR do saldo que esta embarcado sem Invoice.
   //FDR - 12/11/2012 - Gerar título PR somente integrado com financeiro
   If lFinanceiro
      Processa({|| FI400POS_PO(SW2->W2_PO_NUM, .F.) })
   EndIf
   //EndIf
   Processa({|| AVPOS_PO(SW2->W2_PO_NUM, "PO") })
   //***

   If EasyEntryPoint("EICPO400")      // TLM 08/05/2008
      ExecBlock("EICPO400",.F.,.F.,"SLDZERADO")
   EndIf

   AVGetSvLog(STR0318,cMsg)
EndIf

SW3->(dbSetOrder(1))
SW5->(dbSetOrder(1))

If aDataFonte[4] > CTOD("31/03/2020")
   //Restaura Pergunte do compras 
   Pergunte("MTA235",.F.,,,,, @aPergAux)

   For nX := 1 to Len(aPergOld)   
      &("MV_PAR"+PADL(nX, 2, '0')) := aPergOld[nX][8]
   Next nX

   //Chama a rotina para salvar os parâmetros
   __SaveParam("MTA235", aPergAux)
Endif

Return lReturn


/*------------------------------------------------------------------------------------
Funcao      : ConfMoeda
Parametros  : cMoeda - moeda a ser conferida se está com o cadastro correto para integração com SIGACOM
Retorno     : valor lógico, se a moeda informada foi aceita ou não
              Caso não esteja integrado com SIGACOM, sempre retorna .T.
Objetivos   : Validar a configuração da moeda para integração com SigaCom
Autor       : Anderson Soares Toledo
Data/Hora   : 14/01/09
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Static Function ConfMoeda(cMoeda)
   Local lRet
   Local aOrd

   If EasyGParam("MV_EASY") == "S"
      aOrd := SaveOrd("SYF")
      SYF->(dbSetOrder(1))
      If SYF->(dbSeek(xFilial("SYF")+cMoeda))
         If SYF->YF_MOEFAT <> 0
            lRet := .T.
         Else
            MSGINFO(STR0274) //Moeda referente no SIGACOM não informada, acerte o cadastro de moedas
            lRet := .F.
         EndIf
      Else
         MSGINFO(STR0274) //Moeda referente no SIGACOM não informada, acerte o cadastro de moedas
         lRet := .F.
      EndIf
      RestOrd(aOrd,.T.)
   Else
      lRet := .T.
   EndIf

   //FDR - 14/12/2011 - Validação dos campos de Fornecedor/Fabricante + Loja (Bloqueio)
   If !ExistCpo('SA2',AvKey(M->W2_FORN,"A2_COD")+If(EICLOJA(),AvKey(M->W2_FORLOJ,"A2_LOJA"),""))  // GFP - 30/09/2013
      MsgInfo(STR0371)//"O fornecedor utilizado neste processo encontra-se bloqueado para uso."
      lRet:= .F.
   Endif

return lRet
/*
Funcao      : PO400REL
Parametros  : Nenhum
Retorno     : nTotal - Total do PO
Objetivos   : Tratamento para gatilhos e inicializador padrão para os campos de totais da capa
Autor       : Saimon Vinicius Gava
Data/Hora   : 24/08/09
Revisao     :
Obs.        :
*/
Function PO400Rel(cCampo)
Local nTotal:= 0
Local nDesp := 0
Local cAlias := ""
Do Case
   Case cCampo == "TOTAL"
      If TYPE("M->W2_FREINC") != "U"
         cAlias := "M->"
      Else
         IF Type("Inclui") == "U" .or. (Type("Inclui") == "L" .And. !Inclui)
            cAlias := "SW2->"
         EndIf
      EndIf
      
      If !Empty(cAlias)
         IF &(cAlias+"W2_FREINC") $ cNao .AND. AvRetInco(&(cAlias+"W2_INCOTER"),"CONTEM_FRETE")  //M->W2_INCOTER $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP"
               nDesp += &(cAlias+"W2_FRETEIN")
         EndIf
         IF AvFlags("RATEIO_DESP_PO_PLI") .AND. &(cAlias+"W2_SEGINC") $ cNao .AND. AvRetInco(&(cAlias+"W2_INCOTER"),"CONTEM_SEG") //M->W2_INCOTER $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP"
            nDesp += &(cAlias+"W2_SEGURIN")
         EndIf
         nTotal := &(cAlias+"(W2_FOB_TOT+W2_INLAND+W2_PACKING+W2_OUT_DES-W2_DESCONT)") + nDesp
      EndIf
EndCase

Return nTotal


/*
Funcao      : CalcTotPO
Parametros  : Nenhum
Retorno     : nTotal - Total do PO
Objetivos   : Visualização dos totais do PO quando existir o campo de peso líquido unitário
Autor       : Nilson Cesar
Data/Hora   : 08/01/2010
Revisao     :
Obs.        :
*/
Function CalcTotPO()

Local oDlgTotPO, oPanel

Local bOk :=     {||oDlgTotPO:End()}
Local bCancel := {||oDlgTotPO:End()}

Local _PictPeso := "@E 99999,999,999,999.9999999"
Local _PictPO   := ALLTRIM(X3PICTURE("W2_PO_NUM"))

Local cTot        := STR0045              //'Total PO'
Local cNPO        := M->W2_PO_NUM         //"No. PO"
Local nPesoTot    := CriaVar("W2_PESO_B")
Local nPrecoTotPO := CriaVar("W3_PRECO")
Local cPictFob    := ALLTRIM(X3Picture("W2_FOB_TOT"))
Local cPictPeso   := ALLTRIM(X3Picture("W2_PESO_B"))

nPrecoTotPO := 0
nPesoTot := 0

Work->(DbGoTop())
While Work->(!EOF())
   If Work->WKFLAGWIN == cMarca
      nPrecoTotPO += Round(Work->WKQTDE * Work->WKPRECO ,2) //RRV - 29/11/2012 - Incluido arredondamento para que as informações não fiquem divergentes no Purchase Order. (Totais x Conferencia).
      nPesoTot    += Work->WKQTDE * Work->WKPESOL
   EndIf
   Work->(DbSkip())
EndDo
Work->(DbGoTop())

Define MsDialog oDlgTotPO Title STR0276 From 20,30 To 32,100 of oMainWnd

 oPanel:= TPanel():New(0,0, "", oDlgTotPO,,,,,,0,0)
 oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

 @05,20 Say STR0042             of oPanel Pixel  //No. PO
 @25,20 Say cTot + M->W2_MOEDA  of oPanel Pixel  //FOB Total
 @45,20 Say STR0277             of oPanel Pixel  //Peso Total

 @05,58 MsGet ocNPO    Var cNPO PICT _PictPO         Size 60,8 of oPanel Pixel //"No. PO"
 ocNPO:lReadOnly    := .T.
 @25,58 MsGet oTotPO   Var nPrecoTotPO PICT cPictFob Size 60,8 of oPanel Pixel //"Total PO"
 oTotPO:lReadOnly   := .T.
 @45,58 MsGet oPesoTot Var nPesoTot PICT cPictPeso   Size 60,8 of oPanel Pixel //"Peso Total"
 oPesoTot:lReadOnly := .T.

Activate MsDialog oDlgTotPO on init EnchoiceBar(oDlgTotPO,bOk,bCancel) Centered

Return Nil

/*
Funcao      : PO400VALZERA
Parametros  : nIndex = Index que sera utilizado para busca de PA liquidados.
              nCond  = Condição do Seek que sera utilizado para busca de PA liquidados.
Retorno     : nValor = Retorna o valor dos cambios de PA liquidados.
Objetivos   : Buscar valor total dos cambios de PA liquidados.
Autor       : Tamires Daglio Ferreira
Data/Hora   : 21/01/10
Revisao     :
Obs.        :
*/
Function PO400VALZERA(nIndex, cCond)
Local nValor := 0

//Validação de tipos de variaveis, para serem utilizadas no Seek.
If Valtype(nIndex) <> "N" .or. Valtype(cCond) <> "C"
   Alert(STR0319) //STR0319 "Validação para zerar o saldo do pedido não foi concluida com exito, favor contactar o administrador do sistema!"
   Return 0
EndIf

//Busca por cambios de PA liquidados.
SWB->(DBSETORDER(nIndex))

If SWB->(DBSEEK(xFilial() + cCond))
   While SWB->(!EOF()) .and. AVKEY(SWB->WB_HAWB,"W2_PO_NUM") == SW2->W2_PO_NUM
      If SWB->WB_PO_DI == 'A' .and. !EMPTY(SWB->WB_CA_DT)
         nValor += SWB->WB_PGTANT
      EndIf
   SWB->(DbSkip())
   EndDo
EndIf

Return nValor

/*
Função     : PO400VALPO
Parâmetros :
Retorno    : lTemMarcados
Objetivos  : Verifica se o P.O. tem item marcado na alteração, caso não tenha, não permite salvar o P.O.
Autor      : Diogo Felipe dos Santos
Data/Hora  : 19/04/10 - 12:20
Revisão    :
Obs.       :
*/
Function PO400VALPO()
Local lTemMarcado := .F.
Local nRecAtu := WORK->(Recno()) 
WORK->(DbGoTop())
While WORK->(!EOF())
   If !Empty(WORK->WKFLAG)
      lTemMarcado := .T.
   EndIf
   WORK->(DBSKIP())
EndDo
WORK->(DbGoTo(nRecAtu)/*DbGoTop()*/)
nOpcPonto := 1 //LRS - 11/08/2015
IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"APOS_MARCA_ITEM"),)
Return lTemMarcado


/*
Função    : MarcaItem()
Objetivos : efetua a marca/desmarca do item
Parametros: cMarca
Retorno   : -
Autor     : Allan Oliveira Monteiro
Data      : 06/07/2010 - 14:10

Static Function MarcaItem(cMarca)

Begin Sequence

   //verifica se o item está marcado
   cMarca  := IF(!Empty(Work->WKFLAGZ),Space(2),cMarca)

   Work->WKFLAGZ := cMarca

End Sequence

Return Nil
*/

*---------------------------------*
Static Function MarcaItem(cMarca)   //SSS -  REG 4.5 04/06/14
*---------------------------------*

If Empty(Work->WKFLAGZ)

   If !PO400TemNF()
      If !MsgYesNo("Não foi localizada a Nota Fiscal de recebimento deste item"+CHR(13)+"Deseja prosseguir com a marcação do item para eliminação "+CHR(13)+"do saldo ?")
         Return .f.
      EndIf
   EndIf

   Work->WKFLAGZ := cMarca

Else

   Work->WKFLAGZ := ""

EndIf

Return .t.
/*
Função    : MarcaTodos()
Objetivos : Marca/Desmarca todos os registros do MsSelect
Parametros: cMarca
Retorno   : -
Autor     : Allan Oliveira Monteiro
Revisão   :
Data      : 06/07/2010 - 14:19
*/
Static Function MarcaTodos(cMarca)   //SSS -  REG 4.5 04/06/14
   Local nRec

   Begin Sequence

      nRec    := Work->(RecNo())
      cMarca  := If(!Empty(Work->WKFLAGZ),Space(2),cMarca)

      lPergunta := .F.
      Work->(dbGotop())
      While Work->(!Eof())
         IF !PO400TemNF()
            lPergunta := .T.
            Exit
         EndIf
         Work->(DbSkip())
      EndDo
      If lPergunta .And. !MsgYesNo("Não foi localizada a Nota Fiscal de recebimento de um ou mais itens"+CHR(13)+"Deseja prosseguir com a marcação do(s) item(ns) para eliminação do saldo ?")
         Return .F.
      EndIf
      Work->(dbGotop())
      While Work->(!Eof())
         Work->WKFLAGZ := cMarca
         Work->(DbSkip())
      EndDo

   End Sequence

   Work->(DbGoTo(nRec))

Return Nil

*-----------------------*
Static Function PO400TemNF()  //SSS -  REG 4.5 04/06/14
*-----------------------*
Local aOrd   := SaveOrd({"SW3","SW7","SWN"})
Local aProcs := {}
Local lAchou,i

SW7->(DbSetOrder(2))
SW3->(DbGoto(Work->WKRECNO))
If SW7->(DbSeek(xFilial()+SW3->W3_PO_NUM))
   Do While SW7->(!Eof()) .And. SW7->W7_FILIAL = xFilial("SW7") .And. SW7->W7_PO_NUM = SW3->W3_PO_NUM
      If SW7->W7_POSICAO == SW3->W3_POSICAO //.AND. SW7->W7_PGI_NUM == SW3->W3_PGI_NUM
         If Ascan(aProcs,SW7->W7_HAWB) = 0
            Aadd(aProcs,SW7->W7_HAWB)
         EndIf
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

RestOrd(aOrd)

RETURN lAchou
/*
Funcao      : PO400RegPesq
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Vinculação de Regimes de tributação na fase PO
Autor       : Johann Wilfried Josefy
Data/Hora   : 21/10/09
Revisao     :
Obs.        :
*/
*-----------------------*
Function PO400RegPesq()
*-----------------------*
Local i, oEnch, bOldAdd, bOK, bCancel
Local oMsSel
Local cFileBackup := CriaTrab(,.F.)
Local cFileBkpWK := CriaTrab(,.F.)
Local nOpcReg := 0
Private aCamposEIJ := {}, aButtons := {}
Private oDlgEIJ, aMsEIJ := {}
Private cWk := ""

bOK 	:= {|| nOpcReg := 1, oDlgEIJ:End()}
bCancel	:= {|| nOpcReg := 0, oDlgEIJ:End()}

// Monta e carrega a GetDados com os dados da EIJ
aCamposEIJ := {'EIJ_REGTRI','EIJ_FUNREG','EIJ_MOTADI','EIJ_TACOII','EIJ_ACO_II','EIJ_ASSII' ,;
               'EIJ_EX_II' ,'EIJ_ATO_II','EIJ_ORG_II','EIJ_NRATII','EIJ_ANO_II',/*'EIJ_TPAII' ,*/'EIJ_ALI_II',;
               'EIJ_ALA_II','EIJ_ALR_II','EIJ_PR_II' ,/*'EIJ_CALCII','EIJ_ALU_II',*/'EIJ_REGIPI','EIJ_ASSIPI',;
               'EIJ_EX_IPI','EIJ_ATOIPI','EIJ_ORGIPI','EIJ_NROIPI','EIJ_ANOIPI','EIJ_TPAIPI','EIJ_ALAIPI',;
               'EIJ_ALRIPI','EIJ_ALUIPI','EIJ_QTUIPI','EIJ_REG_PC','EIJ_FUN_PC','EIJ_FRB_PC','EIJ_PRB_PC',;
               'EIJ_TPAPIS','EIJ_ALAPIS','EIJ_REDPIS','EIJ_ALUPIS','EIJ_QTUPIS','EIJ_TPACOF','EIJ_ALACOF',;
               'EIJ_ARDCOF','EIJ_ALCOFM','EIJ_ALPISM','EIJ_REDCOF','EIJ_ALUCOF','EIJ_QTUCOF','EIJ_OPERAC'}

IF EIJ->(FIELDPOS("EIJ_CALIPI")) <> 0
   AADD(aCamposEIJ, "EIJ_CALIPI")
ENDIF

aSX3 := SX3->( {IndexOrd(), Recno() } )
SX3->(DBSETORDER(2))

IF SX3->( DBSEEK("EIJ_ADICAO") )
   AADD( aMsEIJ, {"EIJ_ADICAO",,SX3->X3_TITULO,SX3->X3_PICTURE} )
ENDIF
For i:=1 to LEN(aCamposEIJ)
	IF SX3->( DBSEEK(aCamposEIJ[i]) )
   	   AADD( aMsEIJ, {aCamposEIJ[i],,SX3->X3_TITULO,SX3->X3_PICTURE} )
    ENDIF
Next

aMsEIJ[1,3] := "Grupo"	// Acerta o título do campo EIJ_ADICAO

IF nOpcAux # 2
   aButtons := { {'BPMSDOCI', {|| PO400RegManut('I'),oMsSel:oBrowse:Refresh()}, STR0005} ,; //STR0005 'Incluir'
     			 {'BPMSDOCA', {|| PO400RegManut('A'),oMsSel:oBrowse:Refresh()}, STR0006} ,; //STR0006 'Alterar'
	    		 {'BPMSDOCE', {|| PO400RegManut('E'),oMsSel:oBrowse:Refresh()}, STR0333} } // STR0333 'Excluir'
ELSE
   aButtons := { {'PESQUISA', {|| PO400RegManut('P')}, STR0003} }  //STR0003 'Pesquisar'
ENDIF

aTelaConf:=ACLONE(aTela)
aGetsConf:=ACLONE(aGets)
aGets:={}
aTela:={}

Work->(dbGoTop())
Work->(TETempBackup(cFileBkpWK))

WorkPO_EIJ->(dbGoTop())
WorkPO_EIJ->(TETempBackup(cFileBackup))

DEFINE MSDIALOG oDlgEIJ TITLE STR0334 FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM of oMainWnd PIXEL //STR0334 "Manutencao de Aliquotas"

	oMsSel := MsSelect():New("WorkPO_EIJ",,, aMsEIJ,,,{0,0,50,50},,, oDlgEIJ )
    oMsSel:bAval:={|| PO400RegManut(IF(nOpcAux=2,"P","A"))}

	oMsSel:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
	oMsSel:oBrowse:Refresh()

ACTIVATE MSDIALOG oDlgEIJ ON INIT EnchoiceBar(oDlgEIJ,bOk,bCancel,,aButtons)

If nOpcReg == 0
   AvZap("WorkPO_EIJ")
   WorkPO_EIJ->(TERestBackup(cFileBackup))
   WorkPO_EIJ->(dbGoTop())
   AvZap("Work")
   Work->(TERestBackup(cFileBkpWK))
   Work->(dbGoTop())
EndIf

E_EraseArq(cFileBackup)

aTela:=ACLONE(aTelaConf)
aGets:=ACLONE(aGetsConf)

Return

/*
Funcao      : PO400RegManut
Objetivos   : Manutenção dos Grupos de Regimes de tributação na fase PO
Autor       : Elizabete de Oliveira Brito
Data/Hora   : 04/01/10
Obs.        :
*/
*---------------------------------*
Static Function PO400RegManut(cOpc)
*---------------------------------*
Local oDlgEIJ_M, lOK := .F., lCancel := .F.
Local bOK 	  := {|| (lOk:=PO400RegVld(cOpc), IF(lOk,oDlgEIJ_M:End(),))}
Local bCancel := {|| (lCancel := .T., oDlgEIJ_M:End())}
Local i, cTitulo := '', oFont, oMark
Local cAlias := Alias(), aMSCamposEIJ
Local aBtns := {}, nRecEIJ := WorkPO_EIJ->WK_RECNO
Local nOpcAux := 4
Local oEnch
Local cFileBackup := CriaTrab(,.F.)
Private lTemAdicao:= .F., lDISimples := .F.
PRIVATE lWhenAutPis:=.F., lWhenAutCof:= .F.

IF cOpc $ 'AEP' .AND. WorkPO_EIJ->(EasyRecCount()) == 0
     Alert(STR0335) //STR0335 "Deve-se incluir um grupo primeiro."
     Return .F.
Endif

IF cOpc <> "P"
   aMSCamposEIJ := ACLONE( aCampos )
ELSE
   aMSCamposEIJ := ACLONE( Tb_Campos )
ENDIF

IF cOpc $ "AI"
	AADD( aMSCamposEIJ, NIL )
 	AINS( aMSCamposEIJ, 1 )
 	aMSCamposEIJ[1] := {"WKFLAGEIJ", , ""}
ENDIF

IF cOpc == 'I'
   IF EasyQryCount("SELECT * FROM " + TETempName("Work") + " WHERE WKGRUPORT = ' ' AND D_E_L_E_T_= ' ' " ) == 0
      Alert(STR0341) //STR0341 "Não há itens disponíveis para nova inclusão de grupo!"
      return .F.
   ENDIF

	For i := 1 to LEN(aCamposEIJ)
		&("M->"+aCamposEIJ[i]) := CRIAVAR(aCamposEIJ[i], .F.)
	Next
	cTitulo := STR0336 //STR0336 'Inclusão de Grupo'
    nNroGrupo:=1
    DO WHILE WorkPO_EIJ->(DBSEEK(STRZERO(nNroGrupo,3,0)))
       nNroGrupo++
    ENDDO

    M->EIJ_ADICAO:=STRZERO(nNroGrupo,3,0)
else
    For i := 1 to LEN(aCamposEIJ)
       &("M->"+aCamposEIJ[i]) := &('WorkPO_EIJ->'+aCamposEIJ[i])
    Next

    if cOpc == 'A'
	   cTitulo := STR0337 //STR0337 'Alteração de Grupo'
    ELseif cOpc == 'P'
       EIJ->(dbGoto(nRecEIJ))
       cTitulo := STR0338 //STR0338 'Visualização do Grupo'
       nOpcAux := 2
    ELseif cOpc == 'E'
       //EIJ->(dbGoto(nRecEIJ))
       cTitulo := STR0339 //STR0339 'Exclusão de Grupo'
    Endif
    If IsMemVar("lWhenAutPis") .And. M->EIJ_TPAPIS == "2"
      lWhenAutPis := .T.
    EndIf
    If IsMemVar("lWhenAutCof") .And. M->EIJ_TPACOF == "2"
      lWhenAutCof := .T.
    EndIf
    M->EIJ_ADICAO:=WorkPO_EIJ->EIJ_ADICAO
Endif

Work->(dbGoTop())
Work->(TETempBackup(cFileBackup))

DBSelectArea("Work")

// BAK - 26/04/2011 - Utilizou-se a variavel lRegTriPO com o objetivo de verificar se o campo WKGRUPORT existe
If lRegTriPO
   IF cOpc $ "EP" // Exclusão/Visualização
      SET FILTER TO Work->WKGRUPORT==M->EIJ_ADICAO
   ELSE
      SET FILTER TO (EMPTY(Work->WKGRUPORT) .OR. Work->WKGRUPORT==M->EIJ_ADICAO)
      aBtns := {{"RESPONSA", {|| PO400SelIT(oMark:oBrowse)}, STR0340}} //STR0340 "Marcar/Desmarcar"
   ENDIF
EndIf

DBGOTOP()

aSaveTela:=ACLONE(aTela)
aSaveGets:=ACLONE(aGets)
DO WHILE .T.
    aTela:={}
    aGets:={}

	DEFINE MSDIALOG oDlgEIJ_M TITLE cTitulo FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM of oDlgEIJ PIXEL

    	//Tamanho da tela
		nAltura  := int((oDlgEIJ:nBottom-oDlgEIJ:nTop)/2)
		nLargura := int((oDlgEIJ:nRight-oDlgEIJ:nLeft)/2)

		oEnch := MsMGet():New("EIJ",nRecEIJ, nOpcAux,,,, aCamposEIJ, {0,0,nAltura/2-10,nLargura},,0,,,, oDlgEIJ_M,,/*GFP*/  .T.,,,, /*lProperty*/ .T.)
		oEnch:oBox:Align := CONTROL_ALIGN_TOP

		oMark:=MsSelect():New("Work",IF(cOpc $ "AI","WKFLAGEIJ",""),,aMSCamposEIJ,lInverte,cMarca,{0,0,50,50})
		oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
		IF cOpc $ "IA"
  	       oMark:bAval:={|| PO400MarkIt(IF(EMPTY(Work->WKFLAGEIJ),"M","D"),,oMark:oBrowse:Refresh(),,.T.) } //MCF - 06/03/2015
        ELSE
           oMark:bAval:={|| .T.}
        ENDIF
	    oMark:oBrowse:Refresh()

	ACTIVATE MSDIALOG oDlgEIJ_M CENTER ON INIT EnchoiceBar(oDlgEIJ_M, bOK, bCancel,,aBtns)

	IF lOK
		IF cOpc $ "IA"
			IF cOpc == "I"
				WorkPO_EIJ->(DBAPPEND())
			ENDIF

			// *** GFP - 02/03/2011 :: 14:09 - Campos EIJ_TPAII deve ser sempre Ad Valorem
            M->EIJ_TPAII := "1"
            // *** Fim GFP

			AVReplace("M","WorkPO_EIJ")
			WorkPO_EIJ->WK_RECNO:=0

		ELSEIF cOpc == "E"
			Work->(dbGotop())
            DO While !Work->(eof())
               PO400MarkIt("D")
               Work->(dbSkip())
            ENDDO
            WorkPO_EIJ->(dbDelete())
		    WorkPO_EIJ->(dbGotop())
		ENDIF
		IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"MANUT_REG_TRIB"),)    // GFP - 01/07/2013 - Ponto de Entrada para manutenção de Regime de Trib. no PO.
		EXIT
	ELSEIF lCancel
      AvZap("Work")
      Work->(TERestBackup(cFileBackup))
      Work->(dbGoTop())
	   EXIT
	Endif
ENDDO

aTela:=ACLONE(aSaveTela)
aGets:=ACLONE(aSaveGets)

DBSelectArea("Work")
SET FILTER TO

DBSelectArea(cAlias)
Return

/*
Funcao      : PO400MarkIt
Objetivos   : Rotina para Marcar/Desmarcar os itens para os grupos de regime de tributação
Autor       : Elizabete de Oliveira Brito
Data/Hora   : 21/01/10
Obs.        :
*/
*---------------------------------------------------*
Static Function PO400MarkIt(cMark, lTodos, bBlocSel, lSelIt, lRegTrib) // MCF - 06/03/2015
*---------------------------------------------------*
Local aObrig, i, nPos, lObrig, nRecWk, lTudoObrig
Local cFilter, cOldFilter, lVariasSI, nQtdeAnt
Local nOrdW5,nRecW5
Local lExibe := .T.

//Local cFile  := GetSrvProfString ( "RootPath", "\undefined" ) + "\system\POMarkIt.txt"
Local cMsg	 := "Item(s) com contéudo incorreto:" + CRLF
Local cCampo := ""
DEFAULT lTodos := .F.
DEFAULT lSelIt := .F.
DEFAULT lRegTrib := .F.

If Type("lPoAuto") == "U"
   lPoAuto:= .F.
EndIf

If(Type("M->EIJ_ADICAO") == "U", M->EIJ_ADICAO := "", ) // GFP - 28/01/2013

aObrig := EasyGetObrig("SW3",.T.)

If lPedNac .And. cProg == "PN" .And. !lRegTrib // MCF - 06/03/2015 GFP - 26/03/2014 - No cenario de Pedido de Nacionalização, os itens não podem ser desmarcados.
   Return .F.
EndIf

IF lTodos
   If !lSelIt   // GFP - 28/01/2013
      IF(!EMPTY(Work->WKFLAGEIJ), cNewMarca := Space(2), cNewMarca := cMarca)
   Else
      IF(!EMPTY(Work->WKFLAGWIN), cNewMarca := Space(2), cNewMarca := cMarca)
   EndIf

   nRecWk := Work->(RecNo())

   lTudoObrig := .T.
   cFilter := "WKCC+WKSI_NUM==TCC+TSi_Num"//"WKCC+WKSI_NUM==TCC+IF(lSiCopia,cSiOri,TSi_Num)"

   lVariasSI := .F.
   Work->(dbGoTop(),dbEval({|| lVariasSI := WKSI_NUM <> TSi_Num /*IF(lSiCopia,cSiOri,TSi_Num)*/},,{|| !lVariasSI}))

   cOldFilter := Work->(dbFilter())
   DBSELECTAREA("Work")

   If lVariasSI .AND. !MsgYesNo("Deseja marcar/desmarcar os itens de todas as Solicitações de Importação associadas a este pedido? Caso contrario, serão marcados/desmarcados apenas os itens apresentados na tela.")
      Work->(dbSetFilter(&("{|| "+cFilter+"}"),cFilter))
   Else
      SET FILTER TO
   EndIf

   nOrdW5 := SW5->(IndexOrd())
   nRecW5 := SW5->(Recno())
   EW5->(DbSetOrder(2))

   Work->(dbGoTop())
   DO While !Work->(Eof())
      If !(lPoAuto) //FSM - 17/05/2012
         IncProc("Des/Marcando Item: "+Work->WKCOD_I)
      EndIf

      If Empty(cNewMarca) .AND. Work->WKQTDE_EMB # 0  // GFP - 09/01/2014 - Sistema não deve desmarcar itens que já estão embarcados.
         WORK->(DBSKIP())
         LOOP
      EndIf

      // MFR 14/09/2021 OSSME-6182
      if  (Work->WKFLAG .And. empty(cNewMarca) .And. EW5->(dbSeek(xFilial("EW5")+Work->WKPO_NUM + Work->WKPOSICAO)))  
           if lExibe   
              EasyHelp(STR0433,STR0002) //"Somente serão desmarcados os itens sem inoivce antecipada"
              lExibe:=.f.
           EndIf
           WORK->(DBSKIP())
           LOOP
      EndIf

      If !lSelIt   // GFP - 28/01/2013
         // BAK - 26/04/2011 - Utilizou-se a variavel lRegTriPO com o objetivo de verificar se o campo WKGRUPORT existe
         IF lRegTriPO .And. !EMPTY(Work->WKGRUPORT) .AND. Work->WKGRUPORT # M->EIJ_ADICAO
            WORK->(DBSKIP())
            LOOP
         ENDIF

         IF IF(bBlocSel = NIL , Empty(cNewMarca) .AND. !EMPTY(Work->WKFLAGEIJ), !EVAL(bBlocSel) )

            Work->WKFLAGEIJ := ""

            // BAK - 26/04/2011 - Utilizou-se a variavel lRegTriPO com o objetivo de verificar se o campo WKGRUPORT existe
            If lRegTriPO
               Work->WKGRUPORT := ""
            EndIf

            Work->WK_ALTEROU := .T.

         ELSEIF IF( bBlocSel = NIL , !Empty(cNewMarca) .AND. EMPTY(Work->WKFLAGEIJ), EVAL(bBlocSel) )

            Work->WKFLAGEIJ := cMarca

            // BAK - 26/04/2011 - Utilizou-se a variavel lRegTriPO com o objetivo de verificar se o campo WKGRUPORT existe
            If lRegTriPO
               Work->WKGRUPORT := M->EIJ_ADICAO
            EndIf
            Work->WK_ALTEROU := .T.

         ENDIF
      Else

         lObrig := .T.
         If !Empty(cNewMarca)
            For i := 1 To Len(aObrig)
               If (nPos := aScan(aCorrespW3,{|x| x[1] == Upper(AllTrim(aObrig[i]))})) > 0 .And. aObrig[i] <> "W3_SLD_ELI"  // GCC - 21/06/2013 - Retirado campo Elimina Saldo do array de campos obrigatorios, pois sempre apresenta valor 0.
                  lFieldPos := Work->(FieldPos(aCorrespW3[nPos][2])) > 0
                  If lFieldPos .AND. Empty(Work->(FieldGet(FieldPos(aCorrespW3[nPos][2]))))
                     lObrig     := .F.
                     lTudoObrig := .F.
                     cCampo     := AvSx3(aObrig[i], AV_TITULO)
                     cMsgAdicional:=""
                     EXIT
                  EndIf
                  If lFieldPos .And. Alltrim(aObrig[i]) == "W3_DT_EMB" .And. Work->&(aCorrespW3[nPos][2]) < M->W2_PO_DT
                     lObrig     := .F.
                     lTudoObrig := .F.
                     cCampo     := AvSx3(aObrig[i], AV_TITULO)
                     cMsgAdicional := STR0434//"Data de embarque deve ser maior que a data do P.O."
                     EXIT
                  EndIf
               EndIf
            Next i
         EndIf


         /*If lObrig
            Work->WKFLAGWIN  := cNewMarca
            Work->WKFLAG     := !Empty(cNewMarca)
            Work->WK_ALTEROU := .T.
         EndIf*/

         // GCC - 18/06/2013 - Atualização do campo Saldo Qtde para que o Marca / Desmarca funcione corretamente.
     	   If lObrig
            Work->WKFLAGWIN  := cNewMarca
            Work->WKFLAG     := !Empty(cNewMarca)
            Work->WK_ALTEROU := .T.
            If lCopiaPO
               nQtdeAnt        := If( !Empty(cNewMarca) , 0 , Work->WKQTDE )
	   	      //Work->WKQTDE    := If( !lVariasSI, Work->WKSEM_PO , Work->WKQTDE )
			      Work->WKSALDO_Q := Work->WKSEM_PO
			      Work->WKSEM_PO  := nQtdeAnt
            Else
	            If Work->WKFLUXO == "1"
	   		      Work->WKSALDO_Q := (Work->WKQTDE - Work->WKQTDE_LI)
			      ElseIf Work->WKFLUXO == "7"
			         Work->WKSALDO_Q := (Work->WKQTDE - Work->WKQTDE_EMB)
			      Endif
	         EndIf
	      Else
			   cMsg += "Item " + Alltrim(Work->WKCOD_I) + " / Posição " + Alltrim(Work->WKPOSIT) + " esta com o campo " + cCampo + " incorreto." + CRLF + cMsgAdicional + CRLF
		   EndIf
         cMsgAdicional := ""
      EndIf
      Work->(dbSkip())
   ENDDO
   //Work->(dbGoTop())

   SW5->(DbSetOrder(nOrdW5))
   SW5->(DbGoTo(nRecW5))

   Work->(dbGoTo(nRecWk))

   If !lTudoObrig
      EECView(cMsg,STR0002)  // GFP - 13/05/2014
      //MemoWrite(cFile,cMsg)
      //EasyHelp(STR0386,STR0002)  // "Existem itens não marcados pois há campos obrigatórios não preenchidos. Favor verificar o arquivo POMarkIt na pasta system!"  ### "Aviso"
   EndIf

   If Empty(cOldFilter)
      Work->(dbClearFilter())
   Else
      Work->(dbSetFilter(&("{|| "+cOldFilter+"}"),cOldFilter))
   EndIf

   // BAK - 26/04/2011 - Utilizou-se a variavel lRegTriPO com o objetivo de verificar se o campo WKGRUPORT existe
   If lRegTriPO
      SET FILTER TO (EMPTY(Work->WKGRUPORT) .OR. Work->WKGRUPORT==M->EIJ_ADICAO)
   EndIf

ELSEIF cMark == "D"
   Work->WKFLAGEIJ := ""

   // BAK - 26/04/2011 - Utilizou-se a variavel lRegTriPO com o objetivo de verificar se o campo WKGRUPORT existe
   If lRegTriPO
   Work->WKGRUPORT := ""
   EndIf

   Work->WK_ALTEROU := .T.
ELSE
   Work->WKFLAGEIJ := cMarca

   // BAK - 26/04/2011 - Utilizou-se a variavel lRegTriPO com o objetivo de verificar se o campo WKGRUPORT existe
   If lRegTriPO
      Work->WKGRUPORT := M->EIJ_ADICAO
   EndIf

   Work->WK_ALTEROU := .T.
ENDIF

If(AvFlags("RATEIO_DESP_PO_PLI"),PO400RatFrSg(),)
RETURN .T.


/*
Funcao      : PO400RegVld
Objetivos   : Rotina para validação dos dados do grupo de regime de tributação
Autor       : Elizabete de Oliveira Brito
Data/Hora   : 21/01/10
Obs.        :
*/
*--------------------------------*
Static Function PO400RegVld(cOpc)
*--------------------------------*
LOCAL cMsg := "", lReturn := .T., nRecWork := Work->(recno()), lMarkIt := .F.

IF cOpc = "E"
   IF !MSGYESNO(STR0342, "Atenção") //STR0342 "Confirma a exclusão do grupo de regime de tributação?"
      lReturn := .F.
   ENDIF
ELSEIF cOpc $ "AI"
   IF EMPTY(M->EIJ_REGTRI)
      cMsg += STR0343 + CHR(13) + CHR(10) //STR0343 "Regime de tributação do II não informado!"
   ENDIF
   IF EMPTY(M->EIJ_REGIPI)
      cMsg += STR0344 + CHR(13) + CHR(10) //STR0344 "Regime de tributação do IPI não informado!"
   ENDIF
   IF EMPTY(M->EIJ_REG_PC)
      cMsg += STR0345 + CHR(13) + CHR(10) // STR0345 "Regime de tributação do PIS/COFINS não informado!"
   ENDIF

   Work->(dbGotop())
   DO While !Work->(eof())
      IF !EMPTY(Work->WKFLAGEIJ)
         lMarkIt := .T.
         EXIT
      ENDIF
      Work->(dbSkip())
   ENDDO
   Work->(dbGoto(nRecWork))
   IF !lMarkit
      cMsg += STR0346 + CHR(13) + CHR(10) //STR0346 "Atencão! Nenhum item foi selecionado para este grupo!"
   ENDIF

   IF !EMPTY(cMsg)
      Alert(cMsg)
      lReturn := .F.
   ENDIF
ENDIF
RETURN lReturn


/*
Funcao      : PO400SelIt
Objetivos   : Rotina que apresentar os filtros para selecão dos itens para o grupo de regime de tributação
Autor       : Elizabete de Oliveira Brito
Data/Hora   : 02/02/10
Obs.        :
*/
*-------------------------*
Function PO400SelIT(oBrw)
*-------------------------*
LOCAL oDlg, nSelOp, bBlocSel, nRegWork := Work->(Recno())
Private aOpCombo:={"NCM+EX","Atual","Todos"}
Private cOpCombo:=aOpCombo[LEN(aOpCombo)],aEscolha:={}, cEscolha:="Todos", oEscolha
PRIVATE aNcm:={}, cNcm, oNCM, nOpRad := 3

Work->(DBGOTOP())
DO WHILE Work->(!EOF())
   IF EMPTY(Work->WKFLAGWIN)
      Work->(DBSKIP())
      LOOP
   ENDIF
   // MFR 03/04/2020 OSSME-3912
   IF ASCAN( aNcm, Work->WK_TEC + Work->WK_EX_NCM) == 0
      AADD ( aNcm, Work->WK_TEC + Work->WK_EX_NCM)
      cNcm:=aNcm[1]
   ENDIF
   Work->(DBSKIP())
ENDDO

Work->(dbGoto(nRegWork))

Begin Sequence

   nSelOp := 0
   DEFINE MSDIALOG oDlgSel TITLE STR0347 FROM 091,232 TO 105,300 Of oMainWnd //STR0347 "Marcar/Desmarcar por Selecao"
   oPanel:= TPanel():New(0, 0, "", oDlgSel,, .F., .F.,,, 40, 130)
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      @ 17,10 SAY STR0348 OF oPanel PIXEL //STR0348 "Filtro"
      @ 17,25 COMBOBOX oOpCombo VAR cOpCombo ITEMS aOpCombo SIZE 75,18 ON CHANGE(PO400ValCombo()) OF oPanel PIXEL

      @ 17,120 SAY STR0349 OF oPanel PIXEL //STR0349 "Escolha"
      @ 17,140 COMBOBOX oEscolha VAR cEscolha ITEMS aEscolha SIZE 75,18 OF oPanel PIXEL
      If Empty(aEscolha)
         PO400ValCombo()
      EndIf
   ACTIVATE MSDIALOG oDlgSel ON INIT ;
           EnchoiceBar(oDlgSel,{|| nSelOp:=1, oDlgSel:End()}, {|| nSelOp:=0, oDlgSel:End()}) CENTERED

   IF nSelOp == 1
      IF nOpRad <> 0
         IF nOpRad == 1
            //MFR 04/03/2020 OSSME-3912
            bBlocSel := {|| RTRIM(Work->WK_TEC + Work->WK_EX_NCM) == RTRIM(cEscolha)}
         ELSEIF nOpRad == 2
            cEscolha := Work->(recno())
            bBlocSel := {|| Work->(recno()) == cEscolha }
         ENDIF

         Processa( {|| PO400MarkIt("M",.T.,bBlocSel,,.T.) } ) //MCF - 06/03/2015
      ENDIF
   ENDIF

End Sequence

Work->(dbGoTo(nRegWork))

IF oBrw # NIL
   oBrw:Refresh()
   oBrw:Reset()
ENDIF

Return NIL

/*
Funcao      : PO400ValCombo
Autor       : Elizabete de Oliveira Brito
Data/Hora   : 02/02/10
*/
*------------------------------*
Function PO400ValCombo()
*------------------------------*
IF cOpCombo = "NCM"
   nOpRad:=1
   oEscolha:ENABLE()
   oEscolha:AITEMS:=ACLONE(aNCM)
ELSE
   IF cOpCombo = STR0350 //STR0350 "Atual"
      oEscolha:AITEMS:={STR0350} //STR0350 "Atual"
      nOpRad:=2
   ELSE
      oEscolha:AITEMS:={STR0351} //STR0351 "Todos"
      nOpRad:=3
   ENDIF
   oEscolha:DISABLE()
ENDIF
RETURN .T.
/*
Funcao     : NA400Prorrog()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Prorrogar a data de vencimento da DA
Autor      : Saimon Vinicius Gava - SVG -
Data/Hora  : 18/05/2011 - 17:11:25
*/
*---------------------------*
Function PO400Prorrog()
*---------------------------*
Local lProrrog := .F.
Local cDtPO
Local cDataVecDA  := SW2->W2_VENCDA
Local cNewDtVecDA := SW2->W2_VENCDA +EasyGParam("MV_VENCDA",,365)
SW6->(DbSeek(xFilial("SW6")+SW2->W2_HAWB_DA))
cDtPO:=SW6->W6_DT_DTA+EasyGParam("MV_VENCDA",,365)+EasyGParam("MV_VENCDA",,365)
If !cDataVecDA < dDataBase
   Alert(STR0288)//""DA não esta vencida.""
   Return nil
EndIf
If cNewDtVecDA > cDtPO
   MsgInfo(STR0284) //"Data de Vencimento da DA ja foi prorrogada, não é possivel prorrogar novamente."
   Return nil
EndIf
If MsgYesNo(STR0283)//"Deseja Prorrogar a data de vencimento da DA ?"
   lProrrog :=.T.
EndIf
If lProrrog
   RecLock("SW2",.F.)
   SW2->W2_VENCDA := cNewDtVecDA
   SW2->(MSUNLOCK())
   MsgInfo(STR0285+ENTER+ STR0286 +DtoC(cDataVecDA) +STR0287+DtoC(SW2->W2_VENCDA) ) //"Data de Vencimento da DA prorrogada." "De "##/##/#### " para "##/##/####
EndIf
Return nil
/*
Função    : ChkAltDesp()
Objetivos : Chequa caso há alguma alteração nos campos de despesa da capa do PO, frete, packing, outras despesas,
            desconto e inland.
Parametros:
Retorno   : .T. - Caso tenha sido feita alguma alteração em um destes campos
            .F. - Caso não tenha nenhuma alteração
Autor     : Ivo Santana Santos
Revisão   :
Data      : 24/02/11 - 11:00
*/
Static Function ChkAltDesp()

Local lRet := .F.

      Do Case
         Case M->W2_INLAND != SW2->W2_INLAND
            lRet := .T.
         Case M->W2_DESCONT != SW2->W2_DESCONT
            lRet := .T.
         Case M->W2_PACKING != SW2->W2_PACKING
            lRet := .T.
         Case M->W2_OUT_DES != SW2->W2_OUT_DES
            lRet := .T.
         Case M->W2_FRETEIN != SW2->W2_FRETEIN
            lRet := .T.
         Case M->W2_SEGURIN != SW2->W2_SEGURIN   
            lRet := .T.
      EndCase

Return lRet

/*
Função    : ValidOpePO()
Objetivos : Executa regra de Operação Especial, caso a operação nao ocorrer de forma devida efetua o retorno da transação
Parametros:
Retorno   : .T. - Caso tenha ocorrido a operação com sucesso
            .F. - Caso não tenha a operação com sucesso
Autor     : Allan Oliveira Monteiro
Revisão   :
Data      : 08/04/2011
*/

Static Function ValidOpePO(cParam)
Local lRet := .T.
Private lPE := .T.

Begin Sequence

    IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"ANTES_SALVAR"),) //LRS - 23/10/2017

    IF !lPE
       lRet := .F.
       Break
    EndIF

   //Verifica se o campo da operação existe
   If !lOperacaoEsp
      Break
   EndIf

   DO CASE

      CASE cParam == "BTN_MK_IT" //Operação especial no botao OK do item do PO
       
         //Verifica se o codigo da operação está preenchido na work, se estiver efetua o estorno
         If !EMPTY(Work->W3_CODOPE)
            lRet := oOperacao:InitOperacao(Work->W3_CODOPE, "SW3", {{"SW3","Work"},{"SW2","SW2"}}    , .F.,.T.,cParam)//Estorno
            If lRet
               Work->W3_CODOPE := ""
               Work->W3_DESOPE := ""
            EndIf
         EndIf

         If lRet .And. !EMPTY(M->W3_CODOPE)
            lRet := oOperacao:InitOperacao(M->W3_CODOPE   , "SW3", {{"SW3","M"},{"SW2","M"}}, .T.,.T.,cParam)//Inclusão
         EndIf

      CASE cParam == "MK_IT_PO" //Operação especial na ação Marca/Desmarc. item do PO

         If !EMPTY(Work->W3_CODOPE) .And. !Work->WKFLAG
            If oOperacao:InitOperacao(Work->W3_CODOPE, "SW3", {{"SW3","Work"},{"SW2","SW2"}}, .F.,.T.,cParam)//Estorno
               Work->W3_CODOPE := ""
               Work->W3_DESOPE := ""
            Else
               lRet := .F.
               Break
            EndIf
         EndIf

         If !EMPTY(Work->W3_CODOPE) .And. Work->WKFLAG
            lRet := oOperacao:InitOperacao(Work->W3_CODOPE, "SW3", {{"SW3","Work"},{"SW2","SW2"}}, .F.,.T.,cParam)//Inclusão
         EndIf

      CASE cParam == "DESMARCA_IT_PO" //Operação especial na ação Marca/Desmarc. item do PO

         IF !Empty(Work->W3_CODOPE)
            If oOperacao:InitOperacao(Work->W3_CODOPE, "SW3", {{"SW3","Work"},{"SW2","SW2"}}    , .F.,.T.,cParam)//Estorno
               Work->W3_CODOPE := ""
               Work->W3_DESOPE := ""
            Else
               lRet := .F.
               Break
            EndIf
         ENDIF

      CASE cParam == "BTN_MK_TDS_ITS_PO" //Operacao Especial na ação marca todos PO

         If !EMPTY(Work->W3_CODOPE) .And. Work->WKFLAG
            lRet := oOperacao:InitOperacao(Work->W3_CODOPE, "SW3", {{"SW3","Work"},{"SW2","SW2"}}    , .F.,.T.,cParam)//Inclusão
         EndIf

         If !EMPTY(Work->W3_CODOPE) .And. !Work->WKFLAG
            lRet := oOperacao:InitOperacao(Work->W3_CODOPE, "SW3", {{"SW3","Work"},{"SW2","M"}}    , .T.,.T.,cParam)//Inclusão
         EndIf


   ENDCASE


End Sequence

Return lRet

/*
Função    : MarkItemAuto()
Objetivos : Marcar/Desmarcar item no ExecAuto
Parametros: nOpcAuto
			lAutInlcui
			lAutAltera
			lAutDeleta
		    aAux
Retorno   : Nil
Autor     : Thiago Rinaldi Pinto
Revisão   :
Data      : 18/05/2011
*/
*---------------------------------------------------------------------------*
Static Function MarkItemAuto(nOpcAuto,lAutInclui,lAutAltera,lAutDeleta,aAux )
*---------------------------------------------------------------------------*
Local bAvalAuto
Local lRet:= .T.
Private lMarkItem:= .T.

   If nOpcAuto == 4  //Alteracao Automatica de Pedido
      //RMD - 06/01/16 - Informa a chave correta, pois o índice 1 da work possui o campo POSIT, destinado somente a visualização de registros.
      If EasySeekAuto("WORK", aAux, 1, aCorrespW3, Nil, "WKCC+WKSI_NUM+WKCOD_I+STR(WKREG,4,0)")
         If lAutInclui  //Inclusao de Item em uma alteracao
            bAvalAuto:= {||lMarkItem:= P_Te_3(aAux)}
            Eval(bAvalAuto)
         Endif

         If lAutAltera  //Alteracao de Item em uma alteracao
            bAvalAuto:= {||lMarkItem:= P_Te_3(aAux)}
            Eval(bAvalAuto)  //Desmarcar
            Eval(bAvalAuto)  //Marcar
         Endif

         If lAutDeleta  //Exclusao de Item em uma alteracao
            bAvalAuto:= {||lMarkItem:= P_Te_3(aAux)}
            Eval(bAvalAuto)
         Endif
      EndIf
   Else  //Inclusao Automatica de Pedido
      /*
      	RMD - 06/01/16 - Inclui posicionamento pois a função espera que a work esteja posicionada no item marcado, e a função de
				      	carregamento da WORK não retorna posicionada no último item incluído, e sim no último item do SW1 (ordenado por W1_POSICAO).
      */
      If EasySeekAuto("WORK", aAux, 1, aCorrespW3 , Nil, "WKCC+WKSI_NUM+WKCOD_I+STR(WKREG,4,0)")
	      bAvalAuto:= {||lMarkItem:= P_Te_3(aAux)}
	      Eval(bAvalAuto)
      EndIf

   Endif
   If ValType(lMarkItem) == "L"
      lRet:= lMarkItem
   EndIf

Return lRet// Nil

/*
Função    : ExecAutoSI()
Objetivos : Executar um ExecAuto de correspondência para SI
Parametros: nOpcAuto
			lAutInlcui
			lAutAltera
			lAutDeleta
			aCapa
			aItem
			nInc
Retorno   : .T.
Autor     : Thiago Rinaldi Pinto
Revisão   :
Data      : 18/05/2011
*/
*-------------------------------------------------------------------------------------*
Static Function ExecAutoSI(nOpcAuto,lAutInclui,lAutAltera,lAutDeleta,aCapa,aItem,nInc)
*-------------------------------------------------------------------------------------*
Local aItemAux
Local aCabSI:= {}
Local aItemSI:= {}
Local cCCusto
Local lRet:= .T.
Local nPOsPo,nPOsDt,nPOsCo,nPOsMo,nPOsCd,nPOsFa,nPOsFaL,nPOsPr,nPOsQtd,nPOsSld,nPOsCC,nPOsICC,nPO_SI,nPOsDtEnt,nPOsDtEmb,nPOsFo,nPOsFoL,nPOsAut,nPOsReg  // GFP - 01/10/2013
Local nPosDeleta
Local nI
Begin Sequence

   If AvFlags("EIC_EAI")
      Break
   EndIf

   //CAPA

   //Data
   nPOsDt:= aScan(aCapa, {|x|x[1] == "W2_PO_DT" })
   If nPosDt > 0
      aAdd(aCabSI,{"W0_DT",aCapa[nPosDt][2],Nil})
   Endif

   //Código Comprador
   nPOsCo:= aScan(aCapa, {|x|x[1] == "W2_COMPRA" })
   If nPosCo > 0
      aAdd(aCabSI,{"W0_COMPRA",aCapa[nPosCo][2],Nil})
   Endif

   //Moeda
   nPOsMo:= aScan(aCapa, {|x|x[1] == "W2_MOEDA" })
   If nPosMo > 0
      aAdd(aCabSI,{"W0_MOEDA",aCapa[nPosMo][2],Nil})
   Endif

   aItemAux:={}

   If nInc <> 0

      //Numero da SI
      If (nPO_SI:= aScan(aItem[nInc], {|x|x[1] == "W3_SI_NUM"})) > 0
         aAdd(aCabSI,{"W0__NUM",AvKey(aItem[nInc][nPO_SI][2], "W0__NUM"),Nil})
      Endif

      //ITENS

      If (nPOsAut := aScan(aItem[nInc], {|x| x[1] == "AUTDELETA" })) > 0
         aAdd(aItemAux, {"AUTDELETA", aItem[nInc][nPOsAut][2], Nil})
      EndIf

      If (nPOsReg := aScan(aItem[nInc], {|x| x[1] == "W3_REG" })) > 0
         aAdd(aItemAux, {"W1_REG", aItem[nInc][nPOsReg][2], Nil})
      EndIf

      If (nPOsCd := aScan(aItem[nInc], {|x| x[1] == "W3_COD_I" })) > 0
         aAdd(aItemAux, {"W1_COD_I", aItem[nInc][nPOsCd][2], Nil})
      EndIf

      If (nPOsICC := aScan(aItem[nInc], {|x| x[1] == "W3_CC" })) > 0
         aAdd(aItemAux, {"W1_CC", aItem[nInc][nPOsICC][2], Nil})
         aAdd(aCabSI,   {"W0__CC", AvKey(aItem[nInc][nPOsICC][2], "W0__CC"), Nil}) //RMD - 12/09/13 - AvKey
      EndIf

      If (nPOsFa := aScan(aItem[nInc], {|x| x[1] == "W3_FABR" })) > 0
         aAdd(aItemAux, {"W1_FABR", aItem[nInc][nPOsFa][2], Nil})
      EndIf

      If (nPOsFaL := aScan(aItem[nInc], {|x| x[1] == "W3_FABLOJ" })) > 0  // GFP - 01/10/2013 - Gravação do campo Loja
         aAdd(aItemAux, {"W1_FABLOJ", aItem[nInc][nPOsFaL][2], Nil})
      EndIf

      If (nPOsFo := aScan(aItem[nInc], {|x| x[1] == "W3_FORN" })) > 0
         aAdd(aItemAux, {"W1_FORN", aItem[nInc][nPOsFo][2], Nil})
      EndIf

      If (nPOsFoL := aScan(aItem[nInc], {|x| x[1] == "W3_FORLOJ" })) > 0  // GFP - 01/10/2013 - Gravação do campo Loja
         aAdd(aItemAux, {"W1_FORLOJ", aItem[nInc][nPOsFoL][2], Nil})
      EndIf

      If (nPOsPr := aScan(aItem[nInc], {|x| x[1] == "W3_PRECO" })) > 0
         aAdd(aItemAux, {"W1_PRECO", aItem[nInc][nPOsPr][2], Nil})
      EndIf

      //RMD - 12/09/13 - Não manda a quantidade na inclusão da SI
      If !SW0->(DbSeek(xFilial("SW0")+AvKey(aItem[nInc][nPOsICC][2],"W0__CC")+Avkey(aItem[nInc][nPO_SI][2],"W0__NUM")))
   	   If (nPOsQtd := aScan(aItem[nInc], {|x| x[1] == "W3_QTDE" })) > 0
   	      aAdd(aItemAux, {"W1_QTDE", aItem[nInc][nPOsQtd][2], Nil})
   	   EndIf
      EndIf

      //RMD - 12/09/13 - Não manda o saldo na alteração da SI
      If SW0->(DbSeek(xFilial("SW0")+AvKey(aItem[nInc][nPOsICC][2],"W0__CC")+Avkey(aItem[nInc][nPO_SI][2],"W0__NUM")))
   	   If (nPOsSld := aScan(aItem[nInc], {|x| x[1] == "W3_SALDO_Q" })) > 0 .And. aItem[nInc][nPOsSld][2] <> 0
   	      aAdd(aItemAux, {"W1_SALDO_Q", aItem[nInc][nPOsSld][2], Nil})
       ElseIf (nPOsQtd := aScan(aItem[nInc], {|x| x[1] == "W3_QTDE" })) > 0 //caso a rotina automática seja executada pela inclusão automática do P.O., terermos apenas o campo quantidade no array
          aAdd(aItemAux, {"W1_SALDO_Q", aItem[nInc][nPOsQtd][2], Nil})
   	   EndIf
      EndIF

      If (nPOsDtEmb := aScan(aItem[nInc], {|x| x[1] == "W3_DT_EMB" })) > 0
        aAdd(aItemAux, {"W1_DT_EMB", aItem[nInc][nPOsDtEmb][2], Nil})
      EndIf

      If (nPOsDtEnt := aScan(aItem[nInc], {|x| x[1] == "W3_DT_ENTR" })) > 0
         aAdd(aItemAux, {"W1_DTENTR_", aItem[nInc][nPOsDtEnt][2], Nil})
      EndIf

   Else   //Exclusao

      aAdd(aCabSI,   {"W0__NUM",WORK->WKSI_NUM,Nil})
      aAdd(aCabSI,   {"W0__CC", WORK->WKCC, Nil})
      aAdd(aItemAux, {"AUTDELETA", "S", Nil})
      aAdd(aItemAux, {"W1_REG", WORK->WKREG, Nil})
      aAdd(aItemAux, {"W1_COD_I", WORK->WKCOD_I, Nil})
      aAdd(aItemAux, {"W1_CC", WORK->WKCC, Nil})
      aAdd(aItemAux, {"W1_FABR", WORK->WKFABR, Nil})
      aAdd(aItemAux, {"W1_FORN", WORK->WKFORN, Nil})
      aAdd(aItemAux, {"W1_PRECO", WORK->WKPRECO, Nil})
      aAdd(aItemAux, {"W1_QTDE", WORK->WKQTDE, Nil})
      aAdd(aItemAux, {"W1_SALDO_Q", WORK->WKSALDO_Q, Nil})
      aAdd(aItemAux, {"W1_DT_EMB", WORK->WKDT_EMB, Nil})
      aAdd(aItemAux, {"W1_DTENTR_", WORK->WKDT_ENTR, Nil})

   Endif

   AADD(aItemSI,ACLONE(aItemAux))

   If lAutDeleta
      nPosDeleta := 0
      For nI := 1 To Len(aDeletaAuto)
         If aScan(aDeletaAuto[nI][1],{ |X| x[1] == "W0__NUM" .And. X[2] == Work->WKSI_NUM }) > 0 .And. aScan(aDeletaAuto[nI][1],{ |X| x[1] == "W0__CC" .And. x[2] == WORK->WKCC }) > 0
            nPosDeleta := nI
            Exit
         EndIf
      Next
      If nPosDeleta == 0
         aAdd(aDeletaAuto,{ACLONE(aCabSI),ACLONE(aItemSI)})  //Array de itens que serão deletados da SI
      Else
         aAdd(aDeletaAuto[nPosDeleta][2],ACLONE(aItemSI[1]))
      EndIf
   Endif

   If lAutInclui .OR. lAutAltera

      SW0->(DbSetOrder(1))
      If SW0->(DbSeek(xFilial("SW0")+AvKey(aItem[nInc][nPOsICC][2],"W0__CC")+Avkey(aItem[nInc][nPO_SI][2],"W0__NUM")))
         lRet:= MSExecAuto({|a,b,c,d| EICSI400(a,b,c)},aCabSI,aItemSI,4)
      Else
         lRet:= MSExecAuto({|a,b,c,d| EICSI400(a,b,c)},aCabSI,aItemSI,3)
      Endif

   Endif

End Sequence

Return lRet

/*
Função    : ValExecAutoCpos()
Objetivos : Validar campos enviado pelo ExecAuto
Parametros: aItem - Item a ser validado
Retorno   : aMsgs - Array de mensagens resultantes das validacoes
Autor     : Thiago Rinaldi Pinto
Revisão   :
Data      : 18/05/2011
*/
*--------------------------------------*
Static Function ValExecAutoCpos(aItem)
*--------------------------------------*
Local lRet:= .T.
Local aMsgs:= {}
Local nPosSI

If nOpcAuto == 4

   If aScan(aItem, {|x|x[1] == "W3_COD_I"}) == 0
      aAdd(aMsgs,STR0352) // STR0352 "Código do Item não informado"
   Endif

   If aScan(aItem, {|x|x[1] == "W3_REG"}) == 0
      aAdd(aMsgs,STR0353) //STR0353 "Reg não informado"
   Endif

   If aScan(aItem, {|x|x[1] == "W3_CC"}) == 0
      aAdd(aMsgs,STR0354) //STR0354 "Centro de Custo não informado"
   Endif

   If aScan(aItem, {|x|x[1] == "W3_SI_NUM"}) == 0 .Or. (nPosSI := aScan(aItem, {|x|x[1] == "W3_SI_NUM" })) > 0 .And. Empty(aItem[nPosSI][2])
      aAdd(aMsgs,STR0430) // "Solicitação de Importação não informada"
   Endif

Else

   If aScan(aItem, {|x|x[1] == "W3_COD_I"}) == 0
      aAdd(aMsgs,STR0355) //STR0355 "Código do Item não informado"
   Endif

   If aScan(aItem, {|x|x[1] == "W3_REG"}) == 0
      aAdd(aMsgs,STR0356) //STR0356 "Reg não informado"
   Endif

   If aScan(aItem, {|x|x[1] == "W3_CC"}) == 0
      aAdd(aMsgs,STR0357) //STR0357 "Centro de Custo não informado"
   Endif


   If aScan(aItem, {|x|x[1] == "W3_FABR"}) == 0
      aAdd(aMsgs,STR0358) //STR0358 "Fabricante não informado"
   Endif

   If aScan(aItem, {|x|x[1] == "W3_FORN"}) == 0
      aAdd(aMsgs,STR0359) //STR0359 "Fornecedor não informado"
   Endif

   If aScan(aItem, {|x|x[1] == "W3_PRECO"}) == 0
      aAdd(aMsgs,STR0360) //STR0360 "Preco não informado"
   Endif

   If aScan(aItem, {|x|x[1] == "W3_QTDE"}) == 0
      aAdd(aMsgs,STR0361) //STR0361 "Quantidade não informada"
   Endif
/* THTS - Nopado, pois o saldo_q é preenchido de forma automática, e quando era enviado zero, ocorria problemas com o embarque
   If aScan(aItem, {|x|x[1] == "W3_SALDO_Q"}) == 0
      aAdd(aMsgs,STR0362) // STR0362"Saldo não informado"
   Endif
*/
   If aScan(aItem, {|x|x[1] == "W3_DT_EMB"}) == 0
      aAdd(aMsgs,STR0363) //STR0363 "Data de Embarque não informada"
   Endif

   If aScan(aItem, {|x|x[1] == "W3_DT_ENTR"}) == 0
      aAdd(aMsgs,STR0364) //STR0364 "Data de Entrega não informada"
   Endif

Endif

Return aMsgs

Static Function EIDadosEJ0(o)

Begin Sequence

o:TableStruct('EJ0',{'EJ0_FILIAL','EJ0_COD','EJ0_DESC','EJ0_ENTR','EJ0_CHITEM','EJ0_TIPO','EJ0_CONSLD','EJ0_CHUSLD','EJ0_RE','EJ0_ADICAO','EJ0_CRITER','EJ0_MNTOBX','EJ0_CONDBX','EJ0_VALID'},1)
o:TableData("EJ0",{"  ","01",STR0365,"SW3","                                                                                                                                                                                                        ","E","2","                                                                                                                                                                                                        ","1","1","                    ","BTN_MK_TDS_ITS_PO|DESMARCA_IT_PO|MK_IT_PO|BTN_MK_IT                                                 ","                    ","                    "},,.F.) //STR0365 Admissão Temporária de Embalagem
o:TableData("EJ0",{"  ","01",STR0365,"SW5","                                                                                                                                                                                                        ","E","2","                                                                                                                                                                                                        ","1","1","                    ","BTN_MK_IT_PLI|DESMARCA_IT_PLI|MARCATODOS_ITS_PLI|MARCA_ITS_PLI                                      ","                    ","                    "},,.F.)//STR0365 Admissão Temporária de Embalagem
o:TableData("EJ0",{"  ","01",STR0365,"SW8","xFilial('SW8')+#SW6#->W6_HAWB+#SW9#->W9_INVOICE+#SW8#->W8_PO_NUM+#SW8#->W8_POSICAO+#SW8#->W8_PGI_NUM                                                                                                    ","E","1","EJ3_DI+EJ3_ADICAO+ EJ3_COD_I                                                                                                                                                                            ","1","1","                    ","MARC_TDS_EST|BTN_PRINC_EMB|MARC_IT_EST|MARC_EST_IV                                                  ","CondGrvCtrlEmb      ","VldGrvCtrlEmb       "},,.F.)//STR0365 Admissão Temporária de Embalagem
o:TableData("EJ0",{"  ","02",STR0366,"EE8","xFilial('EE8')+#EE8#->EE8_PEDIDO+#EE8#->EE8_SEQUEN+#EE8#->EE8_COD_I                                                                                                                                     ","S","1","                                                                                                                                                                                                        ","1","1","EASYFIFO            ","BTN_IT_EE8|BTN_EXC_PED                                                                              ","                    ","                    "},,.F.) //STR0366 Reexportação de embalagem admitida temporariamente          "
o:TableData("EJ0",{"  ","02",STR0366,"EE9","xFilial('EE9')+#EEC#->EEC_PREEMB+#EE9#->EE9_SEQEMB                                                                                                                                                      ","S","1","                                                                                                                                                                                                        ","1","1","EASYFIFO            ","EXC_EMB|DESMARC_IT|MARC_ITS_EMB                                                                     ","                    ","VldGrvCtrlEmb       "},,.F.)
o:TableData("EJ0",{"  ","03",STR0367,"EE8","                                                                                                                                                                                                        ","E","2","                                                                                                                                                                                                        ","1","1","                    ","BTN_IT_EE8|BTN_EXC_PED                                                                              ","                    ","                    "},,.F.)//STR0367 "Exportação Temporária de Embalagem"
o:TableData("EJ0",{"  ","03",STR0367,"EE9","xFilial('EE9')+#EEC#->EEC_PREEMB+#EE9#->EE9_SEQEMB                                                                                                                                                      ","E","1","EJ3_RE+EJ3_COD_I                                                                                                                                                                                        ","1","1","                    ","EXC_EMB|DESMARC_IT|MARC_ITS_EMB                                                                     ","                    ","VldGrvCtrlEmb       "},,.F.)
o:TableData("EJ0",{"  ","04",STR0368,"SW3","xFilial('SW3')+#SW3#->W3_PO_NUM+#SW3#->W3_POSICAO                                                                                                                                                       ","S","1","                                                                                                                                                                                                        ","1","1","EASYFIFO            ","BTN_MK_TDS_ITS_PO|DESMARCA_IT_PO|MK_IT_PO|BTN_MK_IT                                                 ","                    ","                    "},,.F.) //STR0368 "Reimportação de embalagem admitida temporariamente          "
o:TableData("EJ0",{"  ","04",STR0368,"SW5","                                                                                                                                                                                                        ","S","2","                                                                                                                                                                                                        ","1","1","EASYFIFO            ","BTN_MK_IT_PLI|DESMARCA_IT_PLI|MARCATODOS_ITS_PLI|MARCA_ITS_PLI                                      ","                    ","                    "},,.F.)
o:TableData("EJ0",{"  ","04",STR0368,"SW8","xFilial('SW8')+#SW6#->W6_HAWB+#SW9#->W9_INVOICE+#SW8#->W8_PO_NUM+#SW8#->W8_POSICAO+#SW8#->W8_PGI_NUM                                                                                                    ","S","1","                                                                                                                                                                                                        ","1","1","EASYFIFO            ","MARC_TDS_EST|BTN_PRINC_EMB|MARC_IT_EST|MARC_EST_IV                                                  ","CondGrvCtrlEmb      ","VldGrvCtrlEmb       "},,.F.)

o:TableStruct('EJ1',{'EJ1_FILIAL','EJ1_CODE','EJ1_ENTR','EJ1_CODS','EJ1_SAIDA'},1)
o:TableData('EJ1',{'  ','01','SW8','02','EE8'},,.F.)
o:TableData('EJ1',{'  ','01','SW8','02','EE9'},,.F.)
o:TableData('EJ1',{'  ','03','EE9','04','SW3'},,.F.)
o:TableData('EJ1',{'  ','03','EE9','04','SW8'},,.F.)

o:TableStruct('EJ2',{'EJ2_FILIAL','EJ2_CODE','EJ2_ENTR','EJ2_DE','EJ2_PARA'},1)
o:TableData("EJ2",{"  ","01","SW8","#SW6#->W6_DI_NUM                                                                                                                                                                                        ","EJ3_DI                                                                                                                                                                                                  "},,.F.)
o:TableData("EJ2",{"  ","01","SW8","#SW6#->W6_DTREG_D                                                                                                                                                                                       ","EJ3_DATA                                                                                                                                                                                                "},,.F.)
o:TableData("EJ2",{"  ","01","SW8","#SW8#->W8_ADICAO                                                                                                                                                                                        ","EJ3_ADICAO                                                                                                                                                                                              "},,.F.)
o:TableData("EJ2",{"  ","01","SW8","BUSCA_UM(#SW8#->W8_COD_I+#SW8#->W8_FABR+#SW8#->W8_FORN,#SW8#->W8_CC+#SW8#->W8_SI_NUM, EICRetLoja('#SW8#', 'W8_FABLOJ'), EICRetLoja('#SW8#', 'W8_FORLOJ'))                                               ","EJ3_UM                                                                                                                                                                                                  "},,.F.)
o:TableData("EJ2",{"  ","01","SW8","#SW8#->W8_QTDE                                                                                                                                                                                          ","EJ3_QTD                                                                                                                                                                                                 "},,.F.)
o:TableData("EJ2",{"  ","01","SW8","#SW8#->W8_COD_I                                                                                                                                                                                         ","EJ3_COD_I                                                                                                                                                                                               "},,.F.)
o:TableData("EJ2",{"  ","01","SW8","#SW8#->W8_PO_NUM                                                                                                                                                                                        ","EJ3_PO_NUM                                                                                                                                                                                              "},,.F.)
o:TableData("EJ2",{"  ","01","SW8","#SW8#->W8_POSICAO                                                                                                                                                                                       ","EJ3_POSICA                                                                                                                                                                                              "},,.F.)
o:TableData("EJ2",{"  ","01","SW8","#SW6#->W6_HAWB                                                                                                                                                                                          ","EJ3_HAWB                                                                                                                                                                                                "},,.F.)
o:TableData("EJ2",{"  ","01","SW8","#SW8#->W8_PGI_NUM                                                                                                                                                                                       ","EJ3_PGI_NU                                                                                                                                                                                              "},,.F.)
o:TableData("EJ2",{"  ","01","SW8","#SW8#->W8_INVOICE                                                                                                                                                                                       ","EJ3_INVOIC                                                                                                                                                                                              "},,.F.)
o:TableData("EJ2",{"  ","01","SW8","#SW7#->W7_PESO * #SW8#->W8_QTDE                                                                                                                                                                         ","EJ3_PESO                                                                                                                                                                                                "},,.F.)
o:TableData("EJ2",{"  ","02","EE8","#EE8#->EE8_UNIDAD                                                                                                                                                                                       ","EJ3_UM                                                                                                                                                                                                  "},,.F.)
o:TableData("EJ2",{"  ","02","EE8","#EE8#->EE8_SLDINI                                                                                                                                                                                       ","EJ3_QTD                                                                                                                                                                                                 "},,.F.)
o:TableData("EJ2",{"  ","02","EE8","#EE8#->EE8_COD_I                                                                                                                                                                                        ","EJ3_COD_I                                                                                                                                                                                               "},,.F.)
o:TableData("EJ2",{"  ","02","EE8","#EE8#->EE8_PEDIDO                                                                                                                                                                                       ","EJ3_PEDIDO                                                                                                                                                                                              "},,.F.)
o:TableData("EJ2",{"  ","02","EE8","#EE8#->EE8_PSLQUN * #EE8#->EE8_SLDINI                                                                                                                                                                   ","EJ3_PESO                                                                                                                                                                                                "},,.F.)
o:TableData("EJ2",{"  ","02","EE8","#EE8#->EE8_SEQUEN                                                                                                                                                                                       ","EJ3_SEQUEN                                                                                                                                                                                              "},,.F.)
o:TableData("EJ2",{"  ","02","EE8","dDataBase                                                                                                                                                                                               ","EJ3_DATA                                                                                                                                                                                                "},,.F.)
o:TableData("EJ2",{"  ","02","EE9","#EE9#->EE9_UNIDAD                                                                                                                                                                                       ","EJ3_UM                                                                                                                                                                                                  "},,.F.)
o:TableData("EJ2",{"  ","02","EE9","#EE9#->EE9_SLDINI                                                                                                                                                                                       ","EJ3_QTD                                                                                                                                                                                                 "},,.F.)
o:TableData("EJ2",{"  ","02","EE9","#EE9#->EE9_COD_I                                                                                                                                                                                        ","EJ3_COD_I                                                                                                                                                                                               "},,.F.)
o:TableData("EJ2",{"  ","02","EE9","#EE9#->EE9_RE                                                                                                                                                                                           ","EJ3_RE                                                                                                                                                                                                  "},,.F.)
o:TableData("EJ2",{"  ","02","EE9","IIF(Empty(#EE9#->EE9_DTRE),#EEC#->EEC_DTEMBA,#EE9#->EE9_DTRE)                                                                                                                                           ","EJ3_DATA                                                                                                                                                                                                "},,.F.)
o:TableData("EJ2",{"  ","02","EE9","#EEC#->EEC_PREEMB                                                                                                                                                                                       ","EJ3_PREEMB                                                                                                                                                                                              "},,.F.)
o:TableData("EJ2",{"  ","02","EE9","#EE9#->EE9_SEQEMB                                                                                                                                                                                       ","EJ3_SEQEMB                                                                                                                                                                                              "},,.F.)
o:TableData("EJ2",{"  ","02","EE9","#EE9#->EE9_PEDIDO                                                                                                                                                                                       ","EJ3_PEDIDO                                                                                                                                                                                              "},,.F.)
o:TableData("EJ2",{"  ","02","EE9","#EE9#->EE9_SEQUEN                                                                                                                                                                                       ","EJ3_SEQUEN                                                                                                                                                                                              "},,.F.)
o:TableData("EJ2",{"  ","02","EE9","#EE9#->EE9_PSLQUN * #EE9#->EE9_SLDINI                                                                                                                                                                   ","EJ3_PESO                                                                                                                                                                                                "},,.F.)
o:TableData("EJ2",{"  ","03","EE9","#EE9#->EE9_UNIDAD                                                                                                                                                                                       ","EJ3_UM                                                                                                                                                                                                  "},,.F.)
o:TableData("EJ2",{"  ","03","EE9","#EE9#->EE9_SLDINI                                                                                                                                                                                       ","EJ3_QTD                                                                                                                                                                                                 "},,.F.)
o:TableData("EJ2",{"  ","03","EE9","#EE9#->EE9_COD_I                                                                                                                                                                                        ","EJ3_COD_I                                                                                                                                                                                               "},,.F.)
o:TableData("EJ2",{"  ","03","EE9","#EE9#->EE9_RE                                                                                                                                                                                           ","EJ3_RE                                                                                                                                                                                                  "},,.F.)
o:TableData("EJ2",{"  ","03","EE9","IIF(Empty(#EE9#->EE9_DTRE),#EEC#->EEC_DTEMBA,#EE9#->EE9_DTRE)                                                                                                                                           ","EJ3_DATA                                                                                                                                                                                                "},,.F.)
o:TableData("EJ2",{"  ","03","EE9","#EEC#->EEC_PREEMB                                                                                                                                                                                       ","EJ3_PREEMB                                                                                                                                                                                              "},,.F.)
o:TableData("EJ2",{"  ","03","EE9","#EE9#->EE9_SEQEMB                                                                                                                                                                                       ","EJ3_SEQEMB                                                                                                                                                                                              "},,.F.)
o:TableData("EJ2",{"  ","03","EE9","#EE9#->EE9_PEDIDO                                                                                                                                                                                       ","EJ3_PEDIDO                                                                                                                                                                                              "},,.F.)
o:TableData("EJ2",{"  ","03","EE9","#EE9#->EE9_SEQUEN                                                                                                                                                                                       ","EJ3_SEQUEN                                                                                                                                                                                              "},,.F.)
o:TableData("EJ2",{"  ","03","EE9","#EE9#->EE9_PSLQUN * #EE9#->EE9_SLDINI                                                                                                                                                                   ","EJ3_PESO                                                                                                                                                                                                "},,.F.)
o:TableData("EJ2",{"  ","04","SW3","BUSCA_UM(#SW3#->W3_COD_I+#SW3#->W3_FABR +#SW3#->W3_FORN,#SW3#->W3_CC+#SW3#->W3_SI_NUM,EICRetLoja('#SW3#','W3_FABLOJ'),EICRetLoja('#SW3#','W3_FORLOJ'))                                                  ","EJ3_UM                                                                                                                                                                                                  "},,.F.)
o:TableData("EJ2",{"  ","04","SW3","#SW3#->W3_QTDE                                                                                                                                                                                          ","EJ3_QTD                                                                                                                                                                                                 "},,.F.)
o:TableData("EJ2",{"  ","04","SW3","#SW3#->W3_COD_I                                                                                                                                                                                         ","EJ3_COD_I                                                                                                                                                                                               "},,.F.)
o:TableData("EJ2",{"  ","04","SW3","#SW3#->W3_PO_NUM                                                                                                                                                                                        ","EJ3_PO_NUM                                                                                                                                                                                              "},,.F.)
o:TableData("EJ2",{"  ","04","SW3","#SW3#->W3_POSICAO                                                                                                                                                                                       ","EJ3_POSICA                                                                                                                                                                                              "},,.F.)
o:TableData("EJ2",{"  ","04","SW3","#SW3#->W3_PESOL * #SW3#->W3_QTDE                                                                                                                                                                        ","EJ3_PESO                                                                                                                                                                                                "},,.F.)
o:TableData("EJ2",{"  ","04","SW3","dDataBase                                                                                                                                                                                               ","EJ3_DATA                                                                                                                                                                                                "},,.F.)
o:TableData("EJ2",{"  ","04","SW8","#SW6#->W6_DTREG_D                                                                                                                                                                                       ","EJ3_DATA                                                                                                                                                                                                "},,.F.)
o:TableData("EJ2",{"  ","04","SW8","#SW6#->W6_DI_NUM                                                                                                                                                                                        ","EJ3_DI                                                                                                                                                                                                  "},,.F.)
o:TableData("EJ2",{"  ","04","SW8","#SW8#->W8_ADICAO                                                                                                                                                                                        ","EJ3_ADICAO                                                                                                                                                                                              "},,.F.)
o:TableData("EJ2",{"  ","04","SW8","BUSCA_UM(#SW8#->W8_COD_I+#SW8#->W8_FABR+#SW8#->W8_FORN,#SW8#->W8_CC+#SW8#->W8_SI_NUM, EICRetLoja('#SW8#', 'W8_FABLOJ'), EICRetLoja('#SW8#', 'W8_FORLOJ'))                                               ","EJ3_UM                                                                                                                                                                                                  "},,.F.)
o:TableData("EJ2",{"  ","04","SW8","#SW8#->W8_QTDE                                                                                                                                                                                          ","EJ3_QTD                                                                                                                                                                                                 "},,.F.)
o:TableData("EJ2",{"  ","04","SW8","#SW8#->W8_COD_I                                                                                                                                                                                         ","EJ3_COD_I                                                                                                                                                                                               "},,.F.)
o:TableData("EJ2",{"  ","04","SW8","#SW8#->W8_PO_NUM                                                                                                                                                                                        ","EJ3_PO_NUM                                                                                                                                                                                              "},,.F.)
o:TableData("EJ2",{"  ","04","SW8","#SW8#->W8_POSICAO                                                                                                                                                                                       ","EJ3_POSICA                                                                                                                                                                                              "},,.F.)
o:TableData("EJ2",{"  ","04","SW8","#SW6#->W6_HAWB                                                                                                                                                                                          ","EJ3_HAWB                                                                                                                                                                                                "},,.F.)
o:TableData("EJ2",{"  ","04","SW8","#SW8#->W8_PGI_NUM                                                                                                                                                                                       ","EJ3_PGI_NU                                                                                                                                                                                              "},,.F.)
o:TableData("EJ2",{"  ","04","SW8","#SW8#->W8_INVOICE                                                                                                                                                                                       ","EJ3_INVOIC                                                                                                                                                                                              "},,.F.)
o:TableData("EJ2",{"  ","04","SW8","#SW7#->W7_PESO * #SW8#->W8_QTDE                                                                                                                                                                         ","EJ3_PESO                                                                                                                                                                                                "},,.F.)

End Sequence

Return Nil

/*
Função    : PO400GravaPC
Objetivos : Montar os arrays aCap e aItens para o ExecAuto.
Parametros: nOpcao
Retorno   :
Autor     : Ivo Santana Santos
Revisão   :
Data      : 17/03/11
*/

Function PO400GravaPC(nOpcao)
Local aOrd:= SaveOrd({"SW3", "SA2", "SYF", "SY1", "SW0", "SB1", "SC7", "SC1", "SW1", "SYT"})
Local aItensAtu:= {}

Local cNumPed:= ""
Local cW3_CC := "" //LGS-17/10/2014
Local lPrimeira
Local lRet:= .F.
Local lCompara:= .T.

Local nDespesa
Local nCont
Local nPos
Local nPosProd
Local nPosItem
Local nPosProd2
Local nPosItem2
Local nPreco := 0  // GFP - 17/07/2013
Local x
Local cCodUser:= RetCodUsr()
Private aCab    := {}
Private aItensPo:= {} //para cada item
Private aItem   := {} //acumula itens

If Type("lPoAuto") == "U"
   lPoAuto:= .F.
EndIf

SW3->(DBSetOrder(1))
SC7->(DBSetOrder(1))
SC1->(DBSetOrder(1))
SW1->(DBSetOrder(1))
SYT->(DBSetOrder(1))

Begin Sequence


   //Carrega os itens atuais do pedido de compras
   If nOpcao <> INCLUIR .And. !Empty(SW2->W2_PO_SIGA)

       aItensAtu:= ItensSC7(SW2->W2_PO_SIGA, nOpcao)

       //TRP - 27/01/2012 - Não prosseguir caso o array aItensAtu esteja vazio.
       If Len(aItensAtu) == 0
          Break
       Endif

       nPosProd2:= AScan(aItensAtu[1], {|x| AllTrim(x[1]) == "C7_PRODUTO"})
       nPosItem2:= AScan(aItensAtu[1], {|x| AllTrim(x[1]) == "C7_ITEM"})
   EndIf

   If SW3->(DBSeek(xFilial() + SW2->W2_PO_NUM))

      //Número do pedido
      If !Empty(AllTrim(SW2->W2_PO_SIGA))
         cNumPed:= SW2->W2_PO_SIGA
      Else
         cNumPed:= LEFT(SW3->W3_PO_NUM,6)
      EndIf

      If !(lPoAuto) //FSM - 17/05/2012
         ProcRegua(Len(aItensAtu))
         IncProc(STR0369) //STR0369 "Processando o pedido de compras"
      EndIf


      //Posiciona no fornecedor
      SA2->(DBSetOrder(1))
      SA2->(DBSeek(xFilial()+SW2->W2_FORN+IIf(EICLoja(), SW2->W2_FORLOJ, "")))

      //WFS - 19/01/12 - Posiciona o importador
      SYT->(DBSeek(xFilial() + SW2->W2_IMPORT))

      //Despesas da capa
      nDespesa:= SW2->(W2_INLAND + W2_PACKING + W2_OUT_DES)

      lPrimeira:= .T.

      //Variável reiniciada para considerar os dados da tabela SW2
      aCab:= {}
      While SW3->(!Eof()) .And. SW3->W3_FILIAL == SW3->(xFilial()) .And.;
            SW3->W3_PO_NUM == SW2->W2_PO_NUM

         If !(lPoAuto) //FSM - 17/05/2012
            IncProc()
         EndIf

         //Reinicia a variável
         aItensPo:= {}
         nPreco := 0

         SW0->(DBSetOrder(1))
         SW0->(DBSeek(xFilial() + SW3->(W3_CC + W3_SI_NUM)))

         If SW3->W3_SEQ == 0

            //Dados da capa
            If lPrimeira

               AAdd(aCab,  {"C7_NUM"    , cNumPed                  , Nil})
               AAdd(aCab,  {"C7_FILENT" , CriaVar("C7_FILENT", .T.), Nil})

               //WFS 19/01/12 - Tratamentos de conta e ordem
               //Se o tratamento está habilitado, se o processo é de conta e ordem e se é o adquirente
               If EasyGParam("MV_EIC_PCO",,.F.) .And. SW2->W2_IMPCO == "1" .And. !EasyGParam("MV_PCOIMPO",,.T.)
                  If Empty(SYT->YT_FORN)
                     MsgInfo(STR0372, STR0037)//"Nesta modalidade de conta e ordem, os campos fornecedor e loja devem ser preenchidos no cadastro do importador." / "Atenção"
                     Break
                  EndIf
                  AAdd(aCab,  {"C7_FORNECE", SYT->YT_FORN             , Nil})
                  AAdd(aCab,  {"C7_LOJA"   , SYT->YT_LOJA             , Nil})
               Else
                  AAdd(aCab,  {"C7_FORNECE", SW2->W2_FORN             , Nil})
                  AAdd(aCab,  {"C7_LOJA"   , SA2->A2_LOJA             , Nil})
               EndIf

               AAdd(aCab,  {"C7_EMISSAO", SW2->W2_PO_DT            , Nil})
               AAdd(aCab,  {"C7_DESPESA", nDespesa                 , Nil})

               If !Empty(SW2->W2_MOEDA) //Busca da moeda e taxa da moeda
                  SYF->(DBSetOrder(1))
                  If SYF->(DBSeek(xFilial("SYF")+SW2->W2_MOEDA))
                     AAdd(aCab,  {"C7_MOEDA"  , SYF->YF_MOEFAT                               , Nil})
                     AAdd(aCab,  {"C7_TXMOEDA", BuscaTaxa(SW2->W2_MOEDA, SW2->W2_DT_PAR,,.F.), Nil})
                  EndIf
               EndIf

               AAdd(aCab,  {"C7_CONTATO", SA2->A2_CONTATO, Nil})
               AAdd(aCab,  {"C7_USER"   , cCodUser       , Nil})

               SY6->(DBSetOrder(1))
               If SY6->(DBSeek(xFilial()+SW2->W2_COND_PA)) //Condição de pagamento
                  AAdd(aCab,  {"C7_COND"   , SY6->Y6_SIGSE4 , Nil})
               EndIf

               //WFS - 19/01/12
               If SW2->W2_FREINC == "1"
                  AAdd(aCab,  {"C7_FRETE"  , 0              , Nil})
               Else
                  AAdd(aCab,  {"C7_FRETE"  , SW2->W2_FRETEIN, Nil})
               EndIf

               If SW2->W2_SEGINC == "1"
                  AAdd(aCab,  {"C7_SEGURO"  , 0              , Nil})
               Else
                  AAdd(aCab,  {"C7_SEGURO"  , SW2->W2_SEGURIN, Nil})
               EndIf

               AAdd(aCab,  {"C7_MSG"    , ""                  , Nil})

               //Específicos do controle de alçadas
               If lAlcada .And. SW2->(FieldPos("W2_CONAPRO")) > 0
                  aAdd(aCab, {"C7_COMPRA", SW2->W2_COMPRA, Nil})
               EndIf

               lPrimeira:= .F.

               //Ponto de entrada para gravação da capa
               If EasyEntryPoint("EICPO400")
                  ExecBlock("EICPO400",.F.,.F.,"PO400GRAVAPC_CAPA")
               EndIf

            EndIf

            SB1->(DBSetOrder(1))
            SB1->(DBSeek(xFilial() + SW3->W3_COD_I))

            //Criação do local no Saldos em Estoque
            If ! SB2->(DBSeek(xFilial() + SB1->B1_COD + SB1->B1_LOCPAD))
               CriaSB2(SB1->B1_COD, SB1->B1_LOCPAD)
            EndIf

            AAdd(aItensPo, {"C7_FILIAL" , xFilial("SC7")                              , Nil})
            AAdd(aItensPo, {"C7_PRODUTO", SB1->B1_COD                                 , Nil})
            AAdd(aItensPo, {"C7_UM"     , SB1->B1_UM                                  , Nil})

            PosO1_It_Solic(SW3->W3_CC,SW3->W3_SI_NUM,SW3->W3_COD_I,SW3->W3_REG,0) //MCF - 18/05/2016
            If SC1->(DBSEEK(xFilial("SC1")+SW0->W0_C1_NUM+SW1->W1_POSICAO)) .AND. !EMPTY(SC1->C1_LOCAL)
               AAdd(aItensPo, {"C7_LOCAL"  , SC1->C1_LOCAL                            , Nil})
            Else
               AAdd(aItensPo, {"C7_LOCAL"  , SB1->B1_LOCPAD                           , Nil})
            EndIf

            // GFP - 04/07/2013
            //aSegUM  :=AV_Seg_Uni(SW3->W3_CC,SW3->W3_SI_NUM,SW3->W3_COD_I,SW3->W3_REG,SW3->W3_QTDE)
            aSegUM  :=AV_Seg_Uni(SW3->W3_CC,SW3->W3_SI_NUM,SW3->W3_COD_I,SW3->W3_REG,SW3->W3_QTDE,,,SW3->W3_FABR, SW3->W3_FABLOJ, SW3->W3_FORLOJ) //WHRS 07/04/17 TE-5311 511739 / MTRADE-770 / 863 - Ao confirmar a inclusão do PO apresenta error log

            //FDR - 06/08/12
            If EasyGParam("MV_UNIDCOM",,2) == 2 .And. !Empty(SB1->B1_SEGUM)
               aAdd(aItensPo,{"C7_QTSEGUM", SW3->W3_QTDE                                , Nil})
               aAdd(aItensPo,{"C7_QTDSOL" , aSegUM[2]                                   , Nil}) //FDR - 04/07/13
            Else
               aAdd(aItensPo,{"C7_QUANT"  , SW3->W3_QTDE                                , Nil})
               aAdd(aItensPo,{"C7_QTDSOL" , SW3->W3_QTDE                                , Nil}) //FDR - 28/06/13
            EndIf


            // GFP - 04/07/2013 - Tratamento de Preço
            IF !EMPTY(aSegUM[2])
               IF EasyGParam("MV_UNIDCOM",,2) == 2
                  nPreco  :=( SW3->W3_QTDE * SW3->W3_PRECO) / aSegUM[2]
               ELSE
                  nQtSegUM:=aSegUM[2]
               ENDIF
               cSegUM:=aSegUM[1]
            ENDIF

            //Quando o parâmetro estiver ligado (.T.), se o campo W3_CTCUSTO existir, o conteúdo do mesmo será enviado
            //para o pedido de compra e caso não exista será enviado o campo W3_CC.
            //Se o parâmetro estiver desligado (.F.), o campo Centro de Custo será enviado em branco para o pedido de compras.
            cW3_CC := IF(lCpoCtCust, SW3->W3_CTCUSTO, SW3->W3_CC) //MCF - 07/01/2016
            IF !EasyGParam("MV_GCUSTO",,.T.) //.AND. EMPTY(SW3->W3_CTCUSTO)//LGS-17/10/2014
               cW3_CC := ""
            ENDIF

            aAdd(aItensPo, {"C7_PRECO"  , If(nPreco == 0, SW3->W3_PRECO, nPreco)      , Nil})    // GFP - 04/07/2013 - Tratamento de Preço
            AAdd(aItensPo, {"C7_CONTA"  , SB1->B1_CONTA                               , Nil})
            AAdd(aItensPo, {"C7_ITEMCTA", SB1->B1_ITEMCC                              , Nil})
            AAdd(aItensPo, {"C7_CLVL"   , SB1->B1_CLVL                                , Nil})
            aAdd(aItensPo, {"C7_CC"     , cW3_CC                                      , Nil})
            aAdd(aItensPo, {"C7_OBS"    , "PEDIDO DE IMPORTACAO"                      , Nil}) //digitar no atusx
            aAdd(aItensPo, {"C7_ITEM"   , SW3->W3_POSICAO                             , Nil})
            aAdd(aItensPo, {"C7_DATPRF" , SW3->W3_DT_ENTR                             , Nil})
            If SC7->(FieldPos("C7_PO_EIC")) > 0
               AAdd(aItensPo, {"C7_PO_EIC" , SW3->W3_PO_NUM                           , Nil})
            EndIf
            aAdd(aItensPo, {"C7_SEQUEN" , SW3->W3_POSICAO                             , Nil})
            aAdd(aItensPo, {"C7_NUMIMP" , SW3->W3_PO_NUM                              , Nil})
            aAdd(aItensPo, {"C7_FLUXO"  , If(EasyGParam("MV_EASYFIN")=="S" .AND. EasyGParam("MV_EASYFPO")=="S","N","S"), Nil})//FDR - 28/06/13
            aAdd(aItensPo, {"C7_ORIGEM" , FunName()                                   , Nil})
            AAdd(aItensPo, {"C7_NUMSC"  , PO400NumSC()                                , Nil})  // GFP - 18/09/2015

            //Específicos do controle de alçadas

            //Quando houver solicitação de compras, considerar os dados informados nessa fase
            //SW1->(DBSeek(xFilial() + SW3->W3_CC + SW3->W3_SI_NUM + SW3->W3_COD_I))
            PosO1_It_Solic(SW3->W3_CC,SW3->W3_SI_NUM,SW3->W3_COD_I,SW3->W3_REG,0) //LGS - 09/09/2013 - Posicionar na Tabela e para posição correta do Item
            If !Empty(SW1->W1_POSICAO) .And. SC1->(DBSeek(xFilial() + SW0->W0_C1_NUM + SW1->W1_POSICAO))

               If !lCpoCtCust
                  nPos:= AScan(aItensPo, {|x| AllTrim(x[1]) == "C7_CC"})
                  aItensPo[nPos][2]:= SC1->C1_CC
               EndIf

               nPos:= AScan(aItensPo, {|x| AllTrim(x[1]) == "C7_CONTA"})
               aItensPo[nPos][2]:= SC1->C1_CONTA

               nPos:= AScan(aItensPo, {|x| AllTrim(x[1]) == "C7_ITEMCTA"})
               aItensPo[nPos][2]:= SC1->C1_ITEMCTA

               nPos:= AScan(aItensPo, {|x| AllTrim(x[1]) == "C7_CLVL"})
               aItensPo[nPos][2]:= SC1->C1_CLVL

               AAdd(aItensPo, {"C7_NUMSC" , PO400NumSC(), Nil})  // GFP - 18/09/2015
               AAdd(aItensPo, {"C7_ITEMSC", If(!Empty(aItensPo[aScan(aItensPo,{|x| x[1] == "C7_NUMSC"})][2]),SC1->C1_ITEM,"")  , Nil})  // GFP - 18/09/2015

            EndIf

            If SW3->(FieldPos("W3_OUT_DES")) > 0
               AAdd(aItensPo, {"C7_DESPESA" , SW3->(W3_INLAND + W3_PACKING + W3_OUT_DES)        , Nil})
            Else
			      AAdd(aItensPo, {"C7_DESPESA" , nDespesa * SW3->(W3_PRECO*W3_QTDE)/SW2->W2_FOB_TOT        , Nil})
            EndIf
            AAdd(aItensPo, {"C7_VLDESC"  , (SW2->W2_DESCONT*SW3->(W3_PRECO*W3_QTDE))/SW2->W2_FOB_TOT , Nil})

            If SW2->(FieldPos("W2_CONTR")) > 0 .And. SW2->W2_CONTR == "1"
            	PosO1_It_Solic(SW3->W3_CC,SW3->W3_SI_NUM,SW3->W3_COD_I,SW3->W3_REG,0)
				AAdd(aItensPo, {"C7_CONTRA", SW1->W1_C3_NUM, Nil})
				AAdd(aItensPo, {"C7_NUMSC" , SW1->W1_C3_NUM, Nil})
				AAdd(aItensPo, {"C7_ITEMSC", SW1->W1_POSICAO, Nil})
            EndIf


            If nOpcao <> INCLUIR

               //Verifica se o item foi adicionado ao PO, comparando o aItensPO com array aItensAtu que traz os dados já
               //gravados no pedido de compras.
               //Caso verdadeiro, os campos abaixo não devem ser enviados para o item.
               nPosProd:= AScan(aItensPo, {|x| AllTrim(x[1]) == "C7_PRODUTO"})
               nPosItem:= AScan(aItensPo, {|x| AllTrim(x[1]) == "C7_ITEM"})

               If AScan(aItensAtu, {|x| AllTrim(x[nPosProd2][2]) + AllTrim(x[nPosItem2][2]) == ;
                        AllTrim(aItensPo[nPosProd][2]) + AllTrim(aItensPo[nPosItem][2])}) <> 0

                  AAdd(aItensPo, {"LINPOS"    ,"C7_ITEM",StrZero(Val(SW3->W3_POSICAO),len(SC7->C7_ITEM)),Nil})
                  AAdd(aItensPo, {"AUTDELETA" , "N"            , Nil})
               EndIf
            EndIf

            //Ponto de entrada para gravação dos itens
            If EasyEntryPoint("EICPO400")
               ExecBlock("EICPO400",.F.,.F.,"PO400GRAVAPC_ITEM")
            EndIf


            AAdd(aItem, AClone(aItensPo))
         EndIf

         SW3->(DBSkip())

      EndDo

   Else
      lCompara:= .F.
      aItem:= AClone(aItensAtu)
   EndIf


   //Comparação dos itens do PO com os itens do PC.
   //Não encontra-los no array aItensPo significa que foram excluidos
   If nOpcao <> INCLUIR .And. !Empty(SW2->W2_PO_SIGA) .And. lCompara

      //Posição dos campos-chaves
      nPosProd:= AScan(aItem[1], {|x| AllTrim(x[1]) == "C7_PRODUTO"})
      nPosItem:= AScan(aItem[1], {|x| AllTrim(x[1]) == "C7_ITEM"})

      For nCont:= 1 To Len(aItensAtu)

         //Se não encontrar o item, envia-o para ser deletado
         If AScan(aItem, {|x| AllTrim(x[nPosProd][2]) + AllTrim(x[nPosItem][2]) == ;
                  AllTrim(aItensAtu[nCont][nPosProd2][2]) + AllTrim(aItensAtu[nCont][nPosItem2][2])}) == 0

            AAdd(aItem,{}) //MCF - 16/03/2016
            For x:=1 To Len(aItem[1])
               nPos := AScan(aItensAtu[nCont], {|y| AllTrim(y[1]) == aItem[1][x][1]})
               If nPos > 0
                  AAdd(aItem[Len(aItem)],aItensAtu[nCont][nPos])
               Else
                  AAdd(aItem[Len(aItem)],aItem[1][x])
               Endif
            Next

            If (nPos := AScan(aItensAtu[nCont], {|x| AllTrim(x[1]) == "AUTDELETA"})) > 0
               AAdd(aItem[Len(aItem)],aItensAtu[nCont][nPos])
            Endif

            If (nPos := AScan(aItensAtu[nCont], {|x| AllTrim(x[1]) == "LINPOS"})) > 0
               AAdd(aItem[Len(aItem)],aItensAtu[nCont][nPos])
            Endif

         EndIf
      Next
   EndIf

   lRet:= PO400ExecAuto(nOpcao)
End Sequence

RestOrd(aOrd, .T.)
Return lRet


/*
Função    : PO400ExecAuto
Objetivos : Chamada do ExecAuto para integração com o compras, necessário a montagem
            dos arrays aCab e aItem previamente
Parametros: nOpcao - INCLUIR - 3
                     ALTERAR - 4
                     EXCLUIR - 5
Retorno   :
Autor     : Ivo Santana Santos
Revisão   :
Data      : 17/03/11
*/

Function PO400ExecAuto(nOpcao)
Local lReturn := .T.
Local lLancOnline:= .F.
Local lMostraLanc := .F.
Local lAglutLanc := .F.

Local i

Local nPos
Local nOldLancOnline
Local nOldMostraLanc
Local nOldAglutLanc
Local cGrAprov    := EasyGParam("MV_PCAPROV") //LRS - 14/11/2017
Local nMoe_Com := 0 //LRS - 14/11/2017

Local nTipo //LRS - 20/01/2013 - Variavel para definir o valor do parametro dentro do MATA120

If(!IsMemVar("lMsErroAuto"))
   Private lMsErroAuto := .F.//Declara a variavel como Private caso nao tenha sido declarada anteriormente 
EndIf 

IF SW2->(FieldPos("W2_CONTR")) > 0 .AND. SW2->W2_CONTR == "1" //LRS - 20/01/2013 - verifica se tem contrato ou não
	nTipo := 2
else
	nTipo :=1
EndIF

BEGIN SEQUENCE

   nPos:= AScan(aItem[1], {|x| AllTrim(x[1]) == "AUTDELETA"})
   If nOpcao == 6
        nOpcao := 5
   EndIf
   If nOpcao == EXCLUIR//5
      For i := 1 To Len(aItem)
         If aItem [i][nPos][2] == "N"
            nOpcao := ALTERAR //4
            Break
         EndIf
      Next i
   EndIf

END SEQUENCE

Begin Sequence

   //Início dos tratamentos para lançamentos contábeis
   Pergunte("EICFI4",.F.)
   If MV_PAR01 == 1
      lLancOnline:= .T.
   EndIf
   If MV_PAR02 == 1
      lMostraLanc:= .T.
   EndIf
   If MV_PAR03 == 1
      lAglutLanc:= .T.
   EndIf

   //Armazena os dados informados no pergunte do pedido de compras
   Pergunte("MTA120",.F.)
   nOldLancOnline:= MV_PAR05
   nOldMostraLanc:= MV_PAR07
   nOldAglutLanc := MV_PAR06

   //Altera o pergunte para realização da contabilização
   MV_PAR05:= IIf(lLancOnline, 1, 2)
   MV_PAR07:= IIf(lMostraLanc, 1, 2)
   MV_PAR06:= IIf(lAglutLanc , 1, 2)

   MsExecAuto({|x,y,z,w|Mata120(x,y,z,w)},nTipo,aCab,aItem,nOpcao)

   If lMsErroAuto      
      lReturn := .F.   
      If !IsBlind()         
         MostraErro()
      EndIf               
   EndIf

   // wfs - na rotina automática, quando há controle de alçadas, assumir o status reapurado pelo módulo SIGACOM
   If lReturn .And. lAlcada .And. (SW2->W2_PO_SIGA == SC7->C7_NUM .Or. SC7->(DBSeek(xFilial() + SW2->W2_PO_SIGA)))
      SW2->(Reclock("SW2", .F.))
      SW2->W2_CONAPRO:= SC7->C7_CONAPRO
      SW2->(MsUnlock())
   ElseIF lReturn .And. !lAlcada .AND. !Empty(SC7->C7_CONAPRO)
      If GetAPOInfo("matxalc.prx")[4] < CTOD('05/07/2022') //G.C - O trecho de exclusão da alçada só será executado caso não tenha atualização do matxalc onde trata-se para não gerar a alçada quando o parâmetro está desabilitado 
         nMoe_Com := SimbToMoeda(SW2->W2_MOEDA)

         SY1->(dbSetOrder(1))
         IF SY1->(DbSeek(xFilial("SY1")+SW2->W2_COMPRA)) .And. !Empty(SY1->Y1_GRAPROV)
         cGrAprov := SY1->Y1_GRAPROV
         ENDIF

         MaAlcDoc({SW2->W2_PO_SIGA,"PC",SW2->W2_FOB_TOT,,,cGrAprov,,nMoe_Com,,SW2->W2_PO_DT},,3)

         SC7->(DbSetOrder(1))

         If SC7->(DbSeek(xFilial("SC7")+AvKey(SW2->W2_PO_SIGA, "C7_NUM")))

            While SC7->(!Eof()) .And. SC7->C7_FILIAL == SC7->(xFilial()) .And.;
               SC7->C7_NUM == AvKey(SW2->W2_PO_SIGA, "C7_NUM")
               SC7->(Reclock("SC7", .F.))
               SC7->C7_CONAPRO := ""
               SC7->(MsUnlock())

               SC7->(DbSkip())
            EndDo
         EndIF
      EndIF

   EndIF

   //Restaura o pergunte do pedido de compras
   Pergunte("MTA120",.F.)
   MV_PAR05:= nOldLancOnline
   MV_PAR07:= nOldMostraLanc
   MV_PAR06:= nOldAglutLanc


   aCab := {}
   aItem := {}
End Sequence

Return lReturn

/*
Função    : ItensSC7
Objetivos : Função para montar o array aSC7 com todos os itens do pedido
Parametros: NumPed - Número do Pedido de Compras
Retorno   :
Autor     : Ivo Santana Santos
Revisão   :
Data      : 15/04/11
*/

Static Function ItensSC7(NumPed, nOpcao)
Local aSC7Itens := {}
Local aItem_SC7 := {}

Local nCont

SC7->(DbSetOrder(1))
SX3->(DBSetOrder(2))

If SC7->(DbSeek(xFilial("SC7")+AvKey(NumPed, "C7_NUM")))

   While SC7->(!Eof()) .And. SC7->C7_FILIAL == SC7->(xFilial()) .And.;
         SC7->C7_NUM == AvKey(NumPed, "C7_NUM")

      //Quando o PO for excluído, os dados não estarão na base para serem carregados.


      If nOpcao == EXCLUIR .OR. nOpcao == 6 //FDR - 10/01/2012 - Tratamento para o cancelamento de PO (nOpcao = 6)
         aAdd(aCab,  {"C7_NUM"    , SC7->C7_NUM    , Nil})
         aAdd(aCab,  {"C7_FILENT" , SC7->C7_FILENT , Nil})
         aAdd(aCab,  {"C7_FORNECE", SC7->C7_FORNECE, Nil})
         aAdd(aCab,  {"C7_LOJA"   , SC7->C7_LOJA   , Nil})
         aAdd(aCab,  {"C7_EMISSAO", SC7->C7_EMISSAO, Nil})
         aAdd(aCab,  {"C7_DESPESA", SC7->C7_DESPESA, Nil})
         AAdd(aCab,  {"C7_MOEDA"  , SC7->C7_MOEDA  , Nil})
         AAdd(aCab,  {"C7_TXMOEDA", SC7->C7_TXMOEDA, Nil})
         aAdd(aCab,  {"C7_CONTATO", SC7->C7_CONTATO, Nil})
         aAdd(aCab,  {"C7_USER"   , SC7->C7_USER   , Nil})
         aAdd(aCab,  {"C7_GRUPCOM", SC7->C7_GRUPCOM, Nil})
         AAdd(aCab,  {"C7_COND"   , SC7->C7_COND   , Nil})
         aAdd(aCab,  {"C7_FRETE"  , SC7->C7_FRETE  , Nil})
         aAdd(aCab,  {"C7_MSG"    , SC7->C7_MSG    , Nil})
      EndIf

      aItem_SC7 := {}
      For nCont:= 1 To SC7->(FCount())
         SX3->(DBSeek(SC7->(FieldName(nCont))))
         If X3Uso(SX3->X3_USADO) .And. SX3->X3_CONTEXT <> "V" .And.;
            AScan(aCab, {|x| AllTrim(x[1]) == AllTrim(SX3->X3_CAMPO)}) == 0

            AAdd(aItem_SC7, {SC7->(FieldName(nCont)), SC7->(FieldGet(nCont)), Nil})
         EndIf
      Next

      //Por padrão, estes itens serão excluídos caso não sejam encontrado no array de itens
      AAdd(aItem_SC7, {"AUTDELETA", "S"     , Nil})
      aAdd(aItem_SC7, {"LINPOS"   ,"C7_ITEM",SC7->C7_ITEM,Nil})

      AAdd(aSC7Itens, AClone(aItem_SC7))

      SC7->(DbSkip())

   EndDo


EndIf

Return aSC7Itens


/*
Funcao      : CposUsados
Objetivos   : Tratamento para trazer todos os campos que estão como usados no dicionário de dados
Autor       :
Data/Hora   :
Retorno     :
*/

Static Function CposUsados()
Local aCposUsados:= {}

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("SC7")

While !EOF() .And. (X3_ARQUIVO == "SC7")

   If X3Uso(X3_USADO) .And. X3_CONTEXT <> "V"
      AAdd(aCposUsados, X3_CAMPO)
   EndIF

   DBSkip()

EndDo

Return aCposUsados

/*
Funcao     : PO400ValEli()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Eliminar Saldo do PO e do Compras
Autor      : Diogo Felipe dos Santos
Data/Hora  : 31/10/2011 - 16:35
*/
*----------------------------------------*
Function PO400ValEli(cForn,cLoja,cPedido)
*----------------------------------------*
Private lSim := .T.
/*
"Existem divergências entre o Pedido de Compras e o Purchase Order. Isto ocorre porque a Nota Fiscal não deve ter sido classificada ou associada a o Pedido de Compras."
"Se clicar em Sim, o sistema eliminará o Pedido de Compras! Deseja confirmar a operação?"
*/

SC7->(dbSetOrder(3))
SC7->(Dbseek(xFilial("SC7") + aVKEY(cForn,"W2_FORN") + AVKEY(cLoja,"A2_LOJA") + AVKEY(cPedido,"W2_PO_SIGA")))

If SW3->W3_SALDO_Q <> SC7->C7_QUANT
   If !MsgNoYes(STR0321+SW2->W2_PO_SIGA+STR0322,STR0323)
      lSim := .F.
   EndIf
EndIf

Return lSim

/*
Funcao     : WhenQtdPrec()
Parametros : cCampo
Retorno    : .T./.F.
Objetivos  : Tratamento When para os campos "W3_QTDE" e "W3_PRECO"
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 18/04/2013 - 14:40
Revisão    : Nopado por GFP - 06/06/2013 - Sistema deve sempre permitir alterar Quantidade e Preço dos itens.
*/
/*-----------------------------*
Static Function WhenQtdPrec(cCampo)
*-----------------------------*
Local lRet := .F.
Local aOrd := SaveOrd({"SWB","SW7"})

Begin Sequence

   If cCampo == "W3_QTDE" .AND. !lPOdaIntegracao .OR. Empty(Work->WKSI_NUM)
      If SWB->(dbSeek(xFilial("SWB")+M->W2_PO_NUM)) .AND. Posicione("SWA",1,xFilial("SWA")+SWB->WB_HAWB,"WA_PO_DI") == 'A'
         lRet := .F.
      ElseIf Posicione("SW7",3,xFilial("SW7")+TCC+TSi_Num,"W7_SI_NUM") == TSi_Num
         Do While SW7->(!Eof()) .AND. SW7->W7_FILIAL == xFilial("SW7") .AND. SW7->W7_CC == TCC .AND. SW7->W7_SI_NUM == TSi_Num
            If SW7->W7_COD_I == M->W3_COD_I
               If M->W3_SEM_PED > 0
                  lRet := .T.
                  Break
               Else
                  lRet := .F.
                  Break
               Endif
            EndIf
            SW7->(DbSkip())
         EndDo
         lRet := .T.  // Para casos em que a parte da SI já está em fase de embarque, mas o item em questão está em fase de PO.
      Else
         lRet := .T.
      EndIf
   ElseIf cCampo == "W3_PRECO"   // GFP - 06/06/2013 - Tratamento para campo Preço
      If M->W3_SALDO_Q <> 0      // Para casos em que produto está parcialmente embarcado, sistema deve permitir alteração do campo Preço.
         lRet := .T.
      EndIf
   Else
      lRet := .F.
   EndIf

End Sequence

RestOrd(aOrd,.T.)
Return lRet
*/
/*
Funcao     : PO400Anuente()
Parametros : Nenhum
Retorno    : .T./.F.
Objetivos  : 
Verifica se há itens anuentes no processo e se existe PLI para o Purchase Order
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 21/03/2014
*/
*------------------------*
Function PO400Anuente(cPoNum)
*------------------------*
Local lRet := .F.

If Select("SQLAUX") > 0
   SQLAUX->(DbCloseArea())
EndIf   
BeginSQL Alias "SQLAUX"
Select R_E_C_N_O_ RECSW5 From %table:SW5% SW5
       Where SW5.%NotDel% And SW5.W5_SEQ = 0 AND SW5.W5_FLUXO = '1' AND SW5.W5_PO_NUM = %exp:cPoNum% AND SW5.W5_FILIAL = %exp:xFilial("SW5")%
EndSql

If SQLAUX->(!Eof() .And. !Bof())        
   lRet := .T.
EndIf
Return lRet

/*
Funcao     : PO400LEG
Parametros : Nenhum
Objetivos  : Fazer legenda
Autor      : igor chiba
Data/Hora  : 26/05/14
*/
*-------------------------*
Function PO400LEG()
*-------------------------*
Local aLegenda:= {}

AAdd(aLegenda, {"BR_VERDE"    , STR0398}) //"Aprovado no ERP"
AAdd(aLegenda, {"BR_VERMELHO" , STR0399}) //"Aguardando Aprovação no ERP."

BrwLegenda(cCadastro, STR0391, aLegenda) //"Legenda"

Return

/*
Funcao     : PO400ALC
Parametros : Nenhum
Objetivos  : Fazer legenda da alçada quando estiver integrado com compra
Autor      : Maurício Frison
Data/Hora  : maio/2020
*/
*-------------------------*
Function PO400ALC()
*-------------------------*
Local aLegenda:= {}

AAdd(aLegenda, {"BR_AZUL"     , STR0422}) //"Bloqueado/Em aprovação"
AAdd(aLegenda, {"BR_VERMELHO" , STR0423}) //"Reprovado"
AAdd(aLegenda, {"BR_VERDE"    , STR0424}) //"Aprovado"
BrwLegenda(cCadastro, STR0391, aLegenda) //"Legenda"

Return
/*
Funcao     : FilPergunte()
Parametros : Nenhum
Retorno    : nOpc
Objetivos  : Quando integrado com o Logix, deverá chamar a nova tela de pergunte
Autor      : Jacomo Lisa
Data/Hora  : 21/05/2014
*/
*------------------------*
Function FilPergunte()
*------------------------*
local n1
Local cMV_Cotacao := EasyGParam("MV_EIC0045",,"3") //Integração com o Logix
Local oUpdPO400
//THTS - 03/08/2017
If FindFunction("UPDX1PO400")
    UPDX1PO400()
EndIf

IF (lPO400FIL := Pergunte("PO400FIL",.T.))
   cCotacao := LEFT(cvaltochar(mv_par01),1)//Devolve 1 ou 2 Numerico OU "1 = Sim","2 = Não" caracter
   cItem    := mv_par02
   TSi_Num  := mv_par03
   TCC      := "99999"
   cAgrSIPO := SI410GtAgp(TSi_Num)
   If PO_ValidCC(.f.) .AND. PO_ValidSI(.f.,,.T.)
      nOpca:=1
   ELSE
      nOpca:=0
   ENDIF
ELSE
   nOpca:=0
EndIf
return nOpca



/*
Funcao     : CadFabSxb
Parametros : Nenhum
Retorno    : .T./.F.
Objetivos  : Quando integrado com o Logix, deverá chamar a nova tela MVC
Autor      : Jacomo Lisa
Data/Hora  : 21/05/2014
*/
*------------------------*
Function CadFabSxb()
*------------------------*
Local cALias  := 'SA5'
Local cFiltro := "LEFT(A2_ID_FBFN,1) $  '1/3' .OR.  A2_FABRICA == '1'"  //IGOR CHIBA 18/07/14 INCLUIR FILTRO
Local aOrd    := SAVEORD({'SA5'})
Local cChvPosSA2 := cChvPosSA5 := cChvPosSB1 := ""
Local cChvPosSA5 := ""
Local lSI410StPO := IsInCallSTack('SI410SetPO')
cChvPosSA2 := If( lSI410StPO ,  xFilial('SA2') + WKSI->W1_FORN + WKSI->W1_FORLOJ  ,  xFilial('SA2')+M->W2_FORN+M->W2_FORLOJ )

DBSELECTAREA('SA2')
SA2->(DBSETORDER(1))
SA2->(DBSEEK(cChvPosSA2/*xFilial('SA2')+M->W2_FORN+M->W2_FORLOJ*/))
cNome  := SA2->A2_NOME

SET FILTER TO &cFiltro
lREt:=ConPad1(,,,'SA2',,)
IF lREt
   SA5->(DbSetOrder(2))
   cChvPosSA5 := If( lSI410StPO , xFilial("SA5")+WKSI->W1_COD_I+WKSI->W1_FORN+WKSI->W1_FORLOJ , xFilial("SA5")+Work->WKCOD_I+M->W2_FORN+EICRetLoja("M","W2_FORLOJ") )
   If SA5->(DbSeek(cChvPosSA5 /*xFilial()+Work->WKCOD_I+M->W2_FORN+EICRetLoja("M","W2_FORLOJ")*/))
      cUM := SA5->A5_UNID
      SA5->(DbSetOrder(3))
      SB1->(DbSetOrder(1))
      cChvPosSB1 := If( lSI410StPO , xFilial("SB1")+WKSI->W1_COD_I , xFilial("SB1")+Work->WKCOD_I )
      SB1->(DBSEEK(cChvPosSB1 /*xFilial()+Work->WKCOD_I*/))
      cChvPosSA5 := If( lSI410StPO , xFilial("SA5")+WKSI->W1_COD_I+SA2->A2_COD+WKSI->W1_FORN , xFilial("SA5")+Work->WKCOD_I+SA2->A2_COD+M->W2_FORN )
      IF !SA5->(DbSeek(cChvPosSA5 /*xFilial("SA5")+Work->WKCOD_I+SA2->A2_COD+M->W2_FORN*/)) //.AND. (SA2->A2_ID_FBFN = '1' .OR. SA2->A2_FABRICA = '1')
         SA5->(RECLOCK("SA5",.T.))
         SA5->A5_FILIAL  := XFILIAL('SA5')

         SA5->A5_FORNECE := If( lSI410StPO , WKSI->W1_FORN   ,M->W2_FORN   )
         SA5->A5_LOJA    := If( lSI410StPO , WKSI->W1_FORLOJ ,M->W2_FORLOJ )
         SA5->A5_NOMEFOR := cNome

         SA5->A5_PRODUTO := If( lSI410StPO , WKSI->W1_COD_I ,Work->WKCOD_I )
         SA5->A5_NOMPROD := SB1->B1_DESC

         SA2->(DBSEEK(xFilial('SA2')+SA2->A2_COD+SA2->A2_LOJA))
         SA5->A5_FABR    := SA2->A2_COD//M->W2_FORN
         SA5->A5_FALOJA  := SA2->A2_LOJA
         SA5->A5_UNID    := cUM
         SA5->(MSUNLOCK())
      ENDIF
   ELSE
      EasyHelp(STR0400) //"Não existe relacionamento entre produto e fornecedor. Cadastre-o primeiro."
   Endif
ENDIF
DBSELECTAREA('SA2')
SET FILTER TO
RestOrd(aOrd,.T.)
DBSELECTAREA(cALias)
RETURN

/*
Funcao     : CriaEvento
Parametros : Nenhum
Objetivos  : Criar o Evento 150 - “DESPESAS PROVISORIAS”
Autor      : Jacomo Lisa
Data/Hora  : 01/07/2014
*/
*---------------------------*
Static Function CriaEvento()
*---------------------------*
EC6->(DBSETORDER(1))//EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC
IF !EC6->(DBSEEK(xFilial("EC6")+"IMPORT"+"150"))
   EC6->(RECLOCK("EC6",.T.))
   EC6->EC6_FILIAL := xFilial("EC6")
   EC6->EC6_TPMODU := "IMPORT"
   EC6->EC6_ID_CAM := "150"
   EC6->EC6_DESC   := "DESPESAS PROVISORIAS"
   EC6->(MSUNLOCK())
ENDIF

RETURN .T.

/*
Funcao     : VerTamSW3
Parametros : Nenhum
Objetivos  : Verificar tamanho do campo para uso da tabela SW3 no FWBrowse
Autor      : WFS
Data/Hora  : 13/08/2014
*/
Static Function VerTamSW3(cCampo)
Local nTamanho:= 10 //default

Begin Sequence

	If SW3->(FieldPos(cCampo)) == 0
		cCampo:= "W3_" + SubStr(cCampo, 3, Len(cCampo))
	EndIf

	If SW3->(FieldPos(cCampo)) > 0
		nTamanho:= AvSx3(cCampo, AV_TAMANHO)
	EndIf

End Sequence

Return nTamanho

/*
Funcao     : PossuiItem
Parametros : Nenhum
Objetivos  : Validar se, na inclusão, o P.O. possui ao menos um item selecionado.
             O retorno da função é usado para impedir que o fornecedor da capa do processo
             seja alterado pelo usuário, ficando divergente da informação do item.
Autor      : WFS
Data/Hora  : 11/09/2014
*/
Static Function PossuiItem()
Local lRet:= .F.

Begin Sequence

   WORK->(DBGoTop())

   While WORK->(!Eof()) .And. !lRet

      If !Empty(WORK->WKFLAGWIN) .And. (M->W2_FORN <> WORK->WKFORN .Or.;
          (!EICLoja() .Or. EICLoja() .And. M->W2_FORLOJ <> WORK->W3_FORLOJ))

         lRet:= .T.
      EndIf

      If lNewTelaSI //wfs mar/2017 - remover o item da work quando o fornecedor é alterado na capa do P.O. Quando o item está marcado, o sistema valida, impedindo a alteração do fornecedor.

         If Empty(WORK->WKFLAGWIN) .And. (M->W2_FORN <> WORK->WKFORN .Or.;
            M->W2_FORLOJ <> WORK->W3_FORLOJ)

            Work->(RecLock("Work", .F.))
            Work->(DBDelete())
            Work->(MsUnlock())
         EndIf

      EndIf

      WORK->(DBSkip())
   EndDo

   WORK->(DBGoTop())

End Sequence

Return lRet

/*
Funcao     : AtuSegQuant
Parametros : Nenhum
Objetivos  : Atualiza a quantidade na segunda unidade de medida
Autor      : WFS
Data/Hora  : 11/09/2014
*/
Static Function AtuSegQuant(lMemoria)
Local aOrd:= SaveOrd({"SA5"})
Default lMemoria:= .F.

Begin Sequence

   If MsgYesNo(STR0401, STR0002) //"Esta operação realizará a atualização da quantidade na segunda unidade de medida, conforme conversão cadastrada para o item/ fornecedor. Deseja prosseguir?"

      SA5->(DBSetOrder(2)) //A5_FILIAL+A5_PRODUTO+A5_FORNECE+A5_LOJA
      SA5->(DBSeek(xFilial() + Work->WKCOD_I + M->W2_FORN + EICRetLoja("M", "W2_FORLOJ")))

      Work->WKUNI    := BUSCA_UM(Work->WKCOD_I+Work->WKFABR+Work->WKFORN,WORK->WKCC+WORK->WKSI_NUM,WORK->W3_FABLOJ,WORK->W3_FORLOJ)
      Work->WKSEGUM  := SA5->A5_UNID
      Work->WKQTSEGUM:= AVTransUnid(Work->WKUNI,Work->WKSEGUM,Work->WKCOD_I,Work->WKQTDE,,,,M->W2_FORN,M->W2_FORLOJ)
      Work->WKFATOR  := Work->WKQTSEGUM/Work->WKQTDE
      Work->WK_ALTEROU:= .T.
      If lMemoria
         M->W3_UM:= Work->WKUNI
         M->W3_QTSEGUM:= Work->WKQTSEGUM
      EndIf

      MsgInfo(STR0402, STR0002) //"Atualização concluída"

   EndIf

End Sequence

RestOrd(aOrd)
Return

/*
Funcao     : PO400Prov
Parametros : Nenhum
Objetivos  : Visualizar as despesas provisórias quando EAI
Autor      : WFS
Data/Hora  :
*/
Function PO400Prov()
Return FI410Prov("PR")
/*

*-------------------------------*
Static Function AjustaSmartHtml()//LGS-28/06/2016
*-------------------------------*
Local i,aOrd := SaveOrd("SX3")
Local aCampos := {"W2_FRETEIN","W2_CONTA20","W2_CONTA40","W2_CON40HC"}

SX3->(DBSetOrder(2))
For i := 1 To Len(aCampos)
  If SX3->(DbSeek(aCampos[i]))
     Reclock("SX3",.F.)
     SX3->X3_TITULO	:= StrTran(SX3->X3_TITULO , "'", "")
     SX3->X3_TITSPA	:= StrTran(SX3->X3_TITSPA , "'", "")
     SX3->X3_TITENG	:= StrTran(SX3->X3_TITENG , "'", "")
     SX3->X3_DESCRIC := StrTran(SX3->X3_DESCRIC, "'", "")
     SX3->X3_DESCSPA := StrTran(SX3->X3_DESCSPA, "'", "")
     SX3->X3_DESCENG	:= StrTran(SX3->X3_DESCENG, "'", "")
     SX3->(MSUnlock())
  EndIF
Next

/*
Funcao     : PO400NumSC()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Retorna numero de SC correspondente
Autor      : Guilherme Fernandes Pilan
Data/Hora  : 18/09/2015 :: 12:00
*/
*----------------------------*
Function PO400NumSC()
*----------------------------*
Local aOrd := SaveOrd("SC1")

SC1->(DbSetOrder(2)) //C1_FILIAL+C1_PRODUTO+C1_NUM+C1_ITEM+C1_FORNECE+C1_LOJA
If SC1->(DbSeek(xFilial("SC1")+SW1->W1_COD_I+SW0->W0_C1_NUM+SW1->W1_POSICAO))
   cNumSC := SW0->W0_C1_NUM
Else
   cNuMSC := ""
EndIf

RestOrd(aOrd,.T.)
Return cNuMSC

/*
Funcao     : PO400RatFrSg()
Parametros : cCampo - Campo da despesa
Retorno    : Nenhum
Objetivos  : Efetua o calculo de rateio de frete e seguro para os itens do PO
Autor      : Guilherme Fernandes Pilan
Data/Hora  : 28/01/2016 :: 13:44
*/
*-------------------------------------------------------------------------------------------------*
Function PO400RatFrSg(nRatFrete,nRatSeguro,nRatInland,nRatDesconto,nRatPacking,nFobTotal,cRatPor,nQtdItens,nRatOutDes)
*-------------------------------------------------------------------------------------------------*
Local nRecno := Work->(Recno())
Local nValorItem := 0
Local oRatFrete, oRatSeguro, oRatInland, oRatDesconto, oRatPacking, oRatOutDes
Local nTotal:= 0
//LRS - 01/09/2016 - Variaveis Default para casos que não tenha na memoria.
Default nRatFrete    := M->W2_FRETEIN,;
        nRatSeguro   := M->W2_SEGURIN,;
        nRatInland   := M->W2_INLAND ,;
        nRatDesconto := M->W2_DESCONT,;
        nRatPacking  := M->W2_PACKING,;
        nFobTotal    := M->W2_FOB_GER,;
        cRatPor      := If(Empty(M->W2_RAT_POR),"2",M->W2_RAT_POR),;
        nQtdItens    := 0,;
        nRatOutDes   := M->W2_OUT_DES

Begin Sequence
   
   Work->(DbGoTop())
   While Work->(!Eof())
      Do Case
         Case cRatPor == "1"  // Peso
            nTotal += Work->WKQTDE*Work->(if(FieldPos("WKPESOL")>0,WKPESOL,WKPESO_L))
         Case cRatPor == "2"  // Preço
            nTotal += Work->WKQTDE*Work->WKPRECO
         Case cRatPor == "3"  // Quantidade
            nTotal += Work->WKQTDE
      EndCase
      Work->(DbSkip())
   EndDo

   if nQtdItens == 0
      nQtdItens := Work->(EasyRecCount())
   endif

   oRatFrete    := EasyRateio():New(nRatFrete   /*M->W2_FRETEIN*/, nTotal, nQtdItens, AvSx3("W3_FRETE", AV_DECIMAL))
   oRatSeguro   := EasyRateio():New(nRatSeguro  /*M->W2_SEGURIN*/, nTotal, nQtdItens, AvSx3("W3_SEGURO", AV_DECIMAL))
   oRatInland   := EasyRateio():New(nRatInland  /*M->W2_INLAND*/ , nTotal, nQtdItens, AvSx3("W3_INLAND", AV_DECIMAL))
   oRatDesconto := EasyRateio():New(nRatDesconto/*M->W2_DESCONT*/, nTotal, nQtdItens, AvSx3("W3_DESCONT", AV_DECIMAL))
   oRatPacking  := EasyRateio():New(nRatPacking /*M->W2_PACKING*/, nTotal, nQtdItens, AvSx3("W3_PACKING", AV_DECIMAL))
   If SW3->(FieldPos("W3_OUT_DES")) > 0
      oRatOutDes  := EasyRateio():New(nRatOutDes /*M->W2_OUT_DES*/, nTotal, nQtdItens, AvSx3("W3_OUT_DES", AV_DECIMAL))
   EndIf

   Work->(DbGoTop())
   Do While Work->(!Eof()) 
      If !Work->WKFLAG
         Work->(DbSkip())
         Loop
      EndIf
      Do Case
         Case cRatPor == "1"  // Peso
            nValorItem := Work->WKQTDE*Work->(if(FieldPos("WKPESOL")>0,WKPESOL,WKPESO_L))
         Case cRatPor == "2"  // Preço
            nValorItem := Work->WKQTDE*Work->WKPRECO
         Case cRatPor == "3"  // Quantidade
            nValorItem := Work->WKQTDE
      EndCase
      
      Work->WKFRETE := oRatFrete:GetItemRateio(nValorItem)
      Work->WKSEGUR := oRatSeguro:GetItemRateio(nValorItem)
      Work->WKINLAN := oRatInland:GetItemRateio(nValorItem)
      Work->WKDESCO := oRatDesconto:GetItemRateio(nValorItem)
      Work->WKPACKI := oRatPacking:GetItemRateio(nValorItem)
      If SW3->(FieldPos("W3_OUT_DES")) > 0
         Work->WKOUTDE := oRatOutDes:GetItemRateio(nValorItem)
      EndIf

      //MFR 16/09/2019      
      //if WORK->(fieldpos("WK_ALTEROU")) > 0
        //    Work->WK_ALTEROU := .T.
      //endif
      /* wfs - verificação implementada para tratar o controle de alçadas quando não há alteração das despesas internacionais.
         No entanto, impede a inclusão de P.O. e a gravação do item quando há alteração apenas dos dados deste.
         Revisada a necessidade de alteração do controle de alçadas, passando a deixar a apuração pelo módulo de compras quando rotina automática
         e retornando de lá o status do pedido 
      //LRS - 31/05/2017
      IF  nRatFrete # SW2->W2_FRETEIN .OR. nRatSeguro # SW2->W2_SEGURIN .OR. nRatInland # SW2->W2_INLAND;
          .OR. nRatDesconto # SW2->W2_DESCONT .OR. nRatPacking  # SW2->W2_PACKING 
          Work->WK_ALTEROU := .T. 
      Else
          Work->WK_ALTEROU := .F. 
      EndIF  */
      If EasyEntryPoint("EICPO400")
          ExecBlock("EICPO400", .F., .F., "PO400RAT_DESPESAS")
      EndIf
      Work->(DbSkip())
   EndDo

End Sequence

Work->(DbGoTo(nRecno))
Return


/*
Funcao     : PO400ValDt
Parametros : cCampo - nome da variável que está em edição
Retorno    : Lógico
Objetivos  : Validar e possibilitar o uso de ponto de entrada na validação dos campos de data de embarque/ entrega
Autor      : wfs
Data/Hora  : fev/2017
*/
Function PO400ValDt(cCampo)
Private lValDatas:= .T.

Begin Sequence

   /* Campos de data:
      dDtEmbarque, dDtEntrega, dParaEmbarque, dParaEntrega */
   cCampo:= Upper(cCampo)

   Do Case
      Case cCampo == "DDTEMBARQUE"
         lValDatas:= AltDatas(dDtEmbarque, "D")

      Case cCampo == "DPARAEMBARQUE"

      Case cCampo == "DDTENTREGA"

      Case cCampo == "DPARAENTREGA"

   EndCase

   If EasyEntryPoint("EICPO400")
      ExecBlock("EICPO400", .F., .F., "VALIDA_DATA_" + cCampo)
   EndIf

End Sequence

Return lValDatas

/*
Funcao     : SaveTempFiles
Parametros :
Retorno    : Lógico
Objetivos  : Verificar se está ativo o controle de reaproveitamento de arquivos temporários - EECCRIATRAB
             Possibilitar centralizar em um único ponto as verificações destas condições.
             Inicialmente o único cenário para o P.O. é a integração EAI ou ponto de entrada, que altera a variável __KeepUsrFiles.
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
Funcao      : UPDX1PO400
Objetivos   : Ajustar o SX1
Autor       : Tiago Henrique Tudisco dos Santos - THTS
Data 	    : 03/08/2017
Obs         :
*/
Static Function UPDX1PO400()
Local cMV_Cotacao := EasyGParam("MV_EIC0045",,"3") //Integração com o Logix
Local xConteudo
Local aPerg400F   := {}

If cMV_Cotacao $ "1/2/3"
   Pergunte("PO400FIL",.F.,,,,, @aPerg400F)
   xConteudo := If(cMV_Cotacao == "1" .Or. cMV_Cotacao == "3", 1, 2)
   
   mv_par01 :=  xConteudo
         
   //Chama a rotina para salvar os parâmetros
   __SaveParam("PO400FIL", aPerg400F)        
EndIf

Return

/*
Funcao      : PO400Perg
Objetivos   : Valida Pergunte PO400FIL
Parâmetros  : cCpo - Pergunta (campo), exemplo: "Cotacao Aprovada ? - mv_ch01"              
Autor       : Ramon Prado
Data 	    : Julho/2021
*/
Function PO400Perg(cPerg, cMvPar)
Local lRet := .T.
Local cMV_Cotacao := EasyGParam("MV_EIC0045",,"3") //Integração com o Logix

If cPerg == "PO400FIL" .And. cMvPar == "01" //refere-se a pergunta 01 do pergunte PO400FIL
   If cMV_Cotacao == "1" .And. mv_par01 <> 1
      EasyHelp("Parametrização do sistema está configurada para aceitar apenas seleção de cotações aprovadas","Atenção","Revise o parâmetro 'MV_EIC0045' para permitir seleção de cotações não aprovadas.")     
      lRet := .F.
   ElseIf cMV_Cotacao == "2" .And. mv_par01 <> 2
      EasyHelp("Parametrização do sistema está configurada para aceitar apenas seleção de cotações não aprovadas","Atenção","Revise o parâmetro 'MV_EIC0045' para permitir seleção de cotações aprovadas.")      
      lRet := .F.
   EndIf      
EndIf

Return lRet

/*
Funcao      : PO400Gatlh
Objetivos   : Execução de gatilho de campos do Purchse Order
Parâmetros  : cCpo - Identificador do campo que dispara o gatilho
              lPergunta - (T) Exibe mensagens/perguntas
Autor       : Nilson César C. Filho - NCF
Data 	    : 12/06/2018
Obs         :
*/
Function PO400Gatlh(cCpo,lPergunta)
Local xRet
Local lSeekSA5    := .F.
Default cCpo      := ReadVar()
Default lPergunta := .T.

If lPoAuto
   lPergunta:= .F.
EndIf
Do Case
   Case cCpo $ "W3_FABR001"
         SA2->(DbSetOrder(1))
         SA2->(DbSeek( xfilial("SA2") + SA5->A5_FABR + SA5->A5_FALOJA ))
         xRet := SA2->A2_LOJA

   Case cCpo $ "W3_FABR002|W3_FABLOJ"
      xRet := M->W3_PRECO
      SA5->(DbSetOrder(1))
      lSeekSA5 := SA5->(DbSeek( xFilial("SA5") + AvKey(M->W2_FORN,"A5_FORNECE") + AvKey(M->W2_FORLOJ,"A5_LOJA") + AvKey(Work->WKCOD_I,"A5_PRODUTO") +  AvKey(M->W3_FABR,"A5_FABR") + AvKey(M->W3_FABLOJ,"A5_FALOJA") ))
      If lSeekSA5 .And. SA5->A5_MOE_US == M->W2_MOEDA .And. M->W3_PRECO <> SA5->A5_VLCOTUS .And. SA5->A5_VLCOTUS <> 0 .And. If( lPergunta, MsgYesNo( STR0419 + M->W2_MOEDA+" "+Alltrim(STR(M->W3_PRECO,AvSx3("W3_PRECO",3),AvSx3("W3_PRECO",4)))+;            //"Deseja sobrepor o preço unitário de "   
                                                                                                                                                     STR0420 + SA5->A5_MOE_US+" "+Alltrim(STR(SA5->A5_VLCOTUS,AvSx3("A5_VLCOTUS",3),AvSx3("A5_VLCOTUS",4)))+; //" com o preço unitário de "
                                                                                                                                                     STR0421 , STR0002) , .F. )                                                                               //" encontrado no cadastro de produto x fornecedor/loja x fabricante/loja ?"
         xRet := SA5->A5_VLCOTUS
         M->W3_PRECO:= xRet                                               
         M->W3_CUSTO:=(M->W3_PRECO*M->W3_QTDE)
         M->W3_FABLOJ:= SA5->A5_FALOJA
      EndIf
      
End Case

Return xRet

/*
Funcao      : Po400CdGat
Parâmetros  : cCpo - Identificador do campo que dispara o gatilho
Objetivos   : Verificar condição de Execução de gatilho de campos do Purchse Order
Autor       : Nilson César C. Filho - NCF
Data 	    : 12/06/2018
Obs         :
*/
Function Po400CdGat(cCpo)
Local lRet := .F.
Default cCpo := ReadVar() 

Do Case  
   Case cCpo == "W3_FABR"
      If !Empty(M->W3_COD_I) .And. !Empty(M->W3_FABLOJ)
         lRet := .T.
      EndIf 
   Case cCpo == "W3_FABLOJ"
      If !Empty(M->W3_COD_I) .And. !Empty(M->W3_FABR)
         lRet := .T.
      EndIf 
End Case  

Return lRet

Static Function GetOrders(oBrowse, lExibeOrd1)
Local aOrdens := {}

Default lExibeOrd1 := .T.

If !INCLUI .And. lExibeOrd1
   aAdd(aOrdens,{/*<Resource (Depreciado)>*/,{|| PO400OrdenaItens(1,nOpcAux), oBrowse:Refresh() }, STR0427 , STR0427 }) //"Posição (PO)"
EndIf
aAdd(aOrdens,{/*<Resource (Depreciado)>*/,{|| PO400OrdenaItens(2,nOpcAux), oBrowse:Refresh() }, STR0428 , STR0428 }) //"Unidade Requisitante + Solicitação de Importação + Produto"
aAdd(aOrdens,{/*<Resource (Depreciado)>*/,{|| PO400OrdenaItens(3,nOpcAux), oBrowse:Refresh() }, STR0429 , STR0429 }) //"Unidade Requisitante + Solicitação de Importação + Sequencia SI"

Return aOrdens

/*
Funcao     : EICRejAlc
Parametros : Chave para posicionamento na tabela sc7
Objetivos  : Tratar registros vindos do controle de açadas do fonte matxalc.prx
             NEste caso usado para atualizar o campo CONAPRO da sw2 de acordo com o que foi selecionado na alçada
             Esta função é chamada pelo fonte matxalc.prx
Autor      : Maurício Frison
Data/Hora  : 07/07/2020
*/
*-------------------------*
Function Po400RejAlc(cChaveRej)
*-------------------------*
Local nOrdSC7:=(SC7->(INDEXORD()))
SC7->(dbSetOrder(1))
SC7->(MsSeek(cChaveRej))
if SC7->(MsSeek(cChaveRej)) .And. !Empty(SC7->C7_PO_EIC)
   SW2->(GetArea())
	SW2->(MsSeek(xFilial("SW2")+SC7->C7_PO_EIC))
	if !SW2->(EOF())
	     RecLock("SW2",.F.)
	     SW2->W2_CONAPRO := SC7->C7_CONAPRO
	     SW2->(MsUnlock())
	EndIf
EndIf
SC7->(DBSETORDER(nOrdSC7))
Return .t.

/*
Funcao     : PO400GNrSI
Parametros : cCtCust - Centro de Custo atual para a SI
Objetivos  : Retornar a próxima numeração de SI que não exista cadastrada para o centro de custo atual.
Autor      : Nilson César
Data/Hora  : 09/04/2021
*/
Static Function PO400GNrSI(cCtCust)

Local cSINr, aOrdSW0, lSIExist := .T.
   aOrdSW0 := SaveOrd("SW0")
   SW0->(DbSetOrder(1))
   Do While lSIExist
      cSINr    := EasyGetMVSeq("MV_SI_NUM")
      lSIExist := SW0->(DbSeek( xFilial("SW0") + cCtCust + cSINr  ))
   EndDo
   RestOrd(aOrdSW0,.T.)

Return cSINr

   
