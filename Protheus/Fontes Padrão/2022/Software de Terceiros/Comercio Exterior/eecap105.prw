#INCLUDE "eecap105.ch"
#include "dbtree.ch"
#include "EEC.CH"

#define BXG_DET     97//Baixa Gerencial - JVR - 30/07/09
#define SF_SS  /*STR0901*/ "Sem preço e sem diferencial" //RRC - 01/11/2013 - Ajuste nas defines
#define SF_SD  /*STR0902*/ "Sem preço e com diferencial"
#define SF_FX  /*STR0903*/ "Fixado"
#define SF_PI  /*STR0904*/ "Com preço inicial"
/*
Programa..: EECAP105.PRW
Objetivo..: Proc. Exportacao - Manutenções Diversas.
Autor.....: Jeferson Barros Jr.
Data/Hora.: 10/03/03 11:42
Obs.......:
ALTERACAO.: -LCS - 23/04/2003 - NA FIXACAO DE PRECOS, SÓ TRAZER OS ITENS QUE
             NAO TEM A DATA DE FIXACAO PREENCHIDA. CRIAR PONTO DE ENTRADA P/
             GRAVACAO DOS DADOS NA FIXACAO. CRIAR MV PARA INFORMAR SE OS
             VALORES DA FILIAL BRASIL DEVEM SER ALTERADOS NA FILIAL EXTERIOR
*/

/*
Funcao      : AP100Adian()
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Manutenção de adiantamentos.
Autor       : Jeferson Barros Jr.
Data/Hora   : 06/11/2002 15:29.
Revisao     : WFS 28/08/2009
              Ao calcular o saldo do processo disponível para a criação da parcela de adiantamentos,
              é considerado o total de adiantamentos incluídos (variável nTotAdia) e o total de embarque
              existente para o processo (variável nTotEmb), no entanto ocorre que a parcela de adiantamento
              vinculada ao embarque é somada nas duas variáveis, gerando uma divergência no cálculo do saldo
              disponível.
              Foi adicionado a variável nEEQSaldo, que será usada para este controle na função AP100ValAdian().

Obs.        :
*/
*-------------------*
Function AP100Adian()
*-------------------*
Local bOk := {|| nOpcao:=1, oDlg:End()} , bCancel := {|| oDlg:End()}
Local /*aCpos := {}, */ aOrd:=SaveOrd({"EEQ","SA1","SX3","EEC","EE9"}), aSemSx3:={}
Local oDlg, oMsSelect, oGetTot
Local cArq, cArq2, cPictDt:="  /  /  ", cPictVl := "@E 999,999,999,999.99", cTit, cPictTx := "@E 99,999,999.999999"  //NCF - 01/10/2015 - Adiant. com Mov. Exterior
Local nOpcao := 0
Local lRet:= .t.
Local aFil := {}, nInc := 0, cFil := ""

Local nRecNoEE7 := EE7->(RecNo()), aEE7Filter := EECSaveFilter("EE7") // JPM - 02/12/05 - salva e limpa filtro no EE7
Local bOnError := {|cFuncName, nOpc| Ap105RetAdian(cFuncName, nOpc) }
Local aOrdTabBco := {}                                                                                               //NCF - 01/10/2015 - Adiant. com Mov. Exterior
EE7->(DbClearFilter())
EE7->(DbGoTo(nRecNoEE7))
Private aButtons    := {}
//DFS - 01/04/13 - Inclusão de array private para uso em customizações.
Private aButtonsAux := {}
// ** JPM - private para ser acessado pelo pto entrada
Private aCpos := {}

Private nTotAdia := 0, nTotProc := 0, nEEQSaldo:= 0
Private nTotEmb  := 0  // PLB 20/09/06 - Valor já embarcado
Private cMarca   := GetMark()

Private aDeletados := {}, nSaldo := 0
Private lFinanciamento := EasyGParam("MV_EFF",,.F.)
Private lTelaVincula := .F. //FSM - 01/03/2012
Private lIntFina := EasyGParam("MV_EEC_EFF",,.F.)
Private aArrayEEQ := {}
Private aRetEEQ := {}

SX3->(DBSETORDER(2))
Private lOkEVENT  := SX3->(dbSeek("EEQ_EVENT"))

Private aGets:={}, aTela:={}
Private lLoop := .F.
Private lValExclu := .T. //AST - 23/07/08 - usado para validar a exclusão quando integrado com o SAP,
                         //para alterar o valor da variavel utilizar o ponto de entrada ("EECAP105",.F.,.F.,"ANTES_TELA_ADIAN")

Private aCores := {} //FDR - 27/03/13
Private lIsEmb := .T. //MCF - 29/07/2014
Private lCpoAcrDcr := AVFLAGS("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP") //NCF - 14/08/2015 - Tratamento Acresc./Decres./Multa/Juros/Desconto no controle de cambio SIGAEEC x SIGAFIN
Private lAdtMovExt := AVFLAGS("CAMBIO_EXP_MOV_EXT")               //NCF - 01/10/2015 - Adiant. com Mov. Exterior

//AjustaEC6() // NCF - 01/10/2015

Begin Sequence

  // ** Colunas para o Browse ...
  aCpos := {{{|| Work_Pgto->WK_STATUS}                ,"",STR0001},; //"Tipo"
            {{|| Transf(Work_Pgto->EEQ_PGT,cPictDt)}  ,"",AVSX3("EEQ_PGT",AV_TITULO)},;
            {{|| Work_Pgto->EEQ_PARC}                 ,"",STR0002},; //"Nro.Parcela"
            {{|| Work_Pgto->EEQ_MOEDA}                ,"",STR0184},; //"Moeda"  // GFP - 23/08/2012
            {{|| Transf(Work_Pgto->EEQ_VL,cPictVl)}   ,"",STR0003},; //"Valor"
            {{|| Transf(Work_Pgto->EEQ_SALDO,cPictVl)},"",STR0004+Space(30)},; //"Saldo"
            {{|| Work_Pgto->EEQ_FINNUM}               ,"",STR0191}} //"Nro.Título"  // GFP - 10/04/2014

   If EEQ->(FieldPos("EEQ_SLDELI")) > 0
      AAdd(aCpos, {{|| Transf(Work_Pgto->EEQ_SLDELI,cPictVl)},"",STR0169+Space(30)}) //"Saldo Eliminado"
   EndIf
   //NCF - 14/05/2015
   If AVFLAGS("EEC_LOGIX")
      If EEQ->(FieldPos("EEQ_FFC")) > 0
         AAdd(aCpos, {{|| Work_Pgto->EEQ_FFC},"",AVSX3("EEQ_FFC",AV_TITULO)} ) //"FFC"
      EndIf
      If EEQ->(FieldPos("EEQ_SEQBX")) > 0
         AAdd(aCpos, {{|| Work_Pgto->EEQ_SEQBX},"",AVSX3("EEQ_SEQBX",AV_TITULO)} ) //"Seq.Baixa"
      EndIf
   EndIf
   //NCF - 22/07/2015
   IF lCpoAcrDcr
      AAdd(aCpos, {{|| Transf(Work_Pgto->EEQ_DECRES,cPictVl)},"",AVSX3("EEQ_DECRES",AV_TITULO)} ) //"Decrescimos"
   ENDIF
   //NCF - 01/10/2015 - Adiant. com Mov. Exterior
   IF lAdtMovExt
      AADD(aCpos, {{|| Work_Pgto->EEQ_MOEBCO}                ,"",AVSX3("EEQ_MOEBCO",AV_TITULO)} )
      AADD(aCpos, {{|| Transf(Work_Pgto->EEQ_PRINBC,cPictTx)},"",AVSX3("EEQ_PRINBC",AV_TITULO)} )
      AADD(aCpos, {{|| Transf(Work_Pgto->EEQ_VLMBCO,cPictVl)},"",AVSX3("EEQ_VLMBCO",AV_TITULO)} )
   ENDIF
  // ** Definição dos botoes da Enchoice Bar.

  //ER - 20/06/2006 às 10:00
  aAdd(aButtons,{"HISTORIC",{|| AP100ViewHist()},STR0025}) //"Histórico"

  If EEQ->(FieldPos("EEQ_SLDELI")) > 0
     aAdd(aButtons,{"S4WB004N", {|| AP105RestOrDel()},STR0173}) //"Elimina/Restaura Saldo"
  EndIf

  aAdd(aButtons,{"BMPVISUAL" /*"ANALITICO"*/, {|| AP100AdiMan(VIS_DET)},STR0005}) //"Visualizar"
  aAdd(aButtons,{"BMPINCLUIR" /*"EDIT"*/,      {|| AP100AdiMan(INC_DET,oMsSelect,oGetTot)},STR0006}) //"Incluir"

  // ** Para os adiantamentos associados a partir do importador a tela de asssociacao é acionada,
  // ** caso contrário a tela de alteração padrão é chamada.
  aAdd(aButtons,{"EDIT" /*"ALT_CAD"*/,{|| If(!Empty(Work_Pgto->EEQ_PAOR),AP100Add(oMsSelect,oGetTot,.t.),;
                                   AP100AdiMan(ALT_DET,oMsSelect,oGetTot))},STR0007}) //"Alterar"

  aAdd(aButtons,{"EXCLUIR",   {|| AP100AdiMan(EXC_DET,oMsSelect,oGetTot)},STR0008}) //"Excluir"
  aAdd(aButtons,{"BAIXATIT" /*"NOVACELULA"*/,{|| AP100Add(oMsSelect,oGetTot)},STR0009,STR0166}) //"Associar Adiantamento" , "Associar"

  //Baixa Gerencial - RMD - 08/11/07
  If EECFlags("CAMBIO_EXT")
     aAdd(aButtons,{"BUDGET",{|| AP100AdiMan(BXG_DET,oMsSelect,oGetTot) },STR0174, STR0175}) //STR0174 "Baixa Gerencial" //STR0175	"Bx. Geren."
  EndIf

  aCampos:= Array(EEQ->(fCount()))

  aAdd(aSemSx3,{"EEQ_PREEMB","C",AvSx3("EEQ_PREEMB",AV_TAMANHO),AvSx3("EEQ_PREEMB",AV_DECIMAL)})
  aAdd(aSemSx3,{"EEQ_FINNUM","C",AvSx3("EEQ_FINNUM",AV_TAMANHO),AvSx3("EEQ_FINNUM",AV_DECIMAL)})  // GFP - 10/04/2014

  AddNaoUsado(aSemSx3, "EEQ_FFC")                                                                 // NCF - 14/05/2015

  Aadd(aSemSx3,{"RECNO","N",10,0})
  Aadd(aSemSx3,{"WK_STATUS","C",10,0})

  //RMD - Integração com o módulo SIGAFIN
  AddNaoUsado(aSemSx3, "EEQ_FINNUM")

  //ER - 11/08/2008
  AddNaoUsado(aSemSx3, "EEQ_IMPORT")

  // ** Cria work com os adiantamentos por processo.
  cArq   := E_CriaTrab("EEQ",aSemSx3,"Work_Pgto")
  IndRegua("Work_Pgto",cArq+TEOrdBagExt(),"EEQ_FASE+EEQ_PREEMB+EEQ_PARC",,,STR0009) //"Processando Arquivo Temporário..."
  Set Index To (cArq+TEOrdBagExt())

  cNomArq:=CriaTrab(Nil,.f.)
  IndRegua("Work_Pgto",cNomArq+TEOrdBagExt(),"EEQ_FAOR+EEQ_PROR+EEQ_PAOR")

  Set Index to (cArq+TEOrdBagExt()),(cNomArq+TEOrdBagExt())

  EEQ->(DbSetOrder(6)) // Fase+Preemb+Parcela"
  EEQ->(DbSeek(xFilial("EEQ")+"P"+EE7->EE7_PEDIDO))

  Do While EEQ->(!Eof()) .And. EEQ->EEQ_FILIAL == xFilial("EEQ") .And.;
                               EEQ->EEQ_FASE   == "P" .And.;
                               EEQ->EEQ_PREEMB == EE7->EE7_PEDIDO
     If EEQ->EEQ_TIPO = "A" .AND. EEQ->EEQ_MOEDA == EE7->EE7_MOEDA// GFP - 23/08/2012 - Apenas carrega adiantamentos de moeda igual ao do processo.
        Work_Pgto->(DbAppend())

        //RMD - 11/05/12 - Carrega variáveis do banco para evitar erro no MsSeek
        RegToMemory("EEQ", .F.)

        AvReplace("EEQ","Work_Pgto")
        Work_Pgto->RECNO := EEQ->(RecNo())

        If lAdtMovExt                                                           //NCF - 01/10/2015 - Adiant. com Mov. Exterior
           aOrdTabBco := SaveOrd("SA6")
           SA6->(DbSetOrder(1))
           If EasyVerModal("Work_Pgto")
              SA6->(DbSeek(xFilial()+Work_Pgto->(EEQ_BCOEXT+EEQ_AGCEXT+EEQ_CNTEXT)))
              Work_Pgto->EEQ_MOEBCO := SA6->A6_MOEEASY
              Work_Pgto->EEQ_PRINBC := Work_Pgto->EEQ_VLMBCO/Work_Pgto->EEQ_VL
           Else
              SA6->(DbSeek(xFilial()+Work_Pgto->(EEQ_BANC+EEQ_AGEN+EEQ_NCON)))
              Work_Pgto->EEQ_MOEBCO := EasyGParam("MV_SIMB"+CValToChar(SA6->A6_MOEDA),,"")
           EndIf
           RestOrd(aOrdTabBco,.T.)
        EndIf

        // ** Acumula os adiantamentos.
        nTotAdia += Work_Pgto->EEQ_VL
        //WFS 28/08/09
        nEEQSaldo += Work_Pgto->EEQ_SALDO
     EndIf

     EEQ->(DbSkip())
  EndDo

  Work_Pgto->(DbGoTop())

  // ** Cria work com os adiantamentos do cliente.
  aSemSx3:={}
  aAdd(aSemSx3,{"EEQ_PREEMB","C",AvSx3("EEQ_PREEMB",AV_TAMANHO),AvSx3("EEQ_PREEMB",AV_DECIMAL)})
  Aadd(aSemSx3,{"RECNO"    ,"N",10,0})
  Aadd(aSemSx3,{"WK_FLAG"  ,"C",02,0})
  Aadd(aSemSx3,{"WK_VLADI" ,"N",AVSX3("EEQ_VL",AV_TAMANHO),AVSX3("EEQ_VL",AV_DECIMAL)})

  //RMD - Integração com o módulo SIGAFIN
  AddNaoUsado(aSemSx3, "EEQ_FINNUM")

  cArq2   := E_CriaTrab("EEQ",aSemSx3,"Work_Adia")
  IndRegua("Work_Adia",cArq2+TEOrdBagExt(),"EEQ_FASE+EEQ_PREEMB+EEQ_PARC",,,STR0012) //"Processando Arquivo Temporário..."
  Set Index To (cArq2+TEOrdBagExt())

  cFil := xFilial("EEQ")

  //ER - 29/06/2007 - Quando a tabela EEQ for compatilhada, o cFil será vazio.
  If Empty(cFil)
     aAdd(aFil,cFil)
  Else
     //Seleciona todas as Filiais
     aFil := AvgSelectFil()
  EndIf

  For nInc:=1 to Len(aFil)
     //EEQ->(DbSeek(xFilial("EEQ")+"C"+AvKey(AllTrim(EE7->EE7_IMPORT)+AllTrim(EE7->EE7_IMLOJA),"EEQ_PREEMB")))
     EEQ->(DbSeek(aFil[nInc]+"C"+AvKey(EE7->EE7_IMPORT+EE7->EE7_IMLOJA,"EEQ_PREEMB")))
     Do While EEQ->(!Eof()) .And. EEQ->EEQ_FILIAL == aFil[nInc] .And.;
                                  EEQ->EEQ_FASE   == "C" .And.;
                                  EEQ->EEQ_PREEMB == AvKey(EE7->EE7_IMPORT+EE7->EE7_IMLOJA,"EEQ_PREEMB") // EEQ->EEQ_PREEMB == AvKey(AllTrim(EE7->EE7_IMPORT)+AllTrim(EE7->EE7_IMLOJA),"EEQ_PREEMB")
        If EEQ->EEQ_TIPO = "A" .AND. !Empty(EEQ->EEQ_DTCE) .AND. EEQ->EEQ_MOEDA == EE7->EE7_MOEDA .AND. EEQ->EEQ_SALDO > 0  // GFP - 23/08/2012 - Apenas carrega adiantamentos de moeda igual ao do processo.  // GFP - 29/08/2012 - Apenas carrega adiantamentos que possuam data de credito no exterior.
           Work_Adia->(DbAppend())

           //RMD - 11/05/12 - Carrega variáveis do banco para evitar erro no MsSeek
           RegToMemory("EEQ", .F.)

           AvReplace("EEQ","Work_Adia")
           Work_Adia->RECNO := EEQ->(RecNo())

        EndIf

        EEQ->(DbSkip())
     EndDo
  Next

  Work_Pgto->(DbGoTop())
  Do While Work_Pgto->(!Eof())
     If Work_Pgto->EEQ_FAOR == "C"
        Work_Pgto->WK_STATUS := STR0010
        If Work_Adia->(DbSeek(Work_Pgto->EEQ_FAOR+Work_Pgto->EEQ_PROR+Work_Pgto->EEQ_PAOR))
           Work_Adia->WK_FLAG  := cMarca
           Work_Adia->WK_VLADI := Work_Pgto->EEQ_VL
        EndIf
        Work_Adia->(DbGoTop())
     EndIf
     If Empty(Work_Pgto->EEQ_FAOR)
        Work_Pgto->WK_STATUS := STR0011
     EndIf

     Work_Pgto->(DbSkip())
  EndDo

  Work_Pgto->(DbGoTop())

  //** PLB 20/09/06 - Calcula valor já embarcado
  EEC->( DBSetOrder(1) )
  EE9->( DBSetOrder(1) )
  EE9->( DBSeek(xFilial("EE9")+EE7->EE7_PEDIDO) )
  Do While !EE9->( EoF() )  .And.  EE9->(EE9_FILIAL+EE9_PEDIDO) == EE7->(EE7_FILIAL+EE7_PEDIDO)
     If EEC->( DBSeek(xFilial("EEC")+EE9->EE9_PREEMB)  .And.  !Empty(EEC_DTEMBA) )
        nTotEmb += EE9->EE9_PRCTOT
     EndIf
     EE9->( DBSkip() )
  EndDo
  //**

  cTit        := STR0013+AllTrim(Transf(EE7->EE7_PEDIDO,AVSX3("EE7_PEDIDO",AV_PICTURE))) //"Processo: "
  aTela := {} ;  aGets := {}

   nTotProc := EE7->EE7_TOTPED

   IF EasyEntryPoint("EECAP105")
      EXECBLOCK("EECAP105",.F.,.F.,"ANTES_TELA_ADIAN")
   ENDIF

  Do While .T.

     nOpcao:= 0


     // by CRF 25/10/2010 14:33
     aCpos :=  AddCpoUser(aCpos,"EEQ","2")

     

     DEFINE MSDIALOG oDlg TITLE cTit FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

        oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165)
        oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

        @ 15,007 Say STR0014+AllTrim(EE7->EE7_MOEDA) Size 80,07  Of oPanel PIXEL //"Total Processo "
        @ 15,150 Say STR0015+AllTrim(EE7->EE7_MOEDA) Size 80,07  Of oPanel PIXEL//"Total Adiantamento(s) "
        // PLB - 20/09/06
        @ 15,305 Say STR0161+AllTrim(EE7->EE7_MOEDA) Size 80,07  Of oPanel PIXEL //"Total Embarcado "

        @ 15,70  MSGET nTotProc PICTURE AVSX3("EE7_TOTPED",AV_PICTURE) Size 050,07   Of oPanel Pixel When .f.
        @ 15,225 MSGET oGetTot VAR nTotAdia PICTURE AVSX3("EE7_TOTPED",AV_PICTURE) Size 050,07   Of oPanel Pixel When .f.
        // PLB - 20/09/06
        @ 15,365 MSGET nTotEmb PICTURE AVSX3("EE7_TOTPED",AV_PICTURE) Size 050,07   Of oPanel Pixel When .f.

        aPos := PosDlgDown(oDlg)
        aPos[1] := 70

        //DFS - 01/04/13 - Inclusão de array auxiliar private, que receberá o conteúdo do aButtons para utilização em Ponto de Entrada.
        aButtonsAux := aClone(aButtons)
        //FDR - 27/03/13 - PE para incluir legenda nas parcelas de adiatamento
        IF (EasyEntryPoint("EECAP105"),Execblock("EECAP105",.F.,.F.,"LEGENDA"),)
        //DFS - 01/04/13 - Retorno do array auxiliar private para o array aButtons, para que, retorne as informações customizadas.
        aButtons := aClone(aButtonsAux)

        oMsSelect := MsSelect():New("Work_Pgto",,,aCpos,,,aPos,,,,,aCores)
        oMsSelect:bAval := {|| AP100AdiMan(VIS_DET)}

        oDlg:lMaximized := .T.

     ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

     If nOpcao = 1
        lLoop:=.F.
        IF EasyEntryPoint("EECAP105")//AWR - 16/05/2006
           EXECBLOCK("EECAP105",.F.,.F.,"ANTES_GRAVA") //antes da gravacao da work de todos os adiantamentos Work_Pgto
        ENDIF
        IF lLoop
           Loop
        EndIf

        EasyEAIBuffer("INICIO")
        Begin Transaction
           Processa({|| Ap100RecAdian()})

           If __lSX8
              ConfirmSX8()
           Endif

        End Transaction
        ELinkClearID()
        EasyEAIBuffer("FIM",bOnError)

     Else
        If __lSX8
           //DFS - 06/10/12 - Chamada da função para salvar no logviewer as transações
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

// JPM - 02/12/05 - restaura filtro no EE7
nRecNoEE7 := EE7->(RecNo())
EECRestFilter(aEE7Filter)
EE7->(DbGoTo(nRecNoEE7))

RestOrd(aOrd)

Return lRet
/*
Funcao      : Ap105RetAdian()
Parametros  : nTipo  := VIS_DET/INC_DET/ALT_DET/EXC_DET
              oMsSelect := Objeto para refresh.
Retorno     : .T.
Objetivos   : Manutencao de adiantamentos. - (Pagamentos Antecipados)
Autor       : Jeferson Barros Jr.
Data/Hora   : 06/11/02 16:16.
Obs.        :
*/
Static Function Ap105RetAdian(cFuncName, nOpc)

Local nW, j

    ClrBufADP(EEQ->(Recno()))
    // MPG - 10/07/2018 - Estornar ação de exclusão quando a integração com Logix retornar erro
    iF nOpc == 5

        If ( nW := aScan(aRetEEQ,{|x| x[1] == EEQ->(Recno()) }) )  > 0  //For nW := 1 to len(aRetEEQ)
            //EEQ->( dbgoto( aRetEEQ[nW][1] ) )
            EEQ->(RecLock("EEQ",.F.))
            If EEQ->(Deleted())
               EEQ->(dbRecall())
            EndIf
            j := 1
            aEval( aRetEEQ[nW][2],{|x| EEQ->&(EEQ->(FIELDNAME(j))) := x , j++ })
            EEQ->(MsUnlock())
        EndIf //Next

    ElseIf nOpc == 3

        EEQ->(RecLock('EEQ',.F.))
        EEQ->EEQ_PGT  := cToD("  /  /  ")
        EEQ->EEQ_NROP := AvKey("","EEQ_NROP")
        EEQ->EEQ_TX   := 0
        EEQ->EEQ_EQVL := 0
        EEQ->(MsUnLock())

    EndIf

Return

/*
Funcao      : AC100AdiMan(nTipo)
Parametros  : nTipo  := VIS_DET/INC_DET/ALT_DET/EXC_DET
              oMsSelect := Objeto para refresh.
Retorno     : .T.
Objetivos   : Manutencao de adiantamentos. - (Pagamentos Antecipados)
Autor       : Jeferson Barros Jr.
Data/Hora   : 06/11/02 16:16.
Obs.        :
*/
*--------------------------------------------------*
Static Function AP100AdiMan(nTipo,oMsSelect,oGetTot)
*--------------------------------------------------*
Local bOk:={|| nOpcao := 1, If(AP100ValAdian(nTipo,nReg),oDlg:End(),nOpcao:=0)}, bCancel:={|| oDlg:End()}
Local aPos := {}, aSemSx3 := {}, aButtons:={}, aCposEditaveis
Local cTit := STR0016 //"Manutenção de Adiantamentos."
Local nOpcao := 0, nReg, i:=0
Local lRet := .t.
Local nPos := 0
Local oMsmGet1, oMsmGet2
Local lAdLiquidado
Local aOrdEEQ := {}
Private aGets:={}, aTela:={}
Private aAltera := {} // JPM - private para utilização em rdmake.
Private aEnchoice := {}//passou a ser private para utilização em rdmake.
Private nOpc := nTipo
Private nOpcAdClPd := If( nTipo ==  INC_DET .Or. nTipo == ALT_DET, 5, nTipo)//NCF - 01/10/2015 - Adiant. com Mov. Exterior
Private lEmbarcado := .F. // By JPP - 12/10/2006 - 10:00 - .F. - Informa que a manutenção de câmbio está sendo
                          // realizada sem a realização de um embarque. É o caso dos adiantamentos. Variável utilizada na validação do câmbio AF200Valid()

Begin Sequence

If lAdtMovExt             //NCF - 01/10/2015 - Adiant. com Mov. Exterior(Altera opções nas variáveis da MBrowse)
   If nTipo == ALT_DET .Or. nTipo == BXG_DET
      INCLUI := .F.
      ALTERA := .T.
   ElseIf nTipo == INC_DET
      INCLUI := .T.
      ALTERA := .F.
   EndIf
