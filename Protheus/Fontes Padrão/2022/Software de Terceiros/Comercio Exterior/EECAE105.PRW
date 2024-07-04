#INCLUDE "eecae105.ch"
#include "dbtree.ch"
#include "EEC.CH"

#define PRE "Pré-Embarque"
#define POS "Pós-Embarque"

/*
Programa        : EECAE105.PRW
Objetivo        : Proc. Embarque - Manutenções Diversas.
Autor           : Jeferson Barros Jr.
Data/Hora       : 10/03/03 13:26.
Obs.            :
*/


/*
Funcao      : AE100Adian()
Parametros  : lChamadaEmb - Define se a função foi chamada da manutenção
                            de embarques (.T.) ou de Câmbio (.F.)
Retorno     : .t./.f.
Objetivos   : Manutenção de adiantamentos.
Autor       : Jeferson Barros Jr.
Data/Hora   : 11/11/2002 09:15.
Revisao     :
Obs.        :
*/
*-----------------------------------------------------*
Function AE100Adian(cAlias,nReg,nOpc,uPar1,lChamadaEmb)
*-----------------------------------------------------*
Local bOk := {|| nOpcao:=1, If(Type("lAe100Auto") <> "L" .Or. !lAe100Auto, oDlg:End(), )} , bCancel := {|| oDlg:End()}
Local aButtons := {}, /*aCpos := {}, */ aOrd:=SaveOrd({"EEQ","EE9"})//, aSemSx3:={}// TLM 15/05/2008, aPedidos:={} // By JPP - 21/12/2006 - 09:00 - Variável passou para private
Local oDlg, oMsSelect, oGetTot
Local cArq, cArq2, cPictDt:="  /  /  ", cPictVl := "@E 999,999,999,999.99", cTit
Local nOpcao := 0, i:=0
Local lRet:= .t.
Local aFil := {}, cFil := ""
Local nCont:= 1, nPosAdian
Local aOldModulo := {cModulo,nModulo}
Local aAdRestricao:= {}
Local cMsgErro	:= ""

//DFS - 01/04/13 - Inclusão de array private para uso em customizações.
Private aButtonsAux := {}
// ** JPM - colocada como private pra ser acessada pelo pto entrada
Private aCpos := {}
Private aSemSx3ad:={} // TLM 15/08/2008 - Variavel  Local aSemSx3 alterada para Private aSemSx3ad para o browse do adiantamento ser personalizado.
Private aDeletados := {}, nTotAdia := 0, nTotProc := 0, nTotReceb := 0
Private cMarca := GetMark()
Private aTela:={}, aGets:={}
Private lLoop := .F.
Private aPedidos:={} // By JPP - 21/12/2006 - 09:00
Private lCallEmb := .T.
Private aCores := {} //FDR - 27/03/13
Private lCpoAcrDcr := AVFLAGS("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP") //NCF - 14/08/2015 - Tratamento Acresc./Decres. no controle de cambio SIGAEEC x SIGAFIN
Private lLgxPenden := .F. //THTS - 04/04/2018

Default lChamadaEmb := .T.

Begin Sequence

  cModulo := "EEC"
  nModulo := 29

  lCallEmb := lChamadaEmb

  /*
  aCpos := {{{|| Work_Pgto->WK_STATUS}                ,"",STR0001},; //"Tipo"
            {{|| Transf(Work_Pgto->EEQ_PGT,cPictDt)}  ,"",AVSX3("EEQ_PGT",AV_TITULO)},;
            {{|| Work_Pgto->EEQ_PARC}                 ,"",STR0002},; //"Nro.Parcela"
            {{|| Transf(Work_Pgto->EEQ_VL,cPictVl)}   ,"",STR0003+Space(300)}} //"Valor"
  */

  // ** Colunas para o Browse ...
  aAdd(aCpos,{{|| Work_Pgto->WK_STATUS}                ,"",STR0001}) //"Tipo"
  If !lCallEmb
     aAdd(aCpos,{{|| Work_Pgto->WK_PREPOS}             ,"",STR0149}) //"Fase"
  EndIf
  aAdd(aCpos,{{|| Transf(Work_Pgto->EEQ_PGT,cPictDt)}  ,"",AVSX3("EEQ_PGT",AV_TITULO)})
  aAdd(aCpos,{{|| Work_Pgto->EEQ_PARC}                 ,"",STR0002}) //"Nro.Parcela"
  aAdd(aCpos,{{|| Work_Pgto->EEQ_MOEDA}                ,"",STR0169})  //"Moeda"  // GFP - 23/08/2012
  aAdd(aCpos,{{|| Transf(Work_Pgto->EEQ_VL,cPictVl)}   ,"",STR0003+Space(300)}) //"Valor"

  IF lCpoAcrDcr
     AAdd(aCpos, {{|| Transf(Work_Pgto->EEQ_DECRES,cPictVl)},"",AVSX3("EEQ_DECRES",AV_TITULO)} ) //"Decrescimos"
  ENDIF
  // by CRF - 04/11/2010 - 14:23
  aCpos:= AddCpoUser(aCpos,"EEQ","5","Work_Pgto")

  // ** Definição dos botoes da Enchoice Bar.
  aAdd(aButtons,{"BMPVISUAL" /*"ANALITICO"*/, {|| AE100AdiMan(VIS_DET)},STR0004}) //"Visualizar"

  If (lCallEmb .and. Empty(EEC->EEC_DTEMBA)) .or. !lCallEmb
     aAdd(aButtons,{"BMPINCLUIR" /*"NOVACELULA"*/,{|| AE100Add(oMsSelect,oGetTot,,aAdRestricao)},STR0005/*, STR0152*/}) //"Associar Adiantamento", "Associar"
     aAdd(aButtons,{"EXCLUIR",   {|| AE100AdiMan(EXC_DET,oMsSelect,oGetTot,,aAdRestricao)},STR0006}) //"Excluir"
  EndIf

  aCampos:= Array(EEQ->(fCount()))

  aAdd(aSemSx3ad,{"EEQ_PREEMB","C",AvSx3("EEQ_PREEMB",AV_TAMANHO),AvSx3("EEQ_PREEMB",AV_DECIMAL)})
  Aadd(aSemSx3ad,{"RECNO","N",10,0})
  Aadd(aSemSx3ad,{"WK_STATUS","C",30,0})
  aAdd(aSemSx3ad,{"WK_PREPOS","C",12,0})

  //RMD - Integração com o módulo SIGAFIN
  AddNaoUsado(aSemSx3ad, "EEQ_FINNUM")

  // ** Cria work com os adiantamentos por embarque.
  cArq   := E_CriaTrab("EEQ",aSemSx3ad,"Work_Pgto")
  IndRegua("Work_Pgto",cArq+TEOrdBagExt(),"EEQ_FASE+EEQ_PREEMB+EEQ_PARC",,,STR0009) //"Processando Arquivo Temporário..."
  Set Index To (cArq+TEOrdBagExt())

  cNomArq:=CriaTrab(Nil,.f.)
  IndRegua("Work_Pgto",cNomArq+TEOrdBagExt(),"EEQ_FAOR+EEQ_PROR+EEQ_PAOR")

  Set Index to (cArq+TEOrdBagExt()),(cNomArq+TEOrdBagExt())

  EEQ->(DbSetOrder(6)) // Fase+Preemb+Parcela"
  EEQ->(DbSeek(xFilial("EEQ")+"E"+EEC->EEC_PREEMB))

  Do While EEQ->(!Eof()) .And. EEQ->EEQ_FILIAL == xFilial("EEQ") .And.;
                               EEQ->EEQ_FASE   == "E" .And.;
                               EEQ->EEQ_PREEMB == EEC->EEC_PREEMB
     If EEQ->EEQ_TIPO = "A"
        Work_Pgto->(DbAppend())

        RegToMemory("EEQ", .F.) //WFS
        AvReplace("EEQ","Work_Pgto")
        Work_Pgto->RECNO := EEQ->(RecNo())

        Work_Pgto->WK_STATUS := STR0007+If(Work_Pgto->EEQ_FAOR="P",STR0008+AllTrim(Work_Pgto->EEQ_PROR),STR0009) //"Vinculado/"###"Processo: "###"Cliente"

        If !lCallEmb
           If EEQ->EEQ_EVENT == "603"
              Work_Pgto->WK_PREPOS := POS
           ElseIf EEQ->EEQ_EVENT == "101"
              Work_Pgto->WK_PREPOS := PRE
           EndIf
        EndIf

        // ** Acumula os adiantamentos.
        nTotAdia += Work_Pgto->EEQ_VL
     
     Else //Verificar as parcelas que estao com data de movimento no exterior preenchida (parcelas ja recebidas)

        If EEQ->EEQ_EVENT == "101" .And. !Empty(EEQ->EEQ_DTCE)
            nTotReceb += EEQ->EEQ_VL
        EndIf

     EndIf

     EEQ->(DbSkip())
  EndDo

  Work_Pgto->(DbGoTop())

  IF EasyEntryPoint("EECAE105")  // TLM 15/05/2008
     ExecBlock("EECAE105",.F.,.F.,"ADD_aSemSX3ad")
  Endif

  // ** Carrega os adiantamentos do importador...
  aSemSx3ad:={}
  aAdd(aSemSx3ad,{"EEQ_FILIAL","C",AvSx3("EEQ_FILIAL",AV_TAMANHO),AvSx3("EEQ_FILIAL",AV_DECIMAL)})  // GFP - 19/12/2013
  aAdd(aSemSx3ad,{"EEQ_PREEMB","C",AvSx3("EEQ_PREEMB",AV_TAMANHO),AvSx3("EEQ_PREEMB",AV_DECIMAL)})
  Aadd(aSemSx3ad,{"RECNO"    ,"N",10,0})
  Aadd(aSemSx3ad,{"WK_FLAG"  ,"C",02,0})
  Aadd(aSemSx3ad,{"WK_VLADI" ,"N",AVSX3("EEQ_VL",AV_TAMANHO),AVSX3("EEQ_VL",AV_DECIMAL)})

  //RMD - Integração com o módulo SIGAFIN
  AddNaoUsado(aSemSx3ad, "EEQ_FINNUM")

 //by CRF - 08/10/2010 10:33
 aSemSx3ad := AddWkCpoUser(aSemSx3ad,"EEQ")

  cArq2   := E_CriaTrab("EEQ",aSemSx3ad,"Work_Adia")
  IndRegua("Work_Adia",cArq2+TEOrdBagExt(),"EEQ_FASE+EEQ_PREEMB+EEQ_PARC",,,STR0010) //"Processando Arquivo Temporário..."
  Set Index To (cArq2+TEOrdBagExt())

   cFil := xFilial("EEQ")

   //ER - 29/06/2007 - Quando a tabela EEQ for compatilhada, o cFil será vazio.
   If Empty(cFil)
      aAdd(aFil,cFil)
   Else
      //Seleciona todas as Filiais
      aFil := AvgSelectFil(Type("lAe100Auto") <> "L" .Or. !lAe100Auto)
   EndIf

  For i:=1 to Len(aFil)
     //EEQ->(DbSeek(xFilial("EEQ")+"C"+AllTrim(EEC->EEC_IMPORT)+AllTrim(EEC->EEC_IMLOJA)))
     EEQ->(DbSeek(aFil[i]+"C"+AvKey(EEC->EEC_IMPORT+EEC->EEC_IMLOJA,"EEQ_PREEMB")))

     Do While EEQ->(!Eof()) .And. EEQ->EEQ_FILIAL == aFil[i] .And.;
                                  EEQ->EEQ_FASE   == "C" .And.;
                                  EEQ->EEQ_PREEMB == AvKey(EEC->EEC_IMPORT+EEC->EEC_IMLOJA,"EEQ_PREEMB")
        If EEQ->EEQ_TIPO = "A" .AND. EEQ->EEQ_MOEDA == EEC->EEC_MOEDA .AND. EEQ->EEQ_SALDO > 0   // GFP - 23/08/2012 - Apenas carrega adiantamentos de moeda igual ao do processo.

           RegToMemory("EEQ", .F.) //WFS
           Work_Adia->(DbAppend())
           AvReplace("EEQ","Work_Adia")
           Work_Adia->RECNO := EEQ->(RecNo())
        EndIf

        EEQ->(DbSkip())
     EndDo
  Next

  // ** Carrega os adiantamentos dos pedidos vinculados...
  EE9->(DbSetOrder(2))
  EE9->(DbSeek(xFilial("EE9")+EEC->EEC_PREEMB))
  Do While EE9->(!Eof()) .And. EE9->EE9_FILIAL == xFilial("EE9") .And. EE9->EE9_PREEMB == EEC->EEC_PREEMB

     If aScan(aPedidos,EE9->EE9_PEDIDO) = 0
        aAdd(aPedidos,EE9->EE9_PEDIDO)
     EndIf

     EE9->(DbSkip())
  EndDo

  IF EasyEntryPoint("EECAE105") // By JPP - 21/12/2006 - 09:00 - Inclusão do ponto de entrada.
     ExecBlock("EECAE105",.F.,.F.,"ANTES_LER_ADIAN_PED")
  Endif

  For i:=1 To Len(aPedidos)
     EEQ->(DbSeek(xFilial("EEQ")+"P"+aPedidos[i]))
     Do While EEQ->(!Eof()) .And. EEQ->EEQ_FILIAL == xFilial("EEQ") .And.;
                                  EEQ->EEQ_FASE   == "P" .And.;
                                  EEQ->EEQ_PREEMB == AvKey(aPedidos[i],"EEQ_PREEMB")

        RegToMemory("EEQ", .F.) //WFS - 01/10/2012
        If EEQ->EEQ_TIPO = "A" .AND. !Empty(EEQ->EEQ_DTCE) .AND. AllTrim(EEQ->EEQ_MOEDA) == AllTrim(EEC->EEC_MOEDA) //.AND. EEQ->EEQ_SALDO > 0   // GFP - 23/08/2012 - Apenas carrega adiantamentos de moeda igual ao do processo.   // GFP - 29/08/2012 - Apenas carrega adiantamentos que possuam data de credito no exterior.
           Work_Adia->(DbAppend())
           AvReplace("EEQ","Work_Adia")
           Work_Adia->RECNO := EEQ->(RecNo())
        EndIf

        EEQ->(DbSkip())
     EndDo
  Next

  Work_Pgto->(DbGoTop())
  Do While Work_Pgto->(!Eof())
     If Work_Pgto->EEQ_FAOR == "C" .Or. Work_Pgto->EEQ_FAOR == "P"
        If lCallEmb
           If Work_Adia->(DbSeek(Work_Pgto->EEQ_FAOR+Work_Pgto->EEQ_PROR+Work_Pgto->EEQ_PAOR))
              Work_Adia->WK_FLAG  := cMarca
              Work_Adia->WK_VLADI := Work_Pgto->EEQ_VL
           EndIf
        Else
           If Work_Adia->(DbSeek(Work_Pgto->EEQ_FAOR+Work_Pgto->EEQ_PROR+Work_Pgto->EEQ_PAOR))
              If Work_Pgto->WK_PREPOS == POS
                 Work_Adia->WK_FLAG := cMarca
                 Work_Adia->WK_VLADI := Work_Pgto->EEQ_VL
              EndIf
           EndIf
        EndIf
        Work_Adia->(DbGoTop())
     EndIf
     Work_Pgto->(DbSkip())
  EndDo

  Work_Pgto->(DbGoTop())

  cTit        := STR0011+AllTrim(Transf(EEC->EEC_PREEMB,AVSX3("EEC_PREEMB",AV_PICTURE))) //"Embarque: "
  aTela := {} ;  aGets := {}

  nTotProc := EEC->EEC_TOTPED

  IF EasyEntryPoint("EECAE105") // ** JPM - ponto de entrada antes da tela
     ExecBlock("EECAE105",.F.,.F.,"ANTES_TELA_PRINCIPAL_ADIANT")
  Endif

   DO WHILE .T.
        nOpcao:= 0

  If IsMemVar("lAE100Auto") .And. lAE100Auto

    If (nPosEEQ := aScan(aAE100Auto, {|x| x[1] == "EEQ" })) > 0
        For nPosAdian := 1 To Len(aAE100Auto[nPosEEQ][2])
            AvKeyAuto(aAE100Auto[nPosEEQ][2][nPosAdian])
            If !(lRet := AE100Add(,,aAE100Auto[nPosEEQ][2][nPosAdian]))
                lMsErroAuto := .T.
                Exit
            EndIf
        Next
        If !lMsErroAuto
            Eval(bOk)
        EndIf
    EndIf

  Else

      DEFINE MSDIALOG oDlg TITLE cTit FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

         oPanel:=	TPanel():New(0,0, "", oDlg,, .T., ,,,0,0,,.T.)
         oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
         
         @ 15,007 Say STR0012+AllTrim(EEC->EEC_MOEDA)        Size 80,07 OF oPanel PIXEL //"Total Embarque "
         @ 15,150 Say STR0013+AllTrim(EEC->EEC_MOEDA) Size 80,07 OF oPanel PIXEL //"Total Adiantamento(s) "

         @ 15,70  MSGET nTotProc PICTURE AVSX3("EEC_TOTPED",AV_PICTURE) Size 065,07  OF oPanel PIXEL When .f. HASBUTTON
         @ 15,225 MSGET oGetTot VAR nTotAdia PICTURE AVSX3("EEC_TOTPED",AV_PICTURE) Size 065,07  OF oPanel PIXEL When .f. HASBUTTON

         aPos := PosDlgDown(oPanel)
         aPos[1] := 29
         aPos[3] -= 32

         //DFS - 01/04/13 - Inclusão de array auxiliar private, que receberá o conteúdo do aButtons para utilização em Ponto de Entrada.
         aButtonsAux := aClone(aButtons)
         //FDR - 27/03/13 - PE para incluir legenda nas parcelas de adiatamento
         IF (EasyEntryPoint("EECAE105"),Execblock("EECAE105",.F.,.F.,"LEGENDA"),)
         //DFS - 01/04/13 - Retorno do array auxiliar private para o array aButtons, para que, retorne as informações customizadas.
         aButtons := aClone(aButtonsAux)


         oMsSelect := MsSelect():New("Work_Pgto",,,aCpos,,,aPos,,,oPanel,,aCores)
         oMsSelect:bAval := {|| AE100AdiMan(VIS_DET)}
         oDlg:lMaximized := .T.
      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons)
  EndIf

     If nOpcao = 1

        lLoop:=.F.
        IF EasyEntryPoint("EECAE105")//AWR - 22/05/2006
           EXECBLOCK("EECAE105",.F.,.F.,"ANTES_GRAVA")
        EndIf
        IF lLoop
           Loop
        EndIf

        Begin Transaction
           Processa({|| lRet:= AE100RecAdian(@cMsgErro)})

           If !lCallEmb .And. lRet

              M->EEC_DTEMBA := EEC->EEC_DTEMBA
              M->EEC_STATUS := EEC->EEC_STATUS
              M->EEC_STTDES := EEC->EEC_STTDES
              DbSelectArea("EEQ")
              AF200Status("EEQ",,.T.)
           EndIf

           If __lSX8 .And. lRet
              ConfirmSX8()
           Endif

           //Caso a integração com o financeiro não tenha sido concluida
           If (IsIntEnable("001") .Or. IsIntEnable("010")) .And. !lRet
              RollBackSX8()
              ELinkRollBackTran()
           EndIf

        End Transaction
        If !lRet .And. IsIntEnable("001")
            EasyElinkError("FIN", !(IsMemVar("lAE100Auto") .And. lAE100Auto))
        EndIf
        //MFR 26/10/2020 OSSME-5268
		  //If !lCallEmb .And. lRet
		  //		MsgInfo(STR0150,STR0019)//"As informações do R.E. deverão ser atualizadas. A vinculação de adiantamentos Pós-Embarque não atualiza o RE."###"Atenção"
		  //Else
        If !lRet .And. !Empty(cMsgErro)
		  		EasyHelp(cMsgErro,STR0033) //"Não será possível realizar a associação do Adiantamento, pois a parcela de câmbio possui desconto."###"Atenção."
		  EndIf
     Else
        If __lSX8
           //DFS - 06/10/12 - Chamada da função para salvar as integrações no LogViewer
           ELinkRollBackTran()
        Endif
     Endif

     Exit

  EndDo

End Sequence

If Select("Work_Pgto") > 0
   Work_Pgto->(E_EraseArq(cArq,cNomArq))
EndIf

If Select("Work_Adia") > 0
   Work_Adia->(E_EraseArq(cArq2))
EndIf

RestOrd(aOrd, .T.)

cModulo := aOldModulo[1]
nModulo := aOldModulo[2]

Return lRet

/*
Funcao      : AE100Add(oMsSelect,oGetTot).
Parametros  : Objetos para refresh.
              oGetTot
              aVincAuto
              aAdRestricao: Recno dos adiantamentos desmarcados que já possuem vínculo com o processo
Retorno     : .T.
Objetivos   : Associar adiantamentos com base no importador e no(s) processo(s) vinculado(s).
Autor       : Jeferson Barros Jr.
Data/Hora   : 11/11/02 17:30.
Obs.        :
*/
*------------------------------------------------------------------*
Static Function AE100Add(oMsSelect,oGetTot,aVincAuto, aAdRestricao)
*------------------------------------------------------------------*
Local cTitulo, cPictDt:="  /  /  ", cPictVl := "@E 999,999,999,999.99"
Local cCliCod, cCliNome, cCliCodPais, cCliDscPais
Local bOk:={|| If(Type("lAe100Auto") <> "L" .Or. !lAe100Auto, oDlg:End(),), nOpcao:=1}, bCancel:={||oDlg:End()}
Local aPos, aOrd:=SaveOrd({"SA1","Work_Pgto"}) // , aCpos - TLM 15/08/2008
Local lRet:=.t., lInverte := .f.
Local nOpcao := 0, nRec := 0
Local oDlg, oMark, lAchou := .F.
Local nRecPgto := 0
Local oPanel1, oPanel2
Local cBkWorkAdi := CriaTrab(,.F.) //THTS - 05/04/2018 - Faz um backup da Work_adia. Caso Seja cancelada as alterações, volta o backup.
Local lBkLgxPend := lLgxPenden //THTS - 05/04/2018 - Faz o backup da variavel que controle se ocorreu alguma operação. Utilizada somente em ambientes Logix
Local cMensagem := "", nCpo
Local aBkpAdRestricao:= {}
Private aCposBrowse // TLM 15/08/2008 - Variavel  Local aCpos alterada para Private aCposBrowse para o browse do adiantamento ser personalizado.
Private oMarkAdd //DFS - 18/04/12 - Objeto para receber os dados do oMark
Private nRecMark := 0 //THTS - 05/04/2018 - Guarda o recno do Adiantamento que foi marcado
Default aAdRestricao:= {}

