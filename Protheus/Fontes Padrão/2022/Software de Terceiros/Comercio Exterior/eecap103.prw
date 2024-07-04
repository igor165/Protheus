#INCLUDE "eecap103.ch"
#INCLUDE "EEC.cH"
#INCLUDE "dbtree.ch"

/*
Função      : AP100DespNac
Objetivo    : Despesas Nacionais.
Parametro   : cOrigem_p, indica se chamada da função foi no pedido ou embarque.
Autor       : Alexsander Martins dos Santos
Data e Hora : 08/09/2004 às 10:35
*/

Function AP100DespNac(cOrigem_p, nOpc_p, aAuto)

Local nVlComissao  := 0
Local lRet
Private aTree      := {}
Private oTree      := ""
Private aDelEEBBck := {}
Private aDelEETBck := {}
Private cOrigem    := cOrigem_p
Private cFocus     := ""

Private cEEBWkBck := CriaTrab(, .F.)
Private cEETWkBck := CriaTrab(, .F.)
Private lNAOALTERA := .T.
Private lEETAuto := ValType(aAuto) == "A"//RMD - 24/02/20 - Possibilita a inclusão de despesas nacionais via Rotina Automática

Begin Sequence

   Processa({|| DespNacTree(), STR0001, STR0002, .F. }) //"Aguarde"###"Preparando Despesas Nacionais"

   If DespNacTela(nOpc_p, lEETAuto, aAuto)

      WorkAg->(dbEval({|| nVlComissao += EEB_TXCOMI }))
      // by CAF 23/032/2005 - Esta sintaxe gera msg do Protheus, qdo o fonte contem um outro erro If(cOrigem == OC_PE, M->EE7_VALCOM, M->EEC_VALCOM) := nVlComissao
      If cOrigem == OC_PE
         M->EE7_VALCOM := nVlComissao
      Else
         M->EEC_VALCOM := nVlComissao
      Endif

      lRet := .T.

   Else

      WorkAg->(AvZap())
      dbSelectArea("WorkAg")
      TERestBackup(cEEBWkBck)
      aAgDeletados := aClone(aDelEEBBck)

      WorkDe->(AvZap())
      dbSelectArea("WorkDe")
      TERestBackup(cEETWkBck)
      aDeDeletados := aClone(aDelEETBck)

      lRet := .F.
 
   End

   fErase(cEEBWkBck+GetdbExtension())
   fErase(cEETWkBck+GetdbExtension())

End Sequence

WorkAg->(dbClearFilter())
WorkDe->(dbClearFilter())

//RMD - 24/02/20 - Passa a retornar o resultado da operação para a o gerenciamento da inclusão via MsExecAuto (a função é chamada uma vez para cada despesa).
Return lRet


/*
Função      : DespNacTree()
Objetivo    : Gerar o array "aTree" com os dados que devem ser apresentados no TreeView.
Returno     : Nil.
Autor       : Alexsander Martins dos Santos
Date e Hora : 14/09/2004 às 10:16.
*/

Static Function DespNacTree()

Local lRet      := .F.
Local nSubNivel := 2
Local cFiltro := "" //AOM - 18/07/2011

If Type("lEE7Auto") <> "L"
   lEE7Auto:= .F.
EndIf

Begin Sequence

   /*
   Geração da Work de Backup de Empresas.
   */
   dbSelectArea("WorkAg")
   DbGoTop() // JPM - 17/03/06 - Dar DbGoTop antes dos 'Copy To' para não gerar erro em CTree.
   //Copy To (cEEBWkBck)
   TETempBackup(cEEBWkBck) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados
   aDelEEBBck := aClone(aAgDeletados)

   /*
   Geração da Work de Backup de Despesas. 
   */
   dbSelectArea("WorkDe")
   DbGoTop() // JPM - 17/03/06 - Dar DbGoTop antes dos 'Copy To' para não gerar erro em CTree.
   //Copy To (cEETWkBck)
   TETempBackup(cEETWkBck) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados
   aDelEETBck := aClone(aDeDeletados)
   
   //FDR - 29/07/11
   WorkAg->(DBEVAL({||  If(Left(EEB_TIPOAG, 1) <> "3", WorkAg->WK_FILTRO:="S",WorkAg->WK_FILTRO:="")}))
   WorkAg->(dbSetFilter({|| WorkAg->WK_FILTRO == "S" }, "WorkAg->WK_FILTRO == 'S'")) 
        
   //WorkAg->(dbSetFilter({|| Left(EEB_TIPOAG, 1) <> "3" }, "Left(EEB_TIPOAG, 1) <> '3'"))
   
   If EasyEntryPoint("EECAP103")
      ExecBlock("EECAP103",.F.,.F.,"FILTRO_EMPRESAS")
   EndIf

   /*
   Montagem do Tree View.
   */
   aTree := {}
   aAdd(aTree, {"0000", STR0003, "Raiz", "FOLDER5", "FOLDER6", "0001"}) //"Despesas Nacionais"

   WorkAg->(dbGoTop())
   While WorkAg->(!Eof())

      If !lEE7Auto
         IncProc()
      EndIf      

      aAdd( aTree, { "0001",;
                     AllTrim(AVCapital(WorkAg->EEB_NOME)) + " - " + AllTrim(AVCapital(SubStr(WorkAg->EEB_TIPOAG, 3))),;
                     "E"+WorkAg->(EEB_CODAGE+EEB_TIPOAG),;
                     "BMPUSER",;
                     "BMPUSER",;
                     StrZero(nSubNivel, 4) } )

      WorkDe->(dbGoTop())
      While WorkDe->(!Eof())

         If WorkDe->(EET_CODAGE == WorkAg->EEB_CODAGE .and. EET_TIPOAG == WorkAg->EEB_TIPOAG) .and. aTree[Len(aTree)][3] <> "D"+(WorkDe->EET_CODAGE+WorkDe->EET_TIPOAG+WorkDe->EET_DESPES)

            aAdd( aTree, { StrZero(nSubNivel, 4),;
                           AVCapital(Posicione("SYB", 1, xFilial("SYB")+WorkDE->EET_DESPES, "YB_DESCR")),;
                           "D"+WorkDe->(EET_CODAGE+EET_TIPOAG+EET_DESPES),;
                           "PMSDOC",;
                           "PMSDOC",;
                           "" } )

         EndIf

         WorkDE->(dbSkip())

      End

      nSubNivel++
      WorkAG->(dbSkip())

   End

End Sequence

Return(Nil)


/*
Função      : DespNacTela
Objetivo    : Apresentação da Tela com TreeView.
Parametro   : nOpc_p = 2 -> Exclusão e Visualização.
                       3 -> Inclusão.
                       4 -> Alteração.
Retorno     : .T., para Ok, .F. para Cancelar.
Autor       : Alexsander Martins dos Santos
Data e Hora : 08/09/2004 às 10:50.
*/                               

Static Function DespNacTela(nOpc_p, lEETAuto, aAuto)

Local nOpc       := 0
Local nPos       := 1
/*
Local bOk        := {|| nOpc := 1, oDlg:End()}
Local bCancel    := {|| nOpc := 0, oDlg:End()}
*/
Local aCols      := {}
Local aSaveOrd   := SaveOrd("SX3", 1)
Local oDlg
Local aNotDeEnchoice, cCampo
Local i, j   // By JPP - 11/01/05 11:10 
Local nLinFinal
Local oPanel, oPanel1

Private nOpcAux  // TLM 13/02/2008

Private bOk        := {|| nOpc := 1, If(!lEETAuto, oDlg:End(), )}
Private bCancel    := {|| nOpc := 0, If(!lEETAuto, oDlg:End(), )}
                        
Private aAuxDesp   := {}   //Utilizado em Ponto de Entrada.

Private cMemo              // CAF 08/12/04 para utilizar no ponto de entrada
Private aButtons   := {}   // CAF 08/12/04 para utilizar no ponto de entrada
Private aMenuPopUp := {}   // CAF 08/12/04 para utilizar no ponto de entrada

Private oMSMGet, oMSSelect, aPos

Private aTela[0][0]
Private aGets[0]

Private oTotDesp
Private oSayDesp
Private nTotDesp   := 0                                    

Private oTDespAd
Private oSayDespAd
Private nTDespAd   := 0                                    

Private oTDespNoAd
Private oSayDeNoAd
Private nTDespNoAd := 0                                    
                  
Private oSldAdian
Private oSaySldAd
Private nSldAdian  := 0                                    

Private oTotAdian
Private oSayAdian
Private nTotAdian  := 0

Private oTotDevol
Private oSayDevol
Private nTotDevol  := 0

Private oTotCompl 
Private oSayCompl 
Private nTotCompl  := 0

Private oTotAdia_i
Private oSayAdia_i

Default lEETAuto := .F.//RMD - 24/02/20 - Possibilita a inclusão de despesas nacionais via Rotina Automática

