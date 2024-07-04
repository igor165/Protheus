#INCLUDE "Eicpo560.ch"
//#include "FiveWin.ch"
#include "AVERAGE.CH"
#include "avprint.ch"

#COMMAND E_RESET_AREA => SA5->(DBSETORDER(1)) ;
                       ; DBSELECTAREA(nOldArea)

#xtranslate :TIMES_NEW_ROMAN_12            => \[1\]
#xtranslate :COURIER_12                    => \[2\]
#xtranslate :TIMES_NEW_ROMAN_14_BOLD       => \[3\]
#xtranslate :TIMES_NEW_ROMAN_14_UNDERLINE  => \[4\]
#xtranslate :TIMES_NEW_ROMAN_12_UNDERLINE  => \[5\]
#xtranslate :TIMES_NEW_ROMAN_12_BOLD       => \[6\]

#DEFINE     DATA_ATUAL  SUBSTR(DTOC(dDataBase),1,2)  + "/" + ;
                        SUBSTR(CMONTH(dDataBase),1,3)+ "/" + ;
                        IF(IsYear4(),Right(DtoC(dDataBase),4),;
                                     Right(DtoC(dDataBase),2))

#DEFINE     DATA_EMB    SUBSTR(DTOC(dUltEmb),1,2) + STR0001 + ; //" de "
                        NOME_MES(MONTH(dUltEmb)) + STR0001 + ; //" de "
                        IF(IsYear4(),Right(Dtoc(dUltEmb),4),;
                                     Right(Dtoc(dUltEmb),2))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICPO560 ³ Autor ³ VICTOR IOTTI          ³ Data ³ 29.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Emiss„o de Informacao de Processo de Importacao            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICPO560()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICPO560()

LOCAL nOldArea:=SELECT(), cSaveMenuh, nCnt

LOCAL cTitulo, oGet, nOpcA:=0, lValid

LOCAL aValid:={'PO'}

LOCAL bValid:={||lValid:=.T.,;
                 AEval(aValid,{|campo| If(lValid,lValid:=PO560Val(campo,.T.),)}),;
                 lValid}

PRIVATE cCadastro := OemtoAnsi(STR0002) //"Emiss„o de Informa‡„o de Processo de Importa‡„o"

PRIVATE cMarca := GetMark(), lInverte := .F., MAbandona:= .F., MPos

PRIVATE cArqF3SW2:="SW2", cCampoF3SW2:="W2_PO_NUM", cFileMen

PRIVATE TPO_Num:=SW2->W2_PO_NUM, TImport:=SW2->W2_IMPORT

PRIVATE TCondPg:=SW2->W2_COND_PA, TDiasPg:=SW2->W2_DIAS_PA, TTipo_Emb:=SW2->W2_TIPO_EM

PRIVATE TAgente:=IIF(!EMPTY(SW2->W2_FORWARD), SW2->W2_FORWARD, SW2->W2_AGENTE )

PRIVATE TBancoLC:=spac(45), TBancoRep:=spac(45), cEndRemes:=spac(60), cEndComis:=spac(60)

PRIVATE dUltEmb:=dDataBase, cPeriodoDoc:=spac(25)

PRIVATE cCarta:=STR0003, cShip:=STR0004, cConf:=STR0003, cTranShip:=STR0004 //"Sim"###"ALLOWED"###"Sim"###"ALLOWED"

PRIVATE oDlg, nLinha, cCaymanFo, mValCart:=spac(50), oMemo, TPO_NumAnt

PRIVATE oPrn, cDespesas:=STR0005 //"Todas as despesas por conta do consignatario."
Private _PictPrTot := ALLTRIM(X3Picture("W2_FOB_TOT")), _PictPO := ALLTRIM(X3Picture("W2_PO_NUM"))

bCampo  := {|nCPO| Field(nCPO) }

cPicImp:=ALLTRIM(X3Picture("W2_IMPORT"))
cPicPgc:=ALLTRIM(X3Picture("W2_COND_PA"))
cPicPgd:=ALLTRIM(X3Picture("W2_DIAS_PA"))
cPicAge:=ALLTRIM(X3Picture("W2_AGENTE"))

SA5->(DBSETORDER(3))

WHILE .T.

  DEFINE MSDIALOG oDlg TITLE cCadastro From 7,0 To 35,80 OF oMainWnd
  
  oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 17/07/2015
  oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

  nLin:=18

  PO560Say()

  PO560Get(.T.)

  DEFINE SBUTTON FROM 160,115 TYPE 6 ACTION (Processa({|lEnd| PO560_REL()})) ENABLE OF oPanel
  @ 160,185 BUTTON STR0006 SIZE 34,11 FONT oDlg:oFont ACTION (AV_ESC_OBS('6')) OF oPanel PIXEL //"Mensagens"

  ACTIVATE MSDIALOG oDlg ON INIT ;
           EnchoiceBar(oDlg,{||nOpca:=1,If(EVAL(bValid),oDlg:End(),)},;
                            {||nOpca:=0,oDlg:End()}) CENTERED

  If nOpca = 0
     IF SELECT("WORK_MEN") # 0
        Work_Men->(E_ERASEARQ(cFileMen))
     ENDIF
     E_RESET_AREA
     Return .F.
  Endif

ENDDO

