#INCLUDE "ECOMV150.ch"
#include "Average.ch"
#include "AvPrint.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ECMV150  ³ Autor ³ ALEX WALLAUER         ³ Data ³ 19/04/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Relatorio de Movimentacao de Contas                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs: Manutenção realizada por Thomaz(TAN) em 12/06/02                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Trocar AvPrint por SetPrint e                              ³±±
±±³            Say e Get por Pergunte(SX1)                                ³±±
±±³                                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

*------------------*                       
Function ECOMV150()
*------------------*
#DEFINE PIC_CONTA  AVSX3('EC7_CTA_DB')[6]
#DEFINE PIC_VALOR  AVSX3('EC7_VALOR')[6]
#DEFINE PIC_LINK   AVSX3('EC7_LINK')[6]
#DEFINE PIC_DI     AVSX3('EC7_DI_NUM')[6]

Local nOpcao:= 1

Private cModo := "", aModo :={}, bFor, lTop:= .F.
Private cFilEC7 := xFilial('EC7'), oProcess
Private cFilECA := xFilial('ECA'), cFilEEC:=xFilial("EEC")
Private cIdentCt := SPACE(LEN(EC7->EC7_IDENTC))
Private cConta  := SPACE(LEN(EC7->EC7_CTA_DB))
Private dInicial:= CTOD(""), dFinal  := CTOD("")
Private lFinan := EasyGParam("MV_EFF", .F., .F.), lPrint := .F.
Private nCol1:= 00, nCol2:=nCol1+12, nCol3:=nCol2+08, nCol4:=nCol3+18
Private nCol5:=nCol4+21, nCol6:=nCol5+18, nCol7:=nCol6+41, nCol8:=nCol7+25
Private nCol9:=nCol8+22
private cTPMODU := ""
private bTPMODUECF
Private lExtEcf:=ECF->(FIELDPOS("ECF_CONTAB"))>0
aModo := {STR0035, STR0036, STR0037, STR0038, STR0039} //"1- Importação"###"2- Exportação"###"3- Financ. Imp."###"4- Financ. Exp."###"5- Todos"
cModo := aModo[1]

#IFDEF TOP
   lTop := .T.
#ENDIF

EC7->(DBSETORDER(4))
ECA->(DBSETORDER(7))
ECC->(DBSETORDER(1))
//ECH->(DBSETORDER(1))               
ECF->(DBSETORDER(7))
cFilECF := xFilial('ECF')
   cTPMODU:='EXPORT'
   bTPMODUECF := {|| ECF->ECF_TPMODU = 'EXPORT' }

While .T.

   If !Pergunte("ECOMV1",.T.)
      Return .F.
   EndIf

   dInicial := mv_par01
   dFinal   := mv_par02
   cConta   := mv_par03
   cIdentCt := mv_par04
   cModo    := mv_par05

   If !E_PERIODO_OK(@dInicial,@dFinal)
      Loop
   Endif

   If nOpcao == 1
      lPrint := .F.
      If(MV150Val('OK'), MV150Rel(), )
   ElseIf nOpcao == 0
      Exit
   EndIf

EndDo

//Retorna os Indices Default
EC6->(DBSETORDER(1))
EC7->(DBSETORDER(1))
ECA->(DBSETORDER(1))
//ECH->(DBSETORDER(1))
ECF->(DBSETORDER(1))

Return .T.

