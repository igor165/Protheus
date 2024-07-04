#INCLUDE "DBTREE.CH"
#INCLUDE "eeccad01.ch"
#Include "EEC.cH"

/*
Programa  : EECCAD01.PRW.
Objetivo  : Agrupar todas funcoes de manipulacao de dados do SIGAEEC. (Continuação EECCAD00).
Autor     : Jeferson Barros Jr.
Data/Hora : 07/09/04.
Obs       : 
*/

/*
Funcao      : AvTree().
Objetivos   : Criar objeto Tree.
Sintaxe     : AvTree(aTree,[aCoordenada],[aMenuPopUp],oDlg)
Parametros  : aTree        - Array com as definições para montagem da estrutura do tree.
              aCoordenada  - Coordenadas para posicionamento do tree.
              aMenuPopUp   - Opções para montagem de menu pop-up.
              oDlg         - Objeto para referência na criação do Tree.
Retorno     : Objeto tree/Nill.
Autor       : Jeferson Barros Jr.
Data/Hora   : 02/09/04 - 11:07.
Revisao     :
Obs.        : 1) aTree por dimensão: [1] - Codigo          - Utilizado na relação entre os galhos e folhas.
                                     [2] - Prompty         - Texto que será exibido no Tree.
                                     [3] - Cargo           - Chave de representacao.
                                     [4] - Resource Open   - Imagem para a pasta aberta.
                                     [5] - Resource Close  - Imagem para a pasta fechada.
                                     [6] - Cod.Galho/Folha - Utilizado na relação entre os galhos e folhas.

              2) aCoordenada por dimensão: [1] - Linha Inicial.
                                           [2] - Coluna Inicial
                                           [3] - Linha Final.
                                           [4] - Coluna Final.

              3) aMenuPopUp por dimensão: [1] - Label da Opção.
                                          [2] - CodeBlock com action.
*/
*----------------------------------------------------------*
Function AvTree(aTree,aCoordenada,aMenuPopUp,oDlg,oTreeAtu)
*----------------------------------------------------------*
Local j:=0, k:=0
Local oRet
Local aPos:={}, oMenu

Private oTree,;
        aGalhos := {}

Default aTree       := {}
Default aCoordenada := {}
Default aMenuPopUp  := {}

Begin Sequence

   If ValType(oTreeAtu) == "O"
      oTree := oTreeAtu
   EndIf

   /* A estrutura do Tree a ser construído deve obrigatóriamente ser passada
      como parâmetro. Sem esse parâmetro a função irá retornar nill */
   If Len(aTree) = 0
      Break
   EndIf

   /* Carrega as coordenadas para construção do tree, caso as coordenadas não tenham sido
      passadas como parâmetro, utiliza as coordenadas padrão da funçao AvTree. */
   If ValType(oTree) <> "O"
      If Len(aCoordenada) > 0
         aPos := aClone(aCoordenada)
      Else 
         aPos    := PosDlg(oDlg)
         aPos[1] := 015
         aPos[2] := 002
         aPos[4] := 102
      EndIf


      Define DBTREE oTree From aPos[1],aPos[2] To aPos[3],aPos[4] CARGO Of oDlg 

   EndIf

   // ** Inclui a Raiz do Tree.
   DBADDTREE oTree PROMPT PadR(AllTrim(aTree[1][2]),300);
                          OPENED ;  
                          RESOURCE aTree[1][4], aTree[1][5];
                          CARGO PadR(AllTrim(aTree[1][3]),120)

   // ** Carrega todos os galhos e folhas do tree.
   If !Empty(aTree[1][6])
      aGalhos:={{aTree[1][6],0}}

      Do While Len(aGalhos) > 0
         FindGalho(aTree,aGalhos[Len(aGalhos)][1])
      EndDo
   EndIf

   /* Cria e configura as opões para o menu pop-up de acordo com o
      conteúdo do array aMenuPopUp */

   If Len(aMenuPopUp) > 0
      MENU oMenu POPUP
         For j:=1 To Len(aMenuPopUp)
            MENUITEM aMenuPopUp[j][1] Action ""
         Next
      ENDMENU

      // ** Define o action para cada opção de MenuPopUp.
      For k:=1 To Len(oMenu:aItems)
         If ValType(aMenuPopUp[k][2]) == "B"
            oMenu:aItems[k]:bAction:= aMenuPopUp[k][2]
         EndIf
      Next

      oTree:bRClicked := { |o,nx,ny| oMenu:Activate(nX,nY,o)}
   EndIf

   oTree:Refresh()
   oTree:SetFocus()

   oRet := oTree

End Sequence

Return oRet

/*
Funcao      : FindGalho(aTree,cGalho).
Parametros  : aTree  - Array com as definições para montagem do tree.
              cGalho - Referência do galho que está sendo carregado de acordo com o aTree.
Retorno     : .t./.f.
Objetivos   : Encontrar todas as folhas do galho ativo do tree. Auxiliar a função AvTree().
Autor       : Jeferson Barros Jr.
Data/Hora   : 02/09/04 - 13:43.
Revisao     :
Obs.        :
*/
*-------------------------------------*
Static Function FindGalho(aTree,cGalho)
*-------------------------------------*
Local lRet:=.t., nPosGalho:=0
Local j:=0, lFound := .f.

Begin Sequence

    // ** Verifica a posição do(s) galho(s) filho(s).
    nPosGalho := aScan(aTree,{|x| x[1] == cGalho })

    If nPosGalho > 0 // Existe galho a ser incluso.
       If aGalhos[Len(aGalhos)][2] > 0 // Esta posição do array armazena o último galho processado.

          If nPosGalho < aGalhos[Len(aGalhos)][2]
             nPosGalho := aGalhos[Len(aGalhos)][2]
          EndIf

          nPosGalho ++
          If nPosGalho <= Len(aTree)

             /*  Varre o aTree(estrutura do tree) para verificar se existe mais algum galho a ser incluído
                 para a estrutura pertencente a 'cGalho' */
                 
             For j:=nPosGalho To Len(aTree)
                If aTree[j][1] == cGalho
                   nPosGalho := j
                   lFound    := .t.
                   Exit
                EndIf
             Next

             /* Caso não exista mais galhos a serem inclusos, elimina o 'cGalho' do
                aGalhos. (Todos as folhas deste galho já foram inclusas. */
             If !lFound
                x := aScan(aGalhos,{|x| x[1] == cGalho})
                aGalhos := aDel(aGalhos,x)
                aGalhos := aSize(aGalhos,Len(aGalhos)-1)
                DBENDTREE oTree
                Break
             EndIf
          Else             
             // Todas as folhas do galho atual já foram inclusas.             
             aGalhos := aDel(aGalhos,Len(aGalhos))
             aGalhos := aSize(aGalhos,Len(aGalhos)-1)
             DBENDTREE oTree
             Break
          EndIf
       EndIf
    Else
       // As folhas indicadas para o galho não existem na estrutura do aTree.
       x := aScan(aGalhos,{|x| x[1] == cGalho})
       aGalhos := aDel(aGalhos,x)
       aGalhos := aSize(aGalhos,Len(aGalhos)-1)
       DBENDTREE oTree
       Break
    EndIf

    aGalhos[Len(aGalhos)][2] := nPosGalho

    If !Empty(aTree[nPosGalho][6]) 
       // Inclui novo galho.
       DBADDTREE oTree PROMPT PadR(AllTrim(aTree[nPosGalho][2]),300) ;
                       OPENED RESOURCE aTree[nPosGalho][4], aTree[nPosGalho][5];
                       CARGO PadR(AllTrim(aTree[nPosGalho][3]),120)
    Else
       // Inclui nova folha.
       DBADDITEM oTree PROMPT  PadR(AllTrim(aTree[nPosGalho][2]),300) ;
                       RESOURCE aTree[nPosGalho][5] ;
                       CARGO PadR(AllTrim(aTree[nPosGalho][3]),120)
    EndIf

    // ** Inclui no aGalhos controles para o novo galho (e suas folhas) a ser tratado.
    If !Empty(aTree[nPosGalho][6])
       aAdd(aGalhos,{aTree[nPosGalho][6],0})
       FindGalho(aTree,aTree[nPosGalho][6])
    EndIf

End Sequence

Return lRet             

/*
Funcao          : AvBorda()
Parametros      : oDialog - dialog onde será desenhada a borda
                  lDupla  - define se a borda será dupla: .f. - simples (-)(default)
Retorno         : nil                                     .t. - Dupla   (=)
Objetivos       : Desenhar borda para a MsDialog
Autor           : João Pedro Macimiano Trabbold
Data/Hora       : 11/24/2004 - 9:00
Revisao         :
Obs.            : 
*/

*-------------------------------*
Function AvBorda(oDialog)
*-------------------------------*  
Local oBorda

oBorda := TGroup():New(12,2,13,3,,oDialog,,,.t.)

oBorda:Align := CONTROL_ALIGN_ALLCLIENT

Return nil

/*
Funcao          : EECRotinas(cNmRotina).
Parametros      : cNmRotina - Nome da rotina.
Retorno         : .t./.f.
Objetivos       : Verificar para a rotina passada como parâmetro se o ambiente possue todos os campos necessários 
                  para utilização da rotina.
Autor           : Jeferson Barros Jr.
Data/Hora       : 08/01/2005 - 17:08.
Revisao         :
Obs.            : 
*/
*----------------------------*
Function EECRotinas(cNmRotina)
*----------------------------*
Local lRet := .f.

Static lDicDoctos

Begin Sequence

   cNmRotina := Upper(AllTrim(cNmRotina))

   Do Case
      Case cNmRotina == "DIC_DOCS"

           /* Verifica todos os parâmetros necessários para utilização da manutenção
              de dicionários de parametrização de dicionários. */

           If ValType(lDicDoctos) = "U"
              SX2->(DbSetOrder(1))
              lDicDoctos := SX2->(DbSeek("EG4"))
           EndIf

           lRet := lDicDoctos
   EndCase

End Sequence

Return lRet

/*
Funcao     : EECDicDoc()
Parametros : Nenhum.
Retorno    : .t.
Objetivos  : Opção para manutenção dos Dicionários de Parametrização de Documentos.
Autor      : Jeferson Barros Jr.
Data/Hora  : 08/01/2005 - 17:08
Revisao    :
Obs.       : A função irá trabalhar com a Tabela EG4 além de informações diretas no Dicionário
             SX3.
*/
*------------------*
Function EECDicDoc()
*------------------*
Local lRet:=.t.
Local cOldArea:=select()

Private aRotina := MenuDef()
Private cCadastro := STR0145//"Dicionário de Documentos"
Begin Sequence

   /* Verifica se o ambiente possui todas as configurações necessárias para utilização da rotina de
      dicionário de parametrização de documentos */

   If !EECRotinas("DIC_DOCS")
      MsgStop(STR0006+; //"O ambiente não possui todas as configurações necessárias para utilização da rotina de "
              STR0007,STR0008) //"Dicionários de Parametrização de Documentos."###"Atenção"
      lRet:=.f.
      Break
   EndIf

   mBrowse(6,1,22,75,"EG4")

End Sequence

Dbselectarea(cOldArea)

Return lRet               


/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 30/01/07 - 11:35
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina :=  { {STR0001, "AxPesqui" , 0, PESQUISAR},; //"Pesquisar"
                    {STR0002, "EECDicMan", 0, VISUALIZAR},; //"Visualizar"
                    {STR0003, "EECDicMan", 0, INCLUIR},; //"Incluir"
                    {STR0004, "EECDicMan", 0, ALTERAR},;  //"Alterar"
                    {STR0005, "EECDicMan", 0, EXCLUIR,3}} //"Excluir"

// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("EDICDOCMNU")
	aRotAdic := ExecBlock("EDICDOCMNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina

/*
Funcao      : EECDicMan(cAlias,nReg,nOpc )
Parametros  : cAlias:= alias arq.
              nReg:=num.registro
              nOpc:=opcao escolhida               
Retorno     : .t./.f.
Objetivos   : Realizar a manutenção da tabela EG4 (Parametrização de Dicionários de Documentos).
Autor       : Jeferson Barros Jr.
Data/Hora   : 08/01/2005 - 18:14.
Revisao     :
Obs.        : 
*/
*-----------------------------------*
Function EECDicMan(cAlias,nReg,nOpc )
*-----------------------------------*
Local lRet:=.t., lOk:=.f.
Local cOldArea := Select(), cCadastro := AvTitCad("EG4")
Local j:=0, nChoice := 0
Local oDlg
Local aPos := {}
Local bOk := {|| If(EECDicValid(nOpc,nReg),(nChoice:=1,oDlg:End()),nil)}
Local bCancel := {|| oDlg:End()}
Local aOrd:={}, aAltera :={}

Private aTela[0][0], aGets[0]
Private aCmpEnchoice :={}

Begin Sequence

   aCmpEnchoice:= {"EG4_CODEEA","EG4_TITULO","EG4_CMPSX3","EG4_CMPAVG","EG4_USADO","EG4_TIPO" ,;
                   "EG4__ORD"  ,"EG4__TIT"  ,"EG4__DES"  ,"EG4__TIPO" ,"EG4__TAM" ,"EG4__DEC" ,;
                   "EG4__PICT" ,"EG4__VALID","EG4__INIPA","EG4__F3"   ,"EG4__CBOX","EG4__WHEN",;
                   "EG4__INIBR","EG4__PASTA","EG4__PROP" ,"EG4__OBRI" ,"EG4__VISU","EG4__TRIG"}
   
   //OAP - 04/11/2010 - Inclusão de campos adicionados pelo usuário.
   aCmpEnchoice := AddCpoUser(aCmpEnchoice,"EG4","1")

   If (nOpc == INCLUIR)
      aAltera := aClone(aCmpEnchoice)

      For j := 1 TO (cAlias)->(FCount())
         If aScan(aAltera,(cAlias)->(FieldName(j))) > 0
            M->&((cAlias)->(FieldName(j))) := CriaVar((cAlias)->(FieldName(j)))
         EndIf
      Next

   Else
      For j := 1 TO (cAlias)->(FCount())
         M->&((cAlias)->(FieldName(j))) := (cAlias)->(FieldGet(j))
      Next

      If nOpc = VISUALIZAR
         bOk := {|| nChoice := 1, oDlg:End()}
      EndIf

      If nOpc = ALTERAR
         aAltera := {"EG4_USADO", "EG4__ORD"  , "EG4__TIT"  , "EG4__DES"  , "EG4__TIPO", "EG4__TAM" ,;
                     "EG4__DEC" , "EG4__PICT" , "EG4__VALID", "EG4__INIPA", "EG4__F3"  , "EG4__CBOX",;
                     "EG4__WHEN", "EG4__INIBR", "EG4__PASTA", "EG4__PROP" , "EG4__OBRI", "EG4__VISU",;
                     "EG4__TRIG"}
      EndIf

      /* Carrega os campos virtuais para manutenção das informações 
         gravadas no SX3. */

      aOrd:=SaveOrd({"SX3"})
      SX3->(DbSetOrder(2))
      If SX3->(DbSeek(M->EG4_CMPSX3))
         M->EG4__ORD   := SX3->X3_ORDEM
         M->EG4__TIT   := SX3->X3_TITULO
         M->EG4__DES   := SX3->X3_DESCRIC
         M->EG4__TIPO  := SX3->X3_TIPO
         M->EG4__TAM   := SX3->X3_TAMANHO
         M->EG4__DEC   := SX3->X3_DECIMAL
         M->EG4__PICT  := SX3->X3_PICTURE
         M->EG4__PROP  := SX3->X3_CONTEXT
         M->EG4__VALID := SX3->X3_VALID
         M->EG4__INIPA := SX3->X3_RELACAO
         M->EG4__F3    := SX3->X3_F3
         M->EG4__CBOX  := SX3->X3_CBOX
         M->EG4__WHEN  := SX3->X3_WHEN
         M->EG4__INIBR := SX3->X3_INIBRW
         M->EG4__PASTA := SX3->X3_FOLDER
         M->EG4__TRIG  := SX3->X3_TRIGGER
         M->EG4__VISU  := SX3->X3_VISUAL
         M->EG4__OBRI  := If (SX3->X3_OBRIGAT == Chr(128),"S","N")
      EndIf
      RestOrd(aOrd)
   EndIf
   
   //OAP - 04/11/2010 - Inclusão de campos adicionados pelo usuário, permitindo assim que eles também sejam alteraveis.
    aAltera := AddCpoUser(aAltera,"EG4","1")
  
   Define MsDialog oDlg Title cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
      aPos := PosDlg(oDlg)
      EnChoice(cAlias, nReg, nOpc,,,,aCmpEnchoice,aPos,aAltera)
   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   If nChoice = 1 .And. nOpc <> VISUALIZAR
      Begin Transaction
         If nOpc == INCLUIR
            EG4->(RecLock("EG4",.t.))
            AvReplace("M","EG4")
            EG4->EG4_FILIAL := xFilial("EG4")
         ElseIf nOpc == ALTERAR
            If EG4->(RecLock("EG4",.f.))
               AvReplace("M","EG4")
            EndIf
         Else
            If EG4->(RecLock("EG4",.f.))
               EG4->(DbDelete())
            EndIf
         EndIf

         // ** Realiza a atualização do EG4, para os campos virtuais diretamente no SX3.
         EECSetSX3(nOpc,M->EG4_CMPSX3)

      End Transaction
   EndIf

End Sequence

DbSelectArea(cOldArea)           

Return lRet

/*
Funcao      : EECDicValid(nTipo,nRecNo)
Parametros  : nTipo  -> Operação Corrente.
              nRecno -> Nro. do Registro.
Retorno     : .t./.f.
Objetivos   : Realizar a validação das informações digitadas pelo usuário.
Autor       : Jeferson Barros Jr.
Data/Hora   : 08/01/2005 - 18:36.
Revisao     :
Obs.        : 
*/
*---------------------------------------*
Static Function EECDicValid(nTipo,nRecno)
*---------------------------------------*
Local lRet :=.t., aOrd:={}
Local cMsg :=""
Local nRec := 0

Begin Sequence

   Do Case
      Case nTipo == INCLUIR .Or. nTipo == ALTERAR
           lRet := Obrigatorio(aGets,aTela)

           If !lRet
              Break
           EndIf
           
           If nTipo == INCLUIR
              aOrd:=SaveOrd({"EG4"})
              EG4->(DbSetOrder(2))
              If EG4->(DbSeek(xFilial("EG4")+M->EG4_TIPO+M->EG4_CODEEA+M->EG4_CMPSX3+M->EG4_CMPAVG))
                 MsgStop(STR0009+AllTrim(M->EG4_CMPSX3)+STR0010+; //"O campo '"###"' já está cadastrado para o documento '"
                                     AllTrim(M->EG4_CODEEA)+STR0011+AllTrim(M->EG4_CMPAVG)+"' "+; //"' vinculado ao campo '"
                                     STR0012+If(M->EG4_TIPO="C",STR0013,STR0014)+"'.",STR0008) //"para o tipo '"###"Capa"###"Detalhe"###"Atenção"
                 lRet:=.f.
                 RestOrd(aOrd,.t.)
                 Break
              EndIf
           EndIf

           /* Verificar o campo cadastrado já está vinculado em outros campos do Header_p
              Detail_p. */

           aOrd:=SaveOrd({"EG4"})
           nRec := EG4->(Recno())
           EG4->(DbSetOrder(2))
           If EG4->(DbSeek(xFilial("EG4")+M->EG4_TIPO+M->EG4_CODEEA+M->EG4_CMPSX3))

              Do While EG4->(!Eof()) .And. EG4->EG4_FILIAL == xFilial("EG4") .And.;
                                           EG4->EG4_TIPO   == M->EG4_TIPO    .And.;
                                           EG4->EG4_CODEEA == M->EG4_CODEEA  .And.;
                                           EG4->EG4_CMPSX3 == M->EG4_CMPSX3
                 If EG4->(Recno()) <> nRec
                    If Empty(cMsg)
                       cMsg := STR0009+M->EG4_CMPSX3+STR0015+; //"O campo '"###"' já possui vinculação com o(s) seguinte(s) campo(s):"
                               Replic(ENTER,2)

                       cMsg += IncSpace(STR0016,10,.f.)+ENTER //"Campo(s)"
                       cMsg += Replic("-",10)+ENTER
                    EndIf
                    cMsg += IncSpace(EG4->EG4_CMPAVG,10,.f.)+ENTER
                 EndIf

                 EG4->(DbSkip())
              EndDo

              If !Empty(cMsg)
                 cMsg += Replic(ENTER,2)
                 cMsg += STR0017+Replic(ENTER,2) //"As alterações, serão replicadas em todas as vinculações."
                 cMsg += STR0018 //"Confirma a atualização ?"

                 If !EECView(cMsg,STR0019) //"Parametrização de Doctos - Validações"
                    lRet := .f.
                 EndIf
              EndIf
           EndIf
           RestOrd(aOrd,.t.)

      Case nTipo == EXCLUIR
           lRet := MsgYesNo(STR0020,STR0008) //"Confirma a exclusão?"###"Atenção"
   EndCase

End Sequence

Return lRet

/*
Funcao      : EECCmpVld(cCampo)
Parametros  : cCampo.
Retorno     : .t./.f.
Objetivos   : Realizar a validação das informações digitadas pelo usuário na validação dos campos.
              Chamada a partir do X3_VALID.
Autor       : Jeferson Barros Jr.
Data/Hora   : 10/01/2005 - 17:15.
Revisao     :
Obs.        :
*/
*------------------------*
Function EECCmpVld(cCampo)
*------------------------*
Local lRet:=.t., aOrd:={}
Local cAlias, cX, cChave

Begin Sequence

  cCampo := Upper(AllTrim(cCampo))

  If Empty(cCampo)
     lRet:=.f.
     Break
  EndIf

  Do Case
     Case cCampo == "EG4_CODEEA"
          If !ExistCpo("EEA")
             lRet:=.f.
             Break
          EndIf

          aOrd:=SaveOrd({"EEA"})
          EEA->(DbSetOrder(1))
          If EEA->(DbSeek(xFilial("EEA")+M->EG4_CODEEA))
             If Left(EEA->EEA_TIPDOC,1) <> "2"
                MsgStop(STR0021,STR0008) //"Selecione apenas impessões do tipo 'Documento'."###"Atenção"
                lRet:=.f.
             EndIf

             If !Empty(EEA->EEA_DOCBAS)
                MsgStop(STR0043+; //"Selecione apenas documentos origem. Documentos com base de impressão informada "
                        STR0044,STR0008) //"não serão aceitos."
                lRet:=.f.
             EndIf
          EndIf
          RestOrd(aOrd,.t.)

     Case cCampo == "EG4_CMPSX3"
          If !Empty(M->EG4_CMPSX3)
             If Left(M->EG4_CMPSX3,3) <> "EG4"
                MsgStop(STR0022,STR0008) //"Nome de campo inválido. O nome deve conter as iniciais 'EG4'."###"Atenção"
                lRet:=.f.
                Break
             EndIf
          EndIf

          // ** Verifica se o campo incluído é de uso interno.
          If aScan(aCmpEnchoice,M->EG4_CMPSX3) > 0
             MsgStop(STR0009+M->EG4_CMPSX3+STR0023,STR0008) //"O campo '"###"' é de uso interno e não poderá ser incluído."###"Atenção"
             lRet:=.f.
          EndIf

     Case cCampo == "EG4_CMPAVG"
          cAlias := If(M->EG4_TIPO == "C","Header_p","Detail_p")
          If (cAlias)->(FieldPos(M->EG4_CMPAVG)) = 0
             MsgStop(STR0009+AllTrim(M->EG4_CMPAVG)+STR0024+; //"O campo '"###"' não existe no arquivo de geração "
                     STR0025+cAlias+"'",STR0008) //"de documentos '"###"Atenção"
             lRet:=.f.
             Break
          EndIf

     Case cCampo == "EG4__F3"
          aOrd:=SaveOrd({"SXB"})
          SXB->(DbSetOrder(1))
          If !SXB->(DbSeek(M->EG4__F3))
             MsgStop(STR0026,STR0008) //"A consulta padrão digitada não existe no dicionário."###"Atenção"
             lRet:=.f.
          EndIf
          RestOrd(aOrd)

     Case cCampo == "EG4__PASTA"
          If (M->EG4_TIPO = "D")
             MsgStop(STR0027,STR0008) //"Para registros do tipo 'Detalhe', o campo 'Pasta' não deverá ser preenchido."###"Atenção"
             lRet:=.f.
             Break
          EndIf

          aOrd:=SaveOrd({"SXA"})
          SXA->(DbSetOrder(1))
          If !SXA->(DbSeek("EG4"+M->EG4__PASTA))
             MsgStop(STR0028,STR0008) //"A pasta digitada não existe no dicionário para a tabela 'EG4'."###"Atenção"
             lRet:=.f.
          EndIf
          RestOrd(aOrd)

     Case cCampo == "EG4_TIPO"
          If !Empty(M->EG4_CMPAVG)
             cAlias := If(M->EG4_TIPO == "C","Header_p","Detail_p")
             If (cAlias)->(FieldPos(M->EG4_CMPAVG)) = 0
                MsgStop(STR0009+AllTrim(M->EG4_CMPAVG)+STR0024+; //"O campo '"###"' não existe no arquivo de geração "
                        STR0025+cAlias+"'",STR0008) //"de documentos '"###"Atenção"
                lRet:=.f.
                Break
             EndIf
          EndIf

     Case cCampo == "EEA_TABCAP"
          aOrd:= SaveOrd({"SX2"})
          SX2->(DbSetOrder(1))
          If !SX2->(DbSeek(M->EEA_TABCAP))
             MsgStop(STR0029+AllTrim(M->EEA_TABCAP)+STR0030,STR0008) //"A tabela '"###"' não existe no SX2."###"Atenção"
             lRet:=.f.
          EndIf
          RestOrd(aOrd)

     Case cCampo == "EEA_TABDET"
          aOrd:= SaveOrd({"SX2"})
          SX2->(DbSetOrder(1))
          If !SX2->(DbSeek(M->EEA_TABDET))
             MsgStop(STR0029+AllTrim(M->EEA_TABDET)+STR0030,STR0008) //"A tabela '"###"' não existe no SX2."###"Atenção"
             lRet:=.f.
          EndIf
          RestOrd(aOrd)

     Case cCampo == "EEA_CHAVE"
          cChave := AllTrim(M->EEA_CHAVE)
          cX := SubStr(cChave,1,(At("=",M->EEA_CHAVE)-1))

          If M->EEA_TABDET $ cX
             MsgStop(STR0031,STR0008) //"Chave Inválida. Verifique a expressão digitada"###"Atenção"
             lRet:=.f.
          EndIf

     Case cCampo == "EEA_DOCBAS"

          If !ExistCpo("EEA")
             lRet:=.f.
             Break
          EndIf

          aOrd:=SaveOrd({"EEA"})
          EEA->(DbSetOrder(1))
          If EEA->(DbSeek(xFilial("EEA")+M->EEA_DOCBAS))
             If Left(EEA->EEA_TIPDOC,1) <> "2"
                MsgStop(STR0021,STR0008) //"Selecione apenas impessões do tipo 'Documento'."###"Atenção"
                lRet:=.f.
             EndIf

             If !Empty(EEA->EEA_DOCBAS)
                MsgStop(STR0043+; //"Selecione apenas documentos origem. Documentos com base de impressão informada "
                        STR0044,STR0008) //"não serão aceitos."
                lRet:=.f.
             EndIf
          EndIf
          RestOrd(aOrd,.t.)

     Case cCampo == "EG4__ORD" 

          //JPM - 19/09/05 - Preenchimento da ordem com o máximo de Dígitos, completando com 0 (zero) (padrão do SX3 - 2 dígitos) - Auto-Adaptável
          If !Empty(M->EG4__ORD) 
             If Len(AllTrim(M->EG4__ORD)) < AvSx3("EG4__ORD",AV_TAMANHO)
                M->EG4__ORD := Repl("0",AvSx3("EG4__ORD",AV_TAMANHO) - Len(AllTrim(M->EG4__ORD))) + AllTrim(M->EG4__ORD)
             EndIf
          EndIf
          
  EndCase

End Sequence

Return lRet

/*
Funcao      : EECSetCmp(cCampo).
Parametros  : cCampo.
Retorno     : .t./.f.
Objetivos   : Carregar campos diversos. (Chamada Via Gatilho).
Autor       : Jeferson Barros Jr.
Data/Hora   : 11/01/2005 - 10:27.
Revisao     :
Obs.        :
*/
*------------------------*
Function EECSetVld(cCampo)
*------------------------*
Local lRet:=.t., aOrd:={}

Begin Sequence

   cCampo := Upper(AllTrim(cCampo))

   Do Case
      Case cCampo == "EG4_CMPSX3"

           aOrd:=SaveOrd({"EG4","SX3"})

           /* Carrega os campos virtuais para manutenção das informações 
              que serão gravadas no SX3. */

           SX3->(DbSetOrder(2))
           If SX3->(DbSeek(M->EG4_CMPSX3))
              M->EG4__ORD   := SX3->X3_ORDEM
              M->EG4__TIT   := SX3->X3_TITULO
              M->EG4__DES   := SX3->X3_DESCRIC
              M->EG4__TIPO  := SX3->X3_TIPO
              M->EG4__TAM   := SX3->X3_TAMANHO
              M->EG4__DEC   := SX3->X3_DECIMAL
              M->EG4__PICT  := SX3->X3_PICTURE
              M->EG4__PROP  := SX3->X3_CONTEXT
              M->EG4__VALID := SX3->X3_VALID
              M->EG4__INIPA := SX3->X3_RELACAO
              M->EG4__F3    := SX3->X3_F3
              M->EG4__CBOX  := SX3->X3_CBOX
              M->EG4__WHEN  := SX3->X3_WHEN
              M->EG4__INIBR := SX3->X3_INIBRW
              M->EG4__PASTA := SX3->X3_FOLDER
              M->EG4__TRIG  := SX3->X3_TRIGGER
              M->EG4__VISU  := SX3->X3_VISUAL
              M->EG4__OBRI  := If (SX3->X3_OBRIGAT == Chr(128),"S","N")
           EndIf
           
           EG4->(DbSetOrder(2))
           If EG4->(DbSeek(xFilial("EG4")+M->EG4_TIPO+M->EG4_CODEEA+M->EG4_CMPSX3))
              M->EG4_USADO  := EG4->EG4_USADO
              M->EG4_TIPO   := EG4->EG4_TIPO
           EndIf          
           RestOrd(aOrd,.t.)
   EndCase

End Sequence

Return lRet

/*
Funcao      : EECSetSX3(nOpc,cCampo).
Parametros  : nOpc (Inclusão/Alteração/Exclusão).
              cCampo -> Campo a ser Incluído/Atualizado/Excluído.
Retorno     : .t./.f.
Objetivos   : Atualizar o SX3 de acordo com a opção.
Autor       : Jeferson Barros Jr.
Data/Hora   : 11/01/2005 - 11:57.
Revisao     :
Obs.        : Realiza a gravação do SX3 para inclusão/alteração/exclusão de campos no dicionário 
              visto que a enchoice irá utilizar as informações para montagem e realização de 
              tratamentos diversos na tela.
*/
*------------------------------------*
Static Function EECSetSX3(nOpc,cCampo)
*------------------------------------*
Local lRet:=.t.
/* wfs 29/set/2017
   retirada a atribuição à metadados
, aOrd:=SaveOrd({"SX3"})

Begin Sequence

  If (nOpc == INCLUIR)
     SX3->(RecLock("SX3",.t.))
  Else
     SX3->(DbSetOrder(2))
     If SX3->(DbSeek(cCampo))
        SX3->(RecLock("SX3",.f.))
        If nOpc == EXCLUIR
           SX3->(DbDelete())
        EndIf
     EndIf
  EndIf

  If nOpc == INCLUIR .Or. nOpc == ALTERAR
     SX3->X3_ARQUIVO := "EG4"
     SX3->X3_ORDEM   := M->EG4__ORD
     SX3->X3_CAMPO   := M->EG4_CMPSX3
     SX3->X3_TIPO    := M->EG4__TIPO
     SX3->X3_TAMANHO := M->EG4__TAM
     SX3->X3_DECIMAL := M->EG4__DEC
     SX3->X3_TITULO  := M->EG4__TIT
     SX3->X3_DESCRIC := M->EG4__DES
     SX3->X3_PICTURE := M->EG4__PICT
     SX3->X3_VALID   := M->EG4__VALID
     SX3->X3_RELACAO := M->EG4__INIPA
     SX3->X3_F3      := M->EG4__F3
     SX3->X3_NIVEL   := 1
     SX3->X3_TRIGGER := M->EG4__TRIG
     SX3->X3_PROPRI  := Space(1)
     SX3->X3_VISUAL  := M->EG4__VISU
     SX3->X3_CONTEXT := "V"
     SX3->X3_CBOX    := M->EG4__CBOX
     SX3->X3_WHEN    := M->EG4__WHEN
     SX3->X3_INIBRW  := M->EG4__INIBR
     SX3->X3_FOLDER  := M->EG4__PASTA
     SX3->X3_BROWSE  := "N"

     // Campos para controle de campos obrigatórios no EG4.
     SX3->X3_USADO  := Replic(Chr(128),14)+Chr(160)

     SX3->X3_RESERV := Chr(254)+Chr(192)

     If (EG4__OBRI $ cSim)
        SX3->X3_OBRIGAT := Chr(128)
     Else
        SX3->X3_OBRIGAT := Space(1)
     EndIf
  EndIf

End Sequence
RestOrd(aOrd)
*/
Return lRet

/*
Funcao      : AvTelaGets().
Parametros  : lCall    -> .t. = Chamada automática pela rotina de geração de documentos. (Default).
                          .f. = Chamada manual via rdmake.
              cCodDoc  -> Código do Documento.
              aPos     -> Coordenadas da oDlg:
                          [1][1] - Linha Inicial.
                             [2] - Coluna Inicial
                             [3] - Linha Final.
                             [4] - Coluna Final.
Retorno     : .t./.f.
Objetivos   : Geração Automática de Documentos.
              Funcionalidades: a) Criação de tela de parâmetros com os seguintes objetos:
                                  - Enchoice com as informações de capa a serem editadas antes da impressão
                                    do documento;
                                  - Browse com as informações de detalhe a serem editadas.
                                    (A edição das informações, será realizada diretamente no browse);
                                  - EnchoiceBar;
                                  - Botão para carregar histórico da última impressão (Capa);
                                  - Folders para inclusão da enchoice e folder para browse com os itens.
                               b) Carregar histórico de tela da última impressão;
                               c) Gravar histórico de tela da última impressão;
                               d) Gravar histórico do documento. (Header_H/Detail_H);
                               e) Gravar as tabelas do documento. (Header_p/Detail_p).
Autor       : Jeferson Barros Jr.
Data/Hora   : 13/01/2005 - 09:33.
Revisao     :
Obs.        : 1) Para que a função possa trabalhar corretamente, a tabela de parametrização de 
                 documentos deverá estar preenchida;
              2) A função poderá ser disparada, tanto automaticamente (pela rotina de geração de documentos) como
                 manualmente via rdmake. Neste caso deverão ser enviados os parâmetros.
*/
*-----------------------*
Function AvTelaGets(aPos)
*-----------------------*
Local cOldArea := Alias()

Local lRet := .f., lFolder := .t., lGravou := .f., lGravouTudo := .f.
Local cTitulo, cNomArq, cChave, cAliasCapa, cAliasDet,;
      cFunLinOk, cKey, cFiltro

Local aOrd:=SaveOrd({"EEA","EG4","SX3","SX2"}), aCmpEnchoice:={},;
      aPosDlg:={}, aAltera:={}, aStruct := {}, aAvgCapa:={}, aAvgItem:={}
      
Local nOpca := 0, nIndice := 0, j:=0, nIdSubRel := 0, k:=0, nRec:=0

Local bCancel := {|| oDlg:End(), lRet := .f.},;
      bOk     := {|| If(AvTelaValid(),(lRet := .t.,nOpca := 1,oDlg:End()),nil)}

Private oDlg, oMsmGet, oMsGetDb, oFld, oFldCapa, oFldItem
Private aButtons :={}
Private nUsado   := 0
Private aTela[0][0], aGets[0]
Private aCampos := {}, aHeader := {} , aCols:={}
Private lRefresh := .t., lCapa := .f., lItem := .f., lTela := .t.
Private cDoc, cPtoEntrada

Default aPos  := {9,0,35,90}

Begin Sequence

    /* by jbj - 07/06/05 - Neste ponto através da variável lShowTela a função exibirá ou não a tela
                           de parâmetros.*/
    If Type("lShowTela") == "L"
       lTela := lShowTela
    EndIf

    If !lTela
       nOpca := 1
    EndIf

    cDoc := WorkId->EEA_COD

    EEA->(DbSetOrder(1))
    EEA->(DbSeek(xFilial("EEA")+cDoc))

    /* Caso o campo de documento base esteja preenchido posiciona no documento de origem para realizaçao
       da impressão do documento */

    If !Empty(EEA->EEA_DOCBAS)
       cDoc := EEA->EEA_DOCBAS
       EEA->(DbSeek(xFilial("EEA")+cDoc))
    EndIf

    /* Validações Iniciais.
       - Verifica se a parametrização de documentos foi realizada corretamente. */

    If /*1*/EEA->EEA_DOCAUT $ cNao .Or.;
       /*2*/(Empty(EEA->EEA_TABCAP) .And. Empty(EEA->EEA_TABDET)) .Or.;
       /*3*/(!Empty(If(EEA->EEA_INDICE = 0,"","a")+EEA->EEA_CHAVE+EEA->EEA_FILTRO) .And.;
             (Empty(EEA->EEA_TABDET) .Or. Empty(EEA->EEA_TABCAP) .Or. Empty(EEA->EEA_INDICE) .Or. Empty(EEA->EEA_CHAVE))) .Or.;
       /*4*/((!Empty(EEA->EEA_TABCAP) .And. !Empty(EEA->EEA_TABDET)) .And.;
             (Empty(EEA->EEA_INDICE) .Or. Empty(EEA->EEA_CHAVE) )  )
       
       
       MsgStop(STR0032+; //"A parametrização do documento foi realizada incorretamente. Revise "
               STR0033,STR0008) //"os dados informados."###"Atenção"
       lRet:=.f.
       Break
       
    EndIf 
    
    cTitulo    := Capital(EEA->EEA_TITULO)
    cAliasCapa := EEA->EEA_TABCAP
    cAliasDet  := EEA->EEA_TABDET
    cChave     := EEA->EEA_CHAVE
    nIndice    := EEA->EEA_INDICE
    cFunLinOk  := "EECDicLinOk"

    // ** Tratamentos para definiçao do filtro de dados.
    cFiltro := If(Empty(EEA->EEA_FILTRO),".t.",EEA->EEA_FILTRO)

    // ** Tratamentos para definicao do nome do ponto de entrada a ser utilizado em toda a função.
    cPtoEntrada := If(Empty(EEA->EEA_PE),"EECCAD01",EEA->EEA_PE)

    // ** Realiza a leitura da parametrização dos documentos no EG4.
    EG4->(DbSetOrder(1))
    If EG4->(DbSeek(xFilial("EG4")+AvKey(cDoc,"EG4_CODEEA")))
       Do While EG4->(!Eof()) .And. EG4->EG4_FILIAL == xFilial("EG4") .And.;
                                    EG4->EG4_CODEEA == AvKey(cDoc,"EG4_CODEEA")

          If EG4->EG4_TIPO == "C" // Campos da capa.

             /* Verifica quais campos deverão aparecer na tela e carrega a cria as 
                variáveis de memória. */

             If EG4->EG4_USADO $ cSim // Exibir na tela?
                If aScan(aCmpEnchoice,EG4->EG4_CMPSX3) == 0
                   aAdd(aCmpEnchoice,EG4->EG4_CMPSX3)
                EndIf
             EndIf

             M->&(EG4->EG4_CMPSX3) := CRIAVAR(EG4->EG4_CMPSX3)

             lCapa := .t. // Indica que existe campos a serem exibidos na enchoice.

             // ** Caso o campo possuir folder, habilita a exibição dos folders na enchoice.
             SX3->(DbSetOrder(2))
             If SX3->(DbSeek(EG4->EG4_CMPSX3))
                If !Empty(SX3->X3_FOLDER)
                   lFolder := .f.
                EndIf
             EndIf

             // ** Monta array de controle para gravação dos campos a serem impressos no RPT.
             If aScan(aAvgCapa,{|x| x[1] == EG4->EG4_CMPAVG}) = 0
                aAdd(aAvgCapa,{EG4->EG4_CMPAVG,EG4->EG4_CMPSX3})
             EndIf
          Else
             lItem := .t. // Flag de controle.
             nUsado++
             Aadd(aStruct,{EG4->EG4_CMPSX3,;
                           AvSx3(EG4->EG4_CMPSX3,AV_TIPO),;
                           AvSx3(EG4->EG4_CMPSX3,AV_TAMANHO),;
                           AvSx3(EG4->EG4_CMPSX3,AV_DECIMAL)})

             If EG4->EG4_USADO $ cSim // Exibir na tela?
                Aadd(aHeader,{AvSx3(EG4->EG4_CMPSX3,AV_TITULO)  ,;
                              EG4->EG4_CMPSX3,;
                              AvSx3(EG4->EG4_CMPSX3,AV_PICTURE) ,;
                              AvSx3(EG4->EG4_CMPSX3,AV_TAMANHO) ,;
                              AvSx3(EG4->EG4_CMPSX3,AV_DECIMAL) ,;
                              Posicione("SX3",2,EG4->EG4_CMPSX3,"X3_VALID"),;
                              "",;
                              AvSx3(EG4->EG4_CMPSX3,AV_TIPO),;
                              "",;
                              ""})
             EndIf

             // ** Monta array de controle para gravação dos campos a serem impressos no RPT.
             If aScan(aAvgItem,{|x| x[1] == EG4->EG4_CMPAVG}) = 0 
                aAdd(aAvgItem,{EG4->EG4_CMPAVG,EG4->EG4_CMPSX3})
             EndIf

             If EG4->EG4_USADO $ cSim // Exibir na tela?
                SX3->(DbSetOrder(2))
                If SX3->(DbSeek(EG4->EG4_CMPSX3))
                   If (SX3->X3_VISUAL = "A" .Or. Empty(SX3->X3_VISUAL))
                      aAdd(aAltera,EG4->EG4_CMPSX3)
                   EndIf
                EndIf
             EndIf
          EndIf
          EG4->(DbSkip())
       EndDo
    EndIf

    If lItem
       aAdd(aStruct,{"RECNO","N",07,0})
       aAdd(aStruct,{"FLAG","L",1,0})
       aAdd(aStruct,{"DBDELETE","L",1,0}) //THTS - 31/10/2017 - Este campo deve sempre ser o ultimo campo da Work

       If Select("Wk_Tmp") == 0
          cNomArq:= E_CriaTrab(,aStruct,"Wk_Tmp")
       Endif

       If EasyEntryPoint(cPtoEntrada)
          lGravou := ExecBlock(cPtoEntrada,.F.,.F.,{"PE_GRAVAWORK",cDoc})
          If ValType(lGravou) <> "L"
             lGravou := .f.
          Endif
       EndIf

       If !lGravou
          If Empty(cChave)
             lRet:=.f.
             Break
          EndIf

          (cAliasDet)->(DbSetOrder(nIndice))
          (cAliasDet)->(DbSeek(xFilial(cAliasDet)+&(AllTrim(SubStr(cChave,1,At("=",cChave)-1)))))
          Do While (cAliasDet)->(!Eof()) .And. xFilial(cAliasDet) == (cAliasDet)->&(cAliasDet+"_FILIAL") .And.;
                                               &(cChave) // .And. &(cFiltro)
             If &("!("+cFiltro+")") // FJH 21/12/05
                (cAliasDet)->(DbSkip()) // By JPP - 16/05/2006 - 15:30
                Loop
             Endif
             Wk_Tmp->(DbAppend())
             For j := 1 TO Wk_Tmp->(FCount())
                If ! Wk_Tmp->(FieldName(j)) $ "FLAG/DBDELETE/RECNO"
                   Wk_Tmp->&(FieldName(j)) := CriaVar(Wk_Tmp->(FieldName(j)))
                EndIf
             Next
             (cAliasDet)->(DbSkip())
          EndDo
          Wk_Tmp->(DbGoTop())
       EndIf
    EndIf

    aButtons := {{"OPEN",{|| MsAguarde({|| MsProcTxt(STR0034),; //"Recuperando dados do histórico."
                             EECHist(aAvgCapa,aAvgItem),EECRefresh()}, STR0035)},; //"Histórico"
                             STR0036}} //"Histórico Última Impressão"

    If EasyEntryPoint(cPtoEntrada)
       lRet := ExecBlock(cPtoEntrada,.F.,.F.,{"PE_INI",cDoc})
       If ValType(lRet) = "L" .And. !lRet
          Break
       Else
          lRet := .t.
       EndIf   
    EndIf

    If lItem
       // ** Leitura dos dados dos detalhes.
       Wk_Tmp->(DbSetOrder(0))
       Wk_Tmp->(DbGoTop())
    EndIf

    If lTela
       Define MsDialog oDlg Title cTitulo From aPos[1],aPos[2] To aPos[3],aPos[4] Of oMainWnd

          // ** Monta os folders.
          aPosDlg := PosDlg(oDlg)
          aPosDlg [3] -= 25

          Do Case
             Case lCapa .And. lItem
                  oFld := TFolder():New(aPosDlg[1],aPosDlg[2],;
                                       {"&"+STR0041,"&"+STR0042},{"CAP","DET"},oDlg,,,,.t.,.f.,aPosDlg[4],aPosDlg[3]) //"Geral"###"Detalhes"
             Case lCapa .And. !lItem
                  oFld := TFolder():New(aPosDlg[1],aPosDlg[2],;
                                       {STR0041},{"CAP"},oDlg,,,,.t.,.f.,aPosDlg[4],aPosDlg[3]) //"Geral"
             Case !lCapa .And. lItem
                  oFld := TFolder():New(aPosDlg[1],aPosDlg[2],;
                                       {STR0042},{"DET"},oDlg,,,,.t.,.f.,aPosDlg[4],aPosDlg[3]) //"Detalhes"
          EndCase
          aEval(oFld:aControls,{|x| x:SetFont(oDlg:oFont)})
   
          If EasyEntryPoint(cPtoEntrada)  // By JPP - 25/08/2005 - 11:00 - Inclusão do ponto de entrada.
             ExecBlock(cPtoEntrada,.F.,.F.,{"PE_INI_TELA",cDoc})
          EndIf

          If lCapa
             aPosDlg[1] -= 13
             aPosDlg[3] -= 15
             aPosDlg[4] -= 02

             // Tratamentos para montagem da enchoice.
             oFldCapa := oFld:aDialogs[1]
             oMsmGet  := MsmGet():New("EG4",, 4,,,,aCmpEnchoice,{aPosDlg[1],aPosDlg[2],aPosDlg[3],aPosDlg[4]},;
                                      ,3,,,,oFldCapa,,,,,lFolder)
          EndIf
       
          If lItem
             // Tratamentos para Montagem da MsGetDb com os dados para edição das linhas.
             Private aRotina := {{"","",0,4}}
             If lCapa
                oFldItem := oFld:aDialogs[2]
             Else
                oFldItem := oFld:aDialogs[1]
             EndIf

             Wk_Tmp->(oMsGetDb:=MsGetDb():New(aPosDlg[1],aPosDlg[2],aPosDlg[3],aPosDlg[4],1,cFunLinOk,,;
                      ,.t.,aAltera,,.t.,,"Wk_Tmp",,,,oFldItem))
          EndIf

          If EasyEntryPoint(cPtoEntrada)
             ExecBlock(cPtoEntrada,.F.,.F.,{"PE_TELA",cDoc})
          EndIf

       Activate MsDialog oDlg On Init (EnchoiceBar(oDlg,bOk,bCancel,,aButtons),nBtLin:=1) Centered

    EndIf

    If nOpca = 1

       /* Grava as tabelas do Crystal.
          Grava o histórico de documentos. */

       cSEQREL :=GetSXENum("SY0","Y0_SEQREL")
       ConfirmSx8()

       If EasyEntryPoint(cPtoEntrada)
          lGravouTudo := ExecBlock(cPtoEntrada,.F.,.F.,{"PE_GRAVATUDO",cDoc})
          If ValType(lGravouTudo) <> "L"
             lGravouTudo := .f.
          Endif
       EndIf

       If !lGravouTudo
          Header_p->(DbAppend())
          Header_p->AVG_FILIAL := xFilial("SY0")
          Header_p->AVG_SEQREL := cSEQREL

          SX2->(DbSetOrder(1))
          If !SX2->(DbSeek(EEA->EEA_TABCAPA))
             MsgInfo(STR0037+; //"A leitura dos dados da última impressão não pode ser realiza. Verifique a configuração das "
                     STR0038,STR0008) //"tabelas de capa e detalhe do dicionário SX2 (Coluna X2_UNICO)."###"Atenção"
             lRet:=.f.
             Break
          EndIf

          cKey := (EEA->EEA_TABCAPA)->&(AllTrim(SubStr(FWX2Unico(EEA->EEA_TABCAPA),At("+",FWX2Unico(EEA->EEA_TABCAPA))+1)))
          Header_p->AVG_CHAVE  := cKey

          If lCapa
             For j:=1 To Len(aAvgCapa)
                If AvSx3(aAvgCapa[j][2],AV_TIPO) <> "M"
                   Header_p->&(aAvgCapa[j][1]) := TrataTipo(aAvgCapa[j][2],aAvgCapa[j][1])
                Else
                   nIdSubRel++
                   Header_p->&(aAvgCapa[j][1]) := "H"+StrZero(nIdSubRel,09)

                   nLinhas := MlCount(M->&(aAvgCapa[j][2]),AvSx3(aAvgCapa[j][2],AV_TAMANHO))
                   For k:=1 To nLinhas
                      Detail_p->(DbAppend())
                      Detail_p->AVG_FILIAL  := xFilial("SY0")
                      Detail_p->AVG_SEQREL  := cSEQREL
                      Detail_p->AVG_CHAVE   := "H"+StrZero(nIdSubRel,09)
                      Detail_p->AVG_C01150  := MemoLine(M->&(aAvgCapa[j][2]),AvSx3(aAvgCapa[j][2],AV_TAMANHO),k)
                   Next
                EndIf
             Next

             /*
             // ** Grava o histórico de documentos.
             Header_h->(dbAppend())
             AvReplace("Header_p","Header_h") */
          EndIf

          If lItem
             nIdSubRel := 0
             Wk_Tmp->(DbGoTop())
             Do While Wk_Tmp->(!Eof())

                If Wk_Tmp->DBDELETE
                   Wk_Tmp->(DbSkip())
                   Loop
                EndIf

                Detail_p->(DbAppend())
                Detail_p->AVG_FILIAL := xFilial("SY0")
                Detail_p->AVG_SEQREL := cSEQREL
                Detail_p->AVG_CHAVE  := cKey

                For j:=1 To Len(aAvgItem)
                   If AvSx3(aAvgItem[j][2],AV_TIPO) <> "M"
                      Detail_p->&(aAvgItem[j][1]) := TrataTipo(aAvgItem[j][2],aAvgItem[j][1],.f.)
                   Else
                      nIdSubRel++
                      Detail_p->&(aAvgItem[j][1]) := "D"+StrZero(nIdSubRel,09)

                      nRec:= Detail_p->(RecNo())
                      nLinhas := MlCount(Wk_Tmp->&(aAvgItem[j][2]),AvSx3(aAvgItem[j][2],AV_TAMANHO))
                      For k:=1 To nLinhas
                         Detail_p->(DbAppend())
                         Detail_p->AVG_FILIAL := xFilial("SY0")
                         Detail_p->AVG_SEQREL := cSEQREL
                         Detail_p->AVG_CHAVE  := "D"+StrZero(nIdSubRel,09)
                         Detail_p->AVG_C01150 := MemoLine(Wk_Tmp->&(aAvgItem[j][2]),AvSx3(aAvgItem[j][2],AV_TAMANHO),k)
                      Next

                      Detail_p->(DbGoTo(nRec))
                      Detail_p->(RecLock("Detail_p",.f.))
                   EndIf
                Next
                Wk_Tmp->(DbSkip())
             EndDo
          EndIf
       EndIf

       If EasyEntryPoint(cPtoEntrada)
          ExecBlock(cPtoEntrada,.F.,.F.,{"PE_GRV",cDoc})
       EndIf
       
       If lCapa
          // ** Grava o histórico de documentos.
          Header_h->(dbAppend())
          AvReplace("Header_p","Header_h")
       EndIf
              
       If lItem .Or. nIdSubRel > 0 
          Detail_p->(dbSetOrder(0))
          Detail_p->(DbGoTop())
          Do While Detail_p->(!Eof())
             Detail_h->(DbAppend())
             AvReplace("Detail_p","Detail_h")
             Detail_p->(DbSkip())
          EndDo
          Detail_p->(DbSetOrder(1))
       EndIf    
    EndIf

End Sequence

If Select("Wk_Tmp") > 0
   Wk_Tmp->(E_EraseArq(cNomArq))
Endif

RestOrd(aOrd)
DbSelectArea(cOldArea)

Return lRet

/*
Funcao      : EECDicLinOk().
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Validar a linha da MsGetDb com os detalhes do documento. Utilização na
              rotina de parametrização de documentos.
Autor       : Jeferson Barros Jr.
Data/Hora   : 14/01/2005 - 13:43.
Revisao     :
Obs.        : 
*/
*--------------------*
Function EECDicLinOk()
*--------------------*
Local lRet := .t.

Begin Sequence

   If EasyEntryPoint(cPtoEntrada)
      lRet := ExecBlock(cPtoEntrada,.F.,.F.,{"PE_LINOK",cDoc})
      If ValType(lRet) <> "L"
         lRet := .t.
      Endif
   EndIf

End Sequence

Return lRet

/*
Funcao      : AvTelaValid()
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Validações no botão ok antes da impressão do documento.
Autor       : Jeferson Barros Jr.
Data/Hora   : 15/01/2005 - 16:50.
Revisao     :
Obs.        :
*/
*--------------------*
Function AvTelaValid()
*--------------------*
Local lRet:=.t.

Begin Sequence

   lRet := Obrigatorio(aGets,aTela)

   If !lRet
      Break
   EndIf
   
   If EasyEntryPoint(cPtoEntrada)
      lRet := ExecBlock(cPtoEntrada,.F.,.F.,{"PE_VLDFINAL",cDoc})
      If ValType(lRet) <> "L"
         lRet := .t.
      Endif
   EndIf

End Sequence

Return lRet                      

/*
Funcao      : EECHist().
Parametros  : aAvgCapa - Relação de campos entre Arquivo Crystal e EG4. (Capa).
              aAvgItem - Relação de campos entre Arquivo Crystal e EG4. (Item).
Retorno     : .t./.f.
Objetivos   : Carregar o histórico da tela da última impressão.
Autor       : Jeferson Barros Jr.
Data/Hora   : 15/01/2005 - 19:45.
Revisao     :
Obs.        : Todos os campos memo, tanto da capa como dos itens serão carregados.
*/
*----------------------------------*
Function EECHist(aAvgCapa, aAvgItem)
*----------------------------------*
Local lRet := .t., cTabCapa, cSY0Seq, cKey, cFase, cVal
Local aOrd:= SaveOrd({"SX3","SX2","SY0"}), aMemosCapa:= {}, aMemosItem := {}
Local nPos := 0, j:=0
Local cText, cOldChave, cCmpMemo

Begin Sequence

   cTabCapa := EEA->EEA_TABCAP

   Do Case
      Case substr(EEA->EEA_FASE,1,1) == "2"
    	   cFase := "1"
      Case substr(EEA->EEA_FASE,1,1) == "3"
    	   cFase := "2"
      Case substr(EEA->EEA_FASE,1,1) == "1"
    	   cFase := "3"
      Case substr(EEA->EEA_FASE,1,1) == "4"
           cFase := "4"
   End Case

   SX2->(DbSetOrder(1))
   If !SX2->(DbSeek(cTabCapa))
      MsgInfo(STR0037+; //"A leitura dos dados da última impressão não pode ser realiza. Verifique a configuração das "
              STR0038,STR0008) //"tabelas de capa e detalhe do dicionário SX2 (Coluna X2_UNICO)."###"Atenção"
      lRet:=.f.
      Break
   EndIf

   If !lImprPadrao .And. EECFlags("INVOICE")
         cKey := WorkEXP->EXP_NRINVO
         cFase := "I"
   Else
      // ** Considera as informações do SX2, para encontrar a chave de pesquisa.
      cKey := (cTabCapa)->&(AllTrim(SubStr(FWX2Unico(cTabCapa),At("+",FWX2Unico(cTabCapa))+1)))
   EndIf

   SY0->(DbSetOrder(4))
   If !SY0->(DbSeek(xFilial("SY0")+cKey+cFase+WorkId->EEA_COD))
      // ** JPM - se não achar o histórico com base na fase do EEA, procura com base na fase informada na primeira tela de parâmetros de docs.
      lBreak := .t.
      If WorkId->EEA_FASE = "1" .And. Type("cChosenFase") = "C" //Todas
         Do Case
            Case substr(cChosenFase,1,1) == "2"
               cFase := "1"
            Case substr(cChosenFase,1,1) == "3"
               cFase := "2"
            Case substr(cChosenFase,1,1) == "1"
               cFase := "3"
            Case substr(cChosenFase,1,1) == "4"
               cFase := "4"
         End Case
         If SY0->(DbSeek(xFilial("SY0")+cKey+cFase+WorkId->EEA_COD))
            lBreak := .f.
         EndIf
      EndIf
      // **
      If lBreak
         MsgInfo(STR0039,STR0008) //"Não há dados para restauração."###"Atenção"
         lRet:=.f.
         Break
      EndIf
   EndIf
   
   If !MsgYesNo(STR0040,STR0008) //"Confirma a restauração dos dados da últimas impressão ?"###"Atenção"
      lRet:=.f.
      Break
   EndIf

   Do While SY0->(!Eof()) .And. SY0->Y0_FILIAL  = XFILIAL("SY0") .And.;
                                SY0->Y0_PROCESS = cKey  .And.;
                                SY0->Y0_FASE    = cFase .And.;
                                SY0->Y0_CODRPT  = WorkId->EEA_COD
      cSY0Seq:= SY0->Y0_SEQREL
      SY0->(DbSkip())
   EndDo
   
   If !lImprPadrao .And. EECFlags("INVOICE")      
      SIX->(DbSetOrder(1))
      If SIX->(DbSeek(cTabCapa))
         cKey := (cTabCapa)->&(AllTrim(SubStr(SIX->CHAVE,At("+",SIX->CHAVE)+1)))
      EndIf
   EndIf
   If EasyEntryPoint(cPtoEntrada)
      xRetPos := ExecBlock(cPtoEntrada,.F.,.F.,{"PE_POSICIONA_HIST",cDoc,aAvgCapa,aAvgItem})
      If ValType(xRetPos) = "C"
         cSY0Seq := xRetPos
      ElseIf ValType(xRetPos) = "L" .And. xRetPos = .f.
         lRet := .f.
         Break
      EndIf
   EndIf
   
   SX3->(DbSetOrder(2))
   If lCapa
      // ** Carrega as informações da capa.
      Header_h->(DbSetOrder(1))
      //If Header_h->(DbSeek("  "+cSY0Seq+cKey))
      If Header_h->(DbSeek(xFilial("SY0")+cSY0Seq+cKey))
         For j:= 1 To Len(aAvgCapa)
            If SX3->(DbSeek(aAvgCapa[j][2]))
               // ** Realiza os tratamentos para os campos memos.
               Do Case
                  Case SX3->X3_TIPO = "C"
                       M->&(aAvgCapa[j][2]) := Header_h->&(aAvgCapa[j][1])

                  Case SX3->X3_TIPO = "N"
                       IF ValType(Header_h->&(aAvgCapa[j][1])) == "C"     // By JPP - 10/03/2005 - 16:35 - Deve-se verificar se o campo do documento é do tipo caracter, antes de fazer o tratamento do campo.
                          cVal := StrTran(Header_h->&(aAvgCapa[j][1]),".","")
                          cVal := StrTran(cVal,",",".") 
                          M->&(aAvgCapa[j][2]) := Val(cVal)
                       Else
                          M->&(aAvgCapa[j][2]) := Header_h->&(aAvgCapa[j][1])
                       Endif
                       

                  Case SX3->X3_TIPO = "D"    // By JPP - 10/03/2005 - 16:35 - Deve-se verificar se o campo do documento é do tipo data, antes de fazer o tratamento do campo.
                       M->&(aAvgCapa[j][2]) := IF(ValType(Header_h->&(aAvgCapa[j][1])) == "C",AvCtoD(Header_h->&(aAvgCapa[j][1])),Header_h->&(aAvgCapa[j][1]))

                  Case SX3->X3_TIPO = "M"
                       aAdd(aMemosCapa,{Header_h->&(aAvgCapa[j][1]),aAvgCapa[j][2],""})
               EndCase
            EndIf
         Next
      EndIf
   EndIf

   If lItem
      Wk_Tmp->(avzap())
   EndIf

   Detail_h->(DbSetOrder(1))
   If Detail_h->(DbSeek(xFilial("SY0")+cSY0Seq))
      Do While Detail_h->(!Eof()) .And. Detail_h->AVG_SEQREL == cSY0Seq

         /* Verifica se o registro pertence à algum sub-relatório da capa do
            documento. */

         If Detail_h->AVG_CHAVE <> cKey .And. Left(Detail_h->AVG_CHAVE,1) == "H"
            nPos :=  aScan(aMemosCapa,{|x| AllTrim(x[1]) == AllTrim(Detail_h->AVG_CHAVE)})
            If nPos > 0
               aMemosCapa[nPos][3] += RTrim(Detail_h->AVG_C01150)+ENTER
               Detail_h->(DbSkip())
               Loop
            EndIf
         EndIf

         // Carrega o histórico dos detalhes.
         If lItem
            If Detail_h->AVG_CHAVE = cKey // Neste caso não é registro de sub-relatório.

               aMemosItem := {}
               // ** Carrega as informações dos campos do detalhe.
               Wk_Tmp->(DbAppend())
               For j:= 1 To Len(aAvgItem)
                  If SX3->(DbSeek(aAvgItem[j][2]))
                     Do Case
                        Case SX3->X3_TIPO = "C"
                             Wk_Tmp->&(aAvgItem[j][2]) := Detail_h->&(aAvgItem[j][1])

                        Case SX3->X3_TIPO = "N"
                             IF ValType(Detail_h->&(aAvgItem[j][1])) == "C"   // By JPP - 10/03/2005 - 16:35 - Deve-se verificar se o campo do documento é do tipo caracter, antes de fazer o tratamento do campo.
                                cVal := StrTran(Detail_h->&(aAvgItem[j][1]),".","")
                                cVal := StrTran(cVal,",",".")
                                Wk_Tmp->&(aAvgItem[j][2]) := Val(cVal)
                             Else
                                Wk_Tmp->&(aAvgItem[j][2]) := Detail_h->&(aAvgItem[j][1])
                             Endif

                        Case SX3->X3_TIPO = "D"   // By JPP - 10/03/2005 - 16:35 - Deve-se verificar se o campo do documento é do tipo data, antes de fazer o tratamento do campo.
                             Wk_Tmp->&(aAvgItem[j][2]) := IF(ValType(Detail_h->&(aAvgItem[j][1])) == "C",AvCtoD(Detail_h->&(aAvgItem[j][1])),Detail_h->&(aAvgItem[j][1]))

                        Case SX3->X3_TIPO = "M"
                             aAdd(aMemosItem,{Detail_h->&(aAvgItem[j][1]),aAvgItem[j][2],""})
                     EndCase
                  EndIf
               Next

               If Len(aMemosItem) > 0
                  nRec := Detail_h->(RecNo())
                  For j:=1 To Len(aMemosItem)
                     If Detail_h->(DbSeek(xFilial("SY0")+cSY0Seq+aMemosItem[j][1]))
                        Do While Detail_h->(!Eof()) .And. Detail_h->AVG_SEQREL == cSY0Seq .And.;
                                                 AllTrim(Detail_h->AVG_CHAVE)  == AllTrim(aMemosItem[j][1])

                           aMemosItem[j][3] += RTrim(Detail_h->AVG_C01150)+ENTER
                           Detail_h->(DbSkip())
                        EndDo
                     EndIf
                  Next
                  Detail_h->(DbGoTo(nRec))

                  For j:=1 To Len(aMemosItem)
                     Wk_Tmp->&(aMemosItem[j][2]) := aMemosItem[j][3]
                  Next
               EndIf
            EndIf
         EndIf
         Detail_h->(DbSkip())
      EndDo

      If Len(aMemosCapa) > 0
         For j:=1 to Len(aMemosCapa)
            M->&(aMemosCapa[j][2]) := aMemosCapa[j][3]
         Next
      EndIf

      If lItem
         Wk_Tmp->(DbGoTop())
      EndIf
   EndIf

   If EasyEntryPoint(cPtoEntrada)
      ExecBlock(cPtoEntrada,.F.,.F.,{"PE_HISTORICO",cDoc,aAvgCapa,aAvgItem})
   EndIf

End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : TrataTipo()
Parametros  : cCmpOrig => Campo de origem dos dados.
              cCmpDes  => Campo de destino dos dados.
              lCapa    => .t. - Arquivo de Capa.
              lCapa    => .t. - Arquivo de Capa.
                          .f. - Arquivo de Item.
Retorno     : Valor convertido. (De acordo com as condições).
Objetivos   : Realizar a conversão de tipos de acordo com os campos recebido como parâmetro,
              para alimentação das tabelas para impressão dos documentos.
Autor       : Jeferson Barros Jr.
Data/Hora   : 18/01/2005 - 19:27.
Revisao     :
Obs.        :
*/
*-----------------------------------------------*
Static Function TrataTipo(cCmpOrig,cCmpDes,lCapa)
*-----------------------------------------------*
Local cRet:="", cTpFrom, cTpTo, cAlias, cAliasAux

Default lCapa := .t.

Begin Sequence

   If Empty(cCmpOrig) .Or. Empty(cCmpDes)
      Break
   EndIf

   cAlias    := If(lCapa,"Header_p","Detail_p")
   cAliasAux := If(lCapa,"M","Wk_Tmp")

   cTpFrom := Type(cAliasAux+"->"+cCmpOrig)
   cTpTo   := Type(cAlias+"->"+cCmpDes)

   If cTpFrom == cTpTo
      cRet := If(lCapa,M->&(cCmpOrig),Wk_Tmp->&(cCmpOrig))
   Else
      Do Case
         Case (cTpFrom =="N" .And. cTpTo == "C")
              cRet := If(lCapa,;
                         AllTrim(Transf(M->&(cCmpOrig),AvSx3(cCmpOrig,AV_PICTURE))),;
                         AllTrim(Transf(Wk_Tmp->&(cCmpOrig),AvSx3(cCmpOrig,AV_PICTURE))))

         Case (cTpFrom =="D" .And. cTpTo == "C")
              cRet := If(lCapa,;
                         Transf(M->&(cCmpOrig),AvSx3(cCmpOrig,AV_PICTURE)),;
                         Transf(Wk_Tmp->&(cCmpOrig),AvSx3(cCmpOrig,AV_PICTURE)))
      EndCase
   EndIf

End Sequence

Return cRet

/*
Funcao      : AvRelacao()
Parametros  : cNmCampo => Nome do campo
Retorno     : Retorna inicializador padrão.
Objetivos   : Realizar tratamentos diversos a serem utilizados no inicializador padrão de campos 
              específicos.
Autor       : Jeferson Barros Jr.
Data/Hora   : 21/02/2005 - 16:43.
Revisao     :
Obs.        :
*/
*--------------------------*
Function AvRelacao(cNmCampo)
*--------------------------*
Local xRet, cKey

Begin Sequence

   cNmCampo := AllTrim(Upper(cNmCampo))

   Do Case
      Case cNmCampo == "EEA_TITDB"
           aOrd := SaveOrd({"EEA"})
           cKey := If(INCLUI .Or. ALTERA,M->EEA_DOCBAS,EEA->EEA_DOCBAS)

           xRet := Space(AvSx3(cNmCampo,AV_TAMANHO))
           If !Empty(cKey)
              xRet := Posicione("EEA",1,xFilial("EEA")+cKey,"EEA_TITULO")
           EndIf

           RestOrd(aOrd,.t.)
   EndCase

End Sequence

Return xRet

/*
Funcao      : EECRefresh()
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Refresh na Enchoice e na MsgetDb().
Autor       : Jeferson Barros Jr.
Data/Hora   : 19/01/2005 - 15:51.
Revisao     :
Obs.        :
*/
*--------------------------*
Static Function EECRefresh()
*--------------------------*
Local lRet:=.t.

Begin Sequence

   If lCapa
      oMsmGet:Refresh()
   EndIf
   If lItem      
      oMsGetDb:nCount:= Wk_Tmp->(EasyReccount("Wk_Tmp"))
      oMsGetDb:ForceRefresh()
   EndIf

End Sequence

Return lRet

/*
Funcao     : AvDocSetup()
Parametros : cOcorrencia: OC_PE (Pedido) ou OC_EM (Embarque)
             aChecks: Valor default das opções de check boc:
                      [1] - Nome da Variavel
                      [2] - Conteudo Padrão              
                      
                      Exemplo: AvDocSetup(OC_PE,{{"lFpCodD",.T.}}) // Incializar Descrição da Familia Marcado.

Retorno    : xRet - Se clicar em "Cancelar", retorna .f. 
                    Se "Ok", retorna array com 3 posições:
                    [1] - String com os campos a serem impressos, separados por "/", de acordo com o que o usuário
                          selecionar na tela, tanto os campos de código como os de descrição. Possíveis campos:
                          _________________________________________________
                         | Código     | Descrição  | Definição             |
                         |____________|____________|_______________________|
                         | *não tem*  | EE8_REFCLI | Referência do Cliente |
                         | EE8_DPCOD  | EEG_NOME   | Divisão               |
                         | EE8_GPCOD  | EEH_NOME   | Grupo                 |
                         | EE8_FPCOD  | YC_NOME    | Família               |
                         | EE8_NALSH  | J1_DESC    | NALADI SH             |
                         | EE8_NLNCCA | J2_DESC    | NALADI NCCA           |
                         | EE8_POSIPI | YD_DESC_P  | NCM                   |
                         | EE8_COD_I  | EE8_VM_DES | Código do Item        |
                         |____________|____________|_______________________|
                         
                         Obs.: Campos que estão com EE8 variam dependendo da ocorrência:
                                  OC_PE (Pedido)   - EE8
                                  OC_EM (Embarque) - EE9
                                         
                    [2] - CodeBlock p/ ordenar pelos campos selecionados. Ex: {||EE8->EE8_POSIPI + EE8->EE8_COD_I}
                            Obs.: se usuário selecionar "Nao" na pergunta "Ordenar?", retorna codeblock com Recno
                            
                    [3] - Array com 6 posições, sendo:
                          [1] - Caracter, unidade de medida de Peso
                          [2] - Caracter, unidade de medida de Preço
                          [3] - Caracter, unidade de medida de Quantidade
                          [4] - Lógico, define se será impresso o peso bruto
                          [5] - Lógico, define se os itens serão totalizados
                          [6] - Lógico, define se salta linha entre os itens
                            
                                              
Objetivos  : Filtro genérico para documentos que utilizem itens do pedido ou embarque
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 08/02/05 - 8:30
Revisao    : Crisitano - Novo parametro aChecks para receber os valores default
             Leandro Brito - Novo parametro 'cPe' para chamada de ponto de entrada no OK
             da AvDocSetup
Obs.       :
*/
*------------------------------*
Function AvDocSetup(cOcorrencia,aChecks,cPe)
*------------------------------*
Local xRet := {}, oDlg, lOk, bOk := {|| If(EECValSetup(),(oDlg:End(),lOk := .t.),)},;
      bCancel := {|| oDlg:End(),lOk := .f.},;
      cAliasIt, oFld, aPosDlg, oFldCapa, oFldDet, nLinha := 13, nX := 14, nColuna := 9,;
      nInc1 := 67.5 , nInc2 := 118, cCpos := {}, aCompl := {}, bOrd, ;
      aSimNao := {STR0045,STR0046}/*"Sim","Nao"*/, cPesoBruto := Space(3), cTotItens := Space(3),;
      cSaltaLinha := Space(3), cOrdenar := Space(3), oBtMarca
      
Local i, xVar // by CAF 12/03/2005

Private lRefCliC := .f.,lDpCodC  := .f.,lGpCodC  := .f.,lFpCodC  := .f.,;
        lNalSHC  := .f.,lNlNCCAC := .f.,lPosIPIC := .f.,lCod_IC := .f.
Private lRefCliD := .f.,lDpCodD  := .f.,lGpCodD  := .f.,lFpCodD  := .f.,;
        lNalSHD  := .f.,lNlNCCAD := .f.,lPosIPID := .f.,lCod_ID := .f.
Private cUnPes := Space(2),cUnPrc := Space(2),cUnidad := Space(2)  
Private cPtoVal := cPe   //Leandro D. de Brito 12/03/2005 
Default aChecks := {}

Begin Sequence
   // by CAF 12/03/2005 - Inicializa defaults
   For i:=1 To Len(aChecks)
      xVar := aChecks[i,1] // Variavel a ser inicializada
      
      IF ValType(xVar) <> "U"
         IF Type(xVar) == ValType(aChecks[i,2])
            &xVar := aChecks[i,2]
         Endif
      Endif
   Next i
   
   If cOcorrencia == OC_PE
      cAliasIt := "EE8"
   Else
      cAliasIt := "EE9"
   EndIf
   
   Define MsDialog oDlg Title STR0047 From 1,1 to 342,320 of oMainWnd Pixel //"Parametros do Documento"
      
      aPosDlg := PosDlg(oDlg)
      aPosDlg[1] -= 1
      aPosDlg[3] -= 12
      
      oFld := TFolder():New(aPosDlg[1],aPosDlg[2],{"&"+STR0048,"&"+STR0049},;//"Descricao","Complemento"
                            {"CAP","DET"},oDlg,,,,.t.,.f.,aPosDlg[4],aPosDlg[3])
      oFldCapa := oFld:aDialogs[1]
      oFldDet  := oFld:aDialogs[2]
      
      // FOLDER 1
      @ 2,2   to 124,53    Label STR0050 Pixel Of oFldCapa //"Dados"
      @ 2,54  to 124,104   Label STR0051 Pixel Of oFldCapa //"Codigo"
      @ 2,105 to 124,155.5 Label STR0052 Pixel Of oFldCapa //"Descricao"
      
      //Referência do Cliente
      @ nLinha      ,nColuna Say AvSx3(cAliasIt+"_REFCLI",AV_TITULO) Size 80,07 Pixel Of oFldCapa
      @ nLinha      ,nColuna + nInc1 CHECKBOX lRefCliC PROMPT "" When .f. OF oFldCapa SIZE 10,8 PIXEL 
      @ nLinha      ,nColuna + nInc2 CHECKBOX lRefCliD PROMPT "" OF oFldCapa SIZE 10,8 PIXEL 
      
      //Divisão
      @ nLinha += nX,nColuna Say AvSx3(cAliasIt+"_DPCOD" ,AV_TITULO) Size 80,07 Pixel Of oFldCapa
      @ nLinha      ,nColuna + nInc1 CHECKBOX lDpCodC PROMPT "" OF oFldCapa SIZE 10,8 PIXEL 
      @ nLinha      ,nColuna + nInc2 CHECKBOX lDpCodD PROMPT "" OF oFldCapa SIZE 10,8 PIXEL 
      
      //Grupo
      @ nLinha += nX,nColuna Say AvSx3(cAliasIt+"_GPCOD" ,AV_TITULO) Size 80,07 Pixel Of oFldCapa
      @ nLinha      ,nColuna + nInc1 CHECKBOX lGpCodC PROMPT "" OF oFldCapa SIZE 10,8 PIXEL 
      @ nLinha      ,nColuna + nInc2 CHECKBOX lGpCodD PROMPT "" OF oFldCapa SIZE 10,8 PIXEL
      
      //Família 
      @ nLinha += nX,nColuna Say AvSx3(cAliasIt+"_FPCOD" ,AV_TITULO) Size 80,07 Pixel Of oFldCapa
      @ nLinha      ,nColuna + nInc1 CHECKBOX lFpCodC PROMPT "" OF oFldCapa SIZE 10,8 PIXEL 
      @ nLinha      ,nColuna + nInc2 CHECKBOX lFpCodD PROMPT "" OF oFldCapa SIZE 10,8 PIXEL
      
      //NALADI SH 
      @ nLinha += nX,nColuna Say AvSx3(cAliasIt+"_NALSH" ,AV_TITULO) Size 80,07 Pixel Of oFldCapa
      @ nLinha      ,nColuna + nInc1 CHECKBOX lNalSHC PROMPT "" OF oFldCapa SIZE 10,8 PIXEL 
      @ nLinha      ,nColuna + nInc2 CHECKBOX lNalSHD PROMPT "" OF oFldCapa SIZE 10,8 PIXEL 
      
      //NALADI NCCA
      @ nLinha += nX,nColuna Say AvSx3(cAliasIt+"_NLNCCA",AV_TITULO) Size 80,07 Pixel Of oFldCapa
      @ nLinha      ,nColuna + nInc1 CHECKBOX lNlNCCAC PROMPT "" OF oFldCapa SIZE 10,8 PIXEL 
      @ nLinha      ,nColuna + nInc2 CHECKBOX lNlNCCAD PROMPT "" OF oFldCapa SIZE 10,8 PIXEL 
      
      //NCM
      @ nLinha += nX,nColuna Say AvSx3(cAliasIt+"_POSIPI",AV_TITULO) Size 80,07 Pixel Of oFldCapa
      @ nLinha      ,nColuna + nInc1 CHECKBOX lPosIPIC PROMPT "" OF oFldCapa SIZE 10,8 PIXEL 
      @ nLinha      ,nColuna + nInc2 CHECKBOX lPosIPID PROMPT "" OF oFldCapa SIZE 10,8 PIXEL 
      
      //Item
      @ nLinha += nX,nColuna Say AvSx3(cAliasIt+"_COD_I" ,AV_TITULO) Size 80,07 Pixel Of oFldCapa
      @ nLinha      ,nColuna + nInc1 CHECKBOX lCod_IC PROMPT "" OF oFldCapa SIZE 10,8 PIXEL 
      @ nLinha      ,nColuna + nInc2 CHECKBOX lCod_ID PROMPT "" OF oFldCapa SIZE 10,8 PIXEL
      
      @ 123,2 to 142,155.5 Pixel Of oFldCapa
      
      @ nLinha += (nX + 5) ,nColuna Say STR0053 Size 80,07 Pixel Of oFldCapa //"Ordenar?"
      TComboBox():New(nLinha - 2,nColuna + 27,bSETGET(cOrdenar),aSimNao,40,8,oFldCapa,,,,,,.T.)
      
      @ nLinha - 2 ,nColuna + 76 BUTTON oBtMarca PROMPT STR0054 ; //"Marca / Desmarca Todos"
                                 SIZE 65,11 ACTION EECMarca() Of oFldCapa Pixel
                                                              
      //FOLDER 2
      
      @ 2,2   to 142,155.5  Label STR0055 Pixel Of oFldDet //"Opcoes"
      nLinha := 13
      nX     := 21
      
      @ nLinha      ,nColuna Say AvSx3(cAliasIt+"_UNPES" ,AV_TITULO) Size 80,07 Pixel Of oFldDet
      @ nLinha - 2  ,nColuna + nInc1 MsGet cUnPes  F3 "SAH" Picture "@!" Valid (Vazio() .Or. ExistCpo("SAH"));
                                                                                 Size 40,07 Of oFldDet Pixel
      
      @ nLinha += nX,nColuna Say AvSx3(cAliasIt+"_UNPRC" ,AV_TITULO) Size 80,07 Pixel Of oFldDet
      @ nLinha - 2  ,nColuna + nInc1 MsGet cUnPrc  F3 "SAH" Picture "@!" Valid (Vazio() .Or. ExistCpo("SAH"));
                                                                                 Size 40,07 Of oFldDet Pixel
      
      @ nLinha += nX,nColuna Say AvSx3(cAliasIt+"_UNIDAD",AV_TITULO) Size 80,07 Pixel Of oFldDet
      @ nLinha - 2  ,nColuna + nInc1 MsGet cUnidad F3 "SAH" Picture "@!" Valid (Vazio() .Or. ExistCpo("SAH"));
                                                                                 Size 40,07 Of oFldDet Pixel
      
      @ nLinha += nX,nColuna Say STR0056 Size 80,07 Pixel Of oFldDet //"Imprime Peso Bruto?"
      TComboBox():New(nLinha - 2,nColuna + nInc1,bSETGET(cPesoBruto),aSimNao,40,8,oFldDet,,,,,,.T.)   
      
      @ nLinha += nX,nColuna Say STR0057 Size 80,07 Pixel Of oFldDet //"Totaliza Itens?"
      TComboBox():New(nLinha - 2,nColuna + nInc1,bSETGET(cTotItens),aSimNao,40,8,oFldDet,,,,,,.T.)         

      @ nLinha += nX,nColuna Say STR0058 Size 80,07 Pixel Of oFldDet //"Salta Linha entre itens?"
      TComboBox():New(nLinha - 2,nColuna + nInc1,bSETGET(cSaltaLinha),aSimNao,40,8,oFldDet,,,,,,.T.)   
        
   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) Centered
   
   If lOk
      //Campos de Código
      cCpos := cAliasIt + "_PRECO/" +; //Preco
               If(lDpCodC ,cAliasIt + "_DPCOD/" ,"")+; //Divisão
               If(lGpCodC ,cAliasIt + "_GPCOD/" ,"")+; //Grupo
               If(lFpCodC ,cAliasIt + "_FPCOD/" ,"")+; //Família
               If(lNalSHC ,cAliasIt + "_NALSH/" ,"")+; //NALADI SH
               If(lNlNCCAC,cAliasIt + "_NLNCCA/","")+; //NALADI NCCA
               If(lPosIPIC,cAliasIt + "_POSIPI/","")+; //NCM
               If(lCod_IC ,cAliasIt + "_COD_I/" ,"")   //Código do Item
               
      //Campos de Descrição
      cCpos += If(lRefCliD,cAliasIt + "_REFCLI/" ,"")+; //Referência do Cliente
               If(lDpCodD ,"EEG_NOME/" ,"")+;           //Descrição da Divisão
               If(lGpCodD ,"EEH_NOME/" ,"")+;           //Descrição do Grupo
               If(lFpCodD ,"YC_NOME/"  ,"")+;           //Descrição da Família
               If(lNalSHD ,"J1_DESC/"  ,"")+;           //Descrição da NALADI SH
               If(lNlNCCAD,"J2_DESC/"  ,"")+;           //Descrição da NALADI NCCA
               If(lPosIPID,"YD_DESC_P/","")+;           //Descrição da NCM
               If(lCod_ID ,cAliasIt + "_VM_DES/" ,"")   //Descrição do produto
      
      If cOrdenar == aSimNao[1]
      
         bOrd :=              "{|| Str(" + cAliasIt + "->" + cAliasIt + "_PRECO) + " + ;
                               If(lRefCliD,cAliasIt + "->" + cAliasIt + "_REFCLI + ","") +;
                 If(lDpCodC  .Or. lDpCodD ,cAliasIt + "->" + cAliasIt + "_DPCOD + " ,"") +;
                 If(lGpCodC  .Or. lGpCodD ,cAliasIt + "->" + cAliasIt + "_GPCOD + " ,"") +;
                 If(lFpCodC  .Or. lFpCodD ,cAliasIt + "->" + cAliasIt + "_FPCOD + " ,"") +;
                 If(lNalSHC  .Or. lNalSHD ,cAliasIt + "->" + cAliasIt + "_NALSH + " ,"") +;
                 If(lNlNCCAC .Or. lNlNCCAD,cAliasIt + "->" + cAliasIt + "_NLNCCA + ","") +;
                 If(lPosIPIC .Or. lPosIPID,cAliasIt + "->" + cAliasIt + "_POSIPI + ","") +;
                 If(lCod_IC  .Or. lCod_ID ,cAliasIt + "->" + cAliasIt + "_COD_I + " ,"")
                 
         bOrd := SubStr(bOrd,1,RAt("+",bOrd)-1)+" }"
         
      Else
         bOrd := "{ || Str(" + cAliasIt +"->(RecNo()) ) }"
         
      EndIf
      
      bOrd := &(bOrd)
   
      aCompl := {cUnPes,cUnPrc,cUnidad,If(cPesoBruto  = aSimNao[1],.t.,.f.),If(cTotItens = aSimNao[1],.t.,.f.),;
                                       If(cSaltaLinha = aSimNao[1],.t.,.f.) }
      
      xRet := {cCpos,bOrd,aCompl}
      
   Else
      xRet := .f.
   EndIf   
   
