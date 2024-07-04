#INCLUDE "eecpc100.ch"
#Include "EEC.CH"
/*
Programa  : EECPC100.
Objetivo  : Fun��es de Pr�-Calculo.
Autor     : Jeferson Barros Jr.
Data/Hora : 21/09/04 14:29.
Revis�o   : 
Obs       : 
*/

/*
Funcao     : LoadDespesas().
Parametros : cProcesso.
             cFase - Pedido/Embarque.
             lMemoria - .t. - Apura as despesas com base nas works e mem�ria do processo.
                        .f. - Apura as despesas com base nas tableas.
Retorno    : xRet  - Array com as despesas/agentes e totais por tipo de comiss�o.
                   - Nro. de erro encontrado na apura��o de despesas.
Objetivos  : Leitura das depesas a partir da tabela de pr�-calculo.
             Apura��o dos valores das despesas.
Autor      : Jeferson Barros Jr.
Data/Hora  : 21/09/04 14:34.
Obs        : Caso 'cProcesso' n�o tenha sido informado, considera o EE7 j� posicionado.
             xRet (Array) por dimens�o:
                  xRet[1][1][1] - Codigo da despesa.
                         [1][2] - Descri��o da despesa.
                         [1][3] - Valor da despesa.
                         [1][4] - Moeda da despesa.
                      [2][1][1] - Nome Agente Recebedor de Comiss�o.
                         [1][2] - Tipo Comiss�o.
                         [1][3] - Valor Comiss�o.
                      [3][1][1] - Tipo da Comiss�o.
                         [1][2] - Total por tipo da comiss�o.
             xRet (Num�rico)    - Nro Erro para rotina de apura��o de despesas.
*/
*---------------------------------------------*
Function LoadDespesas(cProcesso,cFase,lMemoria)
*---------------------------------------------*
Local aOrd:=SaveOrd({"SWF","SWI","SYB","EE7","EE8","EE9"}),;
      aAgentes:={}, aComissao:={}
Local nSumQtde:=0, nValDesp:=0,nPos:=0, j:=0
Local lPedido := .t., lGravaAgente:=.t.
Local xRet 
Local cMv, i

Static  aCalculando:={}, aCalculado :={}

Private nErroId := 0
Private cAliasHd
Private aAux:={}
Private c_Fase := cFase // JPM - 19/09/05 - cFase Private...
Private aDespDI := X3DIReturn(cFase), aDespesas := {} // JPM

Default cProcesso   := ""
Default lMemoria    := .f.

