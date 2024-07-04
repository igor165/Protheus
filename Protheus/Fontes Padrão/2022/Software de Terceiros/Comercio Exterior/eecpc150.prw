//Alcir Alves - Revisão - 18-10-05 inclusão de barra de aguarde/Procregua para sinalizar ao usuário o status atual do processo, 
//pois por questão de desempenho para processos com mais de 20 itens os usuários sem os status(barras) tinham a impressão que a rotina travou no sistema.
#Include "eecpc150.ch"
#Include "EEC.cH"

/*                                                                                                  
Programa  : EECPC150.
Objetivo  : Impressão do Relatório de Pré-Calculo.
Autor     : Jeferson Barros Jr.
Data/Hora : 26/05/04 11:52.
Obs       : Para cálculo dos valores, o programa considera as informações do cadastro
            de pré-calculo.
            Considera que o EE7 esteja posicionado (chamada padrão a partir de miscelânea cadastrado
            como documento).
*/

/*
Funcao      : EECPC150().
Parametros  : lPedido - .t. Pedido.
                        .f. Embarque.
              lShowTela - .t. - Mostra tela com os gets.
                          .f. - Não mostra tela gets.
Retorno     : .t./.f.
Objetivos   : Impressão do Relatório de Pré-Calculo.
Autor       : Jeferson Barros Jr.
Data/Hora   : 26/05/04 11:55.
*/ 
*----------------------------------*
Function EECPC150(lPedido,lShowTela)
*----------------------------------*
Local lAgrava:=.f.
Local lRet:=.t., aOrd:=SaveOrd({"SWF"})
Local j:=0, aSemSx3:={}, cArq, cMessageError, nFob:=0, n:=0 //RRV - 25/09/2012
Local cFaseDoc, xDesp,lMSGCUSTO

Private aDespesas:={}  /* aDespesas por dimensão:
                                    aDespesas[1][1] - Codigo.
                                             [1][2] - Descrição.
                                             [1][3] - Valor. 
                                             [1][4] - Moeda */

Private aComissao:={}  /* aComissao por dimensão:
                                    aComissao[1][1] -> Tipo da comissão.
                                             [1][2] -> Total da comissao para o tipo. */

Private aAgentes := {}

Private aCampos:={}
Private aCalculando:={},;
        aCalculado :={}

Private nErro := 0
Private cAliasHd, cAliasIt
Private lIsPedido := .t.
Private aNaoTotaliza:={"104","120","121","122"}

Private cAgente := ""

Default lPedido   := .t.
Default lShowTela := .t.

