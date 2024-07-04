//#INCLUDE "FiveWin.ch"
#include "Average.ch"
#INCLUDE "EICDO120.ch"

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ EICDO120 ≥ Autor ≥ AVERAGE/A.W.R.        ≥ Data ≥ 13/03/98 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Consulta de despesas                                       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function EICDO120
LOCAL oRad
LOCAL cCadastro:=OemtoAnsi(STR0001) //"Consulta de Despesas"
PRIVATE aOpcoes:={OemtoAnsi(STR0002) ,; //"1 - Por N£mero do Documento      "
                  OemtoAnsi(STR0003) ,; //"2 - Por Referància do Despachante"
                  OemtoAnsi(STR0004) ,; //"3 - Por No Conhecimento          "
                  OemtoAnsi(STR0005) }  //"4 - Por C¢digo do Despachante    "

PRIVATE nOpcao :=1, oDlg, nOldArea :=SELECT()

// aRotina declarada apenas para compatibilizar com GetDadDB

PRIVATE aRotina := { { STR0006       , "AxPesqui"  , 0 , 1} ,; //"Pesquisar"
                      { STR0007	      , "C210Impor" , 0 , 2} ,; //"Atual"
                      { STR0008	      , "C210Impor" , 0 , 3} }  //"Todos"

// definir sempre - inicio

PRIVATE cMarca := GetMark(), lInverte := .F.

PRIVATE cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,;
        CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999

Private aHeader[0],nUsado:=0, aCampos:={}, Valor[0], nOpcA:=0

nOpcao:=1

bCampo  := {|nCPO| Field(nCPO) }

// definir sempre - fim

DEFINE MSDIALOG oDlg TITLE cCadastro From 6,11 To 15,60 OF oMainWnd

@ 09,05 TO 60,125 LABEL "" OF oDlg PIXEL

@ 14,11 RADIO oRad VAR nOpcao ITEMS aOpcoes[1],aOpcoes[2],aOpcoes[3],;
                                    aOpcoes[4] 3D SIZE 105,10 PIXEL

DEFINE SBUTTON FROM 14,150 TYPE 1 ACTION (DO120Get()) ENABLE OF oDlg
DEFINE SBUTTON FROM 28,150 TYPE 2 ACTION (oDlg:End()) ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg

DBSELECTAREA(nOldArea)

RETURN NIL


*--------------------------------*
FUNCTION DO120Get()
*--------------------------------*
LOCAL nCol   :=0
LOCAL Titulo :=ALLTRIM(SUBSTR(aOpcoes[nOpcao],9))
LOCAL cTexto1:=ALLTRIM(SUBSTR(aOpcoes[nOpcao],9))+" : "
LOCAL cTexto2:=STR0028 //"Data Pgto Inicial:"
LOCAL cTexto3:=STR0009 //"Data Pgto Final:"
PRIVATE TCod, dInicial:=dFinal:=AVCTOD(" ")

oDlg:disable()

DEFINE MSDIALOG oDlg1 TITLE Titulo From 14,32 To 22,76  OF oMainWnd

@ 13,10 SAY oSayCod VAR cTexto1 SIZE 90,10 OF oDlg1 PIXEL
@ 27,10 SAY oSayCod VAR cTexto2 SIZE 90,10 OF oDlg1 PIXEL
@ 41,10 SAY oSayCod VAR cTexto3 SIZE 90,10 OF oDlg1 PIXEL

DO CASE

   CASE nOpcao = 1    // Numero de Documento.

        TCod:=E_TRAN("WD_DOCTO","SWD")
        cArqF3:="" ; nCol:=73

   CASE nOpcao = 2    // Referencia de Despachante.

        TCod:=E_TRAN("W6_REF_DES","SW6")
        cArqF3:=""  ; nCol:=83

   CASE nOpcao = 3    // Conhecimento

        TCod:=E_TRAN("W6_HAWB","SW6")
        cArqF3:="SW6" ; nCol:=62

   CASE nOpcao = 4    // Codigo do Despachante.

        TCod:=E_TRAN("Y5_COD","SY5")
        cArqF3:="SY5"  ; nCol:=76



ENDC

@ 13,nCol MSGET TCod     F3 cArqF3 SIZE 40,9 OF oDlg1 PIXEL
@ 27,nCol MSGET dInicial           SIZE 40,9 OF oDlg1 PIXEL
@ 41,nCol MSGET dFinal             SIZE 40,9 OF oDlg1 PIXEL