Begin Sequence
   
   // ** JPM - para considerar todas as despesas poss�veis, inclusive as customizadas.
   For i := 1 To Len(aDespDI)
      cMv := EasyGParam("MV"+SubStr(aDespDI[i,2],4),,"")
      If !Empty(AllTrim(cMv))
         AAdd(aDespesas,{cMv,aDespDI[i,2]})
      EndIf
   Next
   // **
   
   aCalculando := {}
   aCalculado  := {}
   cProcesso   := Upper(AllTrim(cProcesso))
   cFase       := Upper(AllTrim(cFase))
   lPedido     := If(cFase==OC_PE, .t.,.f.)
   cAliasHd    := If(lPedido,"EE7","EEC")

   aAux := {{},{},{}}
   
   If lPedido
      cProcesso := AvKey(cProcesso,"EE7_PEDIDO")
   Else
      cProcesso := AvKey(cProcesso,"EEC_PREEMB")
   EndIf

   // ** Critica a tabela informada na capa do pedido contra o cadastro de pr�-calculo.
   SWF->(DbSetOrder(1))
   If lPedido
      If !lMemoria
         If !SWF->(DbSeek(xFilial("SWF")+EE7->EE7_TABPRE))
            EECMsg(STR0001+Replic(ENTER,2)+; //"Problema:"
                    STR0002+Replic(ENTER,2)+; //"Dados inv�lidos para tratamento de despesas."
                    STR0003+Replic(ENTER,2)+; //"Detalhes:"
                    STR0004+AllTrim(EE7->EE7_TABPRE)+STR0005, STR0006, "MsgStop") //"A tabela '"###"' n�o existe no cadastro de Pr�-Calculo."###"Aten��o"
            Break
         EndIf
      Else
         If !SWF->(DbSeek(xFilial("SWF")+M->EE7_TABPRE))
            EECMsg(STR0001+Replic(ENTER,2)+; //"Problema:"
                    STR0002+Replic(ENTER,2)+; //"Dados inv�lidos para tratamento de despesas."
                    STR0003+Replic(ENTER,2)+; //"Detalhes:"
                    STR0004+AllTrim(M->EE7_TABPRE)+STR0005, STR0006, "MsgStop") //"A tabela '"###"' n�o existe no cadastro de Pr�-Calculo."###"Aten��o"
            Break
         EndIf
      EndIf
   Else
      If !lMemoria
         If !SWF->(DbSeek(xFilial("SWF")+EXL->EXL_TABPRE))
            EECMsg(STR0001+Replic(ENTER,2)+; //"Problema:"
                    STR0002+Replic(ENTER,2)+; //"Dados inv�lidos para tratamento de despesas."
                    STR0003+Replic(ENTER,2)+; //"Detalhes:"
                    STR0004+AllTrim(EXL->EXL_TABPRE)+STR0005, STR0006, "MsgStop") //"A tabela '"###"' n�o existe no cadastro de Pr�-Calculo."###"Aten��o"
            Break
         EndIf
      Else
         If !SWF->(DbSeek(xFilial("SWF")+M->EXL_TABPRE))
            EECMsg(STR0001+Replic(ENTER,2)+; //"Problema:"
                    STR0002+Replic(ENTER,2)+; //"Dados inv�lidos para tratamento de despesas."
                    STR0003+Replic(ENTER,2)+; //"Detalhes:"
                    STR0004+AllTrim(M->EXL_TABPRE)+STR0005, STR0006, "MsgStop") //"A tabela '"###"' n�o existe no cadastro de Pr�-Calculo."###"Aten��o"
            Break
         EndIf
      EndIf
   EndIf

   SYB->(DbSetOrder(1))
   SWI->(DbSetOrder(1))

   If !SWI->(DbSeek(xFilial("SWI")+SWF->WF_TAB))
      Break
   EndIf

   Do While SWI->(!Eof()) .And. SWI->WI_FILIAL == xFilial("SWI") .And.;
                                SWI->WI_TAB    == SWF->WF_TAB

      If !SYB->(DbSeek(xFilial("SYB")+SWI->WI_DESP))
         SWI->(DbSkip())
         Loop
      EndIf

      /* Para as despesas do tipo 'Quantidade' � necess�rio que a quantidade de cada
         item seja totalizada para utiliza��o no processo de apura��o do valor da despesa */
      If SYB->YB_IDVL == "3"
         If nSumQtde = 0 // Totaliza apenas uma vez.
            If lPedido
               If !lMemoria
                  EE8->(DbSetOrder(1))
                  If EE8->(DbSeek(xFilial("EE8")+cProcesso))
                     Do While EE8->(!Eof()) .And. EE8->EE8_FILIAL == xFilial("EE8") .And.;
                                                  EE8->EE8_PEDIDO == cProcesso
                        nSumQtde += EE8->EE8_SLDINI // Totaliza a quantidade.
                        EE8->(DbSkip())
                     EndDo
                  EndIf
               Else
                  WorkIt->(DbGoTop())
                  Do While WorkIt->(!Eof())
                     nSumQtde += WorkIt->EE8_SLDINI
                     WorkIt->(DbSkip())
                  EndDo
               EndIf
            Else
               If !lMemoria
                  EE9->(DbSetOrder(2))
                  If EE9->(DbSeek(xFilial("EE9")+cProcesso))
                     Do While EE9->(!Eof()) .And. EE9->EE9_FILIAL == xFilial("EE9") .And.;
                                                  EE9->EE9_PREEMB == cProcesso
                        nSumQtde += EE9->EE9_SLDINI // Totaliza a quantidade.
                        EE9->(DbSkip())
                     EndDo
                  EndIf
               Else
                  WorkIp->(DbGoTop())
                  Do While WorkIp->(!Eof())
                     If !Empty(WorkIp->WP_FLAG)
                        nSumQtde += WorkIp->EE9_SLDINI
                     EndIf
                     WorkIp->(DbSkip())
                  EndDo               
               EndIf
            EndIf
         EndIf
      EndIf

      // ** Apura o valor da despesa. - Par�metros de CalcDesp (cCod,cTipo,nValor,nPercentual,cDespBase,nSumQtde,lPedido)
      nValDesp := CalcDesp(SWI->WI_DESP,;
                           SWI->WI_IDVL,; //FRS 28/01/10 - Alterado para considerar o tipo da tabela de pr�-calculo e n�o da tabela de despesas(SYB->YB_IDVL,;)
                           SWI->WI_VALOR,;
                           If (SWI->WI_DESP=="104",100,SWI->WI_PERCAPL),;
                           SWI->WI_DESPBAS,;
                           nSumQtde,lPedido,lMemoria)

      // ** Flag de indica��o de erro na rotina de c�lculo de despesa (CalcDesp)
      If nErroId <> 0
         Break
      EndIf

      If nValDesp <> 0
         aAdd(aAux[1],{SWI->WI_DESP,;
                       AllTrim(SYB->YB_DESCR),;
                       nValDesp,;
                       SWI->WI_MOEDA})
      EndIf
 
      SWI->(DbSkip())
   EndDo
   
   /* Tratamentos para impress�o do(s) agente(s) recebedor(es) de comiss�o cadastrados no processo.
      Obs: Para a rotina nova de comiss�o, considera as informa��es do EEB.
           Para a rotina antiga de comiss�o, considera as informa��es da
           capa do processo. */

   nFob := EECFob(c_Fase,lMemoria) // JPM - C�lculo do Total Fob do pedido/embarque
   
   If !lMemoria
      
      EEB->(DbSetOrder(1))
      If EEB->(DbSeek(xFilial("EEB")+AvKey(cProcesso,"EEB_PEDIDO")+If(lPedido,OC_PE,OC_EM)))
         Do While EEB->(!Eof()) .And. EEB->EEB_FILIAL == xFilial("EEB") .And.;
                                      EEB->EEB_PEDIDO == AvKey(cProcesso,"EEB_PEDIDO") .And.;
                                      EEB->EEB_OCORRE == If(lPedido,OC_PE,OC_EM)

            //  S� considera os agentes recebedores de comissao.
            If SubStr(EEB->EEB_TIPOAG,1,1) <> CD_AGC
               EEB->(DbSkip())
               Loop
            EndIf

            nPos := aScan(aAgentes,{|x| x[1] = AllTrim(EEB->EEB_NOME)})

            If EECFlags("COMISSAO")
               If nPos = 0
                  aAdd(aAgentes,{AllTrim(EEB->EEB_NOME),EEB->EEB_TIPCOM,EEB->EEB_TOTCOM})
               Else
                  If aAgentes[nPos][2] == EEB->EEB_TIPCOM
                     aAgentes[nPos][3] += EEB->EEB_TOTCOM
                  Else
                     aAdd(aAgentes,{AllTrim(EEB->EEB_NOME),EEB->EEB_TIPCOM,EEB->EEB_TOTCOM})
                  EndIf
               EndIf
            Else
               If lGravaAgente
                  /* JPM - 19/09/05 - Substitu�do por fun��o gen�rica, e colocado fora do loop, s� precisa ser calculado uma vez.
                  nFob := ((cAliasHd)->&(cAliasHd+"_TOTPED")+;
                           (cAliasHd)->&(cAliasHd+"_DESCON"))-;
                          ((cAliasHd)->&(cAliasHd+"_FRPREV")+;
                           (cAliasHd)->&(cAliasHd+"_FRPCOM")+;
                           (cAliasHd)->&(cAliasHd+"_SEGPRE")+;
                           (cAliasHd)->&(cAliasHd+"_DESPIN")+;
                           AvGetCpo(cAliasHd+"->"+cAliasHd+"_DESP1")+;
                           AvGetCpo(cAliasHd+"->"+cAliasHd+"_DESP2"))
                  */
                  
                  Do Case
                     Case (cAliasHd)->&(cAliasHd+"_TIPCVL") = "1" // Percentual.
                        nValCom := Round((EEB->EEB_TXCOMI/100)*nFob,3)

                     Case (cAliasHd)->&(cAliasHd+"_TIPCVL") = "2" // Valor Fixo.
                        nValCom := EEB->EEB_TXCOMI

                     Case (cAliasHd)->&(cAliasHd+"_TIPCVL") = "3" // Percentual Por item.
                        nValCom := Round(((cAliasHd)->&(cAliasHd+"_VALCOM")/100)*nFob,3)
                        lGravaAgente :=.f.
                  Endcase

                  If nPos = 0
                     aAdd(aAgentes,{AllTrim(EEB->EEB_NOME),(cAliasHd)->&(cAliasHd+"_TIPCOM"),nValCom})
                  Else
                     aAgentes[nPos][3] += nValCom
                  EndIf
               EndIf
            EndIf

            EEB->(DbSkip())
         EndDo
      EndIf
   Else
      // Le os dados da work e da memoria.
   
      WorkAg->(DbGoTop())
      Do While WorkAg->(!Eof())
      
         //  S� considera os agentes recebedores de comissao.
         If SubStr(WorkAg->EEB_TIPOAG,1,1) <> CD_AGC
            WorkAg->(DbSkip())
            Loop
         EndIf

         nPos := aScan(aAgentes,{|x| x[1] = AllTrim(WorkAg->EEB_NOME)})

         If EECFlags("COMISSAO")
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
            If lGravaAgente
               /* JPM - 19/09/05 - Substitu�do por fun��o gen�rica, e colocado fora do loop, pois s� precisa ser calculado uma vez.
               nFob := (M->&(cAliasHd+"_TOTPED")+;
                        M->&(cAliasHd+"_DESCON"))-;
                       (M->&(cAliasHd+"_FRPREV")+;
                        M->&(cAliasHd+"_FRPCOM")+;
                        M->&(cAliasHd+"_SEGPRE")+;
                        M->&(cAliasHd+"_DESPIN")+;
                        AvGetCpo("M->"+cAliasHd+"_DESP1")+;
                        AvGetCpo("M->"+cAliasHd+"_DESP2"))
               */
               Do Case
                  Case M->&(cAliasHd+"_TIPCVL") = "1" // Percentual.
                       nValCom := Round((WorkAg->EEB_TXCOMI/100)*nFob,3)
                  Case M->&(cAliasHd+"_TIPCVL") = "2" // Valor Fixo.
                       nValCom := WorkAg->EEB_TXCOMI
                  Case M->&(cAliasHd+"_TIPCVL") = "3" // Percentual Por item.
                       nValCom := Round((M->&(cAliasHd+"_VALCOM")/100)*nFob,3)
                       lGravaAgente :=.f.
               Endcase

               If nPos = 0
                  aAdd(aAgentes,{AllTrim(WorkAg->EEB_NOME),M->&(cAliasHd+"_TIPCOM"),nValCom})
               Else
                  aAgentes[nPos][3] += nValCom
               EndIf
            EndIf
         EndIf

         WorkAg->(DbSkip())
      EndDo
   EndIf

   If Len(aAgentes) > 0
      For j:=1 To Len(aAgentes)
         /* Controle para calculo do total de comiss�o por tipo de comissao.
            aComissao por dimens�o:
                      aComissao[1][1] -> Tipo da comiss�o.
                               [1][2] -> Total da comissao para o tipo. */

         nPosComis := aScan(aComissao,{|x| x[1] == AllTrim(aAgentes[j][2])})

         If nPosComis = 0
            aAdd(aComissao,{AllTrim(aAgentes[j][2]),aAgentes[j][3]})
         Else
            aComissao[nPosComis][2] += aAgentes[j][3]
         EndIf
      Next
   EndIf

   If Len(aComissao) > 0
      For j:=1 To Len(aComissao)
         Do Case
            Case aComissao[j][1] == "1"
                 If !lMemoria
                    aAdd(aAux[1],{"120",;
                                  "COMISSAO (A REMETER)",; 
                                  aComissao[j][2],;
                                  If(lPedido,EE7->EE7_MOEDA,EEC->EEC_MOEDA)})
                 Else
                    aAdd(aAux[1],{"120",;
                                  "COMISSAO (A REMETER)",; 
                                  aComissao[j][2],;
                                  If(lPedido,M->EE7_MOEDA,M->EEC_MOEDA)})
                 EndIf

            Case aComissao[j][1] == "2"
                 If !lMemoria
                    aAdd(aAux[1],{"121",;
                                  "COMISSAO (CONTA GRAFICA)",;
                                  aComissao[j][2],;
                                  If(lPedido,EE7->EE7_MOEDA,EEC->EEC_MOEDA)})
                 Else
                    aAdd(aAux[1],{"121",;
                                  "COMISSAO (CONTA GRAFICA)",;
                                  aComissao[j][2],;
                                  If(lPedido,M->EE7_MOEDA,M->EEC_MOEDA)})
                 EndIf

            Case aComissao[j][1] == "3"
                 If !lMemoria
                    aAdd(aAux[1],{"122",;
                                  "COMISSAO (A DEDUZIR DA FATURA)",;
                                  aComissao[j][2],;
                                  If(lPedido,EE7->EE7_MOEDA,EEC->EEC_MOEDA)})
                 Else
                    aAdd(aAux[1],{"122",;
                                  "COMISSAO (A DEDUZIR DA FATURA)",;
                                  aComissao[j][2],;
                                  If(lPedido,M->EE7_MOEDA,M->EEC_MOEDA)})
                 EndIf
         EndCase
      Next
   EndIf

   If Len(aAgentes) > 0
      aAux[2] := aAgentes
      aAux[3] := aComissao
   EndIf