Begin Sequence

   nRec := Work_Pgto->(RecNo())

   Work_Pgto->(DbGoTop())
   Do While Work_Pgto->(!Eof())
      If Work_Pgto->EEQ_FAOR == "C" .Or. Work_Pgto->EEQ_FAOR == "P"
         If lCallEmb
            If Work_Adia->(DbSeek(Work_Pgto->EEQ_FAOR+Work_Pgto->EEQ_PROR+Work_Pgto->EEQ_PAOR))
               Work_Adia->WK_FLAG  := cMarca
               Work_Adia->WK_VLADI := Work_Pgto->EEQ_VL
            EndIf
          Else
            If Work_Adia->(DbSeek(Work_Pgto->EEQ_FAOR+Work_Pgto->EEQ_PROR+Work_Pgto->EEQ_PAOR))
               If Work_Pgto->WK_PREPOS == POS
                  Work_Adia->WK_FLAG  := cMarca
                  Work_Adia->WK_VLADI := Work_Pgto->EEQ_VL
               EndIf
            EndIf
         EndIf
         Work_Adia->(DbGoTop())
      EndIf
      Work_Pgto->(DbSkip())
   EndDo

   Work_Pgto->(DbGoTo(nRec))

   // ** Valida a moeda do cliente contra a do processo.
   SA1->(DbSeek(xFilial("SA1")+EEC->EEC_IMPORT+EEC->EEC_IMLOJA))

   EXJ->(DbSetOrder(1))
   EXJ->(DbSeek(xFilial("EXJ")+SA1->A1_COD+SA1->A1_LOJA))
   /*  Nopado por GFP - 23/08/2012 - Sistema deve permitir incluir adiantamentos do cliente com moedas diversas
   If EXJ->EXJ_MOEDA <> EEC->EEC_MOEDA
      MsgInfo(STR0014+Replic(ENTER,2)+; //"Não é possível associar adiantamentos do importador."
              STR0015+ENTER+; //"Detalhes:"
              STR0016+EXJ->EXJ_MOEDA+STR0017+ENTER+; //"A moeda de negociação do importador ("###"), é diferente da moeda do "
              STR0018+EEC->EEC_MOEDA+").",STR0019) //"embarque ("###"Atenção"
              Break // By JPP - 24/11/2006 - 16:50 - Quando a moeda do embarque e do cliente forem diferentes, não permitir associar adiantamento.
   EndIf
   */
   // ** Colunas para o Browse ...
   aCposBrowse := {{"WK_FLAG","","  "},;
                  {{|| If(Work_Adia->EEQ_FASE="P",STR0008,STR0020)+AllTrim(Work_Adia->EEQ_PREEMB)},"",STR0021},; //"Processo: "###"Cliente: "###"Adiantamento"
                  {{|| Transf(Work_Adia->EEQ_PGT,cPictDt)}  ,"",AVSX3("EEQ_PGT",AV_TITULO)},;
                  {{|| AllTrim(Work_Adia->EEQ_PARC)}        ,"",STR0022},; //"Parcela"
                  {{|| Work_Adia->EEQ_NRINVO}               ,"",AVSX3("EEQ_NRINVO",AV_TITULO)},; //"Invoice"   //DFS - 28/10/10 - Inclusão do Nr da Invoice.
                  {{|| Work_Adia->EEQ_MOEDA}                ,"",STR0169},; //"Moeda"  // GFP - 23/08/2012
                  {{|| Transf(Work_Adia->WK_VLADI,cPictVl)} ,"",STR0023},; //"Valor Associado"
                  {{|| Transf(Work_Adia->EEQ_SALDO,cPictVl)},"",STR0024},; //"Saldo"
                  {{|| Transf(Work_Adia->EEQ_VL,cPictVl)}   ,"",STR0025+Space(200)},; //"Valor Adiantamento"
                  {{|| Work_Adia->EEQ_FINNUM}               ,"",AVSX3("EEQ_FINNUM",AV_TITULO)}}

   IF lCpoAcrDcr
      AAdd(aCposBrowse, {{|| Transf(Work_Adia->EEQ_DECRES,cPictVl)},"",AVSX3("EEQ_DECRES",AV_TITULO)} ) //"Decrescimos"
   ENDIF

   IF EasyEntryPoint("EECAE105")  // TLM 15/05/2008
      ExecBlock("EECAE105",.F.,.F.,"ADD_BROWSER")
   Endif

   SA1->(DbSetOrder(1))
   SA1->(DbSeek(xFilial("SA1")+EEC->EEC_IMPORT+EEC->EEC_IMLOJA))

   // ** Set das variaveis ...
   cTitulo := STR0026 //"Associação de Adiantamentos."
   cCliCod     := SA1->A1_COD
   cLojaCli    := SA1->A1_LOJA
   cCliNome    := SA1->A1_NOME
   cCliCodPais := SA1->A1_PAIS
   cCliDscPais := Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_NOIDIOM")
   
   Work_Adia->(TETempBackup(cBkWorkAdi))//THTS - 05/04/2018
   aBkpAdRestricao:= AClone(aAdRestricao)
   Work_Adia->(DbGoTop())

   If IsMemVar("lAe100Auto") .And. lAe100Auto
      lExcAuto := .F.
      lFound := .F.
      If (nCpo := aScan(aVincAuto, {|x| x[1] == "AUTDELETA" })) > 0 .And. aVincAuto[nCpo][2] == "S"
         lExcAuto := .T.
      EndIf
      If lExcAuto
         If aScan(aVincAuto, {|x| x[1] == "EEQ_FAOR" .Or. x[2] == "EEQ_PAOR" .Or. x[1] == "EEQ_PROR" }) > 0
            lFound := EasySeekAuto("Work_Pgto", aVincAuto, 2)//Localiza a parcela a Desassociar
         Else
            lFound := EasySeekAuto("Work_Pgto", aVincAuto, 1)
         EndIf
         If lFound
            If !AE100AdiMan(EXC_DET,,,aVincAuto)
               cMensagem :=  STR0178 + ENTER //"Erro ao remover o adiantamento:"
            EndIf
         Else
            cMensagem := STR0179 + ENTER //"Não foi possível localizar o adiantamento:"
         EndIf
      Else//Associação
         If EasySeekAuto("Work_Adia", aVincAuto, 1)//Localiza a parcela a Associar (WORK_ADIA)
            If Empty(Work_Adia->WK_FLAG)
               If (nCpo := aScan(aVincAuto, {|x| x[1] == "AUTVALVINC" })) > 0//Verifica se informou o valor a associar
                  If !AE100Mark(, .T., aVincAuto[nCpo][2])//Marca a parcela informando o valor a associar
                     cMensagem := STR0180 + ENTER //"Erro ao associar o adiantamento:"
                  EndIf
               Else
                  cMensagem := STR0181 + ENTER //"Não foi informado o valor a associar."
               EndIf
            Else
                  cMensagem := STR0182 + ENTER //"A parcela já foi associada ao embarque. É necessário excluir a associação antes de vincular novamente."
            EndIf
         Else
            cMensagem := STR0183 + ENTER //"Não foi possível localizar o adiantamento:"
         EndIf
      EndIf
      If !Empty(cMensagem)
         For nCpo := 1 To Len(aVincAuto)
            cMensagem += aVincAuto[nCpo][1] + ":" + AllTrim(AvConvert(ValType(aVincAuto[nCpo][2]),"C",,aVincAuto[nCpo][2])) + ENTER
         Next
         EasyHelp(cMensagem, STR0177)//"Falha na execução"
         lRet := .F.
      Else
         Eval(bOK)
      EndIf

   Else

      DEFINE MSDIALOG oDlg TITLE cTitulo FROM 9,0 TO 30,80 of oDlg

         //Separação da tela em dois paineis
         oPanel1:= TPanel():New(0, 0, "",oDlg, , .F., .F.,,, (oDlg:nRight-oDlg:nLeft), (oDlg:nBottom-oDlg:nTop)*0.15, , )
         oPanel2:= TPanel():New(0, 0, "",oDlg, , .F., .F.,,, (oDlg:nRight-oDlg:nLeft), (oDlg:nBottom-oDlg:nTop)*0.75, , )

         @ 15,007 Say STR0027 Size 65,07 PIXEL Of oPanel1 //"Codigo"
         @ 15,100 Say STR0028   Size 65,07 PIXEL Of oPanel1 //"Nome"

         @ 15,35  MSGET cCliCod  Size 040,07  Pixel Of oPanel1 When .f.
         @ 15,140 MSGET cCliNome Size 120,07  Pixel Of oPanel1 When .f.

         @ 25,007 Say STR0029      Size 40,07 Pixel of oPanel1 //"Pais"
         @ 25,100 Say STR0030 Size 35,07 Pixel of oPanel1 //"Desc.Pais"

         @ 25,35  MSGET cCliCodPais Size 040,07 Pixel Of oPanel1 When .f.
         @ 25,140 MSGET cCliDscPais Size 120,07 Pixel Of oPanel1 When .f.

         aPos := PosDlgDown(oDlg)
         
         aCposBrowse := AddCpoUser(aCposBrowse,"EEQ","2")

         oMark := MsSelect():New("Work_Adia","WK_FLAG",,aCposBrowse,@lInverte,@cMarca,aPos,,,oPanel2)
         oMark :bAval := {|| If(Empty(Work_Adia->WK_FLAG),AE100Mark(oMark,,,aAdRestricao),AE100Mark(oMark,.f.,,aAdRestricao))}

         //Posicionamento dos Paineis
         oMark:oBrowse:align:= CONTROL_ALIGN_ALLCLIENT
         oPanel1:Align:= CONTROL_ALIGN_TOP
         oPanel2:Align:= CONTROL_ALIGN_ALLCLIENT

         oMarkAdd := oMark //DFS - 18/04/12 - Objeto é sempre copiado por referência, ficando disponível para o ponto de entrada
         IF EasyEntryPoint("EECAE105")
            ExecBlock("EECAE105",.F.,.F.,{"MSDIALOG_ADD_ADTO",oMark})
         Endif

      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED
   EndIf

   If nOpcao = 1
      Work_Adia->(DbGoTop())
      Work_Pgto->(DbSetOrder(2))

      Do While Work_Adia->(!Eof())
         If !Empty(Work_Adia->WK_FLAG)
            /*
            If !Work_Pgto->(DbSeek(If(Empty(Work_Adia->EEQ_FAOR),"C","P")+Work_Adia->EEQ_PREEMB+Work_Adia->EEQ_PARC))
            */
            // by CAF 08/01/2005 - Chave de pesquisa
            If !Work_Pgto->(DbSeek(Work_Adia->EEQ_FASE+Work_Adia->EEQ_PREEMB+Work_Adia->EEQ_PARC)) .and. lCallEmb
               Work_Pgto->(DbAppend())
               AvReplace("Work_Adia","Work_Pgto")
               Work_Pgto->EEQ_PREEMB := EEC->EEC_PREEMB
               Work_Pgto->EEQ_PARC   := ""
               Work_Pgto->EEQ_PARC   := AE100CalcParc()
               Work_Pgto->EEQ_FASE   := "E"
               Work_Pgto->EEQ_TIPO   := "A"
               Work_Pgto->EEQ_VL     := Work_Adia->WK_VLADI
               Work_Pgto->EEQ_SALDO  := Work_Adia->WK_VLADI
               Work_Pgto->EEQ_PROR   := Work_Adia->EEQ_PREEMB
               Work_Pgto->EEQ_EQVL   := Work_Adia->(WK_VLADI*EEQ_TX) // By JPP - 06/03/2006 - 10:25

               If Empty(Work_Adia->EEQ_FAOR)
                  If Work_Adia->EEQ_FASE == "P"
                     Work_Pgto->EEQ_FAOR := "P"
                  Else
                     Work_Pgto->EEQ_FAOR := "C"
                  EndIf
               Else
                  /////////////////////////////////////////////////////////
                  //ER - 19/08/2008                                      //
                  //Verifica se o adiantamento foi gerado automaticamente//
                  //por título do EFF.                                   //
                  /////////////////////////////////////////////////////////
                  If Work_Pgto->EEQ_FAOR == "F"
                     If Work_Adia->EEQ_FASE == "P"
                        Work_Pgto->EEQ_FAOR := "P"
                     Else
                        Work_Pgto->EEQ_FAOR := "C"
                     EndIf
                  Else
                     Work_Pgto->EEQ_FAOR := "P"
                  EndIf
               EndIf

               Work_Pgto->EEQ_PAOR   := Work_Adia->EEQ_PARC
               Work_Pgto->WK_STATUS  := STR0007+If(Work_Adia->EEQ_FASE="P",; //"Vinculado/"
                                        STR0008+AllTrim(Work_Adia->EEQ_PREEMB),STR0009) //"Processo: "###"Cliente"
               Work_Pgto->RECNO      := 0

               //RMD - Integração com o SIGAFIN
               Work_Pgto->EEQ_FINNUM := Work_Adia->EEQ_FINNUM

            Else
               If lCallEmb
                  If Work_Pgto->EEQ_VL <> Work_Adia->WK_VLADI
                     Work_Pgto->(RecLock("Work_Pgto",.f.))
                     Work_Pgto->EEQ_VL    := Work_Adia->WK_VLADI
                     Work_Pgto->EEQ_SALDO := Work_Adia->WK_VLADI
                     Work_Pgto->EEQ_EQVL  := Work_Adia->(WK_VLADI*EEQ_TX) // By JPP - 06/03/2006 - 10:25
                  EndIf
               Else
                  nRecPgto := Work_Pgto->(RecNo())
                  lAchou   := .F.
                  If Work_Pgto->(DbSeek(Work_Adia->EEQ_FASE+Work_Adia->EEQ_PREEMB+Work_Adia->EEQ_PARC))
                     While Work_Pgto->(!EOF()) .and. Work_Pgto->(EEQ_FAOR+EEQ_PROR+EEQ_PAOR) == Work_Adia->EEQ_FASE+Work_Adia->EEQ_PREEMB+Work_Adia->EEQ_PARC
                        If Work_Pgto->WK_PREPOS == POS
                           lAchou := .T.
                           Exit
                        EndIf
                        Work_Pgto->(DbSkip())
                     EndDo
                  EndIf

                  If !lAchou
                     Work_Pgto->(DbAppend())
                     AvReplace("Work_Adia","Work_Pgto")
                     Work_Pgto->EEQ_PREEMB := EEC->EEC_PREEMB
                     Work_Pgto->EEQ_PARC   := ""
                     Work_Pgto->EEQ_PARC   := AE100CalcParc()
                     Work_Pgto->EEQ_FASE   := "E"
                     Work_Pgto->EEQ_TIPO   := "A"
                     Work_Pgto->EEQ_VL     := Work_Adia->WK_VLADI
                     Work_Pgto->EEQ_SALDO  := Work_Adia->WK_VLADI
                     Work_Pgto->EEQ_PROR   := Work_Adia->EEQ_PREEMB
                     Work_Pgto->EEQ_EQVL   := Work_Adia->(WK_VLADI*EEQ_TX)
                     Work_Pgto->WK_PREPOS  := POS

                     If Empty(Work_Adia->EEQ_FAOR)
                        If Work_Adia->EEQ_FASE == "P"
                           Work_Pgto->EEQ_FAOR := "P"
                        Else
                           Work_Pgto->EEQ_FAOR := "C"
                        EndIf
                     Else
                        Work_Pgto->EEQ_FAOR := "P"
                     EndIf

                     Work_Pgto->EEQ_PAOR   := Work_Adia->EEQ_PARC
                     Work_Pgto->WK_STATUS  := STR0007+If(Work_Adia->EEQ_FASE="P",; //"Vinculado/"
                                              STR0008+AllTrim(Work_Adia->EEQ_PREEMB),STR0009) //"Processo: "###"Cliente"

                     Work_Pgto->RECNO      := 0
                  EndIf

                  Work_Pgto->(DbGoTo(nRecPgto))

               EndIf
            EndIf
         Else

            /*
            If Work_Pgto->(DbSeek(If(Empty(Work_Adia->EEQ_FAOR),"C","P")+;
                                            Work_Adia->EEQ_PREEMB+Work_Adia->EEQ_PARC))
            */
            // by CAF 08/01/2005 - Alteração na chave de pesquisa.
            If lCallEmb
               If Work_Pgto->(DbSeek(Work_Adia->EEQ_FASE+Work_Adia->EEQ_PREEMB+Work_Adia->EEQ_PARC))
                  If Work_Pgto->RECNO != 0
                     aAdd(aDeletados,Work_Pgto->RECNO)
                  EndIf

                  Work_Pgto->(RecLock("Work_Pgto",.f.))
                  Work_Pgto->(DbDelete())
               EndIf
            Else
               nRecPgto := Work_Pgto->(RecNo())
               If Work_Pgto->(DbSeek(Work_Adia->EEQ_FASE+Work_Adia->EEQ_PREEMB+Work_Adia->EEQ_PARC))
                  While Work_Pgto->(!Eof()) .and. Work_Pgto->(EEQ_FAOR+EEQ_PROR+EEQ_PAOR) == Work_Adia->EEQ_FASE+Work_Adia->EEQ_PREEMB+Work_Adia->EEQ_PARC
                     If Work_Pgto->WK_PREPOS == POS
                        If Work_Pgto->RECNO != 0
                           aAdd(aDeletados,Work_Pgto->RECNO)
                        EndIf

                        Work_Pgto->(RecLock("Work_Pgto",.f.))
                        Work_Pgto->(DbDelete())
                     EndIf
                     Work_Pgto->(DbSkip())
                  EndDo
               EndIf
               Work_Pgto->(DbGoTo(nRecPgto))
            EndIf
         EndIf

         Work_Adia->(DbSkip())
      EndDo
      Work_Adia->(DbGoTop())
   Else //Se Cancelou (nOpcao = 0), restarua o backup da work
       AvZap("Work_Adia")
       Work_Adia->(TERestBackup(cBkWorkAdi))
       lLgxPenden := lBkLgxPend
       aAdRestricao:= AClone(aBkpAdRestricao)
   EndIf
   If Select(cBkWorkAdi) > 0
        (cBkWorkAdi)->(E_EraseArq(cBkWorkAdi))
   EndIf
   AE100TotAdian() // ** Atualiza o total dos adiantamentos do processo.
   If oMsSelect <> Nil
      oMsSelect:oBrowse:Refresh()
   EndIf
   If oGetTot <> Nil
      oGetTot:Refresh()
   EndIf

   Work_Pgto->(DbGoTop())

End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : AE100Mark(oMark,lMarcar)
Parametros  : oMark   => Objeto para Refresh.
              lMarcar => .t. - Marca item.
                         .f. - Desmarca item.
              nValAuto
              aAdRestricao: Recno dos adiantamentos desmarcados que já possuem vínculo com o processo
Retorno     : .T.
Objetivos   : Associar adiantamentos com base no importador e no(s) processo(s) do embarque.
Autor       : Jeferson Barros Jr.
Data/Hora   : 11/11/02 10:54.
Obs.        :
*/
*---------------------------------------------------------------*
Static Function AE100Mark(oMark,lMarcar,nValAuto, aAdRestricao)
*---------------------------------------------------------------*
Local nOpcao := 0, nQtdDisp:= 0, nQtdAss := 0
Local bOk:={|| If (lRet := AE100ValMark(nQtdDisp,nQtdAss),(nOpcao:=1,lLgxPenden:=.T.,If(Type("lAe100Auto") <> "L" .Or. !lAe100Auto, oDlg:End(), .T.)),Nil)}
Local bCancel := {|| oDlg:End()}
Local aOrd:=SaveOrd({"SA1","EEQ"})
Local cTitulo, cX
Local lRet:=.t.
Local oDlg
Local lRetPto
Local oPanel  // GFP - 20/08/2012
Local nAltu := 0
Local nAltuGrup := 0
Local nPos
Local lIntFin := IsIntEnable("001")//Verifica se a integração com o módulo SIGAFIN está ativa.

Default lMarcar := .t.
Default aAdRestricao:= {}

Begin Sequence

   If lMarcar

    //If Empty(Work_Adia->EEQ_PGT) SVG - CH: 076113
      If Empty(Work_Adia->EEQ_DTCE)//SVG - CH: 076113 - Permite vincular parcelas de adiantamento quando ja se tem crédito no exterior
         EasyHelp(STR0031+Replic(ENTER,2)+; //"Não é possível selecionar este adiantamento."
                 STR0015+ENTER+; //"Detalhes:"
                 STR0032,STR0033) //"O adiantamento selecionado não possue fechamento de câmbio."###"Atenção."
         Break
      EndIf

      If Empty(Work_Adia->EEQ_PGT) .AND. !EasyGParam("MV_AVG0180")
         EasyHelp(STR0031+Replic(ENTER,2)+; //"Não é possível selecionar este adiantamento."
                 STR0015+ENTER+; //"Detalhes:"
                 STR0171,STR0033) //"O adiantamento selecionado não possui Data de Liquidação do Contrato."###"Atenção."
         Break
      EndIf

      // JPM - 17/07/06 - Validação da associação do adiantamento.
      IF EasyEntryPoint("EECAE105")
         If ValType((lRetPto := ExecBlock("EECAE105",.F.,.F.,"VALID_ASSOCIA"))) = "L" .And. !lRetPto
            Break
         EndIf
      Endif

      //THTS - 04/04/2018
      If !lCallEmb .And. AvFlags("EEC_LOGIX") .And. lLgxPenden
         EasyHelp(STR0173,STR0033) //"Existe uma operação pendente. Faça a gravação antes de realizar uma nova operação."###"Atenção."
         Break
      EndIf

      /* Se foi desmarcado, não pode marcar até que a operação seja confirmada */
      If !lCallEmb .And. AScan(aAdRestricao, Work_Adia->RECNO) > 0
         EasyHelp("Este adiantamento foi desassociado da parcela de câmbio e só poderá ser remarcado após a gravação da operação.", "Aviso")
         Break
      EndIf

      SA1->(DbSetOrder(1))
      SA1->(DbSeek(xFilial("SA1")+EEC->EEC_IMPORT+EEC->EEC_IMLOJA))

      EXJ->(DbSetOrder(1))
      EXJ->(DbSeek(xFilial("EXJ")+SA1->A1_COD+SA1->A1_LOJA))

      cTitulo  := STR0034 //"Adiantamentos"
      nQtdDisp := Work_Adia->EEQ_SALDO

      If lIntFin
         nQtdAss := nQtdDisp
      EndIf

      // GFP - 20/08/2012 - Ajuste de posição das informações na tela, independente da versão.
      nAltu := 30
      nAltuGrup := 5.0
      
      If Type("lAE100Auto") == "L" .And. lAE100Auto
         If nValAuto <> Nil
            nQtdAss := nValAuto
         EndIf
         Eval(bOk)
      Else

         DEFINE MSDIALOG oDlg TITLE cTitulo FROM 13,15 TO nAltu /*23*/,65 /*47*/ OF oDlg //oMainWnd

            oPanel := TPanel():New(0,0, "", oDlg,, .T., ,,,0,0,,.T.)
            oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

            @ 0.5 /*1.1*/, 0.5 TO /*5.5*/ nAltuGrup, 24 LABEL STR0035+AllTrim(EXJ->EXJ_MOEDA) OF oPanel //oDlg //"Valores "

            @ 1.2 /*1.8*/, /*6.0*/ 5.5 SAY STR0036 OF oPanel /*oDlg*/ SIZE 35,9 //"Disponivel"
            @ 1.8 /*2.4*/, /*6.0*/ 5.5 MSGET nQtdDisp  SIZE 70,07  PICTURE AVSX3("EEQ_SALDO",AV_PICTURE) OF oPanel /*oDlg*/ WHEN .f. HASBUTTON

            @ 3.2 /*3.8*/, /*6.0*/ 5.5 SAY STR0037 OF oPanel /*oDlg*/ SIZE 35,9 //"Associar"
            @ 3.8 /*4.4*/, /*6.0*/ 5.5 MSGET nQtdAss SIZE 70,07 PICTURE AVSX3("EEQ_VL",AV_PICTURE) When EECFlags("ADIANTAMENTO_PARCIAL") OF oPanel HASBUTTON //oDlg

            @ 9.4 /*10.0*/, /*6.0*/ 5.5 MSGET cX SIZE 70,07 OF oPanel //oDlg

         ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED
      EndIf

      If nOpcao = 1
         Work_Adia->WK_FLAG   := cMarca
         Work_Adia->WK_VLADI  := nQtdAss // Valor Associado.
         Work_Adia->EEQ_SALDO := Work_Adia->EEQ_SALDO-nQtdAss // Abate o saldo do adiantamento.
         nRecMark := Work_Adia->RECNO

         /* Se o adiantamento acabou de ser marcado, então não precisa constar na lista de restrições.
            Será adicionado para, caso conste ao desamrcar, possa ser identificado como uma exceção. */
         AAdd(aAdRestricao, Work_Adia->RECNO)

         //Caso seja um adiantamento recebido no exterior e o parâmetro que permite associar o adiantamento sem liquidação/recebimento estiver desligado, não copia as informações de liquidação para possibilitar a liquidação em fase de embarque
         If (lCallEmb .Or. IsInCallstack("AF201ADIAN")) .And. Work_Adia->EEQ_MODAL == "2" .And. !EasyGParam("MV_AVG0180",,.F.)
            //Work_Adia->EEQ_EMISSA   := dDataBase
            Work_Adia->EEQ_PGT      := CToD("")
            Work_Adia->EEQ_SOL      := CToD("")
            Work_Adia->EEQ_DTNEGO   := CToD("")
            Work_Adia->EEQ_PARI     := 1
            Work_Adia->EEQ_TX       := 0
            Work_Adia->EEQ_NROP     := ""
            Work_Adia->EEQ_BANC     := ""
            Work_Adia->EEQ_AGEN     := ""
            Work_Adia->EEQ_NCON     := ""
            Work_Adia->EEQ_NOMEBC   := ""
            Work_Adia->EEQ_RFBC     := ""
         EndIf
      EndIf
   Else
      //THTS - 02/04/2018 - Caso a parcela de origem esteja liquidada, nao sera possivel excluir a compensacao
      If AvFlags("EEC_LOGIX") .And. Work_Adia->RECNO != nRecMark //Nao deixa desmarcar se nao for o registro que acabou de ser marcado.
        EasyHelp(STR0174,STR0019) //"Para realizar o estorno, utilize a opção 'Excluir'."###"Atenção"
        lRet := .F.
      EndIf
      If lRet
        Work_Adia->WK_FLAG   := ""
        Work_Adia->EEQ_SALDO := Work_Adia->EEQ_SALDO+Work_Adia->WK_VLADI // Atualiza o saldo do adiantamento.
        Work_Adia->WK_VLADI  := 0
        nRecMark := 0
        lLgxPenden := .F.

        /* Caso conste na lista de restrições é porque foi marcado na operação corrente. Neste caso, não precisa ser mantido como restrição, quando desmarcado,
           possibilitando ser marcado em outra operação.
           Caso não conste, será adicionado, impedindo que esta parcela seja selecionada até que o processo seja gravado. */
         If (nPos:= AScan(aAdRestricao, Work_Adia->RECNO)) > 0
            ADel(aAdRestricao, nPos)
         Else
            AAdd(aAdRestricao, Work_Adia->RECNO)
         EndIf

      EndIf
   EndIf

End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : AE100ValMark(nQtdDisp,nQtdAss).
Parametros  : nQtdDisp   => Quantidade disponível de adiantamento para associação.
              nQtdAss    => Quantidade a ser associada, informada pelo usuário.
Retorno     : .t./.f.
Objetivos   : Validar a associação de adiantamentos.
Autor       : Jeferson Barros Jr.
Data/Hora   : 11/11/02 10:56.
Obs.        :
*/
*--------------------------------------------*
Static Function AE100ValMark(nQtdDisp,nQtdAss)
*--------------------------------------------*
Local lRet:=.t., nTotMark:=0, nRec := Work_Adia->(RecNo()), nTotal:= nTotAdia
Local nRecPgto:= Work_Pgto->(RecNo()), nOldVinc := 0
Local aOrd:=SaveOrd("Work_Pgto")
Local nVlUltParc
Private cWORKEEQ, cWORKEEQ2, cWORKEEQ5, cWORKEEQ6
Private aDiscount := {{"603","101"}}  // Adiantamento Pós Embarque

Begin Sequence

   If nQtdAss <= 0
      EasyHelp(STR0038,STR0039) //"Valor a ser associado inválido."###"Aviso"
      lRet:=.f.
      Break
   EndIf

   If nQtdAss > nQtdDisp
      EasyHelp(STR0040,STR0039) //"Valor a ser associado maior que o valor disponível de adiantamento!"###"Aviso"
      lRet:=.f.
      Break
   EndIf

   //Adiantamento Pós Embarque

   If !lCallEmb

      //Valida a presença de Adiantamento Pré-Embarque
      M->EEQ_EVENT  := "603"
      M->EEQ_MOEDA  := EEC->EEC_MOEDA//EXJ->EXJ_MOEDA RMD - 15/06/18 - Deve validar contra a moeda do emabarque, e não do cliente. É possível incluir adiantamentos na moeda do processo.

      EEQ->(DbSetOrder(7))
      If EEQ->(DbSeek(xFilial("EEQ")+Work_Adia->EEQ_FASE+Work_Adia->EEQ_PREEMB+Work_Adia->EEQ_PARC))
         While EEQ->(!EOF()) .and. EEQ->(EEQ_FILIAL + EEQ_FAOR + EEQ_PROR + EEQ_PAOR) == xFilial("EEQ")+Work_Adia->EEQ_FASE+Work_Adia->EEQ_PREEMB+Work_Adia->EEQ_PARC
            If EEQ->EEQ_EVENT == "603"
               nOldVinc := EEQ->EEQ_VL
               Exit
            EndIf
            EEQ->(DbSkip())
         EndDo
      EndIf

      If nOldVinc < nQtdAss
         M->EEQ_VL := nQtdAss - nOldVinc
      Else
         M->EEQ_VL := nQtdAss
      EndIf

      If EECFlags("FRESEGCOM")

         //Gera work TMP para ser utilizado pelas funções Af201DelDiscount() e Af201AddDiscount().
         AF201GrvTMP()

         //Valida a inclusão de Desconto.
         If !AF201VldDiscount()
            lRet := .F.
         EndIf

         If AvFlags("EEC_LOGIX")
            nVlUltParc := VlUltiParc()
            If nVlUltParc > 0 .And. nQtdAss > nVlUltParc
                MsgInfo(STR0175 + Replic(ENTER,2) + ;//"Valor a ser associado maior que o valor da parcela de câmbio que será associada!"
                        STR0022+": " + Transf(nVlUltParc,AVSX3("EEQ_VL",AV_PICTURE)),STR0039) //"Parcela"###"Aviso"
                lRet:=.F.
            EndIf
         EndIf

         //Grava arquivo TMP no EEQ
         AF201GrvEEQ()

         //Seta a tabela ativa
         DbSelectArea("Work_Adia")

      EndIf

      If !lRet
         Break
      EndIf

   EndIf

   Work_Adia->(DbGoTop())
   Do While Work_Adia->(!Eof())
      If !Empty(Work_Adia->WK_FLAG)
         Work_Pgto->(DbSetOrder(2))
         If !Work_Pgto->(DbSeek(Work_Adia->EEQ_FASE+Work_Adia->EEQ_PREEMB+Work_Adia->EEQ_PARC))
            nTotMark += Work_Adia->WK_VLADI
         EndIf
      EndIf

      Work_Adia->(DbSkip())
   EndDo

   Work_Adia->(DbGoTo(nRec))

   Work_Pgto->(DbSetOrder(2))
   If Work_Pgto->(DbSeek(Work_Adia->EEQ_FASE+Work_Adia->EEQ_PREEMB+Work_Adia->EEQ_PARC))
      nTotal -= Work_Pgto->EEQ_VL
   EndIf

   Work_Pgto->(DbGoTo(nRecPgto))

   If (nQtdAss+nTotMark+nTotal+nTotReceb) > EEC->EEC_TOTPED
      EasyHelp(STR0041+Replic(ENTER,2)+; //"Associação de adiantamento inválida."
              STR0015+ENTER+; //"Detalhes:"
              STR0042+ENTER+; //"Com o valor informado, o total de adiantamento(s) ultrapassa "
              STR0043,STR0039) //"o total disponível no processo."###"Aviso"
      lRet:=.f.
      Break
   EndIf

End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : AE100TotAdian().
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Atualizar o total de adiantamentos.
Autor       : Jeferson Barros Jr.
Data/Hora   : 11/11/02 10:25.
Obs.        :
*/
*-----------------------------*
Static Function AE100TotAdian()
*-----------------------------*
Local lRet:= .t., nRec := Work_Pgto->(RecNo())

Begin Sequence

   nTotAdia := 0
   Work_Pgto->(DbGoTop())

   Do While Work_Pgto->(!Eof())
      nTotAdia += Work_Pgto->EEQ_VL
      Work_Pgto->(DbSkip())
   EndDo

End Sequence

Work_Pgto->(DbGoTo(nRec))

Return lRet