*----------------------------------------------------------------------------
FUNCTION PO560Say(lShow)
*----------------------------------------------------------------------------
@ 16 ,8     SAY OemToAnsi(STR0007)  SIZE 40,8 OF oPanel PIXEL //"N§ do P.O."
@ 16 ,120   SAY STR0008             SIZE 40,8 OF oPanel PIXEL //"Importador"
@ 16 ,184   SAY STR0009             SIZE 50,8 OF oPanel PIXEL  //"Terms of Payment"
@ 16 ,265   SAY '/'                 SIZE  5,8 OF oPanel PIXEL
@ 31 ,8     SAY STR0010             SIZE 40,8 OF oPanel PIXEL //"Forwarder"
@ 31 ,96    SAY OemToAnsi(STR0011)  SIZE 40,8 OF oPanel PIXEL //"Carta de Cr‚dito"
@ 31 ,208   SAY OemToAnsi(STR0012)  SIZE 40,8 OF oPanel PIXEL //"Confirmada"
@ 48 ,8     SAY OemToAnsi(STR0013)  SIZE 40,8 OF oPanel PIXEL //"Banco L/C"
@ 48 ,160   SAY OemToAnsi(STR0014)  SIZE 50,8 OF oPanel PIXEL //"Banco Comiss„o"
@ 61 ,8     SAY OemToAnsi(STR0015)  SIZE 40,8 OF oPanel PIXEL //"Endereco"
@ 61 ,160   SAY OemToAnsi(STR0016)  SIZE 65,8 OF oPanel PIXEL //"Ultima Data de Embarque"
@ 74 ,8     SAY OemToAnsi(STR0017)  SIZE 95,8 OF oPanel PIXEL //"Per¡odo p/ a Apresenta‡„o de Doctos"
@ 87 ,8     SAY OemToAnsi(STR0018)  SIZE 40,8 OF oPanel PIXEL //"Despesas"
@ 101 ,8    SAY OemToAnsi(STR0019)  SIZE 55,8 OF oPanel PIXEL //"Partial Shipmentes"
@ 101 ,144  SAY OemToAnsi(STR0020)  SIZE 40,8 OF oPanel PIXEL //"Transhipments"
@ 120,8     SAY OemToAnsi(STR0021)  SIZE 50,8 OF oPanel PIXEL //"Cond. Pagamento"
@ 132,8     SAY OemToAnsi(STR0022)  SIZE 40,8 OF oPanel PIXEL //"Valor da Carta"
RETURN NIL
*----------------------------
FUNCTION PO560Get(lGet)
*----------------------------
TBancoLC   :=spac(45)
TBancoRep  :=spac(45)
cEndRemes  :=spac(60)
cEndComis  :=spac(60)
mValCart   :=spac(50)
cCaymanFo  :=spac(50)
cDespesas  :=STR0005 //"Todas as despesas por conta do consignatario."
cPeriodoDoc:=spac(25)
dUltEmb    :=dDataBase
cCarta     :=STR0003 //"Sim"
cShip      :=STR0004 //"ALLOWED"
cConf      :=STR0003 //"Sim"
cTranShip  :=STR0004 //"ALLOWED"
TPO_NumAnt :=TPO_Num

@ 16,56  MSGET TPO_Num F3 cArqF3SW2 PICTURE _PictPO ;
                       WHEN lGet VALID PO560Val('PO') SIZE 40,8 OF oPanel PIXEL

@ 16,152 MSGET TImport PICTURE cPicImp WHEN .F. SIZE 10,8 OF oPanel  PIXEL

@ 16,232 MSGET TCondPg PICTURE cPicPgc WHEN .F. SIZE 22,8 OF oPanel  PIXEL

@ 16,272 MSGET TDiasPg PICTURE cPicPgd WHEN .F. SIZE 10,8 OF oPanel  PIXEL

@ 31,56  MSGET TAgente PICTURE cPicAge WHEN .F. SIZE 10,8 OF oPanel  PIXEL

@ 29,144 COMBOBOX cCarta ITEMS {STR0003,OemToAnsi(STR0023)} SIZE 50,30 OF oPanel PIXEL //"Sim"###"NÆo"

@ 29,240 COMBOBOX cConf  ITEMS {STR0003,OemToAnsi(STR0023)} SIZE 50,30 OF oPanel PIXEL //"Sim"###"NÆo"

@ 48,56  MSGET TBancoLC WHEN lGet SIZE 100,8 OF oPanel  PIXEL

@ 48,208 MSGET TBancoRep WHEN lGet SIZE 100,8 OF oPanel PIXEL

@ 61,56  MSGET cEndRemes WHEN lGet SIZE 100,8 OF oPanel PIXEL

@ 61,224 MSGET dUltEmb WHEN lGet SIZE 40,8 OF oPanel    PIXEL

@ 74,104 MSGET cPeriodoDoc WHEN lGet SIZE 160,8 OF oPanel PIXEL

@ 87,56  MSGET cDespesas  WHEN lGet SIZE 180,8 OF oPanel  PIXEL

@ 100,56  COMBOBOX cShip ITEMS {STR0004,STR0024} SIZE 60,30 OF oPanel PIXEL //"ALLOWED"###"NOT ALLOWED"

@ 100,200 COMBOBOX cTranShip ITEMS {STR0004,STR0024} SIZE 60,30 OF oPanel PIXEL //"ALLOWED"###"NOT ALLOWED"

