#Include "EEC.CH"
#Include "EECAE106.CH"


/*
Programa        : EECAE106.
Objetivo        : Rotinas - Manutenção de Embarques.
Autor           : Jeferson Barros Jr.
Data/Hora       : 16/09/04 13:42.
Obs.            :
*/

/*
Funcao      : AE106Man().
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Manutenção do EXL.
Autor       : Jeferson Barros Jr.
Data/Hora   : 26/01/99 13:58.
Revisao     :
Obs.        :
*/
*---------------------------------*
Function Ae106Man(cAlias,nReg,nOpc)
*---------------------------------*
Local lRet := .t.
Local aPos := {}
Local nChoice := 0
Local bOk     := {|| If(Ae106Valid(),(nChoice:=1, oDlg:End()),nil)},;
      bCancel := {|| oDlg:End()}

Private cTitulo:= AvTitCad("EXL")
Private aTela[0][0],aGets[0]

Begin Sequence

   Define MsDialog oDlg Title cTitulo From DLG_LIN_INI,DLG_COL_INI To DLG_LIN_FIM,DLG_COL_FIM Of oMainWnd Pixel
      aPos:= PosDlg(oDlg)
      EnChoice("EXL",nReg,nOpc,,,,,aPos,)
   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel)

End Sequence

Return lRet

/*
Funcao      : Ae106Grava().
Parametros  : lInclui -> .t. Inclusão.
                         .f. Alteração.
Retorno     : .t./.f.
Objetivos   : Verificar se todos os campos obrigatórios na enchoice do EXL, estão preenchidos.
Autor       : Jeferson Barros Jr.
Data/Hora   : 16/09/2004 15:20.
Revisao     :
Obs.        :
*/
*--------------------------*
Function Ae106Grava(lInclui)
*--------------------------*
Local lRet:=.t.

Default lInclui := .t.

Begin Sequence

   If lInclui
      EXL->(RecLock("EXL",.t.))
   Else // Alteração
      EXL->(DbSetOrder(1))
      If EXL->(DbSeek(xFilial("EXL")+M->EEC_PREEMB))
         EXL->(RecLock("EXL",.f.))
      Else
         EXL->(RecLock("EXL",.t.))
      EndIf
   EndIf

   AvReplace("M","EXL")
   //AOM - 08/03/2010
   If EXL->(FieldPos("EXL_CINSTA") > 0)
      If lInclui
         MSMM(,AVSX3("EXL_MINSTA", AV_TAMANHO),, M->EXL_MINSTA, INCMEMO,,, "EXL", "EXL_CINSTA")
      Else
         MSMM(EXL->EXL_CINSTA,,,,EXCMEMO)
         MSMM(,AVSX3("EXL_MINSTA", AV_TAMANHO),, M->EXL_MINSTA, INCMEMO,,, "EXL", "EXL_CINSTA")
      EndIf
   EndIf

   EXL->EXL_FILIAL := xFilial("EXL")
   EXL->EXL_PREEMB := M->EEC_PREEMB

   // BAK - Verificação se o campo na memoria foi criada
   If EECFlags("INTTRA") .And. Type("M->EXL_CBKCOM") == "C" .And. Type("M->EXL_CBKTCO") == "C" //  .And. Type("M->EXL_CBKCOM") == "C" .And. Type("EXL_CBKTCO") == "C"

      If !lInclui // Alteracao - registros excluir
         MSMM(M->EXL_CBKCOM,,,,EXCMEMO)
         MSMM(M->EXL_CBKTCO,,,,EXCMEMO)
      Endif

      MSMM(,AVSX3("EXL_BKCOM" ,AV_TAMANHO),,M->EXL_BKCOM ,INCMEMO,,,"EXL","EXL_CBKCOM")
      MSMM(,AVSX3("EXL_BKTPCO",AV_TAMANHO),,M->EXL_BKTPCO,INCMEMO,,,"EXL","EXL_CBKTCO")
   EndIf

   If EasyEntryPoint("EECAE106")
      ExecBlock("EECAE106",.F.,.F.,{"PE_GRVEXL",lInclui})
   EndIf
End Sequence

Return lRet

/*
Funcao      : Ae106Obrigat().
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Verificar se todos os campos obrigatórios na enchoice do EXL, estão preenchidos.
Autor       : Jeferson Barros Jr.
Data/Hora   : 16/09/2004 15:20.
Revisao     :
Obs.        :
*/
*---------------------*
Function Ae106Obrigat()
*---------------------*
Local lRet  := .t.
Local aOrd  := SaveOrd({"SX3"})
Local aPos  := {STR0006,STR0007,STR0008,STR0009,STR0010,STR0011,STR0012,STR0013,STR0014,STR0015} //"Primeira"###"Segunda"###"Terceira"###"Quarta"###"Quinta"###"Sexta"###"Setima"###"Oitava"###"Nona"###"Ultima"
Local cMsg, cFolder  := 1

Begin Sequence

   SX3->(DbSetOrder(1))
   If SX3->(DbSeek("EXL"))
      Do While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "EXL"
         If X3Uso(SX3->X3_CAMPO) .And. X3Obrigat(SX3->X3_CAMPO) .And. SX3->X3_CONTEXT <> "V"

            If Empty(M->&(AllTrim(SX3->X3_CAMPO)))
               cFolder := SX3->X3_FOLDER
               SX3->(DbSetOrder(2))
               SXA->(DbSetOrder(1))
               cMsg := ENTER
               cMsg += STR0016+AllTrim(AvSx3(SX3->X3_CAMPO,AV_TITULO))//"Campo '"###"'
               If (EECFlags("COMPLE_EMB") .And. !SX3->(DbSeek(IncSpace("EEC_EXL",AvSX3("X3_CAMPO",AV_TAMANHO),.F.))));
               .Or. Empty(SX3->X3_FOLDER) .or. !SXA->(DbSeek("EEC"+SX3->X3_FOLDER))
                  cMsg += STR0017 + ENTER + STR0018 // - botão 'Dados Complementares'
               Else
                  cMsg += STR0058 + ENTER + STR0018 // - Aba 'Dados Complementares'
               EndIF

               If cFolder $ "123456789"
                  cMsg += aPos[Val(cFolder)]+STR0019 //" Pasta"
               Else
                  cMsg += aPos[10]+STR0019 //" Pasta"
               EndIf

               cMsg := cMsg + Space(50-Len(cMsg))

               Help(1," ","OBRIGAT",,cMsg,3,0)
               lRet:=.f.
               Exit
            EndIf
         EndIf
         SX3->(DbSkip())
      EndDo
   EndIf

End Sequence

RestOrd(aOrd)

Return lRet


/*
Função      : AE100DespInt
Objetivo    : Despesas Internacionais.
Autor       : Alexsander Martins dos Santos
Data e Hora : 17/09/2004 às 17:41.
*/

Function AE100DespInt(nOpc)

Private oTree, aTree, oPanel, aDespesas, cOldPanel
Private aOldMemory := {}
Private aDespBuffer := {}//RMD - ROADMAP: C1 - 28/07/15 - Buffer para controlar os dados alterados em tela

Begin Sequence
   /* By JPP - 14/08/2005 - 16:00 - Se a data de embarque estiver preenchida exibir mensagem.*/
   If (nOpc == INCLUIR .or. nOpc == ALTERAR) .And. !Empty(M->EEC_DTEMBA)//data de embarque preenchida
      If lAltValPosEmb
         MsgInfo(STR0057,STR0023) // "Data de embarque preenchida. Apenas alguns campos das despesas internacionais poderão ser editados!" ###"Atencäo"
      Else
         MsgInfo(STR0056,STR0023) // "Data de embarque preenchida. Não será permitido editar as despesas internacionais!" ###"Atencäo"
      EndIf
   EndIf
   /* Gera o array do Tree View para Despesas Internacionais */
   Processa({|| DespIntTree(nOpc), STR0005, STR0002, .F. }) //"Aguarde", "Gerando Despesas Internacionais"

   /* Apresenta tela com Tree View */
   DespIntTela(nOpc)

End Sequence

Return(Nil)


/*
Função      : DespIntTree
Objetivo    : Geração do array para Tree View da Despesas Internacionais.
Retorno     : .T. Tree View gerado.
              .F. Tree View não gerado.
Autor       : Alexsander Martins dos Santos
Data e Hora : 20/09/2004 às 09:35.
*/

Static Function DespIntTree(nOpc)

Local aSaveOrd := SaveOrd("SX3", 2)
Local nPos     := 0

Begin Sequence

   aDespesas := X3DIReturn()

   ProcRegua(Len(aDespesas))

   /*
   Geração do Array aTree para Despesas Internacionais.
   */
   aTree := { { "0000",;
                STR0003,; //"Despesas Internacionais"
                "Raiz",;
                "FOLDER5",;
                "FOLDER6",;
                "0001" } }

   For nPos := 1 To Len(aDespesas)

      IncProc()

      aAdd( aTree, { "0001",;
                     AVSX3(aDespesas[nPos][2], AV_TITULO),;
                     aDespesas[nPos][1],;
                     "PMSDOC",;
                     "PMSDOC",;
                     "" } )

   Next

End Sequence

RestOrd(aSaveOrd)

Return(Nil)


/*
Função      : DespIntTela
Objetivo    : Tela com Tree View para Despesa Nacional.
Parametro   : nOpc = Opção de origem.
Autor       : Alexsander Martins dos Santos
Data e Hora : 20/09/2004 às 11:07.
*/

Static Function DespIntTela(nOpc)

Local oDlg, oPanel
Local bOk        := {|| nDIOpc := 1, If(DITelaVld(nOpc), oDlg:End(),)}
Local bCancel    := {|| nDIOpc := 0, oDlg:End()}
//JPM - colocado como private //Local cDespesa   := ""
Local nDespesa   := 0
Local aButtons   := {}
Local aMenuPopUp := {}
Local nPos       := 0
Local cMemo, i

Private aTela[0][0]
Private aGets[0]

Private aObjGets := {}
Private aCampos  := {}
Private nExlMdfr	:= 0

Private cInclusaoPosEmb := EasyGParam("MV_AVG0084",,"")
Private nDIOpc := 0
Private cDespesa   := ""
Private cDespTit   := "( "                          //NCF - 11/04/2011

