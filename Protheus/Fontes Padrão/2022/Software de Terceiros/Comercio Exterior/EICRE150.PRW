#INCLUDE "Eicre150.ch"
#include "AVERAGE.CH"

#COMMAND E_RESET_AREA => SW7->(DBSETORDER(1)) ;
                       ; DBSELECTAREA(nOldArea)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICRE150 ³ Autor ³ MJBARROS/AVERAGE       ³ Data ³ 20/10/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio Resumo do P.O.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SigaEIC                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICRE150()

LOCAL nOldArea:=SELECT(), oDlg, nOpca:=0, TPO_NUM:=SW7->W7_PO_NUM, lValid:=.F.

PRIVATE cCadastro := OemtoAnsi(STR0001) //"Relat¢rio Resumo do P.O."
PRIVATE cArqF3:="SW2", cCampoF3:="W2_PO_NUM"
Private _PictPrUn := ALLTRIM(X3Picture("W3_PRECO")), _PictPO := ALLTRIM(X3Picture("W2_PO_NUM"))
Private _PictNBM := E_Tran("YD_TEC",,.T.)

DBSELECTAREA("SW7")
SW7->(DBSETORDER(2))

WHILE .T.

     DEFINE MSDIALOG oDlg TITLE cCadastro From 9,0 To 18,40 OF GetWndDefault()
     oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //LRS - 09/11/2017
     oPanel:Align:= CONTROL_ALIGN_ALLCLIENT 
     nOpcao:=0
     @ 10,2 SAY OemtoAnsi(STR0002) OF oPanel PIXEL //"N§ do P.O."
     @ 8,35 MSGET TPO_NUM F3 cArqF3 SIZE 40,10 PICTURE _PictPO ;
                                            VALID (lValid:=RE150Val(TPO_NUM)) OF oPanel PIXEL

     ACTIVATE MSDIALOG oDlg ON INIT ;
              EnchoiceBar(oDlg,{||nOpca:=1,If(lValid .OR. RE150Val(TPO_NUM),oDlg:End(),)},;
                               {||nOpca:=0,oDlg:End()}) CENTERED
  If nOpca = 0
     E_RESET_AREA
     Return .F.
  Endif

  RE150Print(TPO_NUM)

ENDDO

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RE150Print³ Autor ³ MJBARROS/AVERAGE      ³ Data ³ 20.10.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Relatorio Resumo do P.O.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
FUNCTION RE150Print(TPO_NUM)

LOCAL cDesc1   := STR0003 //"Emissao de relatorios com dados resumo do P.O."
LOCAL cDesc2   := STR0004 //"Historico do P.O."
LOCAL cDesc3   := " "
LOCAL cString  := "SW7"
LOCAL cRegAnt  := Recno()

PRIVATE tamanho :="M"  // P = 80 , M =132 , G=220
PRIVATE Titulo  :=STR0005 //"Resumo do P.O."
PRIVATE aReturn := { STR0006, 1,STR0007, 1, 2, 1, "",0 } //"Zebrado"###"Importa‡Æo"
PRIVATE nomeprog:="EICRE150",nLastKey := 0,nBegin:=0,aLinha:={ }
PRIVATE aDriver :=ReadDriver()
PRIVATE cPerg
PRIVATE wnrel   := "EICRE150"

wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,Tamanho,,.F.)

wnrel:=ALLTRIM(wnRel)

If nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Set Filter to
   Return
Endif

RptStatus({|lEnd| RE150PrnRel(@lEnd,wnRel,cString,TPO_NUM)},Titulo)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RE150PrnCa³ Autor ³MJBARROS/AVERAGE        ³ Data ³ 11.10.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Impressao de POs                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ EICRE150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RE150PrnRel(lEnd,WnRel,cString,TPO_NUM)
LOCAL MCC_Ant, MSI_Num_Ant, MCod_I_Ant, MFabr_Ant, MForn_Ant, MChave_Ant 
LOCAL MChave, MImprime,lErro:=.F., lPvez := .T.
Local lNaoSkip:= .T.  //FCD, variavel de controle que quando entra no WHILE e 
                      //nao acha o registro no SW6,tem que ir para o proximo 
                      //registro do SW7.