End Sequence

If lMemoria
   If lPedido
      WorkIt->(DbGoTop())
   Else
      WorkIp->(DbGoTop())
   EndIf
EndIf

If nErroId <> 0
   xRet := nErroId
Else
   If (Len(aAux[1]) = 0 .And. Len(aAux[2]) = 0 .And. Len(aAux[3]) = 0)
      aAux := {{"","",0,""},{"","",0},{"",0}}
   EndIf

   /* Permite a altera��o customizada dos valores apurados
      para todas as despesas da tabela de pr�-c�lculo. */
   If EasyEntryPoint("eecpc100")
      ExecBlock("eecpc100",.f.,.f.,{"PE_LOADDESP",lPedido,lMemoria})
   EndIf

   xRet := aAux
EndIf

RestOrd(aOrd)

Return xRet

/*
Funcao     : CalcDesp().
Parametros  : cCod        - C�digo da Despesa.
              cTipo       - Tipo da Despesa.
              nValor      - Valor da Despesa.
              nPercentual - Percentual da Despesa.
              cDespBase   - Despesa Base.
              nSumQtde    - Somat�ria das quantidades de todos os itens do processo.
              lPedido     - .t. - Pedido.
                            .f. - Embarque.
Retorno     : nVal - Total da despesa.
Objetivos   : Auxiliar a fun��o LoadDespesas() na apura��o do valor da despesa.
Autor       : Jeferson Barros Jr.
Data/Hora   : 01/06/04 10:43.
Obs         : 
*/
*-----------------------------------------------------------------------------------------*
Static Function CalcDesp(cCod,cTipo,nValor,nPercentual,cDespBase,nSumQtde,lPedido,lMemoria)
*-----------------------------------------------------------------------------------------*
Local aOrd:=SaveOrd({"SYR","SWI","SYB"}), aCmp:={}, aDespBase:={}
Local lCalcPorContainer := .f.
Local nAux:=0, j:=0, nPrc1:=0, nPrc2:=0,;
      nPos:=0, nRecSWI:=0, nRecSYB:=0, nX := 0,;
      nDe:=0, nAte:=0
