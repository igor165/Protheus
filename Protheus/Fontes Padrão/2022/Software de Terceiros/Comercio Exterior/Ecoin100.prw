#INCLUDE "Ecoin100.ch"
#include "Average.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ECOIN100 ³ Autor ³ VICTOR IOTTI          ³ Data ³ 26.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Integracao Easy / Contabil e Rel. de Critica               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAECO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*----------------------------*
Function ECOIN101(aParametros)
*----------------------------*
// ** AAF 07/01/08 - Execucao da Transferencia de dados da Contabilidade por Agendamento
Local lScheduled := aParametros <> NIL

If lScheduled
   AvPreAmb(aParametros)
   ConOut("["+DToC(Date()) + " " + Time()+"] "+"Transferencia de dados da Contabilidade Importação - Easy Accounting")
EndIf
// **

ECOIN100(lScheduled, 1)

Return .T.

*---------------------*
Function ECOIN100(pAgendamento, pOpc)
*---------------------*
LOCAL aOpcoes:={ STR0001,; //"Transferencia dos dados para Contabilidade"
                 STR0002,; //"Relatorio de critica da integracao        "
                 STR0003} //"Resumo das Observacoes da Integracao      "
LOCAL oDlg, ITEMS, oRad1, nVolta, nOpcao:=1
LOCAL cOldAlias:=Alias()
// ** AAF 07/01/08 - Execucao por Agendamento
Default pOpc         := 1
Default pAgendamento := .F.

nOpcao := pOpc
Private lScheduled := pAgendamento
Private aMessages  := {}
// **

EC5->(DBSETORDER(1))
SA2->(DBSETORDER(1))
ECC->(DBSETORDER(1))
EC2->(DBSETORDER(1))
EC8->(DBSETORDER(1))
  
If ! EasyEntryPoint("ECOIV20A")
   AvE_MSG(STR0004,1) //"Rdmake de grava‡„o dos arquivos tempor rios n„o encontrado.(ECOIV20A)"
   Return .F.
EndIf

If ! EasyEntryPoint("ECOIV20B")
   AvE_MSG(STR0005,1) //"Rdmake de grava‡„o dos arquivos tempor rios n„o encontrado.(ECOIV20B)"
   Return .F.
EndIf  

If ! EasyEntryPoint("ECOCR20A")
   AvE_MSG(STR0006,1) //"Rdmake de leitura dos arquivos tempor rios n„o encontrado.(ECOCR20A)"
   Return .F.
EndIf

If ! EasyEntryPoint("ECOCR20B")
   AvE_MSG(STR0007,1) //"Rdmake de leitura dos arquivos tempor rios n„o encontrado.(ECOCR20B)"
   Return .F.
EndIf

If ! EasyEntryPoint("ECOCR20C")
   AvE_MSG(STR0008,1) //"Rdmake de leitura dos arquivos tempor rios n„o encontrado.(ECOCR20C)"
   Return .F.
EndIf

Do While .t.

   If !lScheduled //AAF 07/01/08 - Execucao por agendamento
      DEFINE MSDIALOG oDlg FROM  9,10 TO 19,60 TITLE STR0009 of oMainWnd //"Integracao Contabil"
   
      @  6, 10 TO 65, 150 LABEL STR0010    OF oDlg  PIXEL //"Seleção"
   
      nVolta = 0
      @ 20,16 RADIO oRad1 VAR nOpcao ITEMS aOpcoes[1],aOpcoes[2],aOpcoes[3] 3D SIZE 115,12 PIXEL
   
      DEFINE SBUTTON FROM 17,163 TYPE 1 ACTION (nVolta:=1,oDlg:End()) ENABLE OF oDlg PIXEL
      DEFINE SBUTTON FROM 47,163 TYPE 2 ACTION (oDlg:End()) ENABLE OF oDlg PIXEL
   
      ACTIVATE MSDIALOG oDlg CENTERED
   
      If nVolta#1
         Exit
      Endif
   EndIf

   If nOpcao == 1
      If lScheduled .OR. SimNao(STR0011,STR0012,,,,STR0012)="S" //"Confirma a Integra‡„o ? "###"Questão ?"###""Integração" ###""Integração"    // GFP - 23/11/2011
         lLe:=.T.
         If lScheduled .OR. SimNao(STR0013,STR0012,,,,STR0012)="S" //"Lˆ dados da Importa‡„o ? "###"Questão ?"###""Integração" ###"Integração"  // GFP - 23/11/2011
            lLe:=ExecBlock("ECOIV20A")
         EndIf
         If lLe
            If ! ExecBlock("ECOCR20A")
               AvE_MSG(STR0014,1) //"Arquivo de atualiza‡„o dos dados para a contabilidade n„o foi bem sucedido, integra‡„o interrompida."
            EndIf
         Else
            AvE_MSG(STR0015,1) //"Arquivo de grava‡„o dos arquivos tempor rios n„o foi bem sucedido, integra‡„o interrompida."
         EndIf
      EndIf
   ElseIf nOpcao == 2
      ECOCR150()
   Else
      ECORESUMO()
   Endif
   
   If !Empty(cOldAlias) //AAF 07/01/08
      DBSELECTAREA(cOldAlias)
   EndIf
   
   //** AAF 08/01/08 - Execucao por Schedule
   If lScheduled
      EXIT
   EndIf
   //**