Begin Sequence

   If (nOpc = INCLUIR .or. nOpc = ALTERAR) .and. Empty(M->EEC_DTEMBA)
      aAdd(aButtons, {"EXCLUIR", {|| DespIntDel() }, STR0020}) //"Limpar"###"Excluir"
   EndIf

   cMemo := STR0003 + Replicate(ENTER, 2) //"Despesas Internacionais"
   cMemo += STR0004 + ENTER               //"Utilize a estrutura ao lado para navegar pelas Despesas."

   Define MSDialog oDlg Title STR0003 + STR0021 + Transform(M->EEC_PREEMB, AVSX3("EEC_PREEMB", AV_PICTURE)) From DLG_LIN_INI,DLG_COL_INI To DLG_LIN_FIM,DLG_COL_FIM Of oMainWnd Pixel //"Despesas Internacionais" //" do Processo "

   oDlg:lEscClose := .F.

   aPos           := PosDlg(oDlg)
   aPos[1]        := 1
   aPos[2]        := 103

   oPanel:= TPanel():New(0, 0, "",oDlg, , .F., .F.,,, aPos[4], aPos[3])

   oTree          := AVTree(aTree,{aPos[1], 1, aPos[3], 102},, oPanel)
   oTree:bChange  := {|| DespIntFocus(oTree:GetCargo())}

   @ 1,103 Get oMemo Var cMemo MEMO HSCROLL SIZE aPos[4]-103, aPos[3] READONLY Of oPanel UPDATE Pixel
   oMemo:lWordWrap := .F.

   SX3->(DbSetOrder(2))
   For nDespesa := 1 To Len(aDespesas)

      cDespesa := aDespesas[nDespesa][1]

      @ aPos[1], aPos[2] ScrollBox &("oPanel"+cDespesa) Vertical Size  aPos[3],aPos[4]-103 Of oPanel Centered Pixel

      aCampos := { "EXL_MD" + cDespesa,;    //Moeda da Despesa.
                   "EXL_VD" + cDespesa,;    //Valor da Despesa na moeda da despesa.
                   aDespesas[nDespesa][2],; //Valor da Despesa na moeda do processo.
                   "EXL_PA" + cDespesa,;    //Paridade.
                   "EXL_EM" + cDespesa,;    //Empresa.
                   "EXL_DE" + cDespesa,;    //Nome da Empresa.
                   "EXL_FO" + cDespesa,;    //Fornecedor.
                   "EXL_LF" + cDespesa,;    //Loja do Fornecedor.
                   "EXL_CP" + cDespesa,;    //Condição de Pagamento.
                   "EXL_DP" + cDespesa,;    //Dias de Pagamento.
                   "EXL_DC" + cDespesa,;    //Descrição da Condição de Pagamento.
                   "EXL_DT" + cDespesa }    //Data Base.

      //By JPM - 28/03/05 - Campo de descrição da despesa.(geralmente para despesas customizadas)
      If SX3->(DbSeek("EXL_DS" + cDespesa)) .And. EXL->(FieldPos("EXL_DS" + cDespesa)) > 0
         AAdd(aCampos,Nil)
         AIns(aCampos,1)
         aCampos[1] := "EXL_DS" + cDespesa
      EndIf

      /////////////////////////////////////////////
      //Campos para a integração com o Financeiro//
      /////////////////////////////////////////////
      If IsIntEnable("001") //WFS
         If SX3->(DbSeek("EXL_TIT" + cDespesa)) .And. EXL->(FieldPos("EXL_TIT" + cDespesa)) > 0
            AAdd(aCampos,Nil)
            AIns(aCampos,1)
            aCampos[1] := "EXL_TIT" + cDespesa
         EndIf
         If SX3->(DbSeek("EXL_NAT" + cDespesa)) .And. EXL->(FieldPos("EXL_NAT" + cDespesa)) > 0
            AAdd(aCampos,Nil)
            AIns(aCampos,1)
            aCampos[1] := "EXL_NAT" + cDespesa
         EndIf
      EndIf
//    aAdd(aOldMemory, {aDespesas[nDespesa][2], M->&(aDespesas[nDespesa][2])})

      //RRC - 13/08/2013 - Integração SIGAEEC x SIGAESS
      If EasyGParam("MV_ESS0014",,.T.) .And. AvFlags("CONTROLE_SERVICOS_AQUISICAO").And. EXL->(FieldPos("EXL_NBS"+cDespesa)) > 0
         AAdd(aCampos,"EXL_NBS" + cDespesa)
         //RMD - ROADMAP: C1 - 25/05/15 - Campos para registrar o Fornecedor Internacional
         If EXL->(FieldPos("EXL_FINT"+cDespesa) > 0 .And. FieldPos("EXL_FLOJ"+cDespesa) > 0)
            AAdd(aCampos,"EXL_FINT" + cDespesa)
            AAdd(aCampos,"EXL_FLOJ" + cDespesa)
         EndIf
         //RMD - ROADMAP: C1 - 30/06/15 - Campos para registrar a moeda do Pedido de Serviços
         If EXL->(FieldPos("EXL_SMOE"+cDespesa) > 0 .And. FieldPos("EXL_SPAR"+cDespesa) > 0 .And. FieldPos("EXL_SVAL"+cDespesa) > 0 .And. FieldPos("EXL_STAX"+cDespesa) > 0)
            AAdd(aCampos,"EXL_SMOE" + cDespesa)
            AAdd(aCampos,"EXL_SPAR" + cDespesa)
            AAdd(aCampos,"EXL_SVAL" + cDespesa)
            AAdd(aCampos,"EXL_STAX" + cDespesa)
         EndIf
      EndIf

      // ** JPM - 29/05/06 - ponto de entrada para acrescentar campos customizados
      If EasyEntryPoint("EECAE106")
         ExecBlock("EECAE106",.F.,.F.,{"CAMPOS_DESPINT"})
      EndIf

      aEval(aCampos, {|x| If(Type(x) = "U", M->&(x) := Criavar(x),;
                                            (aAdd(aOldMemory, {x, M->&(x)}),aAdd(aDespBuffer, {x, M->&(x)})))})//RMD - ROADMAP: C1 - 28/07/15 - Registra o valor atual do campo no Buffer

      aAdd(aObjGets, {})

      DespIntEnchoice(aCampos, &("oPanel"+cDespesa), nOpc, aObjGets[nDespesa], nDespesa)

      &("oPanel"+cDespesa):Hide()

      //RRC - 19/08/2013 - Inicializa os campos de NBS utlizados pelo SIGAESS que fazem parte da rotina de embarque
      If EasyGParam("MV_ESS0014",,.T.) .And. AvFlags("CONTROLE_SERVICOS_AQUISICAO").And. EXL->(FieldPos("EXL_NBS"+cDespesa)) > 0 .And. Empty(M->&("EXL_NBS"+cDespesa))
         M->&("EXL_NBS"+cDespesa) := AE106IniVal("EXL_NBS"+cDespesa)
      EndIf
   Next

   //wfs - alinhamento de tela
   oDlg:lMaximized := .T.
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   Activate MSDialog oDlg On Init (oTree:TreeSeek("Raiz"), EnchoiceBar(oDlg, bOk, bCancel,, aButtons))

   If nDIOpc = 0
      aEval(aOldMemory, {|x| M->&(x[1]) := x[2]})
   EndIf

   // ** JPM - 29/05/06 - pto de entrada para tratamentos adicionais.
   If EasyEntryPoint("EECAE106")
      ExecBlock("EECAE106",.F.,.F.,{"APOS_TELA_DI"})
   EndIf
End Sequence

Return(Nil)


/*
Função      : DespIntFocus
Objetivo    : Função envocada pelo evento bChance(Focus) do objeto oTree, onde irá inibir o objeto oPanel(anterior)
              e exibir o oPanel(da posição do nivel do Tree View).
Autor       : Alexsander Martins dos Santos
Data e Hora : 20/09/2004 às 11:07.
*/

Static Function DespIntFocus(cId)

Local cDespesa := ""

Begin Sequence

   cDespesa := AllTrim(cId)

   If cOldPanel <> Nil
      &(cOldPanel):Hide()
   EndIf

   &(cOldPanel := If(cDespesa == "Raiz", "oMemo", "oPanel"+cDespesa)):Show()

End Sequence

Return(Nil)


/*
Função      : DespIntEnchoice
Objetivo    : Simular a Enchoice(Protheus) para edição de campos.
Parametro   : aCampos, array que contem os campos que devem ser apresentados na tela.
            : oPanel, objeto Panel que objetos devem se referenciar.
Autor       : Alexsander Martins dos Santos
Date e Hora : 21/09/2004 às 11:06
*/

Static Function DespIntEnchoice(aCampos, oPanel, nOpc, aDespGets, nDespesa)

Local nCampo    := 0
Local aSaveOrd  := SaveOrd("SX3", 2)
Local nLISay    := 16
Local nLIGet    := 05, /*oSay, oGet,*/ xVarAux, cVarF3
Local lCambDspLiq := .F.                                             //NCF - 11/04/2011

Private oSay, oGet //WR - 22/06/2006
Private lInclusaoPosEmb := (aDespesas[nDespesa][2] $ cInclusaoPosEmb)

lCambDspLiq     := AE106CambLiq(aDespesas[nDespesa][2],nDespesa)              //NCF - 11/04/2011

Begin Sequence

   For nCampo := 1 To Len(aCampos)

      SX3->(dbSeek(aCampos[nCampo]))

      oSay                 := TSAY():Create(oPanel)
      oSay:cName           := "oSay" + aCampos[nCampo]
      oSay:cCaption        := SX3->X3_TITULO
      oSay:nLeft           := 10
      oSay:nTop            := nLISay+((nCampo*28)-30)
      oSay:nWidth          := 150
      oSay:nHeight         := 20
      oSay:lShowHint       := .F.
      oSay:lReadOnly       := .F.
      oSay:Align           := 0
      oSay:lVisibleControl := .T.
      oSay:lWordWrap       := .F.
      oSay:lTransparent    := .F.

      cVarF3 := Eval({|x| If(Empty(x), Nil, x)}, SX3->X3_F3)
      xVarAux := &("M->"+aCampos[nCampo])

      //Exibição do campo virtual quando não há conteúdo em memória
      If Left(aCampos[nCampo],6) == "EXL_DC" .And. Empty(xVarAux)
         xVarAux := Space(SX3->X3_TAMANHO)
      EndIf

      // ** JPM - Permitir ComboBox, no caso de campos do EXL customizados
      If !Empty(SX3->X3_CBOX)
         @ nLIGet+((nCampo*14)-15), 50 ComboBox oGet Var xVarAux Items ComboX3Box(aCampos[nCampo]) /*Size 30,40*/ Of oPanel Pixel
         //oGet:nWidth          := If(Left(aCampos[nCampo],6)=="EXL_DP",40,0)  // By JPP 13/10/2006 - 09:00 - O sistema estava dimensionando errado todos os campos Dias Pagamento
      Else
         @ nLIGet+((nCampo*14)-15), 50 MSGet oGet Var xVarAux PICTURE SX3->X3_PICTURE F3 cVarF3 Of oPanel Pixel
         //oGet:nWidth          := If(Left(aCampos[nCampo],6)=="EXL_DP",40,0)  // By JPP 13/10/2006 - 09:00 - O sistema estava dimensionando errado todos os campos Dias Pagamento
         oGet:Picture         := AllTrim(SX3->X3_PICTURE)  // By JPP 13/10/2006 - 09:00 - O sistema estava se perdendo a definição das pictures
      EndIf

      If Left(aCampos[nCampo],6)=="EXL_DP"
         oGet:nWidth       := 40
      EndIf
      
      IF aCampos[nCampo] == 'EXL_MDFR' .And. Valtype(nLISay) == 'N' 
      	nExlMdfr := nLIGet+((nCampo*14)-15)      	
      EndIf	

      oGet:lReadOnly       := (nOpc < 3 .or. nOpc > 4) .or. ReadOnlyDI(aCampos[nCampo],aDespesas[nDespesa][2]) .or. lCambDspLiq .Or. AE106CpNoEd( aCampos[nCampo] )
      oGet:cVariable       := "M->" + aCampos[nCampo]
      oGet:bSetGet         := &("{|u| If(pCount() > 0, M->" + aCampos[nCampo] + " := u, M->"+aCampos[nCampo]+")}")
      oGet:bWhen           := &("{|| "+SX3->(If(Empty(X3_WHEN), ".T.", AllTrim(SX3->X3_WHEN)))+"}")
      oGet:bValid          := &("{|| "+SX3->(If(Empty(X3_VALID), If(Empty(SX3->X3_VLDUSER),".T.", AllTrim(SX3->X3_VLDUSER)), AllTrim(SX3->X3_VALID)))+"}")
      /*
      Nopado para ter funcionalidade na V811.
      oGet                 := TGET():Create(oPanel)
      oGet:cF3             := Eval({|x| If(Empty(x), Nil, x)}, SX3->X3_F3)
      oGet:cName           := "oGet" + aCampos[nCampo]
      oGet:nLeft           := 100
      oGet:nTop            := nLIGet + ((nCampo * 31) - 31)
      oGet:nHeight         := 22
      oGet:lShowHint       := .F.
      // JPM - 03/03/05 oGet:lReadOnly       := (nOpc < 3 .or. nOpc > 4) .or. !Empty(M->EEC_DTEMBA)
      oGet:lReadOnly       := (nOpc < 3 .or. nOpc > 4) .or. ReadOnlyDI(aCampos[nCampo])
      oGet:Align           := 0
      oGet:cVariable       := "M->" + aCampos[nCampo]
      oGet:bSetGet         := &("{|u| If(pCount() > 0, M->" + aCampos[nCampo] + " := u, M->"+aCampos[nCampo]+")}")
      oGet:lVisibleControl := .T.
      oGet:lPassword       := .F.
      oGet:Picture         := AllTrim(SX3->X3_PICTURE)
      oGet:lHasButton      := .T.
      oGet:bWhen           := &("{|| "+SX3->(If(Empty(X3_WHEN), ".T.", AllTrim(SX3->X3_WHEN)))+"}")
      oGet:bValid          := &("{|| "+SX3->(If(Empty(X3_VALID), ".T.", AllTrim(SX3->X3_VALID)))+"}")
      */

      //WR - 22/06/2006 *** Permitir alterações no Get das despesas
      If EasyEntryPoint("EECAE106")
         ExecBlock("EECAE106",.F.,.F.,{"GET_DESPINT"})
      EndIf

      aAdd(aDespGets, oGet)     

   Next
   
   If Valtype(oPanel) == 'O'
   	@ nExlMdfr+2, 115 Say oSay Var "("+M->EEC_MOEDA+")." Size 20, 07 Of oPanel Pixel   	
   Endif	

