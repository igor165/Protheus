#include "eecrdm.ch"
#INCLUDE "EECAE104.ch"
/*
Programa        : EECAE104.PRW
Objetivo        : Tela de Carregamento
Autor           : Ricardo Dumbrovsky
Obs.            :
*/

#include "EEC.CH"
#INCLUDE "AP5MAIL.CH"
/*
Funcao      : EECAE104()
Parametros  : Nenhum
Retorno     : NIL
Objetivos   : Tela de Carregamento
Autor       : Ricardo Dumbrovsky
Data/Hora   : 01/08/2002 14:00
Revisao     : João Pedro Macimiano Trabbold - 19/12/05 - Mudança na manutenção de containers e de lotes.
Obs.        :
*/

*-----------------*
Function EECAE104(xAutoCab,xAutoItens,xOpcAuto)
*-----------------*
Local nOldArea := Select(), lAtu := .f., i
Local aOrd := SaveOrd("EEC")

Private cProcEmb := EEC->(EEC_FILIAL+EEC_PREEMB)

Begin Sequence

   /* JPM - Correções na rotina de carregamento/container.
   Private aRotina := { { STR0001, "AxPesqui"  , 0 , PESQUISAR},;  //"Pesquisar"
                        { STR0002, "AE104MAN"  , 0 , ALTERAR } }  //"Carregar"
   */
   Private aRotina := { { STR0001, "AxPesqui" , 0 , 1},;  //"Pesquisar "
                        { STR0093, "AE104MAN" , 0 , 2},;  //"Visualizar"
                        { STR0094, "AE104MAN" , 0 , 3},;  //"Incluir"
                        { STR0095, "AE104MAN" , 0 , 4},;  //"Alterar"
                        { STR0096, "AE104MAN" , 0 , 5,3}} //"Excluir"
   Private cCadastro := STR0003, aCampos:={}, aHeader := {} //"Carregamento"
   Private lIncluir := .F., cNomArq := "", cNomArq2:="", cNomArq3 :=""
   Private lEX9Auto := ValType(xAutoCab) == "A"
   Private lEXAAuto := lEX9Auto .And. ValType(xAutoItens) == "A"
   Private aEX9Auto := xAutoCab
   Private aEXAAuto := xAutoItens
   Private nOpcAuto := xOpcAuto
   If ExistBlock("EECAE104")
      ExecBlock("EECAE104",.F.,.F.,"AROTINA")
   Endif
   If lEX9Auto .And. Type("lMsErroAuto") <> "L"
      Private lMsErroAuto := .F.
   EndIf
   If Type("lIntermed") <> "L"
      Private cFilBr := ""
      Private cFilEx := ""
      Private lIntermed := EECFlags("INTERMED")
   EndIf

   Begin Sequence

       If lEX9Auto
          If (nPosEmb := aScan(aEX9Auto, {|x| Alltrim(x[1]) == "EX9_PREEMB" })) > 0
            if AvKeyAuto(aEX9Auto)
                EEC->(DbSetOrder(1))
                If EEC->(DbSeek(xFilial()+AvKey(aEX9Auto[nPosEmb][2], "EEC_PREEMB")))
                    EX9->(DbFilter({|| EX9->EX9_FILIAL == xFilial("EX9") .And. EX9->EX9_PREEMB == EEC->EEC_PREEMB }, 'EX9->EX9_FILIAL == xFilial("EX9") .And. EX9->EX9_PREEMB == EEC->EEC_PREEMB'))
                    MBrowseAuto(nOpcAuto, aEX9Auto, "EX9",, .T.)
                Else
                    EasyHelp( STR0130 + AllTrim(aEX9Auto[nPosEmb][2]), STR0024 ) //"Embarque não localizado para integração automática de containers: " , // ATENÇÃO
                EndIf
            Else
                EasyHelp( STR0131, STR0024) // "Erro no array da capa do container."
            endif
          Else
             EasyHelp( STR0132, STR0024) //"Código do embarque não informado para integração automática de containers."
          EndIf
       Else
          If Select("WorkIp") = 0 // se não está criada esta work, então não está sendo chamada do lugar certo.
             MsgStop(STR0103) //"Esta opção deve ser chamada da Manutenção de Embarques, através da opção 'Contain./Lotes'. Se a mesma não existir, solicite um patch geral. "
             Break
          EndIf

          DbSelectArea("EX9")

          mBrowse(6,1,22,75,"EX9",,,,,,,,,,,,,,AE104FiltroEX9())
      EndIf

   End Sequence

End Sequence

dbSelectArea(nOldArea)

RestOrd(aOrd,.T.)

Return NIL

/*
Funcao      : AE104FiltroEX9
Parametros  :
Retorno     : Filtro
Objetivos   : Fornecer o filtro a ser executado pela mBrowse na chamada da tabela EX9
Autor       : Wilsimar Fabrício da Silva
Data        : 21/07/2009
Revisao     :
Obs.        :
*/

Function AE104FiltroEX9()
Return "EX9_PREEMB = '" + EEC->EEC_PREEMB + "'"


/*
Funcao      : AE104Man
Parametros  : nOpc    := Opcao Selecionada
              cTitulo := Titulo da janela
Retorno     : NIL
Objetivos   : Manutencao da tela de CARREGAMENTO
Autor       : Ricardo Dumbrovsky
Revisao     :
Obs.        :
*/

Function AE104MAN(cAlias,nReg,nOpc)

Local nInc
Local lRet := .f., i
Local aObjs[4], aPos,  oDlg
Local bOk, bCancel
Local aOrd := SaveOrd("EEC")
Local cMsgCnt := ""
Private aButtons := {}

Private aCpos := {{"EE9_COD_I" ,"",STR0004},; //"Produto"
                {"EE9_SEQEMB","",STR0005},; //"Sequencia"
                {"EE9_DESC"  ,"",STR0006},; //"Descricao"
                {{|| Transform(TRB->EE9_SLDINI,AVSX3('EE9_SLDINI',AV_PICTURE))},"",STR0007},; //"Quantidade"
                {{|| Transform(TRB->EE9_UNIDAD,AVSX3('EE9_UNIDAD',AV_PICTURE))},"",STR0109},;//acb - 12/11/2010 - "Unidade"
                {{|| Transform(TRB->EE9_QTDEM1,AVSX3('EE9_QTDEM1',AV_PICTURE))},"",STR0008}} //"Qtde. de Embalagens"

Private aDeleted := {}
Private nSelecao := nOpc
Private lInclui := (nOpc == INCLUIR)
Private lExclui := (nOpc == EXCLUIR)
Private lAltera := (nOpc == ALTERAR)
Private lVisual := (nOpc == VISUALIZAR)
Private aMemos:={{"EX9_OBS","EX9_VM_OBS"}}
Private aGets[0], aTela[0][0]
Private nUsado:= 0, aStruct := {}, aHeader :={},aCols := {}, aTst := {},aEX9 := {}
Private lFim := .F.

//AST -16/07/08 - vetor usado para mostrar na enchoice somente os campos que não pertencem ao INTTRA
Private aCampos := {}

If EasyEntryPoint("EECAE104") // TLM 04/01/2008
   ExecBlock("EECAE104",.F.,.F.,{"ITENS_BROWSE_LOTE"})
EndIF

Begin Sequence

   If EECFlags("INTTRA")
      aAdd(aMemos,{"EX9_CCOTEM","EX9_COMTEM"})
   EndIf

   If lInclui .Or. lAltera .Or. lExclui
     //MFR 16/04/2019 OSSME-2432
     //IF Len(AddCpoUser(aTst,"EX9","2")) <= 0 //LRS - 08/01/2015 - Contador, para verificar se tem campo de usuario
     IF Len(aTst := AddCpoUser(aTst,"EX9","2")) <= 0//LRS - 08/01/2015 - Contador, para verificar se tem campo de usuario     
	     If !Empty(EEC->EEC_DTEMBA)
	         EasyHelp(STR0097, STR0024) //"O processo deste container já foi embarcado, portanto não poderá ser alterado."###"Atenção"
	         lRet := .f.
	         Break
	     EndIf
     EndIF
      
      If lIntermed .And. xFilial("EX9") <> cFilBr .And. IsOffShore(EEC->EEC_PREEMB) //Processo marcado como OffShore
         EasyHelp(STR0105, STR0024) //"Para processos off-shore, Inclusões/Alterações/Exclusões deverão ser realizadas apenas na filial Brasil."###"Atenção"
         lRet := .f.
         Break
      EndIf
      
   EndIf

   If lInclui
      For nInc := 1 TO (cAlias)->(FCount())
         M->&((cAlias)->(FIELDNAME(nInc))) := Criavar(FIELDNAME(nInc))
      Next nInc
      M->EX9_FILIAL := xFilial("EX9")
      M->EX9_PROCES := EEC->EEC_PEDREF
      M->EX9_PREEMB := EEC->EEC_PREEMB
   Else
      For nInc := 1 TO (cAlias)->(FCount())
         M->&((cAlias)->(FIELDNAME(nInc))) := (cAlias)->(FieldGet(nInc))
      Next nInc
   EndIf

   AAdd(aButtons,{"BMPINCLUIR" /*"ADDCONTAINER"*/,{|| Ae104Det()},STR0002}) // "Carregar"

   bCancel := {|| lRet := .f., oDlg:End() }
   bOk     := {|| If(Ae104Valid(),(lRet := .t., oDlg:End()),) }

   Ae104Grv_Trb()

   If EasyEntryPoint("EECAE104")
      ExecBlock("EECAE104",.f.,.f.,{"ANTES_ENCHOICE_PRINCIPAL"})  //TRP-09/01/08- Criação de ponto de entrada
   EndIf

   If !lEX9Auto
      DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

         aPos := PosDlgUp(oDlg)

         CposEnChoice()

         If Len(aTst) >0  //LRS - 08/01/2015 - Preencher Array para edição de campos de Cliente
	         For i := 1 To Len(aTst)
	            AADD(aEX9,aTst[i][1])
	         Next i
         endIF

         IF(EasyEntryPoint("EECAE104"),Execblock("EECAE104",.F.,.F.,"ALT_TELA_CONT"),) //LRS - 04/03/2015 - Ponto entrada para editar o aEX9

         EnChoice( cAlias, nReg, nOpc,,,,aCampos, aPos, If(!Empty(EEC->EEC_DTEMBA),aEX9, Nil))

         aPos := PosDlgDown(oDlg)

         // by CRF - 07/10/2010 - 10:00
         aCpos := AddCpoUser(aCpos,"EE9","2")

         //aCpos := AddCpoUser(aCpos,"EE9","5","TRB")



         oBrowNote := MsSelect():New("TRB",,,aCpos,,,aPos)
         If AScan(aButtons,{|x| x[1] = "BMPINCLUIR" /*"ADDCONTAINER"*/}) > 0
            oBrowNote:bAval := {|| Ae104Det()}
         EndIf

      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons)
   Else
        if (nPosCont := aScan( aEX9Auto , {|x| alltrim(x[1]) == "ATUCONTAIN" })) > 0
            if (nPContnr := aScan( aEX9Auto , {|x| alltrim(x[1]) == "EX9_CONTNR" })) > 0
                aEX9Auto[nPContnr][2] := aEX9Auto[nPosCont][2]
            endif
        Endif
      EnchAuto(cAlias,aEX9Auto,{|| Obrigatorio(aGets,aTela)},nOpc, If(!Empty(EEC->EEC_DTEMBA),aEX9, Nil))
      If lMsErroAuto
         lRet := .F.
      Else
         lRet := .T.
         If lEXAAuto
            aEXAItemAuto := {}
            For i := 1 To Len(aEXAAuto)
               //Identifica o item
               If (nPosSeq := aScan(aEXAAuto[i], {|x| AllTrim(x[1]) == "EXA_SEQEMB" })) > 0
                  //Agrupa as informações por item
                  If (nPosItem := aScan(aEXAItemAuto, {|x| x[1] == aEXAAuto[i][nPosSeq][2] })) == 0
                     aAdd(aEXAItemAuto, {aEXAAuto[i][nPosSeq][2], {}})
                     nPosItem := Len(aEXAItemAuto)
                  EndIf
                  aAdd(aEXAItemAuto[nPosItem][2], aEXAAuto[i])
               Else
                  EasyHelp(StrTran( STR0133, "XXX", AllTrim(Str(i))), STR0024) //"Erro na execução da rotina automática. Não foi informado o campo EXA_SEQEMB na posição 'XXX' do array de itens."
                  lRet := .F.
                  Exit
               EndIf
            Next
            If lRet
               For i := 1 To Len(aEXAItemAuto)
                  TRB->(DbSetOrder(1))
                  If TRB->(DbSeek(aEXAItemAuto[i][1]))
                     If !(lRet := Ae104Det(aEXAItemAuto[i][2]))
                        Exit
                     EndIf
                  Else
                     EasyHelp(StrTran( STR0134 , "XXX", AllTrim(aEXAItemAuto[i][1])), STR0024) //"Erro na Execução da rotina automática. O item 'XXX' (EE9_SEQEMB) não foi localizado entre os itens disponíveis para carregamento."
                     lRet := .F.
                     Exit
                  EndIf
               Next
            EndIf
         EndIf
      EndIf
   EndIf

   IF !lRet
      Break
   Endif

   Begin Transaction

      If lInclui .Or. lAltera
         EX9->(RecLock("EX9",lInclui))
         AvReplace("M","EX9")

         If lAltera
            For i := 1 To Len(aMemos)
               If EX9->(FieldPos(aMemos[i,1])) > 0
                  MSMM(EX9->&(aMemos[i,1]),,,,EXCMEMO)
               EndIf
            Next
         EndIf

         For i := 1 To Len(aMemos)
            If EX9->(FieldPos(aMemos[i,1])) > 0
               EX9->(MSMM(EX9->&(aMemos[I,1]),AvSx3(aMemos[i,2],AV_TAMANHO),,EX9->&(aMemos[i,2]),INCMEMO,,,"EX9",aMemos[I,1]))
            EndIf
         Next

         EX9->(MsUnlock())

         GravaEXA()

      ElseIf lExclui
         EXA->(DbSetOrder(1))
         EXA->(DbSeek(xFilial("EXA")+EX9->(EX9_PREEMB+EX9_CONTNR)))
         While EXA->(!EoF()) .And. EXA->(EXA_FILIAL+EXA_PREEMB+EXA_CONTNR) == (xFilial("EXA")+EX9->(EX9_PREEMB+EX9_CONTNR))
            AAdd(aDeleted,EXA->(EXA_SEQEMB+EXA_LOTE))
            EXA->(RecLock("EXA",.f.),DbDelete(),MsUnlock())
            EXA->(DbSkip())
         EndDo

         For i := 1 To Len(aMemos)
            If EX9->(FieldPos(aMemos[i,1])) > 0
               MSMM(EX9->&(aMemos[i,1]),,,,EXCMEMO)
            EndIf
         Next

         EX9->(RecLock("EX9",.f.),DbDelete(),MsUnlock())
      EndIf

      If lInclui .Or. lAltera .Or. lExclui
         Ae104SetOffShore() // JPM - Atualizar Off-Shore - 27/01/06
      EndIf

      If lFim
         If !lEX9Auto .And. MsgNoYes(STR0010+" "+AllTrim(M->EX9_PREEMB)+" "+STR0011) //"Encerrar carregamento do Processo "###" ?"
            cMsgCnt+= STR0024 +Replic(ENTER,2) //STR0024	"Atenção:"
            cMsgCnt+= STR0122 +ENTER//STR0122	"Esse tratamento realiza o carregamento automático mais apropriado"
            cMsgCnt+= STR0111 +Replic(ENTER,2)//STR0111	"das quantidades utilizando as informações de cada lote."
            cMsgCnt+= STR0112 +ENTER //STR0112	"As quantidades já carregadas serão apagadas pelo sistema, restando apenas"
            cMsgCnt+= STR0113 +Replic(ENTER,2)//STR0113	"o carregamento automático."
            cMsgCnt+= STR0114 +Replic(ENTER,2)//STR0114	"Veja abaixo a situação atual do carregamento deste embarque: "
            cMsgCnt+= ListItCont()
            cMsgCnt+= ENTER
            cMsgCnt+= STR0115//STR0115	"Deseja realmente encerrar automaticamente o carregamento do processo?"

            aEmb := LoadOffShore()
            ProcRegua(Len(aEmb))
            If EECView(cMsgCnt,STR0116)//STR0116	"Carregamento de Container"
               Processa({||Ae104Atu_Qtde(aEmb)},STR0012) //"Atualizando quantidades do processo..."
            Endif
         Endif
      EndIf

      If EasyEntryPoint("EECAE104")
         ExecBlock("EECAE104",.f.,.f.,{"GRV_CONTAINER",lInclui,lAltera,lExclui})   //TRP-09/01/08- Criação de ponto de entrada
      EndIf
   End Transaction

End Sequence

If Select("WRK2") > 0
   WRK2->(E_EraseArq(cNomArq2))
Endif

If Select("TRB") > 0
   TRB->(E_EraseArq(cNomArq3))
Endif

RestOrd(aOrd,.T.)

Return Nil

/*
Função      : ListItCont
Objetivos   : Exibir mensagem referente ao encerramento de carregamento de containers
Parâmetros  : Nenhum
Retorno     : cMsg
Autor       : Thiago Rinaldi Pinto
Data/Hora   : 17/07/2007
*/
Static Function ListItCont()
Local aHeaderMsg := {"EE9_SEQEMB","EE9_COD_I",{"EE9_VM_DES",,,10},"EE9_SLDINI","EXA_CONTNR",{"EXA_QTDE",,"Qtde.Carregada"},{"EXA_QTDE",,"Saldo"}}
Local aOrd := SaveOrd({"EX9", "EXA", "EE9"})
Local aDetailMsg := {}
Local cMsg := ""
Local nQtdLote := 0, nLinhaIni
Local lPrimeiraVez := .T.
Local lFound:= .F.
Begin Sequence

   EE9->(DbSetOrder(2))
   EE9->(DbSeek(xFilial()+EEC->EEC_PREEMB))
   //Busca os itens referentes ao embarque
   While EE9->(!Eof() .And. EE9_FILIAL+EE9_PREEMB == xFilial()+EEC->EEC_PREEMB)
      EX9->(DbSeek(xFilial()+EEC->EEC_PREEMB))
      While EX9->(!Eof() .And. EX9_FILIAL+EX9_PREEMB == xFilial()+EEC->EEC_PREEMB)
         //Busca o item atual (registro do EE9) no container atual (registro EX9)
         lFound := EXA->(DbSeek(xFilial()+EX9->(EX9_PREEMB+EX9_CONTNR)+EE9->EE9_SEQEMB))
         While EXA->(!Eof() .And. EXA_FILIAL+EXA_PREEMB+EXA_CONTNR+EXA_SEQEMB == xFilial()+EX9->(EX9_PREEMB+EX9_CONTNR)+EE9->EE9_SEQEMB)
            If lPrimeiraVez
               aAdd(aDetailMsg, {EE9->EE9_SEQEMB,EE9->EE9_COD_I, MsMM(EE9->EE9_DESC,10), EE9->EE9_SLDINI, EX9->EX9_CONTNR, (EXA->EXA_QTDE*EE9->EE9_QE), })//LGS-13/05/2014
               nLinhaIni := Len(aDetailMsg)
               lPrimeiraVez := .F.
            Else
               aAdd(aDetailMsg, {"","", "", , EX9->EX9_CONTNR, (EXA->EXA_QTDE*EE9->EE9_QE), })//LGS-13/05/2014
            EndIf
            nQtdLote += (EXA->EXA_QTDE*EE9->EE9_QE)
            EXA->(DbSkip())
         EndDo
         EX9->(DbSkip())
      EndDo
      If lFound
         aDetailMsg[nLinhaIni][7] := EE9->EE9_SLDINI - nQtdLote
      EndIf
      lFound := .F.
      lPrimeiraVez := .T.
      nQtdLote := 0
      EE9->(DbSkip())
   EndDo
   cMsg += EECMontaMsg(aHeaderMsg, aDetailMsg,, .F.) + ENTER

   cMsg += STR0117 +Replic(ENTER,2)//STR0117	"Com o carregamento automático teremos: "

   aEval(aDetailMsg, {|x| If(ValType(x[7]) == "N" .And. x[7] > 0, x[4] -= x[7],)  })

   aSize(aHeaderMsg, Len(aHeaderMsg) - 1)
   cMsg += EECMontaMsg(aHeaderMsg, aDetailMsg,, .F.) + ENTER

End Sequence
RestOrd(aOrd, .T.)

Return cMsg

/*
Função      : Ae104Valid
Objetivos   : Validar dados da enchoice
Parâmetros  : Nenhum
Retorno     : .T./.F.
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 16/12/05
*/
*-------------------*
Function Ae104Valid()
*-------------------*
Local lRet := .t.
Local lRetVal := .t.

Begin Sequence

   If !Obrigatorio(aGets,aTela)
      lRet := .f.
      Break
   EndIf
   //MFR 16/04/2019 OSSME-2432
   //IF Len(AddCpoUser(aTst,"EX9","2")) <= 0 //LRS - 08/01/2015
   If Len(aTst := AddCpoUser(aTst,"EX9","2")) <= 0
	   If !Empty(Posicione("EEC",1,xFilial("EEC")+M->EX9_PREEMB,"EEC_DTEMBA"))
	      EasyHelp(STR0098, STR0024) //"O processo informado já foi embarcado, portanto não poderão ser incluídos novos containers para este processo." ### "Atenção"
	      lRet := .f.
	      Break
	   EndIf
   EndIF

   If EX9->(FieldPos("EX9_PROCES")) > 0
      Posicione("EE9",2,xFilial("EE9")+M->EX9_PREEMB+M->EX9_PROCES,"EE9_SEQUEN")
      If EE9->(EoF())
         EasyHelp(STR0099, STR0024) //"Não há itens que se encontrem no pedido e no embarque informados." ### "Atenção"
         lRet := .f.
         Break
      EndIf
   EndIf

   IF EasyEntryPoint("EECAE104")
      lRetVal := ExecBlock("EECAE104", .F., .F., {"VALIDA"})   //TRP-13/11/2007- Inclusão de ponto de entrada
      IF ValType(lRetVal) == "L"
         lRet := lRetVal
      Endif
   Endif
End Sequence

Return lRet

*-----------------*
Function Ae104Det(aGridAuto)
*-----------------*
LOCAL lRet := .f.,cAlias1:="EXA", oDlg2, oGet, i
LOCAL cTitulo := STR0009+TRB->EE9_COD_I //"Carregamento do Item "
Local nOpcao
Private aCampos:={}
Private aFields := {"EXA_LOTE","EXA_QTDE","EXA_PESOLQ","EXA_PESOBR","EXA_OBS"}, nOpc := 3
Private aPos:= { 15,  1, 70, 315 }, aGets := [0], aTela := [0]
Private cAlias := "WRK", lRefresh := .T.
Private lValidaLote := .T.

Begin Sequence

    aCols      := {}
    CriaWork()
    If EECFlags("CAFE")
        aAdd(aFields,"EXA_CODARM")
    EndIf
    If EasyEntryPoint("EECAE104")
        ExecBlock("EECAE104",.f.,.f.,{"TELA_LOTES_CONTAINER"})
    EndIf

    If !lEXAAuto

        DEFINE MSDIALOG oDlg2 TITLE cTitulo FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
            nLin := 35 //18
            nCol := 07

            @ nLin,07  SAY AVSX3("EE9_COD_I",AV_TITULO) PIXEL OF oDlg2
            @ nLin,44  MSGET TRB->EE9_COD_I  PICTURE AVSX3("EE9_COD_I",AV_PICTURE) PIXEL OF oDlg2 WHEN .F. SIZE 3.5*AVSX3("EE9_COD_I",AV_TAMANHO),08
            @ nLin,164 SAY AVSX3("B1_DESC" ,AV_TITULO) PIXEL OF oDlg2
            @ nLin,204 MSGET TRB->EE9_DESC  PICTURE AVSX3("B1_DESC",AV_PICTURE) PIXEL OF oDlg2 WHEN .F. SIZE 3.5*AVSX3("B1_DESC",AV_TAMANHO),08
            
            nLin := 50 //29
            @ nLin,07  SAY AVSX3("EE9_SLDINI",AV_TITULO) PIXEL OF oDlg2
            @ nLin,44  MSGET TRB->EE9_SLDINI  PICTURE AVSX3("EE9_SLDINI",AV_PICTURE) PIXEL OF oDlg2 WHEN .F. SIZE 3.5*AVSX3("EE9_SLDINI",AV_TAMANHO),08
            @ nLin,164 SAY AVSX3("EE9_QTDEM1",AV_TITULO) PIXEL OF oDlg2
            @ nLin,204 MSGET TRB->EE9_QTDEM1 PICTURE AVSX3('EE9_QTDEM1',AV_PICTURE) PIXEL OF oDlg2 WHEN .F. SIZE 3.5*AVSX3("EE9_QTDEM1",AV_TAMANHO),08
            dbSelectArea("WRK")
            WRK->(dbGoTop())

            aPosDb := PosDlg(oDlg2)
            aPosDb[1] += 37

            If Empty(EEC->EEC_DTEMBA)
               If Wrk->(EasyRecCount() == 0) .And. (lInclui .Or. lAltera)
                  nOpcao := INCLUIR
               ElseIf Wrk->(EasyRecCount() != 0) .And. (lInclui .Or. lAltera)
                  nOpcao := ALTERAR
               Else
                  nOpcao := VISUALIZAR
               EndIf
            Else
               nOpcao := VISUALIZAR
            Endif                                                                                                                                         //MFR 18/07/2019 OSSME-3506
            WRK->(oGet:=MsGetDB():New(aPosDb[1],aPosDb[2],aPosDb[3],aPosDb[4],nOpcao,"E_LinOk","Ae104TudOk",,.T.,aFields , ,, ,"WRK", , ,.T., oDlg2, .T., ,))

        ACTIVATE MSDIALOG oDlg2 ON INIT EnchoiceBar(oDlg2,{|| If((lRet := oGet:TudoOk()),oDlg2:End(),)},{||oDlg2:End()})
    Else
        For i := 1 To Len(aGridAuto)
            if AvKeyAuto(aGridAuto)
                cLote := ""
                If (nPosLote := aScan(aGridAuto[i], {|X| Alltrim(x[1]) == "EXA_LOTE" })) > 0
                    cLote := aGridAuto[i][nPosLote][2]
                EndIf
                WRK->(DbSetOrder(1))
                If WRK->(DbSeek(TRB->EE9_SEQEMB+AvKey(cLote, "EXA_LOTE")))
                    If aScan(aGridAuto[i], {|X| Alltrim(x[1]) == "LINPOS" }) == 0
                    aAdd(aGridAuto[i], {"LINPOS", "EXA_LOTE", AvKey(cLote, "EXA_LOTE")})
                    EndIf
                    If aScan(aGridAuto[i], {|X| Alltrim(x[1]) == "AUTDELETA" .And. AllTrim(x[2]) == "S"}) > 0
                    WRK->DBDELETE := .T.
                    EndIf
                EndIf
            Else
                EasyHelp(STR0135, STR0024) //"Erro no array da capa do container."
            endif
        Next
        MsGetDBAuto("WRK", aGridAuto, "E_LINOK", "Ae104TudOk", aEX9Auto, If(IsVazio("WRK"),INCLUIR,ALTERAR))
        lRet := !lMsErroAuto
   EndIf

   If lRet .And. (lInclui .Or. lAltera)

      If lValidaLote
         If Wrk->(EasyRecCount("Wrk")) == 1 .And. Empty(Wrk->EXA_LOTE) // age em conjunto com a validação.
            Break
         EndIf
      EndIf

      Wrk->(DbsetOrder(0))//Não pode utilizar o índice com o campo EXA_SEQEMB pois o mesmo ainda será gravado no While para os novos itens
      Wrk->(dbgotop())
      While Wrk->(!Eof())
         // Trata os deletados
         If Wrk->DBDELETE
            If !Empty(Wrk->RECNO2)
               Wrk2->(DbGoTo(Wrk->RECNO2),DBDELETE := .T.)
            EndIf
            Wrk->(dbskip())
            Loop
         EndIf

         // Verifica se foi incluído ou alterado
         If !Empty(Wrk->RECNO2)
            Wrk2->(DbGoTo(Wrk->RECNO2))
         EndIf
         RecLock("WRK2",Empty(Wrk->RECNO2))
         //MFR 18/07/2019 OSSME-3506
         //If Empty(Wrk->EXA_PREEMB)
            Wrk->EXA_PREEMB:= M->EX9_PREEMB
            Wrk->EXA_CONTNR:= M->EX9_CONTNR
            Wrk->EXA_COD_I := TRB->EE9_COD_I
            WRK->EXA_SEQEMB:= TRB->EE9_SEQEMB
         //EndIf
         AvReplace("WRK","WRK2")
         
         Wrk2->(MsUnlock())
         Wrk->(dbskip())
      Enddo
   EndIf

