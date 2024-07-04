#INCLUDE "EDCCO150.CH" 
#INCLUDE "AVERAGE.CH"
#include "TOPCONN.CH"

#define MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)
#define COLUNA_FINAL   (oDlg:nClientWidth-4)/2

#COMMAND E_RESET_AREA => TRB2->(E_EraseArq(cNome, cNome1, cNome2)) ;; 
                         TRB1->(E_EraseArq(cNome3, cNome4, cNome5));;
                         WORK_M2->(E_EraseArq(cNome6)) ;;
                         WORK_M1->(E_EraseArq(cNome7)) ;;
                         WORK2->(E_EraseArq(cNome8))   ;;
                         WORK1->(E_EraseArq(cNome9))   ;;
                         WORK->(E_EraseArq(cNome10))

#COMMAND E_ZAP_AREA =>  TRB2->(avzap())    ;;
                        TRB1->(avzap())    ;;
                        WORK_M2->(avzap()) ;;
                        WORK_M1->(avzap()) ;;
                        WORK2->(avzap())   ;;
                        WORK1->(avzap()) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EDCCO150 ³ Autor ³ Thomaz/Emerson                        ³ ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de AC a Comprovar                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observa‡Æo³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*------------------------*
Function EDCCO150()
*------------------------*
Local cAlias := "ED0", nOpca := 1
Local bOk:={||(nOpca:=1, oDlg:End())}
Local bCancel:={||(nOpca:=0,oDlg:End())}

Private cFilSW3 := xFilial("SW3"), cFilSW5 := xFilial("SW5"), cFilSW8 := xFilial("SW8"), cFilEE9 := xFilial("EE9"),;
        cFilEE8 := xFilial("EE8"), cFilED0 := xFilial("ED0"), cFilED3 := xFilial("ED3"), cFilED4 := xFilial("ED4"),;
        cFilSYT := xFilial("SYT"), cFilSW9 := xFilial("SW9"), cFilSW6 := xFilial("SW6"), cFilSWP := xFilial("SWP"),;
        cFilSA5 := xFilial("SA5"), cFilSB1 := xFilial("SB1"), cFilSY6 := xFilial("SY6"), cFilSW4 := xFilial("SW4"),;
        cFilSW2 := xFilial("SW2"), cFilSA2 := xFilial("SA2"), cFilEEC := xFilial("EEC"), cFilEE7 := xFilial("EE7"),;
        cFilED8 := xFilial("ED8")

//AJP 27/06/2007
Private lMultiFil  := VerSenha(115)  ;
                      .And.  Posicione("SX2",1,"ED1","X2_MODO") == "C" ;
                      .And.  Posicione("SX2",1,"ED2","X2_MODO") == "C" ;
                      .And.  Posicione("SX2",1,"EDD","X2_MODO") == "C" ;
                      .And.  Posicione("SX2",1,"EE9","X2_MODO") == "E" ;
                      .And.  Posicione("SX2",1,"SW8","X2_MODO") == "E" ;
                      .And.  ED1->( FieldPos("ED1_FILORI") ) > 0  ;
                      .And.  ED2->( FieldPos("ED2_FILORI") ) > 0  ;
                      .And.  EDD->( FieldPos("EDD_FILIMP") ) > 0  ;
                      .And.  EDD->( FieldPos("EDD_FILEXP") ) > 0

Private aFil := IIF(lMultiFil,AvgSelectFil(.F.,,"ED0"),{cFilED0}) //AJP 27/06/2007

Private cTit    := STR0001 //"Relatorio de Ato Concessorio a comprovar"
Private cTipoRel, cModoImp, cPicCgc := AVSX3("YT_CGC",6)
Private dDtIni := cTod(""), dDtFim := cTod(""), cTipoPed
Private cNome, cNome1, cNome2, cNome3, cNome4, cNome5, cNome6, cNome7, cNome8, cNome9
Private lExisteWK1 := .F., lExisteWK2 := .F., lTop := .F., cNome10
Private cAliasED3, cAliasED4, cAliasSW3, cAliasSW5, cAliasSW8, cAliasEE8, cAliasEE9
Private nContED4 := 0, nContSW8 := 0, nContSW5 := 0, nContSW3 := 0, nContED3 := 0, nContEE9 := 0, nContEE8 := 0
Private lAbriuSA2, cFilSA2Aux:=cFilSA2
Private cTPRel   := "" // PLB 15/03/06 - Variavel para melhoria de desempenho

#IFDEF TOP
  lTop      := .T.
#ENDIF

lAbriuSA2 := AbreArqExp("SA2",ALLTRIM(EasyGParam("MV_EMPEXP",,"")),ALLTRIM(EasyGParam("MV_FILEXP",,Space(FWSizeFilial()))),cFilSA2Aux) // Abre arq. SA2 de outra Empresa/Filial de acordo com os parametros.
If lAbriuSA2
   cFilSA2Aux := EasyGParam("MV_FILEXP",,Space(FWSizeFilial()))
   If(Empty(Alltrim(cFilSA2Aux)),cFilSA2Aux:=Space(FWSizeFilial()),) //Devido ao parâmetro vir com um espaço apenas
Endif

While .T.

   cModoImp := "3 - Imp./Exp."

   If ! Pergunte("EDCCO1",.T.)
      Return .F.
   EndIf

   cTipoRel := mv_par01
   cTPRel   := Str(cTipoRel,1) //** PLB 15/03/06
   cModoImp := mv_par02
   cTipoPed := Str(mv_par03,1)
   dDtIni   := mv_par04
   dDtFim   := mv_par05

   If nOpca == 1
      If SA150DATAS()
         If Select("TRB2") = 0
            CriaWorks()
         Else
            E_ZAP_AREA
            FechaTop()
         EndIf
         Processa({|| CO150REL() })
      EndIf
   ElseIf nOpca == 0
      Exit
   EndIf

EndDo

dbSelectArea(cAlias)

Return .T.

*--------------------------*
Static Function CriaWorks()
*--------------------------*
aEst_ED4 := {}
AADD(aEst_ED4,{ "ED4_SEQSIS" , AVSX3("ED4_SEQSIS",2) , AVSX3("ED4_SEQSIS",3), AVSX3("ED4_SEQSIS",4) })
AADD(aEst_ED4,{ "ED4_AC"     , AVSX3("ED4_AC",2)     , AVSX3("ED4_AC",3)    , AVSX3("ED4_AC",4) })
AADD(aEst_ED4,{ "ED4_CNPJIM" , AVSX3("YT_CGC",2) , AVSX3("YT_CGC",3), AVSX3("YT_CGC",4) })
AADD(aEst_ED4,{ "ED4_IMPOR"  , AVSX3("YT_NOME",2)    , AVSX3("YT_NOME",3)   , AVSX3("YT_NOME",4) })
AADD(aEst_ED4,{ "ED4_DT_VAL" , AVSX3("ED4_DT_VAL",2) , AVSX3("ED4_DT_VAL",3), AVSX3("ED4_DT_VAL",4) })
AADD(aEst_ED4,{ "ED4_DIAS_R" , "N", 6, 0 } )
AADD(aEst_ED4,{ "ED4_ITEM"   , AVSX3("ED4_ITEM",2)   , AVSX3("ED4_ITEM",3)  , AVSX3("ED4_ITEM",4) })
AADD(aEst_ED4,{ "ED4_UMITEM" , AVSX3("ED4_UMITEM",2) , AVSX3("ED4_UMITEM",3), AVSX3("ED4_UMITEM",4) })
AADD(aEst_ED4,{ "ED4_NCM"    , AVSX3("ED4_NCM",2)    , AVSX3("ED4_NCM",3)   , AVSX3("ED4_NCM",4) })
AADD(aEst_ED4,{ "ED4_UMNCM"  , AVSX3("ED4_UMNCM",2)  , AVSX3("ED4_UMNCM",3) , AVSX3("ED4_UMNCM",4) })
AADD(aEst_ED4,{ "ED4_QT_DI"  , AVSX3("ED4_QT_DI",2)  , AVSX3("ED4_QT_DI",3) , AVSX3("ED4_QT_DI",4) })
AADD(aEst_ED4,{ "ED4_DU_QT"  , AVSX3("ED4_QT_DI",2)  , AVSX3("ED4_QT_DI",3) , AVSX3("ED4_QT_DI",4) })
AADD(aEst_ED4,{ "ED4_SALDO"  , AVSX3("ED4_SNCMLI",2) , AVSX3("ED4_SNCMLI",3), AVSX3("ED4_SNCMLI",4) })
AADD(aEst_ED4,{ "ED4_VL_DI"  , AVSX3("ED4_VL_DI",2)  , AVSX3("ED4_VL_DI",3) , AVSX3("ED4_VL_DI",4) })
AADD(aEst_ED4,{ "ED4_DU_VL"  , AVSX3("ED4_VL_DI",2)  , AVSX3("ED4_VL_DI",3) , AVSX3("ED4_VL_DI",4) })
AADD(aEst_ED4,{ "ED4_VL_LI"  , AVSX3("ED4_VL_LI",2)  , AVSX3("ED4_VL_LI",3) , AVSX3("ED4_VL_LI",4) })
AADD(aEst_ED4,{ "ED4_QT_LI"  , AVSX3("ED4_QT_LI",2)  , AVSX3("ED4_QT_LI",3) , AVSX3("ED4_QT_LI",4) })
AADD(aEst_ED4,{ "ED4_CAMB"   , "C", 1, 0 })
AADD(aEst_ED4,{ "ED4_MEMO"   , "M", 10, 0 })

cNome  := E_CriaTrab(,aEst_ED4,"TRB2",,.F.)
cNome1 := cNome + "1"
cNome2 := cNome + "2"

aEst_ED3 := {}
AADD(aEst_ED3,{ "ED3_SEQSIS"  , AVSX3("ED3_SEQSIS",2), AVSX3("ED3_SEQSIS",3), AVSX3("ED3_SEQSIS",4) })
AADD(aEst_ED3,{ "ED3_AC"      , AVSX3("ED3_AC",2)    , AVSX3("ED3_AC",3)    , AVSX3("ED3_AC",4) })
AADD(aEst_ED3,{ "ED3_CNPJIM"  , AVSX3("YT_CGC",2), AVSX3("YT_CGC",3), AVSX3("YT_CGC",4)})
AADD(aEst_ED3,{ "ED3_IMPOR"   , AVSX3("YT_NOME",2)   , AVSX3("YT_NOME",3)   , AVSX3("YT_NOME",4) })
AADD(aEst_ED3,{ "ED3_DT_VAL"  , AVSX3("ED3_DT_VAL",2), AVSX3("ED3_DT_VAL",3), AVSX3("ED3_DT_VAL",4) })
AADD(aEst_ED3,{ "ED3_DIAS_R"  , "N", 5, 0 })
AADD(aEst_ED3,{ "ED3_PROD"    , AVSX3("ED3_PROD",2)  , AVSX3("ED3_PROD",3)  , AVSX3("ED3_PROD",4) })
AADD(aEst_ED3,{ "ED3_UMPROD"  , AVSX3("ED3_UMPROD",2), AVSX3("ED3_UMPROD",3), AVSX3("ED3_UMPROD",4) })
AADD(aEst_ED3,{ "ED3_NCM"     , AVSX3("ED3_NCM",2)   , AVSX3("ED3_NCM",3)   , AVSX3("ED3_NCM",4) })
AADD(aEst_ED3,{ "ED3_UMNCM"   , AVSX3("ED3_UMNCM",2) , AVSX3("ED3_UMNCM",3) , AVSX3("ED3_UMNCM",4) })
AADD(aEst_ED3,{ "ED3_SALDO"   , AVSX3("ED3_SALDO",2) , AVSX3("ED3_SALDO",3) , AVSX3("ED3_SALDO",4) })
AADD(aEst_ED3,{ "ED3_QTD"     , AVSX3("ED3_QTD",2)   , AVSX3("ED3_QTD",3)   , AVSX3("ED3_QTD",4) })
AADD(aEst_ED3,{ "ED3_DU_QT"   , AVSX3("ED3_QTD",2)   , AVSX3("ED3_QTD",3)   , AVSX3("ED3_QTD",4) })
AADD(aEst_ED3,{ "ED3_SALNCM"  , AVSX3("ED3_SALNCM",2), AVSX3("ED3_SALNCM",3), AVSX3("ED3_SALNCM",4) })
AADD(aEst_ED3,{ "ED3_SAL_CO"  , AVSX3("ED3_SAL_CO",2), AVSX3("ED3_SAL_CO",3), AVSX3("ED3_SAL_CO",4) })
AADD(aEst_ED3,{ "ED3_DU_VL"   , AVSX3("ED3_SAL_CO",2), AVSX3("ED3_SAL_CO",3), AVSX3("ED3_SAL_CO",4) })
AADD(aEst_ED3,{ "ED3_SAL_SE"  , AVSX3("ED3_SAL_SE",2), AVSX3("ED3_SAL_SE",3), AVSX3("ED3_SAL_SE",4) })
AADD(aEst_ED3,{ "ED3_MEMO"    , "M", 10, 0 })

cNome3 := E_CriaTrab(,aEst_ED3,"TRB1",,.F.)
cNome4 := cNome3 + "1"
cNome5 := cNome3 + "2"

aEst_Mov_2 := {}
AADD(aEst_Mov_2,{ "TRB2_DI"     , "C" , 8, 0 })
AADD(aEst_Mov_2,{ "TRB2_HAWB"   , AVSX3("W6_HAWB",2)   , AVSX3("W6_HAWB",3)   , AVSX3("W6_HAWB",4) })
AADD(aEst_Mov_2,{ "TRB2_COD_I"  , AVSX3("W3_COD_I",2)  , AVSX3("W3_COD_I",3)  , AVSX3("W3_COD_I",4) })
AADD(aEst_Mov_2,{ "TRB2_POS"    , AVSX3("W3_POSICAO",2), AVSX3("W3_POSICAO",3), AVSX3("W3_POSICAO",4) })
AADD(aEst_Mov_2,{ "TRB2_QTDE"   , AVSX3("W3_SALDO_Q",2), AVSX3("W3_SALDO_Q",3), AVSX3("W3_SALDO_Q",4) })
AADD(aEst_Mov_2,{ "TRB2_QT_NC"  , AVSX3("W5_QTDE",2)   , AVSX3("W5_QTDE",3)   , AVSX3("W5_QTDE",4) })
AADD(aEst_Mov_2,{ "TRB2_VALOR"  , AVSX3("W5_VL_AC",2)  , AVSX3("W5_VL_AC",3)  , AVSX3("W5_VL_AC",4) })
AADD(aEst_Mov_2,{ "TRB2_CAMB"   , "C", 3, 0 })
AADD(aEst_Mov_2,{ "TRB2_AC"		, AVSX3("ED4_AC",2)		, AVSX3("ED4_AC",3) 	,AVSX3("ED4_AC",4)})		//Ato concessório vinculado
AADD(aEst_Mov_2,{ "TRB2_SEQ"    , AVSX3("ED4_SEQSIS",2)	, AVSX3("ED4_SEQSIS",3) ,AVSX3("ED4_SEQSIS",4)})	//Sequencia do Ato concessório vinculado
AADD(aEst_Mov_2,{ "TRB2_MEMO"   , "M", 10 ,0})
AADD(aEst_Mov_2,{ "TRB2_OBS"    , "C", 60 ,0})

cNome6 := E_CriaTrab(,aEst_Mov_2,"WORK_M2",,.F.)

aEst_Mov_1 := {}
AADD(aEst_Mov_1,{ "TRB1_DI"     , "C",  3, 0 })
AADD(aEst_Mov_1,{ "TRB1_HAWB"   , AVSX3("EE9_PREEMB",2),  AVSX3("EE9_PREEMB",3), AVSX3("EE9_PREEMB",4) })
AADD(aEst_Mov_1,{ "TRB1_COD_I"  , AVSX3("EE9_COD_I",2) ,  AVSX3("EE9_COD_I",3) , AVSX3("EE9_COD_I",4)  })
AADD(aEst_Mov_1,{ "TRB1_POS"    , AVSX3("EE9_SEQUEN",2),  AVSX3("EE9_SEQUEN",3), AVSX3("EE9_SEQUEN",4) })
AADD(aEst_Mov_1,{ "TRB1_QTDE"   , AVSX3("EE9_SLDINI",2),  AVSX3("EE9_SLDINI",3), AVSX3("EE9_SLDINI",4) })
AADD(aEst_Mov_1,{ "TRB1_QT_NC"  , AVSX3("EE9_SLDINI",2),  AVSX3("EE9_SLDINI",3), AVSX3("EE9_SLDINI",4) })
AADD(aEst_Mov_1,{ "TRB1_VALOR"  , AVSX3("EE9_PRCTOT",2),  AVSX3("EE9_PRCTOT",3), AVSX3("EE9_PRCTOT",4) })
AADD(aEst_Mov_1,{ "TRB1_CAMB"   , AVSX3("EEC_COBCAM",2),  AVSX3("EEC_COBCAM",3), AVSX3("EEC_COBCAM",4) })
AADD(aEst_Mov_1,{ "TRB1_MEMO"   , "M", 10 ,0})

cNome7 := E_CriaTrab(,aEst_Mov_1,"WORK_M1",,.F.)

aEst_Ato2 := {}
AADD(aEst_Ato2,{ "WORK2_DI"   , AVSX3("W6_DI_NUM",2),  AVSX3("W6_DI_NUM",3) , AVSX3("W6_DI_NUM",4) })
AADD(aEst_Ato2,{ "WORK2_HAWB" , AVSX3("W6_HAWB",2),    AVSX3("W6_HAWB",3)   , AVSX3("W6_HAWB",4) })
AADD(aEst_Ato2,{ "WORK2_COD"  , AVSX3("W3_COD_I",2),   AVSX3("W3_COD_I",3)  , AVSX3("W3_COD_I",4) })
AADD(aEst_Ato2,{ "WORK2_POS"  , AVSX3("W3_POSICAO",2), AVSX3("W3_POSICAO",3), AVSX3("W3_POSICAO",4) })
AADD(aEst_Ato2,{ "WORK2_QTDE" , AVSX3("W3_SALDO_Q",2), AVSX3("W3_SALDO_Q",3), AVSX3("W3_SALDO_Q",4) })
AADD(aEst_Ato2,{ "WORK2_QTN"  , AVSX3("W5_QTDE",2),    AVSX3("W5_QTDE",3)   , AVSX3("W5_QTDE",4) })
AADD(aEst_Ato2,{ "WORK2_VAL"  , AVSX3("W5_VL_AC",2),   AVSX3("W5_VL_AC",3)  , AVSX3("W5_VL_AC",4) })
AADD(aEst_Ato2,{ "WORK2_IMP"  , AVSX3("W2_IMPORT",2),   AVSX3("W2_IMPORT",3)  , AVSX3("W2_IMPORT",4) })

cNome8 := E_CriaTrab(,aEst_Ato2,"WORK2",,.F.)

