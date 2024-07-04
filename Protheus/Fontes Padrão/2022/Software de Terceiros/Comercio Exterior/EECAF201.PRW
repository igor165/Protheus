#INCLUDE "eecaf201.ch"
#Include "eec.ch"

#define EV_PRINC2   "101"
#define EV_COM_AR   "120" // Comissão do Tipo A Remeter.
#define EV_COM_CG   "121" // Comissão do Tipo Conta Gráfica.
#define EV_COM_DF   "122" // Comissão do Deduzir da Fatura.

#define LIQ_DET     99
#define ELQ_DET     98

/*
Programa : eecaf201.prw.
Objetivo : Manutenção de Câmbio - Funções Diversas.
Autor    : Jeferson Barros Jr.
Data/Hora: 06/10/2004 15:35.
Revisao  :
Obs.     :
*/

/*
Função      : Af201Valid(cCampo).
Parametros  : cCampo - Nome do campo a ser validado.
Objetivo    : Validações diversas.
Retorno     : .t./.f.
Autor       : Jeferson Barros Jr.
Data/Hora   : 13/10/04 - 11:46.
*/
*-------------------------*
Function Af201Valid(cCampo)
*-------------------------*
Local lRet := .t.
Local nSld := 0, nSum:=0

Begin Sequence

   cCampo := Upper(AllTrim(cCampo))

   Do Case
      Case cCampo == "EEQ_CGRAFI" // Validações diversas para comissão do tipo conta gráfica.

           // O valor informado para a comissão não deve ultrapassar o valor da parcela.
           If (M->EEQ_CGRAFI > M->EEQ_VL)
              MsgStop(STR0001+Replic(ENTER,2)+; //"Valor para comissão inválido."
                      STR0002+ENTER+; //"Detalhes:"
                      STR0003+ENTER+; //"O valor informado não pode ser maior que o valor "
                      STR0004+AllTrim(EEC->EEC_MOEDA)+Space(1)+; //"da parcela ("
                      AllTrim(Transf(M->EEQ_VL,AvSx3("EEQ_VL",AV_PICTURE)))+").",STR0005) //"Atenção"
              lRet:=.f.
              Break
           EndIf

           nSum := Round((M->EEQ_CGRAFI+M->EEQ_ADEDUZ),2)
           If nSum > M->EEQ_VL
              MsgStop(STR0001+Replic(ENTER,2)+; //"Valor para comissão inválido."
                      STR0002+ENTER+; //"Detalhes:"
                      STR0006+ENTER+; //"O valor da comissão do tipo 'Conta Gráfica' somado com o valor de comissão "
                      STR0007,STR0005) //"do tipo 'Deduzir da Fatura' não deve ser maior que o valor da parcela."###"Atenção"
              lRet:=.f.
              Break
           EndIf

           nSld:= Af201CalcSld(cCampo)

           If (M->EEQ_CGRAFI > nSld)
              MsgStop(STR0001+Replic(ENTER,2)+; //"Valor para comissão inválido."
                      STR0002+ENTER+; //"Detalhes:"
                      STR0008+ENTER+; //"O valor informado não pode ser maior que o saldo disponível"
                      STR0009+Replic(ENTER,2)+; //"a vincular para comissão do tipo 'Conta Gráfica'."
                      STR0010+AllTrim(Transf(nSld,AvSx3("EEQ_CGRAFI",AV_PICTURE))),STR0005) //"Saldo: "###"Atenção"
              lRet:=.f.
              Break
           EndIf

           // ** Atualiza os campos do rodapé de saldo a vincular para cada tipo de comissão.
           Af201LoadSld(.f.)

           // ** Atualiza o valor de fechamento de câmbio.
           Af201SetVlFCam()

      Case cCampo == "EEQ_AREMET" // Validações diversas para comissão do tipo a remeter.

           // O valor informado para a comissão não deve ultrapassar o valor da parcela.
           If (M->EEQ_AREMET > M->EEQ_VL)
              MsgStop(STR0001+Replic(ENTER,2)+; //"Valor para comissão inválido."
                      STR0002+ENTER+; //"Detalhes:"
                      STR0003+ENTER+; //"O valor informado não pode ser maior que o valor "
                      STR0004+AllTrim(EEC->EEC_MOEDA)+Space(1)+; //"da parcela ("
                      AllTrim(Transf(M->EEQ_VL,AvSx3("EEQ_VL",AV_PICTURE)))+").",STR0005) //"Atenção"
              lRet:=.f.
              Break
           EndIf

           nSld:= Af201CalcSld(cCampo)

           If (M->EEQ_AREMET > nSld)
              MsgStop(STR0001+Replic(ENTER,2)+; //"Valor para comissão inválido."
                      STR0002+ENTER+; //"Detalhes:"
                      STR0008+ENTER+; //"O valor informado não pode ser maior que o saldo disponível"
                      STR0011+Replic(ENTER,2)+; //"a vincular para comissão do tipo 'A Remeter'."
                      STR0010+AllTrim(Transf(nSld,AvSx3("EEQ_AREMET",AV_PICTURE))),STR0005) //"Saldo: "###"Atenção"
              lRet:=.f.
              Break
           EndIf

           // ** Atualiza os campos do rodapé de saldo a vincular para cada tipo de comissão.
           Af201LoadSld(.f.)

      Case cCampo == "EEQ_ADEDUZ" // Validações diversas para comissão do tipo deduzir da fatura.

           // O valor informado para a comissão não deve ultrapassar o valor da parcela.
           If (M->EEQ_ADEDUZ > M->EEQ_VL)
              MsgStop(STR0001+Replic(ENTER,2)+; //"Valor para comissão inválido."
                      STR0002+ENTER+; //"Detalhes:"
                      STR0003+ENTER+; //"O valor informado não pode ser maior que o valor "
                      STR0004+AllTrim(EEC->EEC_MOEDA)+Space(1)+; //"da parcela ("
                      AllTrim(Transf(M->EEQ_VL,AvSx3("EEQ_VL",AV_PICTURE)))+").",STR0005) //"Atenção"
              lRet:=.f.
              Break
           EndIf

           nSum := Round((M->EEQ_CGRAFI+M->EEQ_ADEDUZ),2)
           If nSum > M->EEQ_VL
              MsgStop(STR0001+Replic(ENTER,2)+; //"Valor para comissão inválido."
                      STR0002+ENTER+; //"Detalhes:"
                      STR0012+ENTER+; //"O valor da comissão do tipo 'Deduzir da Fatura' somado com o valor de comissão "
                      STR0013,STR0005) //"do tipo 'Conta Gráfica' não deve ser maior que o valor da parcela."###"Atenção"
              lRet:=.f.
              Break
           EndIf

           nSld:= Af201CalcSld(cCampo)

           If (M->EEQ_ADEDUZ > nSld)
              MsgStop(STR0001+Replic(ENTER,2)+; //"Valor para comissão inválido."
                      STR0002+ENTER+; //"Detalhes:"
                      STR0008+ENTER+; //"O valor informado não pode ser maior que o saldo disponível"
                      STR0014+Replic(ENTER,2)+; //"a vincular para comissão do tipo 'Deduzir da Fatura'."
                      STR0010+AllTrim(Transf(nSld,AvSx3("EEQ_ADEDUZ",AV_PICTURE))),STR0005) //"Saldo: "###"Atenção"
              lRet:=.f.
              Break
           EndIf

           // ** Atualiza os campos do rodapé de saldo a vincular para cada tipo de comissão.
           Af201LoadSld(.f.)

           // ** Atualiza o valor de fechamento de câmbio.
           Af201SetVlFCam()
   End Case

End Sequence

Return lRet

/*
Função      : Af201LoadSld().
Parametros  : lTela - .t. (Set Inicial na abertura da tela - Default).
                      .f. (Chamada do dicionário para os campos de comissão).
Objetivo    : Carregar valores para cada tipo de comissão.
              Variáveis para utilização no rodapé da enchoice da parcela de câmbio.
Retorno     : .t.
Autor       : Jeferson Barros Jr.
Data/Hora   : 13/10/04 - 09:34.
Obs         : Esta função irá carregar o saldo a vincular, considerando apenas os valores de comissão
              que não foram vinculados à alguma parcela de evento 101, os valore que já foram vinculados
              independente da parcela estar liquidada ou não, será desconsiderado.
*/
*---------------------------*
Function Af201LoadSld(lTela)
*---------------------------*
Local lRet := .t.
Local nRec := Tmp->(Recno())

Default lTela := .t.

Begin Sequence

   nCGrafica := 0
   nARemeter := 0
   nADeduzir := 0

   Tmp->(DbGoTop())
   Do While Tmp->(!Eof())

      If !lTela
         If nRec == Tmp->(RecNo())
            Tmp->(DbSkip())
            Loop
         EndIf
      EndIf

      Do Case
         Case Tmp->EEQ_EVENT == EV_COM_CG
              nCGrafica += Tmp->EEQ_VL

         Case Tmp->EEQ_EVENT == EV_COM_AR
              nARemeter += Tmp->EEQ_VL

         Case Tmp->EEQ_EVENT == EV_COM_DF
              nADeduzir += Tmp->EEQ_VL

         Case Tmp->EEQ_EVENT == EV_PRINC2
              nCGrafica -= Tmp->EEQ_CGRAFI
              nARemeter -= Tmp->EEQ_AREMET
              nADeduzir -= Tmp->EEQ_ADEDUZ
      EndCase

      Tmp->(DbSkip())
   EndDo

   Tmp->(DbGoTo(nRec))

   If !lTela
      /* Tratamentos para atualizar os valores de saldo a vincular, no
         momento da digitação dos campos de comissão durante a manutenção das parcelas. */

      nCGrafica -= M->EEQ_CGRAFI
      nARemeter -= M->EEQ_AREMET
      nADeduzir -= M->EEQ_ADEDUZ

      oGetCGrafica:Refresh()
      oGetARemeter:Refresh()
      oGetADeduzir:Refresh()
   EndIf

End Sequence

Tmp->(DbGoTo(nRec))

Return lRet

/*
Função      : Af201CalcSld(cTipCom).
Parametros  : cTipCom (Conta Gráfica/Deduzir da Fatura/A Remeter).
Objetivo    : Calcular saldo a vincular para o tipo de comissão passado como parâmetro.
Retorno     : Saldo a vincular.
Autor       : Jeferson Barros Jr.
Data/Hora   : 13/10/04 - 14:50.
Obs         : Esta função irá retornar o saldo de comissão a vincular considerando o total de comissão
              com o abatimento do valor vinculado a parcelas com evento 101 já liquidadas. Os valores
              associados a parcelas com evento 101 em aberto serão considerados como 'saldo a liquidar'.
*/
*-----------------------------------*
Static Function Af201CalcSld(cTipCom)
*-----------------------------------*
Local nRet:=0, nRec:= Tmp->(RecNo())

Begin Sequence

   cTipCom := Upper(AllTrim(cTipCom))

   Tmp->(DbGoTop())
   Do While Tmp->(!Eof())

      Do Case
         Case cTipCom == "EEQ_CGRAFI"
              If (Tmp->EEQ_EVENT == EV_COM_CG)
                 nRet += Tmp->EEQ_VL

              ElseIf (Tmp->EEQ_EVENT == EV_PRINC2)
                 If !Empty(Tmp->EEQ_PGT)
                    nRet -= Tmp->EEQ_CGRAFI
                 EndIf
              EndIf

         Case cTipCom == "EEQ_AREMET"
              If (Tmp->EEQ_EVENT == EV_COM_AR)
                 nRet += Tmp->EEQ_VL

              ElseIf (Tmp->EEQ_EVENT == EV_PRINC2)
                 If !Empty(Tmp->EEQ_PGT)
                    nRet -= Tmp->EEQ_AREMET
                 EndIf
              EndIf

         Case cTipCom == "EEQ_ADEDUZ"
              If (Tmp->EEQ_EVENT == EV_COM_DF)
                 nRet += Tmp->EEQ_VL

              ElseIf (Tmp->EEQ_EVENT == EV_PRINC2)
                 If !Empty(Tmp->EEQ_PGT)
                    nRet -= Tmp->EEQ_ADEDUZ
                 EndIf
              EndIf
      EndCase

      Tmp->(DbSkip())
   EndDo

   Tmp->(DbGoTo(nRec))

End Sequence

Return nRet

/*
Função      : Af201VldSld().
Parametros  : Nenhum.
Objetivo    : Verificar na validação da gravação final do câmbio se existe saldo sem vinculação para qualquer
              tipo de comissão.
Retorno     : .t. - Todos os valores de comissão foram corretamente vinculados.
              .f. - Existe saldo sem vinculação.
Autor       : Jeferson Barros Jr.
Data/Hora   : 14/10/04 - 11:45.
Obs         :
*/
*--------------------*
Function Af201VldSld()
*--------------------*
Local nCGrafica:=0, nARemeter:=0, nADeduzir:=0, nRec := Tmp->(Recno())
Local lRet:=.t.
Local cMsg
Local lTemParcReceb := .F. // By JPP - 06/03/2007 -10:00
Local lPrcAdMvExt   := .F. //NCF - 09/11/2015

Begin Sequence

   Tmp->(DbGoTop())
   Do While Tmp->(!Eof())
      Do Case
         Case Tmp->EEQ_EVENT == EV_COM_CG
              nCGrafica += Tmp->EEQ_VL

         Case Tmp->EEQ_EVENT == EV_COM_AR
              nARemeter += Tmp->EEQ_VL

         Case Tmp->EEQ_EVENT == EV_COM_DF
              nADeduzir += Tmp->EEQ_VL

         Case Tmp->EEQ_EVENT == EV_PRINC2 .Or. TMP->EEQ_EVENT == "603"
              nCGrafica -= Tmp->EEQ_CGRAFI
              nARemeter -= Tmp->EEQ_AREMET
              nADeduzir -= Tmp->EEQ_ADEDUZ
              If Tmp->EEQ_TIPO == "R"
                 lTemParcReceb := .T.
              EndIf
              If AvFlags("CAMBIO_EXP_MOV_EXT") .And. EasyVerModal("TMP") .And. TMP->EEQ_TIPO == 'A'  //NCF - 09/11/2015 - Parcelas de adiantamento com movimento no exterior detêm parte do rateio da comissão conta gráfica e
                 lPrcAdMvExt := .T.                                                                  //                   este valor não é gravado na parcela, apenas utilizado na geração das parcelas para calcular o valor
              EndIf                                                                                  //                   restante da comis. conta gráfica a ser distribuido proporcionalmente nas parcelas a receber.
      EndCase

      Tmp->(DbSkip())
   EndDo
   Tmp->(DbGoTo(nRec))
                                                                                             //DFS - 29/08/12 - Tratamento para não apresentar a mensagem quando um dos eventos estiver preenchido no parâmetro MV_AVG0087
   If (nCGrafica <> 0 .Or. nARemeter <> 0 .Or. nADeduzir <> 0) .And. (lTemParcReceb == .T.) .AND. !("120" $ EasyGParam("MV_AVG0087") .OR. "121" $ EasyGParam("MV_AVG0087") .OR. "122" $ EasyGParam("MV_AVG0087")) .And. !lPrcAdMvExt  // By JPP - 06/03/2007 -10:00 - Isto se faz necessário pois o cálculo só é valido quando se tem parcelas
                                                                                            // de cambio a receber. Quando se tem adiantamento integral o sistema não gera parcelas a receber
                                                                                            // e não tem onde gravar o valor da comissão na parcela de cambio a receber.
      lRet:=.f.
      cMsg := STR0015+Replic(ENTER,2)+; //"Manutenção de Parcelas de Câmbio - Validações"
              STR0016+ENTER+; //"Problema:"
              STR0017+ENTER+; //"Existe(m) valor(es) de tipos de comissão não vinculado(s) ou vinculado(s)"
              STR0018+Replic(ENTER,2)+; //"incorretamente."
              STR0019+Replic(ENTER,2)+; //"Detalhes: "
              IncSpace(STR0020,20,.f.)+Space(2)+IncSpace(STR0021,20,.t.)+; //"Tipo Comissão"###"Saldo"
              Space(2)+IncSpace(STR0022,30,.f.)+ENTER+; //"Observação"
              Replic("-",13)+Space(13)+Replic("-",16)+Space(2)+Replic("-",24)+ENTER

      If !Empty(nCGrafica)
         cMsg += IncSpace(STR0023,20,.f.)+Space(2)+; //"Conta Gráfica"
                 IncSpace(Transf(nCGrafica,AvSx3("EEQ_CGRAFI",AV_PICTURE)),20,.t.)

         cMsg += Space(2) + If(nCGrafica > 0,STR0024,STR0025)+ENTER //"À Vincular"###"Vinculado Incorretamente"
      EndIf

      If !Empty(nARemeter)
         cMsg += IncSpace(STR0026,20,.f.)+Space(2)+; //"A Remeter"
                 IncSpace(Transf(nARemeter,AvSx3("EEQ_AREMET",AV_PICTURE)),20,.t.)

         cMsg += Space(2) + If(nARemeter > 0,STR0024,STR0025)+ENTER   //"À Vincular"###"Vinculado Incorretamente"
      EndIf

      If !Empty(nADeduzir)
         cMsg += IncSpace(STR0027,20,.f.)+Space(2)+; //"Deduzir da Fatura"
                 IncSpace(Transf(nADeduzir,AvSx3("EEQ_ADEDUZ",AV_PICTURE)),20,.t.)

         cMsg += Space(2) + If(nADeduzir > 0,STR0024,STR0025)+ENTER   //"À Vincular"###"Vinculado Incorretamente"
      EndIf

      cMsg += ENTER
      cMsg += STR0028 //"Faça a vinculação do(s) valor(es) pendente(s)."

      // Exibe janela com os detalhes das validações.
      EECView(cMsg,STR0029,STR0030) //"Vinculação de Valores de Comissões"###"Detalhes"
   EndIf