Begin Sequence

   aAdd(aMenuPopUp, {STR0007,    {|| DespNacMan(VIS_DET)}}) //"Visualizar"

   If nOpc_p = 3 .or. nOpc_p = 4
      aAdd(aButtons, {"BMPINCLUIR" /*"EDIT"*/,    {|| DespNacMan(INC_DET,oTree:GetCargo())}, STR0004}) //"Incluir"
      aAdd(aButtons, {"EDIT" /*"ALT_CAD"*/   , {|| DespNacMan(ALT_DET,oTree:GetCargo())}, STR0005}) //"Alterar"
      aAdd(aButtons, {"EXCLUIR", {|| DespNacMan(EXC_DET,oTree:GetCargo())}, STR0006}) //"Excluir"

      aAdd(aMenuPopUp, {"-", ""})
      aAdd(aMenuPopUp, {STR0004,    {|| DespNacMan(INC_DET,oTree:GetCargo())}}) //"Incluir"
      aAdd(aMenuPopUp, {STR0005,    {|| DespNacMan(ALT_DET,oTree:GetCargo())}}) //"Alterar"
      aAdd(aMenuPopUp, {"-", ""})
      aAdd(aMenuPopUp, {STR0006,    {|| DespNacMan(EXC_DET,oTree:GetCargo())}}) //"Excluir"
   EndIf

   aAdd(aButtons, {"BMPVISUAL" /*"ANALITICO"*/,  {|| DespNacMan(VIS_DET,oTree:GetCargo())}, STR0007}) //"Visualizar"

   /* by jbj - 30/03/2005 - O sistema deverá permitir ao usuário incluir despesas nacionais
                            mesmo após ter realizado o embarque das mercadorias. */
   /*
   If cOrigem <> OC_PE .and. !Empty(M->EEC_DTEMBA)
      aButtons   := {{"ANALITICO",  {|| DespNacMan(VIS_DET,oTree:GetCargo())}, STR0007}}
      aMenuPopUp := {{STR0007,      {|| DespNacMan(VIS_DET,oTree:GetCargo())}}}
   EndIf
   */
   
   aNotEnchoice := { "EET_FILIAL", "EET_CODAGE", "EET_PEDIDO",;
                     "EET_OCORRE", "EET_CODINT", "EET_NR_CON",;
                     "EET_DTEMBA", "EET_FORNEC", "EET_LOJAF" }

   aDeEnchoice := {}

   /*
   SX3->(dbSeek("EET"))
   SX3->(dbEval( {|| aAdd(aDeEnchoice, AllTrim(X3_CAMPO)) },;
                 {|| aScan(aNotEnchoice, AllTrim(X3_CAMPO)) = 0 },;
                 {|| X3_ARQUIVO == "EET"},,, .F. ))
   */

   //////////////////////////////////////////////////////////////
   //Remove os campos utilizados na integração com o financeiro//
   //da tela, quando for acessado da fase de pedido ou quando  //
   //aintegração estiver desabilitada.                         //
   //////////////////////////////////////////////////////////////
   If !IsIntEnable("001") .and. !IsIntEnable("010") .or. cOrigem == OC_PE
      aAdd(aNotEnchoice,"EET_DTVENC")
      aAdd(aNotEnchoice,"EET_NATURE")
      aAdd(aNotEnchoice,"EET_FINNUM")
   EndIf

   SX3->(DbSetOrder(1))
   If SX3->(dbSeek("EET"))
      Do While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "EET"
         If X3Uso(SX3->X3_USADO)
            If aScan(aNotEnchoice, AllTrim(SX3->X3_CAMPO)) = 0
               aAdd(aDeEnchoice, AllTrim(SX3->X3_CAMPO))
            EndIf
         EndIf
         SX3->(DbSkip())
      EndDo
   EndIf

   SX3->(DbSetOrder(2))
   For nPos := 1 To Len(aDeEnchoice)
      If SX3->(DbSeek(aDeEnchoice[nPos]))
         If !X3Uso(SX3->X3_USADO) .Or. Upper(SX3->X3_BROWSE) != "S" .Or. SX3->X3_NIVEL > cNivel .Or.;
            SX3->X3_TIPO == "M"
            Loop
         Endif

         If !aDeEnchoice[nPos] $ "EET_NOMAGE, EET_TIPOAG" //"EET_DESPES, EET_DESCDE, EET_NOMAGE, EET_TIPOAG"
            IF aDeEnchoice[nPos] == "EET_DESCDE"
               aAdd(aCols, { {||Posicione("SYB",1,xFilial("SYB")+WorkDE->EET_DESPES,"YB_DESCR")},"",AVSX3("EET_DESCDE",AV_TITULO)})
            Else
               aAdd(aCols, ColBrw(aDeEnchoice[nPos], "WorkDE"))
            Endif
         EndIf
      EndIf
   Next

   cMemo := STR0003 + Replicate(ENTER, 2) //"Despesas Nacionais"
   cMemo += STR0008 + ENTER               //"Utilize a estrutura ao lado para navegar pelas Empresas com suas devidas despesas."
   cMemo += STR0009 + ENTER               //"Para realizar a manutenção das empresas ou despesas, utilize os botões da barra de "
   cMemo += STR0010                       //"ferramentas ou acesse as opções do menu pop-up, com o botão direito do mouse."

   cCampo := If(cOrigem = OC_PE, "EE7_PEDIDO", "EEC_PREEMB")
   
   IF EasyEntryPoint("EECAP103")         //GFC - 06/12/04
      ExecBlock("EECAP103",.F.,.F.,"TELA_DESPESAS")
   Endif

   If !lEETAuto//RMD - 24/02/20

      Define MSDialog oDlg Title STR0003 + STR0016 + Transform(M->&(cCampo), AVSX3(cCampo, AV_PICTURE)) From DLG_LIN_INI,DLG_COL_INI To DLG_LIN_FIM,DLG_COL_FIM Of oMainWnd Pixel //"Despesas Nacionais" //" do Processo "

         oPanel:= TPanel():New(0, 0, "",oDlg, , .F., .F.,,, (oDlg:nRight-oDlg:nLeft)*0.5, (oDlg:nBottom-oDlg:nTop)*0.5)
      
         aPos          := PosDlg(oPanel)
         aPos[1]       := 1
         aPos[2]       := 103

         oPanel1:= TPanel():New(aPos[3]*0.75, aPos[2], "",oPanel, , .F., .F.,,, aPos[4]-102, aPos[3]*0.28)

         oTree         := AVTree(aTree, {aPos[1], 1, aPos[3], 102}, aMenuPopUp, oPanel)
         oTree:bChange := {|| DespNacFocus(oTree:GetCargo())}

         @ aPos[1], aPos[2] Get oMemo Var cMemo MEMO HSCROLL SIZE aPos[4]-103, aPos[3] READONLY Of oPanel UPDATE Pixel //aPos[3]-15
         oMemo:lWordWrap := .F.

         For j := 1 TO WorkAg->(FCount())
            M->&(WorkAg->(FieldName(j))) := WorkAg->(FieldGet(j))
         Next

         oMSMGet := MSMGet():New("EEB",, 3,,,, aAgEnchoice, {aPos[1], aPos[2], aPos[3]*0.13, aPos[4]}, {}, 3,,,, oPanel)
         oMSMGet:oBox:Hide()
      
         // by CRF - 25/10/2010 11:29
         aCols := AddCpoUser(aCols,"EET","5","WorkDE")
            
         oMSSelect := MSSelect():New("WorkDE",,, aCols,,, {aPos[3]*0.14, aPos[2], aPos[3]*0.74, aPos[4]},,, oPanel)
      
         oMsSelect:bAval := {|| DespNacMan(VIS_DET, "D")}
         oMSSelect:oBrowse:Hide()

         DespNacERod(oPanel1)

         oSayDesp:Hide()
         oTotDesp:Hide()
      
         oSayDespAd:Hide()
         oTDespAd:Hide()
      
         oSayDeNoAd:Hide()
         oTDespNoAd:Hide()
      
         oSaySldAd:Hide()
         oSldAdian:Hide()
      
         oSayAdian:Hide()
         oTotAdian:Hide()

         //Será exibido apenas quando selecionado um item do tipo adiantamento
         oTotAdia_i:Hide()
         oSayAdia_i:Hide()
         
         oSayDevol:Hide()
         oTotDevol:Hide()

         oSayCompl:Hide()
         oTotCompl:Hide()
      
         oDlg:lMaximized := .T.
         oPanel:Align:= CONTROL_ALIGN_ALLCLIENT   
      
      Activate MSDialog oDlg On Init (oTree:TreeSeek("Raiz"), EnchoiceBar(oDlg, bOk, bCancel,, aButtons))
   Else
      //RMD - 24/02/20 - Manutenção de despesas nacionais via Rotina Automática (MsExecAuto)
      If (nPosSeq := aScan(aAuto, {|x| Alltrim(x[1]) == "EET_SEQ" })) > 0
         //Caso tenha sido informado o campo EET_SEQ, posiciona a despesa e empresa com base nele
         aOrdWkEET := SaveOrd("WorkDe")
         WorkDe->(DbClearFilter())
         WorkAg->(DbClearFilter())
         WorkDe->(DbSetOrder(3))
         WorkAg->(DbSetOrder(1))
         If WorkDe->(DbSeek(M->EEC_PREEMB+AvKey(aAuto[nPosSeq][2], "EET_SEQ"))) .And. WorkAg->(DbSeek(AvKey(WorkDe->EET_CODAGE, "EEB_CODAGE")))
            //Executa a manutenção automática da despesa recebida
            If DespNacMan(If(nOpc_p <> EXCLUIR, ALT_DET, EXC_DET),"D", lEETAuto, aAuto, 2)
               WorkDe->(DbClearFilter())
               WorkDe->(DbSetOrder(4))
               /* Se for uma alteração, executa o botão ok. Caso seja exclusão, verifica se existem mais despesas associadas à mesma empresa.
                  Caso existam, também segue para o botão ok, porém caso não tenha mais nenhuma despesa associada à empresa, exclui a empresa do embarque antes de prosseguir.*/
               If nOpc_p <> EXCLUIR .Or. WorkDe->(DbSeek(WorkAg->EEB_CODAGE)) .Or. DespNacMan(EXC_DET,"E", lEETAuto, {{"EEB_CODAGE", WorkAg->EEB_CODAGE, Nil}}, 1)
                  Eval(bOk)
               EndIf
            EndIf
         Else
            EasyHelp(StrTran("Erro ao atualizar a despesa nacional. Não foi identificada uma despesa com a sequência (EET_SEQ) igual a 'XXX'.", "XXX", aAuto[nPosSeq][2]), "Aviso")
            lMsErroAuto := .T.
         EndIf
         RestOrd(aOrdWkEET)
      
      ElseIf (nPosAge := aScan(aAuto, {|x| Alltrim(x[1]) == "EET_CODAGE" })) > 0 .And. nOpc_p <> EXCLUIR 
         //Se não informou o EET_SEQ, trata-se de uma inclusão e é obrigatório informar o EET_CODAGE para associar a despesa.
         If nOpc_p == EXCLUIR
            EasyHelp("Erro na exclusão de despesa nacional. Não é possível excluir uma despesa sem informar o campo 'EET_SEQ'.", "Aviso")
            lMsErroAuto := .T.
         Else
            WorkAg->(DbSetOrder(1))
            //Se a empresa já estiver vinculada ao Embarque, inclui a despesa associada à ele.
            If WorkAg->(DbSeek(AvKey(aAuto[nPosAge][2], "EEB_CODAGE")))
               If DespNacMan(INC_DET,"D", lEETAuto, aAuto)
                  Eval(bOk)
               Else
                  Eval(bCancel)
               EndIf
            Else
               //Se a empresa não estiver vinculada ao Embarque, faz a vinculação automaticamente e depois inclui a despesa asssociada a ela.
               aEmpAuto := {aAuto[nPosAge]}
               aEmpAuto[1][1] := "EEB_CODAGE"
               If DespNacMan(INC_DET,"E", lEETAuto, aEmpAuto, 1) .And. DespNacMan(INC_DET,"D", lEETAuto, aAuto, 2)
                  Eval(bOk)
               Else
                  Eval(bCancel)
               EndIf
            EndIf
         EndIf
      Else
         If nOpc_p == EXCLUIR
            EasyHelp("Erro na exclusão de despesa nacional. Não é possível excluir uma despesa sem informar o campo 'EET_SEQ'.", "Aviso")
         Else
            EasyHelp("Erro na inclusão da despesa nacional. O agente não foi informado." + ENTER, "Aviso")
         EndIf
         lMsErroAuto := .T.
         Eval(bCancel)
      EndIf
   EndIf

   IF EasyEntryPoint("EECAP103")         //JPM - 12/06/06  
      nOpcAux := nOpc  // TLM 13/02/2008 - Variavel nOpcAux foi criada para não alterar a declaração da variavel nOpc 
      ExecBlock("EECAP103",.F.,.F.,"DEPOIS_TELA_DESPESAS")
      nOpc := nOpcAux
   Endif

