#INCLUDE "Ecovc150.ch"
#include "Average.ch"
#include "AvPrint.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ECOVC150 ³ Autor ³ ALEX WALLAUER         ³ Data ³ 12/04/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Posicao de Fornecedores                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*------------------*
Function ECOVC150()
*------------------*
//LOCAL nColS := 02
//LOCAL nColG := 12
//
//LOCAL nLin  := 02
//LOCAL cTit  := STR0001, nTipo:=4 //"Posi‡Æo dos Fornecedores"
//LOCAL aItens:= {STR0002,STR0003,STR0004,STR0005} //"1-Transito"###"2-Divisas"###"3-Estoque"###"4-Todos"
Private cFilEC2 := xFilial('EC2'),cFilEC5 := xFilial('EC5'),cFilEC9:=xFilial('EC9')
Private cForn   := SPACE(LEN(SA2->A2_COD))
Private cContab := SPACE(LEN(SA2->A2_CONTAB))
Private dInicial:= AVCTOD("  /  /  ")
Private dFinal  := AVCTOD("  /  /  ")
Private cTipo  // := aItens[nTipo]
Private aWork_Stru  := {  {"WKCODFOR" ,"C",06,0} , {"WKDESFOR" ,"C",20,0} ,;
                          {"WKDTEMI"  ,"D",08,0} , {"WKINVOIC" ,"C",AVSX3("W7_INVOICE",AV_TAMANHO),0} ,;
                          {"WKHAWB"   ,"C",AVSX3("W7_HAWB",AV_TAMANHO),0} , {"WKDTVENC" ,"D",08,0} ,;
                          {"WKCONTAB" ,"C",15,0} , {"WKBU_CC"  ,"C",10,0} ,;
                          {"WKMOEDA"  ,"C",03,0} , {"WKVLINVO" ,"N",15,2} ,;
                          {"WKSLDANT" ,"N",15,2} , {"WKDTPGTO" ,"D",08,0} ,;
                          {"WKVALREG" ,"N",15,2} , {"WKAJUSDI" ,"N",15,2} ,;
                          {"WKVALPAG" ,"N",15,2} , {"WKVARCAM" ,"N",15,2} ,;
                          {"WKSLDATU" ,"N",15,2} }
Private SOMAREG := SOMAAJU := SOMAPAG := SOMAVAR :=0, cPictVl:= "@E 999,999,999,999.99"
Private DTPAGTO := CTOD(""), nOpcao := 1, lTop, cAnoMesEnc, nTotEC5:=EC5->(LASTREC()), lImp
Private aTotal := {} //LRL

SA2->(DBSETORDER(1))

cNomArq:=E_CriaTrab(,aWork_Stru,"Work")
IF ! USED()
   E_Msg(STR0002,1) //"NÆo foi poss¡vel abrir o arquivo tempor rio"
   RETURN .F.
ENDIF

Work->(avzap())
EC5->(DBSETORDER(2))

#IFDEF TOP
   lTop := .T.
#ENDIF

//ASK 12/02/07 17:48 - Incluso no AtuSx do P9R1 
//AcertaSX1()

While .T.
   cTipo := 0
   If !Pergunte("ECOVC2",.T.)
      Exit  // PLB 18/05/06
      //Return .F.
   EndIf

   cForn    := mv_par01
   cContab  := mv_par02
   dInicial := mv_par03
   dFinal   := mv_par04
   IF "AGFA" $ SM0->M0_NOME
      cTipo    := mv_par05
   ENDIF
   Do Case 
      Case cTipo = 1
         cTipo:= "T"
      Case cTipo = 2
         cTipo:= "D"
      Case cTipo = 3
         cTipo:= "E"
      OtherWise
         cTipo:= " "
   EndCase
   
   cAnoMesEnc:= STRZERO(YEAR(dInicial),4,0) + STRZERO(MONTH(dInicial),2,0)

   If !E_PERIODO_OK(@dInicial,@dFinal)
      Loop
   Endif

   If nOpcao == 1
      nTipo:= VAL(SUBSTR(cTipo,1,1))
      //cTipo:= IF(cTipo="4"," ",SUBSTR(cTipo,3,1))
      //If(cTipo="4", " ",cTipo) 

      IF EMPTY(ALLTRIM(cForn))
         EC5->(DBSEEK(cFilEC5))
         IF EC5->(EOF())
            E_Msg(STR0011,1) //"NÆo exitem registros para estas condiçõess"
            LOOP
         ENDIF
      ELSE
         EC5->(DBSEEK(cFilEC5+cForn,.T.))
         IF EC5->EC5_FORN # cForn .OR. EC5->(EOF())
            E_Msg(STR0011,1) //"NÆo exitem registros para estas condiçõess"
            LOOP
         ENDIF
      ENDIF

      ContaReg()
      VC150Rel()

      //If(VC150Val('OK'), VC150Rel, )
   ElseIf nOpcao == 0

   EXIT
   EndIf

EndDo

EC5->(DBSETORDER(1))
If Select("Work") > 0
// WORK->(DBCLOSEAREA())
   WORK->(E_EraseArq(cNomArq))  // PLB 18/05/06
EndIf
RETURN .F.

*-----------------------*
Function VC150Rel()
*-----------------------*
//LOCAL nCont:=500