End Sequence

Return xRet


/*
Funcao      : EECMarca()
Parametros  : 
Retorno     : NIl
Objetivos   : Marcar/desmarcar todos os checkbox da tela de parâmetros de documentos
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 08/02/05 - 16:30
Revisao     :
Obs.        :
*/
*------------------------------*
Static Function EECMarca()
*------------------------------*
Begin Sequence

   If lDpCodC  == .t. .And. lGpCodC  == .t. .And. lFpCodC  == .t. .And. ;
      lNalSHC  == .t. .And. lNlNCCAC == .t. .And. lPosIPIC == .t. .And. lCod_IC  == .t. .And.;
      lRefCliD == .t. .And. lDpCodD  == .t. .And. lGpCodD  == .t. .And. lFpCodD  == .t. .And. ;
      lNalSHD  == .t. .And. lNlNCCAD == .t. .And. lPosIPID == .t. .And. lCod_ID  == .t.
    
      lDpCodC  := .f.; lGpCodC  := .f.; lFpCodC  := .f.
      lNalSHC  := .f.; lNlNCCAC := .f.; lPosIPIC := .f.; lCod_IC  := .f.
      lRefCliD := .f.; lDpCodD  := .f.; lGpCodD  := .f.; lFpCodD  := .f.
      lNalSHD  := .f.; lNlNCCAD := .f.; lPosIPID := .f.; lCod_ID  := .f.
   
   Else
      lDpCodC  := .t.; lGpCodC  := .t.; lFpCodC  := .t.
      lNalSHC  := .t.; lNlNCCAC := .t.; lPosIPIC := .t.; lCod_IC  := .t.
      lRefCliD := .t.; lDpCodD  := .t.; lGpCodD  := .t.; lFpCodD  := .t.
      lNalSHD  := .t.; lNlNCCAD := .t.; lPosIPID := .t.; lCod_ID  := .t.
      
   EndIf
   
