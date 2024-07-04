#Include "EECSI401.ch"
#Include "AVERAGE.CH"
#Include "FileIO.ch"

/*******************************
Status:
0. selecion�vel; j� traz marcado (todos os itens se enquadram aos par�metros)
1. selecion�vel, por�m exibe o campo observa��o e solicita a confirma��o do usu�rio
   (nem todos os itens se enquadram aos par�metos por�m n�o h� pend�ncias)
2. n�o selecion�vel, processo com pend�ncias/ irregularidades
3. processo concluido
9. processo n�o encontrado na tabela correspondente ou n�o se enquadra aos par�metros
*************************************************************************************/
#Define ST_OK 0
#Define ST_PROCESSAVEL 1
#Define ST_IRREGULAR 2
#Define ST_CONCLUIDO 3
#Define ST_ND 9
/*
Programa : EECSI401
Objetivo : Realizar o retorno do n�mero e a data da DDE, a partir do n�mero da RE.
Autor    : Wilsimar Fabr�cio da Silva
Data/Hora: Junho/ 2009
Obs.     : Usa a vari�vel private cPathTXT
*/
Function EECSI401()
Local cArqProc:= "",;
      cMsg:= "",;
      cPathCmd:= ""
Local aCMD:= {{"avgrde.bat", "avgiww.exe", "avgrde.cmd", "killtask.exe"},;
              {"avgrde.bat", "avgpack.exe", "avgrde.cmd", "killtask.exe"}}
Local nCont,;
      nTerminal:= EasyGParam("MV_AVG0091",, 0) //Par�metro que define qual o terminal do siscomex o cliente usa (1=IWW/ 2=Packet)
Private cPathTxt:= AllTrim(EasyGParam("MV_AVG0002")) //Diret�rio para grava��o dos arquivos TXT
Private cPrograma:= ""
Private lInverte:= .F.
Private cMarca:= GetMark()
Begin Sequence

   //Verifica��o da exist�ncia do diret�rio para a grava��o dos arquivos TXT
   If Right(cPathTxt, 1) != "\"
      cPathTxt += "\"
   EndIf   
   If !lIsDir(cPathTxt)
      MsgInfo(STR0001 + cPathOr, STR0002) //Diret�rio para gravacao do txt n�o existe: ###, Aviso
      Break
   EndIf
   
   //Verifica��o do terminal do Siscomex
   If nTerminal == 0
      MsgInfo(STR0030, STR0002) //A integra��o n�o pode prosseguir pois o terminal do Siscomex n�o foi definido. Edite o par�metro MV_AVG0091 e reinicie o processo., Aviso
      Break
   EndIf
   
   //Vefirica��o da exist�ncia dos programas necess�rios para a integra��o.
   //Diret�rio onde encontram-se os arquivos CMD de integra��o.
   cPathCmd:= AllTrim(SubStr(cPathTxt, 1, At("ORISISC", cPathTxt) - 1))
   For nCont:= 1 To Len(aCMD[nTerminal])
      If !File(cPathCmd + aCMD[nTerminal][nCont])
         cMsg += aCMD[nTerminal][nCont] + ENTER
      EndIf
   Next   
   If !Empty(cMsg)
      MsgInfo(STR0031 + ENTER + cMsg, STR0002) //Os arquivos necess�rios para a integra��o n�o foram encontrados. ### , Aviso
      Break
   Else
      //Programa que ser� chamado pelo Easy para a integra��o com o Siscomex. Caminho completo.
      cPrograma:= cPathCmd + aCMD[nTerminal][1]
   EndIf
   
   //Cria��o de Works
   SI401GeraWorks(@cArqProc)

   //Tela para a escolha dos processos
   SI401Main("WkProc")

   //Apagando as Works criadas
   WKProc->(E_EraseArq(cArqProc))
End Sequence
Return

/*
Programa : SI401GeraWorks
Objetivo : Gerar as works que possibilitar� ao usu�rio escolher os processos para a realiza��o do retorno
           do n�mero da DDE no Siscomex.
Autor    : Wilsimar Fabr�cio da Silva
Data/Hora: Junho/ 2009
Obs.     : 
*/
Static Function SI401GeraWorks(cArqProc)
Local aCampos:= {}

aCampos:= EEC->(DBStruct())
AAdd(aCampos, {"WK_FLAG"  , "C",   2, 0})
AAdd(aCampos, {"WK_OBS"   , "M", 200, 0})
AAdd(aCampos, {"WK_STATUS", "N",   1, 0})

//Work referente a capa. Gravar� os processos selecionados pelo usu�rio e que possibilitar� ao usu�rio selecionar
//os processos que deseja realizar o retorno da DDE no Siscomex.

cArqProc:= E_CriaTrab(, aCampos, "WKProc");

IndRegua("WKProc", cArqProc + TEOrdBagExt(), "EEC_PREEMB")

Return

/*
Programa  : SI401Main
Objetivo  : Criar a tela para a escolha dos processos.
Par�metros: cAlias
Autor     : Wilsimar Fabr�cio da Silva
Data/Hora : Junho/ 2009
Obs.      : 
*/

Static Function SI401Main(cAlias)
Local aPos:= {},;
      aCampos:= {},;
      aButtons:= {}
Local bOk:= {|| oProcess:= MsNewProcess():New({|| SI401Siscomex(cAlias, oProcess)}, STR0025, STR0026, .F.), oProcess:Activate(), oDlg:End()},; //Retorno de DDE , Gerando arquivos para a integra��o
      bCancel:= {|| oDlg:End()},;
      bStatus0:= {|| If (Empty((cAlias)->WK_FLAG), (cAlias)->WK_FLAG:= cMarca, (cAlias)->WK_FLAG:= Space(2))},;
      bStatus1:= {|| SI401ConfSel(cAlias)},;
      bStatus2:= {|| EECView({{(cAlias)->WK_OBS, .T.}}, STR0002)} //Aviso
