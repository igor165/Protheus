#Include "AVERAGE.CH"
#Include "EEC.cH"
#Include "EECEI101.ch"
//#Include "AVFRM.CH"
#Define FAT_CERT "CO" //Fatura Comercial - Certificado de Origem
#Define DECL_EXP "DE" //Declaração do Produto
#Define ST_A     "A"  //Arquivos aprovados
#Define ST_E     "E"  //Arquivos enviados
#Define ST_N     "N"  //Arquivos não enviados
#Define ST_R     "R"  //Arquivos rejeitados

#Define ENCERRAR 6

/*
Programa  : EECEI101
Objetivo  : Manutenção do código da declaração do produto - Fiesp
Parâmetros: 
Retorno   : 
Autor     : Wilsimar Fabrício da Silva
Data      : 24/11/2009
Obs.      :
*/
Function EECEI101()
Local aStatus:= {},;
      aOrd   := SaveOrd({"E09", "E10"})
Private aRotina  := {},;
        aGets    := {},;
        aTela    := {},;
        aDeclProd:= {}
Private cCadastro:= STR0001 //Cadastro da Declaração de Produtos - FIESP

Begin Sequence

   //wfs 24/09/12 - retirada do parâmetro de nível de acesso
   aRotina:= {{STR0002, "AxPesqui"  , 0, 1},; //Pesquisar
              {STR0003, "EI101Man"  , 0, 2},; //Visualizar
              {STR0004, "EI101Man"  , 0, 3},; //Incluir
              {STR0005, "EI101Man"  , 0, 4},; //Alterar
              {STR0006, "EI101Man"  , 0, 5},; //Excluir
              {STR0022, "EI101Man"  , 0, 4, 6},; //Encerrar - O acesso para esta ação deve ser superior a 6
              {STR0007, "EI101Legen", 0, 2}}  //Legenda

   AAdd(aStatus, {"EI101LegStatus('BR_AZUL')"    , "BR_AZUL"    })
   AAdd(aStatus, {"EI101LegStatus('BR_AMARELO')" , "BR_AMARELO" })
   AAdd(aStatus, {"EI101LegStatus('BR_LARANJA')" , "BR_LARANJA" })
   AAdd(aStatus, {"EI101LegStatus('BR_VERDE')"   , "BR_VERDE"   })
   AAdd(aStatus, {"EI101LegStatus('BR_VERMELHO')", "BR_VERMELHO"})
   AAdd(aStatus, {"EI101LegStatus('BR_BRANCO')"  , "BR_BRANCO"  })
   AAdd(aStatus, {"EI101LegStatus('BR_PRETO')"   , "BR_PRETO"   })


   MBrowse(,,,, "E10",,,,,, aStatus)
End Sequence

RestOrd(aOrd)
Return


/*
Função    : EI101Man()
Objetivo  : Rotina de manutenção do código da declaração do produto
Parâmetros: Alias, registro posicionado e opção (inclusão, alteração, exclusão)
Retorno   : Lógico
Autor     : Wilsimar Fabrício da Silva
Data      : 25/11/2009
Obs.      :
*/
Function EI101Man(cAlias, nReg, nOpcx)
Local aCamposVis:= {},;
      aCamposAlt:= {}
Local bOk    := {|| If(Obrigatorio(aGets, aTela), (lOk:= .T., oDlg:End()), Nil)},;
      bCancel:= {|| lOk:= .F., oDlg:End()}
Local cDeclTemp
Local lOk,;
      lRet:= .F.
Local nConf,;
      nCont,;
      nOpc:= nOpcx
Local oDlg,;
      oMsmGet