End Sequence

RestOrd(aSaveOrd)

Return(nOpc == 1)


/*
Função      : DespNacFocus()
Objetivo    : Apresentar MSSelect das Despesas Nacionais.
Autor       : Alexsander Martins dos Santos.
Data e Hora : 14/09/2004 às 14:02.
*/

Static Function DespNacFocus(cFocus_id)

Local lRet         := .T.
Local nSize_CodAge := AVSX3("EEB_CODAGE", AV_TAMANHO)
Local nSize_TipoAg := AVSX3("EEB_TIPOAG", AV_TAMANHO)
Local j  // By JPP - 11/01/05 11:10  
Local cFiltro := "" //AOM - 18/07/2011 

Begin Sequence

   cFocus    := AllTrim(cFocus_id)
   cFocus_id := AllTrim(cFocus_id)

   WorkAG->(dbSeek(AVKey(SubStr(cFocus, 2, nSize_CodAge), "EEB_CODAGE") +;
                   AVKey(SubStr(cFocus, nSize_CodAge+2, nSize_TipoAg), "EEB_TIPOAG")))

   Do Case

      Case cFocus_id = "Raiz"

         oMemo:Show()
         oMemo:Refresh()

         oMSMGet:oBox:Hide()
         oMSSelect:oBrowse:Hide()

         oSayDesp:Hide()
         oTotDesp:Hide()
   
         oSayDespAd:Hide()
         oTDespAd:Hide()
   
         oSayDeNoAd:Hide()
         oTDespNoAd:Hide()
   
         oSaySldAd:Hide()
         oSldAdian:Hide()
      
         oSayAdian:Hide()
         oTotAdian:Hide()

         //Será exibido apenas quando selecionado um item do tipo adiantamento
         oTotAdia_i:Hide()
         oSayAdia_i:Hide()   

         oSayDevol:Hide()
         oTotDevol:Hide()

         oSayCompl:Hide()
         oTotCompl:Hide()

         WorkDE->(dbClearFilter())

      Case Left(cFocus_id, 1) = "E"

         For j := 1 TO WorkAg->(FCount())
            M->&(WorkAg->(FieldName(j))) := WorkAg->(FieldGet(j))
         Next

         oMemo:Hide()

         WorkDE->(dbClearFilter())
         WorkDE->(dbGoTop())
         
         //AOM - 18/07/2011  // *** GFP - 19/08/2011 - Nopado
         //cFiltro := "RTrim(WorkDE->EET_CODAGE+WorkDE->EET_TIPOAG) == '"+SubStr(cFocus_id, 2)+"'"
         //WorkDE->(dbSetFilter({|| &cFiltro},cFiltro))
         
         // *** GFP - 19/08/2011
         WorkDE->(DBEVAL({|| If(RTrim(WorkDE->EET_CODAGE+WorkDE->EET_TIPOAG) == SubStr(cFocus_id, 2), WorkDE->WK_FILTRO := "S",WorkDE->WK_FILTRO := "")}))
         WorkDE->(dbSetFilter({|| WorkDE->WK_FILTRO == "S" }, "WorkDE->WK_FILTRO == 'S'")) 
         // *** Fim GFP         

         WorkDE->(dbGoTop())
         
         oMSSelect:oBrowse:Show()
         oMSSelect:oBrowse:Refresh()
         
         WorkDe->(DbGoTop())

         oSayDesp:Show()
         oTotDesp:Show()

         oSayDespAd:Show()
         oTDespAd:Show()
   
         oSayDeNoAd:Show()
         oTDespNoAd:Show()
   
         oSaySldAd:Show()
         oSldAdian:Show()

         oSayAdian:Show()         
         oTotAdian:Show()

         //Será exibido apenas quando selecionado um item do tipo adiantamento
         oTotAdia_i:Hide()
         oSayAdia_i:Hide()

         oSayDevol:Show()
         oTotDevol:Show()

         oSayCompl:Show()         
         oTotCompl:Show()

         DespNacTot()

         oMSMGet:oBox:Show()
         oMSMGet:Refresh()

      Case Left(cFocus_id, 1) = "D"

         oMemo:Hide()
         //oMSMGet:oBox:Hide()

         WorkDE->(dbClearFilter())
         WorkDE->(dbGoTop())
         
         //AOM - 18/07/2011  // *** GFP - 19/08/2011 - Nopado
         //cFiltro := "RTrim(WorkDE->EET_CODAGE+WorkDE->EET_TIPOAG+WorkDE->EET_DESPES) == '"+SubStr(cFocus_id, 2)+"'"
         //WorkDE->(dbSetFilter({|| &cFiltro}, cFiltro))
         
         // *** GFP - 19/08/2011
         WorkDE->(DBEVAL({|| If(RTrim(WorkDE->EET_CODAGE+WorkDE->EET_TIPOAG+WorkDE->EET_DESPES) == SubStr(cFocus_id, 2), WorkDE->WK_FILTRO := "S",WorkDE->WK_FILTRO := "")}))
         WorkDE->(dbSetFilter({|| WorkDE->WK_FILTRO == "S" }, "WorkDE->WK_FILTRO == 'S'")) 
         // *** Fim GFP

         WorkDE->(dbGoTop())
         
         oMSSelect:oBrowse:Show()
         oMSSelect:oBrowse:Refresh()

         If ("901" $ cFocus_id)

            //Será exibido apenas quando selecionado um item do tipo adiantamento
            oTotAdia_i:Show()
            oSayAdia_i:Show()   

            oSayDesp:Hide()
            oTotDesp:Hide()

            oSayDespAd:Hide()
            oTDespAd:Hide()
         Else
            oSayDesp:Show()
            oTotDesp:Show()

            oSayDespAd:Show()
            oTDespAd:Show()         

            oSayAdia_i:Hide()         
            oTotAdia_i:Hide()
         EndIf

         oSayAdian:Hide()
         oTotAdian:Hide()

         oSayDeNoAd:Hide()
         oTDespNoAd:Hide()

         oSaySldAd:Hide()
         oSldAdian:Hide()
         
         oSayDevol:Hide()
         oTotDevol:Hide()

         oSayCompl:Hide()         
         oTotCompl:Hide()
         
         DespNacTot()

   End Case

