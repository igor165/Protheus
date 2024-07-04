//Alcir Alves - 03-11-05 - considerar o banco/agencia/conta de movimentação no EEQ caso estejam preenchidas  - conforme chamado 020324
/*
Programa : EFFAF200.PRW
Objetivo : Conjunto de funções do financiamento para a Manutenção de Cambio
Autor    : Gustavo F. C. - GFC
Data     : 08/07/2005
Revisão  : AAF 23/02/06 - Adicionados os campos chave EF?_TPMODU e EF?_SEQCNT.
                          Substituição da tabela 'CG' do SX5 pela tabela EF7 - Cadastro de Tipos de Financiamento.
*/

#include "EEC.CH"
#include "EFFAF200.ch"

//Eventos.
#define EV_PRINC      "100"
#define EV_PRINC2     "101"
#define EV_EMBARQUE   "600"
#define EV_PJ         "520"
#define EV_TJ         "650"
#define EV_VC_PJ      "550"
#define EV_LIQ_PRC    "630"
#define EV_LIQ_PRC_FC "660"
#define EV_LIQ_JUR    "640"
#define EV_VC_PRC     "500"
#define EV_VLCOR      "530"
#define EV_DESCON     "801"
#define EV_ESTORNO    "999"
#define EV_COM_AR     "120" // Comissão do Tipo A Remeter. (Utilizada nos tratamentos de Frete Seguro e Comissão).
#define EV_COM_CG     "121" // Comissão do Tipo Conta Gráfica. (Utilizada nos tratamentos de Frete Seguro e Comissão).
#define EV_COM_DF     "122" // Comissão do Deduzir da Fatura. (Utilizada nos tratamentos de Frete Seguro e Comissão).
//** GFC - Pré-Pagamento/Securitização
#define EV_PRINC_PREPAG "700"  //Principal das parcelas de pré-pagamento/securitização
#define EV_JUROS_PREPAG "710"  //Parcelas de juros de pré-pagamento/securitização
//**
#define EXP "E"
#define IMP "I"

#define PRE_PAGTO     "03"
#define SECURITIZACAO "04"

*---------------------------------------*
Function GrvWkEEQ(cTipo,cOpcao,lGetProv)
*---------------------------------------*
Local nValTot := 0, lTemParc := .F., nx:=0
Local cTpRotina := If(cTipo = NIL,'',cTipo), cParc, nRecAux
Local nVlrComis := 0, nTotInv := 0, nVlrVinc := 0, nVlrAuxCom := 0, i:=0
If(lGetProv=NIL,lGetProv:=.F.,)
If(cOpcao=NIL,cOpcao:="",)
// Calcula o valor da comissao para abatimento
/*If EEC->EEC_TIPCOM = "2"
   For i:=1 to Len(aArrayEEQ)
       nTotInv += aArrayEEQ[i,1]
   Next
   If EEC->EEC_TIPCVL $ "1/3"   // Tipo Percentual
      nVlrComis := (nTotInv * (EEC->EEC_VALCOM/100))
   Else                         // Tipo Valor Fixo
      nVlrComis := EEC->EEC_VALCOM
   Endif
Endif*/
     
AvZap("WorkEEQ") //WorkEEQ->(avzap())  //NCF - 11/04/2018 - Evitar error.log quando Temp.banco estiver ligado

EEC->(dbSetOrder(1))

If cTpRotina == "LIQ" .and. cOpcao=="INCLUIR" .and. !lGetProv  //GFC 12/04/05
   FAF2ArrayEEQ()
EndIf

   // VI 06/08/05

aJaPagos := {}
//nOrdemEF3 := EF3->(IndexOrd())
//nRecAux := EF3->(RECNO())
//EF3->(dbSetOrder(3))


//EF3->(dbSeek(xFilial("EF3")+TMP->EEQ_NRINVO+If(!lParFin .Or. Empty(TMP->EEQ_PARFIN),TMP->EEQ_PARC,TMP->EEQ_PARFIN)+EV_LIQ_PRC))
//Do While !EF3->(EOF()) .and. EF3->EF3_FILIAL==xFilial("EF3") .and. EF3->EF3_INVOIC==TMP->EEQ_NRINVO .and.;
//EF3->EF3_PARC==If(!lParFin .Or. Empty(TMP->EEQ_PARFIN),TMP->EEQ_PARC,TMP->EEQ_PARFIN) .and. EF3->EF3_CODEVE==EV_LIQ_PRC
//   If If(cTpRotina == "LIQ" .and. cOpcao=="INCLUIR" .and. !lGetProv, aScan(aLiqConf,TMP->&(EasyGParam("MV_CPODTJR",,"EEQ_DTCE"))) = 0, .T.)
//      aAdd(aJaPagos,EF3->EF3_DT_EVE)
//   EndIf
//   EF3->(dbSkip())
//EndDo
//EF3->(dbSetOrder(nOrdemEF3)) // VI 06/08/05
//EF3->(DBGOTO(nRecAux)) // VI 06/08/05

nOrdemEEQ := EEQ->(IndexOrd())
nRecAuxEEQ := EEQ->(RECNO())
EEQ->(dbSetOrder(1))

For i:=Len(aArrayEEQ) to 1 Step -1
   //EEC->(dbSeek(xFilial("EEC")+aArrayEEQ[i,9]))
   //If cTpRotina = "VINC" .Or. cTpRotina = "EST"
   cParc := TMP->EEQ_PARC  // VICTOR
   //Else
   //   cParc := If(!lParvin .Or. Empty(TMP->EEQ_PARVIN), TMP->EEQ_PARC, TMP->EEQ_PARVIN)
   //Endif

   // Valor da Invoice abatendo o valor da Comissão
   nVlrComis := TMP->EEQ_CGRAFI//+TMP->EEQ_ADEDUZ - RMD - 03/03/15 - Não abate o valor da comissão a deduzir na vinculação
   If aArrayEEQ[i,1] = 0
      Loop
   ElseIf aArrayEEQ[i,12] <> 'SALDO'  //EEC->EEC_TIPCOM = "2" .And.
      nVlrVinc  := aArrayEEQ[i,1] - nVlrComis
   /*ElseIf aArrayEEQ[i,1] <= TMP->EEQ_CGRAFI+TMP->EEQ_ADEDUZ
      Loop*/
   Endif
   nPosEEQ:=0
   If EEQ->(dbSeek(xFilial("EEQ")+TMP->EEQ_PREEMB+aArrayEEQ[i,3]))
      nPosEEQ:=Ascan(aJaPagos,EEQ->EEQ_PGT)
   EndIf

   If nPosEEQ > 0 .and. !(cTpRotina == "VINC" .and. cOpcao=="VISUALIZAR") //** GFC - 11/08/05 - Se for visualização da vinculação deve gravar.
      Loop
   EndIf

   If cParc == aArrayEEQ[i,3] .AND. (cTpRotina <> "LIQ" .OR. cOpcao <> "ESTORNAR" .OR. TMP->EEQ_EVENT <> "603")//.or. (cTpRotina="LIQ" .and. cOpcao=="INCLUIR" .and. TMP->EEQ_PARFIN == aArrayEEQ[i,13])
      lTemParc := .T.
      WorkEEQ->(RecLock("WorkEEQ",.T.))

      // Verifica se a parcela foi alterada na manutencao ou quebrada, caso foi atualiza o array p/ gravacao
      WorkEEQ->EEQ_VL     := If((aArrayEEQ[i,1]>(TMP->EEQ_VL-nVlrComis) .and. cTpRotina="LIQ")/* .or. (aArrayEEQ[i,12] <> 'SALDO' .And. Empty(aArrayEEQ[i,5]))*/, nVlrVinc, aArrayEEQ[i,1]) //EEC->EEC_TIPCOM = "2" .And.
      WorkEEQ->VL_ORI     := aArrayEEQ[i,1]
      WorkEEQ->EEQ_VCT    := aArrayEEQ[i,2]
      WorkEEQ->EEQ_PARC   := aArrayEEQ[i,3]
      WorkEEQ->DT_RECEB   := aArrayEEQ[i,4]
      If cTpRotina = 'LIQ' .and. Empty(aArrayEEQ[i,5]) .and.;
      (nx := aScan(aLogEEQ,{|x| x[8]==aArrayEEQ[i,8]}) ) > 0
         WorkEEQ->EF2_CONTRA := aLogEEQ[nx,5]
      Else
         WorkEEQ->EF2_CONTRA := aArrayEEQ[i,5]
      EndIf
      WorkEEQ->SEQ        := aArrayEEQ[i,6]
      WorkEEQ->CONTAB     := aArrayEEQ[i,7]
      WorkEEQ->SEQARRAY   := aArrayEEQ[i,8]
      //WorkEEQ->TIPCOM     := If(EEC->EEC_TIPCOM="1",STR0072,If(EEC->EEC_TIPCOM="2",STR0073,If(EEC->EEC_TIPCOM="3",STR0074,""))) //"A Remeter"#"Conta Grafica"#"Deduzir da Fatura" //"A Remeter"###"Conta Grafica"###"Deduzir da Fatura"
      WorkEEQ->EEC_VALCOM := If(aArrayEEQ[i,12] <> 'SALDO', nVlrComis, 0)  //EEC->EEC_TIPCOM = "2" .And.
      WorkEEQ->DT_VINC    := aArrayEEQ[i,10]
      //**FSY - 18/04/2013
      If EF3->(FieldPos("EF3_DTDOC"))>0
         WorkEEQ->EF3_DTDOC := aArrayEEQ[i,24]
      EndIf
      //**
      WorkEEQ->TX_VINC    := aArrayEEQ[i,11]
      //** PLB 30/10/06 - Dados na moeda do contrato
      WorkEEQ->EF1_MOEDA := aArrayEEQ[i,23]
      WorkEEQ->TX_ME_FIN := aArrayEEQ[i,22]
      WorkEEQ->VL_ME_FIN := WorkEEQ->( ( EEQ_VL * TX_VINC ) / TX_ME_FIN )
      //**
      WorkEEQ->EEQ_DTCE   := TMP->EEQ_DTCE
      WorkEEQ->EEQ_PGT    := TMP->EEQ_PGT
      WorkEEQ->EEQ_DTNEGO := TMP->EEQ_DTNEGO
      WorkEEQ->EEC_MOEDA  := TMP->EEQ_MOEDA
      WorkEEQ->EF2_BAN_FI := If(cTpRotina='LIQ',aArrayEEQ[i,14],TMP->EEQ_BANC)
      WorkEEQ->EF1DESFIN := If(SA6->(DbSeek(xFilial("SA6")+If(cTpRotina='LIQ',aArrayEEQ[i,14],TMP->EEQ_BANC+TMP->EEQ_AGEN+TMP->EEQ_NCON))), SA6->A6_NREDUZ, "")
      WorkEEQ->EEQ_NRINVO := TMP->EEQ_NRINVO
      WorkEEQ->EEQ_NROP   := TMP->EEQ_NROP
      If lParFin .and. lFinanciamento // VI 18/07/03
         WorkEEQ->EEQ_PARFIN := aArrayEEQ[i,13]
      Endif
      //HVR 26/04/06 - CAMPO PARA SER USADO NO SEEK
      If lEFFTpMod
         WorkEEQ->EEQ_TP_CON := TMP->EEQ_TP_CON
      Endif
      // ACSJ - 10/02/2005
      If lTemChave
         WorkEEQ->EF3_PRACA   := aArrayEEQ[i,15]
         If EF5->(DBSeek(xFilial("EF5")+aArrayEEQ[i,15]))
            WorkEEQ->EF5_DESCRI := EF5->EF5_DESCRI
         Endif

         //** AAF 22/02/06 - Sequencia do Contrato.
         If lEFFTpMod
            WorkEEQ->EF3_SEQCNT := aArrayEEQ[i,21]
         EndIf
         //**
      Endif
      // -----------------
      If cTpRotina == "LIQ" .and. aArrayEEQ[i,16] <> NIL
         WorkEEQ->EF3_REC := aArrayEEQ[i,16]
      EndIf

      //** AAF 07/04/08 - Gravação do Tipo de Vinculação, necessário no estorno da vinculação.
      If WorkEEQ->(FieldPos("TIPOVINC")) > 0 .AND. Len(aArrayEEQ[i]) >= 19
         WorkEEQ->TIPOVINC := aArrayEEQ[i,19]
      EndIf
      //**

      //** PLB 21/07/06 - Variavel para tratamento multi-usuario
      If cTpRotina == "VINC"  .And.  !Empty(WorkEEQ->EF2_CONTRA)
         AAdd( aVinList ,{ WorkEEQ->EF2_CONTRA                   ,;
                           IIF(lTemChave,WorkEEQ->EF2_BAN_FI,"") ,;
                           IIF(lTemChave,WorkEEQ->EF3_PRACA ,"") ,;
                           IIF(lEFFTpMod,WorkEEQ->EF3_SEQCNT,"") ,;
                           IIF(lEFFTpMod,WorkEEQ->EEQ_TP_CON,"")    })
      EndIf
      //**
      WorkEEQ->(msUnlock())
   EndIf
Next i

If cTpRotina = 'LIQ' .And. !lTemParc
   If (i := Ascan(aLogEEQ,{|x| x[3]== TMP->EEQ_PARC })) > 0

       //EEC->(dbSeek(xFilial("EEC")+aLogEEQ[i,9]))
       cParc := TMP->EEQ_PARC

       // Verifica se a parcela foi alterada na manutencao ou quebrada, caso foi atualiza o array p/ gravacao
       WorkEEQ->(RecLock("WorkEEQ",.T.))
       WorkEEQ->EEQ_VL     := If((aLogEEQ[i,1]>(TMP->EEQ_VL-nVlrComis) .and. cTpRotina="LIQ") .or. (aLogEEQ[i,12] <> 'SALDO' .And. Empty(aLogEEQ[i,5])), nVlrVinc, aLogEEQ[i,1])  //EEC->EEC_TIPCOM = "2" .And.
       WorkEEQ->VL_ORI     := aLogEEQ[i,1]
       WorkEEQ->EEQ_VCT    := aLogEEQ[i,2]
       WorkEEQ->EEQ_PARC   := aLogEEQ[i,3]
       WorkEEQ->DT_RECEB   := aLogEEQ[i,4]
       WorkEEQ->EF2_CONTRA := aLogEEQ[i,5]
       WorkEEQ->SEQ        := aLogEEQ[i,6]
       WorkEEQ->CONTAB     := aLogEEQ[i,7]
       WorkEEQ->SEQARRAY   := aLogEEQ[i,8]
//       WorkEEQ->TIPCOM     := If(EEC->EEC_TIPCOM="1",STR0072,If(EEC->EEC_TIPCOM="2",STR0073,If(EEC->EEC_TIPCOM="3",STR0074,""))) //"A Remeter"#"Conta Grafica"#"Deduzir da Fatura" //"A Remeter"###"Conta Grafica"###"Deduzir da Fatura"
       WorkEEQ->EEC_VALCOM := If(aArrayEEQ[i,12] <> 'SALDO', nVlrComis, 0) //EEC->EEC_TIPCOM = "2" .And.
       WorkEEQ->DT_VINC    := aLogEEQ[i,10]

       If EF3->(FieldPos("EF3_DTDOC"))>0//FSY - 18/04/2013
          WorkEEQ->EF3_DTDOC := aLogEEQ[i,19]
       EndIf

       WorkEEQ->TX_VINC    := aLogEEQ[i,11]
       //** PLB 30/10/06 - Dados na moeda do contrato
       WorkEEQ->TX_ME_FIN := aLogEEQ[i,17]
       WorkEEQ->EF1_MOEDA := aLogEEQ[i,18]
       WorkEEQ->VL_ME_FIN := WorkEEQ->( ( EEQ_VL * TX_VINC ) / TX_ME_FIN )
       //**
       WorkEEQ->EEQ_DTCE   := TMP->EEQ_DTCE
       WorkEEQ->EEQ_PGT    := TMP->EEQ_PGT
       WorkEEQ->EEQ_DTNEGO := TMP->EEQ_DTNEGO
       WorkEEQ->EEC_MOEDA  := TMP->EEQ_MOEDA
       WorkEEQ->EF2_BAN_FI := If(cTpRotina='LIQ',aArrayEEQ[i,14],TMP->EEQ_BANC)
       WorkEEQ->EF1DESFIN := If(SA6->(DbSeek(xFilial("SA6")+If(cTpRotina='LIQ',aArrayEEQ[i,14],TMP->EEQ_BANC))), SA6->A6_NREDUZ, "")
       WorkEEQ->EEQ_NRINVO := TMP->EEQ_NRINVO
       WorkEEQ->EEQ_NROP   := TMP->EEQ_NROP
       If lParFin .and. lFinanciamento // VI 18/07/03
          WorkEEQ->EEQ_PARFIN := aLogEEQ[i,13]
       Endif
       If lTemChave
          WorkEEQ->EF3_PRACA := aLogEEQ[i,15]
          If lEFFTpMod
             WorkEEQ->EF3_SEQCNT := aLogEEQ[i,16]
          EndIf
       Endif
       WorkEEQ->(msUnlock())
   Endif
Endif

EEQ->(dbSetOrder(nOrdemEEQ)) // VI 06/08/05
EEQ->(DBGOTO(nRecAuxEEQ)) // VI 06/08/05

Return .T.

*-------------------------------*
Function FAF200Vinc(cOp)
*-------------------------------*
Local nSelecao:=0, aBotao:={}, aAlt := {}, nOpc, nRecAux:=0, ni:=0, nVlVinc:=0, lSai:=.F., dDtAux:=AvCtoD("")
Local bBarOk2:={||IIF(Valfina("TUDO_OK"),(nSelecao:=1,oDlg:End()),)}, bBarCancel2:={||nSelecao:=0,lSai:=.F.,oDlg:End()}, nPos:=0, aVinc:={}, nVlCont:=0
Local nx:=0, i:=0, oPanel  // GFP - 14/08/2015
Local nOrdWork := 0
Local lFirst := .T.

If Type("cFilEF1") == "U"
   cFilEF1 := xFilial("EF1")
EndIf

If Type("cFilEF6") == "U"
   cFilEF6 := xFilial("EF6")
EndIf

If Type("cFilEF3") == "U"
   cFilEF3 := xFilial("EF3")
EndIf

If Type("cFilEF2") == "U"
   cFilEF2 := xFilial("EF2")
EndIf

If Type("cFilEF5") == "U"
   If lTemChave
      cFilEF5 := xFilial("EF5")
   EndIf
EndIf

If Type("lAF200Auto") <> "L"
   lAF200Auto:= .F.
EndIf

If Type("bAF200Auto") <> "B"
   bAF200Auto:= Nil
EndIf


Private cOpcao := cOP
Private aWKEEQ := {}  // PLB 19/10/06 - Array que substitui as sobras de valores vinculados que antes ficavam na WorkEEQ

nOrdWork := WorkEEQ->( IndexOrd() )

EF6->( DBSetOrder(2) )

If cOp = "ESTORNAR"
   aBotao := { {"EXCLUIR" ,{||  FAF2EstVinc() }, STR0001} } //"Excluir Vínculo"
   nOpc := 4
   If Empty ( WorkEEQ->EF2_Contra ) .and. Empty ( WorkEEQ->Dt_Vinc )  // LGV - 10/07/03
      MSginfo(STR0002,STR0003) // "Estorno de Vinculaçao Ja Efetuado!","ATENCAO"   // LGV msg
      Return .T.
   Endif
ElseIf cOp = "INCLUIR"
   nOpc := 4

   // ACSJ - 03/01/2005
   if lTemChave
      aAlt := {"EF2_CONTRA","EF2_BAN_FI","EF3_PRACA","EEQ_VL","DT_VINC","TX_VINC"}
      //** AAF - 21/02/2006 - Adicionado o campo sequencia do contrato.
      If lEFFTpMod
//         aAlt := {"EF2_CONTRA","EF2_BAN_FI","EF3_PRACA","EF1_SEQCNT","EEQ_VL","DT_VINC","TX_VINC"}
         aAlt := {"EF2_CONTRA","EF2_BAN_FI","EF3_PRACA","EF3_SEQCNT","EEQ_VL","DT_VINC","TX_VINC","TX_ME_FIN"}  // PLB 30/10/06
      EndIf
      //**

      If EF3->(FieldPos("EF3_DTDOC")) > 0//FSY - 18/04/2013
         aAdd(aAlt,"EF3_DTDOC")
      EndIf
   Else
      aAlt := {"EF2_CONTRA","EF2_BAN_FI","EEQ_VL","DT_VINC","TX_VINC"}
   EndIf
   // -----------------
ElseIf cOp = "VISUALIZAR"
   nOpc := 4
   aAdd(aBotao,{"S4WB008N", { || WinExec("Calc.exe") }, "Calculadora"})  //"Calculadora"
   aAdd(aBotao,{"S4WB016N", { || HelProg() }, "Help de Programa"})  //"Help de Programa"
   aAdd(aBotao,{"S4WB010N", { || OurSpool() }, "Gerenciador de Impressao"})  //"Gerenciador de Impressao"
EndIf

//FSM - 01/03/2012 - Nao permite executar o gatilho do campo EEQ_VL
lTelaVincula := .F.