End Sequence

Return Nil

/*
Funcao      : EECValSetup()
Parametros  : 
Retorno     : .t./.f.
Objetivos   : Validar a tela de parâmetros do documento
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 08/02/05 - 17:30
Revisao     :
Obs.        :
*/
*---------------------------*
Static Function EECValSetup()
*---------------------------*
Local lRet

Begin Sequence   

   If lDpCodC  == .f. .And. lGpCodC  == .f. .And. lFpCodC  == .f. .And. ;
      lNalSHC  == .f. .And. lNlNCCAC == .f. .And. lPosIPIC == .f. .And. lCod_IC  == .f. .And.;
      lRefCliD == .f. .And. lDpCodD  == .f. .And. lGpCodD  == .f. .And. lFpCodD  == .f. .And. ;
      lNalSHD  == .f. .And. lNlNCCAD == .f. .And. lPosIPID == .f. .And. lCod_ID  == .f.
      MsgInfo(STR0059,STR0060)//"Selecione ao menos um codigo ou descricao a ser impresso.","Aviso"
      lRet := .f.
      Break
      
   EndIf   
   
   If !(Empty(cUnPrc)  .Or. ExistCpo("SAH", cUnPrc )) .Or. ;
      !(Empty(cUnPes)  .Or. ExistCpo("SAH", cUnPes )) .Or. ;
      !(Empty(cUnidad) .Or. ExistCpo("SAH", cUnidad))
      
      lRet := .f.
      Break
      
   EndIf
   //Leandro Diniz de Brito - 12/03/2005
   If Valtype(cPtoVal) == "C" .And. EasyEntryPoint(cPtoVal)
       lRet := Execblock(cPtoVal,.F.,.F.)
   Endif