/*
Funcao      : AE100CalcParc().
Parametros  : Nenhum.
Retorno     : nParc => Nro da proxima parcela.
Objetivos   : Calcular próximo nro da parcela.
Autor       : Jeferson Barros Jr.
Data/Hora   : 11/11/02 10:51.
Obs.        :
*/
*-----------------------------*
Static Function AE100CalcParc()
*-----------------------------*
Local cParc:="01", nRec:=Work_Pgto->(RecNo()), nRecEEQ := 0
Local aParc:={}, cParcEEQ := "01"

Begin Sequence

   //Verifica qual a maior parcela da Work_Pgto
   Work_Pgto->(DbGoTop())
   Do While Work_Pgto->(!Eof())
      aAdd(aParc,Work_Pgto->EEQ_PARC)
      Work_Pgto->(DbSkip())
   EndDo

   If Len(aParc) > 0
      aSort(aParc,,,{|x,y| x > y })

      //cParc := StrZero(aParc[1]+1,2,0)
      cParc := SomaIt(aParc[1])
   EndIf

   If !lCallEmb
      aParc     := {}
      nRecEEQ   := EEQ->(RecNo())

      //Verifica qual a maior parcela do EEQ
      EEQ->(DbSetOrder(1))
      If EEQ->(DbSeek(xFilial("EEQ")+EEC->EEC_PREEMB))
         While EEQ->(!EOF()) .and. EEQ->(EEQ_FILIAL + EEQ_PREEMB) == xFilial("EEQ")+EEC->EEC_PREEMB
            If EEQ->EEQ_FASE == "E"
               //aAdd(aParc,Val(EEQ->EEQ_PARC))
               aAdd(aParc,EEQ->EEQ_PARC)
            EndIf
            EEQ->(DbSkip())
         EndDo
      EndIf

      EEQ->(DbGoTo(nRecEEQ))

      If Len(aParc) > 0
         aSort(aParc,,,{|x,y| x > y })
         //cParcEEQ := StrZero(aParc[1]+1,2,0)
         cParcEEQ := SomaIt(aParc[1])
      EndIf

      //Verifica qual é a maior parcela.
      If Val(cParcEEQ) > Val(cParc)
         cParc := cParcEEQ
      EndIf

   EndIf

End Sequence

Work_Pgto->(DbGoTo(nRec))

Return cParc

/*
Funcao      : AE100AdiMan(nTipo)
Parametros  : nTipo  := VIS_DET, EXC_DET
              oMsSelect := Objeto para refresh.
              aAdRestricao: Recno dos adiantamentos excluídos que já possuem vínculo com o processo
Retorno     : .T.
Objetivos   : Manutencao de adiantamentos. - (Pagamentos Antecipados)
Autor       : Jeferson Barros Jr.
Data/Hora   : 11/11/02 16:16.
Obs.        :
*/
*----------------------------------------------------------------------------*
Static Function AE100AdiMan(nTipo,oMsSelect,oGetTot,aVincAuto, aAdRestricao)
*----------------------------------------------------------------------------*
Local bOk:={|| nOpcao:=1, If(AE100ValAdian(nTipo,nReg,aAdRestricao),(lLgxPenden:=.T.,If(IsMemVar("lAe100Auto") .And. lAe100Auto, ,oDlg:End())),nOpcao:=0)}, bCancel:={|| oDlg:End()}
Local aEnchoice := {}, aPos := {},oMsmGet1
Local cTit := STR0044 //"Manutenção de Adiantamentos."
Local nOpcao := 0, nReg, i:=0
Local lRet := .t.
Local aOrd := SaveOrd("EEQ")
Private aTela:={}, aGets:={}
Private lEmbarcado := .F. // By JPP - 12/10/2006 - 10:00 - .F. - Informa que a manutenção de câmbio está sendo
                          // realizada sem a realização de um embarque. É o caso dos adiantamentos. Variável utilizada na validação do câmbio AF200Valid()

Default aAdRestricao:= {}

Begin Sequence

   IF nTipo != INC_DET .And. Work_Pgto->(Eof()) .AND. Work_Pgto->(Bof())
      HELP(" ",1,"AVG0000632") // Não existem registros para a manutenção !
      Break
   EndIf

   If !lCallEmb
      If nTipo <> VIS_DET
         If Work_Pgto->WK_PREPOS == PRE
            EasyHelp(STR0151,STR0019)//"Esse adiantamento foi vinculado na Fase de Pré-Embarque e não pode ser alterado após a digitação da Data de Embarque"###"Atenção"
            lRet := .F.
            Break
         EndIf
      EndIf
   EndIf

   //THTS - 02/04/2018 - Caso a parcela de origem esteja liquidada, nao sera possivel excluir a compensacao
   If nTipo == EXC_DET .And. AvFlags("EEC_LOGIX") .And. ParcOrigBx(Work_Pgto->EEQ_PREEMB, Work_Pgto->EEQ_FINNUM, Work_Pgto->RECNO,Work_Pgto->EEQ_SEQBX) //Verifica se a parcela de Origem esta liquidada. Se Sim, nao prossegue com o estorno da compensacao (necessarios estornar a liquidacao primeiro)
        EasyHelp(STR0172,STR0019)//'Existem parcelas baixadas posteriormente a esta! É necessário estornar estas baixas para estornar a baixa da parcela atual'###"Atenção"
        lRet := .F.
        Break
   EndIf

   //Valida as operações sobre os adiantamentos recebidos no exterior para liquidação em fase de embarque
   If !EasyGParam("MV_AVG0180",,.F.) .And. nTipo == EXC_DET .And. Work_Pgto->EEQ_MODAL = "2" .And. !Empty(Work_Pgto->EEQ_PGT) .And. !Empty(Work_Pgto->EEQ_NROPAG)
      EasyHelp("Parcela liquidada em fase de embarque. Estorne a liquidação na rotina de câmbio do embarque para possibilitar que o adiantamento seja desassociado.", "Aviso")
      lRet := .F.
      Break
   EndIf
   If !EasyGParam("MV_AVG0180",,.F.) .And. nTipo == EXC_DET .And. Work_Pgto->EEQ_MODAL = "2" .And. Work_Pgto->EEQ_EVENT != "603"
      EEQ->(DbSetorder(3))
      If !Empty(Work_Pgto->EEQ_ORIGEM)
         EasyHelp("Esta parcela é o resultado de uma divisão de parcelas no câmbio de embarque e não pode ser excluida na rotina de adiantamentos. Exclua a parcela na rotina de câmbio do embarque para que os valores sejam restaurados corretamente na parcela original.", "Aviso")
         lRet := .F.
         Break
      ElseIf EEQ->(DbSeek(xFilial()+Work_Pgto->(EEQ_PREEMB+EEQ_PARC)))
         EasyHelp("Esta parcela foi alterada em fase de embarque e possui parcelas residuais. Cancele as parcelas residuais na rotina de câmbio de embarque para possibilitar que o adiantamento seja desassociado.", "Aviso")
         lRet := .F.
         Break
      EndIf
   EndIf

   If !lCallEmb .And. nTipo == EXC_DET .And. AvFlags("EEC_LOGIX") .And. lLgxPenden //THTS - 04/04/2018
        EasyHelp(STR0173,STR0019)//"Existe uma operação pendente. Faça a gravação antes de realizar uma nova operação."###"Atenção"
        lRet := .F.
        Break
   EndIf

   // ** Campos da enchoice.
   aEnchoice:={"EEQ_VL"   ,"EEQ_NROP","EEQ_PGT"   ,"EEQ_TX"  ,"EEQ_BANC"  ,"EEQ_AGEN"  ,;
               "EEQ_NCON" ,"EEQ_NOME","EEQ_NOMEBC","EEQ_CORR","EEQ_EQVL"  ,"EEQ_VLCORR",;
               "EEQ_DECAM","EEQ_RFBC","EEQ_DTCE"  ,"EEQ_NRINVO","EEQ_OBS" ,"EEQ_SOL"   ,"EEQ_DTNEGO"}

   // ** Variaveis para evitar erros nos gatilhos.
   M->EEC_NRINVO := ""
   M->EEQ_VM_REC := 0
   M->EEQ_IMPORT := ""

   For i := 1 TO Work_Pgto->(FCount())
      M->&(Work_Pgto->(FieldName(i))) := Work_Pgto->(FieldGet(i))
   Next

   // ** CCH - 01/08/2008 - Tratamento para criação de campos Virtuais
   SX3->(DbSetOrder(1))
   SX3->(DbSeek("EEQ"))
   While SX3->(!Eof() .And. SX3->X3_ARQUIVO == "EEQ")
      If SX3->X3_CONTEXT == "V" .Or. SX3->X3_PROPRI == "U"
         If Work_Pgto->(FieldPos(SX3->X3_CAMPO)) > 0
            M->&(SX3->X3_CAMPO) := Work_Pgto->&(SX3->X3_CAMPO)
         Else
            M->&(SX3->X3_CAMPO) := CriaVar(SX3->X3_CAMPO)
         EndIf
      EndIf
      SX3->(DbSkip())
   EndDo
   // **

   nReg := Work_Pgto->(RecNo())

   If !IsMemVar("lAe100Auto") .Or. !lAe100Auto

      DEFINE MSDIALOG oDlg TITLE cTit FROM 9,0 TO 35,80 OF oMainWnd
         aPos := PosDlg(oDlg)
         //WFS - 01/10/12
         oMsmGet1:= MsmGet():New("EEQ",,IF(nTipo=INC_DET,3,4),,,,aEnchoice,aPos,IF(Str(nTipo,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1),{},),3) //wfs
         oMsmGet1:oBox:Align:= CONTROL_ALIGN_ALLCLIENT
      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED
   Else
      Eval(bOk)
   EndIf

   If nOpcao = 1 .And. nTipo <> VIS_DET
      AE100TotAdian() // ** Atualiza o total dos adiantamentos do processo.
      If !IsMemVar("lAe100Auto") .Or. !lAe100Auto
         oMsSelect:oBrowse:Refresh()
         oGetTot:Refresh()
      EndIf
   EndIf

End Sequence

RestOrd(aOrd)
Return lRet

/*
Funcao      : AE100ValAdian(nTipo,nReg).
Parametros  : nTipo => Opcao
              nReg  => Nro. Registro.
              aAdRestricao: Recno dos adiantamentos excluídos que já possuem vínculo com o processo
Retorno     : .t./.f.
Objetivos   : Efetuar validação para a exclusao.
Autor       : Jeferson Barros Jr.
Data/Hora   : 11/11/02 11:53.
Obs.        :
*/
*---------------------------------------*
Static Function AE100ValAdian(nTipo,nReg,aAdRestricao)
*---------------------------------------*
Local lRet:=.t.
Local aOrd := EEQ->({IndexOrd(),RecNo()})
Local cFil, i, aFil := {}
Local lSeekEEQ := .F.
Default aAdRestricao:= {}

Begin Sequence

   If nTipo == EXC_DET

      If (IsMemVar("lAe100Auto") .And. lAe100Auto) .Or. MsgYesNo(STR0045,STR0039) //"Confirma exclusão do Registro Atual ?"###"Aviso"

         Work_Pgto->(DbGoTo(nReg))

         If Work_Pgto->RECNO != 0
            aAdd(aDeletados,Work_Pgto->RECNO)
         EndIf

         If !Empty(Work_Pgto->EEQ_FAOR)
            If !Work_Adia->(DbSeek(Work_Pgto->EEQ_FAOR+Work_Pgto->EEQ_PROR+Work_Pgto->EEQ_PAOR))
               
               //NCF - 22/08/2017 - Inserido tratamento para Adiantamentos em outras filiais 
               cFil := xFilial("EEQ")
               If Empty(cFil)
                  aAdd(aFil,cFil)
               Else
                  aFil := AvgSelectFil(.F.)
               EndIf
               
               EEQ->(dbSetOrder(6))
               For i := 1 To Len(aFil)
                  If EEQ->(dbSeek(aFil[i]+Work_Pgto->EEQ_FAOR+Work_Pgto->EEQ_PROR+Work_Pgto->EEQ_PAOR))// .And. Work_Pgto->EEQ_FINNUM ==  EEQ->EEQ_FINNUM RMD - 19/03/18 - A parcela é única neste cenário, não é necessário verificar o número do título (que não será igual na associação pós-embarque - lá a referência é para o título NF)
                     lSeekEEQ := .T.
                     EXIT
                  EndIf
               Next i
               
               If !lSeekEEQ
                  EasyHelp(STR0176)//"Não foi possível localizar a origem do adiantamento a ser estornado."
                  lRet := .F.
                  Break
               EndIf
               /*               
               EEQ->(dbSetOrder(6))
               If !EEQ->(dbSeek(xFilial()+Work_Pgto->EEQ_FAOR+Work_Pgto->EEQ_PROR+Work_Pgto->EEQ_PAOR))
                  EasyHelp("Não foi possível localizar a origem do adiantamento a ser estornado.")
                  lRet := .F.
                  Break
               EndIf
               */
               Work_Adia->(DbAppend())
               AvReplace("EEQ","Work_Adia")
               Work_Adia->RECNO := EEQ->(RecNo())
            EndIf

            Work_Adia->(RecLock("Work_Adia",.f.))
            Work_Adia->WK_FLAG   := ""
            Work_Adia->EEQ_SALDO += Work_Pgto->EEQ_VL
            Work_Adia->WK_VLADI  := 0
            Work_Adia->(MsUnLock())

            /* Caso conste na lista de restrições é porque foi marcado na operação corrente. Neste caso, não precisa ser mantido como restrição, quando excluído,
               possibilitando ser marcado em outra operação.
               Caso não conste, será adicionado, impedindo que esta parcela seja selecionada até que o processo seja gravado. */
            If (nPos:= AScan(aAdRestricao, Work_Adia->RECNO)) > 0
               ADel(aAdRestricao, nPos)
            Else
               AAdd(aAdRestricao, Work_Adia->RECNO)
            EndIf

         EndIf

         Work_Pgto->(DbDelete())
         Work_Pgto->(DbGoTop())
      Else
         lRet := .F.
         Break
      EndIf
   EndIf

End Sequence

EEQ->(dbSetOrder(aOrd[1]),dbGoTo(aOrd[2]))

Return lRet

/*
Funcao      : AE100RecAdian().
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Gravar Adiantamentos.
Autor       : Jeferson Barros Jr.
Data/Hora   : 11/11/2002 - 11:35.
Revisao     :
Obs.        :
*/
*-----------------------------*
STATIC Function AE100RecAdian(cMsgErro)
*-----------------------------*
Local lRet := .t., /*i:=0,*/ aOrd:=SaveOrd("EEQ")
Local lRestaura := .F., lEstorno:= .T.
Local nSaldoOld := 0 , nSaldoAtu := 0
Local aParc101 := {},i, nRecEEQ//RMD - 05/10/17
Local cEEQTpTit:= Posicione("EC6",1,xFilial("EC6") + AvKey("EXPORT","EC6_TPMODU") + AvKey("101","EC6_ID_CAM"),"EC6_TPTIT")
Private cWORKEEQ, cWORKEEQ2, cWORKEEQ5, cWORKEEQ6
Private aDiscount := {{"603","101"}}  // Adiantamento Pós Embarque
Private cSeek:= 'SE1->(DbSeek(xFilial()+"EEC"+AvKey(EEQ->EEQ_FINNUM, "E1_NUM")+AvKey(" ", "E1_PARCELA")+AvKey(TETpTitEEQ("EEQ"),"E1_TIPO")))'   //NCF - 04/07/2019
Private nParcEst:= 0 //utilizada pelo sigafin

Begin Sequence

   ProcRegua(Work_Pgto->(LastRec())+1+Work_Adia->(LastRec())+1)
   IncProc(STR0046) //"Atualizando arquivos ..."

   lRet := aDelRecno(lEstorno)// FSY - 29/07/2013 - Função do Laço For para deletar RecNo contido no velor aDeletados {}. Manter a estrutura antiga.
   // FSY - 29/07/2013 - Movido para a função Static Function aDelRecno()
   /*
   For i:=1 To Len(aDeletados)
      IncProc()
      EEQ->(DbGoTo(aDeletados[i]))

      If !lCallEmb

         DbSelectArea("EEQ")

         AF201GrvTMP()

         TMP->(DbGoTop())
         While TMP->(!EOF())
            If TMP->TMP_RECNO == aDeletados[i]
               If TMP->EEQ_EVENT == "603"
                  Af201DelDiscount()
                  Exit
               EndIf
            EndIf
            TMP->(DbSkip())
         EndDo

         lRet:= AF201GrvEEQ(lEstorno)

         EEQ->(DbGoTo(aDeletados[i]))

      EndIf


      //Verifica se é um adiantamento pós-embarque e se possui integração com o módulo sigafin.
      //Caso positivo, estorna a baixa do título antes de realizar a exclusão na EEQ, caso esteja com a data de liquidação preenchida.
      If EEQ->EEQ_EVENT == "603" .And. !Empty(EEQ->EEQ_PGT) .And. IsIntEnable("001")
         If (&cSeek) .And. AF201PosicSE5("SE1", EEQ->EEQ_PGT, EEQ->EEQ_EQVL)
            //Estorno do título de adiantamento no SigaFin
            If !AvStAction("009")
               lRet:= .F.
            EndIf
         EndIf
      EndIf

      EEQ->(RecLock("EEQ",.f.))
      EEQ->(DbDelete())
      EEQ->(MSUnlock())
   Next
   */
   Work_Pgto->(dbGoTop())

   Do While Work_Pgto->(!Eof())
      IncProc()

      If !lCallEmb

         lRestaura := .F.

         //Valida a presença de Adiantamentos Pré-Embarque.
         If Work_Pgto->WK_PREPOS == PRE
            Work_Pgto->(DbSkip())
            Loop
          EndIf
      EndIf

      If Work_Pgto->RECNO == 0
         EEQ->(RecLock("EEQ",.t.))
         EEQ->EEQ_FILIAL := xFilial("EEQ")
         AvReplace("Work_Pgto","EEQ")
         EEQ->EEQ_EVENT := If(lCallEmb,"101","603")
         EEQ->EEQ_VCT   := dDataBase
         //LGS-22/05/2015 - Sempre deve deixar em branco independente da integração se integrado com o Logix.
         If AVFLAGS("EEC_LOGIX") .OR. lCallEmb .AND. EasyGParam("MV_EEC0042",,.F.)    //NCF - 12/05/2014 - Manter gravação em caso de Integ. Logix
           EEQ->EEQ_NR_CON:= ""
		   EEQ->EEQ_FINNUM:= ""
         ElseIf !lCallEmb .AND. EasyGParam("MV_EEC0042",,.F.)
           EEQ->EEQ_NR_CON:= ""
		   EEQ->EEQ_FINNUM:= ""
         EndIf
         nRecEEQ := EEQ->(Recno()) //RMD - 05/10/17
      Else
         EEQ->(dbGoTo(Work_Pgto->RECNO))
         nRecEEQ := Work_Pgto->RECNO //RMD - 05/10/17
         nSaldoOld := EEQ->EEQ_VL
         nSaldoAtu := Work_Pgto->EEQ_VL
         nEEQSaldo := EEQ->EEQ_SALDO //RMD - 12/03/18 - Guarda o saldo para atualização posterior, evitando que a rotina desvie a atualização por falta de saldo
         EEQ->(RecLock("EEQ",.f.))
         AvReplace("Work_Pgto","EEQ")
         EEQ->EEQ_EVENT := If(lCallEmb,"101","603")
         EEQ->EEQ_NR_CON:= ""
         EEQ->EEQ_SALDO := nEEQSaldo//RMD - 12/03/18 - Guarda o saldo para atualização posterior, evitando que a rotina desvie a atualização por falta de saldo
         lRestaura := .T.
      EndIf

      /* Para a rotina com os tratamentos de frete/seguro/comissão os campos abaixo
         devem ser alimentados. */
      If EECFlags("FRESEGCOM")
         EEQ->EEQ_MOEDA  := EEC->EEC_MOEDA
         EEQ->EEQ_IMPORT := EEC->EEC_IMPORT
         EEQ->EEQ_IMLOJA := EEC->EEC_IMLOJA
      EndIf

      // JPM - 20/02/06 - pto entrada na gravação da vinculação de adiantamento.
      IF EasyEntryPoint("EECAE105")
         ExecBlock("EECAE105",.F.,.F.,"GRV_ADIAN")
      Endif

      If AVFLAGS("EEC_LOGIX") //THTS - 14/04/2018 - Atualiza o Tipo do Titulo para integracao Logix
         EEQ->EEQ_TPTIT := cEEQTpTit
      EndIf

      EEQ->(MsUnLock())

      If Work_Pgto->EEQ_EVENT == "603" .And. Work_Pgto->RECNO <> 0 .And. nSaldoOld == nSaldoAtu //RMD - 05/10/17 - Verifica se o adiantamento sofreu alteração antes de continuar
         Work_Pgto->(DbSkip())
         Loop
      EndIf

    If !lCallEmb

        M->EEQ_EVENT  := EEQ->EEQ_EVENT
        M->EEQ_MOEDA  := EEQ->EEQ_MOEDA
        M->EEQ_VL     := EEQ->EEQ_VL

        //Gera work TMP para ser utilizado pelas funções Af201DelDiscount() e Af201AddDiscount().
        AF201GrvTMP()

        If EECFlags("FRESEGCOM")

            //Na alteração de saldo, o valor anterior é restaurado antes de adicionar o novo saldo.

            If lRestaura
                //Posiciona no TMP o mesmo registro do Work_Pgto
                TMP->(DbGoTop())
                While TMP->(!EOF())
                    If TMP->TMP_RECNO == Work_Pgto->RECNO
                        Exit
                    EndIf
                    TMP->(DbSkip())
                EndDo

                If TMP->EEQ_EVENT == "603"
                    TMP->EEQ_VL := nSaldoOld
                    Af201DelDiscount()
                    TMP->EEQ_VL := nSaldoAtu
                EndIf
            EndIf

            //Desconto das parcelas em aberto o valor do adiantamento.
            aParc101 := {}//RMD - 12/03/18 - Zera o array de cotrole para quando for associada mais de uma parcela ao mesmo tempo
            Af201AddDiscount("603",INC_DET,@aParc101)
				//THTS - 04/09/2019 - Quando estiver habilitada alteração de valores do embarque após a dt embarque, nao poderá compensar caso a parcela possua desconto
				If Len(aParc101) > 0 .And. aScan(aParc101,{|x| x[10] > 0}) > 0
					cMsgErro := STR0184 //"Não será possível realizar a associação do Adiantamento, pois a parcela de câmbio possui desconto."
					lRet := .F.
					Break
				EndIf
            //RMD - 05/10/17 - Efetua a quebra das parcelas de câmbio para compensação de adiantamento pós embarque
            For i := 1 To Len(aParc101)
                If i == 1
                    EEQ->(DbGoTo(nRecEEQ)) //Atualiza a parcela 603 com os dados da parcela que teve o valor abatido
                    EEQ->(RecLock("EEQ", .F.))
                Else
                    //Se mais de uma parcela tiver sido abatida, cria novo evento 603 para referencia-la
                    cNewParc := AE100CalcParc()
                    EEQ->(RecLock("EEQ",.t.))
                    EEQ->EEQ_FILIAL := xFilial("EEQ")
                    AvReplace("Work_Pgto","EEQ")
                    EEQ->EEQ_PARC  := cNewParc
                    EEQ->EEQ_EVENT := If(lCallEmb,"101","603")
                    If AVFLAGS("EEC_LOGIX") .OR. lCallEmb .AND. EasyGParam("MV_EEC0042",,.F.)//RMD - 26/03/18 - REVISAR PARA INTEGRAÇÃO DA COMPENSAÇÃO PÓS EMBARQUE COM LOGIX
                        EEQ->EEQ_NR_CON:= ""
                        EEQ->EEQ_TPTIT := cEEQTpTit
                    EndIf
                    TMP->(DBAPPEND())
                    AVREPLACE("EEQ","TMP")
                    TMP->TMP_RECNO := EEQ->(RecNo())
					TMP->(DBCOMMIT())
                EndIf
                //Referencia a parcela que teve o valor abatido
                EEQ->EEQ_PARVIN := aParc101[i][1]
                EEQ->EEQ_VL     := aParc101[i][2]
                EEQ->EEQ_FINNUM := aParc101[i][3]
                //RMD - 12/03/18 - Grava as informações da parcela de origem
                EEQ->EEQ_ORIGEM := aParc101[i][4]
                EEQ->EEQ_NRINVO := aParc101[i][5]
                EEQ->EEQ_EMISSA := aParc101[i][6]
                EEQ->EEQ_CGRAFI := aParc101[i][7]
                EEQ->EEQ_ADEDUZ := aParc101[i][8]
                EEQ->EEQ_AREMET := aParc101[i][9]
                EEQ->(MSUnlock())
            Next
        EndIf

        //Grava arquivo TMP no EEQ
        lRet:= AF201GrvEEQ()

    EndIf
    If !lRet //Se ocorreu erro de integracao, para o processamento
        Break
    EndIf
    Work_Pgto->(DbSkip())
   EndDo

   If lRet //THTS - 29/03/2018 - Nao continua a execucao quando ocorrer falha de integracao (Sera executado o Rollback)
        lRet := aDelRecno(lEstorno)//FSY - 29/07/2013 - Função do Laço For para deletar RecNo contido no velor aDeletados {}. Novamente para deletar evento 101 caso seja o valor do adiantamento em 100%.

        IF(EasyEntryPoint("EECAE105"),ExecBlock("EECAE105",.F.,.F.,"ANTES_DELETA"),)//AWR - 16/05/2006

        // ** Atualiza os adiantamentos vinculados do importador.
        EEQ->(DbSetOrder(6))

        Work_Adia->(DbGoTop())
        Do While Work_Adia->(!Eof())
            If EEQ->(DbSeek(Work_Adia->EEQ_FILIAL+Work_Adia->EEQ_FASE+Work_Adia->EEQ_PREEMB+Work_Adia->EEQ_PARC))  // GFP - 19/12/2013
                    EEQ->(RecLock("EEQ",.f.))
                    EEQ->EEQ_SALDO := Work_Adia->EEQ_SALDO
                    IF(EasyEntryPoint("EECAE105"),ExecBlock("EECAE105",.F.,.F.,"GRV_ADI_CLI_PO"),)//AWR - 25/05/2006
                    EEQ->(MSUnlock())
            EndIf
        Work_Adia->(DbSkip())
        EndDo
   EndIf

End Sequence

RestOrd(aOrd, .T.)

Return lRet