End Sequence

RestOrd(aSaveOrd)

Return(Nil)


/*
Função      : DITelaVld(nOpc)
Objetivo    : Validar os dados da tela, no pressionamento do botão Ok.
Parametro   : nOpc. Opção de origem.
Retorno     : .T., dados consistentes.
              .F., dados inconsistentes.
Autor       : Alexsander Martins dos Santos
Data e Hora : 01/11/2004 às 20:58.
*/

Static Function DITelaVld(nOpc)

Local lRet := .F.
Local nPos := 0
Local lRetPto
Private aDespesas

Begin Sequence

   If nOpc = INCLUIR .or. nOpc = ALTERAR

      aDespesas := X3DIReturn()

      For nPos := 1 To Len(aDespesas)

         Do Case

            Case !Empty(M->&("EXL_CP"+aDespesas[nPos][1])) .and. Empty(M->&("EXL_EM"+aDespesas[nPos][1]))

               oTree:TreeSeek(aDespesas[nPos][1])
               MsgInfo(STR0022, STR0023) //"No preenchimento da condição de pagamento os dados da empresa devem ser informados."###"Atenção"
               Break

            Case !Empty(M->&("EXL_DT"+aDespesas[nPos][1])) .and. M->&("EXL_DT"+aDespesas[nPos][1]) < M->EEC_DTPROC

               oTree:TreeSeek(aDespesas[nPos][1])
               MsgInfo(STR0024, STR0023) //"A data base, não pode ser menor que data do processo de embarque."###"Atenção"
               Break

            Case !Empty(M->&("EXL_MD"+aDespesas[nPos][1])) .and. BuscaTaxa(M->&("EXL_MD"+aDespesas[nPos][1]), dDataBase,, .F.) = 0

               //WFS 12/12/08 ---
               If AllTrim(M->&("EXL_MD"+aDespesas[nPos][1])) <> AllTrim(EasyGParam("MV_SIMB1"))
                  oTree:TreeSeek(aDespesas[nPos][1])
                  MsgInfo(STR0025, STR0023) //"Para moeda informada, não existe Taxa de Conversão Cambial."
                  Break
               EndIf  //---

               If M->&("EXL_MD"+aDespesas[nPos][1]) <> M->EEC_MOEDA .and. BuscaTaxa(M->EEC_MOEDA, dDataBase,, .F.) = 0
                  oTree:TreeSeek(aDespesas[nPos][1])
                  MsgInfo(STR0026+M->&("EXL_MD"+aDespesas[nPos][1])+STR0027, STR0023) //"A taxa de conversão cambial da moeda "###" informada no Embarque não foi encontrada. Informe a taxa no cadastro de Contação de Moedas."###"Atenção"
                  Break
               EndIf

            Case M->&("EXL_VD"+aDespesas[nPos][1]) < 0 .or. M->&(aDespesas[nPos][2]) < 0 .or. M->&("EXL_PA"+aDespesas[nPos][1]) < 0

               oTree:TreeSeek(aDespesas[nPos][1])
               MsgInfo(STR0028+AVSX3(aDespesas[nPos][2], AV_TITULO)+STR0029, STR0023) //"Os campos, Valor da Despesa/ "###"/Paridade não podem conter valores negativos."###"Atenção"
               Break

            Case SX3->(DbSeek("EXL_NAT" + cDespesa)) .And. EXL->(FieldPos("EXL_NAT" + cDespesa)) > 0
               If IsIntEnable("001")
                  If M->&("EXL_VD"+aDespesas[nPos][1]) > 0 .and. Empty(M->&("EXL_NAT"+aDespesas[nPos][1]))
                     oTree:TreeSeek(aDespesas[nPos][1])
                     MsgInfo(STR0061, STR0023) //###"Atenção"//STR0061	"O campo Natureza deve ser preenchido."
                     Break
                  EndIf
               EndIf
         End Case

      Next

      // ** JPM - 29/05/06 - pto de entrada para validar tela de despesas internacionais.
      If EasyEntryPoint("EECAE106")
         If ValType((lRetPto := ExecBlock("EECAE106",.F.,.F.,{"VALID_TELA_DI"}))) = "L" .And. !lRetPto
            Break
         EndIf
      EndIf

   EndIf

   lRet := .T.

End Sequence

Return(lRet)


/*
Função      : DespIntVld()
Objetivo    : Função imposta no X3_VALID dos campos que compõem a rotina de Despesas Internacionais.
Retorno     : .T., houve consistencia nos dados.
              .F., dados inconsistentes.
Autor       : Alexsander Martins dos Santos
Data e Hora : 21/09/2004 às 17:14.
*/

Function DespIntVld()

Local lRet     := .F.
Local aSaveOrd := SaveOrd({"SY5", "SY6", "SYF"})
Local nPos     := 0
Local cGet     := ReadVar()
Local cDespesa
Local nParcs   := 0

Local oGet
Local lModified := .F.
Begin Sequence

   If Type("aDespesas") = "U"
      lRet := .T.
      Break
   EndIf
   //MFR 07/08/2019 OSSME-3579
   If len(cGet) >= 9
      cDespesa  := Right(cGet, -9+Len(cGet))
   Else
      cDespesa := cGet
   EndIf
   //ER - 04/12/2007 - Verifica se existe mais que 10 parcelas de cambio.
   SX3->(DbSetOrder(2))
   If SX3->(DbSeek("Y6_PERC_01"))
      While SX3->(!EOF()) .and. Left(SX3->X3_CAMPO,8) == "Y6_PERC_"
         nParcs ++
         SX3->(DbSkip())
      EndDo
   EndIf

   Do Case

      Case Left(cGet, 9) = "M->EXL_MD"

         oGet := aObjGets[aScan(aDespesas, {|x| x[1] == cDespesa}), aScan(aCampos, SubStr(cGet, 4, 6))]

         If Empty(&cGet)
            M->&("EXL_VD"+cDespesa) := 0
            M->&("EXL_PA"+cDespesa) := 0
            lRet := .T.
            Break
         EndIf

         /*
         SYF->(dbSetOrder(1))

         If !SYF->(dbSeek(xFilial()+&cGet))
            MsgStop(STR0031, STR0023) //"Moeda não cadastrada no cadastro de moedas."###"Atenção"
            Break
         EndIf
         */

         If !ExistCPO("SYF", &cGet, 1)
            Break
         EndIf

         //WFS 12/12/08 ---
         If AllTrim(&cGet) <> AllTrim(EasyGParam("MV_SIMB1"))
            If BuscaTaxa(&cGet, dDataBase,, .F.) = 0
               EECMsg(STR0032+&cGet+STR0033, STR0023) //"A taxa de conversão da moeda "###" não foi encontrada. Informe a taxa no cadastro de Cotação de Moedas."###"Atenção"
               Break
            EndIf

            If &cGet <> M->EEC_MOEDA .and. BuscaTaxa(M->EEC_MOEDA, dDataBase,, .F.) = 0
               EECMsg(STR0032+M->EEC_MOEDA+STR0034, STR0023) //"A taxa de conversão da moeda "###" informada no Embarque, não foi encontrada. Informe a taxa no cadastro de Cotação de Moedas."###"Atenção"
               Break
            EndIf
         EndIf
         /*
         If !Empty(M->&("M->EXL_VD"+cDespesa))
            If Empty(M->&(aDespesas[nPos := aScan(aDespesas, {|x| x[1] == cDespesa})][2]))
               M->&(aDespesas[nPos][2]) := DICalculo1(cDespesa)
            EndIf
            M->&("EXL_PA"+cDespesa) := DICalculo2(cDespesa)
            Break
         EndIf
         */

         lModified := aScan(aDespBuffer, {|x| x[1] == "EXL_MD"+cDespesa .And. x[2] <> &("M->EXL_MD"+cDespesa) }) > 0

         If /*oGet:lModified .Or. */lModified

            If !Empty(M->&(aDespesas[nPos := aScan(aDespesas, {|x| x[1] == cDespesa})][2]))
               M->&("EXL_VD"+cDespesa) := DICalculo3(cDespesa)
               M->&("EXL_PA"+cDespesa) := DICalculo2(cDespesa)
            EndIf

            //RMD - ROADMAP: C1 - 30/06/15 - Campos para registrar a moeda do Pedido de Serviços
	        If EXL->(FieldPos("EXL_SMOE"+cDespesa) > 0 .And. FieldPos("EXL_SPAR"+cDespesa) > 0 .And. FieldPos("EXL_SVAL"+cDespesa) > 0 .And. FieldPos("EXL_STAX"+cDespesa) > 0 )
	        	If Empty(M->&("EXL_SMOE"+cDespesa)) .Or. (M->&("EXL_SMOE"+cDespesa) <> &cGet .And. MsgYesNo("Deseja atualizar a moeda do Pedido de Serviços?", "Aviso"))
	        		//Atualiza a moeda do Pedido de Serviços com a Moeda da despesa
	        		M->&("EXL_SMOE"+cDespesa) := &(cGet)
	        		M->&("EXL_SPAR"+cDespesa) := 1
	        		M->&("EXL_SVAL"+cDespesa) := M->&("EXL_VD"+cDespesa)
				ElseIf !Empty(M->&("EXL_SMOE"+cDespesa)) .And. M->&("EXL_SMOE"+cDespesa) <> &cGet
					//Caso a moeda do Pedido de Serviços seja diferente da nova moeda informada para a despesa, atualiza o valor e a paridade
	        		//M->&("EXL_SPAR"+cDespesa) := BuscaTaxa(M->&("EXL_MD"+cDespesa), dDataBase,, .F.) / BuscaTaxa(M->&("EXL_SMOE"+cDespesa), dDataBase,, .F.)
	        		//M->&("EXL_SVAL"+cDespesa) := M->&("EXL_VD"+cDespesa) * M->&("EXL_SPAR"+cDespesa)
	        		//NCF - 15/10/2015 - Nopado acima e reescrito abaixo (calcular o valor pela taxa e não pela paridade pois para o Siscoserv devemos mandar a Taxa.
	        		M->&("EXL_STAX"+cDespesa) := BuscaTaxa(M->&("EXL_SMOE"+cDespesa), dDataBase,, .F.)
	        		M->&("EXL_SVAL"+cDespesa) := M->&("EXL_VD"+cDespesa) * BuscaTaxa(M->&("EXL_MD"+cDespesa), dDataBase,, .F.) / M->&("EXL_STAX"+cDespesa)
	        		M->&("EXL_SPAR"+cDespesa) := M->&("EXL_SVAL"+cDespesa) / M->&("EXL_VD"+cDespesa)
	        	ElseIf Empty(&cGet)
	        		M->&("EXL_SMOE"+cDespesa) := ""
	        		M->&("EXL_SPAR"+cDespesa) := 0
	        		M->&("EXL_SVAL"+cDespesa) := 0
	        	EndIf
	        EndIf

         EndIf

      Case Left(cGet, 9) = "M->EXL_VD"

         If Empty(&cGet)
            M->&("EXL_PA"+cDespesa) := 0
            If cDespesa == "FR"
			     M->EEC_FRPREV := 0
			  ElseIF cDespesa == "SE"
			     M->EEC_SEGPRE := 0
			  ElseIF cDespesa == "FA"
			     M->EEC_FRPCOM := 0
			  ElseIF cDespesa == "DI"
			     M->EEC_DESPIN := 0
 			  EndIF
            lRet := .T.
            Break
         EndIf

         /*
         If &cGet < 0
            MsgStop(STR0035, STR0023) //"Não é permitido informar valor negativo para o Valor de Despesa."###"Atenção"
            Break
         EndIf
         */
         If !Positivo()
            Break
         EndIf

         If Empty(M->&(aDespesas[nPos := aScan(aDespesas, {|x| x[1] == cDespesa})][2]))
            M->&(aDespesas[nPos][2]) := DICalculo1(cDespesa)
         EndIf

         If !Empty(M->&("EXL_PA"+cDespesa))
            M->&(aDespesas[aScan(aDespesas, {|x| x[1] = cDespesa})][2]) := M->&("EXL_VD"+cDespesa)/M->&("EXL_PA"+cDespesa)
            lRet := .T.
            //Break // - EJA - 10/08/2017 - Deve continuar para preencher o campo Val.Ped.Ser
         ELSE
            M->&("EXL_PA"+cDespesa) := DICalculo2(cDespesa)
         EndIf

		//RMD - ROADMAP: C1 - 30/06/15 - Campos para registrar a moeda do Pedido de Serviços
        If EXL->(FieldPos("EXL_SMOE"+cDespesa) > 0 .And. FieldPos("EXL_SPAR"+cDespesa) > 0 .And. FieldPos("EXL_SVAL"+cDespesa) > 0 .And. FieldPos("EXL_STAX"+cDespesa) > 0)
	        //Atualiza o valor do Pedido de Serviços a partir do valor da despesa, considerando a paridade
        	If Empty(M->&("EXL_SVAL"+cDespesa)) .Or. M->&("EXL_SVAL"+cDespesa) <> &cGet
        		M->&("EXL_SVAL"+cDespesa) := M->&("EXL_VD"+cDespesa) * M->&("EXL_SPAR"+cDespesa)
        	EndIf
        EndIf

      Case (nPos := aScan(aDespesas, {|x| x[2] == SubStr(cGet, 4)})) > 0

         If Empty(&cGet)
            //&cGet := DICalculo1(aDespesas[nPos][1])
            M->&("EXL_VD"+aDespesas[nPos][1]) := 0
            M->&("EXL_PA"+aDespesas[nPos][1]) := 0
            lRet := .T.
            Break
         EndIf

         M->&("EXL_PA"+aDespesas[nPos][1]) := DICalculo2(aDespesas[nPos][1])

      Case Left(cGet, 9) = "M->EXL_PA"

         oGet := aObjGets[aScan(aDespesas, {|x| x[1] == cDespesa}), aScan(aCampos, SubStr(cGet, 4, 6))]

         If Empty(&cGet)
            //&cGet := DICalculo2(cDespesa)
            M->&("EXL_VD"+cDespesa) := 0
            lRet := .T.
            Break
         EndIf

         /*
         If &cGet < 0
            MsgStop(STR0036, STR0023) //"Não é permitido informar valor negativo para a Paridade."###"Atenção"
            Break
         EndIf
         */

         If !Positivo()
            Break
         EndIf

         /*
         If !Empty(M->&(aDespesas[nPos := aScan(aDespesas, {|x| x[1] == cDespesa})][2]))
            M->&("EXL_VD"+cDespesa) := (&cGet*M->&(aDespesas[aScan(aDespesas, {|x| x[1] = cDespesa})][2]))
         EndIf
         */

         lModified := aScan(aDespBuffer, {|x| x[1] == "EXL_PA"+cDespesa .And. x[2] <> &("M->EXL_PA"+cDespesa) }) > 0

         If /*oGet:lModified .Or. */lModified

            If !Empty(M->&(aDespesas[nPos := aScan(aDespesas, {|x| x[1] == cDespesa})][2])) .and. !Empty(M->&("EXL_VD"+cDespesa))
               DIAtuDesp(cDespesa)
            EndIf

         EndIf

      Case Left(cGet, 9) = "M->EXL_EM"

         If Empty(&cGet)
            M->&("EXL_DE"+cDespesa) := ""
            M->&("EXL_FO"+cDespesa) := ""
            M->&("EXL_LF"+cDespesa) := ""
            lRet := .T.
            Break
         EndIf

         If !ExistCPO("SY5", &cGet, 1)
            Break
         EndIf

         SY5->(dbSetOrder(1))
         SY5->(dbSeek(xFilial()+&cGet))

         M->&("EXL_DE"+cDespesa) := SY5->Y5_NOME
         M->&("EXL_FO"+cDespesa) := SY5->Y5_FORNECE
         M->&("EXL_LF"+cDespesa) := SY5->Y5_LOJAF

         If SY5->(Empty(Y5_FORNECE) .or. Empty(Y5_LOJAF))
            EECMsg(STR0038, STR0023, "MsgStop") //"Empresa não permitida por não haver vinculo com o Fornecedor/Loja."###"Atenção"
            Break
         EndIf

         //RMD - ROADMAP: C1 - 25/05/15 - Campos para registro do Fornecedor Internacional na integração com SISCOSERV
         IF EXL->(FieldPos("EXL_NBS"+cDespesa) > 0 .And. FieldPos("EXL_FINT"+cDespesa) > 0 .And. FieldPos("EXL_FLOJ"+cDespesa) > 0)
