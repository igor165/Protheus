#INCLUDE "Eictp252.ch"
#include "Average.ch"
#INCLUDE "TOPCONN.CH"


#COMMAND E_RESET_AREA => SW3->(DBSETORDER(1)) ; SW5->(DBSETORDER(1))   ;
		       ; SW7->(DBSETORDER(1)) ;
		       ; IF(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"E_RESET_AREA"),) ;
		       ; If(Select("WorkTP")>0,(WorkTP->(E_EraseArq(cFileWork,cFileNTX2,cFileNTX3)),FERASE(cFileNTX4+TEOrdBagExt())),);
		       ; DBSELECTAREA(nOldArea)


#define  Realizado      "1"
#define  Pre_X_Real     "2"
#define  Pre_Calculo    "3"

#define  MsgPesq      STR0001 //"PESQUISANDO DADOS - AGUARDE..."
#define  K_ESC         27
#define  _Analitico     1
#define  _Sintetico     2
#define  _Embarque      1
#define  _PO            2
#define  _Despesa       3
#define  _Data          4
#define  DESPESA_FOB    "101"
#define  DESPESA_FRETE  "102"
#define  DESPESA_SEGURO "103"
#define  VALOR_CIF      "104"
#define  DESPESA_II     "201"
#define  DESPESA_IPI    "202"
#define  DESPESA_ICMS   "203"
#define  DESPESA_PIS    "204"  //MLS 26/04/2004
#define  DESPESA_COFINS "205"  //MLS 26/04/2004
#define  ADIANTAMENTO   "901"
#DEFINE  New_Line     CHR(13)+CHR(10)
#DEFINE  EOF_Text     CHR(26)
#DEFINE  RATEIOFRETE  EVAL({||SX3->(DBSETORDER(2)),IF(SX3->(DBSEEK('WF_IDFRETE')),SWF->WF_IDFRETE,' ')})

#XTRANSLATE :PO_NUM     => \[1\]
#XTRANSLATE :COD_I      => \[2\]
#XTRANSLATE :SALDO_Q    => \[3\]
#XTRANSLATE :PRECO      => \[4\]
#XTRANSLATE :DT_EMB     => \[5\]
#XTRANSLATE :DT_ENTR    => \[6\]
#XTRANSLATE :POSICAO    => \[7\]

// vide tambem funcao TPCCalculo no PADRAO3E
#XTRANSLATE :Dt_Pagto   => \[1\]
#XTRANSLATE :Vl_Pagto   => \[2\]
#XTRANSLATE :QTDDIAS    => \[2\]
#XTRANSLATE :DESP       => \[3\]
#XTRANSLATE :MOEDA      => \[4\]
#XTRANSLATE :VALOR      => \[5\]
#XTRANSLATE :PERCAPL    => \[6\]
#XTRANSLATE :DESPBAS    => \[7\]
#XTRANSLATE :Dt_Real    => \[3\]
#XTRANSLATE :FPerc      => \[4\]
#XTRANSLATE :FDias      => \[5\]
#XTRANSLATE :FInvoice   => \[6\]

#COMMAND  TRSEEK   => DBSeek(xFilial()+" 0        0.001",.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³EICTP252   ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 07.05.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Previsao de Desembolso Financeiro                            ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	Last change:  US   12 Nov 99    4:29 pm
*/
Function EICTP252(aAvFluxo)

   //DFS - 12/07/10 - Inclusão de tratamento para trocar o nome dos títulos das colunas no Excel
   Local aStruct := { { "WKDT_PAGTO" , "D" ,  8 , 0 }  ,;
                     { "WKDESPESA"  , "C" ,  3 , 0 }  ,;
                     { "WKPO_NUM"   , "C" , 15 , 0 }  ,;
                     { "WKMOEDA"    , "C" ,  3 , 0 }  ,;
                     { "WKVL_PAGTO" , "N" , 15 , 2 }  ,;
                     { "WKDESPDESC" , "C" , 30 , 0 }  ,;
                     { "WKFORN_N"   , "C" , 30 , 0 }  ,;
                     { "WKFORN_R"   , "C" , 20 , 0 }  ,;
                     { "WKNUM_PC"   , "C" , 04 , 0 }  ,;
                     { "WKDT_EMB"   , "D" , 08 , 0 }  ,;
                     { "WKCONDICAO" , "C" , 08 , 0 }  ,;
                     { "WKFOBPERC"  , "N" , 06 , 2 }  ,;
                     { "WK_HAWB"    , "C" , 17 , 0 }  ,;
                     { "WK_CHEG"    , "C" , 17 , 0 }  ,;
                     { "WKFOBDIAS"  , "N" , 03 , 0 }  ,;
                     { "WKVLPAGTO2" , "N" , 17 , 8 }  }   // GFP - 16/01/2014



   LOCAL aAlias:={"W2","W3","W4","W5","W6","W7","WD","WI","YB","YQ",;
            "YR","Y6","B1","A2","YE","YD","WB"}
   LOCAL aWork:={}, cImport, nOpca:=1, nOldArea:=Select(),;
         L1:=9, MMes, MAno, TMes:=MONTH(dDataBase),;
         TAno:=YEAR(dDataBase), ind_dt, MMsg, oDlg, oPanel

   LOCAL bNewDate:={|mes,ano| AVCTOD('01/'+STRZERO(mes,2)+'/'+STR(ano,4,0)) }

   LOCAL cFileWork, cFileNTX2, cFileNTX3, lCriou:=.T.,;
         dMenorDt:=AVCTOD("01/01/"+STRZERO(Set(_SET_EPOCH),4))

   Local nPosLj:= 0, nPosCampo
   Local nRecWK := 0  // GFP - 09/06/2014

   Private b252Print := {||TPC252Print(MTotGer,MTipo,MOrdem,TDT_I,TDT_F,MSubTit)}

   //DFS - 12/07/10 - Inclusão de tratamento para trocar o nome dos títulos das colunas no Excel
   Private aTitulos  := { {"Data"               ,"WKDT_PAGTO"     ,"",,,"",,"D"},;
                        {"Despesa"            ,"WKDESPESA"      ,"",,,"",,"C"},;
                        {"PO"                 ,"WKPO_NUM"       ,"",,,"",,"C"},;
                        {"Valor Pagamento"    ,"WKVL_PAGTO"     ,"",,,"",,"N"},;
                        {"Descrição"          ,"WKDESPDESC"     ,"",,,"",,"C"},;
                        {"Fornecedor"         ,"WKFORN_N"       ,"",,,"",,"C"},;
                        {"Cod Fornecedor"     ,"WKFORN_R"       ,"",,,"",,"C"},;
                        {"Numero PC"          ,"WKNUM_PC"       ,"",,,"",,"C"},;
                        {"Data embarque"      ,"WKDT_EMB"       ,"",,,"",,"D"},;
                        {"Condição"           ,"WKCONDICAO"     ,"",,,"",,"C"},;
                        {"Percentual FOB"     ,"WKFOBPERC"      ,"",,,"",,"N"},;
                        {"Processo"           ,"WK_HAWB"        ,"",,,"",,"C"},;
                        {"Chegada"            ,"WK_HAWB"        ,"",,,"",,"C"},;
                        {"Dias FOB"           ,"WKFOBDIAS"      ,"",,,"",,"N"}}

   Private aDelCampos := {"WKVLPAGTO2","WKMOEDA"}

   //CCH - 23/09/2008 - Variável TB_Campos alterada para Private conforme solicitado por Fernando Rossetti
   Private TB_Campos:={;
                  { "WKDT_PAGTO"                               ,, STR0002     }  ,; //"Data"
                  {{||TRAN(WorkTP->WKDESPESA,'@R 9.99')+' '+WorkTP->WKDESPDESC},, STR0003     }  ,; //"Despesa"
                  { "WKPO_NUM"                                 ,, STR0004     }  ,; //"No. P.O."
                  { "WKMOEDA"                               ,, STR0108} ,; //"Moeda"
                  { "WKVL_PAGTO"                               ,, STR0005,'@E 999,999,999,999,999.99'} ,; //"Valor"
                  { "WKFORN_R"                                 ,, STR0006         }  ,; //"Fornecedor"
                  { "WKNUM_PC"                                 ,, STR0007         }  } //"Tabela"

   Private MLin := 0  // GFP - 16/10/2013 - Declarado como private para ser usada em Ponto de Entrada
   PRIVATE lAvIntDesp  := AvFlags("AVINT_PR_EIC") .OR. AvFlags("AVINT_PRE_EIC")  //TRP - 12/12/2014 - LOGIX

   //TRP -  07/02/2012 - Tratamento de Loja para geração de arquivo em Excel.
   If EICLOJA() .And. (nPosLj := aScan(aTitulos, {|x| x[2] == "WKFORN_R" })) <> 0
      aAdd(aTitulos, Nil)
      aIns(aTitulos, nPosLj + 1)
      aTitulos[nPosLj+1] := {"Loja Fornecedor"     ,"WKFORLOJ"       ,"",,,"",,"C"}
   EndIf

   If !(aAvFluxo == NIL)
      lAvFluxo:=.T.
      cProcNum:=aAvFluxo[1]
      cImporta:=aAvFluxo[2]
   Else
      cProcNum:=''
      cImporta:=''
      lAvFluxo:=.F.
   Endif

   IF EasyEntryPoint("EICPTR01")
            Private aInvoice          := {}
            Private cInv              := ""
            Private cAux              := ""
            Private MInvoice         := ""
            Private lDespAnalitico :=.F., lDespSintetico:=.F. //Usado no RdMake Eicptr01
   EndIf

   PRIVATE cMarca := GetMark(), lInverte := .F.

   PRIVATE cCadastro := OemtoAnsi(STR0008) //"Previsao de Desembolso em US$"

   PRIVATE aHeader[0]

   PRIVATE TDT_I, TDT_F, MTipo:=1, MOrdem, MTotGer

   //somente devido a macro-substituicao no Help

   PRIVATE TImport:="  ", TPO_NUM:=SPACE(LEN(SW7->W7_PO_NUM)), TDESP:=SPACE(03), THAWB:=SPACE(LEN(SW6->W6_HAWB))

   PRIVATE cPictGeral:='@E 9,999,999,999,999.99'

   PRIVATE cMOEDAEST := BuscaDolar()//ALLTRIM(EasyGParam("MV_SIMB2"))+SPACE(LEN(SW2->W2_MOEDA)-LEN(EasyGParam("MV_SIMB2")))
   PRIVATE MTx_Usd   := BuscaTaxa(cMOEDAEST,dDataBase,.T.,.F.,.T.)

   PRIVATE aPagamento:={} //Usado Para Atualizar o RdMake Eicptr01
   Private _PictPO := ALLTRIM(X3Picture("W2_PO_NUM"))

   IF (++TMes) > 12
      TMes:=1
      TAno++
   ENDIF

   TDT_I:=EVAL(bNewDate,TMes,TAno)
   TDT_F:=EVAL(bNewDate,IF(TMes+1>12,1,TMes+1),IF(TMes+1>12,TAno+1,TAno)) - 1

   Private MSubTit , aParc_Pgtos:={} , cPO_Num:=""
   Private lDesvioRDM := .F. // RA - Usada neste programa e no RdMake EICTP252_RDM
   Private nSomaCol   := 0   // RA - Usada neste programa e no RdMake EICTP252_RDM
   IF(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"INICIA_VARIAVEIS"),) // RA

   DO WHILE .T.

      TB_Campos:={}
      AADD(TB_Campos,{"WKDT_PAGTO"                                ,, STR0002     }) //"Data"
      AADD(TB_Campos,{{||TRAN(WKDESPESA,'@R 9.99')+' '+WKDESPDESC},, STR0003     }) //"Despesa"
      AADD(TB_Campos,{ "WKPO_NUM"                                 ,, STR0004     }) //"No. P.O."
      //AADD(TB_Campos,{ "WKMOEDA"                               ,, STR0108}) //"Moeda"
      AADD(TB_Campos,{ "WKVL_PAGTO"        ,, STR0005,'@E 999,999,999,999,999.99'}) //"Valor"
      AADD(TB_Campos,{ "WKFORN_R"                                 ,, STR0006     }) //"Fornecedor"
      If EICLoja()
         AADD(TB_Campos,{ "WKFORLOJ",, "Loja"})
      EndIf
      AADD(TB_Campos,{ "WKNUM_PC"                                 ,, STR0007     }) //"Tabela"

      lDespAnalitico:=.F.//Usado no Rdmake Eicptr01
      lDespSintetico:=.F.//Usado no Rdmake Eicptr01

      If !lAvFluxo
      IF !Pergunte("EI252A",.T.)
         E_RESET_AREA
         RETURN
      ENDIF
      TImport:=mv_par01
      MTipo  :=mv_par02
      MOrdem :=mv_par03
      Else
         TImport:=cImporta
         MTipo  :=_Analitico
      MOrdem :=_Embarque
      ENDIF

      cImport:=IF(!EMPTY(TImport),TImport+" - "+SYT->YT_NOME,STR0009) //"GERAL"

      IF(MTipo = _Analitico, MSubTit:=STR0010,MSubTit:=STR0011) //"Analitico"###"Sintetico"

      TPC252Ordem(MTipo,L1)

      IF MOrdem = 0
         LOOP
      ENDIF

      IF MOrdem = _Embarque
         TDT_I:=dMenorDt; TDT_F:=AVCTOD('31/12/49')
         TPO_NUM:=SPACE(LEN(SW7->W7_PO_NUM))
            TDESP:=SPACE(03)
         TB_Campos[1]:= {"WK_HAWB"   ,,STR0012} //"Processo"
            //TB_Campos[2]:= {"WKPO_NUM"  ,,STR0004} //"No. P.O."  // GFP - 19/05/2014
         TB_Campos[3]/*[4]*/:= {"WKDT_PAGTO",,STR0002} //"Data"
         TB_Campos[2]/*[3]*/:= {{||TRAN(WorkTP->WKDESPESA,'@R 9.99')+' '+WorkTP->WKDESPDESC},, STR0003 } //"Despesa"
            //AADD(TB_Campos,{ "WKMOEDA" ,, STR0108}) //"Moeda"
            If (nPos := aScanX(TB_Campos,{|x,y| x[1] == "WKVL_PAGTO" .AND. y <= 5},4)) # 0
               aDel(TB_Campos,nPos)
               aSize(TB_Campos,Len(TB_Campos)-1)
               AADD(TB_Campos,{ "WKVL_PAGTO"        ,, STR0005,'@E 999,999,999,999,999.99'}) //"Valor"
            EndIf

         If !lAvFluxo
            IF !Pergunte("EI252E",.T.)
               LOOP
            ENDIF
            THAWB:=mv_par01
         Else
            THAWB:=cProcNUm
         Endif

         MSubTit+=IF(EMPTY(THAWB),STR0013,STR0014+ THAWB) //', todos os Processos'###', Processo '

      ENDIF

      IF MOrdem = _PO
         TDT_I:=dMenorDt ; TDT_F:=AVCTOD('31/12/49')
         TDESP:=SPACE(03); THAWB:=SPACE(LEN(SW6->W6_HAWB))
         TB_Campos[1]:= {"WKPO_NUM"  ,,STR0004} //"No. P.O."
         TB_Campos[2]:= {"WKDT_PAGTO",,STR0002    } //"Data"
         TB_Campos[3]:= {{||TRAN(WorkTP->WKDESPESA,'@R 9.99')+' '+WorkTP->WKDESPDESC},, STR0003 } //"Despesa"
         Ind_Dt:=2

         IF !Pergunte("EI252B",.T.)
               LOOP
         ENDIF

         TPO_NUM:=mv_par01

         MSubTit+=IF(EMPTY(TPO_NUM),STR0015,; //', todos os P.O.s'
                  STR0016+ TRAN(TPO_NUM,_PictPO)) //', P.O. No. '
      ENDIF

      IF MOrdem = _Despesa
         TPO_NUM:=SPACE(LEN(SW7->W7_PO_NUM))
         TDT_I:=dMenorDt ; TDT_F:=AVCTOD('31/12/49')
         THAWB:=SPACE(LEN(SW6->W6_HAWB))
         TB_Campos[1]:= {{||TRAN(WorkTP->WKDESPESA,'@R 9.99')+' '+WorkTP->WKDESPDESC},, STR0003 } //"Despesa"
         TB_Campos[2]:= {"WKDT_PAGTO" ,, STR0002    } //"Data"
         TB_Campos[3]:= {"WKPO_NUM"   ,, STR0004} //"No. P.O."
         Ind_Dt:=2

            AADD(TB_Campos,{"WK_HAWB",,STR0012}) //"Processo"

         IF EasyEntryPoint("EICPTR01")
            If EasyExRdm("U_EICPTR01", "1", @MTipo, @_Analitico, @lDespAnalitico, @lDespSintetico, @TDESP, @TDT_I, @TDT_F, @TB_Campos)
                  Loop
               EndIf
         ELSE
               lPergunta:=.T.
               lLoop    :=.F.
               IF(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"GET_DEPESA"),)
            IF lPergunta .AND. !Pergunte("EI252C",.T.)
               LOOP
            ENDIF
               IF lLoop
               LOOP
            ENDIF
               TDESP:=mv_par01
            ENDIF

            If !lDesvioRDM
               MSubTit+=IF(EMPTY(TDESP),STR0017,STR0018+; //', todas as despesas'###', despesa '
                        TRAN(TDESP,'@R 9.99 ')+ALLTRIM(LEFT(SYB->YB_DESCR,15)))
            EndIf

         ENDIF

      IF MOrdem == _Data
         TDESP  :=SPACE(03)
         IF MTipo == _Sintetico
            Help("", 1, "AVG0000570")//MSGStop(OemToAnsi(STR0019),OemToAnsi(STR0020)) //"Ordem Por Data somente para Relat¢rio Anal¡tico"###"Aten‡Æo"
            LOOP
         ENDIF

         TPO_NUM:=SPACE(LEN(SW7->W7_PO_NUM))
         TDT_I:=dMenorDt ; TDT_F:=AVCTOD('31/12/49')
         THAWB:=SPACE(LEN(SW6->W6_HAWB))
         TB_Campos[1]:= {"WKDT_PAGTO" ,, STR0002    } //"Data"
         TB_Campos[2]:= {{||TRAN(WKDESPESA,'@R 9.99')+' '+WorkTP->WKDESPDESC},, STR0003 } //"Despesa"
         TB_Campos[3]:= {"WKPO_NUM"   ,, STR0004} //"No. P.O."
         AADD(TB_Campos,{"WK_HAWB",,STR0012}) //"Processo"

         DO WHILE .T.
         lOK:=Pergunte("EI252F",.T.)
         IF lOK .AND. !TPC252ValAno(.T.)
            LOOP
         ENDIF
         EXIT
         ENDDO
         IF !lOK ; LOOP ; ENDIF

         IF(!EMPTY(mv_par01),TDT_I:=mv_par01,)
         IF(!EMPTY(mv_par02),TDT_F:=mv_par02,)

         MSubTit+=STR0021+DTOC(TDT_I)+STR0022+DTOC(TDT_F) //", Periodo de "###" a "

      ENDIF

      IF(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"ANTES_IF_SINTETICO"),) //ACB - 05/05/2010

      IF MTipo = _Sintetico .AND. MOrdem # _Data

         IF ! Pergunte("EI252D",.T.)
               LOOP
         ENDIF

         TMes:=mv_par01
         TAno:=mv_par02

         MMes:=IF(TMes>0,TMes,++TMes)
         MAno:=TAno

         nNumMeses:=9

         TDT_I:=EVAL(bNewDate,TMes,TAno)
         IF (MMes+=nNumMeses) > 12
            MMes-=12 ; MAno++
         ENDIF                                       // pega ultimo dia do mes
         TDT_F:=EVAL(bNewDate,MMes,MAno) - 1
         MSubTit+=STR0023+SUBSTR(DTOC(TDT_I),4)+STR0024+; //', no periodo de '###' ate '
                  SUBSTR(DTOC(TDT_F),4)
         IF ind_dt # NIL
               TB_Campos[ind_dt]:= {{||SUBSTR(DTOC(WKDT_PAGTO),4)},, STR0025 } //"Mes"
         ENDIF

      ENDIF

      Processa({||lCriou:=EICFluxo("P",aWork,.T.) },STR0026 ) //"Pesquisando processos"

      If lAvFluxo
         RETURN (IF(lCriou,aWork,))
      Endif


      IF !lCriou
         E_RESET_AREA
         LOOP
      ENDIF

      cFileWork:=aWork[1]
      cFileNTX2:=aWork[2]
      cFileNTX3:=aWork[3]
      cFileNTX4:=aWork[4]
      cFileNTX5:=aWork[5]

      DBSELECTAREA("WorkTP") ; DbGoTop()

         DbGoTop()
         //WorkTP->(DBEVAL({||MTotGer+=WorkTP->WKVL_PAGTO},,{||WorkTP->(!EOF())}))
      IF EOF() .AND. BOF()
         Help("", 1, "AVG0000571")//MsgInfo(OemToAnsi(STR0027),OemToAnsi(STR0028)) //"N o h  registros a serem listados"###"Informa‡äes"
         E_RESET_AREA
         cPO_NUM := ""      // GFP - 16/05/2014
         aParc_Pgtos := {}  // GFP - 16/05/2014
         LOOP
      ENDIF

         fob_cambio()

         MTotGer:=0  // GFP - 15/05/2014
         WorkTP->(DbGoTop())
         Do While WorkTP->(!EOF())
            If WorkTP->(!Deleted())
               MTotGer+=WorkTP->WKVL_PAGTO
            EndIf
            WorkTP->(DbSkip())
         EndDo

      IF WorkTP->(EOF()) .AND. WorkTP->(BOF())  // GFP - 20/03/2014
         Help("", 1, "AVG0000571")//MsgInfo(OemToAnsi(STR0027),OemToAnsi(STR0028)) //"N o h  registros a serem listados"###"Informa‡äes"
         E_RESET_AREA
         cPO_NUM := ""      // GFP - 16/05/2014
         aParc_Pgtos := {}  // GFP - 16/05/2014
         LOOP
      ENDIF

      DBSETORDER(MOrdem)

      nRecWK := WorkTP->(Recno())  // GFP - 09/06/2014
      WorkTP->(DbGoTop())
      Do While WorkTP->(!Eof())
         WorkTP->WKDT_EMB := AjustaDtEmb(,WorkTP->WKPO_NUM)
         WorkTP->(DbSkip())
      EndDo
      WorkTP->(DbGoTo(nRecWK))

      oMainWnd:ReadClientCoors()
   //CCH - 23/09/2008 - Inclusão de Ponto de Entrada de acordo com solicitação de Fernando Rossetti.
   //Ponto para alteração da variável TB_Campos antes da chamada da Tela
      If EasyEntryPoint("EICTP252")
         ExecBlock("EICTP252",.F.,.F.,"ALTERA_FILTRO")
      EndIf

      //aCols:= GeraDados("WorkTP") //DFS
      cTitArq:= "Relatório de Previsão de Desembolso"
      //WORK->(DBGOTOP())

      If MTipo == _Sintetico

            nPosCampo := ASCAN(TB_Campos, {|x| x[3] == "Fornecedor"})
            If nPosCampo != 0

               ADel (TB_Campos, nPosCampo)
               ASize (TB_Campos, Len(TB_Campos) - 1)
            EndIf

            nPosCampo := ASCAN(TB_Campos, {|x| x[3] == "Loja"})
            If nPosCampo != 0

               ADel (TB_Campos, nPosCampo)
               ASize (TB_Campos, Len(TB_Campos) - 1)
            EndIf

      EndIf

      DEFINE MSDIALOG oDlg TITLE cCadastro+OemToAnsi(" - "+MSubTit) ;
               FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 ;
                  TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd PIXEL
   //CCH - 23/09/2008 - Alteração do Action utilizando variável conforme solicitação de Fernando Rossetti.

            WorkTP->(DbGoTop())         
            oMark:= MsSelect():New("WorkTP",,,TB_Campos,@lInverte,@cMarca,{40,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
            oMark:oBrowse:bWhen:={||DBSELECTAREA("WorkTP"),.T.}
            @00,00 MsPanel oPanel Prompt "" Size 60,20 of oDlg //LRL 13/04/04 - Painel para alinhamento MDI
            //	     DEFINE SBUTTON FROM 4,(oDlg:nClientWidth-4)/2-30 TYPE 6 ACTION Eval(b252Print) ENABLE OF oPanel

            //DFS - 12/07/10 - Inclusão de tratamento para trocar o nome dos títulos das colunas no Excel
            @5,(oDlg:nClientWidth-4)/2-100 BUTTON "Gera Arquivo" Size 44,11 FONT oDlg:oFont;
                  ACTION (TR350Arquivo("WorkTP",,aTitulos,cTitArq,aDelCampos)) OF oPanel PIXEL
                  //ACTION DlgToExcel({{"GETDADOS","Relatório de Previsão de Desembolso", aTitulos, aCols}}) OF oPanel PIXEL
            //            ACTION (AvExcel(cFileWork,"WorkTP",.F.)) OF oPanel PIXEL

            @5,(oDlg:nClientWidth-4)/2-50 BUTTON "Imprimir" SIZE 44,11 FONT oDlg:oFont ;
               ACTION Eval(b252Print) OF oPanel PIXEL

            @ 0.6,0.5 SAY STR0029 SIZE 40,10 of oPanel //"Importador"
            @ 0.4,4   MSGET cImport SIZE 120,10 WHEN .F. of oPanel

            @ 0.6,20 SAY STR0030 SIZE 40,10 of oPanel //"Total Geral "
            @ 0.4,24 MSGET MTotGer PICTURE cPictGeral WHEN .F. SIZE 65,10 RIGHT of oPanel

            IF(EasyEntryPoint("EICTP252"),Execblock("EICTP252",.F.,.F.,"BUTTON"),) // LDR - 08/12/03

            oPanel:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
            oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
            oMark:oBrowse:Refresh() //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
            oDlg:lMaximized:=.T. //MCF - 21/07/2015

      ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},;
                        {||nOpca:=0,oDlg:End()})) //LRL 13/04/04 - Painel alinhamento MDI.	//BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
      DBSELECTAREA("WorkTP")
      E_RESET_AREA
      cPO_NUM := ""      // GFP - 16/05/2014
      aParc_Pgtos := {}  // GFP - 16/05/2014
      IF nOpca = 0
         EXIT
      ENDIF

   ENDDO

RETURN NIL

//Funcao    ³EicFluxo  ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 07/05/97  ³±±
//Descricao ³Arquivo de Previsao de Desembolso. Utilizado tambem Fluxo de ³±±
//          ³Caixa                                                        ³±±
//Sintaxe e ³EicFluxo(lQual,aWork,lProcessa)                              ³±±
//Parametros³lQual "F" = Fluxo de Caixa                                   ³±±
//          ³      "P" = Previsao de Desembolso - SIGAEIC                 ³±±
//          ³aWork     = array contendo os nomes dos Dbfs e Ntxs gerados  ³±±
//          ³lProcessa = indice se deve ativar a barra de evolucao        ³±±
// Uso      ³SIGAEIC/SIGAFIN                                              ³±±
*----------------------------------------------------------------------------
Function EICFluxo(lQual,aWork,lProcessa)
*----------------------------------------------------------------------------
#IFNDEF DESPESA_FOB
// diretivas utilizadas na funcao TPCCalculo
  #XTRANSLATE :Dt_Pagto   => \[1\]
  #XTRANSLATE :Vl_Pagto   => \[2\]
  #XTRANSLATE :QTDDIAS    => \[2\]
  #XTRANSLATE :DESP       => \[3\]
  #XTRANSLATE :MOEDA      => \[4\]
  #XTRANSLATE :VALOR      => \[5\]
  #XTRANSLATE :PERCAPL    => \[6\]
  #XTRANSLATE :DESPBAS    => \[7\]
  #XTRANSLATE :Dt_Real    => \[3\]
  #XTRANSLATE :FPerc      => \[4\]
  #XTRANSLATE :FDias      => \[5\]

  #define  _Analitico     1
  #define  _Sintetico     2
  #define  _Embarque      1
  #define  _PO            2
  #define  _Despesa       3
  #define  _Data          4

  #define     DESPESA_FOB    "101"
  #define     DESPESA_FRETE  "102"
  #define     DESPESA_SEGURO "103"
  #define     VALOR_CIF      "104"
  #define     DESPESA_II     "201"
  #define     DESPESA_IPI    "202"
  #define     DESPESA_PIS    "204"  //MLS 26/04/2004
  #define     DESPESA_COFINS "205"  //MLS 26/04/2004

