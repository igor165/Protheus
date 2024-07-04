#Include "Average.CH"
#Include "EICDI501.CH"
#Include "FWBROWSE.CH"

#define MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)
#define COLUNA_FINAL   (oDlg:nClientWidth-4)/2
#define COLUNA_FINAL_I (oDlgItens:nClientWidth-4)/2
#define FECHTO_EMBARQUE       "1"
#define FECHTO_DESEMBARACO    "2"
#define FECHTO_NACIONALIZACAO "3"
#define FINALIZAR (nOpca:=1,If(ValType(oDlg) == "O",oDlg:End(),oDLGBACK:End()))
#define VISUAL    2
#define INCLUSAO  3
#define ALTERACAO 4
#define ESTORNO   5
#define ENCERRAR  6 // Acb - 22/10/2010 - Melhoria para cancelamento do desembaraço em casa de estravio de mercadoria.
#define ENTER CHR(10)+CHR(13)
#define SIM     "1"
#define NAO     "2"
#define GENERICO     "06"
#define NCM_GENERICA "99999999"

/*
Programa   : EICDI501
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em funções que não estão
             definidas em um programa com o mesmo nome da função.
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 25/04/07 11:46:07
Obs.       : Criado com gerador automático de fontes
*/


/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Chamada da função MenuDef no programa onde a função está declarada.
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 25/04/07 11:46:07
*/
Static Function MenuDef()

Local aRotina := {} 
Local cStaticCall := 'StaticCall(EICDI500, MenuDef)'

Private cAvStaticCall := "EICDI501"

Return &cStaticCall


/*
Funcao      : DI501DigItem()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
Function DI501DigItem(oBrw) // Antiga DI_DigItem(oBrw)// by CAF 29/10/1998
#xTranslate AVPic(<Cpo>) => AllTrim(X3Picture(<Cpo>))
Local oDlg, nOpcA

Local aValid := {"COD_I","QTDE","PRECO"}
Local bValid := {|| aScan(aValid,{|x| !DI500DigVal(x)})==0 }
Local nRec_Work := Work->(Recno()), nOrd_Old
Local lEstavaMarcado := .F.

Local cCod_I_Old, nQtde_Old
Local oCod, oQtd, oItem
Local nQtdeAtualizada := 0

cCod_I_Old := cDigCod_I
nQtde_Old  := nDigQtde

DO While .T.
   cDigCod_I := CriaVar("W7_COD_I")
   nDigQtde  := CriaVar("W7_QTDE")
// nDigPreco := CriaVar("W7_PRECO")

   nOpcA := 0
   DEFINE MSDIALOG oDlg TITLE STR0002 From 50,46 To 72,88 OF oMainWnd //"Seleção de Itens por Digitação"

   oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 91, 165)
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   @ 20,08 TO 58,160 LABEL STR0003 OF oPanel PIXEL //"Último item:"
   @ 26,10 SAY AVSX3("W7_COD_I",5)   OF oPanel PIXEL //'Codigo Item'
   @ 39,10 SAY AVSX3("W7_SALDO_Q",5) OF oPanel PIXEL //'Saldo Qtde'


   @ 26,45 MSGET oCod VAR cCod_I_Old PICT AVPic("B1_COD") F3 "SB1" SIZE 114,9 OF oPanel PIXEL
   oCod:Disable()
   @ 39,45 MSGET oQtd VAR nQtde_Old  PICT AVPic("W7_QTDE") SIZE 114,9 OF oPanel PIXEL
   oQtd:Disable()

   @ 071,8  TO 110,160 LABEL STR0004  OF oPanel PIXEL //"Próximo item:"
   @ 078,10 SAY AVSX3("W7_COD_I",5)   OF oPanel PIXEL //'Codigo Item'
   @ 091,10 SAY AVSX3("W7_SALDO_Q",5) OF oPanel PIXEL //'Saldo Qtde'

   @ 78,45 MSGET oItem VAR cDigCod_I F3 "SB1" PICT AVPic("B1_COD") ;
         VALID (DI500DigVal("COD_I")) SIZE 114,9 OF oPanel PIXEL

   @ 91,45 MSGET nDigQtde  PICT AVPic("W7_QTDE");
         VALID (DI500DigVal("QTDE"))  SIZE 114,9 OF oPanel PIXEL

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,; //MCF - 22/07/2016 - Alteração de Enchoicebar
                                  {|| IF(Eval(bValid),(nOpcA:=1,oDlg:End()),)},;
                                  {|| nOpcA:=0, oDlg:End()}) CENTERED

   IF nOpcA == 0
      cDigCod_I := cCod_I_Old
      nDigQtde  := nQtde_Old
      Exit
   Endif
   lGravaSoCapa:=.F.

   cCod_I_Old := cDigCod_I
   nQtde_Old  := nDigQtde

   nOrd_Old := Work->(IndexOrd())
   Work->(dbSetOrder(4)) // WKCOD_I+DTOS(WKDT_EMB)
   Work->(dbGoTop())
   Work->(dbSeek(cDigCod_I))

   DO While !Work->(Eof()) .And. Work->WKCOD_I==cDigCod_I .And.;
         nDigQtde > 0

      lEstavaMarcado := Work->WKFLAG
      nQtdeAtualizada:= 0

      Work->WK_ALTEROU := .T.

      If nDigQtde > Work->WKSALDO_Q
         nDigQtde -= Work->WKSALDO_Q

         IF lEstavaMarcado
            M->W6_PESOL     -= Work->WKPESO_L * Work->WKQTDE
            IF M->W6_PESOL < 0
               M->W6_PESOL := 0
            ENDIF
            Work->WKQTDE    += Work->WKSALDO_Q
         Else
            Work->WKQTDE    := Work->WKSALDO_Q
         Endif

         nQtdeAtualizada := Work->WKSALDO_Q
         Work->WKSALDO_Q := 0
      Else
         Work->WKSALDO_Q -= nDigQtde

         If lEstavaMarcado
            M->W6_PESOL     -= Work->WKPESO_L * Work->WKQTDE
            IF M->W6_PESOL < 0
               M->W6_PESOL := 0
            ENDIF
            Work->WKQTDE    += nDigQtde
            nQtdeAtualizada := nDigQtde
         Else
            Work->WKQTDE    := nDigQtde
         Endif

         nQtdeAtualizada := nDigQtde
         nDigQtde := 0
      Endif

      Work->WKQTDE_D  := Work->WKQTDE
      Work->WKFLAG    := .t.
      Work->WKFLAGWIN := cMarca
      M->W6_PESOL     += Work->WKPESO_L * Work->WKQTDE
      WORK->WKDISPINV := Work->WKQTDE
      DI500Controle(1)

      Work->(dbSkip())
   EndDO

   Work->(dbSetOrder(nOrd_Old))
   Work->(dbGoTop())
   Work->(dbGoTo(nRec_Work))

EndDO
IF oBrw # NIL
   oBrw:Refresh()
   oBrw:Reset()
ENDIF
Return .T.

/*
Funcao      : DI501DigVal()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
Function DI501DigVal(cCpo)

Local nRec_Work := Work->(Recno())
Local nOrd_Old  := Work->(IndexOrd())
Local nSaldo  := 0
Local lOk := .f.
Local lAltPreco := .t., nPreco := 0
Local cPO  := Work->WKPO_NUM
Local cPLI := Work->WKPGI_NUM

DO CASE
   CASE cCpo == "COD_I"
      IF EMPTY(cDigCod_I)
         Return .T.
      ENDIF
      If ! ExistCpo("SB1",cDigCod_I)
         Return .F.
      Endif

      Work->(dbSetOrder(4)) // WKCOD_I+DTOS(WKDT_EMB)
      Work->(dbGoTop())
      Work->(dbSeek(cDigCod_I))

      DO While !Work->(Eof()) .And. Work->WKCOD_I == cDigCod_I
         nSaldo += Work->WKSALDO_Q
         lOk := .T.

         IF Work->WKPO_NUM == cPO .And. Work->WKPGI_NUM == cPLI
            nPreco := Work->WKPRECO
         ENDIF

         If Work->WKFLAG
            lAltPreco := .F.
         ENDIF

         If nSaldo > 0
            IF !lAltPreco
               Exit
            ENDIF
         Endif

         Work->(dbSkip())
      End

      Work->(dbSetOrder(nOrd_Old))
      Work->(dbGoTop())
      Work->(dbGoTo(nRec_Work))

      If ! lOk
         Help("", 1, "AVG0000281")//Item nao cadastrado para este pedido !
         Return .F.
      Endif

      If nSaldo <= 0
         Help("", 1, "AVG0000282")//Nao ha saldo disponivel para este item !
         Return .F.
      Endif

//    IF Empty(nDigPreco)
//       nDigPreco := nPreco
//    ENDIF

//    IF !lAltPreco
//       oPreco:Disable()
//    ENDIF

//    oPreco:Refresh()


   CASE cCpo == "QTDE"
      If !NaoVazio(nDigQtde) .Or. !Positivo(nDigQtde)
         Return .f.
      Endif

      Work->(dbSetOrder(4)) // WKCOD_I+DTOS(WKDT_EMB)
      Work->(dbGoTop())
      Work->(dbSeek(cDigCod_I))

      DO While !Work->(Eof()) .And. Work->WKCOD_I == cDigCod_I
         nSaldo += Work->WKSALDO_Q
         Work->(dbSkip())
      ENDDO

      Work->(dbSetOrder(nOrd_Old))
      Work->(dbGoTop())
      Work->(dbGoTo(nRec_Work))

      If nSaldo < nDigQtde
          Help("", 1, "AVG0000283")//"Quantidade digitada e maior que o saldo atual deste item !
         Return .F.
      Endif

// CASE cCpo == "PRECO"
//    If !NaoVazio(nDigPreco) .Or. !Positivo(nDigPreco)
//       Return .f.
//    Endif

ENDCASE

Return .t.

/*
Funcao      : DI501GravaTudo()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
FUNCTION DI501GravaTudo()//Antiga DI_GRAVA do EIC.PRW

LOCAL cDesc:=IF(MOpcao # FECHTO_EMBARQUE,STR0005,STR0006)//'Desembaraco'###'Embarque'
LOCAL nDespDa:=0,nOrdSW9:=SW9->(INDEXORD())
LOCAL nDesp:=0
LOCAL nI  //igor chiba 02/07/14
LOCAL nRecSw6
//, nREcSW6:=SW6->(RECNO())   //ACSJ - 24/05/2004
LOCAL aPos_Lidos:={},nValorSWD:=0, P, i, _nx, iDA
Local nRecSW1, nOrdSW1, lResp // RA - 04/11/03 - O.S. 1117/03
Local nRecSA5, nOrdSA5, lExistA5PESO, cEasy := EasyGParam("MV_EASY") // RA - 12/01/04 - O.S. 0038/04
LOCAL ldataEMB := !EMPTY(GetNewPar("MV_DTB_APD",""))
LOCAL lSW9 := .F.
LOCAL dDtEmbG := CTOD("")
LOCAL dDtEmbM := CTOD("")
Local aOrdSW5 :={}
Local aOrdSW8 :={}
// TLM 20/05/2008 - Tratamento do rateio das despesas da DA
Local nVlrDA, nVlDins
Local nDinAtu:= nPesDinAtu := 0   //NCF - 09/12/2010 - Variável para rateio das despesas da DA
Local aTotDesp:={}
Local aTotDespDa:={}
Local aDa:={}
Local aAuxHawb:={},cAuxW6:=""
Local aChaves := {}   //GFP - 21/05/11 - WORKFLOW
Local nRegisSW3 := nOrdemSW3 := 0 //NCF - 22/03/2011
Local lPLIAntes := .F. //FSM - 22/05/2012
If Type("lDI500GrvSW6") = "U"
   Private lDI500GrvSW6 := .F.
EndIf

//** GFC - 28/11/05 - Câmbio de frete, seguro, comissão e embarque
Private lAltFrete:=.F., lAltSeg:=.F.
//**

PRIVATE aDespDa:={},aTaxas:={} // LDR
Private aPesoDrawback:= {} //AAF 14/07/05
Private nRateioDesp:=0,nVlrSWD:=0 // RJB 03/10/2005

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"INICIO_GRAVATUDO"),) // LDR

If AvFlags("WORKFLOW")
   aChaves := EasyGroupWF("EMBARQUE_EIC")
EndIf

SX3->(DBSETORDER(2))
lExistA5PESO := SX3->(DBSEEK("A5_PESO")) // RA
SX3->(DBSETORDER(1))

// RA - 31/10/03 - O.S. 1110/03 - Inicio
If GetNewPar("MV_ATUPESO",.F.) .And. ("DI" $ GetNewPar("MV_PESOW57","LI"))
   If cEasy $ cSim // RA
      lResp := MsgYesNo(STR0007, STR0001)  // "Deseja atualizar o peso líquido do Cadastro de Produtos ? "###"Atenção"
   Else
      lResp := .T.
   EndIf
Else
   lResp := .F.
EndIf
// RA - 31/10/03 - O.S. 1110/03 - Final

DBSELECTAREA("Work")
SET FILTER TO
Work->(DBSETORDER(3))

cPO_NUM := SPACE(07)
ProcRegua(Work->(EasyReccount("Work"))+LEN(aPli)+2)

SWD->(DBSETORDER(1))
SW2->(DBSETORDER(1))
SW7->(DBSETORDER(1))
SW9->(DBSETORDER(3))
Work->(DBGOTOP())   // Pega as taxas , para calculo do rateio
If MOpcao == FECHTO_NACIONALIZACAO
   DO WHILE Work->(!EOF())
      IF SW2->(DBSEEK(xFilial("SW2")+Work->WKPO_NUM)) .AND. ! EMPTY(ALLTRIM(SW2->W2_HAWB_DA))
         IF ASCAN(aPos_Lidos,Work->WKPO_NUM)<> 0
            Work->(DBSKIP())
            LOOP
         ENDIF
      ELSE
         Work->(DBSKIP())
         LOOP
      ENDIF
      SW9->(DBSEEK(xFilial("SW9")+SW2->W2_HAWB_DA))
      DO WHILE ! SW9->(EOF()) .AND. SW9->W9_HAWB == SW2->W2_HAWB_DA
         nInd:=ASCAN(aTaxas,{|y| y[1] == SW9->W9_HAWB .AND. y[2] == SW9->W9_MOE_FOB})
         IF nInd == 0
            AADD(aTaxas, { SW9->W9_HAWB, SW9->W9_MOE_FOB, SW9->W9_TX_FOB } )
         ENDIF
         SW9->(DBSKIP())
      ENDDO
      Work->(dbskip())
   ENDDO
   SW9->(DBSETORDER(nOrdSW9))
Endif

//ASK 02/08/2007 - Trata o parâmetro MV_DTB_APD que define a data de vencimento do cambio/título e depois compara
//o que está gravado com o da Memória/Work para saber se houve alteração.

   IF !lDataEMB
      cDatEmb := "SW6->W6_DT_EMB"
   ELSE
      cDatEmb := ALLTRIM(GetNewPar("MV_DTB_APD","SW6->W6_DT_EMB"))
   ENDIF

   If Left(cDatEmb,5) == "SW6->"  //Caso o conteúdo do parâmetro possuir o Alias do Campo "SW6->"
      dDtEmbG:= &(cDatEmb)
      dDtEmbM:= &("M->" + Right(cDatEmb,Len(cDatEmb)-5))
   ElseIf Left(cDatEmb,3) == "W6_" // Ou só o campo
      dDtEmbG := &("SW6->" + cDatEmb )
      dDtEmbM := &("M->" + cDatEmb )
   Else
      lSW9 := .T.
   EndIf

   Work_SW9->(DbGoTop())
   Begin Sequence
   //Se o campo do parametro for da tabela SW9, verifica-se invoice por invoice até achar uma alteração
   SW9->(DbSetOrder(3))
   SW9->(DBSEEK(xFilial("SW9")+M->W6_HAWB))
   Do While !Work_SW9->(EOF()) .And. lSW9
      Do WHILE SW9->W9_HAWB == M->W6_HAWB .AND. SW9->W9_INVOICE == Work_SW9->W9_INVOICE

         If Left(cDatEmb,5) == "SW9->" //Caso o conteúdo do parâmetro possuir o Alias do Campo "SW6->"
            dDtEmbG:= &(cDatEmb)
            dDtEmbM:= &("Work_SW9->" + Right(cDatEmb,Len(cDatEmb)-5))
         ElseIf Left(cDatEmb,3) == "W9_" //Ou só o campo
            dDtEmbG := &("SW9->" + cDatEmb )
            dDtEmbM := &("Work_SW9->" + cDatEmb )
         EndIf
         IF dDtEmbG # dDtEmbM
            Break
         ENDIF
         SW9->(DbSkip())
      EndDo
      Work_SW9->(DbSkip())
   EndDo
   End Sequence
   SW9->(DbSetOrder(1))

   IF EMPTY(dDtEmbG) .And. EMPTY(dDtEmbM)
      dDtEmbG  := SW6->W6_DT_EMB
      dDtEmbM  := M->W6_DT_EMB
      IF EMPTY(dDtEmbG) .And. EMPTY(dDtEmbM)
   	     dDtEmbG  := SW6->W6_DT_ETA
         dDtEmbM  := M->W6_DT_ETA
   	  ENDIF
   ENDIF
//Verifica se base está diferente de memória, se sim, gera novamente.
//** GFC - Câmbio de frete, seguro e comissão
If lWB_TP_CON .and. lGravaFin_EIC .and. !Inclui .and.;
(M->W6_FORNECF<>SW6->W6_FORNECF .or. M->W6_FREMOED<>SW6->W6_FREMOED .or. M->W6_VLFRECC<>SW6->W6_VLFRECC .or.;
M->W6_VENCFRE<>SW6->W6_VENCFRE .or. M->W6_CONDP_F<>SW6->W6_CONDP_F .or. M->W6_DIASP_F<>SW6->W6_DIASP_F .or.;
dDtEmbM <> dDtEmbG)
   lAltFrete := .T.
EndIf
If lGravaFin_EIC .and. !Inclui .and.;
(M->W6_FORNECS<>SW6->W6_FORNECS .or. M->W6_SEGMOED<>SW6->W6_SEGMOED .or. M->W6_VL_USSE<>SW6->W6_VL_USSE .or.;
M->W6_VENCSEG<>SW6->W6_VENCSEG .or. M->W6_CONDP_S<>SW6->W6_CONDP_S .or. M->W6_DIASP_S<>SW6->W6_DIASP_S .or.;
dDtEmbM <> dDtEmbG)
   lAltSeg := .T.
EndIf
//**
lChangeEmb := (nOPC_mBrw == 3 .AND. !EMPTY(M->W6_DT_EMB)) .OR.  (nOPC_mBrw <> 3 .AND. M->W6_DT_EMB <> SW6->W6_DT_EMB) //IGOR CHIBA 02/07/14 se for inclusao e data preenchida ou data tiver alterada

//INICIA O CONTROLE DE TRANSACAO
Begin Transaction //LRS - 12/07/2017

   cRegDI := If(Empty(SW6->W6_DI_NUM),"N","S") //AAF 12/09/05 - Flag indica se há registro de DI.
   lAltDtReg := ( cRegDI == "S"  .And.  !Empty(M->W6_DTREG_D)  .And.  M->W6_DTREG_D != SW6->W6_DTREG_D )  // PLB 19/12/06
   E_Grava("SW6",(!lExiste))  //GFC 22/12/03 - Integridade Referencial.
   lExiste:=.T.
   nREcSW6:=SW6->(RECNO())
   aOrdSW8 := SaveOrd("SW8")
   aOrdSW5 := SaveOrd("SW5")
   AADD(aAuxHawb,M->W6_HAWB)
   nVlDins := 0

   Work->(DBGOTOP())
   DO WHILE Work->(!EOF())

      IncProc(STR0008 + ALLTRIM(Work->WKCOD_I)) //"Lendo itens da D.I.: "

      //FSM - 22/05/2012
      lPLIAntes := DI500PLIAntes()

      If MOpcao == FECHTO_NACIONALIZACAO

         /*TLM 20/05/2008 - Tratamento que permite incluir novas despesas em um DA que já possui pelo menos um DI's
                             Rateio da despesa para as DI's que ainda não foram encerradas.*/
         If Empty(M->W6_DT_ENCE)
            SW5->(DbSetOrder(8))
            If SW5->(DbSeek(xFilial("SW5") + Work->WKPGI_NUM + Work->WKPO_NUM )) // Posiciona na DA
               While SW5->(!Eof()) .And. (xFilial("SW5") == SW5->W5_Filial) .And. (Work->WKPGI_NUM == SW5->W5_PGI_NUM) .And. ;
               (Work->WKPO_NUM == SW5->W5_PO_NUM)
                  If !Empty(SW5->W5_HAWB) .And. SW5->W5_SEQ <> 0
                     If (ASCAN(aAuxHawb,{|x| x== SW5->W5_HAWB})) = 0
                        AADD(aAuxHawb,SW5->W5_HAWB)
                        If SW6->(DbSeek(xFilial("SW6")+SW5->W5_HAWB))//JVR - 14/01/2010
                        //While SW6->(!EOF()) .And. xFilial("SW6") == SW5->W5_Filial .And. SW6->W6_HAWB == SW5->W5_HAWB
                           IF !Empty(SW6->W6_DT_ENCE) .And. SW6->W6_HAWB <> cAuxW6 // Entra apenas uma vez por processo.
                              SW8->(DbSetOrder(1))
                              If SW8->(DBSEEK(xFilial("SW8")+SW6->W6_HAWB))

                                 DO WHILE ! SW8->(EOF()) .AND. SW8->W8_HAWB == SW6->W6_HAWB

                                    If SW2->(DBSEEK(xFilial("SW2") + SW8->W8_PO_NUM)) .AND. ! EMPTY(ALLTRIM(SW2->W2_HAWB_DA))
                                       nInd:=ASCAN(aTaxas,{|y| y[1] == SW2->W2_HAWB_DA .AND. y[2] == SW2->W2_MOEDA})
                                       IF nInd == 0
                                          cHelp:=SW2->W2_MOEDA+" / "+ALLTRIM(SW2->W2_HAWB_DA)
                                          Help("",1,"AVG0000730",,cHelp,4,0)
                                          //MSGINFO("A cotacao da moeda.: " + SW2->W2_MOEDA + " para o processo.: " + SW2->W2_HAWB_DA + " Nao foi encontrada" +;
                                          //        "O rateio das despesas nao podera ser efetuado")
                                          EXIT
                                       ENDIF

                                       nVlDins += (SW8->W8_PRECO * SW8->W8_QTDE) * aTaxas[nInd,3]

                                    Endif
                                    SW8->(DBSKIP())

                                 ENDDO

                                 cAuxW6:=SW6->W6_HAWB
                                 SWD->(DbSetOrder(1))
                                 If SWD->(DbSeek(xFilial("SWD")+SW6->W6_HAWB))
                                    While SWD->(!Eof()) .And. (xFilial("SWD") == SWD->WD_Filial) .And. (SWD->WD_HAWB == SW6->W6_HAWB)
                                       If !(Substr(SWD->WD_DESPESA,1,1) $ "1279") .And. SWD->WD_DA == "1"
                                          nPos := aScan(aTotDesp,{ |x| x[2] == SWD->WD_DESPESA .AND. x[4] == SWD->WD_DES_ADI })
                                          If nPos > 0
                                             aTotDesp[nPos][3] += SWD->WD_VALOR_R // TLM - À partir da segunda DI encerrada as despesas são somadas pelo código e posição no array.
                                          Else
                                             Aadd(aTotDesp,{ SWD->WD_HAWB, SWD->WD_DESPESA, SWD->WD_VALOR_R, SWD->WD_DES_ADI }) // TLM - aTotDesp recebe todas as despesas por linha da DI encerrada.
                                          EndIf
                                      EndIf
                                      SWD->(DbSkip())
                                    EndDo
                                 EndIf

                              EndIf
                           Endif
                        //SW6->(DbSkip())
                        //EndDo
                        EndIf
                     EndIf
                  EndIf
               SW5->(DbSkip())
               EndDo
            EndIf
            SW6->(DBGOTO(nREcSW6))

            If SW2->(DBSEEK(xFilial("SW2") + Work->WKPO_NUM)) .AND. ! EMPTY(ALLTRIM(SW2->W2_HAWB_DA))
               nInd:=ASCAN(aTaxas,{|y| y[1] == SW2->W2_HAWB_DA .AND. y[2] == SW2->W2_MOEDA})
               IF nInd == 0
                  cHelp:=SW2->W2_MOEDA+" / "+ALLTRIM(SW2->W2_HAWB_DA)
                  Help("",1,"AVG0000730",,cHelp,4,0)
                  //MSGINFO("A cotacao da moeda.: " + SW2->W2_MOEDA + " para o processo.: " + SW2->W2_HAWB_DA + " Nao foi encontrada" +;
                  //        "O rateio das despesas nao podera ser efetuado")
                  EXIT
               ENDIF
               If !Empty(WORK->WKFLAGWIN)
                  nDinAtu += (WORK->WKPRECO * WORK->WKQTDE) * aTaxas[nInd,3]
                  nPesDinAtu +=  WORK->WKPESO_L * WORK->WKQTDE               //NCF - 09/12/2010 - Apura peso para rateio das despesas da DA
               Endif

               IF ASCAN(aDA,{|x|x==SW2->W2_HAWB_DA}) = 0
                  AADD( aDA, SW2->W2_HAWB_DA)
               ENDIF
            ENDIF
         Endif
      EndIf

      IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GRAVA_ANTES_LOOP_FLAG"),)

      IF !Work->WK_ALTEROU
         Work->(DBSKIP())
         LOOP
      ENDIF

      IF Work->(!WKFLAG) .AND. Work->(!WKFLAG2)
         Work->(DBSKIP())
         LOOP
      ENDIF

      IF Work->(!WKFLAG2)

         MSeq := 0
         IF !lMV_SLD_EMB
            DI400IdAtuSld("1")
         ELSE
            nSaldo_Li:=0
            IF PosOrd1_IT_Guias(WORK->WKPGI_NUM,Work->WKCC,Work->WKSI_NUM,;
                                Work->WKCOD_I,Work->WKFABR,Work->WKFORN  ,;
                                Work->WKREG,0,Work->WKPO_NUM, EICRetLoja("Work", "W7_FABLOJ"), EICRetLoja("Work", "W7_FORLOJ"))

                SW5->(RecLock("SW5",.F.,.T.))
                IF SW5->W5_SALDO_Q > Work->WKQTDE
                   SW5->W5_SALDO_Q:=SW5->W5_SALDO_Q - Work->WKQTDE
                ELSE
                   nSaldo_Li:=SW5->W5_SALDO_Q
                   SW5->W5_SALDO_Q:=0
                ENDIF
                SW5->(MsUnlock())
             ENDIF
         ENDIF
         //NCF - 22/03/2011 - Item anuente com LI do Embarque no PN (Inclusão)
         IF MOpcao == FECHTO_NACIONALIZACAO .And. Work->WKFLUXO == "1" .And. lPLIAntes //FSM - 22/05/2012
            nRegisSW3 := SW3->(RECNO())
            nOrdemSW3 := SW3->(INDEXORD())
            SW3->(DbSetOrder(8))
            SW3->(DBSeek(xFilial("SW3")+Work->WKPO_NUM+Work->WKPOSICAO))
            DI400POSld( "1", Work->WKSALDO_Q-WORK->WKSALDO_O, .T. )
            SW3->(DbSetOrder(nOrdemSW3))
            SW3->(DbGoTo(nRegisSW3))
         ENDIF

         MSeq := MSeq + 1
         SW5->(RecLock("SW5",.T.))// lock com append
         SW5->W5_SEQ_LI   :=   Work->WKSEQ_LI  //FCD 31/10/01
         SW5->W5_COD_I    :=   Work->WKCOD_I
         SW5->W5_FABR     :=   Work->WKFABR
         SW5->W5_FORN     :=   Work->WKFORN

         SW5->W5_FABLOJ := Work->W7_FABLOJ
         SW5->W5_FORLOJ := Work->W7_FORLOJ

         SW5->W5_FLUXO    :=   Work->WKFLUXO
         SW5->W5_QTDE     :=   Work->WKQTDE
         SW5->W5_PRECO    :=   Work->WKPRECO
         SW5->W5_SALDO_Q  :=   0
         SW5->W5_HAWB     :=   M->W6_HAWB
         SW5->W5_SI_NUM   :=   Work->WKSI_NUM
         SW5->W5_PO_NUM   :=   Work->WKPO_NUM
         SW5->W5_PGI_NUM  :=   Work->WKPGI_NUM
         SW5->W5_NBM      :=   Work->WKNBM
         SW5->W5_DT_EMB   :=   Work->WKDT_EMB
         SW5->W5_DT_ENTR  :=   Work->WKDT_ENTR
         SW5->W5_SEQ      :=   MSeq
         SW5->W5_CC       :=   Work->WKCC
         SW5->W5_REG      :=   Work->WKREG
         SW5->W5_DOCTO_F  :=   Work->WKDOCTO_F
         SW5->W5_FILIAL   :=   xFilial("SW5")
         SW5->W5_POSICAO  :=   Work->WKPOSICAO
         SW5->W5_PESO     :=   Work->WKPESO_L
         SW5->W5_EX_NCM   :=   Work->WKEX_NCM
         SW5->W5_EX_NBM   :=   Work->WKEX_NBM

         IF lMV_SLD_EMB .AND. !EMPTY(nSaldo_Li)
            SW5->W5_QTDE  :=   nSaldo_Li
         ENDIF

         IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GRAVA_INCLUI_SW5"),)
         SW5->(MSUnlock())

         SW7->(RecLock("SW7",.T.))  // lock com append   GFC 22/12/03 - Passado para baixo para Integridade Referencial.
         AVREPLACE("Work","SW7")
         SW7->W7_FILIAL   :=   xFilial("SW7")
         SW7->W7_HAWB     :=   M->W6_HAWB
         SW7->W7_COD_I    :=   Work->WKCOD_I
         SW7->W7_FABR     :=   Work->WKFABR
         SW7->W7_FORN     :=   Work->WKFORN
         SW7->W7_FLUXO    :=   Work->WKFLUXO
         SW7->W7_QTDE     :=   Work->WKQTDE
         SW7->W7_PRECO    :=   Work->WKPRECO
         SW7->W7_SALDO_Q  :=   Work->WKQTDE
         SW7->W7_SI_NUM   :=   Work->WKSI_NUM
         SW7->W7_PO_NUM   :=   Work->WKPO_NUM
         SW7->W7_PGI_NUM  :=   Work->WKPGI_NUM
         SW7->W7_SEQ      :=   0
         SW7->W7_REG      :=   Work->WKREG
         SW7->W7_CC       :=   Work->WKCC
         SW7->W7_SEQ_LI   :=   Work->WKSEQ_LI
         SW7->W7_POSICAO  :=   Work->WKPOSICAO
         SW7->W7_PESO     :=   Work->WKPESO_L
         SW7->W7_NCM      :=   Work->WKTEC
         SW7->W7_EX_NCM   :=   Work->WKEX_NCM
         SW7->W7_EX_NBM   :=   Work->WKEX_NBM
         SW7->W7_OPERACA  :=   Work->WKOPERACA
         SW7->W7_VLR_IPI  :=   Work->WKIPIPAUTA

         //FSM - 31/08/2011 - "Peso Bruto Unitário"
         If lPesoBruto
            SW7->W7_PESO_BR := Work->WKW7PESOBR
         EndIf

         SW7->W7_FABLOJ := Work->W7_FABLOJ
         SW7->W7_FORLOJ := Work->W7_FORLOJ

         If lExiste_Midia .AND. lPesoMid   // LDR - 24/08/04
            SW7->W7_PESOMID  :=   Work->WKPESOMID
         ENDIF
         If lInvAnt //DRL - 16/09/09 - Invoices Antecipadas
            SW7->W7_INVOICE := WORK->WKINVOICE
         EndIf

         IF ascan(aEnv_PO,SW7->W7_PO_NUM + SW7->W7_POSICAO) == 0
            aadd(aEnv_PO,SW7->W7_PO_NUM + SW7->W7_POSICAO)
         ENDIF

         IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GRAVA_INCLUI_SW7"),)

         SW7->(MSUnlock())

      ELSE

         IF !Work->(WKFLAG)

            IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"DELETA_SW3_SW5"),)

            SW7->(DBGOTO( Work->WKRECNO_ID ))

            //** AAF 14/07/05 - Utilizar o Peso de item estornado ao voltar o saldo do A.C.
            If lIntDraw
               aOrdW8:= SaveOrd({"SW8"})

               SW8->( dbSetOrder(3) )
               If SW8->( dbSeek(cFilSW8+SW7->( W7_HAWB+W7_PGI_NUM+W7_PO_NUM+W7_SI_NUM+W7_CC+W7_COD_I+STR(W7_REG, 4, 0) )) ) .AND.;
                  !Empty(SW8->W8_AC)

                  aAdd(aPesoDrawback,{SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM, SW7->W7_PESO} )
               Endif

               RestOrd(aOrdW8)
            Endif
            //**
            IF ascan(aEnv_PO,SW7->W7_PO_NUM + SW7->W7_POSICAO) == 0
               aadd(aEnv_PO,SW7->W7_PO_NUM + SW7->W7_POSICAO)
            ENDIF

            SW7->(RecLock("SW7",.F.,.T.))
            SW7->(DBDELETE())
            SW7->(MSUnlock())

            IF PosOrd2_IT_Guias(M->W6_HAWB,Work->WKCC,Work->WKSI_NUM,Work->WKCOD_I ,;
                                Work->WKFABR,Work->WKFORN,Work->WKREG,Work->WKPGI_NUM,Work->WKPO_NUM,Work->WKPOSICAO, EICRetLoja("Work", "W7_FABLOJ"), EICRetLoja("Work", "W7_FORLOJ"))

                nSaldo_LI:=SW5->W5_QTDE
                SW5->(RecLock("SW5",.F.,.T.))
                SW5->(DBDELETE())
                SW5->(MSUnlock())
            ENDIF

            IF !lMV_SLD_EMB
               DI400IdAtuSld("2")
            ELSE
               IF Work->WKSALDO_O <= SW5->W5_QTDE // CASO A QUANTIDADE DO ITEM SEJA MAIOR QUE A DA PLI , NAO ATUALIZAR A QUANTIDADE NEM O SALDO NAO FICAR NEGATIVO
                  DI400IdAtuSld("2")
               ELSE
                  IF PosOrd1_IT_Guias(WORK->WKPGI_NUM,Work->WKCC,Work->WKSI_NUM,;
                                       Work->WKCOD_I,Work->WKFABR,Work->WKFORN  ,;
                                       Work->WKREG,0,Work->WKPO_NUM, EICRetLoja("Work", "W7_FABLOJ"), EICRetLoja("Work", "W7_FORLOJ"))

                      SW5->(RecLock("SW5",.F.,.T.))
                      SW5->W5_SALDO_Q:=SW5->W5_SALDO_Q + nSaldo_LI

                      SW5->(MsUnlock())
                   ENDIF
                ENDIF
             ENDIF

            //NCF - 22/03/2011 - Item anuente com LI do Embarque no PN (Estorno)
            IF MOpcao == FECHTO_NACIONALIZACAO .And. lPLIAntes //FSM - 22/05/2012
               nRegisSW3 := SW3->(RECNO())
               nOrdemSW3 := SW3->(INDEXORD())
               SW3->(DbSetOrder(8))
               SW3->(DBSeek(xFilial("SW3")+Work->WKPO_NUM+Work->WKPOSICAO))
               IF SW3->(!EOF()) .And. SW3->W3_FLUXO == "1"
                  DI400POSld( "1" , Work->WKSALDO_O , .T. )
               ENDIF
               SW3->(DbSetOrder(nOrdemSW3))
               SW3->(DbGoTo(nRegisSW3))
            ENDIF

         ELSE

            IF Work->WKQTDE > Work->WKQTDEDORI .OR. Work->WKQTDE < Work->WKQTDEDORI

               SW7->(DBGOTO(Work->WKRECNO_ID))
               SW7->(RecLock("SW7",.F.))
               IF (SW7->W7_QTDE <> Work->WKQTDE)
                  IF ascan(aEnv_PO,SW7->W7_PO_NUM + SW7->W7_POSICAO) == 0
                     aadd(aEnv_PO,SW7->W7_PO_NUM + SW7->W7_POSICAO)
                  ENDIF
               ENDIF

               IF Work->WKQTDE > Work->WKQTDEDORI
                  SW7->W7_QTDE   := SW7->W7_QTDE    + ( Work->WKQTDE - Work->WKQTDEDORI )
                  SW7->W7_SALDO_Q:= SW7->W7_SALDO_Q + ( Work->WKQTDE - Work->WKQTDEDORI )
               ELSE
                  SW7->W7_QTDE   := SW7->W7_QTDE    - ( Work->WKQTDEDORI - Work->WKQTDE )
                  SW7->W7_SALDO_Q:= SW7->W7_SALDO_Q - ( Work->WKQTDEDORI - Work->WKQTDE )
               ENDIF

               If lExiste_Midia .AND. lPesoMid   // LDR - 24/08/04
                  SW7->W7_PESOMID  :=   Work->WKPESOMID
               ENDIF

               SW7->(MsUnlock())
               IF !lMV_SLD_EMB

                  IF PosOrd2_IT_Guias(M->W6_HAWB,Work->WKCC,Work->WKSI_NUM,Work->WKCOD_I ,;
                                      Work->WKFABR,Work->WKFORN,Work->WKREG,Work->WKPGI_NUM,Work->WKPO_NUM,Work->WKPOSICAO, EICRetLoja("Work", "W7_FABLOJ"), EICRetLoja("Work", "W7_FORLOJ"))

                     SW5->(RecLock("SW5",.F.))
                     IF Work->WKQTDE > Work->WKQTDEDORI
                        SW5->W5_QTDE:= SW5->W5_QTDE+(Work->WKQTDE-Work->WKQTDEDORI)
                     ELSE
                        SW5->W5_QTDE:= SW5->W5_QTDE-(Work->WKQTDEDORI-Work->WKQTDE)
                     ENDIF
                     SW5->(MSUnlock())
                  ENDIF

                  //NCF - 22/03/2011 - Item anuente com LI do Embarque no PN (Alteração)
                  IF MOpcao == FECHTO_NACIONALIZACAO .And. Work->WKFLUXO == "1" .And. lPLIAntes //FSM - 22/05/2012
                     nRegisSW3 := SW3->(RECNO())
                     nOrdemSW3 := SW3->(INDEXORD())
                     SW3->(DbSetOrder(8))
                     SW3->(DBSeek(xFilial("SW3")+Work->WKPO_NUM+Work->WKPOSICAO))
                     DI400POSld( "1", Work->WKSALDO_O-WORK->WKQTDE, .T. )
                     SW3->(DbSetOrder(nOrdemSW3))
                     SW3->(DbGoTo(nRegisSW3))
                  ENDIF

                  DI400IdAtuSld("3")
               ELSE
                  PosOrd2_IT_Guias(M->W6_HAWB,Work->WKCC,Work->WKSI_NUM,Work->WKCOD_I ,;
                                   Work->WKFABR,Work->WKFORN,Work->WKREG,Work->WKPGI_NUM,Work->WKPO_NUM,Work->WKPOSICAO, EICRetLoja("Work", "W7_FABLOJ"), EICRetLoja("Work", "W7_FORLOJ"))

                  IF Work->WKQTDE <= SW5->W5_QTDE // CASO A QUANTIDADE DO ITEM SEJA MAIOR QUE A DA PLI , NAO ATUALIZAR A QUANTIDADE NEM O SALDO NAO FICAR NEGATIVO

                     SW5->(RecLock("SW5",.F.))
                     nQtde_Li:=SW5->W5_QTDE
                     SW5->W5_QTDE:= Work->WKQTDE
                     SW5->(MSUnlock())
                     IF PosOrd1_IT_Guias(WORK->WKPGI_NUM,WORK->WKCC,WORK->WKSI_NUM,;
                                         WORK->WKCOD_I,WORK->WKFABR,WORK->WKFORN  ,;
                                         WORK->WKREG,0,WORK->WKPO_NUM, EICRetLoja("Work", "W7_FABLOJ"), EICRetLoja("Work", "W7_FORLOJ"))

                        SW5->(RecLock("SW5",.F.))
                        SW5->W5_SALDO_Q:= (nQtde_Li-Work->WKQTDE)
                        SW5->(MSUnlock())
                     ENDIF

                  ELSE
                     IF Work->WKQTDE > Work->WKSALDO_O
                           IF PosOrd1_IT_Guias(WORK->WKPGI_NUM,WORK->WKCC,WORK->WKSI_NUM,;
                                               WORK->WKCOD_I,WORK->WKFABR,WORK->WKFORN  ,;
                                               WORK->WKREG,0,WORK->WKPO_NUM, EICRetLoja("Work", "W7_FABLOJ"), EICRetLoja("Work", "W7_FORLOJ"))

                              nSLD_LI:=SW5->W5_SALDO_Q
                              SW5->(RecLock("SW5",.F.))
                              SW5->W5_SALDO_Q:=0
                              SW5->(MSUnlock())
                           ENDIF

                        IF PosOrd2_IT_Guias(SW6->W6_HAWB,WORK->WKCC,WORK->WKSI_NUM,WORK->WKCOD_I ,;
                                            WORK->WKFABR,WORK->WKFORN,WORK->WKREG,WORK->WKPGI_NUM,WORK->WKPO_NUM, EICRetLoja("Work", "W7_FABLOJ"), EICRetLoja("Work", "W7_FORLOJ"))
                           SW5->(RecLock("SW5",.F.))
                           SW5->W5_QTDE:=SW5->W5_QTDE+nSLD_LI
                           SW5->(MSUnlock())

                        ENDIF
                     ELSE
                        IF PosOrd2_IT_Guias(SW6->W6_HAWB,WORK->WKCC,WORK->WKSI_NUM,WORK->WKCOD_I ,;
                                            WORK->WKFABR,WORK->WKFORN,WORK->WKREG,WORK->WKPGI_NUM,WORK->WKPO_NUM, EICRetLoja("Work", "W7_FABLOJ"), EICRetLoja("Work", "W7_FORLOJ"))

                           IF Work->WKQTDE <= SW5->W5_QTDE
                              nQtde_Li:=SW5->W5_QTDE
                              SW5->(RecLock("SW5",.F.))
                              SW5->W5_QTDE:=Work->WKQTDE
                              SW5->(MSUnlock())

                              IF PosOrd1_IT_Guias(WORK->WKPGI_NUM,WORK->WKCC,WORK->WKSI_NUM,;
                                                  WORK->WKCOD_I,WORK->WKFABR,WORK->WKFORN  ,;
                                                 WORK->WKREG,0,WORK->WKPO_NUM, EICRetLoja("Work", "W7_FABLOJ"), EICRetLoja("Work", "W7_FORLOJ"))

                                 SW5->(RecLock("SW5",.F.))
                                 SW5->W5_SALDO_Q:=SW5->W5_SALDO_Q+(nQtde_Li-Work->WKQTDE)
                                 SW5->(MSUnlock())
                              ENDIF
                           ENDIF
                        ENDIF
                     ENDIF
                  ENDIF
               ENDIF
            ENDIF

            SW7->(DBGOTO(Work->WKRECNO_ID))

            SW7->(RecLock("SW7",.F.))
            AVREPLACE("Work","SW7")
            SW7->W7_PRECO := Work->WKPRECO
            SW7->W7_PESO  := Work->WKPESO_L

            //FSM - 31/08/2011 - "Peso Bruto Unitário"
            If lPesoBruto
               SW7->W7_PESO_BR := Work->WKW7PESOBR
            EndIf

            SW7->W7_NCM   := Work->WKTEC
            SW7->W7_EX_NCM:= Work->WKEX_NCM
            SW7->W7_EX_NBM:= Work->WKEX_NBM
            SW7->W7_VLR_IPI:= Work->WKIPIPAUTA
            If lExiste_Midia .AND. lPesoMid   // LDR - 24/08/04
               SW7->W7_PESOMID  :=   Work->WKPESOMID
            ENDIF
            IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GRAVA_ALTERA_SW7"),)

            SW7->(MSUnlock())
            IF PosOrd2_IT_Guias(M->W6_HAWB,Work->WKCC,Work->WKSI_NUM,Work->WKCOD_I ,;
                                Work->WKFABR,Work->WKFORN,Work->WKREG,Work->WKPGI_NUM,Work->WKPO_NUM,Work->WKPOSICAO, EICRetLoja("Work", "W7_FABLOJ"), EICRetLoja("Work", "W7_FORLOJ"))
               SW5->(RecLock("SW5",.F.))
               SW5->W5_PRECO:=Work->WKPRECO
               SW5->(MSUnlock())
            ENDIF

         ENDIF
      ENDIF

      // RA - 31/10/03 - O.S. 1110/03 - Inicio
      If lResp
         SB1->(DbSetOrder(1))
         If SB1->(DbSeek(xFilial()+WORK->WKCOD_I))
            If cEasy $ cNao  // RA - 12/01/04 - OS 0038/04 - Inicio
               If !GetNewPar("MV_PESONEW",.F.)
                  If SB1->B1_PESO <> Work->WKPESO_L
                     SB1->(RecLock("SB1",.F.))
                     SB1->B1_PESO := Work->WKPESO_L
                     SB1->(MSUnlock())
                   EndIf
               ElseIf GetNewPar("MV_PESONEW",.F.) .And. lExistA5PESO // SA5->(FIELDPOS("A5_PESO")) # 0
                  nRecSA5 := SA5->(RecNo())
                  nOrdSA5 := SA5->(IndexOrd())
                  SA5->(DbSetOrder(3))
                  If EICSFabFor(xFilial("SA5")+SW5->W5_COD_I+SW5->W5_FABR+SW5->W5_FORN, EICRetLoja("SW5", "W5_FABLOJ"), EICRetLoja("SW5", "W5_FORLOJ"))
                     If SA5->A5_PESO <> Work->WKPESO_L
                        SA5->(RecLock("SA5",.F.))
                        SA5->A5_PESO := Work->WKPESO_L
                        SA5->(MSUnlock())
                     EndIf
                  EndIf
                  SA5->(DbSetOrder(nOrdSA5))
                  SA5->(DbGoTo(nRecSA5))
               EndIf // RA - 12/01/04 - OS 0038/04 - Final
            ElseIf EasyGParam("MV_UNIDCOM",,2) == 1 .And. cEasy $ cSim // RA - 12/01/04 - OS 0038/04
               If SB1->B1_PESO <> WORK->WKPESO_L
                  SB1->(RecLock("SB1",.F.))
                  SB1->B1_PESO := WORK->WKPESO_L
                  SB1->(MSUnlock())
               EndIf
            ElseIf EasyGParam("MV_UNIDCOM",,2) == 2 .And. cEasy $ cSim // RA - 12/01/04 - OS 0038/04
               nRecSW1 := SW1->(Recno())
               nOrdSW1 := SW1->(IndexOrd())
               If ( SW1->(PosO1_It_Solic(WORK->WKCC,WORK->WKSI_NUM,WORK->WKCOD_I,WORK->WKREG,0) ) )
                  If SW1->W1_QTSEGUM <> 0
                     If (SB1->B1_PESO <> (WORK->WKPESO_L * (SW1->W1_QTDE/SW1->W1_QTSEGUM)))
                        SB1->(RecLock("SB1",.F.))
                        SB1->B1_PESO := WORK->WKPESO_L * (SW1->W1_QTDE/SW1->W1_QTSEGUM)
                        SB1->(MSUnlock())
                     EndIf
                  Else
                     If SB1->B1_PESO <> WORK->WKPESO_L
                        SB1->(RecLock("SB1",.F.))
                        SB1->B1_PESO := WORK->WKPESO_L
                        SB1->(MSUnlock())
                     EndIf
                  EndIf
               EndIf
               SW1->(DbSetOrder(nOrdSW1))
               SW1->(DbGoTo(nRecSW1))
            EndIf
         EndIf
      EndIf
      // RA - 31/10/03 - O.S. 1110/03 - Final

      IF EMPTY(cPO_NUM)
         cPO_NUM := Work->WKPO_NUM
      ELSE
         IF cPO_NUM # Work->WKPO_NUM
            DI400AtuOco(cPO_NUM)
            cPO_NUM := Work->WKPO_NUM
         ENDIF
      ENDIF

      Work->(DBSKIP())
   ENDDO

   If MOpcao == FECHTO_NACIONALIZACAO

      IF EMPTY(M->W6_DT_ENCE)
         nVlrDA := 0
         FOR i:=1 TO LEN(aDa)
             IF SW6->(DBSEEK(xFilial("SW6") + aDA[i]))
                nVlrDA += SW6->W6_FOB_TOT
             ENDIF
             IF SWD->(DBSEEK(xFilial("SWD") + aDA[i]))
                Do While ! SWD->(EOF()) .AND. SWD->WD_HAWB = aDA[i] .AND. xFilial("SWD") = SWD->WD_FILIAL
                   If SWD->WD_DESPESA#"101" .AND. SWD->WD_DESPESA#"102" .AND. SWD->WD_DESPESA#"103" .AND. Empty(SWD->WD_NF_COMP) .AND. ;
                      IF(EasyGParam("MV_G901DIN",,.T.),.T., LEFT(SWD->WD_DESPESA,1)#"9")

                      nDesp:=ASCAN(aTotDespDa, {|x| x[1] = SWD->WD_DESPESA .AND. x[4] = SWD->WD_DES_ADI})
                      If nDesp = 0
                         Aadd(aTotDespDa,{SWD->WD_DESPESA,SWD->WD_VALOR_R,SWD->(RECNO()), SWD->WD_DES_ADI, SWD->WD_BASEADI})//FDR - 04/10/12
                      Else
                         aTotDespDa[nDesp,2] += SWD->WD_VALOR_R
                      EndIf
                   ENDIF
                   SWD->(dbSkip())
                ENDDO
             ENDIF
         NEXT

         FOR i:=1 TO LEN(aTotDespDA)

            SYB->(DbSetOrder(1))                                 //NCF - 09/12/2010 - Rateia as despesas da DA para DIN por peso quando
            SYB->(DbSeek(xFilial()+aTotDespDA[i][1]))            //                   o cadastro da despesa estiver configurado para ratear
            IF SYB->YB_RATPESO == "1"                            //                   por peso(YB_RATPESO == "1").
               //Rateio da despesa é por Peso
               nRateioDesp := nPesDinAtu/SW6->W6_PESOL
            ELSE
               //Rateio da despesa é por FOB
              nRateioDesp := (nDinAtu/(nVlrDA - nVlDins))
            ENDIF
            nVlrSWD     := aTotDespDA[i,2]

            IF ( nPos:= aScan(aTotDesp, {|x| x[2] == aTotDespDa[i,1] .AND. x[4] == aTotDespDa[i,4] })) > 0
               nVlrSWD:= nVlrSWD - aTotDesp[nPos][3]
            EndIf

            IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"RATEIO_DESPESA_ENTREPOSTO"),)

            nValorSWD:=nVlrSWD*nRateioDesp

            nDespDa:=ASCAN(aDespDa, {|x| x[1] = aTotDespDa[i,1] .AND. x[4] = aTotDespDa[i,4]})
            If nDespDa = 0
               Aadd(aDespDa,{aTotDespDa[i,1],nValorSWD,aTotDespDa[i,3], aTotDespDa[i,4], aTotDespDa[i,5]})//FDR - 04/10/12
            Else
               aDespDa[nDespDa,2] += nValorSWD
            EndIf
         NEXT

         SW6->(DBGOTO(nRecSW6))
         RestOrd(aOrdSW5,.T.)
         RestOrd(aOrdSW8,.T.)

      ENDIF
   ENDIF
   SW4->(DBSETORDER(1))
   FOR P := 1 TO LEN(aPli)
      IncProc(STR0009 + aPLI[P]) //"Lendo a P.L.I.: "
      IF SW4->(DBSEEK(xFilial()+aPLI[P]))
         SW4->(MSUNLOCK())
      ENDIF
   NEXT

   IF !EMPTY(cPO_NUM)
      DI400AtuOco(cPO_NUM)
   ENDIF

   IncProc(STR0010 + cDesc) //"Atualizando dados do "


   //igor chiba 25/06/14 CONTABILIZACAO verifica se houve alteracao nas invoices e dispara contabilizacao
   IF EasyGParam("MV_EIC_ECO",,'N') == 'N'  .AND. EasyGParam('MV_EIC0047',,.F.) //se o modulo sigaeco estiver desligado

      aAtual :={}
      Work_SW9->(DBGOTOP())
      Do While !Work_SW9->(EOF())
         AADD(aAtual,{Work_SW9->WK_RECNO,DI500RetVal("TOT_INV", "WORK", .T., .F. )})
         Work_SW9->(dbSkip())
      EndDo

      aVlAnt:={}
      IF nOPC_mBrw <> 3
         SW9->(dbSetOrder(3))
         SW9->(dbSeek(xFilial("SW9")+SW6->W6_HAWB))
         DO WHILE SW9->(!EOF())    .AND. SW9->W9_FILIAL == xFilial("SW9");
                                   .AND. SW9->W9_HAWB   == SW6->W6_HAWB

            AADD(aVlAnt,{SW9->(RECNO()),DI500RetVal("TOT_INV", "TAB", .T., .F. )})
            SW9->(DBSKIP())
         ENDDO
        ENDIF

      //AHAC - 12/08/2014 - Correção de Integração ocorrendo mesmo com data de embarque em branco
     If !lChangeEmb .AND. !Empty(M->W6_DT_EMB)
        IF LEN(aVlAnt) <> Len(aAtual)
           lChangeEmb:=.T.
        ELSE
           For nI:=1 to len(aVlAnt)
              IF aAtual[nI][1] == 0//se o recno de uma invoice da work nao existir na base houve alteracao
                 lChangeEmb:=.T.
                 EXIT

               //se o recno de uma invoice da work nao existir na base houve alteracao
                 lChangeEmb:=.T.
                 EXIT
              ELSEIF (nPos:=ASCAN(aAtual,{|X| X[1] == aVlAnt[nI][1]})) <> 0 .and. aAtual[nPos][2] <>  aVlAnt[nI][2]  //se o valor estiver anterado houve mudanca
                 lChangeEmb:=.T.
                 EXIT
              ENDIF
           Next
        ENDIF
      EndIf
      //igor chiba  02/04/14 ANTES DE CHAMAR ENVIO CHAMAR CANCELAMENTO
      IF nOPC_mBrw <> 3  .and. lChangeEmb .And. FindFunction("L500RETREG")//!EMPTY(SW6->W6_DT_EMB)  // GFP - 09/10/2014 - Incluido dentro do IF de verificação de Logix.
         //aRegs:=L500RETREG(xFilial("SW6"),SW6->W6_HAWB,"'101','501','504'",'') //comentado por wfs
         aRegs:=L500RETREG(xFilial("SW6"),SW6->W6_HAWB,"'101','111','501','512','504','513'",'') //processos sem cobertura cambial
         L500CANCTB(aRegs)
      ENDIF
   ENDIF


   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GRAVA_ANTES_SW6"),)
   lDeletaSWD:=.F.
   SW7->(dbSetOrder(1))
   IF !SW7->(dbSeek(xFilial()+M->W6_HAWB))
      AVZAP("Work_SW8") //Work_SW8->(avzap())//Para deletar as Invoices
      DI500GrvInvoice()  // GFC 22/12/03 - Passado para cima para Integridade Referencial.
      DI500EIGrava('ESTORNO',M->W6_HAWB,{})
      SW6->(RecLock("SW6",.F.))
      SW6->(dbDelete())
      SW6->(MsUnlock())
      lDeletaSWD:=.T.
      aDespDa:={}
   ELSE  // SVG - 26/05/2010 -
      If !lDI500GrvSW6
         DI500GrvSW6("1")
         DI500EIGrava('GRAVACAO',SW6->W6_HAWB,aAliasAdic)
      EndIf
   ENDIF

   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GRAVA_DEPOIS_SW6"),)
   DI500GrvInvoice()

   If AVFLAGS("DUIMP")
      AjSldLotes("DEL")                                //Ajusta os saldos dos lotes da DUIMP já validados antes da efetivação nas tabelas físicas.
      If !Empty(M->W6_DT_DESE) .And. M->W6_TIPOREG=="2" //MFR 31/01/2022 OSSME-6563
         GerTXSISC()                                   //Calcula e gera a taxa Siscomex do processo DUIMP quando informada a data do desembaraço.
      EndIf    
   EndIf 

   //AOM - 06/04/2011 - Salvando operações especiais - Admissao temporaria / Reimportações
   If lOperacaoEsp
      oOperacao:SaveOperacao()
   EndIf

   If MOpcao == FECHTO_NACIONALIZACAO .AND. EMPTY(M->W6_DT_ENCE)
      If SWD->(DBSEEK(xFilial("SWD")+M->W6_HAWB))
         Do While ! SWD->(EOF()) .AND. SWD->WD_HAWB = M->W6_HAWB .AND. xFilial("SWD") = SWD->WD_FILIAL
            IF !Empty(SWD->WD_NF_COMP)
               nDespDa:=ASCAN(aDespDa, {|x| x[1] = SWD->WD_DESPESA .AND. x[4] = SWD->WD_DES_ADI } )
               If nDespDa # 0
                  aDespDa[nDespDa,2] := 0
               Endif
               SWD->(DBSKIP())
               LOOP
            ENDIF
            IF lDeletaSWD
               SWD->(RECLOCK('SWD',.F.))
               SWD->(DBDELETE())
               SWD->(MSUNLOCK())
               SWD->(DBSKIP())
               LOOP
            ENDIF
            If SWD->WD_DA $ cSim
               nDespDa:=ASCAN(aDespDa, {|x| x[1] = SWD->WD_DESPESA .AND. x[4] = SWD->WD_DES_ADI } )  // TLM 20/05/2008 Incluído contador para incluir despesa por linha, ao invés do valor ser totalizado.
               SWD->(RECLOCK('SWD',.F.))
               If nDespDa # 0
                  If aDespDa[nDespDa,2] <> 0  // TLM 20/05/2008 A despesa não pode ser gravada com valor zero.
                     SWD->WD_VALOR_R    := aDespDa[nDespDa,2]
                     aDespDa[nDespDa,2] := 0
                  EndIf
                Else
                  SWD->(DBDELETE())
               EndIf
               SWD->(MSUNLOCK())
            EndIf
            SWD->(DBSKIP())
         EndDo
      EndIf
      For iDA:=1 to LEN(aDespDa)
          If aDespDa[iDA,2] # 0
             SWD->(DBGOTO(aDespDa[iDA,3]))
             FOR i := 1 TO SWD->(FCount())
                 SWD->( M->&(FIELDNAME(i)) := FieldGet(i) )
             NEXT
             SWD->(RecLock("SWD",.T.))
              If lAvIntFinEIC
                SWD->WD_LINHA := DI500SWDLin()
             EndIf
             For _nX := 1 To SWD->(fCount())
                 _cCampo    := "M->"+SWD->(Field(_nX))
                 _xConteudo := &_cCampo
                 SWD->(FieldPut(_nX, _xConteudo))
             Next
             SWD->WD_FILIAL  := xFilial("SWD")
             SWD->WD_HAWB    := M->W6_HAWB
             SWD->WD_VALOR_R := aDespDa[iDA,2]
             SWD->WD_DA      := '1'
             //FDR
             IF SWD->(FieldPos("WD_DA_ORI")) > 0
                SWD->WD_DA_ORI  := '1'
             ENDIF
             SWD->WD_BASEADI := aDespDa[iDA,5]//FDR - 04/10/12 //"2"
             SWD->WD_GERFIN  := "2"   // GFP - 29/10/2014
             SWD->WD_CTRFIN1 := ""    // GFP - 29/10/2014
             SWD->WD_CTRFIN2 := ""    // GFP - 29/10/2014
             SWD->WD_CTRFIN3 := ""    // GFP - 29/10/2014
             SWD->WD_PARCELA := ""    // GFP - 29/10/2014
             SWD->WD_DOCTO   := ""    // GFP - 29/10/2014
             SWD->(MSUNLOCK())
          EndIf
      Next
   EndIf

   //igor chiba 25/06/14 CONTABILIZACAO
   IF EasyGParam("MV_EIC_ECO",,'N') == 'N'  .AND. EasyGParam('MV_EIC0047',,.F.) .And. FindFunction("L500GERCTB")//se o modulo sigaeco estiver desligado
      IF !EMPTY(SW6->W6_DT_EMB)
         L500GERCTB('TE')
      ENDIF
   ENDIF


   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GRAVA_FINAL"),)

   SWA->(DbSetOrder(1)) // RS 05/07/07
   If SWA->(DbSeek(xFilial("SWA") + M->W6_HAWB + "D" ) )  // RS 05/07/07
      SWA->(RecLock("SWA",.F.))  						  // RS 05/07/07
      SWA->WA_DI_NUM  := M->W6_DI_NUM  					  // RS 05/07/07
      SWA->WA_DTREG_D := M->W6_DTREG_D 					  // RS 05/07/07
      SWA->(MsUnlock())                                   // RS 05/07/07
   EndIf
   EvalTrigger()
//FINALIZA O CONTROLE DE TRANSACAO
End Transaction //LRS - 12/07/2017

IncProc(STR0011) //"Fim do processamento"

//*** GFP - 25/03/2011 - 16:43 - Inclusão de verificação de WorkFlow

If AvFlags("WORKFLOW")
   EasyGroupWF("EMBARQUE_EIC",aChaves)
EndIf


Return .T.

// Passar valores cDataFOB, cDataFre e cDataSeg por referência
Function DI501GetDataVar(cDataFOB, cDataFre, cDataSeg)
    Local aDataVar := StrTokArr(ALLTRIM(EasyGParam("MV_DT_VAR")), "|")
    If Len(aDataVar) >= 1
        cDataFOB := aDataVar[1]
    Else
        cDataFOB := ""
    EndIf
    If Len(aDataVar) >= 2
        cDataFre := aDataVar[2]
    Else
        cDataFre := cDataFOB
    EndIf
    If Len(aDataVar) >= 3
        cDataSeg := aDataVar[3]
    Else
        cDataSeg := cDataFOB
    EndIf
Return

/*
Funcao      : DI501GrvSW6()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
FUNCTION DI501GrvSW6(cAtz_Ocor)//Antiga Di400GrvDi000(PAtz_Ocor) do EIC.PRW

LOCAL cPo_Sal,nFobTotal:=0 //, lGeraCamb := .T.   // Nopado por GFP - 20/03/2012
LOCAL cFilSW9:=xFilial('SW9')
LOCAL ldataEMB := !EMPTY(GetNewPar("MV_DTB_APD",""))
LOCAL lSW9 := .F.
LOCAL dDtEmbG := CTOD("")
LOCAL dDtEmbM := CTOD("")
LOCAL cDataFOB := ""
Local cDataFre := ""
Local cDataSeg := ""
Local lEncerrado := !Empty(SW6->W6_DT_ENCE)
PRIVATE lGrava:=.F., lLib_Fin:=.F.
Private lDI500GrvSW6:= .T.
Private nContMSG := 1 //LRS 10/12/2015 - Contador para a mensagem na function DI501GERNF
//CCH - 15/07/09 - Inclusão de variável para viabilizar o desvio da Mensagem: "Não existe cotação FOB para a data de pesquisa"
Private lTxMsg := .T.

// EJA - 13/11/2018 - Atribui a data de variação de acordo com MV_DT_VAR para cada variável passada na função.
// As variáveis passadas por parâmetros serão alteradas após passar pela função.
DI501GetDataVar(@cDataFOB, @cDataFre, @cDataSeg)

//** AAF 12/09/05
If lIntDraw .AND. Empty(cRegDI)
   cRegDI := If( Empty(SW6->W6_DI_NUM), "N", "S")
   lAltDtReg := ( cRegDI == "S"  .And.  !Empty(M->W6_DTREG_D)  .And.  M->W6_DTREG_D != SW6->W6_DTREG_D )  // PLB 19/12/06
Endif

   DBSELECTAREA("Work")
   ProcRegua(EasyReccount("Work"))
   Work->(DBSETORDER(2))
   DBGOTOP()

   if Work->(eof())  							// RS Chamado 055914 Registro da DI não aparece no Status Report em 08/08/07
      //SW7->(dbsetorder(1))                      // RS Chamado 055914 Registro da DI não aparece no Status Report em 08/08/07
      SW7->(dbSetOrder(4)) //AAF 27/11/08
      SW7->(dbseek(xFilial("SW7")+M->W6_HAWB))  // RS Chamado 055914 Registro da DI não aparece no Status Report em 08/08/07

      WHILE ! SW7->(eof()) .and. SW7->W7_HAWB == M->W6_HAWB    // RS Chamado 055914 Registro da DI não aparece no Status Report em 08/08/07

		 IncProc(STR0012) //"Gravando Ocorrencias..."
		 DI400AtuOco(cPo_Sal)
		 SW7->( AVSeekLast(xFilial("SW7")+M->W6_HAWB+SW7->W7_PO_NUM,,.T.) ) //AAF 27/11/08 - Não é necessário processar mais nenhum registro deste PO.
		 SW7->(DBSKIP())
      END

      SW7->(dbSetOrder(1))
   Endif   // // RS Chamado 055914 Registro da DI não aparece no Status Report em 08/08/07

   DO WHILE !EOF()
      IncProc(STR0012) //"Gravando Ocorrencias..."

      DI400AtuOco(cPo_Sal)
      //** AAF 27/11/08 - Melhoria de performance
      AVSeekLast(WKPO_NUM,,.T.)
      dbSkip()
   ENDDO

Procregua(2)
IncProc(STR0013) //"Gravando capa..."
//gravacao automatica
If MOpcao = FECHTO_NACIONALIZACAO
   M->W6_NACIONA:='1'
   M->W6_TIPOFEC:='DIN'
ElseIf (Val(M->W6_TIPODES) >= 2 .And. Val(M->W6_TIPODES) <= 4) .AND. !lDISimples
   M->W6_NACIONA:='2'
   M->W6_TIPOFEC:='DA'
Else
   M->W6_NACIONA:='2'
   M->W6_TIPOFEC:='DI'
EndIf

//** GFC - 24/11/05 - Câmbio de frete, seguro, comissão e embarque
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"CAMBIO_AUTOMATICO"),)

SW9->(dbSetOrder(3))
SWB->(dbSetOrder(1))

If lGravaFin_EIC .and. !lLib_Fin .and. !Inclui .and. !SWB->(dbSeek(xFilial("SWB")+M->W6_HAWB+If(lCposAdto,"D",""))) .and.;
If(cAtz_Ocor=="2", SW9->(dbSeek(xFilial("SW9")+M->W6_HAWB)), Work_SW9->(EasyRecCount("Work_SW9")) > 0) .And. !lEncerrado
  If !lCambInicial// TDF - 09/08/10
     Processa({|| FI400POS_DI(M->W6_HAWB,lGravaFin_EIC,If(cAtz_Ocor=="2","SW9","Work_SW9"),"M",) }, STR0014) //"Invoices"
  EndIF
ElseIf lGravaFin_EIC .and. !lLib_Fin .and. (Inclui .OR. Altera) .and. If(cAtz_Ocor=="2", SW9->(dbSeek(xFilial("SW9")+M->W6_HAWB)),;
  Work_SW9->(EasyRecCount("Work_SW9")) > 0) .And. !lEncerrado  // GFP - 20/03/2012 - Gravação quando Inclusão e Alteração

   If /*lGeraCamb .AND.*/ !lCambInicial// TDF - 09/08/10  // Nopado por GFP - 20/03/2012
      Processa({|| FI400POS_DI(M->W6_HAWB,lGravaFin_EIC,If(cAtz_Ocor=="2","SW9","Work_SW9"),"M",) },STR0014)//"Invoices"
   EndIf
Else
//Ask 02/08/2007 - Trata o parâmetro MV_DTB_APD que define a data de vencimento do cambio/título e depois compara
//o que está gravado com o da Memória/Work para saber se houve alteração.
IF !lDataEMB
      cDatEmb := "SW6->W6_DT_EMB"
   ELSE
      cDatEmb := ALLTRIM(GetNewPar("MV_DTB_APD","SW6->W6_DT_EMB"))
   ENDIF

   If Left(cDatEmb,5) == "SW6->"  //Caso o conteúdo do parâmetro possuir o Alias do Campo "SW6->"
      dDtEmbG:= &(cDatEmb)
      dDtEmbM:= &("M->" + Right(cDatEmb,Len(cDatEmb)-5))
   ElseIf Left(cDatEmb,3) == "W6_" // Ou só o campo
      dDtEmbG := &("SW6->" + cDatEmb )
      dDtEmbM := &("M->" + cDatEmb )
   Else
      lSW9 := .T.
   EndIf

   Work_SW9->(DbGoTop())
   Begin Sequence
   //Se o campo do parametro for da tabela SW9, verifica-se invoice por invoice até achar uma alteração
   SW9->(DbSetOrder(3))
   SW9->(DBSEEK(xFilial("SW9")+M->W6_HAWB))
   Do While !Work_SW9->(EOF()) .And. lSW9
      Do WHILE SW9->W9_HAWB == M->W6_HAWB .AND. SW9->W9_INVOICE == Work_SW9->W9_INVOICE

         If Left(cDatEmb,5) == "SW9->" //Caso o conteúdo do parâmetro possuir o Alias do Campo "SW6->"
            dDtEmbG:= &(cDatEmb)
            dDtEmbM:= &("Work_SW9->" + Right(cDatEmb,Len(cDatEmb)-5))
         ElseIf Left(cDatEmb,3) == "W9_" //Ou só o campo
            dDtEmbG := &("SW9->" + cDatEmb )
            dDtEmbM := &("Work_SW9->" + cDatEmb )
         EndIf
         IF dDtEmbG # dDtEmbM
            Break
         ENDIF
         SW9->(DbSkip())
      EndDo
      Work_SW9->(DbSkip())
   EndDo
   End Sequence
   SW9->(DbSetOrder(1))

   IF EMPTY(dDtEmbG) .And. EMPTY(dDtEmbM)
      dDtEmbG  := SW6->W6_DT_EMB
      dDtEmbM  := M->W6_DT_EMB
      IF EMPTY(dDtEmbG) .And. EMPTY(dDtEmbM)
   	     dDtEmbG  := SW6->W6_DT_ETA
         dDtEmbM  := M->W6_DT_ETA
   	  ENDIF
   ENDIF
//TDF - 09/08/10
//Se não tem cambio liquidado ou adiantado, verifica se base está diferente de memória, se sim, gera novamente.
//wfs mai/2017 - Inclui: possibilitar a criação do câmbio de frete e seguro na inclusão do processo de embarque/ desembaraço
If !lCambInicial
   If lWB_TP_CON .and. lGravaFin_EIC .and. (Inclui .Or. !Inclui .and. (!lLib_Fin .or. !Empty(SW6->W6_DTLIFIN)) .and.;
   ((M->W6_FORNECF<>SW6->W6_FORNECF .or. M->W6_FREMOED<>SW6->W6_FREMOED .or. M->W6_VLFRECC<>SW6->W6_VLFRECC .or.;
   M->W6_VENCFRE<>SW6->W6_VENCFRE .or. M->W6_CONDP_F<>SW6->W6_CONDP_F .or. M->W6_DIASP_F<>SW6->W6_DIASP_F .or.;
   dDtEmbM <> dDtEmbG) .or. (cAtz_Ocor == "1" .and. lAltFrete)) .And. !lEncerrado )
      If Inclui .Or. ((M->W6_FORNECS<>SW6->W6_FORNECS .or. M->W6_SEGMOED<>SW6->W6_SEGMOED .or. M->W6_VL_USSE<>SW6->W6_VL_USSE .or.;
      M->W6_VENCSEG<>SW6->W6_VENCSEG .or. M->W6_CONDP_S<>SW6->W6_CONDP_S .or. M->W6_DIASP_S<>SW6->W6_DIASP_S .or.;
      dDtEmbM <> dDtEmbG) .or. (cAtz_Ocor == "1" .and. lAltSeg))
         Processa({|| FI400POS_DI(M->W6_HAWB,lGravaFin_EIC,If(cAtz_Ocor=="2","SW9","Work_SW9"),"M","1") },STR0014)//"Invoices"
      Else
         Processa({|| FI400POS_DI(M->W6_HAWB,lGravaFin_EIC,If(cAtz_Ocor=="2","SW9","Work_SW9"),"M","2") },STR0014)//"Invoices"
      EndIf
   ElseIf lGravaFin_EIC .and. (Inclui .Or. !Inclui .and. (!lLib_Fin .or. !Empty(SW6->W6_DTLIFIN)) .and.;
   ((M->W6_FORNECS<>SW6->W6_FORNECS .or. M->W6_SEGMOED<>SW6->W6_SEGMOED .or. M->W6_VL_USSE<>SW6->W6_VL_USSE .or.;
   M->W6_VENCSEG<>SW6->W6_VENCSEG .or. M->W6_CONDP_S<>SW6->W6_CONDP_S .or. M->W6_DIASP_S<>SW6->W6_DIASP_S) .or.;
   (cAtz_Ocor == "1" .and. lAltSeg)))
      Processa({|| FI400POS_DI(M->W6_HAWB,lGravaFin_EIC,If(cAtz_Ocor=="2","SW9","Work_SW9"),"M","3") },STR0014)//"Invoices"
   EndIf

   If lGravaFin_EIC .and. cAtz_Ocor == "1" .And. !lEncerrado
      //Verificar Alteração de Invoices e atualizar se necessário
      If !lLib_Fin .or. !Empty(SW6->W6_DTLIFIN)
         Processa({|| FI400POS_DI(M->W6_HAWB,lGravaFin_EIC,"Work_SW9","M","4") },STR0014)//"Invoices"
      EndIf
   EndIf
EndIf
EndIf

E_Grava("SW6",(!lExiste))
lExiste:=.T.//Para nao duplicar o Processo caso a Tela da Capa tenha algum campo nao-validado
// gravacao de campo memo
IF MOpcao = FECHTO_DESEMBARACO .OR. MOpcao = FECHTO_NACIONALIZACAO .OR. MOpcao == FECHTO_EMBARQUE
   IF !EMPTY(SW6->W6_OBS) .OR. !EMPTY(M->W6_VM_OBS)
      MSMM(If(lExiste,SW6->W6_OBS,),AVSX3("W6_VM_OBS" ,3),,M->W6_VM_OBS ,1,,,"SW6","W6_OBS")
   ENDIF
ENDIF
IF !EMPTY(SW6->W6_COMPLEM) .OR. !EMPTY(M->W6_VM_COMP)
   MSMM(If(lExiste,SW6->W6_COMPLEM,),AVSX3("W6_VM_COMP",3),,M->W6_VM_COMP,1,,,"SW6","W6_COMPLEM")
ENDIF
IF SW6->(FieldPos("W6_DI_OBS")) > 0 .And. Type("M->W6_VMDIOBS") == "C" .And. !EMPTY(M->W6_VMDIOBS)
   MSMM(If(lExiste,SW6->W6_DI_OBS,),AVSX3("W6_VMDIOBS",AV_TAMANHO),,M->W6_VMDIOBS,INCMEMO,,,"SW6","W6_DI_OBS") //MCF - 12/04/2016
ENDIF

IncProc(STR0015) //"Gravando despesas..."
SF1->(DBSETORDER(5))
//ISS - 13/12/10 - Verificação se o HAWB corrente possui alguma nota gerada, e não apenas notas de despesas (NFD)
If lCposNFDesp
   lValidGrv := If(SF1->(DBSEEK(xFilial()+SW6->W6_HAWB)),!ExistHAWBNFE(SW6->W6_HAWB),.T.)
Else
   lValidGrv := !SF1->(DBSEEK(xFilial()+SW6->W6_HAWB))
EndIf

//IF !SF1->(DBSEEK(xFilial()+SW6->W6_HAWB)) .AND. (MOpcao = FECHTO_DESEMBARACO .OR. MOpcao == FECHTO_NACIONALIZACAO )
IF lValidGrv .AND. (MOpcao == FECHTO_EMBARQUE .OR. MOpcao == FECHTO_DESEMBARACO .OR. MOpcao == FECHTO_NACIONALIZACAO)

   
   cCampoDT_VAR:=ALLTRIM(cDataFOB)
   
   dDataDT_VAR :=dDataBranca
   cComtrole   :=ALLTRIM(GETNEWPAR("MV_CAMBAUT","NNN"))

   IF !EMPTY(cCampoDT_VAR)
      dDataDT_VAR := SW6->(FIELDGET(FIELDPOS(ALLTRIM(cCampoDT_VAR))))
   ENDIF

//*****************************  FOB  *****************************
   lGrava:=SUBSTR(cComtrole,1,1) $ cSim
   nDiferenca := 0
   nFobTotal  := 0

   lTxMsg := .T.
   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GRAVA_FOB"),)

   IF Work_SW9->(EasyRecCount("Work_SW9")) # 0
      ProcRegua(Work_SW9->(EasyReccount("Work_SW9")))
   ELSE
      ProcRegua(SW9->(Easyreccount("SW9"))+1)
   ENDIF
   If lIntDraw
      ED4->(dbSetOrder(2))
      ED0->(dbSetOrder(2))
   EndIf
   SW8->(DBSETORDER(1))
   SW9->(DBSETORDER(3))
   SY6->(DbSetOrder(1))
   lTiraSeg := .F.
   IF Work_SW9->(EasyRecCount("Work_SW9")) # 0

      Work_SW9->(DBGOTOP())
      DO WHILE !Work_SW9->(EOF())
         IncProc(STR0015) //"Gravando Despesas..."
         If lIntDraw  .And.  cAtz_Ocor == "2"
            If cRegDI == "N" .and. !Empty(M->W6_DI_NUM)
               DI500AtuAC()        //Atualiza Ato Concessorio
            //** PLB 19/12/06 - Atualiza Anterioridade
            ElseIf cRegDI == "S"  .And.  Empty(M->W6_DI_NUM)
               DI500AtuAC(,.T.)    //Atualiza Ato Concessorio
            ElseIf lAltDtReg  .And.  cAntImp=="2"
               Work_SW8->(dbSetOrder(1))
               Work_SW8->(dbSeek(Work_SW9->W9_INVOICE+Work_SW9->W9_FORN+EICRetLoja("Work_SW9", "W9_FORLOJ")))

               Do While !Work_SW8->( EOF() )  .And.  Work_SW8->WKINVOICE == Work_SW9->W9_INVOICE  .And.  ;
                        Work_SW8->WKFORN==Work_SW9->W9_FORN .And. (!EICLoja() .Or. Work_SW8->W8_FORLOJ == Work_SW9->W9_FORLOJ)
                  If !Empty(Work_SW8->WKAC)  .And.  GetModAtoC(SW8->W8_AC,.T.) == "1"
                     DIGrvAnt(3,M->W6_HAWB,Work_SW8->WKPO_NUM,Work_SW8->WKINVOICE,Work_SW8->WKCOD_I,Work_SW8->WKPOSICAO,Work_SW8->WKPGI_NUM,,M->W6_DTREG_D)
                  EndIf
                  Work_SW8->( DBSkip() )
               EndDo
            EndIf
         EndIf
         IF EMPTY(Work_SW9->W9_TX_FOB)
            nFobTotal  := 0
            EXIT
         ENDIF
         // EOB - 28/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
         IF AvRetInco(Work_SW9->W9_INCOTER,"CONTEM_SEG") .And. ( (!EMPTY(Work_SW9->W9_SEGURO) .AND. !Work_SW9->W9_SEGINC $ cSim) .OR. Work_SW9->W9_SEGINC $ cSim )/*FDR - 27/12/10*/  //Work_SW9->W9_INCOTER $ "CIF,CIP,DAF,DES,DEQ,DDP,DDU"
            lTiraSeg := .T.
         ENDIF
         nValorDT_VAR:=DI500TRANS( DI500RetVal( "TOT_INV", "WORK", .T., .T. ) ) // EOB - 20/06/08 - chamada da função DI500RetVal
         nFobTotal   +=nValorDT_VAR
         /* Nao gerar variacao cambial se a condicao de pagto for sem cobertura cambial */
         If SY6->(DbSeek(xFilial("SY6")+Work_SW9->(W9_COND_PA+Str(W9_DIAS_PA,3,0)))) .And. SY6->Y6_TIPOCOB == "4"
            Work_SW9->(DbSkip())
            Loop
         EndIf
         IF ! EMPTY(dDataDT_VAR/*cCampoDT_VAR*/)
            //nDiferenca  +=DI500TRANS(((Work_SW9->W9_FOB_TOT+Work_SW9->W9_INLAND+Work_SW9->W9_PACKING+Work_SW9->W9_OUTDESP-Work_SW9->W9_DESCONT+nFrete)*BuscaTaxa(Work_SW9->W9_MOE_FOB,dDataDT_VAR,.T.,.F.,.T.)))-nValorDT_VAR
            If EasyGParam("MV_AVG0160", .T.) .And. EasyGParam("MV_AVG0160",, .F.)
               nDiferenca  +=DI500TRANS(DI500RetVal( "TOT_INV", "WORK", .T.)*BuscaTaxa(Work_SW9->W9_MOE_FOB,dDataDT_VAR,.T.,.F.,.T.))-nValorDT_VAR  // EOB - 11/07/08 - chamada da função DI500RetVal
            Else
               nDiferenca  +=DI500TRANS(DI500RetVal( "TOT_INV", "WORK", .T.)*BuscaTaxa(Work_SW9->W9_MOE_FOB,dDataDT_VAR,.T.,.F.,.T.))-nValorDT_VAR  // EOB - 11/07/08 - chamada da função DI500RetVal
            EndIf
            //** AAF 10/09/2008 - Verifica se a taxa está cadastrada para o dia
            IF !Empty(dDataDT_VAR) .AND. SYE->YE_DATA # dDataDT_VAR .AND. lTxMsg <> Nil .AND. lTxMsg //CCH - 15/09/09 - Desviar da mensagem caso a variável seja preenchida como .F. via ponto de entrada
               Help("", 1, "AVG0000210",,(DTOC(dDataDT_VAR)),2,11)//E_Msg( STR0029 + DTOC(dDataDT_VAR),5)//"NÆo existe cota‡Æo FOB para a data de pesquisa "
            ENDIF
            //**
         ENDIF
         Work_SW9->(DBSKIP())
      ENDDO
      IF nFobTotal # 0
         nFobTotal:=nFobTotal-(M->W6_VLFREPP*M->W6_TX_FRET)
      ENDIF
      // EOB - 28/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
      IF lTiraSeg
      	 nFobTotal:=nFobTotal-(M->W6_VL_USSE*M->W6_TX_SEG)
      ENDIF
   ELSE

      SW9->(DBSETORDER(3))
      cFilSW9:=xFilial("SW9")
      SW9->(DBSEEK(xFilial()+M->W6_HAWB))
      DO WHILE SW9->(!EOF()) .AND. SW9->W9_HAWB   == M->W6_HAWB .AND.;
                                   SW9->W9_FILIAL == cFilSW9
         IncProc(STR0015) //"Gravando despesas..."
         If lIntDraw .AND. cAtz_Ocor == "2"
            If cRegDI == "N" .and. !Empty(M->W6_DI_NUM)
               DI500AtuAC(.T.)        //Atualiza Ato Concessorio
            ElseIf cRegDI == "S" .AND. Empty(M->W6_DI_NUM)
               DI500AtuAC(.T.,.T.)    //Atualiza Ato Concessorio
            //** PLB 19/12/06 - Atualiza Anterioridade
            ElseIf lAltDtReg  .And.  cAntImp=="2"
               If Work_SW8->( EasyRecCount("Work_SW8") ) == 0
                  nRecW9:= SW9->( RecNo() )
                  Processa({|| DI500InvCarrega()}, STR0016) //"Pesquisa de Itens"
                  SW9->( DBGoTo(nRecW9) )
               EndIf
               Work_SW9->( DBSeek(SW9->( W9_INVOICE+W9_FORN+SW9->W9_FORLOJ )) )
               Work_SW8->( DBSetOrder(1) )
               Work_SW8->( DBSeek(Work_SW9->W9_INVOICE+Work_SW9->W9_FORN+EICRetLoja("Work_SW9", "W9_FORLOJ")) )
               Do While !Work_SW8->( EOF() )  .And.  Work_SW8->WKINVOICE == Work_SW9->W9_INVOICE  .And.  ;
                        Work_SW8->WKFORN==Work_SW9->W9_FORN .And. (!EICLoja() .Or. Work_SW8->W8_FORLOJ == Work_SW9->W9_FORLOJ)
                  If !Empty(Work_SW8->WKAC)  .And.  ED0->( DBSeek(cFilED0+Work_SW8->WKAC) )  .And.  ED0->ED0_MODAL == "1"
                     DIGrvAnt(3,M->W6_HAWB,Work_SW8->WKPO_NUM,Work_SW8->WKINVOICE,Work_SW8->WKCOD_I,Work_SW8->WKPOSICAO,Work_SW8->WKPGI_NUM,,M->W6_DTREG_D)
                  EndIf
                  Work_SW8->( DBSkip() )
               EndDo
            //**
            Endif
         EndIf

         IF EMPTY(SW9->W9_TX_FOB)
            nFobTotal  := 0
            EXIT
         ENDIF
         // EOB - 28/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
         IF AvRetInco(SW9->W9_INCOTER,"CONTEM_SEG") .And. ( (!EMPTY(SW9->W9_SEGURO) .AND. !SW9->W9_SEGINC $ cSim) .OR. SW9->W9_SEGINC $ cSim )/*FDR - 27/12/10*/  //SW9->W9_INCOTER $ "CIF,CIP,DAF,DES,DEQ,DDP,DDU"
            lTiraSeg := .T.
         ENDIF

         nValorDT_VAR:=DI500TRANS( DI500RetVal( "TOT_INV", "TAB", .T., .T. ) ) // EOB - 20/06/08 - chamada da função DI500RetVal
         nFobTotal   += nValorDT_VAR

         /* Nao gerar variacao cambial se a condicao de pagto for sem cobertura cambial */
         If SY6->(DbSeek(xFilial("SY6")+SW9->(W9_COND_PA+Str(W9_DIAS_PA,3,0)))) .And. SY6->Y6_TIPOCOB == "4"
            SW9->(DbSkip())
            Loop
         EndIf
         IF ! EMPTY(dDataDT_VAR/*cCampoDT_VAR*/)
            //nDiferenca  +=DI500TRANS(((SW9->W9_FOB_TOT+SW9->W9_INLAND+SW9->W9_PACKING+SW9->W9_OUTDESP-SW9->W9_DESCONT+nFrete)*BuscaTaxa(SW9->W9_MOE_FOB,dDataDT_VAR,.T.,.F.,.T.)))-nValorDT_VAR
            If EasyGParam("MV_AVG0160", .T.) .And. EasyGParam("MV_AVG0160",, .F.)
               ///nDiferenca  +=DI500TRANS(DI500RetVal( "TOT_INV", "WORK", .T.)*BuscaTaxa(SW9->W9_MOE_FOB,dDataDT_VAR,.T.,.F.,.T.))-nValorDT_VAR   // EOB - 11/07/08 - chamada da função DI500RetVal  // LCS.24/10/2008.14:43
               nDiferenca  +=DI500TRANS(DI500RetVal( "TOT_INV", "TAB", .T.)*BuscaTaxa(SW9->W9_MOE_FOB,dDataDT_VAR,.T.,.F.,.T.))-nValorDT_VAR   // EOB - 11/07/08 - chamada da função DI500RetVal // LCS.24/10/2008.14:43
            Else
               ///nDiferenca  +=DI500TRANS(DI500RetVal( "TOT_INV", "WORK", .T.)*BuscaTaxa(SW9->W9_MOE_FOB,dDataDT_VAR,Nil,.F.,.T.))-nValorDT_VAR   // EOB - 11/07/08 - chamada da função DI500RetVal  // LCS.24/10/2008.14:43
               nDiferenca  +=DI500TRANS(DI500RetVal( "TOT_INV", "TAB", .T.)*BuscaTaxa(SW9->W9_MOE_FOB,dDataDT_VAR,.T.,.F.,.T.))-nValorDT_VAR   // EOB - 11/07/08 - chamada da função DI500RetVal  // LCS.24/10/2008.14:43
            EndIf
            //** AAF 10/09/2008 - Verifica se a taxa está cadastrada para o dia
            IF !Empty(dDataDT_VAR) .AND. SYE->YE_DATA # dDataDT_VAR .AND. lTxMsg <> Nil .AND. lTxMsg //CCH - 15/09/09 - Desviar da mensagem caso a variável seja preenchida como .F. via ponto de entrada
               Help("", 1, "AVG0000210",,(DTOC(dDataDT_VAR)),2,11)//E_Msg( STR0029 + DTOC(dDataDT_VAR),5)//"NÆo existe cota‡Æo FOB para a data de pesquisa "
            ENDIF
            //**
         ENDIF
         SW9->(DBSKIP())
      ENDDO
      IF nFobTotal # 0
         nFobTotal:=nFobTotal-(M->W6_VLFREPP*M->W6_TX_FRET)
      ENDIF
      // EOB - 28/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
      IF lTiraSeg
      	 nFobTotal:=nFobTotal-(M->W6_VL_USSE*M->W6_TX_SEG)
      ENDIF
   ENDIF
   If lIntDraw
      ED4->(dbSetOrder(1))
      ED0->(dbSetOrder(1))
   EndIf
   IF nFobTotal # 0
      DI400Grvddi(SW6->W6_HAWB,SW6->W6_DT_EMB,"101",nFobTotal,nDiferenca,"701",dDataDT_VAR,"711")
   ELSE
      DI400Grvddi(SW6->W6_HAWB,SW6->W6_DT_EMB,"101",0,0,"701",dDataDT_VAR,"711")
   ENDIF

//*****************************  FRETE  *****************************
   lGrava:=SUBSTR(cComtrole,2,1) $ cSim
   nDiferenca := 0
   nFobTotal  := 0
    cCampoDT_VAR := ALLTRIM(cDataFre)
    IF !EMPTY(cCampoDT_VAR)
        dDataDT_VAR := SW6->(FIELDGET(FIELDPOS(ALLTRIM(cCampoDT_VAR))))
    ENDIF
   nFrete:=(SW6->W6_VLFRECC+SW6->W6_VLFREPP)//ValorFrete(SW6->W6_HAWB,,,2)
   IF nFrete # 0 .AND. SW6->W6_TX_FRET # 0
      nValorDT_VAR := DI500Trans(nFrete * SW6->W6_TX_FRET)
      nDiferenca := 0
      IF ! EMPTY(dDataDT_VAR/*cCampoDT_VAR*/)
         //nDiferenca := DI500Trans(nFrete * BuscaTaxa(SW6->W6_FREMOED,dDataDT_VAR,.T.,.F.)-nValorDT_VAR)
         If EasyGParam("MV_AVG0160", .T.) .And. EasyGParam("MV_AVG0160",, .F.)
            nDiferenca := DI500Trans(nFrete * BuscaTaxa(SW6->W6_FREMOED,dDataDT_VAR,.T.,.F.)-nValorDT_VAR)
         Else
            nDiferenca := DI500Trans(nFrete * BuscaTaxa(SW6->W6_FREMOED,dDataDT_VAR,Nil,.F.)-nValorDT_VAR)
         EndIf
      ENDIF
      DI400Grvddi(SW6->W6_HAWB,SW6->W6_DT_EMB,"102",nValorDT_VAR,nDiferenca,"702",dDataDT_VAR,"712", SW6->W6_FORNECF, SW6->W6_LOJAF)
   ELSE
      DI400Grvddi(SW6->W6_HAWB,SW6->W6_DT_EMB,"102",0,0,"702",dDataDT_VAR,"712", SW6->W6_FORNECF, SW6->W6_LOJAF)
      If AvFlags("CONTROLE_SERVICOS_AQUISICAO") .And. EasyGParam("MV_ESS0022",,.T.)
         If nFrete <> 0 .AND. SW6->W6_TX_FRET == 0 /*SW6->W6_VL_USSE <> 0 .AND. SW6->W6_TX_SEG == 0*/ //NCF - 11/12/2017
            MsgInfo(STR0255, STR0254) //"A despesa de frete não foi gerada, impossibilitando a integração com o SIGAESS. Verifique as informações de taxa."
         EndIf
      EndIf
   ENDIF

//*****************************  SEGURO  *****************************
   lGrava:=SUBSTR(cComtrole,3,1) $ cSim
    cCampoDT_VAR := ALLTRIM(cDataSeg)
    IF !EMPTY(cCampoDT_VAR)
        dDataDT_VAR := SW6->(FIELDGET(FIELDPOS(ALLTRIM(cCampoDT_VAR))))
    ENDIF
   IF SW6->W6_VL_USSE # 0 .AND. SW6->W6_TX_SEG # 0
      nDiferenca   := 0
      nValorDT_VAR := DI500Trans(SW6->W6_VL_USSE * SW6->W6_TX_SEG)
      IF !EMPTY(dDataDT_VAR/*cCampoDT_VAR*/)
         //nDiferenca := DI500Trans(SW6->W6_VL_USSE * BuscaTaxa(SW6->W6_SEGMOED,dDataDT_VAR,.T.,.F.) - nValorDT_VAR)
         If EasyGParam("MV_AVG0160", .T.) .And. EasyGParam("MV_AVG0160",, .F.)
            nDiferenca := DI500Trans(SW6->W6_VL_USSE * BuscaTaxa(SW6->W6_SEGMOED,dDataDT_VAR,.T.,.F.) - nValorDT_VAR)
         Else
            nDiferenca := DI500Trans(SW6->W6_VL_USSE * BuscaTaxa(SW6->W6_SEGMOED,dDataDT_VAR,Nil,.F.) - nValorDT_VAR)
         EndIf
      ENDIF
      DI400Grvddi(SW6->W6_HAWB,SW6->W6_DT_EMB,"103",nValorDT_VAR,nDiferenca,"703",dDataDT_VAR,"713",SW6->W6_FORNECS,SW6->W6_LOJAS)
   ELSE
      DI400Grvddi(SW6->W6_HAWB,SW6->W6_DT_EMB,"103",0,0,"703",dDataDT_VAR,"713",SW6->W6_FORNECS,SW6->W6_LOJAS)
      If AvFlags("CONTROLE_SERVICOS_AQUISICAO") .And. EasyGParam("MV_ESS0022",,.T.)
         If SW6->W6_VL_USSE <> 0 .AND. SW6->W6_TX_SEG == 0
            MsgInfo(STR0256, STR0254) //"A despesa de seguro não foi gerada, impossibilitando a integração com o SIGAESS. Verifique as informações de taxa."
         EndIf
      EndIf
   ENDIF
   IF lValidGrv .AND. (MOpcao == FECHTO_DESEMBARACO .OR. MOpcao == FECHTO_NACIONALIZACAO) 
//*****************************  I.I    *****************************
        lGrava:=.F.  // PARA NAO GRAVAR CONTROLE CAMBIAL

        cCod_D_II := EasyGParam("MV_D_II",,"201")

        cCod_EII:=ALLTRIM(GETNEWPAR("MV_COD_EII","2892,3345,5602,5629"))

        aCodValEII:={}
        DO WHILE !EMPTY(cCod_EII)

            nPos:=AT(',',cCod_EII)
            IF nPos # 0
                AADD(aCodValEII,SUBSTR(cCod_EII,1,nPos-1))
                cCod_EII:=SUBSTR(cCod_EII,nPos+1)
            ELSE
                AADD(aCodValEII,cCod_EII)
                cCod_EII:=""
            ENDIF

        ENDDO

        If lTemAdicao //TRP-14/09/07
            IF M->W6_ADICAOK $ cSim .AND. LEN(aCodValEII) > 0 .AND. WORK_EII->(DBSEEK(aCodValEII[1]))
                DI400Grvddi(SW6->W6_HAWB,SW6->W6_DT,cCod_D_II,Work_EII->EII_VLTRIB,0,,,"712")
            ELSE
                DI400Grvddi(SW6->W6_HAWB,SW6->W6_DT,cCod_D_II,0,0,,,"712")
            ENDIF
        ENDIF
        //*****************************  I.P.I   *****************************

        cCod_D_IPI := EasyGParam("MV_D_IPI",,"202")

        If lTemAdicao //TRP-14/09/07
            IF M->W6_ADICAOK $ cSim  .AND. LEN(aCodValEII) > 1 .AND. WORK_EII->(DBSEEK(aCodValEII[2]))
                DI400Grvddi(SW6->W6_HAWB,SW6->W6_DT,cCod_D_IPI,Work_EII->EII_VLTRIB,0,,,"712")
            ELSE
                DI400Grvddi(SW6->W6_HAWB,SW6->W6_DT,cCod_D_IPI,0,0,,,"712")
            ENDIF
        ENDIF
        //*****************************  I.C.M.S   *****************************

        cCod_D_ICMS := EasyGParam("MV_D_ICMS",,"203")

        nICMS:=0

        WORK_EIJ->(DBGOTOP())
        DO WHILE WORK_EIJ->(!EOF())
            nICMS  +=Work_EIJ->EIJ_VLICMS
            WORK_EIJ->(DBSKIP())
        ENDDO

        IF lTemAdicao //TRP-14/09/07
            IF M->W6_ADICAOK $ cSim  .AND. !EMPTY(nICMS)
                DI400Grvddi(SW6->W6_HAWB,SW6->W6_DT,cCod_D_ICMS,nICMS,0,,,"712")
            ELSE
                DI400Grvddi(SW6->W6_HAWB,SW6->W6_DT,cCod_D_ICMS,0,0,,,"712")
            ENDIF
        ENDIF
        //*****************************  PIS    *****************************

        cCod_D_PIS := EasyGParam("MV_D_PIS",,"204")

        IF lTemAdicao //TRP-14/09/07
            IF M->W6_ADICAOK $ cSim  .AND. LEN(aCodValEII) > 2 .AND. WORK_EII->(DBSEEK(aCodValEII[3]))
                DI400Grvddi(SW6->W6_HAWB,SW6->W6_DT,cCod_D_PIS,Work_EII->EII_VLTRIB,0,,,"712")
            ELSE
                DI400Grvddi(SW6->W6_HAWB,SW6->W6_DT,cCod_D_PIS,0,0,,,"712")
            ENDIF
        ENDIF
        //*****************************  COFINS  *****************************

        cCod_D_COF := EasyGParam("MV_D_COF",,"205")

        IF lTemAdicao //TRP-14/09/07
            IF M->W6_ADICAOK $ cSim .AND. LEN(aCodValEII) > 3 .AND. WORK_EII->(DBSEEK(aCodValEII[4]))
                DI400Grvddi(SW6->W6_HAWB,SW6->W6_DT,cCod_D_COF,Work_EII->EII_VLTRIB,0,,,"712")
            ELSE
                DI400Grvddi(SW6->W6_HAWB,SW6->W6_DT,cCod_D_COF,0,0,,,"712")
            ENDIF
        ENDIF

        //*****************************  TX SISCOMEX  *****************************
        If lTemAdicao //ASK 27/09/2007 - Quando tiver Di eletrônica e o código do siscomex no MV_CODTXSI, gera automatico no SWD.
            cMV_CODTXSI:= EasyGParam("MV_CODTXSI")
            nTxSisco := 0

            If !Empty(cMV_CODTXSI)
                WORK_EIJ->(DBGoTop())
                Do While WORK_EIJ->(!EOF())
                    nTxSisco  +=Work_EIJ->EIJ_TAXSIS
                    WORK_EIJ->(DbSkip())
                EndDo
                If !Empty(nTxSisco)
                    DI400Grvddi(SW6->W6_HAWB,SW6->W6_DT,cMV_CODTXSI,nTxSisco,0,,,"415")
                EndIf
            EndIf
        EndIf
    EndIf
EndIf   

// FDR - 08/11/11 - Geração de titulo NF no Financeiro
// GFP - 03/12/2013 - Inclusão da verificação do parametro MV_TEM_DI, pois parametro MV_EIC0015 depende do MV_TEM_DI para operar corretamente.
// MCF - 16/10/2015 - Inclusão da verificação do parametro MV_EASYFIN.
If EasyGParam("MV_EASYFIN") == "S" .AND. EasyGParam("MV_EIC0015",,.F.) .AND. EasyGParam("MV_TEM_DI",,.F.) .AND. !EMPTY(SW6->W6_DI_NUM) .AND. !EMPTY(SW6->W6_DT) .And. !lEncerrado
   DI500GERNF()
EndIf
DI500EIGrava('GRAVACAO',SW6->W6_HAWB,aAliasCapa)

DI500SWVGrv(.F.)// AWR - Lote

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"FIM_GRAVA_CAPA"),)

SWA->(DbSetOrder(1)) // RS 05/07/07
If SWA->(DbSeek(xFilial("SWA") + M->W6_HAWB + "D" ) )  // RS 05/07/07
   SWA->(RecLock("SWA",.F.))  						  // RS 05/07/07
   SWA->WA_DI_NUM  := M->W6_DI_NUM  					  // RS 05/07/07
   SWA->WA_DTREG_D := M->W6_DTREG_D 					  // RS 05/07/07
   SWA->(MsUnlock())                                   // RS 05/07/07
EndIf
SF1->(DBSETORDER(1))

RETURN .T.

/*
Funcao      : DI501Estorno()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
FUNCTION DI501Estorno()//Antiga DI410Estorno()

LOCAL lMarcou := .F., sInvoice, Ind, Wind,cMoedaFob
LOCAL aInv_CC := {}, a_CC := {},nTotalR:=0,sForn,nxInd, nxInd2 //DRL - 16/09/09 - Invoices Antecipadas
LOCAL sHawb,cPos:="",i
Local cFilSW8:=xFilial("SW8")
Local cFilSW9:=xFilial("SW9")
Local cFilSYS:=xFilial("SYS")
LOCAL aPO_CC  := {}, nTotAdto := 0  //Ref. aos adiantamentos
LOCAL nWk   // ACSJ - 15/07/2004 - é obrigatório declarar a variavei de contagem do comando For/Next como local.
Local cForLoj
Local lRet := .T.
Private cCCAux:="", aInv_CCa := {}, a_CCa := {} //Variáveis utilizadas em RDmake (customização do SYS)

If AvFlags("EIC_EAI")
   aPOs:= {} //regerar PRs do FOB no estorno - DI501SW7Del
EndIf

TRB->(DBGOTOP())
TRB->(DBEVAL({||IF(WKFLAG.OR.WK_OK==cMarca,lMarcou:=.T.,)},,{||!lMarcou}))
TRB->(DBGOTOP())

IF !lMarcou
   Help(" ",1,"E_SEMMARCA")//NENHUM ITEM FOI SELECIONADO PARA O ESTORNO
   Return .F.
ENDIF

lSair:=.F.
If lInvAnt //DRL - 16/09/09 - Invoices Antecipadas
   axQtEW5SW8 := {}
   axEW4      := {}
   EW4->(dBSetOrder(2))
   EW5->(dBSetOrder(1))
   If EW4->(dBSeek(xFilial("EW4")+SW6->W6_HAWB))
      While EW4->(!Eof()).AND.EW4->EW4_FILIAL==xFilial("EW4").AND.EW4->EW4_HAWB==SW6->W6_HAWB
            //---  Separa as Invoices Antecipadas que compõem o embarque...
            If (nxInd2:=aScan(axEW4,{|X|	X[01]==EW4->EW4_INVOIC.AND.X[02]==EW4->EW4_FORN .ANd. x[04]==EICRetLoja("EW4", "EW4_FORLOJ")}))==0
               EW5->(aAdd(axEW4,{EW4->EW4_INVOIC,EW4->EW4_FORN,.T., EICRetLoja("EW4", "EW4_FORLOJ")}))
            EndIf
            //
            //---	Acumula os dados das Invoices Antecipadas que compõem o Processo de Embarque...
            EW5->(dBSeek(xFilial("EW5")+EW4->(EW4_INVOIC+EW4_FORN)))
            While EW5->(!Eof()).AND.EW5->EW5_FILIAL==xFilial("EW5").AND.EW5->(EW5_INVOIC+EW5_FORN)==EW4->(EW4_INVOIC+EW4_FORN)
                  If (nxInd:=aScan(axQtEW5SW8,{|X| X[01]==EW5->EW5_INVOIC	.AND.;
                                              X[02]==EW5->EW5_FORN      .AND.;
                                              X[03]==EW5->EW5_PO_NUM    .AND.;
                                              X[04]==EW5->EW5_POSICAO   .And.;
                                              x[06]==EICRetLoja("EW5", "EW5_FORLOJ")}))==0
                     //--- No primeiro momento, o elemento 5 é FALSO porque o ITEM não foi marcado para deleção...
                     EW5->(aAdd(axQtEW5SW8,{EW5_INVOIC,EW5_FORN,EW5_PO_NUM,EW5_POSICAO,.F., EICRetLoja("EW5", "EW5_FORLOJ")}))
                  EndIf
                  EW5->(dBSkip())
            EndDo
            EW4->(dBSkip())
      EndDo
      //--- Verifica se existe algum produto que foi marcado para ser estornado do processo,
      //    e que pertença a alguma Invoice Antecipada...
      TRB->(dBGoTop())
      While	TRB->(!Eof())
            If !Empty(TRB->W9_INVOICE).AND.(TRB->WKFLAG.OR.TRB->WK_OK==cMarca)
               If (nxInd:=aScan(axQtEW5SW8,{|X|	X[01]==TRB->W9_INVOICE	.AND.;
                                             X[02]==TRB->W7_FORN        .AND.;
                                             X[03]==TRB->W7_PO_NUM      .AND.;
                                             X[04]==TRB->W7_POSICAO .And. ;
                                             x[06]==EICRetLoja("TRB", "W7_FORLOJ")})) > 0
                  //---	Neste momento, o elemento 5 é VERDADEIRO porque o ITEM foi marcado para deleção...
                  axQtEW5SW8[nxInd,05]:=.T.
               EndIf
            EndIf
            TRB->(dBSkip())
      EndDo
      TRB->(dBGoTop())
      //---	Verifica se o usuário não marcou todos os itens de uma mesma Invoice Antecipada
      //    antes de permitir que o estorno seja realizado para evitar que parte da Invoice
      //    Antecipada seja estornada.
      cxMsg:=""
      For nxInd:=1 To Len(axEW4)
          lxFlagAnt:=""
          For nxInd2:=1	To Len(axQtEW5SW8)
              If axQtEW5SW8[nxInd2,1]==axEW4[nxInd,1].AND.axQtEW5SW8[nxInd2,2]==axEW4[nxInd,2].And. axQtEW5SW8[nxInd2,6]==axEW4[nxInd,4]
                 If ValType(lxFlagAnt)=="C".AND.Empty(lxFlagAnt)
                    lxFlagAnt:=axQtEW5SW8[nxInd2,05]
                 EndIf
                 If axQtEW5SW8[nxInd2,05] <> lxFlagAnt
                    //--- O Estorno não pode prosseguir, pois nem todos os itens que pertencem a uma
                    //    Invoice Antecipada foram marcados para serem estornados do processo de embarque.
                    axEW4[nxInd,3]:=.F.
                    cxMsg += STR0017 +AllTrim(axEW4[nxInd,1]) + STR0018 + AllTrim(axEW4[nxInd,2]) + " " + axEW4[nxInd,4] +Chr(13)+Chr(10) // "Invoice: " // " Fornecedor: "
                 EndIf
               EndIf
          Next nxInd2
      Next nxInd
      //
      If !Empty(cxMsg)
         MsgStop(STR0019 + Chr(13) + Chr(10) + Chr(13) + Chr(10) + cxMsg, STR0001) //"O estorno não será permitido, pois nem todos os itens das Invoices abaixo foram selecionados: " ### Atenção
         lSair:=.T.	//---	Variável PRIVATE do EICDI500.PRW.
      EndIf
      //
   EndIf
   EW4->(dBSetOrder(1))
EndIf
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"EXEC_ESTORNO_A"),)
If lSair
   RETURN .F.
EndIf

IF !MsgYesNo(STR0020, STR0021) //"Confirma o estorno?" ### "Estorno de Processo"
   Return .F.
ENDIF

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"EXEC_ESTORNO_B"),)

IF lFinanceiro .Or. lAvIntDesp //wfs - integração EAI
   axFlDelWork:={}
   TP251CriaWork()
   axFl2DelWork:={}
   TP252CriaWork()
ENDIF

If lAvIntDesp//AWR - 2011/06/01 - O AVINTEG deve ser executado fora do Begin Transaction
   oDI500IntProv := AvIntProv():New()
EndIf

Begin Transaction

EICFI400("ANT_GRV_DI","E")
// FDR - 08/11/11 - Geração de titulo NF no Financeiro
If EasyGParam("MV_EIC0015",,.F.) .AND. !EMPTY(SW6->W6_DI_NUM) .AND. !EMPTY(SW6->W6_DT)
   DI500GERNF("E")
EndIf

Processa({|| lRet := DI500SW7Del()}, STR0022) //"Processando estorno..."
If lRet
    EICFI400("POS_GRV_DI","E")
    //igor chiba  02/04/14 ESTORNAR CONTABILIZACAO
    IF EasyGParam('MV_EIC_ECO',,.F.) == 'N' .AND. EasyGParam('MV_EIC0047',,.F.) .And. FindFunction("L500RETREG")
    //aRegs:=L500RETREG(XFILIAL('SW6'),SW6->W6_HAWB,"'101','501','504'",'') //comentado por wfs
    aRegs:=L500RETREG(XFILIAL('SW6'),SW6->W6_HAWB,"'101','111','501','512','504','513'",'') //processos sem cobertura cambial
    L500CANCTB(aRegs)
    ENDIF

    IF lTem_ECO
    SYS->(DbSetOrder(1))//YS_FILIAL+YS_TPMODU+YS_TIPO+YS_HAWB+YS_FORN+YS_MOEDA+YS_INVOICE+YS_CC
    SYS->(DbSeek( cFilSYS+"IH"+M->W6_HAWB ) )
    DO While !SYS->(EOF()) .AND. SYS->YS_FILIAL==cFilSYS .AND. SYS->YS_HAWB==M->W6_HAWB
        If SYS->YS_TIPO <> "P"  // GFC - 06/08/04
        SYS->(RecLock("SYS",.F.,.T.))
        SYS->(DBDELETE())
        SYS->(MSUnlock())
        EndIf
        SYS->(DBSKIP())
    EndDO

    SYS->( DbSeek( cFilSYS+"II"+ M->W6_HAWB ) )
    DO While !SYS->(EOF()) .AND. SYS->YS_FILIAL==cFilSYS .AND. SYS->YS_HAWB==M->W6_HAWB
        If SYS->YS_TIPO <> "P"  // GFC - 06/08/04
        SYS->(RecLock("SYS",.F.,.T.))
        SYS->(DBDELETE())
        SYS->(MSUnlock())
        EndIf
        SYS->(DBSKIP())
    EndDO

    IF lCposAdto .AND. SYS->( DbSeek( cFilSYS+"IA"+ M->W6_HAWB ) )
        DO While !SYS->(EOF()) .AND. SYS->YS_FILIAL==cFilSYS .AND. SYS->YS_HAWB==M->W6_HAWB
            If SYS->YS_TIPO <> "P"  // GFC - 06/08/04
            SYS->(RecLock("SYS",.F.,.T.))
            SYS->(DBDELETE())
            SYS->(MSUnlock())
            EndIf
            SYS->(DBSKIP())
        ENDDO
    ENDIF
    ENDIF

    IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ESTORNA_SYS_A"),)

    // So entra se for estorno parcial.
    SW9->(DbSetOrder(1))
    SW8->(DbSetOrder(1))
    IF SW8->(DbSeek(cFilSW8+M->W6_HAWB))

    IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"EXEC_ESTORNO_E"),)

    DO While !SW8->(EOF()) .AND. SW8->W8_FILIAL==cFilSW8 .AND.SW8->W8_HAWB  ==M->W6_HAWB

        sInvoice := SW8->W8_INVOICE
        sForn    := SW8->W8_FORN
        sHawb    := SW8->W8_HAWB
        If EICLoja()
        /*cLoja*/cForLoj     := SW8->W8_FORLOJ      //NCF - 22/03/2011
        Else
        /*cLoja*/cForLoj     := ""                  //NCF - 22/03/2011
        EndIf
        aInv_CC  := {}

        //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
        SW9->(DbSeek(cFilSW9+sInvoice+sForn+cForLoj+sHawb))

        IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"CORR_SEEK_SW9_01"),)

        nTaxaFob:=1
        cMoedaFob:=SW9->W9_MOE_FOB

        IF EMPTY(SW9->W9_TX_FOB)
            nTaxaFob:=BuscaTaxa(cMoedaFob,DI500DtTxInv(),,.F.,.T.)//.T. GFC
        ELSE
            nTaxaFob:=SW9->W9_TX_FOB
        ENDIF

        DO While !SW8->(EOF()) .AND. SW8->W8_FILIAL  == cFilSW8  .AND.;
                                    SW8->W8_INVOICE == sInvoice .AND.;
                                    SW8->W8_FORN    == sForn    .And.;
                                    (!EICLoja() .Or. SW8->W8_FORLOJ == cForLoj)

            cCCAux:=SW8->W8_CC

            IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"EXEC_ESTORNO_C"),)

            IF lTem_ECO
                Ind:= ASCAN(aInv_CC,{|Tab| Tab[1] + Tab[2] == SW8->W8_INVOICE + cCCAux} )
                IF Ind == 0
                AADD( aInv_CC,{ SW8->W8_INVOICE , cCCAux, DI500Trans(SW8->W8_QTDE * SW8->W8_PRECO) } )
                ELSE
                aInv_CC[Ind,3]+= DI500Trans(SW8->W8_QTDE * SW8->W8_PRECO)
                ENDIF

                Ind:= ASCAN(a_CC,{|Tab|Tab[1]+Tab[2]+Tab[3] == cCCAux+SW8->W8_FORN+cMoedaFob .And. (!EICLoja() .Or. Tab[5] == cForLoj)} )
                IF Ind == 0
                AADD(a_CC,{cCCAux,SW8->W8_FORN,cMoedaFob,DI500Trans(SW8->W8_QTDE * SW8->W8_PRECO)*nTaxaFob, EICRetLoja("SW8", "W8_FORLOJ") } )
                ELSE
                a_CC[Ind,4]+=DI500Trans(SW8->W8_QTDE * SW8->W8_PRECO)*nTaxaFob
                ENDIF

                IF lCposAdto .AND. SWA->(dbSeek(xFilial() + SW8->W8_PO_NUM + "  A"))
                nTotAdto += DI500Trans(SW8->W8_QTDE * SW8->W8_PRECO)
                Ind:= ASCAN(aPO_CC,{|Tab| Tab[1]+Tab[2]+Tab[3] == cCCAux+SW8->W8_FORN+cMoedaFob .And. (!EICLoja() .Or. Tab[5] == cForLoj)} )
                IF Ind == 0
                    AADD( aPO_CC,{ cCCAux,SW8->W8_FORN,cMoedaFob,DI500Trans(SW8->W8_QTDE * SW8->W8_PRECO), EICRetLoja("SW8", "W8_FORLOJ")} )
                ELSE
                    aPO_CC[Ind,4]+= DI500Trans(SW8->W8_QTDE * SW8->W8_PRECO)
                ENDIF
                ENDIF
            ENDIF
            nTotalR+=DI500Trans(SW8->W8_QTDE * SW8->W8_PRECO)*nTaxaFob

            IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"EXEC_ESTORNO_D"),)

            SW8->( DBSKIP() )
        ENDDO

        IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"EXEC_ESTORNO_G"),)

        FOR Wind = 1 TO LEN(aInv_CC)
            SYS->(RecLock("SYS",.T.))
            SYS->YS_FILIAL  := cFilSYS
            SYS->YS_TPMODU  := "I"      //Modulo I=Importacao E=Exportacao(Campo Chave)
            SYS->YS_TIPO    := "I"      //Invoice
            SYS->YS_HAWB    := M->W6_HAWB
            SYS->YS_FORN    := SW8->W8_FORN
            If EICLoja()
                SYS->YS_FORLOJ := SW8->W8_FORLOJ
            EndIf
            SYS->YS_MOEDA   := SW9->W9_MOE_FOB
            SYS->YS_INVOICE := aInv_CC[Wind,1]
            SYS->YS_CC      := aInv_CC[Wind,2]
            SYS->YS_PERC    := aInv_CC[Wind,3] / SW9->W9_FOB_TOT
            SYS->(MSUnlock())
        NEXT

    ENDDO

    IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"EXEC_ESTORNO_H"),)

    IF lTem_ECO
    FOR Wind = 1 TO LEN(a_CC)
        SYS->(RecLock("SYS",.T.))
        SYS->YS_FILIAL  := cFilSYS
        SYS->YS_TPMODU  := "I"      //Modulo I=Importacao E=Exportacao(Campo Chave)
        SYS->YS_TIPO    := "H"
        SYS->YS_HAWB    := M->W6_HAWB
        SYS->YS_CC      := a_CC[Wind,1]
        SYS->YS_FORN    := a_CC[Wind,2]
        If EICLoja()
            SYS->YS_FORLOJ := a_CC[Wind,5]
        EndIf
        SYS->YS_MOEDA   := a_CC[Wind,3]
        SYS->YS_PERC    := a_CC[Wind,4] / nTotalR
        SYS->(MSUnlock())
    NEXT

        // Geracao do TIPO = A no SYS ref. aos pagamentos antecipados
    FOR Wind = 1 TO LEN(aPO_CC)
        SYS->(RecLock("SYS",.T.))
        SYS->YS_FILIAL  := cFilSYS
        SYS->YS_TPMODU  := "I"      //Modulo I=Importacao E=Exportacao(Campo Chave)
        SYS->YS_MOEDA   := aPO_CC[Wind,3]
        SYS->YS_TIPO    := "A"
        SYS->YS_HAWB    := M->W6_HAWB
        SYS->YS_CC      := aPO_CC[Wind,1]
        SYS->YS_FORN    := aPO_CC[Wind,2]
        If EICLoja()
            SYS->YS_FORLOJ := aPO_CC[Wind, 5]
        EndIf
        SYS->YS_PERC    := aPO_CC[Wind,4] / nTotAdto
        SYS->(MSUnlock())
    NEXT
    ENDIF
    ENDIF

Else
    ELinkRollBackTran()
EndIf

End Transaction

If lAvIntDesp//AWR - 2011/06/01 - O AVINTEG deve ser executado fora do Begin Transaction
   oDI500IntProv:Grava()
   oDI500IntProv := NIL
EndIf

***** DELETAR ARQUIVO DA FUNCAO AV POS_DI() E AVPOS_PO(), QDO TEM CONTROLE DE TRANSACAO
IF lFinanceiro
   If Select("WorkTP") # 0
      IF TYPE("axFl2DelWork") = "A" .AND. LEN(axFl2DelWork) > 0
         WorkTP->(E_EraseArq(axFl2DelWork[1]))
         FOR nWk:=2 TO LEN(axFl2DelWork)
             //FERASE(axFl2DelWork[nWk]+TEOrdBagExt())
             E_EraseArq(axFl2DelWork[nWk]+TEOrdBagExt()) //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados
         NEXT
      ENDIF
   ENDIF
   //JMS - 23/06/04 - PARA APAGAR OS ARQUIVOS DO EICTP251.
   If Select("Work_1") # 0 .AND. Select("Work_2") # 0
      IF TYPE("axFlDelWork") = "A" .AND. LEN(axFlDelWork) > 0
         Work_1->(E_EraseArq(axFlDelWork[1]))
         Work_2->(E_EraseArq(axFlDelWork[3]))
         FOR nWk:=2 TO LEN(axFlDelWork)
             //FERASE(axFlDelWork[nWk]+TEOrdBagExt())
             E_EraseArq(axFlDelWork[nWk]+TEOrdBagExt()) //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados
         NEXT
      ENDIF
   ENDIF
ENDIF
*******************
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"EXEC_ESTORNO_F"),)
IF AvFlags("EIC_EAI") .and. Len(aEnv_PO) > 0
   /* Verifica se existem pedidos originados por processo de entreposto e
      retorna os pedidos válidos para a geração da programação de entregas*/
   aEnv_PO:= PO420PedOri(aEnv_PO)
   For i = 1 To Len(aEnv_PO) //SSS -  REG 4.5 03/06/14
       If !EICPO420(.T.,4,,"SW2",.F.,aEnv_PO[I])// EICPO420(lEnvio,nOpc,aCab,cAlias,lWk,cPo_num)
          cPos+=ALLTRIM(aEnv_PO[I])+", "
       EndIf
   Next
   If !Empty(cPos)
      MsgInfo(StrTran(STR0095, "####", cpos), STR0053) //"Acesse os Purchase orders "+cpos+" para realização dos ajustes necessários.")
   EndIf

   aEnv_PO:= {}
ENDIF
//IGOR CHIBA  estorno da contabilizacao 02/07/14
IF EasyGParam("MV_EIC_ECO",,'N') == 'N'  .AND. EasyGParam('MV_EIC0047',,.F.) .And. FindFunction("L500GERCTB")//se o modulo sigaeco estiver desligado //IGOR CHIBA
   lChangeEmb:=.T.
   L500GERCTB('TE')
ENDIF
DbSelectArea("SW6")
TRB->(DBGOTOP())

Return lRet

/*
Funcao      : DI501GrvInvoice()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
FUNCTION DI501GrvInvoice()//Antiga Di400_Gr_Inv

LOCAL cFilSYS:=xFilial("SYS")
LOCAL cFilSW7:=xFilial("SW7"), nOrdSW7:=SW7->(IndexOrd())
LOCAL cFilSW8:=xFilial("SW8"), nDel, Wind
LOCAL cFilSW9:=xFilial("SW9")
LOCAL nTotSW7_R:=nCont  :=nTotPeso:=nDif_Tot:=0
LOCAL aPO_CC  := {}, nTotAdto := 0
Local cSQLChv := ""
Private cMoedaFob,nTaxaFob,nTotalR:=0
Private aInv_CC:={}, a_CC:={}, cForn, cInvoice, cCCAux:="", aInv_CCa := {}, a_CCa := {} //Variáveis utilizadas em RDmake (customização do SYS)

SW9->(DBSETORDER(3))
SW9->(DBSEEK(xFilial()+M->W6_HAWB))
ProcRegua(10)
Work_SW8->(DBSETORDER(1))

If lIntDraw
   ED4->(dbSetOrder(2))
EndIf

If AVFLAGS("DUIMP") .And. M->W6_TIPOREG == '2'
   AjSldLotes("ALT")                                //Ajusta os saldos dos lotes da DUIMP já validados antes da efetivação nas tabelas físicas.   
EndIf

SW7->(dbSetOrder(4))
SW8->(DBSETORDER(1))
SW8->(DBSEEK(xFilial()+M->W6_HAWB))
DO WHILE SW8->(!EOF()) .AND. SW8->W8_HAWB   == M->W6_HAWB .AND.;
                             SW8->W8_FILIAL == cFilSW8
   IF nCont > 10
      ProcRegua(10) ; nCont:=0
   ENDIF
   nCont++
   IncProc(StrTran(STR0023, "####", AllTrim(SW8->W8_COD_I))) //"Excluindo o item #### da Invoice."

   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"DELETA_SW8"),)

   If lIntDraw .and. !Empty(SW8->W8_AC) .AND. cRegDI == "S" //AAF 13/09/05 - Verifica se a DI estava registrada.
      ED4->(dbSeek(cFilED4+SW8->W8_AC+SW8->W8_SEQSIS))
      If ED0->ED0_AC <> ED4->ED4_AC .or. cFilED0 <> ED0->ED0_FILIAL
         ED0->(dbSetOrder(2))
         ED0->(dbSeek(cFilED0+ED4->ED4_AC))
      EndIf

      //** AAF 27/09/06 - Verifica se o registro já está travado.
      If !ED4->( isLocked() )
         ED4->(RecLock("ED4",.F.))
      EndIf
      //**

      If ED0->ED0_TIPOAC <> GENERICO .or. ED4->ED4_NCM <> NCM_GENERICA
         ED4->ED4_QT_DI  += SW8->W8_QT_AC
         If AvVldUn(ED4->ED4_UMNCM) // MPG - 06/02/2018
            If SW7->(dbSeek(cFilSW7+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM))
               ED4->ED4_SNCMDI += SW7->W7_PESO * SW8->W8_QTDE
            Else//AAF 14/07/05 - Utiliza o Peso do Item que foi excluido, para voltar o saldo no A.C.
               If (nPos:= aScan(aPesoDrawback, {|X| X[1] == SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM})) > 0
                  ED4->ED4_SNCMDI += aPesoDrawback[nPos][2] * SW8->W8_QTDE
               Endif
            Endif
         Else
            ED4->ED4_SNCMDI += SW8->W8_QT_AC2
         EndIf
      EndIf
      ED4->ED4_VL_DI  += SW8->W8_VL_AC

      If GetModAtoC(SW8->W8_AC) == "1"        //NCF - 15/08/2019 - Só gera saldo a exportar quando modalidade = Suspensão
         //AOM - 29/09/10
         If ED4->(FieldPos("ED4_SNCMEX")) > 0
            ED4->ED4_SNCMEX -= SW8->W8_QT_AC2
         EndIf

         If ED4->(FieldPos("ED4_SQTDEX")) > 0
            ED4->ED4_SQTDEX -= SW8->W8_QT_AC
         EndIf
      EndIf

      ED4->(msUnlock())

      If cAntImp=="2" .and. ED0->ED0_MODAL == "1"//GFC - 17/07/2003 - Anterioridade Drawback
         DIGrvAnt(2,SW8->W8_HAWB,SW8->W8_PO_NUM,SW8->W8_INVOICE,SW8->W8_COD_I,SW8->W8_POSICAO,SW8->W8_PGI_NUM)
      EndIf

   EndIf

   SW8->(RecLock("SW8",.F.,.T.))
   SW8->(DBDELETE())
   SW8->(MSUnlock())
   SW8->(DBSKIP())
ENDDO

SW7->(dbSetOrder(nOrdSW7))
SW9->(DBSETORDER(1))
If lInvAnt //DRL - 16/09/09 - Invoices Antecipadas
   EW4->(DBSETORDER(1))
EndIf

DO WHILE SW9->(!EOF()) .AND. SW9->W9_HAWB   == M->W6_HAWB .AND.; //GFC 22/12/03 - Passado para baixo para Integridade Referencial.
                             SW9->W9_FILIAL == cFilSW9
   IF nCont > 10
      ProcRegua(10) ; nCont:=0
   ENDIF
   nCont++
   IncProc(STR0024 + SW9->W9_INVOICE) //"Excluindo registros da Invoice: "

   IF !Work_SW8->(DBSEEK(SW9->W9_INVOICE+SW9->W9_FORN+SW9->W9_FORLOJ))
	  //DRL - 16/09/09 - Invoices Antecipadas
      If lInvAnt .And. EW4->(dbSeek(XFILIAL("EW4")+SW9->W9_INVOICE+SW9->W9_FORN+SW9->W9_FORLOJ)) .AND. EW4->EW4_HAWB == SW9->W9_HAWB //AAF 27/12/2019 - Validar se a invoice antecipada realmente é deste embarque. Pode ser de outro com o mesmo nro.
         EW4->(RECLOCK("EW4",.F.))
         EW4->EW4_HAWB := SPACE(AVSX3("EW4_HAWB",3))
         EW4->(MSUNLOCK())
      ENDIF

      IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"DELETA_SW9"),)
       //**igor chiba 29/09/09
      IF LCAMBIO_EIC
         EW4->(DBSETORDER(1))
         cChave:=cFilSW9+SW9->W9_HAWB+SW9->W9_INVOICE+SW9->W9_FORN
         cSQLChv:="W9_FILIAL  = '" + cFilSW9         + "' AND " +;
                  "W9_HAWB    = '" + SW9->W9_HAWB    + "' AND " +;
                  "W9_INVOICE = '" + SW9->W9_INVOICE + "' AND " +;
                  "W9_FORN    = '" + SW9->W9_FORN    + "' "
         IF !EW4->(DBSEEK(XFILIAL('EW4')+SW9->W9_INVOICE+SW9->W9_FORN))	.AND.	lEICFI06  //se Ñ tiver invoice antecipada itegrar qualquer alteração na invoice
            If FindFunction("EICINTEI17")
               EasyExRdm("EICINTEI17", 'E','INV',cChave,"EX",cSQLChv)               
            EndIf
         ENDIF
      ENDIF
      //**
      SW9->(RecLock("SW9",.F.))
      SW9->(DBDELETE())
      SW9->(MSUnlock())
   ENDIF
   SW9->(DBSKIP())
ENDDO
ProcRegua(LEN(aDeletados))

FOR nDel := 1 TO LEN(aDeletados)
    IF !EMPTY(aDeletados[nDel,2]) .AND. aDeletados[nDel,1] = "SW9"
        cAlias:=aDeletados[nDel,1]
        IncProc(STR0024 + SW9->W9_INVOICE) //"Excluindo registros da Invoice: "
        SW9->(DBGOTO(aDeletados[nDel,2]))
        If lInvAnt .And. EW4->(dbSeek(xFilial("EW4")+SW9->W9_INVOICE+SW9->W9_FORN+SW9->W9_FORLOJ)) .AND. EW4->EW4_HAWB == SW9->W9_HAWB //AAF 27/12/2019 - Validar se a invoice antecipada realmente é deste embarque. Pode ser de outro com o mesmo nro. //DRL - 16/09/09 - Invoices Antecipadas
           EW4->(RecLock("EW4",.F.))
           EW4->EW4_HAWB := Space(AVSX3("EW4_HAWB",3))
           EW4->(MsUnlock())
        EndIf
        IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"DELETA_SW9"),)
//      IF(M->W6_TIPOFEC # "DIN",FI400MOVCONT("INVOICE","E"),)
          //**igor chiba 29/09/09
        IF LCAMBIO_EIC
           EW4->(DBSETORDER(1))
           cChave:=cFilSW9+SW9->W9_HAWB+SW9->W9_INVOICE+SW9->W9_FORN
           cSQLChv:="W9_FILIAL  = '" + cFilSW9         + "' AND " +;
                    "W9_HAWB    = '" + SW9->W9_HAWB    + "' AND " +;
                    "W9_INVOICE = '" + SW9->W9_INVOICE + "' AND " +;
                    "W9_FORN    = '" + SW9->W9_FORN    + "' "
           IF !EW4->(DBSEEK(XFILIAL('EW4')+SW9->W9_INVOICE+SW9->W9_FORN))	.AND.	lEICFI06  //se Ñ tiver invoice antecipada itegrar qualquer alteração na invoice
              If FindFunction("EICINTEI17")
                  EasyExRdm("EICINTEI17", 'E','INV',cChave,"EX",cSQLChv)
              EndIf
           ENDIF
        ENDIF
        //**
        SW9->(RECLOCK(cAlias,.F.))
        SW9->(DBDELETE())
        SW9->(MSUNLOCK())
    ENDIF
NEXT

IncProc(STR0025) //"Atualizando arquivo de controle..."

IF lTem_ECO
SYS->(DbSetOrder(1))
SYS->(DbSeek(cFilSYS+"IH"+M->W6_HAWB))//YS_FILIAL+YS_TPMODU+YS_TIPO+YS_HAWB+YS_FORN+YS_MOEDA+YS_INVOICE+YS_CC
DO While !SYS->(EOF()) .AND. SYS->YS_FILIAL==cFilSYS .AND. SYS->YS_HAWB==M->W6_HAWB
   IncProc(STR0033+' '+SYS->YS_INVOICE)
   If SYS->YS_TIPO <> "P"  // GFC - 06/08/04
   SYS->(RecLock("SYS",.F.,.T.))
   SYS->(DBDELETE())
   SYS->(MSUnlock())
   EndIf
   SYS->(DBSKIP())
ENDDO

SYS->(DbSeek(cFilSYS+"II"+M->W6_HAWB))//YS_FILIAL+YS_TPMODU+YS_TIPO+YS_HAWB+YS_FORN+YS_MOEDA+YS_INVOICE+YS_CC
DO While ! SYS->(EOF()) .AND. SYS->YS_FILIAL==cFilSYS .AND. SYS->YS_HAWB==M->W6_HAWB
   IncProc(STR0033+' '+SYS->YS_INVOICE)
   If SYS->YS_TIPO <> "P"  // GFC - 06/08/04
   SYS->(RecLock("SYS",.F.,.T.))
   SYS->(DBDELETE())
   SYS->(MSUnlock())
   EndIf
   SYS->(DBSKIP())
   ENDDO

SYS->(DbSeek(cFilSYS+"IA"+M->W6_HAWB))//YS_FILIAL+YS_TPMODU+YS_TIPO+YS_HAWB+YS_FORN+YS_MOEDA+YS_INVOICE+YS_CC
DO While ! SYS->(EOF()) .AND. SYS->YS_FILIAL==cFilSYS .AND. SYS->YS_HAWB==M->W6_HAWB
   IncProc(STR0033+' '+SYS->YS_INVOICE)
   If SYS->YS_TIPO <> "P"  // GFC - 06/08/04
   SYS->(RecLock("SYS",.F.,.T.))
   SYS->(DBDELETE())
   SYS->(MSUnlock())
   EndIf
   SYS->(DBSKIP())
End
ENDIF

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ESTORNA_SYS_B"),)

Work_SW9->(DBSETORDER(1))
Work_SW8->(DBSETORDER(1))

ProcRegua(Work_SW8->(EasyReccount("Work_SW8")))
SW7->(DBSETORDER(4))
Work_SW8->(DBGOTOP())
ProcRegua(50)
nCont:=0
nQuanTot:=0
nTotalItem:=Work_SW8->(EasyRecCount("Work_SW8"))
DO WHILE !Work_SW8->(EOF())

   IF nCont > 50
      ProcRegua(50) ; nCont:=0
   ENDIF
   nCont++
   IF EMPTY(Work_SW8->WKFLAGIV) .OR.  EMPTY(Work_SW8->WKINVOICE)
      nQuanTot++
      IncProc("Lidos: "+STR(nQuanTot,10)+" / "+STR(nTotalItem,10))
      Work_SW8->(DBSKIP())
      LOOP
   ENDIF
   cInvoice  := Work_SW8->WKINVOICE
   cForn     := Work_SW8->WKFORN
   cLoja     := Work_SW8->W8_FORLOJ
   aInv_CC   := {}

   //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
   IF !Work_SW9->(DBSEEK(cInvoice+cForn+cLoja))
      nQuanTot++
      IncProc("Lidos: "+STR(nQuanTot,10)+" / "+STR(nTotalItem,10))
      Work_SW8->(DBSKIP())
      LOOP
   ENDIF
   IF EMPTY(WORK_SW9->WK_RECNO)
      SW9->(RecLock("SW9",.T.))
   ELSE
      SW9->(DBGOTO(WORK_SW9->WK_RECNO))
      SW9->(RecLock("SW9",.F.))
   ENDIF
   AVREPLACE("Work_SW9","SW9")
   SW9->W9_HAWB   :=M->W6_HAWB
   SW9->W9_FILIAL :=xFilial("SW9")
   SW9->W9_NOM_FOR:=BuscaFabr_Forn(SW9->W9_FORN, SW9->W9_FORLOJ)

   cMoedaFob:=WORK_SW9->W9_MOE_FOB
   IF EMPTY(Work_SW9->W9_TX_FOB)
      nTaxaFob:=BuscaTaxa(cMoedaFob,dDataBase,,.F.,.T.)//.T. GFC
   ELSE
      nTaxaFob:=Work_SW9->W9_TX_FOB
   ENDIF

   SW9->(msUnlock())         //GFC 22/12/03 - Integridade Referencial
   SW9->(FKCOMMIT())		 //JWJ 21/07/05 - Força o Commit no banco (integridade referencial)
   SW9->(RecLock("SW9",.F.))
   DO WHILE !Work_SW8->(EOF()) .AND. Work_SW8->WKINVOICE == cInvoice .AND.;
                                     Work_SW8->WKFORN    == cForn    .And.;
                                     Work_SW8->W8_FORLOJ == cLoja
         nQuanTot++
         IncProc(STR0026 + STR(nQuanTot,10)+" / "+STR(nTotalItem,10)) // "Lidos: "
      SW8->(RecLock("SW8",.T.))
      AVREPLACE("Work_SW8","SW8")
      DI500GrvWkSW8(.T.)
      SW8->W8_FILIAL   :=  cFilSW8
      SW8->W8_HAWB     :=  M->W6_HAWB
      SW8->W8_PRECO_R  :=  DI500Trans(Work_SW8->WKPRECO * Work_SW8->WKQTDE,2) * SW9->W9_TX_FOB
      If lCposNVEPLI
         SW8->W8_NVE := Work_SW8->WKNVE
      EndIf
      SW8->W8_FORLOJ:= WORK_SW8->W8_FORLOJ
      SW8->W8_FABLOJ:= WORK_SW8->W8_FABLOJ
      //FSM - 01/09/2011 - "Peso Bruto Unitário"
      If lPesoBruto
         SW8->W8_PESO_BR := Work_SW8->WKW8PESOBR
      EndIf

      // BAK - Gravando da work da Invoice para a tabela da Invoice
      If SW8->(FieldPos("W8_CODMAT")) > 0 .And. AvFlags("SUFRAMA") .And. EasyGParam("MV_TEM_DI", ,.F.)
         SW8->W8_CODMAT := Work_SW8->WKCODMATRI
      EndIf

      nTotPeso  +=Work_SW8->WKPESOTOT

      If lIntDraw
         If !Empty(Work_SW8->WKAC) .And. GetModAtoC(SW8->W8_AC) == "1" .AND. !Empty(M->W6_DI_NUM) .AND.;
            (( ED4->ED4_FILIAL == cFilED4 .AND. Work_SW8->WKAC == ED4->ED4_AC .AND. Work_SW8->WKSEQSIS == ED4->ED4_SEQSIS ) .OR.;
            ED4->(dbSeek(cFilED4+Work_SW8->WKAC+Work_SW8->WKSEQSIS)) )

            If ED0->ED0_AC <> ED4->ED4_AC .or. cFilED0 <> ED0->ED0_FILIAL
               ED0->(dbSetOrder(2))
               ED0->(dbSeek(cFilED0+ED4->ED4_AC))
            EndIf

            //** AAF 27/09/06 - Verifica se o registro já está travado.
            If !ED4->( isLocked() )
               ED4->(RecLock("ED4",.F.))
            EndIf
            //**

            SW5->(dbSetOrder(8))    //GFC - 16/07/2003 - Pegar dados da LI e não calcular mais.
            SW5->(dbSeek(cFilSW5+Work_SW8->WKPGI_NUM+Work_SW8->WKPO_NUM+Work_SW8->WKPOSICAO))
            Do While !SW5->(EOF()) .and. SW5->W5_SEQ <> 0
               SW5->(dbSkip())
            EndDo
            If SW5->W5_SEQ == 0
               //** PLB 18/07/07 - Baixa o saldo com as quantidades iguais as da PLI, respeitando a proporção
               nCoef := Work_SW8->WKQTDE / SW5->W5_QTDE

               If ED0->ED0_TIPOAC <> GENERICO  .Or.  ED4->ED4_NCM <> NCM_GENERICA
                  SW8->W8_QT_AC  := nCoef * SW5->W5_QT_AC
                  SW8->W8_QT_AC2 := nCoef * SW5->W5_QT_AC2
                  ED4->ED4_QT_DI  -= SW8->W8_QT_AC
                  ED4->ED4_SNCMDI -= SW8->W8_QT_AC2
               EndIf

               SW8->W8_VL_AC   := nCoef * SW5->W5_VL_AC
               ED4->ED4_VL_DI  -= SW8->W8_VL_AC

               If ED4->(FieldPos("ED4_SNCMEX")) > 0
                  ED4->ED4_SNCMEX += SW8->W8_QT_AC2
	           EndIf

	           If ED4->(FieldPos("ED4_SQTDEX")) > 0
                  ED4->ED4_SQTDEX += SW8->W8_QT_AC
               EndIf
            EndIf
            ED4->(msUnlock())
            SW5->(dbSetOrder(1))
            If cAntImp=="2" .and. ED0->ED0_MODAL == "1" //GFC - 17/07/2003 - Anterioridade Drawback
               DIGrvAnt(1,M->W6_HAWB,Work_SW8->WKPO_NUM,Work_SW8->WKINVOICE,Work_SW8->WKCOD_I,Work_SW8->WKPOSICAO,Work_SW8->WKPGI_NUM,SW8->W8_QT_AC,M->W6_DTREG_D,ED4->ED4_AC,ED4->ED4_SEQSIS,ED4->ED4_PD)
            EndIf
            AtuValidade()
         EndIf
      EndIf
      IF lAltDescricao .AND. !EMPTY(Work_SW8->WKDESC_DI)
         MSMM(,AVSX3("W8_DESC_VM",3),,Work_SW8->WKDESC_DI,1,,,"SW8","W8_DESC_DI")
      ENDIF

      cCCAux:=Work_SW8->WKCC

      IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GRAVA_SW8_A"),)

      SW8->(MSUnlock())

      IF lTem_ECO
         Ind:= ASCAN(aInv_CC,{|Tab|Tab[1]+Tab[4]+Tab[2]==Work_SW8->WKINVOICE+Work_SW8->WKFORN+cCCAux})
         IF Ind == 0
            AADD(aInv_CC,{Work_SW8->WKINVOICE,cCCAux,DI500Trans(Work_SW8->WKPRECO * Work_SW8->WKQTDE),Work_SW8->WKFORN,EICRetLoja("Work_SW8", "W8_FORLOJ")})
         ELSE
            aInv_CC[Ind,3]+= DI500Trans(Work_SW8->WKPRECO * Work_SW8->WKQTDE)
         ENDIF

         Ind:= ASCAN(a_CC,{|Tab|Tab[1]+Tab[2]+Tab[3] == cCCAux+Work_SW8->WKFORN+cMoedaFob .And. (!EICLoja() .Or. Tab[5] == Work_SW8->W8_FORLOJ)} )
         IF Ind == 0
            AADD(a_CC,{cCCAux,Work_SW8->WKFORN,cMoedaFob,DI500Trans(SW8->W8_QTDE * SW8->W8_PRECO)*nTaxaFob, EICRetLoja("Work_SW8", "W8_FORLOJ") } )
         ELSE
            a_CC[Ind,4]+= DI500Trans(SW8->W8_QTDE * SW8->W8_PRECO)*nTaxaFob
         ENDIF

         IF lCposAdto .AND. SWA->(dbSeek(xFilial() + SW8->W8_PO_NUM + "  A"))
            nTotAdto += DI500Trans(SW8->W8_QTDE * SW8->W8_PRECO)
            Ind:= ASCAN(aPO_CC,{|Tab| Tab[1]+Tab[2]+Tab[3] == cCCAux+SW8->W8_FORN+cMoedaFob .And. (!EICLoja() .Or. SW8->W8_FORLOJ == Tab[5])} )
            IF Ind == 0
               AADD( aPO_CC,{ cCCAux,SW8->W8_FORN,cMoedaFob,DI500Trans(SW8->W8_QTDE * SW8->W8_PRECO), EICRetLoja("SW8", "W8_FORLOJ")} )
            ELSE
               aPO_CC[Ind,4]+= DI500Trans(SW8->W8_QTDE * SW8->W8_PRECO)
            ENDIF
         ENDIF
      ENDIF

      nTotalR+=DI500Trans(SW8->W8_QTDE * SW8->W8_PRECO)*nTaxaFob
      Work_SW8->(DBSKIP())
   ENDDO

   If lInvAnt //DRL - 16/09/09 - Invoices Antecipadas
      EW4->(DBSETORDER(1))
      If EW4->(DBSEEK(xFilial("EW4")+SW9->W9_INVOICE+SW9->W9_FORN+SW9->W9_FORLOJ)) .And. Empty(EW4->EW4_HAWB)
         EW4->(RecLock("EW4",.F.))
         EW4->EW4_HAWB := M->W6_HAWB
         EW4->(MsUnlock())
      EndIf
   EndIf
   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GRAVA_SW9_A"),)
     //**igor chiba integrando alteração ou inclusao de invoices
   IF LCAMBIO_EIC
      EW4->(DBSETORDER(2))
      cChave:=cFilSW9+M->W6_HAWB+WORK_SW9->W9_INVOICE+WORK_SW9->W9_FORN
      cSQLChv:="W9_FILIAL  = '" + cFilSW9              + "' AND " +;
               "W9_HAWB    = '" + M->W6_HAWB           + "' AND " +;
               "W9_INVOICE = '" + WORK_SW9->W9_INVOICE + "' AND " +;
               "W9_FORN    = '" + WORK_SW9->W9_FORN    + "' "
      IF !lGravaFin_EIC //se nao tiver cambio automatico integra invoice
         IF !EMPTY(WORK_SW9->WK_RECNO)
            IF !EW4->(DBSEEK(XFILIAL('EW4')+M->W6_HAWB+WORK_SW9->W9_INVOICE+WORK_SW9->W9_FORN))	.AND.	lEICFI06  //se Ñ tiver invoice antecipada itegrar
               If FindFunction("EICINTEI17")
                  EasyExRdm("EICINTEI17", 'A','INV',cChave,"AB",cSQLChv)//INTEGRANDO INVOICE                  
               EndIf
            ENDIF
         ELSE
            IF !EW4->(DBSEEK(XFILIAL('EW4')+M->W6_HAWB+WORK_SW9->W9_INVOICE+WORK_SW9->W9_FORN))	.AND.	lEICFI06  //se Ñ tiver invoice antecipada itegrar
               If FindFunction("EICINTEI17")
                  EasyExRdm("EICINTEI17", 'I','INV',cChave,"AB",cSQLChv)
               EndIf
            ENDIF
         ENDIF
      ENDIF
   ENDIF
   //**
   SW9->(MSUnlock())
   SW9->(FKCOMMIT())			//JWJ 21/07/05 - Força um commit no banco - integridade referencial.

   FOR Wind = 1 TO LEN(aInv_CC)
       SYS->(RecLock("SYS",.T.))
       SYS->YS_FILIAL  := xFilial("SYS")
       SYS->YS_TPMODU  := "I"      //Modulo I=Importacao E=Exportacao(Campo Chave)
       SYS->YS_TIPO    := "I"
       SYS->YS_HAWB    := M->W6_HAWB
       SYS->YS_INVOICE := aInv_CC[Wind,1]
       SYS->YS_MOEDA   := SW9->W9_MOE_FOB
       SYS->YS_CC      := aInv_CC[Wind,2]
       SYS->YS_FORN    := aInv_CC[Wind,4]
       If EICLoja()
          SYS->YS_FORLOJ := aInv_CC[Wind,5]
       EndIf
       SYS->YS_PERC    := aInv_CC[Wind,3] / SW9->W9_FOB_TOT
       SYS->(MSUnlock())
   NEXT

   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GRAVA_SW9_B"),)

ENDDO

If lIntDraw      //GFC - 16/07/2003 - Alterado de lugar.
   ED4->(dbSetOrder(1))
EndIf

AtuVlDI(M->W6_HAWB)

IF lTem_ECO
ProcRegua(LEN(a_CC)+1)
FOR Wind = 1 TO LEN(a_CC)
    IncProc(STR0022) //"Processando estorno..."
    SYS->( RecLock("SYS",.T.))
    SYS->YS_FILIAL  := cFilSYS
    SYS->YS_TPMODU  := "I"      //Modulo I=Importacao E=Exportacao(Campo Chave)
    SYS->YS_TIPO    := "H"
    SYS->YS_HAWB    := M->W6_HAWB
    SYS->YS_CC      := a_CC[Wind,1]
    SYS->YS_FORN    := a_CC[Wind,2]
    If EICLoja()
       SYS->YS_FORLOJ := a_CC[Wind,5]
    EndIf
    SYS->YS_MOEDA   := a_CC[Wind,3]
    SYS->YS_PERC    := a_CC[Wind,4] /nTotalR
    SYS->(MSUnlock())
NEXT

ProcRegua(LEN(aPO_CC)+1)
FOR Wind = 1 TO LEN(aPO_CC)
    IncProc(STR0022) //"Processando estorno..."
    SYS->( RecLock("SYS",.T.))
    SYS->YS_FILIAL  := cFilSYS
    SYS->YS_TPMODU  := "I"      //Modulo I=Importacao E=Exportacao(Campo Chave)
    SYS->YS_TIPO    := "A"
    SYS->YS_HAWB    := M->W6_HAWB
    SYS->YS_CC      := aPO_CC[Wind,1]
    SYS->YS_FORN    := aPO_CC[Wind,2]
    IF EICLoja()
       SYS->YS_FORLOJ := aPO_CC[Wind,5]
    EndIf
    SYS->YS_MOEDA   := aPO_CC[Wind,3]
    SYS->YS_PERC    := aPO_CC[Wind,4] /nTotAdto
    SYS->(MSUnlock())
NEXT
ENDIF
IncProc(STR0022) //"Processando estorno..."

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"FIM_DELETA_SW8"),)
//If lCallSap                            //MJB-SAP-1000
//   AVR3Invoice(aMR8M,MForn,"Work_SW8") //MJB-SAP-1000
//Endif                                  //MJB-SAP-1000

aPesoDrawback := {} //AAF 14/07/05

RETURN .T.

/*
Funcao      : DI501Despes()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
Function DI501Despes(Alias,nReg,nOpc)

LOCAL nOldArea:=SELECT()
Local bAddWork := {|| TRB->(dbAppend()), DI500D_Grava("TRB") }
Local cNomeTemp :="", i, i6, nWk // do FOR
LOCAL cAlias:="SWD"
LOCAL aCoresLocal,nI
LOCAL aEnchoEAI     := {"WD_DT_VENC","WD_GERFIN","WD_FORN","WD_LOJA","WD_CTRFIN1","WD_BASEADI","WD_PAGOPOR","WD_CTRFIN1","WD_VL_COMP","WD_VLLIQ"}//CAMPOS QUE IRAO APARECER NA TELA IGOR CHIBA 04/07/14
Local aOrdTRB := {} //LRS - 10/10/2018
local nPOsDelA := 0
Private oDlgGen // DFS - Criação da variável Private para que seja possível alteração via ponto de entrada
PRIVATE aSemSX3 := { {"RECNO", "N",10, 0} }, oPanel
PRIVATE lNaoAltera :=.T. //Para incluir uma Nova Despesa através do Botão F3
PRIVATE lGerPrDI := IF(GetNewPar("MV_EASYFDI","S")="S",.T.,.F.)//ASR - 28/09/2005 - Integração EIC x FIN
PRIVATE bCondSWD := {|| SWD->WD_FILIAL == xFilial("SWD") .And. SWD->WD_HAWB == SW6->W6_HAWB}
PRIVATE aCores := {}
PRIVATE oMarkDesp //FDR - 15/04/13
Private lDevDesp := .F. //THTS - 11/08/2017 - Define se trata-se de uma devolucao do despachante

lSair:=.F.
If(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"DESPESA"),)
IF lSair
   RETURN .F.
EndIf

If !DI500PROG()
   Return .F.
EndIf

//PRIVATE cAlias:="SWD"

PRIVATE lTitFinF050 := .F.   // JBS 23/04/2004
PRIVATE aEnchoice   := {"WD_HAWB","WD_DESPESA","WD_DESCDES","WD_DES_ADI",;
                        "WD_VALOR_R","WD_BASEADI","WD_DOCTO","WD_NF_COMP",;
                        "WD_SE_NFC","WD_VL_NFC","WD_DT_NFC","WD_PAGOPOR","WD_DA"}


If lFinanceiro
   IF !FindFunction("FI400TitFin")   // JBS - 23/04/2004
      MSGINFO("Atencao!!! Rotinas que interagem com o financeiro estao desatualizadas!!!" + CHR(13)+CHR(10)+;
              "Favor solicitar um patch do programa EICFI400 p/ Depto Suporte!",)
   ELSE
      lTitFinF050 := .T.
      aEnchoice :={"WD_HAWB","WD_DESCDES","WD_DES_ADI","WD_VALOR_R","WD_DOCTO","WD_NF_COMP","WD_SE_NFC","WD_VL_NFC","WD_DT_NFC","WD_DA","WD_BASEADI","WD_PAGOPOR","WD_GERFIN"} //LGS-08/10/13 - Incluido campo WD_PAGOPOR
   ENDIF                                                                                                                                                                       //LGS-28/10/13 - Incluido campo WD_GERFIN
ENDIF

PRIVATE nOpcao
PRIVATE cPictValor:=X3Picture("WD_VALOR_R")
PRIVATE MSeguro, MImpostos, MAdiant, MOutras, MSaldos, MTot_Ger, MVariacao
PRIVATE aCpos, lAppend:=.F.
// *** Cria variaveis para E_CriaTrab ...
PRIVATE aCampos := Array(SWD->(FCount()))

PRIVATE lBaixaDesp:=.F.,lnoEnvFin:=.T., lAltForn:=.T. // Verifica se esta baixado a Despesa no financeiro

If lAvIntFinEIC
   AADD(aEnchoice,'WD_VALOR_A')
   AADD(aEnchoice,'WD_FGDEBCC')
   AADD(aEnchoice,'WD_FGTITUL')
   AADD(aEnchoice,'WD_CTRLERP')
   AADD(aEnchoice,'WD_TITERP')
   AADD(aEnchoice,'WD_BANCO')
   AADD(aEnchoice,'WD_AGENCIA')
   AADD(aEnchoice,'WD_CONTA')
   AADD(aEnchoice,'WD_BAN_REC')
   AADD(aEnchoice,'WD_AGE_REC')
   AADD(aEnchoice,'WD_CON_REC')
   AAdd(aEnchoice,'WD_VAL_PRE')
EndIf
IF lFinanceiro
   AADD(aEnchoice,"WD_DTENVF")
ENDIF
//RRC - 20/11/2013 - Alteração para a Integração SIGAEIC x SIGAESS
IF lFinanceiro .OR. cPaisLoc # "BRA" .OR. lAvIntFinEIC .Or.  (AvFlags("CONTROLE_SERVICOS_AQUISICAO") .And. EasyGParam("MV_ESS0022",,.T.) .And. SWD->(FieldPos("WD_MOEDA")) > 0 .And. SWD->(FieldPos("WD_VL_MOE")) > 0 .And. SWD->(FieldPos("WD_TX_MOE")) > 0)
   AADD(aEnchoice,"WD_FORN"  )
   AADD(aEnchoice,"WD_LOJA"  )
   If AvFlags("CONTROLE_SERVICOS_AQUISICAO") .And. EasyGParam("MV_ESS0022",,.T.)
      AADD(aEnchoice,"WD_MOEDA"  )
      AADD(aEnchoice,"WD_VL_MOE"  )
      AADD(aEnchoice,"WD_TX_MOE"  )
	  //RMD - 15/09/14 - Exibir o produto associado a despesa na integração com SISCOSERV
      If SWD->(FieldPos("WD_PRDSIS")) > 0
         aAdd(aEnchoice, "WD_PRDSIS")
      EndIf
   EndIf
ENDIF
IF cPaisLoc # "BRA"
   AADD(aEnchoice,"WD_FORNRAT")
ENDIF

//TRP - 07/04/2010
If EasyGParam("MV_RATACRE",,.F.)  .AND. SWD->(FIELDPOS("WD_CODACR ")) # 0 .AND. SWD->(FIELDPOS("WD_DESCACR")) # 0
   AADD(aEnchoice,"WD_CODACR")
   AADD(aEnchoice,"WD_DESCACR")
Endif
//NCF - 27/08/10
IF EasyGParam("MV_EASY",,"N") == "S" .And. lCposNFDesp
   AADD(aEnchoice,"WD_DOC")
   AADD(aEnchoice,"WD_SERIE")
   AADD(aEnchoice,"WD_EMISSAO")
   AADD(aEnchoice,"WD_ESPECIE")
   AADD(aEnchoice,"WD_TIPONFD")
   AADD(aEnchoice,"WD_B1_COD")
EndIf
PRIVATE aHeader := {}
PRIVATE aDeletados := {}, aAlteraSWD := {}, aIncluiSWD := {} // JBS 23/04/2004
PRIVATE aBotoesDesp:={}
PRIVATE lAltDesp := .T. // Bete - 13/03/06

IF(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"MANUT_DESP"),)

If ! SW6->(RecLock("SW6",.F.))
//   Help(" ",1,"REGNLOCK")
   DbSelectArea(nOldArea)
   Return
Endif

IF AvFlags("EIC_EAI")
   For nI:=1 to len(aEnchoEAI)
      IF ASCAN(aEnchoice,aEnchoEAI[nI])  == 0
         AADD(aEnchoice,aEnchoEAI[nI])
      ENDIF
   Next
EndIf

IF AvFlags("EIC_EAI") 
   /* Dados bancários*/
   If SWD->(FieldPos("WD_BANCO")) > 0
      AAdd(aSemSx3, {"WD_BANCO", AvSx3("WD_BANCO", AV_TIPO), AvSx3("WD_BANCO", AV_TAMANHO), AvSx3("WD_BANCO", AV_DECIMAL)})
      AAdd(aSemSx3, {"WD_AGENCIA", AvSx3("WD_AGENCIA", AV_TIPO), AvSx3("WD_AGENCIA", AV_TAMANHO), AvSx3("WD_AGENCIA", AV_DECIMAL)})
      AAdd(aSemSx3, {"WD_CONTA", AvSx3("WD_CONTA", AV_TIPO), AvSx3("WD_CONTA", AV_TAMANHO), AvSx3("WD_CONTA", AV_DECIMAL)})
   EndIf   
   
   /*Status*/
   AAdd(aSemSx3, {"WKSTATUS", "C", 1, 0})      
EndIf

IF lFinanceiro
   AAdd(aSemSx3,{"WKTITNACI","C",3,0}) //LRS - 09/10/2018
   AAdd(aSemSx3,{"WKDOCENTR","C",AVSX3("WD_DOCTO"  ,3),AVSX3("WD_DOCTO"  ,4)}) //LRS - 09/10/2018
EndIF

aAdd(aSemSX3,{"DBDELETE","L",1,0}) //THTS - 01/11/2017 - Este campo deve sempre ser o ultimo campo da Work
cNomeTemp := E_CriaTrab(cAlias,aSemSX3)  // Criacao do arquivo de Trabalho
IndRegua("TRB",cNomeTemp+TEOrdBagExt(),"WD_HAWB+WD_DESPESA")

//igor chiba req 5.8   17/07/14
IF AvFlags("EIC_EAI")
   IF SELECT('ADIANT') <> 0
      ADIANT->(DBCLOSEAREA())
   ENDIF
   aSemSx3  := {}
   aHeadAdnt:= {}
   AADD(aSemSx3,{"WD_DESPESA","C",AVSX3("WD_DESPESA",3),AVSX3("WD_DESPESA",4)})
   AADD(aSemSx3,{"WD_DESCDES","C",AVSX3("WD_DESCDES",3),AVSX3("WD_DESCDES",4)})
   AADD(aSemSx3,{"WD_DES_ADI","D",AVSX3("WD_DES_ADI",3),AVSX3("WD_DES_ADI",4)})
   AADD(aSemSx3,{"WD_VALOR_R","N",AVSX3("WD_VALOR_R",3),AVSX3("WD_VALOR_R",4)})
   AADD(aSemSx3,{"WD_SALDO"  ,"N",AVSX3("WD_VALOR_R"  ,3),AVSX3("WD_VALOR_R",4)})
   AADD(aSemSx3,{"WD_VL_COMP","N",AVSX3("WD_VL_COMP",3),AVSX3("WD_VL_COMP",4)})
   AADD(aSemSx3,{"WD_CTRFIN1","C",AVSX3("WD_CTRFIN1",3),AVSX3("WD_CTRFIN1",4)})
   AADD(aSemSx3,{"WD_DOCTO"  ,"C",AVSX3("WD_DOCTO"  ,3),AVSX3("WD_DOCTO"  ,4)})
   AADD(aSemSx3,{"WK_SEQBX"  ,AvSx3("EW7_SEQBX", AV_TIPO), AvSx3("EW7_SEQBX", AV_TAMANHO), AvSx3("EW7_SEQBX", AV_DECIMAL)})
   AADD(aSemSx3,{"WK_RECADNT","N",10,0})  //RECNO DA SWD 901 OU 902
   AADD(aSemSx3,{"WK_RECSWD" ,"N",10,0})  //RECNO DA DESPESA ORIGINARIA
   
   cArqAdant := E_CriaTrab(,aSemSx3,"ADIANT") //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados

   IndRegua("ADIANT", cArqAdant + TEOrdBagExt(), "WD_DESPESA+WK_SEQBX")

   SX3->(DBSETORDER(2))
   For nI:=1 to len(aSemSx3)
      cCpo   := aSemSx3[nI][1]

      IF cCpo == 'WD_SALDO'
         AADD(aHeadAdnt,{'Saldo'       ,"WD_SALDO"   ,AVSX3("WD_VALOR_R"  ,6),AVSX3("WD_VALOR_R"  ,3),AVSX3("WD_VALOR_R"  ,4) ,NIL,NIL,AVSX3("WD_VALOR_R"  ,2) ,NIL,NIL})
      ELSEIF SX3->(dbSeek(cCpo))
         AADD(aHeadAdnt,{SX3->X3_TITULO,SX3->X3_CAMPO,SX3->X3_PICTURE        ,SX3->X3_TAMANHO        ,SX3->X3_DECIMAL         ,NIL,NIL,SX3->X3_TIPO            ,NIL,NIL})
      ENDIF
   Next

ENDIF

DBSELECTAREA("SWD")
SWD->(DBSETORDER(1))

// *** Grava arquivo de Trabalho ...
SWD->(dbSeek(xFilial()+SW6->W6_HAWB))
SWD->(dbEval(bAddWork,,bCondSWD))
// ***
SYB->(dbSetOrder(1))

PRIVATE oSeguro, oOutras, oImpostos, oAdiant, oTot_Ger, oSaldos, oVariacao
// JBS - 28/04/2004 - Alterei para Carregar Array com AADD, linha a linha
aCpos:= {}
AADD(aCpos, {{|| TRB->WD_DESPESA+" "+if(SYB->(dbSeek(xFilial()+TRB->WD_DESPESA)),SYB->YB_DESCR,"")},,AVSX3("WD_DESPESA",5)})
AADD(aCpos, {"WD_DES_ADI",,AVSX3("WD_DES_ADI",5)})       //"Data"
AADD(aCpos, {"WD_VALOR_R",,AVSX3("WD_VALOR_R",5),cPictValor}) //"Valor R$"
AADD(aCpos, {{|| If(TRB->WD_BASEADI$cSim, STR0027, STR0028)},,AVSX3("WD_BASEADI",5)})  //Sim ### Não //"Adianta/o ?"
If lAvIntFinEIC
   aAdd(aCpos, {'WD_VALOR_A',,AvSx3('WD_VALOR_A',AV_TITULO),cPictValor})
EndIf

AADD(aCpos, {"WD_DOCTO"  ,,AVSX3("WD_DOCTO"  ,5)}) //"Documento"
AAdd(aCpos, {"WD_VLADNUM",,AvSx3("WD_VLADNUM", AV_TITULO), cPictValor}) //THTS - 10/08/2017 - antes este campo so aparecia para integracao EAI, agora aparece para todos

If AvFlags("EIC_EAI")
   AAdd(aCpos, {"WD_VLLIQ"  ,,AvSx3("WD_VLLIQ"  , AV_TITULO), cPictValor})
   AAdd(aCpos, {"WD_VL_COMP",,AvSx3("WD_VL_COMP", AV_TITULO), cPictValor})
EndIf

//RRC - 20/11/2013 - Adicionada condição para Integração SIGAEIC x SIGAESS relativo a despesas
IF lFinanceiro .OR. cPaisLoc # "BRA" .OR. lAvIntFinEIC .Or. (AvFlags("CONTROLE_SERVICOS_AQUISICAO") .And. EasyGParam("MV_ESS0022",,.T.) .And. SWD->(FieldPos("WD_MOEDA")) > 0 .And. SWD->(FieldPos("WD_VL_MOE")) > 0 .And. SWD->(FieldPos("WD_TX_MOE")) > 0)
   AADD(aCpos, {"WD_FORN"  ,,AVSX3("WD_FORN"  ,5)}) //"Fornecedor"
   AADD(aCpos, {"WD_LOJA"  ,,AVSX3("WD_LOJA"  ,5)}) //"Loja"
Endif
IF lFinanceiro
   AADD(aCpos, {{|| If(TRB->WD_GERFIN$cSim, STR0027, STR0028)},,AVSX3("WD_GERFIN",5) } ) //"Fornecedor"
Endif
AADD(aCpos, {"WD_NF_COMP",,AVSX3("WD_NF_COMP",5)}) //"Nota Fiscal"
//LRS - 04/09/2015 - Nopado o Transform, colocado o campo no Array sem Transform
//AADD(aCpos, {{|| Transform(WD_SE_NFC,AvSX3("F1_SERIE",AV_PICTURE)) } ,,AVSX3("WD_SE_NFC" ,5)}) //"Serie"
AADD(aCpos,{"WD_SE_NFC",,AVSX3("WD_SE_NFC" ,5)})
IF AvFlags("EIC_EAI") .Or. lFinanceiro //IGOR chiba quando esta integrado com eai 04/07/14 - RNLP 27/11/20 - OSSME-5370 - Financeiro habilitado
   AADD(aCpos, {"WD_CTRFIN1",,AVSX3("WD_CTRFIN1",5)}) //NUM DUPLI
ENDIF

AADD(aCpos, {{||AVCOMBO("WD_DA",IF(EMPTY(TRB->WD_DA),"2",TRB->WD_DA))},,AVSX3("WD_DA",5) } )

If lFinanceiro
   AADD(aCpos, {"WD_DTENVF",,AVSX3("WD_DTENVF",5)       } ) //"Data envio Fianceiro"   
Endif

If lAvIntFinEIC
   AADD(aCpos,{{||BSCXBOX('WD_FGTITUL',TRB->WD_FGTITUL)},,AvSx3('WD_FGTITUL',AV_TITULO)})
   AADD(aCpos,{'WD_CTRLERP'                           ,,AvSx3('WD_CTRLERP',AV_TITULO)})
   AADD(aCpos,{'WD_TITERP'                            ,,AvSx3('WD_TITERP' ,AV_TITULO)})
   AADD(aCpos,{{||BSCXBOX('WD_FGDEBCC',TRB->WD_FGDEBCC)},,AvSx3('WD_FGDEBCC',AV_TITULO)})
   AADD(aCpos,{'WD_BANCO'                             ,,AvSx3('WD_BANCO'  ,AV_TITULO)})
   AADD(aCpos,{'WD_AGENCIA'                           ,,AvSx3('WD_AGENCIA',AV_TITULO)})
   AADD(aCpos,{'WD_CONTA'                             ,,AvSx3('WD_CONTA'  ,AV_TITULO)})
   AADD(aCpos,{'WD_BAN_REC'                           ,,AvSx3('WD_BAN_REC',AV_TITULO)})
   AADD(aCpos,{'WD_AGE_REC'                           ,,AvSx3('WD_AGE_REC',AV_TITULO)})
   AADD(aCpos,{'WD_CON_REC'                           ,,AvSx3('WD_CON_REC',AV_TITULO)})
EndIf

//TRP - 07/04/2010
If EasyGParam("MV_RATACRE",,.F.)  .AND. SWD->(FIELDPOS("WD_CODACR ")) # 0 .AND. SWD->(FIELDPOS("WD_DESCACR")) # 0
   AADD(aCpos, {"WD_CODACR",,AVSX3("WD_CODACR",5)       } ) //"Codigo Acrescimo"
   AADD(aCpos, {"WD_DESCACR",,AVSX3("WD_DESCACR",5)     } ) //"Descricao Acrescimo"
Endif

IF EasyGParam("MV_EASY",,"N") == "S" .And. lCposNFDesp
   AADD(aCpos, {"WD_DOC"    ,,AVSX3("WD_DOC",5)       } ) //"Nota Fiscal da Despesa"
//LRS - 04/09/2015 - Nopado o Transform, colocado o campo no Array sem Transform
//   AADD(aCpos, {{|| Transform(WD_SERIE,AvSX3("F1_SERIE",AV_PICTURE)) }  ,,AVSX3("WD_SERIE",5)     } ) //"Série da Nota Fiscal"
   AADD(aCpos, {"WD_SERIE"  ,,AVSX3("WD_SERIE",5)})
   AADD(aCpos, {"WD_EMISSAO",,AVSX3("WD_EMISSAO",5)   } ) //"Data de Emissão"
   AADD(aCpos, {"WD_ESPECIE",,AVSX3("WD_ESPECIE",5)   } ) //"Especie"
   AADD(aCpos, {"WD_TIPONFD",,AVSX3("WD_TIPONFD",5)   } ) //"Tipo NF Desp"
   AADD(aCpos, {"WD_B1_COD" ,,AVSX3("WD_B1_COD",5)    } ) //"Cod.Produto"
EndIf

aOrdTRB := SaveOrd("TRB",1) 
IF lFinanceiro
   TRB->(dbGoTop())
   DO While TRB->(!Eof())
      IF TRB->WD_DA == "1" .AND. SW6->W6_TIPOFEC == "DA "
         AADD(aCpos, {"WKTITNACI"  ,,"Titulo na fase de nacionalização"})
         Exit
      ElseIF TRB->WD_DA == "1" .AND. SW6->W6_TIPOFEC == "DIN"
         AADD(aCpos, {"WKDOCENTR"  ,,"Docto - Entreposto"})
         Exit
      EndIF
   TRB->(dbSkip())
   EndDo
EndIF 
RestOrd(aOrdTRB,.T.)

If Type("lAvIntDesp") == "L" .And. lAvIntDesp
   oDI500IntProv:= AvIntProv():New()
EndIf

IF(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"CAMPOS_WD"),)

EICFI400("ANT_TELA_DESP")

dbSelectArea("TRB")
dbGoTop()

DO While (.T.)
   nOpcao := 1
   aBotoesDesp := {}
   SW2->(DBSETORDER(1))
   lAltDesp:=.t.
   IF (MOpcao # FECHTO_NACIONALIZACAO .AND.;
      (Val(SW6->W6_TIPODES) >= 2 .And. Val(SW6->W6_TIPODES) <= 4) .AND.;
      SW2->(DBSEEK(xFilial("SW2")+LEFT("DA"+SW6->W6_DI_NUM,LEN(SW2->W2_PO_NUM)))) ) //ASR - 14/10/2005 - SW2->(DBSEEK(xFilial("SW2")+"DA"+SW6->W6_DI_NUM,ALLTRIM(X3Picture("W6_DI_NUM"))))
      //lAltDesp:=.t.  // TLM 20/05/2006 Tratamento do rateio das despesas do entreposto.
   EndIf
   IF !EMPTY(SW6->W6_DT_ENCE) .AND. !lTem_ECO
     lAltDesp := .f.
   Endif

   IF(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"ANTES_TELA_DESP"),)  // Bete 13/03/06
   If ! lAltDesp
       cTitJan:= STR0029 + " - "+If(EMPTY(SW6->W6_DT_ENCE), STR0030, Alltrim(SubStr(STR0036, 1,at("-", STR0036)-1))) // JBS - 22/12/2004 //Manutenção ### "D.A. em fase de nacionalização." ### "Processo encerrado. Deseja alterá-lo?"
   Else
      cTitJan:= STR0029
   EndIf

   aCores:= LegDespesa()

      //IGOR CHIBA 04/07/14 passagem de botoes para açoes relacionadas
   IF lAltDesp
      Aadd( aBotoesDesp,{ "SIMULACAO", {|| DI500DespManut(2),oMarkDesp:oBrowse:Refresh()}, STR0031, STR0031}) //"Incluir","Incluir"
      Aadd( aBotoesDesp,{ "SIMULACAO", {|| DI500DespManut(3),oMarkDesp:oBrowse:Refresh()}, STR0032, STR0032}) //"Alterar","Alterar"
      Aadd( aBotoesDesp,{ "SIMULACAO", {|| DI500DespManut(4),oMarkDesp:oBrowse:Refresh()}, STR0033, STR0033}) //"Excluir","Excluir"
      Aadd( aBotoesDesp,{ "SIMULACAO", {|| DI500DespManut(7),oMarkDesp:oBrowse:Refresh()}, STR0239, STR0239}) //"Visualizar", "Visualizar"
      //Aadd( aBotoesDesp,{ "SIMULACAO", {|| DI500DespManut(5),oMarkDesp:oBrowse:Refresh()}, STR0034, STR0034}) //"Relatorio","Relatorio"
      Aadd( aBotoesDesp,{ "SIMULACAO", {|| DI500DespManut(6),oMarkDesp:oBrowse:Refresh()}, STR0037, STR0037}) //"Gerar Arquivo","Gerar Arquivo"

      IF AvFlags("EIC_EAI") //IGOR CHIBA REQ 5.8 14/07/14
         Aadd( aBotoesDesp,{ "SIMULACAO", {|| CA150PCNT(2),oMarkDesp:oBrowse:Refresh()}, STR0038, STR0038}) //"Prestação de Contas"   ,"Prestação de Contas"
         Aadd( aBotoesDesp,{ "SIMULACAO", {|| CA150PCNT(4),oMarkDesp:oBrowse:Refresh()}, STR0039, STR0039}) //"Cancelar Prestação de Contas","Cancelar Prestação de Contas"
         Aadd( aBotoesDesp,{ "SIMULACAO", {|| CA150PCNT(5),oMarkDesp:oBrowse:Refresh()}, STR0040, STR0040}) //"Desbloquear Título de Despesa","Desbloquear Título de Despesa"
         If EasyFindAdpt("EICFI414") //THTS - 10/08/2017 - Opcao de "Devolução do Despachante" quando integrado ao Logix
            AAdd( aBotoesDesp,{ "SIMULACAO", {|| DI501DevDe()}, STR0259, STR0259}) //"Devolução do Despachante, "Devolução do Despachante"
         EndIf
         AAdd( aBotoesDesp,{ "SIMULACAO", {|| DI501LegDesp()}, STR0240, STR0240}) //"Legenda", "Legenda"
      ELSEIF lFinanceiro .AND. cPaisLoc == "BRA"
         Aadd( aBotoesDesp,{ "SIMULACAO", {|| nOpcao:=2,oDlgGen:End(),oMarkDesp:oBrowse:Refresh()}, STR0038, STR0038}) //"Prestação de Contas", "Prestação de Contas"
      ENDIF
   EndIf

   //MCF - 23/12/2015 - Perdimento de versão
   //LRS - 22/04/2015 - Retirada da validação para aparecer o botão relatório mesmo com a data de encerramento preenchida.
   Aadd( aBotoesDesp,{ "SIMULACAO", {|| DI500DespManut(5),oMarkDesp:oBrowse:Refresh()}, STR0034, STR0034}) //"Relatorio","Relatorio"

If !isMemVar("lDespAuto") .or. !lDespAuto
   oMainWnd:ReadClientCoords()
   DEFINE MSDIALOG oDlgGen TITLE cTitJan ; //"Manuten‡Æo"
      FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
      OF oMainWnd PIXEL

      @ 00,00 MsPanel oPanel Prompt "" Size 60,52 of oDlgGen

      DI500D_Tela(.T.)

      IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"TELA_DESP"),) //-BHF-04/11/08

       //TDF - 03/01/12 - Guarda a variável aCores pois os fontes da TOTVS podem deixá-la como NIL causando error
      If ValType(aCoresLocal) == "U" .And. ValType(aCores) == "A"
         aCoresLocal := aClone(aCores)
      EndIf

      //by GFP - 30/09/2010 :: 11:53 - Inclusão da função para carregar campos criados pelo usuario.
      aCpos := AddCpoUser(aCpos,"SWD","2",,.T.)

      oMarkDesp:= MSSELECT():New("TRB",,,aCpos,lInverte,cMarca,{55,4,(oDlgGen:nClientHeight-6)/2,(oDlgGen:nClientWidth-4)/2},,,,,If(Len(aCoresLocal)>0,aCoresLocal,)) // - BHF - 04/11/08
      IF ! lAltDesp
         oMarkDesp:bAval := {|| .T. }
      Else
         oMarkDesp:bAval := {|| DI500DespManut(3),oMarkDesp:oBrowse:Refresh()}
      EndIf

      oPanel:Align:=CONTROL_ALIGN_TOP //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
      oMarkDesp:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT 	 //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
      oMarkDesp:oBrowse:Refresh()

   ACTIVATE MSDIALOG oDlgGen ON INIT (EnchoiceBar(oDlgGen,{||nOpcao:= 1,oDlgGen:End()},{||nOpcao:= 0,oDlgGen:End()},.F.,aBotoesDesp),;
                                      oMarkDesp:oBrowse:Refresh())//FDR - 17/08/11 //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

Else
   lRet := .T.
   DI500D_Tela(.T.)
   For i := 1 TO Len(aCabItem)
      nPOsDelA := aScan(aCabItem[i], {|x| x[1] == "AUTDELETA" .AND. x[2] == "S" })
      If EasySeekAuto("SWD", aCabItem[i], 1)
         if EasySeekAuto("TRB", aCabItem[i], 1)
            If nPOsDelA > 0
               lRet := lRet .and. DI500DespManut(4,aCabItem[i])
            Else 
               lRet := lRet .and. DI500DespManut(3,aCabItem[i]) 
            EndIf
         endif
      ElseIf nPOsDelA == 0
         lRet := lRet .and. DI500DespManut(2,aCabItem[i]) 
      Endif
   Next i

   If lRet
      nOpcao := 1
   Else
      nOpcao := 1
   EndIf
EndIf
   lLoop:=.F.
   IF(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,If(nOpcao == 0, "CANCELA_DESPESA", "CONFIRMA_DESPESA")),)
   If lLoop
      Loop
   ENDIF

   IF lFinanceiro .AND. cPaisLoc = "BRA" .AND. nOpcao == 2   // JBS - 27/04/2004 - OS 0028/04 - 0655/04

      //FDR - 06/10/2012
      If SW2->W2_HAWB_DA == SW6->W6_HAWB
         MsgInfo(STR0041, STR0001)//"Este processo possui nacionalização e as alterações realizadas deverão ser replicadas manualmente em seus respectivos processos de nacionalização." ### Atenção
         //LOOP
      EndIf

      IF !EICFI400("PRESTACAO_DE_CONTAS_1")
         LOOP
      ENDIF

      dbSelectArea("SWD")
      FOR i6 := 1 TO FCount()
          M->&(FIELDNAME(i6)) := CRIAVAR(FIELDNAME(i6))
      NEXT i6

      EICFI400("PRESTACAO_DE_CONTAS_2")
      LOOP

   ENDIF

   If nOpcao == 1   // *** Clicou em Ok // JBS - 23/04/2004
      //INICIO DA TRANSACAO

      Begin Transaction

         IF !lFinanceiro
             // EOS - p/ manter compatibilidade com a versao anterior por causa do ponto de entrada
            TRB->(dbGoTop())
            DO While TRB->(!Eof())
               SWD->(dbGoTo(TRB->RECNO))
               IF(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"CONFIRMA"),)
               TRB->(dbSkip())
            EndDo
         ENDIF

         If len(aIncluiSWD) > 0 .or. len(aAlteraSWD) > 0 .or. len(aDeletados) > 0
            IF EasyGParam("MV_EASYFIN",,"N") $ cSim // Jonato OS 1188/03 Ocorrência 0111/03
               If SW6->W6_TIPOFEC <> "DIN"
                  DeleImpDesp(SW6->W6_NUMDUP,"PRE","DI",.T.)
               EndIf

               EICFI400("POS_GRV_DESP")

               axFl2DelWork:={}
               If SW6->W6_TIPOFEC <> "DIN"
                  cControle := "Inclusao"
                  Processa({|| AVPOS_DI(SW6->W6_HAWB,lGerPrDI) })//ASR - 28/09/2005 - Integração EIC x FIN - antes testa a MV_EASYFDI - Processa({|| AVPOS_DI(SW6->W6_HAWB,.T.) })
               EndIf

            ENDIF
            EvalTrigger()
         EndIf
      End Transaction
      ***** DELETAR ARQUIVO DA FUNCAO AV POS_DI(), QDO TEM CONTROLE DE TRANSACAO
      IF lFinanceiro
         If Select("WorkTP") # 0
            IF TYPE("axFl2DelWork") = "A" .AND. LEN(axFl2DelWork) > 0
               WorkTP->(E_EraseArq(axFl2DelWork[1]))
               FOR nWk:=2 TO LEN(axFl2DelWork)
                   //FERASE(axFl2DelWork[nWk]+TEOrdBagExt())
                   E_EraseArq(axFl2DelWork[nWk]+TEOrdBagExt()) //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados
               NEXT
           ENDIF
         ENDIF
      ENDIF
      *******************
   EndIf
   /* Exclusão das despesas provisórias referentes às despesas incluídas no processo.
      Mesmo que o usuário não confirme, deve ser verificado se existem despesas porvisórias
      a serem excluídas pois, uma vez integrada com o ERP, a despesa na SWD é efetivada.*/
   If Type("lAvIntDesp") == "L" .And. lAvIntDesp
      oDI500IntProv:Grava()
      oDI500IntProv := NIL
   EndIf

   Exit
EndDo

TRB->(E_EraseArq(cNomeTemp))

//igor chiba req 5.8
IF SELECT('ADIANT') # 0
   ADIANT->(E_EraseArq(cArqAdant))
ENDIF

DBSELECTAREA(nOldArea)

//RRC - 20/11/2013 - Integração SIGAEIC x SIGAESS relativo a despesas
If nOpcao == 1 .And. AvFlags("CONTROLE_SERVICOS_AQUISICAO") .And. EasyGParam("MV_ESS0022",,.T.) .And. SWD->(FieldPos("WD_MOEDA")) > 0 .And. SWD->(FieldPos("WD_VL_MOE")) > 0 .And. SWD->(FieldPos("WD_TX_MOE")) > 0
   DI500ESS(SW6->W6_HAWB,nOpc)
EndIf

SW6->(MSUnlock())

Return Nil

/*
Funcao      : DI501DespManut()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
Function DI501DespManut(nOpcao,aAutoCab)

Local lRet:= .T.
Local oExcDesp, nOpExc := 0  // GFP - 26/08/2013
Local lDesp903 := AvFlags("EIC_EAI") .And. EasyFindAdpt("EICFI414") .And. TRB->WD_DESPESA == "903" //THTS - 15/08/2017
Private lNaoNFCompl:= EasyGParam("MV_AVG0160",.T.) .AND. EasyGParam("MV_AVG0160",,.F.)  //TRP-31/07/2008- Caso parâmetro seja .T., não permite que seja gerada nota complementar
                                                                                           // caso já tenha sido gerada nota única.
PRIVATE dDat01:=CTOD(""),dDat02:=CTOD("")
//MFR 25/03/2019 OSSME-2692
PRIVATE lAltera700 := .F.
PRIVATE lExclui700 := .F.
   If nOpcao == 2 // Incluir

      If  lFinanceiro
         If !ValUserDesp("SWD","WD_GERFIN",nOpcao)
            Return .F.
         EndIf
      EndIF

      If ( !isMemVar("lDespAuto") .or. !lDespAuto)
      DO WHILE DI500D_Edi(.T.)
      ENDDO
      Else
         DI500D_Edi(.T.,aAutoCab)
      EndIf
   Elseif nOpcao == 3  // Alterar

      If lDesp903 //THTS - 15/08/2017
            MsgInfo(STR0260,STR0001) //"Despesa 903 (Devolução do Despachante) não pode sofrer alteração!"###"Atenção"
            Return .F.
      EndIf

   //Acb - 20/07/2010
      If  lFinanceiro
         If !ValUserDesp("SWD","WD_GERFIN",nOpcao)
            Return .F.
         EndIf
      EndIF

	  lSair:=.F.
      IF(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"DESP_ALTERA1"),)
	  IF lSair
         Return
      ENDIF

      //FDR - 06/10/2012
      If SW2->W2_HAWB_DA == SW6->W6_HAWB
         MsgInfo(STR0041,STR0001)//"Este processo possui nacionalização e as alterações realizadas deverão ser replicadas manualmente em seus respectivos processos de nacionalização."
         //Return .F.
      EndIf
                                                           //MFR 09/03/2020 OSSME-4151 
      If TRB->WD_DA == "1" .AND. (SW6->W6_TIPOFEC == "DIN" /*.AND. !Empty(TRB->WD_DOCTO)*/ .OR. TRB->WD_DESPESA == "901") //FDR - 05/10/12
         Help(" ",1,"AVG0000104")
         Return
      EndIf


       If lAvIntFinEIC .AND. !Empty(TRB->WD_TITERP) .AND.;
         (EW6->(dbSetOrder(1), dbSeek(xFilial("EW6")+'DRL'+SW6->W6_HAWB+TRB->WD_TITERP)) .OR. EW6->(dbSetOrder(2), dbSeek(xFilial("EW6")+'DRL'+SW6->W6_HAWB+TRB->WD_TITERP)))
         MsgStop(STR0042, STR0001) // "Processo já possui compensação de despesas. Faça o estorno da compensação na rotina de Envio de Despesas."
         Return
      EndIf
                                         //MFR 26/03/2019 OSSME-2692   
      If TRB->WD_DESPESA $ "701|702|703" .and. !lAltera700
         if EICCambAut(Alltrim(TRB->WD_DESPESA))
            MsgStop( STR0269 , STR0001) //"Despesas 701,702 e 703 não podem sofrer alterações pois são geradas automaticamente pelo sistema para controle de variação cambial do FOB, Frete ou Seguro!"
            Return .F.
         endif
      EndIf

      If ( !isMemVar("lDespAuto") .or. !lDespAuto )
         DI500D_Edi(.F.)
      Else
         DI500D_Edi(.F.,aAutoCab)
      EndIf
   Elseif nOpcao == 4  // Excluir

      If lDesp903 //THTS - 15/08/2017
            MsgInfo(STR0261,STR0001) //"Despesa 903 (Devolução do Despachante) não pode ser excluída!"###"Atenção"
            Return .F.
      EndIf

   //Acb - 20/07/2010
      If  lFinanceiro
         If !ValUserDesp("SWD","WD_GERFIN",nOpcao)
            Return .F.
         EndIf
      EndIF


      IF AvFlags("EIC_EAI") //IGOR CHIBA REQ 5.8 14/07/14
         IF !EMPTY(TRB->WD_CODINT) .AND. TRB->WD_BASEADI == '1' .AND. TRB->WD_PAGOPOR == '1'

            IF !EMPTY(TRB->WD_CTRFIN1) .AND.  !EMPTY(TRB->WD_CTRFIN2)
               MSGALERT(STR0043, STR0001) //"Esta despesa foi compensada com um adiantamento ao despachante. Para excluí-la é necessário cancelar a Prestação de Contas."
               RETURN
            ENDIF

            IF (EMPTY(TRB->WD_CTRFIN1) .AND.  EMPTY(TRB->WD_CTRFIN2)) .OR.  (!EMPTY(TRB->WD_CTRFIN1) .AND.  EMPTY(TRB->WD_CTRFIN2))
               IF !MSGYESNO(STR0044,) //"Esta é uma despesa base de adiantamento e sua exclusão, possivelmente, deixará saldo do adiantamento realizado ao despachante. Deseja prosseguir?."
                  RETURN
               ENDIF
            ENDIF

         ENDIF
      ENDIF

	  lSair:=.F.
      IF(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"DESP_EXCLUI1"),)
	  IF lSair
         Return
      ENDIF

      If TRB->WD_DA == "1" .AND. SW6->W6_TIPOFEC = "DIN"//AWR
         Help(" ",1,"AVG0000104")
         Return .F.
      EndIf
      If lAvIntFinEIC
         If !Empty(TRB->WD_TITERP) .OR. Upper(Left(AllTrim(TRB->WD_CTRLERP),7)) == "ENVIADO"
            MsgStop(STR0045) //"Despesa não pode ser excluída poís já foi enviada ao ERP. Faça o estorno do Envio ao Financeiro ERP."
            Return .F.
         EndIf

         If (TRB->WD_DESPESA == "902" .Or. TRB->WD_DESPESA == "903") .And. TRB->WD_GERCMP == "1" //DRL 09/06/10 - Nao pode ser excluido se foi criado pelo sistema
            MsgStop(STR0046) // "Despesa não pode ser excluída pois foi gerada automaticamente pela rotina de compensação."
            Return .F.
         EndIf

      EndIf
      //Se for adiantamento a despachante
      If TRB->WD_DESPESA == "901" .And. TRB->WD_NUMERA  //  MPG - 06/03/2018 só deleta quando não for numerário
          MsgInfo(STR0047,STR0001) //"Despesa não pode ser diretamente excluída. Adiantamento a despachante deve ser excluído via solicitação de numerário."
          Return .F.
      EndIf
                                          //MFR 26/03/2019 OSSME-2692
      If TRB->WD_DESPESA $ "701|702|703" .and. !lExclui700
         if EICCambAut(Alltrim(TRB->WD_DESPESA))
            MsgStop(STR0270 , STR0001) //"Despesas 701,702 e 703 não podem ser excluídas manualmente pois são geradas automaticamente pelo sistema para controle de variação cambial do FOB, Frete ou Seguro!"
            Return .F.
         endif
      EndIf

      //NCF - 27/08/2010
      IF EasyGParam("MV_EASY",,"N") == "S" .And. lCposNFDesp
         If !EMPTY(TRB->WD_DOC)
            SF1->(DBSETORDER(1))
            IF SF1->(DBSEEK(xFILIAL("SF1")+AVKEY(TRB->WD_DOC,"F1_DOC")+AVKEY(TRB->WD_SERIE,"F1_SERIE")))
               DO WHILE !SF1->(EOF()) .AND. SF1->F1_FILIAL == xFilial("SF1") .AND.;
                                            SF1->F1_DOC    == AVKEY(TRB->WD_DOC,"F1_DOC")    .AND.;
                                            SF1->F1_SERIE  == AVKEY(TRB->WD_SERIE,"F1_SERIE")
                  //IF SF1->F1_HAWB == AVKEY(SW6->W6_HAWB,"F1_HAWB") wfs 05/08 a nota pode conter despesas de vários processos
                     Help("", 1, "AVG0005377")//Despesa nao pode ser excluída, pois está incluída em NF gerada.
                     RETURN .F.
                  //ENDIF
                  SF1->(DBSKIP())
               ENDDO
            ENDIF
         EndIf
      EndIf

      IF !EMPTY(TRB->WD_NF_COMP)

         If lFinanceiro .And. !EMPTY(TRB->WD_DOCTO)  // GFP - 26/08/2013 - Tratamento de exclusão de titulo de despesas //NCF - 26/07/2019
            DEFINE MSDIALOG oExcDesp TITLE STR0048 From 14,03 To 20,31 OF oMainWnd  //"Exclusão de Despesa"
               @05.2,17.3 SAY    STR0049 SIZE 200,200 PIXEL //"O que você deseja excluir?"
               @20.0,15.3 BUTTON STR0050 SIZE 25,15 PIXEL OF oExcDesp ACTION (nOpExc:=1,oExcDesp:End())//"Despesa"
               @20.0,60.3 BUTTON STR0051  SIZE 25,15 PIXEL OF oExcDesp ACTION (nOpExc:=2,oExcDesp:End())//"Título"
            ACTIVATE MSDIALOG oExcDesp CENTERED

            If nOpExc == 0  // Sair
               Return .F.
            EndIf
         Else
            nOpExc := 1  // Quando não integrado com Financeiro, sistema deve efetuar somente a validação de NF.
         EndIf

         If nOpExc == 2  // Exclusão de Título
            If !MsgYesNo(STR0052, STR0053)//"Confirmar exclusão do título desta despesa?" ### "Aviso"
               Return .F.
            Else
               If DI501ExcTit()
                  TRB->WD_GERFIN := "2" // Altera a despesa para "Gera Financeiro" igual a "Não".
                  If SWD->(DbSeek(xFilial("SWD")+TRB->(WD_HAWB+WD_DESPESA+DtoS(WD_DES_ADI)))) .AND. SWD->(RecLock("SWD",.F.))
                     AvReplace("TRB","SWD")
                  EndIf
               EndIf
            EndIf
         Else // Exclusão de Despesa
            If !MsgYesNo(STR0054, STR0053)//"Confirmar a exclusão desta despesa?" ### "Aviso"
               Return .F.
            Else
               SF1->(DBSETORDER(1))
               // DFS - 02/02/11 - Inclusão da opção "1" para que seja apresentada mensagem ao tentar alt/exc despesa da NF primeira do desembaraço.
               cTipoNF:=IF(cPaisLoc="BRA","1,2,3,5","5") //NCF - 26/07/2019 - Incluso o tipo 5-Nota Mãe no bloqueio.
               IF SF1->(DBSEEK(xFILIAL("SF1")+TRB->WD_NF_COMP+TRB->WD_SE_NFC))
                     DO WHILE !SF1->(EOF()) .AND. SF1->F1_FILIAL == xFilial("SF1")  .AND.;
                                                  SF1->F1_DOC    == TRB->WD_NF_COMP .AND.;
                                                  SF1->F1_SERIE  == TRB->WD_SE_NFC
                        IF SF1->F1_HAWB == SW6->W6_HAWB .AND.;
                           SF1->F1_TIPO_NF $ cTipoNF
                           Help("", 1, "AVG0000258")//Despesa nao pode ser excluida, pois o processo possui NF(s) de Entrada.
                           Return .F.
                        ENDIF
                     SF1->(DBSKIP())
                     ENDDO
               ENDIF
            EndIf
         EndIf
      ELSE
         DI500D_Del(.F.)
      ENDIF
   Elseif nOpcao == 5  // Relatorio

      DI500RelDesp(.F.)

   Elseif nOpcao == 6  // Gerar Arquivo

      DI500RelDesp(.T.)
   Elseif nOpcao == 7
      DI501D_Vis()

   ENDIF
Return lRet

/*
Funcao      : DI501RelDesp()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
FUNCTION DI501RelDesp(lGera)
Local nFormato:= 1  //1=Retrato 2=Paisagem
Local cTam:= "M"
nOpca:= 0
DEFINE MSDIALOG oDlg TITLE STR0055 From 14,03 To 20,46 OF oMainWnd  //"Parametro para Relatório"

  @05.2,15.3 SAY   STR0056 SIZE    40,8 PIXEL //"Data Inicial : "
  @05.2,55.3 MSGET dDat01  Picture "@D" SIZE 40,8 PIXEL
  @25.2,15.3 SAY   STR0057 SIZE    40,8 PIXEL //"Data Final  : "
  @25.2,55.3 MSGET dDat02  Picture "@D" SIZE 40,8 PIXEL
  DEFINE SBUTTON FROM 05,120 TYPE 1 ACTION( IF(E_PERIODO_OK(@dDat01,@dDat02),(nopca:=1,oDlg:End()),) ) ENABLE OF oDlg PIXEL
  DEFINE SBUTTON FROM 25,120 TYPE 2 ACTION(nopca:=0,oDlg:End()) ENABLE OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTERED
If nOpcA =0
   RETURN
Endif
aDbf_Str1 := {{"WKIMP"    ,"C",LEN(SW6->W6_IMPORT) ,0} ,;
              {"WKHAWB"   ,"C",LEN(SWD->WD_HAWB)   ,0} ,;
              {"WKDESPCD" ,"C",LEN(SWD->WD_DESPESA),0} ,;
              {"WKDESPDE" ,"C",LEN(SYB->YB_DESCR)  ,0} ,;
              {"WKVALOR"  ,"N",AVSX3("WD_VALOR_R",3),AVSX3("WD_VALOR_R",4)},;
              {"WKDATA"   ,"D",AvSx3("WD_DES_ADI"  , AV_TAMANHO),0},;
              {"WKDOCTO"  ,"C",10,0} }//ASR 26/01/2006 - INCLUCAO DA COLUNA DOCUMENTO

If AvFlags("EIC_EAI")
   nFormato:= 2
   cTam:= "G"
   AAdd(aDbf_Str1, {"WK_VLLIQ"  , AvSx3("WD_VLLIQ"  , AV_TIPO), AvSx3("WD_VLLIQ"  , AV_TAMANHO), AvSx3("WD_VLLIQ"  , AV_DECIMAL)})
   AAdd(aDbf_Str1, {"WK_VL_COMP", AvSx3("WD_VL_COMP", AV_TIPO), AvSx3("WD_VL_COMP", AV_TAMANHO), AvSx3("WD_VL_COMP", AV_DECIMAL)})
   AAdd(aDbf_Str1, {"WK_DT_VENC", AvSx3("WD_DT_VENC", AV_TIPO), AvSx3("WD_DT_VENC", AV_TAMANHO), AvSx3("WD_DT_VENC", AV_DECIMAL)})   
   AAdd(aDbf_Str1, {"WKSTATUS", "C", 30, 0})
EndIf

If AvFlags("EIC_EAI") .Or. lFinanceiro //RNLP 27/11/20 - OSSME-5370 - Financeiro habilitado
   AAdd(aDbf_Str1, {"WK_CTRFIN1", AvSx3("WD_CTRFIN1", AV_TIPO), AvSx3("WD_CTRFIN1", AV_TAMANHO), AvSx3("WD_CTRFIN1", AV_DECIMAL)})
EndIf

If(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"WOR_ESTR1"),)
InitYear4() //MCF - 28/04/2015  - Chamada da função para determinar a data.

FileWork := E_CriaTrab(,aDBF_Str1,"Work_Rel") //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados

IF !USED()
   Help(" ",1,"E_NAOHAREA")
   RETURN .F.
ENDIF
IndRegua("Work_Rel",FileWork+TEOrdBagExt(),"WKDESPCD")

If(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"WOR_INDICE"),)   // LDR - 29/11 - TREVO

TRB->(DBGOTOP())

DO WHILE !TRB->(EOF())
   If TRB->WD_DES_ADI > dDAT02 .OR.;
      TRB->WD_DES_ADI < dDat01 .OR.;
      TRB->WD_DESPESA $ '101,102,103'
      TRB->(DBSKIP())
      LOOP
   Endif
   Work_Rel->(DBAPPEND())
   Work_Rel->WKIMP   := SW6->W6_IMPORT
   Work_Rel->WKHAWB  := TRB->WD_HAWB
   Work_Rel->WKDESPCD:= TRB->WD_DESPESA
   Work_Rel->WKDESPDE:= IIF(SYB->(DBSEEK(xFilial("SYB")+TRB->WD_DESPESA)),SYB->YB_DESCR,)
   Work_Rel->WKVALOR := TRB->WD_VALOR_R
   Work_Rel->WKDATA  := TRB->WD_DES_ADI
   Work_Rel->WKDOCTO := TRB->WD_DOCTO//ASR 26/01/2006 - INCLUCAO DA COLUNA DOCUMENTO

   If AvFlags("EIC_EAI")
      Work_Rel->WK_VLLIQ  := TRB->WD_VLLIQ
      Work_Rel->WK_VL_COMP:= TRB->WD_VL_COMP
      Work_Rel->WK_DT_VENC:= TRB->WD_DT_VENC      
      Work_Rel->WKSTATUS := DI501DescLeg(TRB->WKSTATUS)
   EndIf

   If AvFlags("EIC_EAI") .Or. lFinanceiro //RNLP 27/11/20 - OSSME-5370 - Financeiro habilitado
      Work_Rel->WK_CTRFIN1:= TRB->WD_CTRFIN1
   EndIf

   If(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"WOR_GRAV1"),)

   TRB->(DBSKIP())
ENDDO

IF Work_Rel->(EasyRecCount("Work_Rel")) = 0
   Work_Rel->(E_ERASEArq(FileWork))
   DBSELECTAREA("SWD")
   TRB->(DBGOTOP())
   Help("",1,"AVG0000718")//"Nao existem registros para serem listados."
   RETURN .T.
ENDIF

IF lGera
   TR350ARQUIVO("Work_Rel")
   Work_Rel->(E_ERASEArq(FileWork))
   DBSELECTAREA('SWD')
   TRB->(DBGOTOP())
   RETURN .T.
Endif

Work_Rel->(DbGoTop())
PRIVATE aDados:={"Work_Rel",;
                STR0034,;  //"Relatorio "
                STR0058,;  //"Cambios"
                "",;
                cTam,;
                80,;
                STR0059+Work_Rel->WKIMP + " " + STR0060+WKHAWB,; //"Importador : "###"    Processso  : "
                "",;
                STR0061,; //"Relatorio de Despesas"
                { "Zebrado", 1,STR0062, nFormato, 2, 1, "",1 },; //"Importação"
                "EICDI500" ,;
                { {||.T.} , {||.T.} }  }

TB_Campos:={}
AADD(TB_Campos,{"WKDESPCD" ,,AVSX3("WD_DESPESA",5)}) //"Despesa"
AADD(TB_Campos,{"WKDESPDE" ,,AVSX3("YB_DESCR"  ,5)}) //"Descricao"
AADD(TB_Campos,{"WKDATA"   ,,AVSX3("WD_DES_ADI",5),AvSx3("WD_DES_ADI", AV_PICTURE)}) //"Data"
AADD(TB_Campos,{"WKVALOR"  ,,AVSX3("WD_VALOR_R",5),AVSX3("WD_VALOR_R",6)})//Valor R$

If AvFlags("EIC_EAI")
   AAdd(TB_Campos, {"WK_VLLIQ"  ,, AvSx3("WD_VLLIQ"  , AV_TITULO), AvSx3("WD_VLLIQ"  , AV_PICTURE)})
   AAdd(TB_Campos, {"WK_VL_COMP",, AvSx3("WD_VL_COMP", AV_TITULO), AvSx3("WD_VL_COMP", AV_PICTURE)})
   AAdd(TB_Campos, {"WK_DT_VENC",, AvSx3("WD_DT_VENC", AV_TITULO), AvSx3("WD_DT_VENC", AV_PICTURE)})
EndIf

AADD(TB_Campos,{"WKDOCTO"  ,,STR0063}) //"Docto"//ASR 26/01/2006 - INCLUCAO DA COLUNA DOCUMENTO //"Documento"

If AvFlags("EIC_EAI")
   AAdd(TB_Campos, {"WK_STATUS" ,, STR0235}) //Status
EndIf

If AvFlags("EIC_EAI") .Or. lFinanceiro
   AAdd(TB_Campos, {"WK_CTRFIN1",, AvSx3("WD_CTRFIN1", AV_TITULO), AvSx3("WD_CTRFIN1", AV_PICTURE)})
EndIf

IF(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"INCACAMPOS"),)

TB_Campos:= E_CriarCampos(TB_Campos)

Work_Rel->(DbGoTop())
E_Report(aDados,TB_Campos)

Work_Rel->(E_ERASEArq(FileWork))

IF(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"DELETA_IND"),)

DBSELECTAREA('SWD')
TRB->(DBGOTOP())

Return .T.

/*
Funcao      : DI501CondRel()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
FUNCTION DI501CondRel() // BHF-22/05/09
IF(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"COND_REL"),)
Return .T.

/*
Funcao      : DI501D_Grava()
Parâmetros  : cAlias  ->  <"SWD" | "TRB>
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
*--------------------------------------------------------------
FUNCTION DI501D_Grava(cAlias)
*--------------------------------------------------------------
Local i, xValue
Private cTitDin := "" //LRS - 10/10/2018

For i:=1 To SWD->(FCount())
   If "FILIAL" $ (cAlias)->(Field(i))
      Loop
   Endif

   If AllTrim((cAlias)->(Field(i))) == "WD_HAWB"
      (cAlias)->(FieldPut(i,SW6->W6_HAWB))
      Loop
   Endif

   IF cAlias == "SWD"
      IF TRB->(FieldPos(SWD->(Field(i)))) # 0
         xValue := TRB->(FieldGet( FieldPos(SWD->(Field(i)))))
         SWD->(FieldPut(i,xValue))
      ENDIF
   ELSE// Alias TRB
      IF (nPosNew:= TRB->(FieldPos(SWD->(Field(i))))) # 0
         xValue := SWD->(FieldGet(i))
         TRB->(FieldPut(nPosNew,xValue))
      ENDIF
   ENDIF

Next i

AvIniPadVt("SWD","TRB")

If cAlias == "SWD"
   SWD->WD_FILIAL := xFilial("SWD")
   TRB->RECNO := SWD->(RECNO())  // S.A.M 11/07/2001
Else
   // Alias TRB
   TRB->RECNO := SWD->(RECNO())
Endif

IF TRB->WD_DA == "1" .AND. SW6->W6_TIPOFEC == "DA "
    IF cAlias == "TRB" .AND. lFinanceiro .AND. ValPresCont("DA")//LRS - 10/10/2018 
       TRB->WKTITNACI := "SIM"
    Else
       TRB->WKTITNACI := "NAO"
    EndIF
EndIF

IF lFinanceiro .AND. TRB->WD_DA == "1" .AND. SW6->W6_TIPOFEC == "DIN"
    IF cAlias == "TRB" .AND. ValPresCont("DIN") //LRS - 10/10/2018
       TRB->WKDOCENTR := IF(VALTYPE(cTitDin) == "C",cTitDin,"" )
    Else
       TRB->WKDOCENTR := ""
    EndIF
EndIF

If lAvIntFinEIC .AND. Empty(TRB->WD_FGTITUL)
   TRB->WD_FGTITUL := "2"
EndIf
If lAvIntFinEIC .AND. Empty(TRB->WD_FGDEBCC)
   TRB->WD_FGDEBCC := "2"
EndIf

If AvFlags("EIC_EAI") .And. cAlias == "TRB"
   TRB->WKSTATUS:= DI501AtuStatusDesp()
EndIf
Return Nil

/*
Funcao      : DI501D_Tela()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
FUNCTION DI501D_Tela(lInit)

Local MRecno := TRB->(RECNO())//, nL1, nL2, nL3, nC1, nC2, nC3, nC4 // para o Rdmake
MSeguro:=MImpostos:=MAdiant:=MOutras:=MSaldos:=MTot_Ger:=MVariacao:=0

nL1:=1.4 ; nL2:=2.2 ; nL3:=3.0 ; nC1:=0.8 ; nC2:=15 ; nC3:=05 ; nC4:=20

IF(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"INICIA_VAR_SOMA_TRB_DESP"),)

TRB->(dbGoTop())

DO WHILE ! TRB->(EOF())

   lLoop:=.F.
   IF(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"WHILE_SOMA_TRB_DESP"),)
   IF lLoop
      TRB->(DBSKIP())
      LOOP
   ENDIF

   DO CASE
      CASE SUBST(TRB->WD_DESPESA,1,1) == '1'
           IF TRB->WD_DESPESA $ '102,103'
              MSeguro += TRB->WD_VALOR_R
           ENDIF
           MTot_Ger  += TRB->WD_VALOR_R
      CASE SUBST(TRB->WD_DESPESA,1,1) == '2'
           MImpostos += TRB->WD_VALOR_R
           MTot_Ger  += TRB->WD_VALOR_R
      CASE TRB->WD_DESPESA == "903"
           MAdiant   -= TRB->WD_VALOR_R
           MSaldos   -= TRB->WD_VALOR_R
      CASE SUBST(TRB->WD_DESPESA,1,1) == '9'
           MAdiant   += TRB->WD_VALOR_R
           MSaldos   += TRB->WD_VALOR_R
      Case TRB->WD_DESPESA $ "701/702/703" //wfs 04/12/14 - desagregar a variação cambial de outras despesas
           //AAF 27/06/2015 - Não é necessário checar o parametro para mostrar de calculo automatico para mostrar a variacao.
           //If "S" $ EasyGParam("MV_CAMBAUT", .F., "NNN")
              MVariacao += TRB->WD_VALOR_R
           //EndIf
      OTHERWISE
           MOutras   += TRB->WD_VALOR_R
           MTot_Ger  += TRB->WD_VALOR_R
   ENDCASE

   IF TRB->WD_BASEADI $ cSim .AND. ! (SUBST(TRB->WD_DESPESA,1,1)== '9')
      MSaldos -= /*TRB->WD_VALOR_R*/ If(AVFLAGS("EIC_EAI") .And. TRB->(FieldPos("WD_VLLIQ")) > 0 .And. TRB->WD_VLLIQ # 0, TRB->WD_VLLIQ , TRB->WD_VALOR_R ) //NCF - 02/12/2016 - Valor retido no saldo da despesa no ERP Externo
   ENDIF

   IF(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"SOMANDO_TOTAIS"),)

   TRB->(DBSKIP())
ENDDO

TRB->(DBGOTO(MRecno))
//ASK 08/08/07
nL0:= 0.6; nL1:=1.4 ; nL2:=2.2 ; nL3:=3.0; nC1:=0.8 ; nC2:=16 ; nC3:=06 ; nC4:=22

if !isMemVar("lDespAuto") .Or. !lDespAuto
   If lInit # NIL

      //RMD - 25/09/14 - Incluído campo para visualizar o código do embarque
      @nL0,nC1 SAY STR0006 OF oPanel //"Embarque"
      @nL0,nC3 MSGET oEmbarque   VAR SW6->W6_HAWB WHEN .F. SIZE 65,8 RIGHT OF oPanel

      //WFS - 04/12/14 - Destaque da informação de variação vambial - despesas 701, 702 e 703
      //If "S" $ EasyGParam("MV_CAMBAUT", .F., "NNN") //AAF 27/06/2015 - Não é necessário checar o parametro para mostrar de calculo automatico para mostrar a variacao.
         @nL0, nC2 Say STR0064 of oPanel //"Var. Cambial"
         @nL0, nC4 MSGet oVariacao VAR MVariacao PICTURE cPictValor HASBUTTON WHEN .F. SIZE 65,8 RIGHT OF oPanel
      //EndIf

      @nL1/*-0.8*/,nC1 SAY STR0065 OF oPanel //"Seguro/Frete"
      @nL1/*-0.8*/,nC2 SAY STR0066 OF oPanel //"Outras Despesas"
      @nL2/*-0.8*/,nC1 SAY STR0067 OF oPanel //"Impostos"
      @nL2/*-0.8*/,nC2 SAY STR0068 OF oPanel //"Adiantamentos"
      @nL3/*-0.8*/,nC1 SAY STR0069 OF oPanel //"Total Geral"
      @nL3/*-0.8*/,nC2 SAY STR0070 OF oPanel //"Saldo Adianta/o"

      @nL1,nC3 MSGET oSeguro   VAR MSeguro   PICTURE cPictValor HASBUTTON WHEN .F. SIZE 65,8 RIGHT OF oPanel
      @nL1,nC4 MSGET oOutras   VAR MOutras   PICTURE cPictValor HASBUTTON WHEN .F. SIZE 65,8 RIGHT OF oPanel
      @nL2,nC3 MSGET oImpostos VAR MImpostos PICTURE cPictValor HASBUTTON WHEN .F. SIZE 65,8 RIGHT OF oPanel
      @nL2,nC4 MSGET oAdiant   VAR MAdiant   PICTURE cPictValor HASBUTTON WHEN .F. SIZE 65,8 RIGHT OF oPanel
      @nL3,nC3 MSGET oTot_Ger  VAR MTot_Ger  PICTURE cPictValor HASBUTTON WHEN .F. SIZE 65,8 RIGHT OF oPanel
      @nL3,nC4 MSGET oSaldos   VAR MSaldos   PICTURE cPictValor HASBUTTON WHEN .F. SIZE 65,8 RIGHT OF oPanel

      IF(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"TELA_TOTAIS_DESP"),)

   Else
      oSeguro:Refresh()
      oOutras:Refresh()
      oImpostos:Refresh()
      oAdiant:Refresh()
      oTot_Ger:Refresh()
      oSaldos:Refresh()
   Endif
endif

Return Nil

/*
Funcao      : DI501D_Edi()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     : mar/2015 - Alteração do objeto MsGetDB para FwBrowse
*/
FUNCTION DI501D_Edi(lInclui,aAutoCab,lPrestacao)

LOCAL nOpcA:=0, nRec := 0, i6, i, nPosCpo
LOCAL cQual, nTipo, bCampo, oDlg
LOCAL nVlrAlterar := 0 //LGS-28/10/2013
LOCAL nInd
Local lDialog := .T. // JBS 23/04/2004
Local lRet := .T.
Local cMsgValid:= ""
Local aEaiNaoALtera := {/*"WD_BASEADI","WD_PAGOPOR",*/"WD_CTRFIN1","WD_VLLIQ","WD_VL_COMP"}  //(IGOR CHIBA CAMPOS QUE NAO SERAO EDITAVEIS IGOR CHIBA 04/07/14
Local aEnchNaoExibe := {}
LOCAL nI //igor chiba utilizada no for de campos TRATAMENTO PARA EAI 04/07/14
Local oPanel, nInc
Local aAltCpoNF := {} //THTS - 19/06/2017 - TE-5912
Private oEnchEdi
Private lIncAux := lInclui
Private lDespesa := .F. //LGS-28/10/2013
Private aNaoAltDsp	:=	{}
Private aEncAltera := {} // TDF - 26/05/10 - Para usar em rdmake
Private lRdmake := .T. //RRV - 17/12/2012 - Variável a ser utilizada por Rdmake.
Default lPrestacao := .F.


IF AvFlags("EIC_EAI") .And. lPrestacao //TRATAMENTO PARA QUANDO A ROTINA FOR CHAMADA ATRAVÉS DA PRESTACAO DE CONTAS EICCA150 igor chiba 17/07/14
   aHeader := ACLONE(aHeadAdnt)
   AVZAP("ADIANT") //ADIANT->(avzap())
   nSaldAdnt:= 0
   Processa({|| CA150PQPRES('SWD')}, STR0071) //'Pesquisando adiantamentos...'
   SWD->(dbGoTo(TRB->RECNO))//reposicionando no registro que estava posicionado antes do pesquisa
   IF ADIANT->(EasyRecCount("ADIANT")) == 0
      MSGALERT(STR0072, STR0001) //"Não existe despesa de adiantamento com saldo para ser utilizada na compensação desta despesa."
      RETURN .F.
   ENDIF

ENDIF

If !lInclui
   If(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"DESP_ALTERA2"),)
Endif

lSair := !EICFI400("ANT_GET_DESP",IF(lInclui,"S","N"))
IF lSair
   RETURN .F.
ENDIF

// variaveis p/ EnChoice
PRIVATE aTELA[0][0],aGETS[0]
PRIVATE nCampos := 0

dbSelectArea("SWD")
bCampo := { |nCPO| Field(nCPO) }
FOR i6 := 1 TO FCount()
    M->&(FIELDNAME(i6)) := CRIAVAR(FIELDNAME(i6))
NEXT i6

dbSelectArea("TRB")

//IGOR CHIBA 04/07/14 quando for integrado incluir os campos a mais na tela
IF AvFlags("EIC_EAI")
   /* Quando for apenas alteração da despesa, não exibir os campos relacionados à conta bancária */
   If !lPrestacao
      If lDevDesp//THTS - 11/08/2017 - Se for Devolucao do Despachante, exibe os campos de banco, agencia e conta na tela.
          aEnchNaoExibe:= {"WD_MOEDA","WD_VL_MOE","WD_TX_MOE","WD_PRDSIS"}//Nao exibe campos do Siscoserv
      Else
          aEnchNaoExibe:= {"WD_BANCO", "WD_AGENCIA", "WD_CONTA"}
      EndIf
      For nI:= 1 To Len(aEnchNaoExibe)
         i:= AScan(aEnchoice, aEnchNaoExibe[nI])
         If i > 0
            ADel(aEnchoice, i)
            ASize(aEnchoice, Len(aEnchoice) - 1)
         EndIf
      Next
   EndIf
ENDIF
IF lInclui
   Inclui := .T.
   cQual:=STR0073 //"Inclusão de Despesas"
   nTipo:=3
   aEncAltera := aClone(aEnchoice)
Else
   Inclui := .F.
   IF EasyRecCount("TRB") == 0
      Help(" ",1,"EICSEMIT")
      RETURN .F.
   ENDIF

   IF TRB->WD_DESPESA = "101" .Or. ;
      TRB->WD_DESPESA = "104"
      Help(" ",1,"E_FOBCIFNA")
      Return .F.
   ENDIF

   If !EMPTY(TRB->WD_NF_COMP)//Possui Nota Fiscal.
   	  If lFinanceiro
      	aEncAltera := {"WD_BASEADI","WD_FORN","WD_PAGOPOR","WD_GERFIN"}//LGS-28/10/13
      Else
      	aEncAltera := {"WD_BASEADI","WD_FORN","WD_PAGOPOR"}//LGS-08/10/13
      EndIf
   Else
      aEncAltera := aClone(aEnchoice)
   EndIf

   IF lAvIntFinEIC //LRS - 05/05/2015
	  aAdd(aEncAltera,"WD_FGDEBCC")
	  aAdd(aEncAltera,"WD_FGTITUL")
   EndIF

   IF TRB->WD_DESPESA = "102" .Or. TRB->WD_DESPESA = "103"
      IF !EasyGParam("MV_CAMBIL")
         IF ( TRB->WD_DESPESA = "102" .AND. (SW6->W6_VLFRECC+SW6->W6_VLFREPP) > 0 .AND. SW6->W6_TX_FRET # 0 )  ;
            .Or.  ( TRB->WD_DESPESA = "103" .AND. SW6->W6_VL_USSE # 0 .AND. SW6->W6_TX_SEG # 0 .AND. SW6->W6_TX_US_D # 0 )
            If lFinanceiro
               aEncAltera := {"WD_BASEADI"}
            Else
               aEncAltera := {"WD_DES_ADI",;
                              "WD_BASEADI",;
                              "WD_FORN   ",;
                              "WD_LOJA   ",;
                              "WD_DOCTO  ",;
                              "WD_PAGOPOR"}
            EndIf

         ENDIF
      ENDIF
      //RMD - 15/09/14 - Permite editar o campo de Produto base para a integração com o SISCOSERV
      If AvFlags("CONTROLE_SERVICOS_AQUISICAO") .And. EasyGParam("MV_ESS0022",,.T.) .And. SWD->(FieldPos("WD_PRDSIS")) > 0
         aAdd(aEncAltera, "WD_PRDSIS")
      EndIf
   ENDIF

   FOR i := 1 TO FCount()
      M->&(EVAL(bCampo,i)) := FieldGet(i)
      nCampos++
   NEXT i

   If AvFlags("EIC_EAI") .And. !lPrestacao .And. lInclui
      M->WD_GERFIN:= "2"
   EndIf

   SYB->(dbSeek(xFilial()+M->WD_DESPESA))
   M->WD_DESCDES := SYB->YB_DESCR

   cQual:=STR0074
   nTipo:=4 //"Alteração de Despesas"
Endif

//TRP- 06/08/07 - Tratamento para que campos de usuário sejam alteráveis.
SX3->(DbSetOrder(1))
If SX3->(DbSeek("SWD"))
      While SX3->(!Eof() .And. SX3->X3_ARQUIVO == "SWD")
         If SX3->X3_PROPRI == "U"
            aAdd(aEncAltera, SX3->X3_CAMPO)
         EndIf
         SX3->(DbSkip())
      EndDo
EndIf
lDialog    := .F.          // JBS 23/04/2004
M->WD_HAWB := SW6->W6_HAWB
M->WD_DA   := ValFaseDesp()//FDR - 18/04/13 //IF(SW6->W6_TIPOFEC="DA","1","2")

If lAvIntFinEIC
	aNaoAltDsp	:=	{}
	//---	TRATAMENTOS para não permitir a alteração de campos na situação de despesas enviadas ao ERP...
   If	lEICFI10	.AND.	M->WD_DESPESA $ '901/902/903' .AND. ( !Empty(M->WD_CODINT) .OR. !Empty(M->WD_CTRLERP) .OR. !Empty(M->WD_TITERP) .Or. M->WD_GERCMP == "1" ) //DRL 08/06/10, entra se foi gerado pela compensacao
   	//---	Se a interface AvInteg de NUMERÀRIO estiver ativa e a despesa for referente à tratamentos de ADIANTAMENTOS AO DESPACHANTE...
   	aNaoAltDsp	:=	{"WD_DES_ADI","WD_VALOR_R","WD_PAGOPOR","WD_BASEADI","WD_FORN","WD_LOJA"/*,"WD_FGDEBCC","WD_FGTITUL"*/} //LRS - 05/05/2015
   ElseIf	lEICFI11	.AND.	M->WD_DESPESA > '104' .AND. M->WD_DESPESA < '901' .AND. !Empty(M->WD_CTRLERP)
   	//---	Se a interface AvInteg de DESPESAS REALIZADAS estiver ativa e a despesa não estiver aguardando retorno da integração de DESPESAS...
   	aNaoAltDsp	:=	{"WD_DES_ADI","WD_VALOR_R","WD_PAGOPOR","WD_BASEADI","WD_FORN","WD_LOJA"/*,"WD_FGDEBCC","WD_FGTITUL"*/} //LRS - 05/05/2015
   EndIf
   If	!Empty(M->WD_CTRLERP)
      aAdd(aNaoAltDsp,"WD_BANCO")
      aAdd(aNaoAltDsp,"WD_AGENCIA")
      aAdd(aNaoAltDsp,"WD_CONTA")
      aAdd(aNaoAltDsp,"WD_BAN_REC")
      aAdd(aNaoAltDsp,"WD_AGE_REC")
      aAdd(aNaoAltDsp,"WD_CON_REC")
   EndIf
   //
 	For nInd:=1 to Len(aNaoAltDsp)
       If (nPosCpo:=aScan(aEncAltera,{|x| x==aNaoAltDsp[nInd]}))>0
          aDel(aEncAltera,nPosCpo)
          aSize(aEncAltera,len(aEncAltera)-1)
       EndIf
   Next nInd
EndIf
lSair:=.F.
If(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"ANTES_TELA_DESP_MANUT"),)
IF lSair
   RETURN .F.
ENDIF

If lTitFinF050    // JBS - 23/04/2004

   nValorS   := 0
   cCodFor   := SPACE(LEN(SE2->E2_FORNECE))
   cLojaFor  := SPACE(LEN(SE2->E2_LOJA))
   nMoedSubs := 1 //JWJ 22/12/2006 - Chamado 043791

   If lInclui .AND. !DI500D_OriFin(aAutoCab)
      lDialog := .F.
      RETURN .F.

   ElseIf lInclui .and. M->WD_GERFIN == "1" //.and. M->WD_BASEADI == "2"
      If FI400TITFIN("SWD","2")        // Inclusao SE2 e SWD
         DI500GrvDESP("2")
      ELSE
         RETURN .F.
      EndIf

   ElseIf !lInclui .and. TRB->WD_GERFIN == "1" .And. !Empty(TRB->WD_DOCTO)//FDR - 08/10/12
      If FI400TITFIN("SWD","3")  // Alteração do titulo no SE2 (Financeiro)
         DI500GrvDESP("3")       // Registra alterações no SWD
      EndIf
   Else
      lDialog := .T.
      If lInclui //LGS-28/10/13
      	If lFinanceiro
          aEncAltera := aClone(aEnchoice)
      	  ADEL (aEncAltera,13)
      	  //GFP - 26/05/2014 - Tratamento para que campos de usuário sejam alteráveis.
          SX3->(DbSetOrder(1))
          If SX3->(DbSeek("SWD"))
             While SX3->(!Eof() .And. SX3->X3_ARQUIVO == "SWD")
                If SX3->X3_PROPRI == "U"
                   aAdd(aEncAltera, SX3->X3_CAMPO)
                EndIf
                SX3->(DbSkip())
             EndDo
          EndIf
      	EndIf
      EndIf
   EndIf
Else
   lDialog := .T.
EndIf

// IGOR CHIBA 04/07/14  quando for alteracao e ja estiver integrado retirar alguns campos
IF AvFlags("EIC_EAI")
   IF!lInclui .AND. !EMPTY(M->WD_CTRFIN1) //NA ALTERACAO SE O CAMPO NUM.TITO ESTIVER PREENCHIDO JA FOI INTEGRADO NAO DEIXAR ESTES CAMPOS ALTERAVEIS
      AADD(aEaiNaoALtera,"WD_DES_ADI")
      AADD(aEaiNaoALtera,"WD_VALOR_R")
      AADD(aEaiNaoALtera,"WD_BASEADI")
      AADD(aEaiNaoALtera,"WD_GERFIN")
      AADD(aEaiNaoALtera,"WD_FORN")
      AADD(aEaiNaoALtera,"WD_LOJA")
      AAdd(aEaiNaoALtera, "WD_VL_COMP")
      If !lPrestacao
         AAdd(aEaiNaoALtera,"WD_DT_VENC")
         AAdd(aEaiNaoALtera,"WD_BANCO")
         AAdd(aEaiNaoALtera,"WD_AGENCIA")
         AAdd(aEaiNaoALtera,"WD_CONTA")
      EndIf
      //THTS - 16/08/2017 - Nao permite alterar estes campos na alteracao do adiantamento
      If M->WD_DESPESA == "901"
         aAdd(aEaiNaoALtera, "WD_PAGOPOR")
         aAdd(aEaiNaoALtera, "WD_MOEDA")
         aAdd(aEaiNaoALtera, "WD_VL_MOE")
         aAdd(aEaiNaoALtera, "WD_TX_MOE")
         aAdd(aEaiNaoALtera, "WD_PRDSIS")
      EndIf

   ELSEIF lInclui
      M->WD_PAGOPOR := '2'//PAGO POR IMPORTADOR
   Else
      AAdd(aEaiNaoALtera, "WD_VL_COMP")
   ENDIF

   For nI:=1 to Len(aEaiNaoALtera)
      IF (nPos:=ASCAN(aEncAltera,aEaiNaoALtera[nI])) <> 0
         aDel(aEncAltera,nPos)
         aSIZE(aEncAltera,LEN(aEncAltera)-1)
      ENDIF
   Next

ENDIF

IF lPrestacao//TRATAMENTO PARA QUANDO A ROTINA FOR CHAMADA ATRAVÉS DA PRESTACAO DE CONTAS EICCA150 igor chiba 17/07/14
   SYT->(DBSETORDER(1))
   IF SYT->(dBSeek(xFilial("SYT")+SW6->W6_IMPORT))
      M->WD_BANCO   := SYT->YT_BANCO
      M->WD_AGENCIA := SYT->YT_AGENCIA
      M->WD_CONTA   := SYT->YT_CONTA
   ENDIF
   M->WD_GERFIN  := '1' //forçar 1 PARA GERAR ADAPTER

ENDIF


If !lInclui //LGS-28/10/2013
   nVlrAlterar := M->WD_VALOR_R
EndIf

//THTS - 19/06/2017 - TE-5912 - Nao deixar alterar os campos refente a NF
IF EasyGParam("MV_EASY",,"N") == "S" .And. lCposNFDesp
    aAltCpoNF := {"WD_DOC","WD_SERIE","WD_EMISSAO","WD_TIPONFD","WD_B1_COD","WD_ESPECIE" }
    For nI := 1 To Len(aAltCpoNF)
        If (nPos := aScan(aEncAltera,{|x| x == aAltCpoNF[nI]})) <> 0
            aDel(aEncAltera,nPos)
            aSize(aEncAltera,Len(aEncAltera)-1)
        EndIf
    Next
EndIf

//THTS - 11/08/2017 - Devolucao do Despachante - Carregar os valores do adiantamento devolvido
If lDevDesp
    FOR i6 := 1 TO FCount()
        M->&(FIELDNAME(i6)) := TRB->&(FIELDNAME(i6))
    NEXT i6
    M->WD_DESPESA := "903" //Devolucao do Despachante fixa a despesa 903
    M->WD_DESCDES := E_Field("WD_DESPESA","YB_DESCR","G",,1)
    M->WD_VALOR_R := TRB->WD_VALOR_R - TRB->WD_VL_COMP - DI501DVDES(TRB->WD_HAWB,TRB->WD_CTRFIN1)
    M->WD_VL_COMP := 0
    M->WD_VLLIQ   := 0
    M->WD_DES_ADI := dDataBase  
    M->WD_PAGOPOR := "1"

    aEncAltera := {"WD_DOCTO","WD_BANCO","WD_AGENCIA","WD_CONTA"}

EndIf

If M->WD_DESPESA == "901" .And. !AvFlags("EIC_EAI")
   If (nPos := aScan(aEncAltera,{|x| x == "WD_GERFIN"})) <> 0
      aDel(aEncAltera,nPos)
      aSize(aEncAltera,Len(aEncAltera)-1)
   EndIf
EndIf

DO WHILE lDialog

   If !isMemVar("lDespAuto") .or. !lDespAuto
      nOpca := 0

      IF  lPrestacao//TRATAMENTO PARA QUANDO A ROTINA FOR CHAMADA ATRAVÉS DA PRESTACAO DE CONTAS EICCA150 igor chiba 17/07/14
         cQual:=  STR0038//'Prestação de Contas'
      ENDIF

      oMainWnd:ReadClientCoords()
      DEFINE MSDIALOG oDlg TITLE cQual ;
         FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
         OF oMainWnd PIXEL

         oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, oMainWnd:nRight-10, oMainWnd:nBottom-60)
         oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

         IF  lPrestacao//TRATAMENTO PARA QUANDO A ROTINA FOR CHAMADA ATRAVÉS DA PRESTACAO DE CONTAS EICCA150 igor chiba 17/07/14

            nMeio    := MEIO_DIALOG-1
            nFimTela := ((oDlg:nClientHeight-6)/2)
            nRegWD    := TRB->RECNO
            aEncAltera:={"WD_DES_ADI","WD_VALOR_R","WD_DOCTO","WD_DT_VENC","WD_BANCO","WD_AGENCIA","WD_CONTA"}
            oEnchEdi  :=MsMget():New("SWD",nRegWD,nTipo,,,,aEnchoice,{15,1,nMeio,COLUNA_FINAL},aEncAltera,3)
            oEnchEdi:oBox:Align := CONTROL_ALIGN_TOP

            Define FwBrowse oMarkAdnt Data Table Alias "ADIANT" Of oDlg

               For nInc := 1 To Len(aHeadAdnt)
                  Add Column oColumn Data &("{ ||" + aHeadAdnt[nInc][2] + " }") Title aHeadAdnt[nInc][1] Size aHeadAdnt[nInc][4] Picture aHeadAdnt[nInc][3] Of oMarkAdnt
                  If aHeadAdnt[nInc][2] == "WD_VL_COMP"
                     oColumn:SetEdit(.T.)
                     oColumn:SetReadVar("M->WD_VL_COMP")
                  EndIf
               Next

               oMarkAdnt:SetEditCell(.T.)
               oMarkAdnt:bValidEdit:= {|| DI500PVLD('CPO')/*, oMarkAdnt:Refresh(.T.)*/}

               oMarkAdnt:DisableReport()
               oMarkAdnt:DisableSeek()
               //oMarkAdnt:Refresh(.T.)

            Activate FwBrowse oMarkAdnt


            nLin := ((oDlg:nClientHeight-6)/2) + 35
            nCol := 05

            @nLin,nCol MSPANEL oPanAdiant Prompt "" Size 100,20 of oDlg

            @05,01 SAY  'Total Associado'                OF oPanAdiant PIXEL
            @05,40 MSGET oSaldAdnt   VAR nSaldAdnt   PICTURE cPictValor WHEN .F. SIZE 50,9 PIXEL OF oPanAdiant


         ELSE
            oEnchEdi:=MsMget():New("SWD",nRec,nTipo,,,,aEnchoice,{15,1,(oDlg:nClientHeight-6)/2,COLUNA_FINAL},aEncAltera,3,,,, oPanel)
         ENDIF
         oDlg:lMaximized:=.T.

      ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},{||nOpca:=0,oDlg:End()},.F.),;
                                          IF(lPrestacao,(oPanAdiant:Align:=CONTROL_ALIGN_BOTTOM,;
                                          oMarkAdnt:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT),))  //Contas a Pagar - FDR - 17/08/11  //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   Else
      If nOpcA == 0
         lRet := EnchAuto("SWD",aAutoCab,{|| .T.},3,aEnchoice) .AND. lRet
         nOpcA := 1
      Else
         lRet := .F.
         EXIT
      EndIf
   Endif

   If nOpcA = 1

      IF lPrestacao // igor chiba se for prestacao valor da despesa nao pode ser menor que o total da compensada 18/07/14
         IF nSaldAdnt > M->WD_VALOR_R
            MSGALERT(STR0075 + M->WD_DESPESA + ' - ' + M->WD_DESCDES, STR0001) //"O Total Associado ultrapassa o valor da despesa: "
            LOOP
         ENDIF
         /* A memória ficará com o último valor preenchido pelo usuário.
            A informação será apagada antes de gravar na base de dados.*/
         M->WD_VL_COMP:= 0
      ENDIF

      //LGS-25/07/2014 - P.E. para validar valor negativo no processo sem que o sistema valide as despesas negativas.
	  If(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"VALOR_NEGATIVO"),)

	  //LGS-23/04/2014 - Confirma se esta gerando residuo de valor negativo no campo Outras Despesas para o processo.
	  If !(Left(M->WD_DESPESA,1) $ "1,2,9") .And. !(TRB->WD_DESPESA $ "701/702/703")
		  If !lValNegativo .And. ValNegativo(lInclui,MOutras,nVlrAlterar,M->WD_VALOR_R,0)
		   	 loop
		  EndIf
	  EndIf
   	  If !Obrigatorio(aGets,aTela)
         Loop
      Endif
      If lFinanceiro
         //CCH - 21/08/2009 - Não permite incluir despesa sem o Valor
         If Empty(M->WD_VALOR_R)
            MsgInfo(StrTran(STR0076, "####", AllTrim(M->WD_DESPESA)), STR0001) //"Não é permitida a inclusão da despesa #### com valor zerado (Valor R$). É necessário preencher o valor da despesa." ### "Atenção"
            Loop
         EndIf
      EndIf

      //RRC - 12/12/2013 - Atualiza a taxa para integração com o SIGAESS caso a mesma esteja vazia
      If AvFlags("CONTROLE_SERVICOS_AQUISICAO") .And. EasyGParam("MV_ESS0022",,.T.) .And. SWD->(FieldPos("WD_MOEDA")) > 0 .And. SWD->(FieldPos("WD_VL_MOE")) > 0;
         .And. SWD->(FieldPos("WD_TX_MOE")) > 0 .And. !Empty(M->WD_MOEDA) .And. !Empty(M->WD_VL_MOE) .And. Empty(M->WD_TX_MOE)
         M->WD_TX_MOE := BuscaTaxa(M->WD_MOEDA,M->WD_DES_ADI,,.F.)
      EndIf

      //Verifica se a despesa cadastrada e do tipo DA caso seja nao permite o seu cadastro
      IF nTipo == INCLUSAO .And. MOpcao == FECHTO_NACIONALIZACAO .And. M->WD_DA == "1" //FDR - 18/04/13
      	 Help("", 1, "AVG0005109")  // 'Despesa Cadastrada devera ser diferente de DA!
         Loop
      Endif
      IF !EICFI400("POS_GET_DESP")
         loop
      ENDIF
      If lAvIntFinEIC
         If M->WD_DESPESA == "901" .AND. lInclui//Se for adiantamento a despachante
            MsgStop(STR0077) //"Despesa não pode ser diretamente cadastrada. Adiantamento ao despachante deve ser incluído via solicitação de numerário."
            Loop
         EndIf

         If M->WD_PAGOPOR <> "2" .AND.;//Se não for Importador
            M->WD_FGDEBCC == "1" //Débito em conta corrente

            MsgStop(STR0078) //"Despesa não pode ter débito em conta corrente quando o pagamento não é feito pelo Importador. Altere o campo 'Pago Por' ou o campo 'Débito CC?'."
            Loop
         EndIf
      EndIf
      IF ! lInclui
         M->RECNO := TRB->RECNO
      ELSE
         M->RECNO := 0
      ENDIF

      M->DBDELETE := .F.

      IF(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"DESPESA_OK"),) //RRV - 07/12/2012 - Criado ponto de entrada para manipulação das despesas antes de gravar SWD.

      //RRV - 17/12/2012 - Trata retorno do Rdmake, se utilizado.
      If lRdmake == .F.
         Loop
      EndIf

      lOkFI411:=lPrestacao

      IF AvFlags("EIC_EAI")

         //WFS 28/08/2014
         cMsgValid:= ""
         If M->WD_GERFIN $ cSim

            IF ( EMPTY(M->WD_FORN) .OR. EMPTY(M->WD_LOJA) ) // igor chiba
               cMsgValid += STR0079 //"Os campos Fornecedor e Loja não foram preenchidos. Informe o fornecedor da despesa.
            ENDIF

            If Empty(M->WD_DT_VENC)
               cMsgValid += ENTER + STR0080 //"O vencimento da despesa deve ser informado."
            EndIf

            If Empty(M->WD_VALOR_R)
               cMsgValid += ENTER + StrTran(STR0076, "####", AllTrim(M->WD_DESPESA))//"Não é permitida a inclusão da despesa #### com valor zerado (Valor R$). É necessário preencher o valor da despesa."
            EndIf

            If M->WD_DESPESA == "903" .And. (Empty(M->WD_BANCO) .Or. Empty(M->WD_AGENCIA) .Or. Empty(M->WD_CONTA)) //THTS - 16/08/2017
               cMsgValid += ENTER + STR0262 //"O Banco, Agência e Conta devem ser informados."
            EndIf

            If !Empty(cMsgValid)
               MsgAlert(cMsgValid, STR0001) //####, "Atenção"
               Loop
            EndIf

         EndIf

         IF lPrestacao// .AND. CA150CHANGE()//TRATAMENTO PARA QUANDO A ROTINA FOR CHAMADA ATRAVÉS DA PRESTACAO DE CONTAS EICCA150 igor chiba 17/07/14

            //WFS 27/08/2014
            If nSaldAdnt == 0
               MsgAlert(STR0081, STR0001) //"O valor a ser compensado não foi informado."
               Loop
            EndIf

            IF MSGYESNO(STR0082, STR0053) //"Esta operação realizará a geração/ atualização do título efetivo no ERP e a sua compensação com o título de adiantamento ao despachante. Deseja prosseguir?"
               If CA150CHANGE() .And. !EICFI411("M", INCLUSAO)
                  lOkFI411:= .F.
                  Loop
               EndIf
            Else
               Loop
            ENDIF
         ELSEIF (M->WD_GERFIN == '1' .And. AlterouDesp()) .Or. lDevDesp //IGOR CHIBA 04/07/14 envio de despesa efetiva via adapter
            IF !(lOkFI411:=EICFI411('M', INCLUSAO))//adapter
               Loop
            ENDIF
            /* Se existir, será excluído o PRE referente à despesa incluída*/
            If AvFlags("AVINT_PRE_EIC")
               oDI500IntProv:DelDespProv(, M->WD_HAWB, "PRE", M->WD_DESPESA)
            EndIf
         ENDIF
      ENDIF

      If lFinanceiro //LGS-28/10/13 - Verifica se a integração esta habilitado para poder criar o titulo no financeiro a partir da alteração da despesa
	    //If M->WD_GERFIN == "1" .And. Empty(M->WD_CTRFIN1)  // LGS - 05/11/2013
	    If !lInclui .And. Empty(TRB->WD_CTRFIN1) .And. TRB->WD_GERFIN <> "1" .And. M->WD_GERFIN == "1"    // GFP - 07/10/2014    // LGS - 05/11/2013
		   lIncAux := lDespesa := .T.
	       If FI400TITFIN("SWD","2")// Inclusao  na SE2
	          DI500GrvDESP("3")     // Alteracao na SWD
	       EndIf
	    Else
	       DI500GrvDESP(If(lInclui,"2","3"),.F.)
	    EndIf

      Else
      	  DI500GrvDESP(If(lInclui,"2","3"),.F.) // JBS - 23/04/2004
      EndIf

      IF AvFlags("EIC_EAI") .AND. lPrestacao .AND. lOkFI411 //SE DEU CERTO O ENVIO DA DESPESA E É PRESTACAO DE CONTAS
         If EICFI412()
            /* Quando o ERP não realizar todas as compensações ou o saldo do adiantamento for
               insuficiente para baixar o título efetivo, o sistema orientará o usuário a efetuar a
               liberação do documento no ERP */
            If TRB->WD_VL_COMP <> WD_VLLIQ
               MsgInfo(STR0236, STR0001) //"Existe saldo da despesa que não foi compensada com um adiantamento. Realize a liberação da despesa ao ERP.", "Atenção"
            EndIf
         Else
            /* Quando houver problema na compensação da despesa, não ocorrendo, ao menos, uma baixa,
               o documento efetivo será excluído, devido a reapuração do valor líquido cujo fato gerador
               é a data do pagamento do título. */
            EAIEstornaTit()
         EndIf
         TRB->WKSTATUS:= DI501AtuStatusDesp()
      ENDIF

      Exit
   ELSE
      RETURN .F.
   ENDIF

ENDDO

DI500D_Tela()

If lDevDesp //THTS - 14/08/2017 - Se devolucao do despachante, nao abre uma nova tela para inclusao
    lRet := .F. //Joga falso para retornar para a tela de despesas, e nao abrir uma nova inclusao
EndIf

RETURN lRet

/*
Funcao      : DI501PVLD()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     : mar/2017 - Atualização do valor compensado na work ADIANT, devido à alteração do objeto de MsGetDB para FWBROWSE
*/
Function DI501PVLD(cTipo)//AWF - 11/08/2014

LOCAL lRet:=.T.
LOCAL cCpo:=UPPER(READVAR())

DO CASE

   CASE cTipo == "CPO"

      IF cCpo == 'M->WD_VL_COMP'
         IF M->WD_VL_COMP < 0
            MSGALERT(STR0083, STR0001) //"O valor informado deve ser igual ou maior que 0 (zero)."
            lRet:=.F.
         ELSEIF M->WD_VL_COMP > (ADIANT->WD_SALDO + ADIANT->WD_VL_COMP)
            MSGALERT(STR0084, STR0001) //"Valor informado é maior que o saldo disponível."
            lRet:=.F.
         ELSEIF   (M->WD_VL_COMP +  (nSaldAdnt-ADIANT->WD_VL_COMP)) > M->WD_VALOR_R
            MSGALERT(STR0085 + TRB->WD_DESPESA + ' - ' + M->WD_DESCDES, STR0001) //"O Total Associado ultrapassa o valor da despesa: "
            lRet:=.F.
         ENDIF

         IF lRet
            //Saldo
            ADIANT->WD_SALDO :=  ADIANT->WD_SALDO + (ADIANT->WD_VL_COMP - M->WD_VL_COMP)
            //Valor compensado
            ADIANT->WD_VL_COMP :=  ADIANT->WD_VL_COMP + (M->WD_VL_COMP - ADIANT->WD_VL_COMP)

            CA150ATUTOT(ADIANT->(RECNO()))
         ENDIF

      ENDIF

   CASE cTipo == "DEL"
      lRet:=.F.

ENDCASE

Return lRet


/*
Funcao      : DI501D_Del()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
FUNCTION DI501D_Del(lPrestacao)

LOCAL nOpcA, nReg:= TRB->(Recno()), i
LOCAL oDlg, cTit:=STR0086 //"Exclusão de Despesas"
LOCAL nOrdSF1 := SF1->(INDEXORD())
Local lRet := .T.
DEFAULT lPrestacao:= .F.   //igor chiba req5.8

SF1->(DBSETORDER(5))
lTemNfE:= .F.
//ISS - 13/12/10 - Verificação se o HAWB corrente possui alguma nota gerada, e não apenas notas de despesas (NFD)
IF SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB)) .AND. If(lCposNFDesp,ExistHAWBNFE(SW6->W6_HAWB),.T.) //wfs
  lTemNFE:= .T.
ENDIF
SF1->(DBSETORDER(nOrdSF1))

lSair:=.F.
IF(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"DES_EXCLUI2"),)
IF lSair
   Return
ENDIF

IF !EMPTY(TRB->WD_NF_COMP)

   SF1->(DBSETORDER(1))
   cTipoNF:=IF(cPaisLoc="BRA","2,3","5")
   IF SF1->(DBSEEK(xFILIAL("SF1")+TRB->WD_NF_COMP+TRB->WD_SE_NFC))
      DO WHILE !SF1->(EOF()) .AND. SF1->F1_FILIAL == xFilial("SF1")  .AND.;
                                   SF1->F1_DOC    == TRB->WD_NF_COMP .AND.;
                                   SF1->F1_SERIE  == TRB->WD_SE_NFC
         IF SF1->F1_HAWB == SW6->W6_HAWB .AND.;
            SF1->F1_TIPO_NF $ cTipoNF
            Help("", 1, "AVG0000260")//Despesa nao pode ser excluida, pois o processo possui NF(s) de Entrada.
            Return .F.
         ENDIF
         SF1->(DBSKIP())
      ENDDO
   ENDIF
Endif

Inclui := .F.

IF TRB->( EasyRecCount("TRB") ) == 0
   Help(" ",1,"EICSEMIT")
   RETURN
ENDIF

IF TRB->WD_DESPESA = "101" .Or. ;
   TRB->WD_DESPESA = "104"
   Help(" ",1,"E_FOBCIFNA")
   Return
ENDIF

lSair:=.F.
lRet:=EICFI400("MAN_EXC_DESP")
IF lSair .OR. !lRet
   Return .F.
ENDIF


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0]
PRIVATE bCampo, nCampos := 0, lDel_Desp := .T.
bCampo := {|x| Field(x) }

dbSelectArea("TRB")
FOR i := 1 TO FCount()
   M->&(EVAL(bCampo,i)) := FieldGet(i)
   nCampos++
NEXT i

   SYB->(dbSeek(xFilial()+M->WD_DESPESA))
   M->WD_DESCDES := SYB->YB_DESCR

nTipo:=ALTERACAO
aAltCpo:={}
IF !EMPTY(TRB->RECNO)
   SWD->(DBGOTO(TRB->RECNO))
   nTipo:=ESTORNO
   aAltCpo:=NIL
ENDIF

DO While .T.
   nOpcA:=1

   If lTitFinF050 .and. TRB->WD_GERFIN  == "1"  // JBS - 23/04/2004
      If FI400TITFIN("SWD","4")        // Exclusao
         DI500GrvDESP("4")
      EndIf
      EXIT
   ENDIF

   IF lPrestacao  //TRATAMENTO PARA QUANDO A ROTINA FOR CHAMADA ATRAVÉS DA PRESTACAO DE CONTAS EICCA150 igor chiba 17/07/14
      cTit := STR0087 //"Cancelamento da Prestação de Contas"
      AADD(aEnchoice,"WD_BANCO")
      AADD(aEnchoice,"WD_AGENCIA")
      AADD(aEnchoice,"WD_CONTA")
      IF !EMPTY(TRB->RECNO)
         SWD->(DBGOTO(TRB->RECNO))
         M->WD_BANCO   := SWD->WD_BANCO
         M->WD_AGENCIA := SWD->WD_AGENCIA
         M->WD_CONTA   := SWD->WD_CONTA
         nTipo         :=ESTORNO
      ENDIF
      cMsg:= (STR0088) //"Esta operação cancelará a compensação do título efetivo da despesa com os adiantamentos realizados ao despachante. Deseja prosseguir?"

   ENDIF

   If !isMemVar("lDespAuto") .or. !lDespAuto
      oMainWnd:ReadClientCoords()
      DEFINE MSDIALOG oDlg TITLE cTit ;
         FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
         OF oMainWnd PIXEL

      oEnchEdi:=MsMget():New("SWD",nReg,nTipo,,,,aEnchoice,{15,1,(oDlg:nClientHeight-6)/2,COLUNA_FINAL},aAltCpo,3)
      oDlg:lMaximized:=.T.
      oEnchEdi:oBox:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
      ACTIVATE MSDIALOG oDlg ON INIT ;//FDR - 02/01/2012 - Substituído pela função EnchoiceBar
         (EnchoiceBar(oDlg,{|| IF(If(lPrestacao,MsgYesno(cMsg,),MsgYesNo(STR0089, STR0001)),(nOpca:=2,oDlg:End()),)},; //"Confirmar a exclusão ?"##"Atenção"
                           {|| nOpca:=1,oDlg:End()},.F.))
   Else
      nOpcA := 2
   EndIf
   IF nOpcA == 2
    //LGS-25/07/2014 - P.E. para validar valor negativo no processo sem que o sistema valide as despesas negativas.
	If(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"VALOR_NEGATIVO"),)

	//LGS-23/04/2014 - Confirma se esta gerando residuo de valor negativo no campo Outras Despesas para o processo.
	If !(Left(TRB->WD_DESPESA,1) $ "1,2,9") .And. !(TRB->WD_DESPESA $ "701/702/703")
		If !lValNegativo .And. ValNegativo(.F.,MOutras,Nil,TRB->WD_VALOR_R,4)
		   Loop
		EndIf
	EndIf
	lDel_Desp := TRB->WD_DA # "1" .OR. ( MOpcao # FECHTO_NACIONALIZACAO .AND. !SW2->(DBSEEK(xFilial("SW2")+LEFT("DA"+SW6->W6_DI_NUM,LEN(SW2->W2_PO_NUM)))) )
	IF(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"DEL_DESP"),)
   	IF lDel_Desp
         IF lPrestacao  //TRATAMENTO PARA QUANDO A ROTINA FOR CHAMADA ATRAVÉS DA PRESTACAO DE CONTAS EICCA150 igor chiba 17/07/14
            If EICFI413()
               /* Após o cancelamento da prestação de contas, o título efetivo deve ser estornado do ERP,
                  evitando que permaneça um valor líquido inconsistente, uma vez que o fato gerador é o pagamento
                  e não a geração do título efetivo. */
               EAIEstornaTit()
            Else
               /* Quando o ERP não realizar todos os estornos das compensações, o sistema orientará o usuário
                  a efetuar a liberação do documento no ERP */
               If TRB->WD_VL_COMP <> WD_VLLIQ
                  MsgInfo(STR0237, STR0001) //"O cancelamento da prestação de contas não foi concluído. Realize novamente a operação ou efetue a liberação do documento ao ERP.", "Atenção"
               EndIf
            EndIf
            TRB->WKSTATUS:= DI501AtuStatusDesp()
         ELSE
            //IGOR CHIBA ENVIO DE ADAPTER DE EXCLUSAO despesa efetiva 04/07/14
            IF !EMPTY(TRB->WD_CTRFIN1)
               IF AvFlags("EIC_EAI") .AND. !EICFI411('M', ESTORNO)
                  LOOP
               ENDIF
            ENDIF
            DI500GrvDESP("4",.F.)    // JBS - 23/04/2004
         ENDIF
    ELSE //LGS - 26/08/2013 - Permitir exclusão de despesa DA do processo PAI no Desembaraço/Manutenção quando o tipo for Nacionalização.

         IF lPrestacao  //TRATAMENTO PARA QUANDO A ROTINA FOR CHAMADA ATRAVÉS DA PRESTACAO DE CONTAS EICCA150 igor chiba 17/07/14
            If EICFI413()
               /* Após o cancelamento da prestação de contas, o título efetivo deve ser estornado do ERP,
                  evitando que permaneça um valor líquido inconsistente, uma vez que o fato gerador é o pagamento
                  e não a geração do título efetivo. */
               EAIEstornaTit()
            Else
               /* Quando o ERP não realizar todos os estornos das compensações, o sistema orientará o usuário
                  a efetuar a liberação do documento no ERP */
                  MsgInfo(STR0237, STR0001) //"O cancelamento da prestação de contas não foi concluído. Realize novamente a operação ou efetue a liberação do documento ao ERP.", "Atenção"
            EndIf
            TRB->WKSTATUS:= DI501AtuStatusDesp()
         ELSE
            lRet := MsgYesNo(STR0226, STR0001) //"Confirma exclusão despesa de D.A.?"
            IF lRet .AND. TRB->WD_DA == "1"
	          //IGOR CHIBA ENVIO DE ADAPTER DE EXCLUSAO despesa efetiva
               IF !EMPTY(TRB->WD_CTRFIN1)
                  IF AvFlags("EIC_EAI") .AND. !EICFI411('M', ESTORNO)
                     LOOP
                  ENDIF
               ENDIF
		          DI500GrvDESP("4",.F.) //LGS - 26/08/2013
	           Else
                  MSGSTOP("Despesa de DA.")
                  LOOP
               Endif
            Endif
         ENDIF
   Endif

   Exit
ENDDO

DI500D_Tela()

Return

/*
Funcao      : DI501EnchoiceBar()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
Function DI501EnchoiceBar(oDlg,aOk,bCancel,aBotoes)

   Local oEnch

   oEnch := EnchoiceBar(oDlg, IIf(aOk != Nil, ( IIf(ValType(aOk)=="A", aOk[1], aOk) ), {||oDlg:End()}), bCancel, , aBotoes)

Return oEnch

/*
Funcao      : DI501GrvWkSW8()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
FUNCTION DI501GrvWkSW8(lGrava)//Antiga DI400GrvIvh()

LOCAL cFieldSW8,cFieldWk,bFieldWk,bFieldSW8,I

For I:=1 To SW8->(FCOUNT())

   cFieldSW8:=SW8->(FieldName(i))
   cFieldWk :='WK'+SUBSTR(cFieldSW8,4)
   IF Work_SW8->(FieldPos(cFieldWk)) == 0
      Loop
   Else
      //bFieldWk = {|Valor|IF(Valor==NIL,Work_SW8->WK???????,Work_SW8->WK???????:=Valor)}
      bFieldWk:=FieldWBlock(cFieldWk,Select("Work_SW8"))
   Endif
   //bFieldSW8 = {|Valor|IF(Valor==NIL,SW8->W8_???????,SW8->W8_???????:=Valor)}
   bFieldSW8:=FieldWBlock(cFieldSW8,Select("SW8"))

   IF lGrava
      Eval(bFieldSW8,Eval(bFieldWk))
   ELSE
      Eval(bFieldWK,Eval(bFieldSW8))
   ENDIF
Next
//If EICLoja()
   //Work_SW8->W8_FORLOJ := SW8->W8_FORLOJ
   //Work_SW8->W8_FABLOJ := SW8->W8_FABLOJ
//EndIf

RETURN .T.

/*
Funcao      : DI501GrvWkSW8()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
FUNCTION DI501SW7Del()// Antiga DI_Estorno //MJB-SAP-1000

LOCAL cMessage:='', nPeso_L:=0 , lEstornouItem := .F., aOcorrencia:={},cPos:= ""
LOCAL aInvAcerta:={}, aSaveOrd := SaveOrd({"SW2", "SW9", "SW7", "SWD", "SW8", "SW5" })
LOCAL i:=0
Local nVlrDA, nVlDins
Local nDinAtu:=0
Local aTotDesp:={}
Local aTotDespDa:={}
Local aDa:={}
Local aAuxHawb:={},cAuxW6:=""
Local nRecSW6Est
Local lPLIAntes := .F. // FSM - 22/05/2012
Local lRet := .T.
Local lPliAtual := .F. //Verifica se o desembaraco de nacionalizacao tem pli.(item anuente)
Private lDesvio := .F.

PRIVATE aDespDa:={},aTaxas:={}
PRIVATE nRateioDesp:=0,nVlrSWD:=0

DBSELECTAREA("TRB")
TRB->(DBGOTOP())
ProcRegua( TRB->(EasyReccount("TRB")) )

lEstornouItem = .F.

nRecSW6Est:=SW6->(RECNO())
AADD(aAuxHawb,M->W6_HAWB)
nVlDins := 0
//Begin Transaction

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ESTORNO_ANTES"),)

DO WHILE TRB->(!EOF())

   IncProc(STR0093 + W7_COD_I)//"Processando item: "


   //FSM - 22/05/2012
   lPLIAntes := DI500PLIAntes("ESTORNO")

   //MFR TE-7011 WCC-534964 MTRADE-1554 28/09/2017   
   EW4->(DBSETORDER(2))
   If EW4->(dBSeek(xFilial("EW4")+M->W6_HAWB))
      While EW4->(!Eof()).AND.EW4->EW4_FILIAL==xFilial("EW4").AND.EW4->EW4_HAWB==SW6->W6_HAWB    
            EW4->(RECLOCK("EW4",.F.))
            EW4->EW4_HAWB := SPACE(AVSX3("EW4_HAWB",3))
            EW4->(MSUNLOCK())
      End
   EndIf          
   EW4->(DBSETORDER(1))

   // Bete - 17/03/06 - Guarda as taxas da DA, pois num estorno parcial de DI de nacionalização, as despesas da DA
   // devem ser rateadas novamente, devido a mudanca de valor da DI.
   If MOpcao == FECHTO_NACIONALIZACAO

      SW2->(DBSETORDER(1))
      SW9->(DBSETORDER(3))
      IF SW2->(DBSEEK(xFilial("SW2")+TRB->W7_PO_NUM)) .AND. ! EMPTY(ALLTRIM(SW2->W2_HAWB_DA))
         SW9->(DBSEEK(xFilial("SW9")+SW2->W2_HAWB_DA))
         DO WHILE ! SW9->(EOF()) .AND. SW9->W9_HAWB == SW2->W2_HAWB_DA
            nInd:=ASCAN(aTaxas,{|y| y[1] == SW9->W9_HAWB .AND. y[2] == SW9->W9_MOE_FOB})
            IF nInd == 0
               AADD(aTaxas, { SW9->W9_HAWB, SW9->W9_MOE_FOB, SW9->W9_TX_FOB } )
            ENDIF
            SW9->(DBSKIP())
         ENDDO
      Endif

      SW5->(DbSetOrder(8))
      If SW5->(DbSeek(xFilial("SW5") + TRB->W7_PGI_NUM + TRB->W7_PO_NUM )) // Posiciona na DA
         While SW5->(!Eof()) .And. (xFilial("SW5") == SW5->W5_Filial) .And. (TRB->W7_PGI_NUM == SW5->W5_PGI_NUM) .And. ;
         (TRB->W7_PO_NUM == SW5->W5_PO_NUM)
            If !Empty(SW5->W5_HAWB) .And. SW5->W5_SEQ <> 0
               If (ASCAN(aAuxHawb,{|x| x== SW5->W5_HAWB})) = 0
                  AADD(aAuxHawb,SW5->W5_HAWB)
                  If SW6->(DbSeek(xFilial("SW6")+SW5->W5_HAWB))
                  //While SW6->(!EOF()) .And. xFilial("SW6") == SW5->W5_Filial .And. SW6->W6_HAWB == SW5->W5_HAWB
                     IF !Empty(SW6->W6_DT_ENCE) .And. SW6->W6_HAWB <> cAuxW6 // Entra apenas uma vez por processo.
                        SW8->(DbSetOrder(1))
                        If SW8->(DBSEEK(xFilial("SW8")+SW6->W6_HAWB))

                           DO WHILE ! SW8->(EOF()) .AND. SW8->W8_HAWB == SW6->W6_HAWB

                              If SW2->(DBSEEK(xFilial("SW2") + SW8->W8_PO_NUM)) .AND. ! EMPTY(ALLTRIM(SW2->W2_HAWB_DA))
                                 nInd:=ASCAN(aTaxas,{|y| y[1] == SW2->W2_HAWB_DA .AND. y[2] == SW2->W2_MOEDA})
                                 IF nInd == 0
                                    cHelp:=SW2->W2_MOEDA+" / "+ALLTRIM(SW2->W2_HAWB_DA)
                                    Help("",1,"AVG0000730",,cHelp,4,0)
                                    //MSGINFO("A cotacao da moeda.: " + SW2->W2_MOEDA + " para o processo.: " + SW2->W2_HAWB_DA + " Nao foi encontrada" +;
                                    //        "O rateio das despesas nao podera ser efetuado")
                                    EXIT
                                 ENDIF

                                 nVlDins += (SW8->W8_PRECO * SW8->W8_QTDE) * aTaxas[nInd,3]

                              Endif
                              SW8->(DBSKIP())

                           ENDDO

                           cAuxW6:=SW6->W6_HAWB
                           SWD->(DbSetOrder(1))
                           If SWD->(DbSeek(xFilial("SWD")+SW6->W6_HAWB))
                              While SWD->(!Eof()) .And. (xFilial("SWD") == SWD->WD_Filial) .And. (SWD->WD_HAWB == SW6->W6_HAWB)
                                 If !(Substr(SWD->WD_DESPESA,1,1) $ "1279") .And. SWD->WD_DA == "1"
                                    nPos := aScan(aTotDesp,{ |x| x[2] == SWD->WD_DESPESA .AND. x[4] == SWD->WD_DES_ADI })
                                    If nPos > 0
                                       aTotDesp[nPos][3] += SWD->WD_VALOR_R // TLM - À partir da segunda DI encerrada as despesas são somadas pelo código e posição no array.
                                    Else
                                       Aadd(aTotDesp,{ SWD->WD_HAWB, SWD->WD_DESPESA, SWD->WD_VALOR_R, SWD->WD_DES_ADI }) // TLM - aTotDesp recebe todas as despesas por linha da DI encerrada.
                                    EndIf
                                EndIf
                                SWD->(DbSkip())
                              EndDo
                           EndIf

                        EndIf
                     Endif
                     //SW6->(DbSkip())
                     //EndDo
                  EndIf
               EndIf
            EndIf
            SW5->(DbSkip())
         EndDo
      EndIf
      SW6->(DBGOTO(nRecSW6Est))
      If SW2->(DBSEEK(xFilial("SW2") + TRB->W7_PO_NUM)) .AND. ! EMPTY(ALLTRIM(SW2->W2_HAWB_DA))
         nInd:=ASCAN(aTaxas,{|y| y[1] == SW2->W2_HAWB_DA .AND. y[2] == SW2->W2_MOEDA})
         IF nInd == 0
            cHelp:=SW2->W2_MOEDA+" / "+ALLTRIM(SW2->W2_HAWB_DA)
            Help("",1,"AVG0000730",,cHelp,4,0)
            //MSGINFO("A cotacao da moeda.: " + SW2->W2_MOEDA + " para o processo.: " + SW2->W2_HAWB_DA + " Nao foi encontrada" +;
            //        "O rateio das despesas nao podera ser efetuado")
            EXIT
         ENDIF

         If !TRB->WK_OK == cMarca
            nDinAtu += (TRB->W7_PRECO * TRB->W7_QTDE) * aTaxas[nInd,3]
         Endif

         IF ASCAN(aDA,{|x|x==SW2->W2_HAWB_DA}) = 0
            AADD( aDA, SW2->W2_HAWB_DA)
         ENDIF
      ENDIF

   ENDIF

   IF !TRB->WK_OK == cMarca
      TRB->(DBSKIP())
      LOOP
   ENDIF

   nSaldo_LI:=0
   lEstornouItem := .T.

   SW7->(DBGOTO(TRB->WKRECNO))   //GFC 22/12/03 - Passado para cima para integridade referencial.
   DI500SW8Del(SW7->W7_HAWB,SW7->W7_COD_I,SW7->W7_FABR,SW7->W7_FORN,;
               SW7->W7_PGI_NUM,SW7->W7_SI_NUM,SW7->W7_PO_NUM,SW7->W7_CC,;
               SW7->W7_REG,aInvAcerta)

   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ESTORNO_ITEM"),)
   IF ascan(aEnv_PO,SW7->W7_PO_NUM + SW7->W7_POSICAO) == 0
      aadd(aEnv_PO,SW7->W7_PO_NUM + SW7->W7_POSICAO)
   ENDIF

   //Atualização dos títulos PR
   If AvFlags("EIC_EAI")
      If AScan(aPOs, SW7->W7_PO_NUM) == 0
         AAdd(aPOs, SW7->W7_PO_NUM)
      EndIf
   EndIf

   nPeso_L  += SW7->W7_PESO  * SW7->W7_QTDE

   SW7->(RecLock("SW7",.F.,.T.))
   SW7->(DBDELETE())
   SW7->(MsUnlock())
   IF ASCAN(aOcorrencia,TRB->W7_PO_NUM) = 0
      AADD (aOcorrencia,TRB->W7_PO_NUM)
   ENDIF

   IF PosOrd2_IT_Guias(SW6->W6_HAWB,TRB->W7_CC,TRB->W7_SI_NUM,TRB->W7_COD_I ,;
                       TRB->W7_FABR,TRB->W7_FORN,TRB->W7_REG,TRB->W5_PGI_NUM,TRB->W7_PO_NUM,TRB->W7_POSICAO,EICRetLoja("TRB", "W7_FABLOJ"), EICRetLoja("TRB", "W7_FORLOJ"))   // LDR 07/04/2004

      nSaldo_LI := SW5->W5_QTDE
      SW5->(RecLock("SW5",.F.,.T.))
      SW5->(DBDELETE())
      SW5->(MsUnlock())
   ENDIF

   IF PosOrd1_IT_Guias(TRB->W5_PGI_NUM,TRB->W7_CC,TRB->W7_SI_NUM,;
                       TRB->W7_COD_I,TRB->W7_FABR,TRB->W7_FORN  ,;
                       TRB->W7_REG,0,TRB->W7_PO_NUM, EICRetLoja("TRB", "W7_FABLOJ"), EICRetLoja("TRB", "W7_FORLOJ"))

      SW5->(RecLock("SW5",.F.,.T.))
      // EOB - 26/06/08 - Ao desmarcar um item anuente do embarque, deve-se voltar o saldo do item para a LI, retirando a diferenca encontrada
      //                  do saldo do item do PO.
      IF SW5->W5_FLUXO == "1" // Anuente
         lPliAtual := .T.
         If SW5->(FIELDPOS("W5_QTDELI")) > 0 
            nDifLI := SW5->W5_QTDELI - SW5->W5_QTDE
            IF nDifLI > 0
               // Posiciona na seq 0 do SW3 para pegar o saldo
               nSaldoW3 := DI400POSld("S")
               IF SW5->W5_QTDE + nSaldoW3 > SW5->W5_QTDELI
                  nQtde :=  SW5->W5_QTDELI
                  nDiferenca := SW5->W5_QTDELI - SW5->W5_QTDE
               ELSE
                  nQtde :=  SW5->W5_QTDE + nSaldoW3
                  nDiferenca := nSaldoW3
               ENDIF
               SW5->W5_QTDE    := nQtde
               SW5->W5_SALDO_Q := SW5->W5_QTDE

               DI400POSld("2", nSaldoW3)
            ELSE
               SW5->W5_SALDO_Q:=SW5->W5_SALDO_Q + TRB->W7_QTDE
            EndIf
			ELSE
            SW5->W5_SALDO_Q:=SW5->W5_SALDO_Q + TRB->W7_QTDE
         ENDIF
      ELSE
         lPliAtual := .F.
         SW5->W5_SALDO_Q:=SW5->W5_SALDO_Q + TRB->W7_QTDE
      ENDIF
      SW5->(MsUnlock())
   ENDIF

   //NCF - 22/03/2011 - Item anuente com LI do Embarque no PN (Estorno)
   IF MOpcao == FECHTO_NACIONALIZACAO .And. lPLIAntes .And. !lPliAtual //FSM - 24/05/2012
      nRegisSW3 := SW3->(RECNO())
      nOrdemSW3 := SW3->(INDEXORD())
      SW3->(DbSetOrder(8))
      SW3->(DBSeek(xFilial("SW3")+TRB->W7_PO_NUM+TRB->W7_POSICAO))
      IF SW3->(!EOF()) .And. SW3->W3_FLUXO == "1"
         DI400POSld( "2" , 0 - TRB->W7_QTDE , .T. )
      ENDIF
      SW3->(DbSetOrder(nOrdemSW3))
      SW3->(DbGoTo(nRegisSW3))
   ENDIF

   TRB->(DBSKIP())
ENDDO

SW6->(DBGOTO(nRecSW6Est))
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ESTORNO_MEIO"),)

DI500AcertaSW9(SW6->W6_HAWB,aInvAcerta)  //GFC 22/12/03 - Passado para cima para Integridade Referencial.

SW7->(DBSETORDER(1))
IF !SW7->(DBSEEK(xFilial("SW7")+SW6->W6_HAWB))

   DBSELECTAREA("SW6")
   M->W6_HAWB:=SW6->W6_HAWB
   IF !EMPTY(SW6->W6_OBS)
      MSMM(SW6->W6_OBS,,,,2)// exclui campo memo
   ENDIF
   IF !EMPTY(SW6->W6_COMPLEM)
      MSMM(SW6->W6_COMPLEM,,,,2)// exclui campo memo
   ENDIF
   SW6->(RecLock("SW6",.F.,.T.))
   SW6->(DBDELETE())
   SW6->(MsUnlock())

   IF lValidaEIC //JAP 19/08/06
      If Select("EIC") > 0
         EIC->(dbSetOrder(1))
         EIC->(dbSeek(xFilial("EIC")+M->W6_HAWB))
         DO While !(EIC->(Eof())) .And. EIC->EIC_FILIAL+EIC->EIC_HAWB == ;
                                     xFilial("EIC")+M->W6_HAWB
            EIC->(RecLock("EIC", .F.))
            EIC->(dbDelete())
            EIC->(MsUnLock())
            EIC->(dbSkip())
         EndDo
      EndIf
   ENDIF

   // DFS - 02/09/2009 - Ponto de entrada para que as despesas da SWD não sejam deletadas
   lDesvio := .F.
   If EasyEntryPoint("EICDI500")
      ExecBlock("EICDI500",.F.,.F.,"DESVIA_DELET")
   EndIf

   If !lDesvio
      SWD->(DBSETORDER(1))
      IF SWD->(DBSEEK(xFilial()+M->W6_HAWB))
         DO WHILE ! SWD->(EOF()) .AND. SWD->WD_FILIAL == xFilial("SWD") .AND. SWD->WD_HAWB == M->W6_HAWB
            If SWD->WD_GERFIN  == "1";
               .AND. ( SWD->WD_DESPESA <> '102' .OR. !EasyGParam("MV_CAMBFRE",,.F.) );
               .AND. ( SWD->WD_DESPESA <> '103' .OR. !EasyGParam("MV_CAMBSEG",,.F.) )
                  if !EICFI400("ESTORNO_DESPESA_DI")
                     lRet := .F.
                  endif
            ENDIF
            SWD->(RecLock("SWD",.F.,.T.))
            SWD->(DBDELETE())
            SWD->(MsUnLock())
            SWD->(DBSKIP())
         ENDDO
      ENDIF
   Endif

   EIR->(DBSETORDER(1))
   IF EIR->(DBSEEK(xFilial()+M->W6_HAWB))
      DO WHILE ! EIR->(EOF()) .AND. EIR->EIR_FILIAL == xFilial("EIR") .AND. EIR->EIR_HAWB == M->W6_HAWB
         EIR->(RecLock("EIR",.F.,.T.))
         EIR->(DBDELETE())
         EIR->(MsUnLock())
         EIR->(DBSKIP())
      ENDDO
   ENDIF

   // EOS -  Se existir os cpos referente a pagamento antecipado, trata Seek
   // e While com um campo a mais o WB_PO_DI que, nas parcelas de cambio de DI tera
   // como conteudo a letra "D". Tratando-se de estorno, antes de deletar as parcelas
   // de cambio do SWB, verifica se nao tem lancamentos de adiantamento p/ este processo
   // onde, se tiver recompoe o saldo no SWA.
   SWB->(DBSETORDER(1))
   cFilSWB := xFilial("SWB")
   cFilSWA := xFilial("SWA")
    IF lCposAdto
      cChavSWB := cFilSWB + M->W6_HAWB + "D"
      bWhilSWB := {|| SWB->WB_FILIAL == cFilSWB .AND. SWB->WB_HAWB = M->W6_HAWB .AND. ;
                      SWB->WB_PO_DI  == "D" }
      cChavSWA := cFilSWA + M->W6_HAWB + "D"
   ELSE
      cChavSWB := cFilSWB + M->W6_HAWB
      bWhilSWB := {|| SWB->WB_FILIAL == cFilSWB .AND. SWB->WB_HAWB = M->W6_HAWB }
      cChavSWA := cFilSWA + M->W6_HAWB
   ENDIF

   SWB->(DbSeek(cChavSWB))
   Do While lRet .And. (! SWB->(Eof()) .AND. EVAL(bWhilSWB))
      IF lCposAdto .And. !Empty(SWB->WB_NUMPO)
         If SWA->(DbSeek(cFilSWA + SWB->WB_NUMPO + "A"))
            SWA->(RecLock("SWA",.F.,.T.))
            SWA->WA_SLDANT += SWB->WB_PGTANT
            SWA->(MsUnlock())
         ElseIf SWA->(DbSeek(cFilSWA + SWB->WB_NUMPO + "F")) // GCC - 28/08/2013 - Verificar se o pagamento antecipado é vinculado a Fornecedor
            SWA->(RecLock("SWA",.F.,.T.))
            SWA->WA_SLDANT += SWB->WB_PGTANT
            SWA->(MsUnlock())
         ElseIf SWA->(DbSeek(cFilSWA + SWB->WB_NUMPO + "C")) // GCC - 28/08/2013 - Verificar se o pagamento antecipado é vinculado a Credito a Fornecedor
            SWA->(RecLock("SWA",.F.,.T.))
            SWA->WA_SLDANT += SWB->WB_PGTANT
            SWA->(MsUnlock())
         EndIf
      ENDIF
      IF lFinanceiro .And. !Empty(SWB->WB_NUMDUP) //LRS - 12/12/2017
         lRet := FI400TITFIN("SWB","4",.T.) 
      EndIF
      SWB->(RecLock("SWB",.F.,.T.))
      SWB->(DBDELETE())
      SWB->(MsUnlock())
      SWB->(DBSKIP())
   ENDDO

   SWA->(DBSETORDER(1))
   IF SWA->(DBSEEK(cChavSWA))
      SWA->(RecLock("SWA",.F.,.T.))
      SWA->(DBDELETE())
      SWA->(MsUnlock())
   ENDIF

   DI500EIGrava('ESTORNO',SW6->W6_HAWB,{})

   cMessage:= STR0094+UPPER(cCadastro) //"ESTORNO TOTAL "

ELSE

   IF lEstornouItem
      DBSELECTAREA("SW6")
      SW6->(RecLock("SW6",.F.,.T.))
      SW6->W6_ADICAOK :=NAO
      SW6->W6_DT_ENCE :=dDataBranca
      SW6->W6_PESOL   :=SW6->W6_PESOL-nPeso_L
      SW6->(MsUnlock())
   ENDIF

	// Bete - 17/03/06 - Num estorno parcial de DI de nacionalização, as despesas da DA devem ser rateadas
	// novamente, devido a mudanca de valor da DI.
	If MOpcao == FECHTO_NACIONALIZACAO

	  //nRecSW6:= SW6->(recno())


         nVlrDA := 0
         FOR i:=1 TO LEN(aDa)
             IF SW6->(DBSEEK(xFilial("SW6") + aDA[i]))
                nVlrDA += SW6->W6_FOB_TOT
             ENDIF
             IF SWD->(DBSEEK(xFilial("SWD") + aDA[i]))
                Do While ! SWD->(EOF()) .AND. SWD->WD_HAWB = aDA[i] .AND. xFilial("SWD") = SWD->WD_FILIAL
                   If SWD->WD_DESPESA#"101" .AND. SWD->WD_DESPESA#"102" .AND. SWD->WD_DESPESA#"103" .AND. Empty(SWD->WD_NF_COMP) .AND. ;
                      IF(EasyGParam("MV_G901DIN",,.T.),.T., LEFT(SWD->WD_DESPESA,1)#"9")

                      nDesp:=ASCAN(aTotDespDa, {|x| x[1] = SWD->WD_DESPESA .AND. x[4] = SWD->WD_DES_ADI})
                      If nDesp = 0
                         Aadd(aTotDespDa,{SWD->WD_DESPESA,SWD->WD_VALOR_R,SWD->(RECNO()), SWD->WD_DES_ADI})
                      Else
                         aTotDespDa[nDesp,2] += SWD->WD_VALOR_R
                      EndIf
                   ENDIF
                   SWD->(dbSkip())
                ENDDO
             ENDIF
         NEXT

         FOR i:=1 TO LEN(aTotDespDA)
            nRateioDesp := (nDinAtu/(nVlrDA - nVlDins))
            nVlrSWD     := aTotDespDA[i,2]

            IF ( nPos:= aScan(aTotDesp, {|x| x[2] == aTotDespDa[i,1] .AND. x[4] == aTotDespDa[i,4] })) > 0
               nVlrSWD:= nVlrSWD - aTotDesp[nPos][3]
            EndIf

            IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"RATEIO_ESTORNO_PARCIAL"),)

            nValorSWD:=nVlrSWD*nRateioDesp

            nDespDa:=ASCAN(aDespDa, {|x| x[1] = aTotDespDa[i,1] .AND. x[4] = aTotDespDa[i,4]})
            If nDespDa = 0
               Aadd(aDespDa,{aTotDespDa[i,1],nValorSWD,aTotDespDa[i,3], aTotDespDa[i,4]})
            Else
               aDespDa[nDespDa,2] += nValorSWD
            EndIf
         NEXT

         SW6->(DBGOTO(nRecSW6Est))

         If SWD->(DBSEEK(xFilial("SWD")+SW6->W6_HAWB))
		    Do While ! SWD->(EOF()) .AND. SWD->WD_HAWB = SW6->W6_HAWB .AND. xFilial("SWD") = SWD->WD_FILIAL
				If SWD->WD_DA $ cSim
					nDespDa:=ASCAN(aDespDa, {|x| x[1] = SWD->WD_DESPESA .AND. x[4] = SWD->WD_DES_ADI} )
					SWD->(RECLOCK('SWD',.F.,.F.,.T.))
					If nDespDa # 0
						SWD->WD_VALOR_R    := aDespDa[nDespDa,2]
						aDespDa[nDespDa,2] := 0
					Else
						SWD->(DBDELETE())
					EndIf
					SWD->(MSUNLOCK())
				EndIf
				SWD->(DBSKIP())
			EndDo
		EndIf

	ENDIF
ENDIF

//AOM - 06/04/2011 - Salvando operações especiais
If lOperacaoEsp
   oOperacao:SaveOperacao()
EndIf

//DI500AcertaSW9(SW6->W6_HAWB,aInvAcerta)
RestOrd(aSaveOrd, .T.)

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ESTORNO_DEPOIS"),)
IF AvFlags("EIC_EAI") .and. Len(aEnv_PO) > 0
   /* Verifica se existem pedidos originados por processo de entreposto e
      retorna os pedidos válidos para a geração da programação de entregas*/
   aEnv_PO:= PO420PedOri(aEnv_PO)
   For i = 1 To Len(aEnv_PO) //SSS -  REG 4.5 03/06/14
       If !EICPO420(.T.,4,,"SW2",.F.,aEnv_PO[I])// EICPO420(lEnvio,nOpc,aCab,cAlias,lWk,cPo_num)
          cPos+=ALLTRIM(aEnv_PO[I])+", "
       EndIf
   Next
   If !Empty(cPos)
      MsgInfo(StrTran(STR0095, "####", cpos), STR0001) //"Acesse os Purchase Orders #### para realização dos ajustes necessários."
   EndIf
   aEnv_PO:= {}
ENDIF
FOR I=1 TO LEN(aOcorrencia)
    Grava_Ocor(aOcorrencia[I],dDataBase,cMessage)
NEXT

//End Transaction

TRB->(DBGOTOP())
RETURN lRet

/*
Funcao      : DI501SW8Del()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
FUNCTION DI501SW8Del(PHawb,PItem,PFabr,PForn,PPGi,PSi,PPo,PCc,PReg,aInvAcerta, cFabLoj, cForLoj)// Antiga DI410_IVH() //MJB-SAP-1000

LOCAL cFilSW8:=xFilial('SW8'), nOrdSW7:=SW7->(IndexOrd())

If lIntDraw
   ED4->(dbSetOrder(2))
EndIf
SW7->(dbSetOrder(4)) //W7_FILIAL+W7_HAWB+W7_PO_NUM+W7_POSICAO+W7_PGI_NUM
SW8->(DBSETORDER(3)) //W8_FILIAL+W8_HAWB+W8_PGI_NUM+W8_PO_NUM+W8_SI_NUM+W8_CC+W8_COD_I+STR(W8_REG,4,0)
// GFP - 13/04/2012 - Ajustado Seek
SW8->(DBSEEK(cFilSW8 + AvKey(PHawb,"W8_HAWB")   +;
                       AvKey(PPgi,"W8_PGI_NUM") +;
                       AvKey(PPo,"W8_PO_NUM")   +;
                       AvKey(PSi,"W8_SI_NUM")   +;
                       AvKey(PCc,"W8_CC")       +;
                       AvKey(PItem,"W8_COD_I")  +;
                       STR(PReg,nTamReg,0)))
// GFP - 13/04/2012 - Ajustado While
DO WHILE ! SW8->(EOF())                                .AND. SW8->W8_FILIAL == cFilSW8                 .AND.;
           SW8->W8_HAWB    == AvKey(PHawb,"W8_HAWB")   .AND. SW8->W8_COD_I  == AvKey(PItem,"W8_COD_I") .AND.;
           SW8->W8_PGI_NUM == AvKey(PPgi,"W8_PGI_NUM") .AND. SW8->W8_SI_NUM == AvKey(PSi,"W8_SI_NUM")  .AND.;
           SW8->W8_CC      == AvKey(PCc,"W8_CC")       .AND. SW8->W8_REG    == PReg    .AND.;
           SW8->W8_PO_NUM  == AvKey(PPo,"W8_PO_NUM")
   IF ASCAN(aInvAcerta,SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8", "W8_FORLOJ")) = 0
      AADD(aInvAcerta,SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8", "W8_FORLOJ"))
   ENDIF
   IF !EMPTY(SW8->W8_DESC_DI)
      MSMM(SW8->W8_DESC_DI,,,,2)
   ENDIF

   If lIntDraw .and. !Empty(SW8->W8_AC) .and. ED4->(dbSeek(cFilED4+SW8->W8_AC+SW8->W8_SEQSIS))

      If ED0->ED0_AC <> ED4->ED4_AC .or. cFilED0 <> ED0->ED0_FILIAL
         ED0->(dbSetOrder(2))
         ED0->(dbSeek(cFilED0+ED4->ED4_AC))
      EndIf

      //** AAF 27/09/06 - Verifica se o registro já está travado.
      If !ED4->( isLocked() )
         ED4->(RecLock("ED4",.F.))
      EndIf
      //**

      If ED0->ED0_TIPOAC <> GENERICO .or. ED4->ED4_NCM <> NCM_GENERICA
         ED4->ED4_QT_DI  += SW8->W8_QT_AC
         If AvVldUn(ED4->ED4_UMNCM) // MPG - 06/02/2018
            SW7->(dbSeek(xFilial("SW7")+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM))
            //ED4->ED4_SNCMDI += SW7->W7_PESO * SW8->W8_QTDE //comentado por WFS 22/07/11.
            ED4->ED4_SNCMDI += If ((SW7->W7_PESO * SW8->W8_QT_AC) < SW8->W8_QT_AC2, SW8->W8_QT_AC2, (SW7->W7_PESO * SW8->W8_QT_AC))//LGS-15/09/2014 - Ajuste para corrigir erro ao voltar saldo qdo estorna DI
         Else
            ED4->ED4_SNCMDI += SW8->W8_QT_AC2
         EndIf
      EndIf

      //AOM - 29/09/10
      If ED4->(FieldPos("ED4_SNCMEX")) > 0
         ED4->ED4_SNCMEX -= SW8->W8_QT_AC2
      EndIf

      If ED4->(FieldPos("ED4_SQTDEX")) > 0
         ED4->ED4_SQTDEX -= SW8->W8_QT_AC
      EndIf

      ED4->ED4_VL_DI  += SW8->W8_VL_AC
      ED4->(msUnlock())
      If cAntImp=="2" .and. ED0->ED0_MODAL == "1" //GFC - 17/07/2003 - Anterioridade Drawback
         DIGrvAnt(2,SW8->W8_HAWB,SW8->W8_PO_NUM,SW8->W8_INVOICE,SW8->W8_COD_I,SW8->W8_POSICAO,SW8->W8_PGI_NUM)
      EndIf
   EndIf
   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"DELETA_SW8DEL"),)

   IF FindFunction("DI500SWVEstorno")
      DI500SWVEstorno(SW8->(W8_INVOICE+W8_PGI_NUM+W8_PO_NUM+W8_POSICAO))// AWR - Lote
   ENDIF
   SW8->(RecLock("SW8",.F./*,.T.*/))
   SW8->(DBDELETE())
   SW8->(MsUnlock())
   SW8->(DBSKIP())
ENDDO

SW7->(dbSetOrder(nOrdSW7))

If lIntDraw
   ED4->(dbSetOrder(1))
EndIf

RETURN .T.

/*
Funcao      : DI501AcertaSW9()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
FUNCTION DI501AcertaSW9(cProcesso,aInvAcerta)

LOCAL cFilSW7:=xFilial('SW7'), a
LOCAL cFilSW8:=xFilial('SW8')
LOCAL cFilSW9:=xFilial('SW9')
LOCAL nTotalQTDE:=nRateio:=nTotalPESO:=0
LOCAL aAcertos:={},nRecFRE:=nRecVlr:=1,lPerg
LOCAL nMaiorFre:=nMaiorVlr:=0,nCont:=0,lRateia:=.F.
LOCAL cSQLChv := ""
SW8->(DBSETORDER(1))
SW9->(DBSETORDER(3))
SW7->(DBSETORDER(4))
If lInvAnt //DRL - 16/09/09 - Invoices Antecipadas
   EW4->(dbSetOrder(1))
EndIf
ProcRegua(10)

lRDRatPorFOB:=.T.
lRDRatFrete :=.T.

IF SW9->(DBSEEK(cFilSW9+cProcesso))
   DO WHILE SW9->(!EOF())  .AND.;
            SW9->W9_HAWB   == cProcesso .AND.;
            SW9->W9_FILIAL == cFilSW9

      IF nCont > 10
         nCont:=0
         ProcRegua(10)
      ELSE
         nCont++
         IncProc(STR0096+SW9->W9_INVOICE) //"Acertando Invoice: "
      ENDIF
      SW9->(RecLock("SW9",.F.))

      IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"DELETA_SW9_A"),)

      IF !SW8->(DBSEEK(cFilSW8+SW9->W9_HAWB+SW9->W9_INVOICE+SW9->W9_FORN+SW9->W9_FORLOJ))

         If lInvAnt .And. EW4->(dbSeek(XFILIAL("EW4")+SW9->W9_INVOICE+SW9->W9_FORN+SW9->W9_FORLOJ)) .AND. EW4->EW4_HAWB == SW9->W9_HAWB //AAF 27/12/2019 - Validar se a invoice antecipada realmente é deste embarque. Pode ser de outro com o mesmo nro. //DRL - 22/09/09 - Invoices Antecipadas
            EW4->(RECLOCK("EW4",.F.))
            EW4->EW4_HAWB := SPACE(AVSX3("EW4_HAWB",3))
            EW4->(MSUNLOCK())
         EndIF
             //**igor chiba 29/09/09 integrando deleção de capa quano extornar todos itens invoice
         IF LCAMBIO_EIC
            EW4->(DBSETORDER(1))
            cChave:=cFilSW9+SW9->W9_HAWB+SW9->W9_INVOICE+SW9->W9_FORN
            cSQLChv:="W9_FILIAL  = '" + cFilSW9         + "' AND " +;
                     "W9_HAWB    = '" + SW9->W9_HAWB    + "' AND " +;
                     "W9_INVOICE = '" + SW9->W9_INVOICE + "' AND " +;
                     "W9_FORN    = '" + SW9->W9_FORN    + "' "

            IF !EW4->(DBSEEK(XFILIAL('EW4')+SW9->W9_INVOICE+SW9->W9_FORN))	.AND.	lEICFI06  //se Ñ tiver invoice antecipada itegrar qualquer alteração na invoice
               If FindFunction("EICINTEI17")
                  EasyExRdm("EICINTEI17", 'E','INV',cChave,"EX",cSQLChv)
               EndIf
            ENDIF
         ENDIF
         //**
         SW9->(DBDELETE())
         SW9->(MsUnlock())
         SW9->(DBSKIP())
         LOOP
      ELSEIF ASCAN(aInvAcerta,SW9->W9_INVOICE+SW9->W9_FORN+SW9->W9_FORLOJ) # 0
         SW9->W9_FOB_TOT:=0
         nTotalQTDE:=nTotalPESO:=0
         nCont:=0
         DO WHILE SW8->(!EOF()) .AND. SW8->W8_HAWB   ==SW9->W9_HAWB    .AND.;
                                      SW8->W8_INVOICE==SW9->W9_INVOICE .AND.;
                                      SW8->W8_FORN   ==SW9->W9_FORN    .AND.;
                                      SW8->W8_FILIAL == cFilSW8        .And.;
                                      (!EICLoja() .Or. SW8->W8_FORLOJ == SW9->W9_FORLOJ)
            nCont++
            SW9->W9_FOB_TOT+=(SW8->W8_QTDE*SW8->W8_PRECO)
            nTotalQTDE     +=SW8->W8_QTDE
            IF SW7->(DBSEEK(cFilSW7+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM))
               nTotalPESO  +=(SW8->W8_QTDE*SW7->W7_PESO)
            ENDIF
            SW8->(DBSKIP())
         ENDDO

         lPerg:=(DI500RetVal("TOT_INV,SEM_FOB","TAB",.T.) # 0) // EOB - 21/05/08 - chamada da função DI500RetVal

         lRateia:=DI500InvConf(.F.,SW9->W9_INVOICE,SW9->W9_FORN,lPerg, SW9->W9_FORLOJ)

         aAcertos:={}
         AADD(aAcertos,{0,SW9->W9_INLAND })
         AADD(aAcertos,{0,SW9->W9_PACKING})
         AADD(aAcertos,{0,SW9->W9_DESCONT})
         AADD(aAcertos,{0,SW9->W9_OUTDESP})
         AADD(aAcertos,{0,SW9->W9_FRETEIN})
         // EOB - 21/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
         IF lSegInc
            AADD(aAcertos,{0,SW9->W9_SEGURO})
         ENDIF

         ProcRegua(nCont)
         SW8->(DBSEEK(cFilSW8+SW9->W9_HAWB+SW9->W9_INVOICE+SW9->W9_FORN+SW9->W9_FORLOJ))
         DO WHILE SW8->(!EOF()) .AND. SW8->W8_HAWB   ==SW9->W9_HAWB    .AND.;
                                      SW8->W8_INVOICE==SW9->W9_INVOICE .AND.;
                                      SW8->W8_FORN   ==SW9->W9_FORN    .AND.;
                                      SW8->W8_FILIAL == cFilSW8 .AND. lRateia .And.;
                                      (!EICLoja() .Or. SW8->W8_FORLOJ == SW9->W9_FORLOJ)
            IncProc(STR0096+SW9->W9_INVOICE) //"Acertando Invoice: "
            SW8->(RecLock("SW8",.F.))

            IF lRDRatPorFOB
               nRateio:=(SW8->W8_QTDE*SW8->W8_PRECO)/SW9->W9_FOB_TOT
               If EasyGParam("MV_RAT_INL",, 1) == 1 //JVR - 05/11/2009 - Rateio INLAND
                  SW8->W8_INLAND  :=DI500Trans(nRateio*SW9->W9_INLAND )
               EndIf
               SW8->W8_PACKING :=DI500Trans(nRateio*SW9->W9_PACKING)
               SW8->W8_DESCONT :=DI500Trans(nRateio*SW9->W9_DESCONT)
               SW8->W8_OUTDESP :=DI500Trans(nRateio*SW9->W9_OUTDESP)
               // EOB - 21/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
               IF lSegInc
                  IF !EMPTY(SW9->W9_SEGURO) .AND. SW9->W9_SEGINC $ cNao
                     SW8->W8_SEGURO :=DI500Trans(nRateio*SW9->W9_SEGURO)
                  ENDIF
               ENDIF
            ENDIF

            IF lRDRatFrete .AND. !EMPTY(SW9->W9_FRETEIN) .AND. SW9->W9_FREINC $ cNao
               IF SW9->W9_RAT_POR == "1" //Peso
                  nRateio:=0
                  IF SW7->(DBSEEK(cFilSW7+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM))
                     nRateio:=(SW8->W8_QTDE*SW7->W7_PESO)/nTotalPESO
                  ENDIF
               ELSEIF SW9->W9_RAT_POR == "3" //Quantidade
                  nRateio:=SW8->W8_QTDE/nTotalQTDE
               ENDIF
               If EasyGParam("MV_RAT_INL",, 1) == 2 //JVR - 05/11/2009 - Rateio INLAND
                  SW8->W8_INLAND  :=DI500Trans(nRateio*SW9->W9_INLAND )
               EndIf
               SW8->W8_FRETEIN:=DI500Trans(nRateio*SW9->W9_FRETEIN)
            ElseIf lRDRatFrete .and. EasyGParam("MV_RAT_INL",, 1) == 2 //JVR - 05/11/2009 - Rateio INLAND
               nRateio:=0
               If SW7->(DBSEEK(cFilSW7+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM))
                  nRateio:=(SW8->W8_QTDE*SW7->W7_PESO)/nTotalPESO
               EndIf
               SW8->W8_INLAND  :=DI500Trans(nRateio*SW9->W9_INLAND )
            ENDIF

            IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"WHILE_ACERTO_INVOICE"),)

            SW8->(MsUnlock())

            IF lRDRatPorFOB
               aAcertos[1,1]+=SW8->W8_INLAND
               aAcertos[2,1]+=SW8->W8_PACKING
               aAcertos[3,1]+=SW8->W8_DESCONT
               aAcertos[4,1]+=SW8->W8_OUTDESP
               // EOB - 21/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
               IF lSegInc
                  aAcertos[6,1]+=SW8->W8_SEGURO
               ENDIF
               IF (SW8->W8_QTDE*SW8->W8_PRECO) > nMaiorVlr
                  nMaiorVlr:=SW8->W8_QTDE*SW8->W8_PRECO
                  nRecVlr  :=SW8->(RECNO())
               ENDIF
            ENDIF

            IF lRDRatFrete
               aAcertos[5,1]+=SW8->W8_FRETEIN
               IF SW8->W8_FRETEIN > nMaiorFre
                  nMaiorFre:=SW8->W8_FRETEIN
                  nRecFre  :=SW8->(RECNO())
               ENDIF
            ENDIF

            SW8->(DBSKIP())
         ENDDO

         IF lRateia
            IF lRDRatPorFOB
               SW8->(DBGOTO(nRecVlr))
               SW8->(RecLock("SW8",.F.))
               //FOR A := 1 TO 6 // AST - 09/03/09 - Alterado o for para percorrer somente até o tamanho do vetor, o desembaraço pode não conter informações do seguro, então o vetor tem tamanho 5
               FOR A := 1 TO len(aAcertos)
                  IF !EMPTY(aAcertos[A,1]) .AND.  aAcertos[A,2] # aAcertos[A,1]
                     IF(A=1,SW8->W8_INLAND += aAcertos[A,2] - aAcertos[A,1],)
                     IF(A=2,SW8->W8_PACKING+= aAcertos[A,2] - aAcertos[A,1],)
                     IF(A=3,SW8->W8_DESCONT+= aAcertos[A,2] - aAcertos[A,1],)
                     IF(A=4,SW8->W8_OUTDESP+= aAcertos[A,2] - aAcertos[A,1],)
                     // EOB - 21/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
                     IF lSegInc
                        IF(A=6,SW8->W8_SEGURO+= aAcertos[A,2] - aAcertos[A,1],)
                     ENDIF
                  ENDIF
               NEXT
               SW8->(MsUnlock())
            ENDIF

            IF lRDRatFrete
               IF !EMPTY(aAcertos[5,1]) .AND. aAcertos[5,2] # aAcertos[5,1]
                  SW8->(DBGOTO(nRecFre))
                  SW8->(RecLock("SW8",.F.))
                  SW8->W8_FRETEIN+=aAcertos[5,2] - aAcertos[5,1]
                  SW8->(MsUnlock())
               ENDIF
            ENDIF
         ENDIF

         IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ALTERA_SW9"),)
      ENDIF

      IF !lRateia
         SW9->W9_TUDO_OK:=NAO
      ENDIF
      SW9->(MsUnlock())
      //**integrando alteração invoice acertos na capa SW9 igor chiba 30/09/09
      IF LCAMBIO_EIC
         SW9->(DBCOMMIT())
         EW4->(DBSETORDER(2))
         cChave:=XFILIAL('SW9')+SW9->W9_HAWB+SW9->W9_INVOICE+SW9->W9_FORN
         cSQLChv:="W9_FILIAL  = '" + XFILIAL('SW9')  + "' AND " +;
                  "W9_HAWB    = '" + SW9->W9_HAWB    + "' AND " +;
                  "W9_INVOICE = '" + SW9->W9_INVOICE + "' AND " +;
                  "W9_FORN    = '" + SW9->W9_FORN    + "' "

         IF !lGravaFin_EIC //se nao tiver cambio automatico integra invoice
            IF !EW4->(DBSEEK(XFILIAL('EW4')+M->W6_HAWB+SW9->W9_INVOICE+SW9->W9_FORN))	.AND.	lEICFI06  //se Ñ tiver invoice antecipada itegrar
               If FindFunction("EICINTEI17")
                  EasyExRdm("EICINTEI17", 'A','INV',cChave,"AB",cSQLChv)//INTEGRANDO INVOICE
               EndIf
            ENDIF
         ENDIF
      ENDIF
      //**
      SW9->(DBSKIP())
   ENDDO
   
   AtuVlDI(cProcesso)

ENDIF

RETURN .T.

/*
Funcao      : DI501EIGrava()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
Function DI501EIGrava(cExecuta,cHawb,aAlias)

LOCAL cAlias,nDel,i,cWork,cFilAux,nRecTot:=0,lGrava, a
LOCAL aOrdEJ9:= {}
//NCF - 13/04/2012 - Verificar se existe acréscimo sendo gravado sem vínculo a uma das adições
LOCAL nRecWkEIN   := 0
LOCAL cMsgEIN     := ""
LOCAL lAcrDedSAdi := .F.
LOCAL aAcres      := {}
LOCAL aDeduc      := {}

Private cExec := cExecuta
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"INICIO_EIGRAVA"),)

DO CASE
CASE cExecuta == 'LEITURA'

//TDF - 01/12/11
If lEJ9 .AND. Ascan(aAlias,"EJ9") == 0
   AAdd(aAlias, "EJ9")
EndIF

   ProcRegua(Len(aAlias))
   For I:=1 To Len(aAlias)
      cWork   := "Work_"+aAlias[i]
      cAlias  := aAlias[i]
      cFilAux := xFilial(cAlias)
      IncProc(STR0097+cAlias+"...") //"Gravando Temporario do "
      AVZAP(cWork) //(cWork)->(avzap())
      IF cAlias == "EIJ"
         nFOB_TOT := 0         
      ENDIF
      DbSelectArea(cAlias) //RNLP - OSSME-6017 - Força a abertura da area a ser utilizada
      IF (cAlias)->(DBSEEK(cFilAux + cHawb))
         DO WHILE !(cAlias)->(EOF()) .AND.;
                   (cAlias)->&(cAlias+"_FILIAL") == cFilAux .AND.;
                   (cAlias)->&(cAlias+"_HAWB")   == cHawb
            (cWork)->(DBAPPEND())
            AVReplace(cAlias,cWork)
            (cWork)->WK_RECNO:=(cAlias)->(RECNO())
            // EOS 16/11 - apurar o FOB e atribuir a var. nFOB_TOT
            IF cAlias == "EIJ"
               IF Work_EIJ->EIJ_ADICAO <> "MOD"
                  nFOB_TOT += Work_EIJ->EIJ_VLMMN
               ENDIF
            ENDIF
            (cAlias)->(DBSKIP())
         ENDDO
      ENDIF
   Next

CASE cExecuta == 'GRAVACAO'
   For I:=1 To Len(aAlias)
      nRecTot += (aAlias[I])->(EasyRecCount(aAlias[I]))
   NEXT
   ProcRegua(LEN(aDeletados)+nRecTot)
   FOR nDel := 1 TO LEN(aDeletados)
       IF !EMPTY(aDeletados[nDel,2]) .AND. aDeletados[nDel,1] # "SW9"
          cAlias:=aDeletados[nDel,1]
          IncProc(STR0098+cAlias+"...") //"Excluindo Registros do "
          (cAlias)->(DBGOTO(aDeletados[nDel,2]))
          (cAlias)->(RECLOCK(cAlias,.F.))
          (cAlias)->(DBDELETE())
          (cAlias)->(MSUNLOCK())
       ENDIF
   NEXT

   IF !lDISimples .AND. !lTemAdicao .AND. lExisteSEQ_ADI//AWR - 18/09/08 NFE
      Work_SW8->(DBSETORDER(7))
   ELSE
      Work_SW8->(DBSETORDER(4))
   ENDIF

   For I:=1 To Len(aAlias)
      cAlias:= aAlias[I]
      lGrava:='lGrava'+cAlias
      lGrava:=&(lGrava)
      IF !lGrava
         LOOP
      ENDIF
      IF cAlias == "EIM" .AND. DI500EIMGrava()//AWR - NVE - 18/10/2004
         LOOP
      ENDIF
      cWork   := "Work_"+cAlias
      bGrvHAWB:= FIELDWBLOCK(cAlias+"_HAWB",SELECT(cAlias))
      nPos    := (cWork)->(FIELDPOS(cAlias+"_ADICAO"))
      (cWork)->(DBGOTOP())
      IF(lTemAdicao,Work_EIJ->(DBSETORDER(1)),)
      DO WHILE (cWork)->(!EOF())
         IncProc(STR0099+cAlias+"...") //"Gravando registros do "
         IF cAlias = 'EIJ'
            IF !Work_SW8->(DBSEEK(Work_EIJ->EIJ_ADICAO)) .AND. Work_EIJ->EIJ_ADICAO <> "MOD"
               IF !EMPTY(Work_EIJ->WK_RECNO)
                  EIJ->(DBGOTO(Work_EIJ->WK_RECNO))
                  EIJ->(RECLOCK("EIJ",.F.))
                  EIJ->(DBDELETE())
                  EIJ->(MSUNLOCK())
               ENDIF
               Work_EIJ->(DBSKIP())
               LOOP
            ENDIF
         ENDIF
         IF EMPTY((cWork)->WK_RECNO)
            //TDF - 01/12/2011
            If lEJ9
               EJ9->(DbSetOrder(1))
               If cWork == "Work_EJ9" .AND. EJ9->(DBSEEK(xFilial("EJ9")+Work_EJ9->EJ9_HAWB + Work_EJ9->EJ9_ADICAO + Work_EJ9->EJ9_DEMERC))
                  (cWork)->(DBSKIP())
                  Loop
               EndIf
            Endif
            (cAlias)->(RECLOCK(cAlias,.T.))
         ELSE
            (cAlias)->(DBGOTO((cWork)->WK_RECNO))
            (cAlias)->(RECLOCK(cAlias,.F.))
            IF nPos # 0 .AND. cAlias # 'EIJ'//.AND. lTemAdicao
               cAdicao:=(cWork)->(FIELDGET(nPos))
               If !Empty(cAdicao)
                  IF !Work_EIJ->(DBSEEK(AVKEY(cAdicao,"EIJ_ADICAO")))
                     (cAlias)->(DBDELETE())
                     (cAlias)->(MSUNLOCK())
                     (cWork)->(DBSKIP())
                     LOOP
                  EndIf
               ENDIF
            ENDIF
         ENDIF
         //TDF - 01/12/11
         If cWork == "Work_EJ9"
            If !Empty(Work_EJ9->EJ9_ADICAO)
               aOrdEJ9:= SaveOrd({"EJ9"})
               EJ9->(DbSetOrder(1))
               If EJ9->(DBSEEK(xFilial("EJ9")+Work_EJ9->EJ9_HAWB + Work_EJ9->EJ9_ADICAO + Work_EJ9->EJ9_DEMERC))
                  If (cAlias)->( isLocked() )
                     (cAlias)->(MSUNLOCK())
                  EndIf
                  (cWork)->(DBSKIP())
                  Loop
               EndIf
               RestOrd(aOrdEJ9,.T.)
            EndIf
         EndIf

         //NCF - 13/04/2012 - Verificar se existe acréscimo sendo gravado sem vínculo a uma das adições.
         If cWork ==  "Work_EIN"

            nRecWkEIN   := 0
            cMsgEIN     := ""
            lAcrDedSAdi := .F.
            aAcres      := {}
            aDeduc      := {}

            nRecWkEIN := Work_EIN->(Recno())
            cMsgEIN   := ""
            Work_EIN->(DbGoTop())
            Do While Work_EIN->(!Eof())
               If Empty(Work_EIN->EIN_ADICAO)
                  lAcrDedSAdi := .T.
                  If Work_EIN->EIN_TIPO == "1"
                     aAdd(aAcres, {Work_EIN->EIN_CODIGO,Work_EIN->EIN_FOBMOE,Work_EIN->EIN_VLMLE} )
                  Else
                     aAdd(aDeduc, {Work_EIN->EIN_CODIGO,Work_EIN->EIN_FOBMOE,Work_EIN->EIN_VLMLE} )
                  EndIf
               EndIf
               Work_EIN->(DbSkip())
            EndDo
            If lAcrDedSAdi
               If Len(aAcres) > 0
                  cMsgEIN += "Os Acréscimos: "+CHR(13)+CHR(10)
                  For i := 1 To Len(aAcres)
                     cMsgEIN += "Código: "+aAcres[i][1]+" |Moeda : "+aAcres[i][2]+" |Valor :"+STR( aAcres[i][3],AvSX3("EIN_VLMLE",3),AvSX3("EIN_VLMLE",4) )+CHR(13)+CHR(10)
                  Next i
               EndIf
               If Len (aDeduc) > 0
                  cMsgEIN += CHR(13)+CHR(10)
                  cMsgEIN += "e as Deduções: "+CHR(13)+CHR(10)
                  For i := 1 To Len(aDeduc)
                     cMsgEIN += "Código: "+aDeduc[i][1]+" |Moeda : "+aDeduc[i][2]+" |Valor :"+STR( aDeduc[i][3],AvSX3("EIN_VLMLE",3),AvSX3("EIN_VLMLE",4) )+CHR(13)+CHR(10)
                  Next i
               Endif
               // Não será necessária digitar as STR desta mensagem no arquivo .CH devido a este trecho ser somente para verificação
               cMsgEIN += CHR(13)+CHR(10)
               cMsgEIN += "Não estão vinculados a nenhuma das adições do processo"+CHR(13)+CHR(10)
               cMsgEIN += "Por Favor, acione o suporte!"+CHR(13)+CHR(10)

               MsgAlert(cMsgEIN, STR0001)
            EndIf
            Work_EIN->(DbGoTo(nRecWkEIN))
         EndIf

         AVReplace(cWork,cAlias)//Esta funcao ja grava filial
         EVAL(bGrvHAWB,M->W6_HAWB)
         (cAlias)->(MSUNLOCK())
         (cWork)->(DBSKIP())
      ENDDO
   Next

CASE cExecuta == 'ESTORNO'
   aAlias:=ACLONE(aAliasAdic)
   FOR A := 1 TO LEN(aAliasCapa)
       AADD(aAlias,aAliasCapa[A])
   NEXT
   ProcRegua(Len(aAlias))
   For i:=1 To Len(aAlias)
      cAlias  := aAlias[i]
      cFilAux := xFilial(cAlias)
      IncProc(STR0098+cAlias+"...") //"Excluindo Registros do "
      // MFR 14/12/2018 OSSME-1483
      IF cAlias == "EIM"
        IF (cAlias)->(DBSEEK(cFilAux+cHawb))
           DO WHILE (cAlias)->&(cAlias+"_FILIAL") == cFilAux .AND. !(cAlias)->(EOF()) .AND.;
                  (cAlias)->&(cAlias+"_HAWB")   == cHawb  
                  IF (cAlias)->&(cAlias+"_FASE") == "DI"
                    (cAlias)->(RECLOCK(cAlias,.F.))
                    (cAlias)->(DBDELETE())
                    (cAlias)->(MSUNLOCK())                    
                  ENDIF  
                  (cAlias)->(DBSKIP())
           ENDDO
        ENDIF
      ELSE
        IF (cAlias)->(DBSEEK(cFilAux+cHawb))
           DO WHILE (cAlias)->&(cAlias+"_FILIAL") == cFilAux .AND. !(cAlias)->(EOF()) .AND.;
                   (cAlias)->&(cAlias+"_HAWB")   == cHawb 
              (cAlias)->(RECLOCK(cAlias,.F.))
              (cAlias)->(DBDELETE())
              (cAlias)->(MSUNLOCK())
              (cAlias)->(DBSKIP())
           ENDDO
        ENDIF
      ENDIF
   Next

ENDCASE

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GRAVA_EI"),)

RETURN .T.

/*
Funcao      : DI501aEMB()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
Function DI501aEMB()//Antiga EICDI400aEMB

LOCAL I
Local nPosic := 0 //BHF 14/05/09
Local cAlias := "SW6"
Local aOrd:= {}
PRIVATE aTiraCampos:={}

IF MOpcao == FECHTO_EMBARQUE
  aEmbarques:={ "W6_HAWB"    , "W6_HOUSE"   , "W6_DT_HAWB" , "W6_DT_EMB"  ,;
                 "W6_MAWB"    , "W6_DT_ETD"  , "W6_IDENTVE" , "W6_PAISVEI" ,;
                 "W6_PAISNOM" , "W6_AGENTE"  , "W6_AGENTEN" , "W6_VIA_TRA" ,;
                 "W6_DESCVIA" , "W6_DESP"    , "W6_DESPNOM" , "W6_DT_ETA"  ,;
                 "W6_REF_DES" , "W6_ORIGEM"  , "W6_DEST"    , "W6_LOCAL"   ,;
                 "W6_FAT_DES" , "W6_CONEVE1" , "W6_CONEET1" , "W6_CONEPO1" ,;
                 "W6_CONEVE2" , "W6_CONEET2" , "W6_CONEPO2" , "W6_PAISPRO" ,;
                 "W6_PRE_CARGA","W6_VIAGEM"  , "W6_UFDESEM" , "W6_VM_OBS"  ,;
                 "W6_PRVENTR" , "W6_TRANSIN" , "W6_PESO_BR" , "W6_MT3"     ,;
                 "W6_VOLUME"  , "W6_OUT_CTN" , "W6_OUTROS"  , "W6_PESO_TX" ,;
                 "W6_CONTA20" , "W6_PESOTOT" , "W6_CONTA40" , "W6_TIPODES" ,;
                 "W6_URF_DES" , "W6_URF_ENT" , "W6_REC_ALF" , "W6_MODAL_D" ,;
                 "W6_TIPOCON" , "W6_TIPODOC" , "W6_UTILCON" , "W6_IDEMANI" ,;
                 "W6_VM_COMP" , "W6_IDENTCT" , "W6_FREMOED" , "W6_FOB_GER" ,;
                 "W6_CON40HC" , "W6_SETORRA" , "W6_TX_FRET" , "W6_VM_TDES" ,;
                 "W6_VM_UENT" , "W6_VM_UDES" , "W6_VM_RECA" , "W6_VLFRECC" ,;
                 "W6_VLFREPP" , "W6_VLFRETN" , "W6_SEGMOED" , "W6_VL_USSE" ,;
                 "W6_VLSEGMN" , "W6_TX_SEG"  , "W6_PO_NUM"  , "W6_VM_TCON" ,;
                 "W6_LOCALN"  , "W6_MSG_COM" , "W6_ARMAZEM" , "W6_IMPORT"  ,;
                 "W6_IMPORVM" , "W6_NOMEVE"  , "W6_TAB_PC"  , "W6_FFREINT" ,; 
                 "W6_FFRELOJ"  }

                 if AvFlags("DUIMP")
                    aAdd(aEmbarques,"W6_TIPOREG")
                 EndIf   

   //** GFC - 21/11/05 - Câmbio de frete, seguro, comissão e embarque
   If lWB_TP_CON
      aAdd(aEmbarques,"W6_FORNECF")
      aAdd(aEmbarques,"W6_LOJAF")
      aAdd(aEmbarques,"W6_CONDP_F")
      aAdd(aEmbarques,"W6_DIASP_F")
      aAdd(aEmbarques,"W6_VENCFRE")
      aAdd(aEmbarques,"W6_FORNECS")
      aAdd(aEmbarques,"W6_LOJAS")
      aAdd(aEmbarques,"W6_CONDP_S")
      aAdd(aEmbarques,"W6_DIASP_S")
      aAdd(aEmbarques,"W6_VENCSEG")
      aAdd(aEmbarques,"W6_CORRETO") //NCF - 16/02/2011 - Inclusão do campo no embarque para permitir geração de
   EndIf                            //                   título automatico de seguro nesta fase
   IF AvFlags("EIC_EAI")
      aAdd(aEmbarques,"W6_CALCAUT")
      aAdd(aEmbarques,"W6_PRVDESE")
      aAdd(aEmbarques,"W6_PRVENTR")
      //aAdd(aEmbarques,"W6_DT_ENTR") //wfs - retirado pois refere-se à data efetiva de recebimento; existem validações que impedem o preenchimento do campo
   ENDIF
   If AVFLAGS("INV_ANT_GERA_CAMB_FIN") // NCF - 26/11/2015
      aAdd(aEmbarques,"W6_TITINAN")
   EndIf
ElseIf MOpcao == FECHTO_NACIONALIZACAO .AND. EasyGParam("MV_MOST_DA")
   aEmbarques:={ "W6_HAWB"    , "W6_DT_HAWB" , "W6_DESP"    , "W6_DESPNOM" ,;
                 "W6_REF_DES" , "W6_LOCAL"   , "W6_LOCALN"  , "W6_FAT_DES" ,;
                 "W6_DTRECDO" , "W6_LOTE"    , "W6_PRVDESE" , "W6_DT"      ,;
                 "W6_DI_NUM"  , "W6_DTREG_D" , "W6_TX_US_D" , "W6_VLSEGMN" ,;
                 "W6_FOB_TOT" , "W6_INLAND"  , "W6_PACKING" , "W6_DESCONT" ,;
                 "W6_FOB_GER" , "W6_FREMOED" , "W6_VLFRECC" , "W6_VLFREPP" ,;
                 "W6_TX_FRET" , "W6_SEGMOED" , "W6_VL_USSE" , "W6_DT_DESE" ,;
                 "W6_DESCRPG" , "W6_NF_ENT"  , "W6_MSG_COM" , "W6_VLFRETN" ,;
                 "W6_SE_NF"   , "W6_DT_NF"   , "W6_VL_NF"   , "W6_PROG_DI" ,;
                 "W6_DT_ENTR" , "W6_NF_COMP" , "W6_SE_NFC"  , "W6_DT_NFC"  ,;
                 "W6_VL_NFC"  , "W6_PESO_BR" , "W6_MT3"     , "W6_VOLUME"  ,;
                 "W6_PESO_TX" , "W6_PESOTOT" , "W6_DT_AVE"  , "W6_VM_OBS"  ,;
                 "W6_NR_PRO"  , "W6_DT_DOC"  , "W6_TIPODES" , "W6_VM_TDES" ,;
                 "W6_REC_ALF" , "W6_VM_RECA" , "W6_MODAL_D" , "W6_URF_DES" ,;
                 "W6_VM_UDES" , "W6_URF_ENT" , "W6_VM_UENT" , "W6_VM_COMP" ,;
                 "W6_DT_ENCE" , "W6_UTILCON" , "W6_TIPODOC" , "W6_FREPPCC" ,;
                 "W6_ID_MANI" , "W6_TIPOCON" , "W6_VM_TCON" , "W6_TX_SEG" }

ElseIf MOpcao == FECHTO_DESEMBARACO //MCF - 11/04/2016

aOrd := SaveOrd("SX3",1)
SX3->(dbSeek(cAlias))
aEmbarques := {}

   While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias
      If SX3->X3_PROPRI=="U" .Or. X3Uso(SX3->X3_USADO)
         AADD(aEmbarques,SX3->X3_CAMPO)
      Endif
      SX3->(dbSkip())
   EndDo
   RestOrd(aOrd)
EndIf

// da Array aTiraCampos no rdmake chamado 053916 - RS 02/07/07

//JAP - 12/09/06 - Se o parâmetro MV_TEM_DI estiver desligado, os campos do array aTiraCampos serão retirados da enchoice.
IF !lTemAdicao                                                 
	aTiraCampos:={ "W6_ADICAOK","W6_DEBITOS","W6_DEBITVM","W6_PROCVVM",;
                  "W6_QTD_ADI","W6_SEGBASE","W6_SEGPERC"/*,"W6_VOLUMES","W6_VOLUMVM"*/,; //ER - 04/12/2006 - O campo W6_VOLUMES sempre estará visível.
                  "W6_INSTRDE","W6_INSTRVM"}
	IF EasyGParam("MV_EIC_PCO",,.F.)
		IF MOpcao == FECHTO_EMBARQUE
			AADD(aEmbarques,"W6_IMPCO")
			AADD(aEmbarques,"W6_IMPENC")
		ENDIF
		IF !(EasyGParam("MV_PCOIMPO",,.T.) .AND. EasyGParam("MV_EASY",,"N") = "S")
			AADD(aTiraCampos,"W6_PEDFAT")
		ENDIF
	ENDIF
   AADD(aTiraCampos,"W6_DT_DSE" )
   AADD(aTiraCampos,"W6_UL_DSE" )
   AADD(aTiraCampos,"W6_NR_DSE" )
   AADD(aTiraCampos,"W6_NR_DDE" )
   AADD(aTiraCampos,"W6_NR_PROC")
   AADD(aTiraCampos,"W6_BCOPGTO")
   AADD(aTiraCampos,"W6_AGEPGTO")
   AADD(aTiraCampos,"W6_CTAPGTO")
   AADD(aTiraCampos,"W6_FUNDAP")
   AADD(aTiraCampos,"W6_QBRPICO")

   If !lFinanceiro //JVR - 27/05/09 - mostrar o folder financiamento, com os campos a seguir caso MV_EASYFIN, MV_EASY esteja ligados.
      aAdd(aTiraCampos,"W6_PREFIXF")
      aAdd(aTiraCampos,"W6_PREFIXS")
      aAdd(aTiraCampos,"W6_NUMDUPF")
      aAdd(aTiraCampos,"W6_NUMDUPS")
      aAdd(aTiraCampos,"W6_PARCELF")
      aAdd(aTiraCampos,"W6_PARCELS")
      aAdd(aTiraCampos,"W6_TIPOF"  )
      aAdd(aTiraCampos,"W6_TIPOS"  )
   EndIf

   //EOB - 10/03/08 - Campos referente ao Mercosul
   IF SW6->(FIELDPOS("W6_DEMERCO")) # 0
      aAdd(aTiraCampos,"W6_DEMERCO")
   ENDIF
   IF SW6->(FIELDPOS("W6_REINIC")) # 0
      aAdd(aTiraCampos,"W6_REINIC")
   ENDIF
   IF SW6->(FIELDPOS("W6_REFINAL")) # 0
       aAdd(aTiraCampos,"W6_REFINAL")
   ENDIF

ENDIF
//THTS - 14/08/19 - Se Cambio Frete Ligado, nao exibir campo de Vencimento. Caso contrario (desligado) nao exibir os campos de Condicao de Pagamento
If AvFlags("GERACAO_CAMBIO_FRETE")
	aAdd(aTiraCampos,"W6_VENCFRE")
Else
	aAdd(aTiraCampos,"W6_CONDP_F")
	aAdd(aTiraCampos,"W6_DIASP_F")
EndIf
//THTS - 14/08/19 - Se Cambio Seguro Ligado, nao exibir campo de Vencimento. Caso contrario (desligado) nao exibir os campos de Condicao de Pagamento
If AvFlags("GERACAO_CAMBIO_SEGURO")
	aAdd(aTiraCampos,"W6_VENCSEG")
Else
	aAdd(aTiraCampos,"W6_CONDP_S")
	aAdd(aTiraCampos,"W6_DIASP_S")
EndIf

IF aEmbarques = NIL
	aEmbarques:={}
	SX3->(DBSETORDER(1))
	SX3->(DbSeek("SW6"))
	DO WHILE SX3->(!EOF()) .AND. SX3->X3_ARQUIVO == "SW6"
			IF X3USO(SX3->X3_USADO) .AND. ASCAN(aTiraCampos,{|X|X==ALLTRIM(SX3->X3_CAMPO)}) = 0
				AADD(aEmbarques,ALLTRIM(SX3->X3_CAMPO))
			ENDIF
			SX3->(DBSKIP())
	ENDDO
ELSE
	aAuxEmb:=ACLONE(aEmbarques)
	aEmbarques:={}
	For I := 1 TO LEN(aAuxEmb)
			IF ASCAN(aTiraCampos,aAuxEmb[I]) = 0
				AADD(aEmbarques,aAuxEmb[I])
			ENDIF
	NEXT
ENDIF

//BHF - 14/05/09 : Se MV_TEM_DSI desligado, não exibe campo
If !EasyGParam("MV_TEM_DSI",.F.)
   If (nPosic := aScan(aEmbarques,{|x| x = "W6_DSI"})) > 0
      aDel(aEmbarques,nPosic)
      aSize(aEmbarques,Len(aEmbarques)-1)
   EndIf
EndIf

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ALTERA_AEMBARQUE"),)   // Robson Sanches - 02/07/07 chamado 053916
Return .T.


//Empresa...: AVERAGE TECNOLOGIA
//Funcao....: DI500EnvSis()
//Autor.....: Osman Mediros Jr.(OMJ)
//Data......: 21 de Setembro de 2001, 15:00
//Sintaxe...:
//Uso.......: SIGAEIC
//Versao....: Protheus - 6.09
//Descricao.: Geracao do Txt da D.I. Eletronica e Historico de Envio
//Observação: Função migrada do programa EICDI500
*--------------------------------*
Function DI501EnvSis()
*--------------------------------*
Local oDlg,	cTit:=STR0100 //STR0100 "Envio de D.I. ao Siscomex"
Local aTipoEnv := {STR0101,STR0102} //STR0101 "1 - Analise",STR0102 "2 - Registro"

// BAK - Tratamento para enchoicebar - 18/08/2011
//Local aOk      := {{|| IF( DI500ValGerTXT() ,(nOpca:=1,oDlg:End()) ,) },"OK"}
Local bOk      := {|| IF( DI500ValGerTXT() ,(nOpca:=1,oDlg:End()) ,) }
Local bCancel  := {|| nOpca:=0,oDlg:End()}
Private aButtons := {}  //TRP - 17/11/2011 - Variável utilizada em rdmake.
PRIVATE cMaquina := SPACE(5) ,lEMail:=.F.
PRIVATE cArqTrabC,cArqTrabI,cArqTrabV,cArqTrabT,cArqTrabP//DSI
PRIVATE aTBCamposC:={},aTBCamposI:={},aTBCamposV:={},aTBCamposT:={},aTBCamposP:={}//DSI
PRIVATE cPathDest:= "\SIGAADV\"
PRIVATE lDISimples:=.F.
PRIVATE cTipoEnv := aTipoEnv[1]

EasyHelp(STR0271) // A integração do Siscomex via arquivo de texto (.txt) foi descontinuada. Recomendamos que a integração seja feita via Siscomex Web acessando Integ Siscomex Web (EICDI100).

IF lTemDSI
   lDISimples := (SW6->W6_DSI=="1")
ENDIF

IF lTemDI .AND. !lDiSimples   // LDR - 20/09/04
   IF SW6->W6_TEM_DI = "2"
      MSGINFO(STR0103,STR0001) //STR0103 "Processo nao possui DI Eletronica !" //STR0001 := "Atenção"
      RETURN .T.
   ENDIF
ENDIF

IF lDISimples
   cTit:=STR0100 //STR0100 "Envio de D.I. ao Siscomex"
ELSE
   Aadd(aButtons,{"HISTORIC",{|| nOpca:=3,oDlg:End() },STR0104, STR0104})   // GFC  -  "Conf D.I."//STR0104 "Conferencia de D.I."
ENDIF
Aadd(aButtons,{"NOTE"    ,{|| nOpca:=2,oDlg:End() },STR0105, STR0105})   //  "Histórico de Envio"

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ADICBUTTON"),)  //TRP - 17/11/2011 - Criação de Ponto de Entrada para Inclusão de botões Customizados na Enchoicebar.

Do While .T.
   nOpca := 0
   nLin  := 2.5
   nColS := 1.2
   nColG := 8

   Define MsDialog oDlg Title cTit From 9,0 TO 22,48 Of oMainWnd

		@ nLin++,nColS Say AVSX3("W6_HAWB",5)
		@ nLin++,nColS Say STR0106 //"Máquina"
        nLin:=2.5
        @ nLin++,nColG MsGet SW6->W6_HAWB Picture AvSx3("W6_HAWB",6) Size 60,08 Of oDlg WHEN .F.
        @ nLin++,nColG MSGET cMaquina F3 "Y5" PICTURE "@!" SIZE 25,07 OF oDlg

        IF !lDISimples
           @ nLin  ,nColS Say STR0107 //"Tipo de Envio"
           @ nLin  ,nColG ComboBox cTipoEnv Items aTipoEnv Size 74,50 Of oDlg
        ENDIF
// BAK - Tratamento para Enchoicebar - 18/08/2011
//   Activate MsDialog oDlg On Init DI500EnchoiceBar(oDlg,aOk,bCancel,,aButtons) Centered
   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel,,aButtons) Centered
   If nOpca = 0
      Exit
   ElseIf nOpca = 1
      IF lDISimples
         Processa({|| DI500GrvDSI() }, STR0108)//"Lendo Informações..."
      ELSE
         Processa({|| DI500GeraTxt( Left(cTipoEnv,1) )}, STR0108)  //"Lendo Informações..."
      ENDIF
   ElseIf nOpca = 2
      DI500HistDI( SW6->W6_HAWB )
   ElseIf nOpca = 3
      DI500DIConf()//GFC
   EndIf

EndDo

IF lDISimples
   DI500DelTRB()
ENDIF

Return Nil

/*
Funcao      : DI501ValGerTXT()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
Function DI501ValGerTXT(lNovaInt,lBlind)

LOCAL oDLGDescr,cTipo:='DI', E
LOCAL cFilSA2:=xFilial("SA2")
LOCAL cFilEIJ:=xFilial("EIJ")
LOCAL cFilEII:=xFilial("EII")
Local i
Default lNovaInt := .F.      // GFP - 27/02/2015
Default lBlind := .F.        // GFP - 27/02/2015

If lNovaInt      // GFP - 27/02/2015
   PRIVATE cMoeDolar:= BuscaDolar()
   lCposNFDesp := SWD->(FIELDPOS("WD_B1_COD")) # 0 .And. SWD->(FIELDPOS("WD_DOC")) # 0 .And. SWD->(FIELDPOS("WD_SERIE")) # 0;
                  .And. SWD->(FIELDPOS("WD_ESPECIE")) # 0 .And. SWD->(FIELDPOS("WD_EMISSAO")) # 0 .AND. SWD->(FIELDPOS("WD_B1_QTDE")) # 0;
                  .And. SWD->(FIELDPOS("WD_TIPONFD")) # 0
   lDISimples := (SW6->W6_DSI=="1")
EndIf

SF1->(DBSETORDER(5))
//ISS - 13/12/10 - Verificação se o HAWB corrente possui alguma nota gerada, e não apenas notas de despesas (NFD)
IF SF1->(DBSEEK(xFilial()+SW6->W6_HAWB)) .AND. If(lCposNFDesp,ExistHAWBNFE(SW6->W6_HAWB),.T.) //wfs
   Help("",1,"AVG0000733")//MSGSTOP("Processo ja possui Nota Fiscal.",STR0001)
   SF1->(DBSETORDER(1))
   RETURN .F.
ENDIF
SF1->(DBSETORDER(1))

IF !lNovaInt .AND. !SX5->(DBSEEK(xFilial()+'Y5'+ALLTRIM(cMaquina)))      // GFP - 27/02/2015
   Help(" ",1,"EICMAQ")
   RETURN .F.
ENDIF
lEMail:=.F.
IF lDISimples
   cTipo:='MDB'
ENDIF
IF !lNovaInt .AND. ALLTRIM(cMaquina) # "EMAIL"      // GFP - 27/02/2015
   IF !SX5->(DBSEEK(xFilial("SX5")+"CE"+ALLTRIM(cMaquina)+cTipo)) .OR. EMPTY(SX5->X5_DESCRI)
   Help("", 1, "AVG0005354",,cTipo+STR0109,5,8)   //LRL 08/01/04 MSGSTOP("Maquina nao Cadastrada para a Tabela 'CE', Tipo "+cTipo+" ou caminho nao preenchido") //STR0109 " ou caminho nao preenchido"
      RETURN .F.
   ENDIF
   cPathDest:=ALLTRIM(SX5->X5_DESCRI)
ELSE
   lEMail:=.T.
   cPathDest:=Upper(GetSrvProfString("STARTPATH",""))
ENDIF
PRIVATE cErro:='',Enter:=CHR(13)+CHR(10),lOK:=.T.
PRIVATE aCamposErro:={}
IF !lDISimples
   If SW6->W6_MODAL_D <> "6" .And. SW6->W6_MODAL_D <> "2"// SVG 10-11-08 Atualizado em 04/08/2010 Inclusa verificação da Modalidade 2, onde 6 Despacho Antecipado com Entrega Fracionada , 2 Despacho Antecipado.
      AADD(aCamposErro,{ {|| EMPTY(SW6->W6_CHEG)   }, AVSX3("W6_CHEG"   ,5)+STR0110+Enter })//" do processo nao preenchida."
   EndIf
   AADD(aCamposErro,{ {|| EMPTY(SW6->W6_MODAL_D)}, AVSX3("W6_MODAL_D",5)+STR0111+Enter })//" do processo nao preenchido."
   AADD(aCamposErro,{ {|| EMPTY(SW6->W6_URF_ENT)}, AVSX3("W6_URF_ENT",5)+STR0111+Enter }) //STR0111 " do processo nao preenchido."
   AADD(aCamposErro,{ {|| EMPTY(SW6->W6_TIPODOC)}, AVSX3("W6_TIPODOC",5)+STR0111+Enter })//STR0111 " do processo nao preenchido."
ENDIF
AADD(aCamposErro,{ {|| EMPTY(SW6->W6_TIPODES)}, AVSX3("W6_TIPODES",5)+STR0111+Enter })//STR0111 " do processo nao preenchido."
AADD(aCamposErro,{ {|| EMPTY(SW6->W6_PAISPRO)}, AVSX3("W6_PAISPRO",5)+STR0111+Enter })//" do processo nao preenchido."
AADD(aCamposErro,{ {|| EMPTY(SW6->W6_URF_DES)}, AVSX3("W6_URF_DES",5)+STR0111+Enter })//STR0111 " do processo nao preenchido."
//AADD(aCamposErro,{ {|| EMPTY(SW6->W6_BCOPGTO)}, AVSX3("W6_BCOPGTO",5)+" do processo nao preenchido."+Enter })
//AADD(aCamposErro,{ {|| EMPTY(SW6->W6_AGEPGTO)}, AVSX3("W6_AGEPGTO",5)+" do processo nao preenchida."+Enter })
//AADD(aCamposErro,{ {|| EMPTY(SW6->W6_CTAPGTO)}, AVSX3("W6_CTAPGTO",5)+" do processo nao preenchida."+Enter })
AADD(aCamposErro,{ {|| EMPTY(SW6->W6_TIPOCON)}, AVSX3("W6_TIPOCON",5)+STR0111+Enter })//STR0111 " do processo nao preenchido."
AADD(aCamposErro,{ {|| EMPTY(SW6->W6_REC_ALF)}, AVSX3("W6_REC_ALF",5)+STR0111+Enter })//STR0111 " do processo nao preenchido."

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"VALID_SW6_ENVIO_SISC"),)

IF !SW6->W6_ADICAOK $ cSim
   IF lDISimples
      cErro+=STR0112+Enter //STR0112 "Os Calculos da DSI do Processo nao estao Corretos, Recalcule a DSI."
   ELSE
      cErro+=STR0113+Enter //STR0113 "As adições do processo não estão corretas. Recalcule as adições."
   ENDIF
ENDIF

Processa({|| lOK:=DI500Taxa(.F.)}, STR0114) //"Verificando integridade das taxas..."

IF !lOK
   IF lDISimples
      cErro+=STR0115+Enter //STR0115 "As Taxas foram atualizadas. Recalcule a DSI."
   ELSE
      cErro+=STR0116+Enter //STR0116 "As Taxas foram atualizadas. Recalcule as Adições."
   ENDIF
ENDIF

SYT->(dbSeTORDER(1))
IF !SYT->(dbSeek(xFilial('SYT')+SW6->W6_IMPORT))
   cErro += StrTran(STR0117, "####", AllTrim(SW6->W6_IMPORT)) + Enter //"Importador "###" não cadastrado."
ELSEIF EMPTY(SYT->YT_TIPO)
   cErro += StrTran(STR0118, "####", AllTrim(SW6->W6_IMPORT)) + Enter //"Tipo do Importador "###" não preenchido."
ENDIF

EIH->(dbSetOrder(1))
IF !EIH->(dbSeek(xFilial()+SW6->W6_HAWB)) .AND. !lDISimples
   cErro+=STR0119+Enter //"Não existem embalagens cadastradas para esse processo."
ENDIF

SYQ->(dbSetOrder(1))
IF !SYQ->(dbSeek(xFilial()+SW6->W6_VIA_TRA))
   cErro += StrTran(STR0120, "####", AllTrim(SW6->W6_VIA_TRA)) + Enter //"Via de transporte #### não cadastrada."
ENDIF

cTipoVia:=LEFT(SYQ->YQ_COD_DI,1)
IF lDISimples//AWR - 25/06/2003
   IF cTipoVia $ '1,2,3'  .AND. !(SW6->W6_TIPOCON $ '10,12,99')
      cErro += StrTran(StrTran(STR0121, "####", AllTrim(SYQ->YQ_COD_DI)), "$$$$", AVSX3("W6_TIPOCON", 5)) //"A via de transporte #### só aceita $$$$ igual a 10, 12 e 99."
   ELSEIF cTipoVia = '4'  .AND. !(SW6->W6_TIPOCON $ '01,03,08,14')
      cErro += StrTran(StrTran(STR0122, "####", AllTrim(SYQ->YQ_COD_DI)), "$$$$", AVSX3("W6_TIPOCON", 5)) //"A via de transporte #### só aceita $$$$ igual a 01, 03, 08 e 14."
   ELSEIF cTipoVia = '5'  .AND. !(SW6->W6_TIPOCON = '09')
      cErro += StrTran(StrTran(STR0123, "####", AllTrim(SYQ->YQ_COD_DI)), "$$$$", AVSX3("W6_TIPOCON", 5)) //"A via de transporte #### só aceita $$$$ igual a 09."
   ELSEIF cTipoVia = '6'  .AND. !(SW6->W6_TIPOCON $ '17,18,19,99')
      cErro += StrTran(StrTran(STR0124, "####", AllTrim(SYQ->YQ_COD_DI)), "$$$$", AVSX3("W6_TIPOCON", 5)) //"A via de transporte #### só aceita $$$$ igual a 17, 18, 19 e 99."
   ELSEIF cTipoVia = '7'  .AND. !(SW6->W6_TIPOCON $ '13,99')
      cErro += StrTran(StrTran(STR0125, "####", AllTrim(SYQ->YQ_COD_DI)), "$$$$", AVSX3("W6_TIPOCON", 5)) //"A via de transporte #### só aceita $$$$ igual a 13 e 99."
   ELSEIF cTipoVia = '8,A'.AND. !(SW6->W6_TIPOCON = '00')
      cErro += StrTran(StrTran(STR0126, "####", AllTrim(SYQ->YQ_COD_DI)), "$$$$", AVSX3("W6_TIPOCON", 5)) //"A via de transporte #### não tem $$$$. Coloque igual a '00'."
   ELSEIF cTipoVia = '9'  .AND. !(SW6->W6_TIPOCON = '14')
      cErro += StrTran(StrTran(STR0127, "####", AllTrim(SYQ->YQ_COD_DI)), "$$$$", AVSX3("W6_TIPOCON", 5)) //"A via de transporte #### só aceita $$$$ igual a 14."
   ENDIF
ELSE
   IF !(cTipoVia $ '4,5,6,8,9') .AND. EMPTY(SW6->W6_IDENTVE)
      If SW6->W6_MODAL_D <> "6" .And. SW6->W6_MODAL_D <> "2" // SVG 10-11-08 Atualizado em 04/08/2010 Inclusa verificação da Modalidade 2, onde 6 Despacho Antecipado com Entrega Fracionada , 2 Despacho Antecipado.
         cErro+=AVSX3("W6_IDENTVE",5)+STR0111+Enter //" do processo nao preenchido."
      EndIf
   ENDIF
   IF cTipoVia # '9'
      AADD(aCamposErro,{ {|| EMPTY(SW6->W6_UTILCON)}, AVSX3("W6_UTILCON",5)+STR0110+Enter }) //STR0110 := " do processo nao preenchida."
      If SW6->W6_MODAL_D <> "6"  .And. SW6->W6_MODAL_D <> "2" // SVG 10-11-08 Atualizado em 04/08/2010 Inclusa verificação da Modalidade 2, onde 6 Despacho Antecipado com Entrega Fracionada , 2 Despacho Antecipado.
         AADD(aCamposErro,{ {|| EMPTY(SW6->W6_PRCARGA)}, AVSX3("W6_PRCARGA",5)+STR0111+Enter })//STR0111 := " do processo nao preenchido."
         AADD(aCamposErro,{ {|| EMPTY(SW6->W6_IDEMANI)}, AVSX3("W6_IDEMANI",5)+STR0110+Enter })//STR0110 := " do processo nao preenchida." //
      EndIf
   ENDIF
ENDIF
EIF->(dbSetOrder(1))
IF !EIF->(dbSeek(xFilial()+SW6->W6_HAWB)) .AND. !lDISimples
   cErro += StrTran(STR0128, "####", AVSX3("W6_INSTRDE",5)) + Enter //"Não existe #### cadastrado para esse processo."
ENDIF
IF SW6->W6_PESOL > SW6->W6_PESO_BR
   cErro += StrTran(StrTran(STR0129, "####",AVSX3("W6_PESOL",5)), "$$$$", AVSX3("W6_PESO_BR",5)) + Enter //"O #### não pode ser maior que o $$$$."
ENDIF
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"VALIDAPRCARGA"),)

FOR E := 1 TO LEN(aCamposErro)
   IF EVAL( aCamposErro[E,1] )
      cErro+=aCamposErro[E,2]
   ENDIF
NEXT
IF !lDISimples
   lBranco:=EMPTY(SW6->W6_CTAPGTO)
   EII->(dbSetOrder(1)) /* EII_FILIAL+EII_HAWB+EII_CODIGO */
   EII->(dbSeek(cFilEII+SW6->W6_HAWB))
   DO While !EII->(Eof()) .And.;
             EII->EII_FILIAL == cFilEII .And.;
             EII->EII_HAWB   == SW6->W6_HAWB
      IF lBranco .AND. EMPTY(EII->EII_DT_PAG)
         cErro+=AVSX3("W6_CTAPGTO",5)+STR0130+Enter //STR0130 " não prenchida: não pode haver data de pagamento não prenchida no campo de débitos."
         EXIT
      ELSEIF !lBranco .AND. !EMPTY(EII->EII_DT_PAG)
         cErro+=AVSX3("W6_CTAPGTO",5)+STR0131+Enter //STR0131 " preenchida: não pode haver data de pagamento prenchida no campo de débitos."
         EXIT
      ENDIF
      EII->(DBSKIP())
   ENDDO
ENDIF
lTipoDes:=SW6->W6_TIPODES $ '08,09,10,16,20'
EIJ->(dbSetOrder(1))
EIJ->(dbSeek(cFilEIJ+SW6->W6_HAWB))
Do While !EIJ->(EOF()) .AND. EIJ->EIJ_HAWB   == SW6->W6_HAWB .AND.;
                             EIJ->EIJ_FILIAL == cFilEIJ
   IF EIJ->EIJ_ADICAO == "MOD"
      EIJ->(DBSKIP())
      LOOP
   ENDIF
   cAdicao:=STR0132+EIJ->EIJ_ADICAO+": " //"Adicao "

   IF SA2->(dbSeek(cFilSA2+EIJ->EIJ_FABR+EICRetLoja("EIJ", "EIJ_FABLOJ"))) .AND. !lDISimples
      IF EMPTY(SA2->A2_PAIS)
         cErro += cAdicao + StrTran(STR0133, "####", AllTrim(EIJ->EIJ_FABR) + If(EICLOJA(), " - " + AllTrim(EIJ->EIJ_FABLOJ), "")) + Enter //"País do fabricante #### não preenchido."
      ENDIF
   ENDIF

   IF lTipoDes .AND. EMPTY(EIJ->EIJ_PAISPR) .AND. !lDISimples
      cErro+=cAdicao+STR0134+Enter //"País de procedência não preenchido."
   ENDIF

   IF EMPTY(EIJ->EIJ_APLICM) .AND. !(SW6->W6_TIPODES $ "02,03,04,05,06,07,08,09,10").AND. !lDISimples //TANIA PEDIU 17/07/2002
      cErro+=cAdicao+STR0135+Enter //"Aplicação da mercadoria não preenchida."
   ENDIF

   IF EMPTY(EIJ->EIJ_LOCVEN) .AND. !lDISimples
      cErro+=cAdicao+STR0136+Enter //"Local da condição de venda não preenchido."
   ENDIF

   IF SW6->W6_TIPODES <> '19' .AND. EMPTY(EIJ->EIJ_TPAII) .AND. !lDISimples
      cErro+=cAdicao+STR0137+Enter //"Tipo da alíquota do I.I. não preenchido."
   ENDIF

   IF EMPTY(EIJ->EIJ_TPAIPI) .AND. !EIJ->EIJ_REGTRI $ '2,6' .AND. !lDISimples//AWR - 06/2009 - Chamado P10
      cErro+=cAdicao+STR0138+Enter //"Tipo da alíquota do I.P.I. não preenchido."
   ENDIF

   IF EMPTY(EIJ->EIJ_QT_EST) .AND. !lDISimples
      cErro+=cAdicao+STR0139+Enter //STR0334 //STR0139 "Quantidade Estatística não preenchida."
//    cErro+=cAdicao+STR0335+Enter //"Informe as Unidades na Tabela de Conversao."
   ENDIF

   IF EMPTY(EIJ->EIJ_VINCCO) .AND. !lDISimples
      cErro+=cAdicao+STR0140+Enter //"Vinculação Comprador x Vendendor não preenchida."
   ENDIF

//   IF !EMPTY(EIJ->EIJ_MOTADI) .AND. !EMPTY(EIJ->EIJ_APLICM) .AND. !(SW6->W6_TIPODES $ "02,04") .AND. !lDISimples //TANIA PEDIU 17/07/2002
//      cErro+=cAdicao+"Preencher "+AVSX3("EIJ_MOTADI",5)+" OU "+AVSX3("EIJ_APLICM",5)+"."+Enter
//   ENDIF

   IF EMPTY(EIJ->EIJ_METVAL) .AND. !lDISimples
      cErro+=cAdicao+AVSX3("EIJ_METVAL",5)+STR0141+Enter //STR0141 " não preenchido."
   ENDIF

   IF LEFT(EIJ->EIJ_TIPCOB,1) $ "1,2"  .AND. !lDISimples
      IF EMPTY(EIJ->EIJ_MODALI)
         cErro+=cAdicao+AVSX3("EIJ_MODALI",5)+STR0141+Enter//STR0141 " não preenchido."
      ENDIF
      IF !EMPTY(EIJ->EIJ_INSTFI) .OR. !EMPTY(EIJ->EIJ_MOTIVO)
         cErro += cAdicao + StrTran(StrTran(STR0142, "####", AVSX3("EIJ_INSTFI",5)), "$$$$", AVSX3("EIJ_MOTIVO",5)) + Enter //"Os campos #### e $$$$ não podem ser preenchidos."
      ENDIF
   ENDIF

   IF LEFT(EIJ->EIJ_TIPCOB,1) $ "3"  .AND. !lDISimples
      IF EMPTY(EIJ->EIJ_INSTFI)
         cErro+=cAdicao+AVSX3("EIJ_INSTFI",5)+STR0141+Enter //STR0141 " não preenchido."
      ENDIF
      IF !EMPTY(EIJ->EIJ_MODALI) .OR. !EMPTY(EIJ->EIJ_MOTIVO)
         cErro += cAdicao + StrTran(StrTran(STR0142, "####", AVSX3("EIJ_MODALI",5)), "$$$$", AVSX3("EIJ_MOTIVO",5)) + Enter //"Os campos #### e $$$$ não podem ser preenchidos."
      ENDIF
   ENDIF

   IF LEFT(EIJ->EIJ_TIPCOB,1) $ "4" .AND. !lDISimples
      IF EMPTY(EIJ->EIJ_MOTIVO)
         cErro+=cAdicao+AVSX3("EIJ_MOTIVO",5)+STR0141+Enter//STR0141 " não preenchido."
      ENDIF
      IF !EMPTY(EIJ->EIJ_MODALI) .OR. !EMPTY(EIJ->EIJ_INSTFI) .AND. !lDISimples
         cErro += cAdicao + StrTran(StrTran(STR0142, "####", AVSX3("EIJ_MODALI",5)), "$$$$", AVSX3("EIJ_INSTFI",5)) + Enter//"Os campos #### e $$$$ não podem ser preenchidos."
      ENDIF
   ENDIF

   SW8->(dbSetOrder(4)) //W8_FILIAL+W8_HAWB+W8_ADICAO
   IF SW8->(dbSeek( (cFilSW8:=xFilial()) + EIJ->EIJ_HAWB+ EIJ->EIJ_ADICAO ))
        DO WHILE !SW8->(EOF()) .and. SW8->W8_FILIAL==cFilSW8 .and.;
           SW8->W8_HAWB == EIJ->EIJ_HAWB .AND.;
           SW8->W8_ADICAO ==EIJ->EIJ_ADICAO
           IF SW8->W8_VLMLE < 0
              cErro += cAdicao + StrTran(StrTran(STR0143, "####", ALLTRIM(SW8->W8_COD_I)), "$$$$", ALLTRIM(SW8->W8_INVOICE)) //"O valor na moeda do item: ####, Invoice: $$$$, está negativo."
           ENDIF
           IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"VALID_SW8_ENVIO_SISC"),)
           SW8->(DBSKIP())
        ENDDO
   ENDIF
   SW8->(dbSetOrder(1))

   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"VALID_EIJ_ENVIO_SISC"),)

   EIJ->(DBSKIP())
ENDDO

IF lNovaInt // GFP - 26/03/2015 - Detalhamento da mercadoria / Informações Complementares / Taxa do processo
   nRegisSW3 := SW3->(RECNO())
   nOrdemSW3 := SW3->(INDEXORD())
   SW8->(DbSeek(xFilial("SW8")+SW6->W6_HAWB))  //W8_FILIAL+W8_HAWB+W8_INVOICE+W8_FORN+W8_FORLOJ
   Do While SW8->(!Eof()) .AND. SW8->W8_FILIAL == xFilial("SW8") .AND. SW8->W8_HAWB == SW6->W6_HAWB
      mMemo := ""
      cMemo := ""
      SB1->(DbSeek(xFilial("SB1")+SW8->W8_COD_I))
      If !EMPTY(SW8->W8_DESC_DI)
         mMemo := MSMM(SW8->W8_DESC_DI,AvSx3("W8_DESC_VM",3))
      EndIf
      If EMPTY(mMemo)
         mMemo := MSMM(SB1->B1_DESC_GI,AvSx3("B1_VM_GI",3))
      EndIf
      If EasyGParam("MV_PN_DI",,.F.)
         mMemo+= " - " + ALLTRIM(TRANS(SW8->W8_COD_I,AVSX3("B1_COD",6)))
         SW3->(DbSetOrder(8))//W3_FILIAL+W3_PO_NUM+W3_POSICAO
         SW3->(DbSeek(xFilial("SW3")+SW8->W8_PO_NUM+SW8->W8_POSICAO))
         If !Empty(SW3->W3_PART_N)
             mMemo+= " - " + SW3->W3_PART_N
         ElseIf EICSFabFor(xFilial("SA5")+SW8->W8_COD_I+SW8->W8_FABR+SW8->W8_FORN, EICRetLoja("SW8", "W8_FABLOJ"), EICRetLoja("SW8", "W8_FORLOJ"))
             mMemo+= " - "+ ALLTRIM(SA5->A5_CODPRF)
         EndIf
      EndIf
	  mMemo := STRTRAN(mMemo,CHR(13)+CHR(10),' ')
	  cMemo := ""
      For i := 1 To MlCount(mMemo,AvSx3("W8_DESC_VM",3))
          cMemo += AllTrim(MemoLine(mMemo,AvSx3("W8_DESC_VM",3),i))
      Next i
      If Len(cMemo) >= 3900
         cErro += StrTran(STR0242, "####", AllTrim(SW8->W8_COD_I)) + ENTER //"O detalhamento do item #### não pode ultrapassar 3900 caracteres."
      EndIf
      SW8->(DbSkip())
   EndDo
   nTaxaUSD := BuscaTaxa(cMoeDolar,dDataBase,.T.,.F.,.T.)
   If SW6->W6_TX_US_D <> nTaxaUSD
      cErro += STR0243 + ENTER //"A taxa informada no processo está desatualizada em comparação com a data da geração do arquivo. Atualize as taxas do processo."
   EndIf
   mMemo := ""
   mMemo := MSMM(SW6->W6_COMPLEM,AvSx3("W6_VM_COMP",3))
   //mMemo := STRTRAN(mMemo,CHR(13)+CHR(10),' ')
   cMemo := ""
   For i := 1 To MlCount(mMemo,AvSx3("W6_VM_COMP",3))
      cMemo += AllTrim(MemoLine(mMemo,AvSx3("W6_VM_COMP",3),i)) + CHR(13)+CHR(10)
   Next i
   If Len(cMemo) >= 7800
      cErro += STR0241 + ENTER //"As informações complementares do processo não podem ultrapassar 7800 caracteres"
   EndIf
   SW3->(DbSetOrder(nOrdemSW3))
   SW3->(DbGoTo(nRegisSW3))
EndIf

IF !lBlind .AND. !EMPTY(cErro)  // GFP - 27/02/2015
   DEFINE FONT oFont NAME "Courier New" SIZE 0,15
   DEFINE MSDIALOG oDLGDescr TITLE STR0144 + SW6->W6_HAWB; //"Inconsistencias Encontradas, processo: "
          From 00,00 To 32,70 OF oMainWnd

     oDLGDescr:SetFont(oFont)
     @32,2 GET cErro MEMO HSCROLL SIZE 325,210 OF oDLGDescr PIXEL  // GFP - 13/08/2015

// BAK - Tratamento da EnchoiceBar - 18/08/2011
//   ACTIVATE MSDIALOG oDLGDescr ON INIT DI500EnchoiceBar(oDLGDescr,,{||oDLGDescr:End()},.F.) CENTERED
   ACTIVATE MSDIALOG oDLGDescr ON INIT EnchoiceBar(oDLGDescr,{||oDLGDescr:End()},{||oDLGDescr:End()},.F.) CENTERED

ENDIF

RETURN EMPTY(cErro)

/*
Funcao      : DI501Taxa()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
Function DI501Taxa(lMemoria, lAtu,nOpc)

LOCAL nTaxaInv:=1,lDif:=.F.,cFILSW9:=xFilial("SW9")
LOCAL nTaxaUSD:=nTaxaSeg:=nTaxaFre:=0
LOCAL oDlgData
Local nTaxaAnt  // GFP - 21/02/2013

Local nOpcao := 1    // GFP - 09/10/2014
Local aHeader := {}, aCols := {}    // GFP - 09/10/2014
Local bAtu := {|x| x[2] := BuscaTaxa(x[1],dDataBusca,.T.,.F.,.T.)}    // GFP - 09/10/2014
Local lNewInv := .F.

Default lAtu := .F.  // GFP - 11/03/2013
Default nOPC := 4 //LRS - 04/05/2017
Private lMem:=lMemoria //para uso no ponto de entrada
Private dDataBusca:=dDataBase

If AvFlags("EAI_PGANT_INV_NF") .And. M->W6_TITOK == "2"
   MsgStop(STR0189, STR0001) //"Este processo possui pendências de integração com o Financeiro do ERP. Efetue as integrações pendentes para que seja possível editar as taxas do processo." ### Atenção
   Return .F.
EndIf


nTaxaAnt := If(lAtu, M->W6_TX_US_D, 0)  // GFP - 11/03/2013

lTaxa := .T.    // GFP - 25/02/2013

If Type("M->W6_DTREG_D") == "D"
   //TRP - 13/04/2010
   IF !lTemAdicao
      IF lMem
         IF !EMPTY(M->W6_DTREG_D)
            dDataBusca:=M->W6_DTREG_D
         ENDIF
      ELSE
         IF !EMPTY(SW6->W6_DTREG_D)
           dDataBusca:=SW6->W6_DTREG_D
         ENDIF
      ENDIF
   ELSE
      IF lMem
         IF !EMPTY(M->W6_DTREG_D)
            dDataBusca:=M->W6_DTREG_D
         ENDIF
      ENDIF
   ENDIF
EndIf

// LDR - 01/09/04
IF lMem
   // GFP - 08/10/2014 - Implementado ajuste para que o usuario possa informar uma taxa diferente da buscada pelo sistema.
   //             cTitulo    , cCampo         , cPicture                        , nTamanho                        , nDecimais                       , cValidação                                       , cReservado, cTipo                        , xReservado1, xReservado2
   Aadd(aHeader,{  STR0145   , "WKMOEDA"      , "@!"                            , 6                               , 0                               , NIL                                              , NIL       , AvSX3("W9_MOE_FOB",AV_TIPO)  , NIL        , NIL   })  //"Moeda"
   Aadd(aHeader,{  STR0146   , "WKTAXA"       , AvSX3("W6_TX_US_D",AV_PICTURE)  , AvSX3("W6_TX_US_D",AV_TAMANHO)  , AvSX3("W6_TX_US_D",AV_DECIMAL)  ,"NaoVazio(M->WKTAXA) .AND. Positivo(M->WKTAXA)"   , NIL       , AvSX3("W6_TX_US_D",AV_TIPO)  , NIL        , NIL   })  //"Taxa" //LGS-20/10/2014

   aCols := GeraTaxas()
   DEFINE MSDIALOG oDlgData TITLE STR0147  FROM 0,0 TO 340,390 OF oMainWnd PIXEL//156,165 TO 250,450   //"Atualização de Taxas"

      oPanel := TPanel():New(0,0,'',oDlgData,, .T., .T.,,,20,20)
      oPanel:Align := CONTROL_ALIGN_ALLCLIENT

      @ 0.3,0.5  TO 2.3,24.3 LABEL STR0148 OF oPanel  //" Data "
      @ 1.0,06 SAY STR0148 OF oPanel //"Data"
      @ 1.0,08 MSGET dDataBusca  SIZE 50,7
      @ 1.0,30 BUTTON STR0091  SIZE 34,11 FONT oDlgData:oFont ACTION (aEval(aCols,bAtu), oNewGetDb:aCols := aClone(aCols), oNewGetDb:Refresh()) OF oPanel  //"OK"

      @ 2.6,0.5  TO 10.7,24.3 LABEL STR0149 OF oPanel  //"Taxas do Processo"

      oPanel1 := TPanel():New(48,10,'',oPanel,, .T., .T.,,,178,95)
      oNewGetDb := MsNewGetDados():New(0,0,0,0,2,,,,{"WKTAXA"},,120,,,,oPanel1,aHeader,aCols)
      oNewGetDb:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
      oNewGetDb:aCols := aClone(aCols)
      oNewGetDb:Refresh()

      @ 15,9.25  BUTTON STR0150 SIZE 40,11 FONT oDlgData:oFont ACTION (EVAL({|| nOpcao := 1,oDlgData:End()})) OF oPanel  //"Confirmar"
      @ 15,27.75 BUTTON STR0151 SIZE 40,11 FONT oDlgData:oFont ACTION (EVAL({|| nOpcao := 0,oDlgData:End()})) OF oPanel  //"Sair"

   ACTIVATE MSDIALOG oDlgData CENTERED
   
ENDIF
// LDR - 01/09/04
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"DEPOIS_GET_DATA"),)

If nOpcao == 0    // GFP - 09/10/2014
   Return .F.
EndIf
If lMem
   aCols := aClone(oNewGetDb:aCols)
   nTaxaUSD:= aCols[aScan(aCols,{|x| x[1] == cMoeDolar})][2]
Else
   nTaxaUSD:=BuscaTaxa(cMoeDolar,dDataBusca,.T.,.F.,.T.)
EndIf
IF lMemoria
   nTaxaSeg:= If(!Empty(M->W6_SEGMOED) .AND. aScan(aCols,{|x| x[1] == M->W6_SEGMOED}) # 0,aCols[aScan(aCols,{|x| x[1] == M->W6_SEGMOED})][2],0)    // GFP - 09/10/2014
   nTaxaFre:= If(!Empty(M->W6_FREMOED) .AND. aScan(aCols,{|x| x[1] == M->W6_FREMOED}) # 0,aCols[aScan(aCols,{|x| x[1] == M->W6_FREMOED})][2],0)    // GFP - 09/10/2014
   IF !Inclui .AND. lPrimeiraVez
      Processa({|| DI500Existe() },STR0016) //"Pesquisa de Itens"
   ENDIF
ELSE
   nTaxaSeg:=BuscaTaxa(SW6->W6_SEGMOED,dDataBusca,.T.,.F.,.T.)
   nTaxaFre:=BuscaTaxa(SW6->W6_FREMOED,dDataBusca,.T.,.F.,.T.)
ENDIF

ProcRegua(4)
IncProc(STR0152) //"Verificando a taxa do seguro..."
IF lMemoria
   IF (!EMPTY(M->W6_VL_USSE) .or. !EMPTY(M->W6_SEGPERC) ).AND. M->W6_TX_SEG # nTaxaSeg
      M->W6_TX_SEG :=nTaxaSeg
      M->W6_VLSEGMN:=DI500Trans(M->W6_VL_USSE*M->W6_TX_SEG)
      lDif:=.T.
   ENDIF
ELSE
   IF (!EMPTY(SW6->W6_VL_USSE) .or. !EMPTY(SW6->W6_SEGPERC) ) .AND. SW6->W6_TX_SEG # nTaxaSeg
      SW6->(RECLOCK("SW6",.F.))
      SW6->W6_TX_SEG :=nTaxaSeg
      SW6->W6_VLSEGMN:=DI500Trans(SW6->W6_VL_USSE*SW6->W6_TX_SEG)
      SW6->(MSUNLOCK())
      lDif:=.T.
   ENDIF
ENDIF

IncProc(STR0153) //"Verificando a taxa do frete..."
IF lMemoria
   nFrete:=ValorFrete(M->W6_HAWB,,,2,.T.)
   IF !EMPTY(nFrete) .AND. M->W6_TX_FRET # nTaxaFre
      M->W6_TX_FRET:=nTaxaFre
      lDif:=.T.
   ENDIF
ELSE
   nFrete:=ValorFrete(SW6->W6_HAWB,,,2)
   IF !EMPTY(nFrete) .AND. SW6->W6_TX_FRET # nTaxaFre
      SW6->(RECLOCK("SW6",.F.))
      SW6->W6_TX_FRET:=nTaxaFre
      SW6->(MSUNLOCK())
      lDif:=.T.
   ENDIF
ENDIF

IncProc(STR0154) //"Verificando a taxa da D.I. ..."
IF lMemoria
   IF M->W6_TX_US_D # nTaxaUSD
      M->W6_TX_US_D:=nTaxaUSD
   ENDIF
   nTaxaDolar := M->W6_TX_US_D //RMD - 23/12/14 - Guarda a taxa informada para comparar na validação do campo.
ELSE
   IF SW6->W6_TX_US_D # nTaxaUSD
      SW6->(RECLOCK("SW6",.F.))
      SW6->W6_TX_US_D:=nTaxaUSD
      SW6->(MSUNLOCK())
   // lDif:=.T.  // Esta taxa nao influencia nas adicoes
   ENDIF
ENDIF

/* ISS - 10/01/11 - Tratamento para executar as atualizações dos acrescimos somente quando a work "Work_EIN" estiver criada, ou seja,
                    lTemAdicao .OR. lTemDSI*/
IF SELECT("Work_EIN") > 0 .And. Work_EIN->(EasyRecCount("Work_EIN")) > 0
   //ACB - 27/12/2010 - Tratamento para que ao atualizar as taxa sejam atualizados os acrescimos e deduções.
   IncProc(STR0155)  //Verificando acréscimos e deduções...
   WORK_EIN->(dbGotop())
   Do while WORK_EIN->(!EOF())
      If AllTrim(WORK_EIN->EIN_FOBMOE) == "R$"
         WORK_EIN->EIN_VLMMN:= Work_EIN->EIN_VLMLE
      Else
         WORK_EIN->EIN_VLMMN:= Work_EIN->EIN_VLMLE*BuscaTaxa(WORK_EIN->EIN_FOBMOE,dDataBusca,.T.,.F.,.T.)
      EndIf
      WORK_EIN->(DBskip())
   EndDo
EndIf
IncProc(STR0156) //"Verificando taxas das Invoices..."
IF lMemoria
   Work_SW9->(DBSETORDER(1))
   Work_SW9->(DBGOTOP())
   cAlias:="Work_SW9"
   bWhile:={||.T.}
ELSE
   SW9->(DBSETORDER(3))
   SW9->(DBSEEK(cFILSW9+SW6->W6_HAWB))
   cAlias:="SW9"
   bWhile:={|| SW9->W9_HAWB   == SW6->W6_HAWB .AND.;
               SW9->W9_FILIAL == cFILSW9}
ENDIF
lNewInv:= .F.
DO WHILE (cAlias)->(!EOF()) .AND. EVAL(bWhile)
   If lMem    // GFP - 09/10/2014
      nTaxaInv:=aCols[aScan(aCols,{|x| x[1] == (cAlias)->W9_MOE_FOB})][2]
   Else
      nTaxaInv:=BuscaTaxa((cAlias)->W9_MOE_FOB,dDataBusca,.T.,.F.,.T.)
   EndIf
   IF (cAlias)->W9_TX_FOB # nTaxaInv
      IF(!lMemoria, SW9->(RECLOCK("SW9",.F.)) ,)
      (cAlias)->W9_TX_FOB:=nTaxaInv
      IF(!lMemoria, SW9->(MSUNLOCK()) ,)
      lDif:=.T.
      lGravaSoCapa:=.F.
      IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ALTERA_SW9_A"),)
   Endif
   If lMemoria
      If !lNewInv
      	If WORK_SW9->(!EOF()) .And. WORK_SW9->WK_RECNO == 0 
      		lNewInv := .T.
      	EndIf
      EndIf     
   EndIf
   
   (cAlias)->(DBSKIP())
ENDDO

IncProc()

IF lDif
   IF lMemoria
      IF MOpcao # FECHTO_EMBARQUE .AND. lTemAdicao
         lGravaSoCapa:=.F.
         IF lDISimples
            Processa({|| DI500CalcDSI("Work_EIJ",.T.)   }, STR0157) //STR0157 "Calculando os impostos..."
         ELSE
            Processa({|| DI500GeraAdicoes(.T.)}, STR0158) //"Gerando as adições..."
         ENDIF
      ENDIF
   ELSE
      SW6->(RECLOCK("SW6",.F.))
      SW6->W6_ADICAOK := '2'
      SW6->(MSUNLOCK())
      SW9->(DBSETORDER(1))
      RETURN .F.
   ENDIF
ENDIF

If(lAtu, oEnCh1:SetFocus(),) // GFP - 12/03/2013

AtuVldI(If(lMemoria, M->W6_HAWB, SW6->W6_HAWB),aCols,lMem)

RETURN .T.

/*
Funcao      : DI501DIConf()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
Function DI501DIConf()

Local aOrd         := {}
Local cDesc1       := ""
Local cDesc2       := ""
Local cDesc3       := ""

Private lImpAdicao := MsgYesNo(STR0159,) // LDR - 06/07/04 //"Deseja imprimir as adições?"
Private titulo     := STR0188 //"Declaracao de Importacao "
Private Cabec1     := SW6->W6_REF_DES
Private Cabec2     := STR0160 //"Rascunho"
Private nLin       := 99
Private limite     := 80
Private tamanho    := "P"
Private nomeprog   := "DI500DICONF"
Private nTipo      := 15
Private aReturn    := { "Zebrado", 1, STR0062, 2, 2, 1, "", 1} //"Importação"
Private nLastKey   := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "DI500DICONF"
Private nInd, cCond

wnrel := SetPrint("SW6",NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
   Return .T.
EndIf

SetDefault(aReturn,"SW6")

If nLastKey == 27
   Return .T.
EndIf

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| DI500ImpRel(Cabec1,Cabec2,Titulo,nLin,lImpAdicao) },Titulo)

SET DEVICE TO SCREEN
If aReturn[5] == 1
   Set Printer To
   dbCommitAll()
   Ourspool( wnrel )
End
MS_FLUSH()

Return .T.

/*
Funcao      : DI501DIConf()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
// AWR - N.V.A.E - 16/10/2004 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
Function DI501NVE(nOpc)

LOCAL oDlg, lTemItens:=.F.,T,lMarcado,nRecWk,i, lEIJTec:= .F.
PRIVATE aForn:={},aPLIs:={},aPOs:={},aInvoice:={}
PRIVATE cPLI,cPO,cInvoice,oMarkItens,nSelOp
PRIVATE oCboPLI,oCboPO,oInv,oCboFor
PRIVATE aBotaoNVE:={},bBlocSel:={||.T.}
PRIVATE bAtributo:={|| Work_GEIM->EIM_ATRIB == SJL->JL_ATRIB }//AWR - Usado no filtro do SXB do F3 do SJL no EIM_ESPECI
PRIVATE cFiltroSW8 := "!EMPTY(Work_SW8->WKFLAGIV) .AND. !EMPTY(Work_SW8->WKINVOICE) .AND. ALLTRIM(M->EIJ_TEC) $ left(AllTrim(Work_SW8->WKTEC),len(ALLTRIM(M->EIJ_TEC)))"
PRIVATE aOrd_EIM := {} // NCF - 07/12/11 - Classificação N.V.A.E na PLI
PRIVATE cClassif := ""
PRIVATE aWkSW8Bkp := {} , lOpcCanc := .F.

IF !SJK->(DBSEEK(xFilial()))
   MSGSTOP(STR0161, STR0001)//"O cadastro de 'Atributos para Valoração' está vazio. Acesse o menu 'Atualizações/ Tabelas Siscomex/ Sisccad (Siscomex)' e importe usando a opção 'Atrib. p/ Valoração Aduaneira'."
   RETURN .F.
ENDIF

IF !SJL->(DBSEEK(xFilial()))
   MSGSTOP(STR0162, STR0001) //"O cadastro de 'Especificações para Valoração' está vazio. Acesse o menu 'Atualizações/ Tabelas Siscomex/ Sisccad (Siscomex)' e importe usando a opção 'Especificações p/ Valoração'."
   RETURN .F.
ENDIF

nRecWk := Work->(Recno())
lMarcado := .F.
Work->(DbGoTop())
Do While Work->(!Eof())
   If Work->WKFLAG
      lMarcado := .T.
      Exit
   EndIf
   Work->(DbSkip())
EndDo
Work->(DbGoTop())

If !lMarcado
   Alert(STR0252) //"Não existem itens marcados para Classificação NVE."
   Return .F.
EndIf

IF !Inclui
   IF nPos_aRotina == VISUAL .OR. nPos_aRotina == ESTORNO
      IF Work_SW8->(EasyRecCount("Work_SW8")) = 0
         Processa({|| DI500InvCarrega()},STR0016) //"Pesquisa de Itens"
      ENDIF
//      DI500VerNVEs(.T.) - ASR 12/01/2006 - FUNCAO NAO EXISTENTE - DI500VerNVEs
      RETURN .T.
   ELSEIF lPrimeiraVez
      Processa({|| DI500Existe() },STR0016) //"Pesquisa de Itens"
   ENDIF
ENDIF

DBSELECTAREA("Work_CEIM")
//ZAP
AvZap("Work_CEIM")
Work_SW8->(DBGOTOP())

DO WHILE Work_SW8->(!EOF())

   IF EMPTY(Work_SW8->WKFLAGIV) .OR.  EMPTY(Work_SW8->WKINVOICE)
      Work_SW8->(DBSKIP())
      LOOP
   ENDIF

   lTemItens:=.T.

   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"WHILE_SW8_NVES"),)

   IF !EMPTY(Work_SW8->WKNVE) .AND. !Work_CEIM->(DBSEEK(Work_SW8->WKNVE))
       Work_CEIM->(DBAPPEND())
       Work_CEIM->EIM_CODIGO:=Work_SW8->WKNVE
       Work_CEIM->WKTEC     :=Work_SW8->WKTEC

       //NCF - 08/08/2011 - Classificação N.V.A.E na PLI
       If lCposNVEPLI  .And. EasyGParam("MV_EIC0011",,.F.)
          aOrd_EIM := SaveOrd({"EIM","Work_EIM"})
          EIM->(DbSetOrder(2))
          //MFR 23/11/2018
          //If EIM->(DbSeek(xFilial("EIM")+AvKey(Work_SW8->WKPGI_NUM,"W6_HAWB")+Work_SW8->WKNVE))
          If EIM->(DbSeek(GetFilEIM("LI")+AvKey(Work_SW8->WKPGI_NUM,"W6_HAWB")+Work_SW8->WKNVE))
             If EIM->EIM_FASE == "LI"
                Work_EIM->(DbSetOrder(3))
                Do While EIM->EIM_FASE == "LI" .And. EIM->EIM_HAWB == AvKey(Work_SW8->WKPGI_NUM,"W6_HAWB") .And. EIM->EIM_CODIGO == Work_SW8->WKNVE
                   If !Work_EIM->(DbSeek(EIM->(EIM_FASE+EIM_HAWB+EIM_CODIGO+EIM_NIVEL+EIM_ATRIB+EIM_ESPECI)));
                   .And. !Work_EIM->(DbSeek("DI"+M->W6_HAWB+EIM->EIM_CODIGO+EIM->EIM_NIVEL+EIM->EIM_ATRIB+EIM->EIM_ESPECI))
                      If aScan(aWkDeletados,{|x|x[1] == "EIM" .And. x[2] == EIM->(Recno())}) == 0   //NCF - 09/11/2012 - Verificar se foi excluída a tabela da NVE
                         Work_EIM->(DbAppend())                                                     //                   inteira via rotina de NVE
                         AVREPLACE("EIM","Work_EIM")
                         Work_EIM->EIM_HAWB := EIM->EIM_HAWB
                         Work_EIM->WK_RECNO := EIM->(Recno())
                      EndIf
                   EndIf
                   EIM->(DbSkip())
                EndDo
             EndIf
          EndIf
          RestOrd(aOrd_EIM,.T.)
       EndIf

   ENDIF
   aAdd(aWkSW8Bkp,{Work_SW8->(Recno()),Work_SW8->WKNVE,""}) //NCF - 18/05/2018 - Guardar vinculação original para possível restauração
   Work_SW8->(DBSKIP())

ENDDO

IF !lTemItens
   MSGSTOP(STR0163, STR0053) //"Processo não possui Itens de Invoice."
   Work_SW8->(DBGOTOP())
   RETURN .T.
ENDIF

nCol   := 130
nLin   := 4
lNVEInclui:=.F.

aCposMostra:={}
//AADD(aBotaoNVE,{"PREV"    ,{|| IF(DI500TemNVEOK(.T.),(nSelOp:=1,oDlg:End()),) },STR0164,STR0164}) //"Tabela Anterior" //"Anterior"
//AADD(aBotaoNVE,{"NEXT"    ,{|| IF(DI500TemNVEOK(.T.),(nSelOp:=2,oDlg:End()),) },STR0165,STR0165}) //"Proxima Tabela" //"Proxima"
AADD(aBotaoNVE,{"NEXT"    ,{|| DI500LegNVE() },STR0245,STR0245}) //"Legendas"
If nOpc == 3 .OR. nOpc == 4
   AADD(aBotaoNVE,{"NEXT"    ,{|| (DI500SelNVE(),oMarkItens:oBrowse:Refresh()) },STR0169,STR0169}) //"Seleção de Itens"
EndIf
aTelaSW6:=ACLONE(aTela)
aGetsSW6:=ACLONE(aGets)
aTela:={}
aGets:={}
nSelOp:=0
aCamposSW8:={}
AADD(aCamposSW8,{"WKFLAGNVE" ,,""})
AADD(aCamposSW8,{"WKNVE"     ,,"Tab N.V.E."})
AADD(aCamposSW8,{"WKTEC"     ,,AVSX3("W3_TEC"    ,5),AVSX3("W3_TEC",6)})
AADD(aCamposSW8,{"WKPO_NUM"  ,,AVSX3("W8_PO_NUM" ,5)})
AADD(aCamposSW8,{"WKPGI_NUM" ,,AVSX3("W8_PGI_NUM",5)})
AADD(aCamposSW8,{"WKMOEDA"   ,,AVSX3("W2_MOEDA"  ,5)})
AADD(aCamposSW8,{"WKINVOICE" ,,AVSX3("W9_INVOICE",5)})
AADD(aCamposSW8,{"WKCOD_I"   ,,AVSX3("W8_COD_I"  ,5)})
AADD(aCamposSW8,{"WKFORN"    ,,AVSX3("W8_FORN"   ,5)})
If EICLoja()
   aAdd(aCamposSW8,{"W8_FORLOJ",, AvSX3("W8_FORLOJ", 5)})
EndIf
AADD(aCamposSW8,{"WKADICAO"  ,,AVSX3("W8_ADICAO" ,5)})

//Inicia o aHeader guardado na Array aTabelas no inicio do programa
nPos   :=ASCAN(aTabelas,{|A|A[1]=="GEIM"})
aHeader:=ACLONE(aTabelas[nPos,5])
//** PLB 26/02/07 - Walk-Thru
SX3->( DBSetOrder(2) )
SX3->( DBSeek("EIM_FILIAL") )
cUsado := SX3->X3_USADO
//AAdd( aHeader, { "Alias WT", "EIM_ALI_WT", "", 3,  0, NIL, cUsado, "C", "Work_GEIM", "" } )
//AAdd( aHeader, { "Recno WT", "EIM_REC_WT", "", 10, 0, NIL, cUsado, "N", "Work_GEIM", "" } )
//**
aCpos:={"EIM_HAWB","EIM_NIVEL","EIM_ADICAO","EIM_CODIGO"}
//NCF - 08/08/2011 - Classificação N.V.A.E na PLI
If EIM->(FIELDPOS("EIM_FASE")) # 0  // GFP - 05/02/2016 - Retirado exibição do campo EIM_FASE.
   aAdd(aCpos,"EIM_FASE")
EndIf
If lEIM_NCM
   aAdd(aCpos,"EIM_NCM")   
EndIf
nPos :=0
nTam :=LEN(aHeader)-LEN(aCpos)
FOR T := 1 TO LEN(aCpos)//Tira os Campos que nao deve aparecer no MSGETDB
    IF (nPos:=ASCAN(aHeader,{|H|H[2]==aCpos[T]})) # 0
       ADEL(aHeader,nPos)
       ASIZE(aHeader,LEN(aHeader)-1)
    ENDIF
NEXT
//IF(nPos#0,ASIZE(aHeader,nTam),)

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"COLUNAS_BOTOES_NVES"),)

Work_CEIM->(DBGOTOP())

DO WHILE .T.

   IF nSelOp = 1     // Anterior
      Work_CEIM->(DBSKIP(-1))
      IF Work_CEIM->(BOF())
         Work_CEIM->(DBGOBOTTOM())
      ENDIF
   ELSEIF nSelOp = 2 // Proximo
      Work_CEIM->(DBSKIP())
      IF Work_CEIM->(EOF())
         Work_CEIM->(DBGOTOP())
      ENDIF
   ELSEIF nSelOp = 4 // Exclusao
      Work_CEIM->(DBSKIP(-1))                           //NCF - 09/11/2012
      IF Work_CEIM->(BOF())
         Work_CEIM->(DBGOBOTTOM())
      ENDIF
   ENDIF
      aNVE := DI501VerNVE(nOpc)
      If aNVE[3] == 0
         Return .F.
      Else
         lGravaEIM:=.T.
         cNVE       := aNVE[1]
         Work_EIM->(DBSETORDER(2)) //Codigo da Nve
         Work_EIM->(DBSEEK(cNVE))
         
         M->EIJ_TEC := If(nOpc == 3 .Or. Empty(WORK_EIM->EIM_NCM), aNVE[2], WORK_EIM->EIM_NCM )

         If aNVE[3] # 3
            //Work_EIM->(DbGoTop())
            cClassif := Work_EIM->EIM_NIVEL          
         Else
            IF DI500GetNCM()
               EXIT
            ENDIF            
            cClassif := SJK->JK_NIVEL //posiciona na tabela SJK com base na NCM - função DI501NVEVal
            cNVE := DI500GerNVE()
            lNVEInclui  := .T.
         EndIf
         If aNVE[3] == 5
            If MsgYesNo(STR0253,STR0001)//"Deseja excluir a NVE vinculada?" ## "Atenção"
               DI500GrvNVE(4,cNVE,M->EIJ_TEC)
            EndIf
            EXIT
         EndIf
      EndIf

      //NCF - 29/05/2018 - Alterado o local de carregamento dos combobox para considerar a n.c.m selecionada nos filtros
      Work_SW8->(DBGOTOP())
      DO WHILE Work_SW8->(!EOF())
         IF EMPTY(Work_SW8->WKFLAGIV) .OR.  EMPTY(Work_SW8->WKINVOICE)
            Work_SW8->(DBSKIP())
            LOOP
         ENDIF
		 		 
         lEIJTec:= Alltrim(M->EIJ_TEC) == Left(Work_SW8->WKTEC, Len(Alltrim(M->EIJ_TEC)))
         IF ASCAN( aInvoice, Work_SW8->WKINVOICE ) == 0 .And. lEIJTec
            AADD ( aInvoice, Work_SW8->WKINVOICE )
            cInvoice:=aInvoice[1]
         ENDIF

         IF ASCAN( aPLIs, Work_SW8->WKPGI_NUM ) == 0 .And. lEIJTec
            AADD ( aPLIs, Work_SW8->WKPGI_NUM )
            cPLI:=aPLIs[1]
         ENDIF

         IF ASCAN( aPOs, Work_SW8->WKPO_NUM ) == 0 .And. lEIJTec
            AADD ( aPOs, Work_SW8->WKPO_NUM )
            cPO:=aPOs[1]
         ENDIF
         Work_SW8->(DBSKIP())
      ENDDO  
   
   If nOpc # 3 .OR. (Work_GEIM->(EasyRecCount("Work_GEIM")) == 0 .OR. nPos_aRotina == INCLUSAO)
      DI500GEIMGrv(cNVE)
   EndIf
   Work_GEIM->(DBGOTOP())

   nPos:=nPos_aRotina//Verifica se a MS GETDB deve aparecer com um registro em branco ou nao e serao editavel
   IF Work_GEIM->(EasyRecCount("Work_GEIM")) > 0 .AND. nPos_aRotina == INCLUSAO
      nPos:= ALTERACAO
   ELSEIF Work_GEIM->(EasyRecCount("Work_GEIM")) == 0 .AND. nPos_aRotina == ALTERACAO
      nPos:= INCLUSAO
      Work_GEIM->(AvZap())
   ENDIF
   nSelOp := 0
   aAdvSize := MsAdvSize()
   oMainWnd:ReadClientCoors()

    DEFINE MSDIALOG oDlg TITLE STR0166 +" - "+cNVE FROM 0, 0 TO aAdvSize[6], aAdvSize[5] OF oMainWnd PIXEL 
          
    oPanelTela:= TPanel():New(0,0, "", oDlg, /*Fonte Texto*/, /*se texto no centro*/,/*uParam*/, /*Cor Texto*/, /*Cor fundo*/, /*largura*/, 40/*altura*/)
    oPanelTela:Align:= CONTROL_ALIGN_ALLCLIENT

    oPanelTop:= TPanel():New(0, 0, "", oPanelTela)
    oPanelTop:nHeight := oPanelTela:nClientHeight*0.06
    oPanelTop:Align := CONTROL_ALIGN_TOP

    oPanelLeft:= TPanel():New(0, 0, "", oPanelTela)
    oPanelLeft:nWidth := oDlg:nWidth
    oPanelLeft:nHeight := oPanelTela:nClientHeight*0.47
    oPanelLeft:Align := CONTROL_ALIGN_LEFT    

    oPanelBot:= TPanel():New(0, 0, "", oPanelTela)
    oPanelBot:nHeight := oPanelTela:nClientHeight*0.47
    oPanelBot:Align := CONTROL_ALIGN_BOTTOM    

      nMeio := /*86*/ 175
      
      @ 05,05 SAY STR0182 /*"N.C.M."*/ OF oPanelTop PIXEL
      @ 05,35 MSGET M->EIJ_TEC PICTURE AVSX3("W3_TEC",6) F3 "SJ_" SIZE 45,08 OF oPanelTop PIXEL  WHEN .F.

      @ 05,105 SAY STR0249 OF oPanelTop PIXEL  //"Nível Classif."
      @ 05,145 COMBOBOX oClassif VAR cClassif ITEMS StrTokArr(AllTrim(Posicione("SX3",2,"EIM_NIVEL","X3_CBOX")),";") SIZE 90,08 OF oPanelTop PIXEL PIXEL WHEN .F.
      
      Work_GEIM->(DbSetOrder(0))
      
      oMarkEI:=MsGetDB():New(0, 0, 0, 0 ,nPos,'DI500NVEVal("LINHA")',"","",.T.,,,.F.,,"Work_GEIM",,.F.,,oPanelLeft)
      oMarkEI:oBrowse:bwhen:={|| (dbSelectArea("Work_GEIM"),.T.) }
      oMarkEI:ForceRefresh()
      oMarkEI:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
      
      DBSELECTAREA("Work_SW8")
      Work_SW8->(DBSETORDER(1))
      
      // SVG - 13/07/09 -
      If ("CTREE" $ RealRDD())
         Work_SW8->(DBEVAL({||;
         If(&(cFiltroSW8),Work_SW8->WKFILTRO:="S",Work_SW8->WKFILTRO:="")}))
         SET FILTER TO Work_SW8->WKFILTRO == "S"
      Else
         SET FILTER TO &(cFiltroSW8)
      EndIf

      Work_SW8->(DBGOTOP())
      IF SetMDIChild()
         nMeio+=10
      ENDIF
      oMarkItens:=MSSELECT():New("Work_SW8","WKFLAGNVE",,aCamposSW8,lInverte,cMarca,,,,oPanelBot)
      oMarkItens:oBrowse:bWhen:={|| DBSELECTAREA('Work_SW8'),DBSETORDER(1),.T.} 
      oMarkItens:bAval:={|| DI500MarNVE() }
      oMarkItens:obrowse:ACOLUMNS[1]:BDATA:={|| IF(EMPTY(Work_SW8->WKNVE),"BR_VERMELHO",IF(Work_SW8->WKNVE==cNVE,"BR_AZUL","BR_VERDE")) }
      oMarkItens:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
      oDlg:lMaximized:=.T.
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| IF( DI500NVEVal("OK"),(nSelOp:=0,oDlg:End()),)},{|| (nSelOp:=0,lOpcCanc:=.T.,oDlg:End()) },,aBotaoNVE) CENTERED

   IF nSelOp # 0

      IF DI500TemNVEOK(.T.)
         Processa({|| DI500GrvNVE(nSelOp,cNVE) })
      ENDIF

      IF nSelOp = 3 // Inclusao
         lNVEInclui := .T.
      ENDIF

      LOOP
   ELSE
      //NCF - 18/05/2018 - restaura tabelas vinculadas se clicado no botão Cancelar
      If lOPcCanc
         For i:=1 To Len(aWkSW8Bkp)
            Work_SW8->(DbGoTo(aWkSW8Bkp[i][1]))
            Work_SW8->WKNVE := aWkSW8Bkp[i][2]
         Next i
         lOpcCanc := .F.
      EndIf
      aWkSW8Bk := {}     
   ENDIF
  
   EXIT 

Enddo

Work_EIM->(DBSETORDER(1))
Work_SW8->(DBSETORDER(1))
DBSELECTAREA("Work_SW8")
SET FILTER TO
aTela:=ACLONE(aTelaSW6)
aGets:=ACLONE(aGetsSW6)

Return NIL

/*
Funcao      : DI501GetNCM()()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
FUNCTION DI501GetNCM()()

LOCAL oDlgNCM,lSair:=.T.
Local bOk := {|| IF(DI500NVEVal("NCM"),(lSair:=.F.,oDlgNCM:End()),) } //FSM - 20/07/2011
Local bCancel := {|| (lSair:=.T.,oDlgNCM:End()) }
DEFINE MSDIALOG oDlgNCM TITLE STR0166 FROM 0,0 TO 10,50 Of oMainWnd //"Manutenção de NVE's"

    oPanel:= TPanel():New(0, 0, "", oDlgNCM,, .F., .F.,,, 90, 165)
    oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

    @ 20,10 SAY "N.C.M." OF oPanel PIXEL
    @ 20,40 MSGET M->EIJ_TEC PICTURE AVSX3("W3_TEC",6) F3 "SJ_" SIZE 45,08 OF oPanel PIXEL

ACTIVATE MSDIALOG oDlgNCM ON INIT EnchoiceBar(oDlgNCM, bOk, bCancel) CENTERED

/* FSM - 20/07/2011
DI500EnchoiceBar(oDlgNCM,{{|| IF(DI500NVEVal("NCM"),(lSair:=.F.,oDlgNCM:End()),) },"OK"},;
                                                            {|| (lSair:=.T.,oDlgNCM:End()) },.F.) CENTERED */
RETURN lSair

/*
Funcao      : DI501DelNV()()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
FUNCTION DI501DelNV()

IF Work_GEIM->DBDELETE
   RETURN .F.
ENDIF
RETURN .T.

/*
Funcao      : DI501TemNVEOK()()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
FUNCTION DI501TemNVEOK(lVerItens,lMSG)

LOCAL lTemLinha:= .F.,T
LOCAL nRec1 :=Work_GEIM->(RECNO())
LOCAL nRecno:=Work_SW8->(RECNO())
LOCAL nOrder:=Work_SW8->(INDEXORD())
LOCAL aTab:={},cMsgNVE,cDetNVE
DEFAULT lVerItens := .T.
DEFAULT lMSG := .T.

SJL->(DBSETORDER(1))//JL_FILIAL+JL_NCM+JL_ATRIB+JL_ESPECIF
Work_GEIM->(DBGOTOP())
DO WHILE Work_GEIM->(!EOF())
   IF Work_GEIM->DBDELETE
      Work_GEIM->(dbSkip())
      LOOP
   ENDIF
   IF !EMPTY(Work_GEIM->EIM_NIVEL) .And. !EMPTY(Work_GEIM->EIM_ATRIB) .And. EMPTY(Work_GEIM->EIM_ESPECI)
      MSGSTOP(STR0279) //"Existem atributos sem a especificação informada!"
      Work_GEIM->(DBGOTO(nRec1))
      Return .F.      
   ENDIF
   IF EMPTY(Work_GEIM->(EIM_NIVEL+EIM_ATRIB+EIM_ESPECI))
      Work_GEIM->(dbSkip())
      LOOP
   ENDIF
   cTECSeek:=M->EIJ_TEC
   nTamTEC:=LEN(M->EIJ_TEC)
   FOR T := 1 TO nTamTEC
       IF !SJL->(DBSEEK(xFilial()+cTECSeek))
          cTECSeek:=LEFT(M->EIJ_TEC,nTamTEC-T)+SPACE(T)
       ELSE
          EXIT
       ENDIF
   NEXT
   IF ASCAN(aTab,Work_GEIM->(EIM_NIVEL+EIM_ATRIB)) = 0
      AADD(aTab,Work_GEIM->(EIM_NIVEL+EIM_ATRIB))
   ELSE
      If Posicione('SJK',1,xFilial("SJK")+AvKey(Work_GEIM->EIM_NCM,"JK_NCM")+AvKey(Work_GEIM->EIM_ATRIB,"JK_ATRIB"),'JK_MULTIPL') == 'N'
         MSGSTOP(STR0170) //"Atributo não pode ser duplicado."
         Work_GEIM->(DBGOTO(nRec1))
         Return .F.
      EndIf
   ENDIF
   IF !SJL->(DBSEEK(xFilial()+cTECSeek+AvKey(Work_GEIM->EIM_ATRIB,"JL_ATRIB")+AvKey(Work_GEIM->EIM_ESPECI,"JL_ESPECIF")))
      //MsgStop(StrTran(STR0171, "####", cTECSeek+Work_GEIM->(EIM_ATRIB+EIM_ESPECI)), STR0001) //"NCM não possui essa NVE: #### no cadastro de 'Especificações para Valoração'."
      cMsgNve := STR0171
      cDetNVE := STR0278
      cDetNVE := StrTran(cDetNVE, "####", M->EIJ_TEC)
      cDetNVE := StrTran(cDetNVE, "****", StrTokArr(AllTrim(Posicione("SX3",2,"EIM_NIVEL","X3_CBOX")),";")[aScan(StrTokArr(AllTrim(Posicione("SX3",2,"EIM_NIVEL","X3_CBOX")),";"),{|x|Left(x,1)==Work_GEIM->EIM_NIVEL})])
      cDetNVE := StrTran(cDetNVE, "@@@@", Work_GEIM->EIM_ATRIB)
      cDetNVE := StrTran(cDetNVE, "&&&&", Work_GEIM->EIM_ESPECI)
      cDetNVE := StrTran(cDetNVE, ",", CHR(13)+CHR(10))
      MsgStop(cMsgNve + CHR(13)+CHR(10) + cDetNVE , STR0001)      
      Work_GEIM->(DBGOTO(nRec1))
      RETURN .F.
   ELSEIF SJL->JL_NIVEL # Work_GEIM->EIM_NIVEL
      MsgStop(StrTran(StrTran(STR0172, "####", Work_GEIM->EIM_NIVEL), "$$$$", SJL->JL_NIVEL), STR0001) //"NCM, Atributo e Especificação não possuem esse nível: ####. Nível atual da NCM: $$$$."
      Work_GEIM->(DBGOTO(nRec1))
      Return .F.
   ENDIF
   lTemLinha:= .T.
   Work_GEIM->(dbSkip())
ENDDO
Work_GEIM->(DBGOTO(nRec1))

IF !lTemLinha
   IF lMSG
      MSGSTOP(STR0173, STR0053) // "Preencha as N.V.E.'s."
   ENDIF
   RETURN .F.
ENDIF

IF lVerItens
   Work_SW8->(DBSETORDER(5))
   IF !Work_SW8->(DBSEEK(cNVE))
      MSGSTOP(STR0174, STR0001) //"Não existem itens marcados para essa NVE."
      Work_SW8->(DBSETORDER(nOrder))
      Work_SW8->(DBGOTO(nRecno))
      Return .F.
   ENDIF
   Work_SW8->(DBSETORDER(nOrder))
   Work_SW8->(DBGOTO(nRecno))
ENDIF

Work_GEIM->(DBGOTOP())

Return .T.

/*
Funcao      : DI501GerNVE()()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
FUNCTION DI501GerNVE()

LOCAL nCodigo:=1
Work_EIM->(DBSETORDER(2))
DO WHILE Work_EIM->(DBSEEK(STRZERO(nCodigo,3)))
   nCodigo++
ENDDO
Work_EIM->(DBSETORDER(1))
Return STRZERO(nCodigo,3)

/*
Funcao      : DI501MarNVE()()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
FUNCTION DI501MarNVE()

IF !DI500NVEVal("MARCA")   
   If !(Alltrim(M->EIJ_TEC) $ Left(WORK_SW8->WKTEC, Len(Alltrim(M->EIJ_TEC))))
      Work_SW8->WKADICAO:=""
      Work_SW8->WKNVE   :=""
      DI500Controle(1)
   ENDIF
   RETURN .F.
ENDIF

IF EMPTY(Work_SW8->WKNVE)
   Work_SW8->WKNVE := cNVE
ELSEIF Work_SW8->WKNVE == cNVE
   Work_SW8->WKNVE := ""
ELSE
   Work_SW8->WKNVE := cNVE
ENDIF
Work_SW8->WKADICAO:=""
DI500Controle(1)

Return .T.

/*
Funcao      : DI501NVEVal()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
FUNCTION DI501NVEVal(cCampo,cChave)

LOCAL nRecno,nOrder,T
LOCAL aTab:={}
LOCAL cMsgNVE,cDetNVE

IF cCampo == "OK"

   IF EMPTY(M->EIJ_TEC) .AND. !DI500TemNVEOK(.F.,.F.)
      Return .T.
   ENDIF

   IF !DI500TemNVEOK(.T.)
      RETURN .F.
   ENDIF

   IF !DI500NVEVal("LINHA")
      RETURN .F.
   ENDIF

   Processa({|| DI500GrvNVE(nSelOp,cNVE) })

ELSEIF cCampo == "NCM"

// IF EMPTY(M->EIJ_TEC) .AND. !DI500TemNVEOK(.F.,.F.)
//    Return .T.
// ENDIF

   IF EMPTY(M->EIJ_TEC)
      MSGSTOP(STR0175) //STR0175 "NCM nao preenchida."
      Return .F.
   ENDIF

   SJK->(DBSETORDER(1))
   IF !SJK->(DBSEEK(xFilial()+M->EIJ_TEC))
      MSGSTOP(STR0222)  //STR0222 "NCM nao encontrada no Cadastro de Atributos para Valoracao."
      Return .F.
   ENDIF

   nRecno:=Work_SW8->(RECNO())
   nOrder:=Work_SW8->(INDEXORD())
   DBSELECTAREA("Work_SW8")
   SET FILTER TO
   Work_SW8->(DBSETORDER(6))
   IF !Work_SW8->(DBSEEK(ALLTRIM(M->EIJ_TEC)))
      MSGSTOP(STR0221) //STR0221 "NCM nao encontrada nos itens desse Desembaraco."
      Work_SW8->(DBSETORDER(nOrder))
      Work_SW8->(DBGOTO(nRecno))
      Return .F.
   ENDIF
   Work_SW8->(DBSETORDER(nOrder))
   Work_SW8->(DBGOTO(nRecno))

ELSEIF cCampo == "MARCA"

   IF EMPTY(M->EIJ_TEC)
      MSGSTOP(STR0175) //STR0175 "NCM nao preenchida."
      Return .F.
   ENDIF
      
   IF !(Alltrim(M->EIJ_TEC) $ Left(Work_SW8->WKTEC, Len(Alltrim(M->EIJ_TEC)) ))
      MSGSTOP(STR0197) //"NCM selecionada difere da NCM do item."
      Return .F.
   ENDIF
   //NCF - 18/05/2018 - Não permite trocar de tabela
   IF !Empty(Work_SW8->WKNVE) .And. Alltrim(Work_SW8->WKNVE) <> cNVE
      Return .F.
   EndIf

   IF !DI500TemNVEOK(.F.)
      Return .F.
   ENDIF

ELSEIF cCampo == "LINHA"

   IF Work_GEIM->DBDELETE
      RETURN .T.
   ENDIF
   IF EMPTY(Work_GEIM->EIM_NIVEL) .Or. EMPTY(Work_GEIM->EIM_ATRIB) .Or. EMPTY(Work_GEIM->EIM_ESPECI)
      MSGSTOP(STR0279,STR0001) //STR0195 "Existem atributos sem a especificação informada!"
      Return .F.
   ENDIF
   SJL->(DBSETORDER(1))//JL_FILIAL+JL_NCM+JL_ATRIB+JL_ESPECIF
   cTECSeek:=M->EIJ_TEC
   nTamTEC:=LEN(M->EIJ_TEC)
   FOR T := 1 TO nTamTEC
       IF !SJL->(DBSEEK(xFilial()+cTECSeek))
          cTECSeek:=LEFT(M->EIJ_TEC,nTamTEC-T)+SPACE(T)
       ELSE
          EXIT
       ENDIF
   NEXT
   IF !SJL->(DBSEEK(xFilial()+cTECSeek+AvKey(Work_GEIM->EIM_ATRIB,"JL_ATRIB")+AvKey(Work_GEIM->EIM_ESPECI,"JL_ESPECIF")))
      //MsgStop(StrTran(STR0171, "####", cTECSeek+Work_GEIM->(EIM_ATRIB+EIM_ESPECI)), STR0001) //"NCM não possui essa NVE: #### no cadastro de 'Especificações para Valoração'."
      cMsgNve := STR0171
      cDetNVE := STR0278
      cDetNVE := StrTran(cDetNVE, "####", M->EIJ_TEC)
      cDetNVE := StrTran(cDetNVE, "****", StrTokArr(AllTrim(Posicione("SX3",2,"EIM_NIVEL","X3_CBOX")),";")[aScan(StrTokArr(AllTrim(Posicione("SX3",2,"EIM_NIVEL","X3_CBOX")),";"),{|x|Left(x,1)==Work_GEIM->EIM_NIVEL})])
      cDetNVE := StrTran(cDetNVE, "@@@@", Work_GEIM->EIM_ATRIB)
      cDetNVE := StrTran(cDetNVE, "&&&&", Work_GEIM->EIM_ESPECI)
      cDetNVE := StrTran(cDetNVE, ",", CHR(13)+CHR(10))
      MsgStop(cMsgNve + CHR(13)+CHR(10) + cDetNVE , STR0001) 
      Return .F.
   ELSEIF SJL->JL_NIVEL # Work_GEIM->EIM_NIVEL
      MsgStop(StrTran(StrTran(STR0172, "####", Work_GEIM->EIM_NIVEL), "$$$$", SJL->JL_NIVEL), STR0001) //"NCM, Atributo e Especificação não possuem esse nível: ####. Nível atual da NCM: $$$$."
      Return .F.
   ENDIF
   nRec:=Work_GEIM->(RECNO())
   Work_GEIM->(DBGOTOP())
   aTab:={}
   DO WHILE Work_GEIM->(!EOF())
      IF Work_GEIM->DBDELETE
         Work_GEIM->(dbSkip())
         LOOP
      ENDIF
      IF ASCAN(aTab,Work_GEIM->(EIM_NIVEL+EIM_ATRIB)) = 0
         AADD(aTab,Work_GEIM->(EIM_NIVEL+EIM_ATRIB))
      ELSE
         If Posicione('SJK',1,xFilial("SJK")+AvKey(Work_GEIM->EIM_NCM,"JK_NCM")+AvKey(Work_GEIM->EIM_ATRIB,"JK_ATRIB"),'JK_MULTIPL') == 'N'
            MSGSTOP(STR0170) //"Nivel Class. e Atributo nao podem ser duplicados."
            Work_GEIM->(DBGOTO(nRec))
            Return .F.
         EndIf
      ENDIF
      Work_GEIM->(DBSKIP())
   ENDDO
   Work_GEIM->(DBGOTO(nRec))

ENDIF

Return .T.

/*
Funcao      : DI501SelNVE()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
FUNCTION DI501SelNVE()

LOCAL oDlg, oRadio
LOCAL nLin := 17
LOCAL nColR:= 20 
LOCAL nCol := nColR+121
LOCAL nColS:= nCol-25
LOCAL nSoma:= 16
LOCAL nMarcaOK:=0

IF EMPTY(M->EIJ_TEC)
   MSGSTOP(STR0175) //"NCM nao preenchida."
   Return .F.
ENDIF

IF !DI500TemNVEOK(.F.)
   Return .F.
ENDIF

bBlocSel:={||.T.}

DO WHILE .T.

   nLin := 32

   DEFINE MSDIALOG oDlg TITLE STR0176 FROM 0,0 TO 19,63 Of oMainWnd //STR0176 "Seleciona Itens para Marcar"

   nOpRad:=4
   @nLin   ,nColR   TO nLin+75, nColR+84 LABEL STR0177 OF oDlg PIXEL //STR0177 "Seleção"
   @nLin+07,nColR+5 RADIO oRadio VAR nOpRad ITEMS STR0178,STR0017,STR0179,STR0180,STR0250 3D SIZE 60,16 ; //STR0178 "Pedido" //"Invoices" // STR0180 "Todos" // "Itens não vinculados"
                                            PIXEL OF oDlg ON CHANGE (DI500BOXNVE(.T.)) 
   nLin+=10

   @nLin+.6, nColS SAY STR0178 OF oDlg PIXEL //STR0178 "Pedido"
   @nLin,    nCol  COMBOBOX oCboPO  VAR cPO      ITEMS aPOs     SIZE 75,18 PIXEL WHEN {|| nOpRad==1 }
   nLin+=nSoma

   @nLin+.6, nColS SAY STR0014 OF oDlg PIXEL //STR0014 "Invoices"
   @nLin,    nCol  COMBOBOX oInv    VAR cInvoice ITEMS aInvoice SIZE 75,18 PIXEL WHEN {|| nOpRad==2 }
   nLin+=nSoma

   @nLin+.6, nColS SAY STR0179  OF oDlg PIXEL //PLI
   @nLin,    nCol  COMBOBOX oCboPLI VAR cPLI     ITEMS aPLIs    SIZE 75,18 PIXEL WHEN {|| nOpRad==3 }
   nLin+=nSoma

   @ nLin+.6,nColS SAY STR0182 OF oDlg PIXEL //"N.C.M."
   @ nLin,   nCol  MSGET M->EIJ_TEC PICTURE AVSX3("W3_TEC",6) SIZE 40,08 PIXEL WHEN .F.

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| (nMarcaOK:=1,oDlg:End()) }, {|| (nMarcaOK:=0,oDlg:End()) }) CENTERED


   IF nMarcaOK = 1

      IF nOpRad == 1 .And. !Empty(cPO)
         bBlocSel := {|| RTRIM(Work_SW8->WKPO_NUM ) == RTRIM(cPO)}
      ELSEIF nOpRad == 2 .And. !Empty(cInvoice)
         bBlocSel := {|| RTRIM(Work_SW8->WKINVOICE) == RTRIM(cInvoice)}
      ELSEIF nOpRad == 3 .And. !Empty(cPLI)
         bBlocSel := {|| RTRIM(Work_SW8->WKPGI_NUM) == RTRIM(cPLI)}
      ElseIf nOpRad == 4
         bBlocSel := {|| Empty(Work_SW8->WKNVE) }
      ENDIF

      IF !DI500CrgNVE(cNVE,bBlocSel,.F.)
         MSGSTOP(STR0183) //"Não existem itens compatíveis para essa seleção."
         LOOP
      ELSE
         IF DI500TemNVEOK(.F.)
            Processa({|| DI500GrvNVE(nSelOp,cNVE) })
         ENDIF
      ENDIF

   ENDIF

   EXIT

ENDDO

Work_EIM->(DBSETORDER(1))

RETURN .T.

/*
Funcao      : DI501BoxNVE()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
FUNCTION DI501BoxNVE()

IF(nOpRad=1, oCboPO:ENABLE(), oCboPO:DISABLE()) // Escolheu PO
IF(nOpRad=2,   oInv:ENABLE(),   oInv:DISABLE()) // Escolheu Invoice
IF(nOpRad=3,oCboPLI:ENABLE(),oCboPLI:DISABLE()) // Escolheu PLI

RETURN .T.

/*
Funcao      : DI501GrvNVE()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
FUNCTION DI501GrvNVE(nSelOp,cChave)

LOCAL nCont:=xTotal:=0,lGrvItem:=.F.
lGravaSoCapa:=.F.

ProcRegua( Work_EIM->(EasyRecCount("Work_EIM")) )

IF nSelOp = 4 // Exclui NVE
   IF Work_CEIM->(DBSEEK(cChave))
      IncProc()
      Work_CEIM->(DBDELETE())
      DBSELECTAREA("Work_CEIM")
      PACK
   ENDIF
   DBSELECTAREA("Work_SW8")
   SET FILTER TO
   Work_SW8->(DBSETORDER(5))
   DO WHILE Work_SW8->(DBSEEK(cChave))
      Work_SW8->WKNVE:=""
      Work_SW8->WKADICAO:=""
      Work->(DbSetOrder(3))
      If Work->(DbSeek(Work_SW8->WKPO_NUM+Work_SW8->WKPGI_NUM+Work_SW8->WKPOSICAO)) .AND. !Empty(Work->WK_NVE)
         Work->WK_NVE := ""
      EndIf
   ENDDO
   
   Work_SW8->(DBSETORDER(1))
   DI500Controle(1)

   // SVG - 13/07/09 -
   If ("CTREE" $ RealRDD())
      Work_SW8->(DBEVAL({|| If(&(cFiltroSW8),Work_SW8->WKFILTRO:="S",Work_SW8->WKFILTRO:="")}))
      SET FILTER TO Work_SW8->WKFILTRO == "S"
   Else
      SET FILTER TO &(cFiltroSW8)
   EndIf
ENDIF

lGravaEIM:=.T.
Work_EIM->(DBSETORDER(2)) 
Work_EIM->(DBSEEK(cChave))
lDeletou:=.F.
DO While !Work_EIM->(Eof()) .AND. Work_EIM->EIM_CODIGO == cChave

   IncProc()
// IF nSelOp = 4 .AND. !EMPTY(Work_GEIM->WK_RECNO) // Exclui NVE
//    AADD(aDeletados,{"EIM",Work_GEIM->WK_RECNO})
// ENDIF
   lDeletou:=.T.
   Work_EIM->(DBDELETE())
   //NCF - 09/11/2012 - Para serem verificados no re-carregamento da Work de exibição de NVE
   If aScan(aWkDeletados,{|x|x[1] == "EIM" .And. x[2] == Work_EIM->WK_RECNO}) == 0 .And. Work_EIM->WK_RECNO <> 0
      aAdd(aWkDeletados,{"EIM",Work_EIM->WK_RECNO})
      If nSelOp == 4 .And. aScan(aDeletados,{|x|x[1] == "EIM" .And. x[2] == Work_EIM->WK_RECNO}) == 0
         aAdd(aDeletados,{"EIM",Work_EIM->WK_RECNO})
      EndIf
   EndIf
   lEIMGrava := .T.
   Work_EIM->(dbSkip())

ENDDO
Work_EIM->(DBSETORDER(1))

IF lDeletou
   DBSELECTAREA("Work_EIM")
   PACK
ENDIF

IF nSelOp = 4 // Exclui NVE   //NCF - 09/11/2012
   Work_GEIM->(DBSETORDER(2))
   Work_GEIM->(DBSEEK(cChave))
   lDeletou:=.F.
   DO While !Work_GEIM->(Eof()) .AND. Work_GEIM->EIM_CODIGO == cChave
      IncProc()
      lDeletou:=.T.
      Work_GEIM->(DBDELETE())
      Work_GEIM->(dbSkip())
   ENDDO
   Work_GEIM->(DBSETORDER(1))

   IF lDeletou
      DBSELECTAREA("Work_GEIM")
      PACK
   ENDIF

   RETURN .T.
ENDIF

ProcRegua(Work_GEIM->(EasyReccount("Work_GEIM")))

Work_GEIM->(DBGOTOP())

DO WHILE Work_GEIM->(!EOF())

   IncProc()

	IF Work_GEIM->DBDELETE
		IF !EMPTY(Work_GEIM->WK_RECNO)
			AADD(aDeletados,{"EIM",Work_GEIM->WK_RECNO})
		ENDIF
      
		Work_GEIM->(dbSkip())
		LOOP
	ENDIF

	IF EMPTY(Work_GEIM->(EIM_NIVEL+EIM_ATRIB+EIM_ESPECI))
		Work_GEIM->(dbSkip())
		LOOP
	ENDIF
  
   Work_EIM->(DBAPPEND())

   AVREPLACE("Work_GEIM","Work_EIM")

   Work_EIM->EIM_CODIGO:=cChave
   If lEIM_NCM 
      Work_EIM->EIM_NCM := M->EIJ_TEC
   EndIf
   
   If Empty(Work_GEIM->EIM_CODIGO)           //NCF - 09/11/2012
      Work_GEIM->EIM_CODIGO:=cChave
   EndIf

   If Work_GEIM->WK_RECNO == 0
      Work_EIM->EIM_HAWB := M->W6_HAWB
      Work_EIM->EIM_FASE := "DI"
   EndIf

   lNVEInclui:=.F.
   lGrvItem  :=.T.

   Work_GEIM->(dbSkip())
ENDDO

IF lGrvItem
   IF !Work_CEIM->(DBSEEK(cChave))
      Work_CEIM->(DBAPPEND())
      Work_CEIM->EIM_CODIGO:=cChave
      Work_CEIM->WKTEC     :=M->EIJ_TEC
      Work->(DbSetOrder(3))
      If Work->(DbSeek(Work_SW8->WKPO_NUM+Work_SW8->WKPGI_NUM+Work_SW8->WKPOSICAO)) .AND. Empty(Work->WK_NVE)
         Work->WK_NVE         :=Work_CEIM->EIM_CODIGO
      EndIf
   ENDIF
ENDIF

Work_GEIM->(DBGOTOP())
Work_EIM->(DBGOTOP())

RETURN .T.

/*
Funcao      : DI501CrgNVE()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
FUNCTION DI501CrgNVE(cNVE,bBlocSel,lZap)

DBSELECTAREA("Work_SW8")
SET FILTER TO

ProcRegua(Work_SW8->(EasyReccount("Work_SW8")))
Work_SW8->(DBSETORDER(1))//WKINVOICE+WKFORN+WKPO_NUM+WKPOSICAO+WKPGI_NUM
Work_SW8->(dbGoTop())
lTemItens := .F.
DO While !Work_SW8->(Eof())

   IncProc()

   IF EMPTY(Work_SW8->WKFLAGIV) .OR. EMPTY(Work_SW8->WKINVOICE)
      Work_SW8->(DBSKIP())
      LOOP
   ENDIF

   IF !EVAL(bBlocSel)
      Work_SW8->(DBSKIP())
      LOOP
   ENDIF
      
   If !EMPTY(M->EIJ_TEC) .And. !(AllTrim(M->EIJ_TEC) $ Left(Work_SW8->WKTEC, Len(AllTrim(M->EIJ_TEC))))
      Work_SW8->(DBSKIP())
      LOOP
   ENDIF

   Work_SW8->WKNVE   :=cNVE
   Work_SW8->WKADICAO:=""

   lTemItens := .T.

   Work_SW8->(dbSkip())

ENDDO
IF lTemItens
   DI500Controle(1)
ENDIF

DBSELECTAREA("Work_SW8")
Work_SW8->(DBSETORDER(1))

// SVG - 13/07/09 -
If ("CTREE" $ RealRDD())
   Work_SW8->(DBEVAL({|| If(&(cFiltroSW8),Work_SW8->WKFILTRO:="S",Work_SW8->WKFILTRO:="")}))
   SET FILTER TO Work_SW8->WKFILTRO == "S"
Else
   SET FILTER TO &(cFiltroSW8)
EndIf

DBGOTOP()

Return lTemItens

/*
Funcao      : DI501GEIMGrv()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
FUNCTION DI501GEIMGrv(cNVE)

Local bWhile := {|| !Work_EIM->(Eof()) .AND. Work_EIM->(EIM_HAWB+EIM_NIVEL+EIM_CODIGO) == cChave }
Local bCond  := If( lEIM_NCM , {|| Select("Work_NVE") # 0 .AND. AllTrim(Work_EIM->EIM_NCM) $ Left(Work_NVE->WK_TEC, Len(AllTrim(Work_EIM->EIM_NCM))) }, {|| .T. } )
DBSELECTAREA("Work_GEIM")
//ZAPs
AvZap("Work_GEIM")

cChave := AvKey(M->W6_HAWB,"EIM_HAWB")+AvKey(cClassif,"EIM_NIVEL")+AvKey(cNVE,"EIM_CODIGO")
Work_EIM->(DBSETORDER(4))  //EIM_HAWB+EIM_NIVEL+EIM_CODIGO+EIM_ATRIB+EIM_ESPECI

IF Work_EIM->(DBSEEK(cChave))
   DO While Eval(bWhile) 
      If Eval(bCond)
         Work_GEIM->(DBAPPEND())
         AVREPLACE("Work_EIM","Work_GEIM")
         Work_GEIM->EIM_ALI_WT := "EIM"
         Work_GEIM->EIM_REC_WT := Work_EIM->WK_RECNO
      EndIf
      Work_EIM->(dbSkip())
   ENDDO   
ENDIF
Work_EIM->(DBSETORDER(1))

RETURN .T.

/*
Funcao      : DI501GEIMGrv()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
FUNCTION DI501EIMGrava()
//MFR 23/11/2018
//LOCAL cFilEIM:=xFilial("EIM")
LOCAL cFilEIM:=GetFilEIM("DI")

IF !lTemNVE
   RETURN .F.
ENDIF

EIM->(DBSETORDER(1))
EIM->(DBSEEK(cFilEIM+SW6->W6_HAWB))
/*
DO While !EIM->(Eof()) .AND. SW6->W6_HAWB == EIM->EIM_HAWB   .AND.;
                                  cFilEIM == EIM->EIM_FILIAL .AND. SW6->W6_TIPOFEC == EIM->EIM_FASE 
                                  // MFR 07/12/2018 OSSME-1425
                                  //cFilEIM == EIM->EIM_FILIAL 

   EIM->(RECLOCK("EIM",.F.))
   EIM->(DBDELETE())
   EIM->(MSUNLOCK())
   EIM->(dbSkip())
ENDDO
*/
Work_SW8->(DBSETORDER(5))
Work_EIM->(DBGOTOP())
DO While !Work_EIM->(Eof())
   IF !EMPTY(Work_EIM->EIM_CODIGO) .AND. !Work_SW8->(DBSEEK(Work_EIM->EIM_CODIGO))// Se o codigo estiver em branco pode ser EIM de processo antigo que so tem na adicao
      Work_EIM->(dbSkip())
      LOOP
   ENDIF

   If Work_EIM->WK_RECNO == 0
      EIM->(RECLOCK("EIM",.T.))
      AVREPLACE("Work_EIM","EIM")
      EIM->EIM_FILIAL := cFilEIM
      EIM->EIM_HAWB   := M->W6_HAWB
      EIM->EIM_ADICAO := If(Empty(Work_EIM->EIM_ADICAO),Work_SW8->WKADICAO,Work_EIM->EIM_ADICAO)
      //NCF - 08/08/2011 - Classificação N.V.A.E na PLI
      If lCposNVEPLI
         EIM->EIM_FASE := "DI"
      EndIf
      EIM->(MSUNLOCK())
   Else
      EIM->(DBGOTO(Work_EIM->WK_RECNO))
      EIM->(RECLOCK("EIM",.F.))
      AVREPLACE("Work_EIM","EIM")
      EIM->EIM_ADICAO := If(Empty(Work_EIM->EIM_ADICAO),Work_SW8->WKADICAO,Work_EIM->EIM_ADICAO)
      EIM->(MSUNLOCK())      
   EndIf
   
   Work_EIM->(dbSkip())
ENDDO
Work_SW8->(DBSETORDER(1))

RETURN  .T.

/*
Funcao      : DI501TstCpoPeso()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
// AWR - N.V.A.E - 16/10/2004 /\/\/\
FUNCTION DI501TstCpoPeso()

LOCAL aCpos:={"B1_PESO","EIJ_PESOL","W5_PESO","W7_PESO","W6_PESOL","W7_PESOMID","A5_PESOMID"},C
LOCAL nTam:=AVSX3("B1_PESO",3),lDiferente:=.F.
LOCAL nDec:=AVSX3("B1_PESO",4),cCampos:=""
LOCAL lTesta:=EasyGParam("MV_MENPESO",,.T.)
IF !lTesta
   RETURN .T.
ENDIF
cCampos:="  Campos    -  Tam  -  Dec"+CHR(13)+CHR(10)
SX3->(DBSETORDER(2))
FOR C := 1 TO LEN(aCpos)
    IF SX3->(DBSEEK(aCpos[C]))
       IF aCpos[C] == "EIJ_PESOL" .OR. aCpos[C] == "W6_PESOL"
          IF nDec > SX3->X3_DECIMAL
             lDiferente:=.T.
          ENDIF
       ELSE
          IF nTam > SX3->X3_TAMANHO .OR. nDec > SX3->X3_DECIMAL
             lDiferente:=.T.
          ENDIF
       ENDIF
       cCampos+=SX3->X3_CAMPO+"  -  "+STR(SX3->X3_TAMANHO,3)+"  -  "+STR(SX3->X3_DECIMAL,1)+CHR(13)+CHR(10)
    ENDIF
NEXT
SX3->(DBSETORDER(1))
IF lDiferente
   IF !MSGYESNO("Os seguintes campos de peso estao com tamanho e decimais diferentes:"+CHR(13)+CHR(10)+cCampos+CHR(13)+CHR(10)+;
                "Essas diferencas podem gerar problemas nos rateios dos pesos."+CHR(13)+CHR(10)+;
                "DESEJA VISUALIZAR ESSA MENSAGEM NOVAMENTE?","Parametro: MV_MENPESO")
      
      PutMV("MV_MENPESO","F")

   ENDIF
   RETURN .F.
ENDIF
RETURN .T.

/*
Funcao      : DI501RatFrete()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
FUNCTION DI501RatFrete()

/*
Alterações : Leandro Diniz de Brito - 21/06/2006 - Rateio do valor do seguro da DA para a DI de nacionalização
*/
LOCAL aPos:={}
LOCAL nRecno_SW6:=SW6->(RECNO())
LOCAL I
LOCAL aTaxaDA:={},aSW8:={},nPos,aOrd:=SaveOrd({"Work_SW8","Work_SW9","SW8","SW9"})
// SVG 22/12/2008
PRIVATE aDaFrete:={}
PRIVATE nValSeguro := 0
SW2->(DBSETORDER(1))
SW6->(DBSETORDER(1))
SW9->(DbSetOrder(3))

/* LDB 21/06/2006 - Guarda taxas das invoices da DA */
Work->(DbGoTop())
While Work->(!Eof())

   If Empty(Work->WKFLAGWIN)
      Work->(DbSkip())
      Loop
   EndIf

   SW2->(DbSeek(xFilial("SW2")+Work->WKPO_NUM))
   SW6->(DbSeek(xFilial("SW6")+SW2->W2_HAWB_DA))

   If Ascan(aPos,SW2->W2_HAWB_DA) == 0
      Aadd(aPos,SW2->W2_HAWB_DA)

      SW9->(DbSeek(xFilial("SW9")+SW2->W2_HAWB_DA))

      While SW9->(!Eof()) .And. SW9->(W9_FILIAL+W9_HAWB) == (xFilial("SW9")+SW2->W2_HAWB_DA)
         If (nPos:=Ascan(aTaxaDA,{|TAXA|TAXA[1]+TAXA[2] == SW2->W2_HAWB_DA + SW9->W9_MOE_FOB }) ) == 0
            Aadd(aTaxaDA,{SW2->W2_HAWB_DA,SW9->W9_MOE_FOB,SW9->W9_TX_FOB})
         EndIf
         SW9->(DbSkip())
      EndDo

   EndIf

   Work->(DbSkip())

EndDo

/* LDB 21/06/2006 - Acumula total de cada item do desembaraço em Reais */
Work_SW9->(DbGoTop())
Work_SW8->(DbSetOrder(1)) // INVOICE+FORNECEDOR
While Work_SW9->(!Eof())

   Work_SW8->(DbSeek(Work_SW9->(W9_INVOICE+W9_FORN)+EICRetLoja("Work_SW9", "W9_FORLOJ")))


   While Work_SW8->(!Eof()) .And. Work_SW8->(WKINVOICE+WKFORN) == Work_SW9->(W9_INVOICE+W9_FORN) .And. (!EICLoja() .Or. EICRetLoja("Work_SW8", "W8_FORLOJ") == EICRetLoja("Work_SW9", "W9_FORLOJ"))

      SW2->(DBSEEK(xFilial("SW2")+Work_SW8->WKPO_NUM))

      nTaxa := Work_SW9->W9_TX_FOB

      If (nPos :=  Ascan(aTaxaDA,{|TAXA|TAXA[1]+TAXA[2] == SW2->W2_HAWB_DA + Work_SW9->W9_MOE_FOB }) ) > 0
         nTaxa := aTaxaDA[nPos][3]
      EndIf
      If (nPos:=Ascan(aSW8,{ |CHAVE| CHAVE[1]==Work_SW8->(WKPO_NUM+WKPGI_NUM+WKPOSICAO) }) ) == 0
         AADD(aSW8,{Work_SW8->(WKPO_NUM+WKPGI_NUM+WKPOSICAO) ,;
                    Work_SW8->(WKPRECO*WKQTDE)*nTaxa})
      Else
         aSW8[nPos][2] += Work_SW8->(WKPRECO*WKQTDE)*nTaxa
      EndIf

      Work_SW8->(DbSkip())

   EndDo

   Work_SW9->(DbSkip())

EndDo

aPOS:={}
WORK->(DBGOTOP())
DO WHILE WORK->(!EOF())

   IF EMPTY(WORK->WKFLAGWIN)
      WORK->(DBSKIP())
      LOOP
   ENDIF
   nFobReais := 0
   If (nPos:=Ascan(aSW8,{|ITEM| ITEM[1] == Work->(WKPO_NUM+WKPGI_NUM+WKPOSICAO)}) ) > 0
      nFobReais := aSW8[nPos][2]
   EndIf
   IF (nPos:=ASCAN(aPOS,WORK->WKPO_NUM)) == 0
     AADD(aPOS,WORK->WKPO_NUM)

     SW2->(DBSEEK(xFilial("SW2")+WORK->WKPO_NUM))
     SW6->(DBSEEK(xFilial("SW6")+SW2->W2_HAWB_DA))

     AADD(aDaFrete,{SW2->W2_HAWB_DA,;
     				SW6->W6_VLFRECC,;
     				SW6->W6_PESOL,;
     				WORK->WKQTDE*WORK->WKPESO_L,;
     				SW6->W6_VLFREPP,;
     				SW6->W6_VLFRETN,;
     				SW6->W6_FOB_TOT,;  // Total Fob
     				nFobReais,;        // Valor Reais do item
     				SW6->W6_VL_USSE})  // Valor do Seguro da DA

   ELSE
      aDaFrete[nPos,4]+=WORK->WKQTDE*WORK->WKPESO_L
      aDaFrete[nPos,8]+=nFobReais
   ENDIF
   WORK->(DBSKIP())
ENDDO

nValFreCC:=0
nValFrePP:=0
nValFreTN:=0
nValSeguro:=0
FOR I:=1 TO LEN(aDaFrete)
   nValFreCC+=(aDaFrete[I,4]/aDaFrete[I,3])*aDaFrete[I,2]
   nValFrePP+=(aDaFrete[I,4]/aDaFrete[I,3])*aDaFrete[I,5]
   nValFreTN+=(aDaFrete[I,4]/aDaFrete[I,3])*aDaFrete[I,6]
   nValSeguro += (aDaFrete[I,8]/aDaFrete[I,7])*aDaFrete[I,9]
   If(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"RATEIO_SEGURO"),)// SVG 22/12/2008
NEXT

M->W6_VLFRECC  := nValFreCC
M->W6_VLFREPP  := nValFrePP
M->W6_VLFRETN  := nValFreTN
M->W6_VL_USSE  := nValSeguro
M->W6_VLSEGMN  := nValSeguro*M->W6_TX_SEG

WORK->(DBGOTOP())
SW6->(DBGOTO(nRecno_SW6))
RestOrd(aOrd,.T.)
MsgInfo(STR0184,STR0053)  //"Rateio concluído" //STR0053 "Aviso"

Return .T.

/*
Funcao      : DI501AUTPCDI()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
Function DI501AUTPCDI()

Local lRet
Static lAUTPCDI

If ValType(lAUTPCDI) == "U"

   lRet := (EasyGParam("MV_AUTPCDI",,.F.) .AND. ;
   SW8->(FIELDPOS("W8_REG_PC")) # 0 .AND. SW8->(FIELDPOS("W8_FUN_PC")) # 0 .AND. SW8->(FIELDPOS("W8_FRB_PC")) # 0 .AND. SW8->(FIELDPOS("W8_VLDEPIS")) # 0 .AND. ;
   SW8->(FIELDPOS("W8_VLDECOF")) # 0 .AND. EIJ->(FIELDPOS("EIJ_REG_PC")) # 0 .AND. EIJ->(FIELDPOS("EIJ_FUN_PC")) # 0 .AND. EIJ->(FIELDPOS("EIJ_PRB_PC")) # 0 .AND. ;
   EIJ->(FIELDPOS("EIJ_FRB_PC")) # 0 .AND. EIJ->(FIELDPOS("EIJ_REDPIS")) # 0 .AND. EIJ->(FIELDPOS("EIJ_TPAPIS")) # 0 .AND. EIJ->(FIELDPOS("EIJ_ALAPIS")) # 0 .AND. ;
   EIJ->(FIELDPOS("EIJ_QTUPIS")) # 0 .AND. EIJ->(FIELDPOS("EIJ_UNUPIS")) # 0 .AND. EIJ->(FIELDPOS("EIJ_ALUPIS")) # 0 .AND. EIJ->(FIELDPOS("EIJ_BASPIS")) # 0 .AND. ;
   EIJ->(FIELDPOS("EIJ_BR_PIS")) # 0 .AND. EIJ->(FIELDPOS("EIJ_VLDPIS")) # 0 .AND. EIJ->(FIELDPOS("EIJ_VLRPIS")) # 0 .AND. EIJ->(FIELDPOS("EIJ_REDCOF")) # 0 .AND. ;
   EIJ->(FIELDPOS("EIJ_TPACOF")) # 0 .AND. EIJ->(FIELDPOS("EIJ_ALACOF")) # 0 .AND. EIJ->(FIELDPOS("EIJ_QTUCOF")) # 0 .AND. EIJ->(FIELDPOS("EIJ_UNUCOF")) # 0 .AND. ;
   EIJ->(FIELDPOS("EIJ_ALUCOF")) # 0 .AND. EIJ->(FIELDPOS("EIJ_BASCOF")) # 0 .AND. EIJ->(FIELDPOS("EIJ_BR_COF")) # 0 .AND. EIJ->(FIELDPOS("EIJ_VLDCOF")) # 0 .AND. ;
   EIJ->(FIELDPOS("EIJ_VLRCOF")) # 0 )

   SX2->(DBSETORDER(1))

   IF SX2->(DBSEEK("SJY"))
      lRet := lRet .AND. SJY->(FIELDPOS("JY_CODIGO")) # 0 .AND. SJY->(FIELDPOS("JY_DESC")) # 0 .AND. SJY->(FIELDPOS("JY_REGTRI1")) # 0 .AND. ;
                         SJY->(FIELDPOS("JY_REGTRI2")) # 0 .AND. SJY->(FIELDPOS("JY_REGTRI3")) # 0 .AND. SJY->(FIELDPOS("JY_REGTRI4")) # 0
   Else
      lRet := .F.
   Endif

   IF SX2->(DBSEEK("SJZ"))
      lRet := lRet .AND. SJZ->(FIELDPOS("JZ_CODIGO")) # 0 .AND. SJZ->(FIELDPOS("JZ_DESC")) # 0 .AND. SJZ->(FIELDPOS("JZ_NCM")) # 0 .AND. ;
                         SJZ->(FIELDPOS("JZ_PERRED")) # 0 .AND. SJZ->(FIELDPOS("JZ_INIVIG")) # 0 .AND. SJZ->(FIELDPOS("JZ_FIMVIG")) # 0
   Else
      lRet := .F.
   Endif

   IF GETNEWPAR("MV_TEM_DSI",.F.)
       IF SX2->(DBSEEK("SJW"))
	      lRet := lRet .AND. SJW->(FIELDPOS("JW_REG_PC")) # 0
	   Else
	      lRet := .F.
	   Endif

	   IF SX2->(DBSEEK("EIV"))
	      lRet := lRet .AND. EIV->(FIELDPOS("EIV_NATOPE")) # 0 .AND. EIV->(FIELDPOS("EIV_REG_PC")) # 0 .AND. EIV->(FIELDPOS("EIV_FUN_PC")) # 0
	   Else
	      lRet := .F.
	   Endif
   Endif
   lAUTPCDI := lRet
Else
   lRet := lAUTPCDI
EndIf
Return lRet

/*
Função..: DI501TotReg
Autor...: Thiago Rinaldi Pinto - TRP
Data....: 28/09/07
Objetivo: Retornar o Numero de Registros de uma tabela
Parâmetros: cOpcao-> Define se os itens a serem contados são do Pedido ou da LI.
Observação: Função migrada do programa EICDI500
*/
Function DI501TotReg(cOpcao)
Local nTotalReg
Local cQuery     := ""
Local cPosicoes := "'"

If cOpcao == "PLI"
   aEval(aPLI,{|x,y| cPosicoes += x + iIF(y == Len(aPLI),"'","','")})
Else
   aEval(aPedido,{|x,y| cPosicoes += x + iIF(y == Len(aPedido),"'","','")})
Endif

If Select("TOTALREG") > 0
   TOTALREG->( dbCloseArea() )
Endif

cFrom    := RetSqlName("SW5")+" SW5 "

If cOpcao == "PLI"
   cWhere   := iIF( TcSrvType()=="AS/400"," SW5.@DELETED@ <> '*' "," SW5.D_E_L_E_T_ <> '*'" ) + " AND SW5.W5_FILIAL = '"+cFilSW5+"' "+;
                              "AND SW5.W5_PGI_NUM IN ("+cPosicoes+")
Else
   cWhere   := iIF( TcSrvType()=="AS/400"," SW5.@DELETED@ <> '*' "," SW5.D_E_L_E_T_ <> '*'" ) + " AND SW5.W5_FILIAL = '"+cFilSW5+"' "+;
                              "AND SW5.W5_PO_NUM IN ("+cPosicoes+")
Endif

//Total de Registros
cQuery := " SELECT COUNT(*) AS TOTAL FROM " + cFrom + " WHERE " + cWhere

dbUseArea( .t., "TopConn", TCGenQry(,,cQuery),"TOTALREG", .F., .F. )

nTotalReg:= TOTALREG->TOTAL

TOTALREG->( dbCloseArea() )

DBSELECTAREA("SW5")
Return nTotalReg
/*
Função..: DI501DtTxInv
Autor...: Thiago Rinaldi Pinto - TRP
Data....: 31/10/07
Objetivo: Retornar a data referência para buscar a taxa de conversão a ser utilizada.
Parâmetros: Nenhum
Retorno: cRetorno->Data Referência
Observação: função migrada do programa EICDI500
*/
*----------------------------------------------------*
Function DI501DtTxInv()
*----------------------------------------------------*
Local cParam:= ""
Local cRetorno:= ""

cParam:= EasyGParam("MV_DTTAXA",,"dDataBase")

If Type(cParam) == "D"
   If !Empty(M->W6_DT_EMB)
      cRetorno:= &(cParam)
   Else
      cRetorno:= dDataBase
   Endif
Else
   MsgAlert(STR0185,) //"Conteúdo do parâmetro MV_DTTAXA inválido!"
   cRetorno:= dDataBase
Endif

Return cRetorno

/*
Função..: DI501ConvQtdeRat
Autor...: Thiago Rinaldi Pinto - TRP
Data....: 16/04/08
Objetivo: Converter quantidades a partir da unidade de medida da NCM utilizada na adição, afim de se efetuar o rateio correto das quantidades para cálculo dos impostos.
Parâmetros: cAlias , nQtdeTot-> Soma das quantidades convertidas dos itens, utilizada no rateio. (Ponteiro)
Retorno: aConvVal->Array com as quantidades convertidas.
Observação: função migrada do program EICDI500
*/
*----------------------------------------------------*
Function DI501ConvQtdeRat(cAlias,nQtdeTot)
*----------------------------------------------------*
Local nRecnoAdic:= 0
Local aConvVal:= {}
Local cAdicaoQtde:= DI500Block(cAlias,"EIJ_ADICAO")
Local nOldRec := Work_SW8->(RecNo())
Local nOldOrd := Work_SW8->(IndexOrd())

Work_SW8->(DBSETORDER(4))
Work_SW8->(DBSEEK(cAdicaoQtde))

DO WHILE Work_SW8->(!EOF()) .AND.;
         Work_SW8->WKADICAO == cAdicaoQtde

   nQtdeEsta:=0
   DI500QtdeEsta()

   nRecnoAdic:= Work_SW8->(RECNO())

   Aadd(aConvVal,{nQtdeEsta,nRecnoAdic})

   nQtdeTot+= nQtdeEsta


   Work_SW8->(DBSKIP())

Enddo

Work_SW8->(dbSetOrder(nOldOrd))
Work_SW8->(dbGoTo(nOldRec))
Return aConvVal

*----------------------------------------------------*
Function DI501RetVal(cTot,cArea,lDesp,lConv,lConsidIn327)
// cTot := string que indica se é total do FOB do item(ITEM_INV) ou da invoice total (TOT_INV). Caso não seja para considerar o FOB, enviar a string(SEM_FOB)
// cArea := string que indica se pega de variável de memoria (MEMO), de Work (WORK) ou da tabela (TAB)
// lDesp := var lógica que indica se deve somar as despesas da invoice (.T.)
// lConv := var lógica que indica se deve converter em reais o valor apurado
// lConsidIn327 := var lógica que indica se será considerado o parâmetro MV_IN327
// Elizabete de Oliveira Brito - 20/05/08
//Revisão: Thiago Rinaldi Pinto - 09/09/08 (Criação do parâmetro lConsidIn327)
//Observação: função migrada do programa EICDI500
*----------------------------------------------------*
Local aOrdSW3 := {} //LGS-04/02/2016
Private nFobTot := 0
Private lIn327  := EasyGParam("MV_IN327" ,,.F.)
DEFAULT lConv := .F.
DEFAULT lConsidIn327 := .F.
Private cTotPrm := cTot
Private cAreaPrm := cArea
Private lDespPrm := lDesp
Private lConvPrm := lConv
Private lConsidIn327Prm := lConsidIn327

IF cPaisLoc # "BRA" // EOB - 03/06/08 - desvio para localizações
   nTotFob := DI600RetVal(cTot,cArea,lDesp,lConv )
   RETURN nTotFob
ENDIF

lSegInc := SW9->(FIELDPOS("W9_SEGINC")) # 0 .AND. SW9->(FIELDPOS("W9_SEGURO")) # 0 .AND.;
           SW8->(FIELDPOS("W8_SEGURO")) # 0 .AND. SW6->(FIELDPOS("W6_SEGINV")) # 0 // EOB - 20/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)

If EasyEntryPoint("EICDI500")
   ExecBlock("EICDI500",.F.,.F.,"INI_DI500RETVAL")
EndIf

cTot  := cTotPrm
cArea := cAreaPrm
Desp  := lDespPrm
lConv := lConvPrm
lConsidIn327 := lConsidIn327Prm

IF "TOT_INV" $ cTot
   IF cArea == "MEMO"
      IF !("SEM_FOB" $ cTot)
         nFobTot := M->W9_FOB_TOT
      ENDIF
      IF lDesp
         nFobTot += M->W9_INLAND+M->W9_PACKING+M->W9_OUTDESP- IF(lConsidIn327,IF(!lIn327,M->W9_DESCONT,0),IF(!lIn327,M->W9_DESCONT,0))  // GFP - 12/05/2015
         IF M->W9_FREINC $ cNao .AND. AvRetInco(M->W9_INCOTERM,"CONTEM_FRETE")/*FDR - 27/12/10*/  //M->W9_INCOTERM $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP"
            nFobTot += M->W9_FRETEIN
         ENDIF
         IF lSegInc .AND. M->W9_SEGINC $ cNao .AND. AvRetInco(M->W9_INCOTERM,"CONTEM_SEG")/*FDR - 27/12/10*/  //M->W9_INCOTERM $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP"
            nFobTot += M->W9_SEGURO
         ENDIF
      ENDIF
   ELSEIF cArea == "WORK"
      IF !("SEM_FOB" $ cTot)
         nFobTot := Work_SW9->W9_FOB_TOT
      ENDIF
      IF lDesp
         nFobTot += Work_SW9->W9_INLAND+Work_SW9->W9_PACKING+Work_SW9->W9_OUTDESP- IF(lConsidIn327,IF(!lIn327,Work_SW9->W9_DESCONT,0),IF(!lIn327,Work_SW9->W9_DESCONT,0))  // GFP - 12/05/2015
         IF Work_SW9->W9_FREINC $ cNao .AND. AvRetInco(Work_SW9->W9_INCOTERM,"CONTEM_FRETE")/*FDR - 27/12/10*/  //Work_SW9->W9_INCOTERM $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP"
            nFobTot += Work_SW9->W9_FRETEIN
         ENDIF
         IF lSegInc .AND. Work_SW9->W9_SEGINC $ cNao .AND. AvRetInco(Work_SW9->W9_INCOTERM,"CONTEM_SEG")/*FDR - 27/12/10*/  //Work_SW9->W9_INCOTERM $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP"
            nFobTot += Work_SW9->W9_SEGURO
         ENDIF
      ENDIF
      IF lConv
         nFobTot := DI500TRANS(nFobTot * Work_SW9->W9_TX_FOB)
      ENDIF
   ELSEIF cArea == "TAB"
      IF !("SEM_FOB" $ cTot)
         nFobTot := SW9->W9_FOB_TOT
      ENDIF
      IF lDesp
         nFobTot += SW9->W9_INLAND+SW9->W9_PACKING+SW9->W9_OUTDESP- IF(lConsidIn327,IF(!lIn327,SW9->W9_DESCONT,0),IF(!lIn327,SW9->W9_DESCONT,0))  // GFP - 12/05/2015
         IF SW9->W9_FREINC $ cNao .AND. AvRetInco(SW9->W9_INCOTERM,"CONTEM_FRETE")/*FDR - 27/12/10*/  //SW9->W9_INCOTERM $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP"
            nFobTot += SW9->W9_FRETEIN
         ENDIF
         IF lSegInc .AND. SW9->W9_SEGINC $ cNao .AND. AvRetInco(SW9->W9_INCOTERM,"CONTEM_SEG")/*FDR - 27/12/10*/  //SW9->W9_INCOTERM $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP"
            nFobTot += SW9->W9_SEGURO
         ENDIF
      ENDIF
      IF lConv
         nFobTot := DI500TRANS(nFobTot * SW9->W9_TX_FOB)
      ENDIF
   ENDIF
ELSE
   IF cArea == "WORK"
      IF !("SEM_FOB" $ cTot)
         nFobTot := Work_SW8->WKPRECO*Work_SW8->WKQTDE
      ENDIF
      IF lDesp
         nFobTot += Work_SW8->WKINLAND+Work_SW8->WKPACKING+Work_SW8->WKOUTDESP- IF(lConsidIn327,IF(!lIn327,Work_SW8->WKDESCONT,0),IF(!lIn327,Work_SW8->WKDESCONT,0))  // GFP - 12/05/2015
         IF Work_SW9->W9_FREINC $ cNao .AND. AvRetInco(Work_SW9->W9_INCOTERM,"CONTEM_FRETE")/*FDR - 27/12/10*/  //Work_SW9->W9_INCOTERM $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP" // AST - 20/02/09 - Inclusão do tratamento para somar o campo W8_FRETEIN somente para os incoterms corretos
            nFobTot += Work_SW8->WKFRETEIN
         ENDIF      //NCF - 03/10/2011 - Verificar também a flag e o incoterm na Invoice
         IF lSegInc .AND. Work_SW9->W9_SEGINC $ cNao .AND. AvRetInco(Work_SW9->W9_INCOTERM,"CONTEM_SEG")
            nFobTot += Work_SW8->WKSEGURO
         ENDIF
      ENDIF
      IF lConv
         nFobTot := DI500TRANS(nFobTot * Work_SW9->W9_TX_FOB)
      ENDIF
   ELSEIF cArea == "TAB"
      IF !("SEM_FOB" $ cTot)
         nFobTot := SW8->W8_PRECO*SW8->W8_QTDE
      ENDIF
      IF lDesp
         nFobTot += SW8->W8_INLAND+SW8->W8_PACKING+SW8->W8_OUTDESP-IF(lConsidIn327,IF(!lIn327,SW8->W8_DESCONT,0),IF(!lIn327,SW8->W8_DESCONT,0))  // GFP - 12/05/2015
         IF SW9->W9_FREINC $ cNao .AND. AvRetInco(SW9->W9_INCOTERM,"CONTEM_FRETE")/*FDR - 27/12/10*/  //SW9->W9_INCOTERM $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP" // AST - 20/02/09 - Inclusão do tratamento para somar o campo W8_FRETEIN somente para os incoterms corretos
            nFobTot += SW8->W8_FRETEIN
         ENDIF      //NCF - 03/10/2011 - Verificar também a flag e o incoterm na Invoice
         IF lSegInc .AND. SW9->W9_SEGINC $ cNao .AND. AvRetInco(SW9->W9_INCOTERM,"CONTEM_SEG")
            nFobTot += SW8->W8_SEGURO
         ENDIF
      ENDIF
      IF lConv
         nFobTot := DI500TRANS(nFobTot * SW9->W9_TX_FOB)
      ENDIF
   ELSEIF cArea == "TABPR" //LGS-04/02/2016
      aOrdSW3 := SaveOrd({"SW3","SW2"})

      SW2->(DbSetOrder(1))
      SW3->(DbSetOrder(8))

      SW2->(DbSeek(xFilial("SW2") + SW8->W8_PO_NUM ))
      SW3->(DbSeek(xFilial("SW3") + SW8->W8_PO_NUM + SW8->W8_POSICAO ))

      IF !("SEM_FOB" $ cTot)
         nFobTot := SW3->W3_PRECO * SW8->W8_QTDE
      ENDIF
      IF lDesp

         nFobTot += If( SW3->(FieldPos("W3_INLAND" )) > 0, SW3->W3_INLAND , 0) +;
                    If( SW3->(FieldPos("W3_PACKING")) > 0, SW3->W3_PACKING, 0) +;
                    If( SW3->(FieldPos("W3_OUT_DES")) > 0, SW3->W3_OUT_DES, 0) -;
                    If(!lIn327, If( SW3->(FieldPos("W3_DESCONT" )) > 0, SW3->W3_DESCONT, 0), 0)

         IF SW2->W2_FREINC $ cNao .AND. AvRetInco(SW2->W2_INCOTER,"CONTEM_FRETE")
            nFobTot += If( SW3->(FieldPos("W3_FRETE")) > 0, SW3->W3_FRETE, 0)
         ENDIF
         IF SW2->(FieldPos("W2_SEGINC" )) > 0
            IF SW2->(FieldPos("W2_SEGINC" )) > 0 .AND. SW2->W2_SEGINC $ cNao .AND. AvRetInco(SW2->W2_INCOTER,"CONTEM_SEG")
               nFobTot += If( SW3->(FieldPos("W3_SEGURO")) > 0, SW3->W3_SEGURO, 0)
            ENDIF
         ENDIF
      ENDIF
      IF lConv
         nFobTot := DI500TRANS(nFobTot * BuscaTaxa(SW2->W2_MOEDA,SW2->W2_PO_DT,.T.,.F.,.T.))
      ENDIF
      RestOrd(aOrdSW3,.T.)
   ENDIF
ENDIF

If EasyEntryPoint("EICDI500")
   ExecBlock("EICDI500",.F.,.F.,"FIM_DI500RETVAL")
EndIf

RETURN nFobTot

/*
Funcao      : DI501Proc2XLS()
Parâmetros  :
Retorno     :
Objetivos   : Exportar um conjunto de dados para uma planilha
Autor       :
Data 	      :
Obs         : 
Revisão     :
*/
Function DI501Proc2XLS(cAlias,nReg)
Local nValid := DI501XLSVld(cAlias,nReg)
Do Case
   Case nValid ==1
        expNFEExcel((cAlias)->W6_HAWB,nValid)        
   Case nValid == 2     
         if !SWV->(dbSeek(xFilial("SWV")+(cAlias)->W6_HAWB))
           EasyHelp(STR0291,STR0285,STR0292) //'Processo sem itens da DUIMP informado','AVISO','Entre na opçao Itens DUIMP em outras ações do Desembaraço'
         else
           expNFEExcel((cAlias)->W6_HAWB,nValid)        
         EndIf
EndCase
//Quando nValid ==3 não gera a planilha
return        

/*
Funcao      : DI501XLSVld()
Parâmetros  :
Retorno     : 1= Executar no modelo antigo, 2=Executar no modelo novo, 3=não executar
Objetivos   :
Autor       : Maurício Frison
Data 	      : Setembro 2022
*/   
function DI501XLSVld(cAlias,nReg)
Local nRetorno := 3
Default cAlias:=''
Default nReg := 0
   If !empty(cAlias) .And. nReg > 0
      (cAlias)->(dbGoTo(nReg))
   EndIf   
   If AvFlags("DUIMP") .AND. SW6->W6_TIPOREG == "2" //processo tipo DUIMP
      If SW6->W6_FORMREG == "1"  //Duimp do tipo Integrada
         EasyHelp(STR0289,STR0285,STR0290) //"A operação não pode prosseguir para processos do tipo DUIMP com a forma de registro Integrado". "Opção disponível para processos do tipo DUIMP com a forma de registro Manual.
      else
         nRetorno := 2
      EndIf      
   Else  // então o processo é tipo DI
      IF EasyGParam("MV_TEM_DI",.F.)
         EasyHelp(STR0287,STR0285,STR0288) //A operação não pode prosseguir para processos do tipo DI Eletrônica. AVISO. Opção disponível para processos do tipo DI quando a integração com o Siscomex (MV_TEM_DI) estiver desabilitada
      else  
         nRetorno := 1
      endIf
   EndIf  
return nRetorno

/*
Funcao      : DI501ValidInv()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
//DRL
Function DI501ValidInv()

LOCAL   lRet := .T.
LOCAL   aOrd:=SaveOrd({"WORK","EW4","EW5","SW5","SW3"}),nPos,aPgi,nPo,j
LOCAl   cxMsg:=""
Local   cQry
Local nSaldoAux := 0
PRIVATE	bOk_:={{||If(ValPliSel(),(LRET:=.T.,GRVAPLISEL(),ODLGBAR:End()),)},"OK"},;
			bCancel_:={||ODLGBAR:End()}
PRIVATE	ODLGBAR,AHEADER:={},ACAMPOS,oMark_
PRIVATE	oBtOk,oBtCan
EW4->(DbSetOrder(1))
EW5->(DbSetOrder(1))

Begin Sequence
	IF Len(cInv) < LEN(SW8->W8_INVOICE)
		//cInv:= cInv+SPACE(LEN(SW8->W8_INVOICE)-LEN(cInv))
		cInv:= AvKey(cInv,"W8_INVOICE")
	EndIf
	If Empty(cInv) .OR. (aScan(aInv,cInv) # 0)
		lRet := .T.
		Break
	EndIf
	If !EW4->(dbSeek(xFilial("EW4")+cInv))
		MsgInfo(STR0186,STR0001) //"Invoice antecipada nao encontrada." //STR0001 "Atenção"
		lRet := .F.
		Break
	EndIf
	EW5->(dbSeek(xFilial("EW5")+AvKey(cInv,"EW5_INVOIC")))
	WORK_SW9->(DbSetOrder(1))
	If WORK_SW9->(dbSeek(EW5->EW5_INVOIC))
		MsgInfo(STR0187,STR0001) //"Esta invoice ja existe no processo." //STR0001 "Atenção"
		lRet := .F.
		Break
	EndIf
	
   SW9->(dbSetOrder(1)) //W9_FILIAL, W9_INVOICE, W9_FORN, W9_FORLOJ, W9_HAWB
   If SW9->(dbSeek(xFilial("SW9") + cInv + EW4->EW4_FORN + EW4->EW4_FORLOJ))
      MsgInfo(STR0286,STR0001) //"Invoice já utilizada em outro processo" //STR0001 "Atenção"
      lRet := .F.
      Break
   EndIf

   //
	cxMsg	:= STR0196 //"O(s) produto(s) abaixo desta Invoice não possui(em) a sua quantidade total liberada para o embarque. Favor verificar as PLI´s correspendentes para que o seu processo de embarque seja liberado!"
	If	!VrfSldInvAnt(@cxMsg)
		EECView(cxMsg,STR0001) //STR0001 := "Atenção"
		lRet := .F.
		Break
	EndIf

   If Empty(EW4->EW4_COND_P)
		MsgInfo(STR0280 + ENTER + STR0281,STR0001) //"Esta Invoice Antecipada não possui Condição de Pagamento. Para que possa ser utilizada, deve ser informada uma Condição de pagamento para a Invoice Antecipada." //STR0001 "Atenção"
		lRet := .F.
		Break
	EndIf

	/* THTS - 30/12/2021 - NOPADO, pois ao refazer este array, quando tenta montar novamente a tela de itens, usa um array com mesmo nome e dava error.log. Neste ponto, nao encontrei onde este array esta sendo utilizado
	aCamposItem:={}
	AADD(aCamposItem,{"WKFLAGWIN",,""})
	AADD(aCamposItem,{"WKPLI"    ,,"PLI"        ,""})
	AADD(aCamposItem,{"PO_NUM"   ,,STR0178      ,""})                //"Pedido"
	AADD(aCamposItem,{"WKQTD_PLI",,STR0225      ,"999999999.99999"}) //"Qtd. PLI
	AADD(aCamposItem,{"QTD_SLA"  ,,STR0198      ,"999999999.99999"}) //"Qtd. Selecionada"
	AADD(aCamposItem,{"QTD_SEL"  ,,STR0199      ,"999999999.99999"}) //"Qtd. a Selecionar"
	AADD(aCamposItem,{"INVOIC"   ,,STR0200      ,""})                //"Invoice Selecionada"
	AADD(aCamposItem,{"ITEM"     ,,STR0201      ,""})                //"Cod. Produto"
	*/
	SW5->(DbSetorder(8))
	SW3->(DbSetOrder(8))
	EW5->(DbSeek(xFilial("EW5")+AvKey(cInv,"EW5_INVOIC")))
	aPo:={}

   //MFR 16/09/2021 OSSME-6184

   cQry := "SELECT EW5.EW5_PO_NUM "
   cQry +="FROM " + RetSqlName("EW5") + "  EW5 "
   cQry +=" WHERE"
   cQry +=" EW5.EW5_FILIAL= '" + xFilial("EW5") + "' AND "
   cQry += "EW5.D_E_L_E_T_ = ' ' AND " 
   cQry +=" EW5.EW5_INVOIC = '" + cInv + "' "
   cQry +=" GROUP BY EW5.EW5_PO_NUM "

   cQry:=ChangeQuery(cQry)
   dbUseArea( .T., "TopConn", TCGenQry(,,cQry), "cTrbEW5", .T., .T. )

   dO While cTrbEw5->(!EOF())
      Aadd(aPo,cTrbEW5->EW5_PO_NUM)
      cTrbEw5->(DbSkip())
   EndDo
   cTrbEw5->(dbCloseArea())

/*
	WHILE EW5->(!EOF()) .AND. EW5->EW5_INVOIC==cInv
		If Ascan(aPo,EW5->EW5_PO_NUM)==0
			Aadd(aPo,EW5->EW5_PO_NUM)
		EndIf
		EW5->(DbSkip())
	EndDo
*/   

	nPos := 0;aPgi:={}
	For nPo:=1 To Len(aPo)
		SW3->(DbSeek(xFilial("SW3")+aPo[nPo]))
      //select na sw3 onde seq <> 0
		WHILE SW3->(!EOF()) .AND. SW3->W3_PO_NUM==aPo[nPo]
			If SW3->W3_SEQ == 0
				SW3->(DbSkip())
				Loop
			EndIf
			If (nPos:=Ascan(aPgi,{|X|X[2]+X[1]==SW3->W3_PO_NUM+SW3->W3_POSICAO}))==0
				AAdd(aPgi,{SW3->W3_POSICAO,SW3->W3_PO_NUM,{SW3->W3_PGI_NUM}})
			Else
				Aadd(aPgi[nPos][3],SW3->W3_PGI_NUM)
			EndIf
			SW3->(DbSkip())
		EndDo
	Next nPo
	//
	aSla:={}
	WORK_SEL->(DbGoTop())
	While WORK_SEL->(!Eof())
		If Empty(WORK_SEL->WKFLAGWIN)
			WORK_SEL->(DbSkip())
			Loop
		EndIf
		If (nPos:=Ascan(aSla,{|X|X[1]==WORK_SEL->(WKPLI+WKPO_NUM+WKPOSICAO)})) == 0
			Aadd(aSla,{WORK_SEL->(WKPLI+WKPO_NUM+WKPOSICAO),WORK_SEL->WKQTD_SLA})
		Else
			aSla[nPos][2] += WORK_SEL->WKQTD_SLA
		EndIf
		WORK_SEL->(DbSkip())
	EndDo
	lTemSW5:=.F.
	//
	EW5->(DbSeek(xFilial("EW5")+AVKEY(cInv,"EW5_INVOIC")))
	While EW5->(!Eof()) .And. EW5->(EW5_FILIAL+EW5_INVOIC)==(xFilial("EW5")+AvKey(cInv,"EW5_INVOIC"))
		nPosx := Ascan(aPgi,{|x|x[1]+X[2]==EW5->EW5_POSICA+EW5->EW5_PO_NUM})
		If nPosx == 0
			EW5->(DbSkip())
			Loop
		EndIf
		nSaldo:= EW5->EW5_QTDE
      For j:=1 To Len(aPgi[nPosx][3])
			cPgi := aPgi[nPosx][3][j]
			SW5->(dbSeek(xFilial("SW5")+cPgi+EW5->EW5_PO_NUM+EW5->EW5_POSICA))
			WHILE SW5->(!EOF()) .AND. SW5->W5_PGI_NUM == cPgi .And. SW5->W5_PO_NUM==EW5->EW5_PO_NUM .AND. SW5->W5_POSICAO==EW5->EW5_POSICA
				If SW5->W5_FLUXO == "1" .And. ( (!Empty(SW5->W5_INVANT) .And. AvKey(SW5->W5_INVANT,"EW5_INVOIC") != AvKey(cInv,"EW5_INVOIC")) .Or. (!Empty(EW5->EW5_PGI_NUM) .And. SW5->W5_PGI_NUM != EW5->EW5_PGI_NUM) )
					SW5->(DbSkip())
					Loop            
            EndIf
            If SW5->W5_SEQ <> 0
					SW5->(DbSkip())
					Loop
				EndIf
				If SW5->W5_SALDO_Q <= 0 .Or. nSaldo <= 0
					SW5->(DbSkip())
					Loop
				EndIf
            
            nPos:= Ascan(aSla,{|x|x[1]==SW5->(W5_PGI_NUM+W5_PO_NUM+W5_POSICAO)})
            If nPos > 0 .And. aSla[nPos][2] >= SW5->W5_SALDO_Q
					SW5->(DbSkip())
					Loop
            EndIf

				lTemSW5:=.T.
				If !WORK_SEL->(DbSeek(SW5->(W5_PGI_NUM+W5_PO_NUM+W5_POSICAO)+EW5->EW5_INVOIC))
					WORK_SEL->(dbAppend())
					WORK_SEL->WKPLI    :=SW5->W5_PGI_NUM
					WORK_SEL->WKQTD_PLI:=SW5->W5_SALDO_Q
					WORK_SEL->WKQTD_ORI:=SW5->W5_SALDO_Q
					WORK_SEL->WKPO_NUM :=SW5->W5_PO_NUM
					WORK_SEL->WKPOSICAO:=SW5->W5_POSICAO
					WORK_SEL->WKITEM   :=SW5->W5_COD_I
					WORK_SEL->WKUSADO  := ""
					If nPos > 0 .And. aSla[nPos][2] >= SW5->W5_SALDO_Q
						WORK_SEL->WKQTD_SLA:= SW5->W5_SALDO_Q
						WORK_SEL->WKQTD_SEL:= 0
						WORK_SEL->WKFLAGWIN:=""
					ElseIf nPos > 0 .And. aSla[nPos][2] < SW5->W5_SALDO_Q
						nSaldoAux := SW5->W5_SALDO_Q - aSla[nPos][2]
						WORK_SEL->WKQTD_SLA:= If(nSaldoAux >= EW5->EW5_QTDE,EW5->EW5_QTDE,nSaldoAux)
						WORK_SEL->WKQTD_SEL:= If(nSaldoAux >= EW5->EW5_QTDE,nSaldoAux-EW5->EW5_QTDE,0)
                  nSaldo -= nSaldoAux
               ElseIf nPos == 0
                  /* wfs 14/10/19: revisão do controle de saldo na inclusão do embarque/ desembaraço a partir da invoice antecipada com itens anuentes */
                  If SW5->W5_SALDO_Q >= nSaldo//EW5->EW5_QTDE
                     WORK_SEL->WKQTD_SLA:= nSaldo//EW5->EW5_QTDE
                     WORK_SEL->WKQTD_SEL:= SW5->W5_SALDO_Q-nSaldo//EW5->EW5_QTDE
                     nSaldo := 0//EW5->EW5_QTDE
                  Else 
                     WORK_SEL->WKQTD_SLA:= SW5->W5_SALDO_Q
                     WORK_SEL->WKQTD_SEL:= 0
						   nSaldo-= SW5->W5_SALDO_Q
                  EndIf
					EndIf
					WORK_SEL->WKFLAGWIN:=cMarca
					WORK_SEL->WKINVOIC   := EW5->EW5_INVOIC
				EndIf
				SW5->(DbSkip())
			End
		Next J
		EW5->(DbSkip())
	EndDo
	EW5->(DbSeek(xFilial("EW5")+AVKEY(cInv,"EW5_INVOIC")))
	If !lTemSW5
		MsgStop(STR0202, STR0001) //"Nao existem itens com PLI ou saldo para esta invoice." //STR0001 := "Atencao"
		lRet := .F.
		Break
	EndIf
	WORK_SEL->(dbGoTop())
	nQtdTot:=0
	//
	WORK_SEL->(dbGoTop())
	If lRet
		cPo_Num := ""
		IF ASCAN(AINV,cINV)==0
			oLbxInv:ADD(cInv)
		ENDIF
		While EW5->(!Eof()) .And. EW5->(EW5_FILIAL+EW5_INVOIC)=(xFilial("EW5")+EW4->EW4_INVOIC)
			If At(EW5->EW5_PO_NUM,cPo_Num) == 0
				cPo_Num += EW5->EW5_PO_NUM+"/"
				cPedido := EW5->EW5_PO_NUM
				DI500POPLIValid(.T.,cPedido,.F.)
			EndIf
			EW5->(DbSkip())
		EndDo
	EndIf
End Sequence
RestOrd(aOrd)
Return(lRet)


/*
Funcao      : ValPliSel()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
Static Function ValPliSel()

Local lOk := .f.
WORK_SEL->(dbGoTop())
While WORK_SEL->(!EOF())
	If !Empty(WORK_SEL->WKFLAGWIN)
		lOk := .t.
	EndIf
	WORK_SEL->(dbSkip())
End
WORK_SEL->(dbGoTop())
If !lOk
	MsgStop(STR0203, STR0001) //"Não existe PLI selecionada." //STR0001 "Atenção"
EndIf
Return lOk

/*
Funcao      : GRVAPLISEL()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
Static Function GRVAPLISEL() //WR 08/02/2006

cInvAnt:=EW5->EW5_INVOIC
Return .T.

/*
Funcao      : VrfSldInvAnt()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
Static Function VrfSldInvAnt(pxMsg)

//MFR 15/09/2021 OSSME-6184 melhoria de performance
Local lRet := .T.
Local cQry

cQry := " SELECT "
cQry += "   EW5_PO_NUM, "
cQry += "   EW5_COD_I, "
cQry += "   EW5_POSICA, "
cQry += "   SUM(EW5_QTDE) EW5_QTDE, "
cQry += "   CASE WHEN W5_SALDO_Q IS NULL THEN SALDO_INVANT ELSE W5_SALDO_Q END W5_SALDO_Q "
cQry += " FROM "
cQry += "   ( "
cQry += "     SELECT "
cQry += "       EW5B.EW5_INVOIC, "
cQry += "       EW5B.EW5_PO_NUM, "
cQry += "       EW5B.EW5_COD_I, "
cQry += "       EW5B.EW5_POSICA, "
cQry += "       EW5B.EW5_QTDE, "
cQry += "       W5A.W5_SALDO_Q SALDO_INVANT "
cQry += "     FROM " + RetSqlName("EW5") + " EW5B " 
cQry += "       LEFT OUTER JOIN " + RetSqlName("SW5") +" W5A ON ( "
cQry += "         W5A.W5_FLUXO = '1' "
cQry += "         AND W5A.W5_SEQ = 0 "
cQry += "         AND W5A.W5_PO_NUM = EW5B.EW5_PO_NUM "
cQry += "         AND W5A.W5_COD_I = EW5B.EW5_COD_I "
cQry += "         AND W5A.W5_POSICAO = EW5B.EW5_POSICA "
cQry += "         AND W5A.W5_INVANT = EW5B.EW5_INVOIC "
cQry += "         AND W5A.D_E_L_E_T_ = ' ' "
cQry += "         AND W5A.W5_FILIAL = '" + xFilial("SW5") + "' "
cQry += "       ) "
cQry += "     WHERE EW5B.EW5_FILIAL = '" + xFilial("EW5") + "' "
cQry += "       AND EW5B.EW5_INVOIC in (" + GetListInv() + ") "
cQry += "       AND EW5B.D_E_L_E_T_ = ' ' "
cQry += "   ) EW5A "
cQry += "   LEFT OUTER JOIN ( "
cQry += "     SELECT "
cQry += "       W5_PO_NUM, "
cQry += "       W5_COD_I, "
cQry += "       W5_POSICAO, "
cQry += "       W5_INVANT, "
cQry += "       SUM(W5_SALDO_Q) W5_SALDO_Q "
cQry += "     FROM " + RetSqlName("SW5") + " "
cQry += "     WHERE W5_FILIAL='" + xFilial("SW5") + "' "
cQry += "       AND W5_FLUXO = '1' "
cQry += "       AND W5_SEQ = 0 "
cQry += "       AND D_E_L_E_T_ = ' ' "
cQry += "     GROUP BY "
cQry += "       W5_PO_NUM, W5_COD_I, W5_POSICAO, W5_INVANT "
cQry += "   ) W5B ON ( "
cQry += "     W5_PO_NUM = EW5A.EW5_PO_NUM "
cQry += "     AND W5_COD_I = EW5A.EW5_COD_I "
cQry += "     AND W5_POSICAO = EW5A.EW5_POSICA "
cQry += "     AND ( "
cQry += "       W5_INVANT = ' ' "
cQry += "       AND EW5A.SALDO_INVANT IS NULL "
cQry += "     ) "
cQry += "   ) "
cQry += " GROUP BY "
cQry += "   EW5_PO_NUM, "
cQry += "   EW5_COD_I, "
cQry += "   EW5_POSICA, "
cQry += "   W5B.W5_SALDO_Q, "
cQry += "   W5_INVANT, "
cQry += "   SALDO_INVANT "
cQry += " HAVING "
cQry += "   ( "
cQry += "     SUM(EW5_QTDE) > W5B.W5_SALDO_Q "
cQry += "     AND W5_SALDO_Q IS NOT NULL "
cQry += "   ) "
cQry += "   OR ( "
cQry += "     SUM(EW5_QTDE) > SALDO_INVANT "
cQry += "     AND SALDO_INVANT IS NOT NULL "
cQry += "   ) "
cQry += " UNION " 
cQry += " SELECT "
cQry += "   EW5_PO_NUM, "
cQry += "   EW5_COD_I, "
cQry += "   EW5_POSICA, "
cQry += "   EW5_QTDE, "
cQry += "   W5_SALDO_Q "
cQry += " FROM "
cQry += "   ( "
cQry += "     SELECT "
cQry += "       EW5B.EW5_PO_NUM, "
cQry += "       EW5B.EW5_COD_I, "
cQry += "       EW5B.EW5_POSICA, "
cQry += "       SUM(EW5B.EW5_QTDE) EW5_QTDE "
cQry += "     FROM " + RetSqlName("EW5") + " EW5B "
cQry += "     WHERE "
cQry += "       EW5B.EW5_FILIAL = '" + xFilial("EW5") + "' "
cQry += "       AND EW5B.EW5_INVOIC in (" + GetListInv() + ") "
cQry += "       AND D_E_L_E_T_ = ' ' "
cQry += "     GROUP BY "
cQry += "       EW5B.EW5_PO_NUM, "
cQry += "       EW5B.EW5_COD_I, "
cQry += "       EW5B.EW5_POSICA "
cQry += "   ) EW5A "
cQry += "   INNER JOIN " + RetSqlName("SW5") + " SW5 ON ( "
cQry += "     W5_PO_NUM = EW5A.EW5_PO_NUM "
cQry += "     AND W5_COD_I = EW5A.EW5_COD_I "
cQry += "     AND W5_POSICAO = EW5A.EW5_POSICA "
cQry += "     AND W5_FLUXO = '7' "
cQry += "   ) "
cQry += " WHERE "
cQry += "   SW5.W5_FILIAL = '" + xFilial("SW5") + "' "
cQry += "   AND SW5.W5_SEQ = 0 "
cQry += "   AND SW5.D_E_L_E_T_ = ' ' "
cQry += "   AND EW5_QTDE > W5_SALDO_Q "

cQry:=ChangeQuery(cQry)
dbUseArea( .T., "TopConn", TCGenQry(,,cQry), "cTrbEW5A", .T., .T. )

dO While cTrbEw5A->(!EOF())
   If cTrbEw5A->EW5_QTDE > cTrbEw5A->W5_SALDO_Q
//---	Existe mais quantidade na INVOICE ANTECIPADA do que SALDO A EMBARCAR no SW5, portanto, retorna .F.
		//		para que a rotina não permita a seleção desta Invoice que não possui todas as suas quantidades
		//		disponíveis nos ITENS DA PLI (sendo eles ANUENTES ou NÃO ANUENTES)...
		pxMsg	+=	STR0204+AllTrim(cTrbEw5A->EW5_PO_NUM)+ENTER+; //"Purchase Order: "
			      STR0205+AllTrim(cTrbEw5A->EW5_COD_I)+ENTER+; //" Produto: "
					STR0206+AllTrim(cTrbEw5A->EW5_POSICA)+ENTER+; //" Posição: "
					STR0207+AllTrim(Str(cTrbEw5A->EW5_QTDE,AvSx3("EW5_QTDE",3),AvSx3("EW5_QTDE",4)))+ENTER+; //" Quantidade a Embarcar: "
					STR0208+AllTrim(Str(cTrbEw5A->W5_SALDO_Q,AvSx3("EW5_QTDE",3),AvSx3("EW5_QTDE",4)))+Chr(13)+Chr(10) //STR0208 " Quantidade Liberada: "
      lRet:=.F.
   EndIf
   cTrbEw5A->(DBSkip())
EndDo
cTrbEw5A->(dbCloseArea())

Return (lRet)
/*
//MFR 15/09/2021 OSSME-6184 melhoria de performance


Local	lxRet			:=	.T.
Local	axQtdSaldo	:=	{}
Local	nxORecEW5	:=	EW5->(RecNo())
Local	nxOOrdEW5	:=	EW5->(IndexOrd())
Local	nxORecSW5	:=	SW5->(RecNo())
Local	nxOOrdSW5	:=	SW5->(IndexOrd())
Local	nxPos			:=	0
EW5->(dBSetOrder(1))
SW5->(dBSetOrder(3))
While	!EW5->(EOF()) .And. EW5->(EW5_FILIAL+EW5_INVOIC) == (xFilial("EW5")+AvKey(cInv,"EW5_INVOIC"))
	If	(nxPos	:= aScan(axQtdSaldo,{|x| x[01]==EW5->EW5_PO_NUM.AND.x[02]==EW5->EW5_POSICAO.AND.x[03]==EW5->EW5_COD_I}) )==0
		aAdd(axQtdSaldo,{EW5->EW5_PO_NUM,EW5->EW5_COD_I,EW5->EW5_POSICAO,0,0})
		nxPos		:=	Len(axQtdSaldo)
	EndIf
	axQtdSaldo[nxPos,04]+=EW5->EW5_QTDE
	SW5->(dBSeek(xFilial("SW5")+EW5->EW5_PO_NUM+EW5->EW5_COD_I))                                                                                                                                                                                                                     
	While	SW5->(!Eof()) .AND. Alltrim(SW5->(W5_FILIAL+W5_PO_NUM+W5_COD_I))==Alltrim(xFilial("SW5")+EW5->(EW5_PO_NUM+EW5_COD_I))//ACB - 19/01/2011
		If	SW5->W5_POSICAO	==	EW5->EW5_POSICAO	.AND.	SW5->W5_SEQ	==	0
			axQtdSaldo[nxPos,05]+=SW5->W5_SALDO_Q
		EndIf
		SW5->(dBSkip())
	EndDo
	EW5->(dBSkip())
EndDo
For	nxPos:=1	to	Len(axQtdSaldo)
	If	axQtdSaldo[nxPos,04]	>	axQtdSaldo[nxPos,05]
		//---	Existe mais quantidade na INVOICE ANTECIPADA do que SALDO A EMBARCAR no SW5, portanto, retorna .F.
		//		para que a rotina não permita a seleção desta Invoice que não possui todas as suas quantidades
		//		disponíveis nos ITENS DA PLI (sendo eles ANUENTES ou NÃO ANUENTES)...
		pxMsg	+=	STR0204+AllTrim(axQtdSaldo[nxPos,01])+; //"Purchase Order: "
			        STR0205+AllTrim(axQtdSaldo[nxPos,02])+; //" Produto: "
					STR0206+AllTrim(axQtdSaldo[nxPos,03])+; //" Posição: "
					STR0207+AllTrim(Str(axQtdSaldo[nxPos,04],AvSx3("EW5_QTDE",3),AvSx3("EW5_QTDE",4)))+; //" Quantidade a Embarcar: "
					STR0208+AllTrim(Str(axQtdSaldo[nxPos,05],AvSx3("EW5_QTDE",3),AvSx3("EW5_QTDE",4)))+Chr(13)+Chr(10) //STR0208 " Quantidade Liberada: "
		lxRet:=.F.
		EXIT
	EndIf
Next	nxPos
EW5->(dBSetOrder(nxOOrdEW5))
SW5->(dBSetOrder(nxOOrdSW5))
EW5->(dBGoTo(nxORecEW5))
SW5->(dBGoTo(nxORecSW5))
Return	lxRet
/*

Funcao      : DI501GetLocVen()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
//NCF - 13/05/2010 - Retorna o Local de Venda a partir do Incoterm da adição.
//GFP - 19/03/2013 - Efetuado ajuste para que o local de venda seja preenchido a partir das informações das invoices cadastradas.
*-----------------------------------*
Function DI501GetLocVen(cOrigem)
*-----------------------------------*
Local cLocalVend := ""
Local aOrdTables := SaveOrd({"SW6","EIJ","SA2","SY9","SYA"})
Default cOrigem := ""

DO CASE

   CASE IIF(cOrigem == "ADICAO",Work_EIJ->EIJ_INCOTE,Work_SW9->W9_INCOTER) $ "EXW"      //Local de venda -> Cidade do Fornecedor
      SA2->(DbSetOrder(1))
      SA2->(DbSeek(xFilial()+IIF(cOrigem == "ADICAO",Work_EIJ->EIJ_FORN,Work_SW9->W9_FORN)))
      cLocalVend := ALLTRIM(SA2->A2_MUN)+" - "
      IF !EMPTY(SA2->A2_PAIS)
         SYA->(DbSetOrder(1))
         SYA->(DbSeek(xFilial()+SA2->A2_PAIS))
         cLocalVend += SYA->YA_DESCR
      ENDIF

  //DFS - 15/02/11 - Alteração para que só os incoterms "FCA/FAS/FOB" tragam a cidade do porto internacional
   CASE IIF(cOrigem == "ADICAO",Work_EIJ->EIJ_INCOTE,Work_SW9->W9_INCOTER) $ "FCA/FAS/FOB"   //Local de Venda -> Cidade do Porto Internacional
      SY9->(DbSetOrder(2))
      SY9->(DbSeek(xFilial()+M->W6_ORIGEM))
      cLocalVend := ALLTRIM(SY9->Y9_DESCR)+" - "+ALLTRIM(SY9->Y9_CIDADE)+" - "
      IF !EMPTY(SY9->Y9_PAIS)
         SYA->(DbSetOrder(1))
         SYA->(DbSeek(xFilial()+SY9->Y9_PAIS))
         cLocalVend += SYA->YA_DESCR
      ENDIF

   //DFS - 15/02/11 - Alteração para que só os incoterms "CFR/CIF/CPT/CIP" tragam a cidade do porto nacional
   CASE IIF(cOrigem == "ADICAO",Work_EIJ->EIJ_INCOTE,Work_SW9->W9_INCOTER) $ "CFR/CIF/CPT/CIP"  //Local de Venda -> Porto Nacional
      SY9->(DbSetOrder(2))
      SY9->(DbSeek(xFilial()+M->W6_DEST))
      cLocalVend := ALLTRIM(SY9->Y9_DESCR)+" - "+ALLTRIM(SY9->Y9_CIDADE)+" - "
      IF !EMPTY(SY9->Y9_PAIS)
         SYA->(DbSetOrder(1))
         SYA->(DbSeek(xFilial()+SY9->Y9_PAIS))
         cLocalVend += SYA->YA_DESCR
      ENDIF

   //DFS - 15/02/11 - Inclusão para que os incoterms "DES/DEQ/DDU/DDP/DAP/DAT" tragam a cidade do importador/consignatário
   CASE IIF(cOrigem == "ADICAO",Work_EIJ->EIJ_INCOTE,Work_SW9->W9_INCOTER) $ "DES/DEQ/DDU/DDP/DAP/DAT"  //Cidade do importador/consignatário
      SYT->(DbSetOrder(1))
      SYT->(DbSeek(xFilial()+M->W6_IMPORT))
      cLocalVend := ALLTRIM(SYT->YT_NOME)+" - "+ALLTRIM(SYT->YT_CIDADE)+" - "
      IF !EMPTY(SYT->YT_PAIS)
         SYA->(DbSetOrder(1))
         SYA->(DbSeek(xFilial()+SYT->YT_PAIS))
         cLocalVend += SYA->YA_DESCR
      ENDIF

END CASE

RestOrd(aOrdTables)

If Empty(cLocalVend)  // TRP - 28/03/2013
   cLocalVend:= Criavar("EIJ_LOCVEN")
Endif

Return cLocalVend

/*
Funcao      : DI501SWDLin()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
Function DI501SWDLin(cHawb,cDespesa)

Local cLinha := StrZero(1,AvSX3("WD_LINHA",AV_TAMANHO))
Local nOrd   := SWD->(IndexOrd())
Local nReg   := SWD->(RecNo())

Default cHawb    := SWD->WD_HAWB
Default cDespesa := SWD->WD_DESPESA

SWD->(dbSetOrder(6))//WD_FILIAL+WD_HAWB+WD_DESPESA+WD_LINHA
If SWD->(AVSeekLast(xFilial("SWD")+cHawb+cDespesa))
   cLinha := StrZero(Val(SWD->WD_LINHA)+1,AvSX3("WD_LINHA",AV_TAMANHO))
EndIf

SWD->(dbSetOrder(nOrd),dbGoTo(nReg))

Return cLinha

/*
Funcao      : DI501ChkEW4()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
Function DI501ChkEW4()

Local	nOrdEW4		:=	EW4->(IndexOrd())
Local	nRecEW4		:=	EW4->(RecNo())
Local	nOrdWK9		:=	WORK_SW9->(IndexOrd())
Local	nRecWK9		:=	WORK_SW9->(RecNo())
Local	nTotInv		:=	0
Local	lxRet			:=	.T.
Local	cMsgEW4		:=	""
Local	cTeste		:=	""
//
EW4->(dBSetOrder(1))	//EW4_FILIAL+EW4_INVOIC+EW4_FORN
WORK_SW9->(dBGoTop())
While	WORK_SW9->(!Eof())
	nTotInv		:=	WORK_SW9->(W9_FOB_TOT+W9_INLAND+W9_PACKING+W9_OUTDESP)
	//LGS-29/05/2014 - Incluido validação por incoterm para os valores de Frete/Seguro
	If WORK_SW9->W9_FREINC $ cNao .And. AvRetInco(Work_SW9->W9_INCOTERM,"CONTEM_FRETE")
		nTotInv	+=	WORK_SW9->W9_FRETEIN
	EndIf
	If lSegInc .AND. WORK_SW9->W9_SEGINC $ cNao .AND. AvRetInco(Work_SW9->W9_INCOTERM,"CONTEM_SEG")
		nTotInv	+=	WORK_SW9->W9_SEGURO
	EndIf
	nTotInv		-=	WORK_SW9->W9_DESCONT
	If	EW4->(dBSeek(xFilial("EW4")+WORK_SW9->(W9_INVOICE+W9_FORN))) .AND. (Empty(EW4->EW4_HAWB) .OR. EW4->EW4_HAWB == SW9->W9_HAWB)  //AAF 27/12/2019 - Validar se a invoice antecipada realmente é deste embarque. Pode ser de outro com o mesmo nro.
		//--- Se a COMMERCIAL INVOICE existir como uma INVOICE ANTECIPADA, o seu VALOR TOTAL deve obedecer à configuração
		//		realizada na rotina da INVOICE ANTECIPADA para manter a integridade das informações dentro da base de dados.
		If	EW4->EW4_TOTINV	<>	nTotInv .And. ( !AVFLAGS("INV_ANT_GERA_CAMB_FIN") .Or. M->W6_TITINAN <> '1' )
			cTeste	:=	STR0209 //"Vlr Total"
			cMsgEW4	+=	If(Empty(cMsgEW4),"",Chr(13)+Chr(10))+cTeste+STR0210+AllTrim(EW4->EW4_INVOIC)+STR0211 //STR0210 " da Invoice " //STR0211 " diferente do informado na Invoice Antecipada"
		EndIf
		If	EW4->EW4_DT_EMI	<>	WORK_SW9->W9_DT_EMIS
			cTeste	:= STR0212 //STR0212 "Dt.Emissão"
			cMsgEW4	+=	If(Empty(cMsgEW4),"",Chr(13)+Chr(10))+cTeste+STR0210+AllTrim(EW4->EW4_INVOIC)+STR0211 //STR0210 " da Invoice " //STR0211 " diferente do informado na Invoice Antecipada"
		EndIf
		If	EW4->EW4_FORN	<>	WORK_SW9->W9_FORN
			cTeste	:=STR0213 //STR0213 "Fornecedor"
			cMsgEW4	+=	If(Empty(cMsgEW4),"",Chr(13)+Chr(10))+cTeste+STR0210+AllTrim(EW4->EW4_INVOIC)+STR0211 //STR0210 " da Invoice " //STR0211 " diferente do informado na Invoice Antecipada"
		EndIf
		If	EW4->EW4_COND_P	<>	WORK_SW9->W9_COND_PA	.OR.	EW4->EW4_DIAS_P	<>	WORK_SW9->W9_DIAS_PA
			cTeste	:= STR0214 //STR0214 "Cond.Pagto"
			cMsgEW4	+=	If(Empty(cMsgEW4),"",Chr(13)+Chr(10))+cTeste+STR0210+AllTrim(EW4->EW4_INVOIC)+STR0211//STR0210 " da Invoice "  //STR0211 " diferente do informado na Invoice Antecipada"
		EndIf
		If	EW4->EW4_INCOTE	<>	WORK_SW9->W9_INCOTER
			cTeste	:= STR0215 //STR0215 "Incoterm"
			cMsgEW4	+=	If(Empty(cMsgEW4),"",Chr(13)+Chr(10))+cTeste+STR0210+AllTrim(EW4->EW4_INVOIC)+STR0211//STR0210 " da Invoice "  //STR0211 " diferente do informado na Invoice Antecipada"
		EndIf
	EndIf
	WORK_SW9->(dBSkip())
EndDo
//
If	!Empty(cMsgEW4)
	MsgStop(cMsgEW4)
	lxRet	:=	.F.
EndIf
EW4->(dBSetOrder(nOrdEW4))
EW4->(dBGoTo(nRecEW4))
WORK_SW9->(dBSetOrder(nOrdWK9))
WORK_SW9->(dBGoTo(nRecWK9))
Return	lxRet

/*
Funcao      : DI501Crit()
Parâmetros  :
Retorno     :
Objetivos   : Faz as Validacoes necessarias aos campos Banco das Despesas
Autor       : PLB - Pedro Baroni
Data 	     : 31.05.10
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
FUNCTION DI501Crit(MFlag,cCampo)

LOCAL uDado
LOCAL cRno
LOCAL lRetorno:=.T.

IF cCampo==NIL
   uDado:=&(READVAR())
   cCampo:=Subs(READVAR(),4)
ELSE
   uDado:=M->(&cCampo)
ENDIF


DO CASE

   CASE AvFlags("EIC_EAI") .AND. MFlag == "WD_GERFIN" //IGOR CHIBA  REQ 5.8 14/07/14

      IF M->WD_GERFIN == '1' .AND. !EMPTY(M->WD_CODINT) .AND. M->WD_BASEADI == '1' .AND. M->WD_PAGOPOR == '1'
         IF !MSGYESNO(STR0227, STR0053) //"Esta é uma despesa base de adiantamento paga pelo despachante. Ao confirmar esta ação, a despesa não poderá ser usada para na compensação com o adiantamento ao despachante. É recomendável que a geração do título de despesa efetiva ocorra pela rotina de Prestação de Contas Deseja prosseguir?")
            lRetorno:= .F.
         Else
            M->WD_BASEADI:= "2"
         ENDIF
      ENDIF


// CASE EasyGParam("MV_EIC_EAI",,.F.) .AND. MFlag == "WD_GERFIN" //IGOR CHIBA TESTE NO CAMPO WD_DT_VENC 02/07/14
      IF M->WD_GERFIN == '1' .AND. M->WD_DESPESA == '903'
         MsgAlert(STR0223, STR0001) //"Não é possível gerar a integração com o Financeiro para a despesa do tipo Devolução do Despachante."
         lRetorno:=.F.
      ENDIF

   CASE MFlag == "WD_DT_VENC" //IGOR CHIBA TESTE NO CAMPO WD_DT_VENC 02/07/14
      /* retirada a validação para integração com o LOGIX, deixando que o próprio ERP retorne as consistências.
      IF !EMPTY(M->WD_DT_VENC) .AND. M->WD_DT_VENC < dDataBase
         MsgAlert(STR0224, STR0001) //"O vencimento informado é menor que a data base. Favor informar uma data igual ou maior que a data atual."
         lRetorno:=.F.
      ENDIF*/
   CASE MFlag == "BCO"

        cRno := SA6->(Recno())

        If Empty(uDado)

           M->YT_AGENCIA:=""
           M->YT_CONTA  :=""

        Else
           If !SA6->(DBSEEK(xFilial()+uDado))
              Help(" ",1,"BCONAOCAD")
              lRetorno:=.F.
           EndIf
        EndIf

        SA6->(DbGoTo(cRno))

        If SA6->A6_COD == uDado
           M->YT_AGENCIA:=SA6->A6_AGENCIA
           M->YT_CONTA  :=SA6->A6_NUMCON
        EndIf

   CASE MFlag == "AGE"

        cRno := SA6->(Recno())

        If !Empty(uDado)
           If Empty(M->WD_BANCO)
              Help("", 1, "AVG0000189")
              lRetorno:=.F.
           Else
              If !SA6->(DbSeek(xFilial("SA6")+M->WD_BANCO+uDado))
                 Help("", 1, "AVG0000189")
                 lRetorno:=.F.
              EndIf
           EndIf
        EndIf

        SA6->(DbGoTo(cRno))

   CASE MFlag == "CONTA"

        cRno := SA6->(Recno())

        If !Empty(uDado)
           If Empty(M->WD_BANCO)
              MsgStop(STR0216) //STR0216 "Conta não cadastrada para este Banco/Agencia"
              lRetorno:=.F.
           Else
              If !SA6->(DbSeek(xFilial("SA6")+M->WD_BANCO+M->WD_AGENCIA+uDado))
                 MsgStop(STR0216) //STR0216 "Conta não cadastrada para este Banco/Agencia"
                 lRetorno:=.F.
              EndIf
           EndIf
        EndIf

        SA6->(DbGoTo(cRno))

   CASE MFlag == "BCO_REC"

        cRno := SA6->(Recno())

        If Empty(uDado)

           M->WD_AGE_REC:=""
           M->WD_CON_REC  :=""

        Else
           If !SA6->(DBSEEK(xFilial()+uDado))
              Help(" ",1,"BCONAOCAD")
              lRetorno:=.F.
           EndIf
        EndIf

        SA6->(DbGoTo(cRno))

        If SA6->A6_COD == uDado
           M->WD_AGE_REC:=SA6->A6_AGENCIA
           M->WD_CON_REC:=SA6->A6_NUMCON
        EndIf

   CASE MFlag == "AGE_REC"

        cRno := SA6->(Recno())

        If !Empty(uDado)
           If Empty(M->WD_BAN_REC)
              Help("", 1, "AVG0000189")
              lRetorno:=.F.
           Else
              If !SA6->(DbSeek(xFilial("SA6")+M->WD_BAN_REC+uDado))
                 Help("", 1, "AVG0000189")
                 lRetorno:=.F.
              EndIf
           EndIf
        EndIf

        SA6->(DbGoTo(cRno))

   CASE MFlag == "CONTA_REC"

        cRno := SA6->(Recno())

        If !Empty(uDado)
           If Empty(M->WD_BAN_REC)
              MsgStop(STR0216) //STR0216 "Conta não cadastrada para este Banco/Agencia"
              lRetorno:=.F.
           Else
              If !SA6->(DbSeek(xFilial("SA6")+M->WD_BAN_REC+M->WD_AGE_REC+uDado))
                 MsgStop(STR0216)//STR0216 "Conta não cadastrada para este Banco/Agencia"
                 lRetorno:=.F.
              EndIf
           EndIf
        EndIf

        SA6->(DbGoTo(cRno))

ENDCASE


RETURN lRetorno

/*
Funcao     : DI501Encerra()
Parametros : Nenhum
Retorno    : lRet
Objetivos  : Encerrar desembaraço por motivos de estravio de mercadoria e eliminação de residuo do PC no sigacom.
Autor      : André Ceccheto Balieiro
Data/Hora  : 25/10/2010
Observação : Função migrada do programa EICDI500
*/
*-----------------------------------*
Function DI501Encerra()
*-----------------------------------*

Local nOpcEnc :=0
Local lRet:= .F.
Local oDlgEnc,oMemo
Local bOk:= {||lRet:= .T.,nOpcEnc := 1, oDlgEnc:End()}
Local bCancel:= {||nOpcEnc := 0, oDlgEnc:End()}
Local aRecSC7 := {} //MCF - 12/05/2016 - Parâmetro novo utilizado na função MA235PC

PRIVATE lMT235G1 := EasyEntryPoint("MT235G1") //Variavél declarada para uso da rotina MA235PC, não utilizada no Easy.

If lEncerraDes .And. EasyGParam("MV_EASY",, "N") == "S"

   SW7->(DbSetOrder(1)) //filial + hawb + pgi_num + cc + Si_num + Cod_i
   SW7->(DBSeek(xFilial("SW7")+SW6->W6_HAWB))

   //Verifica se o processo possui nota fiscal emitida e não permite o encerramento
   SF1->(dbsetorder(5))
   If SF1->(dbSeek(xFilial("SF1")+SW6->W6_HAWB))
      EECview(Alltrim(STR0060) + " " + Alltrim(SW6->W6_HAWB) + STR0193, STR0001)  //"Processo ### não pode ser cancelado pois possui nota fiscal emitida. ### Atenção
      Return .F.
   Else

   SW6->(DbSetOrder(1))
   If SW6->(DbSeek(xFilial("SW6")+SW7->W7_HAWB))
      If !Empty(SW6->W6_DT_ENCE)
         MsgInfo(STR0194, STR0053) //"Pedido já encerrado", Aviso
         Return .f.
      EndIf
   EndIf

      If !MsgYesNo(STR0190, STR0001)//Deseja encerrar este processo? esta operação irá eliminar residuo no pedido de compras e encerrar o desembaraço
         Return .F.
      Else

         //Tela
         dDataEnce:= dDataBase
         cObs:= Space(200)

         Define MsDialog oDlgEnc Title STR0190 From 229,250 To 525,607 PIXEL  //Encerramento

            oPanel:= TPanel():New(0, 0, "", oDlgEnc,, .F., .F.,,, 21, 50) //MCF - 12/05/2016
            oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

            @ 020, 017 Say AvSx3("W6_DT_ENCE", AV_TITULO) Pixel Of oPanel
            @ 020, 057 MsGet dDataEnce Size 50, 08 Picture AvSx3("W6_DT_ENCE", AV_PICTURE) Pixel Of oPanel

            @ 033, 016 TO 109,168 LABEL STR0192 PIXEL Of oPanel //Observações
            oMemo:= tMultiget():New(039,022,{|u|if(Pcount()>0,cObs:=u,cObs)},oPanel,142,065,,,,,,.T.)

         Activate MsDialog oDlgEnc On Init (EnchoiceBar(oDlgEnc, bOk, bCancel)) CENTERED

         If nOpcEnc == 0
            Return .f.
         EndIf

         While SW7->(!Eof()) .and. SW7->W7_FILIAL == SW6->W6_FILIAL .and. SW7->W7_HAWB == SW6->W6_HAWB

            If nOpcEnc == 1

               SW3->(dbsetOrder(8))
               SW3->(dbSeek(xFilial("SW3")+SW7->W7_PO_NUM+SW7->W7_POSICAO))

               SW2->(DbSetOrder(1))
               SW2->(DbSeek(xFilial("SW2")+SW6->W6_PO_NUM))

               cPosicao := SW3->W3_POSICAO
               cProduto := SW3->W3_COD_I
               nSeq     := SW3->W3_SEQ
               cPedido := SW2->W2_PO_SIGA
               cEmissao:= SW2->W2_PO_DT
               cForn   := SW2->W2_FORN
               cLoja   := Posicione("SA2",1,xFilial("SA2") + cForn,"A2_LOJA")

               MA235PC(100,1,cEmissao,cEmissao,cPedido,cPedido,cProduto,cProduto,cForn,cForn,,,,,.F.,aRecSC7) //Elimina Residuo no SIGACOM //MCF - 12/05/2016

               //Posicionado no PC para verificar se realmente o residuo foi eliminado.
               SC7->(dbSetOrder(3))
               SC7->(Dbseek(xFilial("SC7") + aVKEY(cForn,"W2_FORN") + AVKEY(cLoja,"A2_LOJA") + AVKEY(cPedido,"W2_PO_SIGA")))

               If SC7->C7_RESIDUO == "S"
                  Msginfo(STR0188, STR0053)//"Desembaraço encerrado e resíduo eliminado com sucesso no módulo de Compras (SIGACOM)!"
               EndIf

            EndIf
         SW7->(DbSkip())
         EndDO
      EndIf
   EndIf

   SW6->(RECLOCK("SW6",.F.))
      SW6->W6_DT_ENCE := dDataEnce
      MSMM(,TAMSX3("W6_VM_OBS")[1],,cObs,INCMEMO,,,"SW6","W6_OBS")
   SW6->(MSUNLOCK())

   //LBL
   RegToMemory("SW6",.F.,.T.)

   If EasyGParam("MV_EASYFIN",,"N") == "S"
      Private lRecalcProv := .T.
      Private lEncDesemb := .T.  // GFP - 13/01/2014
      EICFI400("ANT_GRV_DI","A")
      EICFI400("POS_GRV_DI","I")
   EndIf

EndIf

Return lRet

/*
Funcao      : DI501AtuTab
Parametros  : "cOpcao" - "A" = Para Alterar os valores conforme nova legislação
                         "R" = Restaurar para os valores antigos (processos antigos)
Retorno     : Nenhum
Objetivos   : Atualização dos valores da taxa siscomex na tabela SX5 conforme
              Portaria No. 257 do Ministerio da Fazenda publicada em 23/05/2011
Autor       : Nilson Cesar
Data/Hora   : 24/05/2011 - 10:00 hs
Revisao     :
Obs.        : Função migrada do programa EICDI500
*/
Function DI501AtuTab(cOpcao)
/* //NOPADO - THTS - 01/08/2017 - Projeto de dicinario no banco de dados, nao sera possivel mais utilizar reclocl em dicionario de dados
Local cNewVlrPrc := "185"
Local cOldVlrPrc := "30"
Local nPosC5     := 1
Local aOldVlrAdi := { {"02","10"   }, {"05","08"   }, {"10","06"   }, {"20","04"   }, {"50","02"  }, {"99","01"  } }
Local aNewVlrAdi := { {"02","29.50"}, {"05","23.60"}, {"10","17.70"}, {"20","11.80"}, {"50","5.90"}, {"99","2.95"} }

If cOpcao == NIL
   cOpcao := "A"
EndIf

If cOpcao == "A"
   SX5->(DBSEEK(xFilial("SX5")+"C500"))
   Do While !SX5->(Eof()) .And. SX5->X5_TABELA == "C5"
      If SX5->X5_CHAVE == AvKey("00","X5_CHAVE")
         If SX5->X5_DESCRI # AvKey(cNewVlrPrc,"X5_DESCRI")
            SX5->(RecLock("SX5",.F.)) //NOPADO - THTS - 01/08/2017
            SX5->X5_DESCRI := AvKey(cNewVlrPrc,"X5_DESCRI")
            SX5->(MsUnlock())
         EndIf
      Else
         nPosC5 := aScan(aNewVlrAdi,{|x| AvKey(x[1],"X5_CHAVE") == SX5->X5_CHAVE })
         If SX5->X5_DESCRI # AvKey(aNewVlrAdi[nPosC5][2],"X5_DESCRI")
            SX5->(RecLock("SX5",.F.)) //NOPADO - THTS - 01/08/2017
            SX5->X5_DESCRI := AvKey(aNewVlrAdi[nPosC5][2],"X5_DESCRI")
            SX5->(MsUnlock())
         EndIf
      EndIf
      SX5->(DbSkip())
   EndDo
Else
   SX5->(DBSEEK(xFilial("SX5")+"C500"))
   Do While !SX5->(Eof()) .And. SX5->X5_TABELA == "C5"
      If SX5->X5_CHAVE == AvKey("00","X5_CHAVE")
         If SX5->X5_DESCRI # AvKey(cOldVlrPrc,"X5_DESCRI")
            SX5->(RecLock("SX5",.F.)) //NOPADO - THTS - 01/08/2017
            SX5->X5_DESCRI := AvKey(cOldVlrPrc,"X5_DESCRI")
            SX5->(MsUnlock())
         EndIf
      Else
         nPosC5 := aScan(aOldVlrAdi,{|x| AvKey(x[1],"X5_CHAVE") == SX5->X5_CHAVE })
         If SX5->X5_DESCRI # AvKey(aOldVlrAdi[nPosC5][2],"X5_DESCRI")
            SX5->(RecLock("SX5",.F.)) //NOPADO - THTS - 01/08/2017
            SX5->X5_DESCRI := AvKey(aOldVlrAdi[nPosC5][2],"X5_DESCRI")
            SX5->(MsUnlock())
         EndIf
      EndIf
      SX5->(DbSkip())
   EndDo
EndIf

If Type("lAtuTabSisc") == "L"
   lAtuTabSisc := .T.
EndIf
If Type("lTabSisAtu") == "L"
   lTabSisAtu  := .T.
EndIf
*/
Return

/*
Funcao      : DI501PNPLI
Parametros  : "cPo" - Pedido a ser verificado
Retorno     : lRet
Objetivos   : Retornar se o Pedido de Nacionalização possui possui PLI vinda do PO
              antes do embarque admitido como entreposto.
Autor       : Nilson Cesar
Data/Hora   : 18/08/2011 - 10:00 hs
Revisao     :
Obs.        : Função migrada do programa EICDI500
*/
Function DI501PNPLI(cPo)

Local aOrdSW := SaveOrd({"SW3","SW5","Work"})
Local cChaveW3,cChaveW5,cPO_DI
Local lRet := .F.

SW3->(DbSetOrder(8))
SW5->(DbSetOrder(8))

IF SW3->(DbSeek(xFilial("SW3")+AvKey(cPO,"W3_PO_NUM")))               //Posiciona o PN
   cChaveW3 := SW3->(xFilial("SW3")+W3_PO_DA)                         //Obtem a chave do PO
   cPO_DI   := SW3->W3_PO_DA                                          //Guarda PO para o loop
   IF SW3->(DbSeek(cChaveW3))                                         //Posiciona o PO
      DO WHILE !SW3->(EOF()) .And. SW3->W3_PO_NUM == cPO_DI           //Loop nos itens do PO
         cChaveW5 := SW3->(xFilial("SW5")+W3_PGI_NUM+W3_PO_NUM)       //Obtem chave do PLI
         IF SW5->(DbSeek(cChaveW5)) .And. !DI500LIAutomatica(SW3->W3_PGI_NUM) //FSM - 18/05/212
            lRet := .T.
            EXIT
         ENDIF
         SW3->(DbSkip())
      ENDDO
   ENDIF
ENDIF

RestOrd(aOrdSW,.T.)

Return lRet

/*
Funcao      : DI501GERNF
Parametros  : cOperacao
Retorno     :
Objetivos   : Gerar titulos NF das despesas no financeiro
Autor       : Saimon Gava
Data/Hora   : 20/10/2011 - 20:00 hs
Revisao     :
Obs.        : Função migrada do programa EICDI500
*/
FUNCTION DI501GERNF(cOperacao)

LOCAL cFilSWD:=xFilial('SWD')
LOCAL cFilSYB:=xFilial('SYB')
LOCAL aDespesas:={},nCont:=0, lErro:=.T.
LOCAL I,D
LOCAL cFornDesp := "", cLojaDesp := ""
Local lRetFin := .T. //LRS - 08/06/2017
Private nRecSE2 := 0 //LRS - 08/06/2017
ProcRegua(4)
SYB->(DBSETORDER(1))
SWD->(DBSETORDER(1))
SA2->(DBSETORDER(1))

SWD->(DBSEEK(cFilSWD+SW6->W6_HAWB))
DO While SWD->(!Eof()) .AND. cFilSWD == SWD->WD_FILIAL .AND.;
         SWD->WD_HAWB == SW6->W6_HAWB

   IF nCont > 4
      ProcRegua(4)
   ENDIF
   nCont++
   IncProc()

   IF !(SWD->WD_DESPESA $ '201,202,203,204,205,'+cMV_CODTXSI)  // GFP - 31/10/2014 - Sistema deve gerar, obrigatoriamente, o titulo NF da Taxa Siscomex
      SWD->(dbSkip())
      LOOP
   ENDIF

   AADD(aDespesas,{ SWD->(RECNO()), SWD->WD_CTRFIN1})

   SWD->(dbSkip())

ENDDO

ProcRegua(LEN(aDespesas)+1)
IncProc()
If cOperacao == "E"
   For i:=1 to LEN(aDespesas)
      DeleImpDesp(SW6->W6_NUMDUP,"PRE","DI",.F.)
      //DeleImpDesp(aDespesas[I][2],"NF","DI",.F.)
      FI400TITFIN("SWD_ESTORNA","4",.T.)  //LRS - 08/06/2017
   Next
   Return .F.
EndIf


FOR I := 1 TO LEN(aDespesas)
  IncProc()
  SWD->(DBGOTO(aDespesas[I][1]))
  SYB->(DBSEEK(cFilSYB+SWD->WD_DESPESA))


     FOR D := 1 TO SWD->(FCount())// AWR - 13/05/2004
         SWD->( M->&(FIELDNAME(D)) := FieldGet(D) )
     NEXT

    SY5->(DBSEEK(XFILIAL("SY5")+SW6->W6_DESP))
    cFornDesp:=IF(EMPTY(SY5->Y5_FORNECE),cFornDesp,SY5->Y5_FORNECE)
    cLojaDesp:=IF(EMPTY(SY5->Y5_FORNECE),cLojaDesp,SY5->Y5_LOJAF)
    If SA2->( dbSeek(xFilial("SA2")+cFornDesp+cLojaDesp) )
       cNatureza := SA2->A2_NATUREZ
    EndIf

     cIniDocto := SWD->WD_DOCTO
     cTIPO_Tit := "NF"
     cCodFor   := cFornDesp
     cLojaFor  := cLojaDesp
     nMoedSubs := 1
     cDtVecto  := SWD->WD_DES_ADI
     nValorS   := SWD->WD_VALOR_R
     cEMISSAO  := date()
     cParcela  := SWD->WD_PARCELA
     //cHistorico:="P: "+ALLTRIM(SW6->W6_HAWB)+' '+SYB->YB_DESCR//"Proc."
     cHistorico:=AvKey("P: "+ALLTRIM(SW6->W6_HAWB)+' '+SYB->YB_DESCR,"E2_HIST")//"Proc."

     IF ! Empty(SWD->WD_CTRFIN1) //LRS - 08/06/2017
        lretFin :=  FI400TITFIN("SWD","4",.T.)
     EnDIf

     //LRS - 10/12/2015 - Não permetir abrir a tela do contas a pagar
     IF Empty(cCodFor) .And. Empty(cLojaFor)
        IF nContMSG == 1
	        MSGINFO(STR0217 + ENTER + STR0244, STR0053) // Ocorreu um erro ao gerar o título 'NF' para as despesas debitadas em conta para o Desembaraço##Preencha o Fornecedor/Loja Fornecedor
	        nContMSG ++
        EndIF
     Else
	     If lretFin  .and. FI400TITFIN("SWD_ADI","2") // Inclusao
            RecLock("SWD",.F.)
            SE2->(DBGOTO(nRecSE2))
            SWD->WD_GERFIN := "1"
            SWD->WD_TIPO := SE2->E2_TIPO //LRS - 08/06/2017
            SWD->WD_PREFIXO := SE2->E2_PREFIXO //LRS - 08/06/2017
            SWD->WD_FORN := SE2->E2_FORNECE
            SWD->WD_CTRFIN1 := SE2->E2_NUM
            SWD->WD_DOCTO   := SE2->E2_NUM //LRS - 08/06/2017
            SWD->WD_PARCELA := SE2->E2_PARCELA
            SWD->WD_LOJA := SE2->E2_LOJA 
            MsUnlock("swd")
            DeleImpDesp(SW6->W6_NUMDUP,"PRE","DI",.F.)
            //DeleImpDesp(aDespesas[I][2],"NF","DI",.F.) //LRS - 08/06/2017
            lErro:=.F.
        EndIf 
     EndIF
NEXT

IF LEN(aDespesas) > 0
   FIContabEIC('FOOTER',,.F.)//Forca fechar o cProva
ENDIF

IF lErro
   MSGINFO(STR0217, STR0053) //STR0217 "Ocorreu um erro ao gerar o título 'NF' para as despesas debitadas em conta para o Desembaraço."//STR0053 "Aviso"
ENDIF

RETURN .T.

/*
Funcao      : DI501TransfNVE
Parametros  : cFaseOri: "LI" - Quando vier de N.V.E na fase de PLI
                        "CD" - Quando vier de N.V.E na fase de Cadastro do produto
Retorno     : Nenhum
Objetivos   :

Autor       : Nilson Cesar
Data/Hora   : 18/08/2011
Revisao     :
Obs.        : função migrada do programa EICDI500
*/
FUNCTION DI501TransfNVE(cFaseOri)

Local aOrdNVE    := {}
Local cNewCode   := ""
Local nPosNVEDI  := 0 
Local cRet       := ""
Default cFaseOri := "LI"
//aTabsNVEDI -> { Cod PLI , Tabela NVE PLI , Tabela NVE DI}   }

aOrdNVE := SaveOrd({"Work_EIM","EIM","Work","SW5"})

SW5->(DbSetOrder(8))
SW5->(DbSeek(xFilial("SW5")+Work->WKPGI_NUM +Work->WKPO_NUM+Work->WKPOSICAO))

If cFaseOri == "LI"
    cTabNVE   := SW5->W5_NVE
    //MFR 23/11/2018    
    //cSeekEIM  := xFilial("EIM") + "LI" + AvKey(SW5->W5_PGI_NUM,"W6_HAWB") + cTabNVE
	//cWhileEIM := xFilial("EIM") + AvKey(SW5->W5_PGI_NUM,"W6_HAWB") + cTabNVE  + "LI"  
    cSeekEIM  := GetFilEIM("LI") + "LI" + AvKey(SW5->W5_PGI_NUM,"W6_HAWB") + cTabNVE
	cWhileEIM := GetFilEIM("LI") + AvKey(SW5->W5_PGI_NUM,"W6_HAWB") + cTabNVE  + "LI"  
    
ElseIf cFaseOri == "CD"
    cTabNVE   := EIM->EIM_CODIGO
    //MFR 23/11/2018        
    //cSeekEIM  := xFilial("EIM") + "CD" + AvKey(Work->WKCOD_I  ,"W6_HAWB") + cTabNVE
    //cWhileEIM := xFilial("EIM") + AvKey(Work->WKCOD_I  ,"W6_HAWB") + cTabNVE + "CD"  
    cSeekEIM  := GetFilEIM("CD") + "CD" + AvKey(Work->WKCOD_I  ,"W6_HAWB") + cTabNVE
    cWhileEIM := GetFilEIM("CD") + AvKey(Work->WKCOD_I  ,"W6_HAWB") + cTabNVE + "CD"  
    
EndIf

cClassif := ""

Work_EIM->(DbSetOrder(3))
If Work_EIM->(DbSeek("DI"+M->W6_HAWB+cTabNVE))                                                                       //Verifica se já existe a tabela NVE na fase DI 
   
   If cFaseOri == "LI"
      nPosNVEDI := aScan(aTabsNVEDI,{|x| x[1] == SW5->W5_PGI_NUM .And. x[2] == cTabNVE  })                           //Busca a sequencia de tabela NVE disponivel na fase DI
   ElseIf cFaseOri == "CD"
      nPosNVEDI := aScan(aTabsNVEDI,{|x| x[1] == Work->WKCOD_I   .And. x[2] == cTabNVE })
   EndIf
   
   If nPosNVEDI == 0  
      //Copiar Tabela registros de NVE da fase PLI para a fase DI                                       
      EIM->(DbSetOrder(3))                                                                                               //Posicionar pela chave de busca com fase da NVE
      If EIM->(DbSeek(cSeekEIM))        
   
		  //efetua troca                                                                                                        
		  cNewCode  := DI500GerNVE()                                                                                    //Obtem novo codigo de tabela NVE                                                                                                     //Verifica se já existe no array o cod. da tabela convertida para a fase DI
		  If cFaseOri == "LI"
             aAdd(aTabsNVEDI, { SW5->W5_PGI_NUM, cTabNVE  , cNewCode })                                             //Adiciona no array
          ElseIf cFaseOri == "CD"
             aAdd(aTabsNVEDI, { Work->WKCOD_I  , cTabNVE , cNewCode })                                             //Adiciona no array                                                     
          EndIf
          cRet := cNewCode
          Work_SW8->WKNVETIPO := cFaseOri
 
		  //While EIM->(!EOF()) .And. EIM->EIM_HAWB == AvKey(SW5->W5_PGI_NUM,"W6_HAWB") .And. EIM->EIM_CODIGO == SW5->W5_NVE .AND. EIM->EIM_FASE == "LI"    //Loop para adicionar tabela NVE de PLI para DI 
          While EIM->(!EOF()) .And. EIM->(EIM_FILIAL+EIM_HAWB+EIM_CODIGO+EIM_FASE) == cWhileEIM                                   //Loop para adicionar tabela NVE de PLI para DI 		
        	 Work_EIM->(DbAppend())
			 AvReplace("EIM","Work_EIM")
			 Work_EIM->EIM_FASE   := "DI"
			 Work_EIM->EIM_HAWB   := M->W6_HAWB
			 Work_EIM->EIM_CODIGO := cNewCode
          If lEIM_NCM
             Work_EIM->EIM_NCM    := Work->WKTEC
          EndIf
          Work_EIM->WK_RECNO   := 0//EIM->(Recno())           //NCF - 09/11/2012
			 cClassif             := Work_EIM->EIM_NIVEL
			 EIM->(DbSkip())   
		  EndDo
		  DI500GEIMGrv(cNewCode)      
	  ELSE
	     //TABELA NVE DA LI VAZIA - IGNORA
	     Work->WK_NVE := ""
	  EndIf
   Else
      cRet := aTabsNVEDI [nPosNVEDI][3]
      Work_SW8->WKNVETIPO := cFaseOri
   EndIf
Else
   //Grava do SW5/SB1 para SW7 direto
   cRet := cTabNVE
   Work_SW8->WKNVETIPO := cFaseOri
   //Copiar Tabela registros de NVE da fase PLI para a fase DI
   EIM->(DbSetOrder(3))
   EIM->(DbSeek( cSeekEIM ))
   
   //Do While EIM->(!EOF()) .AND. EIM->EIM_FILIAL == xFilial("EIM") .And. EIM->EIM_HAWB == AvKey(SW5->W5_PGI_NUM,"EIM_HAWB") .And. EIM->EIM_CODIGO == SW5->W5_NVE .AND. EIM->EIM_FASE == "LI"      //Loop para alterar tabela NVE de PLI para DI 
   Do While EIM->(!EOF()) .And. EIM->(EIM_FILIAL+EIM_HAWB+EIM_CODIGO+EIM_FASE) == cWhileEIM 
      Work_EIM->(DbAppend())
      AvReplace("EIM","Work_EIM")
      Work_EIM->EIM_FASE   := "DI"
      Work_EIM->EIM_HAWB   := M->W6_HAWB
      Work_EIM->EIM_CODIGO := cTabNVE
      If lEIM_NCM
         Work_EIM->EIM_NCM    := Work->WKTEC
      EndIf
      Work_EIM->WK_RECNO   := 0//EIM->(Recno())             //NCF - 09/11/2012
      cClassif             := Work_EIM->EIM_NIVEL
      EIM->(DbSkip())   
   EndDo
   
   If cFaseOri == "LI"
      aAdd(aTabsNVEDI, { SW5->W5_PGI_NUM, cTabNVE  , cTabNVE })                                                      //Adiciona no array
   ElseIf cFaseOri == "CD"
      aAdd(aTabsNVEDI, { Work->WKCOD_I  , cTabNVE , cTabNVE })                                                      //Adiciona no array                                                     
   EndIf

   If Work_GEIM->(EasyRecCount("Work_GEIM")) == 0
      If cFaseOri == "LI"
         DI500GEIMGrv(cTabNVE,SW5->W5_PGI_NUM)
      ElseIf cFaseOri == "CD"
         DI500GEIMGrv(cTabNVE, Work->WKCOD_I)
      EndIf
   EndIf
EndIf
lGravaEIM:=.T.
RestOrd(aOrdNVE,.T.)

RETURN cRet

/*
Função:    DI501SeqInstrDe()
Autor:     Flavio D. Ricardo
Data:      30/01/2012
Descrição: Função para preenchimento sequencial do campo EIF_SEQUEN
Revisão:
Observação: função migrada do programa EICDI500
*/
Function DI501SeqInstrDe()

Local aOrd := SaveOrd("Work_TEMP")
Local nPosIt := 0
local lGrvNum := .F.

   Work_TEMP->(DbSetOrder(0))
   Work_TEMP->(DbGoTop())
   Do While Work_TEMP->(!Eof())
      If (Val(Work_TEMP->EIF_SEQUEN) > nPosit) .And. !Empty(Work_TEMP->EIF_DOCTO)//Verifica se o cod. do item está preenchido pois o registro
         nPosit := Val(Work_TEMP->EIF_SEQUEN)                             //pode ser "Lixo" da getdb
      EndIf
      Work_TEMP->(DbSkip())
   End Do

RestOrd(aOrd,.T.)

IF !lGrvNum
   nPosIt++
EndIf

Return StrZero(nPosIt,4,0)

/*
Função    : DI501AdmEntre()
Autor     : Felipe Sales Martinez
Data      : 14/05/2012
Descrição : Verifica se o P.O informado possui itens anuentes e
            se o fluxo a seguir vai ser de Admissao em Entreposto. Desta forma
            executa algumas funcionalidade para tal fluxo.
Observação: função migrada do programa EICDI500
*/
Function DI501AdmEntre()
Local lRet := .F., lMsg := .T.
Local aOrd := {}, aCab   := {}, aItem  := {}, aOrdWk := {}, aIDXWK := {}, cOldAlias := Alias()
Private lMsErroAuto := .F.

If Type("M->W6_TIPODES")=="C" .And. AllTrim(UPPER(M->W6_TIPODES)) $ "02/03/04" .And. M->W6_TIPOFEC <> "DIN"

   If Type("lContAdm")=="U" .Or. !lContAdm
      lContAdm := .T.
   EndIf

   aOrd := SaveOrd({"SW2","SW3"})
   SW2->(DbSetOrder(1))
   SW3->(DbSetOrder(1))

   If SW2->( DBSeek(xFilial("SW2")+M->W6_PO_NUM) ) .And. SW3->( DbSeek(xFilial("SW3")+M->W6_PO_NUM) )

      aCab := DI500PrePOEXA(.T.)
      aAdd( aPOAdm, {M->W6_PO_NUM} )
      nContPo++

      Do While SW3->(!Eof()) .And. SW3->W3_PO_NUM == M->W6_PO_NUM .And. lContAdm
         If SW3->W3_FLUXO == "1" .And. SW3->W3_QTDE == SW3->W3_SALDO_Q
            If lMsg
               lContAdm := MsgYesNo(STR0218, STR0001) // #"O processo informado possui item(ns) sem Licença de Importação (L.I.). Deseja criar a L.I. para este(s) item(ns) na fase de 'Desembaraço de Nacionalização'?" ##"Atenção"
               lMsg := .F.
            EndIf
            If lContAdm
               aAdd(aItem, DI500PrePOEXA(.F.))
               aAdd( aPOAdm[nContPo], {SW3->W3_PO_NUM+SW3->W3_POSICAO} )
               lRet := .T.
             EndIf
         EndIf
         SW3->(DbSkip())

      EndDo

      If lRet
         aOrdWk := SaveOrd({"Work"})
         aIDXWK := EasySaveIdx("Work")

         If Select("WORK") > 0
            Work->( DBCloseArea() )
            DBSelectArea(cOldAlias)
         EndIf

         MSExecAuto({|a,b,c,d| EICPO400(a,b,c,d)},NIL,aCab,aItem,4) //Alteração de todos os produtos anuentes do P.O para não-anuente.

         If Select("WORK") > 0
            Work->( DBCloseArea() )
         EndIf

         TETempReopen(cWorkName, "Work")
         EasyRestIdx(aIDXWK, "Work")
         RestOrd(aOrdWk,.T.)

         If lMsErroAuto
            MOSTRAERRO()
         EndIf
      EndIf
   EndIf
   RestOrd(aOrd,.T.)
   DBSelectArea(cOldAlias)

EndIf

Return lRet

/*
Função    : DI501EstAdmEntre()
Autor     : Felipe Sales Martinez
Data      : 14/05/2012
Descrição : Verifica se o P.O informado possui itens anuentes e
            se o fluxo a seguir vai ser de Admissao em Entreposto. Desta forma
            executa algumas funcionalidade para tal fluxo.
Observação: função migrada do programa EICDI500
*/
Function DI501EstAdmEntre()
Local lRet := .F.
Local aOrd := {}, aCab   := {}, aItem  := {}, aOrdWk := {}, aIDXWK := {}, cOldAlias := If(UPPER(Alias())=="WORK","SW6",Alias())
Local i := 0, j := 0
Private lMsErroAuto := .F.

If Type("M->W6_TIPODES")=="C" .And. AllTrim(UPPER(M->W6_TIPODES)) $ "02/03/04" .And. M->W6_TIPOFEC <> "DIN"

   If Type("lContAdm")=="U" .Or. !lContAdm
      lContAdm := .T.
   EndIf

   aOrd := SaveOrd({"SW2","SW3"})
   SW2->(DbSetOrder(1))
   SW3->(DbSetOrder(8))
   For i := 1 To len(aPoAdm)
       lRet := .F.
       cNumPO := aPoAdm[i][1]
       If SW2->( DBSeek(xFilial("SW2")+cNumPO) )
          aCab := DI500PrePOEXA(.T.)

          For j := 2 To len(aPoAdm[i])
              If SW3->( DbSeek(xFilial("SW3")+aPoAdm[i][j][1]) )
                 aAdd(aItem, DI500PrePOEXA(.F.,.T.))
                 lRet := .T.
              EndIf
          Next j

          If lRet
             aOrdWk := SaveOrd({"Work"})
             aIDXWK := EasySaveIdx("Work")

             If Select("WORK") > 0
                Work->( DBCloseArea() )
                DBSelectArea(cOldAlias)
             EndIf

             MSExecAuto({|a,b,c,d| EICPO400(a,b,c,d)},NIL,aCab,aItem,4) //Alteração de todos os produtos anuentes do P.O para não-anuente.

             If Select("WORK") > 0
                Work->( DBCloseArea() )
             EndIf

             TETempReopen(cWorkName, "Work")
             EasyRestIdx(aIDXWK, "Work")
             RestOrd(aOrdWk,.T.)

             If lMsErroAuto
               MOSTRAERRO()
             EndIf
          EndIf
       EndIf

   Next i
   RestOrd(aOrd,.T.)
   DBSelectArea(cOldAlias)

EndIf

Return lRet

/*
Função    : DI500PrePOEXA()
Autor     : Felipe Sales Martinez
Data      : 14/05/2012
Descrição : Prepara arrays de capa e item para o ExecAuto do P.O
Obs.      : função migrada do programa EICDI500
*/
*-----------------------------------*
Static Function DI500PrePOEXA(lCapa, lEstorno)
*-----------------------------------*
Local aInfo := {}
Default lEstorno := .F.
If lCapa
   aAdd(aInfo,{"W2_PO_NUM"    ,SW2->W2_PO_NUM    ,NIL})
   aAdd(aInfo,{"W2_PO_DT"     ,SW2->W2_PO_DT     ,NIL})
   aAdd(aInfo,{"W2_FORN"      ,SW2->W2_FORN      ,NIL})
   aAdd(aInfo,{"W2_COMPRA"    ,SW2->W2_COMPRA    ,NIL})
   aAdd(aInfo,{"W2_IMPORT"    ,SW2->W2_IMPORT    ,NIL})
   aAdd(aInfo,{"W2_AGENTE"    ,SW2->W2_AGENTE    ,NIL})
   aAdd(aInfo,{"W2_TIPO_EM"   ,SW2->W2_TIPO_EM   ,NIL})
   aAdd(aInfo,{"W2_ORIGEM"    ,SW2->W2_ORIGEM    ,NIL})
   aAdd(aInfo,{"W2_DEST"      ,SW2->W2_DEST      ,NIL})
   aAdd(aInfo,{"W2_INCOTER"   ,SW2->W2_INCOTER   ,NIL})
   aAdd(aInfo,{"W2_FREPPCC"   ,SW2->W2_FREPPCC   ,NIL})
   aAdd(aInfo,{"W2_COND_PA"   ,SW2->W2_COND_PA   ,NIL})
   aAdd(aInfo,{"W2_MOEDA"     ,SW2->W2_MOEDA     ,NIL})
   aAdd(aInfo,{"W2_DT_PAR"    ,SW2->W2_DT_PAR    ,NIL})
   aAdd(aInfo,{"W2_PARID_U"   ,SW2->W2_PARID_U   ,NIL})
   aAdd(aInfo,{"W2_E_LC"      ,SW2->W2_E_LC      ,NIL})

Else
   aInfo := {{"W3_COD_I"  ,  SW3->W3_COD_I   ,NIL},;
            {"W3_PO_NUM"  ,  SW3->W3_PO_NUM  ,NIL},;
            {"W3_CC"      ,  SW3->W3_CC      ,NIL},;
            {"W3_SI_NUM"  ,  SW3->W3_SI_NUM  ,NIL},;
            {"W3_COD_I"   ,  SW3->W3_COD_I   ,NIL},;
            {"W3_FLUXO"   ,  If(lEstorno,"1","7"),NIL},;
            {"W3_REG"     ,  SW3->W3_REG     ,NIL},;
            {"W3_PRECO"   ,  SW3->W3_PRECO   ,NIL},;
            {"W3_FABR"    ,  SW3->W3_FABR    ,NIL},;
            {"W3_FORN"    ,  SW3->W3_FORN    ,NIL},;
            {"W3_QTDE"    ,  SW3->W3_QTDE    ,NIL},;
            {"W3_SALDO_Q" ,  SW3->W3_SALDO_Q ,NIL},;
            {"W3_DT_EMB"  ,  SW3->W3_DT_EMB  ,NIL},;
            {"W3_DT_ENTR" ,  SW3->W3_DT_ENTR ,NIL},;
            {"W3_ALTANU"  ,  If(lEstorno,"","2") ,NIL}}
EndIf

Return aClone(aInfo)

/*
Função    : EasySaveIdx()
Autor     : Felipe Sales Martinez
Data      : 14/05/2012
Descrição : Salva em um array (aIndex) todas as ordens de uma Alias.
Return    : aIndex - aIndex[X][1] -> Ordem do índice
                   - aIndex[X][2] -> Chave do índice
                   - aIndex[X][3] -> Nome do arquivo de indice ao qual a ordem pertence
Observação: função migrada do programa EICDI500
*/
Static Function EasySaveIdx(cWork)
Local i := 1, nMax := 0
Local cOldAlias := Alias()
Local aIndex := {/*Ordem,Chave,Arquivo*/}
Local aOrd := {}

If !Empty(cWork)
   DBSelectArea(cWork)
   /* Parametros da Funcao dbOrderInfo:
     7  - Nome do arquivo de indice ao qual a ordem pertence
     9  - Quantidade de ordens existentes no arquivo de índices es´pecificado
     20 - Nome do arquivo de indice (com seu diretorio) ao qual a ordem pertence
   */
   nMax := dbOrderInfo(9) //dbOrderInfo(DBOI_OrderCount)
   aOrd := SaveOrd(cWork)

   For i := 1 To nMax
       If !Empty( (cWork)->( IndexKey(i) ) )
          (cWork)->( DBSetOrder(i) )
          aAdd(aIndex, { i, (cWork)->(IndexKey()), dbOrderInfo(7) })
       EndIf
   Next
   RestOrd(aOrd)
   DBSelectArea(cOldAlias)
EndIf

Return aIndex

/*
Função    : EasyRestIdx()
Autor     : Felipe Sales Martinez
Data      : 14/05/2012
Descrição : Restaura os índices salvos pela função EasySaveIdx().
Return    : .T.
Observação: função migrada do programa EICDI500
*/
Static Function EasyRestIdx(aIdx,cWork)
Local lRet := .F.
Local nPos := 0, i := 0
Local cFileIdx := ""
local cOldAlias := Alias()

If !Empty(aIdx)
   If Empty(cWork)
      cWork := Alias()
   Else
      DBSelectArea(cWork)
   EndIf

   For i := 1 To Len(aIdx)
       nPos  := aScan(aIdx, {|x| x[1] == i }) //numero da ordem
       cFileIdx := aIdx[nPos][3] //Nome do arquivo do indice
       (cWork)->(DBSetindex(cFileIdx))
   Next i

   DBSelectArea(cOldAlias)
   lRet := .T.
EndIf
Return lRet

/*
Funcao      : DI501ValTipDes()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
Function DI501ValTipDes()

If !Empty(M->W6_PO_NUM)
   If EasyGParam("MV_AVG0211",,.F.) .And. DI500AdmEntre()
      Return .T.
   EndIf
Endif

Return .T.

/*
Função    : DI500PLIAntes()
Autor     : Felipe Sales Martinez
Data      : 24/05/2012
Descrição : Verifica se existe uma PLI (Não Automatica) na primeira importação
Return    : lRet
Observação: função migrada do programa EICDI500
*/
Static Function DI500PLIAntes(cOpcPli)

Local lRet := .F.
Local aPLIAntsOrd := SaveOrd("SW3")
Local cPli := "", cChave := ""
Default cOpcPli := "INCLUSAO"

SW3->( DBSetOrder(8))

If UPPER(cOpcPli) == "ESTORNO"

   If SW3->( DBSeek( xFilial("SW3")+TRB->(W7_PO_NUM+W7_POSICAO) ) )
      cPli := Work->(WKPGI_NUM)
      If !DI500LIAutomatica(cPli)
         If SW3->( DBSeek( xFilial("SW3")+SW3->(W3_PO_DA+W3_POSI_DA) ) )
            cChave := SW3->(W3_FILIAL+W3_PO_NUM+W3_POSICAO)

            Do While SW3->(!EOF()) .And. cChave == SW3->(W3_FILIAL+W3_PO_NUM+W3_POSICAO)
               If SW3->(W3_FLUXO) == "1" .And. SW3->W3_PGI_NUM == cPli
                  lRet := .T. //!Empty(SW3->(W3_PGI_NUM))
               EndIf
               SW3->( DBSkip() )
            EndDo
         EndIf
      EndIf
   EndIf

Else

   If SW3->( DBSeek( xFilial("SW3")+Work->(WKPO_NUM+WKPOSICAO) ) )
      cPli := Work->(WKPGI_NUM)
      If !DI500LIAutomatica(cPli)
         If SW3->( DBSeek( xFilial("SW3")+SW3->(W3_PO_DA+W3_POSI_DA) ) )
            cChave := SW3->(W3_FILIAL+W3_PO_NUM+W3_POSICAO)

            Do While SW3->(!EOF()) .And. cChave == SW3->(W3_FILIAL+W3_PO_NUM+W3_POSICAO)
               If SW3->(W3_FLUXO) == "1" .And. SW3->W3_PGI_NUM == cPli
                  lRet := .T. //!Empty(SW3->(W3_PGI_NUM))
               EndIf
               SW3->( DBSkip() )
            EndDo
         EndIf
      EndIf
   EndIf

EndIf
RestOrd(aPLIAntsOrd)
Return lRet

/*
Função    : DI501LIAutomatica()
Autor     : Felipe Sales Martinez
Data      : 24/05/2012
Descrição : Verifica se a PLI é Automatica
Return    : .T. - > PLI/L.I Automatica / .F. -> L.I. Manual
Observação: função migrada do programa EICDI500
*/
Function DI501LIAutomatica(cCampo)
Return ( At("*", cCampo )==1 .And. Rat("*", cCampo )==Len(cCampo) )

/*
Funcao      : DI501Check_adic()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
Function DI501Check_adic(cAdic) /// 03/08/12 - BCO - Validação para o Campo EIN_ADICAO não ser gravado vazio
Local lRet

If Empty(cAdic)
   msginfo("Erro ao gravar o campo 'EIN_ADICAO' na linha " + STR(Procline(1)),)
   lRet := .F.
Else
   lRet := .T.
endif

Return lRet

/*
Funcao      : DI501STATUS()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data 	     :
Obs         : Função migrada do programa EICDI500
Revisão     :
*/
Function DI501STATUS(cHawb)
Local cStatus

Posicione("SW6",1,xFilial("SW6")+AvKey(cHawb,"W6_HAWB"),"")

If !Empty(SW6->W6_DT_ENCE)
   cStatus := "06"//"Encerrado"

ElseIf !Empty(SW6->W6_DT_ENTR)
   cStatus := "05"//"Entregue"

ElseIf !Empty(SW6->W6_DT_DESEM)
   cStatus := "04"//"Aguardando entrega"

ElseIf !Empty(SW6->W6_CHEG)
   cStatus := "03"//"Aguardando desembaraço"

ElseIf !Empty(SW6->W6_DT_EMB)
   cStatus := "02"//"Aguardando atracação"

Else
   cStatus := "01"//Aguardando embarque"

EndIf

Return cStatus

/*
Função    : getTaxa()
Objetivo  : Pegar a taxa para converter os valores dos campos da aba "Valores D.I."
Retorno   : Nulo
Parametro : aCols - Cotações das moedas digitadas na tela Outra ações-Taxas
Autor     : Maurício Frison Miguel Prado Gontijo - MPG
Data      : 03/02/2020
*/
*---------------------------*
Static Function getTaxa(aCols, cInvMoe, lReais, nTx_Fob, nTx_Us)
Local nRetorno

Default aCols := {}
Default lWork := .F.

If lReais // valor em Reais
   if len(aCols) > 0
      nRetorno := aCols[aScan(aCols,{|x| x[1] == cInvMoe})][2] 
   Else
      //nRetorno := SW9->W9_TX_FOB
      nRetorno := nTx_Fob
   EndIf
Else //converter para dólar
   if cInvMoe == cMoeDolar
      nRetorno := 1
   ElseIf len(aCols) > 0
      nRetorno := aCols[aScan(aCols,{|x| x[1] == cInvMoe})][2] / aCols[aScan(aCols,{|x| x[1] == cMoeDolar})][2]
   Else
            //   TX MOE INVOICE    TX MOE DOLAR   
      //nRetorno := SW9->W9_TX_FOB / SW6->W6_TX_US_D         
      nRetorno := nTx_Fob / nTx_Us   
   EndIf
EndIf

Return nRetorno

/*
Função    : AtuVlDI()
Objetivo  : Atualizar os campos da aba "Valores D.I."
Retorno   : Nulo
Parametro : cW6Hawb - Código da Hawb a ter os valores gerados
Autor     : Miguel Prado Gontijo - MPG
Data      : 03/02/2020
*/
*---------------------------*
Static Function AtuVlDI(cW6Hawb,aCols,lmem, lWork)
*---------------------------*
Local lVlDIMoe := EasyGParam("MV_VLDIMOE",,.T.)
Local aAreaSW6 := SW6->( getArea() )
Local aAreaSW8 := SW8->( getArea() )
Local aAreaSW9 := SW9->( getArea() )
Local nTotGerRS := nTotSW9_R := nFobItem := MDI_FOB_R := MDespMoe := MDespesas := nSeguro := nInland := nPacking := nDescont := nOutDesp := nFrete := 0
Local cChave 
Local nTaxa
Local cFilSW9:= SW9->(xFilial())
Default cW6Hawb:= SW6->W6_HAWB
Default aCols := {}
Default lMem      := .F. //por padrao vai gravar para continuar funcionando as outras chamadas desta rotina
Default lWork  := .F. //por padrao vai gravar para continuar funcionando as outras chamadas desta rotina

If !lWork
   If SW8->(DBSEEK(xFilial("SW8")+cW6Hawb))
      SW9->(dbSetOrder(1))
      cChave:=''
      DO WHILE !SW8->(EOF()) .AND. SW8->W8_FILIAL == xFilial("SW8") .AND. SW8->W8_HAWB == cW6Hawb
         If cChave # cFilSW9+SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8", "W8_FORLOJ")+SW8->W8_HAWB
            SW9->(DbSeek(cFilSW9+SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8", "W8_FORLOJ")+SW8->W8_HAWB))
            cChave := cFilSW9+SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8", "W8_FORLOJ")+SW8->W8_HAWB
            nTaxa := getTaxa(aCols,SW9->W9_MOE_FOB,lVlDIMoe,SW9->W9_TX_FOB,SW6->W6_TX_US_D)
         EndIf
         nFobItem := DITRANS(SW8->W8_PRECO*SW8->W8_QTDE,2)
         MDI_FOB_R += nFobItem * nTaxa
         SW8->(dbSkip())
      ENDDO

      MDI_FOB_R:= DITrans(MDI_FOB_R, 2)

      SW9->(DBSETORDER(3))
      SW9->(DbSeek(xFilial("SW9")+cW6Hawb))

      DO WHILE ! SW9->(EOF()) .AND. SW9->W9_FILIAL == xFilial("SW9") .AND. SW9->W9_HAWB == cW6Hawb

         MDespMoe := DI500RetVal("TOT_INV,SEM_FOB", "TAB", .T.,, .T.)

         nTaxaFob := getTaxa(aCols,SW9->W9_MOE_FOB,lVlDIMoe,SW9->W9_TX_FOB,SW6->W6_TX_US_D)
         nInland  += SW9->W9_INLAND  * nTaxaFob
         nPacking += SW9->W9_PACKING * nTaxaFob
         nDescont += SW9->W9_DESCONT * nTaxaFob
         nOutDesp += SW9->W9_OUTDESP * nTaxaFob
         nFrete   += IF(AvRetInco(SW9->W9_INCOTER,"CONTEM_FRETE") .AND. SW9->W9_FREINC $ cNao, SW9->W9_FRETEIN,0) * nTaxaFob
         nSeguro  += IF(AvRetInco(SW9->W9_INCOTER,"CONTEM_SEG")   .AND. SW9->W9_SEGINC $ cNao, SW9->W9_SEGURO,0) * nTaxaFob
         MDespesas += DITRANS( MDespMoe * nTaxaFob , 2)
         nTotSW9_R += DI500TRANS( SW9->W9_FOB_TOT , 2) * nTaxaFob

         SW9->(DBSKIP())

      ENDDO
      
   Endif
Else
   Work_SW9->(DBGOTOP())
   DO WHILE !Work_SW9->(EOF())
      MDespMoe := DI500RetVal("TOT_INV,SEM_FOB", "WORK", .T.,, .T.)

      nTaxaFob := getTaxa(/*aCols*/, Work_SW9->W9_MOE_FOB, lVlDIMoe,Work_SW9->W9_TX_FOB,M->W6_TX_US_D)
      nInland  += Work_SW9->W9_INLAND  * nTaxaFob
      nPacking += Work_SW9->W9_PACKING * nTaxaFob
      nDescont += Work_SW9->W9_DESCONT * nTaxaFob
      nOutDesp += Work_SW9->W9_OUTDESP * nTaxaFob
      nFrete   += IF(AvRetInco(Work_SW9->W9_INCOTER,"CONTEM_FRETE") .AND. Work_SW9->W9_FREINC $ cNao, Work_SW9->W9_FRETEIN,0) * nTaxaFob
      nSeguro  += IF(AvRetInco(Work_SW9->W9_INCOTER,"CONTEM_SEG") .AND. Work_SW9->W9_SEGINC $ cNao, Work_SW9->W9_SEGURO,0) * nTaxaFob
      MDespesas += DITRANS( MDespMoe * nTaxaFob , 2)
      nTotSW9_R += DI500TRANS( Work_SW9->W9_FOB_TOT , 2) * nTaxaFob
      
      Work_SW8->(dbSetOrder(1))
      Work_SW8->(dbSeek(Work_SW9->W9_INVOICE + Work_SW9->W9_FORN + Work_SW9->W9_FORLOJ))
      Do While !Work_SW8->( EOF() )  .And.  Work_SW8->WKINVOICE == Work_SW9->W9_INVOICE  .And.  ;
               Work_SW8->WKFORN==Work_SW9->W9_FORN .And. Work_SW8->W8_FORLOJ == Work_SW9->W9_FORLOJ
         IF EMPTY(Work_SW8->WKFLAGIV) .OR. EMPTY(Work_SW8->WKINVOICE)
            Work_SW8->(DBSKIP())
            LOOP
         ENDIF
         
         nFobItem := DITRANS(Work_SW8->WKPRECO * Work_SW8->WKQTDE, 2)
         MDI_FOB_R += nFobItem * nTaxaFob

         Work_SW8->(DBSKIP())
      EndDo

      MDI_FOB_R:= DITrans(MDI_FOB_R, 2)

      Work_SW9->(DBSKIP())
   ENDDO
EndIf

MDI_FOB_R += MDespesas
nTotGerRS := nTotSW9_R + di500trans(nInland,2)+di500trans(nPacking,2)+di500trans(nFrete,2)+di500trans(nOutDesp,2)+di500trans(nSeguro,2)-di500trans(nDescont,2)  
If lMem
   M->W6_FOB_GER := nTotGerRS
   M->W6_FOB_TOT := nTotSW9_R
   M->W6_VLMLEMN := MDI_FOB_R
   M->W6_INLAND  := nInland
   M->W6_PACKING := nPacking
   M->W6_FRETEIN := nFrete
   M->W6_OUTDESP := nOutDesp
   M->W6_DESCONT := nDescont
   M->W6_SEGINV := nSeguro

   M->W6_TOT_PRO := nTotSW9_R+nInland+nPacking+nSeguro+nFrete+nOutDesp-nDescont
Else
   IF SW6->(DBSEEK(xFilial()+cW6Hawb))
      SW6->(RECLOCK("SW6",.F.))

      SW6->W6_FOB_GER := nTotGerRS
      SW6->W6_FOB_TOT := nTotSW9_R
      SW6->W6_VLMLEMN := MDI_FOB_R
      SW6->W6_INLAND  := nInland
      SW6->W6_PACKING := nPacking
      SW6->W6_FRETEIN := nFrete
      SW6->W6_OUTDESP := nOutDesp
      SW6->W6_DESCONT := nDescont
      SW6->W6_SEGINV  := nSeguro

      SW6->(MSUNLOCK())
   EndIf   
ENDIF


restArea(aAreaSW6)
restArea(aAreaSW8)
restArea(aAreaSW9)

Return

/*
Função    : DI501ExcTit()
Objetivo  : Efetua exclusão do titulo da despesa selecionada.
Retorno   : aRet
Parametro : NIL
Autor     : Guilherme Fernandes Pilan - GFP
Data      : 21/02/2013 :: 10:18
Observação: NCF - 09/04/2020 - Função resumida e renomeada para excluir o título da despesa
                               e possíveis títulos de taxas acessórias via rotina automática.
*/
Static Function DI501ExcTit()
Local lRet

If lRet := FI400TITFIN("SWD","4")
   TRB->WD_DOCTO   := ""
   TRB->WD_CTRFIN1 := ""
   TRB->WD_PARCELA := ""
   TRB->WD_TIPO    := ""
   TRB->WD_DTENVF  := CtoD("")
   MsgInfo(STR0219,STR0053) //"Titulo excluído com sucesso." ### "Aviso"
EndIf

Return lRet

/*
Programa   : GeraTaxas()
Objetivo   : Buscar as taxas de todas as moedas do processo em questão
Autor      : Guilherme Fernandes Pilan - GFP
Data       : 08/10/2014 - 10:57
Observação : função migrada do programa EICDI500
*/
*----------------------------*
Static Function GeraTaxas()
*----------------------------*
Local aDados := {}, aOrdSW9 := SaveOrd({"SW9"})
Local cTXSW9 := IF(Work_SW9->(EasyRecCount("Work_SW9"))>0, "Work_SW9", "SW9")
Local nRecWKSW9 := 0
Local aDbf :={ {"W6_TX_US_D" ,AVSX3("W6_TX_US_D",2),AVSX3("W6_TX_US_D",3) ,AVSX3("W6_TX_US_D",4)},;
			   {"W9_MOE_FOB" ,AVSX3("W9_MOE_FOB",2),AVSX3("W9_MOE_FOB",3) ,AVSX3("W9_MOE_FOB",4)},;
               {"W9_TX_FOB"  ,AVSX3("W9_TX_FOB",2) ,AVSX3("W9_TX_FOB",3)  ,AVSX3("W9_TX_FOB",4)},;
               {"W6_SEGMOED" ,AVSX3("W6_SEGMOED",2),AVSX3("W6_SEGMOED",3) ,AVSX3("W6_SEGMOED",4)},;
               {"W6_TX_SEG"  ,AVSX3("W6_TX_SEG",2) ,AVSX3("W6_TX_SEG",3)  ,AVSX3("W6_TX_SEG",4)},;
               {"W6_FREMOED" ,AVSX3("W6_FREMOED",2),AVSX3("W6_FREMOED",3) ,AVSX3("W6_FREMOED",4)},;
               {"W6_TX_FRET" ,AVSX3("W6_TX_FRET",2),AVSX3("W6_TX_FRET",3) ,AVSX3("W6_TX_FRET",4)}}

   FileWork := E_CriaTrab(,aDbf,"WKTAXAS") //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados

   IndRegua("WKTAXAS",FileWork+TEOrdBagExt(),"W9_MOE_FOB")

   nRecWKSW9 := Work_SW9->(Recno())
   Work_SW9->(DbGoTop())
   WKTAXAS->(DbSetOrder(1))

   IF cTXSW9 $ "Work_SW9,SW9"
      IF cTXSW9 == "Work_SW9"
         Do While Work_SW9->(!Eof())
   			If !WKTAXAS->(DbSeek(Work_SW9->W9_MOE_FOB))
   				WKTAXAS->(DbAppend())
   				WKTAXAS->W9_MOE_FOB := Work_SW9->W9_MOE_FOB
   				WKTAXAS->W9_TX_FOB  := Work_SW9->W9_TX_FOB
   				WKTAXAS->W6_TX_US_D := M->W6_TX_US_D
   			EndIf
   			Work_SW9->(DbSkip())
   		 EndDo
   		 Work_SW9->(DbGoTo(nRecWKSW9))
      ELSEIF cTXSW9 == "SW9" //LGS-19/03/2015
         SW9->(DbSetOrder(3))
         IF SW9->(DbSeek(xFilial("SW9")+M->W6_HAWB))
            Do While SW9->(!Eof()) .And. SW9->W9_HAWB == M->W6_HAWB
               WKTAXAS->(DbAppend())
               WKTAXAS->W9_MOE_FOB := SW9->W9_MOE_FOB
               WKTAXAS->W9_TX_FOB  := SW9->W9_TX_FOB
               WKTAXAS->W6_TX_US_D := M->W6_TX_US_D
               SW9->(DbSkip())
            EndDo
         ELSE
            WKTAXAS->(DbAppend()) //Taxa  //MCF - 20/01/2015
            WKTAXAS->W6_TX_US_D  := M->W6_TX_US_D
            WKTAXAS->W9_MOE_FOB := cMoeDolar
         ENDIF
         RestOrd(aOrdSW9, .T.)
      ENDIF
   ENDIF

   If !Empty(SW6->W6_SEGMOED) .OR. !Empty(M->W6_SEGMOED) //Seguro
   		If SW6->W6_TX_SEG # M->W6_TX_SEG
   			Reclock("WKTAXAS",.F.)
   			WKTAXAS->W6_SEGMOED := M->W6_SEGMOED
   			WKTAXAS->W6_TX_SEG  := M->W6_TX_SEG
   			WKTAXAS->(MSUnlock())
   		Else
	   		Reclock("WKTAXAS",.F.)
	   		WKTAXAS->W6_SEGMOED := SW6->W6_SEGMOED
	   		WKTAXAS->W6_TX_SEG  := SW6->W6_TX_SEG
	   		WKTAXAS->(MSUnlock())
	   	Endif
   	EndIf

   	If !Empty(SW6->W6_FREMOED) .OR. !Empty(M->W6_FREMOED) //Frete
   		If SW6->W6_TX_FRET # M->W6_TX_FRET
   			Reclock("WKTAXAS",.F.)
   			WKTAXAS->W6_FREMOED := M->W6_FREMOED
   			WKTAXAS->W6_TX_FRET  := M->W6_TX_FRET
   			WKTAXAS->(MSUnlock())
   		Else
	   		Reclock("WKTAXAS",.F.)
	   		WKTAXAS->W6_FREMOED := SW6->W6_FREMOED
	   		WKTAXAS->W6_TX_FRET := SW6->W6_TX_FRET
	   		WKTAXAS->(MSUnlock())
	   	Endif
   	EndIf

WKTAXAS->(DbGoTop())
Do While WKTAXAS->(!Eof())  // GFP - 18/11/2014
   If aScan(aDados,{|x| x[1] == WKTAXAS->W9_MOE_FOB}) == 0
      aAdd(aDados,{WKTAXAS->W9_MOE_FOB, If(WKTAXAS->W9_MOE_FOB == "US$",WKTAXAS->W6_TX_US_D,WKTAXAS->W9_TX_FOB),.F.})
   EndIf
   If WKTAXAS->(FieldPos("W6_SEGMOED"))>0 .And. aScan(aDados,{|x| x[1] == WKTAXAS->W6_SEGMOED}) == 0 .And. WKTAXAS->W6_TX_SEG # 0 //MCF - 20/01/2015
      aAdd(aDados,{WKTAXAS->W6_SEGMOED, WKTAXAS->W6_TX_SEG,.F.})
   EndIf
   If WKTAXAS->(FieldPos("W6_FREMOED"))>0 .And. aScan(aDados,{|x| x[1] == WKTAXAS->W6_FREMOED}) == 0 .And. WKTAXAS->W6_TX_FRET # 0
      aAdd(aDados,{WKTAXAS->W6_FREMOED, WKTAXAS->W6_TX_FRET,.F.})
   EndIf
   If aScan(aDados,{|x| x[1] == cMoeDolar}) == 0
      aAdd(aDados,{cMoeDolar, WKTAXAS->W6_TX_US_D,.F.})
   EndIf
   WKTAXAS->(DbSkip())
EndDo
If(Select("WKTAXAS") # 0,WKTAXAS->(DbCloseArea()),)
Return aDados

/*
Programa   : AlterouDesp()
Objetivo   : Verificar se houve alteração nas informações da despesa que
             impliquem em reenvio da mensagem única
Autor      : WFS
Data       : 01/2015
Observação :
*/
Static Function AlterouDesp()
Return CA150CHANGE()

/*
Programa   : LegDespesa()
Objetivo   : Retornar a legenda de cores para identificação dos status das despesas do desembaraço
Autor      : WFS
Data       : Fev/2015
Observação :
*/
Static Function LegDespesa()
Local aDefCores:= {}

Begin Sequence

   /* disponível para cenários de integração via EAI */
   If !AvFlags("EIC_EAI")
      Break
   EndIf

   AAdd(aDefCores, {"TRB->WKSTATUS == 'A'", "BR_CINZA"   }) //Despesa não integrada ao ERP
   AAdd(aDefCores, {"TRB->WKSTATUS == 'B'", "BR_LARANJA" }) //Despesa aguardando prestação de contas (não integrada)
   AAdd(aDefCores, {"TRB->WKSTATUS == 'C'", "BR_BRANCO"  }) //Adiantamento com Saldo
   AAdd(aDefCores, {"TRB->WKSTATUS == 'D'", "BR_VERDE"   }) //Documento desbloqueado no ERP
   AAdd(aDefCores, {"TRB->WKSTATUS == 'E'", "BR_AMARELO" }) //Despesa aguardando prestação de contas
   AAdd(aDefCores, {"TRB->WKSTATUS == 'F'", "BR_VERMELHO"}) //Compensação parcial - documento bloqueado no ERP
   AAdd(aDefCores, {"TRB->WKSTATUS == 'G'", "BR_AZUL"}) //Compensação total
   AAdd(aDefCores, {"TRB->WKSTATUS == 'H'", "BR_PRETO"}) //Câmbio de importação

End Sequence
Return aDefCores

/*
Programa   : DI501AtuStatusDesp()
Objetivo   : Retornar o status da despesa
Autor      : WFS
Data       : Fev/2015
Observação :
*/
Function DI501AtuStatusDesp()
Local cStatus:= ""
Local aOrd:= SaveOrd({"SWB"})
Local nDvDesp := 0

SWB->(DBSetOrder(7))//WB_FILIAL + WB_HAWB + WB_EVENT + WB_PARCELA

Begin Sequence

   /* disponível para cenários de integração via EAI */
   If !AvFlags("EIC_EAI")
      Break
   EndIf
   
   If TRB->WD_DESPESA == "901"
        nDvDesp := DI501DVDES(SWD->WD_HAWB,SWD->WD_CTRFIN1) //THTS - 17/08/2017 - Verifica se adiantamento gerou devolucao
   EndIf

   Do Case
      /* Possíveis status das despesas não integradas ao ERP */
      Case Left(TRB->WD_DESPESA, 1) == "1" .And. SWB->(DBSeek(xFilial() + TRB->WD_HAWB + TRB->WD_DESPESA))
         cStatus:= "H" //Câmbio de importação

      Case Empty(TRB->WD_CTRFIN1) .And. TRB->WD_BASEADI == "2"
         cStatus:= "A" //Despesa não integrada ao ERP

      Case Empty(TRB->WD_CTRFIN1) .And. TRB->WD_BASEADI == "1"
         cStatus:= "B" //Despesa aguardando prestação de contas (não integrada)

      /* Possíveis status das despesas integradas ao ERP */
      Case TRB->WD_DESPESA == "901" .And. TRB->WD_VL_COMP + nDvDesp <> TRB->WD_VALOR_R .And. Empty(TRB->WD_DTENVF) //THTS - 17/08/2017
         cStatus:= "C" //Adiantamento com Saldo

      Case TRB->WD_BASEADI == "2" .Or. !Empty(TRB->WD_DTENVF)
         cStatus:= "D" //Documento desbloqueado no ERP

      /* Despesas base de adiantamento */
      Case TRB->WD_DESPESA <> "903" .And. TRB->WD_VL_COMP == 0 .And. nDvDesp <> TRB->WD_VALOR_R//THTS - 17/08/2017
         cStatus:= "E" //Despesa aguardando prestação de contas

      Case TRB->WD_VL_COMP + nDvDesp < TRB->WD_VLLIQ .And. Empty(TRB->WD_DTENVF) //.And. !lDvDesp //THTS - 17/08/2017
         cStatus:= "F" //Compensação parcial - documento bloqueado no ERP

      Case TRB->WD_VL_COMP == TRB->WD_VLLIQ .Or. DI501LGDESP()//TRB->WD_VALOR_R //THTS - 17/08/2017 - Verifica Status para despesas de Devolucao ao Despachante
         cStatus:= "G" //Compensação total

   End Case

End Sequence

RestOrd(aOrd, .T.)
Return cStatus

/*
Funcao    : DI501LegDesp()
Objetivos : Exibir a legenda dos status das despesas
Parametros:
Autor     : WFS
Data/Hora : Fev/ 2015
Obs.      :
*/

Static Function DI501LegDesp()
Local aLegenda:= {}
Begin Sequence

   /* disponível para cenários de integração via EAI */
   If !AvFlags("EIC_EAI")
      Break
   EndIf

   AAdd(aLegenda, {"BR_BRANCO"  , DI501DescLeg("C")}) //"Adiantamento com Saldo"
   AAdd(aLegenda, {"BR_CINZA"   , DI501DescLeg("A")}) //"Não integrada ao ERP"
   AAdd(aLegenda, {"BR_AMARELO" , DI501DescLeg("E")}) //"Aguardando prestação de contas"
   AAdd(aLegenda, {"BR_LARANJA" , DI501DescLeg("B")}) //"Aguardando prestação de contas (não integrada)"
   AAdd(aLegenda, {"BR_VERMELHO", DI501DescLeg("F")}) //"Compensação parcial - documento bloqueado no ERP"
   AAdd(aLegenda, {"BR_VERDE"   , DI501DescLeg("D")}) //"Documento desbloqueado no ERP"
   AAdd(aLegenda, {"BR_AZUL"    , DI501DescLeg("G")}) //"Compensação total"
   AAdd(aLegenda, {"BR_PRETO"   , DI501DescLeg("H")}) //"Câmbio de importação"

   BrwLegenda(cCadastro, STR0235, aLegenda) //Legenda //"Status das despesas"

End Sequence
Return


/*
Funcao    : DI501DescLeg()
Objetivos : Exibir a legenda dos status das despesas
Parametros: Código do status
Autor     : WFS
Data/Hora : Fev/ 2015
Obs.      :
*/

Static Function DI501DescLeg(cStatus)
Local cRet:= ""
Begin Sequence

   /* disponível para cenários de integração via EAI */
   If !AvFlags("EIC_EAI")
      Break
   EndIf

   Do Case
      Case cStatus == "A"
         cRet:= STR0229 //"Não integrada ao ERP"

      Case cStatus == "B"
         cRet:= STR0230 //"Aguardando prestação de contas"

      Case cStatus == "C"
         cRet:= STR0228 //"Adiantamento com Saldo"

      Case cStatus == "D"
         cRet:= STR0233 //"Documento desbloqueado no ERP"

      Case cStatus == "E"
         cRet:= STR0231 //"Aguardando prestação de contas (não integrada)"

      Case cStatus == "F"
         cRet:= STR0232 //"Compensação parcial - documento bloqueado no ERP"

      Case cStatus == "G"
         cRet:= STR0234 //"Compensação total"

      Case cStatus == "H"
         cRet:= STR0238 //"Câmbio de importação"

   End Case


End Sequence
Return cRet
/*
Funcao    : EAIEstornaTit()
Objetivos : Estornar o título no ERP quando, na prestação de contas, a compensação não ocorrer
Parametros:
Autor     : WFS
Data/Hora : abr/2015
Obs.      :
*/
Static Function EAIEstornaTit()
Local aOrd:= SaveOrd({"SWD"})

Begin Sequence

   SWD->(DBSetOrder(1)) //WD_FILIAL+WD_HAWB+WD_DESPESA+DTOS(WD_DES_ADI)
   SWD->(DBSeek(xFilial() + M->WD_HAWB + M->WD_DESPESA + DTOS(M->WD_DES_ADI)))

   If EICFI411("SWD", ESTORNO)

      /* Atualizar TRB
         O Valor Compensado foi atualizado pelo estorno da compensação. */
      TRB->WD_CTRFIN1 := ""
      TRB->WD_VLLIQ   := 0

      /* Atualizar SWD
         Como não se trata da exclusão da despesa, o registro permanece.
         O Valor Compensado foi atualizado pelo estorno da compensação. */
      SWD->(RecLock("SWD", .F.))
      SWD->WD_CTRFIN1 := ""
      SWD->WD_VLLIQ   := 0
      SWD->(MsUnlock())
   EndIf

End Sequence

RestOrd(aOrd)
Return

/*
Funcao    : DI501D_Vis()
Objetivos : Visualização das despesas
Parametros:
Autor     : WFS
Data/Hora : abr/2015
Obs.      :
Revisão   : mar/2017 - Alteração do objeto para FwBrowse
*/

Function DI501D_Vis()
Local oDlg, oMsMget
Local cTitulo:= STR0239 //"Visualizar"
Local bOk:= {|| oDlg:End()}
Local bCancel:= bOk
Local nInc
Local aBkpHeader:= {}
Private aTela:= {}, aGets:= {}


Begin Sequence

   SWD->(DBGoTo(TRB->RECNO))
   RegToMemory("SWD", .F.)

   If AvFlags("EIC_EAI")
      /* Backup do array aHeader.*/
      aBkpHeader:= AClone(aHeader)

      If Select("ADIANT") > 0
         AVZAP("ADIANT") //ADIANT->(avzap())
         Processa({|| CA150PQPRES("VIS")}, STR0071) //"Pesquisando adiantamentos..."
      Else
         Break
      EndIf
   EndIf


   Define MsDialog oDlg Title cTitulo From DLG_LIN_INI, DLG_COL_INI To DLG_LIN_FIM, DLG_COL_FIM Of oMainWnd Pixel

      oDlg:lMaximized:=.T.

      oMsMget:= MsMget():New("SWD",, 2,,,,aEnchoice, {0, 0, 150, 0},{},,,,, oDlg)

      If AvFlags("EIC_EAI")

            Define FwBrowse oMarkAdnt Data Table Alias "ADIANT" Of oDlg

               For nInc := 1 To Len(aHeader)
                  Add Column oColumn Data &("{ ||" + aHeader[nInc][2] + " }") Title aHeader[nInc][1] Size aHeader[nInc][4] Picture aHeader[nInc][3] Of oMarkAdnt
               Next

               oMarkAdnt:DisableReport()
               oMarkAdnt:DisableSeek()
               oMarkAdnt:Refresh(.T.)

            Activate FwBrowse oMarkAdnt

         oMsMget:oBox:Align:= CONTROL_ALIGN_TOP
         oMarkAdnt:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT

      Else
         oMsMget:oBox:Align:= CONTROL_ALIGN_ALLCLIENT
      EndIf

   Activate MsDialog oDlg On Init (EnchoiceBar(oDlg, bOk, bCancel))

   If AvFlags("EIC_EAI")
      AVZAP("ADIANT") //ADIANT->(avzap())
      /* Restaura backup do array aHeader.*/
      aHeader:= AClone(aBkpHeader)
   EndIf

End Sequence
Return


FUNCTION DI501WHEN(cCpo)

LOCAL uDado
LOCAL lRet := .F.
Local aOrd := {}

IF cCpo == NIL
   uDado:=&(READVAR())
   cCpo:=Subs(READVAR(),4)
ELSE
   uDado:=M->(&cCpo)
ENDIF

DO CASE

   CASE cCpo == "W6_TITINAN"
      If AVFLAGS("INV_ANT_GERA_CAMB_FIN") //.And. EasyGParam("MV_EASYFIN",,"N") == "S"
         aOrd := SaveOrd("SW9")
         SW9->(DbSEtOrder(3))
         If Empty(M->W6_HAWB) .Or. !SW9->(DbSeek(xfilial("SW9") + M->W6_HAWB))
            lRet := .T.
         EndIf
         RestOrd(aOrd,.T.)
      EndIf

    Case cCpo == "WD_BANCO"
        If AvFlags("EIC_EAI") .And. EasyFindAdpt("EICFI414") .And. M->WD_DESPESA == "903" .OR. AvFlags("AVINTEG") //LRS - 20/07/2018
            lRet := .T.
        EndIf

    Case cCpo == "WD_AGENCIA"
        If AvFlags("EIC_EAI") .And. EasyFindAdpt("EICFI414") .And. M->WD_DESPESA == "903" .OR. AvFlags("AVINTEG") //LRS - 20/07/2018
            lRet := .T.
        EndIf

    Case cCpo == "WD_CONTA"
        If AvFlags("EIC_EAI") .And. EasyFindAdpt("EICFI414") .And. M->WD_DESPESA == "903" .OR. AvFlags("AVINTEG") //LRS - 20/07/2018
            lRet := .T.
        EndIf

ENDCASE

Return lRet

/*
Funcao    : GeraVersaoDI()
Objetivos : Gerar versão sequencial para o campo W6_VERSAO
Parametros: lInteg - Via Integração TXT, cNumDI - Número da DI via Integração
Autor     : Marcos Roberto Ramos Cavini Filho - MCF
Data/Hora : ABR/2016
Obs.      :
*/

Function GeraVersaoDI(lInteg,cNumDI)
Local aOrd := SaveOrd("SW6")
Local cDI := "", cRet := ""
Default lInteg := .F.

cDI := If(lInteg,cNumDI,M->W6_DI_NUM)

SW6->(DBSETORDER(11))

If SW6->(AvSeekLast(xFilial('SW6')+AllTrim(cDI)))
   If lInteg .Or. M->W6_HAWB # SW6->W6_HAWB
      cRet := SomaIt(SW6->W6_VERSAO)
   Else
      cRet := SW6->W6_VERSAO
   EndIf
Else
   cRet := "00"
EndIf

RestOrd(aOrd, .T.)
Return cRet

/*
Funcao    : DI500LegNVE()
Autor     : Guilherme Fernandes Pilan - GFP
Data      : 11/11/2016
Retorna   : Legendas de NVE
*/
*------------------------------*
Function DI500LegNVE()
*------------------------------*
Local aColors := {{"BR_VERMELHO" , STR0246},;  //"Itens sem vinculação"
                  {"BR_AZUL"     , STR0247},;  //"Itens já vinculados à tabela atual"
                  {"BR_VERDE"    , STR0248}}   //"Itens já vinculados em outra tabela"
Return BrwLegenda(STR0166, STR0245, aColors)   // "Manutenção de NVEs" ## "Legendas"

/*

Funcao    : DI501Gatilho()
Objetivos : Gatilhar observações da DI retificada
            Tratamento migrado dos gatilhos do número da DI - W6_DI_NUM
            003 - If(M->W6_VERSAO <> '00','Retificação da DI número ' + M->W6_DI_NUM,'')
            004 - ""
Parametros: cParam - indica chaveamento da ação
Autor     : wfs
Data/Hora : fev/2017
Obs.      :
*/
Function DI501Gatilho(cParam, cContraDom)
Local cRet:= ""
Local i, nLen:= 0

Default cContraDom := ""

   Begin Sequence

      Do Case
         Case cParam == "W6_VMDIOBS_PREENCHER"

            cRet:= M->W6_VMDIOBS
            /* OSSME-6300 / MTRADE-2537 - Permitir retificação mesmo com o MV_TEM_DI Habilitado
            If EasyGParam("MV_TEM_DI",, .F.)
               Break
            EndIf
            */
            If !Empty(M->W6_VERSAO) .And. M->W6_VERSAO <> "00"
               cRet:= STR0257 + M->W6_DI_NUM + ENTER //"Retificação da DI número "
               For i:= 1 To MlCount(M->W6_VMDIOBS)
                  cRet += AllTrim(Memoline(M->W6_VMDIOBS,, i)) + ENTER
               Next
            EndIf

         Case cParam == "W6_VMDIOBS_LIMPAR"

            cRet:= M->W6_VMDIOBS

            /* OSSME-6300 / MTRADE-2537 - Permitir retificação mesmo com o MV_TEM_DI Habilitado
            If EasyGParam("MV_TEM_DI",, .F.)
               Break
            EndIf
            */

            If Empty(M->W6_VERSAO)
               nLen:= Len(STR0257 + M->W6_DI_NUM + ENTER) //"Retificação da DI número "
               For i:= 1 To MlCount(M->W6_VMDIOBS, nLen)
                  If i == 1
                     cRet:= Memoline(M->W6_VMDIOBS, nLen, i)
                     If At(STR0257, cRet) > 0 //"Retificação da DI número "
                        cRet:= ""
                     Else
                        cRet:= M->W6_VMDIOBS
                        Break
                     EndIf
                  Else
                     cRet += AllTrim(Memoline(M->W6_VMDIOBS, nLen, i))
                  EndIf
               Next
            EndIf

         Case cParam == "W6_FORMREG" 
            If cContraDom == "W6_DTMANU"
               cRet := STOD("")   
            ElseIf cContraDom == "W6_DTREG_D"
               cRet := STOD("")
            Else
               cRet := ""   
            EndIf
            
         Case cParam == "W6_TIPOREG" 
            If cContraDom == "W6_DTMANU"
               cRet := STOD("")   
            ElseIf cContraDom == "W6_DTREG_D"
               cRet := STOD("")
            Else
               cRet := ""   
            EndIf
         
         Case cParam == "W6_CURRIER"
            If Valtype( SW6->&(cContraDom) ) == "C"
               cRet := ""
            ElseIf Valtype( SW6->&(cContraDom) ) == "D"
               cRet := STOD("") 
            EndIf 

      EndCase

   End Sequence

Return cRet

/*
Funcao    : DI500Alcada()
Autor     : Lucas Raminelli	            
Data      : 07/03/2017
Retorna   : Verifica PO com Alçada
*/
*------------------------------*
Function DI500Alcada(cProAlcada)
*------------------------------*
Local lW2ConaPro
Local aOrd := SaveOrd({"SX3","SW2"})
Local lRet := .T.

SX3->(DBSETORDER(2))
lW2ConaPro := SX3->(DbSeek("W2_CONAPRO")) .AND. EasyGParam("MV_AVG0170",,.F.) 

SW2->(DBSETORDER(1))
IF SW2->(DBSEEK(xFilial("SW2")+cProAlcada))
	IF lW2ConaPro .And. !Empty(SW2->W2_CONAPRO) .And. SW2->W2_CONAPRO <> "L"
	   MsgStop(STR0258,STR0001) //"Pedido nao liberado pela Alcada",Atencao	
	   lRet := .F.
	ENDIF
EndIF

RestOrd(aOrd, .T.)

Return lRet


/*
Funcao    : DI501DevDe()
Autor     : Tiago Henrique Tudisco dos Santos - THTS
Data      : 10/08/2017
Descricao : Funcao utilizada para a Devolucao ao Despachante
*/
Static Function DI501DevDe()
Local aCpoSis := {"WD_MOEDA","WD_VL_MOE","WD_TX_MOE","WD_PRDSIS"}
Local lCpoSis := .T.
Local nVl903  := 0
Local nI
Local nPosSis

If TRB->WD_DESPESA != "901"
    MsgInfo(STR0263,STR0001)//"Selecione um adiantamento ao despachante (901) com saldo para efetuar a devolução ao despachante"###"Atenção"
    Return
EndIf

nVl903 := DI501DVDES(TRB->WD_HAWB,TRB->WD_CTRFIN1) //Verifica se ja gerou 903 e o valor de todas as 903 geradas

If TRB->WD_VALOR_R - TRB->WD_VL_COMP - nVl903 <= 0
    MsgInfo(STR0264,STR0001)//"Não há saldo neste adiantamento para devolução ao despachante"###"Atenção"
    Return
EndIf

IF MSGYESNO(STR0266 + ENTER +; //"Esta operação devolverá o saldo do adiantamento ao despachante e não poderá mais ser utilizado."
            STR0267 + ENTER + ; //"ESTA OPERAÇÃO É IRREVERSÍVEL!"
            STR0268, STR0001) //"Deseja prosseguir?" //"Atenção - Desbloqueio de título"

    For nI:= 1 To Len(aCpoSis)
        nPosSis := AScan(aEnchoice, aCpoSis[nI])
        If nPosSis = 0
            lCpoSis := .F.
        EndIf
    Next

    aAdd(aEnchoice,"WD_BANCO")
    aAdd(aEnchoice,"WD_AGENCIA")
    aAdd(aEnchoice,"WD_CONTA")

    lDevDesp := .T.
    DI500DespManut(2) //Chama inclusao de despesa ## Despesa 903 (nao podera alterar)
    lDevDesp := .F.

    If lCpoSis
        aAdd(aEnchoice,"WD_MOEDA")
        aAdd(aEnchoice,"WD_VL_MOE")
        aAdd(aEnchoice,"WD_TX_MOE")
        aAdd(aEnchoice,"WD_PRDSIS")
    EndIf

EndIf

Return

/*
Funcao    : DI501DVDES()
Autor     : Tiago Henrique Tudisco dos Santos - THTS
Data      : 15/08/2017
Descricao : Funcao utilizada para verificar se existe a despesa 903 - Devolucao ao Despachante
*/
Function DI501DVDES(cHAWB,cTitDecDes)
Local nRet      := 0
Local cQuery    := ""
Local aArea     := getArea()

If AvFlags("EIC_EAI") .And. EasyFindAdpt("EICFI414")
    cQuery := "SELECT SUM(WD_VALOR_R) WD_VALOR_R "
    cQuery += "FROM " + RetSqlName("SWD") + " "
    cQuery += "WHERE WD_FILIAL  = '" + xFilial("SWD") + "' "
    cQuery += "  AND WD_HAWB    = '" + cHAWB + "' "
    cQuery += "  AND WD_DESPESA = '903' "
    cQuery += "  AND WD_CTRFIN1 = '" + cTitDecDes + "' "
    cQuery += "  AND D_E_L_E_T_ =' ' "

    cQuery := ChangeQuery(cQuery)
    DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "TMPDVDES", .T., .T.)
    TcSetField("TMPDVDES","WD_VALOR_R","N", AVSX3("WD_VALOR_R",3), AVSX3("WD_VALOR_R",4))
    If TMPDVDES->(!EOF())
        nRet := TMPDVDES->WD_VALOR_R //Retorna o valor somado de todas as devolucoes (903) geradas para o mesmo titulo 901
    EndIf

    TMPDVDES->(DBCloseArea())
EndIf
restArea(aArea)

Return nRet


/*
Funcao    : DI501LGDESP()
Autor     : Tiago Henrique Tudisco dos Santos - THTS
Data      : 17/08/2017
Descricao : Funcao utilizada para verificar Status de qual legenda será exibida para a despesa
*/
Static Function DI501LGDESP()
Local lRet  := .F.
Local nVl903:= 0

If AvFlags("EIC_EAI") .And. EasyFindAdpt("EICFI414")

    If TRB->WD_DESPESA == "903" //Se for despesa 903 - Devolucao ao Despachante
    
        lRet := .T.
    
    ElseIf TRB->WD_DESPESA == "901"
        nVl903 := DI501DVDES(TRB->WD_HAWB,TRB->WD_CTRFIN1)
        If SWD->WD_VALOR_R - SWD->WD_VL_COMP - nVl903 <= 0
            lRet := .T.
        EndIf

    EndIf

EndIf

Return lRet

/*
Funcao    : DI501VerNVE()
Autor     : Guilherme Fernandes Pilan - GFP 	            
Data      : 06/12/2016
Retorna   : Exibe tela com relação de todas as NVEs por NCMs.
*/
*------------------------------*
Function DI501VerNVE(nOpc)
*------------------------------*
Local oDlg
Local i := 0, nOp := 0
Local aProd := {}, aButtons := {}, aSemSX3 := {}, aCamposWK := {}
Private aCampos[0], aHeader[0]

If Select("Work_NVE") # 0
   Work_NVE->(DbCloseArea())
EndIf

aAdd(aSemSX3,{"WK_TEC"  , "C", AVSX3("B1_POSIPI",3) ,0})
aAdd(aSemSX3,{"WK_NVE"  , "C", AVSX3("EIM_CODIGO",3),0})
aAdd(aSemSX3,{"WK_COD_I", "C", AVSX3("W5_COD_I",3)  ,0})

cFileWkEIM  := E_CriaTrab(,aSemSX3,"Work_NVE")
cFileWK_01 := E_Create(,.F.)
IndRegua("Work_NVE" ,cFileWK_01+TEOrdBagExt() ,"WK_TEC+WK_NVE+WK_COD_I") 
cFileWK_02 := E_Create(,.F.)
IndRegua("Work_NVE" ,cFileWK_02+TEOrdBagExt() ,"WK_NVE")  
SET INDEX TO (cFileWK_01+TEOrdBagExt()),(cFileWK_02+TEOrdBagExt())

If nOpc == 3 .OR. nOpc == 4
   Work_SW8->(DbGoTop())
   Do While Work_SW8->(!Eof())
      If (nOpc == 4 .OR. !EMPTY(Work_SW8->WKFLAGIV)) .AND. !Empty(Work_SW8->WKNVE) .AND. aScan(aProd,{|X| X[3] == Work_SW8->WKNVE .And. X[2] == Work_SW8->WKTEC}) == 0
         aadd(aProd,{Work_SW8->WKCOD_I,Work_SW8->WKTEC,Work_SW8->WKNVE})
      EndIf
      Work_SW8->(DbSkip())
   EndDo
Else
   TRB->(DbGoTop())
   Do While TRB->(!Eof())
      If !Empty(TRB->W5_NVE) .AND. aScan(aProd,StrTran(SubStr(TRB->W5_NBMTEC,1,At("/",TRB->W5_NBMTEC)-1),".","")) == 0
         aadd(aProd,{TRB->W5_COD_I,StrTran(SubStr(TRB->W5_NBMTEC,1,At("/",TRB->W5_NBMTEC)-1),".",""),TRB->W5_NVE})
      EndIf
      TRB->(DbSkip())
   EndDo
Endif

AADD(aCamposWK,{"WK_NVE"   ,"",AVSX3("W5_NVE"   ,5)})
AADD(aCamposWK,{"WK_TEC"   ,"",AVSX3("B1_POSIPI"  ,5)})

Work_NVE->(DbGoTop())
If nOpc # 2 .AND. Len(aProd) == 0
   Work_NVE->(avzap())
EndIf

If Len(aProd) # 0
   For i := 1 To Len(aProd)
      Work_NVE->(DbAppend())
      Work_NVE->WK_COD_I := aProd[i][1]
      Work_NVE->WK_TEC   := aProd[i][2]
      Work_NVE->WK_NVE   := aProd[i][3]
   Next i
EndIf

Work_NVE->(DbSetOrder(2))
Work_NVE->(DbGoTop())

If nOpc == 2
   AADD(aButtons,{"NEXT"    ,{|| nOp := 2, oDlg:End() },"Visualizar" ,"Visualizar"})  //"Visualizar"
Else
   AADD(aButtons,{"NEXT"    ,{|| nOp := 3, oDlg:End() },STR0031 ,STR0031})  //"Incluir"
   If Work_NVE->(EasyRecCount("Work_NVE")) # 0
      AADD(aButtons,{"NEXT"    ,{|| nOp := 4, oDlg:End() },STR0032 ,STR0032})  //"Alterar"
      AADD(aButtons,{"NEXT"    ,{|| nOp := 5, oDlg:End() },STR0033 ,STR0033})  //"Excluir"
   EndIf
EndIf

DEFINE MSDIALOG oDlg TITLE "Relação de NVEs do processo: " + AllTrim(SW6->W6_HAWB) From DLG_LIN_INI,DLG_COL_INI To DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
   //oGetDb := MsGetDB():New(1,1,100,100,2,,,"",.T.,,,.F.,,"Work_NVE",,.F.,,oDlg,.T.)
   //oGetDb:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   oSelect := MSSELECT():New("Work_NVE",,,aCamposWK,,,{1,1,1,1},,,oDlg)
   oSelect:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   oSelect:oBrowse:bWhen:={|| .T.}   
   oSelect:oBrowse:Refresh()

   oDlg:lMaximized:=.T.
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOp := 0, oDlg:End()},{||nOp := 0, oDlg:End()},,aButtons) CENTERED

If nOp == 0
   Return {0,0,0}
Else
   nRecnoWkNVE := Work_NVE->(Recno())
   Work_NVE->(DbSetOrder(1))
   Work_NVE->(DbGoTo(nRecnoWkNVE))
   Return {Work_NVE->WK_NVE,Work_NVE->WK_TEC,nOp}
EndIf

Return NIL

/*
Funcao    : DI501WkEIM()
Autor     : Guilherme Fernandes Pilan - GFP 	            
Data      : 07/12/2016
Retorna   : Gravação da Work_EIM.
*/
*-----------------------------------*
Function DI501WkEIM(cHawb, cNVE, nOpc)
*-----------------------------------*
Local cFase := If(nOpc == 3,"LI","DI")
AvZap("Work_EIM")
EIM->(DbSetOrder(3))
//MFR 23/11/2018
//IF EIM->(DbSeek(xFilial("EIM")+AvKey(cFase,"EIM_FASE")+AvKey(cHawb,"EIM_HAWB")+AvKey(cNVE,"EIM_CODIGO")))
IF EIM->(DbSeek(GetFilEIM(cFase)+AvKey(cFase,"EIM_FASE")+AvKey(cHawb,"EIM_HAWB")+AvKey(cNVE,"EIM_CODIGO")))
//MFR 23/11/2018
//   DO While !EIM->(Eof()) .AND. EIM->EIM_FILIAL == xFilial("EIM") .AND. EIM->EIM_FASE == AvKey(cFase,"EIM_FASE") .AND. EIM->EIM_HAWB == AvKey(cHawb,"EIM_HAWB") .AND. EIM->EIM_CODIGO == AvKey(cNVE,"EIM_CODIGO")
     DO While !EIM->(Eof()) .AND. EIM->EIM_FILIAL == GetFilEIM(cFase) .AND. EIM->EIM_FASE == AvKey(cFase,"EIM_FASE") .AND. EIM->EIM_HAWB == AvKey(cHawb,"EIM_HAWB") .AND. EIM->EIM_CODIGO == AvKey(cNVE,"EIM_CODIGO")
      Work_EIM->(DBAPPEND())
      AVREPLACE("EIM","Work_EIM")
      EIM->(dbSkip())
   ENDDO   
ENDIF
EIM->(DBSETORDER(1))

Work->(DBGOTOP())
DO WHILE Work->(!EOF())
   IF !Work->WKFLAG
      Work->(DBSKIP())
      LOOP
   ENDIF
   IF !EMPTY(Work->WK_NVE) .AND. !Work_CEIM->(DBSEEK(Work->WK_NVE))
       Work_CEIM->(DBAPPEND())
       AvReplace("Work_EIM","Work_CEIM")
       Work_CEIM->EIM_CODIGO:=Work->WK_NVE
       Work_CEIM->WKTEC     :=Work->WKTEC
   ENDIF
   If nOpc # 3
      Work_SW8->(DbSetOrder(2))
      If Work_SW8->(DBSEEK(WORK->WKFORN+EICRetLoja("Work", "W7_FORLOJ")+WORK->WKPO_NUM+WORK->WKPOSICAO+WORK->WKPGI_NUM)) .AND. Empty(Work_SW8->WKNVE)
         Work_SW8->WKNVE := Work->WK_NVE
      EndIf
   EndIf
   Work->(DbSkip())
EndDo

Return NIL

/*
Função    : ValPresCont()
Objetivo  : Verificar se a prestação de conta será executada
Retorno   : Logico
Parametro : Nenhum
Autor     : Lucas Raminelli - LRS
Data      : 10/10/2018
*/
Function ValPresCont(cTipo)

Local aOrd
Local lRet := .F.
Local aDimNasc := {}
Local cChaveSWD := "", i 

If Select("TRB") > 0
    aOrd := SaveOrd({"TRB","SWD"})
Else
    aOrd := SaveOrd("SWD")
EndIf 

IF cTipo == "DA"
    aDimNasc := FI400GetDIsNa(SW6->W6_HAWB)
ElseIF cTipo =="DIN"
    aDimNasc := FI400GetDAS(SW6->W6_HAWB)
EndIF

SWD->(dbSetOrder(1)) 
For i := 1 To Len(aDimNasc)
    cChaveSWD := xFilial("SWD")+aDimNasc[i]+SWD->WD_DESPESA
    SWD->(dbSeek(cChaveSWD))
    Do While SWD->(!Eof() .AND. WD_FILIAL+WD_HAWB+WD_DESPESA == cChaveSWD)
        IF !Empty(SWD->WD_CTRFIN1)
        lRet := .T.
           IF cTipo == "DIN"
              cTitDin := SWD->WD_CTRFIN1
           EndIF
        EndIF
        SWD->(dbSkip())
    EndDo
Next i

RestOrd(aOrd,.T.)
Return lRet


Static Function GetModAtoC(cAtoConc,lPosiciona)
Local cTipo        := ""
Local aOrd         := SaveOrd("ED0")
Default cAtoConc   := ""
Default lPosiciona := .F.
ED0->(DbSetOrder(2))
If ED0->(DbSeek( xFilial("ED0") + AvKey(cAtoConc, "ED0_AC")  ))
   cTipo := ED0->ED0_MODAL
EndIf

If !lPosiciona
   RestOrd(aOrd,.T.)
EndIf

Return cTipo

/*
Função    : DI501ATUDI()
Objetivo  : Será possível chamar a funcao DI501ATUDI de qualquer fonte e assim chamar a função estatica
            AtuVlDI
Retorno   : Função
Parametro : Nenhum
Autor     : Ramon Prado
Data      : Jun/2020
*/
Function DI501ATUDI(cW6Hawb,aCols,lMem,lWork)
Private lSair := .F.

Default aCols := {}
Default lMem      := .F. //por padrao vai gravar para continuar funcionando as outras chamadas desta rotina
Default lWork  := .F. //por padrao vai gravar para continuar funcionando as outras chamadas desta rotina

IF(EasyEntryPoint("EICDI501"),ExecBlock("EICDI501",.F.,.F.,"501VALDI"),)
IF lSair
   Return
ENDIF

Return AtuVlDI(cW6Hawb,aCols,lmem, lWork)

/*
Funcao     : AjSldLotes
Objetivo   : Ajustar os saldos das linhas de SWV sem lote\lpco relacionadas à quantidade do item na invoice alterado (para MENOR ou MAIOR) 
             na manutenção atual.
Parametros : Nenhum.
Retorno    : Lógico
Autor      : Nilson César
Data       : Setembro/2021
*/
Static Function AjSldLotes(cTpOP)
Local aOrdTab    := SaveOrd({"SW8","Work_SW8"})
Local cQryW8Alt  := ''
Local cOP        := '' 
Local aProc      := {}

If cTpOP == "ALT"
   cQryW8Alt := ChangeQuery(GetQryLnWV("0"))
   EasyQry(cQryW8Alt, "WKSW8ALTQT")                           //Identifica se a quantidade foi alterada.
   WKSW8ALTQT->(DbGoTop())
   Do While WKSW8ALTQT->(!Eof())
      Work_SW8->(DbGoTo(WKSW8ALTQT->WK_RECNO))                //Posiciona no registro
      If lVinLtLpco()                                         //Identifica se possui vinculação de Lotes\LPCOs
         cOp := If( WKSW8ALTQT->DIFERENCA > 0 , 'SUB','SUM' ) //Determina o tipo de operação
         AtuSldSWV( GetQryLnWV('2',cOP) , cOP )
      EndIf
      WKSW8ALTQT->(DbSkip())
   EndDo
   WKSW8ALTQT->(DbCloseArea())

ElseIf cTpOP == "DEL"

   cQryWVDel := ChangeQuery(GetQryLnWV("4"))
   EasyQry(cQryWVDel, "REGSWVDEL")                           //Identifica: Item desmarcado do embarque itens desmarcado da invoice (exclusão de item individual, exclusão de invoice - grupo de itens)
   REGSWVDEL->(DbGoTop())                                    //            Grupo de itens de uma invoice a serem excluídos (exclusão da invoice)
   Do While REGSWVDEL->(!Eof())                              //            Grupo de itens de várias invoices a serem excluídos (exclusão do processo)
      DI501DLnLt(REGSWVDEL->WV_RECNO)
      REGSWVDEL->(DbSkip())
   EndDo
   REGSWVDEL->(DbCloseArea())

EndIf

RestOrd(aOrdTab,.T.)

Return .T.

/*
Funcao     : lVinLtLPCO
Objetivo   : Verifica se o item de invoice possui lotes vinculado já gravados
Parametros : Nenhum.
Retorno    : Lógico
Autor      : Nilson César
Data       : Setembro/2021
*/
Static Function lVinLtLPCO()
Local lRet := .F.
Local cQry := GetQryLnWV('1')

   cQry:= ChangeQuery(cQry)
   EasyQry(cQry, "RSTSWV")
   lRet := RSTSWV->REGSWV > 0
   RSTSWV->(DbCloseArea())

Return lRet


/*
Funcao     : GetQryLnWV
Objetivo   : Montar e retornar a string de query baseado no item da Work_SW8 posicionado.
Parametros : cTipQry: Tipo da String a ser retornada
             cTipoOP: 'SUB' para buscar linhas da SWV onde pode ser abatido o saldo A MENOR do item na invoice.
                      'SUM' para buscar linhas da SWV onde pode ser abatido o saldo A MAIOR do item na invoice.
             cTabRel: Alias da tabela relacionada com o SWV pelo campo WV_ID ( EIJ, EIK, EIN ou EJ9 )
Retorno    : Caractér
Autor      : Nilson César
Data       : Setembro/2021
*/
Static Function GetQryLnWV(cTipoQry,cTipoOP,cTabRel)

Local cQuery := ''
Default cTipoOP := 'SUM'

If cTipoQry == '0' //Retorna query que identifica os registros da tabela temporária da SW8 que tiveram a quantidade alterada.

   cQuery += " SELECT DISTINCT WKSW8.WKINVOICE, WKSW8.WKPO_NUM, WKSW8.WKPOSICAO, WKSW8.WKREG, WKSW8.WKCOD_I, WKSW8.WKCC, WKSW8.WKPGI_NUM, WKSW8.WKSI_NUM, WKSW8.WKFORN,WKSW8.W8_FORLOJ,WKSW8.WKQTDE,WKSW8.R_E_C_N_O_ WK_RECNO,(SW8.W8_QTDE - WKSW8.WKQTDE) DIFERENCA"
   cQuery += " FROM "+TETempName("Work_SW8")+" WKSW8"
   cQuery += " INNER JOIN "+RetSQLName("SW8")+" SW8"
   cQuery += "		 ON  SW8.W8_FILIAL    = '"+xFilial("SW8")+"'" 
   cQuery += "		 AND SW8.W8_HAWB      = '"+M->W6_HAWB+"'"
   cQuery += "		 AND SW8.W8_INVOICE = WKSW8.WKINVOICE" 
   cQuery += "		 AND SW8.W8_PO_NUM  = WKSW8.WKPO_NUM" 
   cQuery += "		 AND SW8.W8_POSICAO = WKSW8.WKPOSICAO" 
   cQuery += "		 AND SW8.W8_PGI_NUM = WKSW8.WKPGI_NUM" 
   cQuery += "		 AND SW8.W8_FORN    = WKSW8.WKFORN" 
   cQuery += "		 AND SW8.W8_FORLOJ  = WKSW8.W8_FORLOJ" 
   cQuery += " WHERE WKSW8.D_E_L_E_T_ = ' '"
   cQuery += " AND WKSW8.WKFLAGIV <> ' '"
   cQuery += " AND SW8.D_E_L_E_T_ = ' '" 
   cQuery += " AND SW8.W8_QTDE <> WKSW8.WKQTDE"

ElseIf cTipoQry == '1' // Retorna query que conta quantidade de registros de lotes associados ao item da invoice posicionado no 
                       // arquivo de trabalho
   cQuery += " SELECT COUNT(SWV.WV_QTDE) REGSWV"
   cQuery += " FROM "+RetSQLName("SWV")+" SWV"
   cQuery += " WHERE SWV.WV_FILIAL   = '"+xFilial("SWV")+"'"             
   cQuery += " AND SWV.WV_HAWB     = '"+M->W6_HAWB+"'"
   cQuery += " AND SWV.WV_INVOICE  = '"+Work_SW8->WKINVOICE+"'"
   cQuery += " AND SWV.WV_PO_NUM   = '"+Work_SW8->WKPO_NUM +"'"
   cQuery += " AND SWV.WV_POSICAO  = '"+Work_SW8->WKPOSICAO+"'"
   cQuery += " AND SWV.WV_PGI_NUM  = '"+Work_SW8->WKPGI_NUM+"'"
   cQuery += " AND SWV.WV_FORN     = '"+Work_SW8->WKFORN +"'"
   cQuery += " AND SWV.WV_FORLOJ   = '"+Work_SW8->W8_FORLOJ+"'"

ElseIf cTipoQry == '2' // Retorna as linhas de lotes associadas ao item da invoice posicionado no arquivo de trabalho que não possuem
                       // lote associado ou lpco nas necessidades de anuência da n.c.m (tabela EKQ)

   cQuery += " SELECT DISTINCT"
   cQuery += "    SW8.W8_INVOICE,SW8.W8_PO_NUM,SW8.W8_POSICAO,SW8.W8_PGI_NUM,SW8.W8_FORN,SW8.W8_FORLOJ,SW8.W8_QTDE,(SW8.W8_QTDE - "+Str(Work_SW8->WKQTDE,AvsX3("W8_QTDE",AV_TAMANHO),AvSx3("W8_QTDE",AV_DECIMAL))+") DIFERENCA,"
   cQuery += " 	SWV.WV_FILIAL,SWV.WV_HAWB,SWV.WV_INVOICE,SWV.WV_PO_NUM,SWV.WV_POSICAO,SWV.WV_PGI_NUM,SWV.WV_FORN,SWV.WV_FORLOJ,SWV.WV_SEQUENC,SWV.WV_QTDE,SWV.R_E_C_N_O_ WV_RECNO" 
   cQuery += " FROM "+RetSQLName("SW8")+" SW8"
   cQuery += " INNER JOIN "+RetSQLName("SWV")+" SWV"
   cQuery += "    ON  SWV.D_E_L_E_T_  = ' '"
   cQuery += "    AND SWV.WV_FILIAL   = '"+xFilial("SWV")+"'"             
   cQuery += " 	AND SWV.WV_HAWB     = SW8.W8_HAWB"
   cQuery += "    AND SWV.WV_INVOICE  = SW8.W8_INVOICE"
   cQuery += "    AND SWV.WV_PO_NUM   = SW8.W8_PO_NUM"
   cQuery += "    AND SWV.WV_POSICAO  = SW8.W8_POSICAO"
   cQuery += "    AND SWV.WV_PGI_NUM  = SW8.W8_PGI_NUM"
   cQuery += "    AND SWV.WV_FORN     = SW8.W8_FORN"
   cQuery += "    AND SWV.WV_FORLOJ   = SW8.W8_FORLOJ"
   cQuery += "    AND SWV.WV_LOTE     = ' '"
   cQuery += " WHERE SW8.D_E_L_E_T_  = ' '"                             //Verificar se funciona na alt. para menor
   cQuery += " AND SW8.W8_FILIAL  = '"+xFilial("SW8")+"'"  
	cQuery += " AND SW8.W8_HAWB      = '"+M->W6_HAWB+"'"
	cQuery += " AND SW8.W8_INVOICE   = '"+Work_SW8->WKINVOICE+"'" 
	cQuery += " AND SW8.W8_PO_NUM    = '"+Work_SW8->WKPO_NUM +"'"
	cQuery += " AND SW8.W8_POSICAO   = '"+Work_SW8->WKPOSICAO+"'"
	cQuery += " AND SW8.W8_PGI_NUM   = '"+Work_SW8->WKPGI_NUM+"'"
	cQuery += " AND SW8.W8_FORN      = '"+Work_SW8->WKFORN +"'"
	cQuery += " AND SW8.W8_FORLOJ    = '"+Work_SW8->W8_FORLOJ+"'" 
   cQuery += " AND SW8.W8_QTDE      "+If(cTipoOP == 'SUB',"> ","< ")+Str(Work_SW8->WKQTDE,AvsX3("W8_QTDE",AV_TAMANHO),AvSx3("W8_QTDE",AV_DECIMAL))  
   cQuery += " AND ( SELECT COUNT(*) 
   cQuery += "       FROM "+RetSQLName("EKQ")+" EKQ2"
   cQuery += "       WHERE EKQ2.EKQ_FILIAL = '"+xFilial("EKQ")+"'"
   cQuery += "       AND EKQ2.EKQ_HAWB   = SWV.WV_HAWB"
   cQuery += "       AND EKQ2.EKQ_INVOIC = SWV.WV_INVOICE" 
   cQuery += "       AND EKQ2.EKQ_PO_NUM = SWV.WV_PO_NUM" 
   cQuery += "       AND EKQ2.EKQ_POSICA = SWV.WV_POSICAO"
   cQuery += "       AND EKQ2.EKQ_SEQUEN = SWV.WV_SEQUENC"
   cQuery += "       AND EKQ2.EKQ_LPCO  <> '' ) = 0"
   cQuery += " ORDER BY SWV.WV_SEQUENC DESC"

ElseIf cTipoQry == '3' // Retorna as linhas de necessidades de anuência da n.c.m (tabela EKQ) referente à linha de lote posicionado.

   cQuery += " SELECT EKQ.R_E_C_N_O_"
   cQuery += " FROM "+RetSQLName("EKQ")+" EKQ"
   cQuery += " WHERE EKQ.D_E_L_E_T_ = ' '"
   cQuery += " AND EKQ.EKQ_FILIAL = '"+xFilial("EKQ")+"'"
   cQuery += " AND EKQ.EKQ_HAWB   = '"+SWV->WV_HAWB+"'"
   cQuery += " AND EKQ.EKQ_INVOIC = '"+SWV->WV_INVOICE+"'"
   cQuery += " AND EKQ.EKQ_PO_NUM = '"+SWV->WV_PO_NUM+"'" 
   cQuery += " AND EKQ.EKQ_POSICA = '"+SWV->WV_POSICAO+"'"
   cQuery += " AND EKQ.EKQ_SEQUEN = '"+SWV->WV_SEQUENC+"'"

ElseIf cTipoQry == '4' // Retorna as linhas de SWV que devem ser deletadas.

   cQuery := "SELECT"
   cQuery += " SWV.D_E_L_E_T_ WV_DELETED, SWV.R_E_C_N_O_ WV_RECNO, SWV.WV_FILIAL, SWV.WV_HAWB, SWV.WV_INVOICE, SWV.WV_PO_NUM, SWV.WV_POSICAO, SWV.WV_SEQUENC, SWV.WV_LOTE, SWV.WV_QTDE," 
   cQuery += " SW8.D_E_L_E_T_ W8_DELETED, SW8.R_E_C_N_O_ W8_RECNO, SW8.W8_FILIAL, SW8.W8_HAWB, SW8.W8_INVOICE, SW8.W8_PO_NUM, SW8.W8_POSICAO, SW8.W8_QTDE"
   cQuery += " FROM "+RetSQLName("SWV")+" SWV "
   cQuery += " LEFT JOIN "+RetSQLName("SW8")+" SW8
   cQuery += " ON  SW8.W8_FILIAL  = SWV.WV_FILIAL"
   cQuery += " AND SW8.W8_HAWB    = SWV.WV_HAWB"
   cQuery += " AND SW8.W8_INVOICE = SWV.WV_INVOICE"
   cQuery += " AND SW8.W8_PO_NUM  = SWV.WV_PO_NUM"
   cQuery += " AND SW8.W8_POSICAO = SWV.WV_POSICAO"
   cQuery += " AND SW8.W8_PGI_NUM = SWV.WV_PGI_NUM" 		
   cQuery += " AND SW8.W8_FORN    = SWV.WV_FORN"		
   cQuery += " AND SW8.W8_FORLOJ  = SWV.WV_FORLOJ"
   cQuery += " AND SW8.D_E_L_E_T_ = ' '" 
   cQuery += " WHERE SWV.WV_FILIAL  = '"+xFilial("SWV")+"'"
   cQuery += " AND SWV.WV_HAWB    = '"+M->W6_HAWB+"'" 
   cQuery += " AND SWV.D_E_L_E_T_ = ' ' AND SWV.WV_ID <> ' '"
   cQuery += " AND SW8.W8_HAWB IS NULL" 

ElseIf cTipoQry == '5' // Retorna as linhas da tabela indicada (relacionada com a SWV) para estorno.

   cQuery += " SELECT "+cTabRel+".R_E_C_N_O_"
   cQuery += " FROM "+RetSQLName(cTabRel)+" "+cTabRel
   cQuery += " WHERE "+cTabRel+".D_E_L_E_T_ = ' '"
   cQuery += " AND "+cTabRel+"."+cTabRel+"_FILIAL = '"+xFilial(cTabRel)+"'"
   cQuery += " AND "+cTabRel+"."+cTabRel+"_HAWB   = '"+SWV->WV_HAWB+"'"
   cQuery += " AND "+cTabRel+"."+cTabRel+"_IDWV   = '"+SWV->WV_ID+"'"

EndIf

Return cQuery


/*
Funcao     : AtuSldSWV
Objetivo   : Gravar as linhas de Lotes na SWV distribuindo a diferença de saldo encotnrada após alteração do item da invoice
Parametros : cQuery - Query para filtrar os registros alvo.
Retorno    : Nenhum
Autor      : Nilson César
Data       : Setembro/2021
*/
Static Function AtuSldSWV(cQuery,cOp)

Local lContinua := .T.

   cQuery:= ChangeQuery(cQuery)
   EasyQry(cQuery, "LINESSWV")
   LINESSWV->(DBGoTop())

   If cOp == "SUB"                                    // Saldo do item na invoice foi reduzido.
      nSaldoRest := LINESSWV->DIFERENCA
      Do While LINESSWV->(!Eof()) .And. lContinua
         SWV->(DbGoTo(LINESSWV->WV_RECNO))
         SWV->(RecLock("SWV",.F.))
         If SWV->WV_QTDE > nSaldoRest
            SWV->WV_QTDE -= nSaldoRest
            nSaldoRest   := 0
         else
            nSaldoRest   -= SWV->WV_QTDE
            SWV->WV_QTDE := 0
            DI501DLnLt()                              // Deleta linha de Lote (SWV) e obrigatoriedades de LPCO da n.c.m (EKQ)
         EndIf
         SWV->(MsUnlock())
         If nSaldoRestante <= 0
            lContinua := .F.
         EndIf
         LINESSWV->(DbSkip())
      EndDo
   Else                                               // Saldo do item na invoice foi aumentado.
      If LINESSWV->(!Bof()) .And. LINESSWV->(!Eof())  // Existe item para absorver o saldo
         SWV->(DbGoTo(LINESSWV->WV_RECNO))
         SWV->(RecLock("SWV",.F.))
         SWV->WV_QTDE += Abs(LINESSWV->DIFERENCA)
         SWV->(MsUnlock())
      Else
         DI501ILnLt()                                // Inclui linha de Lote (SWV) e obrigatoriedades de LPCO da n.c.m (EKQ)
      EndIf
   EndIf

   LINESSWV->(DbCloseArea())

Return

/*
Funcao     : DI501DLnLt
Objetivo   : Deletar registro da tabela SWV posicionado eos registros de EKQ associados.
Parametros : nRecno - Recno do registro da SWV. Se não informado, assume que já está posicionado.
Retorno    : Lógico
Autor      : Nilson César
Data       : Setembro/2021
*/
Function DI501DLnLt(nRecno)

Local lRet := .T.
Local cQuery := ""
Local i,aTabDel
   
If ValType(nRecno) == "N"
   SWV->(DbGoTo(nRecno))
EndIf

If SWV->(!Eof())

   //Deleta as obrigações de anuência das n.c.m's (EKQ)
   cQuery:= GetQryLnWV("3")
   cQuery:= ChangeQuery(cQuery)
   EasyQry(cQuery, "RECNOSEKQ")
   RECNOSEKQ->(DbGoTop())
   If RECNOSEKQ->(!Bof()) .And. RECNOSEKQ->(!Eof())
      Do While RECNOSEKQ->(!Eof())
         EKQ->(DbGoTo(RECNOSEKQ->R_E_C_N_O_))
         EKQ->(RecLock("EKQ",.F.))
         EKQ->(DBDelete())
         EKQ->(MsUnlock())
         RECNOSEKQ->(DbSkip())
      EndDo
   EndIf
   RECNOSEKQ->(DBCloseArea())

   //Deleta os registros vinculados à tabela SWV pelo campo WV_ID
   aTabDel := {'EIJ','EIK','EIN','EJ9'}
   For i := 1 To Len(aTabDel)
      cQuery := ChangeQuery( GetQryLnWV( '5',,aTabDel[i] ) )
      cTmpAlias := "RECNOS"+aTabDel[i]
      EasyQry(cQuery, cTmpAlias  )
      If (cTmpAlias)->(!Bof()) .And. (cTmpAlias)->(!Eof())
         Do While (cTmpAlias)->(!Eof())
            (aTabDel[i])->(DbGoTo((cTmpAlias)->R_E_C_N_O_))
            (aTabDel[i])->(RecLock(aTabDel[i],.F.))
            (aTabDel[i])->(DBDelete())
            (aTabDel[i])->(MsUnlock())
            (cTmpAlias)->(DbSkip())
         EndDo
      EndIf
      (cTmpAlias)->(DBCloseArea())
   Next i
   
   //Deleta o registro de Lote
   SWV->(RecLock("SWV",.F.))
   SWV->(DbDelete())
   SWV->(MsUnlock())
ENDIF

Return lRet

/*
Funcao     : DI501ILnLt
Objetivo   : Incluir registro da tabela SWV posicionado e os registros de EKQ associados.
Parametros : nRecno - Recno do registro da SWV. Se não informado, assume que já está posicionado.
Retorno    : Lógico
Autor      : Nilson César
Data       : Setembro/2021
*/
Function DI501ILnLt(nRecno)

Local lRet := .T.
Local cQuery := ""
Local aOrdTabs := SaveOrd({"SWV","EKQ"})
Local i,j,aLinesEKQ,aVlCpos
Local cSeqAnt, cIDWVAnt

SWV->(DbSetOrder(5)) // WV_FILIAL + WV_HAWB + WV_ID
If SWV->(AvSeekLast( xFilial("SWV")+M->W6_HAWB ,,.T.))
   cNextIDWV  := SomaIt( SWV->WV_ID )
else
   cNExtIDWV  := StrZero(1,AvSX3("WV_ID",AV_TAMANHO))
EndIf

SWV->(DbSetOrder(3))
EKQ->(DbSetOrder(1))
If SWV->(AvSeekLast( xFilial("SWV")+M->W6_HAWB+WKSW8ALTQT->WKINVOICE+WKSW8ALTQT->WKPO_NUM+WKSW8ALTQT->WKPOSICAO ,,.T.))
   
   cSeqAnt         := SWV->WV_SEQUENC
   cNextSeq        := SomaIt( cSeqAnt )
   cIDWVAnt        := SWV->WV_ID
   SWV->(RecLock("SWV",.T.))
   SWV->WV_FILIAL  := xFilial("SWV")
   SWV->WV_HAWB    := M->W6_HAWB
   SWV->WV_PO_NUM  := WKSW8ALTQT->WKPO_NUM
   SWV->WV_POSICAO := WKSW8ALTQT->WKPOSICAO
   SWV->WV_REG     := WKSW8ALTQT->WKREG
   SWV->WV_FORN    := WKSW8ALTQT->WKFORN
   SWV->WV_FORLOJ  := WKSW8ALTQT->W8_FORLOJ
   SWV->WV_INVOICE := WKSW8ALTQT->WKINVOICE
   SWV->WV_COD_I   := WKSW8ALTQT->WKCOD_I
   SWV->WV_CC      := WKSW8ALTQT->WKCC
   SWV->WV_PGI_NUM := WKSW8ALTQT->WKPGI_NUM
   SWV->WV_SI_NUM  := WKSW8ALTQT->WKSI_NUM
   SWV->WV_SEQUENC := cNextSeq
   SWV->WV_ID      := cNextIDWV
   SWV->WV_QTDE    := ABS(WKSW8ALTQT->DIFERENCA)
   SWV->(MsUnlock())
   
   CpyLnTab('EKQ', xFilial("EKQ") + SWV->WV_HAWB + SWV->WV_INVOICE + SWV->WV_PO_NUM + SWV->WV_POSICAO + cSeqAnt ,cNextSeq,cNextIDWV)
   CpyLnTab('EIJ', xFilial("EIJ") + SWV->WV_HAWB + cIDWVAnt                                                     ,cNextSeq,cNextIDWV)
   CpyLnTab('EIK', xFilial("EIK") + SWV->WV_HAWB + cIDWVAnt                                                     ,cNextSeq,cNextIDWV)
   CpyLnTab('EIN', xFilial("EIN") + SWV->WV_HAWB + cIDWVAnt                                                     ,cNextSeq,cNextIDWV)
   CpyLnTab('EJ9', xFilial("EJ9") + SWV->WV_HAWB + cIDWVAnt                                                     ,cNextSeq,cNextIDWV)

EndIf

RestOrd(aOrdTabs,.T.)

Return lRet

/*
Funcao     : DI501EKQDL
Objetivo   : Deletar os registros da tabela EQK (obrigações de LPCO por n.c.m)
             relacionados a linha de lote informada.
Parametros : aChaveEKQ - Array com os dados da chave do Lote para busca de 
             registros relacionados na tabela EKQ
Retorno    : Lógico
Autor      : Nilson César
Data       : Outubro/2021
*/
Function DI501EKQDL(aChaveEKQ)
   Local cQuery := ""
   
   cQuery += "SELECT EKQ.R_E_C_N_O_ EKQRECNO "
   cQuery += " FROM "+RetSqlName("EKQ")+" EKQ"
   cQuery += " WHERE EKQ.D_E_L_E_T_ = ' '"
   cQuery += " AND EKQ.EKQ_FILIAL   = '"+aChaveEKQ[1]+"'"
   cQuery += " AND EKQ.EKQ_HAWB     = '"+aChaveEKQ[2]+"'"
   cQuery += " AND EKQ.EKQ_INVOIC   = '"+aChaveEKQ[3]+"'"
   cQuery += " AND EKQ.EKQ_PO_NUM   = '"+aChaveEKQ[4]+"'"
   cQuery += " AND EKQ.EKQ_POSICA   = '"+aChaveEKQ[5]+"'"

   cQuery := ChangeQuery(cQuery)
   EasyQry(cQuery, "RECDELEKQ")
   RECDELEKQ->(DbGoTop())
   If RECDELEKQ->(!Bof()) .And. RECDELEKQ->(!Eof())
      Do While RECDELEKQ->(!Eof())
         EKQ->(DbGoTo(RECDELEKQ->EKQRECNO))
         EKQ->(RecLock("EKQ",.F.))
         EKQ->(DBDelete())
         EKQ->(MsUnlock())
         RECDELEKQ->(DbSkip())
      EndDo
   EndIf
   RECDELEKQ->(DbCloseArea())
Return .T.


/*
Funcao     : DI501IDWVD
Objetivo   : Deletar os registros das tabela EIJ/EIK/EIN e EJ9 relacionadas com a tabela 
             SWV pelo campo WV_ID (Processo DUIMP)
Parametros : aChaveIDWV - Array com os dados da chave do Lote para busca de 
             registros relacionados na tabela EKQ
Retorno    : Lógico
Autor      : Nilson César
Data       : Novembro/2021
*/
Function DI501IDWVD(aChaveIDWV)

Local i, cQuery, cTmpAlias
Local aTabDel := {'EIJ','EIK','EIN','EJ9'}

   For i := 1 To Len(aTabDel)

      cQuery := ""
      cQuery += "SELECT "+aTabDel[i]+".R_E_C_N_O_ "
      cQuery += " FROM "+RetSqlName(aTabDel[i])+" "+aTabDel[i]
      cQuery += " WHERE "+aTabDel[i]+".D_E_L_E_T_ = ' '"
      cQuery += " AND "+aTabDel[i]+"."+aTabDel[i]+"_FILIAL   = '"+xFilial(aTabDel[i])+"'"
      cQuery += " AND "+aTabDel[i]+"."+aTabDel[i]+"_HAWB     = '"+aChaveIDWV[1]+"'"
      cQuery += " AND "+aTabDel[i]+"."+aTabDel[i]+"_IDWV     = '"+aChaveIDWV[2]+"'"
      cQuery := ChangeQuery( cQuery )

      cTmpAlias := "RECNOS"+aTabDel[i]
      EasyQry(cQuery, cTmpAlias  )
      If (cTmpAlias)->(!Bof()) .And. (cTmpAlias)->(!Eof())
         Do While (cTmpAlias)->(!Eof())
            (aTabDel[i])->(DbGoTo((cTmpAlias)->R_E_C_N_O_))
            (aTabDel[i])->(RecLock(aTabDel[i],.F.))
            (aTabDel[i])->(DBDelete())
            (aTabDel[i])->(MsUnlock())
            (cTmpAlias)->(DbSkip())
         EndDo
      EndIf
      (cTmpAlias)->(DBCloseArea())

   Next i

Return

/*
Funcao     : GERTXSISC
Objetivo   : Gerar as adições "virtuais", calcular a taxa Siscomex e gravar na tabela de Despesas.
Parametros : Nenhum
Retorno    : Lógico
Autor      : Nilson César
Data       : Outubro/2021
*/
Static Function GERTXSISC()

Local nVAlue := 0
Local aRegAdiCapa := {}
Local nTaxSiscDI
Local cMsgTXSisc
//Variáveis de escopo private utilizadas pela rotina AdicaoTela no fonte EICADICAO
cAliasItensSW8:="Work_SW8"
EICADSTELA('CRIA_WORKS')

aRegAdiCapa := {}
Work_EIJ->(DBEval({|| aAdd(aRegAdiCapa , {EIJ_ADICAO , WK_RECNO})     } ))

//Variáveis de escopo private utilizadas pela rotina DI500WorkEIJ e associadas
cFilSYD     := xFilial('SYD')
cFilSY6     := xFilial('SY6')
cFilSA2     := xFilial('SA2')
cFilED0     := xFilial('ED0')
aGrvEIJ     := {}
aGrvEIL     := {}
aGrvEIK     := {}
nFOBMaior   := 0
Work_EIJ->(avzap()) //MFR 02/01/2022 OSSME-6563
Work_SW8->(DBEval({|| DI500WorkEIJ(Work_SW8->WKADICAO, aRegAdiCapa)   } ))

nTaxSiscDI := GetTxSisDI( Work_EIJ->(EasyRecCount()) ) 
SWD->(DbSetOrder(1))                                                                                                            //"O valor da taxa de utilização do Siscomex reapurado do processo ( XXXX ) é diferente do valor atual da despesa lançada ( YYYY ). Deseja atualizar o valor da despesa para o valor de R$ XXXX apurado pelo sistema ?" ### "Divergência da taxa Siscomex"
If !SWD->(DbSeek(  xFilial("SWD") + M->W6_HAWB + Alltrim(cMV_CODTXSI)  )) .OR. If( SWD->WD_VALOR_R <> nTaxSiscDI , MsgYesNo(  StrTran( cMsgTXSisc := StrTran( STR0282 , 'XXXX' , Alltrim(STR(nTaxSiscDI,AvSX3("WD_VALOR_R",AV_TAMANHO),AvSX3("WD_VALOR_R",AV_DECIMAL)))) , 'YYYY' , Alltrim(STR(SWD->WD_VALOR_R,AvSX3("WD_VALOR_R",AV_TAMANHO),AvSX3("WD_VALOR_R",AV_DECIMAL)) ) ) ,STR0283  ) , .F. )
   DI400Grvddi(SW6->W6_HAWB,SW6->W6_DT,cMV_CODTXSI,nTaxSiscDI,0,,,"415")
EndIf

Return

/*
Funcao     : GetTxSisDI
Objetivo   : Calcular o valor total da taxa Siscomex por processo com base
             no total de adições existentes.
Parametros : nQtdAdic - Quantidade de adições do processo
Retorno    : nValor - Valor total apurado de taxa Siscomex
Autor      : Nilson César
Data       : Outubro/2021
*/
Static Function GetTxSisDI(nQtdAdic)
Local nAdicao
Local nValor := Val(FWGetSX5("C5","00")[1][4]) //Valor fixo por processo

For nAdicao := 1 To nQtdAdic

   If nAdicao < 3
      nValor += val(FWGetSX5("C5","02")[1][4])
   ElseIf nAdicao >= 3 .And. nAdicao < 6
      nValor += val(FWGetSX5("C5","05")[1][4])
   ElseIf nAdicao >= 6 .And. nAdicao < 11
      nValor += val(FWGetSX5("C5","10")[1][4])
   ElseIf nAdicao >= 11 .And. nAdicao < 21 
      nValor += val(FWGetSX5("C5","20")[1][4])
   ElseIf nAdicao >= 21 .And. nAdicao < 51
      nValor += val(FWGetSX5("C5","50")[1][4])
   ElseIf nAdicao >= 51
      nValor += val(FWGetSX5("C5","99")[1][4]) 
   EndIf

Next i

REturn nValor


/*
Funcao     : CpyLnTab
Objetivo   : Copia os dados de uma linha da tabela para uma nova linha.
Parametros : Alias da tabela (EKQ,EIJ,EIK,EIN ou EJ9)
Retorno    : Nenhum
Autor      : Nilson César
Data       : Novembro/2021
*/
Static Function CpyLnTab(cAlias,cSeek,cWVSeq,cWVId)

Local cPfxCpo, cChave, aLines, aVlCpos, i, j, nOrdInex
   
   cPfxCpo   := cAlias
   nOrdIndex := If(cAlias == 'EKQ', 1 , If(cAlias == 'EIJ', 3 , 2 ) )
   (cAlias)->(DbSetOrder(nOrdIndex))
   If (cAlias)->(DbSeek( cSeek ) )
      aLines := {}
      Do While (cAlias)->(!Eof()) .And. Left( (cAlias)->&(IndexKey()) , Len(cSeek) ) == cSeek
         aVlCpos := {}
         For i := 1 To (cAlias)->(FCount())
            aAdd( aVlCpos,  (cAlias)->(FieldGet(i)) )
         Next i
         aAdd( aLines , aVlCpos  )
         (cAlias)->(DbSkip())
      EndDo

      For i := 1 To Len(aLines)
         (cAlias)->(RecLock(cAlias,.T.))
         For j := 1 To (cAlias)->(FCount())
            (cAlias)->(FieldPut( j , aLines[i][j]   ))
         Next j
 
         If cAlias == "EKQ"
            (cAlias)->&(cPfxCpo+"_LPCO")   := ''
            (cAlias)->&(cPfxCpo+"_VERSAO") := ''
            (cAlias)->&(cPfxCpo+"_SEQUEN") := cWVSeq
         Else
            (cAlias)->&(cPfxCpo+"_IDWV") := cWVId
         EndIf

         If cAlias == "EIJ"
            If GetSx3Cache( "EIJ_DSCCIT" , "X3_VISUAL") == "V"
               (cAlias)->EIJ_DSCCIT := Posicione("Work_SW8",1,WKSW8ALTQT->WKINVOICE + WKSW8ALTQT->WKFORN + WKSW8ALTQT->W8_FORLOJ + WKSW8ALTQT->WKPO_NUM + WKSW8ALTQT->WKPOSICAO,"Work_SW8->WKDESC_DI")
            EndIf
         EndIf
         

         (cAlias)->(MsUnlock())
      Next i      
   EndIf

Return


/*
Funcao     : GetListInv
Objetivo   : Cria uma string com todas as invoices antecipadas já selecionadas e a que foi informada para validação na função VrfSldInvAnt
Parametros : -
Retorno    : cRet - String com todas as invoices antecipadas
Autor      : THTS - Tiago Tudisco
Data       : 07/02/2022
*/
Static Function GetListInv()
Local cRet := ""
Local nI

For nI := 1 To Len(aInv)
   cRet += "'" + aInv[nI] + "',"
Next

cRet += "'" + cInv + "'"

Return cRet