End Sequence

Return(lRet)


/*
Função      : DespNacMan()
Objetivo    : Manutenção (Visualização, Inclusão, Alteração e Exclusão) da Despesa Nacional.
Parametro   : nOpc = Opção para manutenção.
Autor       : Alexsander Martins dos Santos
Data e Hora : 15/09/2004 às 16:27.
*/

Static Function DespNacMan(nOpc, pFocus, lEETAuto, aAuto, nAutoOpc)

Local nPos        := 0
Local nDespNacOpc := 0
Local nOldArea    := Select()
Local nSize_CodAge := AVSX3("EEB_CODAGE", AV_TAMANHO)
Local nSize_TipoAg := AVSX3("EEB_TIPOAG", AV_TAMANHO) 
Local j  // By JPP - 11/01/05 11:10                

Private aCmpEdit  := {}
Private aOpcoes   := {STR0007, STR0004, STR0005, STR0006} //"Visualizar"###"Incluir"###"Alterar"###"Excluir"
Private lExit:= .F. //TRP-28/06/07

If pFocus <> Nil
   cFocus := pFocus
EndIf

Begin Sequence

If !lEETAuto
   dbSelectArea(oTree:cArqTree)
   dbSetOrder(4)
EndIf


   Do Case

      Case cFocus = "Raiz" .or. Empty(cFocus) .or. cFocus = Nil

            If nOpc = INC_DET           
               Do While !lExit
                  For j := 1 TO EEB->(FCount())
                     M->&(EEB->(FieldName(j))) := CriaVar(EEB->(FieldName(j)))
                  Next
  
                  aCmpEdit := aClone(aAgEnchoice)
                  DespNacEMan(nOpc)
                  If lEETAuto
                     lExit := .T.
                  EndIf
               Enddo
            Else
               MsgInfo(STR0017+aOpcoes[nOpc-2]+".", STR0014) //"Selecione uma Empresa ou Despesa que deseja "###"Atenção"
            EndIf
			
			DespNacFocus(oTree:GetCargo())

      Case Left(cFocus, 1) $ "ED"

         Do Case

            Case nOpc = INC_DET

               If lEETAuto//RMD - 24/02/20 - Se for ExecAuto recebe a opção por meio do parâmetro nAutoOpc.
                  nDespNacOpc := nAutoOpc
               Else
                  If (nDespNacOpc := DespNacOpc()) = 0
                     Break
                  EndIf
               EndIf

               Do While !lExit
                  If nDespNacOpc = 1
                     For j := 1 TO EEB->(FCount())
                        M->&(EEB->(FieldName(j))) := CriaVar(EEB->(FieldName(j)))
                     Next
                  Else
                     For j := 1 TO EET->(FCount())
                        M->&(EET->(FieldName(j))) := CriaVar(EET->(FieldName(j)))
                     Next
                  EndIf
               
                  aCmpEdit := If(nDespNacOpc = 1, aClone(aAgEnchoice), aClone(aDeEnchoice))

                  
                  If nDespNacOpc = 1

                     DespNacEMan(nOpc, lEETAuto, aAuto)

                  Else

                     If Left(cFocus, 1) = "D"

                        M->EET_DESPES := Right(AllTrim(cFocus), AVSX3("EET_DESPES", AV_TAMANHO)) //WorkAg->EEB_CODAGE
                        M->EET_DESCDE := Posicione("SYB", 1, xFilial("SYB")+WorkDE->EET_DESPES, "YB_DESCR")

                     /*
                     If (nPos := aScan(aCmpEdit, "EET_DESPES")) > 0
                        aDel(aCmpEdit, nPos)
                        aSize(aCmpEdit, Len(aCmpEdit)-1)
                     EndIf                     
                     */
                     EndIf
                  
                     M->EET_NOMAGE := WorkAg->EEB_NOME
                     M->EET_CODAGE := WorkAg->EEB_CODAGE
                     M->EET_TIPOAG := WorkAg->EEB_TIPOAG
                     M->EET_FORNEC := WorkAg->EEB_FORNEC
                     M->EET_LOJAF  := WorkAg->EEB_LOJAF
                     
                     If Left(AllTrim(WorkAg->EEB_TIPOAG),1) == "6" //Despachante
                        M->EET_PAGOPO := "2"
                     EndIf
                     
                     If DespNacDMan(nOpc, lEETAuto, aAuto) .And. !lEETAuto
                        oMSSelect:oBrowse:Refresh()
                     EndIf

                  EndIf
               
                  If !lEETAuto
                     oMSSelect:oBrowse:Refresh()
                  Else
                     lExit := .T.
                  EndIf
                  
               EndDo
            Case nOpc = ALT_DET
              
               If Left(cFocus, 1) = "E"
                  
                  WorkAG->(DbSeek(AVKey(SubStr(cFocus, 2, nSize_CodAge), "EEB_CODAGE")+;
                                  AVKey(SubStr(cFocus, nSize_CodAge+2, nSize_TipoAg), "EEB_TIPOAG")))
                  
                  For j := 1 TO WorkAg->(FCount())
                      M->&(WorkAg->(FieldName(j))) := WorkAg->(FieldGet(j))
                  Next
               Else
                  For j := 1 TO WorkDe->(FCount())
                      M->&(WorkDe->(FieldName(j))) := WorkDe->(FieldGet(j))
                  Next

                  M->EET_NOMAGE := WorkAg->EEB_NOME
               EndIf             
                                            
               aCmpEdit := If(Left(cFocus, 1) = "E", aClone(aAgEnchoice), aClone(aDeEnchoice))

               If Left(cFocus, 1) = "E"

                  If (nPos := aScan(aCmpEdit, "EEB_CODAGE")) > 0
                     aDel(aCmpEdit, nPos)
                     aSize(aCmpEdit, Len(aCmpEdit)-1)
                  EndIf

                  If (nPos := aScan(aCmpEdit, "EEB_TIPOAG")) > 0
                     aDel(aCmpEdit, nPos)
                     aSize(aCmpEdit, Len(aCmpEdit)-1)
                  EndIf

                  DespNacEMan(nOpc, lEETAuto, aAuto)

               Else

                  M->EET_DESCDE := Posicione("SYB", 1, xFilial("SYB")+WorkDE->EET_DESPES, "YB_DESCR")

                  If (nPos := aScan(aCmpEdit, "EET_DESPES")) > 0
                     aDel(aCmpEdit, nPos)
                     aSize(aCmpEdit, Len(aCmpEdit)-1)
                  EndIf

                  ////////////////////////////////////////////////////////////////////////////////////
                  //Caso o título no financeiro esteja baixado, não será possível alterar a despesa.//
                  ////////////////////////////////////////////////////////////////////////////////////
                  If IsIntEnable("001")
                     If !Empty(M->EET_FINNUM)
                        If IsTitBaixa("EEC",M->EET_FINNUM)
                           aCmpEdit := {}
                        EndIf
                     EndIf
                  EndIf

                  If DespNacDMan(nOpc, lEETAuto, aAuto) .And. !lEETAuto
                     oMSSelect:oBrowse:Refresh()
                  EndIf

               EndIf

               If !lEETAuto
                  oMSSelect:oBrowse:Refresh()
                  WorkDe->(DbGoTop())
               EndIf
            
            Otherwise

               If Left(cFocus, 1) = "E"
                  For j := 1 TO WorkAg->(FCount())
                      M->&(WorkAg->(FieldName(j))) := WorkAg->(FieldGet(j))
                  Next
               Else
                  For j := 1 TO WorkDe->(FCount())
                      M->&(WorkDe->(FieldName(j))) := WorkDe->(FieldGet(j))
                  Next
                  
                  M->EET_NOMAGE := WorkAg->EEB_NOME
               EndIf             

               aCmpEdit := {}

               If Left(cFocus, 1) = "E"
                  DespNacEMan(nOpc, lEETAuto, aAuto)
               Else

                  M->EET_DESCDE := Posicione("SYB", 1, xFilial("SYB")+WorkDE->EET_DESPES, "YB_DESCR")

                  If DespNacDMan(nOpc, lEETAuto, aAuto) .and. nOpc = EXC_DET .And. !lEETAuto
                     oMSSelect:oBrowse:Refresh()
                  EndIf

               EndIf               
         End Case
   End Case

End Sequence

If !lEETAuto
   DespNacTot()
EndIf

DbSelectArea(nOldArea)

Return If(lEETAuto, !lMsErroAuto, Nil)


/*
Função      : DespNacOpc
Objetivo    : Apresentar e retornar a opção entre Empresa/Despesa para inclusão.
Autor       : Alexsander Martins dos Santos
Date e Hora : 15/09/2004 às 20:00
*/

Static Function DespNacOpc()

Local nRet := 0
Local oDlg

Define MSDialog oDlg Title STR0018 From 9,0 To 15,30 Of oMainWnd //"Inclusão"

@ 05,005 To 42,115 LABEL STR0032 Pixel //"O que deseja incluir ?"