Begin Sequence

   //Criação das variáveis de memória
   RegToMemory(cAlias, nOpc == INCLUIR)

   //Campos que serão visualizados na MsmGet
   aCamposVis:= {"E10_COD_I", "E10_DECLPR", "E10_VLDECL", "E10_CHVE09"}
   //Se a declaração do produto foi encerrada, serão exibidos os campos referente à esta operação.
   If !Empty((cAlias)->E10_VLREAL)
      aCamposVis:= {"E10_COD_I", "E10_DECLPR", "E10_VLDECL", "E10_CHVE09",;
                    "E10_USRENC", "E10_DTENC", "E10_HRENC", "E10_VLREAL"}
   EndIf



   //Tratamentos para visualização
   If nOpc == VISUALIZAR

   EndIf

   //Tratamentos para inclusão
   If nOpc == INCLUIR

      //Campos que serão editados no cadastro da declaração do produto
      aCamposAlt:= {"E10_COD_I", "E10_DECLPR"}
      
      //OAP - 09/11/2010 - Permissão de edição dos campos adicionados pelo usuário 
      aCamposAlt := AddCpoUser(aCamposAlt,"E10","1")
      
      //Tratamento para verificar se o usuário usou o número sugerido pelo sistema
      cDeclTemp:= M->E10_DECLPR

      //Se a chamada foi realizada da central de integrações, o código do produto será carregado
      //para a realização do cadastro do item.
      If Upper(ProcName(1)) == "EI100VERIFDECLPROD"
         M->E10_COD_I := EE9->EE9_COD_I
      EndIf

   EndIf

   //Tratamentos para alteração
   If nOpc == ALTERAR
      MsgInfo(STR0008, cCadastro) //As alterações serão realizadas através da central de integrações.
   EndIf


   //Tratamentos para exclusão
   If nOpc == EXCLUIR

   EndIf


   //Tratamentos para o encerramento do código da declaração antes do vencimento
   If nOpc == ENCERRAR
      nOpcx:= VISUALIZAR
   EndIf
   
   aGets:= {}
   aTela:= {}
   Define MsDialog oDlg Title cCadastro From DLG_LIN_INI, DLG_COL_INI To DLG_LIN_FIM, DLG_COL_FIM Pixel Of oMainWnd //Cadastro da Declaração de Produtos - FIESP
      oMsmGet:= MsmGet():New(cAlias, nReg, nOpcx,,,,aCamposVis,, aCamposAlt,,,,, oDlg,, .T.)
      oMsmGet:Refresh()
      oDlg:lMaximized:=.T. //wfs 24/09/12
   Activate MsDialog oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) Centered


   Do Case
      Case lOk .And. nOpc == INCLUIR
   
         //Tratamento para verificar se existe cadastro da declaração de produtos não
         //enviadas ou aguardando retorno da Fiesp (validade da declaração não preenchida)
         (cAlias)->(DBSetOrder(2)) //E10_FILIAL + E10_COD_I + E10_VLDECL
         If (cAlias)->(DBSeek(xFilial() + M->E10_COD_I + AvKey("", "E10_VLDECL")))

            MsgInfo(STR0020 + AllTrim((cAlias)->E10_DECLPR) +; //Este produto possui o código de declaração ####
                    STR0021) //não enviado ou aguardando a aprovação da FIESP. Esta operação não será concluída.
            RollBackSxe(cAlias, "E10_DECLPR")
            (cAlias)->(DBGoTo(nReg))
            Break
         EndIf

         //Inclusão do item
         Begin Transaction
            (cAlias)->(RecLock(cAlias, .T.))
            AvReplace("M", cAlias)
            (cAlias)->(MsUnlock())
         End Transaction

         //Se o usuário não alterou o código sugerido, este será confirmado
         If cDeclTemp == (cAlias)->E10_DECLPR
            ConfirmSx8(cAlias, "E10_DECLPR")
         Else
            RollBackSxe(cAlias, "E10_DECLPR")
         EndIf
         
         lRet:= .T.
      Case !lOk .And. nOpc == INCLUIR
         RollBackSxe(cAlias, "E10_DECLPR")

      Case lOk .And. nOpc == EXCLUIR

         Begin Transaction

         //Se não tiver arquivo gerado, poderá ser excluído
         If Empty((cAlias)->E10_CHVE09)
            (cAlias)->(RecLock(cAlias, .F.))
            (cAlias)->(DBDelete())
            (cAlias)->(MsUnlock())
            lRet:= .T.
         Else

            E09->(DBSetOrder(2)) //E09_FILIAL + E09_ARQUIV + E09_PREEMB + E09_STATUS
            //Se não foi encontrado o arquivo é porque não foi gerado ou excluído no tratamento de exclusão
            //de outro código de declaração. Neste caso será excluído.
            If !E09->(DBSeek(xFilial() + (cAlias)->E10_CHVE09))
               (cAlias)->(RecLock(cAlias, .F.))
               (cAlias)->(DBDelete())
               (cAlias)->(MsUnlock())
               lRet:= .T.   
            Else

            /* Verificação do status do arquivo.
               Caso tenha sido rejeitado ou o status esteja vazio, poderá ser excluído.
               Caso esteja com o status enviado ou aprovado, não será excluído.
               Caso esteja com o status não enviado, poderá ser excluído porém o arquivo de integração também será. */
               Do Case
            
                  Case E09->E09_STATUS == ST_R .Or. Empty(E09->E09_STATUS) //rejeitado ou vazio
                     (cAlias)->(RecLock(cAlias, .F.))
                     (cAlias)->(DBDelete())
                     (cAlias)->(MsUnlock())
                     lRet:= .T.
                  Case E09->E09_STATUS == ST_E //enviado
                     MsgInfo(STR0009) //Este código de declaração não pode ser excluído pois o arquivo de integração referente a este produto encontra-se com o status 'E' - enviado.

                  Case E09->E09_STATUS == ST_A //aprovado
                     MsgInfo(STR0010) //Este código de declaração não pode ser excluído pois o arquivo de integração referente a este produto encontra-se com o status 'A' - aprovado.

                  Case E09->E09_STATUS == ST_N //não enviado
                     If MsgYesNo(STR0011) //Existe arquivo gerado com o status 'não enviado' para este código de declaração. Caso confirme esta exclusão, o arquivo também será excluído. Deseja prosseguir?

                        //Esta função carregará o array aDeclProd com os produtos que fazem parte do arquivo de
                        //integração gerado. O conteúdo do campo E10_CHVE09 deve ser apagado quando o registro do
                        //arquivo de integração for deletado.
                        EI100VerifDeclProd(DECL_EXP, E09->E09_ARQUIV, E09->E09_PREEMB)
                        Begin Transaction
                           E09->(RecLock("E09", .F.))
                           E09->(DBDelete())
                           E09->(MsUnlock())

                           (cAlias)->(RecLock(cAlias, .F.))
                           (cAlias)->(DBDelete())
                           (cAlias)->(MsUnlock())

                           /* Array aDeclProd:
                              Posição 1. o código do produto,
                              Posição 2. o RecNo correspondente à tabela EE9
                              Posição 3. o RecNo correspondente à tabela E10 */
                           For nCont:= 1 To Len(aDeclProd)
                              (cAlias)->(DBGoTo(aDeclProd[nCont][3]))
                              (cAlias)->(RecLock(cAlias, .F.))
                              (cAlias)->E10_CHVE09:= ""
                              (cAlias)->(MsUnlock())
                           Next

                        End Transaction
                        lRet:= .T.
                     EndIf

                  OtherWise
                     MsgInfo(STR0012, cCadastro) //Não foi possível excluir este registro.

               End Case
            EndIf
         EndIf
         
         End Transaction

      Case lOk .And. nOpc == ENCERRAR

         If Empty((cAlias)->E10_VLDECL)
            MsgInfo(STR0023) //Esta declaração não possui data de validade preenchida. Para anular a utilização deste código de declaração use a opção 'Excluir'.
            lRet:= .F.
         Else

            Begin Transaction
               (cAlias)->(RecLock(cAlias, .F.))
               (cAlias)->E10_USRENC:= cUserName
               (cAlias)->E10_DTENC := dDataBase
               (cAlias)->E10_HRENC := Time()
               (cAlias)->E10_VLREAL:= (cAlias)->E10_VLDECL
               (cAlias)->E10_VLDECL:= dDataBase - 1
               (cAlias)->(MsUnlock())
            End Transaction
         EndIf

      OtherWise
         lRet:= .F.


   End Case