#ENDIF

LOCAL bCond_IP :={||!EOF() .AND. xFilial("SW3")=SW3->W3_FILIAL .AND. SW3->W3_SEQ=0 .AND. SW3->W3_SALDO_Q>0}
LOCAL bCond_IG :={||!EOF() .AND. xFilial("SW5")=SW5->W5_FILIAL .AND. SW5->W5_SEQ=0 .AND. SW5->W5_SALDO_Q>0}
LOCAL bCond_ID :={||.T.}
LOCAL bCond_ID1:={||!EOF() .AND. xFilial("SW7")=SW7->W7_FILIAL .AND. SW7->W7_PO_NUM == SW2->W2_PO_NUM}
LOCAL bCond_ID2:={||!EOF() .AND. xFilial("SW7")=SW7->W7_FILIAL}
LOCAL bCond_ID3:={||!EOF() .AND. xFilial("SW7")=SW7->W7_FILIAL .AND. SW7->W7_HAWB == THAWB}

LOCAL bSkip1  :={|imp| (!EMPTY(TImport) .AND.  AllTrim(TImport) # AllTrim(imp)) }  // GFP - 02/10/2013

LOCAL bSkip2  :={|po | !EMPTY(TPO_NUM) .AND. !(ALLTRIM(TPO_NUM)==ALLTRIM(po))}

LOCAL bSkip3  :={|data| (data:Dt_Pagto >= TDT_I .AND. data:Dt_Pagto <= TDT_F)}

LOCAL bSkip4  :={|despesa| despesa # VALOR_CIF}

LOCAL bSkip5  :={|despesa,aDespBase| despesa # VALOR_CIF .AND. ;
		 (! TPC252Pagou(despesa,aDespBase)) }

LOCAL bGrava, nimp, nID

PRIVATE nPesoAcumulado :=0, nQtdeAcumulada :=0, aFrete:={}, aDespBase:={}, aHawbPesoFOB:={}
Private lWKSWB := .F.  // GFP - 24/06/2013

bGrava:={|desp,data,valor,tab,_null,dt_real,fobperc,fobdias,invoic,PDBF| ;
         IF(!EMPTY(data) .AND. data >= TDT_I .AND. data <= TDT_F ,;
  	        TPC252Grava(desp,data,valor,tab,@MTotGer,MTipo,MOrdem,;
                        dt_real,fobperc,fobdias,invoic,PDBF),)}

lPrevisao:=(lQual = "P")

If !lPrevisao
   TImport:="  "
   TPO_NUM:=SPACE(LEN(SW7->W7_PO_NUM))
   TDESP:=SPACE(03)
   TDT_I:=AVCTOD("01/01/"+STRZERO(Set(_SET_EPOCH),4))
   TDT_F:=AVCTOD('31/12/49')
   MTipo:=1
   MOrdem:=1
Endif

SW3->(DbSetOrder(6))
SW5->(DbSetOrder(6))
SW7->(DbSetOrder(2))

WorkFile:=WorkNTX2:=WorkNTX3:=WorkNTX4:=WorkNTX5:=WorkNTX6:=WorkNTX7:=''

/* RMD - 24/11/2021 - A função TP252CriaWork() já possui tratamento para limpar e reaproveitar o temporário
If SELECT("WorkTP") # 0  // GFP - 18/07/2013 - Fechamento da WorkTP para evitar duplicidade de valores.
   WorkTP->(E_EraseArq(WorkFile))
EndIf
*/

TP252CriaWork()

*************************************************************
IF MOrdem # _Embarque

   MMsg:="Verificando Frete P.O. No. "
   DBSELECTAREA("SW3")
   SW3->(DBSETORDER(6))
   TRSEEK
   If lProcessa
      nCont:=0
//    SW3->(DBEVAL({||nCont++},,bCond_IP))
      ProcRegua( SW3->(LASTREC()) )//nCont)
   Endif

   TRSEEK
   TPC252ApuFre("W3_",bCond_IP,bSkip1,bSkip2,bSkip3,bSkip4,MMsg,lProcessa)

   MMsg:="Verificando Frete P.L.I. ref. P.O. No. "
   DBSELECTAREA("SW5")
   SW5->(DBSETORDER(6))
   TRSEEK

   If lProcessa
      nCont:=0
//    SW5->(DBEVAL({||nCont++},,bCond_IG))
      ProcRegua( SW5->(LASTREC()) )//nCont)
   Endif

   TRSEEK
   TPC252ApuFre("W5_",bCond_IG,bSkip1,bSkip2,bSkip3,bSkip4,MMsg,lProcessa)

ENDIF

DBSELECTAREA("SW7")
SW7->(DbSetOrder(2))

IF !EMPTY(TPO_NUM)
   DBSeek(xFilial("SW7")+TPO_NUM)
   bCond_ID:=bCond_ID1
ELSE
   IF EMPTY(THAWB)
      DBSeek(xFilial("SW7"))
      bCond_ID:=bCond_ID2
   ELSE
      SW7->(DbSetOrder(1))
      DBSeek(xFilial("SW7")+THAWB)
      bCond_ID:=bCond_ID3
   ENDIF
ENDIF

MMsg:="Verificando Frete referente a P.O.: "
If lProcessa
   nCont:=0
// SW7->(DBEVAL({||nCont++},,bCond_ID))
   ProcRegua( SW7->(LASTREC()) )//nCont)
Endif

IF !EMPTY(TPO_NUM)
   DBSeek(xFilial("SW7")+TPO_NUM)
ELSE
   IF EMPTY(THAWB)
      DBSeek(xFilial("SW7"))
   ELSE
      DBSeek(xFilial("SW7")+THAWB)
   ENDIF
ENDIF

//** AAF 27/11/08
//TPC252ApuFre("W7_",bCond_ID,bSkip1,bSkip2,bSkip3,bSkip5,MMsg,lProcessa)
//*************************************************************
aRaTotFOB := TPC252CalcFOB(SW7->W7_HAWB)
AADD(aHawbPesoFOB,ACLONE(aRaTotFOB))
//**
MTotGer := 0

IF MOrdem # _Embarque

   MMsg:=STR0032 //"Processando P.O. No. "
   DBSELECTAREA("SW3")
   DBSETORDER(6)
   TRSEEK
   If lProcessa
      nCont:=0
//    SW3->(DBEVAL({||nCont++},,bCond_IP))
      ProcRegua( SW3->(LASTREC()) )//nCont)
   Endif

   TRSEEK
   TPC252Itens("W3_",bCond_IP,bSkip1,bSkip2,bSkip3,bSkip4,bGrava,MMsg,lProcessa)

   MMsg:=STR0033 //"Processando P.L.I. ref. P.O. No. "

   DBSELECTAREA("SW5")
   DBSETORDER(6)
   TRSEEK

   If lProcessa
      nCont:=0
//    SW5->(DBEVAL({||nCont++},,bCond_IG))
      ProcRegua( SW5->(LASTREC()) )//nCont)
   Endif

   TRSEEK
   TPC252Itens("W5_",bCond_IG,bSkip1,bSkip2,bSkip3,bSkip4,bGrava,MMsg,lProcessa)

ENDIF

//IF MOrdem # _PO
	DBSELECTAREA("SW7")
	SW7->(DbSetOrder(2))
	IF ! EMPTY(TPO_NUM)
		DBSeek(xFilial("SW7")+TPO_NUM)
		bCond_ID:=bCond_ID1
	ELSE
		IF EMPTY(THAWB)
			DBSeek(xFilial("SW7"))
			bCond_ID:=bCond_ID2
		ELSE
			SW7->(DbSetOrder(1))
			DBSeek(xFilial("SW7")+THAWB)
			bCond_ID:=bCond_ID3
		ENDIF
	ENDIF

	MMsg:=STR0034 //"Processo referente a P.O.: "
	If lProcessa
		nCont:=0
		// SW7->(DBEVAL({||nCont++},,bCond_ID))
		ProcRegua( SW7->(LASTREC()) )//nCont)
	Endif

    /*
	IF !EMPTY(TPO_NUM)
		DBSeek(xFilial("SW7")+TPO_NUM)
	ELSE
		IF EMPTY(THAWB)
			DBSeek(xFilial("SW7"))
		ELSE
			DBSeek(xFilial("SW7")+THAWB)
		ENDIF
	ENDIF
    */

	TPC252Itens("W7_",bCond_ID,bSkip1,bSkip2,bSkip3,bSkip5,bGrava,MMsg,lProcessa)
//ENDIF

IF !(cPaisloc=="BRA") .and. GetNewPar("MV_EASYFIN","N")="S"

// SW7->(DBSEEK(xFilial("SW7")+THAWB))
   SW9->(DBSETORDER(1))
   SW8->(DBSETORDER(1))
   SW8->(DBSEEK(xFilial()+THAWB))
   aItensDesp:={}
   nValFOB  :=SW6->W6_FOB_TOT//Total em Real

   DO WHILE !SW8->(EOF()) .AND.  XFILIAL("SW8")+THAWB == SW8->W8_FILIAL + SW8->W8_HAWB

      //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
      SW9->(DBSEEK(xFilial()+SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8","W8_FORLOJ")+SW8->W8_HAWB))
      lPosic   :=.F.
      cTecNCM  := SW8->W8_TEC+SW8->W8_EX_NCM+SW8->W8_EX_NBM//Busca_NCM("SW7")
      nValtotIt:=0
      WorkTP->(DBGOTOP())
      DO WHILE  !WORKTP->(EOF())
         // Verifica Despesa
         IF WorkTP->WKDESPESA=='101'
            WORKTP->(DBSKIP())
            LOOP
         ENDIF
         SYB->(DBSEEk(XFILIAL("SYB")+WORKTP->WKDESPESA ))
         IF EMPTY(SYB->YB_IMPINS)
            WORKTP->(DBSKIP())
            LOOP
         ENDIF

         // Posiciona Tabela de Pre-Calculo

         nValPg   :=WORKTP->WKVL_PAGTO
         nValIT   :=SW8->W8_QTDE*SW8->W8_PRECO
         nValtotIt+=nValIT

         // Adiciona Itens para Previsao
         SYB->(DBSEEk(XFILIAL("SYB")+WORKTP->WKDESPESA ))
         nAsc:=ASCAN(aItensDesp, {|cAsc| cAsc[1]+cAsc[2]==SW8->W8_PO_NUM + SW8->W8_COD_I } )
         lPosic:=.T.
         IF nAsc == 0
            AADD(aItensDesp,{ SW8->W8_PO_NUM , SW8->W8_COD_I, , cTecNcm , { { WORKTP->WKDESPESA, nValPg*(SW8->W8_PRECO_R/nVAlFOb), SYB->YB_IMPINS} }, WORKTP->WKDT_PAGTO,nValIT,WORKTP->WKDT_EMB } )
         ELSE
            AADD(aItensDesp[nAsc][5],{ WORKTP->WKDESPESA, nValPg*(SW8->W8_PRECO_R/nVAlFOb), SYB->YB_IMPINS})
         ENDIF

         WORKTP->(DBSKIP())
      ENDDO
      IF !lPosic
         nValIT:=SW8->W8_QTDE*SW8->W8_PRECO
         nValtotIt+=nValIT
         AADD(aItensDesp,{ SW8->W8_PO_NUM , SW8->W8_COD_I,,cTecNcm,{},SW6->W6_DT_HAWB,nValIT,SW6->W6_DT_HAWB } )
      ENDIF
      SW8->(DBSKIP())

   ENDDO

   aItensImp:={}
   For nID:=1 to Len(aItensDesp)

       SYD->(DBSEEK(XFILIAL("SYD")+ aItensDesp[nID][4] ))

       aImpostos:=CalcImpGer(SYD->YD_TES,,,aItensDesp[nID][7],,,,aItensDesp[nID][5],aItensDesp[nID][4],nValtotIt,(nID==Len(aItensDesp)) )

       For nimp:=1 to Len(aImpostos[6])
	      If Len(aImpostos[6,nimp]) >= 5
           nAsc:=ASCAN(aItensImp, {|cAsc| cAsc[1]+cAsc[2]==aItensDesp[nID,1]+aImpostos[6,nImp,1]} )
	          If Subs(aImpostos[6,nImp,5],1,2) == "SS"
    	         nSinal	:=	 1
           ElseIf Subs(aImpostos[6,nImp,5],1,2) == "NN"
		            nSinal	:=	-1
       		  Else
		            nSinal	:=   0
       		  Endif
           IF nAsc = 0
              nOrdSFC:=SFC->(INDEXORD())
              SFC->(DBSETORDER(2))
              SFC->(DBSEEK(XFILIAL("SFC")+SYD->YD_TES+aImpostos[6,nImp,1]))
              cCodImp :='2'+SFC->FC_SEQ
              SFC->(DBSETORDER(nOrdSFC))

              AADD(aItensImp,{aItensDesp[nID,1],;
                              aImpostos[6,nImp,1],;
                              aImpostos[6,nImp,4] *nSinal ,;
                              aItensDesp[nId,6],;
                              aItensDesp[nId,8],;
                              cCodImp})
           ELSE
              aItensImp[nAsc,3]+=aImpostos[6,nImp,4]*nSInal
           ENDIF
       	  EndIf
      Next nImp
   Next nID

   FOR nImp:=1 to Len(aItensImp)
       SW2->(DBSeek(xFilial()+aItensImp[nImp,1]))
       SA2->(DBSeek(xFilial()+SW2->W2_FORN+EICRetLoja("SW2","W2_FORLOJ")))
       WorkTP->( DBAPPEND() )
       WorkTP->WKDT_PAGTO := aItensImp[nImp,4]
       WorkTP->WKDESPESA  := aItensImp[nImp,6]
       WorkTP->WKPO_NUM   := aItensImp[nImp,1]
       WorkTP->WK_HAWB    := SW6->W6_HAWB
       WorkTP->WK_CHEG    := SW6->W6_CHEG
       WorkTP->WKDESPDESC := aItensImp[nImp,2]
       //LGS-27/01/2016 - Tratamento para chamada da rotina NU400PreCalc utilizada na rotina de numerario.
       /* wfs - A despesa será base de adiantamento, logo, o fornecedor deve ser o associado ao despachante.
          Tratamento migrado para NU400PreCalc
       If Type("lEICNU400") == "L" .And. lEICNU400
          WorkTP->WKFORN_N:= SA2->A2_COD
       Else */
       WorkTP->WKFORN_N   := SA2->A2_NOME
       WorkTP->WKFORN_R   := SA2->A2_NREDUZ
       If EICLoja()
          WorkTP->WKFORLOJ:= SA2->A2_LOJA
       EndIf

       WorkTP->WKVL_PAGTO := aItensImp[nImp,3]
       WorkTP->WKDT_EMB   := aItensImp[nImp,5]

       IF(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"GRAVA_WORKTP_INVOICES"),) //ACB - 05/05/2010

       WorkTP->( MSUNLOCK() )
   NEXT nImp


ENDIF


SW3->(DbSetOrder(1))
SW5->(DbSetOrder(1))
SW7->(DbSetOrder(1))

AADD(aWork,WorkFile)
AADD(aWork,WorkNTX2)
AADD(aWork,WorkNTX3)
AADD(aWork,WorkNTX4)
AADD(aWork,WorkNTX5)
AADD(aWork,WorkNTX6)
AADD(aWork,WorkNTX7)

//** AAF 27/11/2008 - Melhoria de performance.
If EasyEntryPoint("EICPTR01") .OR. !EMPTY(TDesp) .OR. EasyEntryPoint("EICTP252")

   DBSELECTAREA("WorkTP")
   WorkTP->(DBGOTOP())
   DO WHILE !WorkTP->(EOF())
      If EasyEntryPoint("EICPTR01")
         EasyExRdm("U_EICPTR01", "8")
      EndIf
      If !EMPTY(TDesp) .And. TDesp # WorkTP->WKDESPESA
         WorkTP->(DBDELETE())
      EndIf
      IF(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"WHILE_WORKTP"),)
      WorkTP->(DBSKIP())
   ENDDO

EndIf

RETURN .T.

*--------------------------------------------------------------------------------------
FUNCTION TPC252ApuFre(PDBF,bCondition,bSkip1,bSkip2,bSkip3,bSkip4,PMsg,lProcessa)
*--------------------------------------------------------------------------------------
LOCAL SavePO:=' ', MPO_NUM, MCod_I, nPesQtd:=0
Local lRet  // By JPP - 05/01/2009 - 17:45
LOCAL aItem:={ FIELDPOS(PDBF+"PO_NUM")  ,;
		       FIELDPOS(PDBF+"COD_I")   ,;
		       FIELDPOS(PDBF+"SALDO_Q") ,;
		       FIELDPOS(PDBF+"PRECO")   ,;
		       FIELDPOS(PDBF+"DT_EMB")  ,;
		       FIELDPOS(PDBF+"DT_ENTR") }

SX3->(DBSETORDER(1))
PRIVATE nPeso:=0 //, cAlias := IF(PDBF="W7_","SW7","SW3")
Private lDarLoop  // By JPP - 05/01/2009 - 17:45

cAlias := "S"+LEFT(PDBF,2)

// apurando o Peso total
// apurando o Qtde total
// apurando o FOB  total
DBSELECTAREA(cAlias)

DO WHILE EVAL(bCondition)
      IF EasyEntryPoint("EICTP252")  // By JPP - 05/01/2009 - 17:45
         lDarLoop := .F.
         lRet := ExecBlock("EICTP252",.F.,.F.,{"TPC252APUFRE_INI_WHILE",PDBF})
         If ValType(lRet) == "L" .And. lRet
            If lDarLoop
               Loop
            EndIf
         EndIf
      EndIf

	  MPO_NUM:=FIELDGET(aItem:PO_NUM)
	  If lProcessa
	     IncProc(PMsg+MPO_NUM)
	  Endif
	  IF EVAL(bSkip2,MPO_NUM)
	     DBSKIP() ; LOOP
	  ENDIF
	  IF FIELDGET(FIELDPOS(PDBF+"FLUXO")) = "5"
	     DBSKIP()
         LOOP
	  ENDIF
	  IF SavePO # MPO_NUM
	     SavePO:= MPO_NUM
	     SW2->( DBSeek(xFilial()+SavePO) )
	  ENDIF
	  IF EVAL(bSkip1,SW2->W2_IMPORT)
	     DBSKIP() ; LOOP
	  ENDIF

	  IF PDBF = "W7_"

         IF aScan( aHawbPesoFOB, {|x| x[1] == SW7->W7_HAWB }) = 0 //*jms 04/05/06
            aRaTotFOB:=TPC252CalcFOB(SW7->W7_HAWB)
            AADD(aHawbPesoFOB,ACLONE(aRaTotFOB))
         EndIf

	     SW6->(DBSeek(xFilial()+SW7->W7_HAWB))
	     IF !(EasyGParam("MV_EASY")=="S")
	        /*
	        IF !EMPTY(SW6->W6_DT_DESE) .OR. SWD->(DBSeek(xFilial()+SW7->W7_HAWB+ADIANTAMENTO))
	      	   SW7->(DBSKIP())
               LOOP
            ENDIF
            */
         ENDIF
/*jms 04/05/06 para carregar o array antes do loop acima, pois tem invoice, mas não preencheu as datas.
         IF aScan( aHawbPesoFOB, {|x| x[1] == SW7->W7_HAWB }) = 0
            aRaTotFOB:=TPC252CalcFOB(SW7->W7_HAWB)
            AADD(aHawbPesoFOB,ACLONE(aRaTotFOB))
         EndIf
*/
         SW7->(DBSKIP())
         LOOP

	  ENDIF

	  MCod_I:=FIELDGET(aItem:COD_I)

	  SB1->(DBSeek(xFilial()+MCod_I))
     //IF !FINDFUNCTION("B1PESO") //RA
     //   nPeso := If(PDBF="W7_",W5Peso(),SB1->B1_PESO   ) //FCD 04/07/01
     //ELSE
     
	 //AAF 03/02/2017 - Ajuste para considerar os campos de peso do pedido/li quando preenchidos.
	 If PDBF = "W7_"
	    nPeso := W5PESO()
	 ElseIf PDBF = "W5_"
	    If !Empty(SW5->W5_PESO)
		   nPeso := SW5->W5_PESO
		Else
		   nPeso := B1PESO(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ"))
		EndIf
	 Else
	    If SW3->(FieldPos("W3_PESOL")) > 0 .AND. !Empty(SW3->W3_PESOL)
		   nPeso := SW3->W3_PESOL
		Else
		   nPeso := B1PESO(SW3->W3_CC,SW3->W3_SI_NUM,SW3->W3_COD_I,SW3->W3_REG,SW3->W3_FABR,SW3->W3_FORN,EICRetLoja("SW3","W3_FABLOJ"),EICRetLoja("SW3","W3_FORLOJ"))  //  LDR - OS 1218/03    //If(PDBF="W7_",W5Peso(),SB1->B1_PESO) //FCD 04/07/01                                 
	    EndIf
     EndIf
	 //ENDIF

     IF(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"APU_FRE"),)
///  IF(EasyEntryPoint("EICTP251"),ExecBlock("EICTP251",.F.,.F.,"APU_FRE"),)

	  IF (nPesQtd := aScan( aFrete, {|x| x[1] == MPO_NUM }) ) # 0
	     aFrete[nPesQtd,2] += (FIELDGET(aItem:SALDO_Q) * nPeso)
	     aFrete[nPesQtd,3] += FIELDGET(aItem:SALDO_Q)
	  Else
	     AADD(aFrete,{MPO_NUM,(FIELDGET(aItem:SALDO_Q) * nPESO),FIELDGET(aItem:SALDO_Q) })
	  EndIf

	  DBSKIP()
ENDDO

SavePO:=' '

RETURN NIL

*--------------------------------------------------------------------------------------
FUNCTION TPC252CalcFOB(cHAWB)
*--------------------------------------------------------------------------------------
LOCAL nFOBTotal:=nDespTotal:=nPesoTotal:=nQtdeTotal:=0
LOCAL cFILSW8:=xFilial("SW8")
LOCAL cFILSW9:=xFilial("SW9")
LOCAL cFILSW2:=xFilial("SW2")
LOCAL cFILSW7:=xFilial("SW7")
LOCAL nRecnOld :=SW7->(RECNO())
LOCAL nOrderOld:=SW7->(INDEXORD())
Local cChvInvCalcFob:= ""
Local cChvPOCalcFob:= ""

SW9->(DbSetOrder(1))
SW8->(DBSETORDER(1))
SW8->(DBSEEK(cFILSW8+cHAWB))

DO WHILE SW8->(!EOF()) .AND.;
         SW8->W8_HAWB   == cHAWB .AND.;
         SW8->W8_FILIAL == cFILSW8

   //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
   //wfs - out/2019: ajustes de performance
   If cChvInvCalcFob <> cFILSW8 + SW8->W8_INVOICE + SW8->W8_FORN + SW8->W8_FORLOJ + SW8->W8_HAWB

      cChvInvCalcFob:= cFILSW8 + SW8->W8_INVOICE + SW8->W8_FORN + SW8->W8_FORLOJ + SW8->W8_HAWB

      SW9->(DBSEEK(cFILSW9+SW8->W8_INVOICE+SW8->W8_FORN+SW8->W8_FORLOJ+SW8->W8_HAWB))

      IF EMPTY(SW9->W9_TX_FOB)
         nTaxaFob:=BuscaTaxa(SW9->W9_MOE_FOB,dDataBase,.T.,.F.,.T.)
      ELSE
         nTaxaFob:=SW9->W9_TX_FOB
      ENDIF

   EndIf

   nFOBTotal  += (SW8->W8_QTDE*SW8->W8_PRECO*nTaxaFob)
   nDespTotal += DI500RetVal("ITEM_INV,SEM_FOB", "TAB", .T.) * nTaxaFob// EOB - 14/07/08 - Chamada da função DI500RetVal
   SW8->(DBSKIP())

ENDDO

lSomou:=nFOBTotal # 0
SW7->(DBSETORDER(1))
SW7->(DBSEEK(cFILSW7+cHAWB))
DO WHILE SW7->(!EOF()) .AND.;
         SW7->W7_HAWB   == cHAWB .AND.;
         SW7->W7_FILIAL == cFILSW7

   //wfs - out/2019: ajustes de performance
   IF !lSomou
      If cChvPOCalcFob <> cFILSW2 + SW7->W7_PO_NUM
         SW2->(DBSEEK(cFILSW2+SW7->W7_PO_NUM))
         cChvPOCalcFob:= cFILSW2 + SW7->W7_PO_NUM
         nTaxaFob  :=BuscaTaxa(SW2->W2_MOEDA,dDataBase,.T.,.F.,.T.)
      EndIf
      nFOBTotal +=(SW7->W7_QTDE*SW7->W7_PRECO*nTaxaFob)
   ENDIF
   nPesoTotal+=(SW7->W7_QTDE*SW7->W7_PESO)
   nQtdeTotal+= SW7->W7_QTDE

   SW7->(DBSKIP())

ENDDO

SW7->(DBGOTO(nRecnOld))
SW7->(DBSETORDER(nOrderOld))

RETURN {cHAWB,nPesoTotal,nQtdeTotal,(nFOBTotal+nDespTotal)}

*--------------------------------------------------------------------------------------
FUNCTION TPC252Itens(PDBF,bCondition,bSkip1,bSkip2,bSkip3,bSkip4,bGrava,PMsg,lProcessa)
*--------------------------------------------------------------------------------------
// array aPagtos contera apenas os valores nao pagos

LOCAL lAchouSW5, nPesQtd:=0
Local lRet // By JPP - 05/01/2009 - 17:45
Local cMsg := "", cTit := ""
LOCAL lSx6Soft:=SX6->(DBSEEK(SM0->M0_CODFIL+"MV_CAMBAUT")).OR.SX6->(DBSEEK("  "+"MV_SOFTWAR"))
LOCAL lTrocouPO:=.f. //Jonato em 13/Agosto
Local bTPCCalc := { |TPC,ind| IF(EVAL(bSkip4,TPC:DESP,aDespBase) .And. aScan(aDespBase, &("{|x| x[1] == '"+TPC:DESP+"'}")) == 0,;
                    TPCCalculo(TPC, MSaldo_Q, MRateio,MTx_Usd,bGrava,aPagtos,SaveTab,aDespBase,;
                    IF(PDBF # "W7_",SW2->W2_FREPPCC,BuscaPPCC()),.T.,PDBF,,,,,,bTPCCalc, @aBuffers,"TPC252"),) }
Local aBuffers := {tHashMap():New(), tHashMap():New(), tHashMap():New(), tHashMap():New()}//RMD - 08/04/19 - Buffers para a função TPCCalculo: [1]-Dados de Paridade, [2]-Dados de NCM, [3]-Dados de Majoração do Cofins, [4] - Tabela de pré-cálculo
Local lCtrlPrtMsg
Local nInd_Frete  := 0
Local nInd_Seguro := 0

SX3->(DBSETORDER(2))

PRIVATE lExiste_Midia   := EasyGParam("MV_SOFTWAR") $ cSim
PRIVATE lFrete_SWD:=.f.

PRIVATE nTotFreGeral:=0
PRIVATE cFilSW8:=xFilial("SW8")
PRIVATE cFilSW9:=xFilial("SW9")
PRIVATE lW7:=.F.,lSoAvista:=.f. //Usado no RdMake Eicptr01
PRIVATE nOrdSW3
PRIVATE SavePO:=' ', SavePO_Dt:=SaveDt_Entr:=AVCTOD(""), SaveTab:=' ', MDt_Emb,;
      MDt_Entr, OldSelect, SaveFobTot:=0, Paridade, aPagtos:={}, aTPC:={},;
      MSaldo_Q, _recno, MFOB, MPO_NUM, SaveFobDes:=0, MCod_I, Pos_I,;
      SaveHAWB:=' ', FoundAPD, MVl_Pagto, MDt_Real:=AVCTOD(""), nFPerc, nFDias,;
      MRateio, nDIFob, dVencto,nTabDesp, nRecAntPrev:=0

PRIVATE aItem:={ FIELDPOS(PDBF+"PO_NUM")  ,;
	       FIELDPOS(PDBF+"COD_I")   ,;
	       FIELDPOS(PDBF+"SALDO_Q") ,;
	       FIELDPOS(PDBF+"PRECO")   ,;
	       FIELDPOS(PDBF+"DT_EMB")  ,;
	       FIELDPOS(PDBF+"DT_ENTR") ,;
	       FIELDPOS(PDBF+"POSICAO") }

PRIVATE lLoop

SY6->(DBSETORDER(1))
nOrdSW3:=(SW3->(INDEXORD()))

MTx_Usd := BuscaTaxa(cMOEDAEST,dDataBase,.T.,.F.,.T.)//AVCTOD("31/12/49")

SavePo_Dt:= AVCTOD("31/12/49")

THAWB:= AvKey(THAWB, "W7_HAWB")// TDF - 25/05/10

//DFS - Criação de mensagem para mostrar apenas no final os relatórios que não foram gerados.
cTit := "Não foi possível gerar todos os relatórios, pois"+CHR(13)+CHR(10)+;
        "o(s) seguinte(s) Processo(s) esta(ão) Encerrado(s):"+REPLICATE(CHR(13)+CHR(10),2)
lCtrlPrtMsg := IsMemVar("aProcEncer") .And. ValType(aProcEncer) == "A" //NCF - 07/02/2019
DO WHILE EVAL(bCondition)

   //**JVR** - 02/04/2009 - Movido a verificação de Data de Encerramento para dentro do while
   //CCH - 29/10/2008 - Verifica se a Data de Encerramento do Processo está preenchida.
   //Se "Sim", não entra no While e não gera Previsão
   If PDBF = "W7_"
      If SW6->(DBSeek(xFilial()+SW7->W7_HAWB))
         If !Empty(SW6->W6_DT_ENCE)
            //DFS - Criação de mensagem para mostrar apenas no final os relatórios que não foram gerados.
            cMsg += "Processo: "+Alltrim(SW7->W7_HAWB)+CHR(13)+CHR(10)+;
                    "Data de Encerramento: "+DtoC(SW6->W6_DT_ENCE)+CHR(13)+CHR(10)+;
                    "---------------------------------------------------"+CHR(13)+CHR(10)

            If lCtrlPrtMsg .And. aScan( aProcEncer , { |x| x[1] == SW6->W6_HAWB } ) == 0       
               aAdd( aProcEncer, { SW6->W6_HAWB , cMsg } )
            EndIf

            DbSkip()//JVR - introduzido para fazer o loop e assim verificar todos os registros.
            Loop
         EndIf
      EndIf
   EndIf

   IF EasyEntryPoint("EICTP252")  // By JPP - 05/01/2009 - 17:45
      lLoop := .F.
      lRet := ExecBlock("EICTP252",.F.,.F.,{"TPC252ITENS_INI_WHILE",PDBF})
      If ValType(lRet) == "L" .And. lRet
         If lLoop
            Loop
         EndIf
      EndIf
   EndIf
   MPO_NUM:=FIELDGET(aItem:PO_NUM)

   If lProcessa
      IncProc(PMsg+MPO_NUM)
   Endif

   IF EVAL(bSkip2,MPO_NUM)
      DBSKIP() ; LOOP
   ENDIF

   IF FIELDGET(FIELDPOS(PDBF+"FLUXO")) = "5"
      DBSKIP() ; LOOP
   ENDIF

   SW2->( DBSeek(xFilial()+MPO_NUM ) )

   If EVAL(bSkip1,SW2->W2_IMPORT)
      dbSkip() ; Loop
   EndIf

   If PDBF = "W7_"
      SW6->(DBSeek(xFilial()+SW7->W7_HAWB))
      IF !(EasyGParam("MV_EASY")=="S")
         If !(Empty(SW6->W6_DT_DESE) .OR. SWD->(dbSeek(xFilial()+SW7->W7_HAWB+ADIANTAMENTO)))
            SW7->(DBSKIP())
            Loop
         EndIf
      EndIf
   EndIf

   lFrete_SWD:=.f.

   lLoop := .F.
   IF(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"LER_ITENS"),)
   IF lLoop
      DBSKIP() ; LOOP
   ENDIF

   If PDBF = "W7_" //.AND. MOrdem <> _PO //THTS - 19/01/2018
      cTabPrePC :=SW6->W6_TAB_PC
      cViaPrePC :=SW6->W6_VIA_TRA
      cChavePesq:=SW6->W6_HAWB
      aRateio   :=ACLONE(aHawbPesoFOB)
   ELSE
      cTabPrePC :=SW2->W2_TAB_PC
      cViaPrePC :=SW2->W2_TIPO_EM
      cChavePesq:=MPO_NUM
      aRateio   :=ACLONE(aFrete)
   EndIf

   If !(SWI->(DBSEEK(xFilial("SWI")+SW6->W6_VIA_TRA+cTabPrePC))) // RRV - 13/08/2012 - Procura a tabela de pré-calculo com via de transporte referente ao processo corretamente.
      SWI->(DBSETORDER(1))
      SWI->(DBSeek(xFilial()+cTabPrePC))
   EndIf

   TPCCarga(aTPC,.F., @aBuffers) //wfs - out/2019: ajustes de performance

   IF SavePO # MPO_NUM
      lTrocouPO:=.T.
      SavePO:= MPO_NUM
      SW2->( DBSeek(xFilial()+SavePO) )
      SaveFobTot:=SW2->W2_FOB_TOT

      nInd_Frete := aScan( aTPC, {|x| x[3] == DESPESA_FRETE })
      nInd_Seguro := aScan( aTPC, {|x| x[3] == DESPESA_SEGURO })
      SaveFobDes:=geraFob( nInd_Frete,nInd_Seguro )

	  IF SW2->W2_MOEDA # cMOEDAEST
         If !aBuffers[1]:Get(SW2->W2_MOEDA + DToS(SavePO_Dt), @Paridade)
            Paridade:=BuscaTaxa(SW2->W2_MOEDA,SavePO_Dt,.T.,.F.,.T.) / MTx_Usd
            aBuffers[1]:Set(SW2->W2_MOEDA + DToS(SavePO_Dt), Paridade)
         EndIf
      Else
         Paridade:=1
      EndIf
   EndIf

   IF PDBF == "W7_" //.AND. MOrdem = _Embarque   // JONATO 19/08/2003
      IF (wind:= ASCAN( aHawbPesoFOB , {|tab| tab[1] == SW7->W7_HAWB } )) # 0
         SaveFobDes:= 0
         SaveFobTot:= aHawbPesoFOB[wind,4] // Fob Total esta vindo em R$
      Else   // AAF - 07/10/2013
         aRaTotFOB:=TPC252CalcFOB(SW7->W7_HAWB)
         AADD(aHawbPesoFOB,ACLONE(aRaTotFOB))
         SaveFobTot := aRaTotFOB[4]
      ENDIF
   ENDIF

   ASIZE(aPagtos,0)
   ASIZE(aDespBase,0)

   MFOB:=(MSaldo_Q:=FIELDGET(aItem:SALDO_Q)) * FIELDGET(aItem:PRECO)

   //CCH - 23/09/2008 - Inclusão de Ponto de Entrada conforme solicitado por Fernando Rossetti.
   If EasyEntryPoint("EICTP252")
      ExecBlock("EICTP252",.F.,.F.,"ANTES_CALC_ITEM")
   EndIf

   If EasyEntryPoint("EICPTR01")
      EasyExRdm("U_EICPTR01", "3", @lSoAvista, @PDBF, @lW7)      
   EndIf

   Private cAliasRDM := "S"+LEFT(PDBF,2)  // RA - 14/08/2003


   FoundAPD:=.F.
   If PDBF # "W7_"
      MDt_Emb :=FIELDGET(aItem:DT_EMB)
      MDt_Entr:=FIELDGET(aItem:DT_ENTR)
      MFOB    :=MFOB + (SaveFobDes * (MRateio := MFOB / SaveFobTot))
      MDt_Emb :=IF(MDt_Emb<dDataBase,dDataBase,MDt_Emb)
      If(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"MDT_ENTR"),) // RA - 14/08/2003
   Else
      If SaveHAWB # SW7->W7_HAWB
         SaveHAWB := SW7->W7_HAWB

			MDt_Emb := CTOD("") // TDF - 11/12/2014

			//RMD - 02/10/13 - Define o campo data base para calculo do desembolso
			If !Empty(cCampo := AllTrim(EasyGParam("MV_EIC0035",,""))) .And. SW6->(FieldPos(cCampo)) > 0
				MDt_Emb := SW6->&(cCampo)
			EndIf

			If Empty(MDt_Emb)
				MDt_Emb  := SW6->W6_DT_EMB
			EndIf

	        lAchouSW5:= .F.
	        If Empty(SW6->W6_DT_ENTR) .OR. Empty(MDt_Emb)
	           OldSelect:=Select()
	           If PosOrd2_It_Guias(SW7->W7_HAWB,SW7->W7_CC,SW7->W7_SI_NUM,SW7->W7_COD_I,;
                                SW7->W7_FABR,SW7->W7_FORN,SW7->W7_REG,EICRetLoja("SW7","W7_FABLOJ"),EICRetLoja("SW7","W7_FORLOJ"))
               lAchouSW5:=.T.
   	        EndIf
	           dbSelectArea(OldSelect)
	        EndIf
	        If Empty(MDt_Emb) .AND. lAchouSW5
	           MDt_Emb:=IF(SW5->W5_DT_EMB<dDataBase,dDataBase,SW5->W5_DT_EMB)
	        ElseIf Empty(MDt_Emb) .AND. ! lAchouSW5
	           MDt_Emb:=dDataBase
         EndIf
         MDt_Entr:=MDt_Emb
         MDt_Real:=MDt_Emb
      EndIf
      If(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"MDT_ENTR"),) // RA - 14/08/2003
  	   IF EasyEntryPoint("EICPTR01")
         EasyExRdm("U_EICPTR01", "6", @cInv, @cAux, @lDespAnalitico, @lW7)         
      EndIf
      SW8->(DBSETORDER(3))
      lTemSW8:=SW8->(DBSEEK(cFilSW8+SW7->W7_HAWB+SW7->W7_PGI_NUM+SW7->W7_PO_NUM+SW7->W7_SI_NUM+SW7->W7_CC+SW7->W7_COD_I+STR(SW7->W7_REG,4,0)))
      IF lTemSW8
         EICTP_SW8(PDBF,bCondition,bSkip1,bSkip2,bSkip3,bSkip4,"",PMsg,lProcessa)
         DBSELECTAREA("SW7")
         DBSKIP()
         LOOP
      ELSE  // Caso nao haja invoice, o maximo possivel para se usar inland,packing e desconto, e utilizar do pedido
         SW8->(DBSETORDER(1))
         nTaxaMoe:= 0
         If !aBuffers[1]:Get(SW2->W2_MOEDA + DToS(dDataBase), @nTaxaMoe)
            nTaxaMoe:=BuscaTaxa(SW2->W2_MOEDA,dDataBase,.T.,.F.,.T.)
            aBuffers[1]:Set(SW2->W2_MOEDA + DToS(dDataBase), nTaxaMoe)
         EndIf

         //MFOB    :=MFOB * nTaxaMoe   //ASR 11/01/2006 - COMENTADO PARA COMPATIBILIZAR COM O TRATAMENTO COM INVOICE - // Bete 26/10/05 - Para converter o fob do item em R$
                                       //ASR 11/01/2006 - AO RETORNAR A FUNCAO CHAMADORA E FEITA OUTRA CONVERSAO DE MOEDA
         MFOB := MFOB + (SaveFobDes * (MRateio :=MFOB * nTaxaMoe / SaveFobTot))
         SaveFobTot:=0
      ENDIF
      If SaveFobTot # 0
         AADD(aDespBase,{DESPESA_FOB,SaveFobTot})
      ENDIF
   ENDIF

   //IF !SaveTab == cTabPrePC  // Nopado por GFP - 04/10/2013 - Sempre deve recarregar os valores da tabela de Pré-Calculo
      IF (nPesQtd := aScan( aRateio, {|x| x[1] == cChavePesq }) ) # 0
         nPesoAcumulado := aRateio[nPesQtd,2]
         nQtdeAcumulada := aRateio[nPesQtd,3]
      Else
         nPesoAcumulado := nQtdeAcumulada := 0
      EndIf

      SaveDt_Entr:=AVCTOD("")   // para forcar o recalculo do vencimento
      IF(! SWI->(EOF()),SaveTab:=SWI->WI_TAB,)

      nTotFreGeral := TPC252Frete(@aTPC,PDBF)
      nTotSegGeral := TP251Seguro(@aTPC,nInd_Seguro)
      lTrocouPO:= .F. // Jonato em 13/Agosto para calculo mais adequado do frete

   IF EasyEntryPoint("EICPTR01")
      EasyExRdm("U_EICPTR01", "5", @aPagtos, @FoundAPD, @lSoAvista, @MFOB, @Paridade, @MDt_Emb, @MDt_Real)
   ElseIf Len(aPagtos)=0 .AND. !FoundAPD
      MFOB*=Paridade                                                             //NCF - 13/12/10 - Inclusão do 7º Parametro
      TPC252Pagtos(aPagtos,MDt_Emb,MFOB,MDt_Real,SW2->W2_COND_PA,SW2->W2_DIAS_PA,PDBF)
   EndIf
   IF SaveDt_Entr # MDt_Entr
      SaveDt_Entr:= MDt_Entr
      AEVAL(aTPC,{ |TPC| TPC:Dt_Pagto := MDt_Entr + TPC:QTDDIAS} )
   ENDIF
   IF ASCAN(aPagtos,bSkip3) = 0  .AND. ASCAN(aTPC,bSkip3) = 0
	     DBSKIP() ; LOOP           // nao encontrou nenhuma data de pagamento no
   ENDIF                        // intervalo selecionado
   MCod_I:=FIELDGET(FIELDPOS(PDBF+"COD_I"))
   Pos_I :=FIELDGET(FIELDPOS(PDBF+"POSICAO"))
   SB1->(DBSeek(xFilial()+MCod_I))
   IF SWI->(EOF())
      IF EVAL(bSkip4,DESPESA_FOB,aDespBase)
         AEVAL(aPagtos,{|fob,ind|;
                        EVAL(bGrava,DESPESA_FOB,fob:Dt_Pagto,fob:Vl_Pagto,' ',NIL,;
                              fob:Dt_Real,fob:FPerc,fob:FDias,fob:FInvoice,PDBF)})

      ENDIF
   ELSE
      SW3->(DBSETORDER(8))  // Jonato , 30-07-01, para funcionar a funcao busca_ncm(), chamada da tpccalculo
      nRecSW3 := SW3->(recno())
      SW3->(DBSEEK(xFilial()+MPO_NUM+Pos_I))
      PRIVATE nDspBasImp:=0 // AWR - Desp Base
	  AEVAL(aTPC, bTPCCalc) //THTS - 18/01/2018

      IF(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"APOS_AEVAL_TPC1"),)

      SW3->(DBSETORDER(nOrdSW3))
      SW3->(dbGoTo(nRecSW3))
   ENDIF

   DBSKIP()

   IF FIELDGET(FIELDPOS(PDBF+"PO_NUM"))#SavePO .AND. (PDBF = "W5_" .OR. PDBF = "W7_")
      DBSKIP(-1)
      nSaveOrder:=WorkTP->(IndexOrd())
      WorkTP->(DbSetOrder(2))
      WorkTP->(DBSeek(MPO_NUM))
      DO WHILE ! WorkTP->(eof()) .AND. WorkTP->WKPO_NUM == MPO_NUM
         IF At(WorkTP->WKDESPESA,"101.102.104.201.202") = 0  // SWI->WI_DESP && FOB.CIF.II.IPI
            IF PDBF = "W5_"
               SW7->(DbSetOrder(2))
               IF SW7->(DBSeek(xFilial("SW7")+WorkTP->WKPO_NUM))
                  EXIT
               EndIf
            EndIF
            nTabDesp:=0
            IF (nTabDesp := aScan( aTPC, {|x| x[3] == WorkTP->WKDESPESA }) ) # 0  //.AND. aTPC[nTabDesp][11] # "2"
               nMin:=aTPC[nTabDesp][10]
               nMax:= aTPC[nTabDesp][9]
               IF aTPC[nTabDesp][4] # cMOEDAEST //.OR. aTPC[nTabDesp][4] # 'USD'
                  nMin:= aTPC[nTabDesp][10] * (BuscaTaxa(aTPC[nTabDesp][4],dDataBase,.T.,.F.,.T.) / BuscaTaxa(cMOEDAEST,dDataBase,.T.,.F.,.T.))
                  nMax:= aTPC[nTabDesp][9]  * (BuscaTaxa(aTPC[nTabDesp][4],dDataBase,.T.,.F.,.T.) / BuscaTaxa(cMOEDAEST,dDataBase,.T.,.F.,.T.))
               ENDIF
               IF WorkTP->WKVL_PAGTO < nMin                    // SWI->WI_VAL_MIN
                  WorkTP->WKVL_PAGTO := nMin
               ELSEIF WorkTP->WKVL_PAGTO > nMax .AND. nMax # 0 // SWI->WI_VAL_MAX
                  WorkTP->WKVL_PAGTO := nMax
               ENDIF
            ENDIF
         ENDIF

         WorkTP->(DbSkip())
      ENDDO
      WorkTP->(DbSetOrder(nSaveOrder))
      DBSKIP()
   ENDIF
ENDDO

If !Empty(cMsg) .And. !lCtrlPrtMsg
   EECVIEW(cTit + cMsg) //DFS - Criação de mensagem para mostrar apenas no final os relatórios que não foram gerados.
EndIf

RETURN NIL


*-----------------------------------------------------------------------------------*
FUNCTION EICTP_SW8(PDBF,bCondition,bSkip1,bSkip2,bSkip3,bSkip4,cNada,PMsg,lProcessa)
*-----------------------------------------------------------------------------------*
LOCAL bGrava:={|desp,data,valor,tab,_null,dt_real,fobperc,fobdias,invoic,PDBF| ;
                IF(!EMPTY(data) .AND. data >= TDT_I .AND. data <= TDT_F ,;
      	        TPC252Grava(desp,data,valor,tab,@MTotGer,MTipo,MOrdem,;
                 dt_real,fobperc,fobdias,invoic,PDBF,SW9->W9_COND_PA,SW9->W9_DIAS_PA),)}
Local bTPCCalc := { |TPC,ind| IF(EVAL(bSkip4,TPC:DESP,aDespBase).And. aScan(aDespBase, &("{|x| x[1] == '"+TPC:DESP+"'}")) == 0,;
                    TPCCalculo(TPC, MSaldo_Q, MRateio,MTx_Usd,bGrava,aPagtos,SaveTab,aDespBase,;
                    IF(PDBF # "W7_",SW2->W2_FREPPCC,BuscaPPCC()),.T.,PDBF,,,,,,bTPCCalc, @aBuffers,"TPC252"),) }
Local aBuffers := {tHashMap():New(), tHashMap():New(), tHashMap():New()}//RMD - 08/04/19 - Buffers para a função TPCCalculo: [1]-Dados de Paridade, [2]-Dados de NCM, [2]-Dados de Majoração do Cofins
Local nTtFobRSPr := 0
Local MFOB_RS    := 0
PRIVATE nVlrSWB:=0

DBSELECTAREA("SW8")
SW8->(DBSETORDER(3))
lTemSW8:=SW8->(DBSEEK(cFilSW8+SW7->W7_HAWB+SW7->W7_PGI_NUM+SW7->W7_PO_NUM+SW7->W7_SI_NUM+Avkey(SW7->W7_CC,"W8_CC")+SW7->W7_COD_I+STR(SW7->W7_REG,4,0)))

If lTemSW8
   aOrdSW9 := SaveOrd("SW9")
   SW9->(DbSetOrder(3))
   SW9->(DbSeek(xFilial("SW9")+ SW7->W7_HAWB ))
   Do While !SW9->(EOF()) .AND. SW9->W9_FILIAL == xFilial("SW9") .And. SW9->W9_HAWB == SW7->W7_HAWB
      nTtFobRSPr += DI500RetVal("TOT_INV", "TAB" , .T. , .T. )
      SW9->(DbSkip())
   EndDo
   RestOrd(aOrdSW9,.T.)
EndIF

DO WHILE lTemSW8 .AND. !SW8->(EOF()) .AND.;
   SW8->W8_HAWB    == SW7->W7_HAWB    .AND. SW8->W8_COD_I  == SW7->W7_COD_I  .AND.;
   SW8->W8_PGI_NUM == SW7->W7_PGI_NUM .AND. SW8->W8_SI_NUM == SW7->W7_SI_NUM .AND.;
   SW8->W8_CC      == AvKey(SW7->W7_CC,"W8_CC")      .AND. SW8->W8_REG    == SW7->W7_REG    .AND.;
   SW8->W8_PO_NUM  == SW7->W7_PO_NUM  .AND. SW8->W8_FILIAL == cFilSW8
   SW9->(DBSETORDER(1))
   //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
   SW9->(DBSEEK(cFILSW9+SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8","W8_FORLOJ")+SW8->W8_HAWB))

   // O While é mantido, pois nem todos possuem a alteração no índice 1 da SW9 (FILIAL+INVOICE+FORNECEDOR+HAWB)
   // A alteração do índice 1 da SW9 é disponibilizada através do update UIINVOICE
   DO WHILE !SW9->(EOF()) .AND. SW9->W9_FILIAL  == cFILSW9         .AND.;
                                SW8->W8_INVOICE == SW9->W9_INVOICE .AND.;
                                (SW8->W8_FORN    == SW9->W9_FORN   .AND.;
                                 IIF(EICLoja(),SW8->W8_FORLOJ==SW9->W9_FORLOJ,.T.))
      IF SW8->W8_HAWB  == SW9->W9_HAWB
         EXIT
      ENDIF
      SW9->(DBSKIP())
   ENDDO

   ASIZE(aPagtos,0)
   ASIZE(aDespBase,0)
   FoundAPD:=.F.
   SWB->(DbGoTop())  // GFP - 10/10/2013
   FoundAPD:= SWB->(DBSeek( xFilial()+SW8->W8_HAWB+"D"+SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SWB","WB_LOJA")))
   MFOB    := DI500RetVal("ITEM_INV", "TAB", .T.) // EOB - 14/07/08 - Chamada da função DI500RetVal
   nDIFob  := DI500RetVal("TOT_INV" , "TAB", .T.) // EOB - 14/07/08 - Chamada da função DI500RetVal
   MFOB_RS := DI500RetVal("ITEM_INV", "TAB", .T. , .T.) // NCF - 25/08/2016 - Total Fob do item da Invoice em R$
   MSaldo_Q:= SW8->W8_QTDE
   lFrete_SWD:=.f.

   IF EMPTY(SW9->W9_TX_FOB)
      nTaxaFob:=BuscaTaxa(SW9->W9_MOE_FOB,dDataBase,.T.,.F.,.T.)
   ELSE
      nTaxaFob:=SW9->W9_TX_FOB
   ENDIF
   //MRateio := (MFOB*nTaxaFob) / SaveFobTot  // jonato 20/06/2002, pegar o total do SW9
   //MRateio    := MFOB / nDIFob          // AAF - 07/10/2013
   MRateio := MFOB_RS / nTtFobRSPr   // NCF - 25/08/2016 - Percentual de rateio por valor do processo para os itens das invoices (Rateio das despesas do processo por valor)
   IF EasyEntryPoint("EICPTR01")
      EasyExRdm("U_EICPTR01", "4",@lDespAnalitico,  @lDespSintetico,  @MVl_Pagto,  @MRateio,  @Paridade , @dVencto,;
                 @nFPerc, @nDiFob, @nFDias,  @MDt_Emb,  @aPagtos,  @MDt_Real, @SaveFobTot)     
   ElseIF FoundAPD
      nVlrSWB:=0
      SWB->(DBEVAL({||MVl_Pagto:=(SWB->WB_FOBMOE + SWB->WB_PGTANT) * (MFOB/nDIFob) * Paridade ,; //wfs 21/02/14: inclusão do campo de adiantamento; o valor antecipado migra do campo WB_FOBMOE para WB_PGTANT após a vinculação do câmbio do pagamento antecipado ao câmbio da invoice
            dVencto:=SWB->WB_DT_VEN,;
            nFPerc :=INT((SWB->WB_FOBMOE/nDIFob)*100),;
            nFDias :=dVencto - MDt_Emb,;
            IF(EMPTY(SWB->WB_CA_DT),; //.OR. EMPTY(SWB->WB_DT_DESE)),;   // GFP - 10/10/2013
                    AADD(aPagtos,{dVencto,MVl_Pagto,MDt_Real,nFPerc,nFDias,""}),;
                   nVlrSWB+= MVl_Pagto)},,;
     			  {|| SWB->WB_HAWB    == SW8->W8_HAWB    .AND. xFilial("SWB")==SWB->WB_FILIAL .AND.;
	    		      SWB->WB_INVOICE == SW8->W8_INVOICE .AND. (SWB->WB_FORN  ==SW8->W8_FORN  .AND.;
	    		      IIF(EICLoja(),SWB->WB_LOJA ==SW8->W8_FORLOJ,.T.))})) // JONATO 20/06/2002 ACRESCENTAR A INVOICE NO FILTRO DO WHILE

      If nVlrSWB # 0
         AADD(aDespBase,{DESPESA_FOB,nVlrSWB})
      ENDIF
   ENDIF

   IF (nPesQtd := aScan(aHawbPesoFOB, {|x| x[1] == SW8->W8_HAWB }) ) # 0//MPO_NUM
      nPesoAcumulado := aHawbPesoFOB[nPesQtd,2]
      nQtdeAcumulada := aHawbPesoFOB[nPesQtd,3]
   Else    // AAF - 07/10/2013
      aRaTotFOB:=TPC252CalcFOB(SW8->W8_HAWB)
      AADD(aHawbPesoFOB,ACLONE(aRaTotFOB))

      nPesoAcumulado := aHawbPesoFOB[Len(aHawbPesoFOB),2]
      nQtdeAcumulada := aHawbPesoFOB[Len(aHawbPesoFOB),3]
   EndIf
   If !(SWI->(DBSEEK(xFilial("SWI")+SW6->W6_VIA_TRA+cTabPrePC))) // GFP - 02/10/2013
      SWI->(DBSETORDER(1))
      SWI->(DBSeek(xFilial()+cTabPrePC))
   EndIf

   TPCCarga(aTPC,.F.)
   SaveDt_Entr:=AVCTOD("")   // para forcar o recalculo do vencimento
   iIF(! SWI->(EOF()),SaveTab:=SWI->WI_TAB,)
   nTotFreGeral := TPC252Frete(@aTPC,PDBF)
   
   IF EasyEntryPoint("EICPTR01")
      EasyExRdm("U_EICPTR01", "5", @aPagtos, @FoundAPD, @lSoAvista, @MFOB, @Paridade, @MDt_Emb, @MDt_Real)      
   ElseIf Len(aPagtos)=0 .AND. !FoundAPD    // GFP - 10/10/2013
      MFOB*=Paridade                                                      
      
             //NCF - 13/12/10 - Inclusão do 7º Parametro
      TPC252Pagtos(aPagtos,MDt_Emb,MFOB,MDt_Real,SW9->W9_COND_PA,SW9->W9_DIAS_PA,PDBF)
   EndIf
   IF SaveDt_Entr # MDt_Entr
      SaveDt_Entr:= MDt_Entr
      //    AEVAL(aTPC,bTPCDias)
      AEVAL(aTPC,{ |TPC| TPC:Dt_Pagto := MDt_Entr + TPC:QTDDIAS} )
   ENDIF
   IF ASCAN(aPagtos,bSkip3) = 0  .AND. ASCAN(aTPC,bSkip3) = 0
	     SW8->(DBSKIP())
	     LOOP           // nao encontrou nenhuma data de pagamento no
   ENDIF                        // intervalo selecionado
   MCod_I:=SW8->W8_COD_I
   Pos_I :=SW8->W8_POSICAO
   SB1->(DBSeek(xFilial()+MCod_I))
   IF SWI->(EOF())
      IF EVAL(bSkip4,DESPESA_FOB,aDespBase)
         AEVAL(aPagtos,{|fob,ind|;
                        EVAL(bGrava,DESPESA_FOB,fob:Dt_Pagto,fob:Vl_Pagto,' ',NIL,;
				        fob:Dt_Real,fob:FPerc,fob:FDias,fob:FInvoice,PDBF)})
      ENDIF
   ELSE
      SW3->(DBSETORDER(8))  // Jonato , 30-07-01, para funcionar a funcao busca_ncm(), chamada da tpccalculo
      nRecSW3 := SW3->(recno())
      SW3->(DBSEEK(xFilial()+SW8->W8_PO_NUM+Pos_I))
      PRIVATE nDspBasImp:=0 // AWR - Desp Base	     
      AEVAL(aTPC,bTPCCalc) //THTS - 18/01/2018

      IF(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"APOS_AEVAL_TPC2"),)

      SW3->(DBSETORDER(nOrdSW3))
      SW3->(dbGoTo(nRecSW3))
   ENDIF
   SW8->(DBSKIP())
   IF ALLTRIM(SW8->W8_PO_NUM) # ALLTRIM(SavePO)
      SW8->(DBSKIP(-1))
      nSaveOrder:=WorkTP->(IndexOrd())
      WorkTP->(DbSetOrder(2))
      WorkTP->(DBSeek(SavePO))
      DO WHILE ! WorkTP->(eof()) .AND. WorkTP->WKPO_NUM == SavePO
         IF At(WorkTP->WKDESPESA,"101.102.104.201.202") == 0  // SWI->WI_DESP && FOB.CIF.II.IPI
            nTabDesp:=0
            IF (nTabDesp := aScan( aTPC, {|x| x[3] == WorkTP->WKDESPESA }) ) # 0  //.AND. aTPC[nTabDesp][11] # "2"
               nMin:=aTPC[nTabDesp][10]
               nMax:= aTPC[nTabDesp][9]
               IF aTPC[nTabDesp][4] # cMOEDAEST //.OR. aTPC[nTabDesp][4] # 'USD'
                  nMin:= aTPC[nTabDesp][10] * (BuscaTaxa(aTPC[nTabDesp][4],dDataBase,.T.,.F.,.T.) / BuscaTaxa(cMOEDAEST,dDataBase,.T.,.F.,.T.))
                  nMax:= aTPC[nTabDesp][9]  * (BuscaTaxa(aTPC[nTabDesp][4],dDataBase,.T.,.F.,.T.) / BuscaTaxa(cMOEDAEST,dDataBase,.T.,.F.,.T.))
               ENDIF
			       IF WorkTP->WKVL_PAGTO < nMin                    // SWI->WI_VAL_MIN
                  WorkTP->WKVL_PAGTO := nMin
               ELSEIF WorkTP->WKVL_PAGTO > nMax .AND. nMax # 0 // SWI->WI_VAL_MAX
                  WorkTP->WKVL_PAGTO := nMax
               ENDIF
            ENDIF
         ENDIF
         WorkTP->(DbSkip())
      ENDDO
      WorkTP->(DbSetOrder(nSaveOrder))
      SW8->(DBSKIP())
   ENDIF
ENDDO
SW8->(DBSETORDER(1))

*----------------------------------------------------------------------------
FUNCTION TPC252Pagtos(aPagtos,PDT_EMB,PFOB,PDt_Real,cCondPa,nDiasPa,cDBF)     //NCF - 13/12/10 - Inclusão do 7º Parametro "cDBF" - Considerar FOB na base dos PRE`s
*---------------------------------------------------------------------------- //                 provenientes da tabela de pré-cálculo quando PO\Embarque não possuir
LOCAL _pos, OldSelect, MPerc, nDias, dVencto,cInv:=''                         //                 cobertura cambial.

OldSelect:=SELECT()
DBSELECTAREA("SY6")
DBSeek(xFilial()+cCondPA+STR(nDiasPA,3,0))
IF SY6->Y6_TIPOCOB == "4" //.AND. cDBF # "W7_" //Sem cobertura //MCF - 09/06/2016
   AADD(aPagtos,{PDT_EMB+nDiasPa,PFOB,PDt_Real,100,nDiasPa,cInv}) 
   DBSELECTAREA(OldSelect)
   RETURN aPagtos
ENDIF
IF nDiasPA <= 900 // Significa pagamento a vista ou normal , nunca antecipado
   AADD(aPagtos,{PDT_EMB+nDiasPa,PFOB,PDt_Real,100,nDiasPa,cInv})
   DBSELECTAREA(OldSelect)
   RETURN aPagtos
ENDIF

_pos:='01'
DO WHILE (MPerc:=FIELDGET(FIELDPOS("Y6_PERC_"+_pos))) # NIL .AND. MPerc # 0  .AND. xFilial("SY6")=SY6->Y6_FILIAL
   nDias  :=FIELDGET(FIELDPOS("Y6_DIAS_"+_pos))
   _pos   :=STRZERO(VAL(_pos)+1,2)
   dVencto:=PDT_EMB+nDias

   IF EasyEntryPoint("EICPTR01")
      If EasyExRdm("U_EICPTR01", "7", @nDias, @lDespAnalitico, @lDespSintetico, @dVencto)      
         Loop
      EndIf
   ELSE
/*    IF nDias < 0
         LOOP
      ENDIF*/
      IF dVencto < dDataBase
         dVencto:= dDataBase
      ENDIF
   ENDIF
   AADD(aPagtos,{dVencto,PFOB*MPerc/100,PDt_Real,MPerc,nDias,cInv})
   IF SY6->(FIELDPOS("Y6_PERC_"+_pos)) = 0
      EXIT
   ENDIF
ENDDO
DBSELECTAREA(OldSelect)
RETURN aPagtos


//**FSY - 18/09/2013 - Função TPC252Grava foi restaurada pela versão do TFS da data 04/04/2013 por apresentar não conformidades na logica para gravar e calcular os valores do titulo
//TPC252Grava responsavel por calcular e gravar os titulos para serem exibidas na tela de previsão de desembolso
*--------------------------------------------------------------------------------
FUNCTION TPC252Grava(PDesp,PDt_Pagto,nVl_Pagto,PTAB,MTotGer,MTipo,MOrdem,;
		     zPDt_Real,PFobPerc,PFobDias,MInvoice,PDBF,cCond_PA,nDias_PA)
*--------------------------------------------------------------------------------
Local 	MPO_NUM:=SW2->W2_PO_NUM, cHawb, dDtCheg
Local lAtualizaValor := .T., lInclusao := .F. //LRS - 14/01/2016
Local aORD := {} //LRS - 14/01/2016
Private PVl_Pagto:=nVl_Pagto
Private nSaveOrder:=WorkTP->(IndexOrd())  //ACB - 05/05/2010
//***  SVG  - 23/10/2010 - Utilização em Rdmake
Private ZPDesp := PDesp, ZPDt_Pagto := PDt_Pagto, ZPTAB := PTAB, ZMTotGer := MTotGer , ZMTipo := MTipo
Private ZMOrdem := MOrdem , PDt_Real := zPDt_Real , ZPFobPerc := PFobPerc , ZPFobDias := PFobDias , ZMInvoice := MInvoice
Private cZCond_PA := cCond_PA , nZDias_PA := nDias_PA

   //***  SVG  - 23/10/2010 - para sintetico acumula sempre no primeiro dia do mes
   IF aParc_Pgtos = NIL
      aParc_Pgtos:={}
   ENDIF

   IF cCond_PA = NIL
      cCond_PA:= SPACE(1)
   ENDIF

   IF PVl_Pagto = 0             // nao Grava despesas com 0
      RETURN NIL
   ENDIF

   If Left(PDesp, 1) $ EasyGParam("MV_EIC0034",,"") //RMD - 02/10/13 - Não imprimir despesas iniciadas por estes códigos. (Ex.: 1;2;...) //LRS - 07/04/2015 - Correção do parametro.
      Return Nil
   EndIf

   IF PDesp $ "101" .AND. cPO_NUM <> MPO_NUM
      cPO_NUM := MPO_NUM
      SWB->(DBSETORDER(1))

      // ** GCC - 28/08/2013 - Tratamento para os tipos de pagamentos antecipados tanto para vinculados a PO quanto para Fornecedor
      If SWB->(DbSeek(xFilial("SWB")+AvKey(MPO_NUM,"W6_HAWB")+"A"))
         cTipAD := "A"
      ElseIf SWB->(DbSeek(xFilial("SWB")+AvKey(MPO_NUM,"W6_HAWB")+"F"))
         cTipAD := "F"
      ElseIf SWB->(DbSeek(xFilial("SWB")+AvKey(MPO_NUM,"W6_HAWB")+"C"))
         cTipAD := "C"
      EndIf
      // **

      DO WHILE SWB->(!EOF()) .AND. xFILIAL("SWB") = SWB->WB_FILIAL .AND. SWB->WB_HAWB = AVKEY(MPO_NUM,"W6_HAWB")  ;
                           .AND. cTipAD = SWB->WB_PO_DI

         IF !EMPTY(SWB->WB_CA_DT) .AND. ASCAN(aParc_Pgtos,{|nASC| nASC[1]==MPO_NUM .AND. nASC[4]==SWB->WB_LINHA }) == 0  // GFP - 18/10/2013
            nPOS:=ASCAN(aParc_Pgtos,{|nASC| nASC[1]=MPO_NUM })
            IF nPOS # 0 .AND. aParc_Pgtos[nPOS,4] == SWB->WB_LINHA
               aParc_Pgtos[nPOS,2]+=(SWB->WB_PGTANT*SWB->WB_CA_TX)
            ELSE
               AADD(aParc_Pgtos,{MPO_NUM,(SWB->WB_PGTANT*SWB->WB_CA_TX),SWB->WB_CA_TX,SWB->WB_LINHA})
            ENDIF
         ENDIF

         SWB->(DBSKIP())
      ENDDO
   ENDIF

   IF MTipo = _Sintetico
      PDt_Pagto:=AVCTOD('01/'+SUBST(DTOC(PDt_Pagto),4))
   ENDIF

   IF PDt_Real = NIL
      PDt_Real:= AVCTOD("")
   ENDIF
   WorkTP->(DbSetOrder(2))
   WorkTP->(DBSeek(MPO_NUM+DTOS(PDt_Pagto)+PDesp))

   If PDBF == "W7_" .AND. SW7->(!Eof()) .AND. Mordem # _PO           // GFP - 27/09/2013    // RMD - 19/09/2013
      If SW6->W6_HAWB == SW7->W7_HAWB .OR. SW6->(DbSeek(xFilial()+SW7->W7_HAWB)) //AAF 24/07/2015 - Melhorar performance.
         If SW6->W6_TAB_PC <> PTAB
            Return Nil
         EndIf
      EndIf
   EndIf

   // RA - 19/08/03 - O.S. 804/03 - Inicio
   If Mtipo == _Sintetico .And. PDBF == "W7_" //Mordem == _Embarque
      If !lAvFluxo .AND. MOrdem == _Data
         WorkTP->(DbSetOrder(1))  //"WK_HAWB+WKPO_NUM+DTOS(WKDT_PAGTO)+WKDESPESA"
         WorkTP->(DBSeek(SW6->W6_HAWB+MPO_NUM+DTOS(PDt_Pagto)+PDesp))
      Else
         WorkTP->(DbSetOrder(6))
         WorkTP->(DBSeek(SW6->W6_HAWB+DTOS(PDt_Pagto)+PDesp))
      EndIf
   Endif
   // RMD - 09/09/13 - Deixa o HAWB sempre disponível
      // RA - 19/08/03 - O.S. 804/03 - Final
      If PDBF # "W7_" //.And. Mordem # _Embarque   // GFP - 03/10/2013
         cHawb   := SPACE(LEN(SW7->W7_HAWB))
         dDtCheg := AVCTOD("")
      ELSE
         cHawb   := SW7->W7_HAWB
         dDtCheg := If(!Empty(SW6->W6_CHEG),SW6->W6_CHEG,SW6->W6_DT_ETA)
      EndIf
   /*
      cHawb   := SW7->W7_HAWB
      dDtCheg := SW6->W6_CHEG
   */
   IF EasyEntryPoint("EICPTR01")
      If EasyExRdm("U_EICPTR01", "15", PDesp, PDt_Pagto, MPO_NUM, PDBF, nSaveOrder, @cInv, @cAux, lDespAnalitico, lW7, @MInvoice)    
         Return Nil
      EndIf
   EndIf

   aORD := SAVEORD({"SWI"}) //LRS - 14/01/2016
   SWI->(DbSetOrder(1)) //LRS
   SYB->(DBSeek(xFilial()+PDesp))
   //If !SW2->W2_FORN == MPO_NUM //AAF 24/07/2015 - Melhorar performance.
   If !SW2->W2_PO_NUM == MPO_NUM //AAF 24/07/2015 - Melhorar performance.
      SW2->(DBSeek(xFilial()+MPO_NUM))
   EndIf
   If SA2->(xFilial()) + SW2->W2_FORN + SW2->W2_FORLOJ <> SA2->(A2_FILIAL + A2_COD + A2_LOJA)
      SA2->(DBSeek(xFilial()+SW2->W2_FORN+SW2->W2_FORLOJ))
   EndIf

   IF WorkTP->(Eof()) //.OR. (!lAvFluxo .AND. (/*Mordem == _Embarque .OR.*/ Mordem == _Data) .AND. WorkTP->WKPO_NUM <> MPO_NUM)
      WorkTP->( DBAPPEND() )
      lInclusao := .T. //LRS
      WorkTP->WKDT_PAGTO := PDt_Pagto
      WorkTP->WKDESPESA  := PDESP
      WorkTP->WKPO_NUM   := MPO_NUM
      WorkTP->WK_HAWB    := cHawb
      WorkTP->WK_CHEG    := dDtCheg
      WorkTP->WKDESPDESC := SYB->YB_DESCR
      //LGS-27/01/2016 - Tratamento para chamada da rotina NU400PreCalc utilizada na rotina de numerario.
      /* wfs - A despesa será base de adiantamento, logo, o fornecedor deve ser o associado ao despachante.
         Tratamento migrado para NU400PreCalc
      If Type("lEICNU400") == "L" .And. lEICNU400
         WorkTP->WKFORN_N:= SA2->A2_COD
      Else */
      WorkTP->WKFORN_N   := SA2->A2_NOME
      WorkTP->WKFORN_R   := SA2->A2_NREDUZ
      If EICLoja()
         WorkTP->WKFORLOJ:= SA2->A2_LOJA
      EndIf
      WorkTP->WKNUM_PC   := PTAB
      WorkTP->WKDT_EMB   := AjustaDtEmb(PDt_Real,MPO_NUM)  // GFP - 09/06/2014
      IF ! EMPTY(cCond_PA)
         WorkTP->WKCONDICAO := cCond_PA+STR(nDias_PA,3,0)
      ELSE
         WorkTP->WKCONDICAO := SW2->W2_COND_PAG+STR(SW2->W2_DIAS_PA,3,0)
      ENDIF

      //AAF 24/07/2015 - Determinar a moeda logo na criacao da despesa (problema de performance).
      If !Empty(cHawb) .AND. SWD->(DbSeek(xFilial("SWD")+AvKey(cHawb,"WD_HAWB")+AvKey(PDesp,"WD_DESPESA")))
         WorkTP->WKMOEDA := SYB->YB_MOEDA
      ElseIf SWI->(DbSeek(xFilial("SWI")+AvKey(pTab,"WI_TAB")+AvKey(PDesp,"WI_DESP")))
         WorkTP->WKMOEDA := SWI->WI_MOEDA
      Else
         WorkTP->WKMOEDA := "US$"
      EndIf
   ENDIF

   If EasyEntryPoint("EICPTR01")
      EasyExRdm("U_EICPTR01", "9", @MInvoice, @lDespAnalitico, @cInv, @cAux, @lW7)  	
   EndIf

   IF(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"GRAVA_WORKTP"),)
   /* //NCF - 25/08/2016 - Nopado - Valor tem de ser atualizado
   IF SWI->(DbSeek(xFilial("SWI")+AvKey(pTab,"WI_TAB")+AvKey(PDesp,"WI_DESP"))) //LRS - 14/01/2016 - Quando tiver mais de uma invoice e o tipo valor for diferente de 1, não colocar novamente o valor na work
      IF SWI->WI_IDVL == "1" .AND. !lInclusao .And. PDesp <> "101"
         lAtualizaValor := .F.
      EndIF
   EndIF
   */
   IF lAtualizaValor .Or. IsInCallStack("NU400PreCalc") //LGS-07/07/2016 - Chamada pela Solicit.numerario
      WorkTP->WKVL_PAGTO := WorkTP->WKVL_PAGTO + PVl_Pagto//FSY - 18/09/2013 - Manter fora do "IF WorkTP->(Eof())"
      WorkTP->WKVLPAGTO2 := WorkTP->WKVLPAGTO2 + PVl_Pagto // GFP - 16/01/2014
   EndIF

   IF PFobPerc # NIL
      WorkTP->WKFOBPERC := PFobPerc
      WorkTP->WKFOBDIAS := PFobDias
   ENDIF

   IF(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"APOS_GRAVA_WORKTP"),)  //ACB - 05/05/2010
   WorkTP->(DbSetOrder(nSaveOrder))                                   //mjb180299

   RESTORD(aORD,.T.)

RETURN NIL

*----------------------------------------------------------------------------
FUNCTION TPC252Ordem(MTipo,L1)
*----------------------------------------------------------------------------
IF(MTipo = _Sintetico .AND. MOrdem # 0,MOrdem,)
RETURN
*----------------------------------------------------------------------------
FUNCTION TPC252Txt(MTipo,WorkFile,WorkNTX2,WorkNTX3,WorkNTX4,WorkNTX5,WorkNTX6,WorkNTX7)
*----------------------------------------------------------------------------
LOCAL nOldRec:=WorkTP->(RECNO()),;
      nOldOrd:=WorkTP->(INDEXORD()), WorkIndex, fHandle, nBytes

LOCAL WorkTxt:="PFE"+STRZERO(DAY(dDataBase),2)+STRZERO(MONTH(dDataBase),2)+".TXT"

LOCAL cTitulo:="01,P,FORNEC.ESTRANGEIRO  ,IMPORTACAO EM ANDAMENTO       ,"

LOCAL cDate:=DTOC(dDataBase)+",", cPagto:=",00/00/00,"

LOCAL cPicture:=" 99999999999999.99", Tx_Usd:=BuscaTaxa(cMOEDAEST,dDataBase,.T.,.F.,.T.)

LOCAL bTxt:={|| FWRITE(fHandle,cTitulo+WorkTP->WKFORN_N+",1,"+cDate+;
   		       DTOC(WKDT_PAGTO)+cPagto+;
		          TRAN(WorkTP->WKVL_PAGTO*-1*Tx_Usd,cPicture) + New_Line)}

IF MTipo # _Analitico
   Help("", 1, "AVG0000579")//MsgInfo(STR0036,OemToAnsi(STR0037)) //"TXT SOMENTE PODE SER GERADO P/ O ANALITICO"###"Informa‡Æo"
   RETURN .F.
ENDIF

//C53 @ 23,0 CLEAR TO 24,79

IF FILE(WorkTxt)
   IF !MsgYesNo(OemToAnsi(STR0038+WorkTxt+STR0039),STR0040)// # "S" //"ARQUIVO "###" Jµ EXISTE, SOBREPOR ?"###"Sobrepor"
      RETURN .F.
   ENDIF
ENDIF
IF (fHandle:= EasyCreateFile(WorkTxt)) < 0
   Help("", 1, "AVG0000582",,WorkTxt+STR0042+STR(FERROR(),5,0),1,20)//MsgInfo(OemToAnsi(STR0041+WorkTxt+STR0042+STR(FERROR(),5,0)),OemToAnsi(STR0037)) //"ERRO NA CRIA€ÇO DO "###" CODIGO = "###"Informa‡Æo"
   RETURN .F.
ENDIF

WorkTP->(DBSETORDER(3))
WorkTP->(DBGOTOP())
WorkIndex:=E_Create(,.F.) //E_Create({},.T.) //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

INDEX ON DTOS(WKDT_PAGTO)+WKFORN_N TO (WorkIndex) WHILE WKDESPESA=DESPESA_FOB

WorkTP->(DBEVAL(bTxt))

FWRITE(fHandle,EOF_Text)

nBytes:=FSEEK(fHandle,0,1)    // posicao atual do arquivo

FCLOSE(fHandle)

IF nBytes <= 1                // so' existe a marca de final de arquivo ?
   Help("", 1, "AVG0000586")//MsgInfo(OemToAnsi(STR0043),OemToAnsi(STR0037)) //"NÇO Hµ  REGISTROS A SEREM GERADOS"###"Informa‡Æo"
   ERASE(WorkTxt)
ELSE
   Help("", 1, "AVG0000587",,WorkTxt+STR0044,1,9)//MsgInfo(STR0038+WorkTxt+STR0044,OemToAnsi(STR0037)) //"ARQUIVO "###" GERADO COM SUCESSO"###"Informa‡Æo"
ENDIF

WorkTP->(DBCLEARINDEX())
ERASE (WorkIndex+RetIndExt())
SET INDEX TO (WorkFile),(WorkNTX2),(WorkNTX3),(WorkNTX4),(WorkNTX5),(WorkNTX6),(WorkNTX7)
WorkTP->(DBSETORDER(nOldOrd))
WorkTP->(DBGOTO(nOldRec))
RETURN .T.
*----------------------------------------------------------------------------
FUNCTION TPC252Pagou(despesa,aDespBase)
*----------------------------------------------------------------------------
LOCAL ValUSD
Private lLoop              //ACB - 05/05/2010
Private cCodDesp := despesa//ACB - 05/05/2010

//LGS-27/01/2016 - Tratamento para chamada da rotina NU400PreCalc utilizada na rotina de numerario.
lEICNU400 := (Type("lEICNU400") == "L" .And. lEICNU400)

			  // na verdade a array aPagtos ja' contem os FOBs
IF despesa = DESPESA_FOB  // nao pagos e se a pesquisa fosse feita aqui pode-
   RETURN .F.             // ria encontrar a 1a parcela no DDI, desprezando o
ENDIF                     // calculo das parcelas nao pagas, ao nao passar o
																								  // FOB da array TPC para a funcao TPCCALCULO
IF (EasyGParam("MV_EASYFIN",,"N") == "S" .Or. lAvIntDesp) .AND. lAvFluxo .aND. !lEICNU400  //wfs 03/07/2014 - atualização dos valores para integração via EAI
   RETURN .F.
ENDIF

lLoop := .F.  //ACB - 05/05/2010
IF EasyEntryPoint("EICTP252") //ACB - 05/05/2010
   ExecBlock("EICTP252",.F.,.F.,"PAGOU_DESPESAS")
EndIf

If lLoop //ACB - 05/05/2010
   Return .F.
EndIf

IF SWD->(DBSeek(xFilial()+SW7->W7_HAWB+despesa))
   IF ALLTRIM(despesa) == DESPESA_FRETE
      lFrete_SWD:=.t.
   ENDIF
   ValUSD:=SWD->WD_VALOR_R/BuscaTaxa(cMOEDAEST,SWD->WD_DES_ADI,.T.,.F.,.T.)
   AADD(aDespBase,{despesa,ValUSD})
ENDIF
RETURN SWD->(FOUND())

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TPC252Print³ Autor ³ ROBSON/AVERAGE        ³ Data ³ 30.06.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Impressao da Carta p/ Envio de P.O.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
FUNCTION TPC252Print(M_Total,MTipo,MOrdem,MDt_I,MDt_F,MSubTit)
LOCAL nRecno:=WorkTP->(RECNO())
LOCAL aDados :={"WorkTP",;
					STR0045 ,; //"Impressao do Relatorio da Previsao de Desembolso"
     				MSubTit,;
					"",;
					"G",;
	     			132,;
					"",;
		     		"",;
			        STR0046       ,; //"Previsao de Desembolso"
					{ STR0047, 1,STR0048, 1, 2, 1, "",1 },; //"Zebrado"###"Importa‡ao"
						"EICTP252",;
					{ {|| .T. } , {|| .T. }  }  }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

LOCAL cString    := aDados[1]
LOCAL cDesc1     := aDados[2]
LOCAL cDesc2     := aDados[3]
LOCAL cDesc3     := aDados[4]
LOCAL cabec1     := aDados[7]
LOCAL cabec2     := aDados[8]
LOCAL wnrel      := aDados[11]

LOCAL lPermiteComprimir:=.T.

PRIVATE tamanho := aDados[5]
PRIVATE limite  := aDados[6]
PRIVATE Titulo  := aDados[9]
PRIVATE aReturn := aDados[10]  // 1=formulario, 2=no.vias, 3=destinatario
				// 4=formato (1-comprimido, 2-normal)
				// 5=midia (1-disco, 2-impressora)
				// 6=porta (1-lpt1, 2-lpt2, 4-com1)
				// 7=expressao do filtro
				// 8=ordem a ser selecionada
PRIVATE R_Funcoes:= aDados[12]

PRIVATE nomeprog := wnrel
PRIVATE nLastKey := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel := SetPrint(cString,wnrel,,@Titulo,cDesc1,cDesc2,cDesc3,.f.,"",lPermiteComprimir,tamanho)

If nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

RptStatus({|lEnd| TPC252Rel(@lEnd,wnRel,cString,M_Total,MTipo,MOrdem,MDt_I,MDt_F)},Titulo)

WorkTP->(DBGOTO(nRecno))

Return

*----------------------------------------------------------------------------
FUNCTION TPC252REL(lEnd,wnRel,cString,M_Total,MTipo,MOrdem,MDt_I,MDt_F)
*----------------------------------------------------------------------------
Li   := 80
M_Pag:= 01
MPag := 00
mLin := 60

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz manualmente porque nao chama a funcao Cabec()                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a Regua                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetRegua(WorkTP->(LASTREC()),STR0049) //"Processando Registros..."

WorkTP->(DBGOTOP())

MLin    := 0
MPag    := 0
MConta  := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Compoe o Driver de Impressao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
If aReturn[4] == 1                                      // Comprimido
   @ 001,000 PSAY &(aDriver[1])
ElseIf aReturn[4] == 2                          // Normal
   @ 001,000 PSAY &(aDriver[2])
EndIf
*/

IF MTipo == 1
   TPC_Ana(MOrdem,MDt_I,MDt_F,M_Total,MTipo,lEnd)
ELSE
   TPC_Sin(MOrdem,MDt_I,MDt_F,lEnd)
ENDIF

Set Device to Screen
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
   Set Printer TO
   Commit
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return .T.

*----------------------------------------------------------------------------
FUNCTION TPC_Ana(POrdem,MDt_I,MDt_F,M_Total,MTipo,lEnd)
*----------------------------------------------------------------------------
PRIVATE TDt_I := MDt_I , TDt_F := MDt_F , MOrdem:= POrdem , TB_DtPos:={}

MPag := 0 ; MLin := 90 ; MTotal_1:= MTotal_2 := MCont_1 := MCont_2 := nTotMes:=0
nTotFixo:=nTotOutros:=nMesFixo:=nMesOutros:=nDiaFixo:=nDiaOutros:=nContMes:=nGerFixo:=nGerOutros:=0
cMesRel:=(month(WKDT_PAGTO)+year(WKDT_PAGTO))
MContMes:=0

nColValor:=69

DO CASE
   CASE MOrdem == _Embarque
								MHAWB_Ant := WK_HAWB
								MTexto    := STR0050 + IF(EMPTY(THAWB),STR0051,THAWB) + " )" //"Analitico - Por Processo ( "###'Todos'
								MDizTot2  := STR0052 //"TOTAL DO DIA...................:"
								MDizTot1  := STR0053 //"TOTAL DO PROCESSO..............:"
   CASE MOrdem == _PO
								MPo_Ant   := WKPO_NUM
								MTexto    := STR0054 + IF(EMPTY(TPO_NUM),STR0051,TRAN(TPO_NUM,_PictPo)) + " )" //"Analitico - Por P.O. ( "###'Todos'
								MDizTot2  := STR0052 //"TOTAL DO DIA...................:"
								MDizTot1  := STR0055 //"TOTAL DO P.O...................:"
   CASE MOrdem == _Despesa
								MDesp_Ant := WKDESPESA
   								MTexto := STR0056 + IF(EMPTY(TDESP),STR0057,TRANSF(TDESP,'@R 9.99')) + " )" //"Analitico - Por Despesa ( "###'Todas'
 								MDizTot2  := STR0058 //"TOTAL DO DIA..............:"
								MDizTot1  := STR0059 //"TOTAL DA DESPESA..........:"
   CASE MOrdem == _Data
								MDt_Ant   := WKDESPESA
								MTexto    := STR0060+DTOC(TDT_I)+STR0022+DTOC(TDT_F) + " )" //"Analitico - Por Data ( Periodo de "###" a "
								MDizTot2  := STR0061 //"TOTAL DO DESPESA......:"
								MDizTot1  := STR0062 //"TOTAL DA DIA..........:"
ENDCASE

MDt_Ant  := WKDT_PAGTO
MDesp_Ant:= WKDESPESA

MBate_1  := MBate_2 := .T.

DO WHILE ! EOF()

   IncRegua()

   If lEnd
      @PROW()+1,001 PSAY STR0063 //"CANCELADO PELO OPERADOR"
      Exit
   Endif

   IF MLin > 58
      TPCAna_Cab()
   ENDIF

   IF MOrdem == 1
      IF MHAWB_Ant # WK_HAWB
								 TPCQb_Ana(MDizTot2,MDizTot1,32,nColValor,'G')
								 MHAWB_Ant:= WK_HAWB
								 MDt_Ant  := WKDT_PAGTO
      ENDIF

      IF MDt_Ant # WKDT_PAGTO
								 TPCQb_Ana(MDizTot2,MDizTot1,32,nColValor,'S')
								 MDt_Ant:= WKDT_PAGTO
								 MLin ++
      ENDIF
   ELSEIF MOrdem == 2
      IF MPo_Ant # WKPO_NUM
								 TPCQb_Ana(MDizTot2,MDizTot1,32,nColValor,'G')
								 MPo_Ant := WKPO_NUM
								 MDt_Ant := WKDT_PAGTO
      ENDIF
      IF MDt_Ant # WKDT_PAGTO
								 TPCQb_Ana(MDizTot2,MDizTot1,32,nColValor,'S')
								 MDt_Ant:= WKDT_PAGTO
								 MLin ++
      ENDIF
   ELSEIF MOrdem == 3
      IF MDesp_Ant # WKDESPESA
								 TPCQb_Ana(MDizTot2,MDizTot1,40,nColValor,'G')
								 MDesp_Ant := WKDESPESA ; MDt_Ant := WKDT_PAGTO
      ENDIF
      IF MDt_Ant # WKDT_PAGTO
								 TPCQb_Ana(MDizTot2,MDizTot1,40,nColValor,'S')
								 MDt_Ant := WKDT_PAGTO ; MLin ++
      ENDIF
   ELSEIF MOrdem == 4
      IF MDt_Ant # WKDT_PAGTO
								 TPCQb_Ana(MDizTot2,MDizTot1,40,nColValor,'G')
								 MDt_Ant := WKDT_PAGTO ; MDesp_Ant := WKDESPESA
      ENDIF
      IF MDesp_Ant # WKDESPESA
								 TPCQb_Ana(MDizTot2,MDizTot1,40,nColValor,'S')
								 MDesp_Ant := WKDESPESA ; MLin ++
      ENDIF
   ENDIF
   TPCAna_Det()
   DBSKIP()
ENDDO

IF MPag > 0

   IF MOrdem == 1
      TPCQb_Ana(MDizTot2,MDizTot1,32,nColValor,'G')
      IF EMPTY(THAWB)
         MLin ++
         @MLin,32 PSAY  STR0064 //"TOTAL GERAL....................:"
     //  @MLin,71 PSAY  TRAN(M_Total,"@E 999,999,999,999.99")
         @MLin,nColValor PSAY  TRAN(M_Total,cPictGeral)
         If(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"IMP_TOTGER"),) // RA - 14/08/2003
      ENDIF
   ELSEIF MOrdem == 2
      TPCQb_Ana(MDizTot2,MDizTot1,32,nColValor,'G')
      IF EMPTY(TPO_NUM)
         MLin ++
         @MLin,32 PSAY  STR0064 //"TOTAL GERAL....................:"
         @MLin,nColValor PSAY  TRAN(M_Total,cPictGeral)
         If(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"IMP_TOTGER"),) // RA - 14/08/2003
      ENDIF
   ELSEIF MOrdem == 3
      IF EasyEntryPoint("EICPTR01")
         EasyExRdm("U_EICPTR01", "10", @TDESP, @nGerFixo, @nGerOutros, @MDizTot2, @MDizTot1, M_Total)          
      Else
         TPCQb_Ana(MDizTot2,MDizTot1,40,nColValor,'G')
         If Empty(TDESP)
            MLin ++
            @MLin,40 PSAY STR0065 //"TOTAL GERAL...............:"
            @MLin,nColValor PSAY TRAN(M_Total,cPictGeral)
            If(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"IMP_TOTGER"),) // RA - 14/08/2003
         EndIf
      EndIf
   ELSEIF MOrdem == 4
      TPCQb_Ana(MDizTot2,MDizTot1,40,nColValor,'G')
      MLin ++
      @MLin,40 PSAY STR0065 //"TOTAL GERAL...............:"
      @MLin,nColValor PSAY TRAN(M_Total,cPictGeral)
      If(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"IMP_TOTGER"),) // RA - 14/08/2003
   ENDIF
// EJECT
ENDIF

*----------------------------------------------------------------------------
FUNCTION TPCAna_Cab()
*----------------------------------------------------------------------------
*Ordem Data
*Data        Despesa                                No. P.O.                        Valor    Tabela    Fornecedor         Embarque    Condicao Pagamento
*--------    -----------------------------------    ---------------    ------------------    ------    ---------------    --------    --------------------------------------------
*99/99/99    9.99 zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz    999999999999999    999,999,999,999.99     9999     zzzzzzzzzzzzzzz    99/99/99    9.9.999 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*1           13                                     52                 71                    93        103                122         134
*
*Ordem P.O.
*No. P.O.           Data        Despesa                                             Valor    Fornecedor         Tabela    Embarque    Condicao Pagamento
*---------------    --------    -----------------------------------    ------------------    ---------------    ------    --------    --------------------------------------------
*999999999999999    99/99/99    9.99 zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz    999,999,999,999.99    zzzzzzzzzzzzzzz     9999     99/99/99    9.9.999 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*1                  20          32                                     71                    93                 112       122         134
*
*Ordem Despesa
*Despesa                                Data        No P.O.                         Valor    Tabela    Fornecedor         Embarque    Condicao Pagamento
*-----------------------------------    --------    ---------------    ------------------    ------    ---------------    --------    --------------------------------------------
*9.99 zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz    99/99/99    zzzzzzzzzzzzzzz    999,999,999,999.99     9999     zzzzzzzzzzzzzzz    99/99/99    9.9.999 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*1                                      40          52                 71                    93        103                122         134

MPag ++
MLin:= 1
If(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"CAB_ANA"),) // RA - 15/08/2003
Cabec(Titulo,MTexto,"",nomeprog,tamanho,EasyGParam("MV_COMP"))
MLin:=PROW()+1
@ MLin,000 PSAY REPLI('*',LIMITE)
MLin +=2
MLin ++

IF EMPTY(TImport)
   @MLin,001 PSAY STR0066 + STR0009 //"Importador.: "###"Geral"
ELSE
   @MLin,001 PSAY STR0066 + TImport + " " + SYT->YT_NOME //"Importador.: "
ENDIF
MLin ++

If(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"IMP_CAB"),) // RA - 14/08/2003
If !lDesvioRDM // RA - 14/08/2003
   IF MOrdem == 1
      @++MLin,001 PSAY STR0067 //'No. Processo       Data        Despesa                                               Valor  Fornecedor         Tabela    Embarque    Condicao Pagamento'
      @++MLin,001 PSAY '---------------    --------    ----------------------------------- -----------------------  ---------------    ------    --------    --------------------------------------------'
   ELSEIF MOrdem == 2
      @++MLin,001 PSAY STR0068 //'No. P.O.           Data        Despesa                                               Valor  Fornecedor         Tabela    Embarque    Condicao Pagamento'
      @++MLin,001 PSAY '---------------    --------    ----------------------------------- -----------------------  ---------------    ------    --------    --------------------------------------------'
   ELSEIF MOrdem == 3
      IF EasyEntryPoint("EICPTR01")
         EasyExRdm("U_EICPTR01", "11")         
      Else
         @++MLin,001 PSAY STR0069 //'Despesa                                Data        No P.O.                           Valor  Tabela    Fornecedor         Embarque    Condicao Pagamento'
         @++MLin,001 PSAY '-----------------------------------    --------    --------------- -----------------------  ------    ---------------    --------    --------------------------------------------'
      EndIf
   ELSEIF MOrdem == 4
      @++MLin,001 PSAY StrTran(STR0070, "No P.O. ", "Processo") //'Data        Despesa                                No P.O.                           Valor  Tabela    Fornecedor         Embarque    Condicao Pagamento'   // RMD - 09/09/2013
      @++MLin,001 PSAY '--------    -----------------------------------    --------------- -----------------------  ------    ---------------    --------    --------------------------------------------'
   ENDIF
EndIf // RA - 14/08/2003

MBate_1 := MBate_2 := .T.

RETURN

*----------------------------------------------------------------------------
FUNCTION TPCAna_Det()
//MFR 04/04/2019 OSSME-2690
Private lDesvioDet := .F. // - Usada neste programa e no RdMake EICTP252_RDM
*----------------------------------------------------------------------------

IF MOrdem == 1
   IF MBate_1
      MLin ++
      @MLin,001  PSAY  WK_HAWB
      MBate_1 := .F.
   ENDIF
   IF MBate_2
      @MLin,020  PSAY  WKDT_PAGTO
      MBate_2 := .F.
   ENDIF
   @MLin,032  PSAY  TRAN(WKDESPESA,"@R 9.99")
   @MLin,037  PSAY  WKDESPDESC
   @MLin,nColValor  PSAY  TRAN(WKVL_PAGTO,cPictGeral)
   If(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"APOS_IMP_VAL"),) // RA - 14/08/2003
     //MFR 04/04/2019 OSSME-2690  
     IF !lDesvioDet
        IF WKDESPESA == DESPESA_FOB
           TPC252DetFob()
        ELSE
           @MLin,114+nSomaCol PSAY WKNUM_PC
        ENDIF
     ENDIF   
ELSEIF MOrdem == 2
   IF MBate_1
      MLin ++
      @MLin,001  PSAY  TRAN(WKPO_NUM,_PictPo)
      MBate_1 := .F.
   ENDIF
   IF MBate_2
      @MLin,020  PSAY  WKDT_PAGTO
      MBate_2 := .F.
   ENDIF
   @MLin,032  PSAY  TRAN(WKDESPESA,"@R 9.99")
   @MLin,037  PSAY  WKDESPDESC
   @MLin,nColValor  PSAY  TRAN(WKVL_PAGTO,cPictGeral)
   If(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"APOS_IMP_VAL"),) // RA - 14/08/2003
     //MFR 04/04/2019 OSSME-2690  
     IF !lDesvioDet
       IF WKDESPESA == DESPESA_FOB
          TPC252DetFob()
       ELSE
          @MLin,114+nSomaCol PSAY WKNUM_PC
       ENDIF
     ENDIF
ELSEIF MOrdem == 3
   IF EasyEntryPoint("EICPTR01")
      EasyExRdm("U_EICPTR01", "12")      
   Else
      IF MBate_1
         MLin ++
         @MLin,001 PSAY TRAN(WKDESPESA,"@R 9.99")
         @MLin,006 PSAY WKDESPDESC
         MBate_1 := .F.
      ENDIF
      IF MBate_2
         @MLin,040 PSAY WKDT_PAGTO ; MBate_2:= .F.
      ENDIF
      @MLin,052 PSAY TRAN(WKPO_NUM,_PictPo)
      @MLin,nColValor PSAY TRAN(WKVL_PAGTO,cPictGeral)
      If(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"APOS_IMP_VAL"),) // RA - 14/08/2003
        //MFR 04/04/2019 OSSME-2690  
        IF !lDesvioDet      
           IF WKDESPESA == DESPESA_FOB
              TPC252DetFob()
           ELSE
              @MLin,095+nSomaCol PSAY WKNUM_PC
           ENDIF
        ENDIF  
   EndIf
