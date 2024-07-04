#INCLUDE "Ecocr150.ch"
#include "AVERAGE.CH"
#include "AvPrint.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ECOCR150 ³ Autor ³ VICTOR IOTTI          ³ Data ³ 26.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Integracao Easy / Contabil e Rel. de Critica               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAECO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*-------------------*
Function  ECOCR150()
*-------------------*
LOCAL cOldArea:=ALIAS(),lOK:=.F.

Private aHeader[0]//E_CriaTrab utiliza
Private cFilEC0:=xFilial('EC0'), cHawb
Private aTipInt:={STR0001,STR0002,STR0003} //"1-Invoice"###"2-Desembara‡os"###"3-Ambos"
Private aTipSta:={STR0004,; //"1-Registros Adicionados"
                  STR0005,; //"2-Campos Adicionados"
                  STR0006,; //"3-Inf(s) J  Existente e Diferente da Receb."
                  STR0007,; //"4-Inf(s) J  Contabilizada e Difer. da Receb."
                  STR0008} //"5-Todos"

Private cTipoInt:='1',cTipoStat:='1',nOpca:=0,cTit:=STR0009 //"Relatorio de criticas"
Private cMarca := GetMark(), lInverte := .F.
Private TB_Cols:= { {{||Work->EC0_HAWB_I},"",STR0010},; //"No. Hawb. / Invoice"
                    {{||Work->EC0_DES_CA},"",STR0011   },; //"Descricao Campo"
                    {{||Work->EC0_CON_EX},"",STR0012},; //"Conteudo Existente"
                    {{||Work->EC0_CON_EN},"",STR0013 },; //"Conteudo Recebido"
                    {{||Work->EC0_STATUS},"",STR0014            }} //"Status"

Private dData_Int:=dDataBase

EC0->(DBSETORDER(1))

aCampos:=ARRAY(EC0->(FCOUNT()))//E_CriaTrab utiliza

cNomArqEC0:=E_CriaTrab("EC0",,"Work")
//MFR 18/12/2018 OSSME-1974 
IndRegua("Work",cNomArqEC0+TeOrdBagExt(),"DTOS(EC0_DT_INT)+EC0_TIPO_I+EC0_HAWB_I+EC0_STATUS",;
         "AllwaysTrue()",;
         "AllwaysTrue()",;
         STR0015) //"Processando Arquivo Temporario..."


DO WHILE .T.

   DEFINE MSDIALOG oDlg TITLE cTit From 10,0 To 20,50 OF GetWndDefault()
      nLin  := 2.5
      nColS := 0.8
      nColG := 8.0

      @ nLin++,nColS SAY STR0016 //"Data da Integra‡„o"
      @ nLin++,nColS SAY STR0017 //"Tipo da Integra‡„o"
      @ nLin++,nColS SAY STR0018 //"Tipo de Staus"

      cTipoInt :=aTipInt[VAL(cTipoInt)]
      cTipoStat:=aTipSta[VAL(cTipoStat)]
      nOpca = 0
      nLin  := 2.5

      @ nLin++,nColG MSGET dData_Int VALID CR150VAL() SIZE 50 ,08 OF oDlg
      @ nLin++,nColG COMBOBOX cTipoInt  ITEMS aTipInt SIZE 70 ,50 OF oDlg
      @ nLin++,nColG COMBOBOX cTipoStat ITEMS aTipSta SIZE 115,50 OF oDlg

   ACTIVATE MSDIALOG oDlg ON INIT ;
            EnchoiceBar(oDlg,{||If(CR150VAL(),(nOpca:=1,oDlg:End()),)},;   
                             {||nOpca:=0,oDlg:End()}) CENTERED             
   If nOpca=0
      EXIT
   EndIf

   cTipoInt :=LEFT(cTipoInt,1)
   cTipoStat:=LEFT(cTipoStat,1)

   DBSELECTAREA("Work")
   AvZap()

   Processa({||lOK:=CR150GeraWork()},STR0019) //"Atualizando Arq. Temporario..."
   If ! lOK
      E_Msg(STR0020,1) //"N„o h  registros para impress„o."
      LOOP
   Endif

   Work->(DBGOTOP())

   oMainWnd:ReadClientCoors()
   DEFINE MSDIALOG oDlg2 TITLE cTit; //From 9,0 To 28,80 OF oMainWnd
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;
               OF oMainWnd PIXEL  

          DEFINE SBUTTON FROM 18,(oDlg2:nClientWidth-4)/2-30 TYPE 6 ACTION Processa({||CR150Rel(cTit)},STR0021) ENABLE OF oDlg2 //"Impressao"
          oMark:=MsSelect():New( "Work",,,TB_Cols,@lInverte,@cMarca,{40,1,(oDlg2:nHeight-30)/2,(oDlg2:nClientWidth-4)/2})

   ACTIVATE MSDIALOG oDlg2 ON INIT EnchoiceBar(oDlg2,{||oDlg2:End()},;
                                                     {||oDlg2:End()})