EndIf

   IF lValExclu .And. nTipo == EXC_DET .And. !EasyVerModal("Work_Pgto") .And. !Empty(Work_Pgto->EEQ_PGT) .And. Empty(Work_Pgto->EEQ_FAOR)  // TLM 11/06/2008
      Alert(STR0167,STR0022)  // Necessário apagar a data de liquidação antes da exclusão da parcela de andiantamento."###"Atenção"
      Break
   EndIf
   IF nTipo != INC_DET .And. Work_Pgto->(Eof()) .AND. Work_Pgto->(Bof())
      HELP(" ",1,"AVG0000632") //MsgInfo("Não existem registros para a manutenção !","Aviso")
      Break
   EndIf

   If nTipo == ALT_DET .Or. nTipo == EXC_DET

      If Work_Pgto->EEQ_VL <> Work_Pgto->EEQ_SALDO .AND. !Empty(Work_Pgto->EEQ_PGT) .OR. If( AVFLAGS("EEC_LOGIX"), !Empty(Work_Pgto->EEQ_FFC) , .F. )  // GFP - 29/08/2012
         If nTipo == ALT_DET                                                                                                                             // NCF - 14/05/2015 - Verificação de FFC (Integ. Logix)
            MsgStop(STR0017+Replic(ENTER,2)+; //"Este adiantamento não pode ser alterado."
                    STR0018+ENTER+;  //"Detalhes:"
                    STR0019 +ENTER+; //"Este adiantamento já está vinculado a fechamento(s) de cambio,"
                    STR0020 +ENTER+; //"para alterar o mesmo favor desvincular o adiantamento no{s) "
                    STR0021,STR0022) //"fechamento(s) de cambio correspondente(s)."###"Atenção"
         Else
            MsgStop(STR0023+Replic(ENTER,2)+; //"Este adiantamento não pode ser excluído."
                    STR0018+ENTER+;  //"Detalhes:"
                    STR0019 +ENTER+; //"Este adiantamento já está vinculado a fechamento(s) de cambio,"
                    STR0024 +ENTER+; //"para excluir o mesmo favor desvincular o adiantamento no{s) "
                    STR0021,STR0022) //"fechamento(s) de cambio correspondente(s)."###"Atenção"
         EndIf
         Break
      Else
         If Work_Pgto->EEQ_VL <> Work_Pgto->EEQ_SALDO .AND. Empty(Work_Pgto->EEQ_PGT) .AND. EasyGParam("MV_AVG0180")
            If nTipo == ALT_DET
               MsgStop(STR0017+Replic(ENTER,2)+; //"Este adiantamento não pode ser alterado."
                       STR0018+ENTER+;  //"Detalhes:"
                       STR0189 +ENTER+; //"Este adiantamento já está vinculado a Fase de Embarque,"
                       STR0020 +ENTER+; //"para alterar o mesmo favor desvincular o adiantamento no{s) "
                       STR0190,STR0022) //"Embarque(s) correspondente(s) ou executar a liquidação na Fase de Câmbio."
            EndIf
            Break
         EndIf
      EndIf
   EndIf

   //RMD - 12/11/07 - Nova legislação de câmbio
   If nTipo == BXG_DET .And. !Empty(Work_Pgto->EEQ_PAOR)
      MsgStop(STR0176 + ENTER + STR0177, STR0022)//###"Atenção" //STR0176 "Somente é possível efetuar a baixa de parcelas incluídas nesta fase." //STR0177	"Para parcelas associadas a baixa gerencial deve ser feita na rotina de adiantamentos do cadastro de clientes."
      Break
   EndIf

   //FSM - 05/10/2012
   If nTipo == EXC_DET .And. EasyIsVincAdiant(nTipo, Work_Pgto->EEQ_NRINVO, Work_Pgto->EEQ_PARC)
      Break
   EndIf

   // ** Campos da enchoice. // GFP - 23/08/2012 - Inclusao do campo de Nro.Titulo
   aEnchoice:={"EEQ_VL"   ,"EEQ_NROP","EEQ_PGT"   ,"EEQ_TX"  ,"EEQ_BANC"  ,"EEQ_AGEN"  ,;
               "EEQ_NCON" ,"EEQ_NOME","EEQ_NOMEBC","EEQ_CORR","EEQ_EQVL"  ,"EEQ_VLCORR",;
               "EEQ_DECAM","EEQ_RFBC","EEQ_DTCE"  ,"EEQ_NRINVO","EEQ_OBS" ,"EEQ_SOL"   ,"EEQ_DTNEGO", "EEQ_FINNUM"}

  If EEQ->(FieldPos("EEQ_MODAL")) > 0
     Aadd(aEnchoice,"EEQ_MODAL")
  EndIF

  If EEQ->(FieldPos("EEQ_BCOEXT")) > 0
     Aadd(aEnchoice,"EEQ_BCOEXT")
  EndIF

  If EEQ->(FieldPos("EEQ_AGCEXT")) > 0
     Aadd(aEnchoice,"EEQ_AGCEXT")
  EndIF

  If EEQ->(FieldPos("EEQ_CNTEXT")) > 0
     Aadd(aEnchoice,"EEQ_CNTEXT")
     Aadd(aEnchoice,"EEQ_NBCEXT")
  EndIF

   // ** Variaveis para evitar erros nos gatilhos.
   M->EEC_NRINVO := ""
   M->EEQ_VM_REC := 0

   If nTipo == INC_DET
      For i := 1 TO EEQ->(FCount())
         M->&(EEQ->(FieldName(i))) := CriaVar(EEQ->(FieldName(i)))
      Next
   Else
      For i := 1 TO Work_Pgto->(FCount())
         M->&(Work_Pgto->(FieldName(i))) := Work_Pgto->(FieldGet(i))
      Next
      if nTipo == VIS_DET .and. EasyVerModal("M")
         M->EEQ_BANC := ""
         M->EEQ_AGEN := ""
         M->EEQ_NCON := ""
         M->EEQ_NOMEBC := ""
      endif
      // ** Exibe o botão de histórico apenas para os adiantamentos que possuem algum vinculo.
      If Work_Pgto->EEQ_SALDO <> Work_Pgto->EEQ_VL
         aAdd(aButtons,{"HISTORIC",{|| AP100ViewHist()},STR0025}) //"Histórico"
      EndIf
   EndIf

    // ** CCH - 01/08/2008 - Tratamento para criação de campos Virtuais
   SX3->(DbSetOrder(1))
   SX3->(DbSeek("EEQ"))
   While SX3->(!Eof() .And. SX3->X3_ARQUIVO == "EEQ")
      If SX3->X3_CONTEXT == "V" .Or. SX3->X3_PROPRI == "U"
         If Work_Pgto->(FieldPos(SX3->X3_CAMPO)) > 0 .And. nTipo != INC_DET
               M->&(SX3->X3_CAMPO) := Work_Pgto->&(SX3->X3_CAMPO)
         Else
            M->&(SX3->X3_CAMPO) := CriaVar(SX3->X3_CAMPO)
         EndIf
      EndIf
      SX3->(DbSkip())
   EndDo
   // **

   nReg := Work_Pgto->(RecNo())

   M->EEQ_MOEDA  := EE7->EE7_MOEDA
   M->EEQ_EVENT  := "602"

   IF EasyEntryPoint("EECAP105")
	  If ValType((lRet := EXECBLOCK("EECAP105",.F.,.F.,"BROWSE_MANUT_ADTO"))) <> "L"
	     lRet := .T.
	  EndIf
	  If !lRet
	     Break
	  EndIf
   ENDIF

   //RMD - 10/11/07
   If nTipo == VIS_DET .Or. nTipo == EXC_DET
      aAltera := {}
   ElseIf nTipo == BXG_DET
      aAltera := {}
      aEnchoice := {}
      aAdd(aEnchoice, IncSpace("EEQ_DTCE", Len(SX3->X3_CAMPO), .F.))
      If Empty(M->EEQ_PGT)
         aAdd(aAltera, IncSpace("EEQ_DTCE"  , Len(SX3->X3_CAMPO), .F.))
      EndIf
      aAdd(aAltera, IncSpace("EEQ_CONTMV", Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_BCOEXT", Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_CNTEXT", Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_AGCEXT", Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_NBCEXT", Len(SX3->X3_CAMPO), .F.))
   ElseIf nTipo == ALT_DET .AND. Empty(M->EEQ_PGT) // GFP - 29/08/2012 - Permitir alteração dos campos apenas se data de liquidação estiver vazia.
      aAltera := {}
      aAdd(aAltera, IncSpace("EEQ_DTCE"  , Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_SOL"   , Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_DTNEGO", Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_PGT"   , Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_DECAM" , Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_NROP"  , Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_TX"    , Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_EEQVL" , Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_BANC"  , Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_AGEN"  , Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_NCON"  , Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_RFBC"  , Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_CORR"  , Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_OBS"   , Len(SX3->X3_CAMPO), .F.))
      //DFS - 08/11/12 - Caso a data de pagamento esteja preenchida, sistema bloqueia todos os campos.
   ElseIf nTipo == ALT_DET .AND. !Empty(M->EEQ_PGT)
      aAltera := {}
      If lAdtMovExt .And. EasyVerModal('M')                              //NCF - 01/10/2015 - Adiant. com Mov. Exterior
         aAdd(aAltera, IncSpace("EEQ_DTCE"   , Len(SX3->X3_CAMPO), .F.))
      Else
         aAdd(aAltera, IncSpace("EEQ_PGT"   , Len(SX3->X3_CAMPO), .F.))
         If IsIntEnable("001")
            AAdd(aAltera, IncSpace("EEQ_MOTIVO", Len(SX3->X3_CAMPO), .F.))
         EndIf
      EndIf
   Else
      aAltera := aClone(aEnchoice)
      If EECFlags("CAMBIO_EXT") .And. !AvFlags("EEC_LOGIX")
         If aScan(aAltera, "EEQ_DTCE") > 0
            aDel(aAltera, aScan(aAltera, "EEQ_DTCE"))
            aSize(aAltera, Len(aAltera) - 1)
         EndIf
      EndIf
      If aScan(aAltera, "EEQ_FINNUM") > 0  // GFP - 10/04/2014
         aDel(aAltera, aScan(aAltera, "EEQ_FINNUM"))
         aSize(aAltera, Len(aAltera) - 1)
      EndIf
   EndIf

   //RMD - 10/11/07 - Baixa Gerencial
   If EECFlags("CAMBIO_EXT")
      aAdd(aEnchoice, IncSpace("EEQ_CONTMV", Len(SX3->X3_CAMPO), .F.))
      aAdd(aEnchoice, IncSpace("EEQ_BCOEXT", Len(SX3->X3_CAMPO), .F.))
      aAdd(aEnchoice, IncSpace("EEQ_CNTEXT", Len(SX3->X3_CAMPO), .F.))
      aAdd(aEnchoice, IncSpace("EEQ_AGCEXT", Len(SX3->X3_CAMPO), .F.))
      aAdd(aEnchoice, IncSpace("EEQ_NBCEXT", Len(SX3->X3_CAMPO), .F.))
   EndIf

   //FSM - 05/10/2012
   If nTipo == ALT_DET .And. EasyIsVincAdiant(nTipo, M->EEQ_NRINVO, M->EEQ_PARC, .F.)
      If aScan(aCposEditaveis, "EEQ_NRINVO") > 0
         aDel(aCposEditaveis, aScan(aCposEditaveis, "EEQ_NRINVO"))
         aSize(aCposEditaveis, Len(aCposEditaveis) - 1)
      EndIf
      If aScan(aCposEditaveis, "EEQ_NROP") > 0
         aDel(aCposEditaveis, aScan(aCposEditaveis, "EEQ_NROP"))
         aSize(aCposEditaveis, Len(aCposEditaveis) - 1)
      EndIf
      If aScan(aCposEditaveis, "EEQ_VL") > 0
         aDel(aCposEditaveis, aScan(aCposEditaveis, "EEQ_VL"))
         aSize(aCposEditaveis, Len(aCposEditaveis) - 1)
      EndIf
   EndIf

   IF lCpoAcrDcr
     Aadd(aEnchoice,"EEQ_DECRES")
     If nTipo == INC_DET .Or. ( nTipo == ALT_DET .And. Empty(M->EEQ_PGT) )
        aAdd(aAltera, IncSpace("EEQ_DECRES"  , Len(SX3->X3_CAMPO), .F.))
     EndIf
   ENDIF

   IF lAdtMovExt                                                            //NCF - 01/10/2015 - Adiant. com Mov. Exterior
     Aadd(aEnchoice,"EEQ_PRINBC")
     Aadd(aEnchoice,"EEQ_VLMBCO")
     Aadd(aEnchoice,"EEQ_MOEBCO")
     If nTipo == INC_DET .Or. ( nTipo == ALT_DET .And. Empty(M->EEQ_PGT) )
        aAdd(aAltera, IncSpace("EEQ_PRINBC"  , Len(SX3->X3_CAMPO), .F.))
        aAdd(aAltera, IncSpace("EEQ_VLMBCO"  , Len(SX3->X3_CAMPO), .F.))
        aAdd(aAltera, IncSpace("EEQ_MODAL"   , Len(SX3->X3_CAMPO), .F.))
        aAdd(aAltera, IncSpace("EEQ_BCOEXT"  , Len(SX3->X3_CAMPO), .F.))
        aAdd(aAltera, IncSpace("EEQ_CNTEXT"  , Len(SX3->X3_CAMPO), .F.))
        aAdd(aAltera, IncSpace("EEQ_AGCEXT"  , Len(SX3->X3_CAMPO), .F.))
        aAdd(aAltera, IncSpace("EEQ_MOTIVO"  , Len(SX3->X3_CAMPO), .F.))
     EndIf
   ENDIF

   IF EasyEntryPoint("EECAP105") // JPM - 14/01/2010 - Ponto de entrada antes da tela.
      ExecBlock("EECAP105",.F.,.F.,"ANTES_TELA_MANUT_PARC")
   Endif

   DEFINE MSDIALOG oDlg TITLE cTit FROM 9,0 TO 35,80 OF oMainWnd    // GFP - 24/04/2012 - Ajuste para versão M11.5
      aPos := PosDlg(oDlg)
      oMsmGet1:= MsmGet():New("EEQ",,IF(nTipo=INC_DET,3,4),,,,aEnchoice,aPos,aAltera,3) //wfs
      oMsmGet1:oBox:Align:= CONTROL_ALIGN_ALLCLIENT

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons) CENTERED

   If nOpcao = 1
      If nTipo == INC_DET
         Work_Pgto->(DbAppend())
         nReg := Work_Pgto->(RecNo())
         AvReplace("M","Work_Pgto")
         Work_Pgto->WK_STATUS  := STR0011 //"Normal"
         Work_Pgto->EEQ_PREEMB := EE7->EE7_PEDIDO
         Work_Pgto->EEQ_FASE   := "P"
         Work_Pgto->EEQ_TIPO   := "A"
         Work_Pgto->EEQ_PARC   := Ap100CalcParc()
         Work_Pgto->EEQ_SALDO  := Work_Pgto->EEQ_VL

      ElseIf nTipo == ALT_DET .Or. nTipo == BXG_DET
         //NCF - 09/11/2017 - Não permitir que as variáveis
         If lAdtMovExt
            If !Empty(Work_Pgto->EEQ_BCOEXT) .And. !Empty(Work_Pgto->EEQ_AGCEXT) .And. !Empty(Work_Pgto->EEQ_CNTEXT) .And. ;
                Empty(M->EEQ_BANC) .And. Empty(M->EEQ_AGEN) .And. Empty(M->EEQ_NCON)
               M->EEQ_BANC   := Work_Pgto->EEQ_BCOEXT
               M->EEQ_AGEN   := Work_Pgto->EEQ_AGCEXT
               M->EEQ_NCON   := Work_Pgto->EEQ_CNTEXT
            EndIf
         EndIf

         AvReplace("M","Work_Pgto")
         //NCF - 28/07/2015 - tem que comparar com a tabela aqui pra saber se a cambial está liquidada, pois pode
         //                   ter alterado o campo na Enchoice sem ter confirmado a rotina.
         aOrdEEQ := SaveOrd("EEQ")
         EEQ->(DbSetORder(6))
         lAdLiquidado := EEQ->(DbSeek(   Work_Pgto->(xFilial('EEQ') + EEQ_FASE + EEQ_PREEMB + EEQ_PARC) )) .And. !Empty( EEQ->EEQ_PGT )
         RestOrd(aOrdEEQ,.T.)
         If /*Empty(Work_Pgto->EEQ_PGT)*/ !lAdLiquidado    // GFP - 31/08/2012
            Work_Pgto->EEQ_SALDO  := Work_Pgto->EEQ_VL
         EndIf
      EndIf

      IF EasyEntryPoint("EECAP105")           //SVG - Solicitação Ponto de Entrada Chamado 076095
         EXECBLOCK("EECAP105",.F.,.F.,{"ADIMAN_FINAL", nTipo}) //após a gravação da parcela na workPgto
      ENDIF
      Work_Pgto->(DbGoTop())
      If nTipo <> VIS_DET
         AP100TotAdian() //** Atualiza o total dos adiantamentos do processo.
         oMsSelect:oBrowse:Refresh()
         oGetTot:Refresh()
      EndIf
   EndIf

End Sequence

Return lRet

/*
Funcao      : AP100ValAdian(nTipo,nReg).
Parametros  : nTipo => Opcao
              nReg  => Nro. Registro.
Retorno     : .t./.f.
Objetivos   : Efetuar validação dos campos.
Autor       : Jeferson Barros Jr.
Data/Hora   : 06/11/02 16:40.
Obs.        : WFS 28/08/09
              Reformulação no cálculo do saldo disponível para inclusão das parcelas de adiantamento.
              Substituição da variável nTotAdia pela nEEQSaldo.
*/
*---------------------------------------*
Static Function AP100ValAdian(nTipo,nReg)
*---------------------------------------*
Local lRet:=.t.
//Local nTotal:= nEEQSaldo + nTotEmb
Local aOrd := {}

Begin Sequence

   If Str(nTipo,1) $ Str(INC_DET,1)+"/"+Str(ALT_DET,1)

      If !Obrigatorio(aGets,aTela)
         lRet := .f.
         Break
      Endif

      If M->EEQ_VL == 0
         MsgInfo(STR0026,STR0027)  //"Valor do adiantamento inválido."###"Aviso"
         lRet:=.f.
         Break
      EndIf

      //*** RMD - 19/12/07 - Validação do banco
      If !Empty(M->EEQ_BANC) .Or. !Empty(M->EEQ_AGEN) .Or. !Empty(M->EEQ_NCON)
         SA6->(DbSetOrder(1))
         If !(lRet := SA6->(DbSeek(xFilial()+M->(EEQ_BANC+EEQ_AGEN+EEQ_NCON))))
            MsgInfo(STR0178 + ENTER + STR0179, STR0016)//"Aviso" //STR0178	"A conta informada não existe no cadastro de bancos." //STR0179	"Escolha uma conta válida."
            Break
         EndIf
      EndIf
            
      //***

      If !Empty(M->EEQ_PGT)
         // ** Valida a Taxa
         If M->EEQ_TX = 0
            MsgInfo(STR0028,STR0022) //"A taxa utilizada para fechamento de câmbio deve ser informada."###"Atenção"
            lRet:=.f.
            Break
         EndIf

         // ** Valida o numero da operação.
         If !Empty(M->EEQ_PGT) .AND. Empty(M->EEQ_NROP)
            MsgInfo(STR0029,STR0022) //"Número da operação deve ser informado."###"Atenção"
            lRet:=.f.
            Break
         EndIf

         // ** Valida a data de solicitação de crédito no exterior.
         If Empty(M->EEQ_DTCE)
            MsgInfo(STR0168,STR0022) //"Data de crédito no exterior deve ser preenchida."###"Atenção"
            lRet:=.f.
            Break
         EndIf
         // ** Valida o codigo do banco.
         If !Empty(M->EEQ_PGT) .AND. If(lAdtMovExt .And. EasyVerModal('M'),Empty(M->EEQ_BCOEXT),Empty(M->EEQ_BANC))  //NCF - 01/10/2015 - Adiant. com Mov. Exterior
            MsgInfo(STR0030,STR0022) //"O banco utilizado para fechamento de câmbio deve ser informado."###"Atenção"
            lRet:=.f.
            Break
         EndIf      
      Else
         /*  Nopado por GFP - 05/09/2012
         // ** Para a dt. de liquidacao vazia o nro de operacao nao deve ser informado.
         If !Empty(M->EEQ_NROP)
            MsgInfo(STR0031+Replic(ENTER,2)+; //"Os dados do adiantamento estão inválidos."
                    STR0018+ENTER+; //"Detalhes:"
                    STR0032+AllTrim(AVSX3("EEQ_PGT",AV_TITULO))+STR0033+ENTER+; //"Se a "###" estiver em aberto,"
                    STR0034+AllTrim(AVSX3("EEQ_NROP",AV_TITULO))+STR0035+; //"o campo "###" e o campo "
                    AllTrim(AVSX3("EEQ_TX",AV_TITULO))+STR0036,STR0022) //" não devem ser preenchidos."###"Atenção"
            lRet:=.f.
            Break
         EndIf
         */

         // ** Valida o numero da operação. // GFP - 05/09/2012
         If !Empty(M->EEQ_PGT) .AND. Empty(M->EEQ_NROP)
            MsgInfo(STR0185,STR0022) //"Número da operação deve ser informado."###"Atenção"
            lRet:=.f.
            Break
         EndIf

         // ** Valida a moeda da operação.    // GFP - 05/09/2012
         If Empty(M->EEQ_MOEDA)
            MsgInfo(STR0186,STR0022) //"A moeda deve ser informada."###"Atenção"
            lRet:=.f.
            Break
         EndIf

         // ** Valida o codigo do banco.     // GFP - 05/09/2012
         If !Empty(M->EEQ_PGT) .AND. If(lAdtMovExt .And. EasyVerModal('M'),Empty(M->EEQ_BCOEXT),Empty(M->EEQ_BANC))  //NCF - 01/10/2015 - Adiant. com Mov. Exterior
            MsgInfo(STR0187,STR0022) //"O banco utilizado para fechamento de câmbio deve ser informado."###"Atenção"
            lRet:=.f.
            Break
         EndIf

         // Valida data de credito no exterior   // GFP - 05/09/2012
         If If(lAdtMovExt .And. EasyVerModal('M') .and. nOpc == 5,.F.,Empty(M->EEQ_DTCE))              //NCF - 01/10/2015 - Adiant. com Mov. Exterior
            MsgInfo(STR0188,STR0022) //"A data de crédito no exterior deve ser informada."###"Atenção"
            lRet:=.f.
            Break
         EndIf
      EndIf
/*
      If nTipo == ALT_DET
         nTotal -= Work_Pgto->EEQ_VL         
      EndIf
      */

//      If (M->EEQ_VL+nTotal) > nTotProc //.And. If(lAdtMovExt .And. EasyVerModal('M') .and. nOpc == 5,.F.,Empty(M->EEQ_DTCE)) //NCF - 01/10/2015 - Adiant. com Mov. Exterior
        If (nEEQSaldo) > nTotProc //MFR 17/08/2021 OSSME-6140
         MsgInfo(STR0037+Replic(ENTER,2)+; //"Valor de adiantamento inválido."
                 STR0018+ENTER+;  //"Detalhes:"
                 STR0038+ENTER+;  //"Com o valor informado, o total de adiantamento(s) ultrapassa "
                 STR0162+ENTER+; //"o valor disponivel para adiantamento(s) do processo:"
                AllTrim(EE7->EE7_MOEDA)+" "+AllTrim(Transform(nEEQSaldo,AVSX3("EE7_TOTPED",AV_PICTURE)))+".",STR0027)
                 // AllTrim(EE7->EE7_MOEDA)+" "+AllTrim(Transform(nTotProc-nTotal,AVSX3("EE7_TOTPED",AV_PICTURE)))+".",STR0027)
         lRet:=.f.
         Break
      EndIf

   Elseif nTipo == EXC_DET

      If MsgYesNo(STR0040,STR0027) //"Confirma exclusão do Registro Atual ?"###"Aviso"

         Work_Pgto->(DbSetOrder(2))
         Work_Pgto->(DbGoTo(nReg))

         If Work_Pgto->RECNO != 0
            aAdd(aDeletados,Work_Pgto->RECNO)
         EndIf

         If Work_Pgto->EEQ_FAOR = "C" // Indica que o adiantamento foi associado a partir do importador.
            If Work_Adia->(DbSeek(Work_Pgto->EEQ_FAOR+Work_Pgto->EEQ_PROR+Work_Pgto->EEQ_PAOR))
               Work_Adia->(RecLock("Work_Adia",.f.))
               Work_Adia->WK_FLAG   := ""
               Work_Adia->EEQ_SALDO += Work_Adia->WK_VLADI
               Work_Adia->WK_VLADI  := 0
               Work_Adia->(MsUnLock())
            Else
               aOrd:=SaveOrd("EEQ")
               EEQ->(DbSetOrder(6))
               EEQ->(DbSeek(xFilial("EEQ")+Work_Pgto->EEQ_FAOR+Work_Pgto->EEQ_PROR+Work_Pgto->EEQ_PAOR))
               Work_Adia->(DbAppend())               
               RegToMemory("EEQ", .F.)
               AvReplace("EEQ","Work_Adia")
               Work_Adia->WK_FLAG   := ""
               Work_Adia->EEQ_SALDO += Work_Pgto->EEQ_SALDO
               Work_Adia->(MsUnLock())
               RestOrd(aOrd)
            EndIf
         EndIf

         aOrd := SaveOrd("Work_Pgto")
         Work_Pgto->(RecLock("Work_Pgto",.f.))
         Work_Pgto->(DbDelete())
         Work_Pgto->(MsUnLock())
         RestOrd(aOrd)         
      Else
         lRet := .F.
         Break
      EndIf
   ElseIf nTipo == BXG_DET
      SA6->(DbSetOrder(1))
      If !(lRet := SA6->(DbSeek(xFilial()+M->(EEQ_BCOEXT+EEQ_AGCEXT+EEQ_CNTEXT))))
         MsgInfo(STR0178 + ENTER + STR0179, STR0016)//"Aviso" //STR0178	"A conta informada não existe no cadastro de bancos." //STR0179	"Escolha uma conta válida."
         Break
      EndIf
      If IsBancoExt(M->EEQ_BCOEXT, M->EEQ_AGCEXT, M->EEQ_CNTEXT) .AND. !(lRet := SA6->A6_MOEEASY == M->EEQ_MOEDA)
         MsgInfo(STR0180 + ENTER + STR0181, STR0022) //STR0180	"A moeda da conta escolhida é diferente da moeda da parcela." //STR0181	 "Escolha uma conta na mesma moeda da parcela." //STR0022	"Atenção"
         Break
      EndIf
   EndIf

   IF EasyEntryPoint("EECAP105") // ** JPM - ponto de entrada na validação da alteração da parcela.
      Private lRetPonto := lRet, nTipoOp := nTipo

      ExecBlock("EECAP105",.F.,.F.,"VALIDA_MANUT_PARC") //Validações adicionais ao salvar as parcelas de câmbio

      If ValType(lRetPonto) = "L"
         lRet := lRetPonto
      EndIf
   Endif

End Sequence

Return lRet

/*
Funcao      : Ap100RecAdian().
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Gravar Adiantamentos do Cliente.
Autor       : Jeferson Barros Jr.
Data/Hora   : 06/11/2002 - 16:48.
Revisao     :
Obs.        :
*/
*-----------------------------*
STATIC Function Ap100RecAdian()
*-----------------------------*
Local lRet := .t.,j := 0 , i:=0, aOrd:=SaveOrd("EEQ")
Local aCposInt:= {"EEQ_NRINVO","EEQ_VL","EEQ_DTCE","EEQ_PGT","EEQ_NROP","EEQ_TX","EEQ_BANC","EEQ_AGEN","EEQ_NCON"}
Local lAltTit:= .F.
Local lEliminaSld := .F., lEstEliSld := .F.  // GFP - 21/08/2012
Local lGerou := lBaixou := .F.  // GFP - 03/09/2012
Private cSeek:= 'SE1->(DbSeek(xFilial()+"EEC"+AvKey(EEQ->EEQ_FINNUM, "E1_NUM")+AvKey(" ", "E1_PARCELA")+AvKey(TETpTitEEQ("EEQ"),"E1_TIPO")))' //NCF - 04/07/2019

If Type("lRollBack") <> "L"
   lRollBack := .F.
EndIf

Begin Sequence

   ProcRegua(Work_Pgto->(LastRec())+1+Work_Adia->(LastRec())+1)
   IncProc(STR0041) //"Atualizando arquivos ..."

   For i:=1 To Len(aDeletados)
      If ValType(aDeletados[i]) == "U"
        Loop
      EndIf

      IncProc()
      EEQ->(DbGoTo(aDeletados[i]))
      // MPG - 10/07/2018 - Estornar ação de exclusão quando a integração com Logix retornar erro
      aReg := {}
      FOR j:=1 To EEQ->(Fcount())
          aAdd(aReg, &("EEQ->"+EEQ->(FIELDNAME(j)) ) )
      Next j
      aAdd( aRetEEQ , {aDeletados[i],aClone(aReg)} )
      lPgt := !Empty(EEQ->EEQ_PGT)
      //Alcir
      IF EasyEntryPoint("EECAP105")
          EXECBLOCK("EECAP105",.F.,.F.,"EXC_ADIANTAMENTO")
      ENDIF
      EEQ->(RecLock("EEQ",.f.))
      //RMD - 10/11/07 - Nova Legislação Câmbio
      If EECFlags("CAMBIO_EXT")
          //Exclui as movimentações
          AD101GrvInv("EEQ", "EEQ", "EXPBXG", .T.)
          AD101GrvInv("EEQ", "EEQ", "EXPLIQ", .T.)
      EndIf
      //RMD - 02/02/07 - Integração com o SIGAFIN e SIGACTB
      If !Empty(EEQ->EEQ_FINNUM) .And. EEQ->EEQ_FAOR != "C"
          If !AvStAction("002")
            lRollBack := .T.
            Exit
          EndIf
      EndIf
      EEQ->(DbDelete())
      EEQ->(MSUnlock())

   Next

   Work_Pgto->(dbGoTop())
   DbSelectArea("EEQ")
   EEQ->(DbSetOrder(1))

   Do While Work_Pgto->(!Eof()) .And. (AvFlags("EEC_LOGIX") .Or. !lRollBack)
      IncProc()

      //DFS - 24/01/13 - Realimentando as flags de teste todas as vezes que forem verificar determinado adiantamento.
      lEliminaSld := .F.
      lEstEliSld  := .F.

      If !(EEQ->(DbSeek(xFilial("EEQ")+AvKey(Work_Pgto->EEQ_PREEMB,"EEQ_PREEMB")+AvKey(Work_Pgto->EEQ_PARC,"EEQ_PARC")+AvKey(Work_Pgto->EEQ_FASE,"EEQ_FASE"))))
         // ** JPM - 14/12/2010 - Ponto de entrada na inclusão de parcelas
         IF EasyEntryPoint("EECAP105")
            EXECBLOCK("EECAP105",.F.,.F.,"INCLUINDO_EEQ")
         ENDIF

         //RMD - 10/11/07 - Nova Legislação Câmbio
         If EECFlags("CAMBIO_EXT")
            //Grava as movimentações
            AD101GrvInv("EEQ", "Work_Pgto", "EXPBXG",, Work_Pgto->RECNO <> 0)
            AD101GrvInv("EEQ", "Work_Pgto", "EXPLIQ",, Work_Pgto->RECNO <> 0)
         EndIf
         EEQ->(RecLock("EEQ",.t.))
         EEQ->EEQ_FILIAL := xFilial("EEQ")
         AvReplace("Work_Pgto","EEQ")
         EEQ->EEQ_EVENT := "602"
         EEQ->EEQ_NR_CON:= ""
         EEQ->EEQ_EMISSA := dDataBase  //NCF - 07/06/2021

         // BAK - Tratamento para salvar o campo EEQ_VCT e EEQ_HVCT
         If EEQ->(FieldPos("EEQ_VCT")) > 0 .And. EEQ->(FieldPos("EEQ_HVCT")) > 0
            If !Empty(EEQ->EEQ_PGT)
               EEQ->EEQ_VCT := EEQ->EEQ_PGT //LRS - 23/09/2015
            Else
               EEQ->EEQ_VCT := dDataBase
            EndIf
            EEQ->EEQ_HVCT := EEQ->EEQ_VCT
         EndIf

         // Para a rotina com os tratamentos de frete/seguro/comissão os campos abaixo
         // devem ser alimentados.
         If EECFlags("FRESEGCOM")
            EEQ->EEQ_MOEDA  := EE7->EE7_MOEDA
            EEQ->EEQ_IMPORT := EE7->EE7_IMPORT
            EEQ->EEQ_IMLOJA := EE7->EE7_IMLOJA
         EndIf

         //RMD - 02/02/07 - Integração com o SIGAFIN e SIGACTB
         //If IsIntEnable("001")
            If !Empty(EEQ->EEQ_PGT) .And. Empty(EEQ->EEQ_FAOR)
               If !AvStAction("001") //DFS - 16/05/12 - Inclusão de tratamento para não salvar a inclusão do adiantamento se não for incluso anteriormente no Financeiro
                  lRollBack := .T.
               EndIf
            EndIf

            //FSM - 08/10/2012
            If !lRollBack .And. lFinanciamento .And. lIntFina
               EasyLiqContAdian()
            EndIf
        // EndIf
      Else
         //EEQ->(dbGoTo(Work_Pgto->RECNO)) nopado por AOM em 25/03/10

          // MPG - 10/07/2018 - Estornar ação de exclusão quando a integração com Logix retornar erro
          aReg := {}
          FOR i:=1 To EEQ->(Fcount())
              aAdd(aReg, &("EEQ->"+EEQ->(FIELDNAME(i)) ) )
          Next i
          aAdd( aRetEEQ , {Work_Pgto->RECNO,aClone(aReg)} )

         lAltTit:= AvGeraTit("Work_Pgto", "EEQ", aCposInt) //Verifica se houve alteração que implica na recriação dos títulos no financeiro (sigafin)

         // ** JPM - 14/12/2010 - Ponto de entrada na alteração de parcelas
         IF EasyEntryPoint("EECAP105")
            EXECBLOCK("EECAP105",.F.,.F.,"ALTERANDO_EEQ")
         ENDIF

         If EEQ->(FieldPos("EEQ_SLDELI")) > 0
         	//RMD - 11/05/12 - Baixa o saldo eliminado no financeiro
            If !Empty(Work_Pgto->EEQ_SLDELI) .And. Empty(EEQ->EEQ_SLDELI)
               lEliminaSld := .T.
            EndIf
            If Empty(Work_Pgto->EEQ_SLDELI) .And. !Empty(EEQ->EEQ_SLDELI)
               lEstEliSld := .T.
            EndIf
         EndIf

         //RMD - 10/11/07 - Nova Legislação Câmbio
         If EECFlags("CAMBIO_EXT")
            //Grava as movimentações
            AD101GrvInv("EEQ", "Work_Pgto", "EXPBXG",, Work_Pgto->RECNO <> 0)
            AD101GrvInv("EEQ", "Work_Pgto", "EXPLIQ",, Work_Pgto->RECNO <> 0)
         EndIf

         EEQ->(RecLock("EEQ",.f.))
         AvReplace("Work_Pgto","EEQ")
         EEQ->EEQ_EVENT := "602"
         EEQ->EEQ_NR_CON:= ""

		 // BAK - Tratamento para salvar o campo EEQ_VCT e EEQ_HVCT
         If EEQ->(FieldPos("EEQ_VCT")) > 0 .And. EEQ->(FieldPos("EEQ_HVCT")) > 0
            If !Empty(EEQ->EEQ_PGT)
               EEQ->EEQ_VCT := EEQ->EEQ_PGT //LRS - 23/09/2015
            EndIf
         EndIf

         // Para a rotina com os tratamentos de frete/seguro/comissão os campos abaixo
         // devem ser alimentados.
         If EECFlags("FRESEGCOM")
            EEQ->EEQ_MOEDA  := EE7->EE7_MOEDA
            EEQ->EEQ_IMPORT := EE7->EE7_IMPORT
            EEQ->EEQ_IMLOJA := EE7->EE7_IMLOJA
         EndIf

         //RMD - 02/02/07 - Integração com o SIGAFIN e SIGACTB
         //If IsIntEnable("001")
            If Empty(EEQ->EEQ_PGT)
               If !Empty(EEQ->EEQ_FINNUM)
                  //NCF - 15/05/2015 - Verificar estorno automático da liquidação do adiantamento
                  If AvFlags("EEC_LOGIX") .and. !Empty(EEQ->EEQ_SEQBX)
                     If !AvStAction("009")
                        lRollBack := .T.
                     EndIf
                     lAF212EsBxAuto := .T.
                  EndIf

                  If !AvStAction("002") //DFS - 16/05/12 - Exclusão de tratamento para não salvar o estorno do adiantamento se não for incluso anteriormente no Financeiro
                     lRollBack := .T.
                  EndIf

                  //NCF - 15/05/2015
                  lAF212EsBxAuto := .F.

                  //FSM - 08/10/2012
                  If !lRollBack .And. lFinanciamento .And. lIntFina
                     EasyEstLiqContAdian()
                  EndIf

               EndIf
            ElseIf Empty(EEQ->EEQ_FAOR)
               If Empty(EEQ->EEQ_FINNUM) .And. EEQ->EEQ_SALDO > 0
                  If !AvStAction("001") //DFS - 16/05/12 - Inclusão de tratamento para não salvar a inclusão do adiantamento se não for incluso no Financeiro
                     lRollBack := .T.
                  Else
                     lGerou := .T.   // GFP - 03/09/2012
                  EndIf

                  //FSM - 08/10/2012
                  If !lRollBack .And. lFinanciamento .And. lIntFina
                     EasyLiqContAdian()
                  EndIf
               ElseIf EEQ->EEQ_SALDO > 0 .And. lAltTit .And. (!IsIntEnable("001") .Or. (&cSeek))  //WFS 10/03/09
                  If !AvStAction("003") //DFS - 16/05/12 - Inclusão de tratamento para não salvar a alteração do adiantamento se não for incluso no Financeiro
                     lRollBack := .T.
                  EndIf
               ElseIf lEliminaSld .Or. lEstEliSld
                  IF !Empty(EEQ->EEQ_FINNUM) .And. (!IsIntEnable("001") .Or. (&cSeek))
                     If lEstEliSld
                        SE5->(DbSetOrder(7))
                        If lRet := SE5->(DbSeek(xFilial()+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))
                           nParcEst := 1
                           lRet := AvStAction("009")//Estorno de Baixa de Titulo a Receber
                           If !lRet //DFS - 16/05/12 - Inclusão de tratamento para não salvar o estorno da baixa se não for incluso anteriormente no Financeiro
                              lRollBack := .T.
                           EndIf
                        EndIf
                     Else
                        If !Empty(EEQ->EEQ_PGT)
                           nValorBaixa:= EEQ->EEQ_EQVL
                           dDtBaixa   := EEQ->EEQ_PGT
                           lRet := AvStAction("008")//Baixa de Titulo a Receber
                           If !lRet //DFS - 16/05/12 - Inclusão de tratamento para não salvar a baixa se não for incluso anteriormente no Financeiro
                              lRollBack := .T.
                           EndIf
                        EndIf
                     EndIf
                  EndIf
               EndIf
            EndIf
         //EndIf
      EndIf
      If !lRollBack
           //GFP - 31/08/2012 - Tratamento de Baixa de adiantamentos após vinculação em embarques.
         If(lGerou, lBaixou := AC100BxAdian(EEQ->EEQ_PREEMB,EEQ->EEQ_PARC,EEQ->EEQ_FASE,EEQ->EEQ_FINNUM, EEQ->EEQ_PGT, EEQ->EEQ_TX),)

         //RMD - 25/11/08 - Todas as parcelas geradas pela exportação devem conter o identificador "1 - Cambio de Exportação" no campo EEQ_TP_CON
         If EEQ->(FieldPos("EEQ_TP_CON")) > 0
              EEQ->EEQ_TP_CON := "1"
         EndIf

         EEQ->(MSUNLOCK())

         //Alcir
         IF EasyEntryPoint("EECAP105")
            EXECBLOCK("EECAP105",.F.,.F.,"INC_ADIANTAMENTO")
         ENDIF
      EndIf 
      Work_Pgto->(DbSkip())
       
   EndDo

   IF EasyEntryPoint("EECAP105")//AWR - 16/05/2006
      EXECBLOCK("EECAP105",.F.,.F.,"ANTES_DELETA")
   ENDIF


   // ** Atualiza os adiantamentos vinculados do importador.
   EEQ->(DbSetOrder(6))

   If (AvFlags("EEC_LOGIX") .Or. !lRollBack)
      Work_Adia->(DbGoTop())
      Do While Work_Adia->(!Eof())
          If EEQ->(DbSeek(xFilial("EEQ")+"C"+Work_Adia->EEQ_PREEMB+Work_Adia->EEQ_PARC))
            EEQ->(RecLock("EEQ",.f.))
            EEQ->EEQ_SALDO := Work_Adia->EEQ_SALDO
            EEQ->(MsUnLock())
          EndIf
          Work_Adia->(DbSkip())
      EndDo

   EndIf

   If lRollBack .And. !AvFlags("EEC_LOGIX") //DFS - 16/05/12 - Mensagem impeditiva, a variavel logica for .T.
      MsgInfo(STR0183)  // "A gravação não ocorreu devido à impossibilidade de integração com o módulo Financeiro. Verifique o Log Viewer."
      //DFS - 06/10/12 - Chamada da função para salvar no logviewer as transações
      ELinkRollBackTran()
   EndIf


End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : AP100CalcParc().
Parametros  : Nenhum.
Retorno     : nParc => Nro da proxima parcela.
Objetivos   : Calcular próximo nro da parcela.
Autor       : Jeferson Barros Jr.
Data/Hora   : 06/11/02 16:54.
Obs.        :
*/
*-----------------------------*
Static Function AP100CalcParc()
*-----------------------------*
Local cParc:="01", nRec:=Work_Pgto->(RecNo())
Local aParc:={}

Begin Sequence

   Work_Pgto->(DbGoTop())
   Do While Work_Pgto->(!Eof())
      aAdd(aParc,Work_Pgto->EEQ_PARC)
      Work_Pgto->(DbSkip())
   EndDo

   aSort(aParc,,,{|x,y| x > y })

   //AOM - 23/03/10
   If Len(aParc) > 0 .And. !Empty(aParc[1])
      cParc := aParc[1]
   Else
      cParc := aParc[1] := "00"
   EndIf

   //RMD - Gravar letras na sequência visto que o campo possui tamanho 2
   cParc := SomaIt(AllTrim(aParc[1]))

End Sequence

Work_Pgto->(DbGoTo(nRec))

Return cParc

/*
Funcao      : AP100ViewHist().
Parametros  : Nenhum.
Retorno     : .T.
Objetivos   : Vizualização do histórico do adiantamento.
Autor       : Jeferson Barros Jr.
Data/Hora   : 08/11/02 10:22.
Obs.        :
*/
*-----------------------------*
Static Function AP100ViewHist()
*-----------------------------*
Local aOrd:=SaveOrd("EEQ"), aPos:={}, aHist_Ped:={}
Local bOk:={|| oDlg:End()}, bCancel:={|| oDlg:End()}
Local cDesc, cTit := STR0042  //"Histórico."
Local nValAdian := 0
Local dDtAdian  := AvCtod("")
Local oTree, oDlg, oPanel1, oPanel2
Local lRet:=.t.

Begin Sequence

   //ER - 20/06/2006 às 10:30
   If Work_Pgto->(EOF()) .or. Work_Pgto->(BOF())
      HELP(" ",1,"AVG0000632") //MsgInfo("Não existem registros para a manutenção !","Aviso")
      Break
   EndIf

   If Work_Pgto->EEQ_SALDO == Work_Pgto->EEQ_VL
      MsgInfo(STR0160,STR0027)//"Não existe histórico para esse item."###"Aviso"
      Break
   EndIf

   EEQ->(DbSetOrder(7))

   SA1->(DbSetOrder(1))
   SA1->(DbSeek(xFilial("SA1")+EE7->EE7_IMPORT+EE7->EE7_IMLOJA))

   // ** Faz a leitura dos processos que utilizaram o adiantamento solicitado para a fase de pedido e embarque.
   If !EEQ->(DbSeek(xFilial("EEQ")+"P"+Work_Pgto->EEQ_PREEMB+Work_Pgto->EEQ_PARC))
      Break
   EndIf

   Do While EEQ->(!Eof()) .And. EEQ->EEQ_FILIAL == xFilial("EEQ") .And.;
                                EEQ->EEQ_FAOR   == "P" .And.;
                                EEQ->EEQ_PROR   == Work_Pgto->EEQ_PREEMB .And.;
                                EEQ->EEQ_PAOR   == Work_Pgto->EEQ_PARC
      If EEQ->EEQ_FASE =="E"
         EXJ->(DbSetOrder(1))
         EXJ->(DbSeek(xFilial("EXJ")+SA1->A1_COD+SA1->A1_LOJA))

         cDesc := STR0043+AllTrim(EEQ->EEQ_PREEMB)+STR0044+AllTrim(EXJ->EXJ_MOEDA)+Space(2)+;  //"Cambio/Embarque: "###" - Valor: "
                  AllTrim(Transf(EEQ->EEQ_VL,AVSX3("EEQ_VL",AV_PICTURE)))
         aAdd(aHist_Ped,cDesc)
      EndIf

      EEQ->(DbSkip())
   EndDo

   // ** By JBJ - 15/03/04 - Visualizar a Dt.Pagto.
   dDtAdian  := Work_Pgto->EEQ_DTCE // Work_Pgto->EEQ_VCT
   nValAdian := Work_Pgto->EEQ_VL

   DEFINE MSDIALOG oDlg TITLE cTit FROM 9,0 TO 35,80 OF oMainWnd

      aPos := PosDlg(oDlg)

      oPanel1:= TPanel():New(0, 0, "",oDlg, , .F., .F.,,, aPos[4], aPos[3]*0.17)
      oPanel2:= TPanel():New(0, 0, "",oDlg, , .F., .F.,,, aPos[4], aPos[3]*0.75)

      @ 02,02 TO aPos[3]*0.17, aPos[4]-1 LABEL STR0045 Pixel Of oPanel1 //"Detalhes do Adiantamento"

      @ 15,007 Say STR0046  Size 65,07 Pixel Of oPanel1 //"Data"
      @ 15,080 Say STR0003  Size 65,07 Pixel Of oPanel1 //"Valor"
      @ 15,160 Say STR0004  Size 65,07 Pixel Of oPanel1 //"Saldo"

      @ 14,030 MSGET dDtAdian  PICTURE AVSX3("EEQ_VCT",AV_PICTURE) Size 040,07 Pixel Of oPanel1 When .f.
      @ 14,105 MSGET nValAdian PICTURE AVSX3("EEQ_VL",AV_PICTURE)  Size 045,07 Pixel Of oPanel1 When .f.
      @ 14,185 MSGET Work_Pgto->EEQ_SALDO PICTURE AVSX3("EEQ_VL",AV_PICTURE)  Size 045,07 Pixel Of oPanel1 When .f.

      oTree := DbTree():New(002,002,aPos[3]*0.74,aPos[4]-1,oPanel2,,,.T.)

      // ** Efetua a leitura de todos os itens para montagem do tree.
      AP100ReadTree(oTree,aHist_Ped)

      // wfs - alinhamento de tela
      oPanel1:Align:= CONTROL_ALIGN_TOP
      oPanel2:Align:= CONTROL_ALIGN_ALLCLIENT

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED

End Sequence

RestOrd(aOrd)

Return lRet
/*
Funcao      : AP100ReadTree(oTree,aHist_Ped).
Parametros  : oTree      => Objeto.
              aHist_Ped  => Informacoes para montagem do Tree.
Retorno     : .T.
Objetivos   : Carrega o tree com os dados do historico do adiantamento selecionado.
Autor       : Jeferson Barros Jr.
Data/Hora   : 05/11/02 12:22.
Obs.        :
*/
*--------------------------------------------*
Static Function AP100ReadTree(oTree,aHist_Ped)
*--------------------------------------------*
Local lRet := .t., i:=0

Begin Sequence

   DBADDTREE oTree PROMPT STR0047+Space(60) OPENED RESOURCE 'BMPCONS' CARGO "L" //"Histórico do Adiantamento."
   For i:=1 To Len(aHist_Ped)
      DBADDITEM oTree PROMPT AllTrim(aHist_Ped[i]) RESOURCE 'RELATORIO' CARGO "E"
   Next

   DBENDTREE oTree
   oTree:Refresh()
   oTree:SetFocus()

End Sequence

Return lRet

/*
Funcao      : AP100TotAdian().
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Atualizar o total de adiantamentos.
Autor       : Jeferson Barros Jr.
Data/Hora   : 07/11/02 15:24.
Obs.        :
*/
*-----------------------------*
Static Function AP100TotAdian()
*-----------------------------*
Local lRet:= .t., nRec := Work_Pgto->(RecNo())

Begin Sequence

   nTotAdia := 0
   nEEQSaldo := 0
   Work_Pgto->(DbGoTop())

   Do While Work_Pgto->(!Eof())
      If !(Work_Pgto->(Deleted()))
        nTotAdia += Work_Pgto->EEQ_VL
        nEEQSaldo += Work_Pgto->EEQ_SALDO
      EndIf
      Work_Pgto->(DbSkip())
   EndDo

End Sequence

Work_Pgto->(DbGoTo(nRec))

Return lRet

/*
Funcao      : AP100Add(oMsSelect,oGetTot,lAlterar).
Parametros  : Objetos para refresh.
Retorno     : .T.
Objetivos   : Associar adiantamentos com base no importador.
Autor       : Jeferson Barros Jr.
Data/Hora   : 06/11/02 17:30.
Obs.        :
*/
*--------------------------------------------------*
Static Function AP100Add(oMsSelect,oGetTot,lAlterar)
*--------------------------------------------------*
Local cTitulo, cPictDt:="  /  /  ", cPictVl := "@E 999,999,999,999.99", cPictTx := "@E 99,999,999.999999"  //NCF - 01/10/2015 - Adiant. com Mov. Exterior
Local cCliCod, cCliNome, cCliCodPais, cCliDscPais
Local bOk:={||oDlg:End(), nOpcao:=1}, bCancel:={||oDlg:End()}
Local aPos, aCpos, aOrd:=SaveOrd({"SA1","Work_Pgto"})
Local lRet:=.t., lInverte := .f.
Local nOpcao := 0, nRec := 0
Local oDlg, oMark
Local nScan := 0
Local oPanel1, oPanel2
Local cFileBak1, cFileBak2
//FDR - 10/04/12
Private oMarkAdd

Private aCposAd:= {}  //TRP - 28/05/2012 - Variavel Private para incluir novos campos na MsSelect da Associacao de Adiantamentos.

Default lAlterar := .f.

Begin Sequence

   If lAlterar
      If Work_Pgto->EEQ_VL <> Work_Pgto->EEQ_SALDO
         MsgStop(STR0017+Replic(ENTER,2)+; //"Este adiantamento não pode ser alterado."
                 STR0018+ENTER+;  //"Detalhes:"
                 STR0019 +ENTER+; //"Este adiantamento já está vinculado a fechamento(s) de cambio,"
                 STR0020 +ENTER+; //"para alterar o mesmo favor desvincular o adiantamento no{s) "
                 STR0021,STR0022) //"fechamento(s) de cambio correspondente(s)."###"Atenção"
         Break
      EndIf
   EndIf

   //DFS - 16/11/12 - Faz backup das works
   cFileBak1 := CriaTrab(,.f.)
   dbSelectArea("Work_Pgto")
   DbGoTop()
   //Copy to (cFileBak1+GetdbExtension())
   TETempBackup(cFileBak1) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados

   cFileBak2 := CriaTrab(,.f.)
   dbSelectArea("Work_Adia")
   DbGoTop()
   //Copy to (cFileBak2+GetdbExtension())
   TETempBackup(cFileBak2) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados

   nRec := Work_Pgto->(RecNo())

   Work_Pgto->(DbGoTop())
   Do While Work_Pgto->(!Eof())
      If Work_Pgto->EEQ_FAOR == "C"
         If Work_Adia->(DbSeek(Work_Pgto->EEQ_FAOR+Work_Pgto->EEQ_PROR+Work_Pgto->EEQ_PAOR))
            Work_Adia->WK_FLAG  := cMarca
            Work_Adia->WK_VLADI := Work_Pgto->EEQ_VL
         EndIf
         Work_Adia->(DbGoTop())
      EndIf
      Work_Pgto->(DbSkip())
   EndDo

   Work_Pgto->(DbGoTo(nRec))

   // ** Valida a moeda do cliente contra a do processo.
   SA1->(DbSeek(xFilial("SA1")+EE7->EE7_IMPORT+EE7->EE7_IMLOJA))

   EXJ->(DbSetOrder(1))
   EXJ->(DbSeek(xFilial("EXJ")+SA1->A1_COD+SA1->A1_LOJA))
   /*  Nopado por GFP - 23/08/2012 - Sistema deve permitir incluir adiantamentos do cliente com moedas diversas
   If EXJ->EXJ_MOEDA <> EE7->EE7_MOEDA
      MsgStop(STR0048+Replic(ENTER,2)+; //"Não é possível associar adiantamentos."
              STR0018+ENTER+; //"Detalhes:"
              STR0049+EXJ->EXJ_MOEDA+STR0050+ENTER+; //"A moeda de negociação do importador ("###"), é diferente da moeda do "
              STR0051+EE7->EE7_MOEDA+").",STR0022) //"processo ("###"Atenção"
      Break
   EndIf
   */
   // ** Colunas para o Browse ...
   aCposAd := {{"WK_FLAG","","  "},;
             {{|| Transf(Work_Adia->EEQ_PGT,cPictDt)}  ,"",AVSX3("EEQ_PGT",AV_TITULO)},;
             {{|| Work_Adia->EEQ_PARC}                 ,"",STR0002},; //"Nro.Parcela"
             {{|| Work_Adia->EEQ_MOEDA}                ,"",STR0184},; //"Moeda"  // GFP - 23/08/2012
             {{|| Transf(Work_Adia->WK_VLADI,cPictVl)} ,"",STR0052},; //"Valor Associado"
             {{|| Transf(Work_Adia->EEQ_SALDO,cPictVl)},"",STR0004},; //"Saldo"
             {{|| Transf(Work_Adia->EEQ_VL,cPictVl)}   ,"",STR0053+Space(200)}} //"Valor do Adiantamento"

   //NCF - 22/07/2015
   IF lCpoAcrDcr
      AAdd(aCposAd, {{|| Transf(Work_Adia->EEQ_DECRES,cPictVl)},"",AVSX3("EEQ_DECRES",AV_TITULO)} ) //"Decrescimos"
   ENDIF
   //NCF - 01/10/2015 - Adiant. com Mov. Exterior
   IF lAdtMovExt
      AAdd(aCposAd, {{|| Transf(Work_Adia->EEQ_PRINBC,cPictTx)},"",AVSX3("EEQ_PRINBC",AV_TITULO)} ) //"Paridade Moe.Inv_x_Moe.Bco"
      AAdd(aCposAd, {{|| Transf(Work_Adia->EEQ_VLMBCO,cPictVl)},"",AVSX3("EEQ_VLMBCO",AV_TITULO)} ) //"Valor na Moeda do Banco"
      AAdd(aCposAd, {{|| Work_Adia->EEQ_MOEBCO}                ,"",AVSX3("EEQ_MOEBCO",AV_TITULO)} ) //"Moeda do Banco"
   ENDIF

   SA1->(DbSetOrder(1))
   SA1->(DbSeek(xFilial("SA1")+EE7->EE7_IMPORT+EE7->EE7_IMLOJA))

   // ** Set das variaveis ...
   cTitulo := STR0054 //"Associação de Adiantamentos."
   cCliCod     := SA1->A1_COD
   cLojaCli    := SA1->A1_LOJA
   cCliNome    := SA1->A1_NOME
   cCliCodPais := SA1->A1_PAIS
   cCliDscPais := Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_NOIDIOM")

   Work_Adia->(DbGoTop())

   IF EasyEntryPoint("EECAP105")
	  If ValType((lRet := EXECBLOCK("EECAP105",.F.,.F.,"BROWSE_ADD_ADTO"))) <> "L"
	     lRet := .T.
	  EndIf
	  If !lRet
	     Break
	  EndIf
   ENDIF
  // by CRF  25/10/2010 - 15:33
  aCpos :=  AddCpoUser(aCpos,"EEQ","2")

   DEFINE MSDIALOG oDlg TITLE cTitulo FROM 9,0 TO 30,80 of oDlg

     //wfs - Separação da tela em dois paineis
      oPanel1:= TPanel():New(0, 0, "",oDlg, , .F., .F.,,, (oDlg:nRight-oDlg:nLeft), (oDlg:nBottom-oDlg:nTop)*0.15, , )
      oPanel2:= TPanel():New(0, 0, "",oDlg, , .F., .F.,,, (oDlg:nRight-oDlg:nLeft), (oDlg:nBottom-oDlg:nTop)*0.75, , )

      @ 15,007 Say STR0055 Size 65,07 PIXEL Of oPanel1//oDlg //"Codigo"      // GFP - 24/08/2012
      @ 15,100 Say STR0056   Size 65,07 PIXEL Of oPanel1//oDlg //"Nome"      // GFP - 24/08/2012

      @ 15,35  MSGET cCliCod  Size 040,07  Pixel Of oPanel1/*oDlg*/ When .f. // GFP - 24/08/2012
      @ 15,140 MSGET cCliNome Size 120,07  Pixel Of oPanel1/*oDlg*/ When .f. // GFP - 24/08/2012

      @ 25,007 Say STR0057      Size 40,07 Pixel of oPanel1//oDlg //"Pais"   // GFP - 24/08/2012
      @ 25,100 Say STR0058 Size 35,07 Pixel of oPanel1//oDlg //"Desc.Pais"   // GFP - 24/08/2012

      @ 25,35  MSGET cCliCodPais Size 040,07 Pixel Of oPanel1/*oDlg*/ When .f. // GFP - 24/08/2012
      @ 25,140 MSGET cCliDscPais Size 120,07 Pixel Of oPanel1/*oDlg*/ When .f. // GFP - 24/08/2012

      aPos := PosDlgDown(oDlg)
      aPos[1] := 36

      oMarkAdd := MsSelect():New("Work_Adia","WK_FLAG",,aCposAd,@lInverte,@cMarca,aPos)
      oMarkAdd :bAval := {|| If(Empty(Work_Adia->WK_FLAG),Ap100Mark(oMarkAdd),Ap100Mark(oMarkAdd,.f.))}

      //FDR - 11/04/12 - Ponto de entrada para customização de associação de adiantamento
      If EasyEntryPoint("EECAP105")
         ExecBlock("EECAP105", .F., .F., {"MSDIALOG_ADD_ADTO",oMarkAdd})
      EndIf

	  //wfs - Posicionamento dos Paineis
      oMarkAdd:oBrowse:align:= CONTROL_ALIGN_ALLCLIENT
      oPanel1:Align:= CONTROL_ALIGN_TOP
      oPanel2:Align:= CONTROL_ALIGN_ALLCLIENT
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   If nOpcao = 1
      Work_Adia->(DbGoTop())
      Work_Pgto->(DbSetOrder(2))

      DbSelectArea("EEQ")
      EEQ->(DbSetOrder(1))

      Do While Work_Adia->(!Eof())
         If !Empty(Work_Adia->WK_FLAG)
            If !Work_Pgto->(DbSeek("C"+Work_Adia->EEQ_PREEMB+Work_Adia->EEQ_PARC))
               Work_Pgto->(DbAppend())
               AvReplace("Work_Adia","Work_Pgto")
               Work_Pgto->EEQ_PREEMB := EE7->EE7_PEDIDO
               Work_Pgto->EEQ_PARC   := ""
               Work_Pgto->EEQ_PARC   := AP100CalcParc()
               Work_Pgto->EEQ_FASE   := "P"
               Work_Pgto->EEQ_VL     := Work_Adia->WK_VLADI
               Work_Pgto->EEQ_EQVL   := Work_Adia->(WK_VLADI*EEQ_TX) // Work_Adia->(EEQ_VL*EEQ_TX) // By JPP - 06/03/2006 - 10:25
               Work_Pgto->EEQ_SALDO  := Work_Adia->WK_VLADI
               Work_Pgto->EEQ_PROR   := Work_Adia->EEQ_PREEMB
               Work_Pgto->EEQ_FAOR   := "C"
               Work_Pgto->EEQ_PAOR   := Work_Adia->EEQ_PARC
               Work_Pgto->WK_STATUS  := STR0010 //"Vinculado"

               /*AOM - 25/03/2010 -  Verifica se o registro adicionado já foi excluido do arquivo de trabalho,
                                     se sim remover do array (aDeletados)*/
               If EEQ->(DbSeek(xFilial("EEQ")+AvKey(Work_Pgto->EEQ_PREEMB,"EEQ_PREEMB")+AvKey(Work_Pgto->EEQ_PARC,"EEQ_PARC")+AvKey(Work_Pgto->EEQ_FASE,"EEQ_FASE")))
                  Work_Pgto->RECNO   := EEQ->(Recno())
                  nScan := ASCAN(aDeletados,Work_Pgto->RECNO)
                  If nScan > 0
                     ADEL(aDeletados,nScan)
                  EndIf
               Else
                  Work_Pgto->RECNO   := 0
               EndIf
               //RMD - Integração com o SIGAFIN
               Work_Pgto->EEQ_FINNUM := Work_Adia->EEQ_FINNUM
            Else
               If Work_Pgto->EEQ_VL <> Work_Adia->WK_VLADI
                  Work_Pgto->(RecLock("Work_Pgto",.f.))
                  Work_Pgto->EEQ_VL    := Work_Adia->WK_VLADI
                  Work_Pgto->EEQ_EQVL  := Work_Adia->(WK_VLADI*EEQ_TX) // Work_Adia->(EEQ_VL*EEQ_TX) // By JPP - 06/03/2006 - 10:25
                  Work_Pgto->EEQ_SALDO := Work_Adia->WK_VLADI
               EndIf
            EndIf
         Else
            If Work_Pgto->(DbSeek("C"+Work_Adia->EEQ_PREEMB+Work_Adia->EEQ_PARC))
               If Work_Pgto->RECNO != 0
                  aAdd(aDeletados,Work_Pgto->RECNO)
               EndIf
               Work_Pgto->(RecLock("Work_Pgto",.f.))
               Work_Pgto->(DbDelete())
               Work_Pgto->(MsUnLock())
            EndIf
         EndIf

         Work_Adia->(DbSkip())
      EndDo
      Work_Adia->(DbGoTop())
   Else
      //DFS - 16/11/12 - Caso cancele a desassociação do adiantamento, sistema deve voltar tudo.

      dbSelectArea("Work_Pgto")
      AvZap()
      TERestBackup(cFileBak1)


      dbSelectArea("Work_Adia")
      AvZap()
      TERestBackup(cFileBak2)

   EndIf

   Work_Adia->(DbGoTop())
   Work_Pgto->(DbGoTop())
   AP100TotAdian() //** Atualiza o total dos adiantamentos do processo.
   oMsSelect:oBrowse:Refresh()
   oGetTot:Refresh()

End Sequence

RestOrd(aOrd)

If ValType(cFileBak1) == "C" .and. ValType(cFileBak2) == "C"  //NCF - 29/07/2015
   //DFS - 16/11/12 - Apaga as informações das works.
   FErase(cFileBak1+GetDBExtension())
   FErase(cFileBak2+GetDBExtension())
EndIf

Return lRet

/*
Funcao      : Ap100Mark(oMark,lMarcar)
Parametros  : oMark   => Objeto para Refresh.
              lMarcar => .t. - Marca item.
                         .f. - Desmarca item.
Retorno     : .T.
Objetivos   : Associar adiantamentos com base no importador.
Autor       : Jeferson Barros Jr.
Data/Hora   : 06/11/02 17:30.
Obs.        :
*/
*--------------------------------------*
Static Function Ap100Mark(oMark,lMarcar)
*--------------------------------------*
Local nOpcao := 0, nQtdDisp:= 0, nQtdAss := 0
Local bOk:={|| If (AP100ValMark(nQtdDisp,nQtdAss),(nOpcao:=1,oDlg:End()),Nil)}
Local bCancel := {|| oDlg:End()}
Local aOrd:=SaveOrd("SA1")
Local cTitulo, cX
Local lRet:=.t.
Local oDlg, oPanel // GFP - 24/08/2012
Local lIntFin := IsIntEnable("001")//Verifica se a integração com o módulo SIGAFIN está ativa.

Default lMarcar := .T.

Begin Sequence

   If lMarcar

      If !EECFlags("CAMBIO_EXT")
         If Empty(Work_Adia->EEQ_DTCE) //ER - 19/08/2008
            MsgInfo(STR0059+Replic(ENTER,2)+; //"Não é possível selecionar este adiantamento."
                    STR0018+ENTER+; //"Detalhes:"
                    STR0060,STR0061) //"O adiantamento selecionado não possui data de crédito no exterior."###"Atenção."
            Break
         EndIf
      Else
         //** AAF 04/03/08 - Adiantamento não precisa estar liquidado. Precisa apenas de pagamento de cliente (crédito no exterior).
         If Empty(Work_Adia->EEQ_DTCE)
            MsgInfo(STR0059+Replic(ENTER,2)+; //"Não é possível selecionar este adiantamento."
                    STR0018+ENTER+; //"Detalhes:"
                    STR0182,STR0061) //###"Atenção."//STR0182	"O adiantamento selecionado não possui baixa gerencial."
            Break
         EndIf
         //**
      EndIf

      SA1->(DbSetOrder(1))
      SA1->(DbSeek(xFilial("SA1")+EE7->EE7_IMPORT+EE7->EE7_IMLOJA))

      EXJ->(DbSetOrder(1))
      EXJ->(DbSeek(xFilial("EXJ")+SA1->A1_COD+SA1->A1_LOJA))

      cTitulo  := STR0062 //"Adiantamentos"
      nQtdDisp := Work_Adia->EEQ_SALDO

      If lIntFin
         nQtdAss := nQtdDisp
      EndIf

      // GFP - 24/08/2012 - Ajuste de posição das informações na tela, independente da versão.
      DEFINE MSDIALOG oDlg TITLE cTitulo FROM 10,12 TO /*20.5*/22.5,65/*47*/ OF oMainWnd

         oPanel := TPanel():New(0,0, "", oDlg,, .T., ,,,0,0,,.T.)
         oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

         @ /*1.1*/0.5, 0.5 TO 5.5,61/*17*/ LABEL STR0063+AllTrim(EXJ->EXJ_MOEDA) OF oPanel//oDlg //"Valores "     // GFP - 24/08/2012

         @ /*1.8*/1.2, 6.0 SAY STR0064 OF oPanel/*oDlg*/ SIZE 35,9 //"Disponivel"    // GFP - 24/08/2012
         @ /*2.4*/1.8, 6.0 MSGET nQtdDisp  SIZE 70,07  PICTURE AVSX3("EEQ_SALDO",AV_PICTURE) OF oPanel/*oDlg*/ WHEN .f.     // GFP - 24/08/2012

         @ /*3.8*/3.2, 6.0 SAY STR0065 OF oPanel/*oDlg*/ SIZE 35,9 //"Associar"              // GFP - 24/08/2012
         @ /*4.4*/3.8, 6.0 MSGET nQtdAss SIZE 70,07 PICTURE AVSX3("EEQ_VL",AV_PICTURE) When EECFlags("ADIANTAMENTO_PARCIAL") OF oPanel//oDlg    // GFP - 24/08/2012

         @ /*10.0*/9.4, 6.0 MSGET cX SIZE 70,07 OF oPanel//oDlg    // GFP - 24/08/2012

      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED

      If nOpcao = 1
         Work_Adia->WK_FLAG   := cMarca
         Work_Adia->WK_VLADI  := nQtdAss // Valor Associado.
         Work_Adia->EEQ_SALDO := Work_Adia->EEQ_SALDO-nQtdAss // Abate o saldo do adiantamento.
      EndIf
   Else
      Work_Adia->WK_FLAG   := ""
      Work_Adia->EEQ_SALDO := Work_Adia->EEQ_SALDO+Work_Adia->WK_VLADI // Atualiza o saldo do adiantamento.
      Work_Adia->WK_VLADI  := 0
   EndIf

End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : AP100ValMark(nQtdDisp,nQtdAss).
Parametros  : nQtdDisp   => Quantidade disponível de adiantamento para associação.
              nQtdAss    => Quantidade a ser associada, informada pelo usuário.
Retorno     : .t./.f.
Objetivos   : Validar a associação de adiantamentos.
Autor       : Jeferson Barros Jr.
Data/Hora   : 07/11/02 16:40.
Obs.        :
*/
*--------------------------------------------*
Static Function AP100ValMark(nQtdDisp,nQtdAss)
*--------------------------------------------*
Local lRet:=.t., nTotMark:=0, nRec := Work_Adia->(RecNo()), nTotal:= nTotAdia + nTotEmb  // PLB 20/09/06
Local nRecPgto:= Work_Pgto->(RecNo())
Local aOrd:=SaveOrd("Work_Pgto")

Begin Sequence

   If nQtdAss <= 0
      MsgInfo(STR0066,STR0027) //"Valor a ser associado inválido."###"Aviso"
      lRet:=.f.
      Break
   EndIf

   If nQtdAss > nQtdDisp
      MsgInfo(STR0067,STR0027) //"Valor a ser associado maior que o valor disponível de adiantamento!"###"Aviso"
      lRet:=.f.
      Break
   EndIf

   Work_Adia->(DbGoTop())
   Do While Work_Adia->(!Eof())
      If !Empty(Work_Adia->WK_FLAG)
         Work_Pgto->(DbSetOrder(2))
         If !Work_Pgto->(DbSeek("C"+Work_Adia->EEQ_PREEMB+Work_Adia->EEQ_PARC))
            nTotMark += Work_Adia->WK_VLADI
         EndIf
      EndIf

      Work_Adia->(DbSkip())
   EndDo

   Work_Adia->(DbGoTo(nRec))

   Work_Pgto->(DbSetOrder(2))
   If Work_Pgto->(DbSeek("C"+Work_Adia->EEQ_PREEMB+Work_Adia->EEQ_PARC))
      nTotal -= Work_Pgto->EEQ_VL
   EndIf

   Work_Pgto->(DbGoTo(nRecPgto))

   If (nQtdAss+nTotMark+nTotal) > EE7->EE7_TOTPED
      MsgInfo(STR0068+Replic(ENTER,2)+; //"Associação de adiantamento inválida."
              STR0018+ENTER+; //"Detalhes:"
              STR0038+ENTER+; //"Com o valor informado, o total de adiantamento(s) ultrapassa "
              STR0162+ENTER+; //"o valor disponivel para adiantamento(s) do processo:"
              AllTrim(EE7->EE7_MOEDA)+" "+AllTrim(Transform(EE7->EE7_TOTPED-nTotal,AVSX3("EE7_TOTPED",AV_PICTURE)))+".",STR0027)
              // PLB - 20/09/06
              //STR0039,STR0027) //"o total do processo."###"Aviso"
      lRet:=.f.
      Break
   EndIf

End Sequence

RestOrd(aOrd)

Return lRet


/*
Função      : AP100OpcFix
Objetivo    : Apresentar opção para Fixar preço ou Estornar fixação.
Autor       : Alexsander Martins dos Santos
Data e Hora : 06/05/2004 às 14:13.
*/

Function AP100OpcFix()

Local lRet         := .F.
Local nButton      := 0
Local nRadio       := 1
Local aRadio       := {{STR0074, {|| AP100FixPrice()}},; //"Fixação de Preço"
                       {STR0100, {|| AP100EstPrice()}}}  //"Estorno de Fixação"
Local aSaveOrd     := SaveOrd("EE8")
Local lITcomFixPRC := .F.
Local lITsemFixPRC := .F.

Local nRecNoEE7 := EE7->(RecNo()), aEE7Filter := EECSaveFilter("EE7") // JPM - 02/12/05 - salva e limpa filtro no EE7
EE7->(DbClearFilter())
EE7->(DbGoTo(nRecNoEE7))

If Type("lIntermed") <> "L" .Or. Type("lCommodity") <> "L"
   Private cFilBr, cFilEx
EndIf
If Type("lIntermed") <> "L"
   lIntermed := EECFlags("INTERMED")
EndIf
If Type("lCommodity") <> "L"
   lIntermed := EECFlags("COMMODITY")
EndIf

Private aHeaderMsg := {}, aDetailMsg := {}// variáveis para mensagem
Private nPrcEEY, cMesAnoFix := ""
Private lRvPed11
Private cUniMedTon := EasyGParam("MV_AVG0030",,"TL") // unidade de medida para tonelada.

Begin Sequence

   If Type("lSI300") <> "L" // chamada do SI300
      lSI300 := .F.
   EndIf

   If lSI300
      aSaveOrd := SaveOrd({"EE7","EE8","EEY"})

      If EEY->EEY_STATUS == ST_BA
         MsgInfo(STR0142, STR0022) // "Este R.V. já está baixado, portanto não poderá ser fixado." ### "Atenção"
         Break
      EndIf
      lRvPed11 := (Left(EEY->EEY_PEDIDO,1) <> "*")
      EE7->(DbSetOrder(1))
      EE7->(DbSeek(xFilial()+EEY->EEY_PEDIDO)) // Posiciona no pedido correspondente ao R.V.
   Else
      aSaveOrd := SaveOrd({"EE7","EE8"})
      lRvPed11 := .F.
      lRv11    := .F.
      lNewRv   := .F.
   EndIf

   EE8->(dbSetOrder(1))
   EE8->(dbSeek(xFilial()+EE7->EE7_PEDIDO))

   While EE8->(!Eof() .and. EE8_FILIAL == xFilial() .and. EE8_PEDIDO == EE7->EE7_PEDIDO)
      If If(lNewRv .And. lRvPed11,EE8->EE8_RV == EEY->EEY_NUMRV,.T.) // no novo tratamento, só vai fixar itens que tenham o mesmo R.V. do registro do EEY
         If(Empty(EE8->EE8_DTFIX), lITsemFixPRC, lITcomFixPRC) := .T.
      EndIf
      EE8->(dbSkip())
   End

   Do Case

      Case lITsemFixPRC .and. !lITcomFixPRC
         lRet := Eval(aRadio[1][2])

      Case lITcomFixPRC .and. !lITsemFixPRC
         lRet := Eval(aRadio[2][2])

      OtherWise
         Define MSDialog oDlg Title STR0101 From 00, 00 To 146, 389 Of oMainWnd Pixel //"Fixação/Estorno de Preço"

         @ 20, 09 Radio nRadio Items aRadio[1][1], aRadio[2][1] Size 150, 10 of oDlg Pixel

         Define SButton From 59, 09 Type 1 Action (nButton := 1, oDlg:End()) Enable of oDlg Pixel
         Define SButton From 59, 40 Type 2 Action (nButton := 0, oDlg:End()) Enable of oDlg Pixel

         Activate MSDialog oDlg Centered

         If nButton = 1
            lRet := Eval(aRadio[nRadio][2])
         EndIf

   EndCase

End Sequence

RestOrd(aSaveOrd,.T.)

If lRet .And. lNewRv
   If !Empty(aDetailMsg) .And. Type("nPrcEEY") = "N"
      EEY->(RecLock("EEY",.F.),;
            EEY_PRCUNI := nPrcEEY,;
            EEY_MESFIX := VAL(LEFT(cMesAnoFix,2)),;
            EEY_ANOFIX := VAL(RIGHT(cMesAnoFix,4)),;
            MsUnlock())
   EndIf
   SI301RatPreco()
EndIf

// JPM - 02/12/05 - restaura filtro no EE7
nRecNoEE7 := EE7->(RecNo())
EECRestFilter(aEE7Filter)
EE7->(DbGoTo(nRecNoEE7))

Return(lRet)


/*
Funcao      : AP100FixPrice()
Parametros  : Nenhum
Retorno     : .t./.f.
Objetivos   : Fixação de Preço
Autor       : Jeferson Barros Jr.
Data/Hora   : 24/06/2002 12:47
Revisao     :
Obs.        :
*/
*-----------------------*
Function AP100FixPrice()
*-----------------------*
Local lRet:=.f.,cFileTmp,aOrd:=SaveOrd("EE8"),cPedido:="",cDtProc:="",cTitulo
Local aPos,aButtons:={},lUnfixed:=.f.,aItem:={},nOpc:=0,nRecNo:=0,i,cSequen:=""

Local aFilBrEx:={}  // Posicao 1 - Filial Brasil
                    // Posicao 2 - Filial Exterior

Local nPercFilho:=0,nPercPai:=0,nRecEE7:=0,nRecSld:=0,nTotFix:= 0
Local bOk    :={|| nOpc:=1,oDlg:End()}
Local bCancel:={|| oDlg:End()}

Local cWorkPed
Local aWorkPed
Local nRec := EE7->(RecNo())

Local nQuantPed := 0
Local cBolsa

Private nVlCotacao:=0
Private aCampos
Private cMarca := GetMark()
Private aFatIt := {}
Private cCodBolsa := ""
Private aSemSX3   :={} //igor chiba 08/04/2010

//RMD - Para permitir o acesso aos itens fixados via ponto de entrada.
Private aItensFixados := {}

Begin Sequence

   EE7->(RecLock("EE7"))

   // ** Cria work para a fixação de preço ...
   aCampos:=Array(EE8->(fCount()))
   aSemSX3 := {{"WK_FLAG ","C",1,0},;
               {"WK_VLCOT","N",17,7},;
               {"EE8_ORIGEM","C",06,0}}

   If EasyEntryPoint("EECAP105")  // //igor chiba 08/04/2010
      ExecBlock("EECAP105", .F., .F., "WORKFIX")
   EndIf

   cFileTmp:=E_CriaTrab("EE8",aSemSX3,"WorkFix")

   // ** Cria work para a fixação de preço de RV(especial) ...
   aWorkPed := {{"WK_MARCA",   "C", 02, 00},;
                {"EE8_RV",     "C", AVSX3("EE8_RV",     AV_TAMANHO), 00},;
                {"EE8_PEDIDO", "C", AVSX3("EE8_PEDIDO", AV_TAMANHO), 00},;
                {"EE8_SEQUEN", "C", AVSX3("EE8_SEQUEN", AV_TAMANHO), 00},;
                {"EE8_SLDINI", "N", AVSX3("EE8_SLDINI", AV_TAMANHO), AVSX3("EE8_SLDINI", AV_DECIMAL)},;
                {"EE8_QTDFIX", "N", AVSX3("EE8_SLDINI", AV_TAMANHO), AVSX3("EE8_SLDINI", AV_DECIMAL)},;
                {"EE8_QTDLOT", "N", AVSX3("EE8_QTDLOT", AV_TAMANHO), AVSX3("EE8_QTDLOT", AV_DECIMAL)},;
                {"EE8_COD_I" , "C", AVSX3("EE8_COD_I" , AV_TAMANHO), AVSX3("EE8_COD_I" , AV_DECIMAL)},;
                {"EE8_UNIDAD", "C", AVSX3("EE8_UNIDAD", AV_TAMANHO), AVSX3("EE8_UNIDAD", AV_DECIMAL)}}

   aCampos:={}

   cWorkPed := E_CriaTrab(, aWorkPed, "WorkPed")
   IndRegua("WorkPed", cWorkPed+TEOrdBagExt(), "EE8_RV+EE8_PEDIDO" )

   EE8->(DbSetOrder(1))
   EE8->(DbSeek(xFilial("EE8")+EE7->EE7_PEDIDO))

   Do While EE8->(!Eof().And. EE8_FILIAL==xFilial("EE7")) .And. EE8->EE8_PEDIDO == EE7->EE7_PEDIDO
      /// LCS - 23/04/2003 - TROCA DO IF
      ///If EE8->EE8_PRECO = 0
      IF EMPTY(EE8->EE8_DTFIX) .And. If(lNewRv .And. lRvPed11,EE8->EE8_RV == EEY->EEY_NUMRV,.T.) // no novo tratamento, só vai fixar itens que tenham o mesmo R.V. do registro do EEY
         WorkFix->(DbAppend())
         AvReplace("EE8","WorkFix")
         WorkFix->EE8_VM_DES := EasyMSMM(WorkFix->EE8_DESC,AVSX3("EE8_VM_DES",AV_TAMANHO),, ,,,, "EE8", "EE8_DESC")  //AAF/NCF - 13/09/2013 - Ajustes para melhora de performance Integ. Pedido Expo. Msg. Unica
         If(!lUnfixed,lUnfixed:=.t.,Nil)
      EndIf
      cSequen := EE8->EE8_SEQUEN
      EE8->(DbSkip())
   EndDo

   // ** Verifica se existe algum preço para fixação ...
   If !lUnfixed
      // Help 710
      MsgStop(STR0069,STR0027) //"Não há itens para fixação de preço !"###"Aviso"
      lRet:=.f.
      Break
   EndIf

   aAdd(aButtons,{"PRECO",{|| AP100Price(),oMsSelect:oBrowse:Refresh()},STR0070}) //"Fixação"
   cTitulo := STR0071 //"Manutenção de Preços"
   aItem   := {{{||Transf(WorkFix->EE8_RV,AVSX3("EE8_RV",AV_PICTURE))},"",AvSx3("EE8_RV",AV_TITULO)},;
               {{||WorkFix->EE8_SEQUEN},"",AvSx3("EE8_SEQUEN",AV_TITULO)},;
               {{||WorkFix->EE8_COD_I} ,"",AvSx3("EE8_COD_I" ,AV_TITULO)},;
               {{||Memoline(WorkFix->EE8_VM_DES,60,1) },"",AvSx3("EE8_VM_DES" ,AV_TITULO)},;
               {{||Transf(WorkFix->EE8_SLDINI,AVSX3("EE8_SLDINI",AV_PICTURE))},"",AvSx3("EE8_SLDINI" ,AV_TITULO)},;
               {{||Transf(WorkFix->EE8_QTDFIX,AVSX3("EE8_QTDFIX",AV_PICTURE))},"",AvSx3("EE8_QTDFIX",AV_TITULO)},;
               {{||Transf(WorkFix->EE8_PRECO ,EECPreco("EE8_PRECO", AV_PICTURE))},"",AvSx3("EE8_PRECO" ,AV_TITULO)},;
               {{||Transf(WorkFix->EE8_DIFERE,AvSX3("EE8_DIFERE",AV_PICTURE))},"",AvSx3("EE8_DIFERE",AV_TITULO)},;
               {{||Transf(WorkFix->EE8_MESFIX,AvSX3("EE8_MESFIX",AV_PICTURE))},"",AvSx3("EE8_MESFIX",AV_TITULO)},;
               {{||Transf(WorkFix->EE8_DTFIX,"  /  /  ")},"",AvSx3("EE8_DTFIX",AV_TITULO)},;
               {{||WorkFix->EE8_ORIGEM},"",AvSx3("EE8_ORIGEM",AV_TITULO)}}
             //{{||Transf(WorkFix->EE8_PRECO ,AVSX3("EE8_PRECO",AV_PICTURE))},"",AvSx3("EE8_PRECO" ,AV_TITULO)},;

   cPedido := AllTrim(EE7->EE7_PEDIDO)
   cDtProc := Transf(EE7->EE7_DTPROC,"  /  /  ")
   WorkFix->(DbGoTop())
   DEFINE MSDIALOG oDlg TITLE cTitulo FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd Pixel

      @ 1.4,0.8 SAY AVSX3("EE7_PEDIDO",AV_TITULO)
      @ 1.4,15  SAY AVSX3("EE7_DTPROC",AV_TITULO)

      @ 1.4,05  MSGET cPedido WHEN .F. SIZE 50,7 RIGHT
      @ 1.4,20  MSGET cDtProc WHEN .F. SIZE 50,7 RIGHT

      aPos := PosDlgDown(oDlg)
      aPos[1] := 30

      // by CRF 26/10/2010 - 11:06
      aItem := AddCpoUser(aItem,"EE8","5","WorkFix")


      oMsSelect := MsSelect():New("WorkFix",,,aItem,,,aPos)

      oMsSelect:bAval:={|| AP100Price(),oMsSelect:oBrowse:Refresh()}
      oDlg:lMaximized := .T.
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

   If nOpc = 1

      Begin Transaction
         // Atualiza o EE8 ...
         WorkFix->(DbGoTop())

         Do While WorkFix->(!Eof())
            If WorkFix->WK_FLAG = "1" // Item com preço fixado ...

               If EE7->EE7_STATUS = ST_RV .and. WorkFix->EE8_SLDINI <> WorkFix->EE8_SLDATU

                  WorkPed->(dbSeek(WorkFix->EE8_RV+"*"))
                  IF Left(WorkPed->EE8_PEDIDO,1) == "*"
                     nRecSld := WorkPed->(RecNo())
                  Endif

                  WorkPed->(dbSeek(WorkFix->EE8_RV))

                  While WorkPed->(!Eof()) .And. WorkPed->EE8_RV == WorkFix->EE8_RV

                     IF Empty(WorkPed->WK_MARCA) .Or. Left(WorkPed->EE8_PEDIDO,1) == "*"
                        WorkPed->(dbSkip())
                        Loop
                     Endif

                     If WorkPed->EE8_UNIDAD <> cUniMedTon
                        nTotFix += AvTransUnidad(WorkPed->EE8_UNIDAD,cUniMedTon,WorkPed->EE8_COD_I,WorkPed->EE8_QTDFIX)
                     Else
                        nTotFix += WorkPed->EE8_QTDFIX
                     EndIf

                     //ER - 19/01/06 às 16:30 - Cálculo da Quant. de lotes a ser gravada no Pedido.
                     If !EECFlags("BOLSAS") .Or. Empty((cBolsa := Posicione("EE7",1,xFilial("EE7")+WorkPed->EE8_PEDIDO,"EE7_CODBOL")))
                        nQuantPed := AvTransUnidad(WorkPed->EE8_UNIDAD,cUniMedTon,WorkPed->EE8_COD_I,WorkPed->EE8_QTDFIX,.F.)
                        WorkPed->EE8_QTDLOT := (nQuantPed / WorkFix->EE8_QTDFIX) * WorkFix->EE8_QTDLOT
                     Else // JPM - 02/02/06
                        nRecEE7 := EE7->(RecNo())
                        WorkPed->EE8_QTDLOT := Ap104CalcLot(WorkPed->EE8_QTDFIX,WorkPed->EE8_UNIDAD,cBolsa)
                        EE7->(DbGoTo(nRecEE7))
                     EndIf

                     AP105FixItem(WorkPed->EE8_PEDIDO, WorkPed->EE8_SEQUEN, WorkPed->EE8_QTDFIX, WorkPed->EE8_QTDLOT,;
                                  WorkFix->EE8_PRECO ,WorkFix->EE8_MESFIX, WorkFix->EE8_DTFIX,;
                                  WorkFix->EE8_DTCOTA, WorkFix->EE8_DIFERE, IF(!Empty(nRecSld),.F.,.T.) )

                     WorkPed->(dbSkip())
                  Enddo

                  IF !Empty(nRecSld)
                     WorkPed->(dbGoTo(nRecSld))

                     //ER - 19/01/06 às 16:30 - Cálculo da Quant. de lotes a ser gravada no Pedido.
                     If !EECFlags("BOLSAS") .Or. Empty(cCodBolsa)
                        WorkPed->EE8_QTDLOT := ((nTotFix+WorkPed->EE8_QTDFIX) / WorkFix->EE8_QTDFIX) * WorkFix->EE8_QTDLOT
                     Else // JPM - 02/02/06
                        WorkPed->EE8_QTDLOT := Ap104CalcLot(nTotFix+WorkPed->EE8_QTDFIX,cUniMedTon,cCodBolsa)
                     EndIf

                     AP105FixItem(WorkPed->EE8_PEDIDO, WorkPed->EE8_SEQUEN, nTotFix+WorkPed->EE8_QTDFIX, WorkPed->EE8_QTDLOT,;
                                  WorkFix->EE8_PRECO , WorkFix->EE8_MESFIX, WorkFix->EE8_DTFIX,;
                                  WorkFix->EE8_DTCOTA, WorkFix->EE8_DIFERE, .F., WorkPed->EE8_QTDFIX , .f.)
                     nTotFix := 0
                  Endif

               Else

                  AP105FixItem(WorkFix->EE8_PEDIDO, WorkFix->EE8_SEQUEN, WorkFix->EE8_QTDFIX, WorkFix->EE8_QTDLOT,;
                               WorkFix->EE8_PRECO , WorkFix->EE8_MESFIX, WorkFix->EE8_DTFIX,;
                               WorkFix->EE8_DTCOTA, WorkFix->EE8_DIFERE, , ,.f.)
               Endif

            EndIf
            WorkFix->(DbSkip())
         EndDo

         If !Empty(aDetailMsg)
            SI301HistFix(.T.) //Grava histórico da fixação de preço
         EndIf

         //atualizar descricao de status
         EE7->(RecLock("EE7",.F.))
         DSCSITEE7(.T.)
         If EasyEntryPoint("EECAP105")
            ExecBlock("EECAP105", .F., .F., "GRVOK")
         EndIf

         // ** Atualiza os totais do processo de exportação.
         AP105CallPrecoI()

         // ** Envia alterações nos itens para o faturamento.
         EE7->(DbSetOrder(1))
         For i := 1 To Len(aFatIt)
            EE7->(DbSeek(xFilial()+aFatIt[i][1]))
            Ap105EnviaFat()
         Next
         EE7->(DbGoTo(nRec))
         lRet := .t.
      End Transaction
   EndIf

   EE7->(MsUnlock())

End Sequence

WorkFix->(E_EraseArq(cFileTmp))
WorkPed->(E_EraseArq(cWorkPed))

RestOrd(aOrd)

Return lRet


/*
Funcao      : Ap105EnviaFat()
Parametros  : aDel - itens deletados
Retorno     : Nil
Objetivos   : Enviar alterações para o Faturamento
Autor       : tratamento desenvolvido por Fabio Justo Hildebrand, passado para função por João Pedro Macimiano Trabbold
Data/Hora   : 30/11/2005 às 9:21
*/
*--------------------------*
Function Ap105EnviaFat(aDel)
*--------------------------*
Local i
Default aDel := {}

Begin Sequence

   If Type("lConvUnid") <> "L"
      Private lConvUnid := .f.
      If (EE7->(FieldPos("EE7_UNIDAD")) # 0) .And. (EE8->(FieldPos("EE8_UNPES")) # 0) .And.;
      (EE8->(FieldPos("EE8_UNPRC")) # 0)
         lConvUnid :=.t.
      EndIf
   EndIf

   // ** FJH 18/11/05 ** Envio do preço fixado ao faturamento.
   If IsIntFat() .And. (EE7->(FIELDPOS("EE7_GPV")) = 0 .OR. EE7->EE7_GPV $ cSIM)

      // Zap nas Works
      WorkIt->(AvZap())
      WorkEm->(AvZap())
      WorkAg->(AvZap())
      WorkIn->(AvZap())
      WorkDe->(AvZap())
      WorkNo->(AvZap())
      IF(Select("WorkGrp") > 0,WorkGrp->(AvZap()),)
      IF(Select("WorkDoc") > 0,WorkDoc->(AvZap()),)

      // Carrega as Variaveis de Memoria com EE7
      For i := 1 To EE7->(FCount())
         M->&(EE7->(FieldName(i))) := EE7->(FieldGet(i))
      Next

      lBACKTO := .F. //usada no grtrb
      AP100GRTRB(ALTERAR)

      //Grava as outras works
      //** Tratamento p/ o work de Embalagens...
      IF ! Inclui
         // ***** Grava WorkEm, com informacoes do EEK ***** \\
         AP100WkEmb(EE7->EE7_PEDIDO,EE8->EE8_SEQUEN,EE8->EE8_EMBAL1)
      Endif

      //** Tratamento p/ o work de Agentes...
      bAddWork  := {|| WorkAg->(dbAppend()),AP100AGGrava(.T.,OC_PE)}
      EEB->(DBSETORDER(1))

      IF ! Inclui
         EEB->(dbSeek(xFilial("EEB")+EE7->EE7_PEDIDO+OC_PE))
         EEB->(dbEval(bAddWork,,{|| !EEB->(EOF()) .AND. EEB->EEB_FILIAL == xFilial("EEB") .And.;
         EEB->EEB_PEDIDO == EE7->EE7_PEDIDO.AND.EEB->EEB_OCORRE==OC_PE}))
      Endif

      //** Tratamento p/ o work de Instituicoes Financeiras ...
      bAddWork := {|| WorkIn->(dbAppend()),AP100INSGrava(.T.,OC_PE)}
      EEJ->(DBSETORDER(1))

      IF ! Inclui
         EEJ->(dbSeek(xFilial("EEJ")+EE7->EE7_PEDIDO+OC_PE))
         EEJ->(dbEval(bAddWork,,{||  !EEJ->(EOF()) .AND. EEJ->EEJ_FILIAL == xFilial("EEJ") .And.;
         EEJ->EEJ_PEDIDO == EE7->EE7_PEDIDO.AND.EEJ->EEJ_OCORRE==OC_PE}))
      Endif

      //** Tratamento p/ o work de Despesas ...
      bAddWork := {|| WorkDe->(dbAppend()),AP100DSGrava(.T.,OC_PE)}
      EET->(DBSETORDER(1))

      IF ! Inclui
         cKey := AVKey(EE7->EE7_PEDIDO,"EET_PEDIDO")
         EET->(dbSeek(xFilial("EET")+cKey+OC_PE))
         EET->(dbEval(bAddWork,,{||EET->EET_FILIAL == xFilial("EET") .And.;
         EET->EET_PEDIDO+EET->EET_OCORRE == AvKey(cKey,"EET_PEDIDO")+OC_PE}))
      Endif

      //** Tratamento p/ o work de Notify's ...
      bAddWork := {|| WorkNo->(dbAppend()),AP100NoGrv(.T.,OC_PE)}
      EEN->(DBSETORDER(1))

      IF ! Inclui
         EEN->(dbSeek(xFilial("EEN")+EE7->EE7_PEDIDO+OC_PE))
         EEN->(dbEval(bAddWork,,{||  !EEN->(EOF()) .AND. EEN->EEN_FILIAL == xFilial("EEN") .And.;
         EEN->EEN_PROCES == EE7->EE7_PEDIDO.AND.EEN->EEN_OCORRE==OC_PE}))
      Endif

      //** Tratamento p/ o work de atividades ...
      IF Select("EXB") > 0
         If !Inclui
            bAddWork := {|| AP100DocGrava(.T.,OC_PE)}
            aOrd := SaveOrd("EXB")
            EXB->(dbSetOrder(2))
            EXB->(dbSeek(xFilial("EXB")+AvKey("","EXB_PREEMB")+M->EE7_PEDIDO+"1"))
            EXB->(dbEval(bAddWork,,{|| EXB->(!Eof()) .And. EXB->EXB_FILIAL == xFilial("EXB") .And.;
            EXB->EXB_TIPO = "1" .And. EXB->EXB_PEDIDO == M->EE7_PEDIDO .And.;
            Empty(EXB->EXB_PREEMB)}))
            RestOrd(aOrd)
         EndIf
      Endif

      aDeletados := AClone(aDel)
      EECFAT2(4,"GRV")

   Endif
   // ** FJH 18/11/05 ** Fim da Alteração.

End Sequence

Return Nil

/*
Funcao      : AP100Price()
Parametros  : Nenhum
Retorno     : .t./.f.
Objetivos   : Auxiliar a função Ap100fixPrice()
Autor       : Jeferson Barros Jr.
Data/Hora   : 24/06/2002 13:17
Revisao     :
Obs.        :
*/
*------------------------------------*
Static Function AP100Price()
*------------------------------------*
Local nI
Local cMoedaCot := "" //DFS - 11/09/12 - Inclusão de variavel para receber o conteudo do parametro MV_AVG0218
Local oGets

// By JPP - 09/10/2006 - 16:00 - Estas variaveis passaram a ser definidas como private para customização.
Private lRet:=.t.,oDlg,cTitulo,nOpc:=0,nPercFiEx:=0,nPercPaiEx:=0
Private bOk:={|| If(AP100ValFix(),(nOpc:=1,oDlg:End()),Nil) }
Private bCancel:={||oDlg:End()},cDesc:="",cCodUnidLot:=EasyGParam("MV_AVG0034")
Private bSetVal:={|nX| If(nX=1,nValFix:=nVlCotacao+nDiferencial,nVlCotacao:=nValFix-nDiferencial), .t.}

Private bSetCotMoeda := {}
Private nVlCotMoe := 0  //DFS - 11/09/12 - Inclusão de variavel para tratar o valor da cotação na moeda corrente de acordo com o parametro MV_AVG0218
Private nDiferMoe := 0  //DFS - 11/09/12 - Inclusão de variavel para tratar o diferencial na moeda corrente de acordo com o parametro MV_AVG0218

Private bSetQtd, bValidQtd := {|x| If(!Empty(cCodUnidLot) .Or. (EECFlags("BOLSAS") .And. !Empty(cBolsa)),Eval(bSetQtd,x),.T.) .And. VldPrice("nQtdeFix")  }
Private nTamTela := 33.0/*31.2*/, nTamLbl := 11.9, nTamColTela := 55, nTamColLbl := 22.2

Private aCampos := {}

// By JPP - 09/10/2006 - 16:00 - Fim

Private cDataFix     := "",;
        nDiferencial := 0,;
        dDtaCota     := AvCtod(""),;
        nValFix      := 0,;
        nQtdeFix     := 0,;
        nQtdeLot     := 0,;
        dDtaFix      := AvCtod(""),;
        cSequen      := "",;
        cPICTVALFX,;
        cPICTVALCT,;
        cBolsa,;
        cPictLot     := AvSx3("EE8_QTDLOT",AV_PICTURE)    // By JPP - 17/01/2006 - 09:30


If EECFlags("BOLSAS") // ** JPM - 02/02/06
   bSetQtd:={|nX| If(nX=1,nQtdeLot:=If(!Empty(cBolsa),;
                                       Ap104CalcLot(nQtdeFix,WorkFix->EE8_UNIDAD,cBolsa),; // com a bolsa preenchida, usa os tratamentos
                                       AvTransUnid(WorkFix->EE8_UNIDAD,cCodUnidLot,WorkFix->EE8_COD_I,nQtdeFix,.F.)),; // sem a bolsa, usa o MV
                  If(nQtdeFix=0 .Or. !VldPrice("nQtdeFix",.F.),nQtdeFix:=If(!Empty(cBolsa),;
                                                                            Ap104CalcLot(nQtdeLot,WorkFix->EE8_UNIDAD,cBolsa,.T.),;
                                                                            AvTransUnid(cCodUnidLot,WorkFix->EE8_UNIDAD,WorkFix->EE8_COD_I,nQtdeLot,.F.)),Nil)), .t.}
Else
   bSetQtd:={|nX| If(nX=1,nQtdeLot:=AvTransUnid(WorkFix->EE8_UNIDAD,cCodUnidLot,WorkFix->EE8_COD_I,nQtdeFix,.F.),;
                  If(nQtdeFix=0 .Or. !VldPrice("nQtdeFix",.F.),nQtdeFix:=AvTransUnid(cCodUnidLot,WorkFix->EE8_UNIDAD,WorkFix->EE8_COD_I,nQtdeLot,.F.),Nil)), .t.}
EndIf

Begin Sequence

   cPICTVALCT := cPICTVALFX := EECPreco("EE8_PRECO", AV_PICTURE)
   Aadd(aCampos,{"cSequen"   ,{|| .T.}                                                                                         ,{||.F.}          ,.F.    ,AvSx3("EE8_SEQUEN",AV_TITULO)                                 ,    ,.F.   ,45      ,    ,AVSX3("EE8_SEQUEN",AV_PICTURE)})
   Aadd(aCampos,{"cCodDesc"  ,{|| .T.}                                                                                         ,{||.F.}          ,.F.    ,STR0075                                                       ,    ,.F.   ,100     ,    ,                              })   //"Cod/Descrição"

   If EECFlags("BOLSAS")
      Aadd(aCampos,{"cBolsa"    ,{|| (Vazio() .Or. ExistCpo("SX5","YP"+cBolsa)) .And. If(!Empty(cBolsa),Eval(bValidQtd,1),.T.)},{|| !lRvPed11}   ,.F.    ,AVSX3("EX7_CODBOL",AV_TITULO)                                 ,    ,.F.   ,45      ,"YP",                              })
   EndIf

   Aadd(aCampos,{"cDataFix"    ,{|| (Vazio() .Or. VldPrice("cDataFix"))}                                                       ,{|| .T.}         ,.F.    ,AVSX3("EE8_MESFIX",AV_TITULO)                                 ,    ,.F.   ,45      ,    ,AVSX3("EE8_MESFIX",AV_PICTURE)})
   Aadd(aCampos,{"dDtaCota"    ,{|| (Vazio() .Or. ( VldPrice("dDtaCota")) .And. Eval(bSetVal,1)) }                                                       ,{|| .T.}         ,.F.    ,AVSX3("EE8_DTCOTA",AV_TITULO)                                 ,    ,.F.   ,45      ,    ,AVSX3("EE8_DTCOTA",AV_PICTURE)})
   Aadd(aCampos,{"dDtaFix"     ,{|| .T.}                                                                                       ,{|| .T.}         ,.F.    ,AVSX3("EE8_DTFIX ",AV_TITULO)                                 ,    ,.F.   ,45      ,    ,AVSX3("EE8_DTFIX",AV_PICTURE) })
   Aadd(aCampos,{"nDiferencial",{|| (Vazio() .Or. VldPrice("nDiferencial"))}                                                   ,{|| .T.}         ,.F.    ,AVSX3("EE8_DIFERE",AV_TITULO)                                 ,    ,.F.   ,50      ,    ,AVSX3("EE8_DIFERE",AV_PICTURE)})

   //DFS - 11/09/12 - Inclusão de tratamento para diferencial na moeda corrente
   If !Empty((cMoedaCot  := EasyGParam("MV_AVG0218",,"US$"))) .And. cMoedaCot <> "US$"
      Aadd(aCampos,{"nDiferMoe",{|| (Vazio() .Or. VldPrice("nDiferMoe"))}                                                      ,{|| .T.}         ,.F.    ,AVSX3("EE8_DIFERE",AV_TITULO) + " " + AllTrim(cMoedaCot)      ,    ,.F.   ,50      ,    ,AVSX3("EE8_DIFERE",AV_PICTURE)})
   EndIf

   Aadd(aCampos,{"nQtdeFix"    ,{|| Eval(bValidQtd,1)}                                                                         ,{|| .T.}         ,.F.    ,AVSX3("EE8_QTDFIX",AV_TITULO)+" "+BuscaUM(WorkFix->EE8_UNIDAD),    ,.F.   ,50      ,    ,AVSX3("EE8_SLDINI",AV_PICTURE)})
   Aadd(aCampos,{"nQtdeLot"    ,{|| Eval(bValidQtd,2)}                                                                         ,{|| .T.}         ,.F.    ,AVSX3("EE8_QTDLOT",AV_TITULO)                                 ,    ,.F.   ,50      ,    ,cPictLot                      })

   //DFS - 11/09/12 - Inclusão de tratamento para valor da cotação na moeda corrente
   If !Empty((cMoedaCot  := EasyGParam("MV_AVG0218",,"US$"))) .And. cMoedaCot <> "US$"
      Aadd(aCampos,{"nVlCotMoe", {|| Vazio() .OR. (VldPrice("nVlCotMoe") .AND. Eval(bSetVal,1)) }                              ,{|| .T.}         ,.F.    ,STR0076 + " " + cMoedaCot                                     ,    ,.F.   ,60      ,    ,cPICTVALCT                    })
   EndIf

   //DFS - 11/09/12 - Inclusão de tratamento para validar a mudança manual do valor da cotação
   Aadd(aCampos,{"nVlCotacao"  ,{|| Vazio() .OR. (Eval(bSetVal,1) .AND. VldPrice("nVlCotacao")) }                              ,{|| .T.}         ,.F.    ,STR0076+STR0163                                               ,    ,.F.   ,60      ,    ,cPICTVALCT                    })//"Vl.Cotação"###" US$/LB"
   Aadd(aCampos,{"nValFix"     ,{|| Vazio() .OR. (Eval(bSetVal,2) .AND. VldPrice("nValFix"))    }                              ,{|| .T.}         ,.F.    ,STR0077+STR0164                                               ,    ,.F.   ,60      ,    ,cPICTVALFX                    })//"Preço Final"###" cents US$/LB"

   If EECFlags("CAFE")
      Aadd(aCampos,{"nValUSTon" ,{|| (nValFix := APPriceConv(12, nValUSTon),Eval(bSetVal,2))}                                  ,{|| .T.}         ,.F.    ,STR0077+STR0165                                               ,    ,.F.   ,60      ,    ,cPICTVALFX                    })
   EndIf
   // Fim montagem array aCampos
   //Criar Objetos a serem utilizados na montagem da tela, junto com aCampos
   For nI := 1 To Len(aCampos)
       Private &("o"+aCampos[nI][1]) := 0
   Next
   // Fim criação dos objetos

   cTitulo      := AVSX3("EE7_PEDIDO",AV_TITULO)+" - "+AllTrim(EE7->EE7_PEDIDO) //+" - "+STR0072 //"Filial Brasil"
   cDataFix     := If(Empty(WorkFix->EE8_MESFIX),If((Type("lSI300") == "L" .And. lSi300), EEY->(StrZero(EEY_MESFIX,2)+StrZero(EEY_ANOFIX,4)), WorkFix->EE8_MESFIX),WorkFix->EE8_MESFIX)
   dDtaCota     := WorkFix->EE8_DTCOTA
   nDiferencial := WorkFix->EE8_DIFERE
   nQtdeFix     := If(Empty(WorkFix->EE8_QTDFIX),WorkFix->EE8_SLDINI,WorkFix->EE8_QTDFIX)
   nQtdeLot     := WorkFix->EE8_QTDLOT
   cSequen      := AllTrim(WorkFix->EE8_SEQUEN)
   cCodDesc     := AllTrim(WorkFix->EE8_COD_I)+" / "+Memoline(WorkFix->EE8_VM_DES,60,1)
   dDtaFix      := WorkFix->EE8_DTFIX
   nValFix      := WorkFix->EE8_PRECO
   If EECFlags("CAFE")
      nValUSTon := APPriceConv(9, nValFix)
      bSetVal   := {|nX| If(nX=1,nValFix:=nVlCotacao+nDiferencial,nVlCotacao:=nValFix-nDiferencial), nValUSTon := APPriceConv(9, nValFix),.t.}
      nTamTela  += 4.5
      nTamLbl   += 1.35
   EndIf

   If EECFlags("BOLSAS")
      cBolsa := If (!Empty(EE7->EE7_CODBOL), EE7->EE7_CODBOL,CriaVar("EE7_CODBOL"))
   EndIf

   IF EasyEntryPoint("EECAP105")
      EXECBLOCK("EECAP105",.F.,.F.,"PICT")
   ENDIF

   DEFINE MSDIALOG oDlg TITLE STR0074+" - "+cTitulo FROM 9,0 TO nTamTela,nTamColTela OF oMainWnd //"Fixação de Preço"
      oDlg:lEscClose := .F.
      aPos := PosDlg(oDlg)

      oGets := AE109Gets(oDlg, aPos, aCampos)
      oGets:Align:= CONTROL_ALIGN_ALLCLIENT

      If EasyEntryPoint("EECAP105")  // By JPP - 09/11/2006 - 16:00                 -
         ExecBlock("EECAP105",.F.,.F.,"MONTANDO_DIALOG_PRICE")
      EndIf

      //DFS - 11/09/12 - Tratamento para carregar os valores digitados anteriormente.
      If nVlCotacao <> 0
        nVlCotMoe := ((nVlCotacao   * BuscaTaxa("US$",dDtaCota ,.T.,.F.,.T.)) / BuscaTaxa(EasyGParam("MV_AVG0218",,"US$"),dDtaCota,.T.,.F.,.T.))
      EndIf
      If nDiferencial <> 0 .AND. !Empty(dDtaCota)
        nDiferMoe := ((nDiferencial * BuscaTaxa("US$",dDtaCota,.T.,.F.,.T.)) / BuscaTaxa(EasyGParam("MV_AVG0218",,"US$"),dDtaCota,.T.,.F.,.T.))
      Else
        nDiferMoe := ((nDiferencial * BuscaTaxa("US$",dDataBase ,.T.,.F.,.T.)) / BuscaTaxa(EasyGParam("MV_AVG0218",,"US$"),dDataBase,.T.,.F.,.T.))
      EndIf

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   If nOpc == 1 .and. EE7->EE7_STATUS = ST_RV .and. WorkFix->EE8_SLDINI <> WorkFix->EE8_SLDATU
      If !AP105MarkPed()
         nOpc := 0
      EndIf
   EndIf

   If nOpc == 1
      // ** Atualiza os campos da work de fixacao ...
      WorkFix->EE8_MESFIX := cDataFix
      WorkFix->EE8_DIFERE := nDiferencial
      WorkFix->EE8_DTCOTA := dDtaCota
      WorkFix->EE8_PRECO  := nValFix
      WorkFix->EE8_DTFIX  := dDtaFix
      WorkFix->EE8_QTDFIX := nQtdeFix
      WorkFix->EE8_QTDLOT := nQtdeLot

      If EECFlags("BOLSAS")
         WorkFix->WK_VLCOT   := APPriceConv(7,nVlCotacao)
      Else
         WorkFix->WK_VLCOT   := nVlCotacao
      EndIf
      WorkFix->WK_FLAG    := "1" // Flag preco fixado ...
      If EECFlags("BOLSAS")
         cCodBolsa := cBolsa
      EndIf
      IF EasyEntryPoint("EECAP105")
         EXECBLOCK("EECAP105",.F.,.F.,"GRVBRA")
      ENDIF
   EndIf

End Sequence

Return lRet

*---------------------------------*
Static Function VldPrice(cCpo,lMsg)
*---------------------------------*
Local lRet := .t., nQE := 0, lRetBlock
Local cUniMedDe   := EasyGParam("MV_AVG0030",, "TL")
Local cUniMedPara := WorkFix->EE8_UNIDAD

Private nQtdenaEmb  := EasyGParam("MV_AVG0066",, 0.6)

Default lMsg := .T.
   IF EasyEntryPoint("EECAP105")
      EXECBLOCK("EECAP105",.F.,.F.,"CALC_QTDENAEMB")
   ENDIF

Begin Sequence
   Do Case

      //DFS - 11/09/12 - Inclusão de tratamento para quando efetuar a digitação manual
      Case cCpo == "nVlCotMoe"
         nVlCotacao := ((nVlCotMoe   * BuscaTaxa(EasyGParam("MV_AVG0218",,"US$"),dDtaCota,.T.,.F.,.T.)) / BuscaTaxa("US$",dDtaCota,.T.,.F.,.T.))
      Case cCpo == "nVlCotacao"
         nVlCotMoe := ((nVlCotacao   * BuscaTaxa("US$",dDtaCota,.T.,.F.,.T.))                      / BuscaTaxa(EasyGParam("MV_AVG0218",,"US$"),dDtaCota,.T.,.F.,.T.))
      Case cCpo == "nDiferMoe"
         nDiferencial := ((nDiferMoe * BuscaTaxa(EasyGParam("MV_AVG0218",,"US$"),dDtaCota,.T.,.F.,.T.)) / BuscaTaxa("US$",dDtaCota,.T.,.F.,.T.))
      Case cCpo == "nDiferencial"
         nDiferMoe := ((nDiferencial * BuscaTaxa("US$",dDtaCota,.T.,.F.,.T.))                      / BuscaTaxa(EasyGParam("MV_AVG0218",,"US$"),dDtaCota,.T.,.F.,.T.))
      Case cCpo == "nValFix"
         nVlCotMoe := ((nVlCotacao   * BuscaTaxa("US$",dDtaCota,.T.,.F.,.T.))                      / BuscaTaxa(EasyGParam("MV_AVG0218",,"US$"),dDtaCota,.T.,.F.,.T.))
      Case cCpo == "nQtdeFix"

         If !EECFlags("CAFE")
            nQE := AVTransUnid(cUniMedDe, cUniMedPara,, nQtdenaEmb, .T.)

            If nQE = Nil
   	           MsgInfo(STR0133+cUniMedDe+STR0134+cUniMedPara+STR0135, STR0022) //"Não foi encontrada a conversão de "###" para "###" na tabela de conversão de unidade de medida."###"Atenção"
               lRet := .F.
               Break
            EndIf

            IF (nQtdeFix % nQE) <> 0
               If lMsg
                  MsgInfo(STR0104, STR0022) //"Quantidade deve ser multipla pela qtde de embalagem!"###"Atenção"
               EndIf
               lRet := .F.
               Break
            Endif
         EndIf

         IF EasyEntryPoint("EECAP105")
            lRetBlock := ExecBlock("EECAP105", .F., .F., "VLDQTDEFIX")
            IF ValType(lRetBlock) == "L"
               lRet := lRetBlock
            Endif
         Endif

      Case cCpo == "cDataFix"

        If !Empty(cBolsa) .And. EECFlags("BOLSAS")
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
               MsgInfo( STR0139 + ENTER + STR0140 )//"Não encontrada cotação para a data informada." "Foi selecionada automaticamente a data mais recente cadastrada no sistema para o periodo informado."
            EndIf

            nVlCotacao := nCot

            //DFS - 11/09/12 - Se o conteudo do parametro for diferente de dolar, busca qual valor da cotação para a moeda definida.
            If EasyGParam("MV_AVG0218",,"US$") <> "US$"
               nVlCotMoe := BuscaVlCot(cDataFix,cBolsa,dDtaCota,EasyGParam("MV_AVG0032",,""), .T.)
            EndIf
         EndIf

   EndCase
End Sequence

Return lRet


Function APPriceConv(nOpc, nValor)
Local nRet

Begin Sequence

   /////////////////////////////////////////////////////////////////////////
   //No caso de pedido e embarque, transforma a unidade de medida de preço//
   //para quilograma e assim realiza as conversões.                       //
   /////////////////////////////////////////////////////////////////////////
   If FunName() == "EECAP100"
      If AllTrim(ReadVar()) == "M->EE8_PRECO"
         If !Empty(M->EE8_UNPES) .and. AllTrim(Upper(M->EE8_UNPES)) <> "KG"
            nValor := AvTransUnid(M->EE8_UNPES,"KG",M->EE8_COD_I,nValor,.F.,.T.)
         EndIf
      EndIf
   ElseIf FunName() == "EECAE100"
      If AllTrim(ReadVar()) == "M->EE9_PRECO"
         If !Empty(M->EE9_UNPES) .and. AllTrim(Upper(M->EE9_UNPES)) <> "KG"
            nValor := AvTransUnid(M->EE9_UNPES,"KG",M->EE9_COD_I,nValor,.F.,.T.)
         EndIf
      EndIf
   EndIf

   If EasyEntryPoint("EECAP105")  // JPM - 16/01/06
      Private nOption := nOpc, nVal := nValor
      nRet := ExecBlock("EECAP105",.F.,.F.,"PRICECONV")
      If ValType(nRet) = "N"
         Return nRet
      EndIf
   EndIf

   //DFS - 14/09/12 - Alterado o valor da conversão para 1.3228 conforme legislação
   Do Case
      Case nOpc == 1  //US$/Sc 50Kg para US$/Sc 60Kg
         nValor := nValor * 1.2
      Case nOpc == 2  //US$/Sc 50Kg para Cents/Lib
         nValor := ( (nValor * 1.2) / 1.3228 )
      Case nOpc == 3  //US$/Sc 50Kg para US$/Ton
         nValor := ( (nValor / 50) * 1000)
      Case nOpc == 4  //US$/Sc 60Kg para US$/Sc 50Kg
         nValor := nValor/1.2
      Case nOpc == 5  //US$/Sc 60Kg para Cents/Lib
         nValor := ( (nValor / 1.3228) )
      Case nOpc == 6  //US$/Sc 60kg para US$/Ton
         nValor := ( (nValor / 60) * 1000 )
      Case nOpc == 7  //Cents/Lb para US$/Sc 50Kg
         nValor := ((nValor * 1.3228) ) / 1.2
      Case nOpc == 8  //Cents/Lb para US$/Sc 60Kg
         nValor := (nValor * 1.3228)
      Case nOpc == 9  //Cents/Lb para US$/Ton
         nValor := (((nValor * 1.3228) ) / 60) * 1000
      Case nOpc == 10 //US$/Ton para US$/Sc 50kg
         nValor := (nValor / 1000) * 50
      Case nOpc == 11 //US$/Ton para US$/Sc 60Kg
         nValor := (nValor / 1000) * 60
      Case nOpc == 12 //US$/Ton para Cents/Lb
         nValor := (((nValor / 1000) * 60) / 1.3228)
      Case nOpc == 13 //US$/KG para US$/Sc 50kg
         nValor := (nValor) * 50
      Case nOpc == 14 //US$/KG para US$/Sc 60Kg
         nValor := (nValor) * 60
      Case nOpc == 15 //US$/KG para Cents/Lb
         nValor := (((nValor) * 60) / 1.3228)
      Case nOpc == 16 //US$/Sc 50Kg para US$/KG
         nValor := ( (nValor / 50))
      Case nOpc == 17  //US$/Sc 60kg para US$/KG
         nValor := ( (nValor / 60))
      Case nOpc == 18  //Cents/Lb para US$/KG
         nValor := (((nValor * 1.3228) ) / 60)
      Case nOpc == 19  //US$/Sc 50Kg para US$/Lb
         nValor := ( (nValor * 1.2) / 1.3228 ) / 100
      Case nOpc == 20  //US$/Sc 60Kg para US$/Lb
         nValor := ( (nValor / 1.3228) ) / 100
      Case nOpc == 21  //Cents/Lb para US$/Lb
         nValor := nValor / 100
      Case nOpc == 22  //US$/KG para US$/Lb
         nValor := (((nValor) * 60) / 1.3228) / 100
      Case nOpc == 23  //US$/Ton para US$/Lb
         nValor := (((nValor / 1000) * 60) / 1.3228) / 100
      Case nOpc == 24  //US$/Lb para US$/Sc 50Kg
         nValor := (((nValor * 1.3228) ) / 1.2 ) * 100
      Case nOpc == 25  //US$/Lb para US$/Sc 60Kg
         nValor := (nValor * 1.3228) * 100
      Case nOpc == 26  //US$/Lb para Cents/Lb
         nValor := nValor * 100
      Case nOpc == 27  //US$/Lb para US$/KG
         nValor := (((nValor * 1.3228) ) / 60) * 100
      Case nOpc == 28  //US$/Lb para US$/Ton
         nValor := ((((nValor * 1.3228) ) / 60) * 1000) * 100
   End Case

End Sequence

Return nValor


/*
Funcao      : AP100ValFix()
Parametros  : Nenhum
Retorno     : .t./.f.
Objetivos   : Validar os parametros informados na tela de fixação de preço.
Autor       : Jeferson Barros Jr.
Data/Hora   : 02/07/2002 13:41
Revisao     :
Obs.        :
*/
*-----------------------------*
Static Function AP100ValFix()
*-----------------------------*
Local lRet:=.t.,cCampos:="", i

Private aParametro:={}

Begin Sequence

   //ER - 21/01/06 às 17:00
   If Empty(cDataFix)
      If Ascan(aParametro,AVSX3("EE8_MESFIX",AV_TITULO))=0
         Aadd(aParametro,AVSX3("EE8_MESFIX",AV_TITULO))
      EndIf
   EndIf

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
      If Ascan(aParametro,STR0076)=0  //"Vl.Cotação"
         Aadd(aParametro,STR0076)  //"Vl.Cotação"
      EndIf
   EndIf

   If nValFix <= 0
      If Ascan(aParametro,STR0077)=0 //"Preço Final"
         Aadd(aParametro,STR0077)  //"Preço Final"
      EndIf
   EndIf

   If nQtdeLot <= 0
      If Ascan(aParametro,AVSX3("EE8_QTDLOT",AV_TITULO))=0
         Aadd(aParametro,AVSX3("EE8_QTDLOT",AV_TITULO))
      EndIf
   EndIf

   If nQtdeFix > WorkFix->EE8_SLDINI
      If Ascan(aParametro,AVSX3("EE8_QTDFIX",AV_TITULO))=0
         Aadd(aParametro,AVSX3("EE8_QTDFIX",AV_TITULO))
      EndIf
   EndIf

   If EasyEntryPoint("EECAP105")
      EXECBLOCK("EECAP105",.F.,.F.,"VALIDFIX")
   EndIf

   If Len(aParametro) > 0
      For i:=1 To Len(aParametro)
         cCampos+=aParametro[i]+ENTER
      Next

      MsgStop(STR0079+ENTER+; //"Problema:"
              STR0087+Replic(ENTER,2)+; //"Parametro(s) inválido(s) para a fixação de preço."
              STR0082+ENTER+; //"Solução:"
              STR0088+Replic(ENTER,2)+; //"Verifique o(s) seguinte(s) campo(s):"
              cCampos,STR0022) //"Atenção"
      lRet:=.f.
   EndIf

End Sequence

Return lRet


/*
Funcao      : AP100ShowFix()
Parametros  : lGatilho => .t. - Chamada via gatilho.
    						     .f. - Chamada via relação.
Retorno     : .t./.f.
Objetivos   : Manter a compatibilidade com dicionários de dados que tenham a chamada desta função ao invés
              da AP100ShowStFix().
Autor       : Alexsander Martins dos Santos
Data/Hora   : 21/07/2004 às 10:40.
*/

Function Ap100ShowFix(lGatilho)
Return(Ap100ShowStFix(lGatilho))

/*
Funcao      : AP100ShowStFix()
Parametros  : lGatilho => .t. - Chamada via gatilho.
						  .f. - Chamada via relação.
Retorno     : .t./.f.
Objetivos   : Atualizar a situação de fixação de preço.
Autor       : Jeferson Barros Jr.
Data/Hora   : 25/06/2002 15:31
Revisao     :
Obs.        :
*/
*-------------------------------*
Function Ap100ShowStFix(lGatilho)
*-------------------------------*
Local cRet:=""

Default lGatilho := .f.

Begin Sequence

  If !lGatilho
     If Type("WorkIt->EE8_STFIX") == "C"
        If WorkIt->EE8_STFIX = "0"
           cRet := SF_SS
        ElseIf WorkIt->EE8_STFIX ="1"
           cRet := SF_SD
        ElseIf WorkIt->EE8_STFIX ="2"
           cRet := SF_FX
        ElseIf WorkIt->EE8_PRECO > 0
           cRet:=SF_PI
        Else
           cRet := SF_SS
        EndIf
     EndIf
  Else
     cRet:=SF_SS
     If M->EE8_PRECO > 0
        cRet:=SF_PI
        If M->EE8_DIFERE <> 0
           cRet:= SF_PI
           If !Empty(M->EE8_DTFIX)
     	      cRet:=SF_FX
           EndIf
        EndIf
     Else
        If M->EE8_DIFERE <> 0
           cRet:= SF_SD
        EndIf
     EndIf
  EndIf

End Sequence

Return cRet

/*
Funcao      : AP100GrvStFix()
Parametros  : Nenhum
Retorno     : .t./.f.
Objetivos   : Gravar a situação de fixação de preço.
Autor       : Jeferson Barros Jr.
Data/Hora   : 25/06/2002 15:42
Revisao     :
Obs.        :
*/
*----------------------*
Function AP100GrvStFix()
*----------------------*
Local lRet:=.t.

Begin Sequence

   M->EE8_STFIX:="0"

   If M->EE8_PRECO > 0
      M->EE8_STFIX:=""
      If M->EE8_DIFERE <> 0
         M->EE8_STFIX:= ""
         If !Empty(M->EE8_DTFIX)
            M->EE8_STFIX:="2"
         EndIf
      EndIf
   Else
      If M->EE8_DIFERE <> 0
         M->EE8_STFIX:= "1"
      EndIf
   EndIf

End Sequence

Return lRet


/*
Função      : AP100EstPrice()
Objetivo    : Estorno da fixação de preço.
Retorno     : .T. -> Estorno com sucesso, .F. -> Não houve sucesso no estorno.
Autor       : Alexsander Martins dos Santos
Data e Hora : 06/05/2004 às 15:15.
*/

Function AP100EstPrice()

Local lRet            := .F.

Private cWorkEE8      := ""
Private cWkITVincRV   := ""
Private nQtdeMarca    := 0

Begin Sequence

   MSAguarde({|| MSProcTxt(STR0105), lRet := E_PriceGeraWork()}, STR0106) //"Selecionando Itens do Pedido ..."###"Estorno da fixação de preço"

   If lRet

      If E_PriceT1()
         Processa({|| lRet := E_PRICEATUPED(), STR0107, STR0108, .F.}) //"Aguarde"###"Estornando Fixação de Preço"
      Else
         lRet := .f.
      EndIf

      WkITVincRV->(dbCloseArea())
      fErase(cWkITVincRV)

      WorkEE8->(dbCloseArea())
      fErase(cWorkEE8)

      If !Empty(aDetailMsg)
         SI301HistFix(.F.) //Grava histórico da fixação de preço
      EndIf

   Else
      MsgInfo(STR0109, STR0022) //"Não foram encontrados itens com Fixação de Preço para serem estornados."###"Atenção"
   EndIf

End Sequence

Return(lRet)


/*
Função      : E_PriceGeraWork
Objetivo    : Geração de Work com os itens do pedido para estorno de fixação.
Retorno     : .T. quando gerar registro(s) na Work e .F. caso contrário.
Autor       : Alexsander Martins dos Santos
Data e Hora : 06/05/2004 às 15:27.
*/

Static Function E_PriceGeraWork()

Local lRet     := .F.
Local aSaveOrd := SaveOrd("EE8")
Local nPos     := 0

Local aWorkEE8 := {WKField("EE8_RV")    ,;
                   WKField("EE8_SEQUEN"),;
                   WKField("EE8_COD_I") ,;
                   WKField("EE8_VM_DES"),;
                   WKField("EE8_SLDINI"),;
                   WKField("EE8_SLDATU"),;
                   WKField("EE8_PRECO") ,;
                   WKField("EE8_DIFERE"),;
                   WKField("EE8_MESFIX"),;
                   WKField("EE8_DTFIX") ,;
                   WKField("EE8_ORIGEM"),;
                   WKField("EE8_ORIGV"),;
                   WKField("EE8_UNIDAD"),;
                   {"WK_FLAG", "C", 02, 00}}

Local aWkITVincRV := {WKField("EE8_PEDIDO"),;
                      WKField("EE8_SEQUEN"),;
                      WKField("EE8_COD_I") ,;
                      {"EE8_VM_DES", "C", 35, 00},;
                      WKField("EE8_SLDATU"),;
                      WKField("EE8_SLDINI"),;
                      WKField("EE8_RV"),;
                      WKField("EE8_ORIGV"),;
                      WKField("EE8_DTFIX"),;
                      WKField("EE8_PRECO"),;
                      WKField("EE8_UNIDAD"),;
                      {"WK_RECNO", "N", 10, 00},;
                      {"WK_FLAG",  "C", 02, 00}}

Private aCampos := {}

cWorkEE8     := E_CriaTrab(, aWorkEE8, "WorkEE8")

cWkITVincRV  := E_CriaTrab(, aWkITVincRV, "WkITVincRV")
IndRegua("WkITVincRV", cWkITVincRV+TEOrdBagExt(), "EE8_RV")

Begin Sequence

   EE8->(dbSetOrder(1))
   EE8->(dbSeek(xFilial()+EE7->EE7_PEDIDO))

   While EE8->(!Eof() .and. EE8_FILIAL == xFilial() .and. EE8_PEDIDO == EE7->EE7_PEDIDO)

      If !Empty(EE8->EE8_DTFIX) .And. If(lNewRv .And. lRvPed11,EE8->EE8_RV == EEY->EEY_NUMRV,.T.) // no novo tratamento, só vai fixar itens que tenham o mesmo R.V. do registro do EEY

         WorkEE8->(dbAppend())

         For nPos := 1 To WorkEE8->(fCount())-3
            If EE8->(FieldPos(WorkEE8->(FieldName(nPos)))) > 0 .And. Posicione("SX3", 2, WorkEE8->(FieldName(nPos)), "X3_CONTEXT") <> "V"
               WorkEE8->(FieldPut(nPos, EE8->(FieldGet(FieldPos(WorkEE8->(FieldName(nPos)))))))
            EndIf
         Next

         WorkEE8->WK_FLAG    := "  "
         WorkEE8->EE8_VM_DES := EasyMSMM(EE8->EE8_DESC, AVSX3("EE8_VM_DES", AV_TAMANHO),, ,,,, "EE8", "EE8_DESC")

      EndIf

      EE8->(dbSkip())

   End

   lRet := WorkEE8->(EasyRecCount()) > 0

End Sequence

RestOrd(aSaveOrd)

Return(lRet)


/*
Função      : WKField
Parametro   : cField -> Campo a retornar a estrutura.
Objetivo    : Função de apoio p/ retornar a estrutura do campo com base no SX3.
Autor       : Alexsander Martins dos Santos
Data e Hora : 06/05/2004 às 16:03.
*/

Static Function WKField(cField)

Local aStru := {cField,;
                AVSX3(cField, AV_TIPO),;
                AVSX3(cField, AV_TAMANHO),;
                AVSX3(cField, AV_DECIMAL)}

Return(aStru)


/*
Função      : E_PriceT1
Objetivo    : Tela de seleção de itens a serem estornados.
Retorno     : .T. indica que houve seleção de itens e foi precionado o botão Confirma, .F. foi cancelada.
Autor       : Alexsander Martins dos Santos
Data e Hora : 06/05/2004 às 17:28.
*/

Static Function E_PriceT1()

Local lRet  	    := .F.
Local nPos          := 0
Local nOpc          := 0
Local aSelectFields := {}
Local bOk           := {|| nOpc := 1, If(E_PriceT1Vld(), oDlg:End(), nOpc := 0)}
Local bCancel       := {|| nOpc := 0, oDlg:End()}

Private cMarca      := GetMark()
Private lInverte    := .F.
DbSelectArea("WorkEE8")

aAdd(aSelectFields, {"WK_FLAG", "XX", ""})

For nPos := 1 To WorkEE8->(fCount())-3
   If EE8->(FieldPos(WorkEE8->(FieldName(nPos)))) > 0 .And. Posicione("SX3", 2, WorkEE8->(FieldName(nPos)), "X3_CONTEXT") <> "V"
      aAdd(aSelectFields, ColBrw(WorkEE8->(FieldName(nPos)), "WorkEE8"))
   Else
      aAdd(aSelectFields, {{|| MemoLine(WorkEE8->EE8_VM_DES, 60, 1)},,AVSX3("EE8_VM_DES", AV_TITULO)})
   EndIf
Next

WorkEE8->(dbGoTop())

Define MSDialog oDlg Title STR0110 From DLG_LIN_INI,DLG_COL_INI To DLG_LIN_FIM,DLG_COL_FIM Of oMainWnd Pixel //"Estorno de Fixação de Preço"

   @ 1.4,0.8 Say AVSX3("EE7_PEDIDO", AV_TITULO)
   @ 1.4,15  Say AVSX3("EE7_DTPROC", AV_TITULO)

   @ 1.4,05  MSGet EE7->EE7_PEDIDO When .F. Size 50,7 Right
   @ 1.4,20  MSGet EE7->EE7_DTPROC When .F. Size 50,7 Right

   aPos    := PosDlgDown(oDlg)
   aPos[1] := 30

   oMSSelect       := MSSelect():New("WorkEE8", "WK_FLAG",, aSelectFields, @lInverte, @cMarca, aPos)
   oMSSelect:bAval := {|| E_PriceRVVinc()}

Activate MSDialog oDlg On Init EnchoiceBar(oDlg, bOk, bCancel)

lRet := (nOpc = 1)

Return(lRet)


/*
Função      : E_PriceT1Vld
Objetivo    : Validação para E_PriceT1.
Retorno     : .T. indica que os dados estão ok e .F. caso contrário.
Autor       : Alexsander Martins dos Santos
Data e Hora : 07/05/2004 às 10:40.
*/

Static Function E_PriceT1Vld()

Local lRet := .T., cOldArea := Alias()
Local cWk := "WkITVincRV"
Local aPedidos, aItens, aRecNos, cOrigem, i, j

Begin Sequence

   If nQtdeMarca = 0
      MsgStop(STR0111, STR0022) //"Deve ser selecionado no minimo 1 item para estorno !"###"Atenção"
      lRet := .F.
      Break
   EndIf

   DbSelectArea(cWk)
   aPedidos := {}
   aRecNos  := {}
   DbGoTop()
   While !EoF()
      If !Empty(WK_FLAG) // faz o levantamento dos itens que foram marcados para estorno
         EE8->(DbGoTo((cWk)->WK_RECNO))
         cOrigem := EE8->EE8_ORIGEM
         If (nPos := AScan(aPedidos,{|x| x[1] == EE8_PEDIDO})) = 0
            AAdd(aPedidos,{EE8_PEDIDO,{}})
            nPos := Len(aPedidos)
         EndIf
         aItens := aPedidos[nPos][2]
         If (nPos := AScan(aItens,{|x| x[1] == EE8_RV+EE8_ORIGV+cOrigem})) = 0
            AAdd(aItens,{EE8_RV+EE8_ORIGV+cOrigem,{}})
            nPos := Len(aItens)
         EndIf
         AAdd(aItens[nPos][2],WK_RECNO)
         AAdd(aRecNos,WK_RECNO)
      EndIf
      DbSkip()
   EndDo

   DbSelectArea("EE8")
   DbSetOrder(1)
   For i := 1 To Len(aPedidos)
      DbSeek(xFilial()+aPedidos[i][1]) // faz o levantamento dos itens que serão agrupados com os que foram desmarcados
      aItens := aPedidos[i][2]
      While !EoF() .And. xFilial()+aPedidos[i][1] == EE8_FILIAL+EE8_PEDIDO
         If Empty(EE8_DTFIX) .And. AScan(aRecNos,RecNo()) = 0
            If (nPos := AScan(aItens,{|x| x[1] == EE8_RV+EE8_ORIGV+EE8_ORIGEM})) > 0
               AAdd(aItens[nPos][2],RecNo())
            EndIf
         EndIf
         DbSkip()
      EndDo

      For j := 1 To Len(aItens)
         If !Ap104CanJoin(aItens[j][2],.F.) // verifica se os itens podem ser agrupados.
            lRet := .F.
            Break
         EndIf
      Next

   Next

End Sequence

Select(cOldArea)

Return(lRet)


/*
Função      : E_PriceRVVinc
Objetivo    : Verificar se o item selecionado é ST_RV e apresentar janela de seleção.
Autor       : Alexsander Martins dos Santos
Data e Hora : 07/05/2004 às 10:40.
*/

Static Function E_PriceRVVinc()

Private cRV          := WorkEE8->EE8_RV
Private dDtFix       := WorkEE8->EE8_DTFIX
Private nPreco       := WorkEE8->EE8_PRECO
Private cOrigem      := WorkEE8->EE8_ORIGEM

If Empty(WorkEE8->WK_FLAG)
   If (EE7->EE7_STATUS = ST_RV) .and. (WorkEE8->EE8_SLDINI <> WorkEE8->EE8_SLDATU)
      If !E_PricePedRV()
         If E_PriceT2()
            nQtdeMarca++
            WorkEE8->WK_FLAG := cMarca
         EndIf
      Else
         nQtdeMarca++
         WorkEE8->WK_FLAG := cMarca
      EndIf
   Else
      nQtdeMarca++
      WorkEE8->WK_FLAG := cMarca
   EndIf
Else
   nQtdeMarca--
   WorkEE8->WK_FLAG := ""
EndIf

Return Nil


/*
Função      : E_PriceAtuPed
Objetivo    : Atualização do(s) pedido(s) com o estorno da fixação de preço.
Retorno     : .T. indica que houve sucesso no estorno, .F. caso contrário.
Autor       : Alexsander Martins dos Santos
Data e Hora : 07/05/2004 às 11:04.
*/

Static Function E_PriceAtuPed()

Local lRet      := .F.
Local aSaveOrd  := SaveOrd({"EE8", "EEY", "EE7"})
Local nEE8Recno := 0
Local dDtFix, nPreco, nQtd := 0
//Local aPedFat   := {}, nPos, i
Local nPos, i // By JPP - 22/11/2006 - 10:45

Private aPedFat   := {} // By JPP - 22/11/2006 - 10:45

EE8->(dbSetOrder(1))

Begin Sequence

   ProcRegua(nQtdeMarca)

   Begin Transaction

      WorkEE8->(dbGoTop())

      While !WorkEE8->(Eof())

         If !Empty(WorkEE8->WK_FLAG)

            IncProc()

            EE8->(dbSeek(xFilial()+EE7->EE7_PEDIDO+WorkEE8->EE8_SEQUEN))

            dDtFix := EE8->EE8_DTFIX
            nPreco := EE8->EE8_PRECO

            AP105ClearFix()
            nQtd := 0
            If lNewRv
               nQtd := EE8->EE8_SLDINI
               AgruparItens(EE7->EE7_PEDIDO, WorkEE8->EE8_ORIGEM, {|| Empty(EE8_DTFIX)}, , EE8->(EE8_RV+EE8_ORIGV))
            Else
               If EE7->EE7_STATUS = ST_RV
                  AgruparItens(EE7->EE7_PEDIDO, WorkEE8->EE8_ORIGEM, {|| Empty(EE8_DTFIX)}, , EE8->(EE8_RV+EE8_ORIGV))
               Else
                  If (nPos := AScan(aPedFat,{|x| x[1] == EE8->EE8_PEDIDO} )) = 0
                     AAdd(aPedFat,{EE8->EE8_PEDIDO,{}})
                     nPos := Len(aPedFat)
                  EndIf
                  Eval({|x, y| aSize(x, Len(x)+Len(y)),;
                               aCopy(y, x,,, Len(x)-Len(y)+1 )}, aPedFat[nPos][2], AgruparItens(EE7->EE7_PEDIDO, WorkEE8->EE8_ORIGEM, {|| Empty(EE8_DTFIX)}, , EE8->(EE8_RV+EE8_ORIGV)))
               EndIf
            EndIf

            If (EE7->EE7_STATUS = ST_RV) .and. (EE8->EE8_SLDINI <> EE8->EE8_SLDATU)

               WkITVincRV->(dbSeek(EE8->EE8_RV))

               While WkITVincRV->(!Eof() .and. EE8_RV == EE8->EE8_RV)

                  If WkITVincRV->(!Empty(WK_FLAG) .and.; // EE8_ORIGV == EE8->EE8_ORIGEM .And.;
                     EE8_DTFIX == dDtFix .And. EE8_PRECO == nPreco )

                     EE8->(dbGoto(WkITVincRV->WK_RECNO))
                     If (nPos := AScan(aPedFat,{|x| x[1] == EE8->EE8_PEDIDO} )) = 0
                        AAdd(aPedFat,{EE8->EE8_PEDIDO,{}})
                        nPos := Len(aPedFat)
                     EndIf

                     AP105ClearFix()
                     Eval({|x, y| aSize(x, Len(x)+Len(y)),;
                                  aCopy(y, x,,, Len(x)-Len(y)+1 )}, aPedFat[nPos][2], AgruparItens(WkITVincRV->EE8_PEDIDO, EE8->EE8_ORIGEM, {|| Empty(EE8_DTFIX)}, , EE8->(EE8_RV+EE8_ORIGV)))
                  EndIf

                  WkITVincRV->(dbSkip())

               End

            EndIf

            // JPM - 26/11/05 - levantamento de informações para gravação do histórico do R.V.
            If lNewRv
               If Empty(aHeaderMsg)
                  aHeaderMsg := {"EE8_SEQUEN","EE8_SLDINI"}
               EndIf

               AAdd(aDetailMsg,Array(Len(aHeaderMsg)))
               For i := 1 To Len(aHeaderMsg)
                  aDetailMsg[Len(aDetailMsg)][i] := EE8->&(aHeaderMsg[i])
               Next
               aDetailMsg[Len(aDetailMsg)][2] := nQtd
               nPrcEEY := 0
               cMesAnoFix := ""
            EndIf

         EndIf

      WorkEE8->(dbSkip())

   End

      //ER - Ponto de Entrada
	  If EasyEntryPoint("EECAP105")
         ExecBlock("EECAP105",.F.,.F.,"ESTFIX")
      EndIf

      // ** Envia alterações nos itens para o faturamento
      EE7->(DbSetOrder(1))
      For i := 1 To Len(aPedFat)
         EE7->(DbSeek(xFilial()+aPedFat[i][1]))
         Ap105EnviaFat(aPedFat[i][2])
      Next

   End Transaction

End Sequence

RestOrd(aSaveOrd,.T.)

Return(lRet)

/*
Função      : AP105ClearFix
Objetivo    : Limpar os campos da Fixação de Preço.
Autor       : Alexsander Martins dos Santos
Data e Hora : 07/05/2004 às 13:41.
Observação  : Considera que o EE8 esteja posicionado.
*/

Function AP105ClearFix()

Local lClearMesDif := .T.


RecLock("EE8", .F.)

EE8->EE8_DTFIX  := Ctod("")
EE8->EE8_PRECO  := 0
EE8->EE8_STFIX  := ""
EE8->EE8_QTDLOT := 0
EE8->EE8_DTCOTA := Ctod("")
If Ap104VerPreco()
   EE8->EE8_PRECO2 := 0
   EE8->EE8_PRECO3 := 0
   EE8->EE8_PRECO4 := 0
   EE8->EE8_PRECO5 := 0
EndIf
/*
  ER - 07/02/2006 às 10:45 - Criação de Ponto de Entrada
  Verifica se o campos Mes de Fixação e Diferencial serão apagados
*/
If EasyEntryPoint("EECAP105")
   lClearMesDif := ExecBlock("EECAP105",.F.,.F.,"CLEARFIX")

   If ValType(lClearMesDif) <> "L"
      lClearMesDif := .T.
   EndIf

EndIf

If lClearMesDif
   EE8->EE8_MESFIX := ""
   EE8->EE8_DIFERE := 0
EndIf

EE8->(MsUnLock())

Return Nil


/*
Função      : E_PricePedRV
Objetivo    : Estorno de Fixação de Preço para os itens vinculados à R.V.
Retorno     : .T., Totalização do saldo na Work é igual ao saldo do item da WorkEE8.
              .F., Totalização do saldo na Work é diferente do saldo do item da WorkEE8.
Autor       : Alexsander Martins dos Santos
Data e Hora : 07/05/2004 às 14:30.
Observação  : Considera que se esteja posicionado o WorkEE8 com R.V.(Pedido especial)
*/

Static Function E_PricePedRV()

Local lRet         := .F.
Local aSaveOrd     := SaveOrd("EE8")
Local cQueryString := ""
Local cCMD         := ""
Local nTotQtdeFix  := 0
Local nPos         := 0
Local cRV          := WorkEE8->EE8_RV
Local cOrigem      := WorkEE8->EE8_ORIGEM
Local nEE8Recno    := EE8->(Recno())
Local cAliasOld    := Alias()
Private aCampos := {}

Begin Sequence

   WkItVincRv->(DbSetFilter({|| WkItVincRv->(EE8_RV+DToS(EE8_DTFIX)+Str(EE8_PRECO)) == cRV+DToS(dDtFix)+Str(nPreco) } ,"WkItVincRv->(EE8_RV+DToS(EE8_DTFIX)+Str(EE8_PRECO)) == '"+cRV+DToS(dDtFix)+Str(nPreco)+"'"))
   WkItVincRv->(DbGoTop())
   If WkITVincRV->(!EoF())
      Sum WkITVincRV->EE8_SLDATU To nTotQtdeFix
      Break
   EndIf

   WkItVincRv->(DbClearFilter())

   #IFDEF TOP

      cQueryString += "SELECT "
      cQueryString += "EE8_PEDIDO, "
      cQueryString += "EE8_SEQUEN, "
      cQueryString += "EE8_COD_I, "
      cQueryString += "EE8_SLDATU, "
      cQueryString += "EE8_SLDINI, "
      cQueryString += "EE8_RV, "
      cQueryString += "EE8_ORIGV, "
      cQueryString += "EE8_DESC, "
      cQueryString += "EE8_DTFIX, "
      cQueryString += "EE8_PRECO, "
      cQueryString += "EE8_UNIDAD, "
      cQueryString += "R_E_C_N_O_ AS WK_RECNO "
      cQueryString += "FROM "
      cQueryString += RetSQLName("EE8") + " EE8 "
      cQueryString += "WHERE "
      cQueryString += "D_E_L_E_T_ <> '*' AND "
      cQueryString += "EE8_FILIAL = '"+xFilial("EE8")+"' AND "
      cQueryString += "EE8_STATUS <> '"+ST_RV+"' AND "
      cQueryString += "EE8_RV = '"+cRV+"' AND "
      cQueryString += "EE8_DTFIX = '"+DToS(dDtFix)  +"' AND "
      cQueryString += "EE8_PRECO =  "+Str(nPreco)+"  AND "
      cQueryString += "EE8_DTFIX <> ''"

      cCMD := ChangeQuery(cQueryString)
      dbUseArea(.T., "TOPCONN", TCGENQRY(,,cCmd), "QRY", .F., .T.)
      TCSetField("QRY", "EE8_DTFIX",  "D", 8, 0)

      While QRY->(!Eof())

         WkITVincRV->(dbAppend())

         For nPos := 1 To WkITVincRV->(fCount())-2
            If Posicione("SX3", 2, WkITVincRV->(FieldName(nPos)), "X3_CONTEXT") <> "V"
               WkITVincRV->(FieldPut(nPos, QRY->(FieldGet(FieldPos(WkITVincRV->(FieldName(nPos)))))))
            EndIf
         Next

         WkITVincRV->EE8_VM_DES := EasyMSMM(QRY->EE8_DESC, AVSX3("EE8_VM_DES",AV_TAMANHO),,,LERMEMO,,,"EE8","EE8_DESC")

         nTotQtdeFix += QRY->EE8_SLDATU

         QRY->(dbSkip())

      End

      QRY->(dbCloseArea())

   #ELSE

      EE8->(dbSetOrder(1))
      EE8->(AVSeekLast(xFilial()+"*"))
      EE8->(dbSkip())

      While EE8->(!Eof() .and. EE8_FILIAL == xFilial("EE8"))

         If (EE8->EE8_RV == cRV) .and. !Empty(EE8->EE8_DTFIX) .And.;
            EE8->(DToS(EE8_DTFIX)+Str(EE8_PRECO)) == DToS(dDtFix)+Str(nPreco)

            WkITVincRV->(dbAppend())

            For nPos := 1 To WkITVincRV->(fCount())-2
               If Posicione("SX3", 2, WkITVincRV->(FieldName(nPos)), "X3_CONTEXT") <> "V"
                  WkITVincRV->(FieldPut(nPos, EE8->(FieldGet(FieldPos(WkITVincRV->(FieldName(nPos)))))))
               EndIf
            Next

            WkITVincRV->EE8_VM_DES := EasyMSMM(EE8->EE8_DESC, AVSX3("EE8_VM_DES",AV_TAMANHO),,,LERMEMO,,,"EE8","EE8_DESC")

            nTotQtdeFix += EE8->EE8_SLDATU

         EndIf

         EE8->(dbSkip())

      End

   #ENDIF

End Sequence

If(lRet := (nTotQtdeFix+WorkEE8->EE8_SLDATU) <= WorkEE8->EE8_SLDINI)

   //WkITVincRV->(dbSeek(cRV))
   WkItVincRv->(DbSetFilter({|| WkItVincRv->(EE8_RV+DToS(EE8_DTFIX)+Str(EE8_PRECO)) = cRV+DToS(dDtFix)+Str(nPreco) } ,"WkItVincRv->(EE8_RV+DToS(EE8_DTFIX)+Str(EE8_PRECO)) == '"+cRV+DToS(dDtFix)+Str(nPreco)+"'"))
   WkItVincRv->(DbGoTop())

   While WkITVincRV->(!Eof())
      WkITVincRV->WK_FLAG := cMarca
      WkITVincRV->(dbSkip())
   End

   WkItVincRv->(DbClearFilter())

EndIf

RestOrd(aSaveOrd)
If !Empty(cAliasOld)
   DbSelectArea(cAliasOld)
EndIf

Return(lRet)


/*
Função      : E_PriceT2
Objetivo    : Tela de seleção de itens vinculados a RV do WorkEE8 a serem estornados.
Retorno     : .T. indica que houve seleção de itens e foi precionado o botão Confirma, .F. foi cancelada.
Autor       : Alexsander Martins dos Santos
Data e Hora : 10/05/2004 às 11:10.
*/

Static Function E_PriceT2()

Local lRet          := .F.
Local aSelectFields := {}
Local nPos          := 0
Local nOpc2         := 0
Local bOk           := {|| nOpc2 := 1, If(E_PriceT2Vld(), oDlg:End(),)}
Local bCancel       := {|| nOpc2 := 0, oDlg:End()}
Local oDlg
Local cOrigem, dDtFix, nPreco,;
      bConv := {|| WkITVincRV->(If(EE8_UNIDAD <> cUniMedTon,;
                   AvTransUnidad(EE8_UNIDAD,cUniMedTon,EE8_COD_I,EE8_SLDINI),;
                   EE8_SLDINI)) }

Private nTotItSelect := 0

WorkEE8->(cOrigem := EE8_ORIGEM, dDtFix := EE8_DTFIX, nPreco := EE8_PRECO)
Begin Sequence

   WkItVincRv->(DbSetFilter({|| WkItVincRv->(EE8_RV+DToS(EE8_DTFIX)+Str(EE8_PRECO)) == cRV+DToS(dDtFix)+Str(nPreco) } ,"WkItVincRv->(EE8_RV+DToS(EE8_DTFIX)+Str(EE8_PRECO)) == '"+cRV+DToS(dDtFix)+Str(nPreco)+"'"))
   WkItVincRv->(DbGoTop())
   If WkITVincRV->(EoF())
      Break
   EndIf

   While WkITVincRV->(!EoF())
      If !Empty(WkITVincRV->WK_FLAG)
         nTotItSelect += Eval(bConv) //WkITVincRV->EE8_SLDINI
      EndIf
      WkITVincRV->(DbSkip())
   EndDo

   aAdd(aSelectFields, {"WK_FLAG", "XX", ""})

   For nPos := 1 To WkITVincRV->(fCount())-4
      If Posicione("SX3", 2, WorkEE8->(FieldName(nPos)), "X3_CONTEXT") <> "V"
         aAdd(aSelectFields, ColBrw(WkITVincRV->(FieldName(nPos)), "WkITVincRV"))
      Else
         aAdd(aSelectFields, {{|| MemoLine(WkITVincRV->EE8_VM_DES, 60, 1)},, AVSX3("EE8_VM_DES", AV_TITULO)})
      EndIf
   Next

   WkITVincRV->(dbGoTop())

   Define MSDialog oDlg Title STR0112 From 00, 00 To 471, 650 Of oMainWnd Pixel //"Itens vinculados a R.V."

      @ 015, 003 To 048, 324 Label STR0113 of oDlg Pixel //"Dados do Item"

      @ 028, 008 Say STR0114 Size 80, 07 Pixel Of oDlg //"R.V"
      @ 026,  40 MSGet WorkEE8->EE8_RV Picture AVSX3("EE8_RV", AV_PICTURE) Size 050, 07 Pixel Of oDlg When .F.

      @ 028, 230 Say STR0115   Size 80, 07 Pixel Of oDlg //"Qtde Fixada"
      @ 026, 260 MSGet WorkEE8->EE8_SLDINI Picture AVSX3("EE8_SLDINI", AV_PICTURE) Size 050, 07 Pixel Of oDlg When .F.

      @ 050, 003 To 233, 324 Label STR0116 of oDlg Pixel //"Itens vinculado à R.V."

      aPos := {57, 06, 230, 321}

      oMark       := MsSelect():New("WkITVincRV", "WK_FLAG",, aSelectFields, @lInverte, @cMarca, aPos)
	  oMark:bAval := {|| WkITVincRV->(WK_FLAG := If(Empty(WK_FLAG), Eval({|| nTotItSelect += Eval(bConv), cMarca}), Eval({|| nTotItSelect -= Eval(bConv), ""})))}

   Activate MSDialog oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) Centered

   If nOpc2 = 1
      lRet := nTotItSelect > 0
   EndIf

   WkITVincRV->(dbClearFilter())

End Sequence

Return(lRet)


/*
Função      : E_PriceT2Vld
Objetivo    : Validação dos dados da E_PRICET2.
Retorno     : .T. indica que os dados estão ok e .F. caso contrário.
Autor       : Alexsander Martins dos Santos
Data e Hora : 10/05/2004 às 18:04.
*/

Static Function E_PriceT2Vld()

Local lRet := .F.

Begin Sequence

   If nTotItSelect <= 0
      MsgStop(STR0117, STR0022) //"Deve ser selecionado no minimo um item para confirmação do estorno." //"Atenção"
      Break
   EndIf

   If (nTotItSelect+WorkEE8->EE8_SLDATU) <> WorkEE8->EE8_SLDINI
      MsgStop(STR0118, STR0022) //"A Qtde total dos itens selecionados é diferente à Qtde fixada."###"Atenção"
      Break
   EndIf

   lRet := .T.

End Sequence

Return(lRet)


/*
Função      : E_PriceT2Vld
Objetivo    : Validação dos dados da E_PRICET2.
Retorno     : .T. indica que os dados estão ok e .F. caso contrário.
Autor       : Alexsander Martins dos Santos
Data e Hora : 10/05/2004 às 18:04.
*/



/*
Funcao      : AP105CallPrecoI(cFil, lMsg)
Parametros  : cFil - Filial a ser atualizada.
              lMsg - .T. = Apresenta mensagem.
                     .F. = Não apresenta mensagem.
Retorno     : .t.
Objetivos   : Preparar Variáveis de Memória e WorkIt para chamada da função ap100PrecoI()
              Atualizar processo com os valores calculados.
Autor       : Jeferson Barros Jr.
Data/Hora   : 12/12/2003 13:58.
Revisao     :
Obs.        : Considera que o EE7 Esteja Posicionado.
*/
*-----------------------------*
Function AP105CallPrecoI(cFil, lMsg)
*-----------------------------*
Local lRet:=.t., aOrd:=SaveOrd({"EE7","EE8","EEB"})
Local lBuildWork := .f., cNomAux    // , aSemSx3:={}
Local lBuildWkAg := .f., cNomArq2  // By JPP - 21/06/2005 - 09:10
Local z
Default cFil = xFilial("EE7") // Considera que o EE8 sempre terá a mesma filial do EE7.
Default lMsg := .T.

/*
AMS - 14/09/2005. Declaração das variaveis lIntegra e lCommodity.
*/
If Type("lIntegra") = "U"
   Private lIntegra := IsIntFat()
EndIf

Private lCommodity := .F.
Private  aSemSx3:={} // By JPP - 14/11/2006 - 16:00 - Esta variável passou a ser do tipo private para customização.

lCommodity := EECFlags("COMMODITY")

Begin Sequence

   // ** Caso a work não exista cria com base no EE8 e no SX3 (Campos Virtuais).
   If Select("WorkIt") = 0
      lBuildWork := .t.

      aCampos := Array(EE8->(FCount()))

      aSemSX3 := {{"EE8_RECNO","N",7,0}}

      // ** JPM - 14/04/05 - Inclusão de novos campos nos itens.
      If EE8->(FieldPos("EE8_PRCUN"))  > 0 .And. EE8->(FieldPos("EE8_VLFRET")) > 0 .And. ;
         EE8->(FieldPos("EE8_VLSEGU")) > 0 .And. EE8->(FieldPos("EE8_VLOUTR")) > 0 .And. ;
         EE8->(FieldPos("EE8_VLDESC")) > 0

         aAdd(aSemSX3,{"EE8_PRCUN" ,AVSX3("EE8_PRCUN" ,AV_TIPO),AVSX3("EE8_PRCUN" ,AV_TAMANHO),AVSX3("EE8_PRCUN" ,AV_DECIMAL)})
         aAdd(aSemSX3,{"EE8_VLFRET",AVSX3("EE8_VLFRET",AV_TIPO),AVSX3("EE8_VLFRET",AV_TAMANHO),AVSX3("EE8_VLFRET",AV_DECIMAL)})
         aAdd(aSemSX3,{"EE8_VLSEGU",AVSX3("EE8_VLSEGU",AV_TIPO),AVSX3("EE8_VLSEGU",AV_TAMANHO),AVSX3("EE8_VLSEGU",AV_DECIMAL)})
         aAdd(aSemSX3,{"EE8_VLOUTR",AVSX3("EE8_VLOUTR",AV_TIPO),AVSX3("EE8_VLOUTR",AV_TAMANHO),AVSX3("EE8_VLOUTR",AV_DECIMAL)})
         aAdd(aSemSX3,{"EE8_VLDESC",AVSX3("EE8_VLDESC",AV_TIPO),AVSX3("EE8_VLDESC",AV_TAMANHO),AVSX3("EE8_VLDESC",AV_DECIMAL)})
      Else
         aAdd(aSemSX3,{"EE8_PRCUN" ,AVSX3("EE8_PRECO" ,AV_TIPO),AVSX3("EE8_PRECO" ,AV_TAMANHO),AVSX3("EE8_PRECO" ,AV_DECIMAL)})
         aAdd(aSemSX3,{"EE8_VLFRET",AVSX3("EE8_PRCTOT",AV_TIPO),AVSX3("EE8_PRCTOT",AV_TAMANHO),AVSX3("EE8_PRCTOT",AV_DECIMAL)})
         aAdd(aSemSX3,{"EE8_VLSEGU",AVSX3("EE8_PRCTOT",AV_TIPO),AVSX3("EE8_PRCTOT",AV_TAMANHO),AVSX3("EE8_PRCTOT",AV_DECIMAL)})
         aAdd(aSemSX3,{"EE8_VLOUTR",AVSX3("EE8_PRCTOT",AV_TIPO),AVSX3("EE8_PRCTOT",AV_TAMANHO),AVSX3("EE8_PRCTOT",AV_DECIMAL)})
         aAdd(aSemSX3,{"EE8_VLDESC",AVSX3("EE8_PRCTOT",AV_TIPO),AVSX3("EE8_PRCTOT",AV_TAMANHO),AVSX3("EE8_PRCTOT",AV_DECIMAL)})
      Endif
      // **

      /*
      AMS - 14/09/2005. Adicionado novos campos no array aSemSX3, utilizando as mesmas consistências
                        da função AP102CRIAWORK.
                        Obs: Esta alteração deve ser revisada, com a intenção de utilizar uma unica
                        forma de preparação de ambiente.
      */
      IF lIntegra .And. aScan(aSemSX3,{|x| AllTrim(x[1]) == "EE8_FATIT"}) == 0
         aAdd(aSemSX3,{"EE8_FATIT",AVSX3("EE8_FATIT",AV_TIPO),AVSX3("EE8_FATIT",AV_TAMANHO),AVSX3("EE8_FATIT",AV_DECIMAL)})
         aAdd(aSemSX3,{"EE8_CF"   ,AVSX3("EE8_CF"   ,AV_TIPO),AVSX3("EE8_CF"   ,AV_TAMANHO),AVSX3("EE8_CF"   ,AV_DECIMAL)})
         aAdd(aSemSX3,{"EE8_TES"  ,AVSX3("EE8_TES"  ,AV_TIPO),AVSX3("EE8_TES"  ,AV_TAMANHO),AVSX3("EE8_TES"  ,AV_DECIMAL)})
      Endif

      If lCommodity
         If aScan(aSemSX3,{|x| AllTrim(x[1]) == "EE8_STFIX"}) == 0
            aAdd(aSemSX3,{"EE8_STFIX",AVSX3("EE8_STFIX",AV_TIPO),AVSX3("EE8_STFIX",AV_TAMANHO),AVSX3("EE8_STFIX",AV_DECIMAL)})
         EndIf

         If aScan(aSemSX3,{|x| AllTrim(x[1]) == "EE8_ORIGEM"}) == 0
            aAdd(aSemSX3,{"EE8_ORIGEM",AVSX3("EE8_ORIGEM",AV_TIPO),AVSX3("EE8_ORIGEM",AV_TAMANHO),AVSX3("EE8_ORIGEM",AV_DECIMAL)})
         EndIf
      EndIf

      If aScan(aSemSX3,{|x| AllTrim(x[1]) == "WP_EE9REG"}) == 0 //Irá armazenar o nº do registro do EE9 para atualizar o EE9_SLDINI.
         aAdd(aSemSX3,{"WP_EE9REG", "N", 12, 0})
      EndIf

      If aScan(aSemSX3,{|x| AllTrim(x[1]) == "WP_EE9SLD"}) == 0 //Irá armazenar a qtde.(-/+) para atualizar o EE9_SLDINI.
         aAdd(aSemSX3,{"WP_EE9SLD", AVSX3("EE9_SLDINI", AV_TIPO), AVSX3("EE9_SLDINI", AV_TAMANHO), AVSX3("EE9_SLDINI", AV_DECIMAL)})
      EndIf

      If aScan(aSemSX3,{|x| AllTrim(x[1]) == "WP_EE9PLQ"}) == 0 //Irá armazenar o peso liquido (-/+) para atualizar o EE9_PSLQTO.
         aAdd(aSemSX3,{"WP_EE9PLQ", AVSX3("EE9_PSLQTO", AV_TIPO), AVSX3("EE9_PSLQTO", AV_TAMANHO), AVSX3("EE9_PSLQTO", AV_DECIMAL)})
      EndIf

      If aScan(aSemSX3,{|x| AllTrim(x[1]) == "WP_EE9PBR"}) == 0 //Irá armazenar o peso bruto (-/+) para atualizar o EE9_PSBRTO.
         aAdd(aSemSX3,{"WP_EE9PBR", AVSX3("EE9_PSBRTO", AV_TIPO), AVSX3("EE9_PSBRTO", AV_TAMANHO), AVSX3("EE9_PSBRTO", AV_DECIMAL)})
      EndIf
      /*
      AMS - 14/09/2005. Fim da alteração para adição de campos
      */

      If EECFlags("INTERMED") // EECFlags("CONTROL_QTD") // By JPP - 21/09/2006 - 09:00 - A rotina controle de quantidade passou a ser padrão para Off-Shore
         AddNaoUsado(aSemSx3,"EE8_ORIGV" )
      EndIf

      If EasyEntryPoint("EECAP105") // By JPP - 14/11/2006 - 16:00 - Inclusão do ponto de Entrada.
         ExecBlock("EECAP105",.F.,.F.,"PE_ANTES_CRIAR_WORKIT")
      EndIf

      cNomAux:=E_CriaTrab("EE8",aSemSX3,"WorkIt")

      If lMsg
         IndRegua("WorkIt",cNomAux+TEOrdBagExt(),"EE8_SEQUEN")
      Else
         INDEX ON EE8_SEQUEN TO (cNomAux+TEOrdBagExt())
      EndIf

   EndIf

   // By JPP - 21/06/2005 - 09:10
   // *** Gera Work de Agentes ...
   If Select("WorkAg") = 0
      lBuildWkAg := .t.

      aSemSX3  := { {"WK_RECNO", "N", 7, 0},{"EEB_OCORRE","C",1,0} }

      AddNaoUsado(aSemSX3,"EEB_TOTCOM")
      AddNaoUsado(aSemSX3,"EEB_FOBAGE")

      aCampos  := Array(EEB->(FCount()))

      cNomArq2 := E_CriaTrab("EEB",aSemSX3,"WorkAg")
      If EECFlags("COMISSAO")
         If lMsg
            IndRegua("WorkAg",cNomArq2+TEOrdBagExt(),"EEB_CODAGE+EEB_TIPOAG+EEB_TIPCOM","AllwayTrue()",;
                     "AllwaysTrue()",STR0012) //"Processando Arquivo Temporário ..."
         Else
            WorkAg->(dbCreateIndex(cNomArq2+TEOrdBagExt(), "EEB_CODAGE+EEB_TIPOAG+EEB_TIPCOM", {|| EEB_CODAGE+EEB_TIPOAG+EEB_TIPCOM}))
         EndIf
      Else
         If lMsg
            IndRegua("WorkAg",cNomArq2+TEOrdBagExt(),"EEB_CODAGE+EEB_TIPOAG","AllwayTrue()",;
                     "AllwaysTrue()",STR0012) //"Processando Arquivo Temporário ..."
         Else
            WorkAg->(dbCreateIndex(cNomArq2+TEOrdBagExt(), "EEB_CODAGE+EEB_TIPOAG", {|| EEB_CODAGE+EEB_TIPOAG}))
         EndIf
      EndIf

      EEB->(DbSetOrder(1))
      EEB->(DbSeek(cFil+Avkey(EE7->EE7_PEDIDO,"EE7_PEDIDO"+OC_PE)))

      Do While EEB->(!Eof()) .And. EEB->EEB_FILIAL == cFil .And.;
                                   EEB->EEB_PEDIDO == EE7->EE7_PEDIDO .And.;
                                   EEB->EEB_OCORRE == OC_PE
         WorkAg->(DbAppend())
         AVReplace("EEB","WorkAg")
         EEB->(DbSkip())
      EndDo
   EndIf


   Inclui := .t.

   // ** Carrega as variáveis de memória.
   For z := 1 TO EE7->(FCount())
      M->&(EE7->(FieldName(z))) := EE7->(FieldGet(z))
   Next

   // ** Carrega a WorkAg.
   WorkAg->(AvZap())
   EEB->(DbSetOrder(1))
   EEB->(DbSeek(cFil+Avkey(EE7->EE7_PEDIDO,"EE7_PEDIDO"+OC_PE)))
   Do While EEB->(!Eof()) .And. EEB->EEB_FILIAL == cFil .And.;
                                EEB->EEB_PEDIDO == EE7->EE7_PEDIDO .And.;
                                EEB->EEB_OCORRE == OC_PE
      WorkAg->(DbAppend())
      AVReplace("EEB","WorkAg")
      EEB->(DbSkip())
   EndDo

   // ** Carrega a WorkIp.
   WorkIt->(AvZap())

   EE8->(DbSetOrder(1))
   EE8->(DbSeek(cFil+M->EE7_PEDIDO))

   Do While EE8->(!Eof()) .And. EE8->EE8_FILIAL == cFil .And.;
                                EE8->EE8_PEDIDO == M->EE7_PEDIDO
      WorkIt->(DbAppend())
      AVReplace("EE8","WorkIt")
      EE8->(DbSkip())
   EndDo

   ap100PrecoI(, .F.) // Recalcula os totais do processo.

   // ** Atualiza a capa.
   If EE7->(RecLock("EE7",.f.))
      AvReplace("M","EE7")
      EE7->EE7_FILIAL := cFil
      EE7->(MsUnLock())
   EndIf

   // ** Atualiza os itens.
   WorkIt->(DbGoTop())
   Do While WorkIt->(!Eof())
      If EE8->(DbSeek(cFil+WorkIt->EE8_PEDIDO+WorkIt->EE8_SEQUEN))
         If EE8->(RecLock("EE8",.f.))
            AvReplace("WorkIt","EE8")
            EE8->EE8_FILIAL := cFil
            EE8->(MsUnLock())
         EndIf
      EndIf
      WorkIt->(DbSkip())
   EndDo

   If lBuildWork
      WorkIt->(E_EraseArq(cNomAux))
   EndIf
   If lBuildWkAg    // By JPP - 21/06/2005 - 09:45
      WorkAg->(E_EraseArq(cNomArq2))
   EndIf
End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : AP105AtuFilBr().
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Atualizar o processo na filial Brasil a partir da filial de OffShore.
Autor       : Jeferson Barros Jr.
Data/Hora   : 23/03/2004 14:48.
Revisao     :
Obs.        :
*/
*----------------------*
Function AP105AtuFilBr()
*----------------------*
Local cRet:="1", lAtuFilBr:=.f., aOrd:=SaveOrd({"EE7"})
Local nRecEE7:=EE7->(RecNo())

Begin Sequence

   If lIntermed // Verifica se a rotina de off-shore está ativa.
      If xFilial("EE7") <> cFilBr // Verifica se a filial logada é a Fil. Brasil.
         cRet:="2"
         Break
      EndIf
   EndIf

   EE7->(DbSetOrder(1))
   If EE7->(DbSeek(cFilEx+M->EE7_PEDIDO))
      lAtuFilBr := MsgYesNo(STR0136+AllTrim(AvSx3("EE7_PEDIDO",AV_TITULO))+STR0089+Replic(ENTER,2)+; //" já existe na filial de Off-shore." //"Este "
                            STR0090,STR0022) //"Deseja carregar as informações ?"###"Atenção"
   EndIf

   If lAtuFilBr
      // ** Verifica se o processo já possui itens lançados.
      If !(IsVazio("WorkIt"))
         If !MsgYesNo(STR0091,STR0022) //"Os itens já lançados serão apagados. Confirma a cópia dos dados?"###"Atenção"
            Break
         EndIf
      EndIf

      MsAguarde({|| MsProcTxt(STR0092+AllTrim(Transf(EE7->EE7_PEDIDO,AVSX3("EE7_PEDIDO",AV_PICTURE)))),; //"Copiando informações do processo: "
                    AP105Copy()}, STR0093) //"Processo de Exportação"
   EndIf

End Sequence

EE7->(DbGoTo(nRecEE7)) // Posiciona na filial inicial.

RestOrd(aOrd)

Return cRet

/*
Funcao      : AP105Copy().
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Copiar as informações de capa e item do processo de off-shore.
Autor       : Jeferson Barros Jr.
Data/Hora   : 24/03/2004 08:19.
Revisao     :
Obs.        : Considera já posicionado no processo de origem dos dados.
              Work dos itens deve estar criada.
*/
*------------------*
Function AP105Copy()
*------------------*
Local lRet:=.t., nRec:=0, j:=0, l:=0, i:=0
Local aOrd:=SaveOrd({"EE8","SY6","SYQ"})

Begin Sequence

   // ** Carrega as informações da capa...
   For j := 1 TO EE7->(FCount())
      M->&(EE7->(FieldName(j))) := EE7->(FieldGet(j))
   Next

   M->EE7_FILIAL := cFilBr
   M->EE7_OBS    := EE7->(MSMM(EE7_CODMEM,TAMSX3("EE7_OBS")[1],,,LERMEMO))
   M->EE7_MARCAC := EE7->(MSMM(EE7_CODMAR,TAMSX3("EE7_MARCAC")[1],,,LERMEMO))
   M->EE7_OBSPED := EE7->(MSMM(EE7_CODOBP,TAMSX3("EE7_OBSPED")[1],,,LERMEMO))
   M->EE7_GENERI := EE7->(MSMM(EE7_DSCGEN,TAMSX3("EE7_GENERI")[1],,,LERMEMO))
   M->EE7_CLIENT := EE7->EE7_IMPORT
   M->EE7_CLLOJA := EE7->EE7_IMLOJA
   M->EE7_CLIEDE := Posicione("SA1",1,xFilial("SA1")+EE7->EE7_IMPORT+EE7->EE7_IMLOJA,"A1_NOME")
   M->EE7_EXPORT := EE7->EE7_FORN
   M->EE7_EXLOJA := EE7->EE7_FOLOJA
   M->EE7_EXPODE := Posicione("SA2",1,xFilial("SA1")+EE7->EE7_FORN+EE7->EE7_FOLOJA,"A2_NOME")
   M->EE7_IMPORT := EE7->EE7_FORN
   M->EE7_IMLOJA := EE7->EE7_FOLOJA
   M->EE7_IMPODE := Posicione("SA1",1,xFilial("SA1")+EE7->EE7_FORN+EE7->EE7_FOLOJA,"A1_NOME")
   M->EE7_ENDIMP := EECMEND("SA1",1,EE7->EE7_FORN+EE7->EE7_FOLOJA,.T.,,1)
   M->EE7_END2IM := EECMEND("SA1",1,EE7->EE7_FORN+EE7->EE7_FOLOJA,.T.,,2)

   SY6->(DbSetOrder(1))
   If SY6->(DbSeek(xFilial("SY6")+EE7->EE7_CONDPA+Str(EE7_DIASPA,3)))
      M->EE7_DESCPA := MSMM(SY6->Y6_DESC_P,60)
   EndIf

   SYQ->(DbSetOrder(1))
   If SYQ->(DbSeek(xFilial("SYQ")+EE7->EE7_VIA))
      M->EE7_VIA_DE:= SYQ->YQ_DESCR
   EndIf

   M->EE7_INTERM := "1"
   M->EE7_PERC   := 0
   M->EE7_FORN   := ""
   M->EE7_FOLOJA := ""
   M->EE7_FORNDE := ""

   M->EE7_TOTPED := 0

   // ** Grava os itens ...
   WorkIt->(AvZap())

   EE8->(DbSetOrder(1))
   EE8->(DbSeek(cFilEx+M->EE7_PEDIDO))

   While EE8->(!Eof()) .AND. EE8->EE8_FILIAL == cFilEx .And. EE8->EE8_PEDIDO == M->EE7_PEDIDO

      For l := 1 TO EE8->(FCount())
         M->&(EE8->(FIELDNAME(l))) := EE8->(FieldGet(l))
      Next

      For i:=1 To Len(aMemoItem)
         If EE8->(FieldPos(aMemoItem[i][1])) > 0
            M->&(aMemoItem[i][2]) := EasyMSMM(EE8->&(aMemoItem[i][1]),TAMSX3(aMemoItem[i][2])[1],,,LERMEMO,,,"EE8",aMemoItem[i][1])
         EndIf
      Next

      M->EE8_PRECO  := 0
      M->EE8_PRCTOT := 0

      WorkIt->(DbAppend())
      AvReplace("M","WorkIt")

      For i:=1 To Len(aMemoItem)
         If WorkIt->(FieldPos(aMemoItem[i][2])) > 0
            WorkIt->&(aMemoItem[i][2]) := EasyMSMM(M->&(aMemoItem[i][1]),TAMSX3(aMemoItem[i][2])[1],,,LERMEMO,,,"EE8",aMemoItem[i][1])
         EndIf
      Next

      EE8->(DbSkip())
   EndDo

   WorkIt->(DbGoTop())
   oMsSelect:oBrowse:Refresh()

End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : AP105VldOffShore().
Parametros  : nOpc - Opção da manutenção. (INCLUIR/ALTERAR/EXCLUIR)
              lIsFilBr - .t. - Filial Brasil.
                         .f. - Filial Off-Shore.
Retorno     : .t./.f.
Objetivos   : Validar informações da filial brasil contra a filial de off-shore.
Autor       : Jeferson Barros Jr.
Data/Hora   : 24/03/2004 18:45.
Revisao     : Função foi movida para o programa eecap104.prw para sanar o problemas de novas
              defines no eecap105.ch.
Obs.        :
*/
*--------------------------------------*
Function AP105VldOffShore(nOpc,lIsFilBr)
*--------------------------------------*
Local lRet:=.t.
   lRet := AP104VldOffShore(nOpc,lIsFilBr)
Return lRet

/*
Movido funções de Vinculação/Estorno de R.V. para o programa EECAP104.PRW.
Autor       : Alexsander Martins dos Santos
Data e Hora : 18/05/2004 as 14:35.
*/


/*
Função      : AgruparItens
Objetivo    : Agrupar 2 itens da mesma origem de um pedido, através da condição.
Parametros  : cPedido   -> Nº do Pedido.
            : cOrigem   -> Origem do Item (Item Pai).
            : bCondicao -> Code Block, com a condição para agrupar.
              lFixacao  -> Se .t., agrupar quebras por fixação, senão por Vinculação de R.V. - JPM
Retorno     : .T. -> Itens agrupados.
            : .F. -> Itens não foram agrupados.
Autor       : Alexsander Martins dos Santos
Data e Hora : 11/05/2004 às 11:07.
Revisão     : João Pedro Macimiano Trabbold - 27/09/05
*/
*--------------------------------------------------------------------*
Function AgruparItens(cPedido, cOrigem, bCondicao, lFixacao, cRvOrigv)
*--------------------------------------------------------------------*
Local aRet      := {}
Local aSaveOrd  := SaveOrd({"EE7","EE8"})
Local nEE8Recno := EE8->(Recno())
Local aItens    := {}
Local i, j, k, aCpos := {"EE8_PSBRTO","EE8_PSLQTO","EE8_QTDEM1","EE8_SLDINI","EE8_SLDATU"}
Local cCampo    := "",;
      lOic := EECFlags("CAFE"),;
      lInv := EECFlags("INVOICE"),;
      aEE9 := {}, aEY2, aEXR, aAux, aSeqs, aRec,;
      cSeq, cPreemb, nTot, nPos


Default lFixacao := .t.
Default cRvOrigv := ""

Begin Sequence

   cCampo := If(lFixacao,"EE8_ORIGEM","EE8_ORIGV")

   EE8->(dbSetOrder(1))
   EE8->(dbSeek(xFilial("EE8")+cPedido))

   While EE8->(!Eof() .and. EE8_FILIAL == xFilial() .and. EE8_PEDIDO == cPedido)

      If EE8->&(cCampo) == cOrigem .and. EE8->(Eval(bCondicao)) .And. If(lFixacao .And. !Empty(cRvOrigv),cRvOrigv == EE8->(EE8_RV+EE8_ORIGV),.t.)

         /*
         aAdd( aItens, { EE8->(Recno())  ,;
                         EE8->EE8_SEQUEN ,;
                         EE8->EE8_PSBRTO ,;
                         EE8->EE8_PSLQTO ,;
                         EE8->EE8_QTDEM1 ,;
                         EE8->EE8_SLDINI ,;
                         EE8->EE8_SLDATU } )
         */

         AAdd(aItens, {EE8->(Recno()), EE8->EE8_SEQUEN } )

         For j := 1 to Len(aCpos)
            AAdd(aItens[Len(aItens)], EE8->&(aCpos[j]) )
         Next

      EndIf

      EE8->(dbSkip())

   End

// If (lRet := Len(aItens) = 2) - JPM - 27/09/05 - totalizar todos os itens possíveis, não apenas 2.
   If Len(aItens) >= 2

      aSort(aItens,,, { |x, y| x[2] < y[2] })

      EE8->(dbGoto(aItens[1][1]))
      cSeq := aItens[1][2]

      RecLock("EE8", .F.)

      // ** JPM - 27/09/05 - Totalizar todos os itens possíveis.
      For j := 1 to Len(aCpos) //Zera os campos que serão aglutinados
          EE8->&(aCpos[j]) := 0
      Next

      For i := 1 to Len(aItens)
         For j := 1 to Len(aCpos) // totaliza os campos definidos em aCpos
            EE8->&(aCpos[j]) += aItens[i][j + 2]
         Next
      Next

      EE8->(MsUnLock())

      For i := 2 to Len(aItens)
         EE8->(dbGoto(aItens[i][1]))
         RecLock("EE8", .F.)
         AAdd(aRet,EE8->(RecNo()))
         EE8->(dbDelete())
         EE8->(MSUnLock())
      Next

      EE8->(dbGoto(aItens[1][1]))

   Else
      Break
   EndIf

   // ** Faz o levantamento dos itens do Embarque possuem as sequências modificadas, e aglutina itens se for necessário.
   EE9->(DbSetOrder(1))
   For i := 1 To Len(aItens)
      EE9->(DbSeek(xFilial()+EE8->EE8_PEDIDO+aItens[i][2]))
      While EE9->(!EoF() .And. EE9->(EE9_FILIAL+EE9_PEDIDO+EE9_SEQUEN) == xFilial()+EE8->EE8_PEDIDO+aItens[i][2])
         If (nPos := AScan(aEE9,{|x| x[1] == EE9->EE9_PREEMB })) = 0
            AAdd(aEE9,{EE9->EE9_PREEMB,{},{},.F.,{}})
            nPos := Len(aEE9)
         EndIf
         AAdd(aEE9[nPos][2],EE9->EE9_SEQUEN)
         AAdd(aEE9[nPos][3],EE9->(RecNo()))
         EE9->(DbSkip())
      EndDo
   Next

   For i := 1 To Len(aEE9)
      cPreemb := aEE9[i][1]
      aAux    := aEE9[i][2]
      aRec    := aEE9[i][3]
      EE9->(DbGoTo(aRec[1]))
      If Len(aAux) = 1      // se não vai aglutinar
         If aAux[1] == cSeq // e a sequência está igual
            Loop            // então desconsidera
         EndIf
         EE9->(RecLock("EE9",.F.),;
               EE9_SEQUEN := cSeq,;
               MsUnlock())
         aSeqs := {{aAux[1],EE9->EE9_PEDIDO}} // se a seq está diferente, então deve ser atualizada.
      Else
         aItens := {0,0,0,0,0,0,0,0} // array para totalizar valores
         aSeqs  := {}                // sequências que serão modificadas
         AAdd(aEE9[i][5],EE9->EE9_SEQEMB)
         For j := 2 To Len(aAux)
            EE9->(DbGoTo(aRec[j])) // totaliza itens
            aItens[1] += EE9->EE9_SLDINI
            aItens[2] += EE9->EE9_QTDEM1
            aItens[3] += EE9->EE9_PSLQTO
            aItens[4] += EE9->EE9_PSBRTO
            aItens[5] += EE9->EE9_QT_AC
            aItens[6] += EE9->EE9_VL_AC
            aItens[7] += EE9->EE9_SALISE
            If EE9->(FieldPos("EE9_VLPVIN")) > 0  // By JPP - 14/11/2006 - 13:00
               aItens[8] += EE9->EE9_VLPVIN
            EndIf

            AAdd(aEE9[i][5],EE9->EE9_SEQEMB)
            EE9->(RecLock("EE9",.F.),DbDelete(),MsUnlock())
            AAdd(aSeqs,{aAux[j],EE9->EE9_PEDIDO})
         Next
         EE9->(DbGoTo(aRec[1]),RecLock("EE9",.F.))
         EE9->EE9_SLDINI += aItens[1] // aglutina itens
         EE9->EE9_QTDEM1 += aItens[2]
         EE9->EE9_PSLQTO += aItens[3]
         EE9->EE9_PSBRTO += aItens[4]
         EE9->EE9_QT_AC  += aItens[5]
         EE9->EE9_VL_AC  += aItens[6]
         EE9->EE9_SALISE += aItens[7]
         If EE9->(FieldPos("EE9_VLPVIN")) > 0  // By JPP - 14/11/2006 - 13:00
            EE9->EE9_VLPVIN += aItens[8]
         EndIf
         If !lFixacao
            EE9->EE9_RV   := ""
            EE9->EE9_DTRV := AvCToD("")
         Endif
         EE9->(MsUnLock())
         aEE9[i][4] := .T.
      EndIf
      EE7->(DbSetOrder(1))
      For j := 1 To Len(aSeqs)
         EE7->(DbSeek(xFilial()+aSeqs[j][2]))
         Ap104AtuSequen(aSeqs[j][1],cSeq,cPreemb,,.F.) // Atualiza as sequências no embarque.
      Next
   Next

   EEC->(DbSetOrder(1))
   If lOic
      EY2->(DbSetOrder(1))
   EndIf
   If lInv
      EXR->(DbSetOrder(1))
   EndIf

   For i := 1 To Len(aEE9)
      If aEE9[i][4]
         EEC->(DbSeek(xFilial()+aEE9[i][1]))
         If lInv .Or. lOic
            aEY2 := {}
            aEXR := {}
            aAux := aEE9[i][5]
            cSeq := aAux[1]

            For j := 1 To Len(aAux)
               cSeqEmb := aAux[j]
               cPreemb := EEC->EEC_PREEMB

               If lOic // faz o levantamento dos itens de OICs para a Sequencia cSeqEmb e para o embarque cPreemb
                  EY2->(DbSeek(xFilial()+cPreemb))
                  While EY2->(!EoF() .And. EY2_FILIAL+EY2_PREEMB == xFilial()+cPreemb)
                     If EY2->EY2_SEQEMB == cSeqEmb
                        If (nPos := AScan(aEY2,{|x| x[1] == EY2->EY2_OIC})) = 0
                           AAdd(aEY2,{EY2->EY2_OIC,{},{}})
                           nPos := Len(aEY2)
                        EndIf
                        AAdd(aEY2[nPos][2],cSeqEmb)
                        AAdd(aEY2[nPos][3],EY2->(RecNo()))
                     EndIf
                     EY2->(DbSkip())
                  EndDo

               EndIf

               If lInv // faz o levantamento dos itens de invoice para a Sequencia cSeqEmb e para o embarque cPreemb
                  EXR->(DbSeek(xFilial()+cPreemb))
                  While EXR->(!EoF() .And. EXR_FILIAL+EXR_PREEMB == xFilial()+cPreemb)
                     If EXR->EXR_SEQEMB == cSeqEmb
                        If (nPos := AScan(aEXR,{|x| x[1] == EXR->EXR_NRINVO})) = 0
                           AAdd(aEXR,{EXR->EXR_NRINVO,{},{}})
                           nPos := Len(aEXR)
                        EndIf
                        AAdd(aEXR[nPos][2],cSeqEmb)
                        AAdd(aEXR[nPos][3],EXR->(RecNo()))
                     EndIf
                     EXR->(DbSkip())
                  EndDo

               EndIf
            Next

            For k := 1 To Len(aEY2)
               aAux := aEY2[k][2]
               aRec := aEY2[k][3]
               If Len(aAux) = 1      // se não vai aglutinar
                  If aAux[1] == cSeq // e a sequência está igual
                     Loop            // então desconsidera
                  EndIf
                  EY2->(RecLock("EY2",.F.),;
                        EY2_SEQEMB := cSeq,;
                        MsUnlock())
               Else
                  nTot := 0
                  For j := 2 To Len(aAux)
                     EY2->(DbGoTo(aRec[j]))
                     nTot += EY2->EY2_QTDE // totaliza quantidade
                     EY2->(RecLock("EY2",.F.),DbDelete(),MsUnlock())
                  Next
                  EY2->(DbGoTo(aRec[1]),RecLock("EY2",.F.))
                  EY2->EY2_QTDE += nTot // aglutina o item
                  EY2->(MsUnLock())
               EndIf
            Next

            For k := 1 To Len(aEXR)
               aAux := aEXR[k][2]
               aRec := aEXR[k][3]
               If Len(aAux) = 1      // se não vai aglutinar
                  If aAux[1] == cSeq // e a sequência está igual
                     Loop            // então desconsidera
                  EndIf
                  EXR->(RecLock("EXR",.F.),;
                        EXR_SEQEMB := cSeq,;
                        MsUnlock())
               Else
                  aItens := {0,0,0,0,0,0,0,0,0}
                  For j := 2 To Len(aAux)
                     EXR->(DbGoTo(aRec[j]))
                     aItens[1] += EXR->EXR_SLDINI
                     aItens[2] += EXR->EXR_PSBRTO
                     aItens[3] += EXR->EXR_PSLQTO
                     aItens[4] += EXR->EXR_VLFRET
                     aItens[5] += EXR->EXR_VLSEGU
                     aItens[6] += EXR->EXR_VLOUTR
                     aItens[7] += EXR->EXR_VLDESC
                     aItens[8] += EXR->EXR_PRCTOT
                     aItens[9] += EXR->EXR_PRCINC
                     EXR->(RecLock("EXR",.F.),DbDelete(),MsUnlock())
                  Next
                  EXR->(DbGoTo(aRec[1]),RecLock("EXR",.F.))

                  EXR->EXR_SLDINI += aItens[1]
                  EXR->EXR_PSBRTO += aItens[2]
                  EXR->EXR_PSLQTO += aItens[3]
                  EXR->EXR_VLFRET += aItens[4]
                  EXR->EXR_VLSEGU += aItens[5]
                  EXR->EXR_VLOUTR += aItens[6]
                  EXR->EXR_VLDESC += aItens[7]
                  EXR->EXR_PRCTOT += aItens[8]
                  EXR->EXR_PRCINC += aItens[9]

                  EXR->(MsUnLock())
               EndIf
            Next

         EndIf
         Ae105CallPrecoI()
      EndIf
   Next

End Sequence

RestOrd(aSaveOrd,.T.)

EE8->(dbGoto(nEE8Recno))

Return(aRet)

/*
Função      : AP105FixItem
Objetivo    : Fixação de preço de um item
Parametro   : cPedido := Nro. do Pedido
              cSequen := Sequencia do item
              nQtdFix := Qtde Fixada na unidade de medida do item
              nQtdLot := Qtde Fixada em Lots
              nPrcFix := Preço fixado na unidade de medida da bolsa NY (cents US$ per LB)
              cMesAno := Mês/Ano de fixação
              dDtFix  := Data da fixação
              dDtCot  := Data da cotação
              nDif    := Diferencial
              lAtuRV  := Atualizar o pedido desvinculado de RV
              nSldFix := Saldo no item fixado.
Retorno     : Nenhum
Autor       : Cristiano A. Ferreira
Data e Hora : 25/04/2004 - 17:43
Obs.        : Após a fixação dos itens, a função AP100CallPrecoI deve ser executada para atualizar
              os totais do processo.
*/
Function AP105FixItem(cPedido, cSequen, nQtdFix, nQtdLot, nPrcFix, cMesAno, dDtFix, dDtCot, nDif, lAtuRV, nSldFix, lZera)

Local aOrd       := SaveOrd({"EE8","EE7"})
Local cLastSeq   := ""
Local nCont      := 0
Local nRecEE8    := 0
Local nInd
Local nPercPai   := 0
Local nPercFilho := 0
Local nPrcBolsa  := nPrcFix
Local cQry  := ""
Local cFilt := ""
Local aRateio  := {}
Local aRateios := {}
Local aAtualiza, aEmbs, i, j

// **
Private cUM_Bolsa  := EasyGParam("MV_AVG0062",,""), cUM_Prc
Default lAtuRV  := .t.
Default lZera   := .t.

If Type("lNewRv") <> "L"
   lNewRv := .f.
EndIf

If Type("lRvPed11") <> "L"
   lRvPed11 := .f.
EndIf

Begin Sequence

   EE7->(dbSetOrder(1))
   IF ! EE7->(dbSeek(xFilial()+AvKey(cPedido,"EE8_PEDIDO")))
      Break
   Endif

   EE8->(dbSetOrder(1))
   IF ! EE8->(dbSeek(xFilial()+AvKey(cPedido,"EE8_PEDIDO")+AvKey(cSequen,"EE8_SEQUEN")))
      Break
   Endif

   If EasyEntryPoint("EECAP105") //ER - 26/02/2007
      ExecBlock("EECAP105",.F.,.F.,"FIXITEM_INICIO")
   EndIf

   // Converte para U.M. do Item.
   If !EECFlags("CAFE") .Or. !Ap104VerPreco()
      IF !Empty(cUM_Bolsa)
         cUM_Prc := EE8->EE8_UNPRC
         IF Empty(cUM_Prc)
            cUM_Prc := EE8->EE8_UNIDAD
         Endif
         nPrcFix := AvTransUnidad(cUM_Bolsa,cUM_Prc,EE8->EE8_COD_I,nPrcFix,,.T.)
      Endif
   EndIf

   nRecEE8 := EE8->(RecNo())
   IF nQtdFix == EE8->EE8_SLDINI
      EE8->(RecLock("EE8", .F.))
      EE8->EE8_PRECO   := nPrcFix
      EE8->EE8_QTDLOT  := nQtdLot
      EE8->EE8_MESFIX  := cMesAno
      EE8->EE8_DTFIX   := dDtFix
      EE8->EE8_DTCOTA  := dDtCot
      EE8->EE8_DIFERE  := nDif
      EE8->EE8_ORIGEM  := If(Empty(EE8->EE8_ORIGEM),EE8->EE8_SEQUEN,EE8->EE8_ORIGEM)
      EE8->EE8_STFIX   := "2"

      IF EasyEntryPoint("EECAP105") // FJH - 10/10/05 - CRIANDO PTO DE ENTRADA
         EXECBLOCK("EECAP105",.F.,.F.,"GRVSSLD")
      ENDIF

      If Ap104VerPreco() .and. EECFlags("CAFE")
         nPrcFix          := EE8->EE8_PRECO
         EE8->EE8_PRECO3  := nPrcFix                 // Já está em cents/Libra
         Ap104GatPreco("EE8_PRECO3",.t.,"EE8")
      Endif

      EE8->EE8_PRECOI  := EE8->EE8_PRECO

      EE8->(MSUnLock())

      AAdd(aRateio,{EE8->(RecNo()),1, .T. } )

      If IsIntFat() .And. (EE7->(FIELDPOS("EE7_GPV")) = 0 .OR. EE7->EE7_GPV $ cSIM) .And. Left(EE8->EE8_PEDIDO,1) <> '*'
         If (nPos := AScan(aFatIt,{|x| x[1] == EE8->EE8_PEDIDO})) = 0
            SC6->(DbSetOrder(1))
            SC6->(AvSeekLast(xFilial("SC6")+EE7->EE7_PEDFAT))
            AAdd(aFatIt,{EE8->EE8_PEDIDO,SC6->C6_ITEM})
            nPos := Len(aFatIt)
         EndIf
      EndIf

      If Type("aItensFixados") == "A"
         If (nInd := (aScan(aItensFixados, {|x| x[1] == EE8->EE8_PEDIDO }))) == 0
            aAdd(aItensFixados, {EE8->EE8_PEDIDO, {EE8->EE8_SEQUEN}})
         Else
            aAdd(aItensFixados[nInd][2], EE8->EE8_SEQUEN)
         EndIf
      EndIf

   Else // ** Existe Saldo na quantidade ...

      nRecEE8 := EE8->(RecNo())
      EE8->(AvSeekLast(xFilial()+EE7->EE7_PEDIDO))
      cLastSeq := EE8->EE8_SEQUEN
      EE8->(dbGoTo(nRecEE8))

      // ** Gera um novo registro com o mesmo item com a quantidade de saldo ...
      For nCont := 1 To EE8->(FCount())
         M->&(EE8->(FieldName(nCont))) := EE8->(FieldGet(nCont))
      Next

      // ** Faz o rateio para a qtde de embalagens e pesos
      nPercPai   := Round((nQtdFix/EE8->EE8_SLDINI),15) // Percentual para o item pai ...
      nPercFilho := Round(1-nPercPai,15) // Percentual para o item filho ...

      AAdd(aRateio,{EE8->(RecNo()),nPercPai, .T. } )

      // ** Gera novo item filho com o saldo da fixação do item pai ...
      EE8->(RecLock("EE8", .T.))
      AvReplace("M", "EE8")

      AAdd(aRateio,{EE8->(RecNo()),nPercFilho, .F. } )

      EE8->EE8_DTFIX  := AVCTOD("  /  /  ")
      EE8->EE8_SLDINI -= nQtdFix // Subtrai a quantidade já fixada ...

      IF EE7->EE7_STATUS == ST_RV
         EE8->EE8_SLDATU -= nQtdFix
      Else
         EE8->EE8_SLDATU := Round(nPercFilho*EE8->EE8_SLDATU,AVSX3("EE8_SLDATU",AV_DECIMAL))
      EndIf

      EE8->EE8_PSBRTO := Round(nPercFilho*EE8->EE8_PSBRTO,AVSX3("EE8_PSBRTO",AV_DECIMAL))
      EE8->EE8_PSLQTO := Round(nPercFilho*EE8->EE8_PSLQTO,AVSX3("EE8_PSLQTO",AV_DECIMAL))
      EE8->EE8_QTDEM1 := Round(nPercFilho*EE8->EE8_QTDEM1,AVSX3("EE8_QTDEM1",AV_DECIMAL))

      If IsIntFat() .And. (EE7->(FIELDPOS("EE7_GPV")) = 0 .OR. EE7->EE7_GPV $ cSIM) .And. Left(EE8->EE8_PEDIDO,1) <> '*'

         If (nPos := AScan(aFatIt,{|x| x[1] == EE8->EE8_PEDIDO})) = 0
            SC6->(DbSetOrder(1))
            SC6->(AvSeekLast(xFilial("SC6")+EE7->EE7_PEDFAT))
            AAdd(aFatIt,{EE8->EE8_PEDIDO,SC6->C6_ITEM})
            nPos := Len(aFatIt)
         EndIf

         aFatIt[nPos][2] := SomaIt(aFatIt[nPos][2])
         EE8->EE8_FATIT  := aFatIt[nPos][2] //ER - 23/11/05 Incrementa o numero do Item no Faturamento.
      EndIf

      If Type("aItensFixados") == "A"
         If (nInd := (aScan(aItensFixados, {|x| x[1] == EE8->EE8_PEDIDO }))) == 0
            aAdd(aItensFixados, {EE8->EE8_PEDIDO, {EE8->EE8_SEQUEN}})
         Else
            aAdd(aItensFixados[nInd][2], EE8->EE8_SEQUEN)
         EndIf
      EndIf

      IF ValType(nSldFix) == "N"
         EE8->EE8_SLDATU := (M->EE8_SLDATU - nSldFix)
      Endif

      // Grava a sequencia do item pai...
      If Empty(EE8->EE8_ORIGEM) //JPM - 27/09/05 - Se a sequencia pai já tem origem, a origem da filha será a mesma
         EE8->EE8_ORIGEM := EE8->EE8_SEQUEN
      EndIf
      EE8->EE8_SEQUEN := Str(Val(cLastSeq)+1 ,AVSX3("EE8_SEQUEN", AV_TAMANHO), 0)

      EE8->(MSUnLock())

      // ** Atualiza o item fixado ...
      EE8->(dbGoTo(nRecEE8))

      EE8->(RecLock("EE8", .F.))

      EE8->EE8_SLDINI  := nQtdFix
      EE8->EE8_PRECO   := nPrcFix
      EE8->EE8_QTDLOT  := nQtdLot
      EE8->EE8_MESFIX  := cMesAno
      EE8->EE8_DTFIX   := dDtFix
      EE8->EE8_DTCOTA  := dDtCot
      EE8->EE8_DIFERE  := nDif
      If Empty(EE8->EE8_ORIGEM) //JPM - 27/09/05 - Se a sequencia pai já tem origem, a origem da filha será a mesma
         EE8->EE8_ORIGEM  := EE8->EE8_SEQUEN
      EndIf

      EE8->EE8_PSBRTO := Round(nPercPai*EE8->EE8_PSBRTO,AVSX3("EE8_PSBRTO",AV_DECIMAL))
      EE8->EE8_PSLQTO := Round(nPercPai*EE8->EE8_PSLQTO,AVSX3("EE8_PSLQTO",AV_DECIMAL))
      EE8->EE8_QTDEM1 := Round(nPercPai*EE8->EE8_QTDEM1,AVSX3("EE8_QTDEM1",AV_DECIMAL))
      EE8->EE8_SLDATU := Round(nPercPai*EE8->EE8_SLDATU,AVSX3("EE8_SLDATU",AV_DECIMAL))

      EE8->EE8_PRECOI := EE8->EE8_PRECO
      EE8->EE8_STFIX  := "2"

      IF EE8->EE8_STATUS == ST_RV .And. lZera
         EE8->EE8_SLDATU := 0
      Endif

      IF ValType(nSldFix) == "N"
         EE8->EE8_SLDATU := nSldFix
      Endif

      If Ap104VerPreco() .and. EECFlags("CAFE")
         nPrcFix          := EE8->EE8_PRECO
         EE8->EE8_PRECO3  := nPrcFix                 // Já está em cents/Libra
         Ap104GatPreco("EE8_PRECO3",.t.,"EE8")
      Endif

      IF EasyEntryPoint("EECAP105") // FJH - 10/10/05 - CRIANDO PTO DE ENTRADA
         EXECBLOCK("EECAP105",.F.,.F.,"GRVCSLD")
      ENDIF
      EE8->(MsUnlock())

   EndIf

   // ** JPM - 31/03/06 - Atualiza o embarque, e faz as quebras necessárias.
   EE8->(dbGoTo(nRecEE8))
   aEmbs := {}
   EE9->(DbSetOrder(1))
   If EE9->(DbSeek(xFilial()+EE8->(EE8_PEDIDO+EE8_SEQUEN))) // se o item possuir embarque, então atualiza o preço do mesmo.
      While EE9->(!EoF()) .And. EE9->(EE9_FILIAL+EE9_PEDIDO+EE9_SEQUEN) == (xFilial("EE9")+EE8->(EE8_PEDIDO+EE8_SEQUEN))
         AAdd(aRateios,EE9->({EE9_PREEMB,EE9_SEQEMB}))
         If AScan(aEmbs,EE9->EE9_PREEMB) = 0
            AAdd(aEmbs,EE9->EE9_PREEMB)
         EndIf
         EE9->(DbSkip())
      EndDo
      For i := 1 To Len(aRateios)
         aAtualiza := Ap104QuebraEE9(aRateio,aRateios[i][1],aRateios[i][2])
         For j := 1 To Len(aAtualiza)
            If aAtualiza[j][1]
               EE8->(DbGoTo(aAtualiza[j][2]))
               EE9->(DbGoTo(aAtualiza[j][3]))
               EE9->(RecLock("EE9",.F.))
               EE9->EE9_PRECO  := EE8->EE8_PRECO
               EE9->EE9_UNPRC  := EE8->EE8_UNPRC
               If Ap104VerPreco() .And. EECFlags("CAFE")
                  Ap104GatPreco("EE9_PRECO",.F.,"EE9")
               EndIf
               EE9->(MsUnlock())
            EndIf
         Next
      Next
      EEC->(DbSetOrder(1))
      For i := 1 To Len(aEmbs)
         EEC->(DbSeek(xFilial()+aEmbs[i]))
         Ae105CallPrecoI()
      Next
   EndIf

   // JPM - 26/11/05 - levantamento de informações para gravação do histórico do R.V.
   If lNewRv
      If lRvPed11
         If Empty(aHeaderMsg)
            aHeaderMsg := {"EE8_SEQUEN","EE8_SLDINI","EE8_PRECO"}
         EndIf
      ElseIf EE8->EE8_STATUS = ST_RV
         If Empty(aHeaderMsg)
            aHeaderMsg := {"EE8_SLDINI","EE8_PRECO"}
         EndIf
      EndIf

      If lRvPed11 .Or. EE8->EE8_STATUS = ST_RV
         AAdd(aDetailMsg,Array(Len(aHeaderMsg)))
         For i := 1 To Len(aHeaderMsg)
            aDetailMsg[Len(aDetailMsg)][i] := EE8->&(aHeaderMsg[i])
         Next
         nPrcEEY := EE8->EE8_PRECO
         cMesAnoFix := cMesAno
      EndIf
   EndIf

   IF EE8->EE8_STATUS == ST_RV // JPM - 18/11/05 - Procura outro item com mesmo Origv, Preço, Dt. Fix para consolidar
      #IFDEF TOP
         cQry := ""
         cQry += "SELECT "
         cQry += "R_E_C_N_O_ AS RECNO "
         cQry += "FROM " + RetSQLName("EE8") + " EE8 "
         cQry += "WHERE "
         cQry += "R_E_C_N_O_ <> " + AllTrim(Str(EE8->(RecNo()))) +"  AND " // não pode ser mesmo item
         cQry += "D_E_L_E_T_ <> '*' AND "
         cQry += "EE8_FILIAL = '" + xFilial("EE8")               +"' AND " // mesma filial
         cQry += "EE8_RV     = '" + EE8->EE8_RV                  +"' AND " // mesmo R.V.
         cQry += "EE8_STATUS = '" + ST_RV                        +"' AND " // status - R.V.
         cQry += "EE8_ORIGV  = '" + EE8->EE8_ORIGV               +"' AND " // mesma origem
         cQry += "EE8_DTFIX  = '" + DToS(EE8->EE8_DTFIX)         +"' AND " // mesma data de fixação
         cQry += "EE8_PRECO  =  " + AllTrim(Str(EE8->EE8_PRECO)) +""       // mesmo preço
         cQry := ChangeQuery(cQry)
         DbUseArea(.T., "TOPCONN", TcGenQry(,,cQry), "QRY", .F., .T.)
      #ELSE
         cFilt := "EE8_FILIAL+EE8_RV+EE8_STATUS+EE8_ORIGV+DToS(EE8_DTFIX)+AllTrim(Str(EE8_PRECO)) == '" +;
             EE8->(EE8_FILIAL+EE8_RV+EE8_STATUS+EE8_ORIGV+DToS(EE8_DTFIX)+AllTrim(Str(EE8_PRECO)))      +;
                  "' .And. EE8->(RecNo()) <> " + AllTrim(Str(EE8->(RecNo())))
         EE8->(DbSetFilter(&("{|| " + cFilt + "}"),cFilt))
      #ENDIF

      #IFDEF TOP
         If Qry->(!EoF())
            EE8->(DbGoTo(QRY->RECNO))
      #ELSE
         If EE8->(!EoF())
      #ENDIF
            For nCont := 1 To EE8->(FCount())
               M->&(EE8->(FieldName(nCont))) := EE8->(FieldGet(nCont))
            Next
            EE8->(RecLock("EE8",.F.),DbDelete(),MsUnlock()) //Exclui o item

            EE8->(dbGoTo(nRecEE8))

            EE8->(RecLock("EE8",.F.)) // soma as quantidades no outro item.
            EE8->EE8_SLDINI += M->EE8_SLDINI
            EE8->EE8_SLDATU += M->EE8_SLDATU
            EE8->EE8_PSBRTO += M->EE8_PSBRTO
            EE8->EE8_PSLQTO += M->EE8_PSLQTO
            EE8->EE8_QTDEM1 += M->EE8_QTDEM1
            EE8->EE8_QTDLOT += M->EE8_QTDLOT
            EE8->(MsUnlock())
         EndIf
      #IFDEF TOP
         QRY->(DbCloseArea())
      #ELSE
         EE8->(DbClearFilter())
      #ENDIF
   EndIf

   IF lAtuRV
      IF EE8->(FieldPos("EE8_DTVCRV")) > 0 .And. !Empty(EE8->EE8_DTVCRV)
         AP100RVFixPrice(nPrcBolsa)
      EndIf
   Endif

End Sequence

RestOrd(aOrd,.t.)

Return (NIL)

/*
Funcao      : AP105MarkPed
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Tela para seleção de pedidos para fixação de RV
Autor       : Cristiano A. Ferreira
Data/Hora   : 29/04/2004 - 19:26
Revisao     :
Obs.        :
*/
Static Function AP105MarkPed

Local lRet := .F.

Local nCont := 0, nAux := 0

Local oDlg, aPos
Local nOpc := 0
Local bOk           := {|| nOpc := 1, IF(AP105VldMarkPed("VLDOK"),oDlg:End(),nOpc:=0) }
Local bCancel       := {|| oDlg:End() }

Local aCpos := {{"WK_MARCA", "XX", ""},;
                ColBrw("EE8_PEDIDO", "WorkPed"),;
                ColBrw("EE8_SEQUEN", "WorkPed"),;
                {{|| Transform(WorkPed->EE8_QTDFIX, AVSX3("EE8_SLDINI",AV_PICTURE))}, "", STR0137},;  //"Qtde.Fixada"
                {{|| Transform(WorkPed->EE8_SLDINI, AVSX3("EE8_SLDINI",AV_PICTURE))}, "", STR0004}} //"Saldo"

Local cFilter := ""
Local lConverteu := .f.

Private oMsSelect, lInverte := .F.
Private aCampos     := {}
Private aHeader     := {}

Private nQtdeaFixar := nQtdeFix, nQtdConv
Private oQtdeaFixar

Begin Sequence

   // Gravar o work com os pedidos com este RV associado.
   IF ! AP105WkPed(WorkFix->EE8_RV)
      MsgInfo(STR0119,STR0027) //"Problemas na geração do arquivo temporário."###"Aviso"
      Break
   Endif

   WorkPed->(dbSeek(WorkFix->EE8_RV))

   While WorkPed->(!Eof()) .And. WorkPed->EE8_RV == WorkFix->EE8_RV
      nCont ++
      If WorkPed->EE8_UNIDAD <> cUniMedTon
         If !lConverteu
            lConverteu := .t.
         EndIf
         WorkPed->EE8_SLDINI := AvTransUnidad(WorkPed->EE8_UNIDAD,cUniMedTon,WorkPed->EE8_COD_I,WorkPed->EE8_SLDINI)
         WorkPed->EE8_QTDFIX := AvTransUnidad(WorkPed->EE8_UNIDAD,cUniMedTon,WorkPed->EE8_COD_I,WorkPed->EE8_QTDFIX)
      EndIf
      IF !Empty(WorkPed->WK_MARCA)
         nQtdeaFixar -= WorkPed->EE8_QTDFIX
      Endif
      WorkPed->(dbSkip())
   Enddo

   // Se só tiver 1 item não abre tela.
   IF nCont == 1
      WorkPed->(dbSeek(WorkFix->EE8_RV))
      If !Ap104VldPrc(.f.) // valida preço inicial contra preço no r.v.
         lRet := .f.
         Break
      EndIf
      WorkPed->WK_MARCA   := cMarca
      If WorkPed->EE8_UNIDAD <> cUniMedTon
         nQtdConv := AvTransUnidad(cUniMedTon,WorkPed->EE8_UNIDAD,WorkPed->EE8_COD_I,nQtdeFix)
      Else
         nQtdConv := nQtdeFix
      EndIf
      WorkPed->EE8_QTDFIX := nQtdConv //WorkFix->EE8_QTDFIX
      WorkPed->EE8_SLDINI := 0 //resto a ser marcado.
      lRet := .t.
      Break
   Endif

   dbSelectArea("WorkPed")
   cFilter := "WorkPed->EE8_RV == '"+WorkFix->EE8_RV+"'"
   Set Filter TO &cFilter
   WorkPed->(dbSeek(WorkFix->EE8_RV))

   Define MSDialog oDlg Title STR0120 From 00, 00 To 471, 555 Of oMainWnd Pixel //"Fixação de RVs - Vinculados"

      @ 015, 003 To 070, 276 Label STR0121 of oDlg Pixel //"Dados do RV"

      @ 026, 008 Say STR0122    Size 80, 07 Pixel Of oDlg //"Nro. R.V."
      @ 038, 008 Say STR0123         Size 80, 07 Pixel Of oDlg //"Qtde"
      @ 052, 008 Say STR0124 Size 80, 07 Pixel Of oDlg //"Qtde à Fixar"

      @ 024, 50 MSGet WorkFix->EE8_RV Picture AVSX3("EE8_RV", AV_PICTURE) Size 050, 07 Pixel Of oDlg When .F.
      @ 036, 50 MSGet WorkFix->EE8_SLDINI Picture AVSX3("EE8_SLDINI", AV_PICTURE) Size 050, 07 Pixel Of oDlg When .F.
      @ 049, 50 MSGet oQtdeaFixar Var nQtdeaFixar Picture AVSX3("EE8_SLDINI", AV_PICTURE) Size 050, 07 Pixel Of oDlg When .F.

      @ 072, 003 To 233, 276 Label STR0138 of oDlg Pixel //"Pedidos"

      aPos := { 79, 06, 230, 273 }

      oMark       := MsSelect():New("WorkPed", "WK_MARCA",, aCpos, @lInverte, @cMarca, aPos)
      oMark:bAval := {|| AP105TelaMarkPed() }

   Activate MSDialog oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) Centered

   dbSelectArea("WorkPed")
   Set Filter TO

   If nOpc = 1
      // OK
      lRet := .t.
   Else
      // Se o usuário cancelou desmarca todos os itens.
      WorkPed->(dbSeek(WorkFix->EE8_RV))
      While WorkPed->(!Eof()) .And. WorkPed->EE8_RV == WorkFix->EE8_RV

         WorkPed->WK_MARCA   := "  "
         WorkPed->EE8_SLDINI := WorkPed->(EE8_SLDINI+EE8_QTDFIX)
         WorkPed->EE8_QTDFIX := 0

         WorkPed->(dbSkip())
      Enddo

      WorkFix->EE8_DTCOTA := AvCtod("")
      WorkFix->EE8_PRECO  := 0
      WorkFix->EE8_DTFIX  := AvCtod("")
      WorkFix->EE8_QTDFIX := 0
      WorkFix->EE8_QTDLOT := 0
      WorkFix->WK_VLCOT   := 0
      WorkFix->WK_FLAG    := " "

   EndIf

   If lConverteu
      WorkPed->(dbSeek(WorkFix->EE8_RV))
      While WorkPed->(!Eof()) .And. WorkPed->EE8_RV == WorkFix->EE8_RV
         If WorkPed->EE8_UNIDAD <> cUniMedTon
            WorkPed->EE8_SLDINI := AvTransUnidad(cUniMedTon,WorkPed->EE8_UNIDAD,WorkPed->EE8_COD_I,WorkPed->EE8_SLDINI)
            WorkPed->EE8_QTDFIX := AvTransUnidad(cUniMedTon,WorkPed->EE8_UNIDAD,WorkPed->EE8_COD_I,WorkPed->EE8_QTDFIX)
         EndIf
         WorkPed->(dbSkip())
      Enddo
   EndIf

End Sequence

Return lRet

/*
Funcao      : AP105TelaMarkPed
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Tela para seleção de qtde a fixar de um item.
Autor       : Cristiano A. Ferreira
Data/Hora   : 29/04/2004 - 20:42
Revisao     :
Obs.        :
*/
*--------------------------------*
Static Function AP105TelaMarkPed()
*--------------------------------*

Local lRet    := .F.
Local nOpc    := 0
Local bOk     := {|| nOpc := 1, If(AP105VldMarkPed("EE8_QTDFIX"), oDlg:End(), nOpc := 0)}
Local bCancel := {|| oDlg:End() }

Local nCont   := 0, nQtdOld
Local oDlg

Local nQtdEm1 := 0
//Private nQE := 0.060 // Por enquanto para Volcafé sempre é em Sacas de 60 kg
Private nQE := Posicione("EE8",1,xFilial("EE8")+WorkPed->(EE8_PEDIDO+EE8_SEQUEN),"EE8_QE")

Begin Sequence

   If !Ap104VldPrc(.f.) // JPM - valida o preço inicial contra o preço do rv.
      Break
   EndIf

   For nCont := 1 To WorkPed->(FCount())
      M->&(WorkPed->(FieldName(nCont))) := WorkPed->(FieldGet(nCont))
   Next

   IF Empty(WorkPed->WK_MARCA)
      M->EE8_QTDFIX := Min(M->EE8_SLDINI,nQtdeaFixar)
   Else
      nQtdeaFixar += WorkPed->EE8_QTDFIX
      oQtdeaFixar:Refresh()

      WorkPed->WK_MARCA   := "  "
      WorkPed->EE8_SLDINI := WorkPed->(EE8_SLDINI+EE8_QTDFIX)
      WorkPed->EE8_QTDFIX := 0
      lRet := .t.
      Break
   EndIf

   Define MSDialog oDlg Title STR0125 From 00, 00 To 160, 400 Of oMainWnd Pixel //"Definição da quantidade para fixação."

      @ 013, 002 To 080, 200 Label STR0126 of oDlg Pixel //"Dados da R.V."

      @ 024, 007 Say STR0127    Size 80,07 Pixel Of oDlg //"Pedido"
      @ 036, 007 Say STR0128 Size 80,07 Pixel Of oDlg //"Sequencia"
      @ 048, 007 Say STR0004     Size 80,07 Pixel Of oDlg //"Saldo"
      @ 060, 007 Say STR0123      Size 80,07 Pixel Of oDlg //"Qtde"

      @ 022, 45 MSGet M->EE8_PEDIDO  Picture AVSX3("EE8_PEDIDO", AV_PICTURE) Size 050, 07 Pixel Of oDlg When .F.
      @ 034, 45 MSGet M->EE8_SEQUEN  Picture AVSX3("EE8_SEQUEN", AV_PICTURE) Size 050, 07 Pixel Of oDlg When .F.
      @ 047, 45 MSGet M->EE8_SLDINI  Picture AVSX3("EE8_SLDINI", AV_PICTURE) Size 050, 07 Pixel Of oDlg When .F.
      @ 060, 45 MSGet M->EE8_QTDFIX  Picture AVSX3("EE8_QTDFIX", AV_PICTURE) Size 050, 07 Pixel Of oDlg When .T. Valid AP105VldMarkPed("EE8_QTDFIX")

   Activate MSDialog oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) Centered

   If nOpc = 1
      WorkPed->EE8_SLDINI := (WorkPed->EE8_SLDINI - M->EE8_QTDFIX)
      WorkPed->EE8_QTDFIX := M->EE8_QTDFIX
      WorkPed->EE8_QTDLOT := Round(WorkPed->EE8_SLDINI/WorkFix->EE8_QTDFIX,AVSX3("EE8_QTDLOT",AV_DECIMAL))

      WorkPed->WK_MARCA   := cMarca

      nQtdeaFixar -= M->EE8_QTDFIX
      oQtdeaFixar:Refresh()

      lRet := .T.
   EndIf