Local oDlg,;
      oMark,;
      oProcess

//Inclui os bot�es na EnchoiceBar
AAdd(aButtons, {"PMSCOLOR", {|| SI401Legenda()}, STR0044})// Legenda
AAdd(aButtons, {"LBTIK", {|| SI401AltStatus(cAlias), SI401MarkAll(cAlias), oMark:oBrowse:Refresh()}, STR0007})// Marcar/ desmarcar itens
AAdd(aButtons, {"NOVACELULA", {|| SI401SelProc(cAlias), oMark:oBrowse:Refresh()}, STR0003})// Inclui Processo
AAdd(aButtons, {"EXCLUIR", {|| SI401DelProc(cAlias)}, STR0004})// Exclui Processo
//Campos que ser�o visualizados no Browse
//             Campo          T�tulo                          Picture
AAdd(aCampos, {"WK_FLAG"   ,, " "                           ,                                })
AAdd(aCampos, {"EEC_FILIAL",, AvSx3("EEC_FILIAL", AV_TITULO), AvSX3("EEC_FILIAL", AV_PICTURE)})
AAdd(aCampos, {"EEC_PREEMB",, AvSx3("EEC_PREEMB", AV_TITULO), AvSX3("EEC_PREEMB", AV_PICTURE)})
AAdd(aCampos, {"EEC_DTPROC",, AvSx3("EEC_DTPROC", AV_TITULO), AvSX3("EEC_DTPROC", AV_PICTURE)})
AAdd(aCampos, {"WK_OBS"    ,, STR0008                       ,                                }) //Observa��es

Begin Sequence

   Define MsDialog oDlg Title STR0005 From DLG_LIN_INI,DLG_COL_INI To DLG_LIN_FIM,DLG_COL_FIM Of oMainWnd Pixel //"Retorno de DDE"

      aPos:= PosDlg(oDlg)
      aPos[1]:= 15
            
      oMark:= MsSelect():New(cAlias, "WK_FLAG", "WK_STATUS", aCampos, @lInverte, @cMarca, aPos)
      oMark:bAval:= {|| If ((cAlias)->WK_STATUS == ST_PROCESSAVEL, Eval(bStatus1),;
                            If ((cAlias)->WK_STATUS == ST_IRREGULAR .Or. (cAlias)->WK_STATUS == ST_CONCLUIDO,;
                            Eval(bStatus2), Eval(bStatus0)))}

      oMark:oBrowse:aColumns[1]:bData:= {|| If ((cAlias)->WK_STATUS == ST_OK, "BR_VERDE",;
                                            If ((cAlias)->WK_STATUS == ST_PROCESSAVEL, "BR_AMARELO",;
                                            If ((cAlias)->WK_STATUS == ST_IRREGULAR, "BR_VERMELHO", "BR_AZUL")))}
      oMark:oBrowse:Refresh()
   Activate MsDialog oDlg Centered On Init EnchoiceBar(oDlg, bOk, bCancel,,aButtons)

End Sequence

Return

/*
Programa  : SI401SelProc()
Objetivo  : Processar os par�metros e os filtros e carregar a Work com os processos.
Par�metros: cAlias
Autor     : Wilsimar Fabr�cio da Silva
Data/Hora : Junho/ 2009
Obs.      : 
*/

Static Function SI401SelProc(cAlias)
Local aOrd:= SaveOrd({"EEC", "EEM", "EEX"})
Local bOk:= {|| oDlg:End()},;
      bCancel:= {|| oDlg:End()}
Local cProcesso:= Space(AvSx3("EEC_PREEMB", AV_TAMANHO)),;
      cProcIni:= "",;
      cProcFin:= "",;
      cDtEmbIni:= "",;
      cDtEmbFin:= "",;
      cNotaIni:= "",;
      cNotaFin:= "",;
      cDtNfIni:= "",;
      cDtNfFin:= "",;
      cReIni:= "",;
      cReFin:= "",;
      cDtReIn:= "",;
      cDtReFin:= "",;
      cObs:= ""

Local nOldArea:= Select(),;
      nStatus,;
      nStatusAux
Local oDlg

