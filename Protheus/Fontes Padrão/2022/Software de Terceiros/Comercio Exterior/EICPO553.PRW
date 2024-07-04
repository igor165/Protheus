//#include "fivewin.ch"
#include "AVERAGE.CH"
#include "EICPO553.CH"

#COMMAND E_RESET_AREA => DBSELECTAREA(nOldArea)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICPO553 ³ Autor ³ MJBARROS/AVERAGE       ³ Data ³ 15/10/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ New Shipping Instructions                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SigaEIC                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICPO553()

LOCAL nOldArea:=SELECT(), nOpca:=0, nInd, TPO_NUM:=SW5->W5_PO_NUM, lValid:=.F.
LOCAL _PictGI := ALLTRIM(X3Picture("W4_GI_NUM"))

PRIVATE cCadastro := OemtoAnsi(STR0001)//"New Shipping Instructions"
PRIVATE cArqF3:="SW2", cCampoF3:="W2_PO_NUM"
PRIVATE TabGI:={},TabTudo:={},;
        cLinhaGI:=SPACE(LEN(TRAN(SW4->W4_GI_NUM,_PictGI))), oLinhaGI
Private _PictPO := ALLTRIM(X3Picture("W2_PO_NUM"))

WHILE .T.

  TPort07:= .F.
  TPort08:= .F.
  TPort15:= .F.
  TPort00:= .F.
  MGuia  := .F.
  TRema01:= SPACE(50)
  TRema02:= SPACE(50)
  TRema03:= SPACE(50)
  TRema04:= SPACE(50)
  TRema05:= SPACE(50)
  
     MLinha:=3.0
     MCol1:=0.8
     MCol2:=7.0

     DEFINE MSDIALOG oDlg TITLE cCadastro From 9,8 To 28,70 OF GetWndDefault()
     
     oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 17/07/2015
     oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

     @ 1.6,MCol1 SAY OemtoAnsi(STR0002) OF oPanel  //"N§ do P.O."

     @ 1.6,MCol2 MSGET TPO_NUM F3 cArqF3 SIZE 50,10 OF oPanel PICTURE _PictPO ;
                                              VALID (lValid:=PO553Val(TPO_NUM))

*    @ MLinha,MCol1 SAY STR0003 OF oPanel //"Import License Nr."

*    @ MLinha,MCol2 SAY oLinhaGI VAR cLinhaGI OF oPanel

*    MLinha:= MLinha + 1

     @ MLinha,MCol1 SAY STR0004 OF oPanel  //"Remarks"    

     @ MLinha,MCol2 MSGET TRema01 SIZE 170,7 OF oPanel 
     MLinha++
     @ MLinha,MCol2 MSGET TRema02 SIZE 170,7 OF oPanel 
     MLinha++
     @ MLinha,MCol2 MSGET TRema03 SIZE 170,7 OF oPanel 
     MLinha++
     @ MLinha,MCol2 MSGET TRema04 SIZE 170,7 OF oPanel 
     MLinha++
     @ MLinha,MCol2 MSGET TRema05 SIZE 170,7 OF oPanel 
                                                   
     ACTIVATE MSDIALOG oDlg ON INIT ;
              EnchoiceBar(oDlg,{||nOpca:=1,;
                                If(lValid .OR. PO553Val(TPO_NUM) .AND. ;
                                   MSGYESNO("CONFIRMA OS DADOS DIGITADOS ?")=.T.,;
                                   oDlg:End(),)},;
                               {||nOpca:=0,oDlg:End()}) CENTERED 

  If nOpca = 0
     E_RESET_AREA
     Return .F.
  Endif

  PO553Print(TPO_NUM)

ENDD

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PO553Print³ Autor ³ MJBARROS/AVERAGE      ³ Data ³ 11.10.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Impressao da Carta p/ Envio de P.O.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
FUNCTION PO553Print(TPO_NUM)

LOCAL wnrel    := STR0005 //"EICPO553"
LOCAL cDesc1   := STR0006 //"Emissao de carta com novas instrucoes de embarque"
LOCAL cDesc2   := " "
LOCAL cDesc3   := " "
LOCAL cString  := "SW2"
LOCAL cRegAnt  := Recno()

PRIVATE tamanho :="P"
PRIVATE Titulo  := STR0007 //"New Shipping Instructions"
PRIVATE aReturn := { "Zebrado", 1,"Importa‡Æo", 2, 2, 1, "",0 }
PRIVATE nomeprog:=STR0008 ,nLastKey := 0,nBegin:=0,aLinha:={ } //"EICPO553"
PRIVATE aDriver :=ReadDriver()
PRIVATE cPerg    :=NIL

wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,.T.,Tamanho,,.F.)

If nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Set Filter to
   Return
Endif

