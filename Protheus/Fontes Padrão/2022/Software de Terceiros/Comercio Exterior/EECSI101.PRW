#INCLUDE "EECSI101.ch"
/*
Programa        : EECSI101.PRW
Objetivo        : Usuarios - Siscomex
Autor           : Cristiano A. Ferreira
Data/Hora       : 17/12/1999 15:19
Obs.            :
*/

#include "EEC.cH"
#Define INCLUIR_RE 2
#Define ALTERAR_RE 4
#Define TAMMEMO (AvSx3("YP_TEXTO",AV_TAMANHO)-6)

#Define IWW    1
#Define Packet 2

/*
Funcao      : EECSI101()
Parametros  : Nenhum
Retorno     : NIL
Objetivos   : Usuarios - Siscomex
Autor       : Cristiano A. Ferreira
Data/Hora   : 16/12/1999 14:23
Revisao     :
Obs.        :
*/
Function EECSI101()

    Local nOldArea:=Select(),cAlias:="EEP"
    
    Private aRotina := { { STR0001, "AxPesqui"  , 0 , PESQUISAR},; //"Pesquisar"
                         { STR0002, "SI101MAN"  , 0 , VISUALIZAR},; //"Visualizar"
                         { STR0003, "SI101MAN"  , 0 , INCLUIR},; //"Incluir"
                         { STR0004, "SI101MAN"  , 0 , ALTERAR},; //"Alterar"
                         { STR0005, "SI101MAN"  , 0 , EXCLUIR,3} } //"Excluir"
   
    Private cCadastro := STR0006 //"Usuários - Siscomex"

    Begin Sequence
        (cAlias)->(dbSetOrder(1))
        mBrowse(6,1,22,75,cAlias)
    End Sequence
    
    dbSelectArea(nOldArea)
    
Return NIL

/*
Funcao      : SI101Man
Parametros  : nOpc    := Opcao Selecionada
              cTitulo := Titulo da janela
Retorno     : NIL
Objetivos   : Geracao de Dados para o Siscomex
Autor       : Cristiano A. Ferreira
Data/Hora   : 16/12/1999 15:45
Revisao     :
Obs.        :
*/
Function SI101Man(cAlias,nReg,nOpc)

Local oDlg, nInc
Local nOpcA := 0

Local bValidAll := {|a,b,n| a:= __ReadVar,;
                            n:= aScan(aObjs,{|x| __ReadVar:=x:cReadVar, !Eval(x:bValid) }),;
                            __ReadVar := a,;
                            if(n != 0, aObjs[n]:SetFocus(), ),;
                            n == 0 }

Local bOk := {|| nOpcA := 1,if(nOpc==VISUALIZAR .Or. nOpc == EXCLUIR .Or. Eval(bValidAll),oDlg:End(),nOpcA:=0) }
Local bCancel := {|| oDlg:End() }
Local aObjs[5]

Local aCpos := ArrayBrowse("EER","Work")
Local cFileTemp, aPos

