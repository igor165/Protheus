#INCLUDE "Eictr120.ch"
#include "AVERAGE.CH"
//#include "FiveWin.ch"

#COMMAND E_RESET_AREA => SW7->(DBSETORDER(1)) ;
                       ; DBSELECTAREA(nOldArea)

#DEFINE   LIMPA_DIAS     @ 10,32 SAY SPAC(3)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICTR120 ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 08.10.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Controle DECEX                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICTR120()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICTR120

LOCAL nOldArea:=SELECT(), MPO_NUM

LOCAL cSaveMenuh, nCnt, cTitulo, oDlg, oGet, nOpcA:=0, bMsg

LOCAl TPO_NUM:=SW5->W5_PO_NUM

PRIVATE TabPO_Num[15]

PRIVATE TDt_E_DEPIN,TDt_S_DEPIN,TDEPIN_DIA,TProtocolo,TCAP,TDt_E_DECEX,;
        TDt_S_DECEX,TNum_GI,TDt_GI,TValidade,TCusto,TObs,;
        TCod_PGI2,TCod_PAGI2,TNum_GI2,TNum_AGI2,TProrr,TDt_Sufr, TAverb_No,;
        TAverb_Dt, TSuframa, TID_DEPIN

PRIVATE cCadastro := OemtoAnsi(STR0001) //"Acompanhamento DECEX"

PRIVATE cMarca := GetMark(), lInverte := .F.

*PRIVATE cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,;
*        CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999

Private aHeader[0],nUsado:=0

*bHotArea:= {|| HotAreas(10, 4,17,75,nUsado)}
*bCampo  := {|nCPO| Field(nCPO) }

*MsgInfo(STR0002,0) //"EM PROCESSAMENTO - AGUARDE..."

DO WHILE .T.

   AFILL(TabPO_Num,SPACE(LEN(SW7->W7_PO_NUM)))
   TCOD_PAGI :=  TCOD_PGI := SPACE(LEN(SW4->W4_PGI_NUM))
   TEscolha  :=1

   DEFINE MSDIALOG oDlg TITLE cCadastro From 9,20 To 16,50 OF GetWndDefault()

   @  7,05 TO 45,70 OF oDlg PIXEL

   @ 18,10 RADIO oRad VAR TEscolha ITEMS STR0003, STR0004; //"P.G.I.s"###"P.A.G.I.s"
                                   3D SIZE 49,12 PIXEL

   DEFINE SBUTTON FROM 11,78 TYPE 1 ACTION (oDlg:End())        ENABLE OF oDlg

   DEFINE SBUTTON FROM 27,78 TYPE 2 ACTION (TEscolha:=0,oDlg:End()) ENABLE OF oDlg

   ACTIVATE MSDIALOG oDlg CENTERED

   If TEscolha = 0
      E_RESET_AREA
      Return .T.
   Endif

   _Altera := .T.

   If ! TR120GetNum()
      LOOP
   ENDIF

   MProg:=STR0005 //"Alteracao"

   If ! TR120Get()
      E_RESET_AREA
      Return .T.
   ENDIF

ENDDO
*----------------------------------------------------------------------------
FUNCTION TR120Get()
*----------------------------------------------------------------------------
Local _PictPAGI := ALLTRIM(X3Picture("W4_PGI_NUM"))
Local _PictGI := ALLTRIM(X3Picture("W4_GI_NUM"))
Local _PictPGI := ALLTRIM(X3Picture("W4_PGI_NUM"))
LOCAL cTitulo:=OemToAnsi(STR0001), oDlg, nOpcA:=0, lValid:=.T. //"Acompanhamento DECEX"

LOCAL nL1, nL2, nL4, nL5, nL6, nL7, nL8, nC0, nC1, nC2, nC3, nC4

LOCAL OldTela, nRec, aValid:={"PGI","PAGI","Ent_Dec","Sai_Dec","NumDi","DtDi","Vali"}

LOCAL bValid:={||lValid:=.T.,;
                 AEVAL(aValid,{|campo|If(lValid,lValid:=TR120Val(campo),)}),;
                 lValid }