dbSelectArea("WorkEEQ")
WorkEEQ->(dbGoTop())
If !WorkEEQ->(EOF()) .and. !WorkEEQ->(BOF())

   Do While .T.

      nSelecao:=0

      If lAF200Auto
         If ValType(bAF200Auto) == "B"
            Eval(bAF200Auto)
         EndIf
         If ValFina("TUDO_OK")
            nSelecao := 1
         Else
            nSelecao := 0
         EndIf
      Else

         DEFINE MSDIALOG oDlg TITLE If(cOp = "ESTORNAR", STR0004, STR0005) ; // "Estorno da Vinculacao" / "Vinculação"
                FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
                OF oMainWnd PIXEL

            // GFP - 14/08/2015
            oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165)
            oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

            nLinha :=(oPanel:nClientHeight-49)/2
            WorkEEQ->(oGet:=MsGetDb():New(30,1,nLinha,(oPanel:nClientWidth-4)/2,nOpc,,,,.F.,aAlt,,.F.,,"WorkEEQ",,.T.))
            oGet:lCondicional := .T. // LGV get
            oGet:oBrowse:bwhen:={||(dbSelectArea("WorkEEQ"),.t.)}
            oGet:oBrowse:Refresh()
            oGet:oBROWSE:Badd := {||.F.}

         WorkEEQ->( DBSetOrder(0) )
         If cOp <> "VISUALIZAR"
            ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bBarOk2,bBarCancel2,,aBotao)
         Else
            ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nSelecao:=0,lSai:=.F.,oDlg:End()},{||nSelecao:=0,lSai:=.F.,oDlg:End()},,aBotao) //AF200BAR(oDlg,{||oDlg:End()},Nil,,)
         Endif

      EndIf

      WorkEEQ->( DBSetOrder(nOrdWork) )

      If nSelecao = 1


        //** PLB 19/10/06 - Inicio

         // Verifica se o contrato possui parcelas de pagamento e se é necessario quebrar as parcelas do câmbio
         If EF1->( DBSeek(cFilEF1+IIF(lEFFTpMod,IIF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+WorkEEQ->EF2_CONTRA+IIF(lTemChave,WorkEEQ->EF2_BAN_FI+WorkEEQ->EF3_PRACA+IIF(lEFFTpMod,WorkEEQ->EF3_SEQCNT,""), "")))
            If IIF(lEFFTpMod,EF1->EF1_CAMTRA=="1",lPrepag .And. EF1->EF1_TP_FIN $ "03/04")
	           EXPosPrePag("EF3",EF1->EF1_CONTRA,EF1->EF1_BAN_FI,EF1->EF1_PRACA,.F.,WorkEEQ->TIPOVINC,IIF(lEFFTpMod,EF1->EF1_TPMODU,""),IIF(lEFFTpMod,EF1->EF1_SEQCNT,"") )
               If EF1->EF1_MOEDA != WorkEEQ->EEC_MOEDA
                  //cSaldoAVin := "( EF3->EF3_SLDVIN * BuscaTaxa(EF1->EF1_MOEDA,WorkEEQ->DT_VINC,,.F.,.T.,,cTX_100) ) / WorkEEQ->TX_VINC"
                  cSaldoAVin := "( EF3->EF3_SLDVIN * WorkEEQ->TX_ME_FIN ) / WorkEEQ->TX_VINC"
               Else
                  cSaldoAVin := "EF3->EF3_SLDVIN"
               EndIf
               If &cSaldoAVin > 0  .And.  WorkEEQ->EEQ_VL > &cSaldoAVin  .And.  IIF(WorkEEQ->TIPOVINC=="1",EF3->EF3_CODEVE==EV_PRINC_PREPAG,Left(EF3->EF3_CODEVE,2)==Left(EV_JUROS_PREPAG,2))
                  RecLock("WorkEEQ",.F.)
                  Do While !EF3->( EoF() )  .And.  ;
                           EF3->(EF3_FILIAL+IIF(lEFFTpMod,EF3_TPMODU,"")+IIF(lTemChave,EF3_BAN_FI+EF3_PRACA,"")+IIF(lEFFTpMod,EF3_SEQCNT,"")) == ;
                           EF1->(EF1_FILIAL+IIF(lEFFTpMod,EF1_TPMODU,"")+IIF(lTemChave,EF1_BAN_FI+EF1_PRACA,"")+IIF(lEFFTpMod,EF1_SEQCNT,"")) ;
                           .And.  EF3->EF3_TX_MOE == 0  .And.  (WorkEEQ->EEQ_VL > &cSaldoAVin  .Or.  WorkEEQ->EEQ_VL > 0)  ;
                           .And.  IIF(WorkEEQ->TIPOVINC=="1",EF3->EF3_CODEVE==EV_PRINC_PREPAG,Left(EF3->EF3_CODEVE,2)==Left(EV_JUROS_PREPAG,2))
                     If WorkEEQ->EEQ_VL > &cSaldoAVin
                        nValPar := &cSaldoAVin
                        nValCom := (&cSaldoAVin / WorkEEQ->EEQ_VL) * WorkEEQ->EEC_VALCOM
                     Else
                        nValPar := WorkEEQ->EEQ_VL
                        nValCom := WorkEEQ->EEC_VALCOM
                     EndIf
                     AAdd(aWKEEQ,Array(WorkEEQ->( FCount() )))
                     For i := 1  to  WorkEEQ->( FCount() )
                        aWKEEQ[Len(aWKEEQ)][i] := WorkEEQ->&( FieldName(i) )
                     Next i
                     aWKEEQ[Len(aWkEEQ)][WorkEEQ->( FieldPos("EEQ_VL"    ) )] := nValPar
                     aWKEEQ[Len(aWkEEQ)][WorkEEQ->( FieldPos("EEC_VALCOM") )] := nValCom
                     If lFirst
                        nFirstParc := Len(aWkEEQ)
                     Else
                        aWKEEQ[Len(aWkEEQ)][WorkEEQ->( FieldPos("SEQARRAY"  ) )] := 0
                     EndIf
                     WorkEEQ->EEQ_VL     -= nValPar
                     WorkEEQ->EEC_VALCOM -= nValCom
                     EF3->( DBSkip() )
                     lFirst := .F.
                  EndDo
                  If WorkEEQ->EEQ_VL > 0
                     WorkEEQ->EF2_CONTRA := ""
                     If lTemChave
                        WorkEEQ->EF2_BAN_FI := ""
                        WorkEEQ->EF3_PRACA  := ""
                     EndIf
                     If lEFFTpMod
                        WorkEEQ->EF3_SEQCNT := ""
                     EndIf
                     If !lFirst
                        WorkEEQ->SEQARRAY := aWKEEQ[nFirstParc][WorkEEQ->(FieldPos("SEQARRAY"))]
                        aWKEEQ[nFirstParc][WorkEEQ->(FieldPos("SEQARRAY"))] := 0
                     EndIf
                     AAdd(aWKEEQ,Array(WorkEEQ->( FCount() )))
                     For i := 1  to  WorkEEQ->( FCount() )
                        aWKEEQ[Len(aWKEEQ)][i] := WorkEEQ->&( FieldName(i) )
                     Next i
                  EndIf
                  WorkEEQ->( DBDelete() )
                  WorkEEQ->( MSUnLock() )
                  lFirst := .T.
               EndIf
            EndIf
         EndIf

         // Grava os dados do array temporário para a WorkEEQ
         If Len(aWKEEQ) > 0
            For i := 1  to Len(aWKEEQ)
               RecLock("WorkEEQ",.T.)
               For nx := 1  to  WorkEEQ->( FCount() )
                  WorkEEQ->&( FieldName(nx) ) := aWKEEQ[i][nx]
               Next nx
               WorkEEQ->( MSUnLock() )
            Next i
         EndIf
        //** PLB 19/10/06 - Término

         //** PLB 21/07/06 - Tratamento Multi-Usuario
         WorkEEQ->(dbGoTop())
         Do While !WorkEEQ->( EoF() )
            If EF1->( DBSeek(cFilEF1+IIF(lEFFTpMod,IIF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+WorkEEQ->EF2_CONTRA+IIF(lTemChave,WorkEEQ->EF2_BAN_FI+WorkEEQ->EF3_PRACA,"")+IIF(lEFFTpMod,WorkEEQ->EF3_SEQCNT,"")) )
               If !SoftLock("EF1")
                  lSai := .T.
                  Exit
               EndIf
            EndIf
            WorkEEQ->( DBSkip() )
         EndDo
         If !lSai  .And.  cOpcao == "INCLUIR"  .And.  Len(aVinList) > 0
            For i := 1  to  Len(aVinList)
               If EF1->( DBSeek(cFilEF1+IIF(lEFFTpMod,IIF(aVinList[i][5] $ ("2/4"),"I","E"),"")+aVinList[i][1]+IIF(lTemChave,aVinList[i][2]+aVinList[i][3],"")+IIF(lEFFTpMod,aVinList[i][4],"")) )
                  If !SoftLock("EF1")
                     lSai := .T.
                  EndIf
               EndIf
            Next i
         EndIf
         //**
         If !lSai  .And.  cOpcao == "INCLUIR"  .And.  EF6->( DBSeek(cFilEF6+TMP->EEQ_PREEMB+TMP->EEQ_NRINVO+TMP->EEQ_PARC) )
            If !MsgYesNo(STR0088+AllTrim(EF6->EF6_CONTRA)+IIF(lTemChave," "+STR0008+" "+EF6->EF6_BANCO+" "+STR0069+" "+EF6->EF6_PRACA,"")+IIF(lEFFTpMod,STR0085+EF6->EF6_SEQCNT,"")+"."+CHR(13)+CHR(10)+STR0089+"?")  //"Esta Invoice esta Pre-Vinculada ao Contrato " # "Banco" # "Praca" # "Sequencia" # "Confirma a Vinculacao"
               lSai := .T.
            EndIf
         EndIf
         If cOpcao == "INCLUIR"
            //** GFC - 15/08/05 - Verifica tudo que foi vinculado
            WorkEEQ->(dbGoTop())
            Do While !WorkEEQ->(EOF())
               //AAF - 22/02/06 - Adicionada a Sequencia do contrato e tipo de modulo "E" - Exportação.
               If !Empty(WorkEEQ->EF2_CONTRA) .And.;
               EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,IF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+WorkEEQ->EF2_CONTRA+iif(lTemChave, WorkEEQ->EF2_BAN_FI+WorkEEQ->EF3_PRACA+If(lEFFTpMod,WorkEEQ->EF3_SEQCNT,""), ""))) //AAF - 22/02/06 - Adicionada a Sequencia do contrato e tipo de modulo "E" - Exportação. //HVR SEEK E OU I
                  //If (nx := aScan(aVinc,{|x| x[2]==WorkEEQ->EF2_CONTRA .and. x[1]=="1" .and. If(lTemChave, x[4]==WorkEEQ->EF2_BAN_FI .and. x[5]==WorkEEQ->EF3_PRACA .AND. If(lEFFTpMod,x[6]==WorkEEQ->EF3_SEQCNT,.T.), .T.)})) = 0
                     aAdd(aVinc,{"1",WorkEEQ->EF2_CONTRA,WorkEEQ->EEQ_VL,If(lTemChave,WorkEEQ->EF2_BAN_FI,),If(lTemChave,WorkEEQ->EF3_PRACA,),If(lEFFTpMod,WorkEEQ->EF3_SEQCNT,),WORKEEQ->TX_VINC, WORKEEQ->TX_ME_FIN})
                  //Else
                  //   aVinc[nx,3] += WorkEEQ->EEQ_VL
                  //EndIf
                  If !((ni:=aScan(aArrayEEQ,{|x| x[8]==WorkEEQ->SEQARRAY})) = 0 .or. Empty(aArrayEEQ[ni,5]))
                     //If (nx := aScan(aVinc,{|x| x[2]==WorkEEQ->EF2_CONTRA .and. x[1]=="2" .and. If(lTemChave, x[4]==WorkEEQ->EF2_BAN_FI .and. x[5]==WorkEEQ->EF3_PRACA .AND. If(lEFFTpMod,x[6]==WorkEEQ->EF3_SEQCNT,.T.), .T.)})) = 0
                        aAdd(aVinc,{"2",WorkEEQ->EF2_CONTRA,aArrayEEQ[ni,1],If(lTemChave,WorkEEQ->EF2_BAN_FI,),If(lTemChave,WorkEEQ->EF3_PRACA,),If(lEFFTpMod,WorkEEQ->EF3_SEQCNT,),WORKEEQ->TX_VINC, WORKEEQ->TX_ME_FIN})
                     //Else
                     //   aVinc[nx,3] += aArrayEEQ[ni,1]
                     //EndIf
                  EndIf
               ElseIf !Empty(WorkEEQ->EF2_CONTRA) .And. Empty(WorkEEQ->DT_VINC)
                  MsgInfo(STR0007) //"Data de Vinculação deve ser preenchida."
                  lSai := .T.
                  Exit
               EndIf
               WorkEEQ->(dbSkip())
            EndDo
            //**

            //** GFC - 15/08/05 - Não permitir estourar o saldo do contrato de financiamento
            For ni:=1 to Len(aArrayEEQ)
               If !Empty(aArrayEEQ[ni,5]) .and. Empty(aArrayEEQ[ni,16]) .and. aArrayEEQ[ni,3] <> TMP->EEQ_PARC
                  //If (nx := aScan(aVinc,{|x| x[2]==aArrayEEQ[ni,5] .and. x[1]=="1" .and. If(lTemChave, x[4]==aArrayEEQ[ni,14] .and. x[5]==aArrayEEQ[ni,15] .AND. If(lEFFTpMod,x[6]==aArrayEEQ[ni,21],.T.), .T.)})) = 0
                     aAdd(aVinc,{"1",aArrayEEQ[ni,5],aArrayEEQ[ni,1],If(lTemChave,aArrayEEQ[ni,14],),If(lTemChave,aArrayEEQ[ni,15],),If(lEFFTpMod,aArrayEEQ[ni,21],),aArrayEEQ[ni,11],aArrayEEQ[ni,22]}) //AAF 22/02/06 - Sequencia do contrato.
                  //Else
                  //   aVinc[nx,3] += aArrayEEQ[ni,1]
                  //EndIf
               EndIf
            Next ni

            aSort(aVinc,,, {|x, y| x[2]+x[1] < y[2]+y[1] })
            IF !lEFFTpMod //SVG 05/12/08 //.Or. WORKEEQ->EEQ_TP_CON $ ("1/3")  //HVR SOMENTE VERIFICA SALDO PARA CONTRATOS DE EXPORTAÇÃO
               For ni:=1 to Len(aVinc)
                  If aVinc[ni,1] == "1"
                     EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,IF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+aVinc[ni,2]+iif(lTemChave, aVinc[ni,4]+aVinc[ni,5]+if(lEFFTpMod,aVinc[ni,6],""), ""))) //AAF 22/02/06 - Sequencia do contrato. //HVR SEEK E OU I //***WORKEEQ
                     nx := aScan(aVinc,{|x| x[2]==aVinc[ni,2] .and. x[1]=="2" .and. If(lTemChave, x[4]==aVinc[ni,4] .and. x[5]==aVinc[ni,5] .AND. If(lEFFTpMod,x[6]==aVinc[ni,6],.T.), .T.)})
                     If ((aVinc[ni,3]*aVinc[ni,7])/aVinc[ni,8]) > EF1->EF1_SLD_PM + If(nx > 0, ((aVinc[ni,3]*aVinc[ni,7])/aVinc[ni,8]), 0) //SVG 05/12/08
                        MsgInfo(STR0006+Trans(EF1->EF1_SLD_PM+If(nx > 0, aVinc[nx,3], 0),AVSX3("EF1_SLD_PM",6))) //"Valor a vincular não pode ser maior que saldo do contrato. "
                        lSai := .T.
                        Exit
                     EndIf
                  EndIf
               Next ni
            EndIf //HVR***
            aVinc   := {}
            nVlCont := 0
            //**

            If lSai
               lSai := .F.
               Loop
            EndIf
         EndIf

         WorkEEQ->(dbGoTop())
         Do While !WorkEEQ->(EOF())
            ni := aScan(aArrayEEQ,{|x| x[8]==WorkEEQ->SEQARRAY})
            If ni > 0
               If cOpcao == "INCLUIR"
                  If WorkEEQ->EF2_CONTRA <> aArrayEEQ[ni,5]
                     If !Empty(aArrayEEQ[ni,5]) .and.;
                     (nPos := aScan(aExcVinculo,{|x| x[8]==aArrayEEQ[ni,16]})) = 0
                        /*(nPos := aScan(aExcVinculo,{|x| x[1]==aArrayEEQ[ni,3] .and.;
                        x[2]+iif(lTemChave,x[6]+x[7],"") == aArrayEEQ[ni,5]+iif(lTemChave,aArrayEEQ[ni,14]+aArrayEEQ[ni,15],"") .and.;
                        x[5]==aArrayEEQ[ni,6] .and. x[3]==1})) = 0*/
                        aAdd(aExcVinculo,;
                           {aArrayEEQ[ni,3],;
                           aArrayEEQ[ni,5],;
                           1,;
                           0,;
                           aArrayEEQ[ni,6],;
                           iif(lTemChave,aArrayEEQ[ni,14],""),;
                           iif(lTemChave,aArrayEEQ[ni,15],""),;
                           aArrayEEQ[ni,16],;
                           If(lEFFTpMod,aArrayEEQ[ni,21],),;
                           If(lEFFTpMod,If(WorkEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),); //HVR
                        })

                        //** AAF 03/03/2009 - Estorna liquidacao para vinculação de adiantamento pos-embarque.
                        If !Empty(WorkEEQ->EEQ_PGT)
                           If (nPos := aScan(aLiquida,{|x| x[1]== WorkEEQ->EEQ_PARC })) > 0
                              aDel(aLiquida,nPos)
                              aSize(aLiquida,LEN(aLiquida)-1)
                           EndIf

                           aAdd(aLiquida,{WorkEEQ->EEQ_PARC,"ESTORNAR",,aArrayEEQ[ni,1]})

                           If aScan(aLogEEQ,{|x| x[8]==aArrayEEQ[ni,8]}) = 0
                              aAdd(aLogEEQ,{aArrayEEQ[ni,1], aArrayEEQ[ni,2], aArrayEEQ[ni,3], aArrayEEQ[ni,4], aArrayEEQ[ni,5],;
                                            aArrayEEQ[ni,6], aArrayEEQ[ni,7], aArrayEEQ[ni,8], aArrayEEQ[ni,9], aArrayEEQ[ni,10],;
                                            aArrayEEQ[ni,11],aArrayEEQ[ni,12],aArrayEEQ[ni,13],;
                                            If(lTemChave,aArrayEEQ[ni,14],), If(lTemChave,aArrayEEQ[ni,15],), If(lEFFTpMod,aArrayEEQ[ni,21],),;
                                            aArrayEEQ[ni,22],aArrayEEQ[ni,23],aArrayEEQ[ni,24]})//FSY - 19/06/2013 - Inclusão do novo campo.
                           EndIf
                        EndIf
                        //**
                     ElseIf (nPos := aScan(aExcVinculo,{|x| x[1]==aArrayEEQ[ni,3] .and.;
                             x[5] == aArrayEEQ[ni,5] .and. x[3]==1})) <> 0 .and.;
                             If(lEFFTpMod,aExcVinculo[nPos,10],"")+aExcVinculo[nPos,2]+iif(lTemChave,aExcVinculo[nPos,6]+aExcVinculo[nPos,7]+If(lEFFTpMod,aExcVinculo[nPos,9],""),"") == If(lEFFTpMod,If(WorkEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),)+WorkEEQ->EF2_CONTRA+iif(lTemChave,WorkEEQ->EF2_BAN_FI+WorkEEQ->EF3_PRACA+If(lEFFTpMod,WorkEEQ->EF3_SEQCNT,""),"")

                        aDel(aExcVinculo,nPos)
                        aSize(aExcVinculo,LEN(aExcVinculo)-1)
                     EndIf
                  EndIf
               /*ElseIf cOpcao == "ESTORNAR"
                  If WorkEEQ->EF2_CONTRA <> aArrayEEQ[ni,5]
                     If !Empty(aArrayEEQ[ni,5]) .and. (nPos := aScan(aExcVinculo,{|x| x[1]==aArrayEEQ[ni,3] .and. x[2]==aArrayEEQ[ni,5] .and. x[5]==aArrayEEQ[ni,6] .and. x[3]==1})) = 0
                        aAdd(aExcVinculo,{aArrayEEQ[ni,3],aArrayEEQ[ni,5],1,0,aArrayEEQ[ni,6]})
                     EndIf
                  EndIf*/
               EndIf

               If cOpcao == "INCLUIR"
                  If WorkEEQ->EEQ_VL < aArrayEEQ[ni,1]
                     /*If (nPos := aScan(aExcVinculo,{|x| x[1]==aArrayEEQ[ni,3] .and.;
                         x[2]+iif(lTemChave,x[6]+x[7],"")==aArrayEEQ[ni,5]+iif(lTemChave,aArrayEEQ[ni,14]+aArrayEEQ[ni,15],"") .and.;
                         x[5]==aArrayEEQ[ni,6] .and. x[3]=2})) = 0 */
                     If (nPos := aScan(aExcVinculo,{|x| x[8]==aArrayEEQ[ni,16]})) = 0
                        aAdd(aExcVinculo,{;
                           aArrayEEQ[ni,3],;
                           aArrayEEQ[ni,5],;
                           2,;
                           aArrayEEQ[ni,1],;
                           aArrayEEQ[ni,6],;
                           iif(lTemChave,aArrayEEQ[ni,14],""),;
                           iif(lTemChave,aArrayEEQ[ni,15],""),;
                           aArrayEEQ[ni,16],;
                           If(lEFFTpMod,aArrayEEQ[ni,21],""),;
                           If(lEFFTpMod,If(WorkEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),); //HVR
                           })
                     ElseIf aExcVinculo[nPos,2]+aExcVinculo[nPos,6]+aExcVinculo[nPos,7] == aArrayEEQ[ni,5]+aArrayEEQ[ni,14]+aArrayEEQ[ni,15] .and.;
                     aExcVinculo[nPos,4] = WorkEEQ->EEQ_VL
                        aDel(aExcVinculo,nPos)
                        aSize(aExcVinculo,LEN(aExcVinculo)-1)
                     ElseIf aExcVinculo[nPos,2]+iif(lTemChave,aExcVinculo[nPos,6]+aExcVinculo[nPos,7]+If(lEFFTpMod,aExcVinculo[nPos,9],""),"") == aArrayEEQ[ni,5]+iif(lTemChave,aArrayEEQ[ni,14]+aArrayEEQ[ni,15]+If(lEFFTpMod,aArrayEEQ[ni,21],""),"")
                        aExcVinculo[nPos,4] := WorkEEQ->EEQ_VL
                     EndIf
                  EndIf

                  aArrayEEQ[ni,1]  := WorkEEQ->EEQ_VL
                  aArrayEEQ[ni,5]  := WorkEEQ->EF2_CONTRA
                  aArrayEEQ[ni,6]  := WorkEEQ->SEQ
                  aArrayEEQ[ni,10] := WorkEEQ->DT_VINC

                  If WorkEEQ->(FieldPos("EF3_DTDOC")) > 0//FSY - 18/04/2013
                     aArrayEEQ[ni,24] := WorkEEQ->EF3_DTDOC
                  EndIf

                  aArrayEEQ[ni,11] := WorkEEQ->TX_VINC
                  aArrayEEQ[ni,14] := WorkEEQ->EF2_BAN_FI

                  // ACSJ - 03/02/2005
                  If lTemChave
                     aArrayEEq[ni,15] := WorkEEQ->EF3_PRACA
                     If lEFFTpMod
                        aArrayEEq[ni,21] := WorkEEQ->EF3_SEQCNT
                     EndIf
                  Endif

                  aArrayEEQ[ni,17] := WorkEEQ->EEQ_VL
                  aArrayEEQ[ni,18] := .F.
                  aArrayEEQ[ni,19] := WorkEEQ->TIPOVINC
                  aArrayEEQ[ni,20] := TMP->(RecNo())
                  //** PLB 30/10/06 - Dados na moeda do contrato
                  aArrayEEQ[ni,22] := WorkEEQ->TX_ME_FIN
                  aArrayEEQ[ni,23] := WorkEEQ->EF1_MOEDA
                  //**

                  If .not. Empty(WORKEEQ->EF2_BAN_FI)
                     TMP->EEQ_BANC   := WORKEEQ->EF2_BAN_FI
                     TMP->EEQ_AGEN   := WORKEEQ->EEQ_AGEN //FDR - 10/02/2017
                     TMP->EEQ_NCON   := WORKEEQ->EEQ_NCON //FDR - 10/02/2017
                     TMP->EEQ_NOMEBC := WORKEEQ->EF1DESFIN
                  Endif
                  // -----------------

                  //** GFC - 04/10/05 - Gravar o Parfin do EEQ para toda vinculação pois o contábil utiliza
                  If lParFin .and. Empty(TMP->EEQ_PARFIN)
                     TMP->EEQ_PARFIN := TMP->EEQ_PARC
                  EndIf
                  //**

                  //** AAF 03/03/2009 - Gerar liquidacao para vinculação de adiantamento pos-embarque.
                  If !Empty(TMP->EEQ_PGT) .AND. aScan(aLiquida,{|x| x[1]== TMP->EEQ_PARC }) == 0
                     aAdd(aLiquida,{TMP->EEQ_PARC,"INCLUIR",TMP->EEQ_TX,})
                  EndIf
                  //**
               ElseIf cOpcao == "ESTORNAR" .and. WorkEEQ->EF2_CONTRA <> aArrayEEQ[ni,5]

                  If Ascan(aExcVinculo,{|x| x[8]==aArrayEEQ[ni,16]}) = 0
                     aAdd(aExcVinculo,{;
                        aArrayEEQ[ni,3],;
                        aArrayEEQ[ni,5],;
                        1,;
                        0,;
                        aArrayEEQ[ni,6],;
                        iif(lTemChave,aArrayEEQ[ni,14],""),;
                        iif(lTemChave,aArrayEEQ[ni,15],""),;
                        aArrayEEQ[ni,16],;
                        If(lEFFTpMod,aArrayEEQ[ni,21],""),;
                        If(lEFFTpMod,IF(WorkEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),""); //HVR 27/04/06
                     })
                     If aScan(aLogEEQ,{|x| x[8]==aArrayEEQ[ni,8]}) = 0
                        aAdd(aLogEEQ,{aArrayEEQ[ni,1], aArrayEEQ[ni,2], aArrayEEQ[ni,3], aArrayEEQ[ni,4], aArrayEEQ[ni,5],;
                                      aArrayEEQ[ni,6], aArrayEEQ[ni,7], aArrayEEQ[ni,8], aArrayEEQ[ni,9], aArrayEEQ[ni,10],;
                                      aArrayEEQ[ni,11],aArrayEEQ[ni,12],aArrayEEQ[ni,13],;
                                      If(lTemChave,aArrayEEQ[ni,14],), If(lTemChave,aArrayEEQ[ni,15],), If(lEFFTpMod,aArrayEEQ[ni,21],),;
                                      aArrayEEQ[ni,22],aArrayEEQ[ni,23],aArrayEEQ[ni,24]})//FSY - 19/06/2013 - Inclusão do novo campo.
                     EndIf
                  Endif

                  //** AAF 03/03/2009 - Estorna liquidacao para vinculação de adiantamento pos-embarque.
                  If !Empty(WorkEEQ->EEQ_PGT)
                     If (nPos := aScan(aLiquida,{|x| x[1]== WorkEEQ->EEQ_PARC })) > 0
                        aDel(aLiquida,nPos)
                        aSize(aLiquida,LEN(aLiquida)-1)
                     EndIf

                     aAdd(aLiquida,{WorkEEQ->EEQ_PARC,"ESTORNAR",,aArrayEEQ[ni,1]})

                     If aScan(aLogEEQ,{|x| x[8]==aArrayEEQ[ni,8]}) = 0
                        aAdd(aLogEEQ,{aArrayEEQ[ni,1], aArrayEEQ[ni,2], aArrayEEQ[ni,3], aArrayEEQ[ni,4], aArrayEEQ[ni,5],;
                                      aArrayEEQ[ni,6], aArrayEEQ[ni,7], aArrayEEQ[ni,8], aArrayEEQ[ni,9], aArrayEEQ[ni,10],;
                                      aArrayEEQ[ni,11],aArrayEEQ[ni,12],aArrayEEQ[ni,13],;
                                      If(lTemChave,aArrayEEQ[ni,14],), If(lTemChave,aArrayEEQ[ni,15],), If(lEFFTpMod,aArrayEEQ[ni,21],),;
                                      aArrayEEQ[ni,22],aArrayEEQ[ni,23],aArrayEEQ[ni,24]})//FSY - 19/06/2013 - Inclusão do novo campo.
                     EndIf
                  EndIf
                  //**

                  aArrayEEQ[ni,05]  := Space(AVSX3("EF1_CONTRA",3))    // Contrato
                  //** PLB 24/10/06 - Limpa todas as informações de vinculação
                  aArrayEEQ[ni,10]  := dDataBase                       // Data de Vinculação
                  aArrayEEQ[ni,11]  := BuscaTaxa(EEC->EEC_MOEDA,dDataBase,,.F.,.T.,,cTX_100)  // Taxa de Vinculação
                  If lTemChave
                     aArrayEEQ[ni,14] := Space(AVSX3("EF1_BAN_FI",3)) // Banco
                     aArrayEEQ[ni,15] := Space(AVSX3("EF1_PRACA",3))  // Praça
                  EndIf
                  aArrayEEQ[ni,16] := NIL                             // Recno na Tabela de Eventos do Contrato EF3
                  If lEFFTpMod
                     aArrayEEQ[ni,21] := Space(AVSX3("EF1_SEQCNT",3)) // Sequencia do Contrato
                  EndIf
                  aArrayEEQ[ni,22] := aArrayEEQ[ni,11]   // Taxa de Vinculação na Moeda do Contrato
                  aArrayEEQ[ni,23] := ""                 // Moeda do Contrato
                  //**

                  If EF3->(FieldPos("EF3_DTDOC")) > 0//FSY - 18/04/2013
                     aArrayEEQ[ni,24] := dDataBase
                  EndIf

                  //If lParFin .and. !Empty(TMP->EEQ_PARFIN) //** GFC - 23/08/05 - Comentado
                  //   nRecAux  := TMP->(RecNo())
                  //   cParcAux := TMP->EEQ_PARFIN
                  //   TMP->(dbGoTop())
                  //   Do While !TMP->(EOF())
                  //      If TMP->EEQ_PARFIN == cParcAux
                  //         TMP->EEQ_PARFIN := ""
                  //      EndIf
                  //      TMP->(dbSkip())
                  //   EndDo
                  //   TMP->(dbGoTo(nRecAux))
                  //EndIf
               EndIf
            ElseIf cOpcao == "INCLUIR"
               aAdd(aArrayEEQ,{WorkEEQ->EEQ_VL,WorkEEQ->EEQ_VCT,WorkEEQ->EEQ_PARC,,WorkEEQ->EF2_CONTRA,;
                               Space(Len(EF3->EF3_SEQ)),,FAF200BusSeq(), TMP->EEQ_PREEMB,;
                               WorkEEQ->DT_VINC, BuscaTaxa(WorkEEQ->EEC_MOEDA,dDataBase,,.F.,.T.,,cTX_100),;
                               If(Empty(WorkEEQ->EF2_CONTRA),"SALDO",""),If(lParFin .and. !Empty(TMP->EEQ_PARFIN),TMP->EEQ_PARFIN,TMP->EEQ_PARC), If(lTemChave,WorkEEQ->EF2_BAN_FI,), Iif(lTemChave, WorkEEQ->EF3_PRACA, ""),,WorkEEQ->EEQ_VL,.F.,WorkEEQ->TIPOVINC,;
                               TMP->(RecNo()), If(lEFFTpMod,WorkEEQ->EF3_SEQCNT,),BuscaTaxa(WorkEEQ->EEC_MOEDA,dDataBase,,.F.,.T.,,cTX_100),"",/*FSY - 18/04/2013*/if(EF3->(FIeldPos("EF3_DTDOC"))>0,WorkEEQ->EF3_DTDOC,)}) //AAF 22/02/06 - Adicionado a sequencia do contrato.

               //nSeqArray += 1
               nSeqArray := FAF200BusSeq()
               //** GFC - 28/09/05 - Quebrar a parcela automaticamente caso a vinculação não seja total
               For ni:=1 to TMP->(FCount())
                  M->&(TMP->(FieldName(ni))) := TMP->(FieldGet(ni))
               Next
               //RMD - 01/09/06 - Considera o valor da comissão, para chegar ao valor da parcela, e não ao Vl.Fech.Camb.
               M->EEQ_VL := TMP->EEQ_VL - WorkEEQ->(EEQ_VL + EEC_VALCOM)
               nRecAux := WorkEEQ->(RecNo())
               Af200TrataParc(.T.)
               WorkEEQ->(dbGoTo(nRecAux))

               //** GFC - 29/09/05 - Atualizar o registro original
               AvReplace("M","TMP")
               //**

               //** AAF 03/03/2009 - Gerar liquidacao para vinculação de adiantamento pos-embarque.
               If !Empty(TMP->EEQ_PGT) .AND. aScan(aLiquida,{|x| x[1]== TMP->EEQ_PARC }) == 0
                  aAdd(aLiquida,{TMP->EEQ_PARC,"INCLUIR",TMP->EEQ_TX,})
               EndIf
               //**

               //**
            EndIf
            WorkEEQ->(dbSkip())
         EndDo
      EndIf

      If !lSai
         Exit
      EndIf

   EndDo

   aVinList := {}

   //** GFC - 29/09/05 - Reorganiza o array de vinculações
   If cOpcao <> "ESTORNAR"
      EF3->(dbSetOrder(3))
      For nx:=1 to Len(aArrayEEQ)
         If !Empty(aArrayEEQ[nx,5]) .and. Empty(aArrayEEQ[nx,16])
            aAdd(aVinc,aArrayEEQ[nx])
         EndIf
      Next nx

      //Grava novamente o Array de vinculações
      nRecTmp  := TMP->(Recno())
      aArrayEEQ := {}
      nSeqArray := 1
      TMP->(dbGoTop())
      Do While !TMP->(EOF())
         GrvArrayFAF2()
         TMP->(dbSkip())
      EndDo

      For nx:=1 to Len(aArrayEEQ)
         If Ascan(aExcVinculo,{|x| x[8]==aArrayEEQ[nx,16]}) > 0
            aArrayEEQ[nx,5]  := Space(AVSX3("EF1_CONTRA",3))    // Contrato
            //** PLB 24/10/06 - Limpa todas as informações de vinculação
            aArrayEEQ[nx,10] := dDataBase                       // Data de Vinculação
            aArrayEEQ[nx,11] := BuscaTaxa(EEC->EEC_MOEDA,dDataBase,,.F.,.T.,,cTX_100)  // Taxa de Vinculação
            If lTemChave
               aArrayEEQ[nx,14] := Space(AVSX3("EF1_BAN_FI",3)) // Banco
               aArrayEEQ[nx,15] := Space(AVSX3("EF1_PRACA",3))  // Praça
            EndIf
            aArrayEEQ[nx,16] := NIL                             // Recno na Tabela de Eventos do Contrato EF3
            If lEFFTpMod
               aArrayEEQ[nx,21] := Space(AVSX3("EF1_SEQCNT",3)) // Sequencia do Contrato
            EndIf
            aArrayEEQ[nx,22] := aArrayEEQ[nx,11]   // Taxa de Vinculação na Moeda do Contrato
            aArrayEEQ[nx,23] := ""                 // Moeda do Contrato

            If EF3->(FieldPos("EF3_DTDOC"))>0//FSY - 18/04/2013
               aArrayEEQ[nx,24] := dDataBase
            EndIf
            //**
         Endif
      Next nx

      nIncPos := 0
      //nx      := 1
      //Do While nx <= Len(aVinc)
      For nx := 1 To Len(aVinc)
         If (nPos:=aScan(aArrayEEQ,{|x| x[3]==aVinc[nx,3]})) > 0 .and. aVinc[nx,1] > 0
            nSaldo     := 0
            nVlVincPar := 0
            nPosSaldo  := 0
            For ni:=nPos to Len(aArrayEEQ)
               If aArrayEEQ[ni,3] == aVinc[nx,3]
                  If !Empty(aArrayEEQ[ni,5])
                     nVlVincPar += aArrayEEQ[ni,1]
                  Else
                     nSaldo    := aArrayEEQ[ni,1]
                     nPosSaldo := ni
                  EndIf
               EndIf
            Next ni
            If nPosSaldo > 0
               TMP->(dbGoTo(aArrayEEQ[nPosSaldo,20]))

               aAdd(aArrayEEQ,aClone(aVinc[nx]))
               If nSaldo >= aVinc[nx,1]
                  If nSaldo = aVinc[nx,1]
                     aDel(aArrayEEQ,nPosSaldo)
                     aSize(aArrayEEQ,Len(aArrayEEQ)-1)
                     If cOpcao == "INCLUIR"
                        //nSeqArray -= 1
                        nSeqArray := FAF200BusSeq()
                     EndIf
                  Else
                     aArrayEEQ[nPosSaldo,1]  -= aVinc[nx,1]
                     aArrayEEQ[nPosSaldo,17] -= aVinc[nx,1]
                  EndIf

                  aArrayEEQ[Len(aArrayEEQ),3]  := TMP->EEQ_PARC
                  aArrayEEQ[Len(aArrayEEQ),8]  := nSeqArray
                  aArrayEEQ[Len(aArrayEEQ),12] := ""
                  aArrayEEQ[Len(aArrayEEQ),13] := If(lParFin .and. !Empty(TMP->EEQ_PARFIN),TMP->EEQ_PARFIN,TMP->EEQ_PARC)
                  aArrayEEQ[Len(aArrayEEQ),20] := TMP->(RecNo())

                  nSeqArray   += 1
                  //nx          += 1
               Else
                  aDel(aArrayEEQ,nPosSaldo)
                  aSize(aArrayEEQ,Len(aArrayEEQ)-1)

                  aArrayEEQ[Len(aArrayEEQ),1]  := nSaldo
                  aArrayEEQ[Len(aArrayEEQ),3]  := TMP->EEQ_PARC
                  aArrayEEQ[Len(aArrayEEQ),8]  := nSeqArray-1
                  aArrayEEQ[Len(aArrayEEQ),12] := ""
                  aArrayEEQ[Len(aArrayEEQ),13] := If(lParFin .and. !Empty(TMP->EEQ_PARFIN),TMP->EEQ_PARFIN,TMP->EEQ_PARC)
                  aArrayEEQ[Len(aArrayEEQ),17] := nSaldo
                  aArrayEEQ[Len(aArrayEEQ),20] := TMP->(RecNo())

                  aVinc[nx,1] -= nSaldo
                  aVinc[nx,3] := StrZero(Val(aVinc[nx,3])+1,Len(EEQ->EEQ_PARC))
               EndIf
            Else
               aVinc[nx,3] := StrZero(Val(aVinc[nx,3])+1,Len(EEQ->EEQ_PARC))
            EndIf
         EndIf
      //EndDo
      Next nx
      aVinc := {}
      EF3->(dbSetOrder(1))
      TMP->(dbGoTo(nRecTmp))
   EndIf
   //**
Else
   Help(" ",1,"AVG0005229") //MsgInfo("Não existem registros para vinculação.")
EndIf

Return .T.

*---------------------------*
Function FAF2Header()
*---------------------------*
SX3->(dbSetOrder(2))

If SX3->(dbSeek("EEQ_VL"))

   Aadd(aHeader,{AVSX3("EF2_CONTRA",5),"EF2_CONTRA",AVSX3("EF2_CONTRA",6),AVSX3("EF2_CONTRA",3),AVSX3("EF2_CONTRA",4),"(Empty(M->EF2_CONTRA) .or. ExistCpo('EF1',If(lEFFTpMod,IF(TMP->EEQ_TP_CON $ ('2/4'),'I','E'),'')+M->EF2_CONTRA)) .and. ValFina('CONTRA')",SX3->X3_USADO,"C","EF2"    ,SX3->X3_CONTEXT}) //HVR SEEK E OU I //***WORKEEQ
   Aadd(aHeader,{STR0008              ,"EF2_BAN_FI",AVSX3("EF1_BAN_FI",6),AVSX3("EF1_BAN_FI",3),AVSX3("EF1_BAN_FI",4),"(Empty(M->EF2_BAN_FI) .or. ExistCpo('SA6',M->EF2_BAN_FI)) .and. ValFina('BANC')"                             ,"S"          ,"C","WorkEEQ",SX3->X3_CONTEXT})         // "Banco"
   Aadd(aHeader,{STR0009              ,"EF1DESFIN" ,AVSX3("A6_NREDUZ",6),AVSX3("A6_NREDUZ",3) ,AVSX3("A6_NREDUZ",4),                                                                                                               ,SX3->X3_USADO,"C","WorkEEQ",SX3->X3_CONTEXT}) //"Nome do Banco"

   // ACSJ - 03/02/2005
   If lTemChave
      Aadd(aHeader,{AVSX3("EF3_PRACA", 5) ,"EF3_PRACA" ,AVSX3("EF3_PRACA", 6), AVSX3("EF3_PRACA",3), AVSX3("EF3_PRACA",4), "ValFina('PRACA')"                                                            ,SX3->X3_USADO,"C","WorkEEQ",SX3->X3_CONTEXT})
      Aadd(aHeader,{AVSX3("EF5_DESCRI",5) ,"EF5_DESCRI",AVSX3("EF5_DESCRI",6), AVSX3("EF5_DESCRI",3),AVSX3("EF5_DESCRI",4),                                                                              ,SX3->X3_USADO,"C","EF5",SX3->X3_CONTEXT})
      //** AAF - 21/02/2006 - Adiciona o campo Sequência do contrato na Tela de Vinculação.
      If lEFFTpMod
         Aadd(aHeader,{AVSX3("EF3_SEQCNT",5) ,"EF3_SEQCNT",AVSX3("EF3_SEQCNT",6), AVSX3("EF3_SEQCNT",3),AVSX3("EF3_SEQCNT",4),"ValFina('SEQCNT')"                                                        ,SX3->X3_USADO,"C","EF3",SX3->X3_CONTEXT})
      EndIf
      //**
   Endif
   // -----------------
   Aadd(aHeader,{STR0011              ,"DT_VINC"   ,AVSX3("EEQ_DTCE",6)   ,AVSX3("EEQ_DTCE",3)   ,AVSX3("EEQ_DTCE",4)   ,"ValFina('DT_VINC')"                                                            ,SX3->X3_USADO,"D","WorkEEQ",SX3->X3_CONTEXT}) //"Dt. Vinculação"
   If EF3->(FieldPos("EF3_DTDOC")) > 0//FSY - 18/04/2013
      aAdd(aHeader,{AVSX3("EF3_DTDOC",5)   ,"EF3_DTDOC"   ,AVSX3("EF3_DTDOC",6)   ,AVSX3("EF3_DTDOC",3)   ,AVSX3("EF3_DTDOC",4)   ,                                                                                   ,SX3->X3_USADO,"D","WorkEEQ"    ,SX3->X3_CONTEXT})
   EndIf
   Aadd(aHeader,{AVSX3("EEC_MOEDA",5) ,"EEC_MOEDA" ,AVSX3("EEC_MOEDA",6) ,AVSX3("EEC_MOEDA",3) ,AVSX3("EEC_MOEDA",4) ,                                                                                   ,SX3->X3_USADO,"C","WorkEEQ",SX3->X3_CONTEXT})
   Aadd(aHeader,{STR0010              ,"EEQ_VL"    ,AVSX3("EEQ_VL",6)    ,AVSX3("EEQ_VL",3)    ,AVSX3("EEQ_VL",4)    ,"ValFina('EEQ_VL')"                                                                ,SX3->X3_USADO,"N","EEQ"    ,SX3->X3_CONTEXT}) //"Vl a Vincular"
   Aadd(aHeader,{STR0012              ,"TX_VINC"   ,AVSX3("EF3_TX_MOE",6),AVSX3("EF3_TX_MOE",3),AVSX3("EF3_TX_MOE",4), "ValFina('TX_VINC')"                                                              ,SX3->X3_USADO,"N","WorkEEQ",SX3->X3_CONTEXT}) //"Tx. Vinculação"   // LGV 10/07/03
   //** PLB 30/10/06 - Dados na moeda do Financiamento
   Aadd(aHeader,{STR0095              ,"EF1_MOEDA" ,AVSX3("EEC_MOEDA",6) ,AVSX3("EEC_MOEDA",3) ,AVSX3("EEC_MOEDA",4) ,                                                                                   ,SX3->X3_USADO,"C","WorkEEQ",SX3->X3_CONTEXT})  //"Moeda Contrato"
   Aadd(aHeader,{STR0096              ,"VL_ME_FIN" ,AVSX3("EEQ_VL",6)    ,AVSX3("EEQ_VL",3)    ,AVSX3("EEQ_VL",4)    ,                                                                                   ,SX3->X3_USADO,"N","WorkEEQ",SX3->X3_CONTEXT})  //"Valor ME Contrato"
   Aadd(aHeader,{STR0097              ,"TX_ME_FIN" ,AVSX3("EF3_TX_MOE",6),AVSX3("EF3_TX_MOE",3),AVSX3("EF3_TX_MOE",4),"ValFina('TX_ME_FIN')"                                                             ,SX3->X3_USADO,"N","WorkEEQ",SX3->X3_CONTEXT})  //"Taxa ME Contrato"
   //**
   Aadd(aHeader,{AVSX3("EEQ_VL",5)    ,"VL_ORI"    ,AVSX3("EF1_VL",6)    ,AVSX3("EEQ_VL",3)    ,AVSX3("EEQ_VL",4)    ,                                                                                   ,SX3->X3_USADO,"N","WorkEEQ",SX3->X3_CONTEXT})