/*
Funcao      : aDelRecno()
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Permitir ao usuário informar dados do Siscomex e atualizar os itens do embarque.
Autor       : Fabio Satoru Yamamoto.
Data/Hora   : 29/07/2013 09:55.
*/
Static Function aDelRecno(lEstorno)
Local i
Local lRet := .T.
Local cFilTitParc, cFilAntBkp
Begin Sequence
   For i:=1 To Len(aDeletados)
        IncProc()
        EEQ->(DbGoTo(aDeletados[i]))

        If !lCallEmb

            DbSelectArea("EEQ")

            AF201GrvTMP()

            TMP->(DbGoTop())
            While TMP->(!EOF())
                If TMP->TMP_RECNO == aDeletados[i]
                    EEQ->(DbGoTo(aDeletados[i]))
                    If TMP->EEQ_EVENT == "603"
                        Af201DelDiscount()
                        Exit
                    EndIf
                EndIf
                TMP->(DbSkip())
            EndDo

            lRet:= AF201GrvEEQ(lEstorno)
            If !lRet
                Break
            EndIf
            EEQ->(DbGoTo(aDeletados[i]))

        EndIf

        //Verifica se é um adiantamento pós-embarque e se possui integração com o módulo sigafin.
        //Caso positivo, estorna a baixa do título antes de realizar a exclusão na EEQ, caso esteja com a data de liquidação preenchida.
        If EEQ->EEQ_EVENT == "603" .And. (!Empty(EEQ->EEQ_PGT) .Or. EasyVerModal("EEQ") .And. !Empty(EEQ->EEQ_DTCE)) .And. (IsIntEnable("001") .Or. IsIntEnable("010")) //THTS - 29/03/2018
            //RMD - 05/10/17 - Trata os cenários de compensação automática
            If !AvFlags("EEC_LOGIX") .And. !EasyGParam("MV_EEC0042",,.F.)
                cFilAntBkp := cFilAnt 
                //NCF - 22/08/2017 - Verificar primeiramente se o adiantamento possui origem em outra filial para setar o cFilAnt antes da integração
                If FWModeAccess("EEQ",3) == "E" .And. (cFilTitParc := AF201FOrPc( EEQ->EEQ_FAOR, EEQ->EEQ_PROR, EEQ->EEQ_PAOR, EEQ->EEQ_FINNUM )) <> cFilAnt 
                    cFilAnt := cFilTitParc
                EndIf 
                    
                If (&cSeek) .And. AF201PosicSE5("SE1", EEQ->EEQ_PGT, EEQ->EEQ_EQVL)
                    //Estorno de baixa do título de adiantamento no SigaFin
                    If !AvStAction("009")
                        lRet:= .F.
                        Break
                    EndIf
                EndIf
                cFilAnt := cFilAntBkp//RMD - 26/03/18 - Movido para dentro do "IF" onde a variável é atribuida, caso contrário irá gravar Nil na filial
            Else
                Processa({|| lRet := AF200ESTCR(EEQ->EEQ_PREEMB,.F.,{{EEQ->(EEQ_FAOR+EEQ_PROR+EEQ_PAOR),EEQ->(RECNO())}}) }, "Estornando a compensação automática do adiantamento")
                If !lRet
                    Break
                EndIf
            EndIf        
            //cFilAnt := cFilAntBkp - RMD - 26/03/18 - Movido para dentro do "IF" onde a variável é atribuida, caso contrário irá gravar Nil na filial
        EndIf

        EEQ->(DbGoTo(aDeletados[i]))
        if (!AvFlags("EEC_LOGIX") .and. !empty(EEC->EEC_DTEMBA) .AND. IsReceita(EEQ->EEQ_EVENT) .And. !Empty(EEQ->EEQ_FINNUM) .And. !EECFlags("ALT_EASYLINK"))
            lRet := AvStAction("007")
            If !lRet
                Break
            EndIf
        EndIf

      EEQ->(RecLock("EEQ",.f.))
      EEQ->(DbDelete())
      EEQ->(MSUnlock())
   Next

aDeletados := {}
End Sequence

Return lRet

/*
Funcao      : Ae105DigDataSis()
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Permitir ao usuário informar dados do Siscomex e atualizar os itens do embarque.
Autor       : Jeferson Barros Jr.
Data/Hora   : 29/10/2003 09:55.
Revisao     :
Obs.        :
*/
*------------------------*
Function Ae105DigDataSis()
*------------------------*
Local lRet:=.t., lIsVazio:=.t.
Local nRecWkIp:=0
Private lTelaRE := .T. //SVG - 04/03/2011 - Digitação de RE em tela customizada
Begin Sequence

   nRecWkIp := WorkIp->(RecNo())

   // ** Verifica se o processo possui algum item marcado para embarque.
   WorkIp->(DbGoTop())
   Do While WorkIp->(!Eof())
      If !Empty(WorkIp->WP_FLAG)
         lIsVazio :=.f.
         Exit
      EndIf

      WorkIp->(DbSkip())
   EndDo

   If lIsVazio
      MsgInfo(STR0047,STR0019) //"Para informar o Nro.RE/SD/Ato Concessório, deverá(ão) existir item(ns) marcado(s) para embarque."###"Atenção"
      Break
   EndIf

   //SVG - 04/03/2011 - Ponto de entrada para digitação de RE em tela customizada.
   IF EasyEntryPoint("EECAE105")
      ExecBlock("EECAE105",.F.,.F.,"Ae105DigDataSis_AntesTelaRE")
   Endif
   If lTelaRE
      // ** Tela de gets para os campos de RE/SD/Ato Concessório.
      If !Ae105GetDataSis()
         Break
      EndIf
      MsgInfo(STR0048,STR0039) //"Atualização dos dados realizada com sucesso!"###"Aviso"
   EndIf


End Sequence

WorkIp->(DbGoTo(nRecWkIp))

Return lRet


/*
Funcao      : Ae105GetDataSis()
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Get das informações a serem atualizadas nos itens. (RE/SD/Ato Concessório)
Autor       : Jeferson Barros Jr.
Data/Hora   : 30/10/2003 10:27.
Revisao     : WFS em 22/07/2009: correção do preenchimento dos campo;
              Data S.D. corresponde à data da solicitação de despacho (DDE) - EE9_DTDDE
              Data Averb. corresponde à data de averbação do despacho - EE9_DTAVRB
Obs.        :
*/
*-------------------------------*
Static Function Ae105GetDataSis()
*-------------------------------*
Local lRet:=.f., lOk:=.f.
Local lAtuTesCf := EECFLags("INTEMB") .and. EE9->(FieldPos("EE9_TES")) <> 0 .and.  EE9->(FieldPos("EE9_CF")) <> 0

Local oDlg, oRe, oDtRe, oSd, oDtSd, oAto, oTes, oCf, oFilNf
Local oChkBoxRe, oChkBoxSd, oChkBoxAto, oChkBoxTes, oChkBoxCf, oChkBoxFiltro

Local oPanel

Local nColIni := 0
Local nColFim //:= 300 WFS 06/11/08
Local nLinIni := 0
Local nLinFim := 195 //241//334 - WFS 06/11/08 --- Multiplo de 15 (nTamLin)

Local nLinPanel := 0
Local nColPanel := 0

Local nLin  := 0

Local nHRes := 0
//WFS 06/11/08
Local nLargLab
Local nTamLin:= 13

Local bOk := {|| If(Ae105ValDataSis(),(lRet:=.T.,lOk:=.T.,oDlg:End()),nil)}, bCancel := {|| lOk:=.f.,lRet:=.f., oDlg:End()}

//WFS 22/07/09: Inclusão do tratamento para preenchimento dos campos quando já existe registro na base.
Local bEnableRe  := {|| oRe:Enable() , oDtRe:Enable(),;
                        If(!Empty(WorkIp->EE9_RE)  , cRe  := WorkIp->EE9_RE,)  , oRe:Refresh(),;
                        If(!Empty(WorkIp->EE9_DTRE), dDtRe:= WorkIp->EE9_DTRE,), oDtRe:Refresh()}
Local bEnableSd  := {|| oSd:Enable() , oDtSd:Enable(), oDtAvrb:Enable(),;
                        If(!Empty(WorkIp->EE9_NRSD)  , cSd    := WorkIp->EE9_NRSD,)  , oSd:Refresh(),;
                        If(!Empty(WorkIp->EE9_DTDDE) , dDtSd  := WorkIp->EE9_DTDDE,) , oDtSd:Refresh(),;
                        If(!Empty(WorkIp->EE9_DTAVRB), dDtAvrb:= WorkIp->EE9_DTAVRB,), oDtAvrb:Refresh()}
Local bEnableAto := {|| oAto:Enable(),;
                        If(!Empty(WorkIp->EE9_ATOCON), cAto:= WorkIp->EE9_ATOCON,), oAto:Refresh()}
Local bEnableTes    := {||}
Local bEnableCf     := {||}
Local bEnableFiltro := {||}

Local bDisableRe     := {|| oRe:Disable() , oDtRe:Disable(),;
                            cRe:=CriaVar("EE9_RE"), dDtRe:= CriaVar("EE9_DTRE"),;
                            oRe:Refresh(),oDtRe:Refresh()}

Local bDisableSd     := {|| oSd:Disable() , oDtSd:Disable(), oDtAvrb:Disable(),;
                            cSd:=CriaVar("EE9_NRSD"), dDtSd:= CriaVar("EE9_DTDDE"), dDtAvrb:= CriaVar("EE9_DTAVRB"),;
                            oSd:Refresh(), oDtSd:Refresh(), oDtAvrb:Refresh()}

Local bDisableAto    := {||}

Local bDisableTes    := {||}

Local bDisableCf     := {||}

Local bDisableFiltro := {||}

//DFS - Permitir editar o RE quando a data de embarque nao estiver preenchida ou o parametro de NF de Remessa estiver habilitado.
//Local lEditRE := Empty(EEC->EEC_DTEMBA) .OR. EasyGParam("MV_AVG0174",,.F.) .Or. EasyGParam("MV_AVG0054",,.F.)

Private lChkBoxRe:=.f., lChkBoxSd:=.f., lChkBoxAto:=.f., lChkBoxTes := .f., lChkBoxCf:= .f., lChkBoxFiltro:= .f., lFimLoop := .T. //LRS - 24/04/2018

Private lVerFlag := .F.

Private cRe := CriaVar("EE9_RE")    , dDtRe    := CriaVar("EE9_DTRE"),;
        cSd := CriaVar("EE9_NRSD")  , dDtSd:= CriaVar("EE9_DTDDE"),;
        cAto:= CriaVar("EE9_ATOCON"), cFiltroNf:= CriaVar("EE9_NF"),;
        cTes:= "", cCf := "", dDtAvrb:= CriaVar("EE9_DTAVRB")

Private cFilterBrw := ""

//WFS 06/11/08 ---
If SetMdiChild()
   nLargLab:= 195
   nColFim:= 400
Else
   nLargLab:= 145
   nColFim:= 300
EndIf

If lAtuTesCf
   cTes := CriaVar("EE9_TES")
   cCf  := CriaVar("EE9_CF")
EndIf

Private aItNf   := {}
Private aFiltro := {}

Begin Sequence

   If !lIntDraw
      nLinFim += 8 * nTamLin /*93*/

      bEnableAto    := {|| oAto:Enable(),;                                                         //NCF - 13/11/2014
                        If(!Empty(WorkIp->EE9_ATOCON), cAto:= WorkIp->EE9_ATOCON,), oAto:Refresh()}
      bDisableAto   := {|| oAto:Disable(), cAto:=CriaVar("EE9_ATOCON"),oAto:Refresh()}
   EndIf

   If lAtuTesCf
      nLinFim += 8 * nTamLin /*93*/

      bEnableTes := {|| oTes:Enable()}
      bEnableCf  := {|| oCf:Enable()}

      nLinFim += 8 * nTamLin /*93*/

      bDisableTes := {|| oTes:Disable(), cTes:=CriaVar("EE9_TES"), oTes:Refresh()}
      bDisableCf  := {|| oCf:Disable() , cCf:= CriaVar("EE9_CF") , oCf:Refresh() }
   EndIf

   If lIntegra
      nLinFim += 8 * nTamLin /*93*/

      bEnableFiltro  := {|| oFilNf:Enable()}
      bDisableFiltro := {|| oFilNf:Disable(), cFiltroNf:=CriaVar("EE9_NF"),oFilNf:Refresh()}
   EndIf

    nHRes := oMainWnd:nClientWidth

    //If nHRes == 800	//Resolucao 800x600 - WFS 06/11/08
    If nHRes <= 800	//Resolucao 800x600
       nLinFim := 241
       nColFim += 20 // WFS 06/11/08
    //ElseIf nHRes == 1024 //Resolucao 1024x768 - WFS 06/11/08
    Else
       If nLinFim > 427
          nLinFim := 427
       EndIf
       If lAtuTesCf // WFS 06/11/08
          nColFim += 20
       EndIf
    EndIf

   Define MsDialog oDlg Title STR0049 From nLinIni,nColIni To nLinFim,nColFim Of oMainWnd Pixel  //"Atualização R.E/S.D/Ato Concessório"

      aPosDlg := PosDlg(oDlg)
      // WFS 06/11/08 ---
      If SetMdiChild()
         oPanel := TScrollBox():New(oDlg, aPosDlg[1], aPosDlg[2], aPosDlg[3] - aPosDlg[1]-5, aPosDlg[4] - aPosDlg[2],.T.,.F.,.T. )
      Else
         oPanel := TScrollBox():New(oDlg, aPosDlg[1], aPosDlg[2], aPosDlg[3] - aPosDlg[1], aPosDlg[4] - aPosDlg[2],.T.,.F.,.T. )
      EndIf

      nLin := 2
   
      // ** Informações RE.
     // @ nLin, 004 To nLin + (3 * nTamLin) /*48*/, nLargLab/*145*/ Label "" Of oPanel Pixel
     // nLin += 2
     // @ nLin, 015 CheckBox oChkBoxRe Var lChkBoxRe Prompt STR0050 When lEditRE Size 45,08  Of oPanel Pixel On Change (If(lChkBoxRe,Eval(bEnableRe),Eval(bDisableRe))) //"Dados R.E."

     // nLin += nTamLin /*12*/

     // @ nLin, 015 Say STR0051 Pixel Of oPanel  //"Nro R.E"
     // @ nLin, 050 MsGet oRe Var cRe Picture AvSx3("EE9_RE",AV_PICTURE) Valid AE100VLDRESD(cRe, "EE9_RE") Size 60,08 Of oPanel Pixel;
     // When iif( ALTERAR .AND. AvFlags("DU-E") , .F. , .t. )

     // nLin += nTamLin /*12*/

     // @ nLin, 015 Say STR0052 Pixel Of oPanel  //"Data R.E"
     // @ nLin, 050 MsGet oDtRe Var dDtRe Picture AvSx3("EE9_DTRE",AV_PICTURE) Size 45,08 Of oPanel Pixel;
     // When iif( ALTERAR .AND. AvFlags("DU-E") , .F. , .t. )

     // nLin += nTamLin /*29*/


     // // ** Informações SD.
     // @ nLin, 004 To nLin + (4 * nTamLin) /*48*/, nLargLab /*145*/ Label "" Of oPanel  Pixel
     // nLin += 2
     // @ nLin, 015 CheckBox oChkBoxSd Var lChkBoxSd Prompt STR0053 Size 45,08  Of oPanel Pixel On Change (If(lChkBoxSd,Eval(bEnableSd),Eval(bDisableSd))) //"Dados S.D."

     // nLin += nTamLin /*12*/

     // @ nLin, 015 Say STR0054 Pixel Of oPanel  //"Nro S.D"
     // @ nLin, 050 MsGet oSd Var cSd Picture AvSx3("EE9_NRSD",AV_PICTURE) Valid AE100VLDRESD(cSD, "EE9_NRSD") Size 60,08 Of oPanel Pixel;
     // When iif( ALTERAR .AND. AvFlags("DU-E") , .F. , .t. )

     // nLin += nTamLin /*12*/

     // @ nLin, 015 Say STR0055 Pixel Of oPanel  //"Data S.D"
     // @ nLin, 050 MsGet oDtSD Var dDtSD Picture AvSx3("EE9_DTDDE",AV_PICTURE) Size 45,08 Of oPanel Pixel;
     // When iif( ALTERAR .AND. AvFlags("DU-E") , .F. , .t. )

     // nLin += nTamLin /*12*/

     // @ nLin, 015 Say STR0161 Pixel Of oPanel //"Data Averb."
     // @ nLin, 050 MsGet oDtAvrb Var dDtAvrb Picture AvSx3("EE9_DTAVRB",AV_PICTURE) Size 45,08 Of oPanel Pixel;
     // When iif( ALTERAR .AND. AvFlags("DU-E") , .F. , .t. )

     // nLin += nTamLin /*29*/

      If !lIntDraw

         // ** Ato concessório.

         @ nLin, 004 To nLin + (2 * nTamLin) /*40*/, nLargLab/*145*/ Label "" Of oPanel  Pixel
         nLin += 2
         @ nLin, 015 CheckBox oChkBoxAto Var lChkBoxAto Prompt STR0056 Size 55,08  Of oPanel Pixel On Change (If(lChkBoxAto,Eval(bEnableAto),Eval(bDisableAto))) //"Ato Concessório"

         nLin += nTamLin /*12*/

         @ nLin, 015 Say STR0057 Pixel Of oPanel  //"Ato Conces."
         @ nLin, 050 MsGet oAto Var cAto Picture AvSx3("EE9_ATOCON",AV_PICTURE) Size 60,08 Of oPanel Pixel

         nLin += nTamLin /*34*/

      EndIf

      If lAtuTesCf

         //////////////////////
         //Atualização da TES//
         //////////////////////

         @ nLin, 004 To nLin + (2 * nTamLin) /*40*/, nLargLab /*145*/ Label "" Of oPanel  Pixel
         nLin += 2
         @ nLin, 015 CheckBox oChkBoxTes Var lChkBoxTes Prompt STR0156 Size 55,08  Of oPanel Pixel On Change (If(lChkBoxTes,Eval(bEnableTes),Eval(bDisableTes))) //Tipo de Saida

         nLin += nTamLin /*12*/

         @ nLin, 015 Say STR0156 Pixel Of oPanel  //Tipo de Saída
         @ nLin, 050 MsGet oTes Var cTes Picture AvSx3("EE9_TES",AV_PICTURE) F3 "SF4" Valid(Vazio() .Or. ExistCpo('SF4')) Size 40,08 Of oPanel Pixel

         nLin += nTamLin /*34*/

         //////////////////////////////
         //Atualização do Cod. Fiscal//
         //////////////////////////////

         @ nLin, 004 To nLin + (2 * nTamLin) /*40*/, nLargLab /*145*/ Label "" Of oPanel  Pixel
         nLin += 2
         @ nLin, 015 CheckBox oChkBoxCf Var lChkBoxCf Prompt STR0157 Size 55,08  Of oPanel Pixel On Change (If(lChkBoxCf,Eval(bEnableCf),Eval(bDisableCf))) //"Cod.Fiscal"

         nLin += nTamLin /*12*/

         @ nLin, 015 Say STR0157 Pixel Of oPanel //"Cod. Fiscal"
         @ nLin, 050 MsGet oCf Var cCf Picture AvSx3("EE9_CF",AV_PICTURE) F3 "13" Size 40,08 Of oPanel Pixel

         nLin += nTamLin /*34*/

      EndIf

      If lIntegra

         //////////////////////////
         //Filtro por Nota Fiscal//
         //////////////////////////

         @ nLin, 004 To nLin + (2 * nTamLin) /*40*/, nLargLab/*145*/ Label "" Of oPanel  Pixel
         nLin += 2
         @ nLin, 015 CheckBox oChkBoxFiltro Var lChkBoxFiltro Prompt STR0153 Size 55,08  Of oPanel Pixel On Change (If(lChkBoxFiltro,Eval(bEnableFiltro),Eval(bDisableFiltro))) //"Filtros Específicos"

         nLin += nTamLin /*12*/

         @ nLin, 015 Say STR0154 Pixel Of oPanel  //"Nota Fiscal"
         @ nLin, 050 MsGet oFilNf Var cFiltroNf Picture AvSx3("EE9_NF",AV_PICTURE) F3 "EECNF" Size 60,08 Of oPanel Pixel

         nLin += nTamLin

      EndIf

      /////////////////////
      //Seleção de Filtro//
      /////////////////////

      @ nLin, 004 To nLin + (2 * nTamLin), nLargLab Label "" Of oPanel  Pixel

      nLin += nTamLin / 2

      @ nLin, 050 Button STR0160 Size 037,012 Action(cFilterBrw := FilterX3Brw("WorkIp", oPanel,cFilterBrw,.F.)) Pixel Of oPanel //"Filtro"

      // ** Desabilita os gets.
      /*Eval(bDisableRe); Eval(bDisableSd);*/ Eval(bDisableAto); Eval(bDisableTes);Eval(bDisableCf); Eval(bDisableFiltro)

      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   Activate MSDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) Centered

    If lOk

       /////////////////////////////////////////////////////////
       //Verifica se mais de um item contempla o Filtro de NFs//
       /////////////////////////////////////////////////////////
       If Len(aItNf) > 1

          /////////////////////////////////////////////////////////////
          //Exibe a tela para seleção dos itens que serão atualizados//
          /////////////////////////////////////////////////////////////
          If !Ae105SelItNf()
             lRet := .F.
             Break
          Else
             lVerFlag := .T.
          EndIf
       EndIf

       // ** Confirma a atualização dos dados.
       lRet:=Ae105WiewIt()

       If lRet
          Processa({||Ae105AtuDataSis()})
       EndIf
    EndIf

End Sequence

Return lRet

/*
Funcao      : Ae105AtuDataSis()
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Atualiza os dados
Autor       : Jeferson Barros Jr.
Data/Hora   : 30/10/2003 17:17.
Revisao     :
Obs.        :
*/
*-------------------------------*
Static Function Ae105AtuDataSis()
*-------------------------------*
Local lRet:=.t., cNCM := ""

Begin Sequence

   ProcRegua(WorkIP->(LastRec())+3)

   IncProc(STR0058) //"Atualizando itens ..."

   WorkIp->(DbGoTop())
   Do While WorkIp->(!Eof())
      IncProc()
      If !Empty(WorkIp->WP_FLAG)

         If lChkBoxFiltro
            If !Empty(cFiltroNF)
               If (lVerFlag .and. Empty(WorkIp->WP_MKITNF)) .or. (!lVerFlag .and. AllTrim(WorkIp->EE9_NF) <> AllTrim(cFiltroNf))
                  WorkIp->(DbSkip())
                  Loop
               EndIf
            EndIf
         EndIf

         If !Empty(cFilterBrw)
           If !(&cFilterBrw)
              WorkIp->(DbSkip())
              Loop
           EndIf
         EndIf

         If lChkBoxRe
            WorkIp->EE9_RE    := cRe
            WorkIp->EE9_DTRE  := dDtRe
            If EE9->(FieldPos("EE9_PERIE")) > 0 .AND. EE9->(FieldPos("EE9_BASIE")) > 0 .AND. EE9->(FieldPos("EE9_VLRIE")) > 0  // GFP - 17/12/2015
               If Empty(WorkIp->EE9_PERIE)
                  cNCM := Posicione('SB1',1,xFilial('SB1') + WorkIp->EE9_COD_I ,'B1_POSIPI') //MCF - 13/06/2016
                  WorkIp->EE9_PERIE := Posicione('SYD',1,xFilial('SYD') + AvKey(cNCM,"YD_TEC") ,'YD_PER_IE')
               EndIf
               WorkIp->EE9_BASIE := AE100GatIE('EE9_BASIE',1,"WorkIp")
               WorkIp->EE9_VLRIE := AE100GatIE('EE9_VLRIE',2,"WorkIp")
            EndIf
         EndIf

         If lChkBoxSd
            WorkIp->EE9_NRSD   := cSd
            WorkIp->EE9_DTAVRB := dDtAvrb
            WorkIp->EE9_DTDDE  := dDtSd
         EndIf

         If lChkBoxAto
            WorkIp->EE9_ATOCON := cAto
         EndIf

         If lChkBoxTes
            WorkIp->EE9_TES := cTes
         EndIf

         If lChkBoxCf
            WorkIp->EE9_CF := cCf
         EndIf

      EndIf
      WorkIp->(DbSkip())
   EndDo

   If EEC->(FieldPos("EEC_VLRIE")) # 0  // GFP - 17/12/2015
      M->EEC_VVLIE := AE100VLRIE(1)
   EndIf

   //DFS - Implementado para atribuir o status correto na geração de RE
   If lChkBoxRe
      M->EEC_STASIS := SI_SF
   EndIf

End Sequence

Return lRet

/*
Funcao      : Ae105ValDataSis()
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Validação das informações do RE/SD/Ato concessório.
Autor       : Jeferson Barros Jr.
Data/Hora   : 30/10/2003 15:42.
Revisao     :
Obs.        :
*/
*-------------------------------*
Static Function Ae105ValDataSis()
*-------------------------------*
Local lRet:=.t.
Local lFiltroNf := .F.
Local aOrd := SaveOrd({"WorkIp"})
Local lRetBlock:= .T.


Begin Sequence

   If /*!lChkBoxRe .And. !lChkBoxSd .And.*/ !lChkBoxAto .And. !lChkBoxTes .And. !lChkBoxCf
      MsgStop(STR0059,STR0019) //"Nenhum dado foi informado para o Ato Concessório."###"Atenção"
      lRet:=.f.
      Break
   EndIf

   // ** Valida as informações do RE.
   If lChkBoxRe
      If Empty(cRe) .AND. Empty(dDtRe)
         If !MsgNoYes("Dados incompletos para o R.E. Deseja continuar mesmo assim?",STR0019) //"Dados incompletos para o R.E. Revise os campos 'Nro R.E.' e 'Data R.E.'."###"Atenção"
            lRet:=.f.
            Break
		 EndIf
      ElseIf Empty(cRe) .Or. Empty(dDtRe)
         MsgStop(STR0060,STR0019) //"Dados incompletos para o R.E. Revise os campos 'Nro R.E.' e 'Data R.E.'."###"Atenção"
         lRet:=.f.
         Break
      EndIf
   EndIf

   // ** Valida as informações do RE.
   If lChkBoxSd
      If Empty(cSd) .AND. Empty(dDtSd)
         If !MsgNoYes("Dados incompletos para o S.D. Deseja continuar mesmo assim?",STR0019) //"Dados incompletos para o S.D. Revise os campos 'Nro S.D.' e 'Data S.D.'."###"Atenção"
            lRet:=.f.
            Break
		 EndIf
	  ElseIf Empty(cSd) .Or. Empty(dDtSd)
         MsgStop(STR0061,STR0019) //"Dados incompletos para o S.D. Revise os campos 'Nro S.D.' e 'Data S.D.'."###"Atenção"
         lRet:=.f.
         Break
      EndIf
   EndIf

   // ** Valida as informações do RE.
   If lChkBoxAto
      If Empty(cAto)
         If !MsgNoYes(STR0185,STR0019) //"Dados incompletos para Nro do Ato Concessório. Deseja continuar mesmo assim?"###"Atenção"
            lRet:=.f.
            Break
		 EndIf
      EndIf
   EndIf

   ///////////////////////////////////////////////////////////////////////
   //Verifica preenchimento do Tipo de Saída (TES) e do Cod. Fiscal (CF)//
   ///////////////////////////////////////////////////////////////////////
   If lChkBoxTes
      If Empty(cTes)
         MsgStop(STR0158 ,STR0019) //"Informe o Código do Tipo de Saída !"###"Atenção"
         lRet:=.f.
         Break
      EndIf
   EndIf

   If lChkBoxCf
      If Empty(cCf)
         MsgStop(STR0159 ,STR0019) //"Informe o Código Fiscal !"###"Atenção"
         lRet:=.f.
         Break
      EndIf
   EndIf

   ///////////////////////////////////
   //Verifica os Filtros Específicos//
   ///////////////////////////////////
   If lChkBoxFiltro

      lFiltroNf := .F.

      ///////////////
      //Nota Fiscal//
      ///////////////
      If !Empty(cFiltroNf)

         WorkIp->(DbGoTop())
         While WorkIp->(!EOF())

            If AllTrim(WorkIp->EE9_NF) == AllTrim(cFiltroNf)
               lFiltroNf := .T.
               aAdd(aItNf,WorkIp->(RecNo()))
            EndIf

            WorkIp->(DbSkip())
         EndDo

         If !lFiltroNf
            MsgStop(STR0155,STR0019) //"Nota Fiscal não encontrada no Embarque."###"Atenção"
            lRet:=.f.
            Break
         EndIf

      EndIf
   EndIf

   ///////////////////////
   //Verifica os Filtros//
   ///////////////////////
   If !Empty(cFilterBrw)

      WorkIp->(DbGoTop())
      While WorkIp->(!EOF())

         If &cFilterBrw
            aAdd(aFiltro,WorkIp->(RecNo()))
         EndIf

         WorkIp->(DbSkip())
      EndDo

      If Len(aFiltro) <= 0 .and. !lFiltroNF
         MsgStop(STR0164,STR0019) //###"Atenção"//STR0164	"Não existem itens que satisfaçam a seleção de filtro."

         lRet:=.f.
         Break
      EndIf

   EndIf

    //TRP - 08/08/2011 - Ponto de entrada para validar botão de OK da tela RE/SD/Ato Concessorio.
    IF EasyEntryPoint("EECAE105")
       lRetBlock:= ExecBlock("EECAE105",.F.,.F.,"VALRESD")
       IF ValType(lRetBlock) == "L"
          lRet := lRetBlock
       Endif
    Endif