End Sequence

If Select("WRK") > 0
   WRK->(E_EraseArq(cNomArq))
Endif

Return lRet

/*
Função      : Ae104TudOk
Objetivos   : Validar dados da MsGetDb()
Parâmetros  : Nenhum
Retorno     : .T./.F.
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 16/12/05
*/
*-------------------*
Function Ae104TudOk()
*-------------------*
Local lRet := .t., nLin := 0, nQtde := 0, nTot := Wrk->(EasyRecCount("Wrk"))
Local aLotes := {}

Begin Sequence

   DbSelectArea("Wrk")

   DbGoTop()
   While !EoF()
      nLin++
      If !DBDELETE

         If AScan(aLotes,EXA_LOTE) = 0
            AAdd(aLotes,EXA_LOTE)
         Else
            EasyHelp(STR0108,STR0024) //"Um mesmo número de lote não pode ser cadastrado 2 vezes para o mesmo item." ### "Atenção"
            lRet := .F.
            Break
         EndIf

         If nLin > 1 .Or. !Empty(RECNO2) .Or. nTot > 1
            If lValidaLote .And. Empty(EXA_LOTE)
               EasyHelp(StrTran(STR0100,"###",AllTrim(Str(nLin))), STR0024) //"O número do lote não foi informado na ###ª linha." ### "Atenção"
               lRet := .f.
               Break
            EndIf
         EndIf
         If !Empty(EXA_LOTE) .And. Empty(EXA_QTDE)
            EasyHelp(StrTran(STR0104,"###",AllTrim(Str(nLin))), STR0024) //"A quantidade não foi preenchida na ###ª linha." ### "Atenção"
            lRet := .f.
            Break
         EndIf
         nQtde += EXA_QTDE
      EndIf
      DbSkip()
   EndDo
   DbGoTop()

   If nQtde > TRB->EE9_SLDINI  
    //  EasyHelp(StrTran(STR0101+".","###",AllTrim(Transf(nQtde-TRB->EE9_SLDINI,AvSx3("EE9_SLDINI",AV_PICTURE)))), STR0024) //"A soma das quantidades informadas em cada lote excedeu em ### a quantidade da embalagem" ### "Atenção"
         EasyHelp(StrTran(STR0101+".","###",AllTrim(Transf(nQtde-TRB->EE9_SLDINI,AvSx3("EE9_QTDEM1",AV_PICTURE)))), STR0024) 
      lRet := .f.
      Break
   EndIf

   If nQtde > TRB->WK_SALDO
      EasyHelp(StrTran(STR0101+STR0102+".","###",AllTrim(Transf(nQtde-TRB->WK_SALDO,AvSx3("EE9_QTDEM1",AV_PICTURE)))), STR0024) //"A soma das quantidades informadas em cada lote excedeu em ### a quantidade da embalagem" ### "(Considerando a quantidade utilizada nos lotes de outros containers)" ###"Atenção"
      lRet := .f.
      Break
   EndIf

End Sequence

Return lRet


/*
Função     : CriaWork
Objetivos  : Carregar a work para edição na MsGetDb
Revisão    : João Pedro Macimiano Trabbold, 19/12/05 às 14:15
*/
*------------------------*
Static Function CriaWork()
*------------------------*
Local aStruct := WRK2->(dbStruct())
Begin Sequence

   cNomArq:= E_CriaTrab(,aStruct,"WRK")
   //MFR OSSME-3994 25/11/2019
   IndRegua("WRK",cNomArq+TEOrdBagExt(),"EXA_SEQEMB+EXA_LOTE")   
   Set Index to (cNomArq+TEOrdBagExt())
   Wrk->(DbsetOrder(0))

   DbSelectArea("WRK2")
    /*
   // seta filtro para que apenas sejam trazidos os lotes do item posicionado, e que não estejam deletados.
   //cF := "(Wrk2->EXA_SEQEMB == '" + TRB->EE9_SEQEMB + "' .And. Wrk2->(!DELETE))"

   IF IsSrvUNIX() // TLM  07/02/2008
      cF := "(Wrk2->EXA_SEQEMB == '" + TRB->EE9_SEQEMB + "')" //  .And. Wrk2->(!DELETE))"
   Else
      // seta filtro para que apenas sejam trazidos os lotes do item posicionado, e que não estejam deletados.
      cF := "(Wrk2->EXA_SEQEMB == '" + TRB->EE9_SEQEMB + "' .And. Wrk2->(!DELETE))"
   EndIf
   DbSetFilter(&("{|| " + cF + " }"),cF)
   DbGoTop()

   While !EoF()
      Wrk->(DbAppend())
      AvReplace("WRK2","WRK")
      Wrk->RECNO2 := Wrk2->(RecNo())
      DbSkip()
   EndDo

   DbClearFilter()
   */

   DbGoTop()
   
   While !EoF()
      If Wrk2->EXA_SEQEMB == TRB->EE9_SEQEMB
         Wrk->(DbAppend())
         AvReplace("WRK2","WRK")
         Wrk->RECNO2 := Wrk2->(RecNo())
         Wrk->(DbCommit())
      EndIf
      WRK2->(DbSkip())
   EndDo

End Sequence

Return .T.

/*
Função     : GravaEXA()
Objetivos  : Gravar dados do EXA -> lotes por container
Revisão    : João Pedro Macimiano Trabbold, 19/12/05 às 14:15
*/
*------------------------*
Static Function GravaEXA()
*------------------------*
Local i, aCont := {}, aEmb

DbSelectArea("WRK2")

// Exclui da base os registros deletados
Set Filter To Wrk2->DBDELETE == .T.

DbGoTop()
While !EoF()
   If !Empty(RECNO)
      EXA->(DbGoTo(Wrk2->RECNO),AAdd(aDeleted,EXA_SEQEMB+EXA_LOTE),RecLock("EXA",.F.),DbDelete(),MsUnlock())
   EndIf
   DbSkip()
EndDo

// Grava na base os registros Incluídos/Alterados
Set Filter To Wrk2->DBDELETE == .F.

DbGoTop()
While !EoF()
   If !Empty(Wrk2->RECNO)
      EXA->(DbGoTo(Wrk2->RECNO),RecLock("EXA",.F.))
   Else
      EXA->(RecLock("EXA",.T.))
   EndIf
   AvReplace("WRK2","EXA")
   EXA->EXA_FILIAL := xFilial("EXA")
   EXA->EXA_PREEMB := M->EX9_PREEMB
   EXA->EXA_CONTNR := M->EX9_CONTNR
   EXA->(MsUnlock())
   DbSkip()
EndDo

nRecEX9 := EX9->(recno())
lFim := .T.

// ** Verifica se o carregamento para o processo pode ser finalizado
EX9->(DbSeek(xFilial("EX9")+M->EX9_PREEMB))
While EX9->(!EoF()) .AND. EX9->(EX9_FILIAL+EX9_PREEMB) == (xFilial("EX9")+M->EX9_PREEMB)
   If !EXA->(DbSeek(xFilial("EXA")+EX9->(EX9_PREEMB+EX9_CONTNR)))
      lFim := .F.
      Exit
   EndIf
   AAdd(aCont,EX9->EX9_CONTNR)
   EX9->(dbSkip())
Enddo

EX9->(DbGoTo(nRecEX9))

If lFim
   EE9->(DbSetOrder(2))
   EE9->(DbSeek(xFilial("EE9")+M->EX9_PREEMB))
   // verifica se cada item possui lotes respectivos. Se todos os itens possuem lotes
   While EE9->(!EoF()) .And. EE9->(EE9_FILIAL+EE9_PREEMB) == (xFilial("EE9")+M->EX9_PREEMB)
      For i := 1 To Len(aCont) // verifica se possui em cada item
         lFim := .f.
         If EXA->(DbSeek(xFilial("EXA")+M->EX9_PREEMB+aCont[i]+EE9->EE9_SEQEMB))
            lFim := .T.
            Exit
         EndIf
      Next
      If !lFim
         Exit
      EndIf
      EE9->(DbSkip())
   EndDo
EndIf
// **

Return .T.

/*
Função     : Ae104Grv_Trb()
Objetivos  : Carregar dados iniciais nas works de itens e lotes
Revisão    : João Pedro Macimiano Trabbold, 19/12/05 às 14:15
*/
*----------------------------*
Static Function Ae104Grv_Trb()
*----------------------------*
Private aStruct := {}, aStruct2
Private cNomArq
Begin Sequence
   aAdd( aStruct,{ "EE9_COD_I"  ,"C", /*30*/AvSX3("EE9_COD_I" ,AV_TAMANHO), 0 } )
   aAdd( aStruct,{ "EE9_SEQEMB" ,"C", /*06*/AvSX3("EE9_SEQEMB",AV_TAMANHO), 0 } )
   aAdd( aStruct,{ "EE9_DESC"   ,"C", /*30*/AvSX3("EE9_DESC"  ,AV_TAMANHO), 0 } )
   aAdd( aStruct,{ "EE9_SLDINI" ,"N", /*15*/AvSX3("EE9_SLDINI",AV_TAMANHO), /*2*/AvSX3("EE9_SLDINI",AV_DECIMAL) } )
   aAdd( aStruct,{ "EE9_UNIDAD" ,"C", /*2*/ AvSX3("EE9_UNIDAD",AV_TAMANHO), 0 } )   //Acb - 12/11/2010
   aAdd( aStruct,{ "EE9_QTDEM1" ,"N", /*15*/AvSX3("EE9_QTDEM1",AV_TAMANHO), /*2*/AvSX3("EE9_QTDEM1",AV_DECIMAL) } )
   aAdd( aStruct,{ "WK_SALDO"   ,"N", /*15*/AvSX3("EE9_SLDINI",AV_TAMANHO), /*2*/AvSX3("EE9_SLDINI",AV_DECIMAL) } )

   aStruct:= AddWkCpoUser(aStruct,"EE9")

   If EasyEntryPoint("EECAE104") // TLM 04/01/2008
      ExecBlock("EECAE104",.F.,.F.,{"INCLUI_TRB"})
   EndIF

   cNomArq3:= E_CriaTrab(,aStruct,"TRB")
   IndRegua("TRB",cNomArq3+TEOrdBagExt(),"EE9_SEQEMB")
   Set Index to (cNomArq3+TEOrdBagExt())

   aStruct  := {}
   aStruct2 := {}
   aHeader  := {}
   DbSelectArea("SX3")
   DbSetOrder(1)
   DbSeek("EXA")
   While !Eof() .And. SX3->X3_ARQUIVO == "EXA"
      IF SX3->X3_CAMPO <> "EXA_FILIAL"
         nUsado++
         IF !(SX3->X3_CAMPO $ "EXA_PREEMB/EXA_CONTNR/EXA_COD_I /EXA_SEQEMB/EXA_PROCES/EXA_OCORRE/EXA_SALDO ")
            SX3->(AAdd(aHeader,{Trim(X3Titulo()), X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, "", X3_TIPO, "", "" }))
         ENDIF
         SX3->(AAdd(aStruct,{X3_CAMPO, X3_TIPO, X3_TAMANHO, X3_DECIMAL}))
       ENDIF
     DbSkip()
   End
   Aadd(aStruct,{"RECNO" ,"N",7,0})
   Aadd(aStruct,{"RECNO2","N",7,0}) // para que o avreplace não sobreponha....
   Aadd(aStruct,{"DBDELETE","L",1,0}) //THTS - 31/10/2017 - Este campo deve ser sempre o ultimo da Work

   aStruct2 := aStruct
   cNomArq2:= E_CriaTrab(,aStruct,"WRK2")

   EXA->(DbSetOrder(1))
   EXA->(DbSeek(xFilial("EXA")+M->EX9_PREEMB+M->EX9_CONTNR))
   While EXA->(EXA_FILIAL+EXA_PREEMB+EXA_CONTNR) == (xFilial("EXA")+M->EX9_PREEMB+M->EX9_CONTNR)
      Wrk2->(DbAppend())
      AvReplace("EXA","WRK2")
      Wrk2->RECNO := EXA->(RecNo())
      EXA->(DbSkip())
   EndDo

   EE9->( dbgotop() )
   EE9->( dbSetOrder(3) )
   EE9->( dbseek(xFilial("EE9")+M->EX9_PREEMB) )
   While EE9->( !Eof() ) .AND. EE9->(EE9_FILIAL+EE9_PREEMB) == xFilial("EE9")+M->EX9_PREEMB
      RecLock( "TRB", .T.)

      AvReplace("EE9","TRB")
      TRB->EE9_COD_I  := EE9->EE9_COD_I
      TRB->EE9_SEQEMB := EE9->EE9_SEQEMB
      TRB->EE9_DESC   := Posicione("SB1",1,xFilial("SB1")+EE9->EE9_COD_I,"B1_DESC")
      TRB->EE9_SLDINI := EE9->EE9_SLDINI
      TRB->EE9_UNIDAD := EE9->EE9_UNIDAD // Acb - 12/11/2010
      //MFR OSSME-3506 24/07/2019
      TRB->WK_SALDO   := EE9->EE9_QTDEM1 // para validar o saldo já utilizado em outros containers
/*      EXA->(DbSetOrder(2))
      EXA->(DbSeek(xFilial("EXA")+M->EX9_PREEMB +TRB->EE9_SEQEMB))
      While EXA->(EXA_FILIAL+EXA_PREEMB) == (xFilial("EXA")+M->EX9_PREEMB) .AND.; // apenas em outros containers
            EXA->EXA_SEQEMB == TRB->EE9_SEQEMB // sendo o mesmo item.
            If  M->EX9_CONTNR <> EXA->EXA_CONTNR
               TRB->WK_SALDO -= EXA->EXA_QTDE
            ENDIF
            EXA->(DbSkip())
      EndDo                                     */
      //Acb - 10/09/2010
      SIX->(DBSetOrder(1))
      If SIX->(DBSeek("EXA02"))
         EXA->(DbSetOrder(2))
         EXA->(DbSeek(xFilial("EXA")+M->EX9_PREEMB +TRB->EE9_SEQEMB))
         While EXA->(EXA_FILIAL+EXA_PREEMB) == (xFilial("EXA")+M->EX9_PREEMB) .AND.; // apenas em outros containers
            EXA->EXA_SEQEMB == TRB->EE9_SEQEMB // sendo o mesmo item.
               If  M->EX9_CONTNR <> EXA->EXA_CONTNR
                  TRB->WK_SALDO -= EXA->EXA_QTDE
               ENDIF
               EXA->(DbSkip())
         EndDo
      Else
         EXA->(DbSetOrder(1))
         EXA->(DbSeek(xFilial("EXA")+M->EX9_PREEMB))
         While EXA->(EXA_FILIAL+EXA_PREEMB) == (xFilial("EXA")+M->EX9_PREEMB)
            If  M->EX9_CONTNR <> EXA->EXA_CONTNR .And. EXA->EXA_SEQEMB == TRB->EE9_SEQEMB // sendo o mesmo item.
               TRB->WK_SALDO -= EXA->EXA_QTDE
            ENDIF
            EXA->(DbSkip())
        EndDo
      EndIf

      EXA->(DbSetOrder(1))
      TRB->EE9_QTDEM1 := EE9->EE9_QTDEM1
      If EasyEntryPoint("EECAE104") // TLM 04/01/2008
         ExecBlock("EECAE104",.F.,.F.,{"CARREGA_TRB"})
      EndIf
      TRB->( msunlock() )
      EE9->( dbskip() )
   Enddo

   TRB->( dbGotop() )

End Sequence

RETURN .T.

/*
Função     : Ae104Atu_Qtde
Objetivos  : Atualizar as quantidades dos itens no embarque de acordo com as informações de cada lote de container
Revisão    : João Pedro Macimiano Trabbold - 19/12/05
*/
*---------------------------------*
Static Function Ae104Atu_Qtde(aEmb)
*---------------------------------*
Local nQtdTotal, aOrd := SaveOrd("EEC")
Local nSaldo := 0, i

AAdd(aEmb,Nil)

For i := Len(aEmb) To 2 Step -1
   aEmb[i] := {cFilEx,aEmb[i-1]}
Next

aEmb[1] := {xFilial("EEC"),EEC->EEC_PREEMB}

EXA->(DbGoTop())
EE9->(DbSetOrder(3))
EEC->(DbSetOrder(1))

Begin Sequence

For i := 1 To Len(aEmb)
   lSaldo := (i >= 3)
   IncProc()
   EE9->(DbSeek(aEmb[i][1]+aEmb[i][2]))
   While EE9->(!EoF() .And. EE9_FILIAL+EE9_PREEMB == aEmb[i][1]+aEmb[i][2])
      nQtdTotal := 0
      EXA->(DbSeek(aEmb[i][1]+aEmb[i][2]))
      While EXA->( !Eof() ) .And. EXA->(EXA_FILIAL+EXA_PREEMB) == aEmb[i][1]+aEmb[i][2]
         If EXA->EXA_SEQEMB == EE9->EE9_SEQEMB
            nQtdTotal += (EXA->EXA_QTDE * EE9->EE9_QE)//LGS-13/05/2014
         Endif
         EXA->(DbSkip() )
      Enddo
      EE9->(DbSeek(aEmb[i][1]+aEmb[i][2]+EE9->EE9_SEQEMB)) // Posiciona no item correspondente aos lotes

      If lSaldo
         nSaldo := Posicione("EE8",1,aEmb[i][1]+EE9->(EE9_PEDIDO+EE9_SEQUEN),"EE8_SLDATU") // guarda saldo anterior
         nSaldo += EE9->EE9_SLDINI  // Restaura saldo utilizado anteriormente
      EndIf
      EE9->(RecLock("EE9", .F.))
      EE9->EE9_SLDINI := nQtdTotal
      If EE9->EE9_SLDINI % EE9->EE9_QE == 0
         EE9->EE9_QTDEM1 := (EE9->EE9_SLDINI/EE9->EE9_QE)
      Else
         EE9->EE9_QTDEM1 := (EE9->EE9_SLDINI/EE9->EE9_QE)+1
      EndIf
      If lSaldo
         nSaldo -= EE9->EE9_SLDINI // abate o saldo utilizado agora
      EndIf
      Ap101CalcPsBr(OC_EM) // Recalcula pesos líquido e bruto da linha
      EE9->(MsUnlock())
      If lSaldo
         EE8->(RecLock("EE8", .F.),(EE8_SLDATU := nSaldo),MsUnlock()) // atualiza saldo do item do pedido na base
      EndIf
      EE9->(DbSkip())
   EndDo
   EEC->(DbSeek(aEmb[i][1]+aEmb[i][2]))
   Ae105CallPrecoI(aEmb[i][1])
Next

End Sequence

RestOrd(aOrd,.T.)

Return .T.

/*
Função    : Ae104SetOffShore()
Objetivos : Atualizar filial(is) Off-Shore.
Autor     : João Pedro Macimiano Trabbold
Data/Hora : 27/01/06 - 9:15
*/
*--------------------------------*
Static Function Ae104SetOffShore()
*--------------------------------*
Local aEmbarques := LoadOffShore()
Local aOrd := SaveOrd("EX9")
Begin Sequence

   If Len(aEmbarques) > 0
      Processa({|| ProcRegua(Len(aEmbarques)),;
                   Ae104UpdateOffShore(aEmbarques)},STR0106) //"Atualizando processo(s) de Off-Shore..."
   EndIf

End Sequence

RestOrd(aOrd)

Return Nil

/*
Função    : Ae104UpdateOffShore()
Objetivos : Atualizar filial(is) Off-Shore.
Autor     : João Pedro Macimiano Trabbold
Data/Hora : 27/01/06 - 9:15
*/
*---------------------------------------*
Static Function Ae104UpdateOffShore(aEmb)
*---------------------------------------*
Local i, j, z, lAdd, lAdd2, cEmb := EEC->EEC_PREEMB, cCont := EX9->EX9_CONTNR
Local aLotes := {}, nRec := EX9->(RecNo())

Begin Sequence

   EX9->(DbClearFilter())
   EX9->(DbGoTop())

   EX9->(DbSetOrder(1))
   EX9->(DbGoTo(nRec))

   For z := 1 TO EX9->(FCount())
      M->&(EX9->(FieldName(z))) := EX9->(FieldGet(z))
   Next

   M->EX9_VM_OBS := Msmm(EX9->EX9_OBS,AvSx3("EX9_VM_OBS",AV_TAMANHO))

   EXA->(DbSetOrder(1))
   EXA->(DbSeek(xFilial()+M->(EX9_PREEMB+EX9_CONTNR)))
   While EXA->(!EoF()) .And. EXA->(EXA_FILIAL+EXA_PREEMB+EXA_CONTNR) == xFilial("EXA")+M->(EX9_PREEMB+EX9_CONTNR)
      AAdd(aLotes,EXA->(EXA_SEQEMB+EXA_LOTE))
      EXA->(DbSkip())
   EndDo

   For i := 1 To Len(aEmb)
      IncProc(AllTrim(AvSx3("EEC_PREEMB",AV_TITULO))+": "+aEmb[i])

      lAdd := EX9->(!DbSeek(cFilEx+aEmb[i]+cCont))
      If !lExclui
         EX9->(RecLock("EX9",lAdd))

         If !lAdd
            MSMM(EX9->EX9_OBS,,,,EXCMEMO)
         EndIf
         AvReplace("M","EX9")
         EX9->EX9_FILIAL := cFilEx
         EX9->EX9_PREEMB := aEmb[i]
         EX9->EX9_OBS    := ""
         EX9->(Msmm(EX9->EX9_OBS,AvSx3("EX9_VM_OBS",AV_TAMANHO),,M->EX9_VM_OBS,INCMEMO,,,"EX9","EX9_OBS"))
         EX9->(MSUnlock())
      EndIf

      For z := 1 To Len(aDeleted)
         If EXA->(DbSeek(EX9->(EX9_FILIAL+EX9_PREEMB+EX9_CONTNR)+aDeleted[z]))
            EXA->(RecLock("EXA",.F.),DbDelete(),MsUnlock())
         EndIf
      Next

      For z := 1 To Len(aLotes)
         EXA->(DbSeek(xFilial()+M->(EX9_PREEMB+EX9_CONTNR)+aLotes[z]))
         For j := 1 To EXA->(FCount())
            M->&(EXA->(FieldName(j))) := EXA->(FieldGet(j))
         Next

         lAdd2 := EXA->(!DbSeek(EX9->(EX9_FILIAL+EX9_PREEMB+EX9_CONTNR)+aLotes[z]))
         EXA->(RecLock("EXA",lAdd2))
         AvReplace("M","EXA")
         EXA->EXA_FILIAL := cFilEx
         EXA->EXA_PREEMB := aEmb[i]
         EXA->(MsUnlock())
      Next

      If lExclui .And. !lAdd
         EX9->(RecLock("EX9",.F.),DbDelete(),MsUnlock())
      EndIf

   Next

   DbSelectArea("EX9")
   Set Filter To EX9->(EX9_FILIAL+EX9_PREEMB) == cProcEmb
   DbGoTop()

End Sequence

Return Nil

/*
Funcao      : LoadOffShore()
Parametros  : Nenhum.
Retorno     : aEmbarques - Array com o nome de todas os embarques na filial de off-shore.
Objetivos   : Carregar o processo de off-shore, e se existirem, os vários níveis de off-shore.
Autor       : Jeferson Barros Jr.
Data/Hora   : 31/03/05 - 14:17.
Obs.        :
*/
*----------------------------*
Static Function LoadOffShore()
*----------------------------*
Local aRet := {}, aOrd:=SaveOrd("EEC")

Begin Sequence

   If !lIntermed
      Break
   EndIf

   EEC->(DbSetOrder(1))
   If EEC->(DbSeek(cFilEx+EEC->EEC_PREEMB))
      aAdd(aRet,EEC->EEC_PREEMB)

      /* Caso a rotina de multi Off-Shore esteja habilitada, o sistema
         irá carregar todos os níveis de off-shore. */

      If lMultiOffShore
         EEC->(DbSetOrder(14))
         cKey := cFilEx+EEC->EEC_PREEMB

         Do While EEC->(DbSeek(cKey))
            Do While EEC->(!Eof()) .And. EEC->EEC_FILIAL+EEC->EEC_PEDREF == cKey
               If !Empty(EEC->EEC_NIOFFS)
                  aAdd(aRet,EEC->EEC_PREEMB)
                  Exit
               EndIf
               EEC->(DbSkip())
            EndDo
            cKey := cFilEx+EEC->EEC_PREEMB
         EndDo
      EndIf
   EndIf

End Sequence

RestOrd(aOrd,.t.)

Return aRet