//   Aadd(aHeader,{AVSX3("EEC_TIPCOM",5),"TIPCOM"    ,"@!"                 ,20                   ,0                    ,                                                                                 ,SX3->X3_USADO,"C","WorkEEQ",SX3->X3_CONTEXT})
   Aadd(aHeader,{AVSX3("EEC_VALCOM",5),"EEC_VALCOM",AVSX3("EEC_VALCOM",6),AVSX3("EEC_VALCOM",3),AVSX3("EEC_VALCOM",4),                                                                                   ,SX3->X3_USADO,"N","WorkEEQ",SX3->X3_CONTEXT})
   Aadd(aHeader,{AVSX3("EEQ_VCT",5)   ,"EEQ_VCT"   ,AVSX3("EEQ_VCT",6)   ,AVSX3("EEQ_VCT",3)   ,AVSX3("EEQ_VCT",4)   ,                                                                                   ,SX3->X3_USADO,"D","EEQ"    ,SX3->X3_CONTEXT})
   Aadd(aHeader,{STR0013              ,"DT_RECEB"  ,AVSX3("EF3_DT_FIX",6),AVSX3("EF3_DT_FIX",3),AVSX3("EF3_DT_FIX",4),                                                                                   ,SX3->X3_USADO,"D",         ,SX3->X3_CONTEXT}) //"Dt. Receb. Dinheiro"

EndIf

SX3->(dbSetOrder(1))

Return .T.

*---------------------------------------------------*
Function AtuVincEF3(cTip,nPos,lRecur,nPos2,aNfLoteEF3)
*---------------------------------------------------*
Local cCampo, cSeq, nVal, nTaxa, nPosAux, cCont, cTpMod  //HVR 25/04/06 - cTpMod
Local aTx_Dia, aTx_Ctb, nVal1, nTaxa1
Local nValAux1:=0, nValAux2:=0, nTxAux2, nOrdemEF3 := EF3->(IndexOrd())
Local cBanco, cAgencia, cConta
Local nTmpOrd  := TMP->(IndexOrd()) //FSM - 15/08/2012
Local lLogix := FindFunction("EFFEX101")
Private cTipo:=If(cTip=NIL,"",cTip)
If(nPos2=NIL,nPos2:=0,)
If(lRecur=NIL, lRecur:=.F. , )

EF3->(DbSetOrder(4))

If (cTipo=="EXCLUIR" .and. EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,aExcVinculo[nPos,10],"")+aExcVinculo[nPos,2]+If(lTemChave,aExcVinculo[nPos,6]+aExcVinculo[nPos,7]+If(lEFFTpMod,aExcVinculo[nPos,9],""),"")+aExcVinculo[nPos,5])))// .or.;   //HVR SEEK E OU I //***WORKEEQ
//(nPos2<>0 .and. Empty(aArrayEEQ[nPos2,5]) .and. EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,IF(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),"")+aArrayEEQ[nPos2,5]+iif(lTemChave,aArrayEEQ[nPos2,14]+aArrayEEQ[nPos2,15]+If(lEFFTpMod,aArrayEEQ[nPos2,21],""),"")+aArrayEEQ[nPos2,6])))  //HVR SEEK E OU I //***WORKEEQ

   If cTipo == "EXCLUIR"
      If aExcVinculo[nPos,8] <> NIL .and. aExcVinculo[nPos,8] > 0
         EF3->(dbGoTo(aExcVinculo[nPos,8]))
         cSeq  := EF3->EF3_SEQ       //aExcVinculo[nPos,5]
         cCont := EF3->EF3_CONTRA    //aExcVinculo[nPos,2]
         if lTemChave
            cBanc := EF3->EF3_BAN_FI //aExcVinculo[nPos,6]
            cPrac := EF3->EF3_PRACA  //aExcVinculo[nPos,7]
            If lEFFTpMod
               cSeqCon := EF3->EF3_SEQCNT  //aExcVinculo[nPos,7]
               cTpMod  := EF3->EF3_TPMODU  //HVR 25/04/06 - cTpMod
            EndIf
         Endif
         EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,cTpMod,"")+cCont+If(lTemChave,cBanc+cPrac+If(lEFFTpMod,cSeqCon,""),"")+cSeq))  //HVR SEEK cTpMod
      Else
         cSeq  := aExcVinculo[nPos,5]
         cCont := aExcVinculo[nPos,2]
         if lTemChave
            cBanc := aExcVinculo[nPos,6]
            cPrac := aExcVinculo[nPos,7]
            If lEFFTpMod
               cSeqCon := aExcVinculo[nPos,9]
               cTpMod  := aExcVinculo[nPos,10]
            EndIf
         Endif
      EndIf
   Else
      cSeq  := aArrayEEQ[nPos2,6]
      cCont := aArrayEEQ[nPos2,5]
      if lTemChave
         cBanc := aArrayEEQ[nPos2,14]
         cPrac := aArrayEEQ[nPos2,15]
         If lEFFTpMod
            cSeqCon := aExcVinculo[nPos,9]
            cTpMod  := aExcVinculo[nPos,10]
         EndIf
      Endif
   EndIf

   EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,cTpMod,"")+cCont+If(lTemChave,cBanc+cPrac+If(lEFFTpMod,cSeqCon,""),"")))  //HVR SEEK cTpMod

   If AvFlags("SIGAEFF_SIGAFIN") .OR. lLogix
      oEFFContrato := AvEFFContra():LoadEF1()
   EndIf

   Do While !EF3->(EOF()) .and. EF3->EF3_FILIAL==xFilial("EF3") .and.;
            If(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3->EF3_CONTRA+iif(lTemChave,EF3->EF3_BAN_FI+EF3->EF3_PRACA+If(lEFFTpMod,EF3->EF3_SEQCNT,""),"")==If(lEFFTpMod,cTpMod,"")+cCont+iif(lTemChave,cBanc+cPrac+If(lEFFTpMod,cSeqCon,""),"") .and.;
            EF3->EF3_SEQ == cSeq  .And.  !( EF3->EF3_CODEVE == EV_ESTORNO )  // PLB 04/07/07

      If EF3->EF3_CODEVE == EV_EMBARQUE
         FAF2ValParc(5,cTipo,If(cTipo=="EXCLUIR",nPos,))
      EndIf

      If AvFlags("SIGAEFF_SIGAFIN") .OR. lLogix
         If Select("TMP") > 0 //FSM - 15/08/2012 - Reabre a Work TMP
            TMP->(dbCloseArea())
         EndIf

         oEFFContrato:EventoEF3("ESTORNO")

         If Select("TMP") == 0 //FSM - 15/08/2012 - Reabre a Work TMP
            Af200AbTmp()
            TMP->(dbSetOrder(nTmpOrd))
         EndIf
      EndIf

      cMod := IIF(lEFFTpMod,EF1->EF1_TPMODU,EXP) //HVR 26/04/06 - NECESSÁRIO PARA EX400
      EX400AtuSaldos("VIN",,,"EEC")
      If cTipo == "EXCLUIR" .and. EF3->EF3_CODEVE == EV_EMBARQUE
         cMod := IIF(lEFFTpMod,EF1->EF1_TPMODU,EXP) //HVR 26/04/06 - NECESSÁRIO PARA EX400
         EX400MotHis("VIN",EF1->EF1_CONTRA,If(lTemChave,EF1->EF1_BAN_FI,),If(lTemChave,EF1->EF1_PRACA,),EF1->EF1_TP_FIN,EF3->EF3_PREEMB,EF3->EF3_INVOIC,EF3->EF3_PARC,EF3->EF3_CODEVE,EF3->EF3_SEQ,"E",If(lEFFTpMod,EF1->EF1_SEQCNT,)) //AAF - 21/02/2006 - Adicionado o campo sequencia do contrato.
      EndIf

      EF3->(RecLock("EF3",.F.))
      If !Empty(EF3->EF3_NR_CON)
         EF3->EF3_EV_EST := EF3->EF3_CODEVE //EF3->(DBDELETE())
         EF3->EF3_DT_EST := dDataBase
         EF3->EF3_CODEVE := EV_ESTORNO
         EF3->EF3_NR_CON := Space(Len(EF3->EF3_NR_CON))
         EF3->(msUnlock())
         // PLB 04/07/07 - Ao alterar o código do evento o registro é desposicionado na tabela devido campo fazer parte da chave
         EF3->( DBSeek(xFilial("EF3")+IIF(lEFFTpMod,cTpMod,"")+cCont+IIF(lTemChave,cBanc+cPrac+IIF(lEFFTpMod,cSeqCon,""),"")+cSeq) )
      Else
         EF3->(dbDelete())
         EF3->(msUnlock())
         EF3->(dbSkip())
      EndIf
   EndDo

   If AvFlags("SIGAEFF_SIGAFIN") .OR. lLogix
      oEFFContrato:EventoFinanceiro("ATUALIZA_PROVISORIOS")
      oEFFContrato:ShowErrors()
   EndIf

ElseIf nPos2<>0 .and. !Empty(aArrayEEQ[nPos2,5]) .and. !lRecur

   If (nPosAux := aScan(aExcVinculo,{|x| x[1]==aArrayEEQ[nPos2,3] .and.;
                        If(lEFFTpMod,x[10],"")+x[2]+iif(lTemChave,x[6]+x[7]+If(lEFFTpMod,x[9],""),"")==IF(TMP->EEQ_TP_CON $ ("2/4"),"I","E")+aArrayEEQ[nPos2,5]+iif(lTemChave,aArrayEEQ[nPos2,14]+aArrayEEQ[nPos2,15]+If(lEFFTpMod,aArrayEEQ[nPos2,21],""),"")+aArrayEEQ[nPos2,6] .and.;
                        x[5]==aArrayEEQ[nPos2,6] .and. x[3]=2})) > 0

      AtuVincEF3("EXCLUIR",nPosAux,.T.)
      // ACSJ - 04/02/2005
      EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,IF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+aArrayEEQ[nPos2,5]+iif(lTemChave,aArrayEEQ[nPos2,14]+aArrayEEQ[nPos2,15]+If(lEFFTpMod,aArrayEEQ[nPos2,21],""),"")))  //HVR SEEK E OU I //***WORKEEQ
      // -----------------
      cMod := IIF(lEFFTpMod,EF1->EF1_TPMODU,EXP) //HVR 26/04/06 - NECESSÁRIO PARA EX400

      aArrayEEQ[nPos2,16] := EX400GrvEventos(EF1->EF1_CONTRA,TMP->EEQ_NRINVO,M->EEC_PREEMB,aArrayEEQ[nPos2,1],dDataBase,;
      M->EEC_MOEDA,aArrayEEQ[nPos2,3],EF1->EF1_MOEDA,"EF1","EF3","CAMB",,aArrayEEQ[nPos2,11],aArrayEEQ[nPos2,10],If(lMulTiFil,xFilial("EEQ"),Nil),;
      iif(lTemChave,aArrayEEQ[nPos2,14],""),iif(lTemChave,aArrayEEQ[nPos2,15],""),aArrayEEQ[nPos2,19],If(lEFFTpMod,EF1->EF1_TPMODU,),If(lEFFTpMod,aArrayEEQ[nPos2,21],),,,,,,/*FSY - 19/06/2013*/if(EF3->(FieldPos("EF3_DTDOC"))>0,aArrayEEQ[nPos2,24],)) //AAF 22/02/06 - Adicionado o campo sequencia do contrato e tipo de modulo "E" - Exportação. //HVR SEEK EF1_TPMODU

      //Atualiza o número da operação e o banco na fatura
      cBanco  := EF1->EF1_BAN_FI
      cAgencia:= EF1->EF1_AGENFI
      cConta  := EF1->EF1_NCONFI
      If !Empty(EF1->EF1_BAN_MO)  //Alcir Alves - 03-11-05 - considerar o banco de movimentação nas vinculações  - conforme chamado 020324
         cBanco  := EF1->EF1_BAN_MO
         cAgencia:= EF1->EF1_AGENMO
         cConta  := EF1->EF1_NCONMO
      Endif
      If Alltrim(TMP->EEQ_NROP) <> Alltrim(EF1->EF1_CONTRA) .Or.;
         Alltrim(TMP->EEQ_BANC) <> Alltrim(cBanco) .Or.;
         Alltrim(TMP->EEQ_AGEN) <> Alltrim(cAgencia) .Or.;
         Alltrim(TMP->EEQ_NCON) <> Alltrim(cConta)

         If(Empty(TMP->EEQ_NROP),TMP->EEQ_NROP := EF1->EF1_CONTRA,)
         If(Empty(TMP->EEQ_BANC),TMP->EEQ_BANC := cBanco,)
         If(Empty(TMP->EEQ_AGEN),TMP->EEQ_AGEN := cAgencia,)
         If(Empty(TMP->EEQ_NCON),TMP->EEQ_NCON := cConta,)
         If SA6->(dbSeek(xFilial("SA6")+cBanco+cAgencia+cConta)) .and. Empty(TMP->EEQ_NOMEBC)
            TMP->EEQ_NOMEBC := SA6->A6_NOME
         EndIf
      Endif

   ElseIf !EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,IF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+aArrayEEQ[nPos2,5]+iif(lTemChave,aArrayEEQ[nPos2,14]+aArrayEEQ[nPos2,15]+If(lEFFTpMod,aArrayEEQ[nPos2,21],""),"")+aArrayEEQ[nPos2,6])) .or.;                       //HVR SEEK I OU E //***WORKEEQ
          (EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,IF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+aArrayEEQ[nPos2,5]+iif(lTemChave,aArrayEEQ[nPos2,14]+aArrayEEQ[nPos2,15]+If(lEFFTpMod,aArrayEEQ[nPos2,21],""),"")+aArrayEEQ[nPos2,6])) .and. Empty(EF3->EF3_PARC)) //HVR SEEK I OU E //***WORKEEQ

      // ACSJ - 04/02/2005
      EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,IF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+aArrayEEQ[nPos2,5]+iif(lTemChave, aArrayEEQ[nPos2,14]+aArrayEEQ[nPos2,15]+If(lEFFTpMod,aArrayEEQ[nPos2,21],""),"") )) //HVR SEEK I OU E
      // ------------------
      cMod := IIF(lEFFTpMod,EF1->EF1_TPMODU,EXP) //HVR 26/04/06 - NECESSÁRIO PARA EX400

      aArrayEEQ[nPos2,16] := EX400GrvEventos(EF1->EF1_CONTRA,TMP->EEQ_NRINVO,M->EEC_PREEMB,aArrayEEQ[nPos2,1],dDataBase,;
      M->EEC_MOEDA,aArrayEEQ[nPos2,3],EF1->EF1_MOEDA,"EF1","EF3","CAMB",,aArrayEEQ[nPos2,11],aArrayEEQ[nPos2,10],if(lMultiFil,xFilial("EEQ"),nil),;
      iif(lTemChave,aArrayEEQ[nPos2,14],""),iif(lTemChave,aArrayEEQ[nPos2,15],""),aArrayEEQ[nPos2,19],If(lEFFTpMod,EF1->EF1_TPMODU,),If(lEFFTpMod,aArrayEEQ[nPos2,21],),,,,,/*FSY-19/06/2013-Inclusao do novo campo*/aArrayEEQ[nPos2][22],if(EF3->(FieldPos("EF3_DTDOC"))>0,aArrayEEQ[nPos2,24],),,aNfLoteEF3)
       // AAF 22/02/06 - Adicionado o campo sequência do contrato e tipo de contrato "E" - Exportação.
       //HVR SEEK EF1_TPMODU

      //Atualiza o número da operação e o banco na fatura
      cBanco  := EF1->EF1_BAN_FI
      cAgencia:= EF1->EF1_AGENFI
      cConta  := EF1->EF1_NCONFI
      If !Empty(EF1->EF1_BAN_MO)   //Alcir Alves - 03-11-05 - considerar o banco de movimentação nas vinculações  - conforme chamado 020324
         cBanco  := EF1->EF1_BAN_MO
         cAgencia:= EF1->EF1_AGENMO
         cConta  := EF1->EF1_NCONMO
      Endif
      If Alltrim(TMP->EEQ_NROP) <> Alltrim(EF1->EF1_CONTRA) .Or.;
         Alltrim(TMP->EEQ_BANC) <> Alltrim(cBanco) .Or.;
         Alltrim(TMP->EEQ_AGEN) <> Alltrim(cAgencia) .Or.;
         Alltrim(TMP->EEQ_NCON) <> Alltrim(cConta)

         If(Empty(TMP->EEQ_NROP),TMP->EEQ_NROP := EF1->EF1_CONTRA,)
         If(Empty(TMP->EEQ_BANC),TMP->EEQ_BANC := cBanco,)
         If(Empty(TMP->EEQ_AGEN),TMP->EEQ_AGEN := cAgencia,)
         If(Empty(TMP->EEQ_NCON),TMP->EEQ_NCON := cConta,)
         If SA6->(dbSeek(xFilial("SA6")+cBanco+cAgencia+cConta)) .and. Empty(TMP->EEQ_NOMEBC)
            TMP->EEQ_NOMEBC := SA6->A6_NOME
         EndIf
      Endif
   EndIf

EndIf

EF3->(DbSetOrder(nOrdemEF3))

Return .T.

*------------------------*
Function ValFina(cCampo, lBOk)
*------------------------*
Local nPos, nAux, nRec, nPsAux := 0, nOrdAux, ni, cCharAux:="", cBanq:="", nTxAux:=0, nVlOri:=0
Local nValCom1, nValCom2
Local nInc, nRecWorkEEQ
Local nVltxEF1,nVlVinculado  //SVG 05/12/08
Local nSaldoCtr
Local cEF3SEQ := ""

Static cContraVal := ""
Static cBancVal   := ""
Static cPracaVal  := ""
Static cSeqVal    := ""
Private lRet := .T., cCampoAux:=cCampo
Default lBOk := .F.

If cCampo = "CONTRA" .and. Valtype(cContraVal) == "U"
   cContraVal := M->EF2_CONTRA
Elseif cCampo = "BANC" .and. Valtype(cBancVal) == "U"
   cBancVal   := M->EF2_BAN_FI
Elseif cCampo = "PRACA" .and. Valtype(cPracaVal) == "U"
   cPracaVal  := M->EF3_PRACA
Elseif cCampo = "SEQCNT" .and. Valtype(cSeqVal) == "U"
   cSeqVal    := M->EF3_SEQCNT
Endif

