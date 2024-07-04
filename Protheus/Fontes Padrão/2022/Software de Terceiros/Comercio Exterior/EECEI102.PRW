#Include "AVERAGE.CH"
#Include "EEC.cH"
#Include "EECEI102.CH"

/*
Programa  : EECEI102
Objetivo  : Manutenção do Acordo Comercial
Parâmetros: 
Retorno   : 
Autor     : Wilsimar Fabrício da Silva
Data      : 09/12/2009
Obs.      :
*/
Function EECEI102()
Private aRotina   := {},;
        aGets     := {},;
        aTela     := {},;
        aDeletados:= {}
Private cCadastro := STR0001,; //Cadastro de Acordos Comerciais
        cArqWork  := ""
Private oUpdAtu

Begin Sequence

   aRotina:= {{STR0002, "AxPesqui"  , 0, 1, 1},; //Pesquisar
              {STR0003, "EI102Man"  , 0, 2, 1},; //Visualizar
              {STR0004, "EI102Man"  , 0, 3, 1},; //Incluir
              {STR0005, "EI102Man"  , 0, 4, 1},; //Alterar
              {STR0006, "EI102Man"  , 0, 5, 1}}  //Excluir

   // BAK - Tratamento para carga padrão da tabela E11 - (Acordo Comercial) - 19/08/2011
   dbSelectArea("E11")
   IF E11->(EasyRecCount()) == 0 //LRS - 04/12/2017 - So carregar carga padrão se não existir registro na tabela
      If FindFunction("AvUpdate01")
            oUpdAtu := AvUpdate01():New()
      EndIf
      
      If ValType(oUpdAtu) == "O" .AND. &("MethIsMemberOf(oUpdAtu,'TABLEDATA')") .AND. Type("oUpdAtu:lSimula") == "L"
            If ChkFile("E11")
            oUpdAtu:aChamados := {{nModulo,{|o| EDadosE11(o)}}}
            oUpdAtu:Init(,.T.)
            EndIf
      EndIf
   EndIF
   
   //LGS-04/09/2015 - Tabela de/Para - FIERGS
   //6 - Acordo
   IF AvFlags("TABELA_DE_PARA_FIERGS")
      aaDD(aRotina,{STR0018, 'TE110Inclui("6",E11->(E11_CODACO+E11_DESRED) )'  , 0 , 4}) //Tabela de/Para
   EndIf

   //Criação da Work para a amarração entre os acordos e os países
   CriaWorkEI102()

   MBrowse(,,,, "E11")

   //Encerrar as works
   If Select("Work") > 0
      Work->(DBCloseArea())
   EndIf
   FErase(cArqWork)
   
End Sequence

Return

Static Function EDadosE11(o)
Local aE11 := {}