/*
Função     : AE104NFCompara
Objetivo   : Comparar iten(s) do embarque contra o(s) iten(s) da NF.
Parametros : aItens[x][1] = Dimensão com os dados do item do embarque.
                      [2] = Dimensão com as NF.
             cAlias_p     = SD2 ou EES.
             lInt_P       = Indica se a chamada da função feio da integração (IN100CLI).
Retorno    : .T. Foram encontradas divergências.
             .F. Não foram encontradas divergências.
Revisão    : 01/09/2004 às 22:26 - AMS. Permitir comparação com SD2 e EES.
             WFS 05/03/2010 - alteração da estrutura do aItens, para adição do campo Produto, devido a utilização da grade
             WFS 09/06/2010 - Tratamentos para segunda unidade de medidas.
*/

Function AE104NFCompara(cProcesso_p, cAlias_p, lInt_P)

Local lRet        := .T.
Local nPos        := 0
Local nPos2       := 0
Local cHeader     := ""
Local aSaveOrd    := SaveOrd({"SD2", "EES", "EEM"})
//Local nRegWorkIP  := If(Select("WorkIP") <> 0, WorkIP->(Recno()), 0) // By JPP - 27/04/2006 - 11:00 - Esta variavel passou a ser private
Local bTamanho
Local bWhile
Local cServer, cFrom, cPassword, cTo, cSubject, cBody, cUser
Local lEmbFaturado := .T.
Local bFor
Local aPsw
Local lTemInvoice := .F.  // GFP - 23/12/2015
Local nRecWkGrp, aFilterA, aFilterB

Private lItemcomRE  := .F.
Private lDivergPosi := .F.
Private lDivergNega := .F.
Private lItemDiverg := .F.
Private lItemNotFat := .F.
Private lTemNF      := .F.    // By JPP - 27/04/2006 - 11:30

Private aItens      := {}
Private nTotItNF    := 0
Private cMsg        := ""
Private cAlias      := If(cAlias_p = Nil, "SD2", cAlias_p)
Private lPCancel    := .F.

Private nQtdeNF     := 0
Private bQtdeNF     := {|x| nQtdeNF := If(Len(x[2]) > nQtdeNF, Len(x[2]), nQtdeNF)}
Private aTemplate   := {}
Private nTolerancia := EasyGParam("MV_AVG0075",, 1)
Private aNF         := {}
Private nVlTotNF    := 0
Private cProcesso   := cProcesso_p
Private lIntegracao := lInt_P
Private nRegWorkIP  := If(Select("WorkIP") <> 0, WorkIP->(Recno()), 0) // By JPP - 27/04/2006 - 11:00 - Esta variavel passou a ser private
Private lRecompNF   := If(ValType(lIntegracao)==NIL,.T.,!lIntegracao) .And. !lIntegra .And. AVFLAGS("EEC_LOGIX") .And. EES->(FieldPos("EES_QTDORI")) > 0 .And. AE104NFDev(EEC->EEC_PREEMB) //NCF - 11/11/2013 - Flag para permitir a Recomparaçào de NF quando alterada as quantidades na NF
Private lMostraMsg := .T. //LRS - 28/08/2017 - Variavel para mostrar a mensagem final
                                                                                                                                                                                      //                   por por motivo de NF de Devolução no outro ERP Sincronizado
If nTolerancia < 1
   nTolerancia := 1
EndIf

If lIntegracao = Nil
   lIntegracao := .F.
EndIf

SD2->(dbSetOrder(8))
EES->(dbSetOrder(1))
EEM->(dbSetOrder(1))

Begin Sequence
   If EasyEntryPoint("EECAE104") // By JPP - 20/12/2006 - 10:15 - Inclusão do ponto de entrada.
      ExecBlock("EECAE104",.f.,.f.,{"ANTES_COMPARAR_NF"})
   EndIf

   If lIntegracao
      bFor :=  {|| Empty(EE9_NF)}  // Este campo não existe na integração do contabil, esta condição de filtro só poderar ser utilizada na integração microsiga.
   EndIf
   If !lIntegracao .and. lNFCompara
      easyhelp(STR0074, STR0024) //"Comparação dos itens do embarque contra os itens da NF já efetuada."###"Atenção"
      lRet := .F.
      Break
   EndIf

   If lIntegracao
      lPCancel := Posicione("EEC", 1, xFilial("EEC")+AVKey(cProcesso, "EEC_PREEMB"), "EEC_STATUS") == ST_PC
      EE9->(dbSetOrder(3))
      EE9->(dbSeek(xFilial()+AVKey(cProcesso, "EEC_PREEMB")))
      bWhile := {|| EE9_FILIAL == xFilial() .and. EE9_PREEMB == cProcesso}
   Else
      WorkIP->(dbGoTop())
   EndIf

   If Empty(cProcesso)
      cProcesso := EEC->EEC_PREEMB
   EndIf

   /*
   AMS - 14/04/2005. Quando integrado com a Microsiga, verifica se os itens do embarque já foram faturados.
                     lIntegracao = Interface de integração do Easy.
                     lIntegra    = Integrado com faturamento da Microsiga.
   */
   If !lIntegracao .and. (lIntegra .Or. AvFlags("EEC_LOGIX"))
      WorkIp->(Eval({|x| dbGoTop(),;
                         dbEval({|| lEmbFaturado := .F.}, {|| IF(lRecompNF,!Empty(EE9_NF),Empty(EE9_NF)) }, {|| lEmbFaturado},,, .F.),;
                         dbGoTo(x)}, Recno()))
      If lEmbFaturado
         easyhelp(STR0118, STR0024)//STR0118	"Processo Ok." //STR0024	"Atenção:"
         lRet := .T.
         lNFCompara := .T.
         Break
      EndIf
   EndIf

   /*
   Comparação da qtde dos itens do embarque com a qtde dos itens da(s) NF(s).
   */
   (If(lIntegracao, "EE9", "WorkIP"))->(dbEval({|| If(IF(lRecompNF,!Empty(EE9_NF),Empty(EE9_NF)),aAdd(aItens, {{Recno(),;
                                                                  EE9_SEQEMB,;
                                                                  EE9_PEDIDO,;
                                                                  EE9_SEQUEN,;
                                                                  EE9_SLDINI,;
                                                                  EE9_RE,;
                                                                  EE9_PREEMB,;
                                                                  EE9_COD_I,; //WFS acrescentado para a realização dos tratamentos de segunda unidade de medida.
                                                                  EE9_UNIDAD,;
                                                                  EE9_NF,;
                                                                  EE9_SERIE,;
                                                                  EE9_ATOCON /*AOM - 12/09/2011*/}, {}}),)}, bFor, bWhile,,, .T.)) // By JPP - 21/03/2006 - 14:30 - a condição bFor só terá conteúdo quando for integração  Microsiga

   Processa({|| NFCompLerNF()}, STR0119, STR0120)//STR0119	"Aguarde" //STR0120	"Analisando NF(s)."


   /*
   Apresentação dos itens divergêntes na tela ou envio por e-mail.
   */
   If !Empty(cMsg)

      aAdd(aTemplate, {STR0014, "EE9_SEQEMB"}) //"Seq.Emb."
      aAdd(aTemplate, {STR0015, "EE9_PEDIDO"}) //"Pedido"
      aAdd(aTemplate, {STR0016, "EE9_SEQUEN"}) //"Seq.Ped."
      aAdd(aTemplate, {STR0017, "EE9_SLDINI"}) //"Qtde.Embarcar"
      aAdd(aTemplate, {STR0018, "EE9_SLDINI"}) //"Qtde.Faturada"
      aAdd(aTemplate, {STR0019, "EE9_SLDINI"}) //"Divergência"
      aAdd(aTemplate, {STR0020, {|| aEval(aItens, bQtdeNF), nQtdeNF*15}}) //"NF/Serie/Item"
      aAdd(aTemplate, { AVSX3("EE9_ATOCON", AV_TITULO), "EE9_ATOCON"}) //"Ato Conces."  - AOM - 14/09/2011
      aAdd(aTemplate, {STR0021, "EE9_RE"    }) //"RE"


      If lIntegracao

         cHeader   += "<Html>"
         cHeader   += "<Body style='font-family:Verdana; font-size:10pt'>"

         If lPCancel
            cHeader   += STR0063+AllTrim(cProcesso)+STR0064 //"O embarque <b>"###"</b>, está cancelado, não podendo assim efetuar a integração de suas NF."
         Else
            cHeader   += STR0065+AllTrim(cProcesso)+STR0066 //"No embarque <b>"###"</b>, foram encontradas divergências na qtde. dos itens entre a NF e o Embarque.<p>"
            cHeader   += "<Table border='1' style='font-family:Verdana; font-size:10pt'>"
            cHeader   += "<Tr style='font-weight:bold'>"

            For nPos := 1 To Len(aTemplate)
               cHeader += "<Td>"+aTemplate[nPos][1]+"</Td>"
            Next

            cHeader   += "</Tr>"
            cMsg      += "</Table>"
         EndIf

         cMsg      := cHeader + cMsg
         cMsg      += "</Body>"
         cMsg      += "</Html>"

         cServer   := EasyGParam("MV_RELSERV")
         cFrom     := EasyGParam("MV_RELACNT")
         cPassword := EasyGParam("MV_RELPSW")
         cSubject  := STR0022 //"Easy Export Control - Divergência entre NF e Embarque na integração"

         cTo       := Posicione("EEC", 1, xFilial("EEC") + AVKey(INT_NC->NNCPRO, "EEC_PREEMB"), "EEC_CODUSU")
         /*
         cUser     := Eval({|x| PswOrder(1), PswSeek(cTo, .T.), PswRet()[1][x]}, 4)
         cTo       := Eval({|x| PswOrder(1), PswSeek(cTo, .T.), PswRet()[1][x]}, 14)
         */
         If !Empty(cTo)
            PswOrder(1)
            PswSeek(cTo, .T.)
            aPsw := PswRet()
            If ValType(aPsw) == "A" .And. Len(aPsw) > 0
               cUser := aPsw[1][4]
               cTo   := aPsw[1][14]
            EndIf
         EndIf

         If Empty(cServer) .or. Empty(cFrom)// .or. Empty(cPassword) - 09/11/2004 às 16:53.
            MsgStop(STR0023, STR0024) //"O envio de e-mail na integração da NF está habitado, porem os parametros que configuram a conta de e-mail de origem não foram informados."###"Atenção"
            Break
         EndIf

         If Empty(cTo)
            MsgStop(STR0025+AllTrim(cUser)+STR0026, STR0024) //"O e-mail do usuário "###" não está cadastrado, o mesmo deve ser informado no configurador, pois foram encontradas divergências entre os dados da NF e o embarque"###"Atenção"
            Break
         EndIf

         cBody := cMsg

         CONNECT SMTP SERVER cServer ACCOUNT cFrom PASSWORD cPassword RESULT lOk

         If lOk
            SEND MAIL From cFrom To cTo SUBJECT cSubject BODY cBody RESULT lOk
            If !lOk
               MsgStop(STR0027, STR0024) //"Falha no envio do e-mail"###"Atenção"
            EndIf
            DISCONNECT SMTP SERVER
         Else
            MsgStop(STR0028+"("+cServer+")", STR0024) //"Falha na conexão com servidor de e-mail "###"Atenção"
         EndIf

         Break

      EndIf

      //bSize := {|x| If(ValType(x) = "B", Eval(x), AVSX3(x, AV_TAMANHO))}
      bSize := {|x| If(ValType(x) = "B", Eval(x), AVSX3(x,AV_TAMANHO)) +  If( Valtype(x) == "C" , If(AvSx3(x,AV_TIPO)=="N",AvSx3(x,AV_DECIMAL),0) ,0) } //NCF - 24/02/2016 - Ajuste para exibir decimais

      If lItemNotFat .and. !lItemDiverg
         cHeader += STR0070 //Näo foram encontradas NF´s para os itens do embarque ou NF´s já utilizadas em outro processo
      Else
         cHeader += STR0029 //"Foram encontradas divergências na qtde. dos itens entre a NF e o Embarque."
      EndIf

      cHeader += Replicate(ENTER, 2)

      For nPos := 1 To (Len(aTemplate) - If(lItemcomRE, 0, 1))
         cHeader += Padc(aTemplate[nPos][1], Eval(bSize, aTemplate[nPos][2])) + Space(1)
      Next

      cHeader += ENTER

      For nPos := 1 To (Len(aTemplate) - If(lItemcomRE, 0, 1))
         cHeader += Replicate("-", Eval(bSize, aTemplate[nPos][2])) + Space(1)
      Next

      cHeader += ENTER

      If !lItemNotFat

         If lItemDiverg //.and. lDivergPosi
            cMsg += Replicate(ENTER, 2) +;
                    STR0030 + ENTER +; //"Para atualizar a Qtde.Embarcar dos itens divergentes com à Qtde.Faturada,"
                    STR0031            //"escolha o botão Ok, caso contrário Cancelar."
         EndIf

         If lItemcomRE
            cMsg += Replicate(ENTER, 2) +;
                    STR0035 + ENTER +; //"Os itens com RE, serão atualizados e o mesmo deve ser feito manualmente"
                    STR0036            //"pelo usuário no SISCOMEX."
         EndIf

      Else
         If ! lTemNF  // By JPP - 02/05/2006 - 17:42
            cMsg += Replicate(ENTER, 2) +;
                    STR0037 + ENTER +; //"Foram encontrado(s) iten(s) sem NF ou a NF já foi utilizada em outro Embarque. Pelo menos um item com divergência igual à". Pelo menos um item com divergência igual à"
                    STR0038 + ENTER +; //"Não Faturado, deverá ser faturado, para dar continuidade a comparação "
                    STR0039 + Replicate(ENTER, 2) +;//"e finalizar o embarque."
                    If(EasyGParam("MV_EEC_EDC",, .F.),STR0110/*AOM - 12/09/2011*/,"")// Verifique tambem se o CFOP da Nota Fiscal condiz com a operação de regime de Drawback
         Else
            cMsg += Replicate(ENTER, 2) +;
                    STR0030 + ENTER +; //"Para atualizar a Qtde.Embarcar dos itens divergentes com à Qtde.Faturada,"
                    STR0031            //"escolha o botão Ok, caso contrário Cancelar."

         EndIf

      EndIf

      /*
      AMS - 30/11/2004 às 09:56. Implementação da consistência para identificar os itens com divergências
                                 que ultrapassem percentual de tolerância.
      */

      If !lIntegracao .and. lDivergNega

         cMsg += Replicate(ENTER, 2)
         cMsg += STR0024 + "!" //"Atenção"
         cMsg += Replicate(ENTER, 2)
         cMsg += STR0071+STR0072+LTrim(Str(nTolerancia))+STR0073 + ENTER //"A Qtde. Faturada dos itens abaixo, "###"excederam o limite de tolerância. A variação máxima permitida é de "###"%."
         cMsg += STR0121//STR0121	"Seq.Emb: "

         For nPos := 1 To Len(aItens)

            nTQtdeEmb := aItens[nPos][1][5]
            nTQtdeNF  := 0

            aEval(aItens[nPos][2], {|x| nTQtdeNF += x[2]})

//            If nTQtdeEmb-nTQtdeNF < 0

//             If ((nTQtdeEmb-nTQtdeNF) * -1) > ((nTQtdeEmb/100)*nTolerancia)
               If ABS((aItens[nPos][1][5]-nTotItNF)) > ((aItens[nPos][1][5]/100)*nTolerancia)
                  cMsg += LTrim(aItens[nPos][1][2]) + If(nPos < Len(aItens), ", ", ". ")
                  If Len(SubStr(cMsg, Rat(ENTER, cMsg)+2)) > 100 //Controle para quebra de linha.
                     cMsg += ENTER
                  EndIf
               EndIf

//            EndIf

         Next

         /*
         cMsg += Replicate(ENTER, 2) +;
                 STR0032 + ENTER +;
                 STR0033 + ENTER +;
                 STR0034
         */

      EndIf

      cMsg := cHeader + cMsg

   EndIf

   If lIntegracao
      Break
   EndIf

   If Empty(cMsg)

      If Len(aItens) = 0
         MsgStop(STR0069, STR0024) //"Não foram encontrados itens no embarque para efetuar a comparação com os itens da NF."
      Else
//       easyhelp(STR0040, STR0024) //"Processo Ok. O Processo está de acordo com a(s) NF(s)."
         If cAlias = "SD2"
            Processa({|| EE9Atualiza(), STR0043, STR0044, .F.}) //"Aguarde"###"Atualizando Itens"
         Else
            lNFCompara := .T.
         EndIf
      EndIf

//    Break  - AMS 11/05/05.

   Else   // GFP - 23/12/2015
      lTemInvoice := .F.
      If WorkInv->(EasyRecCount("WorkInv")) # 0
         cMsg += Replicate(ENTER, 2)
         cMsg += STR0024 + "!" //"Atenção"
         cMsg += Replicate(ENTER, 2)
         cMsg += STR0128  //"Existem invoices vinculadas ao processo. É necessário ajusta-las manualmente."
         lTemInvoice := .T.
      EndIf
   EndIf

   If lItemDiverg .or. lItemNotFat
      If !EECView(cMsg, STR0041) //"Divergência entre NF e Embarque"
         Break
      EndIf
   EndIf

   If lTemInvoice  // GFP - 23/12/2015
      Break
   EndIf

// If cAlias = "EES" .and. lDivergNega .and. !lDivergPosi
   /*
   If lDivergNega .and. !lDivergPosi
      Break
   EndIf
   */

   If lItemNotFat .And. cAlias = "SD2" // By JPP - 26/04/2006 - 16:00
      Break
   EndIf

   If lItemNotFat .And. cAlias = "EES" .And. !lTemNF // By JPP - 27/04/2006 - 11:30
      Break
   EndIf

   If (!Empty(cMsg) .Or. AvFlags("NFS_DESVINC")) .and. MsgYesNo(STR0042, STR0024) //"Confirma Atualização?"###"Atenção"
      Processa({|| EE9Atualiza(), STR0043, STR0044, .F.}) //"Aguarde"###"Atualizando Itens"
   EndIf

   /*
   Comparação do Vl.Total do Embarque contra o Vl.Total da NF na moeda.
   */
   If cAlias_p = "EES" .And. !AvFlags("EEC_LOGIX")
      EEM->(DbSetOrder(1))
      If EEM->(dbSeek(xFilial()+cProcesso+"N"))

         aAdd( aNF, { {M->EEC_PREEMB},;
                      {M->EEC_TOTPED},;
                      {RTrim(EEM->EEM_NRNF), Transform(EEM->EEM_SERIE, AvSx3("EEM_SERIE", AV_PICTURE))},;//{RTrim(EEM->EEM_NRNF), RTrim(EEM->EEM_SERIE)},; //RMD - 24/02/15 - Projeto Chave NF
                      {EEM->EEM_VLNFM} } ) //EEM_VLNF

         nVlTotNF += EEM->EEM_VLNFM

         EEM->(dbSkip())

         While EEM->(!Eof() .and. EEM_FILIAL == xFilial() .and. EEM_PREEMB == cProcesso .and. EEM_TIPOCA = "N")

            aAdd(aNF, {{""},;
                       {""},;
                       {RTrim(EEM->EEM_NRNF), Transform(EEM->EEM_SERIE, AvSx3("EEM_SERIE", AV_PICTURE))},;//{RTrim(EEM->EEM_NRNF), RTrim(EEM->EEM_SERIE)},; //RMD - 24/02/15 - Projeto Chave NF
                       {EEM->EEM_VLNFM}})

            nVlTotNF += EEM->EEM_VLNFM

            EEM->(dbSkip())

         End

         If nVlTotNF < (M->EEC_TOTPED-EasyGParam("MV_AVGVLMP",, 0)) .or. nVlTotNF > (M->EEC_TOTPED+EasyGParam("MV_AVGVLMP",, 0))
            cMsg := AE104NFMsg(aNF, lIntegracao, .T.)
            EECView(cMsg, STR0041)
            lNFCompara := .F.
            Break
         EndIf

      Else

         MsgStop(STR0077, STR0024) //"Não foram encontradas Notas Fiscais para o Embarque."###"Atenção"
         Break

      EndIf

   EndIf
   // EJA - 27/02/2018	
   If lConsolida
      Ap104LoadGrp() // atualiza os agrupamentos de itens
   EndIf
      //NCF - 07/03/2018
      If lConsolOffShore
         nRecWkGrp := WorkGrp->(RecNo())
         aFilterA := Ae104GrpFilter(,"WorkOpos") // seta o filtro na WorkOpos, baseado na WorkGrp
         WorkOpos->(DbGoTop())
         While WorkOpos->(!EoF())
            
            nSldIniAtu := 0

            aFilterB := Ae104GrpFilter() // seta o filtro na WorkIp, baseado na WorkGrp
            WorkIp->(DbGoTop())
            While WorkIp->(!EoF())
               nSLdIniAtu += WorkIP->EE9_SLDINI
               WorkIp->(DbSkip())
            EndDo
            EECRestFilter(aFilterB[1])

            WorkOpos->EE9_SLDINI := nSldIniAtu
            WorkOpos->WP_SLDATU  := WorkOpos->WP_OLDINI - WorkOpos->EE9_SLDINI

            If WorkOpos->EE9_SLDINI % WorkOpos->EE9_QE != 0
               WorkOpos->EE9_QTDEM1 := (WorkOpos->EE9_SLDINI/WorkOpos->EE9_QE)+1
            Else
               WorkOpos->EE9_QTDEM1 := Int(WorkOpos->EE9_SLDINI/WorkOpos->EE9_QE)
            Endif 

            WorkOpos->(DbSkip())
            
         EndDo
         EECRestFilter(aFilterA[1])
         WorkGrp->(DbGoTo(nRecWkGrp))
      EndIf
   
   If Empty(cMsg) .AND. lMostraMsg
        if (Type("lEX9Auto") <> "L" .and. Type("lEXAAuto") <> "L") .or. (Type("lEX9Auto") == "L" .And. !lEX9Auto)
                //MsgInfo(STR0040, STR0024) //"Processo Ok. O Processo está de acordo com a(s) NF(s)."###"Atenção"
                If MsgYesNo(STR0040 + ENTER + STR0129, STR0024) //"Iten(s) do embarque atualizado(s)."### "Deseja visualizar a(s) NF(s) ? ### "Atenção"
                AE100FATURA("EEC",EEC->(Recno()),2)
                EndIf
        endif
   EndIf

End Sequence

If EasyEntryPoint("EECAE104") // By JPP - 20/12/2006 - 10:15 - Inclusão do ponto de entrada.
   ExecBlock("EECAE104",.f.,.f.,{"DEPOIS_COMPARAR_NF"})
EndIf

RestOrd(aSaveOrd)

If nRegWorkIP <> 0
   WorkIP->(dbGoTo(nRegWorkIP))
EndIf

Return(lRet)


/*
Função     : AE104NFMsg()
Objetivo   : Gerar mensagem que será visualizada, informando as divergências.
Parametros : aArray       = Array onde irá receber os dados da NF.
             aArray[1]    = Dimensão com os dados do item do embarque.
                   [2]    = Dimensão com a(s) NF(s) que contemplam o item.
             lIntegracao  = .T., indica que a mensagem deve ser gerada no formato p/ envio de e-mail.
                          = .F., indica que a mensagem não deve ser gerada para envio de e-mail.
             lNF          = .T., indica que o Array contem os dados da NF.
                          = .F., indica que a Array contem os dados dos Itens da NF.
Retorno    : String no formato, apresentando a divergência entre o item e a NF.
*/

Static Function AE104NFMsg(aArray, lIntegracao, lNF)

Local cMsg     := ""
Local nPos     := 0, nPos2 := 0
Local aCmpNF   := {}

Default lNF := .F.

Begin Sequence

   If lIntegracao

      If lPCancel
         Break
      EndIf

      cMsg += "<Tr>"

      cMsg += "<Td>"+aArray[1][2]+"</Td>"
      cMsg += "<Td>"+aArray[1][3]+"</Td>"
      cMsg += "<Td>"+aArray[1][4]+"</Td>"
      cMsg += "<Td align=right>"+ TransForm(aArray[1][5], AVSX3("EE9_SLDINI", AV_PICTURE)) +"</Td>"
      cMsg += "<Td align=right>"+ TransForm(nTotItNF,     AVSX3("EE9_SLDINI", AV_PICTURE)) +"</Td>"

      If nTotItNF > 0

         cMsg += "<Td align=right>"+ TransForm((aArray[1][5] - nTotItNF), AVSX3("EE9_SLDINI", AV_PICTURE)) +"</Td>"

         cMsg += "<Td>"
         For nPos := 1 To Len(aArray[2])
            cMsg += StrTran(aArray[2][nPos][3]+"/"+aArray[2][nPos][4]+"/"+aArray[2][nPos][5], " ", "")+If(nPos < Len(aArray[2]), ", ", ".")
         Next
         cMsg += "</Td>"

      Else

         cMsg += STR0067 //"<Td>Não Faturado</Td>"
         cMsg += "<Td>&nbsp;</Td>"

      EndIf

      cMsg += "<Td>"+If(Empty(aArray[1][6]), "&nbsp;", Transform(aArray[1][6], AVSX3("EE9_RE", AV_PICTURE)))+"</Td>"

      cMsg += "</Tr>"

   Else

      If lNF

         aCmpNF := {{{"EEC_PREEMB"},            STR0078},; //"Embarque"
                    {{"EEC_TOTPED"},            STR0079},; //"Valor Total"
                    {{"EEM_NRNF", "EEM_SERIE"}, STR0080},; //"NF/Serie"
                    {{"EEM_VLNFM"},             STR0079}}  //"Valor Total"

         cMsg += STR0081 + Replicate(ENTER, 2) //"O valor total do embarque não confere com o valor total da(s) NF(s)."

         For nPos := 1 To Len(aCmpNF)
            cMsg += Padc(aCmpNF[nPos][2], FieldSize(aCmpNF[nPos][1])) + If(nPos < Len(aCmpNF), Space(1), ENTER)
         Next

         For nPos := 1 To Len(aCmpNF)
            cMsg += Replicate("-", FieldSize(aCmpNF[nPos][1])) + If(nPos < Len(aCmpNF), Space(1), ENTER)
         Next

         For nPos := 1 To Len(aArray)
            For nPos2 := 1 To Len(aCmpNF)
               cMsg += FormatValue(aCmpNF[nPos2][1], aArray[nPos][nPos2]) + If(nPos2 < Len(aCmpNF), Space(1), ENTER)
            Next
         Next

         For nPos := 1 To Len(aCmpNF)-1
            cMsg += Space(FieldSize(aCmpNF[nPos][1])+1)
         Next

         cMsg += Replicate("-", FieldSize(aCmpNF[4][1])) + ENTER

         For nPos := 1 To Len(aCmpNF)-1
            cMsg += Space(FieldSize(aCmpNF[nPos][1])+1)
         Next

         cMsg += FormatValue(aCmpNF[4][1], {nVlTotNF}) + Replicate(ENTER, 2)

         cMsg += STR0082 + ENTER +; //"A diferença entre o valor total do embarque contra valor total da(s) NF(s),"
                 STR0083+ RTrim(M->EEC_MOEDA) +" "+ AllTrim(Transform(EasyGParam("MV_AVGVLMP",, 0), AVSX3("EEC_TOTPED", AV_PICTURE))) +"." //"ultrapassou (-/+) o valor de tolerância de "

         Break

      EndIf

      cMsg += Padr(aArray[1][2], Len(aArray[1][2])) + Space(1) +;
              Padr(aArray[1][3], Len(aArray[1][3])) + Space(1) +;
              Padr(aArray[1][4], Len(aArray[1][4])) + Space(1) +;                                              //NCF - 24/02/2016 - Ajuste para exibir decimais
              Padl(Transform(aArray[1][5], AVSX3("EE9_SLDINI", AV_PICTURE)), AVSX3("EE9_SLDINI", AV_TAMANHO) + AVSX3("EE9_SLDINI", AV_DECIMAL) ) + Space(1) +;
              Padl(Transform(nTotItNF,    AVSX3("EE9_SLDINI", AV_PICTURE)), AVSX3("EE9_SLDINI", AV_TAMANHO) + AVSX3("EE9_SLDINI", AV_DECIMAL) ) + Space(1)

      aEval(aItens, bQtdeNF)

      If nTotItNF > 0

         cMsg += Padl(Transform((aArray[1][5] - nTotItNF), AVSX3("EE9_SLDINI", AV_PICTURE)), AVSX3("EE9_SLDINI", AV_TAMANHO) + AVSX3("EE9_SLDINI", AV_DECIMAL) ) + Space(1)

         For nPos := 1 To Len(aArray[2])
          //cMsg += Padr(StrTran(aArray[2][nPos][3]+"/"+aArray[2][nPos][4]+"/"+aArray[2][nPos][5], " ", "") + If(nPos < Len(aArray[2]), ", ", "."), 15)
            cMsg += StrTran(aArray[2][nPos][3]+"/"+aArray[2][nPos][4]+"/"+aArray[2][nPos][5], " ", "") + If(nPos < Len(aArray[2]), ", ", ".")
         Next

         cMsg += Space(1)

      Else

         cMsg += Padl(STR0045, AVSX3("EE9_SLDINI", AV_TAMANHO) + AVSX3("EE9_SLDINI", AV_DECIMAL) ) + Space(1) //"Não Faturado"

      EndIf

      //AOM - 14/09/2011
      If !Empty(aArray[1][12])
         cMsg += Padr(aArray[1][12], AVSX3("EE9_ATOCON", AV_TAMANHO))
      EndIF

      If !Empty(aArray[1][6])
         cMsg += Padr(Transform(aArray[1][6], AVSX3("EE9_RE", AV_PICTURE)), AVSX3("EE9_RE", AV_TAMANHO)) + Space(1)
      EndIf



      cMsg += ENTER

   EndIf