Local cCodDesp, cMoedaAtu
Local lRetBlock := .f. // Define se o ponto de entrada calculou o valor da despesa.

Private cAlias := If(lMemoria,"M",cAliasHD) //JPM
Private nRet:=0, cCodigo := cCod

Default cCod        := ""
Default cTipo       := ""
Default nValor      := 0
Default nPercentual := 0
Default cDespBase   := ""
Default nSumQtde    := 0
Default lPedido     := .t.
Default lMemoria    := .f.

Begin Sequence

   cCod  := Upper(AllTrim(cCod))
   cTipo := Upper(AllTrim(cTipo))

   nX := aScan(aCalculado,{|x| x[1] == cCod})
   If nX > 0
      nRet := aCalculado[nX][2]
      Break
   EndIf
   
   If EasyEntryPoint("eecpc100") // JPM - 19/09/05 - Ponto de entrada no c�lculo de cada despesa.
      lRetBlock := ExecBlock("eecpc100",.f.,.f.,{"PE_CALCDESP",lPedido,lMemoria})
      If ValType(lRetBlock) <> "L"
         lRetBlock := .f.
      EndIf
   EndIf
   
   Do Case
      Case lRetBlock
           // Se o ponto de entrada retorna .t., ent�o a despesas j� est� calculada, n�o faz mais tratamentos.
           
      Case (cCod == "101") // A Despesa � FOB?
           /* Quando a despesa � fob, o valor da despesa � o mesmo valor
              fob do processo*/
           
           nRet := EECFob(c_Fase,lMemoria)
           /* JPM - 19/09/05 - Substitu�do por fun��o gen�rica.
           If !lMemoria
              nRet := ((cAliasHd)->&(cAliasHd+"_TOTPED")+;
                       (cAliasHd)->&(cAliasHd+"_DESCON"))-;
                       ((cAliasHd)->&(cAliasHd+"_FRPREV")+;
                        (cAliasHd)->&(cAliasHd+"_FRPCOM")+;
                        (cAliasHd)->&(cAliasHd+"_SEGPRE")+;
                        (cAliasHd)->&(cAliasHd+"_DESPIN")+;
                        AvGetCpo(cAliasHd+"->"+cAliasHd+"_DESP1")+;
                        AvGetCpo(cAliasHd+"->"+cAliasHd+"_DESP2"))
           Else
              nRet := ( M->&(cAliasHd+"_TOTPED")+;
                        M->&(cAliasHd+"_DESCON"))-;
                       (M->&(cAliasHd+"_FRPREV")+;
                        M->&(cAliasHd+"_FRPCOM")+;
                        M->&(cAliasHd+"_SEGPRE")+;
                        M->&(cAliasHd+"_DESPIN")+;
                        AvGetCpo("M->"+cAliasHd+"_DESP1")+;
                        AvGetCpo("M->"+cAliasHd+"_DESP2"))
           EndIf
           */
           
      Case (cCod == "102") // A Despesa � frete?
            
            /* Quando a despesa � de frete, os c�lculos obedecem as seguintes regras:
               1 - O valor da despesa � calculado a partir das quantidades de containers (informada
                   na capa do pedido) contra os valores de frete por tipo de container (informado no 
                   cadastro de via de transporte).
               2 - Caso a quantidade de containers n�o tenha sido informada, o valor de frete � calculado
                   a partir do peso total (capa do pedido) e cubage (capa do pedido) de acordo com as 
                   faixas de valores (cadastro de despesas). */

            // ** Considera o valor de max e min da despesa principal.
            nDe  := SWI->WI_VAL_MIN
            nAte := SWI->WI_VAL_MAX
           
            // ** Verifica se o c�lculo do frete ser� realizado com base nas qtdes de containers.
            If lPedido            
               If !lMemoria
                  lCalcPorContainer := (!Empty(EE7->EE7_QTD20) .Or. !Empty(EE7->EE7_QTD40) .Or.;
                                        !Empty(EE7->EE7_QTD40H))
               
               Else
                  lCalcPorContainer := (!Empty(M->EE7_QTD20) .Or. !Empty(M->EE7_QTD40) .Or.;
                                        !Empty(M->EE7_QTD40H))
               EndIf
            Else
               If !lMemoria
                  lCalcPorContainer := (!Empty(EXL->EXL_QTD20) .Or. !Empty(EXL->EXL_QTD40) .Or.;
                                        !Empty(EXL->EXL_QTD40H))
               Else
                  lCalcPorContainer := (!Empty(M->EXL_QTD20) .Or. !Empty(M->EXL_QTD40) .Or.;
                                        !Empty(M->EXL_QTD40H))
               EndIf
            EndIf
                        
            nRet := CalcFrete(lPedido,lMemoria,lCalcPorContainer)
            
            /* Verifica se o valor calculado confere com o range do cadastro de 
               despesas ou da tabela de pr�-calculo */
            If (nDe > 0) .And. (nDe > nRet)
               nRet := nDe
            ElseIf (nAte > 0) .And. (nAte < nRet)
               nRet := nAte
            EndIf

      OtherWise

         /* Para as despesas que n�o s�o fob nem frete, seguem 
            as regras abaixo: */
         Do Case
            Case cTipo == "1" // Valor
                /* - Para as despesas com o tipo 'Valor', considera diretamente o 
                     valor fixo informado, n�o realizando nenhum tipo de c�lculo. */

                nRet := nValor

            Case cTipo == "2" // Percentual
                /* - Para as despesas do tipo 'Percentual', calcula percentual sobre o
                     total das despesas base;
                   - O valor apurado deve estar no range (valor m�nimo/valor m�ximo) de 
                     acordo com o cadastro de despesas. */

                nRecSWI := SWI->(RecNo())
                nRecSYB := SYB->(RecNo())

                // ** Considera o valor de max e min da despesa principal.
                nDe  := SWI->WI_VAL_MIN
                nAte := SWI->WI_VAL_MAX

                // ** Considera o valor de max e min da despesa principal.
                cMoedaAtu := SWI->WI_MOEDA

                SWI->(DbSetOrder(1))
                SYB->(DbSetOrder(1))

                aAdd(aCalculando,cCod)

                // ** Monta array com a(s) despesa(s) base.
                nPos :=1
                //For j:=1 To 3 - JPM - 20/09/05
                For j:=1 To Eval({|x| (x/3)-x%3 },AvSx3("YB_DESPBAS",AV_TAMANHO))
                   cCodDesp := SubStr(cDespBase,nPos,3)
                   If !Empty(cCodDesp)
                      aAdd(aDespBase,cCodDesp)
                   EndIf
                   nPos+=3
                Next

                If Len(aDespBase) > 0
                   For j:=1 To Len(aDespBase)

                      If aScan(aCalculando,aDespBase[j]) > 0
                         aAdd(aCalculando,aDespBase[j])
                         nErroId := -1 // Erro de refer�ncia circular. (Verifique funcao GetMsgError())
                         Break
                      EndIf

                      // ** Procura por prioridade no SWI (itens da tabela de pr�-c�lculo)
                      If SWI->(DbSeek(xFilial("SWI")+SWF->WF_TAB+AvKey(aDespBase[j],"WI_DESP")))

                         /* by jbj - 29/12/04 - O sistema dever� converter a moeda da despesa atual
                                                contra a despesa principal. */
                         If SWI->WI_MOEDA <> cMoedaAtu

                            nTx1 := BuscaTaxa(SWI->WI_MOEDA,dDataBase,,.f.)
                            nTx1 := If(nTx1=0,1,nTx1)

                            If AllTrim(cMoedaAtu) == "R$"
                               nTx2 := 1
                            Else   
                               nTx2 := BuscaTaxa(cMoedaAtu    ,dDataBase,,.f.)
                            EndIf
                                                       
                            nValDesp := CalcDesp(SWI->WI_DESP,;
                                                 SWI->WI_IDVL,;
                                                 SWI->WI_VALOR,;
                                                 SWI->WI_PERCAPL,;
                                                 SWI->WI_DESPBAS,;
                                                 nSumQtde,;
                                                 lPedido,;
                                                 lMemoria)

                            nAux += ((nValDesp*nTx1)/nTx2)
                         Else

                            nAux +=  CalcDesp(SWI->WI_DESP,;
                                              SWI->WI_IDVL,;
                                              SWI->WI_VALOR,;
                                              SWI->WI_PERCAPL,;
                                              SWI->WI_DESPBAS,;
                                              nSumQtde,;
                                              lPedido,;
                                              lMemoria)
                         EndIf

                         nPos := aScan(aCalculando,SWI->WI_DESP)

                      ElseIf SYB->(DbSeek(xFilial("SYB")+AvKey(aDespBase[j],"YB_DESP")))


                         /* by jbj - 29/12/04 - O sistema dever� converter a moeda da despesa atual
                                                contra a despesa principal. */
                         If SYB->YB_MOEDA <> cMoedaAtu

                            nTx1 := BuscaTaxa(SYB->YB_MOEDA,dDataBase,,.f.)
                            nTx1 := If(nTx1=0,1,nTx1)

                            If AllTrim(cMoedaAtu) == "R$"
                               nTx2 := 1
                            Else   
                               nTx2 := BuscaTaxa(cMoedaAtu    ,dDataBase,,.f.)
                            EndIf
                           
                            nValDesp := CalcDesp(SYB->YB_DESP,;
                                                 SYB->YB_IDVL,;
                                                 SYB->YB_VALOR,;
                                                 SWI->WI_PERCAPL,;
                                                 SYB->YB_DESPBAS,;
                                                 nSumQtde,;
                                                 lPedido,;
                                                 lMemoria)

                            nAux += ((nValDesp*nTx1)/nTx2)
                         Else
                            nAux +=  CalcDesp(SYB->YB_DESP,;
                                              SYB->YB_IDVL,;
                                              SYB->YB_VALOR,;
                                              SWI->WI_PERCAPL,;
                                              SYB->YB_DESPBAS,;
                                              nSumQtde,;
                                              lPedido,;
                                              lMemoria)
                         EndIf

                         nPos := aScan(aCalculando,SYB->YB_DESP)
                      Else
                         nErroId := -2 // Despesa n�o cadastrada.
                         Break
                      EndIf

                      If nPos > 0 .And. nErroId = 0
                         aDel(aCalculando,nPos)
                         aSize(aCalculando,Len(aCalculando)-1)
                      EndIf
                   Next

                   nRet := Round((nAux*(nPercentual/100)),2)

                   /* Verifica se o valor calculado confere com o range do cadastro de 
                      despesas ou da tabela de pr�-calculo */
                   If (nDe > 0) .And. (nDe > nRet)
                      nRet := nDe
                   ElseIf (nAte > 0) .And. (nAte < nRet)
                      nRet := nAte
                   EndIf

                   nPos := aScan(aCalculando,cCod)
                   If nPos > 0 .And. nErroId = 0
                      aDel(aCalculando,nPos)
                      aSize(aCalculando,Len(aCalculando)-1)
                   EndIf
                EndIf

                SWI->(DbGoTo(nRecSWI))
                SYB->(DbGoTo(nRecSYB))

            Case cTipo == "3" // Quantidade
                /* - Para as despesas do tipo 'Quantidade', calcula o valor com base
                     na somat�ria da quantidade de todos os itens do pedido, n�o tratando
                     os casos de processos com protudos diferentes. */

                If nSumQtde > 0
                   nRet := (nValor * nSumQtde)
                EndIf

            Case cTipo == "4" // Peso.
                /* - Para as despesas do tipo 'Peso', calculo o valor com base no
                     total do peso liquido do processo (EE7_PESLIQ), de acordo com
                     as faixas de valores cadastrada no cadastro de despesas. */

                nRet := TabPes((cAliasHd)->&(cAliasHd+"_PESLIQ"))
         EndCase  
   EndCase

   aAdd(aCalculado,{cCod,nRet})