LOCAL _PictItem := ALLTRIM(X3PICTURE("B1_COD"))
LOCAL cMoedaDolar:=BuscaDolar()//EasyGParam("MV_SIMB2",,"US$")

PRIVATE Cabec1  :=""
PRIVATE Cabec2  :=""
PRIVATE nTipo   :=1

limite := 130;li:= 80
M_PAG  := 1  ;mLin:= 99

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a Regua                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetRegua(SW7->(LASTREC()))

// REPOSICIONA POIS RETINDEX() DENTRO DA SETPRINT DESPOSICIONOU ARQUIVO
DBSELECTAREA("SW7")
SW7->(DBSETORDER(2))
SW7->(DBSEEK(xFilial("SW7")+TPO_NUM))

MCC_Ant    := W7_CC
MSI_Num_Ant:= W7_SI_NUM
MCod_I_Ant := W7_COD_I
MFabr_Ant  := W7_FABR
MForn_Ant  := W7_FORN
MChave_Ant := MCC_ANT+MSI_Num_Ant+MCod_I_Ant+MFabr_Ant+MForn_Ant
MChave     := SW7->W7_CC+SW7->W7_SI_NUM+SW7->W7_COD_I+SW7->W7_FABR+SW7->W7_FORN
MImprime   := .F.

WHILE SW7->(!EOF()).AND. TPO_Num == SW7->W7_PO_NUM .AND.;
                  xFilial("SW7") == SW7->W7_FILIAL 
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Compoe o Driver de Impressao                                      ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If lPvez
      If aReturn[4] == 1     // Comprimido
         @ 001,000 PSAY &(aDriver[1])
      ElseIf aReturn[4] == 2    // Normal
         @ 001,000 PSAY &(aDriver[2])
      EndIf
      lPvez := .F.
   EndIf

   IncRegua()

   If lEnd
      @PROW()+1,001 PSAY STR0008		 //"CANCELADO PELO OPERADOR"
      Exit
   Endif

   IF ! SW2->(DBSEEK(xFilial("SW2")+SW7->W7_PO_NUM))
      @PROW()+1,001 PSAY STR0009+TRAN(SW7->W7_PO_NUM,_PictPO)+STR0010 //"P.O. "###" NAO CADASTRADO NO ARQUIVO PO000"
      Exit
   ENDIF

   SY6->(DBSEEK(xFilial("SY6")+SW2->W2_COND_PAG+STR(SW2->W2_DIAS_PAG,3,0)))
   
   BuscaTaxa(cMoedaDolar,SW2->W2_DT_PAR)
   
   If ! SW4->(DBSEEK(xFilial("SW4")+SW7->W7_PGI_NUM))
      @PROW()+1,001 PSAY STR0011+SW7->W7_PGI_NUM+STR0012 //"P.G.I. "###" NAO CADASTRADO NO ARQUIVO GI000"
      EXIT
   ENDIF
   
   If !SB1->(DBSEEK(xFilial("SB1")+SW7->W7_COD_I))
      @PROW()+1,001 PSAY STR0013+TRANS(SW7->W7_COD_I,_PictItem)+STR0014 //"CODIGO DO ITEM "###" NAO CADASTRADO NO ARQUIVO CI000"
      EXIT
   ENDIF
   
   IF MLin > 60
      MImprime:= .T.
      RE150CabRel()
   ENDIF
   
// SELE SW7
   lNaoSkip := .T.
   WHILE SW7->(!EOF()).AND. MChave = MChave_Ant
   
      If !SW6->(DBSEEK(xFilial("SW6")+ SW7->W7_HAWB))
         @PROW()+1,001 PSAY STR0015+SW7->W7_HAWB+STR0016 //"Nr. Processo "###" NAO CADASTRADO NO ARQUIVO SW6"
         EXIT    
      Else
         lNaoSkip := .F.   
      ENDIF
      