Begin Sequence
   lMSGCUSTO := EasyGParam("MV_AVG0076",,.T.)
   lIsPedido := lPedido

   If lIsPedido
      cFaseDoc := VD_PRO
      cAliasHd := "EE7"
      cAliasIt := "EE8"
   Else
      cFaseDoc  := VD_EMB
      cAliasHd  := "EEC"
      cAliasIt  := "EE9"
   EndIf

   /* Verifica se o campo 'Tab.Pre-Calc.' existe na capa do pedido. (Campo chave
      para amarração com a tabela de pré-calculo*/
   If lIsPedido
      If EE7->(FieldPos("EE7_TABPRE")) = 0
         MsgStop(STR0001+Replic(ENTER,2)+; //"Problema:"
                 STR0002+Replic(ENTER,2)+; //"O relatório de Pré-Calculo não poderá ser impresso."
                 STR0003+Replic(ENTER,2)+; //"Detalhes:"
                 STR0004,STR0005) //"O ambiente não está configurado para a rotina de Pré-Calculo."###"Atenção"
         lRet:=.f.
         Break
      EndIf

      // ** Para impressão do relatório a tabela base de pré-calculo deve ser informada.
      If Empty(EE7->EE7_TABPRE)
         MsgStop(STR0001+Replic(ENTER,2)+;  //"Problema:"
                 STR0006+Replic(ENTER,2)+; //"Dados insuficientes para impressão do relatório de Pré-Calculo."
                 STR0007+Replic(ENTER,2)+; //"Solução:"
                 STR0008+AllTrim(Avsx3("EE7_TABPRE",AV_TITULO))+STR0009+ENTER+; //"O campo '"###"' deve ser informado no "
                 STR0010,STR0005) //"processo de exportação."###"Atenção"
         lRet:=.f.
         Break
      EndIf
   Else      
      If EXL->(FieldPos("EXL_TABPRE")) = 0
         MsgStop(STR0001+Replic(ENTER,2)+; //"Problema:"
                 STR0002+Replic(ENTER,2)+; //"O relatório de Pré-Calculo não poderá ser impresso."
                 STR0003+Replic(ENTER,2)+; //"Detalhes:"
                 STR0004,STR0005) //"O ambiente não está configurado para a rotina de Pré-Calculo."###"Atenção"
         lRet:=.f.                                                           
         Break
      EndIf

      EXL->(DbSetOrder(1))
      If !EXL->(DbSeek(xFilial("EXL")+EEC->EEC_PREEMB))
         MsgStop(STR0001+Replic(ENTER,2)+; //"Problema:"
                 STR0006+Replic(ENTER,2)+; //"Dados insuficientes para impressão do relatório de Pré-Calculo."
                 STR0007+Replic(ENTER,2)+; //"Solução:"
                 STR0008+AllTrim(Avsx3("EXL_TABPRE",AV_TITULO))+STR0009+ENTER+; //"O campo '"###"' deve ser informado no "
                 STR0010,STR0005) //"processo de exportação."###"Atenção"
         lRet:=.f.
         Break
      EndIf

      // ** Para impressão do relatório a tabela base de pré-calculo deve ser informada.
      If Empty(EXL->EXL_TABPRE)
         MsgStop(STR0001+Replic(ENTER,2)+; //"Problema:"
                 STR0006+Replic(ENTER,2)+; //"Dados insuficientes para impressão do relatório de Pré-Calculo."
                 STR0007+Replic(ENTER,2)+; //"Solução:"
                 STR0008+AllTrim(Avsx3("EXL_TABPRE",AV_TITULO))+STR0009+ENTER+; //"O campo '"###"' deve ser informado no "
                 STR0010,STR0005) //"processo de exportação."###"Atenção"
         lRet:=.f.
         Break
      EndIf
   EndIf

   // ** Ponto de entrada para validações iniciais customizadas.
   If EasyEntryPoint("EECPC150")
      lRet := ExecBlock("EECPC150",.f.,.f.,{"PE_VLDINI",lIsPedido})

      If ValType(lRet) <> "L"
         lRet := .t.
      Elseif !lRet
         Break
      Endif
   EndIf

   // ** Carrega todas as despesas cadastradas no SWI.
   If lIsPedido
      xDesp := LoadDespesas(EE7->EE7_PEDIDO,OC_PE)   
   Else
      xDesp := LoadDespesas(EEC->EEC_PREEMB,OC_EM)   
   EndIf
   
   SYF->(DbSetOrder(3))
   SYF->(DbSeek(xFilial("SYF")+"220")) // RRV - 01/10/2012 
                           
   For n := 1 to Len(xDesp[1])
      If xDesp[1][n][4] == "US$" //MCF - 29/12/2015
         xDesp[1][n][4] := SYF->YF_MOEDA // RRV - 01/10/2012 - Considera a moeda do cadastro que está com YF_COD_GI == "220" para a geração do array aDespesas
      EndIf
   Next

   If ValType(xDesp) == "A"
      aDespesas := If(ValType(xDesp[1]) == "A", xDesp[1],{})
      aAgentes  := If(ValType(xDesp[2]) == "A", xDesp[2],{})
      aComissao := If(ValType(xDesp[3]) == "A", xDesp[3],{})
      

   ElseIf ValType(xDesp) == "N"
      nErro := xDesp

   EndIf

   // ** Flag de indicação de erro fatal na rotina de leitura e cálculo de despesas.
   If nErro <> 0
      cMessageError := GetMsgError(nErro)

      If !Empty(cMessageError)
         EECView(cMessageError,STR0011,STR0012) //"Pré-Custo - Validações"###"Detalhes"
      EndIf

      lRet:=.f.
      Break
   EndIf
   If Len(aDespesas) = 0
      If lIsPedido
         MsgStop(STR0001+Replic(ENTER,2)+; //"Problema:"
                 STR0013+Replic(ENTER,2)+; //"Dados inválidos para impressão do relatório de Pré-Calculo."
                 STR0003+Replic(ENTER,2)+; //"Detalhes:"
                 STR0014+AllTrim(EE7->EE7_TABPRE)+"' "+ENTER+; //"Não foi possível efetuar a leitura das despesas da tabela '"
                 STR0015, STR0005) //"no cadastro de Pré-Calculo."###"Atenção"
         lRet:=.f.
         Break
      Else
         MsgStop(STR0001+Replic(ENTER,2)+; //"Problema:"
                 STR0013+Replic(ENTER,2)+; //"Dados inválidos para impressão do relatório de Pré-Calculo."
                 STR0003+Replic(ENTER,2)+; //"Detalhes:"
                 STR0014+AllTrim(EXL->EXL_TABPRE)+"' "+ENTER+; //"Não foi possível efetuar a leitura das despesas da tabela '"
                 STR0015 ,STR0005) //"no cadastro de Pré-Calculo."###"Atenção"
         lRet:=.f.
         Break
      EndIf
   EndIf

   // ** Cria a alimenta work com as despesas.
   aSemSx3:= {{"WK_DESP"  ,AvSx3("WI_DESP"   ,AV_TIPO), AvSx3("WI_DESP"   ,AV_TAMANHO), AvSx3("WI_DESP"   ,AV_DECIMAL)},;
              {"WK_DESC"  ,AvSx3("WI_DESC"   ,AV_TIPO), AvSx3("WI_DESC"   ,AV_TAMANHO), AvSx3("WI_DESC"   ,AV_DECIMAL)},;
              {"WK_VALOR" ,AvSx3("WI_VALOR"  ,AV_TIPO), AvSx3("WI_VALOR"  ,AV_TAMANHO), AvSx3("WI_VALOR"  ,AV_DECIMAL)},;
              {"WK_MOEDA" ,AvSx3("WI_MOEDA"  ,AV_TIPO), AvSx3("WI_MOEDA"  ,AV_TAMANHO), AvSx3("WI_MOEDA"  ,AV_DECIMAL)},;
              {"WK_VALR"  ,AvSx3("WI_VALOR"  ,AV_TIPO), AvSx3("WI_VALOR"  ,AV_TAMANHO), AvSx3("WI_VALOR"  ,AV_DECIMAL)},;
              {"WK_TX"    ,"N",15,08}}

   cArq := E_CriaTrab(,aSemSx3,"WorkDesp")
   IndRegua("WorkDesp",cArq+TEOrdBagExt(),"WK_DESP",,,STR0016) //"Processando Arquivo Temporário..."
   Set Index To (cArq+TEOrdBagExt())
   
   nFob := EECFob(If(cAliasHd=="EE7",OC_PE,OC_EM),.f.)
   /* JPM - 19/09/05 - Substituído por função genérica
   nFob := ((cAliasHd)->&(cAliasHd+"_TOTPED")+;
            (cAliasHd)->&(cAliasHd+"_DESCON"))-;
           ((cAliasHd)->&(cAliasHd+"_FRPREV")+;
            (cAliasHd)->&(cAliasHd+"_FRPCOM")+;
            (cAliasHd)->&(cAliasHd+"_SEGPRE")+;
            (cAliasHd)->&(cAliasHd+"_DESPIN")+;
            AvGetCpo(cAliasHd+"->"+cAliasHd+"_DESP1")+;
            AvGetCpo(cAliasHd+"->"+cAliasHd+"_DESP2"))
   */

   For j:=1 To Len(aDespesas)
      WorkDesp->(DbAppend())
      WorkDesp->WK_DESP   := aDespesas[j][1]
      WorkDesp->WK_DESC   := aDespesas[j][2]
      WorkDesp->WK_MOEDA  := aDespesas[j][4]
      If AllTrim(aDespesas[j][4]) <> "R$"
         WorkDesp->WK_VALOR  := aDespesas[j][3] // Valor da despesa.
         WorkDesp->WK_TX     := If(WorkDesp->WK_MOEDA == "US$", BuscaTaxa(SYF->YF_MOEDA,dDataBase), BuscaTaxa(WorkDesp->WK_MOEDA,dDataBase)) // RRV - 01/10/2012 - Considera a moeda do cadastro que está com YF_COD_GI == "220"
         WorkDesp->WK_VALR   := Round(WorkDesp->WK_VALOR*WorkDesp->WK_TX,2)
      Else
         WorkDesp->WK_VALOR  := aDespesas[j][3] // Valor da despesa.
         WorkDesp->WK_TX     := 1
         WorkDesp->WK_VALR   := aDespesas[j][3] // Valor da despesa.
      EndIf
         
   Next

   // ** Tela de parâmetros.
   If lShowTela
      If !TelaGets()
         lRet:=.f.
         Break
      EndIf
   EndIf
   lITEM := .F.
   IF lMSGCUSTO
      lItem := MsgYesNo(STR0050,STR0005) //"Deseja imprimir o custo por item ?"###"Atenção"
   ENDIF
   
   cSeqRel  := GetSxeNum("SY0","Y0_SEQREL")
   ConfirmSx8()

   MSAGUARDE({|| lAgrava:=GravaDados(),"Processando","Aguarde.."}) //Alcir Alves - 18-10-05 - informa para o usuárioo status atual.
   // ** Grava as tabelas Header_p e Detail_p para impressão do documento.
   If !lAgrava
      lRet:=.f.
      Break
   EndIf

   If EasyEntryPoint("EECPC150")
      lRet := ExecBlock("EECPC150",.f.,.f.,{"PE_FIM",aDespesas,aComissao,lIsPedido})

      If ValType(lRet) <> "L"
         lRet := .t.
      Elseif !lRet
         Break
      Endif
   EndIf
   Processa({|| GrvHist()}) //Alcir Alves - 18-10-05 - informa para o usuárioo status atual.

