#INCLUDE "Ecoiv150.ch"
#include "AVERAGE.CH"
#include "AvPrint.ch"

#define TITULO STR0001 //"Consulta de Invoices por Fornecedor"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ECOIV150  ³ Autor ³Cristiano A. Ferreira ³ Data ³ 13.04.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta de Invoices por Fornecedor                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ void ECOIV150()                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ECOIV150()

ECOIV150R3(.T.)
Return .t.

FUNCTION ECOIV150R3(p_R4)

LOCAL cFileWork,i
LOCAL aStruct := { {"EC5_INVOIC",,,},;
                   {"EC5_IDENTC",,,},;
                   {"EC5_DT_EMI",,,},;
                   {"EC5_MOE_FO",,,},;
                   {"EC5_FOB_TO",,,},;
                   {"EC5_DT_CAM",,,},;
                   {"EC5_FORN"  ,,,},;
                   {"EC5_NR_CON",,,},;
                   {"EC5_SIS_OR",,,},;
                   {"EC5_T_D"   ,,,},;
                   {"EC5_CD_PGT",,,} }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para a MSSELECT                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lInverte := .F., cMarca := GetMark()
Private oSelect
Private nOpcA

Private aCampos := { {"EC5_FORN"  ,,AVSX3("EC5_FORN")[5]},;
                   {"EC5_INVOIC",,AVSX3("EC5_INVOIC")[5]},;
                   {"EC5_IDENTC",,AVSX3("EC5_IDENTC")[5]},;
                   {"EC5_DT_EMI",,AVSX3("EC5_DT_EMI")[5]},;
                   {"EC5_MOE_FO",,AVSX3("EC5_MOE_FO")[5]},;
                   {"EC5_FOB_TO",AVSX3("EC5_FOB_TO")[6],AVSX3("EC5_FOB_TO")[5]},;
                   {{||TRB->EC5_CD_PGT+'-'+BuscaCondPagto(TRB->EC5_CD_PGT)},,AVSX3("EC5_CD_PGT")[5]},;
                   {"EC5_DT_CAM",,AVSX3("EC5_DT_CAM")[5]},;
                   {"EC5_NR_CON",,AVSX3("EC5_NR_CON")[5]},;
                   {{||IF(TRB->EC5_T_D='E',STR0002,IF(TRB->EC5_T_D='D',STR0003,STR0004))},,AVSX3("EC5_T_D")[5]} } //'Estoque'###'Divisas '###'Transito'

Private cForn := EC5->EC5_FORN, nOpcao := 1
Private lTop:= .F., oProcess, nTotEC5:=0, lEnd, lRet
Private lR4       := If(p_R4==NIL,.F.,p_R4) .AND. FindFunction("TRepInUse") .And. TRepInUse()
Private cCabec
Private Cabec1       
Private Cabec2       
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao do arquivo de trabalho                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For i:=1 To Len(aStruct)
   aStruct[i][2] := AVSx3(aStruct[i][1])[2] // Tipo
   aStruct[i][3] := AVSx3(aStruct[i][1])[3] // Tamanho
   aStruct[i][4] := AVSx3(aStruct[i][1])[4] // Decimal
Next


cFileWork := E_CriaTrab(, aStruct, "TRB")

IndRegua("TRB",cFileWork+TEOrdBagExt(),"EC5_FORN")

Set Index To (cFileWork+TEOrdBagExt())


#IFDEF TOP
   lTop := .T.
#ENDIF

DO WHILE .T.
   
   lRet:= .T.

   If !Pergunte("ECOIV1",.T.)
      Exit
   Endif

   cForn := mv_par01
   nOpcao:= mv_par02

   ContaReg()

   oProcess:=  MsNewProcess():New({|lEnd| IV150Grava(@lEnd) },STR0030,STR0031,.T.) //"Contábil"###"Gerando Relatório"
   oProcess:Activate()

   If nOpcA == 0
      Exit
   Endif

ENDDO