aEst_Ato1 := {}
AADD(aEst_Ato1,{ "WORK1_PE"   , "C", 03, 0 })
AADD(aEst_Ato1,{ "WORK1_HAWB" , AVSX3("W6_HAWB",2),    AVSX3("W6_HAWB",3)   , AVSX3("W6_HAWB",4) })
AADD(aEst_Ato1,{ "WORK1_PREE" , AVSX3("EE9_PREEMB",2), AVSX3("EE9_PREEMB",3), AVSX3("EE9_PREEMB",4) })
AADD(aEst_Ato1,{ "WORK1_COD"  , AVSX3("EE9_COD_I",2),  AVSX3("EE9_COD_I",3) , AVSX3("EE9_COD_I",4) })
AADD(aEst_Ato1,{ "WORK1_POS"  , AVSX3("EE9_SEQUEN",2), AVSX3("EE9_SEQUEN",3), AVSX3("EE9_SEQUEN",4) })
AADD(aEst_Ato1,{ "WORK1_QTD"  , AVSX3("EE9_SLDINI",2), AVSX3("EE9_SLDINI",3), AVSX3("EE9_SLDINI",4) })
AADD(aEst_Ato1,{ "WORK1_QTN"  , AVSX3("EE9_SLDINI",2), AVSX3("EE9_SLDINI",3), AVSX3("EE9_SLDINI",4) })
AADD(aEst_Ato1,{ "WORK1_VAL"  , AVSX3("EE9_PRCTOT",2), AVSX3("EE9_PRCTOT",3), AVSX3("EE9_PRCTOT",4) })
AADD(aEst_Ato1,{ "WORK1_EXP"  , AVSX3("EEC_EXPORT",2), AVSX3("EEC_EXPORT",3), AVSX3("EEC_EXPORT",4) })
AADD(aEst_Ato1,{ "WORK1_LOJ"  , AVSX3("EEC_EXLOJA",2), AVSX3("EEC_EXLOJA",3), AVSX3("EEC_EXLOJA",4) })

If(EasyEntryPoint("EDCCO150"),ExecBlock("EDCCO150",.F.,.F.,"ALTERA_ESTRUTURAS"),)

cNome9  := E_CriaTrab(,aEst_Ato1,"WORK1",,.F.)

aWork:= aClone(aEst_ED4)

AADD(aWork,{ "TRB2_DI"     , "C" , 3, 0 })
AADD(aWork,{ "TRB2_HAWB"   , AVSX3("W6_HAWB",2)   , AVSX3("W6_HAWB",3)   , AVSX3("W6_HAWB",4) })
AADD(aWork,{ "TRB2_COD_I"  , AVSX3("W3_COD_I",2)  , AVSX3("W3_COD_I",3)  , AVSX3("W3_COD_I",4) })
AADD(aWork,{ "TRB2_POS"    , AVSX3("EE9_SEQUEN",2), AVSX3("EE9_SEQUEN",3), AVSX3("EE9_SEQUEN",4) })
AADD(aWork,{ "TRB2_QTDE"   , AVSX3("W3_SALDO_Q",2), AVSX3("W3_SALDO_Q",3), AVSX3("W3_SALDO_Q",4) })
AADD(aWork,{ "TRB2_QT_NC"  , AVSX3("W5_QTDE",2)   , AVSX3("W5_QTDE",3)   , AVSX3("W5_QTDE",4) })
AADD(aWork,{ "TRB2_VALOR"  , AVSX3("W5_VL_AC",2)  , AVSX3("W5_VL_AC",3)  , AVSX3("W5_VL_AC",4) })
AADD(aWork,{ "TRB2_CAMB"   , "C", 1, 0 })
AADD(aWork,{ "TRB2_MEMO"   , "M", 10 ,0})
AADD(aWork,{ "TRB2_OBS"    , "C", 60 ,0})
AADD(aWork,{ "TRB2_MODAL"  , AVSX3("ED0_MODAL",2),   9  , 0 })
AADD(aWork,{ "TRB2_PD"     , AVSX3("ED4_PD",2), AVSX3("ED4_PD",3), AVSX3("ED4_PD",4) })

AADD(aWork,{ "WORK2_DI"   , AVSX3("W6_DI_NUM",2),  AVSX3("W6_DI_NUM",3) , AVSX3("W6_DI_NUM",4) })
AADD(aWork,{ "WORK2_HAWB" , AVSX3("W6_HAWB",2),    AVSX3("W6_HAWB",3)   , AVSX3("W6_HAWB",4) })
AADD(aWork,{ "WORK2_COD"  , AVSX3("W3_COD_I",2),   AVSX3("W3_COD_I",3)  , AVSX3("W3_COD_I",4) })
AADD(aWork,{ "WORK2_POS"  , AVSX3("EE9_SEQUEN",2), AVSX3("EE9_SEQUEN",3), AVSX3("EE9_SEQUEN",4) })
AADD(aWork,{ "WORK2_QTDE" , AVSX3("W3_SALDO_Q",2), AVSX3("W3_SALDO_Q",3), AVSX3("W3_SALDO_Q",4) })
AADD(aWork,{ "WORK2_QTN"  , AVSX3("W5_QTDE",2),    AVSX3("W5_QTDE",3)   , AVSX3("W5_QTDE",4) })
AADD(aWork,{ "WORK2_VAL"  , AVSX3("W5_VL_AC",2),   AVSX3("W5_VL_AC",3)  , AVSX3("W5_VL_AC",4) })
AADD(aWork,{ "WORK2_IMP"  , AVSX3("W2_IMPORT",2),  60,0 })
AADD(aWork,{ "WORK2_CGC"  , AVSX3("YT_CGC",2)   ,  AVSX3("YT_CGC",3),   AVSX3("YT_CGC",4) })
AADD(aWork,{ "WORK2_TIPO" , "C"  ,  1,0 })

cNome10 := E_CriaTrab(,aWork,"WORK",,.F.)

IndRegua("TRB2",   cNome+TEOrdBagExt() ,"ED4_AC+ED4_SEQSIS", , ,STR0002)    //"Processando Arquivo Temporario..."
IndRegua("TRB2",   cNome1+TEOrdBagExt(),"ED4_CNPJIM+ED4_ITEM+ED4_CAMB+DTOS(ED4_DT_VAL)", , ,STR0002) //"Processando Arquivo Temporario..."
IndRegua("TRB2",   cNome2+TEOrdBagExt(),"ED4_CNPJIM+ED4_NCM+ED4_ITEM+ED4_CAMB+DTOS(ED4_DT_VAL)", , ,STR0002)	       //"Processando Arquivo Temporario..."

IndRegua("TRB1",   cNome3+TEOrdBagExt(),"ED3_AC+ED3_SEQSIS" , , ,"Processando Arquivo Temporario...")
IndRegua("TRB1",   cNome4+TEOrdBagExt(),"ED3_CNPJIM+ED3_PROD+DTOS(ED3_DT_VAL)", , ,STR0002) //"Processando Arquivo Temporario..."
IndRegua("TRB1",   cNome5+TEOrdBagExt(),"ED3_CNPJIM+ED3_NCM+ED3_PROD+DTOS(ED3_DT_VAL)", , ,STR0002) //"Processando Arquivo Temporario..."

IndRegua("WORK_M2",cNome6+TEOrdBagExt(),"TRB2_COD_I" , , ,STR0002)                                       //"Processando Arquivo Temporario..."
IndRegua("WORK_M1",cNome7+TEOrdBagExt(),"TRB1_COD_I" , , ,STR0002)       //"Processando Arquivo Temporario..."

IndRegua("WORK2",  cNome8+TEOrdBagExt(),"WORK2_COD"  , , ,STR0002)                                 //"Processando Arquivo Temporario..."
IndRegua("WORK1",  cNome9+TEOrdBagExt(),"WORK1_COD"  , , ,STR0002)                              //"Processando Arquivo Temporario..."

IndRegua("WORK",cNome10+TEOrdBagExt(),"ED4_AC" , , ,STR0002)                                       //"Processando Arquivo Temporario..."

DbSelectArea("TRB2")
SET INDEX TO (cNome+TEOrdBagExt()),(cNome1+TEOrdBagExt()),(cNome2+TEOrdBagExt())

DbSelectArea("TRB1")
SET INDEX TO (cNome3+TEOrdBagExt()),(cNome4+TEOrdBagExt()),(cNome5+TEOrdBagExt())

Return