@ 120,56 MSGET cCaymanFo WHEN .F. SIZE 180,8 OF oPanel PIXEL

@ 132,56 GET  oMemo Var mValCart MEMO WHEN lGet SIZE 180,23 OF oPanel PIXEL
RETURN NIL
*----------------------------------------------------------------------------
FUNCTION PO560Val(MFlag)
*----------------------------------------------------------------------------
Do Case
   Case MFlag = 'PO'
        IF EMPTY(TPO_Num)
           Help("", 1, "AVG0000465")//MSGINFO(OemToAnsi(STR0025),OemToAnsi(STR0026)) //"N£mero do P.O. deve ser preenchido"###"Informa‡Æo"
           Return .F.
        Endif

        DBSELECTAREA("SW2")

        IF TPO_NumAnt # TPO_Num
           TPO_NumAnt :=TPO_Num
           cCarta     :=STR0003 //"Sim"
           cConf      :=STR0003 //"Sim"
           cShip      :=STR0004 //"ALLOWED"
           cTranShip  :=STR0004 //"ALLOWED"
           TBancoLC   :=spac(45)
           TBancoRep  :=spac(45)
           cEndRemes  :=spac(60)
           cEndComis  :=spac(60)
           cDespesas  :=STR0005 //"Todas as despesas por conta do consignatario."
           mValCart   :=spac(50)
           cPeriodoDoc:=spac(25)
           dUltEmb    :=dDataBase
           cCaymanFo  :=spac(50)
        ENDIF

        IF !SW2->(DBSEEK(xFilial("SW2")+TPO_Num))
           Help("", 1, "AVG0000466")//MSGINFO(OemToAnsi(STR0027),OemToAnsi(STR0026)) //"N£mero do P.O. nÆo cadastrado"###"Informa‡Æo"
           Return .F.
        Endif

        SW3->(DBSEEK(xFilial("SW3")+TPO_Num))
        IF SW3->W3_FLUXO = "5"
           Help("", 1, "AVG0000466")//MSGINFO(OemToAnsi(STR0027),OemToAnsi(STR0026)) //"N£mero do P.O. nÆo cadastrado"###"Informa‡Æo"
           Return .F.
        Endif

        TImport  := SW2->W2_IMPORT
        TCondPg  := SW2->W2_COND_PA
        TDiasPg  := SW2->W2_DIAS_PA
        TAgente  := IIF(!EMPTY(SW2->W2_FORWARD), SW2->W2_FORWARD, SW2->W2_AGENTE )
        TTipo_Emb:= SW2->W2_TIPO_EM

        IF ! SYT->(DBSEEK(xFilial("SYT")+TImport))
           Help("", 1, "AVG0000467")//MSGINFO(OemToAnsi(STR0028),OemToAnsi(STR0026)) //"C¢digo do Importador nÆo cadastrado"###"Informa‡Æo"
           RETURN .F.
        ENDIF

        IF ! SY6->(DBSEEK(xFilial("SY6")+TCondPg))
           Help("", 1, "AVG0000468")//MSGINFO(OemToAnsi(STR0029),OemToAnsi(STR0026)) //"Condi‡Æo de Pagamento nÆo cadastrada"###"Informa‡Æo"
           RETURN .F.
        ENDIF

        IF ! SY4->(DBSEEK(xFilial("SY4")+TAgente))
           Help("", 1, "AVG0000469")//MSGINFO(OemToAnsi(STR0030),OemToAnsi(STR0026)) //"Agente nÆo cadastrado"###"Informa‡Æo"
           RETURN .F.
        ENDIF

        IF ! SYQ->(DBSEEK(xFilial("SYQ")+TTipo_Emb))
           Help("", 1, "AVG0000470")//MSGINFO(OemToAnsi(STR0031),OemToAnsi(STR0026)) //"Via de Transporte nÆo cadastrada"###"Informa‡Æo"
           RETURN .F.
        ENDIF

        SA2->(DBSEEK(xFILIAL("SA6")+SW2->W2_FORN))

        IF ! EMPTY(ALLTRIM(SA2->A2_BANCO)) .AND. ! EMPTY(ALLTRIM(SA2->A2_AGENCIA))
           SA6->(DBSEEK(xFILIAL("SA6")+SA2->A2_BANCO+SA2->A2_AGENCIA))
           IF EMPTY(ALLTRIM(TBancoLC))
              TBancoLC:=ALLTRIM(SA6->A6_NOME)+SPACE(ABS(LEN(ALLTRIM(SA6->A6_NOME))-45))
           ENDIF
           IF EMPTY(ALLTRIM(cEndRemes))
              cEndRemes:=ALLTRIM(SA6->A6_END)+SPACE(ABS(LEN(ALLTRIM(SA6->A6_NOME))-60))
           ENDIF
        ENDIF

        IF ! EMPTY(ALLTRIM(SA2->A2_REPR_BA)) .AND. ! EMPTY(ALLTRIM(SA2->A2_REPR_AG))
           SA6->(DBSEEK(xFILIAL("SA6")+SA2->A2_REPR_BA+SA2->A2_REPR_AG))
           IF EMPTY(ALLTRIM(TBancoRep))
              TBancoRep:=ALLTRIM(SA6->A6_NOME)+SPAC(ABS(LEN(ALLTRIM(SA6->A6_NOME))-45))
           ENDIF
           IF EMPTY(ALLTRIM(cEndComis))
              cEndComis:=ALLTRIM(SA6->A6_END)+SPACE(ABS(LEN(ALLTRIM(SA6->A6_NOME))-60))
           ENDIF
        ENDIF

        IF EMPTY(ALLTRIM(mValCart))
           mValCart:=SW2->W2_MOEDA+' '+ALLTRIM(TRANS(SW2->W2_FOB_TOT+SW2->W2_INLAND+;
           SW2->W2_PACKING+SW2->W2_FRETEIN-SW2->W2_DESCONT,_PictPrTot))
        ENDIF

        IF EMPTY(ALLTRIM(cCaymanFo))
           SY6->(DBSEEK(xFILIAL("SY6")+SW2->W2_COND_PA+STR(SW2->W2_DIAS_PA,3,0)))
           cCaymanFo:=ALLTRIM(MSMM(SY6->Y6_DESC_I,50,,,3))
        ENDIF