Private cDesc1       := STR0045 //"Este programa tem como objetivo imprimir relatório de"
Private cDesc2       := STR0046 //"Relatório de Posição de Fornecedores"
Private cDesc3       := "", cPict := "", imprime := .T.
Private titulo       := STR0047 //"RELATÓRIO DE POSICAO DE FORNECEDORES"
Private nLin         := 80, Cabec1 :="",Cabec2 := ""
Private cString      := "EC5"//, CbTxt := ""//, lEnd := .F.
Private lAbortPrint  := .F., limite:= 220, tamanho:= "G"
Private nomeprog     := "ECOVC150", nTipo := 18
Private aReturn      :={STR0048, 1,STR0049, 1, 2, 1, "",1 } //"Zebrado"###"Contabil"
Private nLastKey     := 0, cbtxt := Space(10), cbcont := 00
Private CONTFL       := 01, m_pag := 01, aOrd:={}
Private wnrel        := "ECOVC150" // Coloque aqui o nome do arquivo usado para impressao em disco

wnrel := SetPrint(cString,Nomeprog,"",titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho)

If nLastKey = 27
   Return
Endif

SetDefault(aReturn,cString)

Processa({||VC150Imprime()},STR0013) //"Pesquisando Processos..."

Return .T.

*------------------------------*
Static Function VC150Imprime()
*------------------------------*
Local i
nLin    := 9999
nPag    := 0000

nLimPage:= 65
nColIni := 000
nColFim := 220

nCol1_1:= nColIni+23; nCol1_2:=nCol1_1+11 ; nCol1_3:=nCol1_2+23; nCol1_4:=nCol1_3+20
nCol1_5:= nCol1_4+26   ; nCol1_6:=nCol1_5+26 ; nCol1_7:=nCol1_6+26; nCol1_8:=nCol1_7+26
nCol1_9:=nCol1_8+26

lPri:= lPri_FORN:= .T.
MImp_Det:= lQuebrou:= .F.

cAnoMesEnc:= STRZERO(YEAR(dInicial),4,0) + STRZERO(MONTH(dInicial),2,0)
MFORN_ANT := SPACE(06)
MINV_ANT  := SPACE(15)

MTSAL_ANT := MTVARIACAO:= MTGACERTO  := MGSAL_ANT:= MGSAIDA     := 0
MTENTRADA := MTGSAL_ANT:= MTGSAIDA   := MGFOB_TOT:= MGVARIACAO  := 0
MTACERTO  := MTGFOB_TOT:= MTGVARIACAO:= MGENTRADA:= MGSALDO     := 0
MTSAIDA   := MTGENTRADA:= MTGSALDO   := MGACERTO := MSLD_FOB_TOT:= 0
MFOBTOTAL := 0


EC9->(DBSETORDER(1))
EC5->(DBSETORDER(2))
EC5->(DBSEEK(cFilEC5))
ProcRegua(nTotEC5)

oDlgProc := GetWndDefault()
nCount:=0

DO WHILE ! EC5->(EOF()) .AND. EC5->EC5_FILIAL==cFilEC5   

   nCount++
   IncProc("Lendo Registro: "+STR(nCount,10)+" /"+STR(nTotEC5,10))
   oDlgProc:SetText(  STR0050+ALLTRIM(EC5->EC5_FORN)+" / "+ALLTRIM(EC5->EC5_INVOIC)) //"Imprimindo Forn. / Inv.:"
      
   IF !EC9->(DBSEEK(cFilEC9+EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC))
      EC5->(DBSKIP())
      LOOP
   ENDIF

   IF !EMPTY(ALLTRIM(EC5->EC5_VCFANO+EC5->EC5_VCFMES))
      IF EC5->EC5_VCFANO+EC5->EC5_VCFMES <= cAnoMesEnc
         EC5->(DBSKIP())
         LOOP
      ENDIF
   ENDIF

   IF EC5->EC5_AMOS $ cSim
      EC5->(DBSKIP())
      LOOP
   ENDIF

   IF !EMPTY(ALLTRIM(cForn)) .AND. EC5->EC5_FORN # cForn
      EXIT
   ENDIF

   SA2->(DBSEEK(xFilial()+EC5->EC5_FORN))

   IF ! EMPTY(ALLTRIM(cContab)) .AND. SA2->A2_CONTAB # cContab
      EC5->(DBSKIP())
      LOOP
   ENDIF

   IF !EMPTY(cTipo) .AND. EC5->EC5_T_D # cTipo
      EC5->(DBSKIP())
      LOOP
   ENDIF

   IF EC5->EC5_INVOIC+EC5->EC5_IDENTC # MINV_ANT

      IF !lPri .AND. MImp_Det
         MTSALDO:= MTSAL_ANT + MTENTRADA + MTACERTO + MTVARIACAO - MTSAIDA
         IF !lQuebrou
            //nLin-- // -=nPula
         ELSE
            lQuebrou:=.F.
         ENDIF
         
         // COMPARA O SALDO DO FOB COM O FOB TOTAL
         If MSLD_FOB_TOT <> MFOBTOTAL
            nLin++ //+=nPula
         Endif
         MTGFOB_TOT := MTGFOB_TOT + MSLD_FOB_TOT
         @ nLin,nCol1_5-27 Psay TRANS(MSLD_FOB_TOT,cPictVl)//@ nLin,nCol1_3-2 Psay TRANS(MSLD_FOB_TOT,cPictVl)
         @ nLin,nCol1_9-5 Psay TRANS(MTSALDO,cPictVl)
         GeraWork(MTSALDO,.F.)

         nLin++ //+=nPula

      ENDIF

      MINV_ANT := EC5->EC5_INVOIC+EC5->EC5_IDENTC

   ENDIF

   IF EC5->EC5_FORN # MFORN_ANT
      IF lPri
         lPri:=.F.
      ELSE
          VC150_Total()
      ENDIF
      lPri_FORN  := .T.
      MFORN_ANT  := EC5->EC5_FORN
      MINV_ANT   := EC5->EC5_INVOICE+EC5->EC5_IDENTCT
      MTGFOB_TOT := 0
      MTGSAL_ANT := 0
      MTGENTRADA := 0
      MTGACERTO  := 0
      MTGSAIDA   := 0
      MTGVARIACAO:= 0
   ENDIF

   IF nLin > nLimPage
      VC150_CAB()
   ENDIF

   MImp_Det     := .F.
   MSLD_FOB_TOT := EC5->EC5_FOB_TO
   MFOBTOTAL    := EC5->EC5_FOB_TO

   VC150_Det()