ENDDO
Work->(E_EraseArq(cNomArqEC0))
DBSELECTAREA(cOldArea)
Return .T.

*-----------------------*
Function CR150GeraWork()
*-----------------------*
LOCAL nCont:=0
LOCAL bWhile:={|| !EC0->(EOF()).AND.EC0->EC0_DT_INT=dData_Int.AND.cFilEC0=EC0->EC0_FILIAL}
LOCAL bFor  :={|| (cTipoInt='3'.OR.EC0->EC0_TIPO_I=cTipoInt).AND.(cTipoStat='5'.OR.EC0->EC0_STATUS=cTipoStat)}

EC0->(DBSEEK(cFilEC0+DTOS(dData_Int)))
EC0->(DBEVAL({||nCont++},bFor,bWhile,,,.T.))

If nCont#0
   nCont+=1
   ProcRegua(nCont)
   IncProc(STR0022) //"Gravando ..."
   EC0->(DBSEEK(cFilEC0+DTOS(dData_Int)))
   Do While Eval(bWhile)
      IF ! Eval(bFor)
         EC0->(DBSKIP())
         LOOP
      ENDIF
      IncProc()
      Work->(DBAPPEND())
      Work->EC0_HAWB_I := EC0->EC0_HAWB_I
      Work->EC0_DES_CA := EC0->EC0_DES_CA
      Work->EC0_CON_EX := EC0->EC0_CON_EX
      Work->EC0_CON_EN := EC0->EC0_CON_EN
      Work->EC0_STATUS := EC0->EC0_STATUS
      Work->EC0_TIPO_I := EC0->EC0_TIPO_I
      Work->EC0_DT_INT := EC0->EC0_DT_INT
      EC0->(DBSKIP())
   EndDo
EndIf
Return !(Work->(EOF()).AND.Work->(BOF()))


*-------------------*
PROCEDURE CR150Rel()
*-------------------*
#DEFINE COURIER_07 oFont1
#DEFINE COURIER_08 oFont2
#DEFINE COURIER_10 oFont3
#DEFINE COURIER_12 oFont4
LOCAL nRecno

nRecno=Work->(RECNO())
ProcRegua(Work->(LASTREC()))
Work->(DBGOTOP())

AVPRINT oPrn NAME cTit

   DEFINE FONT oFont1  NAME "Courier New" SIZE 0,07      OF oPrn
   DEFINE FONT oFont2  NAME "Courier New" SIZE 0,08      OF oPrn
   DEFINE FONT oFont3  NAME "Courier New" SIZE 0,10      OF oPrn
   DEFINE FONT oFont4  NAME "Courier New" SIZE 0,12 BOLD OF oPrn

   AVPAGE
      nLimPage  := 3000 ; nColIni := 0    ; nCol1 := 10   ; nCol2 := 310
      nCol3     := 660  ; nCol4   := 1150 ; nCol5 := 1630
      nColFim   := 2320 ; nPag    := 0    ; nLin  := 99999
      cHawb     := Work->EC0_HAWB_I ; cTipo_Ant := Work->EC0_TIPO_I
      Do While ! Work->(EOF())
         IncProc( STR0023 ) //"Imprimindo..."
         If cTipo_Ant # Work->EC0_TIPO_I
            cTipo_Ant := Work->EC0_TIPO_I
            nLin+=20
            oPrn:Box(nLin,nColIni,nLin+1,nColFim)
            nLin      := 99999
         EndIf
         If nLin > nLimPage
            CR150_Cab()
         EndIf
         If cHawb # Work->EC0_HAWB_I
            cHawb := Work->EC0_HAWB_I
            nLin+=20
            oPrn:Box(nLin,nColIni,nLin+1,nColFim)
            nLin+=40
            oPrn:Say(nLin,nCol1,Work->EC0_HAWB_I)
         EndIf
         oPrn:Say(nLin,nCol2,Work->EC0_DES_CA)
         oPrn:Say(nLin,nCol3,Work->EC0_CON_EX)
         oPrn:Say(nLin,nCol4,Work->EC0_CON_EN)
         oPrn:Say(nLin,nCol5,SUBSTR(aTipSta[VAL(Work->EC0_STATUS)],3,45))
         nLin+=30
         Work->(DBSKIP())
      EndDo
      nLin+=20
      oPrn:Box(nLin,nColIni,nLin+1,nColFim)
   AVENDPAGE