ENDCASE
oMemo:Refresh()
*oDlg:Refresh()
Return .T.

*-----------------*
FUNCTION PO560_REL()
*-----------------*
LOCAL oFont1, oFont2, oFont3, oFont4, oFont5, oFont6, mAux, mAux2
LOCAL cAux,cAux1,cAux2,cAux3,aVetor, nAux, cAlias
LOCAL lExistExp:=.F.
LOCAL I          := 0,;
      nAux1      := 0,;
      nAux2      := 0,;
      W          := 0
PRIVATE aFontes

AVPRINT oPrn NAME OemtoAnsi(STR0032) //"Informa‡„o de Processo de Importa‡„o (I.P.I.)"

   ProcRegua(12)

   DEFINE FONT oFont1  NAME "Times New Roman"  SIZE 0,12                  OF oPrn
   DEFINE FONT oFont2  NAME "Courier"          SIZE 0,12                  OF oPrn
   DEFINE FONT oFont3  NAME "Times New Roman"  SIZE 0,14  BOLD            OF oPrn
   DEFINE FONT oFont4  NAME "Times New Roman"  SIZE 0,14  BOLD UNDERLINE  OF oPrn
   DEFINE FONT oFont5  NAME "Times New Roman"  SIZE 0,12       UNDERLINE  OF oPrn
   DEFINE FONT oFont6  NAME "Times New Roman"  SIZE 0,12  BOLD            OF oPrn

   aFontes := { oFont1, oFont2, oFont3, oFont4, oFont5, oFont6 }

   AVPAGE

        nLinha := 100
        PO560CAB()

        mAux:=''
        IF !EMPTY(SW2->W2_EXPORTA)
           SY6->(DBSEEK(xFILIAL()+SW2->W2_COND_EX+STR(SW2->W2_DIAS_EX,3,0)))
           mAux := MSMM(SY6->Y6_DESC_I)
           lExistExp:=.T.
        ENDIF
        SY6->(DBSEEK(xFILIAL()+SW2->W2_COND_PA+STR(SW2->W2_DIAS_PA,3,0)))
        mAux2 := MSMM(SY6->Y6_DESC_I)

        IncProc(STR0033) //"Imprimindo..."
        oPrn:Box( nLinha+=120, 110  , (nLinha+IF(lExistExp,170,80)+(50*IF(EMPTY(mAux),1,MLCOUNT(mAux,50)))+(50*IF(EMPTY(mAux2),1,MLCOUNT(mAux2,50)))), 2300 )
        oPrn:Say( nLinha+=20 , 170  , STR0034,aFontes:TIMES_NEW_ROMAN_12_UNDERLINE ) //"CONDICAO DE PAGAMENTO"

        IF lExistExp
           oPrn:Say( nLinha+=100, 170  , STR0035,aFontes:TIMES_NEW_ROMAN_12_UNDERLINE ) //"DA UNIDADE P/ EXPORTADOR:"
           FOR I=1 TO MLCOUNT(mAux,50)
               oPrn:Say( nLinha , 810  , MEMOLINE(mAux,50,I),aFontes:TIMES_NEW_ROMAN_12 )
               nLinha+=50
           NEXT

           oPrn:Say( nLinha+=50 , 170  , STR0036,aFontes:TIMES_NEW_ROMAN_12_UNDERLINE ) //"DO EXPORTADOR P/ FORNECEDOR:"
           FOR I=1 TO MLCOUNT(mAux2,50)
               oPrn:Say( nLinha , 920  , MEMOLINE(mAux2,50,I),aFontes:TIMES_NEW_ROMAN_12 )
               nLinha+=50
           NEXT
        ELSE
           nLinha+=50
           FOR I=1 TO MLCOUNT(mAux2,50)
               oPrn:Say( nLinha , 170  , MEMOLINE(mAux2,50,I),aFontes:TIMES_NEW_ROMAN_12 )
               nLinha+=50
           NEXT
        ENDIF
        IncProc(STR0033) //"Imprimindo..."
        oPrn:oFont := aFontes:TIMES_NEW_ROMAN_12
        oPrn:Box( nLinha+=120, 110  , nLinha+70, 2300 )
        oPrn:Say( nLinha+=10 , 170  , (STR0037+TRANS(SW2->W2_PO_NUM,_PictPO)),aFontes:TIMES_NEW_ROMAN_12_BOLD ) //"NUMERO DE PO:  "
        oPrn:Say( nLinha     , 2000 , DATA_ATUAL,aFontes:TIMES_NEW_ROMAN_12_BOLD)

        oPrn:Box( nLinha+=120, 110 , nLinha+70, 2300 )

        IF cCarta=STR0003 //"Sim"
           cAux:='X'
           cAux1:=' '
        ELSE
           cAux:=' '
           cAux1:='X'
        ENDIF

        IF cCarta <> STR0003 //"Sim"
           cAux2:=''
           cAux3:=''
        ELSE
           IF cConf=STR0003 //"Sim"
              cAux2:='X'
              cAux3:=' '
           ELSE
              cAux2:=' '
              cAux3:='X'
           ENDIF
        ENDIF

        IncProc(STR0033) //"Imprimindo..."
        oPrn:Say( nLinha+=10 , 170 , STR0038+cAux+" ) SIM  ( "+cAux1+STR0039+cAux2+STR0040+cAux3+STR0041,aFontes:COURIER_12 ) //"CARTA DE CREDITO:( "###" ) NAO  CONFIRMADA:( "###" ) SIM  ( "###" ) NAO"

        IncProc(STR0033) //"Imprimindo..."
        oPrn:oFont := aFontes:TIMES_NEW_ROMAN_12
        oPrn:Say( nLinha+=120, 170  , STR0042 ) //"EMBARQUE"
        oPrn:Box( nLinha+=50 , 110  , nLinha+200, 2300 )

        SY9->(DBSETORDER(2))
        SY9->(DBSEEK(xFilial("SY9")+SW2->W2_ORIGEM))
        oPrn:Say( nLinha+=20 , 170  , STR0043 ) //"DE:"
        oPrn:Say( nLinha     , 470  , SW2->W2_ORIGEM+" "+SY9->Y9_DESCR )

        SY9->(DBSEEK(xFilial("SY9")+SW2->W2_DEST))
        oPrn:Say( nLinha+=50 , 170  , STR0044 ) //"PARA:"
        oPrn:Say( nLinha     , 470  , SW2->W2_DEST+" "+SY9->Y9_DESCR)
        SY9->(DBSETORDER(1))
        oPrn:Say( nLinha+=50 , 170  , STR0045 ) //"INCOTERMS:"
        oPrn:Say( nLinha     , 470  , SW2->W2_INCOTER+' '+SW2->W2_COMPL_I,aFontes:TIMES_NEW_ROMAN_12_BOLD )

        IncProc(STR0033) //"Imprimindo..."

        SA2->(DBSEEK(xFILIAL("SA2")+SW2->W2_FORN))

        IF ! EMPTY(ALLTRIM(SW2->W2_LC_NUM))
           oPrn:Say( nLinha+=120, 170  , STR0046) //"BANCO PARA A ABERTURA / CONFIRMACAO"
        ELSE
           oPrn:Say( nLinha+=120, 170  , STR0047) //"BANCO PARA A REMESSA"
        ENDIF
        oPrn:Say( nLinha     , 1310 , STR0048) //"BANCO PARA A COMISSAO DE AGENTE"
        oPrn:Box( nLinha+=50 , 110  , nLinha+250, 2300 )
        oPrn:Box( nLinha     , 1300 , nLinha+250, 1301 )
        oPrn:Say( nLinha+=20 , 170  , TBancoLC )
        oPrn:Say( nLinha     , 1310 , TBancoRep )
        oPrn:Say( nLinha+=50 , 170  , SA2->A2_NUMCON )
        oPrn:Say( nLinha     , 1310 , LEFT(cEndComis,40) )
        oPrn:Say( nLinha+=50 , 170  , LEFT(cEndRemes,40) )
        oPrn:Say( nLinha     , 1310 , RIGHT(cEndComis,20) )
        oPrn:Say( nLinha+=50 , 170  , RIGHT(cEndRemes,20) )

        IncProc(STR0033) //"Imprimindo..."
        nLinha+=120
        IF (nLinha+(4*50)+80) >= 2900
           nLinha:=4444
        ENDIF
        PO560VERFIM(0,(4*50)+80)
        nAux1:=(nLinha+(4*50)+80)
        oPrn:Say( nLinha     , 170  , STR0049 ) //"BENEFICIARIO"
        oPrn:Box( nLinha+=50 , 110  , nAux1, 2300 )
        PO560VERFIM(4)
        oPrn:Say( nLinha+=20 , 170  , SA2->A2_NOME,aFontes:TIMES_NEW_ROMAN_12_BOLD )
        PO560VERFIM(3)
        oPrn:Say( nLinha+=50 , 170  , ALLTRIM(SA2->A2_END)+', '+ALLTRIM(SA2->A2_NR_END),aFontes:TIMES_NEW_ROMAN_12_BOLD )
        PO560VERFIM(2)
        oPrn:Say( nLinha+=50 , 170  , ALLTRIM(SA2->A2_MUN)+' - '+ALLTRIM(SA2->A2_BAIRRO)+' - '+ALLTRIM(SA2->A2_ESTADO),aFontes:TIMES_NEW_ROMAN_12_BOLD )
        IF ! EMPTY(ALLTRIM(SA2->A2_CEP))
           PO560VERFIM(1)
           oPrn:Say( nLinha+=50 , 170  , TRANS(SA2->A2_CEP,'@R 99999-999'),aFontes:TIMES_NEW_ROMAN_12_BOLD )
        ELSE
           nLinha+=50
        ENDIF

        IncProc(STR0033) //"Imprimindo..."
        nLinha+=120