TRB->(E_EraseArq(cFileWork))

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³IV150Valid ³ Autor ³Cristiano A. Ferreira ³ Data ³ 13.04.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia da Entrada de dados do programa ECOIV150      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ IV150Valid(cCampo) => Retorno True (Ok), False para Cancel ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCampo => Campo a ser consistido                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ IV150Get                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION IV150Valid(cCampo)

DO CASE
   CASE cCampo == "FORN"

      If !Empty(mv_par01)
         If ! ExistCpo("SA2",mv_par01)
            Return .f.
         Endif

         EC5->(dbSetOrder(2))
         IF ! EC5->(dbSeek(xFilial()+mv_par01))
            // Mensagem de Advertencia. - By A. Caetano Jr. 15/12/2003
            MsgInfo(STR0012, STR0006) //"Não há registros a serem consultados !"###"Informação"
            Return .F.
         Endif
      Endif

ENDCASE

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³IV150Grava ³ Autor ³Cristiano A. Ferreira ³ Data ³ 13.04.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava dados no arquivo de trabalho                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ void IV150Grava(cForn,nOpcao)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cForn => fornecedor                                        ³±±
±±³          ³ nOpcao=> 1=Nao contabilizados, 2=Contabilizados, 3=Ambos   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ECOIV150                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION IV150Grava(lEnd)
Local nCont := 1, i
Private oPanel //LRL 02/06/04
//ProcRegua( TOTREGUA )

TRB->(avzap())

EC5->(dbSetOrder(2))
If !Empty(cForn)
   EC5->(dbSeek(xFilial()+cForn))
Else
   EC5->(dbSeek(xFilial()))
Endif

oProcess:SetRegua1(2)
oProcess:IncRegua1(STR0032) //"Lendo Arquivos 1 / 2 Invoices Contabeis"

oProcess:SetRegua2(nTotEC5)

DO WHILE ! EC5->(EOF()) .And. EC5->EC5_FILIAL == xFilial("EC5")

   //IF nCont < TOTREGUA
   //   IncProc()
   //   nCont ++
   //Else

   //Endif
   
   If lEnd
      If lEnd:=MsgYesNo(STR0033,STR0034) //"Tem certeza que deseja cancelar?"###"Atenção"
         MS_FLUSH()
         lRet:= .F.
         Return lRet
      EndIf
   EndIf   

   IF ! Empty(cForn)
      IF EC5->EC5_FORN <> cForn
         Exit
      ENDIF
   ENDIF

   IF nOpcao == 1
      IF Val(EC5->EC5_NR_CON) > 0
         EC5->(dbSkip())
         LOOP
      ENDIF
   ENDIF

   IF nOpcao == 2
      IF Val(EC5->EC5_NR_CON) <= 0
         EC5->(dbSkip())
         LOOP
      ENDIF
   ENDIF

   oProcess:IncRegua2(STR0035+Alltrim(EC5->EC5_INVOIC)) //"1 / 1 Invoice "

   TRB->(dbAppend())

   TRB->EC5_INVOIC := EC5->EC5_INVOIC
   TRB->EC5_IDENTC := EC5->EC5_IDENTC
   TRB->EC5_DT_EMI := EC5->EC5_DT_EMI
   TRB->EC5_MOE_FO := EC5->EC5_MOE_FO
   TRB->EC5_FOB_TO := EC5->EC5_FOB_TO
   TRB->EC5_DT_CAM := EC5->EC5_DT_CAM
   TRB->EC5_FORN   := EC5->EC5_FORN
   TRB->EC5_NR_CON := EC5->EC5_NR_CON
   TRB->EC5_SIS_OR := EC5->EC5_SIS_OR
   TRB->EC5_T_D    := EC5->EC5_T_D
   TRB->EC5_CD_PGT := EC5->EC5_CD_PGT

   EC5->(dbSkip())
ENDDO

IF TRB->(EasyRecCount("TRB")) == 0
   // Mensagem de Advertencia. - By A. Caetano Jr. 15/12/2003
   MsgInfo(STR0005,STR0006) //"Não há registros a serem processados !"###"Informação"
   Return .F.
Endif