*------------------*
Function MV150Rel()
*------------------*
Private cDesc1       := STR0055 //"Este programa tem como objetivo imprimir relatório "
Private cDesc2       := STR0056 //"Movimentação de Contas - Contábil"
Private cDesc3       := "", cPict := "", imprime := .T.
Private titulo       := STR0001 //"MOVIMENTACAO DE CONTAS"
Private nLin         := 80, Cabec1 :=STR0049+Space(87)+STR0057+DTOC(dInicial)+STR0058+DTOC(dFinal),Cabec2 := "" //"SIGAECO"###"Período de "###" a "
Private cString      := "ECF", CbTxt := "", lEnd := .F.
Private lAbortPrint  := .F., limite:= 220, tamanho:= "G"
Private nomeprog     := "ECOMV150", nTipo := 18
Private aReturn        :={ STR0059, 1,STR0060, 1, 2, 1, "",1 } //"Zebrado"###"Importacao"
Private nLastKey     := 0,  cbcont := 00
Private CONTFL       := 01, m_pag := 01, aOrd:={}
Private wnrel        := "ECOMV150" // Coloque aqui o nome do arquivo usado para impressao em disco
Private nTotECA:= nTotECF:= nTotEC7:= 0
cbtxt := Space(10)
wnrel := SetPrint(cString,Nomeprog,"",titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho)

If nLastKey = 27
   Return
Endif

SetDefault(aReturn,cString)

nTipo := If(aReturn[4]==1,15,18)

MV150ContaReg()

oProcess := MsNewProcess():New({|lEnd| MV150Imprime(@lEnd) },STR0062,STR0063,.T.) //"Contábil"###"Gerando Relatório"
oProcess:Activate()

Return .T.

*-----------------------------------------*
Function MV150Imprime(lEnd)
*-----------------------------------------*
Private nCont, lRet:= .T., cModAux := Space(6)

nLin:= 9999; nPag:= 0000; nLimPage:=55

nVlr_Cre:= 0
nVlr_Deb:= 0

//nCont:=500
//ProcRegua(nCont)
oProcess:SetRegua1(3)
oProcess:IncRegua1(STR0064) //"Lendo Arquivos 1 / 3 Movimentação de Contas"

oProcess:SetRegua2(nTotEC7)

If Str(cModo, 1) $ "1/5"

   DBSELECTAREA("EC7")
   EC7->(DBSEEK(cFilEC7+DTOS(dInicial),.T.))

   DO WHILE EC7->(!EOF()) .AND. EC7->EC7_FILIAL == cFilEC7 .AND. EC7->EC7_DT_CON <= dFinal

      If lEnd
         If lEnd:=MsgYesNo(STR0065, STR0066) //"Tem certeza que deseja cancelar?"###"Atenção"
            MS_FLUSH()
            Return .F.
         EndIf
      EndIf      

      IF !EMPTY(cConta) .AND. cConta # EC7->EC7_CTA_DB .AND. cConta # EC7->EC7_CTA_CR
         EC7->(DBSKIP())
         LOOP
      ENDIF

      IF !EMPTY(cIdentCt) .AND. cIdentCt # EC7->EC7_IDENTCT
         EC7->(DBSKIP())
         LOOP
      ENDIF

      IF nLin > nLimPage
         MV150_Cab()
      ENDIF
      
//    oProcess:IncRegua2(STR0067+STR0068+Alltrim(EC7->EC7_PREEMB)+STR0069+Alltrim(EC7->EC7_INVOIC)) //"1 / 1 "###"Processo "###" Inv: "
      oProcess:IncRegua2(STR0067+STR0068+Alltrim(EC7->EC7_HAWB)+STR0069+Alltrim(EC7->EC7_INVOIC)) //"1 / 1 "###"Processo "###" Inv: "      
      EC7->(MV150_Det("EC7_"))
      EC7->(DBSKIP())

   ENDDO

Endif

Do Case
   Case Str(cModo, 1) == "1"
      cModAux := "IMPORT"
   Case Str(cModo, 1) == "2"
      cModAux := "EXPORT"
   Case Str(cModo, 1) == "3"
      cModAux := "XXXXXX"
   Case Str(cModo, 1) == "4"
      cModAux := "FIEX"
EndCase

If Str(cModo, 1) == "5"
   ECA->(DBSEEK(cFilECA))