End Sequence

Return lRet

/*
Função      : af201CanModify().
Parametros  : nTipo - INC_DET, ALT_DET, EXC_DET, VIS_DET, LIQ_DET e ELQ_DET.
Objetivo    : Verificar se a parcela poderá ser manutenciada de acordo com a opção.
Retorno     : .t./.f.
Autor       : Jeferson Barros Jr.
Data/Hora   : 15/10/04 - 11:40.
Obs         :
*/
*----------------------------*
Function af201CanModify(nTipo)
*----------------------------*
Local cDetalhes
Private lRetValid:=.t.
Private nTipoRdm:= nTipo  //TRP - 01/12/2011 - Variável para ser utilizada em rdmake.

Begin Sequence

   If nTipo == ALT_DET
      If Left(Tmp->EEQ_EVENT,1) = "8"
         MsgStop(STR0031+Replic(ENTER,2)+; //"Parcelas com evento de desconto/devolução não podem ser alteradas."
                 STR0032+ENTER+; //"Procedimentos:"
                 STR0033+ENTER+; //"Exclua o desconto/devolução a ser modificado e em seguida inclua a "
                 STR0034,STR0005) //"parcela com os valores corretos."###"Atenção"
         lRetValid:=.f.
         Break
      EndIf
   EndIf

   If Tmp->EEQ_TIPO == "A" // Parcela de Adiantamento.
      Do Case
         Case nTipo == ALT_DET .And. (!EasyGParam("MV_AVG0180",, .F.) .And. TMP->EEQ_MODAL <> "2")//Caso seja parcela de adiantamento recebida no exterior, permite alterar no embarque
              cDetalhes := STR0035+Capital(BscXBox("EEQ_TIPO","A"))+STR0081+ENTER+; //"As informações das parcelas do tipo '" //STR0081	"' não "
                           STR0036 //"podem sofrer alterações."

         Case nTipo == EXC_DET .And. ((!EasyGParam("MV_AVG0180",, .F.) .And. TMP->EEQ_MODAL <> "2") .Or. Empty(TMP->EEQ_ORIGEM))//Caso seja quebra de parcela de adiantamento recebida no exterior, permite excluir
              cDetalhes := STR0037+Capital(BscXBox("EEQ_TIPO","A"))+STR0038 //"Parcelas do tipo "###"' não podem ser excluidas."

         Case nTipo == LIQ_DET .And. (!EasyGParam("MV_AVG0180",, .F.) .And. TMP->EEQ_MODAL <> "2")//Caso seja parcela de adiantamento recebida no exterior, permite liquidar
              cDetalhes := STR0037+Capital(BscXBox("EEQ_TIPO","A"))+STR0039 //"Parcelas do tipo "###"' não podem ser liquidadas."

         Case nTipo == ELQ_DET .And. (!EasyGParam("MV_AVG0180",, .F.) .And. TMP->EEQ_MODAL <> "2")//Caso seja parcela de adiantamento recebida no exterior, permite estornar a liquidação no embarque
              cDetalhes := STR0037+Capital(BscXBox("EEQ_TIPO","A"))+STR0040+ENTER+; //"Parcelas do tipo "###"' não podem ser estornadas."
                           STR0041+ENTER+; //"O estorno não é permitido visto que a liquidação é bloqueada "
                           STR0042 //"pelo sistema."
      EndCase

      If !Empty(cDetalhes)
         MsgStop(STR0043+ENTER+; //"Problema: "
                 STR0044+Replic(ENTER,2)+; //"A operação não poderá ser realizada."
                 STR0019+ENTER+; //"Detalhes: "
                 cDetalhes,STR0045) //"Validações"
         lRetValid:=.f.
      EndIf
   EndIf

   //TRP - 01/12/2011 - Ponto de Entrada para customização do AvInteg Exportação.
   If EasyEntryPoint("EECAF201")
      ExecBlock("EECAF201", .f., .f., "VALIDA_PARCELA")
   Endif

End Sequence

Return lRetValid

/*
Função      : Af201SetVlFCam().
Parametros  : cAlias - Alias da tabela onde o campo Valor de Fechamento de Câmbio deverá ser atualizado.
Objetivo    : Atualiza o campo Valor de Fechamento de Câmbio.
Retorno     : .t.
Autor       : Jeferson Barros Jr.
Data/Hora   : 18/10/04 - 09:50.
Obs         :
*/
*-----------------------------*
Function Af201SetVlFCam(cAlias)
*-----------------------------*
Local lRet:=.t.

Default cAlias:= "M"

Begin Sequence
   If EECFlags("FRESEGCOM") // By JPP - 05/10/2005 - 10:35 - Calculos com os campos EEQ_CGRAFI E EEQ_ADEDUZ só serão possiveis se a rotina de frete seguro e comissão estiver habilitada.
      If cAlias = "M"
         M->EEQ_VLFCAM :=  AF200VLFCam("M")//Round((M->EEQ_VL-M->EEQ_CGRAFI),2)
         // M->EEQ_VLFCAM := Round((M->EEQ_VL-(M->EEQ_CGRAFI+M->EEQ_ADEDUZ)),2)         
      Else
         (cAlias)->EEQ_VLFCAM :=  AF200VLFCam(cAlias)//Round(((cAlias)->EEQ_VL-(cAlias)->EEQ_CGRAFI),2)
         //(cAlias)->EEQ_VLFCAM := Round(((cAlias)->EEQ_VL-((cAlias)->EEQ_CGRAFI+(cAlias)->EEQ_ADEDUZ)),2)
      EndIf
   EndIf

End Sequence

Return lRet

/*
Função      : Af201CanExclude().
Parametros  : cAlias.  - Alias para ser validado.
              lShowMsg - Exibe ou não msg.
Objetivo    : Verifica se a parcela poderá ser excluída de acordo com o evento.
Retorno     : .t./.f.
Autor       : Jeferson Barros Jr.
Data/Hora   : 21/10/04 - 11:03.
Obs         :
*/
*---------------------------------------*
Function Af201CanExclude(cAlias,lShowMsg)
*---------------------------------------*
Local lRet := .t., lErro := .f.
Local cEvento, cConteudo, cMv, cCheck
Local j:=1, nPos := 0, nTam := AvSx3("EEQ_EVENT",AV_TAMANHO), nRec:=0

Default cAlias   := "M"
Default lShowMsg := .t.

Begin Sequence

   cEvento := If(cAlias=="M",AllTrim(M->EEQ_EVENT),;
                             AllTrim((cAlias)->EEQ_EVENT))

   /* Serão verificados todos os MV´s "MV_EVENT??" de 01 até 10, a fim de analisar se o evento poderá ser
      excluído ou não. */
   Do While (j<=10)
      cMv := "MV_EVENT"+StrZero(j,2)

      // ** Verifica se o mv existe e se o mesmo está preenchido.
      If EasyGParam(cMv,.t.) .And. !Empty(EasyGParam(cMv))
         cConteudo := AllTrim(EasyGParam(cMv))

         // ** JPM - 17/03/06 - Correção no tratamento do evento.
         If Right(cConteudo,1) <> "/"
            cConteudo += "/"
         EndIf
         If Left(cConteudo,1) <> "/"
            cConteudo := "/" + cConteudo
         EndIf
         // **

         nPos   := 1   // Variável de controle para leitura do conteúdo dos mvs.
         lFinal := .f. // Flag para indicação do final da string com todos as dependências dos eventos.

         Do While !lFinal .And. !lErro

            // Verifica se o evento digitado pelo usuário está relacionado neste mv.
            nPos := At(cEvento,SubStr(cConteudo,If(nPos=1,nPos,nPos+nTam)))

            If nPos <= 0
               j++
               lFinal := .t.
               Loop
            EndIf

            If (SubStr(cConteudo,nPos+nTam,1) == "-")
               /* Neste caso o evento faz parte do domínio da relação, ou seja outro evento é dependente
                  deste. Dessa forma deverá ser verificado se o evento dependente existe, em caso positivo
                  a exclusão é bloqueada */

               cCheck := AvKey(SubStr(cConteudo, nPos+(nTam+1),nTam),"EEQ_EVENT")

               nRec := TMP->(Recno())
               Tmp->(DbGoTop())
               Do While Tmp->(!Eof())
                  If Tmp->EEQ_EVENT == cCheck
                     // ** Se o evento dependente existir a parcela não poderá ser excluída.
                     lErro := .t.
                     Exit
                  EndIf
                  Tmp->(DbSkip())
               EndDo
              Tmp->(DbGoTo(nRec))
            EndIf
         EndDo
         If lErro
            Exit
         EndIf
      EndIf
      j++
   EndDo

   If lErro
      If lShowMsg
         MsgStop(STR0016+ENTER+; //"Problema:"
                 STR0046+Replic(ENTER,2)+; //"A parcela não poderá ser excluída."
                 STR0002+ENTER+; //"Detalhes:"
                 STR0047+ENTER+; //"De acordo com o(s) parâmetros de dependência de Eventos (MV_EVENT??),"
                 STR0048+AllTrim(TMP->EEQ_EVENT)+STR0049+ENTER+; //"O evento '"###"' possui dependentes lançados e não poderá ser excluído,"
                 STR0050,STR0005) //"até que todas as parcelas com o evento dependente sejam eliminadas."###"Atenção"
      EndIf
      lRet:=.f.
   EndIf

End Sequence

Return lRet

/*
Função      : Af201VldDiscount().
Parametros  : Nenhum.
Objetivo    : Valida a inclusão de desconto.
Retorno     : .t./.f.
Autor       : Jeferson Barros Jr.
Data/Hora   : 21/10/04 - 11:03.
Obs         :
*/
*-------------------------*
Function Af201VldDiscount()
*-------------------------*
Local lRet:=.t., lErro := .f.
Local cEventAux
Local aOrd:=SaveOrd({"TMP","EF3"})
Local nFreeValue := 0, nValCom := 0
Local cEvent := M->EEQ_EVENT
Local lFilial:= .F. // TDF - 03/02/11
Local cMsg1 := cMsg2 := ""

Begin Sequence

    nPos := aScan(aDiscount,{|x| x[1] == M->EEQ_EVENT})
    If nPos <> 0
       cEventAux := aDiscount[nPos][2]
    Else
       // Verifica no(s) mv(s) de dependências qual é o evento "pai".
       cEventAux := Af201EventPai(M->EEQ_EVENT)

       If Empty(cEventAux)
          MsgStop(STR0016+ENTER+; //"Problema:"
                  STR0051+; //"O desconto não poderá ser lançado."
                  STR0002+ENTER+; //"Detalhes:"
                  STR0052+cEvent+STR0053+ENTER+; //"O evento de desconto '"###"' não está configurado corretamente no(s) "
                  STR0054,STR0005) //"parâmetros de configuração de eventos (MV_EVENT??)."###"Atenção"
          lRet:=.f.
          Break
       EndIf
    EndIf

    /* Verifica nas parcelas já lançadas se o desconto poderá ser lançado.
       Regras: - Verifica se o evento "pai" existe.
               - O evento "pai" deve possuir a mesma moeda da parcela de desconto.
               - Os valores já liquidados serão desconsiderados.
               - As parcelas com vinculação no EF3 serão desconsideradas.
               - Para o caso de desconto para parcelas 101, a soma dos valores das parcelas subtraído
                 do total de comissão vinculado em cada parcela, deverá ser menor ou igual ao valor do
                 desconto a ser lançado. */

    Tmp->(DbSetOrder(4))

    If !Tmp->(DbSeek(cEventAux))
       // Caso o Evento "Pai" não seja encontrado a inclusão do desconto é bloqueada.
       MsgStop( STR0016+ENTER+; //"Problema:"
                STR0055+AllTrim(cEvent)+"'."+Replic(ENTER,2)+; //"Não é possível incluir parcelas de desconto '"
                STR0002+ENTER+; //"Detalhes:"
                STR0056+ENTER+; //"Para realizar esta operação é necessário que exista uma parcela "
                STR0057+cEventAux+"'.",STR0005) //"previamente lançada com evento '"###"Atenção"
       lRet:=.f.
       Break
    Else
       EF3->(DbSetOrder(3))
       Do While Tmp->(!Eof()) .And. TMP->EEQ_EVENT == cEventAux

          // ** Desconsidera as parcelas com moeda diferente
          If M->EEQ_MOEDA <> Tmp->EEQ_MOEDA
             Tmp->(DbSkip())
             cMsg1 := "Existem parcelas com moedas diferentes do adiantamento, verificar!"
             Loop
          EndIf

          // ** Desconsidera as parcelas liquidadas.
          If !Empty(Tmp->EEQ_PGT)
             Tmp->(DbSkip())
             cMsg2 := "Não existem parcelas em aberto para associar ao adiantamento, verificar!"
             Loop
          EndIf

          If cEventAux == EV_PRINC2
             // TDF - 03/02/11
             // ** Verifica se a parcela(Processo) possui vinculação com o EF3(Contrato) e se é da mesma filial(Processo+Contrato)
             If EF3->(DbSeek(xFilial("EF3")+If(lEFFTpMod,IF(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),"")+Tmp->EEQ_NRINVO+Tmp->EEQ_PARC))  //HVR SEEK I OU E

                DO WHILE EF3->(!EOF());
                        .AND. If(lEFFTpMod,IF(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),"") == EF3->EF3_TPMODU;
                        .AND. Tmp->EEQ_NRINVO                                        == EF3->EF3_INVOIC;
                        .AND. Tmp->EEQ_PARC                                          == EF3->EF3_PARC

                      IF xFilial("EEQ") == EF3->EF3_FILORI
                         lFilial:= .T.
                      ENDIF
                   EF3->(DbSkip())
                   LOOP
                ENDDO

                IF lFilial
                   Tmp->(DbSkip())
                   LOOP
                ENDIF

             EndIf
          EndIf

          // ** Acumula os valores livres para abatimento.
          nFreeValue += Tmp->EEQ_VL

          If Tmp->EEQ_EVENT == EV_PRINC2
             /*
             Nopado por ER - 22/05/2007
             Para o tipo "A Remeter" o valor da comissão não deverá ser considerado para a validação
             de inclusão de desconto.
             O pagamento da comissão desse tipo é de responsabilidade do Exportador, nesse caso o importador paga
             todo o valor ao exportador e esse que irá pagar o agente.

             nValCom += (Tmp->EEQ_CGRAFI+Tmp->EEQ_ADEDUZ+Tmp->EEQ_AREMET)
             */
             nValCom += (Tmp->EEQ_CGRAFI+Tmp->EEQ_ADEDUZ)
          EndIf

          Tmp->(DbSkip())
       EndDo

       If nFreeValue = 0     //LRS 5/11/2013 - Trocado a mensagem de erro para adequar a validação (STR0086,STR0087)
       /*   MsgStop( STR0016+ENTER+; //"Problema:"
                   STR0086+ENTER+; //"Verificar se a moeda cadastrada no importador é a mesma utilizada no adiantamento"
                   STR0002+ENTER+; //"Detalhes:"
                   STR0087+ENTER,; //"Verificar se a moeda cadastrada no importador confere com a utilizada no adiantamento"
                   STR0005) //"Atenção"  */
                MsgStop( cMsg1 + ENTER + cMsg2 + ENTER , STR0005 )
          lRet:=.f.
          Break
       Else
          If cEventAux = EV_PRINC2
             /* Para o desconto lançado sobre as parcelas de evento 101, o valor "livre" onde o desconto
                poderá ser abatido deve ser calculado abatendo os valores vinculados para cada tipo de
                comissão. */

             If (M->EEQ_VL > (nFreeValue)) //- nValCom))  // GFP - 17/11/2014
                lErro := .t.
                nVlAux := nFreeValue - nValCom
             EndIf
          Else
             If (M->EEQ_VL > nFreeValue)
                lErro := .t.
                nVlAux := nFreeValue
             EndIf
          EndIf
       EndIf

       If lErro
          MsgStop(STR0016+ENTER+; //"Problema:"
                  STR0060+ENTER+; //"O valor de desconto não é válido para as parcelas de "
                  STR0061+cEventAux+"'."+Replic(ENTER,2)+; //"evento '"
                  STR0002+ENTER+; //"Detalhes:"
                  STR0062+; //"O valor de desconto ("
                  M->EEQ_MOEDA+Space(1)+AllTrim(Transf(M->EEQ_VL,AvSx3("EEQ_VL",AV_PICTURE)))+") "+;
                  STR0063+ENTER+; //"ultrapassa o valor "
                  STR0064+; //"disponível para abatimento ("
                  M->EEQ_MOEDA+Space(1)+AllTrim(Transf((nFreeValue-nValCom),AvSx3("EEQ_VL",AV_PICTURE)))+").",;
                  STR0005) //"Atenção"
          lRet := .f.
       EndIf
    EndIf

