#Include "EEC.CH"
#Include "EECAE110.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FWBROWSE.CH"
#Include "TOPCONN.CH"
#Include "AVERAGE.CH"
#Include "TOTVS.CH"

#Define BASE          "0"
#Define CONTAINER     "1"
#Define LOTE          "2"
#Define EMBALAGEM     "3"
#Define PRODUTO       "4"
#Define PRE_CONTAINER "5"

#Define SOMAR    1
#Define SUBTRAIR 2

/*
Função      : AE110ESTUF
Parametros  : Nenhum.
Retorno     : lOk - Indica o status da manutenção.
Objetivos   : Interface principal da manutenção de estufagem de mercadorias.
Autor       : Rodrigo Mendes Diaz
Revisão     : WFS - 13/01/10: inclusão do botão "Reiniciar", que permitirá
              desestufar os itens e reezibí-los como apresentado inicialmente.
Data/Hora   : 20/08/07
*/
*-------------------*
Function AE110ESTUF()
*-------------------*
//Estrutura inicial do tree passada para os objetos
Local aTreeNE, aTreeES

//Definições da Dialog
Local cDlgTit := StrTran(STR0027, "###", AllTrim(EEC->EEC_PREEMB)) //STR0027	"Estufagem de Mercadorias - Embarque '###'"
Local bOk := {|| lOk := .T., oDlg:End() }
Local bCancel := {|| oDlg:End() }

Local nInc

//Controle de ação do usuário quanto à manutenção (finalizada ou cancelada)
Local lOk := .F.

//Fontes utilizadas na interface
Local oFont1 := TFont():New("ARIAL",,23,, .T.)//Fonte do título do tree
Local oFont2 := TFont():New("ARIAL",,18,, .T.)//Fonte do título do memo

//Rotina de reinicialização da estufagem
Local bReiniciar:= {|| ReiniciarEstufagem(), AE110ESTUF()}

Local aOrdEEA := SaveOrd({"EEA"})

Local bSetKey25 := SetKey(25)     //AAF/NCF - 13/09/2013 - Ajustes de melhoria e otimização da rotina de Estufagem
Local bSetKey26 := SetKey(26)

Private lReinicializar:= .F.
//Variável para permitir que a execução seja cancelada via ponto de entrada.
Private lAbort := .F.

Private oDlg, aPos, aPosNE, aPosES, nTamMemo := 84//51                        //NCF - 24/09/2013 - Implementação de melhoria para permitir quebra de itens não estufados por estrutura de produto
Private oFontMemo
Private nRecnoNE := 0, nRecnoES := 0
//Objeto dos trees e seus respectivos objetos de descrição (memo)
Private oTreeNE, oTreeES, oMemoNE, oMemoES, oSize, oGet1, oGet2

//Indica o tree ativo (foco da tela)
Private cActiveTree := "NE"

//Identificador sequencial das folhas do objeto tree, cada folha possui um código próprio e único dentro do processo
Private nId := 10

//Guarda as informações de origem e destino
Private aMovDe := {}, aMovPara := {}

//Indica o nodo raiz dos objetos Tree
Private cZero := StrZero(0, AvSx3("EYH_ID", AV_TAMANHO))
Private cZeroCont := StrZero(1, AvSx3("EYH_ID", AV_TAMANHO))
Private cZeroPreC := StrZero(2, AvSx3("EYH_ID", AV_TAMANHO))

Private cPictPeso := If(Empty(AvSx3("EYH_PSLQUN", AV_PICTURE)), AvSx3("EE9_PSLQUN", AV_PICTURE), AvSx3("EYH_PSLQUN", AV_PICTURE))

//*** Opções de customização da rotina
Private cDesPreCon := If(EECFlags("PRE-CONTAINER"), EasyGParam("MV_AVG0157",, STR0028), "")//STR0028	"Pré-Container"

//AAF 02/07/2013 - Novos parametros para uso da rotina de estufagem, configuravel por usuário
Private oUserParams	 := EASYUSERCFG():New("EECAE110")

Private lDoubleClick := oUserParams:LoadParam("DOUBLE_CLICK",  .T.)
Private lTelaQuantidade := oUserParams:LoadParam("TELA_QUANTIDADE", .T.)
Private lGroupEmbs := oUserParams:LoadParam("GROUP_EMBS", EasyGParam("MV_AVG0172",, .T.))

Private aOperacoes := {}
Private nOperaPos  := 0
//***

//Alias das tabelas utilizadas, works e arquivos de memória criados
Private cAlias := "EYH", cWorkNE := "WK_NE", cWorkES := "WK_ES", cWorkEX9 := "WK_EX9"
//Guarda informações dos arquivos temporários Cada dimensão possui: {"Alias do arquivo temporário", "Alias base", "Nome do arquivo físico criado"}
Private aFiles := {{cWorkNE, "EYH", Nil}, {cWorkES, "EYH", Nil}, {cWorkEX9, "EX9", Nil}}
Private aDeletados := {}

//Texto do rodapé dos objetos tree, alterados conforme o item selecionado
Private cMemoNE := STR0029, cMemoES := STR0030 //STR0029	"Itens não Estufados" //STR0030	"Itens Estufados"

Private aMemosEX9 := {{"EX9_OBS","EX9_VM_OBS"}}

Private cUnPes := If(Empty(EEC->EEC_UNIDAD), "KG", EEC->EEC_UNIDAD)

Private nOpc := INCLUIR

// BAK - Tratamento para inclusão de nova embalagens na estufagem - 15/02/2013
// aEmbIncl - {Codigo da Embalagem, Id, Id Vinculado, Peso Liquido, Quantidade}
Private aEmbIncl := {}

//NCF - 15/04/2011 - Inclusão da opção do Packing List Mod. 4
EEA->(DBSETORDER(1))  //DOCUMENTO + TIPO + IDIOMA
IF !EEA->(DBSEEK(  xFilial("EEA" )+AvKey("A-140","EEA_COD")+AvKey("2-Documento","EEA_TIPDOC")+AvKey("INGLES-INGLES","EEA_IDIOMA") ))
   EEA->(RecLock("EEA",.T.))
   EEA->EEA_FILIAL := xFilial("EEA")
   EEA->EEA_COD    := "A-140"
   EEA->EEA_FASE   := "3"
   EEA->EEA_TIPDOC := "2-Documento"
   EEA->EEA_TITULO := "PACKING LIST (MODELO 4)"
   EEA->EEA_CLADOC := "3-Packing List"
   EEA->EEA_IDIOMA := "INGLES-INGLES"
   EEA->EEA_ARQUIV := "PEM76.RPT"
   EEA->EEA_RDMAKE := 'EXECBLOCK("EECPEM76",.F.,.F.)'
   EEA->(MsUnlock())
ENDIF
RestOrd(aOrdEEA,.T.)

Begin Sequence

   //Só permite visualizar a estufagem quando o processo de embarque estiver cancelado
   If EEC->EEC_STATUS == ST_PC
      nOpc := VISUALIZAR
   EndIf

   If EECFlags("INTTRA")
      aAdd(aMemosEX9, {"EX9_CSICOM", "EX9_SICOM" })
      aAdd(aMemosEX9, {"EX9_CSIRIN", "EX9_SIRINS"})
      aAdd(aMemosEX9, {"EX9_CBLCL1", "EX9_BLCLM1"})
      aAdd(aMemosEX9, {"EX9_CBLCL2", "EX9_BLCLM2"})
      aAdd(aMemosEX9, {"EX9_CBLCL3", "EX9_BLCLM3"})
      aAdd(aMemosEX9, {"EX9_CCOTEM", "EX9_COMTEM"})
   EndIf

   //Cria os arquivos de trabalho utilizando a função CriaFiles
   For nInc := 1 To Len(aFiles)
      If Select(aFiles[nInc][1]) == 0
         aFiles[nInc][3] := CriaWork(aFiles[nInc][2],, aFiles[nInc][1])
      Else
         (aFiles[nInc][1])->(AvZap())
      EndIf
   Next

   //Obtém os itens não estufados alimentando a work cWorkNE
   Ae110GetEstuf("NE")
   //Gera o array de definição de estrutura para o tree de itens não estufados
   aTreeNE := Ae110GerTree("NE")

   //Alimenta a work cWorkES com os containers já existentes na base de dados para o processo atual
   Ae110GetConts()
   //Obtém os itens estufados alimentando a work cWorkES
   Ae110GetEstuf("ES")

   //Gera o array de definição de estrutura para o tree de itens estufados
   aTreeES := Ae110GerTree("ES")

   If EasyEntryPoint("EECAE110")
      ExecBlock("EECAE110", .F., .F., "ESTUFAGEM_ANTES_DIALOG")
   EndIf

   //Caso o ponto de entrada determine que a rotina não será executada
   If lAbort
      lOk := .F.
      Break
   EndIf

   Ae110AtuPeso(cWorkNe,, cZero)
   Ae110AtuPeso(cWorkEs,, cZeroCont)
   If EECFlags("PRE-CONTAINER")
      Ae110AtuPeso(cWorkEs,, cZeroPreC)
   EndIf

  oSize:= FWDefSize():New(.T.)
  oSize:lLateral := .T.
  oSize:AddObject( "tre1" , 100, 100, .T., .T. )
  oSize:AddObject( "tre2" , 100, 100, .T., .T. )
  oSize:Process()

   DEFINE MSDIALOG oDlg TITLE cDlgTit FROM oSize:aWindSize[2], oSize:aWindSize[1] ; //DLG_LIN_INI, DLG_COL_INI;
                                        TO oSize:aWindSize[3], oSize:aWindSize[4] ; // DLG_LIN_FIM, DLG_COL_FIM;
                                        OF oMainWnd PIXEL
      oDlg:lMaximized := .T.
      oPanel:= TPanel():New(0, 0, "", oDLG,, .F., .F.,,, 90, 165) //MCF - 14/09/2015
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      /// lado 1
      aPos := { 3 , 3 , oSize:GetDimension("tre1","COLEND") }  //{1,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2}//PosDlg(oDlg)
      //@ aPos[1], aPos[2] Get oGet1 Var STR0031 MEMO SIZE aPos[3], 17 READONLY FONT oFont1 Of oPanel Pixel //STR0031	"Mercadorias não estufadas"
        @ aPos[1], aPos[2] Say STR0031 FONT oFont1 Of oPanel Pixel //STR0031 "Mercadorias não estufadas"

      aPosNE := { 21 , 3 , oSize:GetDimension("tre1","YSIZE") - (nTamMemo+16) , oSize:GetDimension("tre1","COLEND") + 3 }
      oTreeNE := AvTree(aTreeNE, aPosNE, MenuTree(), oPanel,)

      aPos := { oSize:GetDimension("tre1","YSIZE") - (nTamMemo+15) , 3 , oSize:GetDimension("tre1","COLEND") }
      //@ aPos[1], aPos[2] Get STR0033 MEMO SIZE aPos[3] , 14 READONLY FONT oFont2 Of oPanel Pixel//STR0033	"Informações"
        @ aPos[1], aPos[2] Say STR0033 FONT oFont1 Of oPanel Pixel //STR0033 "Informações"      

      aPos := { oSize:GetDimension("tre1","YSIZE") - (nTamMemo) , 3 , oSize:GetDimension("tre1","COLEND") }
      @ aPos[1], aPos[2] Get oMemoNE Var cMemoNE MEMO SIZE aPos[3], nTamMemo READONLY FONT oFontMemo Of oPanel Pixel

      /// lado 2
      aPos := { 3 , oSize:GetDimension("tre2","COLINI") , oSize:GetDimension("tre1","COLEND") }
      //@ aPos[1], aPos[2] Get oGet2 Var STR0032 MEMO SIZE aPos[3], 17 READONLY FONT oFont1 Of oPanel Pixel//STR0032	"Mercadorias estufadas"
        @ aPos[1], aPos[2] Say STR0032 FONT oFont1 Of oPanel Pixel //STR0032 "Mercadorias estufadas"
        

      aPosES := { 21 , oSize:GetDimension("tre2","COLINI") + 1 , oSize:GetDimension("tre2","YSIZE") - (nTamMemo+16) , oSize:GetDimension("tre2","COLEND") + 3 }
      oTreeES := AvTree(aTreeES, aPosES, MenuTree(), oPanel,)

      aPos := { oSize:GetDimension("tre2","YSIZE") - (nTamMemo+15) , oSize:GetDimension("tre2","COLINI") , oSize:GetDimension("tre1","COLEND") }
      //@ aPos[1], aPos[2] Get STR0033 MEMO SIZE aPos[3], 14 READONLY FONT oFont2 Of oPanel Pixel//STR0033	"Informações"
        @ aPos[1], aPos[2] Say STR0033 FONT oFont1 Of oPanel Pixel //STR0033	"Informações"

      aPos := { oSize:GetDimension("tre2","YSIZE") - (nTamMemo) , oSize:GetDimension("tre2","COLINI") , oSize:GetDimension("tre1","COLEND") }
      @ aPos[1], aPos[2] Get oMemoES Var cMemoES MEMO SIZE aPos[3], nTamMemo READONLY FONT oFontMemo Of oPanel Pixel

      //Busca todas as folhas do tree para abrir todos os galhos
      aEval(aTreeNE, {|x| oTreeNE:TreeSeek(x[3]) })
      aEval(aTreeES, {|x| oTreeES:TreeSeek(x[3]) })

      //Posiciona na raiz do tree
      oTreeNE:TreeSeek(cZero)
      oTreeES:TreeSeek(cZero)

      //Sempre que algum tree receber o foco da tela ou uma folha diferente for clicada, atualiza as informações
      oTreeNE:bChange := {|| Ae110CTree("NE", If( Empty(oTreeNE:GetCargo()),cZero,oTreeNE:GetCargo() ), @cMemoNE) }     //NCF - 26/07/2013 - Verifica se o GetCargo não retorna vazio após rodar a função DelItem
      oTreeNE:bGotFocus := {|| Ae110CTree("NE", If( Empty(oTreeNE:GetCargo()),cZero,oTreeNE:GetCargo() ), @cMemoNE) }
      oTreeES:bChange := {|| Ae110CTree("ES",If( Empty(oTreeES:GetCargo()),cZero,oTreeES:GetCargo() ), @cMemoES) }
      oTreeES:bGotFocus := {|| Ae110CTree("ES", If( Empty(oTreeES:GetCargo()),cZero,oTreeES:GetCargo() ), @cMemoES) }

      oTreeNE:blDblClick := {|| DuplClick(oTreeNE, oTreeES) }
      oTreeES:blDblClick := {|| DuplClick(oTreeES, oTreeNE) }

      //***
      MENU oMenu POPUP
         MENUITEM "INCLUIR" Action Ae110Edit(INCLUIR)
      ENDMENU

      //oMenu:aItems[k]:bAction:= aMenuPopUp[k][2]

      oTreeNE:bRClicked := { |o,nx,ny| oMenu:Activate(nX/2,nY/2,o)}
      oTreeES:bRClicked := { |o,nx,ny| oMenu:Activate(nX/2,nY/2,o)}
      //***

      SetKey (25,{|| Ae110Desfaz(.T.) })
      SetKey (26,{|| Ae110Desfaz() })

      oTreeNE:SetFocus()

   ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg, bOk, bCancel,, RetButtons())

   If lOk .And. nOpc <> VISUALIZAR
      Begin Transaction

         Processa({|| lOk := Ae110GrvEstuf() }, STR0034, STR0035)//STR0034	"Aguarde" //STR0035	"Efetuando gravação da estufagem"

      End Transaction
   EndIf

End Sequence

   Processa({|| ProcRegua(Len(aFiles)),;
                aEval(aFiles, {|x| (x[1])->(DbCloseArea()),;
                                   aEval(x[3], {|y| FErase(y+TEOrdBagExt()) }),;
                                   IncProc() })},;
            STR0034,; //STR0034	"Aguarde"
            STR0036)//STR0036	"Eliminando arquivos temporários"

   //Reinicialização da operação de estufagem
   If lReinicializar
      Eval(bReiniciar)
   EndIf

SetKey(25,bSetKey25)
SetKey(26,bSetKey26)

Return lOk

/*
Função      : RetButtons()
Parametros  : Nenhum.
Retorno     : Array de botões para enchoicebar.
Objetivos   : Define os botões exibidos na enchoicebar da manutenção principal.
Autor       : Rodrigo Mendes Diaz
Revisão     : WFS - 13/01/10: inclusão do botão "Reiniciar", que permitirá
              desestufar os itens e reezibí-los como apresentado inicialmente.
Data/Hora   : 20/08/07
*/
Static Function RetButtons()
Local bMsg:= {|| MsgYesNo(STR0037 +; //STR0037	"Esta ação irá reiniciar toda a operação de estufagem para este processo e NÃO poderá"
                          STR0038, STR0039)} //STR0038	" ser revertida. Deseja prosseguir?" //STR0039 "Reiniciar a Estufagem"
Private aButtons := {}

   If (nOpc == ALTERAR) .Or. (nOpc == INCLUIR)
      //*** Opções para mover embalagens
      aAdd(aButtons, {"AVG_EMBFRM", {|| Ae110MovDe() }, STR0040, STR0040})//STR0040	"Mover De"
      aAdd(aButtons, {"AVG_EMBTO", {|| Ae110MovPara() }, STR0041, STR0041}) //STR0041	"Mover Para"
      aAdd(aButtons, {"", {|| Ae110Desfaz() }, "Desfazer (CTRL+Z)", "Desfazer (CTRL+Z)"}) //"Desfazer"
      aAdd(aButtons, {"", {|| Ae110Desfaz(.T.) }, "Refazer (CTRL+Y)", "Refazer (CTRL+Y)"}) //"Desfazer"
      //aAdd(aButtons, {"", {|| AltEmbalag() }, "Alterar Embalagens", "Alterar Embalagens"}) //"Desfazer"
      aAdd(aButtons, {"", {|| Ae110MovTodos() }, "Mover todos os itens", "Mover todos os itens"}) //"Desfazer"
      aAdd(aButtons, {"", {|| Ae110QbrEstru() }, "Quebrar item pela estrutura", "Quebrar item pela estrutura"}) //"Desfazer"
      //***

      //*** Opção para estufagem (inclusão de lotes ou containeres e carga automática via Wizard)
      aAdd(aButtons, {"MPWIZARD", {|| Ae110Wizard() }, "Wizard", "Wizard"})
      aAdd(aButtons, {"BMPINCLUIR",   {|| Ae110Edit(INCLUIR) }, STR0042, STR0042})//	STR0042	"Incluir"
      //***

      //*** Opções para alterar ou excluir o item selecionado no tree (Embalagem, Lote ou Container)
      aAdd(aButtons, {"EDIT",   {|| Ae110Edit(ALTERAR) }, STR0043, STR0043}) //	STR0043	"Alterar"
      aAdd(aButtons, {"EXCLUIR", {|| Ae110Edit(EXCLUIR) }, STR0044, STR0044}) //STR0044	"Excluir"
      //***

      //*** Opções de configuração da rotina
      If EasyGParam("MV_AVG0172", .T.)
         aAdd(aButtons, {"SelectAll", {|| AltPrefs() }, STR0045, STR0046}) //	STR0045	"Alterar Preferências" //STR0046	"Preferências"
      EndIf
      //***

      //WFS 13/01/2010
      //*** Opções para reiniciar a estufagem.
      AAdd(aButtons, {"Estomovi", {|| If (Eval(bMsg), (lReinicializar:= .T., oDlg:End()),)}, STR0039, STR0047}) //STR0039	"Reiniciar Estufagem" //STR0047	"Reiniciar"
      //***

   EndIf

   If EasyEntryPoint("EECAE110")
      ExecBlock("EECAE110", .F., .F., "RETBUTTONS")
   EndIf

Return aButtons

/*
Função      : MenuTree()
Parametros  : Nenhum.
Retorno     : aMenu - Array com definições de menu para AvTree.
Objetivos   : Definir opções do menu gerado pela função AvTree, com base nos botões da enchoicebar.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Static Function MenuTree()
Local aButtons := RetButtons()
Local aMenu    := {}
Local nInc

   For nInc := 1 To Len(aButtons)
      aAdd(aMenu, {aButtons[nInc][3], aButtons[nInc][2]})
   Next

Return Nil//aMenu RMD - Não monta o menu porque na build atual as coordenadas não estão sendo calculadas corretamente.

/*
Função      : Ae110GetEstuf(cOpc)
Parametros  : cOpc - Tipo de registro a ser buscado:
                        "NE" - Não estufados
                        "ES" - Estufados.
Retorno     : Nil
Objetivos   : Buscar as informações de estufagem já existentes na base de dados.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Function Ae110GetEstuf(cOpc)
Local cWork
Local i := 0
Local aChaves  := {}
Default cOpc := ""

   If cOpc == "NE"
      cWork := cWorkNE
      cCond := "N"
   ElseIf cOpc == "ES"
      cWork := cWorkES
      cCond := "S"
   EndIf

   If (cAlias)->(DbSeek(xFilial()+cCond+EEC->EEC_PREEMB))
      nOpc := ALTERAR
      //Caso a rotina já tenha sido concluída antes, busca os dados gravados na tabela EYH
      While (cAlias)->(!Eof() .And. EYH_FILIAL+EYH_ESTUF+EYH_PREEMB == xFilial("EYH")+cCond+EEC->EEC_PREEMB)
         (cWork)->(DbAppend())
         AvReplace(cAlias, cWork)
         If lMarcacao
            (cWork)->EYH_MARCAC := MSMM((cAlias)->EYH_CODMAR, AVSX3("EYH_MARCAC",3),,,LERMEMO) //BAK - 27 de Janeiro de 2011
         EndIf
         (cWork)->WK_RECNO   := (cAlias)->(Recno())
         (cAlias)->(DbSkip())
      EndDo
   ElseIf cOpc == "NE" .And. !(cAlias)->(DbSeek(xFilial()+"S"+EEC->EEC_PREEMB))
      //Caso contrário busca a relação de embalagens para cada item conforme gravado na tabela EEK e na capa do embarque

      //BAK - 19 de Janeiro de 2011
      //Tratamento para verificar quantas OIC existe em um determinado processo pra estufagem.
      aChaves := Ae110Agrup()
      EE9->(DbSetOrder(2))
      EE9->(DbSeek(xFilial()+EEC->EEC_PREEMB))
      While EE9->(EE9_FILIAL+EE9_PREEMB == xFilial()+EEC->EEC_PREEMB)
         nQtdEE9 := EE9->EE9_SLDINI
         //MFR OSSME-2738 10/10/201
         While nQtdEE9 > 0
            //Agrupamento da estufagem por OIC
            If (nPos := aScan(aChaves, {|x| x[3] == EE9->EE9_SEQEMB })) > 0
                       //  EY2_OIC     +    EY2_SAFRA   +   EY2_SEQEMB
               cOic := aChaves[nPos][1]+aChaves[nPos][2]+aChaves[nPos][3]
               nQtdOIC := aChaves[nPos][4]
               Ae110GetEmbs(nQtdOIC, cOIC)
               nQtdEE9 -= nQtdOIC
               aDel(aChaves, nPos)
               aSize(aChaves, Len(aChaves) - 1)
            Else
            //Agrupamento da estufagem por embalagem
               Ae110GetEmbs(nQtdEE9, "")
               nQtdEE9 := 0
            EndIf
         EndDo
         EE9->(DbSkip())
      EndDo
   EndIf

Return Nil

/*
Função      : Ae110Agrup()
Parametros  : Nenhum.
Retorno     : Array.
Objetivos   : Definir o agrupamento de cada tree da estufagem
Autor       : Bruno Akyo Kubagawa
Data/Hora   : 21/01/11
*/
Function Ae110Agrup()
Local aChaves := {}
Local aOrd := SaveOrd({"EY2","EXZ"}) // BAK - 3 de Fevereiro de 2011
Begin Sequence

   Do Case
      Case lQuebraOIC == .T.
         EXZ->(DbSetOrder(1))
         EXZ->(DbSeek(xFilial() + EEC->EEC_PREEMB))
         Do While EXZ->(!Eof()) .And. EXZ->(EXZ_FILIAL+EXZ_PREEMB == xFilial()+EEC->EEC_PREEMB)
            EY2->(DbSetOrder(1))
            EY2->(DbSeek(xFilial() + EEC->EEC_PREEMB + EXZ->EXZ_OIC))
            While EY2->(!Eof()) .And. xFilial("EEC") + EEC->EEC_PREEMB + EXZ->EXZ_OIC == EY2->(EY2_FILIAL+EY2_PREEMB+EY2_OIC)
               aAdd(aChaves, {EY2->EY2_OIC, EY2->EY2_SAFRA, EY2->EY2_SEQEMB, EY2->EY2_QTDE})
               EY2->(DbSkip())
            EndDo
            EXZ->(DbSkip())
         EndDo
         Break
   EndCase

End Sequence
RestOrd(aOrd) // BAK - 03 de Fevereiro de 2011

Return aChaves

/*
Função      : Ae110GetEmbs()
Parametros  : Nenhum.
Retorno     : Nenhum.
Objetivos   : Definir os relacionamentos das embalagens com base nos itens do embarque.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Function Ae110GetEmbs(nQtdItem,cChave)
Local bNewEmb    := {|| aBufferOld := aClone(aBufferAtu), aBufferAtu := {}, nBfOldPos := 1 }
Local bAddID     := {|x, y| aAdd(aBufferAtu, {x, y, 0})}
Local cEmbSup := "", nQtdSup := 1
Local lDivide := .F.
Local lCheck := (cWorkNE == "EYH")
Local aOrd := SaveOrd({"EY2","EXZ"}) // BAK - 3 de Fevereiro de 2011
Private aBufferAtu := {}, aBufferOld, nBfOldPos := 1

Default nQtdItem := EE9->EE9_QTDEM1
Default cChave := ""

Begin Sequence

   If !Empty(EEC->EEC_EMBAFI)
      nRelacao := 1
      nQtde    := 1
      Eval(bNewEmb)
      //MFR OSSME-2738 10/10/2019
      While nQtde > 0
         (cWorkNE)->(RecLock(cWorkNe, .T.))
         If cWorkNE == "EYH"
            EYH->EYH_FILIAL := xFilial("EYH")
         EndIf
         (cWorkNE)->EYH_PREEMB := EEC->EEC_PREEMB
         (cWorkNE)->EYH_ID     := Ae110NewId(lCheck, EEC->EEC_PREEMB)
         (cWorkNE)->EYH_IDVINC := GetIdSup()
         (cWorkNE)->EYH_CODEMB := EEC->EEC_EMBAFI
         (cWorkNE)->EYH_DESEMB := Posicione("EE5", 1, xFilial("EE5")+EEC->EEC_EMBAFI, "EE5_DESC")
         (cWorkNE)->EYH_EMBSUP := cEmbSup
         (cWorkNE)->EYH_RELSUP := nRelacao
         (cWorkNE)->EYH_ESTUF  := "N"
         (cWorkNE)->EYH_QTDEMB := If(lDivide, If(nQtde < nRelacao, nQtde, nRelacao), nQtde)
         (cWorkNE)->EYH_PSLQUN := BuscaPesEmb(EYH->EYH_CODEMB)

         If lQuebraOIC .Or. lMarcacao// BAK - 27 de Janeiro de 2011
            (cWorkNE)->EYH_CHAVE  := cChave
         EndIf

         If lMarcacao // BAK - 27 de Janeiro de 2011
            If Select("EY2") = 0 .Or. Select("EXZ") = 0
               DBSelectArea("EY2")
               DBSelectArea("EXZ")
            EndIf

            EY2->(DbSetOrder(1)) // EY2_FILIAL+EY2_PREEMB+EY2_OIC+EY2_SAFRA+EY2_SEQEMB
            EXZ->(DbSetOrder(1)) // EXZ_FILIAL+EXZ_PREEMB+EXZ_OIC+EXZ_SAFRA
            If EY2->(DbSeek(xFilial("EY2")+EEC->EEC_PREEMB + cChave)) .And. !Empty(EY2->EY2_CODMAR)
              (cWorkNE)->EYH_MARCAC := MSMM(EY2->EY2_CODMAR, AVSX3("EY2_MARCAC",AV_TAMANHO),,,LERMEMO)
            ElseIf EXZ->(DbSeek(xFilial("EXZ")+EEC->EEC_PREEMB + SubStr(cChave,1,AVSX3("EXZ_OIC",AV_TAMANHO)+AVSX3("EXZ_SAFRA",AV_TAMANHO)))) ;
                   .And. !Empty(EXZ->EXZ_CODMAR)
              (cWorkNE)->EYH_MARCAC := MSMM(EXZ->EXZ_CODMAR, AVSX3("EXZ_MARCAC",AV_TAMANHO),,,LERMEMO)
            Else
              (cWorkNE)->EYH_MARCAC := MSMM(EEC->EEC_CODMAR, AVSX3("EEC_MARCAC",AV_TAMANHO),,,LERMEMO)
            EndIf

         EndIf

         nQtde -= (cWorkNE)->EYH_QTDEMB
         Eval(bAddId, (cWorkNE)->EYH_ID, (cWorkNE)->EYH_QTDEMB)
         (cWorkNE)->(MsUnlock())
      EndDo
      cEmbSup := EEC->EEC_EMBAFI//EYH->EYH_CODEMB
      nQtdSup := (cWorkNE)->EYH_QTDEMB//Guarda a quantidade para usar como valor default caso não encontre relacionamento nas embalagens do nível inferior.
   EndIf

   //Inclui todas as embalagens do item gravadas na tabela EEK pela rotina de embarque
   EEK->(DbSetOrder(2))
   EEK->(AvSeekLast(xFilial("EEK")+OC_EM+EE9->(EE9_PREEMB+EE9_SEQEMB)))
   While EEK->(!Eof() .And. EEK_FILIAL+EEK_TIPO+EEK_PEDIDO+EEK_SEQUEN == xFilial("EEK")+OC_EM+EE9->(EE9_PREEMB+EE9_SEQEMB))
      nRelacao := GetRelacao(EEK->EEK_EMB, cEmbSup)
      nQtde    := EEK->EEK_QTDE
      If nRelacao == 0
         //nRelacao := Int(nQtde / nQtdSup)/*RMD - 17/10/08 - Se não encontrar a relação, utiliza a divisão entre a quantidade da linha e a quantidade da
         //                                              embalagem superior*/
         nRelacao := nQtde / nQtdSup // BAK - Retirado a chamada da função Int e alterado o campo EYH_RELSUP, colocando o escopo igual do EE9_QE - 20/02/2013
      EndIf
      Eval(bNewEmb)
      //MFR OSSME-2738 10/10/2019
      While nQtde > 0
         (cWorkNE)->(RecLock(cWorkNE, .T.))
         If cWorkNE == "EYH"
            EYH->EYH_FILIAL := xFilial("EYH")
         EndIf
         (cWorkNE)->EYH_PREEMB := EEC->EEC_PREEMB
         (cWorkNE)->EYH_ID     := Ae110NewId(lCheck, EEC->EEC_PREEMB)
         (cWorkNE)->EYH_IDVINC := GetIdSup()
         (cWorkNE)->EYH_CODEMB := EEK->EEK_EMB
         (cWorkNe)->EYH_DESEMB := Posicione("EE5", 1, xFilial("EE5")+EEK->EEK_EMB, "EE5_DESC")
         (cWorkNE)->EYH_EMBSUP := cEmbSup
         (cWorkNE)->EYH_RELSUP := nRelacao
         (cWorkNE)->EYH_ESTUF  := "N"
         (cWorkNE)->EYH_QTDEMB := If(lDivide, If(nQtde < nRelacao, nQtde, nRelacao), nQtde)
         (cWorkNE)->EYH_PSLQUN := BuscaPesEmb(EEK->EEK_EMB)

         If lQuebraOIC .Or. lMarcacao// BAK - 27 de Janeiro de 2011
            (cWorkNE)->EYH_CHAVE  := cChave
         EndIf

         If lMarcacao .And. (cWorkNE)->(FieldPos("EYH_MARCAC")) > 0// BAK - 27 de Janeiro de 2011
            If Select("EY2") = 0 .Or. Select("EXZ") = 0
               DBSelectArea("EY2")
               DBSelectArea("EXZ")
            EndIf
            EY2->(DbSetOrder(1)) // EY2_FILIAL+EY2_PREEMB+EY2_OIC+EY2_SAFRA+EY2_SEQEMB
            EXZ->(DbSetOrder(1)) // EXZ_FILIAL+EXZ_PREEMB+EXZ_OIC+EXZ_SAFRA
            If EY2->(DbSeek(xFilial("EY2")+EEC->EEC_PREEMB + cChave)) .And. !Empty(EY2->EY2_CODMAR)
              (cWorkNE)->EYH_MARCAC := MSMM(EY2->EY2_CODMAR, AVSX3("EY2_MARCAC",AV_TAMANHO),,,LERMEMO)
            ElseIf EXZ->(DbSeek(xFilial("EXZ")+EEC->EEC_PREEMB + SubStr(cChave,1,AVSX3("EXZ_OIC",AV_TAMANHO)+AVSX3("EXZ_SAFRA",AV_TAMANHO)))) ;
                   .And. !Empty(EXZ->EXZ_CODMAR)
              (cWorkNE)->EYH_MARCAC := MSMM(EXZ->EXZ_CODMAR, AVSX3("EXZ_MARCAC",AV_TAMANHO),,,LERMEMO)
            Else
              (cWorkNE)->EYH_MARCAC := MSMM(EEC->EEC_CODMAR, AVSX3("EEC_MARCAC",AV_TAMANHO),,,LERMEMO)
            EndIf
         EndIf

         nQtde -= (cWorkNE)->EYH_QTDEMB
         Eval(bAddId, (cWorkNE)->EYH_ID, (cWorkNE)->EYH_QTDEMB)
         (cWorkNE)->(MsUnlock())
      EndDo
      nQtdSup := (cWorkNE)->EYH_QTDEMB//Guarda a quantidade para usar como valor default caso não encontre relacionamento nas embalagens do nível inferior.
      cEmbSup := EEK->EEK_EMB
      EEK->(DbSkip(-1))
   EndDo

   //Inclui a embalagem imediatamente superior ao item (EE9_EMBAL1)
   nRelacao := GetRelacao(EE9->EE9_EMBAL1, cEmbSup)
   //MFR OSSME-2738 10/10/2019
   If (nQtdItem % EE9->EE9_QE) != 0
       nQtde := Int(nQtdItem / EE9->EE9_QE)+1
   Else
       nQtde := nQtdItem / EE9->EE9_QE
   Endif

   If nRelacao == 0
      //nRelacao := Int(nQtde / nQtdSup)/*RMD - 17/10/08 - Se não encontrar a relação, utiliza a divisão entre a quantidade da linha e a quantidade da
      //                                                   embalagem superior*/
      nRelacao := nQtde / nQtdSup // BAK - Retirado a chamada da função Int e alterado o campo EYH_RELSUP, colocando o escopo igual do EE9_QE - 20/02/2013
   EndIf

   Eval(bNewEmb)
   //MFR OSSME-2738 10/10/2019
   While nQtde > 0
      (cWorkNE)->(RecLock(cWorkNe, .T.))
      If cWorkNE == "EYH"
         EYH->EYH_FILIAL := xFilial("EYH")
      EndIf
      (cWorkNE)->EYH_PREEMB := EEC->EEC_PREEMB
      (cWorkNE)->EYH_ID     := Ae110NewId(lCheck, EEC->EEC_PREEMB)
      (cWorkNE)->EYH_IDVINC := GetIdSup()
      (cWorkNE)->EYH_CODEMB := EE9->EE9_EMBAL1
      (cWorkNe)->EYH_DESEMB := Posicione("EE5", 1, xFilial("EE5")+EE9->EE9_EMBAL1, "EE5_DESC")
      (cWorkNE)->EYH_EMBSUP := cEmbSup
      (cWorkNE)->EYH_RELSUP := nRelacao
      (cWorkNE)->EYH_ESTUF  := "N"
      (cWorkNE)->EYH_QTDEMB := If(lDivide, If(nQtde < nRelacao, nQtde, nRelacao), nQtde)
      (cWorkNE)->EYH_PSLQUN := BuscaPesEmb(EE9->EE9_EMBAL1)

      If lQuebraOIC .Or. lMarcacao // BAK - 27 de Janeiro de 2011
         (cWorkNE)->EYH_CHAVE  := cChave
      EndIf

      If lMarcacao .And. (cWorkNE)->(FieldPos("EYH_MARCAC")) > 0 // BAK - 27 de Janeiro de 2011
         If Select("EY2") = 0 .Or. Select("EXZ") = 0
            DBSelectArea("EY2")
            DBSelectArea("EXZ")
         EndIf

         EY2->(DbSetOrder(1)) // EY2_FILIAL+EY2_PREEMB+EY2_OIC+EY2_SAFRA+EY2_SEQEMB
         EXZ->(DbSetOrder(1)) // EXZ_FILIAL+EXZ_PREEMB+EXZ_OIC+EXZ_SAFRA
         If EY2->(DbSeek(xFilial("EY2")+EEC->EEC_PREEMB + cChave)) .And. !Empty(EY2->EY2_CODMAR)
           (cWorkNE)->EYH_MARCAC := MSMM(EY2->EY2_CODMAR, AVSX3("EY2_MARCAC",AV_TAMANHO),,,LERMEMO)
         ElseIf EXZ->(DbSeek(xFilial("EXZ")+EEC->EEC_PREEMB + SubStr(cChave,1,AVSX3("EXZ_OIC",AV_TAMANHO)+AVSX3("EXZ_SAFRA",AV_TAMANHO)))) ;
                .And. !Empty(EXZ->EXZ_CODMAR)
           (cWorkNE)->EYH_MARCAC := MSMM(EXZ->EXZ_CODMAR, AVSX3("EXZ_MARCAC",AV_TAMANHO),,,LERMEMO)
         Else
           (cWorkNE)->EYH_MARCAC := MSMM(EEC->EEC_CODMAR, AVSX3("EEC_MARCAC",AV_TAMANHO),,,LERMEMO)
         EndIf
      EndIf

      nQtde -= (cWorkNE)->EYH_QTDEMB
      Eval(bAddId, (cWorkNE)->EYH_ID, (cWorkNE)->EYH_QTDEMB)
      (cWorkNE)->(MsUnlock())
   EndDo

   //Inclui o próprio item
   nRelacao := EE9->EE9_QE
   nQtde    := nQtdItem//EE9->EE9_SLDINI
   Eval(bNewEmb)
   //MFR OSSME-2738 10/10/2019
   While nQtde > 0
      (cWorkNE)->(RecLock(cWorkNe, .T.))
      If cWorkNE == "EYH"
         EYH->EYH_FILIAL := xFilial("EYH")
      EndIf
      (cWorkNE)->EYH_PREEMB := EEC->EEC_PREEMB
      (cWorkNE)->EYH_ID     := Ae110NewId(lCheck, EEC->EEC_PREEMB)
      (cWorkNE)->EYH_IDVINC := GetIdSup()
      (cWorkNE)->EYH_CODEMB := EE9->EE9_COD_I
      (cWorkNe)->EYH_DESEMB := MSMM(EE9->EE9_DESC, 60,,,LERMEMO)
      (cWorkNE)->EYH_COD_I  := EE9->EE9_COD_I
      (cWorkNE)->EYH_SEQEMB := EE9->EE9_SEQEMB
      (cWorkNE)->EYH_EMBSUP := GetEmbSup(cWorkNE,(cWorkNE)->EYH_IDVINC)//cEmbSup
      (cWorkNE)->EYH_RELSUP := nRelacao
      (cWorkNE)->EYH_ESTUF  := "N"
      (cWorkNE)->EYH_QTDEMB := If(lDivide, If(nQtde < nRelacao, nQtde, nRelacao), nQtde)

      If lQuebraOIC .Or. lMarcacao // BAK - 27 de Janeiro de 2011
         (cWorkNE)->EYH_CHAVE  := cChave
      EndIf

      If lMarcacao .And. (cWorkNE)->(FieldPos("EYH_MARCAC")) > 0 // BAK - 27 de Janeiro de 2011
         If Select("EY2") = 0 .Or. Select("EXZ") = 0
            DBSelectArea("EY2")
            DBSelectArea("EXZ")
         EndIf

         EY2->(DbSetOrder(1)) // EY2_FILIAL+EY2_PREEMB+EY2_OIC+EY2_SAFRA+EY2_SEQEMB
         EXZ->(DbSetOrder(1)) // EXZ_FILIAL+EXZ_PREEMB+EXZ_OIC+EXZ_SAFRA
         If EY2->(DbSeek(xFilial("EY2")+EEC->EEC_PREEMB + cChave)) .And. !Empty(EY2->EY2_CODMAR)
           (cWorkNE)->EYH_MARCAC := MSMM(EY2->EY2_CODMAR, AVSX3("EY2_MARCAC",AV_TAMANHO),,,LERMEMO)
         ElseIf EXZ->(DbSeek(xFilial("EXZ")+EEC->EEC_PREEMB + SubStr(cChave,1,AVSX3("EXZ_OIC",AV_TAMANHO)+AVSX3("EXZ_SAFRA",AV_TAMANHO)))) ;
                .And. !Empty(EXZ->EXZ_CODMAR)
           (cWorkNE)->EYH_MARCAC := MSMM(EXZ->EXZ_CODMAR, AVSX3("EXZ_MARCAC",AV_TAMANHO),,,LERMEMO)
         Else
           (cWorkNE)->EYH_MARCAC := MSMM(EEC->EEC_CODMAR, AVSX3("EEC_MARCAC",AV_TAMANHO),,,LERMEMO)
         EndIf
      EndIf

      If Empty(EE9->EE9_UNPES)
         (cWorkNE)->EYH_PSLQUN := EE9->EE9_PSLQUN
      Else
         If Empty(EEC->EEC_UNIDAD) .Or. AvVldUn(EEC->EEC_UNIDAD) // MPG - 06/02/2018
            (cWorkNE)->EYH_PSLQUN := AvTransUnid(EE9->EE9_UNPES, "KG", EE9->EE9_COD_I, EE9->EE9_PSLQUN, .F.)
         Else
            (cWorkNE)->EYH_PSLQUN := AvTransUnid(EE9->EE9_UNPES, EEC->EEC_UNIDAD, EE9->EE9_COD_I, EE9->EE9_PSLQUN, .F.)
         EndIf
      EndIf
      nQtde -= (cWorkNE)->EYH_QTDEMB
      Eval(bAddId, (cWorkNE)->EYH_ID, (cWorkNE)->EYH_QTDEMB)
      (cWorkNE)->(MsUnlock())
   EndDo

   //*** RMD - Passa a recalcular os pesos sempre, antes da chamada da tela.
   //Atualiza os campos de peso bruto
   //Ae110AtuPeso(cWorkNE,, cZero)

RestOrd(aOrd) // BAK - 03 de Fevereiro de 2011

End Sequence

Return Nil

/*
Função      : GetIdSup()
Parametros  : Nennum.
Retorno     : cRet - Id da embalagem superior.
Objetivos   : Auxiliar a função Ae110GetEmbs, retornando o ID da embalagem superior à atual.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Static Function GetIdSup()
Local cRet := cZero

   If Len(aBufferOld) >= nBfOldPos
      If aBufferOld[nBfOldPos][3] >= aBufferOld[nBfOldPos][2]
         ++nBfOldPos
      EndIf
      If Len(aBufferOld) >= nBfOldPos .And. aBufferOld[nBfOldPos][3] <= aBufferOld[nBfOldPos][2]
         ++aBufferOld[nBfOldPos][3]
         cRet := aBufferOld[nBfOldPos][1]
      EndIf
   EndIf

Return cRet

/*
Função      : BuscaPesEmb(cEmb)
Parametros  : cEmb - Código da embalagem.
Retorno     : nPes - Peso da embalagem.
Objetivos   : Retornar o peso cadastrado para a embalagem.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Static Function BuscaPesEmb(cEmb)
Local nPes := 0

   EE5->(DbSetOrder(1))
   If EE5->(DbSeek(xFilial()+cEmb))
      If Empty(EEC->EEC_UNIDAD) .Or.  AvVldUn(EEC->EEC_UNIDAD) // MPG - 06/02/2018
         nPes := EE5->EE5_PESO
      Else
         nPes := AvTransUnid("KG",EEC->EEC_UNIDAD,, EE5->EE5_PESO, .F.)
      EndIf
   EndIf

Return nPes

/*
Função      : Ae110NewId(lCheck, cPreemb)
Parametros  : lCheck - Se .T., verifica na base de dados, senão verifica somente nas Works.
Retorno     : cId - Novo ID gerado.
Objetivos   : Retornar um novo ID.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Function Ae110NewId(lCheck, cPreemb, cFilId)
Local aOrd
Local cId := StrZero(If(Type("nID") == "N", ++nID, 10), AvSx3("EYH_ID", AV_TAMANHO))
Default lCheck := .T.
Default cPreemb := ""
Default cFilId := xFilial("EYH")

Begin Sequence

   If lCheck
      If Type("cWorkNE") <> "C" .Or. Type("cWorkES") <> "C" .Or. (Select(cWorkNE) == 0) .Or. (Select(cWorkES) == 0)
         aOrd := SaveOrd({"EYH", "EX9"})
         If Empty(cPreemb)
            Break
         EndIf
         EYH->(DbSetOrder(1))
         EX9->(DbSetOrder(2))
         If EYH->(AvSeekLast(cFilId+"S"+cPreemb))
            cId := EYH->EYH_ID
         EndIf
         If EYH->(AvSeekLast(cFilId+"N"+cPreemb)) .And. Val(cId) < Val(EYH->EYH_ID)
            cId := EYH->EYH_ID
         EndIf
         If EX9->(AvSeekLast(cFilId+cPreemb)) .And. Val(cId) < Val(EX9->EX9_ID)
            cId := EX9->EX9_ID
         EndIf
         cId := StrZero(Val(cId) + 1, AvSx3("EYH_ID", AV_TAMANHO))
      Else
         aOrd := SaveOrd({cWorkNE, cWorkES})
         (cWorkNE)->(DbSetOrder(1))
         (cWorkES)->(DbSetOrder(1))
         If (cWorkNE)->(DbSeek(cId)) .Or. (cWorkES)->(DbSeek(cID))
            If Val((cWorkNE)->EYH_ID) > Val((cWorkES)->EYH_ID)
               (cWorkNe)->(DbGoBottom())
               nId := Val((cWorkNE)->EYH_ID)
            Else
               (cWorkES)->(DbGoBottom())
               nId := Val((cWorkES)->EYH_ID)
            EndIf
            cId := Ae110NewId(lCheck)
         EndIf
      EndIf
   EndIf

End Sequence

If ValType(aOrd) == "A"
   RestOrd(aOrd, .T.)
EndIf

Return cId

/*
Função      : GetRelacao(cEmb, cEmbSup)
Parametros  : cEmb - Código da embalagem
              cEmbSup - Código da embalagem superior.
Retorno     : nRelacao - Relação entre as embalagens (qual a quantidade da embalagem atual que a embalagem superior comporta).
Objetivos   : Retornar a relação entre embalagens.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Static Function GetRelacao(cEmb, cEmbSup)
Local aOrd
Local nRelacao := 0 /*nRelacao := 1 - RMD - Quando retornar zero, significa que a relação não foi encontrada. (assim quem chamar a rotina irá
                                            utilizar a quantidade atual como a relação.*/
Default cEmb := "", cEmbSup := ""

If !(Empty(cEmb) .Or. Empty(cEmbSup))
   aOrd := SaveOrd({"EEK"})
   EEK->(DbSetOrder(1))
   If EEK->(DbSeek(xFilial()+OC_EMBA+cEmb+AvKey("01", "EEK_SEQ")))
      If EEK->EEK_EMB == cEmbSup
         nRelacao := EEK->EEK_QTDE
      EndIf
   EndIf
   RestOrd(aOrd, .T.)
EndIf

Return nRelacao

/*
Função      : Ae110GetConts()
Parametros  : Nenhum.
Retorno     : Nenhum.
Objetivos   : Buscar os containeres já cadastrados para o embarque.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Function Ae110GetConts()

   EX9->(DbSeek(xFilial()+EEC->EEC_PREEMB))
   While EX9->(!Eof() .And. EX9_FILIAL+EX9_PREEMB == xFilial()+EEC->EEC_PREEMB)

      (cWorkEX9)->(DbAppend())
      AvReplace("EX9", cWorkEX9)
      (cWorkEX9)->WK_RECNO := EX9->(Recno())

      (cWorkES)->(DbAppend())

      (cWorkES)->EYH_PREEMB := (cWorkEX9)->EX9_PREEMB
      (cWorkES)->EYH_CODEMB := (cWorkEX9)->EX9_CONTNR
      (cWorkES)->EYH_QTDEMB := 1
      (cWorkES)->EYH_ESTUF  := "S"

      If Empty(EX9->EX9_ID)
         (cWorkEX9)->EX9_ID := Ae110NewId()
      EndIf
      (cWorkES)->EYH_ID := (cWorkEX9)->EX9_ID
      If EECFlags("PRE-CONTAINER") .And. (EX9->EX9_PRECON $ cSim)
         (cWorkES)->EYH_IDVINC := cZeroPreC
      Else
         (cWorkES)->EYH_IDVINC := cZeroCont
      EndIf

      //Indica que a linha refere-se a um container
      (cWorkES)->WK_ISCONT := "S"

      (cWorkES)->WK_RECNO := (cWorkEX9)->(Recno())

      EX9->(DbSkip())
   EndDo

Return Nil

/*
Função      : Ae110GerTree(cOpc)
Parametros  : cOpc - Tree a ser gerado:
                        "NE" - Itens não estufados
                        "ES" - Itens estufados.
Retorno     : aTree - Array de definições do Tree.
Objetivos   : Montar array de definições para AvTree.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Function Ae110GerTree(cOpc)
Local aTree := {}
Local cWork
Local cImg
Default cOpc := ""

   If cOpc == "NE"
      cWork := cWorkNE
      //Raiz do Tree
      aAdd(aTree, {" ", STR0048, cZero, , , cZero})//	STR0048	"Mercadorias"
   ElseIf cOpc == "ES"
      cWork := cWorkES
      //Raiz do Tree
      aAdd(aTree, {" ", STR0049, "OPC", , , "OPC"})//	STR0049	"Opções de Estufagem"
      aAdd(aTree, {"OPC", STR0050, "CONT", , , cZeroCont})//STR0050	"Containers"
      If EECFlags("PRE-CONTAINER")
         aAdd(aTree, {"OPC", cDesPreCon, "PREC", , , cZeroPreC})
      EndIf
   EndIf

   (cWork)->(DbGoTop())
   While (cWork)->(!Eof())
      cImg := GetImgTree(cWork)
      aAdd(aTree, (cWork)->({AllTrim(EYH_IDVINC), Ae110Info("WORK_DESC", cWork), Ae110Info("WORK_CARGO", cWork), cImg, cImg, EYH_ID}))
      (cWork)->(DbSkip())
   EndDo

Return aTree

/*
Função      :
Parametros  :
Retorno     :
Objetivos   :
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Static Function GetImgTree(cWork, lMov, lUnderPallet)
Local cImg := "", cIdVinc := (cWork)->EYH_IDVINC
Local aOrd
Default lMov := .F.
Default lUnderPallet := .F.

   If cWork <> "M"
      aOrd := SaveOrd(cWork)
   EndIf

   Do Case
      Case (cWork)->WK_ISCONT == "S"
         // BAK - Alteração para comparação da vinculação
         If EECFlags("PRE-CONTAINER") .And. AllTrim((cWork)->EYH_IDVINC) == AllTrim(cZeroPreC)
            cImg := EasyGParam("MV_AVG0158",, "AVG_CONT")
         Else
            cImg := "AVG_CONT"
         EndIf
      Case (cWork)->EYH_PLT == "S"
         cImg := "AVG_PLT"
      Case !Empty((cWork)->EYH_COD_I)
         cImg := "AVG_EMBI"
      OtherWise
         cImg := "AVG_EMBF"
         If !(cIdVinc $ cZero+"/"+cZeroCont+"/"+cZeroPreC) .And. !lUnderPallet .And. cWork <> "M"
            (cWork)->(DbSetOrder(1))
            If (cWork)->(DbSeek(cIdVinc)) .And. ((cWork)->WK_ISCONT <> "S") .And. ((cWork)->EYH_PLT <> "S")
               cImg := "AVG_EMBM"
            EndIf
         EndIf

   End Case

   If lMov .And. !Empty(cImg)
      cImg += "_T"
   EndIf

RestOrd(aOrd, .T.)

Return cImg

/*
Função      :
Parametros  :
Retorno     :
Objetivos   :
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Static Function CriaWork(cAlias, aSemSX3, cAliasWK)
Local aNomFile := {}, nInc
Private aHeader:={}
Private aCampos  := Array((cAlias)->(FCount()))
Default aSemSX3 := {}
   //NCF - 29/07/2013
   aAdd(aSemSx3, {"EYH_IDPROR","C",  6,0 })
   aAdd(aSemSx3, {"WK_RECNO",  "N", 10, 0})
   aAdd(aSemSx3, {"WK_ISCONT", "C", 01, 0})

   If cAlias == "EX9"
      AddNaoUsado(aSemSx3, "EX9_ID")
      AddNaoUsado(aSemSx3, "EX9_PRECON")
      For nInc := 1 To Len(aMemosEX9)
         AddNaoUsado(aSemSx3, aMemosEX9[nInc][1])
      Next
   EndIf

   aAdd(aNomFile, E_CriaTrab(cAlias, aSemSx3, cAliasWK))

   If cAlias == "EYH"
      IndRegua(cAliasWK, aNomFile[1]+TEOrdBagExt(), "EYH_ID")

      aAdd(aNomFile, CriaTrab(, .F.))
      IndRegua(cAliasWK, aNomFile[2]+TEOrdBagExt(),"EYH_CODEMB")

      aAdd(aNomFile, CriaTrab(, .F.))
      IndRegua(cAliasWK, aNomFile[3]+TEOrdBagExt(),"EYH_IDVINC")

      aAdd(aNomFile, CriaTrab(, .F.))
      IndRegua(cAliasWK, aNomFile[4]+TEOrdBagExt(),"EYH_COD_I+EYH_SEQEMB")

      Set Index to (aNomFile[1]+TEOrdBagExt()), (aNomFile[2]+TEOrdBagExt()), (aNomFile[3]+TEOrdBagExt()), (aNomFile[4]+TEOrdBagExt())
   EndIf
   If cAlias == "EX9"
      IndRegua(cAliasWK, aNomFile[1]+TEOrdBagExt(),"EX9_CONTNR")

      Set Index to (aNomFile[1]+TEOrdBagExt())
   EndIf

Return aNomFile

/*
Função      :
Parametros  :
Retorno     :
Objetivos   :
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Function Ae110GrvEstuf(cWork, cAlias)
Local aWorks := {{cWorkNE, "EYH"}, {cWorkES, "EYH"}, {cWorkEX9, "EX9"}}
Local nInc
Default cAlias := ""
Default cWork := ""

   If Empty(cWork)
      For nInc := 1 To Len(aWorks)
         Ae110GrvEstuf(aWorks[nInc][1], aWorks[nInc][2])
      Next
   Else
      ProcRegua((cWork)->(LastRec()))
      (cWork)->(DbGoTop())
       While (cWork)->(!Eof())
          If cAlias <> "EYH" .Or. (cWork)->WK_ISCONT <> "S"

            If (cWork)->WK_RECNO > 0
               (cAlias)->(DbGoTo((cWork)->WK_RECNO))
            EndIf

            (cAlias)->(RecLock(cAlias, (cWork)->WK_RECNO == 0))

            AvReplace(cWork, cAlias)

            //Tratamento para a gravação do campo Memo da Marcação - BAK - 27 de Janeiro de 2011
            If lMarcacao .And. (cWork)->(FieldPos("EYH_CODMAR")) > 0
               If (cWork)->WK_RECNO == 0
                  MSMM((cWork)->EYH_CODMAR,,,,EXCMEMO)
               EndIf
               MSMM(,AVSX3("EYH_MARCAC",AV_TAMANHO),,(cWork)->EYH_MARCAC,INCMEMO,,,"EYH","EYH_CODMAR")
            EndIf

            (cAlias)->(MsUnlock())

            IncProc()

         EndIf
         (cWork)->(DbSkip())
      EndDo

      For nInc := 1 To Len(aDeletados)
         (aDeletados[nInc][1])->(DbGoTo(aDeletados[nInc][2]))
         (aDeletados[nInc][1])->(RecLock(aDeletados[nInc][1], .F.))
         (aDeletados[nInc][1])->(DbDelete())
         (aDeletados[nInc][1])->(MsUnlock())
      Next
   EndIf

Return Nil

/*
Função      :
Parametros  :
Retorno     :
Objetivos   :
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Function Ae110CTree(cOpc, cCargo, cMemo)
Local cWork, oMemo, nRecno, oTree
Default cOpc:= ""

   //*** Atualiza variáveis que indicam o Tree ativo e o galho/folha selecionado
   cActiveTree := cOpc
   If cActiveTree == "NE"
      nRecno := Val(Right(cCargo, Len(cCargo) - 5))
      cWork  := cWorkNE
      oMemo  := oMemoNE
      oTree  := oTreeNE
      cMemo  := STR0029 //STR0029	"Itens não Estufados"
   ElseIf cActiveTree == "ES"
      nRecno := Val(Right(cCargo, Len(cCargo) - 5))
      cWork  := cWorkES
      oMemo  := oMemoES
      oTree  := oTreeNE
      cMemo  := STR0030 //STR0030	"Itens Estufados"
   EndIf
   //***

   (cWork)->(DbGoTo(nRecno))

   If (cWork)->(!Eof() .And. !(EYH_ID $ cZero+"/"+cZeroCont+"/"+cZeroPreC))
      //*** Descrição do item (exibida no painel inferior)
      Do Case
         Case (cWork)->WK_ISCONT == "S"
            // BAK - Alteração para comparação da vinculação
            If EECFlags("PRE-CONTAINER") .And. AllTrim((cWork)->EYH_IDVINC) == AllTrim(cZeroPreC)
               cMemo := cDesPreCon + ": "
            Else
               cMemo := "Container: "
            EndIf
            cMemo += (cWork)->EYH_CODEMB + ENTER
         Case !Empty((cWork)->EYH_COD_I)
            cMemo := STR0051 //STR0051	"Produto: "
            cMemo += (cWork)->EYH_CODEMB + ENTER
            cMemo += STR0052 //STR0052	"Lote: "
            cMemo += (cWork)->EYH_LOTE + ENTER
         OtherWise
            cMemo := STR0053 //STR0053	"Embalagem: "
            cMemo += (cWork)->EYH_CODEMB + ENTER
            If lQuebraOIC // EasyGParam("MV_AVG0114") //Habilitar/Desabilitar Adequações do sistema ao exportador de café. - BAK - 27 de Janeiro de 2011
               cMemo += "OIC: "
               cMemo += (cWork)->EYH_CHAVE + ENTER
            EndIf
      End Case

      If (cWork)->WK_ISCONT == "S"
         cMemo += STR0054 //	#define	STR0054	"Descrição: "
         (cWorkEX9)->(DbGoTo((cWorkES)->WK_RECNO))
         cMemo += MSMM((cWorkEX9)->EX9_OBS, AvSx3("EX9_VM_OBS", AV_TAMANHO))
         cMemo += ENTER
      Else
         cMemo += STR0054 + (cWork)->EYH_DESEMB + ENTER //STR0054	"Descrição: "
      EndIf
      cMemo += STR0055 + Transform((cWork)->EYH_QTDEMB, AvSx3("EE9_SLDINI", AV_PICTURE)) + ENTER //	STR0055	"Quantidade: "
      If (cWork)->WK_ISCONT <> "S" .And. Empty((cWork)->EYH_COD_I) .And. (cWork)->EYH_PLT == "S"
         cMemo += STR0056 + ENTER //STR0056	"Esta embalagem foi definida como tipo Pallet."
      EndIf
      cMemo += STR0057 + Transform((cWork)->EYH_PSLQUN, cPictPeso) + " " + cUnPes + ENTER //STR0057	"Peso Liq. Un. : "
      cMemo += STR0058 + Transform((cWork)->EYH_PSBRUN, cPictPeso) + " " + cUnPes + ENTER//STR0058	"Peso Bru. Un. : "
      cMemo += STR0059 + Transform((cWork)->EYH_PSLQTO, cPictPeso) + " " + cUnPes + ENTER//	STR0059	"Peso Liq. Tot.: "
      cMemo += STR0060 + Transform((cWork)->EYH_PSBRTO, cPictPeso) + " " + cUnPes + ENTER //STR0060	"Peso Bru. Tot.: "

      //BAK - 27 de Janeiro de 2011
      If lMarcacao .And. (cWork)->WK_ISCONT != "S" //.And. Empty((cWork)->EYH_COD_I)
         cMemo += STR0061 + " " + (cWork)->EYH_MARCAC //	STR0061	"Marcação: "
      EndIf
      //***
   EndIf

   If EasyEntryPoint("EECAE110")
      ExecBlock("EECAE110", .F., .F., {"ESTUFAGEM_DESCRICAO_ITEM", cWork})
   EndIf
   oMemo:Refresh()

Return Nil

/*
Função      :
Parametros  :
Retorno     :
Objetivos   :
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Function Ae110MovDe(cWork, nRecno, cCargo, oTree, nQtde, cId, lGetItem)
Local aOrd
Default cWork  := Ae110Info("TREE_WORK")
Default nRecno := Ae110Info("TREE_RECNO")
Default cCargo := Ae110Info("TREE_CARGO")
Default oTree  := Ae110Info("TREE")
Default cId    := Ae110Info("TREE_ID")
Default lGetItem := .F.

   aOrd := SaveOrd(cWork)
   (cWork)->(DbGoTo(nRecno))
   If (cWork)->WK_ISCONT == "S"
      MsgInfo(STR0062, STR0001)//STR0062	"Não é possível mover este tipo de estrutura." //STR0001	"Atenção"
   ElseIf nRecno == 0
      MsgInfo(STR0063, STR0001) //STR0063	"Não é possível mover. Selecione a origem primeiro."//STR0001	"Atenção"
   ElseIf !Empty((cWork)->EYH_COD_I)
      If !lGetItem
         MsgInfo(STR0064, STR0001) //STR0064	"Não é possível mover itens sem mover a sua embalagem imediatamente superior."//STR0001	"Atenção"
      Else
         /*(cWork)->(DbSetOrder(1))
         (cWork)->(DbSeek(EYH_IDVINC))
         cCargo := Ae110Info("WORK_CARGO", cWork)
         oTree:TreeSeek(cCargo)
         Ae110MovDe(cWork, (cWork)->(RecNo()), cCargo, oTree, nQtde,,lGetSuperior)*/
         Default nQtde  := Ae108GetQtd(Ae110Info("TREE_SALDO"),,!lTelaQuantidade,,cWork)
         aMovDe := {cWork, nRecno, cCargo, oTree, nQtde, cId, GetStruct(cWork)}
      EndIf
   Else
      // BAK - Tratamento para quebra do produto na estufagem - 13/02/2013
      Default nQtde  := Ae108GetQtd(Ae110Info("TREE_SALDO"),,!lTelaQuantidade,,cWork)
      If nQtde > 0
         If Len(aMovDe) > 0
            ChangeImg(aMovDe[1], aMovDe[2], aMovDe[3], aMovDe[4], .F.)
         EndIf
         ChangeImg(cWork, nRecno, cCargo, oTree, .T.)
         aMovDe := {cWork, nRecno, cCargo, oTree, nQtde, cId, GetStruct(cWork)}
      EndIf
   EndIf
   RestOrd(aOrd, .T.)

Return Nil

/*
Função      :
Parametros  :
Retorno     :
Objetivos   :
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Function Ae110MovPara(cWork, nRecno, cCargo, oTree, cId, lReposiciona)
Local lRet := .T.
Default cWork  := Ae110Info("TREE_WORK")
Default nRecno := Ae110Info("TREE_RECNO")
Default cCargo := Ae110Info("TREE_CARGO")
Default oTree  := Ae110Info("TREE")
Default cId    := Ae110Info("TREE_ID")
Default lReposiciona := .F.

Begin Sequence

   If Empty(aMovDe)
      MsgInfo(STR0063, STR0001)//STR0063 "Não é possível mover. Selecione a origem primeiro."//STR0001 "Atenção"
      lRet := .F.
      Break
   EndIf
   If cWork == cWorkES .And. nRecno == 0
      MsgInfo(STR0065, STR0001)//STR0065	"Não é possível mover. Selecione o destino."//STR0001 "Atenção"
      lRet := .F.
      Break
   EndIf
   If aMovDe[1] == cWork .And. aMovDe[2] == nRecno
      MsgInfo (STR0066, STR0001)//STR0066	"Não é possível mover. A origem e o destino são iguais."//STR0001 "Atenção"
      lRet := .F.
      Break
   EndIf
   (cWork)->(DbGoTo(nRecno))
   If !Empty((cWork)->EYH_COD_I) .AND. cWork <> cWorkNE
      MsgInfo(STR0067, STR0001)//STR0067 "Não é possível mover. Itens não podem conter elementos no seu nível inferior."//STR0001 "Atenção"
      lRet := .F.
      Break
   EndIf
   If FindLeaf(cId, aMovDe[6], cWork)
      MsgInfo(STR0068, STR0001)//STR0068	"Não é possível mover. O destino está contido na mesma estrutura da origem."//STR0001 "Atenção"
      lRet := .F.
      Break
   EndIf

   /* RMD - 28/06/16 - Não posiciona na raiz porque senão perde a referência da embalagem de destino.
   If cWork == cWorkNE
      (cWork)->(dbGoBoTTom(),dbSkip())
      aMovPara := {cWork, 0, cZero, oTree, cZero,, GetStruct(cWork)}
   Else
   */
      aMovPara := {cWork, nRecno, cCargo, oTree, cId,, GetStruct(cWork)}
   //EndIf

   //(aMovDe[1])->(dbGoTo(aMovDe[2]))
   cDePai := (aMovDe[1])->EYH_IDVINC

   Ae110MovIt(aMovDe, aMovPara)
   //Atualiza os campos de peso bruto
   Ae110AtuPeso(cWorkNe,, cZero)
   Ae110AtuPeso(cWorkEs,, cZeroCont)
   If EECFlags("PRE-CONTAINER")
      Ae110AtuPeso(cWorkEs,, cZeroPreC)
   EndIf
   ChangeImg(aMovDe[1], aMovDe[2], aMovDe[3], aMovDe[4], .F., .T.)

   (aMovDe[1])->(dbSetOrder(3))
   (aMovDe[1])->(dbSeek(cDePai))

   aBkpDe := (aMovDe[1])->({aMovDe[1],RecNo(),Ae110Info("WORK_CARGO", aMovDe[1]),aMovDe[4],aMovDe[5],cDePai,GetStruct(aMovDe[1])})

   aMovDe := {}

   nRecAtu := (cWork)->(RecNo())
   cOld := cActiveTree
   cActiveTree := Right(cWork,2)

   Ae110MovDe(,,,, aBkpDe[5],,.T.)
   Ae110Operacao(aBkpDe, aMovDe, aMovPara)

   cActiveTree := cOld
   aMovDe := {}

   If lReposiciona
      (cWork)->(dbGoTo(aMovPara[2]))
      aMovPara[4]:TreeSeek(Ae110Info("WORK_CARGO", aMovPara[1]))
   Else
      (cWork)->(dbGoTo(nRecAtu))
      aMovPara[4]:TreeSeek(Ae110Info("WORK_CARGO", aMovPara[1]))
   EndIf

End Sequence

Return lRet

Static Function Ae110Desfaz(lReFaz)
Local nPos
Local aMoveDe
Local aMovePara
Default lReFaz := .F.

Begin Sequence

If !lReFaz .AND. nOperaPos > 0 .OR. lReFaz .AND. nOperaPos < Len(aOperacoes)
   If lReFaz
      nOperaPos ++
   EndIf

   nPos := nOperaPos

   if lReFaz
      aMoveDe   := aOperacoes[nPos][2]
      aMovePara := aOperacoes[nPos][3]//3
   Else
      aMoveDe   := aOperacoes[nPos][2]
      aMovePara := aOperacoes[nPos][1]
   EndIf

   //aMoveDe[6] := aMoveDe[5]
   //aMoveDe[5] := aMovePara[5]

   //aMovePara[4]:SetFocus()
   //Eval(aMovePara[4]:bGotFocus)
   //Ae110MovPara(aMovePara[1], aMovePara[2], aMovePara[3], aMovePara[4], aMovePara[6])

               (aMovePara[1])->(dbSetOrder(1))
               (aMoveDe[1])->(dbSetOrder(1))

               nRecnoWkDe := aMoveDe[2]
               (aMoveDe[1])->(dbGoTo(nRecnoWkDe))

               If !Empty((aMoveDe[1])->EYH_COD_I)
                  If !(aMoveDe[1])->(dbSeek(EYH_IDVINC))
                     If lReFaz
                        nOperaPos --
                     EndIf
                     Break
                  EndIf
                  nRecnoWkDe := (aMoveDe[1])->(RecNo())
               EndIf

               //cNePallet := (aMoveDe[1])->EYH_PLT

               cCargoDest := Ae110Info("WORK_CARGO", aMoveDe[1])
               aMoveDe[4]:TreeSeek(cCargoDest)
               Eval(aMoveDe[4]:bChange)

               //(cWorkNE)->(DbGoTo(Ae110Info("TREE_RECNO")))
               //(cWorkNE)->EYH_PLT := cPallet

               Ae110MovDe(,,,, aMoveDe[5])

               (aMovePara[1])->(dbGoTo(aMovePara[2]))
               (aMovePara[1])->(dbSeek(EYH_IDVINC))

               cCargoOri := Ae110Info("WORK_CARGO", aMovePara[1])
               aMovePara[4]:TreeSeek(cCargoOri)
               Eval(aMovePara[4]:bChange)

               Ae110MovPara()

               //Reposiciona as Works após a transferência de embalagem
               (aMoveDe[1])->(DbGoTo(nRecnoWkDe))
               //(cWorkNE)->EYH_PLT := cNePallet
               aMoveDe[4]:TreeSeek(Ae110Info("WORK_CARGO", aMoveDe[1]))

               If !IsVazio(aMoveDe[1]) .And. (aMoveDe[1])->EYH_QTDEMB > 0
                  ChangeImg(aMoveDe[1], (aMoveDe[1])->(Recno()),, aMoveDe[4])
               EndIf


   If !lReFaz
      nOperaPos --
   EndIf

EndIf

End Sequence

Return .T.

Static Function Ae110Operacao(aMovDe,aMov,aMovPara)

If !IsInCallStack("Ae110Desfaz")

   Do While Len(aOperacoes) > nOperaPos
      aDel(aOperacoes,Len(aOperacoes))
      aSize(aOperacoes,Len(aOperacoes)-1)
   EndDo

   aAdd(aOperacoes,{aClone(aMovDe),aClone(aMov),aClone(aMovPara)})
   nOperaPos++
Else
   aOperacoes[nOperaPos][2] := aClone(aMov)
EndIf

Return .T.

Static Function FindLeaf(cIdLeaf, cIdTree, cWork)
Local aOrd := SaveOrd(cWork)
Local lRet := .F.

   (cWork)->(DbSetOrder(3))
   (cWork)->(DbSeek(cIdTree))
   // BAK - Alteração para comparação da vinculação
   While AllTrim((cWork)->EYH_IDVINC) == AllTrim(cIdTree)
      If (AllTrim((cWork)->EYH_ID) == AllTrim(cIdLeaf)) .Or. FindLeaf(cIdLeaf, (cWork)->EYH_ID, cWork)
         lRet := .T.
         Exit
      EndIf
      (cWork)->(DbSkip())
   EndDo

RestOrd(aOrd, .T.)
Return lRet

Static Function ChangeImg(cWork, nRecno, cCargo, oTree, lMov, lChangeCargo, lUnderPallet)
Local aOrd := SaveOrd(cWork)
Local cImg, cCargoAtu := oTree:GetCargo()
Default lChangeCargo := .F.
Default lUnderPallet := .F.

   (cWork)->(DbGoTo(nRecno))
   Default cCargo := cCargoAtu
   cImg := GetImgTree(cWork, lMov, lUnderPallet)
   If oTree:TreeSeek(cCargo)
      oTree:ChangeBMP(cImg, cImg)
   EndIf
   If !lChangeCargo
      oTree:TreeSeek(cCargoAtu)
   EndIf
   oTree:Refresh()
   Eval(oTree:bChange)

RestOrd(aOrd, .T.)
Return Nil

/*
Função      :
Parametros  :
Retorno     :
Objetivos   :
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Function Ae110Info(cInfo, xParam1, xParam2)
Local aOrd, cAlias
Private xRet
Default cInfo := ""

   Do Case
      Case cInfo == "TREE"
         If cActiveTree == "NE"
            xRet := oTreeNE
         ElseIf cActiveTree == "ES"
            xRet := oTreeES
         EndIf

      Case cInfo == "TREE_NAME"
         xRet := cActiveTree

      Case cInfo == "TREE_WORK"
         If cActiveTree == "NE"
            xRet := cWorkNE
         ElseIf cActiveTree == "ES"
            xRet := cWorkES
         EndIf

      Case cInfo == "TREE_CARGO"
         If cActiveTree == "NE"
            xRet := oTreeNE:GetCargo()
         ElseIf cActiveTree == "ES"
            xRet := oTreeES:GetCargo()
         EndIf

      Case cInfo == "TREE_RECNO"
         xRet := Ae110Info("TREE_CARGO")
         xRet := Val(Right(xRet, Len(xRet) - 5))

      Case cInfo == "TREE_SALDO"
         aOrd := SaveOrd(Ae110Info("TREE_WORK"))
         (Ae110Info("TREE_WORK"))->(DbGoTo(Ae110Info("TREE_RECNO")))
         xRet := (Ae110Info("TREE_WORK"))->EYH_QTDEMB
         RestOrd(aOrd, .T.)

      Case cInfo == "TREE_ID"
         If cActiveTree == "NE"
            cAlias := cWorkNE
            xRet := cZero
         ElseIf cActiveTree == "ES"
            cAlias := cWorkES
            xRet := cZeroCont
         EndIf
         (cAlias)->(DbGoTo(Ae110Info("TREE_RECNO")))
         If !(cAlias)->(Eof() .Or. Bof())
            xRet := (cAlias)->EYH_ID
         EndIf

      Case cInfo == "WORK_DESC"
         If Select(xParam1) > 0
            Do Case
               Case (xParam1)->WK_ISCONT == "S"
                  xRet := "Cod: " + (xParam1)->(EYH_CODEMB + " " + "Qtd: " + AllTrim(Str(EYH_QTDEMB)))
               Case !Empty((xParam1)->EYH_COD_I)
                  xRet := If(!Empty((xParam1)->EYH_LOTE), "[" + AllTrim((xParam1)->EYH_LOTE) + "]","") + "Prod: " + (xParam1)->(EYH_DESEMB + " " + "Qtd: " + AllTrim(Str(EYH_QTDEMB)))
               OtherWise
                  If lQuebraOIC // EasyGParam("MV_AVG0114") //Habilitar/Desabilitar Adequações do sistema ao exportador de café. - BAK - 27 de Janeiro de 2011
                     xRet := "Emb: " + (xParam1)->(EYH_DESEMB + " OIC: " + EYH_CHAVE + " " + "Qtd: " + AllTrim(Str(EYH_QTDEMB)))
                  Else
                     xRet := "Emb: " + (xParam1)->(EYH_DESEMB + " " + "Qtd: " + AllTrim(Str(EYH_QTDEMB)))
                  EndIf
            End Case
         EndIf

      Case cInfo == "WORK_CARGO"
         If Select(xParam1) > 0
            xRet := xParam1 + StrZero((xParam1)->(Recno()), 10)
         EndIf

      Case cInfo == "WORK_CARGO_PAI"
         If Select(xParam1) > 0
            aOrd := SaveOrd(xParam1)
            cIdPai := (xParam1)->EYH_IDVINC
            (xParam1)->(DbSetOrder(1))
            If (xParam1)->(DbSeek(cIdPai))
               xRet := xParam1 + StrZero((xParam1)->(Recno()), 10)
            EndIf
            RestOrd(aOrd, .T.)
         EndIf

   EndCase
   If EasyEntryPoint("EECAE110")
      ExecBlock("EECAE110", .F., .F., {"AE110INFO_DESCRICAO", cInfo})
   EndIf
Return xRet

/*
Função      :
Parametros  :
Retorno     :
Objetivos   :
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Function Ae110MovIt(aMovDe, aMovPara, lRefresh, lJoin)
Local aOrd := SaveOrd({cWorkNE, cWorkES})
Local aNextDe, aNextPara, aStruDe, aStruPara, aProxStruDe := {}
Local lOkStru := .F.
Local cWkOri, cWkDes, cCargoOri, cCargoDes, cIdAtuOri, cIdAtuDes, cNewDesc, cImg
Local oTreeOri, oTreeDes
Local nInc, nRecOri, nRecDes, nQtdeMov, nSaldo := 0, nPos
Default lRefresh := .T.
Default lJoin := .F.

Begin Sequence

   cWkOri    := aMovDe[1]
   nRecOri   := aMovDe[2]
   cCargoOri := aMovDe[3]
   oTreeOri  := aMovDe[4]
   nQtdeMov  := aMovDe[5]
   cIdAtuOri := aMovDe[6]
   aStruDe   := aMovDe[7]


   cWkDes    := aMovPara[1]
   nRecDes   := aMovPara[2]
   cCargoDes := aMovPara[3]
   oTreeDes  := aMovPara[4]
   cIdAtuDes := aMovPara[5]
   aStruPara := aMovPara[7]

   lOkStru := ValType(aStruDe) == "A" .And. Len(aStruDe) > 0 .And. ValType(aStruPara) == "A" .And. Len(aStruPara) > 0

   (cWkOri)->(DbGoTo(nRecOri))
   If nQtdeMov < (cWkOri)->EYH_QTDEMB
      (cWkOri)->EYH_QTDEMB -= nQtdeMov
   Else
      nSaldo   := nQtdeMov - (cWkOri)->EYH_QTDEMB
      nQtdeMov := (cWkOri)->EYH_QTDEMB
      (cWkOri)->EYH_QTDEMB := 0
   EndIf

   For nInc := 1 To (cWkOri)->(FCount())
      M->&((cWkOri)->(FieldName(nInc))) := (cWkOri)->(FieldGet(nInc))
   Next

   If (cWkOri)->(   (!Empty(EYH_COD_I) .And. !Empty(EYH_LOTE))    .And.    !EasyGParam("MV_AVG0199",,.F.)   .Or.   (FieldPos("EYH_CHAVE") > 0 .And. !Empty(EYH_CHAVE))    ) //BAK - 27 de Janeiro de 2011    //NCF - 14/08/2012 - Adicionada verificação de existência do campo EYH_CHAVE
      lJoin := .F.//Nunca agrupa o item se o mesmo possuir lote.
   ElseIf lOkStru .And. !lJoin
      If lGroupEmbs .And. (lJoin := ((nPos := aScan(aStruPara[5], {|x| (x[1] == aStruDe[1]) .And. (x[2] == aStruDe[2]) })) > 0))
         nRecDes   := aStruPara[5][nPos][3]
         aStruPara  := aStruPara[5][nPos]
         (cWkDes)->(DbGoTo(nRecDes))
         cCargoDes := cWkDes + StrZero((cWkDes)->(Recno()), 10)
         cIdAtuDes := (cWkDes)->EYH_ID
      Else
        lOkStru := .F.
      EndIf
   EndIf

   If !lJoin

      (cWkDes)->(DbAppend())
      nRecDes := (cWkDes)->(Recno())

      AvReplace("M", cWkDes)

      (cWkDes)->WK_RECNO := 0

      (cWkDes)->EYH_ID     := Ae110NewId()
      (cWkDes)->EYH_IDVINC := cIdAtuDes
      (cWkDes)->EYH_ESTUF  := If(cWkDes == cWorkES, "S", "N")
      (cWkDes)->EYH_QTDEMB := nQtdeMov
      // BAK - 27 de Janeiro de 2011
      If lMarcacao
         (cWkDes)->EYH_MARCAC := M->EYH_MARCAC
      EndIf

   Else
      (cWkDes)->EYH_QTDEMB += nQtdeMov
	   /* RMD - 28/06/16 - Retornado o trecho anterior. O correto é sempre mover a quantidade que o usuário informou, se for necessário mover parcial ele deve informar
       antes da operação, na tela de seleção de saldo, e não tratar automaticamente. Com o tratamento abaixo ficou impossível somar uma quantidade maior
       a uma quantidade já estufada.

      /LGS-24/03/2014
       Verifica se a quantidade da nova estufagem é maior que a que já esta estufada no container, se for, estufa apenas a diferença.
       se for igual desconsidera estufagem neste container e retorna a quantidade inicial que foi inicializado para não baixar item a mais. /
   	  If nQtdeMov > (cWkDes)->EYH_QTDEMB
      	(cWkOri)->EYH_QTDEMB += (cWkDes)->EYH_QTDEMB
      	(cWkDes)->EYH_QTDEMB += (nQtdeMov - (cWkDes)->EYH_QTDEMB)
      Else
      	(cWkDes)->EYH_QTDEMB += nQtdeMov  // GFP - 18/01/2016
      EndIf
      */

   EndIf

   cNewCargo := cWkDes + StrZero((cWkDes)->(Recno()), 10)
   cNewDesc  := Ae110Info("WORK_DESC", cWkDes)

   If oTreeDes:TreeSeek(cCargoDes)
      If !Empty(M->EYH_COD_I)
         cImg := "AVG_EMBI"
      Else
         cImg := GetImgTree(cWkDes)
      EndIf
      If !lJoin
         oTreeDes:AddItem(cNewDesc, cNewCargo, cImg, cImg,,, 2)
         oTreeDes:TreeSeek(cNewCargo)
      Else
         oTreeDes:ChangePrompt(cNewDesc)
      EndIf

      If lRefresh
         oTreeDes:Refresh()
         oTreeDes:SetFocus()
      EndIf
   EndIf

   cIdAtuDes := (cWkDes)->EYH_ID

   (cWkOri)->(DbGoTo(nRecOri))
   AtuLeaf(oTreeOri, cWkOri, cCargoOri)

   (cWkOri)->(DbSetOrder(3))
   If (cWkOri)->(DbSeek(cIdAtuOri))
      aNextPara := {cWkDes, nRecDes, cNewCargo, oTreeDes, cIdAtuDes, Nil, aStruPara}
      //nQtdeMov := (cWkOri)->EYH_RELSUP * nQtdeMov
// BAK - Alteração para comparação da vinculação - 19/05/2011
//      While (cWkOri)->(!Eof() .And. EYH_IDVINC == cIdAtuOri) .And. nQtdeMov > 0
      While (cWkOri)->(!Eof()) .And. AllTrim((cWkOri)->(EYH_IDVINC)) == AllTrim(cIdAtuOri)// .And. nQtdeMov > 0
         If (cWkOri)->EYH_QTDEMB > 0
            If lOkStru
               aProxStruDe := aStruDe[5][aScan(aStruDe[5], {|x| AllTrim(x[4]) == AllTrim((cWkOri)->EYH_ID) })]
            EndIf
            aNextDe  := {cWkOri, (cWkOri)->(Recno()), cWkOri + StrZero((cWkOri)->(Recno()), 10), oTreeOri, (cWkOri)->EYH_RELSUP * nQtdeMov/*nQtdeMov*/, (cWkOri)->EYH_ID, aProxStruDe}
            //nQtdeMov  := Ae110MovIt(aNextDe, aNextPara, .F.)
            Ae110MovIt(aNextDe, aNextPara, .F.)
         EndIf
         (cWkOri)->(DbSkip())
      EndDo
   EndIf

   oTreeDes:TreeSeek(cNewCargo)
   Eval(oTreeDes:bChange)

End Sequence

RestOrd(aOrd, .T.)

Return nSaldo

Static Function AtuLeaf(oTree, cWork, cCargo, nQtd, cLote)
Default nQtd := (cWork)->EYH_QTDEMB
Default cLote := (cWork)->EYH_LOTE

   If nQtd == 0
      If (cWork)->WK_RECNO > 0
         aAdd(aDeletados, {"EYH", (cWork)->WK_RECNO})
      EndIf

      If Val((cWork)->EYH_ID) == nID
         nID--
      EndIf

      (cWork)->(DbDelete())
   Else
      (cWork)->EYH_QTDEMB := nQtd
      (cWork)->EYH_LOTE := cLote
   EndIf
   If oTree:TreeSeek(cCargo)
      If nQtd == 0
         oTree:DelItem()
      Else
         oTree:ChangePrompt(Ae110Info("WORK_DESC", cWork))
      EndIf
      If lRefresh
         oTree:Refresh()
         oTree:SetFocus()
      EndIf
   EndIf

Return .T.

Static Function GetStruct(cWork)
Local aOrd := SaveOrd(cWork)
Local cId  := (cWork)->EYH_ID
Local aEstru := {}, aEstruF

   If cWork == cWorkNE .AND. (cWork)->(EoF())
      aEstru := {"", "", 0, cZero, {}}
      cId := cZero
   Else
      aEstru := (cWork)->({EYH_CODEMB, EYH_COD_I, Recno(), EYH_ID, {}})
   EndIf
   (cWork)->(DbSetOrder(3))
   (cWork)->(DbSeek(cId))
// BAK - Alteração para comparação da vinculação - 19/05/2011
//   While (cWork)->(!Eof() .And. EYH_IDVINC == cID)
   While (cWork)->(!Eof()) .And. AllTrim((cWork)->EYH_IDVINC) == AllTrim(cID)
      aEstruF := GetStruct(cWork)
      aAdd(aEstru[5], aClone(aEstruF))
      (cWork)->(DbSkip())
   Enddo

RestOrd(aOrd, .T.)
Return aClone(aEstru)

/*
Função      :
Parametros  :
Retorno     :
Objetivos   :
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Function Ae110Wizard()
Local oProcess

Private cCont  := Space(AvSx3("EYG_CODCON", AV_TAMANHO))
Private nCont  := 0
Private cLotes := "2 - Não"
Private aEmbs  := {}, aLotes := {}
Private aHeader := {}
Private aCols := {}

   If IsVazio(cWorkNE)
      MsgInfo(STR0069, STR0070)//STR0069	"Não há itens disponíveis para estufagem." //	STR0070	"Aviso"
   Else
      If ShowWiz()
         oProcess := MsNewProcess():New({|| AutoEstuf(oProcess) }, STR0071, STR0072, .F.)//	STR0071	"Aguarde..." //STR0072	"Executando estufagem automática."
         oProcess:Activate()
      EndIf
   EndIf

Return Nil

Static Function AutoEstuf(oProcess, lPreCont)
Local aEX9 := {}
Local nInc1, nInc2, nRecnoWkNE, nCapacidade, nEstuf
Local aCapacidade, aCont := {}
Local cEmb, cCargoDest, cCargoOri, cPallet, cNePallet
Default lPreCont := .F.

   (cWorkES)->(DbGoTop())
   (cWorkNE)->(DbSetOrder(2))
   (cWorkNE)->(DbGoTop())
   While (cWorkES)->(!Eof())
      If (cWorkES)->WK_ISCONT == "S"
          aAdd(aCont, (cWorkES)->(Recno()))
      EndIf
      (cWorkES)->(DbSkip())
   EndDo

   oProcess:SetRegua1(3)
   oProcess:IncRegua1(STR0073)	//STR0073	"Incluindo containeres."

   oProcess:SetRegua2(nCont)
   For nInc1 := 1 To nCont
      oProcess:IncRegua2(StrTran(StrTran(STR0074, "XXX", AllTrim(Str(nInc1))), "YYY", AllTrim(Str(nCont))))//STR0074	"Incluindo container XXX de YYY."
      aAdd(aEX9, {"EX9_CONTNR", GetContNr()})
      aAdd(aEX9, {"EX9_TIPO"  , cCont      })
      aAdd(aCont, Ae110EditCont(INCLUIR, aEX9, .T., lPreCont))
   Next

   oProcess:IncRegua1(STR0075)//	STR0075	"Carregando containeres."
   oProcess:SetRegua2(Len(aCont))
   For nInc1 := 1 To Len(aCont)
      oProcess:IncRegua2(StrTran(StrTran(STR0076, "XXX", AllTrim(Str(nInc1))), "YYY", AllTrim(Str(Len(aCont)))))//STR0076	"Carregando container XXX de YYY."
      (cWorkES)->(DbGoTo(aCont[nInc1]))
      aCapacidade := GetCapacidade()
      For nInc2 := 1 To Len(aCapacidade)
         cEmb        := aCapacidade[nInc2][1]
         nCapacidade := aCapacidade[nInc2][2]
         cPallet     := If(aCapacidade[nInc2][3], "S", "N")
         (cWorkNE)->(DbGoTop())
         (cWorkNE)->(DbSetOrder(2))//RMD - 17/12/13
         (cWorkNE)->(DbSeek(cEmb))
         // BAK - Alteração para comparação da vinculação
         While (cWorkNE)->(!Eof() .And. AllTrim(EYH_CODEMB) == AllTrim(cEmb) .And. AllTrim(EYH_IDVINC) == AllTrim(cZero) .And. nCapacidade > 0)
            If (cWorkNE)->EYH_QTDEMB > 0
               nRecnoWkNE := (cWorkNE)->(Recno())
               cNePallet := (cWorkNE)->EYH_PLT
               If (cWorkNE)->EYH_QTDEMB < nCapacidade
                  nEstuf := (cWorkNE)->EYH_QTDEMB
               Else
                  nEstuf := nCapacidade
               EndIf
               nCapacidade -= nEstuf
               cCargoDest := Ae110Info("WORK_CARGO", cWorkNE)
               oTreeNE:TreeSeek(cCargoDest)
               Eval(oTreeNE:bChange)
               (cWorkNE)->(DbGoTo(Ae110Info("TREE_RECNO")))
               (cWorkNE)->EYH_PLT := cPallet
               Ae110MovDe(,,,, nEstuf)
               cCargoOri := Ae110Info("WORK_CARGO", cWorkES)
               oTreeES:TreeSeek(cCargoOri)
               Eval(oTreeES:bChange)
               Ae110MovPara()
               //Reposiciona as Works após a transferência de embalagem
               (cWorkNE)->(DbGoTo(nRecnoWkNE))
               (cWorkNE)->EYH_PLT := cNePallet
               oTreeNE:TreeSeek(Ae110Info("WORK_CARGO", cWorkNE))
               If !IsVazio(cWorkNE) .And. (cWorkNE)->EYH_QTDEMB > 0
                  ChangeImg(cWorkNE, (cWorkNE)->(Recno()),, oTreeNE)
               EndIf
               (cWorkES)->(DbGoTo(aCont[nInc1]))
            EndIf
            (cWorkNE)->(DbSkip())
         EndDo
      Next
   Next

   oProcess:IncRegua1(STR0077)//STR0077	"Definindo Lotes."
   If Left(cLotes, 1) == "1"
      AutoLotes(aCols,, aHeader, oProcess)
   EndIf

Return Nil

/*
Função      :
Parametros  :
Retorno     :
Objetivos   :
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Static Function ShowWiz()
Local oWizard, oPanel, oGetLotes
Local nCol1, nCol2, nCol3, nLin, nInc
Local aPos
Private lRefresh := .T.
Private lRet := .F.

Private aRotina := {{STR0078, "AxPesqui", 0, 1},;//	 STR0078	"Pesquisar"
                    {STR0079, "AxVisual", 0, 2},; //STR0079	"Visualizar"
                    {STR0080, "AxInclui", 0, 3},;   // STR0080	"Incluir"
                    {STR0081, "AxAltera", 0, 4},; //	 STR0081	"Alterar"
                    {STR0082, "AxDeleta", 0, 5}} //	 STR0082	"Excluir"

   DEFINE WIZARD oWizard TITLE STR0083 HEADER STR0084 MESSAGE STR0085 TEXT STR0086 PANEL NEXT {|| .T.} FINISH {|| .T.}//	STR0083	"Wizard de Estufagem" //STR0084	"Início" //	STR0085	"Apresentação" //STR0086	"Esta rotina irá obter os dados necessários para estufagem automática das  mercadorias."

      CREATE PANEL oWizard HEADER STR0087 MESSAGE STR0088 PANEL BACK {|| .F.} NEXT {|| Ae110WizVal("EYG_CODCON") } FINISH {|| .T.} EXEC {|| .T.}//	STR0087	"Inclusão de Containeres" //STR0088	"Tipo"
         oPanel := oWizard:oMPanel[Len(oWizard:oMPanel)]

         @ 20, 10  Say IncSpace(STR0089, 50, .T.) Of oPanel Pixel //STR0089	"Tipo de container a ser utilizado:"
         @ 19, 135 MsGet cCont Size 60, 7 Of oPanel Picture AvSx3("EYG_COD", AV_PICTURE) F3 "EYG" Pixel

      CREATE PANEL oWizard HEADER STR0090 MESSAGE STR0091 PANEL BACK {|| .T.} NEXT {|| .T.  } FINISH {|| .T.} EXEC {|| .T.} //STR0090	"Inclusão de Containeres" //STR0091	"Quantidade"
         oPanel := oWizard:oMPanel[Len(oWizard:oMPanel)]
         @ 20, 10  Say IncSpace(STR0092, 50, .T.) Of oPanel Pixel //STR0092	"Quantidade de containeres do tipo selecionado:"
         @ 19, 135 MsGet nCont Size 60, 7 Picture "@E 999,999,999,999" Valid Positivo(nCont) Of oPanel Pixel

      CREATE PANEL oWizard HEADER STR0093 MESSAGE STR0094 PANEL BACK {|| .T.} NEXT {|| Ae110WizVal("REL_EMBS")  } FINISH {|| .T.} EXEC {|| .T.}//STR0093	"Embalagens"  //STR0094	"Relação"
         oPanel := oWizard:oMPanel[Len(oWizard:oMPanel)]

         @ 5, 5  Say STR0095 Of oPanel Pixel //	STR0095	"Relação das embalagens com o container:"

         aPos := PosDlg(oPanel)
         //Cria ScrolBox para obter relação das embalagens de nível externo ainda não estufadas com o container
         oSbox := TScrollBox():New(oPanel, aPos[1], aPos[2], aPos[3] - 20, aPos[4],.T.,.F.,.T. )

         (cWorkNe)->(DbSetOrder(3))
         (cWorkNe)->(DbGoTop())
         (cWorkNe)->(DbSeek(cZero))
         nLin := 0
         // BAK - Alteração para comparação da vinculação
         While (cWorkNe)->(!Eof() .And. AllTrim(EYH_IDVINC) == AllTrim(cZero))
            If aScan(aEmbs, {|x| x[1] == (cWorkNe)->EYH_CODEMB}) == 0
               aAdd(aEmbs, {(cWorkNe)->EYH_CODEMB})
               If Mod(Len(aEmbs), 2) <> 0
                  nCol1 := 05
                  nCol2 := 65
                  nCol3 := 110
                  nLin  += 15
               Else
                  nCol1 := 145
                  nCol2 := 205
                  nCol3 := 250
               EndIf
               cVar1 := "n"+StrZero(Len(aEmbs), 9)
               cVar2 := "l" + StrZero(Len(aEmbs), 9)
               &(cVar1) := 0
               &(cVar2) := (cWorkNe)->EYH_PLT == "S"
               //Retira as aspas duplas da descrição (se houver) para não causar erro na macro
               TSay():New(nLin + 2, nCol1, &('{|| "' + StrTran((cWorkNe)->EYH_DESEMB, '"', "'") + '" }'),;
                          oSbox,,,,,, .T.,,, 50, 8)

               TGet():New(nLin, nCol2, &("{|u| If(pCount() > 0, M->" + cVar1 + " := u, M->" + cVar1 + ")}"),;
                          oSbox, 40, 8, "@E 999,999,999,999", ,,,,,,.T.,,,, .F., .F.,, .F., .F.,,cVar1)

               TCheckBox():New(nLin, nCol3, "Pallet", &("{|u| If(pCount() > 0, M->" + cVar2 + " := u, M->" + cVar2 + ")}"), oSBox, 30, 08,;
                               ,,,,,,, .T., STR0096) //#STR0096	"Mensagem"

            EndIf
            (cWorkNe)->(DbSkip())
         EndDo

      CREATE PANEL oWizard HEADER STR0097 MESSAGE STR0098 PANEL BACK {|| .T.} NEXT {|| .T.  } FINISH {|| lRet := .T. } EXEC {|| .F. }//	STR0097	"Lotes" //	STR0098	"Utilização da rotina"
         oPanel := oWizard:oMPanel[Len(oWizard:oMPanel)]

         @ 10, 06  Say STR0099 Of oPanel Pixel //	STR0099	"Será utilizada a rotina de controle de lotes?"
         @ 08, 120 ComboBox cLotes Items {STR0100, STR0101} Valid (If(Left(cLotes, 1) == "1", oGetLt:Show(), oGetLt:Hide())) Size 50,08 Of oPanel Pixel // STR0100	"2 - Não" //STR0101	"1 - Sim"

         aPos := PosDlg(oPanel)
         aCamposLt := {"EXA_LOTE", "EXA_COD_I", "EXA_SEQEMB", "EXA_QTDE"}
         For nInc := 1 To Len(aCamposLt)

            aAdd(aHeader,{AVSX3(aCamposLt[nInc], AV_TITULO),;
                                aCamposLt[nInc],;
                                AvSx3(aCamposLt[nInc], AV_PICTURE),;
                                AvSx3(aCamposLt[nInc], AV_TAMANHO),;
                                AvSx3(aCamposLt[nInc], AV_DECIMAL),;
                                "", Nil,;
                                AvSx3(aCamposLt[nInc], AV_TIPO),;
                                Nil, Nil})
         Next

         oGetLt := MsGetDados():New( aPos[1] + 10, aPos[2], aPos[3], aPos[4], 3, /*cLinhaOk*/, /*cTudoOk*/,, /*lDelete*/, aCamposLt,, /*lEmpty*/, 1500, "Ae110WizVal(ReadVar())",,, /*cDelOk*/, oPanel)
         oGetLt:Hide()

   ACTIVATE WIZARD oWizard CENTERED VALID {|| .T. }

Return lRet

/*
Função      :
Parametros  :
Retorno     :
Objetivos   :
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Function Ae110WizVal(cCpo)
Local lRet := .T.
Local nInc, nQtde := 0
Local cVar1, cVar2
Local aAux
Default cCpo := ""

Begin Sequence

   Do Case

      Case cCpo == "EYG_CODCON"
         If (lRet := !Empty(cCont))
            lRet := ExistCpo("EYG", cCont)
         Else
            MsgInfo(STR0102,STR0001)//STR0102	"Favor informar o código do container!"
         EndIf

      Case cCpo == "REL_EMBS"
         aAux := Array(Len(aEmbs))
         For nInc := 1 To Len(aEmbs)
            cVar1 := "n" + StrZero(nInc, 9)
            cVar2 := "l" + StrZero(nInc, 9)
            If (lRet := &(cVar1) > 0)
               aAux[nInc] := {aEmbs[nInc][1], &(cVar1), &(cVar2)}
            Else
               MsgInfo(STR0103,STR0001) //STR0103	"Favor informar a relação de todas as embalagens!"
               Exit
            EndIf
         Next
         If lRet
            aEmbs := aClone(aAux)
         EndIf

      Case cCpo == "QTD_CON"
         If nCont < 1
            MsgInfo(STR0104,STR0001) //STR0104	"Favor informar a quantidade de containeres!"
            lRet := .F.
         EndIf

      Case cCpo == "M->EXA_LOTE"
         For nInc := 1 To Len(aCols)
            If nInc <> n .And. !aCols[nInc][Len(aCols[nInc])] .And. GdFieldGet("EXA_LOTE", nInc) == M->EXA_LOTE
               MsgInfo(STR0105,STR0001) //STR0105	"Lote já informado"
               lRet := .F.
               Break
            EndIf
         Next

      Case cCpo == "M->EXA_COD_I"
         If Empty(M->EXA_COD_I)
            lRet := .F.
            Break
         Else
            EE9->(DbSetOrder(3))
            If !(EE9->(DbSeek(xFilial()+EEC->EEC_PREEMB+GdFieldGet("EXA_SEQEMB"))) .And. EE9->EE9_COD_I == M->EXA_COD_I) .Or. Empty(GdFieldGet("EXA_SEQEMB"))
               lRet := .F.
               EE9->(DbSeek(xFilial()+EEC->EEC_PREEMB))
               While EE9->(!Eof() .And. EE9_FILIAL+EE9_PREEMB == xFilial()+EEC->EEC_PREEMB)
                  If EE9->EE9_COD_I == M->EXA_COD_I
                     GdFieldPut("EXA_SEQEMB", EE9->EE9_SEQEMB)
                     lRet := .T.
                     Exit
                  EndIf
                  EE9->(DbSkip())
               EndDo
               If !lRet
                  MsgInfo(STR0106, STR0070)//STR0106	"Produto inválido." //STR0070	"Aviso"
                  Break
               EndIf
            EndIf
         EndIf
         EE9->(DbSetOrder(3))
         If EE9->(DbSeek(xFilial()+EEC->EEC_PREEMB+GdFieldGet("EXA_SEQEMB")))
            nQtde := EE9->EE9_SLDINI
            For nInc := 1 To Len(aCols)
               If nInc <> n .And. GdFieldGet("EXA_COD_I", nInc) == M->EXA_COD_I .And. GdFieldGet("EXA_SEQEMB", nInc) == GdFieldGet("EXA_SEQEMB", n) .And. !aCols[nInc][Len(aCols[nInc])]
                  nQtde -= GdFieldGet("EXA_QTDE", nInc)
               EndIf
            Next
            If nQtde > 0
               GdFieldPut("EXA_QTDE", nQtde)
            Else
               MsgInfo(STR0107,STR0001) //STR0107	"A sequência informada não possui saldo"
               GdFieldPut("EXA_SEQEMB", "")
               lRet := .F.
               Break
            EndIf
         Else
            MsgInfo(STR0108,STR0001) //STR0108	"Sequência inválida"
            lRet := .F.
            Break
         EndIf

      Case cCpo == "M->EXA_QTDE"
         If Empty(GdFieldGet("EXA_SEQEMB"))
            MsgInfo(STR0109,STR0001) //STR0109	"Informe o produto"
            lRet := .F.
         Else
            EE9->(DbSetOrder(3))
            If EE9->(DbSeek(xFilial()+EEC->EEC_PREEMB+GdFieldGet("EXA_SEQEMB", n)))
               nQtde := EE9->EE9_SLDINI
               For nInc := 1 To Len(aCols)
                  If nInc <> n .And. !aCols[nInc][Len(aCols[nInc])]
                     nQtde -= GdFieldGet("EXA_QTDE", nInc)
                  EndIf
               Next
            EndIf
            If (nQtde := Ae108GetQtd(nQtde,,,.T.)) > 0
               GdFieldPut("EXA_QTDE", nQtde)
            Else
               lRet:= .F.
            EndIf
         EndIf

   End Case

End Sequence

Return lRet

/*
Função      :
Parametros  :
Retorno     :
Objetivos   :
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Static Function GetCapacidade()

Return aEmbs

/*
Função      :
Parametros  :
Retorno     :
Objetivos   :
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Static Function AutoLotes(aLotes, cIdOri, aHeader, oProcess)
Local aOrd := SaveOrd(cWorkES)
Local nInc, nInc2
Local nLote, nProd, nSeqEmb, nQtde
Default oProcess := Nil

   If ValType(aHeader) == "A"
      nLote   := aScan(aHeader, {|x| x[2] == "EXA_LOTE"  })
      nProd   := aScan(aHeader, {|x| x[2] == "EXA_COD_I"  })
      nSeqEmb := aScan(aHeader, {|x| x[2] == "EXA_SEQEMB" })
      nQtde   := aScan(aHeader, {|x| x[2] == "EXA_QTDE"   })
   Else
      nLote   := 1
      nProd   := 2
      nSeqEmb := 3
      nQtde   := 4
   EndIf

   If ValType(aLotes) == "A" .And. Len(aLotes) > 0 .And. ValType(aLotes[1]) <> "A"
      aLotes := {aLotes}
   EndIf

   If ValType(oProcess) == "O"
      oProcess:SetRegua2(Len(aLotes))
   EndIf
   For nInc := 1 To Len(aLotes)
      If ValType(oProcess) == "O"
         oProcess:IncRegua2(StrTran(StrTran(STR0110, "XXX", AllTrim(Str(nInc))), "YYY", AllTrim(Str(Len(aLotes))))) //STR0110	"Incluindo lote de XXX de YYY."
      EndIf
      aProds := BuscaItens(cIdOri, aLotes[nInc][nProd], aLotes[nInc][nSeqEmb], cWorkES)
      For nInc2 := 1 To Len(aProds)
         If aLotes[nInc][nQtde] == 0
            Exit
         EndIf
         (cWorkES)->(DbGoTo(aProds[nInc2]))
         If Empty((cWorkES)->EYH_LOTE)
            aLotes[nInc][nQtde] -= Ae110EditLote(INCLUIR, cWorkES, aLotes[nInc][nLote], aLotes[nInc][nQtde], .T.)
         EndIf
      Next
   Next
   RestOrd(aOrd)

Return Nil

Static Function BuscaItens(cIDOri, cItem, cSeq, cWork)
Local aOrd := SaveOrd(cWork)
Local bCond := {|x, y, z| (x)->(!Eof()) .And. If(Empty(y), .T., ((x)->EYH_COD_I == y)) .And. If(Empty(z), .T., ((x)->EYH_SEQEMB == z)) }
Local aItens := {}, aItensEmb
Local nInc
Default cIDOri := ""
Default cItem  := ""
Default cSeq   := ""

   If Empty(cIdOri)
      (cWork)->(DbGoTop())
      If !Empty(cItem)
         (cWork)->(DbSetOrder(4))
         (cWork)->(DbSeek(cItem+cSeq))
      EndIf
      While Eval(bCond, cWork, cItem, cSeq)
         aAdd(aItens, (cWork)->(Recno()))
         (cWork)->(DbSkip())
      EndDo
   Else
      (cWork)->(DbSetOrder(3))
      (cWork)->(DbSeek(cIdOri))
      // BAK - Alteração para comparação da vinculação
      While (cWork)->(!Eof() .And. AllTrim(EYH_IDVINC) == AllTrim(cIdOri))
         If Empty((cWork)->EYH_COD_I) .And. Eval(bCond, cWork, cItem, cSeq)
            aItensEmb := BuscaItens((cWork)->EYH_ID, cItem, cSeq, cWork)
            For nInc := 1 To Len(aItensEmb)
               aAdd(aItens, aItensEmb[nInc])
            Next
         Else
            aAdd(aItens, (cWork)->(Recno()))
         EndIf
         (cWork)->(DbSkip())
      EndDo
   EndIf

RestOrd(aOrd, .T.)

Return aItens

/*
Função      :
Parametros  :
Retorno     :
Objetivos   :
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Static Function GetContNr(lSeek)
Local nNum := 1
Local aOrd := SaveOrd(cWorkEX9)
Local nTamCont := If(EECFlags("INTTRA"),17, AvSx3("EX9_CONTNR", AV_TAMANHO))

Default lSeek := .F.

   (cWorkEX9)->(DbGoTop())
   While (cWorkEX9)->(!Eof())
      If lSeek .And. AllTrim((cWorkEX9)->EX9_CONTNR) == AllTrim(M->EX9_CONTNR)
         Return (cWorkEX9)->EX9_CONTNR
      EndIf
      If Left(alltrim((cWorkEX9)->EX9_CONTNR),4) == "AAAA"
         If VAl(RIGHT(alltrim((cWorkEX9)->EX9_CONTNR),7)) > nNum
            nNum := VAl(RIGHT(alltrim((cWorkEX9)->EX9_CONTNR),7))
         EndIf
         ++nNum
      EndIf
      (cWorkEX9)->(DbSkip())
   EndDo

RestOrd(aOrd, .T.)
Return "AAAA" + StrZero(nNum, nTamCont -10) + space(6)

/*
Função      :
Parametros  :
Retorno     :
Objetivos   :
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Function Ae110Edit(nOpc)
Local cWork := Ae110Info("TREE_WORK")
Local cItem := GetItem(nOpc, cWork)
Local oTree := Ae110Info("TREE")
Local lOk := .T.
Local aOrd

Begin Sequence

   Do Case
      Case cItem == CONTAINER
         If nOpc == EXCLUIR
            aOrd := SaveOrd(cWorkES)
            (cWorkES)->(DbSetOrder(3))
            If !(lOk := !(cWorkES)->(DbSeek((cWorkES)->EYH_ID)))
               MsgInfo(STR0111, STR0001) //STR0111	"Container carregado. Só podem ser excluídos containers vazios." //STR0001	"Atenção"
            EndIf
            RestOrd(aOrd, .T.)
         EndIf
         If lOk
            Ae110EditCont(nOpc,,,.F.)
         EndIf

     Case cItem == PRE_CONTAINER
         If nOpc == EXCLUIR
            aOrd := SaveOrd(cWorkES)
            (cWorkES)->(DbSetOrder(3))
            If !(lOk := !(cWorkES)->(DbSeek((cWorkES)->EYH_ID)))
               MsgInfo(STR0112, STR0001)//STR0112	"Existem itens vinculados. Não será possível excluir."//STR0001	"Atenção"
            EndIf
            RestOrd(aOrd, .T.)
         EndIf
         If lOk
            Ae110EditCont(nOpc,,,.T.)
         EndIf

      Case cItem == LOTE
         Ae110EditLote(nOpc)

      Case cItem == CONTAINER+LOTE
         Ae110EditLote(nOpc)

      Case cItem == EMBALAGEM+LOTE
         Ae110EditLote(nOpc)

      Case cItem == EMBALAGEM+BASE+LOTE
         Ae110EditLote(nOpc)

      Case cItem == CONTAINER+EMBALAGEM
         If nOpc == INCLUIR
            Ae110IncEmb(nOpc)
         EndIf

      Case cItem == PRODUTO+LOTE
         Ae110EditLote(nOpc)

      Case cItem == PRODUTO
         MsgInfo(STR0113, STR0070)//STR0113	"Produto não possui lote para manutenção."//STR0070	"Aviso"

      Case cItem == EMBALAGEM
         If nOpc == INCLUIR
            Ae110IncEmb(nOpc)
         Else

            // FDR - 19/05/11
            // Incluido a função EditEmb para que seja possivel inserir uma marcação na embalagem na mercadoria nao estufada.
            If lMarcacao
               EditEmb(cWork, oTree)
            Else
               MsgInfo(STR0114, STR0070) //STR0114	"Não é possível excluir/alterar a embalagem."//STR0070	"Aviso"
            EndIf
         EndIf

      Case cItem == EMBALAGEM+BASE
         If nOpc == EXCLUIR
            MsgInfo(STR0115, STR0070) //STR0115	"Não é possível excluir embalagens."//STR0070	"Aviso"

         ElseIf nOpc == INCLUIR
            Ae110IncEmb(nOpc)
         Else
            EditEmb(cWork, oTree)
         EndIf

   End Case

End Sequence

Return lOk

/*
Função      :
Parametros  :
Retorno     :
Objetivos   :
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Static Function GetItem(nOpc, cWork)
Local oDlgInc
Local lOk := .T.
Local nCol := 10, nLinDlg := 80, nColDlg := 325, nTamBut := 45, nLin := 16
Local nRecno := Ae110Info("TREE_RECNO")
Local bOpc   := {|x| If(cOpc <> x, cOpc += x,) }
Local lContainer := .F., lLote := .T., lEmbalagem := .T.
Private cOpc := ""

   If EECFlags("PRE-CONTAINER")
      nColDlg += 95
   EndIf

   (cWork)->(DbGoTo(nRecno))
   Do Case
      Case (cWork)->(Eof()) .And. nOpc == INCLUIR//Raiz do Tree
         cOpc := CONTAINER
         lContainer := .T.
         lLote := .F.
         lEmbalagem := .F.
      Case (cWork)->WK_ISCONT == "S"
         cOpc := CONTAINER
         lContainer := .T.
      Case !Empty((cWork)->EYH_LOTE)
         cOpc := LOTE
         lEmbalagem := .F.
      Case !Empty((cWork)->EYH_COD_I) .And. nOpc == INCLUIR
         cOpc := PRODUTO
         lEmbalagem := .F.
      Otherwise
         cOpc := EMBALAGEM
         If IsNivelBase(cWork)
            cOpc := EMBALAGEM+BASE
         EndIf
         If cWork <> cWorkES
            lEmbalagem := .F.
         EndIf
   EndCase

   If nOpc == INCLUIR
      lOk := .F.

      Define MsDialog oDlgInc Title STR0116 From 0,0 To nLinDlg, nColDlg Pixel Of oDlg //STR0116	"Inclusão"

         @  2,  2 To (nLinDlg/2)-1, (nColDlg/2)-1 LABEL STR0117 Pixel //	STR0117	"O que deseja incluir ?"
         If EECFlags("PRE-CONTAINER")
            @ nLin, nCol Button cDesPreCon Size nTamBut,12 When lContainer Action (cOpc := "", Eval(bOpc, PRE_CONTAINER), lOk := .T., oDlgInc:End()) Of oDlgInc Pixel
            nCol += nTamBut + 5
         EndIf
         @ nLin, nCol Button STR0118 Size nTamBut,12 When lContainer Action (Eval(bOpc, CONTAINER), lOk := .T., oDlgInc:End()) Of oDlgInc Pixel //STR0118	"Container"
         nCol += nTamBut + 5
         @ nLin, nCol Button STR0052 Size nTamBut,12 When lLote Action (Eval(bOpc, LOTE), lOk := .T., oDlgInc:End()) Of oDlgInc Pixel //STR0052	"Lote: "
         nCol += nTamBut + 5
         @ nLin, nCol Button STR0053 Size nTamBut,12 When lEmbalagem Action (Eval(bOpc, EMBALAGEM), lOk := .T., oDlgInc:End()) Of oDlgInc Pixel //STR0053	"Embalagem: "

      Activate MsDialog oDlgInc Centered

   EndIf

   If !lOk
      cOpc := ""
   EndIf

Return cOpc

Static Function IsNivelBase(cWork)
Local aOrd := SaveOrd(cWork)
Local lRet := .F.

   If (cWork)->EYH_IDVINC $ cZero+"/"+cZeroCont+"/"+cZeroPreC
      lRet := .T.
   Else
      (cWork)->(DbSetOrder(1))
      If (cWork)->(DbSeek(EYH_IDVINC)) .And. (cWork)->WK_ISCONT == "S"
         lRet := .T.
      EndIf
   EndIf

RestOrd(aOrd, .T.)
Return lRet

Static Function EditEmb(cWork, oTree)
Local lIsPallet := (cWork)->EYH_PLT == "S"
Local lOk := .F.
Local cCargo := oTree:GetCargo()
Local oDlg
Local bOk := {|| lOk := .T., oDlg:End() }
Local bCancel := {|| oDlg:End() }
Local nAltura   := 18 //15    *** GFP - 15/09/2011 - Ajuste de janela para versão 11.5
Local nComprim  := 48 //45    *** GFP - 15/09/2011 - Ajuste de janela para versão 11.5
Local cMemoMarc := ""
Local cMarcacao := ""
Local oMarcacao
Local cTexto    := ""
Local aOrd := SaveOrd({"EY2","EXZ"})

   // Tratamento para o campo de marcação da embalagem - BAK - 27 de Janeiro 2011
   If lMarcacao
      nAltura := nAltura + 10
      cMemoMarc := (cWork)->EYH_MARCAC
      cMarcacao := cMemoMarc
   EndIf

   Define MsDialog oDlg Title STR0119 From 9,0 To nAltura,nComprim Of oMainWnd //	STR0119	"Edição do Item"

      oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //LRS
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      @ 13, 05 To 42,176 LABEL STR0120 Pixel of oPanel //STR0120	"Tipo da Embalagem"
      TCheckBox():New(25, 30, "Pallet", &("{|u| If(pCount() > 0, M->lIsPallet := u, M->lIsPallet)}"), oPanel, 30, 08,;
                      ,,,,,,, .T., STR0096)//STR0096	"Mensagem"
      If lMarcacao // BAK - 27 de Janeiro de 2011
         @ 43, 05 To  92,176 LABEL STR0121 Of oPanel Pixel//STR0121	"Marcação"
         @ 51, 07 Get oMarcacao Var cMemoMarc MEMO HSCROLL Size 167,38 Of oPanel Pixel
           oMarcacao:EnableVScroll(.T.)
           oMarcacao:EnableHScroll(.T.)
      EndIf

   Activate MsDialog oDlg Centered On Init EnchoiceBar(oDlg, bOk, bCancel)

   If lOk
      (cWork)->EYH_PLT := If(lIsPallet, "S", "N")
      Eval(oTree:bChange)
      ChangeImg(cWork, (cWork)->(Recno()),, oTree)
      AtuImgNivel(cWork, oTree, lIsPallet)
      oTree:TreeSeek(cCargo)
      Eval(oTree:bChange)

      If lMarcacao // BAK - 01 de Fevereiro de 2011
         (cWork)->(RecLock((cWork),.F.))
         (cWork)->EYH_MARCAC := cMemoMarc
         (cWork)->(MsUnLock())

         If !(cMemoMarc == cMarcacao) .And. lQuebraOIC
            cTexto := STR0122 +; //	STR0122	"Deseja salvar a alteração da marcação do OIC "
                      SubStr((cWork)->EYH_CHAVE,1,AVSX3("EXZ_OIC",AV_TAMANHO))+;
                      STR0123 + SubStr((cWork)->EYH_CHAVE,AVSX3("EXZ_OIC",AV_TAMANHO)+AVSX3("EXZ_SAFRA",AV_TAMANHO),Len((cWork)->EYH_CHAVE))+ " ?" + Replic(ENTER,2) +; //STR0123	" item "
                      STR0124 //STR0124	"Obs.: Caso positivo a marcação será salvo na rotina de Manutenção do OIC."
            If MsgYesNo(cTexto,STR0001)//STR0001	"Atenção"
               EY2->(DBSetOrder(1))
               If EY2->(DbSeek(xFilial("EY2")+EEC->EEC_PREEMB + (cWork)->EYH_CHAVE))
                  If EY2->(RecLock("EY2",.F.))
                     MSMM(EY2->EY2_CODMAR,,,,EXCMEMO)
                     MSMM(,AVSX3("EY2_MARCAC",AV_TAMANHO),,cMemoMarc,INCMEMO,,,"EY2","EY2_CODMAR")
                     EY2->(MsUnlock())
                  EndIf
                  MsgInfo(STR0125, STR0001)//	STR0125	"A marcação foi salva com sucesso na Manutenção do OIC."//STR0001	"Atenção"               EndIf
               EndIf
            EndIf
         EndIf

         Eval(oTree:bChange)
      EndIf

   EndIf

RestOrd(aOrd)

Return

Static Function AtuImgNivel(cWork, oTree, lisPallet)
Local aOrd := SaveOrd(cWork)
Local cId := (cWork)->EYH_ID

   (cWork)->(DbSetOrder(3))
   (cWork)->(DbSeek(cId))
   // BAK - Alteração para comparação da vinculação
   While (cWork)->(!Eof() .And. AllTrim(EYH_IDVINC) == AllTrim(cId))
      oTree:TreeSeek(Ae110Info("WORK_CARGO", cWork))
      ChangeImg(cWork, (cWork)->(Recno()),, oTree,,, lIsPallet)
      (cWork)->(DbSkip())
   EndDo

RestOrd(aOrd, .T.)
Return

/*
Função      :
Parametros  :
Retorno     :
Objetivos   :
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Function Ae110EditLote(nOpc, cWork, cLote, nQtde, lAuto)
Local oDlg
Local bOk := {|| If(Positivo(nQtde - 1), (lOk := .T., oDlg:End()), ) }
Local bCancel := {|| oDlg:End() }
Local lOk := .F.
Local lWhen := nOpc == INCLUIR .Or. nOpc == ALTERAR
Local cTitulo := STR0126 //STR0126 "Manutenção de Lotes"
Local cLoteAtu
Local lEmbalagem

Default cWork := Ae110Info("TREE_WORK")
Default cLote := Space(AvSx3("EXA_LOTE", AV_TAMANHO))

Begin Sequence

   lEmbalagem := Empty((cWork)->EYH_COD_I)

   If cWork <> cWorkES
      MsgInfo(STR0127, STR0070)//	STR0127	"Somente itens estufados podem conter lotes" //STR0070	"Aviso"
      Break
   EndIf

   If ValType(nQtde) <> "N"
      If lEmbalagem
         nQtde := 0
      Else
         nQtde := (cWork)->EYH_QTDEMB
      EndIf
   EndIf
   If nOpc <> INCLUIR
      cLote := (cWork)->EYH_LOTE
   EndIf

   If lAuto
      lOk := .T.
   Else
      DEFINE MSDIALOG oDlg TITLE cTitulo FROM 1,1 To 188,321 OF oMainWnd Pixel  //DFS - 28/02/2012 - Alteração do tamanho da dialog para não cortar na versão 11.5

         oPanel:= TPanel():New(0, 0, "", oDLG,, .F., .F.,,, 90, 165) //MCF - 14/09/2015
         oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

         @ 14, 4 To 48,158 Label STR0033 Pixel Of oPanel  //STR0033	"Informações" //DFS - 28/02/2012 - Alteração do tamanho da label de informações
         @ 23,10 Say STR0052 Pixel Of oPanel //STR0052	"Lote: "
         @ 22,60 MsGet cLote Size 70,07 When lWhen Pixel Of oPanel
         @ 35,10 Say STR0055 Pixel Of oPanel //STR0055	"Quantidade: "
         @ 34,60 MsGet nQtde  Size 70,07 Picture "@E 999,999,999,999.99" Valid Positivo(nQtde - 1) When lWhen Pixel Of oPanel

      Activate MsDialog oDlg ON INIT EnchoiceBar(oDlg, bOk, bCancel) Centered
   EndIf

   If lOk
      If lEmbalagem
         AutoLotes({cLote,,, nQtde}, (cWork)->EYH_ID)
      Else
         If (nOpc == INCLUIR) .Or. (nOpc == ALTERAR)
            If (cWork)->EYH_QTDEMB > nQtde
               nSaldo := (cWork)->EYH_QTDEMB - nQtde
            Else
               nSaldo   := 0
               nQtde    := (cWork)->EYH_QTDEMB
            EndIf
            If nOpc == INCLUIR
               cLoteAtu := (cWork)->EYH_LOTE
               (cWork)->EYH_LOTE   := cLote
            Else
               cLoteAtu := ""
            EndIf
            (cWork)->EYH_QTDEMB := nQtde
            Ae110Info("TREE"):TreeSeek(Ae110Info("WORK_CARGO", cWork))
            Eval(Ae110Info("TREE"):bChange)
            Ae110Info("TREE"):ChangePrompt(Ae110Info("WORK_DESC", cWork))
            Ae110Info("TREE"):Refresh()
         ElseIf nOpc == EXCLUIR
            nSaldo := (cWork)->EYH_QTDEMB
            cLoteAtu := ""
            If Empty(cEmptyLeaf := FindEmptyLeaf(cWork, (cWork)->EYH_ID))
               AtuLeaf(Ae110Info("TREE"), cWork, Ae110Info("WORK_CARGO", cWork),, "")
               Break
            Else
               nSaldo := (cWork)->EYH_QTDEMB
               (cWork)->EYH_QTDEMB := 0
               AtuLeaf(Ae110Info("TREE"), cWork, Ae110Info("WORK_CARGO", cWork), 0)
               (cWork)->(DbSeek(cEmptyLeaf))
               AtuLeaf(Ae110Info("TREE"), cWork, Ae110Info("WORK_CARGO", cWork), (cWork)->EYH_QTDEMB + nSaldo)
               Break
            EndIf
         EndIf

         If nSaldo > 0
            RegToMemory(cWork, .F., .F.)
            (cWork)->(DbAppend())
            AvReplace("M", cWork)
            (cWork)->EYH_ID     := Ae110NewId()
            (cWork)->EYH_LOTE   := cLoteAtu
            (cWork)->EYH_QTDEMB := nSaldo
            (cWork)->WK_RECNO   := 0
            Ae110Info("TREE"):TreeSeek(Ae110Info("WORK_CARGO_PAI", cWork))
            cImg := GetImgTree(cWork)
            cNewCargo := cWork + StrZero((cWork)->(Recno()), 10)
            cNewDesc  := Ae110Info("WORK_DESC", cWork)
            Ae110Info("TREE"):AddItem(cNewDesc, cNewCargo, cImg, cImg,,, 2)
            Ae110Info("TREE"):TreeSeek(cNewCargo)
            Ae110Info("TREE"):Refresh()
            Ae110Info("TREE"):SetFocus()
         EndIf
      EndIf
   EndIf

End Sequence

Return nQtde

Static Function FindEmptyLeaf(cWork, cId)
Local aOrd := SaveOrd(cWork)
Local cIdVinc := (cWork)->EYH_IDVINC
Local cEmptyLeaf := ""

   (cWork)->(DbSetOrder(3))
   If (cWork)->(DbSeek(cIdVinc))
      // BAK - Alteração para comparação da vinculação
      While (cWork)->(!Eof() .And. AllTrim(EYH_IDVINC) == AllTrim(cIdVinc))
         If Empty((cWork)->EYH_LOTE) .And. AllTrim((cWork)->EYH_ID) <> AllTrim(cId)
            cEmptyLeaf := (cWork)->EYH_ID
            Exit
         EndIf
         (cWork)->(DbSkip())
      EndDo
   EndIf

RestOrd(aOrd, .T.)
Return cEmptyLeaf

/*
Função      :
Parametros  :
Retorno     :
Objetivos   :
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Function Ae110EditCont(nOpc, aAuto, lAuto, lPreCont)
Local cCargo, cNewCargo, cNewDesc, cImg, cID, cDest
Local xRet
Private aAutoEX9 := {}
Default lPreCont := .F.

   If ValType(aAuto) == "A"
      aEval(aAuto, {|x| aAdd(aAutoEX9, x)})
   EndIf
   If ValType(lAuto) == "L"
      Private lAutoEX9 := lAuto
   EndIf
   If nOpc <> INCLUIR
      (cWorkEX9)->(DbGoTo((cWorkES)->WK_RECNO))
      EX9->(DbGoTo((cWorkEX9)->WK_RECNO))
      cCargo := Ae110Info("TREE_CARGO")
      cId := (cWorkEX9)->EX9_ID
      nRecnoEX9 := (cWorkEX9)->WK_RECNO
   Else
      aAdd(aAutoEX9, {"EX9_CONTNR", GetContNr()})
      aAdd(aAutoEX9, {"EX9_ID", Ae110NewId()})
      If EECFlags("PRE-CONTAINER")
         If aScan(aAutoEX9, {|x| x[1] == "EX9_PRECON" }) > 0
            lPreCont := (aAutoEX9[aScan(aAutoEX9, {|x| x[1] == "EX9_PRECON" })][2] $ cSim)
         Else
            If lPreCont
              aAdd(aAutoEX9, {"EX9_PRECON", "1"})
            Else
              aAdd(aAutoEX9, {"EX9_PRECON", "2"})
            EndIf
         EndIf
      EndIf
   EndIf

   If Ae110Cont(cWorkEX9, 0, nOpc, oDlg)
      If EECFlags("PRE-CONTAINER")
         lPreCont := ((cWorkEX9)->EX9_PRECON $ cSim)
      EndIf
      If lPreCont
         cDest := cZeroPreC
      Else
         cDest := cZeroCont
      EndIf
      If nOpc == INCLUIR
         (cWorkES)->(DbAppend())
         (cWorkES)->EYH_PREEMB := (cWorkEX9)->EX9_PREEMB
         (cWorkES)->EYH_CODEMB := (cWorkEX9)->EX9_CONTNR
         (cWorkES)->EYH_QTDEMB := 1
         (cWorkES)->EYH_ESTUF  := "S"
         (cWorkES)->EYH_ID     := aAutoEX9[aScan(aAutoEX9, {|x| x[1] == "EX9_ID" })][2]
         (cWorkES)->EYH_IDVINC := cDest
         (cWorkES)->WK_RECNO   := (cWorkEX9)->(Recno())
         (cWorkES)->WK_ISCONT  := "S"

         cNewCargo := cWorkES + StrZero((cWorkES)->(Recno()), 10)
         cNewDesc  := Ae110Info("WORK_DESC", cWorkES)

         If oTreeES:TreeSeek(If(cDest == cZeroPreC, "PREC", "CONT"))
            cImg := GetImgTree(cWorkES)
            oTreeES:AddItem(cNewDesc, cNewCargo, cImg, cImg,,, 2)
            oTreeES:TreeSeek(cNewCargo)
            oTreeES:Refresh()
            oTreeES:SetFocus()
         EndIf
         xRet := (cWorkES)->(Recno())

      ElseIf nOpc == ALTERAR
         (cWorkES)->EYH_CODEMB := (cWorkEX9)->EX9_CONTNR
         (cWorkES)->EYH_QTDEMB := 1

         oTreeES:ChangePrompt(Ae110Info("WORK_DESC", cWorkES))
         Ae110CTree("ES", Ae110Info("WORK_CARGO", cWorkES), @cMemoES)

      ElseIf nOpc == EXCLUIR
         If nRecnoEX9 > 0
            aAdd(aDeletados, {"EX9", nRecnoEX9})
         EndIf
         (cWorkES)->(DbSetOrder(1))
         If (cWorkES)->(DbSeek(cID))
            If oTreeES:TreeSeek(cCargo)
               oTreeES:DelItem()
               oTreeES:Refresh()
               oTreeES:SetFocus()
            EndIf
            (cWorkES)->(DbDelete())
         EndIf
      EndIf

   EndIf

Return xRet

/*
Função      : Ae110Cont()
Parametros  :
Retorno     :
Objetivos   :
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Function Ae110Cont(cAlias, nReg, nOpc, oDlgPai)
Local oDlg
Local bCancel := {|| oDlg:End() }
Local bOk     := {|| If(lOk := (Obrigatorio(aGets,aTela) .And. Ae110VldCont("EX9_CONTNR")), oDlg:End(), )}
Local nInc
Local cCadastro := STR0128 //STR0128 "Cadastro de Container"
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
                     "EX9_SICOM",;
                     "EX9_SIRINS",;
                     "EX9_BLNUM",;
                     "EX9_TIPOBL",;
                     "EX9_QTDBL",;
                     "EX9_QTDBLC",;
                     "EX9_BLCLA1",;
                     "EX9_BLCLM1",;
                     "EX9_BLCLA2",;
                     "EX9_BLCLM2",;
                     "EX9_BLCLA3",;
                     "EX9_BLCLM3"}
Private nSelecao := nOpc//Utilizada na função Ae103ValDet()
Private aGets := {}, aTela := {}
Private lOk := .F.
Private aCamposEnchoice := {}

Default cAlias := "EX9"
Default nReg   := 0
Default nOpc   := INCLUIR
Default oDlgPai := oMainWnd

Begin Sequence

   If nOpc == INCLUIR
      RegToMemory("EX9", .T.)
   Else
      For nInc := 1 To (cAlias)->(FCount())
         M->&((cAlias)->(FieldName(nInc))) := (cAlias)->(FieldGet(nInc))
      Next
      SX3->(DbSetOrder(1))
      SX3->(DbSeek("EX9"))
      While SX3->(!Eof() .And. X3_ARQUIVO == "EX9")
         If SX3->X3_CONTEXT == "V"
            M->&(SX3->X3_CAMPO) := CriaVar(SX3->X3_CAMPO)
         EndIf
         SX3->(DbSkip())
      EndDo
   EndIf

   If nOpc <> INCLUIR
      For nInc := 1 To Len(aMemosEX9)
         M->&(aMemosEX9[nInc][2]) := MSMM((cAlias)->&(aMemosEX9[nInc][1]), AVSX3(aMemosEX9[nInc][2])[AV_TAMANHO])
      Next
   EndIf

   If nOpc == INCLUIR
      M->EX9_FILIAL := xFilial("EX9")
      M->EX9_PROCES := EEC->EEC_PEDREF
      M->EX9_PREEMB := EEC->EEC_PREEMB
   EndIf

   If Type("aAutoEx9") == "A"
      For nInc := 1 To Len(aAutoEx9)
         Eval(MemVarBlock(aAutoEx9[nInc][1]), aAutoEx9[nInc][2])
      Next
   EndIf

   If EECFlags("PRE-CONTAINER") .And. (M->EX9_PRECON $ cSim)
      cCadastro := "Cadastro de " + cDesPreCon
   EndIf

   SX3->(DbSeek("EX9"))
   While SX3->(!Eof() .And. X3_ARQUIVO == "EX9")
      If X3Uso(SX3->X3_USADO)
         If EECFlags("PRE-CONTAINER") .And. (M->EX9_PRECON $ cSim) .And. !(SX3->X3_CAMPO $ "EX9_PREEMB/EX9_CONTNR/EX9_VM_OBS")
            SX3->(DbSkip())
            Loop
         EndIf
         If !EECFlags("INTTRA") .And. aScan(aCpoInttra, {|x| IncSpace(x, 10, .F.) == SX3->X3_CAMPO}) > 0
            SX3->(DbSkip())
            Loop
         EndIf
         If SX3->X3_CAMPO == IncSpace("EX9_PREEMB", 10, .F.)
            SX3->(DbSkip())
            Loop
         EndIf
         If EECFlags("INTTRA") .And. SX3->X3_CAMPO == IncSpace("EX9_TIPCON", 10, .F.)
            SX3->(DbSkip())
            Loop
         EndIf
         aAdd(aCamposEnchoice, SX3->X3_CAMPO)
      EndIf
      SX3->(DbSkip())
   EndDo

   If EasyEntryPoint("EECAE110")
      ExecBlock("EECAE110", .F., .F., "CONTAINER_ANTES_DIALOG")
   EndIf

   If Type("lAutoEX9") == "L" .And. lAutoEX9
      lOk := .T.
   Else
      DEFINE MSDIALOG oDlg TITLE cCadastro FROM 0, 0;
                                             TO DLG_LIN_FIM * 0.8, DLG_COL_FIM * 0.8 OF oDlgPai PIXEL

         //EnChoice("EX9", nReg, nOpc,,,, aCamposEnchoice, PosDlg(oDlg))
         MsmGet():New("EX9",nReg,nOpc,,,,aCamposEnchoice,;
                             {PosDlg(oDlg)[1], PosDlg(oDlg)[2], PosDlg(oDlg)[3]-5, PosDlg(oDlg)[4]},,,,,,;
                             oDlg)

      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bOk, bCancel) CENTERED
   EndIf

   If lOk

      If nOpc <> VISUALIZAR

         Begin Transaction
            (cAlias)->(RecLock(cAlias, nOpc == INCLUIR))

            For nInc := 1 To Len(aMemosEX9)
               If (cAlias)->(FieldPos(aMemosEX9[nInc][1])) > 0
                  MSMM((cAlias)->&(aMemosEX9[nInc][1]),,,,EXCMEMO)
               EndIf
            Next

            If nOpc <> EXCLUIR
               AvReplace("M", cAlias)

               For nInc := 1 To Len(aMemosEX9)
                  If (cAlias)->(FieldPos(aMemosEX9[nInc,1])) > 0
                     (cAlias)->(MSMM((cAlias)->&(aMemosEX9[nInc,1]),AvSx3(aMemosEX9[nInc,2],AV_TAMANHO),,(cAlias)->&(aMemosEX9[nInc,2]),INCMEMO,,,cAlias,aMemosEX9[nInc,1]))
                  EndIf
               Next

            Else
               (cAlias)->(DbDelete())
            EndIf
            (cAlias)->(MsUnlock())

         End Transaction
      EndIf

   EndIf

End Sequence

Return lOk

/*
Função      : Ae110VldCont(cCpo)
Parametros  : cCpo - Campo a ser validado.
Retorno     : lRet
Objetivos   : Validar campos da manutenção de container.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Function Ae110VldCont(cCpo)
Local lRet := .T.

Default cCpo := ""

   Do Case
      Case cCpo == "EX9_CONTNR" .AND. nOpc <> INCLUIR
         If Empty(M->EX9_CONTNR)
            MsgInfo(STR0129, STR0001) //STR0129	"O preenchimento do código é obrigatório" //STR0001	"Atenção"
            lRet := .F.
         EndIf
         If EECFlags("INTTRA")
            If Len(AllTrim(M->EX9_CONTNR)) > 17
               MsgInfo(STR0130, STR0070)//STR0130	"Em ambientes integrados com o Inttra, o código do container deve ser tamanho máximo de 17 caracteres." //STR0070	"Aviso"
               lRet := .F.
            EndIf
            //JVR - Validar numero container.
            If GetContNr(.T.) <> M->EX9_CONTNR
               lRet := VLDNumCont(M->EX9_CONTNR)
            Else
               lRet := VLDNumCont(M->EX9_CONTNR, .F.)
            EndIf
         EndIf
   EndCase

Return lRet

/*
Função      :
Parametros  :
Retorno     :
Objetivos   :
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Function Ae110AtuPeso(cAlias, cChave, cIdIni)
Local lBase := .F.
Local aOrd := SaveOrd(cAlias)
Default cChave := ""
Default cAlias := "EYH"

   If cAlias == "EYH"
      lBase := .T.
   EndIf

   (cAlias)->(DbSetOrder(3))
   (cAlias)->(DbSeek(If(lBase, cChave, "")+cIdIni))
   // BAK - Alteração para comparação da vinculação
   While (cAlias)->(!Eof() .And. If(lBase, EYH_FILIAL+EYH_ESTUF+EYH_PREEMB, "")+AllTrim(EYH_IDVINC) == cChave+AllTrim(cIdIni))
      If cAlias == "WK_ES" .And. cIdIni == cZeroCont
         (cAlias)->EYH_PSLQUN:=0
         (cAlias)->EYH_PSBRUN:=0
         (cAlias)->EYH_PSLQTO:=0
         (cAlias)->EYH_PSBRTO:=0
      EndIf
      AtuPesoEmb(cAlias, lBase)
      (cAlias)->(DbSkip())
   EndDo

RestOrd(aOrd, .T.)
Return

/*
Função      :
Parametros  :
Retorno     :
Objetivos   :
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/08/07
*/
Static Function AtuPesoEmb(cAlias, lBase)
Local nPesBrTo := 0, nPesBrUn := 0
Local nRecno, nInc
Local cChave := If(lBase, (cAlias)->(EYH_FILIAL+EYH_ESTUF+EYH_PREEMB+AllTrim(EYH_ID)), AllTrim((cAlias)->EYH_ID)) // BAK - Alteração para comparação da vinculação
Local aItens := {}

   nRecno := (cAlias)->(Recno())

   If lBase
      RecLock(cAlias, .F.)
   EndIf

   //(cAlias)->EYH_PSLQTO := ((cAlias)->EYH_QTDEMB * (cAlias)->EYH_RELSUP) * (cAlias)->EYH_PSLQUN
   (cAlias)->EYH_PSLQTO := (cAlias)->EYH_QTDEMB * (cAlias)->EYH_PSLQUN

   If lBase
      (cAlias)->(MsUnlock())
   EndIf

   nPesBrTo += (cAlias)->EYH_PSLQTO

   (cAlias)->(DbSetOrder(3))
   (cAlias)->(DbSeek(cChave))
   // BAK - Alteração para comparação da vinculação
   While (cAlias)->(!Eof() .And. If(lBase, EYH_FILIAL+EYH_ESTUF+EYH_PREEMB, "")+AllTrim(EYH_IDVINC) == cChave)
      If !Empty((cAlias)->EYH_COD_I)
         aAdd(aItens, (cAlias)->(Recno()))
      EndIf
      nPesBrTo += AtuPesoEmb(cAlias, lBase)
      (cAlias)->(DbSkip())
   EndDo

   (cAlias)->(DbGoTo(nRecno))

   //nPesBrUn := nPesBrTo / ((cAlias)->EYH_QTDEMB * (cAlias)->EYH_RELSUP)
   nPesBrUn := nPesBrTo / (cAlias)->EYH_QTDEMB

   If lBase
      RecLock(cAlias, .F.)
   EndIf
   (cAlias)->EYH_PSBRTO := nPesBrTo
   (cAlias)->EYH_PSBRUN := nPesBrUn

   //Nos containers não tratamos o peso líquido, portanto sempre assume o peso bruto.
   If (cAlias)->(FieldPos("WK_ISCONT")) > 0 .And. (cAlias)->WK_ISCONT == "S"
      (cAlias)->EYH_PSLQUN := nPesBrUn
      (cAlias)->EYH_PSLQTO := nPesBrTo
   EndIf

   If lBase
      (cAlias)->(MsUnlock())
   EndIf

   For nInc := 1 To Len(aItens)
      (cAlias)->(DbGoTo(aItens[nInc]))
      If lBase
         RecLock(cAlias, .F.)
      EndIf
      (cAlias)->EYH_PSBRTO := nPesBrTo
      (cAlias)->EYH_PSBRUN := nPesBrUn
      If lBase
         (cAlias)->(MsUnlock())
      EndIf
   Next

   (cAlias)->(DbGoTo(nRecno))

Return nPesBrTo

Function Ae110Int(aInt, cAlias, cOpc)
Local nInc
Local lErro := .F.
Local cMsg := ""
Local aOrd := SaveOrd("SX3")

Begin Sequence

   If ValType(aInt) == "A" .And. Len(aInt) > 0
      If ValType(aInt[1]) == "A" .And. Len(aInt[1]) > 0 .And. ValType(aInt[1][1]) == "C"
         aInt := {aInt}
      ElseIf ValType(aInt[1]) == "A" .And. Len(aInt[1]) > 0 .And. ValType(aInt[1][1]) <> "A"
         lErro := .T.
         cMsg += STR0131 + ENTER //	STR0131	"Erro na estrutura dos dados de integração"
      EndIf

      For nInc := 1 To Len(aInt)
         cMsg += ValReg(cAlias, aInt[nInc])
      Next
      If Empty(cMsg)
         For nInc := 1 To Len(aInt)
            cMsg += IncReg(cAlias, aInt[nInc])
         Next
      EndIf
   EndIf

End Sequence

RestOrd(aOrd, .T.)
Return cMsg

Static Function IncReg(cAlias, aRegistro)
Local cMsg := ""
Local nInc

   For nInc := 1 To Len(aRegistro)
      M->&(aRegistro[nInc][1]) := aRegistro[nInc][2]
   Next
   SX3->(DbSeek(cAlias))
   While SX3->(!Eof() .And. cAlias == X3_ARQUIVO)
      If Type(SX3->X3_CAMPO) = "U"
         M->&(SX3->X3_CAMPO) := CriaVar(SX3->X3_CAMPO)
      EndIf
      SX3->(DbSkip())
   EndDo

   (cAlias)->(RecLock(cAlias, .T.))
   AvReplace("M", cAlias)
   (cAlias)->(MsUnlock())

Return cMsg

Static Function ValReg(cAlias, aRegistro)
Local cMsg := ""
Local nInc
Local bRegistro
Local aOrd, aCposChave

Begin Sequence

   For nInc := 1 To Len(aRegistro)
      M->&(aRegistro[nInc][1]) := aRegistro[nInc][2]
   Next

   Do Case
      Case cAlias == "EX9"
         bRegistro := {|| STR0132      + If(Type("M->EX9_FILIAL") = "U", STR0133, M->EX9_FILIAL);//	STR0132	"Filial:" //STR0133	"Não Informado"
                        + STR0134  + If(Type("M->EX9_PREEMB") = "U", STR0133, M->EX9_PREEMB); //STR0134	" Embarque: "      //STR0133	"Não Informado"
                        + STR0118 + If(Type("M->EX9_CONTNR") = "U", STR0133, M->EX9_CONTNR) + ENTER } //STR0118	Container   //STR0133	"Não Informado"

         aCposChave := {"EX9_FILIAL", "EX9_PREEMB", "EX9_CONTNR", "EX9_ID"}
         If Empty(cMsg += ValChave(aCposChave, bRegistro))
            aOrd := SaveOrd({"EEC", "EX9"})
            EEC->(DbSetOrder(1))
            EX9->(DbSetOrder(1))
            If !EEC->(DbSeek(M->EX9_FILIAL+M->EX9_PREEMB))
               cMsg += Eval(bRegistro) + STR0135 + ENTER //STR0135	"'O embarque não existe no sistema.'"
            EndIf
            If EX9->(DbSeek(M->EX9_FILIAL+M->EX9_PREEMB+M->EX9_CONTNR))
               cMsg += Eval(bRegistro) + STR0136 + ENTER //STR0136	"'O container informado já existe neste embarque.'"
            EndIf
         EndIf

      Case cAlias == "EYH"
         bRegistro := {|| STR0132     + If(Type("M->EYH_FILIAL") = "U", STR0133, M->EYH_FILIAL);//STR0132	"Filial:" //STR0133	"Não Informado"
                        + STR0134 + If(Type("M->EYH_PREEMB") = "U", STR0133, M->EYH_PREEMB);//STR0134	" Embarque: "//STR0133	"Não Informado"
                        + STR0137       + If(Type("M->EYH_ID"    ) = "U", STR0133, M->EYH_ID) + ENTER } //	STR0137	"ID"//STR0133	"Não Informado"
         aCposChave := {"EYH_FILIAL", "EYH_PREEMB", "EYH_ID"}
         If Empty(cMsg += ValChave(aCposChave, bRegistro))
           aOrd := SaveOrd({"EEC", "EYH"})
            EEC->(DbSetOrder(1))
            EYH->(DbSetOrder(1))
            If !EEC->(DbSeek(M->EYH_FILIAL+M->EYH_PREEMB))
               cMsg += Eval(bRegistro) + STR0135 + ENTER//STR0135	"'O embarque não existe no sistema.'"
            EndIf
            If EYH->(DbSeek(M->EYH_FILIAL+"S"+M->EYH_PREEMB+M->EYH_ID)) .Or. EYH->(DbSeek(M->EYH_FILIAL+"N"+M->EYH_PREEMB+M->EYH_ID))
               cMsg += Eval(bRegistro) + STR0138 + ENTER //STR0138	"'O ID do registro já existe neste embarque.'"
            EndIf
         EndIf

   EndCase

End Sequence

If ValType(aOrd) == "A"
   RestOrd(aOrd, .T.)
EndIf

Return cMsg

Static Function ValChave(aCposChave, bRegistro)
Local cMsg := ""
Local nInc

   For nInc := 1 To Len(aCposChave)
      If Type(aCposChave[nInc]) = "U" .Or. (!("FILIAL" $ aCposChave[nInc]) .And. Empty(M->&(aCposChave[nInc])))
         cMsg += StrTran(StrTran(STR0139, "XXX", aCposChave[nInc]), "YYY", AvSx3(aCposChave[nInc], AV_TITULO)) + ENTER //STR0139	"O campo 'XXX' (YYY) não foi informado."
      EndIf
   Next
   If !Empty(cMsg)
      cMsg := Eval(bRegistro) + cMsg
   EndIf

Return cMsg

/*
Função     : AltPrefs
Parâmetros : Nenhum
Retorno    : Nenhum
Objetivos  : Exibe tela com opções de personalização da rotina, possibilitando a alteração do conteúdo dos parâmetros.
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 13/10/08
Revisao    :
Obs.       :
*/
Static Function AltPrefs()
Local lRet := .F.
Local bOk := {|| lRet := .T., oDlg:End() }, bCancel := {|| oDlg:End() }
Local oDlg
Local oCheck1, lCheck1 := lGroupEmbs
Local oCheck2, lCheck2 := lDoubleClick
Local oCheck3, lCheck3 := lTelaQuantidade
Local nLin := 15, nCol := 12

DEFINE MSDIALOG oDlg TITLE STR0140 FROM 330,360 TO 565,730 OF oMainWnd PIXEL //	STR0140	"Estufagem de Mercadorias"

    oPanel:= TPanel():New(0, 0, "", oDLG,, .F., .F.,,, 90, 165) //MCF - 14/09/2015
    oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

    @ nLin, 6 To 75, 182 Label STR0141 Of oPanel Pixel //STR0141	"Preferências"
    nLin += 10
	@ nLin,nCol CheckBox oCheck1 Var lCheck1 Prompt STR0142 Size 160,08 PIXEL OF oPanel //STR0142	"Agrupar embalagens/produtos iguais ao mover?"z
    nLin += 10
	@ nLin,nCol CheckBox oCheck2 Var lCheck2 Prompt "Usar duplo clique para mover embalagens/produtos?" Size 160,08 PIXEL OF oPanel
    nLin += 10
	@ nLin,nCol CheckBox oCheck3 Var lCheck3 Prompt "Exibir tela para escolher quantidade ao mover embalagens/produtos?" Size 160,08 PIXEL OF oPanel

ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   If lRet
      //SetMv("MV_AVG0172", lGroupEmbs := lCheck1)
      oUserParams:SetParam("GROUP_EMBS", lGroupEmbs    := lCheck1)

      oUserParams:SetParam("DOUBLE_CLICK", lDoubleClick    := lCheck2)

      oUserParams:SetParam("TELA_QUANTIDADE", lTelaQuantidade := lCheck3)
   EndIf

Return lRet

/*
Função     : Ae110IncEmb
Parâmetros :
Retorno    :
Objetivos  : Exibe tela para inclusão manual de embalagem.
Autor      : Eduardo C. Romanini
Data/Hora  : 30/03/2009
Obs.       :
*/
*-------------------------------*
Static Function Ae110IncEmb(nOpc)
*-------------------------------*
Local lRet := .F.

Local cNewDesc, cNewCargo

Local nLin  := 25, nCol := 12
Local nId   := 0

Local bOk := {|| If(ValIncEmb(),(lRet:=.T., oDlg:End()),)}
Local bCancel := {|| oDlg:End()}

Local aOrd :={}

Local oDlg

Private cIncEmb:= Space(AvSX3("EE5_CODEMB",AV_TAMANHO))
Private nQtdEmb := 0

Begin Sequence

   ////////////////////////////////////////////////////
   //Inicio das validações para inclusão de Embalagem//
   ////////////////////////////////////////////////////
   If nOpc <> INCLUIR
      Break
   EndIf

   /////////////////////////////////////////
   //Exibe tela para seleção de Embalagens//
   /////////////////////////////////////////
   Define MsDialog oDlg Title STR0143 From 9,0 To 22,57 Of oMainWnd //	STR0143	"Seleção de Embalagens"

      oPanel:= TPanel():New(0, 0, "", oDLG,, .F., .F.,,, 90, 165) //MCF - 14/09/2015
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      @ 13, 05 To 42,220 LABEL STR0144 Pixel Of oPanel //STR0144	"Tipo da Embalagem"

      @ nLin,nCol Say STR0053 Size 032,008 Pixel Of oPanel //STR0053	"Embalagem:"
      @ nLin,nCol+30 MsGet cIncEmb Size 060,009 Picture "@!" F3 "EE5" Valid ExistCpo("EE5",cIncEmb) Pixel Of oPanel

      nCol += 100

      @ nLin,nCol Say STR0055 Size 032,008 Pixel Of oDlg//STR0055	"Quantidade:"
      @ nLin,nCol+40 MsGet nQtdEmb  Size 060,009 Picture "@E 999,999.99" Valid Positivo(nQtdEmb - 1) Pixel Of oPanel

   Activate MsDialog oDlg Centered On Init EnchoiceBar(oDlg, bOk, bCancel)

   ///////////////////////////////////////
   //Gravação da Embalagem na work WK_ES//
   ///////////////////////////////////////
   If lRet

      aOrd := SaveOrd({cWorkES})

      (cWorkES)->(DbSetOrder(1))
      If (cWorkES)->(DbSeek(Ae110Info("TREE_ID")))
         nId := Val((cWorkES)->EYH_ID) //Id do galho que está posicionado.
      EndIf

      ////////////////////
      //Gravação na Work//
      ////////////////////
      (cWorkES)->(DbAppend())

      (cWorkES)->EYH_FILIAL := xFilial(cAlias)
      (cWorkES)->EYH_PREEMB := EEC->EEC_PREEMB
      (cWorkES)->EYH_ESTUF  := "S"
      (cWorkES)->EYH_IDVINC := StrZero(nId,AvSx3("EYH_ID", AV_TAMANHO))
      (cWorkES)->EYH_ID     := Ae110NewId(.T.)
      (cWorkES)->EYH_RELSUP := 1
      (cWorkES)->EYH_CODEMB := cIncEmb
      (cWorkES)->EYH_DESEMB := Posicione("EE5",1,xFilial("EE5")+cIncEmb,"EE5_DESC")
      (cWorkES)->EYH_QTDEMB := nQtdEmb
      (cWorkES)->EYH_PSLQUN := Posicione("EE5",1,xFilial("EE5")+cIncEmb,"EE5_PESO")
      (cWorkES)->EYH_PSBRUN := 0
      (cWorkES)->EYH_PSLQTO := 0
      (cWorkES)->EYH_PSBRTO := 0
      (cWorkES)->WK_ISCONT  := ""
      (cWorkES)->WK_RECNO   := 0

      ////////////////////
      //Gravação no Tree//
      ////////////////////
      cNewCargo := cWorkES + StrZero((cWorkES)->(Recno()), 10)

      cImg := GetImgTree(cWorkES)
      cNewDesc  := "Emb: " + (cWorkES)->EYH_DESEMB + " " + "Qtd: " + AllTrim(Str(nQtdEmb))

      oTreeES:AddItem(cNewDesc, cNewCargo, cImg, cImg,,, 2)

      oTreeES:TreeSeek(cNewCargo)
      oTreeES:Refresh()
      oTreeES:SetFocus()

      /////////////////////
      //Cálculo dos Pesos//
      /////////////////////
      Ae110AtuPeso(cWorkES,,cZeroCont)

      // BAK - Tratamento para inclusão de nova embalagens na estufagem - 15/02/2013
      If Type("aEmbIncl") == "A"
         aAdd(aEmbIncl,{cIncEmb,(cWorkES)->EYH_ID,(cWorkES)->EYH_IDVINC,(cWorkES)->EYH_PSLQUN,nQtdEmb})
      EndIf

   EndIf

End Sequence

RestOrd(aOrd, .T.)

Return lRet

*-------------------------*
Static Function ValIncEmb()
*-------------------------*
Local lRet := .T.
Local nPeso := 0

Begin Sequence

   If Empty(cIncEmb)
      MsgInfo(STR0145,STR0001)//	STR0145	"Favor selecionar a embalagem para inclusão!"//STR0001	"Atenção"
      lRet := .F.
      Break
   EndIf

   If nQtdEmb <= 0
      MsgInfo(STR0146,STR0001)//STR0146	"Favor preencher uma quantidade valida!"//STR0001	"Atenção"
      lRet := .F.
      Break
   EndIf

   If !ExistCpo("EE5",cIncEmb)
      MsgInfo(STR0147,STR0001) //STR0147	 "Favor preencher uma embalagem valida!"//STR0001	"Atenção"
      lRet := .F.
      Break
   EndIf

   // BAK - Tratamento para inclui quantidade inteira, deixar a função ExistCpo antes desse tratamento por causa do EE5_PESO
   nPeso := EE5->EE5_PESO
   If nQtdEmb < 1
      nDecimal := nQtdEmb
   Else
      nDecimal := nQtdEmb%Int(nQtdEmb)
   EndIf

   // Caso seja o decimal igual a Zero, significa que foi informado a quantidade inteira.
   If nDecimal == 0
      Break
   Else
      If nDecimal > 0 .And. nDecimal < 1 .And.  nPeso > 0
         lRet := .F.
         MsgInfo(STR0146,STR0001)
         Break
      EndIf
   EndIf
   //

End Sequence

Return lRet

/*
Função      : AE110IsEstuf
Parametros  : cPreemb - Processo de embarque
              cSeqEmb - Sequência do item no embarque
Retorno     : lRet - Indica se o item possui quantidade estufada
Objetivos   : Verificar se um item de determinado embarque possui quantidade estufada
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 27/07/09
*/
Function Ae110IsEstuf(cPreemb, cSeqEmb)
Local aOrd := SaveOrd("EYH")
Local lRet := .F.

   cPreemb := AvKey(cPreemb, "EYH_PREEMB")
   cSeqEmb := AvKey(cSeqEmb, "EYH_SEQEMB")
   EYH->(DbSetOrder(2))
   //Chave - EYH_FILIAL+EYH_ESTUF+EYH_PREEMB+EYH_SEQEMB
   lRet := EYH->(DbSeek(xFilial()+"S"+cPreemb+cSeqEmb))

RestOrd(aOrd, .T.)
Return lRet

/*
Função      : Ae110ExcItNE
Parametros  : cPreemb - Processo de embarque
              cSeqEmb - Sequência do item no embarque
Retorno     : lRet - Indica se o item possui quantidade estufada
Objetivos   : Verificar se um item de determinado embarque possui quantidade estufada
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 27/07/09
*/
Function Ae110ExcItNE(cPreemb, cSeqEmb)
Local aOrd := SaveOrd("EYH")
Local cIdVinc

Begin Sequence

   cPreemb := AvKey(cPreemb, "EYH_PREEMB")
   cSeqEmb := AvKey(cSeqEmb, "EYH_SEQEMB")

   EYH->(DbSetOrder(2))

   /*
      Faz a exclusão/alteração do item.
      Verifica somente se o item possui quantidade não estufada, visto que a rotina de embarque não deve permitir que itens já estufados
      sejam desmarcados do embarque.
   */
   If !EYH->(DbSeek(xFilial()+"N"+cPreemb+cSeqEmb))
      Break
   EndIf

   EYH->(RecLock("EYH", .F.))
   cIdVinc := EYH->EYH_IDVINC
   EYH->(DbDelete())
   EYH->(MSUnlock())

   EYH->(DbSetOrder(1))

   //Exclui/altera a embalagem imediatamente superior ao item
   If !EYH->(DbSeek(xFilial()+"N"+cPreemb+cIdVinc))
      Break
   EndIf

   EYH->(RecLock("EYH", .F.))
   cIdVinc := EYH->EYH_IDVINC
   EYH->(DbDelete())
   EYH->(MSUnlock())

End Sequence

RestOrd(aOrd)

Return Nil

/*
Função      : Ae110AddItNE
Parametros  : cPreemb - Processo de embarque
              cSeqEmb - Sequência do item no embarque
Retorno     : Nenhum.
Objetivos   : Incluir um novo item do embarque na relação de itens não estufados.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 27/07/09
*/
Function Ae110AddItNE(cPreemb, cSeqEmb)
Local aOrd := SaveOrd("EYH"), aOrdEE9
Local lDivide := .F., nQtde, nRelacao
Local cId := Ae110NewId(.T., cPreemb), cEmbSup, cIdEmb
Local bGetID := {|| cId := StrZero(Val(cId) + 1, AvSx3("EYH_ID", AV_TAMANHO)) }

Private cWorkNE := "EYH"
Private cZero := StrZero(0, AvSx3("EYH_ID", AV_TAMANHO))

Begin Sequence

   cPreemb := AvKey(cPreemb, "EYH_PREEMB")
   cSeqEmb := AvKey(cSeqEmb, "EYH_SEQEMB")

   EYH->(DbSetOrder(1))
   If !EYH->(DbSeek(xFilial()+"N"+cPreemb)) .And. !EYH->(DbSeek(xFilial()+"S"+cPreemb))
      /*
         Caso não tenha registro na tabela EYH para este embarque, a rotina de estufagem ainda não foi acessada. Não é necessário incluir o item,
         já que ao acessar a estufagem a rotina irá verificar todos os itens do embarque para calcular os itens não estufados.
      */
      Break
   EndIf

   If EE9->(EE9_PREEMB+EE9_SEQEMB) <> cPreemb+cSeqEmb
      //Caso a chave informada não corresponda ao registro atual, posiciona a tabela EE9
      aOrdEE9 := SaveOrd("EE9")
      EE9->(DbSetOrder(3))
      //Chave - EE9_FILIAL+EE9_PREEMB+EE9_SEQEMB
      If !EE9->(DbSeek(xFilial()+cPreemb+cSeqEmb))
         //Cancela o processamento caso a chave informada não exista na base para a filial atual
         Break
      EndIf
   EndIf

   /*
   //Inclui a embalagem imediatamente superior ao item
   EYH->(RecLock("EYH", .T.)) //(DbAppend())
   EYH->EYH_FILIAL := xFilial("EYH")
   EYH->EYH_PREEMB := EEC->EEC_PREEMB
   EYH->EYH_ID     := cIdEmb := Eval(bGetId)
   EYH->EYH_IDVINC := cZero
   EYH->EYH_CODEMB := cEmbSup := EE9->EE9_EMBAL1
   EYH->EYH_DESEMB := Posicione("EE5", 1, xFilial("EE5")+EE9->EE9_EMBAL1, "EE5_DESC")
   EYH->EYH_EMBSUP := ""
   EYH->EYH_RELSUP := 1
   EYH->EYH_ESTUF  := "N"
   EYH->EYH_QTDEMB := EE9->EE9_QTDEM1
   EYH->EYH_PSLQUN := BuscaPesEmb(EE9->EE9_EMBAL1)
   EYH->(MsUnlock())

   //Inclui o item
   nRelacao := EE9->EE9_QE
   nQtde    := EE9->EE9_SLDINI
   While nQtde > 0
      EYH->(RecLock("EYH", .T.)) //(DbAppend())
      EYH->EYH_FILIAL := xFilial("EYH")
      EYH->EYH_PREEMB := EEC->EEC_PREEMB
      EYH->EYH_ID     := Eval(bGetId)
      EYH->EYH_IDVINC := cIdEmb
      EYH->EYH_CODEMB := EE9->EE9_COD_I
      EYH->EYH_DESEMB := MSMM(EE9->EE9_DESC, 60,,,LERMEMO)
      EYH->EYH_COD_I  := EE9->EE9_COD_I
      EYH->EYH_SEQEMB := EE9->EE9_SEQEMB
      EYH->EYH_EMBSUP := cEmbSup
      EYH->EYH_RELSUP := nRelacao
      EYH->EYH_ESTUF  := "N"
      EYH->EYH_QTDEMB := If(lDivide, If(nQtde < nRelacao, nQtde, nRelacao), nQtde)
      If Empty(EE9->EE9_UNPES)
         EYH->EYH_PSLQUN := EE9->EE9_PSLQUN
      Else
         If Empty(EEC->EEC_UNIDAD) .Or.  AvVldUn(EEC->EEC_UNIDAD) // MPG - 06/02/2018
            EYH->EYH_PSLQUN := AvTransUnid(EE9->EE9_UNPES, "KG", EE9->EE9_COD_I, EE9->EE9_PSLQUN, .F.)
         Else
            EYH->EYH_PSLQUN := AvTransUnid(EE9->EE9_UNPES, EEC->EEC_UNIDAD, EE9->EE9_COD_I, EE9->EE9_PSLQUN, .F.)
         EndIf
      EndIf
      nQtde -= EYH->EYH_QTDEMB
      EYH->(MsUnlock())
   EndDo
   */

   //Inclui o item e todas as embalagens relacionadas
   Ae110GetEmbs()

End Sequence

If ValType(aOrdEE9) == "A"
   RestOrd(aOrdEE9, .T.)
EndIf
RestOrd(aOrd)

Return Nil

/*
Função      : Ae110RmItem(cPreemb, cSeqEmb)
Parametros  : cPreemb - Processo de embarque
              cSeqEmb - Sequência do item no embarque
Retorno     : Nenhum.
Objetivos   : Remover um item da relação de itens não estufados.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 18/11/09
*/
Function Ae110RmItem(cPreemb, cSeqEmb)
Local aOrd := SaveOrd("EYH")
Local cIdVinc, nQuant, nRelsup
Local lExcluiEmb := .T.

Begin Sequence

   cPreemb := AvKey(cPreemb, "EYH_PREEMB")
   cSeqEmb := AvKey(cSeqEmb, "EYH_SEQEMB")

   EYH->(DbSetOrder(2))
   While EYH->(DbSeek(xFilial()+"N"+cPreemb+cSeqemb))

      cIdVinc   := EYH->EYH_IDVINC
      nQuant    := EYH->EYH_QTDEMB
      nRelSup   := EYH->EYH_RELSUP
      nRecnoEYH := EYH->(Recno())

      EYH->(DbSetOrder(1))
      While EYH->(DbSeek(xFilial()+"N"+cPreemb+cIdVinc))
         If EYH->EYH_QTDEMB > (nQuant * nRelSup)
            lExcluiEmb := .F.
         Else
            lExcluiEmb := .T.
         EndIf

         cIdVinc := EYH->EYH_IDVINC
         nQuant  := EYH->EYH_QTDEMB
         nRelSup := EYH->EYH_RELSUP

         If EYH->(RecLock("EYH", .F.))
            If lExcluiEmb
               EYH->(DbDelete())
            Else
               EYH->EYH_QTDEMB -= (nQuant * nRelSup)
            EndIf
            EYH->(MsUnlock())
         EndIf
         EYH->(DbSkip())
      EndDo

      EYH->(DbSetOrder(1))
      EYH->(DbGoTo(nRecnoEYH))

      If EYH->(RecLock("EYH", .F.))
         EYH->(DbDelete())
         EYH->(MsUnlock())
      EndIf

      EYH->(DbSkip())
   EndDo

End Sequence

RestOrd(aOrd, .T.)
Return Nil

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Inicio da Rotina de Notas Fiscais de Remessa.                                                                                                    //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*
Função     :AE110VincNfEnt()
Parâmetros :Nenhum
Retorno    :lRet
Objetivos  :
Autor      :Eduardo C. Romanini
Data/Hora  : 13/11/2008 às 14:15
Revisão    : WFS - 19/01/2010
             Inclusão do tratamento de nota fiscal de remessa no pedido de exportação,
             para atender ao convênio ICMS n.º 84 no DOU de 29/09/09, NFe.
             WFS jun/2016
             Implementação de estrutura com controle de saldo.
             A partir destas implementações, a funcionalidade estará disponível somente na fase de embarque.
             A partir da liberação do release com os ajustes de dicionário, todas as implementações condicionadas
             pela função !NFRemNewStruct() podem ser descartadas.
*/
*-----------------------*
Function AE110VincNfEnt(nOpc)
*-----------------------*
Local lRet := .F.

Local aAlter := {}
Local aCpos  := {}
Local aPos   := {}
Local aCposAux := {}, aCposOrdem := {}, i := 0, j := 0
Local aNaoExibeCpos:= {"EYY_PREEMB", "EYY_FASE", "EYY_D1ITEM", "EYY_POSIPI"}
Local cFileBackup := CriaTrab(,.F.)

Local nRecSeq := 0
Local cAlias  := ""
Local bOk     := {|| If(AE110TudoOk(),(lRet:= .T.,oDlgNfRem:End()),)}
Local bCancel := {|| oDlgNfRem:End()}
Local aDePara := {}
Local oDlgNfRem
Local nCont
Local cCampo
Local nPos
Local cFuncDelete:= "AE110DelLin"
Local lFimEspecNew := AvFlags("ROTINA_VINC_FIM_ESPECIFICO_RP12.1.20")
Local aBkpDeletados := aClone(aNfRemDeletados) //THTS - 26/11/2018 - Backup do array de deletados, para o caso de cancelar a operacao.

Private oGetNfRem
Private aHeader := {}
Private aItemPed := {}   // GFP - 08/01/2014
Private lExecConPad1:= .T.
Private cWarning:= ""
Private lRetPE

Default nOpc:= ALTERAR

Begin Sequence

   If nOpc == VISUALIZAR
      cFuncDelete:= ""
   EndIf

   If !AvFlags("FIM_ESPECIFICO_EXP")
      Break
   EndIf

   If Select("WK_NFRem") == 0
      Break
   EndIf

   Do Case

      Case cOcorre == OC_PE //Fase de pedido
         cAlias:= "WorkIt"

         If !Avflags("EEC_LOGIX")
            aAlter := {"EYY_SEQUEN", "EYY_NFENT", "EYY_SERENT", "EYY_FORN", "EYY_FOLOJA", "EYY_QUANT","EYY_NROMEX","EYY_DTMEX"}
         Else
            aAlter := {"EYY_NROMEX","EYY_DTMEX"}  //NCF - 23/11/2017
         EndIf
         aCpos  := {"EYY_SEQUEN","EE8_COD_I", "EYY_NFENT", "EYY_SERENT", "EYY_FORN", "EYY_FOLOJA", "EYY_DESFOR", "EYY_QUANT","EYY_NROMEX","EYY_DTMEX"}

         aAlter := AddCpoUser(aAlter,"EYY","3")
         aCpos  := AddCpoUser(aCpos,"EYY","3")

         aHeader:= EECMontaHeader(aCpos)

      Case cOcorre == OC_EM //Fase de embarque

         cAlias := "WorkIp"

         If !NFRemNewStruct()
            If !Avflags("EEC_LOGIX")
               aAlter := {"EYY_SEQUEN","EYY_PEDIDO","EYY_NFSAI","EYY_SERSAI","EYY_NFENT","EYY_SERENT","EYY_FORN","EYY_FOLOJA","EYY_NROMEX","EYY_DTMEX","EYY_QUANT"}
            Else
               aAlter := {"EYY_NROMEX","EYY_DTMEX"}  //NCF - 23/11/2017
            EndIf
            aCpos  := {"EYY_SEQUEN","EYY_PEDIDO","EE9_COD_I","EYY_RE","EYY_NFSAI","EYY_SERSAI","EYY_NFENT","EYY_SERENT","EYY_FORN","EYY_FOLOJA","EYY_DESFOR","EYY_NROMEX","EYY_DTMEX","EYY_QUANT"}
         Else

            /* Campos carregados a partir da EE9/ WorkIP não sofrerão alterações.
               Manter como editável a nota, para chamada da consulta padrão, e a quantidade, além das informações
               do memorando de exportação. */
            aAlter := {"EYY_NFENT", "EYY_QUANT", "EYY_NROMEX", "EYY_DTMEX"}

            If !EasyGParam("MV_EEC0051",, .F.)
               AAdd(aNaoExibeCpos, "EYY_D1PROD")
            EndIf

            //Campos exibidos
            SX3->(DBSetOrder(1))
            SX3->(DBSeek("EYY"))
            While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "EYY"

               If X3Uso(SX3->X3_USADO) .And. AScan(aNaoExibeCpos, AllTrim(SX3->X3_CAMPO)) == 0
                  AAdd(aCpos, AllTrim(SX3->X3_CAMPO))
               EndIf

               SX3->(DBSkip())
            EndDo
            aSaldoNFE:= {}
         EndIf

        //NCF - 15/02/2017 - Ordenar conforme a ordem abaixo, pois UPDDISTR e AVUPDATE02 não alterarm ordem.
         aCposOrdem := {"EYY_PREEMB" , "EYY_SEQEMB" , "EYY_COD_I"  , "EYY_VM_DES" , "EYY_RE"     , "EYY_NFSAI"  , ;
                        "EYY_SERSAI" , "EYY_NFENT"  , "EYY_SERENT" , "EYY_FORN"   , "EYY_FOLOJA" , "EYY_DESFOR" , ;
                        "EYY_PEDIDO" , "EYY_SEQUEN" , "EYY_FASE"   , "EYY_QUANT"  , "EYY_UNIDAD" , "EYY_NROMEX" , ;
                        "EYY_DTMEX"  , "EYY_D1ITEM" , "EYY_CHVNFE" , "EYY_SQFNFS" , "EYY_D1PROD" }
         //Adiciona no array auxiliar os campos da ordem que existam no SX3
         For i := 1 To Len(aCposOrdem)
            If aScan( aCpos , {|x| Alltrim(x) == aCposOrdem[i] }) > 0
               aAdd(aCposAux,aCposOrdem[i])
            EndIf
         Next i
         //Adiciona os demais campos que existam no SX3 mas não estão listados no array de ordenação
         For j := 1 To Len(aCpos)
            If aScan(aCposAux,{|x| Alltrim(aCpos[j]) == x }) == 0
               aAdd(aCposAux,aCpos[j])
            EndIf
         Next j
         aCpos := aClone(aCposAux)
         aCposAux := {}

         //Campos de usuário
         aAlter := AddCpoUser(aAlter, "EYY", "3")
         aCpos  := AddCpoUser(aCpos , "EYY", "3")

         If nOpc == VISUALIZAR
            aAlter:= {}
         EndIf

         aHeader:= EECMontaHeader(aCpos)

   End Case

   nRecSeq:= (cAlias)->(RecNo())

   /* Carga dos dados, com base nos dados das tabelas EYY e WorkIp*/
   AE110LoadEYY()

   //////////////////////////////////////////////////////////
   //Carrega a work WK_NFRem com as notas fiscais dos itens//
   //////////////////////////////////////////////////////////

   /* Confirma se os itens da nota fiscal de remessa WK_NFRem se mantém no processo de embarque WorkIp */
   AE110LoadNfRem()

   If !Empty(cWarning)
      EECView(cWarning, STR0001,,,, .T.)
   EndIf

   DbSelectArea("WK_NFRem")
   TETempBackup(cFileBackup)

   WK_NFRem->(dbGoTop())

   If WK_NFRem->(BOF()) .And. WK_NFRem->(EOF())

      If cOcorre == OC_PE //Fase de pedido
         MsgInfo(STR0002, STR0001) //O processo não possui itens a serem vinculados. / Atenção
      ElseIf cOcorre == OC_EM //Fase de embarque
         MsgInfo(STR0002 /*STR0003*/, STR0001) //O processo não possui itens a serem vinculados. /* Nenhum item possui a Nota Fiscal de Saída e/ ou R.E. preenchido.*/ Atenção
      EndIf

      /* WFS - 27/01/2010
         Inclusão do tratamento de nota fiscal de remessa no pedido de exportação,
         para atender ao convênio ICMS n.º 84 no DOU de 29/09/09, NFe.
         Se a comparação das notas fiscais não foi executada, a tabela EYY será
         apagada indevidamente. Inclusão de tratamento impeditivo.*/

      If EasyGParam("MV_AVG0067",, .F.)
         aNfremDeletados:= {}
      EndIf

      WK_NFRem->(DbGoTop())

      lRet := .F.
      Break
   EndIf


   If !NFRemNewStruct()
      Wk_NFRem->(DbSetOrder(0))
   Else
      Wk_NFRem->(DbSetOrder(1))
   EndIf
   WK_NFRem->(DbGoTop())

   Define MsDialog oDlgNfRem Title STR0148 FROM DLG_LIN_INI, DLG_COL_INI To DLG_LIN_FIM, DLG_COL_FIM Of oMainWnd Pixel //STR0148 "Notas Fiscais de Remessa"

      aPos := PosDlg(oDlgNfRem)
      oGetNfRem := MsGetDb():New(aPos[1],aPos[2],aPos[3]-4,aPos[4],;// Posições da Tela
                                 4,;                                // Tipo (Inclusão, Alt., etc.)
                                 "AE110LinOk",;                     // cLinhaOk
                                 ,;                                 // cTudoOk
                                 ,;                                 // cIncrementa
                                 .T.,;                              // Permite deleção de registros
                                 aAlter,;                           // Campos que podem ser alterados
                                 0,;                                // Nro. de Colunas que serão congeladas
                                 ,;
                                 ,;
                                 "WK_NFRem",;                       // Work que será mostrada no Browse
                                 ,;                                 // Função executada na validação do campo.
                                 ,;                                 // Parâmetro reservado
                                 !NFRemNewStruct(),;                // Indica se a MSGetDB irá criar uma linha em branco automaticamente quando for inclusão.
                                 oDlgNfRem,;                        // Objeto no qual está inserida a MsGetDb
                                 .T.,;                              // Define se vai utilizar características do dicionário (gatilhos, consultas...)
                                 ,;
                                 cFuncDelete,;                      // Função que valida exclusão
                                 )                                  // Função executada quando pressionada as teclas +.

      /* Bloqueia a inclusão de linhas */
      If NFRemNewStruct()
         oGetNfRem:oBrowse:bAdd := {|| .F.}
         oGetNfRem:oBrowse:bChange:= {|| oGetNfRem:nCount:= Wk_NFRem->(EasyRecCount())}
      EndIf

      oGetNfRem:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT
      oDlgNfRem:lMaximized := .T.
      oGetNfRem:oBrowse:Refresh()
   Activate MsDialog oDlgNfRem ON INIT EnchoiceBar(oDlgNfRem, bOk, bCancel) Centered

   If !lRet
      WK_NFRem->(AvZap())

      WK_NFRem->(TERestBackup(cFileBackup))
      WK_NFRem->(DbGoTop())
      aNfRemDeletados := {}
      aNfRemDeletados := aClone(aBkpDeletados)
   EndIf

(cAlias)->(DbGoTo(nRecSeq))

lRetPE := lRet
If EasyEntryPoint("EECAE110")
   ExecBlock("EECAE110", .F., .F., "POS_GRV_WORKNFREM")
EndIf
lRet := lRetPE

End Sequence

Return lRet

/*
Função     : AE110LoadEYY
Parâmetros : Nenhum
Retorno    : lRet = .T. ou .F.
Objetivos  : Gravação da Work Wk_NfRem com os dados da tabela EYY
Autor      : Eduardo C. Romanini
Data/Hora  : 18/11/2008 às 10:30
Revisão    : WFS - 19/01/2010
             Inclusão do tratamento de nota fiscal de remessa no pedido de exportação,
             para atender ao convênio ICMS n.º 84 no DOU de 29/09/09, NFe.
             WFS Jun/2016
             Melhorias na funcionalidade: carga inicial da quantidade irá sugerir a quantidade do
             item ainda não vinculada à uma nota fiscal de entrada
*/
*---------------------*
Function AE110LoadEYY()
*---------------------*
Local lRet     := .T.
Local nPos, nRecNo
Local nSaldo   := 0
Local aOrd     := {}
Local cChave   := ""
Local lFimEspecNew := AvFlags("ROTINA_VINC_FIM_ESPECIFICO_RP12.1.20")
Local lExpDireta := .F.

Begin Sequence

If !NFRemNewStruct()
   If WK_NFRem->(EasyRecCount()) <> 0      // GFP - 31/10/2012 - Carregar informações corretas
      WK_NFRem->(DbGoTop())
      Do While WK_NFRem->(!Eof())
         If Empty(WK_NFRem->(EYY_NFENT + EYY_SERENT)) //LBL - 12/09/2013
            WK_NFRem->(DbDelete())
         EndIf
         WK_NFRem->(DbSkip())
      EndDo
   EndIf
EndIf

Do Case
   Case cOcorre == OC_PE //Fase de pedido

      aOrd:= SaveOrd({"EE8", "EYY", "WORKIT", "SD1"})

      EYY->(DBSetOrder(2)) //EYY_FILIAL + PEDIDO
      If EYY->(DBSeek(xFilial() + M->EE7_PEDIDO))
         Wk_NfRem->(DBSetOrder(1)) //ordem estabelecida conforme as informações que serão gravadas na fase de pedido

         While EYY->(!Eof()) .And.;
               EYY->EYY_FILIAL + EYY->EYY_PEDIDO == EYY->(xFilial()) + M->EE7_PEDIDO

            If !Wk_NFRem->(DBSeek(EYY->(EYY_PEDIDO + EYY_SEQUEN + EYY_NFENT + EYY_SERENT)))

               Wk_NFRem->(DBAppend())
               AvReplace("EYY", "Wk_NFRem")
               Wk_NFRem->EYY_RecNo:= EYY->(RecNo())
               If WK_NFRem->(FieldPos("EE8_COD_I"))>0 //FSY - 04/02/2014
                  WK_NFRem->EE8_COD_I := Posicione("EE8",1,xFilial("EE8")+ EYY->EYY_PEDIDO + EYY->EYY_SEQUEN ,"EE8_COD_I") //FSY - 08/01/2014 pedido: alteração
               End If
            EndIf

            EYY->(DBSkip())
         End
      EndIf

      // GFP - 03/02/2014 - Armazena os itens do pedido de referência que compõem o pedido
      WorkIt->(DBGoTop())
      While WorkIt->(!Eof())

         AAdd(aItemPed, {WorkIt->EE8_SEQUEN, WorkIt->(RecNo()), WorkIt->EE8_COD_I})

         WorkIt->(DBSkip())
      End

      ASort(aItemPed)
      WorkIt->(DBGoTop())

   Case cOcorre == OC_EM //Fase de embarque

      aOrd:= SaveOrd({"EE8", "EE9", "EYY", "WORKIP", "SD1"})

      If !NFRemNewStruct()
         //Armazena os itens do pedido de referência que compõem o embarque
         nRecNo:= WorkIp->(RecNo())
         WorkIp->(DBGoTop())

         While WorkIp->(!Eof())

            AAdd(aItemPed, {WorkIp->EE9_SEQUEN, WorkIp->(RecNo()), WorkIp->EE9_COD_I})  // GFP - 08/01/2014

            WorkIp->(DBSkip())
         EndDo
         WorkIp->(DBGoTo(nRecNo))

         ASort(aItemPed)
      EndIf


      If NFRemNewStruct()

         /* 1. Atualização da work com base nos registros da tabela EYY.
            Será executado apenas quando a WK_NFRem estiver vazia.
            Não será necessário atualizar o array aSaldoNFE, pois os saldos da tabela
            SD1 estão atualizados com as informações gravadas na tabela EYY. */
         EYY->(DbSetOrder(1)) //EYY_FILIAL + EYY_PREEMB + EYY_SEQEMB + EYY_NFSAI + EYY_SERSAI
         WorkIp->(DBSetOrder(2)) //EE9_SEQEMB + EYY->EYY_NFSAI + EYY->EYY_SERSAI
         SD1->(DBSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
         If WK_NFRem->(EasyRecCount()) == 0 .And. !Empty(M->EEC_PREEMB) .And. EYY->(DBSeek(xFilial("EYY") + M->EEC_PREEMB ))

            While EYY->(!Eof()) .And. EYY->EYY_FILIAL == EYY->(xFilial()) .And.;
                  EYY->EYY_PREEMB == M->EEC_PREEMB


               /* Se o item não está na WorkIp ou foi desmarcado, será excluído da EYY */
               If !WorkIp->(DBSeek(EYY->EYY_SEQEMB + EYY->EYY_NFSAI + EYY->EYY_SERSAI)) .Or. Empty(WorkIp->(WP_FLAG))
                  AAdd(aNfRemDeletados, EYY->(RecNo()))
                  EYY->(DBSkip())
                  Loop
               EndIf

               SD1->(DBSeek(xFilial() + EYY->EYY_NFENT + EYY->EYY_SERENT + EYY->EYY_FORN + EYY->EYY_FOLOJA + WorkIp->EE9_COD_I + EYY->EYY_D1ITEM))

               RecLock("WK_NFRem", .T.)

               AvReplace("EYY", "WK_NFRem")
               Wk_NfRem->EYY_RECNO:= EYY->(RecNo())
               Wk_NfRem->SD1_RECNO:= SD1->(RecNo())
               If lFimEspecNew
                  Wk_NfRem->EYY_UMDSD1:= IF(Empty(SD1->D1_UM), EYY->EYY_UMDSD1, SD1->D1_UM)
               EndIf
               //NCF - 15/02/2017
               If Wk_NfRem->(FieldPos("EYY_VM_DES")) > 0
                  Wk_NfRem->EYY_VM_DES := WorkIp->EE9_VM_DES
               EndIf

               WK_NFRem->(MsUnlock())

               EYY->(DBSkip())
            EndDo

         EndIf

         /* 2. Atualização da work coom base nos registros da EYY da fase de pedido */
         If WK_NFRem->(EasyRecCount()) == 0 .And. !EYY->(DBSeek(xFilial("EYY") + M->EEC_PREEMB ))
            //Implementar posteriormente
         EndIf

         /* 3. Atualização da work com com base nos registos da WorkIp.
            Neste ponto será adicionado o registro adicional com o saldo total ou residual, pendente de vinculação
            da nota fiscal de entrada. */
         WorkIp->(DBGoTop())

         cWarning:= ""
         While WorkIp->(!Eof())

            /* desconsidera itens desmarcados */
            If Empty(WorkIp->(WP_FLAG))
               WorkIp->(DBSkip())
               Loop
            EndIf

            /* considerar somente itens que possuam notas fiscais de saídas associadas */
            If Empty(WorkIp->EE9_NF)
               cWarning += StrTran(StrTran(STR0172, "###", AllTrim(WorkIp->EE9_SEQEMB)), "$$$", AllTrim(WorkIp->EE9_COD_I)) + ENTER //"O item ###, produto $$$, não possui nota fiscal de saída."
               WorkIp->(DBSkip())
               Loop
            EndIf
                        
            lExpDireta := ExportDir()
            /* considerar somente itens que caracterizam exportação indireta */
            If EasyEntryPoint("EECAE110")
                ExecBlock("EECAE110", .F., .F., "BLOQ_NF_ENT")
            EndIf

            If lExpDireta .And. !lLiberaBloq
               cWarning += StrTran(StrTran(STR0173, "###", AllTrim(WorkIp->EE9_SEQEMB)), "$$$", AllTrim(WorkIp->EE9_COD_I)) + ENTER //"O item ###, produto $$$, não caracteriza uma exportação indireta. Verifique o fabricante do item."
               WorkIp->(DBSkip())
               Loop
            EndIf

            /* se o item encontra-se na WK_NFRem, verifica se há saldo pendente de vinculação de
               nota fiscal de entrada */
            nSaldo:= WorkIp->EE9_SLDINI

            WK_NFRem->(DBSetOrder(1)) //EYY_SEQEMB + EYY_NFSAI + EYY_SERSAI
            If WK_NFRem->(DBSeek(WorkIp->(EE9_SEQEMB + EE9_NF + EE9_SERIE)))

               While WK_NFRem->(!Eof()) .And.;
                     WK_NFRem->(EYY_SEQEMB + EYY_NFSAI + EYY_SERSAI) == WorkIp->(EE9_SEQEMB + EE9_NF + EE9_SERIE)

                  /* abate o que está associado à uma nota fiscal de entrada */
                  If !WK_NFRem->DBDELETE
                     nSaldo -= WK_NFRem->EYY_QUANT
                  EndIf

                  /* atualiza o número do R.E., caso não esteja preenchido, e a descrição do item */
                  GravaWk_NfRem(ALTERAR, WK_NFRem->EYY_QUANT)


                  WK_NFRem->(DBSkip())
               EndDo

            EndIf

            /* grava nova linha na WK_NFRem, com o saldo pendente para vinculação na nota fiscal de entrada */
            If nSaldo <> 0
               GravaWk_NfRem(INCLUIR, nSaldo)
            EndIf

            WorkIp->(DBSkip())
         EndDo

      Else

         If !Empty(M->EEC_PREEMB) .And. EYY->(DbSeek(xFilial("EYY")+M->EEC_PREEMB))
            While EYY->(!EOF()) .and. EYY->(EYY_FILIAL + EYY_PREEMB) == xFilial("EYY")+M->EEC_PREEMB

               WK_NFRem->(DbSetOrder(1)) //ordem estabelecida conforme as informações que serão gravadas na fase de embarque
               If !WK_NFRem->(DBSeek(EYY->EYY_SEQUEN + EYY->EYY_NFSAI + EYY->EYY_SERSAI + EYY->EYY_NFENT + EYY->EYY_SERENT))

                  WK_NFRem->(DbAppend())

                  AvReplace("EYY", "WK_NFRem")
                  WK_NFRem->EYY_RECNO := EYY->(RecNo())
                  If WK_NFRem->(FieldPos("EE9_COD_I")) > 0 //FSY - 04/02/2014
                     WK_NFRem->EE9_COD_I := Posicione("EE9",2,xFilial("EE9")+ EYY->EYY_PREEMB + EYY->EYY_PEDIDO + EYY->EYY_SEQUEN, "EE9_COD_I") //FSY - 08/01/2014 embarque: alteração
                  End If
                  WK_NFRem->(MsUnlock())

               //Este tratamento permite que os dados duplicados na base sejam exibidos.
               ElseIf WK_NFRem->EYY_RECNO <> EYY->(RecNo())

                  WK_NFRem->(DbAppend())

                  AvReplace("EYY", "WK_NFRem")
                  WK_NFRem->EYY_RECNO := EYY->(RecNo())
                  If WK_NFRem->(FieldPos("EE9_COD_I"))>0//FSY - 04/02/2014
                     WK_NFRem->EE9_COD_I := Posicione("EE9",2,xFilial("EE9")+ EYY->EYY_PREEMB + EYY->EYY_PEDIDO + EYY->EYY_SEQUEN ,"EE9_COD_I") //FSY - 08/01/2014 embarque: alteração
                  End If
                  WK_NFRem->(MsUnlock())

               EndIf

               EYY->(DbSkip())
            EndDo

            //DFS - 25/09/12 - Preencher o RE quando for digitado no item do embarque.
            WK_NFRem->(DbGoTop())
            WorkIp->(DbSetOrder(1))

            While WK_NFRem->(!Eof())
               If WorkIp->(DBSeek(WK_NFRem->EYY_PEDIDO + WK_NFRem->EYY_SEQUEN)) .AND. !Empty(WorkIP->WP_FLAG)
                  WK_NFRem->(RecLock("WK_NFRem",.F.))
                  WK_NFRem->EYY_RE := WorkIp->EE9_RE
                  WK_NFRem->(MsUnlock())
               EndIf
               WK_NFRem->(DbSkip())
            EndDo

         Else

            EYY->(DBSetOrder(2)) //EYY_FILIAL + EYY_PEDIDO
            If WK_NFRem->(EasyRecCount()) == 0 //LRS - 18/08/2015 - Não preencher a Work, se já estiver preenchido.
               If !Empty(M->EEC_PEDREF) .And. (EYY->(DBSeek(xFilial() + M->EEC_PEDREF)))
	               While EYY->(!Eof()) .And.;
	                     EYY->(EYY_FILIAL + EYY_PEDIDO) == EYY->(xFilial()) + M->EEC_PEDREF

	                  nPos:= AScan(aItemPed, {|x| x[1] == EYY->EYY_SEQUEN})

	                  If nPos > 0
	                     WorkIp->(DBGoTo(aItemPed[nPos][2]))
                         If !AVFLAGS("EEC_LOGIX") .Or. ( Empty(EYY->EYY_PREEMB) .And. !Empty(WorkIP->WP_FLAG) ) .Or. EYY->EYY_PREEMB == M->EEC_PREEMB //NCF - 23/11/2017 - Não criar linha se a remessa estiver vinculada em outro embarque.
	                        Wk_NfRem->(DBAppend())
	                        AvReplace("EYY", "Wk_NfRem")

	                        WK_NFRem->EYY_PREEMB:= M->EEC_PREEMB
	                        WK_NFRem->EYY_NFSAI := WorkIp->EE9_NF
	                        WK_NFRem->EYY_SERSAI:= WorkIp->EE9_SERIE
	                        WK_NFRem->EYY_RE    := WorkIp->EE9_RE
	                        If WK_NFRem->(FieldPos("EE9_COD_I"))>0 .And. WorkIp->(FieldPos("EE9_COD_I"))>0//FSY - 02/04/2014
                               WK_NFRem->EE9_COD_I := WorkIp->EE9_COD_I//FSY - 09/01/2014 - AJUSTE DO CAMPO DE ITEM
	                        End If
	                        Wk_NfRem->EYY_RECNO := EYY->(RecNo())
                         EndIf
	                  EndIf

	                  EYY->(DBSkip())
	               EndDo
	            EndIf
            EndIF

         EndIf
      EndIf
End Case

End Sequence

RestOrd(aOrd,.T.)

Return lRet

/*
Função     : AE110LoadNfRem()
Parâmetros : Nenhum
Retorno    : lRet = .T. ou .F.
Objetivos  : Gravação/ atualização da Work Wk_NfRem
Autor      : Eduardo C. Romanini
Data/Hora  : 18/11/2008 às 10:30
Revisão    : WFS - 19/01/2010
             Inclusão do tratamento de nota fiscal de remessa no pedido de exportação,
             para atender ao convênio ICMS n.º 84 no DOU de 29/09/09, NFe.
*/

*-----------------------*
Function AE110LoadNfRem()
*-----------------------*
Local lRet := .T.

Local nPos := 0
Local nInc := 0

Local aNfRem  := {}
Local aNfItem := {}
Local aWkNf   := {}
Local aWkDel  := {}
Local aWkPed  := {}
Local aOrd    := {}
Local cOldFil := ""
Local bOldFil

Begin Sequence


Do Case


   Case cOcorre == OC_PE //Fase de pedido

      aOrd   := SaveOrd({"WorkIt","EE8"})//FSY - 08/01/2014 - Adicionado a tabela EE8
      cOldFil:= WorkIt->(DBFilter())
      bOldFil:= &("{|| "+WorkIt->(DBFilter())+"}")

      //Carrega todos os itens do pedido de exportação
      WorkIt->(DBClearFilter())

      WorkIt->(DBGoTop())
      While WorkIt->(!Eof())
         AAdd(aWkPed, {WorkIt->EE8_PEDIDO, WorkIt->EE8_SEQUEN,WorkIt->EE8_COD_I }) //FSY - 09/01/2014 - Incluido o campo EE8_COD_I

         WorkIt->(DBSkip())
      EndDo

      If !Empty(cOldFil)
         WorkIt->(DBSetFilter(bOldFil, cOldFil))
      EndIf

      //Adiciona todos os registros da work em um array
      Wk_NfRem->(DBGoTop())
      While Wk_NfRem->(!Eof())

         AAdd(aWkNf, {Wk_NfRem->EYY_PEDIDO, Wk_NfRem->EYY_SEQUEN, Wk_NfRem->EYY_NFENT, Wk_NfRem->EYY_SERENT})

         //WFS 20/05/2010 - Riex
         If Wk_NfRem->(FieldPos("EYY_QUANT")) > 0
            AAdd(aWkNf[Len(aWkNf)], Wk_NfRem->EYY_QUANT)
         EndIf

         Wk_NfRem->(DBSkip())
      EndDo


      //Consiste os itens da work de notas fiscais com os itens do pedido
      For nInc:= 1 To Len(aWkNf)

         nPos:= AScan(aWkPed, {|x| x[1] + x[2] == aWkNf[nInc][1] + aWkNf[nInc][2]})

         If nPos > 0
            AAdd(aNfRem, AClone(aWkNf[nInc]))
         Else
            AAdd(aWkDel, AClone(aWkNf[nInc]))
         EndIf
      Next


      //Consiste os itens do pedido com os itens da work de notas fiscais
      For nInc:= 1 To Len(aWkPed)

         nPos:= AScan(aWkNf, {|x| x[1] + x[2] == aWkPed[nInc][1] + aWkPed[nInc][2]})

         If nPos == 0
            AAdd(aNfRem, {aWkPed[nInc][1], aWkPed[nInc][2], "", "", "",aWkPed[nInc][3]})
         EndIf

      Next


      //Apaga os registros da Work que não estão no pedido de exportação
      For nInc:=1 To Len(aWkDel)
         Wk_NfRem->(DbSetOrder(1)) //EYY_PEDIDO + EYY_SEQUEN + EYY_NFENT + EYY_SERENT
         If Wk_NfRem->(DBSeek(AvKey(aWkDel[nInc][1], "EYY_PEDIDO") + AvKey(aWkDel[nInc][1], "EYY_SEQUEN")))

            If Wk_NfRem->EYY_RECNO <> 0
               AAdd(aNfRemDeletados, Wk_NfRem->EYY_RECNO)
            EndIf

            Wk_NfRem->(RecLock("Wk_NfRem", .F.))
            Wk_NfRem->(DBDelete())
            Wk_NfRem->(MsUnlock())

         EndIf
      Next


      //Verifica os Dados da Work com com o resultado do array aNfRem
      For nInc:= 1 To Len(aNfRem)

         Wk_NfRem->(DBSetOrder(1)) //EYY_PEDIDO + EYY_SEQUEN + EYY_NFENT + EYY_SERENT
         If !Wk_NfRem->(DbSeek(AvKey(aNfRem[nInc][1], "EYY_PEDIDO") + AvKey(aNfRem[nInc][2], "EYY_SEQUEN")))

            WK_NFRem->(DBAppend())

            WK_NFRem->EYY_PEDIDO:= aNfRem[nInc][1]
            WK_NFRem->EYY_SEQUEN:= aNfRem[nInc][2]
            WK_NFRem->EYY_NFENT := aNfRem[nInc][3]
            WK_NFRem->EYY_SERENT:= aNfRem[nInc][4]
            If Wk_NfRem->(FieldPos("EE8_COD_I")) > 0//FSY - 04/02/2014
               WK_NFRem->EE8_COD_I := aNfRem[nInc][6]//Posicione("EE8",1,xFilial("EE8")+AvKey(aNfRem[nInc][1], "EYY_PEDIDO") + AvKey(aNfRem[nInc][2], "EYY_SEQUEN"),"EE8_COD_I") //FSY - 08/01/2014 pedido
            End If
            //WFS 20/05/2010 - Riex
            If Wk_NfRem->(FieldPos("EYY_QUANT")) > 0
               WK_NFRem->EYY_SERENT:= aNfRem[nInc][5]
            EndIf

         EndIf
      Next

      WK_NFRem->(DBGoTop())

   Case cOcorre == OC_EM //Fase de embarque

      aOrd:= SaveOrd({"WorkIp", "EE9"})//FSY - 08/01/2014 - Adicionado a tabela EE9 embarque

      If NFRemNewStruct()

         WK_NFRem->(DBGoTop())
         WorkIp->(DBSetOrder(2)) //EE9_SEQEMB + EE9_NF + EE9_SERIE

         While WK_NFRem->(!Eof())

            /* Verificar se o item da WK_NFRem ainda está no embarque. Desconsidera itens desmarcados e os itens que foram alterados
               para exportação direta. */
            If Empty(WorkIp->WP_FLAG) .Or. !WorkIp->(DBSeek(WK_NFRem->(EYY_SEQEMB + EYY_NFSAI + EYY_SERSAI))) .Or.;
               ExportDir() .And. !lLiberaBloq
            
               /* Atualizar a disponibilidade de saldo para vinculação do documento de entrada */
               SaldoTmpSD1(WK_NFRem->SD1_RECNO, WK_NFRem->EYY_QUANT, SUBTRAIR)

               /* Excluir o item da WK_NFRem */
               GravaWk_NfRem(EXCLUIR)

               /* Se o item está na base, guardar o RECNO para exclusão e atualização do saldo na SD1 */
	            If WK_NFRem->EYY_RECNO <> 0
	               AAdd(aNfRemDeletados, WK_NFRem->EYY_RECNO)
	            EndIf
            Else
               /* Reajusta o saldo temporário em uso da nota fiscal de entrada (SD1).
                  Considera apenas os registros em edição.  */
               If WK_NFRem->EYY_RECNO == 0
                  SaldoTmpSD1(WK_NFRem->SD1_RECNO, WK_NFRem->EYY_QUANT, SOMAR)
               EndIf
            EndIf

            WK_NFRem->(DBSkip())
         EndDo

      Else

	      cOldFil:= WorkIp->(DBFilter())
	      bOldFil:= &("{|| "+WorkIp->(DBFilter())+"}")

	      /////////////////////////////////////////////////////////
	      //Carrega todas as Notas Fiscais dos itens do Embarque.//
	      /////////////////////////////////////////////////////////
	      WorkIp->(DbClearFilter())

	      WorkIp->(DbGoTop())
	      While WorkIp->(!EOF())

	         //DFS - 25/09/12 - Não validar o RE para adicionar ao array
	         If !Empty(WorkIP->WP_FLAG) .and. !Empty(WorkIp->EE9_NF)// .and. !Empty(WorkIp->EE9_RE)
	            /* nopado por WFS em 18/01/2010
	            nPos := aScan(aNfItem,{|e| AllTrim(e[1]) + AllTrim(e[2]) + AllTrim(e[3]) == AllTrim(WorkIp->EE9_NF) + AllTrim(WorkIp->EE9_SERIE)+ AllTrim(WorkIp->EE9_RE) })

	            If nPos == 0
	               aAdd(aNfItem,{WorkIp->EE9_NF,WorkIp->EE9_SERIE,WorkIp->EE9_RE})
	            EndIf */
	            //AAdd(aNfItem, {WorkIp->EE9_NF, WorkIp->EE9_SERIE, WorkIp->EE9_SEQUEN, WorkIp->EE9_RE, WorkIp->EE9_PEDIDO})
	            AAdd(aNfItem, {WorkIp->EE9_NF, WorkIp->EE9_SERIE, WorkIp->EE9_SEQUEN, WorkIp->EE9_RE, WorkIp->EE9_PEDIDO,WorkIp->EE9_COD_I})
	         EndIf

	         WorkIp->(DbSkip())
	      EndDo

	      If !Empty(cOldFil)
	         WorkIP->(dbSetFilter(bOldFil,cOldFil))
	      EndIf

	      //DFS - 25/09/12 - Retirar da work o RE quando for retirado do item do embarque.
	      WK_NFRem->(DbGoTop())
	      WorkIp->(DbSetOrder(1))

	      While WK_NFRem->(!Eof())
	         If WorkIp->(DBSeek(WK_NFRem->EYY_PEDIDO + WK_NFRem->EYY_SEQUEN)) .AND. !Empty(WorkIP->WP_FLAG)
	            WK_NFRem->(RecLock("WK_NFRem",.F.))
	            WK_NFRem->EYY_RE := WorkIp->EE9_RE
	            WK_NFRem->(MsUnlock())
	         EndIf
	         WK_NFRem->(DbSkip())
	      EndDo

	      ///////////////////////////////////////////////
	      //Adiciona todas as Notas da Work em um array//
	      ///////////////////////////////////////////////
	      Wk_NfRem->(DbGoTop())
	      While Wk_NfRem->(!EOF())

	         //aAdd(aWkNf,{Wk_NfRem->EYY_NFSAI,Wk_NfRem->EYY_SERSAI,Wk_NfRem->EYY_RE,Wk_NfRem->EYY_NFENT,Wk_NfRem->EYY_SERENT}) - WFS 18/01/2010
	         AAdd(aWkNf,{Wk_NfRem->EYY_NFSAI,Wk_NfRem->EYY_SERSAI,Wk_NfRem->EYY_SEQUEN,Wk_NfRem->EYY_RE,Wk_NfRem->EYY_NFENT,Wk_NfRem->EYY_SERENT,Wk_NfRem->EYY_PEDIDO})

	         //WFS 20/05/2010 - Riex
	         If Wk_NfRem->(FieldPos("EYY_QUANT")) > 0
	            AAdd(aWkNf[Len(aWkNf)], Wk_NfRem->EYY_QUANT)
	         EndIf

	         //NCF - 06/02/2012 - Memorando de Exportação por item
	         If Wk_NfRem->(FieldPos("EYY_NROMEX")) > 0
	            AAdd(aWkNf[Len(aWkNf)], Wk_NfRem->EYY_NROMEX)
	         EndIf

	         //NCF - 06/02/2012 - Memorando de Exportação por item
	         If Wk_NfRem->(FieldPos("EYY_DTMEX")) > 0
	            AAdd(aWkNf[Len(aWkNf)], Wk_NfRem->EYY_DTMEX)
	         EndIf

	         Wk_NfRem->(DbSkip())

	      EndDo


	      ////////////////////////////////////////////////////////
	      //Verificação se a Nota Fiscal de Saída está realmente//
	      //nos itens do Embarque.                              //
	      ////////////////////////////////////////////////////////
	      For nInc:=1 To Len(aWkNf)

	         nPos := aScan(aNfItem,{|e| e[1] + e[2] + e[3] == aWkNf[nInc][1] + aWkNf[nInc][2]+ aWkNf[nInc][3] })

	         If nPos > 0
	            //aAdd(aNfRem,{aWkNf[nInc][1],aWkNf[nInc][2],aWkNf[nInc][3],aWkNf[nInc][4],aWkNf[nInc][5]}) - WFS 18/01/2010
	            AAdd(aNfRem, AClone(aWkNf[nInc]))
	         Else
	            aAdd(aWkDel,{aWkNf[nInc][1],aWkNf[nInc][2],aWkNf[nInc][3]})
	         EndIf
	      Next

	      /////////////////////////////////////////////////////////
	      //Verificação se existe alguma Nota Fiscal de Saída nos//
	      //itens do Embarque que não estão na Work.             //
	      /////////////////////////////////////////////////////////
	      For nInc:=1 To Len(aNfItem)

	         nPos := aScan(aWkNf,{|e| e[1] + e[2] + e[3] == aNfItem[nInc][1] + aNfItem[nInc][2] + aNfItem[nInc][3] })

	         If nPos == 0
	            //aAdd(aNfRem,{aNfItem[nInc][1],aNfItem[nInc][2],aNfItem[nInc][3]}) - nopado por WFS 18/01/2010
	            AAdd(aNfRem, {aNfItem[nInc][1], aNfItem[nInc][2], aNfItem[nInc][3], aNfItem[nInc][4],,,aNfItem[nInc][5],,aNfItem[nInc][6]})//FSY - 09/01/2014 - adicionado 9º posição aNfItem[nInc][6] codigo do item.
	         EndIf

	      Next

	      /////////////////////////////////////////////////////////////////
	      //Apaga os registros da Work que não estão em itens do Embarque//
	      /////////////////////////////////////////////////////////////////
	      For nInc:=1 To Len(aWkDel)
	         Wk_NfRem->(DbSetOrder(1))
	         //If Wk_NfRem->(DbSeek(AvKey(aWkDel[nInc][3],"EYY_RE")+AvKey(aWkDel[nInc][1],"EYY_NFSAI")+AvKey(aWkDel[nInc][2],"EYY_SERSAI"))) - WFS 18/01/2010
	         If Wk_NfRem->(DbSeek(AvKey(aWkDel[nInc][3],"EYY_SEQUEN")+AvKey(aWkDel[nInc][1],"EYY_NFSAI")+AvKey(aWkDel[nInc][2],"EYY_SERSAI")))

	            If Wk_NfRem->EYY_RECNO <> 0
	               aAdd(aNfRemDeletados,Wk_NfRem->EYY_RECNO)
	            EndIf

	            Wk_NfRem->(RecLock("Wk_NfRem",.F.))
	            Wk_NfRem->(DbDelete())
	            Wk_NfRem->(MsUnlock())

	         EndIf
	      Next

	      /////////////////////////////////////////////////////////////////
	      //Verifica os Dados da Work com com o resultado do array aNfRem//
	      /////////////////////////////////////////////////////////////////
	      //NCF - 23/11/2017 - Manter a relação de registros inseridos na comparação pela rotina AE102ESSEYY uma vez que esta não
	      //                   insere registros nos casos em que a Nota de saída não possuir remessa. No browser de notas de remessas
	      //                   integradas via mensagem única só será possível editar os dados do Memorando de Exportação
	      If !AvFlags("EEC_LOGIX")
	         For nInc:=1 To Len(aNfRem)

	            Wk_NfRem->(DbSetOrder(1))
	            //If !Wk_NfRem->(DbSeek(AvKey(aNfRem[nInc][3],"EYY_RE")+AvKey(aNfRem[nInc][1],"EYY_NFSAI")+AvKey(aNfRem[nInc][2],"EYY_SERSAI"))) - WFS 18/01/2010
	            If !Wk_NfRem->(DbSeek(AvKey(aNfRem[nInc][3],"EYY_SEQUEN")+AvKey(aNfRem[nInc][1],"EYY_NFSAI")+AvKey(aNfRem[nInc][2],"EYY_SERSAI")))

	               WK_NFRem->(DbAppend())

	               WK_NFRem->EYY_PREEMB:= EEC->EEC_PREEMB
	               WK_NFRem->EYY_NFSAI := aNfRem[nInc][1]
	               WK_NFRem->EYY_SERSAI:= aNfRem[nInc][2]
	               WK_NFRem->EYY_SEQUEN:= aNfRem[nInc][3]
	               WK_NFRem->EYY_RE    := aNfRem[nInc][4]
	               WK_NFRem->EYY_PEDIDO:= aNfRem[nInc][7]
	               If Wk_NfRem->(FieldPos("EE9_COD_I")) > 0//FSY - 04/02/2014
	                  WK_NFRem->EE9_COD_I := aNfRem[nInc][9]//FSY - 08/01/2014  - embarque:inclusão
	               End If
	               //WFS 20/05/2010 - Riex
	               If Wk_NfRem->(FieldPos("EYY_QUANT")) > 0
	                  WK_NFRem->EYY_QUANT:= aNfRem[nInc][8]
	               EndIf

	            EndIf
	         Next
          EndIf
	      WK_NFRem->(DbGoTop())
	   EndIf
End Case

End Sequence

RestOrd(aOrd,.T.)

Return lRet

/*
Função     : AE110GravaNfRem()
Parâmetros : aNfRemDeletados : Array com os registros da Work que foram deletados.
Retorno    : lRet = .T. ou .F.
Objetivos  : Gravação da tabela EYY.
Autor      : Eduardo C. Romanini
Data/Hora  : 18/11/2008 às 10:30
Revisão    : WFS - 21/01/2010
             Inclusão do tratamento de nota fiscal de remessa no pedido de exportação,
             para atender ao convênio ICMS n.º 84 no DOU de 29/09/09, NFe.
*/
*---------------------------------------*
Function AE110GravaNfRem(aNfRemDeletados)
*---------------------------------------*
Local lRet := .T.
Local aOrd:= {}
Local nInc := 0
Local nQuantidade

Begin Sequence

   If cOcorre == OC_EM //Fase de embarque
      aOrd := SaveOrd({"SD1", "WorkIp"})
   Else
      aOrd := SaveOrd({"SD1", "WorkIt"})
   EndIf

   SD1->(DBSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
   For nInc:=1 To Len(aNfRemDeletados)

      EYY->(DBGoTo(aNfRemDeletados[nInc]))

      If EYY->(RecNo()) <> aNfRemDeletados[nInc] //NCF - 08/07/2016 - Found() está retornando sempre .F.
         Loop
      EndIf

      /* Atualiza o saldo para uso na tabela SD1 */
      If NFRemNewStruct() .And. !AtualizarSD1("EYY", SOMAR)
         lRet:= .F.
         Break
      EndIf

      EYY->(RecLock("EYY",.F.))
      If !AvFlags("EEC_LOGIX")  //NCF - 23/11/2017 - Só desfaz a vinculação com o embarque pois a inclusão/exclusão é feita pelo adapter de intergação de NF de Saída.
         EYY->(DbDelete())
      Else
         EYY->EYY_PREEMB := ""
      EndIf
      EYY->(MsUnlock())
   Next

   WK_NFRem->(DbGoTop())
   While WK_NFRem->(!EOF())

      // AST - 16/01/09
      If Empty(WK_NFRem->EYY_NFENT)
         If WK_NFRem->EYY_RECNO <> 0
            EYY->(DbGoTo(WK_NFRem->EYY_RECNO))
            If Empty(EYY->EYY_NFENT)
               WK_NFRem->(DbSkip())
               Loop
            EndIf
         Else
            WK_NFRem->(DbSkip())
            Loop
         EndIf
      EndIf

      If WK_NFRem->EYY_RECNO <> 0

         EYY->(DbGoTo(WK_NFRem->EYY_RECNO))
         EYY->(RecLock("EYY",.F.))

         If WK_NFRem->DBDELETE
            /* Redundância, para manter o legado... Se não tiver no array, não foi deletado no bloco acima */
            If AScan(aNfRemDeletados, WK_NFRem->EYY_RECNO) == 0
               /* Atualiza o saldo para uso na tabela SD1 */
               If NFRemNewStruct() .And. !AtualizarSD1("EYY", SOMAR)
                  lRet:= .F.
                  Break
               EndIf
               If !AvFlags("EEC_LOGIX")   //NCF - 23/11/2017 - Só desfaz a vinculação com o embarque pois a inclusão/exclusão é feita pelo adapter de intergação de NF de Saída.
                  EYY->(DbDelete())
               Else
                  EYY->EYY_PREEMB := ""
               EndIf
            EndIf

         Else

            /* Atualiza somente se houve alteração no registro */
            If NFRemHasChange()

               nQuantidade:= EYY->EYY_QUANT - WK_NFRem->EYY_QUANT
               AvReplace("WK_NFRem","EYY")

               EYY->EYY_FASE:= cOcorre

               /* Atualiza o saldo usado da tabela SD1 */
               If NFRemNewStruct() .And. !AtualizarSD1("WK_NFRem", SOMAR, nQuantidade)
                  lRet:= .F.
                  Break
               EndIf

            EndIf

         EndIf

         EYY->(MsUnlock())

      Else

         If !WK_NFRem->DBDELETE

            /* Atualiza o saldo usado da tabela SD1 */
            If NFRemNewStruct() .And. !AtualizarSD1("WK_NFRem", SUBTRAIR)
               lRet:= .F.
               Break
            EndIf

            EYY->(RecLock("EYY",.T.))

            AvReplace("WK_NFRem","EYY")

            //WFS 20/01/10
            If cOcorre == OC_PE
               EYY->EYY_PEDIDO:= M->EE7_PEDIDO
               EYY->EYY_FASE  := OC_PE
            Else
               EYY->EYY_PREEMB:= M->EEC_PREEMB
               EYY->EYY_FASE  := OC_EM
            EndIf

            EYY->(MsUnlock())

         EndIf
      EndIf

      WK_NFRem->(DbDelete())
      WK_NFRem->(DbSkip())

   EndDo

  // Wk_NfRem->(AvZap())
   aNfRemDeletados:= {}

End Sequence

RestOrd(aOrd)
Return lRet

/*
Função     : AE110LinOk()
Parâmetros : Nenhum
Retorno    : lRet = .T. ou .F.
Objetivos  : Validação das linhas da MsGetDb.
Autor      : Eduardo C. Romanini
Data/Hora  : 18/11/2008 às 10:30
Revisão    : WFS - 19/01/2010
             Inclusão do tratamento de nota fiscal de remessa no pedido de exportação,
             para atender ao convênio ICMS n.º 84 no DOU de 29/09/09, NFe.
*/
*-------------------*
Function AE110LinOk()
*-------------------*
Local lRet := .T.

Local nPos   := 0

Local aNfItem := {}
Local aPedItem:= {}
Local cOldFil := ""
Local bOldFil := ""

Begin Sequence

   If Wk_NFRem->DBDELETE
      Break
   EndIf

   If cOcorre == OC_PE //Fase de pedido

      cOldFil:= WorkIt->(DBFilter())
      bOldFil:= &("{|| " + WorkIt->(DBFilter()) + "}")


      //Carrega os itens do pedido de exportação
      WorkIt->(DBClearFilter())

      WorkIt->(DBGoTop())
      While WorkIt->(!Eof())

         AAdd(aPedItem, WorkIt->EE8_SEQUEN)
         WorkIt->(DBSkip())
      EndDo

      If !Empty(cOldFil)
         WorkIt->(DBSetFilter(bOldFil, cOldFil))
      EndIf


      //Verifica se o item digitado está na WorkIt
      If !Empty(Wk_NfRem->EYY_SEQUEN) .And. !Wk_NfRem->DBDELETE
         nPos:= AScan(aPedItem, Wk_NfRem->EYY_SEQUEN)

         If nPos == 0
            lRet := .F.
            MsgInfo(STR0004, STR0001) //O item digitado não existe no processo. / Atenção
            Break
         EndIf
      Else
         lRet := .F.
         MsgInfo(STR0005, STR0001) //O item do pedido de exportação não foi informado. / Atenção
         Break
      EndIf


   ElseIf cOcorre == OC_EM //Fase de embarque

      cOldFil := WorkIp->(dbFilter())
      bOldFil := &("{|| "+WorkIp->(dbFilter())+"}")

      /////////////////////////////////////////////////////////
      //Carrega todas as Notas Fiscais dos itens do Embarque.//
      /////////////////////////////////////////////////////////
      WorkIp->(DbClearFilter())

      WorkIp->(DbGoTop())
      While WorkIp->(!EOF())

         If !Empty(WorkIP->WP_FLAG)
            AAdd(aNfItem, {WorkIp->EE9_NF, WorkIp->EE9_SERIE, WorkIp->EE9_RE, WorkIp->EE9_SEQUEN, WorkIp->EE9_PEDIDO})
         EndIf

         WorkIp->(DbSkip())
      EndDo

      If !Empty(cOldFil)
         WorkIP->(dbSetFilter(bOldFil,cOldFil))
      EndIf

      //////////////////////////////////////////////////////////////////////////////
      //Verifica se a Nota Fiscal de Saída está digitada em algum Item do Embarque//
      //////////////////////////////////////////////////////////////////////////////
      If !Empty(Wk_NfRem->EYY_NFSAI) .and. !Wk_NfRem->DBDELETE
         nPos := aScan(aNfItem,{|e| e[1] + e[2] == Wk_NfRem->EYY_NFSAI + Wk_NfRem->EYY_SERSAI })

         If nPos == 0
            lRet := .F.
            MsgInfo(STR0006, STR0001) //A Nota Fiscal digitada não pertence a nenhum item do Embarque / Atenção
            Break
         EndIf
      Else
         lRet := .F.
         MsgInfo(STR0007, STR0001) //Informações de N.F. e Série de Saída incompletos /Atenção
         Break
      EndIf

      ///////////////////////////////////////////////////////////////////////
      //Verifica se o R.E. digitado está digitado em algum Item do Embarque//
      ///////////////////////////////////////////////////////////////////////


      //Verifica se o pedido informado está digitado em algum item do embarque e se
      //corresponde ao item digitado
      If !Empty(Wk_NfRem->EYY_PEDIDO) .And. !Wk_NfRem->DBDELETE
         nPos:= aScan(aNfItem, {|x| x[4] + x[5] == Wk_NfRem->EYY_SEQUEN + Wk_NfRem->EYY_PEDIDO}) //VERIFICAR

         If nPos == 0
            MsgInfo(STR0011, STR0001) //O pedido/ sequência digitado não pertence ao embarque - Atenção
            lRet:= .F.
            Break
         EndIf
      ElseIf !Wk_NfRem->DBDELETE
         MsgInfo(STR0012, STR0001) //Informações do pedido incompletas. / Atenção
         lRet:= .F.
         Break
      EndIf

      //WFS 21/05/2010
      //Validação para impedir a inclusao de linhas duplicadas na Work Wk_NfRem
      lRet:= ValidaLinhaAE110(Wk_NfRem->(EYY_RE + EYY_NFSAI + EYY_SERSAI + EYY_NFENT + EYY_SERENT + EYY_FORN + EYY_FOLOJA + EYY_PEDIDO + EYY_SEQUEN))
      If !lRet
         Break
      EndIf

      /* A quantidade será preenchida automaticamente. Quando zerada, não será gravada.
         Se for digitado 0, deve ser validado na digitação. */
      If !NFRemNewStruct()
         //Validação da quantidade
         If Wk_NfRem->(FieldPos("EYY_QUANT")) > 0 .And. Wk_NfRem->EYY_QUANT == 0
            MsgInfo(STR0026, STR0001) //Quantidade não informada. / Atenção
            lRet:= .F.
            Break
         EndIf
      EndIf

   EndIf

   //DFS - 02/01/13 - Inclusão de tratamento para que, caso não encontre os dados na SF1, apresenta mensagem.
   If !NFRemNewStruct() .Or. !Empty(Wk_NfRem->EYY_NFENT)
      If !AvFlags("EEC_LOGIX") //NCF - 23/11/2017
         If !SF1->(DbSeek(xFilial("SF1")+AvKey(Wk_NfRem->EYY_NFENT,"F1_DOC")+AvKey(Wk_NfRem->EYY_SERENT,"F1_SERIE")+AvKey(Wk_NfRem->EYY_FORN,"F1_FORNECE")+AvKey(Wk_NfRem->EYY_FOLOJA,"F1_LOJA")))
            MsgInfo(STR0164,STR0001)//"Dados Inválidos. Favor verificar Nota Fiscal de Entrada, Série e/ou Fornecedor e Loja digitados.", "Atenção"
            lRet:= .F.
         EndIf
      EndIf
   EndIf

  If lRet .And. !EYYCHVNFE(xFilial("SF1"),Wk_NfRem->EYY_NFENT,Wk_NfRem->EYY_SERENT,Wk_NfRem->EYY_FORN,Wk_NfRem->EYY_FOLOJA) //THTS - 05/03/2018 - Verifica se a nota de entrada possui Chave de Acesso F1_CHVNFE
    lRet := .F.
  EndIf

End Sequence

Return lRet

/*
Função     : ValidaLinhaAE110
Parâmetros : cChave
Retorno    : lRet - .T. ou .F.
Objetivos  : Verificar se a linha digitada já existe na Work
Autor      : Wilsimar Fabrício da Silva
Data       : 21/05/2010
Revisão    :
*/

Static Function ValidaLinhaAE110(cChave)
Local aOrd:= {}
Local lRet:= .T.
Local nRecNo:= 0

Begin Sequence

   If NFRemNewStruct()
      Break
   EndIf

   nRecNo:= Wk_NfRem->(RecNo())
   aOrd:= SaveOrd({"Wk_NfRem"})

   Wk_NfRem->(DBGoTop())
   While Wk_NfRem->(!Eof())

      If !Wk_NfRem->DBDELETE .And.;
         nRecNo <> Wk_NfRem->(RecNo()) .And.;
         cChave == Wk_NfRem->(EYY_RE + EYY_NFSAI + EYY_SERSAI + EYY_NFENT + EYY_SERENT + EYY_FORN + EYY_FOLOJA + EYY_PEDIDO + EYY_SEQUEN)

         MsgInfo(STR0013, STR0001) //Este registro já existe. Favor verificar. / Atenção
         lRet:= .F.
         Break

      EndIf
      Wk_NfRem->(DBSkip())
   EndDo

End Sequence

RestOrd(aOrd, .T.)
Return lRet

/*
Função     : AE110ValNfRem
Parâmetros : cCampo: Campo que será validado.
Retorno    : lRet = .T. ou .F.
Objetivos  : Validação dos campos de preenchimento das NFs de Entrada.
Autor      : Eduardo C. Romanini
Data/Hora  : 18/11/2008 às 10:30
Revisão    : WFS - 19/01/2010
             Inclusão do tratamento de nota fiscal de remessa no pedido de exportação,
             para atender ao convênio ICMS n.º 84 no DOU de 29/09/09, NFe.
*/
*----------------------------*
Function AE110ValNfRem(cCampo)
*----------------------------*
Local lRet      := .T.
Local nPos      := 0
Local aNfItem   := {}
Local aOrd      := {}
Local aArea     := GetArea()
Local cOldFil   := ""
Local bOldFil   := ""
Local cForn     := ""
Local cLoja     := ""
Local cNotaEnt  := "" 	 // LRS - 14/07/2014
Local lItens    := .F.   // GFP - 04/03/2013
Local i := 0, nSaldoTotal := 0, nSaldoUsado := 0   // GFP - 16/01/2014
Local nQtdWkIp:= 0
Local cProduto
Local nOldBrLin:= If(Type("nBrLin")=="N", nBrLin, 0)
Local lFiltroNCM:= EasyGParam("MV_EEC0051",, .F.)
Local nQtdeUMEmb := 0
Local nQtdeUMNFe := 0
Local lFimEspecNew := AvFlags("ROTINA_VINC_FIM_ESPECIFICO_RP12.1.20")
Local cChaveNFE  := ""

If Type("cOcorre") <> "C"
  Return NF400Valid(cCampo)
EndIf

Begin Sequence

   Do Case
      Case cOcorre == OC_PE
         aOrd   := SaveOrd({"WorkIt", "SF1", "SD1", "WK_NFRem"})
         cOldFil:= WorkIt->(DBFilter())
         bOldFil:= &("{|| "+WorkIt->(DBFilter())+"}")

         //Carrega todas as Notas Fiscais dos itens do Embarque.
         WorkIt->(DBClearFilter())

         WorkIt->(DBGoTop())
         While WorkIt->(!Eof())

            AAdd(aNfItem, {WorkIt->EE8_PEDIDO, WorkIt->EE8_SEQUEN})

            WorkIt->(DBSkip())
         EndDo

         If !Empty(cOldFil)
            WorkIt->(DBSetFilter(bOldFil, cOldFil))
         EndIf

      Case cOcorre == OC_EM
         aOrd   := SaveOrd({"WorkIp", "SF1", "SD1", "WK_NFRem"})
         cOldFil:= WorkIp->(dbFilter())
         bOldFil:= &("{|| "+WorkIp->(dbFilter())+"}")


         /////////////////////////////////////////////////////////
         //Carrega todas as Notas Fiscais dos itens do Embarque.//
         /////////////////////////////////////////////////////////
         WorkIp->(DbClearFilter())

         WorkIp->(DbGoTop())
         While WorkIp->(!EOF())

            If !Empty(WorkIP->WP_FLAG)
               AAdd(aNfItem, {WorkIp->EE9_NF, WorkIp->EE9_SERIE, WorkIp->EE9_RE, WorkIp->EE9_SEQUEN, WorkIp->EE9_PEDIDO, WorkIp->EE9_FABR, WorkIp->EE9_FALOJA, WorkIp->EE9_COD_I}) //LGS-10/02/2016 - Incluido o código do item
            EndIf

            WorkIp->(DbSkip())
         EndDo

         If !Empty(cOldFil)
            WorkIP->(dbSetFilter(bOldFil,cOldFil))
         EndIf
   End Case

   /////////////////////////
   //Inicio das validações//                                         Z
   /////////////////////////
   If cCampo == "EYY_RE"

      ///////////////////////////////////////////////////////////////////////
      //Verifica se o R.E. digitado está digitado em algum Item do Embarque//
      ///////////////////////////////////////////////////////////////////////
      If !Empty(M->EYY_RE) .and. !Wk_NfRem->DBDELETE
         nPos := aScan(aNfItem,{|e| e[3] == M->EYY_RE })

         If nPos == 0
            lRet := .F.
            //MsgInfo("O R.E digitado não pertence a nenhum item do Embarque","Atenção") - nopado por WFS em 18/01/2010
            MsgInfo(STR0008, STR0001) //O R.E digitado não pertence ao item do Embarque / Atenção
            Break
         EndIf
      EndIf

   ElseIf cCampo == "EYY_SEQUEN"

      If cOcorre == OC_PE //Fase de pedido

         If !Empty(M->EYY_SEQUEN) .and. !Wk_NfRem->DBDELETE
            nPos:= AScan(aNfItem, {|x| x[2] == M->EYY_SEQUEN})

            If nPos == 0
               M->EYY_SEQUEN := Space(AvSX3("EYY_SEQUEN",AV_TAMANHO)-Len(AllTrim(M->EYY_SEQUEN)))+AllTrim(Str(Val(M->EYY_SEQUEN)))
               nPos:= AScan(aNfItem, {|x| x[2] == M->EYY_SEQUEN})
            EndIf

            If nPos == 0
               lRet := .F.
               MsgInfo(STR0004, STR0001) //O item digitado não existe no processo / Atenção
               Break
            EndIf
         Else
            lRet := .F.
            MsgInfo(STR0014, STR0001) //Informações incompletas / Atenção
            Break
         EndIf
      EndIf

      If cOcorre == OC_EM //Fase de embarque

         //Verifica se o item digitado existe na WorkIp
         If !Empty(M->EYY_SEQUEN) .and. !Wk_NfRem->DBDELETE
            nPos:= AScan(aNfItem, {|e| e[4] == M->EYY_SEQUEN})

           If nPos == 0
               M->EYY_SEQUEN := Space(AvSX3("EYY_SEQUEN",AV_TAMANHO)-Len(AllTrim(M->EYY_SEQUEN)))+AllTrim(Str(Val(M->EYY_SEQUEN)))
              nPos:= AScan(aNfItem, {|x| x[4] == M->EYY_SEQUEN})
            EndIf

            If nPos == 0
               lRet := .F.
               MsgInfo(STR0004, STR0001) //O item digitado não existe no processo / Atenção
               Break
            Else
               Wk_NfRem->EYY_NFSAI := aNfItem[nPos][1]
               Wk_NfRem->EYY_SERSAI:= aNfItem[nPos][2]
               Wk_NfRem->EYY_RE    := aNfItem[nPos][3]
               Wk_NfRem->EYY_PEDIDO:= aNfItem[nPos][5]
               If NFRemNewStruct()
                  WK_NFRem->EYY_COD_I := aNfItem[nPos][8]
               Else
                  WK_NFRem->EE9_COD_I := aNfItem[nPos][8] //LGS-10/02/2016
               EndIf
            EndIf
         Else
            lRet := .F.
            MsgInfo(STR0014, STR0001) //Informações incompletas / Atenção
            Break
         EndIf
      EndIf
   //WFS 22/01/10
   ElseIf cCampo == "EYY_PEDIDO"
      If cOcorre == OC_EM //Fase de embarque
         If !Empty(M->EYY_PEDIDO) .And. !Wk_NfRem->DBDELETE
            nPos:= aScan(aNfItem, {|x| x[4] + x[5] == Wk_NfRem->EYY_SEQUEN + M->EYY_PEDIDO})

            If nPos == 0
               MsgInfo(STR0011, STR0001) //O pedido/ sequência digitado não pertence ao embarque - Atenção
               lRet:= .F.
               Break
            Else
               Wk_NfRem->EYY_NFSAI := aNfItem[nPos][1]
               Wk_NfRem->EYY_SERSAI:= aNfItem[nPos][2]
               Wk_NfRem->EYY_RE    := aNfItem[nPos][3]
            EndIf
         Else
            MsgInfo(STR0014, STR0001) //Informações incompletas / Atenção
            lRet:= .F.
            Break
         EndIf
      EndIf
   ElseIf cCampo == "EYY_NFSAI"

      //////////////////////////////////////////////////////////////////////////////
      //Verifica se a Nota Fiscal de Saída está digitada em algum Item do Embarque//
      //////////////////////////////////////////////////////////////////////////////
      If !Empty(M->EYY_NFSAI) .and. !Wk_NfRem->DBDELETE
         nPos := aScan(aNfItem,{|e| e[1]== M->EYY_NFSAI})

         If nPos == 0
            lRet := .F.
            MsgInfo(STR0006, STR0001) //A Nota Fiscal digitada não pertence a nenhum item do Embarque / Atenção
            Break
         EndIf
      Else
         lRet := .F.
         MsgInfo(STR0015, STR0001) //Informações de N.F. de Saída incompletas / Atenção
         Break
      EndIf

   ElseIf cCampo == "EYY_SERSAI"

      ////////////////////////////////////////////////////////////////////////////////
      //Verifica se a Série da N.F. de Saída está digitada em algum Item do Embarque//
      ////////////////////////////////////////////////////////////////////////////////
      If !Empty(Wk_NFRem->EYY_NFSAI) .and. !Wk_NfRem->DBDELETE
         nPos := aScan(aNfItem,{|e| e[1] + e[2] == Wk_NFRem->EYY_NFSAI + M->EYY_SERSAI })

         If nPos == 0
            lRet := .F.
            MsgInfo(STR0006, STR0001) // A Nota Fiscal digitada não pertence a nenhum item do Embarque / Atenção
            Break
         EndIf
      Else
         lRet := .F.
         MsgInfo(STR0007, STR0001) //Informações de N.F. e Série de Saída incompletos / Atenção
         Break
      EndIf

   ElseIf cCampo == "EYY_NFENT"

      If Vazio() .And. Empty(Wk_NfRem->EYY_NFENT)
         lRet:= .T.
         Break
      EndIf

      If NFRemNewStruct()
         If lExecConPad1
            ConPad1(,,, "EYY","EYY_NFENT",,.F.)
            lRet:= .T.
            Break
         EndIf
         lExecConPad1:= .T.
      EndIf

      SF1->(DbSetOrder(1))

      If !Empty(M->EYY_NFENT) .And. !Empty(Wk_NfRem->EYY_SERENT) .And. !Empty(Wk_NfRem->EYY_FORN) .And. !Empty(Wk_NfRem->EYY_FOLOJA)

         cSerie:= AvKey(Wk_NfRem->EYY_SERENT, "F1_SERIE")
         cForn := AvKey(Wk_NfRem->EYY_FORN  , "F1_FORNECE")
         cLoja := AvKey(Wk_NfRem->EYY_FOLOJA, "F1_LOJA")

         //DFS - 13/12/12 - Inclusão de fornecedor e loja no seek para que, ao selecionar uma nota, sistema preencha corretamente os demais campos.
         If SF1->(DbSeek(xFilial("SF1")+AvKey(M->EYY_NFENT,"F1_DOC")+If(!Empty(cSerie), cSerie, "")+If(!Empty(cForn), cForn, "")+If(!Empty(cLoja), cLoja, "")))

            IF Wk_NfRem->(FieldPos("EYY_CHVNFE")) > 0
              If EYYCHVNFE(xFilial("SF1"),M->EYY_NFENT,cSerie,cForn,cLoja,@cChaveNFE) //THTS - 05/03/2018 - Verifica se a nota de entrada possui Chave de Acesso F1_CHVNFE
                Wk_NfRem->EYY_CHVNFE := cChaveNFE
              Else
                lRet := .F.
                Wk_NfRem->EYY_CHVNFE := ""
              EndIf
            EndIF
            //LRS - 07/07/2015
            IF !Empty(cForn) .and. !Empty(cLoja) .and. !Empty(cSerie)
	            Wk_NfRem->EYY_FORN   := SF1->F1_FORNECE
	            Wk_NfRem->EYY_FOLOJA := SF1->F1_LOJA
	            Wk_NfRem->EYY_SERENT := SF1->F1_SERIE
            EndIF
            Wk_NfRem->EYY_DESFOR := Posicione("SA2",1,xFilial("SA2")+Wk_NfRem->EYY_FORN+Wk_NfRem->EYY_FOLOJA,"A2_NOME")

            cAlias := If(cOcorre == OC_EM,"WorkIp","WorkIt")

            If cOcorre == OC_EM  // GFP - 18/12/2013
               WorkIp->(Dbseek(Wk_NfRem->(EYY_PEDIDO+EYY_SEQUEN)))
               //cItem := WorkIp->EE9_COD_I
            EndIf

            /* Quando habilitado o filtro por NCM, não validar o código do item */
            If NFRemNewStruct() .And. lFiltroNCM
               lItens:= .T.
            Else
               lItens := .F.
               &(cAlias)->(DbGoTop())
               SD1->(DbSetOrder(2))  // D1_FILIAL+D1_COD+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA
               Do While &(cAlias)->(!Eof())
                  If !SD1->(DbSeek(xFilial("SD1") +;
                                   If(cOcorre == OC_EM, WorkIp->EE9_COD_I, &(cAlias+"->EE8_COD_I")) +; //AAF 23/10/2014 - Alterado para considerar o item posicionado no loop da WorkIp
                                   M->EYY_NFENT +;
                                   if(!Empty(cSerie),cSerie,"") +;
                                   If(!Empty(cForn), cForn, "") +;
                                   If(!Empty(cLoja), cLoja, "")))
                     lItens := .F.
                     cCodIt := ""
                  Else
                     lItens := .T.
                     cCodIt := SD1->D1_COD
                     Exit
                  EndIf
                  &(cAlias)->(DbSkip())
               EndDo
            EndIf

            If lRet .And. !lItens
               MsgAlert(STR0174, STR0001) //"Não é possível vincular a NF informada, pois os itens presentes no processo não coincidem." // "Atenção"
               M->EYY_NFENT         := ""
               Wk_NfRem->EYY_NFENT  := ""
               Wk_NfRem->EYY_SERENT := ""
               Wk_NfRem->EYY_FORN   := ""
               Wk_NfRem->EYY_FOLOJA := ""
               Wk_NfRem->EYY_DESFOR := ""
               Wk_NfRem->EYY_CHVNFE := ""
               lRet:= .F.
            EndIf

            If !NFRemNewStruct()
               Wk_NfRem->EYY_QUANT := 0
            EndIf

            // ** Fim GFP - 04/03/2013

            //WFS 21/05/2010 - Validação do fornecedor informado
            If lRet .And. cOcorre == OC_EM  .AND. lItens .And. !NFRemNewStruct() //Fase de embarque
               nPos:= AScan(aNfItem, {|x| x[4] + x[5] + x[6] + x[7] == ;
                                      Wk_NfRem->EYY_SEQUEN + Wk_NfRem->EYY_PEDIDO + Wk_NfRem->EYY_FORN + Wk_NfRem->EYY_FOLOJA})
               If nPos == 0
                  lRet:= MsgYesNo(STR0025,STR0001) //O fabricante desta nota fiscal não é o mesmo do item do processo. Deseja prosseguir?
				          If !lRet
                     Wk_NfRem->EYY_FORN   := ""
                     Wk_NfRem->EYY_FOLOJA := ""
                     Wk_NfRem->EYY_DESFOR := ""
                     Wk_NfRem->EYY_SERENT := ""
                     Wk_NfRem->EYY_CHVNFE := ""
                  EndIf
               EndIf
            EndIf

         Else
            If !NFRemNewStruct()
               Wk_NfRem->EYY_NFENT  := ""
               Wk_NfRem->EYY_FORN   := ""
               Wk_NfRem->EYY_FOLOJA := ""
               Wk_NfRem->EYY_DESFOR := ""
               Wk_NfRem->EYY_SERENT := ""
               Wk_NfRem->EYY_CHVNFE := ""
            EndIf
         EndIf
      Else
         If !NFRemNewStruct()
            Wk_NfRem->EYY_FORN   := ""
            Wk_NfRem->EYY_FOLOJA := ""
            Wk_NfRem->EYY_DESFOR := ""
            Wk_NfRem->EYY_SERENT := ""
            Wk_NfRem->EYY_CHVNFE := ""
         EndIf
      EndIf

   ElseIf cCampo == "EYY_SERENT"

      If Vazio()
         lRet:= .T.
         Break
      EndIf

      If !Empty(Wk_NfRem->EYY_NFENT) .and. !Wk_NfRem->DBDELETE
         SF1->(DbSetOrder(1))
         If SF1->(DbSeek(xFilial("SF1")+AvKey(Wk_NfRem->EYY_NFENT,"F1_DOC")+AvKey(M->EYY_SERENT,"F1_SERIE")))

            Wk_NfRem->EYY_FORN   := SF1->F1_FORNECE
            Wk_NfRem->EYY_FOLOJA := SF1->F1_LOJA
            Wk_NfRem->EYY_DESFOR := Posicione("SA2",1,xFilial("SA2")+Wk_NfRem->EYY_FORN+Wk_NfRem->EYY_FOLOJA,"A2_NOME")

            If EYYCHVNFE(xFilial("SF1"),Wk_NfRem->EYY_NFENT,M->EYY_SERENT,Wk_NfRem->EYY_FORN,Wk_NfRem->EYY_FOLOJA,@cChaveNFE) //THTS - 05/03/2018 - Verifica se a nota de entrada possui Chave de Acesso F1_CHVNFE
              Wk_NfRem->EYY_CHVNFE := cChaveNFE
            Else
              lRet := .F.
              Wk_NfRem->EYY_CHVNFE := ""
            EndIf

            //WFS 21/05/2010 - Validação do fornecedor informado
            If lRet .And. cOcorre == OC_EM //Fase de embarque
               nPos:= AScan(aNfItem, {|x| x[4] + x[5] + x[6] + x[7] == ;
                                      Wk_NfRem->EYY_SEQUEN + Wk_NfRem->EYY_PEDIDO + Wk_NfRem->EYY_FORN + Wk_NfRem->EYY_FOLOJA})
               If nPos == 0
                  lRet:= MsgYesNo(STR0025,STR0001) //O fabricante desta nota fiscal não é o mesmo do item do processo. Deseja prosseguir?
               EndIf
            EndIf

         Else
            Wk_NfRem->EYY_FORN   := ""
            Wk_NfRem->EYY_FOLOJA := ""
            Wk_NfRem->EYY_DESFOR := ""
         EndIf

      EndIf

   ElseIf cCampo == "EYY_FORN"

      If Vazio()
         Wk_NfRem->EYY_FOLOJA := ""
         Wk_NfRem->EYY_DESFOR := ""
         lRet:= .T.
         Break
      EndIf

      SA2->(DbSetOrder(1))

      cLoja:= ""
      If !Empty(Wk_NfRem->EYY_FOLOJA)
         cLoja:= Wk_NfRem->EYY_FOLOJA
      EndIf

      If SA2->(DBSeek(xFilial() + M->EYY_FORN + cLoja))
         Wk_NfRem->EYY_FOLOJA := SA2->A2_LOJA
         Wk_NfRem->EYY_DESFOR := SA2->A2_NOME

        If EYYCHVNFE(xFilial("SF1"),Wk_NfRem->EYY_NFENT,Wk_NfRem->EYY_SERENT,M->EYY_FORN,Wk_NfRem->EYY_FOLOJA,@cChaveNFE) //THTS - 05/03/2018 - Verifica se a nota de entrada possui Chave de Acesso F1_CHVNFE
          Wk_NfRem->EYY_CHVNFE := cChaveNFE
        Else
          lRet := .F.
          Wk_NfRem->EYY_CHVNFE := ""
        EndIf

      Else
         MsgInfo(STR0175, STR0070) //"Código do fornecedor inválido.", "Aviso"
         lRet:= .F.
         Break
      EndIf

   ElseIf cCampo == "EYY_FOLOJA"

      If Vazio()
         lRet:= .T.
         Break
      EndIf

      SA2->(DbSetOrder(1))

      cForn:= ""
      If Empty(Wk_NfRem->EYY_FORN)
         MsgInfo(STR0176, STR0070) //"O código do fornecedor não foi informado.", "Aviso"
         lRet:= .F.
         Break
      Else
         cForn:= Wk_NfRem->EYY_FORN
      EndIf

      If SA2->(DBSeek(xFilial() + Wk_NfRem->EYY_FORN + M->EYY_FOLOJA))
         Wk_NfRem->EYY_DESFOR := SA2->A2_NOME

        If EYYCHVNFE(xFilial("SF1"),Wk_NfRem->EYY_NFENT,Wk_NfRem->EYY_SERENT,Wk_NfRem->EYY_FORN,M->EYY_FOLOJA,@cChaveNFE) //THTS - 05/03/2018 - Verifica se a nota de entrada possui Chave de Acesso F1_CHVNFE
          Wk_NfRem->EYY_CHVNFE := cChaveNFE
        Else
          lRet := .F.
          Wk_NfRem->EYY_CHVNFE := ""
        EndIf

      Else
         MsgInfo(STR0177, STR0070) //"O código da loja é invpalido para o fornecedor informado.", "Aviso"
         lRet:= .F.
         Break
      EndIf


   ElseIf cCampo == "EYY_QUANT"     // GFP - 04/03/2013 - Inclusão de validação de quantidade.

      /* Esta validação será executada apenas na fase de embarque.
         O campo referente ao código do produto não existe na tabela EYY e nem na
         work  Wk_NfRem, na fase de pedido, inviabilizando esta validação.
         Além de ser executada no preenchimento do campo, esta validação será executada na
         função AE110TudoOk, na fase de embarque, garantindo que ainda que tenha sido informada uma
         quantidade superior ao disponível na fase de pedido, na finalização do embarque esta quantidade
         seja persistida. */

      If cOcorre == OC_PE //Fase de pedido
         Break
      EndIf

      If NFRemNewStruct()

         If M->EYY_QUANT == 0
            MsgInfo(STR0026, STR0001) //Quantidade não informada. / Atenção
            lRet:= .F.
            Break
         EndIf

         If M->EYY_QUANT <> Wk_NfRem->EYY_QUANT .And. Empty(Wk_NfRem->EYY_NFENT)
            MsgInfo(STR0178, STR0001) //"Antes de alterar a quantidade, informe o documento de entrada."
            lRet:= .F.
            Break
         EndIf

      EndIf

      If !Empty(Wk_NfRem->EYY_NFENT)

         If NFRemNewStruct()
            If lFiltroNCM
               cProduto:= Wk_NfRem->EYY_D1PROD
            Else
               cProduto:= Wk_NfRem->EYY_COD_I
            EndIf
         Else
            nPos:= AScan(aItemPed, {|x| x[1] == Wk_NfRem->EYY_SEQUEN})  // GFP - 08/01/2014

            If nPos == 0
               MsgInfo(STR0179, STR0001) //"Sequência do pedido não encontrada.", "Atenção"
               lRet:= .F.
               Break
            EndIf

            cProduto:= If(Len(aItemPed) > 0, aItemPed[nPos][3], Wk_NfRem->EE9_COD_I)
         EndIf

         SD1->(DbSetOrder(2)) //D1_FILIAL+D1_COD+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA

         //LGS-07/03/2014
         If SD1->(DbSeek(xFilial("SD1") +;
                         cProduto +;
                         Wk_NfRem->EYY_NFENT +;
                         Wk_NfRem->EYY_SERENT +;
                         Wk_NfRem->EYY_FORN +;
                         Wk_NfRem->EYY_FOLOJA))

            // GFP - 16/01/2014 - Tratamento para validação de quantidade de itens com o mesmo código.
            Do While SD1->(!Eof()) .AND. SD1->D1_FILIAL   == xFilial("SD1")       .AND.;
                                         SD1->D1_COD      == cProduto             .AND.;
                                         SD1->D1_DOC      == Wk_NfRem->EYY_NFENT  .AND.;
                                         SD1->D1_SERIE    == Wk_NfRem->EYY_SERENT .And.;
                                         SD1->D1_FORNECE  == Wk_NfRem->EYY_FORN   .And.;
                                         SD1->D1_LOJA     == Wk_NfRem->EYY_FOLOJA

               nSaldoTotal += SD1->D1_QUANT

               SD1->(DbSkip())
            EndDo

            //Verificar se a quantidade do item da NF foi usada na work em edição
            nRecNfRem := Wk_NfRem->(RecNo())
            cNotaEnt  := cProduto + Wk_NfRem->EYY_NFENT + Wk_NfRem->EYY_SERENT + Wk_NfRem->EYY_FORN + Wk_NfRem->EYY_FOLOJA

            If NFRemNewStruct()
               Wk_NfRem->(DBSetOrder(2)) //EYY_COD_I + EYY_PEDIDO + EYY_SEQUEN + EYY_NFSAI + EYY_SERSAI
               Wk_NfRem->(DBSeek(cProduto))
               If lFiltroNCM
                  Wk_NfRem->(DBGoTop())
               EndIf
            Else
               Wk_NfRem->(DbSetOrder(1)) //EYY_SEQUEN + EYY_NFSAI + EYY_SERSAI + EYY_NFENT + EYY_SERENT
               Wk_NfRem->(DbSeek(aItemPed[nPos][1]))
            EndIf

            /* Melhorar o filro por NCM */
            If !NFRemNewStruct() .Or. !lFiltroNCM
               While Wk_NfRem->(!Eof()) .And.;
                     If(!lFiltroNCM, !If(NFRemNewStruct(), Wk_NfRem->EYY_COD_I == cProduto, Wk_NfRem->EYY_SEQUEN == aItemPed[nPos][1]), .T.)


                  If Wk_NfRem->DBDELETE
                     Wk_NfRem->(DBSkip())
                     Loop
                  EndIf

                  /* descartar notas fiscais diferentes vinculadas ao produto */
                  If cNotaEnt <> If(NFRemNewStruct(), If(lFiltroNCM, Wk_NfRem->EYY_D1PROD, Wk_NfRem->EYY_COD_I), Wk_NfRem->EE9_COD_I) + Wk_NfRem->EYY_NFENT + Wk_NfRem->EYY_SERENT + Wk_NfRem->EYY_FORN + Wk_NfRem->EYY_FOLOJA
                     Wk_NfRem->(DBSkip())
                     Loop
                  EndIf

                  /* não pode considerar o item em edição */
                  If Wk_NfRem->(Recno()) <> nRecNfRem
                     nSaldoUsado += Wk_NfRem->EYY_QUANT
                  EndIf

                  Wk_NfRem->(DBSkip())
               EndDo
            EndIf

            Wk_NfRem->(DbGoTo(nRecNfRem))

            /* Verificar a quantidade do item/ nota usada em outros processos de embarque. */
            nSaldoUsado += RetQtdUsada()

            If !IsInCallStack("AE110TudoOk")

               //Posiciona o registro da WorkIP, para comparação da quantidade
               If NFRemNewStruct()
                  WorkIp->(DBSetOrder(2)) //EE9_SEQEMB + EE9_NF + EE9_SERIE
                  WorkIp->(DBSeek(Wk_NfRem->(EYY_SEQEMB + EYY_NFSAI + EYY_SERSAI)))
               Else
                  PosWorkIP()
               EndIf

               nQtdWkIp:= QtdUsadaWorkIP()

               If M->EYY_QUANT + nQtdWkIp > WorkIP->EE9_SLDINI
                  MsgAlert(StrTran(StrTran(STR0171, "####", AllTrim(Str(WorkIP->EE9_SLDINI)) + " " + WorkIp->EE9_UNIDAD), "$$$$", AllTrim(Str(WorkIP->EE9_SLDINI-nQtdWkIp)) + " " + WorkIp->EE9_UNIDAD), STR0070) //"A somatória das quantidades informadas ultrapassam a quantidade do item no processo de embarque. Quantidade do item no embarque: #### - saldo disponível para vinculação: $$$$.", "Aviso"
                  lRet:= .F.
                  Break
               EndIf

               //O posicionamento da WORKIP (acima) deve ser mantido para uso da unidade de medida
               If M->EYY_QUANT > ((nSaldoTotal-nSaldoUsado)/*-nQtdNfEnt*/)  // GFP - 16/01/2014
                  MsgAlert(StrTran(STR0165, "####", AllTrim(Str(nSaldoTotal-nSaldoUsado)) + " " + WorkIp->EE9_UNIDAD), STR0070)     // "A quantidade informada é maior que o saldo disponível para vinculação desta nota fiscal de remessa com fim específico de exportação. Quantidade disponível para vinculação: ####.", "Aviso"
                  lRet := .F.
                  Break
               EndIf

               If NFRemNewStruct()
                  /* Verifica se será necessário criar, atualizar ou excluir a linha para associação
                     da nota fiscal de entrada.  */
                  If M->EYY_QUANT <> Wk_NfRem->EYY_QUANT
                  //nQtdeUMEmb := EasyConvQt( Wk_NfRem->EYY_COD_I , {{ If(lFimEspecNew, Wk_NfRem->EYY_UNIDAD ,WorkIp->EE9_UNIDAD), Wk_NfRem->EYY_QUANT}}                                                               , If(lFimEspecNew, Wk_NfRem->EYY_UMDSD1,WorkIp->EE9_UNIDAD) , .F. , /*oRefObjA*/)
                     nQtdeUMEmb := EasyConvQt( Wk_NfRem->EYY_COD_I , GetEYYQtds("Wk_NfRem", "WORK" , If(lFimEspecNew, Wk_NfRem->EYY_UNIDAD , WorkIp->EE9_UNIDAD) , If(lFimEspecNew, Wk_NfRem->EYY_UMDSD1,WorkIp->EE9_UNIDAD),,,"1")  , If(lFimEspecNew, Wk_NfRem->EYY_UMDSD1,WorkIp->EE9_UNIDAD) , .F. , /*oRefObjA*/)
                  //nQtdeUMNFe := EasyConvQt( Wk_NfRem->EYY_COD_I , {{ If(lFimEspecNew, Wk_NfRem->EYY_UNIDAD ,WorkIp->EE9_UNIDAD), M->EYY_QUANT       }}                                                               , If(lFimEspecNew, Wk_NfRem->EYY_UMDSD1,WorkIp->EE9_UNIDAD) , .F. , /*oRefObjA*/)
                     nQtdeUMNFe := EasyConvQt( Wk_NfRem->EYY_COD_I , GetEYYQtds("M","MEMO" , If(lFimEspecNew, Wk_NfRem->EYY_UNIDAD , WorkIp->EE9_UNIDAD) , If(lFimEspecNew, Wk_NfRem->EYY_UMDSD1,WorkIp->EE9_UNIDAD),,,"1")  , If(lFimEspecNew, Wk_NfRem->EYY_UMDSD1,WorkIp->EE9_UNIDAD) , .F. , /*oRefObjA*/)
                     SaldoTmpSD1(WK_NFRem->SD1_RECNO, nQtdeUMEmb /*WK_NFRem->EYY_QUANT*/, SUBTRAIR)
                     AtuWk_NfRem(M->EYY_QUANT, Wk_NfRem->EYY_QUANT)
                     SaldoTmpSD1(WK_NFRem->SD1_RECNO, nQtdeUMNFe /*M->EYY_QUANT*/       , SOMAR)
                  EndIf
               EndIf

            Else
               If Wk_NfRem->EYY_QUANT > (nSaldoTotal-nSaldoUsado)
                  cVldQtd += "Pedido: " + AllTrim(Wk_NfRem->EYY_PEDIDO) + ENTER +;
                             "Sequencia: " + AllTrim(Wk_NfRem->EYY_SEQUEN) + ENTER +;
                             "Nota fiscal/ série: " + AllTrim(Wk_NfRem->EYY_NFENT) + "/ " + AllTrim(Wk_NfRem->EYY_SERENT) + ENTER +;
                             "Quantidade informada: " + AllTrim(Str(Wk_NfRem->EYY_QUANT)) + ENTER +;
                             "Quantidade disponível para vinculação: " + AllTrim(Str(nSaldoTotal-nSaldoUsado)) + ENTER + ENTER
                  lRet:= .F.
               EndIf
            EndIf
         EndIf
      EndIf
   EndIf

End Sequence

RestArea(aArea)
RestOrd(aOrd, .T.)
If NFRemNewStruct()
   nBrLin:= nOldBrLin
EndIf
oGetNfRem:oBrowse:Refresh()
Return lRet

/*
Função     : AE110TudoOk()
Parâmetros : Nenhum
Retorno    : lRet = .T. ou .F.
Objetivos  : Validação da tela de preenchimento de NFs de Entrada.
Autor      : Eduardo C. Romanini
Data/Hora  : 18/11/2008 às 10:30
Revisão    : WFS - 19/01/2010
             Inclusão do tratamento de nota fiscal de remessa no pedido de exportação,
             para atender ao convênio ICMS n.º 84 no DOU de 29/09/09, NFe.
*/
*--------------------*
Function AE110TudoOk()
*--------------------*
Local lRet := .T.

Local nPos   := 0

Local aNfItem := {}
Local aOrd    := {}
Local aArea   := GetArea()
Local aPedItem:= {}

Local cOldFil := ""

Local bOldFil := ""

Local aItemNfEnt := {}

Private cVldQtd:= ""

Begin Sequence


   Do Case

      Case cOcorre == OC_PE //Pedido de exportação

         aOrd   := SaveOrd({"WorkIt", "SF1"})
         cOldFil:= WorkIt->(DBFilter())
         bOldFil:= &("{|| "+WorkIt->(DBFilter())+"}")

         //Carrega os itens do pedido de exportação
         WorkIt->(DBClearFilter())

         WorkIt->(DBGoTop())
         While WorkIt->(!Eof())

            AAdd(aPedItem, WorkIt->EE8_SEQUEN)
            WorkIt->(DBSkip())
         EndDo

         If !Empty(cOldFil)
            WorkIt->(DBSetFilter(bOldFil, cOldFil))
         EndIf


      Case cOcorre == OC_EM //Embarque

         aOrd    := SaveOrd({"WorkIp","SF1"})
         cOldFil := WorkIp->(dbFilter())
         bOldFil := &("{|| "+WorkIp->(dbFilter())+"}")

         /////////////////////////////////////////////////////////
         //Carrega todas as Notas Fiscais dos itens do Embarque.//
         /////////////////////////////////////////////////////////
         WorkIp->(DbClearFilter())

         WorkIp->(DbGoTop())


         While WorkIp->(!EOF())

            If !Empty(WorkIP->WP_FLAG)
            /* nopado por WFS em 18/01/2010
               nPos := aScan(aNfItem,{|e| AllTrim(e[1]) + AllTrim(e[2]) + AllTrim(e[3]) == AllTrim(WorkIp->EE9_NF) + AllTrim(WorkIp->EE9_SERIE)+ AllTrim(WorkIp->EE9_RE) })

               If nPos == 0
                  aAdd(aNfItem,{WorkIp->EE9_NF,WorkIp->EE9_SERIE,WorkIp->EE9_RE})
               EndIf */
               AAdd(aNfItem, {WorkIp->EE9_NF, WorkIp->EE9_SERIE, WorkIp->EE9_RE, WorkIp->EE9_SEQUEN, WorkIp->EE9_PEDIDO})
            EndIf

            WorkIp->(DbSkip())
         EndDo

         If !Empty(cOldFil)
            WorkIP->(dbSetFilter(bOldFil,cOldFil))
         EndIf

         WorkIP->(DBGoTop())
   End Case

   /////////////////////////
   //Inicio das validações//
   /////////////////////////
   WK_NfRem->(DbGoTop())
   //aNfRemDeletados:= {}
   While WK_NfRem->(!EOF())

      If cOcorre == OC_PE //Pedido de exportação

         //Verifica se o item digitado está na WorkIt
         If !Empty(Wk_NfRem->EYY_SEQUEN) .And. !Wk_NfRem->DBDELETE
            nPos:= AScan(aPedItem, Wk_NfRem->EYY_SEQUEN)

            If nPos == 0
               lRet := .F.
               MsgInfo(STR0004, STR0001) //O item digitado não existe no processo / Atenção
               Break
            EndIf
         ElseIf Wk_NfRem->DBDELETE
            If Wk_NfRem->EYY_RECNO <> 0
               AAdd(aNfRemDeletados, Wk_NfRem->EYY_RECNO)
            EndIf
            lRet:= .T.
            Wk_NfRem->(DBSkip())
            Loop
         Else
            lRet := .F.
            MsgInfo(STR0005, STR0001) //O item do pedido de exportação não foi informado / Atenção
            Break
         EndIf

      ElseIf cOcorre == OC_EM //Embarque

         ///////////////////////////////////////////////////////////////////////
         //Verifica se o R.E. digitado está digitado em algum Item do Embarque//
         ///////////////////////////////////////////////////////////////////////
         If !Empty(Wk_NfRem->EYY_RE) .and. !Wk_NfRem->DBDELETE

            nPos:= AScan(aNfItem, {|e| e[3] + e[4] == Wk_NfRem->EYY_RE + Wk_NfRem->EYY_SEQUEN})

            If nPos == 0
               lRet := .F.
               MsgInfo(STR0016 + AllTrim(Wk_NfRem->EYY_RE) + STR0017, STR0001) //O R.E. ####  não pertence a nenhum item do Embarque. / Atenção
               Break
            EndIf
         //WFS 22/01/2010
         //Verifica se a linha foi deletada
         ElseIf Wk_NfRem->DBDELETE
            If Wk_NfRem->EYY_RECNO <> 0 .And. AScan(aNfRemDeletados, Wk_NfRem->EYY_RECNO) == 0
               AAdd(aNfRemDeletados, Wk_NfRem->EYY_RECNO)
            EndIf
            lRet:= .T.
            Wk_NfRem->(DbSkip())
            Loop
         //DFS - 25/09/12 - Retirado tratamento impeditivo no preenchimento do RE
         /*Else
            lRet := .F.
             MsgInfo(STR0018, STR0001) //Informações de R.E. incompletas. / Atenção
            Break */
         EndIf

         //////////////////////////////////////////////////////////////////////////////
         //Verifica se a Nota Fiscal de Saída está digitada em algum Item do Embarque//
         //////////////////////////////////////////////////////////////////////////////
         If !Empty(Wk_NfRem->EYY_NFSAI) .and. !Wk_NfRem->DBDELETE
            nPos := aScan(aNfItem,{|e| e[1] == Wk_NfRem->EYY_NFSAI})

            If nPos == 0
               lRet := .F.
               MsgInfo(STR0019 + Alltrim(Wk_NfRem->EYY_NFSAI) + STR0017, STR0001) //A Nota Fiscal #### não pertence a nenhum item do Embarque / Atenção
               Break
            EndIf

         Else
            lRet := .F.
            MsgInfo(STR0015, STR0001) //Informações de N.F. de Saída incompletas / Atenção
            Break
         EndIf

         //Verifica se o pedido informado está digitado em algum item do embarque e se
         //corresponde ao item digitado
         If !Empty(Wk_NfRem->EYY_PEDIDO) .And. !Wk_NfRem->DBDELETE
            nPos:= aScan(aNfItem, {|x| x[4] + x[5] == Wk_NfRem->EYY_SEQUEN + Wk_NfRem->EYY_PEDIDO}) //VERIFICAR

            If nPos == 0
               MsgInfo(STR0011, STR0001) //O pedido/ sequência digitado não pertence ao embarque - Atenção
               lRet:= .F.
               Break
            EndIf
         ElseIf !Wk_NfRem->DBDELETE
            MsgInfo(STR0012, STR0001) //Informações do pedido incompletas. / Atenção
            lRet:= .F.
            Break
         EndIf


      EndIf

      If !Empty(Wk_NFRem->EYY_NFENT)

         ////////////////////////////////////////////////////////
         //Verifica se o Fornecedor foi preenchido corretamente//
         ////////////////////////////////////////////////////////
         If Empty(Wk_NFRem->EYY_FORN)
            lRet := .F.
            MsgInfo(STR0020, STR0001) //Informações de Fornecedor incompletas / Atenção
            Break
         EndIf

         //////////////////////////////////////////////////////////////////////
         //Verifica se a Nota de Entrada está cadastrada no módulo de Compras//
         //////////////////////////////////////////////////////////////////////
         If !AvFlags("EEC_LOGIX") //NCF - 23/11/2017
            SF1->(DbSetOrder(1))
            If !SF1->(DbSeek(xFilial("SF1")+AvKey(Wk_NFRem->EYY_NFENT,"F1_DOC")+AvKey(Wk_NFRem->EYY_SERENT,"F1_SERIE")+AvKey(Wk_NFRem->EYY_FORN,"F1_FORNECE")+AvKey(Wk_NFRem->EYY_FOLOJA,"F1_LOJA")))

               If SF1->(DbSeek(xFilial("SF1")+AvKey(Wk_NFRem->EYY_NFENT,"F1_DOC")+AvKey(Wk_NFRem->EYY_SERENT,"F1_SERIE")))
                  lRet := .F.
                  MsgInfo(STR0021 + AllTrim(Wk_NFRem->EYY_NFENT) + STR0022, STR0001) //A Nota de Entrada #### não foi gerada para o Fornededor informado. / Atenção
                  Break
               Else
                  lRet := .F.
                  MsgInfo(STR0021 + AllTrim(Wk_NFRem->EYY_NFENT) + STR0023, STR0001) //A Nota de Entrada #### não foi gerada. / Atenção
                  Break
               EndIf

            EndIf

         EndIf

         //RMD - 22/11/12 - Valida se a nota foi informada duas vezes para o mesmo item
         If !NFRemNewStruct()
            If aScan(aItemNfEnt, {|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]+x[7]+x[8] == Wk_NFRem->(EYY_PEDIDO+EYY_SEQUEN+EYY_NFENT+EYY_SERENT+EYY_FORN+EYY_FOLOJA+EYY_NFSAI+EYY_SERSAI) }) == 0
               aAdd(aItemNfEnt, {Wk_NfRem->EYY_PEDIDO, Wk_NFRem->EYY_SEQUEN, Wk_NFRem->EYY_NFENT, Wk_NFRem->EYY_SERENT, Wk_NFRem->EYY_FORN, Wk_NFRem->EYY_FOLOJA,Wk_NFRem->EYY_NFSAI, Wk_NFRem->EYY_SERSAI}) //AAF 23/10/2014 - Adicionado pedido na chave. //adicionada a nota fiscal de saída na chave
            Else
               MsgInfo("A nota fiscal de entrada Nr.: " + Wk_NFRem->(AllTrim(EYY_NFENT)+"-"+AllTrim(EYY_SERENT)) + " Forn.: " + Wk_NFRem->(EYY_FORN+"/"+EYY_FOLOJA) + " foi informada duas vezes para o item '" + AllTrim(WK_NfRem->EYY_SEQUEN) + "' do pedido '"+AllTrim(Wk_NfRem->EYY_PEDIDO)+"'." + ENTER + "Não será possível continuar.", "Aviso") //AAF 23/10/2014 - Adicionado pedido na chave.
               lRet := .F.
               Break
            EndIf
         Else
            //NCF - 22/02/2018 -
            If aScan(aItemNfEnt, {|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]+x[7]+x[8]+x[9] == Wk_NFRem->(EYY_PEDIDO+EYY_SEQUEN+EYY_NFENT+EYY_SERENT+EYY_FORN+EYY_FOLOJA+EYY_D1ITEM+EYY_NFSAI+EYY_SERSAI) }) == 0
               aAdd(aItemNfEnt, {Wk_NfRem->EYY_PEDIDO, Wk_NFRem->EYY_SEQUEN, Wk_NFRem->EYY_NFENT, Wk_NFRem->EYY_SERENT, Wk_NFRem->EYY_FORN, Wk_NFRem->EYY_FOLOJA, Wk_NFRem->EYY_D1ITEM,Wk_NFRem->EYY_NFSAI, Wk_NFRem->EYY_SERSAI}) //AAF 23/10/2014 - Adicionado pedido na chave. //adicionada a nota fiscal de saída na chave
            Else
               MsgStop("A nota fiscal de entrada número: " + Wk_NFRem->(AllTrim(EYY_NFENT) + If(!Empty(EYY_SERENT), "/" + AllTrim(EYY_SERENT), "")) + " do fornecedor: " + Wk_NFRem->(AllTrim(EYY_FORN)+"/ " + AllTrim(EYY_FOLOJA)) + " Item NFe: "+ Wk_NFRem->EYY_D1ITEM + " foi informada mais de uma vez para a sequência '" + AllTrim(WK_NfRem->EYY_SEQEMB) + "' do embarque." + ENTER + "Corrija a vinculação do documento de entrada para prosseguir.", "Aviso")
               lRet := .F.
               Break
            EndIf
         EndIf

         /* Verifica se a quantidade associada ao item excede a quantidade total usada em outros processos,
            referente a este produto/ nota/ fornecedor. */
         If cOcorre == OC_EM .And. !NFRemNewStruct() //Fase de embarque
            AE110ValNfRem("EYY_QUANT")
         EndIf

      EndIf

      Wk_NfRem->(DbSkip())
   EndDo

   If !Empty(cVldQtd)
      cVldQtd:= STR0180 + ENTER + ENTER + cVldQtd //"Verifique as quantidades informadas para os itens: "
      EECView(cVldQtd, STR0148,,,, .T.)
      lRet:= .F.
      Break
   EndIf
End Sequence

RestArea(aArea)
RestOrd(aOrd)

Return lRet

/*
Função     : AvRetNfEnt()
Parâmetros : cFilNf    = Filial
             cEmbarque = Cód. do Embarque
             cRE       = Num. do R.E.
             cNFSai    = Num. da N.F. de Saída.
             cSerSai   = Série da N.F. de Saída.
Retorno    : aRet = Array com todas as N.Fs. de Entrada Relacionadas.
Objetivos  : Retornar as Notas Fiscais de Entrada relacionadas as
             Notas de Saída.
Autor      : Eduardo C. Romanini
Data/Hora  : 18/11/2008 às 10:30
*/
*------------------------------------------------------*
Function AvRetNfEnt(cFilNf,cEmbarque,cRE,cNFSai,cSerSai)
*------------------------------------------------------*
Local aRet := {}
Local aOrd := {}

Begin Sequence

   ////////////////////////////////////////////////////////
   //Verifica se a tabela EYY está cadastrada no ambiente//
   ////////////////////////////////////////////////////////
   ChkFile("EYY")
   If Select("EYY") == 0
      Break
   Else
      aOrd := SaveOrd({"EYY"})
   EndIf

   /////////////////////////////////////////////////////////
   //Verifica se os parâmetros foram passados corretamente//
   /////////////////////////////////////////////////////////
   If Empty(cEmbarque) .or. Empty(cRE) .or. Empty(cNfSai)
      Break
   EndIf

   ///////////////////////////////////////////////////////////////////
   //Executa o Seek na tabela EYY, para retornar as Notas de Entrada//
   ///////////////////////////////////////////////////////////////////
   EYY->(DbSetOrder(1))
   If EYY->(DbSeek(AvKey(cFilNf,"EYY_FILIAL")+AvKey(cEmbarque,"EYY_PREEMB")))
      While EYY->(!EOF()) .and. EYY->(EYY_FILIAL + EYY_PREEMB) == AvKey(cFilNf,"EYY_FILIAL")+AvKey(cEmbarque,"EYY_PREEMB")

         ///////////////////////////////////////////////////////////
         //Adiciona as Notas de Entrada relacionadas ao array aRet//
         ///////////////////////////////////////////////////////////
         If !Empty(EYY->EYY_NFENT) // AST - 16/01/09
            If EYY->EYY_RE == cRE .and. EYY->EYY_NFSAI == cNfSai .and. EYY->EYY_SERSAI == cSerSai
               aAdd(aRet,{EYY->EYY_NFENT,EYY->EYY_SERENT,EYY->EYY_FORN,EYY->EYY_FOLOJA})
            EndIf
         EndIf
         EYY->(DbSkip())
      EndDo
   EndIf

End Sequence

RestOrd(aOrd)

Return aRet

/*
Função     : Ae110HistProc()
Parâmetros :
Retorno    :
Objetivos  : Apresentação de alterações do processo.
Autor      : Jean Victor Rocha
Data/Hora  : 19/08/2009
*/
*----------------------*
Function Ae110HistProc()
*----------------------*
Local cTitle      := STR0149     //STR0149	"Relação de alterações"
Local cTitDetalhe := STR0150   //STR0150	"Detalhe das alterações"
Local cProcesso := EEC->EEC_PREEMB, cFase := OC_EM
Local aButtons  := {}
Local cAlias := "EW3", cWork := "WKEW3"
Local nOpc := VISUALIZAR
Local lRet := .T.
Local oDlg
Private cMarca := GetMark()
Private lInverte := .F.
Private aCampos := Array(EW3->(FCount()))

   Begin Sequence

      //Definição da Work.
      cArqWork:=E_CriaTrab(cAlias,,cWork)
      IndRegua(cWork,cARQWORK+TEOrdBagExt(),"EW3_CHAVE")

      //Carrega Work com os itens do processo.
      EW3->(DbSetOrder(1))
      If EW3->(DbSeek(xFilial() + cFase + cProcesso ))
         While EW3->(!EOF()) .And.  EW3->EW3_FASE == cFase .and.  EW3->EW3_PROC == cProcesso
            WKEW3->(DBAPPEND())
            AvReplace(cAlias, cWork)
            EW3->(DbSkip())
         EndDo
      EndIf

      (cWork)->(DbGoTop())

      //Verificação de historico do processo.
      If (cWork)->(Eof())
         MsgInfo(STR0024, STR0001) //Processo sem informações de histórico registradas. / Atenção
         Break
      EndIf

      //Tela para apresentação dos itens alterados.
      DEFINE MSDIALOG oDlg TITLE cTitle FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM, DLG_COL_FIM OF oMainWnd PIXEL

         oMsSelect := MsSelect():New(cWork, , ,ArrayBrowse(cAlias, cWork),@lInverte,@cMarca,PosDLG(oDlg))
         oMsSelect:bAval := {|| EECView(MSMM((cWork)->EW3_DESC,AVSX3("EW3_VM_DES",AV_TAMANHO),,,LERMEMO), cTitDetalhe ) }

         bOk     := {|| oDlg:End() }
      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bOk, {|| oDlg:End() }, , aButtons) CENTERED

   End Sequence

   (cWork)->(DbCloseArea())
   E_EraseArq(cArqWork)

Return lRet

/*
Função     : Ae110CadHistProc()
Parâmetros : cFase     = Fase do processo
             cProcesso = Numero do Processo
             cResumo   = Resumo da Alteração
             cTexto    = Texto da Alteração (composto por detalhes das modificações;
                         - Criado nas funções Ae110MonHistProc() e Ae110CadHistProc())
Retorno    :
Objetivos  : Cadastra as alterações do processo.
Autor      : Jean Victor Rocha
Data/Hora  : 19/08/2009
*/
*----------------------------------------------------------*
Function Ae110CadHistProc(cFase, CProcesso, cResumo, cTexto)
*----------------------------------------------------------*
Local lRet := .T.
Local cChave := DToS(dDatabase)+ StrTran(Time(), ":", "")//Chave composta por AAAAMMDDHHMMSS
Local cAlias := "EW3"

   //Definição do Resumo que sera apresentado caso não tenha sido passado no parametro.
   If cResumo == ""
      cResumo := STR0151 //STR0151	"Alteração de conteúdo de campos."
   EndIf
   //Verificação de registro ja existente na Base. Caso tenha cria um novo.
   (cAlias)->(DbSetOrder(1))
   While ((cAlias)->(DbSeek(xFilial() + cFase + cProcesso + cChave)))
      cChave := DToS(dDatabase)+ StrTran(Time(), ":", "")
   EndDo

   //Cria um novo registro de alteração.
   (cAlias)->(RecLock(cAlias, .T.)) //(DbAppend())
   (cAlias)->EW3_FILIAL:= xFilial("EW3")  //Filial
   (cAlias)->EW3_DATA  := dDataBase  //Data atual
   (cAlias)->EW3_HORA  := Time()     //Hora atual
   (cAlias)->EW3_PROC  := cProcesso  //Processo corrente
   (cAlias)->EW3_FASE  := cFase      //Fase do Processo
   (cAlias)->EW3_USER  := cUserName  //Usuario corrente
   (cAlias)->EW3_CHAVE := cChave     //Chave
   (cAlias)->EW3_RESUMO:= cResumo    //Resumo da alteração
   (cAlias)->(MsUnlock())

   //Definição do conteudo do campo Memo.
   cTexto := STR0152        + ENTER +;//STR0152 "Detalhes da Alteração:            "
             "----------------------------------"        + ENTER +;
             STR0153        + cProcesso      + ENTER +;//STR0153	"Processo Nº:"
             STR0154        + DToS(dDataBase)+ ENTER +;//STR0154	"Data:  "
             STR0155        + Time()         + ENTER +;//STR0155	"Hora:  "
             STR0156        + cUserName       + ENTER +;//STR0156	"Usuário: "
             STR0157        + cResumo        + ENTER +;//STR0157	"Resumo: "
             ENTER +;
             STR0158        + ENTER +;//STR0158	"Relação de Alterações: "
             cTexto

   MSMM(,AVSX3("EW3_VM_DES",AV_TAMANHO),,cTexto,INCMEMO,,,cAlias,"EW3_DESC")

Return lRet

/*
Função     : Ae110MonHistProc()
Parâmetros : cAlias
             cAliasOri
             cAliasDest
Retorno    : cTexto
Objetivos  : Monitoramento de alterações.
Autor      : Jean Victor Rocha
Data/Hora  : 19/08/2009
*/
*------------------------------------------------------*
Function Ae110MonHistProc(cAlias, cAliasOri, cAliasDest)
*------------------------------------------------------*
Local i
Local cTexto := ""
Local lLog := .T.
Local aCposMon := RetCposMon(cAlias)

   SX2->(DbSetOrder(1))
   SX2->(DbSeek(cAlias))
   //Verifica campos monitorados
   For i := 1 to Len(aCposMon)
      //Verificação de alterações.
      If &(cAliasOri + "->" + aCposMon[i]) <> &(cAliasDest + "->" + aCposMon[i])
         If AvSx3(aCposMon[i],AV_TIPO) == "C"
            If AllTrim(&(cAliasOri + "->" + aCposMon[i])) == AllTrim(&(cAliasDest + "->" + aCposMon[i]))
               Loop
            EndIf
         EndIf

         //Definição do titulo da descrição(apena uma vez).
         If lLog
            cTexto += STR0159 + AllTrim(FWX2Nome(cAlias)) + "'." + ENTER /*cAlias*///STR0159	"Log de alterações da tabela '"
            lLog := .F.
         EndIf
         cTexto += STR0160 + AllTrim(AVSX3(aCposMon[i],AV_TITULO)) + "'" + ENTER //STR0160	"Alteração no campo: '"

         //Verificação de Tipo de conteudo do campo caso seja diferente de Caracter.
         If AvSx3(aCposMon[i],AV_TIPO) == "N"//Tipo Numerico
            cTexto += STR0161   + AllTrim(Str( &(cAliasOri + "->" + aCposMon[i]) )) + ENTER +; //STR0161	"De: "
                      STR0162 + AllTrim(Str( &(cAliasDest + "->" + aCposMon[i]) )) //STR0162	"Para: "
         ElseIf AvSx3(aCposMon[i],AV_TIPO) == "D"//Tipo Data
            cTexto += STR0161   + DToC(&(cAliasOri + "->" + aCposMon[i])) + ENTER +;//STR0161	"De: "
                      STR0162 + DToC(&(cAliasDest + "->" + aCposMon[i]))//STR0162	"Para: "
         ElseIf AvSx3(aCposMon[i],AV_TIPO) == "C"//Tipo Caracter
            cTexto += STR0161   + &(cAliasOri + "->" + aCposMon[i]) + ENTER +;//STR0161	"De: "
                      STR0162 + &(cAliasDest + "->" + aCposMon[i])//STR0162	"Para: "
         EndIf
         cTexto += ENTER
      EndIf
   Next i
   //***

Return cTexto

/*
Função     : RetCposMon()
Parâmetros : cAlias = Alias a ser monitorado
Retorno    : aCpos  = Campos que vão ser monitorados.
Objetivos  : Definição dos campos a ser monitorados
Autor      : Jean Victor Rocha
Data/Hora  : 19/08/2009
*/
*--------------------------------*
Static Function RetCposMon(cAlias)
*--------------------------------*
Local aCposMon := {}
Local nInc, aCamposTela

Do Case
   Case cAlias == "EEC"
       //Definição dos campos que vão ser monitorados
       /*
       aCposMon := {"EEC_VIAGEM" ,"EEC_ETA", "EEC_ETD", "EEC_PREEMB", "EEC_VIA", "EEC_ORIGEM",;
                    "EEC_DEST", "EEC_EMBARC", "EEC_VIAGEM", "EEC_DTEMBA"}
       */
       aCamposTela := aHDEnchoice

   Case cAlias == "EXL"
      /*
      aCposMon := {"EXL_BOOK", "EXL_BKRFIN", "EXL_QTDCON", "EXL_TIPCON", "EXL_LOCFRE", "EXL_TPSERV", "EXL_TIPMOV",;
                   "EXL_LOCREC", "EXL_LOCENT", "EXL_ETDORI", "EXL_DTRETI", "EXL_HRRETI", "EXL_IMPFRE",;
                   "EXL_ENVVAL"}
      */

      if IsMemVar("aCamposEXL")
         aCamposTela := aCamposEXL
      Else
         aCamposTela :=  {}
      Endif

EndCase

   For nInc := 1 To (cAlias)->(FCount())
      If aScan(aCamposTela, (cAlias)->(FieldName(nInc))) > 0
         aAdd(aCposMon, (cAlias)->(FieldName(nInc)))
      EndIf
   Next

Return aCposMon

*----------------------------*
Function Ae110ChgTags(cTexto)
*----------------------------*
Local aTags := RetTags()
Local nInc

   For nInc := 1 To Len(aTags)
      cTexto := StrTran(cTexto, aTags[nInc][1], &(aTags[nInc][2]))
   Next

Return cTexto
*------------------------------*
Static Function RetTags(cAlias)
*------------------------------*
Local aTags := {}

   aAdd(aTags, {"#NR_RE#"   , "M->EE9_RE"          })
   aAdd(aTags, {"#QTD#"     , "TransForm(M->EE9_SLDINI, AvSx3('EE9_SLDINI', " + Str(AV_PICTURE) + "))"})
   aAdd(aTags, {"#PRECOUN#" , "TransForm(M->EE9_PRECO, AvSx3('EE9_PRECO', " + Str(AV_PICTURE) + "))"})
   aAdd(aTags, {"#NCM#"     , "M->EE9_POSIPI"      })
   aAdd(aTags, {"#DT_RE#"   , "DToC(M->EE9_DTRE)"  })
   aAdd(aTags, {"#NR_SD#"   , "M->EE9_NRSD"        })
   aAdd(aTags, {"#AVRB_SD#" , "DToC(M->EE9_DTAVRB)"})
   aAdd(aTags, {"#EMBARQUE#", "M->EEC_PREEMB"      })

Return aTags

/*
Função     : ReiniciarEstufagem()
Parâmetros :
Retorno    :
Objetivos  : Reiniciar o a estufagem para o processo posicionado
Autor      : Wilsimar Fabrício da Silva
Data/Hora  : 13/01/2010
*/
*-----------------------------------*
Static Function ReiniciarEstufagem()
*-----------------------------------*

Begin Sequence

   //Eliminando os dados das tabelas
   EYH->(DBSeek(xFilial() + "N" + EEC->EEC_PREEMB))
   While EYH->(!Eof()) .And.;
         EYH->EYH_FILIAL == EYH->(xFilial()) .And.;
         EYH->EYH_PREEMB == EEC->EEC_PREEMB

      EYH->(RecLock("EYH", .F.))
      EYH->(DBDelete())
      EYH->(MsUnlock())
      EYH->(DBSkip())
   End

   EYH->(DBSeek(xFilial() + "S" + EEC->EEC_PREEMB))
   While EYH->(!Eof()) .And.;
         EYH->EYH_FILIAL == EYH->(xFilial()) .And.;
         EYH->EYH_PREEMB == EEC->EEC_PREEMB

      EYH->(RecLock("EYH", .F.))
      EYH->(DBDelete())
      EYH->(MsUnlock())
      EYH->(DBSkip())
   End

   If MsgYesNo(STR0163, STR0070) //STR0070	"Aviso" //STR0163	"Deseja remover os containers do processo?"
      EX9->(DBSeek(xFilial() + EEC->EEC_PREEMB))
      While EX9->(!Eof()) .And.;
            EX9->EX9_FILIAL == EX9->(xFilial()) .And.;
            EX9->EX9_PREEMB == EEC->EEC_PREEMB

         EX9->(RecLock("EX9", .F.))
         EX9->(DBDelete())
         EX9->(MsUnlock())
         EX9->(DBSkip())
      End Do
   EndIf

End Sequence
Return

*--------------------------------------*
Static Function GetEmbSup(cWork,cIdSup)
*--------------------------------------*
Local aOrd := (cWork)->({IndexOrd(),RecNo()})
Local cRet

(cWork)->(dbSetOrder(1))
(cWork)->(dbSeek(cIdSup))

cRet := (cWork)->EYH_CODEMB

(cWork)->(dbSetOrder(aOrd[1]),dbGoTo(aOrd[2]))

Return cRet

*---------------------------------------------*
Static Function DuplClick(oTreeOri, oTreeDest)
*---------------------------------------------*
Local bOldOri  := oTreeOri:blDblClick
Local bOldDest := oTreeDest:blDblClick

//Não deixar executar outro enquanto não terminar este
oTreeOri:blDblClick := {|| .T.}
oTreeDest:blDblClick := {|| .T.}

if lDoubleClick
   oTreeOri:SetFocus()
   Eval(oTreeOri:bGotFocus)

   Ae110MovDe()

   if !Empty(aMovDe)
      oTreeDest:SetFocus()
      Eval(oTreeDest:bGotFocus)
      Ae110MovPara(,,,,,.T.)
   EndIf
EndIf

oTreeOri:blDblClick  := bOldOri
oTreeDest:blDblClick := bOldDest

Return .T.
*------------------------------*
Static Function Ae110MovTodos()
*------------------------------*
Local nRecAtu

If MsgYesNo("Deseja mover todas as mercadorias não estufadas para o container/embalagem selecionado?",STR0001)

Begin Sequence

   WK_NE->(dbGoTop())
   Do While WK_NE->(!EoF())

      nRecAtu:= WK_NE->(RecNo())
      If Empty(WK_NE->EYH_COD_I)

         oTreeNE:TreeSeek(Ae110Info("WORK_CARGO", "WK_NE"))
         Eval(oTreeNE:bChange)

         oTreeNE:SetFocus()
         Eval(oTreeNE:bGotFocus)

         Ae110MovDe()

         If !Empty(aMovDe)
            oTreeES:SetFocus()
            Eval(oTreeES:bGotFocus)
            Ae110MovPara(,,,,,.T.)
         EndIf

      EndIf
      If nRecAtu == WK_NE->(RecNo())
         WK_NE->(dbSkip())
         If nRecAtu == WK_NE->(RecNo())
            Break
         EndIf
      EndIf
   EndDo

End Sequence

EndIf

Return .T.

*------------------------------*
Static Function Ae110QbrEstru()
*------------------------------*
Local cWork  := Ae110Info("TREE_WORK")
Local nRecAtu:= (cWork)->(RecNo())
Local lOk    := .T.
Local aOrd   := SaveOrd({"SG1"})
Local cLog         := ""
Local cDescItExp, cIdEmbSupA, cCdEmbSupA, nRlEmbSupA, cNewCargo, cImg, cNewDesc, cIdVinc, nRecnoPos
Local cCodMemEmb:= cDesEmb:=  cCodMemIte:= cDesIte := ''
Static aItensExpl   := {}

Begin Sequence

   If cWork <> cWorkNE
      MsgInfo("Somente itens não estufados podem ter quebra por estrutura", "AVISO")
      lOk := .F.
      Break
   EndIf

   If Empty((cWork)->EYH_COD_I)
      MsgInfo("Somente itens podem ter quebra por estrutura", "AVISO")
      lOk := .F.
      Break
   EndIf

   SG1->(DbSetOrder(1))
   SB1->(DbSetOrder(1))
   EE2->(DbSetOrder(1))
   If !SG1->(DbSeek(  xFilial("SG1")+Avkey((cWork)->EYH_COD_I,"G1_COD") ))
      MsgInfo("Este item não possui estrutura cadastrada para quebra", "AVISO")
      lOk := .F.
      Break
   EndIf

   Do While SG1->(!Eof()) .And. SG1->G1_FILIAL == SG1->(xFilial("SG1")) ;
                          .And. SG1->G1_COD == Avkey((cWork)->EYH_COD_I,"G1_COD")           //Loop nos itens da Estrutura
         SB1->(DbSeek(xFilial("SB1")+SG1->G1_COMP))                                            //Posicionar no cadastro do produto componente
         lLogEmb := .F.
         If Empty(SB1->B1_CODEMB)
            cLog += '[PRODUTO COMPONENTE: '+Alltrim(SB1->B1_DESC)+']-[CODIGO: '+SG1->G1_COMP+'] - Não possui embalagem informada.'
            llogEmb := .T.
         EndIf
         If SB1->B1_QE == 0
            If lLogEmb
               cLog += 'e não possui informada a quantidade do item comportada nesta embalagem.'+CHR(13)+CHR(10)
            Else
               cLog += ''+CHR(13)+CHR(10)+'[PRODUTO COMPONENTE: '+Alltrim(SB1->B1_DESC)+']-[CODIGO: '+SG1->G1_COMP+'] - não possui informada a quantidade do item comportada em sua embalagem.'+CHR(13)+CHR(10)
            EndIf
         EndIf
         SG1->(DbSkip())
   EndDo

   If !Empty(cLog)

         cLog += CHR(13)+CHR(10)
         cLog += 'Campo "Embalagem"(B1_CODEMB) localiza-se no cadastro de produtos na aba "Outros."'+CHR(13)+CHR(10)
         cLog += 'Campo "Qtd.Embalag."(B1_QE) localiza-se no cadastro de produtos na aba "Mrp/Suprimentos".'+CHR(13)+CHR(10)
         cLog := 'EXISTEM PROBLEMAS COM O CADASTRO DE PRODUTO DOS ITENS QUE COMPÕEM A ESTRUTURA DO ITEM QUEBRADO:'+CHR(13)+CHR(10)+cLog
         cTit := 'PROBLEMAS NOS ITENS DA ESTRUTURA'
         AVGetSvLog(cTit,cLog)
         Break
   EndIf

   If MsgYesNo("Deseja mesmo quebrar este item pela sua estrutura?"+CHR(13)+CHR(10)+;
               "Esta operação é reversível apenas pela opção de"+CHR(13)+CHR(10)+;
               "reinicialização da Estufagem.","AVISO IMPORTANTE!")

      SB1->(DbSeek(xFilial("SB1")+AvKey((cWork)->EYH_COD_I,"B1_COD")))
      cCodMemIte := Posicione("EE2",1,xFilial("EE2")+AvKey("3","EE2_CODCAD")+AvKey("*","EE2_TIPMEN")+AvKey(EEC->EEC_IDIOMA,"EE2_IDIOMA")+AvKey(SB1->B1_COD,"EE2_COD"),"EE2_TEXTO")
      If !Empty(cCodMemIte)
         cDescItExp := MSMM(cCodMemIte,AVSX3("EE2_VM_TEX",3),,,LERMEMO)
      Else
         cDescItExp := SB1->B1_DESC
      EndIf

     aAdd(aItensExpl ,  {(cWork)->EYH_PREEMB,;
                         (cWork)->EYH_ID,;
                         (cWork)->EYH_IDVINC,;
                         (cWork)->EYH_CODEMB,;
                         (cWork)->EYH_COD_I,;
                         (cWork)->EYH_DESEMB,;
                         (cWork)->EYH_EMBSUP,;
                         (cWork)->EYH_RELSUP,;
                         (cWork)->EYH_ESTUF,;
                         (cWork)->EYH_QTDEMB,;
                         (cWork)->EYH_PSLQUN,;
                         (cWork)->EYH_IDPROR})
     //EndIf
     (cWork)->(DbSeek(aItensExpl[Len(aItensExpl)][3]))                                                          //Posiciona no ID da embalagem superior do item atual

     cIdEmbSupA := (cWork)->EYH_IDVINC                                                                          //Obtem o ID da embalagem superior a embalagem atual
     cCdEmbSupA := GetEmbSup(cWork,cIdEmbSupA)                                                                  //Obtem o código da embalagem superior a embalagem atual
     nRlEmbSupA := (cWork)->EYH_RELSUP                                                                          //Obtem a qtde de embalagem atual comportada na embalagem superior
     aAdd(aItensExpl[Len(aItensExpl)],If((cWork)->EYH_IDVINC <> cZero,Ae110Info("WORK_CARGO_PAI", cWork),cZero))

     (cWork)->(DbGoto(nRecAtu))                                                                                 //Retorna ao item a ser explodido
     SG1->(DbSeek(  xFilial("SG1")+Avkey((cWork)->EYH_COD_I,"G1_COD") ))
     Do While SG1->(!Eof()) .And. SG1->G1_FILIAL == SG1->(xFilial("SG1")) ;
                            .And. SG1->G1_COD == Avkey(aItensExpl[Len(aItensExpl)][5],"G1_COD")                 //Loop nos itens da Estrutura do item a ser explodido

        SB1->(DbSeek(xFilial("SB1")+SG1->G1_COMP))                                                              //Posicionar no cadastro do produto componente

        //Inclui embalagem do item componente
        (cWork)->(DbAppend())
        cNewIdEmb := Ae110NewId(.T.,EEC->EEC_PREEMB)
        (cWork)->EYH_PREEMB := EEC->EEC_PREEMB
        (cWork)->EYH_ID     := cNewIDEmb
        (cWork)->EYH_IDVINC := cIdEmbSupA
        (cWork)->EYH_IDPROR := aItensExpl[Len(aItensExpl)][2]
        (cWork)->EYH_CODEMB := SB1->B1_CODEMB

        cCodMemEmb := Posicione("EE2",1,xFilial("EE2")+AvKey("6","EE2_CODCAD")+AvKey("*","EE2_TIPMEN")+AvKey(EEC->EEC_IDIOMA,"EE2_IDIOMA")+AvKey(SB1->B1_CODEMB,"EE2_COD"),"EE2_TEXTO")
        If !Empty(cCodMemEmb)
           cDesEmb := MSMM(cCodMemEmb,AVSX3("EE2_VM_TEX",3),,,LERMEMO)
        EndIf

        (cWork)->EYH_DESEMB := If(!Empty(cDesEmb),cDesEmb,Posicione("EE5", 1, xFilial("EE5")+Avkey(SB1->B1_CODEMB,"EE5_CODEMB"), "EE5_DESC"))
        (cWork)->EYH_EMBSUP := cCdEmbSupA
        (cWork)->EYH_RELSUP := nRlEmbSupA
        (cWork)->EYH_ESTUF  := "N"
        (cWork)->EYH_QTDEMB := INT((SG1->G1_QUANT * aItensExpl[Len(aItensExpl)][10]) / SB1->B1_QE )
        (cWork)->EYH_PSLQUN := BuscaPesEmb((cWork)->EYH_CODEMB)

        If lMarcacao .And. (cWork)->(FieldPos("EYH_MARCAC")) > 0
           (cWork)->EYH_MARCAC := MSMM(EEC->EEC_CODMAR, AVSX3("EEC_MARCAC",AV_TAMANHO),,,LERMEMO)
        EndIf

        //Gravação da embalagem no Tree
        cNewCargo := cWork + StrZero((cWork)->(Recno()), 10)
        cImg      := GetImgTree(cWork)
        cNewDesc  := "Emb: " + (cWork)->EYH_DESEMB + " " + "Qtd: " + AllTrim(Str( (cWork)->EYH_QTDEMB ))
        oTreeNE:TreeSeek(aItensExpl[Len(aItensExpl)][13])
        oTreeNE:AddItem(cNewDesc, cNewCargo, cImg, cImg,,, 2)

        oTreeNE:TreeSeek(cNewCargo)
        oTreeNE:Refresh()
        oTreeNE:SetFocus()

        //Cálculo dos Pesos
        Ae110AtuPeso(cWork,,(cWork)->EYH_IDVINC)

        //Inclui o próprio item componente
        (cWork)->(DbAppend())
        (cWork)->EYH_PREEMB := EEC->EEC_PREEMB
        (cWork)->EYH_ID     := Ae110NewId(.T., EEC->EEC_PREEMB)
        (cWork)->EYH_IDVINC := cNewIDEmb
        (cWork)->EYH_IDPROR := aItensExpl[Len(aItensExpl)][2]
        (cWork)->EYH_CODEMB := SB1->B1_COD

        cCodMemIte := Posicione("EE2",1,xFilial("EE2")+AvKey("3","EE2_CODCAD")+AvKey("*","EE2_TIPMEN")+AvKey(EEC->EEC_IDIOMA,"EE2_IDIOMA")+AvKey(SB1->B1_COD,"EE2_COD"),"EE2_TEXTO")
        If !Empty(cCodMemIte)
           cDesIte := MSMM(cCodMemIte,AVSX3("EE2_VM_TEX",3),,,LERMEMO)
        EndIf

        (cWork)->EYH_DESEMB := If(!Empty(cDesIte),cDesIte,SB1->B1_DESC)//MSMM(EE9->EE9_DESC, 60,,,LERMEMO)
        (cWork)->EYH_COD_I  := SB1->B1_COD
        //(cWork)->EYH_SEQEMB := EE9->EE9_SEQEMB
        (cWork)->EYH_EMBSUP := SB1->B1_CODEMB
        (cWork)->EYH_RELSUP := SB1->B1_QE
        (cWork)->EYH_ESTUF  := "N"
        (cWork)->EYH_QTDEMB := SG1->G1_QUANT * aItensExpl[Len(aItensExpl)][10] //Quantidade do componente múltipla da quantidade do produto
        (cWork)->EYH_PSLQUN := SB1->B1_PESO

        If lMarcacao .And. (cWork)->(FieldPos("EYH_MARCAC")) > 0
           (cWork)->EYH_MARCAC := MSMM(EEC->EEC_CODMAR, AVSX3("EEC_MARCAC",AV_TAMANHO),,,LERMEMO)
        EndIf

        //Gravação do item no Tree
        cNewCargo := cWork + StrZero((cWork)->(Recno()), 10)
        cImg      := GetImgTree(cWork)
        cNewDesc  := "[Prod: " + cDescItExp +"]-Componente: "+ (cWork)->EYH_DESEMB +" "+ "Qtd: " + AllTrim(Str( (cWork)->EYH_QTDEMB ))

        oTreeNE:AddItem(cNewDesc, cNewCargo, cImg, cImg,,, 2)

        oTreeNE:TreeSeek(cNewCargo)
        oTreeNE:Refresh()
        oTreeNE:SetFocus()

        //Cálculo dos Pesos
        Ae110AtuPeso(cWork,,(cWork)->EYH_IDVINC)

        SG1->(DbSkip())
     EndDo

     (cWork)->(DbGoto(nRecAtu))
     nRecnoPos := (cWork)->(Recno())
     oTreeNE:TreeSeek(Ae110Info("WORK_CARGO", cWork))                 //Posiciona o foco do Tree no item explodido
     oTreeNE:DelItem()                                                //Deleta o item do Tree
     (cWork)->(DbGoto(nRecnoPos))                                     //Reposiciona
     cIdVinc := (cWork)->EYH_IDVINC                                   //Obtem o ID da embalagem relacionada
     (cWork)->(DbDelete())                                            //Exclui o item explodido da work

     If cIdVinc <> cZero                                              //Se for a raiz não poderá deletar
        (cWork)->(DbSeek(cIdVinc))                                    //Posiciona na Embalagem Superior
        nRecnoPos := (cWork)->(Recno())
        oTreeNE:TreeSeek(Ae110Info("WORK_CARGO", cWork))              //Posiciona o foco do Tree na embalagem do item explodido
        oTreeNE:DelItem()                                             //Deleta a embalagem deste item do Tree
        (cWork)->(DbGoto(nRecnoPos))
        (cWork)->(DbDelete())                                         //Exclui a embalagem imediatamente superior ao item explodido da work
     EndIf

     oTreeNE:TreeSeek(cZero)                                          //Posiciona o Tree na raiz

     cDescItExp:= cIdEmbSupA:= cCdEmbSupA:= cNewCargo:= cImg:= cNewDesc:= cIdVinc:= ''
     nRlEmbSupA := 0

     Ae110AtuPeso(cWorkNE,,cZero)
   Else
     Break
   EndIf
End Sequence

RestOrd(aOrd,.T.)

Return lOk
/*
	RMD - 17/10/14 - Busca por container.
*/
Function AE110BuscaCont()

Local aOrd := SaveOrd({"EX9", "EEC"})
Local cCont := Space(AVSX3("EX9_CONTNR",AV_TAMANHO))
Local lOk := .F.
Local bOk      := {|| If(Eval(bValid),(lOk := .T., oDlg:End()),)}
Local bCancel  := {|| oDlg:End()}
Local bValid   := {|| .T. }
Local oDlg
Local i
Local aEmb := {}
Local oPanel
Begin Sequence

    DEFINE MSDIALOG oDlg TITLE STR0166 FROM 1,1 To 150,389 OF oMainWnd Pixel //"Busca Container"

    oPanel:= TPanel():New(0, 0, "",oDlg,, .F., .F.,,, 40.5, 7.5)

    @ 18,25  Say STR0167 Pixel Of oPanel //"Container:"
    @ 17,75 MsGet cCont Size 70,07 Picture ("@!") Of oPanel Pixel

    oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

    Activate MsDialog oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) Centered

   If !lOk
      Break
   EndIf

   cCont := AllTrim(cCont)

   BeginSQL Alias "CONT"
	    Select
	    	EX9_PREEMB
		From
			%table:EX9% EX9
		Where
			EX9_FILIAL = %XFilial:EX9%
			And EX9_CONTNR = %exp:cCont%
			AND %NotDel%
   EndSql

   While CONT->(!Eof())
      If aScan(aEmb, CONT->EX9_PREEMB) == 0
         aAdd(aEmb, CONT->EX9_PREEMB)
      EndIf
      CONT->(DbSkip())
   EndDo
   CONT->(DbCloseArea())

   If Len(aEmb) == 0
      MsgInfo(STR0168, STR0169) // "Container não encontrado." ### "Aviso"
   Else
      For i := 1 To Len(aEmb)
         EEC->(DbSetOrder(1))
         If EEC->(DbSeek(xFilial()+aEmb[i]))
         	If Len(aEmb) > i
	           If !MsgYesNo(StrTran(StrTran(STR0170, "XXX", AllTrim(aEmb[i])), "ZZZ", AllTrim(Str(Len(aEmb) - i))), STR0169) //"O container foi localizado no embarque 'XXX' e em mais ZZZ embarque(s). Deseja continuar a pesquisa?" ### "Aviso"
	              Exit
	           EndIf
	        EndIf
         EndIf
      Next
   EndIf

End Sequence

RestOrd(aOrd, .F.)

Return Nil

/*
Função     : RetQtdUsada()
Objetivo   : Retonar a quantidade do item/ nota usada em outros processos
Parâmetros :
Retorno    : nQtd - quantidade do item usada
Autor      : WFS
Data       : 04/03/16
Revisão    :
*/
Static Function RetQtdUsada()
Local cQuery:= "", cJoin:= "", cWhere:= "", cDelete:= ""
Local nQtdUsada:= 0

Begin Sequence


   If TcSrvType() <> "AS/400"
      cDelete := " And EYY.D_E_L_E_T_ <> '*' And EE9.D_E_L_E_T_ <> '*'"
   EndIf

   cQuery:= "Select Sum(EYY_QUANT) as SALDO From " + RetSqlName("EYY") + " EYY"

   cJoin:= " Inner Join " +  RetSqlName("EE9") + " EE9" +;
           " On EE9.EE9_FILIAL = EYY.EYY_FILIAL And" +;
              " EE9.EE9_PEDIDO = EYY.EYY_PEDIDO And" +;
              " EE9.EE9_SEQUEN = EYY.EYY_SEQUEN And" +;
              " EE9.EE9_NF     = EYY.EYY_NFSAI  And" +;
              " EE9.EE9_SERIE  = EYY.EYY_SERSAI"


   /* Dados referente ao produto, nota e fornecedor corrente.*/
   cWhere:= " Where EE9.EE9_COD_I  = '" + If(NFRemNewStruct(), Wk_NfRem->EYY_COD_I, Wk_NfRem->EE9_COD_I)  + "' And" +;
                  " EYY.EYY_NFENT  = '" + Wk_NfRem->EYY_NFENT  + "' And" +;
                  " EYY.EYY_SERENT = '" + Wk_NfRem->EYY_SERENT + "' And" +;
                  " EYY.EYY_FORN   = '" + Wk_NfRem->EYY_FORN   + "' And" +;
                  " EYY.EYY_FOLOJA = '" + Wk_NfRem->EYY_FOLOJA + "' And" +;
                  " EYY.EYY_FILIAL = '" + EYY->(xFilial())     + "'"

   /* Diferente do processo em edição.*/
   cWhere += " And EYY.EYY_PREEMB <> '" + Wk_NfRem->EYY_PREEMB + "'"

   /* Montagem da Query com as quantidades usadas nos processos de exportação.*/
   cQuery += cJoin + cWhere + cDelete
   cQuery := ChangeQuery(cQuery)
   TcQuery cQuery Alias "SLDUSADO" New

   TcSetField("SLDUSADO", "SALDO", "N", TamSx3("EYY_QUANT")[1], TamSx3("EYY_QUANT")[2])

   nQtdUsada:= SLDUSADO->SALDO

   SLDUSADO->(DBCloseArea())

End Sequence

Return nQtdUsada

/*
Função     : PosWorkIP()
Objetivo   : Posicionar o item da workip
Parâmetros :
Retorno    :
Autor      : WFS
Data       : mai/2016
Revisão    :
*/
Static Function PosWorkIP()

Begin Sequence

   WorkIp->(DBSeek(Wk_NfRem->(EYY_PEDIDO+EYY_SEQUEN)))
   While WorkIP->(!Eof()) .And. WorkIp->EE9_PEDIDO == Wk_NfRem->EYY_PEDIDO .And.;
                                WorkIp->EE9_SEQUEN == Wk_NfRem->EYY_SEQUEN

      If WorkIp->EE9_NF == Wk_NfRem->EYY_NFSAI .And. WorkIp->EE9_SERIE == Wk_NfRem->EYY_SERSAI
         Exit
      EndIf
      WorkIP->(DBSkip())
   EndDo

End Sequence

Return

/*
Função     : QtdUsadaWorkIP()
Objetivo   : Calcular a quantidade do item do embarque associado à uma nota de remessa, evitando
             associação de quantidade de fim específico de exportação superior a quantidade embarcada.
Parâmetros :
Retorno    :
Autor      : WFS
Data       : mai/2016
Revisão    : jun/2016
*/
Static Function QtdUsadaWorkIP()
Local nRecNo
Local nOldOrd
Local cChave
Local nQtd

Begin Sequence

   If NFRemNewStruct()
      cChave := Wk_NfRem->(EYY_SEQEMB + EYY_NFSAI + EYY_SERSAI)
      nRecNo := Wk_NfRem->(Recno())

      Wk_NfRem->(DBSetOrder(1)) //EYY_SEQEMB + EYY_NFSAI + EYY_SERSAI
      Wk_NfRem->(DBSeek(cChave))

      nQtd:= 0
      While Wk_NfRem->(!Eof()) .And.;
            Wk_NfRem->(EYY_SEQEMB + EYY_NFSAI + EYY_SERSAI) == cChave

         /* verificar a quantidade do item da WorkIp associada à uma nota de remessa com fim específico de
             exportação, exceto do item em edição, que a quantidade estará na memória.
            Também deve ser desconsiderado o item que não etá associado à uma nota fiscal de entrada */
         If !Wk_NfRem->DBDELETE .And. Wk_NfRem->(Recno()) <> nRecNo .And. !Empty(Wk_NfRem->EYY_NFENT)
            nQtd += Wk_NfRem->EYY_QUANT
         EndIf

         Wk_NfRem->(DBSkip())
      EndDo

      Wk_NfRem->(DBGoTo(nRecNo))
   Else

      //EE9_COD_I + EYY_PEDIDO + EYY_SEQUEN + EYY_NFSAI + EYY_SERSAI","AllwayTrue()"
      cChave := Wk_NfRem->(EE9_COD_I + EYY_PEDIDO + EYY_SEQUEN + EYY_NFSAI + EYY_SERSAI)
      nRecNo := Wk_NfRem->(Recno())
      nOldOrd:= Wk_NfRem->(IndexOrd())

      Wk_NfRem->(DBSetOrder(2))
      Wk_NfRem->(DBSeek(cChave))

      nQtd:= 0

      While Wk_NfRem->(!Eof()) .And.;
            Wk_NfRem->(EE9_COD_I + EYY_PEDIDO + EYY_SEQUEN + EYY_NFSAI + EYY_SERSAI) == cChave

         /* verifica a quantidade do item associada à uma nota de remessa com fim específico de exportação,
            exceto do item em edição, que a quantidade estará na memória */
         If Wk_NfRem->(Recno()) <> nRecNo
            nQtd += Wk_NfRem->EYY_QUANT
         EndIf

         Wk_NfRem->(DBSkip())
      EndDo

      Wk_NfRem->(DBGoTo(nRecNo))
      Wk_NfRem->(DBSetOrder(nOldOrd))
   EndIf

End Sequence

Return nQtd

/*
Função     : GravaWk_NfRem(nOpc, nQuantidade)
Objetivo   : Inclusão/ atualização dos dados na work
Parâmetros : nOpc
             3 = INCLUIR
             4 = ALTERAR
             5 = EXCLUIR
             nQuantidade - saldo do item para vinculação da nota fiscal de entrada
Retorno    :
Autor      : WFS
Data       : jun/2016
Revisão    :
Observação : A WorkIp deve estar posicionada
*/
Static Function GravaWk_NfRem(nOpc, nQuantidade)
Local lFiltNcm := EasyGParam("MV_EEC0051",,.F.)
Local lFimEspecNew := AvFlags("ROTINA_VINC_FIM_ESPECIFICO_RP12.1.20")

Begin Sequence


   //fase embarque
   Do Case
      Case nOpc == INCLUIR .Or. nOpc == ALTERAR

         Wk_NfRem->(RecLock("Wk_NfRem", nOpc == INCLUIR))

         WK_NFRem->EYY_PREEMB:= WorkIp->EE9_PREEMB
         WK_NFRem->EYY_SEQEMB:= WorkIp->EE9_SEQEMB
         WK_NFRem->EYY_PEDIDO:= WorkIp->EE9_PEDIDO
         WK_NFRem->EYY_SEQUEN:= WorkIp->EE9_SEQUEN
         WK_NFRem->EYY_COD_I := WorkIp->EE9_COD_I
         WK_NFRem->EYY_VM_DES:= /*MemoLine(*/WorkIP->EE9_VM_DES/*, 60, 1)*/
         WK_NFRem->EYY_NFSAI := WorkIp->EE9_NF
         WK_NFRem->EYY_SERSAI:= WorkIp->EE9_SERIE
         WK_NFRem->EYY_RE    := WorkIp->EE9_RE
         Wk_NfRem->EYY_QUANT := nQuantidade
         If lFiltNcm
            WK_NFRem->EYY_POSIPI:= WorkIp->EE9_POSIPI
         EndIf
         If lFimEspecNew
            WK_NFRem->EYY_UNIDAD := WorkIp->EE9_UNIDAD
         EndIf
         Wk_NfRem->(MsUnlock())

      Case nOpc == EXCLUIR
         Wk_NfRem->(RecLock("Wk_NfRem", .F.))
         Wk_NfRem->(DBDelete())
         Wk_NfRem->(MsUnlock())

   End Case
End Sequence

Return

/*
Função     : AE110DelLin()
Objetivo   : Armazenar o RecNo dos registros deletados
             Validar a exclusão do item
Parâmetros :
Retorno    :
Autor      : WFS
Data       : jun/2016
Revisão    :
*/
Function AE110DelLin()
Local nPos
Local lRet:= .T.
Local aOrd:= SaveOrd({"WK_NFRem"})
Local nQtdeUMNFe := 0
Local lFimEspecNew := AvFlags("ROTINA_VINC_FIM_ESPECIFICO_RP12.1.20")
Begin Sequence

    /* Validação disponível apenas quando houver estrutura de dicionário para controle de saldos */
    If !NFRemNewStruct()
       Break
    EndIf

    /* Se o registro deletado refere-se à um registro gravado na base */
    If WK_NFRem->EYY_RECNO <> 0
       /* Se estiver marcado como deletado, é poque o registro está sendo restaurado */
       If WK_NFRem->DBDELETE
          nPos:= AScan(aNfRemDeletados, WK_NFRem->EYY_RECNO)
          /* Retira da relação de itens deletados */
          If nPos > 0
             ADel(aNfRemDeletados, nPos)
             ASize(aNfRemDeletados, Len(aNfRemDeletados) - 1)
          EndIf
       Else
          AAdd(aNfRemDeletados, WK_NFRem->EYY_RECNO)
       EndIf
    EndIf

   If !Empty(WK_NFRem->EYY_NFENT)
    //nQtdeUMNFe := EasyConvQt( Wk_NfRem->EYY_COD_I , {{ If(lFimEspecNew, Wk_NfRem->EYY_UNIDAD ,WorkIp->EE9_UNIDAD), Wk_NfRem->EYY_QUANT }}                                                            , If(lFimEspecNew, Wk_NfRem->EYY_UMDSD1,WorkIp->EE9_UNIDAD) )
      nQtdeUMNFe := EasyConvQt( Wk_NfRem->EYY_COD_I , GetEYYQtds( "Wk_NfRem", "WORK" , If(lFimEspecNew, Wk_NfRem->EYY_UNIDAD ,WorkIp->EE9_UNIDAD) , If(lFimEspecNew, Wk_NfRem->EYY_UMDSD1,WorkIp->EE9_UNIDAD),,,"1") , If(lFimEspecNew, Wk_NfRem->EYY_UMDSD1,WorkIp->EE9_UNIDAD) )
      /* Se o usuário estiver deletando o registro */
      If !WK_NFRem->DBDELETE
         If (lRet:= MsgYesNo(STR0181, STR0182))//"Este item está vinculado à uma nota fiscal de entrada. Deseja apagá-lo?", "Exlusão de Vinculação"
            SaldoTmpSD1(WK_NFRem->SD1_RECNO, nQtdeUMNFe /*WK_NFRem->EYY_QUANT*/, SUBTRAIR)
            AtuWK_NFRem(0, WK_NFRem->EYY_QUANT)
         EndIf
      Else

         /* Se o usuário estiver restaurando o registro */
         M->EYY_QUANT:= WK_NFRem->EYY_QUANT
         If !AE110ValNfRem("EYY_QUANT")
            lRet:= .F.
            Break
         EndIf

         If (lRet:= MsgYesNo(STR0183, STR0182)) //"Deseja restaurar o registro?", "Exlusão de Vinculação"
            SaldoTmpSD1(WK_NFRem->SD1_RECNO, nQtdeUMNFe /*WK_NFRem->EYY_QUANT*/, SOMAR)
            AtuWK_NFRem(WK_NFRem->EYY_QUANT, 0)
         EndIf
      EndIf
   EndIf

End Sequence

RestOrd(aOrd, .T.)
Return lRet

/*
Função     : AE110SD1F3()
Objetivo   : Exibir itens da SD1 que podem ser associados aos itens do embarque, destinados
             à exportação indireta
Parâmetros :
Retorno    :
Autor      : WFS
Data       : jun/2016
Observações: Variável lExecConPad1 é de controle; indica se a consulta padrão via validação do campo EYY_NFENT deve ser executada
Revisão    :
*/
Function AE110SD1F3()
Local aEnchoice:= {}
Local nCont
Local oDlg, oMsMget, oBrowse
Local aDados:= {}
Local aSeek := {}
Local bOk:= {|| If( ValOkF3(aCampos, aDados[oBrowse:nAt]) , ( GrvDados(aCampos, aDados[oBrowse:nAt]), lRet:= .T., lExecConPad1:= .F.,  oDlg:End() ) , ) }
Local bCancel:= {|| lRet:= .F., lExecConPad1:= .T., If(Empty(M->EYY_NFENT),M->EYY_NFENT:= WK_NFRem->EYY_NFENT,), oDlg:End()}
Local lRet:= .T.
Local nRecNoOrig:= WK_NFRem->(RecNo())
Local lFiltNcm := EasyGParam("MV_EEC0051",,.F.)
Local nTamDesc := 50
Local nAlTela  := 60
Local lFimEspecNew := AvFlags("ROTINA_VINC_FIM_ESPECIFICO_RP12.1.20")
Local lBkpAlt
Local lBkpInc

Private aTela:= {}, aGets:= {}
Private cTitulo:= STR0184 //"Notas fiscais de entrada"
Private aCampos:= {}
Private aFilter:= {}

Begin Sequence

   If EasyGParam("MV_EEC0050",,0) > 0
      cTitulo += ", " + STR0185 //"com emissão em até ### dias."
      cTitulo:= StrTran(cTitulo, "###", AllTrim(Str(EasyGParam("MV_EEC0050"))))
      If lFiltNcm
         cTitulo += " "
      EndIf
   EndIf

   If lFiltNcm
      cTitulo += STR0186 //"Filtro por N.C.M. "
   EndIf

   /* Carrega em memória os registros da parte superior. */
   aEnchoice:= {"EYY_COD_I"}
   //LRS - 11/07/2018
   IF WK_NFRem->(FieldPos("EYY_VM_DES")) > 0
      AADD(aEnchoice,"EYY_VM_DES")
      M->EYY_VM_DES:= WK_NFRem->EYY_VM_DES
   EndIF

   M->EYY_COD_I := WK_NFRem->EYY_COD_I

   If lFimEspecNew
      aAdd(aEnchoice, "EYY_UNIDAD")
      M->EYY_UNIDAD:= WK_NFRem->EYY_UNIDAD
   EndIf

   If lFiltNcm
      AAdd(aEnchoice, "EYY_POSIPI")
      M->EYY_POSIPI:= WK_NFRem->EYY_POSIPI
   EndIf

   /* Campos que serão exibidos na parte inferior */
   aCampos:= {"D1_DOC", "D1_SERIE", "D1_EMISSAO", "D1_FORNECE", "D1_LOJA", "D1_ITEM", "D1_TES", "D1_CF", "D1_SLDEXP", "D1_QUANT", "D1_UM" ,"R_E_C_N_O_"}

   If lFiltNcm
      aAdd(aCampos, NIL)
      aIns(aCampos, 6)
      aCampos[6] := "D1_COD"

      AAdd(aCampos, NIL)
      AIns(aCampos, 7)
      aCampos[7]:= "B1_DESC"
   EndIf

   /* Campos usados na pesquisa */
   AAdd(aSeek, {AvSx3("D1_DOC", AV_TITULO)    , {{"", AvSx3("D1_DOC", AV_TIPO)    , AvSx3("D1_DOC", AV_TAMANHO)    , AvSx3("D1_DOC", AV_DECIMAL)    , AvSx3("D1_DOC"    , AV_TITULO)}}})
   AAdd(aSeek, {AvSx3("D1_FORNECE", AV_TITULO), {{"", AvSx3("D1_FORNECE", AV_TIPO), AvSx3("D1_FORNECE", AV_TAMANHO), AvSx3("D1_FORNECE", AV_DECIMAL), AvSx3("D1_FORNECE", AV_TITULO)}}})

   /* Campos usados no filtro */
   AAdd(aFilter, {AvSx3("D1_DOC", AV_TITULO)    , AvSx3("D1_DOC", AV_TITULO)    , AvSx3("D1_DOC", AV_TIPO)    , AvSx3("D1_DOC", AV_TAMANHO)    , AvSx3("D1_DOC", AV_DECIMAL), ""})
   AAdd(aFilter, {AvSx3("D1_SERIE", AV_TITULO)  , AvSx3("D1_SERIE", AV_TITULO)  , AvSx3("D1_SERIE", AV_TIPO)  , AvSx3("D1_SERIE", AV_TAMANHO)  , AvSx3("D1_SERIE", AV_DECIMAL), ""})
   AAdd(aFilter, {AvSx3("D1_EMISSAO", AV_TITULO), AvSx3("D1_EMISSAO", AV_TITULO), AvSx3("D1_EMISSAO", AV_TIPO), AvSx3("D1_EMISSAO", AV_TAMANHO), AvSx3("D1_EMISSAO", AV_DECIMAL), ""})
   AAdd(aFilter, {AvSx3("D1_FORNECE", AV_TITULO), AvSx3("D1_FORNECE", AV_TITULO), AvSx3("D1_FORNECE", AV_TIPO), AvSx3("D1_FORNECE", AV_TAMANHO), AvSx3("D1_FORNECE", AV_DECIMAL), ""})
   AAdd(aFilter, {AvSx3("D1_LOJA", AV_TITULO)   , AvSx3("D1_LOJA", AV_TITULO)   , AvSx3("D1_LOJA", AV_TIPO)   , AvSx3("D1_LOJA", AV_TAMANHO)   , AvSx3("D1_LOJA", AV_DECIMAL), ""})
   AAdd(aFilter, {AvSx3("D1_TES", AV_TITULO)    , AvSx3("D1_TES", AV_TITULO)    , AvSx3("D1_TES", AV_TIPO)    , AvSx3("D1_TES", AV_TAMANHO)    , AvSx3("D1_TES", AV_DECIMAL), ""})
   AAdd(aFilter, {AvSx3("D1_CF", AV_TITULO )    , AvSx3("D1_CF", AV_TITULO)     , AvSx3("D1_CF", AV_TIPO)     , AvSx3("D1_CF", AV_TAMANHO)     , AvSx3("D1_CF", AV_DECIMAL), ""})

   If EasyEntryPoint("EECAE110")
      ExecBlock("EECAE110", .F., .F., "ADD_CAMPOS")
   EndIf
  /*THTS - 31/01/2019 - Sempre que for necessario adicionar um campo ao aCampos que não pertenca ao dicionario de dados, 
                        ele deve ser adicionado apos a chamada do ponto de entrada "ADD_CAMPOS".
  */
  //Movido para após a execução do ponto de entrada, pois deve sempre ser o último campo da lista
   If lFimEspecNew
      aAdd(aCampos,"SLD_UM_CONV")
   EndIf

   /* Retorna os dados que serão exibidos na parte inferior. */
   aDados:= RetSD1(aCampos)

   /* Se não houver dados, redefine a ação do botão OK. */
   If Len(aDados) == 0
      bOk:= bCancel
   EndIf

   Define MsDialog oDlg Title STR0184 From DLG_LIN_INI, DLG_COL_INI To DLG_LIN_FIM * 0.9, DLG_COL_FIM * 0.9 Of oMainWnd Pixel //"Notas fiscais de entrada"

      /* Parte superior */
      lBkpAlt := ALTERA
      lBkpInc := INCLUI

      oMsMget:= MsmGet():New("EYY",, 2,,,, aEnchoice, {0, 0,nAlTela, 0}, {},,,,, oDlg,.T.,.T.,,, .T.)

      ALTERA := lBkpAlt
      INCLUI := lBkpInc

      oMsMget:oBox:Align:= CONTROL_ALIGN_TOP

      /* Parte inferior */
      oBrowse:= FWBrowse():New(oDlg)

         oBrowse:SetDataArray()
         oBrowse:SetArray(aDados)
         oBrowse:SetDescription(cTitulo)

         For nCont:= 1 To Len(aCampos)
            If aCampos[nCont] <> "R_E_C_N_O_"
               If lFimEspecNew .And. aCampos[nCont] == "SLD_UM_CONV"                             //"Saldo Conv.Unid.Embarque"
                  Add COLUMN oColumn Data &("{|| aDados[oBrowse:nAt][" + Str(nCont) + "]}") Title STR0190 Size AvSx3("D1_QUANT", AV_TAMANHO) Picture AvSx3("D1_QUANT", AV_PICTURE) Of oBrowse
               ElseIf lFimEspecNew .And. aCampos[nCont] == "D1_QUANT"                            //"Saldo Qtde. da Nota Fiscal"
                  Add COLUMN oColumn Data &("{|| aDados[oBrowse:nAt][" + Str(nCont) + "]}") Title STR0191 Size AvSx3(aCampos[nCont], AV_TAMANHO) Picture AvSx3(aCampos[nCont], AV_PICTURE) Of oBrowse
               ElseIf lFimEspecNew .And. aCampos[nCont] == "D1_SLDEXP"                           //"Saldo Disp.Export.(Unid.Med.da NF)"
                  Add COLUMN oColumn Data &("{|| aDados[oBrowse:nAt][" + Str(nCont) + "]}") Title STR0192 Size AvSx3(aCampos[nCont], AV_TAMANHO) Picture AvSx3(aCampos[nCont], AV_PICTURE) Of oBrowse
               ElseIf lFimEspecNew .And. aCampos[nCont] == "D1_UM"                               //"Unidade de Medida da NF"
                  Add COLUMN oColumn Data &("{|| aDados[oBrowse:nAt][" + Str(nCont) + "]}") Title STR0193 Size AvSx3(aCampos[nCont], AV_TAMANHO) Picture AvSx3(aCampos[nCont], AV_PICTURE) Of oBrowse
               Else
                  Add COLUMN oColumn Data &("{|| aDados[oBrowse:nAt][" + Str(nCont) + "]}") Title AvSx3(aCampos[nCont], AV_TITULO) Size AvSx3(aCampos[nCont], AV_TAMANHO) Picture AvSx3(aCampos[nCont], AV_PICTURE) Of oBrowse
               EndIf
            EndIf
         Next

         /* Pesquisa */
         oBrowse:SetSeek(, aSeek)

         /* Filtro */
         oBrowse:SetUseFilter()
         oBrowse:SetFieldFilter(aFilter)

      oBrowse:Activate()

	Activate MsDialog oDlg On Init (EnchoiceBar(oDlg, bOk, bCancel,,,,,,,.F.))

End Sequence

/* Atualização do browse */
oGetNfRem:oBrowse:Refresh()
If nRecNoOrig <> WK_NFRem->(RecNo())
   nBrLin:= nRecNoOrig
   WK_NFRem->(DBGoTo(nRecNoOrig))
EndIf

Return lRet

/*
Função     : RetSD1()
Objetivo   : Listar as notas fiscais de entrada que podem ser usadas para vinculação ao processo de exportação
Parâmetros : aCampos - campos a serem considerados no retorno de dados
Retorno    : aDados - array as notas fiscais que podem ser exibidas
Autor      : WFS
Data       : jun/2016
Revisão    :
*/
Static Function RetSD1(aCampos)
Local cWhere:= "", cDelete:= "", cPrefixo:= ""
Local nCont, nPos
Local aDados:= {}, aReg:= {}
Local aArea:= GetArea()
Local nSldUsado
Local lFiltNcm := EasyGParam("MV_EEC0051",,.F.)
Local nPosCpoUMD, nPosCpoSld
Local lFimEspecNew := AvFlags("ROTINA_VINC_FIM_ESPECIFICO_RP12.1.20")
Local cUnidPara := ""

Private cQuery:= ""

Begin Sequence

   DBSelectArea("SD1")

   If TcSrvType() <> "AS/400"
      cDelete := " And D1.D_E_L_E_T_ <> '*'"
   EndIf

   cQuery:= "Select "
   For nCont:= 1 To Len(aCampos)

      If aCampos[nCont] == "SLD_UM_CONV"
         Loop
      EndIf

      If nCont > 1
         cQuery += ", "
      EndIf

      If aCampos[nCont] == "R_E_C_N_O_"
         cPrefixo:= "D1."
      ElseIf SubStr(aCampos[nCont], 1, 1) == "S"
         cPrefixo:= SubStr(aCampos[nCont], 1, 3) + "."
      Else
         cPrefixo:= SubStr(aCampos[nCont], 1, 2) + "."
      EndIf
      cQuery +=  cPrefixo + aCampos[nCont]
   Next

   cQuery += " From " + RetSqlName("SD1") + " D1"

   If lFiltNcm
      cQuery += " Inner Join " + RetSqlName("SB1") + " B1"                       //NCF - 08/07/2016 - Trazer Itens de NF por N.c.m
      cQuery += " On D1.D1_COD = B1.B1_COD"
   EndIf

   cWhere:= " Where D1.D1_FILIAL = '" + SD1->(xFilial()) + "' And D1.D1_SLDEXP <> 0"

   If lFiltNcm
      cWhere += " AND B1.B1_POSIPI = '" + WK_NFRem->EYY_POSIPI + "'"
   Else
      cWhere += " And D1.D1_COD = '" + WK_NFRem->EYY_COD_I + "'"
   EndIf

   If EasyGParam("MV_EEC0050",,0) > 0
      cWhere  += " And D1.D1_EMISSAO > '" + DtoS(dDataBase - EasyGParam("MV_EEC0050")) + "'"
   EndIf

   /* Montagem da Query */
   cQuery += cWhere + cDelete

   If EasyEntryPoint("EECAE110")
      ExecBlock("EECAE110", .F., .F., "MUDA_QUERY")
   EndIf

   cQuery:= ChangeQuery(cQuery)
   TcQuery cQuery Alias "SD1TMP" New

   For nCont:= 1 To Len(aCampos)
      If aCampos[nCont] <> "R_E_C_N_O_" .And. ( !lFimEspecNew .Or. !(aCampos[nCont] == "SLD_UM_CONV") )
         If AvSx3(aCampos[nCont], AV_TIPO) == "N"
            TcSetField("SD1TMP", aCampos[nCont], "N", AvSx3(aCampos[nCont], AV_TAMANHO), AvSx3(aCampos[nCont], AV_DECIMAL))
         ElseIf AvSx3(aCampos[nCont], AV_TIPO) == "C"
            TcSetField("SD1TMP", aCampos[nCont], "C", AvSx3(aCampos[nCont], AV_TAMANHO))
         ElseIf AvSx3(aCampos[nCont], AV_TIPO) == "D"
            TcSetField("SD1TMP", aCampos[nCont], "D")
         EndIf
      EndIf
   Next

   nPosCpoUMD := aScan(aCampos,"D1_UM")
   nPosCpoSld := aScan(aCampos,"D1_SLDEXP")

   /* Array com os registros a serem exibidos. */
   SD1TMP->(DBGoTop())
   While SD1TMP->(!Eof())

      /* Atualização do saldo.
         Serão abatidas as quantidades associadas ao processo em edição. */
      nSldUsado:= 0
      If (nPos:= AScan(aSaldoNFE, {|x| x[1] == SD1TMP->R_E_C_N_O_})) > 0
         nSldUsado:= aSaldoNFE[nPos][2]
      EndIf

      /* Se o saldo se mantiver superior a 0, será exibido */
      If (SD1TMP->D1_SLDEXP - nSldUsado) > 0
         aReg:= {}
         For nCont:= 1 To SD1TMP->(FCount())
            If SD1TMP->(FieldName(nCont)) <> "D1_SLDEXP"
               AAdd(aReg, SD1TMP->&(FieldName(nCont)))
            Else
               AAdd(aReg, SD1TMP->&(FieldName(nCont)) - nSldUsado)
            EndIf
         Next
         AAdd(aDados, AClone(aReg))
         If lFimEspecNew //NCF - 15/02/2017
            If Alltrim(aDados[Len(aDados)][nPosCpoUMD]) == "KG"
               cUnidPara := If(!Empty(WorkIP->EE9_UNPES), WorkIP->EE9_UNPES,If(!Empty(EEC->EEC_UNIDAD),EEC->EEC_UNIDAD,"KG"))
            Else
               cUnidPara := M->EYY_UNIDAD
            EndIf
            AAdd( aDados[Len(aDados)] , EasyConvQt( M->EYY_COD_I , GetEYYQtds( "Wk_NFRem" ,"ARRAY" , aDados[Len(aDados)][nPosCpoUMD] , aDados[Len(aDados)][nPosCpoUMD], aDados , aCampos , "2"  ) , cUnidPara ) )
         EndIf
      EndIf

      SD1TMP->(DBSkip())
   EndDo

   SD1TMP->(DBCloseArea())

End Sequence

RestArea(aArea)
Return AClone(aDados)

/*
Função     : GrvDados()
Objetivo   : Atualizar os dados da work WK_NFRem, controlar o saldo usado e
             posicionar a SD1 para retorno das demais informações
             - Deve controlar a inclusão/ exclusão da linha na work, de acordo com o  saldo
               vindo da tabela SD1
             - Deve controlar o saldo do item usado, para atualização da tabela SD1
             com o saldo que estiver vindo da
Parâmetros : aCampos - campos exibidos na consulta padrão
             aDados - array as informações da linha posicionada
Retorno    :
Autor      : WFS
Data       : jun/2016
Revisão    :
*/
Static Function GrvDados(aCampos, aDados)
Local lRet:= .T.
Local nPos:= 0
Local nRecNoSD1
Local nQuantidade, nQtdeUMEmb , nQtdeUMNFe
Local lFimEspecNew := AvFlags("ROTINA_VINC_FIM_ESPECIFICO_RP12.1.20")
Local cUMPesItEmb, cUMNFeIt, nQtdeBxSD1

Begin Sequence

   If Len(aDados) == 0
      Break
   EndIf

   nRecNoSD1:= aDados[AScan(aCampos, "R_E_C_N_O_")]

   cUMPesItEmb := Alltrim( If(!Empty(WorkIP->EE9_UNPES), WorkIP->EE9_UNPES,If(!Empty(EEC->EEC_UNIDAD),EEC->EEC_UNIDAD,"KG")) )
   cUMNFeIt    := Alltrim( aDados[AScan(aCampos, "D1_UM") ] )
   nQtdeBxSD1  := WK_NFRem->EYY_QUANT

   If cUMNFeIt == "KG"
      If cUMPesItEmb <> cUMNFeIt
         nQtdeBxSD1 := EasyConvQt(WorkIP->EE9_COD_I,{{cUMPesItEmb, WK_NFRem->EYY_QUANT * WorkIP->EE9_PSLQUN }},cUMNFeIt,.F.,)
      Else
         nQtdeBxSD1 := WK_NFRem->EYY_QUANT * WorkIP->EE9_PSLQUN
      EndIf
   EndIf

   /* Verifica se o item em edição possui associação à uma nota de entrada
      Se houver, o saldo deve ser abatido, para associação da outra nota informada. */
   SaldoTmpSD1(WK_NFRem->SD1_RECNO, nQtdeBxSD1 /*WK_NFRem->EYY_QUANT*/, SUBTRAIR)

   /* Se a quantidade da nota de entrada for superior a quantidade do item na WK_NFRem,
      assume-se a quantidade da work. Se a quantidade for inferior, ela será assumida e
      deve ser criada uma linha com o residual na work. */
   nQtdeUMEmb := aDados[AScan(aCampos, If( lFimEspecNew , "SLD_UM_CONV" , "D1_SLDEXP" ) )]
   nQtdeUMNFe := aDados[AScan(aCampos, "D1_SLDEXP"   )]

   If nQtdeUMEmb >= WK_NFRem->EYY_QUANT
      nQtdeUMEmb := WK_NFRem->EYY_QUANT
   Else
      AtuWK_NFRem(nQtdeUMEmb, WK_NFRem->EYY_QUANT)
   EndIf

   /* Verifica se o recno da nota de entrada já consta na relação de notas associadas, para
      atualização do saldo consumido */
   SaldoTmpSD1(nRecNoSD1, nQtdeUMEmb , SOMAR)

   /* Posiciona do registro da SD1 para retorno da consulta padrão */
   SD1->(DBGoTo(nRecNoSD1))

   /* Atualiza os valores da WK_NFRem */
   WK_NFRem->(RecLock("WK_NFRem", .F.))

   WK_NFRem->EYY_QUANT := nQtdeUMEmb
   WK_NFRem->SD1_RECNO := nRecNoSD1
   If lFimEspecNew
      Wk_NfRem->EYY_UMDSD1:= SD1->D1_UM
   EndIf
   WK_NFRem->EYY_D1ITEM:= SD1->D1_ITEM
   If EasyGParam("MV_EEC0051",, .F.) .Or. WK_NFRem->(FieldPos("EYY_D1PROD")) > 0 //Manter a gravação do campo, para histórico. Quando o parâmetro estiver desabilitado esta informação será a mesma do campo EYY_COD_I
      WK_NFRem->EYY_D1PROD:= SD1->D1_COD      //NCF - 14/07/2016
   EndIf
   WK_NFRem->EYY_NFENT := SD1->D1_DOC
   WK_NFRem->EYY_SERENT:= SD1->D1_SERIE
   WK_NFRem->EYY_FORN  := SD1->D1_FORNECE
   WK_NFRem->EYY_FOLOJA:= SD1->D1_LOJA
   //NCF - 30/11/2018 - Gravar a seq. do item na Fatura
   If WK_NFRem->(FieldPos("EYY_SQFNFS")) > 0  .And. ChkFile("EES") .And. EES->(FieldPos("EES_FATSEQ")) > 0
      WK_NFRem->EYY_SQFNFS := Posicione( "EES", 1 ,xFilial("EES") + AvKey(WK_NFRem->EYY_PREEMB,"EES_PREEMB") + AvKey(WK_NFRem->EYY_NFSAI,"EES_NRNF") + AvKey(WK_NFRem->EYY_SERSAI,"EES_SERIE") + AvKey(WK_NFRem->EYY_PEDIDO,"EES_PEDIDO") + AvKey(WK_NFRem->EYY_SEQUEN,"EES_SEQUEN") , "EES_FATSEQ" )
   EndIf

   WK_NFRem->(MsUnlock())

End Sequence

Return lRet

/*
Função     : AtuWK_NFRem()
Objetivo   : Atualizar a work WK_NFRem.
             - Quando a quantidade informada for menor que a quantidade "disponível" da WorkIP,
               incluir uma linha nova com o saldo residual para vinculação da nota de entrada
             - Caso seja alterada a nota de entrada e a quantidade de algum registro, deve verificar
               se existe linha sem nota fiscal de entrada associada e atualizar o saldo
             - Caso o saldo fique 0 (zero), excluir a linha da work
Parâmetros : Quantidade digitada pelo usuário
             Saldo residual atual
Retorno    :
Autor      : WFS
Data       : jun/2016
Revisão    :
*/
Static Function AtuWK_NFRem(nQtdInformada, nSaldoAtual)
Local aOrd:= SaveOrd({"WK_NFRem", "WorkIp"})
Local cChave
Local lTemRegistro
Local nNovoSldResidual
Local nRecNoAtual

Begin Sequence

   /* Dados do registro em edição */
   cChave:= WK_NFRem->(EYY_SEQEMB + EYY_NFSAI + EYY_SERSAI)
   nRecNoAtual:= WK_NFRem->(RecNo())
   WK_NFRem->(DBSetOrder(1)) //EYY_SEQEMB + EYY_NFSAI + EYY_SERSAI

   /* A WorkIp deve estar posicionada para atualização da WK_NFRem */
   WorkIp->(DBSetOrder(2)) //EE9_SEQEMB + EE9_NF + EE9_SERIE
   WorkIp->(DBSeek(cChave))

   lTemRegistro:= .F.
   While WK_NFRem->(!Eof()) .And. WK_NFRem->(EYY_SEQEMB + EYY_NFSAI + EYY_SERSAI) == cChave

      /* se não possui possuir nota fiscal associada, atualizar a quantidade ou excluir o registro */
      If Empty(WK_NFRem->EYY_NFENT) .And. WK_NFRem->(RecNo()) <> nRecNoAtual
         lTemRegistro:= .T.
         Exit
      EndIf
      WK_NFRem->(DBSkip())
   EndDo

   /* Se tiver registro, reapura o saldo considerando os novos valores informados */
   If lTemRegistro
      nNovoSldResidual:= WK_NFRem->EYY_QUANT + (nSaldoAtual - nQtdInformada)
   EndIf

   /* Se a quantidade informada for menor que o saldo residual, verificar se será necessário incluir ou alterar uma linha
      que não possui vinculação com uma nota fiscal de entrada. */
   If nQtdInformada < nSaldoAtual

      If lTemRegistro
         /* Atualização da quantidade */
         GravaWk_NfRem(ALTERAR, nNovoSldResidual)
      Else
         /* Cria uma nova linha em brando, com o saldo residual para vinculação do documento de entrada. */
         GravaWk_NfRem(INCLUIR, nSaldoAtual - nQtdInformada)
      EndIf
   EndIf

   /* Se a quantidade informada for maior que o saldo residual, verificar se a linha que não possui vinculação
      com a nota de entrada permanecerá com saldo.
      Caso o saldo residual seja 0 (zero), a linha deve ser excluída */
   If nQtdInformada > nSaldoAtual

      If !lTemRegistro //neste cenário, não faz sentido não ter registro! Deve ser bloqueado na validação da quantidade informada
         MsgAlert(STR0187, STR0001) //"A quantidade informada é superior que o saldo residual/ quantidade do item no embarque. Problema de vinculação", "Atenção"
         Break
      EndIf

      If nNovoSldResidual > 0
         /* Atualização da linha atual */
         GravaWk_NfRem(ALTERAR, nNovoSldResidual)
      Else
         GravaWk_NfRem(EXCLUIR)
      EndIf
   EndIf

End Sequence

RestOrd(aOrd, .T.)

Return


/*
Função     : SaldoTmpSD1()
Objetivo   : Atualizar o array aSaldoNFE com os dados em edição da tabela SD1
Parâmetros : - Quantidade consumida do item da nota de entrada
             - RecNo do registro da tabela SD1
             - nOperacao: SOMAR = 1; SUBTRAIR = 2
Retorno    :
Autor      : WFS
Data       : jun/2016
Revisão    :
*/
Static Function SaldoTmpSD1(nRecNoSD1, nQuantidade, nOperacao)
Local nPos
Default nQuantidade:= 0
Default nRecNoSD1:= 0
Default nOperacao:= SOMAR

Begin Sequence

   If nRecNoSD1 == 0
      Break
   EndIf

   /* agrega no recno da SD1 ou adiciona no array de controle */
   If nOperacao == SOMAR
      nPos:= AScan(aSaldoNFE, {|x| x[1] == nRecNoSD1})
      If nPos > 0
         aSaldoNFE[nPos][2] += nQuantidade
      Else
         AAdd(aSaldoNFE, {nRecNoSD1, nQuantidade})
      EndIf
   EndIf

   /* abate a quantidade substituida ou deletada da work */
   If nOperacao == SUBTRAIR
      nPos:= AScan(aSaldoNFE, {|x| x[1] == nRecNoSD1})
      If nPos > 0
         aSaldoNFE[nPos][2] -= nQuantidade
      EndIf
   EndIf

End Sequence
Return


/*
Função     : AtualizarSD1()
Objetivo   : Atualizar o saldo para exportação na tabela SD1
Parâmetros : cAlias - tabela EYY ou WK_NFRem
             nOperacao: SOMAR = 1; SUBTRAIR = 2
Retorno    :
Autor      : WFS
Data       : jun/2016
Revisão    :
*/
Static Function AtualizarSD1(cAlias, nOperacao, nQuantidade)
Local lRet:= .T.
Local cProduto
Default nQuantidade:= (cAlias)->EYY_QUANT

Begin Sequence

   /* Posicionamento na WorkIp/EE9, apenas para pegar o código do produto */
   If !Empty((cAlias)->EYY_SEQEMB)
      WorkIp->(DBSetOrder(2)) //EE9_SEQEMB+EE9_NF+EE9_SERIE
      WorkIp->(DBSeek((cAlias)->EYY_SEQEMB))
   Else
      WorkIp->(DBSetOrder(1)) //EE9_PEDIDO+EE9_SEQUEN
      WorkIp->(DBSeek((cAlias)->EYY_PEDIDO + (cAlias)->EYY_SEQUEN))
   EndIf

   /* Garantir a integridade da base de dados, caso o parâmetro MV_EEC0051 tenha sido alternado entre habilitado e desabilitado. */
   //NCF - 14/07/2016
   If EasyGParam("MV_EEC0051",, .F.) .Or. !Empty((cAlias)->EYY_D1PROD)
      cProduto:= (cAlias)->EYY_D1PROD
   Else
      cProduto:= WorkIp->EE9_COD_I
   EndIf

   If SD1->(DBSeek(xFilial() + (cAlias)->EYY_NFENT + (cAlias)->EYY_SERENT + (cAlias)->EYY_FORN + (cAlias)->EYY_FOLOJA + cProduto + AvKey((cAlias)->EYY_D1ITEM, "D1_ITEM") ))

      nQuantidade := Round(avTransUnid((cAlias)->EYY_UNIDAD,SD1->D1_UM,,nQuantidade,.T.),AvSX3("D1_SLDEXP",4)) //Converte a quantidade vinculada na EYY (unidade de medida do item do embarque) para a unidade de medida da SD1

      If nOperacao == SOMAR .And. ((SD1->D1_SLDEXP + nQuantidade) > SD1->D1_QUANT)
         MsgInfo(StrTran(STR0188, "###", AllTrim((cAlias)->EYY_NFENT) + "/ " + AllTrim((cAlias)->EYY_SERENT)), STR0070) //"Inconsistência na atualização do saldo da nota fiscal de entrada ###. O saldo ficará maior que a quantidade registrada no documento de entrada.", "Aviso"
         lRet:= .F.
         Break
      EndIf

      If nOperacao == SUBTRAIR .And. ((SD1->D1_SLDEXP - nQuantidade) < 0)
         MsgInfo(StrTran(STR0189, "###", AllTrim((cAlias)->EYY_NFENT) + "/ " + AllTrim((cAlias)->EYY_SERENT)), STR0070) //"Inconsistência na atualização do saldo da nota fiscal de entrada ###. O saldo ficará negativo.", "Aviso"
         lRet:= .F.
         Break
      EndIf

      SD1->(RecLock("SD1", .F.))

      /* Atualizar o saldo da tabela de notas fiscais de entrada - SD1 - devolvendo o saldo dos registros deletados. */
      If nOperacao == SOMAR
         SD1->D1_SLDEXP += nQuantidade
      EndIf
      /* Atualizar o saldo da tabela de notas fiscais de entrada - SD1 - abatendo o saldo usado na vinculação do documento de entrada
         ao item a exportar. */
      If nOperacao == SUBTRAIR
         SD1->D1_SLDEXP -= nQuantidade
      EndIf

      SD1->(MsUnlock())
   EndIf
End Sequence

Return lRet


/*
Função     : NFRemHasChange()
Objetivo   : Verificar se houve alteração do registro, para atualização da base
Parâmetros :
Retorno    :
Autor      : WFS
Data       : jun/2016
Revisão    :
*/
Static Function NFRemHasChange()
Local lRet:= .F.
Local nCont
Local cCampo
Begin Sequence

   For nCont:= 1 To WK_NFRem->(FCount())

      cCampo:= WK_NFRem->(FieldName(nCont))

      If EYY->(FieldPos(cCampo)) > 0
         If WK_NFRem->&(cCampo) <> EYY->&(cCampo)
            lRet:= .T.
            Break
         EndIf
      EndIf

   Next

End Sequence

Return lRet

/*
Função     : NFRemNewStruct()
Objetivo   : Retonar se a rotina está com nova estrutura de controle de saldo
Parâmetros :
Retorno    :
Autor      : WFS
Data       : jun/2016
Revisão    :
Observação : Remover esta função e suas chamadas quando a funcionalidade for publicada
             no release 12.1.20
*/
Function NFRemNewStruct()
Static lNewStruct
Local aOrdSX3

   If ValType(lNewStruct) == "U"
      lNewStruct:= CHKFile("EYY") .And. EYY->(FieldPos("EYY_SEQEMB")) > 0 /*.And. EYY->(FieldPos("EYY_COD_I")) > 0*/ .And. CHKFile("SD1") .And. SD1->(FieldPos("D1_SLDEXP")) > 0 //MCF - 13/01/2017 - Adicionado EYY_COD_I

      aOrdSX3 := SaveOrd("SX3")        //NCF - 17/03/2017 - Verificação temporária de existência do campo no dicionário de dados para ativação (cliente Durli Couros)
      SX3->(DbSetOrder(2))             //                   Este trecho será posteriormente substituído ou retirado quando homologada a nova rotina de Vinculação de NFs.
      If !SX3->(DbSeek("EYY_COD_I"))   //                   O campo EYY_COD_I só existe como campo de usuário nos clientes que utilizam a nova rotina.
         lNewStruct := .F.
      EndIf
      RestOrd(aOrdSX3,.T.)

   EndIf

Return lNewStruct


Static Function ValOkF3(aCampos, aDados)

Local lRet := .T.

Begin Sequence

//NCF - 22/02/2017 - WFS 21/05/2010 - Validação do fornecedor informado
If (WorkIp->EE9_FABR + WorkIp->EE9_FALOJA) <> ( aDados[AScan(aCampos, "D1_FORNECE")] + aDados[AScan(aCampos, "D1_LOJA")] )
   If !MsgYesNo(STR0025,STR0001) //O fabricante desta nota fiscal não é o mesmo do item do processo. Deseja prosseguir?
      lRet := .F.
      Break
   EndIF
EndIf
//THTS - 05/03/2018 - Verifica se a nota de entrada possui Chave de Acesso F1_CHVNFE
If !EYYCHVNFE(xFilial("SF1"), aDados[AScan(aCampos, "D1_DOC")], aDados[AScan(aCampos, "D1_SERIE")], aDados[AScan(aCampos, "D1_FORNECE")], aDados[AScan(aCampos, "D1_LOJA")])
   lRet := .F.
   Break
EndIf

If aDados[AScan(aCampos, "SLD_UM_CONV")] == -1
   EasyHelp(STR0194,STR0001,STR0195 + " (" + Alltrim(aDados[AScan(aCampos, "D1_UM")]) + " / " + Alltrim(M->EYY_UNIDAD) + ")") //"Item não possui saldo na unidade de medida do Embarque."####"Atenção"####"Verifique se existe o cadastro de conversão de unidade de medida entre o item da Nota e do Embarque."
   lRet := .F.
   Break
EndIf

End Sequence

Return lRet

Static Function GetEYYQtds( cAliasEYY, cTpObj , cUnMedDE , cUnMedSD1, aDados, aCampos , cTipo  )
Local aRet
Local bGet := If(cTpObj <> "ARRAY", {|x,y,z| &( x+"->EYY_QUANT" ) } , {|x,y,z| y[Len(y)][aScan(z,"D1_SLDEXP")] }  )

If cTipo == "1"  // Conversao da qtde. na unidade do embarque para qtde. na unidade da nota
        //   Unidade DE[*]                                            Qtde. DE[*]
   aRet := { { cUnMedDE                                             , Eval(bGet, cAliasEYY ,aDados, aCampos)                                }, ;
             { If(!Empty(WorkIP->EE9_UNPES), WorkIP->EE9_UNPES,"KG"), ( Eval({|x| &( x+"->EYY_QUANT" ) }, cAliasEYY ) * WorkIP->EE9_PSLQUN) }  }
Else
   aRet := {{ cUnMedSD1 , Eval(bGet, cAliasEYY ,aDados, aCampos) }} //Conversão da Qtde. do item da NFe no array aDados para Qtde. do item no embarque
EndIf

Return aRet


/*
Função     : EYYCHVNFE
Objetivo   : Retorna .T. quando existir a chave da nota (F1_CHVNFE) e .F. quando nao existir ou quando nao for possivel verificar (fatam informacoes)
Parâmetros :
Retorno    : .T. - Posicionou SF1 e existe F1_CHVNFE; .F. nao posicionou ou nao existe a informacao F1_CHVNFE
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data       : Marco/2018
*/
Static Function EYYCHVNFE(cFilialSF1,cDocSF1,cSerieSF1,cFornSF1,cLojaSF1,cChaveNFE)
Local lRet        := .T.
Local aAreaSF1    := SF1->(GetArea())

Default cChaveNFE := ""

If !Empty(cFilialSF1) .And. !Empty(cDocSF1) .And. !Empty(cSerieSF1) .And. !Empty(cFornSF1) .And. !Empty(cLojaSF1)
  SF1->(dbSetOrder(1))//F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + F1_TIPO
  If !AvFlags("EEC_LOGIX") .And. SF1->(DbSeek(AvKey(cFilialSF1,"F1_FILIAL") + AvKey(cDocSF1,"F1_DOC") + AvKey(cSerieSF1,"F1_SERIE") + AvKey(cFornSF1,"F1_FORNECE") + AvKey(cLojaSF1,"F1_LOJA")))

    If Empty(SF1->F1_CHVNFE)
      MsgInfo("Esta nota fiscal não pode ser associada, pois não há chave de registro da Nota Fiscal na Sefaz. Efetue a transmissão para a Sefaz para efetuar a associação ao embarque.", STR0001) //"Esta nota fiscal não pode ser associada, pois não há chave de registro da Nota Fiscal na Sefaz. Efetue a transmissão para a Sefaz para efetuar a associação ao embarque." #### "Atenção"
      cChaveNFE := ""
      lRet := .F.
    Else
      cChaveNFE := SF1->F1_CHVNFE
    EndIf

  EndIf
EndIf

RestArea(aAreaSF1)
Return lRet

/*
Função     : ExportDir
================================================================================================
Objetivo   : Identificar se determinado item do embarque caracteriza exportação (in)direta.
================================================================================================
Parâmetros : 
             cForn1 : 1o fornecedor envolvido.
             cForn2 : 2o fornecedor envolvido.
================================================================================================             
Retorno    : .T. - Exportação Direta, .F. - Exportação Indireta
================================================================================================
Autor      : CEO - Carlos Eduardo Olivieri
================================================================================================
Data       : Jul/2018
================================================================================================
Obs.       : Espera-se que já esteja posicionado no registro do item correto da WorkIp
================================================================================================
*/
Static Function ExportDir()

  Local cExportador := ""
  Local lRet := .F.
  Local lExpIndireta :=  (!Empty(M->(EEC_EXPORT+EEC_EXLOJA)) .And. M->(EEC_EXPORT+EEC_EXLOJA) <> M->(EEC_FORN+EEC_FOLOJA) )
  
  lExpIndireta := (!Empty(WorkIp->(EE9_FABR+EE9_FALOJA)) .And. WorkIp->(EE9_FORN+EE9_FOLOJA) <> WorkIp->(EE9_FABR+EE9_FALOJA) ) .Or. lExpIndireta

Return !lExpIndireta