Begin Sequence

   // Integração FIESP
   o:TableStruct("E11",{"E11_FILIAL"   , "E11_CODACO" , "E11_DESRED"      , "E11_DESCRI"      , "E11_DOBRIG" },1)
   AAdd(aE11, { E11->(xFilial()), "14"      , "ACE-14"             , "Acordo de Complementação Econômica nº 14"   , "1"})
   AAdd(aE11, { E11->(xFilial()), "18"      , "ACE-18"             , "Acordo de Complementação Econômica nº 18"   , "1"})
   AAdd(aE11, { E11->(xFilial()), "35"      , "ACE-35"             , "Acordo de Complementação Econômica nº 35"   , "1"})
   AAdd(aE11, { E11->(xFilial()), "36"      , "ACE-36"             , "Acordo de Complementação Econômica nº 36"   , "1"})
   AAdd(aE11, { E11->(xFilial()), "53"      , "ACE-53"             , "Acordo de Complementação Econômica nº 53"   , "1"})
   AAdd(aE11, { E11->(xFilial()), "55"      , "ACE-55"             , "Acordo de Complementação Econômica nº 55"   , "1"})
   AAdd(aE11, { E11->(xFilial()), "58"      , "ACE-58"             , "Acordo de Complementação Econômica nº 58"   , "1"})
   AAdd(aE11, { E11->(xFilial()), "59"      , "ACE-59"             , "Acordo de Complementação Econômica nº 59"   , "1"})
   AAdd(aE11, { E11->(xFilial()), "62"      , "ACE-62"             , "Acordo de Complementação Econômica nº 62"   , "1"})
   AAdd(aE11, { E11->(xFilial()), "A3"      , "ACE-14 - Automotivo", "Acordo de Complementação Econômica" +;
                                                              " Automotivo nº14"                              , "1"})
   AAdd(aE11, { E11->(xFilial()), "AC"      , "ACP-Mercosul-Índia" , "Acordo de Comércio Preferencial "+;
                                                              "Mercosul-Índia"                                , "1"})
   AAdd(aE11, { E11->(xFilial()), "AG"      , "AAP.AG/2"           , "Acordo de alcance parcial - sementes"       , "1"})
   AAdd(aE11, { E11->(xFilial()), "AN"      , "ANEXO III"          , "ANEXO III"                                  , "1"})
   AAdd(aE11, { E11->(xFilial()), "AU"      , "AAP.CE 14.35"       , "AAP.CE 14.35"                               , "1"})
   AAdd(aE11, { E11->(xFilial()), "CO"      , "COMUM"              , "Certificado de Origem Comum"                , "2"})
   AAdd(aE11, { E11->(xFilial()), "CP"      , "CAP 52-55"          , "Capítulo 52-55 ( Brasil X Peru )"           , "2"})
   AAdd(aE11, { E11->(xFilial()), "GT"      , "GATT"               , "General Agrement on Tarifs and Trade"       , "2"})
   AAdd(aE11, { E11->(xFilial()), "PT"      , "AAR/PTR04"          , "Preferências Tarifárias Regional nº 04"     , "1"})
   AAdd(aE11, { E11->(xFilial()), "SG"      , "SGPC"               , "Sistema Global de Preferências Comerciais" +;
                                                              " entre Países em desenvolvimento"              , "2"})
   AAdd(aE11, { E11->(xFilial()), "U2"      , "ACE-02 - Automotivo", "Acordo de Complementação Econômica" +;
                                                              " Automotivo nº02"                              , "1"})
   AAdd(aE11, { E11->(xFilial()), "02"      , "ACE-02"             , "Acordo de Complementação Econômica nº 02"   , "1"})
   o:TableData("E11"  ,aE11,,.F.)

      // Integração FACISC
   o:TableStruct("E11",{"E11_FILIAL"   , "E11_CODACO" , "E11_DESRED"      , "E11_DESCRI"      , "E11_DOBRIG" , "E11_INTEGR"},1)
   o:TableData("E11"  ,{ xFilial("E11"), "01"         , "ACE 02"          , "ACE 02"          , "2"          , "FACISC"    },,.F.)
   o:TableData("E11"  ,{ xFilial("E11"), "02"         , "ACE 14"          , "ACE 14"          , "2"          , "FACISC"    },,.F.)
   o:TableData("E11"  ,{ xFilial("E11"), "03"         , "ACE 18"          , "ACE 18"          , "2"          , "FACISC"    },,.F.)
   o:TableData("E11"  ,{ xFilial("E11"), "04"         , "ACE 35"          , "ACE 35"          , "2"          , "FACISC"    },,.F.)
   o:TableData("E11"  ,{ xFilial("E11"), "05"         , "ACE 36"          , "ACE 36"          , "2"          , "FACISC"    },,.F.)
   o:TableData("E11"  ,{ xFilial("E11"), "06"         , "ACE 38"          , "ACE 38"          , "2"          , "FACISC"    },,.F.)
   o:TableData("E11"  ,{ xFilial("E11"), "07"         , "ACE 53"          , "ACE 53"          , "2"          , "FACISC"    },,.F.)
   o:TableData("E11"  ,{ xFilial("E11"), "08"         , "ACE 55"          , "ACE 55"          , "2"          , "FACISC"    },,.F.)
   o:TableData("E11"  ,{ xFilial("E11"), "09"         , "ACE 58"          , "ACE 58"          , "2"          , "FACISC"    },,.F.)
   o:TableData("E11"  ,{ xFilial("E11"), "10"         , "ACE 59"          , "ACE 59"          , "2"          , "FACISC"    },,.F.)
   o:TableData("E11"  ,{ xFilial("E11"), "11"         , "ACE 62"          , "ACE 62"          , "2"          , "FACISC"    },,.F.)
   o:TableData("E11"  ,{ xFilial("E11"), "12"         , "ANEXO III"       , "ANEXO III"       , "2"          , "FACISC"    },,.F.)
   o:TableData("E11"  ,{ xFilial("E11"), "13"         , "ANEXO INDIA"     , "ANEXO INDIA"     , "2"          , "FACISC"    },,.F.)
   o:TableData("E11"  ,{ xFilial("E11"), "14"         , "APTR 04"         , "APTR 04"         , "2"          , "FACISC"    },,.F.)
   o:TableData("E11"  ,{ xFilial("E11"), "16"         , "COMUM"           , "COMUM"           , "2"          , "FACISC"    },,.F.)
   o:TableData("E11"  ,{ xFilial("E11"), "17"         , "COMUM 2"         , "COMUM 2"         , "2"          , "FACISC"    },,.F.)
   o:TableData("E11"  ,{ xFilial("E11"), "18"         , "COTTON AND SILK" , "COTTON AND SILK" , "2"          , "FACISC"    },,.F.)
   o:TableData("E11"  ,{ xFilial("E11"), "19"         , "HANDICRAFT"      , "HANDICRAFT"      , "2"          , "FACISC"    },,.F.)
   o:TableData("E11"  ,{ xFilial("E11"), "20"         , "ISRAEL"          , "ISRAEL"          , "2"          , "FACISC"    },,.F.)