//   GeraWork(,.T.)

   nRec := EC5->(Recno())   // ACSJ - 04/04/2005 
   EC5->(DBSKIP())   
ENDDO

IF nPag > 0

   MTSALDO := MTSAL_ANT + MTENTRADA + MTACERTO + MTVARIACAO - MTSAIDA

   IF MImp_Det      
      
      // Total da Invoice
      MTGFOB_TOT := MTGFOB_TOT + MSLD_FOB_TOT
       
      nLin++
      @ nLin,nCol1_3-2 Psay TRANS(MSLD_FOB_TOT,cPictVl)
      @ nLin,nCol1_9-5 Psay TRANS(MTSALDO,cPictVl)
      GeraWork(MTSALDO,.F.)
      nLin++
   ENDIF
   EC5->(DBGoTo(nRec))  // ACSJ - 04/04/2005
   VC150_Total()
   //nLin-- //-=nPula2
   //VC150_BateCol()
 
   //MGSALDO := MGSAL_ANT + MGENTRADA + MGACERTO + MGVARIACAO - MGSAIDA
   IF nLin > nLimPage -8
         VC150_CAB()
   ENDIF
   //LRL 25/06/04--------------------------------------------------------------------------------
   nLin++  
   nLin++ 
   @ nLin,nColIni PSay __PrtThinLine()
   nLin++ 
   @ nLin,nColIni   Psay STR0015 //"Total Geral"
   For i:=1 to Len(aTotal)
      aTotal[i,2]:= aTotal[i,3] + aTotal[i,5] + aTotal[i,6] + aTotal[i,8] - aTotal[i,7] 
      IF nLin > nLimPage -3
         VC150_CAB()
      ENDIF      
      @ nLin,nCol1_1   Psay aTotal[i,1]
      @ nLin,nCol1_3-2 Psay TRANS(aTotal[i,4],cPictVl) //070 nCol1_4
      @ nLin,nCol1_4   Psay TRANS(aTotal[i,3],cPictVl)  // 091
      @ nLin,nCol1_5-1 Psay TRANS(aTotal[i,5],cPictVl)  // 112
      @ nLin,nCol1_6   Psay TRANS(aTotal[i,6],cPictVl)  // 133
      @ nLin,nCol1_7-3 Psay TRANS(aTotal[i,7],cPictVl)  // 154
      @ nLin,nCol1_8-2 Psay TRANS(aTotal[i,8],cPictVl)  // 177
      @ nLin,nCol1_9-5 Psay TRANS(aTotal[i,2],cPictVl)  // 198
      nLin++
   Next    
   If Empty(aTotal)
      nLin++
   Endif   
   @ nLin,nColIni PSay __PrtThinLine()
   aTotal:={}
   //---------------------------------------------------------------------------------------------
   /*
   nLin++ 
   @ nLin,nColIni PSay __PrtThinLine()
   nLin++
   @ nLin,nColIni   Psay STR0015 //"Total Geral"
   @ nLin,nCol1_4   Psay TRANS(MGSAL_ANT ,cPictVl)  // 091
   @ nLin,nCol1_5-1 Psay TRANS(MGENTRADA ,cPictVl)  // 112
   @ nLin,nCol1_6   Psay TRANS(MGACERTO  ,cPictVl)  // 133
   @ nLin,nCol1_7-3 Psay TRANS(MGSAIDA   ,cPictVl)  // 154
   @ nLin,nCol1_8-2 Psay TRANS(MGVARIACAO,cPictVl)  // 177
   @ nLin,nCol1_9-5 Psay TRANS(MGSALDO   ,cPictVl)  // 198
   nLin++
   @ nLin,nColIni PSay __PrtThinLine()
   */
ENDIF

Set Printer To
Commit
Ourspool(wnrel)

MS_FLUSH()

RETURN .T.

*-------------------*
FUNCTION VC150_CAB()
*-------------------*
LOCAL cTexto2:=STR0017+ DTOC(dInicial) +STR0018+ DTOC(dFinal)+"  "+; //"DATA INICIAL.: "###"   DATA FINAL.: "
               IF("AGFA" $ SM0->M0_NOME,IF(cTipo='D',STR0019,; //"Divisas"
               IF(cTipo='E',STR0020,; //"Estoque"
               IF(EMPTY(cTipo),STR0021,STR0022))),'') //"Geral"###"Transito"

lQuebrou:=.T.

cabec1:= ALLTRIM(SM0->M0_NOME)+" - "+ALLTRIM(SM0->M0_FILIAL)+Space(80)
cabec2:= STR0051+Space(nColFim/2-30)+cTexto2 //"Sigaeco"

Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
nLin:= 09
nPag++