End Sequence

Return nRet

/*
Funcao      : TabPes(nPeso)
Parametros  : nPeso.
Retorno     : Valor a ser cobrado de acordo com os ranges.
Objetivos   : aApurar valor a ser cobrado.
Autor       : Jeferson Barros Jr.
Data/Hora   : 21/09/04 - 15:43.
Obs         :
*/
*---------------------------*
Static Function TabPes(nPeso)
*---------------------------*
Local nRetorno := 0

Begin Sequence

   Do Case
      Case SWI->WI_KILO1 >= nPeso
           nRetorno := nPeso * SWI->WI_VALOR1
      Case SWI->WI_KILO2 >= nPeso
           nRetorno := nPeso * SWI->WI_VALOR2
      Case SWI->WI_KILO3 >= nPeso
           nRetorno := nPeso * SWI->WI_VALOR3
      Case SWI->WI_KILO4 >= nPeso
           nRetorno := nPeso * SWI->WI_VALOR4
      Case SWI->WI_KILO5 >= nPeso
           nRetorno := nPeso * SWI->WI_VALOR5
      OtherWise // SWI->WI_KILO6
           nRetorno := nPeso * SWI->WI_VALOR6
   EndCase

End Sequence

Return nRetorno

/*
Funcao      : GetMsgError(nIdErro)
Parametros  : nIdErro - Nro de identifica��o do erro.
Retorno     : cMsg - Descri��o do Erro.
Objetivos   : Retornar msg de erro de acordo com identifica��o (Par�metro nIdErro)
Autor       : Jeferson Barros Jr.
Data/Hora   : 02/06/04 - 08:26.
Obs         :
*/
*---------------------------*
Function GetMsgError(nIdErro)
*---------------------------*
Local cMsg := "", j:=0, nSpace:=0