End Sequence

Return Nil

/*
Função    : EI102Man()
Objetivo  : Rotina de manutenção de acordos comerciais
Parâmetros: Alias, registro posicionado e opção (inclusão, alteração, exclusão)
Retorno   : Lógico
Autor     : Wilsimar Fabrício da Silva
Data      : 25/11/2009
Obs.      :
*/
Function EI102Man(cAlias, nReg, nOpcx)
Local aCamposWork:= {},;
      aButtons   := {}
Local bOk    := {|| If(Obrigatorio(aGets, aTela), (lOk:= .T., oDlg:End()), Nil)},;
      bCancel:= {|| lOk:= .F., oDlg:End()}
Local cWork:= "Work"
Local lOk,;
      lAchou:= .F.,;
      lInclui
Local nCont,;
      nOpc:= nOpcx,;
      j := 0
Local oDlg,;
      oMsmGet,;
      oSelect
      
//OAP -09/11/2010- aUsuario contém os campos criados pelo usuário.
Private aUsuario := AddCpoUser({},"EXN","1")

Begin Sequence

   //Criação das variáveis de memória
   RegToMemory(cAlias, nOpc == INCLUIR)

   //Carregar dados da Work com base no registro posicionado
   If nOpc != INCLUIR
   CarregaWorkEI102(cAlias, cWork)
   EndIf

   //Campos que serão visualizados no objeto MsSelect
   AAdd(aCamposWork, {{|| (cWork)->EXN_PAIS}  ,, STR0008}) //País
   AAdd(aCamposWork, {{|| (cWork)->EXN_PAISDE},, STR0009}) //Descrição
   
   //OAP -09/11/2010- Campos criados pelo usuário a serem inseridos na MsSelect
   aCamposWork := AddCpoUser(aCamposWork,"EXN","5",cWork)
   
   //Tratamentos para visualização
   If nOpc == VISUALIZAR
     aButtons:= {{"ANALITICO", {|| ManutPaisEI102(nOpcx,VISUALIZAR, cWork)}, STR0015, STR0003}} //Visualizar Países - Visualizar
   EndIf

   //Tratamentos para inclusão
   If nOpc == INCLUIR
      aButtons:= {{"EDIT"   , {|| ManutPaisEI102(nOpcx, INCLUIR, cWork)}, STR0010, STR0011},; //Vincular Países - + País
                  {"EXCLUIR", {|| ManutPaisEI102(nOpcx, EXCLUIR, cWork)}, STR0013, STR0014}}  //Desvincular Países - - País
   EndIf

   //Tratamentos para alteração
   If nOpc == ALTERAR
      aButtons:= {{"EDIT"   , {|| ManutPaisEI102(nOpcx, INCLUIR, cWork)}, STR0010, STR0011},; //Vincular Países - + País
                  {"EXCLUIR", {|| ManutPaisEI102(nOpcx, EXCLUIR, cWork)}, STR0013, STR0014}}  //Desvincular Países - - País
   EndIf

   //Tratamentos para exclusão
   If nOpc == EXCLUIR
      aButtons:= {{"ANALITICO", {|| ManutPaisEI102(nOpcx, EXCLUIR, cWork)}, STR0015, STR0003}} //Visualizar Países - Visualizar
   EndIf


   aGets:= {}
   aTela:= {}
   aDeletados:= {}
   Define MsDialog oDlg Title cCadastro From DLG_LIN_INI, DLG_COL_INI To DLG_LIN_FIM, DLG_COL_FIM Pixel Of oMainWnd //Cadastro de Acordos Comerciais
      oMsmGet:= MsmGet()  :New(cAlias, nReg, nOpcx,,,,, PosDlgUp(oDlg),,,,,, oDlg,, .T.)
      oSelect:= MsSelect():New(cWork,,, aCamposWork,,,PosDlgDown(oDlg))

      oMsmGet:Refresh()
      oSelect:oBrowse:Refresh()
   Activate MsDialog oDlg On Init EnchoiceBar(oDlg, bOk, bCancel,, aButtons) Centered


   Do Case
      Case lOk .And. (nOpc == INCLUIR .Or. nOpc == ALTERAR)
      
         If nOpc == INCLUIR
            lInclui:= .T.
         Else
            lInclui:= .F.
         EndIf

         Begin Transaction

            (cAlias)->(RecLock(cAlias, lInclui))
            AvReplace("M", cAlias)
            (cAlias)->(MsUnlock())


            //Tratamento para atualizar a tabela EXN
            (cWork)->(DBGoTop())
            While (cWork)->(!Eof())
         
               //Adicionando os novos dados
               If (cWork)->WK_RECNO == 0
                  EXN->(RecLock("EXN", .T.))
                  EXN->EXN_PAIS:= (cWork)->EXN_PAIS
                  EXN->EXN_ACORDO  := (cAlias)->E11_CODACO
                         
                  //OAP -09/11/2010- Tratamento para que os campos incluidos pelo usuário sejam alteraveis e possam ser salvos na base
                  For j := 1 To Len(aUsuario)
                     EXN->&(aUsuario[j]) := (cWork)->&(aUsuario[j])
              	  Next j
                  
                  EXN->(MsUnlock())
               //Atualizando dados   
               Else
                  EXN->(DBGoTo((cWork)->WK_RECNO))
                  EXN->(RecLock("EXN", .F.))
                  EXN->EXN_PAIS  := (cWork)->EXN_PAIS
                  EXN->EXN_ACORDO:= (cAlias)->E11_CODACO
               
                  //OAP -09/11/2010- Tratamento para que os campos incluidos pelo usuário sejam alteraveis e possam ser salvos na base
                  For j := 1 To Len(aUsuario)
                     EXN->&(aUsuario[j]) := (cWork)->&(aUsuario[j])
              	  Next j
                  
                  EXN->(MsUnlock())
               EndIf
               (cWork)->(DBSkip())
            End

            //Excluindo dados
            For nCont:= 1 To Len(aDeletados)
               If aDeletados[nCont] <> 0
                  EXN->(DBGoTo(aDeletados[nCont]))
                  EXN->(RecLock("EXN", .F.))
                  EXN->(DBDelete())
                  EXN->(MsUnlock())
               EndIf
            Next
         End Transaction
      Case lOk .And. nOpc == EXCLUIR


         //Caso o acordo comercial esteja vinculado a uma norma, não poderá ser excluído.
         EEI->(DBSetOrder(1)) //EEI_FILIAL + EEI_COD
         EEI->(DBGoTop())

         While EEI->(!Eof())
            If AllTrim(EEI->EEI_ACCOME) == AllTrim((cAlias)->E11_CODACO)
               lAchou:= .T.
               Exit
            EndIf

            EEI->(DBSkip())
         End


         If !lAchou
            Begin Transaction

               //Exclusão do acordo
               (cAlias)->(RecLock(cAlias, .F.))
               (cAlias)->(DBDelete())
               (cAlias)->(MsUnlock())

               //Exclusão da vinculação país x norma
               (cWork)->(DBGoTop())
               While (cWork)->(!Eof())

                  EXN->(DBGoTo((cWork)->WK_RECNO))
                  EXN->(RecLock("EXN", .F.))
                  EXN->(DBDelete())
                  EXN->(MsUnlock())
                  (cWork)->(DBSkip())
               End
            End Transaction

         Else
            MsgInfo(STR0007, cCadastro) //Este registro não pode ser excluído pois possui norma de origem vinculada.
         EndIf

      OtherWise



   End Case

   (cWork)->(avzap())
