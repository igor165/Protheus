#INCLUDE "Ecofp110.ch"
#include "AVERAGE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ECOFP110 ³ Autor ³ ALEX WALLAUER         ³ Data ³ 14/04/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Encerramento de DI's                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*----------------*
Function ECOFP110
*----------------*
LOCAL cOldAlias:=ALIAS(), nLin, nColS1, oDlg, oObj
LOCAL cTitulo:=STR0001 //"Consulta de Invoice / Processo / No. P.O."
Local oPanel //LRL 02/06/04
Local aButtons := {}
Local bOk      := {||nOpca:=1,oDlg:End()}
Local bCancel  := {||nOpca:=0,oDlg:End()}
Private bWhile:={||IF(nTipo=1,EC8->EC8_INVOIC,;
                   IF(nTipo=2,EC8->EC8_HAWB  ,;
                              EC8->EC8_PO_NUM))}
Private aCampoBrow:={;
        {"EC8_HAWB"  ,"", AVSX3("EC8_HAWB"   )[5], AVSX3("EC8_HAWB")[6]   },;  // GFP - 17/11/2011
        {"EC8_IDENTC","", AVSX3("EC8_IDENTC")[5], AVSX3("EC8_IDENTC")[6] },;
        {"EC8_PO_NUM","", AVSX3("EC8_PO_NUM")[5], AVSX3("EC8_PO_NUM")[6] },;
        {"EC8_FOB_PO","", AVSX3("EC8_FOB_PO")[5], AVSX3("EC8_FOB_PO")[6] }}

Private cFilEC8:=xFilial("EC8"),oGet,oSay

cEntrada:= SPACE(LEN(EC8->EC8_INVOIC))
cEntradaFor := SPACE(LEN(EC8->EC8_FORN))
cLitForn    := AVSX3("EC8_FORN")[5]

cLiteral:= AVSX3("EC8_INVOIC")[5]
cTipo   := STR0002 //"1 - Invoice"
nTipo   := 1 //Usado no SXB (consulta)
nLin    := 1.8
nColS1  := 1
//cMsg    := ""

DBSELECTAREA("EC8") ; EC8->(DBSETORDER(2))