Do Case
   // ACSJ - 07/02/2005 - INICIO
   Case cCampo == "CONTRA" .or. cCampo == "BANC" .or. cCampo == "PRACA" .or. cCampo == "SEQCNT"
      If cOpcao == "INCLUIR"
         If cCampo == "BANC"
            if Empty(WORKEEQ->EF2_CONTRA)
               MsgInfo(STR0014) // "O campo contrato deve ser digitado primeiro"
               lRet := .f.
            Endif
         ElseIf cCampo == "PRACA"
            if Empty(WORKEEQ->EF2_BAN_FI)
               MsgInfo(STR0015) // "O campo banco deve ser digitado primeiro"
               lRet := .f.
            Endif
         ElseIf cCampo == "SEQCNT"
            If Empty(WORKEEQ->EF2_CONTRA)
               MsgInfo(STR0014) // "O campo contrato deve ser digitado primeiro"
               lRet := .f.
            Else //ASK 15/02/08 - Inclusão da validação do campo Sequencia do Contrato na Vinculação da parcela
               If !EF1->(dbSeek(xFilial("EF1")+"E"+WORKEEQ->EF2_CONTRA+WORKEEQ->EF2_BAN_FI+WorkEEQ->EF3_PRACA+M->EF3_SEQCNT))
                  MsgInfo(STR0090) //"Contrato+Banco+Praca+Sequencia do Contrato não existe"
                  lRet := .F.
               EndIf
            Endif
         Endif

         If lRet

            If cCampo == "CONTRA" .and. !Empty(M->EF2_CONTRA) 
               If .not. (( (!lEEQ_TP_CON .OR. TMP->EEQ_TP_CON $ "1/3") .AND. EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,"E","")+M->EF2_CONTRA))) .OR. ( lEEQ_TP_CON .AND. TMP->EEQ_TP_CON $ "2/4" .AND. EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,"I","")+M->EF2_CONTRA)))) //HVR JA FAZ SEEK I OU E
                  MsgInfo(STR0016) // "Contrato não existe"
                  lRet := .F.
               ElseIf /*EF1->EF1_TPMODU*/cMod == EXP .AND. Empty(EF1->EF1_DT_JUR) //HVR CONTRATO DE EXPORTACAO NÃO PODE ESTAR COM DATA DE INICIO DE JUROS EM BRANCO
                  MsgInfo(STR0074) //"Não é possível vincular a invoice, pois a data de inicio do juros não está preenchida no contrato."
                  lRet := .F.
               ElseIf /*EF1->EF1_TPMODU*/cMod == IMP .AND. !Empty(EF1->EF1_DT_JUR) //HVR  CONTRATO DE IMPORTAÇÃO NÃO PODE ESTAR COM A DATA DE INICIO DE JUROS PREENCHIDA
                  MsgInfo(STR0087) //"Não é possível vincular a invoice a contrato de importação, pois a data de inicio do juros está preenchida no contrato." //HVR
                  lRet := .F.
               //MFR 28/10/2109 OSSME-3908
               ElseIf EF1->EF1_TP_FIN == "01" .AND. EEC->EEC_DTEMBA < EF1->EF1_DT_CON
                     easyhelp(STR0101) //"Não é permitido vincular Invoice com data de embarque inferior à data de contrato do tipo ACC."
                     lRet := .F.
               //Valida a data de vinculacao em relacao a ultima data de contabilizacao do contrato
               ElseIf !VldVincCtb(WorkEEQ->DT_VINC)
                     lRet := .F.
               EndIf

               If(EasyEntryPoint("EECAF200"),ExecBlock("EECAF200", .F., .F., "VALIDA_CONTRATO"),)

               If lRet .and. TMP->EEQ_VCT > EF1->EF1_DT_VEN
                  MsgInfo(STR0017+" "+Alltrim(TMP->EEQ_NRINVO)+" "+STR0018+Alltrim(TMP->EEQ_PARC)+" "+STR0019) //"Invoice" # "Parcela  " # "possui data de vencimento maior que a data limite para vinculação"
               Endif
            Elseif cCampo == "BANC" .and. .not. Empty(M->EF2_BAN_FI)
               if  .not. EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,IF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+WORKEEQ->EF2_CONTRA+M->EF2_BAN_FI)) //HVR SEEK I OU E
                  MsgInfo(STR0020) // "Contrato+Banco não existe"
                  lRet := .f.
               Else
                  if SA6->(DBSeek(xFilial("SA6")+M->EF2_BAN_FI))
                     Reclock("WORKEEQ",.f.)
                     WORKEEQ->EF1DESFIN := SA6->A6_NREDUZ
                     M->EF1DESFIN       := SA6->A6_NREDUZ
                     TMP->EEQ_NOMEBC     := SA6->A6_NOME
                     WORKEEQ->(MsUnlock())
                  Endif
                  //** PLB 30/10/06 - Dados na Moeda do Financiamento
                  WorkEEQ->EF1_MOEDA := EF1->EF1_MOEDA
                  If WorkEEQ->( EEC_MOEDA == EF1_MOEDA )
                     WorkEEQ->TX_ME_FIN := WorkEEQ->TX_VINC
                  Else
                     WorkEEQ->TX_ME_FIN := BuscaTaxa(EF1->EF1_MOEDA,WorkEEQ->DT_VINC,,.F.,.T.,,cTX_100)
                  EndIf
                  WorkEEQ->VL_ME_FIN := WorkEEQ->( ( EEQ_VL * TX_VINC ) / TX_ME_FIN )
                  //**
                  TMP->EEQ_AGEN   := EF1->EF1_AGENFI
                  TMP->EEQ_NCON   := EF1->EF1_NCONFI
               Endif
            Elseif cCampo == "PRACA"  .and. .not. Empty(M->EF3_PRACA) // Não Estou verificando se lTemChave
                                                                  // pois so entra neste IF se existir PRACA na Base.
               if  .not. EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,IF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+WORKEEQ->EF2_CONTRA+WORKEEQ->EF2_BAN_FI+M->EF3_PRACA)) //HVR SEEK I OU E
                  MsgInfo(STR0021) // "Contrato+Banco+Praca não existe"
                  lRet := .f.
               Else
                  if EF5->(DBSeek(xFilial("EF5")+M->EF3_PRACA))
                     Reclock("WORKEEQ",.f.)
                     WORKEEQ->EF5_DESCRI := EF5->EF5_DESCRI
                     M->EF5_DESCRI       := EF5->EF5_DESCRI
                     WORKEEQ->(MsUnlock())
                  Endif
                  //** PLB 30/10/06 - Dados na Moeda do Financiamento
                  WorkEEQ->EF1_MOEDA := EF1->EF1_MOEDA
                  If WorkEEQ->( EEC_MOEDA == EF1_MOEDA )
                     WorkEEQ->TX_ME_FIN := WorkEEQ->TX_VINC
                  Else
                     WorkEEQ->TX_ME_FIN := BuscaTaxa(EF1->EF1_MOEDA,WorkEEQ->DT_VINC,,.F.,.T.,,cTX_100)
                  EndIf
                  WorkEEQ->VL_ME_FIN := WorkEEQ->( ( EEQ_VL * TX_VINC ) / TX_ME_FIN )
                  //**
               Endif

            //** AAF - 23/02/06 - Validação para o campo Sequência do Contrato.
            Elseif cCampo == "SEQCNT" .and. .not. Empty(M->EF3_SEQCNT)
               If !EF1->(dbSeek(xFilial("EF1")+"E"+WORKEEQ->EF2_CONTRA+WORKEEQ->EF2_BAN_FI+WorkEEQ->EF3_PRACA+M->EF3_SEQCNT))
                  MsgInfo(STR0090) //"Contrato+Banco+Praca+Sequencia do Contrato não existe"
                  lRet := .F.
               ElseIf Empty(EF1->EF1_DT_JUR)
                  MsgInfo(STR0074) //"Não é possível vincular a invoice, pois a data de inicio do juros não está preenchida no contrato."
                  lRet := .F.
               Else
                  //** PLB 30/10/06 - Dados na Moeda do Financiamento
                  WorkEEQ->EF1_MOEDA := EF1->EF1_MOEDA
                  If WorkEEQ->( EEC_MOEDA == EF1_MOEDA )
                     WorkEEQ->TX_ME_FIN := WorkEEQ->TX_VINC
                  Else
                     WorkEEQ->TX_ME_FIN := BuscaTaxa(EF1->EF1_MOEDA,WorkEEQ->DT_VINC,,.F.,.T.,,cTX_100)
                  EndIf
                  WorkEEQ->VL_ME_FIN := WorkEEQ->( ( EEQ_VL * TX_VINC ) / TX_ME_FIN )
                  //**
               Endif
            EndIf
            //**

            // ------------------------------------------------------------------------- ACSJ - 07/02/2005 - FIM
            If cCampo $ "CONTRA|SEQCNT" .and. lRet
               If !Empty(EF1->EF1_DT_ENC)
                  // By - A. Caetano Jr.- 10/12/2003
                  MsgInfo(STR0022+Alltrim(EF1->EF1_CONTRA)+STR0023+Dtoc(EF1->EF1_DT_ENC),STR0003)  // STR0022 - "O Contrato ("
               																					// STR0023 - ") já foi Encerrado em: "
               																					// STR0003 - "Atenção"
                  M->EF2_CONTRA:= Space(Len(EF1->EF1_CONTRA))
                  lRet := .F.
               ElseIf lTemChave
                  WorkEEQ->EF2_BAN_FI := EF1->EF1_BAN_FI
                  M->EF2_BAN_FI       := EF1->EF1_BAN_FI
                  If SA6->(DBSeek(xFilial("SA6")+M->EF2_BAN_FI+ EF1->EF1_AGENFI+EF1->EF1_NCONFI))
                     WORKEEQ->EF1DESFIN := SA6->A6_NREDUZ
                     M->EF1DESFIN       := SA6->A6_NREDUZ
                     //TMP->EEQ_NOMEBC     := SA6->A6_NOME
                  Endif
                  WorkEEQ->EEQ_AGEN      := EF1->EF1_AGENFI //FDR - 10/02/2017
                  WorkEEQ->EEQ_NCON      := EF1->EF1_NCONFI //FDR - 10/02/2017
                  //TMP->EEQ_AGEN      := EF1->EF1_AGENFI
                  //TMP->EEQ_NCON      := EF1->EF1_NCONFI
                  WorkEEQ->EF3_PRACA := EF1->EF1_PRACA
                  M->EF3_PRACA       := EF1->EF1_PRACA
                  If EF5->(DBSeek(xFilial("EF5")+M->EF3_PRACA))
                     WORKEEQ->EF5_DESCRI := EF5->EF5_DESCRI
                     M->EF5_DESCRI       := EF5->EF5_DESCRI
                  Endif
                  //** PLB 30/10/06 - Dados na Moeda do Financiamento
                  WorkEEQ->EF1_MOEDA := EF1->EF1_MOEDA
                  If WorkEEQ->( EEC_MOEDA == EF1_MOEDA )
                     WorkEEQ->TX_ME_FIN := WorkEEQ->TX_VINC
                  Else
                     WorkEEQ->TX_ME_FIN := BuscaTaxa(EF1->EF1_MOEDA,WorkEEQ->DT_VINC,,.F.,.T.,,cTX_100)
                  EndIf
                  WorkEEQ->VL_ME_FIN := WorkEEQ->( ( EEQ_VL * TX_VINC ) / TX_ME_FIN )
                  //**

                  //** AAF - 21/02/2006 - Grava o campo Sequência do contrato na Work.
                  If lEFFTpMod
                     WorkEEQ->EF3_SEQCNT := EF1->EF1_SEQCNT
                     M->EF3_SEQCNT       := EF1->EF1_SEQCNT
                  EndIf
                  //**
               EndIf
               //** GFC - Pré-Pagamento
               If lEFFTpMod .AND. TMP->EEQ_TP_CON $ ("2/4")
                  If lRet .and. lPrePag .and. IF(lEFFTpMod,EF1->EF1_CAMTRA == "1",EF1->EF1_TP_FIN $ ("03/04")) //HVR 25/04/06 - DE: EF1->EF1_TP_FIN $ ("03/04") PARA:IF(EF1->EF1_CAMTRA == "1",.T.,IF EF1->EF1_TP_FIN $ ("03/04")) VERIFICAR SE CONTRATO POSSUI PARCELAS DE PAGAMENTO
                     WorkEEQ->TIPOVINC := "1" //AAF - 02/05/06 - Não existe opção de vinculação em financiamento de importação.
                  EndIf
               ElseIf lRet .AND. lPrePag .AND. IF(lEFFTpMod,EF1->EF1_CAMTRA == "1",EF1->EF1_TP_FIN $ ("03/04"))
                  WorkEEQ->TIPOVINC := FAF2TpVinc()
                  Do While WorkEEQ->TIPOVINC == "2"  .And.  !ValFina("TIPOVINC")  // PLB 01/09/06
                     WorkEEQ->TIPOVINC := FAF2TpVinc()
                  EndDo
               EndIf
               //**
            Endif
         Endif
         If cContraVal <> WorkEEQ->EF2_CONTRA .and. lRet

            If !Empty(WorkEEQ->EF2_CONTRA) .and. (nPos := aScan(aExcVinculo,{|x| x[1]==WorkEEQ->EEQ_PARC .and.;
                      If(lEFFTpMod,x[10],"")+x[2]+iif(lTemChave,x[6]+x[7]+If(lEFFTpMod,x[9],""),"")==If(lEFFTpMod,IF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+WorkEEQ->EF2_CONTRA+iif(lTemChave,WorkEEQ->EF2_BAN_FI+WorkEEQ->EF3_PRACA+If(lEFFTpMod,WorkEEQ->EF3_SEQCNT,""),"") .and.;
                      x[5]==WorkEEQ->SEQ .and. x[3]==1})) = 0

               WorkEEQ->SEQ := Space(Len(WorkEEQ->SEQ))
            ElseIf Empty(WorkEEQ->EF2_CONTRA)
               nPsAux := aScan(aArrayEEQ,{|x| x[3]==TMP->EEQ_PARC .and. x[5]+iif(lTemChave,x[14]+x[15]+If(lEFFTpMod,x[21],""),"") == cContraVal+iif(lTemChave,cBancVal+cPracaVal+If(lEFFTPMod,cSeqVal,""),"")})
               If lRet .And. nPsAux > 0    // LGV 11/07/03
                  Msginfo(STR0022+Alltrim(EF1->EF1_CONTRA)+STR0024,STR0003) //"O Contrato (" # ") já existe para essa Invoice"
                  lRet := .F.
               Else  // LGV
                  WorkEEQ->SEQ := Space(Len(WorkEEQ->SEQ))
               EndIf
            ElseIf (nPos := aScan(aExcVinculo,{|x| x[1]==WorkEEQ->EEQ_PARC .and. x[5]==WorkEEQ->SEQ .and. x[3]==1})) <> 0 .and.;
                    aExcVinculo[nPos,2]+iif(lTemChave,aExcVinculo[nPos,6]+aExcVinculo[nPos,7]+If(lEFFTpMod,aExcVinculo[nPos,9],""),"") == M->EF2_CONTRA+iif(lTemChave,M->EF2_BAN_FI+M->EF3_PRACA+If(lEFFTPMod,M->EF3_SEQCNT,""),"")
               WorkEEQ->SEQ := Space(Len(WorkEEQ->SEQ))
            EndIf
         EndIf
      Else
         If cContraVal+cBancVal+iif(lTemChave,cPracaVal+If(lEFFTPMod,cSeqVal,""), "") <> WorkEEQ->EF2_CONTRA+WorkEEQ->EF2_BAN_FI+iif(lTemChave,WorkEEQ->EF3_PRACA+If(lEFFTPMod,WorkEEQ->EF3_SEQCNT,""),"")
            If !Empty(cContraVal)
               Help(" ",1,"AVG0005230") //MsgInfo("Vinculação não pode ser alterada, somente excluída.")
               lRet := .F.
            // ACSJ - 06/02/2005
            ElseIf EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,IF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+WorkEEQ->EF2_CONTRA+iif(lTemChave, WorkEEQ->EF2_BAN_FI+WorkEEQ->EF3_PRACA+If(lEFFTPMod,WorkEEQ->EF3_SEQCNT,""),""))) .and. !Empty(EF1->EF1_DT_ENC) //HVR SEEK I OU E
               MsgInfo(STR0025) //"Parcela não pode ser desvinculada pois o contrato já foi encerrado."
               lRet := .F.
            ElseIf !Empty(WorkEEQ->EF2_CONTRA) .and. (nPos := aScan(aExcVinculo,{|x| x[1]==WorkEEQ->EEQ_PARC .and.;
                          x[2]+iif(lTemChave,x[6]+x[7]+If(lEFFTpMod,x[9],""),"")==WorkEEQ->EF2_CONTRA+iif(lTemChave,WorkEEQ->EF2_BAN_FI+WorkEEQ->EF3_PRACA+If(lEFFTpMod,WorkEEQ->EF3_SEQCNT,""),"") .and.;
                          x[5]==WorkEEQ->SEQ .and. x[3]==1})) = 0
               WorkEEQ->SEQ := Space(Len(WorkEEQ->SEQ))
            ElseIf lTemChave
               WorkEEQ->EF2_BAN_FI := EF1->EF1_BAN_FI
               M->EF2_BAN_FI       := EF1->EF1_BAN_FI
               If SA6->(DBSeek(xFilial("SA6")+M->EF2_BAN_FI))
                  WORKEEQ->EF1DESFIN := SA6->A6_NREDUZ
                  M->EF1DESFIN       := SA6->A6_NREDUZ
                  TMP->EEQ_NOMEBC     := SA6->A6_NOME
               Endif
               TMP->EEQ_AGEN      := EF1->EF1_AGENFI
               TMP->EEQ_NCON      := EF1->EF1_NCONFI
               WorkEEQ->EF3_PRACA := EF1->EF1_PRACA
               M->EF3_PRACA       := EF1->EF1_PRACA
               If EF5->(DBSeek(xFilial("EF5")+M->EF3_PRACA))
                  WORKEEQ->EF5_DESCRI := EF5->EF5_DESCRI
                  M->EF5_DESCRI       := EF5->EF5_DESCRI
               Endif

               //** AAF - 21/02/2006 - Grava o campo Sequência do contrato na Work.
               If lEFFTpMod
                  WorkEEQ->EF3_SEQCNT := EF1->EF1_SEQCNT
                  M->EF3_SEQCNT       := EF1->EF1_SEQCNT
               EndIf
               //**
            EndIf
            //** GFC - Pré-Pagamento
            If lEFFTpMod .AND. TMP->EEQ_TP_CON $ ("2/4")
               If lRet .and. lPrePag .and. IF(lEFFTpMod,EF1->EF1_CAMTRA == "1",EF1->EF1_TP_FIN $ ("03/04")) //HVR 25/04/06 - DE: EF1->EF1_TP_FIN $ ("03/04") PARA:IF(EF1->EF1_CAMTRA == "1",.T.,IF EF1->EF1_TP_FIN $ ("03/04")) VERIFICAR SE CONTRATO POSSUI PARCELAS DE PAGAMENTO
                  WorkEEQ->TIPOVINC := "1" //AAF - 02/05/06 - Não existe opção de vinculação em financiamento de importação.
               EndIf
            ElseIf lRet .and. lPrePag .and. IF(lEFFTpMod,EF1->EF1_CAMTRA == "1",EF1->EF1_TP_FIN $ ("03/04")) //HVR 25/04/06 - DE: EF1->EF1_TP_FIN $ ("03/04") PARA:IF(EF1->EF1_CAMTRA == "1",.T.,IF EF1->EF1_TP_FIN $ ("03/04")) VERIFICAR SE CONTRATO POSSUI PARCELAS DE PAGAMENTO
               WorkEEQ->TIPOVINC := FAF2TpVinc()
            EndIf
            //**
         EndIf
      EndIf
   Case cCampo == "EEQ_VL"
      If WORKEEQ->EEQ_EVENT == "603"
         MsgStop("O valor da vinculação deve ser o mesmo do adiantamento pos-embarque. Caso necessário, altere o valor do adiantamento.")
         lRet := .F.
      EndIf

      //SVG-05/12/08
      nVltxEF1:=BuscaTaxa(EF1->EF1_MOEDA,WORKEEQ->DT_VINC,,.F.,.T.,,cTX_100)
      //MFR 05/10/2021 OSSME-6276 
      nSaldoCtr := if(EF1->EF1_TP_FIN=="02",EF1->EF1_VL_MOE - EX401EvSum("600","EF3",xFilial("EF3")+"E" + EF1->EF1_CONTRA + EF1->EF1_BAN_FI + EF1->EF1_PRACA + EF1->EF1_SEQCNT,.T.),EF1->EF1_SLD_PM)
      IF WORKEEQ->EEC_MOEDA == WORKEEQ->EF1_MOEDA
         nVlVinculado :=M->EEQ_VL
      Else
         nVlVinculado:=(M->EEQ_VL*WORKEEQ->TX_VINC)/nVltxEF1
      Endif
      If Empty(WorkEEQ->EF2_CONTRA)
         Help(" ",1,"AVG0005231") //MsgInfo("Campo só pode ser alterado caso parcela esteja vinculada a um contrato.")
         lRet := .F.
      ElseIf M->EEQ_VL <= 0
         Help(" ",1,"AVG0005232") //MsgInfo("Valor deve ser maior que zero.")
         lRet := .F.
      /*ElseIf M->EEQ_VL > (WorkEEQ->EEQ_VL+WorkEEQ->EEC_VALCOM)
         Help(" ",1,"AVG0005233") //MsgInfo("Valor maior que o saldo da parcela.")
         lRet := .F.*/
      ElseIf M->EEQ_VL > WorkEEQ->VL_ORI //(WorkEEQ->VL_ORI-WorkEEQ->EEC_VALCOM)
         Help(" ",1,"AVG0005233") //MsgInfo("Valor maior que o saldo da parcela.")
         lRet := .F.                                                                                                                                                                                                                          //MFR 05/10/2021 OSSME-6276                                                           
      ElseIf EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,IF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+WorkEEQ->EF2_CONTRA+iif(lTemChave, WorkEEQ->EF2_BAN_FI+WorkEEQ->EF3_PRACA+If(lEFFTpMod,WorkEEQ->EF3_SEQCNT,""),""))) .and. nVlVinculado > nSaldoCtr // SVG 05/12/08 M->EEQ_VL > EF1->EF1_SLD_PM     //HVR SEEK I OU E
         If lBOk
            MsgInfo(StrTran(StrTran("O saldo a vincular do contrato 'XXX' (YYY), é inferior ao valor informado.", "XXX", AllTrim(WorkEEQ->EF2_CONTRA)), "YYY", AllTrim(Trans(nSaldoCtr,AVSX3("EF1_SLD_PM",6)))), "Atenção")
         Else
            MsgInfo(STR0026+Trans(nSaldoCtr,AVSX3("EF1_SLD_PM",6))) //"Valor a vincular não pode ser maior que saldo do contrato. "
         EndIf
         lRet := .F.
      ElseIf M->EEQ_VL != WorkEEQ->EEQ_VL
         //If M->EEQ_VL < WorkEEQ->EEQ_VL
         /* RMD 01/09/06 - 1 - Valida a quantidade digitada com o saldo (quantidade disponível na parcela não vinculada, para permitir
                               alterações de quantidade a maior (antes só permitia a menor).
                           2 - Atualiza os valores das comissões, para calcular corretamente o valor da parcela no
         						    OK final. Neste momento o valor da parcela é o Vl.Fech.Camb.
         */
         oGet:lCondicional := .F.  // LGV get
         nAux                := WorkEEQ->EEQ_VL - M->EEQ_VL
         //nRec                := WorkEEQ->(RecNo())
         nValCom1            := WorkEEQ->EEC_VALCOM
         nValCom2            := (M->EEQ_VL / WorkEEQ->EEQ_VL) * WorkEEQ->EEC_VALCOM
         //WorkEEQ->EEQ_VL     := M->EEQ_VL

         //** PLB 19/10/06 - Substituido o controle temporário da sobra de parcela da WorkEEQ para o array

         /*WorkEEQ->( DBSetOrder(1) )

         If WorkEEQ->(dbSeek(WorkEEQ->EEQ_PARC+Space(Len(WorkEEQ->EF2_CONTRA))))
            If (WorkEEQ->EEQ_VL + nAux) > 0
               WorkEEQ->EEQ_VL += nAux
            ElseIf (WorkEEQ->EEQ_VL + nAux) < 0
               Help(" ",1,"AVG0005233") //MsgInfo("Valor maior que o saldo da parcela.")
               lRet := .F.
               //Break
            Else   // PLB 11/10/06 - Caso o valor da parcela seja vinculado totalmente, o excedente que havia sido gerado será excluido.
               RecLock("WorkEEQ",.F.)
               WorkEEQ->( DBDelete() )
            EndIf
            If lRet  // PLB 11/10/06
               WorkEEQ->EEC_VALCOM += (nValCom1 - nValCom2)
            EndIf
            WorkEEQ->(dbGoTo(nRec))
            If lRet  // PLB 11/10/06
               WorkEEQ->EEQ_VL := M->EEQ_VL
            EndIf
         Else
            WorkEEQ->(dbGoTo(nRec))
            WorkEEQ->EEQ_VL := M->EEQ_VL  // PLB 11/10/06
            dVct      := WorkEEQ->EEQ_VCT
            cPar      := WorkEEQ->EEQ_PARC
            cBanq     := WorkEEQ->EF2_BAN_FI
            nTxAux    := WorkEEQ->TX_VINC
            nVlOri    := WorkEEQ->VL_ORI
            If nAux > 0
               WorkEEQ->(RecLock("WorkEEQ",.T.))
               WorkEEQ->EEQ_VL     := nAux
               WorkEEQ->EEQ_VCT    := dVct
               WorkEEQ->EEQ_PARC   := cPar
               WorkEEQ->VL_ORI     := nVlOri
               WorkEEQ->EF2_BAN_FI := cBanq
               WorkEEQ->EF1_DES_FI := If(SA6->(DbSeek(cFilSA6+TMP->EEQ_BANC)), SA6->A6_NREDUZ, "")
               WorkEEQ->TX_VINC    := nTxAux
               WorkEEQ->DT_VINC    := dDataBase
               WorkEEQ->EEC_Moeda  := TMP->EEQ_MOEDA     //LGV moeda
               WorkEEQ->EEC_VALCOM := nValCom1 - nValCom2
               WorkEEQ->(msUnlock())
            EndIf
         EndIf*/
         If Len(aWKEEQ) > 0
            nPos := WorkEEQ->( FieldPos("EEQ_VL") )
            If (aWKEEQ[Len(aWKEEQ)][nPos] + nAux) > 0
               aWKEEQ[Len(aWKEEQ)][nPos] += nAux
            ElseIf (aWKEEQ[Len(aWKEEQ)][nPos] + nAux) < 0
               Help(" ",1,"AVG0005233") //MsgInfo("Valor maior que o saldo da parcela.")
               lRet := .F.
            Else
               aWKEEQ := {}
            EndIf
            If lRet
               If Len(aWKEEQ) > 0
                  aWKEEQ[1][WorkEEQ->( FieldPos("EEC_VALCOM") )] += (nValCom1 - nValCom2)
               EndIf
               WorkEEQ->EEQ_VL := M->EEQ_VL
            EndIf
         Else
            WorkEEQ->EEQ_VL := M->EEQ_VL
            If nAux > 0
               AADD(aWKEEQ,Array(WorkEEQ->( FCount() )) )
               aWKEEQ[Len(aWKEEQ)][WorkEEQ->( FieldPos("EEQ_VL"    ) )] := nAux
               aWKEEQ[Len(aWKEEQ)][WorkEEQ->( FieldPos("EEQ_VCT"   ) )] := WorkEEQ->EEQ_VCT
               aWKEEQ[Len(aWKEEQ)][WorkEEQ->( FieldPos("EEQ_PARC"  ) )] := WorkEEQ->EEQ_PARC
               aWKEEQ[Len(aWKEEQ)][WorkEEQ->( FieldPos("VL_ORI"    ) )] := WorkEEQ->VL_ORI
               aWKEEQ[Len(aWKEEQ)][WorkEEQ->( FieldPos("EF2_BAN_FI") )] := WorkEEQ->EF2_BAN_FI
               aWKEEQ[Len(aWKEEQ)][WorkEEQ->( FieldPos("EF1DESFIN") )] := If(SA6->(DbSeek(cFilSA6+TMP->EEQ_BANC)), SA6->A6_NREDUZ, "")
               aWKEEQ[Len(aWKEEQ)][WorkEEQ->( FieldPos("TX_VINC"   ) )] := WorkEEQ->TX_VINC
               aWKEEQ[Len(aWKEEQ)][WorkEEQ->( FieldPos("DT_VINC"   ) )] := dDataBase
               aWKEEQ[Len(aWKEEQ)][WorkEEQ->( FieldPos("EEC_Moeda" ) )] := TMP->EEQ_MOEDA
               aWKEEQ[Len(aWKEEQ)][WorkEEQ->( FieldPos("EEC_VALCOM") )] := nValCom1 - nValCom2
               //** PLB 30/10/06
               aWKEEQ[Len(aWKEEQ)][WorkEEQ->( FieldPos("EF1_MOEDA" ) )] := ""
               aWKEEQ[Len(aWKEEQ)][WorkEEQ->( FieldPos("TX_ME_FIN" ) )] := WorkEEQ->TX_ME_FIN
               aWKEEQ[Len(aWKEEQ)][WorkEEQ->( FieldPos("VL_ME_FIN" ) )] := 0
               //**
               If WorkEEQ->( FieldPos("EF3_DTDOC") ) > 0//FSY - 18/04/2013
                  aWKEEQ[Len(aWKEEQ)][WorkEEQ->( FieldPos("EF3_DTDOC") )] := dDataBase
               EndIf
            EndIf
         EndIf
         //**

         //WorkEEQ->(dbGoTo(nRec))
         //Atualiza o valor da comissão
         WorkEEQ->EEC_VALCOM := nValCom2
         oGet:oBrowse:Refresh()
      EndIf
      //** PLB 30/10/06 - Dados na Moeda do Financiamento
      If lRet
         WorkEEQ->VL_ME_FIN := ( M->EEQ_VL * WorkEEQ->TX_VINC ) / WorkEEQ->TX_ME_FIN
      EndIf
      //**
      /*
      //** GFC - Pré-Pagamento/Securitização
      If lRet .and. !Empty(WorkEEQ->EF2_CONTRA) .and. lPrePag .and. IF(lEFFTpMod,IF EF1->EF1_CAMTRA == "1",IF EF1->EF1_TP_FIN $ ("03/04")) //HVR 25/04/06 - DE: EF1->EF1_TP_FIN $ ("03/04") PARA:IF(EF1->EF1_CAMTRA == "1",.T.,IF EF1->EF1_TP_FIN $ ("03/04")) VERIFICAR SE CONTRATO POSSUI PARCELAS DE PAGAMENTO
         EF3->(dbSetOrder(1))

         //Posiciona na primeira parcela em aberto
         nSaldoVin := EXPosPrePag("EF3",EF1->EF1_CONTRA,EF1->EF1_BAN_FI,EF1->EF1_PRACA,.T.)

         //Caso o valor a vincular seja maior que o saldo, verifica se pode deduzir da próxima
         If M->EEQ_VL > nSaldoVin
            EF3->(dbSkip())

            If !EF3->(EOF()) .and. EF3->EF3_FILIAL==xFilial("EF3") .and. EF3->EF3_CONTRA==EF1->EF1_CONTRA .and.;
            EF3->EF3_BAN_FI==EF1->EF1_BAN_FI .and. EF3->EF3_PRACA==EF1->EF1_PRACA .and.;
            EF3->EF3_CODEVE == EV_PRINC_PREPAG .and. EF3->EF3_VL_MOE - (M->EEQ_VL - nSaldoVin) < 0
               MsgInfo(STR0173+Trans(nSaldoVin,AVSX3("EF1_SLD_PM",6))) //"Esse valor a vincular invalidaria a próxima parcela. o Saldo restante da parcela atual é de "
               lRet := .F.
            Else
               If !MsgYesNo(STR0174) //"O saldo da parcela atual é insuficiente. Deseja utilizar a diferença da próxima parcela?"
                  lRet := .F.
               EndIf
            EndIf
         EndIf
      EndIf
      //** */
   Case cCampo == "LIQEST"
      If lIntCont .and. !EMPTY(TMP->EEQ_NR_CONT)
         If !MsgYESNO("Deseja realmente estornar a liquidação desta parcela?" + Chr(13) + Chr(10)+;
                      "ATENÇÃO! Parcela já contabilizada." + ENTER + ;
                      "Confirma Estorno?")
            lRet:=.F.
         EndIf
	  EndIf

	  If Empty(TMP->EEQ_PGT)
         If lOkEvent
            Help(" ",1,"AVG0005235")
         Else
            MsgInfo(STR0027,STR0003)      //"Não é possível efetuar o Estorno pois a parcela não foi liquidada."###"Atenção"
         EndIf
         lRet := .F.
      EndIf

      //If (nPos:=aScan(aArrayEEQ,{|x| x[3]==If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN)}))>0 .and.;
      //!Empty(aArrayEEQ[nPos,5]) .And. EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,IF(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),"")+aArrayEEQ[nPos,5]+iif(lTemChave,aArrayEEQ[nPos,14]+aArrayEEQ[nPos,15]+If(lEFFTpMod,aArrayEEQ[nPos,21],""),""))) .And. !Empty(EF1->EF1_DT_ENC)  // LGV 11/07/03 //HVR SEEK I OU E
      // PLB 23/08/07
      If (nPos:=aScan(aArrayEEQ,{|x| x[3]==TMP->EEQ_PARC}))>0 .and. !Empty(aArrayEEQ[nPos,5]);
         .And. EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,IF(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),"")+aArrayEEQ[nPos,5]+iif(lTemChave,aArrayEEQ[nPos,14]+aArrayEEQ[nPos,15]+If(lEFFTpMod,aArrayEEQ[nPos,21],""),""))) // LGV 11/07/03 //HVR SEEK I OU E

		 If !Empty(EF1->EF1_DT_ENC)
            MsgInfo(STR0028+Alltrim(EF1->EF1_CONTRA)+STR0029+Dtoc(EF1->EF1_DT_ENC), STR0003) //"Liquidação não pode ser estornada pois o Contrato (" # ") já foi Encerrado em: "
            lRet := .F.
		 EndIf

		 aOrd := EF3->({IndexOrd(),RecNo()})
		 EF3->(dbSetOrder(1))//EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_CODEVE+EF3_PARC+EF3_INVOIC+EF3_INVIMP+EF3_LINHA
		 If EF1->EF1_PGJURO <> "1" .AND. EF3->(dbSeek(xFilial("EF3")+EF1->(EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT)+"630"+TMP->(EEQ_PARC+EEQ_NRINVO)))

			//Busca por eventos de juros associados a liquidação desta invoice
			cChave := EF3->(EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_SEQ)+"64"
			EF3->(dbSetOrder(4))//EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_SEQ+EF3_CODEVE
            Do While EF3->(!Eof() .AND. Left(&(IndexKey()),Len(cChave)) == cChave)
			   If EF3->EF3_VL_REA <> 0
			      EasyHelp("Não é possível estornar a liquidação desta parcela pois existem parcelas de juros associadas já liquidadas no contrato "+EF3->EF3_CONTRA,"Atenção")
				  lRet := .F.
			      EXIT
			   EndIf

			   EF3->(dbSkip())
			EndDo
		 EndIf

		 EF3->(dbSetOrder(aOrd[1]),dbGoTo(aOrd[2]))
      EndIf

   Case Left(cCampo,3) == "LIQ"
      //If (nPos:=aScan(aArrayEEQ,{|x| x[3]==If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN)}))>0 .and.;
      //!Empty(aArrayEEQ[nPos,5]) .And. EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,IF(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),"")+aArrayEEQ[nPos,5]+iif(lTemChave,aArrayEEQ[nPos,14]+aArrayEEQ[nPos,15]+If(lEFFTpMod,aArrayEEQ[nPos,21],""),""))) .And. !Empty(EF1->EF1_DT_ENC)  // LGV 11/07/03 //HVR SEEK I OU E
      // PLB 23/08/07
      If (nPos:=aScan(aArrayEEQ,{|x| x[3]==TMP->EEQ_PARC}))>0  .And. !Empty(aArrayEEQ[nPos,5]) ;
         .And. EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,IF(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),"")+aArrayEEQ[nPos,5]+iif(lTemChave,aArrayEEQ[nPos,14]+aArrayEEQ[nPos,15]+If(lEFFTpMod,aArrayEEQ[nPos,21],""),""))) .And. !Empty(EF1->EF1_DT_ENC)  // LGV 11/07/03 //HVR SEEK I OU E
         MsgInfo(STR0030+Alltrim(EF1->EF1_CONTRA)+STR0029+Dtoc(EF1->EF1_DT_ENC), STR0003) //"Parcela não pode ser Liquidada, pois o Contrato (" # ") já foi Encerrado em: "
         lRet := .F.
      EndIf
      /*nAux := EF3->(IndexOrd())
      EF3->(dbSetOrder(3))
      If !EF3->(dbSeek(cFilEF3+TMP->EEQ_NRINVO+TMP->EEQ_PARC))
         Help(" ",1,"AVG0005234") //MsgInfo("Não é possível efetuar as rotinas de liquidação pois a parcela não está vinculada a nenhum Contrato.")
         lRet := .F.
      ElseIf cCampo == "LIQEST" .and. Empty(TMP->EEQ_PGT)
         Help(" ",1,"AVG0005235") //MsgInfo("Não é possível efetuar o Estorno pois a parcela não foi liquidada.")
         lRet := .F.
      EndIf
      EF3->(dbSetOrder(nAux)) */
   Case cCampo == "VINC"
      If !Empty(TMP->EEQ_PGT) .AND. TMP->EEQ_EVENT <> "603" //AAF - 02/03/09 - Vinculação de adiantamento pos-embarque ao financiamento.
         Help(" ",1,"AVG0005236") //MsgInfo("Parcela não pode ser alterada pois está liquidada.")
         lRet := .F.
      ElseIf Empty(TMP->EEQ_NRINVO)
         MsgInfo(STR0031) //"Parcela não pode ser vinculada pois o nro. da invoice não está preenchido."
         lRet := .F.
      ElseIf TMP->EEQ_EVENT <> "101" .AND. TMP->EEQ_EVENT <> "603" //AAF - 02/03/09 - Vinculação de adiantamento pos-embarque ao financiamento.  // LGV 10/07/03
         MsgInfo(STR0032,STR0033) //"Não é possível efetuar a Vinculação para Eventos diferentes de '101'"###"Aviso"
         lRet := .F.
      //ElseIf (nPos:=aScan(aArrayEEQ,{|x| x[3]==If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN)})) > 0  ;
      //       .And. !Empty(aArrayEEQ[nPos,5])
      // PLB 23/08/07
      ElseIf (nPos:=aScan(aArrayEEQ,{|x| x[3]==TMP->EEQ_PARC})) > 0  .And. !Empty(aArrayEEQ[nPos,5])
         MsgInfo(STR0093)  //"Parcela já está vinculada a contrato de financiamento."
         lRet := .F.
      EndIf

      If(EasyEntryPoint("EECAF200"),ExecBlock("EECAF200", .F., .F., "VALIDA_VINCULACAO"),)

   Case cCampo == "VINCEST"    // LGV 11/07/03
      //If (nPos:=aScan(aArrayEEQ,{|x| x[3]==If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN)}))>0
      // PLB 23/08/07
      If (nPos:=aScan(aArrayEEQ,{|x| x[3]==TMP->EEQ_PARC}))>0
         For ni:=nPos to Len(aArrayEEQ)
            //If aArrayEEQ[ni,3] <> If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN) .or.;
            // PLB 23/08/07
            If aArrayEEQ[ni,3] <> TMP->EEQ_PARC  .Or.  !Empty(aArrayEEQ[ni,5])
               lRet := .F.
               Exit
            EndIf
         Next ni
         //If lRet .or. (!lRet .and. aArrayEEQ[ni,3] <> If(!lParFin .Or. Empty(TMP->EEQ_PARFIN),TMP->EEQ_PARC,TMP->EEQ_PARFIN))
         // PLB 23/08/07
         If lRet .or. (!lRet .and. aArrayEEQ[ni,3] <> TMP->EEQ_PARC )
            lRet:=.F.
            MsgInfo(STR0034,STR0035) //"A Parcela não está Vinculada!","Estorno Impossibilitado...")  // LGV msg 11/07/03
         Else
            cEF3SEQ := aArrayEEQ[nPos,6]
            lRet := .T.
         EndIf
      EndIf
      If lRet
         If !Empty(TMP->EEQ_PGT) .AND. TMP->EEQ_EVENT <> "603" //AAF 02/03/09 - Permitir vinculacao de adiantamento pos-embarque.
            MsgInfo(STR0036,STR0035) //"A Parcela já está Liquidada!","Estorno Impossibilitado...")  // LGV msg 11/07/03
            lRet:= .F.
         ElseIf lParFin .and. !Empty(TMP->EEQ_PARFIN)
            nRec     := TMP->(RecNo())
            cCharAux := TMP->EEQ_PARFIN
            TMP->(dbGoTop())
            Do While !TMP->(EOF())
               If TMP->EEQ_PARFIN == cCharAux .and. !Empty(TMP->EEQ_PGT) .AND. TMP->EEQ_EVENT <> "603"
                  MsgInfo(STR0037) //"Estorno impossibilitado pois esta parcela faz parte de uma vinculação maior que já foi parcialmente liquidada."
                  lRet := .F.
                  Exit
               EndIf
               TMP->(dbSkip())
            EndDo
            TMP->(dbGoTo(nRec))
         Endif
         If lRet .And. Empty(cEF3SEQ)
            MsgInfo(STR0102,STR0035)//"É necessário confirmar a gravação do câmbio antes de efetuar o Estorno da Vinculação."####"Estorno Impossibilitado..."
            lRet := .F.
         EndIf
      EndIf
   Case cCampo == "DT_VINC"
      EF1->(DBSETORDER(1))
      If Empty(M->DT_VINC)
         MsgInfo(STR0038) //"Data de Vinculação deve ser preenchida."
         lRet := .F.
      //ElseIf EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,IF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+WorkEEQ->EF2_CONTRA+iif(lTemChave, WorkEEQ->EF2_BAN_FI+WorkEEQ->EF3_PRACA+If(lEFFTpMod,WorkEEQ->EF3_SEQCNT,""),""))) .and. M->DT_VINC < EF1->EF1_DT_JUR //HVR SEEK I OU E
      EndIf
      If lRet .And. EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,IF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+WorkEEQ->EF2_CONTRA+iif(lTemChave, WorkEEQ->EF2_BAN_FI+WorkEEQ->EF3_PRACA+If(lEFFTpMod,WorkEEQ->EF3_SEQCNT,""),"")))
      //** PLB 29/06/07 - Tratamento para permitir Vinculações em contratos ACE
         If  M->DT_VINC < EF1->EF1_DT_JUR  .And.  !(EF1->EF1_TP_FIN == "02")
            MsgInfo(STR0039+" "+Dtoc(EF1->EF1_DT_JUR)) //"Data de Vinculação deve ser maior ou igual a data de início de juros "
            lRet := .F.
         ElseIf M->DT_VINC < EF1->EF1_DT_CON
            MsgInfo(STR0100+" "+Dtoc(EF1->EF1_DT_CON)) //"Data de Vinculação deve ser maior ou igual a data de início do contrato "
            lRet := .F.
         //**
         ElseIf M->DT_VINC < EEC->EEC_DTEMBA .AND. Empty(WorkEEQ->EEQ_PGT)
            MsgInfo(STR0040+" ("+DtoC(EEC->EEC_DTEMBA)+")") //"Data de Vinculação não pode ser menor que a Data de Embarque."
            lRet := .F.
         ElseIf M->DT_VINC > dDataBase
            MsgInfo(STR0075) //"A Data de Vinculação não pode ser maior que a data corrente do sistema."
            lRet := .F.
         //** PLB 24/10/06 - Verifica se data de vinculação é maior que a data da primeira parcela de pagamento em aberto
         ElseIf EF1->( DBSeek(xFilial("EF1")+IIF(lEFFTpMod,IIF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+WorkEEQ->EF2_CONTRA+IIF(lTemChave, WorkEEQ->EF2_BAN_FI+WorkEEQ->EF3_PRACA,"")+IIF(lEFFTpMod,WorkEEQ->EF3_SEQCNT,""))) ;
               .And. IIF(lEFFTpMod,EF1->EF1_CAMTRA=="1",lPrepag .And. EF1->EF1_TP_FIN $ PRE_PAGTO+"/"+SECURITIZACAO) ;
               .And. EXPosPrePag("EF3",EF1->EF1_CONTRA,IIF(lTemChave,EF1->EF1_BAN_FI,""),IIF(lTemChave,EF1->EF1_PRACA,""),.T.,WorkEEQ->TIPOVINC,IIF(lEFFTpMod,EF1->EF1_TPMODU,""),IIF(lEFFTpMod,EF1->EF1_SEQCNT,"") ) > 0 ;
               .And. M->DT_VINC > EF3->EF3_DT_EVE
            MsgInfo(STR0094+DToC(EF3->EF3_DT_EVE))  //"A Data de Vinculação não pode ser maior do que a data da primeira parcela em aberto: " ###
            lRet := .F.
         //**

         //** AAF 03/03/09 - Não permite vinculação maior que pagamento para adiantamento pos-embarque
         ElseIf !Empty(WorkEEQ->EEQ_PGT) .AND. M->DT_VINC > WorkEEQ->EEQ_PGT
            MsgStop("Data de Vinculação não pode ser maior que a data de liquidação da parcela")
            lRet := .F.
         //* FSY 19/06/2013 - Nao permitir que a data de vinculação seja maior que a data credito exterior
         //ElseIf !Empty(WorkEEQ->EEQ_DTCE) .AND. WorkEEQ->EEQ_DTCE < M->DT_VINC
            //EasyHelp("Data de Vinculação não pode ser maior que a Data de credito exterior ("+ DtoC(WorkEEQ->EEQ_DTCE) +").")
            //lRet := .F.
         //*
         //Valida a data de vinculacao em relacao a ultima data de contabilizacao do contrato
         ElseIf !VldVincCtb(M->DT_VINC)
            lRet := .F.
         EndIf
      EndIf
      //**

      If lRet
         WorkEEQ->DT_VINC  := M->DT_VINC
         WorkEEQ->TX_VINC  := BuscaTaxa(M->EEC_MOEDA,M->DT_VINC,,.F.,.T.,,cTX_100)
      EndIF

   Case cCampo == "TIPOVINC"  // PLB 01/09/06 - Verifica se Periodo de Juros permite vincular Invoice a Parcela de Juros
      EF2->( DBSetOrder(1) )
      If EF2->( DBSeek(EF1->EF1_FILIAL+IIF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA+IIF(lTemChave,EF1->EF1_BAN_FI+EF1->EF1_PRACA,"")+IIF(lEFFTpMod,EF1->EF1_SEQCNT,"")) )
         lRet := .F.
         Do While !EF2->( EoF() )  .And.  EF2->( EF2_FILIAL+IIF(lEFFTpMod,EF2_TPMODU,"")+EF2_CONTRA+IIF(lTemChave,EF2_BAN_FI+EF2_PRACA,"")+IIF(lEFFTpMod,EF2_SEQCNT,"") ) == EF1->( EF1_FILIAL+IIF(lEFFTpMod,EF1_TPMODU,"")+EF1_CONTRA+IIF(lTemChave,EF1_BAN_FI+EF1_PRACA,"")+IIF(lEFFTpMod,EF1_SEQCNT,"") )
            If EF2->EF2_USEINV == "1"  //Sim
               lRet := .T.
               Exit
            EndIf
            EF2->( DBSkip() )
         EndDo
         If !lRet
            MsgStop(STR0092)  //"Nenhum dos Periodos de Juros do Contrato de Financiamento permite vinculacoes de Invoices a Parcelas de Juros."
         EndIf
      EndIf

   Case cCampo == "TX_VINC"  // PLB 16/10/06 - Verifica taxa de vinculação
      If M->TX_VINC <= 0
         Help(" ",1,"AVG0005232") //MsgInfo("Valor deve ser maior que zero.")
         lRet := .F.
      Else
        //** PLB 30/10/06 - Dados na Moeda do Financiamento
        If WorkEEQ->( EEC_MOEDA == EF1_MOEDA  .Or.  Empty(EF1_MOEDA) )
           WorkEEQ->TX_ME_FIN := M->TX_VINC
        Else
           WorkEEQ->VL_ME_FIN := ( WorkEEQ->EEQ_VL * M->TX_VINC ) / WorkEEQ->TX_ME_FIN
        EndIf
        //**
      EndIf

   //** PLB 30/10/06
   Case cCampo == "TX_ME_FIN"
      If Empty(WorkEEQ->EF1_MOEDA)
         MsgInfo(STR0098)  //"Preencha os dados do Contrato primeiro."
         lRet := .F.
      ElseIf WorkEEQ->( EEC_MOEDA == EF1_MOEDA )
         MsgInfo(STR0099)  //"Não é permitida alteração desta taxa pois a moeda da Invoice é a mesma que a do Contrato de Financiamento. Altere somente a taxa de vinculação."
         lRet := .F.
      ElseIf M->TX_ME_FIN <= 0
         Help(" ",1,"AVG0005232") //"Valor deve ser maior que zero."
         lRet := .F.
      Else
        WorkEEQ->VL_ME_FIN := ( WorkEEQ->EEQ_VL * WorkEEQ->TX_VINC ) / M->TX_ME_FIN
      EndIf
   //**

   Case cCampo == "TUDO_OK"  // PLB 20/10/06 - Verifica a tela de vinculação
      If !Empty(WorkEEQ->EF2_CONTRA)
         //** AAF 03/03/09 - Não permite vinculação maior que pagamento para adiantamento pos-embarque
         If !Empty(WorkEEQ->EEQ_PGT) .AND. WorkEEQ->DT_VINC > WorkEEQ->EEQ_PGT
            MsgStop("Data de Vinculação não pode ser maior que a data de liquidação da parcela")
            lRet := .F.
         EndIf
         //**

         If lRet .AND. WorkEEQ->TIPOVINC $ "1/2"
            If EF1->( DBSeek(cFilEF1+IIF(lEFFTpMod,IIF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+WorkEEQ->EF2_CONTRA+IIF(lTemChave,WorkEEQ->EF2_BAN_FI+WorkEEQ->EF3_PRACA+IIF(lEFFTpMod,WorkEEQ->EF3_SEQCNT,""), "")))
               If IIF(lEFFTpMod,EF1->EF1_CAMTRA=="1",lPrepag .And. EF1->EF1_TP_FIN $ PRE_PAGTO+"/"+SECURITIZACAO)
                  If EF3->( DBSeek(xFilial("EF3")+IIF(lEFFTpMod,IIF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+WorkEEQ->EF2_CONTRA+IIF(lTemChave,WorkEEQ->EF2_BAN_FI+WorkEEQ->EF3_PRACA+IIF(lEFFTpMod,WorkEEQ->EF3_SEQCNT,""), "")+IIF(WorkEEQ->TIPOVINC=="1",EV_PRINC_PREPAG,Left(EV_JUROS_PREPAG,2))))
                     nSaldoAVin := 0
                     Do While !EF3->( EoF() )  .And.  ;
                              EF3->(EF3_FILIAL+IIF(lEFFTpMod,EF3_TPMODU,"")+IIF(lTemChave,EF3_BAN_FI+EF3_PRACA,"")+IIF(lEFFTpMod,EF3_SEQCNT,"")) == ;
                              EF1->(EF1_FILIAL+IIF(lEFFTpMod,EF1_TPMODU,"")+IIF(lTemChave,EF1_BAN_FI+EF1_PRACA,"")+IIF(lEFFTpMod,EF1_SEQCNT,"")) ;
                              .And.  IIF(WorkEEQ->TIPOVINC=="1",EF3->EF3_CODEVE==EV_PRINC_PREPAG,Left(EF3->EF3_CODEVE,2)==Left(EV_JUROS_PREPAG,2))
                        If EF3->EF3_TX_MOE == 0
                           If EF1->EF1_MOEDA != WorkEEQ->EEC_MOEDA
                              //nSaldoAVin += ( EF3->EF3_SLDVIN * BuscaTaxa(EF1->EF1_MOEDA,WorkEEQ->DT_VINC,,.F.,.T.,,cTX_100) ) / WorkEEQ->TX_VINC
                              nSaldoAVin += ( EF3->EF3_SLDVIN * WorkEEQ->TX_ME_FIN ) / WorkEEQ->TX_VINC   //PLB 30/10/06
                           Else
                              nSaldoAVin += EF3->EF3_SLDVIN
                           EndIf
                        EndIf
                        EF3->( DBSkip() )
                     EndDo

                     //** AAF 19/02/08 - Abate o valor das parcelas já vinculadas.
                     For nI:= 1 To Len(aArrayEEQ)
                        If aArrayEEQ[nI,5]+aArrayEEQ[nI,14]+aArrayEEQ[nI,15]+If(lEFFTpMod,aArrayEEQ[nI,21],"") == EF1->(EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+If(lEFFTpMod,EF1_SEQCNT,""))

                           nJaVinculado := 0
                           EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,'E',"")+EF1->(EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+If(lEFFTpMod,EF1_SEQCNT,"")+"600"+aArrayEEQ[nI,3]+TMP->EEQ_NRINVO)))
                           Do While EF3->( !EoF() .AND. EF3_FILIAL+If(lEFFTpMod,EF3_TPMODU,"")+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+If(lEFFTpMod,EF3_SEQCNT,"")+EF3_CODEVE+EF3_PARC+EF3_INVOIC ==;
                                                        xFilial("EF3")+EF1->(If(lEFFTpMod,EF1_TPMODU,"")+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+If(lEFFTpMod,EF1_SEQCNT,"")+"600"+aArrayEEQ[nI,3]+TMP->EEQ_NRINVO))
                              nJaVinculado += EF3->EF3_VL_MOE

                              EF3->(dbSkip())
                           EndDo

                           nSaldoAVin -= ( aArrayEEQ[ni,1]-nJaVinculado)
                        EndIf
                     Next
                     //**

                     If WorkEEQ->EEQ_VL > nSaldoAVin
                        MsgInfo(STR0006+WorkEEQ->EEC_MOEDA+" "+Trans(nSaldoAVin,AVSX3("EF1_SLD_PM",6))) //"Valor a vincular não pode ser maior que saldo do contrato. "
                        lRet := .F.
                     ElseIf EXPosPrePag("EF3",EF1->EF1_CONTRA,IIF(lTemChave,EF1->EF1_BAN_FI,""),IIF(lTemChave,EF1->EF1_PRACA,""),.T.,WorkEEQ->TIPOVINC,IIF(lEFFTpMod,EF1->EF1_TPMODU,""),IIF(lEFFTpMod,EF1->EF1_SEQCNT,"") ) > 0 ;
                           .And. WorkEEQ->DT_VINC > EF3->EF3_DT_EVE
                        MsgInfo(STR0094+DToC(EF3->EF3_DT_EVE))  //"A Data de Vinculação não pode ser maior do que a data da primeira parcela em aberto: " ###
                        lRet := .F.
                     EndIf
	              EndIf
	           EndIf
	        EndIf
	     EndIf
      EndIf

      If cOpcao <> "ESTORNAR" //ER - 19/09/2008
         //RMD - 05/05/08
         If lRet
            WorkEEQ->(DbGoTop())
            nRecWorkEEQ := WorkEEQ->(Recno())
            While WorkEEQ->(!Eof())
               For nInc := 1 To WorkEEQ->(FCount())
                  M->&(WorkEEQ->(FIELDNAME(nInc))) := WorkEEQ->(FieldGet(nInc))
               Next
               If !(lRet := ValFina("EEQ_VL", .T.))
                  Exit
               EndIf
               WorkEEQ->(DbSkip())
            EndDo
            WorkEEQ->(DbGoTo(nRecWorkEEQ))
         EndIf
      EndIf