ELSEIF MOrdem == 4
   IF MBate_1
      MLin ++
      @MLin,001 PSAY WKDT_PAGTO
      MBate_1 := .F.
   ENDIF
   IF MBate_2
      @MLin,013 PSAY TRAN(WKDESPESA,"@R 9.99")
      @MLin,019 PSAY WKDESPDESC
      MBate_2:= .F.
   ENDIF
   //@MLin,052 PSAY TRAN(WKPO_NUM,_PictPo)   // RMD - 09/09/2013
   @MLin,052 PSAY WK_HAWB
   @MLin,nColValor PSAY TRAN(WKVL_PAGTO,cPictGeral)
   If(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"APOS_IMP_VAL"),) // RA - 14/08/2003
     //MFR 04/04/2019 OSSME-2690  
     IF !lDesvioDet
       IF WKDESPESA == DESPESA_FOB
          TPC252DetFob()
       ELSE
          @MLin, 95+nSomaCol PSAY WKNUM_PC   // RMD - 09/09/2013
          @MLin,103+nSomaCol PSAY WKFORN_R
          @MLin,122+nSomaCol PSAY WKDT_EMB
       ENDIF
     ENDIF 
ENDIF

MTotal_1+= WKVL_PAGTO
MTotal_2+= WKVL_PAGTO
MCont_1 ++
MCont_2 ++
MLin    ++