Elseif Str(cModo, 1) == "4"
   If !ECA->(DBSEEK(cFilECA+If(!Empty(cModAux), cModAux+'01', ""),.T.))
      ECA->(DBSEEK(cFilECA+If(!Empty(cModAux), cModAux+'02', ""),.T.))
   Endif
Else
   ECA->(DBSEEK(cFilECA+If(!Empty(cModAux), cModAux, "")+DTOS(dInicial),.T.))
Endif

oProcess:IncRegua1(STR0070) //Lendo Arquivos 2 / 3 Prévia Contábil"

oProcess:SetRegua2(nTotECA)

DO WHILE ECA->(!EOF()) .AND. ECA->ECA_FILIAL == cFilECA  .AND.;
   If(Str(cModo, 1) <> "5", If(Str(cModo, 1)="4", Left(ECA->ECA_TPMODU,4), ECA->ECA_TPMODU) = cModAux, .T.)
   
   If lEnd
      If lEnd:=MsgYesNo(STR0065,STR0066) //"Tem certeza que deseja cancelar?","Atenção"
         MS_FLUSH()
         Return .F.
      EndIf
   EndIf    

   If ECA->ECA_DT_CON < dInicial .Or. ECA->ECA_DT_CON > dFinal
      ECA->(DbSkip())
      Loop
   Endif

   IF !EMPTY(cConta) .AND. cConta # ECA->ECA_CTA_DB .AND. cConta # ECA->ECA_CTA_CR
      ECA->(DBSKIP())
      LOOP
   ENDIF

      IF !EMPTY(cIdentCt) .AND. cIdentCt # ECA->ECA_IDENTCT
         ECA->(DBSKIP())
         LOOP
      ENDIF            
        
      IF nLin > nLimPage
         MV150_Cab()
      ENDIF
      
      oProcess:IncRegua2(STR0067+STR0068+Alltrim(ECA->ECA_PREEMB)+STR0069+Alltrim(ECA->ECA_INVEXP)) //"1 / 1 "###"Processo "###" Inv: "
      ECA->(MV150_Det("ECA_"))
      ECA->(DBSKIP())

ENDDO

//If lExisteECF

   oProcess:IncRegua1(STR0071) //"Lendo Arquivos 3 / 3 Eventos do Pagto Antec./Adiant."
    
   oProcess:SetRegua2(nTotECF) //500
   
   ECF->(DBSETORDER(7))
   DBSELECTAREA("ECF")
   ECF->(DBSEEK(cFilECF+cTPMODU+DTOS(dInicial),.T.))

   DO WHILE ECF->(!EOF())              .AND.;
            ECF->ECF_FILIAL == cFilECF .AND.;
            ECF->ECF_DTCONT <= dFinal  .and.;
            Eval(bTPMODUECF)
      
      If lEnd
         If lEnd:=MsgYesNo(STR0065,STR0066) //"Tem certeza que deseja cancelar?","Atenção")
            MS_FLUSH()
            Return .F.
         EndIf
      EndIf            

      If Str(cModo,1) == "3"   //Financ. Importação
         ECF->(dbSkip())
         Loop           
      Endif

      If ECF->ECF_ORIGEM == "CO" .And. !Str(cModo,1) $ "4/5"  // Financiamento da Exportação
         ECF->(dbSkip())
         Loop
      Endif

      If ECF->ECF_ORIGEM == "EX" .And. !Str(cModo,1) $ "2/5"  // Exportação
         ECF->(dbSkip())
         Loop
      Endif

      If lExtEcf .AND. ECF->ECF_CONTAB $ '2'  // Verifica se o evento é para ser contabilizado ou nao.
         ECF->(DbSkip())
         Loop
      Endif

      //IF nCont > 1
      //   IncProc(STR0054) //"3-3 Imprimindo Pagatos. Antecipados / Adiantamentos..."
      //    nCont--
      //ELSE

      //ENDIF

      IF nLin > nLimPage
         MV150_Cab()
      ENDIF

      IF !EMPTY(cConta) .AND. cConta # ECF->ECF_CTA_DB .AND.;
                              cConta # ECF->ECF_CTA_CR
         ECF->(DBSKIP())
         LOOP
      ENDIF

      IF !EMPTY(cIdentCt) .AND. cIdentCt # ECF->ECF_IDENTCT
         ECF->(DBSKIP())
         LOOP
      ENDIF

      oProcess:IncRegua2(STR0067+STR0068+Alltrim(ECF->ECF_PREEMB)+STR0069+Alltrim(ECF->ECF_INVEXP)) //"1 / 1 "###"Processo "###" Inv: "

      ECF->(MV150_Det("ECF_"))
      ECF->(DBSKIP())

   ENDDO

   //FOR I:= 1 TO nCont
   //     IncProc(STR0054) //"3-3 Imprimindo Pagatos. Antecipados / Adiantamentos..."
   //NEXT