//           MFR 24/04/2017 TE-5432 WCC-515090
//	         If EasyGParam("MV_ESS0014",,.T.) .And. AvFlags("CONTROLE_SERVICOS_AQUISICAO").And. Empty(M->&("EXL_FINT"+cDespesa)) .Or. (M->&("EXL_FINT"+cDespesa) <> M->&("EXL_FO"+cDespesa))
	         If EasyGParam("MV_ESS0014",,.T.) .And. AvFlags("CONTROLE_SERVICOS_AQUISICAO").And. (( Empty(M->&("EXL_FINT"+cDespesa))) .Or. (M->&("EXL_FINT"+cDespesa) <> M->&("EXL_FO"+cDespesa)) )
	             SA2->(DbSetOrder(1))
	             SA2->(DbSeek(xFilial("SA2") + M->&("EXL_FO"+cDespesa) + M->&("EXL_LF"+cDespesa)))
	             //IF cPaisLoc == "BRA" .AND. SA2->A2_PAIS == "105"
	                //EasyHelp("Ao informar um Fornecedor Nacional para esta despesa, a integração com o SISCOSERV não será executada.","Atenção")
	                //Break
	             IF MsgYesNo("Deseja atualizar o Fornecedor Internacional para registro no SISCOSERV com os dados do Fornecedor informado?", "Aviso")
		             M->&("EXL_FINT"+cDespesa) := M->&("EXL_FO"+cDespesa)
		             M->&("EXL_FLOJ"+cDespesa) := M->&("EXL_LF"+cDespesa)
	             EndIF
	         EndIf
         EndIF

      Case Left(cGet, 9) = "M->EXL_CP"

         If Empty(&cGet)
            M->&("EXL_DC"+cDespesa) := ""
            M->&("EXL_DP"+cDespesa) := 0
            lRet := .T.
            Break
         EndIf

         If !ExistCPO("SY6", &cGet, 1)
            Break
         EndIf

         SY6->(dbSetOrder(1)) //Y6_FILIAL, Y6_COD, Y6_DIAS_PA, R_E_C_N_O_, D_E_L_E_T__
         SY6->(dbSeek(xFilial() + AVKEY(&cGet,"Y6_COD") + Str(M->&("EXL_DP"+cDespesa), AVSX3("EXL_DP"+cDespesa, AV_TAMANHO))))

         /*
         If Empty(M->&("EXL_DP"+Right(cGet, 2)))
            If !SY6->(dbSeek(xFilial()+&cGet))
               MsgStop(STR0039, STR0023) //"Condição de pagamento invalida."###"Atenção"
               Break
            EndIf
         Else
            If !SY6->(dbSeek(xFilial()+&cGet+Str(M->&("EXL_DP"+Right(cGet, 2)), 3)))
               MsgStop(STR0039, STR0023) //"Condição de pagamento invalida."###"Atenção"
               Break
            EndIf
         EndIf
         */

         If SY6->Y6_TIPO = "3"
            //For nPos := 1 To 10
            For nPos := 1 To nParcs
               If SY6->&("Y6_DIAS_" + StrZero(nPos, 2)) < 0
                  EECMsg(STR0040, STR0023, "MsgStop") //"A condição de pagamento selecionada, contém uma ou mais parcelas de adiantamento. Informe uma condição de pagamento onde não haja parcelas de adiantamento."###"Atenção"
                  Break
               EndIf
            Next
         EndIf

         M->&("EXL_DC"+cDespesa) := MSMM(SY6->Y6_DESC_P, 50)
         M->&("EXL_DP"+cDespesa) := SY6->Y6_DIAS_PA

      Case Left(cGet, 9) = "M->EXL_DP"

         If Empty(M->&("EXL_CP"+cDespesa)) .and. Empty(&cGet)
            lRet := .T.
            Break
         EndIf

         If !ExistCPO("SY6", M->&("EXL_CP"+cDespesa)+Str(&cGet, 3), 1)
            Break
         EndIf

         SY6->(dbSetOrder(1))
         SY6->(dbSeek(xFilial()+M->&("EXL_CP"+cDespesa)+Str(&cGet, 3)))

         M->&("EXL_DC"+cDespesa) := MSMM(SY6->Y6_DESC_P, 50)

      Case Left(cGet, 9) = "M->EXL_DT"

         If &cGet < M->EEC_DTPROC
            EECMsg(STR0024, STR0023, "MsgStop") //"A data base, não pode ser menor que data do processo de embarque."###"Atenção"
            Break
         EndIf

      Case "EXL_SVAL" $ cGet
      	cDespesa := Right(AllTrim(cGet), 2)
      	If !Empty(M->&("EXL_SVAL"+cDespesa))
			If !Empty(M->&("EXL_MD"+cDespesa))
				//RMD - ROADMAP: C1 - 30/06/15 - Atualiza a paridade com o valor da despesa a partir do novo valor do Pedido de Serviços
		        M->&("EXL_SPAR"+cDespesa) := M->&("EXL_SVAL"+cDespesa) / M->&("EXL_VD"+cDespesa)
			Else
				MsgInfo("Moeda da despesa não informada.", "Aviso")
				Break
			EndIf
	  	EndIf

      Case "EXL_SPAR" $ cGet
      	/*cDespesa := Right(AllTrim(cGet), 2)
      	If !Empty(M->&("EXL_SPAR"+cDespesa))
	      	If !Empty(M->&("EXL_MD"+cDespesa))
				//RMD - ROADMAP: C1 - 30/06/15 - Atualiza o valor do Pedido de Serviços considerando a nova paridade informada
		        M->&("EXL_SVAL"+cDespesa) := M->&("EXL_VD"+cDespesa) * M->&("EXL_SPAR"+cDespesa)
		  	Else
		  		MsgInfo("Moeda da despesa não informada.", "Aviso")
		  		Break
		  	EndIf
		EndIf*/

      Case "EXL_SMOE" $ cGet
      	cDespesa := Right(AllTrim(cGet), 2)
      	If !Empty(M->&("EXL_SMOE"+cDespesa))
      		If !Empty(M->&("EXL_MD"+cDespesa))
		      	//RMD - ROADMAP: C1 - 30/06/15 - Atualiza o valor e a paridade do Pedido de Serviços a partir da nova moeda informada
				//M->&("EXL_SPAR"+cDespesa) := BuscaTaxa(M->&("EXL_MD"+cDespesa), dDataBase,, .F.) / BuscaTaxa(M->&("EXL_SMOE"+cDespesa), dDataBase,, .F.)
			   	//M->&("EXL_SVAL"+cDespesa) := M->&("EXL_VD"+cDespesa) * M->&("EXL_SPAR"+cDespesa)
	            //NCF - 15/10/2015 -
	            M->&("EXL_STAX"+cDespesa) := BuscaTaxa(M->&("EXL_SMOE"+cDespesa), dDataBase,, .F.)
	            M->&("EXL_SVAL"+cDespesa) := M->&("EXL_VD"+cDespesa) * BuscaTaxa(M->&("EXL_MD"+cDespesa), dDataBase,, .F.) / M->&("EXL_STAX"+cDespesa)
	            M->&("EXL_SPAR"+cDespesa) := M->&("EXL_SVAL"+cDespesa) / M->&("EXL_VD"+cDespesa)
		  	Else
		  		MsgInfo("Moeda da despesa não informada.", "Aviso")
		  		Break
		  	EndIf
		EndIf

      Case "EXL_STAX" $ cGet
      //wReliquias 20/12/16 - TE-3739 494538 / MTRADE-17 - Sistema não permite alterar o valor do frete internacional
      	/*cDespesa := Right(AllTrim(cGet), 2)
      	If !Empty(M->&("EXL_STAX"+cDespesa))
	      	If !Empty(M->&("EXL_MD"+cDespesa))
				//RMD - ROADMAP: C1 - 30/06/15 - Atualiza o valor do Pedido de Serviços considerando a nova paridade informada
		        //M->&("EXL_SVAL"+cDespesa) := M->&("EXL_VD"+cDespesa) * M->&("EXL_SPAR"+cDespesa)
		        M->&("EXL_SVAL"+cDespesa) := M->&("EXL_VD"+cDespesa) * BuscaTaxa(M->&("EXL_MD"+cDespesa), dDataBase,, .F.) / M->&("EXL_STAX"+cDespesa)
		        M->&("EXL_SPAR"+cDespesa) := M->&("EXL_SVAL"+cDespesa) / M->&("EXL_VD"+cDespesa)
		  	Else
		  		MsgInfo("Moeda da despesa não informada.", "Aviso")
		  		Break
		  	EndIf
		EndIf*/
		//LRS - 01/12/2016
		Case Left(cGet, 11) = "M->EXL_FINT"

		cDespesa  := Right(cGet, -11+Len(cGet))

	    SA2->(DbSetOrder(1))
	    SA2->(DbSeek(xFilial("SA2") + M->&("EXL_FINT"+cDespesa) + M->&("EXL_FLOJ"+cDespesa)))
	    IF SA2->A2_PAIS == "105"
	       EasyHelp("Ao informar um Fornecedor Nacional para esta despesa, a integração com o SISCOSERV não será executada.","Atenção")
	       Break
	    EndIF

   End Case

   lRet := .T.

   //RMD - ROADMAP: C1 - 28/07/15 - Atualiza a informação já validada no Buffer
   cGet := AllTrim(StrTran(ReadVar(), "M->", ""))
   If (nPos := aScan(aDespBuffer, {|x| x[1] == cGet})) > 0
      aDespBuffer[nPos][2] := &(ReadVar())
   EndIf