@ 21,025 Button STR0012 Size 35,12 Action (nRet := 1, oDlg:End()) Of oDlg Pixel //"Empresa"
@ 21,065 Button STR0015 Size 35,12 Action (nRet := 2, oDlg:End()) Of oDlg Pixel //"Despesa"

Activate MsDialog oDlg Centered

Return(nRet)


/*
Função      : DespNacEMan
Objetivo    : Manutenção (Inclusão, Alteração e Exclusão) de empresa.
Parametro   : nOpc = Opção para manutenção.
Returno     : .T., manutenção concluida, .F.. manutenção cancelada.
Autor       : Alexsander Martins dos Santos
Data e Hora : 15/09/2004 às 20:16.
*/

Static Function DespNacEMan(nOpc, lEETAuto, aAuto)

Local bOk     := {|| If((nOpcDet := If(DespNacEVld(nOpc, lEETAuto), 1, 0)) = 1, If(!lEETAuto, oDlg:End(), ),)}
Local bCancel := {|| nOpcDet := 0, oDlg:End()}

Local nOpcDet := 0

Local oDlg, lTreeFound

Local cOldFilter, bOldFilter

Local aOldaTela
Local aOldaGets
Local nRec :=0
Local j   // By JPP - 11/01/05 11:10
Local oMsmGet1
Default lEETAuto := .F.//RMD - 24/02/20 - Possibilita a inclusão de despesas nacionais via Rotina Automática

Begin Sequence

   aOldaTela := aTela
   aOldaGets := aGets

   If EasyEntryPoint("EECAP103")
      ExecBlock("EECAP103",.F.,.F.,"ANTES_TELA_EMP")
   EndIf

   If !lEETAuto
   
      Define MSDialog oDlg Title STR0012 + " - " + aOpcoes[nOpc-2] From 9, 0 To 35, 80 Of oMainWnd //"Empresa"

         oMsmGet1 := MSMGet():New("EEB",, If(nOpc == INC_DET, 3, 4),,,, aAgEnchoice, PosDlg(oDlg), aCmpEdit, 3)
         oMsmGet1:oBox:Align:= CONTROL_ALIGN_ALLCLIENT

      Activate MSDialog oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) Centered
   Else
      EnchAuto("EEB",ValidaEnch(aAuto, If(nOpc==EXCLUIR, {}, aCmpEdit)),{|| Obrigatorio(aGets,aTela)},3, aAgEnchoice)
      If !lMsErroAuto
         Eval(bOk)
      EndIf
   EndIf

   If nOpcDet = 1

      Do Case

         Case nOpc = INC_DET .or. nOpc = ALT_DET

            nRec := WorkAg->(RecNo())
            cOldFilter := WorkAg->(DbFilter())
            //bOldFilter := &("{|| "+if(Empty(cOldFilter),".t.",cOldFilter)+" }") - NOPADO POR AOM - 10/08/2011 
            //AOM - 10/08/2011 
            If !Empty(cOldFilter)
               bOldFilter := &("{|| "+cOldFilter+" }")
            EndIf
            WorkAg->(DbClearFilter())

            If nOpc = INC_DET
               WorkAg->(dbAppend())

               M->EET_PEDIDO := M->(If(cOrigem == OC_PE, M->EE7_PEDIDO, M->EEC_PREEMB))
               M->WK_RECNO := 0 // By JPP - 26/02/2008 - 12:10 - Esta variável deve ser limpa na inclusão, para não ficar residuos e desbalancear a base.
               If !lEETAuto
                  lTreeFound := oTree:TreeSeek("E")

                  oTree:AddItem( AllTrim(AVCapital(M->EEB_NOME)) + " - " + AllTrim(AVCapital(SubStr(M->EEB_TIPOAG, 3))),;
                                 "E"+M->EEB_CODAGE+M->EEB_TIPOAG,;
                                 "BMPUSER",;
                                 "BMPUSER",,,;
                                 If(lTreeFound, 1, 2) )
               EndIf
            EndIf

            If nOpc = ALT_DET .And. !lEETAuto
               oTree:ChangePrompt(AllTrim(AVCapital(M->EEB_NOME)) + " - " + AllTrim(AVCapital(SubStr(M->EEB_TIPOAG, 3))))
            EndIf

            AVReplace("M", "WorkAg")
            
            //DFS - 10/02/12 - Alteração para carregar as informações cadastradas nas despesas nacionais   
            If Left(M->EEB_TIPOAG, 1) <> "3"
               WorkAg->WK_FILTRO:="S"
            Else
               WorkAg->WK_FILTRO:=""
            EndIf

            If !Empty(cOldFilter) .And. !lEETAuto
               WorkAg->(DbSetFilter(bOldFilter,cOldFilter))
               If nOpc = ALT_DET
                  WorkAg->(DbGoTo(nRec))
               EndIf
            EndIf
            If !lEETAuto
               oTree:TreeSeek("E"+M->EEB_CODAGE+M->EEB_TIPOAG)
            EndIf
            
         Case nOpc = EXC_DET

            If WorkAg->WK_RECNO <> 0
               aAdd(aAgDeletados, WorkAg->WK_RECNO)
            EndIf

            WorkAg->(dbDelete())

            WorkDe->( dbEval( {|| If(EET_RECNO <> 0, aAdd(aDeDeletados, WorkDe->EET_RECNO),), dbDelete() },;
                              {|| EET_CODAGE+EET_TIPOAG == M->EEB_CODAGE+M->EEB_TIPOAG } ) )
            If !lEETAuto
               oTree:TreeSeek("E"+M->EEB_CODAGE+M->EEB_TIPOAG)
               oTree:DelItem()
               oTree:TreeSeek("Raiz")
               Eval(oTree:bChange)
            EndIf
      EndCase

      For j := 1 TO WorkAg->(FCount())
         M->&(WorkAg->(FieldName(j))) := WorkAg->(FieldGet(j))
      Next   

      If !lEETAuto
         oTree:Refresh()
         oTree:SetFocus()

         oMSSelect:oBrowse:Refresh()
         oMSMGet:Refresh()
      EndIf
   Else
      lExit:=.T.
   EndIf

End Sequence

aTela := aOldaTela
aGets := aOldaGets

Return(nOpcDet==1)

//RMD - 24/02/20 - Retira campos que não podem ser editados no EnchAuto
Static Function ValidaEnch(aAuto, aEdita)
Local i, nPos
Local aReturn := aClone(aAuto)
Local aRetira := {}

    For i := 1 To Len(aReturn)
        If aScan(aEdita, aReturn[i][1]) == 0
            aAdd(aRetira, aReturn[i][1])
        EndIf
    Next
    For i := 1 To Len(aRetira)
        If (nPos := aScan(aReturn, {|x| AllTrim(Upper(x[1])) == AllTrim(Upper(aRetira[i])) })) > 0
            aDel(aReturn, nPos)
            aSize(aReturn, Len(aReturn)-1)
        EndIf
    Next

Return aReturn

/*
Função      : DespNacEVld
Objetivo    : Validar o cadastro de empresas.
Retorno     : .T., dados consistentes, .F., dados não consistentes.
Autor       : Alexsander Martins dos Santos
Data e Hora : 16/09/2004 às 10:10
*/

Static Function DespNacEVld(nOpc, lEETAuto)

Local lRet         := .F.
Local nWorkAgRecno := WorkAg->(Recno())
Local nCountDe     := 0, lRetPto

// ** JPM - 02/06/06 - Dados para ponto de entrada.
Private nOption := nOpc, lValidTipoAg := .T.

Begin Sequence

   If EasyEntryPoint("EECAP103")
      If ValType((lRetPto := ExecBlock("EECAP103",.F.,.F.,"VALIDA_EMPRESA"))) = "L" .And. !lRetPto
         Break
      EndIf
   EndIf

   Do Case

      Case nOpc = INC_DET .or. nOpc = ALT_DET

         If Left(AllTrim(M->EEB_TIPOAG), 1) = "3" .And. lValidTipoAg
            EasyHelp(STR0019, STR0014) //"Para Despesas Nacionais o agente informado não pode ser Recebedor de Comissão."###"Atenção"
            Break
         EndIf

         If Empty(M->EEB_FORNEC) .or. Empty(M->EEB_LOJAF)
            EasyHelp(STR0030, STR0014) //"Empresa não permitida por não haver vinculo com o Fornecedor/Loja."###"Atenção"
            Break
         EndIf

         If nOpc = INC_DET .and. WorkAg->(dbSeek(M->EEB_CODAGE+M->EEB_TIPOAG))
            EasyHelp(STR0013 + Rtrim(M->EEB_TIPOAG) + STR0031, STR0014) //"A empresa informada já está cadastrada com a classifição "###". Informe uma classificação diferente."###"Atenção"
            Break
         EndIf

      Case nOpc = EXC_DET

         WorkDe->(dbEval( {|| nCountDe++ },;
                          {|| EET_CODAGE+EET_TIPOAG == M->EEB_CODAGE+M->EEB_TIPOAG }))

         If nCountDe > 0
            EasyHelp(STR0020, STR0014) //"Exclusão não permitida. A empresa só poderá ser excluída se não possuir despesas cadastradas."###"Atenção"
            Break
         EndIf

         If !lEETAuto .And. !MsgYesNo(STR0021, STR0014) //"Confirma Exclusão?"###"Atenção"
            Break
         EndIf

   EndCase

   If !Obrigatorio(aGets, aTela)
      Break
   EndIf

   lRet := .T.