RETURN NIL

*----------------------------------------------------------------------------
FUNCTION TPCQb_Ana(MTexto2,MTexto1,MCol1,MCol2,MGer_Sub)
*----------------------------------------------------------------------------
// RA - Criadas variaveis privates para serem usadas no Ponto de Entrada
// Ponto de Entrada : IMP_TOTAL do U_EICTP252()
Private MTexto2_RDM := MTexto2, MTexto1_RDM := MTexto1, MCol1_RDM := MCol1
Private MCol2_RDM   := MCol2,  MGer_Sub_RDM := MGer_Sub
//
IF EasyEntryPoint("EICPTR01")
   EasyExRdm("U_EICPTR01", "13", @MTexto2, @MTexto1, @MCol1, @MCol2, @MGer_Sub)   
Else
   If(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"IMP_TOTAL"),) // RA - 14/08/2003
   If !lDesvioRDM
      IF MGer_Sub == 'G'
         IF (MCont_1 > 1) .Or. (MOrdem == _Data .And. EasyGParam("MV_EIC0033",,.F.) .And. MCont_1 > 0)//RMD - 02/10/13 - Imprime o cabeçalho completo na impressão por data
            IF (MCont_2 > 1) .Or. (MOrdem == _Data .And. EasyGParam("MV_EIC0033",,.F.) .And. MCont_2 > 0)//RMD - 02/10/13 - Imprime o cabeçalho completo na impressão por data
               @MLin,MCol2 PSAY REPLI('-',(LEN(cPictGeral)-3))
               MLin ++
               @MLin,MCol1 PSAY MTexto2
               @MLin,MCol2 PSAY TRAN(MTotal_2,cPictGeral)
               MLin ++
            ENDIF
            MLin ++
            @MLin,MCol1 PSAY MTexto1
            @MLin,MCol2 PSAY TRAN(MTotal_1,cPictGeral)
            MLin += 2
         ENDIF
         MTotal_2 := MTotal_1 := 0
         MCont_2  := MCont_1  := 0
         MBate_2  := MBate_1  := .T.
	  ELSE
         IF MCont_2 > 1 .Or. (MOrdem == _Data .And. EasyGParam("MV_EIC0033",,.F.) .And. MCont_2 > 0)//RMD - 02/10/13 - Imprime o cabeçalho completo na impressão por data
            @MLin,MCol2  PSAY REPLI('-',(LEN(cPictGeral)-3))
            MLin ++
            @MLin,MCol1  PSAY MTexto2
            @MLin,MCol2  PSAY TRAN(MTotal_2,cPictGeral)
            MLin += 2
         ENDIF
  		 MTotal_2 := MCont_2 := 0
  		 MBate_2  := .T.
      ENDIF
   EndIf