AVENDPRINT

oFont1:End()
oFont2:End()
oFont3:End()
oFont4:End()
Work->(DBGOTO(nRecno))

RETURN .T.

*----------------------*
Function CR150VAL(nVez)
*----------------------*
IF EMPTY(dData_Int)
   E_Msg(STR0024,1) //"Dara da integra‡„o deve ser preenchida."
   Return .F.
ENDIF

If ! EC0->(DBSEEK(cFilEC0+DTOS(dData_Int)))
   E_Msg(STR0025,1) //"Data de integra‡„o n„o encontrada."
   Return .F.
ENDIF
Return .T.

*-----------------*
PROCEDURE CR150_Cab
*-----------------*
IF nPag#0
   AVNEWPAGE
ENDIF

oPrn:oFont:= COURIER_07

nLin:= 100
nPag++

cTexto = STR0026+DTOC(dData_Int) //"Integrado em "

oPrn:Box(nLin,nColIni,nLin+1,nColFim)
nLin+=25

oPrn:Say(nLin,nColIni,ALLTRIM(SM0->M0_NOME)+" - "+ALLTRIM(SM0->M0_FILIAL),COURIER_10)
oPrn:Say(nLin,(nColFim/2),cTit,COURIER_10,,,,2)
oPrn:Say(nLin,nColFim-20,STR0027+STR(nPag,8),COURIER_10,,,,1) //"Pagina..: "
nLin+=50

oPrn:Say(nLin,nColIni,'SIGAECO',COURIER_10)
oPrn:Say(nLin,(nColFim/2),cTexto,COURIER_10,,,,2)
oPrn:Say(nLin,nColFim-20,STR0028+DTOC(dDatabase),COURIER_10,,,,1) //"Emissao.: "
nLin+=50

oPrn:Box(nLin,nColIni,nLin+1,nColFim)
nLin+=25

oPrn:Say(nLin,(nColFim/2),SUBSTR(aTipInt[VAL(Work->EC0_TIPO_I)],3,15),COURIER_12,,,,2)
nLin+=70
oPrn:oFont:= COURIER_07

oPrn:Say(nLin,nCol1,IF(Work->EC0_TIPO_I='1','Nr. Invoice',STR0029)) //"Nr. Hawb"
oPrn:Say(nLin,nCol2,STR0011) //"Descricao Campo"
oPrn:Say(nLin,nCol3,STR0012) //"Conteudo Existente"
oPrn:Say(nLin,nCol4,STR0013) //"Conteudo Recebido"
oPrn:Say(nLin,nCol5,STR0014) //"Status"
nLin+=25

oPrn:Say(nLin,nCol1,REPLICATE('-',LEN(Work->EC0_HAWB_I)))
oPrn:Say(nLin,nCol2,REPLICATE('-',20))
oPrn:Say(nLin,nCol3,REPLICATE('-',30))
oPrn:Say(nLin,nCol4,REPLICATE('-',30))
oPrn:Say(nLin,nCol5,REPLICATE('-',45))
nLin+=50

oPrn:Say(nLin,nCol1,Work->EC0_HAWB_I)
cHawb := Work->EC0_HAWB_I

RETURN .T.