End Sequence

WorkAg->(dbGoTo(nWorkAgRecno))

Return(lRet)


/*
Função      : DespNacDMan
Objetivo    : Manutenção (Visualização, Inclusão, Alteração e Exclusão) de despesa.
Parametro   : nOpc = Opção para manutenção.
Returno     : .T., manutenção concluida, .F.. manutenção cancelada.
Autor       : Alexsander Martins dos Santos
Data e Hora : 15/09/2004 às 16:32.
*/

Static Function DespNacDMan(nOpc, lEETAuto, aAuto)

Local bOk     := {|| If((nOpcDet := If(DespNacDVld(nOpc, lEETAuto), 1, 0)) = 1, If(!lEETAuto, oDlg:End(), ),)}
Local bCancel := {|| nOpcDet := 0, oDlg:End()}

Local nOpcDet := 0
Local nCount  := 0
Local nPos    := 0

Local oDlg
Local cOldFilter, bOldFilter
Local oMsmGet2

Private aTela[0][0]
Private aGets[0]
Private nOpcPE   := nOpc //DFS - Criação de variável para armazenar data e hora da inclusão ou da última alteração no cadastro de despesas.
Default lEETAuto := .F.//RMD - 24/02/20 - Possibilita a inclusão de despesas nacionais via Rotina Automática

Begin Sequence

   If !lEETAuto

      Define MSDialog oDlg Title STR0015 + " - " + aOpcoes[nOpc-2] From 9, 0 To 35, 80 Of oMainWnd //"Despesa"

         If EasyEntryPoint("EECAP103")   //Alcir - 11-11-04
            ExecBlock("EECAP103",.F.,.F.,"ENCHOICE_DESPESA_NASC")
         EndIf
      
         oMsmGet2 := MSMGet():New("EET",, If(nOpc == INC_DET, 3, 4),,,, aDeEnchoice, PosDlg(oDlg), aCmpEdit, 3)
         oMsmGet2:oBox:Align:= CONTROL_ALIGN_ALLCLIENT

      Activate MSDialog oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) Centered
   Else
      EnchAuto("EET",ValidaEnch(aAuto, aCmpEdit),{|| Obrigatorio(aGets,aTela)},3, aDeEnchoice)
      If !lMsErroAuto
         Eval(bOk)
      EndIf
   EndIf

   If nOpcDet = 1

      Do Case

         Case nOpc = INC_DET .or. nOpc = ALT_DET

            cOldFilter := WorkDe->(DbFilter())
            
            //bOldFilter := &("{|| "+if(Empty(cOldFilter),".t.",cOldFilter)+" }") - NOPADO POR AOM - 10/08/2011
            //AOM - 10/08/2011
            If !Empty(cOldFilter)
               bOldFilter := &("{|| "+cOldFilter+" }")
            EndIf
            

            WorkDe->(DbClearFilter())

            If nOpc = INC_DET

               WorkDE->(dbAppend())

               M->EET_PEDIDO := M->(If(cOrigem == OC_PE, M->EE7_PEDIDO, M->EEC_PREEMB))
               
               //AOM - 19/01/2012
               If EET->(FieldPos("EET_SEQ")) > 0
                   M->EET_SEQ := AP103SEQEET()
               EndIf 

               If !lEETAuto
                  If !oTree:TreeSeek("D"+M->(EET_CODAGE+EET_TIPOAG+EET_DESPES))

                     oTree:AddItem( AVCapital(M->EET_DESCDE),;
                                    "D"+M->(EET_CODAGE+EET_TIPOAG+EET_DESPES),;
                                    "PMSDOC",;
                                    "PMSDOC",,,;
                                    IF(Left(cFocus,1) == "D",1,2) ) //by CAF 2


                     //ER - 31/01/2008 - Posiciona o foco na empresa relacionada a despesa, para montar 
                     //                  corretamente a Tree no caso de inclusões seguidas.
                     oTree:TreeSeek("E"+M->(EET_CODAGE+EET_TIPOAG))              

                  Else
                     oTree:TreeSeek("D"+M->(EET_CODAGE+EET_TIPOAG+EET_DESPES))
                  EndIf
               EndIf               
            EndIf

            AVReplace("M", "WorkDE")

            If !Empty(cOldFilter)
               WorkDe->(DbSetFilter(bOldFilter,cOldFilter))
               WorkDe->(dbGoTop())
            EndIf

         Case nOpc = EXC_DET

            If WorkDe->EET_RECNO <> 0
               aAdd(aDeDeletados, WorkDe->EET_RECNO)
            EndIf

            WorkDE->(dbDelete())

            WorkDe->(dbEval({|| nCount++ }, {|| WorkDe->(EET_CODAGE+EET_TIPOAG+EET_DESPES) == SubStr(cFocus, 2, Len(WorkDe->(EET_CODAGE+EET_TIPOAG+EET_DESPES)))}))

            If nCount = 0 .And. !lEETAuto
               oTree:DelItem()
               Eval(oTree:bChange)
               oTree:Refresh()
               oTree:SetFocus()
            EndIf

            WorkDE->(dbGoTop())
      EndCase
   Else
      lExit:=.T.
   EndIf

   If !lEETAuto
      oTree:Refresh()
      oTree:SetFocus()
      
      oMSSelect:oBrowse:Refresh()
      oMSMGet:Refresh()
   EndIf

End Sequence

Return(nOpcDet==1)


/*
Função      : DespNacDVld
Objetivo    : Validação para despesas.
Returno     : .T., dados consistentes
              .F.. dados inconsistentes.
Autor       : Alexsander Martins dos Santos
Data e Hora : 01/11/2004 às 15:05.
*/

Static Function DespNacDVld(nOpc, lEETAuto)
private Rdm_ret := .T. //Alcir - 11-11-04   - RETORNO DA FUNÇÃO DE VALIDAÇÃO VIA RDMAKE
private lRet := .F.

Begin Sequence
   
   ///////////////////////////////////////////////////////////////////////////////
   //Validação adicional para inclusão/alteração/exclusão das Despesas Nacionais//
   ///////////////////////////////////////////////////////////////////////////////
   If EasyEntryPoint("EECAP103")
      ExecBlock("EECAP103",.F.,.F.,{"VAL_DESPNASC",nOpc})
   EndIf

   If !Rdm_ret 
      Break
   Endif

   Do Case     

      Case nOpc = INC_DET .or. nOpc = ALT_DET

         If EasyEntryPoint("EECAP103")   //Alcir - 11-11-04
            ExecBlock("EECAP103",.F.,.F.,"VALIDA_DESPESA_NASC")
         EndIf

         if Rdm_ret==.f. //Alcir - 11-11-04
            Break
         endif

         If !Obrigatorio(aGets, aTela)
            Break
         EndIf

         If M->EET_DESPES $ "101, 102, 103"
            EasyHelp(STR0022, STR0014) //"Os tipos de despesas Frete/Seguro/FOB somente serão aceitos no Pré-Calculo."###"Atenção"
            Break
         EndIf

      Case nOpc = EXC_DET
         
         ////////////////////////////////////////////////////////////////////////////////////
         //Caso o título no financeiro esteja baixado, não será possível excluir a despesa.//
         ////////////////////////////////////////////////////////////////////////////////////
         If IsIntEnable("001")
            If !Empty(M->EET_FINNUM)
               If IsTitBaixa("EEC",M->EET_FINNUM)
	                  EasyHelp(STR0035,STR0014) //###"Atenção" //STR0035	"O título no SigaFIN referente a essa despesa já foi baixado."
                  Break
               EndIf
            EndIf
         Else

            If !lEETAuto .And. !MsgYesNo(STR0021, STR0014) //"Confirma Exclusão?"###"Atenção"
               Break
            EndIf

         EndIf

   End Case

   lRet := .T.

End Sequence

Return(lRet)


/*
Function EEBTrigger
Objetivo  : Rotina para ser envocada nos campos do EEB que possuirem gatilho.
Parametro : cCampo
            nSequencia
Obs       : Considere-se que no SX7(gatilho) esteja executando o Seek no SY5 na sequencia 001.
*/

Function EEBTrigger(cCampo, nSequencia)

Local xRet
Local aSaveOrd := SaveOrd("EEB")

Begin Sequence

   Do Case
      Case cCampo == "EEB_CODAGE"
         Do Case
            Case nSequencia = 1
               xRet := SY5->Y5_NOME
            Case nSequencia = 2
               //If EECFlags("FRESEGCOM") .and. (Type("lRecebCom") = "L" .and. lRecebCom = .T.)
               //   xRet := M->EEB_TIPOAG := "3-AGENTE (RECEBEDOR COMISSAO)"
               //Else
                  xRet := M->EEB_TIPOAG := SY5->Y5_TIPOAGE
               //EndIf
               AP100Comissao()
         EndCase
         If Type("M->EEB_FORNEC") <> "U" .and. Type("M->EEB_LOJAF") <> "U"
            M->EEB_FORNEC := SY5->Y5_FORNECE
            M->EEB_LOJAF  := SY5->Y5_LOJAF
         EndIf
   EndCase

End Sequence

RestOrd(aSaveOrd)

Return(xRet)


/*
Função      : DespNacERod
Objetivo    : Apresentar rodape com o total de despesas da empresa.
Retorno     : Nil
Autor       : Alexsander Martins dos Santos
Data e Hora : 19/11/2004 às 15:11.
*/