DEFINE SBUTTON FROM 13,136 TYPE 1 ACTION (IF(DO120Valid(),(oDlg1:End(),DO120Proces()),)) ENABLE OF oDlg1
DEFINE SBUTTON FROM 30,136 TYPE 2 ACTION (oDlg1:End())                     ENABLE OF oDlg1

ACTIVATE MSDIALOG oDlg1

RETURN .T.

*------------------------------*
FUNCTION DO120Valid()
*------------------------------*
DO CASE

   CASE nOpcao = 1    // Numero de Documento.

        IF EMPTY(TCod)
           Help("", 1, "AVG0000285")//MSGINFO(OemToAnsi(STR0010),OemToAnsi(STR0011)) //"N£mero do documento n∆o preenchido "###"Informaá∆o"
           RETURN .F.
        ENDIF

   CASE nOpcao = 2    // Referencia de Despachante.

        IF EMPTY(TCod)
           Help("", 1, "AVG0000286")//MSGINFO(OemToAnsi(STR0012),OemToAnsi(STR0013))//"Referencia do despachante n∆o preenchida "###"Informaá∆o"
           RETURN .F.
        ENDIF


   CASE nOpcao = 3    // Conhecimento.

        IF EMPTY(TCod)
           Help("", 1, "AVG0000287")//MSGINFO(OemToAnsi(STR0014),OemToAnsi(STR0015))//"No. Conhecimento n∆o preenchido "###"Informaá∆o"
           RETURN .F.
        ENDIF

        IF ! SWD->(DBSEEK(xFilial("SWD")+TCod))
           Help("", 1, "AVG0000288")//MSGINFO(OemToAnsi(STR0016),OemToAnsi(STR0017))//"No. Conhecimento n∆o cadastrado "###"Informaá∆o"
           RETURN .F.
        ENDIF


   CASE nOpcao = 4    // Codigo do Despachante.

        IF EMPTY(TCod)
           Help("", 1, "AVG0000289")//MSGINFO(OemToAnsi(STR0018),OemToAnsi(STR0019)) //"C¢digo do despachante n∆o preenchido"###"Informaá∆o"
           RETURN .F.
        ENDIF

        IF ! SY5->(DBSEEK(xFilial("SY5")+TCod))
           Help("", 1, "AVG0000290")//MSGINFO(OemToAnsi(STR0020),OemToAnsi(STR0021))//"C¢digo do despachante n∆o cadastrado"###"Informaá∆o"
           RETURN .F.
        ENDIF

ENDCASE

IF EMPTY(dInicial)
   dInicial := AVCTOD("01/01/1900")
ENDIF

IF EMPTY(dFinal)
   dFinal := AVCTOD("31/12/2999")
ENDIF

IF dFinal < dInicial
   Help("", 1, "AVG0000291")//MSGINFO(STR0022,OemToAnsi(STR0023))//"Data final menor que data inicial"###"Informaá∆o"
   RETURN .F.
ENDIF

RETURN .T.

*-----------------------------------------------------*
FUNCTION DO120Proces()
*-----------------------------------------------------*
LOCAL Titulo :=ALLTRIM(SUBSTR(aOpcoes[nOpcao],9)),CAMPO1:="",CAMPO2:="" ,I
LOCAL aDados :={"TRB",;
                "",;
                "",;
                "",;
                "G",;
                80,;
                "",;
                "",;
                Titulo,;
                { STR0024, 1,STR0025, 2, 2, 1, "",1 },;//"Zebrado"###"Importaá∆o"
                "EICdo120",;
                { {|| .T. } , {|| .T. }  }  }, nOpcA:=1

PRIVATE aHeader:={}, aCampos:={}, aRcampos:={}
PRIVATE aRotina := { { STR0026       , "AxPesqui"  , 0 , 1} } //"Pesquisar"


#DEFINE   CARACTER   IF(nOpcao=1,'WD_DOCTO' ,IF(nOpcao=2,'W6_REF_DES',IF(nOpcao=3,'W6_HAWB','W6_DESP')))
#DEFINE   CAMPO      IF(nOpcao=1, WD_DOCTO  ,IF(nOpcao=2, W6_REF_DES ,IF(nOpcao=3, W6_HAWB , W6_DESP )))