Begin Sequence
   
   IF nOpc != INCLUIR
      For nInc := 1 TO (cAlias)->(FCount())
         M->&((cAlias)->(FIELDNAME(nInc))) := (cAlias)->(FieldGet(nInc))
      Next nInc
      
      M->EEP_SENHA := EEP->EEP_SENHA // Decrypt(EEP->EEP_SENHA)
      M->EEP_NVSEN := EEP->EEP_SENHA // Decrypt(EEP->EEP_NVSEN)
   Else
      For nInc := 1 TO (cAlias)->(FCount())
         M->&((cAlias)->(FIELDNAME(nInc))) := CRIAVAR((cAlias)->(FIELDNAME(nInc)))
      Next nInc
   Endif
   
   cFileTemp := E_CriaTrab("EER",,"Work")
   IndRegua("Work",cFileTemp+TEOrdBagExt(),"EER_PREEMB")
   
   SI101GrvWork()
   
   Work->(dbGoTop())
   
   DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
   
      @ 18,03 SAY AVSX3("EEP_CNPJ",AV_TITULO)   PIXEL OF oDlg
      @ 29,03 SAY AVSX3("EEP_SISTEM",AV_TITULO) PIXEL OF oDlg
      @ 40,03 SAY AVSX3("EEP_USUARI",AV_TITULO) PIXEL OF oDlg
      @ 51,03 SAY AVSX3("EEP_SENHA",AV_TITULO)  PIXEL OF oDlg
      @ 62,03 SAY AVSX3("EEP_NVSEN",AV_TITULO)  PIXEL OF oDlg
   
      @ 18,40 MSGET aObjs[1] VAR M->EEP_CNPJ   PICTURE AVSX3("EEP_CNPJ",AV_PICTURE) PIXEL OF oDlg ;
              VALID Eval(AVSX3("EEP_CNPJ",7)) WHEN (nOpc == INCLUIR) SIZE 3.5*AVSX3("EEP_CNPJ",AV_TAMANHO),08
      @ 29,40 MSGET aObjs[2] VAR M->EEP_SISTEM PICTURE AVSX3("EEP_SISTEM",AV_PICTURE) PIXEL OF oDlg ;
              VALID Eval(AVSX3("EEP_SISTEM",7)) WHEN ((nOpc==INCLUIR .Or. nOpc==ALTERAR) .And. Eval(AVSX3("EEP_SISTEM",13))) SIZE 3.5*AVSX3("EEP_SISTEM",AV_TAMANHO),08
      @ 40,40 MSGET aObjs[3] VAR M->EEP_USUARI PICTURE AVSX3("EEP_USUARI",AV_PICTURE) PIXEL OF oDlg ;
              VALID Eval(AVSX3("EEP_USUARI",7)) WHEN ((nOpc==INCLUIR .Or. nOpc==ALTERAR) .And. Eval(AVSX3("EEP_USUARI",13))) SIZE 3.5*AVSX3("EEP_USUARI",AV_TAMANHO),08
      @ 51,40 MSGET aObjs[4] VAR M->EEP_SENHA  PICTURE AVSX3("EEP_SENHA",AV_PICTURE) PIXEL OF oDlg PASSWORD ;
              VALID Eval(AVSX3("EEP_SENHA",7)) WHEN ((nOpc==INCLUIR .Or. nOpc==ALTERAR) .And. Eval(AVSX3("EEP_SENHA",13))) SIZE 3.5*AVSX3("EEP_SENHA",AV_TAMANHO),08
      @ 62,40 MSGET aObjs[5] VAR M->EEP_NVSEN  PICTURE AVSX3("EEP_NVSEN",AV_PICTURE) PIXEL OF oDlg PASSWORD ;
              VALID Eval(AVSX3("EEP_NVSEN",7)) WHEN ((nOpc==INCLUIR .Or. nOpc==ALTERAR) .And. Eval(AVSX3("EEP_NVSEN",13))) SIZE 3.5*AVSX3("EEP_NVSEN",AV_TAMANHO),08
      
      aPos := PosDlg(oDlg)
      aPos[1] := 75
      
      //GFP 26/10/2010
      aCpos := AddCpoUser(aCpos,"EER","2")
           
      oBrowNote:= MsSelect():New("Work",,,aCpos,,,aPos)
      oBrowNote:bAval:={|cArq|;
       cArq := AllTrim(Left(Work->EER_IDTXT,8))+if(Work->EER_STASIS == "3",".INC",IF(Work->EER_STASIS =="5" ,".ERR",".OK")),;
       AvCpyArqSrv(cArq),;
       Winexec("NotePad"+" "+DirCrw()+"\"+cArq) }
   
      IF nOpc == EXCLUIR
         bOk := {|| nOpcA :=1,IF(Work->(EasyReccount("Work"))==0.And.MsgYesNo(STR0007,STR0008),oDlg:End(),nOpcA:=0),; //"Confirma exclusão do registro ?"###"Aviso"
                 IF(nOpcA==0.And.Work->(EasyReccount("Work"))<>0,HELP(" ",1,"AVG0005071"),) }
      Endif
       
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel)
   
   IF nOpcA == 0 .Or. nOpc == VISUALIZAR
      Break
   Endif
   
   EEP->(RecLock("EEP",nOpc == INCLUIR))
   
   IF nOpc == EXCLUIR
      EEP->(dbDelete())
   Else
      AVReplace("M","EEP")
      EEP->EEP_SENHA := M->EEP_SENHA // Encrypt(M->EEP_SENHA)
      EEP->EEP_NVSEN := M->EEP_NVSEN // Encrypt(M->EEP_NVSEN)
   Endif
   
   EEP->(MsUnlock())
   
End Sequence

Work->(E_EraseArq(cFileTemp))

Return NIL

/*
Funcao      : SI101GrvWork()
Parametros  : nOpc := Opcao Selecionada
Retorno     : NIL
Objetivos   : Grava Work baseado nos dados do EEP
Autor       : Cristiano A. Ferreira
Data/Hora   : 16/12/1999 16:15
Revisao     :
Obs.        :
*/
Function SI101GrvWork()

EER->(dbSeek(xFilial()+M->EEP_CNPJ))

While EER->(!Eof() .And. EER_FILIAL == xFilial("EER")) .And.;
    EER->EER_CNPJ == M->EEP_CNPJ
    
   Work->(dbAppend())
   AvReplace("EER","Work")

   EER->(dbSkip())
Enddo

Return NIL


/*
Função      : SI100CadAgrup
Objetivo    : Manutenção (Inclusão, Ateração, Exclusão e Visualização) das opções de agrupamento para R.E./Anexo.
Autor       : Alexsander Martins dos Santos
Data e Hora : 02/05/2005 às 16:55.
*/

Function SI100CadAgrup()

Local cOldArea := Select()

Begin Sequence

   If IsVazio("EXO")
      Processa({|| EXOLoad(), STR0009, STR0010, .F.}) //"Aguarde"###"Carga de Agrupamentos"
   EndIf

   AXCadastro("EXO", AnsitoOem(STR0011),, "CadAgrupVld()") //"Agrupamento para R.E./Anexo"

End Sequence

dbSelectArea(cOldArea)

Return(.T.)


/*
Função      : CadAgrupVld()
Objetivo    : Validação dos dados no cadastro de agrupamento para R.E./Anexo quando pressionado o botão Ok.
Retorno     : .T. = Dados consistentes.
              .F. = Dados inconsistentes.
Autor       : Alexsander Martins dos Santos
Data e Hora : 03/05/2005 às 14:23.
*/

Function CadAgrupVld()

Local lRet     := .F.

Begin Sequence

   If M->(Empty(EXO_RE) .and. Empty(EXO_ANEXO))
      MsgStop(STR0012, STR0013) //"Deve ser informada a condição de agrupamento."###"Atenção"
      Break
   EndIf

   If Select("EE9") = 0
      Eval({|x| dbSelectArea("EE9"),;
                dbSelectArea(x)}, Select())
   EndIf

   If !Empty(M->EXO_RE) .and. Type(M->EXO_RE) = "UE"
      MsgStop("A condição informada no campo "+AVSX3("EXO_RE", AV_TITULO)+" não é valida.", "Atenção")
      Break
   EndIf

   If !Empty(M->EXO_ANEXO) .and. Type(M->EXO_ANEXO) = "UE"
      MsgStop("A condição informada no campo "+AVSX3("EXO_ANEXO", AV_TITULO)+" não é valida.", "Atenção")
      Break
   EndIf

   lRet := .T.

End Sequence

Return(lRet)


/*
Função      : WizardRE
Objetivo    : Assistente para geração de R.E.
Retorno     : .T. = R.E's geradas.
              .F. = Geração de R.E. abortada.
Autor       : Alexsander Martins dos Santos
Data e Hora : 16/05/2005 às 15:15.
*/

Function WizardRE(nOpc)
Local lRet := .F.
Private nOpcRE:= nOpc

Begin Sequence

   If !IsMarcado("TRB", "WK_FLAG")
      Help(" ", 1, "AVG0005067") //"Não há registros marcado para a Geração de Arquivos !"
      Break
   EndIf

   lRet := WizardREUser()
   TRB->(DBGoTop())
   
   If EECFlags("NOVOEX")
      lReOK := lRet
      lRet := .T.
   EndIf
   
End Sequence

Return(lRet)


/*
Função      : WizardREUser
Objetivo    : Solicitar o usuário que será registrada a R.E. no SISCOMEX.
Retorno     : .T. = R.E's geradas.
              .F. = Geração de R.E. abortada.
Autor       : Alexsander Martins dos Santos
Data e Hora : 04/05/2005 às 17:37.
*/

Function WizardREUser()

Local lRet         := .F.
Local lInverte     := .F.
Local aMSSelFields := {}

Private oMSSelect
//Private cMarca

Static cWorkUser

Begin Sequence

   If Select("WorkUser") = 0
      cWorkUser := WizardRECriaWork("EEP", "WorkUser")
   EndIf

   //cMarca := AVGetMark("WorkUser", "WK_FLAG")

   aMSSelFields := ArrayBrowse("EEP", "WorkUser")

   aDel(aMSSelFields, 3)
   aIns(aMSSelFields, 1)

   aMSSelFields[1] := {"WK_FLAG", "XX", ""}

   WorkUser->(dbGoTop())
   
   
   Define MSDialog oDlg Title STR0015 From 0, 0 To 562, 455 Of oMainWnd Pixel //"Geração de R.E."
   Define FONT oBold Name "Arial" Size 0, -12 BOLD

   @ 010, 08 Say STR0016 Pixel FONT oBold //"Seleção de Usuários"
   @ 030, 08 Say STR0017 Pixel //"Selecione o usuário que irá registrar a R.E. no SISCOMEX"

   @ 045, 08 To 210, 221 Label "Usuários" Pixel

   oMSSelect       := MSSelect():New("WorkUser", "WK_FLAG",, aMSSelFields, @lInverte, @cMarca, {52, 11, 206, 217})
   oMSSelect:bAval := {|| SI101OneMark("WorkUser", "WK_FLAG")}

   @ 219, 08 Say STR0019 Pixel //"Para prosseguir, clique no botão Avançar ou Cancelar para abortar a geração de R.E."

   Define SButton oBtAvancar  From 260, 191 Type 19 Action (oDlg:End(), lRet:= WizardREAgrup()) Disable Of oDlg
   Define SButton oBtCancelar From 260, 160 Type 02 Action (oDlg:End(), lRet := .F.) Enable Of oDlg

   If IsMarcado("WorkUser", "WK_FLAG")
      oBtAvancar:lActive := .T.
   EndIf
	  
   If !EECFlags("NOVOEX")
      Activate MSDialog oDlg Centered
   Else
	  oDlg:lVisible := .F.
	  Activate MSDialog oDlg Centered ON INIT oDlg:End()
	  lRet:= WizardREAgrup()
   End If
   
   If Select("WorkUser") <> 0
      WorkUser->(E_EraseArq(cWorkUser))
   EndIf

End Sequence

Return(lRet)


/*
Função      : WizardREAgrup
Objetivo    : Solicitar a opção de agrupamento para geração da R.E.
Retorno     : .T. = R.E's geradas.
              .F. = Geração de R.E. abortada.
Autor       : Alexsander Martins dos Santos
Data e Hora : 04/05/2005 às 18:01.
*/

Static Function WizardREAgrup()

Local lRet         := .F.
Local lInverte     := .F.
Local aMSSelFields := {}

Private oMSSelect
//Private cMarca

Static cWorkAgrup

oCfg := EASYUSERCFG():New()  // GFP - 05/12/2013

Begin Sequence

    //DFS - 16/07/12 - Inclusão de validação na rotina de agrupamento. Isto define se irá agrupar as descrições separadas por barra ou uma por linha.
   If AllTrim(EasyGParam("MV_AVG0212",,"1")) == "1"
      lSepMerc := .T.
   ElseIf AllTrim(EasyGParam("MV_AVG0212",,"1")) == "2"
      lSepMerc := .F.
   Else
      lSepMerc := oCfg:LoadParam("MV_AVG0212", .T.)
   EndIf
   /*
   Caso a tabela de Agrupamento(EXO) estiver vazia, é carregada com as opções de agrupamento padrão.
   */
   If IsVazio("EXO")
      Processa({|| EXOLoad(), STR0009, STR0010, .F.}) //"Aguarde"###"Carga de Agrupamentos"
   EndIf
   
   //WFS 24/07/2009
   //Inclusão do registro 06, agrupamento por RE, para alteração de RE
   EXO->(DBSetOrder(1)) //EXO_FILIAL + EXO_COD
   If !EXO->(DBSeek(xFilial() + "06"))
      EXO->(RecLock("EXO", .T.))
      EXO->EXO_COD:= "06"
      EXO->EXO_DESCR:= "RE"
      EXO->EXO_RE:= ""
      EXO->EXO_ANEXO:= "EE9->EE9_RE"
      EXO->(MsUnlock())
   EndIf

   If Select("WorkAgrup") == 0
      cWorkAgrup := WizardRECriaWork("EXO", "WorkAgrup")
   EndIf

   //cMarca := AVGetMark("WorkAgrup", "WK_FLAG")

   //WFS 24/07/2009
   //Se for alteração de RE, executará as instruções abaixo e não exibirá a tela para a selecão de agrupamento.
   //O agrupamento será sempre por RE, código 06.
   //If nOpcRe == ALTERAR_RE
   //wfs 29/11
   
   If PossuiItemSemRe()
      TRB->EEC_STASIS := SI_RS
   EndIf
   
   If TRB->EEC_STASIS == SI_SF
      cTipoArq:= "A"   
   
      WorkAgrup->(DBGoTop())
      While WorkAgrup->(!Eof())
         If WorkAgrup->EXO_COD == "06"
            WorkAgrup->WK_FLAG:= cMarca
            Exit
         EndIf
         WorkAgrup->(DBSkip())
      End

      lRet:= WizardREGera()
      
      If Select("WorkAgrup") <> 0
         WorkAgrup->(E_EraseArq(cWorkAgrup))
      EndIf
      
      Break
   EndIf

   //Quando for inclusão, o agrupamento por RE não será exibido
   WorkAgrup->(DBGoTop())
   While WorkAgrup->(!Eof())
      If WorkAgrup->EXO_COD == "06"
         WorkAgrup->(DBDelete())
         Exit
      EndIf
      WorkAgrup->(DBSkip())
   End

   aMSSelFields := ArrayBrowse("EXO", "WorkAgrup")

   aAdd(aMSSelFields, {})
   aIns(aMSSelFields, 1)

   aMSSelFields[1] := {"WK_FLAG", "XX", ""}

   WorkAgrup->(dbGoTop())

   Define MSDialog oDlg Title STR0015 From 0, 0 To 562, 455 Of oMainWnd Pixel //"Geração de R.E."
   //Define FONT oBold Name "Arial" Size 0, -12 BOLD

   @ 010, 08 Say STR0020 Pixel FONT oBold //"Seleção de Agrupamento"
   @ 030, 08 Say STR0042 Pixel //"Indique o agrupamento para geração de R.E."

   @ 045, 08 To 210, 221 Label STR0022 Pixel //"Agrupamentos"

   oMSSelect       := MSSelect():New("WorkAgrup", "WK_FLAG",, aMSSelFields, @lInverte, @cMarca, {52, 11, 206, 217})
   oMSSelect:bAval := {|| SI101OneMark("WorkAgrup", "WK_FLAG")}
   
   If EECFlags("NOVOEX")
      //oCfg := EASYUSERCFG():New()  // GFP - 05/12/2013
      
      If AllTrim(EasyGParam("MV_AVG0197",,"1")) == "1"
         lAddAnexos := .T.
      ElseIf AllTrim(EasyGParam("MV_AVG0197",,"1")) == "2"
         lAddAnexos := .F.
      Else
         lAddAnexos := oCfg:LoadParam("MV_AVG0197", .T.)
      EndIf                       
      
      cMsgAnexos := "Caso um dos anexos gerados no RE seja rejeitado pelo Siscomex, sera necessario cancelar o RE no Siscomex para que o sistema possa reenvia-lo."+Chr(13)+Chr(10)+;
                    "Tem certeza que deseja gerar varios anexos por RE?"
      
      @ 212, 08 CHECKBOX oCbx VAR lAddAnexos PROMPT "Permitir varios anexos por RE." OF oDlg SIZE 145,8 PIXEL WHEN AllTrim(EasyGParam("MV_AVG0197",,"1")) == "3" ON CHANGE (if(lAddAnexos,(lAddAnexos:=MsgYesNo(cMsgAnexos),oCbx:Refresh()),.T.))
      //DFS - 16/07/12 - Inclusão de ComboBox para permitir que o usuário decida isso antes da geração do RE
      @ 222, 08 CHECKBOX oCbx VAR lSepMerc PROMPT "Separar as Mercadorias por RE quando utilizar o agrupamento por NCM" OF oDlg SIZE 187,8 PIXEL WHEN AllTrim(EasyGParam("MV_AVG0212",,"1")) == "3" ON CHANGE (oCbx:Refresh(),.T.)      
   EndIf
   
   @ 232, 08 Say "Para prosseguir, clique no botão Avançar ou Cancelar para abortar a geração de R.E." Pixel 
   @ 242, 08 Say "Para retornar a seleção de usuários, clique no botão Voltar." Pixel 
   @ 252, 08 Say "Para incluir um agrupamento, clique no botão Incluir." Pixel

   Define SButton oBtAvancar  From 267, 191 Type 19 Action (lRet := WizardREGera()) Disable Of oDlg
   Define SButton oBtVoltar   From 267, 160 Type 20 Action (oDlg:End(), WizardREUser()) Enable Of oDlg
   Define SButton oBtIncluir  From 267, 129 Type 04 Action (SI100CadAgrup(), LoadWork("EXO", "WorkAgrup", .T., "EXO_COD")) Enable Of oDlg OnStop STR0045 //"Manutenção"
   Define SButton oBtCancelar From 267, 098 Type 02 Action (oDlg:End(), lRet := .F.) Enable Of oDlg

   If IsMarcado("WorkAgrup", "WK_FLAG")
      oBtAvancar:lActive := .T.
   EndIf
   
   If EECFlags("NOVOEX")
      oBtVoltar:lActive := .F.
   EndIf
   
   Activate MSDialog oDlg Centered

   If EECFlags("NOVOEX")
      oCfg:SetParam("MV_AVG0197", lAddAnexos)
      //DFS - 16/07/12 - Definição do conteudo do parâmetro. 
      oCfg:SetParam("MV_AVG0212", lSepMerc)
   EndIf

   If Select("WorkAgrup") <> 0
      WorkAgrup->(E_EraseArq(cWorkAgrup))
   EndIf

End Sequence

Return(lRet)


/*
Função      : WizardREGera
Objetivo    : Geração da(s) R.E.(s)
Retorno     : .T. = R.E's geradas.
              .F. = Geração de R.E. abortada.
Autor       : Alexsander Martins dos Santos
Data e Hora : 05/05/2005 às 14:10.
Revisão     : WFS em 24/07/2009
              Inclusão de tratamentos para alteração de RE
*/

Static Function WizardREGera()
Local lRetGeraTXT
Local lRet := .F.

Local cUser  := ContentMark("WorkUser", "WK_FLAG", "EEP_CNPJ")
Local cAgrup := ContentMark("WorkAgrup", "WK_FLAG", "EXO_COD")

Begin Sequence
   
   //Do Case
   //   Case nOpcRe == INCLUIR_RE
         Processa({|| lRetGeraTXT := SI100GeraTXT(cUser, INCLUIR_RE, Val(cAgrup), oDlg)})
         
   //   Case nOpcRe == ALTERAR_RE
   //      Processa({|| lRetGeraTXT:= SI102AltRE(cUser, ALTERAR_RE, Val(cAgrup), oDlg)})
   //EndCase

   If !lRetGeraTXT
      Break
   EndIf

   If cTipoArq <> "A"
   		oDlg:End()
   EndIf

   If !EECFlags("NOVOEX")
      lRet:= WizardRESiscomex()
   Else
      lRet := lRetGeraTXT
   End If
         
End Sequence

Return(lRet)


/*
Função      : WizardRESiscomex
Objetivo    : Orientar o usuário a se conectar no SISCOMEX e posicionar na tela de start para o DIGRE.
Retorno     : .T. = R.E's geradas.
              .F. = Geração de R.E. abortada.
Autor       : Alexsander Martins dos Santos
Data e Hora : 11/05/2005 às 09:54.
*/

Static Function WizardRESiscomex()

Local lRet     := .F.

Local nEmbarque := 0
Local nCNPJ     := 0
Local aFilesInc, nInd  // JPP - 10/08/2005 - 17:30
Local cPathOr := AllTrim(EasyGParam("MV_AVG0002"))  // Path para gravacao dos txt - JPP - 10/08/2005 - 17:30
Local cPathDt := AllTrim(EasyGParam("MV_AVG0003"))  // Path de Retorno do txt - JPP - 10/08/2005 - 17:30

Private cInfLer := .T.

Begin Sequence

   For nCNPJ := 1 To Len(aCNPJ)

      Define MSDialog oDlg Title STR0015+" - "+STR0032+"("+LTrim(Str(nCNPJ))+"/"+LTrim(Str(Len(aCNPJ)))+")" From 0, 0 To 562, 455 Of oMainWnd Pixel //"Geração de R.E."###"Registro: "
      Define FONT oBold Name "Arial" Size 0, -12 BOLD

      @ 010, 08 Say STR0025 Pixel FONT oBold //"Conexão com SISCOMEX"

      @ 030, 08  Say STR0026 Pixel //"Conecte-se no SISCOMEX com o CNPJ:"
      @ 030, 104 Say Transf(aCNPJ[nCNPJ][1], AVSX3("A2_CGC", AV_PICTURE)) Pixel FONT oBold
      @ 030, 161 Say STR0027 Pixel //"e posicione na tela abaixo."

      @ 045, 08 To 204, 221 Label STR0028 Pixel //"Siscomex"
      @ 052, 11 BitMap ResName "Siscomex" Size 368, 512 NoBorder Of oDlg Pixel

      @ 213, 08 Say STR0029 Pixel //"Apos ter posicionado na tela acima, clique no botão Avançar para iniciar a geração"
      @ 223, 08 Say STR0030 Pixel //"da R.E. no SISCOMEX."
      @ 233, 08 Say STR0031 Pixel //"Para retornar a seleção de agrupamento, clique no botão Voltar."

      Define SButton From 260, 191 Type 19 Of oDlg Action (lRet := WizardRERegistra(aCNPJ[nCNPJ][2])) Enable
      Define SButton From 260, 160 Type 20 Of oDlg Action (oDlg:End(), WizardREAgrup()) Enable
      Define SButton From 260, 129 Type 02 Of oDlg Action (oDlg:End(), lRet := .F.) Enable

      Activate MSDialog oDlg Centered

   Next

   /*
   Retorno das R.E.
   */
   If lRet
      MSAguarde({|| MSProcTXT(STR0036), SI100Ret()}, STR0009) //"Gravação da R.E. nos itens dos embarque"###"Aguarde"

      // JPP - 10/08/2005 - 17:30 - Após o retorno excluir todos os Arquivos ".INC" restantes.
      aFilesInc := DIRECTORY(cPathOr+"*.INC")
      For nInd := 1 To Len(aFilesInc)
         If File(cPathor+aFilesInc[nInd][1])
            Copy File (cPathor+aFilesInc[nInd][1]) To (cPathdt+aFilesInc[nInd][1])
            FErase(cPathor+aFilesInc[nInd][1])
         EndIf   
      Next
   EndIf
//   If !lRetRetorno
//      MsgStop(STR0036, STR0013) //"Não foi possivel obter o número da R.E. Verifique se o item foi registrado corretamente no SISCOMEX."###"Atenção"
//      oDlg:End()
//      Break
//   EndIf

End Sequence

Return(lRet)


/*
Função      : WizardRERegistra
Objetivo    : Orientar o usuária a registrar a R.E. no SISCOMEX.
Parematro   : aFiles_CNPJ = Array com os nomes dos arquivos que serão gravados no EECTOT.AVG do CNPJ.
Retorno     : .T.         = R.E. Gerada.
              .F.         = R.E. não gerada.
Autor       : Alexsander Martins dos Santos
Data e Hora : 10/05/2005 às 15:14.
Revisão     : WFS em 24/04/2009
              Inclusão de tratamentos para alteração de RE.
              Correção das chamadas de arquivos
*/

Static Function WizardRERegistra(aFiles_CNPJ)

Local lRet      := .F.
Local nTerminal := EasyGParam("MV_AVG0091",, 0)
Local cPatch    := EasyGParam("MV_AVG0002",, "C:\EEC-SISC\")
Local aFiles    := {}
Local nPos      := 0
Local cMsg      := ""
Local aFilesOk  := {}
Local aFilesErr := {}
Local cDir      := EasyGParam("MV_AVG0002",, "C:\EEC-SISC\ORISISC\")
Local lRetRetorno, hFile, nFile
Local cFile     := ""

Do Case
   Case nOpcRe == INCLUIR_RE
      aFiles:= {{"avgiww.bat" , "avgiww.exe"   ,  "dig_re.cmd", "killtask.exe"},;
                {"AvgPack.bat", "avgpackre.exe", "avgpack.exe", "dig_re.cmd"  }}
             
   Case nOpcRe == ALTERAR_RE
      aFiles:= {{"AvgIWW_Alt_RE.bat" , "avgiww.exe",  "Alt_RE.cmd", "killtask.exe"},;
                {"AvgPack_Alt_RE.bat", "avgpackre.exe", "avgpack.exe", "Alt_RE.cmd"}}
EndCase

Begin Sequence

   /*
   Verifica se existe configurado o parametro que define o emulador de terminal para acessar o SISCOMEX e caso não exista
   é apresentada tela, solicitando o terminal a ser utilizado.
   */
   nTerminal := If(nTerminal = 1 .or. nTerminal = 2, nTerminal, RESelectTerm())

   If nTerminal = 0
      Break
   EndIf

   /*
   Verifica se os arquivos necessários para registrar a(s) R.E(s) no SISCOMEX exitem no diretório configurado.
   */
   cPatch := AllTrim(SubStr(cPatch, 1, At("ORISISC", cPatch)-1))

   For nPos := 1 To Len(aFiles[nTerminal])
      If !File(cPatch+aFiles[nTerminal][nPos])
         cMsg += aFiles[nTerminal][nPos] + ENTER
      EndIf
   Next

   If !Empty(cMsg)
      MsgStop(STR0033+cPatch+"." +Replicate(ENTER, 2)+; //"Os seguintes arquivos não foram encontrados no diretório "
              cMsg +ENTER+;
              STR0034 , STR0013) //"Verifique se os arquivos não se encontram em outro diretório."###"Atenção"
      Break
   EndIf
   
   If nOpcRE == INCLUIR_RE
      /*
      Geração do arquivo EECTOT.AVG com o arquivo referente ao CNPJ da unid.exp. à ser registro no SISCOMEX.
      */
      cDir += If(Right(cDir, 1) = "\", "", "\")

      If File(cDir+"EECTOT.AVG")
         fErase(cDir+"EECTOT.AVG")
      EndIf

      hFile := EasyCreateFile(cDir+"EECTOT.AVG")

      For nFile := 1 To Len(aFiles_CNPJ)
         cFile += aFiles_CNPJ[nFile] + CRLF
      Next

      cFile += "####eof#####" + CRLF

      fWrite(hFile, cFile, Len(cFile))

      fClose(hFile)
   EndIf

   /*
   Geração de R.E.
   */

   MSAguarde({|| MSProcTXT(STR0035), WaitRun(cPatch + aFiles[nTerminal][1])}, STR0009) //"Registrando no SISCOMEX"###"Aguarde"

/* Nopado por WFS em 24/07/2009
   Do Case

      Case nTerminal = IWW
         MSAguarde({|| MSProcTXT(STR0035), WaitRun(cPatch+"avgiww.bat")}, STR0009) //"Registrando no SISCOMEX"###"Aguarde"

      Case nTerminal = Packet
         MSAguarde({|| MSProcTXT(STR0035), WaitRun(cPatch+"avgpack.bat")}, STR0009) //"Registrando no SISCOMEX"###"Aguarde"

   End Case

//   MSAguarde({|| MSProcTXT(STR0035), lRetRetorno := SI100Ret()}, STR0009) //"Gravação da R.E. nos itens dos embarque"###"Aguarde"

//   If !lRetRetorno
//      MsgStop(STR0036, STR0013) //"Não foi possivel obter o número da R.E. Verifique se o item foi registrado corretamente no SISCOMEX."###"Atenção"
//      oDlg:End()
//      Break
//   EndIf  */ 

   oDlg:End()

   lRet := .T.

End Sequence

Return(lRet)


/*
Função      : RESelectTerm
Objetivo    : Solicitar ao usuário o emulador de terminal utilizado para acessar remotamente o siscomex.
Retorno     : 0 - Terminal não selecionado.
              1 - IWW
              2 - Packet
Autor       : Alexsander Martins dos Santos
Data e Hora : 12/05/2005 ás 09:53.
*/

Static Function RESelectTerm()

Local nRet      := 0
Local nTerminal := 1
Local nOpc      := 0

Begin Sequence

   Define MSDialog oDlg Title STR0038 From 0, 0 To 195, 310 Of oMainWnd Pixel //"Terminal de acesso ao Siscomex"

   @ 010, 08 Say STR0039 Pixel //"Informe o emulador de terminal, utilizado para acessar"
   @ 020, 08 Say STR0040 Pixel //"remotamente o SISCOMEX."

   @ 035, 08 To 69, 148 Label STR0041 Pixel //"Terminais"

   @ 045, 11 Radio oTerminal Var nTerminal Size 90, 09 Items "1 - IWW",;
                                                             "2 - Packet" Of oDlg Pixel

   Define SButton From 079, 008 Type 01 Of oDlg Action (nOpc := 1, oDlg:End()) Enable
   Define SButton From 079, 038 Type 02 Of oDlg Action (nOpc := 0, oDlg:End()) Enable

   Activate MSDialog oDlg Centered

   If nOpc = 1

      nRet := nTerminal

   EndIf

End Sequence

Return(nRet)


/*
Função      : WizardRECriaWork()
Objetivo    : Criação e carregamento da Work de usuários (WorkUser).
Parametro   : cBase     = Alias da tabela base.
              cWork     = Alias da work a ser criada.
Retorno     : cFileName = Nome do arquivo criado para work.
Autor       : Alexsander Martins dos Santos
Data e Hora : 05/05/2005 às 14:39.
*/

Static Function WizardRECriaWork(cBase, cWork)

Local cFileName := ""
Local aSemSX3   := { {"WK_RECNO", "N", 07, 00},;
                     {"WK_FLAG",  "C", 02, 00} }

Private aCampos := Array((cBase)->(fCount()))
Private aHeader := {}

Begin Sequence

   cFileName := E_CriaTrab(cBase, aSemSX3, cWork)

   LoadWork(cBase, cWork)

End Sequence

Return(cFileName)


/*
Função      : AVGetMark()
Objetivo    : Criar/Localizar a flag de marcação do MSSelect e retornar o conteúdo para marcação.
Parametro   : cWork    = Alias da Work que contém a flag de marcação.
              cFlag    = Campo da Work reservado para flag.
Retorno     : cGetMark
Autor       : Alexsander Martins dos Santos
Data e Hora : 05/05/2005 às 14:58.
*/

/*
Function AVGetMark(cWork, cFlag)

Local cGetMark := ""

Begin Sequence

   (cWork)->(Eval({|x| dbGoTop(),;
                       dbEval({|| cGetMark := &(cFlag)}, {|| !Empty(&(cFlag))}, {|| Empty(cGetMark)},,, .F.),;
                       dbGoTo(x)}, Recno()))

   If Empty(cGetMark)
      cGetMark := GetMark()
   EndIf

End Sequence

Return(cGetMark)
*/


/*
Função      : SI101OneMark()
Objetivo    : Marcar/Desmarcar uma seleção, onde não pode haver mais de uma selecionada.
Parametro   : cWork    = Alias da Work que contém a flag de marcação.
              cFlag    = Campo da Work reservado para flag.
Retorno     : cGetMark
Autor       : Alexsander Martins dos Santos
Data e Hora : 05/05/2005 às 15:46.
*/

Function SI101OneMark(cWork, cFlag,oMSSel)
Default oMSSel := oMSSelect
Begin Sequence

   Do Case

      Case Empty((cWork)->&(cFlag))

         (cWork)->(Eval({|x| dbEval({|| &(cFlag) := ""}, {|| &(cFlag) <> ""}),;
                             dbGoTo(x),;
                             &(cFlag) := cMarca}, Recno()))

         If Type("oBtAvancar") == "O"
            oBtAvancar:lActive := .T.
         EndIf

      Case !Empty((cWork)->&(cFlag))

         (cWork)->&(cFlag) := ""

         If Type("oBtAvancar") == "O"
            oBtAvancar:lActive := .F.
         EndIf
         
   End Case

   If Type("oBtAvancar") == "O"
      oBtAvancar:Refresh()
   EndIf
   oMSSel:oBrowse:Refresh()

End Sequence

Return(Nil)


/*
Função      : IsMarcado
Objetivo    : Retorna verdadeiro ou falso se encontrar um registro marcado/selecionado.
Parametro   : cWork = Alias da Work que contém a flag de marcação.
              cFlag = Campo da Work reservado para flag.
Retorno     : .T. = Existe marcação.
              .F. = Não existe marcação.
Autor       : Alexsander Martins dos Santos
Data e Hora : 05/05/2005 às 16:46.
*/

Function IsMarcado(cWork, cFlag)

Local lRet := .F.

Begin Sequence

   (cWork)->(Eval({|x| dbGoTop(),;
                       dbEval({|| lRet := .T.}, {|| !Empty(&(cFlag))}, {|| lRet = .F.}),;
                       dbGoTo(x)}, Recno()))

End Sequence

Return(lRet)


/*
Função      : EXOLoad
Objetivo    : Carregar a tabela de agrupamentos(EXO) com opções padrôes no sistema.
Retorno     : Nil
Autor       : Alexsander Martins dos Santos
Data e Hora : 06/05/2005 às 15:35.
*/

Function EXOLoad()

Local aEXO_Campo, nCampo
Local aEXO_Conteudo, nConteudo

Begin Sequence

   aEXO_Campo := { "EXO_COD",;
                   "EXO_DESCR",;
                   "EXO_RE",;
                   "EXO_ANEXO" }

   aEXO_Conteudo := { { "01",;
                        "Item",;
                        "",;
                        "EE9->EE9_SEQEMB" },;
                      { "02",;
                        "NCM + Item +Preço",;
                        "",;
                        "EE9->(EE9_POSIPI+EE9_COD_I+AVKey(EE9_PRECOI, "+Chr(34)+"EE9_PRECOI"+Chr(34)+"))" },;
                      { "03",;
                        "NCM + Preço",;
                        "",;
                        "EE9->(EE9_POSIPI+AVKey(EE9_PRECOI, "+Chr(34)+"EE9_PRECOI"+Chr(34)+"))" },;
                      { "04",;
                        "NCM",;
                        "",;
                        "EE9->EE9_POSIPI" },;
                      { "05",;
                        "Item por RC",;
                        "",;
                        "EE9->EE9_RC" } }

   //WFS 24/07/2009
   //Inclusão do registro 06, agrupamento por RE, para alteração de RE
   AAdd(aEXO_Conteudo, {"06",;
                        "RE",;
                        "",;
                        "EE9->EE9_RE"})

   ProcRegua(Len(aEXO_Conteudo))

   For nConteudo := 1 To Len(aEXO_Conteudo)

      IncProc()
      RecLock("EXO", .T.)
	  
	  EXO->EXO_FILIAL := xFilial("EXO")
      For nCampo := 1 To Len(aEXO_Campo)
         EXO->&(aEXO_Campo[nCampo]) := aEXO_Conteudo[nConteudo][nCampo]
      Next

      EXO->(MSUnlock())

   Next

End Sequence

Return(Nil)


/*
Função      : LoadWork
Objetivo    : Carregar a work com os dados da tabela base.
Parametros  : cBase    = Alias da tabela que contem os dados para carregar a work.
              cWork    = Alias da work que será carregada.
              lRefresh = .T. = O metodo refresh será executado no objeto da grade de seleção.
                         .F. = Não ocorrera o refresh na grade de seleção.
Retorno     : Nil
Autor       : Alexsander Martins dos Santos
Data e Hora : 16/05/2005 às 13:57.
*/

Static Function LoadWork(cBase, cWork, lRefresh, cId)

Local aSaveMark

Default lRefresh := .F.

Begin Sequence

   If Select(cWork) = 0
      Break
   EndIf

   If cId <> Nil
      aSaveMark := SaveMark(cWork, "WK_FLAG", cId)
   EndIf

   If !IsVazio(cWork)
      avZap(cWork)
   EndIf

   (cBase)->(dbEval({|| (cWork)->(dbAppend(),;
                                  AvReplace(cBase, cWork))}))

   If aSaveMark <> Nil
      RestMark(aSaveMark)
   EndIf

   If lRefresh
      oMSSelect:oBrowse:Refresh()
   EndIf

End Sequence

Return(Nil)


/*
Função      : SaveMark
Objetivo    : Salvar a posição do registro e a posição do registro marcado.
Parametro   : cWork      = Work a ser analisada.
              cFieldMark = Campo da work reservado para marcação.
              cFieldKey  = Campo que contem o código do item.
Retorno     : aRet[1]    = Alias da work a ser analisada.
                  [2]    = Registro posicionado.
                   ..[1] = Campo chave.
                   ..[2] = Conteúdo do campo chave.
                  [3]    = Registro marcado.
                   ..[1] = Campo chave. 
                   ..[2] = Conteúdo do campo chave.
                   ..[3] = Campo flag.
                   ..[4] = Conteúdo do campo flag.
Autor       : Alexsander Martins dos Santos
Data e Hora : 16/05/2005 às 15:44.
Observação  : A work deve ser a area ativa.
*/

Static Function SaveMark(cWork, cFieldMark, cFieldKey)

Local aRet   := {}
Local nRecno := (cWork)->(Recno())

Begin Sequence

   /*
   Adiciona o Alias da Work.
   */
   aAdd(aRet, cWork)

   /*
   Adiciona a chave de localização do registro posicionado.
   */
   aAdd(aRet, {cFieldKey,;
               (cWork)->&(cFieldKey)})

   dbGoTop()

   /*
   Adiciona a chave de localização do registro que está marcado.
   */
   dbEval({|| aAdd(aRet, {cFieldKey,;
                          (cWork)->&(cFieldKey),;
                          cFieldMark,;
                          (cWork)->&(cFieldMark)})}, {|| !Empty((cWork)->&(cFieldMark))}, {|| Len(aRet) = 2})

End Sequence

(cWork)->(dbGoTo(nRecno))

Return(aRet)


/*
Função      : RestMark
Objetivo    : Restaurar a posicição e a flag de marcação no registro.
Parametro   : aKey[1] = Alias da Work a ser restaurada.
                  [2] = Registro posicionado.
                   ..[1] = Campo chave.
                   ..[2] = Conteúdo do campo chave.
                  [3] = Registro marcado.
                   ..[1] = Campo chave.
                   ..[2] = Conteúdo do campo chave.
                   ..[3] = Campo flag.
                   ..[4] = Conteúdo do campo flag.
Retorno     : Nil
Autor       : Alexsander Martins dos Santos
Data e Hora : 16/05/2005 às 16:01.
*/

Static Function RestMark(aKey)

Local lFound := .F.

Begin Sequence

   /*
   Marca o registro da work.
   */
   If Len(aKey) = 3
      (aKey[1])->(dbGoTop(),;
                  dbEval({|| &(aKey[3][3]) := aKey[3][4], lFound := .T.}, {|| &(aKey[3][1]) = aKey[3][2]}, {|| !lFound}))
   EndIf

End Sequence

/*
Posiciona no registro na work.
*/
(aKey[1])->(dbGoTop(),;
            dbEval({||},, {|| &(aKey[2][1]) <> aKey[2][2]}))

If (aKey[1])->(Eof())
   (aKey[1])->(dbGoTop())
EndIf

Return(Nil)


/*
Função      : ContentMark
Objetivo    : Retorna o conteúdo do campo passado como parametro(cFieldReturn) do registro marcado.
Parametros  : cAlias       = Alias da work a ser analisada.
              cFieldFlag   = Nome do campo reservado para flag.
              cFieldReturn = Nome do campo que tera o conteúdo retornado.
Retorno     : xRet         = Conteúdo do campo(cFieldReturn).
Autor       : Alexsander Martins dos Santos
Data e Hora : 18/05/2005 às 16:11
*/

Function ContentMark(cAlias, cFieldFlag, cFieldReturn)

Local xRet := Nil

Begin Sequence

   (cAlias)->(Eval({|x| dbGoTop(),;
                        dbEval({|| xRet := &(cFieldReturn)}, {|| !Empty(&(cFieldFlag))}, {|| Empty(xRet)}),;
                        dbGoTo(x)}, Recno()))

End Sequence

Return(xRet)


/*
Função      : BuscaExportador
Objetivo    : Localizar e retornar o conteúdo com campo passado como parametro na terceira posição.
Parametros  : cCodigo = Codigo do exportador.
              cLoja   = Loja do exportador.
              cCampo  = Nome do campo a retornar o seu conteúdo.
Retorno     : xRet    = Conteúdo do campo a retornar.
Autor       : Alexsander Martins dos Santos
Data e Hora : 19/05/2005 às 15:00.
*/

Function BuscaExportador(cCodigo, cLoja, cCampo)

Local xRet
Local aSaveOrd := SaveOrd("SA2", 1)

Begin Sequence

   SA2->(dbSeek(xFilial()+cCodigo+cLoja),;
         xRet := &(cCampo))

End Sequence

RestOrd(aSaveOrd, .T.)

Return(xRet)


/*
Função      : CNPJUnidExp
Parametro   : cEmb = ID do embarque.
              cSeq = Sequencia do item no embarque.
Retorno     : cRet = CNPJ da unidade exportadora.
Objetivo    : Retornar o CNPJ da unidade exportadora do item no embarque, caso o item não tenha o código da
              unidade exportadora, será retornado o CNPJ do fabricando ou exportador da capa do embarque de
              acordo com qual estiver preenchido.
Autor       : Alexsander Martins dos Santos
Data - Hora : 30/06/2005 - 09:57.
*/

Function CNPJUnidExp(cEmb, cSeq)

Local cRet     := ""
Local aSaveOrd := SaveOrd({"EE9", "EEC"})

EE9->(dbSetOrder(3))
EEC->(dbSetOrder(1))

Begin Sequence

   cEmb := AvKey(cEmb, "EEC_PREEMB")
   cSeq := AvKey(cSeq, "EE9_SEQEMB")

   EE9->(dbSeek(xFilial()+cEmb+cSeq))

   If EE9->(FieldPos("EE9_CODUE") > 0 .and. FieldPos("EE9_LOJUE") > 0 .and. !Empty(EE9_CODUE))
      cRet := BuscaExportador(EE9->EE9_CODUE, EE9->EE9_LOJUE, "A2_CGC")
      Break
   EndIf

   EEC->(dbSeek(xFilial()+cEmb))

   Do Case

      Case !Empty(EEC->EEC_EXPORT)
         cRet := BuscaExportador(EEC->EEC_EXPORT, EEC->EEC_EXLOJA, "A2_CGC")

      Case !Empty(EEC->EEC_FORN)
         cRet := BuscaExportador(EEC->EEC_FORN, EEC->EEC_FOLOJA, "A2_CGC")

   End Case

End Sequence

RestOrd(aSaveOrd)

Return(cRet)

/*
Função      : CNPJUnidExp
Objetivo    : Retornar o CNPJ da unidade exportadora.
Parametros  : cCodigo  = Codigo do exportador.
              cLoja    = Loja do exportador.
              nUnidExp = 1 = Será retornado o CNPJ da unidade exportadora com base no item do embarque.
                         2 = Será retornado o CNPJ do exportador/fornecedor com base na capa do embarque.
                         3 = Será retornado o CNPJ do representante legal, através do parametro MV_AVG0036.
Retorno     : cCNPJ    = Conteúdo do campo a retornar.
Autor       : Alexsander Martins dos Santos
Data e Hora : 19/05/2005 às 15:00.
Observação  : ER - 01/12/2006 - Essa função foi nopada, passando a ser utilizada a função de mesmo nome acima.
*/
/*
Function CNPJUnidExp(cCodigo, cLoja, nUnidExp)

Local cRet := ""

Default nUnidExp := 2

Begin Sequence

   Do Case

      Case nUnidExp = 1

         If !Empty(cCodigo)
            cRet := BuscaExportador(cCodigo, cLoja, "A2_CGC")
            Break
         EndIf

      Case nUnidExp = 3

         cRet := EasyGParam("MV_AVG0036",, "")
         Break

   End Case

   If Select("TRB") <> 0

      If !Empty(TRB->EEC_EXPORT)
         cRet := BuscaExportador(TRB->EEC_EXPORT, TRB->EEC_EXLOJA, "A2_CGC")
         Break
      EndIf

      If !Empty(TRB->EEC_FORN)
         cRet := BuscaExportador(TRB->EEC_FORN, TRB->EEC_FOLOJA, "A2_CGC")
         Break
      EndIf

   Else

      If !Empty(EEC->EEC_EXPORT)
         cRet := BuscaExportador(EEC->EEC_EXPORT, EEC->EEC_EXLOJA, "A2_CGC")
         Break
      EndIf

      If !Empty(EEC->EEC_FORN)
         cRet := BuscaExportador(EEC->EEC_FORN, EEC->EEC_FOLOJA, "A2_CGC")
         Break
      EndIf

   EndIf

End Sequence

Return(cRet)
*/

/*
Função      : BuscaExportador
Objetivo    : Localizar e retornar o conteúdo com campo passado como parametro na terceira posição.
Parametros  : cCodigo = Codigo do exportador.
              cLoja   = Loja do exportador.
              cCampo  = Nome do campo a retornar o seu conteúdo.
Retorno     : xRet    = Conteúdo do campo a retornar.
Autor       : Alexsander Martins dos Santos
Data e Hora : 19/05/2005 às 15:00.
*/
/*
Function BuscaExportador(cCodigo, cLoja, cCampo)

Local xRet
Local aSaveOrd := SaveOrd("SA2", 1)

Begin Sequence

   SA2->(dbSeek(xFilial()+cCodigo+cLoja),;
         xRet := &(cCampo))

End Sequence

RestOrd(aSaveOrd, .T.)

Return(xRet)  
*/
/*
Funcao      : SI101ProrrogaRE
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Tela de Prorrogação de R.E.
Autor       : Eduardo C. Romanini
Data/Hora   : 12/05/2006 17:00
Revisao     : 
Obs.        :
*/
Function SI101ProrrogaRE()

    Local nOldArea:=Select()
    Local aOrd := SaveOrd({"EY6","EER"})
                                                           
    Private aRotina := MenuDef(ProcName())
    Private cAlias := "EY6" 

    Private cCadastro := "Prorrogação de RE por Consignação"

    Begin Sequence
        
        If !EECFLAGS("CONSIGNACAO")
           MsgInfo("A Rotina de Consignação não está Instalada.","Atenção")
           Break
        EndIf
        
        (cAlias)->(dbSetOrder(1))
        mBrowse(6,1,22,75,cAlias)

    End Sequence
    
    dbSelectArea(nOldArea)
    RestOrd(aOrd)
    
Return NIL


/*
Funcao      : SI101MANRE
Parametros  : cAlias,nReg,nOpc 
Retorno     : lRet
Objetivos   : Tela de Manutenção da Prorrogação de R.E.
Autor       : Eduardo C. Romanini
Data/Hora   : 12/05/2006 17:00
Revisao     : 
Obs.        :
*/
Function SI101ManRE(cAlias,nReg,nOpc)
Local lRet := .T., nInc
Local aButtons := {}, aPos

Local bOk     := {}
Local bCancel := {|| oDlg:End()}

Local aCposEnchoice := {"EY6_RE","EY6_STTDES","EY6_PRAZO","EY6_SLDINI","EY6_SLDATU","EY6_UNIDAD"} // campos que aparecem na enchoice
Local aCamposEdit := {}
Local i, aGrupos := UsrRetGrp(), cGrupo := Upper(AllTrim(EasyGParam("MV_AVG0122",,"XXXXXX")))
Local aAll := AllGroups(), nGroup

Begin Sequence   
   
   If nOpc == 3 //Prorrogar
      
      aCamposEdit := {"EY6_PRAZO"}
      bOk := {|| If(SI101ValidRE(),(SI101GravaRE(),oDlg:End()),)}
   
      If EY6->EY6_STATUS == RE_PR //Prorrogado
         lRet := .F.

         //FSM - 21/12/2010
         If PswID() == '000000'  //Usuário administrador
            lRet := .T.
         Else
            For i := 1 To Len(aGrupos)
                If (nGroup := AScan(aAllGrupo,{|x| AllTrim(x[2]) == AllTrim(aGrupos[i]) })) > 0
                   If Upper(AllTrim(aAllGrupo[nGroup][3])) == cGrupo
                      lRet := .T.
                      Exit
                   EndIf
                EndIf
            Next
         EndIf
         If !lRet
            MsgInfo("O Sistema só efetua a prorrogação para R.E's não prorrogados","Atenção")
            Break
         EndIf
      EndIf
   ElseIf nOpc == VISUALIZAR
      bOk := {||oDlg:End()}
   EndIf

   For nInc := 1 TO EY6->(FCount())
      M->&(EY6->(FIELDNAME(nInc))) := EY6->(FIELDGET(nInc))
   Next nInc
   
   If nOpc == 3 //Prorrogar
      EER->(DbSetOrder(2))
      EER->(DbSeek(xFilial("EER")+EY6->EY6_PREEMB))
      
      nDias := EY6->EY6_PRAZO - EER->EER_DTLANS
     
      M->EY6_PRAZO := EY6->EY6_PRAZO + nDias
   
   EndIf 
   
   DEFINE MSDIALOG oDlg TITLE "Registro de Exportação" FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

    aPos := PosDlg(oDlg)
     
    EnChoice("EY6", ,3, , , ,aCposEnchoice,aPos,aCamposEdit)
     
   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk,bCancel,,aButtons))

End Sequence

Return lRet

/*
Funcao      : SI101ValidRE
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : Valida a Prorrogação de R.E.
Autor       : Eduardo C. Romanini
Data/Hora   : 16/05/2006 14:00
Revisao     : 
Obs.        :
*/
Function SI101ValidRE()

Local lRet := .T.
          
Begin Sequence
   EY6->(DbSetOrder(2))
   EY6->(DbSeek(xFilial("EY6")+M->EY6_RE))
   
   //Validação
   If EY6->EY6_PRAZO >= M->EY6_PRAZO //Nova Data deve ser maior que a Data Anterior
      MsgInfo("O novo prazo deverá ser maior que a validade anterior: " + DtoC(EY6->EY6_PRAZO),"Atenção")
      lRet := .F.
      Break
   EndIf

End Sequence

Return lRet

/*
Funcao      : SI101GravaRE
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : Gravação da Nova Date de Validade do R.E.
Autor       : Eduardo C. Romanini
Data/Hora   : 12/05/2006 17:00
Revisao     : 
Obs.        :
*/
Function SI101GravaRE()

Local lRet := .T.

Begin Sequence
      
   EY6->(DbSetOrder(2))
   EY6->(DbSeek(xFilial("EY6")+M->EY6_RE))
   
   //Gravação   
   If EY6->EY6_PRAZO <> M->EY6_PRAZO

      GravaHistorico(.T.)   

      EY6->(RecLock("EY6",.F.))
      EY6->EY6_PRAZO  := M->EY6_PRAZO
      EY6->EY6_STATUS := RE_PR //Prorrogado
      EY6->(MsUnlock())

   EndIf
   
End Sequence
Return lRet

/*
Função     : GravaHistorico()
Objetivos  : Grava o histórico da prorrogação de RE.
Parâmetros : lProrroga - Verifica se foi chamado na Rotina de Prorrogação de R.E.
Retorno    : Nenhum
Autor      : Eduardo C. Romanini
Data/Hora  : 15/05/2006 às 16:48
*/

Static Function GravaHistorico(lProrroga)
Local mHist := "", aHeader := {}, aDetail := {}, i
Local aAlteraveis := {"EY6_SLDINI","EY6_UNIDAD"}
Local cPict := "", cTit := ""
Local cCampoAlt := "" // SVG  CH: 705251 Dt. 18/07/08

Default lProrroga := .F.
Begin Sequence
   
   // Monta cabeçalho da mensagem
   AAdd(aHeader,{,"C","Campo Alterado"})
   AAdd(aHeader,{,"C","Informação Anterior"})
   AAdd(aHeader,{,"C","Informação Nova"})
   
   If lProrroga
      AAdd(aDetail,{"Data de Validade",EY6->EY6_PRAZO,M->EY6_PRAZO})
   Else
      For i:=1 To WorkRE->(FCount())
         If aScan(aAlteraveis,WorkRE->(FieldName(i))) > 0
            cCampoAlt := WorkRE->(FieldName(i))
            //If WorkRE->&(FieldName(i)) <> EY6->(FieldGet(i+1))  SVG CH: 705251 Dt. 18/07/08
            If WorkRE->&(FieldName(i)) <> EY6->&(cCampoAlt)
               cPict := Posicione("SX3",2,WorkRE->(FieldName(i)),"X3_PICTURE")
               cTit  := Posicione("SX3",2,WorkRE->(FieldName(i)),"X3_TITULO")
               //AAdd(aDetail,{cTit,Transform(EY6->(FieldGet(i+1)),cPict),Transform(WorkRE->&(FieldName(i)),cPict)})SVG CH: 705251 Dt. 18/07/08
               AAdd(aDetail,{cTit,Transform(EY6->&(cCampoAlt),cPict),Transform(WorkRE->&(FieldName(i)),cPict)})
            EndIf
         EndIf
      Next
   EndIf
   
   // se houveram alterações, então grava no campo memo.
   If Len(aDetail) > 0
       mHist := "Data Alter.: " + AllTrim(DToC(dDataBase)) + Space(5) +;         
                "Hora: "        + AllTrim(Time())          + Space(5) +;         
                "Usuário: "     + AllTrim(Substr(cUsuario,7,15)) + Repl(ENTER,2)

      mHist += EECMontaMsg(aHeader,aDetail)

      If lProrroga
         mHist := mHist + Repl(ENTER,2) + MSMM(M->EY6_HIST,TAMMEMO,,,LERMEMO)
      Else
         mHist := mHist + Repl(ENTER,2) + MSMM(WorkRE->EY6_HIST,TAMMEMO,,,LERMEMO)
         MSMM(WorkRE->EY6_HIST,,,,EXCMEMO)
      EndIf
      
      MSMM(,TAMMEMO,,mHist,INCMEMO,,,"EY6","EY6_HIST")
   EndIf
   
End Sequence

Return Nil  

/*
Função       : SI301Hist()
Objetivo     : Mostrar Histórico de Alterações ou retornar histórico já existente
Parâmetros   : lProrroga - Verifica se é chamado da Rotina de Prorrogação de R.E.
Retorno      : Conteúdo do histórico
Autor        : Eduardo Romanini
Data/Hora    : 16/05/06 - 9:30
*/
Function SI101Hist(lProrroga)

Local mHist

If ValType(lProrroga) <> "L"
   lProrroga := .t.
EndIf

Begin Sequence
   
   If lProrroga
      mHist := MSMM(EY6->EY6_HIST,TAMMEMO)
      mHist := "Histórico de Alterações no R.E. nº " + AllTrim(Transform(EY6->EY6_RE,AvSx3("EY6_RE",AV_PICTURE))) + Repl(ENTER,2) +; 
               If(Empty(AllTrim(mHist)),"Não houveram alterações neste R.E..",mHist)
   
   Else
      mHist := MSMM(WorkRE->EY6_HIST,TAMMEMO)
      mHist := "Histórico de Alterações no R.E. nº " + AllTrim(Transform(WorkRE->EY6_RE,AvSx3("EY6_RE",AV_PICTURE))) + Repl(ENTER,2) +; 
               If(Empty(AllTrim(mHist)),"Não houveram alterações neste R.E..",mHist)
   EndIf

   EECView(mHist,"Histórico","Alterações Realizadas")
   
End Sequence

Return mHist

/*
Função       : SI101REManual()
Objetivo     : Browse da Manutenção do Cadastro de R.E. Manual
Parâmetros   : Nenhum
Retorno      : Nil
Autor        : Eduardo C. Romanini
Data/Hora    : 16/05/2006 15:45
*/
Function SI101REManual()

Local nOldArea:=Select()
Local aOrd := SaveOrd({"EY6","EER"})

Private aRotina := MenuDef(ProcName())
   
Private cAlias := "EER" 

Private cCadastro := "Inclusão Manual de RE"

//Filtro no EER
EER->(dbSetFilter({|| EER_MANUAL == "S" }, "EER_MANUAL == 'S'"))

Begin Sequence
    (cAlias)->(dbSetOrder(1))
    mBrowse(6,1,22,75,cAlias)
End Sequence

EER->(DbClearFilter())    
dbSelectArea(nOldArea)
RestOrd(aOrd)

Return Nil

/*
Função       : SI101RE
Objetivo     : Tela de Manutenção do Cadastro de R.E. Manual
Parâmetros   : cAlias,nReg,nOpc
Retorno      : lRet
Autor        : Eduardo C. Romanini
Data/Hora    : 16/05/2006 15:45
*/

Function SI101RE(cAlias,nReg,nOpc)

Local lRet := .T., nInc
Local aButtons := {}, aPos

Local bOk     := {||If(SI101ValRE(nOpc),(nOpcA:=1,oDlg:End()),(WorkRE->(DbGoTop()),oMsSelect:oBrowse:Refresh()))}
Local bCancel := {|| oDlg:End()}

Local aCposEnchoice := {"EER_RE","EER_DTGERS"} // campos que aparecem na enchoice
Local aCamposEdit := {}
Local aCposBrowse := {}
Local aOrd := SaveOrd({"EER","EY6"})
Local nOpcA := 0, cSequencial

Private bTemReg := {|| If(IsVazio("WorkRE"),(HELP(" ",1,"AVG0000632"),.F.),.T.) }
Private aTela[0][0],aGets[0]
Private aDeletados := {}
Private lInclui := If(nOpc==INCLUIR,.T.,.F.)

Begin Sequence   
   
   If nOpc == INCLUIR
      
      //Monta as Variaveis de memória
      For nInc := 1 TO (cAlias)->(FCount())
         M->&((cAlias)->(FIELDNAME(nInc))) := CRIAVAR((cAlias)->(FIELDNAME(nInc)))
      Next
      
      M->EER_DTGERS := Date()

      //Adiciona campo Editavel     
      aAdd(aCamposEdit,"EER_RE")
      aAdd(aCamposEdit,"EER_DTGERS")
   Else
      //Monta as Variaveis de memória
      For nInc := 1 TO (cAlias)->(FCount())
         M->&((cAlias)->(FIELDNAME(nInc))) := (cAlias)->(FieldGet(nInc))
      Next
   EndIf
   
   aWork := CriaWorkItRE(nOpc)

   aCposBrowse := ArrayBrowse("EY6","WorkRE")

   //Adiciona Botões
   If nOpc <> VISUALIZAR .and. nOpc <> EXCLUIR
      aAdd(aButtons,{"BMPINCLUIR" /*"EDIT"*/ ,{|| If(!Empty(M->EER_RE),(SI101DETRE(INC_DET),oMsSelect:oBrowse:Refresh()),;
                                     MsgInfo("O Nº do RE não foi Informado","Atenção"))},"Incluir"})
      aAdd(aButtons,{"EDIT" /*"ALT_CAD"*/    ,{|| If(Eval(bTemReg),(SI101DETRE(ALT_DET),oMsSelect:oBrowse:Refresh()),)},"Alterar"}) 
      aAdd(aButtons,{"EXCLUIR"  ,{|| If(Eval(bTemReg),(SI101DETRE(EXC_DET),oMsSelect:oBrowse:Refresh()),)},"Excluir"}) 
   Else
      aAdd(aButtons,{"BMPVISUAL" /*"ANALITICO"*/,{|| SI101DETRE(VIS_DET)},"Visualizar"}) 
   EndIf

   If nOpc <> INCLUIR
      aAdd(aButtons,{"HISTORIC",{|| SI101Hist(.F.) },"Visualizar"}) 
   EndIf

   DEFINE MSDIALOG oDlg TITLE "R.E. Manual" FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

    aPos    := PosDlgUp(oDlg)
    aPos[3] := aPos[3]/2
     
    EnChoice("EER", ,nOpc, , , ,aCposEnchoice,aPos,aCamposEdit)
    
    aPos := PosDlgDown(oDlg)
    aPos[1] := aPos[1]/2
    
    oMsSelect := MsSelect():New("WorkRE",,,aCposBrowse,,,aPos)  
    oMsSelect:bAval := {|| If((nOpc == INCLUIR .or. nOpc == ALTERAR),(SI101DETRE(ALT_DET,If(nOpc==INCLUIR,.T.,.F.))),SI101DETRE(VIS_DET))}

   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk,bCancel,,aButtons))
    
   If nOpcA == 1 //Botão Ok
      
      If nOpc == INCLUIR .or. nOpc == ALTERAR
         //Atualiza o RE dos Detalhes com o RE da Capa
         AtuREDet()
      EndIf
      
      If nOpc == INCLUIR
         
         cSequencial := SI101SeqRE()           
        
         //Grava Capa
         EER->(RecLock("EER",.T.))
         
         EER->EER_FILIAL := xFilial("EER")  // By JPP - 08/12/2006 - 16:00
         EER->EER_PREEMB := cSequencial
         EER->EER_MANUAL := "S"              
         
         EER->EER_RE     := M->EER_RE
         EER->EER_DTGERS := M->EER_DTGERS
         EER->EER_DTLANS := M->EER_DTGERS
         
         EER->(MsUnlock())
 
         //Grava detalhes
         WorkRE->(DbGoTop())
         
         ProcRegua(WorkRE->(EasyReccount("WorkRE")))
         
         While WorkRE->(!EOF())
            
            EY6->(RecLock("EY6",.T.))
           
            AvReplace("WorkRE","EY6")            
            EY6->EY6_FILIAL := xFilial("EY6") // By JPP - 08/12/2006 - 16:00     
            EY6->EY6_PREEMB := cSequencial
            EY6->EY6_STATUS := RE_NP
            EY6->(MsUnlock())

            IncProc()
         
            WorkRE->(DbSkip())
         EndDo
      
      ElseIf nOpc == ALTERAR
         
         //Apaga o aDeletados
         For nInc:=1 to Len(aDeletados)
            EY6->(DbGoTo(aDeletados[nInc]))
            EY6->(RecLock("EY6",.F.))
            EY6->(DbDelete())
            EY6->(MsUnlock())
         Next
         
         EER->(DbSetOrder(3))
         EER->(DbSeek(xFilial()+M->EER_RE))
         
         cSequencial := EER->EER_PREEMB
 
         WorkRE->(DbGoTop())
         ProcRegua(WorkRE->(EasyReccount("WorkRE")))
         While WorkRE->(!EOF())
            
            If Empty(WorkRE->WK_RECNO)
               EY6->(RecLock("EY6",.T.))
            Else
               EY6->(DbGoTo(WorkRE->WK_RECNO))
               GravaHistorico()            
               EY6->(RecLock("EY6",.F.))
            EndIf
            
            WorkRE->EY6_HIST := EY6->EY6_HIST
            AvReplace("WorkRE","EY6")            
            EY6->EY6_PREEMB := cSequencial
           
            If Empty(Alltrim(EY6->EY6_STATUS))
               EY6->EY6_STATUS := RE_NP //Não Prorrogado
            EndIf
            
            EY6->(MsUnlock("EY6"))            
            
            IncProc() 
            WorkRE->(DbSkip())
         EndDo
         
      ElseIf nOpc == EXCLUIR
         
         //Exclui os Detalhes
         EY6->(DbSetOrder(2))
         If EY6->(DbSeek(xFilial("EY6")+M->EER_RE))
            ProcRegua(WorkRE->(EasyReccount("WorkRE")))
            While EY6->(!EOF()) .and. EY6->(EY6_FILIAL+Left(EY6_RE,9)) == xFilial("EY6")+M->EER_RE 
            
               EY6->(RecLock("EY6",.F.))
               MSMM(EY6->EY6_HIST,,,,EXCMEMO)
               EY6->(DbDelete())
               EY6->(MsUnlock())
               
               IncProc()
               EY6->(DbSkip())
            EndDo
         EndIf
      
         //Exclui a Capa
         EER->(DbSetOrder(3))
         If EER->(DbSeek(xFilial("EER")+M->EER_RE))
      
            EER->(RecLock("EER",.F.))
            EER->(DbDelete())
            EER->(MsUnlock())
      
         EndIf
      EndIf
   EndIf
   