EEC->(DBSetOrder(1)) //EEC_FILIAL + EEC_PREEMB
Begin Sequence

   If !Pergunte("SI401A", .T.)
      Break
   EndIf
   
   (cAlias)->(avzap())

   //Coletando par�metros vindos do pergunte
   cProcIni:= MV_Par01
   cProcFin:= MV_Par02
   cDtEmbIni:= DtoS(MV_Par03)
   cDtEmbFin:= DtoS(MV_Par04)
   cNotaIni:= MV_Par05
   cNotaFin:= MV_Par06
   cDtNfIni:= DtoS(MV_Par07)
   cDtNfFin:= DtoS(MV_Par08)
   cReIni:= MV_Par09
   cReFin:= MV_Par10
   cDtReIni:= DtoS(MV_Par11)
   cDtReFin:= DtoS(MV_Par12)
   
   //Tratamentos para os par�metros coletados
   //Embarque
   If Empty(cProcFin)
      cProcFin:= Replicate("Z", AvSx3("EEC_PREEMB", AV_TAMANHO)) //�ltimo processo
   EndIf   
   //Data do embarque
   If Empty(cDtEmbIni)
      cDtEmbIni:= ("00000000") //Data do primeiro processo
   EndIf
   If Empty(cDtEmbFin)
      cDtEmbFin:= DtoS(Date()) //Data atual
   EndIf
   //Nota Fiscal
   If Empty(cNotaFin)
      cNotaFin:= Replicate("Z", AvSx3("EEM_NRNF", AV_TAMANHO)) //�ltima Nota
   EndIf
   //Data da nota fiscal
   If Empty(cDtNfIni)
      cDtNfIni:= ("00000000") //Data do primeiro processo
   EndIf
   If Empty(cDtNfFin)
      cDtNfFin:= DtoS(Date()) //Data atual
   EndIf
   //Numero do RE
   If Empty(cReIni)
      cReIni:= Replicate("0", AvSx3("EE9_RE", AV_TAMANHO)) //Primeiro RE
   EndIf
   If Empty(cReFin)
      cReFin:= Replicate("9", AvSx3("EE9_RE", AV_TAMANHO)) //�ltimo RE
   EndIf
   If Empty(cDtReIni)
      cDtReIni:= ("00000000") //Data do primeiro RE
   EndIf
   If Empty(cDtReFin)
      cDtReFin:= DtoS(Date()) //Data atual
   EndIf   
   
   //Gravando na Work os processos que se enquadram nos par�metros definidos
   EEC->(DBSetOrder(1)) //EEC_Filial + EEC_PREEMB
   If !EEC->(DBSeek(xFilial() + AvKey(cProcIni, "EEC_PREEMB")))
      DBSelectArea("EEC")
      Set Filter To EEC_FILIAL == EEC->(xFilial())
      EEC->(DBGoTop())
      Set Filter To
   EndIf
   While !EEC->(EOF()) .And. EEC->(EEC_FILIAL + EEC_PREEMB) <= (xFilial("EEC") + cProcFin)
      nStatus:= ST_OK //inicia sempre como selecion�vel
      cObs:= ""
      //Se a data do processo est� fora do par�metro
      If DtoS(EEC->EEC_DTPROC) < cDtEmbIni .Or.;
         DtoS(EEC->EEC_DTPROC) > cDtEmbFin
         
         EEC->(DBSkip())
         Loop
      EndIf
      //Se o processo possui DDE relacionda, grava a informa��o na observa��o e define o status
      //como concluido e n�o alter�vel
      EEX->(DBSetOrder(1)) //EEX_FILIAL + EEX_PREEMB
      If EEX->(DBSeek(xFilial() + AvKey(EEC->EEC_PREEMB, "EEX_PREEMB"))) .And.;
         !Empty(AllTrim(EEX->EEX_NUM))
         
         nStatus:= ST_CONCLUIDO
         cObs:= AllTrim(EEX->EEX_NUM) + ENTER
      EndIf
      
      //Verificando as notas fiscais...
      nStatusAux:= SI401NF(EEC->EEC_PREEMB, cNotaIni, cNotaFin, cDtNfIni, cDtNfFin, @cObs)
      //Se retornou 9 o sistema considerar� que o processo n�o se enquadra aos par�metros e n�o ser� exibido.
      If nStatusAux == ST_ND
         EEC->(DBSkip())
         Loop
      EndIf
      //Se o status retornado � maior que o anterior, o processo se aproxima de um n�vel que
      //n�o poder� ser integrado.
      If nStatusAux > nStatus
         nStatus:= nStatusAux
      EndIf

      //Se os itens n�o possuem RE, lista o processo, grava a informa��o na observa��o e o status com 2.
      //Se a RE est� fora do par�metro especificado pelo cliente ou se o processo possui a RE especificada
      //pelo cliente por�m existem mais itens com RE, grava na observa��o todos os itens, grava o status
      //como 1, exibe a mensagem e solicita a confirma��o quando o usu�rio tentar selecionar o item.
      nStatusAux:= SI401RE(EEC->EEC_PREEMB, cReIni, cReFin, cDtReIni, cDtReFin, @cObs)
        
      //Se retornou 9, o processo n�o se enquadra aos par�metros e n�o ser� exibido.
      If nStatusAux == ST_ND
         EEC->(DBSkip())
         Loop
      EndIf
      //Se o status retornado � maior que o anterior, o processo se aproxima de um n�vel que
      //n�o poder� ser integrado.
      If nStatusAux > nStatus
         nStatus:= nStatusAux
      EndIf
      
      If !Empty(cObs)
         Do Case
            Case nStatus == ST_PROCESSAVEL
               cObs:= STR0018 + ENTER + cObs //O processo possui dados que n�o se enquadram aos par�metros.
            Case nStatus == ST_IRREGULAR
               cObs:= STR0019 + ENTER + cObs //Exite(m) pend�ncia(s) no processo.
            Case nStatus == ST_CONCLUIDO
               cObs:= STR0009 + ENTER + cObs //Este processo j� possui DDE vinculada.
         EndCase
      EndIf
      (cAlias)->(DBAppend())
      AVReplace("EEC", cAlias)
      If nStatus == ST_OK
         (cAlias)->WK_FLAG:= cMarca
      EndIf
      (cAlias)->WK_STATUS:= nStatus
      (cAlias)->WK_OBS:= cObs
      EEC->(DBSkip())      
   End
   (cAlias)->(DBGoTop())
End Sequence

RestOrd(aOrd)
DBSelectArea(nOldArea)
Return

/*

Programa  : SI401RE()
Objetivo  : Verificar se o itens do processo de embarque possuem RE. A fun��o grava a observa��o do
            item, caso este n�o se enquadre aos par�metros definidos pelo usu�rio.
Par�metros: cPreemb, cReIni, cReFin, cDtReIni, cDtReFin, @cObs
Retorno   : nStatus
Autor     : Wilsimar Fabr�cio da Silva
Data/Hora : Junho/ 2009
Obs.      : 
*/

Static Function SI401RE(cPreemb, cReIni, cReFin, cDtReIni, cDtReFin, cObs)
Local aOrd:= SaveOrd("EE9"),;
      aRE:= {}
Local cObsAux:= ""
Local lRE:= .T.
Local nCont:= 0,;
      nStatus:= ST_OK //inicia como selecion�vel
      