ENDIF
RETURN

*----------------------------------------------------------------------------
FUNCTION TPC_Sin(POrdem,MDt_I,MDt_F,lEnd)
*----------------------------------------------------------------------------
LOCAL Wind, ICOL
PRIVATE TDt_I := MDt_I , TDt_F := MDt_F , MOrdem:= POrdem
MTx_Usd := BuscaTaxa(cMOEDAEST,dDataBase,.T.,.F.,.T.)

Tb_Mes := ARRAY(nNumMeses); Tb_Pos   := ARRAY(nNumMeses); Tb_Col:= ARRAY(nNumMeses)
Tb_Tot := ARRAY(nNumMeses); Tb_TotMes:= ARRAY(nNumMeses)

//Tb_Col := {33,55,75,95,115,135,155,175,195,214 }
Tb_Col := {32,53,74,095,116,137,158,179,200}

AFILL(Tb_Mes,SPACE(18)); AFILL(Tb_Pos,0); AFILL(Tb_Tot,0); AFILL(Tb_TotMes,0)

FOR Wind = 1 TO nNumMeses
    Tb_Mes[Wind]:=TpcRel_Meses(Wind,'D')
    Tb_Pos[Wind]:=TpcRel_Meses(Wind,'P')
NEXT

MPag := 0
MLin := 90

IF MOrdem == 1
   MHAWB_Ant := WK_HAWB
   MTexto    := STR0071 + IF( EMPTY(THAWB),STR0051,ALLTRIM(THAWB)) + ")" //"Sintetico por Processo ( "###'Todos'
ELSEIF MOrdem == 2
   MPo_Ant   := WKPO_NUM
   MTexto    := STR0072 + IF( EMPTY(TPO_NUM),STR0051,ALLTRIM(TPO_NUM)) + ")" //"Sintetico por P.O. ( "###'Todos'
ELSEIF MOrdem == 3
   MDesp_Ant := WKDESPESA
   MTexto    := STR0073 + IF(EMPTY(TDESP),STR0057,TRANS(TDESP,'@R 9.99')) + ")" //"Sintetico por Despesa ( "###'Todas'

ENDIF

DO WHILE ! EOF()

   If lEnd
      @PROW()+1,001 PSAY STR0063 //"CANCELADO PELO OPERADOR"
      Exit
   Endif

   IF MLin > 58
      TPCSin_Cab()
   ENDIF

   IF MOrdem == 1
      @MLin,000 PSAY   WK_HAWB
      If MTipo == _Analitico       
         @MLin,018 PSAY   LEFT(WKFORN_R,13)
      EndIf
   ELSEIF MOrdem == 2
      @MLin,000 PSAY   WKPO_NUM
      If MTipo == _Analitico 
         @MLin, 016 PSAY WKFORN_R
      EndIf
   ELSEIF MOrdem == 3
      @MLin,000 PSAY   TRAN(WKDESPESA,'@R 9.99')
      @MLin,005 PSAY   SUBST(WKDESPDESC,1,24)
   ENDIF
   DO WHILE ! EOF()
      IF MOrdem == 1
								 IF WK_HAWB # MHAWB_Ant
								    EXIT
								 ENDIF
      ELSEIF MOrdem == 2
								 IF WKPO_NUM # MPo_Ant
								    EXIT
								 ENDIF
      ELSEIF MOrdem == 3
								 IF WKDESPESA # MDesp_Ant
								    EXIT
								 ENDIF
      ENDIF
      IncRegua()
      _MPos := ASCAN( Tb_Pos, MONTH(WKDT_PAGTO) )

      IF _MPos == 0
	        DBSKIP()
	        LOOP
      ENDIF

      Tb_TotMes[_MPos]+=WKVL_PAGTO
      Tb_Tot   [_MPos]+=WKVL_PAGTO
      DBSKIP()
   ENDDO

   FOR Wind = 1 TO nNumMeses
       @MLin,Tb_Col[Wind] PSAY TRANS(Tb_TotMes[Wind],cPictGeral)
   NEXT

   If(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"IMP_SIN"),) // RA - 15/08/2003

   AFILL(Tb_TotMes,0)

   MLin ++

   IF MOrdem == 1
      MHAWB_Ant:= WK_HAWB
   ELSEIF MOrdem == 2
      MPo_Ant  := WKPO_NUM
   ELSEIF MOrdem == 3
      MDesp_Ant:= WKDESPESA
   ENDIF

ENDDO

IF MPag > 0
   FOR ICOL := 1 TO nNumMeses
       @MLin,Tb_Col[ICOL] PSAY REPLI('-',(LEN(cPictGeral)-3))
   NEXT
   MLin ++
   @MLin,000 PSAY STR0074 //'TOTAL GERAL.........:'
   FOR Wind = 1 TO nNumMeses
       @MLin,Tb_Col[Wind] PSAY TRAN(Tb_Tot[Wind],cPictGeral)
   NEXT

   If(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"TOT_SIN"),) // RA - 15/08/2003

ENDIF
RETURN

*----------------------------------------------------------------------------
FUNCTION TPCSin_Cab()
*----------------------------------------------------------------------------
Local ICOL

MPag ++ ; MLin:= 1

If(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"CAB_SIN"),) // RA - 15/08/2003
Cabec(Titulo,MTexto,"",nomeprog,tamanho,EasyGParam("MV_COMP"))
MLin:=PROW()+1
MLin ++

IF EMPTY(TImport)
   @MLin,000 PSAY STR0066 + STR0009 //"Importador.: "###"Geral"
ELSE
   @MLin,000 PSAY STR0066 + TImport + ' ' + SYT->YT_NOME //"Importador.: "
ENDIF
MLin ++

If MTipo == _Analitico

   @MLin,000 PSAY IF(MOrdem=1,STR0075,IF(MOrdem=2,STR0076,STR0077)) //'No. Processo / Fornecedor'###'No. P.O. / Fornecedor'###'Despesa'

Else
   @MLin,000 PSAY IF(MOrdem=1,STR0109,IF(MOrdem=2,STR0110,STR0077)) //'No. Processo'###'No. P.O.'###'Despesa'

EndIf

FOR ICOL := 1 TO nNumMeses
    @MLin  ,Tb_Col[ICOL] PSAY Tb_Mes[ICOL]
NEXT
MLin ++

@MLin,000 PSAY REPLI('-',31)

FOR ICOL := 1 TO nNumMeses
    @MLin,Tb_Col[ICOL] PSAY REPLI('-',(LEN(cPictGeral)-3))
NEXT
MLin ++

RETURN NIL
*----------------------------------------------------------------------------
FUNCTION TpcRel_Meses(Q_Mes,MFLAG)
*----------------------------------------------------------------------------
LOCAL T_Mes:= { STR0078,STR0079,STR0080,STR0081,STR0082,STR0083,; //'Janeiro'###'Fevereiro'###'Marco'###'Abril'###'Maio'###'Junho'
																STR0084,STR0085,STR0086,STR0087,STR0088,STR0089 } //'Julho'###'Agosto'###'Setembro'###'Outubro'###'Novembro'###'Dezembro'

LOCAL _Month, _Ano:= YEAR(TDt_I) , Mes_Ret

_Month:= MONTH(TDt_I) + Q_Mes -1

IF _Month > 12
   _Month -=12 ; _Ano += 1
ENDIF

Mes_Ret := T_Mes[ _Month ] + STR0090 + STR(_Ano,4) //' de '

IF LEN(Mes_Ret) < 18
   Mes_Ret :=  SPACE((LEN(cPictGeral)-3)-LEN(Mes_Ret)) + Mes_Ret
ENDIF

IF MFLAG == 'D'
   RETURN Mes_Ret
ELSE
   RETURN _Month
ENDIF

*----------------------------------------------------------------------------
FUNCTION TPC_ResCab
*----------------------------------------------------------------------------
MPag ++ ; MLin:= 1
TPC252CabRel( 85,  STR0091, MPag,MTexto) //"RESUMO DA PREVISAO EM DOLAR"
MLin ++
IF EMPTY(TImport)
   @MLin,001 PSAY STR0066 + STR0009 //"Importador.: "###"Geral"
ELSE
   @MLin,001 PSAY STR0066 + TImport + ' '+ SYT->YT_NOME //"Importador.: "
ENDIF
MLin +=2

*Data                     No. P.O.                        Valor
*xx/xx/xx                 xxxxxxxxxxxxxxx                 999,999,999,999.99

@ MLin,001 PSAY STR0002 //"Data"
@ MLin,026 PSAY STR0004 //"No. P.O."
@ MLin,058 PSAY STR0005 //"Valor"
MLin ++

@ MLin,001 PSAY REPLI('-',08)
@ MLin,026 PSAY REPLI('-',Len(SW2->W2_PO_NUM))
@ MLin,058 PSAY REPLI('-',18)
MLin ++
RETURN NIL

*----------------------------------------------------------------------------
FUNCTION TPC252DetFob()
*----------------------------------------------------------------------------
Local cDias:=" "+STR(IF(WKFOBDIAS>=-1,WKFOBDIAS,WKFOBDIAS*-1),3)+STR0092 //" DIAS"

IF EasyEntryPoint("EICPTR01")
   EasyExRdm("U_EICPTR01", "14", @cDias, @MOrdem)   
Else
   IF STR(MOrdem,1) $ "3,4"
      @MLin, 95+nSomaCol PSAY WKNUM_PC
      @MLin,103+nSomaCol PSAY WKFORN_R
   ELSE
      @MLin, 94+nSomaCol PSAY WKFORN_R
      @MLin,114+nSomaCol PSAY WKNUM_PC
   ENDIF
   @MLin,122+nSomaCol PSAY WKDT_EMB
   @MLin,134+nSomaCol PSAY TRAN(LEFT(WKCONDICAO,5),'@R 9.9.999')+" com "
   @MLin,146+nSomaCol PSAY TRAN(WKFOBPERC,"@E 999.99")+"% A"
   @MLin,155+nSomaCol PSAY IF(WKFOBDIAS>=0,cDias,;
   IF(WKFOBDIAS=-1,STR0094,STR0095+cDias)) //" VISTA"###"ANTECIPADO A"
ENDIF
*----------------------------------------------------------------------------
FUNCTION TPC252ValPO()   // acionada pelo sx1 - ei252b
*----------------------------------------------------------------------------
If !Empty(mv_par01) .AND. !SW2->(DbSeek(xFilial()+mv_par01))
   Help("", 1, "AVG0000576")//MsgInfo(OemToAnsi(STR0096),OemToAnsi(STR0037)) //"P.O. nÆo cadastrado"###"Informa‡Æo"
   Return .F.
Endif
Return .T.

*----------------------------------------------------------------------------
FUNCTION TPC252ValHawb()   // acionada pelo sx1 - ei252b
*----------------------------------------------------------------------------
If !Empty(mv_par01) .AND. !SW6->(DbSeek(xFilial()+mv_par01))
   Help("", 1, "AVG0000589")//MsgInfo(OemToAnsi(STR0097),OemToAnsi(STR0037)) //"Processo nÆo cadastrado"###"Informa‡Æo"
   Return .F.
