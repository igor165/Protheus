#INCLUDE "Eicqc251.ch"
//#include "FiveWin.ch"
#include "AVERAGE.CH"
#include "AvPrint.ch"
#DEFINE AVALIA  6
#DEFINE RESUMO  2
#DEFINE REQ_QUO 1
#xtranslate :COURIER_07 => \[1\]
#xtranslate :COURIER_08 => \[2\]
#xtranslate :COURIER_10 => \[3\]
#xtranslate :COURIER_12 => \[4\]

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ EICQC251 ³ Autor ³ AVERAGE-ALEX WALLAUER ³ Data ³ 02/09/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Programa de Cotacao de Precos                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

*----------------------------------------------------------------------*
Function EICQC251Rel(nOpc)
*----------------------------------------------------------------------*
#DEFINE FIMREL Work2->(DBSETORDER(1)); Work2->(DBGOTOP()); RETURN
LOCAL oDlg, nTipo:=STR0001,nOpca:= 0,nImpr:=STR0002 //"1 - Request for Quotation"###"Sim"
LOCAL cPerg:= "EICQCO", ind
Local oPanel
PRIVATE nLenFF := AVSX3("A2_COD",3)//SO.:0026 OS.: 0248/02 FCD
PRIVATE TForLoja := ""
IF nOpc == AVALIA

   PRIVATE aRecno:={}, cIndex
   DO WHILE .T.

      Work2->(dbGotop())
      IF !Pergunte(cPerg,.T.)
         FIMREL
      ENDIF
      IF mv_par01 == RESUMO
         QC251Resumo(.F.)
      ELSE
         QC251Total()
      ENDIF

      Work2->(DbClearFilter())
      Work2->(OrdListClear())
      FErase(cIndex+TEOrdBagExt())

      Work2->(DBSETINDEX(cNo2CdxWT+TEOrdBagExt()))
      Work2->(DBSETINDEX(cNo3CdxWT+TEOrdBagExt()))             
      IF cTipo = "3"//Por Data de Entrega
         Work2->(DBSETINDEX(cNo4CdxWT+TEOrdBagExt())) //TDF - 23/11/11
      ELSEIF cTipo = "2"//Por Valor FOB Total
         Work2->(DBSETINDEX(cNo5CdxWT+TEOrdBagExt())) //TDF - 23/11/11
      ENDIF


      Processa({||ProcRegua(LEN(aRecno)),AEVAL(aRecno,{|nRecno|IncProc(STR0003),; //"Restaurando..."
                                               Work2->(DBGOTO(nRecno)),;
                                               Work2->(DBDELETE()) }) },STR0004) //"Restaurando Indices"

   ENDDO

ELSE
   
   IF Work1->(BOF()) .AND. Work1->(EOF())
      Help("", 1, "AVG0000512")//"NÆo existe Itens para a ImpressÆo"###"Aviso"
      FIMREL
   ENDIF

   SY7->(DBSEEK(xFilial()+"2"))//para iniciar com uma mensagem v lida
   PRIVATE cArqF3SY7:="SY7", cCampoF3SY7:="Y7_COD"
   PRIVATE cCodMen  :=SY7->Y7_COD, TOpcaoRel

   DO WHILE .T.

      nOpca:= 0
      dbSelectArea("Work2")

      DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0007) From 9,0 To 25,48 OF oMainWnd  //"Relat¢rios"

         oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165)
         oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

         @ 20,9 SAY OemToAnsi(STR0008) SIZE 70,8 OF oPanel PIXEL //"C¢digo da Mensagem"

         @ 20,72 MSGET cCodMen F3 cArqF3SY7 PICTURE "!!!" SIZE 33,8 OF oPanel PIXEL HASBUTTON
   
         @ 39,9 SAY OemToAnsi(STR0009) SIZE 80,8 OF oPanel PIXEL //"Tipo de Relat¢rio"

         @ 39,72 COMBOBOX nTipo ITEMS {STR0001,; //"1 - Request for Quotation"
                                        OemToAnsi(STR0010)}; //"2 - Conferˆncia"
                                        SIZE 79,30 OF oPanel PIXEL

         @ 57,9 SAY OemToAnsi(STR0011) SIZE 90,8 OF oPanel PIXEL //"Descri‡Æo do Item Total"

         @ 57,72 COMBOBOX nImpr ITEMS {STR0002,OemtoAnsi(STR0012)}; //"Sim"###"NÆo"
                                        SIZE 79,30 OF oPanel PIXEL

      ACTIVATE MSDIALOG oDlg ON INIT ;
               EnchoiceBar(oDlg,{||IF(QC210Val("16"),(nOpca:=1,oDlg:End()),)},;
                                {||nOpca:=0,oDlg:End()}) CENTERED
   
      IF nOpca = 0
         FIMREL
      ENDIF

      TOpcaoRel  := VAL(LEFT(nTipo,1))
      lDescrTotal:= (nImpr==STR0002) //"Sim"

      // ***** CAF 06/01/1999 - Rdmake NEC (INICIO) ***** \\
      IF TOpcaoRel = REQ_QUO
         IF EasyEntryPoint("EICQC001")
            // Rdmake para NEC - Imprime Request for Quotation
            PRIVATE lDescrCompleta := lDescrTotal
            PRIVATE cMensagem := cCodMen
            IF ! lInclusao
               M->WR_NR_CONC := SWR->WR_NR_CONC
            ENDIF
            ExecBlock("EICQC001")
            RETURN
         ENDIF
      ENDIF
      // ***** CAF 06/01/1999 - Rdmake NEC (FIM)    ***** \\


      AVPRINT oPrn NAME nTipo

         DEFINE FONT oFont1  NAME "Courier New" SIZE 0,07 OF  oPrn
         DEFINE FONT oFont2  NAME "Courier New" SIZE 0,08 OF  oPrn
         DEFINE FONT oFont3  NAME "Courier New" SIZE 0,10 OF  oPrn
         DEFINE FONT oFont4  NAME "Courier New" SIZE 0,12 OF  oPrn
      
         aFontes := { oFont1,oFont2,oFont3,oFont4 }
      
         AVPAGE
      
            oPrn:oFont:=IF(TOpcaoRel=REQ_QUO,aFontes:COURIER_08,aFontes:COURIER_07)
            
            Work2->(DBSETORDER(2))
            Work2->(DBGOTOP())
            //nC - Tracos do relatorio de conferencia
            nC1:=004; nC2:=037; nC3:=048; nC4:=064; nC5:=072; nC6:=083; nC7:=091; nC8:=098; nC9:=109
            //nR - Tracos do relatorio de request
            nR1:=004; nR2:=041; nR3:=057; nR4:=076; nR5:=085; nR6:=099; nR7:=107
            lPrimPag:=.T.
            MLin := 10000
            nLimPage:= 2955
            nLinAux1:= nItem:= 0
            nLinAux2:= MPag := 0
            nLinAux3:= 0
            nColLin := 2320
            
            M_Nome:=cFones:=cFax:=cContato:=""
            TFornecedor:= Work2->WT_FORN
            If EICLoja()
               TForLoja  :=Work2->WT_FORLOJ
            EndIf 
            
            Processa({||Work2->(DBEVAL({||QC210Det()}))},STR0013) //"Impressao"
   
            QC210BateTraco()
            Work2->(DBGOBOTTOM())//para imprimir o cabecario certo se estourar
            QC210DetMemo()   
   
         AVENDPAGE
      
      AVENDPRINT
      
      oFont1:End()
      oFont2:End()
      oFont3:End()
      oFont4:End()
      
      MS_FLUSH()
   
   ENDDO
   