End Sequence

RestOrd(aSaveOrd)

Return(lRet)


/*
Função      : DICalculo1
Objetivo    : Obter o valor da despesa referente a moeda do processo.
Parametro   : cDespesa. Indica qual despesa deve ser calculada.
Autor       : Alexsander Martins dos Santos
Data e Hora : 24/09/2004 às 17:42.
*/

Static Function DICalculo1(cDespesa)

Local nResultado := 0

Begin Sequence

   If M->&("EXL_MD"+cDespesa) == M->EEC_MOEDA
      nResultado := M->&("EXL_VD"+cDespesa)
   Else
      nResultado := (M->&("EXL_VD"+cDespesa)*BuscaTaxa(M->&("EXL_MD"+cDespesa), dDataBase,, .F.))/BuscaTaxa(M->EEC_MOEDA , dDataBase,, .F.)
   EndIf

End Sequence

Return(nResultado)


/*
Função      : DICalculo2
Objetivo    : Obter o valor da paridade entre o valor da despesa e o valor da despesa na moeda do processo.
Parametro   : cDespesa. Indica qual despesa deve ser calculada.
Autor       : Alexsander Martins dos Santos
Data e Hora : 24/09/2004 às 17:42.
*/

Static Function DICalculo2(cDespesa)

Local nResultado := 0

Begin Sequence

   nResultado := M->&("EXL_VD"+cDespesa)/M->&(aDespesas[aScan(aDespesas, {|x| x[1] == cDespesa})][2])

End Sequence

Return(nResultado)


/*
Função      : DICalculo3
Objetivo    : Obter o valor da despesa, através do valor da despesa na moeda do processo, convertendo para
              moeda da despesa.
Parametro   : cDespesa. Indica qual despesa deve ser calculada.
Autor       : Alexsander Martins dos Santos
Data e Hora : 20/12/2004 às 22:54.
*/

Static Function DICalculo3(cDespesa)

Local nResultado := 0
Local nPos       := 0

Begin Sequence

   If (nPos := aScan(aDespesas, {|x| x[1] == cDespesa})) > 0

      nResultado := (M->&(aDespesas[nPos][2])*BuscaTaxa(M->EEC_MOEDA , dDataBase,, .F.))/BuscaTaxa(M->&("EXL_MD"+cDespesa) , dDataBase,, .F.)

   EndIf

End Sequence

Return(nResultado)


/*
Function DIX3Relacao()
Parametro   : cCampo, campo de envocação da função.
Objetivo    : Função imposta no X3_RELACAO dos campos virtuais que compõem a rotina de Despesas Internacionais.
Autor       : Alexsander Martins dos Santos
Data e Hora : 24/09/2004 às 22:21.
*/

Function DIX3Relacao(cCampo)

Local cRet     := ""
Local aSaveOrd := SaveOrd({"SY5", "SY6"})
Local cDespesa := Right(cCampo, -6+Len(cCampo))

Begin Sequence

   Do Case

      Case Left(cCampo, 6) == "EXL_DE"

         If !Empty(M->&("EXL_EM"+cDespesa))

            SY5->(dbSetOrder(1))
            SY5->(dbSeek(xFilial()+M->&("EXL_EM"+cDespesa)))

            cRet := SY5->Y5_NOME

         EndIf

      Case Left(cCampo, 6) == "EXL_DC"

         If !Empty(M->&("EXL_CP"+cDespesa))

            SY6->(dbSetOrder(1))
            SY6->(dbSeek(xFilial()+M->&("EXL_CP"+cDespesa)+Str(M->&("EXL_DP"+cDespesa), 3)))

            cRet := MSMM(SY6->Y6_DESC_P, 50)

         EndIf

   End Case

End Sequence

RestOrd(aSaveOrd)

Return(cRet)


/*
Função      : X3DIReturn
Objetivo    : Retornar os campos da Despesas Internacionais através do SX3.
Parâmetro   : Fase (Pedido ou Embarque - OC_EM ou OC_PE)
Retorno     : Array[1] = Prefixo de relacionamento com os campos(EXL) que define as caracteristicas da despesa.
                   [2] = Nome do campo no SX3.
Autor       : Alexsander Martins dos Santos
Alteração   : JPM - Parâmetro cFase
Data e Hora : 27/09/2004 às 17:20.
*/

Function X3DIReturn(cFase)

Local aSaveOrd  := SaveOrd("SX3", 2)

Local aDespesas, cAlias
Default cFase := OC_EM

cAlias := If(cFase = OC_EM,"EEC","EE7")

aDespesas  := { { "FR", cAlias + "_FRPREV" },;  //Frete
                { "SE", cAlias + "_SEGPRE" },;  //Seguro
                { "FA", cAlias + "_FRPCOM" },;  //Frete Adicional
                { "DI", cAlias + "_DESPIN" } }  //Despesas Internas

Begin Sequence

   SX3->(dbSeek(cAlias + "_DESP"))

   If RTrim(SX3->X3_CAMPO) == cAlias+"_DESP"
      SX3->(dbSkip())
   EndIf

   While SX3->(!Eof() .and. Left(X3_CAMPO, 8) == cAlias + "_DESP" .and. Val(Right(X3_CAMPO, 2)) > 0)

      SX3->(aAdd(aDespesas, {RTrim(Right(X3_CAMPO, 2)), AllTrim(X3_CAMPO)}))
      SX3->(dbSkip())

   End

End Sequence

RestOrd(aSaveOrd)

Return(aDespesas)

/*
Função      : DIVld_DTEMBA
Objetivo    : Função imposta na validação(AE100CRIT) da data de embarque, onde irá validar as despesas lançadas
              na Despesas Internacionais.
Retorno     : .T., dados consistentes.
              .F., dados inconsistentes.
Autor       : Alexsander Martins dos Santos
Data e Hora : 02/11/2004 às 11:44.
*/

Function DIVld_DTEMBA()

Local lRet := .F.

Local aDespesas, cDespesa, nDespesa
Local aCampos, cCampo, nCampo