Endif
Return .T.
*----------------------------------------------------------------------------
FUNCTION TPC252ValDesp() // acionada pelo sx1 - ei252c
*----------------------------------------------------------------------------
If !Empty(mv_par01)
   If !SYB->(DbSeek(xFilial()+mv_par01))
      Help("", 1, "AVG0000592")//MsgInfo(OemToAnsi(STR0098),OemToAnsi(STR0037)) //"Despesa nÆo cadastrada"###"Informa‡Æo"
      Return .F.
   ElseIf mv_par01 = VALOR_CIF
   	  Help("", 1, "AVG0000593")//MsgInfo(OemToAnsi(STR0099),OemToAnsi(STR0037)) //"Despesa nÆo pode ser valor C.I.F."###"Informa‡Æo"
	     Return .F.
   Endif
Endif
Return .T.
*----------------------------------------------------------------------------
FUNCTION TPC252ValAno(lDatas)  // acionada pelo sx1 - ei252d/F
*----------------------------------------------------------------------------
IF lDatas == NIL
			IF mv_par02 == 00
						mv_par02 := 2000
			ENDIF
   IF mv_par01 > 12 .OR. mv_par01 < 1
      Help("", 1, "AVG0000594")//MsgInfo(OemToAnsi(STR0100),OemToAnsi(STR0037)) //"Mˆs fora do periodo de '01' A '12'"###"Informa‡Æo"
      Return .F.
   ElseIf EMPTY(mv_par02)
      Help("", 1, "AVG0000596")//MsgInfo(OemToAnsi(STR0101),OemToAnsi(STR0037)) //"Ano nÆo informado"###"Informa‡Æo"
      Return .F.
  ENDIF
ELSE
   IF !EMPTY(mv_par02) .AND. mv_par01 > mv_par02
      Help("", 1, "AVG0000598")//MsgInfo(STR0102,OemToAnsi(STR0037)) //"Data Final menor que e Data Inicial"###"Informa‡Æo"
      Return .F.
  ENDIF
ENDIF
Return .T.
*------------------------------------------------------------------------------------------
FUNCTION TPCCalculo(TPC,PSALDO_Q,PRATEIO,PTX_USD,bGrava,aPagtos,PTAB,;
		              aDespBase,PPp_Cc,Origem252,PDBF,MRateioPeso,dDtRef,nParidade,cImportador,lRegTriPO,bTPCPag, aBuffers,cChamada)
// ATENCAO: FUNCAO UTILIZADA NO TPC251 E TPC252
*------------------------------------------------------------------------------------------
LOCAL SaveMoeda:=' ', MPerc:=0, IndFOB, MDt_Pari
LOCAL bFOB, nTipoDesp:=Nil,nD
Local nBaseICMIN := 0, IndFrete:=0, xRetPE, nvalFrete
Local aOrdSWI:= {}
Local aOrdWork_1:= {} //TDF - 15/02/12
local nFobTot := 0    //TDF - 15/02/12
Local cChave_Ncm      //NCF - 08/02/2013
Local nIndDspAt := 0, nPosDspICM := 0
Local nEDspBII_P, nEDspBII_V , nEDspBIC_P , nEDspBIC_V, nPRateio, nValor 
Local nPosDesBas //THTS - 18/01/2018
Local lFretePerc := TPC:DESP = DESPESA_FRETE .And. (EasyGParam("MV_AVG0227",,.F.) .And. TPC[11] == '2' .And. Empty(SWI->WI_VIA) )
Local nBase102
Local aValBufNCM
Local lConverte := .F. //THTS - 08/07/2020 - Utilizada para identificar se o valor do imposto dever´s ser convertido para dólar ou não
Local cGrupoRT  := ""
Local lFasePO := IsMemVar("cAvFase") .And. !Empty(cAvFase)

Default cChamada := "" //MOstra qual fonte chamou a função, pois pode ter vindo do eictp251 ou eictp252
Default PDBF     := ""
// AWR - 20/05/2004 - MP164: as variaveis foram p/ private
PRIVATE nPeso := 0 , cAlias := IF(PDBF ="W7_","SW7",If(PDBF="W5_","SW5","SW3"))
Private lPontoEnt := .F. // RA - 23/01/2004 - O.S. 0123/04
PRIVATE lMV_PIS_EIC:= EasyGParam("MV_PIS_EIC",,.F.) .AND. SYD->(FIELDPOS("YD_PER_PIS"))#0 .AND. SYD->(FIELDPOS("YD_PER_COF"))#0 .AND. FindFunction("DI500PISCalc")// AWR - 20/05/2004 - MP164
PRIVATE lMV_ICMSPIS:= lMV_PIS_EIC .AND. EasyGParam("MV_ICMSPIS",,.F.)      // AWR - 20/05/2004 - MP164
PRIVATE MPerc_II:= MPerc_IPI:= MPerc_ICMS:= MPerc_PIS:= MPerc_COF := MPerc_COFM:=0  // AWR - 20/05/2004 - MP164: as variaveis eram static //NCF - 24/01/2013 - MPrc_ICMPC para Aliq. de ICMS de PIS/COF quando existir
PRIVATE MVlu_PIS:= MVlu_COF := MRed_PIS  := MRed_COF := 0             // AWR - 20/05/2004 - MP164

PRIVATE nDesBasIcm:=0
Private lAUTPCDI := DI500AUTPCDI()	//JWJ 12/05/2006
Private Paridade:=1 // SVG - 13/12/2010 -
//ISS - 21/01/11 - Alteração da variável MVl_Pagto de local para private, assim ela podera ser utilizada em pontos de entrada.
Private MVl_Pagto:= 0
Private cTabela:= pTab  //TDF - 15/02/12
//NCF - 24/01/2013 - Variável private no EICTP251
If Type("aICMS_Dif") == "U"
   Private aICMS_Dif := {}
EndIf
Private lRegTri_II := .F., lRegTri_IPI := .F., lRegTri_PC := .F., lReg_ICMS := .F.
PRIVATE nICMS_RED  := 1, nICMS_CTE := 0, nVal_Dif:=0, nVal_CP:=0, nVal_ICM:=0    // EOB - 26/01/10
PRIVATE lICMS_Dif  := SWZ->( FieldPos("WZ_ICMSUSP") > 0 .And. FieldPos("WZ_ICMSDIF") > 0 .And. ;  // EOB - 26/01/10
                             FieldPos("WZ_ICMS_CP") > 0 .And. FieldPos("WZ_ICMS_PD") > 0 ) .And.;
                      SWN->( FieldPos("WN_VICM_PD") > 0 .And. FieldPos("WN_VICMDIF") > 0 .And. ;
                             FieldPos("WN_VICM_CP") > 0 )
PRIVATE lICMS_Dif2 := SWN->( FieldPos("WN_PICM_PD") > 0 .And. FieldPos("WN_PICMDIF") > 0 .And. ;  // EOB - 26/01/10
                             FieldPos("WN_PICM_CP") > 0 .And. FieldPos("WN_PLIM_CP") > 0 ) .And.;
                      SWZ->( FieldPos("WZ_PCREPRE") ) > 0
//SVG - 02/06/2011 -
If Type("lTemAdicao") == "U"
   Private lTemAdicao:=EasyGParam("MV_TEM_DI",,.F.)
EndIf
If Type("lExisteSEQ_ADI") == "U"
   Private lExisteSEQ_ADI:= SW8->(FIELDPOS("W8_SEQ_ADI")) # 0 .AND. SW8->(FIELDPOS("W8_GRUPORT")) # 0
EndIf
//SVG - 02/06/2011 -
//NCF - 29/01/2013 - Majoração de COFINS no Pré-Calculo
Private lCposCofMj := SYD->(FieldPos("YD_MAJ_COF")) > 0 .And. SYT->(FieldPos("YT_MJCOF")) > 0 .And. SWN->(FieldPos("WN_VLCOFM")) > 0 .And.;                                                   //NCF - 20/07/2012 - Majoração PIS/COFINS
                      SWN->(FieldPos("WN_ALCOFM")) > 0  .And. SWZ->(FieldPos("WZ_TPCMCOF")) > 0 .And. SWZ->(FieldPos("WZ_ALCOFM")) > 0 .And.;
                      EIJ->(FieldPos("EIJ_ALCOFM")) > 0 .And. SW8->(FieldPos("W8_VLCOFM")) > 0 .And. EI2->(FieldPos("EI2_VLCOFM")) > 0

IF(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"INICIO_TPCCALCULO"),) // RA - 23/01/2004 - O.S. 0123/04

If MRateioPeso==NIL  // Jonato , em 12/08/2003
   MRateioPeso:=1
Endif

IF Origem252 # NIL  // CHAMADA PELO TPC252
	bFOB:={ |fob|EVAL(bGrava,DESPESA_FOB,fob:Dt_Pagto,fob:Vl_Pagto,PTAB,MPerc,;
            fob:Dt_Real,fob:FPerc,fob:FDias,fob:FInvoice,PDBF),MVl_Pagto+=fob:Vl_Pagto }
	MDt_Pari:= AVCTOD("31/12/49")
	// RA - 27/11/2003 - O.S. 1283/03 - Inicio
	If dDtRef != NIL
       MDt_Pari := dDtRef
	EndIf
	// RA - 27/11/2003 - O.S. 1283/03 - Final
ELSE
   bFOB:={ |fob| EVAL(bGrava,DESPESA_FOB,fob:Dt_Pagto,fob:Vl_Pagto,PTAB,MPerc),MVl_Pagto+=fob:Vl_Pagto }
   IF MParam == Pre_Calculo
//    MDt_Pari:= dDataBase  // RA - 13/08/2003
      MDt_Pari:= dDataConTx // RA - 13/08/2003
   ELSE
      MDt_Pari:= SW2->W2_PO_DT
   ENDIF
ENDIF
IF lExiste_Midia .AND. SB1->B1_MIDIA $ cSim
   nBaseMidiA := PSALDO_Q * SB1->B1_QTMIDIA * SW2->W2_VLMIDIA
ELSE
   nBaseMidia := 0
ENDIF

IF TPC:DESP = DESPESA_FOB
   AEVAL(aPagtos,bFOB)
   IF (IndFOB:=ASCAN(aDespBase,{|despesa| despesa[1] = DESPESA_FOB})) = 0
      AADD(aDespBase,{DESPESA_FOB,MVl_Pagto})
   ELSE
      aDespBase[IndFOB,2]+=MVl_Pagto
   ENDIF
   RETURN NIL
ENDIF

IF TPC:MOEDA # cMOEDAEST
   IF nParidade == NIL .OR. nParidade == 0
      IF ! SaveMoeda == TPC:MOEDA
         SaveMoeda := TPC:MOEDA
         //RMD - 21/03/18 - Utiliza buffer com as paridades para otimizar performance
         IF ALLTRIM(SaveMoeda) <> ALLTRIM(EasyGParam("MV_SIMB1",,"R$"))
            Paridade := 0
            If aBuffers <> Nil
               If !aBuffers[1]:Get(SaveMoeda+DToS(MDt_Pari), @Paridade)
                  Paridade  := BuscaTaxa(SaveMoeda,MDt_Pari,.T.,.F.,.T.) / PTX_USD
                  aBuffers[1]:Set(SaveMoeda+DToS(MDt_Pari), Paridade)
               EndIf
            Else
               Paridade  := BuscaTaxa(SaveMoeda,MDt_Pari,.T.,.F.,.T.) / PTX_USD
            EndIf
         ELSE
            Paridade  := 1 / PTX_USD
         ENDIF
      ENDIF
   ELSE
      Paridade := nParidade  // Jonato em 01/04/2004 p/ forcar a conversao por uma determinada taxa
   ENDIF
ENDIF

IF TPC:DESP # DESPESA_FRETE .AND. Origem252 # NIL
   IF TPC[11]$'3'
      TPC:VALOR := nQtdeAcumulada * TPC[8] //SWI->WI_VALOR
   ElseIF TPC[11]$'4'
      IF nPesoAcumulado <= TPC[12]     // WI_KILO1
         TPC:VALOR := TPC[13] * nPesoAcumulado  // WI_VALOR1
      ELSEIF nPesoAcumulado <= TPC[14] // WI_KILO2
         TPC:VALOR := TPC[15]  * nPesoAcumulado// WI_VALOR2
      ELSEIF nPesoAcumulado <= TPC[16] // WI_KILO3
         TPC:VALOR := TPC[17]  * nPesoAcumulado// WI_VALOR3
      ELSEIF nPesoAcumulado <= TPC[18] // WI_KILO4
         TPC:VALOR := TPC[19]  * nPesoAcumulado// WI_VALOR4
      ELSEIF nPesoAcumulado <= TPC[20] // WI_KILO5
         TPC:VALOR := TPC[21]  * nPesoAcumulado// WI_VALOR5
      ELSE //nPesoAcumulado <= aTPC[I][22] // WI_KILO6
         TPC:VALOR := TPC[23]  * nPesoAcumulado// WI_VALOR6
      ENDIF
   EndIf

   IF TPC[11]$'3' .OR. TPC[11]$'4'
      IF TPC:VALOR < TPC[10] // SWI->WI_VAL_MIN
         TPC:VALOR := TPC[10]
      ENDIF
      IF TPC:VALOR > TPC[9] .AND. TPC[9] # 0 // SWI->WI_VAL_MAX
         TPC:VALOR := TPC[9]
      ENDIF
   EndIf

    IF TPC[11] == "5"  // SWI->WI_IDVL == CONTEINER
       nVlrConte := 0
       nVlrConte += If(cAlias == "SW7",SW6->W6_CONTA20,SW2->W2_CONTA20) * TPC[24] //SWI->WI_CON20
       nVlrConte += If(cAlias == "SW7",SW6->W6_CONTA40,SW2->W2_CONTA40) * TPC[25] //SWI->WI_CON40
       nVlrConte += If(cAlias == "SW7",SW6->W6_CON40HC,SW2->W2_CON40HC) * TPC[26] //SWI->WI_CON40H
       nVlrConte += If(cAlias == "SW7",SW6->W6_OUTROS ,SW2->W2_OUTROS)  * TPC[27] //SWI->WI_CONOUT
       TPC:VALOR := nVlrConte
       IF TPC:VALOR < TPC[10] // SWI->WI_VAL_MIN
          TPC:VALOR := TPC[10]
       ENDIF
       IF TPC:VALOR > TPC[9] .AND. TPC[9] # 0 // SWI->WI_VAL_MAX
          TPC:VALOR := TPC[9]
       ENDIF
    ENDIF

   //ER - 24/04/2007
   If EasyEntryPoint("EICTP252")
      xRetPE := ExecBlock("EICTP252",.F.,.F.,{"ALTTPC",TPC})
      If ValType(xRetPE) == "A"
         TPC := aClone(xRetPE)
      EndIf
   EndIf

ENDIF

If EasyEntryPoint("EICTP252")
   xRetPE := ExecBlock("EICTP252",.F.,.F.,{"TPC",TPC})
   If ValType(xRetPE) == "A"
      TPC := aClone(xRetPE)
   EndIf
EndIf
                          //NCF - 13/12/2018 - Frete por percentual na tabela de pré-calculo
IF !EMPTY(TPC:VALOR) .OR. lFretePerc 

   MPerc := TPC:PERCAPL //TRP- 28/11/2007
   nTipoDesp:=Nil
   IF Origem252 # NIL
      nTipoDesp:=TPC[11]
//    MVl_Pagto:=TPC:VALOR * Paridade   // Quando e' valor, nao Ratear
// ELSE
//    MVl_Pagto:=TPC:VALOR * PRATEIO * Paridade
   ENDIF

   IF EasyGParam("MV_EIC0012",,.F.)    //GFP - 14/10/2013 - Considerar para cálculo de Frte o Peso Bruto do Cadastro de Produtos
      nPeso := SB1->B1_PESBRU
   ELSE
   	/*
      IF !FINDFUNCTION("B1PESO") //RA
         nPeso := If(PDBF="W7_",W5Peso(),SB1->B1_PESO) //FCD 04/07/01
      ELSE
         nPeso := IF(PDBF="W7_",W5PESO(),IF(PDBF="W5_",B1PESO(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW3","W3_FORLOJ")),B1PESO(SW3->W3_CC,SW3->W3_SI_NUM,SW3->W3_COD_I,SW3->W3_REG,SW3->W3_FABR,SW3->W3_FORN,EICRetLoja("SW3","W3_FABLOJ"),EICRetLoja("SW3","W3_FORLOJ")))) //LDR OS 1218/03    //If(PDBF="W7_",W5Peso(),SB1->B1_PESO) //FCD 04/07/01
      ENDIF
      */
      
      //AAF 03/02/2017 - Ajuste para considerar os campos de peso do pedido/li quando preenchidos.
	 If PDBF == "W7_"
	    nPeso := W5PESO()
	 ElseIf PDBF == "W5_"
	    If !Empty(SW5->W5_PESO)
		   nPeso := SW5->W5_PESO
		Else
		   nPeso := B1PESO(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ"))
		EndIf
	 Else
	    If SW3->(FieldPos("W3_PESOL")) > 0 .AND. !Empty(SW3->W3_PESOL)
		   nPeso := SW3->W3_PESOL
		Else
		   nPeso := B1PESO(SW3->W3_CC,SW3->W3_SI_NUM,SW3->W3_COD_I,SW3->W3_REG,SW3->W3_FABR,SW3->W3_FORN,EICRetLoja("SW3","W3_FABLOJ"),EICRetLoja("SW3","W3_FORLOJ"))  //  LDR - OS 1218/03    //If(PDBF="W7_",W5Peso(),SB1->B1_PESO) //FCD 04/07/01                                 
	    EndIf
     EndIf
      
      
   ENDIF
   IF PDBF=="999"
      nPeso:=1
   ENDIF
   IF(EasyEntryPoint("EICTP251"),ExecBlock("EICTP251",.F.,.F.,"DESPFRE"),)
   IF(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"DESPFRE"),) // RA - 14/08/2003 - Correcao do Acima

   IF TPC:DESP = DESPESA_FRETE

      If lFretePerc
         nBase102 := TPCBase(TPC:DESPBAS,aDespBase,nBaseMidia,bTPCPag)        // NCF - 13/12/2018 - Frete por percentual na tabela de pré-calculo
         nTotFreGeral := nBase102 * (TPC[6] / 100)
      ElseIf !(Origem252 # NIL) .AND. cAlias == "SW3" .AND. nTotFreGeral == 0 // GFP - 03/06/2014 - Frete deve ser calculado mesmo na fase de PO.
         nTotFreGeral := TPC252Frete(@aTPC,PDBF)
      EndIf
      
      IF(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"ALTERA_FRETE"),) //LRS- 03/01/2017
      
      If !lFretePerc
         IF RATEIOFRETE $ '1 '
            MVl_Pagto:= nTotFreGeral * ((PSALDO_Q * nPeso) / nPesoAcumulado) * Paridade
         ELSE
            MVl_Pagto:= nTotFreGeral * ( PSALDO_Q / nQtdeAcumulada ) * Paridade
         ENDIF
      ELSE
         MVl_Pagto:= nTotFreGeral   
      ENDIF

   ElseIF TPC:DESP == DESPESA_SEGURO  // GFP - 02/12/2016
      IF TPC[11]='3'
         MVl_Pagto := If(!EMPTY(SW2->W2_SEGURIN),SW2->W2_SEGURIN,TPC:VALOR) * (PSALDO_Q / nQtdeAcumulada) * Paridade
      ELSEIF TPC[11]='4'
         MVl_Pagto := If(!EMPTY(SW2->W2_SEGURIN),SW2->W2_SEGURIN,TPC:VALOR) * ((PSALDO_Q * nPeso) / nPesoAcumulado) * Paridade
      ELSE
         MVl_Pagto := If(!EMPTY(SW2->W2_SEGURIN),SW2->W2_SEGURIN,TPC:VALOR) * PRATEIO * Paridade
      ENDIF
   ElseIF TPC[11]='4'
   	// RA - 27/11/2003 - O.S. 1283/03 - Inicio
      If dDtRef != NIL
         MVl_Pagto:= TPC:VALOR * Paridade
      Else
         MVl_Pagto:= TPC:VALOR * ((PSALDO_Q * nPeso) / nPesoAcumulado) * Paridade
      EndIf
      // MVl_Pagto:= TPC:VALOR * ((PSALDO_Q * nPeso) / nPesoAcumulado) * Paridade
      // RA - 27/11/2003 - O.S. 1283/03 - Inicio

   ElseIF TPC[11]='3'
      MVl_Pagto:= TPC:VALOR * (PSALDO_Q / nQtdeAcumulada) * Paridade
   ELSE
      MVl_Pagto:=TPC:VALOR * PRATEIO * Paridade
   ENDIF

   EVAL(bGrava,TPC:DESP,TPC:Dt_Pagto,MVl_Pagto,PTAB,MPerc,,,,,PDBF,nTipoDesp)
   AADD(aDespBase,{TPC:DESP,MVl_Pagto})
   RETURN NIL
ENDIF