Begin Sequence

   EE9->(DBSetOrder(3)) //EE9_FILIAL + EE9_PREEMB + EE9_SEQEMB
   If EE9->(DBSeek(xFilial() + AvKey(cPreemb, "EE9_PREEMB")))
      //Verifica se todos os itens possuem RE. Grava no campo observa��o os itens que n�o possuem e
      //grava o status com 2.
      While !EE9->(EOF()) .And. (AllTrim(cPreemb) == AllTrim(EE9->EE9_PREEMB))
         If Empty(EE9->EE9_RE)
            lRE:= .F.
            nStatus:= ST_IRREGULAR
            cObsAux += STR0010 + AllTrim(EE9->EE9_SEQEMB) + STR0011 + ENTER //O item #### n�o possui RE.
         EndIf
         AAdd(aRE, {EE9->EE9_RE, EE9->EE9_DTRE, EE9->EE9_SEQEMB})
         EE9->(DBSkip())
      End
      //Se todos os itens possuem RE, verifica se h� ao menos um que se enquadra nos par�metros
      //escolhidos pelo usu�rio.
      If lRE == .T.
         lRE:= .F.
         For nCont:= 1 To Len(aRE)
            If AllTrim(aRE[nCont][1]) < AllTrim(cReIni) .Or.;
               AllTrim(aRE[nCont][1]) > AllTrim(cReFin) .Or.;
               AllTrim(DtoS(aRE[nCont][2])) < AllTrim(cDtReIni) .Or.;
               AllTrim(DtoS(aRE[nCont][2])) > AllTrim(cDtReFin)

               cObsAux += STR0010 + AllTrim(aRE[nCont][3]) + STR0012;
                               + Transform(AllTrim(aRE[nCont][1]), AvSx3("EE9_RE", AV_PICTURE));
                               + STR0013 + ENTER //O item ###, RE ###, n�o se enquadra aos par�metros definidos.
               nStatus:= ST_PROCESSAVEL
            Else
               lRE:= .T.
            EndIf
         Next
      EndIf
      //Se retornou verdadeiro por�m h� observa��o � porque existem mais itens no processo al�m do
      //definido pelo usu�rio no par�metro. Ao tentar selecionar o processo, o sistema exibir� a
      //observa��o e solicitar� a confirma��o do usu�rio.
      If lRE == .T. .And. !Empty(cObsAux)
         cObsAux:= STR0017 + ENTER + cObsAux //Al�m da RE informada, o processo possui outros itens com RE
      EndIf
   Else
      //O processo n�o pertence a filial ativa.
      nStatus:= ST_ND
   EndIf
cObs += cObsAux   
End Sequence

RestOrd(aOrd)
Return nStatus

/*
Programa  : SI401MarkAll()
Objetivo  : Marcar/ desmarcar os itens da Work
Par�metros: cAlias
Autor     : Wilsimar Fabr�cio da Silva
Data/Hora : Junho/ 2009
Obs.      : 
*/
Static Function SI401MarkAll(cAlias)
Local nRecNo:= 0
Local cFlag:= cMarca

Begin Sequence

   nRecNo:= (cAlias)->(RecNo())
   (cAlias)->(DBGoTop())
   //verifica a flag do primeiro item selecion�vel (status = 0)
   While !(cAlias)->(EOF())
      If (cAlias)->WK_STATUS == ST_OK
         If !Empty((cAlias)->WK_FLAG)
            cFlag:= Space(2)
         EndIf
         Exit
      EndIf
      (cAlias)->(DBSkip())
   End
   (cAlias)->(DBGoTop())
   //marcar� apenas os processos que est�o completamente de acordo ou aceitos pelo usu�rio
   While !(cAlias)->(EOF())
      If (cAlias)->WK_STATUS == ST_OK
         (cAlias)->WK_FLAG:= cFlag
      EndIf
      (cAlias)->(DBSkip())
   End

   (cAlias)->(DBGoTo(nRecNo))

End Sequence
Return

/*
Programa  : SI401NF()
Objetivo  : Verificar se existe nota fiscal vinculada ao processo e se esta encontra-se dentro dos par�metros
            determinados pelo usu�rio. Grava a observa��o do item, caso n�o se enquadre aos par�metros.
Par�metros: cPreemb, cNotaIni, cNotaFin, cDtNfIni, cDtNfFin, @cObs
Retorno   : nStatus
Autor     : Wilsimar Fabr�cio da Silva
Data/Hora : Junho/ 2009
Obs.      : 
*/
Static Function SI401NF(cPreemb, cNotaIni, cNotaFin, cDtNfIni, cDtNfFin, cObs)
Local aOrd:= SaveOrd("EEM")
Local cObsAux:= ""
Local nStatus:= ST_ND //inicia o status como n�o process�vel
Local lNf:= .F.