End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : Ae105WiewIt()
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Verificar os itens antes da atualização dos campos.
Autor       : Jeferson Barros Jr.
Data/Hora   : 30/10/2003 16:19.
Revisao     :
Obs.        :
*/
*---------------------------*
Static Function Ae105WiewIt()
*---------------------------*
Local cMsg, cCond:=" ", cCampos:=" ", cCmp:=" ", cFiltro:=" "
Local aCond:={}, aCmp:={}, aFiltro:={}
Local nRecWkIp:=0, j:=0, z:=0
Local lRet:=.t.

Begin Sequence

    If lChkBoxRe
       aAdd(aCond,"!Empty(WorkIp->EE9_RE)")
       aAdd(aCond,"!Empty(WorkIp->EE9_DTRE)")
    EndIf

    If lChkBoxSd
       aAdd(aCond,"!Empty(WorkIp->EE9_NRSD)")
       aAdd(aCond,"!Empty(WorkIp->EE9_DTDDE)")
       aAdd(aCond,"!Empty(WorkIp->EE9_DTAVRB)")
    EndIf

    If lChkBoxAto
       aAdd(aCond,"!Empty(WorkIp->EE9_ATOCON)")
    EndIf

    If lChkBoxTes
       aAdd(aCond,"!Empty(WorkIp->EE9_TES)")
    EndIf

    If lChkBoxCf
       aAdd(aCond,"!Empty(WorkIp->EE9_CF)")
    EndIf

    For j:=1 To Len(aCond)
       cCond += aCond[j]+If(j<>Len(aCond)," .Or. ","")
    Next

    If lChkBoxFiltro
       aAdd(aFiltro,"Alltrim(WorkIp->EE9_NF) == '" + AllTrim(cFiltroNf)+ "'" )
    EndIf

    If !Empty(cFilterBrw)
       aAdd(aFiltro, cFilterBrw)
    EndIf

    For j:=1 To Len(aFiltro)
       cFiltro += aFiltro[j]+If(j<>Len(aFiltro)," .And. ","")
    Next

    nRecWkIp:=WorkIp->(RecNo())
    WorkIp->(DbGoTop())
    Do While WorkIp->(!Eof())

       If !Empty(WorkIp->WP_FLAG)
          If Empty(cFiltro) .Or. &(cFiltro)
             If (lVerFlag .and. !Empty(WorkIp->WP_MKITNF)) .or. !lVerFlag
                If &(cCond)
                   lRet:=.f.
                   Exit
                EndIf
             EndIf
          EndIf
       EndIf

       WorkIp->(DbSkip())
    EndDo
    WorkIp->(DbGoTo(nRecWkIp))

    If !lRet
       If lChkBoxRe
          aAdd(aCmp,STR0129) //"'Nro R.E.'"
          aAdd(aCmp,STR0130) //"'Data R.E.'"
       EndIf

       If lChkBoxSd
          aAdd(aCmp,STR0131) //"'Nro S.D.'"
          aAdd(aCmp,STR0132) //"'Data S.D.'"

          //WFS 22/07/2009
          //a Data de averbação é preenchida posteriormente.
          If !Empty(WorkIp->EE9_DTAVRB)
             AAdd(aCmp,STR0162) //"'Data Averb.'"
          EndIf
       EndIf

       If lChkBoxAto
          aAdd(aCmp,STR0133) //"'Ato Conces.'"
       EndIf

       If lChkBoxTes
          aAdd(aCmp,STR0156) //"'Tipo de Saída'"
       EndIf

       If lChkBoxCf
          aAdd(aCmp,STR0157)
       EndIf

       For z:=1 To Len(aCmp)
          cCmp+= aCmp[z]+If(z<>Len(aCmp),", ","")
       Next

       lRet:= MsgYesNo(STR0063+cCmp+STR0064+Replic(ENTER,2)+; //"O processo já possui item(ns) com os campos "###" preenchidos."
                       STR0065,STR0019) //"Deseja atualizar as informações?"###"Atenção"
    EndIf

End Sequence

Return lRet

/*
Função      : FilterX3Brw(cAlias, oDlg, cFilter, lSetFilter)
Parametros  : cAlias - Work onde o filtro será aplicado.
              oDlg - Tela onde a interface será inserida.
              cFilter - Filtro atual.
              lSetFilter - Indica se o filtro será aplicado na tabela.
Retorno     : cFilter - Filtro montado pelo usuário.
Objetivos   : Exibir tela para montagem de filtro.
Autor       : Eduardo C. Romanini
Data/Hora   : 22/04/09
*/
Static Function FilterX3Brw(cAlias, oDlg, cFilter, lSetFilter)
Local aCampos := SxFieldInfo("FILTER", X3Fields(), cAlias)
Default cFilter := cFilterBrw
Default lSetFilter := .T.

   cFilter := BuildExpr(cAlias, oDlg, cFilter, , , , , , , , aCampos )
   If lSetFilter
      If Empty(cFilter)
         (cAlias)->(DbClearFilter())
      Else
         (cAlias)->(DbClearFilter())
         (cAlias)->(DbSetFilter(&("{|| " + cFilter + "}"), cFilter))
      EndIf
      cFilterBrw := cFilter
      (cAlias)->(DbGoTop())
   EndIf

Return cFilter

/*
Função      : SxFieldInfo(cType, aFields, cAlias, cFlag)
Parametros  : cType - Tipo de uso das informações (MSSELECT, CRIATRAB ou FILTER)
Retorno     : aRet - Array com a definição dos campos
Objetivos   : Montar array com definições dos campos so SX3
Autor       : Eduardo C. Romanini
Data/Hora   : 22/04/09
*/
Static Function SxFieldInfo(cType, aFields, cAlias)
Local aRet   := {}
Local nInc, nPos

Local nField   := 1,;
      nType    := 2,;
      nSize    := 3,;
      nDecimal := 4

Local aStru := (cAlias)->(DbStruct())

   Do Case

      Case Upper(cType) == "FILTER"
         For nInc := 1 To Len(aFields)
            nPos := aScan(aStru, {|aField| aField[1] == aFields[nInc] })
            If nPos > 0
               aAdd(aRet, {aFields[nInc], aFields[nInc], .T., StrZero(nPos, 2), aStru[nPos][nSize], "", aStru[nPos][nType], aStru[nPos][nDecimal] })
            EndIf
         Next
   End Case

Return aRet

/*
Função      : X3Fields()
Parametros  : Nenhum.
Retorno     : aFields - Array com o nome dos campos do SX3.
Objetivos   : Retornar campos do SX3 que serão exibidos nos browses.
Autor       : Eduardo C. Romanini
Data/Hora   : 22/04/09
*/
Static Function X3Fields()
Local aFields := {"EE9_SEQUEN","EE9_SEQEMB","EE9_PEDIDO","EE9_COD_I","EE9_FORN","EE9_FOLOJA","EE9_FABR","EE9_FALOJA","EE9_PACKAG",;
                  "EE9_POSIPI","EE9_NLNCCA","EE9_NALSH" ,"EE9_RV"   ,"EE9_DTRV","EE9_RE"    ,"EE9_DTRE","EE9_ATOCON","EE9_SEQED3",;
                  "EE9_NRSD"  ,"EE9_DTAVRB"}
Return aFields

/*
Funcao      : AE105FixPrice
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Fixação de Preço na Fase de Embarque.
Autor       : Jeferson Barros Jr.
Data/Hora   : 25/03/2004 14:37.
Revisao     :
Obs.        :
*/
*----------------------*
Function AE105FixPrice()
*----------------------*
Local lRet:=.t., aOrd:=SaveOrd({"EE9","EE8"}), oDlg
//Local cFilBr:=AvKey(EasyGParam("MV_AVG0023",,""),"EE7_FILIAL"),;
//      cFilEx:=AvKey(EasyGParam("MV_AVG0024",,""),"EE7_FILIAL")
Local aItensToFix:={}, aItEstornar:={}, lFix:=.f., lEst:=.f., aAux:={}
Local cFileTemp, aSemSx3, j:=0, aButtons:={}, cTitulo, aColunas:={}
Local cEmbarque, dDtProc := AvCToD("")
Local lOk:=.f.
Local bOk := {||If(Ae105VldFix(.T.),(lOk:=.t.,oDlg:End()),nil)},;
      bCancel:={|| oDlg:End()}

//Private dDtCotacao := AvCToD(""),
Private cMesFix := Space(8)

Begin Sequence

   // ** Verifica se o embarque possue algum item para fixação de preço.
   EE9->(DbSetOrder(2))
   EE9->(DbSeek(xFilial("EEC")+EEC->EEC_PREEMB))

   Do While EE9->(!Eof()) .And. EE9->EE9_FILIAL == xFilial("EEC") .And. EE9->EE9_PREEMB == EEC->EEC_PREEMB

      //JPM - 22/02/06 - If Empty(EE9->EE9_PRECO)
      If Empty(Posicione("EE8",1,xFilial("EE8")+EE9->(EE9_PEDIDO+EE9_SEQUEN),"EE8_DTFIX"))
         aAdd(aItensToFix,EE9->EE9_SEQEMB)
      EndIf

      EE9->(DbSkip())

   EndDo

   /*
   If Len(aItensToFix) = 0
      // ** Verifica se existe algum item para estorno da fixação.
      EE8->(DbSetOrder(1))
      EE9->(DbSeek(cFilEx+EEC->EEC_PREEMB))
      Do While EE9->(!Eof()) .And. EE9->EE9_FILIAL == cFilEx .And.;
                                   EE9->EE9_PREEMB == EEC->EEC_PREEMB

         If !Empty(EE9->EE9_PRECO)
            If EE8->(DbSeek(cFilEx+EE9->EE9_PEDIDO+EE9->EE9_SEQUEN))
               If EE8->EE8_SLDINI = EE9->EE9_SLDINI
                  aAdd(aItEstornar,EE9->EE9_SEQEMB)
               EndIf
            EndIf
         EndIf

         EE9->(DbSkip())
      EndDo
   EndIf

   lFix := !(Len(aItensToFix) = 0)
   lEst := !(Len(aItEstornar) = 0)

   If !lFix //.And. !lEst
      MsgStop(STR0066,STR0019) //"Este processo não possue itens para fixar ou estonar preço."###"Atenção"
      lRet:=.f.
      Break
   EndIf
   */

   If Len(aItensToFix) = 0
      MsgStop(STR0084, STR0019) //"Este processo não possue itens para fixar preço."
      lRet:=.f.
      Break
   EndIf

   aCampos:={}
   aSemSX3:={{"EE9_PREEMB",AVSX3("EE9_PREEMB",AV_TIPO),AVSX3("EE9_PREEMB",AV_TAMANHO),AVSX3("EE9_PREEMB",AV_DECIMAL)},;
             {"EE9_PEDIDO",AVSX3("EE9_PEDIDO",AV_TIPO),AVSX3("EE9_PEDIDO",AV_TAMANHO),AVSX3("EE9_PEDIDO",AV_DECIMAL)},;
             {"EE9_SEQEMB",AVSX3("EE9_SEQEMB",AV_TIPO),AVSX3("EE9_SEQEMB",AV_TAMANHO),AVSX3("EE9_SEQEMB",AV_DECIMAL)},;
             {"EE9_SEQUEN",AVSX3("EE9_SEQUEN",AV_TIPO),AVSX3("EE9_SEQUEN",AV_TAMANHO),AVSX3("EE9_SEQUEN",AV_DECIMAL)},;
             {"EE9_COD_I ",AVSX3("EE9_COD_I ",AV_TIPO),AVSX3("EE9_COD_I ",AV_TAMANHO),AVSX3("EE9_COD_I ",AV_DECIMAL)},;
             {"EE9_VM_DES",AVSX3("EE9_VM_DES",AV_TIPO),AVSX3("EE9_VM_DES",AV_TAMANHO),AVSX3("EE9_VM_DES",AV_DECIMAL)},;
             {"EE9_SLDINI",AVSX3("EE9_SLDINI",AV_TIPO),AVSX3("EE9_SLDINI",AV_TAMANHO),AVSX3("EE9_SLDINI",AV_DECIMAL)},;
             {"EE9_QTDFIX",AVSX3("EE9_SLDINI",AV_TIPO),AVSX3("EE9_SLDINI",AV_TAMANHO),AVSX3("EE9_SLDINI",AV_DECIMAL)},;
             {"EE9_PRECO ",AVSX3("EE9_PRECO ",AV_TIPO),AVSX3("EE9_PRECO ",AV_TAMANHO),AVSX3("EE9_PRECO ",AV_DECIMAL)},;
             {"EE9_DIFERE",AVSX3("EE8_DIFERE",AV_TIPO),AVSX3("EE8_DIFERE",AV_TAMANHO),AVSX3("EE8_DIFERE",AV_DECIMAL)},;
             {"EE9_MESFIX",AVSX3("EE8_MESFIX",AV_TIPO),AVSX3("EE8_MESFIX",AV_TAMANHO),AVSX3("EE8_MESFIX",AV_DECIMAL)},;
             {"EE9_DTCOTA",AVSX3("EE8_DTCOTA",AV_TIPO),AVSX3("EE8_DTCOTA",AV_TAMANHO),AVSX3("EE8_DTCOTA",AV_DECIMAL)},;
             {"EE9_DTFIX", AVSX3("EE8_DTFIX", AV_TIPO),AVSX3("EE8_DTFIX", AV_TAMANHO),AVSX3("EE8_DTFIX", AV_DECIMAL)},;
             {"EE9_QTDLOT",AVSX3("EE8_QTDLOT",AV_TIPO),AVSX3("EE8_QTDLOT",AV_TAMANHO),AVSX3("EE8_QTDLOT",AV_DECIMAL)},;
             {"EE9_UNIDAD",AVSX3("EE9_UNIDAD",AV_TIPO),AVSX3("EE9_UNIDAD",AV_TAMANHO),AVSX3("EE9_UNIDAD",AV_DECIMAL)},;
             {"EE9_QE",    AVSX3("EE9_QE",AV_TIPO),    AVSX3("EE9_QE",    AV_TAMANHO),AVSX3("EE9_QE",AV_DECIMAL)},;
             {"WK_VLCOT", "N", 17, 07},;
             {"WK_FLAG",  "C", 01, 00}}

   cFileTmp:=E_CriaTrab(,aSemSX3,"WorkFix")

   aAux := aClone(aItensToFix)

   EE9->(DbSetOrder(3)) // Filial+Preemb+SeqEmb.
   For j:=1 To Len(aAux)
      If EE9->(DbSeek(cFilEx+EEC->EEC_PREEMB+AvKey(aAux[j],"EE9_SEQEMB")))
         WorkFix->(DbAppend())
         WorkFix->EE9_PREEMB := EE9->EE9_PREEMB
         WorkFix->EE9_PEDIDO := EE9->EE9_PEDIDO
         WorkFix->EE9_SEQUEN := EE9->EE9_SEQUEN
         WorkFix->EE9_SEQEMB := EE9->EE9_SEQEMB
         WorkFix->EE9_COD_I  := EE9->EE9_COD_I
         WorkFix->EE9_VM_DES := MSMM(EE9->EE9_DESC,AVSX3("EE9_VM_DES",AV_TAMANHO))
         WorkFix->EE9_SLDINI := EE9->EE9_SLDINI
         WorkFix->EE9_PRECO  := EE9->EE9_PRECO
         WorkFix->EE9_UNIDAD := EE9->EE9_UNIDAD
         WorkFix->EE9_QE     := EE9->EE9_QE
      EndIf
   Next

      aAdd(aButtons,{"PRECO",{|| AE105Price(), oMsSelect:oBrowse:Refresh()},STR0067}) //"Fixação"
      cTitulo := STR0068 //"Embarque"

   aColunas := {{{||WorkFix->EE9_PEDIDO},"",AvSx3("EE9_PEDIDO",AV_TITULO)},;
                {{||WorkFix->EE9_SEQUEN},"",AvSx3("EE9_SEQUEN",AV_TITULO)},;
                {{||WorkFix->EE9_COD_I} ,"",AvSx3("EE9_COD_I" ,AV_TITULO)},;
                {{||Memoline(WorkFix->EE9_VM_DES,60,1) },"",AvSx3("EE9_VM_DES" ,AV_TITULO)},;
                {{||Transf(WorkFix->EE9_SLDINI,AVSX3("EE9_SLDINI",AV_PICTURE))},"",AvSx3("EE9_SLDINI" ,AV_TITULO)},;
                {{||Transf(WorkFix->EE9_QTDFIX, AVSX3("EE9_SLDINI",AV_PICTURE))},"", STR0099},; //"Qtde.Fixada"
                {{||Transf(WorkFix->EE9_PRECO ,EECPreco("EE9_PRECO", AV_PICTURE))},"",AvSx3("EE9_PRECO" ,AV_TITULO)},;
                {{||Transf(WorkFix->EE9_DIFERE ,AVSX3("EE8_DIFERE",AV_PICTURE))},"",AvSx3("EE8_DIFERE" ,AV_TITULO)},;
                {{||Transf(WorkFix->EE9_MESFIX ,AVSX3("EE8_MESFIX",AV_PICTURE))},"",AvSx3("EE8_MESFIX" ,AV_TITULO)}}
              //{{||Transf(WorkFix->EE9_PRECO ,AVSX3("EE9_PRECO",AV_PICTURE))},"",AvSx3("EE9_PRECO" ,AV_TITULO)},;

   cEmbarque := AllTrim(EEC->EEC_PREEMB)
   dDtProc   := EEC->EEC_DTPROC
   WorkFix->(DbGoTop())

   DEFINE MSDIALOG oDlg TITLE cTitulo FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd Pixel

      @ 1.4,0.8 Say AvSx3("EEC_PREEMB",AV_TITULO)
      @ 1.4,15  Say AvSx3("EEC_DTPROC",AV_TITULO)

      @ 1.4,05  MsGet cEmbarque When .f. Size 50,7 RIGHT
      @ 1.4,20  MsGet dDtProc   When .f. Size 50,7 RIGHT

//      If lFix
//         @ 2.4,0.8 Say STR0070 //"Dt.Cotação"
//         @ 2.4,05  MsGet dDtCotacao PICTURE "@D" Size 50,7 RIGHT
//      EndIf

      aPos := PosDlgDown(oDlg)
      aPos[1] := 45

      //by CRF - 08/10/2010 12:02
  //    aColunas := AddCpoUser(aColunas,"EE9","2")

      AddCpoUser(aColunas,"EE9","5","WorkFix")

      oMsSelect := MsSelect():New("WorkFix",,,aColunas,,,aPos)
      oMsSelect:bAval := aButtons[AScan(aButtons,{|x| x[1] = "PRECO"})][2]

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

   If lOk
      Begin Transaction
        Processa({|| Ae105RecFix(.T.)})
        IF EasyEntryPoint("EECAE105")
           ExecBlock("EECAE105",.F.,.F.,"GRVOKFIX")
        Endif
      End Transaction
   EndIf

End Sequence

If Select("WorkFix") > 0
   WorkFix->(E_EraseArq(cFileTmp))
EndIf

RestOrd(aOrd)

Return lRet

/*
Funcao      : Ae105RecFix().
Parametros  : lFix - .t. - Fixação.
                     .f. - Estorno.
Retorno     : .t./.f.
Objetivos   : Efetivar a fixação na Base de Dados.
Autor       : Jeferson Barros Jr.
Data/Hora   : 26/03/2004 10:36.
Revisao     :
Obs.        :
*/
*-------------------------------*
Static Function AE105RecFix(lFix)
*-------------------------------*
Local lRet:=.t., aOrd:=SaveOrd({"EE9"})

Begin Sequence

   ProcRegua(WorkFix->(LastRec())+1)

   EE9->(DbSetOrder(3))

   //Atualiza o EE9.
   WorkFix->(DbGoTop())

   Do While WorkFix->(!Eof())

      IncProc(STR0071+AllTrim(Transf(WorkFix->EE9_SEQEMB,AVSX3("EE9_SEQEMB",AV_PICTURE)))) //"Atualizando Item: "

      If WorkFix->WK_FLAG = "1" // Item com preço fixado ...

         AE105FixItem(WorkFix->EE9_PREEMB, WorkFix->EE9_SEQEMB, WorkFix->EE9_QTDFIX, WorkFix->EE9_QTDLOT,;
                      WorkFix->EE9_PRECO, WorkFix->EE9_MESFIX, WorkFix->EE9_DTFIX,;
                      WorkFix->EE9_DTCOTA, WorkFix->EE9_DIFERE,,0)


         //Atualização do preco do itens do embarque.
         AE105CallPrecoI()

         //Atualização do preco dos itens do pedido.
         AP105CallPrecoI()

      EndIf

      /*
      If (EE9->(DbSeek(xFilial("EE9")+WorkFix->EE9_PREEMB+WorkFix->EE9_SEQEMB)))
         If EE9->(RecLock("EE9",.f.))
            EE9->EE9_PRECO  := WorkFix->EE9_PRECO
            EE9->EE9_PRECOI := EE9->EE9_PRECO

            // ** Atualiza os dados no item no processo de exportação.
            Ae105AtuItPed(lFix)
         EndIf
      EndIf
      */

      WorkFix->(DbSkip())

   EndDo

   // ** Recalcula os precos e totais do embarque.
   Ae105CallPrecoI()

End Sequence

RestOrd(aOrd)

Return lRet


/*
Funcao      : AE105GetMesFix().
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Get do Mes de Fixação de preço.
              Atualiza browse com os dados da fixação.
Autor       : Jeferson Barros Jr.
Data/Hora   : 25/03/2004 17:37.
Revisao     :
Obs.        :
*/

/*
*------------------------------*
Static Function AE105GetMesFix()
*------------------------------*
Local lRet, oDlg, oMesFix, xx, aOrd:=SaveOrd({"EE8","EX7"}), nValCot:=0
Local bOk := {|| If(Ae105MesAno(cMesFix),(lOk:=.t.,oDlg:End()),nil)},;
      bCancel := {|| oDlg:End()}
Local lOk:=.f.

Local oDtCota,  dDtCota  := Ctod(""),;
      oQtdeFix, nQtdeFix := WorkFix->EE9_SLDINI,;
      oDifere,  nDifere  := If(EE8->(dbSeek(xFilial("EE8")+WorkFix->EE9_PEDIDO+WorkFix->EE9_SEQUEN)), EE8->EE8_DIFERE, 0)

Begin Sequence

   If Empty(dDtCotacao)
      MsgStop(STR0072,STR0019) //"Informe a data de cotação."###"Atenção"
      lRet:=.f.
      Break
   EndIf

   DEFINE MSDIALOG oDlg TITLE STR0073 FROM 10,12 TO 25.5,47 OF oMainWnd //"Fixação" 20.5

      @ 1.1, 0.5 To 5.5,17 LABEL STR0074 Of oDlg //F"Dados para fixação"

      @ 2.0, 1.5 SAY STR0075 OF oDlg SIZE 35,9 //"Mes/Ano"
      @ 2.0, 7.0 MsGet oMesFix Var cMesFix SIZE 40,07 PICTURE "@R 99/9999" Valid Ae105MesAno(cMesFix) Of oDlg

      @ 3.0, 1.5 SAY STR0086 OF oDlg SIZE 35,9 //"Diferencial"
      @ 3.0, 7.0 MsGet oDifere Var nDifere SIZE 40,07 PICTURE AVSX3("EE8_DIFERE",AV_PICTURE) Of oDlg

      @ 4.0, 1.5 SAY STR0087 OF oDlg SIZE 35,9 //"Qtde Fixada (KG)"
      @ 4.0, 7.0 MsGet oQtdeFix Var nQtdeFix SIZE 50,07 PICTURE AVSX3("EE8_SLDINI", AV_PICTURE) Of oDlg

      xx := ""
      @ 1000, 1 MSGET xx SIZE 1,1

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   If lOk

      EX7->(DbSetOrder(1))
      If EX7->(DbSeek(xFilial("EX7")+dtos(dDtCotacao)+AVKey(AllTrim(cMesFix),"EX7_MESANO")))
         nVlCot := EX7->EX7_VALCOT
      EndIf

	  WorkFix->EE9_MESFIX := cMesFix
	  WorkFix->EE9_DIFERE := nDifere
      WorkFix->EE9_PRECO  := nVlCot + WorkFix->EE9_DIFERE
      WorkFix->EE9_QTDFIX := nQtdeFix
      WorkFix->WK_FLAG    := "1" // Flag preco fixado ...

      //EE8->(DbSetOrder(1))
      //WorkFix->(DbGoTop())
      //Do While WorkFix->(!Eof())
      //   If EE8->(DbSeek(xFilial("EE8")+WorkFix->EE9_PEDIDO+WorkFix->EE9_SEQUEN))
      //     WorkFix->EE9_PRECO := nVlCot+EE8->EE8_DIFERE
      //   EndIf
      //   WorkFix->(DbSkip())
      //EndDo
      //WorkFix->(DbGoTop())


   EndIf

End Sequence

RestOrd(aOrd)

Return lRet
*/

/*
Funcao    : AE105Price()
Objetivos : Tela com dados p/ fixação de R.V.
Autor     : Alexsander Martins dos Santos.
Data/Hora : 28/04/2004 às 15:25.
*/

Static Function AE105Price()

// Local lRet        := .F. // By JPP - 09/11/2006 - 16:00 - Estas variaveis passaram a ser definidas como private para customização.
Local aSaveOrd    := SaveOrd("EE8")
// Local nOpc        := 0 // By JPP - 09/11/2006 - 16:00 - Estas variaveis passaram a ser definidas como private para customização.
// Local bSetVal     := {|x| If(x = 1, nValFix := nVlCotacao+nDiferencial, nVlCotacao := nValFix-nDiferencial)} // By JPP - 09/11/2006 - 16:00 - Estas variaveis passaram a ser definidas como private para customização.
// Local cCodUnidLot := EasyGParam("MV_AVG0034") // By JPP - 09/11/2006 - 16:00 - Estas variaveis passaram a ser definidas como private para customização.
// Local bSetQtd     := {|x| If(x = 1, nQtdeLot := AVTransUnid(WorkFix->EE9_UNIDAD, cCodUnidLot, WorkFix->EE9_COD_I, nQtdeFix, .F.),; // By JPP - 09/11/2006 - 16:00 - Estas variaveis passaram a ser definidas como private para customização.
//                           If(nQtdeFix = 0, nQtdeFix := AvTransUnid(cCodUnidLot, WorkFix->EE9_UNIDAD, WorkFix->EE9_COD_I, nQtdeLot, .F.),Nil)), .T.}

// Local bOk     := {|| If( AE105VldPrice(), (nOpc := 1, oDlg:End()), Nil)},; // By JPP - 09/11/2006 - 16:00 - Estas variaveis passaram a ser definidas como private para customização.
//       bCancel := {|| oDlg:End()}

Local nI
Private lRet        := .F. // By JPP - 09/11/2006 - 16:00
Private nOpc        := 0 // By JPP - 09/11/2006 - 16:00
Private bSetVal     := {|x| If(x = 1, nValFix := nVlCotacao+nDiferencial, nVlCotacao := nValFix-nDiferencial)} // By JPP - 09/11/2006 - 16:00
Private cCodUnidLot := EasyGParam("MV_AVG0034") // By JPP - 09/11/2006 - 16:00
Private bSetQtd     := {|x| If(x = 1, nQtdeLot := AVTransUnid(WorkFix->EE9_UNIDAD, cCodUnidLot, WorkFix->EE9_COD_I, nQtdeFix, .F.),; // By JPP - 09/11/2006 - 16:00
                            If(nQtdeFix = 0, nQtdeFix := AvTransUnid(cCodUnidLot, WorkFix->EE9_UNIDAD, WorkFix->EE9_COD_I, nQtdeLot, .F.),Nil)), .T.}