End Sequence
Return lRet

/*
Função    : EI101ValidDt()
Objetivo  : Validar a digitação da data de validade do código da declaração do produto.
Parâmetros:
Retorno   : Lógico 
Autor     : Wilsimar Fabrício da Silva
Data      : 25/11/2009
Obs.      :
*/
Function EI101ValidDt()
Local lRet:= .T.

Begin Sequence

   If M->E10_VLDECL < dDataBase
      MsgInfo(STR0013) //A data de validade deve ser igual ou posterior a data atual.
      lRet:= .F.
   EndIf

End Sequence
Return lRet


/*
Funcao     : EI101Legen()
Parametros : 
Retorno    : 
Objetivos  : Exibir a legenda para as cores do status.
Autor      : Wilsimar Fabricio da Silva
Data/Hora  : 25/11/2009
*/

Function EI101Legen()
Local aLegenda:= {}

   AAdd(aLegenda, {"BR_AZUL"    , STR0014}) //Arquivo não gerado
   AAdd(aLegenda, {"BR_AMARELO" , STR0016}) //Aguardando envio
   AAdd(aLegenda, {"BR_LARANJA" , STR0017}) //Aguardando aprovação
   AAdd(aLegenda, {"BR_VERDE"   , STR0015}) //Liberado
   AAdd(aLegenda, {"BR_VERMELHO", STR0018}) //Rejeitado
   AAdd(aLegenda, {"BR_PRETO"   , STR0019}) //Vencido
   AAdd(aLegenda, {"BR_BRANCO"  , STR0024}) //Encerrado

   BrwLegenda(cCadastro, STR0007, aLegenda) //Legenda