//    SELE SW7
      
      IF MImprime
         RE150Cab1()
      ENDIF

      IF MLin > 60
         MLIN:= MLIN + 1
         @ Mlin,01 PSAY REPL("-",86)
         RE150CabRel()
         RE150Cab2()
      ENDIF
      
      MLIN:= MLIN + 1
      @ Mlin,01 PSAY "|"
      @ Mlin,02 PSAY SW6->W6_LOTE
      @ Mlin,08 PSAY "|"
      @ Mlin,09 PSAY SW6->W6_DT
      @ Mlin,19 PSAY "|"
      @ Mlin,20 PSAY SW6->W6_DT_EMB
      @ Mlin,30 PSAY "|"
      @ Mlin,31 PSAY SW6->W6_CHEG
      @ Mlin,41 PSAY "|"
      @ Mlin,44 PSAY SW6->W6_HAWB
      @ Mlin,59 PSAY "|"
      @ Mlin,60 PSAY SW6->W6_DI_NUM PICTURE E_Tran("W6_DI_NUM",,.T.)
      @ Mlin,72 PSAY "|"
      @ Mlin,73 PSAY SW6->W6_DT_DESEM
      @ Mlin,82 PSAY "|"
      @ Mlin,83 PSAY SW6->W6_DT_ENTR
      @ Mlin,94 PSAY "|"
      
      MImprime:= .F.
//    SELE SW7
      SW7->(DBSKIP())
      MChave:=SW7->W7_CC+SW7->W7_SI_NUM+SW7->W7_COD_I+SW7->W7_FABR+SW7->W7_FORN
   ENDDO
   If lNaoSkip
      SW7->(DBSkip())
   Endif
   MCC_Ant    := W7_CC
   MSI_Num_Ant:= W7_SI_NUM
   MCod_I_Ant := W7_COD_I
   MFabr_Ant  := W7_FABR
   MForn_Ant  := W7_FORN
   MChave_Ant := MCC_ANT+MSI_Num_Ant+MCod_I_Ant+MFabr_Ant+MForn_Ant
   MChave     := SW7->W7_CC+SW7->W7_SI_NUM+SW7->W7_COD_I+SW7->W7_FABR+SW7->W7_FORN
   
   IF MLin > 54
      MLIN:= MLIN + 1
      @ Mlin,01 PSAY REPL("-",86)
      RE150CabRel()
   ENDIF
   RE150Cab3()
   MLin:= 99

   If lEnd
      Exit
   Endif

ENDDO

Set Device to Screen
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
   Set Printer TO 
   OurSpool(wnrel)
Endif
MS_FLUSH()
Return .T.
*----------------------------------------------------------------------------
FUNCTION RE150Cab1
*----------------------------------------------------------------------------
LOCAL _LIT_CC := AVSX3("W0__CC")[5]
LOCAL _PictItem := ALLTRIM(X3PICTURE("B1_COD"))
LOCAL _PictSi   := ALLTRIM(X3PICTURE("W0__NUM"))