EndCase

If(EasyEntryPoint("EECAF200"),ExecBlock("EECAF200",.F.,.F.,"VALFINANC"),)

Return lRet

*-------------------------------------*
Function FAF2ValParc(nTipo,cTipo,nPos)
*-------------------------------------*
Local nOrdAux, nRecAux, nRecEF1, nOrdTMP
//** GFC - 22/08/05
Local nVlVolta := 0, cParcAux:=""
//**

If nTipo == 3
   EEQ->(RecLock("EEQ",.F.))
   If EF3->EF3_VL_INV < EEQ->EEQ_VL
      If EEQ->EEQ_FI_TOT == "N"
         EEQ->EEQ_VL_PAR -= EF3->EF3_VL_INV
      Else
         EEQ->EEQ_VL_PAR := EEQ->EEQ_VL - EF3->EF3_VL_INV
         EEQ->EEQ_FI_TOT := "N"
      EndIf
   Else
      EEQ->EEQ_FI_TOT := "S"
   EndIf
   EEQ->(msUnlock())
Else
   If cTipo == "EXCLUIR"
      nOrdTMP:=TMP->(IndexOrd())
      TMP->(dbSetOrder(1))

      //** GFC - 22/08/05
      //If TMP->(dbSeek(aExcVinculo[nPos,1]))
      //   cParcAux := If(lParFin .and. !Empty(TMP->EEQ_PARFIN),TMP->EEQ_PARFIN,TMP->EEQ_PARC)
      //Else
      //   cParcAux := aExcVinculo[nPos,1]
      //EndIf
      //If TMP->(dbSeek(cParcAux))

      // PLB 23/08/07 - Quando EEQ_PARFIN for diferente do EEQ_PARC
      If TMP->(dbSeek(aExcVinculo[nPos,1]))
         cParcAux := If(lParFin .and. !Empty(TMP->EEQ_PARFIN),TMP->EEQ_PARFIN,TMP->EEQ_PARC)
         Do While !TMP->(EOF())
            If If(lParFin .and. !Empty(TMP->EEQ_PARFIN),TMP->EEQ_PARFIN,TMP->EEQ_PARC)==cParcAux
               nRecAux := TMP->(RecNo())
            EndIf
            TMP->(dbSkip())
         EndDo
         TMP->(dbGoTo(nRecAux))
         nVlVolta:=EF3->EF3_VL_INV
         Do While !TMP->(BOF()) .and. nVlVolta > 0
            If If(lParFin .and. !Empty(TMP->EEQ_PARFIN),TMP->EEQ_PARFIN,TMP->EEQ_PARC)==cParcAux
               If TMP->EEQ_FI_TOT == "N"
                  If TMP->EEQ_VL - (TMP->EEQ_VL_PAR + nVlVolta) <= 0
                     nVlVolta += TMP->EEQ_VL_PAR
                     TMP->EEQ_VL_PAR := TMP->EEQ_VL  //+=
                     nVlVolta -= TMP->EEQ_VL
                  Else
                     TMP->EEQ_VL_PAR += nVlVolta
                     nVlVolta := 0
                  EndIf
                  If TMP->EEQ_VL == TMP->EEQ_VL_PAR
                     TMP->EEQ_FI_TOT := ""
                     TMP->EEQ_VL_PAR := 0
                     TMP->EEQ_PARFIN := ""
                  EndIf
               ElseIf TMP->EEQ_FI_TOT == "S"
                  If (nVlVolta - (TMP->EEQ_VL-If(EECFlags("FRESEGCOM"),TMP->EEQ_CGRAFI-TMP->EEQ_ADEDUZ,0))) < 0
                     TMP->EEQ_FI_TOT := "N"
                     TMP->EEQ_VL_PAR := nVlVolta
                     nVlVolta := 0
                  Else
                     TMP->EEQ_FI_TOT := ""
                     TMP->EEQ_VL_PAR := 0
                     TMP->EEQ_PARFIN := ""
                     nVlVolta -= TMP->EEQ_VL
                  EndIf
               EndIf

               //** GFC
               If lTemChave //.and. Alltrim(TMP->EEQ_NROP) == Alltrim(EF1->EF1_CONTRA)
                  nRecAux := EF3->(RecNo())
                  nOrdAux := EF3->(IndexOrd())
                  EF3->(dbSetOrder(3))
                  If EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,IF(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),"")+TMP->EEQ_NRINVO+If(!lParFin .Or. Empty(TMP->EEQ_PARFIN),TMP->EEQ_PARC,TMP->EEQ_PARFIN)+EV_EMBARQUE)) //HVR SEEK I OU E
                     Do While !EF3->(EOF()) .and. EF3->EF3_FILIAL==xFilial("EF3") .AND. If(lEFFTpMod,EF3->EF3_TPMODU == IF(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),.T.) .and. EF3->EF3_INVOIC==TMP->EEQ_NRINVO .and.; //HVR WHILE I OU E
                     EF3->EF3_PARC==If(!lParFin .Or. Empty(TMP->EEQ_PARFIN),TMP->EEQ_PARC,TMP->EEQ_PARFIN) .and. EF3->EF3_CODEVE==EV_EMBARQUE
                        If EF3->(RecNo()) <> nRecAux
                           Exit
                        EndIf
                        EF3->(dbSkip())
                     EndDo
                     If !EF3->(EOF()) .and. EF3->EF3_FILIAL==xFilial("EF3") .and. If(lEFFTpMod,EF3->EF3_TPMODU == IF(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),.T.) .AND. EF3->EF3_INVOIC==TMP->EEQ_NRINVO .and.; //HVR WHILE I OU E
                     EF3->EF3_PARC==If(!lParFin .Or. Empty(TMP->EEQ_PARFIN),TMP->EEQ_PARC,TMP->EEQ_PARFIN) .and. EF3->EF3_CODEVE==EV_EMBARQUE
                        nRecEF1 := EF1->(RecNo())
                        EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3->EF3_CONTRA+If(lTemChave,EF3->EF3_BAN_FI+EF3->EF3_PRACA+If(lEFFTpMod,EF3->EF3_SEQCNT,""),""))) //HVR SEEK I OU E
                        //Alcir Alves - 03-11-05 - considerar o banco de movimentação nas vinculações  - conforme chamado 020324
                        IF !EMPTY(EF1->EF1_BAN_MO)
                           TMP->EEQ_BANC   := EF1->EF1_BAN_MO
                           TMP->EEQ_AGEN   := EF1->EF1_AGENMO
                           TMP->EEQ_NCON   := EF1->EF1_NCONMO
                           If SA6->(DBSeek(xFilial("SA6")+EF1->EF1_BAN_MO))
                              TMP->EEQ_NOMEBC := SA6->A6_NOME
                           Else
                              TMP->EEQ_NOMEBC := EF1->EF1_DES_MO
                           EndIf
                        //
                        ELSE
                           TMP->EEQ_BANC   := EF1->EF1_BAN_FI
                           TMP->EEQ_AGEN   := EF1->EF1_AGENFI
                           TMP->EEQ_NCON   := EF1->EF1_NCONFI
                           If SA6->(DBSeek(xFilial("SA6")+EF1->EF1_BAN_FI))
                              TMP->EEQ_NOMEBC := SA6->A6_NOME
                           Else
                              TMP->EEQ_NOMEBC := EF1->EF1_DES_FI
                           EndIf
                        ENDIF

                        TMP->EEQ_NROP   := EF1->EF1_CONTRA
                        EF1->(dbGoTo(nRecEF1))
                     Else
                        TMP->EEQ_BANC   := ""
                        TMP->EEQ_AGEN   := ""
                        TMP->EEQ_NCON   := ""
                        TMP->EEQ_NOMEBC := ""
                        TMP->EEQ_NROP   := ""
                     EndIf
                  Else
                     TMP->EEQ_BANC   := ""
                     TMP->EEQ_AGEN   := ""
                     TMP->EEQ_NCON   := ""
                     TMP->EEQ_NOMEBC := ""
                     TMP->EEQ_NROP   := ""
                  EndIf

                  // Atualiza EEQ
                  IF TMP->TMP_RECNO <> 0
                     EEQ->(dbGoTo(TMP->TMP_RECNO))
                     EEQ->(RECLOCK("EEQ",.F.))
                     EEQ->EEQ_FI_TOT := TMP->EEQ_FI_TOT
                     EEQ->EEQ_VL_PAR := TMP->EEQ_VL_PAR
                     //** GFC
                     EEQ->EEQ_BANC   := TMP->EEQ_BANC
                     EEQ->EEQ_AGEN   := TMP->EEQ_AGEN
                     EEQ->EEQ_NCON   := TMP->EEQ_NCON
                     EEQ->EEQ_NOMEBC := TMP->EEQ_NOMEBC
                     EEQ->EEQ_NROP   := TMP->EEQ_NROP
                     EEQ->EEQ_PARFIN := If(lParFin .and. !Empty(TMP->EEQ_PARFIN),TMP->EEQ_PARFIN,TMP->EEQ_PARC)
                     //**
                     EEQ->(msUnlock())
                  Endif

                  EF3->(dbSetOrder(nOrdAux))
                  EF3->(dbGoTo(nRecAux))
               EndIf
               //**

            EndIf
            TMP->(dbSkip(-1))
         EndDo
         //**

      //If TMP->(dbSeek(aExcVinculo[nPos,1]))
      //   TMP->(RecLock("TMP",.F.))
      //   If TMP->EEQ_FI_TOT == "N"
      //      TMP->EEQ_VL_PAR += EF3->EF3_VL_INV
      //      If TMP->EEQ_VL == TMP->EEQ_VL_PAR
      //         TMP->EEQ_FI_TOT := ""
      //         TMP->EEQ_VL_PAR := 0
      //      EndIf
      //   Else
      //      TMP->EEQ_FI_TOT := ""
      //   EndIf

         TMP->(msUnlock())
      EndIf
      TMP->(dbSetOrder(nOrdTMP))
   Else
      EEQ->(RecLock("EEQ",.F.))
      If EEQ->EEQ_FI_TOT == "N"
         EEQ->EEQ_VL_PAR += EF3->EF3_VL_INV
         If EEQ->EEQ_VL == EEQ->EEQ_VL_PAR
            EEQ->EEQ_FI_TOT := ""
            EEQ->EEQ_VL_PAR := 0
         EndIf
      Else
         EEQ->EEQ_FI_TOT := ""
      EndIf
      EEQ->(msUnlock())
   EndIf
EndIf

Return .T.

*---------------------------*
Function GrvArrayFAF2()
*---------------------------*
Local nValTot := 0, nPos := 0, lAddArray := .T., nVlControle:=0, ni
Private lCpoAcrDcr := If( Type('lCpoAcrDcr')=="L" , lCpoAcrDcr , AVFLAGS("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP") )              //NCF - 14/08/2015 - Tratamento Acresc./Decres. no controle de cambio Exportação
If TMP->EEQ_EVENT <> '101' .AND. TMP->EEQ_EVENT <> '603' //AAF 02/03/09 - Permitir vinculação de adiantamento pos-embarque.
   Return .F.
Endif

If EEC->EEC_PREEMB <> TMP->EEQ_PREEMB
   EEC->(dbSeek(xFilial("EEC")+TMP->EEQ_PREEMB))
EndIf
cFilEF3:= xFilial("EF3")
nVlControle:=0
If EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,IF(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),"")+TMP->EEQ_NRINVO+If(!lParFin .Or. Empty(TMP->EEQ_PARFIN),TMP->EEQ_PARC,TMP->EEQ_PARFIN)+EV_EMBARQUE)) //HVR SEEK I OU E
   Do While !EF3->(EOF()) .and. xFilial("EF3")==EF3->EF3_FILIAL .AND. If(lEFFTpMod,EF3->EF3_TPMODU == IF(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),.T.) .and. EF3->EF3_INVOIC==TMP->EEQ_NRINVO .and.;    //HVR WHILE I OU E
   EF3->EF3_PARC==If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN) .and.;
   EF3->EF3_CODEVE == EV_EMBARQUE .and. nValTot < TMP->EEQ_VLFCAM

      If (nPos:=aScan(aArrayEEQ,{|x| x[16]==EF3->(RecNo())})) > 0
         For ni:=nPos to Len(aArrayEEQ)
            nVlControle += aArrayEEQ[ni,1]
         Next ni
      EndIf

      If nVlControle < EF3->EF3_VL_INV
         aAdd(aArrayEEQ,{(If(TMP->EEQ_VLFCAM > (EF3->EF3_VL_INV-nVlControle), (EF3->EF3_VL_INV-nVlControle),TMP->EEQ_VLFCAM)),TMP->EEQ_VCT,TMP->EEQ_PARC,EF3->EF3_DT_FIX,EF3->EF3_CONTRA,;
                         EF3->EF3_SEQ,If(!Empty(EF3->EF3_NR_CON) , "1" , "2" ),nSeqArray,TMP->EEQ_PREEMB, EF3->EF3_DT_EVE, EF3->EF3_TX_CON, "", If(lParFin .and. !Empty(TMP->EEQ_PARFIN),TMP->EEQ_PARFIN,TMP->EEQ_PARC),;
                         If(lTemChave, EF3->EF3_BAN_FI,""), Iif(lTemChave, EF3->EF3_PRACA, ""),EF3->(RecNo()),If(TMP->EEQ_VLFCAM > (EF3->EF3_VL_INV-nVlControle), (EF3->EF3_VL_INV-nVlControle), TMP->EEQ_VLFCAM),;
                         .F.,If(!lPrePag .or. Left(EF3->EF3_EV_VIN,2)==Left(EV_PRINC_PREPAG,2), "1", "2"),TMP->(RecNo()),If(lEFFTpMod,EF3->EF3_SEQCNT,),EF3->EF3_TX_MOE,;  // AAF 22/02/06 - Adicionado o campo sequencia do contrato.   // PLB 08/06/06 - EF3_TX_MOE alterado para EF3_TX_CON, que e a taxa de vinculacao
                         Posicione("EF1",1,xFilial("EF1")+IIF(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3->EF3_CONTRA+IIF(lTemChave,EF3->(EF3_BAN_FI+EF3->EF3_PRACA),"")+IIF(lEFFTpMod,EF3->EF3_SEQCNT,""),"EF1_MOEDA"),/*FSY - 18/04/2013*/If(EF3->(FIeldPos("EF3_DTDOC"))>0,EF3->EF3_DTDOC,)})
         nSeqArray += 1
         nValTot += If(TMP->EEQ_VLFCAM > (EF3->EF3_VL_INV-nVlControle), (EF3->EF3_VL_INV-nVlControle), TMP->EEQ_VLFCAM) //EF3->EF3_VL_INV
         If (nPoS:=aScan(aParcVinc,{|x| x[1]== EF3->EF3_INVOIC .And. x[2]== EF3->EF3_PARC  })) = 0
            Aadd(aParcVinc, {EF3->EF3_INVOIC, EF3->EF3_PARC, TMP->EEQ_VLFCAM, EF3->EF3_VL_INV} )
         Endif
      EndIf
      nVlControle := 0
      EF3->(dbSkip())
   EndDo
   If nValTot < TMP->EEQ_VLFCAM .and. (TMP->EEQ_VL_PAR > 0 .or. Empty(TMP->EEQ_FI_TOT))
      aAdd(aArrayEEQ,{TMP->EEQ_VLFCAM - nValTot,TMP->EEQ_VCT,TMP->EEQ_PARC,,Space(Len(EF1->EF1_CONTRA)),;
                      Space(Len(EF3->EF3_SEQ)),,nSeqArray, TMP->EEQ_PREEMB,/*FSY - 18/04/2013*/if(EF3->(FieldPos("EF3_DTDOC"))>0.AND.!Empty(TMP->EEQ_DTCE).AND.TMP->EEQ_DTCE<dDataBase,TMP->EEQ_DTCE,dDataBase),;
                      BuscaTaxa(EEC->EEC_MOEDA,dDataBase,,.F.,.T.,,cTX_100), "SALDO", If(lParFin .and. !Empty(TMP->EEQ_PARFIN),TMP->EEQ_PARFIN,TMP->EEQ_PARC),;
                      Space(Len(EEQ->EEQ_BANC)), Iif(lTemChave, Space(Len(EF3->EF3_PRACA)), ""),,TMP->EEQ_VLFCAM - nValTot,.F.,"1",;
                      TMP->(RecNo()), If(lEFFTpMod,Space(Len(EF3->EF3_SEQCNT)),""),BuscaTaxa(EEC->EEC_MOEDA,dDataBase,,.F.,.T.,,cTX_100),"",/*FSY - 18/04/2013*/If(EF3->(FIeldPos("EF3_DTDOC"))>0,dDataBase,)}) //AAF 22/02/06 - Adicionado o campo sequencia do contrato.
      nSeqArray += 1
   EndIf
Else
   If lParFin
      If (nPoS:=aScan(aParcVinc,{|x| x[1]== TMP->EEQ_NRINVO .And. x[2]== If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN)})) > 0  // TMP->EEQ_PARFIN  VI 18/07/03
         aParcVinc[nPos,3] += TMP->EEQ_VLFCAM   // Saldo Vinculado
         If aParcVinc[nPos,3] <= aParcVinc[nPos,4]