ENDIF

FIMREL

*--------------------*
FUNCTION QC210Det()
*--------------------*
LOCAL nTam:=36, nTotLin:=0, cDescrItem:="", MInd, nTotLinFor := 0, cForn := ""    // GFP - 07/06/2013

IF lPrimPag
   ProcRegua(Work2->(LASTREC()))
ENDIF

IncProc(STR0014+Work2->WT_FORN+" - " + EICRetLoja("Work2","WT_FORLOJ")) //"Imprimindo Fornecedor: "

IF (Work2->WT_FORN <> TFornecedor  .AND. IIF(EICLoja(),Work2->WT_FORLOJ<>TForLoja,.T.)) //WFS - 19/01/12

   QC210BateTraco()   
   
   //o cabecario do memo tem que ser impresso com a 
   //informacoes do fornecedor anterior
   IF TOpcaoRel == REQ_QUO
      QC210DetMemo()
   ENDIF

   M_Nome  :=Work2->WT_REPRES
   cFones  :=Work2->WT_FONES
   cFax    :=Work2->WT_FAX   
   cContato:=Work2->WT_CONTATO

   QC210Cab() 
   QC210SubCab()
   TFornecedor := Work2->WT_FORN
   If EICLoja()
      TForLoja:= Work2->WT_FORLOJ
   EndIf 
   nItem := 0

ENDIF                      


IF MLin > nLimPage

   M_Nome  :=Work2->WT_REPRES
   cFones  :=Work2->WT_FONES
   cFax    :=Work2->WT_FAX   
   cContato:=Work2->WT_CONTATO
   
   QC210BateTraco()   
   QC210Cab() 
   QC210SubCab()
ENDIF

                          
lBate := .T. 
nItem ++  

Work1->(DBSEEK(Work2->WT_COD_I))

oPrn:Say(MLin,QC210xCol(1.0),STRZERO(nItem,3),aFontes:COURIER_08)
// GFP - 07/06/2013 - Tratamento de quebra de linha para o campo Fornecedor
nBkpLin := MLIN
cForn := Work2->WT_DESCRFA
STRTRAN(cForn,CHR(13)+CHR(10)," ")
If TOpcaoRel == REQ_QUO
   nTotLinFor := IF(lDescrTotal,MLCOUNT(cForn,20),1)
Else
   nTotLinFor := IF(lDescrTotal,MLCOUNT(cForn,15),1)
EndIf
FOR MInd = 1 TO nTotLinFor
   IF !EMPTY(MEMOLINE(cForn,IIF(TOpcaoRel==REQ_QUO,20,15),MInd))
      IF TOpcaoRel == REQ_QUO
         oPrn:Say(MLin,QC210xCol(042),MEMOLINE(cForn,20,MInd))
      ELSE
         oPrn:Say(MLin,QC210xCol(37.5),MEMOLINE(cForn,15,MInd))
      ENDIF
      MLIN+=45
   ENDIF
NEXT
MLIN := nBkpLin

IF TOpcaoRel == REQ_QUO
   //oPrn:Say(MLin,QC210xCol(042),/*LEFT(*/Work2->WT_DESCRFA/*,14)*/,aFontes:COURIER_08)//NOPADO POR AOM - 08/07/2011   // GFP - 07/06/2013
   oPrn:Say(MLin,QC210xCol(76.0),AllTrim(Work1->WS_UNI)+" "+TRANS(Work1->WS_QTDE,cPicQtde),aFontes:COURIER_08,,,,1)
   oPrn:Say(MLin,QC210xCol(077),DTOC(Work1->WS_DTNECES),aFontes:COURIER_08)
   oPrn:Say(MLin,QC210xCol(085),TRANS(Work2->WT_FOB_TOT,cPicQtde),aFontes:COURIER_08)   // GFP - 24/07/2013
ELSE
   //oPrn:Say(MLin,QC210xCol(37.5) ,/*LEFT(*/Work2->WT_DESCRFA/*,13)*/,aFontes:COURIER_07) //NOPADO POR AOM - 08/07/2011   // GFP - 07/06/2013  
   oPrn:Say(MLin,QC210xCol(50),AllTrim(Work1->WS_UNI),aFontes:COURIER_07)
   oPrn:Say(MLin,QC210xCol(064.0),TRANS(Work1->WS_QTDE,cPicQtde),aFontes:COURIER_07,,,,1)
   
   oPrn:Say(MLin,QC210xCol(/*76.0*/66),DTOC(Work1->WS_DTNECES),aFontes:COURIER_07)//64.5
   oPrn:Say(MLin,QC210xCol(074),TRANS(Work2->WT_FOB_TOT,cPicQtde),aFontes:COURIER_07)   // GFP - 24/07/2013
   oPrn:Say(MLin,QC210xCol(108.7),TRANS(Work2->WT_ULT_FOB,cPicUltFob),aFontes:COURIER_07,,,,1)
   oPrn:Say(MLin,QC210xCol(110.0),DTOC(Work2->WT_ULT_ENT),aFontes:COURIER_07)//109.5