Default nIdErro := 0

Begin Sequence

   If nIdErro = 0
      Break
   EndIf

   Do Case
      Case nErro = -1 // Refer�ncia Circular.
           cMsg += STR0007+Replic(ENTER,2) //"Erro na apura��o do(s) valor(es) da(s) despesa(s)."
           cMsg += STR0008+Replic(ENTER,2) //"Descri��o: Refer�ncia circular entre a(s) despesa(s) base(s)."
           cMsg += STR0009+Replic(ENTER,2) //"Detalhes: "
           cMsg += STR0010+ENTER //"No esquema abaixo a despesa inicial est� no n�vel mais alto, no n�vel mais "
           cMsg += STR0011+Replic(ENTER,2) //"baixo s�o as despesas dependentes"

           For j:=1 To Len(aCalculando)
              If j = 1
                 nSpace := 10
                 cMsg += Space(nSpace)
              EndIf
              cMsg += AllTrim(aCalculando[j])+ENTER
              
              If j < Len(aCalculando)
                 cMsg += Space(nSpace+1)+"|"+ENTER
                 cMsg += Space(nSpace+1)+"+-> "
              EndIf
              nSpace += 5
           Next

      Case nErro = -2
           cMsg += STR0007+Replic(ENTER,2) //"Erro na apura��o do(s) valor(es) da(s) despesa(s)."
           cMsg += STR0012+Replic(ENTER,2) //"Descri��o: Despesa n�o cadastrada."
           cMsg += STR0009+Replic(ENTER,2) //"Detalhes: "
           cMsg += STR0013+aCalculando[Len(aCalculando)]+STR0014+ENTER //"A despesa '"###"' n�o foi encontrada na "
           cMsg += STR0015 //"tabela de pr�-c�lculo e na tabela de despesas."
          
   EndCase