DO WHILE .T.

   nOpca:=0

   DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 12,50/*45*/ OF oMainWnd

      @ nLin,nColS1 SAY STR0003 SIZE 40,8 OF oDlg //"Consutar por"

      @ nLin,nColS1+5 COMBOBOX cTipo ITEMS {STR0002,STR0004,STR0005}; //"1 - Invoice"###"2 - Processo"###"3 - P.O."
        SIZE 50,50 OF oDlg ON CHANGE (FP110_Troca_Get(cTipo))
        
      @ nLin+2,nColS1 SAY cLitForn SIZE 40,8 OF oDlg COLOR CLR_HBLUE

      @ nLin+2,nColS1+5 MSGET oGet Var cEntradaFor PICTURE "@!" F3 "SA2" ;
                           WHEN If(cTipo = "1", .T., .F.) SIZE 80,8 OF oDlg  

      @ nLin+4,nColS1 SAY oSay Var cLiteral SIZE 40,8 OF oDlg

      @ nLin+4,nColS1+5 MSGET oGet Var cEntrada PICTURE "@!" F3 "EC8" ;
                        SIZE 80,8 OF oDlg
      

   ACTIVATE MSDIALOG oDlg ON INIT ;
            EnchoiceBar(oDlg,{||IF(cTipo <> "1" , ,),;
                                IF(FP110_Valid(),(nOpca:=1,oDlg:End()),)},;
                             {||nOpca:=0,oDlg:End()}) CENTERED 
                             
                             
   IF nOpca = 0
      EXIT
   ENDIF

   IF EMPTY(cEntrada)
      EC8->(DBSEEK(xFilial("EC8")))
      cEntrada:=EVAL(bWhile)
   ENDIF
   
   //FSM - 18/11/2011
   aAdd(aButtons, {"S4WB016N", {|| HelProg() }             ,STR0008} )//"Help de Programa"
   aAdd(aButtons, {"S4WB00N",  {|| Calculadora() }         ,STR0007} )//"Calculadora"
   aAdd(aButtons, {"TOP",      {|| (nOpca:=6,oDlg:End()) } ,STR0009} )//"Primeiro"
   aAdd(aButtons, {"PREV",     {|| (nOpca:=3,oDlg:End()) } ,STR0010} )//"Anterior"
   aAdd(aButtons, {"NEXT",     {|| (nOpca:=4,oDlg:End()) } ,STR0011} )//"Proximo"
   aAdd(aButtons, {"BOTTOM",   {|| (nOpca:=5,oDlg:End()) } ,STR0012} )//"Ultimo"

   WHILE .T.

      nOpca:=0

      oMainWnd:ReadClientCoors()
      DEFINE MSDIALOG oDlg TITLE cTitulo ;
             FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 ;
               TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd PIXEL
         @00,00 MsPanel oPanel Prompt "" Size 20,30 of oDlg
         nLin    := 0.8
         @ nLin,nColS1 SAY cLiteral of oPanel

         @ nLin,(nColS1+5) MSGET cEntrada WHEN .F. SIZE 80,8 OF oPanel
         nLin    := 1.8
         oObj:=MsSelect():New("EC8",/*cCampo*/,/*cCpo*/,aCampoBrow,.T.,"X",{40,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2},"FP110_Filtro()","FP110_Filtro()",oDlg,/*uPar11*/,/*aColors*/)  //,.T.)  GFP - 17/11/2011
         oPanel:Align:=CONTROL_ALIGN_TOP //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
		 oObj:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
		 
      ACTIVATE MSDIALOG oDlg ON INIT ;
                        (EnchoiceBar(oDlg,bOk,bCancel,,aButtons) )
               /* //FSM - 18/11/2011
                 (FP110Bar(oDlg,{||nOpca:=1,oDlg:End()},;
                             {||nOpca:=0,oDlg:End()}),;
                  oPanel:Align:=CONTROL_ALIGN_TOP,;            //LRL
  
                  oObj:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT) //02/06/04             
				*/
      cFilEC8 := xFilial("EC8")
      DO CASE
        
         CASE nOpca = 3 //Anterior

              WHILE EC8->(!BOF()) .AND. If(cTipo = "1", EC8->EC8_FORN,"")+EVAL(bWhile)==If(cTipo = "1", cEntradaFor,"")+cEntrada .AND.;
                    EC8->EC8_FILIAL == cFilEC8
                 EC8->(DBSKIP(-1))
              ENDDO

              IF EC8->(BOF()) .OR. EC8->EC8_FILIAL # cFilEC8
//               EC8->(DBSEEK(cFilEC8,,.T.))//Protheus nao tem este parametro
                 EC8->(AVSeekLast(cFilEC8))//Ultimo registro da filial
//               cMsg:="NÆo h  mais registros anteriores ao atual"
              ENDIF

              cEntrada:=EVAL(bWhile)

              LOOP

         CASE nOpca = 4 //Proximo

              WHILE EC8->(!EOF()) .AND. If(cTipo = "1", EC8->EC8_FORN,"")+EVAL(bWhile)==If(cTipo = "1", cEntradaFor,"")+cEntrada .AND.;
                    EC8->EC8_FILIAL == cFilEC8
                 EC8->(DBSKIP())
              ENDDO

              IF EC8->(EOF()) .OR. EC8->EC8_FILIAL # cFilEC8
                 EC8->(DBSEEK(cFilEC8))
//               cMsg:="NÆo h  mais registros posteriores ao atual"
              ENDIF

              cEntrada:=EVAL(bWhile)

              LOOP

         CASE nOpca = 5 //Ultimo