Static Function DespNacERod(oDlg)

Local aPosRod := PosDlg(oDlg)
Local lRet := .T. // TLM 20/02/2008


Begin Sequence    

   If EasyEntryPoint("EECAP103") // TLM 20/02/2008
      lRet:= ExecBlock("EECAP103",.F.,.F.,"PE_RODAPE_ADIAN")
   EndIf   

   If ValType(lRet) <> "L"  // TLM 20/02/2008
      lRet := .T.
   EndIf

   If !lRet  // TLM 20/02/2008
      Break
   EndIf
 
    
   //ASK 29/11/2007 - Acrescentado os totais: Total de Despesas Adiantadas/Total de Despesas Não Adiantadas/Saldo Adiantamento  
   //Total de Despesas
      @ 0, 0 To aPosRod[3], aPosRod[4] of oDlg Pixel //256
      @ 002, 007 Say oSayDesp Var STR0023 Size 120, 70 Of oDlg Pixel //"Total de Despesas" //265 //aPosRod[1]+87
      @ 002, 070 MSGet oTotDesp Var nTotDesp Picture AVSX3("EET_VALORR", AV_PICTURE) Size 058, 08 Pixel of oDlg When .F. //aPosRod[1]+86
   
      //Total de Despesas Adiantadas  
      @ 017, 007 Say oSayDespAd Var STR0036 Size 120, 70 Of oDlg Pixel //"Total de Despesas" //265 //aPosRod[1]+87//STR0036	"Total Desp. Adian."
      @ 017, 070 MSGet oTDespAd Var nTDespAd Picture AVSX3("EET_VALORR", AV_PICTURE) Size 058, 08 Pixel of oDlg When .F. //aPosRod[1]+86
      
      //Total de Despesas Não Adiantadas  
      @ 032, 007 Say oSayDeNoAd Var STR0037 Size 120, 70 Of oDlg Pixel //"Total de Despesas" //265 //aPosRod[1]+87 //STR0037	"Total Desp. Não Adian."
      @ 032, 070 MSGet oTDespNoAd Var nTDespNoAd Picture AVSX3("EET_VALORR", AV_PICTURE) Size 058, 08 Pixel of oDlg When .F. //aPosRod[1]+86
   
      //Saldo Adiantamento
      @ 047, 007 Say oSaySldAd Var STR0038 Size 120, 70 Of oDlg Pixel //"Total Adiantado" //STR0038	"Saldo Adiantamento"
      @ 047, 070 MSGet oSldAdian Var nSldAdian Picture AVSX3("EET_VALORR", AV_PICTURE) Size 058, 08 Pixel of oDlg When .F.
   
      //2ªColuna 
      //Total Adiantado
      @ 002, 243 Say oSayAdian Var STR0039 Size 120, 70 Of oDlg Pixel //"Total Adiantado" //STR0039	"Total Adiantado"
      @ 002, 296 MSGet oTotAdian Var nTotAdian Picture AVSX3("EET_VALORR", AV_PICTURE) Size 058, 08 Pixel of oDlg When .F.

      //Será exibido apenas quando selecionado um item do tipo adiantamento
      @ 002, 007 Say oSayAdia_i Var STR0039 Size 120, 70 Of oDlg Pixel //"Total Adiantado" //STR0039	"Total Adiantado"
      @ 002, 070 MSGet oTotAdia_i Var nTotAdian Picture AVSX3("EET_VALORR", AV_PICTURE) Size 058, 08 Pixel of oDlg When .F.
   
      //Total Devolvido
      @ 017, 243 Say oSayDevol Var STR0040 Size 120, 70 Of oDlg Pixel //"Total Devolvido" //STR0040	"Total Devolvido"
      @ 017, 296 MSGet oTotDevol Var nTotDevol Picture AVSX3("EET_VALORR", AV_PICTURE) Size 058, 08 Pixel of oDlg When .F.
   
      //Total Complemento
      @ 032, 243 Say oSayCompl Var STR0041 Size 120, 70 Of oDlg Pixel //Total Complemento //STR0041	"Total Complemento" 
      @ 032, 296 MSGet oTotCompl Var nTotCompl Picture AVSX3("EET_VALORR", AV_PICTURE) Size 058, 08 Pixel of oDlg When .F.

End Sequence

Return(Nil)


/*
Função      : DespNacTot
Objetivo    : Totalizar o valor das despesas.
Retorno     : Total da despesas.
Autor       : Alexsander Martins dos Santos
Data e Hora : 23/11/2004 às 15:25.
Revisão     : ER - 15/12/2006
Objetivo    : Tratamento para adiantemanto a Despachante. 
              Quando existir adiantamento a Despachante, as despesas pagas pelo Despachante terão 
              seu valor abatido do adiantamento para Cálculo do Total.  
*/
*--------------------------*
Static Function DespNacTot()
*--------------------------*
//Local nTotal := 0
Local aOrd   :=SaveOrd({"WorkDe"})

Local nRec   := 0
//Local lAdian := .F.
//Local lCompl := .F.
//Local lDevol := .F.

Local cChave := ""

//ASK 06/12/2007 - Alterada as variaveis de Local para Private
Private nTotal := 0
Private nValAdian := 0
Private nValCompl := 0
Private nValDevol := 0

Private nValAd := 0
Private nVAlNoAd := 0
Private nVlSldAd  := 0
       

//Local nValDesp  := 0
//Local nDespesa  := 0

//Local dAdian    := AVCTOD("  /  /  ")

Begin Sequence
   
   //Cria a chave para busca de Parcelas de Adiantamento ao Despachante.
   If cOrigem == OC_PE
      cChave := M->EE7_PEDIDO // + "901"
   Else
      cChave := M->EEC_PREEMB // + "901"
   EndIf
   
   nRec := WorkDe->(RecNo())
   
   //Verifica se existe alguma parcela de Adiantamento ao Despachante.
   // ***ASK 29/11/2007 Novo tratamento de totais de adiantamento 
   WorkDe->(DbSetOrder(1))
   If WorkDe->(DbSeek(cChave))
      While WorkDe->(!EOF())   
         If LEFT(WorkDe->EET_DESPES,1)#"9"
            nTotal += WorkDe->EET_VALORR      //Total Geral das despesas (Exceto despesa 901 / 902 / 903)
            If WorkDe->EET_BASEAD $ cSim .And. Left(WorkDe->EET_PAGOPO,1) == "1"
               nValAd += WorkDe->EET_VALORR   //Total das despesas Adiantado = Sim
            Else 
               nValNoAd += WorkDe->EET_VALORR //Total das despesas Adiantado = Não  
            EndIf
         ElseIf WorkDe->EET_DESPES == "901"
            nValAdian += WorkDe->EET_VALORR  //Total dos Adiantamentos - Despesa 901
         ElseIf WorkDe->EET_DESPES == "902"
            nValCompl += WorkDe->EET_VALORR  //Total de Complemento - Despesa 902
         ElseIf WorkDe->EET_DESPES == "903"
            nValDevol += WorkDe->EET_VALORR  //Total de Devoluções - Despesa 903
         EndIf
         WorkDe->(DbSkip())
      EndDo
   EndIf
                          
   nVlSldAd := nValAdian + nValCompl - (nValDevol + nValAd) // 901 + 902 - (903 + Despesas BASEAD = Sim)

   If EasyEntryPoint("EECAP103")  //ASK 06/12/2007 
      ExecBlock("EECAP103",.F.,.F.,"POS_TOTAIS")
   EndIf

   //***
   
   /*   lAdian    := .T.
      While WorkDe->(!EOF())
         
         If WorkDe->EET_DESPES == "901"
            //Recebe a menor Data de Adiantamento
            If Empty(dAdian) .or. WorkDe->EET_DESADI < dAdian
               dAdian := WorkDe->EET_DESADI
            EndIf
         EndIf
      
         WorkDe->(DbSkip())
      EndDo
   EndIf

   //Cria a chave para busca de Parcelas de Complemento ao Despachante.
   If cOrigem == OC_PE
      cChave := M->EE7_PEDIDO+"902"
   Else
      cChave := M->EEC_PREEMB+"902"   
   EndIf
   
   nRec := WorkDe->(RecNo())
   
   //Verifica se existe alguma parcela de Complemento ao Despachante.
   WorkDe->(DbSetOrder(1))
   If WorkDe->(DbSeek(cChave))
      lCompl    := .T.
   EndIf

   //Cria a chave para busca de Parcelas de Devolução ao Despachante.
   If cOrigem == OC_PE
      cChave := M->EE7_PEDIDO+"903"
   Else
      cChave := M->EEC_PREEMB+"903"   
   EndIf
   
   nRec := WorkDe->(RecNo())
   
   //Verifica se existe alguma parcela de Devolução ao Despachante.
   WorkDe->(DbSetOrder(1))
   If WorkDe->(DbSeek(cChave))
      lDevol    := .T.
   EndIf
   
   If lAdian .or. lCompl .or. lDevol
   
      WorkDe->(DbGoTop())
      While WorkDe->(!EOF())
         
         //Adiantamento a Despachante
         If WorkDe->EET_DESPES == "901"
            nValAdian += WorkDe->EET_VALORR
     
         //Despesa paga pelo Despachante
         ElseIf Left(WorkDe->EET_PAGOPO,1) == "1" .And. WorkDe->EET_DESADI >= dAdian
            nValDesp  += WorkDe->EET_VALORR
         
         //Outras Despesas
         Else
            nDespesa  += WorkDe->EET_VALORR
         EndIf
         
         //Complemento ao Despachante
         If WorkDe->EET_DESPES == "902"
            nValCompl += WorkDe->EET_VALORR
         
         //Devolução ao Despachante
         ElseIf WorkDe->EET_DESPES == "903"
            nValDevol += WorkDe->EET_VALORR
         
         EndIf
   
         WorkDe->(DbSkip())
      EndDo
      
    //  If nValAdian >= nValDesp
    //     nTotal := nDespesa
    //  Else
    //     nTotal := (nValDesp - nValAdian) + nDespesa
    //  EndIf
   
   Else
   
      //WorkDe->(dbEval({|| nTotal += EET_VALORR}))   
   
   EndIf*/
   
   WorkDe->(DbGoTo(nRec))
   
   nTotDesp := nTotal   
   oTotDesp:Refresh()
    
   nTDespAd := nValAd  
   oTDespAd:Refresh() 
                        
   nTDespNoAd := nValNoAd
   oTDespNoAd:Refresh()
   
   nSldAdian := nVlSldAd 
   oSldAdian:Refresh()
   
   nTotAdian := nValAdian
   oTotAdian:Refresh()
   oTotAdia_i:Refresh()
   
   nTotDevol := nValDevol
   oTotDevol:Refresh()

   nTotCompl := nValCompl
   oTotCompl:Refresh()