End Sequence
WorkRE->(DbCloseArea())
//WorkRE->(E_EraseArq(aWork))

Return lRet

/*
Função       : CriaWorkItRE
Objetivo     : Criar a Work de Detalhes
Parâmetros   : nOpc
Retorno      : cWork
Autor        : Eduardo C. Romanini
Data/Hora    : 16/05/2006 15:45
*/
Static Function CriaWorkItRE(nOpc)

Local cWork,aCmpWork := {{"WK_RECNO","N",7,0}}
Local aOrd := SaveOrd({"EY6"})

Private aCampos := {}

Begin Sequence
   
   aCampos  := Array(EY6->(FCount()))
   AddNaousado(aCmpWork,"EY6_STATUS")
   AddNaousado(aCmpWork,"EY6_HIST")
   
   //TRP - 02/01/07 - Campos do WalkThru
   AADD(aCmpWork,{"TRB_ALI_WT","C",03,0})
   AADD(aCmpWork,{"TRB_REC_WT","N",10,0}) 
   
   cWork := E_CriaTrab("EY6",aCmpWork,"WorkRE")
  
   If nOpc <> INCLUIR

      //Carrega a Work
      EY6->(DbSetOrder(2))
      If EY6->(DbSeek(xFilial("EY6")+M->EER_RE))

         While EY6->(!EOF()) .and. EY6->(EY6_FILIAL+Left(EY6_RE,9)) == xFilial("EY6")+M->EER_RE
         
            WorkRE->(DbAppend())
            AvReplace("EY6","WorkRE")      
            WorkRE->WK_RECNO := EY6->(Recno())
            WorkRE->TRB_ALI_WT:= "EY6"
            WorkRE->TRB_REC_WT:= EY6->(Recno())
            EY6->(DbSkip())
         EndDo
      EndIf
      WorkRE->(DbGoTop())
   EndIf
   
