#Include "AVERAGE.CH"
#Include "EEC.cH"
#Include "EECEI101.ch"
//#Include "AVFRM.CH"
#Define FAT_CERT "CO" //Fatura Comercial - Certificado de Origem
#Define DECL_EXP "DE" //Declara��o do Produto
#Define ST_A     "A"  //Arquivos aprovados
#Define ST_E     "E"  //Arquivos enviados
#Define ST_N     "N"  //Arquivos n�o enviados
#Define ST_R     "R"  //Arquivos rejeitados

#Define ENCERRAR 6

/*
Programa  : EECEI101
Objetivo  : Manuten��o do c�digo da declara��o do produto - Fiesp
Par�metros: 
Retorno   : 
Autor     : Wilsimar Fabr�cio da Silva
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
Private cCadastro:= STR0001 //Cadastro da Declara��o de Produtos - FIESP

Begin Sequence

   //wfs 24/09/12 - retirada do par�metro de n�vel de acesso
   aRotina:= {{STR0002, "AxPesqui"  , 0, 1},; //Pesquisar
              {STR0003, "EI101Man"  , 0, 2},; //Visualizar
              {STR0004, "EI101Man"  , 0, 3},; //Incluir
              {STR0005, "EI101Man"  , 0, 4},; //Alterar
              {STR0006, "EI101Man"  , 0, 5},; //Excluir
              {STR0022, "EI101Man"  , 0, 4, 6},; //Encerrar - O acesso para esta a��o deve ser superior a 6
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
Fun��o    : EI101Man()
Objetivo  : Rotina de manuten��o do c�digo da declara��o do produto
Par�metros: Alias, registro posicionado e op��o (inclus�o, altera��o, exclus�o)
Retorno   : L�gico
Autor     : Wilsimar Fabr�cio da Silva
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

   //Cria��o das vari�veis de mem�ria
   RegToMemory(cAlias, nOpc == INCLUIR)

   //Campos que ser�o visualizados na MsmGet
   aCamposVis:= {"E10_COD_I", "E10_DECLPR", "E10_VLDECL", "E10_CHVE09"}
   //Se a declara��o do produto foi encerrada, ser�o exibidos os campos referente � esta opera��o.
   If !Empty((cAlias)->E10_VLREAL)
      aCamposVis:= {"E10_COD_I", "E10_DECLPR", "E10_VLDECL", "E10_CHVE09",;
                    "E10_USRENC", "E10_DTENC", "E10_HRENC", "E10_VLREAL"}
   EndIf



   //Tratamentos para visualiza��o
   If nOpc == VISUALIZAR

   EndIf

   //Tratamentos para inclus�o
   If nOpc == INCLUIR

      //Campos que ser�o editados no cadastro da declara��o do produto
      aCamposAlt:= {"E10_COD_I", "E10_DECLPR"}
      
      //OAP - 09/11/2010 - Permiss�o de edi��o dos campos adicionados pelo usu�rio 
      aCamposAlt := AddCpoUser(aCamposAlt,"E10","1")
      
      //Tratamento para verificar se o usu�rio usou o n�mero sugerido pelo sistema
      cDeclTemp:= M->E10_DECLPR

      //Se a chamada foi realizada da central de integra��es, o c�digo do produto ser� carregado
      //para a realiza��o do cadastro do item.
      If Upper(ProcName(1)) == "EI100VERIFDECLPROD"
         M->E10_COD_I := EE9->EE9_COD_I
      EndIf

   EndIf

   //Tratamentos para altera��o
   If nOpc == ALTERAR
      MsgInfo(STR0008, cCadastro) //As altera��es ser�o realizadas atrav�s da central de integra��es.
   EndIf


   //Tratamentos para exclus�o
   If nOpc == EXCLUIR

   EndIf


   //Tratamentos para o encerramento do c�digo da declara��o antes do vencimento
   If nOpc == ENCERRAR
      nOpcx:= VISUALIZAR
   EndIf
   
   aGets:= {}
   aTela:= {}
   Define MsDialog oDlg Title cCadastro From DLG_LIN_INI, DLG_COL_INI To DLG_LIN_FIM, DLG_COL_FIM Pixel Of oMainWnd //Cadastro da Declara��o de Produtos - FIESP
      oMsmGet:= MsmGet():New(cAlias, nReg, nOpcx,,,,aCamposVis,, aCamposAlt,,,,, oDlg,, .T.)
      oMsmGet:Refresh()
      oDlg:lMaximized:=.T. //wfs 24/09/12
   Activate MsDialog oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) Centered


   Do Case
      Case lOk .And. nOpc == INCLUIR
   
         //Tratamento para verificar se existe cadastro da declara��o de produtos n�o
         //enviadas ou aguardando retorno da Fiesp (validade da declara��o n�o preenchida)
         (cAlias)->(DBSetOrder(2)) //E10_FILIAL + E10_COD_I + E10_VLDECL
         If (cAlias)->(DBSeek(xFilial() + M->E10_COD_I + AvKey("", "E10_VLDECL")))

            MsgInfo(STR0020 + AllTrim((cAlias)->E10_DECLPR) +; //Este produto possui o c�digo de declara��o ####
                    STR0021) //n�o enviado ou aguardando a aprova��o da FIESP. Esta opera��o n�o ser� conclu�da.
            RollBackSxe(cAlias, "E10_DECLPR")
            (cAlias)->(DBGoTo(nReg))
            Break
         EndIf

         //Inclus�o do item
         Begin Transaction
            (cAlias)->(RecLock(cAlias, .T.))
            AvReplace("M", cAlias)
            (cAlias)->(MsUnlock())
         End Transaction

         //Se o usu�rio n�o alterou o c�digo sugerido, este ser� confirmado
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

         //Se n�o tiver arquivo gerado, poder� ser exclu�do
         If Empty((cAlias)->E10_CHVE09)
            (cAlias)->(RecLock(cAlias, .F.))
            (cAlias)->(DBDelete())
            (cAlias)->(MsUnlock())
            lRet:= .T.
         Else

            E09->(DBSetOrder(2)) //E09_FILIAL + E09_ARQUIV + E09_PREEMB + E09_STATUS
            //Se n�o foi encontrado o arquivo � porque n�o foi gerado ou exclu�do no tratamento de exclus�o
            //de outro c�digo de declara��o. Neste caso ser� exclu�do.
            If !E09->(DBSeek(xFilial() + (cAlias)->E10_CHVE09))
               (cAlias)->(RecLock(cAlias, .F.))
               (cAlias)->(DBDelete())
               (cAlias)->(MsUnlock())
               lRet:= .T.   
            Else

            /* Verifica��o do status do arquivo.
               Caso tenha sido rejeitado ou o status esteja vazio, poder� ser exclu�do.
               Caso esteja com o status enviado ou aprovado, n�o ser� exclu�do.
               Caso esteja com o status n�o enviado, poder� ser exclu�do por�m o arquivo de integra��o tamb�m ser�. */
               Do Case
            
                  Case E09->E09_STATUS == ST_R .Or. Empty(E09->E09_STATUS) //rejeitado ou vazio
                     (cAlias)->(RecLock(cAlias, .F.))
                     (cAlias)->(DBDelete())
                     (cAlias)->(MsUnlock())
                     lRet:= .T.
                  Case E09->E09_STATUS == ST_E //enviado
                     MsgInfo(STR0009) //Este c�digo de declara��o n�o pode ser exclu�do pois o arquivo de integra��o referente a este produto encontra-se com o status 'E' - enviado.

                  Case E09->E09_STATUS == ST_A //aprovado
                     MsgInfo(STR0010) //Este c�digo de declara��o n�o pode ser exclu�do pois o arquivo de integra��o referente a este produto encontra-se com o status 'A' - aprovado.

                  Case E09->E09_STATUS == ST_N //n�o enviado
                     If MsgYesNo(STR0011) //Existe arquivo gerado com o status 'n�o enviado' para este c�digo de declara��o. Caso confirme esta exclus�o, o arquivo tamb�m ser� exclu�do. Deseja prosseguir?

                        //Esta fun��o carregar� o array aDeclProd com os produtos que fazem parte do arquivo de
                        //integra��o gerado. O conte�do do campo E10_CHVE09 deve ser apagado quando o registro do
                        //arquivo de integra��o for deletado.
                        EI100VerifDeclProd(DECL_EXP, E09->E09_ARQUIV, E09->E09_PREEMB)
                        Begin Transaction
                           E09->(RecLock("E09", .F.))
                           E09->(DBDelete())
                           E09->(MsUnlock())

                           (cAlias)->(RecLock(cAlias, .F.))
                           (cAlias)->(DBDelete())
                           (cAlias)->(MsUnlock())

                           /* Array aDeclProd:
                              Posi��o 1. o c�digo do produto,
                              Posi��o 2. o RecNo correspondente � tabela EE9
                              Posi��o 3. o RecNo correspondente � tabela E10 */
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
                     MsgInfo(STR0012, cCadastro) //N�o foi poss�vel excluir este registro.

               End Case
            EndIf
         EndIf
         
         End Transaction

      Case lOk .And. nOpc == ENCERRAR

         If Empty((cAlias)->E10_VLDECL)
            MsgInfo(STR0023) //Esta declara��o n�o possui data de validade preenchida. Para anular a utiliza��o deste c�digo de declara��o use a op��o 'Excluir'.
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
Fun��o    : EI101ValidDt()
Objetivo  : Validar a digita��o da data de validade do c�digo da declara��o do produto.
Par�metros:
Retorno   : L�gico 
Autor     : Wilsimar Fabr�cio da Silva
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

   AAdd(aLegenda, {"BR_AZUL"    , STR0014}) //Arquivo n�o gerado
   AAdd(aLegenda, {"BR_AMARELO" , STR0016}) //Aguardando envio
   AAdd(aLegenda, {"BR_LARANJA" , STR0017}) //Aguardando aprova��o
   AAdd(aLegenda, {"BR_VERDE"   , STR0015}) //Liberado
   AAdd(aLegenda, {"BR_VERMELHO", STR0018}) //Rejeitado
   AAdd(aLegenda, {"BR_PRETO"   , STR0019}) //Vencido
   AAdd(aLegenda, {"BR_BRANCO"  , STR0024}) //Encerrado

   BrwLegenda(cCadastro, STR0007, aLegenda) //Legenda

Return

/*
Fun��o    : EI101LegStatus
Objetivo  : Definir a cor da legenda a ser exibida na mBrowse
Par�metros: Cor da legenda (BR_XXXXX)
Retorno   : L�gico
Autor     : Wilsimar Fabr�cio da Silva
Data      : 25/11/2009
Obs.      : A classifica��o do status � totalmente relevante (A-aceito, E-enviado, N-n�o enviado, R-rejeitado).
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
         //N�o enviado
         If lAchou .And. E09->E09_STATUS == ST_N
            lRet:= .T.
         EndIf

      Case cCor == "BR_LARANJA"
         //Aguardando aprova��o
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
         If Empty(E10->E10_CHVE09) //Arquivo n�o foi gerado
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