DEFINE MSDIALOG oDlg TITLE cTitulo From 09,05 To 27,75 OF GetWndDefault()

@ 12,03 TO 130,265 OF oDlg PIXEL
nL1:=1.6 ; nL2:=2.6 ; nL3:=3.6   ; nL4:=4.6 ; nL5:=5.6 ; nL6:=6.6 ; nL7:=7.6
nL8:=8.6
nC1:=0.8 ; nC2:=8.0 ; nC3:=20.5  ; nC4:=25.0 ; nC5:=12.5

IF TEscolha = 1
   @ nL1,nC1 SAY  STR0006          //"P.G.I."
ELSE
   @ nL1,nC1 SAY  STR0007        //"P.A.G.I."
ENDIF

@ nL2,nC1 SAY STR0008    //"Entrada no DECEX"

IF TSuframa = "S"
   @ nL2,nC3 SAY STR0009  //"Dt Ent.SUFRAMA:"
ENDIF

@ nL3,nC1 SAY OemToAnsi(STR0010)  //"Sa¡da do DECEX"

IF TEscolha = 1
   @ nL3,nC3 SAY OemToAnsi(STR0011)    //"N§ da G.I."
   @ nL4,nC1 SAY STR0012             //"Data da G.I."
   @ nL4,nC3 SAY STR0013            //"Custo da G.I."
ELSE
   @ nL3,nC3 SAY OemToAnsi(STR0014)  //"N§ da A.G.I."
   @ nL4,nC1 SAY STR0015           //"Data da A.G.I."
   @ nL4,nC3 SAY STR0016             //"Custo A.G.I."
ENDIF

@ nL5,nC1 SAY STR0017               //"Data Validade"

IF TEscolha = 1
   @ nL6,nC1 SAY OemToAnsi(STR0018)  //"N§ Averba‡Æo Prov"
   @ nL6,nC3 SAY STR0019                          //"Data"
ENDIF

@ nL7,nC1 SAY OemToAnsi(STR0020)           //"Observa‡äes"

bDias:={|x|IF(x=NIL,"("+PADL(TDt_S_DECEX-TDt_E_DECEX,3,'0')+" dias)",SPACE(12))}
cDias:=Eval(bDias)

@ nL3,nC5 SAY oDias VAR cDias SIZE 30,15

IF TEscolha = 1
   IF _Altera
      @ nL1,nC2 MSGET TCod_PGI2 PICTURE _PictPGI VALID  TR120Val("PGI") SIZE 40,8
   ENDIF
ELSE
   @ nL1,nC2 MSGET TCod_PAGI2  PICTURE _PictPAGI VALID  TR120Val("PAGI") SIZE 40,8
ENDIF

IF TSuframa = "S"
   @ nL2,nC4 MSGET TDt_Sufr SIZE 30,7
ENDIF

@ nL2,nC2 MSGET TDt_E_DECEX                     VALID TR120Val("Ent_Dec") SIZE 30,7
@ nL3,nC2 MSGET TDt_S_DECEX                     VALID TR120Val("Sai_Dec") SIZE 30,7
@ nL3,nC4 MSGET TNum_GI     PICTURE _PictGI     VALID TR120Val("NumDi")   SIZE 50,7
@ nL4,nC2 MSGET TDt_GI                          VALID TR120Val("DtDi")    SIZE 30,7
@ nL5,nC2 MSGET TValidade                       VALID TR120Val("Vali")    SIZE 30,7
@ nL4,nC4 MSGET TCusto      PICTURE  "999,999,999.99"                     SIZE 50,7

IF TEscolha = 1
   @ nL6,nC2 MSGET TAverb_No  PICTURE "@!"             SIZE 90,10
   @ nL6,nC4 MSGET TAverb_Dt  WHEN ! EMPTY(TAverb_No)  SIZE 30,10
ENDIF

@ nL8,nC1 MSGET TObs          PICTURE "@!"             SIZE 220,10

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,;
         {|| nOpcA:=1,If(EVAL(bValid),oDlg:End(),)},;
         {|| nOpcA:=0, oDlg:End()}) CENTERED