DBSELECTAREA("SW7")
@ Mlin,01 PSAY "         --------------------------------------------------"+REPLI('-',LEN(_PictPo)-1)+"------------------------------------------------"
MLIN:= MLIN + 1
@ Mlin,01 PSAY STR0017+TRANS(W7_PO_NUM,_PictPO)+STR0018+DTOC(SW2->W2_PO_DT)+"                             |" //"         | Purchase Order Nro...: "###" |       | Data..: "
MLIN:= MLIN + 1
@ Mlin,01 PSAY "         --------------------------------------------------"+REPLI('-',LEN(_PictPo)-1)+"------------------------------------------------"
MLIN:= MLIN + 2
@ Mlin,01 PSAY " ----------------------------------------------------------------------------------------------------------------------------------------"
MLIN:= MLIN + 1
@ Mlin,01 PSAY STR0019 + _LIT_CC +REPLI('.',18-LEN(_LIT_CC))+": "+TRANS(W7_SI_NUM,_PictSI)+" / "+W7_CC+" - "+BuscaCCusto(W7_CC) //" | Solicitacao de Importacao / "
@ Mlin,137 PSAY "|"
MLIN:= MLIN + 1
@ Mlin,01 PSAY " |                                                                                                                                      |"
MLIN:= MLIN + 1
@ Mlin,01 PSAY STR0020+TRANS(W7_COD_I,_PictItem)+" - "+MSMM( SB1->B1_DESC_P,36,1 ) //" | Discriminacao da Mercadoria...................: "
@ Mlin,137 PSAY "|"
MLIN:= MLIN + 1
@ Mlin,01 PSAY " |                                                                                                                                      |"
MLIN:= MLIN + 1
@ Mlin,01 PSAY STR0021+W7_FABR+" - "+BuscaFabr_Forn(W7_FABR) //" | Fabricante....................................: "
@ Mlin,137 PSAY "|"
MLIN:= MLIN + 1
@ Mlin,01 PSAY STR0022+W7_FORN+" - "+BuscaFabr_Forn(W7_FORN) //" | Exportador....................................: "
@ Mlin,137 PSAY "|"
MLIN:= MLIN + 1
@ Mlin,01 PSAY STR0023+SA2->A2_REPRES //" | Representante no Brasil.......................: "
@ Mlin,137 PSAY "|"
MLIN:= MLIN + 1
@ Mlin,01 PSAY STR0024+MSMM(SY6->Y6_DESC_P,36,1 ) //" | Condicoes de Pagamento........................: "
@ Mlin,137 PSAY "|"
MLIN:= MLIN + 1
@ Mlin,01 PSAY STR0025+TRANS(SW4->W4_GI_NUM,'@R 9999-99/999999-9')+STR0026+DTOC(SW4->W4_DT_VEN)/* +"      Prorrogacao.: "+SW4->W4_PRORR*/ //" | Guia de Importacao Nro........................: "###"        Vence em......: "
@ Mlin,137 PSAY "|"
MLIN:= MLIN + 1
/*
IF SW4->W4_IDDEPIN = "S"
   @ Mlin,01 PSAY STR0027 //" | Isento da Guia - Carta de Credenciamento......: DEPIN                                                                                |"
ELSE
   @ Mlin,01 PSAY STR0028 //" | Isento da Guia - Carta de Credenciamento......: NORMAL                                                                               |"
ENDIF
MLIN:= MLIN + 1
*/
@ Mlin,01 PSAY STR0029+SW2->W2_MOEDA+" "+TRAN(W7_PRECO,_PictPrUn) //" | Valor em Moeda Estrangeira....................: "
@ Mlin,137 PSAY "|"
MLIN:= MLIN + 1
@ Mlin,01 PSAY STR0030+DTOC(SW2->W2_DT_PAR)+STR0031+TRANS(SYE->YE_VLCON_CR,'@E 999,999.99999999') //" | Data Paridade.................................: "###"                Dolar Base....: "
@ Mlin,137 PSAY "|"
MLIN:= MLIN + 1
*tValor:= W7_PRECO / SW2->W2_PARID_US A.W.R. 13/05/98
TValor:= W7_PRECO * SW2->W2_PARID_US
@ Mlin,01 PSAY STR0032+TRANS(SW2->W2_PARID_US,'@E 999,999.999999')+STR0033+TRANS(TValor,'@E 999,999,999,999.99') //" | Paridade......................................: "###"          Valor em US$..: "
@ Mlin,137 PSAY "|"
MLIN:= MLIN + 1
@ Mlin,01 PSAY " ----------------------------------------------------------------------------------------------------------------------------------------"
MLIN:= MLIN + 1
@ Mlin,01 PSAY "----------------------------------------------------------------------------------------------"
MLIN:= MLIN + 1
@ Mlin,01 PSAY STR0034 //"|                                  EMBARQUES                                         |"
MLIN:= MLIN + 1
@ Mlin,01 PSAY "|--------------------------------------------------------------------------------------------|"
MLIN:= MLIN + 1
@ Mlin,01 PSAY STR0035 //"| Lote |  Data  |Embarque|Chegada  | Nr. Processo    | D.I.       | Desemb. |Entrega |"
MLIN:= MLIN + 1
@ Mlin,01 PSAY "|------|----------|----------|----------|----------------|------------|-----------|----------|"
*123456 99/99/99 99/99/99 99/99/99  12345678901234567 999999 99/99/99  99/99/99
               *  A   99/99/99 99/99/99  99/99/99  12345678901234567 999999 99/99/99  99/99/99