@ nLin,nColIni Psay STR0025 //"         FORNECEDOR"
@ nLin,nCol1_1 Psay STR0026 //"  DATA"
@ nLin,nCol1_2 Psay STR0027 //"       INVOICE"
@ nLin,nCol1_3 Psay STR0028 //"VALOR DA INVOICE"
@ nLin,nCol1_4 Psay STR0029 //"   SALDO ANTERIOR"
@ nLin,nCol1_5 Psay STR0030 //"VALOR DE REGISTRO"
@ nLin,nCol1_6 Psay STR0031 //"AJUSTE D.I./N.F.E."
@ nLin,nCol1_7 Psay STR0032 //"     PAGAMENTOS"
@ nLin,nCol1_8 Psay STR0033 //"VARIACAO CAMBIAL"
@ nLin,nCol1_9 Psay STR0034 //"  SALDO ATUAL" 
nLin++
@ nLin,nColIni PSay __PrtThinLine()
nLin++

RETURN

*--------------------*
FUNCTION VC150_Det()
*--------------------*
SOMAREG := 0
SOMAAJU := 0
SOMAPAG := 0
SOMAVAR := 0
DTPAGTO := CTOD("")
MTSAL_ANT:=0

VC150ACUM_SALANT()

IF !MImp_Det
   RETURN .F.
ENDIF

IF EC9->(EOF()) .OR. EC9->EC9_FILIAL # cFilEC9 .OR.;
   EC9->EC9_INVOIC # EC5->EC5_INVOIC           .OR.;
   EC9->EC9_IDENTC # EC5->EC5_IDENTC           .OR.;
   EC5->EC5_FORN # EC9->EC9_FORN
   EC9->(DBSKIP(-1))
ENDIF


IF lPri_FORN
   lImp:= .T.
   SA2->(DBSEEK(xfILIAL()+EC5->EC5_FORN))

   @ nLin,nColIni Psay EC5->EC5_FORN+" "+SA2->A2_NREDUZ

   nLin++

   //@ nLin,nColIni Psay STR0035+SA2->A2_CONTAB // c 15 //"C.Contab.: "
   //nLin-- //=nPula

   lPri_FORN := .F.

ENDIF

// Localiza o Nº da DI no EC2
EC2->(DBSEEK(cFilEC2+EC5->EC5_HAWB+EC5->EC5_FORN+EC5->EC5_MOE_FOB+EC5->EC5_IDENTC))
@ nLin,nCol1_2-10 Psay DTOC(EC5->EC5_DT_EMI)
@ nLin,nCol1_3-20 Psay ALLTRIM(EC5->EC5_INVOIC) // c 15
@ nLin,nCol1_4-20 Psay STR0036+EC5->EC5_HAWB // c 17 //"Hawb.: "
@ nLin,nCol1_5-21 Psay STR0037+DTOC(EC5->EC5_DT_VEN) //c 8 //"Vencto.: "

nLin++

If lImp
   @ nLin,nColIni Psay STR0035+SA2->A2_CONTAB // c 15 //"C.Contab.: "
   lImp:= .F.
Endif

@ nLin,nCol1_3-20 Psay STR0038+EC5->EC5_IDENTC // c 10 //"BU./CC.: "
@ nLin,nCol1_4-20 Psay STR0044+TRANS(EC2->EC2_DI_NUM,AVSX3('EC2_DI_NUM')[6]) // c 10 // "D.I.: "  
@ nLin,nCol1_5-27 Psay TRANS(MTSAL_ANT,cPictVl)
nLin++
@ nLin,nCol1_4-26 Psay EC5->EC5_MOE_FO+" "+TRANS(EC5->EC5_FOB_TO,cPictVl)

lQuebrou   := .F.
//MTGFOB_TOT := MTGFOB_TOT + EC5->EC5_FOB_TO
MTENTRADA  := 0
MTACERTO   := 0
MTSAIDA    := 0
MTVARIACAO := 0

DO WHILE !EC9->(EOF()) .AND. EC9->EC9_FILIAL==cFilEC9 .AND.;
          EC9->EC9_INVOIC == EC5->EC5_INVOIC          .AND.;
          EC9->EC9_IDENTC == EC5->EC5_IDENTC          .AND.;
          EC9->EC9_FORN == EC5->EC5_FORN

   oDlgProc:SetText(  STR0050+ALLTRIM(EC9->EC9_FORN)+" / "+ALLTRIM(EC5->EC5_INVOIC)) //"Imprimindo Forn. / Inv.:"

   IF nLin > nLimPage
      VC150_CAB()
   ENDIF