End Sequence
Return

/*
Função    : CriaWorkEI102()
Objetivo  : Criar a Work para a amarração entre os acordos comerciais e os países
Parâmetros: 
Retorno   : 
Autor     : Wilsimar Fabrício da Silva
Data      : 10/12/2009
Obs.      :
*/
Static Function CriaWorkEI102()
Local cAlias:= "Work"

Begin Sequence

   aEstrutura:= {{"EXN_PAIS"  , "C", AvSx3("EXN_PAIS" , AV_TAMANHO) , 0},;
                 {"EXN_PAISDE", "C", AvSx3("YA_DESCR" , AV_TAMANHO) , 0},;
                 {"WK_RECNO"  , "N", 7                              , 0}}

   //OAP - 14/12/2010
   aEstrutura := AddCpoUser(aEstrutura,"EXN","1",cAlias)

   cArqWork := E_CriaTrab(, aEstrutura, cAlias)

   //Índice
   IndRegua(cAlias, cArqWork + TEOrdBagExt(), "EXN_PAIS")
   
End Sequence
Return


/*
Função    : CarregaWorkEI102()
Objetivo  : Carregar os dados da Work com base no registro posicionado
Parâmetros: Alias da tabela da capa, Alias da Work
Retorno   : 
Autor     : Wilsimar Fabrício da Silva
Data      : 10/12/2009
Obs.      :
*/
Static Function CarregaWorkEI102(cAlias, cWork)