Begin Sequence

   EEM->(DBSetOrder(1)) //EEM_FILIAL + EEM_PREEMB + EEM_TIPOCA + EEM_NRNF + EEM_TIPONF
   
   If EEM->(DBSeek(xFilial() + AvKey(cPreemb, "EEM_PREEMB")))
      While !EEM->(EOF()) .And. AllTrim(cPreemb) == AllTrim(EEM->EEM_PREEMB)
         //Verifica se existe ao menos uma nota fiscal que se enquadra aos par�metros
         If AllTrim(EEM->EEM_NRNF) >= AllTrim(cNotaIni) .And.;
            AllTrim(EEM->EEM_NRNF) <= AllTrim(cNotaFin) .And.;
            AllTrim(DtoS(EEM->EEM_DTNF)) >= AllTrim(cDtNfIni) .And.;
            AllTrim(DtoS(EEM->EEM_DTNF)) <= AllTrim(cDtNfFin)
         
            lNf:= .T.
            nStatus:= ST_OK //Se n�o houver outras notas, permanecer� este status
         EndIf
         EEM->(DBSkip())
      End
   Else
      //O processo com a nota fiscal fora dos par�metros ou sem a nota fiscal ser� exibido
      //apenas se o usu�rio n�o determinou o par�metro para as notas fiscais.
      If Empty(cNotaIni) .And.;
         cNotaFin == Replicate("Z", AvSx3("EEM_NRNF", AV_TAMANHO))
         
         cObsAux:= STR0049 + ENTER //N�o existe nota fiscal vinculada a este processo.      
         nStatus:= ST_IRREGULAR //N�o possui nota fiscal; n�o se enquadra aos par�metros
      Else
         nStatus:= ST_ND //Status para n�o exibir os processos; fora dos par�metros especificados pelo usu�rio
      EndIf
      
      Break
   EndIf
   
   //Se existe ao menos uma nota que se enquadra aos par�metros, ser� verificado se o
   //processo possui outras notas, acrescentando � observa��o todas as notas relacionadas
   //e solicitando a confirma��o do usu�rio para o processamento.
   If lNf .And. EEM->(DBSeek(xFilial() + AvKey(cPreemb, "EEM_PREEMB")))
      lNf:= .F.
      While !EEM->(EOF()) .And. AllTrim(cPreemb) == AllTrim(EEM->EEM_PREEMB)
         //Se est� fora dos par�metros
         If AllTrim(EEM->EEM_NRNF) < AllTrim(cNotaIni) .Or.;
            AllTrim(EEM->EEM_NRNF) > AllTrim(cNotaFin) .Or.;
            AllTrim(DtoS(EEM->EEM_DTNF)) < AllTrim(cDtNfIni) .Or.;
            AllTrim(DtoS(EEM->EEM_DTNF)) > AllTrim(cDtNfFin)

            cObsAux += STR0015 + AllTrim(EEM->EEM_NRNF) + STR0013 + ENTER //A nota fiscal ### n�o se enquadra nos par�metros definidos.
            nStatus:= ST_PROCESSAVEL
            lNf:= .T.
         EndIf
         EEM->(DBSkip())
      End
   EndIf
   
End Sequence   

If lNf
   cObsAux:= STR0016 + ENTER + cObsAux //Al�m da NF informada, o processo possui outros itens com NF.
EndIf   
cObs += cObsAux

RestOrd(aOrd)
Return nStatus

/*
Programa  : SI401ConfSel()
Objetivo  : Confirmar a sele��o dos processos marcados com Status 1. Quando o usu�rio confirma a
            sele��o do item, altera o status para 0 (ok) e apaga as observa��es.
Par�metros: cAlias
Autor     : Wilsimar Fabr�cio da Silva
Data/Hora : Junho/ 2009
Obs.      : 
*/

Static Function SI401ConfSel(cAlias)

If EECView({{(cAlias)->WK_OBS, .T.}}, STR0002) //Aviso
   If MsgYesNo(STR0014, STR0002) //Deseja marc�-lo mesmo assim? / Aviso
      (cAlias)->WK_STATUS:= ST_OK
      (cAlias)->WK_OBS:= ""
      (cAlias)->WK_FLAG:= cMarca
   EndIf
EndIf
Return

/*
Programa  : SI401AltStatus()
Objetivo  : Ap�s clicar sobre o marca/ desmarca, verificar se existem itens com status = 1 (ST_PROCESSAVEL).
            Caso haja, solicita a confirma��o do usu�rio para marcar os itens, realizando a altera��o do
            status para 0 (ST_OK) e apagando as observa��es. Varre todos os itens da work.
Par�metros: cAlias
Autor     : Wilsimar Fabr�cio da Silva
Data/Hora : Junho/ 2009
Obs.      : 
*/
Static Function SI401AltStatus(cAlias)
Local lStatus:= .F.
Local nRecNo
Begin Sequence
   //Varre a Work procurando os itens com o Status = 1 (ST_PROCESSAVEL)
   nRecNo:= (cAlias)->(RecNo())
   (cAlias)->(DBGoTop())
   While !(cAlias)->(EOF())
      If (cAlias)->WK_STATUS == ST_PROCESSAVEL
         If MsgYesNo(STR0020 + ENTER + STR0014, STR0002) //Existem processos que n�o se enquadram aos par�metros / Deseja marc�-lo mesmo assim?, Aviso
            lStatus:= .T.
            Exit
         Else
            Exit
         EndIf            
      EndIf
      (cAlias)->(DBSkip())
   End
   
   If lStatus == .T.
      While !(cAlias)->(EOF())
         If (cAlias)->WK_STATUS == ST_PROCESSAVEL
            (cAlias)->WK_STATUS:= ST_OK
            (cAlias)->WK_OBS:= ""
         EndIf
         (cAlias)->(DBSkip())
      End
   EndIf
   (cAlias)->(DBGoTo(nRecNo))
End Sequence
Return

/*
Programa  : SI401DelProc()
Objetivo  : Excluir da (cAlias) todos os itens n�o process�veis, que est�o com pend�ncias ou irregularidades
            (Status 2) ou j� foram integradas (Status 3), com a finalidade de "limpar" as informa��es
            visualizadas pelo usu�rio.
Par�metros: cAlias
Autor     : Wilsimar Fabr�cio da Silva
Data/Hora : Junho/ 2009
Obs.      : 
*/

Static Function SI401DelProc(cAlias)

If (cAlias)->(EasyRecCount()) > 0
   If MsgYesNo(STR0021 + ENTER + STR0022, STR0002) //Esta a��o eliminar� da visualiza��o todos os processos com pend�ncias ou j� integrados(n�o process�veis)./ Deseja continuar?, Aviso
      (cAlias)->(DBGoTop())
      While !(cAlias)->(EOF())
         If (cAlias)->WK_STATUS == ST_IRREGULAR .Or. (cAlias)->WK_STATUS == ST_CONCLUIDO
            (cAlias)->(DBDelete())
         EndIf
         (cAlias)->(DBSkip())
      End
      (cAlias)->(DBGoTop())
   EndIf
EndIf

Return