End Sequence

If Select("WorkDesp") > 0
   WorkDesp->(E_EraseArq(cArq))
EndIf

RestOrd(aOrd)

Return lRet

/*
Funcao      : TelaGets().
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Tela de parâmetro para configurações antes da impressão do relatório.
Autor       : Jeferson Barros Jr.
Data/Hora   : 26/05/04 15:28.
Obs         : 
*/
*------------------------*
Static Function TelaGets()
*------------------------*
Local lRet:=.f., oDlg, oMark
Local aButtons:={}, aDespPos:={}, aDespBrowse:={}
Local bOk := {|| lRet:=.t.,oDlg:End()},;
      bCancel := {|| oDlg:End()}

Begin Sequence

   aDespPos := {25,9,136,350}
   aDespBrowse := {{{|| WorkDesp->WK_DESP+"-"+WorkDesp->WK_DESC}                 , "", STR0025},; //"Despesa"
                   {{|| WorkDesp->WK_MOEDA}                                      , "", STR0051},; //"Moeda"
                   {{|| Transf(WorkDesp->WK_VALOR,AvSx3("WI_VALOR",AV_PICTURE))} , "", STR0026},; //"Valor"
                   {{|| Transf(WorkDesp->WK_TX   ,AvSx3("EEQ_TX",AV_PICTURE))}   , "", STR0030},; //"Taxa"
                   {{|| Transf(WorkDesp->WK_VALR ,AvSx3("WI_VALOR",AV_PICTURE))} , "", STR0052}} //"Valor R$"

   WorkDesp->(DbGoTop())

   Define MsDialog oDlg Title STR0028 From 9,0 TO 28, 091 OF oMainWnd //"Relatório de Pré-Cálculo "

      @ 15,05 To 140,355 Label STR0031 Of oDlg Pixel //"Despesas"
      oMark := MsSelect():New("WorkDesp",,,aDespBrowse,,,aDespPos)

   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel,,aButtons) Centered

End Sequence

Return lRet

/*
Funcao      : GravaDados().
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Alimentar as tabelas para o relatório (Header_p/Detail_p).
Autor       : Jeferson Barros Jr.
Data/Hora   : 31/05/04 - 08:47.
Obs         :
*/
*--------------------------*
Static Function GravaDados()
*--------------------------*
Local cTipTra, cVia,;
      cPictPre  := If(lIsPedido,AvSx3("EE7_TOTPED",AV_PICTURE),AvSx3("EEC_TOTPED",AV_PICTURE)),;
      cPictQtde := If(lIsPedido,AvSx3("EE8_SLDINI",AV_PICTURE),AvSx3("EE9_SLDINI",AV_PICTURE)),;
      cPictPeso := If(lIsPedido,AvSx3("EE8_PSLQUN",AV_PICTURE),AvSx3("EE9_PSLQUN",AV_PICTURE)),;
      cTipCom,;
      cPictTx := "@E 999.9999"

Local lRet:=.t., lGravaAgente:=.t.
Local aOrd:=SaveOrd({"SYQ","SYR","SY9","SA2","EE5","EE6","EE8","EEB","SB1"}),;
      aValores:={},; // {1-Val.Unit.R$/2-Val.Unit./3-Val.Tot. R$/4-Val.Tot/5-% Fob.}
      aTx := {}

Local nAdianDesp:=0, nComplDesp:=0, nDevolDesp:=0, nPos:=0, j:=0 ,;
      nPosComis :=0, nValCom   :=0, nSumVlUnReais:=0, nSumVlUn:=0,;
      nSumVlTotReais:=0, nSumVlTot:=0, nSumPerc:=0, nValFob :=0  ,;
      nSumDespReais:=0, nSumDesp:=0, nCont:=0, nFobReais, nPercAux:=0