ENDIF
cDescrItem:=""
SB1->(DBSEEK(xFilial()+Work2->WT_COD_I))
cDescrItem := MSMM(SB1->B1_DESC_I,36)
STRTRAN(cDescrItem,CHR(13)+CHR(10)," ")

nTotLin := IF(lDescrTotal,MLCOUNT(cDescrItem,nTam),1)

FOR MInd = 1 TO nTotLin
   IF !EMPTY(MEMOLINE(cDescrItem,nTam,MInd))
      IF MLIN > nLimPage
         oPrn:Box( MLin,10,MLin+1,nColLin)
         nLinAux2:=MLin
         QC210BateTraco()
         QC210Cab()
         QC210SubCab()
      ENDIF
      IF nTotLin = 1 .OR. nTotLin = MInd
         oPrn:Say(MLin,QC210xCol(005),MEMOLINE(cDescrItem,nTam,MInd))
      ELSE
         oPrn:Say(MLin,QC210xCol(005),AV_Justifica(MEMOLINE(cDescrItem,nTam,MInd)))
      ENDIF
      MLIN+=45
   ENDIF
NEXT

MLin+=45*If(nTotLinFor == 1,nTotLinFor,nTotLinFor-1)//IF(nTotLin#0,0,45) //AOM - 08/07/2011 - Rejuste do quadro de itens   // GFP - 07/06/2013 - Incluido tratamento do tamanho de fornecedor.

SA5->(DBSEEK(cFilSA5+Work2->WT_COD_I+Work2->WT_FORN+EICRetLoja("Work2","WT_FORLOJ")))
IF !EMPTY(SA5->A5_CODPRF)
   oPrn:Say(MLin,QC210xCol(005),STR0015+SA5->A5_CODPRF) //"P.N.: "
   MLin +=45
ENDIF

oPrn:Box( MLin,10,MLin+1,nColLin)
nLinAux2:=MLin
MLin +=25

RETURN .T.

*-------------------------*                                                                                                        
FUNCTION QC210Cab()
*-------------------------*
LOCAL M_Tel, M_Fax,nPos:=75


IF lPrimPag
   lPrimPag:=.F.
ELSE
   AVNEWPAGE
ENDIF

MPag++
MLin:=100

SYT->(DBSETORDER(1))
SYT->(DBSEEK(xFilial()+SWR->WR_IMPOR))
oPrn:Say(MLin,QC210xCol(001),SYT->YT_NOME,aFontes:COURIER_12) 
MLin+=50

IF TOpcaoRel == REQ_QUO 
   oPrn:Say(MLin,QC210xCol(045),STR0016,aFontes:COURIER_12 ) //"REQUEST FOR QUOTATION"
ELSE
   oPrn:Say(MLin,QC210xCol(048),STR0017,aFontes:COURIER_12 ) //"CONFERENCIA"
ENDIF
MLin+=70

oPrn:Box( MLin  ,10, MLin+450, nColLin )
oPrn:Box( MLin+1,11, MLin+449, nColLin-1 )
MLin +=50
nLinAux3:=MLin+450

oPrn:Say(MLin,QC210xCol(002),STR0018+M->WR_NR_CONC,aFontes:COURIER_10) //"OUR REF.: "
oPrn:Say(MLin,QC210xCol(050),STR0019+DTOC(M->WR_DT_CONC),aFontes:COURIER_10) //"DATE.: "
oPrn:Say(MLin,QC210xCol(100),STR0020+STR(MPag,3),aFontes:COURIER_10) //"PAGE: "
MLin+=100

oPrn:Say(MLin,QC210xCol(02)  ,STR0021+ALLTRIM(M_Nome),aFontes:COURIER_10) //"TO...: "
oPrn:Say(MLin,QC210xCol(nPos),STR0022+ALLTRIM(cFones),aFontes:COURIER_10) //"PHONE: "
MLin+=50

oPrn:Say(MLin,QC210xCol(02)  ,STR0023+ALLTRIM(cContato),aFontes:COURIER_10) //"ATTN.: "
oPrn:Say(MLin,QC210xCol(nPos),STR0024+ALLTRIM(cFax),aFontes:COURIER_10) //"FAX..: "
MLin+=100

//oPrn:Say(MLin,QC210xCol(02),STR0023+ALLTRIM(SA2->A2_CONTATO),aFontes:COURIER_10) //"ATTN.: "
//MLin +=50  

SY1->(DBSEEK(xFilial()+M->WR_COMPRA))
M_Tel:=IF(!EMPTY(SY1->Y1_TEL),SY1->Y1_TEL,SYT->YT_TEL_PO)
M_Fax:=IF(!EMPTY(SY1->Y1_FAX),SY1->Y1_FAX,SYT->YT_FAX_PO)

oPrn:Say(MLin,QC210xCol(02)  ,STR0025+ALLTRIM(SY1->Y1_NOME),aFontes:COURIER_10  ) //"FROM.: "
oPrn:Say(MLin,QC210xCol(nPos),STR0022+ALLTRIM(M_Tel),aFontes:COURIER_10  ) //"PHONE: "
MLin+=50

oPrn:Say(MLin,QC210xCol(10),  STR0026,aFontes:COURIER_10 ) //"IMPORT DEPARTMENT"
oPrn:Say(MLin,QC210xCol(nPos),STR0024+ALLTRIM(M_Fax),aFontes:COURIER_10 ) //"FAX..: "
MLin+=65

RETURN NIL

*--------------------*
FUNCTION QC210SubCab
*--------------------*
oPrn:Box( MLin  ,10, MLin+150, nColLin )
oPrn:Box( MLin+1,11, MLin+149, nColLin-1 )

nLinAux1:= MLin+150  

IF TOpcaoRel == REQ_QUO
   oPrn:Box( MLin  ,QC210xCol(nR1),MLin+150,QC210xCol(nR1)+1)
   oPrn:Box( MLin  ,QC210xCol(nR2),MLin+150,QC210xCol(nR2)+1)
   oPrn:Box( MLin  ,QC210xCol(nR3),MLin+150,QC210xCol(nR3)+1)
   oPrn:Box( MLin  ,QC210xCol(nR4),MLin+150,QC210xCol(nR4)+1)
   oPrn:Box( MLin  ,QC210xCol(nR5),MLin+150,QC210xCol(nR5)+1)
   oPrn:Box( MLin  ,QC210xCol(nR6),MLin+150,QC210xCol(nR6)+1)