Begin Sequence

   aDespesas := X3DIReturn()

   For nDespesa := 1 To Len(aDespesas)

      cDespesa := aDespesas[nDespesa][1]

      aCampos  := { "EXL_MD" + cDespesa,;
                    "EXL_VD" + cDespesa,;
                    aDespesas[nDespesa][2],;
                    "EXL_PA" + cDespesa,;
                    "EXL_EM" + cDespesa,; //"EXL_DE" + cDespesa,;
                    "EXL_FO" + cDespesa,;
                    "EXL_LF" + cDespesa,;
                    "EXL_CP" + cDespesa,;
                    "EXL_DP" + cDespesa,; //"EXL_DC" + cDespesa,;
                    "EXL_DT" + cDespesa }

      For nCampo := 1 To Len(aCampos)

         cCampo := aCampos[nCampo]

        If Left(cCampo, 6) <> "EXL_EM" .and. !Empty(M->&(cCampo))

			If Empty(M->&(aCampos[5]))
				MsgStop(STR0041+AVSX3(aCampos[3], AV_TITULO)+STR0042, STR0023) //"Os dados informados no botão Despesas Internacionais estão incompletos. A despesa do tipo "###" está sem o preenchimento do campo empresa."###"Atenção"
				Break
			EndIf
			
			Do Case
				Case cCampo == "EEC_FRPREV" .and. !Empty(M->&(cCampo))
	            	
	            	nPosCp := AScan( aCampos, {|x| Substr(AllTrim(x),1,6) == "EXL_VD" }  )
	            	If M->&(aCampos[nPosCp]) == 0 //"EXL_VD?
	                  MsgStop(STR0041+AVSX3(aCampos[3], AV_TITULO)+STR0079, STR0023) //"Os dados informados no botão Despesas Internacionais estão incompletos. A despesa do tipo "###" está sem o preenchimento do campo Valor da despesa."###"Atenção"
	                  Break
	               EndIf
	               
	               nPosCp := AScan( aCampos, {|x| Substr(AllTrim(x),1,6) == "EXL_PA" }  )
	               If M->&(aCampos[nPosCp]) == 0 //"EXL_PA?"
	                  MsgStop(STR0041+AVSX3(aCampos[3], AV_TITULO)+STR0080, STR0023) //"Os dados informados no botão Despesas Internacionais estão incompletos. A despesa do tipo "###" está sem o preenchimento do campo Paridade da despesa."###"Atenção"
	                  Break
	               Else
	               	  nPosCp := AScan( aCampos, {|x| Substr(AllTrim(x),1,6) == "EXL_PA" }  )
	                  If M->&(aCampos[nPosCp]) <> 1 //EXL_PAFR
	                  	nPosCp := AScan( aCampos, {|x| Substr(AllTrim(x),1,6) == "EXL_MD" }  )
	                  	If Empty(M->&(aCampos[nPosCp])) //EXL_MDFR
	                  		MsgStop(STR0041+AVSX3(aCampos[3], AV_TITULO)+STR0081, STR0023) //"Os dados informados no botão Despesas Internacionais estão incompletos. A despesa do tipo "###" está sem o preenchimento do campo Moeda da despesa."###"Atenção"
	                  		Break
	                  	EndIf
	                  Endif
	               EndIf
	                             
	            Case cCampo == "EEC_SEGPRE" .and. !Empty(M->&(cCampo))
	            
	              nPosCp := AScan( aCampos, {|x| Substr(AllTrim(x),1,6) == "EXL_VD" }  )
	            	If M->&(aCampos[nPosCp]) == 0 //"EXL_VD?
	                  MsgStop(STR0041+AVSX3(aCampos[3], AV_TITULO)+STR0079, STR0023) //"Os dados informados no botão Despesas Internacionais estão incompletos. A despesa do tipo "###" está sem o preenchimento do campo Valor da despesa."###"Atenção"
	                  Break
	               EndIf
	               
	               nPosCp := AScan( aCampos, {|x| Substr(AllTrim(x),1,6) == "EXL_PA" }  )
	               If M->&(aCampos[nPosCp]) == 0 //"EXL_PA?"
	                  MsgStop(STR0041+AVSX3(aCampos[3], AV_TITULO)+STR0080, STR0023) //"Os dados informados no botão Despesas Internacionais estão incompletos. A despesa do tipo "###" está sem o preenchimento do campo Paridade da despesa."###"Atenção"
	                  Break
	               Else
	               	  nPosCp := AScan( aCampos, {|x| Substr(AllTrim(x),1,6) == "EXL_PA" }  )
	                  If M->&(aCampos[nPosCp]) <> 1 //EXL_PAFR
	                  	nPosCp := AScan( aCampos, {|x| Substr(AllTrim(x),1,6) == "EXL_MD" }  )
	                  	If Empty(M->&(aCampos[nPosCp])) //EXL_MDFR
	                  		MsgStop(STR0041+AVSX3(aCampos[3], AV_TITULO)+STR0081, STR0023) //"Os dados informados no botão Despesas Internacionais estão incompletos. A despesa do tipo "###" está sem o preenchimento do campo Moeda da despesa."###"Atenção"
	                  		Break
	                  	EndIf
	                  Endif
	               EndIf
	            
	            Case cCampo == "EEC_FRPCOM" .and. !Empty(M->&(cCampo))  
	            	nPosCp := AScan( aCampos, {|x| Substr(AllTrim(x),1,6) == "EXL_VD" }  )
	            	If M->&(aCampos[nPosCp]) == 0 //"EXL_VD?
	                  MsgStop(STR0041+AVSX3(aCampos[3], AV_TITULO)+STR0079, STR0023) //"Os dados informados no botão Despesas Internacionais estão incompletos. A despesa do tipo "###" está sem o preenchimento do campo Valor da despesa."###"Atenção"
	                  Break
	               EndIf
	               
	               nPosCp := AScan( aCampos, {|x| Substr(AllTrim(x),1,6) == "EXL_PA" }  )
	               If M->&(aCampos[nPosCp]) == 0 //"EXL_PA?"
	                  MsgStop(STR0041+AVSX3(aCampos[3], AV_TITULO)+STR0080, STR0023) //"Os dados informados no botão Despesas Internacionais estão incompletos. A despesa do tipo "###" está sem o preenchimento do campo Paridade da despesa."###"Atenção"
	                  Break
	               Else
	               	  nPosCp := AScan( aCampos, {|x| Substr(AllTrim(x),1,6) == "EXL_PA" }  )
	                  If M->&(aCampos[nPosCp]) <> 1 //EXL_PAFR
	                  	nPosCp := AScan( aCampos, {|x| Substr(AllTrim(x),1,6) == "EXL_MD" }  )
	                  	If Empty(M->&(aCampos[nPosCp])) //EXL_MDFR
	                  		MsgStop(STR0041+AVSX3(aCampos[3], AV_TITULO)+STR0081, STR0023) //"Os dados informados no botão Despesas Internacionais estão incompletos. A despesa do tipo "###" está sem o preenchimento do campo Moeda da despesa."###"Atenção"
	                  		Break
	                  	EndIf
	                  Endif
	               EndIf
	            Case cCampo == "EEC_DESPIN" .and. !Empty(M->&(cCampo))     
	            	nPosCp := AScan( aCampos, {|x| Substr(AllTrim(x),1,6) == "EXL_VD" }  )
	            	If M->&(aCampos[nPosCp]) == 0 //"EXL_VD?
	                  MsgStop(STR0041+AVSX3(aCampos[3], AV_TITULO)+STR0079, STR0023) //"Os dados informados no botão Despesas Internacionais estão incompletos. A despesa do tipo "###" está sem o preenchimento do campo Valor da despesa."###"Atenção"
	                  Break
	               EndIf
	               
	               nPosCp := AScan( aCampos, {|x| Substr(AllTrim(x),1,6) == "EXL_PA" }  )
	               If M->&(aCampos[nPosCp]) == 0 //"EXL_PA?"
	                  MsgStop(STR0041+AVSX3(aCampos[3], AV_TITULO)+STR0080, STR0023) //"Os dados informados no botão Despesas Internacionais estão incompletos. A despesa do tipo "###" está sem o preenchimento do campo Paridade da despesa."###"Atenção"
	                  Break
	               Else
	               	  nPosCp := AScan( aCampos, {|x| Substr(AllTrim(x),1,6) == "EXL_PA" }  )
	                  If M->&(aCampos[nPosCp]) <> 1 //EXL_PAFR
	                  	nPosCp := AScan( aCampos, {|x| Substr(AllTrim(x),1,6) == "EXL_MD" }  )
	                  	If Empty(M->&(aCampos[nPosCp])) //EXL_MDFR
	                  		MsgStop(STR0041+AVSX3(aCampos[3], AV_TITULO)+STR0081, STR0023) //"Os dados informados no botão Despesas Internacionais estão incompletos. A despesa do tipo "###" está sem o preenchimento do campo Moeda da despesa."###"Atenção"
	                  		Break
	                  	EndIf
	                  Endif
	               EndIf
	        EndCase
		EndIf

      Next

   Next

   lRet := .T.

End Sequence

Return(lRet)


/*
Função      : DespIntDel
Objetivo    : Limpeza dos campos de despesa.
Parametro   : cId, Cargo do TreeView.
Retorno     : Nil
Autor       : Alexsander Martins dos Santos
Data e Hora : 02/11/2004 às 16:10
*/

Static Function DespIntDel()

Local aDespesas, aCampos, nCampo := 0, cId

cId := AllTrim(oTree:GetCargo())

Begin Sequence

   If cId == "Raiz"
      MsgInfo(STR0043, STR0023) //"Selecione uma despesa para ser excluida."###"Atenção"
      Break
   EndIf

   aDespesas := X3DIReturn()

   aCampos  := { "EXL_NAT" + cId,;
                 "EXL_MD" + cId,;
                 "EXL_VD" + cId,;
                 aDespesas[aScan(aDespesas, {|x| x[1] == cId})][2],;
                 "EXL_PA" + cId,;
                 "EXL_EM" + cId,;
                 "EXL_DE" + cId,;
                 "EXL_FO" + cId,;
                 "EXL_LF" + cId,;
                 "EXL_CP" + cId,;
                 "EXL_DP" + cId,;
                 "EXL_DC" + cId,;
                 "EXL_DT" + cId }


      // EJA - 10/08/2017 - Caso haja campos do Siscoserv, estes serão limpados
      If EasyGParam("MV_ESS0014",,.T.) .And. AvFlags("CONTROLE_SERVICOS_AQUISICAO").And. EXL->(FieldPos("EXL_NBS"+cId)) > 0
            AAdd(aCampos,"EXL_NBS" + cId)
            //RMD - ROADMAP: C1 - 25/05/15 - Campos para registrar o Fornecedor Internacional
            If EXL->(FieldPos("EXL_FINT"+cId) > 0 .And. FieldPos("EXL_FLOJ"+cId) > 0)
                  AAdd(aCampos,"EXL_FINT" + cId)
                  AAdd(aCampos,"EXL_FLOJ" + cId)
            EndIf
            //RMD - ROADMAP: C1 - 30/06/15 - Campos para registrar a moeda do Pedido de Serviços
            If EXL->(FieldPos("EXL_SMOE"+cId) > 0 .And. FieldPos("EXL_SPAR"+cId) > 0 .And. FieldPos("EXL_SVAL"+cId) > 0 .And. FieldPos("EXL_STAX"+cId) > 0)
                  AAdd(aCampos,"EXL_SMOE" + cId)
                  AAdd(aCampos,"EXL_SPAR" + cId)
                  AAdd(aCampos,"EXL_SVAL" + cId)
                  AAdd(aCampos,"EXL_STAX" + cId)
            EndIf
      EndIf

   aEval(aCampos, {|x| If(Empty(M->&(x)),, nCampo++)})

   If nCampo = 0
      MsgStop(STR0053, STR0023) //"A despesa selecionada não possui dados para exclusão."###"Atenção"
      Break
   EndIf

   If !MsgYesNo(STR0044, STR0023) //"Deseja limpar os dados da despesa?"###"Atenção"
      Break
   EndIf

   For nCampo := 1 To Len(aCampos)
      M->&(aCampos[nCampo]) := Criavar(aCampos[nCampo])
   Next
   //MFR OSSME-3579 06/08/2019
   AE100PRECOI(.T.,.F.) // true para recalcular e false para nao dar mensaegem
End Sequence

Return(Nil)


/*
Função      : DIVldMoeda
Objetivo    : Na alteração da moeda na capa do processo, avisar o usuário que os valores da Desp.Internacional
              deverá ser revisada.
Retorno     : Nil
Autor       : Alexsander Martins dos Santos
Data e Hora : 02/11/2004 às 19:10
*/

Function DIVldMoeda()

Local aDespesas  := X3DIReturn()
Local nPos       := 0

Begin Sequence

   If EECFlags("FRESEGCOM")

      For nPos := 1 To Len(aDespesas)

         If !Empty(M->&("EXL_VD"+aDespesas[nPos][1])) .or. !Empty(M->&(aDespesas[nPos][2]))
            MsgInfo(STR0045, STR0023) //"Com a alteração da Moeda no processo, deverão ser revisados todos os valores das Despesas Internacionais"###"Atenção"
            Break
         EndIf

      Next

   EndIf

End Sequence

Return(.T.)


/*
Função      : DIVldIcoterm
Objetivo    : Validar o Icoterm informado na capa do embarque. Verficando a existencia ou não de Frete e Seguro.
Retorno     : .T., Despesas Internacionais com despesas consistentes com o icoterm.
              .F., Despesas Internacionais com despesas inconsistentes com o icoterm.
Autor       : Alexsander Martins dos Santos
Data e Hora : 02/11/2004 às 19:10
*/

Function DIVldIcoterm()

Local lRet      := .T.
Local aSaveOrd  := SaveOrd("SYJ", 1)
Local nDespesa  := 1
Local cDespesas := ""
Local cMsg      := ""

Local aDespesas, cPlural, aCampos, nCampo

Begin Sequence

   If !EECFlags("FRESEGCOM")
      Break
   EndIf

   SYJ->(dbSeek(xFilial()+M->EEC_INCOTE))

   aDespesas := { { "FR", "Frete",  "EEC_FRPREV", SYJ->YJ_CLFRETE == SIM },;
                  { "SE", "Seguro", "EEC_SEGPRE", SYJ->YJ_CLSEGUR == SIM } }

   While nDespesa <= Len(aDespesas)

      If !Empty(M->&(aDespesas[nDespesa][3])) .and. !aDespesas[nDespesa][4]
         cDespesas += If(Empty(cDespesas), "", " e ") + aDespesas[nDespesa][2]
         nDespesa++
         Loop
      EndIf

      aDel(aDespesas, nDespesa)
      aSize(aDespesas, Len(aDespesas)-1)

   End

   If Len(aDespesas) > 0

      cPlural := If(Len(aDespesas) = 2, "s", "")

      cMsg += STR0046+M->EEC_INCOTE+STR0047+cDespesas+"." + ENTER //"O Incoterm "###" não prevê "
      cMsg += STR0048+cPlural+STR0049+cPlural+STR0050+cDespesas+STR0051+cPlural+STR0052+M->EEC_INCOTE+" ?" //"Deseja eliminar a"###" despesa"###" de "###" lançada"###" na opção de Despesas Internacionais e alterar o icoterm para "

      If MsgYesNo(cMsg, STR0023) //"Atenção"

         aCampos  := { "EXL_MD",;
                       "EXL_VD",;
                       "EXL_PA",;
                       "EXL_EM",;
                       "EXL_DE",;
                       "EXL_FO",;
                       "EXL_LF",;
                       "EXL_CP",;
                       "EXL_DP",;
                       "EXL_DC",;
                       "EXL_DT" }

         For nDespesa := 1 To Len(aDespesas)

            M->&(aDespesas[nDespesa][3]) := CriaVar(aDespesas[nDespesa][3])

            For nCampo := 1 To Len(aCampos)

               M->&(aCampos[nCampo]+aDespesas[nDespesa][1]) := CriaVar(aCampos[nCampo]+aDespesas[nDespesa][1])

            Next

         Next

      Else

         lRet := .F.

      EndIf

   EndIf