TRB->(dbGoTop())

   DO WHILE .T. .And. lRet
      nOpcA := 0

      oMainWnd:ReadClientCoors()
      DEFINE MSDIALOG oDlg TITLE TITULO ;
             FROM oMainWnd:nTop+125  ,oMainWnd:nLeft+5 ;
             TO   oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd PIXEL
      @00,00 MsPanel oPanel Prompt "" Size 60,20 of oDlg
      dbSelectArea("TRB")
      oSelect :=MsSelect():New("TRB",,,aCampos,@lInverte,@cMarca,{34,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
	  
	  oPanel:Align:=CONTROL_ALIGN_TOP //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	  oSelect:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

      DEFINE SBUTTON FROM 3,(oDlg:nClientWidth-4)/2-30 TYPE 6 ACTION (nOpcA:=2,oDlg:End()) ENABLE OF oPanel

      ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpcA:=1,oDlg:End()},;
                                                {||nOpcA:=0,oDlg:End()})) //02/06/04 //LRL //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

      DO CASE
         CASE nOpcA == 0  // Cancel
              Exit

         CASE nOpcA == 1 // Ok
              Exit

         CASE nOpcA == 2 // Imprimir
              If(lR4, (oReport := ReportDef(),oReport:PrintDialog()),IV150Imprime(lEnd))
              Exit
      ENDCASE
   ENDDO

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³IV150Imprim³ Autor ³Cristiano A. Ferreira ³ Data ³ 13.04.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Impressao do arquivo de trabalho                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ void IV150Imprim()                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ECOIV150                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION IV150Imprime(lEnd)


Local cFornecedor
Local nCol1:=0, nCol2:=nCol1+28, nCol3:=nCol2+16, nCol4:=nCol3+16, nCol5:=nCol4+12
Local nCol6:=nCol5+04, nCol7:=nCol6+19, nCol8:=nCol7+10, nCol9:=nCol8+12

Private cDesc1       := STR0037 //"Este programa tem como objetivo imprimir relatório "
Private cDesc2       := STR0038 //"Consulta de Invoices por Fornecedor"
Private cDesc3       := "", cPict := "", imprime := .T.
Private titulo       := STR0039 //"Relatório de Invoices"
Private nLin         := 80 
Private cString      := "EC5", CbTxt := ""
Private lAbortPrint  := .F., limite:= 80, tamanho:= "M"
Private nomeprog     := "ECOIV150", nTipo := 18
Private aReturn        :={ STR0046, 1,STR0047, 1, 2, 1, "",1 } //"Zebrado"###"Importacao"
Private nLastKey     := 0,  cbcont := 00
Private CONTFL       := 01, m_pag := 01, aOrd:={}, lRet:=.T.
Private wnrel        := "ECOIV150" // Coloque aqui o nome do arquivo usado para impressao em disco
Cabec1       := ALLTRIM(SM0->M0_NOME)+" - "+ALLTRIM(SM0->M0_FILIAL)+Space(83)+STR0044+If(Empty(cForn), STR0045, cForn) //"Código: "###"Todos"
Cabec2       := STR0040+Space(107)+If(nOpcao==1, STR0041, If(nOpcao==2, STR0042, STR0043)) //"Sigaeco"###"Não Contabilizados"###"Contabilizados"###"Ambos"
cbtxt := Space(10)
wnrel := SetPrint(cString,Nomeprog,"",titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho)

If nLastKey = 27
   Return
Endif

SetDefault(aReturn,cString)

nTipo := If(aReturn[4]==1,15,18)

oProcess:IncRegua1(STR0048) //"Lendo Arquivo Temporário 2 / 2 Gerando Relatório"
oProcess:SetRegua2(TRB->(EasyRecCount("TRB")))

TRB->(dbGoTop())