// oPrn:Say(MLin+15,QC210xCol(104),STR0027,aFontes:COURIER_08 )  //"FORECAST"
ELSE
   oPrn:Box( MLin  ,QC210xCol(nC1),MLin+150,QC210xCol(nC1)+1)
   oPrn:Box( MLin  ,QC210xCol(nC2),MLin+150,QC210xCol(nC2)+1)
   oPrn:Box( MLin  ,QC210xCol(nC3),MLin+150,QC210xCol(nC3)+1)
   oPrn:Box( MLin  ,QC210xCol(nC4),MLin+150,QC210xCol(nC4)+1)
   oPrn:Box( MLin  ,QC210xCol(nC5),MLin+150,QC210xCol(nC5)+1)
   oPrn:Box( MLin  ,QC210xCol(nC6),MLin+150,QC210xCol(nC6)+1)
// oPrn:Say(MLin+15,QC210xCol(87),STR0027,aFontes:COURIER_08) //"FORECAST" 
   oPrn:Box( MLin  ,QC210xCol(nC8),MLin+150,QC210xCol(nC8)+1)
// oPrn:Say(MLin+15,QC210xCol(102),STR0028,aFontes:COURIER_08) //"ULTIMA COMPRA"
ENDIF                                            
MLin +=45

oPrn:Say(MLin,QC210xCol(1.5),STR0029,aFontes:COURIER_08) //"IT"
oPrn:Say(MLin,QC210xCol(005),STR0030,aFontes:COURIER_08) //"DESCRIPTION / PART NUMBER"

IF TOpcaoRel == REQ_QUO
   oPrn:Say(MLin,QC210xCol(041),STR0031,aFontes:COURIER_08) //"      MANUF"
   oPrn:Say(MLin,QC210xCol(057),STR0032,aFontes:COURIER_08) //"      QUANTITY"
   oPrn:Say(MLin,QC210xCol(077),STR0033,aFontes:COURIER_08) //"DELIVERY" 
   oPrn:Say(MLin,QC210xCol(085),STR0034,aFontes:COURIER_08) //"     PRICE"
   oPrn:Say(MLin,QC210xCol(104),STR0027,aFontes:COURIER_08) //"FORECAST"
// oPrn:Box(MLin+15,QC210xCol(099),MLin+16,nColLin )
// oPrn:Box(MLin+15,QC210xCol(nR7),MLin+100,QC210xCol(nR7)+1)
ELSE
   oPrn:Say(MLin,QC210xCol(40.5),STR0035,aFontes:COURIER_08) //"MANUF"
   oPrn:Say(MLin,QC210xCol(52.5),STR0036,aFontes:COURIER_08) //"QUANTITY"
   oPrn:Say(MLin,QC210xCol(65)  ,STR0033,aFontes:COURIER_08) //"DELIVERY"
   oPrn:Say(MLin,QC210xCol(076) ,STR0037,aFontes:COURIER_08) //"PRICE"
   oPrn:Say(MLin,QC210xCol(87)  ,STR0027,aFontes:COURIER_08) //"FORECAST" 
   oPrn:Say(MLin,QC210xCol(102) ,STR0028,aFontes:COURIER_08) //"ULTIMA COMPRA"
// oPrn:Box(MLin+15,QC210xCol(nC6),MLin+16,nColLin)
// oPrn:Box(MLin+15,QC210xCol(nC7),MLin+100,QC210xCol(nC7)+1)
// oPrn:Box(MLin+15,QC210xCol(nC9),MLin+100,QC210xCol(nC9)+1)
ENDIF

MLin +=50

IF TOpcaoRel == REQ_QUO
   oPrn:Say(MLin,QC210xCol(078),STR0038,aFontes:COURIER_08) //"DATE"
   oPrn:Say(MLin,QC210xCol(099),STR0039,aFontes:COURIER_08) //"  QTY"
   oPrn:Say(MLin,QC210xCol(108),STR0040,aFontes:COURIER_08) //"  DATE"
ELSE
   oPrn:Say(MLin,QC210xCol(054)  ,STR0041,aFontes:COURIER_08) //"UNIT"
   oPrn:Say(MLin,QC210xCol(66)   ,STR0038,aFontes:COURIER_08) //"DATE"
   oPrn:Say(MLin,QC210xCol(85.5) ,STR0042,aFontes:COURIER_08) //"QTY"
   oPrn:Say(MLin,QC210xCol(092.5),STR0038,aFontes:COURIER_08) //"DATE"
   oPrn:Say(MLin,QC210xCol(099)  ,STR0043,aFontes:COURIER_08) //"PRICE  US$"
   oPrn:Say(MLin,QC210xCol(110.5),STR0038,aFontes:COURIER_08) //"DATE"
ENDIF

MLin:=nLinAux1+25//para o primeiro quadro dos itens ficar na mesma altura dos outros

RETURN NIL
*---------------------*
FUNCTION QC210DetMemo()
*---------------------*
LOCAL nTam:=AVSX3("Y7_VM_TEXT",3),MInd
LOCAL cMemo   := MSMM(SY7->Y7_TEXTO,nTam) 
LOCAL MTamanho:= MLCOUNT(cMemo,nTam) 

MLIN+=50                             

FOR MInd = 1 TO MTamanho
    IF MLIN > nLimPage
       QC210Cab()
       nLinAux1:= 0
       nLinAux2:= 0
       MLin:=nLinAux3
    ENDIF
    oPrn:Say(MLin,QC210xCol(01),MEMOLINE(cMemo,nTam,MInd),aFontes:COURIER_10)
    MLIN+=50
NEXT

RETURN NIL

*------------------------*
FUNCTION QC210BateTraco()
*------------------------*

oPrn:Box(nLinAux1,0010,nLinAux2,0011)
oPrn:Box(nLinAux1,nColLin,nLinAux2,nColLin-1)