/*      IF (nLinha+(6*50)+80) >= 2900
           nLinha:=4444
        ENDIF*/
        PO560VERFIM(0,(6*50)+80)
        nAux1:=(nLinha+(6*50)+80)
        oPrn:Say( nLinha     , 170  , STR0050 ) //"VALIDADES:"
        oPrn:Box( nLinha+=50 , 110  , nAux1, 2300 )
        PO560VERFIM(6)
        oPrn:Say( nLinha+=20 , 170  , STR0051 ,aFontes:TIMES_NEW_ROMAN_12_BOLD ) //"ULTIMA DATA DE EMBARQUE: "
        IF ! EMPTY(dUltEmb)
           oPrn:Say( nLinha  , 900  , DATA_EMB,aFontes:TIMES_NEW_ROMAN_12_BOLD )
        ENDIF
        PO560VERFIM(5)
        oPrn:Say( nLinha+=50 , 170  , STR0052 ) //"PERIODO PARA A APRESENTACAO DE DOCUMENTOS: "
        oPrn:Say( nLinha     , 1350 , cPeriodoDoc ,aFontes:TIMES_NEW_ROMAN_12_BOLD )
        PO560VERFIM(4)
        oPrn:Say( nLinha+=50 , 170  , STR0053 ) //"DESPESAS: "
        oPrn:Say( nLinha     , 400  , cDespesas ,aFontes:TIMES_NEW_ROMAN_12_BOLD)
        PO560VERFIM(3)
        oPrn:Say( nLinha+=50 , 170  , STR0054) //"UNIDADE REQUISITANTE: "

        SYT->(DBSEEK(xFilial("SYT")+SW2->W2_IMPORT))
        oPrn:Say( nLinha     , 800  , SYT->YT_NOME ,aFontes:TIMES_NEW_ROMAN_12_BOLD)
        PO560VERFIM(2)
        oPrn:Say( nLinha+=50 , 800  , SYT->YT_ENDE ,aFontes:TIMES_NEW_ROMAN_12_BOLD )
        PO560VERFIM(1)
        oPrn:Say( nLinha+=50 , 800  , ALLTRIM(SYT->YT_CIDADE)+' - '+ALLTRIM(SYT->YT_ESTADO)+' - '+ALLTRIM(SYT->YT_PAIS),aFontes:TIMES_NEW_ROMAN_12_BOLD )

        PO560VERFIM(0)
        nLinha+=120
        W := 2 + IF(EMPTY(ALLTRIM(mValCart)),1,MLCOUNT(ALLTRIM(mValCart),40))