End Sequence   

//Leandro Diniz de Brito - 12/03/2005
If Valtype(lRet) <> "L"
    lRet := .T.
Endif

Return lRet

/*                                                                                                  
Funcao.....: AVSELPROC
Objetivo...: EXIBE UM MSSELECT COM OPCAO DE MARCAR OS PROCESSO PARA IMPRESSAO.
             LE DADOS DO EEC OU DO EE7
Parametro..:  
 1.cP_PROC   -> CODIGO DO PROCESSO DE EXPORTACAO OU IMPORTACAO SELECIONADO PARA IMPRESSAO
                OBRIGATORIO
 2.cP_FASE   -> INDICA SE FASE DE PEDIDO (OC_PE) OU EMBARQUE (OC_EM). DEFAULT OC_PE
                OBRIGATORIO
 3.aP_ESTR   -> ESTRUTURA DO ARQUIVO A SER APRENSETADO NA MSSELECT PARA A SELECAO DOS
                REGISTROS. A COLUNA 1 SEMPRE SERA A DO GETMARK()
                DEFAULT = CAMPOS DO SX3 COM X3_BROWSE = 'S'
 4.cP_ALIAS  -> NOME DO ALIAS DO ARQUIVO DE TRABALHO. DEFAULT 'TMPA'
 5.aP_MSSEL  -> ARRAY CONTENDO AS COLUNAS A SEREM APRESENTADAS NO MSSELECT
 6.bP_GRAVA  -> CODE BLOCK CONTENDO A FUNCAO PARA GRAVACAO DO WORK
 7.bP_LOOP   -> CODE BLOCK CONTENDO FUNCAO PARA GRAVACAO DOS DADOS NA WORK ;
                (LOOP INCLUSAO)
 8.cP_INDEX  -> STRING CONTENDO A ESTRUTURA DO INDICE A SER USADO NA WORK.
                DEFAULT É O NUMERO DO PROCESSO OU EMBARQUE
 9.bP_HEADET -> CODE BLOCK CONTENDO A ROTINA PARA TELA DE PARAMETROS E GRAVACAO DO 
                HEADER E DETAIL
10.cP_CODDOC -> CODIGO DO DOCUMENTO NO EEA
Autor......: LUCIANO CAMPOS DE SANTANA
Data/Hora..: 20/01/2005 - 14:34
Observacao.: ASSUME QUE ESTA POSICIONADO NO EEC
Alteracao..:
                   1       2       3       4        5        6        7       8        9         10
*/
FUNCTION AVSELPROC(cP_PROC,cP_FASE,aP_ESTR,cP_ALIAS,aP_MSSEL,bP_GRAVA,bP_LOOP,cP_INDEX,bP_HEADET,cP_CODDOC)
LOCAL lRET,aORD,cSEQR,cKEX0,nA,nEX0RECNO,aEX0
PRIVATE cTMPA,aESTRUDEF,cFILEA,aCAMPOS,aHEADER,cEE7C,cMARCA,lINVERTE
*
aORD      := SAVEORD({"EX0","EE7","EEC"})
lRET      := .F.
cEE7C     := ""
cP_PROC   := IF(cP_PROC ==NIL,"",cP_PROC)
cP_FASE   := IF(cP_FASE ==NIL,"",cP_FASE)
aP_ESTR   := IF(aP_ESTR ==NIL,{},aP_ESTR)
cTMPA     := IF(cP_ALIAS==NIL,"TMPA",cP_ALIAS)
aP_MSSEL  := IF(aP_MSSEL==NIL,{},aP_MSSEL)
cP_INDEX  := IF(cP_INDEX==NIL,"",cP_INDEX)
cP_CODDOC := IF(cP_CODDOC==NIL,"",cP_CODDOC)
aCAMPOS   := {}
aHEADER   := {}
aESTRUDEF := {}
cMARCA   := GETMARK()
lINVERTE := .F.
BEGIN SEQUENCE
   // VALIDA PARAMETRO DE PROCESSO
   IF EMPTY(cP_PROC)
      MSGINFO(STR0061,STR0008) //"Erro. Não foi informado o Número do Processo !"###"Atenção"
      BREAK
   // VALIDA PARAMENTRO DA FASE
   ELSEIF EMPTY(cP_FASE)
          MSGINFO(STR0062,STR0008) //"Erro. Fase do processo não informada !"###"Atenção"
          BREAK
   ELSEIF cP_FASE <> OC_PE .AND. cP_FASE <> OC_EM
          MSGINFO(STR0063+; //"Erro. Esta função só pode ser usado para o Pedido ou "
                  STR0064,STR0008) //"Embarque de Exportação !"###"Atenção"
          BREAK
   // VALIDA O CODIGO DO DOCUMENTO
   ELSEIF EMPTY(cP_CODDOC)
          MSGINFO(STR0065,STR0008) //"Erro. Não foi informado o código do documento no EEA !"###"Atenção"
          BREAK
   ENDIF
   cEE7C := IF(cP_FASE=OC_PE,"EE7","EEC")
   // VALIDA PARAMETRO DA ESTRUTURA DO WORK
   IF LEN(aP_ESTR) = 0
      MSGINFO(STR0066,STR0008) //"Erro. Não foi informada a estrutura do arquivo de trabalho !"###"Atenção"
      BREAK
   ELSEIF ! AVFSPSTRU(aP_ESTR)
           MSGINFO(STR0067+; //"Erro. É obrigatório a existencia do campo "
                   IF(cEE7C="EE7","EE7_PEDIDO !","EEC_PREEMB !"),STR0008) //"Atenção"
           BREAK
   ELSEIF ! AVFSPMSEL(aP_MSSEL)
          MSGINFO(STR0068,STR0008) //"Erro. Não foi informada as colunas para apresentação dos dados !"###"Atenção"
          lRET := .F.
          BREAK
   ENDIF
   // CRIA O ARQUIVO DE TRABALHO DE ACORDO COM A ESTRUTURA INFORMADA
   
   cFILEA := E_CRIATRAB(,aESTRUDEF,cTMPA)
   INDREGUA(cTMPA,cFILEA+TEORDBAGEXT(),IF(cP_FASE=OC_PE,"EE7_PEDIDO","EEC_PREEMB"),"AllwayTrue()","AllwaysTrue()",STR0069) //"Processando Arquivo Temporario"
   IF ! EMPTY(cP_INDEX)
      cFILEB := E_CREATE(,.F.)
      INDREGUA(cTMPA,cFILEB+TEORDBAGEXT(),cP_INDEX,"AllwayTrue()","AllwaysTrue()",STR0069) //"Processando Arquivo Temporario"
      SET INDEX TO (cFILEA+TEORDBAGEXT()),(cFILEB+TEORDBAGEXT())
      (cTMPA)->(DBSETORDER(2))
   ENDIF
   // GRAVACAO DOS DADOS NA WORK
   IF bP_LOOP == NIL
      MSGINFO(STR0070,STR0008) //"Erro. Não foi informada a condição para gravação do arquivo de trabalho !"###"Atenção"
      BREAK
   ELSEIF bP_GRAVA == NIL
          MSGINFO(STR0071,STR0008) //"Erro. Não foi informada a rotina para gravação do arquivo de trabalho !"###"Atenção"
          BREAK
   ELSEIF bP_HEADET == NIL
          MSGINFO(STR0072,STR0008) //"Erro. Não foi informada a rotina para gravação dos arquivos de impressao !"###"Atenção"
          BREAK
   ENDIF
   // VERIFICA SE JA TEM IMPRESSO. CASO SIM TRAZ SOMENTE OS JA IMPRESSOS. SENAO TODOS
   EX0->(DBSETORDER(1))
   IF (EX0->(DBSEEK(XFILIAL("EX0")+AVKEY(cP_PROC,"EX0_PREEMB")+;
                    AVKEY(cP_CODDOC,"EX0_CODDOC")+AVKEY(cP_FASE,"EX0_FASE"))))
      *
      cSEQR := EX0->EX0_SEQREL
      cKEX0 := XFILIAL("EX0")+AVKEY(cP_CODDOC,"EX0_CODDOC")+cSEQR+AVKEY(cP_FASE,"EX0_FASE")
      EX0->(DBSETORDER(2))
      EX0->(DBSEEK(cKEX0,.T.))
      DO WHILE ! EX0->(EOF()) .AND.;
         EX0->(EX0_FILIAL+EX0_CODDOC+EX0_SEQREL+EX0_FASE) = cKEX0
         *
         (cEE7C)->(DBSETORDER(1))
         IF ((cEE7C)->(DBSEEK(XFILIAL(cEE7C)+EX0->EX0_PREEMB)))
            (cTMPA)->(DBAPPEND())
            EVAL(bP_GRAVA)
            (cTMPA)->WK_FLAG := cMARCA
         ENDIF
         EX0->(DBSKIP())
      ENDDO
   ELSE              
      EVAL(bP_LOOP)
      // TIRA DO WORK OS REGISTROS JA SELECIONADOS EM OUTRAS IMPRESSOES
      (cTMPA)->(DBGOTOP())
      DO WHILE ! (cTMPA)->(EOF())
         IF cP_FASE = OC_PE
            nA := (cTMPA)->(FIELDPOS("EE7_PEDIDO"))
         ELSE
            nA := (cTMPA)->(FIELDPOS("EEC_PREEMB"))
         ENDIF
         cKEX0 := (cTMPA)->(FIELDGET(nA))
         EX0->(DBSETORDER(1))
         IF (EX0->(DBSEEK(XFILIAL("EX0")+AVKEY(cKEX0,"EX0_PREEMB")+;
                          AVKEY(cP_CODDOC,"EX0_CODDOC")+AVKEY(cP_FASE,"EX0_FASE"))))
            *
            (cTMPA)->(DBDELETE())
         ENDIF
         (cTMPA)->(DBSKIP())
      ENDDO
   ENDIF
   (cTMPA)->(DBGOTOP())
   IF ! AVFSPTELAG(aP_MSSEL,bP_GRAVA)
      lRET := .F.
      BREAK
   ENDIF
   // EXECUTA A GRAVACAO DO HEADER/DETAIL
   IF ! EVAL(bP_HEADET)
      BREAK
   ENDIF
   // GRAVA OS REGISTROS MARCADOS NO EX0
   IF Empty(cSEQREL)
      cSEQREL := GETSXENUM("SY0","Y0_SEQREL")
      CONFIRMSX8()
   Endif
   (cTMPA)->(DBGOTOP())
   DO WHILE ! (cTMPA)->(EOF())
      IF ! EMPTY((cTMPA)->WK_FLAG)
         IF cP_FASE = OC_PE
            nA := (cTMPA)->(FIELDPOS("EE7_PEDIDO"))
         ELSE
            nA := (cTMPA)->(FIELDPOS("EEC_PREEMB"))
         ENDIF
         // CASO O PROCESSO JA FOI IMPRESSO EM OUTRA SEQUENCIA, LIMPA A SEQUENCIA
         // DOS DEMAIS
         cKEX0 := (cTMPA)->(FIELDGET(nA))
         EX0->(DBSETORDER(1))
         IF (EX0->(DBSEEK(XFILIAL("EX0")+AVKEY(cKEX0,"EX0_PREEMB")+;
                          AVKEY(cP_CODDOC,"EX0_CODDOC")+AVKEY(cP_FASE,"EX0_FASE"))))
            *
            nEX0RECNO := EX0->(RECNO())
            cSEQR     := EX0->EX0_SEQREL
            aEX0      := {}
            EX0->(DBSETORDER(2))
            EX0->(DBSEEK(XFILIAL("EX0")+AVKEY(cP_CODDOC,"EX0_CODDOC")+cSEQR,.T.))
            DO WHILE ! EX0->(EOF()) .AND.;
               EX0->(EX0_FILIAL+EX0_CODDOC+EX0_SEQREL) = (XFILIAL("EX0")+AVKEY(cP_CODDOC,"EX0_CODDOC")+cSEQR)
               *
               IF EX0->(RECNO()) <> nEX0RECNO
                  AADD(aEX0,EX0->(RECNO()))
               ENDIF
               EX0->(DBSKIP())
            ENDDO
            FOR nA := 1 TO LEN(aEX0)
                EX0->(DBGOTO(aEX0[nA]))
                EX0->(RECLOCK("EX0",.F.))
                EX0->(DBDELETE())
                EX0->(MSUNLOCK())
            NEXT
            EX0->(DBGOTO(nEX0RECNO))
         ELSE
            EX0->(RECLOCK("EX0",.T.))
            EX0->EX0_FILIAL := XFILIAL("EX0")
            EX0->EX0_PREEMB := cKEX0
            EX0->EX0_CODDOC := cP_CODDOC
            EX0->EX0_FASE   := cP_FASE
         ENDIF
         // GRAVA A SEQUENCIA DE IMPRESSAO ATUAL
         EX0->(RECLOCK("EX0",.F.))
         EX0->EX0_SEQREL := cSEQREL
      ENDIF
      (cTMPA)->(DBSKIP())
   ENDDO
   lRET := .T.