End Sequence

RestOrd(aOrd)

Return cWork

/*
Função       : SI101DetRE
Objetivo     : Tela de Manutenção de Detalhes do Cadastro de R.E. Manual
Parâmetros   : nDetOpc -> INC_DET,ALT_DET,VIS_DET,EXC_DET
Retorno      : lRet
Autor        : Eduardo C. Romanini
Data/Hora    : 16/05/2006 15:45
*/
Function SI101DetRE(nDetOpc)

Local lRet  := .T.
Local nInc  := 0, aPos := 0
Local nOpcA := 0, nVlOld := 0, nVlAtu := 0, nDiff := 0 
Local aButtons := {}, aCposItEnc := {}, aCamposItEdit := {}
Local bOk     := {||If(SI101ValDetRE(nDetOpc),(nOpcA:=1,oDlg2:End()),Nil)}
Local bCancel := {|| oDlg2:End()}
Local cDetTit := AllTrim(Transf(M->EER_RE,AVSX3("EER_RE",AV_PICTURE)))

Private aTela[0][0],aGets[0]

Begin Sequence
   
   //Atualiza o RE dos Detalhes com o RE da Capa.
   AtuREDet()   
   
   If nDetOpc == ALT_DET .or. nDetOpc == ALT_DET
      If WorkRE->EY6_SLDATU == 0
         Msginfo("O R.E. não possui saldo para alteração.","Atenção")
         nDetOpc := VIS_DET
      EndIf  
   EndIf
      
   //Definição do Título 
   Do Case
      Case nDetOpc == INC_DET 
           cDetTit += " - Incluir"
      Case nDetOpc == ALT_DET 
           cDetTit += " - Alterar"
      Case nDetOpc == EXC_DET 
           cDetTit += " - Excluir"
      Case nDetOpc == VIS_DET 
           cDetTit += " - Vizualizar"
   EndCase
   
   If nDetOpc == INC_DET 
      If Len(AllTrim(M->EER_RE)) <> 9 
         MsgInfo("Número do RE Invalido","Atenção")
         lRet := .F.
         Break
      EndIf

      //Monta as Variaveis de memória
      For nInc := 1 TO EY6->(FCount())
         M->&(EY6->(FIELDNAME(nInc))) := CRIAVAR(EY6->(FIELDNAME(nInc)))
      Next

      M->EY6_RE := AvKey(M->EER_RE,"EY6_RE")

      //Campos que serão alterados
      aAdd(aCamposItEdit,"EY6_RE")
      aAdd(aCamposItEdit,"EY6_SLDINI")
      aAdd(aCamposItEdit,"EY6_PRAZO")
      aAdd(aCamposItEdit,"EY6_UNIDAD")
     
   Else

      //Monta as Variaveis de memória
      For nInc := 1 TO WorkRE->(FCount())
         M->&(WorkRE->(FIELDNAME(nInc))) := WorkRE->(FieldGet(nInc))
      Next
      
      M->EY6_STTDES := CriaVar("EY6_STTDES")
   
   EndIf
   
   //Campos que serão exibidos
   aAdd(aCposItEnc,"EY6_RE")
   aAdd(aCposItEnc,"EY6_SLDINI")
   aAdd(aCposItEnc,"EY6_PRAZO")
   aAdd(aCposItEnc,"EY6_UNIDAD")
   
   If nDetOpc <> INC_DET
      aAdd(aCposItEnc,"EY6_STTDES")
   EndIf
   
   If nDetOpc == ALT_DET
      aAdd(aCamposItEdit,"EY6_SLDINI")
      aAdd(aCamposItEdit,"EY6_UNIDAD")
   EndIf

   DEFINE MSDIALOG oDlg2 TITLE cDetTit FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

      aPos := PosDlg(oDlg2)     
      EnChoice("EY6",,If(nDetOpc=INC_DET,3,4),,,,aCposItEnc,aPos,aCamposItEdit)
    
   ACTIVATE MSDIALOG oDlg2 ON INIT (EnchoiceBar(oDlg2,bOk,bCancel,,aButtons))
   
   If nOpcA == 1 //Botão Ok
      
      If nDetOpc == INC_DET //Inclusão
        
         WorkRE->(DbAppend())
         WorkRE->EY6_RE     := M->EY6_RE
         WorkRE->EY6_PRAZO  := M->EY6_PRAZO   
         WorkRE->EY6_SLDINI := M->EY6_SLDINI
         WorkRE->EY6_SLDATU := M->EY6_SLDINI
         WorkRE->EY6_UNIDAD := M->EY6_UNIDAD
         WorkRE->TRB_ALI_WT := "EY6"
         WorkRE->TRB_REC_WT := EY6->(Recno())
      
      ElseIf nDetOpc == ALT_DET //Alteração

         If !lInclui
            nVlOld := WorkRE->EY6_SLDINI
            nVlAtu := M->EY6_SLDINI
            nDiff  := nVlAtu - nVlOld
            
            If !Empty(nDiff)            
               WorkRE->EY6_SLDINI := nVlAtu
               WorkRE->EY6_SLDATU += nDiff
            EndIf
         Else      
            WorkRE->EY6_SLDINI := M->EY6_SLDINI
            WorkRE->EY6_SLDATU := M->EY6_SLDINI
         EndIf
         
         WorkRE->EY6_UNIDAD := M->EY6_UNIDAD
      
      ElseIf nDetOpc == EXC_DET //Exclusão
         
         //Adiciona no aDeletados
         If !Empty(WorkRE->WK_RECNO)
            aAdd(aDeletados,WorkRE->WK_RECNO)
         EndIf
         
         MSMM(WorkRE->EY6_HIST,,,,EXCMEMO)
         WorkRE->(DbDelete()) // Apaga o registro da work
      
      EndIf
   EndIf