IF TOpcaoRel == REQ_QUO
   oPrn:Box(nLinAux1,QC210xCol(nR1),nLinAux2,QC210xCol(nR1)+1)
   oPrn:Box(nLinAux1,QC210xCol(nR2),nLinAux2,QC210xCol(nR2)+1)
   oPrn:Box(nLinAux1,QC210xCol(nR3),nLinAux2,QC210xCol(nR3)+1)
   oPrn:Box(nLinAux1,QC210xCol(nR4),nLinAux2,QC210xCol(nR4)+1)
   oPrn:Box(nLinAux1,QC210xCol(nR5),nLinAux2,QC210xCol(nR5)+1)
   oPrn:Box(nLinAux1,QC210xCol(nR6),nLinAux2,QC210xCol(nR6)+1)
   oPrn:Box(nLinAux1,QC210xCol(nR7),nLinAux2,QC210xCol(nR7)+1)
ELSE
   oPrn:Box(nLinAux1,QC210xCol(nC1),nLinAux2,QC210xCol(nC1)+1)
   oPrn:Box(nLinAux1,QC210xCol(nC2),nLinAux2,QC210xCol(nC2)+1)
   oPrn:Box(nLinAux1,QC210xCol(nC3),nLinAux2,QC210xCol(nC3)+1)
   oPrn:Box(nLinAux1,QC210xCol(nC4),nLinAux2,QC210xCol(nC4)+1)
   oPrn:Box(nLinAux1,QC210xCol(nC5),nLinAux2,QC210xCol(nC5)+1)
   oPrn:Box(nLinAux1,QC210xCol(nC6),nLinAux2,QC210xCol(nC6)+1)
   oPrn:Box(nLinAux1,QC210xCol(nC7),nLinAux2,QC210xCol(nC7)+1)
   oPrn:Box(nLinAux1,QC210xCol(nC8),nLinAux2,QC210xCol(nC8)+1)
   oPrn:Box(nLinAux1,QC210xCol(nC9),nLinAux2,QC210xCol(nC9)+1)
ENDIF

RETURN NIL


*--------------------------------*
FUNCTION QC251Resumo(lDireto)
*--------------------------------*
LOCAL oMark, aRCampos:={}, TB_Campos:={}, aForn:={}, ind
LOCAL oDlg, nOpca:=0

PRIVATE nCont:=0

DBSELECTAREA("Work2") 
Work2->(DBSETORDER(2))
Work2->(DBGOTOP())

Processa({||QC251GeraImp(),STR0044}) //"Avaliacao"

cIndex:=E_Create({},.F.)
DBSELECTAREA("Work2")
DBSEEK(STR(9,1))

If EICLoja()

   IndRegua("Work2",cIndex,"WT_CLASS+WT_FORN+WT_FORLOJ" ,;
            "Work2->WT_CLASS=='00'"    ,;
            "Work2->WT_CLASS=='00'"    ,;
            STR0045) //"Resumindo as Cotacoes"  
Else

   IndRegua("Work2",cIndex,"WT_CLASS+WT_FORN" ,;
            "Work2->WT_CLASS=='00'"    ,;
            "Work2->WT_CLASS=='00'"    ,;
            STR0045) //"Resumindo as Cotacoes" 
            
EndIf


IF !lDireto

   PRIVATE cMarca :=GetMark(), lInverte:=.F.

   AADD(TB_Campos,{{||TRANS(Work2->WT_FORN,REPL("!",LEN(Work2->WT_FORN)))+" "+LEFT(Work2->WT_DESCRFO,25)},"",STR0046})  //"Fornecedor"
   If EICLoja()
      AADD(TB_Campos,{"WT_FORLOJ","","Loja Forn.",AVSX3("WT_FORLOJ",6)})
   EndIf
   AADD(TB_Campos,{"WT_FOB_TOT","",STR0047,AVSX3("WT_FOB_TOT",6)}) //"Fob Total US$"
   AADD(TB_Campos,{"WT_FRE_KG" ,"",STR0048,AVSX3("WT_FRE_KG" ,6)}) //"Frete Total US$"
   AADD(TB_Campos,{"WT_SEGURO" ,"",STR0049,AVSX3("WT_SEGURO" ,6)}) //"Seguro US$"
   AADD(TB_Campos,{"WT_CIF"    ,"",STR0050,cPicCIF}) //"C.I.F US$"
   
   TB_Campos:= AddCpoUser(TB_Campos,"SWT","2")     
   
   
   DO WHILE .T.

      nOpca:=0

      oMainWnd:ReadClientCoors()
      DEFINE MSDIALOG oDlg TITLE STR0051 ; //"Resumo Quadro de Concorrencia"
             FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;
     	           OF oMainWnd PIXEL  

			    DEFINE SBUTTON FROM 12,(oDlg:nClientWidth-4)/2-30 TYPE 6 ACTION (nOpca:=1,oDlg:End()) ENABLE OF oDlg

          dbSelectArea("Work2")
          dbGoTop()
          oMark:=MsSelect():New("Work2",,,TB_Campos,@lInverte,@cMarca,{31,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
          oMark:bAval:={||nOpca:=1,oDlg:End()}

      ACTIVATE MSDIALOG oDlg ON INIT;
               EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},;
                                {||nOpca:=0,oDlg:End()}) CENTERED

      IF nOpca == 1
         QC251ImpResumo()
         LOOP
      ELSEIF nOpca == 0
         EXIT
      ENDIF

   ENDDO                     

ELSE

   oPrn:oFont:=aFontes:COURIER_08
   Work2->(DBGOTOP())

   nLinAux1:= MLin := 0
   nLinAux2:= MPag := 0
   lPrimPag:=.F.; nItem:= 1
   nLimPage:= 2255
   nColLin := 2320
   TCol1:=QC210xCol(0.5); TCol2:=QC210xCol(09); TCol3:=QC210xCol(58)
   TCol4:=QC210xCol(78); TCol5:=QC210xCol(96); TCol6:=QC210xCol(115.5)

   QC251CabRes()
   Processa({||ProcRegua(nCont),Work2->(DBEVAL({||QC251DetRes()}))},STR0013) //"Impressao"
   QC210BatTraco()


ENDIF

RETURN .T.