/*
Programa  : SI401Siscomex
Objetivo  : Controlar o processo de gera��o de arquivos, navega��o no Siscomex e grava��o do retorno.
Par�metros: cAlias, oProcess
Autor     : Wilsimar Fabr�cio da Silva
Data/Hora : Junho/ 2009
Obs.      : Usa a vari�vel private cPathTXT e a fun��o SI400Ret() (EECSI400.PRW)
*/

Static Function SI401Siscomex(cAlias, oProcess)
Local aCnpj:= {}
Local lRet:= .T.
Local nCont:= 0
Local cMsg:= ""

Begin Sequence

   If (cAlias)->(EasyRecCount()) < 1
      MsgInfo(STR0023, STR0002) //N�o existem registros para serem processados., Aviso
      lRet:= .F.
      Break
   EndIf

   oProcess:SetRegua1((cAlias)->(EasyRecCount()) + 1)
 
   //Agrupa os processos por CNPJ da unidade exportadora.
   //A inclus�o no Siscomex � realizada com base neste CNPJ.
   aCnpj:= SI401Cnpj(cAlias, oProcess)

   //Se n�o retornou CNPJ � porque o usu�rio n�o selecionou processos para a integra��o
   If Len(aCnpj) == 0
      MsgInfo(STR0006, STR0002) //N�o h� processo(s) selecionado(s)., Aviso
      lRet:= .F.
      Break
   EndIf
   
   For nCont:= 1 To Len(aCnpj)
      //Envia os RecNo's dos processos selecionados pelo usu�rio
      lRet:= SI401GeraTxt(cAlias, oProcess, aCnpj[nCont][2])
      If !lRet
         cMsg:= DescErroSI401(FError())
         MsgInfo(STR0024 + cMsg, STR0002) //Erro na gera��o dos arquivos: ###, Aviso
         Break
      EndIf
      
      oProcess:IncRegua1(STR0033) //Processando a integra��o

      lRet:= SI401IntDDE(aCnpj[nCont][1], nCont, Len(aCnpj))
      //Se o usu�rio optou por cancelar a opera��o no momento de se conectar ao Siscomex,
      //apaga os arquivos gerados e retorna para a tela de sele��o de processos.
      If lRet == .F.
         AEval(Directory(cPathTXT + "*.inc"), {|x| FErase(cPathTxt + x[1])})
         AEval(Directory(cPathTXT + "*.avg"), {|x| FErase(cPathTxt + x[1])})
         Break
      EndIf
   Next
   
   lRet:= SI401GeraDDE(oProcess)
   If lRet == .F.
      cMsg:= DescErroSI401(FError())
      MsgInfo(STR0035 + cMsg, STR0002) //Erro na abertura do arquivo: ###, Aviso
      Break
   EndIf
   
   //Processamento do retorno.
   //Atualiza as tabelas EEX, EEZ e EE9.
   //Exibe a tela de retono para o usu�rio
   oProcess:SetRegua2(1)
   oProcess:IncRegua2(STR0042) //Atualizando o Easy Export Control
   SI400Ret()
   //Os tratamentos para copiar os arquivos para o servidor (hist�rico) e apag�-los do
   //diret�rio EEC-Sisc/Orisis ser�o realizados pelas fun��es do programa EECSI400.PRW.   
End Sequence

If !lRet
   (cAlias)->(DBGoTop())
   SI401Main(cAlias)
EndIf
Return

/*
Programa  : SI401GeraTxt
Objetivo  : Criar o arquivo TXT que ser� lido pelo CMD.
Par�metros: cAlias, oProcess, aRecNo
Autor     : Wilsimar Fabr�cio da Silva
Data/Hora : Junho/ 2009
Obs.      : Usa a vari�vel private cPathTXT
*/

Static Function SI401GeraTxt(cAlias, oProcess, aRecNo)
Local aOrd:= SaveOrd("EE9"),;
      aAgrupaRE:= {}
Local cBuffer:= "",;
      cArqInc:= "",;
      cArqAvg:= "eectot.avg",;
      cArquivos:= ""
Local lRet:= .T.
Local nSequencia,;
      nArqInc,;
      nArqAvg,;
      nCont:= 0

Begin Sequence

   EE9->(DBSetOrder(3)) //EE9_FILIAL + EE9_PREEMB + EE9_SEQEMB
   
   For nCont:= 1 To Len(aRecNo)
      
      aAgrupaRE:= {}
      (cAlias)->(DBGoTo(aRecNo[nCont]))

      oProcess:IncRegua1(STR0026) //Gerando arquivos para a integra��o

      //sequ�ncia de arquivos gerados para a integra��o com o Siscomex
      nSequencia:= EasyGParam("MV_AVG0001")
      SetMv("MV_AVG0001", nSequencia + 1)

      //nome do arquivo que ser� integrado com o Siscomex
      cArqInc:= "rd" + StrZero(nSequencia, 6) + ".inc"
         
      //armazenando os nomes dos arquivos .inc para a gera��o do arquivo eectot.avg
      cArquivos += cArqInc + ENTER
   
      //cria��o do arquivo .inc
      If (nArqInc:= EasyCreateFile(cPathTxt + cArqInc, FC_NORMAL)) < 0
         lRet:= .F.
         Break
      EndIf
         
      //ID
      cBuffer:= "ID" + ENTER
         
      //NP
      cBuffer += "NP"
      cBuffer += IncSpace((cAlias)->EEC_PREEMB, AvSx3("EEC_PREEMB", AV_TAMANHO)) //tamanho 20
      cBuffer += ENTER

      EE9->(DBSeek(xFilial() + (cAlias)->EEC_PREEMB))
      While !EE9->(EOF()) .And. AllTrim(EE9->EE9_PREEMB) == AllTrim((cAlias)->EEC_PREEMB)
         /* Para que n�o seja realizada a busca da mesma RE no Siscomex por v�rias vezes,
            o TXT ser� gerado apenas com as RE's que n�o se repetem.*/
               
         //Se n�o existe a RE, armazena e adiciona no arquivo TXT
         If AScan(aAgrupaRE, AllTrim(EE9->EE9_RE)) == 0
            AAdd(aAgrupaRE, AllTrim(EE9->EE9_RE))
            //T1
            cBuffer += "T1"
            cBuffer += IncSpace(EE9->EE9_RE, AvSx3("EE9_RE", AV_TAMANHO)) //tamanho 12
            cBuffer += ENTER
         EndIf
         EE9->(DBSkip())
      End
      //Fim de arquivo
      cBuffer += "####eof#####" + ENTER

      //Grava��o do arquivo .inc
      FWrite(nArqInc, cBuffer)
      FClose(nArqInc)      
   Next

   //fim de arquivo
   cArquivos += "####eof#####"  + ENTER

   //cria��o do arquivo .avg
   If (nArqAvg:= EasyCreateFile(cPathTxt + cArqAvg, FC_NORMAL)) < 0
      lRet:= .F.
      Break
   EndIf

   FWrite(nArqAvg, cArquivos)
   FClose(nArqAvg)   
   