/*      IF (nLinha+(W*50)+50) >= 2900
           nAux1:=3100
        ELSE
           nAux1:=(nLinha+(W*50)+50)
        ENDIF*/

        PO560VERFIM(0,((W*50)+50))
        nAux1:=(nLinha+(W*50)+50)
        oPrn:Box( nLinha     , 110  , nAux1, 2300 )
        PO560VERFIM(nAux1-1)
        IncProc(STR0033) //"Imprimindo..."
        oPrn:Say( nLinha+=20 , 170  , STR0055+ALLTRIM(SW2->W2_DES_IPI) ) //"DESCRICAO DA MERCADORIA: "
        PO560VERFIM(nAux1-2)
        oPrn:Say( nLinha+=50 , 170  , STR0056 ) //"COMISSAO DE AGENTE: "
        PO560VERFIM(nAux1-3)
        IF !SW2->W2_COMIS $ cSim
           oPrn:Say( nLinha     ,680  ,STR0057,aFontes:TIMES_NEW_ROMAN_12_BOLD) //"*** NAO HA ***"
        ELSE
           IF SW2->W2_TIP_COM = '1'
              oPrn:Say( nLinha     ,680 , TRANS(SW2->W2_PER_COM,"@E 9,999.99")+'%',aFontes:TIMES_NEW_ROMAN_12_BOLD )
           ELSEIF SW2->W2_TIP_COM $ '2,3'
              oPrn:Say( nLinha     ,680 , SW2->W2_MOEDA+' '+TRANS(SW2->W2_VAL_COM,"@E 9,999,999,999.9999"),aFontes:TIMES_NEW_ROMAN_12_BOLD )
           ELSEIF SW2->W2_TIP_COM = '4'
              oPrn:Say( nLinha     ,680 , SW2->W2_OUT_COM,aFontes:TIMES_NEW_ROMAN_12_BOLD )
           ENDIF
        ENDIF

***     oPrn:Say( nLinha+=50 , 170  , STR0058 ) //"PAGAMENTO ANTECIPADO: "
***     oPrn:Say( nLinha     , 750  , cPag_Antec,aFontes:TIMES_NEW_ROMAN_12_BOLD )

        PO560VERFIM(nAux1-4)
        oPrn:Say( nLinha+=50 , 170  , STR0059+IF(cCarta=="Sim",STR0060,"")+STR0061+ALLTRIM(SW2->W2_INCOTER)+".:" ) //"VALOR"###" DA CARTA"###" EM "
        oPrn:Say( nLinha     , 750  , Memoline(mValCart,40,1) )
        FOR W=2 TO Mlcount(mValCart,40)
            IF ! Empty(Memoline(mValCart,40,W))
               PO560VERFIM(nAux1-(W+3))
               oPrn:Say( nLinha+=50 , 750  , Memoline(mValCart,40,W) )
            ENDIF
        NEXT