//          EF3->(dbSeek(cFilEF3+TMP->EEQ_NRINVO+TMP->EEQ_PARVIN)) VICTOR
            EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,IF(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),"")+TMP->EEQ_NRINVO+If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN)))
            aAdd(aArrayEEQ,{TMP->EEQ_VLFCAM,TMP->EEQ_VCT,TMP->EEQ_PARC,EF3->EF3_DT_FIX,EF3->EF3_CONTRA,;
                            EF3->EF3_SEQ, If(!Empty(EF3->EF3_NR_CON) , "1" , "2" ), nSeqArray,;
                            TMP->EEQ_PREEMB, EF3->EF3_DT_EVE, EF3->EF3_TX_CON, "SALDO", If(lParFin .and. !Empty(TMP->EEQ_PARFIN),TMP->EEQ_PARFIN,TMP->EEQ_PARC),;
                            EF3->EF3_BANC, Iif(lTemChave, EF3->EF3_PRACA,""),EF3->(RecNo()),TMP->EEQ_VLFCAM,;
                            .F.,If(!lPrePag .or. Left(EF3->EF3_EV_VIN,2)==Left(EV_PRINC_PREPAG,2), "1", "2"),TMP->(RecNo()),If(lEFFTpMod,EF3->EF3_SEQCNT,""),EF3->EF3_TX_MOE,;    // PLB 08/06/06 - EF3_TX_MOE alterado para EF3_TX_CON, que e a taxa de vinculacao
                            Posicione("EF1",1,xFilial("EF1")+IIF(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3->EF3_CONTRA+IIF(lTemChave,EF3->(EF3_BAN_FI+EF3->EF3_PRACA),"")+IIF(lEFFTpMod,EF3->EF3_SEQCNT,""),"EF1_MOEDA"),If(EF3->(FIeldPos("EF3_DTDOC"))>0,EF3->EF3_DTDOC,)}) //FSY - Incusao do campo data entrega documento.
            nSeqArray += 1
            lAddArray := .F.
         Endif
      Endif
   Endif
   If lAddArray
   //FSY 19/062013 - Inclusão do campo credito exterior da tabela EEQ
      aAdd(aArrayEEQ,{TMP->EEQ_VLFCAM,TMP->EEQ_VCT,TMP->EEQ_PARC,,Space(Len(EF1->EF1_CONTRA)),;
                      Space(Len(EF3->EF3_SEQ)),,nSeqArray,TMP->EEQ_PREEMB, if(EF3->(FieldPos("EF3_DTDOC"))>0.AND.!Empty(TMP->EEQ_DTCE).AND.TMP->EEQ_DTCE<dDataBase,TMP->EEQ_DTCE,dDataBase),;
                      BuscaTaxa(EEC->EEC_MOEDA,dDataBase,,.F.,.T.,,cTX_100), "", If(lParFin .and. !Empty(TMP->EEQ_PARFIN),TMP->EEQ_PARFIN,TMP->EEQ_PARC),;
                      Space(Len(EF1->EF1_BAN_FI)), Iif(lTemChave, Space(Len(EF3->EF3_PRACA)), ""),,TMP->EEQ_VLFCAM,.F.,"1",;
                      TMP->(RecNo()),If(lEFFTpMod,Space(Len(EF3->EF3_SEQCNT)),""),BuscaTaxa(EEC->EEC_MOEDA,dDataBase,,.F.,.T.,,cTX_100),"",If(EF3->(FIeldPos("EF3_DTDOC"))>0,dDataBase,)}) //AAF 22/02/06 - Adicionado o campo sequencia do contrato.

      nSeqArray += 1
   Endif
EndIf

Return .T.

*------------------------------------------------------*
Function GeraLiq(cTipo,nTxLiq,lGetProv,nValEst)
*------------------------------------------------------*
Local nOrd, cSeq, nSldInv, nTxAux:=0, cCpoDt:=EasyGParam("MV_CPODTJR",,"EEQ_DTCE")
Local ni:=1
Local lExecLiq

//nTxAux := TMP->EEQ_EQVL / TMP->EEQ_VL //FSM - 04/09/2012
nTxAux := nTxLiq

GrvWkEEQ("LIQ",cTipo,lGetProv)
WorkEEQ->(dbGoTop())
If cTipo == "INCLUIR"
   Do While !WorkEEQ->(EOF())
      If !Empty(WorkEEQ->EF2_CONTRA)
         // Verifica o Saldo da Parcela Principal

         nSldInv := FAF2ApuSld(WorkEEQ->EF2_CONTRA, WorkEEQ->EEQ_NRINVO,;
                                WorkEEQ->EEQ_PARC, If(lParFin .and. !Empty(WorkEEQ->EEQ_PARFIN),WorkEEQ->EEQ_PARFIN,WorkEEQ->EEQ_PARC),If(lTemChave,WORKEEQ->EF2_BAN_FI,),If(lTemChave,WORKEEQ->EF3_PRACA,),If(lEFFTpMod,WorkEEQ->EF3_SEQCNT,))

         EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,IF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+WorkEEQ->EF2_CONTRA+iif(lTemChave, WorkEEQ->EF2_BAN_FI+WorkEEQ->EF3_PRACA+If(lEFFTpMod,WorkEEQ->EF3_SEQCNT,""),""))) //HVR SEEK I OU E
         If If(WorkEEQ->EEQ_VL >= nSldInv, nSldInv, WorkEEQ->EEQ_VL) > 0
            cMod := IIF(lEFFTpMod,EF1->EF1_TPMODU,EXP) //HVR 26/04/06 - NECESSÁRIO PARA EX400
            If lEFFTpMod
               M->EF1_TPMODU := EF1->EF1_TPMODU //HVR 26/04/06 - DECLARADO DEVIDO A UTILIZAÇÃO NO EX400
            EndIf

            lExecLiq:= .F.
            If !lGetProv
               EX400Liquida(EF1->EF1_CONTRA,WorkEEQ->EEQ_NRINVO,;
                           If(lParFin .And. !Empty(WorkEEQ->EEQ_PARFIN), WorkEEQ->EEQ_PARFIN, WorkEEQ->EEQ_PARC),M->EEC_PREEMB,;
                           If(WorkEEQ->EEQ_VL >= nSldInv, nSldInv, WorkEEQ->EEQ_VL) ,;
                           M->EEC_MOEDA,EF1->EF1_MOEDA,"EF1","EF3","CAMB",nTxLiq,WorkEEQ->&(cCpoDt),If(!Empty(WorkEEQ->EEQ_DTNEGO),WorkEEQ->EEQ_DTNEGO,WorkEEQ->EEQ_PGT),WorkEEQ->EEQ_PGT,If(lMulTiFil,xFilial("EEQ"),Nil),;
                           ,,,,If(lTemChave,WorkEEQ->EF2_BAN_FI,),/*If(lTemChave,TMP->EEQ_AGEN,)*/EF1->EF1_AGENFI,/*If(lTemChave,TMP->EEQ_NCON,)*/EF1->EF1_NCONFI,If(lTemChave,WORKEEQ->EF3_PRACA,),,;    //GFC - 13/01/05 // FSM - 01/03/2012
                           If(WorkEEQ->EEQ_VL >= nSldInv, nSldInv, WorkEEQ->EEQ_VL) * nTxAux,,WorkEEQ->EEQ_NROP,WorkEEQ->EF3_REC,If(lEFFTpMod,IF(WorkEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),),If(lEFFTpMod,WorkEEQ->EF3_SEQCNT,),"EEQ",;    //GFC - 13/01/05 //HVR EX400LIQUIDA I OU E
                           ,;  // cForn
                           ,;  // cLojaFo
                           ,;  // cPo_Di
                           ,;  // nVlMoeLiq
                           ,;  // lEvRefi
                           @lExecLiq) //lExecLiq
            Else
               EX400Liquida(EF1->EF1_CONTRA,WorkEEQ->EEQ_NRINVO,;
                           If(lParFin .And. !Empty(WorkEEQ->EEQ_PARFIN), WorkEEQ->EEQ_PARFIN, WorkEEQ->EEQ_PARC),;
                           M->EEC_PREEMB,If(WorkEEQ->EEQ_VL >= nSldInv, nSldInv, WorkEEQ->EEQ_VL) ,;
                           M->EEC_MOEDA,EF1->EF1_MOEDA,"EF1","EF3","CAMB",nTxLiq,WorkEEQ->&(cCpoDt),If(!Empty(WorkEEQ->EEQ_DTNEGO),WorkEEQ->EEQ_DTNEGO,WorkEEQ->EEQ_PGT),WorkEEQ->EEQ_PGT,If(lMulTiFil,xFilial("EEQ"),Nil),;
                           aGetProv[ni,4],aGetProv[ni,6],aGetProv[ni,5],aGetProv[ni,7],If(lTemChave,WorkEEQ->EF2_BAN_FI,),/*If(lTemChave,TMP->EEQ_AGEN,)*/EF1->EF1_AGENFI,/*If(lTemChave,TMP->EEQ_NCON,)*/EF1->EF1_NCONFI,If(lTemChave,WORKEEQ->EF3_PRACA,),,;    //GFC - 13/01/05 //FSM - 01/03/2012
                           If(WorkEEQ->EEQ_VL >= nSldInv, nSldInv, WorkEEQ->EEQ_VL) * nTxAux,,WorkEEQ->EEQ_NROP,WorkEEQ->EF3_REC,If(lEFFTpMod,IF(WorkEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),),If(lEFFTpMod,WorkEEQ->EF3_SEQCNT,),"EEQ",;    //GFC - 13/01/05 //HVR EX400LIQUIDA I OU E
                           ,;  // cForn
                           ,;  // cLojaFo
                           ,;  // cPo_Di
                           ,;  // nVlMoeLiq
                           ,;  // lEveRefi
                           @lExecLiq) //lExecLiq
               ni++
            EndIf         // Moe. Old        Moe Atu        Rea Old        Rea Atu


            /* WFS set-16 - Chamada da tela de liquidação do evento.
               Objetivos: possibilitar ao usuário informar os dados para liquidação do evento e executar a tela fora da transação.
               A flag lExecLiq será alterada para verdadeiro quando o evento principal for liquidado totalmente. */
            If lExecLiq
               EF3->(DBSetOrder(1))
               If EF3->(DBSeek(cFilEF3 + IIf(lEFFTpMod, IIf(WorkEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"") + WorkEEQ->EF2_CONTRA + IIf(lTemChave, WorkEEQ->EF2_BAN_FI + WorkEEQ->EF3_PRACA + IIf(lEFFTpMod, WorkEEQ->EF3_SEQCNT, ""), "") + EF3->EF3_EV_VIN + EF3->EF3_PARVIN))
                  lLiqAutoFinancing:= .T.
                  AAdd(aLiqAuto, EF3->(RecNo()))
               EndIf

            EndIf

         EndIf
      EndIf
      WorkEEQ->(dbSkip())
   Enddo
Else
   nOrd := EF3->(IndexOrd())
   Do While !WorkEEQ->(EOF())
      If !Empty(WorkEEQ->EF2_CONTRA)
         EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,IF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+WorkEEQ->EF2_CONTRA+iif(lTemChave, WorkEEQ->EF2_BAN_FI+WorkEEQ->EF3_PRACA+If(lEFFTpMod,WorkEEQ->EF3_SEQCNT,""),""))) //HVR SEEK I OU E
         EF3->(dbSetOrder(1))
         cFilEF3 := xFilial("EF3")
         If EF3->(dbSeek(cFilEF3+If(lEFFTpMod,IF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+WorkEEQ->EF2_CONTRA+iif(lTemChave, WorkEEQ->EF2_BAN_FI+WorkEEQ->EF3_PRACA+If(lEFFTpMod,WorkEEQ->EF3_SEQCNT,""),"")+EV_LIQ_PRC)) .or.; //HVR SEEK I OU E
         (lPrePag .and. ( IF(lEFFTpMod, EF1->EF1_CAMTRA == "1", EF1->EF1_TP_FIN $ ("03/04")) ) .and. EF3->(dbSeek(cFilEF3+If(lEFFTpMod,IF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+WorkEEQ->EF2_CONTRA+iif(lTemChave, WorkEEQ->EF2_BAN_FI+WorkEEQ->EF3_PRACA+If(lEFFTpMod,WorkEEQ->EF3_SEQCNT,""),"")+Left(EV_LIQ_JUR,2))))// .or.; //HVR 25/04/06 - DE: EF1->EF1_TP_FIN $ ("03/04") PARA:IF(EF1->EF1_CAMTRA == "1",.T.,IF EF1->EF1_TP_FIN $ ("03/04")) VERIFICAR SE CONTRATO POSSUI PARCELAS DE PAGAMENTO //HVR SEEK I OU E
//         EF3->(dbSeek(cFilEF3+WorkEEQ->EF2_CONTRA+iif(lTemChave, WorkEEQ->EF2_BAN_FI+WorkEEQ->EF3_PRACA,"")+EV_LIQ_PRC_FC))
            cSeq := ""
            Do While EF3->(!Eof()) .And. EF3->EF3_FILIAL == cFilEF3 .AND. If(lEFFTpMod,EF3->EF3_SEQCNT == WorkEEQ->EF3_SEQCNT,.T.) .And. WorkEEQ->EF2_CONTRA == EF3->EF3_CONTRA ;
            .And. (EF3->EF3_CODEVE==EV_LIQ_PRC .or. (lPrePag .and. IF(lEFFTpMod,EF1->EF1_CAMTRA == "1",EF1->EF1_TP_FIN $ ("03/04")) .and.;//HVR 25/04/06 - DE: EF1->EF1_TP_FIN $("02/03") PARA:IF(EF1->EF1_CAMTRA == "1",.T.,IF EF1->EF1_TP_FIN $ ("03/04")) VERIFICAR SE CONTRATO POSSUI PARCELAS DE PAGAMENTO //HVR 25/04/06 - correção 02/03 para 03/04
            Left(EF3->EF3_CODEVE,2)==Left(EV_LIQ_JUR,2))) .and.; // .or. EF3->EF3_CODEVE=EV_LIQ_PRC_FC)
            If(lTemChave,EF3->EF3_BAN_FI+EF3->EF3_PRACA+If(lEFFTpMod,EF3->EF3_SEQCNT,"")==WorkEEQ->EF2_BAN_FI+WorkEEQ->EF3_PRACA+If(lEFFTpMod,WorkEEQ->EF3_SEQCNT,""),.T.)
               If EF3->EF3_INVOIC == WorkEEQ->EEQ_NRINVO .and. If(lParFin .And. !Empty(WorkEEQ->EEQ_PARFIN), EF3->EF3_PARC==WorkEEQ->EEQ_PARFIN, EF3->EF3_PARC==WorkEEQ->EEQ_PARC) .and. If(EF3->EF3_CODEVE==EV_LIQ_PRC,EF3->EF3_VL_INV = nValEst,.T.) //WorkEEQ->EEQ_VL
                  cSeq := EF3->EF3_SEQ
               Endif
               EF3->(DbSkip())
            Enddo
            If !Empty(cSeq)
               FAF2EstLiq(WorkEEQ->EF2_CONTRA,cSeq,WorkEEQ->EF2_BAN_FI,iif(lTemChave,WorkEEQ->EF3_PRACA,""),.T.,If(lEFFTpMod,WorkEEQ->EF3_SEQCNT,""))
            Endif
         EndIf
      EndIf
      WorkEEQ->(dbSkip())
   EndDo
   EF3->(dbSetOrder(nOrd))
EndIf

Return .T.

*-----------------------------------------------------*
//AAF 22/02/06 - Adicionado o parametro cSeqCon - Sequência do Contrato.
Function FAF2EstLiq(cContra,cSeq,cBanc,cPraca,lMotivo,cSeqCon)
*-----------------------------------------------------*
Local nOrd := EF3->(IndexOrd()), nRec := EF3->(RecNo())
Local lBackEEQ := .F. //FSM - 24/02/2012
Local lLogix := FindFunction("EFFEX101") .And. Avflags("EEC_LOGIX")
//** AAF - 21/02/2006 - Nova estrutura das tabelas de financiamento - EF1_TPMODU e EF1_SEQCNT.
Private lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                     EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                     EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                     EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                     EF6->( FieldPos("EF6_SEQCNT") ) > 0

cFilEF1 := xFilial("EF1")
cFilEF3 := xFilial("EF3")

If IsInCallStack("AF200MAN") .And. AvFlags("SIGAEFF_SIGAFIN") //FSM - 24/02/2012
	lBackEEQ := .T.
	TMP->(DbCloseArea())
EndIf

If AvFlags("SIGAEFF_SIGAFIN") .OR. lLogix
   oEFFContrato := AvEFFContra():LoadEF1()
EndIf

EF3->(dbSetOrder(4))
EF1->(dbSeek(cFilEF1+If(lEFFTpMod,EF3->EF3_TPMODU,"")+cContra+iif(lTemChave,cBanc+cPraca+If(lEFFTpMod,cSeqCon,""),"")))       //HVR SEEK I OU E
EF3->(dbSeek(cFilEF3+If(lEFFTpMod,EF3->EF3_TPMODU,"")+cContra+iif(lTemChave,cBanc+cPraca+If(lEFFTpMod,cSeqCon,""),"")+cSeq))  //HVR SEEK I OU E
Do While !EF3->(EOF()) .and. EF3->EF3_FILIAL==xFilial("EF3") .AND. If(lEFFTpMod,EF3->EF3_SEQCNT == cSeqCon,.T.)  ;
         .And. EF3->EF3_CONTRA==cContra .and. EF3->EF3_SEQ==cSeq .and. If(lTemChave,EF3->EF3_BAN_FI+EF3->EF3_PRACA+If(lEFFTpMod,EF3->EF3_SEQCNT,"")==cBanc+cPraca+If(lEFFTpMod,cSeqCon,""),.T.);
         .And.  !( EF3->EF3_CODEVE == EV_ESTORNO )  // PLB 04/07/07
   cMod := IIF(lEFFTpMod,EF1->EF1_TPMODU,EXP) //HVR 26/04/06 - NECESSÁRIO PARA EX400

   EX400AtuSaldos("LIQ",,,"EEC")
   If lMotivo .and. (EF3->EF3_CODEVE == EV_LIQ_PRC .Or. Left(EF3->EF3_CODEVE,2) == Left(EV_LIQ_JUR,2) ) //.or. EF3->EF3_CODEVE == EV_LIQ_PRC_FC)
      cMod := IIF(lEFFTpMod,EF1->EF1_TPMODU,EXP) //HVR 26/04/06 - NECESSÁRIO PARA EX400
      EX400MotHis("LIQ",EF1->EF1_CONTRA,If(lTemChave,EF1->EF1_BAN_FI,),If(lTemChave,EF1->EF1_PRACA,),EF1->EF1_TP_FIN,EF3->EF3_PREEMB,EF3->EF3_INVOIC,EF3->EF3_PARC,EF3->EF3_CODEVE,EF3->EF3_SEQ,"E",If(lEFFTpMod,EF1->EF1_SEQCNT,)) //AAF - 21/02/2006 - Adicionado o campo sequencia do contrato.
   EndIf

   If AvFlags("SIGAEFF_SIGAFIN") .OR. lLogix
      If lLogix .And. !Empty(EF3->EF3_SEQBX)          //NCF - 26/09/2014 - Permitir estorno de baixa automática dos eventos de juros
         oEFFContrato:EventoEF3("ESTORNO_LIQUIDACAO")
      EndIf
      oEFFContrato:EventoEF3("ESTORNO")
   EndIf

   EF3->(RecLock("EF3",.F.))
   If !Empty(EF3->EF3_NR_CON)
      //NCF - 29/08/2014
      If lLogix
         AF200BkPInt( "EF3" , "EEC_ESBX_ALT",,{'EEQ',EEQ->(Recno())},)
      EndIf

      EF3->EF3_EV_EST := EF3->EF3_CODEVE //EF3->(DBDELETE())
      EF3->EF3_DT_EST := dDataBase
      EF3->EF3_CODEVE := EV_ESTORNO
      EF3->EF3_NR_CON := Space(Len(EF3->EF3_NR_CON))
      EF3->(msUnlock())
      // PLB 04/07/07 - Ao alterar o código do evento o registro é desposicionado na tabela devido campo fazer parte da chave
      EF3->( DBSeek(cFilEF3+If(lEFFTpMod,EF3->EF3_TPMODU,"")+cContra+iif(lTemChave,cBanc+cPraca+If(lEFFTpMod,cSeqCon,""),"")+cSeq) )
   Else
      //NCF - 29/08/2014
      If lLogix
         AF200BkPInt( "EF3" , "EEC_ESBX_DEL",,{'EEQ',EEQ->(Recno())},)
      EndIf

      EF3->(dbDelete())
      EF3->(msUnlock())
      EF3->(dbSkip())
   EndIf
EndDo
EF3->(dbSetOrder(nOrd))
EF3->(dbGoTo(nRec))

If AvFlags("SIGAEFF_SIGAFIN") .OR. lLogix
   oEFFContrato:EventoFinanceiro("ATUALIZA_PROVISORIOS")
   oEFFContrato:ShowErrors()
EndIf

If lBackEEQ //FSM - 24/02/2012
	Af200AbTmp()
EndIf

Return .T.

*----------------------*
Function FAF2EstVinc()
*----------------------*

If (Type("lAF200Auto") == "L" .and. !lAF200Auto) .or. Type("lAF200Auto") <> "L"

   If Empty(WorkEEQ->EF2_CONTRA)
      MsgInfo(STR0041) //"Parcela sem vinculação."
   ElseIf EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,IF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+WorkEEQ->EF2_CONTRA+iif(lTemChave, WorkEEQ->EF2_BAN_FI+WorkEEQ->EF3_PRACA+If(lEFFTpMod,WorkEEQ->EF3_SEQCNT,""),""))) .and. !Empty(EF1->EF1_DT_ENC) //HVR SEEK I OU E
      MsgInfo(STR0025) //"Parcela não pode ser desvinculada pois o contrato já foi encerrado."
      Return .T.
   Else
      EF3->(dbSetOrder(1))
      If EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,IF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+WorkEEQ->EF2_CONTRA+If(lTemChave,WorkEEQ->EF2_BAN_FI+WorkEEQ->EF3_PRACA+If(lEFFTpMod,WorkEEQ->EF3_SEQCNT,""),"")+EV_LIQ_PRC_FC)) .or.; //HVR SEEK I OU E
      EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,IF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+WorkEEQ->EF2_CONTRA+If(lTemChave,WorkEEQ->EF2_BAN_FI+WorkEEQ->EF3_PRACA+If(lEFFTpMod,WorkEEQ->EF3_SEQCNT,""),"")+EV_LIQ_PRC)) //HVR SEEK I OU E
      Do While !EF3->(EOF()) .and. EF3->EF3_FILIAL==xFilial("EF3") .AND. If(lEFFTpMod,EF3->EF3_TPMODU == IF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),.T.) .and. EF3->EF3_CONTRA==WorkEEQ->EF2_CONTRA .and.; //HVR WHILE I OU E
         If(lTemChave, EF3->EF3_BAN_FI+EF3->EF3_PRACA+If(lEFFTpMod,EF3->EF3_SEQCNT,"")==WorkEEQ->EF2_BAN_FI+WorkEEQ->EF3_PRACA+If(lEFFTpMod,WorkEEQ->EF3_SEQCNT,""), .T.) .and.;
         (EF3->EF3_CODEVE==EV_LIQ_PRC_FC .or. EF3->EF3_CODEVE==EV_LIQ_PRC)
         If EF3->EF3_INVOIC == TMP->EEQ_NRINVO .and. EF3->EF3_PARC == If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN)
            Exit
         EndIf
         EF3->(dbSkip())
      EndDo
   EndIf
   If !EF3->(EOF()) .AND. TMP->EEQ_EVENT <> "603" .and.; //AAF 03/03/2009 - Permitir desvincular adiantamento pos-embarque.
   EF3->EF3_FILIAL==xFilial("EF3") .AND. IF(lEFFTpMod,EF3->EF3_TPMODU == IF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),.T.) .and. EF3->EF3_CONTRA==WorkEEQ->EF2_CONTRA .and.;   //HVR IF I OU E
      If(lTemChave, EF3->EF3_BAN_FI+EF3->EF3_PRACA+If(lEFFTpMod,EF3->EF3_SEQCNT,"")==WorkEEQ->EF2_BAN_FI+WorkEEQ->EF3_PRACA+If(lEFFTpMod,WorkEEQ->EF3_SEQCNT,""), .T.) .and.;
      (EF3->EF3_CODEVE==EV_LIQ_PRC_FC .or. EF3->EF3_CODEVE==EV_LIQ_PRC) .and.;
      EF3->EF3_INVOIC == TMP->EEQ_NRINVO .and. EF3->EF3_PARC == If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN)
         MsgInfo(STR0042) //"Parcela não pode ser desvinculada pois possui baixa no contrato."
         Return .T.
      EndIf
   EndIf
EndIf
/*
If Ascan(aExcVinculo,{|x| x[1]==WorkEEQ->EEQ_PARC .And. x[2]==WorkEEQ->EF2_CONTRA .And. x[3]=1}) = 0

  aAdd(aExcVinculo,{WorkEEQ->EEQ_PARC,WorkEEQ->EF2_CONTRA,1,0,WorkEEQ->SEQ})

  If (nPos := aScan(aArrayEEQ,{|x| x[3]==WorkEEQ->EEQ_PARC .And. x[5]==WorkEEQ->EF2_CONTRA})) > 0
     aAdd(aLogEEQ,{aArrayEEQ[nPos,1], aArrayEEQ[nPos,2], aArrayEEQ[nPos,3], aArrayEEQ[nPos,4], aArrayEEQ[nPos,5],;
                   aArrayEEQ[nPos,6], aArrayEEQ[nPos,7], aArrayEEQ[nPos,8], aArrayEEQ[nPos,9], aArrayEEQ[nPos,10],;
                   aArrayEEQ[nPos,11],aArrayEEQ[nPos,12],aArrayEEQ[nPos,13]})

     //aDel(aArrayEEQ,nPos)  // LGV
     aArrayEEQ[nPos,5]  := "" // LGV
     //aArrayEEQ[nPos,10] := AVCTOD("  /  /  ")

     //aSize(aArrayEEQ,LEN(aArrayEEQ)-1) // LGV

  EndIf
Endif

If lParFin .and. !Empty(TMP->EEQ_PARFIN)
   nRecAux  := TMP->(RecNo())
   cParcAux := TMP->EEQ_PARFIN
   TMP->(dbGoTop())
   Do While !TMP->(EOF())
      If TMP->EEQ_PARFIN == cParcAux
         TMP->EEQ_PARFIN := ""
      EndIf
      TMP->(dbSkip())
   EndDo
   TMP->(dbGoTo(nRecAux))
EndIf
*/

// LGV - 10/07/03 //////////////////////////////////////
WORKEEQ->(Reclock ("WORKEEQ",.F.))
WORKEEQ->EF2_Contra := ""
WORKEEQ->EF2_BAN_FI := ""
WorkEEQ->EF1DESFIN := ""
WORKEEQ->DT_Vinc    := Ctod("")
//FSY 19/06/2013
If EF3->(FieldPos("EF3_DTDOC")) >0
   WORKEEQ->EF3_DTDOC := Ctod("")
EndIf

// ACSJ - 06/02/2005
IF lTemChave
   WORKEEQ->EF3_PRACA  := ""
   WorkEEQ->EF5_DESCRI := ""
   If lEFFTpMod
      WorkEEQ->EF3_SEQCNT := ""
   EndIf
Endif

WORKEEQ->(MSUnlock ())
// LGV - 10/07/03 //////////////////////////////////////

Return .T.

*------------------------------------------------------------*
Function FAF2ApuSld(cContra, cInvoice, cParcela, cParcOrig, cBanco, cPraca, cSeqCon )
*------------------------------------------------------------*
Local nVlRet := 0, lTemVinc := .F.
cFilEF3:=xFilial("EF3")
EF3->(dbSetOrder(6))
// Verifica o Saldo da Parcela de Origem da Liquidação
If EF3->(dbSeek(cFilEF3+If(lEFFTpMod,IF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+cContra+iif(lTemChave,cBanco+cPraca+If(lEFFTpMod,cSeqCon,""),"")+cInvoice+cParcOrig)) //HVR SEEK I OU E
   Do While EF3->(!Eof()) .And. EF3->EF3_FILIAL == cFilEF3 .And. If(lEFFTpMod,EF3->EF3_TPMODU == IF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),.T.) .AND. EF3->EF3_CONTRA = cContra .And. ; //HVR WHILE I OU E
      iif(lTemChave,EF3->EF3_BAN_FI == cBanco,.t.) .and. iif(lTemChave,EF3->EF3_PRACA == cPraca,.t.) .AND. If(lEFFTpMod,EF3->EF3_SEQCNT == cSeqCon,.T.) .and.;
      EF3->EF3_PARC == cParcOrig
      If EF3->EF3_CODEVE = EV_EMBARQUE
         nVlRet += EF3->EF3_VL_INV //EF3->EF3_VL_MOE
         lTemVinc := .T.
      Elseif (EF3->EF3_CODEVE = EV_LIQ_PRC .or. EF3->EF3_CODEVE = EV_LIQ_PRC_FC)
         nVlRet -= EF3->EF3_VL_INV //EF3->EF3_VL_MOE
      Endif
      EF3->(DbSkip())
   Enddo
Endif

// Verifica o Saldo da Parcela Principal, a caso a parcela de origem nao tenha sido Liquidada
If cParcela <> cParcOrig .And. !lTemVinc
   If EF3->(dbSeek(cFilEF3+If(lEFFTpMod,IF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+cContra+iif(lTemChave,cBanco+cPraca+If(lEFFTpMod,cSeqCon,""),"")+cInvoice+cParcela)) //cParcOrig //HVR SEEK I OU E //***WORKEEQ
      Do While EF3->(!Eof()) .And. EF3->EF3_FILIAL = cFilEF3 .AND. If(lEFFTpMod,EF3->EF3_TPMODU == IF(WORKEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),.T.) .And. EF3->EF3_CONTRA = cContra .And. ; //HVR WHILE I OU E
               iif(lTemChave,EF3->EF3_BAN_FI == cBanco,.t.) .and. iif(lTemChave,EF3->EF3_PRACA == cPraca,.t.) .AND. If(lEFFTpMod,EF3->EF3_SEQCNT == cSeqCon,.T.) .and.;
               EF3->EF3_PARC = cParcela
         If EF3->EF3_CODEVE = EV_EMBARQUE
            nVlRet += EF3->EF3_VL_INV //EF3->EF3_VL_MOE
         Elseif (EF3->EF3_CODEVE = EV_LIQ_PRC .or. EF3->EF3_CODEVE = EV_LIQ_PRC_FC)
            nVlRet -= EF3->EF3_VL_INV //EF3->EF3_VL_MOE
         Endif
         EF3->(DbSkip())
      Enddo
   Endif
Endif
EF3->(dbSetOrder(1))

Return nVlRet

*-----------------------------------------------------------------------------------------------*
Function FAF2GetProv()  //GFC - 12/01/05
*-----------------------------------------------------------------------------------------------*
Local oDlg, oGet, ni, lBtOk:=.F., aAlter:={}
Local lVlPrJr := EasyGParam("MV_VLPRJR",,.f.)
Private aHeader := {}, aCols := {}

Aadd(aHeader,{AVSX3("EF3_CONTRA",5),"CONTRATO",AVSX3("EF3_CONTRA",6), AVSX3("EF3_CONTRA",3),AVSX3("EF3_CONTRA",4),"",nil, AVSX3("EF3_CONTRA",2),nil,nil })
Aadd(aHeader,{AVSX3("EF3_INVOIC",5),"INVOICE" ,AVSX3("EF3_INVOIC",6), AVSX3("EF3_INVOIC",3),AVSX3("EF3_INVOIC",4),"",nil, AVSX3("EF3_INVOIC",2),nil,nil })
Aadd(aHeader,{AVSX3("EF3_PARC"  ,5),"PARCELA" ,AVSX3("EF3_PARC"  ,6), AVSX3("EF3_PARC"  ,3),AVSX3("EF3_PARC"  ,4),"",nil, AVSX3("EF3_PARC"  ,2),nil,nil })
Aadd(aHeader,{"Vl. Moeda Calc."    ,"VLOLDMOE",AVSX3("EF3_VL_MOE",6), AVSX3("EF3_VL_MOE",3),AVSX3("EF3_VL_MOE",4),"",nil, AVSX3("EF3_VL_MOE",2),nil,nil })
Aadd(aHeader,{"Vl. R$ Calc."       ,"VLOLDREA",AVSX3("EF3_VL_REA",6), AVSX3("EF3_VL_REA",3),AVSX3("EF3_VL_REA",4),"",nil, AVSX3("EF3_VL_REA",2),nil,nil })
Aadd(aHeader,{"Vl. Moeda Digitado" ,"VLATUMOE",AVSX3("EF3_VL_MOE",6), AVSX3("EF3_VL_MOE",3),AVSX3("EF3_VL_MOE",4),"",nil, AVSX3("EF3_VL_MOE",2),nil,nil })
Aadd(aHeader,{"Vl. R$ Digitado"    ,"VLATUREA",AVSX3("EF3_VL_REA",6), AVSX3("EF3_VL_REA",3),AVSX3("EF3_VL_REA",4),"",nil, AVSX3("EF3_VL_REA",2),nil,nil })

If Len(aGetProv) > 0 .and. lVlPrJr

   For ni:=1 to Len(aGetProv)
      Aadd(aCols,Array(Len(aHeader)+1))
      GDFieldPut("CONTRATO",aGetProv[ni,1] ,Len(aCols))
      GDFieldPut("INVOICE" ,aGetProv[ni,2] ,Len(aCols))
      GDFieldPut("PARCELA" ,aGetProv[ni,3] ,Len(aCols))
      GDFieldPut("VLOLDMOE",aGetProv[ni,4] ,Len(aCols))
      GDFieldPut("VLOLDREA",aGetProv[ni,5] ,Len(aCols))
      GDFieldPut("VLATUMOE",aGetProv[ni,4] ,Len(aCols))
      GDFieldPut("VLATUREA",aGetProv[ni,5] ,Len(aCols))
   Next ni

   //Colunas alteráveis
   aAdd(aAlter, "VLATUMOE" )
   aAdd(aAlter, "VLATUREA" )

   DEFINE MSDIALOG oDlg TITLE STR0091 FROM 10,10 TO 545,770 OF oMainWnd  PIXEL  //"Valores das Provisões de Juros"
      oGet := MsGetDados():New(13,000,269,380,4,"AllwaysTrue()", ,  ,.f., aAlter ,nil,.t.,1500,"Positivo()",nil,nil)
      oGet:oBROWSE:BADD := {||.F.}
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lBtOk:=.T.,oDlg:End()},{||lBtOk:=.F.,oDlg:End()},,) CENTERED

   If lBtOk
      For ni:=1 to Len(aCols)
         aGetProv[ni,6] := GDFieldGet("VLATUMOE",ni)
         aGetProv[ni,7] := GDFieldGet("VLATUREA",ni)
      Next ni
   EndIf