Begin Sequence
   For j:=1 To Len(aDespesas)
      If aScan(aTx,{|x| x[1] == aDespesas[j][4] }) = 0
         If AllTrim(aDespesas[j][4]) <> "R$"
            aAdd(aTx,{If(aDespesas[j][4] == "US$",SYF->YF_MOEDA,aDespesas[j][4]),If(aDespesas[j][4] == "US$",BuscaTaxa(SYF->YF_MOEDA,dDataBase),BuscaTaxa(aDespesas[j][4],dDataBase))}) // RRV - 01/10/2012 - Considera a moeda do cadastro que está com YF_COD_GI == "220" para buscar taxa da moeda.
         Else
            aAdd(aTx,{aDespesas[j][4],1}) 
         EndIf
      EndIf
   Next

   nValFob := EECFob(If(cAliasHd=="EE7",OC_PE,OC_EM),.f.)
   /* JPM - 19/09/05 - Substituído por função genérica
   nValFob := ((cAliasHd)->&(cAliasHd+"_TOTPED")+;
               (cAliasHd)->&(cAliasHd+"_DESCON"))-;
              ((cAliasHd)->&(cAliasHd+"_FRPREV")+;
               (cAliasHd)->&(cAliasHd+"_FRPCOM")+;
               (cAliasHd)->&(cAliasHd+"_SEGPRE")+;
               (cAliasHd)->&(cAliasHd+"_DESPIN")+;
               AvGetCpo(cAliasHd+"->"+cAliasHd+"_DESP1")+;
               AvGetCpo(cAliasHd+"->"+cAliasHd+"_DESP2"))
   */
   
   // ** Grava as informações para o header do relatório.
   Header_p->(DbAppend())
   Header_p->AVG_FILIAL := xFilial("SY0")
   Header_p->AVG_SEQREL := cSeqRel

   If lIsPedido
      Header_p->AVG_CHAVE  := EE7->EE7_PEDIDO
      Header_p->AVG_C01_20 := AllTrim(Transf(EE7->EE7_PEDIDO,AvSx3("EE7_PEDIDO",AV_PICTURE))) // ** Processo.
   Else
      Header_p->AVG_CHAVE  := EEC->EEC_PREEMB
      Header_p->AVG_C01_20 := AllTrim(Transf(EEC->EEC_PREEMB,AvSx3("EEC_PREEMB",AV_PICTURE))) // ** Processo.  
   EndIf   

   SA2->(DbSetOrder(1))
   If !Empty((cAliasHd)->&(cAliasHd+"_EXPORT"))
      SA2->(DbSeek(xFilial("SA2")+(cAliasHd)->&(cAliasHd+"_EXPORT")+;
                                  (cAliasHd)->&(cAliasHd+"_EXLOJA")))
   Else
      SA2->(DbSeek(xFilial("SA2")+(cAliasHd)->&(cAliasHd+"_FORN")+;
                                  (cAliasHd)->&(cAliasHd+"_FOLOJA")))
   EndIf

   // ** Exportador.
   Header_p->AVG_C01_60 := AllTrim(SA2->A2_NOME)

   // ** Importador.
   Header_p->AVG_C02_60 := AllTrim((cAliasHd)->&(cAliasHd+"_IMPODE"))

   // ** Agente Embarcador.
   
   /*
      ER - 05/09/2006
      A variavel cAgente é declarada como Private e carregada na Função CalcFrete(),
      assim será exibido o Agente que apresenta a melhor Taxa de Frete.
   */
   SY5->(DbSetOrder(1))
   If SY5->(DbSeek(xFilial("SY5")+AvKey(cAgente,"Y5_COD")))
      Header_p->AVG_C03_60 := AllTrim(cAgente)+Space(1)+AllTrim(SY5->Y5_NOME)
   EndIf
   
   /*
   If lIsPedido
	   BuscaEmpresa(EE7->EE7_PEDIDO,OC_PE,CD_AGE)
	Else
	   BuscaEmpresa(EEC->EEC_PREEMB,OC_EM,CD_AGE)
	EndIf
   Header_p->AVG_C03_60 := EEB->EEB_CODAGE+Space(1)+EEB->EEB_NOME
   */

   SYQ->(DbSetOrder(1))
   If SYQ->(DbSeek(xFilial("SYQ")+(cAliasHd)->&(cAliasHd+"_VIA")))
      cVia := AllTrim(SYQ->YQ_DESCR)
   EndIf

   // ** Total do Pedido.
   Header_p->AVG_C02_20 := "("+AllTrim((cAliasHd)->&(cAliasHd+"_MOEDA"))+") "+;
                           AllTrim(Transf((cAliasHd)->&(cAliasHd+"_TOTPED"),AvSx3(cAliasHd+"_TOTPED",AV_PICTURE)))
   // ** Seguro.
   //Header_p->AVG_C03_20 := "("+AllTrim((cAliasHd)->&(cAliasHd+"_MOEDA"))+") "+;
                           //AllTrim(Transf((cAliasHd)->&(cAliasHd+"_SEGPRE"),AvSx3(cAliasHd+"_SEGPRE",AV_PICTURE)))
   nScan := ascan(aDespesas,{|x| x[1] == "103"})
   
   if nScan > 0 
      Header_p->AVG_C03_20 := "("+If(aDespesas[nScan,4] == "US$",SYF->YF_MOEDA,aDespesas[nScan,4])+") "+; // RRV - 01/10/2012 - Considera a moeda do cadastro que está com YF_COD_GI == "220" para buscar taxa da moeda.
                              AllTrim(Transf(aDespesas[nScan,3],AvSx3(cAliasHd+"_SEGPRE",AV_PICTURE)))
   Else
      Header_p->AVG_C03_20 := Transf(0,AvSx3(cAliasHd+"_SEGPRE",AV_PICTURE))
   Endif    

   // ** Condição de pagamento.
   If lIsPedido
      Header_p->AVG_C05_60 := AllTrim(Sy6Descricao(EE7->EE7_CONDPA+Str(EE7->EE7_DIASPA,AvSx3("EE7_DIASPA",AV_TAMANHO),;
                                                   AvSx3("EE7_DIASPA",AV_DECIMAL)),PORTUGUES,1)) //PORT. PORTUGUES
   Else
      Header_p->AVG_C05_60 := AllTrim(Sy6Descricao(EEC->EEC_CONDPA+Str(EEC->EEC_DIASPA,AvSx3("EEC_DIASPA",AV_TAMANHO),;
                                                   AvSx3("EEC_DIASPA",AV_DECIMAL)),PORTUGUES,1)) //PORT. PORTUGUES
   EndIf

   // ** Preço aberto ou fechado.
   Header_p->AVG_C04_20 := If((cAliasHd)->&(cAliasHd+"_PRECOA") == "1","Aberto","Fechado")

   // ** Via de transporte.
   If !Empty(cVia)
      SY9->(DbSetOrder(2))
      If SY9->(DbSeek(xFilial("SY9")+(cAliasHd)->&(cAliasHd+"_ORIGEM")))
         cVIA += " de "+AllTrim(SY9->Y9_DESCR)
      EndIf

      If SY9->(DbSeek(xFilial("SY9")+(cAliasHd)->&(cAliasHd+"_DEST")))
         cVIA += " para "+AllTrim(SY9->Y9_DESCR)
      EndIf

      Header_p->AVG_C06_60 := AllTrim(cVia)
   EndIf

   // ** Tipo de embalagem.
   EE5->(DbSetOrder(1))
   If EE5->(DbSeek(xFilial("EE5")+(cAliasHd)->&(cAliasHd+"_EMBAFI")))
      Header_p->AVG_C07_60 := AllTrim(EE5->EE5_DESC)
   EndIf

   // ** Valor do Frete.
   //Header_p->AVG_C06_20 := "("+(cAliasHd)->&(cAliasHd+"_MOEDA")+") "+;
     //                      AllTrim(Transf((cAliasHd)->&(cAliasHd+"_FRPREV"),AvSx3(cAliasHd+"_FRPREV",AV_PICTURE)))
   nScan := ascan(aDespesas,{|x| x[1] == "102"})
   if nScan > 0 
      Header_p->AVG_C06_20 := "("+aDespesas[nScan,4]+") "+;
                              AllTrim(Transf(aDespesas[nScan,3],AvSx3(cAliasHd+"_FRPREV",AV_PICTURE)))
   Else
      Header_p->AVG_C06_20 := Transf(0,AvSx3(cAliasHd+"_FRPREV",AV_PICTURE))
   Endif      

   // ** Apura as despesas com Despachante. (P/ impressão do quadro "Observações Gerais".
   For j:=1 To Len(aDespesas)
      Do Case
         Case aDespesas[j][1] == "901" // Adiantamento ao Despachante
            nAdianDesp += aDespesas[j][3]

         Case aDespesas[j][1] == "902" // Complementos ao Despachante
            nComplDesp += aDespesas[j][3]

         Case aDespesas[j][1] == "903" // Devoluções ao Despachante
            nDevolDesp += aDespesas[j][3]
      EndCase
   Next

   // ** Quadro Observações Gerais.
   Header_p->AVG_C05_10 :=  AllTrim(Transf(nAdianDesp,cPictPre)) // ** Adiantamento ao Despachante.
   Header_p->AVG_C06_10 :=  AllTrim(Transf(nComplDesp,cPictPre)) // ** Complementos ao Despachante.
   Header_p->AVG_C07_10 :=  AllTrim(Transf(nDevolDesp,cPictPre)) // ** Devoluções ao Despachante.

   // ** Valor trabalhado com o Despachante.
   Header_p->AVG_C08_10 :=  AllTrim(Transf(((nAdianDesp+nComplDesp)-nDevolDesp),cPictPre))

   /* Inicio dos Tratamentos e Gravação dos Detalhes.
      - Relatório principal
      - Sub-Relatório de Agentes;
      - Sub-Relatório de Despesas;
      - Sub-Relatório de Custo por Item. 
   */

   If Len(aAgentes) > 0
      For j:=1 To Len(aAgentes)
         AddDet("AGE",If(j=1,"A",".")) // Inclui registro no sub-report agentes, para a sessao Det "a" do Relatório.

         // ** Descrição do agente.
         Detail_p->AVG_C01_60 := AllTrim(aAgentes[j][1])

         // ** Tipo da comissão.
         Do Case
            Case aAgentes[j][2] == "1"
                 Detail_p->AVG_C02_60 := STR0037 //"120-A Remeter"
            Case aAgentes[j][2] == "2"
                 Detail_p->AVG_C02_60 := STR0038 //"121-Conta Gráfica"
            Case aAgentes[j][2] == "3"
                 Detail_p->AVG_C02_60 := STR0039 //"122-A Deduzir da Fatura"
         EndCase

         // ** Valor da comissao.
         Detail_p->AVG_C01_20 := AllTrim(Transf(aAgentes[j][3],AvSx3(cAliasHd+"_TOTPED",AV_PICTURE)))
      Next
   EndIf

   /* Tratamentos para impressão das despesas.
      As despesas são impressas a partir da tabela de pré-cálculo 
      especificada na capa do processo. */

   For j:=1 To Len(aDespesas)
      AddDet("DES",If(j=1,"B",".")) // Inclui registro no sub-report Despesas, para a sessao Det "B" do Relatório.
      Detail_p->AVG_C02_10 := "A" // Flag para a sessao "a" do sub-report Despesas.

      // ** Descrição da Despesa.
      Detail_p->AVG_C01_60 := AllTrim(aDespesas[j][1])+"-"+AllTrim(aDespesas[j][2])
      
      // ** Valor em R$.
      If AllTrim(aDespesas[j][4]) <> "R$"
         Detail_p->AVG_C01_20 := AllTrim(Transf(Round(If(aDespesas[j][4] == "US$",aDespesas[j][3]*BuscaTaxa(SYF->YF_MOEDA,dDataBase),aDespesas[j][3]*BuscaTaxa(aDespesas[j][4],dDataBase)),2),cPictPre)) // RRV - 01/10/2012 - Considera a moeda do cadastro que está com YF_COD_GI == "220"
         Detail_p->AVG_C04_20 := AllTrim(Transf(round(If(aDespesas[j][4] == "US$", BuscaTaxa(SYF->YF_MOEDA,dDataBase), BuscaTaxa(aDespesas[j][4],dDataBase)),4),cPictTx)) // RRV - 01/10/2012 - Considera a moeda do cadastro que está com YF_COD_GI == "220" para buscar taxa da moeda.
      Else
         Detail_p->AVG_C01_20 := AllTrim(Transf(round((aDespesas[j][3]),2),cPictPre))
         Detail_p->AVG_C04_20 := AllTrim(Transf(1,cPictTx))
      EndIf

      // ** Valor na Moeda do Processo.
      Detail_p->AVG_C02_20 := AllTrim(Transf(round(aDespesas[j][3],2),cPictPre))
      
      // ** % em relação ao FOB.
      If aDespesas[j][1] == "101"
         Detail_p->AVG_C03_20 := "Base"
      Else
         If AllTrim(aDespesas[j][4]) <> "R$"
            nPercAux :=  Round(;
                         Round((aDespesas[j][3]*If(aDespesas[j][4] == "US$", BuscaTaxa(SYF->YF_MOEDA,dDataBase), BuscaTaxa(aDespesas[j][4],dDataBase))/; // RRV - 01/10/2012 - Considera a moeda do cadastro que está com YF_COD_GI == "220" para buscar taxa da moeda.
                                BuscaTaxa(If(lIsPedido,EE7->EE7_MOEDA,EEC->EEC_MOEDA),dDatabase))/nValFob,4)*100,2)
         Else
            nPercAux :=  Round(;
                         Round((aDespesas[j][3]/;
                                BuscaTaxa(If(lIsPedido,EE7->EE7_MOEDA,EEC->EEC_MOEDA),dDatabase))/nValFob,4)*100,2)
         EndIf

         Detail_p->AVG_C03_20 := AllTrim(Transf(nPercAux,"@E 999999.99"))

         If aScan(aNaoTotaliza,aDespesas[j][1]) = 0
            nSumPerc += nPercAux
         EndIf
      EndIf

      /*
      Detail_p->AVG_C03_20 := If(aDespesas[j][1]=="101","Base", AllTrim(Transf(Round(;
                                (((aDespesas[j][3]*BuscaTaxa(aDespesas[j][4],dDataBase));
                                /BuscaTaxa(if(lIsPedido,EE7->EE7_MOEDA,EEC->EEC_MOEDA),dDatabase))/nValFob);
                                *100,2),"@E 999999.99"))) */
      
      If aDespesas[j][1] == "101"
         nFobReais := round((aDespesas[j][3]*If(aDespesas[j][4] == "US$", BuscaTaxa(SYF->YF_MOEDA,dDataBase), BuscaTaxa(aDespesas[j][4],dDataBase))),2) // RRV - 01/10/2012 - Considera a moeda do cadastro que está com YF_COD_GI == "220" para buscar taxa da moeda.
      Endif

      // ** Totais.
      If aScan(aNaoTotaliza,aDespesas[j][1]) = 0  // Para despesas de CIF e comissões os valores não são totalizados.
         If AllTrim(aDespesas[j][4]) <> "R$"
            nSumDespReais += round((aDespesas[j][3]*If(aDespesas[j][4] == "US$", BuscaTaxa(SYF->YF_MOEDA,dDataBase), BuscaTaxa(aDespesas[j][4],dDataBase))),2) // RRV - 01/10/2012 - Considera a moeda do cadastro que está com YF_COD_GI == "220" para buscar taxa da moeda.
         Else
            nSumDespReais += round((aDespesas[j][3]),2)
         EndIf
   
         nSumDesp      += round(aDespesas[j][3],2)
      Endif
   Next

   // ** Grava total das despesas.
   AddDet("DES",".") // Inclui registro no sub-report Despesas, para a sessao Det "B" do Relatório.
   Detail_p->AVG_C02_10 := "B" // Flag para a sessao "b" do sub-report Despesas.
   Detail_p->AVG_C01_20 := AllTrim(Transf(round(nSumDespReais,2),cPictPre))
   Detail_p->AVG_C02_20 := AllTrim(Transf(round(nSumDesp,2),cPictPre))

   nSumPerc += 100 // Considera 100% com relação a base (Fob).
   Detail_p->AVG_C03_20 := AllTrim(Transf(nSumPerc,"@E 999999.99")) // ** % em relação ao FOB.

   /*
   Detail_p->AVG_C03_20 := AllTrim(Transf(Round((((nSumDespReais-nFobReais)/BuscaTaxa(if(lIsPedido,EE7->EE7_MOEDA,EEC->EEC_MOEDA),;
                           dDataBase))/nValFob)*100+100,2),"@E 999999.99")) // ** % em relação ao FOB. */
   
   /* Tratamentos para impressão do custo por item.
      O rateio das despesas é efetuado com base nas despesas lançadas na tabela de 
      pré-cálculo na capa do processo. */

   if lItem
      nSumPerc := 0
      If lIsPedido
         EE8->(DbSetOrder(1))
         If EE8->(DbSeek(xFilial("EE8")+EE7->EE7_PEDIDO))
   
            SB1->(DbSetOrder(1))
            SA2->(DbSetOrder(1))
            Do While EE8->(!Eof()) .And. EE8->EE8_FILIAL == xFilial("EE8") .And.;
                                         EE8->EE8_PEDIDO == EE7->EE7_PEDIDO
               nCont++

               // Inclui registro no sub-report Custo por Item, para a sessao Det "C" do Relatório.      
               AddDet("CIT",If(nCont=1,"C","."))
   
               // ** Campo utilizado para agrupamento dos detalhes do sub-relatório Custo por Item.
               Detail_p->AVG_C02_10 := AllTrim(EE8->EE8_SEQUEN)
   
               // Produto.
               If SB1->(DbSeek(xFilial("SB1")+EE8->EE8_COD_I))
                  Detail_p->AVG_C02_60 := Memoline(AllTrim(EE8->EE8_COD_I)+Space(1)+;
                                                   AllTrim(SB1->B1_DESC),60,1)
               EndIf
   
               // Fabricante.
               If SA2->(DbSeek(xFilial("SA2")+EE8->EE8_FABR+EE8->EE8_FALOJA))
                  Detail_p->AVG_C03_60 :=  Memoline(AllTrim(SA2->A2_COD)+" - "+;
                                                    AllTrim(SA2->A2_NOME),60,1)
               EndIf
   
               Detail_p->AVG_C01_20 := AllTrim(Transf(EE8->EE8_SLDINI,cPictQtde)) // Quantidade.
               Detail_p->AVG_C02_20 := AllTrim(Transf(EE8->EE8_PSLQUN,cPictPeso))  // Peso Liq. Unitário.
               Detail_p->AVG_C03_20 := AllTrim(Transf(EE8->EE8_POSIPI,AvSx3("EE8_POSIPI",AV_PICTURE))) // N.C.M
               Detail_p->AVG_C04_20 := AllTrim(Transf(EE8->EE8_PSLQTO,cPictPeso)) // Peso liq. Total.
   
               For j:=1 To Len(aDespesas)
                  AddDet("CIT",".")
                  Detail_p->AVG_C02_10 := AllTrim(EE8->EE8_SEQUEN) // Agrupamento no Crystal.
   
                  Detail_p->AVG_C04_60 := AllTrim(aDespesas[j][1]+"-"+aDespesas[j][2]) // Descrição da Despesa.
   
                  // ** Calcula o rateio das despesas e retorna array com os valores das colunas a serem impressas.
                  aValores := CalcRateio(aDespesas[j][1],aDespesas[j][3], aDespesas[j][4])
   
                  Detail_p->AVG_C05_20 := AllTrim(Transf(aValores[1],cPictPre + "99")) // Val.Unit.R$.
                  If AllTrim(aDespesas[j][4]) <> "R$"
                     Detail_p->AVG_C05_60 := AllTrim(Transf(round(BuscaTaxa(aDespesas[j][4],dDataBase),4),cPictTx)) // Taxa.
                  Else
                     Detail_p->AVG_C05_60 := AllTrim(Transf(1,cPictTx)) // Taxa. 
                  EndIf
                  Detail_p->AVG_C06_20 := AllTrim(Transf(aValores[2],cPictPre + "99")) // Val.Unit.
                  Detail_p->AVG_C07_20 := AllTrim(Transf(aValores[3],cPictPre)) // Val.Tot. R$
                  Detail_p->AVG_C08_20 := AllTrim(Transf(aValores[4],cPictPre)) // Val.Tot (Moeda do processo).
                  Detail_p->AVG_C09_20 := If(aDespesas[j][1] == "101", aValores[5],;
                                                                       AllTrim(Transf(aValores[5],cPictPre))) // % Fob.
                  // Calculo dos totais. 
                  If aScan(aNaoTotaliza,aDespesas[j][1]) = 0 // Para despesas de CIF e comissões os valores não são totalizados.
                     nSumVlUnReais  += aValores[1]
                     nSumVlUn       += aValores[2]
                     nSumVlTotReais += aValores[3]
                     nSumVlTot      += aValores[4]
                     nSumPerc += If(aDespesas[j][1]<>"101",aValores[5],0)
                  Endif
               Next
   
               // ** Totais
               nSumPerc += 100
               AddDet("CIT",".")
               Detail_p->AVG_C02_10 := AllTrim(EE8->EE8_SEQUEN) // Agrupamento no Crystal.
   
               Detail_p->AVG_C10_20 := AllTrim(Transf(round(nSumVlUnReais,4),cPictPre + "99"))  // Total Val.Unit.R$
               Detail_p->AVG_C01100 := AllTrim(Transf(round(nSumVlUn,4),cPictPre + "99"))       // Total Val.Unit.
               Detail_p->AVG_C02100 := AllTrim(Transf(round(nSumVlTotReais,2),cPictPre)) // Total Val.Tot. R$
               Detail_p->AVG_C03100 := AllTrim(Transf(round(nSumVlTot,2),cPictPre))      // Total Val.Tot (Moeda do processo)
               Detail_p->AVG_C03_10 := AllTrim(Transf(nSumPerc,cPictPre))                // Total % Fob.
   
               // ** Zera os totalizadores.
               nSumVlUnReais := nSumVlUn := nSumVlTotReais := nSumVlTot := nSumPerc := 0
   
               EE8->(DbSkip())
            EndDo
         EndIf
      Else
         EE9->(DbSetOrder(2))
         If EE9->(DbSeek(xFilial("EE9")+EEC->EEC_PREEMB))
   
            SB1->(DbSetOrder(1))
            SA2->(DbSetOrder(1))
            Do While EE9->(!Eof()) .And. EE9->EE9_FILIAL == xFilial("EE9") .And.;
                                         EE9->EE9_PREEMB == EEC->EEC_PREEMB
               nCont++
            
               // Inclui registro no sub-report Custo por Item, para a sessao Det "C" do Relatório.      
               AddDet("CIT",If(nCont=1,"C","."))
   
               // ** Campo utilizado para agrupamento dos detalhes do sub-relatório Custo por Item.
               Detail_p->AVG_C02_10 := AllTrim(EE9->EE9_SEQEMB)
   
               // Produto.
               If SB1->(DbSeek(xFilial("SB1")+EE9->EE9_COD_I))
                  Detail_p->AVG_C02_60 := Memoline(AllTrim(EE9->EE9_COD_I)+Space(1)+;
                                                   AllTrim(SB1->B1_DESC),60,1)
               EndIf
   
               // Fabricante.
               If SA2->(DbSeek(xFilial("SA2")+EE9->EE9_FABR+EE9->EE9_FALOJA))
                  Detail_p->AVG_C03_60 :=  Memoline(AllTrim(SA2->A2_COD)+" - "+;
                                                    AllTrim(SA2->A2_NOME),60,1)
               EndIf
   
               Detail_p->AVG_C01_20 := AllTrim(Transf(EE9->EE9_SLDINI,cPictQtde)) // Quantidade.
               Detail_p->AVG_C02_20 := AllTrim(Transf(EE9->EE9_PSLQUN,cPictPeso))  // Peso Liq. Unitário.
               Detail_p->AVG_C03_20 := AllTrim(Transf(EE9->EE9_POSIPI,AvSx3("EE9_POSIPI",AV_PICTURE))) // N.C.M
               Detail_p->AVG_C04_20 := AllTrim(Transf(EE9->EE9_PSLQTO,cPictPeso)) // Peso liq. Total.
   
               For j:=1 To Len(aDespesas)
                  AddDet("CIT",".")
                  Detail_p->AVG_C02_10 := AllTrim(EE9->EE9_SEQEMB) // Agrupamento no Crystal.

                  Detail_p->AVG_C04_60 := AllTrim(aDespesas[j][1]+"-"+aDespesas[j][2]) // Descrição da Despesa.
   
                  // ** Calcula o rateio das despesas e retorna array com os valores das colunas a serem impressas.
                  aValores := CalcRateio(aDespesas[j][1],aDespesas[j][3],aDespesas[j][4])
   
                  Detail_p->AVG_C05_20 := AllTrim(Transf(aValores[1],cPictPre + "99")) // Val.Unit.R$
                  If AllTrim(aDespesas[j][4]) <> "R$"
                     Detail_p->AVG_C05_60 := AllTrim(Transf(round(BuscaTaxa(aDespesas[j][4],dDataBase),4),cPictTx)) // Taxa.
                  Else
                     Detail_p->AVG_C05_60 := AllTrim(Transf(1,cPictTx)) // Taxa.
                  EndIf
   
                  Detail_p->AVG_C06_20 := AllTrim(Transf(aValores[2],cPictPre + "99")) // Val.Unit.
                  Detail_p->AVG_C07_20 := AllTrim(Transf(aValores[3],cPictPre)) // Val.Tot. R$
                  Detail_p->AVG_C08_20 := AllTrim(Transf(aValores[4],cPictPre)) // Val.Tot (Moeda do processo)
                  Detail_p->AVG_C09_20 := If(aDespesas[j][1] == "101", aValores[5],;
                                                                       AllTrim(Transf(aValores[5],cPictPre))) // % Fob.

                  // Para despesas de CIF e comissões os valores não são totalizados.
                  If aScan(aNaoTotaliza,aDespesas[j][1]) = 0 
                     nSumVlUnReais  += aValores[1]
                     nSumVlUn       += aValores[2]
                     nSumVlTotReais += aValores[3]
                     nSumVlTot      += aValores[4]
                     nSumPerc += If(aDespesas[j][1]<>"101",aValores[5],0)
                  Endif
               Next

               // ** Totais
               nSumPerc += 100 
               AddDet("CIT",".")
               Detail_p->AVG_C02_10 := AllTrim(EE9->EE9_SEQEMB) // Agrupamento no Crystal.
   
               Detail_p->AVG_C10_20 := AllTrim(Transf(round(nSumVlUnReais,4),cPictPre + "99"))  // Total Val.Unit.R$
               Detail_p->AVG_C01100 := AllTrim(Transf(round(nSumVlUn,4),cPictPre + "99"))       // Total Val.Unit.
               Detail_p->AVG_C02100 := AllTrim(Transf(round(nSumVlTotReais,2),cPictPre)) // Total Val.Tot. R$
               Detail_p->AVG_C03100 := AllTrim(Transf(round(nSumVlTot,2),cPictPre))      // Total Val.Tot (Moeda do processo)
               Detail_p->AVG_C03_10 := AllTrim(Transf(nSumPerc,cPictPre))                // Total % Fob.
   
               // ** Zera os totalizadores.
               nSumVlUnReais := nSumVlUn := nSumVlTotReais := nSumVlTot := nSumPerc := 0
      
               EE9->(DbSkip())
            EndDo
         EndIf   
      EndIf
   Endif
   For j:=1 To Len(aTx)
      AddDet("TX",".")
      Detail_p->AVG_C03_10 := AllTrim(aTx[j][1])
      Detail_p->AVG_C01_20 := AllTrim(Transf(aTx[j][2] ,cPictTx))
   Next