End Sequence

Return lRet

/*
Função       : SI101ValDetRE
Objetivo     : Validação do Botão Ok da Tela de Detalhes
Parâmetros   : nDetOpc
Retorno      : lRet
Autor        : Eduardo C. Romanini
Data/Hora    : 16/05/2006 15:45
*/
Static Function SI101ValDetRE(nDetOpc)
Local lRet := .T.
Local aOrd := SaveOrd({"EY6"})
Local nVlOld := 0, nVlAtu := 0, nVlEstorno := 0

Begin Sequence
   
   If !Obrigatorio(aGets,aTela)
      lRet := .F.
      Break
   EndIf

   If !lInclui
      If nDetOpc == ALT_DET      
         nVlOld := WorkRe->EY6_SLDINI
         nVlAtu := M->EY6_SLDINI

         If nVlAtu < nVlOld
            nVlEstorno := nVlOld - nVlAtu
            If nVlEstorno > WorkRe->EY6_SLDATU
               MsgInfo("Não há saldo suficiente para efetivar a alteração na quantidade.","Atenção")
               lRet := .F.
               Break
            EndIf
         EndIf
      EndIf
   EndIf
   
   If nDetOpc == INC_DET
      If Len(AllTrim(M->EY6_RE)) <> AVSX3("EY6_RE",AV_TAMANHO)
         MsgInfo("R.E. Inválido.","Atenção")    
         lRet := .F.
         Break
       EndIf
   EndIf
   
   If nDetOpc == EXC_DET
      
      If WorkRE->EY6_SLDATU <> WorkRE->EY6_SLDINI
         MsgInfo("A exclusão não poderá ser efetivada visto que este R.E. possui quantidade vinculada a Embarque(s)","Atenção")
         lRet := .F. 
         Break
      EndIf
      
      If !MsgYesNo("Confirma a Exclusão do Item?","Atenção")
         lRet := .F. 
         Break
      EndIf
   EndIf