End Sequence

RestOrd(aOrd,.t.)

Return lRet

/*
Função      : Af201EventPai().
Parametros  : cEvent - Código do evento a ser analisado.
Objetivo    : Encontrar nos MVs MV_EVENT?? qual é o evento pai do evento passado como parâmetro.
Retorno     : .t./.f.
Autor       : Jeferson Barros Jr.
Data/Hora   : 26/10/04 - 10:46.
Obs         :
*/
*----------------------------*
Function Af201EventPai(cEvent)
*----------------------------*
Local nTam := AvSx3("EEQ_EVENT",AV_TAMANHO), j:=0
Local lOk  := .f.
Local cRet := ""

Begin Sequence

   Do While ((j<=10) .And. !lOk)
      cMv := "MV_EVENT"+StrZero(j,2)

      // ** Verifica se o mv existe e se o mesmo está preenchido.
      If EasyGParam(cMv,.t.) .And. !Empty(EasyGParam(cMv))
         cConteudo := AllTrim(EasyGParam(cMv))

         // ** JPM - 17/03/06 - Correção no tratamento do evento.
         If Right(cConteudo,1) <> "/"
            cConteudo += "/"
         EndIf
         If Left(cConteudo,1) <> "/"
            cConteudo := "/" + cConteudo
         EndIf
         // **

         nPos := At(cEvent,cConteudo) // Verifica se o evento digitado pelo usuário está relacionado neste mv.
         If nPos <= 0
            j++
            Loop
         EndIf

         If (nPos-1) > 0
            If (SubStr(cConteudo,nPos-1,1) == "-")
               cRet := AvKey(SubStr(cConteudo, nPos-(nTam+1),nTam),"EEQ_EVENT")
               lOk  := .t.
               Loop
            EndIf
         EndIf
      EndIf
      j++
   EndDo

End Sequence

Return cRet

/*
Função      : Af201AddDiscount().
Parametros  : cEvent - Código do desconto a ser tratado.
              nTipo  - Opção (Inclusão/Alteração).
Objetivo    : Realizar o abatimento do valor de desconto das parcelas com o evento "pai".
Retorno     : .t./.f.
Autor       : Jeferson Barros Jr.
Data/Hora   : 26/10/04 - 18:21.
Obs         :
*/
*-------------------------------------*
Function Af201AddDiscount(cEvent,nTipo,aParc101)//RMD - 05/10/17 - Recebe referência de parâmetro para registrar as parcelas que tiveram o valor abatido
*-------------------------------------*
Local lRet := .t., aOrd:=SaveOrd("TMP")
Local cEventAux
Local nSldDiscount := 0, nFreeValue := 0
Local aTMPCheck  := {}
Local aOrdEEQTMP := {}
Local i
Private lSeekLast := .T.//RMD - 31/10/18 - Define se a verificação ocorrerá em ordem decrescente (.T.) ou crescente (.F.).
Default aParc101 := {}

Begin Sequence

    nPos := aScan(aDiscount,{|x| x[1] == cEvent})
    If nPos <> 0
       cEventAux := aDiscount[nPos][2]
    Else
       // Verifica no(s) mv(s) de dependências qual é o evento "pai".
       cEventAux := Af201EventPai(cEvent)
    EndIf

    If nTipo == INC_DET
        nSldDiscount := M->EEQ_VL

        Tmp->(DbSetOrder(4))

        If EasyEntryPoint("EECAF201")
            ExecBlock("EECAF201", .f., .f., "AF201ADDDISCOUNT")
        EndIf

        If if(lSeekLast, Tmp->(AvSeekLast(cEventAux)), Tmp->(DbSeek(cEventAux)))
            Do While Tmp->(If(lSeekLast, !Bof(), !Eof())) .And. Tmp->EEQ_EVENT == cEventAux .And. (nSldDiscount > 0)

                If aScan(aDeletados, TMP->TMP_RECNO) > 0
                    Tmp->(DbSkip(If(lSeekLast, -1, Nil)))
                    Loop
                EndIf

                // ** Desconsidera as parcelas liquidadas.
                //If If(TMP->EEQ_MODAL == "2" , !Empty(TMP->EEQ_DTCE) ,!Empty(TMP->EEQ_PGT))  //NCF - 07/08/2017 - Considerar as liquidações com Mov. Exterior
                //RMD - 31/10/18 - Se tiver data de crédito no exterior, não deve associar independente da modalidade
                If !Empty(TMP->EEQ_DTCE) .Or. !Empty(TMP->EEQ_PGT)
                    Tmp->(DbSkip(If(lSeekLast, -1, Nil)))
                    Loop
                EndIf

                // ** Desconsidera as parcelas com moeda diferente da moeda do desconto.
                If M->EEQ_MOEDA <> Tmp->EEQ_MOEDA
                    Tmp->(DbSkip(If(lSeekLast, -1, Nil)))
                    Loop
                EndIf
                
                If cEventAux == EV_PRINC2
                    // ** Verifica se a parcela possui vinculação com o EF3.
                    If EF3->(DbSeek(xFilial("EF3")+If(lEFFTpMod,IF(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),"")+Tmp->EEQ_NRINVO+Tmp->EEQ_PARC))  //HVR SEEK I OU E
                    Tmp->(DbSkip(If(lSeekLast, -1, Nil)))
                    Loop
                    EndIf
                EndIf
                
                // ** Realiza o abatimento do valor de desconto.
                If cEventAux == EV_PRINC2

                    /* Para parcelas com evento 101, os valores vinculados para cada tipo de comissão são
                    levados em consideração para calcular o valor disponível para abatimento do desconto. */

                    Do Case
                    Case !Empty(Tmp->EEQ_CGRAFI) .Or. !Empty(Tmp->EEQ_ADEDUZ)// .Or. !Empty(Tmp->EEQ_AREMET)

                            /* Neste caso subtrai os valores de comissão do valor disponível para abatimento
                            do desconto. */

                            /*
                            Nopado por ER - 22/05/2007
                            Para o tipo "A Remeter" o valor da comissão não deverá ser considerado para a inclusão de desconto.
                            O pagamento da comissão desse tipo é de responsabilidade do Exportador, nesse caso o importador paga
                            todo o valor ao exportador e esse que irá pagar o agente.

                            nFreeValue := (Tmp->EEQ_VL - (Tmp->EEQ_CGRAFI+Tmp->EEQ_ADEDUZ+Tmp->EEQ_AREMET))
                            */
                            nFreeValue := (Tmp->EEQ_VL - (Tmp->EEQ_CGRAFI+Tmp->EEQ_ADEDUZ))
                            
                        If nFreeValue  > nSldDiscount
                            If EasyGParam("MV_EEC0042",,.F.) .Or. AvFlags("EEC_LOGIX") //THTS - 29/03/2018
                                //aAdd(aParc101, {TMP->EEQ_PARC, nSldDiscount, TMP->EEQ_FINNUM}) //RMD - 05/10/17 - Guarda os dados da parcela atualizada
                                //RMD - 12/03/18 - Caso tenha parcela de origem guarda esta parcela também, além dos dados de invoice e emissão
                                aAdd(aParc101, {If(!Empty(TMP->EEQ_ORIGEM), TMP->EEQ_PARVIN, TMP->EEQ_PARC), nSldDiscount, TMP->EEQ_FINNUM, TMP->EEQ_PARC, TMP->EEQ_NRINVO, TMP->EEQ_EMISSA,Round(Tmp->EEQ_CGRAFI*(nSldDiscount/Tmp->EEQ_VL),2), Round(Tmp->EEQ_ADEDUZ*(nSldDiscount/Tmp->EEQ_VL),2), Round(Tmp->EEQ_AREMET*(nSldDiscount/Tmp->EEQ_VL),2),TMP->EEQ_DESCON})
                                TMP->EEQ_CGRAFI -= aParc101[Len(aPArc101)][7]
                                TMP->EEQ_ADEDUZ -= aParc101[Len(aPArc101)][8]
                                TMP->EEQ_AREMET -= aParc101[Len(aPArc101)][9]
                            EndIf
                            Tmp->EEQ_VL -= nSldDiscount
                            nSldDiscount := 0
                        Else
                            If EasyGParam("MV_EEC0042",,.F.) .Or. AvFlags("EEC_LOGIX") //THTS - 29/03/2018
                                //aAdd(aParc101, {TMP->EEQ_PARC, nFreeValue, TMP->EEQ_FINNUM}) //RMD - 05/10/17 - Guarda os dados da parcela atualizada
                                //RMD - 12/03/18 - Caso tenha parcela de origem guarda esta parcela também, além dos dados de invoice e emissão
                                aAdd(aParc101, {If(!Empty(TMP->EEQ_ORIGEM), TMP->EEQ_PARVIN, TMP->EEQ_PARC), nFreeValue, TMP->EEQ_FINNUM, TMP->EEQ_PARC, TMP->EEQ_NRINVO, TMP->EEQ_EMISSA,Round(Tmp->EEQ_CGRAFI*(nFreeValue/Tmp->EEQ_VL),2), Round(Tmp->EEQ_ADEDUZ*(nFreeValue/Tmp->EEQ_VL),2), Round(Tmp->EEQ_AREMET*(nFreeValue/Tmp->EEQ_VL),2),TMP->EEQ_DESCON})
                                TMP->EEQ_CGRAFI -= aParc101[Len(aPArc101)][7]
                                TMP->EEQ_ADEDUZ -= aParc101[Len(aPArc101)][8]
                                TMP->EEQ_AREMET -= aParc101[Len(aPArc101)][9]
                            EndIf
                            Tmp->EEQ_VL -= nFreeValue
                            nSldDiscount -= nFreeValue
                        EndIf

                            Af201SetVlFCam("TMP") // ** Atualiza o valor de fechamento de câmbio.

                    Case Empty(Tmp->EEQ_CGRAFI) .And. Empty(Tmp->EEQ_ADEDUZ)// .And. Empty(Tmp->EEQ_AREMET)
        
                            // Neste caso apenas o valor cheio da parcela é levado em consideração.
                        If Tmp->EEQ_VL  > nSldDiscount
                            If EasyGParam("MV_EEC0042",,.F.) .Or. AvFlags("EEC_LOGIX") //THTS - 29/03/2018
                                //aAdd(aParc101, {TMP->EEQ_PARC, nSldDiscount, TMP->EEQ_FINNUM}) //RMD - 05/10/17 - Guarda os dados da parcela atualizada
                                //RMD - 12/03/18 - Caso tenha parcela de origem guarda esta parcela também, além dos dados de invoice e emissão
                                aAdd(aParc101, {If(!Empty(TMP->EEQ_ORIGEM), TMP->EEQ_PARVIN, TMP->EEQ_PARC), nSldDiscount, TMP->EEQ_FINNUM, TMP->EEQ_PARC, TMP->EEQ_NRINVO, TMP->EEQ_EMISSA,Round(Tmp->EEQ_CGRAFI*(nSldDiscount/Tmp->EEQ_VL),2), Round(Tmp->EEQ_ADEDUZ*(nSldDiscount/Tmp->EEQ_VL),2), Round(Tmp->EEQ_AREMET*(nSldDiscount/Tmp->EEQ_VL),2),TMP->EEQ_DESCON})
                                TMP->EEQ_CGRAFI -= aParc101[Len(aPArc101)][7]
                                TMP->EEQ_ADEDUZ -= aParc101[Len(aPArc101)][8]
                                TMP->EEQ_AREMET -= aParc101[Len(aPArc101)][9]
                            EndIf
                            Tmp->EEQ_VL -= nSldDiscount
                            nSldDiscount := 0
                            Af201SetVlFCam("TMP") // ** Atualiza o valor de fechamento de câmbio.
                        Else
                            nSldDiscount -= Tmp->EEQ_VL
                            If EasyGParam("MV_EEC0042",,.F.) .Or. AvFlags("EEC_LOGIX") //THTS - 29/03/2018
                                //aAdd(aParc101, {TMP->EEQ_PARC, Tmp->EEQ_VL, TMP->EEQ_FINNUM}) //RMD - 05/10/17 - Guarda os dados da parcela atualizada
                                //RMD - 12/03/18 - Caso tenha parcela de origem guarda esta parcela também, além dos dados de invoice e emissão
                                aAdd(aParc101, {If(!Empty(TMP->EEQ_ORIGEM), TMP->EEQ_PARVIN, TMP->EEQ_PARC), Tmp->EEQ_VL, TMP->EEQ_FINNUM, TMP->EEQ_PARC, TMP->EEQ_NRINVO, TMP->EEQ_EMISSA, Tmp->EEQ_CGRAFI, Tmp->EEQ_ADEDUZ, Tmp->EEQ_AREMET,TMP->EEQ_DESCON})
                            EndIf

                            If !Empty(TMP->TMP_RECNO)
                                aAdd(aDeletados,TMP->TMP_RECNO)
                            Endif
                            TMP->(DbDelete())
                        EndIf
                    EndCase
                Else // Demais eventos.

                    If Tmp->EEQ_VL  > nSldDiscount
                        Tmp->EEQ_VL -= nSldDiscount
                        nSldDiscount := 0
                    Else
                        nSldDiscount -= Tmp->EEQ_VL

                        If !Empty(TMP->TMP_RECNO)
                            aAdd(aDeletados,TMP->TMP_RECNO)
                        Endif
                        TMP->(DbDelete())
                    EndIf
                EndIf
                If !TMP->(DELETED())
                    aAdd(aTMPCheck,{TMP->TMP_RECNO, TMP->EEQ_EVENT, TMP->EEQ_VL, TMP->(Recno()) })
                EndIf
                Tmp->(DbSkip(If(lSeekLast, -1, Nil)))
            EndDo
            
            If Type("aFat3Alt") == "A" .And. Len(aTMPCheck) > 0
                aOrdEEQTMP := SaveOrd({"EEQ","TMP"})
                For i:=1 To Len(aTMPCheck)
                    If aTMPCheck[i][1] > 0 .And. aTMPCheck[i][2] == "101"
                    EEQ->(DbGoTo(aTMPCheck[i][1]))
                    If EEQ->EEQ_VL <> aTMPCheck[i][3]            
                        aAdd(aFat3Alt,aTMPCheck[i][4])
                    EndIf                
                    EndIf
                Next i
                RestOrd(aOrdEEQTMP,.T.)
            EndIf   

        EndIf
    Else
       // Tratamentos para a opção de alteração.



    EndIf