Private bOk     := {|| If( AE105VldPrice(), (nOpc := 1, oDlg:End()), Nil)},; // By JPP - 09/11/2006 - 16:00
        bCancel := {|| oDlg:End()}

Private cDataFix     := "",;
        nDiferencial := 0,;
        dDtaCota     := AvCtod(""),;
        nValFix      := 0,;
        nQtdeFix     := 0,;
        nQtdeLot     := 0,;
        dDtaFix      := AvCtod(""),;
        cSequen      := "",;
        nVlCotacao   := 0,;
        cPICTVALFX   := EECPreco("EE8_PRECO", AV_PICTURE),; //cPICTVALFX   := AVSX3("EE8_PRECO",AV_PICTURE),;
        cPICTVALCT   := cPICTVALFX,;
        cCodDesc,;
        cBolsa,;
        nTamLinTela := 32.2/*31.2*/,; // By JPP - 09/11/2006 - 16:00
        nTamColTela := 45,;   // By JPP - 09/11/2006 - 16:00
        nTamLinLbl  := 11.9,; // By JPP - 09/11/2006 - 16:00
        nTamColLbl :=  22.2   // By JPP - 09/11/2006 - 16:00

Private aCampos :={}

Begin Sequence
   // By JPP - 10/11/2006 - 15:00 - O array aCampos define a estrutura e tratamentos dos dados que serão editados em
   //                               uma tela MsDialog e montados com base neste Array.
   //           {"Nome do Campo",bValid                    ,bWhen            ,lObrigatorio, cTitulo                     ,lTrigger,lMemo ,nTamanho,cF3,cPicture}
   Aadd(aCampos,{"cSequen"   ,{|| .T.}                     ,{||.F.}          ,.F.         ,AvSx3("EE8_SEQUEN",AV_TITULO),        ,.F.   ,45      ,   ,AVSX3("EE9_SEQUEN", AV_PICTURE)})
   Aadd(aCampos,{"cCodDesc"  ,{|| .T.}                     ,{||.F.}          ,.F.         ,STR0090                      ,        ,.F.   ,100     ,   ,                               })  //"Cod/Descrição"
   If EECFlags("BOLSAS")
      Aadd(aCampos,{"cBolsa"    ,{|| .T.}                     ,{||.F.}          ,.F.         ,AVSX3("EE7_CODBOL",AV_TITULO),     ,.F.   ,45      ,   ,                               })
   EndIF
   Aadd(aCampos,{"cDataFix"  ,{|| (Vazio() .Or. AE105VldPrice("cDataFix"))},{|| .T.},.F.  ,AVSX3("EE8_MESFIX",AV_TITULO),        ,.F.   ,45      ,   ,AVSX3("EE8_MESFIX",AV_PICTURE) })
   Aadd(aCampos,{"nDiferencial",{|| .T.}                   ,{|| .T.}         ,.F.         ,AVSX3("EE8_DIFERE",AV_TITULO),        ,.F.   ,50      ,   ,AVSX3("EE8_DIFERE",AV_PICTURE) })
   Aadd(aCampos,{"dDtaCota"  ,{|| (Vazio() .Or. AE105VldPrice("dDtaCota"))},{|| .T.},.F.  ,AVSX3("EE8_DTCOTA",AV_TITULO),        ,.F.   ,45      ,   ,AVSX3("EE8_DTCOTA",AV_PICTURE) })
   Aadd(aCampos,{"dDtaFix"   ,{|| .T.}                     ,{|| .T.}         ,.F.         ,AVSX3("EE8_DTFIX ",AV_TITULO),        ,.F.   ,45      ,   ,AVSX3("EE8_DTFIX",AV_PICTURE)  })
   Aadd(aCampos,{"nQtdeFix"  ,{|| If(!Empty(cCodUnidLot), Eval(bSetQtd, 1), .T.) .And. VldPrice("nQtdeFix")},{|| .T.},.F.,AVSX3("EE8_QTDFIX",AV_TITULO),   ,.F.,50,   ,AVSX3("EE9_SLDINI",AV_PICTURE) })
   Aadd(aCampos,{"nQtdeLot"  ,{|| If(!Empty(cCodUnidLot),Eval(bSetQtd,2),.t.)},{|| .T.},.F.,AVSX3("EE8_QTDLOT",AV_TITULO),       ,.F.  ,50      ,   ,"@E 999,999,999.99"            })
   Aadd(aCampos,{"nVlCotacao",{|| Eval(bSetVal, 1)}        ,{|| .T.}         ,.F.         ,STR0091                      ,        ,.F.   ,60      ,   ,cPICTVALCT                     }) //"Vl.Cotação cents US$/LB"
   Aadd(aCampos,{"nValFix"   ,{|| Eval(bSetVal, 2)}        ,{|| .T.}         ,.F.         ,STR0100                      ,        ,.F.   ,60      ,   ,cPICTVALFX                     }) //"Preço Final cents US$/LB"
   // Fim Montagem do aCampos
   //Criar Objetos a serem utilizados na montagem da tela, junto com aCampos
   For nI := 1 To Len(aCampos)
       Private &("o"+aCampos[nI][1]) := 0
   Next
   // Fim Criação dos objetos

   cSequen      := AllTrim(WorkFix->EE9_SEQUEN)
   cCodDesc     := AllTrim(WorkFix->EE9_COD_I)+" / "+Memoline(WorkFix->EE9_VM_DES,60,1)
   nQtdeFix     := WorkFix->EE9_SLDINI
   cDataFix     := WorkFix->EE9_MESFIX
   nDiferencial := WorkFix->EE9_DIFERE
   dDtaCota     := WorkFix->EE9_DTCOTA
   nQtdeLot     := WorkFix->EE9_QTDLOT
   dDtaFix      := WorkFix->EE9_DTFIX
   nValFix      := WorkFix->EE9_PRECO

   If EE8->(dbSeek(xFilial("EE8")+WorkFix->EE9_PEDIDO+WorkFix->EE9_SEQUEN))
      nDiferencial := EE8->EE8_DIFERE
   EndIf

   If EECFlags("BOLSAS")
      If EE7->(DbSeek(xFilial("EE7")+WorkFix->EE9_PEDIDO))
         cBolsa := EE7->EE7_CODBOL
      EndIf
   EndIf

   If EasyEntryPoint("EECAE105") // By JPP - 09/11/2006 - 16:00
      ExecBlock("EECAE105",.F.,.F.,"ANTES_DIALOG_PRICE")
   EndIf

   /* By JPP - 13/11/2006 - 08:00 - A tela abaixo foi altera para permitir a customização e inclusão de novos campos.
   DEFINE MSDIALOG oDlg TITLE STR0088 FROM 9,0 TO nTamLinTela,nTamColTela OF oMainWnd //"Fixação de Item" // 31.2,45

      @ 1.0,0.3 To nTamLinLbl,nTamColLbl LABEL STR0089 //"Fixação de Preço"  // 11.9,22.2

      nLin := 1.8
      @ nLin,1.0 Say AVSX3("EE9_SEQUEN",AV_TITULO)
      @ nLin+=1,1.0 Say STR0090 //"Cod/Descrição"
      If EECFlags("BOLSAS")
         @ nLin+=1,1.0 Say AVSX3("EE7_CODBOL",AV_TITULO)
      EndIf
      @ nLin+=1,1.0 Say AVSX3("EE8_MESFIX",AV_TITULO)
      @ nLin+=1,1.0 Say AVSX3("EE8_DIFERE",AV_TITULO)
      @ nLin+=1,1.0 Say AVSX3("EE8_DTCOTA",AV_TITULO)
      @ nLin+=1,1.0 Say AVSX3("EE8_DTFIX ",AV_TITULO)
      @ nLin+=1,1.0 Say AVSX3("EE8_QTDFIX",AV_TITULO)
      @ nLin+=1,1.0 Say AVSX3("EE8_QTDLOT",AV_TITULO)
      @ nLin+=1,1.0 Say STR0091 //"Vl.Cotação cents US$/LB"
      @ nLin+=1,1.0 Say STR0100 //"Preço Final cents US$/LB"

      nLin := 1.8
      @ nLin,09 MSGET cSequen      SIZE 45,7   Picture AVSX3("EE9_SEQUEN", AV_PICTURE) When .F.
      @ nLin+=1,09 MSGET cCodDesc     SIZE 100,7  When .F.
      If EECFlags("BOLSAS")
         @ nLin+=1,09 MSGET cBolsa       SIZE 45,7  When .F.
      EndIf
      @ nLin+=1,09 MSGET cDataFix     SIZE 45,7   Picture AVSX3("EE8_MESFIX",AV_PICTURE) Valid (Vazio() .Or. AE105VldPrice("cDataFix"))
      @ nLin+=1,09 MSGET nDiferencial SIZE 50,7   Picture AVSX3("EE8_DIFERE",AV_PICTURE)
      @ nLin+=1,09 MSGET dDtaCota     SIZE 45,7   Picture AVSX3("EE8_DTCOTA",AV_PICTURE) Valid (Vazio() .Or. AE105VldPrice("dDtaCota"))
      @ nLin+=1,09 MSGET dDtaFix      SIZE 45,7   Picture AVSX3("EE8_DTFIX",AV_PICTURE)
      @ nLin+=1,09 MSGET nQtdeFix     SIZE 50,7   Picture AVSX3("EE9_SLDINI",AV_PICTURE) Valid If(!Empty(cCodUnidLot), Eval(bSetQtd, 1), .T.) .And. VldPrice("nQtdeFix")
      @ nLin+=1,09 MSGET nQtdeLot     SIZE 50,7   Picture "@E 999,999,999.99" Valid If(!Empty(cCodUnidLot),Eval(bSetQtd,2),.t.)
      @ nLin+=1,09 MSGET nVlCotacao   SIZE 60,7   Picture cPICTVALCT Valid Eval(bSetVal, 1)
      @ nLin+=1,09 MSGET nValFix     SIZE 60,7   Picture cPICTVALFX Valid Eval(bSetVal, 2)

      If EasyEntryPoint("EECAE105") // By JPP - 09/11/2006 - 16:00
         ExecBlock("EECAE105",.F.,.F.,"MONTANDO_DIALOG_PRICE")
      EndIf

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bOk, bCancel) CENTERED
   */
   // By JPP - 13/11/2006 - 08:00 - Nova tela que subistitui a anterior
   DEFINE MSDIALOG oDlg TITLE STR0089+" - "+STR0088 FROM 9,0 TO nTamLinTela,nTamColTela OF oMainWnd //"Fixação de Item" // 31.2,45
      aPos := PosDlg(oDlg)
      aPos[3] -= 15

      //@ 1.0,0.3 To nTamLinLbl,nTamColLbl LABEL STR0089 //"Fixação de Preço"  // 11.9,22.2

      AE109Gets(oDlg, aPos, aCampos)

      If EasyEntryPoint("EECAE105") // By JPP - 09/11/2006 - 16:00
         ExecBlock("EECAE105",.F.,.F.,"MONTANDO_DIALOG_PRICE")
      EndIf

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bOk, bCancel) CENTERED

   If nOpc = 1
      WorkFix->EE9_MESFIX := cDataFix
      WorkFix->EE9_DIFERE := nDiferencial
      WorkFix->EE9_DTCOTA := dDtaCota
      WorkFix->EE9_PRECO  := nValFix
      WorkFix->EE9_DTFIX  := dDtaFix
      WorkFix->EE9_QTDFIX := nQtdeFix
      WorkFix->EE9_QTDLOT := nQtdeLot
      WorkFix->EE9_SLDINI := nQtdeFix
      If EECFlags("BOLSAS")
         WorkFix->WK_VLCOT   := APPriceConv(7,nVlCotacao)
      Else
         WorkFix->WK_VLCOT   := nVlCotacao
      EndIf
      WorkFix->WK_FLAG    := "1" // Flag preco fixado ...
      lRet := .T.
      If EasyEntryPoint("EECAE105") // By JPP - 09/11/2006 - 16:00
         ExecBlock("EECAE105",.F.,.F.,"GRV_WORK_PRICE")
      EndIf
   EndIf

End Sequence

RestOrd(aSaveOrd)

Return(lRet)

/*
Funcao      : AE105VldPrice()
Parametros  : Nenhum
Retorno     : .t./.f.
Objetivos   : Validar os parametros informados na tela de fixação de preço.
Autor       : Alexsander Martins dos Santos.
Data/Hora   : 29/04/2004 às 15:22.
*/

Static Function AE105VldPrice(cCpo)

Local lRet       := .T.,;
      aParametro := {},;
      cCampos    := "",;
      aBolsas     := {{AvKey("NY","EX7_CODBOL"),"CENTS/LB"},{AvKey("BMF","EX7_CODBOL"),"US$/SC60"},{AvKey("LON","EX7_CODBOL"),"US$/TON"}},;
      i

Local nCot

Begin Sequence

Do Case
      Case cCpo == "cDataFix"
         If !Empty(dDtaCota)
            dDtaCota := CToD( "  /  /  " )
         EndIf
         If EECFlags("BOLSAS") .And. !Empty(cBolsa)
            If !AT150MesAno(cDataFix,cBolsa)
               lRet := .F.
               Break
            EndIf
         Else
            If !AT150MesAno(cDataFix)
               lRet := .F.
               Break
            EndIf
         EndIf
         Break

      Case cCpo == "dDtaCota"
         If EECFlags("BOLSAS") .And. !Empty(cDataFix) .And. !Empty(cBolsa)
            If !AT150MesAno(cDataFix,cBolsa,Month(dDtaCota))
               lRet := .F.
               Break
            EndIf

            If (nCot := BuscaVlCot(cDataFix,cBolsa,dDtaCota,EasyGParam("MV_AVG0032",,""))) = 0
               lRet := .f.
               Break
            EndIf

            If dDtaCota <> EX7->EX7_DATA .Or. EX7->EX7_MESANO <> cDataFix .Or. EX7->EX7_CODBOL <> cBolsa
               dDtaCota := EX7->EX7_DATA
               MsgInfo( STR0134 + ENTER + STR0135 )//"Não encontrada cotação para a data informada." "Foi selecionada automaticamente a data mais recente cadastrada no sistema para o periodo informado."
            EndIf

            /*
            EX7->(DbSetOrder(2))
            If !EX7->(DbSeek(xFilial("EX7")+cBolsa+DTOS(dDtaCota)))
               EX7->(DbSetOrder(1))
               If EX7->(DbSeek(xFilial("EX7")+cDataFix))
                  While EX7->(EX7_FILIAL == xFilial("EX7") .And. EX7_MESANO == cDataFix)
                     EX7->(DbSkip())
                  EndDo
                  EX7->(DbSkip(-1))
                  MsgInfo( STR0134 + ENTER + STR0135 )//"Não encontrada cotação para a data informada." "Foi selecionada automaticamente a data mais recente cadastrada no sistema para o periodo informado."
                  dDtaCota := EX7->EX7_DATA
               Else
                  MsgInfo(STR0136) //"Nenhuma cotação cadastrada para o período informado"
                  lRet := .F.
                  Break
               EndIf
            EndIf
            */

            x := AScan(aBolsas,{|x| x[1] == cBolsa})
            If aBolsas[x][2] == "US$/SC50"
               nVlCotacao := APPriceConv(2,nCot)
            ElseIf aBolsas[x][2] == "US$/SC60"
               nVlCotacao := APPriceConv(5,nCot)
            ElseIf aBolsas[x][2] == "US$/TON"
               nVlCotacao := APPriceConv(12,nCot)
            ElseIf aBolsas[x][2] == "CENTS/LB"
               nVlCotacao := nCot
            EndIf

         EndIf
         Break

   End Case


   If Empty(dDtaCota)
      If Ascan(aParametro,AVSX3("EE8_DTCOTA",AV_TITULO))=0
         Aadd(aParametro,AVSX3("EE8_DTCOTA",AV_TITULO))
      EndIf
   EndIf

   If Empty(dDtaFix)
      If Ascan(aParametro,AVSX3("EE8_DTFIX",AV_TITULO))=0
         Aadd(aParametro,AVSX3("EE8_DTFIX",AV_TITULO))
      EndIf
   EndIf

   If dDtaFix < dDtaCota
      If Ascan(aParametro,AVSX3("EE8_DTFIX",AV_TITULO))=0
         Aadd(aParametro,AVSX3("EE8_DTFIX",AV_TITULO))
      EndIf
   EndIf

   If nQtdeFix <=0
      If Ascan(aParametro,AVSX3("EE8_QTDFIX",AV_TITULO))=0
         Aadd(aParametro,AVSX3("EE8_QTDFIX",AV_TITULO))
      EndIf
   EndIf

   If nVlCotacao <=0
      If Ascan(aParametro, STR0101) = 0 //"Vl.Cotação"
         Aadd(aParametro, STR0101) //"Vl.Cotação"
      EndIf
   EndIf

   If nValFix <= 0
      If Ascan(aParametro, STR0102) = 0 //"Preço Final"
         Aadd(aParametro, STR0102) //"Preço Final"
      EndIf
   EndIf

   If nQtdeLot <= 0
      If Ascan(aParametro,AVSX3("EE8_QTDLOT",AV_TITULO))=0
         Aadd(aParametro,AVSX3("EE8_QTDLOT",AV_TITULO))
      EndIf
   EndIf

   If nQtdeFix > WorkFix->EE9_SLDINI
      If Ascan(aParametro,AVSX3("EE8_QTDFIX",AV_TITULO))=0
         Aadd(aParametro,AVSX3("EE8_QTDFIX",AV_TITULO))
      EndIf
   EndIf

   If Len(aParametro) > 0

      For i:=1 To Len(aParametro)
         cCampos+=aParametro[i]+ENTER
      Next

      MsgStop(STR0103 +ENTER+; //"Problema"
              STR0104 +Replic(ENTER,2)+; //"Parametro(s) inválido(s) para a fixação de preço."
              STR0095 +ENTER+; //"Solução:"
              STR0096 +Replic(ENTER,2)+; //"Verifique o(s) seguinte(s) campo(s):"
              cCampos, STR0019) //"Atenção"

      lRet := .F.

   EndIf

End Sequence

Return lRet


/*
Funcao    : Ae105MesAno(cMesAno)
Parametros: cMesAno => Mes/Ano para validação.
Objetivos : Validação do mes e ano da cotação da bolsa.
Autor     : Jeferson Barros Jr.
Data/Hora : 25/03/04 - 18:08
Revisao   :
Obs.      :
*/
/*
*-------------------------------------*
Static Function Ae105MesAno(cMesAnoFix)
*-------------------------------------*
Local lRet:=.T.,cOldArea:=select(), nMes:=0, nAno:=0

Begin sequence
   If Empty(cMesAnoFix)
      MsgStop(STR0076,STR0039) //"Informe o mês e o ano de cotação da bolsa ! "###"Aviso"
      lRet:=.f.
      Break
   EndIf

   nMes:= Val(SubStr(cMesAnoFix,1,2))

   If Empty(SubStr(cMesAnoFix,3,2))
      MsgStop(STR0077,STR0039) //"Informe o ano da cotação da bolsa ! "###"Aviso"
      lRet:=.f.
      Break
   Else
      nAno:= Val(SubStr(cMesAnoFix,3,2))
   EndIf

   If nMes < 1 .Or. nMes > 12
      MsgStop(STR0078,STR0039) //"Mês da cotação da bolsa inválido ! "###"Aviso"
      lRet:=.f.
      Break
   EndIf

   If nAno < 0
      MsgStop(STR0079,STR0039) //"Ano da cotação da bolsa inválido ! "###"Aviso"
      lRet:=.f.
   EndIf

   EX7->(DbSetOrder(1))
   If !EX7->(DbSeek(xFilial("EX7")+Dtos(dDtCotacao)+AvKey(AllTrim(cMesAnoFix),"EX7_MESANO")))
      MsgStop(STR0080,STR0019) //"Não existe cotação cadastrada para esta data, mes e ano."###"Atenção"
      lRet:=.f.
   EndIf

End Sequence

DbSelectArea(cOldArea)

Return lRet
*/

/*
Funcao    : Ae105VldFix()
Parametros: Nenhum.
Retorno   : .f./.t.
Objetivos : Validação das informações de fixação de preco.
Autor     : Jeferson Barros Jr.
Data/Hora : 26/03/04 - 09:04
Revisao   :
Obs.      :
*/
*-------------------------------*
Static Function Ae105VldFix(lFix)
*-------------------------------*
Local lRet:=.t.

Default lFix := .t.

Begin Sequence

   If lFix // Opção de fixaçao de preco.

      /*
      If Empty(dDtCotacao)
         MsgStop(STR0081+ENTER+; //"Dados incompletos para fixação de preço."
                 STR0072,STR0019) //"Informe a Data de Cotação."###"Atenção"
         lRet:=.f.
         Break
      EndIf
      */

      /*
      If Empty(cMesFix)
         MsgStop(STR0081+ENTER+; //"Dados incompletos para fixação de preço."
                 STR0082,STR0019) //"Informe o Mês/Ano para cálculo do preço final."###"Atenção"
         lRet:=.f.
      EndIf
      */

   Else // Opcao de estorno da fixação.

      If MsgYesNo(STR0083,STR0019) //"Confirma o estorno da fixação de preço?"###"Atenção"
         Ae105EstFix()
      Else
         lRet:=.f.
      EndIf

   EndIf

End Sequence

Return lRet

/*
Funcao      : Ae105EstFix()
Parametros  : Nenhum
Retorno     : .t.
Objetivos   : Estornar a fixação de preço.
Autor       : Jeferson Barros Jr.
Data/Hora   : 26/03/2004 14:25.
Revisao     :
Obs.        :
*/
*---------------------------*
Static Function Ae105EstFix()
*---------------------------*
Local lRet:=.t.

Begin Sequence

   WorkFix->(DbGoTop())
   Do While WorkFix->(!Eof())
      // ** Caso algum item estiver sem fixação considera que todos não estão fixados.
      If Empty(WorkFix->EE9_PRECO)
         Exit
      EndIf

      WorkFix->EE9_PRECO := 0
      WorkFix->(DbSkip())
   EndDo
   WorkFix->(DbGoTop())

End Sequence

Return lRet

/*
Funcao      : Ae105CallPrecoI(cFil, lMsg)
Parametros  : cFil - Filial a Ser atualiazada.
              lMsg - .T. = Apresenta mensagem.
                     .F. = Não apresenta mensagem.
Retorno     : .t.
Objetivos   : Preparar Variáveis de Memória e WorkIp para chamada da função ae100PrecoI()
              Atualizar embarque com os valores calculados.
Autor       : Jeferson Barros Jr.
Data/Hora   : 26/03/2004 09:55.
Revisao     :
Obs.        : Considera que o EEC Esteja Posicionado.
*/
*----------------------------*
Function Ae105CallPrecoI(cFil, lMsg)
*----------------------------*
Local lRet:=.t., aOrd:=SaveOrd({"EEC","EE9","EEB","SX3"})
Local lBuildWork := .f., cNomAux, aSemSx3:={}, z
Local lBuildWkAg := .f., cNomArq2 // By JPP - 21/06/2005 - 09:10

Private cMarca

Private lIntDraw   := EasyGParam("MV_EEC_EDC",,.F.)
Private lOkEE9_ATO := SX3->(dbSetOrder(2), dbSeek("EE9_ATOCON"))
Private lOkEE9_CC  := SX3->(dbSetOrder(2), dbSeek("EE9_CC"))

Default cFil = xFilial("EEC") // Considera que o EE9 sempre terá a mesma filial do EEC.
Default lMsg := .T.

If Type("lIntegra") <> "L"
   lIntegra := IsIntFat()
EndIf