End Sequence
RestOrd(aOrd)

Return lRet

/*
Função       : SI101ValRE
Objetivo     : Validação do Botão Ok da Tela de Manutenção
Parâmetros   : nOpc
Retorno      : lRet
Autor        : Eduardo C. Romanini
Data/Hora    : 16/05/2006 15:45
*/
Static Function SI101ValRE(nOpc)

Local lRet := .T.

Begin Sequence
   
   If !Obrigatorio(aGets,aTela)
      lRet := .F.
      Break
   EndIf
    
   If !Eval(bTemReg)
      lRet := .F.
      Break
   EndIf
   
   If nOpc == EXCLUIR
      
      WorkRE->(DbGoTop())
      While WorkRE->(!EOF())
         If aScan(aDeletados,WorkRE->WK_RECNO) == 0
            If WorkRE->EY6_SLDATU <> WorkRE->EY6_SLDINI
               MsgInfo("O R.E. não pode ser excluído porque já foi vinculado.","Atenção")
               lRet := .F. 
               Break
            EndIf
         EndIf
         WorkRE->(DbSkip())
      EndDo
      
      If !MsgYesNo("Confirma a Exclusão?","Atenção")
         lRet := .F. 
         Break
      EndIf
   EndIf

End Sequence

Return lRet

/*
Função       : ValCampoRE
Objetivo     : Validação dos Campos
Parâmetros   : cCampo
Retorno      : lRet
Autor        : Eduardo C. Romanini
Data/Hora    : 16/05/2006 15:45
*/
Function SI101CmpValid(cCampo)