Enddo

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ECORESUMO³ Autor ³ VICTOR IOTTI          ³ Data ³ 08.12.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Resumo da Integracao Easy / Contabil                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*-----------------*
Function ECORESUMO
*-----------------*
LOCAL oDlgResumo, oFont1
mMemo:=''
//IF FILE('MemoCTB.INT')
IF FILE('MemoCTB.MEM')
//   restore from ('MemoCTB.INT') additive
   restore from ('MemoCTB.MEM') additive
EndIf
DEFINE MSDIALOG oDlgResumo TITLE STR0016 From 7,2 To 26,78 OF oMainWnd //"Resumo das Observacoes da Integracao"
DEFINE FONT oFont1 NAME "Courier New" SIZE 0,14
oDlgResumo:SetFont(oFont1)
@ 06.5,03 GET mMemo MEMO HSCROLL READONLY SIZE 295,120 OF oDlgResumo PIXEL
DEFINE SBUTTON FROM 130,140 TYPE 1 ACTION (oDlgResumo:End()) ENABLE OF oDlgResumo PIXEL
ACTIVATE MSDIALOG oDlgResumo
Return .T.


*--------------------------*
FUNCTION IV200VALID(cCampo) //Usado no SX1 EICIV2
*--------------------------*
dIniEncerra := mv_par01
dFimEncerra := mv_par02
cImport1    := mv_par03
cImport2    := mv_par04
cImport3    := mv_par05
cImport4    := mv_par06

IF cCampo == "*" .Or. cCampo == "DTINI"
   IF dIniEncerra > dFimEncerra
      AvE_MSG( STR0017, 1000, .T. ) //"DATA INICIAL MAIOR QUE A DATA FINAL - TECLE <ENTER>"
      RETURN IF(cCampo=="*",.F.,.T.)
   ENDIF
ENDIF

IF cCampo == "*" .Or. cCampo== "DTFIM"
   IF EMPTY( dFimEncerra )
      mv_par02 :=  dFimEncerra := AVCTOD( '31/12/99' )
   ENDIF

   IF dIniEncerra > dFimEncerra
      AvE_MSG( STR0017, 1000, .T. ) //"DATA INICIAL MAIOR QUE A DATA FINAL - TECLE <ENTER>"
      RETURN IF(cCampo=="*",.F.,.T.)
   ENDIF
ENDIF

IF cCampo == "*" .Or. cCampo== "IMPOR1"
   IF !EMPTY(cImport1)
      IF  ! SYT->(DbSeek(xFilial()+cImport1))
          AvE_MSG(STR0018,100) //"IMPORTADOR NAO CADASTRADO - REENTRE"
          RETURN IF(cCampo=="*",.F.,.T.)
      ENDIF
   ENDIF
ENDIF

IF cCampo == "*" .Or. cCampo== "IMPOR2"
   IF !EMPTY(cImport2)
      IF ! SYT->(DbSeek(xFilial()+cImport2))
         AvE_MSG(STR0018,100) //"IMPORTADOR NAO CADASTRADO - REENTRE"
         RETURN IF(cCampo=="*",.F.,.T.)
      ENDIF
   ENDIF
ENDIF

IF cCampo == "*" .Or. cCampo== "IMPOR3"
   IF !EMPTY(cImport3)
      IF ! SYT->(DbSeek(xFilial()+cImport3))
         AvE_MSG(STR0018,1000) //"IMPORTADOR NAO CADASTRADO - REENTRE"
         RETURN IF(cCampo=="*",.F.,.T.)
      ENDIF
   ENDIF
ENDIF

IF cCampo == "*" .Or. cCampo== "IMPOR4"
   IF !EMPTY(cImport4)
      IF ! SYT->(DbSeek(xFilial()+cImport4))
         AvE_MSG(STR0018,1000) //"IMPORTADOR NAO CADASTRADO - REENTRE"
         RETURN IF(cCampo=="*",.F.,.T.)
      ENDIF
   ENDIF
ENDIF

IF cCampo == "*" .And. Empty(cImport1+cImport2+cImport3+cImport4)
   Help(" ",1,"AVG0005322") //E_Msg(AnsiToOem(STR0019),1000) //"Não há importadores selecionado !"
   RETURN .F.
ENDIF

RETURN .T.