DO WHILE !TRB->(EOF())
   
   oProcess:IncRegua2(STR0049+Alltrim(TRB->EC5_INVOIC)) //"1 / 1 Invoice "

   IF nLin > 67
      IV150Cabec() //cForn,@nLinha,@nPage,nOpcao)
      @nLin,nCol1 PSAY Transf(TRB->EC5_FORN, AVSX3("EC5_FORN")[6])+" "+BuscaFabr_For(TRB->EC5_FORN)
   ENDIF

   IF TRB->EC5_FORN <> cFornecedor
      cFornecedor := TRB->EC5_FORN
      @nLin,nCol1 PSAY Transf(TRB->EC5_FORN, AVSX3("EC5_FORN")[6])+" "+BuscaFabr_For(TRB->EC5_FORN)
   ENDIF

   @nLin,nCol2 PSAY TRB->EC5_INVOIC
   @nLin,nCol3 PSAY TRB->EC5_IDENTC
   @nLin,nCol4 PSAY Dtoc(TRB->EC5_DT_EMI)
   @nLin,nCol5 PSAY TRB->EC5_MOE_FO
   @nLin,nCol6 PSAY Transf(TRB->EC5_FOB_TO,AVSX3("EC5_FOB_TO")[6])
   @nLin,nCol7 PSAY IF(TRB->EC5_T_D='E',STR0002,IF(TRB->EC5_T_D='D',STR0003,STR0004)) //'Estoque'###'Divisas '###'Transito'
   @nLin,nCol8 PSAY TRB->EC5_NR_CON
   @nLin,nCol9 PSAY Dtoc(TRB->EC5_DT_CAM)

   nLin++

   TRB->(dbSkip())
ENDDO

If TRB->(BOF()) .And. TRB->(EOF())
   Help(" ",1,"AVG0005206") //Msginfo(STR0041, STR0042) //"Nao ha registros a serem Impressos.
   lRet:= .F.
Else   
   Set Printer To
   Commit
   Ourspool(wnrel)
Endif

MS_FLUSH()

Return lRet

*------------------------------*
FUNCTION IV150Cabec()
*------------------------------*
LOCAL  nColun:=0


Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
nLin:= 09

@ nLin,nColun Psay STR0050 //"    Fonecedor                  Invoice       B.U./C.Custo   Dt. Emissão Moeda   Valor Fob       Status   Nr. Contab. Dt. Contab.
nLin++
@ nLin,nColun Psay "=========================== =============== =============== =========== ===== ================ ========= =========== ==========="
nLin++

Return .T.

/*ASK 12/02/07 17:48 - Incluso no AtuSx do P9R1
*----------------------------*
Static Function AcertaSX1()
*----------------------------*
If !SX1->(dbSeek("ECOIV1"+"01"))
   SX1->(RecLock("SX1",.T.))
   SX1->X1_GRUPO   := "ECOIV1"
   SX1->X1_ORDEM   := "01"
   SX1->X1_VARIAVL := "MV_CH1"
   SX1->X1_VAR01   := "MV_PAR01"
   SX1->X1_PERGUNT := "Fornecedor"
   SX1->X1_PERSPA  := ""
   SX1->X1_PERENG  := ""
   SX1->X1_TIPO    := "C"
   SX1->X1_TAMANHO := 06
   SX1->X1_PRESEL  := 0
   SX1->X1_GSC     := "G"
   SX1->X1_VALID   := "IV150Valid('FORN')"
   SX1->X1_CNT01   := ""
   SX1->X1_DEF01   := ""
   SX1->X1_DEF02   := ""
   SX1->X1_F3      := "SA2"
   SX1->(msUnlock())

   If !SX1->(dbSeek("ECOIV1"+"02"))
      SX1->(RecLock("SX1",.T.))
      SX1->X1_GRUPO   := "ECOIV1"
      SX1->X1_ORDEM   := "02"
      SX1->X1_VARIAVL := "MV_CH2"
      SX1->X1_VAR01   := "MV_PAR02"
      SX1->X1_PERGUNT := "Tipo de Relatorio"
      SX1->X1_PERSPA  := ""
      SX1->X1_PERENG  := ""
      SX1->X1_TIPO    := "N"
      SX1->X1_TAMANHO := 01
      SX1->X1_PRESEL  := 0
      SX1->X1_GSC     := "C"
      SX1->X1_VALID   := ""
      SX1->X1_CNT01   := ""
      SX1->X1_DEF01   := "1-Nao Contab."
      SX1->X1_DEF02   := "2-Contabilizados"
      SX1->X1_DEF03   := "3-Ambos"
      SX1->X1_F3      := ""
      SX1->(msUnlock())
   Endif

EndIf

Return .T.
  */