END SEQUENCE
IF SELECT(cTMPA) # 0
   (cTMPA)->(E_ERASEARQ(cFILEA))
ENDIF
RESTORD(aORD)
RETURN(lRET)
*--------------------------------------------------------------------
// ESTA FUNCAO TEM A FINALIDADE DE TRAZER DO SX3 OS CAMPOS COM X3_BROW = "S"
STATIC FUNCTION AVFSPSTRU(aP_ESTR)
LOCAL aRET,nA,lRET
*
lRET := .F.
aRET := {{"WK_FLAG","C",02,0}}  // FIXO SEMPRE NA PRIMEIRA COLUNA
// MONTA DE ACORDO COM A ESTRUTURA DO CLIENTE
FOR nA := 1 TO LEN(aP_ESTR)
    AADD(aRET,{aP_ESTR[nA,1],aP_ESTR[nA,2],aP_ESTR[nA,3],aP_ESTR[nA,4]})
NEXT
// VERIFICA SE OS CAMPOS OBRIGATORIOS DA WORK EXISTEM
FOR nA := 1 TO LEN(aRET)
    AADD(aESTRUDEF,{aRET[nA,1],aRET[nA,2],aRET[nA,3],aRET[nA,4]})
    IF cEE7C = "EE7" .AND. aRET[nA,1] = "EE7_PEDIDO"
       lRET := .T.
    ELSEIF cEE7C = "EEC" .AND. aRET[nA,1] = "EEC_PREEMB"
           lRET := .T.
    ENDIF