End Sequence

Return(lRet)

/*
Funcao      : AP105VldMarkPed
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   :
Autor       : Cristiano A. Ferreira
Data/Hora   : 29/04/2004 - 21:00
Revisao     :
Obs.        :
*/
Static Function AP105VldMarkPed(cAcao)

Local lRet := .T.

Begin Sequence

   do Case
      Case cAcao == "VLDOK"

         IF nQtdeaFixar <> 0
            MsgInfo(STR0129, STR0022) //"Qtde à fixar não selecionada !"###"Atenção"
            lRet := .F.
            Break
         Endif

      Case cAcao == "EE8_QTDFIX"

         IF M->EE8_QTDFIX > (WorkPed->EE8_QTDFIX+WorkPed->EE8_SLDINI)
            MsgInfo(STR0130, STR0022) //"Saldo insuficiente para fixação. Informe uma quantidade inferior ao Saldo."###"Atenção"
            lRet := .F.
            Break
         EndIf

         IF M->EE8_QTDFIX < 0
            MsgInfo(STR0131, STR0022) //"Não pode haver quantidade negativada !"###"Atenção"
            lRet := .F.
            Break
         EndIf

         IF ! NaoVazio(M->EE8_QTDFIX)
            lRet := .F.
            Break
         Endif

         IF (M->EE8_QTDFIX % nQE) <> 0
            MsgInfo(STR0104, STR0022) //"Quantidade deve ser multipla pela qtde de embalagem!"###"Atenção"
            lRet := .F.
            Break
         Endif

         IF (nQtdeaFixar - M->EE8_QTDFIX) < 0
            MsgInfo( STR0132, STR0022 ) //"A quantidade informada é superior a Qtde à fixar. Informe uma qtde inferior ou igual a Qtde à fixar"###"Atenção"
            lRet := .F.
            Break
         EndIf

   End Case