End Sequence

RestOrd(aOrd)
Return lRet

/*
Programa  : SI401IntDDE
Objetivo  : Orientar o usu�rio quanto ao posicionamento de tela no Siscomex e realizar a integra��o
            com a chamada do programa CMD.
Par�metros: cCnpj, nPasso, nTotal, cProgOpc(programa opcional, quando a fun��o � chamada de outros programas)
Autor     : Wilsimar Fabr�cio da Silva
Data/Hora : Junho/ 2009
Obs.      : Usa a vari�vel private cPrograma
*/

Function SI401IntDDE(cCnpj, nPasso, nTotal, cProgOpc)
Local oDlg
Local lRet:= .T.
Local nOpcao:= 0,;
      nCont,;
      nRet

Begin Sequence
   
   //O par�metro cProgOpc possibilida a chamada da fun��o por outros programas
   If ValType(cProgOpc) <> "U"
      cPrograma:= cProgOpc
   EndIf

   Define MSDialog oDlg Title STR0005 From 0, 0 To 562, 455 Of oMainWnd Pixel //"Retorno de DDE"
      Define Font oBold Name "Arial" Size 0, -12 BOLD

      @ 010, 08 Say STR0027 Pixel Font oBold //"Conex�o com o SISCOMEX"
      @ 020, 08 Say STR0038 + AllTrim(Str(nPasso)) + ;
                    STR0039 + AllTrim(Str(nTotal)) Pixel Font oBold //Unidade exportadora: ## de ##
      @ 030, 08 Say STR0028 + Transform(cCnpj, AvSx3("A2_CGC", AV_PICTURE)) + ;
                    STR0037 Pixel //"Conecte-se ao SISCOMEX com o CNPJ " ### " e posicione na tela abaixo."
      @ 213, 08 Say STR0029 Pixel //"Ap�s ter posicionado na tela acima, clique no bot�o Avan�ar para iniciar a integra��o."
      
      @ 045, 08 To 198, 218 Label STR0040 Pixel //Tela inicial
     
      @ 050, 11 BitMap ResName "AVG_DDE" Size 203, 150 NoBorder Of oDlg Pixel

      Define SButton From 260, 160 Type 02 Of oDlg Action (nOpcao:= 0, oDlg:End()) Enable
      Define SButton From 260, 191 Type 19 Of oDlg Action (nOpcao:= 1, oDlg:End()) Enable

   Activate MSDialog oDlg Centered

   Do Case
      Case nOpcao == 0
         lRet:= .F.
      Case nOpcao == 1
         MSAguarde({|| nRet:= WaitRun(cPrograma)}, STR0032, STR0043) //Aguarde, "Realizando a busca no Siscomex..."
         If nRet < 0
            lRet:= .F.
         EndIf
   EndCase

End Sequence
Return lRet

/*
Programa  : SI401Cnpj
Objetivo  : Retornar os CNPJ's das unidades exportadoras dos itens de embarque.
Par�metros: cAlias, oProcess
Autor     : Wilsimar Fabr�cio da Silva
Data/Hora : Junho/ 2009
Obs.      : Usa a fun��o CNPJUnidExp (EECSI101.PRW).
*/

Static Function SI401CNPJ(cAlias, oProcess)

Local aRet:= {},;
      aOrd:= SaveOrd("EE9")
Local cCnpj
Local nRecNo:= (cAlias)->(RecNo()),;
      nPos

Begin Sequence

   (cAlias)->(DBGoTop())
   EE9->(DBSetOrder(3)) //EE9_FILIAL + EE9_PREEMB + EE9_SEQEMB
   
   While (cAlias)->(!Eof())

      oProcess:IncRegua1(STR0036) //Coletando os CNPJ's das unidades exportadoras

      //o processo deve estar selecionado e o Status como totalmente regular
      If !Empty((cAlias)->WK_FLAG) .And. (cAlias)->WK_STATUS == ST_OK
   
         EE9->(DBSeek(xFilial() + (cAlias)->EEC_PREEMB))

         While !EE9->(Eof()) .And. EE9->EE9_FILIAL == xFilial("EE9") .And.;
            AllTrim(EE9->EE9_PREEMB) == AllTrim((cAlias)->EEC_PREEMB)

            cCnpj:= CNPJUnidExp(EE9->EE9_PREEMB, EE9->EE9_SEQEMB)

            If (nPos:= AScan(aRet, {|x| x[1] == cCnpj})) > 0
               //Verifica se o RecNo da WorkProc j� n�o foi adicionado
               If AScan(aRet[nPos][2], (cAlias)->(RecNo())) == 0
                  AAdd(aRet[nPos][2], (cAlias)->(RecNo()))
               EndIf
            Else
               AAdd(aRet, {cCnpj, {(cAlias)->(RecNo())}})
            EndIf

            EE9->(DBSkip())
         End
      EndIf
      (cAlias)->(DBSkip())
   End
   
   //Ponto de entrada para altera��o do array contendo os CNPJs das unidades exportadoras
   If EasyEntryPoint("EECSI401")
      aRet:= ExecBlock("EECSI401",.F.,.F.,{"CNPJ", aRet}) 
   EndIf