*-------------------------*
Static Function ContaReg()
*-------------------------*
Local cQueryEC5, cAliasEC5, cWhereEC5, cFilEC5:= xFilial("EC5")
Local cCondEC5:=" AND EC5.D_E_L_E_T_ <> '*' ",  cCondAsEC5:= " AND EC5.@DELETED@ <> '*' "

nTotEC5:= 0

If lTop

  cAliasEC5    := "EC5TMP"

  // Where EC5
  cWhereEC5:= " EC5.EC5_FILIAL='"+ cFilEC5 +"' "
  If !Empty(cForn)
     cWhereEC5+=" AND EC5.EC5_FORN = '"+cForn+"' "
  Endif

  If nOpcao == 1 //Não contabilizados
     cWhereEC5+=" AND (EC5.EC5_NR_CON = '0000' OR EC5.EC5_NR_CON = '0000') "
  Endif

  If nOpcao == 2 //Contabilizados
     cWhereEC5+=" AND (EC5.EC5_NR_CON <> '' OR EC5.EC5_NR_CON <> ' ') "
  Endif

  cWhereEC5+= If(TcSrvType()<>"AS/400",cCondEC5,cCondAsEC5)

  // Query EC5
  cQueryEC5 := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EC5")+ " EC5 WHERE "+cWhereEC5
  
  hFile:=EasyCreateFile("Thomaz.txt")
  fwrite(hFile, cQueryEC5)
  fclose(hFile)
          
  cQueryEC5 := ChangeQuery(cQueryEC5)
  DbUsearea(.T.,"TOPCONN", TCGenQry(,,cQueryEC5), cAliasEC5,.F.,.T.)          
          
  If Select(cAliasEC5) > 0
     nTotEC5 := (cAliasEC5)->TOTALREG
     (cAliasEC5)->(DbCloseArea())
  Else
     nTotEC5:= 0
  Endif
  
Else

  // EC5
  EC5->(DbSeek(cFilEC5,.T.))
  
  // Nick 14/04/2006 - Ajuste na Função MsAguarde pois estava pela metade
  EC5->(DBEVAL({||nTotEC5++, MsAguarde({|| MsProcTxt("Lendo Invoice "+EC5->EC5_INVOIC),},"")},,{||EC5->(!EOF()) .And. EC5->EC5_FILIAL = cFilEC5 .And. ;
               If(!Empty(cForn), EC5->EC5_FORN == cForn, .T.) .And.;
               If(nOpcao == 1, Empty(EC5->EC5_NR_CON), If(nOpcao == 2, !Empty(EC5->EC5_NR_CON), .T. )) })) //"Lendo Invoice "

Endif

Return .T.

//TRP - 14/08/2006 - Definições do relatório personalizável
***************************
Static Function ReportDef()
***************************
//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTabelas := {"EC5"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := { }

//Cria o objeto principal de controle do relatório.
//Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("ECOIV150",STR0039,"ECOIV1",{|oReport| ReportPrint(oReport)},STR0037+ " " + STR0038)

//Define o objeto com a seção do relatório
oSecao1 := TRSection():New(oReport,"Invoices",aTabelas,aOrdem) 

//Define o objeto com a seção do relatório
oSecao2 := TRSection():New(oReport,"Cabeçalho",{""},aOrdem)