//Endif

If !lPrint
   Help(" ",1,"AVG0005206") //Msginfo(STR0041, STR0042) //"Nao ha registros a serem Impressos.
   lRet:= .F.
Else
   SOMATOTAL()
   
   Set Printer To
   Commit
   Ourspool(wnrel)

Endif

MS_FLUSH()

Return lRet

*-------------------*
FUNCTION MV150_Cab()
*-------------------*
Local cModalid 
Local cTexto3:=STR0014+IF(EMPTY(cConta),STR0015,ALLTRIM(cConta)) //"Conta: "###"Todas"
Local cTexto4:=STR0016+IF(EMPTY(cIdentCt),STR0015,ALLTRIM(cIdentCt)) //"  -  Unid. Requi.: "###"Todas"
Local cTexto5, nColun:= 00

If Str(cModo, 1) == "1"
   cModalid := STR0043 //"Importação"
ElseIf Str(cModo, 1) == "2"
   cModalid := STR0044 //"Exportação"
ElseIf Str(cModo, 1) == "3"
   cModalid := STR0045 //"Financ. Imp."
ElseIf Str(cModo, 1) == "4"
   cModalid := STR0046 //"Financ. Exp."
ElseIf Str(cModo, 1) == "5"
   cModalid := STR0047 //"Todos"
Endif

cTexto5 := STR0048+cModalid //"Modalidade "

cabec2:= cTexto5+Space(85)+cTexto3+Space(76)+cTexto4

Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
nLin:= 09

@ nLin,nColun Psay STR0072 //" Data       Lcto      C. Partida           Débito              Crédito                    Histórico                       Processo                  Invoice                 Documento"
nLin++
@ nLin,nColun Psay "========    ====    ===============    =================    =================    =================================    =====================    =====================    ================="
nLin++

Return .T.

*----------------------------*
FUNCTION MV150_Det(MArq)
*----------------------------*
lPrint := .T.

IF nLin > nLimPage
   MV150_Cab()
ENDIF

@nLin,nCol1 PSAY DTOC(FIELDGET(FIELDPOS(MArq+If(MArq="ECF_","DTCONT","DT_CON"))))
@nLin,nCol2 PSAY TRANS(FIELDGET(FIELDPOS(MArq+"LINK")), PIC_LINK )

If !(cConta == FIELDGET(FIELDPOS(MArq+"CTA_DB")))//FSM - 22/11/11
   @nLin,nCol3 PSAY ALLTRIM(FIELDGET(FIELDPOS(MArq+"CTA_CR")))
Else
   @nLin,nCol3 PSAY ALLTRIM(FIELDGET(FIELDPOS(MArq+"CTA_DB")))
Endif

IF cConta <> FIELDGET(FIELDPOS(MArq+"CTA_DB"))
   nVlr_Cre += ABS(FIELDGET(FIELDPOS(MArq+"VALOR")))
   @nLin,nCol4 PSAY TRANS((ABS(FIELDGET(FIELDPOS(MArq+"VALOR")))), PIC_VALOR )