End Sequence

Return lRet


/*
Função      : AP105WKPed()
Parametro   : cRV
Objetivo    : Gravar dados na WorkPed com os itens vinculados ao cRV.
Retorno     : .T. ou .F., .T. -> WorkPed com registros, .F. -> WorkPed sem registros.
Autor       : Alexsander Martins dos Santos
Data e Hora : 29/04/2004 às 19:31
*/

Static Function AP105WKPed(cRV)

Local lRet         := .T.
Local aSaveOrd     := SaveOrd("EE8")

#IFDEF TOP
   Local cQueryString := ""
   Local cCMD         := ""
#ENDIF

Begin Sequence

   If !WorkPed->(dbSeek(cRV))

      lRet := .F.

      If WorkFix->EE8_SLDATU <> 0
         WorkPed->(dbAppend())
         WorkPed->EE8_RV     := WorkFix->EE8_RV
         WorkPed->EE8_PEDIDO := WorkFix->EE8_PEDIDO
         WorkPed->EE8_SEQUEN := WorkFix->EE8_SEQUEN
         WorkPed->EE8_SLDINI := WorkFix->EE8_SLDATU
         WorkPed->EE8_UNIDAD := WorkFix->EE8_UNIDAD
      EndIf

      #IFDEF TOP

         cQueryString += "SELECT "
         cQueryString += "EE8_RV, "
         cQueryString += "EE8_PEDIDO, "
         cQueryString += "EE8_SEQUEN, "
         cQueryString += "EE8_UNIDAD, "
         cQueryString += "EE8_SLDINI "
         cQueryString += "FROM " + RetSQLName("EE8") + " EE8 "
         cQueryString += "WHERE "
         cQueryString += "D_E_L_E_T_ <> '*' AND "
         cQueryString += "EE8_FILIAL = '"+xFilial("EE8")+"' AND "
         cQueryString += "EE8_STATUS <> '"+ST_RV+"' AND "
         cQueryString += "EE8_RV = '"+cRV+"' AND "
         cQueryString += "EE8_DTFIX = ''"

         cCMD := ChangeQuery(cQueryString)
         dbUseArea(.T., "TOPCONN", TCGENQRY(,,cCmd), "QRY", .F., .T.)

         While QRY->(!Eof())

            WorkPed->(dbAppend())
            AVReplace("QRY", "WorkPed")

            QRY->(dbSkip())

         End

         QRY->(dbCloseArea())

      #ELSE

         EE8->(dbSetOrder(1))
         EE8->(AVSeekLast(xFilial()+"*"))
         EE8->(dbSkip())

         While EE8->(!Eof() .and. EE8_FILIAL == xFilial())

            If EE8->EE8_RV == cRV .and. Empty(EE8->EE8_DTFIX)
               WorkPed->(dbAppend())
               WorkPed->EE8_RV     := EE8->EE8_RV
               WorkPed->EE8_PEDIDO := EE8->EE8_PEDIDO
               WorkPed->EE8_SEQUEN := EE8->EE8_SEQUEN
               WorkPed->EE8_SLDINI := EE8->EE8_SLDINI
               WorkPed->EE8_UNIDAD := EE8->EE8_UNIDAD
            EndIf

            EE8->(dbSkip())

         End

      #ENDIF

      lRet := WorkPed->(EasyRecCount()) > 0

   EndIf