End Sequence

RestOrd(aOrd)

Return lRet

/*
Função      : Af201DelDiscount().
Parametros  : Nenhum.
Objetivo    : Realizar o inclusão do valor do desconto excluído nas parcelas com o evento "pai".
Retorno     : .t./.f.
Autor       : Jeferson Barros Jr.
Data/Hora   : 26/10/04 - 18:21.
Obs         :
*/
*-------------------------*
Function Af201DelDiscount()
*-------------------------*
Local lRet := .t., aOrd:=SaveOrd("TMP")
Local cEventAux, cNumParc, cMoeda
Local nSldToAdd := 0
Local aTMPCheck  := {}
Local aOrdEEQTMP := {}
Local i
Local lParVinLiq   := .F.
Local nCGRAFI := 0
Local nADEDUZ := 0
Local nAREMET := 0
Private lSeekLast := .T.//RMD - 31/10/18 - Define se a verificação ocorrerá em ordem decrescente (.T.) ou crescente (.F.).

Begin Sequence

    nPos := aScan(aDiscount,{|x| x[1] == Tmp->EEQ_EVENT})
    If nPos <> 0
       cEventAux := aDiscount[nPos][2]
    Else
       // Verifica no(s) mv(s) de dependências qual é o evento "pai".
       cEventAux := Af201EventPai(cEvent)
    EndIf

    nSldToAdd := Tmp->EEQ_VL
    cMoeda    := Tmp->EEQ_MOEDA
    cFINNUM   := TMP->EEQ_FINNUM //RMD - 05/10/17
    cParcVin  := TMP->EEQ_ORIGEM //RMD - 12/03/17
    cOrigem   := TMP->EEQ_PARVIN
    nCGRAFI   := TMP->EEQ_CGRAFI
    nADEDUZ   := TMP->EEQ_ADEDUZ
    nAREMET   := TMP->EEQ_AREMET

    Tmp->(DbSetOrder(4))

    If EasyEntryPoint("EECAF201")
        ExecBlock("EECAF201", .f., .f., "AF201DELDISCOUNT")
    EndIf

    If Tmp->(If(lSeekLast, AvSeekLast(cEventAux), DbSeek(cEventAux)))
       Do While Tmp->(If(lSeekLast, !Bof(), !Eof())) .And. Tmp->EEQ_EVENT == cEventAux .And. (nSldToAdd > 0)

          // ** Desconsidera as parcelas liquidadas.
          //If !Empty(Tmp->EEQ_PGT)
          //RMD - 31/10/18 - Se tiver data de crédito no exterior, não deve associar independente da modalidade
          If !Empty(TMP->EEQ_DTCE) .Or. !Empty(TMP->EEQ_PGT)
             Tmp->(DbSkip(If(lSeekLast, -1, Nil)))
             Loop
          EndIf

          // ** Desconsidera as parcelas com moeda diferente da moeda do desconto.
          If cMoeda <> Tmp->EEQ_MOEDA
             Tmp->(DbSkip(If(lSeekLast, -1, Nil)))
             Loop
          EndIf

          //RMD - 05/10/17 - Sempre retorna o saldo para a parcela de origem
          If !Empty(cParcVin) .And. TMP->EEQ_PARC <> cParcVin
             Tmp->(DbSkip(If(lSeekLast, -1, Nil)))
             Loop
          EndIf

          If cEventAux == EV_PRINC2
             // ** Verifica se a parcela possui vinculação com o EF3.
             If EF3->(DbSeek(xFilial("EF3")+If(lEFFTpMod,IF(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),"")+Tmp->EEQ_NRINVO+Tmp->EEQ_PARC)) //HVR SEEK I OU E
                Tmp->(DbSkip(If(lSeekLast, -1, Nil)))
                Loop
             EndIf
          EndIf

          // ** Adiciona o valor da parcela de desconto excluída.
          Tmp->EEQ_VL     += nSldToAdd
          TMP->EEQ_CGRAFI += nCGRAFI
          TMP->EEQ_ADEDUZ += nADEDUZ
          TMP->EEQ_AREMET += nAREMET
          nSldToAdd       := 0

          If cEventAux == EV_PRINC2
             /* Atualiza o valor de fechamento de câmbio considerando os valores vinculados para
                cada tipo de comissão. */
             Af201SetVlFCam("TMP")
          EndIf
          If !TMP->(DELETED())
             aAdd(aTMPCheck,{TMP->TMP_RECNO, TMP->EEQ_EVENT, TMP->EEQ_VL, TMP->(Recno())})
          EndIf
          Tmp->(DbSkip(If(lSeekLast, -1, Nil)))
       EndDo
       
       If Type("aFat3Alt") == "A" .And. Len(aTMPCheck) > 0
          aOrdEEQTMP := SaveOrd({"EEQ","TMP"})
          For i:=1 To Len(aTMPCheck)
             If aTMPCheck[i][1] > 0 .And. aTMPCheck[i][2] == "101"
                EEQ->(DbGoTo(aTMPCheck[i][1]))
                If EEQ->EEQ_VL <> aTMPCheck[i][3]            
                   aAdd(aFat3Alt,aTMPCheck[i][4])
                EndIf                
             EndIf
          Next i
          RestOrd(aOrdEEQTMP,.T.)
       EndIf 
          
    EndIf

    // O valor da parcela de desconto não foi adicionado nas parcelas já existentes
    If nSldToAdd > 0

       Tmp->(DbSetOrder(1))
       If TMP->(dbSeek(cParcVin)) .And. !Empty(TMP->EEQ_PGT)
           lParVinLiq := .T.
       EndIf

       Tmp->(dbGoBottom())

       cNumParc := TMP->EEQ_PARC

       Tmp->(DbAppend())
       If TMP->(FieldPos("EEQ_FILIAL")) > 0   //NCF - 07/08/2017
          Tmp->EEQ_FILIAL := xFilial("EEQ")
       EndIf
       If TMP->(FieldPos("EEQ_PREEMB")) > 0
          Tmp->EEQ_PREEMB := EEC->EEC_PREEMB
       EndIf
       If (EasyGParam("MV_EEC0042",,.F.) .Or. AvFlags("EEC_LOGIX")) .And. !lParVinLiq //THTS - 29/03/2018
          TMP->EEQ_PARC   := cParcVin//RMD - 05/10/17 - Devolve os dados para a parcela original (que havia sido excluída)
       Else
          Tmp->EEQ_PARC   := SomaIt(cNumParc)
       EndIF
       Tmp->EEQ_EVENT  := cEventAux
       Tmp->EEQ_VCT    := dDataBase
       Tmp->EEQ_VL     := nSldToAdd
       TMP->EEQ_CGRAFI := nCGRAFI
       TMP->EEQ_ADEDUZ := nADEDUZ
       TMP->EEQ_AREMET := nAREMET       
       Tmp->EEQ_MOEDA  := EEC->EEC_MOEDA
       Tmp->EEQ_PARI   := 1
       /* RMD - 12/03/18 - A parcela do adiantamento deve referenciar a parcela original (101) pra viabilizar a identificação do título e posterior estorno
       Tmp->EEQ_PARVIN := Tmp->EEQ_PARC
       Tmp->EEQ_ORIGEM := ""
       */
       Tmp->EEQ_ORIGEM := cOrigem
       Tmp->EEQ_PARVIN := cOrigem
       Tmp->EEQ_TIPO   := "R"
       Tmp->EEQ_EMISSA := EEC->EEC_DTEMBA
       
       Tmp->EEQ_TIPO   := "R"
       
       //RMD - 05/10/17 - Guarda os dados do título de origem
       If EECFlags("TIT_PARCELAS") .or. EECFlags("ALT_EASYLINK")
          TMP->EEQ_FINNUM := cFINNUM
       EndIf

       Af201SetVlFCam("TMP")
       nSldToAdd := 0
    EndIf

End Sequence

RestOrd(aOrd,.t.)

Return lRet

/*
Função      : AF201PES()
Parametros  : Nenhum.
Objetivo    : Realizar pesquisas padrões e pesquisas por Contrato, R.E., S.D.
Retorno     : Nenhum.
Autor       : Alessandro Alves Ferreira
Data/Hora   : 18/01/05 - 16:35
Obs         :
*/
Function AF201PES()
Local i, lOk := .F.
Local aOrd   := SaveOrd( {"EE9","EF3","EF1","EEM","SX3","SIX","EEQ"} )
Local lRet   := .F.
Static oDlg, oDlg2
Static aOldInds := {}
Static aInds    := {}, aAllInds := {}//RMD - As posições de aInds não correspondem com a ordem do dicionário, portanto será utilizando um array auxiliar (aAllInds)
Private cChave  := ""
Private cInd    := ""
Private aCampos := {}
Private nLin    := 03
Private nLinGet := 0
Private oScrBox
Private oButton1,oButton2,oButton3
SX3->( dbSetOrder(2) )   //TRP-21/02/08
Private lMultiFil := Posicione("SX2",1,"EEC","X2_MODO") == "E" .AND. VerSenha(115) .AND. Posicione("SX2",1,"EF1","X2_MODO") == "C" .AND.;
                     SX3->(DbSeek("EF3_FILORI"))
Private lOutras := Len(aInds) == 6

Private lEF3FILORI:= SX3->( dbSeek("EF3_FILORI") )
Private cFil

//Recebe as filiais que o usuário possui acesso.
aFiliais := AvgSelectFil(.F.,"EEC")
aFilNames:= AvgFilName(aFiliais,.T.)

//Adiciona opção de todas as filiais.
aAdd(aFilNames,NIL)
aIns(aFilNames,1)
aFilNames[1] := STR0065//"Todas"

Do While .T.
   lRet := .F.
   lOk  := .F.
   nLin := 03
   nLinGet := 0

   If Len(aInds) == 0
      //Carrega as pesquisas padrões do dicionário
      SIX->( dbSetOrder(1) )
      SIX->( dbSeek("EEC") )
      Do While !SIX->( EoF() ) .AND. SIX->INDICE == "EEC"
         If SIX->SHOWPESQ == "S"
            aAdd(aInds  ,SIX->DESCRICAO)
            aAdd(aCampos,SIX->CHAVE)
         Endif
         aAdd(aAllInds, SIX->DESCRICAO)
         SIX->( dbSkip() )
      EndDo
   Endif

   If !lOutras
      DEFINE MSDIALOG oDlg TITLE STR0072 FROM 0,0 TO 110,407 OF oMainWnd PIXEL//"Pesquisa"
   Else
      DEFINE MSDIALOG oDlg2 TITLE STR0071 FROM /*255,255 TO 365,662*/ oDlg:nLeft+10,oDlg:nTop+10 TO oDlg:nLeft+110+10,oDlg:nTop+407+10  OF oMainWnd PIXEL//"Outras Pesquisas"
   Endif

   cChave := Space(60)

   //Seleção de Filiais
   If lMultiFil
      @ 03, 03 SAY STR0073 Pixel Size 170,6//"Filial:"
      @ 03, 30 ComboBox oCmb Var cFil Items aFilNames Pixel Size 170,6
      nLin+= 9
   Endif

   nLin+= 03
   @ nLin, 03 SAY STR0072+":" Pixel Size 170,6//"Pesquisa:"
   @ nLin, 30 ComboBox oCmb2 Var cInd Items aInds On Change iIF(lOutras,AF201ChgPes(),.T.) Pixel Size 170,6
   nLin+= 12
   @ nLin, 03 SAY STR0074 Pixel Size 170,6//"Chave:"
   @ nLin, 30 MsGet cChave Pixel Size 170,6
   nLinGet := nLin
   nLin+= 12

   DEFINE SBUTTON oButton1 FROM nLin,03 TYPE 1 ACTION (lOk:= .T.,If(lOutras,oDlg2,oDlg):End()) ENABLE
   DEFINE SBUTTON oButton2 FROM nLin,35 TYPE 2 ACTION (If(lOutras,oDlg2,oDlg):End())           ENABLE

   If !lOutras
      @ nLin,67 BUTTON STR0071 SIZE 60,12 ACTION (If(AF201NewPes(),oDlg:End(),)) of oDlg Pixel//"Outras Pesquisas"
   Endif

   If lOutras
      ACTIVATE MSDIALOG oDlg2
   Else
      ACTIVATE MSDIALOG oDlg CENTERED
   Endif

   If lOk
//      If cInd == STR0071 //"Outras Pesquisas"
//         //Pesquisas Padrões do dicionário
//         AxPesqui("EEC")
//      Else
      MsAguarde({||lRet:= AF201Procura()},STR0075)//"Aguarde... Pesquisando..."
//      Endif
      If lRet .or. !lOutras
         Exit
      EndIf
   Else
      Exit
   Endif

EndDo

If !lOutras
   RestOrd(aOrd,.T.)
   //EEC->( dbSetOrder(1) ) - BHF - 04/07/08
   aInds := {}
Else
   aInds := aOldInds
Endif

Return lRet

/*
Função      : AF201NewPes()
Parametros  : Nenhum.
Objetivo    : Abrir tela com novas pesquisas
Retorno     : Nenhum.
Autor       : Alessandro Alves Ferreira
Data/Hora   : 26/01/05 - 11:50
Obs         :
*/
Function AF201NewPes()

aOldInds := aClone(aInds)

//Novas Pesquisas
aInds := {}
aAdd(aInds,STR0078)//"Pesquisa por Invoice"
aAdd(aInds,STR0066)//"Pesquisa por Contrato de Câmbio"
aAdd(aInds,STR0067)//"Pesquisa por R.E."
aAdd(aInds,STR0068)//"Pesquisa por S.D."
aAdd(aInds,STR0069)//"Pesquisa por N.F."
aAdd(aInds,STR0070)//"Pesquisa por Status"
//aAdd(aInds,STR0071)//"Outras Pesquisas"