EndIf

Return lBtOk

*-----------------------------------------------------------------------------------------------------*
Function FAF2ArrayEEQ()
*-----------------------------------------------------------------------------------------------------*
Local ni, cParc, nVlAux:=0, nPos, lContrato:=.F., cContrato:=""
Local oDlg, oGet, lBtOk:=.F., aAlter:={}, cEv:="", nRecTMP, dDtPgt:=AvCtoD("")
Private aHeader := {}, aCols := {}

Aadd(aHeader,{AVSX3("EF3_CONTRA",5),"CONTRATO",AVSX3("EF3_CONTRA",6), AVSX3("EF3_CONTRA",3),AVSX3("EF3_CONTRA",4),"",nil, AVSX3("EF3_CONTRA",2),nil,nil })
Aadd(aHeader,{AVSX3("EF3_INVOIC",5),"INVOICE" ,AVSX3("EF3_INVOIC",6), AVSX3("EF3_INVOIC",3),AVSX3("EF3_INVOIC",4),"",nil, AVSX3("EF3_INVOIC",2),nil,nil })
Aadd(aHeader,{AVSX3("EF3_PARC"  ,5),"PARCELA" ,AVSX3("EF3_PARC"  ,6), AVSX3("EF3_PARC"  ,3),AVSX3("EF3_PARC"  ,4),"",nil, AVSX3("EF3_PARC"  ,2),nil,nil })
Aadd(aHeader,{STR0043              ,"VLVINC"  ,AVSX3("EF3_VL_MOE",6), AVSX3("EF3_VL_MOE",3),AVSX3("EF3_VL_MOE",4),"",nil, AVSX3("EF3_VL_MOE",2),nil,nil }) //"Vl. Vinc. Moeda"
Aadd(aHeader,{STR0044              ,"VLLIQ"   ,AVSX3("EF3_VL_MOE",6), AVSX3("EF3_VL_MOE",3),AVSX3("EF3_VL_MOE",4),"",nil, AVSX3("EF3_VL_MOE",2),nil,nil }) //"Vl. Liq. Moeda"
If lPrePag
   Aadd(aHeader,{STR0045           ,"TIPOVINC","@!"                 , 9                    ,0                    ,"",nil, "C"                  ,nil,nil }) //"Vinculado a"
Endif

If Len(aArrayEEQ)>0
   If lPrePag .and. aArrayEEQ[Len(aArrayEEQ),16] <> NIL
      EF3->(dbGoTo(aArrayEEQ[Len(aArrayEEQ),16]))
      IF (lEFFTpMod, EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3->EF3_CONTRA+iif(lTemChave, EF3->EF3_BAN_FI+EF3->EF3_PRACA+If(lEFFTpMod,EF3->EF3_SEQCNT,""), ""))),) //HVR 25/04/06 - //HVR IF lEFFTpMod
      If IF(lEFFTpMod, EF1->EF1_CAMTRA == "1", EF3->EF3_TP_EVE $ ("03/04")) //HVR 25/04/06 - DE: EF3->EF3_TP_EVE $ ("03/04") PARA:(IF EF1->EF1_CAMTRA == "1",.T.,IF EF3->EF3_TP_EVE $ ("03/04")) -
         cEv := Left(EF3->EF3_EV_VIN,2)
      EndIf
   EndIf
   cContrato:=aArrayEEQ[Len(aArrayEEQ),5]
EndIf

nRecTMP := TMP->(RecNo())
For ni:=Len(aArrayEEQ) to 1 Step -1
   cParc := If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN)

   TMP->(dbGoTo(aArrayEEQ[ni,20]))
   dDtPgt := TMP->EEQ_PGT
   TMP->(dbGoTo(nRecTMP))

   If (cParc == aArrayEEQ[ni,3] .or. cParc == aArrayEEQ[ni,13]) .and.;
   aArrayEEQ[ni,12] <> "SALDO" .and. (Empty(dDtPgt) .or. aArrayEEQ[ni,20] == nRecTMP)

      If !lContrato .and. cContrato <> aArrayEEQ[ni,5]
         If !Empty(cContrato)
            lContrato := .T.
         Else
            cContrato := aArrayEEQ[ni,5]
         EndIf
      ElseIf !lContrato
         If lPrePag .and. !Empty(cEv) .and. aArrayEEQ[ni,16] <> NIL
            EF3->(dbGoTo(aArrayEEQ[ni,16]))
            If cEv <> Left(EF3->EF3_EV_VIN,2)
               lContrato := .T.
            EndIf
         EndIf
      EndIf

      If !aArrayEEQ[ni,18]
         If aArrayEEQ[ni,1] = 0 .and. aArrayEEQ[ni,17] <> 0
            aArrayEEQ[ni,1] := aArrayEEQ[ni,17]
         EndIf

         nVlAux += aArrayEEQ[ni,1]

         Aadd(aCols,Array(Len(aHeader)+1))
         GDFieldPut("CONTRATO",aArrayEEQ[ni,5] ,Len(aCols))
         GDFieldPut("INVOICE" ,TMP->EEQ_NRINVO ,Len(aCols))
         GDFieldPut("PARCELA" ,aArrayEEQ[ni,3] ,Len(aCols))
         GDFieldPut("VLVINC"  ,aArrayEEQ[ni,1] ,Len(aCols))
         GDFieldPut("VLLIQ"   ,0               ,Len(aCols))
         If lPrePag .and. aArrayEEQ[ni,16] <> NIL
            EF3->(dbGoTo(aArrayEEQ[ni,16]))
            GDFieldPut("TIPOVINC",If(Left(EF3->EF3_EV_VIN,2)==Left(EV_PRINC_PREPAG,2), STR0046, If(Left(EF3->EF3_EV_VIN,2)==Left(EV_JUROS_PREPAG,2), STR0047, STR0048)) ,Len(aCols)) //"PRINCIPAL" # "JUROS" # "ACC/ACE"
         EndIf
         aCols[Len(aCols),If(lPrePag,7,6)] := aArrayEEQ[ni,8]
      Else
         aArrayEEQ[ni,1] := 0
      EndIf

   EndIf

Next ni

If TMP->EEQ_VL < nVlAux .and. lContrato

   //Colunas alteráveis
   aAdd(aAlter, "VLLIQ" )

   DEFINE MSDIALOG oDlg TITLE STR0049+" - "+TMP->EEQ_MOEDA+Alltrim(Transf(TMP->EEQ_VL,AVSX3("EEQ_VL",AV_PICTURE))) FROM 10,10 TO 545,770 OF oMainWnd  PIXEL //"Valores a liquidar nos contratos de financiamento"
      oGet := MsGetDados():New(13,000,269,380,4,"AllwaysTrue()", ,  ,.f., aAlter ,nil,.t.,1500,"FAF2ArrayVal()",nil,nil)
      oGet:oBROWSE:BADD := {||.F.}
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(FAF2ArrayVal("M->VLLIQ"),(lBtOk:=.T.,oDlg:End()),)},{||If(FAF2ArrayVal("M->VLLIQ"),(lBtOk:=.T.,oDlg:End()),)},,) CENTERED

   If lBtOk
      For ni:=1 to Len(aCols)
         If (nPos:=aScan(aArrayEEQ,{|x| x[8] == aCols[ni,If(lPrePag,7,6)]})) > 0
            aArrayEEQ[nPos,1] := aCols[ni,5]
            If aArrayEEQ[nPos,1] = aArrayEEQ[nPos,17]
               aArrayEEQ[nPos,18] := .T.
            EndIf
         EndIf
      Next ni
   EndIf

EndIf

Return .T.

*---------------------------------------------------------------------------------------------------------*
Function FAF2ArrayVal(cPar)
*---------------------------------------------------------------------------------------------------------*
Local lRet := .T., cCampo, ni, nValAux:=0

cCampo := ReadVar()

If cPar <> NIL .and. cPar == "M->VLLIQ"
   If aCols[n,5] > aCols[n,4]
      MsgInfo(STR0071) //"O Valor a liquidar não pode ser maior quer o valor vinculado"
      lRet := .F.
   Else
      For ni:=1 to Len(aCols)
         nValAux += GDFieldGet("VLLIQ",ni)
      Next ni
      If nValAux < TMP->EEQ_VL
         MsgInfo(STR0072) //"A soma dos valores informados para cada parcela não pode ser menor que o valor a liquidar."
         lRet := .F.
      ElseIf nValAux > TMP->EEQ_VL
         MsgInfo(STR0073) //"A soma dos valores informados para cada parcela não pode ser maior que o valor a liquidar."
         lRet := .F.
      EndIf
   EndIf
ElseIf cCampo == "M->VLLIQ"
   If M->VLLIQ > aCols[n,4]
      MsgInfo(STR0071) //"O Valor a liquidar não pode ser maior quer o valor vinculado"
      lRet := .F.
   Else
      For ni:=1 to Len(aCols)
         If ni <> n
            nValAux += GDFieldGet("VLLIQ",ni)
         EndIf
      Next ni
      nValAux += M->VLLIQ
      If nValAux > TMP->EEQ_VL
         MsgInfo(STR0073) //"A soma dos valores informados para cada parcela não pode ser maior que o valor a liquidar."
         lRet := .F.
      EndIf
   EndIf
EndIf

Return lRet

/*
Função      : FAF2TpVinc
Objetivo    : Saber se a fatura será vinculada a principal ou a juros
Parametro   : -
Retorno     : Tipo da Vinculação
Autor       : Gustavo Fabro da Costa Carreiro
Data e Hora : 06/2005.
*/
*--------------------*
Function FAF2TpVinc()
*--------------------*
Local oDlgMd, nOp:=1, oCbxModal
Local cTpVinc:=Space(1), aTpVinc:={STR0050,STR0051} //"1 - Principal" # "2 - Juros"

If Type("lAF200Auto") == "L" .And. lAF200Auto
   cTpVinc := "1"
Else

   DEFINE MSDIALOG oDlgMd TITLE STR0052 ; //"Contrato de Pré-Pagamento"
          FROM 12,05 To 20,45 OF GetwndDefault()

      @01,04 SAY STR0053 of oDlgMd //"Vincular a"
      cTpVinc := "1"
      @01,08 ComboBox oCbxModal Var cTpVinc Items aTpVinc Valid (!Empty(cTpVinc)) SIZE 52,08 of oDlgMd

      DEFINE SBUTTON FROM 40,45 TYPE 1 ACTION If(!Empty(cTpVinc),(nOp:=1,oDlgMd:End()),) ENABLE OF oDlgMd
      DEFINE SBUTTON FROM 40,80 TYPE 2 ACTION If(!Empty(cTpVinc),(nOp:=1,oDlgMd:End()),) ENABLE OF oDlgMd

   ACTIVATE MSDIALOG oDlgMd CENTERED
EndIf

cTpVinc := Left(cTpVinc,2)

Return cTpVinc

/*
Função      : VerLiqPar
Objetivo    : Verifica se a parcela é totalmente cambio pronto ou se é totalmente vinculada a contrato
              de financiamento, em caso negativo apresentará uma tela explicativa justificando a
              impossibilidade de liquidação da fatura
Parametro   : -
Retorno     : Lógico
Autor       : Gustavo Fabro da Costa Carreiro
Data e Hora : 06/2005.
*/
*-------------------------------------------------------------------------------------------------------*
Function VerLiqPar(lFFC)
*-------------------------------------------------------------------------------------------------------*
Local lRet := .T., nInd, nVlVinc:=0, oDlgVerLiq, nVlPronto
If(lFFC=NIL,lFFC:=.F.,)

For nInd:=1 to Len(aArrayEEQ)
   If (TMP->EEQ_PARC == aArrayEEQ[nInd,3] .or. If(lParFin .and. !Empty(TMP->EEQ_PARFIN),TMP->EEQ_PARFIN,TMP->EEQ_PARC) == aArrayEEQ[nInd,13]) .and.;
   !Empty(aArrayEEQ[nInd,5])
      nVlVinc += aArrayEEQ[nInd,1]
   EndIf
Next nInd

If nVlVinc > 0 .and. nVlVinc < TMP->EEQ_VLFCAM //NCF - 09/04/2014 - Ajuste nos parenteses para cálculo correto
   lRet := .F.
   nVlPronto := ((TMP->EEQ_VLFCAM) - nVlVinc)

   DEFINE MSDIALOG oDlgVerLiq TITLE If(lFFC,STR0054,STR0055)+STR0056+If(lFFC,"o","a") ; //"O FFC" # "A parcela" # " não pode ser liquidad" # "a/o"
   FROM 15,03 To 30,47 OF oMainWnd

      If lFFC
         @0.3,0.5  SAY STR0055+" "+Alltrim(TMP->EEQ_PARC)+STR0057+Alltrim(TMP->EEQ_NRINVO)+STR0058 //"A parcela" # " da invoice " # " não pode ser liquidada pois tem"
         @0.8,0.5  SAY STR0059 //"valores vinculados a contratos de financiamento e também valores"
         @1.3,0.5  SAY STR0060 //"como câmbio pronto."
      Else
         @0.5,0.5  SAY STR0061 //"Esta parcela não pode ser liquidada pois tem valores vinculados a "
         @1,0.5    SAY STR0062 //"contratos de financiamento e também valores como câmbio pronto."
      EndIf
      @2.5,3    SAY STR0063 SIZE 50,8  //"Valor da Parcela"
      @2.5,10.5 MSGET TMP->EEQ_VLFCAM PICTURE AVSX3("EEQ_VL",6) WHEN .F. SIZE 70,7 HASBUTTON
      @3.5,3    SAY STR0064 SIZE 50,8  //"Valor Vinculado"
      @3.5,10.5 MSGET nVlVinc PICTURE AVSX3("EEQ_VL",6) WHEN .F. SIZE 70,7 HASBUTTON
      @4.5,3    SAY STR0065 SIZE 50,8  //"Valor Cambio Pronto"
      @4.5,10.5 MSGET nVlPronto PICTURE AVSX3("EEQ_VL",6) WHEN .F. SIZE 70,7 HASBUTTON

      DEFINE SBUTTON FROM 85,70 TYPE 1 ACTION(oDlgVerLiq:End()) ENABLE OF oDlgVerLiq

   ACTIVATE MSDIALOG oDlgVerLiq CENTERED
EndIf

Return lRet

/*
Função      : FAF2NaoLiq
Objetivo    : Apenas apresenta uma tela explicativa para justificar a impossibilidade da liquidação devido a
              data da liquidação ser anterior ao vencimento da parcela do contrato
Parametro   : cContra  -> Contrato de financiamento
              cBanco   -> Banco do contrato de financiamento
              cPraca   -> Praca do contrato de financiamento
              cEveVin  -> Evento Vinculado
              cParcVin -> Parcela Vinculada
              dDtLiq   -> Data de Liquidação
              dDtVenc  -> Data de vencimento da parcela
Retorno     : Lógico, sempre .T.
Autor       : Gustavo Fabro da Costa Carreiro
Data e Hora : 07/2005.
*/
*-------------------------------------------------------------------------------------------------------*
Function FAF2NaoLiq(cContra,cBanco,cPraca,cEveVin,cParcVin,dDtLiq,dDtVenc,cSeqCon)
*-------------------------------------------------------------------------------------------------------*
Local oDlgVerLiq

DEFINE MSDIALOG oDlgVerLiq TITLE STR0055+STR0056+"a." ; //"A parcela" # " não pode ser liquidada"
FROM 15,03 To 30,47 OF oMainWnd

   @0.5,1  SAY   STR0066 //"Esta fatura não pode ser liquidada antecipadamente pois está"
   @1.0,1  SAY   STR0067+" "+If(cEveVin==EV_PRINC_PREPAG,Lower(STR0046),Lower(STR0047))+"." //" vinculada a " # "Principal"/"Juros"
   @1.5,1  SAY   STR0018+cParcVin+" "+STR0068+" "+Alltrim(cContra)+If(lEFFTpMod .AND. !Empty(cSeqCon)," "+STR0085+" "+AllTrim(cSeqCon),"")  //"parcela " # " do contrato " # " Sequência " #
   @2.0,1  SAY   IIF(!Empty(cBanco),STR0008+" "+Alltrim(cBanco)+IIF(!Empty(cPraca)," "+STR0069+" "+Alltrim(cPraca)+".","."),"")               //" banco " # " praça "
   @3.5,2      SAY   AVSX3("EEQ_PGT",5) SIZE 50,8
   @3.5,11.5   MSGET dDtLiq PICTURE AVSX3("EEQ_PGT",6) WHEN .F. SIZE 60,7
   @4.5,2      SAY   STR0070+If(cEveVin==EV_PRINC_PREPAG,Lower(STR0046),Lower(STR0047)) SIZE 50,8  //"Data de vencimento " # "Principal"/"Juros"
   @4.5,11.5   MSGET dDtVenc PICTURE AVSX3("EEQ_PGT",6) WHEN .F. SIZE 60,7

   DEFINE SBUTTON FROM 85,70 TYPE 1 ACTION(oDlgVerLiq:End()) ENABLE OF oDlgVerLiq

ACTIVATE MSDIALOG oDlgVerLiq CENTERED

Return .T.

/*
Função      : FAF2Repact
Objetivo    : Abre uma manutenção dos períodos dos contratos de financiamento
Parametro   : -
Retorno     : Lógico, sempre .T.
Autor       : Gustavo Fabro da Costa Carreiro
              Alessandro Alves Ferreira
Data e Hora : 11/2005.
*/

*-------------------------------------------------------------------------------------------------------*
Function FAF2Repact()
*-------------------------------------------------------------------------------------------------------*
Local oDlg, nI:= 0, aPosDlgPer:={}, aAltera:={}, nSelecao:=0
Local bOk:={|| If(FAF2LnOK(),(nSelecao:=1,oDlgPer:End()),)}, bCancel:={||nSelecao:=0,oDlgPer:End()}
Private aHeader:={}, aCols:={}, lVinc:=.F.
Private lEF2Filori  := EF2->(FieldPos("EF2_FILORI")) > 0
Private lEvCont := .F.       // Filtro para F3 do Tipo de Financiamento
Private cFiltroF3Fin := "E"  // Filtro para F3 do Tipo de Financiamento

Begin Sequence

   //** GFC - 16/02/05
   If aScan(aClickRep,TMP->EEQ_PARC) = 0
      aAdd(aClickRep,TMP->EEQ_PARC)
   EndIf
   //**

   FAF2HeadRep()

   EF1->( dbSetOrder(1) )
   EF2->( dbSetOrder(1) )

   //Verifica se invoice esta vinculada a contrato de financiamento.
   If aScan(aRepact,{|x| x[Len(aHeader)+5]==TMP->EEQ_PARC}) = 0
      aCols := Ini_aCols()
   Else
      For nI:=1 to Len(aRepact)
         If aRepact[nI,Len(aHeader)+5] == TMP->EEQ_PARC
            aAdd(aCols,aRepact[ni])
         EndIf
      Next nI
      lVinc := .T.
   EndIf

   If !lVinc
      MsgStop(STR0076) //"Parcela não vinculada a contrato de financiamento."
      BREAK
   ElseIf Len(aCols) == 0
      MsgInfo(STR0077) //"Esta parcela não possui períodos em nenhum de seus contratos."
   Endif

   DEFINE MSDIALOG oDlgPer TITLE STR0078+Alltrim(TMP->EEQ_NRINVO)+"/"+Alltrim(TMP->EEQ_PARC); //"Repactuação - Invoice/Parc: "
   FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
       aPosDlgPer := PosDlg(oDlgPer)
       //                           1              2             3            4         5  6  7  8  9   10      11  12  13  14 15  16  17   18
       oGet := MsGetDados():New(aPosDlgPer[1],aPosDlgPer[2],aPosDlgPer[3],aPosDlgPer[4],3,"FAF2LnOK","","",.f.,       ,nil,.f.,1500,"FAF2FieldOK",nil,nil,"FAF2DelOK",oDlgPer)

       oDlgPer:lMaximized:=.T.
   ACTIVATE MSDIALOG oDlgPer ON INIT EnchoiceBar(oDlgPer,bOk,bCancel)

   If nSelecao = 1
      If Len(aRepact) > 0
         For nI:=1 to Len(aRepact)
            If nI <= Len(aRepact) .and. aRepact[nI,Len(aHeader)+5] == TMP->EEQ_PARC
               aDel(aRepact,nI)
               aSize(aRepact,LEN(aRepact)-1)
               ni:=0
            ElseIf nI > Len(aRepact)
               Exit
            EndIf
         Next nI

         For nI:=1 to Len(aCols)
            aAdd(aRepact,aCols[nI])
         Next nI
      Else
         aRepact := aClone(aCols)
      EndIf
   EndIf

End Sequence

Return .T.

*---------------------------------------------------------------------------------------------------------*
Function FAF2GrvRep()
*---------------------------------------------------------------------------------------------------------*
Local nI:=0, aColsAux:={}, nX:=0, lInc:=.F., lAltTaxa:=.F., nRecEF2, nOldTx, nOrdTmp
Private aHeader := {}, aParcs:={}

lEF1_LIQPER := EF1->(FieldPos("EF1_LIQPER")) > 0
lEF2_TIPJUR := EF2->(FieldPos("EF2_TIPJUR")) > 0
lEF1_JR_ANT := EF1->(FieldPos("EF1_JR_ANT")) > 0

EC6->(DbSetOrder(6))
EC6->(DbSeek(xFilial("EC6")+"FIEX01"+'100'))
cTX_100 := EC6->EC6_TXCV
EC6->(dbSetOrder(1))

FAF2HeadRep()

//Deleta excluídos
TMP->(dbGoTop())
Do While !TMP->(EOF())
   If aScan(aClickRep,TMP->EEQ_PARC) > 0  //** GFC - 16/02/05
      aColsAux := Ini_aCols()
      For nI:=1 to Len(aColsAux)
         If aScan(aRepact,{|x| x[Len(aHeader)+1]==aColsAux[nI,Len(aHeader)+1] }) = 0
            EF2->(dbGoTo(aColsAux[nI,Len(aHeader)+1]))

            EF1->(dbSetOrder(1))
            EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,IF(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),"")+EF2->EF2_CONTRA+EF2->EF2_BAN_FI+EF2->EF2_PRACA+If(lEFFTpMod,EF2->EF2_SEQCNT,""))) //HVR SEEK I OU E

            //** GFC - Liquidação por Períodos
            If lEF1_LIQPER .and. EF1->EF1_LIQPER == "1"
               EX401GrvLP("EF1","EF2","EF3",EF1->EF1_CONTRA,EF1->EF1_BAN_FI,EF1->EF1_PRACA,EF2->EF2_DT_INI,EF2->EF2_DT_FIM,If(lEF2_TIPJUR,EF2->EF2_TIPJUR,"0"),5,"E",If(lEFFTpMod,EF1->EF1_SEQCNT,)) //AAF - 21/02/2006 - Adicionado o campo sequencia do contrato.
            EndIf
            //**

            EF2->(RecLock("EF2",.F.))
            EF2->(dbDelete())
            EF2->(msUnlock())
         EndIf
      Next nI
   EndIf
   TMP->(dbSkip())
EndDo

//Grava inclusões e alterações
For nI:=1 to Len(aRepact)
//HVR GUADA SET ORDER DA TMP E POSICIONA USANDO aCols
   nOrdTmp := TMP->(IndexOrd())
   TMP->(dbSetOrder(1))
   TMP->(dbSeek(aRepact[nI][Len(aHeader)+5]))
//HVR***

   If !Empty(aRepact[nI][Len(aHeader)+1])         //Alteração
      EF2->(dbGoTo(aRepact[nI][Len(aHeader)+1]))
      EF2->(RecLock("EF2",.F.))
   Else                                           //Inclusão
      lInc := .T.
      EF2->(RecLock("EF2",.T.))
      EF2->EF2_FILIAL := xFilial("EF2")
      EF2->EF2_CONTRA := aRepact[nI][GDFieldPos("EF2_CONTRA")]
      EF2->EF2_BAN_FI := aRepact[nI][GDFieldPos("EF2_BAN_FI")]
      EF2->EF2_PRACA  := aRepact[nI][GDFieldPos("EF3_PRACA")]
      //** AAF - 21/02/2006 - Adicionado o campo sequencia do contrato.
      If lEFFTpMod
         EF2->EF2_SEQCNT := aRepact[nI][GDFieldPos("EF3_SEQCNT")]
      EndIf
      //**
      If lMulTiFil
         EF2->EF2_FILORI := aRepact[nI][Len(aHeader)+3]
      EndIf
      EF2->EF2_INVOIC := aRepact[nI][Len(aHeader)+4]
      EF2->EF2_PARC   := aRepact[nI][Len(aHeader)+5]
   EndIf
   EF2->EF2_TP_FIN := aRepact[nI][GDFieldPos("EF1_TP_FIN")]
   EF2->EF2_TIPJUR := aRepact[nI][GDFieldPos("EF2_TIPJUR")]
   EF2->EF2_DT_INI := aRepact[nI][GDFieldPos("DT_INI")]
   EF2->EF2_DT_FIM := aRepact[nI][GDFieldPos("EF2_DT_FIM")]
   EF2->EF2_TP_VAR := aRepact[nI][GDFieldPos("EF2_TP_VAR")]
   EF2->EF2_TX_VAR := aRepact[nI][GDFieldPos("TX_VAR")]
   If !lInc .and. EF2->EF2_TX_DIA <> aRepact[nI][GDFieldPos("EF2_TX_DIA")]
      lAltTaxa := .T.
      nOldTx   := EF2->EF2_TX_FIX
   EndIf
   EF2->EF2_TX_FIX := aRepact[nI][GDFieldPos("EF2_TX_FIX")]
   EF2->EF2_TX_DIA := aRepact[nI][GDFieldPos("EF2_TX_DIA")]
   EF2->EF2_USEINV := aRepact[nI][GDFieldPos("EF2_USEINV")]
   // PLB 14/09/06
   //If lEF1_DTBONI
      //EF2->EF2_BONUS  := aRepact[nI][GDFieldPos("EF2_BONUS")]
   //EndIf
   EF2->(msUnlock())

   EF1->(dbSetOrder(1))
   EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,IF(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),"")+EF2->EF2_CONTRA+EF2->EF2_BAN_FI+EF2->EF2_PRACA+If(lEFFTpMod,EF2->EF2_SEQCNT,"")))  //HVR 26/04/06 SEEK I OU E

   If lAltTaxa
      nRecEF2 := EF2->(RecNo())
      EX401AltTaxa("EF1","EF2","EF3",EF2->EF2_INVOIC,EF2->EF2_PARC,EF2->EF2_DT_INI,EF2->EF2_CONTRA,EF2->EF2_BAN_FI,EF2->EF2_PRACA,If(lEF2_TIPJUR,EF2->EF2_TIPJUR,"0"),EF2->EF2_TX_FIX,nOldTx,nRecEF2,"E",If(lEFFTpMod,EF2->EF2_SEQCNT,))
      lAltTaxa := .F.
      EF2->(dbGoTo(nRecEF2))
   EndIf

   //** GFC - Juros Antecipados
   If lInc .and. lEF1_JR_ANT .and. EF1->EF1_JR_ANT == "1"
      nTxJrAnt := BuscaTaxa(EF1->EF1_MOEDA,EF2->EF2_DT_INI,,.F.,.T.,,cTX_100)
      EX401GrvJA("EF1","EF2","EF3",EF2->EF2_DT_INI,EF2->EF2_DT_FIM,EF1->EF1_CONTRA,EF1->EF1_BAN_FI,EF1->EF1_PRACA,nTxJrAnt,EF2->EF2_DT_INI,If(lEF2_TIPJUR,{EF2->EF2_TIPJUR},),"E",If(lEFFTpMod,EF1->EF1_SEQCNT,)) //AAF - 21/02/2006 - Adicionado o campo sequencia do contrato.
   EndIf
   //**

   //** GFC - Liquidação por Períodos
   If lInc .and. lEF1_LIQPER .and. EF1->EF1_LIQPER == "1"
      EX401GrvLP("EF1","EF2","EF3",EF1->EF1_CONTRA,EF1->EF1_BAN_FI,EF1->EF1_PRACA,EF2->EF2_DT_INI,EF2->EF2_DT_FIM,If(lEF2_TIPJUR,EF2->EF2_TIPJUR,"0"),3,"E",If(lEFFTpMod,EF1->EF1_SEQCNT,)) //AAF - 21/02/2006 - Adicionado o campo sequencia do contrato.
   EndIf
   //**
Next nI
TMP->(DbSetOrder(nOrdTmp))

Return .T.

*---------------------------------------------------------------------------------------------------------*
Function FAF2GetDVal(cGet)
*---------------------------------------------------------------------------------------------------------*
Local lRet:=.T.