ELSE
   nVlr_Deb += ABS(FIELDGET(FIELDPOS(MArq+"VALOR")))
   @nLin,nCol5 PSAY TRANS((ABS(FIELDGET(FIELDPOS(MArq+"VALOR")))), PIC_VALOR )
ENDIF

IF MArq = "EC7_"
   @nLin,nCol6 PSAY Alltrim(EC7->EC7_COD_HI)+" "+Alltrim(EC7->EC7_COM_HI)
ELSEIF MArq = "ECA_"
   @nLin,nCol6 PSAY Alltrim(ECA->ECA_COD_HI)+" "+Alltrim(ECA->ECA_DESCAM)
ELSEIF MArq = "ECF_"
   @nLin,nCol6 PSAY SPACE(Len(ECA->ECA_COD_HI))+" "+Alltrim(ECF->ECF_DESCR)
ENDIF

If MArq = "ECF_" .AND. ECF->ECF_ORIGEM = "EX"
   @nLin,nCol7 PSAY FIELDGET(FIELDPOS(MArq+"PREEMB"))
   @nLin,nCol8 PSAY FIELDGET(FIELDPOS(MArq+"INVEXP"))
Elseif MArq = "ECF_" .AND. ECF->ECF_ORIGEM = "CO"
   @nLin,nCol7 PSAY FIELDGET(FIELDPOS(MArq+"CONTRA"))
   @nLin,nCol8 PSAY FIELDGET(FIELDPOS(MArq+"INVEXP"))
Elseif MArq = "ECA_" .AND. ECA->ECA_TPMODU = "EXPORT"
   @nLin,nCol7 PSAY FIELDGET(FIELDPOS(MArq+"PREEMB"))
   @nLin,nCol8 PSAY FIELDGET(FIELDPOS(MArq+"INVEXP"))
Elseif MArq = "ECA_" .AND. Left(ECA->ECA_TPMODU,4) = "FIEX"
   @nLin,nCol7 PSAY FIELDGET(FIELDPOS(MArq+"CONTRA"))
   @nLin,nCol8 PSAY FIELDGET(FIELDPOS(MArq+"INVEXP"))
Else
   @nLin,nCol7 PSAY FIELDGET(FIELDPOS(MArq+"HAWB"))
   @nLin,nCol8 PSAY FIELDGET(FIELDPOS(MArq+"INVEXP"))
   @nLin,nCol9 PSAY TRANS(FIELDGET(FIELDPOS(MArq+"DI_NUM")), PIC_DI )
EndIf

nLin++

Return .T.

*-----------------------*
Function MV150Val(cTipo)
*-----------------------*
Local lExiste1,lExiste2
Local cFilSX5 := xFilial("SX5")

IF cTipo = '1' .OR. cTipo = 'OK'

   IF EMPTY(mv_par01)
      Help(" ",1,"AVG0005215") //E_Msg(STR0028,1) //"Data inicial nao preenchida"
      Return .F.
   ENDIF

ENDIF

IF cTipo = '2' .OR. cTipo = 'OK'

   IF EMPTY(mv_par02)
      Help(" ",1,"AVG0005216") //E_Msg(STR0029,1) //"Data final nao preenchida"
      Return .F.
   ENDIF

ENDIF

/* FSM - 22/11/11
IF cTipo = '3' .OR. cTipo = 'OK'

   IF EMPTY(mv_par03)
      Help(" ",1,"AVG0005217") //E_Msg(STR0030,1) //"Conta nao preenchida"
      Return .F.
   ENDIF
ENDIF
*/

IF cTipo = '4' .OR. cTipo = 'OK'

   IF !EMPTY(mv_par04) .AND. !ECC->(DBSEEK(xFilial()+mv_par04))
      Help(" ",1,"AVG0005218") //E_Msg(STR0032,1) //"Unidade Requisitante nao cadastrado"
      Return .F.
   ENDIF

ENDIF