*--------------------------------*
FUNCTION QC251GeraImp()
*--------------------------------*
LOCAL aForn:={}, ind
LOCAL TFob_Total  := 0
LOCAL TFre_Total  := 0
LOCAL TSeguro     := 0
LOCAL TCif        := 0
LOCAL cDescr := ''
LOCAL TFornecedor := Work2->WT_FORN

LOCAL TForLoj     := SPACE(AVSX3("A2_LOJA",3))

If EICLoja()
   TForLoj := Work2->WT_FORLOJ 
EndIf

ProcRegua(Work2->(LASTREC()))

WHILE Work2->(!EOF()) .AND. Val(Work2->WT_CLASS) = 1

  IncProc(STR0052+Work2->WT_COD_I) //"Avaliando Item: "
  IF (Work2->WT_FORN <> TFornecedor .AND. IIF(EICLoja(),Work2->WT_FORLOJ <> TForLoj,.T.))

     AADD(aForn,{TFornecedor,TFob_Total,TFre_Total,TSeguro,TCif,cDescr,TForLoj})
     TFornecedor:= Work2->WT_FORN 
     TFob_Total := 0 
     TFre_Total := 0 
     TSeguro    := 0
     TCif       := 0 
     If EICLoja()
        TForLoj := Work2->WT_FORLOJ      
     EndIf

  ENDIF

  TFob_Total += Work2->WT_FOB_TOT
  TFre_Total += Work2->WT_FRE_KG
  TSeguro    += Work2->WT_SEGURO
  TCif       += Work2->WT_CIF
  cDescr     := Work2->WT_DESCRFO

  Work2->(DBSKIP())
ENDDO

Work2->(DBSKIP(-1))

AADD(aForn,{Work2->WT_FORN,TFob_Total,TFre_Total,TSeguro,TCif,cDescr,TForLoj})

FOR ind:=1 TO LEN(aForn)
    Work2->(DBAPPEND())
    Work2->WT_CLASS   :="00"
    Work2->WT_FORN    :=aForn[ind,1] 
    Work2->WT_FOB_TOT :=aForn[ind,2]
    Work2->WT_FRE_KG  :=aForn[ind,3]
    Work2->WT_SEGURO  :=aForn[ind,4]
    Work2->WT_CIF     :=aForn[ind,5]
    Work2->WT_DESCRFO :=aForn[ind,6]
    If EICLoja()
       Work2->WT_FORLOJ  :=aForn[ind,7]
    EndIf 
    AADD(aRecno,Work2->(RECNO()))
    nCont++
NEXT

RETURN .T.
*-------------------------------------*
FUNCTION QC251ImpResumo()
*-------------------------------------*

PRINT oPrn NAME ""
      oPrn:SetLandsCape()
ENDPRINT

AVPRINT oPrn NAME STR0053 //"Resumo do Quadro de Concorrencia"

   DEFINE FONT oFont1  NAME "Courier New" SIZE 0,07 OF  oPrn
   DEFINE FONT oFont2  NAME "Courier New" SIZE 0,08 OF  oPrn
   DEFINE FONT oFont3  NAME "Courier New" SIZE 0,10 OF  oPrn
   DEFINE FONT oFont4  NAME "Courier New" SIZE 0,12 OF  oPrn

   aFontes := { oFont1,oFont2,oFont3,oFont4 }

   AVPAGE

      oPrn:oFont:=aFontes:COURIER_08
      
      Work2->(DBGOTOP())

      nLinAux1:= MLin := 0
      nLinAux2:= MPag := 0
      lPrimPag:=.T.; nItem:= 1
      nLimPage:= 2255
      nColLin := 2320
      TCol1:=QC210xCol(0.5); TCol2:=QC210xCol(09); TCol3:=QC210xCol(58)
      TCol4:=QC210xCol(78); TCol5:=QC210xCol(96); TCol6:=QC210xCol(115.5)

      QC251CabRes()
      Processa({||ProcRegua(nCont),Work2->(DBEVAL({||QC251DetRes()}))},STR0054) //"Impressao..."
      QC210BatTraco()

   AVENDPAGE

AVENDPRINT

oFont1:End()
oFont2:End()
oFont3:End()
oFont4:End()

MS_FLUSH()
RETURN .T.

*--------------------*
FUNCTION QC251CabRes()
*--------------------*
LOCAL cabec1 :=STR0055+SWR->WR_NR_CONC //"Nr. Concorrencia.: "
LOCAL titulo :=STR0053 //"Resumo do Quadro de Concorrencia"

IF lPrimPag
   lPrimPag:=.F.
ELSE
   AVNEWPAGE
ENDIF

MLin:= 100
MPag++

oPrn:Box( MLin,01,MLin,nColLin)
MLin+=25

oPrn:Say(MLin,01,SM0->M0_NOME,aFontes:COURIER_10)
oPrn:Say(MLin,1180,titulo,aFontes:COURIER_10,,,,2)
oPrn:Say(MLin,nColLin,STR0056+STR(MPag,8),aFontes:COURIER_10,,,,1) //"Pagina..: "
MLin+=50

oPrn:Say(MLin,01,STR0057,aFontes:COURIER_10) //"SIGAEIC"
oPrn:Say(MLin,1180,cabec1,aFontes:COURIER_10,,,,2)
oPrn:Say(MLin,nColLin,STR0058+DTOC(dDataBase),aFontes:COURIER_10,,,,1) //"Emissao.: "
MLin+=50

oPrn:Box( MLin,01,MLin,nColLin)
MLin+=50

oPrn:Box( MLin,01,MLin,nColLin)
nLinAux1:=MLin
MLin +=35

oPrn:Say(MLin,TCol1     ,STR0059) //"Pedido"
oPrn:Say(MLin,TCol2     ,STR0046) //"Fornecedor"
oPrn:Say(MLin,TCol3-080 ,STR0047,,,,,1) //"Fob Total US$"
oPrn:Say(MLin,TCol4     ,STR0048,,,,,1) //"Frete Total US$"
oPrn:Say(MLin,TCol5-055 ,STR0049,,,,,1) //"Seguro US$"
oPrn:Say(MLin,TCol6-080 ,STR0050,,,,,1) //"C.I.F US$"
MLin +=50

oPrn:Box( MLin,01,MLin,nColLin)
MLin +=50

RETURN NIL