// IF (EMPTY(dInicial) .OR. EC9->EC9_DT_LAN >= dInicial) .AND.;
//    (EMPTY(dFinal  ) .OR. EC9->EC9_DT_LAN <= dFinal  )

   IF EC9->EC9_DT_LAN  >= dInicial .AND. EC9->EC9_DT_LAN <= dFinal

      IF EC9->EC9_ID_CAM = "101"
         @ nLin,nCol1_1 Psay DTOC(EC9->EC9_DTCONT)
         @ nLin,nCol1_5 Psay TRANS(VC150_Real(EC9->EC9_VALOR,EC9->EC9_DT_LAN),cPictVl)
         DTPAGTO := EC9->EC9_DTCONT
         SOMAREG += VC150_Real(EC9->EC9_VALOR,EC9->EC9_DT_LAN)
         nLin++//=nPula

         lQuebrou   := .F.
         MTENTRADA  := MTENTRADA  + VC150_Real(EC9->EC9_VALOR,EC9->EC9_DT_LAN)
         MTGENTRADA := MTGENTRADA + VC150_Real(EC9->EC9_VALOR,EC9->EC9_DT_LAN)
      ENDIF

      IF EC9->EC9_ID_CAM = "201"
         @ nLin,nCol1_1 Psay DTOC(EC9->EC9_DTCONT)
         @ nLin,nCol1_6 /*nCol1_7*/ Psay TRANS(VC150_Real(EC9->EC9_VALOR,EC9->EC9_DT_LAN),cPictVl)    // GFP - 12/04/2012 - Ajuste na posição do valor no relatorio.
         DTPAGTO := EC9->EC9_DTCONT
         SOMAAJU += VC150_Real(EC9->EC9_VALOR,EC9->EC9_DT_LAN)
         nLin++//=nPula

         lQuebrou  := .F.
         MTACERTO  := MTACERTO  + VC150_Real(EC9->EC9_VALOR,EC9->EC9_DT_LAN)
         MTGACERTO := MTGACERTO + VC150_Real(EC9->EC9_VALOR,EC9->EC9_DT_LAN)
      ENDIF

      IF SUBSTR(EC9->EC9_ID_CAM,1,1) = "6"
         @ nLin,nCol1_1 Psay DTOC(EC9->EC9_DTCONT)
         @ nLin,nCol1_7 Psay TRANS(VC150_Real(EC9->EC9_VALOR,EC9->EC9_DT_LAN),cPictVl)
         DTPAGTO := EC9->EC9_DTCONT
         SOMAPAG += VC150_Real(EC9->EC9_VALOR,EC9->EC9_DT_LAN)
         nLin++//=nPula

         lQuebrou:= .F.
         MTSAIDA :=MTSAIDA + VC150_Real(EC9->EC9_VALOR,EC9->EC9_DT_LAN)
         MTGSAIDA:=MTGSAIDA+ VC150_Real(EC9->EC9_VALOR,EC9->EC9_DT_LAN)
         MSLD_FOB_TOT := MSLD_FOB_TOT - EC9->EC9_VL_MOE   && LAB 11.09.98

      ENDIF

      IF SUBSTR(EC9->EC9_ID_CAMP,1,1)  $ "5/7"
         @ nLin,nCol1_1 Psay DTOC(EC9->EC9_DTCONT)
         @ nLin,nCol1_8 Psay TRANS(VC150_Real(EC9->EC9_VALOR,EC9->EC9_DT_LAN),cPictVl)
         DTPAGTO := EC9->EC9_DTCONT
         SOMAVAR += VC150_Real(EC9->EC9_VALOR,EC9->EC9_DT_LAN)
         nLin++//=nPula

         lQuebrou    := .F.
         MTVARIACAO  := MTVARIACAO + VC150_Real(EC9->EC9_VALOR,EC9->EC9_DT_LAN)
         MTGVARIACAO := MTGVARIACAO+ VC150_Real(EC9->EC9_VALOR,EC9->EC9_DT_LAN)
      ENDIF
   ENDIF

   EC9->(DBSKIP())

   IF DTOS(EC9->EC9_DT_LAN) > DTOS(dFinal)
      EXIT
   ENDIF

ENDDO
GeraWork(,.T.)
RETURN .T.

*----------------------------------*
FUNCTION VC150_Real(PValor,PData)
*----------------------------------*
LOCAL MMes,MAno,MRetorno

MMes := MONTH(dInicial)
MAno := YEAR(dInicial)

IF ( MMes >= 7 .AND. MAno = 1994 ) .OR. MAno >= 1995
   IF PData < AVCTOD("01/07/94")
      MRetorno := PValor / 2750
   ELSE
      MRetorno := PValor
   ENDIF
ELSE
   MRetorno := PValor
ENDIF

RETURN VAL(STR(MRetorno,15,2))    && LAB 03.05.00

*----------------------*
FUNCTION VC150_Total()
*----------------------*
LOCAL nPos
MTGSALDO := MTGSAL_ANT + MTGENTRADA + MTGACERTO + MTGVARIACAO - MTGSAIDA

IF VAL(STR(MTGSAL_ANT + MTGENTRADA + MTGACERTO + MTGVARIACAO + MTGSAIDA,15,2)) <> 0

   nLin++
   @ nLin,nColIni PSay __PrtThinLine()
   nLin++
   @ nLin, nColIni  Psay STR0039 //"Total do Fornecedor"
   @ nLin,nCol1_3-2 Psay TRANS(MTGFOB_TOT ,cPictVl) //070 nCol1_4
   @ nLin,nCol1_4   Psay TRANS(MTGSAL_ANT ,cPictVl) //091 nCol1_5
   @ nLin,nCol1_5-1 Psay TRANS(MTGENTRADA ,cPictVl) //112 nCol1_6
   @ nLin,nCol1_6   Psay TRANS(MTGACERTO  ,cPictVl) //133 nCol1_7
   @ nLin,nCol1_7-3 Psay TRANS(MTGSAIDA   ,cPictVl) //154 nCol1_8
   @ nLin,nCol1_8-2 Psay TRANS(MTGVARIACAO,cPictVl) //177 nCol1_9
   @ nLin,nCol1_9-5 Psay TRANS(MTGSALDO   ,cPictVl) //198 nCol1_10
   nLin++ //+=nPula