Return

/*
Função    : EI101LegStatus
Objetivo  : Definir a cor da legenda a ser exibida na mBrowse
Parâmetros: Cor da legenda (BR_XXXXX)
Retorno   : Lógico
Autor     : Wilsimar Fabrício da Silva
Data      : 25/11/2009
Obs.      : A classificação do status é totalmente relevante (A-aceito, E-enviado, N-não enviado, R-rejeitado).
*/
Function EI101LegStatus(cCor)
Local lRet:= .F.,;
      lAchou

Begin Sequence

   E09->(DBSetOrder(2)) //E09_FILIAL + E09_ARQUIV + E09_PREEMB + E09_STATUS
   lAchou:= E09->(DBSeek(xFilial() + E10->E10_CHVE09))

   Do Case
      Case cCor == "BR_VERDE"
         //Aprovado
         If lAchou .And. E09->E09_STATUS == ST_A .And. E10->E10_VLDECL >= dDataBase
            lRet:= .T.
         EndIf

      Case cCor == "BR_AMARELO"
         //Não enviado
         If lAchou .And. E09->E09_STATUS == ST_N
            lRet:= .T.
         EndIf

      Case cCor == "BR_LARANJA"
         //Aguardando aprovação
         If lAchou .And. E09->E09_STATUS == ST_E
            lRet:= .T.
         EndIf

      Case cCor == "BR_VERMELHO"
         //Rejeitado
         If lAchou .And. E09->E09_STATUS == ST_R
            lRet:= .T.
         EndIf

      Case cCor == "BR_PRETO"
         //Vencido
         If lAchou .And. E09->E09_STATUS == ST_A .And. E10->E10_VLDECL < dDataBase .And. Empty(E10->E10_USRENC)
            lRet:= .T.
         EndIf

      Case cCor == "BR_AZUL"
         If Empty(E10->E10_CHVE09) //Arquivo não foi gerado
            lRet:= .T.
         EndIf

      Case cCor == "BR_BRANCO"
         If !Empty(E10->E10_USRENC)
            lRet:= .T.
         EndIf

      OtherWise
         lRet:= .F.

   End Case

End Sequence
Return lRet