End Sequence

RestOrd(aSaveOrd)

Return(lRet)

/*
JPP - 24/02/2005 às 13:30. Devido a probelmas de compilação,A função IsFilial() apenas passou a chamar a função IsFilial2
                           que está definida no programa EECAP103, para resolver o problema de estouro de define que
                           ocorria no programa EECAP105.
*/

/*
Funcao      : IsFilial(cRotina)
Parametros  : cRotina - Indica a rotina utilizada e verifica as validações
                        necessárias a serem executadas.
Retorno     : .t./.f.
Objetivos   : Chamar a função IsFilial2(), que irá Validar os códigos de filiais informados contra os códigos válidos
              no sigamat.emp.
Autor       : Julio de Paula Paz.
Data/Hora   : 24/02/2005 13:30.
Revisao     :
Obs.        :
*/

*------------------------*
Function IsFilial(cRotina)
*------------------------*
Return IsFilial2(cRotina)

/*
Funcao      : AP105VldAdiant().
Parametros  : Nenhum
Retorno     : .t./.f.
Objetivos   : Validar se o Total do Processo é maior ou menor que o total de adiantamento do processo.
Autor       : Julio de Paula Paz
Data/Hora   : 08/02/2006 11:55
Revisao     :
Obs.        :
*/
*--------------------------------------*
Function AP105VldAdiant()
Local lRet := .T., aOrdAd := SaveOrd("EEQ")
Local nTotAdia := 0