If nOpcA = 1
    MsAguarde({|lEnd|TR120Atu({|msg| MsProcTxt(OemToAnsi(msg))}) },;
              STR0021) //"Atualizando informa‡äes..."
Else
    Return .F.
Endif

RETURN .T.
*----------------------------------------------------------------------------
FUNCTION TR120Val(PCampo)
*----------------------------------------------------------------------------
LOCAL GRecNo, MRecNo

DO CASE
   CASE PCampo = "PGI"
        If TEscolha # 1
           RETURN .T.
        ENDIF
        IF EMPTY(TCod_PGI2)
           Help("",1,"AVG0000574") //"Novo N£mero do P.G.I. nÆo preenchido"
           RETURN .F.
        ENDIF
        MRECNO := RECNO()
        IF TCod_PGI = TCod_PGI2
      *** MsgInfo("NAO HOUVE ALTERACAO NO NUMERO DA P.G.I",100,.T.)
        ELSE
           MRECNO := RECNO()
           DBSELECTAREA("SW4")
           DBSETORDER(1)
           IF DBSEEK(xFilial()+TCod_PGI2)
              Help("",1,"AVG0000577") //"Novo N£mero do P.G.I. j  cadastrado"###"Informação"
              DBSELECTAREA("SW4")
              DBGOTO(MRECNO)
              RETURN .F.
           ENDIF
        ENDIF

        DBSELECTAREA("SW4")
        DBGOTO(MRECNO)
*MsgInfo("ENTRE COM AS ALTERACOES",0)

        RETURN .T.

   CASE PCampo = "PAGI"
        If TEscolha # 2
           RETURN .T.
        ENDIF
        IF EMPTY(TCod_PAGI2)
           Help("",1,"AVG0000580") //"Novo N£mero do P.A.G.I. nÆo preenchido"###"Informação"
           RETURN .F.
        ENDIF
        MRECNO := RECNO()
        IF TCod_PAGI = TCod_PAGI2
        *** MsgInfo("NAO HOUVE ALTERACAO NO NUMERO DA P.A.G.I.",100,.T.)
        ELSE
           MRECNO := RECNO()
/*         DBSELECTAREA("SYI")
           IF DBSEEK(xFilial()+TCod_PAGI2)
             *MsgInfo("Novo N£mero do P.A.G.I. j  cadastrado",100,.T.)
              DBSELECTAREA("SYI")
              DBGOTO(MRECNO)
              RETURN .F.
           ENDIF   */
        ENDIF