Begin Sequence

   If Select() == 0
      DbSelectArea("EE9")
   EndIf

   cMarca := GetMark()

   If Select("WorkIP") = 0
      lBuildWork := .t.

      aCampos := Array(EE9->(FCount()))

      aSemSx3 := {{"WP_RECNO" ,"N",7,0},;
                  {"WP_FLAG"  ,"C",2,0},;
                  {"WP_SLDATU","N",15,3},;
                  {"WP_OLDINI",AVSX3("EE9_SLDINI",AV_TIPO),AVSX3("EE9_SLDINI",AV_TAMANHO),AVSX3("EE9_SLDINI",AV_DECIMAL)} }

      // ** JPM - 14/04/05 - Inclusão de novos campos nos itens.
      If EE9->(FieldPos("EE9_PRCUN"))  > 0 .And. EE9->(FieldPos("EE9_VLFRET")) > 0 .And. ;
         EE9->(FieldPos("EE9_VLSEGU")) > 0 .And. EE9->(FieldPos("EE9_VLOUTR")) > 0 .And. ;
         EE9->(FieldPos("EE9_VLDESC")) > 0

         aAdd(aSemSx3,{"EE9_PRCUN" ,AVSX3("EE9_PRCUN" ,AV_TIPO),AVSX3("EE9_PRCUN" ,AV_TAMANHO),AVSX3("EE9_PRCUN" ,AV_DECIMAL)})
         aAdd(aSemSx3,{"EE9_VLFRET",AVSX3("EE9_VLFRET",AV_TIPO),AVSX3("EE9_VLFRET",AV_TAMANHO),AVSX3("EE9_VLFRET",AV_DECIMAL)})
         aAdd(aSemSx3,{"EE9_VLSEGU",AVSX3("EE9_VLSEGU",AV_TIPO),AVSX3("EE9_VLSEGU",AV_TAMANHO),AVSX3("EE9_VLSEGU",AV_DECIMAL)})
         aAdd(aSemSx3,{"EE9_VLOUTR",AVSX3("EE9_VLOUTR",AV_TIPO),AVSX3("EE9_VLOUTR",AV_TAMANHO),AVSX3("EE9_VLOUTR",AV_DECIMAL)})
         aAdd(aSemSx3,{"EE9_VLDESC",AVSX3("EE9_VLDESC",AV_TIPO),AVSX3("EE9_VLDESC",AV_TAMANHO),AVSX3("EE9_VLDESC",AV_DECIMAL)})
      Else
         aAdd(aSemSx3,{"EE9_PRCUN" ,AVSX3("EE9_PRECO" ,AV_TIPO),AVSX3("EE9_PRECO" ,AV_TAMANHO),AVSX3("EE9_PRECO" ,AV_DECIMAL)})
         aAdd(aSemSx3,{"EE9_VLFRET",AVSX3("EE9_PRCTOT",AV_TIPO),AVSX3("EE9_PRCTOT",AV_TAMANHO),AVSX3("EE9_PRCTOT",AV_DECIMAL)})
         aAdd(aSemSx3,{"EE9_VLSEGU",AVSX3("EE9_PRCTOT",AV_TIPO),AVSX3("EE9_PRCTOT",AV_TAMANHO),AVSX3("EE9_PRCTOT",AV_DECIMAL)})
         aAdd(aSemSx3,{"EE9_VLOUTR",AVSX3("EE9_PRCTOT",AV_TIPO),AVSX3("EE9_PRCTOT",AV_TAMANHO),AVSX3("EE9_PRCTOT",AV_DECIMAL)})
         aAdd(aSemSx3,{"EE9_VLDESC",AVSX3("EE9_PRCTOT",AV_TIPO),AVSX3("EE9_PRCTOT",AV_TAMANHO),AVSX3("EE9_PRCTOT",AV_DECIMAL)})
      EndIf
      // **

      /*
      AMS - 14/09/2005. Adicionado novos campos no array aSemSX3, utilizando as mesmas consistências
                        da função AE102CRIAWORK.
                        Obs: Esta alteração deve ser revisada, com a intenção de utilizar uma unica
                        forma de preparação de ambiente.
      */
      If lIntDraw .and. lOkEE9_ATO
         cCpo := "EE9_SEQED3"
         aAdd(aSemSx3,{cCpo,AVSX3(cCpo,2),AVSX3(cCpo,3),AVSX3(cCpo,4)})

         cCpo := "EE9_QT_AC"
         aAdd(aSemSx3,{cCpo,AVSX3(cCpo,2),AVSX3(cCpo,3),AVSX3(cCpo,4)})

         cCpo := "EE9_VL_AC"
         aAdd(aSemSx3,{cCpo,AVSX3(cCpo,2),AVSX3(cCpo,3),AVSX3(cCpo,4)})
      EndIf

      If lOkEE9_CC
         aOrd2 := SaveOrd("SX3",2)
         cCpo  := "EE9_CC"
         IF SX3->(dbSeek(AvKey(cCpo,"X3_CAMPO"))) .And. ! X3Uso(SX3->X3_USADO)
            aAdd(aSemSX3,{cCpo,AVSX3(cCpo,2),AVSX3(cCpo,3),AVSX3(cCpo,4)})
         Endif

         cCpo := "EE9_DESCCC"
         IF SX3->(dbSeek(AvKey(cCpo,"X3_CAMPO"))) .And. ! X3Uso(SX3->X3_USADO)
            aAdd(aSemSX3,{cCpo,AVSX3(cCpo,2),AVSX3(cCpo,3),AVSX3(cCpo,4)})
         Endif
         RestOrd(aOrd2)
      EndIf

      IF lIntegra
         aOrd2 := SaveOrd("SX3",2)
         cCpo  := "EE9_NF"
         IF SX3->(dbSeek(AvKey(cCpo,"X3_CAMPO"))) .And. ! X3Uso(SX3->X3_USADO)
            aAdd(aSemSX3,{cCpo,AVSX3(cCpo,2),AVSX3(cCpo,3),AVSX3(cCpo,4)})
         Endif

         cCpo := "EE9_SERIE"
         IF SX3->(dbSeek(AvKey(cCpo,"X3_CAMPO"))) .And. ! X3Uso(SX3->X3_USADO)
            aAdd(aSemSX3,{cCpo,AVSX3(cCpo,2),AVSX3(cCpo,3),AVSX3(cCpo,4)})
         Endif

         // ** JPM - 27/12/05 - Geração de notas fiscais em várias filiais.
         If EECFlags("FATFILIAL")
            AddNaoUsado(aSemSx3,"EE9_FIL_NF")
         EndIf
         // **

         RestOrd(aOrd2)
      Endif

      aOrd2 := SaveOrd("SX3",2)
      cCpo  := "EE9_PERCOM"
      IF SX3->(dbSeek(AvKey(cCpo,"X3_CAMPO"))) .And. ! X3Uso(SX3->X3_USADO)
         aAdd(aSemSX3,{cCpo,AVSX3(cCpo,2),AVSX3(cCpo,3),AVSX3(cCpo,4)})
      Endif
      cCpo  := "EE9_UNIDAD"
      IF SX3->(dbSeek(AvKey(cCpo,"X3_CAMPO"))) .And. ! X3Uso(SX3->X3_USADO)
         aAdd(aSemSX3,{cCpo,AVSX3(cCpo,2),AVSX3(cCpo,3),AVSX3(cCpo,4)})
      Endif
      RestOrd(aOrd2)
      /*
      AMS - 14/09/2005. Fim da alteração para adição de campos
      */

      cNomAux:=E_CriaTrab("EE9",aSemSX3,"WorkIP")

      If lMsg
         IndRegua("WorkIP",cNomAux+TEOrdBagExt(),"EE9_PEDIDO+EE9_SEQUEN")
      Else
         WorkIp->(dbCreateIndex(cNomAux+TEOrdBagExt(), "EE9_PEDIDO+EE9_SEQUEN", {|| EE9_PEDIDO+EE9_SEQUEN}))
      EndIf

   EndIf

   // By JPP - 21/06/2005 - 09:10
   // *** Gera Work de Agentes ...
  If Select("WorkAg") = 0
      lBuildWkAg := .t.
      aSemSX3  := { {"WK_RECNO", "N", 7, 0},{"EEB_OCORRE","C",1,0} }
      AddNaoUsado(aSemSX3,"EEB_FOBAGE")
      AddNaoUsado(aSemSX3,"EEB_TOTCOM")

      aCampos  := Array(EEB->(FCount()))

      cNomArq2 := E_CriaTrab("EEB",aSemSX3,"WorkAg")  // Criacao do arquivo de Trabalho
      If EECFlags("COMISSAO")
         If lMsg
            IndRegua("WorkAg",cNomArq2+TEOrdBagExt(),"EEB_CODAGE+EEB_TIPOAG+EEB_TIPCOM","AllwayTrue()",;
                     "AllwaysTrue()",STR0010) //"Processando Arquivo Temporário ..."
         Else
            WorkAg->(dbCreateIndex(cNomArq2+TEOrdBagExt(), "EEB_CODAGE+EEB_TIPOAG+EEB_TIPCOM", {|| EEB_CODAGE+EEB_TIPOAG+EEB_TIPCOM}))
         EndIf
      Else
         If lMsg
            IndRegua("WorkAg",cNomArq2+TEOrdBagExt(),"EEB_CODAGE+EEB_TIPOAG","AllwayTrue()",;
                     "AllwaysTrue()",STR0010) //"Processando Arquivo Temporário ..."
         Else
            WorkAg->(dbCreateIndex(cNomArq2+TEOrdBagExt(), EEB_CODAGE+EEB_TIPOAG, {|| EEB_CODAGE+EEB_TIPOAG}))
         EndIf
      EndIf

      EEB->(DbSetOrder(1))
      EEB->(DbSeek(cFil+Avkey(EEC->EEC_PREEMB,"EEC_PREEMB"+OC_EM)))

      Do While EEB->(!Eof()) .And. EEB->EEB_FILIAL == cFil .And.;
                                   EEB->EEB_PEDIDO == EEC->EEC_PREEMB .And.;
                                   EEB->EEB_OCORRE == OC_EM
         WorkAg->(DbAppend())
         AVReplace("EEB","WorkAg")
         EEB->(DbSkip())
      EndDo

   EndIf

   Inclui := .t.

   // ** Carrega as variáveis de memória.
   For z := 1 TO EEC->(FCount())
      M->&(EEC->(FieldName(z))) := EEC->(FieldGet(z))
   Next

   // ** Carrega a WorkIp.
   WorkIp->(AvZap())

   EE9->(DbSetOrder(2))
   EE9->(DbSeek(cFil+EEC->EEC_PREEMB))

   Do While EE9->(!Eof()) .And. EE9->EE9_FILIAL == cFil .And.;
                                EE9->EE9_PREEMB == EEC->EEC_PREEMB
      WorkIp->(DbAppend())
      AVReplace("EE9","WorkIp")
      WorkIP->WP_FLAG := cMarca
      EE9->(DbSkip())
   EndDo

   ae100PrecoI(, .F.) // Recalcula os totais do processo.

   // ** Atualiza a capa.
   If EEC->(RecLock("EEC",.f.))
      AvReplace("M","EEC")
      EEC->EEC_FILIAL := cFil
      EEC->(MsUnLock())
   EndIf

   // ** Atualiza os itens.
   EE9->(DbSetOrder(3))
   WorkIp->(DbGoTop())
   Do While WorkIp->(!Eof())
      If EE9->(DbSeek(cFil+WorkIp->EE9_PREEMB+WorkIp->EE9_SEQEMB))
         If EE9->(RecLock("EE9",.f.))
            AvReplace("WorkIp","EE9")
            EE9->EE9_FILIAL := cFil
            EE9->(MsUnLock())
         EndIf
      EndIf
      WorkIp->(DbSkip())
   EndDo

   If lBuildWork
      WorkIp->(E_EraseArq(cNomAux))
   EndIf
   If lBuildWkAg    // By JPP - 21/06/2005 - 09:45
      WorkAg->(E_EraseArq(cNomArq2))
   EndIf
End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : Ae105AtuItPed().
Parametros  : lFix - .t. - Fixação.
                     .f. - Estorno.
Retorno     : .t.
Objetivos   : Atualizar o item no pedido de exportaçao com as informações da fixação de preço.
Autor       : Jeferson Barros Jr.
Data/Hora   : 02/04/2004 11:51.
Revisao     :
Obs.        :
*/
/*
*---------------------------------*
Static Function Ae105AtuItPed(lFix)
*---------------------------------*
Local lRet:=.t., aOrd:=SaveOrd({"EE8"})
Local aMemoItem :={{"EE8_DESC","EE8_VM_DES"}}
Local nSaldo:=0, nRecOld:=0, j, i

Begin Sequence

   EE8->(DbSetOrder(1))
   If EE8->(DbSeek(xFilial("EE8")+EE9->EE9_PEDIDO+EE9->EE9_SEQUEN))

      If lFix // Fixação.
         // ** Verifica se o item faz parte de um embarque parcial.
         nSaldo := (EE8->EE8_SLDINI - EE9->EE9_SLDINI)

         If Empty(nSaldo)
            If EE8->(RecLock("EE8",.f.))
               EE8->EE8_DTFIX  := dDataBase
               EE8->EE8_DTCOTA := dDataBase
               EE8->EE8_MESFIX := cMesFix
               EE8->EE8_PRECO  := EE9->EE9_PRECO
            EndIf
         Else // Item com embarque parcial. Neste caso um novo item é gerado com a qtde. fixada.

            nRecOld:= EE8->(RecNo())

            nPercPai   := Round((EE8->EE8_SLDATU/EE8->EE8_SLDINI),2) // Percentual para o item pai ...
            nPercFilho := Round(1-nPercPai,2) // Percentual para o item filho ...

            For j:=1 TO EE8->(FCount())
               M->&(EE8->(FieldName(j))) := EE8->(FieldGet(j))
            Next

            For i:=1 To Len(aMemoItem)
               If EE8->(FieldPos(aMemoItem[i][1])) > 0
                  M->&(aMemoItem[i][2]) := MSMM(EE8->&(aMemoItem[i][1]),TAMSX3(aMemoItem[i][2])[1],,,LERMEMO)
               EndIf
            Next

            M->EE8_SLDINI := EE9->EE9_SLDINI
            M->EE8_PRECO  := EE9->EE9_PRECO
            M->EE8_SLDATU := 0
            M->EE8_DTFIX  := dDataBase
            M->EE8_DTCOTA := dDataBase
            M->EE8_MESFIX := cMesFix
            M->EE8_QTDEM1 := Round(nPercFilho*EE8->EE8_QTDEM1,AVSX3("EE8_QTDEM1",AV_DECIMAL))
            M->EE8_PSBRTO := Round(nPercFilho*EE8->EE8_PSBRTO,AVSX3("EE8_PSBRTO",AV_DECIMAL))
            M->EE8_PSLQTO := Round(nPercFilho*EE8->EE8_PSLQTO,AVSX3("EE8_PSLQTO",AV_DECIMAL))
            M->EE8_SEQUEN := Str(Val(EE8->EE8_SEQUEN)+1,AvSX3("EE8_SEQUEN",AV_TAMANHO),0)
            M->EE8_STFIX  := "2"

            If EE8->(RecLock("EE8",.t.))
               AvReplace("M","EE8")

               EE8->EE8_FILIAL := xFilial("EE8")

               For i:=1 To Len(aMemoItem)
                  If EE8->(FieldPos(aMemoItem[i][1])) > 0
                     MSMM(,TAMSX3(aMemoItem[i][2])[1],,M->&(aMemoItem[i][2]),INCMEMO,,,"EE8",aMemoItem[i][1])
                  EndIf
               Next
               EE8->(MsUnLock())

               // ** Atualiza a sequencia do item no EE9.
               EE9->EE9_SEQUEN := EE8->EE8_SEQUEN
            EndIf

            EE8->(DbGoTo(nRecOld))

            // ** Atualiza o item de origem dos dados
            If EE8->(RecLock("EE8",.f.))
               EE8->EE8_SLDINI := EE8->EE8_SLDATU
               EE8->EE8_PSBRTO := Round(nPercPai*EE8->EE8_PSBRTO,AVSX3("EE8_PSBRTO",AV_DECIMAL))
               EE8->EE8_PSLQTO := Round(nPercPai*EE8->EE8_PSLQTO,AVSX3("EE8_PSLQTO",AV_DECIMAL))
               EE8->EE8_QTDEM1 := Round(nPercPai*EE8->EE8_QTDEM1,AVSX3("EE8_QTDEM1",AV_DECIMAL))
               EE8->(MsUnLock())
            EndIf
         EndIf

      Else // Estorno.
         If EE8->(RecLock("EE8",.f.))
            EE8->EE8_DTFIX  := AvCtoD("")
            EE8->EE8_DTCOTA := AvCtoD("")
            EE8->EE8_MESFIX := ""
            EE8->EE8_PRECO  := 0
         EndIf
      EndIf

      // ** Chama a ap100PrecoI() para atualização dos totais da capa e dos itens do pedido.
      EE7->(DbSetOrder(1))
      If EE7->(DbSeek(xFilial("EE7")+EE9->EE9_PEDIDO))
         Ap105CallPrecoI()
      EndIf
   EndIf

End Sequence

RestOrd(aOrd)

Return lRet
*/

/*
Função      : AE105FixItem
Objetivo    : Fixação de preço de um item
Parametro   : cEmbarque := Nro. do Embaque
              cSeqEmb   := Sequencia do embarque.
              nQtdFix   := Qtde Fixada na unidade de medida do item
              nQtdLot   := Qtde Fixada em Lots
              nPrcFix   := Preço fixado na unidade de medida da bolsa NY (cents US$ per LB)
              cMesAno   := Mês/Ano de fixação
              dDtFix    := Data da fixação
              dDtCot    := Data da cotação
              nDif      := Diferencial

Retorno     : Nenhum
Autor       : Cristiano A. Ferreira
Data e Hora : 25/04/2004 - 17:43
Obs.        : Após a fixação dos itens, a função AP100CallPrecoI deve ser executada para atualizar
              os totais do processo.
Revisão     : Alexsander Martins dos Santos - 29/04/2004 às 11:23.
*/

Function AE105FixItem(cEmbarque, cSeqEmb, nQtdFix, nQtdLot, nPrcFix, cMesAno, dDtFix, dDtCot, nDif)

Local aOrd        := SaveOrd({"EE9","EEC","EE8"})
Local cLastSeqEmb := ""
Local cLastSequen := ""
Local nCont       := 0
Local nRecEE9     := 0
Local nRecEE8     := 0

Local nPercPai    := 0
Local nPercFilho  := 0

Local cUM_Bolsa   := EasyGParam("MV_AVG0062",,""), cUM_Prc
Local nPrcBolsa   := nPrcFix

Begin Sequence

   EEC->(dbSetOrder(1))
   IF ! EEC->(dbSeek(xFilial()+AvKey(cEmbarque,"EE9_PREEMB")))
      Break
   Endif

   EE9->(dbSetOrder(3))
   IF ! EE9->(dbSeek(xFilial()+AvKey(cEmbarque,"EE9_PREEMB")+AvKey(cSeqEmb,"EE9_SEQEMB")))
      Break
   Endif

   // Converte para U.M. do Item.
   If !EECFlags("CAFE") .Or. !Ap104VerPreco()
      IF !Empty(cUM_Bolsa)
         cUM_Prc := EE9->EE9_UNPRC
         IF Empty(cUM_Prc)
            cUM_Prc := EE9->EE9_UNIDAD
         Endif
         nPrcFix := AvTransUnidad(cUM_Bolsa,cUM_Prc,EE9->EE9_COD_I,nPrcFix)
      Endif
   EndIf

   IF nQtdFix == EE9->EE9_SLDINI
      EE9->(RecLock("EE9", .F.))
      EE9->EE9_PRECO   := nPrcFix
      //EE8->EE8_QTDLOT  := nQtdLot
      //EE8->EE8_MESFIX  := cMesAno
      //EE8->EE8_DTFIX   := dDtFix
      //EE8->EE8_DTCOTA  := dDtCot
      //EE8->EE8_DIFERE  := nDif
      EE9->EE9_PRECOI  := EE9->EE9_PRECO

      If Ap104VerPreco() .and. EECFlags("CAFE")
         nPrcFix          := EE9->EE9_PRECO
         /*
         EE9->EE9_PRECO   := APPriceConv(7, nPrcFix) // Conv p/ US$/Saca 50kg
         EE9->EE9_PRECO2  := APPriceConv(8, nPrcFix) // Conv p/ US$/Saca 60kg
         EE9->EE9_PRECO3  := nPrcFix                 // Já está em cents/Libra
         EE9->EE9_PRECO4  := APPriceConv(9, nPrcFix) // Conv p/ US$/Tonelada
         */
         EE9->EE9_PRECO3  := nPrcFix                 // Já está em cents/Libra
         Ap104GatPreco("EE9_PRECO3",.F.,"EE9")
      Endif

      IF EasyEntryPoint("EECAE105") // FJH - 10/10/05 - CRIANDO PTO DE ENTRADA
         EXECBLOCK("EECAE105",.F.,.F.,"GRVSSLD")
      ENDIF
      EE9->(MSUnLock())

   Else // ** Existe Saldo na quantidade ...

      //Returna a ultima sequencia de item do embarque.
      nRecEE9 := EE9->(RecNo())
      EE9->(AVSeekLast(xFilial()+EEC->EEC_PREEMB))
      cLastSeqEmb := EE9->EE9_SEQEMB
      EE9->(dbGoTo(nRecEE9))

      //Retorna a ultima sequencia do item do pedido.
      EE8->(dbSetOrder(1))
      nRecEE8 := EE8->(RecNo())
      EE8->(AVSeekLast(xFilial()+EE9->EE9_PEDIDO))
      cLastSequen := EE8->EE8_SEQUEN
      EE8->(dbGoTo(nRecEE8))

      // ** Gera um novo registro com o mesmo item com a quantidade de saldo ...
      For nCont := 1 To EE9->(FCount())
         M->&(EE9->(FieldName(nCont))) := EE9->(FieldGet(nCont))
      Next

      // ** Faz o rateio para a qtde de embalagens e pesos
      nPercPai   := Round((nQtdFix/EE9->EE9_SLDINI),15) // Percentual para o item pai ...
      nPercFilho := Round(1-nPercPai,15) // Percentual para o item filho ...

      // ** Gera novo item filho com o saldo da fixação do item pai ... (FILHO)
      EE9->(RecLock("EE9", .T.))
      AvReplace("M", "EE9")

      //EE8->EE8_DTFIX  := AVCTOD("  /  /  ")
      EE9->EE9_SLDINI -= nQtdFix // Subtrai a quantidade já fixada ...
//    EE9->EE9_SLDATU := M->EE9_SLDATU
      EE9->EE9_PSBRTO := Round(nPercFilho*EE9->EE9_PSBRTO, AVSX3("EE9_PSBRTO",AV_DECIMAL))
      EE9->EE9_PSLQTO := Round(nPercFilho*EE9->EE9_PSLQTO, AVSX3("EE9_PSLQTO",AV_DECIMAL))
      EE9->EE9_QTDEM1 := Round(nPercFilho*EE9->EE9_QTDEM1, AVSX3("EE9_QTDEM1",AV_DECIMAL))

      If EE9->(FieldPos("EE9_VLPVIN")) > 0
         EE9->EE9_VLPVIN := Round(nPercFilho*EE9->EE9_VLPVIN, AVSX3("EE9_VLPVIN",AV_DECIMAL))
      EndIf

      // Grava a sequencia do item pai...
      //EE8->EE8_ORIGEM := EE8->EE8_SEQUEN
      EE9->EE9_SEQEMB := Str(Val(cLastSeqEmb)+1 ,AVSX3("EE9_SEQEMB", AV_TAMANHO), 0)
      EE9->EE9_SEQUEN := Str(Val(cLastSequen)+1 ,AVSX3("EE9_SEQUEN", AV_TAMANHO), 0)

      EE9->(MSUnLock())

      // ** Atualiza o item fixado ... (PAI)
      EE9->(dbGoTo(nRecEE9))

      EE9->(RecLock("EE9", .F.))

      EE9->EE9_SLDINI  := nQtdFix
      EE9->EE9_PRECO   := nPrcFix
      //EE9->EE9_QTDLOT  := nQtdLot
      //EE9->EE9_MESFIX  := cMesAno
      //EE9->EE9_DTFIX   := dDtFix
      //EE9->EE9_DTCOTA  := dDtCot
      //EE9->EE9_DIFERE  := nDif
      //EE9->EE9_ORIGEM  := EE9->EE9_SEQUEN

      EE9->EE9_PSBRTO := Round(nPercPai*EE9->EE9_PSBRTO,AVSX3("EE9_PSBRTO",AV_DECIMAL))
      EE9->EE9_PSLQTO := Round(nPercPai*EE9->EE9_PSLQTO,AVSX3("EE9_PSLQTO",AV_DECIMAL))
      EE9->EE9_QTDEM1 := Round(nPercPai*EE9->EE9_QTDEM1,AVSX3("EE9_QTDEM1",AV_DECIMAL))

      If EE9->(FieldPos("EE9_VLPVIN")) > 0
         EE9->EE9_VLPVIN := Round(nPercPai*EE9_VLPVIN, AVSX3("EE9_VLPVIN",AV_DECIMAL))
      EndIf

      EE9->EE9_PRECOI := EE9->EE9_PRECO

      If Ap104VerPreco() .and. EECFlags("CAFE")
         nPrcFix          := EE9->EE9_PRECO
         /*
         EE9->EE9_PRECO   := APPriceConv(7, nPrcFix) // Conv p/ US$/Saca 50kg
         EE9->EE9_PRECO2  := APPriceConv(8, nPrcFix) // Conv p/ US$/Saca 60kg
         EE9->EE9_PRECO3  := nPrcFix                 // Já está em cents/Libra
         EE9->EE9_PRECO4  := APPriceConv(9, nPrcFix) // Conv p/ US$/Tonelada
         */
         EE9->EE9_PRECO3  := nPrcFix                 // Já está em cents/Libra
         Ap104GatPreco("EE9_PRECO3",.F.,"EE9")
      Endif

      IF EasyEntryPoint("EECAE105") // FJH - 10/10/05 - CRIANDO PTO DE ENTRADA
         EXECBLOCK("EECAE105",.F.,.F.,"GRVCSLD")
      ENDIF
      EE9->(MSUnlock())

   EndIf

   //Atualização do Item do Pedido.
   AP105FixItem(WorkFix->EE9_PEDIDO, WorkFix->EE9_SEQUEN, nQtdFix, nQtdLot, nPrcFix, cMesAno, dDtFix, dDtCot, nDif,,0)
End Sequence

RestOrd(aOrd)

Return (NIL)

/*
Função   : VldPrice(cCpo)
Objetivo : Validar a Qtde a fixar p/ ser multipla pela qtde de embalagem.
*/

Static Function VldPrice(cCpo)

Local lRet := .t.,;
      nQE  := 0,;
      lRetBlock

Begin Sequence

   Do Case

      Case cCpo == "nQtdeFix"
         nQE := WorkFix->EE9_QE
         IF (nQtdeFix % nQE) <> 0
            MsgInfo(STR0105, STR0019) //"Quantidade deve ser multipla pela qtde de embalagem!"###"Atenção"
            lRet := .F.
            Break
         Endif

         IF EasyEntryPoint("EECAE105")
            lRetBlock := ExecBlock("EECAE105", .F., .F., "VLDQTDEFIX")
            IF ValType(lRetBlock) == "L"
               lRet := lRetBlock
            Endif
         Endif

   End Case

End Sequence

Return lRet

/*
Funcao      : AE105VldOffShore().
Parametros  : nOpc - Opção da manutenção (Incluir/Alterar/Excluir).
Retorno     : .t./.f.
Objetivos   : Validar informações da filial brasil contra a filial de intermediação.
Autor       : Jeferson Barros Jr.
Data/Hora   : 29/06/2004 15:57.
Revisao     :
Obs.        :
*/
*--------------------------------------*
Function AE105VldOffShore(nOpc,lIsFilBr)
*--------------------------------------*
Local lRet:=.t., aOrd:=SaveOrd({"EEC"}), nRecEEC:=0
//Local cFilBr:=AvKey(EasyGParam("MV_AVG0023",,""),"EEC_FILIAL"),;
//      cFilEx:=AvKey(EasyGParam("MV_AVG0024",,""),"EEC_FILIAL")
Local cMsg
Local lEmbarcado := .f., lTemAdiantamento := .f., lCancelado := .f.

Default lIsFilBr := .t.

If Type("lConsolida") <> "L"
   lConsolida := .f.
EndIf

Begin Sequence

   If lIsFilBr // Filial do Brasil.

      /* Para a opção de inclusão sem tratamentos de off-shore, caso o processo já exista na filial de
         intermediação e não puder ser deletado, a inclusão é bloqueada. */

      If (nOpc == INCLUIR) .And. !(M->EEC_INTERM $ cSim)
         EEC->(DbSetOrder(1))
         If EEC->(DbSeek(cFilEx+M->EEC_PREEMB))

            If (EEC->EEC_STATUS == ST_PC)
               lCancelado := .t.
            Else
               /*
               If !Empty(EEC->EEC_DTEMBA)
                  lEmbarcado := .t.
               EndIf
               */
               If lPagtoAnte
                  EEQ->(DbSetOrder(6))
                  If EEQ->(DbSeek(cFilEx+"E"+M->EEC_PREEMB))
                     Do While EEQ->(!Eof()) .And. EEQ->EEQ_FILIAL == cFilEx .And.;
                                                  EEQ->EEQ_FASE   == "E"    .And.;
                                                  EEQ->EEQ_PREEMB == EEC->EEC_PREEMB
                        If EEQ->EEQ_TIPO == "A"
                           lTemAdiantamento := .t.
                           Exit
                        EndIf
                        EEQ->(DbSkip())
                     EndDo
                  EndIf
               EndIf
            EndIf

            If lEmbarcado .Or. lTemAdiantamento .Or. lCancelado
               cMsg := STR0106+Replic(ENTER,2) //"Problema:"
               cMsg += STR0107+AllTrim(Transf(M->EEC_PREEMB,AVSX3("EEC_PREEMB",AV_PICTURE)))+STR0108+cFilEx+"' " //"O processo '"###"' está lançado na filial '"
               cMsg += STR0109+Replic(ENTER,2) //"e não poderá ser excluído."
               cMsg += STR0015+ENTER //"Detalhes:"

               If lCancelado
                  cMsg+= STR0110+ENTER //" - O processo cancelado."
               EndIf

               /*
               If lEmbarcado
                  cMsg+= STR0111+ENTER //" - O processo já está embarcado."
               EndIf
               */

               If lPagtoAnte .And. lTemAdiantamento
                  cMsg+= STR0112+ENTER //" - O processo possui adiantamento(s) vinculado(s)."
               EndIf

               cMsg += ENTER

               cMsg += STR0113+ENTER+; //"O processo, não poderá ser lançado sem tratamento de off-shore "
                       STR0114+cFilBr+"'." //"na filial '"
            EndIf

            If !Empty(cMsg)
               EECView(cMsg,STR0115,STR0116) //"Validações Off-Shore"###"Detalhes"
               lRet:=.f.
            Else
               If !MsgYesNo(STR0107+AllTrim(Transf(M->EEC_PREEMB,AVSX3(STR0117,AV_PICTURE)))+STR0118+cFilEx+"' "+ENTER+; //"O processo '"###"EEC_PREEMB"###"' será eliminado na filial '"
                            STR0119,STR0019) //"Confirma a operação ?"###"Atenção"
                  lRet:=.f.
                  Break
               EndIf
            EndIf
         EndIf
      EndIf

      If !(M->EEC_INTERM $ cSim)
         Break
      EndIf

      EEC->(DbSetOrder(1))
      If !EEC->(DbSeek(cFilEx+M->EEC_PREEMB))
         Break
      EndIf

      If nOpc == INCLUIR .Or. nOpc == ALTERAR

         /* Na inclusão/Alteração de embarque com tratamentos de off-shore, caso o processo já exista na filial
            de off-shore e estiver cancelado a inclusão/alteração não é permitida.*/

         If EEC->EEC_STATUS = ST_PC
            MsgInfo(STR0120+cFilEx+STR0121+ENTER+; //"Este processo está cancelado na filial de off-shore ("###") e não poderá ser"
                    STR0122+cFilBr+STR0123,STR0019) //"lançado na filial '"###"' com tratamento de intermediação."###"Atenção"
            lRet:=.f.
            Break
         EndIf

         /* Na alteração de embarque caso o mesmo já esteja embarcado na filial de off-shore não permite
            alterações. */
         /*
         If !Empty(EEC->EEC_DTEMBA)
            MsgInfo(STR0124+Transf(EEC->EEC_DTEMBA,"  /  /  ")+STR0125+ENTER+; //"Este processo foi embarcado em '"###"' na filial de off-shore"
                    STR0126+cFilBr+"'.",STR0019) //"e não poderá ser alterado na filial '"###"Atenção"
            lRet:=.f.
            Break
         EndIf
         */
      EndIf

   Else // Filial de Intermediação.

      /* Para validar a filial do Brasil a partir da filial de intermediação, o sistema verifica se no Brasil,
         o processo está marcado como processo de intermediação. Caso contrário não valida as quantidades e
         campos */

      nRecEEC := EEC->(Recno())
      EEC->(DbSetOrder(1))
      If EEC->(DbSeek(cFilBr+M->EEC_PREEMB))
         Do Case
            Case nOpc == INCLUIR  .And. !(EEC->EEC_INTERM $ cSim)
                /* Na inclusão de processo na filial exterior, caso o processo já exista na filial
                   brasil com a flag de off-shore = não, bloqueia a inclusão do processo */

                EEC->(DbGoTo(nRecEEC))
                MsgInfo(STR0107+AllTrim(Transf(M->EEC_PREEMB,Avsx3("EEC_PREEMB",AV_PICTURE)))+"'"+; //"O processo '"
                        STR0127+ENTER+; //"não poderá ser lançado nesta filial. Este processo está "
                        STR0122+cFilBr+STR0128,STR0019) //"lançado na filial '"###"' sem tratamento de off-shore."###"Atenção"
                lRet:=.f.
                Break

            Case (EEC->EEC_INTERM $ cSim)
                /* by jbj - 11/04/05 - Retirada das validações abaixo, visto que serão executadas novas validações para atender
                                       ao tratamento de off-shore.
                // Valida as quantidades de todos os produtos entre os processos da filial de intermediação e da
                //   filial brasil

                EEC->(DbGoTo(nRecEEC))
                If !Ap101VldQtde(OC_EM,.f.)
                   lRet:=.f.
                   Break
                EndIf
                */
         EndCase
      EndIf
   EndIf