IF cTipo = 'OK'

   IF dInicial > dFinal
      Help(" ",1,"AVG0005219") //E_Msg(STR0033,1) //"Data final menor que a inicial"
      Return .F.
   ENDIF       
   
   EC7->(DBSEEK(xFilial("EC7")+DTOS(mv_par01),.T.))
   ECA->(DBSEEK(xFilial("ECA")+"IMPORT"+DTOS(mv_par01),.T.))
   lImp:=!ECA->(EOF())
   ECA->(DBSEEK(xFilial("ECA")+"EXPORT"+DTOS(mv_par01),.T.))
   lExp:=!ECA->(EOF())
   ECA->(DBSEEK(xFilial("ECA")+"FIEX01"+DTOS(mv_par01),.T.))
   lF01:=!ECA->(EOF())
   ECA->(DBSEEK(xFilial("ECA")+"FIEX02"+DTOS(mv_par01),.T.))
   lF02:=!ECA->(EOF())
   ECA->(DBSEEK(xFilial("ECA")+"FIEX03"+DTOS(mv_par01),.T.))
   lF03:=!ECA->(EOF())
   ECA->(DBSEEK(xFilial("ECA")+"FIEX04"+DTOS(mv_par01),.T.))
   lF04:=!ECA->(EOF())
   ECA->(DBSEEK(xFilial("ECA")+"FIEX05"+DTOS(mv_par01),.T.))         
   lF05:=!ECA->(EOF())
   ECF->(DBSEEK(xFilial("ECF")+cTPMODU+DTOS(mv_par01),.T.))
   
   If Str(cModo, 1) == "5" //Todos
   
      If EC7->(EOF()) .And. lImp .And. lExp .And. lF01 .And. lF02 .And. lF03 .And. lF04 .And. lF05 .And. ECF->(EOF())
         Help(" ",1,"AVG0005220") //Msginfo(STR0052,STR0053) //"Nao ha Movimentacao de Contas a ser Impressa
         Return .F.
      Endif
                 
   ElseIf Str(cModo, 1) == "1" //Importação
   
      If EC7->(EOF()) .And. lImp .And. lExp .And. lF01 .And. lF02 .And. lF03 .And. lF04 .And. lF05 .And. ECF->(EOF())
         Help(" ",1,"AVG0005221") //E_Msg(STR0034,1) //"Data inicial da integraca nao encontrada"
         Return .F.
      Endif
   Endif
   
   bFor:={||.T.}
      
ENDIF

Return .T.

*------------------------------*
Static Function SOMATOTAL(cArq)
*------------------------------*
nLin++
@nLin,nCol4 PSAY REPL("-",(LEN( PIC_VALOR )-3))
@nLin,nCol5 PSAY REPL("-",(LEN( PIC_VALOR )-3))
nLin++

@nLin,nCol4 PSAY TRANS(nVlr_Cre,PIC_VALOR )
@nLin,nCol5 PSAY TRANS(nVlr_Deb,PIC_VALOR )

Return .T.

*----------------------------------*
Static Function MV150ContaReg()
*----------------------------------*
Local cQueryEC7, cQueryECA, cQueryECF, cWhereEC7, cWhereECA, cWhereECF, cOrig:= "CO"
Local cCondEC7:=" AND EC7.D_E_L_E_T_ <> '*' ",  cCondAsEC7:= " AND EC7.@DELETED@ <> '*' "
Local cCondECA:=" AND ECA.D_E_L_E_T_ <> '*' ",  cCondAsECA:= " AND ECA.@DELETED@ <> '*' "
Local cCondECF:=" AND ECF.D_E_L_E_T_ <> '*' ",  cCondAsECF:= " AND ECF.@DELETED@ <> '*' "

nTotEC7 := nTotECA := nTotECF := 0