*-------------------------------------*
FUNCTION QC251DetRes()
*-------------------------------------*
IF MLin > nLimPage
   QC210BatTraco()
   QC251CabRes()
ENDIF
IncProc(STR0014+Work2->WT_FORN+" "+EICRetLoja("Work2","WT_FORLOJ")) //"Imprimindo Fornecedor: "

oPrn:Say( MLin,TCol1, STRZERO(nItem,4))                            
oPrn:Say( MLin,TCol2, Work2->WT_FORN+" "+ EICRetLoja("Work2","WT_FORLOJ")+" "+LEFT(Work2->WT_DESCRFO,(15-(nLenFF-6)))) //SO.:0026 OS.:0248/02 FCD
oPrn:Say( MLin,TCol3, TRANS(Work2->WT_FOB_TOT,_PictPrUn),,,,,1)
oPrn:Say( MLin,TCol4, TRANS(Work2->WT_FRE_KG ,cPicFreKG),,,,,1)
oPrn:Say( MLin,TCol5, TRANS(Work2->WT_SEGURO ,cPicSeguro),,,,,1)
oPrn:Say( MLin,TCol6, TRANS(Work2->WT_CIF    ,cPicCIF),,,,,1)
MLin+=50

nLinAux2:=MLin
nItem ++

RETURN NIL

*------------------------*
FUNCTION QC210BatTraco()
*------------------------*
LOCAL TCol6:=QC210xCol(34)

oPrn:Box(nLinAux1,0001,nLinAux2,0002)//CI
oPrn:Box(nLinAux1,TCol2-20,nLinAux2,TCol2-20)
oPrn:Box(nLinAux1,TCol6+20,nLinAux2,TCol6+20)
oPrn:Box(nLinAux1,TCol3+20,nLinAux2,TCol3+20)
oPrn:Box(nLinAux1,TCol4+20,nLinAux2,TCol4+20)
oPrn:Box(nLinAux1,TCol5+20,nLinAux2,TCol5+20)
oPrn:Box(nLinAux1,nColLin,nLinAux2,nColLin)//CF
oPrn:Box(nLinAux2,0001,nLinAux2,nColLin)//Linha

RETURN NIL

*-------------------------------------*
FUNCTION QC251Total(lEnd,WnRel,cString)
*-------------------------------------*
PRIVATE titulo   := STR0060 //"Avaliacao do Quadro de Concorrencia"

PRINT oPrn NAME ""
      oPrn:SetLandsCape()
ENDPRINT

AVPRINT oPrn NAME titulo

   DEFINE FONT oFont1  NAME "Courier New" SIZE 0,07 OF  oPrn
   DEFINE FONT oFont2  NAME "Courier New" SIZE 0,08 OF  oPrn
   DEFINE FONT oFont3  NAME "Courier New" SIZE 0,10 OF  oPrn
   DEFINE FONT oFont4  NAME "Courier New" SIZE 0,12 OF  oPrn

   aFontes := { oFont1,oFont2,oFont3,oFont4 }

   AVPAGE

      oPrn:oFont:=aFontes:COURIER_07
      
      Work2->(DBGOTOP())

      nLinAux1:= nSubAux1:= 0
      nLinAux2:= nSubAux2:= 0
      lPrimPag:= lBate   :=.T.
      nLimPage:= 2255
      cColFim := 2770
      MLin := 90000 
      MPag := 0 
      ItemAnter := Work2->WT_COD_I

      TCol0:=1.5; TCol1:=033; TCol2:=047; TCol3:=061; TCol4:=077 
      TCol5:=078; TCol6:=083; TCol7:=095; TCol8:=115; TCol9:=129 

      Processa({||ProcRegua(Work2->(LASTREC())),Work2->(DBEVAL({||QC251Det()}))},STR0013) //"Impressao"
      BateTraco()
      
      QC251Resumo(.T.)

   AVENDPAGE

AVENDPRINT

oFont1:End()
oFont2:End()
oFont3:End()
oFont4:End()

MS_FLUSH()

RETURN NIL

*----------------*
FUNCTION QC251Det
*----------------*

IF MLin > nLimPage
   IF MPag <> 0
      BateTraco()      
      lBate := .F.
   ENDIF
   QC251Cab()
ENDIF

IF WT_COD_I <> ITemAnter
   IF MPag <> 0 .AND. lBate
      IF MLin + nSubAux2 > nLimPage
         IF MPag <> 0
            BateTraco()      
            lBate := .F.
         ENDIF
         QC251Cab()
      ELSE
         BateTraco()      
         MLin +=50
         QC251SubCab()
      ENDIF
   ENDIF
   ITemAnter := Work2->WT_COD_I
ENDIF

IncProc(STR0014+Work2->WT_FORN + ' '+ EICRetLoja("Work2","WT_FORLOJ")) //"Imprimindo Fornecedor: "
lBate:=.T.

oPrn:oFont:=aFontes:COURIER_07

oPrn:Say(MLin,QC210xCol(TCol0), Work2->WT_FORN+' '+EICRetLoja("Work2","WT_FORLOJ") +' '+LEFT(Work2->WT_DESCRFO,(16-(nLenFF-6))))//SO.:0026  OS.:0248/02 FCD
oPrn:Say(MLin,QC210xCol(TCol1), TRANS(Work2->WT_FOB_TOT,_PictQtde),,,,,1)
oPrn:Say(MLin,QC210xCol(TCol2), TRANS(Work2->WT_FRE_KG ,cPicFreKG ),,,,,1)
oPrn:Say(MLin,QC210xCol(TCol3), TRANS(Work2->WT_SEGURO ,cPicSeguro),,,,,1)
oPrn:Say(MLin,QC210xCol(TCol4), TRANS(Work2->WT_CIF    ,cPicCIF   ),,,,,1)
oPrn:Say(MLin,QC210xCol(TCol5), ALLTRIM(TRANS(Work2->WT_CIF_P  ,cPicCIF)))
oPrn:Say(MLin,QC210xCol(TCol6), TRANS(Work2->WT_COD_PAG+STR(Work2->WT_DIASPAG,3),"@R 9.9.999 ###"))
oPrn:Say(MLin,QC210xCol(TCol7), Work2->WT_DES_PAG)
oPrn:Say(MLin,QC210xCol(TCol8), Work2->WT_FABR+' '+EICRetLoja("Work2","WT_FABLOJ")+' '+LEFT(Work2->WT_DESCRFA,(10-(nLenFF-6))))//SO.:0026  OS.:0248/02 FCD
oPrn:Say(MLin,QC210xCol(TCol9+1), DTOC(Work2->WT_DT_FORN))
MLin+=40 