Local j := 0

Begin Sequence

   EXN->(DBSetOrder(2)) //EXN_FILIAL + EXN_ACORDO + EXN_PAIS
   If EXN->(DBSeek(xFilial("EXN") + (cAlias)->E11_CODACO))  // GFP - 17/03/2014

      While EXN->(!Eof()) .And.;
            AllTrim(EXN->EXN_ACORDO) == AllTrim((cAlias)->E11_CODACO)

         (cWork)->(DBAppend())
         (cWork)->EXN_PAIS  := EXN->EXN_PAIS
         (cWork)->EXN_PAISDE:= Posicione("SYA", 1, SYA->(xFilial()) + AvKey(EXN->EXN_PAIS, "YA_CODGI"), "YA_DESCR")
         
         //OAP -09/11/2010- Tratamento para que os campos incluidos pelo usuário sejam alteraveis
         For j := 1 To Len(aUsuario)
            (cWork)->&(aUsuario[j]) := EXN->&(aUsuario[j])
         Next j
         
         (cWork)->WK_RECNO  := EXN->(RecNo())

         EXN->(DBSkip())
      End
   EndIf                             

   (cWork)->(DBGoTop())
End Sequence

Return

/*
Função    : ManutPaisEI102()
Objetivo  : Vincular países aos acordos comerciais
Parâmetros: nOpcx: ação executada pelo usuário no aRotina
            nOpc : ação executada pelo usuário ao clicar o botão da enchoicebar (incluir ou excluir).
            Nome da Work
Retorno   : 
Autor     : Wilsimar Fabrício da Silva
Data      : 25/11/2009
Obs.      :
*/

Static Function ManutPaisEI102(nOpcx, nOpc, cWork)
Local aCamposVis:= {},;
      aCamposAlt:= {},;
      aBkpaTela := AClone(aTela),;
      aBkpaGets := AClone(aGets)
Local bOk    := {|| If((Obrigatorio(aGets, aTela) .And. If(nOpc == INCLUIR,ValidPaisEI102(cWork),.T.)), (lOk:= .T., oDlg:End()), Nil)},;
      bCancel:= {|| lOk:= .F., oDlg:End()}
Local cTitulo
Local lOk
Local oDlg 
Local i := 0