IF lTop

  cAliasEC7    := "EC7TMP"
  cAliasECA    := "ECATMP"
  cAliasECF    := "ECFTMP"

  // Where EC7
  cWhereEC7:= " EC7.EC7_FILIAL='"+ cFilEC7 +"' "
  If !Empty(cConta)
     cWhereEC7+=" AND (EC7.EC7_CTA_DB = '"+cConta+"' OR EC7.EC7_CTA_CR = '"+cConta+"') "
  Endif
  If !Empty(cIdentCt)
     cWhereEC7+=" AND EC7.EC7_IDENTC = '"+cIdentCt+"' "
  Endif
  cWhereEC7+= If(TcSrvType()<>"AS/400",cCondEC7,cCondAsEC7)

  // Where ECA
  cWhereECA:= " ECA.ECA_FILIAL='"+ cFilECA +"' AND ECA.ECA_DT_CON >= '"+DTOS(dInicial)+"' AND ECA.ECA_DT_CON <= '"+DTOS(dFinal)+"' "
  If !Empty(cConta)
     cWhereECA+=" AND (ECA.ECA_CTA_DB = '"+cConta+"' OR ECA.ECA_CTA_CR = '"+cConta+"') "
  Endif
  If !Empty(cIdentCt)
     cWhereECA+=" AND ECA.ECA_IDENTC = '"+cIdentCt+"' "
  Endif
  cWhereECA+= If(TcSrvType()<>"AS/400",cCondECA,cCondAsECA)
    
  // Where ECF
  If Str(cModo,1) <> "3"
  
     cWhereECF:= " ECF.ECF_FILIAL='"+ cFilECA +"' AND ECF.ECF_DTCONT <= '"+DTOS(dFinal)+"' AND ECF.ECF_DTCONT >= '"+DTOS(dInicial)+"' "
    
     If !Str(cModo,1) $ "4/5"
        cWhereECF+=" AND ECF.ECF_ORIGEM = 'CO' "
     Endif
     
     If !Str(cModo,1) $ "2/5"
        cWhereECF+=" AND ECF.ECF_ORIGEM = 'EX' "
     Endif          
     
     If !Empty(cConta)
        cWhereECF+=" AND (ECF.ECF_CTA_DB = '"+cConta+"' OR ECF.ECF_CTA_CR = '"+cConta+"') "
     Endif
     
     If !Empty(cIdentCt)
        cWhereECF+=" AND ECF.ECF_IDENTC = '"+cIdentCt+"' "
     Endif
     
     IF lExtEcf
        cWhereECF+= " AND ECF.ECF_CONTAB = '1' "
     ENDIF
     cWhereECF+= If(TcSrvType()<>"AS/400",cCondECF,cCondAsECF)
     
     // Query ECF
     cQueryECF    := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("ECF")+ " ECF WHERE "+cWhereECF     
     
     cQueryECF := ChangeQuery(cQueryECF)
     DbUsearea(.T.,"TOPCONN", TCGenQry(,,cQueryECF), cAliasECF,.F.,.T.)
     If Select(cAliasECF) > 0
        nTotECF := (cAliasECF)->TOTALREG
        (cAliasECF)->(DbCloseArea())
     Else
        nTotECF := 0
     Endif
  Endif
  
  // Query EC7
  cQueryEC7    := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EC7")+ " EC7 WHERE "+cWhereEC7
  
  // Query ECA
  cQueryECA    := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("ECA")+ " ECA WHERE "+cWhereECA
  
  // EC7
  cQueryEC7 := ChangeQuery(cQueryEC7)
  DbUsearea(.T.,"TOPCONN", TCGenQry(,,cQueryEC7), cAliasEC7,.F.,.T.)
  
  If Select(cAliasEC7) > 0
     nTotEC7 := (cAliasEC7)->TOTALREG
     (cAliasEC7)->(DbCloseArea())
  Else
     nTotEC7 := 0
  Endif

  // ECA
  cQueryECA := ChangeQuery(cQueryECA)
  DbUsearea(.T.,"TOPCONN", TCGenQry(,,cQueryECA), cAliasECA,.F.,.T.)
  If Select(cAliasECA) > 0
     nTotECA := (cAliasECA)->TOTALREG
     (cAliasECA)->(DbCloseArea())
  Else
     nTotECA := 0
  Endif