End Sequence

Return cMsg

/*
Funcao      : CalcFrete
Parametros  : lPedido -  .T. - Fase Pedido
                         .F. - Fase Embarque
              lMem�ria - .T. - M�moria
                         .F. - Arquivo
              lCalcPorContainer - .T. - C�culo por Container
                                  .F. - C�lculo por Cubagem/Peso Liq.           
                          
Retorno     : Valor do Frete
Objetivos   : Calcula o Valor do Frete.
              Esse c�lculo � feito de 2 formas:
              1) Por Container -    Quando os campos de Container(CON20,CON40 e CON40H)
                                    est�o preenchidos.
              2) Por Peso/Cubagem - Quando os campos de Container n�o est�o preenchidos.                     
Autor       : Eduardo C. Romanini
Data/Hora   : 24/07/2006 - 14:30
Obs         :
*/
Function CalcFrete(lPedido,lMemoria,lCalcPorContainer)

Local nRet  := 0
Local nInc  := 0

Local nTot20      := 0
Local nTot40      := 0
Local nTot40HC    := 0
Local nTotalFrete := 0  

Local nPrcPeso  := 0
Local nPrcCub   := 0
Local nPrcUsado := 0

Local cAlias := If(lPedido,"EE7","EEC")

Local aTaxas := {}