RptStatus({|lEnd| PO553PrnCarta(@lEnd,wnRel,cString,TPO_NUM)},Titulo)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PO553PrnCa³ Autor ³MJBARROS/AVERAGE        ³ Data ³ 11.10.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Impressao de POs                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ EICPO553                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PO553PrnCarta(lEnd,WnRel,cString,TPO_NUM)

limite := 130;li:= 80
MPag   := 0;mLin:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz manualmente porque nao chama a funcao Cabec()                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a Regua                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetRegua(4)

MLin    := 0
MPag    := 0
MConta  := 1
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Compoe o Driver de Impressao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[4] == 1// Comprimido
   @ 001,000 PSAY &(aDriver[1])
ElseIf aReturn[4] == 2// Normal
   @ 001,000 PSAY &(aDriver[2])
EndIf 

IncRegua()//1

SW2->(DBSEEK(xFilial()+TPO_Num))
SY1->(DBSEEK(xFilial()+SW2->W2_COMPRA))
SA2->(DBSEEK(xFilial()+SW2->W2_FORN))

TNOME:=IF( ! EMPTY(SA2->A2_REPRES), SA2->A2_REPRES, SA2->A2_NOME)

PO553Cab()

IncRegua()//4

Grava_Ocor(SW2->W2_PO_NUM,dDataBase,STR0009) //"EMISSAO DA NEW SHIPPING INSTRUCTIONS"

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
FUNCTION PO553Cab()
*----------------------------------------------------------------------------
IncRegua()//2
MLin := 9

@ Mlin,65 PSAY STRZERO(DAY(dDataBase),2,0)+" / "+SUBSTR(CMONTH(dDataBase),1,3)+" / "+SUBSTR(STR(YEAR(dDataBase),4,0),3,2)
MLIN:= MLIN + 1
@ Mlin,01 PSAY "--------------------------------------------------------------------------------"
MLIN:= MLIN + 1
@ Mlin,21 PSAY STR0010 //"NEW SHIPPING INSTRUCTIONS"
MLIN:= MLIN + 1
@ Mlin,01 PSAY "--------------------------------------------------------------------------------"
MLIN:= MLIN + 6

PO553ATTN()

MLIN:= MLIN + 6
@ Mlin,01 PSAY "         OUR REFERENCE P.O. "+TRAN(SW2->W2_PO_NUM,_PictPO)
*@ Mlin,01 PSAY "                            "+CHR(14)+TRANS(Pedidos->POPO_NUM,'@R 9999/99!')+CHR(18)
MLIN:= MLIN + 2

@ MLin,01 PSAY "         REMARKS........: "+ TRema01
MLin:= MLin + 1
@ MLin,01 PSAY "                          "+ TRema02
MLin:= MLin + 1                      
@ MLin,01 PSAY "                          "+ TRema03
MLin:= MLin + 1
@ MLin,01 PSAY "                          "+ TRema04
MLin:= MLin + 1               
@ MLin,01 PSAY "                          "+ TRema05
MLIN:= MLIN + 10
@ Mlin,01 PSAY "         ANY DOUBT PLS CONTACT US."
MLIN:= MLIN + 2
SYT->(DBSEEK(xFilial()+SW2->W2_IMPORT))
@ Mlin,01 PSAY "         "+SYT->YT_NOME
MLIN:= MLIN + 2
/*TRANS(Importadores->IMTEL_PO,'@R 999-999-9999999')*/
@ Mlin,01 PSAY "         PHONE : "+SY1->Y1_TEL
*@ Mlin,01 PSAY "         PHONE : "
MLIN:= MLIN + 2
/*TRANS(Importadores->IMFAX_PO,'@R 999-999-9999999')*/
@ Mlin,01 PSAY "         FAX   : "+SY1->Y1_NOME
*@ Mlin,01 PSAY "         FAX   : "
RETURN

*----------------------------------------------------------------------------
FUNCTION PO553ATTN()
*----------------------------------------------------------------------------
IncRegua()//3
@ Mlin,01 PSAY STR0011 +TNome //"         TO.........: "
MLIN:= MLIN + 2
@ Mlin,01 PSAY STR0012 +LEFT(SA2->A2_CONTATO,20) //"         ATTN.......: "
MLIN++
@ Mlin,01 PSAY STR0013 +SA2->A2_FAX //"         FAX NR.....: "
MLIN++
@ Mlin,01 PSAY STR0014 +SA2->A2_TEL //"         PHONE NR...: "
MLIN:= MLIN + 2  
@ Mlin,01 PSAY STR0015 +SY1->Y1_NOME //"         FROM.......: "
RETURN
*----------------------------------------------------------------------------
FUNCTION PO553Val(TPO_NUM)
*----------------------------------------------------------------------------
LOCAL aLinhaGI:={}, Ind, nInd
LOCAL _PictGI := ALLTRIM(X3Picture("W4_GI_NUM"))