IF lPrimPag
   lPrimPag:=.F.
   nSubAux2:=MLin-nSubAux1
ENDIF

nLinAux2:=MLin

RETURN NIL

*--------------------*
FUNCTION QC251Cab()
*--------------------*
LOCAL cabec1 :=STR0055+SWR->WR_NR_CONC //"Nr. Concorrencia.: "

IF !lPrimPag
   AVNEWPAGE
ENDIF

MLin:= 100
MPag++

oPrn:Box( MLin,10,MLin,cColFim)
MLin+=25

oPrn:Say(MLin,10,SM0->M0_NOME,aFontes:COURIER_10)
oPrn:Say(MLin,(cColFim/2),titulo,aFontes:COURIER_10,,,,2)
oPrn:Say(MLin,(cColFim-20),STR0056+STR(MPag,8),aFontes:COURIER_10,,,,1) //"Pagina..: "
MLin+=50

oPrn:Say(MLin,10,STR0057,aFontes:COURIER_10) //"SIGAEIC"
oPrn:Say(MLin,(cColFim/2),cabec1,aFontes:COURIER_10,,,,2)
oPrn:Say(MLin,(cColFim-20),STR0058+DTOC(dDataBase),aFontes:COURIER_10,,,,1) //"Emissao.: "
MLin+=50

oPrn:Box( MLin,10,MLin,cColFim)
MLin+=50

QC251SubCab() 

RETURN .T.

*--------------------*
FUNCTION QC251SubCab
*--------------------*
SA5->(DBSEEK(xFilial()+Work2->WT_COD_I+Work2->WT_FORN+EICRetLoja("Work2","WT_FORLOJ")))
SYQ->(DBSEEK(xFilial()+SWR->WR_VIA))
SB1->(DBSEEK(xFilial()+Work2->WT_COD_I))

nSubAux1:=MLin

oPrn:oFont:=aFontes:COURIER_07

oPrn:Box(MLin,0010,MLin,cColFim)//Linha
MLin+=20

oPrn:Say(MLin,QC210xCol(001), STR0061+ALLTRIM(Work2->WT_COD_I)+STR0062+MSMM(SB1->B1_DESC_GI,25,1)) //"Item.: "###" Descr.(LI): "
MLin+=40

oPrn:Say(MLin,QC210xCol(001), STR0063+ALLTRIM(TRANS(Work2->WT_QTDE,cPicQtde ))+' '+IF(!EMPTY(SA5->A5_UNID),SA5->A5_UNID,SB1->B1_UM)) //"Qtde.: "
oPrn:Say(MLin,QC210xCol(038), STR0064+DTOC(Work2->WT_DT_NEC)) //"Dt. Prev.: "
oPrn:Say(MLin,QC210xCol(068), STR0065+TRANS(SWR->WR_PER_SEG, '@E 999.9999')+' %') //"Seguro.: "
MLin+=40

oPrn:Say(MLin,QC210xCol(001), STR0066+SWR->WR_VIA+' '+LEFT(SYQ->YQ_DESCR,15)) //"Modalidade.: "
MLin+=40

nLinAux1:=MLin
oPrn:Box(MLin,0010,MLin,cColFim)//Linha
MLin+=20

oPrn:Say(MLin,QC210xCol(TCol0), STR0046) //"Fornecedor"  //AQUI SO.:0026
oPrn:Say(MLin,QC210xCol(TCol1), STR0067,,,,,1) //"Fob Total"
oPrn:Say(MLin,QC210xCol(TCol2), STR0068,,,,,1) //"Frete Total"
oPrn:Say(MLin,QC210xCol(TCol3), STR0069,,,,,1) //"Seguro"
oPrn:Say(MLin,QC210xCol(TCol4), STR0070,,,,,1) //"C.I.F"
oPrn:Say(MLin,QC210xCol(TCol5), STR0071) //"% Var"
oPrn:Say(MLin,QC210xCol(TCol6), STR0072) //"C. Pagto"
oPrn:Say(MLin,QC210xCol(TCol8), STR0073) //"Fabr" //AQUI SO.:0026
oPrn:Say(Mlin,QC210xCol(TCol9), STR0074) //"Pzo Entrega"
MLin+=40

oPrn:Box(MLin,0010,MLin,cColFim)//Linha
MLin+=40


RETURN NIL

*---------------------------------*
FUNCTION BateTraco()
*---------------------------------*
LOCAL TColAux:=20

oPrn:Box(nLinAux1,10,nLinAux2,11)
oPrn:BOX(nLinAux1,QC210xCol(TColAux)-20,nLinAux2,QC210xCol(TColAux)-20)
oPrn:BOX(nLinAux1,QC210xCol(TCol1+0.5),nLinAux2,QC210xCol(TCol1+0.5))
oPrn:BOX(nLinAux1,QC210xCol(TCol2+0.5),nLinAux2,QC210xCol(TCol2+0.5))
oPrn:BOX(nLinAux1,QC210xCol(TCol3+0.5),nLinAux2,QC210xCol(TCol3+0.5))
oPrn:BOX(nLinAux1,QC210xCol(TCol4+0.5),nLinAux2,QC210xCol(TCol4+0.5))
oPrn:BOX(nLinAux1,QC210xCol(TCol6-0.5),nLinAux2,QC210xCol(TCol6-0.5))
oPrn:BOX(nLinAux1,QC210xCol(TCol8-0.5),nLinAux2,QC210xCol(TCol8-0.5))
oPrn:BOX(nLinAux1,QC210xCol(TCol9-0.5),nLinAux2,QC210xCol(TCol9-0.5))
oPrn:Box(nLinAux1,cColFim,nLinAux2,cColFim+1)

oPrn:Box( MLin,10,MLin,cColFim)

RETURN NIL

*---------------------------------*
Function QC210xCol( pnColuna )
*---------------------------------*
Return ( pnColuna * 20 )