Begin Sequence
  EEQ->(DbSetOrder(6)) // Fase+Preemb+Parcela"
  EEQ->(DbSeek(xFilial("EEQ")+"P"+M->EE7_PEDIDO))

  Do While EEQ->(!Eof()) .And. EEQ->EEQ_FILIAL == xFilial("EEQ") .And.;
                               EEQ->EEQ_FASE   == "P" .And.;
                               EEQ->EEQ_PREEMB == M->EE7_PEDIDO
     If EEQ->EEQ_TIPO = "A"
        // ** Acumula os adiantamentos.
        nTotAdia += EEQ->EEQ_VL
     EndIf

     EEQ->(DbSkip())
  EndDo
  If nTotAdia > M->EE7_TOTPED // Total de Adiantamentos > Total do processo.
     lRet := .F.
  EndIf
End Sequence

RestOrd(aOrdAd)

Return lRet
/*
Funcao      : AP105AtuAdiant().
Parametros  : Nenhum
Retorno     : .t./.f.
Objetivos   : Atualizar o total de adiantamento do processo, de acordo com o total do processo.
Autor       : Julio de Paula Paz
Data/Hora   : 08/02/2006 13:45
Revisao     :
Obs.        :
*/
*--------------------------------------*
Function AP105AtuAdiant()
Local lRet := .T., aOrdAd := SaveOrd({"EEQ","SA1"}) ,nOpc := 0
Local aCpos
Local cPictVl := AvSx3("EEQ_VL",AV_PICTURE)
Local cTitulo