NEXT
RETURN(lRET)
*--------------------------------------------------------------------
STATIC FUNCTION AVFSPMSEL(cP_MSSEL)
LOCAL lRET
*
lRET := .T.
IF cP_MSSEL = NIL .OR. LEN(cP_MSSEL) = 0
   lRET := .F.
ENDIF
RETURN(lRET)
*--------------------------------------------------------------------
STATIC FUNCTION AVFSPTELAG(aP_MSSEL,bP_GRAVA)
LOCAL bOK,bCANCEL,aBUTTONS,nBTOP,oDLG,aCOLMS,lRET,nA,aPOS,aMSELECT
*
lRET     := .F.
nBTOP    := 0
bOK      := {|| nBTOP := 1,oDLG:END()}
bOK      := {|| nBTOP := 1,IF(AVFSPVAL("bOKMSE"),oDLG:END(),nBTOP := 0)}
aBUTTONS := {{"LBTIK",{|| AVFSPMARCA()},STR0073},; //"Marca/Desmarca Todos"
             {"EDIT" ,{|| E02INCPROC(bP_GRAVA)},STR0003}} //"Incluir"
bCANCEL  := {|| nBTOP := 0,oDLG:END()}
aCOLMS   := {{"WK_FLAG" ,," "}}
FOR nA := 1 TO LEN(aP_MSSEL)
    AADD(aCOLMS,aP_MSSEL[nA])
NEXT
DBSELECTAREA(cTMPA)
DEFINE MSDIALOG oDLG TITLE STR0074+IF(cEE7C="EE7",STR0075,STR0076) FROM 0,0 TO 290,455 OF oMainWnd PIXEL  //"Seleção de "###"Pedidos"###"Embarque"
   aPOS     := POSDLG(oDLG)
   oMSELECT := MSSELECT():NEW(cTMPA,"WK_FLAG",,aCOLMS,@lINVERTE,@cMARCA,aPOS)
   oMSELECT:BAVAL := {|| AVFSPBAVAL()}
   oMSELECT:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT //By JPM - 14/06/05
ACTIVATE MSDIALOG oDLG ON INIT ENCHOICEBAR(oDLG,bOK,bCANCEL,,aBUTTONS) CENTERED
IF nBTOP = 1
   lRET := .T.
ENDIF
RETURN(lRET)
*--------------------------------------------------------------------
STATIC FUNCTION AVFSPBAVAL()
IF ! EMPTY((cTMPA)->WK_FLAG)
   (cTMPA)->WK_FLAG := ""
ELSE
   (cTMPA)->WK_FLAG := cMARCA
ENDIF
RETURN(NIL)
*--------------------------------------------------------------------
STATIC FUNCTION AVFSPVAL(cP_ACAO,cP_CPA)
LOCAL lRET,nA
*
lRET    := .T.
cP_ACAO := IF(cP_ACAO==NIL,"",cP_ACAO)
IF cP_ACAO == "bOKMSE"
   lRET := .F.
   nA   := (cTMPA)->(RECNO())
   (cTMPA)->(DBGOTOP())
   DO WHILE ! (cTMPA)->(EOF())
      IF ! EMPTY((cTMPA)->WK_FLAG)
         lRET := .T.
         EXIT
      ENDIF
      (cTMPA)->(DBSKIP())
   ENDDO
   IF ! lRET
      MSGINFO(STR0077+IF(cEE7C="EE7",STR0078,STR0079),STR0008) //"Selecione pelo menos um "###"pedido !"###"embarque !"###"Atenção"
   ENDIF
   (cTMPA)->(DBGOTO(nA))
ELSEIF cP_ACAO == "EE7"
       EE7->(DBSETORDER(1))
       IF ! (EE7->(DBSEEK(XFILIAL("EE7")+cP_CPA)))
          MSGINFO(STR0080,STR0008) //"Processo não cadastrado !"###"Atenção"
          lRET := .F.
       ELSE
          nA := {(cTMPA)->(INDEXORD()),(cTMPA)->(RECNO())}
          (cTMPA)->(DBSETORDER(1))
          IF ((cTMPA)->(DBSEEK(cP_CPA)))
             MSGINFO(STR0081,STR0008) //"Processo já informado na tela de seleção !"###"Atenção"
             lRET := .F.
          ENDIF
          (cTMPA)->(DBSETORDER(nA[1]))
          (cTMPA)->(DBGOTO(nA[2]))
       ENDIF
ELSEIF cP_ACAO == "EEC"
       EEC->(DBSETORDER(1))
       IF ! (EEC->(DBSEEK(XFILIAL("EEC")+cP_CPA)))
          MSGINFO(STR0082,STR0008) //"Embarque não cadastrado !"###"Atenção"
          lRET := .F.
       ELSE
          nA := {(cTMPA)->(INDEXORD()),(cTMPA)->(RECNO())}
          (cTMPA)->(DBSETORDER(1))
          IF ((cTMPA)->(DBSEEK(cP_CPA)))
             MSGINFO(STR0083,STR0008) //"Embarque já informado na tela de seleção !"###"Atenção"
             lRET := .F.
          ENDIF
          (cTMPA)->(DBSETORDER(nA[1]))
          (cTMPA)->(DBGOTO(nA[2]))
       ENDIF
ENDIF
RETURN(lRET)
*--------------------------------------------------------------------
STATIC FUNCTION AVFSPMARCA()
LOCAL nRECTMPA,cFLAG
*
nRECTMPA := (cTMPA)->(RECNO())
cFLAG    := (cTMPA)->WK_FLAG
(cTMPA)->(DBGOTOP())
DO WHILE ! (cTMPA)->(EOF())
   (cTMPA)->WK_FLAG := IF(EMPTY(cFLAG),cMARCA,"")
   (cTMPA)->(DBSKIP())
ENDDO
(cTMPA)->(DBGOTO(nRECTMPA))
RETURN(NIL)
*--------------------------------------------------------------------
STATIC FUNCTION E02INCPROC(bP_GRAVA)
LOCAL lRET,bOK,bCANCEL,aBUTTONS,nBTOP,oDLG,cPROC,lEE7,cSAY,cPIC,XX
*
XX       := ""
lRET     := .F.
lEE7     := IF(cEE7C="EE7",.T.,.F.)
bOK      := {|| nBTOP := 1,IF(AVFSPVAL(cEE7C,cPROC),oDLG:END(),nBTOP := 0)}
bCANCEL  := {|| nBTOP := 0,oDLG:END()}
aBUTTONS := {}
nBTOP    := 0
cPROC    := IF(lEE7,SPACE(LEN(EE7->EE7_PEDIDO)),SPACE(LEN(EEC->EEC_PREEMB)))
cSAY     := AVSX3(IF(lEE7,"EE7_PEDIDO","EEC_PREEMB"),AV_TITULO)
cPIC     := AVSX3(IF(lEE7,"EE7_PEDIDO","EEC_PREEMB"),AV_PICTURE)
DEFINE MSDIALOG oDLG TITLE STR0084 FROM 0,0 TO 070,240 OF oMainWnd PIXEL //"Inclusão"
   @ 16,010 SAY cSAY PIXEL OF oDLG
   @ 16,045 MSGET cPROC PICTURE "@!" VALID (AVFSPVAL(cEE7C,cPROC)) F3(cEE7C) SIZE 60,08 ;
            PIXEL OF oDLG
   *
   @ 100,010 MSGET XX
ACTIVATE MSDIALOG oDLG ON INIT ENCHOICEBAR(oDLG,bOK,bCANCEL,,aBUTTONS) CENTERED
IF nBTOP = 1
   (cTMPA)->(DBAPPEND())
   EVAL(bP_GRAVA)
   (cTMPA)->WK_FLAG := cMARCA
ENDIF
RETURN(lRET)

/*
Funcao      : DataExtenso(dDt,cIdioma).
Parametros  : dDt - Data que o sw.
              cIdioma - Idioma base para montagem da data por extenso. (Default - Inglês).
              lUpper  - .t. = A função irá 
Retorno     : aRet - Por dimensão: [1] - Mês por extenso. (no idioma).
                                   [2] - dia e complemento (th,sd,rd, etc - no caso de idioma em inglês).
                                   [3] - Ano.
Objetivos   : Retornar data por extenso.
Autor       : Jeferson Barros Jr.
Data/Hora   : 23/05/2005 - 13:16.
Revisao     :
Obs.        :
*/
*--------------------------------------*
Function DataExtenso(dDt,cIdioma,lUpper)
*--------------------------------------*
Local aRet:={"","",""}
Local aMesesEsp := {"Enero"  , "Febrero"  , "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"}
Local aMesesPor := {"Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro"  , "Outubro", "Novembro" , "Dezembro" }
Local cAux

Default cIdioma := INGLES
Default lUpper  := .f.

Begin Sequence

   If Empty(dDt)
      Break
   EndIf

   cIdioma := AllTrim(Upper(cIdioma))

   Do Case
      Case cIdioma == INGLES
           nDay := Day(dDt)
           If nDay >= 4 .And. nDay <= 20
              cAux := "th"
           Else
              cAux := If(Right(Str(nDay),1)=="1","st",;                                       
                      If(Right(Str(nDay),1)=="2","nd",;
                      If(Right(Str(nDay),1)=="3","rd",;
                      "th")))
           EndIf

           aRet := {AllTrim(Capital(cMonth(dDt)))  ,;
                    AllTrim(Str(Day(dDt),2,0))+cAux,;
                    Str(Year(dDt),4,0)}

           aRet[1] := If(lUpper,Upper(aRet[1]),aRet[1])
      
      Case cIdioma == PORTUGUES
           aRet := {aMesesPor[Month(dDt)],;
                    AllTrim(Str(Day(dDt),2,0)),;
                    Str(Year(dDt),4,0)}

           aRet[1] := If(lUpper,Upper(aRet[1]),aRet[1])

      Case cIdioma == ESPANHOL

           aRet := {aMesesEsp[Month(dDt)],;
                    AllTrim(Str(Day(dDt),2,0)),;
                    Str(Year(dDt),4,0)}

           aRet[1] := If(lUpper,Upper(aRet[1]),aRet[1])
   EndCase

End Sequence

Return aRet

/*
Funcao     : AvSelectDoc()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Gerar markBrow para marcação dos Relatório/Documentos que serão exportados
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 16/06/05 - 11:40
Revisao    : 
Obs.       : Função passada para o EECCAD02, por estouro de defines
*/

*--------------------*
Function AvSelectDoc()
*--------------------*
Return Av2SelectDoc()

/*
Funcao     : AvDocImport()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Importar dados de documentos do EEA
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 17/06/05 - 14:00
Revisao    : 
Obs.       : Função passada para o EECCAD02, por estouro de defines
*/
*--------------------*
Function AvDocImport()
*--------------------*
Return Av2DocImport()

/*
Funcao     : EECCalcTaxa()
Parametros : 1 - cMoeda1 - Moeda Atual
             2 - cMoeda2 - Moeda para a qual o valor será convertido
             3 - nValor  - Valor a ser convertido (opcional)
             4 - nCasas  - Casas Decimais em que será arredondado o valor convertido (opcional)
             5 - dData   - data da cotação desejada
Retorno    : Se for informado nValor, o retorno será o valor já convertido e arredondado em nCasas Casas Decimais (se for informado tb)
             Senão, o retorno será o Valor da Taxa (taxa pela qual o valor deve ser multiplicado para ser convertido)
Objetivos  : Calcular taxa para conversão de uma moeda (cMoeda1) para outra (cMoeda2)
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 07/07/05 - 10:24
*/

*-------------------------------------------------------*
Function EECCalcTaxa(cMoeda1,cMoeda2,nValor,nCasas,dData)
*-------------------------------------------------------*
Local nRet

Default dData := dDataBase

Begin Sequence   

   If cMoeda1 <> cMoeda2
      nRet := If(cMoeda1 <> "R$ ", BuscaTaxa(cMoeda1,dData),1);
              /;
              If(cMoeda2 <> "R$ ", BuscaTaxa(cMoeda2,dData),1)
   Else
      nRet := 1
   EndIf
   
   If ValType(nValor) = "N" // se for informado o valor, a função retorna o valor já convertido, senão retorna só a taxa
      nRet := nValor * nRet
      If ValType(nCasas) = "N"
         nRet := Round(nRet,nCasas)
      EndIf
   EndIf
   
End Sequence

Return nRet

/*
Funcao     : CoMsg()
Parametros : cP_MODO
Retorno    : .T./.F.
Objetivos  : Verifica se o CO está correto
Autor      : Fabio Justo Hildebrand
Data/Hora  : 15/08/05 - 11:00
Revisao    : 
Obs.       :
*/

*--------------------------*
Function CoMsg(cP_MODO)
*--------------------------*

LOCAL lRET := .T.,aORD := SAVEORD({"SYA","EEE","EE9"}), cMsg := "", lCodNor := .F.,;
      cINSTNEG := SPACE(AVSX3("EEE_DCRED",AV_TAMANHO))

cP_MODO := IF(cP_MODO=NIL,"",cP_MODO)
cINSTNEG := Posicione("EEE",1,XFILIAL("EEE")+EEC->EEC_INSCOD,"EEE_DCRED")
IF Empty(EEC->EEC_INSCOD)
   cMsg+=STR0131+ENTER //"Instrumento de Negociação Não Informado !" 
   lRET := .F.
ElseIf Empty(cINSTNEG)
   cMsg+=STR0122+ENTER //"Descrição resumida do instrumento de negociação não preenchida"
   lRET := .F.
Endif 

SYA->(DBSETORDER(1))
SYA->(DBSEEK(XFILIAL("SYA")+EEC->EEC_PAISDT))
IF cP_MODO = "MER" .AND. SYA->YA_MERCOSU # "1"
   cMsg+=STR0132+ENTER //"Pais nao pertence ao MERCOSUL !" 
   lRET := .F.
Endif
IF cP_MODO = "ALA" .AND. SYA->YA_ALADI # "1"
   cMsg+=STR0133+ENTER //"Pais Destino nao pertence ao acordo ALADI !"
   lRET := .F.
ENDIF
If !Empty(cP_MODO) //FJH 02/09/05 Não verificar se existem normas para certificado comum.
   EE9->(DBSETORDER(3))
   EE9->(DBSEEK(XFILIAL("EE9")+EEC->EEC_PREEMB))
   While EE9->(!EOF()) .And. EE9->(EE9_FILIAL+EE9_PREEMB) == (XFILIAL("EE9")+EEC->EEC_PREEMB)
      IF (cP_MODO = "ALA".or.cP_MODO = "ACE".or.cP_MODO = "BOL".or.cP_MODO = "CHI") .AND. Empty(EE9->EE9_NALSH) 
         cMsg+=STR0123+ AllTrim(EE9->EE9_COD_I) +STR0124+ENTER // "aladi do item " #### " não preenchido"
         lRET := .F.
      ENDIF
      IF !Empty(EE9->EE9_CODNOR)
         lCodNor:=.T.
      Endif
      EE9->(dbSkip())
   End
   IF !lCodNor
      cMsg+=STR0125+ENTER //"Código da norma não preenchido nos itens"
      lRet:=.F.
   Endif