End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : CalcRateio().
Parametros  : cTipo  - Tipo da Despesa.
              nValor - Valor da Despesa.
              cMoeda - Moeda da Despesa.
Retorno     : aRet.
Objetivos   : Distribuir os valores da despesa.
Autor       : Jeferson Barros Jr.
Data/Hora   : 02/06/04 - 13:32.
Obs         : aRet por dimensão
                   aRet[1] - Val.Unit.R$.
                       [2] - Val.Unit.
                       [3] - Val.Tot. R$.
                       [4] - Val.Tot (Moeda do processo).
                       [5] - % Fob.
*/
*---------------------------------------------*
Static Function CalcRateio(cTipo,nValor,cMoeda)
*---------------------------------------------*
Local nVl:=0, nFob:=0 , nPerc:=0, nAmountDesp := 0, nTx := 0,;
      nAmountQtde := 0, nPercFob := 0, nRatCab:=0, nRatDet:=0

Local cRateio

Local aRet:=Array(5)

Begin Sequence

   cTipo := AllTrim(Upper(cTipo))
   
   If AllTrim(cMoeda) == "R$ 
      nTx := BuscaTaxa(cMoeda,dDataBase)
   Else
      nTx := 1
   EndIf

   Do Case
      Case cTipo == "101" // Fob
           aRet[1] := round((cAliasIt)->&(cAliasIt+"_PRECOI")*nTx,4)   // Val.Unit.R$.
           aRet[2] := round((cAliasIt)->&(cAliasIt+"_PRECOI"),4)       // Val.Unit.
           aRet[3] := round((cAliasIt)->&(cAliasIt+"_PRCINC")*nTx,2)   // Val.Tot. R$.
           aRet[4] := round((cAliasIt)->&(cAliasIt+"_PRCINC"),2)       // Val.Tot (Moeda do processo).
           aRet[5] := "Base"  // % Fob

      Case cTipo == "102" // Frete
      
           // Rateio (1=Peso Liquido, 2=Peso Bruto, 3=Preco FOB)
           cRateio := AllTrim(Upper(EasyGParam("MV_AVG0021",,"3")))

           Do Case
              Case cRateio == "1" // Peso Liquido.
                 nRatCab := (cAliasHd)->&(cAliasHd+"_PESLIQ")
                 nRatDet := (cAliasIt)->&(cAliasIt+"_PSLQTO")

              Case cRateio == "2" // Peso Bruto.
                 nRatCab := (cAliasHd)->&(cAliasHd+"_PESBRU")
                 nRatDet := (cAliasIt)->&(cAliasIt+"_PSBRTO")

              Case cRateio == "3" // Preço Fob.
                 nRatCab := EECFob(If(cAliasHd=="EE7",OC_PE,OC_EM),.f.)
                 /* JPM - 19/09/05 - Substituído por função genérica
                 nRatCab := ((cAliasHd)->&(cAliasHd+"_TOTPED")+;
                             (cAliasHd)->&(cAliasHd+"_DESCON"))-;
                            ((cAliasHd)->&(cAliasHd+"_FRPREV")+;
                             (cAliasHd)->&(cAliasHd+"_FRPCOM")+;
                             (cAliasHd)->&(cAliasHd+"_SEGPRE")+;
                             (cAliasHd)->&(cAliasHd+"_DESPIN")+;
                             AvGetCpo(cAliasHd+"->"+cAliasHd+"_DESP1")+;
                             AvGetCpo(cAliasHd+"->"+cAliasHd+"_DESP2"))
                 */
                 nRatDet := (cAliasIt)->&(cAliasIt+"_PRCINC")
           EndCase

           nPerc := (nRatDet/nRatCab)

           // ** Calcula proporcional ao total da despesa.
           nAmountDesp := Round((nValor*nPerc),2)

           // Rateia o proporcional da despesa pela qtde para encontrar o valor unitário.
           nAmountQtde := Round((nAmountDesp/(cAliasIt)->&(cAliasIt+"_SLDINI")),4)

           // ** Calcula proporcional da despesa rateada com o total FOB do item.
           
           nPercFob    := Round(;
                          Round(((nAmountDesp/(cAliasIt)->&(cAliasIt+"_PRCINC"))*nTx/;
                                  BuscaTaxa(If(lIsPedido,EE7->EE7_MOEDA,EEC->EEC_MOEDA),dDataBase)),4)*100,2)
           /*
           nPercFob    := Round((((nAmountDesp/(cAliasIt)->&(cAliasIt+"_PRCINC"))*nTx)/;
                          BuscaTaxa(if(lIsPedido,EE7->EE7_MOEDA,EEC->EEC_MOEDA),dDataBase)) *100,3)
           */
           aRet[1] := round(nAmountQtde*nTx,4)   // Val.Unit.R$.
           aRet[2] := nAmountQtde                // Val.Unit.
           aRet[3] := round(nAmountDesp*nTx,2)   // Val.Tot. R$.
           aRet[4] := nAmountDesp                // Val.Tot (Moeda do processo).
           aRet[5] := nPercFob                   // % Fob.

      OtherWise // Demais despesas.
        
           nFob := EECFob(If(cAliasHd=="EE7",OC_PE,OC_EM),.f.)
           /* JPM - 19/09/05 - Substituído por função genérica
           nFob := ((cAliasHd)->&(cAliasHd+"_TOTPED")+;
                    (cAliasHd)->&(cAliasHd+"_DESCON"))-;
                    ((cAliasHd)->&(cAliasHd+"_FRPREV")+;
                    (cAliasHd)->&(cAliasHd+"_FRPCOM")+;
                    (cAliasHd)->&(cAliasHd+"_SEGPRE")+;
                    (cAliasHd)->&(cAliasHd+"_DESPIN")+;
                    AvGetCpo(cAliasHd+"->"+cAliasHd+"_DESP1")+;
                    AvGetCpo(cAliasHd+"->"+cAliasHd+"_DESP2"))
           */
           
           // ** Percentual do item em relação a capa do pedido.
           nPerc := ((cAliasIt)->&(cAliasIt+"_PRCINC")/nFob)

           // ** Calcula proporcional ao total da despesa.
           nAmountDesp := Round((nValor*nPerc),2)

           // Rateia o proporcional da despesa pela qtde para encontrar o valor unitário.
           nAmountQtde := Round((nAmountDesp/(cAliasIt)->&(cAliasIt+"_SLDINI")),4)

           // ** Calcula proporcional da despesa rateada com o total FOB do item.
           nPercFob    := Round(;
                          Round(((nAmountDesp/(cAliasIt)->&(cAliasIt+"_PRCINC"))*nTx/;
                                  BuscaTaxa(If(lIsPedido,EE7->EE7_MOEDA,EEC->EEC_MOEDA),dDataBase)),4)*100,2)

           /*
           nPercFob    := Round( (((nAmountDesp/(cAliasIt)->&(cAliasIt+"_PRCINC"))*nTx);
                          /BuscaTaxa(If(lIsPedido,EE7->EE7_MOEDA,EEC->EEC_MOEDA),dDataBase))*100,3)
           */

           aRet[1] := round(nAmountQtde*nTx,4)   // Val.Unit.R$.
           aRet[2] := nAmountQtde                // Val.Unit.
           aRet[3] := round(nAmountDesp*nTx,2)   // Val.Tot. R$.
           aRet[4] := nAmountDesp                // Val.Tot (Moeda do processo).
           aRet[5] := nPercFob                   // % Fob
   EndCase