lRet := AF201PES()

Return lRet

/*
Função      : AF201ChgPes()
Parametros  : Nenhum.
Objetivo    : Trocar a picture do campo de pesquisa, dependendo do tipo de pesquisa.
Retorno     : Nenhum.
Autor       : Alessandro Alves Ferreira
Data/Hora   : 18/01/05 - 16:35
Obs         :
*/
Function AF201ChgPes()
Local cPict   := ""
Local nPosInd := aScan(aInds,cInd)

If nPosInd < Len(aInds)
   If cInd == STR0066//"Pesquisa por Contrato de Câmbio"
      cPict := AvSx3("EF3_CONTRA",AV_PICTURE)
   ElseIf cInd == STR0067//"Pesquisa por R.E."
      cPict := AvSx3("EE9_RE"    ,AV_PICTURE)
   ElseIf cInd == STR0068//"Pesquisa por S.D."
      cPict := AvSx3("EE9_NRSD"  ,AV_PICTURE)
   ElseIf cInd == STR0069//"Pesquisa por N.F."
      cPict := AvSx3("EEM_NRNF"  ,AV_PICTURE)
   ElseIf cInd == STR0070//"Pesquisa por Status"
      cPict := AvSx3("EEC_STTDES",AV_PICTURE)
   Endif
Endif

@ nLinGet, 30 MsGet cChave Picture cPict Pixel Size 170,6

Return .T.

/*
Função      : AF201Procura()
Parametros  : Nenhum.
Objetivo    : Realizar pesquisas padrões e pesquisas por Contrato, R.E., S.D.
Retorno     : Nenhum.
Autor       : Alessandro Alves Ferreira
Data/Hora   : 18/01/05 - 16:35
Obs         :
*/
Function AF201Procura()
Local i
Local lRet     := .T.
Private aHeader:= {}
Private aCols  := {}

If (nPosInd := aScan(aAllInds, cInd)) == 0//RMD - 04/06/08
   nPosInd:= aScan(aInds    ,cInd)
EndIf

//nPosInd:= aScan(aInds    ,cInd)
nPosFil:= aScan(aFilNames,cFil)

//Altera Filial para a filiais selecionada
If nPosFil > 1
   aFiliais := {aFiliais[nPosFil-1]}
Endif

If !lOutras //<= Len(aInds) - 5

   If !Empty(cChave)
      EEC->( dbSetOrder(nPosInd) )
      If nPosInd = 2 .or. nPosInd = 4 .or. nPosInd = 12
         cChave := DtoS(CtoD(Alltrim(cChave)))
      ElseIf nPosInd = 5
         cChave := Left(Alltrim(cChave),1) + DtoS(CtoD(Right(Alltrim(cChave),8)))
      EndIf
      For i:= 1 To Len(aFiliais)
         If EEC->( dbSeek(aFiliais[i]+Alltrim(cChave)) )
            aAdd(aCols,NIL)
            EXIT
         EndIf
      Next
   ElseIf Len(aFiliais) = 1
      If EEC->( dbSeek(aFiliais[1]) )
         aAdd(aCols,NIL)
      EndIf
   Endif

Endif

If cInd == "Pesquisa por Invoice"
   If lMultiFil
      aAdd(aHeader,{AVSX3("EEQ_FILIAL",5),"EEQ_FILIAL",AVSX3("EEQ_FILIAL",6),AVSX3("EEQ_FILIAL",3)+20,AVSX3("EEQ_FILIAL",4),nil,nil,AVSX3("EEQ_FILIAL",2),nil,nil })
   EndIf

   aAdd(aHeader,{AVSX3("EEQ_PREEMB",5),"EEQ_PREEMB",AVSX3("EEQ_PREEMB",6),AVSX3("EEQ_PREEMB",3),AVSX3("EEQ_PREEMB",4),nil,nil,AVSX3("EEQ_PREEMB",2),nil,nil })

   If Empty(cChave)
      aAdd(aHeader,{AVSX3("EEQ_NRINVO",5),"EEQ_NRINVO",AVSX3("EEQ_NRINVO",6),AVSX3("EEQ_NRINVO",3),AVSX3("EEQ_NRINVO",4),nil,nil,AVSX3("EEQ_NRINVO",2),nil,nil })
      aAdd(aHeader,{AVSX3("EEQ_PARC",5)  ,"EEQ_PARC"  ,AVSX3("EEQ_PARC",6)  ,AVSX3("EEQ_PARC",3)  ,AVSX3("EEQ_PARC",4)  ,nil,nil,AVSX3("EEQ_PARC",2)  ,nil,nil })
      aAdd(aHeader,{AVSX3("EEQ_MOEDA",5) ,"EEQ_MOEDA" ,AVSX3("EEQ_MOEDA",6) ,AVSX3("EEQ_MOEDA",3) ,AVSX3("EEQ_MOEDA",4) ,nil,nil,AVSX3("EEQ_MOEDA",2) ,nil,nil })
      aAdd(aHeader,{AVSX3("EEQ_VL",5)    ,"EEQ_VL"    ,AVSX3("EEQ_VL",6)    ,AVSX3("EEQ_VL",3)    ,AVSX3("EEQ_VL",4)    ,nil,nil,AVSX3("EEQ_VL",2)    ,nil,nil })
      aAdd(aHeader,{AVSX3("EEQ_BANC",5)  ,"EEQ_BANC"  ,AVSX3("EEQ_BANC",6)  ,AVSX3("EEQ_BANC",3)  ,AVSX3("EEQ_BANC",4)  ,nil,nil,AVSX3("EEQ_BANC",2)  ,nil,nil })
   Else
      aAdd(aHeader,{AVSX3("EEQ_NRINVO",5),"EEQ_NRINVO",AVSX3("EEQ_NRINVO",6),AVSX3("EEQ_NRINVO",3),AVSX3("EEQ_NRINVO",4),nil,nil,AVSX3("EEQ_NRINVO",2),nil,nil })
   Endif

   cFilOld := cFilAnt
   For i:= 1 To Len(aFiliais)
      cFilAnt := aFiliais[i] //Seta a Filial de Retorno do xFilial.
      cFilEEQ := xFilial("EEQ")
      cFilEF3 := xFilial("EF3")
      cFilEF1 := xFilial("EF1")

      If Empty(cChave)
         EEQ->( dbSetOrder(5) )
         //cChave := SubStr(cChave,1,AVSX3("EEQ_NRINVO",3))

         EEQ->( dbSeek(cFilEEQ) )
         Do While !EEQ->( EoF() ) .AND. EEQ->( EEQ_FILIAL ) == cFilEEQ
            If EEQ->EEQ_EVENT == '101'
               aAdd(aCols,Array(Len(aHeader)+1))
               nI:= 1

               If lMultiFil
                  aCols[Len(aCols)][nI++] := aFilNames[i+1]
               Endif

               aCols[Len(aCols)][nI++] := EEQ->EEQ_PREEMB
               aCols[Len(aCols)][nI++] := EEQ->EEQ_NRINVO
               aCols[Len(aCols)][nI++] := EEQ->EEQ_PARC
               aCols[Len(aCols)][nI++] := EEQ->EEQ_MOEDA
               aCols[Len(aCols)][nI++] := EEQ->EEQ_VL
               aCols[Len(aCols)][nI++] := EEQ->EEQ_BANC

               aCols[Len(aCols)][Len(aHeader)+1] := .F.
            Endif

            EEQ->( dbSkip() )
         EndDo
      Else
         EEQ->( dbSetOrder(5) )
         cChave := SubStr(cChave,1,AVSX3("EEQ_NRINVO",3))

         EEQ->( dbSeek(cFilEEQ+cChave+'101') )
         cUltEmb:= ""
         Do While !EEQ->( EoF() ) .AND. EEQ->( EEQ_FILIAL+EEQ_NRINVO+EEQ_EVENT ) == cFilEEQ+cChave+'101'
            If EEQ->EEQ_PREEMB <> cUltEmb
               aAdd(aCols,Array(Len(aHeader)+1))
               nI:= 1

               If lMultiFil
                  aCols[Len(aCols)][nI++] := aFilNames[i+1]
               Endif

               aCols[Len(aCols)][nI++] := EEQ->EEQ_PREEMB
               aCols[Len(aCols)][nI++] := EEQ->EEQ_NRINVO

               aCols[Len(aCols)][Len(aHeader)+1] := .F.
            Endif

            cUltEmb:= EEQ->EEQ_PREEMB
            EEQ->( dbSkip() )
         EndDo
      Endif
   Next
   cFilAnt := cFilOld //Volta a Filial Original.