IF TPC:DESP # DESPESA_FRETE
   MPerc := TPC:PERCAPL
   nTipoDesp := TPC[11]
   IF TPC:DESP = DESPESA_II   .OR.;
      TPC:DESP = DESPESA_IPI  .OR.;
      TPC:DESP = DESPESA_ICMS .OR.;
      TPC:DESP = DESPESA_PIS  .OR.;// AWR - 20/05/2004 - MP164
      TPC:DESP = DESPESA_COFINS    // AWR - 20/05/2004 - MP164
      //RMD - 08/04/19 - Busca os dados de NCM e guarda no Buffer
      If aBuffers <> Nil
         aValBufNCM := {}
         If aBuffers[2]:get(cAlias+AllTrim(Str((cAlias)->(Recno()))), @aValBufNCM)
            SYD->(DbGoTo(aValBufNCM[4]))
         Else
            SYD->(DBSEEK(xFilial()+Busca_NCM(cAlias)))
            aBuffers[2]:Set(cAlias+AllTrim(Str((cAlias)->(Recno()))), {cAlias, (cAlias)->(Recno()), SYD->YD_TEC, SYD->(Recno())})
         EndIf
      Else
         SYD->(DBSEEK(xFilial()+Busca_NCM(cAlias)))
      EndIF
      IF(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"DEPOIS_BUSCA_NCM"),) // RA - 23/01/2004 - O.S. 0123/04
      MPerc_II  :=SYD->YD_PER_II
      MPerc_IPI :=SYD->YD_PER_IPI
      MPerc_ICMS:=SYD->YD_ICMS_RE
      IF lMV_PIS_EIC// AWR - 20/05/2004 - MP164
         MVlu_PIS :=SYD->YD_VLU_PIS
         MVlu_COF :=SYD->YD_VLU_COF
         MPerc_PIS:=SYD->YD_PER_PIS
         MPerc_COF:=SYD->YD_PER_COF
         MRed_PIS :=SYD->YD_RED_PIS
         MRed_COF :=SYD->YD_RED_COF
      // SVG - 28/07/2011 - Aliq de ICMS para calculo de PIS e COFINS
      // NCF - 24/01/2013 - Adicionada as considerações para carregamento das alíquotas de ICMS e ICMS sobre PIS/COFINS
         If SYD->(FIELDPOS("YD_ICMS_PC")) # 0
            IF SYD->YD_ICMS_PC > 0
               MPercICMPC := SYD->YD_ICMS_PC
            ELSE
               MPercICMPC := MPerc_ICMS
            ENDIF
         Else
            MPercICMPC := MPerc_ICMS
         EndIf
         If lCposCofMj                                                            //NCF - 30/01/2013 - Majoração PIS/COFINS
            cChave_Ncm := SYD->YD_TEC + SYD->YD_EX_NCM + SYD->YD_EX_NBM
            //RMD - 21/03/19 - Busca os dados da Majoração da NCM e guarda no Buffer
            If aBuffers <> Nil
               If !aBuffers[3]:Get(cChave_Ncm+SW2->W2_IMPORT, @MPerc_COFM)
                  MPerc_COFM:= EicGetPerMaj(cChave_Ncm, "" ,SW2->W2_IMPORT, "COFINS")
                  aBuffers[3]:Set(cChave_Ncm+SW2->W2_IMPORT, MPerc_COFM)
               EndIf
            Else
               MPerc_COFM:= EicGetPerMaj(cChave_Ncm, "" ,SW2->W2_IMPORT, "COFINS")
            EndIf
            MPerc_COF += MPerc_COFM
         EndIf
      ENDIF

      lRT_EIJ := .F.
      If lAvFluxo .And. !lTemAdicao .And. !lFasePO
         cGrupoRT := IF(lExisteSEQ_ADI, SW8->W8_GRUPORT, SW8->W8_ADICAO)
      EndIf
     
      IF !EMPTY(SW3->W3_GRUPORT) .And. Empty(cGrupoRT)
         EIJ->(dbSetOrder(2))
         IF EIJ->(dbSeek(xFilial("EIJ")+SW3->W3_PO_NUM+SW3->W3_GRUPORT))
            lRT_EIJ := .T.
            cChave_Ncm := SW3->W3_TEC + SW3->W3_EX_NCM + SW3->W3_EX_NBM
         ENDIF      
      ELSEIF !Empty(cGrupoRT) .And. !lFasePO     
         EIJ->(dbSetOrder(1))
         IF EIJ->(dbSeek(xFilial("EIJ")+SW8->W8_HAWB+cGrupoRT))
            lRT_EIJ := .T.
            cChave_Ncm := SW8->W8_TEC + SW8->W8_EX_NCM + SW8->W8_EX_NBM
         ENDIF         
      ENDIF
      IF lRT_EIJ
         IF !EMPTY(EIJ->EIJ_REGTRI)
            lRegTri_II  := .T.
            IF EIJ->EIJ_TPAII == '1'
               MPerc_II := EIJ->EIJ_ALI_II
               IF !EMPTY(EIJ->EIJ_TACOII)
                  MPerc_II := EIJ->EIJ_ALA_II
               ENDIF
               IF !EMPTY(EIJ->EIJ_ALR_II)
                  MPerc_II := EIJ->EIJ_ALR_II
               ENDIF
            ENDIF
         ENDIF
         IF !EMPTY(EIJ->EIJ_REGIPI)
            lRegTri_IPI := .T.
            IF EIJ->EIJ_TPAIPI == "1"
               MPerc_IPI := EIJ->EIJ_ALAIPI
               IF !EMPTY(EIJ->EIJ_ALRIPI)
                  MPerc_IPI := EIJ->EIJ_ALRIPI
               ENDIF
            ENDIF
         ENDIF
         IF !EMPTY(EIJ->EIJ_REG_PC)
            lRegTri_PC  := .T.
            IF EIJ->EIJ_TPAPIS == '1' .OR. EIJ->EIJ_TPACOF == '1'
               MPerc_PIS:=EIJ->EIJ_ALAPIS
               MPerc_COF:=EIJ->EIJ_ALACOF

               If lCposCofMj                                                                         //NCF - 30/01/2013 - Majoração PIS/COFINS
                  MPerc_COFM:= EicGetPerMaj( cChave_Ncm , EIJ->EIJ_OPERAC ,SYT->YT_COD_IMP, "COFINS")
                  MPerc_COF += MPerc_COFM
               EndIf

               MRed_PIS :=EIJ->EIJ_REDPIS
               MRed_COF :=EIJ->EIJ_REDCOF
               MVlu_PIS :=0
               MVlu_COF :=0
            ELSE                                                                                     //NCF - 07/02/2013 - PIS/COFINS de Pauta
               MVlu_PIS := EIJ->EIJ_ALUPIS
               MVlu_COF := EIJ->EIJ_ALUCOF
            ENDIF
         ENDIF
         IF !EMPTY(EIJ->EIJ_OPERAC)
            lReg_ICMS   := .T.

            SWZ->(dbSetOrder(2))
            SWZ->(dbSeek(xFilial("SWZ")+EIJ->EIJ_OPERAC))
            IF !SWZ->(EOF())
               MPERC_ICMS := SWZ->WZ_AL_ICMS
               // NCF - 24/01/2013 - Adicionada as considerações para carregamento das alíquotas de ICMS e ICMS sobre PIS/COFINS
               If SWZ->WZ_ICMS_PC > 0
                  MPercICMPC := SWZ->WZ_ICMS_PC
               Else
                  MPercICMPC := MPERC_ICMS
               EndIf

               nICMS_RED  := IF(SWZ->WZ_RED_ICM#0,(100-SWZ->WZ_RED_ICM)/100,1)
               nICMS_CTE  := SWZ->WZ_RED_CTE

               IF lICMS_Dif .AND. ASCAN( aICMS_Dif, {|x| x[1] == EIJ->EIJ_OPERAC} ) == 0
                  //                Operação         Suspensao        % diferimento        % Credito presumido              % Limite Cred.  % pg desembaraco  Aliq. ICMS CFO   Aliq. ICMS S/ PIS/COF
                  AADD( aICMS_Dif, {EIJ->EIJ_OPERAC, SWZ->WZ_ICMSUSP, SWZ->WZ_ICMSDIF, IF( lICMS_Dif2, SWZ->WZ_PCREPRE, 0), SWZ->WZ_ICMS_CP, SWZ->WZ_ICMS_PD, SWZ->WZ_AL_ICMS, SWZ->WZ_ICMS_PC       } )
               ENDIF
            ENDIF
         ENDIF
      ENDIF

      IF(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"ALIQUOTA"),) // LDR - 07/06/2004
      IF(TPC:DESP = DESPESA_II    ,MPerc := MPerc_II  ,)
      IF(TPC:DESP = DESPESA_IPI   ,MPerc := MPerc_IPI ,)
      IF(TPC:DESP = DESPESA_ICMS  ,MPerc := MPerc_ICMS,)
      IF(TPC:DESP = DESPESA_PIS   ,MPerc := MPerc_PIS ,)// AWR - 20/05/2004 - MP164
      IF(TPC:DESP = DESPESA_COFINS,MPerc := MPerc_COF ,)// AWR - 20/05/2004 - MP164
   EndIf
   IF TPC:DESP = DESPESA_II .OR. TPC:DESP = DESPESA_IPI
      aOrdSWI:= SaveOrd({"SWI"})  //DFS - 02/12/11 - Para guardar a posição e o registro em qual se encontra antes do while
      If !SWI->(DBSEEK(xFilial("SWI")+SW6->W6_VIA_TRA+pTab)) // RRV - 13/08/2012 - Procura a tabela de pré-calculo com via de transporte referente ao processo corretamente.
         SWI->(dbSetOrder(1))   //DFS - 02/12/11 - Inclusão da ordem do indice
         SWI->(dbSeek(xFilial("SWI")+pTab))
      EndIf

      If TPC:DESP = DESPESA_II
        nDspBasImp:=0
        If EasyGParam("MV_EIC0068",,0) > 0 
            LoadDspBImp( pTab , PSALDO_Q , nQtdeAcumulada, cImportador, 1 ,bTPCPag)  // NCF - 15/01/2017 - Carrega a variável nDspBasImp com as Desp.Base.Imposto e o array aDespBase com as Desp.Base.ICMS
        EndIf
      EndIf

      RestOrd(aOrdSWI,.T.) //DFS - 02/12/11 - Para restaurar a ordem alteriormente guardada.

      // EOB - 22/01/10 - Calculo da despesa II considerando os dados de regime de tributação
      IF TPC:DESP == DESPESA_II .AND. lRegTri_II
         IF EIJ->EIJ_REGTRI $ '2,3,5,6' .OR. (EIJ->EIJ_REGTRI == '4' .AND. EIJ->EIJ_PR_II == 100)
            MVl_Pagto := 0
         ELSEIF EIJ->EIJ_TPAII == '1' .Or. EIJ->(FIELDPOS("EIJ_ALU_II")) == 0
            MVl_Pagto := (TPCBase(TPC:DESPBAS,aDespBase,nBaseMidia,bTPCPag)+nDspBasImp)
            MVl_Pagto := MVl_Pagto * MPerc / 100
            IF EIJ->EIJ_REGTRI == '4' .AND. !EMPTY(EIJ->EIJ_PR_II)
               MVl_Pagto:= MVl_Pagto * ((100-EIJ->EIJ_PR_II)/100)
            ENDIF
         ELSE
            IF EIJ->(FIELDPOS("EIJ_CALCII")) == 0 .OR. EIJ->EIJ_CALCII == '1'
               MVl_Pagto := EIJ->EIJ_ALU_II * SW3->W3_PESOL
            ELSE
               MVl_Pagto := EIJ->EIJ_ALU_II * EIJ->EIJ_QTU_II
            ENDIF
            lConverte := .T.
         ENDIF

      // EOB - 22/01/10 - Calculo da despesa IPI considerando os dados de regime de tributação
      ELSEIF TPC:DESP == DESPESA_IPI .AND. lRegTri_IPI
         IF EIJ->EIJ_REGIPI $ '1,3,5'
            MVl_Pagto := 0
         ELSEIF EIJ->EIJ_TPAIPI == "1"
            MVl_Pagto := (TPCBase(TPC:DESPBAS,aDespBase,nBaseMidia,bTPCPag)+nDspBasImp)
            MVl_Pagto := MVl_Pagto * MPerc / 100
         ELSE
            IF EIJ->(FIELDPOS("EIJ_CALIPI")) == 0 .OR. EIJ->EIJ_CALIPI == '1'
               MVl_Pagto := EIJ->EIJ_ALUIPI * EIJ->EIJ_QTUIPI
            ELSE
               MVl_Pagto := EIJ->EIJ_ALUIPI * SW3->W3_PESOL
            ENDIF
            lConverte := .T.
         ENDIF

      ELSEIF TPC:DESP == DESPESA_IPI .AND. IPIPauta()
         Mvl_Pagto := PSALDO_Q * IPIPauta(IF(PDBF#"W7_",.F.,.T.)) /PTx_USD

      ELSEIF TPC:DESP == DESPESA_IPI .AND. lExiste_Midia .AND. SB1->B1_MIDIA $ cSim
         MVl_Pagto := TPCTotMidia(TPC:DESP,aDespBase,PSALDO_Q) * MPerc /100

      ELSE
         MVl_Pagto := (TPCBase(TPC:DESPBAS,aDespBase,nBaseMidia,bTPCPag)+nDspBasImp)// AWR - Desp Base
         MVl_Pagto := MVl_Pagto * MPerc / 100
      ENDIF

   ELSEIF TPC:DESP = "203"
       aOrdSWI:= SaveOrd({"SWI"})  //DFS - 02/12/11 - Para guardar a posição e o registro em qual se encontra antes do while
       If !SWI->(DBSEEK(xFilial("SWI")+SW6->W6_VIA_TRA+pTab)) // RRV - 13/08/2012 - Procura a tabela de pré-calculo com via de transporte referente ao processo corretamente.
          SWI->(dbSetOrder(1))   //DFS - 02/12/11 - Inclusão da ordem do indice
          SWI->(dbSeek(xFilial("SWI")+pTab))
       EndIf
       nDesBasIcm:=0
       If EasyGParam("MV_EIC0068",,0) > 0 
            LoadDspBImp( pTab , PSALDO_Q , nQtdeAcumulada, cImportador, 2 ,bTPCPag) // NCF - 15/01/2017 - Carrega a variável nDspBasImp com as Desp.Base.Imposto e o array aDespBase com as Desp.Base.ICMS
       EndIf
        RestOrd(aOrdSWI,.T.) //DFS - 02/12/11 - Para restaurar a ordem alteriormente guardada.
         IF lMV_ICMSPIS// AWR - 20/05/2004 - MP164
            MVl_Pagto:=TPCalcImp(TPC:DESP,aDESPBASE,PSALDO_Q,cImportador,nDesBasIcm,PTX_USD)
         ELSE
            IF GetNewPar("MV_ICMS_IN",.F.)
               nBaseICMIN:=((TPCBase(TPC:DESPBAS,aDespBase,nBaseMidia,bTPCPag)+nDesBasIcm)/((100-MPerc)/100))       //NCF - 15/01/2018 - Desp.Base.Imp entram na base do ICMS
               MVl_Pagto := nBaseICMIN * MPerc / 100
            ELSE
               MVl_Pagto := TPCBase(TPC:DESPBAS,aDespBase,nBaseMidia,bTPCPag)+nDesBasIcm
               MVl_Pagto := MVl_Pagto * MPerc / 100
            ENDIF
         ENDIF
      //ENDIF
      //SVG - 14/08/2009 - Calculo de ICMS de Pauta -
      If SYD->( FieldPos("YD_VLU_ICM") ) > 0 .And. !Empty(SYD->YD_VLU_ICM) .And. EasyGParam("MV_CALCICM",,"0") == "1"
         MVl_Pagto := (B1PESO() * SYD->YD_VLU_ICM * PSALDO_Q)
      EndIf
   ELSEIF TPC:DESP = DESPESA_PIS .OR. TPC:DESP = DESPESA_COFINS// AWR - 20/05/2004 - MP164
      // EOB - 26/01/10 - Calculo das despesas de PIS/COFINS considerando os dados de regime de tributação
      IF lRegTri_PC
         IF EIJ->EIJ_REG_PC $ '2,3,5,6' .OR. EIJ->EIJ_PRB_PC == 100
            MVl_Pagto := 0
         ELSEIF (EIJ->EIJ_TPAPIS == '1' .And. TPC:DESP = DESPESA_PIS) .OR. (EIJ->EIJ_TPACOF == '1' .And.  TPC:DESP = DESPESA_COFINS)
            MVl_Pagto:=TPCalcImp(TPC:DESP,aDESPBASE,PSALDO_Q,cImportador,nDspBasImp,PTX_USD) // AWR - 20/05/2004 - MP164

         ELSEIF TPC:DESP = DESPESA_PIS
            MVl_Pagto := EIJ->EIJ_ALUPIS * EIJ->EIJ_QTUPIS
            lConverte := .T.
         ELSEIF TPC:DESP = DESPESA_COFINS
            MVl_Pagto := EIJ->EIJ_ALUCOF * EIJ->EIJ_QTUCOF
            lConverte := .T.
         ENDIF

      ELSE
         MVl_Pagto:=TPCalcImp(TPC:DESP,aDESPBASE,PSALDO_Q,cImportador,nDspBasImp,PTX_USD) // AWR - 20/05/2004 - MP164
      ENDIF

   ELSEIF TPC[11]='2'

/*      If EasyGParam("MV_EIC0068",,0) > 0
         If !(Left(TPC[3],1) $ "129T") .And. IsDspBasIm("II",TPC[3],"PROC",SW2->W2_IMPORT)                                   //NCF - 10/01/2018 - Só fazer os cálculos no caso do parâmetro ativo se não houver ref. circular 
            aVal_II   := EA110RefCirc("II",TPC[3],TPC[3],TPC[7],"SWI",SWI->WI_VIA,SWI->WI_TAB,.T.,.F.,"PROC",SW2->W2_IMPORT) //                   na relação de desp.base da própria despesa ou na cadeia de desp. bases destas despesas
            If !aVal_II[1]
               MVl_Pagto := TPCBase(TPC:DESPBAS,aDespBase,nBaseMidia) * MPerc / 100  
            Else
               MVl_Pagto := 0
            EndIF
         ElseIf !(Left(TPC[3],1) $ "129T") .And. IsDspBasIm("ICMS",TPC[3],"PROC",SW2->W2_IMPORT)  
            aVal_ICMS := EA110RefCirc("ICMS",TPC[3],TPC[3],TPC[7],"SWI",SWI->WI_VIA,SWI->WI_TAB,.T.,.F.,"PROC",SW2->W2_IMPORT)
            If !aVal_ICMS[1]
               MVl_Pagto := TPCBase(TPC:DESPBAS,aDespBase,nBaseMidia) * MPerc / 100
            Else
              MVl_Pagto := 0
            EndIF
         Else
            MVl_Pagto := TPCBase(TPC:DESPBAS,aDespBase,nBaseMidia) * MPerc / 100          
         EndIf
      Else     */
         AADD(aDespBase,{TPC:DESP,0})
         MVl_Pagto := TPCBase(TPC:DESPBAS,aDespBase,nBaseMidia,bTPCPag,nDspBasImp) * MPerc / 100 
/*      EndIf  */

      If Origem252 # NIL
         IF MVl_Pagto < TPC[10]                        // SWI->WI_VAL_MIN
            MVl_Pagto := TPC[10] * Paridade * PRATEIO
         ElseIF MVl_Pagto > TPC[9] .AND. TPC[9] # 0    // SWI->WI_VAL_MAX
            MVl_Pagto := TPC[9] * Paridade * PRATEIO
         ENDIF
      ENDIF

   EndIf
ENDIF

/*ISS - 21/11/01 - Ponto de entrada para alterar as despesas calculadas, os parâmetros informarão à despesa que esta sendo
                   calculada, a alteração da mesma será feita através da variável MVl_Pagto  */
If EasyEntryPoint("EICTP252")
   ExecBlock("EICTP252",.F.,.F.,{"TPCCALCULO_CALCDESP",TPC:DESP})
EndIf
//Deve se ter cuidado ao alterar os parâmetros desta execução, pois o bGrava pode assumir valores diferentes vindos do eictp251 e eictp252
EVAL(bGrava,TPC:DESP,TPC:Dt_Pagto,MVl_Pagto,PTAB,MPerc,IIF(cChamada=="TPC251",lConverte,),,,,PDBF,nTipoDesp)
If (nPosDesBas := aScan(aDespBase, {|x| x[1] == TPC:DESP})) > 0 //THTS - 18/01/2018
    aDespBase[nPosDesBas][2] := MVl_Pagto
Else
    AADD(aDespBase,{TPC:DESP,MVl_Pagto})
EndIf
RETURN NIL

*----------------------------------------------------------------------------
FUNCTION TPCBase(PDespBase,aDespBase,nBaseMidia,bTPCPag,nVlrDesImp)
*----------------------------------------------------------------------------
LOCAL Ind1:=ASCAN(aDespBase,{|desp| desp[1] = LEFT(PDespBase,3) })
LOCAL Ind2:=ASCAN(aDespBase,{|desp| desp[1] = SUBSTR(PDespBase,4,3) })
LOCAL Ind3:=ASCAN(aDespBase,{|desp| desp[1] = RIGHT(PDespBase,3) })
LOCAL MValor:=0
LOCAL IndFob := ASCAN(aDespBase,{|desp| desp [1] = DESPESA_FOB })
LOCAL IndCif := ASCAN(aDespBase,{|desp| desp [1] = VALOR_CIF }) //Quando o CIF é carregado via Rdmake.
LOCAL nPosDspII := 0
Local nPosTPC
//LOCAL nVarFob := IF(IndFob # 0,IF(lExiste_Midia .AND. SB1->B1_MIDIA $ cSim ,nBaseMidia, aDespBase[IndFob,2]),0 )       //NCF - 29/09/2010 - Impostos da Mídia deve ser calculado de acordo
LOCAL nVarFob := IF(IndFob # 0,aDespBase[IndFob,2],0 )                                                                   //                   com o cálculo da Nota - Chamado 083525
Default nVlrDesImp := 0 //THTS - 31/01/2018 - valor das despesas base de Imposto a ser considerada no CIF quando o MV_EIC0068 for igual a 2

IF AT(VALOR_CIF,PDespBase) # 0  .and. IndCif = 0
   If nVlrDesImp > 0 .And. EasyGParam("MV_EIC0068",,0) != 2 //THTS - 23/01/2018 - 2=considera desp.base imp. p/ CIF/Imp. Pré-Calculo
        nVlrDesImp := 0
   EndIf
   MValor:= TPCBase(DESPESA_FOB+DESPESA_FRETE+DESPESA_SEGURO,aDespBase,nBaseMidia) + nVlrDesImp
   /*If EasyGParam("MV_EIC0068",,0) > 0 .And. (nPosDspII := aScan(aTPC,{|x| x[3] == VALOR_CIF}) ) > 0 //NCF - 28/12/2017 - Desp.Base.Imp. na base de calculo
      MValor += GetEDspBas(aTPC,"II",nPosDspII,,'TPCBase' ) 
   EndIf*/
ENDIF

If Ind1 == 0 .And. !Empty(LEFT(PDespBase,3)) .And. !( AT(VALOR_CIF,PDespBase) # 0  .and. IndCif = 0)    
    If (nPosTPC := aScan(aTPC,{|x| x[3] == LEFT(PDespBase,3)})) > 0
      EVAL(bTPCPag,aTPC[nPosTPC])
      Ind1:=ASCAN(aDespBase,{|desp| desp[1] = LEFT(PDespBase,3) })
   EndIf
EndIf
If Ind2 == 0 .And. !Empty(SUBSTR(PDespBase,4,3)) .And.!( AT(VALOR_CIF,PDespBase) # 0  .and. IndCif = 0)
   If (nPosTPC := aScan(aTPC,{|x| x[3] == SUBSTR(PDespBase,4,3)})) > 0
    EVAL(bTPCPag,aTPC[nPosTPC])
    Ind2:=ASCAN(aDespBase,{|desp| desp[1] = SUBSTR(PDespBase,4,3) })
   EndIf
EndIf
If Ind3 == 0 .And. !Empty(RIGHT(PDespBase,3)) .And. !( AT(VALOR_CIF,PDespBase) # 0  .and. IndCif = 0)
   If (nPosTPC := aScan(aTPC,{|x| x[3] == RIGHT(PDespBase,3)})) > 0
     EVAL(bTPCPag,aTPC[nPosTPC])
    Ind3:=ASCAN(aDespBase,{|desp| desp[1] = RIGHT(PDespBase,3) })
   EndIf
EndIf

MValor+=(IF(Ind1 # 0,IF (Ind1= IndFob, nVarFob,aDespBase[Ind1,2]),0) +;
         IF(Ind2 # 0,IF (Ind2= IndFob, nVarFob,aDespBase[Ind2,2]),0) +;
         IF(Ind3 # 0,IF (Ind3= IndFob, nVarFob,aDespBase[Ind3,2]),0))
RETURN MValor

*----------------------------------------------------------------------------*
FUNCTION TPCCarga(aTPC,PMsg, aBuffers)
// ATENCAO: FUNCAO UTILIZADA NO TPC251 E TPC252
*----------------------------------------------------------------------------*
LOCAL SaveTab:=SWI->WI_TAB, _recno:=SWI->(RECNO()),;
      SaveMsg,;
      MMsg:=STR0103+SWI->WI_TAB+STR0104,; //"Carregando a Tabela de Pre-Calculo No. "###" - Aguarde..."
      MPosSWF:=.F.
LOCAL bTPC_Cond:={|| SaveTab = SWI->WI_TAB .AND. SWI->WI_FILIAL=xFilial("SWI")}
LOCAL bTPC1For :={|| LEFT(SWI->WI_DESP,1) # "2" } // AWR - Desp Base
LOCAL bTPC2For :={|| LEFT(SWI->WI_DESP,1) = "2" } // AWR - Desp Base
Local nCont, aBaseImposto:= {}, nTamTPC
Private aTPCAux := {}
PRIVATE bTPC:={|| AADD(aTPC,{AVCTOD('')     ,;//1
                           SWI->WI_QTDDIAS,;//2
                           SWI->WI_DESP   ,;//3
		           SWI->WI_MOEDA  ,;//4
		           SWI->WI_VALOR  ,;//5
		           SWI->WI_PERCAPL,;//6
		           SWI->WI_DESPBAS,;//7
 		           IF(SWI->WI_IDVL="3",SWI->WI_VALOR,0),;//8
 		           SWI->WI_VAL_MAX,;//9
                           SWI->WI_VAL_MIN,;//10
                           SWI->WI_IDVL   ,;//11
		           IF( SWI->WI_IDVL="4",SWI->WI_KILO1,0) ,;
		           IF( SWI->WI_IDVL="4",SWI->WI_VALOR1,0) ,;
			   IF( SWI->WI_IDVL="4",SWI->WI_KILO2,0)  ,;
			   IF( SWI->WI_IDVL="4",SWI->WI_VALOR2,0) ,;
			   IF( SWI->WI_IDVL="4",SWI->WI_KILO3,0)  ,;
			   IF( SWI->WI_IDVL="4",SWI->WI_VALOR3,0),;
			   IF( SWI->WI_IDVL="4",SWI->WI_KILO4,0),;
			   IF( SWI->WI_IDVL="4",SWI->WI_VALOR4,0),;
			   IF( SWI->WI_IDVL="4",SWI->WI_KILO5,0),;
			   IF( SWI->WI_IDVL="4",SWI->WI_VALOR5,0),;
			   IF( SWI->WI_IDVL="4",SWI->WI_KILO6,0),;
			   IF( SWI->WI_IDVL="4",SWI->WI_VALOR6,0) } ) }

ASIZE(aTPC,0)
//ER - 24/04/2007
If EasyEntryPoint("EICTP252")
   ExecBlock("EICTP252",.F.,.F.,"TPCCARGA_INICIO")
EndIf

IF !SWI->(EOF())
   IF !MPosSWF
      SWF->(DbSetOrder(2))  // GFP - 02/12/2013
      SWF->(DBSEEK(XFILIAL("SWF")+SWI->WI_VIA+SWI->WI_TAB))
      MPosSWF:=.T.
   ENDIF

   cOldArea := Alias()
   dbSelectArea("SWI")

   //wfs - out/2019: ajustes de performance
   If aBuffers <> Nil
      
      cFilSWI := xFilial("SWI")
      If !aBuffers[4]:Get(cFilSWI+SaveTab+SWF->WF_VIA, @aTPC)
         aTPC:= LoadATPC(SaveTab)
         aBuffers[4]:Set(cFilSWI+SaveTab+SWF->WF_VIA, aTPC)
      EndIf
   Else
      aTPC:= LoadATPC(SaveTab)
   EndIf

   // DFS - Criação de ponto de entrada para reordenar o array no
   aTPCAux := aClone(aTPC)
   If EasyEntryPoint("EICTP252")
      ExecBlock("EICTP252",.F.,.F.,"REORDENA_ARRAY")
   EndIf
   aTPC := aClone(aTPCAux)

   If Select(cOldArea) > 0
      dbSelectArea(cOldArea)
   EndIf

   SWI->(DBGOTO(_recno))
   //**

ENDIF
RETURN aTPC

/*
Funcao      : LoadATPC()
Parâmetros  : SaveTab: tabela de pré-cálculo
Retorno     :
Objetivos   : Retornar os registros cadastrados na tabela de pré-cálculo 
Autor       : WFS
Data 	      : 04/10/2019
Obs         : Trecho de código segregado da função TPCCarga(), para viabilizar tratamento de performance
Revisão     :
*/
Static Function LoadATPC(SaveTab)
Local cFilSWI := xFilial("SWI")
Local aTPC:= {}

   Do While !EoF() .AND. SaveTab == WI_TAB .AND. WI_FILIAL == cFilSWI
      If SWI->WI_VIA == SWF->WF_VIA //AAF 03/10/2013 - Considerar apenas as despesas da tabela referente a mesma via de transporte

         aAdd(aTPC,{AVCTOD('')     ,;//1
               SWI->WI_QTDDIAS,;//2
               SWI->WI_DESP   ,;//3
               SWI->WI_MOEDA  ,;//4
               SWI->WI_VALOR  ,;//5
               SWI->WI_PERCAPL,;//6
               SWI->WI_DESPBAS,;//7
               IF(SWI->WI_IDVL="3",SWI->WI_VALOR,0),;//8
               SWI->WI_VAL_MAX,;//9
               SWI->WI_VAL_MIN,;//10
               SWI->WI_IDVL   ,;//11
               IF( SWI->WI_IDVL="4",SWI->WI_KILO1,0) ,;
               IF( SWI->WI_IDVL="4",SWI->WI_VALOR1,0),;
               IF( SWI->WI_IDVL="4",SWI->WI_KILO2,0) ,;
               IF( SWI->WI_IDVL="4",SWI->WI_VALOR2,0),;
               IF( SWI->WI_IDVL="4",SWI->WI_KILO3,0) ,;
               IF( SWI->WI_IDVL="4",SWI->WI_VALOR3,0),;
               IF( SWI->WI_IDVL="4",SWI->WI_KILO4,0) ,;
               IF( SWI->WI_IDVL="4",SWI->WI_VALOR4,0),;
               IF( SWI->WI_IDVL="4",SWI->WI_KILO5,0) ,;
               IF( SWI->WI_IDVL="4",SWI->WI_VALOR5,0),;
               IF( SWI->WI_IDVL="4",SWI->WI_KILO6,0) ,;
               IF( SWI->WI_IDVL="4",SWI->WI_VALOR6,0) ,;
               IF( SWI->WI_IDVL="5",SWI->WI_CON20,0),;
               IF( SWI->WI_IDVL="5",SWI->WI_CON40,0),;
               IF( SWI->WI_IDVL="5",SWI->WI_CON40H,0),;
               IF( SWI->WI_IDVL="5",SWI->WI_CONOUT,0)})
      EndIf

      dbSkip()
   EndDo
   aSort(aTPC,,,{|X,Y| IIF((Left(SubStr(x[7], 1, 3), 1) == "2" .Or.;
                           Left(SubStr(x[7], 4, 3), 1) == "2" .Or.;
                           Left(SubStr(x[7], 7, 3), 1) == "2") .And.;
                           Left(x[3], 1) <> "2","Z","A")+X[3] < IIF((Left(SubStr(y[7], 1, 3), 1) == "2" .Or.;
                                                                     Left(SubStr(y[7], 4, 3), 1) == "2" .Or.;
                                                                     Left(SubStr(y[7], 7, 3), 1) == "2") .And.;
                           Left(y[3], 1) <> "2","Z","A")+Y[3] })

Return aTPC
*----------------------------------------------------------------------------
FUNCTION TPCalcImp(cDespesa,aDESPBASE,nQuantidade,cImportador,nDesBasIcm,nTaxa)// AWR - 20/05/2004 - MP164
*----------------------------------------------------------------------------
LOCAL nX, nIPIPauta:=0
LOCAL lIpi_Pauta := .F., nDspBICMPerc
PRIVATE nBASE_II := 0
PRIVATE nIPIVAL  := 0
PRIVATE nIIVAL   := 0
PRIVATE nVl_Pagto:= 0
PRIVATE nNewBaseICMS:=0
PRIVATE lNewBaseICMS:=.F.
PRIVATE nDespBaseICM:=0    // EOS - 07/06/04
Private cDespPVT := cDespesa
Default nDesBasIcm := 0
Default nTaxa := 1

If Type("lRegTriPO") == "U"
   lRegTriPO:= .F.
EndIf

lTemYB_ICM_UF:=.F.
IF cImportador # NIL
   SYT->(DBSETORDER(1))
   SYT->(dBSeek(xFilial("SYT")+cImportador))
   cCpoBasICMS:="YB_ICMS_"+Alltrim(SYT->YT_ESTADO)   //JWJ - 17/10/05
   //SYB->(DBSEEk(XFILIAL("SYB")+cDespesa ))
   lTemYB_ICM_UF:=SYB->(FIELDPOS(cCpoBasICMS)) # 0//AWR - Esse teste de campo nao pode ser removido porque o campo YT_ESTADO nao é obrigatorio
ENDIF

//TDF - 15/02/12 - Calculo das despesas base de imposto para entrar na base do II

nDespBaseICM := 0
IF lMV_PIS_EIC

   FOR nX:=1 TO LEN(aDESPBASE)
       DO CASE
          CASE aDESPBASE[nX][1]=="101"           // FOB
               nBASE_II :=nBASE_II + aDESPBASE[nX][2]

          CASE aDESPBASE[nX][1]=="102"           // FRETE
               nBASE_II :=nBASE_II + aDESPBASE[nX][2]

          CASE aDESPBASE[nX][1]=="103"           // SEGURO
               nBASE_II :=nBASE_II + aDESPBASE[nX][2]

          CASE aDESPBASE[nX][1]=="201"           // II
               nIIVAL   :=aDESPBASE[nX][2]

          CASE aDESPBASE[nX][1]=="202"           // IPI
               nIPIVAL  :=aDESPBASE[nX][2]
                             //NCF - 26/02/2013 - Verificar IPI de Pauta no Regime de Tributação do PO
               IF IPIPauta() .Or. ( lRegTriPO .And. !(EIJ->EIJ_REGIPI $ '1,3,5') .And. EIJ->EIJ_TPAIPI == "2" )
                  nIPIPauta := nIPIVAL
                  lIpi_Pauta := .T.
               ENDIF

          CASE !(LEFT(aDESPBASE[nX][1],1) $ "1,2,9") // Despesas Base de ICMS               EOS - 07/06/04
              IF SYB->(DBSEEk(XFILIAL("SYB")+aDESPBASE[nX][1] ))
                 /*IF SYB->YB_BASEIMP $ cSim
                    nBASE_II += aDESPBASE[nX][2] // AWR - Desp Base
                 ENDIF*/
                 lBaseICM:=SYB->YB_BASEICM $ cSim
                 IF lTemYB_ICM_UF
                    lBaseICM:=lBaseICM .AND. SYB->(FIELDGET(FIELDPOS(cCpoBasICMS))) $ cSim
                 ENDIF
                 IF lBaseICM
                    nDespBaseICM += aDESPBASE[nX][2]
                 ENDIF
              ENDIF
       ENDCASE
   NEXT

   nNewBaseICMS:=0

   IF !EMPTY(MVlu_PIS)
      nVLRPIS := (MVlu_PIS*nQuantidade) / nTaxa
   ELSE
     // TDF - 15/02/12 - O quinto parametro da função DI500PISCalc deve ser sempre o valor do ICMS, pois ele é utilizado no cálvulo do ICMS'.
     //                  O nono parametro da função DI500PISCalc deve ser informado somente quando possuir o campo YD_ICMS_PC (ICMS de PIS e COFINS)
     //SVG - 28/07/2011 - Aliq de ICMS para calculo de PIS e COFINS
     /* If SYD->(FIELDPOS("YD_ICMS_PC")) # 0
         nVLRPIS:= DI500PISCalc(nBASE_II,nDespBaseICM,(MPERC_II/100),(MPERC_IPI/100),(MPercICMPC/100),(MPERC_PIS/100),(MPERC_COF/100),(MRed_PIS/100),0, nIPIPauta ) * (MPERC_PIS/100)
      Else*/                                                                                                                                         //NCF - 24/01/2013 - A tratativa da Aliq. de ICMS para PIS/COFINS será feita no carregamento da variável MPercICMPC
         nVLRPIS:= DI500PISCalc(nBASE_II+nDspBasImp,nDespBaseICM,(MPERC_II/100),(MPERC_IPI/100),(MPERC_ICMS/100),(MPERC_PIS/100),(MPERC_COF/100),(MRed_PIS/100),(MPercICMPC/100), nIPIPauta,,,lIpi_Pauta ) * (MPERC_PIS/100)
      //EndIf
   ENDIF

   IF !EMPTY(MVlu_COF)
      nVLRCOF     := (MVlu_COF*nQuantidade) / nTaxa
      //lNewBaseICMS:= .T.
      //nNewBaseICMS:= (nBASE_II+nIIVAL+nIPIVAL+nVLRPIS+nVLRCOF)/( ( 100 - MPERC_ICMS )/ 100 )
   ELSE

     // TDF - 15/02/12 - O quinto parametro da função DI500PISCalc deve ser sempre o valor do ICMS, pois ele é utilizado no cálvulo do ICMS'.
     //                  O nono parametro da função DI500PISCalc deve ser informado somente quando possuir o campo YD_ICMS_PC (ICMS de PIS e COFINS)
     //SVG - 28/07/2011 - Aliq de ICMS para calculo de PIS e COFINS
     /* If SYD->(FIELDPOS("YD_ICMS_PC")) # 0
         nVLRCOF:= DI500PISCalc(nBASE_II,nDespBaseICM,(MPERC_II/100),(MPERC_IPI/100),(MPercICMPC/100),(MPERC_PIS/100),(MPERC_COF/100),(MRed_COF/100),0, nIPIPauta ) * (MPERC_COF/100)
      Else */                                                                                                                                        //NCF - 24/01/2013 - A tratativa da Aliq. de ICMS para PIS/COFINS será feita no carregamento da variável MPercICMPC
         nVLRCOF:= DI500PISCalc(nBASE_II+nDspBasImp,nDespBaseICM,(MPERC_II/100),(MPERC_IPI/100),(MPERC_ICMS/100),(MPERC_PIS/100),(MPERC_COF/100),(MRed_COF/100),(MPercICMPC/100), nIPIPauta,,,lIpi_Pauta ) * (MPERC_COF/100)
      //EndIf
   ENDIF

   IF cDespesa = DESPESA_PIS

      nVl_Pagto:=nVLRPIS

   ELSEIF cDespesa = DESPESA_COFINS

      nVl_Pagto:=nVLRCOF

   ELSEIF cDespesa = "203" .AND. lMV_ICMSPIS
      //IF !lNewBaseICMS                     //NCF - 08/02/2012 - Calcular o ICMS conforme configuração do CFO quando as alíquotas de PIS e COFINS no Regime de Trib. forem específicas
         nNewBaseICMS:=DI154CalcICMS(,nICMS_RED,MPERC_ICMS,nICMS_CTE,nBASE_II+nDspBasImp,nDesBasIcm/*nDespBaseICM*/,0,nIIVAL,nIPIVAL,.T.,nVLRPIS,nVLRCOF,EIJ->EIJ_OPERAC)
      //ENDIF
      //NCF - 24/01/2013 - Quando há Regime de Tribuação no PO e tratamento de ICMS por Suspensão, Diferimento ou Crédito Presumido
      //                   o valor do ICMS a recolher é calculado na variável nVal_ICM
      If (If(Type("lRegTriPO") # "U",lRegTriPO,.F.)) .And. (TYPE("aICMS_DIF")=="A" .AND. LEN(aICMS_DIF) > 0 .AND. (nP:=ASCAN( aICMS_Dif, {|x| x[1] == EIJ->EIJ_OPERAC} )) > 0 .And. ValType(nVal_ICM) == "N")
         nVl_Pagto := nVal_ICM
      ELSE
         nVl_Pagto := DITrans(nNewBaseICMS*(MPERC_ICMS/100),2)
      ENDIF

   ENDIF

ENDIF

IF(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"TPCALCIMP"),)// AWR - 20/05/2004 - MP164

Return nVl_Pagto

*--------------------------------------------------------*
FUNCTION  TPC252CabRel(PLargura, PTexto01, PPag, PTexto02)
*--------------------------------------------------------*
LOCAL MColSay := PLargura - 19, MColDate:= PLargura - 09,; // CRF 18/07/2011
      MColPage:= PLargura - 3 , MCta_Col:= 0 , MCta_Aux:= 0 // CRF 18/07/2011

MLin:=1

@ MLin,01    PSAY REPLICATE("-",PLargura)

MCta_Col:= (PLargura - LEN(PTexto01)) / 2
MCta_Aux:= LEN(ALLTRIM(SM0->M0_NOMECOM)) + 1

IF MCta_Col > MCta_Aux
   @ ++MLin,01  PSAY ALLTRIM(SM0->M0_NOMECOM)
ELSE
   @ ++MLin,01  PSAY SUBST(ALLTRIM(SM0->M0_NOMECOM),1,MCta_Col-3)
ENDIF

TPC252Center( PLargura, PTexto01, MLin)
@ MLin,MColSay    PSAY STR0105 //"Pagina..:"
@ MLin++,MColPage   PSAY STRZERO( PPag ,3,0)

IF PTexto02 = NIL
  // @ MLin,01       PSAY STR0106 //"Average Tecnologia"
   @ MLin,MColSay  PSAY STR0107 //"Emissao.:"
   @ MLin,MColDate PSAY dDataBase
ELSE
  // @ MLin,01       PSAY "Average Tecnologia"
   TPC252Center( PLargura, PTexto02, MLin)
   @ MLin,MColSay  PSAY STR0107 //"Emissao.:"
   @ MLin,MColDate PSAY dDataBase
ENDIF

@ ++MLin,01 PSAY REPLICATE("-",PLargura)

RETURN .T.

*-----------------------------------------*
FUNCTION TPC252Center(PComprimento, PTxt, PLin)
*-----------------------------------------*
@ PLin,(PComprimento-LEN(PTxt)) / 2 PSAY PTxt
RETURN NIL

*------------------------------*
FUNCTION TPC252Frete(aTPC,PDBF)
*------------------------------*
Local nVlrConte := 0
Private  nTotCnt:=0,nVl_Pagto:=0
DEFAULT PDBF := "W3_"
   nTabDesp:=0
   IF (nTabDesp := aScan( aTPC, {|x| x[3] == DESPESA_FRETE }) ) != 0
      IF aTPC[nTabDesp][11] #  "1"
         If PDBF = "W7_"
            SYR->(DBSEEK(xFilial()+SW6->W6_VIA_TRA+SW6->W6_ORIGEM+SW6->W6_DEST))
            nTotCnt:=SW6->(W6_CONTA20+W6_CONTA40+W6_CON40HC+W6_OUTROS)
            IF(EasyEntryPoint("EICTP252"),Execblock("EICTP252",.F.,.F.,'TOT_CNT'),)
            IF nTotCnt > 0
               nVl_Pagto += SW6->w6_CONTA20 * SYR->YR_20
               nVl_Pagto += SW6->W6_CONTA40 * SYR->YR_40
               nVl_Pagto += SW6->W6_CON40HC * SYR->YR_40_HC
               nVl_Pagto += SW6->W6_OUTROS  * SYR->YR_OUTROS
            ELSEIF !EMPTY(SW6->W6_MT3)
               nFrete1:=TabFre( SW6->W6_MT3 / 0.006 )
               nFrete2:=TabFre( nPesoAcumulado  )
               nVl_Pagto:=IF(nFrete1>=nFrete2,nFrete1,nFrete2)
            ELSE
               nVl_Pagto := TabFre( nPesoAcumulado  )
            ENDIF

         ELSE

            SYR->(DBSEEK(xFilial()+SW2->W2_TIPO_EM+SW2->W2_ORIGEM+SW2->W2_DEST))
            IF(EasyEntryPoint("EICTP252"),Execblock("EICTP252",.F.,.F.,'TOT_CNT_SEM_EMB'),)  // PLB 04/05/04 - Inclusão de Ponto para cálculo quando não houver embarque: PDBF = 'W3_'

            IF SW2->(!EMPTY(W2_FRETEIN)) //LGS-13/06/2016
               nVl_Pagto := SW2->W2_FRETEIN
            ELSEIF SW2->(!EMPTY(W2_CONTA20+W2_CONTA40+W2_CON40HC+W2_OUTROS))
               nVl_Pagto := SW2->W2_CONTA20 * SYR->YR_20
               nVl_Pagto += SW2->W2_CONTA40 * SYR->YR_40
               nVl_Pagto += SW2->W2_CON40HC * SYR->YR_40_HC
               nVl_Pagto += SW2->W2_OUTROS  * SYR->YR_OUTROS
            ELSEIF !EMPTY(SW2->W2_MT3)
               nFrete1:=TabFre( SW2->W2_MT3 / 0.006 )
               nFrete2:=TabFre( nPesoAcumulado  )
               nVl_Pagto:=IF(nFrete1>=nFrete2,nFrete1,nFrete2)
            ELSE
               nVl_Pagto := TabFre( nPesoAcumulado  )
            ENDIF

         ENDIF

         //       aTPC[nTabDesp][11] := "1"  Jonato em 13 de Agosto de 2003
         aTPC[nTabDesp][5] := nVl_Pagto
         IF aTPC[nTabDesp][4] # SYR->YR_MOEDA .AND. ! EMPTY(ALLTRIM(SYR->YR_MOEDA))
            aTPC[nTabDesp][5]:= aTPC[nTabDesp][5] * (BuscaTaxa(SYR->YR_MOEDA,dDataBase,.T.,.F.,.T.) / BuscaTaxa(aTPC[nTabDesp][4],dDataBase,.T.,.F.,.T.))
         ENDIF
      ENDIF
      IF aTPC[nTabDesp][5] < aTPC[nTabDesp][10] // SWI->WI_VAL_MIN
         aTPC[nTabDesp][5] := aTPC[nTabDesp][10]
      ELSEIF aTPC[nTabDesp][5] > aTPC[nTabDesp][9] .AND. aTPC[nTabDesp][9] # 0 // SWI->WI_VAL_MAX
         aTPC[nTabDesp][5] := aTPC[nTabDesp][9]
      ENDIF
      IF aTPC[nTabDesp][11] == "5"  // SWI->WI_IDVL == CONTEINER
         nVlrConte := 0
         nVlrConte += SW6->W6_CONTA20 * aTPC[nTabDesp][24] //SWI->WI_CON20
         nVlrConte += SW6->W6_CONTA40 * aTPC[nTabDesp][25] //SWI->WI_CON40
         nVlrConte += SW6->W6_CON40HC * aTPC[nTabDesp][26] //SWI->WI_CON40H
         nVlrConte += SW6->W6_OUTROS  * aTPC[nTabDesp][27] //SWI->WI_CONOUT
         aTPC[nTabDesp][5] := nVlrConte
         IF aTPC[nTabDesp][5] < aTPC[nTabDesp][10] // SWI->WI_VAL_MIN
            aTPC[nTabDesp][5] := aTPC[nTabDesp][10]
         ENDIF
         IF aTPC[nTabDesp][5] > aTPC[nTabDesp][9] .AND. aTPC[nTabDesp][9] # 0 // SWI->WI_VAL_MAX
            aTPC[nTabDesp][5] := aTPC[nTabDesp][9]
         ENDIF
      ENDIF
   ENDIF
Return If(nTabDesp#0,aTPC[nTabDesp][5],0)

*----------------------------------------------------------------------------
Function TP252CriaWork()
*----------------------------------------------------------------------------
Private aStruct

IF SELECT("WorkTP") # 0
   //RMD - 24/11/2021 - Revisado o tratamento para reaproveitar o temporário
   AvZap("WorkTP")
   /*
      //MFR 05/04/2019 OSSME-2690
      WorkTP->(avzap())
   IF TYPE("axFl2DelWork") = "A" .AND. LEN(axFl2DelWork) > 3
      WorkFile:=axFl2DelWork[1]
      WorkNTX2:=axFl2DelWork[2]
      WorkNTX3:=axFl2DelWork[3]
      WorkNTX4:=axFl2DelWork[4]
      WorkNTX5:=axFl2DelWork[5]
      WorkNTX6:=axFl2DelWork[6]
      WorkNTX7:=axFl2DelWork[7]
      //MFR 05/04/2019 OSSME-2690
      //RETURN .T.      
   ENDIF
   //MFR 05/04/2019 OSSME-2690
   //RETURN .F.
ENDIF*/

Else

   aStruct:={;
   { "WKDT_PAGTO" , "D" ,  8 , 0 }  ,;
   { "WKDESPESA"  , "C" ,  3 , 0 }  ,;
   { "WKPO_NUM"   , "C" , AVSX3("W7_PO_NUM",AV_TAMANHO) , 0 }  ,;
   { "WKMOEDA"    , "C" ,  3 , 0 }  ,;
   { "WKVL_PAGTO" , "N" , 19 , 2 }  ,;
   { "WKDESPDESC" , "C" , 30 , 0 }  ,;
   { "WKFORN_N"   , "C" , 30 , 0 }  ,;
   { "WKFORN_R"   , "C" , 15 , 0 }  ,;
   { "WKNUM_PC"   , "C" , 04 , 0 }  ,;
   { "WKDT_EMB"   , "D" , 08 , 0 }  ,;
   { "WKCONDICAO" , "C" , 08 , 0 }  ,;
   { "WKFOBPERC"  , "N" , 10 , 2 }  ,;
   { "WK_HAWB"    , "C" , AVSX3("W7_HAWB",AV_TAMANHO) , 0 }  ,;
   { "WK_CHEG"    , "D" , 08 , 0 }  ,;
   { "WKFOBDIAS"  , "N" , 10 , 0 }  ,;
   { "WKVLPAGTO2" , "N" , 17 , 8 }  }  // GFP - 16/01/2014

   If EICLOJA() .And. (nPos := aScan(aStruct, {|x| x[1] == "WKFORN_R" })) > 0
      aAdd(aStruct, Nil)
      aIns(aStruct, nPos + 1)
      aStruct[nPos+1] := {"WKFORLOJ","C", AvSx3("W1_FORLOJ", AV_TAMANHO),0}
   EndIf

   If(EasyEntryPoint("EICTP252"),ExecBlock("EICTP252",.F.,.F.,"ESTR_WORK"),) // RA - 14/08/2003

   IF EasyEntryPoint("EICPTR01")
      EasyExRdm("U_EICPTR01", "2",@aStruct)   
   EndIf

   WorkFile := E_CriaTrab(,aStruct,"WorkTP") //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

   IF !USED()
      Help("", 1, "AVG0000573")//Nao foi possivel a abertura do Arquivo de Trabalho
      Return .F.
   ENDIF

   IndRegua("WorkTP",WorkFile+TEOrdBagExt(),"WK_HAWB+WKPO_NUM+DTOS(WKDT_PAGTO)+WKDESPESA")

   WorkNTX2:=E_Create(,.F.)
   IndRegua("WorkTP",WorkNTX2+TEOrdBagExt(),"WKPO_NUM+DTOS(WKDT_PAGTO)+WKDESPESA")

   WorkNTX3:=E_Create(,.F.)
   IndRegua("WorkTP",WorkNTX3+TEOrdBagExt(),"WKDESPESA+DTOS(WKDT_PAGTO)+WKPO_NUM")

   WorkNTX4:=E_Create(,.F.)
   IndRegua("WorkTP",WorkNTX4+TEOrdBagExt(),"DTOS(WKDT_PAGTO)+WKDESPESA+WKPO_NUM")

   WorkNTX5:=E_Create(,.F.)
   IndRegua("WorkTP",WorkNTX5+TEOrdBagExt(),"WK_HAWB+WKDESPESA+WKPO_NUM")

   // RA - 19/08/03 - O.S. 804/03 - Inicio
   WorkNTX6:=E_Create(,.F.)
   IndRegua("WorkTP",WorkNTX6+TEOrdBagExt(),"WK_HAWB+DTOS(WKDT_PAGTO)+WKDESPESA")
   // RA - 19/08/03 - O.S. 804/03 - Final

   // LDR
   WorkNTX7:=E_Create(,.F.)
   IndRegua("WorkTP",WorkNTX7+TEOrdBagExt(),"WKPO_NUM+WKDESPESA+DTOS(WKDT_PAGTO)")

   // RJB 23.03.2004 ERRO COM ADS E CONTROLE DE TRASACAO
   // RJB 23.03.2004 ERRO COM ADS E CONTROLE DE TRASACAO
   SET INDEX TO (WorkFile+TEOrdBagExt()),(WorkNTX2+TEOrdBagExt()),(WorkNTX3+TEOrdBagExt()),(WorkNTX4+TEOrdBagExt()),(WorkNTX5+TEOrdBagExt()),(WorkNTX6+TEOrdBagExt()),(WorkNTX7+TEOrdBagExt())

   IF TYPE("axFl2DelWork") = "A"
      AADD(axFl2DelWork,WorkFile)
      AADD(axFl2DelWork,WorkNTX2)
      AADD(axFl2DelWork,WorkNTX3)
      AADD(axFl2DelWork,WorkNTX4)
      AADD(axFl2DelWork,WorkNTX5)
      AADD(axFl2DelWork,WorkNTX6)
      AADD(axFl2DelWork,WorkNTX7)
   ENDIF
EndIf

RETURN .T.

*--------------------------------------------*
FUNCTION Fob_cambio()
*--------------------------------------------*
LOCAL nORD:=WORKTP->(INDEXORD()),nRECNO:=WORKTP->(RECNO()),I
Local cPO := WORKTP->WKPO_NUM

WORKTP->(DBSETORDER(7))

FOR I:=1 TO LEN(aParc_Pgtos)
    //If MOrdem <> _Embarque
       WORKTP->(DBSEEK(aParc_Pgtos[I][1]+"101"))
       cPO := aParc_Pgtos[I][1]
    //Else
       //WORKTP->(DBSEEK(cPO+"101"))
    //EndIf
    DO WHILE WORKTP->(!EOF()) .AND. WORKTP->WKPO_NUM = cPO .AND. WORKTP->WKDESPESA = "101"

       IF (WorkTP->WKVL_PAGTO) <= Round((aParc_Pgtos[I][2]/aParc_Pgtos[I][3]),2)
          WorkTP->(DBDELETE())
          aParc_Pgtos[I][2]  -= Round((WorkTP->WKVL_PAGTO * aParc_Pgtos[I][3]),2)
       ELSE
          WorkTP->WKVL_PAGTO -= Round((aParc_Pgtos[I][2] / aParc_Pgtos[I][3]),2)
          aParc_Pgtos[I][2] := 0 //AAF 29/01/08 - Valor já abatido
       ENDIF
       WORKTP->(DBSKIP())
    ENDDO
NEXT

WORKTP->(DBSETORDER(nORD))
WORKTP->(DBGOTO(nRECNO))

RETURN .T.


*---------------------------------------------*
Static Function AjustaDtEmb(PDt_Real,MPO_NUM)
*---------------------------------------------*
Local nRecSW7 := 0, nRecSW6 := 0
Local aOrd := SaveOrd({"SW6","SW7"})
Default PDt_Real := CTOD("")

If MOrdem == _PO .OR. MOrdem == _Data .OR. MOrdem == _Despesa
   nRecSW7 := SW7->(Recno())
   nRecSW6 := SW6->(Recno())
   SW6->(DbSetOrder(1))
   SW7->(DbSetOrder(2))
   If SW7->(DbSeek(xFilial("SW7")+AvKey(MPO_NUM,"W7_PO_NUM"))) .AND. SW6->(DbSeek(xFilial("SW6")+SW7->W7_HAWB))
      PDt_Real := If(!Empty(SW6->W6_DT_EMB),SW6->W6_DT_EMB,PDt_Real)
   EndIf
   SW7->(DbGoTo(nRecSW7))
   SW6->(DbGoTo(nRecSW6))
EndIf

RestOrd(aOrd,.T.)
Return PDt_Real

Static function LoadDspBImp( pTab , PSALDO_Q , nQtdeAcumulada, cImportador ,cImpCalc,bTPCPag)

Local lIsDspBImp, lIsDspBIcm, nEDspBAux  := 0
Local nFobTot := 0

   If Type("aTPC") <> "A"
      aTPC:= Nil
   EndIf

   //TDF - 15/02/12 - Calculo do valor total do processo
   IF SELECT("Work_1") > 0
      aOrdWork_1:= SaveOrd({"Work_1"})
      Work_1->(DbGoTop())
      While Work_1->(!EOF())
         nFobTot += Work_1->WKFOB_TOT
         Work_1->(dbSkip())
      EndDo
      RestOrd(aOrdWork_1,.T.)
   EndIf
      
      nPRateio := If( nFobtot > 0 , (Work_1->WKFOB_TOT/nFobTot) , MRateio )
      While SWI->(!EOF()) .And. SWI->WI_TAB == pTab
         IF !(LEFT(SWI->WI_DESP,1) $ "1,2,9")
            IF SYB->(DBSEEK(XFILIAL("SYB")+SWI->WI_DESP))

                lIsDspBImp := SYB->YB_BASEIMP  $ cSim .And. cImpCalc == 1 //THTS - 19/01/2018
                lIsDspBIcm := SYB->YB_BASEICMS $ cSim .And. cImpCalc == 2
                nEDspBAux  := 0

                If lIsDspBImp .Or. lIsDspBIcm
                   IF SWI->WI_IDVL == '1' 
                     nEDspBAux := Tp252CvUSD( SWI->WI_VALOR , SWI->WI_MOEDA , cMOEDAEST ,  nPRateio )

                   ElseIf SWI->WI_IDVL == '2'
                      If EasyGParam("MV_EIC0068",,0) > 0 .And. ValType(aTPC) == "A" .And. (nIndDspAt := aScan(aTPC,{|x| x[3] == SWI->WI_DESP })) > 0 .And. If(lIsDspBIcm,(nPosDspICM := aScan(aTPC,{|x| x[3] == DESPESA_ICMS}) ) > 0,.T.) //NCF - 28/12/2017 - Desp.Base.Imp. na base de calculo 
                         nValor    := If( lIsDspBImp, GetEDspBas(aTPC,"II",nIndDspAt,nIndDspAt,"TPCBase",,nPRateio,bTPCPag) , GetEDspBas(aTPC,"ICMS",nPosDspICM,nIndDspAt,"TPCBase251",cImportador,nPRateio,bTPCPag) )
                         nEDspBAux := Tp252CvUSD( nValor , SWI->WI_MOEDA , cMOEDAEST ,  nPRateio )
                      EndIf

                   ElseIF SWI->WI_IDVL == '3'
                     nEDspBAux :=  Tp252CvUSD( SWI->WI_VALOR * nQtdeAcumulada , SWI->WI_MOEDA , cMOEDAEST ,  nPRateio )

                   ElseIF SWI->WI_IDVL == '4'
                     IF nPesoAcumulado <= SWI->WI_KILO1
                        nEDspBAux := SWI->WI_VALOR1 * nPesoAcumulado
                     ELSEIF nPesoAcumulado <= SWI->WI_KILO2
                        nEDspBAux := SWI->WI_VALOR2  * nPesoAcumulado 
                     ELSEIF nPesoAcumulado <= SWI->WI_KILO3
                        nEDspBAux := SWI->WI_VALOR3  * nPesoAcumulado 
                     ELSEIF nPesoAcumulado <= SWI->WI_KILO4
                        nEDspBAux := SWI->WI_VALOR4  * nPesoAcumulado 
                     ELSEIF nPesoAcumulado <= SWI->WI_KILO5
                        nEDspBAux := SWI->WI_VALOR5  * nPesoAcumulado 
                     ELSE 
                        nEDspBAux := SWI->WI_VALOR6  * nPesoAcumulado 
                     ENDIF
                     nEDspBAux := Tp252CvUSD( nEDspBAux , SWI->WI_MOEDA , cMOEDAEST ,  nPRateio )

                   ElseIf SWI->WI_IDVL == '5'
                     nEDspBAux := If(cAlias == "SW7",SW6->W6_CONTA20,SW2->W2_CONTA20) * SWI->WI_CON20
                     nEDspBAux += If(cAlias == "SW7",SW6->W6_CONTA40,SW2->W2_CONTA40) * SWI->WI_CON40
                     nEDspBAux += If(cAlias == "SW7",SW6->W6_CON40HC,SW2->W2_CON40HC) * SWI->WI_CON40H
                     nEDspBAux += If(cAlias == "SW7",SW6->W6_OUTROS ,SW2->W2_OUTROS ) * SWI->WI_CONOUT

                     IF nEDspBAux < SWI->WI_VAL_MIN
                        nEDspBAux := SWI->WI_VAL_MIN
                     ENDIF
                     IF nEDspBAux > SWI->WI_VAL_MAX .AND. SWI->WI_VAL_MAX # 0
                        nEDspBAux := SWI->WI_VAL_MAX
                     ENDIF
                     nEDspBAux := Tp252CvUSD( nEDspBAux , SWI->WI_MOEDA , cMOEDAEST ,  nPRateio )
                     
                   Else
                     nEDspBAux := Tp252CvUSD( SWI->WI_VALOR , SWI->WI_MOEDA , cMOEDAEST ,  nPRateio )

                   EndIf
                   
                   If( lIsDspBImp , nDspBasImp , nDesBasIcm ) += nEDspBAux
                   nEDspBAux := 0
                       
                ENDIF
            ENDIF
         ENDIF
         SWI->(dbSkip())
      EndDo

Return .T.

Static Function Tp252CvUSD( nValor, cMoedaDe , cMoedaPara ,  nPRateio )
Local nValRet := 0

   If Alltrim(cMoedaDe) $ ("BRL/R$")
      nValRet := ( nValor * nPRateio ) / BuscaTaxa(cMoedaPara,dDataBase,.T.,.F.,.T.)
   ElseIf Alltrim(cMoedaDe) <> "US$"
      nValRet := ( nValor * nPRateio ) * (BuscaTaxa(cMoedaDe,dDataBase,.T.,.F.,.T.)/ BuscaTaxa(cMoedaPara,dDataBase,.T.,.F.,.T.))
   Else
      nValRet := ( nValor * nPRateio )
   EndIf

Return nValRet
*----------------------------------------------------------------------------
*     FIM DO PROGRAMA TPC252
*----------------------------------------------------------------------------