IF ! SW2->(DBSEEK(xFilial()+TPO_NUM))
   Help("", 1, "AVG0000446")//"P.O. nÆo cadastrado"###"Informa‡Æo"
   Return .F.
Endif
   
IF SW2->W2_NR_ALTER = 0
   Help("", 1, "AVG0000447")//"NÆo houve altera‡Æo no P.O. informado"###"Informa‡Æo"
   Return .F.
ENDIF

DBSELECTAREA("SW3")

IF ! SW3->(DBSEEK(xFilial()+TPO_NUM))
   Help("", 1, "AVG0000448")//"P.O. nÆo possui ¡tens"###"Informa‡Æo"
   Return .F.
Endif

SYT->(DBSEEK(xFilial()+SW2->W2_IMPORT))

TPort07:= .F.
TPort08:= .F.
TPort15:= .F.
TPort00:= .F.

TabGI:={}
TabTudo:={}

MControla:= .T.
ASIZE(aLinhaGI,0)

WHILE !EOF() .AND. SW3->W3_PO_NUM == TPO_Num .AND.;
                   SW3->W3_FILIAL == xFilial("SW3")

   DO CASE
      CASE W3_PORTARI = 7
           MControla:= .F.
           TPort07:= .T.
      CASE W3_PORTARI = 8
           MControla:= .F.
           TPort08:= .T.
      CASE W3_PORTARI = 15
           MControla:= .F.
           TPort15:= .T.
      CASE W3_PORTARI = 0
           TPort00:= .T.
   ENDCASE

   IF !EMPTY(W3_PGI_NUM)

      IF ASCAN(TabGI,W3_PGI_NUM) = 0
         MControla:= .F.
         AADD(TabGI,W3_PGI_NUM)
      ENDIF

      IF ASCAN(TabTudo,W3_PGI_NUM+W3_COD_I) = 0
         MControla:= .F.
         AADD(TabTudo,W3_PGI_NUM+W3_COD_I)
      ENDIF

   ENDIF
   DBSKIP()
ENDDO

MGuia := .F.

IF TPort07
   AADD(aLinhaGI, STR0022) //"PORTARIA DECEX 07 (PLS NOTE THE REMARKS ON THE PO)"
   MGuia:= .T.
ENDIF

IF TPort08
   AADD(aLinhaGI,STR0023) //"PORTARIA DECEX 08 (PLS NOTE THE REMARKS ON THE PO)"
   MGuia:= .T.
ENDIF

IF TPort15
   AADD(aLinhaGI,STR0024) //"PORTARIA DECEX 15 (PLS NOTE THE REMARKS ON THE PO)"
   MGuia:= .T.
ENDIF

IF .NOT. MGuia
   IF TPort00
      IF MControla
         Help("", 1, "AVG0000449")//"NÆo existe N£mero de P.G.I. p/ este P.O."###"Informa‡Æo"
         Return .F.
      ENDIF

      IF LEN(TabGI) = 1
         MControla2:= .F.
         FOR Ind=1 TO LEN(TabGI)
             DBSELECTAREA("SW4")
             IF ! SW4->(DBSEEK(xFilial()+TabGI[Ind]))
                MControla2:= .T.
                EXIT
             ELSE
                IF EMPTY(W4_GI_NUM)
                   MControla2:= .T.
                   EXIT
                ENDIF
             ENDIF
             AADD(aLinhaGI,TRAN(SW4->W4_GI_NUM,_PictGI))
         NEXT
      ELSE
         FOR Ind=1 TO LEN(TabTudo)

             MControla2:= .F.

             DBSELECTAREA("SW4")
             IF ! SW4->(DBSEEK(xFilial()+SUBSTR(TabTudo[Ind],1,10)))
                MControla2:= .T.
                EXIT
             ELSE
                IF EMPTY(W4_GI_NUM)
                   MControla2:= .T.
                   EXIT
                ENDIF
             ENDIF
             TCod_I:= VAL(SUBSTR(TabTudo[Ind],11,LEN(SW5->W5_COD_I)))
             AADD(aLinhaGI,TRAN(SW4->W4_GI_NUM,_PictGI))
         NEXT
      ENDIF
   ENDIF
   IF MControla2
      Help("", 1, "AVG0000450")//"NÆo existe N£mero de G.I. p/ este P.O."###"Informa‡Æo"
      Return .F.
   ENDIF
ENDIF

If LEN(aLinhaGI) > 3
   ASIZE(aLinhaGI,3)
   aLinhaGI[3]:="... e demais"
Endif
  
cLinhaGI:=""
For nInd:=1 TO LEN(aLinhaGI)
    cLinhaGI+=aLinhaGI[nInd]
    If nInd < LEN(aLinhaGI)
       cLinhaGI+=","
    Endif
Next
ASIZE(aLinhaGI,0)
Return .T.