Local bOk:={|| If(nSaldo == 0,(nOpc:=1, oDlg:End()),MsgInfo(STR0159))},; //"O saldo de Adiantamento deve ser igual a zero."
      bCancel:={||nOpc := 0 , oDlg:End()}
Local lInverte := .f.
Local oDlg, oMark,oTotVinc,oSaldo

Private nTotVinc := 0, nSaldo := 0, cMarcaAd := GetMark()

Begin Sequence
   MsgInfo(STR0144,STR0022) //"O total de adiantamento do pedido não pode ser maior que o total do pedido. Os excessos deverão ser estornados."###"Atenção!"      

   SA1->(DbSetOrder(1))
   SA1->(DbSeek(xFilial("SA1")+M->EE7_IMPORT+M->EE7_IMLOJA))

   WORKSLD_AD->(AvZap())
   EEQ->(DbSetOrder(6)) // Fase+Preemb+Parcela"
   EEQ->(DbSeek(xFilial("EEQ")+"P"+M->EE7_PEDIDO))

   Do While EEQ->(!Eof()) .And. EEQ->EEQ_FILIAL == xFilial("EEQ") .And.;
                                EEQ->EEQ_FASE   == "P" .And.;
                                EEQ->EEQ_PREEMB == M->EE7_PEDIDO
      If EEQ->EEQ_TIPO = "A"
         WORKSLD_AD->(DbAppend())
         AvReplace("EEQ","WORKSLD_AD")
         WORKSLD_AD->WK_RECNO := EEQ->(RecNo())
         WORKSLD_AD->WK_STATUS := If(Empty(WORKSLD_AD->EEQ_FAOR),STR0011,STR0145+SA1->A1_NOME) // "Normal" ### "Vinculado Cliente: "
         nTotVinc += EEQ->EEQ_VL
      EndIf

      EEQ->(DbSkip())
   EndDo
   nSaldo := nTotVinc - M->EE7_TOTPED

    // ** Colunas para o Browse ...
   aCpos := {{"WK_FLAG","","  "},;
             {{|| WORKSLD_AD->WK_STATUS},"",STR0150},; //"Adiantamento"
             {{|| Transf(WORKSLD_AD->EEQ_VL,cPictVl)}   ,"",STR0151},; //"Valor Adiantamento"
             {{|| Transf(WORKSLD_AD->WK_VLEST,cPictVl)} ,"",STR0152}} // "Valor a Estornar"

   cTitulo := STR0146 // "Estorno dos Adiantamentos"
   WORKSLD_AD->(DbGoTop())

   Define MsDialog oDlg Title cTitulo From 9,0 To 40,110 of oDlg

      oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165)
      oPanel1:Align:= CONTROL_ALIGN_TOP
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      @ 15,07 Say STR0147 Size 100,07 Pixel Of oDlg // "Total Adiantamento do Processo"
      @ 15,90  MsGet oTotVinc Var nTotVinc Picture cPictVl Size 40,07  Pixel Of oPanel When .f.

      @ 25,007 Say STR0148 Size 100,07 Pixel of oPanel // "Total do Processo"
      @ 25,90  MsGet M->EE7_TOTPED Picture cPictVl Size 40,07 Pixel Of oPanel When .f.

      @ 35,07 Say STR0149 Size 100,07 Pixel Of oDlg // "Saldo de Adiantamento"
      @ 35,90 MsGet oSaldo Var nSaldo Picture cPictVl Size 40,07 Pixel Of oPanel When .f.

      aPos := PosDlgDown(oDlg)
      aPos[1] := 46

      // by CRF 24/11/2010 - 14:44
      aCpos := AddCpoUser(aCpos,"EEQ","2")

      oMark := MsSelect():New("WORKSLD_AD","WK_FLAG",,aCpos,@lInverte,@cMarcaAd,aPos)
      oMark :bAval := {|| If(Empty(WORKSLD_AD->WK_FLAG),AP105MarkAd(oMark,,oTotVinc,oSaldo),AP105MarkAd(oMark,.f.,oTotVinc,oSaldo))}

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
Funcao      : AP105MarkAd(oMark,lMarcar,oTotVinc,oSaldo)
Parametros  : oMark   => Objeto para Refresh.
              lMarcar => .t. - Marca item.
                         .f. - Desmarca item.
              oTotVinc => Objeto para Refresh
              oSaldo   => Objeto para Refresh