ElseIf cInd == STR0066//"Pesquisa por Contrato de Câmbio"

   If lMultiFil
      aAdd(aHeader,{AVSX3("EEC_FILIAL",5),"EEC_FILIAL",AVSX3("EEC_FILIAL",6),AVSX3("EEC_FILIAL",3)+20,AVSX3("EEC_FILIAL",4),nil,nil,AVSX3("EEC_FILIAL",2),nil,nil })
   EndIf

   aAdd(aHeader,{AVSX3("EEC_PREEMB",5),"EEC_PREEMB",AVSX3("EEC_PREEMB",6),AVSX3("EEC_PREEMB",3),AVSX3("EEC_PREEMB",4),nil,nil,AVSX3("EEC_PREEMB",2),nil,nil })

   If Empty(cChave)
      aAdd(aHeader,{AVSX3("EEC_NRINVO",5),"EEC_NRINVO",AVSX3("EEC_NRINVO",6),AVSX3("EEC_NRINVO",3),AVSX3("EEC_NRINVO",4),nil,nil,AVSX3("EEC_NRINVO",2),nil,nil })
      aAdd(aHeader,{AVSX3("EEQ_PARC",5)  ,"EEQ_PARC"  ,AVSX3("EEQ_PARC",6)  ,AVSX3("EEQ_PARC",3)  ,AVSX3("EEQ_PARC",4)  ,nil,nil,AVSX3("EEQ_PARC",2)  ,nil,nil })
      aAdd(aHeader,{AVSX3("EF1_BAN_FI",5),"EF1_BAN_FI",AVSX3("EF1_BAN_FI",6),AVSX3("EF1_BAN_FI",3),AVSX3("EF1_BAN_FI",4),nil,nil,AVSX3("EF1_BAN_FI",2),nil,nil })
      aAdd(aHeader,{AVSX3("EF3_CONTRA",5),"EF3_CONTRA",AVSX3("EF3_CONTRA",6),AVSX3("EF3_CONTRA",3),AVSX3("EF3_CONTRA",4),nil,nil,AVSX3("EF3_CONTRA",2),nil,nil })
      aAdd(aHeader,{AVSX3("EEC_MOEDA",5) ,"EEC_MOEDA" ,AVSX3("EEC_MOEDA",6) ,AVSX3("EEC_MOEDA",3) ,AVSX3("EEC_MOEDA",4) ,nil,nil,AVSX3("EEC_MOEDA",2) ,nil,nil })
      aAdd(aHeader,{AVSX3("EF3_VL_MOE",5),"EF3_VL_MOE",AVSX3("EF3_VL_MOE",6),AVSX3("EF3_VL_MOE",3),AVSX3("EF3_VL_MOE",4),nil,nil,AVSX3("EF3_VL_MOE",2),nil,nil })
   Else
      aAdd(aHeader,{AVSX3("EF3_CONTRA",5),"EF3_CONTRA",AVSX3("EF3_CONTRA",6),AVSX3("EF3_CONTRA",3),AVSX3("EF3_CONTRA",4),nil,nil,AVSX3("EF3_CONTRA",2),nil,nil })
   Endif

   cFilOld := cFilAnt
   For i:= 1 To Len(aFiliais)
      cFilAnt := aFiliais[i] //Seta a Filial de Retorno do xFilial.
      cFilEEC := xFilial("EEC")
      cFilEEQ := xFilial("EEQ")
      cFilEF3 := xFilial("EF3")
      cFilEF1 := xFilial("EF1")

      If Empty(cChave)
         EEC->( dbSetOrder(1) )
         EEQ->( dbSetOrder(5) )
         EF1->( dbSetOrder(1) )
         EF3->( dbSetOrder(3) )

         EEC->( dbSeek(cFilEEC) )
         Do While !EEC->( EoF() ) .AND. EEC->EEC_FILIAL == cFilEEC
            EEQ->( dbSeek(cFilEEQ+EEC->EEC_NRINVO+'101') )
            Do While !EEQ->( EoF() ) .AND. EEQ->( EEQ_FILIAL+EEQ_NRINVO+EEQ_EVENT ) == cFilEEQ+EEC->EEC_NRINVO+'101'
               //** GFC - 01/12/05 - Nos loops do EEQ verificar se o processo do eeq é o mesmo do eec
               If EEQ->EEQ_PREEMB <> EEC->EEC_PREEMB
                  EEQ->(dbSkip())
                  Loop
               EndIf
               //**

               EF3->( dbSeek(cFilEF3+If(lEFFTpMod,IF(EEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+EEQ->EEQ_NRINVO+EEQ->EEQ_PARC+'600') ) //HVR SEEK I OU E
               Do While !EF3->( EoF() ) .AND. EF3->( EF3_FILIAL+If(lEFFTpMod,EF3_TPMODU,"")+EF3_INVOIC+EF3_PARC+EF3_CODEVE ) == EEQ->( cFilEF3+If(lEFFTpMod,IF(EEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+EEQ_NRINVO+EEQ_PARC+'600' ) //HVR SEEK I OU E
                  If !lEF3FILORI .OR. EF3->EF3_FILORI == cFilEEQ
                     EF1->( dbSeek(cFilEF1+If(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3->EF3_CONTRA) ) //HVR SEEK I OU E

                     aAdd(aCols,Array(Len(aHeader)+1))
                     nI:= 1

                     If lMultiFil
                        aCols[Len(aCols)][nI++] := aFilNames[i+1]
                     Endif

                     aCols[Len(aCols)][nI++] := EEC->EEC_PREEMB
                     aCols[Len(aCols)][nI++] := EEC->EEC_NRINVO
                     aCols[Len(aCols)][nI++] := EEQ->EEQ_PARC
                     aCols[Len(aCols)][nI++] := EF1->EF1_BAN_FI+" - "+Posicione("SA6",1,xFilial("SA6")+EF1->EF1_BAN_FI,"A6_NOME")
                     aCols[Len(aCols)][nI++] := EF3->EF3_CONTRA
                     aCols[Len(aCols)][nI++] := EEC->EEC_MOEDA
                     aCols[Len(aCols)][nI++] := EF3->EF3_VL_MOE

                     aCols[Len(aCols)][Len(aHeader)+1] := .F.

                  Endif
                  EF3->( dbSkip() )
               EndDo
               EEQ->( dbSkip() )
            EndDo
            EEC->( dbSkip() )
         EndDo
      Else
         EF3->( dbSetOrder(1) )
         EF3->( dbSeek(cFilEF3+If(lEFFTpMod,"E","")+SubStr(cChave,1,AVSX3("EF3_CONTRA",3))) )
         Do While !EF3->( EoF() ) .AND. EF3->( EF3_FILIAL+If(lEFFTpMod,EF3_TPMODU,"")+EF3_CONTRA ) == cFilEF3+If(lEFFTpMod,"E","")+SubStr(cChave,1,AVSX3("EF3_CONTRA",3))
            If EF3->EF3_CODEVE == '600' .AND. (!lEF3FILORI .OR. EF3->EF3_FILORI == cFilEEQ) .AND. aScan(aCols,{|X| iIF(lMultiFil,X[1]+X[2] == aFilNames[i+1]+EF3->EF3_PREEMB,;
                                                                                                  X[1] == EF3->EF3_PREEMB)}) == 0
               EF1->( dbSeek(cFilEF1+If(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3->EF3_CONTRA) ) //HVR SEEK I OU E

               aAdd(aCols,Array(Len(aHeader)+1))
               nI:= 1

               If lMultiFil
                  aCols[Len(aCols)][nI++] := aFilNames[i+1]
               Endif

               aCols[Len(aCols)][nI++] := EF3->EF3_PREEMB
               //aCols[Len(aCols)][nI++] := EF3->EF3_INVOIC
               //aCols[Len(aCols)][nI++] := EF3->EF3_PARC
               //aCols[Len(aCols)][nI++] := EF1->EF1_BAN_FI+" - "+Posicione("SA6",1,xFilial("SA6")+EF1->EF1_BAN_FI,"A6_NOME")
               aCols[Len(aCols)][nI++] := EF3->EF3_CONTRA

               aCols[Len(aCols)][Len(aHeader)+1] := .F.
            Endif
            EF3->( dbSkip() )
         EndDo

      Endif

   Next
   cFilAnt := cFilOld //Volta a Filial Original.

ElseIf cInd == STR0067//"Pesquisa por R.E."

   IndRegua("EE9","AF201EE9"+TEOrdBagExt(),"EE9_FILIAL+EE9_RE")

   If lMultiFil
      aAdd(aHeader,{AVSX3("EEC_FILIAL",5),"EEC_FILIAL",AVSX3("EEC_FILIAL",6),AVSX3("EEC_FILIAL",3)+20,AVSX3("EEC_FILIAL",4),nil,nil,AVSX3("EEC_FILIAL",2),nil,nil })
   EndIf

   aAdd(aHeader,{AVSX3("EEC_PREEMB",5),"EEC_PREEMB",AVSX3("EEC_PREEMB",6),AVSX3("EEC_PREEMB",3),AVSX3("EEC_PREEMB",4),nil,nil,AVSX3("EEC_PREEMB",2),nil,nil })

   If Empty(cChave)
      aAdd(aHeader,{AVSX3("EE9_DTRE",5)  ,"EE9_DTRE"  ,AVSX3("EE9_DTRE",6)  ,AVSX3("EE9_DTRE",3)  ,AVSX3("EE9_DTRE",4)  ,nil,nil,AVSX3("EE9_DTRE",2)  ,nil,nil })
   Endif

   aAdd(aHeader,{AVSX3("EE9_RE",5)    ,"EE9_RE"    ,AVSX3("EE9_RE",6)    ,AVSX3("EE9_RE",3)    ,AVSX3("EE9_RE",4)    ,nil,nil,AVSX3("EE9_RE",2)    ,nil,nil })

   cFilOld := cFilAnt
   For i:= 1 To Len(aFiliais)
      cFilAnt := aFiliais[i] //Seta a Filial de Retorno do xFilial.
      cFilEE9 := xFilial("EE9")

      If !Empty(cChave)

         EE9->( dbSeek(cFilEE9+SubStr(cChave,1,AVSX3("EE9_RE",3)) ) )
         Do While !EE9->( EoF() ) .AND. EE9->( EE9_FILIAL+EE9_RE ) == cFilEE9+SubStr(cChave,1,AVSX3("EE9_RE",3))
            If aScan(aCols,{|X| iIF(lMultiFil,X[1]+X[2]==aFilNames[i+1]+EE9->EE9_PREEMB,X[1]==EE9->EE9_PREEMB)}) == 0
               aAdd(aCols,Array(Len(aHeader)+1))
               nI:= 1

               If lMultiFil
                  aCols[Len(aCols)][nI++] := aFilNames[i+1]
               Endif

               aCols[Len(aCols)][nI++] := EE9->EE9_PREEMB
               //aCols[Len(aCols)][nI++] := EE9->EE9_DTRE
               aCols[Len(aCols)][nI++] := EE9->EE9_RE

               aCols[Len(aCols)][Len(aHeader)+1] := .F.

            Endif
            EE9->( dbSkip() )
         EndDo
      Else
         EE9->( dbSeek(cFilEE9) )
         Do While !EE9->( EoF() ) .AND. EE9->EE9_FILIAL == cFilEE9
            If !Empty(EE9->EE9_RE) .AND.;
               aScan(aCols,{|X| iIF(lMultiFil,X[1]+X[2]+X[4]==aFilNames[i+1]+EE9->EE9_PREEMB+EE9->EE9_RE,;
                                              X[1]+X[3]==EE9->EE9_PREEMB+EE9->EE9_RE)}) == 0

               aAdd(aCols,Array(Len(aHeader)+1))
               nI:= 1

               If lMultiFil
                  aCols[Len(aCols)][nI++] := aFilNames[i+1]
               Endif

               aCols[Len(aCols)][nI++] := EE9->EE9_PREEMB
               aCols[Len(aCols)][nI++] := EE9->EE9_DTRE
               aCols[Len(aCols)][nI++] := EE9->EE9_RE

               aCols[Len(aCols)][Len(aHeader)+1] := .F.

            Endif
            EE9->( dbSkip() )
         EndDo
      Endif
   Next
   cFilAnt := cFilOld //Volta a Filial Original.

   E_EraseArq("AF201EE9")

ElseIf cInd == STR0068//"Pesquisa por S.D."
   IndRegua("EE9","AF201EE9"+TEOrdBagExt(),"EE9_FILIAL+EE9_NRSD")

   If lMultiFil
      aAdd(aHeader,{AVSX3("EEC_FILIAL",5),"EEC_FILIAL",AVSX3("EEC_FILIAL",6),AVSX3("EEC_FILIAL",3)+20,AVSX3("EEC_FILIAL",4),nil,nil,AVSX3("EEC_FILIAL",2),nil,nil })
   EndIf

   aAdd(aHeader,{AVSX3("EEC_PREEMB",5),"EEC_PREEMB",AVSX3("EEC_PREEMB",6),AVSX3("EEC_PREEMB",3),AVSX3("EEC_PREEMB",4),nil,nil,AVSX3("EEC_PREEMB",2),nil,nil })

   If Empty(cChave)
      aAdd(aHeader,{AVSX3("EE9_DTAVRB",5),"EE9_DTAVRB",AVSX3("EE9_DTAVRB",6),AVSX3("EE9_DTAVRB",3),AVSX3("EE9_DTAVRB",4),nil,nil,AVSX3("EE9_DTAVRB",2),nil,nil })
   Endif

   aAdd(aHeader,{AVSX3("EE9_NRSD",5)  ,"EE9_NRSD"  ,AVSX3("EE9_NRSD",6)  ,AVSX3("EE9_NRSD",3)  ,AVSX3("EE9_NRSD",4)  ,nil,nil,AVSX3("EE9_NRSD",2)  ,nil,nil })

   cFilOld := cFilAnt
   For i:= 1 To Len(aFiliais)
      cFilAnt := aFiliais[i] //Seta a Filial de Retorno do xFilial.
      cFilEE9 := xFilial("EE9")

      If !Empty(cChave)

         EE9->( dbSeek(cFilEE9+SubStr(cChave,1,AVSX3("EE9_NRSD",3)) ) )
         Do While !EE9->( EoF() ) .AND. EE9->( EE9_FILIAL+EE9_NRSD ) == cFilEE9+SubStr(cChave,1,AVSX3("EE9_NRSD",3))
            If aScan(aCols,{|X| iIF(lMultiFil,X[1]+X[2]==aFilNames[i+1]+EE9->EE9_PREEMB,X[1]==EE9->EE9_PREEMB)}) == 0
               aAdd(aCols,Array(Len(aHeader)+1))
               nI:= 1

               If lMultiFil
                  aCols[Len(aCols)][nI++] := aFilNames[i+1]
               Endif

               aCols[Len(aCols)][nI++] := EE9->EE9_PREEMB
               If Empty(cChave)
                  aCols[Len(aCols)][nI++] := EE9->EE9_DTAVRB
               Endif
               aCols[Len(aCols)][nI++] := EE9->EE9_NRSD

               aCols[Len(aCols)][Len(aHeader)+1] := .F.

            Endif
            EE9->( dbSkip() )
         EndDo
      Else
         EE9->( dbSeek(cFilEE9) )
         Do While !EE9->( EoF() ) .AND. EE9->EE9_FILIAL == cFilEE9
            If !Empty(EE9->EE9_NRSD) .AND.;
               aScan(aCols,{|X| iIF(lMultiFil,X[1]+X[2]+X[4]==aFilNames[i+1]+EE9->EE9_PREEMB+EE9->EE9_NRSD,;
                                              X[1]+X[3]     ==EE9->EE9_PREEMB+EE9->EE9_NRSD)}) == 0

               aAdd(aCols,Array(Len(aHeader)+1))
               nI:= 1

               If lMultiFil
                  aCols[Len(aCols)][nI++] := aFilNames[i+1]
               Endif

               aCols[Len(aCols)][nI++] := EE9->EE9_PREEMB
               aCols[Len(aCols)][nI++] := EE9->EE9_DTAVRB
               aCols[Len(aCols)][nI++] := EE9->EE9_NRSD

               aCols[Len(aCols)][Len(aHeader)+1] := .F.

            Endif
            EE9->( dbSkip() )
         EndDo
      Endif
   Next
   cFilAnt := cFilOld //Volta a Filial Original.

   E_EraseArq("AF201EE9")

ElseIf cInd == STR0069//"Pesquisa por N.F."
   IndRegua("EEM","AF201EEM"+TEOrdBagExt(),"EEM_FILIAL+EEM_NRNF")

   If lMultiFil
      aAdd(aHeader,{AVSX3("EEC_FILIAL",5),"EEC_FILIAL",AVSX3("EEC_FILIAL",6),AVSX3("EEC_FILIAL",3)+20,AVSX3("EEC_FILIAL",4),nil,nil,AVSX3("EEC_FILIAL",2),nil,nil })
   EndIf

   aAdd(aHeader,{AVSX3("EEC_PREEMB",5),"EEC_PREEMB",AVSX3("EEC_PREEMB",6),AVSX3("EEC_PREEMB",3),AVSX3("EEC_PREEMB",4),nil,nil,AVSX3("EEC_PREEMB",2),nil,nil })

   If Empty(cChave)
      aAdd(aHeader,{AVSX3("EEM_TIPONF",5),"EEM_TIPONF",AVSX3("EEM_TIPONF",6),AVSX3("EEM_TIPONF",3),AVSX3("EEM_TIPONF",4),nil,nil,AVSX3("EEM_TIPONF",2),nil,nil })
      aAdd(aHeader,{AVSX3("EEM_DTNF",5)  ,"EEM_DTNF"  ,AVSX3("EEM_DTNF",6)  ,AVSX3("EEM_DTNF",3)  ,AVSX3("EEM_DTNF",4)  ,nil,nil,AVSX3("EEM_DTNF",2)  ,nil,nil })
   Endif

   aAdd(aHeader,{AVSX3("EEM_NRNF",5)  ,"EEM_NRNF"  ,AVSX3("EEM_NRNF",6)  ,AVSX3("EEM_NRNF",3)  ,AVSX3("EEM_NRNF",4)  ,nil,nil,AVSX3("EE9_DTAVRB",2),nil,nil })

   If Empty(cChave)
      aAdd(aHeader,{AVSX3("EEM_SERIE",5) ,"EEM_SERIE" ,AVSX3("EEM_SERIE",6) ,AVSX3("EEM_SERIE",3) ,AVSX3("EEM_SERIE",4) ,nil,nil,AVSX3("EEM_SERIE",2) ,nil,nil })
   Endif

   cFilOld := cFilAnt
   For i:= 1 To Len(aFiliais)
      cFilAnt := aFiliais[i] //Seta a Filial de Retorno do xFilial.
      cFilEEC := xFilial("EEC")
      cFilEEM := xFilial("EEM")

      If !Empty(cChave)

         EEM->( dbSeek(cFilEEM+SubStr(cChave,1,AVSX3("EEM_NRNF",3)) ) )
         Do While !EEM->( EoF() ) .AND. EEM->( EEM_FILIAL+EEM_NRNF ) == cFilEEM+SubStr(cChave,1,AVSX3("EEM_NRNF",3))
            If aScan(aCols,{|X| iIF(lMultiFil,X[1]+X[2]+[3]==aFilNames[i+1]+EEM->EEM_PREEMB+EEM->EEM_NRNF,X[1]+X[2]==EEM->EEM_PREEMB+EEM->EEM_NRNF)}) == 0
               aAdd(aCols,Array(Len(aHeader)+1))
               nI:= 1

               If lMultiFil
                  aCols[Len(aCols)][nI++] := aFilNames[i+1]
               Endif

               aCols[Len(aCols)][nI++] := EEM->EEM_PREEMB
               //aCols[Len(aCols)][nI++] := EEM->EEM_TIPONF
               aCols[Len(aCols)][nI++] := EEM->EEM_NRNF
               //aCols[Len(aCols)][nI++] := EEM->EEM_SERIE
               //aCols[Len(aCols)][nI++] := EEM->EEM_DTNF

               aCols[Len(aCols)][Len(aHeader)+1] := .F.
            Endif
            EEM->( dbSkip() )
         EndDo
      Else
         EEM->( dbSeek(cFilEEM) )
         Do While !EEM->( EoF() ) .AND. EEM->( EEM_FILIAL ) == cFilEEM
            aAdd(aCols,Array(Len(aHeader)+1))
            nI:= 1

            If lMultiFil
               aCols[Len(aCols)][nI++] := aFilNames[i+1]
            Endif

            aCols[Len(aCols)][nI++] := EEM->EEM_PREEMB
            aCols[Len(aCols)][nI++] := EEM->EEM_TIPONF
            aCols[Len(aCols)][nI++] := EEM->EEM_DTNF
            aCols[Len(aCols)][nI++] := EEM->EEM_NRNF
            aCols[Len(aCols)][nI++] := EEM->EEM_SERIE

            aCols[Len(aCols)][Len(aHeader)+1] := .F.

            EEM->( dbSkip() )
         EndDo
      Endif
   Next
   cFilAnt := cFilOld //Volta a Filial Original.

ElseIf cInd == STR0070//"Pesquisa por Status"
   IndRegua("EEC","AF201EEC"+TEOrdBagExt(),"EEC_FILIAL+EEC_STATUS")

   If lMultiFil
      aAdd(aHeader,{AVSX3("EEC_FILIAL",5),"EEC_FILIAL",AVSX3("EEC_FILIAL",6),AVSX3("EEC_FILIAL",3)+20,AVSX3("EEC_FILIAL",4),nil,nil,AVSX3("EEC_FILIAL",2),nil,nil })
   EndIf

   aAdd(aHeader,{AVSX3("EEC_PREEMB",5),"EEC_PREEMB",AVSX3("EEC_PREEMB",6),AVSX3("EEC_PREEMB",3),AVSX3("EEC_PREEMB",4),nil,nil,AVSX3("EEC_PREEMB",2),nil,nil })
   aAdd(aHeader,{AVSX3("EEC_STTDES",5),"EEC_STTDES",AVSX3("EEC_STTDES",6),25                   ,AVSX3("EEC_STTDES",4),nil,nil,AVSX3("EEC_STTDES",2),nil,nil })
   aAdd(aHeader,{AVSX3("EEC_DTPROC",5),"EEC_DTPROC",AVSX3("EEC_DTPROC",6),AVSX3("EEC_DTPROC",3),AVSX3("EEC_DTPROC",4),nil,nil,AVSX3("EEC_DTPROC",2),nil,nil })
   aAdd(aHeader,{AVSX3("EEC_IMPODE",5),"EEC_IMPODE",AVSX3("EEC_IMPODE",6),AVSX3("EEC_IMPODE",3),AVSX3("EEC_IMPODE",4),nil,nil,AVSX3("EEC_IMPODE",2),nil,nil })
   aAdd(aHeader,{AVSX3("EEC_DTEMBA",5),"EEC_DTEMBA",AVSX3("EEC_DTEMBA",6),AVSX3("EEC_DTEMBA",3),AVSX3("EEC_DTEMBA",4),nil,nil,AVSX3("EEC_DTEMBA",2),nil,nil })

   cFilOld := cFilAnt
   For i:= 1 To Len(aFiliais)

      cFilAnt := aFiliais[i] //Seta a Filial de Retorno do xFilial.
      cFilEEC := xFilial("EEC")
      cFilSX5 := xFilial("SX5")
      cStatus := " "
      cChave  := Trim(SubStr(cChave,1,Len(SX5->X5_DESCRI)))

      If !Empty(cChave)
         SX5->( dbSeek(cFilSX5+"YC") )
         Do While !SX5->( EoF() ) .AND. SX5->( X5_FILIAL+X5_TABELA ) == cFilSX5+"YC"

            If Upper(SubStr(SX5->X5_DESCRI,1,Len(cChave))) == Upper(cChave)
               cStatus := Trim(SX5->X5_CHAVE)
               Exit
            Endif

            SX5->( dbSkip() )
         EndDo
      Endif

      If !Empty(cStatus)
         EEC->( dbSeek(cFilEEC+cStatus) )
         Do While !EEC->( EoF() ) .AND. EEC->( EEC_FILIAL+EEC_STATUS ) == cFilEEC+cStatus
            aAdd(aCols,Array(Len(aHeader)+1))
            nI:= 1

            If lMultiFil
               aCols[Len(aCols)][nI++] := aFilNames[i+1]
            Endif

            aCols[Len(aCols)][nI++] := EEC->EEC_PREEMB
            aCols[Len(aCols)][nI++] := SX5->X5_DESCRI
            aCols[Len(aCols)][nI++] := EEC->EEC_DTPROC
            aCols[Len(aCols)][nI++] := EEC->EEC_IMPODE
            aCols[Len(aCols)][nI++] := EEC->EEC_DTEMBA

            aCols[Len(aCols)][Len(aHeader)+1] := .F.
            EEC->( dbSkip() )
         EndDo
      Else
         MsgInfo(STR0076)//"Status não Encontrado"
         Return .F.
      Endif
   Next
   cFilAnt := cFilOld //Volta a Filial Original.
Endif

If Len(aCols) > 0 .AND. aCols[1] <> NIL
   lRet := AF201Results()
ElseIf Len(aCols) == 0
   //MsgInfo(STR0078)//"Nenhum Registro foi encontrado"
   Help(" ",1,"CPOFILTER")
   lRet := .F.
Endif

Return lRet

/*
Função      : AF201Results()
Parametros  : Nenhum.
Objetivo    : Mostrar resultados da pesquisa.
Retorno     : Nenhum.
Autor       : Alessandro Alves Ferreira
Data/Hora   : 19/01/05 - 17:35
Obs         :
*/
Function AF201Results()
Local oGetDados
Local lOk:= .F.
Private oDlg3

DEFINE MSDIALOG oDlg3 TITLE STR0077 FROM 00,00 TO 400,682 OF oMainWnd PIXEL//"Resultados"

oGetDados := MsGetDados():New(13, 01, 202, 342, 2,/*LinOk*/,/*TudoOk*/,/*cIniCpos*/,.F.,{},/*reservado*/,/*lEmpty*/,1000,/*fieldok*/,/*superdel*/,/*Reservado*/,/*delok*/, oDlg2)
oGetDados:oBrowse:blDblClick:= {||lOK:= .T., oDlg3:End()}

ACTIVATE MSDIALOG oDlg3 ON INIT ENCHOICEBAR(oDlg3,{||lOk:= .T., oDlg3:End() },{||oDlg3:End()},,) CENTERED

If lOk
  EEC->( dbSetOrder(1) )
  EEC->( dbSeek(iIF(lMultiFil,aFiliais[aScan(aFilNames,aCols[n][1])-1]+aCols[n][2],xFilial("EEC")+aCols[n][1])) )
Endif

Return lOk

/*
Função      : AF201Adian()
Parametros  : Nenhum.
Objetivo    : Adiantamanto Pós-Embarque
Retorno     : Nenhum.
Autor       : Eduardo C. Romanini
Data/Hora   : 19/04/07 - 11:35
Obs         :
*/
*-------------------*
Function AF201Adian()
*-------------------*
Local lRet    := .T.
Local aOrd    := SaveOrd("EEQ")

Begin Sequence

   //Verifica se o Embarque já foi Embarcado.
   If Empty(EEC->EEC_DTEMBA)
      MsgInfo(STR0079,STR0005)//"Esse processo ainda não foi embarcado. Para essa opção utilize a manutenção de embarques."###"Atenção"
      lRet := .F.
      Break
   EndIf

   If !AvFlags("EEC_LOGIX") .And. EECFlags("ALT_EASYLINK") .And. !EasyGParam("MV_EEC0042",,.F.)
      MsgInfo(STR0088+;//"Não é possível a utilização da rotina de Adiantamento Pós-Embarque, pois o ambiente está configurado para manter a mesma numeração dos títulos a receber na alteração "
              STR0089+ENTER+""+ENTER+;//"e está com a compensação automática desabilidata."
              STR0090,STR0005)//"Para utilizar a rotina, habilite a compensação automática (MV_EEC0042)."###"Atenção"
      lRet := .F.
      Break
   EndIf

   //Verifica se Existe pelo menos uma Parcela de Câmbio não Liquidada
   //THTS - 04/04/2018 - NOPADO - Quando feita uma liquidacao e depois uma compensacao (parcelas com mesmo titulo e com logix), ao tentar estorar a liquidacao, o sistema exigia que fizesse primeiro
   //o estorno da compensação, porém a rotina de compensacao não deixava acessar após o embarque estar totalmente liquidado. 
/*   If EEC->EEC_STATUS == ST_CO
      EEQ->(DbSetOrder(1))
      If EEQ->(DbSeek(xFilial("EEQ")+EEC->EEC_PREEMB))
         While EEQ->(!EOF()) .and. EEQ->(EEQ_FILIAL + EEQ_PREEMB) == xFilial("EEQ")+EEC->EEC_PREEMB
            //Verifica se existe pelo menos uma parcela que não seja de adiantamento.
            If EEQ->EEQ_EVENT == "101" .and. EEQ->EEQ_FASE == "E" .and. EEQ->EEQ_TIPO <> "A"
               MsgInfo(STR0080,STR0005)//"Todas as parcelas já foram liquidadas. Não é possível vincular/excluir Adiantamentos."###"Atenção"
               lRet := .F.
               Break
            EndIf
            EEQ->(DbSkip())
         EndDo
      EndIf
   EndIf
*/
   AE100Adian(,,,,.F.)

End Sequence

RestOrd(aOrd)
Return

/*
Função      : AF201GrvTMP
Parametros  : Nenhum.
Objetivo    : Gerar e carregar a work TMP com as parcelas do EEQ
              para ser utilizada pela função AF201AddDiscount e AF201DelDiscount.
Retorno     : Nenhum.
Autor       : Eduardo C. Romanini
Data/Hora   : 19/04/07 - 11:35
Obs         :
*/
*-----------------------*
Function AF201GrvTMP()
*-----------------------*
Local aSemSX3 := {}, aCpo := {}
Local nZ := 0, cCpo := ""

Private aHeader[0]
Private aCampos := Array(EEQ->(FCount()))

Begin Sequence

   If Select("TMP") > 0
      Break
   EndIf

   AADD(aCpo,{"EEQ_DTVC","EEQ_VLVC","EEQ_ORIGEM","EEQ_FFC","EEQ_PREEMB","EEQ_FILIAL","EEQ_BANC","EEQ_FINNUM"})//RMD - 05/10/17 - Adiciona o EEQ_FINNUM se estiver como não usado.

   If EECFlags("FRESEGCOM")
      aAdd(aCpo[1],"EEQ_IMPORT") ; aAdd(aCpo[1],"EEQ_IMLOJA") ; AADD(aCpo[1],"EEQ_DESIMP")  // PLB 11/10/06 - DESIMP passou a ser não-usado
   EndIf

   SX3->(dbSetOrder(2))
   For nZ = 1 to LEN(aCPO[1])
      cCpo := aCpo[1,nZ]
      IF SX3->(dbSeek(AvKey(cCpo,"X3_CAMPO"))) .And. ! X3Uso(SX3->X3_USADO)
         aAdd(aSemSX3,{cCpo,AVSX3(cCpo,AV_TIPO),AVSX3(cCpo,AV_TAMANHO),AVSX3(cCpo,AV_DECIMAL)})
      Endif
   Next

   //Cria a Work "TMP" e carrega variáveis de memória para utilizar o tratamento do EECAF200.prw
   aAdd(aSemSX3,{"TMP_RECNO","N",07,0})

   aAdd(aSemSX3,{"TMP_PARC" ,"C",03,0})

   cWORKEEQ  := E_CRIATRAB("EEQ",aSemSX3,"TMP")
   INDREGUA("TMP",cWORKEEQ+TEOrdBagExt(),"EEQ_PARC" ,"AllwayTrue()","AllwaysTrue()",STR0082)//STR0082	"Processando Arquivo Temporario"

   cWORKEEQ2  := CRIATRAB(,.F.)
   INDREGUA("TMP",cWORKEEQ2+TEOrdBagExt(),"EEQ_ORIGEM" ,"AllwayTrue()","AllwaysTrue()",STR0082)//STR0082	"Processando Arquivo Temporario"

   cWorkEEQ5  := CriaTrab(,.F.)
   IndRegua("TMP",cWorkEEQ5+TEOrdBagExt(),"EEQ_PARVIN+EEQ_PARC","AllwayTrue()","AllwaysTrue()",STR0082)//STR0082	"Processando Arquivo Temporario"

   If EECFlags("FRESEGCOM")
      cWorkEEQ6  := CriaTrab(,.f.)
      //IndRegua("TMP",cWorkEEQ6+TEOrdBagExt(),"EEQ_EVENT","AllwayTrue()","AllwaysTrue()",STR0082) //STR0082	"Processando Arquivo Temporario"
      //RMD - 31/10/18 - Incluída a parcela de origem e a parcela no índice, para que a ordem utilizada na associação de adiantamento pós embarque respeite a ordem exibida na tela de câmbio
      IndRegua("TMP",cWorkEEQ6+TEOrdBagExt(),"EEQ_EVENT+EEQ_PARVIN+EEQ_PARC","AllwayTrue()","AllwaysTrue()",STR0082) //STR0082	"Processando Arquivo Temporario"
      Set Index to (cWORKEEQ+TEOrdBagExt()),(cWORKEEQ2+TEOrdBagExt()),(cWORKEEQ5+TEOrdBagExt()),(cWorkEEQ6+TEOrdBagExt())
   Else
      Set Index to (cWORKEEQ+TEOrdBagExt()),(cWORKEEQ2+TEOrdBagExt()),(cWORKEEQ5+TEOrdBagExt())
   EndIf

   //Carrega "TMP"
   EEQ->(DBSETORDER(1))
   EEQ->(DBSEEK(XFILIAL("EEQ")+EEC->EEC_PREEMB))

   Do While ! EEQ->(EOF()) .AND.;
              EEQ->(EEQ_FILIAL+EEQ_PREEMB) = (XFILIAL("EEQ")+EEC->EEC_PREEMB)

      If lPagtoAnte
         If EEQ->EEQ_TIPO = "A" // Verifica se o lançamento é um adiantamento.
            IF !EECFlags("FRESEGCOM") .Or. EEQ->EEQ_FASE <> "E"
               EEQ->(DbSkip())
               Loop
            EndIf
         Endif
      EndIf

      TMP->(DBAPPEND())
      AVREPLACE("EEQ","TMP")
      TMP->TMP_RECNO := EEQ->(RecNo())

      If EECFlags("FRESEGCOM")
         TMP->EEQ_VLFCAM := AF200VLFCam("TMP","LIQ")//Round((TMP->EEQ_VL-TMP->EEQ_CGRAFI),2)
      EndIf
      TMP->(DBCOMMIT())
      EEQ->(DBSKIP())
   EndDo

End Sequence
Return


/*
Função      : AF201GrvEEQ
Parametros  : lEstorno
Objetivo    : Grava a Work TMP no arquivo EEQ
Retorno     : Nenhum.
Autor       : Eduardo C. Romanini
Data/Hora   : 19/04/07 - 11:35
Obs         :
*/
*-----------------------------*
Function AF201GrvEEQ(lEstorno)
*-----------------------------*
Local aRecNo := {}
Local nRecTmp:= 0
Local lAltTit:= .F.,;
      lLiqAdi:= .F.,;
      lRet   := .T.
Local cFilTitParc, cFilAntBkp
Private dDtBaixa
Private nValorBaixa
Private cSeek:= 'SE1->(DbSeek(xFilial()+"EEC"+AvKey(EEQ->EEQ_FINNUM, "E1_NUM")+AvKey(If(EECFlags("TIT_PARCELAS"),EECGetFinParc(EEQ->EEQ_PARVIN)," "), "E1_PARCELA")+AvKey(TETpTitEEQ("EEQ"),"E1_TIPO")))'  //NCF - 04/07/2019

Default lEstorno:= .F.

Begin Sequence

   If Select("TMP") <= 0
      Break
   EndIf

   TMP->(DbGoTop())
   Do While TMP->(!EOF()) .And. lRet //THTS - 29/03/2018 - Se ocorreu alguma falha (lRet = .F.) nao continua a execucao

      If EasyEntryPoint("EECAF201")
         ExecBlock("EECAF201", .f., .f., "AF201GRVEEQ_LOOP_TMP")
      EndIf

      nRecTmp:= TMP->(RecNo())

      lAltTit:= .F.
      If TMP->TMP_RECNO == 0
         EEQ->(RecLock("EEQ",.T.))

         AvReplace("TMP","EEQ")

         If lPagtoAnte
            EEQ->EEQ_FASE := "E"
         EndIf

         If TMP->EEQ_EVENT == "101" .and. TMP->EEQ_TIPO <> "A"

            EEQ->EEQ_NRINVO := EEC->EEC_NRINVO
            EEQ->EEQ_FORN   := EEC->EEC_FORN
            EEQ->EEQ_FOLOJA := EEC->EEC_FOLOJA
            EEQ->EEQ_IMPORT := EEC->EEC_IMPORT
            EEQ->EEQ_IMLOJA := EEC->EEC_IMLOJA

            If EEQ->(FIELDPOS("EEQ_TP_CON")) > 0
               EEQ->EEQ_TP_CON:="1"
            EndIf

            If lEstorno .And. !AvFlags("EEC_LOGIX") .And.  !EECFlags("ALT_EASYLINK")//THTS - 18/10/2018
                lRet := AvStAction("005")
            EndIf

         ElseIf TMP->EEQ_EVENT == "603"

            EEQ->EEQ_TIPO   := "P"
            EEQ->EEQ_PREEMB := EEC->EEC_PREEMB

            If TMP->EEQ_NROP <> EEQ->EEQ_NROP
               EEQ->EEQ_NROP := TMP->EEQ_NROP
            EndIf
         EndIf

      Else
         EEQ->(dbGoTo(TMP->TMP_RECNO))

         //Verifica se o título RA foi liquidado ou se foi realizado estorno da liquidação
         //para atualização do título principal, da invoice, no módulo sigafin
         If TMP->EEQ_EVENT == "603"
            lLiqAdi:= !Empty(TMP->EEQ_PGT) .Or. (EasyVerModal("TMP") .And. !Empty(TMP->EEQ_DTCE))
         EndIf

         //Tratamento para alteração do título principal no SigaFin
         lAltTit:= TMP->EEQ_VL <> EEQ->EEQ_VL

         //RMD - 05/10/17 - Se for adiantamento pos embarque guarda a referência da parcela de origem
         If TMP->EEQ_EVENT == "603"
            TMP->EEQ_PARVIN := EEQ->EEQ_PARVIN
            //RMD - 12/03/17 - Guarda os dados da parcela de origem
            TMP->EEQ_ORIGEM := EEQ->EEQ_ORIGEM
            TMP->EEQ_NRINVO := EEQ->EEQ_NRINVO
            TMP->EEQ_EMISSA := EEQ->EEQ_EMISSA
            TMP->EEQ_CGRAFI := EEQ->EEQ_CGRAFI
            TMP->EEQ_ADEDUZ := EEQ->EEQ_ADEDUZ
            TMP->EEQ_AREMET := EEQ->EEQ_AREMET
            If EECFlags("TIT_PARCELAS") .Or. EECFlags("ALT_EASYLINK")
               TMP->EEQ_FINNUM := EEQ->EEQ_FINNUM
            EndIf
            TMP->EEQ_VL := EEQ->EEQ_VL
        EndIf

         EEQ->(RecLock("EEQ",.F.))
         AvReplace("TMP","EEQ")

         //Verifica se o adiantamento já está liquidado.
         //Estando liquidado e integrado com o módulo sigafin, na associação ao embarque
         //o título deve ser baixado.
         //RMD - 05/10/17 - Trata a compensação automática
         //If IsIntEnable("001") .And. lLiqAdi .And. (&cSeek) .And. EEQ->EEQ_SALDO <> 0
         If (IsIntEnable("001") .Or. IsIntEnable("010")) .And. lLiqAdi .And. EEQ->EEQ_SALDO <> 0 //THTS - 28/03/2018 - Executa também quando integrado ao Logix
         
            If !AvFlags("EEC_LOGIX") .And. !EasyGParam("MV_EEC0042",,.F.)
                cFilAntBkp := cFilAnt 
                //NCF - 22/08/2017 - Verificar primeiramente se o adiantamento possui origem em outra filial para setar o cFilAnt antes da integração
                If FWModeAccess("EEQ",3) == "E" .And. (cFilTitParc := AF201FOrPc( EEQ->EEQ_FAOR, EEQ->EEQ_PROR, EEQ->EEQ_PAOR, EEQ->EEQ_FINNUM )) <> cFilAnt 
                   cFilAnt := cFilTitParc
                EndIf  

                cFilAnt := cFilAntBkp
                        
                If (&cSeek)
                   nValorBaixa:= EEQ->EEQ_EQVL
                   dDtBaixa   := EEQ->EEQ_PGT
                   EEQ->EEQ_SALDO:= 0
                   //Baixa do titulo de adiantamento
                   lRet:= AvStAction("008")
                EndIf
           Else
                //RMD - 05/10/17 - Compensação automática
                EEQ->EEQ_NR_CON:= ""
                EEQ->EEQ_SALDO:= 0
                If !AvFlags("EEC_LOGIX") //THTS - 28/03/2018
                    If !EECFlags("ALT_EASYLINK")
                        //RMD - 05/10/17 - Cria título NF no contas a receber com o valor do adiantamento
                        lRet := AvStAction("005")
                    Else
                        SE1->(DBSETORDER(1))
                        //RMD - Posiciona no Evento 101 correspondente para localizar o SE1 relacionado ao NF
                        nRecEEQ := EEQ->(Recno())
                        If EEQ->(DbSeek(xFilial()+EEQ->(EEQ_PREEMB+EEQ_PARVIN+EEQ_FASE)))
                            lRet := SE1->(DbSeek(xFilial()+"EEC"+AvKey(EEQ->EEQ_FINNUM, "E1_NUM")+AvKey(If(EECFlags("TIT_PARCELAS"),EECGetFinParc(EEQ->EEQ_PARVIN)," "), "E1_PARCELA")))
                        EndIf
                        EEQ->(dbGoTo(nRecEEQ))
                    EndIf
                EndIf
                If lRet
                   //Efetua a compensação automática 
                   Processa({|| lRet := AF200COMPCR({{EEQ->(RECNO()),SE1->(RECNO()),0}}) }, "Efetuando compensação automática do adiantamento")
                EndIf
            EndIf             
         EndIf
         If !lRet
            Break
         EndIf
         //Armazena o RecNo dos títulos que devem sofrer alteração
         If lAltTit .And. EEQ->EEQ_EVENT == "101" .And. EEQ->EEQ_TIPO <> "A" .And. Empty(EEQ->EEQ_PGT)
            AAdd(aRecNo, EEQ->(RecNo()))
         EndIf

         EEQ->(msUnlock())

      Endif

      //Caso a work seja fechada durante alguma integração, força a reabertura.
      If Select("TMP") == 0
         Af200AbTmp()
         TMP->(DBGoTo(nRecTmp))
      EndIf

      Tmp->(DbSkip())
   EndDo

   //Quando integrado com o financeiro, deve atualizar os títulos que sofreram alteração, desde que o título
   //RA esteja com a data de liquidação preenchida, o que indica que haverá um título de adiantamento correspondente
   //no módulo sigafin, ou que tenha sido realizado o estorno da liquidação
   If lRet .And. (IsIntEnable("001") .And. (lLiqAdi .Or. lEstorno))
      lRet:= AF200AtualTit(aRecNo)
   EndIf
 
End Sequence

If Select("TMP") > 0
    If EECFlags("FRESEGCOM")
        //TMP->(E_EraseArq("TMP",cWorkEEQ,cWorkEEQ2,cWorkEEQ5,cWorkEEQ6)) RMD - 12/03/18 - A chamada estava incorreta (não é enviado o Alias)
        TMP->(E_EraseArq(cWorkEEQ,cWorkEEQ2,cWorkEEQ5,cWorkEEQ6))
    Else
        //TMP->(E_EraseArq("TMP",cWorkEEQ,cWorkEEQ2,cWorkEEQ5)) RMD - 12/03/18 - A chamada estava incorreta (não é enviado o Alias)
        TMP->(E_EraseArq(cWorkEEQ,cWorkEEQ2,cWorkEEQ5))
    EndIf
EndIf

Return lRet

/*
Funcao      : AF201PosicSE5()
Parametros  : Alias - tabela de títulos a pagar ou a receber
Retorno     : lRet
Objetivos   : Posicionar a tabela SE5 em uma sequencia válida, a partir da tabela SE1 ou SE2
Autor       : Wilsimar Fabrício da Silva
Data/Hora   : 19/07/11
Obs.        :
*/
Function AF201PosicSE5(cAlias, dDataBaixa, nValorBx)
Local cPre:= ""
Local lRet:= .F.
Local cCLIFOR
Private aBaixaSE5 := {}
Default cAlias:= "SE1"
Default dDataBaixa:= CtoD("")
Default nValorBx:= 0

Begin Sequence

   cPre:= SubStr(cAlias, 2, 2)

   If Empty(dDataBaixa)
      dDataBaixa:= (cAlias)->&(cPre + "_BAIXA")
   EndIf
   //Verifica se deve utilizar o campo de Cliente (SE1) ou Fornecedor (SE2)
   cCLIFOR := IIF(cAlias == "SE1","E1_CLIENTE","E2_FORNECE")

   SE5->(DbSetOrder(7))//E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
   If SE5->(DBSeek(xFilial() + (cAlias)->(&(cPre + "_PREFIXO") + &(cPre + "_NUM") + &(cPre + "_PARCELA") + &(cPre + "_TIPO") + &(cCLIFOR) + &(cPre + "_LOJA"))))
        
        // E5_FILIAL, E5_TIPODOC, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_DATA, E5_CLIFOR, E5_LOJA, E5_SEQ, R_E_C_N_O_, D_E_L_E_T_
        nRecAux := SE5->( recno() )
        If cAlias == "SE1"
           aBaixaSE5 := Sel070Baixa("VL /V2 /BA /RA /CP /LJ /" , (cAlias)->(&(cPre + "_PREFIXO")) , (cAlias)->(&(cPre + "_NUM")) , (cAlias)->(&(cPre + "_PARCELA")), (cAlias)->(&(cPre + "_TIPO")) , , , SE5->E5_CLIFOR , SE5->E5_LOJA ,nValorBx , , , , , )
        Else
           aBaixaSE5 := Sel080Baixa("VL /BA /CP /",(cAlias)->(&(cPre + "_PREFIXO")) , (cAlias)->(&(cPre + "_NUM")) , (cAlias)->(&(cPre + "_PARCELA")), (cAlias)->(&(cPre + "_TIPO")) ,,,SE5->E5_CLIFOR , SE5->E5_LOJA, , , , , , , , ,(cAlias)->(&(cPre + "_IDENTEE")), )
        EndIf
        aSort(aBaixaSE5,,,{|x,y| SubStr(x,Len(x)-1,Len(x)) < SubStr(y,Len(y)-1,Len(y))})

        SE5->(DbSetOrder(7))//RMD - 24/09/18 - Restaura a chave porque a função Sel080Baixa muda a chave de índice da tabela SE5
        SE5->(dbgoto(nRecAux))

      //Procura uma sequencia válida
      While SE5->(!Eof()) .And. SE5->(xFilial()) == SE5->E5_FILIAL .And.;
            SE5->(E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO + E5_CLIFOR + E5_LOJA) ==;
            (cAlias)->(&(cPre + "_PREFIXO") + &(cPre + "_NUM") + &(cPre + "_PARCELA") + &(cPre + "_TIPO") + &(cCLIFOR) + &(cPre + "_LOJA"))

                If Empty(SE5->E5_DTCANBX) .And. SE5->E5_DATA == dDataBaixa .And. !Empty(SE5->E5_SEQ) .And. (nValorBx == 0 .Or. nValorBx == SE5->E5_VALOR .Or. Len(aBaixaSE5) == 1 )
                //nParcEst := Val(SE5->E5_SEQ)
                If (nParcEst := aScan( aBaixaSE5 , {|x| right( x , len(SE5->E5_SEQ) ) == SE5->E5_SEQ } )) > 0
                        lRet:= .T.
                        Exit
                EndIf
                EndIf

         SE5->(DBSkip())

      EndDo

   EndIf

End Sequence

Return lRet


/*
Função     : AF201PergFin
Parâmetros : nPos-> Opção de baixa ou contas a pagar e a receber
Objetivos  : Chamada de pergunte para que seja possível escolher atraves do F12 qual ação irá executar
Autor      : Diogo Felipe dos Santos - DFS
Data/Hora  : 26/09/12 - 14:22
*/
FUNCTION AF201PergFin()
Local oDlg, oButton, oCombo, cCombo
Local lOk := .F.
Local aItems:= {'Contas a Receber','Baixas a Receber','Contas a Pagar','Baixas a Pagar'}

DEFINE MSDIALOG oDlg FROM 0,0 TO 135,230 PIXEL TITLE STR0083 //"Escolher Parametrização"

 oCombo:= tComboBox():New(10,10,{|u|if(PCount()>0,cCombo:=u,cCombo)},;
 aItems,100,20,oDlg,,,,,,.T.,,,,,,,,,'cCombo')

 // Botões para confirmar e fechar a janela
 oButton:=tButton():New(30,10,STR0084,oDlg,{|| lOk := .T., oDlg:End()},40,10,,,,.T.) //"Confirmar"
 oButton:=tButton():New(30,70,STR0085,oDlg,{||oDlg:End()},40,10,,,,.T.) //"Fechar"

ACTIVATE MSDIALOG oDlg CENTERED

	If lOk
		nPos := aScan(aItems, cCombo)
		Do Case
		    //Chama o pergunte do Contas a Receber
			Case nPos == 1
				AcessaPerg("FIN040",.T.)
    	    //Chama o pergunte do Baixas a Receber
			Case nPos == 2
				AcessaPerg("FIN070",.T.)
  		    //Chama o pergunte do Contas a Pagar
				Case nPos == 3
				AcessaPerg("FIN050",.T.)
		    //Chama o pergunte do Baixas a Pagar
			Case nPos == 4
				AcessaPerg("FIN080",.T.)
		EndCase
	EndIf

Return NIL


/*
Função     : AF201SelLiq
Parâmetros : aParc - array com as parcelas
Objetivos  : Executar a liquidação da parcela principal do financiamento, através da chamada da tela
Autor      : wfs
Data/Hora  : set/2016
*/
Function AF201SelLiq(aParc)
Local nCont

Begin Sequence

   If Len(aParc) == 0
      Break
   EndIf

   ProcRegua(Len(aParc))

   For nCont:= 1 To Len(aParc)
      IncProc(StrTran(StrTran("Liquidação do Financiamento. Parcela ## de $$.", "##", AllTrim(Str(nCont))), "$$", AllTrim(Str(Len(aParc)))))
      EF3->(DBGoTo(aParc[nCont]))
      If EF1->(EF1_TPMODU + EF1_CONTRA) <> EF3->(EF3_TPMODU + EF3_CONTRA)
         EF1->(DBSetOrder(1))
         EF1->(DBSeek(xFilial() + EF3->EF3_TPMODU + EF3->EF3_CONTRA))
         cMod:= EF1->EF1_TPMODU
      EndIf
      EX401SelLiq(.T.,.T.,,,,,"CAMB",,"EF1")
   Next

End Sequence

Return .T.

/*
Função     : AF201FOrPc
Parâmetros : cFase -> Fase Origem
             cProc -> Processo Origem
             cParc -> Parcela Origem
             cTit - > Nro. Título
Objetivos  : Retornar a Filial de origem de um adiantamento vinculado pós-embarque
             Retorna a filial corrente caso não sejam passados os parâmetros corretamente
Autor      : Nilson César
Data/Hora  : Ago/2017
*/
Function AF201FOrPc(cFase,cProc,cParc,cTit)

Local cFil    := xFilial("EEQ")
Local aFil    := {}
Local aOrdEEQ := SaveOrd("EEQ")
Local i
Default cFase := ""
Default cProc := ""
Default cParc := ""
Default cTit  := ""

If !Empty(cFase) .and. !Empty(cProc) .And. !Empty(cParc)// .And. !Empty(cTit) - RMD - 19/03/18 - A parcela é única neste cenário, não é necessário verificar o número do título (que não será igual na associação pós-embarque - lá a referência é para o título NF)
   If Empty(cFil)
      aAdd(aFil,cFil)
   Else
      aFil := AvgSelectFil(.F.)
   EndIf
               
   EEQ->(dbSetOrder(6))
   For i := 1 To Len(aFil)
      If EEQ->(dbSeek(aFil[i]+cFase+cProc+cParc))// .And. EEQ->EEQ_FINNUM == cTit - RMD - 19/03/18 - A parcela é única neste cenário, não é necessário verificar o número do título (que não será igual na associação pós-embarque - lá a referência é para o título NF)
         cFil := aFil[i]
         EXIT
      EndIf
   Next i   
   RestOrd(aOrdEEQ, .T.)
EndIf

Return cFil 

*------------------------------------------------------------------------------------------------------------------*
*                                          Fim do Programa EECAF201                                                *
*------------------------------------------------------------------------------------------------------------------*