Begin Sequence

   aCamposVis:= {"EXN_PAIS", "EXN_PAISDE"}

   If nOpc == INCLUIR
      cTitulo:= STR0010 //Vincular Países
   Else
      cTitulo:= STR0013 //Desvincular Países
   EndIf

   //Inclusão de países
   If (nOpcx == INCLUIR .Or. nOpcx == ALTERAR) .And. nOpc == INCLUIR

      //Carregar as variáveis de memória, de acordo com a ação executada
      RegToMemory("EXN", .T.)
      aCamposAlt:= {"EXN_PAIS", "EXN_PAISDE"}
                                                  
      //OAP - 09/11/2010 - Inclusão de campos adicionados pelo usuário. Assim os campos podem ser alteraveis na Enchoice
      For i:=1 To Len(aUsuario)
         Aadd(aCamposAlt,aUsuario[i])
      Next i
      
   EndIf

   //Exclusão de países
   If (nOpcx == INCLUIR .Or. nOpcx == ALTERAR) .And. nOpc == EXCLUIR

      If (cWork)->(EasyRecCount()) == 0
         MsgInfo(STR0012, cTitulo) //Não há itens a serem excluidos.
         Break
      Else
         M->EXN_PAIS  := (cWork)->EXN_PAIS
         M->EXN_PAISDE:= (cWork)->EXN_PAISDE    
         
         //OAP- 09/11/2010 - Inclusão de campos adicionados pelo usuário. Assim os campos podem ser alteraveis na Enchoice
         For i := 1 To Len(aUsuario)
            M->&(aUsuario[i]) := (cWork)->&(aUsuario[i])
         Next i 
         
      EndIf
   EndIf

   If nOpcx == VISUALIZAR .Or. nOpcx == EXCLUIR
      If (cWork)->(EasyRecCount()) == 0
         MsgInfo(STR0016, cTitulo) //Não há itens a serem exibidos.
         Break
      Else
         M->EXN_PAIS  := (cWork)->EXN_PAIS
         M->EXN_PAISDE:= (cWork)->EXN_PAISDE
      EndIf
      M->EXN_PAIS  := (cWork)->EXN_PAIS
      M->EXN_PAISDE:= (cWork)->EXN_PAISDE   
      
      //OAP -09/11/2010- Tratamento para que os campos incluidos pelo usuário sejam Visuais.
      For i := 1 To Len(aUsuario)
         M->&(aUsuario[i]) := (cWork)->&(aUsuario[i])
      Next i 
      
   EndIf

   aTela:= {}
   aGets:= {}
   Define MsDialog oDlg Title cTitulo From DLG_LIN_INI, DLG_COL_INI To DLG_LIN_FIM, DLG_COL_FIM Pixel Of oMainWnd

      Enchoice("EXN", 0, nOpc,,,,aCamposVis,, aCamposAlt,,,,, oDlg,, .T.)

      //Botão sem efeito, para ativar o gatilho do campo
      @ 500,048   BUTTON oBtnDes PROMPT "" SIZE 50,12

   Activate MsDialog oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) Centered

   Do Case
      Case lOk .And. nOpc == INCLUIR .And. (nOpcx == INCLUIR .Or. nOpcx == ALTERAR)
   
         (cWork)->(DBAppend())
         (cWork)->EXN_PAIS  := M->EXN_PAIS
         (cWork)->EXN_PAISDE:= M->EXN_PAISDE
              
         //OAP- 09/11/2010 - Inclusão de campos adicionados pelo usuário. Assim os campos podem ser alteraveis na Enchoice
         For i := 1 To Len(aUsuario)
             (cWork)->&(aUsuario[i]) := M->&(aUsuario[i])
         Next i 

      Case lOk .And. nOpc == EXCLUIR .And. (nOpcx == INCLUIR .Or. nOpcx == ALTERAR)

         //Adiciona no array para exclusão da tabela
         AAdd(aDeletados, (cWork)->WK_RECNO)
         //Exclusão da Work
         (cWork)->(RecLock((cWork), .F.))
         (cWork)->(DBDelete())
         (cWork)->(MsUnlock())
      OtherWise
      
      
   End Case

   aTela:= AClone(aBkpaTela)
   aGets:= AClone(aBkpaGets)
   (cWork)->(DBGoTop())
End Sequence
Return

/*
Função    : ValidPaisEI102()
Objetivo  : Verificar se o país já está vinculado ao acordo comercial
Parâmetros: Nome da Work
Retorno   : 
Autor     : Wilsimar Fabrício da Silva
Data      : 11/12/2009
Obs.      :
*/

Static Function ValidPaisEI102(cWork)
Local lRet:= .T.

Begin Sequence

   If (cWork)->(DBSeek(M->EXN_PAIS))
      MsgAlert(STR0017, STR0010) //O País informado já está vinculado à este Acordo Comercial. / Vincular Países
      lRet:= .F.
   EndIf

End Sequence
Return lRet