End Sequence

Return(cMsg)


/*
Função      : EE9Atualiza
Objetivo    : Atualizar a qtde. dos itens do Embarque(EE9) com a qtde. dos itens da NF(SD2).
              Os itens do embarque serão desmembrado, caso o mesmo esteja em mais de uma NF.
Autor       : Alexsander Martins dos Santos
Data e Hora : 28/07/2004 às 13:55.
*/

Static Function EE9Atualiza()

Local nPos         := 0
Local nPos2        := 0
Local nPos3        := 0
Local aSaveOrd     := SaveOrd({"EE8", "WorkIp"})
Local cNextSeqEmb  := ""
Local lFlag := .T.
Local nTotDesc     := 0
Private nTotQtdeNF := 0
Private nTotDevNF  := 0
Private lSelecaoNF := .T. //LGS-21/07/2015 - Variavel utilizada no ponto de entrada "EXIBE_TELA_SEL_NF"

EE8->(dbSetOrder(1))
WorkIp->(DBSetOrder(2))
cNextSeqEmb  := Eval({|| WorkIp->(dbGoBottom()), WorkIp->EE9_SEQEMB})

Begin Sequence

   ProcRegua(Len(aItens))

   For nPos := 1 To Len(aItens)

      IncProc()

      If Len(aItens[nPos][2]) > 0 //Verifica se o item atual possui NF.

         WorkIP->(dbGoTo(aItens[nPos][1][1]))
         If lFlag .And. cAlias = "EES" // By JPP - 27/04/2006 - 11:15 - Posicionar no primeiro registro atualizado após a conclusão da atualização.
            nRegWorkIp := WorkIp->(Recno())
            lFlag := .F.
         EndIf
         aEval(aItens[nPos][2], {|x| nTotQtdeNF += x[2]})
         aEval(aItens[nPos][2], {|x| nTotQtdeNF -= x[7]}) //ER - 07/03/2007 - Desconta a Quantidade Devolvida

		 //AAF 08/07/2015 - Ratear desconto por item na quebra de NF
		 nTotDesc := WorkIP->EE9_DESCON
		 oRatDesc := EasyRateio():New(nTotDesc,nTotQtdeNF,Len(aItens[nPos][2]),AvSX3("EE9_DESCON",AV_DECIMAL))

         /*
         AMS - 17/02/2005 às 15:29. Consistencia para não atualizar os itens com divergencia negativa.
         */
         /*
         AMS - 15/04/2005 às 17:40. Retirada a consistencia abaixo para permitir ajuste quando for divergencia negativa.
         If cAlias = "SD2" .and. aItens[nPos][1][5] < nTotQtdeNF
            If (((nTotQtdeNF-aItens[nPos][1][5])/aItens[nPos][1][5])*100) > nTolerancia
               lDivergNega := .T.
               Loop
            EndIf
         EndIf
         */

         /*
         AMS - 15/04/2005. Retirada consistencia para permitir que os itens sejam ajustados quando a divergencia ultrapassar a tolerancia.
         If (aItens[nPos][1][5] <> nTotQtdeNF .or. Len(aItens[nPos][2]) > 1) .and. !(cAlias = "EES" .and. ((aItens[nPos][1][5]-nTotQtdeNF) * -1) > ((aItens[nPos][1][5]/100)*nTolerancia))
         */
         If (aItens[nPos][1][5] <> nTotQtdeNF .or. Len(aItens[nPos][2]) > 1)

            /*
            Ponto de entrada para manipular se o sistema irá apresentar ou não a tela de Seleção de NF
            */
			IF(EasyEntryPoint("EECAE104"),Execblock("EECAE104",.F.,.F.,"EXIBE_TELA_SEL_NF"),) //LGS-21/07/2015

            /*
            Verifica se o item está envolvido em mais de um embarque.
            */
            If AP104ItemEmb(WorkIP->EE9_PEDIDO, WorkIP->EE9_SEQUEN, 2) > 1 .and. cAlias = "SD2" .and. lSelecaoNF
//              If !EE9SelecNF(aDivergencia[nPos]) // By JPP - 05/07/2006 - 16:30 - O array correto é o aItens e não o aDivergencia
                If !EE9SelecNF(aItens[nPos])
                  Break
               EndIf
            EndIf

            Begin Transaction

               /*
               Desmembramento do Item conforme o número de NF para o mesmo.
               */
               If Len(aItens[nPos][2]) > 1 .and. (cAlias = "SD2" .Or. (cAlias == "EES" .And. AvFlags("EEC_LOGIX")))

                  For nPos3 := 1 To WorkIP->(fCount())
                     M->&(WorkIP->(FieldName(nPos3))) := WorkIP->(FieldGet(nPos3))
                  Next
                  nQtdOri := M->EE9_SLDINI
                  nPsLqUnOri := M->EE9_PSLQUN
                  nPsBrUnOri := M->EE9_PSBRUN
                  If WorkIp->WP_RECNO <> 0 .And. Len(aItens[nPos][2]) > 0 
                     Eval(bTotal,"SUBTRAI")
                  EndIf

                  For nPos2 := 1 To Len(aItens[nPos][2])

                     If nPos2 > 1

                        WorkIP->(dbAppend())
                        M->EE9_SLDINI := nQtdOri
                        M->EE9_PSLQUN := nPsLqUnOri
                        M->EE9_PSBRUN := nPsBrUnOri
                        AVReplace("M", "WorkIP")

                        cNextSeqEmb        := Str(Val(cNextSeqEmb)+1, AVSX3("EE9_SEQEMB", AV_TAMANHO))
                        WorkIP->EE9_SEQEMB := cNextSeqEmb

                        WorkIP->WP_RECNO   := 0

                     EndIf

                     IF lItemDiverg .Or. lDivergPosi
                        WorkIP->EE9_SLDINI := aItens[nPos][2][nPos2][2] - aItens[nPos][2][nPos2][7]
                     EndIF
                        //NCF - 01/04/2015 - Atualiza o saldo do item com o saldo faturado nas NFs (Ex: item possui 2 notas que faturam somadas o saldo total)
                     If /*AVFLAGS("EEC_LOGIX") .and. */WorkIP->EE9_SLDINI > aItens[nPos][2][nPos2][2] //MCF - 20/10/2015
                        WorkIP->EE9_SLDINI := aItens[nPos][2][nPos2][2] - aItens[nPos][2][nPos2][7]
                     EndIf

					      //AAF 08/07/2015 - Ratear desconto por item na quebra de NF
					      WorkIP->EE9_DESCON := oRatDesc:GetItemRateio(WorkIP->EE9_SLDINI)

                     WorkIP->EE9_NF     := aItens[nPos][2][nPos2][3]
                     WorkIP->EE9_SERIE  := aItens[nPos][2][nPos2][4]
                     
                     If cAlias == "EES" .And. AvFlags("EEC_LOGIX") //NCF - 23/11/2017
                        WorkIP->EE9_FATSEQ  := aItens[nPos][2][nPos2][10]
                        AE102ESSEYY( If(!Empty(WorkIP->WP_FLAG),"1","2") ,WorkIP->EE9_PREEMB,"WORKIP")
                     EndIf

                     If EECFlags("FATFILIAL") // JPM - 27/12/05 - Geração de notas fiscais em várias filiais
                        WorkIP->EE9_FIL_NF  := aItens[nPos][2][nPos2][6]
                     EndIf
                     
                     If WorkIP->(EE9_SLDINI % EE9_QE) == 0
                        WorkIP->EE9_QTDEM1 := Int(WorkIP->(EE9_SLDINI/EE9_QE)) //QUANT.DE EMBAL.
                     Else
                       WorkIP->EE9_QTDEM1 := Int(WorkIP->(EE9_SLDINI/EE9_QE))+1 //QUANT.DE EMBAL.
                     EndIf
                     /*
                     WorkIP->EE9_PSLQTO := WorkIP->(EE9_SLDINI * EE9_PSLQUN)
                     WorkIP->EE9_PSBRTO := WorkIP->(EE9_QTDEM1 * EE9_PSBRUN) //AOM - 19/07/2010 - Alterado o calculo do peso bruto total para considerar a quantidade na embalagem
                     */
                     M->EE9_SLDINI := WorkIP->EE9_SLDINI
                     AE100CALC("PESOS")
                     WorkIp->EE9_PSLQTO := M->EE9_PSLQTO
                     WorkIp->EE9_PSBRTO := M->EE9_PSBRTO

                     //AOM - 12/09/2011
                     If WorkIP->(FIELDPOS("EE9_TES")) > 0 .And. WorkIP->(FIELDPOS("EE9_CF")) > 0
                        WorkIP->EE9_TES := aItens[nPos][2][nPos2][8]
                        WorkIP->EE9_CF  := aItens[nPos][2][nPos2][9]
                     EndIf
                     Eval(bTotal,"SOMA")
                  Next

               Else

                  /*
                  Atualização da qtde. na WorkIP(EE9).
                  */
                  IF lItemDiverg .Or. lDivergPosi
				         WorkIP->EE9_SLDINI := nTotQtdeNF
				      EndIf

                  If cAlias = "SD2"
                     WorkIP->EE9_NF     := aItens[nPos][2][1][3]
                     WorkIP->EE9_SERIE  := aItens[nPos][2][1][4]
                     If EECFlags("FATFILIAL") // JPM - 27/12/05 - Geração de notas fiscais em várias filiais
                        WorkIP->EE9_FIL_NF  := aItens[nPos][2][1][6]
                     EndIf
                  Else

                     nTotDevNF := 0
                     aEval(aItens[nPos][2],{|X| nTotDevNF += X[7]})

                     If (aItens[nPos][1][5] - nTotQtdeNF) <> 0
                        WorkIP->WP_SLDATU  := AVGSaldoItem(xFilial("EE8"), WorkIp->EE9_PEDIDO, WorkIp->EE9_SEQUEN) + (aItens[nPos][1][5] - nTotQtdeNF - nTotDevNF) //(aItens[nPos][1][5] - nTotQtdeNF) //AAF 30/06/2015 - Desconsidera quantidade devolvida (não liberar saldo para outro embarque).
                     EndIf

                     // BAK - 15/12/2011
                     If AvFlags("NFS_DESVINC") .And. WorkIP->(FieldPos("EE9_NF")) > 0 .And. WorkIP->(FieldPos("EE9_SERIE")) > 0
                        WorkIP->EE9_NF := aItens[nPos][2][1][3]
                        WorkIP->EE9_SERIE := aItens[nPos][2][1][4]
                        If cAlias == "EES" .And. AvFlags("EEC_LOGIX")  //NCF - 23/11/2017
                           WorkIP->EE9_FATSEQ  := aItens[nPos][2][1][10]
                           AE102ESSEYY( If(!Empty(WorkIP->WP_FLAG),"1","2") ,WorkIP->EE9_PREEMB,"WORKIP")                          
                        EndIf
                     EndIf

                  EndIf

                  If WorkIP->(EE9_SLDINI % EE9_QE) == 0
                     WorkIP->EE9_QTDEM1 := Int(WorkIP->(EE9_SLDINI/EE9_QE)) //QUANT.DE EMBAL.
                  Else
                     WorkIP->EE9_QTDEM1 := Int(WorkIP->(EE9_SLDINI/EE9_QE))+1 //QUANT.DE EMBAL.
                  EndIf

                  WorkIP->EE9_PSLQTO := WorkIP->(EE9_SLDINI*EE9_PSLQUN)
                  WorkIP->EE9_PSBRTO := WorkIP->(EE9_QTDEM1*EE9_PSBRUN)  //AOM - 19/07/2010 - Alterado o calculo do peso bruto total para considerar a quantidade na embalagem

                  //AOM - 12/09/2011
                  If WorkIP->(FIELDPOS("EE9_TES")) > 0 .And. WorkIP->(FIELDPOS("EE9_CF")) > 0
                     WorkIP->EE9_TES := aItens[nPos][2][1][8]
                     WorkIP->EE9_CF  := aItens[nPos][2][1][9]
                  EndIf

               EndIf

            End Transaction

         Else

            If cAlias = "SD2"
               WorkIP->EE9_NF     := aItens[nPos][2][1][3]
               WorkIP->EE9_SERIE  := aItens[nPos][2][1][4]
               If EECFlags("FATFILIAL") // JPM - 27/12/05 - Geração de notas fiscais em várias filiais
                  WorkIP->EE9_FIL_NF  := aItens[nPos][2][1][6]
               EndIf

               //AOM - 12/09/2011
               If EE9->(FIELDPOS("EE9_TES")) > 0 .And. EE9->(FIELDPOS("EE9_CF")) > 0
                  WorkIP->EE9_TES := aItens[nPos][2][1][8]
                  WorkIP->EE9_CF  := aItens[nPos][2][1][9]
               EndIf

            ElseIf cAlias == "EES" .And. AvFlags("NFS_DESVINC")
               WorkIP->EE9_NF     := aItens[nPos][2][1][3]
               WorkIP->EE9_SERIE  := aItens[nPos][2][1][4]

                If cAlias == "EES" .And. AvFlags("EEC_LOGIX") //NCF - 23/11/2017
                        WorkIP->EE9_FATSEQ  := aItens[nPos][2][1][10]
                        AE102ESSEYY( If(!Empty(WorkIP->WP_FLAG),"1","2") ,WorkIP->EE9_PREEMB,"WORKIP")
                EndIf

               If EECFlags("FATFILIAL") // JPM - 27/12/05 - Geração de notas fiscais em várias filiais
                  WorkIP->EE9_FIL_NF  := aItens[nPos][2][1][6]
               EndIf
            EndIf

         EndIf

         //THTS - 09/11/2017 - Preenche as informacoes da WorkNF quando a mesma ainda estiver vazia
         If !WorkNF->(dbSeek(EEM_NF +AvKey(WorkIP->EE9_NF,"EEM_NRNF") + AvKey(WorkIP->EE9_SERIE,"EEM_SERIE")))
             AE100WrkNF(WorkIP->EE9_PEDIDO,WorkIP->EE9_SEQUEN,WorkIP->EE9_NF,WorkIP->EE9_SERIE,WorkIp->(Ap101FilNf()))
         EndIf

      Else
         If cAlias == "EES"  // By JPP - 26/04/2006 - 16:00
            WorkIP->(dbGoTo(aItens[nPos][1][1]))
            Eval(bTiraMark)
            lItemNotFat := .F.
         EndIf
      EndIf

      nTotQtdeNF := 0
   Next

   //Atualiza os Preços.
   AE100PrecoI(.T.)
   AE100TTela(.F.)
   IF(EasyEntryPoint("EECAE104"),Execblock("EECAE104",.F.,.F.,"MOSTRA_MSG_ATU"),) //LRS -28/08/2017

   If lMostraMsg
      easyhelp(STR0046, STR0024) //"Iten(s) do embarque atualizado(s)."###"Atenção"
   EndIF

   If !lItemNotFat //.and. lDivergNega
      lNFCompara := .T.
   EndIf

End Sequence

RestOrd(aSaveOrd, .T.)
Return(Nil)


/*
Função      : EE9SelecNF
Parametro   : aEE9SD2 = Array com os dados do Item e da NF.
Objetivo    : Apresentar tela de seleção de NF(s) para o item.
Autor       : Alexsander Martins dos Santos
Data e Hora : 16/08/2004 às 13:55.
*/

Static Function EE9SelecNF(aEE9SD2)

Local lRet     := .F.
Local lInverte := .F.
Local oSldItem
Local aPos     := {79, 06, 182, 224} //{79, 06, 230, 273}
Local nCont    := 0
Local nCont2   := 0
Local nOpc     := 0
Local bOk      := {|| nOpc := 1, If(nNFSel > 0, oDlg:End(), easyhelp(STR0047, STR0024))} //"Deve ser selecionado no minimo uma NF."###"Atenção"
Local bCancel  := {|| nOpc := 0, oDlg:End()}
Local cMsg     := ""

Local aSelectFields := {{"WK_FLAG",  "XX", ""     },;
                        {"WK_DOC",   "",   "NF"   },;
                        {{|| Transform(WorkSD2->WK_SERIE, AvSx3("D2_SERIE", AV_PICTURE)) }, "",   "Serie"},; //{"WK_SERIE", "",   "Serie"},; //RMD - 24/02/15 - Projeto Chave NF
                        {"WK_ITEM",  "",   "Item" },;
                        {{||Transform(WorkSD2->WK_QTDE, AVSX3("D2_QUANT", AV_PICTURE))}, "", "Qtde"}}

/*
Geração de Work com a(s) NF(s), relacionadas ao item do WorkIP.
*/
Local aWorkSD2 := { {"WK_DOC",   "C", AVSX3("D2_DOC",   AV_TAMANHO), AVSX3("D2_DOC",   AV_DECIMAL)},;
                    {"WK_SERIE", "C", AVSX3("D2_SERIE", AV_TAMANHO), AVSX3("D2_SERIE", AV_DECIMAL)},;
                    {"WK_ITEM",  "C", AVSX3("D2_ITEM",  AV_TAMANHO), AVSX3("D2_ITEM",  AV_DECIMAL)},;
                    {"WK_QTDE",  "N", AVSX3("D2_QUANT", AV_TAMANHO), AVSX3("D2_QUANT", AV_DECIMAL)},;
                    {"WK_FLAG",  "C", 02, 00} }

Local cWorkSD2

cWorkSD2 := E_CriaTrab(, aWorkSD2, "WorkSD2")
IndRegua("WorkSD2" , cWorkSD2+TEOrdBagExt(), "WK_DOC+WK_SERIE+WK_ITEM", "AllwayTrue()", "AllwaysTrue()", STR0048) //"Gerando Indice"

EE8->(dbSeek(xFilial()+WorkIP->(EE9_PEDIDO+EE9_SEQUEN)))

Private aCampos   := {}
Private cMarca    := GetMark()
Private nSldItem  := WorkIP->EE9_SLDINI + EE8->EE8_SLDATU
Private nQtdeSel  := 0
Private nNFSel    := 0

For nCont := 1 To Len(aEE9SD2[2]) //Looping nas NF(s) do Item.
   WorkSD2->(dbAppend())
   WorkSD2->WK_DOC   := aEE9SD2[2][nCont][3]
   WorkSD2->WK_SERIE := aEE9SD2[2][nCont][4]
   WorkSD2->WK_ITEM  := aEE9SD2[2][nCont][5]
   WorkSD2->WK_QTDE  := aEE9SD2[2][nCont][2]
Next

Define MSDialog oDlg Title STR0049 From 00, 00 To 371, 455 Of oMainWnd Pixel // 471, 555 //"Seleção de NF"

   @ 015, 003 To 070, 227 Label STR0050 of oDlg Pixel //276 //"Dados do Item"

   @ 026, 008 Say STR0051 Size 80, 07 Pixel Of oDlg //"Seq.Embarque"
   @ 038, 008 Say STR0052 Size 80, 07 Pixel Of oDlg //"Qtde"
   @ 052, 008 Say STR0053 Size 80, 07 Pixel Of oDlg //"Saldo á vincular"

   @ 024, 50 MSGet WorkIP->EE9_SEQEMB    Picture AVSX3("EE9_SEQEMB", AV_PICTURE) Size 050, 07 Pixel Of oDlg When .F.
   @ 036, 50 MSGet WorkIP->EE9_SLDINI    Picture AVSX3("EE9_SLDINI", AV_PICTURE) Size 050, 07 Pixel Of oDlg When .F.
   @ 049, 50 MSGet oSldItem Var nSldItem Picture AVSX3("EE9_SLDINI", AV_PICTURE) Size 050, 07 Pixel Of oDlg When .F.

   @ 072, 003 To 185, 227 Label STR0054 of oDlg Pixel //233, 276 //"NF(s) relacionada(s) ao item"

   WorkSD2->(dbGoTop())

   oMark       := MSSelect():New("WorkSD2", "WK_FLAG",, aSelectFields, @lInverte, @cMarca, aPos)
   oMark:bAval := {|| EE9NFVLD(), oSldItem:Refresh() }

Activate MSDialog oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) Centered

If nOpc = 1
   nTotQtdeNF := nQtdeSel
   nCont := 1
   While nCont <= Len(aEE9SD2[2])
      WorkSD2->(dbSeek(aEE9SD2[2][nCont][3]+aEE9SD2[2][nCont][4]+aEE9SD2[2][nCont][5]))
      If Empty(WorkSD2->WK_FLAG)
         aDel(aEE9SD2[2], nCont)
         aSize(aEE9SD2[2], Len(aEE9SD2[2])-1)
      Else
         nCont++
      EndIf
   End
//   nCont2 := aScan(aDivergencia, {|x| x[1][1] == aEE9SD2[1][1]}) // By JPP - 05/07/2006 - 16:30 - O array correto é o aItens e não o aDivergencia
   nCont2 := aScan(aItens, {|x| x[1][1] == aEE9SD2[1][1]})

//   aDivergencia[nCont2] := aEE9SD2 // By JPP - 05/07/2006 - 16:30 - O array correto é o aItens e não o aDivergencia
   aItens[nCont2] := aEE9SD2
   lRet := .T.
EndIf

WorkSD2->(dbCloseArea())
E_EraseArq(cWorkSD2)

Return(lRet)

/*
Função  : EE9NFVLD()
Objetivo: Validar a função EE9SelecNF.
*/

Static Function EE9NFVLD()

Local lRet := .F.

Begin Sequence

   If Empty(WorkSD2->WK_FLAG)

      If EE8->EE8_SLDATU + ((WorkIP->EE9_SLDINI - (nQtdeSel + WorkSD2->WK_QTDE))) < 0
         MsgStop( STR0055, STR0024 ) //"A NF selecionada não poderá ser vinculada ao item, devido o saldo ser insuficiente."###"Atenção"
         Break
      EndIf

      nQtdeSel += WorkSD2->WK_QTDE
      nSldItem -= WorkSD2->WK_QTDE
      WorkSD2->WK_FLAG := cMarca
      nNFSel++

   Else

      nQtdeSel -= WorkSD2->WK_QTDE
      nSldItem += WorkSD2->WK_QTDE
      WorkSD2->WK_FLAG := Space(2)
      nNFSel--
   EndIf

   lRet := .T.

End Sequence

Return(lRet)

/*
Funcao      : AE104ViewHistPreCalc().
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Tela para visualização do histórico do pré-calculo.
Autor       : Jeferson Barros Jr.
Data/Hora   : 21/09/04 13:58.
Obs         :
*/
*-----------------------------*
Function AE104ViewHistPreCalc()
*-----------------------------*
Local lRet:=.f., oDlg, oMark
Local aButtons:={}, aPos:={}
Local bOk := {|| lRet:=.t.,oDlg:End()},;
      bCancel := {|| oDlg:End()}

Local cTitulo := STR0056+EXL->EXL_TABPRE //"Histórico de Pré-Calculo - Tabela: "

Begin Sequence

   If IsVazio("WorkCalc")
      Help(" ",1,"AVG0000632")
      lRet := .f.
      Break
   EndIf

   // O recálculo das despesas será realiazado no momento da alteração do processo de embarque.
   //aAdd(aButtons,{"RECALC",   {|| AE104RecalcDesp(),oMark:oBrowse:Refresh()},"Recalcular"})

   aAdd(aButtons,{"RELATORIO",{|| AE104Print()},STR0057}) //"Imprimir Doc. Detalhes das Despesas"

   WorkCalc->(DbGoTop())
   Define MsDialog oDlg Title cTitulo From 9,0 TO 34, 083 OF oMainWnd

   oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 29/12/2015 - Ajustes versão P12.
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   aPos := {33,9,136,320}

   @ 15,05 To 140,325 Label STR0075 Of oPanel Pixel //"Despesas"
   oMark := MsSelect():New("WorkCalc",,,aPreCalcBrowse,,,aPos,,,oPanel)

   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel,,aButtons) Centered

End Sequence

Return lRet