/*
   MGSAL_ANT := MGSAL_ANT + MTGSAL_ANT
   MGFOB_TOT := MGFOB_TOT + MTGFOB_TOT
   MGENTRADA := MGENTRADA + MTGENTRADA
   MGACERTO  := MGACERTO  + MTGACERTO
   MGSAIDA   := MGSAIDA   + MTGSAIDA
   MGVARIACAO:= MGVARIACAO+ MTGVARIACAO
*/
   //LRL 25/06/04--------------------------------------------------------------------------------
   nPos := ASCAN(aTotal,{ |x| x[1] =EC5->EC5_MOE_FO}) //LRL
   if nPos = 0             
      AADD(aTotal,{EC5->EC5_MOE_FO,0,MTGSAL_ANT,MTGFOB_TOT,MTGENTRADA,MTGACERTO,MTGSAIDA,MTGVARIACAO}) 
   else
      aTotal[nPos,2] += 0
      aTotal[nPos,3] += MTGSAL_ANT
      aTotal[nPos,4] += MTGFOB_TOT
      aTotal[nPos,5] += MTGENTRADA
      aTotal[nPos,6] += MTGACERTO
      aTotal[nPos,7] += MTGSAIDA
      aTotal[nPos,8] += MTGVARIACAO       
   endif
   //----------------------------------------------------------------------------------------------

ENDIF

RETURN

*---------------------------*
FUNCTION VC150ACUM_SALANT()
*---------------------------*
//LOCAL nRec := EC9->(RECNO())

DO WHILE !EC9->(EOF()) .AND. EC9->EC9_FILIAL==cFilEC9 .AND.;
          EC9->EC9_INVOIC == EC5->EC5_INVOIC          .AND.;
          EC9->EC9_IDENTC == EC5->EC5_IDENTC          .AND.;
          EC9->EC9_FORN == EC5->EC5_FORN

   oDlgProc:SetText(  STR0050+ALLTRIM(EC9->EC9_FORN)+" / "+ALLTRIM(EC5->EC5_INVOIC)) //"Imprimindo Forn. / Inv.:"

//DO WHILE .NOT. EOF() .AND. EC9_INVOICE+EC9_IDENTCT = Invoice_Ctb->EC5_INVOICE+Invoice_Ctb->EC5_IDENTCT

// IF (EMPTY(dInicial) .OR. EC9->EC9_DT_LAN >= dInicial) .AND.;
//    (EMPTY(dFinal  ) .OR. EC9->EC9_DT_LAN <= dFinal  )

   IF EC9->EC9_DT_LAN <= dFinal .AND. EC9->EC9_DT_LAN >= dInicial     && so' imprimir com movto
      MImp_Det := .T.
   ENDIF

   IF EC9->EC9_DT_LAN >= dInicial
      EXIT
   ENDIF

   IF EC9->EC9_ID_CAM $ "101/201/501/502/503/504/505/506/507/701/702"
      MTSAL_ANT := MTSAL_ANT + VC150_Real(EC9->EC9_VALOR,EC9->EC9_DT_LAN)
   ELSE
      MSLD_FOB_TOT := MSLD_FOB_TOT- EC9->EC9_VL_MOE
      MTSAL_ANT    := MTSAL_ANT   - VC150_Real(EC9->EC9_VALOR,EC9->EC9_DT_LAN)
   ENDIF

   EC9->(DBSKIP())

ENDDO

IF MTSAL_ANT < -1 .or. MTSAL_ANT > 1    && so' imprimir com saldos <> 0
   MImp_Det := .T.
ENDIF

MTGSAL_ANT := MTGSAL_ANT + MTSAL_ANT

//EC9->(DBGOTO(nRec))

RETURN

*-----------------------*
Function VC150Val(cTipo)
*-----------------------*

If cTipo = '0' .OR. cTipo = 'OK'
   IF !EMPTY(mv_par01) .AND. !SA2->(DBSEEK(xFilial()+mv_par01))
      Help(" ",1,"AVG0005302") //E_Msg(STR0040,1) //"Fornecedor nÆo cadastrado."
      Return .F.
   ENDIF
EndIf

If cTipo = '1' .OR. cTipo = 'OK'
   IF EMPTY(mv_par03)
      Help(" ",1,"AVG0005339") //E_Msg(STR0041,1) //"Data inicial n„o preenchida."
      Return .F.
   ENDIF
EndIf

If cTipo = '2' .OR. cTipo = 'OK'
   IF EMPTY(mv_par04)
      Help(" ",1,"AVG0005340") //E_Msg(STR0042,1) //"Data final n„o preenchida."
      Return .F.
   ENDIF
EndIf

If cTipo = 'OK'
   IF DTOS(mv_par03) > DTOS(mv_par03)
      Help(" ",1,"AVG0005341") //E_Msg(STR0043,1) //"Data final menor que a inicial."
      Return .F.
   ENDIF
EndIf

Return .T.

*---------------------------------------------------------------------------------------*
FUNCTION GERAWORK(TSALDO,lAPPEND)
*---------------------------------------------------------------------------------------*
DBSELECTAREA("WORK")

IF lAPPEND
   WORK->(DBAPPEND())   
			WORK->WKCODFOR :=	EC5->EC5_FORN
			WORK->WKDESFOR := SA2->A2_NREDUZ
			WORK->WKDTEMI  := EC5->EC5_DT_EMI
			WORK->WKINVOIC := EC5->EC5_INVOIC
			WORK->WKHAWB   := EC5->EC5_HAWB  
			WORK->WKDTVENC := EC5->EC5_DT_VEN
			WORK->WKCONTAB := SA2->A2_CONTAB 
			WORK->WKBU_CC  := EC5->EC5_IDENTC
			WORK->WKMOEDA  := EC5->EC5_MOE_FO
			WORK->WKVLINVO := MSLD_FOB_TOT //EC5->EC5_FOB_TO
			WORK->WKSLDANT := MTSAL_ANT      
			WORK->WKDTPGTO := DTPAGTO       
			WORK->WKVALREG := SOMAREG       
			WORK->WKAJUSDI := SOMAAJU       
			WORK->WKVALPAG := SOMAPAG       
			WORK->WKVARCAM := SOMAVAR       