End Sequence

RestOrd(aOrd,.t.)

Return(nTotal)


/*
AMS - 25/11/2004 às 18:18. A função IsFilial() foi removida do programa EECAP105 por motivo de estouro de define.

JPP - 24/02/2005 às 13:30 Devido a problemas de compilação, a função IsFilial2() passou a possuir as definições
      da antiga função IsFilial() e é chamada pela nova função IsFilial() definida no programa EECAP105.PRW.
*/

/*
Funcao      : IsFilial2(cRotina)
Parametros  : cRotina - Indica a rotina utilizada e verifica as validações 
                        necessárias a serem executadas.
Retorno     : .t./.f.
Objetivos   : Validar os códigos de filiais informados contra os códigos válidos 
              no sigamat.emp.
Autor       : Jeferson Barros Jr.
Data/Hora   : 06/11/2002 15:29.
Revisao     :
Obs.        :
*/

*------------------------*
Function IsFilial2(cRotina)
*------------------------*
Local aOrd := SaveOrd({"SM0"}), aFils:={}
Local cEmpresa, cDesc
Local nRec, j:=0 
Local lRet := .t.

Default cRotina := "OFFSHORE"

Begin Sequence

   SM0->(DbSetOrder(1))

   cEmpresa := SM0->M0_CODIGO // Empresa Atual.
   cDesc    := SM0->M0_NOME   
   nRec     := SM0->(RecNo())

   cRotina  := AllTrim(Upper(cRotina))

   Do Case
      Case cRotina == "OFFSHORE" // Validações para a rotina de Off-Shore.

         aFils := {{"MV_AVG0023",AllTrim(EasyGParam("MV_AVG0023"))},;
                   {"MV_AVG0024",AllTrim(EasyGParam("MV_AVG0024"))}}

         For j:=1 To Len(aFils)
            If !SM0->(DbSeek(cEmpresa+aFils[j][2]))
                  If IsMemVar("lEE7Auto") .AND. !lEE7Auto //WHRS TE-7768 540063/ MTRADE-1723 - Exibição de MsgInfo na execução da rotina automática
                        MsgInfo(STR0024+Replic(ENTER,2)+; //"A rotina de off-shore não será poderá ser habilitada."
                              STR0025+AllTrim(aFils[j][2])+STR0026+AllTrim(aFils[j][1])+STR0027+ENTER+; //"A filial '"###"' informada no parâmetro '"###"' não"
                              STR0028+cEmpresa+"-"+AllTrim(cDesc)+"'."+Replic(ENTER,2)+; //"existe para a empresa '"
                              STR0029+AllTrim(aFils[j][1])+"'.",STR0014) //"Revise o conteúdo do parâmetro '"###"Atenção"
                  EndIf
               lRet:=.f.
               Break
            EndIf
         Next

   End Case
End Sequence

RestOrd(aOrd)

SM0->(DbGoTo(nRec))

Return lRet


/*
Função      : AVCapital
Objetivo    : Tratamentos especiais para siglas e letras depois do ponto.
Parametro   : cString = String a ser tratada.
Autor       : Alexsander Martins dos Santos
Data e Hora : 26/11/2004 às 16:51.
*/

Static Function AVCapital(cString)

Local nPos       := 0
Local cStringNew := ""
Local lUpper     := .F.

Begin Sequence

   If Len(RTrim(cString)) < 5
      Break
   EndIf

   cString := Capital(cString)

   If At(".", cString) <> 0

      For nPos := 1 To Len(RTrim(cString))

         If lUpper
            cStringNew += Upper(SubStr(cString, nPos, 1))
         Else
            cStringNew += SubStr(cString, nPos, 1)
         EndIf

         If SubStr(cString, nPos, 1) = "."
            lUpper := .T.
         Else
            lUpper := .F.
         EndIf

      Next

      cString := cStringNew

   EndIf

End Sequence

Return(cString)  

/*
Função      : AP100Normas(cPais,cFase,cCampo)
Objetivo    : Na alteração do país de entrega, alterar as normas vinculadas aos itens, de acordo com o pais de entrega e
              dar mensagem ao final avisando.
Parametro   : cPais = País de entrega.
              cFase = "P" - indica fase de pedido
              cFase = "Q" - indica fase de embarque  
              cCampo = Nome do campo em que o gatilho foi disparado
Retorno     : O conteúdo da variável de memoria alterada.
Autor       : Julio de Paula Paz
Data e Hora : 10/01/04 - 15:00  
Revisão     : JPP - 04/04/2005 - 13:00
*/
Function AP100Normas(cPais,cFase,cCampo)
Local lRet := Space(3), nReg, lMsg := .f. 

Begin Sequence

Do Case
   Case cFase == OC_PE // Fase de Pedido
        If ! IsVazio("WORKIT")
           nReg := WORKIT->(Recno())
           WORKIT->(DbGotop())
           Do While ! WORKIT->(Eof()) 
              If EXN->(DbSeek(xFilial("EXN")+WORKIT->EE8_COD_I+cPais))
                 WORKIT->EE8_CODNOR := EXN->EXN_NORMA
                 lMsg := .t.
              Else
                 WORKIT->EE8_CODNOR := Space(3) 
                 lMsg := .t.
              EndIf
              WORKIT->(DbSkip())
           EndDo
           WORKIT->(DbGoto(nReg))
        EndIf
        If cCampo = "EE7_PAISET"
           lRet := M->EE7_PAISET // CAMPO PADRÃO
        Else
           lRet := M->EE7_PAISDT // CAMPO CUSTOMIZADO
        EndIf   
   Case cFase == OC_EM // Fase de Embarque
        nReg := WORKIP->(Recno())
        WORKIP->(DbGotop())
        Do While ! WORKIP->(Eof())
           If ! Empty(WORKIP->WP_FLAG) 
              If EXN->(DbSeek(xFilial("EXN")+WORKIP->EE9_COD_I+cPais))
                 WORKIP->EE9_CODNOR := EXN->EXN_NORMA
                 lMsg := .t.   
              Else
                 WORKIP->EE9_CODNOR := Space(3)
                 lMsg := .t.
              EndIf
           EndIf   
           WORKIP->(DbSkip())
        EndDo
        WORKIP->(DbGoto(nReg))
        If cCampo = "EEC_PAISET"
           lRet := M->EEC_PAISET // CAMPO PADRÃO
        Else
           lRet := M->EEC_PAISDT // CAMPO CUSTOMIZADO.
        EndIf
End Case

If lMsg
   If cCampo = "EE7_PAISET" .Or. cCampo = "EEC_PAISET"
      MsgInfo(STR0033,STR0014) //"Devido a alteração no Pais de Entrega, As normas vinculadas aos produtos foram alteradas." ## "Atenção"
   Else
      MsgInfo(STR0034,STR0014)  // "Devido a alteração no Pais de Destino, As normas vinculadas aos produtos foram alteradas." ## "Atenção"
   EndIf
EndIf   

End Sequence

Return(lRet)

*----------------------------*
Static Function AP103SEQEET()
*----------------------------*
Local cSeq := "" , cSeqWorkDe := ""
Local nRecWorkDe := WorkDe->(Recno())

WorkDe->(DbSetOrder(3))//EET_PEDIDO+EET_SEQ

If WorkDe->( AvSeekLast(AvKey(M->EET_PEDIDO,"EET_PEDIDO")))
   cSeqWorkDe := WorkDe->EET_SEQ		
EndIf
If !Empty(cSeqWorkDe)   

   cSeq := SomaIt(cSeqWorkDe) 
   
Else

   cSeq := StrZero(1,AVSX3("EET_SEQ",AV_TAMANHO))

EndIf

WorkDe->(DbGoTo(nRecWorkDe))

Return cSeq