/*
Funcao      : AE104ApuraDesp().
Parametros  : lGrava - .t. - Grava work.
                       .f. - Valida tab. de despesas.
Retorno     : .t./.f.
Objetivos   : Carregar WorkCalc, com as despesas do da tabela de pre-calculo.
Autor       : Jeferson Barros Jr.
Data/Hora   : 21/09/04 17:03.
Obs         :
*/
*-----------------------------*
Function AE104ApuraDesp(lGrava)
*-----------------------------*
Local lRet:=.t.
Local j:=0
Local xDesp
Local aDespesas :={}
Local lExibeMsg:= .F.

Default lGrava := .t.

Begin Sequence

   xDesp := LoadDespesas(M->EEC_PREEMB,OC_EM,.t.)

   If ValType(xDesp) == "A"
      aDespesas := If(ValType(xDesp[1]) == "A", xDesp[1],{})

   ElseIf ValType(xDesp) == "N"
      nErro := xDesp
      cMsg  := GetMsgError(nErro)

      If !Empty(cMsg)
        if (Type("lEX9Auto") <> "L" .and. Type("lEXAAuto") <> "L") .or. (Type("lEX9Auto") == "L" .And. !lEX9Auto)
                 EECView(cMsg,STR0058,STR0076) //"Histórico de Pré-Cálculo - Validações"###"Detalhes"
        Else
                easyhelp(cMsg,STR0076)
        endif
         lRet:=.f.
         Break
      EndIf
   EndIf

   If lGrava
      For j:=1 To Len(aDespesas)
         WorkCalc->(DbAppend())
         WorkCalc->EXM_DESP   := aDespesas[j][1]
         WorkCalc->EXM_DESCR  := aDespesas[j][2]
         WorkCalc->EXM_MOEDA  := aDespesas[j][4]
         If AllTrim(aDespesas[j][4]) == "R$"
            WorkCalc->EXM_VALOR  := aDespesas[j][3]
            WorkCalc->WK_VALR    := aDespesas[j][3]
         Else
            WorkCalc->EXM_VALOR  := aDespesas[j][3]
            WorkCalc->WK_VALR    := Round(WorkCalc->EXM_VALOR*BuscaTaxa(WorkCalc->EXM_MOEDA,dDataBase,,lExibeMsg),2)
         EndIf
      Next

      If EasyEntryPoint("EECAE104")
         ExecBlock("EECAE104",.f.,.f.,{"GRV_WORKPRECALC"})
      EndIf
   EndIf

   WorkCalc->(DbGoTop())

End Sequence

Return lRet

/*
Funcao      : AE104RecalcDesp().
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Recalcular a tabela de histórico de pré-calculo.
Autor       : Jeferson Barros Jr.
Data/Hora   : 22/10/04 17:28.
Obs         :
*/
*------------------------*
Function AE104RecalcDesp()
*------------------------*
Local lRet:=.t.

Begin Sequence

   If !MsgNoYes(STR0059,STR0024) //"Confirma o recalculo das despesas ?" //"Atenção"
      lRet:=.f.
      Break
   EndIf

   WorkCalc->(DbGoTop())
   Do While WorkCalc->(!Eof())
      aAdd(aPreCalcDeletados,WorkCalc->WK_RECNO)
      WorkCalc->(DbDelete())
      WorkCalc->(DbSkip())
   EndDo

   Begin Transaction
      AP100PreCalcGrv(.f.,OC_EM)
   End Transaction

   aPreCalcDeletados := {}

   MsAguarde({|| MsProcTxt(STR0060), aE104ApuraDesp()},STR0068) //"Apurando Despesas..." //"Pré-Calculo"

   Begin Transaction
      If WorkCalc->(EasyReccount("WorkCalc")) <> 0
         Do While WorkCalc->(!Eof())
            If EXM->(RecLock("EXM",.t.))
               AVReplace("WorkCalc","EXM")
               EXM->EXM_FILIAL := xFilial("EXM")
               EXM->EXM_PREEMB := EEC->EEC_PREEMB
               EXM->(MsUnlock())

               WorkCalc->WK_RECNO := EXM->(RecNo())
            EndIf
            WorkCalc->(DbSkip())
         EndDo
      EndIf
   End Transaction

   If MsgYesNo(STR0061,STR0024) //"Deseja visualizar documento com detalhes das despesas reapuradas ?" //"Atenção"
      Ae104Print()
   EndIf

   WorkCalc->(DbGoTop())

End Sequence

Return lRet

/*
Funcao      : Ae104Print().
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Imprimir documento com detalhes do recalculo de despesas.
Autor       : Jeferson Barros Jr.
Data/Hora   : 22/10/04 18:46.
Obs         :
*/
*--------------------------*
Static Function Ae104Print()
*--------------------------*
Local lRet:=.t.

Private aCampos:=Array(EEA->(fCount())), cSeqRel

Begin Sequence

   cSeqrel :=GetSxeNum("SY0","Y0_SEQREL")
   ConfirmSx8()

   If EECPC150(.f.,.f.)
      AvgCrw32("Pc150.rpt",STR0062,cSeqRel) //"Detalhes do Recalculo de Despesas"
   EndIf

End Sequence

Return lRet

/*
Funcao      : Ae104TrataValores().
Parametros  : lApura - .t. - Verifica os valores gravados no array, aDadosPreCalc contra os valores atuais do
                             processo alterado, se existir alguma diferença, realiza a apuração das despesas.
                       .f. - Grava o aDadosPreCalc{}.
Retorno     : .t./.f.
Objetivos   : Auxiliar as funções participantes da rotina de Pré-Calculo.
Autor       : Jeferson Barros Jr.
Data/Hora   : 25/10/04 13:46.
Obs         : aDadosPreCalc por dimensao [1]  - Total do processo.
                                         [2]  - Total de comissao do tipo a remeter.
                                         [3]  - Total de comissao do tipo conta gráfica.
                                         [4]  - Total de comissao do tipo deduzir da fatura.
                                         [5]  - Código da tabela de pré-calculo.
                                         [6]  - Qtd. de Containers 20            ER - 26/07/2006
                                         [7]  - Qtd. de Containers 40            ER - 26/07/2006
                                         [8]  - Qtd. de Containers 40HC          ER - 26/07/2006
                                         [9]  - Cubagem                          ER - 26/07/2006
                                         [10] - Peso Líq. Total                  ER - 26/07/2006
*/
*--------------------------------*
Function Ae104TrataValores(lApura)
*--------------------------------*
Local lRet:=.t.
Local aAgentes:={}, aAux:={}
Local j:=0

Private lRecalc := .f.

Default lApura := .f.

Begin Sequence

   /* Verifica todos os valores por tipo de comissão presentes.
      no processo de embarque.
      Obs: A rotina considera tanto os ambientes com os tratamentos antigos para comissão, como
           o ambiente com os tratamentos novos, onde o tipo de comissão pode variar por agente
           de comissão. */

   WorkAg->(DbGoTop())
   Do While WorkAg->(!Eof())

      //  Só considera os agentes recebedores de comissao.
      If SubStr(WorkAg->EEB_TIPOAG,1,1) <> CD_AGC
         WorkAg->(DbSkip())
         Loop
      EndIf

      nPos := aScan(aAgentes,{|x| x[1] = AllTrim(WorkAg->EEB_NOME)})

      If EECFlags("COMISSAO")
         // Tratamentos para a rotina nova de comissão (Tipos diferentes de comissão para agentes distintos).

         If nPos = 0
            aAdd(aAgentes,{AllTrim(WorkAg->EEB_NOME),WorkAg->EEB_TIPCOM,WorkAg->EEB_TOTCOM})
         Else
            If aAgentes[nPos][2] == WorkAg->EEB_TIPCOM
               aAgentes[nPos][3] += WorkAg->EEB_TOTCOM
            Else
               aAdd(aAgentes,{AllTrim(WorkAg->EEB_NOME),WorkAg->EEB_TIPCOM,WorkAg->EEB_TOTCOM})
            EndIf
         EndIf
      Else
         // Considera os tratamentos antigos de comissão, apenas um tipo de comissão por processo.

         nFob := (M->EEC_TOTPED+M->EEC_DESCON)-(M->EEC_FRPREV+M->EEC_FRPCOM+M->EEC_SEGPRE+;
                                                M->EEC_DESPIN+AvGetCpo("M->EEC_DESP1")+;
                                                AvGetCpo("M->EEC_DESP2"))
         Do Case
            Case M->EEC_TIPCVL = "1" // Percentual.
                 nValCom := Round((WorkAg->EEB_TXCOMI/100)*nFob,3)
            Case M->EEC_TIPCVL = "2" // Valor Fixo.
                 nValCom := WorkAg->EEB_TXCOMI
            Case M->EEC_TIPCVL = "3" // Percentual Por item.
                 nValCom := Round((M->EEC_VALCOM/100)*nFob,3)
         Endcase

         If nPos = 0
            aAdd(aAgentes,{AllTrim(WorkAg->EEB_NOME),M->&(cAliasHd+"_TIPCOM"),nValCom})
         Else
            aAgentes[nPos][3] += nValCom
         EndIf
      EndIf

      WorkAg->(DbSkip())
   EndDo

   WorkAg->(DbGoTop())

   If !lApura
      // Realiza a gravação do array aDadosPreCalc.

      //aDadosPreCalc := {M->EEC_TOTPED,0,0,0,M->EXL_TABPRE}
      aDadosPreCalc := {M->EEC_TOTPED,0,0,0,M->EXL_TABPRE,M->EXL_QTD20,M->EXL_QTD40,M->EXL_QTD40H,M->EEC_CUBAGE,M->EEC_PESLIQ}
      For j:=1 To Len(aAgentes)
         Do Case
            Case aAgentes[j][2] = "1" // A Remeter.
                 aDadosPreCalc[2] += aAgentes[j][3]

            Case aAgentes[j][2] = "2" // Conta Gráfica.
                 aDadosPreCalc[3] += aAgentes[j][3]

            Case aAgentes[j][2] = "3" // Deduzir da Fatura.
                 aDadosPreCalc[4] += aAgentes[j][3]
         End Case
      Next
   Else

      /* Verifica se algum dado (Total do processo ou totais por tipo de comissão),
         sofreram algum tipo de alteração comparando com a situação inicial do processo
         antes das alterações, em caso positivo as alterações são reapuradas. */

      //aAux := {M->EEC_TOTPED,0,0,0,M->EXL_TABPRE}
      aAux := {M->EEC_TOTPED,0,0,0,M->EXL_TABPRE,M->EXL_QTD20,M->EXL_QTD40,M->EXL_QTD40H,M->EEC_CUBAGE,M->EEC_PESLIQ}
      For j:=1 To Len(aAgentes)
         Do Case
            Case aAgentes[j][2] = "1" // A Remeter.
                 aAux[2] += aAgentes[j][3]

            Case aAgentes[j][2] = "2" // Conta Gráfica.
                 aAux[3] += aAgentes[j][3]

            Case aAgentes[j][2] = "3" // Deduzir da Fatura.
                 aAux[4] += aAgentes[j][3]
         End Case
      Next

      /* Compara as informações iniciais contra as informações após as alterações realizadas
         pelo usuário. */
      /*
      For j:=1 To Len(aDadosPreCalc)
         If (ValType(aDadosPreCalc[j]) = "C" .And. !Empty(aAux[j])) .Or.;
             ValType(aDadosPreCalc[j]) <> "C"

            If aDadosPreCalc[j] <> aAux[j]
               lRecalc := .t.
               Exit
            EndIf
         EndIf
      Next
      */
      lRecalc := .t.

      If EasyEntryPoint("EECAE104")
         ExecBlock("EECAE104",.f.,.f.,{"RECALCULA_PRECALCULO"})
      EndIf

      If lRecalc
         /* Realiza o novo cálculo para todas as despesas do processo,  incluindo
            os dados para os diferentes tipos de comissão (no caso de rotina nova
            de comissões). */

         If WorkCalc->(EasyReccount("WorkCalc")) <> 0
            WorkCalc->(DbGoTop())
            Do While WorkCalc->(!Eof())
               aAdd(aPreCalcDeletados,WorkCalc->WK_RECNO)
               WorkCalc->(DbDelete())
               WorkCalc->(DbSkip())
            EndDo
         EndIf

         If !aE104ApuraDesp()
            lRet := .f.
            Break
         EndIf
      EndIf
   EndIf

End Sequence

Return lRet


/*
Função      : FieldSize
Objetivo    : Retornar o tamanho dos campos totalizados.
Parametros  : aFields = Array unidimensional com um ou mais campos.
Retorno     : nRet
Autor       : Alexsander Martins dos Santos
Data e Hora : 28/12/2004 às 10:00.
*/

Static Function FieldSize(aFields)

Local nRet := Len(aFields)-1

Begin Sequence

   aEval(aFields, {|Field| nRet += AVSX3(Field, AV_TAMANHO)})

End Sequence

Return(nRet)


/*
Função      : FormatValue
Objetivo    : Transformar valores de acordo com a picture no SX3.
Parametros  : aFields
              aValues
Returno     : Valor transformado de acordo com a picture do SX3.
Autor       : Alexsander Martins dos Santos
Data e Hora : 28/12/2004 às 11:47.
*/

Static Function FormatValue(aFields, aValues)

Local nPos := 0
Local cRet := ""

Begin Sequence

   For nPos := 1 To Len(aValues)

      If !Empty(aValues[nPos])
         cRet += Transform(aValues[nPos], AVSX3(aFields[nPos], AV_PICTURE))
      EndIf

      If Len(aValues) > 1 .and. nPos < Len(aValues)
         cRet += "/"
      EndIf

   Next

   Do Case

      Case ValType(aValues[1]) = "C"

         cRet := Padr(cRet, FieldSize(aFields))

      Case ValType(aValues[1]) = "N"

         cRet := Padl(cRet, FieldSize(aFields))

   End Case

End Sequence

Return(cRet)


/*
Função      : AVGSaldoItem
Parametro   : cFil       = Filial do pedido.
              cPedido    = Número do pedido.
              cSequencia = Sequencia do item no pedido.
Objetivo    : Retornar a saldo atual do item no pedido.
Autor       : Alexsander Martins dos Santos
Data e Hora : 18/04/2005 às 10:02
*/

Function AVGSaldoItem(cFil, cPedido, cItem)

Local nSaldo   := 0
Local aSaveOrd := SaveOrd("EE8", 1)

Begin Sequence

   EE8->(dbSeek(cFil+cPedido+cItem))

   nSaldo := EE8->EE8_SLDATU

End Sequence

RestOrd(aSaveOrd)

Return(nSaldo)


/*
Função      : NFCompLerNF
Objetivo    : Ler a NF(s) dos itens do embarque e configurar as flags de controle.
Retorno     : Nil
Autor       : Alexsander Martins dos Santos
Data Hora   : 18/05/2005 às 11:32.
Revisão     : WFS 05/03/2010 - Tratamentos para utilização do recurso grade de produtos
Revisão     : WFS 14/06/2010
              Inclusão de tratamento para converter a quantidade da nota fiscal conforme a quantidade
              do processo de exportação, baseado no uso da segunda unidade de medidas do cadastro do produto.
*/
*---------------------------*
Static Function NFCompLerNF()
*---------------------------*
Local aPedidos:= {}

// ** JPM - 27/12/05 - Geração de Notas Fiscais em Várias Filiais.
Local cFilNf := ""

Local nPos       := 0
Local nPos2      := 0
Local nCont      := 0
Local nSize      := 0
Local nTotDev    := 0
Local nQuant     := 0
Local nQtdDev    := 0
Local aItensTemp := {} //DFS - Inclusão de array temporário
Local lAddItens  := .F. //DFS - Criação de variável lógica para verificar se adiciona ou não no array aItensTemp
Local lNfDev     := .F.
Local lSegUnMed  := .F.
Local i
Local aAgregaIT := {} //AOM - 07/07/2011 - Vetor com os itens agregados
Local nSldDev := nQtdDev2 := nCont := j := 0 //AOM - 07/07/2011

//Local aFiliais := Ap101RetFil(), i
// **

// BAK - 15/12/2011
//lEESSemEmb - Se .T., permite buscar uma NF no EES sem que esta referencie o embarque (igual à integração com SigaFAT)
Local lEESSemEmb := .F.
Local nOrderEES := 1
Local nRecnoEES := 1
Local lCposNFDev:= EES->(FieldPos("EES_QTDORI")) > 0 .And. EES->(FieldPos("EES_QTDDEV")) > 0
Local cChaveSF2 := ""
If AvFlags("NFS_DESVINC")
   lEESSemEmb := .T.
EndIf

Private aFiliais := Ap101RetFil()

Begin Sequence

   If Type("M->EEC_PEDFAT") == "U"
      M->EEC_PEDFAT:= ""
   EndIf

   ProcRegua(Len(aItens))

   SB1->(DBSetOrder(1)) //B1_FILIAL + B1_COD
   SF2->(dbSetOrder(1)) //F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO
   For nPos := 1 To Len(aItens)

      IncProc()

      //ER - 18/10/2007
      If EasyEntryPoint("EECAE104")
         ExecBlock( "EECAE104", .F., .F., {"ALT_FILIAL"} )
      EndIf

      If cAlias = "SD2"

         //AOM - 07/07/2011 - Função responsavel por juntar itens do mesmo pedido e sequencia
                                  // Pedido           , Sequencia do Pedido , Ato Concessório
         aAgregaIT := AE104AgregaIT(aItens[nPos][1][3], aItens[nPos][1][4]  ,aItens[nPos][1][12])


         If EECFlags("INTEMB") .Or. !Empty(M->EEC_PEDFAT)
            cPedFat  := Posicione("EEC", 1, xFilial("EEC")+aItens[nPos][1][7], "EEC_PEDFAT")
            cItemFat := Posicione("EE9", 3, xFilial("EE9")+aItens[nPos][1][7]+aItens[nPos][1][2], "EE9_FATIT")
         Else
            cPedFat  := Posicione("EE7", 1, xFilial("EE7")+aItens[nPos][1][3], "EE7_PEDFAT")
            cItemFat := Posicione("EE8", 1, xFilial("EE8")+aItens[nPos][1][3]+aItens[nPos][1][4], "EE8_FATIT")
         EndIf

         //WFS 02/07/09 - tratamento para considerar as devoluções / novos pedidos quando
         //usado o fluxo alternativo de integração - EECFlags("INTEMB").
         AAdd(aPedidos, {cPedFat, cItemFat})
            EXD->(DBSetOrder(1)) //EXD_FILIAL + EXD_PREEMB + EXD_SEQEMB + EXD_ITEM + EXD_PEDFAT + EXD_ITEMPV
            If EXD->(DBSeek(xFilial() + AvKey(aItens[nPos][1][7], "EXD_PREEMB") +;
                                        AvKey(aItens[nPos][1][2], "EXD_SEQEMB")))

               //Acrescenta todas as devoluções ou novos pedidos gerados para o item do embarque
               While EXD->(!EOF() .And. EXD_PREEMB == AvKey(aItens[nPos][1][7], "EXD_PREEMB"))
                  If EXD->EXD_SEQEMB == AvKey(aItens[nPos][1][2], "EXD_SEQEMB")
                     AAdd(aPedidos, {EXD->EXD_PEDFAT, EXD->EXD_ITEMPV})
                  EndIf
                  EXD->(DBSkip())
               End

            EndIf

         //EndIf

         For i := 1 To Len(aFiliais)
            cFilNf   := aFiliais[i]

            //WFS 02/07/09 ---
            For nCont:= 1 To Len(aPedidos)

               cPedFat:= AvKey(aPedidos[nCont][1], "D2_PEDIDO")
               cItemFat:= AvKey(aPedidos[nCont][2], "D2_ITEMPV")

               lAddItens:= .F.

               // ---

               //WFS 14/06/2010
               //Tratamento para quando usada a segunda unidade de medidas do cadastro do produto
               lSegUnMed:= .F.
               If SB1->(DBSeek(xFilial() + AvKey(aItens[nPos][1][8], "B1_COD")))
                  lSegUnMed:= IIf(AllTrim(aItens[nPos][1][9]) == AllTrim(SB1->B1_SEGUM), .T., .F.)
               EndIf

               SD2->(dbSeek(cFilNf + cPedFat + cItemFat))
               aItensTemp := {}
               While SD2->(!Eof() .and. D2_FILIAL == cFilNf .and. D2_PEDIDO == cPedFat .and. D2_ITEMPV == cItemFat)
                  nQuant := 0
                  nQtdDev:= 0
                  If cChaveSF2 != cFilNf + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA + SD2->D2_FORMUL + SD2->D2_TIPO //quando mudar de nota na SD2, deve reposicionar a SF2
                     cChaveSF2 := cFilNf + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA + SD2->D2_FORMUL + SD2->D2_TIPO
                     SF2->(dbSeek(cChaveSF2))
                  EndIf
                  If (Empty(SD2->D2_PREEMB) .Or. (SD2->D2_PREEMB == aItens[nPos][1][7])) .And. !(!Empty(SF2->F2_HAWB) .And. AvKey(SF2->F2_HAWB,"EEC_PREEMB") != M->EEC_PREEMB)

                     //AOM - 12/09/2011 - Verifica se CF é o mesmo utilizado na NF
                     If EasyGParam("MV_EEC_EDC",, .F.) .And. !Empty(aItens[nPos][1][12]) .And. ;
                        !Empty(AllTrim(EasyGParam("MV_EEC0006",,""))) .And. !Empty(AllTrim(EasyGParam("MV_EEC0007",,"")))

                        If !(AllTrim(SD2->D2_TES) $ EasyGParam("MV_EEC0006") .And. ;
                           AllTrim(SD2->D2_CF) $ EasyGParam("MV_EEC0007"))
                           SD2->(DbSkip())
                           Loop
                        EndIf

                     EndIf


                     //WFS 14/06/2010
                     //Tratamento para quando usada a segunda unidade de medidas do cadastro do produto
                     nQuant := SD2->D2_QUANT
                     nQtdDev:= SD2->D2_QTDEDEV
                     If lSegUnMed
                        SegUnidadeAE104(, @nQuant,, @nQtdDev)
                     EndIf

                     //DFS - Tratamento para verificar se a comparação de NF's está correta
                     If nQuant == aItens[nPos][1][5]

                        aAdd(aItens[nPos][2], {SD2->(Recno()),;
                                                  ;//SD2->D2_QUANT,; nopado por WFS em 14/06/2010
                                                  nQuant,;
                                                  SD2->D2_DOC,;
                                                  SD2->D2_SERIE,;
                                                  SD2->D2_ITEM,;
                                                  SD2->D2_FILIAL,;
                                                  ;//SD2->D2_QTDEDEV}) nopado por WFS em 14/06/2010
                                                  nQtdDev,;
                                                  SD2->D2_TES,;//AOM - 12/09/2011
                                                  SD2->D2_CF})//AOM - 12/09/2011
                        nTotItNF := nQuant
                        nTotDev  := nQtdDev
                        lAddItens := .F.
                        Exit

                     //AOM - 07/07/2011 - Adicionar as Notas para comparação nos itens agregados
                     ElseIf Len(aAgregaIT) > 0 .And. nQuant == aAgregaIT[1][1]//Qtd somada dos itens agregados

                        If Len(aItens[nPos][2]) == 0//Verifica se foi associada a NF

                           nSldDev := nQtdDev

                           For nCont := 1 To Len(aAgregaIT[1][2])

                              //Indica a Posição do Item
                              j :=  aAgregaIT[1][2][nCont]

                              nQtdDev2:= aItens[j][1][5]

                              If nSldDev > aItens[j][1][5]
                                 nSldDev -= nQtdDev2
                              Else
                                 nQtdDev2 := nSldDev
                              EndIf

                              aAdd(aItens[j][2], {SD2->(Recno()),;
                                                     ;//SD2->D2_QUANT,; nopado por WFS em 14/06/2010
                                                     aItens[j][1][5],;
                                                     SD2->D2_DOC,;
                                                     SD2->D2_SERIE,;
                                                     SD2->D2_ITEM,;
                                                     SD2->D2_FILIAL,;
                                                     ;//SD2->D2_QTDEDEV}) nopado por WFS em 14/06/2010
                                                     nQtdDev2,;
                                                     SD2->D2_TES,;//AOM - 12/09/2011
                                                     SD2->D2_CF})//AOM - 12/09/2011})

                           Next nCont

                        EndIf

                        nTotItNF  := aItens[nPos][1][5]//Qtd utilizada
                        nTotDev   := nQtdDev
                        lAddItens := .F.
                        Exit

                     Else
                        If (nPos2 := aScan(aItensTemp, {|x| x[3] == SD2->D2_DOC   .and.;
                                                                     x[4] == SD2->D2_SERIE .and.;
                                                                     x[6] == SD2->D2_FILIAL})) = 0

                           aAdd(aItensTemp, {SD2->(Recno()),;
                                                  ;//SD2->D2_QUANT,; nopado por WFS em 14/06/2010
                                                  nQuant,;
                                                  SD2->D2_DOC,;
                                                  SD2->D2_SERIE,;
                                                  SD2->D2_ITEM,;
                                                  SD2->D2_FILIAL,;
                                                  ;//SD2->D2_QTDEDEV}) nopado por WFS em 14/06/2010
                                                  nQtdDev,;
                                                  SD2->D2_TES,;//AOM - 12/09/2011
                                                  SD2->D2_CF})//AOM - 12/09/2011})
                                                  lAddItens := .T.

                        Else
                           /*nopado por WFS em 14/06/2010
                           aItens[nPos][2][nPos2][2] += SD2->D2_QUANT
                           aItens[nPos][2][nPos2][7] += SD2->D2_QTDEDEV*/
                           aItensTemp[nPos2][2] += nQuant
                           aItensTemp[nPos2][7] += nQtdDev
                        EndIf
                     Endif
                  EndIF
                  /*
                     nTotItNF += nQuant
                     nTotDev  += nQtdDev
                  Else
                     nTotItNF += SD2->D2_QUANT
                     nTotDev  += SD2->D2_QTDEDEV
                  EndIf
                  */
                  nTotItNF += nQuant
                  nTotDev  += nQtdDev
                  /*nopado por WFS em 14/06/2010
                  nTotItNF += SD2->D2_QUANT
                  nTotDev  += SD2->D2_QTDEDEV*/
                  SD2->(dbSkip())
               EndDo
               //DFS - Se retornar .T., adiciona os campos no aItensTemp
               If lAddItens
                  aItens[nPos][2]:= AClone(aItensTemp)
               Endif
            Next
         Next

      Else
         If !lEESSemEmb

	         EES->(dbSeek(xFilial()+AVKey(cProcesso, "EES_PREEMB")))
	         If EEM->(FieldPos("EEM_CNPJ")) > 0 .And. EES->(FieldPos("EES_CNPJ")) > 0 // If FieldPos("EEM_CNPJ") > 0 .And. FieldPos("EES_CNPJ") > 0 // BAK - 13/12/2011
	            EEM->(DbSetOrder(3))
	         EndIf
	         While EES->(!Eof() .and. EES_FILIAL == xFilial() .and. EES_PREEMB == AVKey(cProcesso, "EES_PREEMB"))
	            If EEM->(FieldPos("EEM_CNPJ")) > 0 .And. EES->(FieldPos("EES_CNPJ")) > 0
	               EEM->(DbSeek(xFilial("EEM")+EES->(EES_CNPJ+EES_NRNF+EES_SERIE))) // By JPP - 21/03/2006 - 15:00
	               If EEM->EEM_TIPONF == EEM_CP // EEM_TIPONF = "2" - Nota fiscal complementar
	                  EES->(dbSkip())
	                  Loop
	               EndIf
	            EndIf
	            If EES->EES_PEDIDO == aItens[nPos][1][3] .and. EES->EES_SEQUEN == aItens[nPos][1][4] //2
	               If (nPos2 := aScan(aItens[nPos][2], {|x| x[3] == EES->EES_NRNF .and.;
	                                                        x[4] == EES->EES_SERIE  .and.;
	                                                        x[10] == EES->EES_FATSEQ })) = 0  //NCF - 23/11/2017
	                  aAdd(aItens[nPos][2], {EES->(Recno()),;
	                                       /*EES->EES_QTDE*/If(lCposNFDev,If( EES->EES_QTDE < EES->EES_QTDORI  , EES->EES_QTDORI  , EES->EES_QTDE ),0),;     //NCF - 17/04/2015
	                                         EES->EES_NRNF,;
	                                         EES->EES_SERIE,;
	                                         EES->EES_COD_I,;
	                                         EES->EES_FILIAL,;
	                                         If(lCposNFDev,EES->EES_QTDDEV,0),;
	                                         "",;
	                                         "",;
	                                         EES->EES_FATSEQ})
	               Else
	                  aItens[nPos][2][nPos2][2] += EES->EES_QTDE
	               EndIf

	               nTotItNF += /*EES->EES_QTDE*/ If(lCposNFDev , If( EES->EES_QTDE < EES->EES_QTDORI  , EES->EES_QTDORI  , EES->EES_QTDE ) , EES->EES_QTDE)  //NCF - 17/04/2015
	               nTotDev  += If(lCposNFDev,  If( WorkIP->EE9_SLDINI - EES->EES_QTDDEV == EES->EES_QTDE, 0, EES->EES_QTDDEV)    ,0)
	               lTemNF := .T.    // By JPP - 27/04/2006 - 11:30

	            EndIf

	            EES->(dbSkip())

	         End
         Else
            //BAK - 15/12/2011 - Busca NFs no EES sem que estas estejam referenciadas a um embarque
            nOrderEES := EES->(IndexOrd())
            nRecnoEES := EES->(Recno())
            EES->(DbSetOrder(4))
            If EES->(dbSeek(xFilial()+AvKey(aItens[nPos][1][3], "EES_PEDIDO")+AvKey(aItens[nPos][1][4], "EES_SEQUEN")))
               Do While !EES->(Eof()) .And. EES->EES_PEDIDO == aItens[nPos][1][3] .And. EES->EES_SEQUEN == aItens[nPos][1][4]

                  If !Empty(EES->EES_PREEMB) .And. EES->EES_PREEMB <> M->EEC_PREEMB  // NCF - 13/06/2016 - ignorar quantidades já vinculadas em outro embarque.
                     EES->(DbSkip())
                     Loop
                  EndIf
                  /*If lCposNFDev .And. EES->EES_QTDORI == EES->EES_QTDDEV            //  NCF - 14/06/2016 - ignorar quantidades totalmente devolvidas
                     EES->(DbSkip())
                     Loop
                  EndIf*/
                  If (nPos2 := aScan(aItens[nPos][2], {|x| x[3] == EES->EES_NRNF .and. x[4] == EES->EES_SERIE .and. x[10] == EES->EES_FATSEQ})) = 0

                     aAdd(aItens[nPos][2], {EES->(Recno()),;
	                                      /*EES->EES_QTDE*/If(lCposNFDev,If( EES->EES_QTDE < EES->EES_QTDORI  , EES->EES_QTDORI  , EES->EES_QTDE ),0),;     //NCF - 17/04/2015
	                                        EES->EES_NRNF,;
	                                        EES->EES_SERIE,;
	                                        EES->EES_COD_I,;
	                                        EES->EES_FILIAL,;
	                                        If(lCposNFDev,EES->EES_QTDDEV,0),;
	                                        "",;
	                                        "",;
	                                        EES->EES_FATSEQ})
   	              Else
                     aItens[nPos][2][nPos2][2] += EES->EES_QTDE
                  EndIf
                  nTotItNF += /*EES->EES_QTDE*/ If(lCposNFDev , If( EES->EES_QTDE < EES->EES_QTDORI  , EES->EES_QTDORI  , EES->EES_QTDE ) , EES->EES_QTDE)   //NCF - 17/04/2015
                  nTotDev  += If(lCposNFDev,  If( WorkIP->EE9_SLDINI - EES->EES_QTDDEV == EES->EES_QTDE, 0, EES->EES_QTDDEV)    ,0)
	              lTemNF := .T.    // By JPP - 27/04/2006 - 11:30
	              EES->(DbSkip())
               EndDo
            EndIf
            EES->(DbSetOrder(nOrderEES))
            EES->(DbGoTo(nRecnoEES))
            //***
         EndIf

      EndIf

      /*
      Verifica se a qtde total do item na(s) NF(s) é diferente da qtde no embarque.
      */
      //WFS 02/07/09 ---
      nTotItNF:= nTotItNF - nTotDev

      //Quando a quantidade devolvida for igual a quantidade total do item,
      //não será realizada a quebra do item no embarque
      For nCont:= 1 To Len(aItens[nPos][2])
         If aItens[nPos][2][nCont] == Nil
            Exit
         EndIf
         If aItens[nPos][2][nCont][2] == aItens[nPos][2][nCont][7] //D2_QUANT == D2_QTDEDEV
            aDel(aItens[nPos][2], nCont)
            nSize++
            nCont--
         EndIf
      Next
      //Redimensionamento do array
      aSize(aItens[nPos][2], (Len(aItens[nPos][2]) - nSize))
      //---
      If nTotItNF <> aItens[nPos][1][5]

         /*
         Caso a divergencia seja maior que o valor de tolerancia é apresentada a mensagem.
         cMsg += AE104NFMsg(aItens[nPos], lIntegracao)
         */
         If ABS((aItens[nPos][1][5]-nTotItNF)) > ((aItens[nPos][1][5]/100)*nTolerancia)
            cMsg += AE104NFMsg(aItens[nPos], lIntegracao)
         EndIf

         If nTotItNF = 0

            lItemNotFat := .T.

         Else
            // Divergencia                          Tolerancia.
            If ABS((aItens[nPos][1][5]-nTotItNF)) > ((aItens[nPos][1][5]/100)*nTolerancia)
               lDivergNega := .T.
			   lItemDiverg := .T.
            Else
               lDivergPosi := .T.
            EndIf

        EndIf

      EndIf

      If !Empty(aItens[nPos][1][6])
         lItemcomRE := .T.
      EndIf

      nTotItNF:= 0

      //WFS 03/07/09
      aPedidos:= {}
      If EECFlags("INTEMB") .Or. !Empty(M->EEC_PEDFAT) .Or. (AVFLAGS("EEC_LOGIX") .And. lCposNFDev ) //NCF - 17/04/2015
         nTotDev:= 0
         nSize:= 0
      EndIf

   Next