End Sequence

Return aRet

/*
Funcao      : AddDet().
Parametros  : cFlagReport -> Flag que será utilizada pelo Crystal para seleção dos registros nos
                             relatório e sub-relatórios.
              cFlagSessao -> Flag que será utilizada pelo Crystal para controle de supress nas
                             sessoes do report principal.                        
Retorno     : .t./.f.
Objetivos   : Incluir registros no arquivo de detalhes (Detail_p).
Autor       : Jeferson Barros Jr.
Data/Hora   : 31/05/04 - 10:42.
Obs         :
*/
*---------------------------------------------*
Static Function AddDet(cFlagReport,cFlagSessao)
*---------------------------------------------*
Local lRet:=.t.

Begin Sequence

   If Empty(cFlagReport) .or. Empty(cFlagSessao)
      lRet:=.f.
      Break
   EndIf

   cFlagReport := AllTrim(Upper(cFlagReport))
   cFlagSessao := AllTrim(Upper(cFlagSessao))

   Detail_p->(DbAppend())
   Detail_p->AVG_FILIAL := xFilial("SY0")
   Detail_p->AVG_SEQREL := cSeqRel
   Detail_p->AVG_CHAVE  := If(lIsPedido,EE7->EE7_PEDIDO,EEC->EEC_PREEMB)

   // ** Flag para controle de reports.
   Detail_p->AVG_C01_10 := cFlagReport

   // ** Flag para controle de sessao.
   Detail_p->AVG_C05_10 := cFlagSessao

End Sequence

Return lRet
//Alcir Alves - 18-10-05 - apresenta status da situação atual para o usuário
****************************************************************************
Static function GrvHist()
****************************************************************************
   // ** Grava as tabelas de histórico. (Header_h/Detail_h)
   ProcRegua((detail_p->(EasyRecCount())+1))
   IncProc("Atualizando arquivos de impressão")	
   Header_h->(dbAppend())
   AvReplace("Header_p","Header_h")

   Detail_p->(DbGoTop())
   Do While Detail_p->(!Eof())
      Detail_h->(DbAppend())
      AvReplace("Detail_p","Detail_h")
      Detail_p->(DbSkip())
      IncProc("Preparando ambiente de impressão")	
   EndDo
return .t.
*------------------------------------------------------------------------------------------------------------------*
* FIM DO PROGRAMA EECPC150                                                                                         *
*------------------------------------------------------------------------------------------------------------------*