//      DBSELECTAREA("SYI")
//      DBGOTO(MRECNO)
*        MsgInfo(OemToAnsi(STR0026,0) //"ENTRE COM AS ALTERA€åES"

        RETURN .T.

   CASE PCampo = "Ent_Dec"
        IF ! EMPTY(TDt_Sufr) .AND. TSuframa = "S"
           IF ! EMPTY(TDt_E_DECEX)
              IF TDt_Sufr > TDt_E_DECEX
                 Help("",1,"AVG000083") //"Dt. Entrada SUFRAMA nÆo pode ser maior que Dt.Entrada DECEX"###"Informação"
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

       /* IF TID_DEPIN = "S"
           IF EMPTY(TDt_S_DEPIN)
              IF EMPTY(TDt_E_DECEX)
                 RETURN .T.
              ELSE
                 Help("",1,"AVG000588") //"P.G.I./P.A.G.I. NÇO LIBERADA PELO DEPIN"###"Informação"
                 RETURN .F.
              ENDIF
           ELSE
              IF .NOT. EMPTY(TDt_E_DECEX)
                 IF TDt_S_DEPIN > TDt_E_Decex
                    Help("",1,"AVG0000591") //"DATA DE SAIDA DA DEPIN MAIOR QUE DATA DE ENTRADA NA DECEX"###"Informação"
                    RETURN .F.
                 ELSE
                    RETURN .F.
                 ENDIF
              ELSE
                 RETURN .T.
              ENDIF
           ENDIF
        ELSE
           RETURN .T.
        ENDIF */ //LRL 22/01/04
   CASE PCampo = "Sai_Dec"
        IF EMPTY(TDt_E_DECEX)
           IF .NOT. EMPTY(TDt_S_DECEX)
              Help("",1,"AVG0000595") //"Data de Sa¡da nÆo pode ser preenchida"###"Informação"
              RETURN .F.
           ELSE
               cDias:=Eval(bDias,.T.)
               oDias:Refresh()
*              LIMPA_DIAS
              RETURN .T.
           ENDIF
        ELSE
           IF .NOT. EMPTY(TDt_S_DECEX)
              IF TDt_S_DECEX < TDt_E_DECEX
                 Help("",1,"AVG0000599") //"Data de Sa¡da nÆo pode ser menor que Data de Entrada"###"Informação"
                 RETURN .F.
              ELSE
                  cDias:=Eval(bDias)
                  oDias:Refresh()
                 RETURN .T.
              ENDIF
           ELSE
               cDias:=Eval(bDias,.T.)
               oDias:Refresh()
*              LIMPA_DIAS
              RETURN .T.
           ENDIF
        ENDIF
   CASE PCampo = "NumDi"
        IF EMPTY(TDt_S_DECEX)
           IF EMPTY(TNum_GI)
              RETURN .T.
           ELSE
              Help("",1,"AVG0000600") //"N£mero da G.I. nÆo pode ser preenchido"###"Informação"
              RETURN .F.
           ENDIF
        ELSEIF EMPTY(TNum_GI)
        							Help("",1,"AVG0000603") //"N£mero da G.I./A.G.I. nÆo preenchido"###"Informação"
               RETURN .F.
        ELSEIF TEscolha = 1
               IF TNum_GI <> TNum_GI2
                  DBSELECTAREA("SW4")
                  GRecno := RECNO()
                  DBSETORDER(2)
                  IF DBSEEK(xFilial()+TNum_GI)
                     Help("",1,"AVG0000605") //"N£mero da G.I. j  cadastrado"###"Informação"
                     DBGOTO(GRecno)
                     RETURN .F.
                  ENDIF
                  DBGOTO(GRecno)
               ENDIF
               RETURN .T.
        ELSEIF TNum_GI <> TNum_AGI2
/*             DBSELECTAREA("SYI")
               RRecno := RECNO()
               DBSETORDER(3)
               IF DBSEEK(xFilial()+TNum_GI)
*                 MsgInfo(OemToAnsi("N£mero do A.G.I. j  cadastrado"),1000,.T.)
                  DBGOTO(RRecno)
                  RETURN .F.
               ENDIF
               DBGOTO(RRecno)  */
        ENDIF

        RETURN .T.

   CASE PCampo = "DtDi"
        IF TEscolha = 1
           IF EMPTY(TDt_S_DECEX)
              IF EMPTY(TDt_GI)
                 RETURN .T.
              ELSE
                 Help("",1,"AVG0000608") //"Data da G.I. nÆo pode ser preenchida"###"Informação"
                 RETURN .F.
              ENDIF
           ELSE
              IF EMPTY(TDt_GI)
                 Help("",1,"AVG0000609") //"Data da G.I. nÆo preenchida"###"Informação"
                 RETURN .F.
              ELSE
                 // A.C.D. 19.07.96
                 IF TDt_GI < TDt_E_DECEX
                    Help("",1,"AVG0000611") //"Data da G.I. nÆo pode ser menor que Data de Entrada no DECEX"###"Informação"
                    RETU .F.
                 ENDIF
                 // FIM
                 IF EMPTY(TValidade)
                    TValidade := TDt_Gi + 60
                 ENDIF
                 RETURN .T.
              ENDIF
           ENDIF
        ELSE
           IF .NOT. EMPTY(TDt_GI)
              IF EMPTY(TValidade)
                 * TValidade := TDt_Gi + 60
              ENDIF
           ENDIF
           RETURN .T.
        ENDIF

   CASE PCampo = "Vali"
        IF TEscolha = 1
           IF EMPTY(TDt_S_DECEX)
              IF EMPTY(TValidade)
                 RETURN .T.
              ELSE  
              			Help("",1,"AVG0000612") //"Data de Validade nÆo pode ser preenchida"###"Informação"
                 RETURN .F.
              ENDIF
           ELSE
              IF EMPTY(TValidade)
                 Help("",1,"AVG0000614") //"Data de Validade nÆo preenchida"###"Informação"
                 RETURN .F.
              ELSE
                 RETURN .T.
              ENDIF
           ENDIF
        ELSE
           RETURN .T.
        ENDIF
ENDCASE
RETURN .T.
*----------------------------------------------------------------------------
FUNCTION TR120GetNum()
*----------------------------------------------------------------------------
Local _PictPAGI := ALLTRIM(X3Picture("W4_PGI_NUM"))
Local _PictPGI := ALLTRIM(X3Picture("W4_PGI_NUM"))
LOCAL   oDlg, lValid:=.F., nOpca:= 0,cTitulo:=OemToAnsi(STR0040),bValid //"Sele‡Æo de "
PRIVATE cArqF3, cCampoF3

IF TEscolha = 1
   cArqF3 :="SW4" ; cCampoF3:="W4_PGI_NUM"
   cQual  :=OemtoAnsi(STR0041) //"N§ do P.G.I."
   cTitulo+=STR0006 //"P.G.I."
   bValid :={||TR120PGI()}
Else
   cArqF3 :="SYI" ; cCampoF3:="YI_PAGI_NU"
   cQual  :=OemtoAnsi(STR0042) //"N§ do P.A.G.I."
   cTitulo+="P.A.G.I."
   bValid :={||TR120PAGI()}
Endif

DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 To 18,40 OF GetWndDefault()

@ 1.4,0.8 SAY cQual

IF TEscolha = 1
   @ 1.4,6.0 MSGET TCOD_PGI  F3 cArqF3 PICTURE _PictPGI  SIZE 40,10 VALID (lValid:=EVAL(bValid))
ELSE
   @ 1.4,6.0 MSGET TCOD_PAGI F3 cArqF3 PICTURE _PictPAGI SIZE 40,10 VALID (lValid:=EVAL(bValid))
ENDIF

ACTIVATE MSDIALOG oDlg ON INIT ;
         EnchoiceBar(oDlg,{||nOpca:=1,If(lValid .OR. EVAL(bValid),;
                                         oDlg:End(),)},;
                          {||nOpca:=0,oDlg:End()}) CENTERED

Return (nOpca <> 0)
*----------------------------------------------------------------------------
FUNCTION TR120PGI()
*----------------------------------------------------------------------------
IF EMPTY(TCOD_PGI)
   Help("",1,"AVG0000616") //'N£mero do P.G.I. nÆo preenchido'###"Informação"
   Return .F.
ENDIF

DBSELECTAREA("SW4")
DBSETORDER(1)
IF ! DBSEEK(xFilial()+TCOD_PGI)
   Help("",1,"AVG0000618") //'N£mero do P.G.I. nÆo cadastrado'###"Informação"
   Return .F.
ENDIF

/*
IF W4_FLUXO = "1" .AND. W4_PORTASN = "S"   // Portaria 15.
   SW5->(DBSEEK(xFilial()+TCod_PGI))
   IF ! SW7->(DBSEEK(SW5->W5_FILIAL+SW5->W5_PO_NUM))
*     MsgInfo('PROCESSO NAO EMBARCADO (PORTARIA 15)',1000,.T.)
      LOOP
   ENDIF
ENDIF
*/

IF W4_FLUXO = "5"
   _Altera := .F.
ENDIF

IF .NOT. RecLock("SW4",.F.)
   SW4->(MsUnlock())
   Return .T.
ENDIF

TSuframa   := SW4->W4_SUFRAMA
TID_DEPIN  := "N"
TCod_PGI2  := SW4->W4_PGI_NUM
*TDt_E_DEPIN:= SW4->W4_DTE_DEP
*TDt_S_DEPIN:= SW4->W4_DTS_DEP
*TProtocolo := SW4->W4_DEP_PRO
*TCAP       := SW4->W4_CAP
TDt_E_DECEX:= SW4->W4_DTEDCEX
TDt_S_DECEX:= SW4->W4_DTSDCEX
TNum_GI    := SW4->W4_GI_NUM
TDt_GI     := SW4->W4_DT
TValidade  := SW4->W4_DT_VEN
*TProrr     := SW4->W4_PRORR    // "pega" conteudo GIPRORR qdo Tescolha=1
TCusto     := SW4->W4_CUSTOEM
TObs       := SW4->W4_OBS
TNum_GI2   := SW4->W4_GI_NUM
TDt_Sufr   := SW4->W4_DT_SUFR
TAverb_No  := SW4->W4_AVERBNO
TAverb_Dt  := SW4->W4_AVERBDT
Return .T.
*----------------------------------------------------------------------------
FUNCTION TR120PAGI()
*----------------------------------------------------------------------------
IF EMPTY(TCOD_PAGI)
   Help("",1,"AVG0000658")//'N£mero do P.A.G.I. nÆo preenchido'###"Informação"
   Return .F.
ENDIF

DBSELECTAREA("SYI")
DBSETORDER(1)
IF ! DBSEEK(xFilial()+TCOD_PAGI)
   Help("",1,"AVG0001000")//'N£mero do P.A.G.I. nÆo cadastrado'###"Informação"
   Return .F.
ENDIF

IF .NOT. RecLock("SYI",.F.)
   SYI->(MsUnlock())
   Return .T.
ENDIF

SW4->(DBSETORDER(2))
IF SW4->(DBSEEK(SYI->YI_FILIAL+SYI->YI_GI_NUM))
   TSuframa  := SW4->W4_SUFRAMA
ELSE
   TSuframa  := " "
ENDIF
SW4->(DBSETORDER(1))

TID_DEPIN   := "N"
TCod_PAGI2  := SYI->YI_PAGI_NU
*TDt_E_DEPIN := SYI->YI_DTE_DEP
*TDt_S_DEPIN := SYI->YI_DTS_DEP
*TProtocolo  := SYI->YI_DEP_PRO
*TCAP        := SYI->YI_CAP
TDt_E_DECEX := SYI->YI_DTEDCEX
TDt_S_DECEX := SYI->YI_DTSDCEX
TNum_GI     := SYI->YI_AGI_NUM
TDt_GI      := SYI->YI_AGI_DT
TValidade   := IF( ! EMPTY(SYI->YI_AGI_VEN),SYI->YI_AGI_VEN,SW4->W4_DT_VEN)
TCusto      := SYI->YI_CUSTOEM
TObs        := SYI->YI_OBS
TNum_AGI2   := SYI->YI_AGI_NUM
TDt_Sufr    := SYI->YI_DT_SUFR
Return .T.
*----------------------------------------------------------------------------
FUNCTION TR120Atu(bMsg)
*----------------------------------------------------------------------------
Local _PictPAGI := ALLTRIM(X3Picture("W4_PGI_NUM"))
Local _PictGI := ALLTRIM(X3Picture("W4_GI_NUM"))
Local _PictItem := ALLTRIM(X3Picture("B1_COD"))
Local _PictPGI := ALLTRIM(X3Picture("W4_PGI_NUM")),I
IF TEscolha = 1
   IF TNum_GI <> TNum_GI2
/*    DBSELECTAREA("SYI")
      DBSETORDER(2)
      IF DBSEEK(xFilial()+TNum_GI2)
         RecLock("SYI",.F.)
         REPLACE YI_GI_NUM WITH TNum_GI
         DBUNLOCK()
      ENDIF       */
   ENDIF
   DBSELECTAREA("SW4")
   RecLock("SW4",.F.)
   REPLACE  W4_PGI_NUM  WITH  TCod_PGI2   ,;
            W4_DTEDCEX  WITH  TDt_E_DECEX ,;
            W4_DTSDCEX  WITH  TDt_S_DECEX ,;
            W4_GI_NUM   WITH  TNum_GI     ,;
            W4_DT       WITH  TDt_GI      ,;
            W4_DT_VEN   WITH  TValidade   ,;
            W4_OBS      WITH  TObs        ,;
            W4_DT_SUFR  WITH  TDt_Sufr    ,;
            W4_CUSTOEM  WITH  TCusto      ,;
            W4_AVERBNO  WITH  TAverb_No   ,;
            W4_AVERBDT  WITH  IF(!EMPTY(TAverb_No),TAverb_Dt,AVCTOD(""))
//          W4_CAP      WITH  TCAP        ,;
//          W4_DTS_DEP  WITH  TDt_S_DEPIN ,;
//          W4_DTE_DEP  WITH  TDt_E_DEPIN ,;
//          W4_DEP_PRO  WITH  TProtocolo  ,;
ELSE
/* DBSELECTAREA("SYI")
   RecLock("SYI",.F.)
   REPLACE  YI_PAGI_NU   WITH  TCod_PAGI2  ,;
            YI_DTEDCEX   WITH  TDt_E_DECEX ,;
            YI_DTSDCEX   WITH  TDt_S_DECEX ,;
            YI_AGI_NUM   WITH  TNum_GI     ,;
            YI_AGI_DT    WITH  TDt_GI      ,;
            YI_AGI_VEN   WITH  TValidade   ,;
            YI_DT_SUFR   WITH  TDt_Sufr    ,;
            YI_OBS       WITH  TObs        ,;
            YI_CUSTOEM   WITH  TCusto           */
//          YI_CAP       WITH  TCAP        ,;
//          YI_DTS_DEP   WITH  TDt_S_DEPIN ,;
//          YI_DTE_DEP   WITH  TDt_E_DEPIN ,;
//          YI_DEP_PRO   WITH  TProtocolo  ,;

ENDIF
DBCOMMIT()
MSUNLOCK()

IF TEscolha = 1
   Ind := 1
   IF TCod_PGI <> TCod_PGI2 .OR. TNum_GI <> TNum_GI2
      DBSELECTAREA("SW5")
      DBSETORDER(1)
      DBSEEK(xFilial()+TCod_PGI)
&&sol0794   Ind = 1

      DO WHILE .NOT. EOF()

         Eval(bMsg,STR0047+TRAN(W5_COD_I,_PictItem)) //"Atualizando Guia - Ötem "

         IF W5_PGI_NUM <> TCod_PGI
            EXIT
         ENDIF
         DBSKIP()
         TRECNO := RECNO()
         DBSKIP(-1)

         RecLock("SW5",.F.)
         MPO_NUM:=W5_PO_NUM
         IF ASCAN(TabPO_Num,MPO_NUM) = 0
            TabPO_Num[Ind]:= MPO_NUM
            Ind:= Ind + 1
         ENDIF

         REPLACE W5_PGI_NUM  WITH TCod_PGI2
         MSUNLOCK()
         DBGOTO(TRECNO)
      ENDDO
      DBCOMMIT()

      DBSELECTAREA("SW3")
      DBSETORDER(2)
      DBSEEK(xFilial()+TCod_PGI)

      DO WHILE .NOT. EOF()

         Eval(bMsg,STR0048+TRAN(W3_COD_I,_PictItem)) //"Atualizando Pedido - Ötem "

         IF W3_PGI_NUM <> TCod_PGI
            EXIT
         ENDIF
         DBSKIP()
         TRECNO := RECNO()
         DBSKIP(-1)

         RecLock("SW3",.F.)
         REPLACE W3_PGI_NUM  WITH TCod_PGI2
         MsUnlock()
         DBGOTO(TRECNO)
         DBCOMMIT()
      ENDDO

      DBSELECTAREA("SWE")
      DBSEEK(xFilial()+TCod_PGI)
*     Ind = 1

      DO WHILE .NOT. EOF()

         Eval(bMsg,STR0049+TRAN(WE_COD_I,_PictItem)) //"Atualizando Guia Aprovada - Ötem "

         IF WE_PGI_NUM <> TCod_PGI
            EXIT
         ENDIF
         DBSKIP()
         TRECNO := RECNO()
         DBSKIP(-1)

         RecLock("SWE",.F.)
         MPO_NUM:=WE_PO_NUM
         IF ASCAN(TabPO_Num,MPO_NUM) = 0
            TabPO_Num[Ind]:= MPO_NUM
            Ind:= Ind + 1
         ENDIF

         REPLACE WE_PGI_NUM  WITH TCod_PGI2
         SWE->(MsUnlock())
         DBGOTO(TRECNO)
      ENDDO
      DBCOMMIT()
   ENDIF

ELSEIF TEscolha = 2
         Ind := 1
         IF TCod_PAGI <> TCod_PAGI2  .OR. TNum_GI <> TNum_AGI2
            DBSELECTAREA("SW4")
            DBSETORDER(2)
//          DBSEEK(SYI->YI_FILIAL+SYI->YI_GI_NUM)
            DBSELECTAREA("SW5")
            DBSETORDER(1)
            DBSEEK(SW4->W4_FILIAL+SW4->W4_PGI_NUM)
&&sol0794   Ind = 1

            DO WHILE .NOT. EOF()

               Eval(bMsg,STR0047+TRAN(W5_COD_I,_PictItem)) //"Atualizando Guia - Ötem "

               IF W5_PGI_NUM <> SW4->W4_PGI_NUM
                  EXIT
               ENDIF
               MPO_NUM:=W5_PO_NUM
               IF ASCAN(TabPO_Num,MPO_NUM) = 0
                  TabPO_Num[Ind]:= MPO_NUM
                  Ind:= Ind + 1
               ENDIF
               DBSKIP()
            ENDDO
         ENDIF
ENDIF																						   	

TDesc1 := SPACE(60)
TDesc2 := SPACE(60)

IF TEscolha = 1
   IF TCod_PGI <> TCod_PGI2
      TDesc1 := STR0050+TRANS(TCod_PGI,_PictPGI)+STR0051+TRANS(TCod_PGI2,_PictPGI) //"NUMERO DO P.G.I. "###" ALTERADO PARA "
   ENDIF
   IF TNum_GI <> TNum_GI2
      TDesc2 := STR0052+TRANS(TNum_GI,_PictGI) //"NUMERO DA G.I. "
   ENDIF
ELSEIF TEscolha = 2
   IF TCod_PAGI <> TCod_PAGI2
      TDesc1 := STR0053+TRANS(TCod_PAGI,_PictPAGI)+STR0051+TRANS(TCod_PAGI2,_PictPAGI) //"NUMERO DO P.A.G.I. "###" ALTERADO PARA "
   ENDIF
   IF TNum_GI <> TNum_AGI2
      TDesc2 := STR0054+TRANS(TNum_GI,_PictGI) //"NUMERO DO A.G.I. "
   ENDIF
ENDIF

FOR I = 1 TO Ind

    IF TEscolha = 2
       I := Ind + 1
       LOOP
    ENDIF

    IF EMPTY(TabPO_Num[I])
       LOOP
    ENDIF

    IF .NOT. EMPTY(TDesc1)
        Grava_Ocor(TabPO_Num[I],dDataBase,TDesc1)
    ENDIF

    IF .NOT. EMPTY(TDesc2)
        Grava_Ocor(TabPO_Num[I],dDataBase,TDesc2)
    ENDIF

    DBSELECTAREA("SW7")
    DBSEEK(xFilial()+TabPo_Num[I])

    DO WHILE .NOT. EOF() .AND. W7_PO_NUM = TabPo_Num[I]

       Eval(bMsg,STR0055+TRAN(W7_COD_I,_PictItem)) //"Atualizando D.I. - Ötem "

       IF TCod_PGI <> W7_PGI_NUM .OR. EMPTY(W7_PGI_NUM)
          DBSKIP() ; LOOP
       ENDIF

       RecLock("SW7",.F.)
       REPLACE W7_PGI_NUM WITH TCod_PGI2
       SW7->(MsUnlock())
       DBSKIP()
    ENDDO

NEXT
*----------------------------------------------------------------------------
* FIM DO PROGRAMA TR120
*----------------------------------------------------------------------------