End Sequence

Return(Nil)

/*------------------------------------------------------------------------------*
  Início das rotinas de Controle de Quantidades entre Filiais Brasil e Off-Shore
 *------------------------------------------------------------------------------*/

/*
Função      : Ae104LoadOpos()
Objetivos   : Carregar work de itens da filial oposta
Parâmetros  : cPedido
Retorno     : Nenhum
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 21/10/05 às 9:55
Obs.        :
*/
*-----------------------------*
Function Ae104LoadOpos(cPedido)
*-----------------------------*
Local aOrd := SaveOrd({"WorkIp","WorkOpos","EE8","EE9","EE7"}), i, j
Local aPedidos := {}

Begin Sequence
   WorkOpos->(DbClearFilter())
   If cPedido = Nil // carrega do EE9 da filial oposta (ao carregar o embarque)
      EE9->(DbSetOrder(2))
      EE9->(DbSeek(cFilOpos+M->EEC_PREEMB))
      While EE9->(EE9_FILIAL+EE9_PREEMB) == (cFilOpos+M->EEC_PREEMB)
         If AScan(aPedidos,EE9->EE9_PEDIDO) = 0
            AAdd(aPedidos,EE9->EE9_PEDIDO)
         EndIf
         WorkOpos->(DbAppend())
         AvReplace("EE9","WorkOpos")
         WorkOpos->WP_FLAG    := cMarca
         WorkOpos->(WP_OLDINI := EE9_SLDINI)
         WorkOpos->EE9_VM_DES := MSMM(WorkOpos->EE9_DESC,AvSx3("EE9_VM_DES", AV_TAMANHO))
         WorkOpos->WP_SLDATU  := Posicione("EE8",1,cFilOpos+EE9->(EE9_PEDIDO+EE9_SEQUEN),"EE8_SLDATU")
         WorkOpos->WP_RECNO   := EE9->(RecNo())
         EE9->(DbSkip())
      EndDo

      For i := 1 To Len(aPedidos)
         EECPME01(aPedidos[i])// carrega os itens que estão desmarcados.
      Next

   Else // carrega do EE8 da filial oposta (ao selecionar um processo)

      EE8->(DbSeek(cFilOpos+cPedido))

      Do While EE8->(!EoF()) .And. EE8->(EE8_FILIAL+EE8_PEDIDO) == (cFilOpos+cPedido)

         If !WorkOpos->(dbSeek(cPedido+EE8->EE8_SEQUEN))

            If EE8->EE8_SLDATU == 0
               lConsiste := .t.
               If SB1->(FieldPos("B1_REPOSIC")) > 0
                  IF Posicione("SB1",1,xFilial("SB1")+EE8->EE8_COD_I,"B1_REPOSIC") $cSim
                     lConsiste := .f.
                  Endif
               Endif
               If lConsiste
                  EE8->(DbSkip())
                  Loop
               Endif
            Endif

            WorkOpos->(DbAppend())

            For i:=1 To EE8->(FCount())
               cField := EE8->(FieldName(i))
               bGetSetEE8:=FieldWBlock(cField,Select("EE8"))

               cFieldEE9:="EE9"+SubStr(AllTrim(cField),4)
               bGetSetEE9:=FieldWBlock(cFieldEE9,Select("WorkOpos"))

               IF ( WorkOpos->(FieldPos(cFieldEE9))#0)
                  Eval(bGetSetEE9,Eval(bGetSetEE8))
               Endif
            Next i

            For j := 1 To Len(aMemoItem)
               cCampoCod := "EE8"+Substr(aMemoItem[j,1],4,7)
               cCampoMem := "EE8"+Substr(aMemoItem[j,2],4,7)
               If EE8->(Fieldpos(cCampoCod)) > 0 .And. AvSX3(cCampoMem,,,.t.) .And.;
                  EE9->(Fieldpos(aMemoItem[j,1])) > 0 .And. AvSX3(aMemoItem[j,2],,,.t.)
                  WorkOpos->&(aMemoItem[j,2]) := EasyMSMM(&("EE8->"+cCampoCod),AVSX3(cCampoMem)[AV_TAMANHO],,,LERMEMO,,,"EE8",cCampoCod)   //AAF/NCF - 13/09/2013 - Ajustes para melhora de performance Integ. Pedido Expo. Msg. Unica
               EndIf
            Next

            WorkOpos->EE9_SLDINI := 0
            WorkOpos->WP_SLDATU  := EE8->EE8_SLDATU
            WorkOpos->WP_FLAG    := ""

         EndIf

         EE8->(DbSkip())
      EndDo

   EndIf

End Sequence

RestOrd(aOrd,.t.)

Return Nil

/*
Função      : Ae104GrpFilter()
Objetivos   : Setar filtro na WorkIp para ajustá-la ao regitro posicionado da WorkGrp
Parâmetros  : cFiltro -> Algum filtro adicional
              cWork   -> Work na qual será setado o filtro
Retorno     : 2 Arrays retornados pela EECSaveFilter, um com o filtro anterior, outro com o filtro que acabou de ser setado
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 24/10/05 às 10:45
Obs.        : cConsolida, bConsolida, bGrpFilter já devem estar declarados como private.
*/
*------------------------------------*
Function Ae104GrpFilter(cFiltro,cWork)
*------------------------------------*
Local aBk, cFilter, bFilter
Local cVar1, cVar2
Default cWork := "WorkIp"

Begin Sequence
   If cWork = "WorkIp"
      cVar1 := "bConsolida"
      cVar2 := "cGrpFilter"
   Else
      cVar1 := "b2Consolida"
      cVar2 := "c2GrpFilter"
   EndIf

   aBk := EECSaveFilter(cWork)
   cConsolida := Ap104StrCpos(aConsolida)
   &(cVar1) := &("{|| "+cWork+"->(Ap104SeqIt("+If(cWork=="WorkOpos",",'"+cFilOpos+"'","")+") + " + cConsolida + ") }")
   &(cVar2) := WorkGrp->(EE9_PEDIDO+EE9_ORIGEM+&(cConsolida))
   // Filtro para que só sejam considerados os itens que pertençam à consolidação
   cFilter := "("+cVar2+" == Eval("+cVar1+")) " + If(!Empty(cFiltro),".And. (" + cFiltro + ")","")
   bFilter := &("{||" + cFilter + "}")
   (cWork)->(DbSetFilter(bFilter, cFilter))
   (cWork)->(DbGoTop())

End Sequence

Return {aBk,EECSaveFilter(cWork)}

/*
Função      : Ae104LoadArrays()
Objetivos   : Carregar arrays que serão usados na consolidação de itens (enchoice e msgetdb)
Parâmetros  : cFil - Filial
              aCposDif,aCposGd,aHeader devem ser passados por referencia
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 25/10/05 às 9:42
Obs.        :
*/
*-----------------------------------------------------*
Function Ae104LoadArrays(cFil,aCposDif,aCposGd,aHeader)
*-----------------------------------------------------*
Local aCposShow, i

Default cFil := xFilial("EE9")

// ** variáveis para o ponto de entrada
Private cFilBrowse := cFil, cFilLogada := cFilAtu
Private aCposDif2, aCposShow2
// **

Begin Sequence
   aCposGd := {}

   If cFil == cFilAtu
      aCposDif := {"WP_FLAG   ","EE9_SEQUEN","EE9_SEQEMB","EE9_SLDINI","WP_SLDATU ","EE9_QTDEM1","EE9_PRECO ",;
                   "EE9_PRECOI","EE9_PSBRTO","EE9_DTRV  ","EE9_RE    ","EE9_DTRE  ","EE9_ATOCON",;
                   "EE9_SEQED3","EE9_RV    ","EE9_PRCTOT","EE9_PSLQTO","EE9_TOTAL ","EE9_SEQSIS","EE9_PRCINC",;
                   "EE9_NF    ","EE9_SERIE ","EE9_FASEDR","EE9_QT_AC ","EE9_VL_AC ","EE9_ISENTO",;
                   "EE9_SALISE","EE9_VM_DRE","WP_OLDINI ","EE9_NRSD  ","EE9_DTAVRB"}

      If EECFlags("CAFE")
         If Ap104VerPreco()
            aAdd(aCposDif,"EE9_PRECO2") // FJH - Adicionando os campos novos de preco.
            aAdd(aCposDif,"EE9_PRECO3")
            aAdd(aCposDif,"EE9_PRECO4")
            aAdd(aCposDif,"EE9_PRECO5")
         EndIf
         AAdd(aCposDif,"WK_FLAGOIC")
         AAdd(aCposDif,"WK_TOTOIC")
         AAdd(aCposDif,"WK_QTDOIC")
      Endif

      If EECFlags("FATFILIAL")
         AAdd(aCposDif,"EE9_FIL_NF")
      EndIf

      i := 1
      While i <= Len(aCposDif)
         If WorkIp->(FieldPos(AllTrim(aCposDif[i]))) == 0
            ADel(aCposDif,i)
            ASize(aCposDif,Len(aCposDif)-1)
         Else
            i++
         EndIf
      EndDo
   Else
      aCposDif := {}
      For i := 1 TO WorkIP->(FCount())
         AAdd(aCposDif,WorkIP->(FieldName(i)))
      Next nInc
      Ap104KeyX3(aCposDif) //Acerta campos
   EndIf

   aCposShow := {"WP_FLAG   ","EE9_SLDINI","WP_SLDATU ","EE9_QTDEM1","EE9_PRECO ","EE9_TOTAL "}

   If cFil == cFilBr
      If lIntegra
         AAdd(aCposShow,Nil)
         AIns(aCposShow,2)
         aCposShow[2] := AvKey("EE9_NF", "X3_CAMPO")

         AAdd(aCposShow,Nil)
         AIns(aCposShow,3)
         aCposShow[3] := AvKey("EE9_SERIE", "X3_CAMPO")

         If EECFlags("FATFILIAL")
            AAdd(aCposShow,Nil)
            AIns(aCposShow,4)
            aCposShow[4] := AvKey("EE9_FIL_NF", "X3_CAMPO")
         EndIf

      EndIf

      aAdd(aCposShow, AvKey("EE9_RV", "X3_CAMPO"))

      // ** JPM - 20/03/06 - campos de R.E. e S.D. também aparecem no browse, pois para cada R.V. pode haver um R.E. ou S.D.
      AAdd(aCposShow,"EE9_RE    ")
      AAdd(aCposShow,"EE9_DTRE  ")
      AAdd(aCposShow,"EE9_NRSD  ")
      AAdd(aCposShow,"EE9_DTAVRB")
   EndIf

   If Ap104VerPreco() .and. EECFlags("CAFE") // p/ q os outros campos preço sejam exibidos.
      aAdd(aCposShow,"EE9_PRECO2")
      aAdd(aCposShow,"EE9_PRECO3")
      aAdd(aCposShow,"EE9_PRECO4")
      aAdd(aCposShow,"EE9_PRECO5")
   Endif

   For i := 1 To Len(aGrpCpos)
      If aGrpInfo[i] = "N" // se for um campo do aGrpCpos que não é sempre igual para todos os itens, vai para o aCposDif
         If AScan(aCposDif,aGrpCpos[i]) = 0
            AAdd(aCposDif,aGrpCpos[i])
         EndIf
      EndIf
   Next

   aCposDif2 := aCposDif // se as variáveis aCposDif2 e aCposShow2 forem alteradas pelo ponto de entrada, então aCposDif e aCposShow tb serão alteradas, pois são ponteiros...
   aCposShow2 := aCposShow
   If EasyEntryPoint("EECAE104")
      ExecBlock("EECAE104",.f.,.f.,{"ARRAY_BROWSE_ITENS"})
   EndIf

   SX3->(DbSetOrder(2))
   // campos que vão para o browse
   For i := 1 To Len(aCposShow)
      If aCposShow[i] == "EE9_TOTAL "
         SX3->(DbSeek("EE9_PRCTOT")) //campo de exemplo
         SX3->(AAdd(aCposGd,{STR0087,"EE9_TOTAL ",x3_picture,x3_tamanho,x3_decimal,"",nil,x3_tipo,nil,nil}) ) //"Total"
      ElseIf aCposShow[i] == "WP_SLDATU "
         SX3->(DbSeek("EE9_SLDINI")) //campo de exemplo
         SX3->(AAdd(aCposGd,{STR0088,"WP_SLDATU ",x3_picture,x3_tamanho,x3_decimal,"",nil,x3_tipo,nil,nil}) ) //"Saldo a Embarcar"
      ElseIf aCposShow[i] == "WP_FLAG   "
         SX3->(AAdd(aCposGd,{"","WP_FLAG   ","",2,0,"",nil,"C",nil,nil}) )
      Else
         AAdd(aCposGd,aCposShow[i])
      EndIf
   Next

   aHeader := EECMontaHeader(aCposGd,.t.) // A header para a GetDados na nova folder de itens

   //WFS 22/01/2010 - Chamado 080495
   If EasyEntryPoint("EECAE104")
      ExecBlock("EECAE104", .F., .F., {"APOS_MONTA_HEADER"})
   EndIf

   // define títulos dos browses.
   If(cFil==cFilAtu,cTituloAtu,cTituloOpos) := If(cFil==cFilBr,STR0084,STR0085) + If(cFil == cFilAtu .And. lConsolOffShore,"(" + STR0086 + ")","") //"Filial Brasil" ## "Atual"

End Sequence

Return Nil

/*
Função      : Ae104CpoAdic()
Objetivos   : Carregar campos adicionais além dos do aHeader e do aCols
Parâmetros  : Nenhum
Retorno     : Nil
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 25/10/05 às 15:36
Obs.        :
*/
*---------------------*
Function Ae104CpoAdic()
*---------------------*
Local i, k
Local aCposDif, aHeader, aHeadAdic

Begin Sequence

   aHeadAdicAtu  := {}
   aHeadAdicOpos := {}
   aColsAdicAtu  := {}
   aColsAdicOpos := {}

   For i := 1 TO WorkIP->(FCount())
      AAdd(aHeadAdicAtu,{,IncSpace(WorkIP->(FieldName(i)),10,.f.) })
   Next nInc

   If lConsolOffShore
      aHeadAdicOpos := AClone(aHeadAdicAtu)
   EndIf

   For k := 1 To 2
      If k = 1
         aCposDif  := aCposDifAtu
         aHeader   := aHeaderAtu
         aHeadAdic := aHeadAdicAtu
      Else
         If !lConsolOffShore
            Exit
         EndIf
         aCposDif  := aCposDifOpos
         aHeader   := aHeaderOpos
         aHeadAdic := aHeadAdicOpos
      EndIf
      /*
      os arrays aHeadAdic???? contém os campos adicionais, que não seram armazenados pelo aCols. Se um campo é
      diferente entre os itens (pertence ao aCposDif????) e não está no aHeader (ou seja, não será armazenado no aCols)
      então, ele vai ser armazenado nos arrays aColsAdic????, que tem como "Header" o aHeadAdic????.
      */
      i := 1
      While i <= Len(aHeadAdic)
         If AScan(aCposDif,aHeadAdic[i][2]) = 0 .Or.; // se não for um campo diferente entre os itens  ou
            AScan(aHeader,{|x| x[2] == aHeadAdic[i][2]}) > 0 // se for um campo do aHeader
            ADel(aHeadAdic,i)
            Asize(aHeadAdic,Len(aHeadAdic)-1)//redimensiona o array, tirando o item deletado
         Else
            i++
         EndIf
      EndDo
   Next

   AAdd(aHeadAdicAtu ,{,"REC_NO"})
   If lConsolOffShore
      AAdd(aHeadAdicOpos,{,"REC_NO"})
   EndIf

End Sequence

Return Nil

/*
Função      : Ae104LoadCols()
Objetivos   : Carregar aColsAtu, aColsOpos, aColsAdicAtu e aColsAdicOpos
Parâmetros  : Nenhum
Retorno     : Nil
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 25/10/05 às 15:36
Obs.        : Considera que a WorkIp já está com filtro setado de acordo com a WorkGrp
*/
*----------------------*
Function Ae104LoadCols()
*----------------------*
Local i, cWork, aColsAdic, aHeadAdic, nCountIp := 0, nCountOpos := 1, lRet := .T.
Local aCols, aHeader, nSldAtu, nSldIni, aBk
Local nSldIniWkIP := 0

If Type("lChamada") <> "L"
   lChamada:= Nil
EndIf

Begin Sequence

   aColsAtu  := {}
   aColsOpos := {}

   For i := 1 To 2
      If i == 1
         cWork := "WorkIp"
      Else
         cWork := "WorkOpos"
      EndIf
      (cWork)->(DbGoTop())
      (cWork)->(dbEval({|| If(i == 1, nCountIp++, nCountOpos++) } ,, {|| !Eof() } ))
      (cWork)->(DbGoTop())
   Next

   //WHRS 12/07/17 -TE-6185 524753 / MTRADE-1186 - Quantidades no Embarque no processo Off shore
   If (nCountIp < 1 .or. nCountIp = 1 .and. empty(WORKIP->(EE9_NF))) /*nCountIp <= 1*/ .And. nCountOpos <= 1
      lRet := .F.
      Break
   EndIf

   For i := 1 To 2

      If i = 1 // carrega acols da WorkIp
         cWork     := "WorkIp"
         aCols     := aColsAtu
         aHeader   := aHeaderAtu
         aColsAdic := aColsAdicAtu
         aHeadAdic := aHeadAdicAtu
      Else // carrega acols da WorkOpos
         If !lConsolOffShore
            Exit
         EndIf
         cWork := "WorkOpos"
         // Setar filtro na WorkOpos
         aBk := Ae104GrpFilter(,cWork)
         aCols   := aColsOpos
         aHeader := aHeaderOpos
         aColsAdic := aColsAdicOpos
         aHeadAdic := aHeadAdicOpos
      EndIf

      (cWork)->(DbGoTop())
      While (cWork)->(!Eof())
         EECGDAppend(@aCols,aHeader)          //adiciona linha do aCols
         EECGDReplace(cWork,@aCols,aHeader) //copia registro posicionado na cWork para a Linha do aCols

         EECGDAppend(@aColsAdic,aHeadAdic) // appenda linha no aCols adicional
         EECGDReplace(cWork,@aColsAdic,aHeadAdic)

         GdFieldPut("EE9_TOTAL", (cWork)->(EE9_PRECO*EE9_SLDINI), Len(aCols), aHeader, aCols, /*lReadVar*/) // grava o total (campo virtual)

         GdFieldPut("REC_NO", (cWork)->(RecNo()), Len(aColsAdic), aHeadAdic, @aColsAdic, /*lReadVar*/) // grava o recno da work

         If !Empty((cWork)->WP_FLAG)
            GdFieldPut("WP_FLAG", "X ", Len(aCols), aHeader, @aCols, /*lReadVar*/) // grava o recno da work
         EndIf

         If !(lVisual .Or. ValType(lChamada) <> "L")
            If Empty((cWork)->WP_FLAG)// tratar quantidades que são carregadas inicialmente
               nSldIni := 0
               nSldAtu := (cWork)->(EE9_SLDINI+WP_SLDATU)
               GdFieldPut("EE9_SLDINI", nSldIni, Len(aCols), aHeader, aCols, /*lReadVar*/) // quantidade
               GdFieldPut("WP_SLDATU" , nSldAtu, Len(aCols), aHeader, aCols, /*lReadVar*/) // saldo   
               //NCF - 07/03/2018
               If cWork == "WorkOpos"
                  GdFieldPut("EE9_SLDINI", nSldIniWkIP , Len(aCols), aHeader, aCols, /*lReadVar*/)
                  nSldIniWkIP := 0
               Else
                  nSldIniWkIP += (cWork)->(EE9_SLDINI+WP_SLDATU)
               EndIf 
            EndIf
         EndIf

         (cWork)->(DbSkip())
      EndDo     
      (cWork)->(DbGoTop())
   Next

End Sequence

If ValType(aBk) = "A"
   EECRestFilter(aBk[1]) // restaura filtro da WorkOpos
EndIf

Return lRet

/*
Função      : Ae104TratEdit()
Objetivos   : Tratar Campos que aparecem na enchoice, campos editáveis, campos da getdados que serão totalizados nos gets da enchoice.
Parâmetros  : Nenhum
Retorno     : Nil
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 25/10/05 às 16:35
Obs.        :
*/
*----------------------*
Function Ae104TratEdit()
*----------------------*
Local i
Begin Sequence

   If Empty(aAltera)
      aAltera := aClone(aItemEnchoice)
   EndIf

   Ap104KeyX3(aAltera)
   Ap104KeyX3(aItemEnchoice)

   aTotaliza := {}
   For i := 1 To Len(aCposDifAtu)
      If AScan(aAltera,aCposDifAtu[i]) = 0 .Or. AScan(aItemEnchoice,aCposDifAtu[i]) = 0
         AAdd(aNotEditGetDados,aCposDifAtu[i])
      EndIf

      // Todos os campos do novo browse não aparecerão na enchoice, exceto na(s) situação(ões) enumerada(s) abaixo:
      // ** 1 - se é um campo da work de agrupamento e o campo for de totalizar, aparecerá ma enchoice (se já existir no aItemEnchoice), porém não será editável.
      If (nPos := AScan(aGrpCpos,aCposDifAtu[i])) > 0                   // procura na work de agrupamentos
         If aGrpInfo[nPos] = "T"                                       // é de totalizar??
            AAdd(aTotaliza,aCposDifAtu[i])
            If (nPos := AScan(aAltera,aCposDifAtu[i])) > 0 // é editável? se for, não será mais.
               aDel(aAltera,nPos)
               aSize(aAltera,Len(aAltera)-1)
            EndIf
            Loop //para não excluir do aItemEnchoice
         EndIf
      EndIf
      // **

      //ER - 17/12/2007 - O campo de descrição deverá ser exibido na enchoice.
      If aCposDifAtu[i] == "EE9_VM_DES"
         Loop
      EndIf

      If (nPos := AScan(aItemEnchoice,aCposDifAtu[i])) > 0
         aDel(aItemEnchoice,nPos)
         aSize(aItemEnchoice,Len(aItemEnchoice)-1)
      EndIf
      If (nPos := AScan(aAltera,aCposDifAtu[i])) > 0
         aDel(aAltera,nPos)
         aSize(aAltera,Len(aAltera)-1)
      EndIf
   Next

   SX3->(DbSetOrder(2))
   aAllCpos := {}
   For i := 1 To Len(aItemEnchoice)
      If !(aItemEnchoice[i] $ "EE9_PSBRTO/EE9_PSLQTO/EE9_QTDEM1/EE9_SLDINI/") .And. SX3->(DbSeek(aItemEnchoice[i])) .And. SX3->X3_TIPO = "N"
         If (AScan(aAllCpos,aItemEnchoice[i]) = 0)
            AAdd(aAllCpos,aItemEnchoice[i])
         EndIf
      EndIf
   Next

   For i := 1 To Len(aCposDifAtu)
      If !(aCposDifAtu[i] $ "EE9_PSBRTO/EE9_PSLQTO/EE9_QTDEM1/EE9_SLDINI/") .And. SX3->(DbSeek(aCposDifAtu[i])) .And. SX3->X3_TIPO = "N"
         If (AScan(aAllCpos,aCposDifAtu[i]) = 0)
            AAdd(aAllCpos,aCposDifAtu[i])
         EndIf
      EndIf
   Next

   aDifValid := {}
   SX3->(DbSetOrder(2))
   For i := 1 To Len(aItemEnchoice)
      If SX3->(DbSeek(aItemEnchoice[i]))
         AAdd(aDifValid,{aItemEnchoice[i],SX3->X3_VALID})
      Else
         AAdd(aDifValid,{aItemEnchoice[i],".t."})
      EndIf
   Next

   For i := 1 To Len(aCposDifAtu)
      If ASCan(aDifValid,{|x| x[1] == aCposDifAtu[i]}) = 0
         If SX3->(DbSeek(aCposDifAtu[i]))
            AAdd(aDifValid,{aCposDifAtu[i],SX3->X3_VALID})
         Else
           AAdd(aDifValid,{aCposDifAtu[i],".t."})
         EndIf
      EndIf
   Next

End Sequence

Return Nil

/*
Função      : Ae104TelaIt()
Objetivos   : Adicionar novo folder na enchoice de itens com a tela de itens consolidados
Parâmetros  : Nenhum
Retorno     : Nenhum
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 26/10/05 às 16:00
Obs.        :
*/
*------------------------*
Function Ae104TelaIt(oDlg)
*------------------------*
Local oFolderItem, oGetDadosAtu, oGetDadosOpos, aPos, i, aCpos
Local aAlterAtu := {},aAlterOpos := {}, c, j
Local cOldReadVar
Private lMarkAll, aNotEditFilAtu := {}

Begin Sequence

   AAdd(aNotEditGetDados,"WP_SLDATU ")
   AAdd(aNotEditGetDados,"EE9_TOTAL ")
   AAdd(aNotEditGetDados,"EE9_RV    ")
   AAdd(aNotEditGetDados,"EE9_NF    ")
   AAdd(aNotEditGetDados,"EE9_SERIE ")
   AAdd(aNotEditGetDados,"EE9_FIL_NF")

   If EECFlags("ESTUFAGEM") .And. Type("lItEstufado") == "L" .And. lItEstufado
      AAdd(aNotEditFilAtu,"EE9_SLDINI")
      AAdd(aNotEditFilAtu,"EE9_QE    ")
      AAdd(aNotEditFilAtu,"EE9_EMBAL1")
      AAdd(aNotEditFilAtu,"EE9_QTDEM1")
   EndIf

   If EasyEntryPoint("EECAE104")
      ExecBlock("EECAE104", .F., .F., "TELAIT_DEFCAMPOS_INI")
   EndIf

   For i := 1 To Len(aCposGDAtu)
      If ValType(aCposGDAtu[i]) = "C"
         c := aCposGDAtu[i]
      Else
         c := aCposGDAtu[i][2]
      EndIf
      If AScan(aNotEditGetDados,c) = 0 .And. AScan(aNotEditFilAtu, c) = 0
         AAdd(aAlterAtu,c)
      EndIf
   Next

   If lConsolOffShore
      For i := 1 To Len(aCposGDOpos)
         If ValType(aCposGDOpos[i]) = "C"
            c := aCposGDOpos[i]
         Else
            c := aCposGDOpos[i][2]
         EndIf
         If AScan(aNotEditGetDados,c) = 0
            AAdd(aAlterOpos,c)
         EndIf
      Next
   EndIf

   // para que nas validações e gatilhos feitos para cada item, sejam simuladas as variáveis de memória, baseadas na AuxIt
   For i := 1 To Len(aHeaderAtu)
      AddValid(@aHeaderAtu[i][2],@aHeaderAtu[i][6])
   Next

   If lConsolOffShore
      For i := 1 To Len(aHeaderOpos)
         AddValid(@aHeaderOpos[i][2],@aHeaderOpos[i][6])
      Next
   EndIf

   // ** Tela
   oFolderItem := ATail(oFolder:aDialogs) // oFolderItem == pasta que acabou de ser adicionada
   aPos := PosDlg(oFolderItem)

   aPos[1] -= 17

   //Títulos dos Browses
   @ aPos[1], aPos[2]       To 17, If(lConsolOffShore,(aPos[4]/2)-9.5,aPos[4]) Pixel Of oFolderItem
   @ aPos[1]+5, 5 Say cTituloAtu  Size 120,8 Of oFolderItem Pixel Font TFont():New("Arial",9,20)
   If lConsolOffShore
      @ aPos[1], (aPos[4]/2)-9 To 17, aPos[4] Pixel Of oFolderItem
      @ aPos[1]+5, (aPos[4]/2)-6 Say cTituloOpos Size 120,8 Of oFolderItem Pixel Font TFont():New("Arial",9,20)
   EndIf

   aPos := PosDlg(oFolderItem)
   aPos[1] += 3

   oGetDadosAtu  := MsNewGetDados():New(aPos[1],aPos[2],aPos[3],If(lConsolOffShore,(aPos[4]/2)-10,aPos[4]),; // Posições da Getdados
                                        If(!lVisual,2,0),,,,;                    // Tipo (Alteração ou Visualização)
                                        aAlterAtu,,,,,;                          // Campos que serão alterados
                                        ,;                                       // Função para validar a deleção da linha da GetDados
                                        oFolderItem,;                            // Objeto contenedor da GetDados
                                        aHeaderAtu,;                             // aHeader
                                        aColsAtu)                                // aCols

   If lConsolOffShore
      oGetDadosOpos := MsNewGetDados():New(aPos[1],(aPos[4]/2)-9,aPos[3],aPos[4],;  // Posições da Getdados
                                           If(!lVisual,2,0),,,,;                    // Tipo (Alteração ou Visualização)
                                           aAlterOpos,,,,,;                         // Campos que serão alterados
                                           ,;                                       // Função para validar a deleção da linha da GetDados
                                           oFolderItem,;                            // Objeto contenedor da GetDados
                                           aHeaderOpos,;                            // aHeader
                                           aColsOpos)                               // aCols
   EndIf

   oFolder:bChange := {|| Ae104AuxIt(7,,,,.t.), nOpcFolder := oFolder:nOption} // calcula totais

   EditBrowse(@oGetDadosAtu:oBrowse,.t.)
   If lConsolOffShore
      EditBrowse(@oGetDadosOpos:oBrowse,.f.)
   EndIf

   // Incluir validações de when
   For j := 1 To 2
      If j = 1
         aCpos := oGetDadosAtu:aInfo
      Else
         If !lConsolOffShore
            Exit
         EndIf
         aCpos := oGetDadosOpos:aInfo
      EndIf
      For i := 1 To Len(aCpos)
         cOldWhen := AllTrim(aCpos[i][4])
         aCpos[i][4] := "Ae104AuxIt(6)"
         If !Empty(cOldWhen)
            aCpos[i][4] += " .And. (" + cOldWhen + ")"
         EndIf
                             // carrega var. memoria, valida, restaura var. memo. e retorna validação
         aCpos[i][4] := "Eval( {|| Ae104AuxIt(2,,.f.), ret := (" + aCpos[i][4] + "), Ae104AuxIt(3,,.f.), ret } )"
      Next
   Next

   oGetDadosAtu:lF3Header  := .f.
   If lConsolOffShore
      oGetDadosOpos:lF3Header := .f.
   EndIf

   aObjs := {oFolderItem, oGetDadosAtu, oGetDadosOpos, oMsMGet}

   // ** carrega campos virtuais
   cOldReadVar := __readvar
   __readvar := "M->EE9_SLDINI"
   lMarkAll := .t.
   lGdFilAtu := .t.
   For i := 1 To Len(aColsAtu)
      Ae104AuxIt(2,cFilAtu,.f.,i)
      &(aDifValid[AScan(aDifValid,{|x| x[1] = "EE9_SLDINI"})][2]) //executa validação
      Ae104AuxIt(3,cFilAtu,.f.,i)
   Next

   If lConsolOffShore
      lGdFilAtu := .f.
      For i := 1 To Len(aColsOpos)
         Ae104AuxIt(2,cFilOpos,.f.,i)
         &(aDifValid[AScan(aDifValid,{|x| x[1] = "EE9_SLDINI"})][2]) //executa validação
         Ae104AuxIt(3,cFilOpos,.f.,i)
      Next
   EndIf
   lMarkAll := Nil
   __readvar := cOldReadVar
   lGdFilAtu := Nil
   // **

End Sequence

Return Nil

// Função Auxiliar
// Objetivos: Modificar browse
*--------------------------------------*
Static Function EditBrowse(oBrowse,lAtu)
*--------------------------------------*
Local oCol := oBrowse:aColumns[1], aSaveColumns, nPos
Local aHeader, aCols,i

Begin Sequence

   oCol         := TCColumn():New("", {|| ""})
   oCol:lBitmap := .T.
   oCol:lNoLite := .T.
   oCol:nWidth  := 14
   oCol:nAlign  := 0
   oCol:BackColor := oBrowse:aColumns[2]:BackColor
   oCol:bClrBack  := oBrowse:aColumns[2]:bClrBack
   oCol:bClrFore  := oBrowse:aColumns[2]:bClrFore
   oCol:cHeading  := ""

   oBrowse:bAdd    := {||.F.} // não inclui novos itens
   //oBrowse:bDelete := {||Ae104AuxIt(5)} // função executada ao apertar Del em uma linha da GD.
   If lAtu
      oCol:bData   := {||If(!Empty(aObjs[2]:aCols[aObjs[2]:oBrowse:nAt][1]), "LBTIK", "LBNO" )}
      oBrowse:bGotFocus  := {||lGDFilAtu := .t.}
   Else
      oCol:bData   := {||If(!Empty(aObjs[3]:aCols[aObjs[3]:oBrowse:nAt][1]), "LBTIK", "LBNO" )}
      oBrowse:bGotFocus := {||lGDFilAtu := .f.}
   EndIf

   oBrowse:bLDblClick := {|| Ae104DbClick() }
   oBrowse:bKeyDown   := {|| Ae104DbClick() }

End Sequence

Return Nil

/*
Função      : Ae104DbClick
Objetivos   : Double Click na MsNewGetDados
Parâmetros  : Nenhum
*/
*---------------------*
Function Ae104DbClick()
*---------------------*
Local oGetDados := If((Type("lGDFilAtu") <> "L" .Or. lGDFilAtu), aObjs[2], aObjs[3])
Local lRet := .t., nLine := oGetDados:oBrowse:nAt, nCol := oGetDados:oBrowse:nColPos
Private lAe104DbClick := .t.

Begin Sequence

   If (lVisual .Or. Type("lChamada") <> "L")
      If oGetDados:aHeader[nCol][8] == "M" // FJH 14/12/05 Se for cpo memo abre janela p/ visualização.
         lRet := AE104MemoEdit(aMemoItem[aScan(aMemoItem,{|x| x[2] == oGetDados:aHeader[nCol][2]})][1], ;
         oGetDados:aHeader[nCol][2],oGetDados:aHeader[nCol][1],.F.)
      Endif
      lRet := .f.
      Break
   EndIf

   If oGetDados:oBrowse:nColPos = 1
      Ae104MarkIt(nLine)
   Else
      If oGetDados:aHeader[nCol][8] == "M" // FJH 14/12/05 Se for cpo memo abre janela p/ edição.
         lRet := AE104MemoEdit(aMemoItem[aScan(aMemoItem,{|x| x[2] == oGetDados:aHeader[nCol][2]})][1], ;
         oGetDados:aHeader[nCol][2],oGetDados:aHeader[nCol][1],.T.)

         oGetDados:aCols[nLine][oGetDados:oBrowse:nColPos] := &("M->"+oGetDados:aHeader[oGetDados:oBrowse:nColPos][2])
      Else
         lRet := oGetDados:EditCell()
      Endif
      If lRet
         If Empty(oGetDados:aCols[nLine][1]) .And. oGetDados:aCols[nLine][GDFieldPos("EE9_SLDINI",oGetDados:aHeader)] > 0
            Ae104MarkIt(nLine)
         EndIf
      EndIf
   EndIf

   If oGetDados:aCols[nLine][GDFieldPos("EE9_SLDINI",oGetDados:aHeader)] <= 0 .And.; // se a quantidade ficar zerada, desmarca
      !Empty(oGetDados:aCols[nLine][1])

      Ae104MarkIt(nLine)

   EndIf

End Sequence

Return lRet

/*
Função      : Ae104MarkIt
Objetivos   : Simular marca/desmarca na MsNewGetDados
Parâmetros  : aHeader, aCols e nLine
*/
Function Ae104MarkIt(nLine)
Local aCols, aHeader, nSldIni, nSldAtu
Local cOld, lRet := .t.
If Type("lGDFilAtu") <> "L" .Or. lGdFilAtu
   aCols   := @aObjs[2]:aCols //aColsAtu
   aHeader := aHeaderAtu
Else
   aCols   := @aObjs[3]:aCols  //aColsOpos
   aHeader := aHeaderOpos
EndIf

Begin Sequence

   cOld := __readvar
   __readvar := "M->EE9_SLDINI"

   Ae104AuxIt(2,,.f.,nLine,,) // simula variáveis de memória de acordo com o aCols da GetDados.
   If Empty(M->WP_FLAG)
      If Ae100VldSel()
         M->WP_FLAG := "X " //cMarca //
      Else
         lRet := .f.
      EndIf
   Else
      M->WP_FLAG := "  "
   EndIf

   If Empty(M->WP_FLAG)
      M->WP_SLDATU += M->EE9_SLDINI
      M->EE9_SLDINI := 0
   ElseIf Empty(M->EE9_SLDINI)
      M->EE9_SLDINI += M->WP_SLDATU
      M->WP_SLDATU := 0
   EndIf

   lMarkAll := .t. // para não dar mensagem.
   &(aDifValid[AScan(aDifValid,{|x| x[1] = "EE9_SLDINI"})][2]) //executa validação
   lMarkAll := Nil
   Ae104AuxIt(3,,.f.,nLine,.t.,) // restaura variáveis de memória.
   __readvar := cOld

   If(Type("lGDFilAtu") <> "L" .Or. lGdFilAtu,aColsAtu,aColsOpos)[nLine] := AClone(aCols[nLine])

End Sequence

Return lRet

// Função Auxiliar
// Obj.: Adicionar validações no aHeader
*-----------------------------------*
Static Function AddValid(cCpo,cValid)
*-----------------------------------*
Begin Sequence

   If Empty(AllTrim(cValid))
      cValid := ".t."
   EndIf

   cValid := "Eval( {|| Ae104AuxIt(2), ret := (" + cValid + "), ret2 := Ae104AuxIt(3,,,,ret), (ret .And. ret2) } )"

End Sequence

Return Nil

/*
Função      : Ae104AuxIt()
Objetivos   : Rotinas auxiliares na consolidação de itens
Parâmetros  : nTipo
              lAux
Retorno     : lRet
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 24/10/05 às 10:45
Obs.        :
*/
*-------------------------------------------------------------------------*
Function Ae104AuxIt(nTipo,cFil,lReadVar,nLine,lRetValid,lTotaliza,lBk,lAux)
*-------------------------------------------------------------------------*
Local lRet := .t.
Local i, j
Local aHeader, aCols, aHeadAdic, aColsAdic, oGetDados
Local cReadVar := IncSpace(SubStr(ReadVar(),4),10,.f.)
Local lValAndTrigger
Local nSomaAtu, nSomaOpos, lOld

Static aVar := {}, aVarBk := {} //backup de memória.

Default cFil := If(Type("lGDFilAtu") <> "L" .Or. lGDFilAtu .Or. nTipo==7,cFilAtu,cFilOpos)
Default lReadVar := .t.
Default lBk := .f.
Default lAux := .t.

Private cWork

// define ponteiros -> para browse da filial atual ou da oposta.
If cFil = cFilAtu
   aHeadAdic := aHeadAdicAtu
   aColsAdic := aColsAdicAtu
   cWork     := "WorkIp"
   If Type("aObjs[2]") = "O"
      oGetDados := aObjs[2]
      aHeader   := @oGetDados:aHeader
      aCols     := @oGetDados:aCols
      Default nLine := If(ValType(oGetDados:oBrowse)="O",oGetDados:oBrowse:nAt,1)
   Else
      aHeader   := aHeaderAtu
      aCols     := aColsAtu
   EndIf
   aCposDif := aCposDifAtu
Else
   aHeadAdic := aHeadAdicOpos
   aColsAdic := aColsAdicOpos
   cWork     := "WorkOpos"
   If Type("aObjs[3]") = "O"
      oGetDados := aObjs[3]
      aHeader   := @oGetDados:aHeader
      aCols     := @oGetDados:aCols
      Default nLine := If(ValType(oGetDados:oBrowse)="O",oGetDados:oBrowse:nAt,1)
   Else
      aHeader   := aHeaderOpos
      aCols     := aColsOpos
   EndIf
   aCposDif := aCposDifOpos
EndIf

Begin Sequence

   *-----------------------------------------------------------------------------------------------------------------------------------------------*
   If nTipo == 1 // Carrega campos de totalizar na enchoice, antes de carregar a tela
      Default lRetValid := .t.
      If WorkGrp->WP_FLAG = "N" // se não estiver marcado, os campos ficam zerados
         For i := 1 To Len(aTotaliza)
            M->&(aTotaliza[i]) := 0
         Next
      Else // senão, fica com o valor da WorkGrp
         For i := 1 To Len(aTotaliza)
            M->&(aTotaliza[i]) := WorkGrp->(aTotaliza[i])
         Next
      EndIf
   *-----------------------------------------------------------------------------------------------------------------------------------------------*
   ElseIf nTipo == 2 // Simula as variáveis de memória, puxando da linha da MsNewGetDados, e faz backup da mesma
      Default lRetValid := .t.
      lArtificial := .t.
      (cWork)->(DbGoTo(aColsAdic[nLine][GdFieldPos("REC_NO", aHeadAdic)]))// posiciona no item correto
      If lBk
         aVarBk := aClone(aVar)
      EndIf
      aVar := {}
      For i := 1 To Len(aHeader)
         cCpo := aHeader[i][2]
         If lReadVar .And. cCpo == cReadVar
            AAdd(aVar,Nil)
         Else
            AAdd(aVar,M->&(cCpo))
            M->&(cCpo) := GdFieldGet(cCpo, nLine,, aHeader, aCols)
         EndIf
      Next

      For i := 1 To Len(aHeadAdic)
         cCpo := aHeadAdic[i][2]
         If lReadVar .And. cCpo == cReadVar
            AAdd(aVar,Nil)
         Else
            AAdd(aVar,M->&(cCpo))
            M->&(cCpo) := GdFieldGet(cCpo, nLine,, aHeadAdic, aColsAdic)
         EndIf
      Next

   *-----------------------------------------------------------------------------------------------------------------------------------------------*
   ElseIf nTipo == 3
      Default lRetValid := .t.
      (cWork)->(DbGoTo(aColsAdic[nLine][GdFieldPos("REC_NO", aHeadAdic)]))// posiciona no item correto

      If lRetValid

         If lAux .Or. !(cReadVar $ "EE9_PRECO /EE9_PRECO2/EE9_PRECO3/EE9_PRECO4/EE9_PRECO5/")
            If !(cReadVar $ "EE9_COD_I ") .And. ExistTrigger(cReadVar)
               RunTrigger(1,,,cReadVar) /* Executa gatilhos agora, na hora da validação para que
                                           depois possa voltar os backups (Memória e AuxIt)*/
            EndIf
         EndIf

         If cReadVar $ "EE9_SLDINI/EE9_PRECO "
            M->EE9_TOTAL := M->EE9_SLDINI*M->EE9_PRECO
         EndIf

         If cReadVar $ "EE9_QTDEM1/EE9_SLDINI"
            M->WP_SLDATU := (cWork)->WP_SLDATU - M->EE9_SLDINI + (cWork)->EE9_SLDINI
         EndIf

         If cReadVar $ "EE9_QTDEM1"
            // ** Executa validações/gatilhos necessários
            cOldReadVar := __readvar
            __readvar := "M->EE9_SLDINI"
            lRet := &(aDifValid[AScan(aDifValid,{|x| x[1] = "EE9_SLDINI"})][2])
            __readvar := cOldReadVar
            // **
         EndIf

         If lRet
            // ** joga variáveis de memória nos aCols
            For i := 1 To Len(aHeader)
               cCpo := aHeader[i][2]
               If lReadVar .And. cCpo == cReadVar
                  //
               Else
                  GdFieldPut(cCpo, M->&(cCpo), nLine, aHeader, aCols)
               EndIf
            Next

            For i := 1 To Len(aHeadAdic)
               cCpo := aHeadAdic[i][2]
               If lReadVar .And. cCpo == cReadVar
                  //
               Else
                  GdFieldPut(cCpo, M->&(cCpo), nLine, aHeadAdic, aColsAdic)
               EndIf
            Next
            // **
         EndIf
      EndIf

      // ** Restaura variáveis de memória
      j := 0
      For i := 1 To Len(aHeader)
         j++
         cCpo := aHeader[i][2]
         If lReadVar .And. cCpo == cReadVar
            //
         Else
            M->&(cCpo) := aVar[j]
         EndIf
      Next

      For i := 1 To Len(aHeadAdic)
         j++
         cCpo := aHeadAdic[i][2]
         If lReadVar .And. cCpo == cReadVar
            //
         Else
            M->&(cCpo) := aVar[j]
         EndIf
      Next
      // **

      If ValType(oGetDados) = "O"
         If(cFil = cFilAtu,aColsAtu,aColsOpos)  := AClone(oGetDados:aCols)
      EndIf

      lArtificial := .f.
      If ValType(oGetDados) = "O" .And. ValType(oGetDados:oBrowse) = "O" // testa, pois quando é dado o end da dialog, o oBrowse não esxite mais.
         oGetDados:oBrowse:Refresh() //Atualiza os dados do browse da GetDados
      EndIf

      If lBk
         aVar := aClone(aVarBk)
      EndIf

   *-----------------------------------------------------------------------------------------------------------------------------------------------*
   ElseIf nTipo == 4 //validar soma das quantidades no Ok final da tela de itens.

      nSomaAtu := 0
      For i := 1 To Len(aColsAtu)
         If !Empty(Ae104AuxFieldPutGet(,"WP_FLAG",,i,,.f.,.t.)) //Flag
            nSomaAtu += GdFieldGet("EE9_SLDINI", i, .f., aHeaderAtu, aColsAtu)
         EndIf
      Next

      If lConsolOffShore

         nSomaOpos := 0
         For i := 1 To Len(aColsOpos)
            If !Empty(Ae104AuxFieldPutGet(cFilOpos,"WP_FLAG",,i,,.f.,.t.)) //Flag
               nSomaOpos += GdFieldGet("EE9_SLDINI", i, .f., aHeaderOpos, aColsOpos)
            EndIf
         Next

         If nSomaAtu <> nSomaOpos
            easyhelp(STR0089 + ENTER +;//"A soma das quantidades entre filiais Brasil e Exterior devem ser iguais."
                    STR0090 + AllTrim(Transf(If( lFilBr,nSomaAtu,nSomaOpos),AvSx3("EE9_SLDINI",AV_PICTURE))) + ". " +; //"Qtd. Filial Brasil: "
                    STR0091 + AllTrim(Transf(If(!lFilBr,nSomaAtu,nSomaOpos),AvSx3("EE9_SLDINI",AV_PICTURE))) + ".",;   //"Qtd. Filial Exterior: "
                    STR0024) //"Atenção"
            lRet := .f.
            Break
         EndIf
      EndIf

      If nSomaAtu <= 0
         easyhelp(STR0092,STR0024) //"As quantidades não podem ficar zeradas.","Atenção"
         lRet := .f.
         Break
      EndIf

   *-----------------------------------------------------------------------------------------------------------------------------------------------*
   ElseIf nTipo == 5 // valida a deleção da linha da GetDados
      If !Empty(Ae104AuxFieldPutGet(cFil,"WP_FLAG",,nLine,,.f.,.t.)) // se estiver marcado, desmarca na deleção
         Ae104MarkIt(nLine)
      EndIf
      lRet := .f. // não permite deleção
   *-----------------------------------------------------------------------------------------------------------------------------------------------*
   ElseIf nTipo == 6 // validar When das linhas da GetDados
      Default lRetValid := .t.

      If Type("lAe104DbClick") <> "L"
         lRet := .f.
         Break
      EndIf

      If !Ae100BloqIt(.f.)
         lRet := .f.
         Break
      EndIf

      If Empty(aCols[nLine][1]) .And. !Ae100VldSel()
         lRet := .f.
         Break
      EndIf

   *-----------------------------------------------------------------------------------------------------------------------------------------------*
   ElseIf nTipo == 7 // Totalização e passagem de dados das validações da enchoice para a GetDados
      Default lRetValid := .f. //se .t., foi chamado do bChange da folder
      lArtificial := .t.
      lOld := lGdFilAtu
      lGdFilAtu := .t.

      If lRetValid //Chamada do bChange da Folder
         lValAndTrigger := .f.
         lTotaliza := .f.
         If oFolder:nOption = Len(oFolder:aDialogs) // só valida e gatilha se acabou de mudar para a nova folder.
            lValAndTrigger := .t.
         ElseIf nOpcFolder = Len(oFolder:aDialogs) // só totaliza se acabou de mudar da nova folder para outra qualquer.
            lTotaliza := .t.
         EndIf
      Else // chamada em outros lugares
         If ValType(lTotaliza) = "L"
            If lTotaliza
               lValAndTrigger := .f.
            Else
               lValAndTrigger := .t.
            EndIf
         Else
            lValAndTrigger := .t.
            lTotaliza := .t.
         EndIf
      EndIf

      If lValAndTrigger
         // ** Executar validações e gatilhos
         j := 1
         cOldReadVar := __readvar // armazena variável de leitura
         While j <= Len(aCols)
            If Empty(Ae104AuxFieldPutGet(,"WP_FLAG",,j,,.f.,.t.)) //Flag
               j++
               Loop
            EndIf
            Ae104AuxIt(2,,.f.,j,,)
            For i := 1 To Len(aAllCpos)
               If !("EE9_PRECO" $ aAllCpos[i]) .And. !(aAllCpos[i] $ "EE9_COD_I /EE9_PRCTOT/EE9_PRCINC/")
                  __readvar := "M->" + aAllCpos[i]
                  &(aDifValid[AScan(aDifValid,{|x| x[1] = aAllCpos[i]})][2]) // executa validação
                  If ExistTrigger(aAllCpos[i])
                     RunTrigger(1,,,aAllCpos[i])
                  EndIf
               EndIf
            Next

            Ae104AuxIt(3,,.f.,j,.t.,,,.f.)
            j++
         EndDo
         __readvar := cOldReadVar //restaura a variável antiga de leitura
         // **
      EndIf

      If lTotaliza
         For i := 1 To Len(aTotaliza)
            M->&(aTotaliza[i]) := 0 // zera, para ser recalculado depois
         Next

         // Totaliza os campos de memória
         j := 1
         While j <= Len(aCols)
            If Empty(Ae104AuxFieldPutGet(,"WP_FLAG",,j,,.f.,.t.)) //Flag
               j++
               Loop
            EndIf
            For i := 1 To Len(aTotaliza)
               M->&(aTotaliza[i]) += Ae104AuxFieldPutGet(,aTotaliza[i],,j,,.f.,.t.)
            Next
            j++
         EndDo

      EndIf

      If Type("aObjs[2]:oBrowse") = "O" // testa, pois quando é dado o end da dialog, o oBrowse não existe mais.
         aObjs[2]:oBrowse:Refresh() //Atualiza os dados do browse da GetDados
      EndIf

      If Type("aObjs[3]:oBrowse") = "O" // testa, pois quando é dado o end da dialog, o oBrowse não existe mais.
         aObjs[3]:oBrowse:Refresh() //Atualiza os dados do browse da GetDados
      EndIf

      aColsAtu  := AClone(aObjs[2]:aCols)
      If lConsolOffShore
         aColsOpos := AClone(aObjs[3]:aCols)
      EndIf

      lArtificial := .f.
      lGdFilAtu := lOld
   EndIf

End Sequence

Return lRet

/*
Função      : Ae104AuxFieldPutGet()
Objetivos   : Executar GDFieldPut ou GDFieldGet, escolhendo o array certo (aCols ou o aColsAdic, Atu ou Opos)
Parâmetros  : cFil
Retorno     : Nil
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 26/10/05 às 13:34
Obs.        :
*/
*-----------------------------------------------------------------------*
Function Ae104AuxFieldPutGet(cFil,cCpo,xConteudo,nLine,lReadVar,lPut,lGD)
*-----------------------------------------------------------------------*
Local aHeader, aCols
Local aHeadAdic, aColsAdic
Local cRet := ""

Default cFil := cFilAtu
Default lPut := .t.
Default lGD  := .f.

If cFil = cFilAtu
   aHeader   := aHeaderAtu
   If lGD
      aCols     := aObjs[2]:aCols
   Else
      aCols     := aColsAtu
   EndIf
   aHeadAdic := aHeadAdicAtu
   aColsAdic := aColsAdicAtu
Else
   aHeader   := aHeaderOpos
   If lGD
      aCols     := aObjs[3]:aCols
   Else
      aCols     := aColsOpos
   EndIf
   aHeadAdic := aHeadAdicOpos
   aColsAdic := aColsAdicOpos
EndIf

If GdFieldPos( cCpo , aHeader ) > 0
   If lPut
      GdFieldPut( cCpo, xConteudo, nLine, aHeader, aCols, lReadVar)
   Else
      cRet := GdFieldGet( cCpo , nLine , lReadVar , aHeader , aCols )
   EndIf
Else
   If lPut
      GdFieldPut( cCpo, xConteudo, nLine, aHeadAdic, aColsAdic, lReadVar)
   Else
      cRet := GdFieldGet( cCpo , nLine , lReadVar , aHeadAdic , aColsAdic )
   EndIf
EndIf

Return cRet

/*
Função      : Ae104AtuFil()
Objetivos   : Atualizar filial com os registros da WorkOpos
Parâmetros  : cFil -> Filial a ser atualizada
Retorno     : .t./.f.
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 01/11/05 às 11:37
Obs.        :
*/
*------------------------*
Function Ae104AtuFil(cFil)
*------------------------*
Local lRet := .t., nSeqEmb := 0
Local nRec2
Local nVez := 1 //nVez - Primeiro trata as exclusões, depois inclusões, e depois alterações.

Begin Sequence

   EE8->(DbSetOrder(1))
   EE9->(DbSetOrder(2))

   WorkOpos->(DbClearFilter())
   WorkOpos->(DbGoTop())
   While WorkOpos->(!EoF()) .And. nVez <= 3
      If WorkOpos->(Empty(WP_FLAG) .And. Empty(WP_RECNO)) // se não foi marcado e não existe na base, desconsidera
         // atualiza saldos (para o caso de liquidar o saldo
         If nVez == 1
            EE8->(DbSeek(cFil+WorkOpos->(EE9_PEDIDO+EE9_SEQUEN))) //posiciona no item de pedido correspondente
            EE8->(RecLock("EE8",.f.))
            EE8->EE8_SLDATU := WorkOpos->WP_SLDATU
            EE8->(MsUnlock())
         EndIf

      ElseIf WorkOpos->(Empty(WP_FLAG)) // foi desmarcado
         If nVez == 1
            EE9->(DbGoTo(WorkOpos->WP_RECNO)) // posiciona no item correspondente na filial

            EE8->(DbSeek(cFil+EE9->(EE9_PEDIDO+EE9_SEQUEN))) //posiciona no item de pedido correspondente
            EE8->(RecLock("EE8",.f.))
            EE8->EE8_SLDATU := WorkOpos->WP_SLDATU
            EE8->(MsUnlock())

            EE9->(RecLock("EE9",.f.))
            EE9->(DbDelete()) // Exclui o item que foi desmarcado
            EE9->(MsUnlock())
         EndIf

      ElseIf WorkOpos->(Empty(WP_RECNO)) // foi marcado
         If nVez == 2
            If Empty(nSeqEmb)
               If EE9->(AvSeekLast(cFil+EEC->EEC_PREEMB)) //procura última sequência do embarque
                  nSeqEmb := Val(EE9->EE9_SEQEMB)+1
               Else
                  nSeqEmb := 1
               EndIf
            EndIf

            EE9->(RecLock("EE9",.t.))
            AvReplace("WorkOpos","EE9")
            If Empty(EE9->EE9_SEQEMB)
               nRec2 := EE9->(RecNo())
               EE9->(DbSetOrder(3))
               While EE9->(DbSeek(cFil+EEC->EEC_PREEMB+Str(nSeqEmb,AvSx3("EE9_SEQEMB",AV_TAMANHO))))
                  nSeqEmb++ //para não repetir sequências.
               EndDo
               EE9->(DbSetOrder(2))
               EE9->(DbGoTo(nRec2))
               EE9->EE9_SEQEMB := Str(nSeqEmb,AvSx3("EE9_SEQEMB",AV_TAMANHO))
               nSeqEmb++
            EndIf
            EE9->EE9_FILIAL := cFil
            EE9->EE9_PREEMB := M->EEC_PREEMB
            EE9->(MsUnlock())

            EE8->(DbSeek(cFil+EE9->(EE9_PEDIDO+EE9_SEQUEN))) //posiciona no item de pedido correspondente
            EE8->(RecLock("EE8",.f.))
            EE8->EE8_SLDATU := WorkOpos->WP_SLDATU //abate o saldo utilizado
            EE8->(MsUnlock())
         EndIf

      Else // foi alterado
         If nVez == 3
            EE9->(DbGoTo(WorkOpos->WP_RECNO))

            EE9->(RecLock("EE9",.f.))
            AvReplace("WorkOpos","EE9")
            EE9->EE9_FILIAL := cFil
            EE9->EE9_PREEMB := M->EEC_PREEMB
            EE9->(MsUnlock())

            EE8->(DbSeek(cFil+EE9->(EE9_PEDIDO+EE9_SEQUEN))) //posiciona no item de pedido correspondente
            EE8->(RecLock("EE8",.f.))
            EE8->EE8_SLDATU := WorkOpos->WP_SLDATU // abate o saldo utilizado
            EE8->(MsUnlock())
         EndIf
      EndIf

      WorkOpos->(DbSkip())
      If WorkOpos->(Eof())
         WorkOpos->(DbGoTop())
         nVez++
      EndIf
   EndDo

End Sequence

Return lRet

/*
Função      : Ae104MarkAll()
Objetivos   : Marcar todos os itens na tela de seleção de itens (detalhes)
Parâmetros  : Nenhum
Retorno     : .t./.f.
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 09/11/05 às 11:37
Obs.        :
*/
*---------------------*
Function Ae104MarkAll()
*---------------------*
Local lRet := .f., i, lOldGDFilAtu := lGDFilAtu
Local n := Len(aColsAtu) + If(Type("aColsOpos") = "A",Len(aColsOpos),0)
Local lMarca := Empty(aColsAtu[1][1])

ProcRegua(n)
lGdFilAtu := .t.
For i := 1 To Len(aColsAtu)
   If (lMarca .And. Empty(aColsAtu[i][1])) .Or. (!lMarca .And. !Empty(aColsAtu[i][1]))
      Ae104MarkIt(i)
   EndIf
   IncProc()
Next

If Type("aColsOpos") = "A"
   lGdFilAtu := .f.
   For i := 1 To Len(aColsOpos)
      If (lMarca .And. Empty(aColsOpos[i][1])) .Or. (!lMarca .And. !Empty(aColsOpos[i][1]))
         Ae104MarkIt(i)
      EndIf
      IncProc()
   Next
EndIf

lGdFilAtu := .t.
Ae104AuxIt(7,,,,,.T.)

lGDFilAtu := lOldGDFilAtu

Return lRet

 /*
Funcao      : AE104MemoEdit
Parametros  : cCodMemo - Cód. do cpo memo
              cCpoMemo - Campo Memo
Retorno     : .t./.f.
Autor       : Fabio Justo Hildebrand
Data/Hora   : 14/12/2005 14:15
Revisao     :
Obs.        :
*/
Function AE104MemoEdit(cCodMemo, cCpoMemo, cTitulo, lWhen)

Local lRet := .F., cMsg := ""
Local oDlg, oMemo, oFont := TFont():New("Courier New",09,15)

Local bOk      := {|| oDlg:End(),If(lWhen,lRet:=.T.,)},;
      bCancel  := {|| oDlg:End()}

Begin Sequence
   //cMsg := MSMM(cCodMemo,AvSx3(cCpoMemo,AV_TAMANHO))
   cMsg := &("M->"+cCpoMemo)

   Define MsDialog oDlg Title cTitulo From 9,0 To 23,50 of oDlg

      If lWhen
         @ 15,02 Get oMemo Var cMsg MEMO HSCROLL FONT oFont Size 195,90 Of oDlg  Pixel
      Else
         @ 15,02 Get oMemo Var cMsg MEMO HSCROLL FONT oFont Size 195,90 READONLY Of oDlg  Pixel
      Endif

      oMemo:EnableVScroll(.t.)
      oMemo:EnableHScroll(.t.)

   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) Centered

   If lRet
      &("M->"+cCpoMemo) := cMsg
   Endif