Begin Sequence
   
   /*
      C�lculo por Container.
      Ser�o lidas todas taxas de todos os agentes e selecionada a melhor(Mais Barata).
      Ap�s isso o seguinte c�culo � realizado:
      Vl. Desp := (Qtde 20 * Vl. Frete 20) + (Qtde 40 * Vl. Frete 40) + (Qtde 40HC * Vl. Frete 40HC)
   */ 
   

   If lCalcPorContainer
      SYR->(DbSetOrder(1))
      
      /*
        Pesquisa Origem/Destino
      */
      If !lMemoria               
         If !SYR->(dbSeek(xFilial("SYR")+(cAlias)->&(cAlias+"_VIA")+;
                                         (cAlias)->&(cAlias+"_ORIGEM")+;
                                         (cAlias)->&(cAlias+"_DEST")+;
                                         (cAlias)->&(cAlias+"_TIPTRA")))
            nRet := 0
            Break
         EndIf   
      Else      
         If !SYR->(dbSeek(xFilial("SYR")+M->&(cAlias+"_VIA")+;
                                         M->&(cAlias+"_ORIGEM")+;
                                         M->&(cAlias+"_DEST")+;
                                         M->&(cAlias+"_TIPTRA")))
            nRet := 0
            Break
         EndIf   
      EndIf
         
      /*
        Pesquisa Agentes
      */
      EX3->(DbSetOrder(1))
      If EX3->(dbSeek(xFilial("EX3")+SYR->YR_VIA+;
                                     SYR->YR_ORIGEM+;
                                     SYR->YR_DESTINO))
                                                    
         While EX3->(!EOF() .And. EX3->EX3_FILIAL == xFilial("EX3")  .And.;
                                  EX3->EX3_VIA    == SYR->YR_VIA    .And.;
                                  EX3->EX3_ORIGEM == SYR->YR_ORIGEM .And.;                    
                                  EX3->EX3_DEST   == SYR->YR_DESTINO)
               
            /*
              Pesquisa Taxa por Container
            */            
            EX4->(DbSetOrder(1))
            If EX4->(DbSeek(xFilial("EX4")+EX3->EX3_VIA+;
                                           EX3->EX3_ORIGEM+;
                                           EX3->EX3_DEST+;
                                           EX3->EX3_AGENTE))
                     
                           
               While EX4->(!EOF() .And. EX4->EX4_FILIAL == xFilial("EX4")  .And.;
                                        EX4->EX4_VIA    == EX3->EX3_VIA    .And.;
                                        EX4->EX4_ORIGEM == EX3->EX3_ORIGEM .And.;                    
                                        EX4->EX4_DEST   == EX3->EX3_DEST   .And.;
                                        EX4->EX4_AGENTE == EX3->EX3_AGENTE)
                     
                                 
                  If Left(EX4->EX4_TIPO,1) == "1" //Frete
                        
                     If lPedido
                        If !lMemoria
                           nTot20   := EE7->EE7_QTD20  * EX4->EX4_CON20
                           nTot40   := EE7->EE7_QTD40  * EX4->EX4_CON40
                           nTot40HC := EE7->EE7_QTD40H * EX4->EX4_CON40H
                        Else
                           nTot20   := M->EE7_QTD20    * EX4->EX4_CON20
                           nTot40   := M->EE7_QTD40    * EX4->EX4_CON40
                           nTot40HC := M->EE7_QTD40H   * EX4->EX4_CON40H
                        EndIf
                     Else
                        If !lMemoria
                           nTot20   := EXL->EXL_QTD20  * EX4->EX4_CON20
                           nTot40   := EXL->EXL_QTD40  * EX4->EX4_CON40
                           nTot40HC := EXL->EXL_QTD40H * EX4->EX4_CON40H
                        Else
                           nTot20   := M->EXL_QTD20    * EX4->EX4_CON20
                           nTot40   := M->EXL_QTD40    * EX4->EX4_CON40
                           nTot40HC := M->EXL_QTD40H   * EX4->EX4_CON40H
                        EndIf 
                     EndIf

                     nTotalFrete := nTot20 + nTot40 + nTot40HC
                        
                     aAdd(aTaxas,{EX4->EX4_AGENTE,nTotalFrete})
                     
                  EndIf                                 
                     
                  EX4->(DbSkip())
               EndDo
            EndIf
                    
            EX3->(DbSkip())
         EndDo
      Else
         nRet := 0
         Break
      EndIf
      
   Else
      
      /* Faz o c�lculo da despesa de frete com base no peso total do pedido e 
         e na cubagem total do pedido. Posteriormente � verificado qual � o mais caro.
         Ap�s isso � verificado qual o melhor pre�o de todos os agentes e esse ser� o valor do frete.       
      */
      
      If !lMemoria                           
      
         SYR->(DbSetOrder(1))
         If SYR->(dbSeek(xFilial("SYR")+(cAlias)->&(cAlias+"_VIA")+;
                                        (cAlias)->&(cAlias+"_ORIGEM")+;
                                        (cAlias)->&(cAlias+"_DEST")+;
                                        (cAlias)->&(cAlias+"_TIPTRA")))
             
            /*
              Pesquisa Agentes
            */
            
            EX3->(DbSetOrder(1))
            If EX3->(dbSeek(xFilial("EX3")+SYR->YR_VIA+;
                                           SYR->YR_ORIGEM+;
                                           SYR->YR_DESTINO))
                                                    
               While EX3->(!EOF() .And. EX3->EX3_FILIAL == xFilial("EX3")  .And.;
                                        EX3->EX3_VIA    == SYR->YR_VIA    .And.;
                                        EX3->EX3_ORIGEM == SYR->YR_ORIGEM .And.;                    
                                        EX3->EX3_DEST   == SYR->YR_DESTINO)
                  
                  If ExistValor()
                  
                     nPrcPeso  := TabFre((cAlias)->&(cAlias+"_PESLIQ"),.T.)
                     nPrcCub   := TabFre((cAlias)->&(cAlias+"_CUBAGE")/0.006,.T.)
                
                     nPrcUsado := If(nPrcPeso>nPrcCub,nPrcPeso,nPrcCub)
                  
                     aAdd(aTaxas,{EX3->EX3_AGENTE,nPrcUsado})
                  
                  EndIf
               
                  EX3->(DbSkip())
               EndDo

            Else
               nRet := 0
               Break
            EndIf            
         
         Else
            nRet := 0
            Break
         EndIf            

      Else
     
         SYR->(DbSetOrder(1))
         If SYR->(dbSeek(xFilial("SYR")+M->&(cAlias+"_VIA")+;
                                        M->&(cAlias+"_ORIGEM")+;
                                        M->&(cAlias+"_DEST")+;
                                        M->&(cAlias+"_TIPTRA")))
             
            /*
              Pesquisa Agentes
            */
            EX3->(DbSetOrder(1))
            If EX3->(dbSeek(xFilial("EX3")+SYR->YR_VIA+;
                                           SYR->YR_ORIGEM+;
                                           SYR->YR_DESTINO))
                                                    
               While EX3->(!EOF() .And. EX3->EX3_FILIAL == xFilial("EX3")  .And.;
                                        EX3->EX3_VIA    == SYR->YR_VIA    .And.;
                                        EX3->EX3_ORIGEM == SYR->YR_ORIGEM .And.;                    
                                        EX3->EX3_DEST   == SYR->YR_DESTINO)
                  
                  If ExistValor()
                  
                     nPrcPeso  := TabFre(M->&(cAlias+"_PESLIQ"),.T.)
                     nPrcCub   := TabFre(M->&(cAlias+"_CUBAGE")/0.006,.T.)

                     nPrcUsado := If(nPrcPeso>nPrcCub,nPrcPeso,nPrcCub)
                  
                     aAdd(aTaxas,{EX3->EX3_AGENTE,nPrcUsado})
                  
                  EndIf
               
                  EX3->(DbSkip())
               EndDo
            Else
               nRet := 0
               Break  // By JPP - 27/10/2006 - 11:40  - Caso o sistema n�o encontre Agente/Taxa Interromper sequencia para evitar erros.
            EndIf            
         Else
            nRet := 0
            Break  // By JPP - 27/10/2006 - 11:40  - Caso o sistema n�o encontre Agente/Taxa Interromper sequencia para evitar erros.
         EndIf            

      EndIf
   
   EndIf   
   
   //Organiza o array de forma que a menor taxa de frete fique na primeira posi��o     
   aSort(aTaxas,,,{|x,y| x[2] < y[2]})
   
   If Len(aTaxas) > 0 .And. Len(aTaxas[1]) >= 2
      //Essa vari�vel foi declarada na fun��o EECPC150()(Impress�o do Documento de Pr�-Custo).
      If Type("cAgente") <> "U"  // ValType("cAgente") <> "U" // By JPP - 27/10/2006 - 11:40  - O correto � utilizar Type no lugar de ValType para verificar se a vari�vel existe.
         cAgente := aTaxas[1][1] 
      EndIf
   
      //Retorno com a Despesa
      nRet    := aTaxas[1][2]
   EndIf
      
End Sequence

Return nRet

/*
Funcao      : ExistValor()
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : Verificar se o agente possui Cota��o de Frete por Peso Liquido.
Autor       : Eduardo Romanini
Data/Hora   : 15/08/2006 - 14:00
Obs         :
*/
*--------------------*
Function ExistValor()
*--------------------*
Local lRet := .F.

Begin Sequence

   /*
      Verifica o primeiro ou o �ltimo valor da faixa de pre�o est�o preenchidos.
      Apenas uma dessas informa��es j� � necess�ria para saber se o cadastro foi preenchido corretamente.
      N�o testa os outros campos ( De 2 a 5 ), porque se estes estiverem preenchidos e o 1 ou o 6 n�o, 
      a informa��o estar� preenchida de forma incorreta. 
   */
   If (!Empty(EX3->EX3_KILO1) .and. !Empty(EX3->EX3_VALOR1)) .or.;
      (!Empty(EX3->EX3_KILO6) .and. !Empty(EX3->EX3_VALOR6))
   
      lRet := .T.
   EndIf

End Sequence

Return lRet
*-----------------------------------------------------------------------------------------------------------------*
*                                        FIM DO PROGRAMA EECPC100                                                 *
*-----------------------------------------------------------------------------------------------------------------*