*---------------------------*
STATIC FUNCTION CO150REL()
*---------------------------*
Local cDesc1         := STR0003 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0004 //"de Ato Concessorio a comprovar."
Local cDesc3         := ""
Local cPict          := ""
Local imprime        := .T.
Private titulo       := STR0001 //"Relatorio de Ato Concessorio a comprovar"
Private nLin         := 80
Private Cabec1       := ""
Private Cabec2       := ""
Private cString      := "ED0"
Private CbTxt        := ""
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := "EDCCO150"
Private nTipo        := 18
Private aReturn      := { STR0005, 1, STR0006, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "EDCCO150" // Coloque o nome do arquivo usado para impressao em disco
PRIVATE nPagina      := 0
Private nTotalQtde   := 0, nTotalFob := 0
Private TituloRel
Private cCobCam
Private lImprime     := .F., lEE8Interface := .F., lOpen := .T.

If lTop
   cAliasED3 := "ED3QUERY"
   cAliasED4 := "ED4QUERY"
   cAliasSW3 := "SW3QUERY"
   cAliasSW5 := "SW5QUERY"
   cAliasSW8 := "SW8QUERY"
   cAliasEE8 := "EE8QUERY"
   cAliasEE9 := "EE9QUERY"
   If(EasyEntryPoint("EDCCO150"),ExecBlock("EDCCO150",.F.,.F.,"LER_INTERFACE?"),)
   Processa({|| ContaRegs()}, STR0007) //"Aguarde Contando Registros...."
   Processa({|| GeraQuery()}, STR0008) //"Aguarde Pesquisando Dados...."
Else
   cAliasED3 := "ED3"
   cAliasED4 := "ED4"
   cAliasSW3 := "SW3"
   cAliasSW5 := "SW5"
   cAliasSW8 := "SW8"
   cAliasEE8 := "EE8"
   cAliasEE9 := "EE9"
   If(EasyEntryPoint("EDCCO150"),ExecBlock("EDCCO150",.F.,.F.,"ABRE_ARQ"),)
Endif

If lOpen

   If Str(cModoImp, 1) == "1"
      If !CO150Grv_I()
         Return
      EndIf
   ElseIf Str(cModoImp, 1) == "2"
      If !CO150Grv_E()
         Return
      EndIf
   ElseIf Str(cModoImp, 1) == "3"
      If !CO150Grv_I()
         If !CO150Grv_E()
            Return
         EndIf
      Else
         CO150Grv_E()
      EndIf
   EndIf

/*   If Str(cModoImp, 1) $ "1/3" // Importacao ou Ambos //** PLB 15/03/06 - Substituído pelo If acima
      Processa ({|| CO150Grv_I()})
   Endif   
   If Str(cModoImp,1) $ "2/3"  // Exportacao ou Ambos
      Processa ({|| CO150Grv_E()})
   Endif
*/
   wnrel := SetPrint(cString,Nomeprog,"",titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,Tamanho)

   If nLastKey = 27
      Return
   Endif

   SetDefault(aReturn,cString)

   nTipo := If(aReturn[4]==1,15,18)

   RptStatus({|lEnd| CO150Imprime(wnRel,cString)})
   If(lImprime, EDCCOGERADBF(), )

EndIf

FechaTop()

E_RESET_AREA

Return
*-----------------------------*
STATIC FUNCTION CO150Grv_I()
*-----------------------------*
Local nDiasPrd := EasyGParam("MV_DIASPRD",,180)
Local nQtdAto  := 0
Local cUnid, cMoeda
//LOCAL nCalcQtd := 0, cMensagem, cObserva  ACSJ - 01/12/2004 - Variavel não é usada.
Local nQtdeItem := 0
Local nValorAto := 0
Local nFilInd   := 0 //AJP 27/06/2007
Local lPrim     := .T.

SW4->(DBSETORDER(1))
SYT->(DBSETORDER(1))
ED0->(dbSetOrder(2))
SW9->(dbSetOrder(3))

ProcRegua(If(lTop, nContED4, (cAliasED4)->(EasyRecCount())))
If !lTop
   (cAliasED4)->(dbSetOrder(2))
   (cAliasED4)->(DbSeek(cFilED4,.T.))
Endif

DO While !((cAliasED4)->(EOF())) .And. (cAliasED4)->ED4_FILIAL==cFilED4

	IncProc(STR0009 )                                                //"Lendo Itens a Importar"
	If cTipoPed <> "2" .and. Empty((cAliasED4)->ED4_AC)
	   (cAliasED4)->(DBSKIP())
	   LOOP
	Endif

    If (cAliasED4)->ED4_DT_VAL < dDataBase
       (cAliasED4)->(DBSKIP())
       LOOP
    EndIf

	If cTipoPed == "2" .and. Empty((cAliasED4)->ED4_AC)
	   ED0->(dbSetOrder(1))
	   ED0->(DBSEEK(cFilED0+(cAliasED4)->ED4_PD))
//	   ED0->(dbSetOrder(2))
    Else
   	   ED0->(DBSEEK(cFilED0+(cAliasED4)->ED4_AC))
    EndIf
    SYT->(DbSeek(cFilSYT+ED0->ED0_IMPORT))

    If ED0->ED0_TIPOAC <> "06" .AND. (cAliasED4)->ED4_QT_DI <= 0  //Dif. de Generico
	   (cAliasED4)->(DBSKIP())
	   LOOP
    EndIf

    If ED0->ED0_TIPOAC = "06" .AND. (cAliasED4)->ED4_VL_DI <= 0 
	   (cAliasED4)->(DBSKIP())
	   LOOP
    EndIf 

    TRB2->(DBAPPEND())
    TRB2->ED4_SEQSIS  := (cAliasED4)->ED4_SEQSIS                               // Sequencia
    If !Empty((cAliasED4)->ED4_AC)
       TRB2->ED4_AC   := (cAliasED4)->ED4_AC                                   // Ato Concessorio
    Else
       TRB2->ED4_AC   := (cAliasED4)->ED4_PD                                   // Ato Concessorio
    EndIf
    TRB2->ED4_CNPJIM  := (cAliasED4)->ED4_CNPJIM				               // CNPJ Importador
    TRB2->ED4_IMPOR   := ED0->ED0_IMPORT                                       // Importador
    If !Empty((cAliasED4)->ED4_DT_VAL)
       TRB2->ED4_DT_VAL  := (cAliasED4)->ED4_DT_VAL                            // Data de Validade
    Else
       TRB2->ED4_DT_VAL  := dDataBase + nDiasPrd                               // Data de Validade
    EndIf
    TRB2->ED4_DIAS_R  := If(!Empty((cAliasED4)->ED4_DT_VAL), ((cAliasED4)->ED4_DT_VAL - dDataBase) ,0) // Dias Restantes
    TRB2->ED4_ITEM    := (cAliasED4)->ED4_ITEM                                 // Item
    TRB2->ED4_UMITEM  := (cAliasED4)->ED4_UMITEM                               // Unidade do Item
    TRB2->ED4_NCM     := (cAliasED4)->ED4_NCM 							       // NCM
    TRB2->ED4_UMNCM   := (cAliasED4)->ED4_UMNCM                                // Unidade NCM
    TRB2->ED4_QT_DI   := (cAliasED4)->ED4_QT_DI								   // Qtde DI
    TRB2->ED4_DU_QT   := (cAliasED4)->ED4_QT_DI                                // Dup. Qtde DI
    TRB2->ED4_SALDO   := (cAliasED4)->ED4_SNCMDI                               // Saldo NCM DI
    TRB2->ED4_VL_DI   := (cAliasED4)->ED4_VL_DI                                // Valor DI
    TRB2->ED4_DU_VL   := (cAliasED4)->ED4_VL_DI                                // Dupl. Valor LI   
    TRB2->ED4_VL_LI   := (cAliasED4)->ED4_VL_LI                                // Valor LI   
    TRB2->ED4_QT_LI   := (cAliasED4)->ED4_QT_LI                                // Qtde. LI   
    TRB2->ED4_CAMB    := (cAliasED4)->ED4_CAMB        						   // Cobertura Cambial

    (cAliasED4)->(DBSKIP())
Enddo
  
If cTPRel == "2" .And. TRB2->(EasyRecCount() ) == 0 //** PLB 15/03/06 - Verifica se existe Ato COncessório com Saldo de Itens a Importar
   MsgInfo("Não existem Atos Concessórios com Saldo de Itens a Importar.")
   Return .F.

Else
 For nFilInd :=1 to Len(aFil) //AJP 27/06/2007
   If lMultiFil
      cFilSW3 := aFil[nFilInd]
      cFilSW5 := aFil[nFilInd]
      cFilSW8 := aFil[nFilInd]
      cFilEE9 := aFil[nFilInd]
      cFilEE8 := aFil[nFilInd]
      cFilSW9 := aFil[nFilInd]
      cFilSW6 := aFil[nFilInd]
      cFilSWP := aFil[nFilInd]
      cFilSW4 := aFil[nFilInd]
      cFilSW2 := aFil[nFilInd]
      cFilEEC := aFil[nFilInd]
      cFilEE7 := aFil[nFilInd]
   EndIf      
   SA5->(DBSETORDER(3))
   ProcRegua(If(lTop, nContSW8, (cAliasSW8)->(EasyRecCount())))
   If !lTop
      (cAliasSW8)->(DBSETORDER(5))
      (cAliasSW8)->(DbSeek(cFilSW8+'0000000000001',.T.))          				    
   Endif

   //IF EasyGParam("MV_EDCDIE",,.F.) //Alcir Alves - define se virá dados das DI´s externas  - NOPADO POR AOM - 04/11/10
      ED8->(DBSETORDER(1))
      ED8->(DBSEEK(cFilED8))
      Do While !ED8->(EOF()) .And. ED8->ED8_FILIAL == cFilED8 
         IF !Empty(ED8->ED8_AC)
            GRVWORKMOV("2", "D.I. EXT.", ED8->ED8_DI_NUM, ED8->ED8_COD_I, ED8->ED8_POSDI, ED8->ED8_QTD, ED8->ED8_QTDNCM,ED8->ED8_VALEMB,"",ED8->ED8_AC,ED8->ED8_SEQSIS)
            IF !empty(ED8->ED8_DT_INT)
               WORK_M2->TRB2_OBS  := STR0069 //"D.I. externa vinda da integração"
            ENDIF
         ENDIF
         ED8->(DBSKIP())
      EndDo
   //ENDIF

   // 1.1    
   TRB2->(DBSETORDER(1))
   Do While (cAliasSW8)->(!EOF()) .And. (cAliasSW8)->W8_FILIAL == cFilSW8 .And. !Empty((cAliasSW8)->W8_AC)

      IncProc(STR0010) //"1.1 - Lendo Hawb's"
      SW9->(DbSeek(cFilSW9+(cAliasSW8)->W8_HAWB))                     
      SW6->(DbSeek(cFilSW6+(cAliasSW8)->W8_HAWB))
      ED0->(DBSEEK(cFilED0+TRB2->ED4_AC))

      If Empty(SW6->W6_DI_NUM) .And. TRB2->(DbSeek((cAliasSW8)->W8_AC + (cAliasSW8)->W8_SEQSIS))
         
         If SA5->(DbSeek(cFilSW8+(cAliasSW8)->W8_COD_I))
            cUnid  := SA5->A5_UNID
         Elseif SB1->(DbSeek(cFilSW8+(cAliasSW8)->W8_COD_I))
            cUnid  := SB1->B1_UM
         Endif

         nQtdeItem := If(cUnid = TRB2->ED4_UMITEM, (cAliasSW8)->W8_QTDE, AVTransUnid(cUnid,TRB2->ED4_UMITEM,(cAliasSW8)->W8_COD_I,(cAliasSW8)->W8_QTDE))
         If ED0->ED0_TIPOAC  = "06"   // GENERICO
            TRB2->ED4_DU_VL -= (((cAliasSW8)->W8_PRECO*(cAliasSW8)->W8_QTDE*SW9->W9_TX_FOB)/SW6->W6_TX_US_D)
         Else
            TRB2->ED4_DU_VL -= (((cAliasSW8)->W8_PRECO*(cAliasSW8)->W8_QTDE*SW9->W9_TX_FOB)/SW6->W6_TX_US_D)
            TRB2->ED4_DU_QT -= nQtdeItem
         Endif

         If TRB2->ED4_DU_VL < 0
            TRB2->ED4_DU_VL := 0
         EndIf
      
         If TRB2->ED4_DU_QT < 0
            TRB2->ED4_DU_QT := 0
         EndIf

         If cTPRel == "2" //Str(cTipoRel,1) == "2"
            GRVTRBMEMO("2", (cAliasSW8)->W8_HAWB)
         Else
            GRVWORKMOV("2", "D.I.", (cAliasSW8)->W8_HAWB, (cAliasSW8)->W8_COD_I, (cAliasSW8)->W8_POSICAO, nQtdeItem, If(TRB2->ED4_UMNCM = TRB2->ED4_UMITEM,nQtdeItem, AVTransUnid(TRB2->ED4_UMITEM,TRB2->ED4_UMNCM,(cAliasSW8)->W8_COD_I,nQtdeItem)), (((cAliasSW8)->W8_PRECO*(cAliasSW8)->W8_QTDE*SW9->W9_TX_FOB)/SW6->W6_TX_US_D), TRB2->ED4_CAMB)
            If (cAliasSW8)->W8_FLUXO = "7"
               WORK_M2->TRB2_OBS  := STR0011 //"Produto devera ser anuente, para a apropriacao do AC."
            Endif
        Endif   
      Endif      
      (cAliasSW8)->(DBSKIP())
   Enddo       
       
   SWP->(dbSetOrder(1))
   ProcRegua(If(lTop, nContSW5, (cAliasSW5)->(EasyRecCount())))   //nContSW5
   If !lTop
      (cAliasSW5)->(dbSetOrder(9))
      (cAliasSW5)->(DbSeek(cFilSW5,.T.))
   Endif   

   //1.2    
   DO While !((cAliasSW5)->(Eof())) .And. (cAliasSW5)->W5_FILIAL == cFilSW5 
 
    IncProc(STR0012+(cAliasSW5)->W5_PGI_NUM)  //"1.2 Lendo L.I.'s "
    
    If !Empty((cAliasSW5)->W5_AC) .And. (cAliasSW5)->W5_SALDO_Q > 0 .And. (cAliasSW5)->W5_SEQ = 0
      
      If TRB2->(DbSeek((cAliasSW5)->W5_AC + (cAliasSW5)->W5_SEQSIS))
   
         SWP->(DbSeek(cFilSWP+(cAliasSW5)->W5_PGI_NUM))
         ED0->(DBSEEK(cFilED0+TRB2->ED4_AC))   
         SW4->(DbSeek(cFilSA5+(cAliasSW5)->W5_PGI_NUM)) 
         SW6->(DbSeek(cFilSW6+(cAliasSW5)->W5_HAWB))
      
         If SA5->(DbSeek(cFilSA5+(cAliasSW5)->W5_COD_I))
            cUnid  := SA5->A5_UNID
         Elseif SB1->(DbSeek(cFilSB1+(cAliasSW5)->W5_COD_I))
	        cUnid  := SB1->B1_UM		 	  
         Endif
        
         nQtdeItem  := If(cUnid = TRB2->ED4_UMITEM, (cAliasSW5)->W5_QTDE, AVTransUnid(cUnid,TRB2->ED4_UMITEM,(cAliasSW5)->W5_COD_I,(cAliasSW5)->W5_QTDE))
         cMoeda := SW4->W4_MOEDA

         If ED0->ED0_TIPOAC  = "06"    // GENERICO
            TRB2->ED4_DU_VL -= ConvVal(cMoeda, ((cAliasSW5)->W5_PRECO * nQtdeItem))   
         Else
            TRB2->ED4_DU_VL -= ConvVal(cMoeda, ((cAliasSW5)->W5_PRECO * nQtdeItem))
            TRB2->ED4_DU_QT -= nQtdeItem
         Endif                       

         If TRB2->ED4_DU_VL < 0
            TRB2->ED4_DU_VL := 0
         EndIf
      
         If TRB2->ED4_DU_QT < 0
            TRB2->ED4_DU_QT := 0
         EndIf
            
         If cTPRel == "2" //Str(cTipoRel,1) == "2"
            GrvTRBMEMO("2", (cAliasSW5)->W5_PO_NUM)
         Else           
            GRVWORKMOV("2", "L.I.", (cAliasSW5)->W5_PO_NUM, (cAliasSW5)->W5_COD_I, (cAliasSW5)->W5_POSICAO, nQtdeItem,If(TRB2->ED4_UMNCM = TRB2->ED4_UMITEM,nQtdeItem, AVTransUnid(TRB2->ED4_UMITEM,TRB2->ED4_UMNCM,(cAliasSW5)->W5_COD_I,nQtdeItem)), ConvVal(cMoeda, ((cAliasSW5)->W5_PRECO * nQtdeItem)), TRB2->ED4_CAMB)
            If (cAliasSW5)->W5_FLUXO = "7"
               WORK_M2->TRB2_OBS  := STR0011 //"Produto devera ser anuente, para a apropriacao do AC."
            Endif         
         Endif   
      Endif             
    Else
       If Empty((cAliasSW5)->W5_AC) .And. (cAliasSW5)->W5_SALDO_Q > 0 .And. (cAliasSW5)->W5_SEQ = 0 //.And. !Empty((cAliasSW5)->W5_DT_ENTR)
 
        SW4->(DbSeek(cFilSW4+(cAliasSW5)->W5_PGI_NUM)) 
        SW6->(DbSeek(cFilSW6+(cAliasSW5)->W5_HAWB))
  
        If SA5->(DbSeek(cFilSA5+(cAliasSW5)->W5_COD_I))
           cUnid  := SA5->A5_UNID
        Elseif SB1->(DbSeek(cFilSB1+(cAliasSW5)->W5_COD_I))
           cUnid  := SB1->B1_UM
        Endif
  
        cMoeda     := SW4->W4_MOEDA                                         
        nQtdAto    := (cAliasSW5)->W5_QTDE //(cAliasSW5)->W5_SALDO_Q 
        nValorAto  := ConvVal(cMoeda, ((cAliasSW5)->W5_PRECO * (cAliasSW5)->W5_QTDE))
        lPrim      := .T.
       
        DO While nQtdAto > 0// If(lPrim, (nQtdAto > 0 .Or. nValorAto > 0), (nQtdAto > 0 .And. nValorAto > 0))
   
         lPrim := .F.
         If CO150ApuImp((cAliasSW5)->W5_COD_I, (cAliasSW5)->W5_TEC)
   	  
      	     ED0->(DBSEEK(cFilED0+TRB2->ED4_AC))   
         
            nQtdeItem  := If(cUnid = TRB2->ED4_UMITEM, (cAliasSW5)->W5_QTDE, AVTransUnid(cUnid, TRB2->ED4_UMITEM,(cAliasSW5)->W5_COD_I,(cAliasSW5)->W5_QTDE))
   
            If ED0->ED0_TIPOAC  = "06"    // GENERICO      
               TRB2->ED4_DU_VL -= ConvVal(cMoeda, ((cAliasSW5)->W5_PRECO * nQtdeItem))
               nValorAto  -= TRB2->ED4_DU_VL
            Else
               TRB2->ED4_DU_VL -= ConvVal(cMoeda, ((cAliasSW5)->W5_PRECO * nQtdeItem))
               nValorAto  -= TRB2->ED4_DU_VL
               nQtdAto    -= If(nQtdeItem<TRB2->ED4_DU_QT, (cAliasSW5)->W5_QTDE, AVTransUnid(TRB2->ED4_UMITEM, cUnid, (cAliasSW5)->W5_COD_I,TRB2->ED4_DU_QT))
               TRB2->ED4_DU_QT -= nQtdeItem
            Endif                       

            If TRB2->ED4_DU_QT < 0
               TRB2->ED4_DU_QT := 0
            EndIf      
            If TRB2->ED4_DU_VL < 0
               TRB2->ED4_DU_VL := 0
            EndIf      

            If cTPRel == "2" //Str(cTipoRel,1) == "2"
               GrvTRBMEMO("2", (cAliasSW5)->W5_PO_NUM)
            Else           
               GRVWORKMOV("2", "L.I.", (cAliasSW5)->W5_PO_NUM, (cAliasSW5)->W5_COD_I, (cAliasSW5)->W5_POSICAO, nQtdeItem,If(TRB2->ED4_UMNCM = TRB2->ED4_UMITEM,nQtdeItem, AVTransUnid(TRB2->ED4_UMITEM,TRB2->ED4_UMNCM,(cAliasSW5)->W5_COD_I,nQtdeItem)),ConvVal(cMoeda, ((cAliasSW5)->W5_PRECO * nQtdeItem)), TRB2->ED4_CAMB)
               If (cAliasSW5)->W5_FLUXO = "7"
                  WORK_M2->TRB2_OBS  := STR0011 //"Produto devera ser anuente, para a apropriacao do AC."
               Endif         
            Endif   
         Else
            If cTPRel == "1" //Str(cTipoRel,1) == "1"
               SW2->(dbSeek(cFilSW2+(cAliasSW5)->W5_PO_NUM))
               GRVWORKAC("2", "L.I", (cAliasSW5)->W5_PO_NUM, (cAliasSW5)->W5_COD_I, (cAliasSW5)->W5_POSICAO, nQtdAto,AVTransUnid(cUnid,TRB2->ED4_UMNCM,(cAliasSW5)->W5_COD_I,nQtdAto),nValorAto,SW2->W2_IMPORT)
            Endif   
            Exit
         Endif             
        Enddo                  
       Endif 
 
    Endif  
    (cAliasSW5)->(DBSKIP())
   Enddo         


//** PLB 15/03/06 - Unificado com o While do 1.2
// 1.3
/*ProcRegua(If(lTop, nContSW5, (cAliasSW5)->(EasyRecCount())))
If !lTop    
   (cAliasSW5)->(dbSetOrder(6))
   (cAliasSW5)->(DbSeek(cFilSW5,.T.))
Else
   (cAliasSW5)->(dbGoTop())
Endif   

DO While !((cAliasSW5)->(Eof())) .And. (cAliasSW5)->W5_FILIAL == cFilSW5  
 
 IncProc(STR0013) //"1.3 Lendo L.I.'s"
 If Empty((cAliasSW5)->W5_AC) .And. (cAliasSW5)->W5_SALDO_Q > 0 .And. (cAliasSW5)->W5_SEQ = 0 //.And. !Empty((cAliasSW5)->W5_DT_ENTR)
 
  SW4->(DbSeek(cFilSW4+(cAliasSW5)->W5_PGI_NUM)) 
  SW6->(DbSeek(cFilSW6+(cAliasSW5)->W5_HAWB))
  
  If SA5->(DbSeek(cFilSA5+(cAliasSW5)->W5_COD_I))
     cUnid  := SA5->A5_UNID
  Elseif SB1->(DbSeek(cFilSB1+(cAliasSW5)->W5_COD_I))
	 cUnid  := SB1->B1_UM
  Endif
  
  cMoeda     := SW4->W4_MOEDA                                         
  nQtdAto    := (cAliasSW5)->W5_QTDE //(cAliasSW5)->W5_SALDO_Q 
  nValorAto  := ConvVal(cMoeda, ((cAliasSW5)->W5_PRECO * (cAliasSW5)->W5_QTDE))
  lPrim      := .T.
       
  DO While nQtdAto > 0// If(lPrim, (nQtdAto > 0 .Or. nValorAto > 0), (nQtdAto > 0 .And. nValorAto > 0))
   
   lPrim := .F.    
   If CO150ApuImp((cAliasSW5)->W5_COD_I, (cAliasSW5)->W5_TEC)                    
   	  
   	  ED0->(DBSEEK(cFilED0+TRB2->ED4_AC))   
      
      nQtdeItem  := If(cUnid = TRB2->ED4_UMITEM, (cAliasSW5)->W5_QTDE, AVTransUnid(cUnid, TRB2->ED4_UMITEM,(cAliasSW5)->W5_COD_I,(cAliasSW5)->W5_QTDE))
   
      If ED0->ED0_TIPOAC  = "06"    // GENERICO      
         TRB2->ED4_DU_VL -= ConvVal(cMoeda, ((cAliasSW5)->W5_PRECO * nQtdeItem))
         nValorAto  -= TRB2->ED4_DU_VL
      Else
         TRB2->ED4_DU_VL -= ConvVal(cMoeda, ((cAliasSW5)->W5_PRECO * nQtdeItem))
         nValorAto  -= TRB2->ED4_DU_VL
         nQtdAto    -= If(nQtdeItem<TRB2->ED4_DU_QT, (cAliasSW5)->W5_QTDE, AVTransUnid(TRB2->ED4_UMITEM, cUnid, (cAliasSW5)->W5_COD_I,TRB2->ED4_DU_QT))
         TRB2->ED4_DU_QT -= nQtdeItem
      Endif                       

      If TRB2->ED4_DU_QT < 0
         TRB2->ED4_DU_QT := 0
      EndIf      
      If TRB2->ED4_DU_VL < 0
         TRB2->ED4_DU_VL := 0
      EndIf      

      If cTPRel == "2" //Str(cTipoRel,1) == "2"
         GrvTRBMEMO("2", (cAliasSW5)->W5_PO_NUM)
      Else           
         GRVWORKMOV("2", "L.I.", (cAliasSW5)->W5_PO_NUM, (cAliasSW5)->W5_COD_I, (cAliasSW5)->W5_POSICAO, nQtdeItem,If(TRB2->ED4_UMNCM = TRB2->ED4_UMITEM,nQtdeItem, AVTransUnid(TRB2->ED4_UMITEM,TRB2->ED4_UMNCM,(cAliasSW5)->W5_COD_I,nQtdeItem)),ConvVal(cMoeda, ((cAliasSW5)->W5_PRECO * nQtdeItem)), TRB2->ED4_CAMB)
         If (cAliasSW5)->W5_FLUXO = "7"
            WORK_M2->TRB2_OBS  := STR0011 //"Produto devera ser anuente, para a apropriacao do AC."
         Endif         
      Endif   
   Else
      If cTPRel == "1" //Str(cTipoRel,1) == "1"
         SW2->(dbSeek(cFilSW2+(cAliasSW5)->W5_PO_NUM))
         GRVWORKAC("2", "L.I", (cAliasSW5)->W5_PO_NUM, (cAliasSW5)->W5_COD_I, (cAliasSW5)->W5_POSICAO, nQtdAto,AVTransUnid(cUnid,TRB2->ED4_UMNCM,(cAliasSW5)->W5_COD_I,nQtdAto),nValorAto,SW2->W2_IMPORT)
      Endif   
      Exit
   Endif             
  Enddo                  
 Endif 
 (cAliasSW5)->(DBSKIP())
Enddo                            
*/
/*// 1.5
ProcRegua(If(lTop, nContSW5, (cAliasSW5)->(EasyRecCount())))
If !lTop
   (cAliasSW5)->(DbSeek(cFilSW5,.T.))
Endif   

DO While !((cAliasSW5)->(Eof())) .And. (cAliasSW5)->W5_FILIAL == cFilSW5 

 IncProc(STR0014) //"Lendo L.I.'s"
 If Empty((cAliasSW5)->W5_AC) .And. (cAliasSW5)->W5_SALDO_Q # 0 .And. Empty((cAliasSW5)->W5_DT_ENTR) .And. (cAliasSW5)->W5_SEQ == 0

  SW4->(DbSeek(cFilSW4+(cAliasSW5)->W5_PGI_NUM)) 
  SW6->(DbSeek(cFilSW6+(cAliasSW5)->W5_HAWB))

  If SA5->(DbSeek(cFilSA5+(cAliasSW5)->W5_COD_I))             
     cUnid  := SA5->A5_UNID
  Elseif SB1->(DbSeek(cFilSB1+(cAliasSW5)->W5_COD_I))
	 cUnid  := SB1->B1_UM		 	  
  Endif

  cMoeda  := SW4->W4_MOEDA                                         
  nQtdAto := (cAliasSW5)->W5_QTDE
  nValorAto  := ConvVal(cMoeda, ((cAliasSW5)->W5_PRECO * (cAliasSW5)->W5_QTDE))
  lPrim := .T.

  DO While nQtdAto > 0//If(lPrim, (nQtdAto > 0 .Or. nValorAto > 0), (nQtdAto > 0 .And. nValorAto > 0))   

   lPrim := .F.    
   If CO150ApuImp((cAliasSW5)->W5_COD_I, (cAliasSW5)->W5_TEC)                    

   	  ED0->(DBSEEK(cFilED0+TRB2->ED4_AC))   

      nQtdeItem  := If(cUnid = TRB2->ED4_UMITEM, (cAliasSW5)->W5_QTDE, AVTransUnid(cUnid, TRB2->ED4_UMITEM,(cAliasSW5)->W5_COD_I,(cAliasSW5)->W5_QTDE))

      If ED0->ED0_TIPOAC  = "06"    // GENERICO
         TRB2->ED4_DU_VL -= ConvVal(cMoeda, ((cAliasSW5)->W5_PRECO * nQtdeItem))   
         nValorAto  -= TRB2->ED4_DU_VL
      Else
         TRB2->ED4_DU_VL -= ConvVal(cMoeda, ((cAliasSW5)->W5_PRECO * nQtdeItem))   
         nValorAto  -= TRB2->ED4_DU_VL
         nQtdAto    -= If(nQtdeItem<TRB2->ED4_DU_QT, (cAliasSW5)->W5_QTDE, AVTransUnid(TRB2->ED4_UMITEM, cUnid, (cAliasSW5)->W5_COD_I,TRB2->ED4_DU_QT))
         TRB2->ED4_DU_QT -= nQtdeItem
      Endif                       

      If TRB2->ED4_DU_QT < 0
         TRB2->ED4_DU_QT := 0
      EndIf      
      If TRB2->ED4_DU_VL < 0
         TRB2->ED4_DU_VL := 0
      EndIf      

      If Str(cTipoRel,1) == "2"
         GrvTRBMEMO("2", (cAliasSW5)->W5_PO_NUM)
      Else           
         GRVWORKMOV("2", "L.I.", (cAliasSW5)->W5_PO_NUM, (cAliasSW5)->W5_COD_I, (cAliasSW5)->W5_POSICAO, nQtdeItem,If(TRB2->ED4_UMNCM = TRB2->ED4_UMITEM,nQtdeItem, AVTransUnid(TRB2->ED4_UMITEM,TRB2->ED4_UMNCM,(cAliasSW5)->W5_COD_I,nQtdeItem)), ConvVal(cMoeda, ((cAliasSW5)->W5_PRECO * nQtdeItem)), TRB2->ED4_CAMB)
         If (cAliasSW5)->W5_FLUXO = "7"
            WORK_M2->TRB2_OBS  := STR0011 //"Produto devera ser anuente, para a apropriacao do AC."
         Endif         
      Endif   
   Else
      If Str(cTipoRel,1) == "1"
         SW2->(dbSeek(cFilSW2+(cAliasSW5)->W5_PO_NUM))
         GRVWORKAC("2", "L.I.", (cAliasSW5)->W5_PO_NUM, (cAliasSW5)->W5_COD_I, (cAliasSW5)->W5_POSICAO,nQtdAto,AVTransUnid(cUnid,TRB2->ED4_UMNCM,(cAliasSW5)->W5_COD_I,nQtdAto), nValorAto,SW2->W2_IMPORT )
       Endif                                                                                                      
       Exit
   Endif             
  Enddo                  
 Endif 
 (cAliasSW5)->(DBSKIP())
Enddo */

   // 1.4 
   ProcRegua(If(lTop, nContSW3, (cAliasSW3)->(EasyRecCount())))
   If !lTop
      (cAliasSW3)->(dbSetOrder(6))
      (cAliasSW3)->(DbSeek(cFilSW3,.T.))
   Endif   

   DO While !((cAliasSW3)->(Eof())) .And. (cAliasSW3)->W3_FILIAL == cFilSW3 .And. (cAliasSW3)->W3_SEQ = 0

    IncProc(STR0015) //"1.4 - Lendo P.O.'s"

    If (cAliasSW3)->W3_SALDO_Q > 0 //.And. !Empty((cAliasSW3)->W3_DT_ENTR)

      SW4->(DbSeek(cFilSW4+(cAliasSW3)->W3_PGI_NUM)) 

      If SA5->(DbSeek(cFilSA5+(cAliasSW3)->W3_COD_I))             
        cUnid  := SA5->A5_UNID
      Elseif SB1->(DbSeek(cFilSB1+(cAliasSW3)->W3_COD_I))
        cUnid  := SB1->B1_UM		 	  
      Endif

      cMoeda  := SW4->W4_MOEDA                                         
      nQtdAto := (cAliasSW3)->W3_QTDE
      nValorAto  := ConvVal(cMoeda, ((cAliasSW3)->W3_PRECO * (cAliasSW3)->W3_QTDE))
      lPrim   := .T.

      DO While nQtdAto > 0//If(lPrim, (nQtdAto > 0 .Or. nValorAto > 0), (nQtdAto > 0 .And. nValorAto > 0))   

         lPrim := .F.
         If CO150ApuImp((cAliasSW3)->W3_COD_I, (cAliasSW3)->W3_TEC)

            ED0->(DBSEEK(cFilED0+TRB2->ED4_AC))   

            nQtdeItem  := If(cUnid = TRB2->ED4_UMITEM, (cAliasSW3)->W3_QTDE, AVTransUnid(cUnid, TRB2->ED4_UMITEM,(cAliasSW3)->W3_COD_I,(cAliasSW3)->W3_QTDE))

            If ED0->ED0_TIPOAC  = "06"    // GENERICO
               TRB2->ED4_DU_VL -= ConvVal(cMoeda, ((cAliasSW3)->W3_PRECO * nQtdeItem))   
               nValorAto  -= TRB2->ED4_DU_VL
            Else
               TRB2->ED4_DU_VL -= ConvVal(cMoeda, ((cAliasSW3)->W3_PRECO * nQtdeItem))   
               nValorAto  -= TRB2->ED4_DU_VL
               nQtdAto    -= If(nQtdeItem<TRB2->ED4_DU_QT, (cAliasSW3)->W3_QTDE, AVTransUnid(TRB2->ED4_UMITEM, cUnid, (cAliasSW3)->W3_COD_I,TRB2->ED4_DU_QT))
               TRB2->ED4_DU_QT -= nQtdeItem
            Endif                       

            If TRB2->ED4_DU_QT < 0
               TRB2->ED4_DU_QT := 0
            EndIf      
            If TRB2->ED4_DU_VL < 0
               TRB2->ED4_DU_VL := 0
            EndIf      
   
            If cTPRel == "2" //Str(cTipoRel,1) == "2"
               GrvTRBMEMO("2", (cAliasSW3)->W3_PO_NUM)
            Else  
               GRVWORKMOV("2", "P.O.", (cAliasSW3)->W3_PO_NUM, (cAliasSW3)->W3_COD_I, (cAliasSW3)->W3_POSICAO, nQtdeItem,If(TRB2->ED4_UMNCM = TRB2->ED4_UMITEM,nQtdeItem, AVTransUnid(TRB2->ED4_UMITEM,TRB2->ED4_UMNCM,(cAliasSW3)->W3_COD_I,nQtdeItem)), ConvVal(cMoeda, ((cAliasSW3)->W3_PRECO * nQtdeItem)), TRB2->ED4_CAMB)
               If (cAliasSW3)->W3_FLUXO = "7"
                  WORK_M2->TRB2_OBS  := STR0011 //"Produto devera ser anuente, para a apropriacao do AC."
               Endif         
            Endif   
         Else
            If cTPRel == "1" //Str(cTipoRel,1) == "1"
               SW2->(dbSeek(cFilSW2+(cAliasSW3)->W3_PO_NUM))
               GRVWORKAC("2", "P.O.", (cAliasSW3)->W3_PO_NUM, (cAliasSW3)->W3_COD_I, (cAliasSW3)->W3_POSICAO,nQtdAto,AVTransUnid(cUnid,TRB2->ED4_UMNCM,(cAliasSW3)->W3_COD_I,nQtdAto), nValorAto,SW2->W2_IMPORT )
            Endif   
            Exit
         Endif             
      Enddo         
    Endif  
    (cAliasSW3)->(DBSKIP())
   Enddo      

/*// 1.5    
ProcRegua(If(lTop, nContSW3, (cAliasSW3)->(EasyRecCount())))
If !lTop
   (cAliasSW3)->(DbSeek(cFilSW3,.T.))
Endif   

DO While !((cAliasSW3)->(Eof())) .And. (cAliasSW3)->W3_FILIAL == cFilSW3 .And. (cAliasSW3)->W3_SEQ == 0			

 IncProc(STR0015) //"Lendo P.O.'s"

 If (cAliasSW3)->W3_SALDO_Q # 0 .And. Empty((cAliasSW3)->W3_DT_ENTR)  

   SW4->(DbSeek(cFilSW4+(cAliasSW3)->W3_PGI_NUM)) 

   If SA5->(DbSeek(cFilSA5+(cAliasSW3)->W3_COD_I))             
     cUnid  := SA5->A5_UNID
   Elseif SB1->(DbSeek(cFilSB1+(cAliasSW3)->W3_COD_I))
	 cUnid  := SB1->B1_UM		 	  
   Endif

   cMoeda  := SW4->W4_MOEDA                                         
   nQtdAto := (cAliasSW3)->W3_QTDE
   nValorAto  := ConvVal(cMoeda, ((cAliasSW3)->W3_PRECO * (cAliasSW3)->W3_QTDE))
   lPrim   := .T.

   DO While nQtdAto > 0 //If(lPrim, (nQtdAto > 0 .Or. nValorAto > 0), (nQtdAto > 0 .And. nValorAto > 0))   

      lPrim := .F.
      If CO150ApuImp((cAliasSW3)->W3_COD_I, (cAliasSW3)->W3_TEC)

         ED0->(DBSEEK(cFilED0+TRB2->ED4_AC))   

         nQtdeItem  := If(cUnid = TRB2->ED4_UMITEM, (cAliasSW3)->W3_QTDE, AVTransUnid(cUnid, TRB2->ED4_UMITEM,(cAliasSW3)->W3_COD_I,(cAliasSW3)->W3_QTDE))

         If ED0->ED0_TIPOAC  = "06"    // GENERICO
            TRB2->ED4_DU_VL -= ConvVal(cMoeda, ((cAliasSW3)->W3_PRECO * nQtdeItem))   
            nValorAto -= TRB2->ED4_DU_VL
         Else
            TRB2->ED4_DU_VL -= ConvVal(cMoeda, ((cAliasSW3)->W3_PRECO * nQtdeItem))   
            nValorAto -= TRB2->ED4_DU_VL
            nQtdAto    -= If(nQtdeItem<TRB2->ED4_DU_QT, (cAliasSW3)->W3_QTDE, AVTransUnid(TRB2->ED4_UMITEM, cUnid, (cAliasSW3)->W3_COD_I,TRB2->ED4_DU_QT))
            TRB2->ED4_DU_QT -= nQtdeItem
         Endif                       

         If TRB2->ED4_DU_QT < 0
            TRB2->ED4_DU_QT := 0
         EndIf      
         If TRB2->ED4_DU_VL < 0
            TRB2->ED4_DU_VL := 0
         EndIf      

         If Str(cTipoRel,1) == "2"
            GrvTRBMEMO("2", (cAliasSW3)->W3_PO_NUM)
         Else  
            GRVWORKMOV("2", "P.O.", (cAliasSW3)->W3_PO_NUM, (cAliasSW3)->W3_COD_I, (cAliasSW3)->W3_POSICAO, nQtdeItem,If(TRB2->ED4_UMNCM = TRB2->ED4_UMITEM,nQtdeItem, AVTransUnid(TRB2->ED4_UMITEM,TRB2->ED4_UMNCM,(cAliasSW3)->W3_COD_I,nQtdeItem)),ConvVal(cMoeda, ((cAliasSW3)->W3_PRECO * nQtdeItem)), TRB2->ED4_CAMB)
            If (cAliasSW3)->W3_FLUXO = "7"
               WORK_M2->TRB2_OBS  := STR0011 //"Produto devera ser anuente, para a apropriacao do AC."
            Endif         
         Endif   
      Else
         If Str(cTipoRel,1) == "1"
            SW2->(dbSeek(cFilSW2+(cAliasSW3)->W3_PO_NUM))
            GRVWORKAC("2", "P.O.", (cAliasSW3)->W3_PO_NUM, (cAliasSW3)->W3_COD_I, (cAliasSW3)->W3_POSICAO,nQtdAto,AVTransUnid(cUnid,TRB2->ED4_UMNCM,(cAliasSW3)->W3_COD_I,nQtdAto), nValorAto,SW2->W2_IMPORT)
         Endif   
         Exit
      Endif             
   Enddo         
 Endif  
 (cAliasSW3)->(DBSKIP())
Enddo */
 Next
EndIf

Return .T.
*-----------------------------*
STATIC FUNCTION CO150Grv_E()
*-----------------------------* 
Local nQtdAto  := 0   
Local cUnid         
// LOCAL cMensagem, cObserva, nCalcQtd := 0 ACSJ - 01/12/2004 - Variavel não é usada
Local lPrim    := .T.
Private cForn_Exp, cAuxEx, cAuxLo

ProcRegua(If(lTop, nContED3, (cAliasED3)->(EasyRecCount())))
If !lTop
   (cAliasED3)->(dbSetOrder(4))
   (cAliasED3)->(DbSeek(cFilED3,.T.))
Endif   

// Exportacao                                
DO While !((cAliasED3)->(EOF())) .And. (cAliasED3)->ED3_FILIAL==cFilED3

    IncProc(STR0016)                                       //"Lendo Itens a Exportar"
    If cTipoPed <> "2" .and. Empty((cAliasED3)->ED3_AC)
       (cAliasED3)->(DBSKIP())
       LOOP
    Endif	

    If (cAliasED3)->ED3_DT_VAL < dDataBase
       (cAliasED3)->(DBSKIP())
       LOOP
    EndIf

	If cTipoPed == "2" .and. Empty((cAliasED3)->ED3_AC)
	   ED0->(dbSetOrder(1))
	   ED0->(DBSEEK(cFilED0+(cAliasED3)->ED3_PD))
//	   ED0->(dbSetOrder(2))
    Else
   	   ED0->(DBSEEK(cFilED0+(cAliasED3)->ED3_AC))
   	EndIf
	SYT->(DbSeek(cFilSYT+ED0->ED0_IMPORT))		

	If ED0->ED0_TIPOAC <> "06" .AND. (cAliasED3)->ED3_QTD  = 0 //Dif. de Generico
	   (cAliasED3)->(DBSKIP())
	   LOOP
	EndIf

    If ED0->ED0_TIPOAC = "06" .AND. (cAliasED3)->ED3_SAL_CO = 0 //Dif. de Generico
	   (cAliasED3)->(DBSKIP())
	   LOOP
	EndIf 	           

    TRB1->(DBAPPEND())
    TRB1->ED3_SEQSIS  := (cAliasED3)->ED3_SEQSIS                                 //Sequencia
    If !Empty((cAliasED3)->ED3_AC)
       TRB1->ED3_AC   := (cAliasED3)->ED3_AC                                     //Ato Concessorio
    Else
       TRB1->ED3_AC   := (cAliasED3)->ED3_PD                                     //Ato Concessorio
    EndIf
    TRB1->ED3_CNPJIM  := (cAliasED3)->ED3_CNPJIM                                 //CNPJ do Importador
    TRB1->ED3_IMPOR   := ED0->ED0_IMPORT                                         //Importador
    If !Empty((cAliasED3)->ED3_DT_VAL)
       TRB1->ED3_DT_VAL  := (cAliasED3)->ED3_DT_VAL                              //Data de Validade
    Else
       TRB1->ED3_DT_VAL  := dDataBase + nDiasPrd                                 // Data de Validade
    EndIf
    TRB1->ED3_DIAS_R  := If(!Empty((cAliasED3)->ED3_DT_VAL), ((cAliasED3)->ED3_DT_VAL - dDataBase),0) //Dias Restantes
    TRB1->ED3_PROD    := (cAliasED3)->ED3_PROD                                   //Produto
    TRB1->ED3_UMPROD  := (cAliasED3)->ED3_UMPROD                                 //Unidade do Produto
    TRB1->ED3_NCM     := (cAliasED3)->ED3_NCM       							 //NCM
    TRB1->ED3_UMNCM   := (cAliasED3)->ED3_UMNCM                                  //Unidade da NCM
    TRB1->ED3_SALDO   := (cAliasED3)->ED3_SALDO    								 //Saldo do Produto
    TRB1->ED3_DU_QT   := (cAliasED3)->ED3_SALDO       						     //Dupl. Saldo Qtde
    TRB1->ED3_QTD     := (cAliasED3)->ED3_QTD              						 //Qtde 
    TRB1->ED3_SAL_CO  := (cAliasED3)->ED3_SAL_CO  								 //Saldo com Cobertura
    TRB1->ED3_DU_VL   := (cAliasED3)->ED3_SAL_CO  								 //Dupl. Saldo
    TRB1->ED3_SALNCM  := (cAliasED3)->ED3_SALNCM   								 //Saldo NCM
    TRB1->ED3_SAL_SE  := (cAliasED3)->ED3_SAL_SE  								 //Saldo sem Cobertura
    (cAliasED3)->(DBSKIP())
Enddo

If cTPRel == "2" .And. TRB1->(EasyRecCount() ) == 0 //** PLB 15/03/06 - Verifica se existem Atos Concessórios com Saldo de Produtos a Exportar
   MsgInfo("Não existem Atos Concessórios com Saldo de Produtos a Exportar.")
   Return .F.
Else

//2.1                   
   ProcRegua(If(lTop, nContEE9, (cAliasEE9)->(EasyRecCount())))
/*
If !lTop
   (cAliasEE9)->(dbSetOrder(10))
   (cAliasEE9)->(DbSeek(cFilEE9+'0000000000001',.T.))
Endif   

//2.2
If !lTop
   (cAliasEE9)->(DbSeek(cFilEE9,.T.))
Else
   (cAliasEE9)->(dbGoTop())
Endif   
*/

   Do While (cAliasEE9)->(!EOF()) .And. (cAliasEE9)->EE9_FILIAL == cFilEE9 

      IncProc("2.1 - "+STR0017) //"2.1 - Lendo Itens de Embarque"

      If !Empty((cAliasEE9)->EE9_ATOCON) .And. (cAliasEE9)->EE9_STATUS # "*" .And. Empty((cAliasEE9)->EE9_RE) .And. TRB1->(DbSeek((cAliasEE9)->EE9_ATOCON+(cAliasEE9)->EE9_SEQUEN))

         cUnid  := (cAliasEE9)->EE9_UNIDAD

         ED0->(DBSEEK(cFilED0+TRB1->ED3_AC))

         nQtdeItem := If(cUnid = TRB1->ED3_UMPROD, (cAliasEE9)->EE9_SLDINI, AVTransUnid(cUnid,TRB1->ED3_UMPROD,(cAliasEE9)->EE9_COD_I,(cAliasEE9)->EE9_SLDINI))
         TRB1->ED3_DU_QT -= nQtdeItem
         If TRB1->ED3_DU_QT < 0
            TRB1->ED3_DU_QT := 0
         EndIf

         GrvTRBMEMO("1", (cAliasEE9)->EE9_PREEMB)
         GRVWORKMOV("1", "EMB", (cAliasEE9)->EE9_PREEMB, (cAliasEE9)->EE9_COD_I, (cAliasEE9)->EE9_SEQEMB, nQtdeItem, If(TRB1->ED3_UMPROD = TRB1->ED3_UMNCM, nQtdeItem, AVTransUnid(TRB1->ED3_UMPROD, TRB1->ED3_UMNCM,(cAliasEE9)->EE9_COD_I,nQtdeItem)) , TRB1->ED3_DU_VL )

      ElseIf Empty((cAliasEE9)->EE9_ATOCON) .And. (cAliasEE9)->EE9_STATUS #  "*" .And. Empty((cAliasEE9)->EE9_RE)
   
         cUnid   := (cAliasEE9)->EE9_UNIDAD   
         nQtdAto := (cAliasEE9)->EE9_SLDINI
         nValorAto  := (cAliasEE9)->EE9_PRCTOT
         lPrim   := .T.

         Do While nQtdAto > 0    //If(lPrim, (nQtdAto > 0 .Or. nValorAto > 0), (nQtdAto > 0 .And. nValorAto > 0))   

            lPrim := .F.
            If CO150ApuExp((cAliasEE9)->EE9_COD_I, (cAliasEE9)->EE9_POSIPI, (cAliasEE9)->EE9_FORN, (cAliasEE9)->EE9_FOLOJA)
   
               nQtdeItem  := If(cUnid = TRB1->ED3_UMPROD, (cAliasEE9)->EE9_SLDINI, AVTransUnid(cUnid, TRB1->ED3_UMPROD,(cAliasEE9)->EE9_COD_I,(cAliasEE9)->EE9_SLDINI))

               ED0->(DBSEEK(cFilED0+TRB1->ED3_AC))   

               TRB1->ED3_DU_QT -= nQtdeItem
               nQtdAto -= (cAliasEE9)->EE9_SLDINI

               If TRB1->ED3_DU_QT < 0
                  TRB1->ED3_DU_QT := 0
               EndIf

               GrvTRBMEMO("1", (cAliasEE9)->EE9_PREEMB)
               GRVWORKMOV("1", "EMB", (cAliasEE9)->EE9_PREEMB, (cAliasEE9)->EE9_COD_I, (cAliasEE9)->EE9_SEQEMB, nQtdeItem, If(TRB1->ED3_UMPROD = TRB1->ED3_UMNCM, nQtdeItem, AVTransUnid(TRB1->ED3_UMPROD, TRB1->ED3_UMNCM,(cAliasEE9)->EE9_COD_I,nQtdeItem)) , TRB1->ED3_DU_VL )
            Else               
              If cTPRel == "1" //Str(cTipoRel,1) == "1"
                 EEC->(dbSeek(cFilEEC+(cAliasEE9)->EE9_PREEMB))
                 If !Empty(EEC->EEC_EXPORT)
                    cAuxEx := EEC->EEC_EXPORT
                    cAuxLo := EEC->EEC_EXLOJA
                 Else
                    cAuxEx := (cAliasEE9)->EE9_FORN
                    cAuxLo := (cAliasEE9)->EE9_FOLOJA
                 EndIf
                 GRVWORKAC("1", "EMB", (cAliasEE9)->EE9_PREEMB, (cAliasEE9)->EE9_COD_I, (cAliasEE9)->EE9_SEQEMB,nQtdAto,AVTransUnid(cUnid,TRB1->ED3_UMNCM,(cAliasEE9)->EE9_COD_I,nQtdAto), nValorAto,cAuxEx,cAuxLo)
              Endif                  
              Exit
            Endif                    
         Enddo   
      Endif   
      (cAliasEE9)->(DBSKIP())
   Enddo            

//** PLB 15/03/06 - 2.2 foi incluído no While do 2.1
//2.2    
/*ProcRegua(If(lTop, nContEE9, (cAliasEE9)->(EasyRecCount())))
If !lTop
   (cAliasEE9)->(DbSeek(cFilEE9,.T.))
Else
   (cAliasEE9)->(dbGoTop())
Endif   

Do While (cAliasEE9)->(!EOF()) .And. (cAliasEE9)->EE9_FILIAL == cFilEE9  

   IncProc("2.2 - "+STR0017) //"2.2 - Lendo Itens de Embarque"

   If Empty((cAliasEE9)->EE9_ATOCON) .And. (cAliasEE9)->EE9_STATUS #  "*" .And. Empty((cAliasEE9)->EE9_RE)

      cUnid   := (cAliasEE9)->EE9_UNIDAD   
      nQtdAto := (cAliasEE9)->EE9_SLDINI
      nValorAto  := (cAliasEE9)->EE9_PRCTOT
      lPrim   := .T.

      Do While nQtdAto > 0    //If(lPrim, (nQtdAto > 0 .Or. nValorAto > 0), (nQtdAto > 0 .And. nValorAto > 0))   

         lPrim := .F.
         If CO150ApuExp((cAliasEE9)->EE9_COD_I, (cAliasEE9)->EE9_POSIPI, (cAliasEE9)->EE9_FORN, (cAliasEE9)->EE9_FOLOJA)

            nQtdeItem  := If(cUnid = TRB1->ED3_UMPROD, (cAliasEE9)->EE9_SLDINI, AVTransUnid(cUnid, TRB1->ED3_UMPROD,(cAliasEE9)->EE9_COD_I,(cAliasEE9)->EE9_SLDINI))

            ED0->(DBSEEK(cFilED0+TRB1->ED3_AC))   

            TRB1->ED3_DU_QT -= nQtdeItem
            nQtdAto -= (cAliasEE9)->EE9_SLDINI

            If TRB1->ED3_DU_QT < 0
               TRB1->ED3_DU_QT := 0
            EndIf

            GrvTRBMEMO("1", (cAliasEE9)->EE9_PREEMB)
            GRVWORKMOV("1", "EMB", (cAliasEE9)->EE9_PREEMB, (cAliasEE9)->EE9_COD_I, (cAliasEE9)->EE9_SEQEMB, nQtdeItem, If(TRB1->ED3_UMPROD = TRB1->ED3_UMNCM, nQtdeItem, AVTransUnid(TRB1->ED3_UMPROD, TRB1->ED3_UMNCM,(cAliasEE9)->EE9_COD_I,nQtdeItem)) , TRB1->ED3_DU_VL )
         Else               
           If cTPRel == "1" //Str(cTipoRel,1) == "1"
              EEC->(dbSeek(cFilEEC+(cAliasEE9)->EE9_PREEMB))
              If !Empty(EEC->EEC_EXPORT)
                 cAuxEx := EEC->EEC_EXPORT
                 cAuxLo := EEC->EEC_EXLOJA
              Else
                 cAuxEx := (cAliasEE9)->EE9_FORN
                 cAuxLo := (cAliasEE9)->EE9_FOLOJA
              EndIf
              GRVWORKAC("1", "EMB", (cAliasEE9)->EE9_PREEMB, (cAliasEE9)->EE9_COD_I, (cAliasEE9)->EE9_SEQEMB,nQtdAto,AVTransUnid(cUnid,TRB1->ED3_UMNCM,(cAliasEE9)->EE9_COD_I,nQtdAto), nValorAto,cAuxEx,cAuxLo)
           Endif                  
           Exit
         Endif                    
      Enddo   
   Endif   
   (cAliasEE9)->(DBSKIP())
Enddo            
*/
//2.3
   ProcRegua(If(lTop, nContEE8, (cAliasEE8)->(EasyRecCount())))
   If !lTop
      (cAliasEE8)->(DbSeek(cFilEE8,.T.))
   Endif   

   Do While (cAliasEE8)->(!EOF()) .And. (cAliasEE8)->EE8_FILIAL == cFilEE8
 
    IncProc(STR0018) //"2.3 - Lendo Itens do Processo de Exportacao"
    If (cAliasEE8)->EE8_SLDINI > 0 .And. (cAliasEE8)->EE8_STATUS #  "*"//.And. !Empty((cAliasEE8)->EE8_DTPREM)

      cUnid     := (cAliasEE8)->EE8_UNIDAD   
      nQtdAto   := (cAliasEE8)->EE8_SLDINI
      nValorAto := (cAliasEE8)->EE8_PRCTOT
      cForn_Exp := (cAliasEE8)->EE8_FORN
      lPrim   := .T.

      If(EasyEntryPoint("EDCCO150"),ExecBlock("EDCCO150",.F.,.F.,"ALTERA_FORN_EXP"),)

      Do While nQtdAto > 0 //If(lPrim, (nQtdAto > 0 .Or. nValorAto > 0), (nQtdAto > 0 .And. nValorAto > 0))   

         lPrim := .F.   
         If CO150ApuExp((cAliasEE8)->EE8_COD_I, (cAliasEE8)->EE8_POSIPI, cForn_Exp, (cAliasEE8)->EE8_FOLOJA)
            nQtdeItem  := If(cUnid = TRB1->ED3_UMPROD, (cAliasEE8)->EE8_SLDINI, AVTransUnid(cUnid, TRB1->ED3_UMPROD,(cAliasEE8)->EE8_COD_I,(cAliasEE8)->EE8_SLDINI))

            ED0->(DBSEEK(cFilED0+TRB1->ED3_AC))               
            TRB1->ED3_DU_QT -= nQtdeItem			
            nQtdAto -= (cAliasEE8)->EE8_SLDINI

            If TRB1->ED3_DU_QT < 0
               TRB1->ED3_DU_QT := 0
            EndIf      

            GrvTRBMEMO("1", (cAliasEE8)->EE8_PEDIDO)
            GRVWORKMOV("1", "PED", (cAliasEE8)->EE8_PEDIDO, (cAliasEE8)->EE8_COD_I, (cAliasEE8)->EE8_SEQUEN, nQtdeItem, If(cUnid = TRB1->ED3_UMPROD, nQtdeItem, AVTransUnid(TRB1->ED3_UMPROD, TRB1->ED3_UMNCM,(cAliasEE8)->EE8_COD_I,nQtdeItem)) , TRB1->ED3_DU_VL)
         Else
            If cTPRel == "1" //Str(cTipoRel,1) == "1"
               If EE7->(dbSeek(cFilEE7+(cAliasEE8)->EE8_PEDIDO)) .and. !Empty(EE7->EE7_EXPORT)
                  cAuxEx := EE7->EE7_EXPORT
                  cAuxLo := EE7->EE7_EXLOJA
               Else
                  cAuxEx := (cAliasEE8)->EE8_FORN
                  cAuxLo := (cAliasEE8)->EE8_FOLOJA
               EndIf
               If(EasyEntryPoint("EDCCO150"),ExecBlock("EDCCO150",.F.,.F.,"ALTERA_FORN_EXP"),)
               GRVWORKAC("1", "PED", (cAliasEE8)->EE8_PEDIDO, (cAliasEE8)->EE8_COD_I, (cAliasEE8)->EE8_SEQUEN,nQtdAto,AVTransUnid(cUnid,TRB1->ED3_UMNCM,(cAliasEE8)->EE8_COD_I,nQtdAto), nValorAto,cAuxEx,cAuxLo )
            Endif            
            Exit
         Endif                    
      Enddo                
    Endif  
    (cAliasEE8)->(DBSKIP())
   Enddo                                         

EndIf

/*// 2.5
ProcRegua(If(lTop, nContEE8, (cAliasEE8)->(EasyRecCount())))
If !lTop
   (cAliasEE8)->(DbSeek(cFilEE8,.T.))
Endif   

Do While (cAliasEE8)->(!EOF()) .And. (cAliasEE8)->EE8_FILIAL == cFilEE8

 IncProc(STR0018) //"Lendo Itens do Processo de Exportacao"
 If (cAliasEE8)->EE8_SLDINI # 0 .And. Empty((cAliasEE8)->EE8_DTPREM)    

   cUnid     := (cAliasEE8)->EE8_UNIDAD   
   nQtdAto   := (cAliasEE8)->EE8_SLDINI
   nValorAto := (cAliasEE8)->EE8_PRCTOT
   cForn_Exp := (cAliasEE8)->EE8_FORN
   lPrim   := .T.

   If(EasyEntryPoint("EDCCO150"),ExecBlock("EDCCO150",.F.,.F.,"ALTERA_FORN_EXP"),)

   Do While nQtdAto > 0  //If(lPrim, (nQtdAto > 0 .Or. nValorAto > 0), (nQtdAto > 0 .And. nValorAto > 0))   

      lPrim := .F.   
      If CO150ApuExp((cAliasEE8)->EE8_COD_I, (cAliasEE8)->EE8_POSIPI, cForn_Exp, (cAliasEE8)->EE8_FOLOJA)

         nQtdeItem  := If(cUnid = TRB1->ED3_UMPROD, (cAliasEE8)->EE8_SLDINI, AVTransUnid(cUnid, TRB1->ED3_UMPROD,(cAliasEE8)->EE8_COD_I,(cAliasEE8)->EE8_SLDINI))

         ED0->(DBSEEK(cFilED0+TRB1->ED3_AC))
         TRB1->ED3_DU_QT -= nQtdeItem
         nQtdAto -= (cAliasEE8)->EE8_SLDINI

         If TRB1->ED3_DU_QT < 0
            TRB1->ED3_DU_QT := 0
         EndIf      

         GrvTRBMEMO("1", (cAliasEE8)->EE8_PEDIDO)
         GRVWORKMOV("1", "PED", (cAliasEE8)->EE8_PEDIDO, (cAliasEE8)->EE8_COD_I, (cAliasEE8)->EE8_SEQUEN, nQtdeItem, If(cUnid = TRB1->ED3_UMPROD, nQtdeItem, AVTransUnid(TRB1->ED3_UMPROD, TRB1->ED3_UMNCM,(cAliasEE8)->EE8_COD_I,nQtdeItem)) , TRB1->ED3_DU_VL)
      Else      
         If Str(cTipoRel,1) == "1"
            If EE7->(dbSeek(cFilEE7+(cAliasEE8)->EE8_PEDIDO)) .and. !Empty(EE7->EE7_EXPORT)
               cAuxEx := EE7->EE7_EXPORT
               cAuxLo := EE7->EE7_EXLOJA
            Else
               cAuxEx := (cAliasEE8)->EE8_FORN
               cAuxLo := (cAliasEE8)->EE8_FOLOJA
            EndIf
            If(EasyEntryPoint("EDCCO150"),ExecBlock("EDCCO150",.F.,.F.,"ALTERA_FORN_EXP"),)
            GRVWORKAC("1", "PED", (cAliasEE8)->EE8_PEDIDO, (cAliasEE8)->EE8_COD_I, (cAliasEE8)->EE8_SEQUEN,nQtdAto,AVTransUnid(cUnid,TRB1->ED3_UMNCM,(cAliasEE8)->EE8_COD_I,nQtdAto), nValorAto,cAuxEx,cAuxLo )
         Endif   
         Exit
      Endif                    
   Enddo                
 Endif  
 (cAliasEE8)->(DBSKIP())
Enddo */

Return .T.
*------------------------------------------*
Static Function CO150IMPRIME(wnRel,cString)
*------------------------------------------*
Local cLine, i, lImpMemo := .F.
Local lImpCabW := .T.
Local lImpCabP := .F.
Private nSizeName := 0
                            
ED0->(dbSetOrder(2))

// Importacao
If Str(cModoImp,1) $ "1/3"

  TRB2->(dbGoTop())
  cAto := Space(Len(TRB2->ED4_AC))
  While !(TRB2->(Eof()))

/*    If ! Empty(dDtIni)                  // PLB 15/03/06 - Agora é verificada na Query
       If !Empty(TRB2->ED4_DT_VAL)
          If TRB2->ED4_DT_VAL < dDtIni
             TRB2->(DbSkip())
             Loop
          Endif
	   Endif
    Endif
			
    If ! Empty(dDtFim)
       If !Empty(TRB2->ED4_DT_VAL)
         If TRB2->ED4_DT_VAL > dDtFim
            TRB2->(DbSkip())
   	        Loop
	     Endif
	   Endif
    Endif
*/
    If nLin >= 55 .Or. cAto # TRB2->ED4_AC
       CO150CAB("I")
       cAto := TRB2->ED4_AC
       lImprime := .T.
       lImpCabP := .F.
    EndIf
        
    If lImpCabP
    	CO150CABPRI("I")  
    EndIf
    
    // 19.mai.2009 - 719546 - Aumento dos espaços entre colunas - HFD
    @ nLin,001 PSAY TRB2->ED4_ITEM+" / "+TRB2->ED4_UMITEM
    @ nLin,035 PSAY Transf(TRB2->ED4_NCM   , AVSX3("ED4_NCM",6))+If(ED0->ED0_MODAL == "1", ("/ "+TRB2->ED4_UMNCM), "")
    @ nLin,048 PSAY Transf(TRB2->ED4_QT_DI , AVSX3("ED4_QT_DI",6))
    @ nLin,070 PSAY Transf(TRB2->ED4_SALDO , AVSX3("ED4_SNCMLI",6))
    @ nLin,088 PSAY Transf(TRB2->ED4_VL_DI , AVSX3("ED4_VL_DI",6))
    @ nLin,119 PSAY If(TRB2->ED4_CAMB == "1", "Sim", "Nao")
    If cTPRel == "1" //Str(cTipoRel,1) == "1" //Analítico
       @ nLin,125 PSAY Transf(TRB2->ED4_DU_QT , AVSX3("ED4_QT_DI",6))
       @ nLin,If(ED0->ED0_MODAL == "1",142,140) PSAY Transf(AVTransUnid(TRB2->ED4_UMITEM,TRB2->ED4_UMNCM,TRB2->ED4_ITEM,TRB2->ED4_DU_QT),AVSX3("ED4_SNCMLI",6))
       @ nLin,If(ED0->ED0_MODAL == "1",160,158) PSAY Transf(TRB2->ED4_DU_VL , AVSX3("ED4_VL_DI",6))
       If ED0->ED0_MODAL == "2" //Isenção
          @ nLin,181 PSAY Alltrim(TRB2->ED4_UMNCM)
       Endif
    Endif

    EDCCOGRVDBF("I")

    If cTPRel == "2" //Str(cTipoRel,1) == "2"             // Sintetico
       lImpMemo := .F.
       For i:=1 To MLCOUNT(TRB2->ED4_MEMO,50)
   	       cLine:=MEMOLINE(TRB2->ED4_MEMO,50,i)
   	       @ nLin,/*102*/129 PSay cLine                   //NCF - 20/09/2011 - Reposicionado o local de impressão do Memo
   	       nLin++
   	       lImpMemo := .T.
   	       If nLin >= 55
              CO150CAB("I")
           EndIf
       Next i

    Else     // Somente se for Analitico - Verifica a movimentacao dos itens
    	IF WORK_M2->(DbSeek(TRB2->ED4_ITEM))
    					
			Do While WORK_M2->(!Eof()) .And. TRB2->ED4_ITEM == WORK_M2->TRB2_COD_I
			
			 	If TRB2->ED4_AC == WORK_M2->TRB2_AC .And. TRB2->ED4_SEQSIS == WORK_M2->TRB2_SEQ
			 					 					 		
					If nLin >= 55 .Or. lImpCabW
						nLin += 2
						SA150MOV("CAC", "I")
						lImpCabW := .F.
						lImpCabP := .T.
					EndIf
	    
					// Imprime as Movimentacoes do item                    
					@ nLin,001 PSAY WORK_M2->TRB2_DI
					@ nLin,011 PSAY WORK_M2->TRB2_HAWB
					@ nLin,034 PSAY WORK_M2->TRB2_COD_I
					@ nLin,053 PSAY WORK_M2->TRB2_POS
					@ nLin,060 PSAY Transf(WORK_M2->TRB2_QTDE , AVSX3("W3_SALDO_Q",6))
					@ nLin,077 PSAY Transf(WORK_M2->TRB2_QT_NC, AVSX3("W5_QTDE",6))
					@ nLin,092 PSAY Transf(WORK_M2->TRB2_VALOR, AVSX3("W5_VL_AC",6))
					@ nLin,120 PSAY If(WORK_M2->TRB2_CAMB == "1", "Sim", "Nao")
					@ nLin,128 PSAY WORK_M2->TRB2_OBS
					nLin ++
						
					EDCCOGRVDBF("MOV/I")
				EndIf	
					
				WORK_M2->(DbSkip())
			Enddo			
		Endif   
	Endif    

    If !lImpMemo
       nLin++
    Endif

    TRB2->(DBSKIP())					
  ENDDO

  // Imprime produtos que nao atenderam nenhum AC Importacao
  If lExisteWK2
     nLin := 99
     If cTPRel == "1" //Str(cTipoRel,1) = "1" 
        WORK2->(DbGotop())
        nSizeName := Len(WORK2->WORK2_IMP)+Len(" - ")+Len(E_Field2(WORK2->WORK2_IMP,"SYT",1,"YT_NOME") )
        Do While WORK2->(!Eof())
           If nLin >= 55
              SA150MOV("SAC", "I")
              lImprime := .T.
           EndIf
             
           // Imprime as Movimentacoes do item                    
           @ nLin,000 PSAY WORK2->WORK2_DI                            
           @ nLin,009 PSAY WORK2->WORK2_HAWB
    	   @ nLin,032 PSAY WORK2->WORK2_COD
		   @ nLin,051+22 PSAY WORK2->WORK2_POS
		   @ nLin,066+12 PSAY Transf(WORK2->WORK2_QTDE , AVSX3("W5_QTDE",6))
		   @ nLin,084+12 PSAY Transf(WORK2->WORK2_QTN  , AVSX3("W5_QTDE",6))
		   @ nLin,100+12 PSAY Transf(WORK2->WORK2_VAL  , AVSX3("W5_VL_AC",6))
		   @ nLin,119+16 PSAY WORK2->WORK2_IMP+" - "+PADC(E_Field2(WORK2->WORK2_IMP,"SYT",1,"YT_NOME"),nSizeName-32,'')
		   @ nLin,119+1+nSizeName-4 PSAY Transf(BuscaCNPJ(WORK2->WORK2_IMP,.T.),cPicCgc)
		   nLin ++
		   
		   EDCCOGRVDBF("SEM/I")

		   WORK2->(DbSkip())
        Enddo
        nSizeName := 0
     Else
   	    SA150MOV("SAC", "I")
	    nLin += 2
	    @ nLin,020 PSAY STR0019	   //"EXISTE(M) PEDIDO(S) SEM AC."
     Endif   
  Endif   
Endif
                  
// Exportacao	  
nLin := 99
If Str(cModoImp,1) $ "2/3" 

  TRB1->(dbGoTop())
  cAto := Space(LEN(TRB1->ED3_AC))
  While !(TRB1->(Eof()))

/*     If ! Empty(dDtIni)                  // PLB 15/03/06 - Agora é verificada na Query
       If !Empty(TRB1->ED3_DT_VAL)
          If TRB1->ED3_DT_VAL < dDtIni
             TRB1->(DbSkip())
             Loop
          Endif
	   Endif
    Endif
			
    If ! Empty(dDtFim)
       If !Empty(TRB1->ED3_DT_VAL)
         If TRB1->ED3_DT_VAL > dDtFim
            TRB1->(DbSkip())
   	        Loop
	     Endif
	   Endif
    Endif			                          
*/
    If nLin >= 55 .Or. cAto # TRB1->ED3_AC
       CO150CAB("E")   
       cAto := TRB1->ED3_AC
       lImprime := .T.
    EndIf
                      
    // 19.mai.2009 - 719546 - Aumento dos espaços entre colunas - HFD
    @ nLin,001 PSAY TRB1->ED3_PROD+" / "+TRB1->ED3_UMPROD
    @ nLin,032 PSAY Transf(TRB1->ED3_NCM    , AVSX3("ED3_NCM",6))+If(ED0->ED0_MODAL == "1", ("/ "+TRB1->ED3_UMNCM), "")
    @ nLin,044 PSAY Transf(TRB1->ED3_SALDO  , AVSX3("ED3_SALDO",6))
    @ nLin,068 PSAY Transf(TRB1->ED3_SALNCM , AVSX3("ED3_SALNCM",6)) 
    @ nLin,088 PSAY Transf(TRB1->ED3_SAL_CO , AVSX3("ED3_SAL_CO",6))
    @ nLin,106 PSAY Transf(TRB1->ED3_SAL_SE , AVSX3("ED3_SAL_SE",6))
    @ nLin,131 PSAY Transf(TRB1->ED3_DU_QT  , AVSX3("ED3_SALDO",6))
    @ nLin,153 PSAY Transf(AVTransUnid(TRB1->ED3_UMPROD,TRB1->ED3_UMNCM,TRB1->ED3_PROD,TRB1->ED3_DU_QT) , AVSX3("ED3_SALNCM",6))
    If ED0->ED0_MODAL == "2" //Isenção
       @ nLin,158 PSAY TRB1->ED3_UMNCM
    Endif

    lImpMemo := .F.
    For i:=1 To MLCOUNT(TRB1->ED3_MEMO,50)
        cLine:=MEMOLINE(TRB1->ED3_MEMO,50,i)
        @ nLin,If(ED0->ED0_MODAL == "1", 158, 167) PSAY cLine
   	    nLin++
   	    lImpMemo := .T.
   	    If nLin >= 55
           CO150CAB("E")
        EndIf
    Next i

    EDCCOGRVDBF("E")

    If cTPRel == "1" //Str(cTipoRel,1) = "1" // Somente se for Analitico - Verifica a movimentacao dos itens
       IF WORK_M1->(DbSeek(TRB1->ED3_PROD+TRB1->ED3_SEQSIS))
          nLin += 1
          SA150MOV("CAC", "E")
          Do While WORK_M1->(!Eof()) .And. TRB1->ED3_PROD == WORK_M1->TRB1_COD_I
          
             If nLin >= 55
                SA150MOV("CAC", "E")
             EndIf
             
             // Imprime as Movimentacoes do item                    
             @ nLin,001 PSAY WORK_M1->TRB1_DI
             @ nLin,011 PSAY WORK_M1->TRB1_HAWB
			 @ nLin,034 PSAY WORK_M1->TRB1_COD_I
			 @ nLin,053 PSAY WORK_M1->TRB1_POS
			 @ nLin,067 PSAY Transf(WORK_M1->TRB1_QTDE , AVSX3("EE9_SLDINI",6))
			 @ nLin,085 PSAY Transf(WORK_M1->TRB1_QT_NC, AVSX3("W5_QTDE",6))
			 @ nLin,100 PSAY Transf(WORK_M1->TRB1_VALOR, AVSX3("W5_VL_AC",6))
			 @ nLin,122 PSAY If(WORK_M1->TRB1_CAMB == "1", "Sim", "Nao")
			 nLin++
			 
			 EDCCOGRVDBF("MOV/E")
			 
             WORK_M1->(DbSkip())
          Enddo
       Endif
    Endif
    
    If !lImpMemo 
       nLin++
    Endif   

    TRB1->(DBSKIP())					
  ENDDO				                                                   
                                     
  // Imprime produtos que nao atenderam nenhum AC 
  If lExisteWK1
     nLin := 99
     If cTPRel == "1" //Str(cTipoRel,1) = "1"
        WORK1->(DbGotop())      
        nSizeName := Len(WORK1->WORK1_EXP)+Len(" - ")+Len(SA2->A2_NOME)
        Do While WORK1->(!Eof())           
           If nLin >= 55
              SA150MOV("SAC", "E")
              lImprime := .T.
           EndIf
             
           // Imprime as Movimentacoes do item                    
           @ nLin,002 PSAY WORK1->WORK1_PE                          
           @ nLin,010 PSAY WORK1->WORK1_HAWB
		   @ nLin,033 PSAY WORK1->WORK1_COD
		   @ nLin,052+17 PSAY WORK1->WORK1_POS
		   @ nLin,067+14 PSAY Transf(WORK1->WORK1_QTD  , AVSX3("EE9_SLDINI",6))
		   @ nLin,085+14 PSAY Transf(WORK1->WORK1_QTN  , AVSX3("EE9_SLDINI",6))
		   @ nLin,101+14 PSAY Transf(WORK1->WORK1_VAL  , AVSX3("W5_VL_AC",6))
		   SA2->(dbSeek(cFilSA2Aux+WORK1->WORK1_EXP))
		   @ nLin,120+17 PSAY WORK1->WORK1_EXP+" - "+PADC(SA2->A2_NOME,nSizeName-32,'')
		   @ nLin,120+1+nSizeName-3 PSAY Transf(SA2->A2_CGC,cPicCgc)
		   nLin++
		   
		   EDCCOGRVDBF("SEM/E")
		   
		   WORK1->(DbSkip())
        Enddo
        nSizeName := 0
     Else
        SA150MOV("SAC", "E")	   
	    nLin += 2
	    @ nLin,020 PSAY STR0019	   //"EXISTE(M) PEDIDO(S) SEM AC."
     Endif   
  Endif
Endif

If lImprime
   If aReturn[5] = 1
      Set Printer To
      Commit
      Ourspool(wnrel)
   EndIf
Else
   Help(" ",1,"AVG0005190") //MsgInfo(STR0020) //"Nao ha Dados para Impressao !!!"
Endif   

MS_FLUSH()

ED0->(dbSetOrder(1))
SW6->(DBSETORDER(1))        
SW7->(DBSETORDER(1))        
SW9->(DBSETORDER(1))        
SA5->(DBSETORDER(1))        
SWP->(dbSetOrder(1))
EEC->(DBSETORDER(1)) 
ED4->(dbSetOrder(1))
ED3->(dbSetOrder(1))
SW8->(DBSETORDER(1))
SW5->(dbSetOrder(1))
EE9->(DBSETORDER(1))
   
Return .T.
*---------------------------------*
STATIC FUNCTION CO150CAB(cModulo)
*---------------------------------*
TituloRel := Titulo + If(/*Str(cTipoRel,1)*/cTPRel == "1", STR0021, STR0022 )  //" (Analitico)"###" (Sintetico)"

// Busca o Importador no ED0
If !ED0->(DbSeek(cFilED0+If(cModulo == "E", TRB1->ED3_AC, TRB2->ED4_AC )))
   ED0->(dbSetOrder(1))
   ED0->(DbSeek(cFilED0+If(cModulo == "E", TRB1->ED3_AC, TRB2->ED4_AC )))
   ED0->(dbSetOrder(2))
EndIf

// Buscar Dados do Importador
SYT->(DbSeek(cFilSYT+ED0->ED0_IMPORT))
nLin := 08

If cModulo  == "I"
   Cabec1 := STR0023+TRB2->ED4_AC+Space(20)+"Modalidade: "+If(ED0->ED0_MODAL=="1", "Suspensão", "Isenção"+Space(02))+Space(25)+STR0056+ED0->ED0_PD+space(39)+STR0025+ALLTRIM(SYT->YT_NOME) //" Ato Concessorio...: "### "Pedido de Drawback: " ###"Importador......: "
   nLIN:= nLIN + 1
   Cabec2 := STR0026+dtoc(dDtIni)+STR0027+dtoc(dDtFim)+STR0028+space(47)+STR0024+Transf(ALLTRIM(SYT->YT_CGC),cPicCgc)+space(30)+STR0029+If(!Empty(TRB2->ED4_DT_VAL), Alltrim(Strzero((TRB2->ED4_DT_VAL - dDataBase),05)),"00000")+space(03)+STR0030+dtoc(TRB2->ED4_DT_VAL)  //" Periodo...........: "###" a "###" - Importacao" ### "C.N.P.J..: " ### "Dias Restantes..: "###"Dt. Validade: "
ElseIf cModulo == "E"
   Cabec1 := STR0023+TRB1->ED3_AC+Space(20)+"Modalidade: "+If(ED0->ED0_MODAL=="1", "Suspensão", "Isenção"+Space(02))+Space(25)+STR0056+ED0->ED0_PD+space(39)+STR0031+ALLTRIM(SYT->YT_NOME)  //" Ato Concessorio...: "### "Pedido de Drawback: " ###"Exportador......: "
   nLIN:= nLIN + 1
   Cabec2 := STR0026+dToc(dDtIni)+STR0027+dtoc(dDtFim)+STR0032+space(47)+STR0024+Transf(ALLTRIM(SYT->YT_CGC),cPicCgc)+space(30)+STR0029 +If(!Empty(TRB1->ED3_DT_VAL), Alltrim(Strzero((TRB1->ED3_DT_VAL - dDataBase),05)),"00000")+space(03)+STR0030+dtoc(TRB1->ED3_DT_VAL)  //" Periodo...........: "###" a "###" - Exportacao"### "C.N.P.J..: " ### "Dias Restantes..: "###"Dt. Validade: "
Endif

Cabec(TituloRel,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)

CO150CABPRI(cModulo)

RETURN .T.
*----------------------------------------*
STATIC FUNCTION SA150MOV(cOpcao, cModulo)
*----------------------------------------* 
If nLIn >= 55                                                  
   If cOpcao == "CAC"
      Cabec(TituloRel,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 09  
      CO150CABPRI(cModulo)
      nLin += 2         
   Else
      Cabec(STR0033+If(cModulo="I", STR0034, STR0035),"","",NomeProg,Tamanho,nTipo)        //"Pedidos sem AC - "###"Importacao"###"Exportacao"
      nLin := 07  
   Endif   
Endif

If cOpcao == "CAC"
   If cModulo="I" .And. ED0->ED0_MODAL == "1" //Suspensão
      @ nLin,01 Psay STR0036+STR0037 //"  Tipo         Documento               Item           Posição         Quantidade     Quantidade NCM         Valor US$  Câmbio "###"            Observações"
   ElseIf cModulo="I" .And. ED0->ED0_MODAL == "2" //Isenção
      @ nLin,01 Psay STR0059+STR0037 //"  Tipo         Documento               Item           Posicao         Quantidade     Quant. Compra          Valor US$  Cambio "###"            Observações"
   ElseIf cModulo="E" .And. ED0->ED0_MODAL == "1" //Suspensão
      @ nLin,01 Psay STR0036 //"  Tipo         Documento               Item           Posição         Quantidade     Quantidade NCM         Valor US$  Câmbio "
   ElseIf cModulo="E" .And. ED0->ED0_MODAL == "2" //Isenção
      @ nLin,01 Psay STR0062 //"  Tipo         Documento               Item           Posicao         Quantidade     Quant. Venda          Valor US$  Cambio "
   Endif
   
   //@ nLin,01 Psay STR0036 + If(cModulo="I",STR0037,"") //"  Tipo         Documento               Item           Posicao         Quantidade     Quantidade NCM         Valor US$  Cambio "###"            Observacoes"
   
   nLin := nLin +1
   @ nLin,01 Psay STR0038 + If(cModulo="I",STR0039,"") //"========= ====================== ================== =========== ================= ================= ================= ========"###" ==========================================================="
Else
/*   If cModulo = "I" .And. ED0->ED0_MODAL == "1" //Suspensão
      @ nLin,00 Psay STR0040 // "  Tipo        Documento               Item           Posição            Quantidade    Quantidade NCM          Valor US$                      Importador                                  CNPJ       "
   ElseIf cModulo = "I" .And. ED0->ED0_MODAL == "2" //Isenção
      @ nLin,00 Psay STR0060 // "  Tipo        Documento               Item           Posicao            Quantidade    Quant. Compra           Valor US$                      Importador                                CNPJ     "
   ElseIf cModulo = "E" .And. ED0->ED0_MODAL == "1" //Suspensão
      @ nLin,00 Psay STR0054 // "  Tipo        Documento               Item           Posição            Quantidade    Quantidade NCM          Valor US$                Exportador/Fonecedor                      CNPJ       "
   ElseIf cModulo = "E" .And. ED0->ED0_MODAL == "2" //Isenção
      @ nLin,00 Psay STR0061 // "  Tipo        Documento               Item           Posicao            Quantidade    Quant. Venda            Valor US$ 
   Endif
*/
   nLin := nLin +1
   //** PLB 16/03/06
   @ nLin,00 Psay STR0040+SPACE(23)+STR0072+PadC(IIF(cModulo=="I",STR0070,STR0071),nSizeName-20," ")+STR0054 //"  Tipo        Documento               Item                        Posicao            Quantidade    Quantidade NCM          Valor US$                      Importador                                CNPJ     " ### "  Tipo        Documento               Item           Posicao            Quantidade    Quantidade NCM          Valor US$                Exportador/Fonecedor                    CNPJ     "
   nLin := nLin +1
   @ nLin,00 Psay STR0041+SPACE(20)+STR0073+SPACE(1)+Replicate("=",nSizeName-20)+STR0055//"========= ====================== =============================== ===========  ================= =================  ================= ========================================================= ==============" ### "========= ====================== ================== ===========  ================= =================  ================= ================================================= =============="

   //@ nLin,00 Psay If(cModulo="I",STR0041,STR0055)+Replicate("=",nSizeName)+STR0070 //"========= ====================== ================== ===========  ================= =================  ================= ========================================================= ==============" ### "========= ====================== ================== ===========  ================= =================  ================= ================================================= =============="
   
   //@ nLin,00 Psay If(cModulo="I",STR0040,STR0054) //"  Tipo        Documento               Item           Posicao            Quantidade    Quantidade NCM          Valor US$                      Importador                                CNPJ     " ### "  Tipo        Documento               Item           Posicao            Quantidade    Quantidade NCM          Valor US$                Exportador/Fonecedor                    CNPJ     "
      
Endif   
nLin := nLin +1
   
Return .T.
*-----------------------------------*
STATIC FUNCTION CO150CABPRI(cModulo)
*-----------------------------------* 
If cModulo  == "I"
   If cTPRel == "1" //Str(cTipoRel,1) = "1"    // Analitico
      @ nLin,01 Psay If(ED0->ED0_MODAL == "1", STR0042, STR0057 ) //"     Item                NCM          Saldo Qtde Item     Saldo Qtde NCM    Saldo Valor US$  Câmbio      Sld Qtde Atual Sld Qtde NCM Atual      Sld US$ Atual" ### "     Item                NCM          Saldo Qtde Item  Saldo Qtde Compra   Saldo Valor US$  Câmbio      Sld Qtde Atual   Sld Qtde Compra Atual     Sld US$ Atual  UM Compra"
      nLin := nLin +1
 	  @ nLin,01 Psay If(ED0->ED0_MODAL == "1", STR0043, STR0058 ) //"=================== ============== ================== ================== ================== ======== ================== ================== ==================" ### "=================== ============== ================== ================== ================== ======== ================== ===================== ==================  ========="
   Else                     // Sintetico
      @ nLin,01 Psay If(ED0->ED0_MODAL == "1", STR0044, STR0065 ) //"     Item               NCM          Saldo Qtde Item     Saldo Qtde NCM     Saldo Valor US$  Cambio     Pedidos/Processos p/ A.C."###"     Item               NCM          Saldo Qtde Item     Saldo Qtd Compra   Saldo Valor US$  Cambio     Pedidos/Processos p/ A.C."
      nLin := nLin +1
 	  @ nLin,01 Psay If(ED0->ED0_MODAL == "1", STR0045, STR0066 ) //"=================== ============== ================== ================== ================== ======== =================================================="
   Endif
ElseIf cModulo  == "E"
   	@ nLin,01 Psay If(ED0->ED0_MODAL == "1", STR0046, STR0063) //"    Produto             NCM          Saldo Qtde Prod.     Saldo Qtde NCM  Sld Valor c/ Cob.  Sld Valor s/ Cob.       Sld Qtde Atu   Sld Qtde NCM Atu               Pedidos/Processos p/ A.C.              "###"    Produto             NCM          Saldo Qtde Prod.   Saldo Qtd Venda  Sld Valor c/ Cob.  Sld Valor s/ Cob.       Sld Qtde Atu  Sld Qtd Venda Atu  UM Venda             Pedidos/Processos p/ A.C.              "
	nLin := nLin +1
    @ nLin,01 Psay If(ED0->ED0_MODAL == "1", STR0047, STR0064) //"=================== ============== ================== ================== ================== ================== ================== ==================  ===================================================="###"=================== ============== ================== ================== ================== ================== ================== ================== ======== ===================================================="
Endif          

nLin := nLin + 1      

RETURN .T.
*-----------------------------*
STATIC FUNCTION SA150DATAS()
*-----------------------------*
If dDtFim < dDtIni  
	Help(" ",1,"AVG0005207") //Msginfo(STR0048, STR0049)  //"A data final deve ser maior que a data inicial"###"Mensagem"
	Return .F.
Endif

Return .T.                    
*-----------------------------------------*
Static Function CO150ApuImp(cItem, cNCM)
*-----------------------------------------*
Local cAto:="", dDtVal, nSalLI, cPos:=""
Local cAto2:="", dDtVal2, nSalLI2, cPos2:=""
Local cPos3:=""
// LOCAL nAPos, cAto3:="", lSaldo ACSJ - 01/12/2004 - Variavel não é usada.
Local cMelhor:=""
Local nSA5Ord := SA5->(IndexOrd())
Local nED0Ord := ED0->(IndexOrd())
Local nSYTOrd := SYT->(IndexOrd())
Local cAlias  := "TRB2"                
Local nAliasOrd := (cAlias)->(IndexOrd())
Local cCambio := VerCobertura()
Local lRetorno:= .F.
Local cOldAC := "" //** PLB 15/03/06 - Variavel para melhoria de desempenho
nQtdAux:=0
cUnid  :=""

ED0->(dbSetOrder(2))
SA5->(dbSetOrder(3))
cCGC := BuscaCNPJ(SW4->W4_IMPORT)   //Função BuscaCNPJ() está no EDCAC400.PRW

cPos:=""; cAto:=""; cPos2:=""; cAto2:=""; cPos3:=""; lOk:=.T.
   
(cAlias)->(dbSetOrder(2))
(cAlias)->(dbSeek(cCGC+cItem+cCambio+DtoS(dDataBase),.T.))  //SoftSeek
            
cOldAC := (cAlias)->ED4_AC //** PLB 15/03/06

If !ED0->(dbSeek(cFilED0+(cAlias)->ED4_AC))
   ED0->(dbSetOrder(1))
   ED0->(dbSeek(cFilED0+(cAlias)->ED4_AC))
//   ED0->(dbSetOrder(2))
EndIf

If (cAlias)->ED4_CNPJIM==cCGC .and. (cAlias)->ED4_ITEM==cItem .and. (cAlias)->ED4_CAMB==cCambio
   If !Empty((cAlias)->ED4_AC) .and. ((ED0->ED0_TIPOAC <> "06" .and. (cAlias)->ED4_DU_QT > 0) .or. (ED0->ED0_TIPOAC=="06" .and. (cAlias)->ED4_DU_VL > 0)) .and. Empty(ED0->ED0_DT_ENC)
      cPos    := (cAlias)->ED4_SEQSIS
      cAto    := (cAlias)->ED4_AC
      dDtVal  := (cAlias)->ED4_DT_VAL      
      nSalLI  := If(ED0->ED0_TIPOAC <> "06" , (cAlias)->ED4_DU_QT, (cAlias)->ED4_DU_VL)
   EndIf
EndIf

(cAlias)->(dbSetOrder(3))
(cAlias)->(dbSeek(cCGC+cNCM+Space(Len((cAlias)->ED4_ITEM))+Alltrim(cCambio)+DtoS(dDataBase),.T.))  //SoftSeek

If cOldAC != (cAlias)->ED4_AC
   cOldAC := (cAlias)->ED4_AC
   ED0->( DBSetOrder(2) )
   If !ED0->(dbSeek(cFilED0+(cAlias)->ED4_AC))
      ED0->(dbSetOrder(1))
      ED0->(dbSeek(cFilED0+(cAlias)->ED4_AC))
//      ED0->(dbSetOrder(2))
   EndIf
EndIf

If (cAlias)->ED4_CNPJIM==cCGC .and. (cAlias)->ED4_NCM==cNCM .and. Empty((cAlias)->ED4_ITEM) .and. (cAlias)->ED4_CAMB==cCambio
   If !Empty((cAlias)->ED4_AC) .and. ((ED0->ED0_TIPOAC <> "06" .and. (cAlias)->ED4_DU_QT > 0) .or. (ED0->ED0_TIPOAC=="06" .and. (cAlias)->ED4_DU_VL > 0)) .and. Empty(ED0->ED0_DT_ENC) 
      cPos2   := (cAlias)->ED4_SEQSIS
      cAto2   := (cAlias)->ED4_AC
      dDtVal2 := (cAlias)->ED4_DT_VAL
      nSalLI2 := If(ED0->ED0_TIPOAC <> "06" , (cAlias)->ED4_DU_QT, (cAlias)->ED4_DU_VL)
   EndIf
EndIf
      
(cAlias)->(dbSeek(cCGC+AvKey("99999999","ED4_NCM")+Space(Len((cAlias)->ED4_ITEM))+Alltrim(cCambio)+DtoS(dDataBase),.T.))  //SoftSeek

If cOldAC != (cAlias)->ED4_AC
   cOldAC := (cAlias)->ED4_AC
   ED0->( DBSetOrder(2) )
   If !ED0->(dbSeek(cFilED0+(cAlias)->ED4_AC))
      ED0->(dbSetOrder(1))
      ED0->(dbSeek(cFilED0+(cAlias)->ED4_AC))
//      ED0->(dbSetOrder(2))
   EndIf
EndIf

If (cAlias)->ED4_CNPJIM==cCGC .and. Alltrim((cAlias)->ED4_NCM)=="99999999" .and. Empty((cAlias)->ED4_ITEM) .and. (cAlias)->ED4_CAMB==cCambio
   If !Empty((cAlias)->ED4_AC) .and. (cAlias)->ED4_DU_VL > 0 .and. Empty(ED0->ED0_DT_ENC) 
      cPos3   := (cAlias)->ED4_SEQSIS
   EndIf
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

(cAlias)->(dbSetOrder(1))
If cMelhor == cAto+cPos .and. !Empty(cMelhor)
   If !Empty(cPos3)
      If MelhorAC(dDtVal,nSalLI,(cAlias)->ED4_DT_VAL,0)
         (cAlias)->(dbSeek(cAto+cPos))
      EndIf
   Else
      (cAlias)->(dbSeek(cAto+cPos))
   EndIf
ElseIf cMelhor == cAto2+cPos2 .and. !Empty(cMelhor)
   If !Empty(cPos3)
      If MelhorAC(dDtVal2,nSalLI2,(cAlias)->ED4_DT_VAL,0)
         (cAlias)->(dbSeek(cAto2+cPos2))
      EndIf
   Else
      (cAlias)->(dbSeek(cAto2+cPos2))
   EndIf
ElseIf Empty(cPos3)
   lOk := .F.
EndIf

If cOldAC != (cAlias)->ED4_AC
   ED0->( DBSetOrder(2) )
   If !ED0->(dbSeek(cFilED0+(cAlias)->ED4_AC))
      ED0->(dbSetOrder(1))
      ED0->(dbSeek(cFilED0+(cAlias)->ED4_AC))
//      ED0->(dbSetOrder(2))
   EndIf
EndIf

If lOk
   lRetorno := .T.  
Else
   lRetorno := .F.
EndIf   
   
(cAlias)->(dbSetOrder(nAliasOrd))
SA5->(dbSetOrder(nSA5Ord))
ED0->(dbSetOrder(nED0Ord))
SYT->(dbSetOrder(nSYTOrd))

dbSelectArea(cAlias)

Return lRetorno
*----------------------------*
Static Function VerCobertura()
*----------------------------*
//Local cCobCamb
SY6->(dbSeek(cFilSY6+SW4->W4_COND_PA+str(SW4->W4_DIAS_PA,3,0)))
//cCobCamb := If(SY6->Y6_TIPOCOB<>"4","1","2")

Return If(SY6->Y6_TIPOCOB<>"4","1","2") //cCobCamb
*------------------------------------------------------------------------------------------------*
Static Function GrvWorkMov(cOpcao, cPedido, cHawb, cCod_I, cPos, nQtde, nQtdnc, nValorAto, cCamb,cAc,cSeqSis)
*------------------------------------------------------------------------------------------------*
Local cCobCamb

Default cAc		:= ""
Default cSeqSis	:= ""

cCobCamb := TRAZCOBERTURA()

If cOpcao = "1"
   WORK_M1->(DBAPPEND())                                           
   WORK_M1->TRB1_DI     := cPedido
   WORK_M1->TRB1_HAWB   := cHawb
   WORK_M1->TRB1_COD_I  := cCod_I
   WORK_M1->TRB1_POS    := cPos         
   WORK_M1->TRB1_QTDE   := nQtde
   WORK_M1->TRB1_QT_NC  := nQtdnc
   WORK_M1->TRB1_VALOR  := nValorAto
   WORK_M1->TRB1_CAMB   := cCobCamb //If( cCamb = "1", STR0050, STR0051) //"Sim"###"Nao"
Else
   WORK_M2->(DBAPPEND())                                   
   WORK_M2->TRB2_DI     := cPedido
   WORK_M2->TRB2_HAWB   := cHawb
   WORK_M2->TRB2_COD_I  := cCod_I
   WORK_M2->TRB2_POS    := cPos
   WORK_M2->TRB2_QTDE   := nQtde 
   WORK_M2->TRB2_QT_NC  := nQtdnc
   WORK_M2->TRB2_VALOR  := nValorAto  
   WORK_M2->TRB2_CAMB   := cCobCamb //If( cCamb = "1", STR0050, STR0051) //"Sim"###"Nao"
   WORK_M2->TRB2_AC		:= cAc		//Ato concessório vinculado
   WORK_M2->TRB2_SEQ := cSeqSis	//sequência ato concessório vinculado
Endif

Return .T.
*--------------------------------------------------------------------------------------------------*
Static Function GrvWorkAC(cOpcao, cPedido, cHawb, cCod_I, cPos, nQtde, nQtdnc, nValorAto,cImp,cLoja)
*--------------------------------------------------------------------------------------------------*
//Local cCobCamb  //PLB 15/03/06 - Não está sendo utilizada

If cOpcao = "1"      
   lExisteWK1 := .T. 
//   cCobCamb := TRAZCOBERTURA()
   WORK1->(DBAPPEND())                                   
   WORK1->WORK1_PE   := cPedido
   WORK1->WORK1_HAWB := cHawb 
   WORK1->WORK1_COD  := cCod_I 
   WORK1->WORK1_POS  := cPos
   WORK1->WORK1_QTD  := nQtde
   WORK1->WORK1_QTN  := nQtdnc
   WORK1->WORK1_VAL  := nValorAto
   WORK1->WORK1_EXP  := cImp
   WORK1->WORK1_LOJ  := cLoja
   If(EasyEntryPoint("EDCCO150"),ExecBlock("EDCCO150",.F.,.F.,"GRV_WORK_EXP"),)
Else
   lExisteWK2 := .T.
   WORK2->(DBAPPEND())
   WORK2->WORK2_DI     := cPedido
   WORK2->WORK2_HAWB   := cHawb 
   WORK2->WORK2_COD    := cCod_I
   WORK2->WORK2_POS    := cPos
   WORK2->WORK2_QTDE   := nQtde
   WORK2->WORK2_QTN    := nQtdnc       
   WORK2->WORK2_VAL    := nValorAto
   WORK2->WORK2_IMP    := cImp
Endif

Return
*-----------------------------------------*
Static Function GrvTRBMEMO(cOpcao, cCampo)
*-----------------------------------------*
Local lGrava := .T. 
Local i
      
If cOpcao == "1"  // Exportacao
   // Verifica se ja tem o conteudo listado no campo memo
   For i:=1 To MLCOUNT(TRB1->ED3_MEMO,50)	
   	   cLine:=MEMOLINE(TRB1->ED3_MEMO,50,i)   	   
       If AT(ALLTRIM(cCampo), ALLTRIM(cLine)) != 0
//   	      lGrava := .T.		   	   	      
//   	   Else
   	      lGrava := .F.
   	      Exit //** PLB 15/03/06
   	   Endif
   Next
   If lGrava
      TRB1->ED3_MEMO := TRB1->ED3_MEMO + IF(Empty(TRB1->ED3_MEMO),""," / ") + ALLTRIM(cCampo)
   Endif  
Else
   // Verifica se ja tem o conteudo listado no campo memo
   For i:=1 To MLCOUNT(TRB2->ED4_MEMO,50)	
   	   cLine:=MEMOLINE(TRB2->ED4_MEMO,50,i)   	   
   	   If AT(ALLTRIM(cCampo), ALLTRIM(cLine)) = 0
//	      lGrava := .T.		   	   	      
//   	   Else
   	      lGrava := .F.
   	      Exit //** PLB 15/03/06
   	   Endif
   Next
   If lGrava
      TRB2->ED4_MEMO := TRB2->ED4_MEMO + IF(Empty(TRB2->ED4_MEMO),""," / ") + ALLTRIM(cCampo)
   Endif  
Endif
   
Return 
*------------------------------*
Static Function TrazCobertura()     
*------------------------------*
Local Cond_Pag := SW4->W4_COND_PA
Local Dias_Pag := SW4->W4_DIAS_PA
//Local cCobRet

SY6->(dbSeek(cFilSY6+Cond_Pag+str(Dias_Pag,3,0)))

//** PLB 15/03/06
//cCobRet := If(SY6->Y6_TIPOCOB<>"4","1","2")

Return If(SY6->Y6_TIPOCOB<>"4", STR0050, STR0051) //If(cCobRet = "1", STR0050, STR0051)                  //"Sim"###"Nao"

*------------------------------------*
Static Function ContaRegs()
*------------------------------------*
Local cQuery, cCondDel:="AND D_E_L_E_T_ <> '*' "
Local cSelect := "SELECT COUNT(*) Contador FROM "

// Zera Variaveis
nContED4 := 0
nContSW8 := 0
nContSW5 := 0
nContSW3 := 0
nContED3 := 0
nContEE9 := 0
nContEE8 := 0
               
ProcRegua(If(Str(cModoImp,1) = "1", 4, If(Str(cModoImp,1) = "2", 3, 7)))               
                                      
If Str(cModoImp,1) $ "1/3"   // Importacao ou Ambos
   
   IncProc("Contando Registros....")

   // ED4
   cQuery :=  cSelect + RetSqlName('ED4') + " WHERE ED4_FILIAL='" + cFilED4+ "' "+;
	          If(TcSrvType()<>"AS/400",cCondDel,"")+;
	          If(cTipoPed<>"2","AND (ED4_AC <> '' OR ED4_AC <> ' ') ","")+;
	          "AND (ED4_QT_DI > 0 OR ED4_VL_DI > 0) "

   If Select(cAliasED4) <> 0
      (cAliasED4)->(DbCloseArea())
   Endif
   
   cQuery:=ChangeQuery(cQuery)
   TcQuery cQuery ALIAS (cAliasED4) NEW                               
   //If Select(cAliasED4) <> 0
      nContED4  := (cAliasED4)->Contador
      (cAliasED4)->(DbCloseArea())
   //Endif

   
   IncProc(STR0052) //"Contando Registros...."

   // SW8
   cQuery :=  cSelect + RetSqlName('SW8') + " WHERE W8_FILIAL='" + cFilSW8+ "' "+;
   		    If(TcSrvType()<>"AS/400",cCondDel,"")+;
   		    "AND (W8_AC <> '' OR W8_AC <> ' ') "

   cQuery:=ChangeQuery(cQuery)
   TcQuery cQuery ALIAS (cAliasSW8) NEW                               
   If Select(cAliasSW8) <> 0
      nContSW8  := (cAliasSW8)->Contador
      (cAliasSW8)->(DbCloseArea())
   Endif


   IncProc(STR0052) //"Contando Registros...."
     
   // SW5
   cQuery :=  cSelect + RetSqlName('SW5') + " WHERE W5_FILIAL='" + cFilSW5+ "' "+;
  		    If(TcSrvType()<>"AS/400",cCondDel,"")+;
  		    "AND W5_SEQ = 0 AND W5_SALDO_Q > 0"

   cQuery:=ChangeQuery(cQuery)
   TcQuery cQuery ALIAS (cAliasSW5) NEW                               
   If Select(cAliasSW5) <> 0
      nContSW5  := (cAliasSW5)->Contador
      (cAliasSW5)->(DbCloseArea())
   Endif
 

   IncProc(STR0052) //"Contando Registros...."
      
   // SW3
   cQuery :=  cSelect + RetSqlName('SW3') + " WHERE W3_FILIAL='" + cFilSW3+ "'" + ;
	          If(TcSrvType()<>"AS/400",cCondDel,"")		  

   cQuery:=ChangeQuery(cQuery)
   TcQuery cQuery ALIAS (cAliasSW3) NEW                               
   If Select(cAliasSW3) <> 0
      nContSW3  := (cAliasSW3)->Contador
      (cAliasSW3)->(DbCloseArea())
   Endif      
Endif

If Str(cModoImp,1) $ "2/3"   // Exportacao ou Ambos

   IncProc(STR0052) //"Contando Registros...."

   // ED3
   cQuery :=  cSelect + RetSqlName('ED3') + " WHERE ED3_FILIAL='" + cFilED3+ "' "+;
	        If(TcSrvType()<>"AS/400",cCondDel,"")+;
	        If(cTipoPed<>"2","AND (ED3_AC <> '' OR ED3_AC <> ' ') ","")+"AND ED3_SALDO > 0 "

   cQuery:=ChangeQuery(cQuery)
   TcQuery cQuery ALIAS (cAliasED3) NEW                               
   If Select(cAliasED3) <> 0
      nContED3  := (cAliasED3)->Contador
      (cAliasED3)->(DbCloseArea())
   Endif
 
   IncProc(STR0052) //"Contando Registros...."
                         
   // EE9
   cQuery :=  cSelect + RetSqlName('EE9') + " WHERE EE9_FILIAL='" +cFilEE9+ "' AND EE9_STATUS <> '*' " +;
  		    If(TcSrvType()<>"AS/400",cCondDel,"")

   cQuery:=ChangeQuery(cQuery)
   TcQuery cQuery ALIAS (cAliasEE9) NEW                               
   If Select(cAliasEE9) <> 0
      nContEE9  := (cAliasEE9)->Contador
      (cAliasEE9)->(DbCloseArea())
   Endif


   IncProc(STR0052) //"Contando Registros...."
                   
   If !lEE8Interface
      // EE8
      cQuery :=  cSelect + RetSqlName('EE8') + " WHERE EE8_FILIAL='" + cFilEE8+ "' "+;
               If(TcSrvType()<>"AS/400",cCondDel,"")+"AND EE8_SLDINI > 0 "

      cQuery:=ChangeQuery(cQuery)
      TcQuery cQuery ALIAS (cAliasEE8) NEW
      If Select(cAliasEE8) <> 0
         nContEE8  := (cAliasEE8)->Contador
         (cAliasEE8)->(DbCloseArea())
      Endif
   Else
      ExecBlock("EDCCO150",.F.,.F.,"CONTA_REGS")
   EndIf
Endif

Return .T.

*------------------------------------*
Static Function GeraQuery()
*------------------------------------*
Local cQuery, cCondDel:="AND D_E_L_E_T_ <> '*' "

ProcRegua(If(Str(cModoImp,1) = "1", 4, If(Str(cModoImp,1) = "2", 3, 7)))               

If Str(cModoImp,1) $ "1/3"   // Importacao ou Ambos

   IncProc(STR0053) //"Apurando Dados...."

   // ED4
   cQuery :=  "SELECT ED4_FILIAL, ED4_AC, ED4_QT_DI, ED4_VL_LI, ED4_SEQSIS, ED4_DT_VAL, ED4_ITEM, ED4_UMITEM, ED4_NCM, "+;
              "ED4_UMNCM, ED4_QT_DI, ED4_SNCMDI, ED4_VL_DI, ED4_CAMB, ED4_CNPJIM, ED4_VL_LI, ED4_QT_LI, ED4_PD "+;
	          "FROM " + RetSqlName('ED4') + " WHERE ED4_FILIAL='" + cFilED4+ "' "+;
	          If(TcSrvType()<>"AS/400",cCondDel,"")+;
	          If(cTipoPed<>"2","AND (ED4_AC <> '' OR ED4_AC <> ' ') ","")+;
	          "AND (ED4_QT_DI > 0 OR ED4_VL_DI > 0) "+;
              IIF(!Empty(dDtIni)," AND (ED4_DT_VAL <> '' OR ED4_DT_VAL <> ' ') AND ED4_DT_VAL > '"+DToS(dDtIni)+"' ","")+;  //** PLB 15/03/06 - Condição era verificada na funcao CO150IMPRIME()
	          IIF(!Empty(dDtFim)," AND (ED4_DT_VAL <> '' OR ED4_DT_VAL <> ' ') AND ED4_DT_VAL < '"+DToS(dDtFim)+"' ","")

   cQuery:=ChangeQuery(cQuery)
   TcQuery cQuery ALIAS (cAliasED4) NEW                               
   If Select(cAliasED4) <> 0
      TCSETFIELD(cAliasED4,"ED4_DT_VAL","D")
   Endif


   IncProc(STR0053) //"Apurando Dados...."


   // SW8
   cQuery:= "SELECT W8_FILIAL, W8_HAWB, W8_AC, W8_SEQSIS, W8_COD_I, W8_PRECO, W8_QTDE, "+;
            "W8_POSICAO, W8_FLUXO "+;
	        "FROM "+ RetSqlName('SW8') +" WHERE W8_FILIAL='" + cFilSW8+ "' "+;
   		    If(TcSrvType()<>"AS/400",cCondDel,"")+;
   		    "AND (W8_AC <> '' OR W8_AC <> ' ') "

   cQuery:=ChangeQuery(cQuery)
   TcQuery cQuery ALIAS (cAliasSW8) NEW


   IncProc(STR0053) //"Apurando Dados...."


   // SW5
   cQuery:= "SELECT W5_FILIAL, W5_AC, W5_QT_AC, W5_SEQSIS, W5_PGI_NUM, W5_HAWB, W5_QTDE, W5_SALDO_Q, W5_PRECO, "+;
            "W5_PO_NUM, W5_COD_I, W5_POSICAO, W5_FLUXO, W5_SEQ, W5_DT_ENTR, W5_TEC, W5_DT_EMB "+;
	        "FROM "+ RetSqlName('SW5') +" WHERE W5_FILIAL='" + cFilSW5+ "' "+;
  		    If(TcSrvType()<>"AS/400",cCondDel,"")+;
  		    "AND W5_SEQ = 0 AND W5_SALDO_Q > 0 ORDER BY W5_DT_ENTR, W5_DT_EMB DESC"

   cQuery:=ChangeQuery(cQuery)
   TcQuery cQuery ALIAS (cAliasSW5) NEW
   If Select(cAliasSW5) <> 0
      TCSETFIELD(cAliasSW5,"W5_DT_ENTR","D")
      TCSETFIELD(cAliasSW5,"W5_DT_EMB","D")
   Endif


   IncProc(STR0053) //"Apurando Dados...."


   // SW3
   cQuery:= "SELECT W3_FILIAL, W3_SEQ, W3_QTDE, W3_SALDO_Q, W3_DT_ENTR, W3_PGI_NUM, W3_COD_I, W3_PRECO, "+;
            "W3_PO_NUM, W3_POSICAO, W3_FLUXO, W3_TEC, W3_DT_EMB "+;
	        "FROM "+ RetSqlName('SW3') +" WHERE W3_FILIAL='" + cFilSW3+ "' "+;
 		    If(TcSrvType()<>"AS/400",cCondDel,"")+;
 		    "AND W3_SEQ=0 AND W3_SALDO_Q > 0 ORDER BY W3_DT_ENTR, W3_DT_EMB DESC"

   cQuery:=ChangeQuery(cQuery)
   TcQuery cQuery ALIAS (cAliasSW3) NEW
   If Select(cAliasSW3) <> 0
      TCSETFIELD(cAliasSW3,"W3_DT_ENTR","D")
      TCSETFIELD(cAliasSW3,"W3_DT_EMB","D")
   Endif
Endif

If Str(cModoImp,1) $ "2/3"   // Exportacao ou Ambos

   IncProc(STR0053) //"Apurando Dados...."

   // ED3
   cQuery:= "SELECT ED3_FILIAL, ED3_AC, ED3_QTD, ED3_SAL_CO, ED3_SEQSIS, ED3_DT_VAL, ED3_PROD, ED3_UMPROD, ED3_NCM, "+;
            "ED3_UMNCM, ED3_SALDO, ED3_QTD, ED3_SALNCM, ED3_SAL_SE, ED3_CNPJIM, ED3_PD "+;
	        "FROM "+ RetSqlName('ED3') +" WHERE ED3_FILIAL='" + cFilED3+ "' "+;
	        If(TcSrvType()<>"AS/400",cCondDel,"")+;
	        If(cTipoPed<>"2","AND (ED3_AC <> '' OR ED3_AC <> ' ') ","")+"AND ED3_SALDO > 0 "+;
	        IIF(!Empty(dDtIni)," AND (ED3_DT_VAL <> '' OR ED3_DT_VAL <> ' ') AND ED3_DT_VAL > '"+DToS(dDtIni)+"' ","")+;  //** PLB 15/03/06 - Condição era verificada na funcao CO150IMPRIME()
	        IIF(!Empty(dDtFim)," AND (ED3_DT_VAL <> '' OR ED3_DT_VAL <> ' ') AND ED3_DT_VAL < '"+DToS(dDtFim)+"' ","")
	        
   cQuery:=ChangeQuery(cQuery)
   TcQuery cQuery ALIAS (cAliasED3) NEW
   If Select(cAliasED3) <> 0
      TCSETFIELD(cAliasED3,"ED3_DT_VAL","D")
   Endif


   IncProc(STR0053) //"Apurando Dados...."

   // EE9
   cQuery:= "SELECT EE9_FILIAL, EE9_ATOCON, EE9_STATUS, EE9_RE, EE9_UNIDAD, EE9_PRCTOT, EE9_SLDINI, "+;
            "EE9_PREEMB, EE9_PEDIDO, EE9_COD_I, EE9_SEQEMB, EE9_SEQUEN, EE9_POSIPI, EE9_FORN, EE9_FOLOJA "+;
	        "FROM "+ RetSqlName('EE9') +" WHERE EE9_FILIAL='" +cFilEE9+ "' AND EE9_STATUS <> '*' AND (EE9_RE='' OR EE9_RE=' ') "+;
  		    If(TcSrvType()<>"AS/400",cCondDel,"")

   cQuery:=ChangeQuery(cQuery)
   TcQuery cQuery ALIAS (cAliasEE9) NEW


   IncProc(STR0053) //"Apurando Dados...."

   If !lEE8Interface
      // EE8
      cQuery:= "SELECT EE8_FILIAL, EE8_SLDINI, EE8_DTPREM, EE8_UNIDAD, EE8_PRCTOT, EE8_DTENTR, "+;
               "EE8_PEDIDO, EE8_COD_I, EE8_SEQUEN, EE8_POSIPI, EE8_FORN, EE8_FOLOJA, EE8_STATUS "+;
               "FROM "+ RetSqlName('EE8') +" WHERE EE8_FILIAL='" + cFilEE8+ "' "+;
               If(TcSrvType()<>"AS/400",cCondDel,"")+"AND EE8_SLDINI > 0 " +;
               "ORDER BY EE8_DTENTR, EE8_DTPREM DESC"

      cQuery:=ChangeQuery(cQuery)
      TcQuery cQuery ALIAS (cAliasEE8) NEW                               

      If Select(cAliasEE8) <> 0
         TCSETFIELD(cAliasEE8,"EE8_DTPREM","D")
         TCSETFIELD(cAliasEE8,"EE8_DTENTR","D")
      Endif
   Else
      ExecBlock("EDCCO150",.F.,.F.,"QUERY")
   EndIf
Endif

Return .T.
*--------------------------------------------------------*
Static Function CO150ApuExp(cItem, cPosIPI, cForn, cLoja)
*--------------------------------------------------------*
Local cPos:="", cAto, dDtVal, cCGC
Local nSalRE, cPos2:=""
// LOCAL cPD, nAPos, 
Local cAlias    := "TRB1"
Local nAliasOrd := (cAlias)->(IndexOrd())
Local nOrdED0   := ED0->(IndexOrd())
Local nOrdSA5   := SA5->(IndexOrd())
//** PLB 15/03/06 - Variavel para melhoria de desempenho
Local cOldAC := "" 
Local lRetorno := .T.
//**
Private cUnid

ED0->(dbSetOrder(2))
SA5->(dbSetOrder(3))

cCGC := CGCFor(cForn, cLoja)

(cAlias)->(dbSetOrder(2))
(cAlias)->(dbSeek(cCGC+cItem+DtoS(dDataBase),.T.))  //SoftSeek

cOldAC := (cAlias)->ED3_AC  // PLB 15/03/06

If !ED0->(dbSeek(cFilED0+(cAlias)->ED3_AC))
   ED0->(dbSetOrder(1))
   ED0->(dbSeek(cFilED0+(cAlias)->ED3_AC))
//   ED0->(dbSetOrder(2))
EndIf

If (cAlias)->ED3_CNPJIM==cCGC .and. (cAlias)->ED3_PROD==cItem
   If !Empty((cAlias)->ED3_AC) .and. (cAlias)->ED3_DU_QT > 0 .and. Empty(ED0->ED0_DT_ENC)
      cPos    := (cAlias)->ED3_SEQSIS
      cAto    := (cAlias)->ED3_AC
      dDtVal  := (cAlias)->ED3_DT_VAL
      nSalRE  := (cAlias)->ED3_DU_QT
   EndIf
EndIf

(cAlias)->(dbSetOrder(3))
(cAlias)->(dbSeek(cCGC+cPosIPI+Space(Len((cAlias)->ED3_PROD))+DtoS(dDataBase),.T.))  //SoftSeek

If cOldAC != (cAlias)->ED3_AC  // PLB 15/03/06
   ED0->(dbSetOrder(2))
   If !ED0->(dbSeek(cFilED0+(cAlias)->ED3_AC))
      ED0->(dbSetOrder(1))
      ED0->(dbSeek(cFilED0+(cAlias)->ED3_AC))
//      ED0->(dbSetOrder(2))
   EndIf
EndIf

If (cAlias)->ED3_CNPJIM==cCGC .and. (cAlias)->ED3_NCM==cPosIPI .and. (cAlias)->ED3_PROD==Space(Len((cAlias)->ED3_PROD))
   If !Empty((cAlias)->ED3_AC) .and. (cAlias)->ED3_DU_QT > 0 .and. Empty(ED0->ED0_DT_ENC) 
      cPos2 := (cAlias)->ED3_SEQSIS
   EndIf
EndIf
   
/*If !Empty(cPos) .and. !Empty(cPos2)
   If MelhorAC(dDtVal,nSalRE)
      (cAlias)->(dbSetOrder(1))
      (cAlias)->(dbSeek(cAto+cPos))
   EndIf
ElseIf Empty(cPos) .and. Empty(cPos2)
   lOk := .F.
ElseIf Empty(cPos2)
   (cAlias)->(dbSetOrder(1))
   (cAlias)->(dbSeek(cAto+cPos))
EndIf*/
//** PLB 15/03/06
If Empty(cPos) .and. Empty(cPos2)
   lRetorno := .F.
ElseIf Empty(cPos2) .Or. (!Empty(cPos) .and. MelhorAC(dDtVal,nSalRE))
   (cAlias)->(dbSetOrder(1))
   (cAlias)->(dbSeek(cAto+cPos))
EndIf
//**
   
(cAlias)->(dbSetOrder(nAliasOrd))
SA5->(dbSetOrder(nOrdSA5))
ED0->(dbSetOrder(nOrdED0))

Return lRetorno

*--------------------------------------------*
Static Function CGCFor(cCodFor,cLoja,lInteiro)
*--------------------------------------------*
Local cCNPJ, nOldSA2Ord:=SA2->(IndexOrd())
Local cOldArea:=Select()
lInteiro:=If(lInteiro<>NIL,lInteiro,.F.)
If(Empty(cLoja), cLoja:=Space(0) ,)

SA2->(dbSetOrder(1))
SA2->(dbSeek(cFilSA2Aux+cCodFor+cLoja))
If lInteiro
   cCNPJ := SA2->A2_CGC
Else
   cCNPJ := Left(SA2->A2_CGC,8)
EndIf
SA2->(dbSetOrder(nOldSA2Ord))

dbSelectArea(cOldArea)

Return cCNPJ

*------------------------*
Static Function FechaTop()
*------------------------*
If lTop
   If Select(cAliasED3) <> 0
	  (cAliasED3)->(DbCloseArea())
   Endif

   If Select(cAliasED4) <> 0
   	  (cAliasED4)->(DbCloseArea())
   Endif

   If Select(cAliasSW3) <> 0
	  (cAliasSW3)->(DbCloseArea())
   Endif

   If Select(cAliasSW5) <> 0
   	  (cAliasSW5)->(DbCloseArea())
   Endif

   If Select(cAliasSW8) <> 0
	  (cAliasSW8)->(DbCloseArea())
   Endif

   If Select(cAliasEE9) <> 0
   	  (cAliasEE9)->(DbCloseArea())
   Endif

   If Select(cAliasEE8) <> 0
   	  (cAliasEE8)->(DbCloseArea())
   Endif
Endif

Return .T.

*------------------------------*
Static Function EDCCOGERADBF()
*------------------------------*
Local oDlg, nOp:=0, oCbx, lRet:= .T.
Private cGera:=Space(1), aGera:={"1 - Sim","2 - Não"}

DEFINE MSDIALOG oDlg TITLE STR0067; //"Geração de Arquivo DBF/TXT"
       FROM 12,05 To 20,45 OF GetwndDefault()

   @01,04 SAY STR0068 of oDlg //"Gera Arquivo"
   cGera := "1"
   @01,09 ComboBox oCbx Var cGera Items aGera Valid (!Empty(cGera)) SIZE 52,08 of oDlg

   DEFINE SBUTTON FROM 40,45 TYPE 13 ACTION (nOp:=1,oDlg:End()) ENABLE OF oDlg //Salvar Arq.
   DEFINE SBUTTON FROM 40,80 TYPE 2 ACTION (nOp:=0,oDlg:End()) ENABLE OF oDlg  //Cancel

ACTIVATE MSDIALOG oDlg CENTERED

If nOp = 1 .And. Left(cGera,1)=="1"
   TR350ARQUIVO("Work")
Else
   lRet:= .F.
EndIf

Return lRet

*----------------------------------*
Static Function EDCCOGRVDBF(cParam)
*----------------------------------*
Local i

Work->(dbAppend())

If cParam == "I" .Or. cParam == "MOV/I"    

   Work->ED4_AC     :=TRB2->ED4_AC
   Work->ED4_CNPJIM :=SYT->YT_CGC
   Work->ED4_IMPOR  :=SYT->YT_NOME
   Work->ED4_DT_VAL :=TRB2->ED4_DT_VAL
   Work->ED4_DIAS_R :=If(!Empty(Work->ED4_DT_VAL), (Work->ED4_DT_VAL - dDataBase),0) //If(cParam == "I", (TRB2->ED4_DT_VAL - dDataBase), (TRB1->ED3_DT_VAL - dDataBase))
   Work->ED4_ITEM   :=TRB2->ED4_ITEM
   Work->ED4_UMITEM :=TRB2->ED4_UMITEM
   Work->ED4_NCM    :=TRB2->ED4_NCM
   Work->ED4_UMNCM  :=TRB2->ED4_UMNCM //If(ED0->ED0_MODAL == "1", TRB2->ED4_UMNCM, )
   Work->ED4_QT_DI  :=TRB2->ED4_QT_DI
   Work->ED4_SALDO  :=TRB2->ED4_SALDO
   
   If cTPRel == "1" //Str(cTipoRel,1) == "1" //Analítico
      Work->ED4_DU_QT  :=TRB2->ED4_DU_QT
      Work->ED4_DU_VL  :=TRB2->ED4_DU_VL
      Work->ED4_QT_LI  :=AVTransUnid(TRB2->ED4_UMITEM,TRB2->ED4_UMNCM,TRB2->ED4_ITEM,TRB2->ED4_DU_QT)
      //If ED0->ED0_MODAL == "2" //Isenção
      //   Work->ED4_UMNCM := TRB2->ED4_UMNCM
      //Endif
   Endif
   
   Work->ED4_VL_DI  :=TRB2->ED4_VL_DI
   Work->ED4_CAMB   :=If(TRB2->ED4_CAMB == "1", "Sim", "Nao")
   Work->ED4_MEMO   :=TRB2->ED4_MEMO
   Work->TRB2_MODAL :=If(ED0->ED0_MODAL=="1", "Suspensão", "Isenção")
   Work->TRB2_PD    :=ED0->ED0_PD 
   
ElseIf cParam == "E" .Or. cParam == "MOV/E"
   Work->ED4_AC     :=TRB1->ED3_AC
   Work->ED4_CNPJIM :=SYT->YT_CGC
   Work->ED4_IMPOR  :=SYT->YT_NOME
   Work->ED4_DT_VAL :=TRB1->ED3_DT_VAL
   Work->ED4_DIAS_R :=If(!Empty(Work->ED4_DT_VAL), (Work->ED4_DT_VAL - dDataBase),0) //If(cParam == "I", (TRB2->ED4_DT_VAL - dDataBase), (TRB1->ED3_DT_VAL - dDataBase))
   Work->ED4_ITEM   :=TRB1->ED3_PROD
   Work->ED4_UMITEM :=TRB1->ED3_UMPROD
   Work->ED4_NCM    :=TRB1->ED3_NCM
   Work->ED4_UMNCM  :=If(ED0->ED0_MODAL == "1", TRB1->ED3_UMNCM, )
   Work->ED4_QT_DI  :=TRB1->ED3_QTD
   Work->ED4_DU_QT  :=If(/*Str(cTipoRel,1)*/cTPRel == "1", TRB1->ED3_DU_QT, )
   Work->ED4_SALDO  :=TRB1->ED3_SALDO
   Work->ED4_VL_DI  :=TRB1->ED3_SAL_CO
   Work->ED4_DU_VL  :=If(/*Str(cTipoRel,1)*/cTPRel == "1", TRB1->ED3_DU_VL, )
   Work->ED4_QT_LI  :=If(/*Str(cTipoRel,1)*/cTPRel == "1",AVTransUnid(TRB1->ED3_UMPROD,TRB1->ED3_UMNCM,TRB1->ED3_PROD,TRB1->ED3_DU_QT), )
   Work->ED4_MEMO   :=TRB1->ED3_MEMO
   Work->TRB2_MODAL :=If(ED0->ED0_MODAL=="1", "Suspensão", "Isenção")
   Work->TRB2_PD    :=ED0->ED0_PD
Endif

If cTPRel == "2" //Str(cTipoRel,1) == "2"             // Sintetico
    If cParam == "I"
       For i:=1 To MLCOUNT(TRB2->ED4_MEMO,50)
          cLine:=MEMOLINE(TRB2->ED4_MEMO,50,i)
   	      Work->ED4_MEMO:= cLine
       Next i
    ElseIf cParam == "E"
       For i:=1 To MLCOUNT(TRB1->ED3_MEMO,50)
          cLine:=MEMOLINE(TRB1->ED3_MEMO,50,i)
   	      Work->ED3_MEMO:= cLine
       Next i
    Endif
Else
   WORK->TRB2_DI    :=If(cParam == "MOV/I",WORK_M2->TRB2_DI, WORK_M1->TRB1_DI)
   WORK->TRB2_HAWB  :=If(cParam == "MOV/I",WORK_M2->TRB2_HAWB,WORK_M1->TRB1_HAWB)
   WORK->TRB2_COD_I :=If(cParam == "MOV/I",WORK_M2->TRB2_COD_I, WORK_M1->TRB1_COD_I)
   WORK->TRB2_POS   :=If(cParam == "MOV/I",WORK_M2->TRB2_POS, WORK_M1->TRB1_POS)
   WORK->TRB2_QTDE  :=If(cParam == "MOV/I",WORK_M2->TRB2_QTDE, WORK_M1->TRB1_QTDE)
   WORK->TRB2_QT_NC :=If(cParam == "MOV/I",WORK_M2->TRB2_QT_NC, WORK_M1->TRB1_QT_NC)
   WORK->TRB2_VALOR :=If(cParam == "MOV/I",WORK_M2->TRB2_VALOR, WORK_M1->TRB1_VALOR)
   WORK->TRB2_CAMB  :=If(cParam == "MOV/I",If(WORK_M2->TRB2_CAMB=="1", "Sim", "Nao"), If(WORK_M1->TRB1_CAMB=="1", "Sim", "Nao"))
   WORK->TRB2_OBS   :=If(cParam == "MOV/I",WORK_M2->TRB2_OBS, )//WORK_M1->TRB1_OBS)

   WORK->WORK2_TIPO := If(cParam == "MOV/I" .Or. cParam == "I", "I", "E")
Endif

If cParam == "SEM/I" .Or. cParam == "SEM/E"
   If cTPRel == "1" //Str(cTipoRel,1) = "1"   //Analítico
      WORK->WORK2_DI   := If(cParam == "SEM/I", WORK2->WORK2_DI, WORK1->WORK1_PE)
      WORK->WORK2_HAWB := If(cParam == "SEM/I", WORK2->WORK2_HAWB, WORK1->WORK1_HAWB)
      WORK->WORK2_COD  := If(cParam == "SEM/I", WORK2->WORK2_COD, WORK1->WORK1_COD)
      WORK->WORK2_POS  := If(cParam == "SEM/I", WORK2->WORK2_POS, WORK1->WORK1_POS)
      WORK->WORK2_QTDE := If(cParam == "SEM/I", WORK2->WORK2_QTDE, WORK1->WORK1_QTD)
      WORK->WORK2_QTN  := If(cParam == "SEM/I", WORK2->WORK2_QTN, WORK1->WORK1_QTN)
      WORK->WORK2_VAL  := If(cParam == "SEM/I", WORK2->WORK2_VAL, WORK1->WORK1_VAL)
      WORK->WORK2_CGC  := If(cParam == "SEM/I", BuscaCNPJ(WORK2->WORK2_IMP,.T.), WORK1->WORK1_EXP+" - "+SA2->A2_NOME)
      WORK->WORK2_IMP  := If(cParam == "SEM/I", WORK2->WORK2_IMP+" - "+E_Field2(WORK2->WORK2_IMP,"SYT",1,"YT_NOME"), SA2->A2_CGC)
   Else
      WORK->WORK2_IMP  := STR0019
   Endif

   WORK->WORK2_TIPO:= If(cParam == "SEM/I", "I", "E")

Endif

Return .T.