End Sequence

Return lRet

/*
Função  : CposEnChoice()
Data    : 16/07/08
Objetivo: Definir os campos a serem exibidos na Enchoice.
*/
Static Function CposEnChoice()
//Campos referente ao INTTRA, não devem estar na EnChoice quando não integrado
Local aCpoInttra := {"EX9_CCOTEM",;
                     "EX9_COMTEM",;
                     "EX9_ENVTMP",;
                     "EX9_FILIAL",;
                     "EX9_FORCTR",;
                     "EX9_FORLCR",;
                     "EX9_ID",;
                     "EX9_OBS",;
                     "EX9_PRECON",;
                     "EX9_TEMP",;
                     "EX9_TIPO",;
                     "EX9_VENT",;
                     "EX9_BLCLA1",;
                     "EX9_CBLCL1",;
                     "EX9_BLCLM1",;
                     "EX9_BLCLA2",;
                     "EX9_CBLCL2",;
                     "EX9_BLCLM2",;
                     "EX9_BLCLA3",;
                     "EX9_CBLCL3",;
                     "EX9_BLCLM3"}  // GFP - 08/05/2014

	SX3->(dbSetOrder(1))
	SX3->(dbSeek("EX9"))
	While(SX3->(!EOF()) .And. SX3->X3_ARQUIVO == "EX9")
		If X3Uso(SX3->X3_USADO)
			If EECFlags("INTTRA") .Or. aScan(aCpoInttra, AllTrim(SX3->X3_CAMPO)) == 0
				aAdd(aCampos,SX3->X3_CAMPO)
			EndIf
		EndIf
      SX3->(dbSkip())
   EndDo