Do Case
   Case cGet == "EF2_CONTRA"
      If !Empty(aCols[n][Len(aHeader)+1])
         MsgInfo(STR0079) //"O Contrato não pode ser alterado."
         lRet := .F.
      ElseIf !ExistCpo('EF1',M->EF2_CONTRA)
         lRet := .F.
      Else
         If EF1->EF1_CONTRA <> M->EF2_CONTRA
            EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,IF(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),"")+M->EF2_CONTRA)) //HVR SEEK I OU E
         EndIf
         aCols[n][GDFieldPos("EF2_BAN_FI")] := EF1->EF1_BAN_FI
         aCols[n][GDFieldPos("EF3_PRACA" )] := EF1->EF1_PRACA
         aCols[n][GDFieldPos("EF1_TP_FIN")] := EF1->EF1_TP_FIN+" - "+If(lCadFin,Posicione("EF7",1,xFilial("EF7")+EF1->EF1_TP_FIN,"EF7_DESCRI"), Posicione("SX5",1,xFilial("SX5")+"CG"+EF1->EF1_TP_FIN,"X5_DESCRI"))

         //** AAF 21/02/2006 - Gravação da Sequencia do Contrato.
         If lEFFTpMod
            aCols[n][GDFieldPos("EF1_SEQCNT")] := EF1->EF1_SEQCNT
         EndIf
         //**
      EndIf

   Case cGet == "EF2_BAN_FI"
      If !Empty(aCols[n][Len(aHeader)+1])
         MsgInfo(STR0080) //"O Banco não pode ser alterado."
         lRet := .F.
      ElseIf !ExistCpo('EF1',aCols[n][GDFieldPos("EF2_CONTRA")]+M->EF2_BAN_FI)
         lRet := .F.
      Else
         If EF1->EF1_CONTRA <> aCols[n][GDFieldPos("EF2_CONTRA")] .or. EF1->EF1_BAN_FI <> M->EF2_BAN_FI
            EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,IF(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),"")+aCols[n][GDFieldPos("EF2_CONTRA")]+M->EF2_BAN_FI)) //HVR SEEK I OU E
         EndIf
         aCols[n][GDFieldPos("EF3_PRACA" )] := EF1->EF1_PRACA
         aCols[n][GDFieldPos("EF1_TP_FIN")] := EF1->EF1_TP_FIN+" - "+If(lCadFin,Posicione("EF7",1,xFilial("EF7")+EF1->EF1_TP_FIN,"EF7_DESCRI"),Posicione("SX5",1,xFilial("SX5")+"CG"+EF1->EF1_TP_FIN,"X5_DESCRI"))
         aCols[n][GDFieldPos("EF2_TIPJUR")] := "0"+" - "+Posicione("SX5",1,xFilial("SX5")+"CV"+"0","X5_DESCRI")
         //** AAF 21/02/2006 - Gravação da Sequencia do Contrato.
         If lEFFTpMod
            aCols[n][GDFieldPos("EF3_SEQCNT")] := EF1->EF1_SEQCNT
         EndIf
         //**
      EndIf

   Case cGet == "EF3_PRACA"
      If !Empty(aCols[n][Len(aHeader)+1])
         MsgInfo(STR0081) //"A praça não pode ser alterada."
         lRet := .F.
      ElseIf !ExistCpo('EF1',aCols[n][GDFieldPos("EF2_CONTRA")]+aCols[n][GDFieldPos("EF2_BAN_FI")]+M->EF3_PRACA)
         lRet := .F.
      Else
         If EF1->EF1_CONTRA <> aCols[n][GDFieldPos("EF2_CONTRA")] .or.;
         EF1->EF1_BAN_FI <> aCols[n][GDFieldPos("EF2_BAN_FI")] .or. EF1->EF1_PRACA <> M->EF3_PRACA
            EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,IF(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),"")+aCols[n][GDFieldPos("EF2_CONTRA")]+aCols[n][GDFieldPos("EF2_BAN_FI")]+M->EF3_PRACA)) //HVR SEEK I OU E
         EndIf
         aCols[n][GDFieldPos("EF1_TP_FIN")] := EF1->EF1_TP_FIN+" - "+If(lCadFin,Posicione("EF7",1,xFilial("EF7")+EF1->EF1_TP_FIN,"EF7_DESCRI"),Posicione("SX5",1,xFilial("SX5")+"CG"+EF1->EF1_TP_FIN,"X5_DESCRI"))
         //** AAF 21/02/2006 - Gravação da Sequencia do Contrato.
         If lEFFTpMod
            aCols[n][GDFieldPos("EF1_SEQCNT")] := EF1->EF1_SEQCNT
         EndIf
         //**
      EndIf

   //** AAF 23/02/06  - Adicionada validação para o campo Sequência.
   Case cGet == "EF3_SEQCNT"
      If !Empty(aCols[n][Len(aHeader)+1])
         MsgInfo(STR0086) //"A sequência não pode ser alterada."
         lRet := .F.
      ElseIf !ExistCpo('EF1',aCols[n][GDFieldPos("EF2_CONTRA")]+aCols[n][GDFieldPos("EF2_BAN_FI")]+aCols[n][GDFieldPos("EF3_PRACA")]+M->EF3_SEQCNT)
         lRet := .F.
      Else
         If EF1->EF1_CONTRA <> aCols[n][GDFieldPos("EF2_CONTRA")] .or.;
         EF1->EF1_BAN_FI <> aCols[n][GDFieldPos("EF2_BAN_FI")] .or. EF1->EF1_PRACA <> aCols[n][GDFieldPos("EF3_PRACA")] .AND. EF1->EF1_SEQCNT <> M->EF3_SEQCNT
            EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,IF(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),"")+aCols[n][GDFieldPos("EF2_CONTRA")]+aCols[n][GDFieldPos("EF2_BAN_FI")]+aCols[n][GDFieldPos("EF3_PRACA")]+M->EF3_SEQCNT)) //HVR SEEK I OU E
         EndIf
         aCols[n][GDFieldPos("EF1_TP_FIN")] := EF1->EF1_TP_FIN+" - "+If(lCadFin,Posicione("EF7",1,xFilial("EF7")+EF1->EF1_TP_FIN,"EF7_DESCRI"),Posicione("SX5",1,xFilial("SX5")+"CG"+EF1->EF1_TP_FIN,"X5_DESCRI"))
         //** AAF 21/02/2006 - Gravação da Sequencia do Contrato.
         If lEFFTpMod
            aCols[n][GDFieldPos("EF1_SEQCNT")] := EF1->EF1_SEQCNT
         EndIf
         //**
      EndIf
   //**

   Case cGet == "EF1_TP_FIN"
      If If(lCadFin,!ExistCpo("EF7",M->EF1_TP_FIN),!ExistCpo("SX5","CG"+M->EF1_TP_FIN))
         lRet := .F.
      Else
         M->EF1_TP_FIN := Alltrim(M->EF1_TP_FIN)+" - "+If(lCadFin,Posicione("EF7",1,xFilial("EF7")+EF1->EF1_TP_FIN,"EF7_DESCRI"),Posicione("SX5",1,xFilial("SX5")+"CG"+M->EF1_TP_FIN,"X5_DESCRI"))
      EndIf

   Case cGet == "EF2_TIPJUR
      If !ExistCpo("SX5","CV"+M->EF2_TIPJUR)
         lRet := .F.
      Else
         M->EF2_TIPJUR := Alltrim(M->EF2_TIPJUR)+" - "+Posicione("SX5",1,xFilial("SX5")+"CV"+M->EF2_TIPJUR,"X5_DESCRI")
      EndIf

   Case cGet == "DT_INI"
      If !Empty(M->DT_INI) .and. !Empty(aCols[n][GDFieldPos("EF2_DT_FIM")]) .and.;
      !E_Periodo_OK(M->DT_INI,aCols[n][GDFieldPos("EF2_DT_FIM")])
         lRet := .F.
      ElseIf !Empty(M->DT_INI) .and. EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,IF(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),"")+aCols[n][GDFieldPos("EF2_CONTRA")]+aCols[n][GDFieldPos("EF2_BAN_FI")]+aCols[n][GDFieldPos("EF3_PRACA")]+If(lEFFTpMod,aCols[n][GDFieldPos("EF3_SEQCNT")],""))) .and.; //AAF - 21/02/2006 - Adicionado o campo Sequência do Contrato. //HVR SEEK I OU E
      M->DT_INI < EF1->EF1_DT_JUR
         MsgInfo(STR0082) //"A data incial informada não pode ser menor que a data de início do juros."
         lRet := .F.
      //** Validar datas nos períodos
      //**
      EndIf

   Case cGet == "EF2_DT_FIM"
      If !Empty(M->EF2_DT_FIM) .and. !Empty(aCols[n][GDFieldPos("DT_INI")]) .and.;
      !E_Periodo_OK(aCols[n][GDFieldPos("DT_INI")],M->EF2_DT_FIM)
         lRet := .F.
      //ElseIf !Empty(M->EF2_DT_FIM) .and. EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,IF(TMP->EEQ_TP_CON $ ("2/4"),"E","I"),"")+aCols[n][GDFieldPos("EF2_CONTRA")]+aCols[n][GDFieldPos("EF2_BAN_FI")]+aCols[n][GDFieldPos("EF3_PRACA")]+If(lEFFTpMod,aCols[n][GDFieldPos("EF3_SEQCNT")],""))) .and.; //AAF 21/02/2006 - Adicionado campo Sequência. //HVR SEEK I OU E
      //M->EF2_DT_FIM < EF1->EF1_DT_CTB
      // PLB 13/06/07
      ElseIf !Empty(M->EF2_DT_FIM) .and. EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,IF(TMP->EEQ_TP_CON $ ("2/4"),"E","I"),"")+aCols[n][GDFieldPos("EF2_CONTRA")]+aCols[n][GDFieldPos("EF2_BAN_FI")]+aCols[n][GDFieldPos("EF3_PRACA")]+If(lEFFTpMod,aCols[n][GDFieldPos("EF3_SEQCNT")],"")))  ;
             .And.  !Empty(EF1->EF1_DT_CTB)  .And.  M->EF2_DT_FIM < EF1->EF1_DT_CTB  ;
             .And.  IIF(IIF(lEFFTpMod,EF1->EF1_TPMODU=="E",.T.),EX401IsCtb(EF1->EF1_CONTRA,EF1->EF1_BAN_FI,EF1->EF1_PRACA,IIF(lEFFTpMod,EF1->EF1_SEQCNT,"")),.F.)
         MsgInfo(STR0083) //"Data Final do periodo nao pode ser menor que a Data da Ultima Contabilização."
         lRet := .F.
      //** Validar datas nos períodos
      //**
      EndIf

   Case cGet == "EF2_TX_FIX"
      If !Positivo(M->EF2_TX_FIX)
         lRet := .F.
      Else
         aCols[n][GDFieldPos("EF2_TX_DIA")] := (M->EF2_TX_FIX + aCols[n][GDFieldPos("TX_VAR")]) / 360
      EndIf

   Case cGet == "EF2_TP_VAR"
      If !Empty(M->EF2_TP_VAR) .and. !ExistCpo("SX5","CI"+M->EF2_TP_VAR)
         lRet := .F.
      EndIf

   Case cGet == "TX_VAR"
      If !Positivo(M->TX_VAR)
         lRet := .F.
      Else
         aCols[n][GDFieldPos("EF2_TX_DIA")] := (aCols[n][GDFieldPos("EF2_TX_FIX")] + M->TX_VAR) / 360
      EndIf

   Case cGet == "EF2_USEINV"
      If !Pertence("12 ",M->EF2_USEINV)
         lRet := .F.
      EndIf

   // PLB 14/09/06
   //Case cGet == "EF2_BONUS"
      //If !Pertence("12 ",M->EF2_BONUS)
         //lRet := .F.
      //EndIf

EndCase

Return lRet

*---------------------------------------------------------------------------------------------------------*
Function FAF2LnOK()
*---------------------------------------------------------------------------------------------------------*
Local lRet:=.T.

If Empty(aCols[n][GDFieldPos("EF2_CONTRA")])
   MsgInfo(aHeader[GDFieldPos("EF2_CONTRA"),1]+STR0084) //" deve ser preenchido(a)."
   lRet:=.F.
ElseIf Empty(aCols[n][GDFieldPos("EF2_BAN_FI")])
   MsgInfo(aHeader[GDFieldPos("EF2_BAN_FI"),1]+STR0084) //" deve ser preenchido(a)."
   lRet:=.F.
ElseIf Empty(aCols[n][GDFieldPos("EF3_PRACA")])
   MsgInfo(aHeader[GDFieldPos("EF3_PRACA"),1]+STR0084) //" deve ser preenchido(a)."
   lRet:=.F.
ElseIf lEFFTpMod .AND. Empty(aCols[n][GDFieldPos("EF3_SEQCNT")]) //AAF - 21/02/2006 - Validação da Sequência.
   MsgInfo(aHeader[GDFieldPos("EF3_SEQCNT"),1]+STR0084) //" deve ser preenchido(a)."
   lRet:=.F.
ElseIf Empty(aCols[n][GDFieldPos("EF1_TP_FIN")])
   MsgInfo(aHeader[GDFieldPos("EF1_TP_FIN"),1]+STR0084) //" deve ser preenchido(a)."
   lRet:=.F.
ElseIf Empty(aCols[n][GDFieldPos("EF2_TIPJUR")])
   MsgInfo(aHeader[GDFieldPos("EF2_TIPJUR"),1]+STR0084) //" deve ser preenchido(a)."
   lRet:=.F.
ElseIf Empty(aCols[n][GDFieldPos("DT_INI")])
   MsgInfo(aHeader[GDFieldPos("DT_INI"),1]+STR0084) //" deve ser preenchido(a)."
   lRet:=.F.
ElseIf Empty(aCols[n][GDFieldPos("EF2_DT_FIM")])
   MsgInfo(aHeader[GDFieldPos("EF2_DT_FIM"),1]+STR0084) //" deve ser preenchido(a)."
   lRet:=.F.
ElseIf Empty(aCols[n][GDFieldPos("EF2_USEINV")])
   MsgInfo(aHeader[GDFieldPos("EF2_USEINV"),1]+STR0084) //" deve ser preenchido(a)."
   lRet:=.F.
Else
   If ValType(aCols[n][Len(aHeader)+1]) <> "N"
      aAdd(aCols[n],NIL)
      aAdd(aCols[n],NIL)
      aAdd(aCols[n],NIL)
      aAdd(aCols[n],NIL)
      aIns(aCols[n],Len(aHeader)+1)
      aIns(aCols[n],Len(aHeader)+3)
      aIns(aCols[n],Len(aHeader)+4)
      aIns(aCols[n],Len(aHeader)+5)
      aCols[n][Len(aHeader)+1] := 0
      aCols[n][Len(aHeader)+3] := TMP->EEQ_FILIAL
      aCols[n][Len(aHeader)+4] := TMP->EEQ_NRINVO
      aCols[n][Len(aHeader)+5] := TMP->EEQ_PARC
   EndIf
EndIf

Return lRet

*---------------------------------------------------------------------------------------------------------*
Function FAF2FieldOK()
*---------------------------------------------------------------------------------------------------------*

Return .T.

*---------------------------------------------------------------------------------------------------------*
Function FAF2DelOK()
*---------------------------------------------------------------------------------------------------------*
Local aAux := {}, nI

aCols[n, ( Len(aHeader) + 2 ) ] := .T.

For nI := 1 to Len(aCols)
   If !aCols[ nI, ( Len(aHeader) + 2 ) ]
      Aadd(aAux,aCols[nI])
   Endif
Next

aCols := aClone(aAux)

If Len(aCols) = 0
   New_aCols()
ElseIf n > Len(aCols)
   n := Len(aCols)
EndIf

oGet:ForceRefresh()

Return .T.

*---------------------------------------------------------------------------------------------------------*
Function FAF2HeadRep()
*---------------------------------------------------------------------------------------------------------*
aHeader := {}

aAdd(aHeader,{AVSX3("EF2_CONTRA",5),"EF2_CONTRA",AVSX3("EF2_CONTRA",6),AVSX3("EF2_CONTRA",3),AVSX3("EF2_CONTRA",4),"FAF2GetDVal('EF2_CONTRA')",NIL,AVSX3("EF2_CONTRA",2),NIL,NIL} )
aAdd(aHeader,{AVSX3("EF2_BAN_FI",5),"EF2_BAN_FI",AVSX3("EF2_BAN_FI",6),AVSX3("EF2_BAN_FI",3),AVSX3("EF2_BAN_FI",4),"FAF2GetDVal('EF2_BAN_FI')","S",AVSX3("EF2_BAN_FI",2),NIL,NIL} )
If lTemChave
   aAdd(aHeader,{AVSX3("EF3_PRACA",5) ,"EF3_PRACA" ,AVSX3("EF3_PRACA",6) ,AVSX3("EF3_PRACA" ,3),AVSX3("EF3_PRACA" ,4),"FAF2GetDVal('EF3_PRACA')",NIL,AVSX3("EF3_PRACA" ,2),NIL,NIL} )
   //** AAF - 21/02/2006 - Adiciona o campo Sequência do contrato na Tela de Vinculação.
   If lEFFTpMod
      aAdd(aHeader,{AVSX3("EF3_SEQCNT",5) ,"EF3_SEQCNT" ,AVSX3("EF3_SEQCNT",6) ,AVSX3("EF3_SEQCNT" ,3),AVSX3("EF3_SEQCNT" ,4),"FAF2GetDVal('EF3_SEQCNT')",NIL,AVSX3("EF3_SEQCNT" ,2),NIL,NIL} )
   EndIf
   //**
Endif

aAdd(aHeader,{AVSX3("EF1_TP_FIN",5),"EF1_TP_FIN",AVSX3("EF1_TP_FIN",6),AVSX3("EF1_TP_FIN",3)+AVSX3("EF1_VM_FIN",3)+3,AVSX3("EF1_TP_FIN",4),"FAF2GetDVal('EF1_TP_FIN')",NIL,AVSX3("EF1_TP_FIN",2),NIL,NIL} )
aAdd(aHeader,{AVSX3("EF2_TIPJUR",5),"EF2_TIPJUR",AVSX3("EF2_TIPJUR",6),AVSX3("EF2_TIPJUR",3)+AVSX3("EF2_VM_JUR",3)+3,AVSX3("EF2_TIPJUR",4),"FAF2GetDVal('EF2_TIPJUR')",NIL,AVSX3("EF2_TIPJUR",2),NIL,NIL} )
aAdd(aHeader,{AVSX3("EF2_DT_INI",5),"DT_INI"    ,AVSX3("EF2_DT_INI",6),AVSX3("EF2_DT_INI",3),AVSX3("EF2_DT_INI",4),"FAF2GetDVal('DT_INI')",NIL,AVSX3("EF2_DT_INI",2),NIL,NIL} )
aAdd(aHeader,{AVSX3("EF2_DT_FIM",5),"EF2_DT_FIM",AVSX3("EF2_DT_FIM",6),AVSX3("EF2_DT_FIM",3),AVSX3("EF2_DT_FIM",4),"FAF2GetDVal('EF2_DT_FIM')",NIL,AVSX3("EF2_DT_FIM",2),NIL,NIL} )
aAdd(aHeader,{AVSX3("EF2_TX_FIX",5),"EF2_TX_FIX",AVSX3("EF2_TX_FIX",6),AVSX3("EF2_TX_FIX",3),AVSX3("EF2_TX_FIX",4),"FAF2GetDVal('EF2_TX_FIX')",NIL,AVSX3("EF2_TX_FIX",2),NIL,NIL} )
aAdd(aHeader,{AVSX3("EF2_TP_VAR",5),"EF2_TP_VAR",AVSX3("EF2_TP_VAR",6),AVSX3("EF2_TP_VAR",3),AVSX3("EF2_TP_VAR",4),"FAF2GetDVal('EF2_TP_VAR')",NIL,AVSX3("EF2_TP_VAR",2),NIL,NIL} )
aAdd(aHeader,{AVSX3("EF2_TX_VAR",5),"TX_VAR"    ,AVSX3("EF2_TX_VAR",6),AVSX3("EF2_TX_VAR",3),AVSX3("EF2_TX_VAR",4),"FAF2GetDVal('TX_VAR')",NIL,AVSX3("EF2_TX_VAR",2),NIL,NIL} )
aAdd(aHeader,{AVSX3("EF2_TX_DIA",5),"EF2_TX_DIA",AVSX3("EF2_TX_DIA",6),AVSX3("EF2_TX_DIA",3),AVSX3("EF2_TX_DIA",4),/*VALIDACAO*/,NIL,AVSX3("EF2_TX_DIA",2),NIL,NIL} )
aAdd(aHeader,{AVSX3("EF2_USEINV",5),"EF2_USEINV",AVSX3("EF2_USEINV",6),AVSX3("EF2_USEINV",3),AVSX3("EF2_USEINV",4),"FAF2GetDVal('EF2_USEINV')",NIL,AVSX3("EF2_USEINV",2),NIL,NIL} )
// PLB 14/09/06
//If lEF1_DTBONI
   //aAdd(aHeader,{AVSX3("EF2_BONUS" ,5),"EF2_BONUS" ,AVSX3("EF2_BONUS" ,6),AVSX3("EF2_BONUS" ,3),AVSX3("EF2_BONUS" ,4),"FAF2GetDVal('EF2_BONUS')",NIL,AVSX3("EF2_BONUS" ,2),NIL,NIL} )
//EndIf

Return .T.

*---------------------------------------------------------------------------------------------------------*
Static Function New_aCols()
*---------------------------------------------------------------------------------------------------------*
aAdd(aCols, Array( Len(aHeader)+5 ))
n := Len(aCols)
oGet:oBrowse:ColPos	:= 1

aCols[n][GDFieldPos("EF2_CONTRA")] := Space(Len(EF2->EF2_CONTRA))
aCols[n][GDFieldPos("EF2_BAN_FI")] := Space(Len(EF2->EF2_BAN_FI))
If lTemChave
   aCols[n][GDFieldPos("EF3_PRACA")] := Space(Len(EF3->EF3_PRACA))
   //** AAF - 21/02/2006 - Adiciona o campo Sequência do contrato na Tela de Vinculação.
   If lEFFTpMod
      aCols[n][GDFieldPos("EF3_SEQCNT")] := Space(Len(EF3->EF3_SEQCNT))
   EndIf
   //**
EndIf
aCols[n][GDFieldPos("EF1_TP_FIN")] := Space(Len(EF1->EF1_TP_FIN))
aCols[n][GDFieldPos("EF2_TIPJUR")] := Space(Len(EF2->EF2_TIPJUR))
aCols[n][GDFieldPos("DT_INI")]     := dDataBase
aCols[n][GDFieldPos("EF2_DT_FIM")] := avCtoD("")
aCols[n][GDFieldPos("EF2_TX_FIX")] := 0
aCols[n][GDFieldPos("EF2_TP_VAR")] := Space(Len(EF2->EF2_TP_VAR))
aCols[n][GDFieldPos("TX_VAR")]     := 0
aCols[n][GDFieldPos("EF2_TX_DIA")] := 0
aCols[n][GDFieldPos("EF2_USEINV")] := "2"
// PLB 14/09/06
//If lEF1_DTBONI
   //aCols[n][GDFieldPos("EF2_BONUS")]  := "2"
//EndIf

Return .T.

*---------------------------------------------------------------------------------------------------------*
Static Function Ini_aCols(cParc)
*---------------------------------------------------------------------------------------------------------*
Local aCols:={}, nReg, nI

lEF2Filori  := EF2->(FieldPos("EF2_FILORI")) > 0

For nI := 1 to Len(aArrayEEQ)
   If aArrayEEQ[nI,3] == TMP->EEQ_PARC .AND. !Empty(aArrayEEQ[nI,5])
      lVinc := .T.

      If aScan(aCols,{|X| X[GDFieldPos("EF2_CONTRA")] == aArrayEEQ[nI,5]}) == 0

         //Verifica se existem períodos específicos para esta invoice.
         EF2->( dbSeek(xFilial("EF2")+If(lEFFTpMod,IF(TMP->EEQ_TP_CON $ ("2/4"),"E","I"),"")+aArrayEEQ[nI,5]+iif(lTemChave,aArrayEEQ[nI,14]+aArrayEEQ[nI,15]+If(lEFFTpMod,aArrayEEQ[nI,21],""),"")+; //HVR SEEK I OU E //***TMP
                iif(lEF2FilOri,xFilial("EEQ"),"") + iif(lEF2_INVOIC,TMP->EEQ_NRINVO+aArrayEEQ[nI,3],"") ))

         Do While EF2->( !EoF() ) .AND. EF2->EF2_FILIAL == xFilial("EF2") .AND. EF2->EF2_CONTRA == aArrayEEQ[nI,5] .AND.;
                         iif(lTemChave  ,EF2->(EF2_BAN_FI + EF2_PRACA + If(lEFFTpMod,EF2_SEQCNT,"")) == aArrayEEQ[nI,14] + aArrayEEQ[nI,15] + If(lEFFTpMod,aArrayEEQ[nI,21],""),.T.) .AND.;
                         iif(lEF2FilOri ,EF2->EF2_FILORI == xFilial("EEQ"),.T.) .AND.;
                         iif(lEF2_INVOIC,EF2->(EF2_INVOIC + EF2_PARC ) == TMP->EEQ_NRINVO   + aArrayEEQ[nI,03],.T.)

            EF1->( dbSeek(xFilial("EF1")+If(lEFFTpMod,EF2->EF2_TPMODU,"")+aArrayEEQ[nI,5]+aArrayEEQ[nI,14]+aArrayEEQ[nI,15]+If(lEFFTpMod,aArrayEEQ[nI,21],"")) ) //HVR SEEK I OU E //***EF2

            aAdd(aCols, Array( Len(aHeader)+5 ))
            nReg := Len(aCols)

            aCols[nReg][GDFieldPos("EF2_CONTRA")] := aArrayEEQ[nI,5]
            aCols[nReg][GDFieldPos("EF2_BAN_FI")] := EF1->EF1_BAN_FI
            If lTemChave
               aCols[nReg][GDFieldPos("EF3_PRACA")] := EF1->EF1_PRACA

               //** AAF - 21/02/2006 - Adiciona o campo Sequência do contrato na Tela de Vinculação.
               If lEFFTpMod
                  aCols[nReg][GDFieldPos("EF3_SEQCNT")] := EF1->EF1_SEQCNT
               EndIf
               //**
            EndIf
            aCols[nReg][GDFieldPos("EF1_TP_FIN")] := EF1->EF1_TP_FIN+" - "+If(lCadFin,Posicione("EF7",1,xFilial("EF7")+EF1->EF1_TP_FIN,"EF7_DESCRI"),Posicione("SX5",1,xFilial("SX5")+"CG"+EF1->EF1_TP_FIN,"X5_DESCRI"))
            aCols[nReg][GDFieldPos("EF2_TIPJUR")] := EF2->EF2_TIPJUR+" - "+Posicione("SX5",1,xFilial("SX5")+"CV"+EF2->EF2_TIPJUR,"X5_DESCRI")
            aCols[nReg][GDFieldPos("DT_INI")]     := EF2->EF2_DT_INI
            aCols[nReg][GDFieldPos("EF2_DT_FIM")] := EF2->EF2_DT_FIM
            aCols[nReg][GDFieldPos("EF2_TX_FIX")] := EF2->EF2_TX_FIX
            aCols[nReg][GDFieldPos("EF2_TP_VAR")] := EF2->EF2_TP_VAR
            aCols[nReg][GDFieldPos("TX_VAR")]     := EF2->EF2_TX_VAR
            aCols[nReg][GDFieldPos("EF2_TX_DIA")] := EF2->EF2_TX_DIA
            aCols[nReg][GDFieldPos("EF2_USEINV")] := EF2->EF2_USEINV
            // PLB 14/09/06
            //If lEF1_DTBONI
               //aCols[nReg][GDFieldPos("EF2_BONUS")]  := EF2->EF2_BONUS
            //EndIf

            //Marca Recno do EF2
            aCols[nReg][Len(aHeader)+1] := EF2->(RecNo())

            //Marca como não deletado
            aCols[nReg][Len(aHeader)+2] := .F.

            //Campos para controle
            aCols[nReg][Len(aHeader)+3] := TMP->EEQ_FILIAL
            aCols[nReg][Len(aHeader)+4] := TMP->EEQ_NRINVO
            aCols[nReg][Len(aHeader)+5] := TMP->EEQ_PARC

            EF2->( dbSkip() )
         EndDo
      EndIf
   EndIf

Next nI

Return aCols


*--------------------------------------------------------------------------*
// PLB 16/10/06
*--------------------------------------------------------------------------*
Function FAF2AtuFin(nPos,aNfLoteEF3)
*--------------------------------------------------------------------------*

 Local cChave  := ""  ,;
       cSeqEve := ""  ,;
       nRecEF1 := 0   ,;
       aOrdInd := {}
 Local lLogix := FindFunction("EFFEX101")
  Local cInvoice
 Private cTipo := ""

   If lEFFTpMod
      cChave += EF3->EF3_TPMODU
   EndIf
   cChave += EF3->EF3_CONTRA
   If lTemChave
      cChave += EF3->EF3_BAN_FI
      cChave += EF3->EF3_PRACA
   EndIf
   If lEFFTpMod
      cChave += EF3->EF3_SEQCNT
   EndIf

   cSeqEve := EF3->EF3_SEQ
   cInvoice:= EF3->EF3_INVOIC

   aOrdInd := SaveOrd({"EF1","EF3"})
   nRecEF1 := EF1->( RecNo() )

   EF1->( DBSetOrder(1) )
   EF1->(dbSeek(xFilial("EF1")+cChave))

   If AvFlags("SIGAEFF_SIGAFIN") .OR. lLogix
      oEFFContrato := AvEFFContra():LoadEF1()
   EndIf

   EF3->( DBSetOrder(4) )
   EF3->( DBSeek(xFilial("EF3")+cChave+cSeqEve) )

   Do While !EF3->(EOF()) .and. EF3->EF3_FILIAL==xFilial("EF3") .and.;
            If(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3->EF3_CONTRA+iif(lTemChave,EF3->EF3_BAN_FI+EF3->EF3_PRACA+If(lEFFTpMod,EF3->EF3_SEQCNT,""),"")==cChave .And.;
            EF3->EF3_SEQ == cSeqEve  .And.  !( EF3->EF3_CODEVE == EV_ESTORNO )  // PLB 04/07/07

      cMod := IIF(lEFFTpMod,EF1->EF1_TPMODU,EXP)
      EX400AtuSaldos("VIN",,,"EEC")

      If AvFlags("SIGAEFF_SIGAFIN") .OR. lLogix
         oEFFContrato:EventoEF3("ESTORNO")
      EndIf
      If !Empty(EF3->EF3_NRLOTE)
         aAdd(aNfLoteEF3,{EF3->EF3_CODEVE,{EF3->EF3_NRLOTE,EF3->EF3_RELACA,EF3->EF3_NR_CON,EF3->EF3_DT_CTB,EF3->EF3_TX_CTB}})
      EndIf
      EF3->(RecLock("EF3",.F.))
      If !Empty(EF3->EF3_NR_CON) .And. !AvFlags("EEC_LOGIX")
         EF3->EF3_EV_EST := EF3->EF3_CODEVE
         EF3->EF3_DT_EST := dDataBase
         EF3->EF3_CODEVE := EV_ESTORNO
         EF3->EF3_NR_CON := Space(Len(EF3->EF3_NR_CON))
         EF3->(msUnlock())
         // PLB 04/07/07 - Ao alterar o código do evento o registro é desposicionado na tabela devido campo fazer parte da chave
         EF3->( DBSeek(xFilial("EF3")+cChave+cSeqEve) )
      Else
         EF3->(dbDelete())
         EF3->(msUnlock())
         EF3->(dbSkip())
      EndIf
   EndDo

   aArrayEEQ[nPos,16] := EX400GrvEventos(EF1->EF1_CONTRA,cInvoice,M->EEC_PREEMB,aArrayEEQ[nPos,1],dDataBase,;
   M->EEC_MOEDA,aArrayEEQ[nPos,3],EF1->EF1_MOEDA,"EF1","EF3","CAMB",,aArrayEEQ[nPos,11],aArrayEEQ[nPos,10],if(lMultiFil,xFilial("EEQ"),nil),;
   iif(lTemChave,aArrayEEQ[nPos,14],""),iif(lTemChave,aArrayEEQ[nPos,15],""),aArrayEEQ[nPos,19],If(lEFFTpMod,EF1->EF1_TPMODU,),If(lEFFTpMod,aArrayEEQ[nPos,21],),,,,,aArrayEEQ[nPos,22],if(EF3->(FieldPos("EF3_DTDOC"))>0,aArrayEEQ[nPos,24],),,aNfLoteEF3)//FSY - 19/06/2013 Adicionado novo campo EF3_DTDOC

   RestOrd(aOrdInd)
   EF1->( DBGoTo(nRecEF1) )

   If AvFlags("SIGAEFF_SIGAFIN") .OR. lLogix
      oEFFContrato:EventoFinanceiro("ATUALIZA_PROVISORIOS")
      oEFFContrato:ShowErrors()
   EndIf

Return

Function FAF200BusSeq()
Local nSeq := 1

Do While aScan(aArrayEEQ,{|X| x[8] == nSeq}) > 0
    nSeq++
EndDo

Return nSeq


Static Function VldVincCtb(dDtVincula)
Local lRet := .T.
   If !Empty(EF1->EF1_DT_CTB) .And. !Empty(dDtVincula) .And. EF1->EF1_DT_CTB <> EF1->EF1_DT_JUR .And. dDtVincula <= EF1->EF1_DT_CTB .And.;
      !MsgYesNo(STR0103 + TransForm(EF1->EF1_DT_CTB,"@D")+". " + STR0104,STR0003)//"Este contrato foi contabilizado em #### "Tem certeza que deseja vincular uma invoice com data igual ou anterior a esta contabilização?" #### Atenção
      lRet := .F.
   EndIf
Return lRet