ASIZE(aRCampos,0)
ASIZE(aHeader,0)
ASIZE(aCampos,0)

AADD(aCampos,CARACTER)

IF nOpcao=4
   AADD(aCampos,"Y5_NOME")
ENDIF

IF ASCAN(aCampos, {|cCampo| cCampo=="WD_DOCTO" }) = 0
   AADD(aCampos,"WD_DOCTO")
ENDIF

AADD(aCampos,"WD_DES_ADI")
AADD(aCampos,"WD_DESPESA")
AADD(aCampos,"YB_DESCR")
AADD(aCampos,"WD_VALOR_R")

IF ASCAN(aCampos, {|cCampo| cCampo=="W6_DESP" }) = 0
   AADD(aCampos,"W6_DESP")
ENDIF

IF ASCAN(aCampos, {|cCampo| cCampo=="W6_REF_DES" }) = 0
   AADD(aCampos,"W6_REF_DES")
ENDIF

IF ASCAN(aCampos, {|cCampo|cCampo=="W6_HAWB" }) = 0
   AADD(aCampos,"W6_HAWB")
ENDIF

FileWork:=E_CriaTrab()


FOR I := 1 TO LEN(aCampos)
    CAMPO2+=" - "+aCampos[I]
NEXT


E_CriaCampos(aRCampos)

FOR I := 1 TO LEN(aRCampos)
    CAMPO1+=" - "+aRCampos[I][1]
    CAMPO1+=" / "+aRCampos[I][2]
    CAMPO1+=" / "+aRCampos[I][3]
NEXT

IndRegua("TRB",FileWork+TEOrdBagExt(),CARACTER+'+DTOS(WD_DES_ADI)')



Processa({||DO120GravaWork()})

E_SayLeadT(Titulo,,,aDados,aRCampos,,aCampos,.F.)

TRB->(E_EraseArq(FileWork,FileWork))

DBSELECTAREA(nOldArea)

RETURN .T.

*----------------------------------------------*
FUNCTION DO120GravaWork()
*----------------------------------------------*

SWD->(DBGOTOP())
TRB->(avzap())

IF nOpcao = 3
   SWD->(DBSEEK(xFilial("SWD")+TCod))
ENDIF

ProcRegua(SWD->(LASTREC()))

WHILE ! SWD->(EOF()) .AND. IF(nOpcao=3, SWD->WD_HAWB==TCod, .T.)

   SW6->(DBSEEK(xFilial("SW6")+SWD->WD_HAWB))

   IncProc(STR0027) //'Lendo dados das Despesas'

   IF nOpcao = 1  .AND.  SWD->WD_DOCTO # TCod
      SWD->(DBSKIP())
      LOOP
   ENDIF

   IF nOpcao = 2  .AND.  SW6->W6_REF_DES # TCod
      SWD->(DBSKIP())
      LOOP
   ENDIF

   IF nOpcao = 3  .AND.  SWD->WD_HAWB # TCod
      SWD->(DBSKIP())
      LOOP
   ENDIF

   IF nOpcao = 4  .AND.  SW6->W6_DESP # TCod
      SWD->(DBSKIP())
      LOOP
   ENDIF

   IF SWD->WD_DES_ADI < dInicial .OR. SWD->WD_DES_ADI > dFinal
      SWD->(DBSKIP())
      LOOP
   ENDIF

   SY5->(DBSEEK(xFilial("SY5")+SW6->W6_DESP))
   SYB->(DBSEEK(xFilial("SYB")+SWD->WD_DESPESA))

   TRB->(DBAPPEND())
   TRB->W6_HAWB     := SW6->W6_HAWB
   TRB->WD_DESPESA  := SWD->WD_DESPESA
   TRB->YB_DESCR    := SYB->YB_DESCR
   TRB->Y5_NOME     := SY5->Y5_NOME
   TRB->WD_DOCTO    := SWD->WD_DOCTO
   TRB->WD_VALOR_R  := SWD->WD_VALOR_R
   TRB->WD_DES_ADI  := SWD->WD_DES_ADI
   TRB->W6_REF_DES  := SW6->W6_REF_DES
   TRB->W6_DESP     := SW6->W6_DESP

   SWD->(DBSKIP())

END


RETURN .T.


*----------------------------------------------------------------------------*
*     FIM DO PROGRAMA EICDO120
*----------------------------------------------------------------------------*