ELSE
			WORK->WKSLDATU := IF(!EMPTY(TSALDO),TSALDO,0)
ENDIF   

RETURN.T.
//ASK 12/02/07 17:48 - Incluso no AtuSx do P9R1 
/*
*--------------------------*
Static Function AcertaSX1()
*--------------------------*
If !SX1->(dbSeek("ECOVC2"+"01"))
   SX1->(RecLock("SX1",.T.))
   SX1->X1_GRUPO   := "ECOVC2"
   SX1->X1_ORDEM   := "01"
   SX1->X1_VARIAVL := "MV_CH1"
   SX1->X1_VAR01   := "MV_PAR01"
   SX1->X1_PERGUNT := "Fornecedor"
   SX1->X1_PERSPA  := ""
   SX1->X1_PERENG  := ""
   SX1->X1_TIPO    := "G"
   SX1->X1_TAMANHO := 06
   SX1->X1_PRESEL  := 0
   SX1->X1_GSC     := "G"
   SX1->X1_VALID   := "VC150Val('0')"
   SX1->X1_CNT01   := ""
   SX1->X1_DEF01   := ""
   SX1->X1_DEF02   := ""
   SX1->X1_F3      := "SA2"
   SX1->(msUnlock())

   If !SX1->(dbSeek("ECOVC2"+"02"))
      SX1->(RecLock("SX1",.T.))
      SX1->X1_GRUPO   := "ECOVC2"
      SX1->X1_ORDEM   := "02"
      SX1->X1_VARIAVL := "MV_CH2"
      SX1->X1_VAR01   := "MV_PAR02"
      SX1->X1_PERGUNT := "Conta Contabil"
      SX1->X1_PERSPA  := ""
      SX1->X1_PERENG  := ""
      SX1->X1_TIPO    := "C"
      SX1->X1_TAMANHO := 15
      SX1->X1_PRESEL  := 0
      SX1->X1_GSC     := "G"
      SX1->X1_VALID   := ""
      SX1->X1_CNT01   := ""
      SX1->X1_DEF01   := ""
      SX1->X1_DEF02   := ""
      SX1->X1_DEF03   := ""
      SX1->X1_F3      := ""
      SX1->(msUnlock())
   Endif

   If !SX1->(dbSeek("ECOVC2"+"03"))
      SX1->(RecLock("SX1",.T.))
      SX1->X1_GRUPO   := "ECOVC2"
      SX1->X1_ORDEM   := "03"
      SX1->X1_VARIAVL := "MV_CH3"
      SX1->X1_VAR01   := "MV_PAR03"
      SX1->X1_PERGUNT := "Dt. Inicial Contab."
      SX1->X1_PERSPA  := ""
      SX1->X1_PERENG  := ""
      SX1->X1_TIPO    := "D"
      SX1->X1_TAMANHO := 08
      SX1->X1_PRESEL  := 0
      SX1->X1_GSC     := "G"
      SX1->X1_VALID   := "VC150Val('1')"
      SX1->X1_CNT01   := ""
      SX1->X1_DEF01   := ""
      SX1->X1_DEF02   := ""
      SX1->X1_DEF03   := ""
      SX1->X1_F3      := ""
      SX1->(msUnlock())
   Endif

   If !SX1->(dbSeek("ECOVC2"+"04"))
      SX1->(RecLock("SX1",.T.))
      SX1->X1_GRUPO   := "ECOVC2"
      SX1->X1_ORDEM   := "04"
      SX1->X1_VARIAVL := "MV_CH4"
      SX1->X1_VAR01   := "MV_PAR04"
      SX1->X1_PERGUNT := "Dt. Final Contab."
      SX1->X1_PERSPA  := ""
      SX1->X1_PERENG  := ""
      SX1->X1_TIPO    := "D"
      SX1->X1_TAMANHO := 08
      SX1->X1_PRESEL  := 0
      SX1->X1_GSC     := "G"
      SX1->X1_VALID   := "VC150Val('2')"
      SX1->X1_CNT01   := ""
      SX1->X1_DEF01   := ""
      SX1->X1_DEF02   := ""
      SX1->X1_DEF03   := ""
      SX1->X1_F3      := ""
      SX1->(msUnlock())
   Endif
   
   IF "AGFA" $ SM0->M0_NOME
      SX1->(RecLock("SX1",.T.))
      SX1->X1_GRUPO   := "ECOVC2"
      SX1->X1_ORDEM   := "05"
      SX1->X1_VARIAVL := "MV_CH5"
      SX1->X1_VAR01   := "MV_PAR05"
      SX1->X1_PERGUNT := "Tipo"
      SX1->X1_PERSPA  := ""
      SX1->X1_PERENG  := ""
      SX1->X1_TIPO    := "C"
      SX1->X1_TAMANHO := 1
      SX1->X1_PRESEL  := 4
      SX1->X1_GSC     := "C"
      SX1->X1_VALID   := ""
      SX1->X1_CNT01   := ""
      SX1->X1_DEF01   := "1-Transito"
      SX1->X1_DEF02   := "2-Divisas"
      SX1->X1_DEF03   := "3-Estoque"
      SX1->X1_DEF04   := "4-Todos"
      SX1->X1_DEF05   := ""
      SX1->X1_F3      := ""
      SX1->(msUnlock())
   Endif
EndIf

Return .T.
*/
                                                