*       oPrn:Say( nLinha     , 700  , TRANS(SW2->W2_FOB_TOT+;
*                                          SW2->W2_INLAND+;
*                                          SW2->W2_PACKING+;
*                                          SW2->W2_FRETEIN-;
*                                          SW2->W2_DESCONT,_PictPrTot),;
*                                    aFontes:TIMES_NEW_ROMAN_12_BOLD)

        SW3->(DBSEEK(xFilial("SW3")+SW2->W2_PO_NUM))
        aVetor:={}
        DO WHILE ! SW3->(EOF()) .AND. SW3->W3_FILIAL==xFilial("SW3") .AND. SW3->W3_PO_NUM=SW2->W2_PO_NUM
           IF SW3->W3_SEQ <> 0
              SW3->(DBSKIP()) ; LOOP
           ENDIF
           nAux:=ASCAN(aVetor,{|x| x[1] = SW3->W3_DT_EMB })
           IF nAux = 0
              AADD(aVetor,{SW3->W3_DT_EMB,VAL(TRANS(SW3->W3_QTDE*SW3->W3_PRECO,'999999999999.99'))})
           ELSE
              aVetor[nAux,2]+=VAL(TRANS(SW3->W3_QTDE*SW3->W3_PRECO,'999999999999.99'))
           ENDIF
           SW3->(DBSKIP())
        ENDDO

        nLinha+=120
/*      IF (nLinha+(LEN(aVetor)*50)+50) >= 2900
           nAux1:=3100
        ELSE
           nAux1:=(nLinha+(LEN(aVetor)*50)+170)
        ENDIF*/

        IncProc(STR0033) //"Imprimindo..."
        PO560VERFIM(0,((LEN(aVetor)*50)+IF(lExistExp,220,70)))
        nAux1:=(nLinha+(LEN(aVetor)*50)+IF(lExistExp,220,70))
        oPrn:Box( nLinha     , 110  , nAux1, 2300 )
        PO560VERFIM(LEN(aVetor)+4)
        oPrn:Say( nLinha+=20 , 170  , STR0062,aFontes:TIMES_NEW_ROMAN_12_UNDERLINE ) //"OBSERVACOES:"

        IF ! EMPTY(SW2->W2_EXPORTA)
           PO560VERFIM(LEN(aVetor)+3)
           SA2->(DBSEEK(xFilial("SA2")+SW2->W2_EXPORTA))
           PO560VERFIM(LEN(aVetor)+2)
           oPrn:Say( nLinha+=50 ,170 , ALLTRIM(SA2->A2_NOME))
           PO560VERFIM(LEN(aVetor)+1)
           oPrn:Say( nLinha+=50 ,170 , ALLTRIM(SA2->A2_END)+', '+ALLTRIM(SA2->A2_NR_END)+' - '+ALLTRIM(SA2->A2_BAIRRO))
           oPrn:Say( nLinha+=50 ,170 , ALLTRIM(SA2->A2_MUN)+' - '+ALLTRIM(SA2->A2_ESTADO))
        ENDIF

        IF LEN(aVetor) # 0
           ASORT(aVetor,,,{|x,y| x[1] < y[1]})
           PO560VERFIM(LEN(aVetor))
           oPrn:Say( nLinha+=50 , 170  , STR0063+TRANS(LEN(aVetor),'@E 99,999')+STR0064) //"NUMERO DE EMBARQUES: "###"  DE "
           FOR I=1 TO LEN(aVetor)
              PO560VERFIM(LEN(aVetor)-I)
              oPrn:Say( nLinha ,  920, DTOC(aVetor[I,1]))
              oPrn:Say( nLinha , 1150, SW2->W2_MOEDA)
              oPrn:Say( nLinha , 1600, TRANS(aVetor[I,2],"@E 9,999,999,999.9999"),,,,,1)
              nLinha+=50
           NEXT
        ENDIF
        ASIZE(aVetor,0)
        nLinha+=50

        IF cCarta == "Sim"

           PO560VERFIM(0,165)

           oPrn:Box( nLinha , 110 , nLinha+165, 2300 )
           IF cShip=STR0004 //"ALLOWED"
              cAux:='X'
              cAux1:=' '
           ELSE
              cAux:=' '
              cAux1:='X'
           ENDIF
           IncProc(STR0033) //"Imprimindo..."

           oPrn:Say( nLinha+=20 , 170  , STR0065+cAux+" ) ALLOWED   ( "+cAux1+" ) NOT ALLOWED", aFontes:COURIER_12 ) //"PARTIAL SHIPMENTS     ( "
/*         nLinha+=120

           PO560VERFIM(0,100)
           oPrn:Box( nLinha     , 110  , nLinha+100, 2300 )*/
           IF cTranShip=STR0004 //"ALLOWED"
              cAux:='X'
              cAux1:=' '
           ELSE
              cAux:=' '
              cAux1:='X'
           ENDIF
           IncProc(STR0033) //"Imprimindo..."
           oPrn:Say( nLinha+=70 , 170  , STR0066+cAux+" ) ALLOWED   ( "+cAux1+" ) NOT ALLOWED", aFontes:COURIER_12 ) //"TRANSHIPMENTS         ( "
           nLinha+=100
        ENDIF