End Sequence

RestOrd(aSaveOrd)

Return(lRet)


/*
Função      : DIAtuDesp
Objetivo    : Atualizar a despesa e a despesa na moeda do processo para Despesas Internacionais.
Parametro   : Despesa.
Autor       : Alexsander Martins dos Santos
Data e Hora : 21/11/2004 às 10:35
*/

Static Function DIAtuDesp(cDespesa)

Local nOpc     := 0
Local oDlg
Local cButton1 := AVSX3("EXL_VD"+cDespesa, AV_TITULO)
Local cButton2 := AVSX3(aDespesas[aScan(aDespesas, {|x| x[1] == cDespesa})][2], AV_TITULO)

Begin Sequence

   Define MSDialog oDlg Title STR0023 From 9,0 To 15,30 Of oMainWnd //"Atenção"

   @ 05,005 To 42,115 LABEL STR0054 Pixel //"Deseja Atualizar?"

   @ 21,025 Button cButton1 Size 35,12 Action (nOpc := 1, oDlg:End()) Of oDlg Pixel
   @ 21,065 Button cButton2 Size 35,12 Action (nOpc := 2, oDlg:End()) Of oDlg Pixel

   Activate MsDialog oDlg Centered

   Do Case

      Case nOpc = 1

         M->&("EXL_VD"+cDespesa) := (M->&("EXL_PA"+cDespesa)*M->&(aDespesas[aScan(aDespesas, {|x| x[1] = cDespesa})][2]))

      Case nOpc = 2

         M->&(aDespesas[aScan(aDespesas, {|x| x[1] = cDespesa})][2]) := M->&("EXL_VD"+cDespesa)/M->&("EXL_PA"+cDespesa)

   End Case

End Sequence

Return(Nil)

/*
Função      : ReadOnlyDI
Objetivo    : Definir se o campo cCampo de despesas internacionais será editável
Parametro   : cCampo
Autor       : João Pedro Macimiano Trabbold
Data e Hora : 03/03/05 14:40
*/

Static Function ReadOnlyDI(cCampo,cCampoEEC)
Local lRet := .f.

Begin Sequence

   If !Empty(M->EEC_DTEMBA)//data de embarque preenchida
      If lAltValPosEmb //rotina de alteração de valores após embarque
         //If lInclusaoPosEmb .And. Empty(EEC->&(cCampoEEC))
         If lInclusaoPosEmb .And. AE106VldDespInt(cCampo) //DFS - Inclusão das funções de validações de bloqueio dos campos.
            Break
         EndIf
         If ! ( (Left(cCampo,6) $ "EXL_VD/EXL_PA/") .Or. (Left(cCampo,3) = "EEC")) .Or. Empty(EEC->&(cCampoEEC))
            lRet := .t.
         EndIf
      Else
         lRet := .t.
      EndIf
   EndIf

End Sequence

Return lRet

/*
Função      : AE106AltVld
Objetivo    : Validar se são possíveis as alterações feitas em valores após o embarque
Parametro   : Nenhum
Autor       : João Pedro Macimiano Trabbold
Data e Hora : 05/03/05 às 8:30
*/

Function AE106AltVld()

Local lRet := .t., nVlAlteravel := 0, nDiferenca := 0, aComLivre := {0,0,0}, aCom := {0,0,0}
Local aOrd := SaveOrd({"EEC","EEQ"}), aDespInt, cDiferenca := "", i, cNome := "", lTemParcNaoLiq := .f.
Local lTemParc
Local lAltDespInt //LGS-28/07/2015
Private lAltDesLiq := .T. //LRS - 27/06/2017

Begin Sequence

   //Valida o Total do Embarque
   //TRP - 04/11/2011 - Utilizar índice por Processo (PREEMB) e não pelo Nr. Invoice (NRINVO).
   EEQ->(DbSetOrder(1))
   EEQ->(DbSeek(xFilial("EEQ")+M->EEC_PREEMB))
   While EEQ->(!EoF()) .And. EEQ->(EEQ_FILIAL+EEQ_PREEMB) ==;
         (xFilial("EEQ")+M->EEC_PREEMB)

      If EEQ->EEQ_EVENT == "101"
         If EEQ->(Empty(EEQ_DTCE) .And. Empty(EEQ_PGT) .And. Empty(EEQ_NROP))
            lTemParcNaoLiq := .t.
            nVlAlteravel += If(Empty(EEQ->EEQ_FI_TOT),AF200VLFCAM("EEQ","ALT"),EEQ->EEQ_VL_PAR)
         EndIf
      Endif

      EEQ->(DbSkip())
   EndDo

   EEC->(DbSeek(xFilial("EEC")+M->EEC_PREEMB))

   nDiferenca := EEC->EEC_TOTPED - Round(M->EEC_TOTPED,AvSx3("EEC_TOTPED",AV_DECIMAL)) // By JPP - 20/04/2006 - 11:00

   lAltDespInt := If(EEC->EEC_AMOSTR == "1" .And. EasyGParam("MV_AVG0081",,.F.), .T., .F.) //LGS-28/07/2015 - Se processo for Amostra e parametro .T. permite alterar

   If(EasyEntryPoint("EECAE106"),ExecBlock("EECAE106",.F.,.F.,"ALTERA_PROCESSO_LIQ"),) //LRS - 27/06/2017

   If (!lTemParcNaoLiq .And. nDiferenca > 0 .And. !lAltDespInt .AND. lAltDesLiq) .Or. (M->EEC_PRECOA == "2" .And. !lTemParcNaoLiq .And. M->EEC_TOTFOB > EEC->EEC_TOTFOB .And. AE102CalcAg(,,'2') > 0)//LRS - 27/06/2017
      lRet := .f.
      MsgStop(STR0062,STR0063)//STR0062	"Todas as parcelas de invoice estão liquidadas. Não será possível a alteração de valores." // STR0063	"Aviso"
      Return lRet
   EndIf

   If !lAltDespInt //LGS-28/07/2015
      lRet := (nDiferenca <= nVlAlteravel)
   EndIf

   If !lRet
      cNome := STR0064//STR0064	"do Embarque "
      Break
   EndIf

   //Valida as Despesas Internacionais
   If EECFlags("FRESEGCOM")
      EXL->(DbSetOrder(1))
      EXL->(DbSeek(xFilial("EXL")+M->EEC_PREEMB))

      aDespInt := X3DIReturn()

      For i := 1 to Len(aDespInt)

         If !EasyGParam("MV"+SubStr(aDespInt[i][2], 4), .T.)
            Loop
         EndIf

         If !EC6->(DbSeek(xFilial("EC6")+AVKey("EXPORT", "EC6_TPMODU")+AVKey(EasyGParam("MV"+SubStr(aDespInt[i][2], 4)), "EC6_ID_CAM")))
            Loop
         EndIf

         nVlAlteravel := 0
         nDiferenca := &("EXL->EXL_VD"+aDespInt[i][1]) - &("M->EXL_VD"+aDespInt[i][1])
         cEvento := EasyGParam("MV"+SubStr(aDespInt[i][2], 4))
         lTemParcNaoLiq := .f.
         lTemParc := .f.

         //TRP - 04/11/2011 - Utilizar índice por Processo (PREEMB) e não pelo Nr. Invoice (NRINVO).
         EEQ->(DbSetOrder(1))
         EEQ->(DbSeek(xFilial("EEQ")+M->EEC_PREEMB))
         While EEQ->(!EoF()) .And. EEQ->(EEQ_FILIAL+EEQ_PREEMB) ==;
               (xFilial("EEQ")+M->EEC_PREEMB)
            If EEQ->EEQ_EVENT == cEvento
               lTemParc := .t.
               If Empty(EEQ->EEQ_PGT)
                  lTemParcNaoLiq := .t.
                  nVlAlteravel += EEQ->EEQ_VL
               EndIf
            Endif
            EEQ->(DbSkip())
         EndDo

         If lTemParc .And. !lTemParcNaoLiq .And. nDiferenca <> 0
            lRet := .f.
            MsgStop(STR0065 + AllTrim(Posicione("SX3",2,aDespInt[i][2],"X3_TITULO")) + STR0066,STR0063)//STR0065	"Todas as parcelas de " //STR0066	" estão liquidadas. Não será possível a alteração de valores." //STR0063	"Aviso"
            Return lRet
         EndIf

         If !lAltDespInt //LGS-28/07/2015
            lRet := (nDiferenca <= nVlAlteravel)
         EndIf

         If !lRet
            cNome := "de " + AllTrim(Posicione("SX3",2,aDespInt[i][2],"X3_TITULO")) + " "
            Break
         EndIf

      Next

   EndIf

   //Valida as comissões
   If !IsVazio("WorkAg") .And. EECFlags("COMISSAO")
      EECTotCom(OC_EM,, .T.)

      //TRP - 04/11/2011 - Utilizar índice por Processo (PREEMB) e não pelo Nr. Invoice (NRINVO).
      EEQ->(DbSetOrder(1))
      EEQ->(DbSeek(xFilial("EEQ")+M->EEC_PREEMB))
      While EEQ->(!EoF()) .And. EEQ->(EEQ_FILIAL+EEQ_PREEMB) ==;
            (xFilial("EEQ")+M->EEC_PREEMB)
         If EEQ->EEQ_EVENT == "101"
            If Empty(EEQ->EEQ_PGT)
               aComLivre[1] += EEQ->EEQ_AREMET
               aComLivre[2] += EEQ->EEQ_CGRAFI
               aComLivre[3] += EEQ->EEQ_ADEDUZ
            EndIf
         Endif
         EEQ->(DbSkip())
      EndDo
      WorkAg->(DbGoTop())
      While WorkAg->(!EoF())

         EEB->(DbSeek(xFilial() + M->EEC_PREEMB + OC_EM + WorkAg->(EEB_CODAGE + EEB_TIPOAG + EEB_TIPCOM)))

         If WorkAg->EEB_TIPCOM = "1"
            aCom[1] += EEB->EEB_TOTCOM - WorkAg->EEB_TOTCOM
         ElseIf WorkAg->EEB_TIPCOM = "2"
            aCom[2] += EEB->EEB_TOTCOM - WorkAg->EEB_TOTCOM
         Else
            aCom[3] += EEB->EEB_TOTCOM - WorkAg->EEB_TOTCOM
         EndIf

         WorkAg->(DbSkip())
      EndDo

      For i := 1 to len(aCom)
         If AvFlags("EEC_LOGIX") .Or. (aCom[i] <> 0 .And. Empty(M->EEC_PREEMB))//RMD - 30/08/12 - Não revalida as comissões após o embarque
            cEvento := If(i=1,"120",If(i=2,"121","122"))
            //Procura se há parcelas não liquidadas de comissão
            nVlAlteravel := 0
            lTemParcNaoLiq := .f.
            //TRP - 04/11/2011 - Utilizar índice por Processo (PREEMB) e não pelo Nr. Invoice (NRINVO).
            EEQ->(DbSeek(xFilial("EEQ")+M->EEC_PREEMB))
            While EEQ->(!EoF()) .And. EEQ->(EEQ_FILIAL+EEQ_PREEMB) ==;
                  (xFilial("EEQ")+M->EEC_PREEMB)
               If EEQ->EEQ_EVENT == cEvento
                  If Empty(EEQ->EEQ_PGT)
                     nVlAlteravel += EEQ->EEQ_VL
                     lTemParcNaoLiq := .t.
                  EndIf
               Endif
               EEQ->(DbSkip())
            EndDo

            If AvFlags("EEC_LOGIX") .And. cEvento == "122" .And. EasyGParam("MV_EEC0025",,.T.) .And. aCom[i] > nVlAlteravel
               If !MsgYesNo(STR0082+;//"O valor das parcelas não liquidadas de comissão 'Deduzir da Fatura' não é suficiente para a alteração de valores para menor."
                            STR0083+;//"Caso queira prosseguir com a alteração, o valor da comissão 'Deduzir da Fatura' não será atualizado."
                            STR0084,STR0063)//"Deseja prosseguir?"###"Aviso"
                  lRet := .F.
                  Return lRet
               EndIf
            Else
               If aCom[i] > nVlAlteravel
                  MsgStop(STR0067 + Alltrim(BscxBox("EEB_TIPCOM",AllTrim(Str(i)))) + STR0068,STR0063)//STR0067	"O valor das parcelas não liquidadas de comissão " /STR0068	" não é suficiente para a alteração de valores para menor." //STR0063	"Aviso"
                  lRet := .f.
                  Return lRet
               EndIf
            EndIf
            /*NOPADO - THTS - 29/10/2019 - ALteração pos embarque para um valor maior, não deve ser bloqueado.
            If !lTemParcNaoLiq .And. aCom[i] <> 0
               MsgStop(STR0069 + Alltrim(BscxBox("EEB_TIPCOM",AllTrim(Str(i)))) + STR0070,STR0063)//STR0069	"Todas as parcelas de comissão "//STR0070	" estão liquidadas. Não será possível a alteração de valores."//STR0063	"Aviso"
               lRet := .f.
               Return lRet
            EndIf
            */
         EndIf
      Next

      For i := 1 to Len(aCom)
         If aCom[i] > aComLivre[i] .And. Empty(M->EEC_PREEMB)//RMD - 30/08/12 - Não revalida as comissões após o embarque
            lRet := .f.
            MsgStop(STR0071 + Alltrim(BscxBox("EEB_TIPCOM",AllTrim(Str(i))))+ STR0072 + ENTER + ENTER +; //STR0071	"Com o recálculo das comissões("// STR0072	"), não será possível abater a diferenca dos valores de comissão já vinculados a parcelas de câmbio."
                    STR0073 + Alltrim(Transf(aCom[i],AvSx3("EEB_TOTCOM",AV_PICTURE))) + ENTER +; //STR0073	 "       Diferença entre o valor de comissão anterior e o recalculado: "
                    STR0074 + Alltrim(Transf(aComLivre[i],AvSx3("EEB_TOTCOM",AV_PICTURE))),STR0063) //STR0074	"       Comissão livre para ser desvinculada: " //STR0063	"Aviso"

         EndIf
      Next

      If !lRet
         Return lRet
      EndIf

      WorkAg->(DbSkip())

   EndIf