*---------------------------*
Static Function ContaReg()
*---------------------------*
Local cQueryEC5, cWhereEC5
Local cCondEC5:=   " AND D_E_L_E_T_ <> '*'"// AND EC9.D_E_L_E_T_  <> '*' AND SA2.D_E_L_E_T_  <> '*'"
Local cCondAsEC5:= " AND @DELETED@ <> '*'"// AND EC9.@DELETED@ <> '*' AND SA2.@DELETED@ <> '*'"

//nTotEC5  := 0

IF lTop

  cAliasEC5   := "EC5TMP"

  // Where EC5
/*cWhereEC5:= " EC5.EC5_FILIAL='"+ cFilEC5 +"' AND EC9.EC9_FILIAL='"+cFilEC9+"' "
  If !Empty(cForn)
     cWhereEC5+=" AND EC5.EC5_FORN = '"+cForn+"'"
  Endif
  
  
  cWhereEC5+= " AND EC5.EC5_FORN = EC9.EC9_FORN "
  

  cWhereEC5+=" AND EC5.EC5_INVOIC = EC9.EC9_INVOIC AND EC5.EC5_IDENTC = EC9.EC9_IDENTC "
  
  cWhereEC5+=" AND ((EC5.EC5_VCFANO+EC5.EC5_VCFMES) = '' OR (EC5.EC5_VCFANO+EC5.EC5_VCFMES) = ' ' "
  cWhereEC5+=" OR (EC5.EC5_VCFANO+EC5.EC5_VCFMES) <= '"+cAnoMesEnc+"') AND EC5.EC5_AMOS NOT IN('"+cSim+"')"

  If !Empty(cContab)  
     cWhereEC5+=" AND EC5.EC5_FORN = SA2.A2_COD AND SA2.A2_CONTAB = '"+cContab+"'"
  Endif

  If !Empty(cTipo) .And. "AGFA" $ SM0->M0_NOME
     cWhereEC5+=" AND EC5.EC5_T_D = '"+cTipo+"'"
  Endif
 
  cWhereEC5+= If(TcSrvType()<>"AS/400",cCondEC5,cCondAsEC5)  

  cQueryEC5:= " SELECT DISTINCT EC5.EC5_FILIAL, EC5.EC5_FORN, EC5.EC5_INVOIC, EC5.EC5_IDENTC, "
  cQueryEC5+= " EC5.EC5_VCFANO, EC5.EC5_VCFMES, EC5.EC5_AMOS, EC9.EC9_FILIAL, EC9.EC9_FORN ,"
  cQueryEC5+= " EC9.EC9_INVOIC, EC9.EC9_IDENTC FROM "+RetSqlName("EC5")+ " EC5, "+RetSqlName("EC9")+ " EC9, "
  cQueryEC5+= RetSqlName("SA2")+ " SA2 WHERE "+cWhereEC5*/

  //AWR - 18/04/2007 - Não há necessidade de uma SELECT com todas as condicoes
  cQueryEC5:="SELECT COUNT(*) TOTAL FROM "+RetSqlName("EC5")+" WHERE EC5_FILIAL = '"+ cFilEC5 +"'"
  cQueryEC5+= If(TcSrvType()<>"AS/400",cCondEC5,cCondAsEC5)  
  // EC5
  cQueryEC5 := ChangeQuery(cQueryEC5)
  DbUsearea(.T.,"TOPCONN", TCGenQry(,,cQueryEC5), cAliasEC5,.F.,.T.)
  IF !USED()
     MSGINFO("Nao foi possivel executar a SELECT : "+ALLTRIM(cQueryEC5))
     RETURN .F.
  ENDIF
  
  dbSelectArea(cAliasEC5)
  IF (cAliasEC5)->TOTAL # 0
     nTotEC5:=(cAliasEC5)->TOTAL
  ENDIF
//Do While !(cAliasEC5)->(EOF())
//   nTotEC5++
//   (cAliasEC5)->(dbSkip())
//EndDo
  
  If Select(cAliasEC5) > 0  
     (cAliasEC5)->(DbCloseArea())
  Endif   
  
Else

  // EC5
  EC5->(DbSeek(cFilEC5,.T.))
//EC9->(DbSeek(cFilEC9,.T.))
  
  EC5->(DBEVAL({||nTotEC5++, MsProcTxt("Lendo Invoice "+EC5->EC5_INVOIC)},,{||EC5->(!EOF()) .And. EC5->EC5_FILIAL = cFilEC5}))// .And.;
//             If(!Empty(cForn), cForn = EC5->EC5_FORN , .T.) .And. EC5->EC5_FORN = EC9->EC9_FORN .And. EC5->EC5_INVOIC = EC9->EC9_INVOIC .And.;
//             EC5->EC5_IDENTC = EC9->EC9_IDENTC .And. (!Empty((EC5->EC5_VCFANO+EC5->EC5_VCFMES)) .And. (EC5->EC5_VCFANO+EC5->EC5_VCFMES) <= cAnoMesEnc) .And.;
//             EC5->EC5_AMOS $ cSim .And. If(!Empty(cCcont), (EC5->EC5_FORN = SA2->A2_COD .And. SA2->A2_CONTAB = cCcont), .T.) .And.;
//             If(!Empty(cTipo) .And. "AGFA" $ SM0->M0_NOME, EC5->EC5_T_D = cTipo, .T.) })) //"Lendo Invoice "

Endif

Return .T.