//            EC8->(DBSEEK(cFilEC8,,.T.))//Ultimo registro da filial
              EC8->(AVSeekLast(cFilEC8))//Ultimo registro da filial

              cEntrada:=EVAL(bWhile)

              LOOP

         CASE nOpca = 6 //Primeiro

              EC8->(DBSEEK(cFilEC8))

              cEntrada:=EVAL(bWhile)

              LOOP
      ENDCASE

      EXIT

   ENDDO

   IF nOpca = 1
      LOOP
   ENDIF

   EXIT

ENDDO

EC8->(DBSETORDER(1))
DBSELECTAREA(cOldAlias)

Return .T.

*----------------------*
FUNCTION FP110_Filtro()
*----------------------*
Return xFilial("EC8")+If(cTipo = "1", cEntradaFor,"")+cEntrada

*---------------------*
FUNCTION FP110_Valid()
*---------------------*

EC8->(DBSETORDER(nTipo+1))

If cTipo = "1"
   If Empty(cEntradaFor)
      Help(" ",1,"AVG0005321") //E_Msg(STR0015,1) //"Fornecedor nao Informado."
      RETURN .F.
   Endif
Endif

IF If(cTipo = "1", !EMPTY(cEntradaFor), !EMPTY(cEntrada)) .AND. !EC8->(DBSEEK(xFilial("EC8")+If(cTipo = "1", cEntradaFor,"")+ALLTRIM(cEntrada)))

   E_Msg(STR0006,1) //"C¢digo nÆo encontrado."
   RETURN .F.

ENDIF

Return .T.

*------------------------------*
FUNCTION FP110_Troca_Get(cTipo)
*------------------------------*

DO CASE

   CASE cTipo = "1"

        aCampoBrow:={;
        {"EC8_HAWB"  ,"", AVSX3("EC8_HAWB"  )[5] },;
        {"EC8_IDENTC","", AVSX3("EC8_IDENTC")[5] },;
        {"EC8_PO_NUM","", AVSX3("EC8_PO_NUM")[5] },;
        {"EC8_FOB_PO","", AVSX3("EC8_FOB_PO")[5], AVSX3("EC8_FOB_PO")[6]}}

        EC8->(DBSETORDER(2))

        cEntrada:=SPACE(LEN(EC8->EC8_INVOIC))
        cLiteral:=AVSX3("EC8_INVOIC")[5]
        nTipo   := 1

   CASE cTipo = "2"

        aCampoBrow:={;
        {"EC8_INVOIC","", AVSX3("EC8_INVOIC")[5] },;
        {"EC8_IDENTC","", AVSX3("EC8_IDENTC")[5] },;
        {"EC8_PO_NUM","", AVSX3("EC8_PO_NUM")[5] },;
        {"EC8_FOB_PO","", AVSX3("EC8_FOB_PO")[5], AVSX3("EC8_FOB_PO")[6]}}

        EC8->(DBSETORDER(3))

        cEntrada:=SPACE(LEN(EC8->EC8_HAWB))
        cLiteral:=AVSX3("EC8_HAWB")[5]
        nTipo   := 2

   CASE cTipo = "3"

        aCampoBrow:={;
        {"EC8_HAWB"  ,"", AVSX3("EC8_HAWB"  )[5] },;
        {"EC8_INVOIC","", AVSX3("EC8_INVOIC")[5] },;
        {"EC8_IDENTC","", AVSX3("EC8_IDENTC")[5] },;
        {"EC8_FOB_PO","", AVSX3("EC8_FOB_PO")[5], AVSX3("EC8_FOB_PO")[6]}}

        EC8->(DBSETORDER(4))

        cEntrada:=SPACE(LEN(EC8->EC8_PO_NUM))
        cLiteral:=AVSX3("EC8_PO_NUM")[5]
        nTipo   := 3

ENDCASE

oGet:cText(cEntrada)
oGet:Refresh()

oSay:SetText(cLiteral)
oSay:Refresh()



RETURN