Retorno     : .T.
Objetivos   : Estornar os valores para os adiantamentos do processo.
Autor       : Julio de Paula Paz
Data/Hora   : 15/02/2006
Obs.        :
*/
*--------------------------------------*
Static Function AP105MarkAd(oMark,lMarcar,oTotVinc,oSaldo)
*--------------------------------------*
Local nOpc := 0, nValor := 0, nValDisp := 0
Local bOk:={|| (nOpc:=1,oDlg:End())}
Local bCancel := {|| oDlg:End()}
Local cTitulo, cX
Local lRet:=.t.
Local oDlg

Default lMarcar := .t.

Begin Sequence
   If ! Empty(WORKSLD_AD->EEQ_PGT) .And. Empty(WORKSLD_AD->EEQ_FAOR)
      MsgInfo(STR0153,STR0022) //"Este Adiantamento está com cambio contratado e não poderá ser estornado." ###"Atenção"
      Break
   ElseIf WORKSLD_AD->EEQ_SALDO == 0
      MsgInfo(STR0154,STR0022) //"Este Adiantamento está vinculado a um ou mais embarques. Estorne o adiantamento vinculado ao embarque, antes de estornar o adiantamento do pedido." ###"Atenção"
      Break
   EndIf
   If nSaldo > WORKSLD_AD->EEQ_SALDO
      nValDisp := WORKSLD_AD->EEQ_SALDO
   Else
      nValDisp := nSaldo
   EndIf

   If lMarcar

      cTitulo  := STR0155 // "Estorno dos valores de adiantamento"

      Define MsDialog oDlg Title cTitulo From 10,12 To 20.5,47 Of oMainWnd

         @ 1.1, 0.5 To 5.5,17 Label STR0063 Of oDlg // "Valores "

         @ 1.8, 2.0 Say STR0064  Of oDlg Size 35,9 // "Disponivel"
         @ 2.4, 2.0 MsGet nValDisp  Size 70,07  Picture AVSX3("EEQ_VL",AV_PICTURE) Of oDlg When .f.

         @ 3.8, 2.0 Say STR0156 Of oDlg Size 35,9 // "Estornar"
         @ 4.4, 2.0 MsGet nValor Size 70,07 Picture AVSX3("EEQ_VL",AV_PICTURE) Valid(AP105ValAd(nValDisp,nValor)) Of oDlg

         @ 10.0, 2.0 MsGet cX Size 70,07 Of oDlg

      Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) Centered

      If nOpc = 1
         If nValor > 0
            WORKSLD_AD->WK_FLAG   := cMarcaAd
            WORKSLD_AD->WK_VLEST  := nValor // Valor a estornar
            AP105AtuValAd() // Atualiza valores das variaveis saldo(nSaldo) e total vinculado(nTotVinc).
         EndIf
      EndIf
   Else
      WORKSLD_AD->WK_FLAG   := ""
      WORKSLD_AD->WK_VLEST := 0 // Zera valor Estornado
      AP105AtuValAd() // Atualiza valores das variaveis saldo(nSaldo) e total vinculado(nTotVinc).
   EndIf
   oTotVinc:Refresh()
   oSaldo:Refresh()
End Sequence

Return lRet

/*
Funcao      : AP105ValAd(nValDisp,nValor)
Parametros  : nValDisp   => Valor disponivel para o estorno
              nValor     => Valor digitado
Retorno     : .T./.F.
Objetivos   : Validação na digitação dos valores a Estornar.
Autor       : Julio de Paula Paz
Data/Hora   : 15/02/2006 - 08:55
Obs.        :
*/
*--------------------------------------*
Static Function AP105ValAd(nValDisp,nValor)
Local lRet := .T.
Begin Sequence
   If nValor > nValDisp
      MsgInfo(STR0157,STR0022) //"O valor digitado não pode ser maior que o valor disponível." ###"Atenção"
      lRet := .F.
   ElseIf nValor < 0
      MsgInfo(STR0158,STR0022) //"O valor digitado não pode ser menor que zero." ###"Atenção"
      lRet := .F.
   EndIf
End Sequence

Return lRet

/*
Funcao      : AP105AtuValAd()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Atualizar valores Total adiantamento do processo e saldo dos valores estornados.
Autor       : Julio de Paula Paz
Data/Hora   : 15/02/2006 - 08:55
Obs.        :
*/
*--------------------------------------*
Static Function AP105AtuValAd()
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
   nSaldo := nTotVinc - M->EE7_TOTPED // Valor do saldo
End Sequence

Return lRet

/*
Funcao      : AP105GrvEstAd()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Atualizar os dados da tabela EEQ com os estornos dos adiantamentos.
Autor       : Julio de Paula Paz
Data/Hora   : 09/02/2006 - 09:20
Obs.        :
*/
*--------------------------------------*
Function AP105GrvEstAd()
Local lRet := .T., aOrd := SaveOrd({"EEQ"}), cChave := AvKey(M->EE7_IMPORT,"EE7_IMPORT")+AvKey(M->EE7_IMLOJA,"EE7_IMLOJA")
Local nReg
Local aParc:={}

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
      If Empty(WORKSLD_AD->EEQ_FAOR) // Adiantamento normal criado na fase de processo
         aParc:={}
         Aadd(aParc,0)
         nReg := 0
         EEQ->(DbSetOrder(1))
         If EEQ->(DbSeek(xFilial("EEQ")+cChave))   // Localiza uma parcela de cambio por cliente que possa ser adicionado o estorno.
            Do While ! EEQ->(Eof()) .And. (xFilial("EEQ")+Avkey(cChave,"EEQ_PREEMB")) == (EEQ->(EEQ_FILIAL+EEQ_PREEMB))
               If Empty(EEQ->EEQ_PGT) .And. EEQ->EEQ_TIPO == "A"  // Cambio não contratado
                  nReg := EEQ->(Recno())
               EndIf
               aAdd(aParc,Val(EEQ->EEQ_PARC))
               EEQ->(DbSkip())
            EndDo
         EndIf
         If nReg == 0  // Não há nenhum adiantamento por cliente disponível. Cria um novo adiantamento por cliente para adicionar o estorno do adiantamento por processo.
            aSort(aParc,,,{|x,y| x > y }) // Ordena o numero das parcelas existentes, do maior para o menor.
            EEQ->(Reclock("EEQ",.T.))
            EEQ->EEQ_FILIAL := xFilial("EEQ")
            EEQ->EEQ_EVENT  := "605"
            EEQ->EEQ_VL     := WORKSLD_AD->WK_VLEST
            EEQ->EEQ_PARC   := SomaIt(AllTrim(Str(aParc[1])))//StrZero(aParc[1]+1,2,0)
            EEQ->EEQ_PREEMB := M->EE7_IMPORT+M->EE7_IMLOJA
            EEQ->EEQ_FASE   := "C"
            EEQ->EEQ_TIPO   := "A"
            EEQ->EEQ_SALDO  := WORKSLD_AD->WK_VLEST
            EEQ->EEQ_EMISSA := dDataBase  //NCF - 07/06/2021
            If EECFlags("FRESEGCOM")
               EEQ->EEQ_MOEDA  := Posicione("EXJ",1,xFilial("EXJ")+M->EE7_IMPORT+M->EE7_IMLOJA,"EXJ_MOEDA")
               EEQ->EEQ_IMPORT := M->EE7_IMPORT
               EEQ->EEQ_IMLOJA := M->EE7_IMLOJA
            EndIf
         Else  // Há adiantamento por cliente disponível. Adiciona estorno do adiantamento por processo no adiantamento por cliente.
            EEQ->(DbGoto(nReg))
            EEQ->(Reclock("EEQ",.F.))
            EEQ->EEQ_VL := EEQ->EEQ_VL + WORKSLD_AD->WK_VLEST
            EEQ->EEQ_SALDO := EEQ->EEQ_SALDO + WORKSLD_AD->WK_VLEST
            EEQ->(MsUnLock())
         EndIf
      Else // Adiantamento vinculado
         EEQ->(DbSetOrder(6))
         EEQ->(DbSeek(xFilial("EEQ")+WORKSLD_AD->(EEQ_FAOR+EEQ_PROR+EEQ_PAOR))) // Localiza o registro que originou a associação do Adiantamento.
         EEQ->(RecLock("EEQ",.F.))
         EEQ->EEQ_SALDO := EEQ->EEQ_SALDO + WORKSLD_AD->WK_VLEST  // Estorna o saldo
         EEQ->(MsUnLock())
      EndIf
      EEQ->(DbGoto(WORKSLD_AD->WK_RECNO)) // Posiciona no registro associado
      EEQ->(RecLock("EEQ",.F.))
      If EEQ->EEQ_VL == WORKSLD_AD->WK_VLEST // Se Valor de estorno igual ao total da associação de adiantamento excluir registro.
         EEQ->(DbDelete())
      Else
         EEQ->EEQ_VL := EEQ->EEQ_VL - WORKSLD_AD->WK_VLEST  // Atualiza valor de adiantamento associado.
         EEQ->EEQ_SALDO := EEQ->EEQ_SALDO - WORKSLD_AD->WK_VLEST
      EndIf
      EEQ->(MsUnLock())
      WORKSLD_AD->(DbSkip())
   EndDo
End Sequence
RestOrd(aOrd)
Return lRet

/*
*------------------------------------------------*
/ Funcao....: AP105RestOrDel()                   /
/ Parametro.:                                    /
/ Objetivos.: Eliminar/Restaurar Saldo           /
/ Autor.....: Diogo Felipe dos Santos            /
/ Data/Hora.: 26/07/10 - 15:20                   /
/ RETORNO...: Saldo Eliminado ou Restaurado      /
/ Obs.......:                                    /
*------------------------------------------------*
*/

*--------------------------------*
STATIC FUNCTION AP105RestOrDel()
*--------------------------------*

Begin sequence

   If Empty(Work_Pgto->EEQ_FAOR) .AND. !Empty(Work_Pgto->EEQ_SALDO)
      If MSGYESNO(STR0170) //"Confirma Eliminação de Saldo?"
         Work_Pgto->EEQ_SLDELI := Work_Pgto->EEQ_SALDO
         Work_Pgto->EEQ_SALDO  := 0
      EndIf
   ElseIf Empty(Work_Pgto->EEQ_FAOR) .AND. Empty(Work_Pgto->EEQ_SALDO)
       If MSGYESNO(STR0171) //"Confirma Restauração de Saldo?"
         Work_Pgto->EEQ_SALDO  := Work_Pgto->EEQ_SLDELI
         Work_Pgto->EEQ_SLDELI := 0
       EndIf
   ElseIf Work_Pgto->EEQ_FAOR == "F"
      MsgStop(STR0017+Replic(ENTER,2)+; //"Este adiantamento não pode ser alterado."
              STR0018+ENTER+;  //"Detalhes:"
              STR0019+ENTER+;  //"Este adiantamento já está vinculado a fechamento(s) de cambio,"
              STR0020+ENTER+;  //"para alterar o mesmo favor desvincular o adiantamento no{s) "
              STR0021, STR0022) //"fechamento(s) de cambio correspondente(s)."###"Atenção"
      Break
   Else
      MsgStop(STR0172, STR0061) //"Não foi possível Eliminar/Resturar este processo, por ser um adiantamento vinculado.", "Atenção"
      Break
   EndIf

End Sequence

Return nil

/*
Funcao     : ClrBufADP()
Parametros : nRecEEQ - Recno da EEQ
Retorno    : Nenhum
Objetivos  : Chamar funções que manipulam array estático da integração do adapter EECAF212
             para exclusão de registros da lista de recnos.
Autor      : NCF - Nilson César
Data/Hora  : 07/11/2018 - 11:30
*/
*-----------------------------------*
Static Function ClrBufADP(nRecEEQ)
*-----------------------------------*
Local aDadosRcp,nPosAdp

// NCF - 06/11/2018 - recuperar buffer com os recnos das parcelas tratadas pelo ADAPTER EECAF212
If FindFunction("GetDataInt")
   aDadosRcp := GetDataInt()
EndIf

If ValType(aDadosRcp) == "A"
   If( nPosAdp := aScan(aDadosRcp, {|x| x[1] == "EECAF212" .And. x[2] == nRecEEQ } ) ) > 0
      If FindFunction("DelDataInt")
         DelDataInt( nPosAdp )
      EndIf
   EndIf
EndIf

Return
*------------------------------------------------------------------------------------------------------------------*
* FIM DO PROGRAMA EECAP105                                                                                         *
*------------------------------------------------------------------------------------------------------------------*