*  A    99/99/99  99/99/99  99/99/99  XXXXXXXXXXAA  99999  99/99/99   99/99/99

RETURN
*----------------------------------------------------------------------------
FUNCTION RE150Cab2
*----------------------------------------------------------------------------
@ Mlin,01 PSAY "--------------------------------------------------------------------------------------"
MLIN:= MLIN + 1
@ Mlin,01 PSAY STR0034 //"|                                  EMBARQUES                                         |"
MLIN:= MLIN + 1
@ Mlin,01 PSAY "|------------------------------------------------------------------------------------|"
MLIN:= MLIN + 1
@ Mlin,01 PSAY STR0035 //"| Lote |  Data  |Embarque|Chegada  | Nr. Processo    | D.I.       | Desemb. |Entrega |"
MLIN:= MLIN + 1
@ Mlin,01 PSAY "|------|--------|--------|---------|-----------------|------------|---------|--------|"

*  A    99/99/99 99/99/99 99/99/99 12345678901234567 99999 99/99/99 99/99/99
*  A    99/99/99  99/99/99  99/99/99  XXXXXXXXXXAA  99999  99/99/99   99/99/99

RETURN

*----------------------------------------------------------------------------
FUNCTION RE150Cab3
*----------------------------------------------------------------------------
LOCAL _PictQC := ALLTRIM(X3PICTURE("WR_NR_CONC")) 

MLIN:= MLIN + 1
@ Mlin,01 PSAY "----------------------------------------------------------------------------------------------"
MLIN:= MLIN + 1
@ Mlin,01 PSAY STR0036 //"| Observacoes..:                                                                     |"
MLIN:= MLIN + 1
@ Mlin,01 PSAY "|--------------------------------------------------------------------------------------------|"
MLIN:= MLIN + 1
@ Mlin,01 PSAY "| "+SW4->W4_OBS+"                     |"
MLIN:= MLIN + 1
@ Mlin,01 PSAY "----------------------------------------------------------------------------------------------"
MLIN:= MLIN + 2

*IF EMPTY(SW4->W4_CAP)
*   @ MLIN,01 PSAY STR0037 //"Anuencia da DEPIN                     Nao"
*ELSE
*   @ MLIN,01 PSAY STR0038+TRANS(SW4->W4_CAP,'@R 99999/99-9') //"Anuencia da DEPIN                     Sim    Nro. C.A.P...: "
*ENDIF

MLIN:= MLIN + 1
IF EMPTY(SW4->W4_DTSDCEX)
   @ MLIN,01 PSAY STR0039 //"Guia DECEX                            Nao"
ELSE
   @ MLIN,01 PSAY STR0040 //"Guia DECEX                            Sim"
ENDIF
MLIN:= MLIN + 2
@ MLIN,01 PSAY STR0041+TRANS(SB1->B1_POSIPI,_PictNBM) //"Classificacao da Mercadoria..: "
MLIN:= MLIN + 1
@ MLIN,01 PSAY STR0042+TRANS(SW2->W2__NR_COTA, _PictQc)+STR0043+DTOC(SW2->W2__DT_COTA) //"Cotacao......................: "###"                  Data..: "

RETURN
*----------------------------------------------------------------------------
FUNCTION RE150CabRel
*----------------------------------------------------------------------------
MLin := Cabec(Titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
MLin += 1
@ MLIN,01 PSAY REPL("*",limite)
MLin+=2
RETURN
*----------------------------------------------------------------------------
FUNCTION RE150Val(TPO_NUM)
*----------------------------------------------------------------------------
SW7->(DBSETORDER(2))
IF ! SW7->(DBSEEK(xFilial("SW7")+TPO_NUM))
   MsgInfo(STR0044,STR0045) //"P.O. não possui dados de embarque"###"Informação"
   Return .F.
Endif
   
Return .T.
*----------------------------------------------------------------------------*
*     FIM DO PROGRAMA
*----------------------------------------------------------------------------*