*       nLinha:=4444
        SYT->(DBSEEK(xFilial("SYT")+SW2->W2_IMPORT))
*       nLinha+=120
        PO560VERFIM(0,200)
        oPrn:Box( nLinha+=20 , 110  , nLinha+200, 2300 )
        PO560VERFIM(4)
        oPrn:Say( nLinha+=20, 170  , STR0067 ) //"IMPORTER.: "
        PO560VERFIM(3)
        oPrn:Say( nLinha     , 450  , SYT->YT_NOME ,aFontes:TIMES_NEW_ROMAN_12_BOLD)
        PO560VERFIM(2)
        oPrn:Say( nLinha+=50 , 450  , SYT->YT_ENDE ,aFontes:TIMES_NEW_ROMAN_12_BOLD )
        PO560VERFIM(1)
        oPrn:Say( nLinha+=50 , 450  , ALLTRIM(SYT->YT_CIDADE)+' - '+ALLTRIM(SYT->YT_ESTADO)+' - '+ALLTRIM(SYT->YT_PAIS),aFontes:TIMES_NEW_ROMAN_12_BOLD )

        IncProc(STR0033) //"Imprimindo..."
        nLinha+=120
        IF SELECT("WORK_MEN") # 0
           PO560VERFIM(0)
           oPrn:Say( nLinha, 120  , STR0068 ) //"DOCUMENTS REQUIRED:"
           nLinha+=50
           oPrn:oFont := aFontes:COURIER_12
           cAlias:=Alias()
           Work_Men->(DBGOTOP())
           DO WHILE ! Work_Men->(EOF()) .AND. Work_Men->WKORDEM<'zzzzz'
/*            nAux:=((MLCOUNT(RTRIM(Work_Men->WKOBS),70)*50)+50)
              IF (nLinha+nAux) > 3000
                 nAux := 4444
              ENDIF
              PO560VERFIM(0)*/
              nAux:=((MLCOUNT(RTRIM(Work_Men->WKOBS),70)*50)+50)
              PO560VERFIM(0,nAux)
              nAux := nLinha+nAux
              oPrn:Box( nLinha , 110 , nAux , 2300 )

              oPrn:Say( nLinha+=20, 170 , RTRIM(Memoline(Work_Men->WKOBS,70,1)))

              FOR W=2 TO MLCOUNT(Work_Men->WKOBS,70)
                  IF ! EMPTY(ALLTRIM(MEMOLINE(Work_Men->WKOBS,70,W)))
                     PO560VERFIM(MLCOUNT(RTRIM(Work_Men->WKOBS),70)-W+1)
                     oPrn:Say( nLinha+=50 , 170  , RTRIM(Memoline(Work_Men->WKOBS,70,W)))
                  ENDIF
              NEXT
              Work_Men->(DBSKIP())
              nLinha+=50
           ENDDO
           DBSELECTAREA(cAlias)
           nLinha+=100
        ENDIF

        PO560VERFIM(0,300)
        oPrn:Box( nLinha , 110 , (nLinha+300) , 2300 ) //150
        SY1->(DBSEEK(xFilial("SY1")+SW2->W2_COMPRA))
        oPrn:Say( nLinha+=20 , 125 , STR0069 ) //"SIGNATURES"
        cAux:= ALLTRIM(EasyGParam("MV_CHEFEIM"))+spac(4)+'/'+spac(4)+ALLTRIM(SY1->Y1_NOME)
        oPrn:Say( nLinha+=200 , 2300 , cAux,aFontes:TIMES_NEW_ROMAN_12_BOLD,,,,1)

   AVENDPAGE

AVENDPRINT

oFont1:End()
oFont2:End()
oFont3:End()
oFont4:End()
oFont5:End()
oFont6:End()

RETURN NIL

*-------------------------------*
FUNCTION PO560CAB()
*-------------------------------*
oPrn:Box( nLinha , 400 , nLinha+160, 2000 )
oPrn:Say( nLinha+=20 , 1200 , STR0070, aFontes:TIMES_NEW_ROMAN_14_BOLD,,,,2 ) //"INFORMACAO DE PROCESSO DE IMPORTACAO"
oPrn:Say( nLinha+=70 , 1200 , STR0071, aFontes:TIMES_NEW_ROMAN_14_BOLD,,,,2 ) //"I.P.I."
oPrn:Say( nLinha     , 2090 , STR0072+STRZERO(oPrn:nPage,2),aFontes:TIMES_NEW_ROMAN_12_BOLD ) //"PAGE "

*-------------------------------*
FUNCTION PO560VERFIM(nAux1,nBox)
*-------------------------------*
LOCAL aFonteAnt := oPrn:oFont
nBox:=IF(nBox==NIL,0,nBox)//para pular de pagina se nao tiver espaco p/ o box interio
IF (nLinha+nBox) > 3000
   AVNEWPAGE
   nLinha := 100
   PO560CAB()
   nLinha+=120
   IF nAux1 # 0
      oPrn:Box( nLinha+=20 , 110  , nLinha+(nAux1*50)+50, 2300 )
   ENDIF
ENDIF
oPrn:oFont := aFonteAnt
RETURN NIL