Local lRet := .T.

Begin Sequence
   Do Case
      Case cCampo == "EY6_PRAZO"
           
           If Type("M->EER_DTGERS") <> "U"
              If !Empty(M->EY6_PRAZO) .and. M->EY6_PRAZO <= If(Empty(M->EER_DTGERS),Date(),M->EER_DTGERS)
                 MsgInfo("A Data de Validade deve ser maior que a Data de Geração","Atenção")
                 lRet := .F.
                 Break
              EndIf
           EndIf
      Case cCampo == "EY6_RE"
           If Len(AllTrim(M->EY6_RE)) <> AVSX3("EY6_RE",AV_TAMANHO)
              MsgInfo("R.E. Inválido.","Atenção")    
              lRet := .F.
              Break
           EndIf
           
           If Left(M->EY6_RE,9) <> M->EER_RE
              MsgInfo("O RE deve ser o mesmo da Capa - " + Transform(M->EER_RE,AVSX3("EER_RE",AV_PICTURE)),"Atenção")
              lRet := .F.
              Break
           EndIf 
           
           If lInclui
              WorkRE->(DbGoTop())
              While WorkRE->(!EOF())
                 If M->EY6_RE == WorkRE->EY6_RE
                    MsgInfo("Esse R.E. já foi Cadastrado","Atenção")
                    lRet := .F.
                    Break
                 EndIf
                 WorkRE->(DbSkip())
              EndDo
           EndIf
      Case cCampo == "EER_RE" 
           If Len(AllTrim(M->EER_RE)) <> AVSX3("EER_RE",AV_TAMANHO)
              MsgInfo("R.E. Inválido.","Atenção")    
              lRet := .F.
              Break
           EndIf
   End Case

End Sequence
Return lRet

/*
Função       : AtuREDet
Objetivo     : Atualiza o número do R.E. nos Detalhes.
Parâmetros   : Nenhum
Retorno      : Nil
Autor        : Eduardo C. Romanini
Data/Hora    : 16/05/2006 15:45
*/
Function AtuREDet()

Local cREOld
Local nRecOld := WorkRE->(RecNo())

Begin Sequence
   WorkRE->(DbGoTop())
   
   If M->EER_RE == Left(WorkRE->EY6_RE,9)
      Break
   EndIf 

   While WorkRE->(!EOF())
      cREOld := WorkRE->EY6_RE
      WorkRE->EY6_RE := M->EER_RE + Right(cREOld,3)
   
      WorkRE->(DbSkip())
   EndDo
   
End Sequence

WorkRe->(DbGoTo(nRecOld))
Return 

/*
Função       : AtuStatusRE
Objetivo     : Atualiza a Descrição do Status
Parâmetros   : Nenhum - Iniciador do Browse
Retorno      : Nil
Autor        : Eduardo C. Romanini
Data/Hora    : 16/05/2006 15:45
*/
Function AtuStatusRE(lBrowse)

Loca cRet := ""
Begin Sequence
   If lBrowse
      If Select("WorkRE") > 0
         cRet := If(WorkRE->EY6_STATUS=="P","Prorrogado","Não Prorrogado")
      Else
         cRet := If(EY6->EY6_STATUS=="P","Prorrogado","Não Prorrogado")
      EndIf
   Else
      If Select("WorkRE") > 0
         cRet := If(WorkRE->EY6_STATUS=="P","Prorrogado","Não Prorrogado")
      Else
         cRet := If(M->EY6_STATUS=="P","Prorrogado","Não Prorrogado")
      EndIf
   EndIf

End Sequence

Return cRet

/*
Função       : SI101SeqRE
Objetivo     : Gera Numero Sequencial para o Preemb
Parâmetros   : Nenhum
Retorno      : Nil
Autor        : Eduardo C. Romanini
Data/Hora    : 16/05/2006 15:45
*/
Function SI101SeqRE()                          

Local cSequencial := "" 

Begin Sequence
  
  EER->(DbSetOrder(2))
  EER->(DbGoTo(EasyReccount("EER")))
  While Left(EER->EER_PREEMB,1) <> "*" .and. (EER->(!EOF()) .and. EER->(!BOF()))
     EER->(DbSkip(-1))
  EndDo
         
  If EER->(EOF()) .or. EER->(BOF())
     cSequencial := "*" + IncSpace("1",(AVSX3("EER_PREEMB",AV_TAMANHO)-1))
  Else
     cSequencial := "*" + IncSpace(Str(Val(Substr(EER->EER_PREEMB,2))+1),(AVSX3("EER_PREEMB",AV_TAMANHO)-1))
  EndIf

End Sequence

Return cSequencial

/*
Função    : RESchema
Objetivo  : Montar a estrutura de quebra e agrupamento para geração de R.E.
Parametro : cProcesso
Retorno   : aArray[1]
                   +-[1]=CNPJ
                      +-[1]=R.E
                         +-[1]=Sufixo
Autor     : Alexsander Martins dos Santos
Data-Hora : 31/05/2005 - 17:39.
*/

Function RESchema(cProcesso)

Local aRet      := {}
Local aSaveOrd  := SaveOrd("EE9", 3)

Local cCNPJ, nCNPJ
Local cRE, nRE
Local cSufixo, nSufixo
Local cContMark

Begin Sequence
/*   If lItFabric // By JPP - 14/11/2007 - 14:00 
      aItFabric := {}
      SI101MtQbr(cProcesso)
   EndIf*/
    
   EE9->(dbSeek(xFilial()+cProcesso))

   While EE9->(!Eof() .and. EE9_FILIAL == xFilial() .and. EE9_PREEMB == cProcesso)

      //CNPJ.
      cCNPJ := CNPJUnidExp(EE9->EE9_PREEMB, EE9->EE9_SEQEMB)

      If aScan(aRet, {|x| x[1] == cCNPJ}) = 0
         aAdd(aRet, {cCNPJ})
      EndIf

      nCNPJ := aScan(aRet, {|x| x[1] == cCNPJ})

      //R.E.
      If lWizardRE
         cContMark := ContentMark("WorkAgrup", "WK_FLAG", "EXO_RE")

         If Empty(cContMark)
            cRE := EE9->EE9_AGRE
         Else
            cRE := &(cContMark)+EE9->EE9_AGRE
         EndIf
      Else
         cRE := ""
      EndIf

      /*
      Inclusão da quebra de R.E. por ato concessório preenchido/vazio.
      Existindo itens com ato concessório preenchido e outros itens não, deve haver uma quebra de R.E.
      para separalos.
      */
      //cRE := cRE + If(Empty(EE9->EE9_ATOCON), "AV", "AP") //AV = "Ato Vazio", AP = "Ato Preenchido".
      //cRE := cRE + If(Empty(EE9->EE9_ATOCON), "AV", EE9->EE9_ATOCON) //AV = "Ato Vazio", "Numero do Ato Preenchido".
      cRE := cRE + If(Empty(EE9->EE9_ATOCON), "AV", EE9->EE9_ATOCON+EE9->EE9_SEQED3) //AV = "Ato Vazio", "Numero do Ato Preenchido".
      
      If lItFabric // By JPP - 14/11/2007 - 14:00 - Efetua a quebra de RE quando o item de embarque possuir 2 atos concessórios diferentes(itens intermediários) para o mesmo Cnpj.
         nI := Ascan(aItFabric,{|x| x[2] == EE9->EE9_SEQEMB}) 
         If nI > 0
            cRE := cRE + StrZero(aItFabric[nI,4],3)
         EndIf
      EndIf   
         
      If aScan(aRet[nCNPJ], {|x| x[1] == cRE}, 2) = 0
         aAdd(aRet[nCNPJ], {cRE})
      EndIf

      nRE := aScan(aRet[nCNPJ], {|x| x[1] == cRE}, 2)

      //Sufixo.
      If lWizardRE
         cSufixo := EE9->EE9_AGSUFI
      Else
         cSufixo := ""
      EndIf

      If Len(aRet[nCNPJ][nRE]) = 1
         aAdd(aRet[nCNPJ][nRE], {})
      EndIf

      If aScan(aRet[nCNPJ][nRE][2], {|x| x == cSufixo}, 1) = 0
         aAdd(aRet[nCNPJ][nRE][2], cSufixo)
      EndIf

      EE9->(dbSkip())

   End

End Sequence

RestOrd(aSaveOrd)

Return(aRet)

/*
Função    : CNPJUniq
Objetivo  : Montar e retornar um array unificado com os CNPJ's das unid. exportadoras associadas 
            aos itens dos embarques selecionados.
Retorno   : aArray = Array com os CNPJ's unificados dos embarques.
Autor     : Alexsander Martins dos Santos
Data-Hora : 29/06/2005 - 17:49.
*/

Function CNPJUniq()

Local aRet      := {}
Local aSaveOrd  := SaveOrd("EE9", 3)
Local nOldRecno := TRB->(Recno())
Local cCNPJ

Begin Sequence

   TRB->(dbGoTop())

   While TRB->(!Eof())

      If Empty(TRB->WK_FLAG)
         TRB->(dbSkip())
         Loop
      EndIf

      EE9->(dbSeek(xFilial()+TRB->EEC_PREEMB))

      While EE9->(!Eof() .and. EE9_FILIAL == xFilial() .and. EE9_PREEMB == TRB->EEC_PREEMB)

         cCNPJ := CNPJUnidExp(EE9->EE9_PREEMB, EE9->EE9_SEQEMB)

         If aScan(aRet, {|x| x[1] == cCNPJ}) = 0
            aAdd(aRet, {cCNPJ, {}})
         EndIf

         EE9->(dbSkip())

      End

      TRB->(dbSkip())

   End

End Sequence

RestOrd(aSaveOrd)

TRB->(dbGoTo(nOldRecno))

Return(aRet)


/*
Funcao     : MenuDef()
Parametros : cFuncao
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya	
Data/Hora  : 27/01/07 - 17:41
*/
Static Function MenuDef(cOrigem)
Local aRotAdic := {}
Local aRotina := {}
Default cOrigem  := AvMnuFnc()

cOrigem := Upper(AllTrim(cOrigem))

Begin Sequence

   Do Case

      Case cOrigem $ "SI101PRORROGARE"
           Aadd(aRotina, { STR0001   , "AxPesqui"   , 0 , 1 }) //"Pesquisar"
           Aadd(aRotina, { STR0002   , "SI101ManRE" , 0 , 2 }) //"Visualizar"
           Aadd(aRotina, {"Prorrogar", "SI101ManRE" , 0 , 6 }) //"Prorrogar"
           Aadd(aRotina, {"Historico", "SI101Hist"  , 0 , 7 }) //Histórico
         
           If EasyEntryPoint("ESI101PMNU")
	          aRotAdic := ExecBlock("ESI101PMNU",.f.,.f.)
	          If ValType(aRotAdic) == "A"
		         AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	          EndIf
           EndIf
      
       
      Case cOrigem $ "SI101REMANUAL"
           Aadd(aRotina, { STR0001, "AxPesqui", 0 , 1})   //"Pesquisar"
           Aadd(aRotina, { STR0002, "SI101RE" , 0 , 2})   //"Visualizar"
           Aadd(aRotina, { STR0003, "SI101RE" , 0 , 3})   //"Incluir"
           Aadd(aRotina, { STR0004, "SI101RE" , 0 , 4})   //"Alterar"
           Aadd(aRotina, { STR0005, "SI101RE" , 0 , 5,3}) //"Cancelar"
           
           
           If EasyEntryPoint("ESI101MMNU")
	          aRotAdic := ExecBlock("ESI101MMNU",.f.,.f.)
	          If ValType(aRotAdic) == "A"
		         AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	          EndIf
           EndIf        
           
      OtherWise
         aRotina := StaticCall(MATXATU,MENUDEF)     
   End Case

End Sequence   

Return aRotina           
/*
Função     : SI101MtQbr(cProcesso) 
Objetivos  : Montar um Array com a Quebra de RE, de Acordo com o Critério utilizado para
             determinar os REs para os atos concessórios de itens intermediários.
Parâmetros : cProcesso = Numero do processo de embarque.
Retorno    : Nil
Autor      : Julio de Paula Paz
Data/Hora  : 14/11/2007 - 14:00
Revisão    : 
*/
                             