Else

  // EC7
  EC7->(DbSeek(cFilEC7,.T.))

  // PLB 12/04/2006 - Ajuste na Função MsAguarde, estava incompleta
  //EC7->(DBEVAL({||nTotEC7++, MsProcTxt(STR0074+EC7->EC7_INVOIC)},,{||EC7->(!EOF()) .And. EC7->EC7_FILIAL = cFilEC7 .And. ;
  EC7->(DBEVAL({||nTotEC7++, MsAguarde({|| MsProcTxt(STR0074+EC7->EC7_INVOIC),},"")},,{||EC7->(!EOF()) .And. EC7->EC7_FILIAL = cFilEC7 .And. ;
               If(!Empty(cConta), (EC7->EC7_CTA_DB == cConta .Or. EC7->EC7_CTA_CR == cConta), .T.) .And. ;
               If(!Empty(cIdentCt), EC7->EC7_IDENTCT = cIdentCt, .T.) })) //"Lendo Invoice "
  
  // ECA
  ECA->(DbSeek(cFilECA,.T.))
  // PLB 12/04/2006 - Ajuste na Função MsAguarde, estava incompleta
  //ECA->(DBEVAL({||nTotECA++, MsProcTxt(STR0074+ECA->ECA_INVEXP)},,{||ECA->(!EOF()) .And. ECA->ECA_FILIAL = cFilECA .And. ;
  ECA->(DBEVAL({||nTotECA++, MsAguarde({|| MsProcTxt(STR0074+ECA->ECA_INVEXP),},"")},,{||ECA->(!EOF()) .And. ECA->ECA_FILIAL = cFilECA .And. ;
               ECA->ECA_DT_CON >= dInicial .And. ECA->ECA_DT_CON <= dFinal .And. If(!Empty(cConta),(ECA->ECA_CTA_DB == cConta .OR. ECA->ECA_CTA_CR == cConta), .T. ) .And.;
               If(!Empty(cIdentCt), ECA->ECA_IDENTCT == cIdentCt, .T.) })) //"Lendo Invoice "          
  
  // ECF
  ECF->(DbSeek(cFilECF+cTPMODU,.T.))
  // PLB 12/04/2006 - Ajuste na Função MsAguarde, estava incompleta
  //ECF->(DBEVAL({||nTotECF++, MsProcTxt(STR0074+ECF->ECF_INVEXP)},,{||ECF->(!EOF()) .and. Eval(bTPMODUECF) .And. ECF->ECF_FILIAL = cFilECF .And. ECA->ECA_DT_CON >= dInicial .And. ECA->ECA_DT_CON <= dFinal .And.;
  ECF->(DBEVAL({||nTotECF++, MsAguarde({|| MsProcTxt(STR0074+ECF->ECF_INVEXP),},"")},,{||ECF->(!EOF()) .and. Eval(bTPMODUECF) .And. ECF->ECF_FILIAL = cFilECF .And. ECA->ECA_DT_CON >= dInicial .And. ECA->ECA_DT_CON <= dFinal .And.;
               Str(cModo,1) <> "3" .And. If(!Str(cModo,1) $ "4/5", ECF->ECF_ORIGEM = 'CO' , .T.) .And. ;
               If(!Str(cModo,1) $ "2/5", ECF->ECF_ORIGEM = 'EX', .T.) .And. If(!Empty(cConta),(ECF->ECF_CTA_DB == cConta .OR. ECF->ECF_CTA_CR == cConta),.T.) .And.;
               If(!Empty(cIdentCt), ECF->ECF_IDENTCT == cIdentCt, .T.) .And. (IF(lExtEcf,ECF->ECF_CONTAB == '1',))  })) //"Lendo Invoice "

Endif

Return .T.