Endif
IF cP_MODO == "BOL" .AND. SYA->YA_SISEXP <> "0973" //Não é a Bolivia
   IF Empty(SYA->YA_SISEXP)
      cMsg+=STR0129+ENTER // "Cód. Siscomex do país de destino não preenchido" 
   Elseif SYA->YA_SISEXP <> "0973"
      cMsg+=STR0127+ENTER // "País de destino não é a Bolivia" 
   Endif
   lRET := .F.
ENDIF
IF cP_MODO == "CHI" .AND. SYA->YA_SISEXP <> "1589" //Não é o Chile
   IF Empty(SYA->YA_SISEXP)
      cMsg+=STR0129+ENTER // "Cód. Siscomex do país de destino não preenchido" 
   Elseif SYA->YA_SISEXP <> "1589"
      cMsg+=STR0128+ENTER // "País de destino não é o Chile" 
   Endif
   lRET := .F.
ENDIF
IF cP_MODO = "ACE" .AND. (SYA->YA_SISEXP <> "1694" .and. SYA->YA_SISEXP <> "2399" ;
                          .and. SYA->YA_SISEXP <> "8508") //Não é a Colombia, Equador ou Venezuela
   IF Empty(SYA->YA_SISEXP)
      cMsg+=STR0129+ENTER //"Cód Siscomex do país de destino não preenchido" 
   Else 
      cMsg+=STR0130+ENTER // "Pais de destino não pertence ao acordo ACE59" 
   Endif
   lRET := .F.
ENDIF

//WFS 21/10
//ACE-53
If cP_MODO == "MEX" .And. SYA->YA_SISEXP <> "4936"  //México
   If Empty(SYA->YA_SISEXP)
      cMsg += STR0129 + ENTER //"Cód Siscomex do país de destino não preenchido" 
   Else 
      cMsg += STR0142 + ENTER // "O país de destino não é o México"
   EndIf
   lRet:= .F.
EndIf

//FRS 29/01/10
//ACE-58
If cP_MODO == "PER" .And. SYA->YA_SISEXP <> "5894"  //Peru
   If Empty(SYA->YA_SISEXP)
      cMsg += STR0129 + ENTER //"Cód Siscomex do país de destino não preenchido" 
   Else 
      cMsg += STR0143 + ENTER // "O país de destino não é o Peru"
   EndIf
   lRet:= .F.
EndIf             

//FRS 29/01/10
//ACE-62
If cP_MODO == "CUB" .And. SYA->YA_SISEXP <> "1996"  //Cuba
   If Empty(SYA->YA_SISEXP)
      cMsg += STR0129 + ENTER //"Cód Siscomex do país de destino não preenchido" 
   Else 
      cMsg += STR0144 + ENTER // "O país de destino não é Cuba"
   EndIf
   lRet:= .F.
EndIf             

// se lRet for .F. mostra msg de erro cMsg: 
IF !lRet
   EECView(cMsg,STR0134) // "Certificado de Origem" FJH 15/08/05  
Endif

RESTORD(aORD)
Return lRet

/*
Funcao     : EECCancelPed()
Parametros : cFilUso    - Filial 
             cPedido    - Codigo do Pedido(EE7_PEDIDO)
             lExibeMsg  - Se exibe mensagens ou não.
             lCanCancel - Se pode cancelar automatico na rotina de Off-Shore.
Retorno    : .T./.F. - Se cancelou ou não
Objetivos  : Cancelar o Pedido de Embarque
Autor      : Eduardo Romanini
Data/Hora  : 19/09/05 - 15:00
Revisao    : 
Obs.       :
*/

Function EECCancelPed(cFilUso,cPedido,lExibeMsg,lCanCancel,cPedFat)

Local lRet := .F., cFil
Local lIntermed := .F.
Local aOrd := SAVEORD({"EE7","EE8","EEQ","EE9","EEC","SM0"})
Local cFase := OC_PE

Private cFilBr := "", cFilEx := ""
Private lPagtoAnte := EasyGParam("MV_AVG0039",,.f.)          
Private lIntEmb := EECFlags("INTEMB") .Or. (EEC->(FieldPos("EEC_PEDFAT")) > 0 .And. !Empty(EEC->EEC_PEDFAT))

Default lExibeMsg := .T.
Default cFilUso   := xFilial("EE7")
Default cPedido   := ""
Default lCanCancel:= .F. 
Default cPedFat   := ""

Begin Sequence
        
   If Empty(cPedido)
      Break
   EndIf

   cPedido := AvKey(cPedido, "EE7_PEDIDO")
   
   /////////////////////////////////////////////////////////////////////////////////////////////////
   //Se a nova rotina de integração entre SigaEEC e SigaFAT estiver habilitada e o Pedido de Venda//
   //estiver relacionado ao Embarque, a função não será executada.                                //
   /////////////////////////////////////////////////////////////////////////////////////////////////
   If lIntEmb
      If !Empty(cPedFat)
         cFase := FatFasePV(cPedFat)

         If cFase == OC_EM
            lRet := .T.
            Break
         EndIf
      EndIf
   EndIf
   
   //Validação do Pedido

   EE7->(DbSetOrder(1))
   IF EE7->(DbSeek(cFilUso+cPedido))
        
      //Verifica se o Pedido já foi cancelado
      If EE7->EE7_STATUS == ST_PC
         If lExibeMsg
            MsgInfo(STR0135+Transf(DtoC(EE7->EE7_FIM_PE),"@d") ,STR0008) //"Processo já Cancelado em "###"Atenção"
         EndIf
         Break
      EndIF  
      
      //Carrega as Variaveis cFilBr e cFilEx      
      Ap100InitFil()
      
      If cFilUso $ (cFilBr + "/" + cFilEx)
              
         // Validações obrigatórias para habilitação da rotina de off-shore. 
         // Obs: A função IsFilial() valida as filiais informadas nos parâmetros MV_AVG0023 e MV_AVG0024 
         // contra as filiais válidas no sigamat.emp
         
         If !Empty(cFilBr) .And. !Empty(cFilEx) .And. IsFilial()
            If (EE7->(FieldPos("EE7_INTERM")) <> 0) .And. (EE7->(FieldPos("EE7_COND2"))  <> 0) .And.;
               (EE7->(FieldPos("EE7_DIAS2"))  <> 0) .And. (EE7->(FieldPos("EE7_INCO2"))  <> 0) .And.;
               (EE7->(FieldPos("EE7_PERC"))   <> 0) .And. (EE8->(FieldPos("EE8_PRENEG")) <> 0)
               
               lIntermed := .T.
            
            EndIf 
         EndIf      
      EndIf      
      
      If lIntermed .and. cFilUso $ (cFilBr + "/" + cFilEx)
         
         // Coloca a filial do Pedido a ser cancelada(cFilUso) como a Filial logada
         // para que a rotina de Off-Shore possa validar corretamente o Pedido da filial Brasil
         // ou do Exterior. Esse tratamento está sendo usado, porque pode-se tentar cancelar
         // um Pedido que faz parte da Off-Shore, de uma filial que não faz parte do Off-Shore.
                 
         SM0->(DbSetOrder(1))      
         If !SM0->(DbSeek(SM0->M0_CODIGO+cFilUso))
            lRet:=.f.
            Break
         EndIf
         
         // Para processos com tratamento de intermediação, o sistema valida se o cancelamento
         // poderá ser realizada, visto que para a rotina de off-shore, os
         // pedidos cancelados em uma filial são automaticamente cancelados 
         // na outra filial que faz parte da intermediação.    
         
         If !Ap104CanCancel(OC_PE,lExibeMsg,lCanCancel)
            Break
         EndIf       
      EndIf
      
      
      //Validação para Pedido já Embarcado.       
      
      EE9->(DbSetOrder(1))
      If EE9->(DbSeek(cFilUso+EE7->EE7_PEDIDO))
         While EE9->(!EOF()) .and. EE9->EE9_FILIAL == cFilUso .and. EE9->EE9_PEDIDO == EE7->EE7_PEDIDO
            EEC->(DbSetOrder(1))
            EEC->(DbSeek(cFilUso+EE9->EE9_PREEMB))
           
            If EEC->EEC_STATUS # ST_PC 
               Help(" ",1,"AVG0000647") //MSGINFO("Processo possui Embarque, Não pode ser Estornado","Atenção")
               Break
            EndIf
            EE9->(DbSkip())
         EndDo
      EndIf
                  
      //Verifica se existe Pagamento Antecipado.
      
      If lPagtoAnte
         EEQ->(DbSetOrder(6))
         If EEQ->(DbSeek(cFilUso+"P"+EE7->EE7_PEDIDO)) 
            
            If lExibeMsg
               MsgStop(STR0136+Replic(ENTER,2)+; //"Este processo não pode ser cancelado ou excluído."
                       STR0137+ENTER+;           //"Detalhes:"
                       STR0138+ENTER+;           //"O processo selecionado possui adiantamento(s) lançado(s)."
                       STR0139,STR0008)          //"Para cancelar ou excluir, primeiro estorne o(s) adiantameto(s)."###"Atenção"               
            EndIf       
            Break
         EndIf
      EndIf
           
      //Cancelamento do Pedido
      
      If EE7->(RecLock("EE7",.f.))

         EE8->(DbSetOrder(1))         
         EE8->(DbSeek(cFilUso+EE7->EE7_PEDIDO))

         While !EE8->(EOF()) .AND. ; 
               cFilUso+EE7->EE7_PEDIDO==EE8->EE8_FILIAL+EE8->EE8_PEDIDO
            
            If RecLock("EE8",.F.)
               EE8->EE8_STATUS := ST_PC
               
               // Na opção de cancelamento de pedidos o saldo a embarcar
               // dos itens, deverá ser zerado visto que como o pedido não 
               // poderá ser utilizado, o saldo deve ser nulo. 
            
               EE8->EE8_SLDATU := 0                      
               EE8->(MsUnlock())
            EndIf
            
            EE8->(DbSkip(1))
         EndDo
         
         EE7->EE7_FIM_PE := dDataBase
         EE7->EE7_STATUS := ST_PC

         //Atualizar descricao de status
         DSCSITEE7(.T.)
         EE7->(MsUnlock())

         If lIntermed .and. cFilUso $ (cFilBr + "/" + cFilEx)
                                             
            // Para os processos com tratamento de off-shore, o cancelamento é realizado automaticamente
            // na filial de intermediação, e vice-versa. 
            
            cFil := If(cFilUso==cFilBr,cFilEx,cFilBr)
            
            AP100CanPed(cFil)          
         EndIf        
         
         lRet := .T.
      EndIf
   
   Else
      
      If lExibeMsg
         MsgInfo(STR0140,STR0008) //"O pedido não foi encontrado. "###"Atenção"
      EndIf
   
   EndIF
  
End Sequence

RestOrd(aOrd,.t.)
Return lRet
/*
Funcao     : EECZeraSaldo()
Parametros : cFilUso    - Filial 
             cPedido    - Codigo do Pedido(EE7_PEDIDO)
             lExibeMsg  - Se exibe mensagens ou não.
             lZeraOffShore - Zerar os saldos da Off-shore
Retorno    : .T./.F.    - Zerou os Saldos/Não zerou os saldos
Objetivos  : Zerar os Saldos dos pedidos
Autor      : Julio de Paula Paz
Data/Hora  : 20/04/2006 - 15:00
Revisao    : 
Obs.       :
*/

Function EECZeraSaldo(cFilUso,cPedido,lExibeMsg,lZeraOffShore,cPedFat)

Local lRet := .F.
Local aOrd := SaveOrd({"EE7","EE8"}), lIntermed := .F., cFil, lFilEx := .F.
Local cOffShore
Local cFase := OC_PE

Private cFilBr := "", cFilEx := ""
Private lIntEmb := EECFlags("INTEMB") .Or. (EEC->(FieldPos("EEC_PEDFAT")) > 0 .And. !Empty(EEC->EEC_PEDFAT))

Default lExibeMsg := .T.
Default cFilUso   := xFilial("EE7")
Default cPedido   := ""
Default lZeraOffShore := .F.
Begin Sequence
        
   If Empty(cPedido)
      Break
   EndIf

   cPedido := AvKey(cPedido, "EE7_PEDIDO")

   /////////////////////////////////////////////////////////////////////////////////////////////////
   //Se a nova rotina de integração entre SigaEEC e SigaFAT estiver habilitada e o Pedido de Venda//
   //estiver relacionado ao Embarque, a função não será executada.                                //
   /////////////////////////////////////////////////////////////////////////////////////////////////
   If lIntEmb
      If !Empty(cPedFat)
         cFase := FatFasePV(cPedFat)

         If cFase == OC_EM
            lRet := .T.
            Break
         EndIf
      EndIf
   EndIf
   
   //Carrega as Variaveis cFilBr e cFilEx      
   Ap100InitFil()
      
   If cFilUso $ (cFilBr + "/" + cFilEx)
                 
      If !Empty(cFilBr) .And. !Empty(cFilEx) .And. IsFilial()
         If (EE7->(FieldPos("EE7_INTERM")) <> 0) .And. (EE7->(FieldPos("EE7_COND2"))  <> 0) .And.;
            (EE7->(FieldPos("EE7_DIAS2"))  <> 0) .And. (EE7->(FieldPos("EE7_INCO2"))  <> 0) .And.;
            (EE7->(FieldPos("EE7_PERC"))   <> 0) .And. (EE8->(FieldPos("EE8_PRENEG")) <> 0)
               
            lIntermed := .T.
            
         EndIf 
      EndIf      
   EndIf      

   EE7->(DbSetOrder(1))
   IF EE7->(DbSeek(cFilUso+cPedido))     
      //Verifica se o Pedido já foi cancelado
      If EE7->EE7_STATUS == ST_PC
         If lExibeMsg
            MsgInfo(STR0141+Transf(DtoC(EE7->EE7_FIM_PE),"@d") ,STR0008) //"Processo já Cancelado em "###"Atenção"
         EndIf
         Break
      EndIF  
      
      // Zera os Saldos do pedido
      If EE7->(RecLock("EE7",.f.))
         EE8->(DbSetOrder(1))         
         EE8->(DbSeek(cFilUso+EE7->EE7_PEDIDO))

         While !EE8->(EOF()) .AND. ; 
               cFilUso+EE7->EE7_PEDIDO==EE8->EE8_FILIAL+EE8->EE8_PEDIDO
            
            If EE8->EE8_FATIT == SC6->C6_ITEM
               RecLock("EE8",.F.)
               EE8->EE8_SLDATU := SC6->C6_QTDENT - (EE8->EE8_SLDINI - EE8_SLDATU)   //DFS - 12/09/11 - Tratamento para calcular corretamente o resíduo a ser eliminado. 
               EE8->(MsUnlock())
            EndIf
            
            EE8->(DbSkip(1))
         EndDo     
         EE7->(MsUnlock())
         lRet := .T.
      EndIf
      cFil := If(cFilUso==cFilBr,cFilEx,cFilBr)         
      If lIntermed .And. lZeraOffShore  // Se houver OffShore zera saldo do pedido oposto ao da filial corrente.
         lFilEx :=(cFilUso==cFilEx)
         If !lFilEx
            cOffShore := EE7->EE7_INTERM // Verifica se é pedido de offshore.
         EndIF
         EE7->(DbSetOrder(1))
         IF EE7->(DbSeek(cFil+cPedido))  // Zera os saldos do pedido OffShore.
            If lFilEx
               cOffShore := EE7->EE7_INTERM
            EndIF
            If cOffshore $ cSim
               lRet := .F.
               If EE7->(RecLock("EE7",.f.))
                  EE8->(DbSetOrder(1))         
                  EE8->(DbSeek(cFil+EE7->EE7_PEDIDO))

                  While !EE8->(EOF()) .AND. ; 
                        cFil+EE7->EE7_PEDIDO==EE8->EE8_FILIAL+EE8->EE8_PEDIDO
                     
                     If EE8->EE8_FATIT == SC6->C6_ITEM
                        RecLock("EE8",.F.)
                        EE8->EE8_SLDATU := SC6->C6_QTDENT - (EE8->EE8_SLDINI - EE8_SLDATU)   //DFS - 12/09/11 - Tratamento para calcular corretamente o resíduo a ser eliminado. 
                        EE8->(MsUnlock())
                     EndIf
                     EE8->(DbSkip(1))
                  EndDo     
                  EE7->(MsUnlock())
                  lRet := .T.
               EndIf   
            EndIF
         EndIf
      EndIf
   Else      
      If lExibeMsg
         MsgInfo(STR0140,STR0008) //"O pedido não foi encontrado. "###"Atenção"
      EndIf   
   EndIF
  
End Sequence

RestOrd(aOrd,.t.)
Return lRet



*------------------------------------------------------------------------------------------------------------------*
*                                               FIM DO PROGRAMA EECCAD01                                           *
*------------------------------------------------------------------------------------------------------------------*