Function SI101MtQbr(cProcesso)
Local aOrd := SaveOrd({"EE9","EYU"}), aItVinc := {}
Local nI, nJ, cCNPJ, cEE9_ATO, cEYU_ATO, nNivel, cCnpj_Pesq, aItensPesq
Begin Sequence
   EYU->(DbSetOrder(1))   
   EE9->(DbSetOrder(3))
   EE9->(DbSeek(xFilial()+cProcesso))
   Do While EE9->(!Eof() .and. EE9_FILIAL == xFilial() .and. EE9_PREEMB == cProcesso)
      EYU->(DbSeek(xFilial()+EE9->(EE9_PREEMB+EE9_SEQEMB)))
      Do While !EYU->(Eof()) .And. EYU->(EYU_PREEMB+EYU_SEQEMB) == EE9->(EE9_PREEMB+EE9_SEQEMB)
         Aadd(aItVinc,{EE9->EE9_PREEMB,;  // 1 - Processo
                       EE9->EE9_SEQEMB,;  // 2 - Sequencia Embarque
                       EE9->EE9_ATOCON,;  // 3 - Ato concessório EE9
                       EYU->EYU_ATOCON,;  // 4 - Ato concessório EYU
                       EYU->EYU_CNPJ,;     // 5 - Cnpj Eyu
                       0})                // 6 - Nível
         EYU->(DbSkip())
      EndDo
      EE9->(DbSkip())
   EndDo                                   
   nNivel := 1
   If Len(aItVinc) > 0
      aItVinc[1,6] := nNivel  
   EndIf                                   
   For nI := 1 To Len(aItVinc)
       cEE9_ATO := aItVinc[nI,3]  
       cEYU_ATO := aItVinc[nI,4]  
       cCNPJ    := aItVinc[nI,5]
       For nJ := 1 To Len(aItVinc)
           If aItVinc[nJ,6] <> 0 // Nivel
              Loop
           EndIf
           aItensPesq := aClone(aItVinc)
          If cEE9_ATO == aItVinc[nJ,3] .And. (cEYU_ATO == aItVinc[nJ,4] .And. cCNPJ == aItVinc[nJ,5]) 
             aItVinc[nJ,6] := nNivel
          ElseIf cEE9_ATO == aItVinc[nJ,3] .And. (cEYU_ATO == aItVinc[nJ,4] .And. cCNPJ <> aItVinc[nJ,5]) 
             aItVinc[nJ,6] := nNivel
          ElseIf cEE9_ATO == aItVinc[nJ,3] .And. (cEYU_ATO <> aItVinc[nJ,4] .And. cCNPJ <> aItVinc[nJ,5])
             cCnpj_Pesq := aItVinc[nJ,5]
             If Ascan(aItensPesq,{|x| x[6] == nNivel .And. x[5] ==cCnpj_Pesq}) = 0 
                aItVinc[nJ,6] := nNivel
             EndIf
          EndIf

       Next
       nNivel += 1
   Next                       
   For nI := 1 To Len(aItVinc) // Agrupa os registro que não possuem Fabricantes/Itens intermediários no primeiro nível da quebra por RE.
       If aItVinc[nI,6] == 0
          aItVinc[nI,6] := 1
       EndIf 
   Next
   For nI := 1 To Len(aItVinc)  // Passa para o array aItFabric o nível da quebra Correspondente a item do EE9.
       If Ascan(aItFabric,{|x| x[1] == aItVinc[nI,2]}) = 0 
          Aadd(aItFabric,{aItVinc[nI,1],aItVinc[nI,2],aItVinc[nI,3],aItVinc[nI,6]})
       EndIf
   Next
End Sequence
RestOrd(aOrd)      
Return Nil            
/*
Função     : SI101MtAtos(nVlFob) 
Objetivos  : Montar um Array com os dados dos Atos Concessórios dos Itens a serem incluidos
             no TXT de Envio ao Siscomex.
Parâmetros : nVlFob = Valor Fob do Item
Retorno    : nPos = posição do CGC do Ato Concessório do Item.
Autor      : Julio de Paula Paz
Data/Hora  : 14/11/2007 - 14:00
Revisão    : 
*/
                             
Function SI101MtAtos(nVlFob)
Local aAtosItem := {}, nRet, nI, nPos, cCgc, cNbm, cDestaque, nQtdDet, cUmTon, nQtdOld, nValOld
Local cTipoCGC, nPosIt
Local nEE9Taxa, nItTaxa, nValor
                    
Begin Sequence
   nPos := 0 
   nPosIt := 0
   IF Empty(Work->WK_UF1) .Or. Work->WK_UF1 == cUFATU
      For nI := 1 To 10
          cCgc := Work->(FieldGet(FieldPos("WK_CGC"+Ltrim(Str(nI)))))
          cNbm := Work->(FieldGet(FieldPos("WK_NBM"+Ltrim(Str(nI)))))     
          cTipoCgc := Work->(FieldGet(FieldPos("WK_TPCGC"+Ltrim(Str(nI)))))     
          
          //cDestaque := Left(EE9->EE9_POSIPI,8)+"00"       
          SYD->(DBSetOrder(1))
          If SYD->(DBSeek(xFilial("SYD")+EE9->EE9_POSIPI))
             If !EMPTY(SYD->YD_SISCEXP)
                cDestaque := Left(EE9->EE9_POSIPI,8) + SYD->YD_SISCEXP
             Else
                cDestaque := Left(EE9->EE9_POSIPI,8) + "00"
             EndIf
          EndIf
                  
          If EE9->(FieldPos("EE9_DTQNCM")) > 0                           
             cDestaque := Left(EE9->EE9_POSIPI,8)+If(!Empty(EE9->EE9_DTQNCM),EE9->EE9_DTQNCM,"00")
          EndIf
                                  
          //If AllTrim(SA2->A2_CGC)+cDestaque == cCgc+cNbm .And. cTipoCgc == "ITEM"
          //   nPosIt := nI
          //EndIf
          If Empty(cCgc) 
             nPos := nI
             Exit
          EndIf
      Next

      IF nPos > 0 .And. nPos <= 10
         //cDestaque := Left(EE9->EE9_POSIPI,8)+"00"       
         SYD->(DBSetOrder(1))
         If SYD->(DBSeek(xFilial("SYD")+EE9->EE9_POSIPI))
            If !EMPTY(SYD->YD_SISCEXP)
               cDestaque := Left(EE9->EE9_POSIPI,8) + SYD->YD_SISCEXP
            Else
               cDestaque := Left(EE9->EE9_POSIPI,8) + "00"
            EndIf
         EndIf
  
         If EE9->(FieldPos("EE9_DTQNCM")) > 0                
            cDestaque := Left(EE9->EE9_POSIPI,8) + If(!Empty(EE9->EE9_DTQNCM),EE9->EE9_DTQNCM,"00")
         EndIf 
                  
         nQtdDet := EE9->EE9_SLDINI

         If Select("SJ5") > 0 // Verifica se o cliente esta usando o cadastro de conversao ...
            If !EasyGParam("MV_AVG0127",,.F.)   // Em clientes como a DEICMAR, este valor não pode ser convertido para unidade da NCM.
               nQtdDet  := AvTransUnid(EE9->EE9_UNIDAD,cUMCONV,EE9->EE9_COD_I,EE9->EE9_SLDINI,.F.) // Qtde Uni Mercadoria
            EndIf
                  
            If lField_RV .And. !Empty(Work->EE9_RV)
               nQtdDet := EE9->EE9_PSLQTO

               If EE9->(FieldPos("EE9_UNPES")) > 0 .And. !Empty(EE9->EE9_UNPES)
                  cUmTon := ALLTRIM(EasyGParam("MV_AVG0030",,""))
                  cUmTon := IF(cUmTon=".","",cUmTon)
                  cUmTon := AvKey(cUmTon,"AH_UNIMED")

                  If Empty(cUmTon)
                     MsgInfo("Problema: O parametro MV_AVG0030 não foi encontrado !"+CRLF+"Solução: Cadastre o parametro no módulo Configurador, MV_AVG0030 - Tipo: Caracter - Descrição: Código da U.M. Tonelada - Conteúdo: ??","Aviso") 
                  Else
                     nQtdDet := Round(AVTRANSUNI(WORK->EE9_UNPES,cUmTon,,nQtdDet,.F.),3) // Qtde Uni Comercializada
                  EndIf
               Else                        
                  // Padrão do Easy é KG
                  nQtdDet := Round(nQtdDet/1000,3) // Qtde Uni Comercializada
               EndIf
            EndIf
         EndIf                                                        
         If nPosIt > 0
            nQtdOld := Work->(FieldGet(FieldPos("WK_QTD"+Ltrim(Str(nPosIt)))))
            nValOld := Work->(FieldGet(FieldPos("WK_VAL"+Ltrim(Str(nPosIt)))))
         EndIf

                  
         Aadd(aAtosItem,{SI100CNPJ(SA2->A2_COD+SA2->A2_LOJA),; // 1 - WK_CGC
                         cDestaque,; // 2 - WK_NBM
                         SA2->A2_EST,; // 3 - WK_UF
                         EE9->EE9_ATOCON,; // 4 - WK_ATO
                         nQtdDet,; // 5 - WK_QTD
                         nVlFob+nSemCobCamb,; // 6 - WK_VAL 
                         "I",;    // 7 - Tipo de Registro = "I" = Item
                         0}) // 8 - Recno                        
                                  
         EYU->(DbSeek(xFilial("EYU")+EE9->(EE9_PREEMB+EE9_SEQEMB)))
         Do While !EYU->(Eof()) .And. EYU->(EYU_FILIAL+EYU_PREEMB+EYU_SEQEMB) == ;
                                      xFilial("EYU")+EE9->(EE9_PREEMB+EE9_SEQEMB)
            nEE9Taxa := BuscaTaxa(EEC->EEC_MOEDA,EYU->EYU_DTNF,,.f.)
            nItTaxa := BuscaTaxa(EYU->EYU_MOEDA,EYU->EYU_DTNF,,.f.)
            If EYU->EYU_MOEDA <> EEC->EEC_MOEDA
               nValor := EYU->EYU_VALOR * nItTaxa
               nValor := nValor / nEE9Taxa
            Else
               nValor := EYU->EYU_VALOR
            EndIf                           
            If Ascan(aAtosLidos,EYU->(Recno())) == 0                                  
               Aadd(aAtosItem,{EYU->EYU_CNPJ,; // 1 - WK_CGC
                               EYU->EYU_POSIPI,; // 2 - WK_NBM
                               EYU->EYU_UF,; // 3 - WK_UF
                               EYU->EYU_ATOCON,; // 4 - WK_ATO
                               EYU->EYU_QTD,; // 5 - WK_QTD
                               nValor+nSemCobCamb,; // 6 - WK_VAL 
                               EYU->EYU_TIPO,;    // 7 - Tipo de Registro = "1" - Empresa Industrial - "2" - Fabricantes Intermediários
                               EYU->(Recno())}) // 8 - Recno                                                  
            EndIf
                    
            EYU->(DbSkip())                          
         EndDo 
         //If Ascan(aAtosLidos,{|x| x[7] == "1"}) > 0 .And. ;
         //   Ascan(aAtosItem,{|x| x[7] == "1"}) // Já existe Tipo 1 processado
         //   nRet := 11
         //   Break
         //Else 
         //   For nI := 1 To Len(aAtosItem)
         //       Aadd(aAtosLidos,aAtosItem[nI])
         //   Next
         //EndIf 
                 
         nValTp_1 := 0
         nValTp_2 := 0
         If Len(aAtosItem) > 1
            For nI := 2 To Len(aAtosItem)
                If nI + nPos > 10
                   Exit
                EndIf 
                If aAtosItem[nI,7] == "1"
                   nValTp_1 += aAtosItem[nI,6] // Valor
                Else
                   nValTp_2 += aAtosItem[nI,6] // Valor                        
                EndIf
            Next  
            If nValTp_1 > 0
               aAtosItem[1,6] -= nValTp_1
            Else
               aAtosItem[1,6] -= nValTp_2
            EndIf
         Else
            If aAtosItem[1,7] == "I" .And. (nPos + 1) == 10
               nPos := 11
            EndIf
         EndIf
         For nI := 1 To Len(aAtosItem)
             Work->(FieldPut(FieldPos("WK_CGC"+Ltrim(Str(nPos))),aAtosItem[nI,1]))
             Work->(FieldPut(FieldPos("WK_NBM"+Ltrim(Str(nPos))),aAtosItem[nI,2]))
             Work->(FieldPut(FieldPos("WK_UF" +Ltrim(Str(nPos))),aAtosItem[nI,3]))
             Work->(FieldPut(FieldPos("WK_ATO"+Ltrim(Str(nPos))),aAtosItem[nI,4]))
             Work->(FieldPut(FieldPos("WK_QTD"+Ltrim(Str(nPos))),aAtosItem[nI,5]))
             Work->(FieldPut(FieldPos("WK_VAL"+Ltrim(Str(nPos))),aAtosItem[nI,6]))                                       
             If aAtosItem[nI,1] <> "I"
                Aadd(aAtosLidos,aAtosItem[nI,8])
             EndIf  
             nPos += 1
             If nPos > 10
                Exit
             EndIf
         Next
         nRet := nPos
      EndIf
   EndIf
   
End Sequence

Return nRet

Static Function PossuiItemSemRe()
Local lRet := .F.

	BeginSql Alias "QRYEE9"
		Select
			Count(*) As QTD
		From
			%table:EE9% EE9
		Where
			EE9_FILIAL = %XFilial:EE9%
			And EE9_PREEMB = %exp:TRB->EEC_PREEMB%
			And EE9_RE = ' '
			And EE9_ID = ' '
			AND %NotDel%
	EndSql
	
	If !QRYEE9->(Eof() .And. Bof()) .And. QRYEE9->QTD > 0
		lRet := .T.
	EndIf
	
	QRYEE9->(DbCloseArea())

Return lRet
 
*--------------------------------------------------------------------------*
* FIM DO PROGRAMA EECSI101.PRW                                             *
*--------------------------------------------------------------------------*