End Sequence

RestOrd(aOrd)
(cAlias)->(DBGoTo(nRecNo))

Return(aRet)

/*
Programa  : SI401GeraDDE
Objetivo  : Ler os arquivos TXT retornados pelo Siscomex e gerar os registros nas tabelas EEX e EEZ,
            caso n�o existam.
Par�metros: oProcess
Autor     : Wilsimar Fabr�cio da Silva
Data/Hora : Junho/ 2009
Obs.      : Usa a vari�vel private cPathTXT e a fun��o SI400Man() (programa EECSI400.PRW)
*/

Static Function SI401GeraDDE(oProcess)
Local aArqOk:= {},;
      aPreemb:= {},;
      aOrd:= SaveOrd("EE9")
Local cArquivo:= "",;
      cBuffer:= ""
Local nCont,;
      nArqOk,;
      nTamTotal
Local lRet:= .T.

Begin Sequence
   
   aArqOk:= Directory(cPathTXT + "*.ok")

   oProcess:SetRegua2(Len(aArqOk))

   //Lendo os RE's que obtiveram retorno com sucesso
   For nCont:= 1 To Len(aArqOk)
      oProcess:IncRegua2(STR0034) //Verificando arquivos de retorno
      //Nome do arquivo
      cArquivo:= aArqOk[nCont][1]
      //Tamanho total do arquivo
      nTamTotal:= aArqOk[nCont][2] //FSeek(nArqOk, 0, FS_END)

      nArqOk:= EasyOpenFile(cPathTXT + cArquivo, FO_READ + FO_EXCLUSIVE)

      If nArqOk < 0
         lRet:= .F.
         Break
      EndIf

      FSeek(nArqOk, 0, 0)
      FRead(nArqOk, @cBuffer, nTamTotal)

      //Coletar o n�mero do processo para a gera��o do processo nas tabelas EEX e EEZ dos arquivos .ok
      cBuffer:= StrTran(cBuffer, ENTER, "")
      AAdd(aPreemb, SubStr(cBuffer, 1, AvSx3("EEC_PREEMB", AV_TAMANHO))) //tamanho 20
      cBuffer:= ""

      FClose(nArqOK)
   Next

   //Grava��o nas tabelas do Easy
   //Gerando o registro nas tabelas EEX e EEZ. Correspondente a op��o "Preparar" da rotina
   //de "Gera��o de DDE"
   oProcess:SetRegua2(Len(aPreemb))
   EEC->(DBSetOrder(1)) //EEC_FILIAL + EEC_PREEMB
   For nCont:= 1 To Len(aPreemb)
   
      oProcess:IncRegua2(STR0041) //Gerando registros nas tabelas EEX e EEZ
      
      If EEC->(DBSeek(xFilial() + aPreemb[nCont]))
         SI400Man(,, 3, .F.) //op��o 3: Preparar; .F.: lShowDlg
      EndIf
   Next

End Sequence

RestOrd(aOrd)
Return lRet

/*
Funcao    : SI400Legenda()
Objetivos : Exibir a legenda das flags de status dos itens selecionados pelo usu�rio
Parametros: 
Autor     : Wilsimar Fabr�cio da Silva
Data/Hora : Junho/ 2009
Obs.      :
*/

Static Function SI401Legenda()
Local aLegenda:= {}

   AAdd(aLegenda, {"BR_VERDE"   , STR0045}) //Pronto para a integra��o
   AAdd(aLegenda, {"BR_AMARELO" , STR0046}) //Dados fora dos par�metros
   AAdd(aLegenda, {"BR_VERMELHO", STR0047}) //Possui pend�ncias 
   AAdd(aLegenda, {"BR_AZUL"    , STR0048}) //Concluido

   BrwLegenda(cCadastro, STR0044, aLegenda) //Legenda

Return

/*
Fun��o    : DescErroSI401
Objetivo  : Retornar a descri��o do erro na cria��o e grava��o do arquivo.
Par�metros: FError()
Retorno   : Descri��o do erro
Autor     : Wilsimar Fabr�cio da Silva
Data      : 19/11/2009
Obs.      :
*/
Static Function DescErroSI401(nErro)
Local cDescErro:= ""

Begin Sequence

      Do Case
         Case nErro == 2
            cDescErro:= "Arquivo n�o encontrado"
         Case nErro == 3
            cDescErro:= "Caminho n�o encontrado"
         Case nErro == 4
            cDescErro:= "Muitos arquivos abertos"
         Case nErro == 5
            cDescErro:= "Acessso negado"
         Case nErro == 6
            cDescErro:= "Manipulador Invalido"
         Case nErro == 8
            cDescErro:= "Mem�ria Insuficiente"
         Case nErro == 15
            cDescErro:= "Drive especificado inv�lido"
         Case nErro == 19
            cDescErro:= "Tentativa de gravar em disco protegido contra grava��o"
         Case nErro == 21
            cDescErro:= "Drive n�o esta pronto"
         Case nErro == 23
            cDescErro:= "Dados com erro de CRC"
         Case nErro == 29
            cDescErro:= "Erro de grava��o"
         Case nErro == 30
            cDescErro:= "Erro de leitura"
         Case nErro == 32
            cDescErro:= "Viola��o de compartilhamento"
         Case nErro == 33
            cDescErro:= "Erro de Lock"
         Case nErro == 430 .Or. nErro == 161
            cDescErro:= "Arquivo n�o encontrado"
         OtherWise
            cDescErro:= "Erro desconhecido"
      EndCase

End Sequence
Return cDescErro