End Sequence

//Mensagem para validação do Total do Embarque e Despesas Internacionais
If !lRet
   MsgStop(STR0075 + cNome + STR0076 + ENTER + ENTER +;//STR0075	"Os valores " //STR0076	"foram alterados para menor, porém já existem parcelas liquidadas e/ou vinculadas ao financiamento, e o valor livre das parcelas não é suficiente."
           STR0077 + AllTrim(Transf(nVlAlteravel,AvSx3("EEQ_VL",AV_PICTURE))) + ENTER +; //STR0077	"       Valor Livre das Parcelas: "
           STR0078 + AllTrim(Transf(nDiferenca,AvSx3("EEC_TOTPED",AV_PICTURE))) + ".","") //STR0078	"       Valor alterado para menor: "
EndIf

RestOrd(aOrd)

Return lRet

/*
Funcao      : AE106VerAgCom()
Parametros  : Nenhum.
Retorno     :
Objetivos   : verifica se os campos obrigatorios dos agentes de comissão estão preenchidos
Autor       : Fabio Justo Hildebrand.
Data/Hora   : 24/08/05 17:30.
Revisao     :
Obs.        :
*/

Function AE106VerAgCom()
Local lRet:=.T., nRegAnt:= WorkAg->(RecNo())

      If EECFlags("COMISSAO") //Testa se há tratamento por comissão
         WorkAg->(DbGoTop())
         While WorkAg->(!Eof())
            IF (Empty(WorkAg->EEB_TIPCOM).or.Empty(WorkAg->EEB_TIPCVL)).and.Left(WorkAg->EEB_TIPOAG,1) == CD_AGC
               lRet := .F.
               MsgAlert(STR0055) // "Há campos obrigatórios não preenchidos nos Agentes de Comissão vinculados ao processo"
            Endif
            WorkAg->(DbSkip())
         End
      Endif

WorkAg->(dbGoTo(nRegAnt))
Return lRet

/*
Funcao      : AE106Valid()
Parametros  : nenhum
Retorno     : lRet
Objetivos   : Ponto de Entrada para Validação de Campos
Autor       : Eduardo C. Romanini
Data/Hora   : 24/10/05 15:40
Revisao     :
Obs.        :
*/

*--------------------------*
Static Function Ae106Valid()
*--------------------------*
Local lRet := .F.

Begin Sequence

   If EasyEntryPoint("EECAE106")

      lRet := Execblock("EECAE106",.F.,.F.,{"PE_VALIDOK"})

      If ValType(lRet) == "L" .and. !lRet
         Break
      EndIf

   EndIf

   lRet := .T.

End Sequence

Return lRet

/*
Funcao      : AE106VldDespInt()
Parametros  : cCampo
Retorno     :
Objetivos   : Não permitir editar os campos que já foram preenchidos na edição anterior
Autor       : Diogo Felipe dos Santos
Data/Hora   : 22/12/10 - 10:00
Revisao     :
Obs.        :
*/

*-----------------------------------------*
Static Function AE106VldDespInt(cCampo)
*-----------------------------------------*

Local lRet    := .F.

If Left(cCampo,6) $ "EXL_NAT/EXL_MD/EXL_VD/EXL_PA/EXL_EM/EXL_CP/EXL_DT/" //EEC_FRPREV/EEC_SEGPRE/EEC_FRPCOM/EEC_DESPIN/
   If Empty(EXL->&(cCampo))
      lRet := .T.
   EndIf
Else
   lRet := .T.
EndIf

Return lRet

/*******************************************************************************
Funcao     : AE106CambLiq()
Parametros : cDespesa - Despesa a ser verificada
             nPosDespesa - Posição da despesa no array aDespesas
Retorno    : Retorna T caso haja cambio da despesa liquidado e F caso contrário
Objetivos  : Verificar se há cambio liquidado para a despesa referente
Autor      : Nilson César C. Filho
Data/Hora  : 11/04/2011
********************************************************************************/
*-----------------------------------------*
FUNCTION AE106CambLiq(cDespesa,nPosDespesa)
*-----------------------------------------*

Local lTemParcLiq, cEvento
Local lRet := .F.
Local aOrdTbEEQ := SaveOrd({"EEQ"})

Begin Sequence

If EECFlags("FRESEGCOM")
   EXL->(DbSetOrder(1))
   EXL->(DbSeek(xFilial("EXL")+M->EEC_PREEMB))

   If !EasyGParam("MV"+SubStr(cDespesa,4), .T.)
      Break
   EndIf

   If !EC6->(DbSeek(xFilial("EC6")+AVKey("EXPORT", "EC6_TPMODU")+AVKey(EasyGParam("MV"+SubStr(cDespesa, 4)), "EC6_ID_CAM")))
      Break
   EndIf

   cEvento := EasyGParam("MV"+SubStr(cDespesa, 4))
   lTemParcLiq := .f.

   //TRP - 04/11/2011 - Utilizar índice por Processo (PREEMB) e não pelo Nr. Invoice (NRINVO).
   EEQ->(DbSetOrder(1))
   EEQ->(DbSeek(xFilial("EEQ")+M->EEC_PREEMB))
   While EEQ->(!EoF()) .And. EEQ->(EEQ_FILIAL+EEQ_PREEMB) == (xFilial("EEQ")+M->EEC_PREEMB)
      If EEQ->EEQ_EVENT == cEvento
         If !Empty(EEQ->EEQ_PGT)
            lTemParcLiq := .t.
            EXIT
         EndIf
      Endif
      EEQ->(DbSkip())
   EndDo

   If lTemParcLiq
      lRet := .T.
      IF !(nPosDespesa == LEN(aDespesas))
         cDespTit += " " + AllTrim(Posicione("SX3",2,cDespesa,"X3_TITULO"))+", "
      ELSE
         cDespTit += " " + AllTrim(Posicione("SX3",2,cDespesa,"X3_TITULO"))+" )"
         MsgStop(STR0059+cDespTit+STR0060,"Aviso")
      ENDIF
   EndIf

EndIf

End Sequence

RestOrd(aOrdTbEEQ,.T.)

Return lRet

/*
Programa   : AE106ESSVal()
Objetivo   : Validar campos utlizados pelo SIGAESS que fazem parte da rotina de embarque
Parâmetros : cCampo
Autor      : Rafael Ramos Capuano
Data       : 13/08/2013 - 14:03:00
*/

Function AE106ESSVal(cCampo)
Local lRet     := .T.
Default cCampo := SPACE(LEN(cCampo))//"" - LGS-26/03/2014

If !Empty(cCampo)
   Do Case
      Case "EXL_NBS" $ cCampo
         If !(Vazio().Or.ExistCpo("EL0",M->&(cCampo)).And.Len(AllTrim(M->&(cCampo))) >= LEN(M->&(cCampo)))
            lRet := .F.
            EasyHelp("Digite N.B.S valido! Selecione um N.B.S sem espaços e registrado no sistema.","Aviso")
         EndIf
   EndCase
EndIf

Return lRet

/*
Programa   : AE106IniVal()
Objetivo   : Inicializa os campos de NBS utlizados pelo SIGAESS que fazem parte da rotina de embarque
Parâmetros : cCampo
Autor      : Rafael Ramos Capuano
Data       : 19/08/2013 - 10:16:00
*/

Function AE106IniVal(cCampo)
Local cCont    := SPACE(LEN(cCampo))//"" - LGS-26/03/2014
Local aOrd     := SaveOrd({"SYB","SB5"})
Local cCodDesp := ""

Do Case
   Case cCampo == "EXL_NBSFR" //Frete
      cCodDesp := "102"
   Case cCampo == "EXL_NBSSE" //Seguro
      cCodDesp := "103"
   Case cCampo == "EXL_NBSFA" //Frete Adicional
      cCodDesp := "333"
   //Case cCampo == "EXL_NBSDI" //Não há o tratamento para este tipo de despesa com o SIGAESS
   //   cCodDesp := "411"
EndCase
SYB->(DbSetOrder(1)) //YB_FILIAL+YB_DESP
If SYB->(DbSeek(xFilial("SYB")+cCodDesp))
   SB5->(DbSetOrder(1)) //B5_FILIAL+B5_COD
   If SB5->(DbSeek(xFilial("SB5")+AvKey(SYB->YB_PRODUTO,"B5_COD")))
      cCont := SB5->B5_NBS
   EndIf
EndIf

RestOrd(aOrd,.T.)
Return cCont

/*
Programa   : AE106CpNoEd()
Objetivo   : Definir se um campo é ou não editável na tela de Despesas Internacionais
Parâmetros : cCampo - Nome do campo a ser validado
Autor      : Nilson César
Data       : 16/10/2015 - 10:00 hrs
*/
Function AE106CpNoEd( cCampo )
Local lRet := .F.
Default cCampo := ""

   DO CASE
      CASE cCampo == "EXL_SPARFR"
         lRet := .T.
      CASE cCampo == "EXL_SPARSE"
         lRet := .T.
      CASE cCampo == "EXL_SPARFA"
         lRet := .T.
   ENDCASE

Return lRet
*-----------------------------------------------------------------------------------------------------------------*
*                                       FIM DO PROGRAMA EECAP106.PRW                                              *
*-----------------------------------------------------------------------------------------------------------------*