Return

/*---------------------------------------------------------------------------*
  Fim das rotinas de Controle de Quantidades entre Filiais Brasil e Off-Shore
 *---------------------------------------------------------------------------*/


/*
Funcao      : SegUnidadeAE104
Parametros  : cUnidade
              nQuantidade
              nPreco
              nQtdDev
Retorno     :
Objetivos   : Converter da primeira para a segunda unidade de medida, com base no
              cadastro de produtos (SB1). Esta é uma operação inversa da realizada
              pela função Fat2SegUnidade(), utilizada apenas para realização da
              comparação das notas fiscais quando habilitado o parâmetro MV_AVG0067
              e MV_AVG0141
Autor       : Wilsimar Fabrício da Silva
Data/Hora   : 14/06/2010
Obs.        : 1. Os parâmetro devem ser enviado por referência
              2. A tabela SB1 deve estar posicionada no registro
Revisão     :
*/

Static Function SegUnidadeAE104(cUnidade, nQuantidade, nPreco, nQtdDev)
Default cUnidade:= ""
Default nQuantidade:= 0,;
        nPreco     := 0,;
        nQtdDev    := 0

Begin Sequence

   If SB1->B1_CONV == 0
      Break
   EndIf

   If SB1->B1_TIPCONV == "M"
      nQuantidade:= nQuantidade * SB1->B1_CONV
      nQtdDev    := nQtdDev * SB1->B1_CONV
      nPreco     := Round(nPreco / SB1->B1_CONV, AvSx3("EE8_PRECOI", AV_DECIMAL))
   Else
      nQuantidade:= nQuantidade / SB1->B1_CONV
      nQtdDev    := nQtdDev / SB1->B1_CONV
      nPreco     := Round(nPreco * SB1->B1_CONV, AvSx3("EE8_PRECOI", AV_DECIMAL))
   EndIf

End Sequence
Return Nil


*==================================*
Function AE104VCampo(cCampo)
*==================================*
Local lRet := .T.
Local cMsg := ""

cCampo := Upper(cCampo)
Begin Sequence
   Do Case

      Case cCampo == "EX9_DTRETI"
           If !Empty(M->EX9_DTPREV).And. M->&(cCampo) > M->EX9_DTPREV
              lRet := .F.
           ElseIf !Empty(M->EX9_DTDEVO) .And. M->&(cCampo) > M->EX9_DTDEVO
              lRet := .F.
           EndIf

           If !lRet
              cMsg += STR0123 + ENTER+; //STR0123 "A data de retirada deve ser menor ou igual que a data prevista de devolução e"
                      STR0124 //"a data de devolução."
           EndIf

      Case cCampo == "EX9_DTPREV" .Or. cCampo == "EX9_DTDEVO"
           If M->&(cCampo) < M->EX9_DTRETI
              cMsg += STR0125 + IIf(cCampo == "EX9_DTPREV",STR0127,"") + STR0126 //STR0125 "A data" //STR0126 " de devolução deve ser maior que a data de retirada " //STR0127 " prevista"
              lRet := .F.
           EndIf

   EndCase
End Sequence

If !lRet ; EasyHelp(cMsg,STR0024) ; EndIf // Atenção

Return lRet
 /*
Funcao      : AE104AgregaIT
Parametros  : Pedido e Sequência do Pedido
Retorno     : aITAgregado - Vetor com os itens agregados
Autor       : Allan Oliveira Monteiro
Data/Hora   : 07/07/2011  - 11:18
Revisao     :
Obs.        :
*/

*-------------------------------------------------------------*
Function AE104AgregaIT(cPedido, cSeqPed,cAto)
*-------------------------------------------------------------*
Local i , nQtdSldIT := 0
Local aITAgregado :={}, aPosIT := {}


   For i := 1 To Len(aItens)

      If cPedido == aItens[i][1][3] .And. cSeqPed == aItens[i][1][4]  .And. AllTrim(cAto) == AllTrim(aItens[i][1][12])
         AADD(aPosIT,i) //Adiciona a posição do item
         nQtdSldIT += aItens[i][1][5] //Saldo do item
      EndIf

   Next i

   AADD(aITAgregado,{nQtdSldIT,aPosIT})

Return aClone(aITAgregado)


Function AE104NFDev(cPreemb)

Local lRet       := .F.
Local aOrdTables := SaveOrd({"EE9","EES","WorkIp"})
Local cChaveEmb  := cChaveItNF := cItPedEmbF := ""

EE9->(DbSetOrder(2))
WorkIP->(DBSetOrder(1))

cChaveEmb := xFilial("EE9")+AvKey(EEC->EEC_PREEMB,"EE9_PREEMB")
EE9->(DbSeek(cChaveEmb))

Begin Sequence

Do While EE9->( !Eof() .AND. Left(&(IndexKey()),Len(cChaveEmb)) == cChaveEmb)
   If !Empty(EE9->EE9_NF)
      cItPedEmbF := EE9->EE9_PEDIDO+EE9->EE9_SEQUEN
      EES->(DbSetORder(1))
      cChaveItNF := xFilial("EES")+AvKey(EE9->EE9_PREEMB,"EES_PREEMB")+AvKey(EE9->EE9_NF,"EES_NRNF")
      If EES->(DbSeek(cChaveItNF))
         Do While EES->( !Eof() .AND. Left(&(IndexKey()),Len(cChaveItNF)) == cChaveItNF )
            If EES->EES_PEDIDO+EES->EES_SEQUEN == cItPedEmbF
               If EE9->EE9_SLDINI <> EES->EES_QTDE
                  lRet := .T.
                  Break
               EndIf
            EndIf
            EES->(DbSkip())
         EndDo
      EndIf
   EndIf
   EE9->(DbSkip())
EndDo

End Sequence

RestOrd(aOrdTables,.T.)

Return lRet

Static Function IntegAuto(cAlias, aAuto, nOpc)
Local nPos, i

        If (nPos := aScan(aAuto, {|x| x[1] == "AUTDELETA"})) > 0 .And. aAuto[nPos][2] == "S"
                nOpc := EXCLUIR
        EndIf
        If aScan(aAuto, {|x| x[1] $ "_FILIAL" }) == 0
                aAdd(aAuto, {cAlias + "_FILIAL", xFilial(cAlias), Nil})
        EndIf

        If EasySeekAuto(cAlias,aAuto,1)
                If nOpcAuto == INCLUIR
                        If cAlias == "EX9"
                                EasyHelp( STR0136 , STR0024) //"O container informado já está cadastrado."
                        Else
                                EasyHelp( STR0137 , STR0024) //"O item informado já está cadastrado."
                        EndIf
                        lMsErroAuto := .T.
                Else
                        Reclock(cAlias, .F.)
                        If nOpc == EXCLUIR
                                (cAlias)->(DbDelete())
                        Else
                                For i := 1 To Len(aAuto)
                                        (cAlias)->&(aAuto[i][1]) := aAuto[i][2]
                                Next
                        EndIf
                        (cAlias)->(MsUnlock())
                EndIf
          Else
                If nOpcAuto <> INCLUIR
                        If cAlias == "EX9"
                                EasyHelp( STR0138 , STR0024) //"O container informado não foi localizado."
                        Else
                                EasyHelp( STR0139 , STR0024) //"O item informado não foi localizado."
                        EndIf
                        lMsErroAuto := .T.
                Else
                        Reclock(cAlias, .T.)
                        For i := 1 To Len(aAuto)
                                (cAlias)->&(aAuto[i][1]) := aAuto[i][2]
                        Next
                        (cAlias)->(MsUnlock())
                EndIf
          EndIf

Return !lMsErroAuto

/*
Funcao      : IsOffShore(cProcesso)
Parametros  :
Retorno     : retorna se o processo encontrado é offShore
Objetivos   :
Autor       : Ramon Prado
Data/Hora   : 05/11/2020
Obs.        :
*/
Static Function IsOffShore(cProcesso)
Local aOrdEEC  :=SaveOrd("EEC")
Local lIsOffShore := .F.

EEC->(DbSetOrder(1)) //EEC_FILIAL+EEC_PREEMB
If EEC->(DbSeek(cFilBr+cProcesso))
   If EEC->EEC_INTERM == '1'
      lIsOffShore := .T.         
   EndIf   
EndIf

RestOrd(aOrdEEC,.T.)
Return lIsOffShore

*------------------------------------------------------------------------------------------------------------------*
*                                            FIM DO PROGRAMA EECAE104                                              *
*------------------------------------------------------------------------------------------------------------------*
/*
Funcao      : AE100WrkNF(cPedido,cSequen,cNota,cSerie)
Parametros  :
Retorno     : nenhum
Objetivos   :
Autor       : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora   : 09/11/2017
Obs.        :
*/
Function AE100WrkNF(cPedido,cSequen,cNota,cSerie,cFilNf, nSD1Quant, nSD1Total)

Local aOrd := SaveOrd({"SF2","SD2","EEM"})

Default cFilNf := xFilial("SD2")

Begin Sequence

	cNota := AvKey(cNota , "EEM_NRNF")
	cSerie:= AvKey(cSerie, "EEM_SERIE")
	cFilNf:= AvKey(cFilNf, "EEM_FILIAL")

	SF2->(dbSetOrder(1))
	If SF2->(dbSeek(xFilial("SF2")+AvKey(cNota,"F2_DOC")+AvKey(cSerie,"F2_SERIE")))

                WorkNF->(dbAppend())
                WorkNF->EEM_PREEMB:= EEC->EEC_PREEMB
                WorkNF->EEM_TIPOCA:= EEM_NF
                WorkNF->EEM_NRNF  := cNota
                WorkNF->EEM_SERIE := cSerie
                WorkNF->EEM_DTNF  := SF2->F2_EMISSAO
                WorkNF->EEM_TIPONF:= EEM_SD
                WorkNF->EEM_VLNF  := SF2->F2_VALBRUT
                WorkNF->EEM_VLMERC:= SF2->F2_VALMERC
                WorkNF->EEM_VLFRET:= SF2->F2_FRETE
                WorkNF->EEM_VLSEGU:= SF2->F2_SEGURO
                WorkNF->EEM_OUTROS:= SF2->F2_DESPESA
                WorkNF->EEM_MODNF := AModNot(SF2->F2_ESPECIE)

                If EECFlags("FATFILIAL")
                     WorkNF->EEM_FIL_NF := cFilNf
                EndIf

                If WorkNF->(FieldPos("EEM_CHVNFE")) > 0
                     WorkNF->EEM_CHVNFE := SF2->F2_CHVNFE
                EndIf
                
                EEM->(dbSetOrder(4)) //EEM_FILIAL, EEM_NRNF, EEM_SERIE, EEM_TIPOCA, EEM_TIPONF
                If EEM->(dbSeek(xFilial("EEM") + cNota + cSerie + EEM_NF + EEM_SD))
                     WorkNF->WK_RECNO := EEM->(Recno())
                Else
                     WorkNF->WK_RECNO := 0
                EndIf
                WorkNF->(dbCommit())
        EndIf

End Sequence

RestOrd(aOrd)

Return