//Definição das colunas de impressão da seção 1
TRCell():New(oSecao1,"EC5_FORN"         ,"TRB"   ,STR0010      ,AVSX3("EC5_FORN")[6]               ,AVSX3("EC5_FORN",3)+AVSX3("EC5_FORNDE",3),/*lPixel*/, {|| TRB->EC5_FORN+" "+BuscaFabr_For(TRB->EC5_FORN) }  )
TRCell():New(oSecao1,"EC5_INVOIC"       ,"TRB"   ,STR0022      ,/*Picture*/                        ,/*Tamanho*/                              ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"EC5_IDENTC"       ,"TRB"   ,STR0023      ,/*Picture*/                        ,/*Tamanho*/                              ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"EC5_DT_EMI"       ,"TRB"   ,STR0024      ,/*Picture*/                        ,/*Tamanho*/                              ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"EC5_MOE_FO"       ,"TRB"   ,STR0025      ,/*Picture*/                        ,/*Tamanho*/                              ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"EC5_FOB_TO"       ,"TRB"   ,STR0026      ,AVSX3("EC5_FOB_TO")[6]             ,/*Tamanho*/                              ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"EC5_T_D"          ,"TRB"   ,STR0027      ,/*Picture*/                        ,Max(Max(Len(STR0002),Len(STR0003)),Len(STR0004))    ,/*lPixel*/,{||IF(TRB->EC5_T_D='E',STR0002,IF(TRB->EC5_T_D='D',STR0003,STR0004))})  // PLB 27/03/07 - Ajuste do Tamanho
TRCell():New(oSecao1,"EC5_NR_CON"       ,"TRB"   ,STR0028      ,/*Picture*/                        ,/*Tamanho*/                              ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"EC5_DT_CAM"       ,"TRB"   ,STR0029      ,/*Picture*/                        ,/*Tamanho*/                              ,/*lPixel*/,/*{|| code-block de impressao }*/)

AEval(oReport:Section("Invoices"):aCell, {|X| X:SetColSpace(2) } )
oReport:Section("Invoices"):Cell("EC5_IDENTC"   ):SetColSpace(5)
oReport:Section("Invoices"):Cell("EC5_FOB_TO"   ):SetColSpace(5)


//Definição das colunas de impressão da seção 2
TRCell():New(oSecao2,"Cabecalho"   ,""   , ""                     ,"@!"                               ,210                     ,/*lPixel*/,{||cCabec})

//oReport:Section("Seção 2"):Cell("Titulo"):SetCellBreak()
oReport:bOnPageBreak :={||cCabec:=Cabec1,oReport:Section("Cabeçalho"):PrintLine(),cCabec:=Cabec2,oReport:Section("Cabeçalho"):PrintLine(),oReport:FatLine()} 

//Necessário para carregar os perguntes mv_par**
Pergunte(oReport:uParam,.F.)

Return oReport

************************************
Static Function ReportPrint(oReport)
************************************
Local cFornecedor := ""
Cabec1       := ALLTRIM(SM0->M0_NOME)+" - "+ALLTRIM(SM0->M0_FILIAL)+Space(83)+STR0044+If(Empty(cForn), STR0045, cForn) //"Código: "###"Todos"
Cabec2       := STR0040+Space(107)+If(nOpcao==1, STR0041, If(nOpcao==2, STR0042, STR0043)) //"Sigaeco"###"Não Contabilizados"###"Contabilizados"###"Ambos"

//Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.

TRPosition():New(oReport:Section("Invoices"),"EC5",1,{|| xFilial("EC5") + TRB->EC5_FORN})

//oSection:Print()
oReport:SetMeter(TRB->(EasyRecCount("TRB")))
TRB->( dbGoTop() )

//Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("Invoices"):Init()

//Inicio da impressão da seção 2. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("Cabeçalho"):Init()

//Para desabilitar a impressão da página de parâmetros do pergunte
//oReport:oParamPage:Disable()

//Laço principal
Do While TRB->(!EoF()) .And. !oReport:Cancel()
   IF cFornecedor != TRB->EC5_FORN
      cFornecedor := TRB->EC5_FORN
      //oReport:Section("Invoices"):lVis := .T.
      oReport:Section("Invoices"):Cell("EC5_FORN"):Show()  // PLB 27/03/07
   ELSE
      //oReport:Section("Invoices"):lVis := .F.   
      oReport:Section("Invoices"):Cell("EC5_FORN"):Hide()  // PLB 27/03/07
   ENDIF
   oReport:Section("Invoices"):PrintLine() //Impressão da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso
   
   TRB->( dbSkip() )
EndDo

//Fim da impressão da seção 1
oReport:Section("Invoices"):Finish()
//Fim da impressão da seção 2
oReport:Section("Cabeçalho"):Finish() 

Return .T.
*----------------------------------------------------------------------------*
*     FIM DO PROGRAMA ECOIV150.PRW                                           *
*----------------------------------------------------------------------------*