End Sequence

RestOrd(aOrd,.t.)

Return lRet

/*
Funcao      : AE105VldAdiant().
Parametros  : Nenhum
Retorno     : .t./.f.
Objetivos   : Validar se o Total de Embarque é maior ou menor que o total de adiantamento vinculado.
Autor       : Julio de Paula Paz
Data/Hora   : 08/02/2006 11:55
Revisao     :
Obs.        :
*/
*--------------------------------------*
Function AE105VldAdiant()
Local lRet := .T., aOrdAd := SaveOrd("EEQ")
Local nTotAdia := 0

Begin Sequence
  EEQ->(DbSetOrder(6)) // Fase+Preemb+Parcela"
  EEQ->(DbSeek(xFilial("EEQ")+"E"+M->EEC_PREEMB))

  Do While EEQ->(!Eof()) .And. EEQ->EEQ_FILIAL == xFilial("EEQ") .And.;
                               EEQ->EEQ_FASE   == "E" .And.;
                               EEQ->EEQ_PREEMB == M->EEC_PREEMB
     If EEQ->EEQ_TIPO = "A"
        // ** Acumula os adiantamentos.
        nTotAdia += EEQ->EEQ_VL
     EndIf

     EEQ->(DbSkip())
  EndDo
  If M->EEC_TOTPED > 0 .and. nTotAdia > M->EEC_TOTPED // Total de Adiantamentos Vinculados > Total de embarque.
     lRet := .F.
  EndIf
End Sequence

RestOrd(aOrdAd)

Return lRet
/*
Funcao      : AE105AtuAdiant().
Parametros  : Nenhum
Retorno     : .t./.f.
Objetivos   : Atualizar o total de adiantamento vinculado de acordo com o total de embarque.
Autor       : Julio de Paula Paz
Data/Hora   : 08/02/2006 13:45
Revisao     :
Obs.        :
*/
*--------------------------------------*
Function AE105AtuAdiant()
Local lRet := .T., aOrdAd := SaveOrd({"EEQ","SA1"}) ,nOpc := 0
Local aCpos
Local cPictVl := AvSx3("EEQ_VL",AV_PICTURE)
Local cTitulo

Local bOk:={|| If(nSaldo == 0,(nOpc:=1, oDlg:End()),MsgInfo(STR0137))},; //"O saldo de Adiantamento deve ser igual a zero."
      bCancel:={||nOpc := 0 , oDlg:End()}
Local lInverte := .f.
Local oDlg, oMark,oTotVinc,oSaldo

Local nAltu := 40, nLargu := 80, nPosIni := 25, nGet_size := 50
Local aPosLinhas := {15, 35, 55}

Private nTotVinc := 0, nSaldo := 0, cMarcaAd := GetMark()

Begin Sequence
   MsgInfo(STR0138,STR0020) //"O total de adiantamento vinculado não pode ser maior que o total do embarque. Os excessos deverão ser estornados."###"Atenção!"

   SA1->(DbSetOrder(1))
   SA1->(DbSeek(xFilial("SA1")+M->EEC_IMPORT+M->EEC_IMLOJA))

   WORKSLD_AD->(AvZap())
   EEQ->(DbSetOrder(6)) // Fase+Preemb+Parcela"
   EEQ->(DbSeek(xFilial("EEQ")+"E"+M->EEC_PREEMB))

   Do While EEQ->(!Eof()) .And. EEQ->EEQ_FILIAL == xFilial("EEQ") .And.;
                                EEQ->EEQ_FASE   == "E" .And.;
                                EEQ->EEQ_PREEMB == M->EEC_PREEMB
      If EEQ->EEQ_TIPO = "A"
         WORKSLD_AD->(DbAppend())
         AvReplace("EEQ","WORKSLD_AD")
         WORKSLD_AD->WK_RECNO := EEQ->(RecNo())
         WORKSLD_AD->WK_STATUS := STR0007+If(WORKSLD_AD->EEQ_FAOR="P",STR0008+AllTrim(WORKSLD_AD->EEQ_PROR),STR0020+SA1->A1_NOME) //"Vinculado/"###"Processo: "###"Cliente:"
         nTotVinc += EEQ->EEQ_VL
      EndIf

      EEQ->(DbSkip())
   EndDo
   nSaldo := nTotVinc - M->EEC_TOTPED

    // ** Colunas para o Browse ...
   aCpos := {{"WK_FLAG","","  "},;
             {{|| WORKSLD_AD->WK_STATUS},"",STR0021},; //"Adiantamento"
             {{|| Transf(WORKSLD_AD->EEQ_VL,cPictVl)}   ,"",STR0023},; //"Valor Adiantamento"
             {{|| Transf(WORKSLD_AD->WK_VLEST,cPictVl)} ,"",STR0139}} // "Valor a Estornar"

   cTitulo := STR0140 // "Estorno dos Adiantamentos Vinculados"
   WORKSLD_AD->(DbGoTop())

   Define MsDialog oDlg Title cTitulo From 9,0 To nAltu,nLargu of oDlg

      @ nPosIni + aPosLinhas[1], 07 Say STR0141 Size 100,07 Pixel Of oDlg // "Total Adiantamento Vinculado"
      @ nPosIni + aPosLinhas[1], 90  MsGet oTotVinc Var nTotVinc Picture cPictVl Size nGet_size, 07  Pixel Of oDlg When .f.

      @ nPosIni + aPosLinhas[2], 07 Say STR0142 Size 100,07 Pixel of oDlg // "Total do Processo"
      @ nPosIni + aPosLinhas[2], 90  MsGet M->EEC_TOTPED Picture cPictVl Size nGet_size, 07 Pixel Of oDlg When .f.

      @ nPosIni + aPosLinhas[3], 07 Say STR0143 Size 100,07 Pixel Of oDlg // "Saldo de Adiantamento"
      @ nPosIni + aPosLinhas[3], 90 MsGet oSaldo Var nSaldo Picture cPictVl Size nGet_size, 07 Pixel Of oDlg When .f.

      aPos := PosDlgDown(oDlg)
      aPos[1] := 110
      aPos[3] := 246

      oMark := MsSelect():New("WORKSLD_AD","WK_FLAG",,aCpos,@lInverte,@cMarcaAd,aPos)
      oMark :bAval := {|| If(Empty(WORKSLD_AD->WK_FLAG),AE105MarkAd(oMark,,oTotVinc,oSaldo),AE105MarkAd(oMark,.f.,oTotVinc,oSaldo))}
      oMark:oBrowse:align := CONTROL_ALIGN_BOTTOM

   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) Centered
   If nOpc == 1
      lRet := .T.
   Else
      lRet := .F.
      WORKSLD_AD->(AvZap())
   EndIf
End Sequence

Return lRet

/*
Funcao      : AE105MarkAd(oMark,lMarcar,oTotVinc,oSaldo)
Parametros  : oMark   => Objeto para Refresh.
              lMarcar => .t. - Marca item.
                         .f. - Desmarca item.
              oTotVinc => Objeto para Refresh
              oSaldo   => Objeto para Refresh
Retorno     : .T.
Objetivos   : Estornar os valores para os adiantamentos associados.
Autor       : Julio de Paula Paz
Data/Hora   : 08/02/2006
Obs.        :
*/
*--------------------------------------*
Static Function AE105MarkAd(oMark,lMarcar,oTotVinc,oSaldo)
*--------------------------------------*
Local nOpc := 0, nValor := 0, nValDisp := 0
Local bOk:={|| (nOpc:=1,oDlg:End())}
Local bCancel := {|| oDlg:End()}
Local cTitulo, cX
Local lRet:=.t.
Local oDlg
Local nPosIni, nAltu, nLargu, aPosLinhas := {0,0}, nAltGrup

Default lMarcar := .t.

Begin Sequence
   If WORKSLD_AD->EEQ_FAOR == "P"
      EEQ->(DbSetOrder(6))  // Fase+Processo+Nro. Parcela
      EEQ->(DbSeek(xFilial("EEQ")+WORKSLD_AD->(EEQ_FAOR+EEQ_PROR+EEQ_PAOR))) // Localiza o registro que originou a associação do Adiantamento.
      If ! AE105HaSaldo(EEQ->EEQ_PREEMB)
         MsgInfo(STR0144,STR0019) // "O processo que originou a vinculação deste adiantamento está com câmbio contratado e não há itens disponiveis para futuros embarques. Não será possível fazer o estorno desta parcela."###"Atenção"
         Break
      EndIf
   EndIf
   If nSaldo > WORKSLD_AD->EEQ_VL
      nValDisp := WORKSLD_AD->EEQ_VL
   Else
      nValDisp := nSaldo
   EndIf

   If lMarcar

      cTitulo  := STR0146 // "Estorno dos valores Vinculados"

      nPosIni := 1.5
      nAltu := 25       // 20.5
      nLargu := 47
      nAltGrup := 7

      aPosLinhas[1] := 2.0
      aPosLinhas[2] := aPosLinhas[1] + 2.0 //distancia da primeira linha pra segunda 2.0

      Define MsDialog oDlg Title cTitulo From 10,12 To nAltu, nLargu Of oMainWnd

         @ nPosIni + 1.1, 0.5 To nAltGrup, 17 Label STR0035 Of oDlg //"Valores "

         @ nPosIni + aPosLinhas[1], 2.0 Say STR0036 Of oDlg Size 35, 9 //"Disponivel"
         @ nPosIni + aPosLinhas[1] + 0.6, 2.0 MsGet nValDisp  Size 70, 07  Picture AVSX3("EEQ_VL",AV_PICTURE) Of oDlg When .f.

         @ nPosIni + aPosLinhas[2], 2.0 Say STR0143 Of oDlg Size 35,9 // "Estornar"
         @ nPosIni + aPosLinhas[2] + 0.6, 2.0 MsGet nValor Size 70, 07 Picture AVSX3("EEQ_VL",AV_PICTURE) Valid(AE105ValAd(nValDisp,nValor)) Of oDlg

      Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) Centered

      If nOpc = 1
         If nValor > 0
            WORKSLD_AD->WK_FLAG   := cMarcaAd
            WORKSLD_AD->WK_VLEST  := nValor // Valor a estornar
            AE105AtuValAd() // Atualiza valores das variaveis saldo(nSaldo) e total vinculado(nTotVinc).
         EndIf
      EndIf
   Else
      WORKSLD_AD->WK_FLAG   := ""
      WORKSLD_AD->WK_VLEST := 0 // Zera valor Estornado
      AE105AtuValAd() // Atualiza valores das variaveis saldo(nSaldo) e total vinculado(nTotVinc).
   EndIf
   oTotVinc:Refresh()
   oSaldo:Refresh()
End Sequence

Return lRet

/*
Funcao      : AE105ValAd(nValDisp,nValor)
Parametros  : nValDisp   => Valor disponivel para o estorno
              nValor     => Valor digitado
Retorno     : .T./.F.
Objetivos   : Validação na digitação dos valores a Estornar.
Autor       : Julio de Paula Paz
Data/Hora   : 08/02/2006 - 16:55
Obs.        :
*/
*--------------------------------------*
Static Function AE105ValAd(nValDisp,nValor)
Local lRet := .T.
Begin Sequence
   If nValor > nValDisp
      MsgInfo(STR0147,STR0019) // "O valor digitado não pode ser maior que o valor disponível."###"Atenção"
      lRet := .F.
   ElseIf nValor < 0
      MsgInfo(STR0148,STR0019) // "O valor digitado não pode ser menor que zero."###"Atenção"
      lRet := .F.
   EndIf
End Sequence

Return lRet

/*
Funcao      : AE105AtuValAd()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Atualizar valores Total Vinculados e saldo dos valores estornados.
Autor       : Julio de Paula Paz
Data/Hora   : 08/02/2006 - 17:20
Obs.        :
*/
*--------------------------------------*
Static Function AE105AtuValAd()
Local lRet := .T., nRec := WORKSLD_AD->(Recno())
Local nValVinc:=0 , nValEstor := 0

Begin Sequence
   WORKSLD_AD->(DbGotop())
   Do While !WORKSLD_AD->(Eof())
      nValVinc += WORKSLD_AD->EEQ_VL   // Valor total vinculado
      nValEstor += WORKSLD_AD->WK_VLEST // Valor total estornado.
      WORKSLD_AD->(DbSkip())
   EndDo
   WORKSLD_AD->(DbGoto(nRec))
   nTotVinc := nValVinc - nValEstor // Valor total vinculado
   nSaldo := nTotVinc - M->EEC_TOTPED // Valor do saldo
End Sequence

Return lRet

/*
Funcao      : AE105GrvEstAd()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Atualizar os dados da tabela EEQ com os estornos dos adiantamentos Vinculados.
Autor       : Julio de Paula Paz
Data/Hora   : 09/02/2006 - 09:20
Obs.        :
*/
*--------------------------------------*
Function AE105GrvEstAd()
Local lRet := .T., aOrd := SaveOrd({"EEQ"})//, cChave := AvKey(M->EEC_IMPORT,"EEC_IMPORT")+AvKey(M->EEC_IMLOJA,"EEC_IMLOJA")
//Local nReg
//Local aParc:={}

Begin Sequence
   If IsVazio("WORKSLD_AD")
      Break
   EndIf
   WORKSLD_AD->(DbGotop())
   Do While ! WORKSLD_AD->(Eof())
      If Empty(WORKSLD_AD->WK_FLAG)   // Item sem valor de estorno.
         WORKSLD_AD->(DbSkip())
         Loop
      EndIf
      EEQ->(DbSetOrder(6))
      EEQ->(DbSeek(xFilial("EEQ")+WORKSLD_AD->(EEQ_FAOR+EEQ_PROR+EEQ_PAOR))) // Localiza o registro que originou a associação do Adiantamento.
      EEQ->(RecLock("EEQ",.F.))
      EEQ->EEQ_SALDO := EEQ->EEQ_SALDO + WORKSLD_AD->WK_VLEST  // Estorna o saldo
      EEQ->(MsUnLock())
      EEQ->(DbGoto(WORKSLD_AD->WK_RECNO)) // Posiciona no registro associado
      EEQ->(RecLock("EEQ",.F.))
      If EEQ->EEQ_VL == WORKSLD_AD->WK_VLEST // Se Valor de estorno igual ao total da associação de adiantamento excluir registro.
         EEQ->(DbDelete())
      Else
         EEQ->EEQ_VL := EEQ->EEQ_VL - WORKSLD_AD->WK_VLEST  // Atualiza valor de adiantamento associado.
         EEQ->EEQ_SALDO := EEQ->EEQ_VL
      EndIf
      EEQ->(MsUnLock())
      WORKSLD_AD->(DbSkip())
   EndDo
End Sequence
RestOrd(aOrd)
Return lRet

/*
Funcao      : AE105HaSaldo(cProcesso)
Parametros  : cProcesso => Código do processo de exportação
Retorno     : .T./.F.
Objetivos   : Verifica se há saldo nos itens do processo para futuros embarques
Autor       : Julio de Paula Paz
Data/Hora   : 10/02/2006 - 17:05
Obs.        :
*/
*--------------------------------------*
Function AE105HaSaldo(cProcesso)
Local lRet := .F., aItensAlt:= {}, nX //, aOrd := SaveOrd({"EE8"})
Begin Sequence
   WorkIP->(dbClearFilter())
   WORKIP->(DbGotop())
   Do while ! WORKIP->(Eof())  // Virifica se há itens com saldo disponivel para futuros embarques
      Aadd(aItensAlt,{WORKIP->EE9_PEDIDO,WORKIP->EE9_SEQUEN})
      If (WORKIP->WP_RECNO <> 0 .And. EMPTY(WORKIP->WP_FLAG)) .Or. (WORKIP->WP_SLDATU > 0)
         If EEQ->EEQ_PREEMB == WORKIP->EE9_PEDIDO
            lRet := .T.
         EndIf
      EndIf
      WORKIP->(DbSkip())
   EndDo
   WorkIP->(dbSetFilter({|| WP_FLAG == cMarca },"WP_FLAG =='"+cMarca+"'"))
   WorkIP->(dbGoTop())

   EE8->(DbSetOrder(1))
   EE8->(DbSeek(xFilial("EE8")+EEQ->EEQ_PREEMB))  // Posiciona nos itens de processo para verificar se há saldo para embarque.
   Do While ! EE8->(Eof()) .And. (xFilial("EE8")+EEQ->EEQ_PREEMB) == (EE8->(EE8_FILIAL+EE8_PEDIDO))
      nX := Ascan(aItensAlt,{|x| x[1]+x[2] == EE8->(EE8_PEDIDO+EE8_SEQUEN)})
      If nX > 0   // Despreza os itens já verificado anteriomente.
         EE8->(DbSkip())
         Loop
      EndIf
      If EE8->EE8_SLDATU > 0
         lRet := .T.
      EndIf
      EE8->(DbSkip())
   EndDo
End Sequence
// RestOrd(aOrd)
Return lRet

/*
Funcao      : Ae105SelItNf()
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : Exibe tela de seleção de itens, caso o filtro de Notas Fiscais seja utilizado
              e mais de um item possua a mesma Nota Fiscal.
Autor       : Eduardo C. Romanini
Data/Hora   : 24/09/2008 - 16:50
Obs.        :
*/
*----------------------------*
Static Function Ae105SelItNf()
*----------------------------*
Local lRet     := .T.
Local lInverte := .F.

Local cOldFilter := WorkIP->(DbFilter())
Local cMarca     := GetMark()

Local bOldFilter := &("{|| "+If(Empty(cOldFilter),".T.",cOldFilter)+" }")
Local bOk        := {|| If(Ae105ValItNf(),oDlgItNf:End(),)}
Local bCancel    := {|| lRet := .F., oDlgItNf:End()}

Local aPos        := {}
Local aCampos     := {}
Local aSelButtons := {}
Local aOrd        := SaveOrd({"WorkIp"})

Private oMarkItNf

Begin Sequence

   If !Empty(cFiltroNf)

      aSelButtons := { {"LBTIK",{|| ItNfMarkAll(cMarca) } ,STR0165} }//"Marca/Desmarca Todos"//STR0165	"Marca/Desmarca Todos"

      aCampos:={{"WP_MKITNF","","  "},;
               {{||WorkIP->EE9_SEQUEN}               ,"",AvSX3("EE9_SEQUEN",AV_TITULO)},;
               {{||WorkIP->EE9_COD_I}                ,"",AvSX3("EE9_COD_I" ,AV_TITULO)},;
               {{||Memoline(WorkIP->EE9_VM_DES,60,1)},"",AvSX3("EE9_VM_DES",AV_TITULO)},;
               {{||WorkIP->EE9_NF}                   ,"",AvSX3("EE9_NF"    ,AV_TITULO)}}

      //Apaga o Filtro Atual
      WorkIp->(DbClearFilter())

      //Apaga o conteúdo das flags
      WorkIp->(DbGoTop())
      WorkIp->(DbEval({|| WorkIp->WP_MKITNF := Space(2)}))
      WorkIp->(DbGoTop())

      //Filtra os itens que possuem a NF selecionada.
      WorkIp->(DbSetFilter({|| EE9_NF == AvKey(cFiltroNf,"EE9_NF") },"EE9_NF =='"+ AvKey(cFiltroNf,"EE9_NF")+"'"))

      WorkIp->(DbGoTop())

      DEFINE MSDIALOG oDlgItNf TITLE STR0166 FROM 0,0 TO 290,800 OF oMainWnd PIXEL//STR0166	"Selecione os itens a ser atualizados"

         aPos := PosDlg(oDlgItNf)

         oMarkItNf := MsSelect():New("WorkIp","WP_MKITNF",,aCampos,@lInverte,@cMarca,aPos)
         oMarkItNf:bAval := {|| If(Empty(WorkIp->WP_MKITNF),WorkIp->WP_MKITNF := cMarca,WorkIp->WP_MKITNF := Space(2))}

      ACTIVATE MSDIALOG oDlgItNf ON INIT (EnchoiceBar(oDlgItNf,bOk,bCancel,,aSelButtons)) CENTERED

      //Restaura o Filtro antigo
      If !Empty(cOldFilter)
         WorkIP->(DbSetFilter(bOldFilter,cOldFilter))
      Else
         WorkIp->(DbClearFilter())
      Endif

   EndIf

End Sequence

RestOrd(aOrd,.T.)

Return lRet

/*
Funcao      : Ae105ValItNf()
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : Valida a tela de seleção de itens.
Autor       : Eduardo C. Romanini
Data/Hora   : 24/09/2008 - 16:50
Obs.        :
*/
*----------------------------*
Static Function Ae105ValItNf()
*----------------------------*
Local lRet   := .T.
Local lSelNf := .F.

Local aOrd := SaveOrd({"WorkIp"})

Begin Sequence

   WorkIp->(DbGoTop())
   While WorkIp->(!EOF())
      If !Empty(WorkIp->WP_MKITNF)
         lSelNf := .T.
         Exit
      EndIf
      WorkIp->(DbSkip())
   EndDo

   If !lSelNf
      MsgInfo(STR0167,STR0168)//STR0167	"Não foi selecionado nenhum item para atualização." //STR0168	"Atenção"
      lRet := .F.
      Break
   EndIf

End Sequence

RestOrd(aOrd,.T.)

Return lRet

/*
Funcao      : ItNfMarkAll
Parametros  : cMarca
Retorno     : Nil
Objetivos   : Função do botão de marca/desmarca todos os itens.
Autor       : Eduardo C. Romanini
Data/Hora   : 24/09/2008 - 16:50
Obs.        :
*/
*---------------------------------*
Static Function ItNfMarkAll(cMarca)
*---------------------------------*

Begin Sequence
   WorkIp->(DbGoTop())
   If !Empty(WorkIp->WP_MKITNF)
      While WorkIp->(!EOF())
         If WorkIp->WP_MKITNF <> Space(2)
            WorkIp->WP_MKITNF := Space(2)
         EndIf
         WorkIp->(DbSkip())
      EndDo
   Else
      While WorkIp->(!EOF())
         If WorkIp->WP_MKITNF == Space(2)
            WorkIp->WP_MKITNF := cMarca
         EndIf
         WorkIp->(DbSkip())
      EndDo
   EndIf
End Sequence

WorkIp->(DbGoTop())
oMarkItNf:oBrowse:Refresh()

Return Nil

/*
Funcao      : ParcOrigBx
Parametros  : Filial, Embarque, Parcela de Origem e Fase
Retorno     : lRet - Retorna se a percela de origem da compensacao sofreu alguma liquidacao(.T.) ou nao(.F.);
Objetivos   : Verifica se a parcela de câmbio de origem da compensacao sofreu alguma liquidacao.
Autor       : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora   : 02/04/2018
*/
Static Function ParcOrigBx(cPREEMB, cFINNUM, nRECNO,cSEQBX)
Local lRet      := .F.
Local aAreaEEQ  := EEQ->(GetArea())

cPREEMB := AvKey(cPREEMB,"EEQ_PREEMB")
cFINNUM := AvKey(cFINNUM,"EEQ_FINNUM")

EEQ->(dbSetOrder(1)) //EEQ_FILIAL + EEQ_PREEMB + EEQ_PARC + EEQ_FASE
EEQ->(dbSeek(xFilial("EEQ") + cPREEMB))
Do While EEQ->(!Eof()) .And. EEQ->EEQ_FILIAL == xFilial("EEQ") .And. EEQ->EEQ_PREEMB == cPREEMB

    If !(EEQ->(Recno()) == nRECNO .Or. Empty(EEQ->EEQ_SEQBX))
        If EEQ->EEQ_FINNUM == cFINNUM .And. VAL(EEQ->EEQ_SEQBX) > VAL(cSEQBX) .AND. !Empty(EEQ->EEQ_PGT)
            lRet := .T.
            Exit
        EndIf
    EndIf

    EEQ->(DbSkip())
EndDo

RestArea(aAreaEEQ)
Return lRet


/*
Função      : VlUltiParc
Parametros  : 
Objetivo    : Verifica o valor da ultima parcela de cambio que sera utilizada na compensacao com o adiantamento pos-embarque
Retorno     : 
Autor       : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora   : 19/04/18
*/
Static Function VlUltiParc()
Local nRet := 0
Local aAreaTMP := TMP->(getArea())

TMP->(dbSetOrder(4))
If TMP->(AvSeekLast("101"))
   While TMP->(!Bof()) .And. TMP->EEQ_EVENT == "101"
		
        If If(TMP->EEQ_MODAL == "2" , !Empty(TMP->EEQ_DTCE) ,!Empty(TMP->EEQ_PGT))
            TMP->(DbSkip(-1))
            Loop
        EndIf
	If TMP->EEQ_MOEDA <> M->EEQ_MOEDA //Desconsidera as parcelas com moeda diferente da moeda do desconto
	    TMP->(DbSkip(-1))
	    Loop
	EndIf
		
	If EF3->(DbSeek(xFilial("EF3")+If(lEFFTpMod,IF(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),"") + TMP->EEQ_NRINVO + TMP->EEQ_PARC)) //Verifica se a parcela possui vinculação com o EF3
	    TMP->(DbSkip(-1))
	    Loop
	EndIf

        nRet := (TMP->EEQ_VL - (TMP->EEQ_CGRAFI + TMP->EEQ_ADEDUZ))

        Exit
    End

EndIf

RestArea(aAreaTMP)

Return nRet
*----------------------------------------------------------------------------------------*
* FIM DO PROGRAMA EECAE105                                                               *
*----------------------------------------------------------------------------------------*
